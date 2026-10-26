//! A minimal JSON value and writer, for the Lean dumps (`RYO_DUMP_LEAN`): the backend has no
//! serde.

use std::fmt::Write as _;
use std::rc::Rc;

/// A JSON value. `Raw` is already serialized (memoized types).
pub(super) enum J {
    Null,
    Bool(bool),
    Num(String),
    Str(String),
    Arr(Vec<J>),
    Obj(Vec<(&'static str, J)>),
    Raw(Rc<str>),
}

impl J {
    pub(super) fn write(&self, out: &mut String) {
        match self {
            J::Null => out.push_str("null"),
            J::Bool(b) => out.push_str(if *b { "true" } else { "false" }),
            J::Num(n) => out.push_str(n),
            J::Str(s) => write_str(out, s),
            J::Arr(xs) => {
                out.push('[');
                for (i, x) in xs.iter().enumerate() {
                    if i > 0 {
                        out.push(',');
                    }
                    x.write(out);
                }
                out.push(']');
            }
            J::Obj(fs) => {
                out.push('{');
                for (i, (k, v)) in fs.iter().enumerate() {
                    if i > 0 {
                        out.push(',');
                    }
                    write_str(out, k);
                    out.push(':');
                    v.write(out);
                }
                out.push('}');
            }
            J::Raw(s) => out.push_str(s),
        }
    }

    pub(super) fn to_raw(&self) -> Rc<str> {
        let mut s = String::new();
        self.write(&mut s);
        s.into()
    }
}

pub(super) fn write_str(out: &mut String, s: &str) {
    out.push('"');
    for c in s.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => {
                let _ = write!(out, "\\u{:04x}", c as u32);
            }
            c => out.push(c),
        }
    }
    out.push('"');
}

pub(super) fn num(n: impl std::fmt::Display) -> J {
    J::Num(n.to_string())
}

pub(super) fn obj(fields: Vec<(&'static str, J)>) -> J {
    J::Obj(fields)
}

/// A constructor with arguments: `{"ctor": {"arg": ..}}` (Lean's derived encoding).
pub(super) fn ctor(name: &'static str, args: Vec<(&'static str, J)>) -> J {
    J::Obj(vec![(name, J::Obj(args))])
}

/// A constructor without arguments: `"ctor"`.
pub(super) fn tag(name: &str) -> J {
    J::Str(name.to_owned())
}

pub(super) fn opt(o: Option<J>) -> J {
    o.unwrap_or(J::Null)
}

pub(super) fn pair(a: J, b: J) -> J {
    J::Arr(vec![a, b])
}
