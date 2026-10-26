//! The frame as allocas (design/jit.md, "The SSA tier"): the AOT frame cut into byte ranges
//! that no access, escaped object or island operand crosses (union-find over its bytes),
//! each classified: promoted (its fields become SSA variables), memory, the outgoing
//! argument area, or the incoming one. Also which allocas may be escaped at an OSR entry
//! (pinned to their AOT offsets), and for every access of a promoted alloca the variable it
//! reads or writes (by a reaching-shape dataflow, so that slots reused at other widths
//! split).

use alloc::vec::Vec;

use super::Unsupported;
use super::decode::{Code, How, Kind};
use super::ir::{Alloca, AllocaId, AllocaKind};
use crate::asm::ScopeKind;

/// A promoted field: `w` bytes at AOT offset `off` of an alloca.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Var {
    pub alloca: AllocaId,
    pub off: i32,
    pub w: u8,
}

impl Var {
    /// A field of the incoming argument area that nothing writes: its value is loaded at the
    /// entry (an incoming alloca stays memory, at its fixed place).
    pub fn incoming(&self) -> bool {
        self.off >= 16
    }
}

/// What an access names.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Res {
    /// A promoted variable (for a read: possibly at fewer bytes than its width).
    Var(u32),
    /// A read of promoted bytes nothing wrote: any value.
    Undef,
    /// Memory: the alloca, and the offset in it.
    Mem(AllocaId, i32),
}

pub struct Frame {
    pub allocas: Vec<Alloca>,
    pub vars: Vec<Var>,
    /// By instruction, by access ([`super::decode::RInsn::accs`]): what it reads (for a
    /// write, the variable it writes).
    pub res: Vec<Vec<Res>>,
    /// By instruction, by access: the variable a write or update of a promoted alloca
    /// defines (`u32::MAX` for the others).
    pub wvars: Vec<Vec<u32>>,
}

struct Uf(Vec<u32>);

impl Uf {
    fn find(&mut self, mut x: u32) -> u32 {
        while self.0[x as usize] != x {
            let p = self.0[x as usize];
            self.0[x as usize] = self.0[p as usize];
            x = p;
        }
        x
    }
    fn union(&mut self, a: u32, b: u32) {
        let (a, b) = (self.find(a), self.find(b));
        if a != b {
            self.0[a.max(b) as usize] = a.min(b);
        }
    }
}

const NONE: u16 = u16::MAX;
const CONFLICT: u16 = u16::MAX - 1;

pub fn analyze(code: &Code, frame_size: u32) -> Result<Frame, Unsupported> {
    let f = frame_size as i64;
    // The bytes: `[-F, hi)`, `hi` past the incoming arguments accessed.
    let mut hi = 16i64;
    for i in &code.insns {
        for a in i.accs.iter().filter(|a| a.size != 0 || a.how != How::Block) {
            let (lo, end) = (a.off as i64, a.off as i64 + a.size.max(1) as i64);
            if lo < -f {
                return Err(Unsupported("a frame access below the frame"));
            }
            if lo < 16 && end > 0 {
                return Err(Unsupported("a frame access at the return address"));
            }
            hi = hi.max(end);
        }
    }
    let n = (hi + f) as usize;
    let at = |off: i64| (off + f) as usize;
    let mut uf = Uf((0..n as u32).collect());
    let span = |uf: &mut Uf, off: i64, size: u32| {
        let lo = off.max(-f);
        let end = (off + size as i64).min(hi);
        if (lo < 16 && end > 0 && lo >= 0) || lo >= end {
            return;
        }
        for b in lo + 1..end {
            if b > 0 && b < 16 {
                continue;
            }
            uf.union(at(lo) as u32, at(b) as u32);
        }
    };
    // Per byte: explicitly read, escaped, a block (island, handler length), an address.
    let mut read = alloc::vec![false; n];
    let mut opaque = alloc::vec![false; n];
    let mut accessed = alloc::vec![false; n];
    let mut odd = alloc::vec![false; n];
    // The ends of escaped objects. An `addr` there (past a trailing zero-sized field, say)
    // is a 1-byte access of the next byte, which may be another alloca's or none: join the
    // two so that the end pointer stays with its object, whatever the layout. The object is
    // the one escaping at the `addr` (`ScopeAt::at`), unless one escaping there also starts
    // there (a call's arguments passed by address are their objects' starts); with none
    // escaping there, any escaped object that ends there.
    let mut ends: Vec<(u32, i64, i64)> = code
        .scopes
        .iter()
        .filter(|s| matches!(s.kind, ScopeKind::Escape { .. }) && s.size != 0)
        .map(|s| (s.at, s.off as i64, s.off as i64 + s.size as i64))
        .collect();
    ends.sort_unstable();
    let mut any_end: Vec<i64> = ends.iter().map(|e| e.2).collect();
    any_end.sort_unstable();
    for (k, i) in code.insns.iter().enumerate() {
        let island = matches!(i.kind, Kind::Island { .. });
        let here = &ends[ends.partition_point(|e| e.0 < k as u32)..ends.partition_point(|e| e.0 <= k as u32)];
        for a in i.accs.iter().filter(|a| a.how == How::Addr) {
            let off = a.off as i64;
            let end = if here.is_empty() {
                any_end.binary_search(&off).is_ok()
            } else {
                here.iter().any(|e| e.2 == off) && !here.iter().any(|e| e.1 == off)
            };
            if end {
                span(&mut uf, a.off as i64 - 1, 2);
            }
        }
        // A zero-sized island operand accesses nothing.
        for a in i.accs.iter().filter(|a| a.size != 0 || a.how != How::Block) {
            span(&mut uf, a.off as i64, a.size.max(1));
            let r = at(a.off as i64)..at(a.off as i64 + a.size.max(1) as i64).min(n);
            for b in r.clone() {
                accessed[b] = true;
                match a.how {
                    How::Read | How::Update => read[b] = true,
                    How::Addr => {
                        read[b] = true;
                        opaque[b] = true
                    }
                    How::Block => {
                        opaque[b] = true;
                        read[b] |= !island
                    }
                    How::BlockWrite => opaque[b] = true,
                    How::Write => {}
                }
                if !matches!(a.size, 1 | 2 | 4 | 8) {
                    odd[b] = true;
                }
            }
        }
    }
    let mut escaped = alloc::vec![false; n];
    for s in &code.scopes {
        if s.kind == ScopeKind::End {
            continue;
        }
        span(&mut uf, s.off as i64, s.size);
        let lo = (s.off as i64).max(-f);
        let end = (s.off as i64 + s.size as i64).min(hi);
        for b in lo..end.max(lo) {
            if !(0..16).contains(&b) {
                if s.kind == ScopeKind::Lend {
                    opaque[at(b)] = true;
                } else {
                    escaped[at(b)] = true;
                }
            }
        }
    }
    // The outgoing area: the longest run from `-F` of bytes nothing reads (calls read them
    // implicitly) and no pointer reaches, up to its last accessed byte.
    let mut out_end = 0;
    let mut k = 0;
    while k < n && (k as i64) < f && !read[k] && !escaped[k] {
        k += 1;
        if accessed[k - 1] {
            out_end = k;
        }
    }
    for b in 1..out_end {
        uf.union(0, b as u32);
    }

    // The allocas: classes in order of their first byte.
    let mut of = alloc::vec![u32::MAX; n];
    let mut allocas: Vec<Alloca> = Vec::new();
    let mut root_alloca = alloc::vec![u32::MAX; n];
    // The classes with a byte that something touches.
    let mut touched = alloc::vec![false; n];
    for b in 0..n {
        if accessed[b] || escaped[b] || opaque[b] || b < out_end {
            let r = uf.find(b as u32) as usize;
            touched[r] = true;
        }
    }
    for b in 0..n {
        let off = b as i64 - f;
        if (0..16).contains(&off) {
            continue;
        }
        let r = uf.find(b as u32) as usize;
        if !touched[r] {
            continue;
        }
        if root_alloca[r] == u32::MAX {
            root_alloca[r] = allocas.len() as u32;
            allocas.push(Alloca { aot_off: off as i32, size: 0, kind: AllocaKind::Promoted, pinned: false, escaped: false, inlined: false });
        }
        let a = root_alloca[r];
        of[b] = a;
        let al = &mut allocas[a as usize];
        al.size = (off - al.aot_off as i64 + 1) as u32;
        if escaped[b] {
            al.escaped = true;
        }
        if escaped[b] || opaque[b] || odd[b] {
            al.kind = AllocaKind::Memory;
        }
        if off >= 16 {
            al.kind = AllocaKind::Incoming;
        }
        if b < out_end {
            al.kind = AllocaKind::Outgoing;
        }
    }
    let alloca_at = |off: i32| -> Option<AllocaId> {
        let b = (off as i64 + f) as usize;
        of.get(b).copied().filter(|&a| a != u32::MAX).map(AllocaId)
    };

    // The reaching shapes of the promoted allocas' bytes: per byte the write shape (an
    // access `(off, w)`) that wrote it last, `NONE` if none, or `CONFLICT`.
    let mut shapes: Vec<(i32, u8)> = Vec::new();
    let shape_id = |shapes: &mut Vec<(i32, u8)>, s: (i32, u8)| -> u16 {
        match shapes.iter().position(|&x| x == s) {
            Some(i) => i as u16,
            None => {
                shapes.push(s);
                shapes.len() as u16 - 1
            }
        }
    };
    // Promoted bytes, densely.
    let mut pbyte = alloc::vec![u32::MAX; n];
    let mut np = 0u32;
    for b in 0..n {
        if of[b] != u32::MAX && allocas[of[b] as usize].kind == AllocaKind::Promoted {
            pbyte[b] = np;
            np += 1;
        }
    }
    let promoted = |allocas: &[Alloca], off: i32| alloca_at(off).is_some_and(|a| allocas[a.idx()].kind == AllocaKind::Promoted);
    // Shape ids of each write, by instruction and access.
    let mut wshape: Vec<Vec<u16>> = Vec::with_capacity(code.insns.len());
    for i in &code.insns {
        let mut v = Vec::with_capacity(i.accs.len());
        for a in &i.accs {
            v.push(if matches!(a.how, How::Write | How::Update) && promoted(&allocas, a.off) {
                if shapes.len() >= (CONFLICT - 1) as usize {
                    return Err(Unsupported("too many shapes"));
                }
                shape_id(&mut shapes, (a.off, a.size as u8))
            } else {
                NONE
            });
        }
        wshape.push(v);
    }
    let nb = code.blocks.len();
    let np = np as usize;
    let join = |into: &mut [u16], from: &[u16]| -> bool {
        let mut changed = false;
        for (x, &y) in into.iter_mut().zip(from) {
            let z = if *x == y || y == NONE {
                *x
            } else if *x == NONE {
                y
            } else {
                CONFLICT
            };
            if z != *x {
                *x = z;
                changed = true;
            }
        }
        changed
    };
    // `None` until a block is reached.
    let mut inn: Vec<Option<Vec<u16>>> = alloc::vec![None; nb];
    let mut demote = alloc::vec![false; allocas.len()];
    let mut res: Vec<Vec<Res>> = code.insns.iter().map(|i| alloc::vec![Res::Undef; i.accs.len()]).collect();
    if np > 0 && nb > 0 {
        inn[0] = Some(alloc::vec![NONE; np]);
        let mut work: Vec<usize> = alloc::vec![0];
        let mut queued = alloc::vec![false; nb];
        queued[0] = true;
        // Runs block `b` from its entry state: the state at the end, and before the last
        // instruction's writes (for its landing pad; only when it has one, and not while
        // resolving).
        let run = |b: usize, st: &mut Vec<u16>, before_last: &mut Vec<u16>, res: Option<&mut Vec<Vec<Res>>>, demote: &mut Vec<bool>| {
            let bl = &code.blocks[b];
            let mut res = res;
            for i in bl.start..bl.end {
                let ri = &code.insns[i as usize];
                for (k, a) in ri.accs.iter().enumerate() {
                    if !matches!(a.how, How::Read | How::Update) || !promoted(&allocas, a.off) {
                        continue;
                    }
                    let al = alloca_at(a.off).unwrap();
                    let bytes = (a.off as i64 + f) as usize..(a.off as i64 + f) as usize + a.size as usize;
                    let first = st[pbyte[bytes.start] as usize];
                    let all = bytes.clone().all(|x| st[pbyte[x] as usize] == first);
                    let r = if all && first == NONE {
                        Some(Res::Undef)
                    } else if all && first != CONFLICT && shapes[first as usize].0 == a.off && shapes[first as usize].1 as u32 >= a.size {
                        Some(Res::Var(first as u32))
                    } else {
                        None
                    };
                    match r {
                        None => demote[al.idx()] = true,
                        Some(r) => {
                            if let Some(res) = res.as_deref_mut() {
                                res[i as usize][k] = r;
                            }
                        }
                    }
                }
                if i + 1 == bl.end && bl.pad.is_some() && res.is_none() {
                    before_last.clone_from(st);
                }
                for (k, a) in ri.accs.iter().enumerate() {
                    let s = wshape[i as usize][k];
                    if s == NONE {
                        continue;
                    }
                    let lo = (a.off as i64 + f) as usize;
                    for x in lo..lo + a.size as usize {
                        st[pbyte[x] as usize] = s;
                    }
                    if let Some(res) = res.as_deref_mut()
                        && a.how == How::Write
                    {
                        res[i as usize][k] = Res::Var(s as u32);
                    }
                }
            }
        };
        let (mut st, mut before) = (Vec::new(), Vec::new());
        while let Some(b) = work.pop() {
            queued[b] = false;
            st.clone_from(inn[b].as_ref().unwrap());
            run(b, &mut st, &mut before, None, &mut demote);
            let bl = &code.blocks[b];
            for &s in &bl.succ {
                let from = if Some(s) == bl.pad { &before } else { &st };
                let s = s as usize;
                let changed = match &mut inn[s] {
                    Some(x) => join(x, from),
                    x @ None => {
                        *x = Some(from.clone());
                        true
                    }
                };
                if changed && !queued[s] {
                    queued[s] = true;
                    work.push(s);
                }
            }
        }
        // The resolutions, from the fixed point.
        for b in 0..nb {
            if let Some(mut st) = inn[b].take() {
                run(b, &mut st, &mut before, Some(&mut res), &mut demote);
            }
        }
    }
    for (a, d) in demote.iter().enumerate() {
        if *d {
            allocas[a].kind = AllocaKind::Memory;
        }
    }
    // Variables: the shapes of promoted allocas still promoted, densely.
    let mut var_of = alloc::vec![u32::MAX; shapes.len()];
    let mut vars = Vec::new();
    for (s, &(off, w)) in shapes.iter().enumerate() {
        let a = alloca_at(off).unwrap();
        if allocas[a.idx()].kind == AllocaKind::Promoted {
            var_of[s] = vars.len() as u32;
            vars.push(Var { alloca: a, off, w });
        }
    }
    // Incoming allocas only read, whole, at fields that don't overlap: their fields are
    // variables loaded at the entry.
    let mut ro_in = alloc::vec![true; allocas.len()];
    let mut fields: Vec<Vec<(i32, u32)>> = alloc::vec![Vec::new(); allocas.len()];
    for ri in &code.insns {
        for a in ri.accs.iter().filter(|a| a.size != 0 || a.how != How::Block) {
            let Some(al) = alloca_at(a.off) else { continue };
            let x = &allocas[al.idx()];
            if x.kind != AllocaKind::Incoming {
                continue;
            }
            let fs = &mut fields[al.idx()];
            if a.how != How::Read || !matches!(a.size, 1 | 2 | 4 | 8) || x.escaped {
                ro_in[al.idx()] = false;
            } else if !fs.contains(&(a.off, a.size)) {
                if fs.iter().any(|&(o, n)| (o as i64) < a.off as i64 + a.size as i64 && (a.off as i64) < o as i64 + n as i64) {
                    ro_in[al.idx()] = false;
                }
                fs.push((a.off, a.size));
            }
        }
    }
    for s in &code.scopes {
        if let Some(al) = alloca_at(s.off) {
            ro_in[al.idx()] &= s.kind == ScopeKind::End;
        }
    }
    let mut in_var: Vec<(i32, u32, u32)> = Vec::new();
    for (a, fs) in fields.iter().enumerate() {
        if allocas[a].kind == AllocaKind::Incoming && ro_in[a] {
            for &(off, size) in fs {
                in_var.push((off, size, vars.len() as u32));
                vars.push(Var { alloca: AllocaId(a as u32), off, w: size as u8 });
            }
        }
    }
    for (i, ri) in code.insns.iter().enumerate() {
        for (k, a) in ri.accs.iter().enumerate() {
            if a.size == 0 && a.how == How::Block {
                res[i][k] = Res::Undef;
                continue;
            }
            let al = match alloca_at(a.off) {
                Some(al) => al,
                None => return Err(Unsupported("an access outside every alloca")),
            };
            if let Some(&(_, _, v)) = in_var.iter().find(|x| x.0 == a.off && x.1 == a.size)
                && ro_in[al.idx()]
                && allocas[al.idx()].kind == AllocaKind::Incoming
            {
                res[i][k] = Res::Var(v);
            } else if allocas[al.idx()].kind == AllocaKind::Promoted {
                res[i][k] = match res[i][k] {
                    Res::Var(s) => Res::Var(var_of[s as usize]),
                    r => r,
                };
            } else {
                res[i][k] = Res::Mem(al, a.off - allocas[al.idx()].aot_off);
            }
        }
    }

    // Escapes at the enterable heads: a forward may-dataflow over the memory allocas.
    let na = allocas.len();
    let words = na.div_ceil(64);
    let mut ein: Vec<Option<Vec<u64>>> = alloc::vec![None; nb];
    if nb > 0 && code.scopes.iter().any(|s| matches!(s.kind, ScopeKind::Escape { .. })) {
        ein[0] = Some(alloc::vec![0; words]);
        let mut work: Vec<usize> = alloc::vec![0];
        let mut scope_at: Vec<Vec<usize>> = alloc::vec![Vec::new(); code.insns.len() + 1];
        for (k, s) in code.scopes.iter().enumerate() {
            scope_at[s.at as usize].push(k);
        }
        let covered = |off: i32, size: u32| -> Vec<(usize, bool)> {
            // The allocas the range touches, and whether it covers each whole.
            let mut v: Vec<(usize, bool)> = Vec::new();
            for (a, al) in allocas.iter().enumerate() {
                let (lo, end) = (al.aot_off as i64, al.aot_off as i64 + al.size as i64);
                let (s, e) = (off as i64, off as i64 + size as i64);
                if s < end && lo < e {
                    v.push((a, s <= lo && end <= e));
                }
            }
            v
        };
        while let Some(b) = work.pop() {
            let mut st = ein[b].clone().unwrap();
            let bl = &code.blocks[b];
            for i in bl.start..bl.end {
                for &k in &scope_at[i as usize] {
                    let s = &code.scopes[k];
                    match s.kind {
                        ScopeKind::Escape { .. } => covered(s.off, s.size).iter().for_each(|&(a, _)| st[a / 64] |= 1 << (a % 64)),
                        ScopeKind::End => covered(s.off, s.size).iter().filter(|x| x.1).for_each(|&(a, _)| st[a / 64] &= !(1 << (a % 64))),
                        ScopeKind::Lend => {}
                    }
                }
            }
            for &s in &bl.succ {
                let s = s as usize;
                let changed = match &mut ein[s] {
                    Some(x) => {
                        let mut c = false;
                        for (p, q) in x.iter_mut().zip(&st) {
                            if *p | q != *p {
                                *p |= q;
                                c = true;
                            }
                        }
                        c
                    }
                    x @ None => {
                        *x = Some(st.clone());
                        true
                    }
                };
                if changed {
                    work.push(s);
                }
            }
        }
        for (b, bl) in code.blocks.iter().enumerate() {
            if let (Some(h), Some(st)) = (bl.head, &ein[b])
                && code.enterable[h as usize]
            {
                for a in 0..na {
                    if st[a / 64] >> (a % 64) & 1 != 0 {
                        allocas[a].pinned = true;
                    }
                }
            }
        }
    }
    let wvars = wshape.iter().map(|v| v.iter().map(|&s| if s == NONE { u32::MAX } else { var_of[s as usize] }).collect()).collect();
    Ok(Frame { allocas, vars, res, wvars })
}
