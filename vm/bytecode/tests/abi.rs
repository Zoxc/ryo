use core::mem::{align_of, offset_of, size_of};
use ryo_bytecode::abi::*;

fn f<T>(offset: usize) -> ArgField {
    ArgField { offset: offset as u32, size: size_of::<T>() as u32, align: align_of::<T>() as u32 }
}

/// Layouts taken from real rustc tuples (as the backend would from `tcx.layout_of`) are
/// accepted.
macro_rules! real {
    ($($i:tt: $t:ty),*) => {{
        type Tup = ($($t,)*);
        let fields: Vec<ArgField> = vec![$(f::<$t>(offset_of!(Tup, $i))),*];
        let b = arg_block(&fields, size_of::<Tup>() as u32, align_of::<Tup>() as u32).unwrap();
        assert_eq!(b.size() as usize, size_of::<Tup>());
        let size = b.size();
        (fields, size)
    }};
}

#[test]
fn accepts_real_tuple_layouts() {
    real!(0: u8, 1: u32, 2: u8);
    real!(0: u64, 1: (), 2: &'static str, 3: bool);
    real!(0: u128, 1: u8);
    real!(0: Option<Box<u8>>, 1: char, 2: u16);
    real!();
}

/// rustc's tuple layout isn't a function of field sizes and alignments: these two tuples
/// have identical (size, align) field lists but different layouts, which is why `arg_block`
/// takes offsets from the backend instead of computing them.
#[test]
fn rustc_layout_depends_on_niches() {
    let (a, sa) = real!(0: u32, 1: u8, 2: bool, 3: u8);
    let (b, sb) = real!(0: u32, 1: u8, 2: u8, 3: u8);
    let key = |v: &[ArgField]| v.iter().map(|x| (x.size, x.align)).collect::<Vec<_>>();
    assert_eq!(key(&a), key(&b));
    assert_eq!(sa, sb);
    assert_ne!(a.iter().map(|x| x.offset).collect::<Vec<_>>(), b.iter().map(|x| x.offset).collect::<Vec<_>>());
    // And neither is the repr(C) order.
    let (c, _) = real!(0: u8, 1: u32, 2: u8);
    assert_ne!(c[0].offset, 0);
}

#[test]
fn rejects_bad_layouts() {
    let x = |offset, size, align| ArgField { offset, size, align };
    assert_eq!(arg_block(&[x(0, 4, 4), x(2, 4, 4)], 8, 4), Err(ArgBlockError::FieldMisaligned(1)));
    assert_eq!(arg_block(&[x(0, 4, 4), x(4, 4, 4)], 6, 2), Err(ArgBlockError::FieldOverAligned(0)));
    assert_eq!(arg_block(&[x(0, 4, 4), x(4, 4, 4)], 4, 4), Err(ArgBlockError::FieldOutOfBounds(1)));
    assert_eq!(arg_block(&[x(0, 8, 4), x(4, 4, 4)], 8, 4), Err(ArgBlockError::Overlap(0, 1)));
    assert_eq!(arg_block(&[x(0, 4, 3)], 4, 4), Err(ArgBlockError::BadAlign));
    assert_eq!(arg_block(&[], 6, 4), Err(ArgBlockError::SizeNotAligned));
    assert_eq!(arg_block(&[x(0, 32, 32)], 32, 32), Err(ArgBlockError::BlockOverAligned));
    // ZSTs may share offsets with anything.
    let ok = [x(0, 4, 4), x(0, 0, 1), x(4, 0, 4)];
    let b = arg_block(&ok, 4, 4).unwrap();
    assert_eq!(b.frame_offset(0), HEADER_SIZE);
    assert_eq!(b.outgoing_offset(64, 0), 64 + HEADER_SIZE);
    assert_eq!(b.end(), HEADER_SIZE + 4);
}

#[test]
fn frame_size_rounds_to_16() {
    assert_eq!(frame_size(16), 16);
    assert_eq!(frame_size(17), 32);
    assert_eq!(frame_size(HEADER_SIZE + 1), 32);
}
