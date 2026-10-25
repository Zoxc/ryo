//! The JIT's trip entry points (design/vm.md, "JIT records and counters"): what a JIT
//! record's `entry` and `osr` slots start at. A function's counter stub calls them when a
//! counter of its stops being negative, with `r11` the record, `eax` a loop head's index
//! (`osr`), and the return address the continuation in the stub, which jumps back after the
//! counter check.
//!
//! This is the no-op JIT, for builds without the `jit` feature (targets `y build` has no JIT
//! for, and `vm/`'s tests without it): it biases the counter that tripped as a failed
//! record's (`-JIT_BIAS`), so that the function doesn't trip again in practice, and returns.
//! It clobbers only `rax` (and the flags), which the counter checks may: at the entry `rax`
//! holds no argument (VM functions aren't variadic, so nothing passes `al`), and at a loop
//! head nothing but `rsp` and `rbp` is live. The store races with other threads' counting,
//! harmlessly: a lost store trips again later.

/// The trip of a function's entry: `r11` is its JIT record.
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_entry")]
pub unsafe extern "sysv64" fn trip_entry() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "mov rax, {failed}",
        "mov qword ptr [r11], rax",
        "ret",
        ".cfi_endproc",
        failed = const -ryo_bytecode::image::JIT_BIAS,
    );
}

/// The trip of a loop head: `r11` is the JIT record, `eax` the head's index.
#[unsafe(naked)]
#[rustc_std_internal_symbol]
#[unsafe(export_name = "ryo_jit_trip_osr")]
pub unsafe extern "sysv64" fn trip_osr() {
    core::arch::naked_asm!(
        ".cfi_startproc",
        "mov rax, {failed}",
        "mov qword ptr [r11 + {ctr_l}], rax",
        "ret",
        ".cfi_endproc",
        failed = const -ryo_bytecode::image::JIT_BIAS,
        ctr_l = const ryo_bytecode::image::JIT_LOOP_CTR,
    );
}

/// Called for every newly registered image: nothing to do without a JIT.
pub(crate) fn registered(_: &ryo_bytecode::image::Image<'_>) {}
