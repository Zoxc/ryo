//! A minimal JSON reader for `ryo-lean exec-item`'s responses (numbers kept as text, so `u64`
//! and `u128` values stay exact).

#[derive(Debug, Clone, PartialEq)]
pub enum Json {
    Null,
    Bool(bool),
    Num(String),
    Str(String),
    Arr(Vec<Json>),
    Obj(Vec<(String, Json)>),
}

impl Json {
    pub fn get(&self, k: &str) -> Option<&Json> {
        match self {
            Json::Obj(kv) => kv.iter().find(|(key, _)| key == k).map(|(_, v)| v),
            _ => None,
        }
    }

    pub fn arr(&self) -> Option<&[Json]> {
        match self {
            Json::Arr(a) => Some(a),
            _ => None,
        }
    }

    pub fn str(&self) -> Option<&str> {
        match self {
            Json::Str(s) => Some(s),
            _ => None,
        }
    }

    pub fn u128(&self) -> Option<u128> {
        match self {
            Json::Num(n) => n.parse().ok(),
            _ => None,
        }
    }

    pub fn u64(&self) -> Option<u64> {
        self.u128().and_then(|v| u64::try_from(v).ok())
    }

    /// `Some(b)` for a boolean, `None` for `null` or a missing value.
    pub fn opt_bool(&self) -> Option<bool> {
        match self {
            Json::Bool(b) => Some(*b),
            _ => None,
        }
    }
}

pub fn parse(s: &str) -> Result<Json, String> {
    let mut p = Parser { s: s.as_bytes(), i: 0 };
    let v = p.value()?;
    p.ws();
    if p.i != p.s.len() {
        return Err(format!("trailing input at {}", p.i));
    }
    Ok(v)
}

struct Parser<'a> {
    s: &'a [u8],
    i: usize,
}

impl Parser<'_> {
    fn ws(&mut self) {
        while self.i < self.s.len() && self.s[self.i].is_ascii_whitespace() {
            self.i += 1;
        }
    }

    fn peek(&mut self) -> Option<u8> {
        self.ws();
        self.s.get(self.i).copied()
    }

    fn expect(&mut self, c: u8) -> Result<(), String> {
        if self.peek() == Some(c) {
            self.i += 1;
            Ok(())
        } else {
            Err(format!("expected `{}` at {}", c as char, self.i))
        }
    }

    fn lit(&mut self, w: &str, v: Json) -> Result<Json, String> {
        if self.s[self.i..].starts_with(w.as_bytes()) {
            self.i += w.len();
            Ok(v)
        } else {
            Err(format!("bad literal at {}", self.i))
        }
    }

    fn value(&mut self) -> Result<Json, String> {
        match self.peek().ok_or("unexpected end")? {
            b'n' => self.lit("null", Json::Null),
            b't' => self.lit("true", Json::Bool(true)),
            b'f' => self.lit("false", Json::Bool(false)),
            b'"' => Ok(Json::Str(self.string()?)),
            b'[' => {
                self.i += 1;
                let mut a = Vec::new();
                if self.peek() == Some(b']') {
                    self.i += 1;
                    return Ok(Json::Arr(a));
                }
                loop {
                    a.push(self.value()?);
                    match self.peek() {
                        Some(b',') => self.i += 1,
                        Some(b']') => {
                            self.i += 1;
                            return Ok(Json::Arr(a));
                        }
                        _ => return Err(format!("bad array at {}", self.i)),
                    }
                }
            }
            b'{' => {
                self.i += 1;
                let mut o = Vec::new();
                if self.peek() == Some(b'}') {
                    self.i += 1;
                    return Ok(Json::Obj(o));
                }
                loop {
                    self.ws();
                    let k = self.string()?;
                    self.expect(b':')?;
                    o.push((k, self.value()?));
                    match self.peek() {
                        Some(b',') => self.i += 1,
                        Some(b'}') => {
                            self.i += 1;
                            return Ok(Json::Obj(o));
                        }
                        _ => return Err(format!("bad object at {}", self.i)),
                    }
                }
            }
            _ => {
                let start = self.i;
                while self.i < self.s.len() && matches!(self.s[self.i], b'-' | b'+' | b'.' | b'e' | b'E' | b'0'..=b'9') {
                    self.i += 1;
                }
                if start == self.i {
                    return Err(format!("unexpected character at {}", self.i));
                }
                Ok(Json::Num(String::from_utf8_lossy(&self.s[start..self.i]).into_owned()))
            }
        }
    }

    fn string(&mut self) -> Result<String, String> {
        self.expect(b'"')?;
        let mut out = String::new();
        loop {
            let c = *self.s.get(self.i).ok_or("unterminated string")?;
            self.i += 1;
            match c {
                b'"' => return Ok(out),
                b'\\' => {
                    let e = *self.s.get(self.i).ok_or("unterminated escape")?;
                    self.i += 1;
                    match e {
                        b'n' => out.push('\n'),
                        b't' => out.push('\t'),
                        b'r' => out.push('\r'),
                        b'u' => {
                            let h = std::str::from_utf8(self.s.get(self.i..self.i + 4).ok_or("bad \\u")?).map_err(|e| e.to_string())?;
                            let v = u32::from_str_radix(h, 16).map_err(|e| e.to_string())?;
                            out.push(char::from_u32(v).unwrap_or('?'));
                            self.i += 4;
                        }
                        c => out.push(c as char),
                    }
                }
                _ => {
                    // Copy a UTF-8 sequence through.
                    let start = self.i - 1;
                    let mut end = self.i;
                    while end < self.s.len() && (self.s[end] & 0xc0) == 0x80 {
                        end += 1;
                    }
                    out.push_str(&String::from_utf8_lossy(&self.s[start..end]));
                    self.i = end;
                }
            }
        }
    }
}
