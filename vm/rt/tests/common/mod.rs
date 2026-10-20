//! Test support: a tiny assembler, an in-memory "linker" for image objects, and calls into
//! the VM through `vm::enter`.

#![allow(dead_code)]

use std::any::Any;
use std::collections::HashMap;
use std::mem::{ManuallyDrop, MaybeUninit};
use std::sync::atomic::{AtomicU64, Ordering};

pub use ryo_bytecode::Opcode;
pub use ryo_bytecode::image::*;
pub use ryo_bytecode::insn::*;
use ryo_rt::unwind::RawPayload;

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
    pub fn done(self) -> Vec<u32> {
        self.c.words
    }
}

pub fn func(code: Vec<u32>, frame_size: u32, max_outgoing: u32, arg_size: u32, ret_size: u32) -> FunctionDef {
    FunctionDef { code, frame_size, max_outgoing, arg_size, ret_size, ..Default::default() }
}

static NEXT_SCID: AtomicU64 = AtomicU64::new(0x5eed_0000_0000_0001);

/// A fresh StableCrateId whose crate hash differs from every other test image's.
pub fn unique_scid() -> u64 {
    NEXT_SCID.fetch_add(1, Ordering::Relaxed)
}

/// A linked image: both sections placed in leaked memory, relocations applied.
pub struct Linked {
    pub header: *const u8,
    pub data: *mut u8,
    pub crate_hash: u32,
    pub symbols: Vec<String>,
}

unsafe impl Sync for Linked {}
unsafe impl Send for Linked {}

fn leak_buf(bytes: &[u8], align: u64) -> *mut u8 {
    assert!(align <= 16);
    let mem: &'static mut [u128] = Vec::leak(vec![0u128; bytes.len().div_ceil(16) + 1]);
    let p = mem.as_mut_ptr().cast::<u8>();
    unsafe { std::ptr::copy_nonoverlapping(bytes.as_ptr(), p, bytes.len()) };
    p
}

/// Places the sections and applies every relocation, resolving symbols through `syms`.
pub fn link(obj: ImageObject, syms: &[(&str, usize)]) -> Linked {
    let map: HashMap<&str, usize> = syms.iter().copied().collect();
    let ro = leak_buf(&obj.rodata, obj.rodata_align);
    let data = leak_buf(&obj.data, obj.data_align);
    for r in &obj.relocs {
        let target = match r.target {
            RelocTarget::Symbol(s) => {
                let name = &obj.symbols[s.0 as usize].name;
                *map.get(name.as_str()).unwrap_or_else(|| panic!("unresolved symbol {name}")) as u64
            }
            RelocTarget::Section(Section::ReadOnly) => ro as u64,
            RelocTarget::Section(Section::Writable) => data as u64,
        };
        let base = match r.section {
            Section::ReadOnly => ro,
            Section::Writable => data,
        };
        unsafe { base.add(r.offset as usize).cast::<u64>().write_unaligned(target.wrapping_add(r.addend as u64)) };
    }
    let crate_hash = unsafe { Image::from_header(ro) }.unwrap().crate_hash();
    Linked { header: ro, data, crate_hash, symbols: obj.symbols.iter().map(|s| s.name.clone()).collect() }
}

pub fn register(images: &[&Linked]) {
    let hs: Vec<*const u8> = images.iter().map(|l| l.header).collect();
    unsafe { ryo_rt::vm::ryo_vm_register(hs.as_ptr(), hs.len()) };
}

/// Builds, links and registers an image.
pub fn build(w: ImageWriter, syms: &[(&str, usize)]) -> Linked {
    let l = link(w.finish().expect("image"), syms);
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
}

/// Calls VM function `id` with the argument block `args` through `vm::enter`.
pub fn call<A, R>(id: u64, args: A) -> Result<R, Box<dyn Any + Send>> {
    let args = ManuallyDrop::new(args);
    let mut ret = MaybeUninit::<R>::uninit();
    let mut p = RawPayload::NONE;
    let st = unsafe { ryo_rt::vm::enter(id, (&raw const args).cast(), ret.as_mut_ptr().cast(), &mut p) };
    if st == 0 {
        assert!(p.is_none());
        Ok(unsafe { ret.assume_init() })
    } else {
        assert_eq!(st, 1);
        // Re-raise and catch it, as a portal's caller would: the panic is still counted
        // (ryo_rt::unwind), and only a real catch uncounts it.
        Err(std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| unsafe { ryo_rt::unwind::resume_unwind_from_vm(p) })).unwrap_err())
    }
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
