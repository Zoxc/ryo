//! Encoding of compiler values across sessions, for the side file saved with an image's work
//! product (design/backend.md#incremental): what a reused image's CGU gives the native CGUs
//! and the exported-symbols queries, with `Instance`s and `MonoItem`s in it.
//!
//! rustc's own on-disk cache encoder is private to its query system, so this is a small
//! `TyEncoder`/`TyDecoder` pair over `rustc_serialize`'s in-memory coders: `DefId`s as their
//! `DefPathHash`es, crates as their `StableCrateId`s, symbols as strings, types with
//! shorthands. Nothing in the values it carries has spans, expansions or allocations.

use rustc_data_structures::fx::FxHashMap;
use rustc_hir::def_id::{CrateNum, DefId, DefIndex, DefPathHash, StableCrateId};
use rustc_middle::mir::interpret::AllocId;
use rustc_middle::ty::codec::{TyDecoder, TyEncoder};
use rustc_middle::ty::{self, Ty, TyCtxt};
use rustc_serialize::opaque::MemDecoder;
use rustc_serialize::opaque::mem_encoder::MemEncoder;
use rustc_serialize::{Decodable, Decoder, Encodable, Encoder};
use rustc_span::{AttrId, BlobDecoder, ByteSymbol, ExpnId, Span, SpanDecoder, SpanEncoder, Symbol, SyntaxContext};

/// Encodes values for [`Dec`].
pub struct Enc<'tcx> {
    tcx: TyCtxt<'tcx>,
    e: MemEncoder,
    types: FxHashMap<Ty<'tcx>, usize>,
    predicates: FxHashMap<ty::PredicateKind<'tcx>, usize>,
}

impl<'tcx> Enc<'tcx> {
    pub fn new(tcx: TyCtxt<'tcx>) -> Self {
        Enc { tcx, e: MemEncoder::new(), types: FxHashMap::default(), predicates: FxHashMap::default() }
    }

    pub fn finish(self) -> Vec<u8> {
        // `MemDecoder` expects the end marker `FileEncoder` writes.
        let mut v = self.e.finish();
        v.extend_from_slice(rustc_serialize::opaque::MAGIC_END_BYTES);
        v
    }
}

macro_rules! forward_emit {
    ($($name:ident: $t:ty),*) => {
        $(fn $name(&mut self, v: $t) { self.e.$name(v) })*
    };
}

impl Encoder for Enc<'_> {
    forward_emit!(emit_usize: usize, emit_u128: u128, emit_u64: u64, emit_u32: u32, emit_u16: u16, emit_u8: u8,
        emit_isize: isize, emit_i128: i128, emit_i64: i64, emit_i32: i32, emit_i16: i16);

    fn emit_raw_bytes(&mut self, s: &[u8]) {
        self.e.emit_raw_bytes(s)
    }
}

impl SpanEncoder for Enc<'_> {
    fn encode_span(&mut self, _: Span) {
        // Spans don't matter to codegen; they decode as dummies.
    }

    fn encode_symbol(&mut self, sym: Symbol) {
        self.emit_str(sym.as_str());
    }

    fn encode_byte_symbol(&mut self, sym: ByteSymbol) {
        self.emit_byte_str(sym.as_byte_str());
    }

    fn encode_expn_id(&mut self, _: ExpnId) {
        panic!("ryo: no `ExpnId` in a saved image's side data");
    }

    fn encode_syntax_context(&mut self, _: SyntaxContext) {
        panic!("ryo: no `SyntaxContext` in a saved image's side data");
    }

    fn encode_crate_num(&mut self, krate: CrateNum) {
        self.tcx.stable_crate_id(krate).encode(self);
    }

    fn encode_def_index(&mut self, _: DefIndex) {
        panic!("ryo: a bare `DefIndex` in a saved image's side data");
    }

    fn encode_def_id(&mut self, def_id: DefId) {
        self.tcx.def_path_hash(def_id).encode(self);
    }
}

impl<'tcx> TyEncoder<'tcx> for Enc<'tcx> {
    const CLEAR_CROSS_CRATE: bool = true;

    fn position(&self) -> usize {
        self.e.position()
    }

    fn type_shorthands(&mut self) -> &mut FxHashMap<Ty<'tcx>, usize> {
        &mut self.types
    }

    fn predicate_shorthands(&mut self) -> &mut FxHashMap<ty::PredicateKind<'tcx>, usize> {
        &mut self.predicates
    }

    fn encode_alloc_id(&mut self, _: &AllocId) {
        panic!("ryo: no allocation in a saved image's side data");
    }
}

/// Decodes what [`Enc`] encoded, in a later session.
pub struct Dec<'a, 'tcx> {
    tcx: TyCtxt<'tcx>,
    d: MemDecoder<'a>,
    types: FxHashMap<usize, Ty<'tcx>>,
}

impl<'a, 'tcx> Dec<'a, 'tcx> {
    pub fn new(tcx: TyCtxt<'tcx>, data: &'a [u8]) -> Option<Self> {
        Some(Dec { tcx, d: MemDecoder::new(data, 0).ok()?, types: FxHashMap::default() })
    }
}

macro_rules! forward_read {
    ($($name:ident: $t:ty),*) => {
        $(fn $name(&mut self) -> $t { self.d.$name() })*
    };
}

impl Decoder for Dec<'_, '_> {
    forward_read!(read_usize: usize, read_u128: u128, read_u64: u64, read_u32: u32, read_u16: u16, read_u8: u8,
        read_isize: isize, read_i128: i128, read_i64: i64, read_i32: i32, read_i16: i16);

    fn read_raw_bytes(&mut self, len: usize) -> &[u8] {
        self.d.read_raw_bytes(len)
    }

    fn peek_byte(&self) -> u8 {
        self.d.peek_byte()
    }

    fn position(&self) -> usize {
        self.d.position()
    }
}

impl BlobDecoder for Dec<'_, '_> {
    fn decode_symbol(&mut self) -> Symbol {
        Symbol::intern(self.read_str())
    }

    fn decode_byte_symbol(&mut self) -> ByteSymbol {
        ByteSymbol::intern(self.read_byte_str())
    }

    fn decode_def_index(&mut self) -> DefIndex {
        panic!("ryo: a bare `DefIndex` in a saved image's side data");
    }
}

impl SpanDecoder for Dec<'_, '_> {
    fn decode_span(&mut self) -> Span {
        rustc_span::DUMMY_SP
    }

    fn decode_expn_id(&mut self) -> ExpnId {
        panic!("ryo: no `ExpnId` in a saved image's side data");
    }

    fn decode_syntax_context(&mut self) -> SyntaxContext {
        panic!("ryo: no `SyntaxContext` in a saved image's side data");
    }

    fn decode_crate_num(&mut self) -> CrateNum {
        let id = StableCrateId::decode(self);
        self.tcx.stable_crate_id_to_crate_num(id)
    }

    fn decode_def_id(&mut self) -> DefId {
        let h = DefPathHash::decode(self);
        // The side data is read only once its image's dep node is green, so every item it
        // names still exists.
        self.tcx.def_path_hash_to_def_id(h).unwrap_or_else(|| panic!("ryo: an item of a reused image's side data is gone ({h:?})"))
    }

    fn decode_attr_id(&mut self) -> AttrId {
        panic!("ryo: no `AttrId` in a saved image's side data");
    }
}

impl<'tcx> rustc_type_ir::InternerDecoder for Dec<'_, 'tcx> {
    type Interner = TyCtxt<'tcx>;

    fn interner(&self) -> TyCtxt<'tcx> {
        self.tcx
    }
}

impl<'tcx> TyDecoder<'tcx> for Dec<'_, 'tcx> {
    const CLEAR_CROSS_CRATE: bool = true;

    fn cached_ty_for_shorthand<F>(&mut self, shorthand: usize, or_insert_with: F) -> Ty<'tcx>
    where
        F: FnOnce(&mut Self) -> Ty<'tcx>,
    {
        if let Some(&t) = self.types.get(&shorthand) {
            return t;
        }
        let t = or_insert_with(self);
        self.types.insert(shorthand, t);
        t
    }

    fn with_position<F, R>(&mut self, pos: usize, f: F) -> R
    where
        F: FnOnce(&mut Self) -> R,
    {
        let new = self.d.split_at(pos);
        let old = std::mem::replace(&mut self.d, new);
        let r = f(self);
        self.d = old;
        r
    }

    fn decode_alloc_id(&mut self) -> AllocId {
        panic!("ryo: no allocation in a saved image's side data");
    }
}

/// Encodes `v`.
pub fn encode<'tcx, T: Encodable<Enc<'tcx>>>(tcx: TyCtxt<'tcx>, v: &T) -> Vec<u8> {
    let mut e = Enc::new(tcx);
    v.encode(&mut e);
    e.finish()
}

/// Decodes a `T` from `data`, `None` if it lacks the end marker (e.g. truncated). Like
/// rustc's own incremental data, a corrupt body or one naming items that are gone panics.
pub fn decode<'a, 'tcx, T: Decodable<Dec<'a, 'tcx>>>(tcx: TyCtxt<'tcx>, data: &'a [u8]) -> Option<T> {
    let mut d = Dec::new(tcx, data)?;
    Some(T::decode(&mut d))
}
