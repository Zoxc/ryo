//! Test support: a tiny assembler, an in-memory linker for image objects (machine code
//! included, with its unwind information registered with the unwinder), and calls into the
//! VM through `vm::enter`.

#![allow(dead_code)]

use std::any::Any;
use std::collections::HashMap;
use std::ffi::c_void;
use std::mem::{ManuallyDrop, MaybeUninit};
use std::sync::Mutex;
use std::sync::atomic::{AtomicU64, Ordering};

pub use ryo_bytecode::Opcode;
pub use ryo_bytecode::asm::Mode;
pub use ryo_bytecode::image::*;
pub use ryo_bytecode::full::*;

/// The encoding mode: the runtime's, with loop alignment on.
pub const ENC: Mode = Mode { align_loops: true, pe: false, ..ryo_rt::vm::MODE };

/// A code buffer with patchable branch targets.
#[derive(Default)]
pub struct Asm {
    pub c: CodeBuf,
    /// The slot of the sret pointer ([`Asm::sret`]).
    sret: Option<Slot>,
}

impl Asm {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn pos(&self) -> u32 {
        self.c.pos()
    }
    pub fn i(&mut self, insn: Insn<'_>) -> u32 {
        self.c.emit(&insn)
    }
    /// Encodes `op` with the operand values in list order, by their kinds in `OP_INFO`
    /// (list operands unsupported). Checks that the result decodes.
    pub fn raw(&mut self, op: Opcode, vals: &[u128]) -> u32 {
        let at = self.pos();
        let info = op.info();
        assert_eq!(info.operands.len(), vals.len(), "{}", info.mnemonic);
        self.c.words.push(op as u32);
        for (o, &v) in info.operands.iter().zip(vals) {
            let n = o.kind.words().expect("list operand");
            for i in 0..n {
                self.c.words.push((v >> (32 * i)) as u32);
            }
        }
        Insn::decode(&self.c.words[at as usize..]).expect("encoding");
        at
    }
    /// Points the `Target` operand `name` of the instruction at `at` to `target`.
    pub fn patch(&mut self, at: u32, name: &str, target: u32) {
        let op = Opcode::from_u16(self.c.words[at as usize] as u16).unwrap();
        self.c.set_target(at, op.info().operand_index(name).unwrap(), target);
    }
    /// Sets element `i` of the target list `name` of the instruction at `at`.
    pub fn patch_list(&mut self, at: u32, name: &str, i: usize, target: u32) {
        let op = Opcode::from_u16(self.c.words[at as usize] as u16).unwrap();
        self.c.set_list_target(at, op.info().operand_index(name).unwrap(), i, target);
    }
    /// `arg` of the sret pointer into `at`, first in a function that returns a value of a
    /// size other than 0, 1, 2, 4, 8 and 16 bytes ([`Asm::ret`]).
    pub fn sret(&mut self, at: Slot) -> u32 {
        self.sret = Some(at);
        self.i(Insn::Arg { d: at, r: ryo_bytecode::asm::ArgReg { xmm: false, size: 8, index: 0 }.word() })
    }
    /// `ret` of the `len` bytes at `s`: in `rax` (and `rdx`), or for another size through the
    /// sret pointer ([`Asm::sret`]). Returns the position of the first instruction.
    pub fn ret(&mut self, s: Slot, len: u32) -> u32 {
        match len {
            0 => self.i(Insn::Ret { s: Slot(0), k: 0 }),
            1 | 2 | 4 | 8 | 16 => self.i(Insn::Ret { s, k: kind(len) }),
            _ => {
                let p = self.sret.expect("sret function");
                let at = self.i(Insn::StoreCopy { m: Mem { p, k: 0 }, s, len });
                self.i(Insn::Ret { s: p, k: 8 });
                at
            }
        }
    }
    pub fn done(self) -> Vec<u32> {
        self.c.words
    }
}

/// The return kind of a `len`-byte integer value in registers (1, 2, 4, 8 or 16 bytes).
pub fn kind(len: u32) -> u32 {
    use ryo_bytecode::asm::{RetPart, ret_kind};
    let p = |size, off| RetPart { xmm: false, size, off };
    if len == 16 { ret_kind(&[p(8, 0), p(8, 8)]) } else { ret_kind(&[p(len, 0)]) }
}

static NEXT_NAME: AtomicU64 = AtomicU64::new(0);

/// A function definition with frame size `frame_size` (`F`: locals plus the largest outgoing
/// block, a multiple of 16), named `f<n>`.
pub fn func(code: Vec<u32>, frame_size: u32, arg_size: u32, ret_size: u32) -> FunctionDef {
    let ret_kind = match ret_size {
        0 => 0,
        1 | 2 | 4 | 8 | 16 => kind(ret_size),
        _ => ryo_bytecode::asm::RET_SRET,
    };
    assert_eq!(frame_size % 16, 0, "frames are 16-aligned");
    let name = format!("f{}", NEXT_NAME.fetch_add(1, Ordering::Relaxed));
    FunctionDef { name, code, frame_size, arg_size, ret_size, ret_kind, ..Default::default() }
}

static NEXT_SCID: AtomicU64 = AtomicU64::new(0x5eed_0000_0000_0001);

/// A fresh StableCrateId whose crate hash differs from every other test image's.
pub fn unique_scid() -> u64 {
    NEXT_SCID.fetch_add(1, Ordering::Relaxed)
}

// ---- memory ----

unsafe extern "C" {
    fn mmap(addr: *mut c_void, len: usize, prot: i32, flags: i32, fd: i32, off: i64) -> *mut c_void;
    fn mprotect(addr: *mut c_void, len: usize, prot: i32) -> i32;
    /// libgcc's: registers an `.eh_frame` (terminated by a zero word) with the unwinder.
    fn __register_frame(begin: *const u8);
    /// std's personality routine, which the CIE names.
    fn rust_eh_personality();
}

const PROT_READ: i32 = 1;
const PROT_WRITE: i32 = 2;
const PROT_EXEC: i32 = 4;
const MAP_PRIVATE: i32 = 0x02;
const MAP_ANONYMOUS: i32 = 0x20;
const MAP_NORESERVE: i32 = 0x4000;
const MAP_FIXED_NOREPLACE: i32 = 0x10_0000;
const PAGE: usize = 4096;
const ARENA: usize = 256 << 20;

/// A bump allocator over one mapping within ±2 GiB of `ryo_rt`'s code, so that the
/// machine code's 32-bit PC-relative fields reach the handlers and every section.
struct Arena {
    cur: usize,
    end: usize,
}

static MEM: Mutex<Option<Arena>> = Mutex::new(None);

fn new_arena() -> Arena {
    let near = ryo_rt::vm::handler(Opcode::Copy).unwrap() as usize & !(PAGE - 1);
    for k in 1..8isize {
        for sign in [1isize, -1] {
            let hint = (near as isize + sign * k * (128 << 20)) as usize & !(PAGE - 1);
            let p = unsafe {
                mmap(
                    hint as *mut c_void,
                    ARENA,
                    PROT_READ | PROT_WRITE,
                    MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE | MAP_FIXED_NOREPLACE,
                    -1,
                    0,
                )
            };
            if p as isize == -1 {
                continue;
            }
            assert_eq!(p as usize, hint, "kernel without MAP_FIXED_NOREPLACE");
            return Arena { cur: p as usize, end: p as usize + ARENA };
        }
    }
    panic!("no address range near the runtime's code");
}

/// `len` zeroed bytes aligned to `align`, never freed.
fn alloc(len: usize, align: usize) -> *mut u8 {
    let mut g = MEM.lock().unwrap();
    let a = g.get_or_insert_with(new_arena);
    let p = a.cur.next_multiple_of(align);
    assert!(p + len <= a.end, "test arena exhausted");
    a.cur = p + len;
    p as *mut u8
}

fn place(bytes: &[u8], align: usize) -> *mut u8 {
    let p = alloc(bytes.len().max(1), align.max(16));
    unsafe { std::ptr::copy_nonoverlapping(bytes.as_ptr(), p, bytes.len()) };
    p
}

// ---- linking ----

/// A linked image: every section placed, relocations applied, unwind information registered.
pub struct Linked {
    pub header: *const u8,
    pub data: *mut u8,
    pub text: *const u8,
    pub crate_hash: u32,
    pub symbols: Vec<String>,
    pub functions: Vec<FuncCode>,
}

unsafe impl Sync for Linked {}
unsafe impl Send for Linked {}

/// Places the sections and applies every relocation, resolving symbols through `syms`
/// (and `rust_eh_personality` to std's), the handlers through `vm::handler` and the probe to
/// `vm::probe_stack`. Then makes the text executable and registers the `.eh_frame`.
pub fn link(obj: ImageObject, syms: &[(&str, usize)]) -> Linked {
    let map: HashMap<&str, usize> = syms.iter().copied().collect();
    let ro = place(&obj.rodata, obj.rodata_align as usize);
    let data = place(&obj.data, obj.data_align as usize);
    let text_len = obj.text.len().max(1).next_multiple_of(PAGE);
    let text = alloc(text_len, PAGE);
    unsafe { std::ptr::copy_nonoverlapping(obj.text.as_ptr(), text, obj.text.len()) };
    let unwind = |s: Section| obj.unwind.iter().find(|u| u.0 == s).map(|u| u.1.as_slice()).unwrap_or(&[]);
    let lsda = place(unwind(Section::Lsda), 4);
    let ehb = unwind(Section::EhFrame);
    let mut eh_bytes = ehb.to_vec();
    eh_bytes.extend_from_slice(&[0; 4]); // the terminator
    let eh = place(&eh_bytes, 8);

    let base = |s: Section| -> usize {
        match s {
            Section::ReadOnly => ro as usize,
            Section::Writable => data as usize,
            Section::Text => text as usize,
            Section::Lsda => lsda as usize,
            Section::EhFrame => eh as usize,
            s => panic!("unexpected section {s:?}"),
        }
    };
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => {
                let name = &obj.symbols[s.0 as usize].name;
                if name == PERSONALITY {
                    rust_eh_personality as *const () as usize
                } else {
                    *map.get(name.as_str()).unwrap_or_else(|| panic!("unresolved symbol {name}"))
                }
            }
            RelocTarget::Section(s) => base(s),
            RelocTarget::Handler(op) => ryo_rt::vm::handler(op).unwrap_or_else(|| panic!("no handler for {op:?}")) as usize,
            RelocTarget::Probe => ryo_rt::vm::probe_stack as *const () as usize,
        };
        let v = (target as u64).wrapping_add(r.addend as u64);
        let field = base(r.section) + r.offset as usize;
        match r.kind {
            RelocKind::Abs64 => unsafe { (field as *mut u64).write_unaligned(v) },
            RelocKind::Pc32 | RelocKind::Call32 => {
                let d = v.wrapping_sub(field as u64) as i64;
                let d32 = i32::try_from(d).unwrap_or_else(|_| panic!("PC-relative field out of range: {r:?}"));
                unsafe { (field as *mut i32).write_unaligned(d32) }
            }
            RelocKind::Rva32 => panic!("PE relocation on ELF"),
        }
    }
    assert_eq!(unsafe { mprotect(text.cast(), text_len, PROT_READ | PROT_EXEC) }, 0, "mprotect");
    unsafe { __register_frame(eh) };
    let crate_hash = unsafe { Image::from_header(ro) }.unwrap().crate_hash();
    Linked {
        header: ro,
        data,
        text,
        crate_hash,
        symbols: obj.symbols.iter().map(|s| s.name.clone()).collect(),
        functions: obj.functions,
    }
}

pub fn register(images: &[&Linked]) {
    let hs: Vec<*const u8> = images.iter().map(|l| l.header).collect();
    unsafe { ryo_rt::vm::ryo_vm_register(hs.as_ptr(), hs.len()) };
}

/// Encodes and links an image (unregistered).
pub fn assemble(w: ImageWriter, syms: &[(&str, usize)]) -> Linked {
    link(w.finish(ENC).expect("image"), syms)
}

/// Builds, links and registers an image.
pub fn build(w: ImageWriter, syms: &[(&str, usize)]) -> Linked {
    let l = assemble(w, syms);
    register(&[&l]);
    l
}

/// A function to call through [`call`]: its code, argument block size and return kind.
#[derive(Clone, Copy)]
pub struct Entry {
    pub code: *const u8,
    pub arg_size: u32,
    pub ret_kind: u32,
}

unsafe impl Send for Entry {}

impl Linked {
    pub fn id(&self, f: Func) -> Entry {
        let e = unsafe { Image::from_header(self.header) }.unwrap().functions()[f.0 as usize];
        Entry { code: self.code(f), arg_size: e.arg_size, ret_kind: e.ret_kind }
    }
    /// The machine code of function `f`.
    pub fn code(&self, f: Func) -> *const u8 {
        unsafe { self.text.add(self.functions[f.0 as usize].start as usize) }
    }
}

/// [`test_enter`]'s operands and results (`repr(C)`: the assembly uses the offsets).
#[repr(C)]
struct EnterCall {
    args: *const u8,
    arg_size: usize,
    /// A multiple of 16, at least `arg_size` and 48.
    reserve: usize,
    /// The first integer argument: an sret function's return value pointer.
    sret: *mut u8,
    regs: [u64; 2],
    xmm: [[u8; 16]; 2],
}

unsafe extern "Rust" {
    /// Calls `entry` with the argument block copied to the stack (the callee's `fp + 16`),
    /// its first six words also in `rdi rsi rdx rcx r8 r9` (with `call.sret`, if not null,
    /// in `rdi` instead and the words in the others), and stores the return registers. The
    /// hand-written test functions take their arguments either way.
    fn test_enter(entry: *const u8, call: *mut EnterCall);
}

core::arch::global_asm!(
    ".text",
    ".p2align 4",
    ".globl test_enter",
    "test_enter:",
    ".cfi_startproc",
    "push rbp",
    ".cfi_def_cfa_offset 16",
    ".cfi_offset rbp, -16",
    "push rbx",
    ".cfi_def_cfa_offset 24",
    ".cfi_offset rbx, -24",
    "mov rbx, rsp",
    ".cfi_def_cfa_register rbx",
    "push rsi",
    "sub rsp, [rsi + 16]",
    "mov rax, rdi",
    "mov rdi, rsp",
    "mov rcx, [rsi + 8]",
    "mov rsi, [rsi]",
    "rep movsb",
    "mov r11, [rbx - 8]",
    "mov rdi, [r11 + 24]",
    "test rdi, rdi",
    "jnz 2f",
    "mov rdi, [rsp]",
    "mov rsi, [rsp + 8]",
    "mov rdx, [rsp + 16]",
    "mov rcx, [rsp + 24]",
    "mov r8, [rsp + 32]",
    "mov r9, [rsp + 40]",
    "jmp 3f",
    "2:",
    "mov rsi, [rsp]",
    "mov rdx, [rsp + 8]",
    "mov rcx, [rsp + 16]",
    "mov r8, [rsp + 24]",
    "mov r9, [rsp + 32]",
    "3:",
    "xor ebp, ebp",
    "call rax",
    "mov rcx, [rbx - 8]",
    "mov [rcx + 32], rax",
    "mov [rcx + 40], rdx",
    "movups [rcx + 48], xmm0",
    "movups [rcx + 64], xmm1",
    "mov rsp, rbx",
    "pop rbx",
    ".cfi_def_cfa rsp, 16",
    "pop rbp",
    ".cfi_def_cfa_offset 8",
    "ret",
    ".cfi_endproc",
);

/// Calls the VM function `e` with the argument block `args` ([`test_enter`]), catching a
/// panic that unwinds out of it, and collects its return value as its return kind says.
pub fn call<A, R>(e: Entry, args: A) -> Result<R, Box<dyn Any + Send>> {
    use ryo_bytecode::asm::{RET_SRET, ret_parts};
    let args = ManuallyDrop::new(args);
    let mut ret = MaybeUninit::<R>::uninit();
    let mut c = EnterCall {
        args: (&raw const args).cast(),
        arg_size: e.arg_size as usize,
        reserve: (e.arg_size as usize).max(48).next_multiple_of(16),
        sret: if e.ret_kind == RET_SRET { ret.as_mut_ptr().cast() } else { std::ptr::null_mut() },
        regs: [0; 2],
        xmm: [[0; 16]; 2],
    };
    std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| unsafe { test_enter(e.code, &mut c) }))?;
    let (mut g, mut x) = (0, 0);
    for p in ret_parts(e.ret_kind, false).into_iter().flatten().flatten() {
        let src: &[u8] = if p.xmm {
            x += 1;
            &c.xmm[x - 1]
        } else {
            g += 1;
            unsafe { std::slice::from_raw_parts((&raw const c.regs[g - 1]).cast(), 8) }
        };
        unsafe { std::ptr::copy_nonoverlapping(src.as_ptr(), ret.as_mut_ptr().cast::<u8>().add(p.off as usize), p.size as usize) };
    }
    Ok(unsafe { ret.assume_init() })
}

/// A call's argument list ([`ryo_bytecode::asm::params_ok`]): each slot's 8 bytes into the
/// next integer argument register.
pub fn regs(slots: &[i32]) -> Vec<u32> {
    let mut a = Vec::new();
    for (i, &s) in slots.iter().enumerate() {
        a.extend([s as u32, ryo_bytecode::asm::ArgReg { xmm: false, size: 8, index: i as u32 }.word()]);
    }
    a
}

/// `arg`: the integer argument register `i` to slot `d`.
pub fn arg(d: i32, i: u32) -> Insn<'static> {
    Insn::Arg { d: Slot(d), r: ryo_bytecode::asm::ArgReg { xmm: false, size: 8, index: i }.word() }
}

pub fn ok<A, R>(id: Entry, args: A) -> R {
    match call(id, args) {
        Ok(r) => r,
        Err(e) => std::panic::resume_unwind(e),
    }
}

/// Address of a value as `usize` (for symbol tables).
pub fn addr<T>(p: *const T) -> usize {
    p as usize
}

pub type IslandFn = unsafe fn(*mut u8, *const u32) -> u32;

pub fn island(f: IslandFn) -> usize {
    f as usize
}

/// A slot offset as an island operand word.
pub const fn op(s: i32) -> u32 {
    s as u32
}
