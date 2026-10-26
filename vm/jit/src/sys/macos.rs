//! macOS (x86_64, natively or under Rosetta): libunwind's `__register_frame`, which takes one
//! FDE, not a whole `.eh_frame` as libgcc's does.
//!
//! Not enabled ([`SUPPORTED`] is false): the backend writes no Mach-O, so there are no VM
//! images on macOS and nothing for the JIT to compile. The parts below are what it needs once
//! there are; they compile on `x86_64-apple-darwin`, and the FDE handling is tested on Linux.
//!
//! What libunwind makes of [`Unwind::eh`] (`UnwindLevel1-gcc-ext.c`, `DwarfParser.hpp`):
//! `__register_frame(fde)` decodes the FDE, finds its CIE through the FDE's CIE pointer (the
//! CIE sits before it in the same buffer), and adds `pc_begin..pc_begin + len` to
//! `DwarfFDECache`, which the unwinder searches for code no loaded image covers. A CIE
//! passed in its place fails to decode and is only logged, so each FDE is registered by
//! itself. The CIE's `zPLR` augmentation is parsed as libgcc parses it: the personality
//! `pcrel | sdata4 | indirect` (read through the slot), LSDA and FDE pointers `pcrel |
//! sdata4`; an LSDA field of 0 (the OSR code's) means none, as libunwind tests the value
//! before applying `pcrel`.
//!
//! `DwarfFDECache` is static arrays (grown with `malloc`) under a `pthread_rwlock`, with no
//! destructor: nothing is torn down at exit, unlike libgcc's b-tree. The common
//! `FRAMES_OPEN` lock is kept anyway; it costs nothing.

use core::ffi::{c_int, c_void};

use super::Unwind;

pub(crate) const SUPPORTED: bool = false;

unsafe extern "C" {
    fn write(fd: c_int, buf: *const c_void, n: usize) -> isize;
    /// Registers one FDE (libunwind; libSystem's `libunwind.dylib`).
    fn __register_frame(fde: *const u8);
}

/// The FDEs of `u` to pass to `__register_frame`, one at a time.
fn fdes<'a>(u: &'a Unwind<'_>) -> impl Iterator<Item = *const u8> + 'a {
    u.fdes.iter().map(|&off| {
        // SAFETY: `off` is within `eh`, as `Unwind` promises.
        let p = unsafe { u.eh.add(off) };
        // An FDE's second word is its CIE pointer, never 0 (a CIE's id).
        debug_assert!(unsafe { p.add(4).cast::<u32>().read_unaligned() } != 0, "not an FDE");
        p
    })
}

pub(super) unsafe fn register(u: &Unwind<'_>) -> bool {
    for fde in fdes(u) {
        // SAFETY: the caller's: an FDE of `eh`, whose CIE precedes it, living forever.
        unsafe { __register_frame(fde) };
    }
    true
}

/// Writes `b` to stderr, straight to the file descriptor.
pub(crate) fn write_stderr(b: &[u8]) {
    // SAFETY: a write of a live buffer.
    unsafe { write(2, b.as_ptr().cast(), b.len()) };
}

/// Where profilers look for the process's JIT symbols: there is no `perf` on macOS, but
/// samply reads the same file, and it is only written with `RYO_JIT_PERFMAP=1`.
pub(crate) fn perfmap_path() -> Option<std::string::String> {
    Some(std::format!("/tmp/perf-{}.map", std::process::id()))
}

#[cfg(test)]
mod tests {
    use ryo_bytecode::image::{eh_cie, eh_fde_rows};

    use super::{Unwind, fdes};

    /// The layout `install` builds: the CIE, the body's FDE, the OSR code's, the terminator.
    #[test]
    fn registers_each_fde_not_the_cie() {
        let mut eh = Vec::new();
        eh_cie(&mut eh);
        let mut offs = vec![eh.len()];
        eh_fde_rows(&mut eh, 0, 64, &[(4, vec![0x0e, 16])]);
        offs.push(eh.len());
        eh_fde_rows(&mut eh, 0, 32, &[]);
        eh.extend_from_slice(&[0; 4]);
        let u = Unwind { eh: eh.as_ptr(), fdes: &offs, code: (0, 96), pdata: (core::ptr::null(), 0) };
        let got: Vec<usize> = fdes(&u).map(|p| p as usize - eh.as_ptr() as usize).collect();
        assert_eq!(got, offs);
        for &o in &offs {
            let w = |at: usize| u32::from_le_bytes(eh[at..at + 4].try_into().unwrap()) as usize;
            // Its CIE pointer leads back to the CIE at 0, whose id is 0.
            assert_eq!(o + 4 - w(o + 4), 0);
            assert_eq!(w(4), 0);
            // Its length stays inside the buffer, before the terminator.
            assert!(o + 4 + w(o) <= eh.len() - 4);
        }
    }
}
