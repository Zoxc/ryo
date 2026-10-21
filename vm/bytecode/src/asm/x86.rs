//! The canonical machine-code elements of VM code: every [`Item`] has exactly one encoding,
//! and [`read`] accepts only that one. Immediates take their shortest form; padding is the
//! standard multi-byte `nop`s, which never use `rcx`, so they can't be mistaken for the call
//! marker `nop dword [rcx + d]`.

use alloc::vec::Vec;

use super::encode::{Ref, Reloc};

/// The general-purpose registers the encoder uses, by their x86 number.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Reg {
    Rax = 0,
    Rcx = 1,
    Rdx = 2,
    Rsp = 4,
    Rbp = 5,
    Rsi = 6,
    Rdi = 7,
    R8 = 8,
    R9 = 9,
}

impl Reg {
    fn from_num(n: u8) -> Option<Reg> {
        Some(match n {
            0 => Reg::Rax,
            1 => Reg::Rcx,
            2 => Reg::Rdx,
            4 => Reg::Rsp,
            5 => Reg::Rbp,
            6 => Reg::Rsi,
            7 => Reg::Rdi,
            8 => Reg::R8,
            9 => Reg::R9,
            _ => return None,
        })
    }

    fn low(self) -> u8 {
        self as u8 & 7
    }

    fn ext(self) -> bool {
        self as u8 >= 8
    }
}

/// The handler argument registers, in order (`sysv64`).
pub const ARGS: [Reg; super::ARG_REGS] = [Reg::Rdi, Reg::Rsi, Reg::Rdx, Reg::Rcx, Reg::R8, Reg::R9];

/// The island argument registers (`fp`, `ops`): the Rust ABI, `sysv64` or Win64.
pub const fn island_args(pe: bool) -> [Reg; 2] {
    if pe { [Reg::Rcx, Reg::Rdx] } else { [Reg::Rdi, Reg::Rsi] }
}

/// A branch condition, on the flags of the `test` before it.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cond {
    Always,
    /// `jz`: the value tested was zero (false).
    Z,
    /// `jnz`.
    Nz,
}

/// A machine-code element. Positions are byte offsets in the function.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Item {
    /// `push rbp`
    PushRbp,
    /// `sub rsp, imm` (`imm8` below 128, else `imm32`)
    SubRsp(u32),
    /// `add rsp, imm` (`imm8` below 128, else `imm32`)
    AddRsp(u32),
    /// `reg = value`, in the shortest of `xor r32, r32`, `mov r32, imm32`,
    /// `mov r64, simm32`, `mov r64, imm64`.
    SetReg(Reg, u64),
    /// `lea reg, [rip + disp32]`, the field relocated against the [`Ref`].
    Lea(Reg, Ref),
    /// `lea rcx, [rip + disp32]` of a jump table in the function, at this position.
    LeaTable(u32),
    /// `mov dst, src` (64 bits).
    Mov(Reg, Reg),
    /// `call rel32`
    Call(Ref),
    /// `call [rip + disp32]`: through a symbol slot.
    CallMem(Ref),
    /// `call rax`
    CallRax,
    /// `jmp rax`
    JmpRax,
    /// `jmp rel32` to another function (a tail call).
    Jmp(Ref),
    /// A jump within the function: `jmp`, `jz` or `jnz`, `rel8` or (`long`) `rel32`.
    Branch { cond: Cond, target: u32, long: bool },
    /// `test al, al`
    TestAl,
    /// `test rax, rax`
    TestRax,
    /// `leave`
    Leave,
    /// `ret`
    Ret,
    /// `ud2`
    Ud2,
    /// `nop dword [rcx + d]`: the call marker, carrying the destination slot `d`.
    Marker(i32),
    /// `movsxd rax, [rcx + rax*4]`
    LoadTableEntry,
    /// `add rax, rcx`
    AddRaxRcx,
    /// A padding `nop` of 1 to 9 bytes.
    Nop(u8),
    /// `int3`: padding before a jump table.
    Int3,
    /// A jump table entry: the offset of `target` from the table start `base`.
    TableEntry { base: u32, target: u32 },
}

/// The standard multi-byte `nop`s (Intel SDM), by length.
const NOPS: [&[u8]; 10] = [
    &[],
    &[0x90],
    &[0x66, 0x90],
    &[0x0f, 0x1f, 0x00],
    &[0x0f, 0x1f, 0x40, 0x00],
    &[0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x44, 0x00, 0x00],
    &[0x0f, 0x1f, 0x80, 0x00, 0x00, 0x00, 0x00],
    &[0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
    &[0x66, 0x0f, 0x1f, 0x84, 0x00, 0x00, 0x00, 0x00, 0x00],
];

/// The padding items for `n` bytes: 9-byte `nop`s, then the remainder.
pub fn padding(n: u32, out: &mut Vec<Item>) {
    for _ in 0..n / 9 {
        out.push(Item::Nop(9));
    }
    if n % 9 != 0 {
        out.push(Item::Nop((n % 9) as u8));
    }
}

/// The shortest form of `reg = v`: 0 `xor`, 1 `mov r32`, 2 `mov r64, simm32`, 3 `movabs`.
fn set_form(v: u64) -> u8 {
    if v == 0 {
        0
    } else if v <= u32::MAX as u64 {
        1
    } else if v as i64 >= i32::MIN as i64 && v as i64 <= i32::MAX as i64 {
        2
    } else {
        3
    }
}

impl Item {
    /// The encoded length.
    pub fn len(&self) -> u32 {
        match *self {
            Item::PushRbp | Item::Leave | Item::Ret | Item::Int3 => 1,
            Item::TestAl | Item::CallRax | Item::JmpRax | Item::Ud2 => 2,
            Item::TestRax | Item::Mov(..) | Item::AddRaxRcx => 3,
            Item::LoadTableEntry | Item::TableEntry { .. } => 4,
            Item::SubRsp(v) | Item::AddRsp(v) => {
                if v < 128 {
                    4
                } else {
                    7
                }
            }
            Item::SetReg(r, v) => {
                let rex = r.ext() as u32;
                match set_form(v) {
                    0 => 2 + rex,
                    1 => 5 + rex,
                    2 => 7,
                    _ => 10,
                }
            }
            Item::Lea(..) | Item::LeaTable(_) | Item::Marker(_) => 7,
            Item::Call(_) | Item::Jmp(_) => 5,
            Item::CallMem(_) => 6,
            Item::Branch { cond, long, .. } => match (cond, long) {
                (_, false) => 2,
                (Cond::Always, true) => 5,
                (Cond::Z | Cond::Nz, true) => 6,
            },
            Item::Nop(n) => n as u32,
        }
    }

    /// Appends the item at position `pos`, and its relocation if it has one.
    pub fn write(&self, pos: u32, out: &mut Vec<u8>, relocs: &mut Vec<Reloc>) {
        let start = out.len();
        let rel32 = |out: &mut Vec<u8>, target: u32| {
            let end = pos + (out.len() - start) as u32 + 4;
            out.extend_from_slice(&(target.wrapping_sub(end) as i32).to_le_bytes());
        };
        let reloc = |out: &mut Vec<u8>, relocs: &mut Vec<Reloc>, to: Ref| {
            relocs.push(Reloc { at: pos + (out.len() - start) as u32, to });
            out.extend_from_slice(&[0; 4]);
        };
        match *self {
            Item::PushRbp => out.push(0x55),
            Item::SubRsp(v) | Item::AddRsp(v) => {
                let ext = if matches!(self, Item::SubRsp(_)) { 0xec } else { 0xc4 };
                if v < 128 {
                    out.extend_from_slice(&[0x48, 0x83, ext, v as u8]);
                } else {
                    out.extend_from_slice(&[0x48, 0x81, ext]);
                    out.extend_from_slice(&v.to_le_bytes());
                }
            }
            Item::SetReg(r, v) => match set_form(v) {
                0 => {
                    if r.ext() {
                        out.push(0x45);
                    }
                    out.extend_from_slice(&[0x31, 0xc0 | r.low() << 3 | r.low()]);
                }
                1 => {
                    if r.ext() {
                        out.push(0x41);
                    }
                    out.push(0xb8 | r.low());
                    out.extend_from_slice(&(v as u32).to_le_bytes());
                }
                2 => {
                    out.extend_from_slice(&[0x48 | r.ext() as u8, 0xc7, 0xc0 | r.low()]);
                    out.extend_from_slice(&(v as u32).to_le_bytes());
                }
                _ => {
                    out.extend_from_slice(&[0x48 | r.ext() as u8, 0xb8 | r.low()]);
                    out.extend_from_slice(&v.to_le_bytes());
                }
            },
            Item::Lea(r, to) => {
                out.extend_from_slice(&[0x48 | (r.ext() as u8) << 2, 0x8d, 0x05 | r.low() << 3]);
                reloc(out, relocs, to);
            }
            Item::LeaTable(t) => {
                out.extend_from_slice(&[0x48, 0x8d, 0x0d]);
                rel32(out, t);
            }
            Item::Mov(dst, src) => {
                out.extend_from_slice(&[0x48 | (src.ext() as u8) << 2 | dst.ext() as u8, 0x89, 0xc0 | src.low() << 3 | dst.low()])
            }
            Item::Call(to) => {
                out.push(0xe8);
                reloc(out, relocs, to);
            }
            Item::CallMem(to) => {
                out.extend_from_slice(&[0xff, 0x15]);
                reloc(out, relocs, to);
            }
            Item::CallRax => out.extend_from_slice(&[0xff, 0xd0]),
            Item::JmpRax => out.extend_from_slice(&[0xff, 0xe0]),
            Item::Jmp(to) => {
                out.push(0xe9);
                reloc(out, relocs, to);
            }
            Item::Branch { cond, target, long } => {
                if long {
                    match cond {
                        Cond::Always => out.push(0xe9),
                        Cond::Z => out.extend_from_slice(&[0x0f, 0x84]),
                        Cond::Nz => out.extend_from_slice(&[0x0f, 0x85]),
                    }
                    rel32(out, target);
                } else {
                    out.push(match cond {
                        Cond::Always => 0xeb,
                        Cond::Z => 0x74,
                        Cond::Nz => 0x75,
                    });
                    let d = target.wrapping_sub(pos + 2) as i32;
                    debug_assert!(i8::try_from(d).is_ok(), "short branch out of range");
                    out.push(d as i8 as u8);
                }
            }
            Item::TestAl => out.extend_from_slice(&[0x84, 0xc0]),
            Item::TestRax => out.extend_from_slice(&[0x48, 0x85, 0xc0]),
            Item::Leave => out.push(0xc9),
            Item::Ret => out.push(0xc3),
            Item::Ud2 => out.extend_from_slice(&[0x0f, 0x0b]),
            Item::Marker(d) => {
                out.extend_from_slice(&super::CALL_MARKER);
                out.extend_from_slice(&d.to_le_bytes());
            }
            Item::LoadTableEntry => out.extend_from_slice(&[0x48, 0x63, 0x04, 0x81]),
            Item::AddRaxRcx => out.extend_from_slice(&[0x48, 0x01, 0xc8]),
            Item::Nop(n) => out.extend_from_slice(NOPS[n as usize]),
            Item::Int3 => out.push(0xcc),
            Item::TableEntry { base, target } => out.extend_from_slice(&(target.wrapping_sub(base) as i32).to_le_bytes()),
        }
        debug_assert_eq!(out.len() - start, self.len() as usize, "{self:?}");
    }
}

/// A function's code being read: the bytes, the position, and the relocations (sorted by
/// field position).
pub struct Cursor<'a> {
    pub code: &'a [u8],
    pub pos: u32,
    relocs: &'a [Reloc],
}

/// The code at the cursor isn't a canonical element.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct BadItem(pub u32);

impl<'a> Cursor<'a> {
    pub fn new(code: &'a [u8], relocs: &'a [Reloc]) -> Self {
        Cursor { code, pos: 0, relocs }
    }

    pub fn at_end(&self) -> bool {
        self.pos as usize >= self.code.len()
    }

    fn bytes(&self, n: usize) -> Result<&'a [u8], BadItem> {
        self.code.get(self.pos as usize..).and_then(|b| b.get(..n)).ok_or(BadItem(self.pos))
    }

    fn reloc(&self, at: u32) -> Option<Ref> {
        self.relocs.binary_search_by_key(&at, |r| r.at).ok().map(|i| self.relocs[i].to)
    }

    fn i32_at(&self, off: usize) -> Result<i32, BadItem> {
        let b = self.bytes(off + 4)?;
        Ok(i32::from_le_bytes([b[off], b[off + 1], b[off + 2], b[off + 3]]))
    }

    /// The relocation of the 4-byte field `off` bytes into the item.
    fn field_ref(&self, off: u32) -> Result<Ref, BadItem> {
        self.reloc(self.pos + off).ok_or(BadItem(self.pos))
    }

    /// The target of the PC-relative field `off` bytes into an item of length `len`, which
    /// must not be relocated.
    fn local(&self, off: u32, len: u32) -> Result<u32, BadItem> {
        if self.reloc(self.pos + off).is_some() {
            return Err(BadItem(self.pos));
        }
        Ok((self.pos + len).wrapping_add(self.i32_at(off as usize)? as u32))
    }

    /// Reads the next element (not padding, `int3` or a table entry), and checks that its
    /// encoding is canonical.
    pub fn item(&mut self) -> Result<Item, BadItem> {
        let bad = BadItem(self.pos);
        let b = self.bytes(1)?;
        let all = &self.code[self.pos as usize..];
        let get = |i: usize| all.get(i).copied().ok_or(bad);
        // An optional REX prefix (0x40..=0x4f), then the opcode.
        let (rex, at) = if (0x40..=0x4f).contains(&b[0]) { (b[0], 1) } else { (0, 0) };
        let (w, r, x, bx) = (rex & 8 != 0, rex & 4 != 0, rex & 2 != 0, rex & 1 != 0);
        let op = get(at)?;
        let item = match (rex, op) {
            (0, 0x55) => Item::PushRbp,
            (0x48, 0x83 | 0x81) => {
                let ext = get(2)?;
                let (v, long) = if op == 0x83 { (get(3)? as u32, false) } else { (self.i32_at(3)? as u32, true) };
                if long != (v >= 128) || (op == 0x83 && v >= 128) {
                    return Err(bad);
                }
                match ext {
                    0xec => Item::SubRsp(v),
                    0xc4 => Item::AddRsp(v),
                    _ => return Err(bad),
                }
            }
            (0 | 0x45, 0x31) if !x => {
                let m = get(at + 1)?;
                let (rr, rm) = (m >> 3 & 7, m & 7);
                if m >> 6 != 3 || rr != rm || r != bx {
                    return Err(bad);
                }
                let reg = Reg::from_num(rm | (bx as u8) << 3).ok_or(bad)?;
                Item::SetReg(reg, 0)
            }
            (0 | 0x41, 0xb8..=0xbf) => {
                let reg = Reg::from_num(op & 7 | (bx as u8) << 3).ok_or(bad)?;
                let v = self.i32_at(at + 1)? as u32 as u64;
                if set_form(v) != 1 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x49, 0xc7) => {
                let m = get(2)?;
                if m & 0xf8 != 0xc0 {
                    return Err(bad);
                }
                let reg = Reg::from_num(m & 7 | (bx as u8) << 3).ok_or(bad)?;
                let v = self.i32_at(3)? as i64 as u64;
                if set_form(v) != 2 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x49, 0xb8..=0xbf) => {
                let reg = Reg::from_num(op & 7 | (bx as u8) << 3).ok_or(bad)?;
                let b = self.bytes(10)?;
                let v = u64::from_le_bytes(b[2..10].try_into().unwrap());
                if set_form(v) != 3 {
                    return Err(bad);
                }
                Item::SetReg(reg, v)
            }
            (0x48 | 0x4c, 0x8d) if w && !x && !bx => {
                let m = get(2)?;
                if m & 0xc7 != 0x05 {
                    return Err(bad);
                }
                let reg = Reg::from_num(m >> 3 & 7 | (r as u8) << 3).ok_or(bad)?;
                match self.reloc(self.pos + 3) {
                    Some(to) => Item::Lea(reg, to),
                    None if reg == Reg::Rcx => Item::LeaTable(self.local(3, 7)?),
                    None => return Err(bad),
                }
            }
            (0x48..=0x4f, 0x89) if w && !x => {
                let m = get(2)?;
                if m >> 6 != 3 {
                    return Err(bad);
                }
                let src = Reg::from_num(m >> 3 & 7 | (r as u8) << 3).ok_or(bad)?;
                let dst = Reg::from_num(m & 7 | (bx as u8) << 3).ok_or(bad)?;
                Item::Mov(dst, src)
            }
            (0, 0xe8) => Item::Call(self.field_ref(1)?),
            (0, 0xff) => match get(1)? {
                0x15 => Item::CallMem(self.field_ref(2)?),
                0xd0 => Item::CallRax,
                0xe0 => Item::JmpRax,
                _ => return Err(bad),
            },
            (0, 0xe9) => match self.reloc(self.pos + 1) {
                Some(to) => Item::Jmp(to),
                None => Item::Branch { cond: Cond::Always, target: self.local(1, 5)?, long: true },
            },
            (0, 0xeb | 0x74 | 0x75) => {
                let d = get(1)? as i8 as i32 as u32;
                let cond = match op {
                    0xeb => Cond::Always,
                    0x74 => Cond::Z,
                    _ => Cond::Nz,
                };
                Item::Branch { cond, target: (self.pos + 2).wrapping_add(d), long: false }
            }
            (0, 0x0f) => match get(1)? {
                0x84 => Item::Branch { cond: Cond::Z, target: self.local(2, 6)?, long: true },
                0x85 => Item::Branch { cond: Cond::Nz, target: self.local(2, 6)?, long: true },
                0x0b => Item::Ud2,
                0x1f if get(2)? == super::CALL_MARKER[2] => Item::Marker(self.i32_at(3)?),
                _ => return Err(bad),
            },
            (0, 0x84) if get(1)? == 0xc0 => Item::TestAl,
            (0x48, 0x85) if get(2)? == 0xc0 => Item::TestRax,
            (0, 0xc9) => Item::Leave,
            (0, 0xc3) => Item::Ret,
            (0x48, 0x63) if self.bytes(4)? == [0x48, 0x63, 0x04, 0x81] => Item::LoadTableEntry,
            (0x48, 0x01) if get(2)? == 0xc8 => Item::AddRaxRcx,
            _ => return Err(bad),
        };
        // A relocation must be the item's own field.
        let len = item.len();
        let own = match item {
            Item::Lea(..) => Some(3),
            Item::Call(_) | Item::Jmp(_) => Some(1),
            Item::CallMem(_) => Some(2),
            _ => None,
        };
        if self.relocs_in(self.pos, len).iter().any(|rl| Some(rl.at - self.pos) != own) {
            return Err(bad);
        }
        self.bytes(len as usize)?;
        self.pos += len;
        Ok(item)
    }

    /// Reads padding: 9-byte `nop`s, then at most one shorter one. Returns its length.
    pub fn padding(&mut self) -> u32 {
        let start = self.pos;
        loop {
            let rest = &self.code[self.pos as usize..];
            let Some(n) = (1..NOPS.len()).rev().find(|&n| rest.starts_with(NOPS[n])) else { break };
            if self.reloc_in(self.pos, n as u32) {
                break;
            }
            self.pos += n as u32;
            if n != 9 {
                break;
            }
        }
        self.pos - start
    }

    /// The relocations of the fields starting in `at..at + len`.
    fn relocs_in(&self, at: u32, len: u32) -> &'a [Reloc] {
        let lo = self.relocs.partition_point(|r| r.at < at);
        let hi = self.relocs.partition_point(|r| r.at < at + len);
        &self.relocs[lo..hi]
    }

    fn reloc_in(&self, at: u32, len: u32) -> bool {
        !self.relocs_in(at, len).is_empty()
    }

    /// Reads `int3`s up to a multiple of 4.
    pub fn table_padding(&mut self) -> Result<(), BadItem> {
        while self.pos % 4 != 0 {
            if self.bytes(1)? != [0xcc] {
                return Err(BadItem(self.pos));
            }
            self.pos += 1;
        }
        Ok(())
    }

    /// Reads a jump table entry, relative to the table start `base`: its target.
    pub fn table_entry(&mut self, base: u32) -> Result<u32, BadItem> {
        if self.reloc_in(self.pos, 4) {
            return Err(BadItem(self.pos));
        }
        let t = base.wrapping_add(self.i32_at(0)? as u32);
        self.pos += 4;
        Ok(t)
    }
}
