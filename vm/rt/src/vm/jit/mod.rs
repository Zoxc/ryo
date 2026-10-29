//! The JIT (design/jit.md): recompiles hot functions on a background thread and
//! switches their entry over to the new code. This module is the runtime's side of it; the
//! JIT thread is the `ryo_jit` crate's, which sees the runtime only through the [`RtApi`]
//! that this side builds ([`ryo_bytecode::jit_abi`]), and starts with `ryo_jit_start`.
//!
//! - **Trips**: [`trip_entry`] and [`trip_osr`] are what a JIT record's `entry` and `osr`
//!   slots start at; a function's counter stub calls them when a counter of its stops being
//!   negative (design/vm.md, "JIT records and counters"). They queue the record if it is
//!   cold, bias its counters ([`JitRecord`]), and return into the AOT code; in a compiled
//!   function they continue into its JIT code instead (at a loop head through its OSR dispatcher). Lock-free: a CAS on
//!   the record's state, a push onto [`QUEUE`], and a futex wake if the JIT thread sleeps.
//!   They never compile or allocate, but the first push starts the JIT thread.
//! - **The JIT thread** takes the whole queue at once ([`next_batch`]), decodes each
//!   function from its image ([`ryo_bytecode::image::ImageResolver`]), encodes it again
//!   without counters, installs the code near the image with its unwind information, and
//!   publishes it in the record: `entry` (its [`JIT_ENTRY_PREFIX`]) and `osr` (its OSR
//!   dispatcher), then the state `Done`, then the counters' `Done` bias, so that every later
//!   call's and loop iteration's counter check takes its stub into the JIT code, a loop
//!   head's through an OSR entry that converts the AOT frame into the JIT one. It reports
//!   each record ([`done`]).
//!
//! This side uses `core` only, like the rest of the runtime (design/vm.md, "No re-entry"):
//! the settings come from the C runtime's `getenv`, and waiting is a futex (`WaitOnAddress`
//! on PE). Nothing on the trips'
//! path may unwind (the stubs aren't call sites), and nothing there does: the Rust parts
//! are `extern "C-unwind"` only so that the compiler adds no abort-on-unwind guard, which
//! would reach core's panic path (as for `ryo_vm_register`).

use core::cell::UnsafeCell;
use core::ffi::{CStr, c_char};
use core::mem::{MaybeUninit, offset_of};
use core::ptr;
use core::sync::atomic::Ordering::{AcqRel, Acquire, Relaxed, Release, SeqCst};
use core::sync::atomic::{AtomicBool, AtomicPtr, AtomicU8, AtomicU32, AtomicUsize};

use ryo_bytecode::image::{Image, JIT_BIAS, JIT_COLD, JIT_DONE, JIT_ENTRY_THRESHOLD, JIT_FAILED, JIT_QUEUED, JIT_THRESHOLD, JitRecord, jit_settle};
use ryo_bytecode::jit_abi::{JitOpt, JitSettings, RtApi};

pub use ryo_bytecode::jit_abi::JIT_ENTRY_PREFIX;

use super::sys::fatal;

mod merge;
pub(crate) use merge::forward;

/// The settings, read once from the environment (or [`configure_jit`]).
#[derive(Clone, Copy)]
struct Config {
    /// `RYO_JIT=off` turns the JIT into the no-op JIT.
    enabled: bool,
    /// `RYO_JIT_THRESHOLD`: the call and loop thresholds registration sets the counters
    /// to (default: the image's, [`JIT_ENTRY_THRESHOLD`] and [`JIT_THRESHOLD`]): `L` for
    /// `L / 16` calls and `L` loop iterations, or `E,L`.
    threshold: Option<(i64, i64)>,
    /// `RYO_JIT_SYNC=1`: a trip that queues a function waits until it is compiled (or failed)
    /// and continues in its JIT code, so threshold 0 runs every function's JIT code from its
    /// first call (tests).
    sync: bool,
    /// `RYO_JIT_SHUFFLE=1`: JIT code gets another frame layout than the AOT code's
    /// (`asm::frame::shuffle_map`), so that OSR entries convert frames (tests).
    shuffle: bool,
    /// What the JIT gets: its flags from [`FLAGS`] (`RYO_JIT_TEST_PANIC`: the JIT catches its
    /// panics even in a `-Cpanic=abort` program), `RYO_JIT_OPT`, `RYO_JIT_SSA_LIMIT` and
    /// `RYO_JIT_STATS`'s level.
    jit: JitSettings,
    /// `RYO_JIT_STATS`'s value if it isn't `0`, `1` or `2` (level 1, with a warning).
    stats_bad: Option<&'static [u8]>,
}

/// `RYO_JIT_OPT`: the SSA tier unless it names another.
fn opt() -> JitOpt {
    var(c"RYO_JIT_OPT").and_then(JitOpt::parse).unwrap_or(JitOpt::Ssa)
}

/// A `bool` field of [`Config`], by offset (an offset, not an accessor function: an indirect
/// call could unwind, which would pull core's panic path into `at_exit`). Built only by
/// [`flag!`], which checks the field's type.
#[derive(Clone, Copy)]
struct Flag(usize);

/// The [`Flag`] for `Config`'s field `$f` (a path such as `jit.check`), which must be a `bool`.
macro_rules! flag {
    ($($f:ident).+) => {{
        fn _is_bool(c: &Config) -> bool {
            c.$($f).+
        }
        Flag(offset_of!(Config, $($f).+))
    }};
}

impl Flag {
    fn get(self, cfg: &Config) -> bool {
        // SAFETY: `self.0` is a `bool` field's offset ([`flag!`]).
        unsafe { *(cfg as *const Config).cast::<u8>().add(self.0).cast::<bool>() }
    }

    fn set(self, cfg: &mut Config, v: bool) {
        // SAFETY: `self.0` is a `bool` field's offset ([`flag!`]).
        unsafe { *(cfg as *mut Config).cast::<u8>().add(self.0).cast::<bool>() = v }
    }
}

/// The boolean settings, on with `<var>=1`: the variable, the startup line's label (`None`:
/// not shown), and the field.
const FLAGS: [(&CStr, Option<&str>, Flag); 9] = [
    (c"RYO_JIT_SYNC", Some("sync"), flag!(sync)),
    (c"RYO_JIT_SHUFFLE", Some("shuffle"), flag!(shuffle)),
    (c"RYO_JIT_CHECK", Some("check"), flag!(jit.check)),
    (c"RYO_JIT_LICM", Some("licm"), flag!(jit.licm)),
    (c"RYO_JIT_ROTATE", Some("rotate"), flag!(jit.rotate)),
    (c"RYO_JIT_PERFMAP", Some("perfmap"), flag!(jit.perfmap)),
    (c"RYO_JIT_LOG", Some("log"), flag!(jit.log)),
    (c"RYO_JIT_TEST_PANIC", None, flag!(jit.test_panic)),
    (c"RYO_JIT_TEST_OOM", None, flag!(jit.test_oom)),
];

/// A static written once: [`UNINIT`], then [`BUSY`] while one thread writes it, then
/// [`READY`].
struct Once<T> {
    state: AtomicU8,
    val: UnsafeCell<MaybeUninit<T>>,
}

// SAFETY: written only by the thread that moved `state` to `BUSY`, before the release store
// of `READY`; read only after acquiring `READY`.
unsafe impl<T> Sync for Once<T> {}

const UNINIT: u8 = 0;
const BUSY: u8 = 1;
const READY: u8 = 2;

impl<T> Once<T> {
    const fn new() -> Self {
        Once { state: AtomicU8::new(UNINIT), val: UnsafeCell::new(MaybeUninit::uninit()) }
    }

    /// The value, if it is set.
    fn get(&self) -> Option<&T> {
        // SAFETY: written before `READY` was published, never again.
        (self.state.load(Acquire) == READY).then(|| unsafe { (*self.val.get()).assume_init_ref() })
    }

    /// Sets the value to `make()` unless something else set it (or is setting it) first.
    /// `None` if it did.
    fn set_with(&self, make: impl FnOnce() -> T) -> Option<&T> {
        if self.state.compare_exchange(UNINIT, BUSY, Acquire, Relaxed).is_err() {
            return None;
        }
        // SAFETY: only the thread that moved the state to `BUSY` writes, and nothing reads
        // until `READY`.
        let v = unsafe { (*self.val.get()).write(make()) };
        self.state.store(READY, Release);
        Some(v)
    }

    /// The value, set to `make()` first if nothing set it yet; waits while another thread
    /// sets it.
    fn get_or_init(&self, make: impl Fn() -> T) -> &T {
        loop {
            if let Some(v) = self.get() {
                return v;
            }
            if self.state.load(Relaxed) == UNINIT {
                self.set_with(&make);
            } else {
                core::hint::spin_loop();
            }
        }
    }
}

static CONFIG: Once<Config> = Once::new();

fn config() -> &'static Config {
    // Another thread may be reading the environment: a few `getenv`s.
    CONFIG.get_or_init(from_env)
}

/// Sets the settings to `make()` unless something else set them first. False if it did.
fn set_config(make: impl FnOnce() -> Config) -> bool {
    CONFIG.set_with(make).is_some()
}

unsafe extern "C" {
    fn getenv(name: *const c_char) -> *const c_char;
}

/// The environment variable `name`'s value, if it is set.
fn var(name: &CStr) -> Option<&'static [u8]> {
    // SAFETY: a NUL-terminated name; the value stays valid unless the program changes the
    // environment, which it may not while other threads read it (as for std's `env::var`).
    unsafe {
        let v = getenv(name.as_ptr());
        (!v.is_null()).then(|| CStr::from_ptr(v).to_bytes())
    }
}

/// A decimal `i64`, with an optional sign; `None` if it isn't one or doesn't fit.
fn parse_i64(s: &[u8]) -> Option<i64> {
    let (neg, digits) = match s {
        [b'-', rest @ ..] => (true, rest),
        [b'+', rest @ ..] => (false, rest),
        _ => (false, s),
    };
    if digits.is_empty() {
        return None;
    }
    let mut n: i64 = 0;
    for &d in digits {
        if !d.is_ascii_digit() {
            return None;
        }
        let d = (d - b'0') as i64;
        n = n.checked_mul(10)?;
        n = if neg { n.checked_sub(d)? } else { n.checked_add(d)? };
    }
    Some(n)
}

/// `RYO_JIT_STATS`'s level, and the value if it is malformed (level 1).
fn parse_stats(v: Option<&'static [u8]>) -> (u8, Option<&'static [u8]>) {
    match v {
        None | Some(b"0") => (0, None),
        Some(b"1") => (1, None),
        Some(b"2") => (2, None),
        Some(bad) => (1, Some(bad)),
    }
}

fn from_env() -> Config {
    let (stats, stats_bad) = parse_stats(var(c"RYO_JIT_STATS"));
    let mut cfg = Config {
        enabled: var(c"RYO_JIT") != Some(b"off"),
        threshold: var(c"RYO_JIT_THRESHOLD")
            .map(|s| parse_thresholds(s).unwrap_or_else(|| fatal("RYO_JIT_THRESHOLD: expected `L` or `E,L` with decimal thresholds"))),
        sync: false,
        shuffle: false,
        jit: JitSettings {
            log: false,
            perfmap: false,
            test_panic: false,
            test_oom: false,
            check: false,
            opt: opt(),
            licm: false,
            rotate: false,
            ssa_limit: var(c"RYO_JIT_SSA_LIMIT").and_then(parse_i64).and_then(|n| u64::try_from(n).ok()).unwrap_or(u64::MAX),
            stats,
            count: stats >= 1,
        },
        stats_bad,
    };
    for (name, _, flag) in FLAGS {
        flag.set(&mut cfg, var(name) == Some(b"1"));
    }
    cfg
}

/// `RYO_JIT_THRESHOLD`'s value: `L` or `E,L` ([`Config::threshold`]); `None` if malformed.
fn parse_thresholds(s: &[u8]) -> Option<(i64, i64)> {
    match s.iter().position(|&c| c == b',') {
        Some(k) => Some((limit(parse_i64(&s[..k])?), limit(parse_i64(&s[k + 1..])?))),
        None => parse_i64(s).map(thresholds_of),
    }
}

/// A threshold, clamped to what the counters hold.
fn limit(t: i64) -> i64 {
    t.clamp(0, JIT_BIAS / 4)
}

/// The thresholds of a single `L`: `L / 16` calls and `L` loop iterations.
fn thresholds_of(l: i64) -> (i64, i64) {
    (limit(l) / 16, limit(l))
}

impl Config {
    /// The call and loop thresholds.
    fn thresholds(&self) -> [i64; 2] {
        let (e, l) = self.threshold.unwrap_or((JIT_ENTRY_THRESHOLD, JIT_THRESHOLD));
        [e, l]
    }
}

/// Sets the JIT's settings instead of the environment, before anything reads them (tests):
/// on, with `sync` ([`Config::sync`]) and `threshold` (as `RYO_JIT_THRESHOLD=threshold`), no
/// perf map, shuffling or test panics or OOMs, compile timing on, and the rest from the
/// environment. False if they were read already.
#[doc(hidden)]
pub fn configure_jit(sync: bool, threshold: Option<i64>) -> bool {
    set_config(|| {
        let env = from_env();
        Config {
            enabled: true,
            threshold: threshold.map(thresholds_of),
            sync,
            shuffle: false,
            jit: JitSettings { perfmap: false, test_panic: false, test_oom: false, count: true, ..env.jit },
            stats_bad: env.stats_bad,
        }
    })
}

/// The images whose functions the JIT compiles with another frame layout, as with
/// `RYO_JIT_SHUFFLE` (tests), by header address; 0 for a free entry.
static SHUFFLED: [AtomicUsize; 256] = [const { AtomicUsize::new(0) }; 256];
/// Whether [`SHUFFLED`] has an entry: without, [`shuffled`] doesn't scan it.
static SHUFFLED_ANY: AtomicBool = AtomicBool::new(false);

/// Compiles the functions of the image with header `header` with another frame layout than
/// their AOT code's, as `RYO_JIT_SHUFFLE=1` does for all (tests).
#[doc(hidden)]
pub fn jit_shuffle_image(header: *const u8) {
    if !SHUFFLED.iter().any(|s| s.compare_exchange(0, header as usize, Relaxed, Relaxed).is_ok()) {
        fatal("jit_shuffle_image: too many images");
    }
    // Release: publishes the entry to readers that see the flag (Acquire in `shuffled`).
    SHUFFLED_ANY.store(true, Release);
}

/// [`RtApi::shuffled`]: whether the image with header `header` gets shuffled frames.
extern "C-unwind" fn shuffled(header: *const u8) -> bool {
    config().shuffle || (SHUFFLED_ANY.load(Acquire) && SHUFFLED.iter().any(|s| s.load(Relaxed) == header as usize))
}

/// [`RtApi::image_at`].
extern "C-unwind" fn image_at(addr: usize) -> *const u8 {
    super::registry::image_at(addr)
}

/// The queue of records to compile: a Treiber stack linked through [`JitRecord::next`]. Only
/// a trip that moved a record from `Cold` to `Queued` pushes it, so each record is pushed at
/// most once, and the JIT thread, the only consumer, takes the whole stack at once: no ABA.
static QUEUE: AtomicPtr<JitRecord> = AtomicPtr::new(ptr::null_mut());
/// Bumped after every push; the JIT thread sleeps on it (futex).
static WAKE: AtomicU32 = AtomicU32::new(0);
/// The JIT thread is asleep or about to be: a push must wake it.
static SLEEPING: AtomicBool = AtomicBool::new(false);
/// The first push started the JIT thread.
static STARTED: AtomicBool = AtomicBool::new(false);
/// The JIT thread couldn't be started: the trips act as the no-op JIT.
static DISABLED: AtomicBool = AtomicBool::new(false);

/// The trip of a function's entry: `r11` is its JIT record, `rsp` 16-aligned (the caller's
/// and the stub's return addresses are on it), the argument registers live. Saves them,
/// calls [`entry_trip`], restores them, and returns into the AOT code, or jumps to the JIT
/// entry [`entry_trip`] gives, which drops the stub's return address
/// ([`JIT_ENTRY_PREFIX`]). Clobbers `rax` and `r11`, which carry nothing at an entry. On PE
/// (and with `pe-test`, so PE-mode tests off Windows run the same code) it also saves
/// `xmm8`–`xmm15`, callee-saved on Win64 but not for the `sysv64` Rust code it calls (`rdi`,
/// `rsi`, `xmm6` and `xmm7` are among the argument registers it saves anyway), in a 320-byte
/// area instead of 192. On Windows its unwind info records the area and the nonvolatile
/// registers in it, so a panic in [`entry_trip`] or a stack walk passes through, and it
/// ends in epilogues the Win64 unwinder recognizes (`add rsp`, then `ret` or `rex.w jmp`),
/// so an asynchronous walk does too.
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(trip_entry)))]
pub unsafe extern "sysv64" fn trip_entry() {
    core::arch::naked_asm!(
        cfi!(".cfi_startproc"),
        seh!(".seh_proc {this}"),
        "sub rsp, {area}",
        cfi!(".cfi_adjust_cfa_offset {area}"),
        seh!(".seh_stackalloc {area}"),
        "mov [rsp], rdi",
        seh!(".seh_savereg rdi, 0"),
        "mov [rsp + 8], rsi",
        seh!(".seh_savereg rsi, 8"),
        "mov [rsp + 16], rdx",
        "mov [rsp + 24], rcx",
        "mov [rsp + 32], r8",
        "mov [rsp + 40], r9",
        "movaps [rsp + 48], xmm0",
        "movaps [rsp + 64], xmm1",
        "movaps [rsp + 80], xmm2",
        "movaps [rsp + 96], xmm3",
        "movaps [rsp + 112], xmm4",
        "movaps [rsp + 128], xmm5",
        save_xmm!(6 144, 7 160),
        #[cfg(any(windows, feature = "pe-test"))]
        save_xmm!(8 176, 9 192, 10 208, 11 224, 12 240, 13 256, 14 272, 15 288),
        seh!(".seh_endprologue"),
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        "mov rdi, [rsp]",
        "mov rsi, [rsp + 8]",
        "mov rdx, [rsp + 16]",
        "mov rcx, [rsp + 24]",
        "mov r8, [rsp + 32]",
        "mov r9, [rsp + 40]",
        "movaps xmm0, [rsp + 48]",
        "movaps xmm1, [rsp + 64]",
        "movaps xmm2, [rsp + 80]",
        "movaps xmm3, [rsp + 96]",
        "movaps xmm4, [rsp + 112]",
        "movaps xmm5, [rsp + 128]",
        restore_xmm!(6 144, 7 160),
        #[cfg(any(windows, feature = "pe-test"))]
        restore_xmm!(8 176, 9 192, 10 208, 11 224, 12 240, 13 256, 14 272, 15 288),
        // Two epilogues, each of the form the Win64 unwinder recognizes: `add rsp`, then
        // `ret` or `rex.w jmp r11`.
        "test r11, r11",
        "jz 2f",
        cfi!(".cfi_remember_state"),
        "add rsp, {area}",
        cfi!(".cfi_adjust_cfa_offset -{area}"),
        // `rex.w jmp r11`.
        ".byte 0x49, 0xff, 0xe3",
        cfi!(".cfi_restore_state"),
        "2:",
        "add rsp, {area}",
        cfi!(".cfi_adjust_cfa_offset -{area}"),
        "ret",
        cfi!(".cfi_endproc"),
        seh!(".seh_endproc"),
        area = const TRIP_ENTRY_AREA,
        trip = sym entry_trip,
        #[cfg(windows)]
        this = sym trip_entry,
    );
}
/// [`trip_entry`]'s save area.
const TRIP_ENTRY_AREA: usize = if cfg!(any(windows, feature = "pe-test")) { 320 } else { 192 };

/// The trip of a loop head: `r11` is the JIT record, `eax` the head's index, `rsp + 8`
/// 16-aligned, nothing live but `rsp` and `rbp`. A compiled function's head jumps to its OSR
/// dispatcher, in the record's `osr` slot since before it was `Done` (the stubs call it
/// directly then, so this is only for a stub that read the slot before). Else
/// [`osr_trip`], keeping `eax`, and on to the dispatcher if that compiled it (`RYO_JIT_SYNC`),
/// else back to the AOT code. On PE (and with `pe-test`) it also saves `rdi`, `rsi` and
/// `xmm6`–`xmm15`, callee-saved on Win64 (VM code preserves them for its caller) but not for
/// the `sysv64` Rust code; on Windows with unwind info, as [`trip_entry`]'s.
#[cfg(any(windows, feature = "pe-test"))]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(trip_osr)))]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        cfi!(".cfi_startproc"),
        seh!(".seh_proc {this}"),
        "cmp dword ptr [r11 + {state}], {done}",
        "jne 2f",
        "jmp qword ptr [r11 + {osr}]",
        "2:",
        // PE: `rdi`, `rsi`, then the area: the `xmm` saves and `eax` at 160.
        "push rdi",
        cfi!(".cfi_adjust_cfa_offset 8"),
        seh!(".seh_pushreg rdi"),
        "push rsi",
        cfi!(".cfi_adjust_cfa_offset 8"),
        seh!(".seh_pushreg rsi"),
        "sub rsp, 168",
        cfi!(".cfi_adjust_cfa_offset 168"),
        seh!(".seh_stackalloc 168"),
        "mov [rsp + 160], eax",
        xmm6_15!(save_xmm),
        seh!(".seh_endprologue"),
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        xmm6_15!(restore_xmm),
        "mov eax, [rsp + 160]",
        // Two epilogues, each of the form the Win64 unwinder recognizes: `add rsp`, the
        // pops, then `ret` or `rex.w jmp r11`.
        "test r11, r11",
        "jz 3f",
        cfi!(".cfi_remember_state"),
        "add rsp, 168",
        cfi!(".cfi_adjust_cfa_offset -168"),
        "pop rsi",
        cfi!(".cfi_adjust_cfa_offset -8"),
        "pop rdi",
        cfi!(".cfi_adjust_cfa_offset -8"),
        // `rex.w jmp r11`.
        ".byte 0x49, 0xff, 0xe3",
        cfi!(".cfi_restore_state"),
        "3:",
        "add rsp, 168",
        cfi!(".cfi_adjust_cfa_offset -168"),
        "pop rsi",
        cfi!(".cfi_adjust_cfa_offset -8"),
        "pop rdi",
        cfi!(".cfi_adjust_cfa_offset -8"),
        "ret",
        cfi!(".cfi_endproc"),
        seh!(".seh_endproc"),
        state = const core::mem::offset_of!(JitRecord, state),
        done = const JIT_DONE,
        osr = const core::mem::offset_of!(JitRecord, osr),
        trip = sym osr_trip,
        #[cfg(windows)]
        this = sym trip_osr,
    );
}

/// [`trip_osr`] off PE: only `eax` is saved.
#[cfg(not(any(windows, feature = "pe-test")))]
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = tagged!(ryo_bytecode::rt_sym!(trip_osr)))]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        cfi!(".cfi_startproc"),
        seh!(".seh_proc {this}"),
        "cmp dword ptr [r11 + {state}], {done}",
        "jne 2f",
        "jmp qword ptr [r11 + {osr}]",
        "2:",
        "push rax",
        cfi!(".cfi_adjust_cfa_offset 8"),
        "mov rdi, r11",
        "call {trip}",
        "mov r11, rax",
        "pop rax",
        cfi!(".cfi_adjust_cfa_offset -8"),
        "test r11, r11",
        "jz 3f",
        "jmp r11",
        "3:",
        "ret",
        cfi!(".cfi_endproc"),
        seh!(".seh_endproc"),
        state = const core::mem::offset_of!(JitRecord, state),
        done = const JIT_DONE,
        osr = const core::mem::offset_of!(JitRecord, osr),
        trip = sym osr_trip,
        #[cfg(windows)]
        this = sym trip_osr,
    );
}

/// [`trip_entry`]'s work: the JIT entry to continue at, or null to continue in AOT code.
extern "sysv64-unwind" fn entry_trip(rec: *mut JitRecord) -> *const u8 {
    if trip(rec) == JIT_DONE {
        return JitRecord::entry_slot(rec).load(Acquire);
    }
    ptr::null()
}

/// [`trip_osr`]'s work: the OSR dispatcher to continue at, or null to continue in AOT code.
extern "sysv64-unwind" fn osr_trip(rec: *mut JitRecord) -> *const u8 {
    if trip(rec) == JIT_DONE {
        return JitRecord::osr_slot(rec).load(Acquire);
    }
    ptr::null()
}

/// What both trips do: registers the record's image if its link unit's registry constructor
/// hasn't run yet ([`super::registry::ensure`]), queues the record if it is cold, and biases its counters as its
/// state says ([`settle`]): away from the trigger while it is queued, failed or without a
/// JIT, towards every check's stub once it is compiled. With [`Config::sync`], waits for a
/// queued record to be compiled. Returns the record's state.
fn trip(rec: *mut JitRecord) -> u32 {
    // Before anything else: registration sets the image's counters (`registered`), which must
    // not undo what the trip does to them.
    // SAFETY: the writer sets `header` to the record's image's header, linked and mapped
    // forever.
    unsafe { super::registry::ensure((*rec).header.cast()) };
    // Merged into another copy: the registration just pointed the record at the winner's
    // trips; the next check trips there.
    if merge::forward().is_some() {
        return JIT_COLD;
    }
    let cfg = config();
    if !cfg.enabled || DISABLED.load(Relaxed) {
        for c in [JitRecord::ctr_e(rec), JitRecord::ctr_l(rec)] {
            jit_settle(c, || JIT_FAILED);
        }
        return JIT_COLD;
    }
    let st = JitRecord::state(rec).load(Acquire);
    if st == JIT_COLD && JitRecord::state(rec).compare_exchange(JIT_COLD, JIT_QUEUED, AcqRel, Acquire).is_ok() {
        push(rec);
    }
    // With `sync`, a queued record keeps its counters unbiased, so that every thread that
    // trips meanwhile waits for the compile too, rather than running on in AOT code. Not
    // once the process exits on PE: the JIT thread is gone (`sys::exiting`), the wait would
    // never end, and the record stays queued (its code AOT).
    if cfg.sync && !super::sys::exiting() {
        while JitRecord::state(rec).load(Acquire) == JIT_QUEUED && !DISABLED.load(Acquire) {
            futex_wait(JitRecord::state(rec), JIT_QUEUED);
        }
    }
    JitRecord::settle(rec);
    JitRecord::state(rec).load(Acquire)
}

/// Pushes a record that just became `Queued`, starts the JIT thread with the first push, and
/// wakes it if it sleeps.
fn push(rec: *mut JitRecord) {
    let mut head = QUEUE.load(Relaxed);
    loop {
        // SAFETY: only this thread writes `next` of a record it moved to `Queued`, until the
        // JIT thread pops it.
        unsafe { (*rec).next = head };
        // AcqRel: Release publishes `next` and the record to the JIT thread's Acquire swap;
        // Acquire makes a failing `push`'s `DISABLED` store (before its swap, which this
        // may follow) visible to the wait in `trip`. The sleep handshake doesn't need SeqCst
        // here: a sleeper's SeqCst `WAKE` load that reads the `fetch_add` below synchronizes
        // with it, so its `QUEUE` load sees this push.
        match QUEUE.compare_exchange_weak(head, rec, AcqRel, Relaxed) {
            Ok(_) => break,
            Err(h) => head = h,
        }
    }
    if !STARTED.load(Relaxed) && !STARTED.swap(true, AcqRel) && !start() {
        // Fail everything queued so far, this record included, and wake its waiters
        // (`RYO_JIT_SYNC`). A push racing this one either precedes the swap, or its
        // pusher sees `DISABLED` before it would wait.
        DISABLED.store(true, SeqCst);
        let mut list = QUEUE.swap(ptr::null_mut(), SeqCst);
        while !list.is_null() {
            let r = list;
            // SAFETY: popped records are this thread's, as the JIT thread's.
            list = unsafe { (*r).next };
            fail(r);
            futex_wake(JitRecord::state(r), i32::MAX);
        }
        return;
    }
    WAKE.fetch_add(1, SeqCst);
    if SLEEPING.load(SeqCst) {
        futex_wake(&WAKE, 1);
    }
}

/// What the JIT gets: built by the first push, before the JIT starts.
static RT_API: Once<RtApi> = Once::new();

unsafe extern "C" {
    /// The program's personality routine, which VM code's CIEs name through a symbol slot.
    fn rust_eh_personality();
}

/// Builds [`RT_API`] and starts the JIT thread. Called once, by the first push. False if the
/// thread couldn't start.
fn start() -> bool {
    let cfg = config();
    let table = |f: fn(ryo_bytecode::Opcode) -> Option<*const ()>| -> [*const (); ryo_bytecode::Opcode::COUNT] {
        core::array::from_fn(|i| f(ryo_bytecode::ALL_OPCODES[i]).unwrap_or(ptr::null()))
    };
    let handlers = table(super::interp::handler);
    let reg_handlers = table(super::interp::reg_handler);
    #[cfg(all(feature = "pe-test", not(windows)))]
    let (pe_handlers, pe_reg_handlers) = {
        static PE: Once<[[*const (); ryo_bytecode::Opcode::COUNT]; 2]> = Once::new();
        let Some(t) = PE.set_with(|| [table(super::interp::pe_handler), table(super::interp::pe_reg_handler)]) else {
            super::sys::fatal("ryo: the JIT started twice");
        };
        (&raw const t[0], &raw const t[1])
    };
    #[cfg(not(all(feature = "pe-test", not(windows))))]
    let (pe_handlers, pe_reg_handlers) = (ptr::null(), ptr::null());
    let api = RtApi {
        settings: cfg.jit,
        thresholds: cfg.thresholds(),
        probe: super::interp::probe_stack as *const (),
        personality: rust_eh_personality as *const (),
        #[cfg(windows)]
        seh_handler: super::seh::handler as *const (),
        #[cfg(not(windows))]
        seh_handler: ptr::null(),
        next_batch,
        done,
        shuffled,
        image_at,
        handlers,
        reg_handlers,
        pe_handlers,
        pe_reg_handlers,
    };
    // The JIT thread runs this module's code (the sealed JIT) and reads its images for the
    // rest of the process: pin the module first.
    super::sys::pin_module(start as *const ());
    let Some(api) = RT_API.set_with(|| api) else { super::sys::fatal("ryo: the JIT started twice") };
    // SAFETY: the JIT reads `api` only after the start, and it lives forever.
    let report = unsafe { ryo_jit_start(api) };
    if let Some(r) = report {
        REPORT.store(r as *mut (), Release);
    }
    report.is_some()
}

unsafe extern "C" {
    /// The JIT's (`ryo_jit`, `ryo_jit_start_<tag>`): starts its thread and returns its exit report
    /// (`RYO_JIT_STATS`), or `None` if the thread can't start.
    #[link_name = tagged!("ryo_jit_start")]
    fn ryo_jit_start(rt: &'static RtApi) -> Option<extern "C" fn()>;
}

/// The JIT's exit report, once its thread started (an `extern "C" fn()`).
static REPORT: AtomicPtr<()> = AtomicPtr::new(ptr::null_mut());

/// [`RtApi::next_batch`]: the queue, in trip order, once it isn't empty (or at once without
/// `wait`).
extern "C-unwind" fn next_batch(wait: bool) -> *mut JitRecord {
    loop {
        let mut list = QUEUE.swap(ptr::null_mut(), Acquire);
        if list.is_null() {
            if !wait {
                return list;
            }
            // Re-check after announcing the sleep: a push after that wakes us (or changes
            // `WAKE`, so that the wait returns at once).
            SLEEPING.store(true, SeqCst);
            let w = WAKE.load(SeqCst);
            if QUEUE.load(SeqCst).is_null() {
                futex_wait(&WAKE, w);
            }
            SLEEPING.store(false, SeqCst);
            continue;
        }
        let mut order = ptr::null_mut();
        while !list.is_null() {
            // SAFETY: popped records are the JIT thread's until it reports them.
            unsafe {
                let next = (*list).next;
                (*list).next = order;
                order = list;
                list = next;
            }
        }
        return order;
    }
}

/// [`RtApi::done`]: fails a record that didn't compile, and wakes its waiters.
extern "C-unwind" fn done(rec: *mut JitRecord, ok: bool) {
    if !ok {
        fail(rec);
    }
    if config().sync {
        futex_wake(JitRecord::state(rec), i32::MAX);
    }
}

/// Leaves a record in AOT code for good.
fn fail(rec: *mut JitRecord) {
    JitRecord::fail(rec);
}

/// Called for every newly registered image: with `RYO_JIT_THRESHOLD`, starts its counters
/// at its thresholds, and without a JIT (`RYO_JIT=off`) biases them out of reach, as for a
/// failed record.
#[inline(never)]
pub(crate) fn registered(img: &Image<'_>) {
    // The records' slots start at this copy's trips, also for an image of another copy that
    // merged into this one (`merge`), whose slots were linked against that copy's.
    for i in 0..img.header().jit_records.count {
        let r = img.jit_record(i);
        JitRecord::entry_slot(r).store(trip_entry as *const () as *mut u8, Relaxed);
        JitRecord::osr_slot(r).store(trip_osr as *const () as *mut u8, Relaxed);
    }
    let cfg = config();
    if cfg.jit.stats != 0 && !ANNOUNCED.swap(true, Relaxed) {
        announce(cfg);
    }
    let [e, l] = cfg.thresholds();
    let bias = match (cfg.enabled, cfg.threshold) {
        (false, _) => -JIT_BIAS,
        (true, Some(_)) => 0,
        (true, None) => return,
    };
    for i in 0..img.header().jit_records.count {
        let r = img.jit_record(i);
        JitRecord::ctr_e(r).store(bias - e, Relaxed);
        JitRecord::ctr_l(r).store(bias - l, Relaxed);
    }
}

/// `RYO_JIT_STATS`: the startup line was printed (or is being printed) by the first
/// registration.
static ANNOUNCED: AtomicBool = AtomicBool::new(false);
/// The process that printed the startup line: a forked child, which has no JIT thread,
/// prints no summary.
static ANNOUNCED_PID: AtomicU32 = AtomicU32::new(0);

unsafe extern "C" {
    fn atexit(f: extern "C" fn()) -> core::ffi::c_int;
}

/// `RYO_JIT_STATS`'s start: the malformed-value warning, the startup line, and the exit
/// summary's `atexit` handler. Once, at the first registration.
#[cold]
#[inline(never)]
fn announce(cfg: &Config) {
    let pid = super::sys::pid();
    ANNOUNCED_PID.store(pid, Relaxed);
    if let Some(bad) = cfg.stats_bad {
        let mut l = Line::new();
        l.bytes(b"[ryo] warning: RYO_JIT_STATS=");
        l.bytes(bad);
        l.bytes(b": expected 0, 1 or 2; using 1\n");
        l.flush();
    }
    let mut l = Line::new();
    startup_line(cfg, pid, &mut l);
    l.flush();
    // SAFETY: registers a function that lives for the whole process.
    unsafe { atexit(at_exit) };
}

/// The startup line: whether the JIT is on, its tier, thresholds and flags, and the pid.
fn startup_line(cfg: &Config, pid: u32, l: &mut Line) {
    if !cfg.enabled {
        l.bytes(b"[ryo] jit: off (RYO_JIT=off), pid ");
        l.u64(pid as u64);
        l.bytes(b"\n");
        return;
    }
    let j = &cfg.jit;
    l.bytes(b"[ryo] jit: on, ");
    l.bytes(j.opt.name().as_bytes());
    let [e, it] = cfg.thresholds();
    l.bytes(b", thresholds ");
    l.u64(e as u64);
    l.bytes(b" calls / ");
    l.u64(it as u64);
    l.bytes(b" iterations");
    if cfg.threshold.is_some() {
        l.bytes(b" (RYO_JIT_THRESHOLD)");
    }
    for (_, label, flag) in FLAGS {
        if let Some(label) = label
            && flag.get(cfg)
        {
            l.bytes(b", ");
            l.bytes(label.as_bytes());
        }
    }
    if j.ssa_limit != u64::MAX {
        l.bytes(b", ssa-limit ");
        l.u64(j.ssa_limit);
    }
    l.bytes(b", pid ");
    l.u64(pid as u64);
    l.bytes(b"\n");
}

/// `RYO_JIT_STATS`'s exit summary: the JIT's report once its thread started, else one line
/// of why there is none. Nothing in a forked child. Takes no lock and never waits for the
/// JIT thread.
extern "C" fn at_exit() {
    if super::sys::pid() != ANNOUNCED_PID.load(Relaxed) {
        return;
    }
    let report = REPORT.load(Acquire);
    let why: &[u8] = if !config().enabled {
        b"JIT off"
    } else if !STARTED.load(Relaxed) {
        b"no function reached a threshold"
    } else if DISABLED.load(Relaxed) || report.is_null() {
        b"JIT thread failed to start"
    } else {
        // SAFETY: `ryo_jit_start`'s report, an `extern "C" fn()`.
        let report: extern "C" fn() = unsafe { core::mem::transmute(report) };
        report();
        return;
    };
    let mut l = Line::new();
    l.bytes(b"[ryo] jit stats: ");
    l.bytes(why);
    l.bytes(b"\n");
    l.flush();
}

/// A line of output built without `core::fmt` (which the runtime must not reach), in a
/// fixed buffer: too long a line is truncated. Nothing here can panic: only `get`/`get_mut`,
/// division by the constant 10, and wrapping arithmetic.
struct Line {
    buf: [u8; 256],
    len: usize,
}

impl Line {
    fn new() -> Line {
        Line { buf: [0; 256], len: 0 }
    }

    fn bytes(&mut self, s: &[u8]) {
        for &b in s {
            if let Some(slot) = self.buf.get_mut(self.len) {
                *slot = b;
                self.len = self.len.wrapping_add(1);
            }
        }
    }

    fn u64(&mut self, mut n: u64) {
        let mut d = [0u8; 20];
        let mut i = d.len();
        loop {
            // At most 20 digits: never wraps.
            i = i.wrapping_sub(1);
            if let Some(s) = d.get_mut(i) {
                *s = b'0'.wrapping_add((n % 10) as u8);
            }
            n /= 10;
            if n == 0 {
                break;
            }
        }
        self.bytes(d.get(i..).unwrap_or(&[]));
    }

    fn as_bytes(&self) -> &[u8] {
        self.buf.get(..self.len).unwrap_or(&[])
    }

    /// Writes the line to stderr with one `write`.
    fn flush(&self) {
        super::sys::write_stderr(self.as_bytes());
    }
}

#[cfg(target_os = "linux")]
mod futex {
    use core::ffi::{c_long, c_void};
    use core::ptr;
    use core::sync::atomic::AtomicU32;

    const SYS_FUTEX: c_long = 202;
    const FUTEX_WAIT_PRIVATE: i32 = 128;
    const FUTEX_WAKE_PRIVATE: i32 = 129;

    unsafe extern "C" {
        fn syscall(n: c_long, ...) -> c_long;
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a futex wait on a live atomic, without a timeout.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAIT_PRIVATE, v, ptr::null::<c_void>()) };
    }

    /// Wakes up to `n` threads waiting on `a`.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a futex wake on a live atomic.
        unsafe { syscall(SYS_FUTEX, a.as_ptr(), FUTEX_WAKE_PRIVATE, n) };
    }
}

/// Apple: `__ulock_wait`/`__ulock_wake` (libSystem; what libc++'s and std's waits use
/// before macOS 14.4's `os_sync_wait_on_address`).
#[cfg(target_vendor = "apple")]
mod futex {
    use core::ffi::{c_int, c_void};
    use core::sync::atomic::AtomicU32;

    const UL_COMPARE_AND_WAIT: u32 = 1;
    const ULF_WAKE_ALL: u32 = 0x100;
    const ULF_NO_ERRNO: u32 = 0x0100_0000;

    unsafe extern "C" {
        fn __ulock_wait(op: u32, addr: *mut c_void, value: u64, timeout_us: u32) -> c_int;
        fn __ulock_wake(op: u32, addr: *mut c_void, wake_value: u64) -> c_int;
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a wait on a live atomic of 4 bytes, compared with `v`, without a timeout.
        unsafe { __ulock_wait(UL_COMPARE_AND_WAIT | ULF_NO_ERRNO, a.as_ptr().cast(), v as u64, 0) };
    }

    /// Wakes one thread waiting on `a`, or all of them.
    pub fn wake(a: &AtomicU32, n: i32) {
        let all = if n == 1 { 0 } else { ULF_WAKE_ALL };
        // SAFETY: a wake on a live atomic.
        unsafe { __ulock_wake(UL_COMPARE_AND_WAIT | ULF_NO_ERRNO | all, a.as_ptr().cast(), 0) };
    }
}

/// PE: `WaitOnAddress`, imported as std imports it (`raw-dylib`, no import library needed).
#[cfg(windows)]
mod futex {
    use core::ffi::c_void;
    use core::sync::atomic::AtomicU32;

    #[link(name = "api-ms-win-core-synch-l1-2-0", kind = "raw-dylib")]
    unsafe extern "system" {
        fn WaitOnAddress(addr: *const c_void, compare: *const c_void, size: usize, ms: u32) -> i32;
        fn WakeByAddressSingle(addr: *const c_void);
        fn WakeByAddressAll(addr: *const c_void);
    }

    /// Sleeps while `a` holds `v` (or until a wake; spurious returns are fine).
    pub fn wait(a: &AtomicU32, v: u32) {
        // SAFETY: a wait on a live atomic of 4 bytes, compared with `v`, without a timeout.
        unsafe { WaitOnAddress(a.as_ptr().cast(), (&raw const v).cast(), 4, u32::MAX) };
    }

    /// Wakes one thread waiting on `a`, or all of them.
    pub fn wake(a: &AtomicU32, n: i32) {
        // SAFETY: a wake on a live atomic.
        unsafe { if n == 1 { WakeByAddressSingle(a.as_ptr().cast()) } else { WakeByAddressAll(a.as_ptr().cast()) } }
    }
}

use futex::{wait as futex_wait, wake as futex_wake};

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stats_values() {
        assert_eq!(parse_stats(None), (0, None));
        assert_eq!(parse_stats(Some(b"0")), (0, None));
        assert_eq!(parse_stats(Some(b"1")), (1, None));
        assert_eq!(parse_stats(Some(b"2")), (2, None));
        assert_eq!(parse_stats(Some(b"3")), (1, Some(&b"3"[..])));
        assert_eq!(parse_stats(Some(b"x")), (1, Some(&b"x"[..])));
        assert_eq!(parse_stats(Some(b"")), (1, Some(&b""[..])));
    }

    #[test]
    fn count_gate() {
        // `from_env` counts with stats on; `configure_jit` always does.
        let c = from_env();
        assert_eq!(c.jit.count, c.jit.stats >= 1);
    }

    #[test]
    fn line() {
        let mut l = Line::new();
        l.u64(0);
        l.bytes(b" ");
        l.u64(u64::MAX);
        assert_eq!(l.as_bytes(), b"0 18446744073709551615");
        let mut l = Line::new();
        for _ in 0..30 {
            l.bytes(b"0123456789");
        }
        l.u64(12345);
        assert_eq!(l.as_bytes().len(), 256);
        assert_eq!(&l.as_bytes()[250..], b"012345");
    }

    #[test]
    fn startup() {
        let jit = JitSettings {
            log: false,
            perfmap: false,
            test_panic: false,
            test_oom: false,
            check: true,
            opt: JitOpt::Ssa,
            ssa_limit: u64::MAX,
            licm: false,
            rotate: false,
            stats: 1,
            count: true,
        };
        let mut cfg = Config { enabled: true, threshold: Some((4, 64)), sync: true, shuffle: true, jit, stats_bad: None };
        let line = |cfg: &Config| {
            let mut l = Line::new();
            startup_line(cfg, 41213, &mut l);
            std::string::String::from_utf8(l.as_bytes().to_vec()).unwrap()
        };
        assert_eq!(line(&cfg), "[ryo] jit: on, ssa, thresholds 4 calls / 64 iterations (RYO_JIT_THRESHOLD), sync, shuffle, check, pid 41213\n");
        cfg.threshold = None;
        cfg.sync = false;
        cfg.shuffle = false;
        cfg.jit.check = false;
        cfg.jit.opt = JitOpt::Reencode;
        cfg.jit.ssa_limit = 7;
        let [e, l] = cfg.thresholds();
        assert_eq!(line(&cfg), std::format!("[ryo] jit: on, reencode, thresholds {e} calls / {l} iterations, ssa-limit 7, pid 41213\n"));
        cfg.enabled = false;
        assert_eq!(line(&cfg), "[ryo] jit: off (RYO_JIT=off), pid 41213\n");
    }

    #[test]
    fn thresholds() {
        assert_eq!(parse_thresholds(b"32"), Some((2, 32)));
        assert_eq!(parse_thresholds(b"2,0"), Some((2, 0)));
        assert_eq!(parse_thresholds(b"-5,+7"), Some((0, 7)));
        for bad in [&b""[..], b",", b",0", b"5,", b"x", b"1,2,3", b"1 ", b"99999999999999999999"] {
            assert_eq!(parse_thresholds(bad), None, "{:?}", core::str::from_utf8(bad));
        }
    }
}
