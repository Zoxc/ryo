//! Code memory: the regions near the images that JIT code and its unwind information are
//! taken from, and which of them a function is compiled for.

use super::*;

/// The size of a code region: one mapping that code (from the start, in pages, made
/// executable once written) and unwind information (from the end, read-write) are taken from.
pub(super) const REGION: usize = 32 << 20;
/// How far apart a 32-bit PC-relative field and its target may be, with a margin.
pub(super) const REACH: usize = (1 << 31) - (1 << 20);
/// An address range `lo..hi` that code must reach with 32-bit PC-relative fields.
#[derive(Clone, Copy)]
pub(super) struct Span {
    pub(super) lo: usize,
    pub(super) hi: usize,
}

/// A mapping near some images ([`REGION`]): code is taken from `code` up, unwind
/// information from `data` down. A full one is retired: it stays mapped (its code may run),
/// but nothing is compiled for it any more.
pub(super) struct Region {
    pub(super) start: usize,
    pub(super) end: usize,
    pub(super) code: usize,
    pub(super) data: usize,
    pub(super) retired: bool,
}

impl Region {
    /// Whether all of the region reaches all of `s`.
    pub(super) fn reaches(&self, s: Span) -> bool {
        reaches(self.start, self.end, s)
    }
}

pub(super) fn reaches(start: usize, end: usize, s: Span) -> bool {
    s.hi.saturating_sub(start) <= REACH && end.saturating_sub(s.lo) <= REACH
}

impl Span {
    pub(super) fn union(self, o: Span) -> Span {
        Span { lo: self.lo.min(o.lo), hi: self.hi.max(o.hi) }
    }
}

/// The region a function is compiled for: calls are encoded by whether it reaches their
/// targets.
#[derive(Clone, Copy)]
pub(super) struct Place {
    /// Its index in [`Jit::regions`].
    pub(super) region: usize,
    pub(super) start: usize,
    pub(super) end: usize,
    /// The handlers and the probe are out of reach ([`Mode::far_rt`]).
    pub(super) far_rt: bool,
}

impl Place {
    pub(super) fn reaches(&self, addr: usize) -> bool {
        reaches(self.start, self.end, Span { lo: addr, hi: addr + 1 })
    }
}

impl Jit {
    /// The region to compile code of an image of span `s` for: one that also reaches the
    /// handlers and the probe if there is one (mapping it if need be), else one that reaches
    /// the image only, whose code calls them through `r11` ([`Mode::far_rt`]): an image far
    /// from a shared `ryo_rt`.
    pub(super) fn place(&mut self, s: Span) -> Option<Place> {
        let rt = self.rt_span;
        let i = match self.region(s.union(rt)) {
            Some(i) => i,
            None => self.region(s)?,
        };
        let r = &self.regions[i];
        Some(Place { region: i, start: r.start, end: r.end, far_rt: !r.reaches(rt) })
    }

    /// The index of a region that reaches `s`, mapping a new one if none does.
    fn region(&mut self, s: Span) -> Option<usize> {
        if s.hi - s.lo > REACH {
            return None;
        }
        if let Some(i) = self.regions.iter().position(|r| !r.retired && r.reaches(s)) {
            return Some(i);
        }
        const STEP: usize = 2 << 20;
        let above = s.hi.next_multiple_of(STEP);
        let below = (s.lo & !(STEP - 1)).checked_sub(REGION);
        for k in 0..(REACH / REGION) {
            for hint in [above.checked_add(k * REGION), below.and_then(|b| b.checked_sub(k * REGION))].into_iter().flatten() {
                if !reaches(hint, hint + REGION, s) {
                    continue;
                }
                let Some(p) = vmem::reserve_code(hint, REGION) else { continue };
                let p = p as usize;
                // Linux before 4.17 (no `MAP_FIXED_NOREPLACE`) and Apple take the address as a
                // hint only.
                if !reaches(p, p + REGION, s) {
                    // SAFETY: the mapping just made.
                    unsafe { vmem::release(p as *mut u8, REGION) };
                    continue;
                }
                self.regions.push(Region { start: p, end: p + REGION, code: p, data: p + REGION, retired: false });
                return Some(self.regions.len() - 1);
            }
        }
        None
    }
}
