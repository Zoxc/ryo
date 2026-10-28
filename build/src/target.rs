//! What `y` needs to know about a target triple: its object format, OS, and the file and
//! symbol names that follow from them.

/// Whether `triple` is a Mach-O (Apple) target.
pub fn is_macho(triple: &str) -> bool {
    triple.contains("-apple-")
}

/// Whether `triple` is a COFF (windows-msvc) target.
pub fn is_coff(triple: &str) -> bool {
    triple.ends_with("-windows-msvc")
}

/// Whether `triple` is a Windows target (msvc or gnu).
pub fn is_windows(triple: &str) -> bool {
    triple.contains("-windows")
}

/// The file name of the static library `name` on `triple`, as `-l static=<name>` looks for
/// it: `<name>.lib` on COFF, `lib<name>.a` elsewhere.
pub fn static_lib_name(triple: &str, name: &str) -> String {
    if is_coff(triple) { format!("{name}.lib") } else { format!("lib{name}.a") }
}

/// The object-file name of the C symbol `name` on `triple`: Mach-O prefixes an `_`.
pub fn symbol(triple: &str, name: &str) -> String {
    if is_macho(triple) { format!("_{name}") } else { name.to_owned() }
}

/// The symbol `s` of an object for `triple` as its C or Rust name: without Mach-O's `_`.
pub fn unprefixed<'a>(triple: &str, s: &'a str) -> &'a str {
    if is_macho(triple) { s.strip_prefix('_').unwrap_or(s) } else { s }
}

#[cfg(test)]
mod tests {
    #[test]
    fn names() {
        assert_eq!(super::symbol("x86_64-apple-darwin", "ryo_jit_start"), "_ryo_jit_start");
        assert_eq!(super::symbol("x86_64-unknown-linux-gnu", "ryo_jit_start"), "ryo_jit_start");
        assert_eq!(super::unprefixed("x86_64-apple-darwin", "_main"), "main");
        assert_eq!(super::static_lib_name("x86_64-pc-windows-msvc", "ryo_jit"), "ryo_jit.lib");
        assert_eq!(super::static_lib_name("x86_64-pc-windows-gnu", "ryo_jit"), "libryo_jit.a");
        assert!(super::is_windows("x86_64-pc-windows-gnu") && !super::is_coff("x86_64-pc-windows-gnu"));
    }
}
