// Output for the Lean differential runs (scripts/lean-diff.py): only `write` and `exit`, which
// the Lean interpreter has shims for; no std formatting or I/O (non-generic std functions
// without MIR).

#[allow(dead_code)]
mod out {
    unsafe extern "C" {
        fn write(fd: i32, buf: *const core::ffi::c_void, n: usize) -> isize;
        fn exit(code: i32) -> !;
    }

    pub fn bytes(b: &[u8]) {
        unsafe {
            write(1, b.as_ptr().cast(), b.len());
        }
    }

    pub fn str(s: &str) {
        bytes(s.as_bytes());
    }

    pub fn nl() {
        bytes(b"\n");
    }

    pub fn sp() {
        bytes(b" ");
    }

    pub fn u(mut v: u128) {
        let mut buf = [0u8; 40];
        let mut i = buf.len();
        if v == 0 {
            i -= 1;
            buf[i] = b'0';
        }
        while v > 0 {
            i -= 1;
            buf[i] = b'0' + (v % 10) as u8;
            v /= 10;
        }
        bytes(&buf[i..]);
    }

    pub fn i(v: i128) {
        if v < 0 {
            bytes(b"-");
            u((v as u128).wrapping_neg());
        } else {
            u(v as u128);
        }
    }

    pub fn hex(mut v: u128) {
        let mut buf = [0u8; 32];
        let mut i = buf.len();
        if v == 0 {
            i -= 1;
            buf[i] = b'0';
        }
        while v > 0 {
            i -= 1;
            let d = (v & 15) as u8;
            buf[i] = if d < 10 { b'0' + d } else { b'a' + d - 10 };
            v >>= 4;
        }
        bytes(b"0x");
        bytes(&buf[i..]);
    }

    pub fn b(v: bool) {
        str(if v { "true" } else { "false" });
    }

    /// Unsigned values, space-separated, then a newline.
    pub fn us(vs: &[u128]) {
        for (k, &v) in vs.iter().enumerate() {
            if k > 0 {
                sp();
            }
            u(v);
        }
        nl();
    }

    /// Signed values, space-separated, then a newline.
    pub fn is(vs: &[i128]) {
        for (k, &v) in vs.iter().enumerate() {
            if k > 0 {
                sp();
            }
            i(v);
        }
        nl();
    }

    pub fn quit(code: i32) -> ! {
        unsafe { exit(code) }
    }
}
