//! Command line flags.

/// A `--flag value` / `--flag=value` command line parser.
pub struct Flags<'a> {
    args: std::slice::Iter<'a, &'a str>,
    /// The current argument, its flag part and its unconsumed `=value` part.
    arg: &'a str,
    flag: &'a str,
    inline: Option<&'a str>,
}

impl<'a> Flags<'a> {
    pub fn new(args: &'a [&'a str]) -> Self {
        Flags { args: args.iter(), arg: "", flag: "", inline: None }
    }

    /// The next flag, erroring if the previous one was given an `=value` it doesn't take.
    pub fn next(&mut self) -> Result<Option<&'a str>, String> {
        if self.inline.is_some() {
            return Err(format!("`{}` takes no value", self.flag));
        }
        let Some(&arg) = self.args.next() else { return Ok(None) };
        (self.arg, self.flag, self.inline) = match arg.split_once('=') {
            Some((f, v)) if f.starts_with("--") => (arg, f, Some(v)),
            _ => (arg, arg, None),
        };
        Ok(Some(self.flag))
    }

    /// The current flag's value: inline or the next argument.
    pub fn value(&mut self) -> Result<&'a str, String> {
        self.inline.take().or_else(|| self.args.next().copied()).ok_or(format!("`{}` needs a value", self.flag))
    }

    /// The current flag's optional value: inline, or the next argument unless it is a flag
    /// (starts with `-`).
    pub fn optional_value(&mut self) -> Option<&'a str> {
        self.inline.take().or_else(|| {
            let next = self.args.clone().next().copied().filter(|a| !a.starts_with('-'))?;
            self.args.next();
            Some(next)
        })
    }

    /// The error for an unknown current argument.
    pub fn unexpected(&self) -> String {
        format!("unexpected argument `{}`", self.arg)
    }
}
