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
pub use ryo_bytecode::insn::*;

/// The encoding mode: the runtime's, with loop alignment on.
pub const ENC: Mode = Mode { align_loops: true, pe: false, ..ryo_rt::vm::MODE };

/// A code buffer with patchable branch targets.
#[derive(Default)]
pub struct Asm {
    pub c: CodeBuf,
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
    /// `ret s, len`, or for a value that doesn't return in registers, its copy to the start
    /// of the argument block, then `ret` of nothing, as the lowering does. Returns the
    /// position of the first instruction.
    pub fn ret(&mut self, s: Slot, len: u32) -> u32 {
        if ryo_bytecode::asm::ret_in_regs(len) {
            self.i(Insn::Ret { s, len })
        } else if len == 0 {
            self.i(Insn::Ret { s: Slot(0), len: 0 })
        } else {
            let at = self.i(Insn::Copy { d: Slot(16), s, len });
            self.i(Insn::Ret { s: Slot(0), len: 0 });
            at
        }
    }
    pub fn done(self) -> Vec<u32> {
        self.c.words
    }
}

static NEXT_NAME: AtomicU64 = AtomicU64::new(0);

/// A function definition with frame size `frame_size` (`F`: locals plus the largest outgoing
/// block, a multiple of 16), named `f<n>`.
pub fn func(code: Vec<u32>, frame_size: u32, arg_size: u32, ret_size: u32) -> FunctionDef {
    assert_eq!(frame_size % 16, 0, "frames are 16-aligned");
    let name = format!("f{}", NEXT_NAME.fetch_add(1, Ordering::Relaxed));
    FunctionDef { name, code, frame_size, arg_size, ret_size, ..Default::default() }
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

impl Linked {
    pub fn id(&self, f: Func) -> u64 {
        portal_id(self.crate_hash, f.0)
    }
    /// Site cache slot `s`.
    pub fn site(&self, s: Site) -> usize {
        unsafe { self.data.cast::<usize>().add(s.0 as usize).read() }
    }
    /// The machine code of function `f`.
    pub fn code(&self, f: Func) -> *const u8 {
        unsafe { self.text.add(self.functions[f.0 as usize].start as usize) }
    }
}

/// Calls VM function `id` with the argument block `args` through `vm::enter`, catching a
/// panic that unwinds out of it.
pub fn call<A, R>(id: u64, args: A) -> Result<R, Box<dyn Any + Send>> {
    let args = ManuallyDrop::new(args);
    let mut ret = MaybeUninit::<R>::uninit();
    std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| unsafe {
        ryo_rt::vm::enter(id, (&raw const args).cast(), ret.as_mut_ptr().cast())
    }))?;
    Ok(unsafe { ret.assume_init() })
}

pub fn ok<A, R>(id: u64, args: A) -> R {
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
