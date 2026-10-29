//! OSR entries (design/jit.md, "OSR"): code that moves a call running a function's AOT code at
//! one of its loop heads into the function's JIT code, converting the frame in place.
//!
//! A loop head's counter stub calls through its JIT record's `osr` slot with `eax` the
//! head's index ([`super::Decoded::heads`]), `rsp` at `fp - F_aot - 8` (the stub's return
//! address on top), the whole state in the AOT frame. The *dispatcher* jumps through a table
//! to the head's entry. An entry drops the return address, keeps `fp` (the return address,
//! the caller's frame and the stack arguments don't move), moves `rsp` to `fp - F_jit`, moves
//! the live values whose slots differ ([`super::frame::osr_moves`]) through a scratch area
//! below both frames, loads first and stores second (a parallel move), and jumps to the head
//! in the JIT code. A head it can't enter (`None`) returns to the stub, which continues the
//! AOT code.

use alloc::vec::Vec;

use super::{Mode, PROBE_FROM};
use crate::image::cfa;

/// What the OSR entry of one loop head does.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct OsrEntry {
    /// The head's position in the JIT code (bytes from its start).
    pub landing: u32,
    /// The moves: `len` bytes from AOT offset `from` to JIT offset `to`.
    pub moves: Vec<(i32, i32, u32)>,
}

/// The dispatcher and the entries of one function.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct OsrCode {
    pub code: Vec<u8>,
    /// The `rel32` fields of `call ryo_probe_stack`s (offsets in `code`), the `imm64` ones
    /// with [`Mode::far_rt`].
    pub probes: Vec<u32>,
    /// The CFA rules: at each offset in `code`, the DWARF call frame instructions that take
    /// effect there (after the CIE's initial `CFA = rsp + 8`), in order.
    pub cfi: Vec<(u32, Vec<u8>)>,
}

/// `DW_CFA_def_cfa reg, off`, as a rule of its own.
fn def_cfa(reg: u8, off: u32) -> Vec<u8> {
    let mut v = Vec::new();
    cfa::def_cfa(&mut v, reg, off);
    v
}

/// The base register of the entries' frame addressing: `rbp` with a frame pointer, else
/// `rdx`, which the entry sets to `fp` (the probe preserves it); `rsp` for the scratch area
/// and for computing `fp` into `rdx`.
#[derive(Clone, Copy)]
enum Base {
    Rdx,
    Rbp,
    Rsp,
}

impl Base {
    /// ModRM `rm` (and SIB) of `[base + disp32]` with register field `reg`.
    fn modrm(self, out: &mut Vec<u8>, reg: u8, disp: i32) {
        match self {
            Base::Rdx => out.push(0x80 | reg << 3 | 2),
            Base::Rbp => out.push(0x80 | reg << 3 | 5),
            Base::Rsp => out.extend([0x84 | reg << 3, 0x24]),
        }
        out.extend(disp.to_le_bytes());
    }
}

/// `mov` of `size` bytes (1, 2, 4 or 8) between `rax` and `[base + disp]`.
fn mov(out: &mut Vec<u8>, load: bool, size: u32, base: Base, disp: i32) {
    match size {
        8 => out.push(0x48),
        2 => out.push(0x66),
        _ => {}
    }
    let op = match (size, load) {
        (1, true) => 0x8a,
        (1, false) => 0x88,
        (_, true) => 0x8b,
        (_, false) => 0x89,
    };
    out.push(op);
    base.modrm(out, 0, disp);
}

/// `lea dst, [base + disp]`, `dst` `rsp` (4) or `rdx` (2).
fn lea(out: &mut Vec<u8>, dst: u8, base: Base, disp: i32) {
    out.extend([0x48, 0x8d]);
    base.modrm(out, dst, disp);
}

/// The CFA rules: offset in the code, DWARF call frame instructions.
pub(crate) type Cfi = Vec<(u32, Vec<u8>)>;

/// The start of an OSR code, shared by the AOT-layout entries here and the SSA tier's: the
/// initial CFA rule and the dispatcher for `n` heads. Returns the code, the rules and the
/// table's offset.
///
/// With a frame pointer the rules are the body's throughout: CFA = rbp + 16, rbp saved at
/// CFA - 16. Without, CFA = rsp + F_aot + 24 while the stub's return address is on the stack.
pub(crate) fn dispatcher(n: usize, fp: bool, f_aot: u32) -> (Vec<u8>, Cfi, usize) {
    let mut c = Vec::new();
    let mut cfi = Vec::new();
    if fp {
        let mut v = def_cfa(cfa::RBP, 16);
        cfa::offset(&mut v, cfa::RBP, 2);
        cfi.push((0, v));
    } else {
        cfi.push((0, def_cfa(cfa::RSP, f_aot + 24)));
    }
    // `lea r11, [rip + table]; movsxd rax, [r11 + rax*4]; add rax, r11; jmp rax`, then the
    // table, 4-aligned, of `i32` offsets from it.
    c.extend([0x4c, 0x8d, 0x1d]);
    let table_field = c.len();
    c.extend([0; 4]);
    c.extend([0x49, 0x63, 0x04, 0x83, 0x4c, 0x01, 0xd8, 0xff, 0xe0]);
    while c.len() % 4 != 0 {
        c.push(0xcc);
    }
    let table = c.len();
    let d = (table - (table_field + 4)) as i32;
    c[table_field..table_field + 4].copy_from_slice(&d.to_le_bytes());
    c.resize(table + 4 * n, 0);
    (c, cfi, table)
}

/// Starts head `n`'s entry at the end of `c`: its table slot and, without a frame pointer,
/// its CFA rule.
pub(crate) fn entry_start(c: &mut Vec<u8>, cfi: &mut Cfi, table: usize, n: usize, fp: bool, f_aot: u32) {
    let len = c.len();
    let off = (len - table) as i32;
    c[table + 4 * n..][..4].copy_from_slice(&off.to_le_bytes());
    if !fp {
        cfi.push((len as u32, def_cfa(cfa::RSP, f_aot + 24)));
    }
}

/// `pop rcx`: drops the stub's return address (CFA = rsp + F_aot + 16 without a frame
/// pointer).
pub(crate) fn drop_return(c: &mut Vec<u8>, cfi: &mut Cfi, fp: bool, f_aot: u32) {
    c.push(0x59);
    if !fp {
        let mut v = Vec::new();
        cfa::def_cfa_offset(&mut v, f_aot + 16);
        cfi.push((c.len() as u32, v));
    }
}

/// `lea rdx, [rsp + F_aot]` after [`drop_return`] without a frame pointer: rdx = fp, and from
/// here CFA = rdx + 16.
pub(crate) fn fp_to_rdx(c: &mut Vec<u8>, cfi: &mut Cfi, f_aot: u32) {
    lea(c, 2, Base::Rsp, f_aot as i32);
    cfi.push((c.len() as u32, def_cfa(cfa::RDX, 16)));
}

/// The low end of an entry's stack, `fp - low`: the scratch area of `scratch` bytes below
/// both frames.
pub(crate) fn low(f_aot: u32, f_jit: u32, scratch: u32) -> u32 {
    f_aot.max(f_jit) + scratch.next_multiple_of(16)
}

/// `mov eax, grow; call ryo_probe_stack` when growing the stack by `grow` bytes needs it:
/// touches the pages below `rsp`. With `far_rt`, `mov r11, imm64; call r11` (the field is
/// the `imm64`). Preserves everything but `rax` and `r11`.
pub(crate) fn probe(c: &mut Vec<u8>, probes: &mut Vec<u32>, grow: u32, far_rt: bool) {
    if grow < PROBE_FROM {
        return;
    }
    c.push(0xb8);
    c.extend(grow.to_le_bytes());
    if far_rt {
        c.extend([0x49, 0xbb]);
        probes.push(c.len() as u32);
        c.extend([0; 8]);
        c.extend([0x41, 0xff, 0xd3]);
    } else {
        c.push(0xe8);
        probes.push(c.len() as u32);
        c.extend([0; 4]);
    }
}

/// `jmp rel32` to `landing` in the JIT code, the OSR code being placed `at` bytes after its
/// start.
pub(crate) fn jmp_landing(c: &mut Vec<u8>, at: u32, landing: u32) {
    c.push(0xe9);
    let rel = landing as i64 - (at as i64 + c.len() as i64 + 4);
    c.extend((rel as i32).to_le_bytes());
}

/// The dispatcher and entries for `entries` (by head index), for a function whose AOT frame
/// is `f_aot` and JIT frame `f_jit` bytes, in `mode`, placed `at` bytes after the JIT code's
/// start (the landings' origin).
pub fn osr_code(entries: &[Option<OsrEntry>], f_aot: u32, f_jit: u32, mode: Mode, at: u32) -> OsrCode {
    let mut probes = Vec::new();
    let fp = mode.frame_pointer;
    let (mut c, mut cfi, table) = dispatcher(entries.len(), fp, f_aot);
    for (n, e) in entries.iter().enumerate() {
        entry_start(&mut c, &mut cfi, table, n, fp, f_aot);
        let Some(e) = e else {
            // Not enterable: back to the stub, and on in the AOT code.
            c.push(0xc3);
            continue;
        };
        drop_return(&mut c, &mut cfi, fp, f_aot);
        if !(e.moves.is_empty() && f_aot == f_jit) {
            let base = if fp {
                Base::Rbp
            } else {
                fp_to_rdx(&mut c, &mut cfi, f_aot);
                Base::Rdx
            };
            // The scratch area below both frames, 8 bytes per started 8 of each move.
            let low = low(f_aot, f_jit, e.moves.iter().map(|m| m.2.next_multiple_of(8)).sum());
            probe(&mut c, &mut probes, low - f_aot, mode.far_rt);
            if low != f_aot {
                lea(&mut c, 4, base, -(low as i32));
            }
            // Load everything into the scratch area, then store it to the new homes.
            for pass in 0..2 {
                let mut k = 0i32;
                for &(from, to, len) in &e.moves {
                    let mut done = 0;
                    while done < len {
                        let left = len - done;
                        let size = [8, 4, 2, 1].into_iter().find(|&s| s <= left).unwrap();
                        let (src, dst) = if pass == 0 {
                            ((base, from + done as i32), (Base::Rsp, k + done as i32))
                        } else {
                            ((Base::Rsp, k + done as i32), (base, to + done as i32))
                        };
                        mov(&mut c, true, size, src.0, src.1);
                        mov(&mut c, false, size, dst.0, dst.1);
                        done += size;
                    }
                    k += len.next_multiple_of(8) as i32;
                }
            }
            if low != f_jit {
                lea(&mut c, 4, base, -(f_jit as i32));
            }
        }
        jmp_landing(&mut c, at, e.landing);
    }
    OsrCode { code: c, probes, cfi }
}
