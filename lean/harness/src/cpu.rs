//! Running item bytes on the CPU: an RWX mapping holding a trampoline, the code under test,
//! landing pads, and a data region its memory operands and stack point into.
//!
//! Layout of the mapping (`map`):
//!
//! - `ENTRY`: the trampoline. It saves the host's callee-saved registers and `rsp` in the state
//!   block, loads `xmm0`–`xmm15`, the flags (`popfq`) and all 16 GPRs (`rsp` too) from the block,
//!   and jumps (`jmp [rip + slot]`, which touches no register or flag) to the code under test.
//! - `FUNC`: the function the items belong to (`Ctx.base`); the items sit at `FUNC + POS`.
//! - landing pads: 5-byte `jmp rel32`s to exit `k`, one after the items (fall-through) and one
//!   at each other address control may reach (branch and call targets, return addresses...).
//! - `EXITS`: exit `k` stores all GPRs (the first with `mov [moffs64], rax`), the `xmm`s, then
//!   switches to the host stack and stores the flags (`pushfq`) and `k`, and returns to Rust.
//! - `DATA`: `DATA_LEN` bytes the test's memory accesses stay in; compared afterwards.

use std::arch::asm;

pub const MAP_LEN: usize = 0x11000;
pub const ENTRY: usize = 0;
pub const SLOT: usize = 0xf00;
pub const FUNC: usize = 0x1000;
pub const FUNC_LEN: usize = 0x1000;
pub const POS: usize = 0x400;
pub const EXITS: usize = 0x8000;
pub const EXIT_LEN: usize = 0x200;
pub const MAX_PADS: usize = 8;
pub const DATA: usize = 0x10000;
pub const DATA_LEN: usize = 1024;

/// The state block the trampoline reads and writes.
#[repr(C)]
#[derive(Clone, Copy)]
pub struct Block {
    pub regs: [u64; 16],
    pub rflags: u64,
    host_rsp: u64,
    exit: u64,
    _pad: u64,
    pub xmm: [u128; 16],
}

const OFF_RFLAGS: i32 = 128;
const OFF_HOST_RSP: i32 = 136;
const OFF_EXIT: i32 = 144;
const OFF_XMM: i32 = 160;

unsafe fn syscall6(n: u64, a: [u64; 6]) -> i64 {
    let ret: i64;
    unsafe {
        asm!("syscall", inlateout("rax") n as i64 => ret, in("rdi") a[0], in("rsi") a[1], in("rdx") a[2],
             in("r10") a[3], in("r8") a[4], in("r9") a[5], lateout("rcx") _, lateout("r11") _, options(nostack));
    }
    ret
}

pub struct Cpu {
    map: *mut u8,
    block: Box<Block>,
}

/// The bytes of the result of one run.
pub struct Outcome {
    pub regs: [u64; 16],
    pub rflags: u64,
    pub xmm: [u128; 16],
    pub mem: Vec<u8>,
    /// The landing pad reached.
    pub rip: u64,
}

struct Asm(Vec<u8>);

impl Asm {
    fn b(&mut self, bs: &[u8]) {
        self.0.extend_from_slice(bs);
    }
    fn d32(&mut self, v: i32) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    fn q64(&mut self, v: u64) {
        self.0.extend_from_slice(&v.to_le_bytes());
    }
    /// `mov [rax + d], reg` (`store`) or `mov reg, [rax + d]`, 64 bits.
    fn mov_rax_mem(&mut self, store: bool, reg: u8, d: i32) {
        self.b(&[0x48 | if reg >= 8 { 4 } else { 0 }, if store { 0x89 } else { 0x8b }, 0x80 | (reg & 7) << 3]);
        self.d32(d);
    }
    /// `movups [rax + d], xmm{x}` (`store`) or `movups xmm{x}, [rax + d]`.
    fn movups_rax_mem(&mut self, store: bool, x: u8, d: i32) {
        if x >= 8 {
            self.b(&[0x44]);
        }
        self.b(&[0x0f, if store { 0x11 } else { 0x10 }, 0x80 | (x & 7) << 3]);
        self.d32(d);
    }
}

impl Cpu {
    pub fn new() -> Cpu {
        // mmap(NULL, MAP_LEN, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
        let p = unsafe { syscall6(9, [0, MAP_LEN as u64, 7, 0x22, u64::MAX, 0]) };
        assert!(!(-4095..0).contains(&p), "mmap of an RWX region failed: errno {}", -p);
        let block = Box::new(Block { regs: [0; 16], rflags: 0, host_rsp: 0, exit: 0, _pad: 0, xmm: [0; 16] });
        let mut cpu = Cpu { map: p as *mut u8, block };
        cpu.write_fixed();
        cpu
    }

    pub fn addr(&self, off: usize) -> u64 {
        self.map as u64 + off as u64
    }

    fn write(&mut self, off: usize, bs: &[u8]) {
        assert!(off + bs.len() <= MAP_LEN);
        unsafe { std::ptr::copy_nonoverlapping(bs.as_ptr(), self.map.add(off), bs.len()) };
    }

    fn read(&self, off: usize, n: usize) -> Vec<u8> {
        unsafe { std::slice::from_raw_parts(self.map.add(off), n) }.to_vec()
    }

    /// The trampoline and the exits.
    fn write_fixed(&mut self) {
        let block = &*self.block as *const Block as u64;
        let mut a = Asm(Vec::new());
        // push rbx; push rbp; push r12; push r13; push r14; push r15
        a.b(&[0x53, 0x55, 0x41, 0x54, 0x41, 0x55, 0x41, 0x56, 0x41, 0x57]);
        a.b(&[0x48, 0xb8]); // mov rax, block
        a.q64(block);
        a.mov_rax_mem(true, 4, OFF_HOST_RSP); // mov [rax + host_rsp], rsp
        for x in 0..16 {
            a.movups_rax_mem(false, x, OFF_XMM + 16 * x as i32);
        }
        a.b(&[0xff, 0xb0]); // push qword [rax + rflags]
        a.d32(OFF_RFLAGS);
        a.b(&[0x9d]); // popfq
        for r in 1..16 {
            a.mov_rax_mem(false, r, 8 * r as i32);
        }
        a.mov_rax_mem(false, 0, 0);
        a.b(&[0xff, 0x25]); // jmp [rip + slot]
        let end = ENTRY + a.0.len() + 4;
        a.d32((SLOT as i64 - end as i64) as i32);
        assert!(ENTRY + a.0.len() <= SLOT);
        let entry = a.0;
        self.write(ENTRY, &entry);

        for k in 0..MAX_PADS {
            let mut a = Asm(Vec::new());
            a.b(&[0x48, 0xa3]); // mov [block], rax
            a.q64(block);
            a.b(&[0x48, 0xb8]); // mov rax, block
            a.q64(block);
            for r in 1..16 {
                a.mov_rax_mem(true, r, 8 * r as i32);
            }
            for x in 0..16 {
                a.movups_rax_mem(true, x, OFF_XMM + 16 * x as i32);
            }
            a.mov_rax_mem(false, 4, OFF_HOST_RSP); // mov rsp, [rax + host_rsp]
            a.b(&[0x9c, 0x59]); // pushfq; pop rcx
            a.mov_rax_mem(true, 1, OFF_RFLAGS);
            a.b(&[0x48, 0xc7, 0x80]); // mov qword [rax + exit], k
            a.d32(OFF_EXIT);
            a.d32(k as i32);
            // pop r15; pop r14; pop r13; pop r12; pop rbp; pop rbx; cld; ret
            a.b(&[0x41, 0x5f, 0x41, 0x5e, 0x41, 0x5d, 0x41, 0x5c, 0x5d, 0x5b, 0xfc, 0xc3]);
            assert!(a.0.len() <= EXIT_LEN);
            let code = a.0;
            self.write(EXITS + k * EXIT_LEN, &code);
        }
    }

    /// Runs `code` placed at `FUNC + POS` from the given state, with landing pads at the
    /// fall-through and at `pads` (absolute addresses). `Err` if the layout doesn't fit (pads
    /// overlapping the code or each other).
    pub fn run(&mut self, code: &[u8], pads: &[u64], regs: [u64; 16], rflags: u64, xmm: [u128; 16], mem: &[u8]) -> Result<Outcome, String> {
        let at = FUNC + POS;
        let mut all = vec![self.addr(at + code.len())];
        for &p in pads {
            if !all.contains(&p) {
                all.push(p);
            }
        }
        if all.len() > MAX_PADS {
            return Err("too many landing pads".into());
        }
        let lo = self.addr(FUNC);
        let hi = self.addr(FUNC + FUNC_LEN);
        let item = (self.addr(at), self.addr(at + code.len()));
        for (i, &p) in all.iter().enumerate() {
            if p < lo || p + 5 > hi {
                return Err(format!("landing pad {p:#x} outside the function"));
            }
            if p < item.1 && item.0 < p + 5 {
                return Err(format!("landing pad {p:#x} overlaps the code"));
            }
            if all[..i].iter().any(|&q| p < q + 5 && q < p + 5) {
                return Err(format!("landing pad {p:#x} overlaps another"));
            }
        }
        self.write(FUNC, &[0xcc; FUNC_LEN]);
        self.write(at, code);
        for (k, &p) in all.iter().enumerate() {
            let off = (p - self.map as u64) as usize;
            let rel = (EXITS + k * EXIT_LEN) as i64 - (off + 5) as i64;
            let mut jmp = vec![0xe9];
            jmp.extend_from_slice(&(rel as i32).to_le_bytes());
            self.write(off, &jmp);
        }
        let target = self.addr(at);
        self.write(SLOT, &target.to_le_bytes());
        assert_eq!(mem.len(), DATA_LEN);
        self.write(DATA, mem);
        // Through a raw pointer passed to the trampoline, so the compiler sees the block escape.
        let block: *mut Block = &mut *self.block;
        unsafe {
            (*block).regs = regs;
            (*block).rflags = rflags;
            (*block).xmm = xmm;
            (*block).exit = u64::MAX;
            let entry: extern "sysv64" fn(*mut Block) = std::mem::transmute(self.map.add(ENTRY));
            entry(block);
        }
        let b = unsafe { std::ptr::read_volatile(block) };
        let exit = b.exit as usize;
        assert!(exit < all.len(), "bad exit {exit}");
        Ok(Outcome { regs: b.regs, rflags: b.rflags, xmm: b.xmm, mem: self.read(DATA, DATA_LEN), rip: all[exit] })
    }
}
