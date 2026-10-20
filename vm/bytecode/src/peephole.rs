//! Peephole passes over a function's code (design/lowering.md, "Bytecode optimization").
//!
//! [`fuse`] forms superinstructions ([`SUPERINSTRUCTIONS`]). It only rewrites opcode words:
//! a superinstruction has its first part's operands and the second part stays in place, so
//! instruction positions, branch targets (which may point at either part), cleanup table
//! offsets and return pcs are unaffected. It can run at any point after the code is complete,
//! before or after branch targets are patched, and running it again changes nothing.

use crate::insn::{CodeBuf, DecodeError, Opcode, SUPERINSTRUCTIONS, insn_len};

/// The superinstruction for `first` directly followed by `second`, if there is one.
pub fn superinstruction(first: Opcode, second: Opcode) -> Option<Opcode> {
    SUPERINSTRUCTIONS.iter().find(|&&(_, a, b)| a == first && b == second).map(|&(f, _, _)| f)
}

/// Replaces every instruction that starts a superinstruction pair with the superinstruction,
/// and returns how many it formed. Pairs may overlap (`a b c` with `a+b` and `b+c` both
/// existing becomes `a+b b+c c`): a superinstruction runs its second part as that part's
/// plain opcode, whatever that instruction's own opcode word became.
///
/// Fails if the code doesn't decode into whole instructions; the code is then unchanged.
pub fn fuse(code: &mut CodeBuf) -> Result<usize, DecodeError> {
    let w = &mut code.words;
    // Instruction starts first, so that a decode error leaves the code untouched.
    let mut starts = alloc::vec::Vec::new();
    let mut pos = 0;
    while pos < w.len() {
        starts.push(pos);
        pos += insn_len(&w[pos..])?;
    }
    let base = |w: u32| Opcode::from_u16(w as u16).map(Opcode::first_part);
    let mut n = 0;
    for pair in starts.windows(2) {
        let (i, j) = (pair[0], pair[1]);
        if let (Some(a), Some(b)) = (base(w[i]), base(w[j]))
            && let Some(f) = superinstruction(a, b)
        {
            if w[i] != f as u32 {
                n += 1;
            }
            w[i] = f as u32;
        }
    }
    Ok(n)
}
