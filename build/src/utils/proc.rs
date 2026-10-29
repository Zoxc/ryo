//! Spawning processes.

use std::process::{Command, Stdio};

/// A command with `RUSTC_BOOTSTRAP=1`, as `y` uses for everything it spawns.
pub fn cmd(program: impl AsRef<std::ffi::OsStr>) -> Command {
    let mut cmd = Command::new(program);
    cmd.env("RUSTC_BOOTSTRAP", "1");
    cmd
}

/// `cmd` as a shell-like command line, for messages.
pub fn describe(cmd: &Command) -> String {
    let mut s = cmd.get_program().to_string_lossy().into_owned();
    for arg in cmd.get_args() {
        s.push(' ');
        s.push_str(&arg.to_string_lossy());
    }
    s
}

/// Runs `cmd`, failing if it doesn't exit successfully.
pub fn run(cmd: &mut Command) -> Result<(), String> {
    let status = cmd.status().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    if !status.success() {
        return Err(format!("`{}` failed with {status}", describe(cmd)));
    }
    Ok(())
}

/// Whether `cmd` runs and exits successfully (with its output discarded): a probe for whether
/// a tool is usable.
pub fn succeeds(cmd: &mut Command) -> bool {
    cmd.output().is_ok_and(|o| o.status.success())
}

/// What a [`capture`]d command did.
pub struct Captured {
    pub status: std::process::ExitStatus,
    pub stdout: String,
    pub stderr: String,
}

/// Runs `cmd` with its stdout and stderr captured (lossily decoded), failing only if it can't
/// be spawned.
pub fn capture(cmd: &mut Command) -> Result<Captured, String> {
    let out = cmd.output().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    Ok(Captured {
        status: out.status,
        stdout: String::from_utf8_lossy(&out.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
    })
}

/// [`capture`], failing with the output if `cmd` doesn't exit successfully.
pub fn capture_ok(cmd: &mut Command) -> Result<Captured, String> {
    let res = capture(cmd)?;
    if !res.status.success() {
        return Err(format!("`{}` failed with {}:\n{}{}", describe(cmd), res.status, res.stdout, res.stderr));
    }
    Ok(res)
}

/// Runs `cmd` with stdin closed and its stdout and stderr captured, killing it if it runs
/// longer than `limit`: then fails with what it printed so far, so a hang (a deadlock, a
/// read of stdin) fails the test instead of the CI job's timeout. The first line of an error
/// says what happened, the rest is the output.
pub fn output_timeout(cmd: &mut Command, limit: std::time::Duration) -> Result<std::process::Output, String> {
    use std::io::Read;
    let mut child = cmd
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    // The readers append to shared buffers, so what was read is there even if a descendant
    // that inherited the pipes keeps them open after the child exits.
    type Buf = std::sync::Arc<std::sync::Mutex<Vec<u8>>>;
    let pipe = |r: Option<Box<dyn Read + Send>>| {
        let buf = Buf::default();
        let b = buf.clone();
        let t = std::thread::spawn(move || {
            if let Some(mut r) = r {
                let mut chunk = [0u8; 8192];
                while let Ok(n @ 1..) = r.read(&mut chunk) {
                    b.lock().unwrap().extend_from_slice(&chunk[..n]);
                }
            }
        });
        (t, buf)
    };
    let out = pipe(child.stdout.take().map(|r| Box::new(r) as Box<dyn Read + Send>));
    let err = pipe(child.stderr.take().map(|r| Box::new(r) as Box<dyn Read + Send>));
    // Waits for both readers until `deadline`; false if a pipe is still held open then.
    let drained = |deadline: std::time::Instant| loop {
        if out.0.is_finished() && err.0.is_finished() {
            return true;
        }
        if std::time::Instant::now() >= deadline {
            return false;
        }
        std::thread::sleep(std::time::Duration::from_millis(10));
    };
    let take = |b: &Buf| std::mem::take(&mut *b.lock().unwrap());
    let start = std::time::Instant::now();
    let status = loop {
        match child.try_wait() {
            Ok(Some(status)) => break status,
            Ok(None) if start.elapsed() < limit => std::thread::sleep(std::time::Duration::from_millis(10)),
            Ok(None) => {
                // If `cmd` made the child a process group leader (`process_group(0)`), kill
                // the group, so the processes it started go too. Otherwise there is no such
                // group: the unreaped child's pid can't name another one.
                #[cfg(unix)]
                let _ = Command::new("kill").args(["-9", "--", &format!("-{}", child.id())]).stderr(Stdio::null()).status();
                let _ = child.kill();
                let _ = child.wait();
                // The pipes close with the process, unless it left descendants holding them.
                drained(std::time::Instant::now() + std::time::Duration::from_secs(1));
                return Err(format!(
                    "`{}` timed out after {}s, killed\nstdout:\n{}stderr:\n{}",
                    describe(cmd),
                    limit.as_secs(),
                    String::from_utf8_lossy(&take(&out.1)),
                    String::from_utf8_lossy(&take(&err.1))
                ));
            }
            Err(e) => return Err(format!("failed to wait for `{}`: {e}", describe(cmd))),
        }
    };
    if !drained((start + limit).max(std::time::Instant::now() + std::time::Duration::from_secs(1))) {
        return Err(format!(
            "`{}` exited ({status}) but left a process holding its stdout or stderr open\nstdout:\n{}stderr:\n{}",
            describe(cmd),
            String::from_utf8_lossy(&take(&out.1)),
            String::from_utf8_lossy(&take(&err.1))
        ));
    }
    Ok(std::process::Output { status, stdout: take(&out.1), stderr: take(&err.1) })
}

/// Runs `cmd` and returns its stdout, failing if it doesn't exit successfully.
/// Unlike [`capture_ok`], its stderr goes to y's, and its stdout must be UTF-8: for tool output
/// to parse, where diagnostics should reach the user as they come.
pub fn output(cmd: &mut Command) -> Result<String, String> {
    let out = cmd.stderr(Stdio::inherit()).output().map_err(|e| format!("failed to run `{}`: {e}", describe(cmd)))?;
    if !out.status.success() {
        return Err(format!("`{}` failed with {}", describe(cmd), out.status));
    }
    String::from_utf8(out.stdout).map_err(|_| format!("`{}`: non-UTF-8 output", describe(cmd)))
}
