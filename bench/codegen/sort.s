fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     [rbp-20h],rax
     17: mov     rax,[rbp+18h]
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx-1]
     2b: mov     edi,0FFFFFFFFh
     30: mov     esi,1
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

fn <&u32 as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     [rbp-20h],rax
     17: mov     rax,[rbp+18h]
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx-1]
     2b: mov     edi,0FFFFFFFFh
     30: mov     esi,1
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

fn <() as std::process::Termination>::report
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     byte ptr [rbp-1],0
      c: mov     edi,0FFFFFFFFh
     11: mov     esi,1
     16: call    ryo_h_Ret
     1b: leave
     1c: ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFE0h
     1c: mov     esi,20h
     21: call    ryo_h_MovW128
     26: mov     rax,[rbp+30h]
     2a: mov     [rbp-10h],rax
     2e: call    fn0
     33: nop     [rcx]
     3a: xor     edi,edi
     3c: xor     esi,esi
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-8],20h
     10: mov     edi,0FFFFFFF8h
     15: mov     esi,8
     1a: call    ryo_h_Ret
     1f: leave
     20: ret

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     byte ptr [rbp-1],1
      c: mov     edi,0FFFFFFFFh
     11: mov     esi,1
     16: call    ryo_h_Ret
     1b: leave
     1c: ret

fn <(u32, u32) as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-80h],rax
     13: mov     edi,0FFFFFF88h
     18: lea     rsi,[k0]
     1f: call    ryo_h_AddrAbs
     24: mov     qword ptr [rbp-70h],0
     2c: lea     rdi,[sym1]
     33: lea     rsi,[site2]
     3a: mov     edx,0FFFFFFA0h
     3f: call    ryo_h_CallExt
     44: test    rax,rax
     47: je      54h
     49: call    rax
     4b: nop     [rcx-20h]
     52: jmp     64h
     54: mov     rdi,rbp
     57: lea     rsi,[ro+4]
     5e: call    qword ptr [sym3]
     64: mov     rax,[rbp+10h]
     68: mov     [rbp-28h],rax
     6c: mov     rax,[rbp+10h]
     70: lea     rax,[rax+4]
     74: mov     [rbp-30h],rax
     78: lea     rax,[rbp-20h]
     7c: mov     [rbp-40h],rax
     80: lea     rax,[rbp-28h]
     84: mov     [rbp-58h],rax
     88: mov     [rbp-50h],rax
     8c: mov     edi,0FFFFFFB8h
     91: lea     rsi,[k4]
     98: call    ryo_h_AddrAbs
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-80h],rax
     a5: mov     edi,0FFFFFF88h
     aa: mov     esi,0FFFFFFB0h
     af: call    ryo_h_MovW128
     b4: lea     rdi,[sym5]
     bb: lea     rsi,[site6]
     c2: mov     edx,0FFFFFFA0h
     c7: call    ryo_h_CallExt
     cc: test    rax,rax
     cf: je      0DCh
     d1: call    rax
     d3: nop     [rcx-38h]
     da: jmp     0ECh
     dc: mov     rdi,rbp
     df: lea     rsi,[ro+20]
     e6: call    qword ptr [sym7]
     ec: lea     rax,[rbp-20h]
     f0: mov     [rbp-40h],rax
     f4: lea     rax,[rbp-30h]
     f8: mov     [rbp-58h],rax
     fc: mov     [rbp-50h],rax
    100: mov     edi,0FFFFFFB8h
    105: lea     rsi,[k8]
    10c: call    ryo_h_AddrAbs
    111: mov     rax,[rbp-40h]
    115: mov     [rbp-80h],rax
    119: mov     edi,0FFFFFF88h
    11e: mov     esi,0FFFFFFB0h
    123: call    ryo_h_MovW128
    128: lea     rdi,[sym9]
    12f: lea     rsi,[site10]
    136: mov     edx,0FFFFFFA0h
    13b: call    ryo_h_CallExt
    140: test    rax,rax
    143: je      150h
    145: call    rax
    147: nop     [rcx-38h]
    14e: jmp     160h
    150: mov     rdi,rbp
    153: lea     rsi,[ro+20]
    15a: call    qword ptr [sym11]
    160: lea     rax,[rbp-20h]
    164: mov     [rbp-38h],rax
    168: mov     [rbp-80h],rax
    16c: lea     rdi,[sym12]
    173: lea     rsi,[site13]
    17a: mov     edx,0FFFFFFA0h
    17f: call    ryo_h_CallExt
    184: test    rax,rax
    187: je      194h
    189: call    rax
    18b: nop     [rcx-1]
    192: jmp     1A4h
    194: mov     rdi,rbp
    197: lea     rsi,[ro+36]
    19e: call    qword ptr [sym14]
    1a4: mov     edi,0FFFFFFFFh
    1a9: mov     esi,1
    1ae: call    ryo_h_Ret
    1b3: leave
    1b4: ret

fn <[u32] as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-0A0h],rax
     16: lea     rdi,[sym0]
     1d: lea     rsi,[site1]
     24: mov     edx,0FFFFFF80h
     29: call    ryo_h_CallExt
     2e: test    rax,rax
     31: je      3Eh
     33: call    rax
     35: nop     [rcx-28h]
     3c: jmp     4Eh
     3e: mov     rdi,rbp
     41: lea     rsi,[ro+4]
     48: call    qword ptr [sym2]
     4e: lea     rax,[rbp-28h]
     52: mov     [rbp-18h],rax
     56: mov     rax,[rbp+18h]
     5a: mov     [rbp-40h],rax
     5e: mov     rax,[rbp+10h]
     62: mov     [rbp-70h],rax
     66: mov     rax,[rbp+18h]
     6a: mov     [rbp-68h],rax
     6e: mov     edi,0FFFFFFA8h
     73: mov     esi,0FFFFFF90h
     78: call    ryo_h_MovW128
     7d: mov     edi,0FFFFFF88h
     82: mov     esi,0FFFFFFA8h
     87: call    ryo_h_MovW128
     8c: mov     rax,[rbp-78h]
     90: mov     [rbp-68h],rax
     94: mov     [rbp-48h],rax
     98: mov     byte ptr [rbp-79h],0
     9c: test    byte ptr [rbp-79h],0FFh
     a0: je      10Eh
     a2: jmp     104h
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: mov     rax,[rbp-10h]
     b4: mov     [rbp-0A0h],rax
     bb: lea     rdi,[sym3]
     c2: lea     rsi,[site4]
     c9: mov     edx,0FFFFFF80h
     ce: call    ryo_h_CallExt
     d3: test    rax,rax
     d6: je      0E3h
     d8: call    rax
     da: nop     [rcx-1]
     e1: jmp     0F3h
     e3: mov     rdi,rbp
     e6: lea     rsi,[ro+20]
     ed: call    qword ptr [sym5]
     f3: mov     edi,0FFFFFFFFh
     f8: mov     esi,1
     fd: call    ryo_h_Ret
    102: leave
    103: ret
    104: mov     rax,[rbp-40h]
    108: mov     [rbp-60h],rax
    10c: jmp     126h
    10e: mov     rax,[rbp-48h]
    112: mov     [rbp-58h],rax
    116: imul    rcx,[rbp-40h],4
    11b: add     rax,rcx
    11e: mov     [rbp-50h],rax
    122: mov     [rbp-60h],rax
    126: mov     rax,[rbp-48h]
    12a: mov     [rbp-38h],rax
    12e: mov     rax,[rbp-60h]
    132: mov     [rbp-30h],rax
    136: mov     rax,[rbp-18h]
    13a: mov     [rbp-0A0h],rax
    141: mov     edi,0FFFFFF68h
    146: mov     esi,0FFFFFFC8h
    14b: call    ryo_h_MovW128
    150: call    fn6
    155: nop     [rcx-10h]
    15c: jmp     0B0h

fn <alloc::raw_vec::RawVec<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFD8h
     19: lea     rsi,[k0]
     20: mov     edx,10h
     25: call    ryo_h_Const
     2a: lea     rdi,[sym1]
     31: lea     rsi,[site2]
     38: mov     edx,0FFFFFFF0h
     3d: call    ryo_h_CallExt
     42: test    rax,rax
     45: je      52h
     47: call    rax
     49: nop     [rcx]
     50: jmp     62h
     52: mov     rdi,rbp
     55: lea     rsi,[ro+4]
     5c: call    qword ptr [sym3]
     62: xor     edi,edi
     64: xor     esi,esi
     66: call    ryo_h_Ret
     6b: leave
     6c: ret

fn <alloc::raw_vec::RawVec<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFD8h
     19: lea     rsi,[k0]
     20: mov     edx,10h
     25: call    ryo_h_Const
     2a: lea     rdi,[sym1]
     31: lea     rsi,[site2]
     38: mov     edx,0FFFFFFF0h
     3d: call    ryo_h_CallExt
     42: test    rax,rax
     45: je      52h
     47: call    rax
     49: nop     [rcx]
     50: jmp     62h
     52: mov     rdi,rbp
     55: lea     rsi,[ro+4]
     5c: call    qword ptr [sym3]
     62: xor     edi,edi
     64: xor     esi,esi
     66: call    ryo_h_Ret
     6b: leave
     6c: ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+8]
     1b: mov     [rbp-10h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+10h]
     27: mov     [rbp-18h],rax
     2b: mov     byte ptr [rbp-29h],1
     2f: test    byte ptr [rbp-29h],0FFh
     33: je      8Ah
     35: mov     rax,[rbp-8]
     39: mov     [rbp-20h],rax
     3d: mov     rax,[rbp-10h]
     41: mov     [rbp-28h],rax
     45: mov     rax,[rbp-20h]
     49: mov     [rbp-60h],rax
     4d: mov     rax,[rbp-28h]
     51: mov     [rbp-58h],rax
     55: mov     qword ptr [rbp-50h],8
     5d: mov     qword ptr [rbp-48h],4
     65: mov     rax,[rbp-18h]
     69: mov     [rbp-40h],rax
     6d: mov     edi,0FFFFFFC8h
     72: lea     rsi,[k0]
     79: call    ryo_h_AddrAbs
     7e: call    fn1
     83: nop     [rcx]
     8a: imul    rax,[rbp-18h],8
     8f: mov     [rbp-30h],rax
     93: mov     edi,0FFFFFFF0h
     98: mov     esi,0FFFFFFF8h
     9d: mov     edx,0FFFFFFD0h
     a2: call    ryo_h_Memcpy
     a7: xor     edi,edi
     a9: xor     esi,esi
     ab: call    ryo_h_Ret
     b0: leave
     b1: ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+8]
     1b: mov     [rbp-10h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+10h]
     27: mov     [rbp-18h],rax
     2b: mov     byte ptr [rbp-29h],1
     2f: test    byte ptr [rbp-29h],0FFh
     33: je      8Ah
     35: mov     rax,[rbp-8]
     39: mov     [rbp-20h],rax
     3d: mov     rax,[rbp-10h]
     41: mov     [rbp-28h],rax
     45: mov     rax,[rbp-20h]
     49: mov     [rbp-60h],rax
     4d: mov     rax,[rbp-28h]
     51: mov     [rbp-58h],rax
     55: mov     qword ptr [rbp-50h],4
     5d: mov     qword ptr [rbp-48h],4
     65: mov     rax,[rbp-18h]
     69: mov     [rbp-40h],rax
     6d: mov     edi,0FFFFFFC8h
     72: lea     rsi,[k0]
     79: call    ryo_h_AddrAbs
     7e: call    fn1
     83: nop     [rcx]
     8a: imul    rax,[rbp-18h],4
     8f: mov     [rbp-30h],rax
     93: mov     edi,0FFFFFFF0h
     98: mov     esi,0FFFFFFF8h
     9d: mov     edx,0FFFFFFD0h
     a2: call    ryo_h_Memcpy
     a7: xor     edi,edi
     a9: xor     esi,esi
     ab: call    ryo_h_Ret
     b0: leave
     b1: ret

fn <core::slice::sort::stable::merge::MergeState<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-20h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     rax,[rax]
     1e: mov     [rbp-8],rax
     22: mov     [rbp-28h],rax
     26: mov     rax,[rbp-20h]
     2a: mov     [rbp-30h],rax
     2e: mov     byte ptr [rbp-41h],1
     32: test    byte ptr [rbp-41h],0FFh
     36: je      0ABh
     38: jmp     6Eh
     3a: nop     [rax+rax]
     40: mov     rax,[rbp+10h]
     44: mov     rax,[rax]
     47: mov     [rbp-10h],rax
     4b: mov     [rbp-20h],rax
     4f: mov     rax,[rbp+10h]
     53: mov     rax,[rax+10h]
     57: mov     [rbp-28h],rax
     5b: mov     byte ptr [rbp-41h],1
     5f: test    byte ptr [rbp-41h],0FFh
     63: je      1D0h
     69: jmp     17Bh
     6e: mov     rax,[rbp-20h]
     72: mov     [rbp-38h],rax
     76: mov     rax,[rbp-8]
     7a: mov     [rbp-40h],rax
     7e: mov     rax,[rbp-38h]
     82: mov     [rbp-80h],rax
     86: mov     rax,[rbp-40h]
     8a: mov     [rbp-78h],rax
     8e: mov     edi,0FFFFFF90h
     93: lea     rsi,[k0]
     9a: call    ryo_h_AddrAbs
     9f: call    fn1
     a4: nop     [rcx-10h]
     ab: mov     qword ptr [rbp-48h],0
     b3: cmp     qword ptr [rbp-48h],8
     b8: setb    [rbp-31h]
     bc: test    byte ptr [rbp-31h],0FFh
     c0: je      112h
     c2: mov     qword ptr [rbp-48h],8
     ca: mov     rax,[rbp-48h]
     ce: mov     rcx,7FFFFFFFFFFFFFFFh
     d8: cmp     rax,rcx
     db: setbe   [rbp-32h]
     df: test    byte ptr [rbp-32h],0FFh
     e3: je      112h
     e5: mov     rax,[rbp-30h]
     e9: sub     rax,[rbp-28h]
     ed: mov     [rbp-18h],rax
     f1: mov     qword ptr [rbp-48h],8
     f9: mov     edi,0FFFFFFE8h
     fe: mov     esi,0FFFFFFE8h
    103: mov     edx,0FFFFFFB8h
    108: call    ryo_h_DivUW64
    10d: jmp     40h
    112: mov     edi,0FFFFFF80h
    117: lea     rsi,[k2]
    11e: call    ryo_h_AddrAbs
    123: mov     qword ptr [rbp-78h],49h
    12b: mov     edi,0FFFFFF90h
    130: lea     rsi,[k3]
    137: call    ryo_h_AddrAbs
    13c: lea     rdi,[sym4]
    143: lea     rsi,[site5]
    14a: mov     edx,0FFFFFFB8h
    14f: call    ryo_h_CallExt
    154: test    rax,rax
    157: je      164h
    159: call    rax
    15b: nop     [rcx-10h]
    162: jmp     174h
    164: mov     rdi,rbp
    167: lea     rsi,[ro+4]
    16e: call    qword ptr [sym6]
    174: call    ryo_h_Unreachable
    179: ud2
    17b: mov     rax,[rbp-10h]
    17f: mov     [rbp-30h],rax
    183: mov     rax,[rbp-28h]
    187: mov     [rbp-38h],rax
    18b: mov     rax,[rbp-30h]
    18f: mov     [rbp-80h],rax
    193: mov     rax,[rbp-38h]
    197: mov     [rbp-78h],rax
    19b: mov     qword ptr [rbp-70h],8
    1a3: mov     qword ptr [rbp-68h],4
    1ab: mov     rax,[rbp-18h]
    1af: mov     [rbp-60h],rax
    1b3: mov     edi,0FFFFFFA8h
    1b8: lea     rsi,[k7]
    1bf: call    ryo_h_AddrAbs
    1c4: call    fn8
    1c9: nop     [rcx-10h]
    1d0: imul    rax,[rbp-18h],8
    1d5: mov     [rbp-48h],rax
    1d9: mov     edi,0FFFFFFD8h
    1de: mov     esi,0FFFFFFE0h
    1e3: mov     edx,0FFFFFFB8h
    1e8: call    ryo_h_Memcpy
    1ed: xor     edi,edi
    1ef: xor     esi,esi
    1f1: call    ryo_h_Ret
    1f6: leave
    1f7: ret

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax]
     1f: mov     [rbp-18h],rax
     23: mov     byte ptr [rbp-29h],1
     27: test    byte ptr [rbp-29h],0FFh
     2b: je      82h
     2d: mov     rax,[rbp-8]
     31: mov     [rbp-20h],rax
     35: mov     rax,[rbp-18h]
     39: mov     [rbp-28h],rax
     3d: mov     rax,[rbp-20h]
     41: mov     [rbp-70h],rax
     45: mov     rax,[rbp-28h]
     49: mov     [rbp-68h],rax
     4d: mov     qword ptr [rbp-60h],4
     55: mov     qword ptr [rbp-58h],4
     5d: mov     qword ptr [rbp-50h],1
     65: mov     edi,0FFFFFFB8h
     6a: lea     rsi,[k0]
     71: call    ryo_h_AddrAbs
     76: call    fn1
     7b: nop     [rcx-8]
     82: mov     qword ptr [rbp-30h],1
     8a: imul    rax,[rbp-30h],4
     8f: mov     [rbp-38h],rax
     93: mov     edi,0FFFFFFE8h
     98: mov     esi,0FFFFFFF0h
     9d: mov     edx,0FFFFFFC8h
     a2: call    ryo_h_Memcpy
     a7: xor     edi,edi
     a9: xor     esi,esi
     ab: call    ryo_h_Ret
     b0: leave
     b1: ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
      0: push    rbp
      1: mov     rbp,rsp
      4: mov     edi,10h
      9: lea     rsi,[site0]
     10: call    ryo_h_CallInd
     15: test    rax,rax
     18: je      25h
     1a: call    rax
     1c: nop     [rcx]
     23: jmp     35h
     25: mov     rdi,rbp
     28: lea     rsi,[ro+4]
     2f: call    qword ptr [sym1]
     35: xor     edi,edi
     37: xor     esi,esi
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+20h]
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp-18h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp-10h]
     24: mov     [rbp-28h],rax
     28: call    fn0
     2d: nop     [rcx-1]
     34: mov     edi,0FFFFFFFFh
     39: mov     esi,1
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <std::alloc::Global as std::clone::Clone>::clone
      0: push    rbp
      1: mov     rbp,rsp
      4: xor     edi,edi
      6: xor     esi,esi
      8: call    ryo_h_Ret
      d: leave
      e: ret

fn <std::array::IntoIter<usize, 2> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-21h],0
      c: test    byte ptr [rbp-21h],0FFh
     10: je      50h
     12: mov     rax,[rbp+10h]
     16: mov     [rbp-20h],rax
     1a: mov     [rbp-30h],rax
     1e: mov     edi,0FFFFFFD8h
     23: lea     rsi,[sym0]
     2a: call    ryo_h_AddrSym
     2f: mov     rdi,rbp
     32: lea     rsi,[ro+4]
     39: call    qword ptr [sym1]
     3f: jmp     5Bh
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: jmp     50h

fn <std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-10h],rax
     17: mov     [rbp-20h],rax
     1b: mov     edi,0FFFFFFE8h
     20: lea     rsi,[sym0]
     27: call    ryo_h_AddrSym
     2c: mov     rdi,rbp
     2f: lea     rsi,[ro+4]
     36: call    qword ptr [sym1]
     3c: xor     edi,edi
     3e: xor     esi,esi
     40: call    ryo_h_Ret
     45: leave
     46: ret

fn <std::hint::select_unpredictable::DropOnPanic<*const u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-10h],rax
     17: mov     [rbp-20h],rax
     1b: mov     edi,0FFFFFFE8h
     20: lea     rsi,[sym0]
     27: call    ryo_h_AddrSym
     2c: mov     rdi,rbp
     2f: lea     rsi,[ro+4]
     36: call    qword ptr [sym1]
     3c: xor     edi,edi
     3e: xor     esi,esi
     40: call    ryo_h_Ret
     45: leave
     46: ret

fn <std::hint::select_unpredictable::DropOnPanic<*mut u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-10h],rax
     17: mov     [rbp-20h],rax
     1b: mov     edi,0FFFFFFE8h
     20: lea     rsi,[sym0]
     27: call    ryo_h_AddrSym
     2c: mov     rdi,rbp
     2f: lea     rsi,[ro+4]
     36: call    qword ptr [sym1]
     3c: xor     edi,edi
     3e: xor     esi,esi
     40: call    ryo_h_Ret
     45: leave
     46: ret

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+8]
     13: mov     [rbp-30h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     rax,[rax]
     1e: mov     [rbp-60h],rax
     22: mov     [rbp-58h],rax
     26: mov     rax,[rbp+20h]
     2a: mov     [rbp-50h],rax
     2e: mov     rax,[rbp+18h]
     32: mov     [rbp-48h],rax
     36: mov     edi,0FFFFFFC0h
     3b: mov     esi,0FFFFFFA8h
     40: call    ryo_h_MovW128
     45: mov     rax,[rbp-30h]
     49: mov     [rbp-90h],rax
     50: mov     rax,[rbp-48h]
     54: mov     [rbp-88h],rax
     5b: mov     edi,0FFFFFF80h
     60: mov     esi,0FFFFFFC0h
     65: call    ryo_h_MovW128
     6a: call    fn0
     6f: nop     [rcx-28h]
     76: mov     rax,[rbp+10h]
     7a: mov     rax,[rax]
     7d: mov     [rbp-68h],rax
     81: mov     qword ptr [rbp-70h],1
     89: mov     edi,0FFFFFFE8h
     8e: mov     esi,0FFFFFFF0h
     93: mov     edx,0FFFFFF98h
     98: mov     ecx,0FFFFFF90h
     9d: call    ryo_h_AddOvfUW64
     a2: test    byte ptr [rbp-10h],0FFh
     a6: je      0F8h
     a8: mov     edi,0FFFFFF70h
     ad: lea     rsi,[k1]
     b4: call    ryo_h_AddrAbs
     b9: lea     rdi,[sym2]
     c0: lea     rsi,[site3]
     c7: mov     edx,0FFFFFF98h
     cc: call    ryo_h_CallExt
     d1: test    rax,rax
     d4: je      0E1h
     d6: call    rax
     d8: nop     [rcx-60h]
     df: jmp     0F1h
     e1: mov     rdi,rbp
     e4: lea     rsi,[ro+4]
     eb: call    qword ptr [sym4]
     f1: call    ryo_h_Unreachable
     f6: ud2
     f8: mov     rax,[rbp+10h]
     fc: mov     rcx,[rbp-18h]
    100: mov     [rax],rcx
    103: mov     rax,[rbp-28h]
    107: mov     [rbp-8],rax
    10b: mov     edi,0FFFFFFF8h
    110: mov     esi,8
    115: call    ryo_h_Ret
    11a: leave
    11b: ret
    11c: nop     [rax]
    120: mov     edi,0FFFFFFE0h
    125: call    ryo_h_Resume
    12a: ud2
    12c: mov     rdi,rax
    12f: mov     esi,0FFFFFFE0h
    134: call    ryo_h_Lpad
    139: jmp     120h

fn <std::iter::Enumerate<std::slice::Iter<'_, u32>> as std::iter::Iterator>::fold::<u64, {closure@bench/sort.rs:46:37: 46:51}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+20h]
     1b: mov     [rbp-28h],rax
     1f: mov     [rbp-20h],rax
     23: mov     edi,0FFFFFFB0h
     28: mov     esi,0FFFFFFE8h
     2d: call    ryo_h_MovW128
     32: mov     rax,[rbp+28h]
     36: mov     [rbp-40h],rax
     3a: mov     rax,[rbp-20h]
     3e: mov     [rbp-38h],rax
     42: call    fn0
     47: nop     [rcx-8]
     4e: mov     edi,0FFFFFFF8h
     53: mov     esi,8
     58: call    ryo_h_Ret
     5d: leave
     5e: ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::IntoIterator>::into_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,10h
     12: mov     edx,18h
     17: call    ryo_h_Copy
     1c: mov     edi,0FFFFFFE8h
     21: mov     esi,18h
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::collect::<std::vec::Vec<u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     edi,0FFFFFF50h
     10: mov     esi,10h
     15: mov     edx,18h
     1a: call    ryo_h_Copy
     1f: call    fn0
     24: nop     [rcx-18h]
     2b: mov     edi,0FFFFFFE8h
     30: mov     esi,18h
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,18h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-38h],rax
     1f: mov     edi,0FFFFFFD0h
     24: mov     esi,28h
     29: mov     edx,18h
     2e: call    ryo_h_Copy
     33: mov     rax,[rbp-38h]
     37: mov     [rbp-18h],rax
     3b: mov     edi,0FFFFFF90h
     40: mov     esi,0FFFFFFF0h
     45: call    ryo_h_MovW128
     4a: mov     edi,0FFFFFFA0h
     4f: mov     esi,0FFFFFFD0h
     54: mov     edx,20h
     59: call    ryo_h_Copy
     5e: call    fn0
     63: nop     [rcx]
     6a: xor     edi,edi
     6c: xor     esi,esi
     6e: call    ryo_h_Ret
     73: leave
     74: ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,28h
     12: mov     edx,18h
     17: call    ryo_h_Copy
     1c: mov     edi,0FFFFFFB0h
     21: mov     esi,10h
     26: mov     edx,18h
     2b: call    ryo_h_Copy
     30: mov     edi,0FFFFFFC8h
     35: mov     esi,0FFFFFFE8h
     3a: mov     edx,18h
     3f: call    ryo_h_Copy
     44: call    fn0
     49: nop     [rcx]
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-30h],rax
     18: call    fn0
     1d: nop     [rcx-18h]
     24: mov     edi,0FFFFFFE8h
     29: mov     esi,18h
     2e: call    ryo_h_Ret
     33: leave
     34: ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::IntoIterator>::into_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFF0h
     1c: mov     esi,10h
     21: call    ryo_h_Ret
     26: leave
     27: ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::collect::<std::vec::Vec<(u32, u32)>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     edi,0FFFFFF60h
     10: mov     esi,10h
     15: call    ryo_h_MovW128
     1a: call    fn0
     1f: nop     [rcx-18h]
     26: mov     edi,0FFFFFFE8h
     2b: mov     esi,18h
     30: call    ryo_h_Ret
     35: leave
     36: ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFD8h
     1c: mov     esi,20h
     21: mov     edx,18h
     26: call    ryo_h_Copy
     2b: mov     edi,0FFFFFFB0h
     30: mov     esi,0FFFFFFF0h
     35: call    ryo_h_MovW128
     3a: mov     edi,0FFFFFFC0h
     3f: mov     esi,0FFFFFFD8h
     44: mov     edx,18h
     49: call    ryo_h_Copy
     4e: call    fn0
     53: nop     [rcx]
     5a: xor     edi,edi
     5c: xor     esi,esi
     5e: call    ryo_h_Ret
     63: leave
     64: ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,20h
     12: mov     edx,18h
     17: call    ryo_h_Copy
     1c: mov     edi,0FFFFFFC0h
     21: mov     esi,10h
     26: call    ryo_h_MovW128
     2b: mov     edi,0FFFFFFD0h
     30: mov     esi,0FFFFFFE8h
     35: mov     edx,18h
     3a: call    ryo_h_Copy
     3f: call    fn0
     44: nop     [rcx]
     4b: xor     edi,edi
     4d: xor     esi,esi
     4f: call    ryo_h_Ret
     54: leave
     55: ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     [rbp-30h],rax
     14: call    fn0
     19: nop     [rcx-18h]
     20: mov     edi,0FFFFFFE8h
     25: mov     esi,18h
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFF0h
     1c: mov     esi,10h
     21: call    ryo_h_Ret
     26: leave
     27: ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     byte ptr [rbp-9],1
      c: nop     [rax]
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-30h],rax
     18: mov     [rbp-60h],rax
     1c: call    fn0
     21: nop     [rcx-28h]
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-8],rax
     30: mov     edi,0FFFFFFF8h
     35: xor     esi,esi
     37: mov     edx,2
     3c: call    ryo_h_SwitchDenseW64
     41: lea     rcx,[54h]
     48: movsxd  rax,[rcx+rax*4]
     4c: add     rax,rcx
     4f: jmp     rax
     51: int3
     52: int3
     53: int3
     54: .long   a1h
     58: .long   60h
     5c: .long   118h
     60: mov     rax,[rbp-20h]
     64: mov     [rbp-30h],rax
     68: lea     rax,[rbp+20h]
     6c: mov     [rbp-38h],rax
     70: mov     byte ptr [rbp-9],0
     74: mov     rax,[rbp-30h]
     78: mov     [rbp-40h],rax
     7c: mov     rax,[rbp-38h]
     80: mov     [rbp-60h],rax
     84: mov     rax,[rbp-40h]
     88: mov     [rbp-58h],rax
     8c: call    fn1
     91: nop     [rcx-8]
     98: mov     byte ptr [rbp-9],1
     9c: jmp     10h
     a1: lea     rax,[rbp+20h]
     a5: mov     [rbp-48h],rax
     a9: mov     [rbp-60h],rax
     ad: call    fn2
     b2: nop     [rcx-48h]
     b9: xor     edi,edi
     bb: xor     esi,esi
     bd: call    ryo_h_Ret
     c2: leave
     c3: ret
     c4: nop     [rax+rax]
     cd: nop     [rax]
     d0: lea     rax,[rbp+20h]
     d4: mov     [rbp-48h],rax
     d8: mov     [rbp-60h],rax
     dc: call    fn3
     e1: nop     [rcx-48h]
     e8: nop     [rax+rax]
     f0: mov     edi,0FFFFFFE8h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: nop     [rax]
    100: jmp     0D0h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: test    byte ptr [rbp-9],0FFh
    114: je      0D0h
    116: jmp     100h
    118: call    ryo_h_Unreachable
    11d: ud2
    11f: nop
    120: lea     rdi,[sym4]
    127: lea     rsi,[site5]
    12e: mov     edx,0FFFFFFB8h
    133: call    ryo_h_CallExt
    138: test    rax,rax
    13b: je      148h
    13d: call    rax
    13f: nop     [rcx-40h]
    146: jmp     158h
    148: mov     rdi,rbp
    14b: lea     rsi,[ro+4]
    152: call    qword ptr [sym6]
    158: call    ryo_h_Unreachable
    15d: ud2
    15f: mov     rdi,rax
    162: mov     esi,0FFFFFFE8h
    167: call    ryo_h_Lpad
    16c: jmp     110h
    16e: mov     rdi,rax
    171: mov     esi,0FFFFFFE8h
    176: call    ryo_h_Lpad
    17b: jmp     0F0h
    180: mov     rdi,rax
    183: mov     esi,0FFFFFFE8h
    188: call    ryo_h_Lpad
    18d: jmp     120h

fn <std::ops::Range<usize> as std::iter::Iterator>::map::<u32, {closure@bench/sort.rs:52:37: 52:40}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+20h]
     1b: mov     [rbp-18h],rax
     1f: mov     edi,0FFFFFFE8h
     24: mov     esi,18h
     29: call    ryo_h_Ret
     2e: leave
     2f: ret

fn <std::ops::Range<usize> as std::iter::range::RangeIteratorImpl>::spec_next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+8]
     18: mov     [rbp-28h],rax
     1c: mov     rax,[rbp-20h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-28h]
     28: mov     [rbp-38h],rax
     2c: call    fn0
     31: nop     [rcx-11h]
     38: test    byte ptr [rbp-11h],0FFh
     3c: je      7Eh
     3e: mov     rax,[rbp+10h]
     42: mov     rax,[rax]
     45: mov     [rbp-20h],rax
     49: mov     [rbp-40h],rax
     4d: mov     qword ptr [rbp-38h],1
     55: call    fn1
     5a: nop     [rcx-28h]
     61: mov     rax,[rbp+10h]
     65: mov     rcx,[rbp-28h]
     69: mov     [rax],rcx
     6c: mov     rax,[rbp-20h]
     70: mov     [rbp-8],rax
     74: mov     qword ptr [rbp-10h],1
     7c: jmp     86h
     7e: mov     qword ptr [rbp-10h],0
     86: mov     edi,0FFFFFFF0h
     8b: mov     esi,10h
     90: call    ryo_h_Ret
     95: leave
     96: ret

fn <std::ops::Range<usize> as std::slice::SliceIndex<[T]>>::get_unchecked_mut::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jb      2Ah
     15: mov     rax,[rbp+20h]
     19: cmp     rax,[rbp+18h]
     1d: jb      2Ah
     1f: xor     edi,edi
     21: xor     esi,esi
     23: call    ryo_h_Ret
     28: leave
     29: ret
     2a: mov     edi,0FFFFFFF0h
     2f: lea     rsi,[k0]
     36: call    ryo_h_AddrAbs
     3b: mov     qword ptr [rbp-8],0DAh
     43: mov     rax,[rbp-10h]
     47: mov     [rbp-48h],rax
     4b: mov     rax,[rbp-8]
     4f: mov     [rbp-40h],rax
     53: mov     rax,[rbp-48h]
     57: mov     [rbp-38h],rax
     5b: mov     [rbp-30h],rax
     5f: mov     edi,0FFFFFFA0h
     64: lea     rsi,[k1]
     6b: call    ryo_h_AddrAbs
     70: mov     qword ptr [rbp-58h],0DAh
     78: mov     rax,[rbp-58h]
     7c: mov     [rbp-50h],rax
     80: shl     rax,1
     84: mov     [rbp-48h],rax
     88: or      rax,1
     8c: mov     [rbp-40h],rax
     90: mov     [rbp-38h],rax
     94: mov     rax,[rbp-30h]
     98: mov     [rbp-28h],rax
     9c: mov     rax,[rbp-38h]
     a0: mov     [rbp-20h],rax
     a4: mov     edi,0FFFFFF70h
     a9: mov     esi,0FFFFFFD8h
     ae: call    ryo_h_MovW128
     b3: mov     byte ptr [rbp-80h],0
     b7: mov     rax,[rbp+28h]
     bb: mov     [rbp-78h],rax
     bf: lea     rdi,[sym2]
     c6: lea     rsi,[site3]
     cd: mov     edx,0FFFFFF98h
     d2: call    ryo_h_CallExt
     d7: test    rax,rax
     da: je      0E7h
     dc: call    rax
     de: nop     [rcx-10h]
     e5: jmp     0F7h
     e7: mov     rdi,rbp
     ea: lea     rsi,[ro+4]
     f1: call    qword ptr [sym4]
     f7: call    ryo_h_Unreachable
     fc: ud2

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+28h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+20h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-18h]
     1f: cmp     rax,[rbp-20h]
     23: jb      103h
     29: jmp     105h
     2e: xchg    ax,ax
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-60h],rax
     38: mov     rax,[rbp+18h]
     3c: mov     [rbp-58h],rax
     40: mov     rax,[rbp-60h]
     44: mov     [rbp-68h],rax
     48: imul    rcx,[rbp-20h],4
     4d: add     rax,rcx
     50: mov     [rbp-70h],rax
     54: mov     [rbp-50h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-48h],rax
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-10h],rax
     68: mov     rax,[rbp-48h]
     6c: mov     [rbp-8],rax
     70: mov     edi,0FFFFFFF0h
     75: mov     esi,10h
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     rax,[rbp+18h]
     94: mov     [rbp-28h],rax
     98: mov     rax,[rbp-20h]
     9c: mov     [rbp-0A0h],rax
     a3: mov     rax,[rbp-18h]
     a7: mov     [rbp-98h],rax
     ae: mov     rax,[rbp-28h]
     b2: mov     [rbp-90h],rax
     b9: mov     rax,[rbp+30h]
     bd: mov     [rbp-88h],rax
     c4: lea     rdi,[sym0]
     cb: lea     rsi,[site1]
     d2: mov     edx,0FFFFFF88h
     d7: call    ryo_h_CallExt
     dc: test    rax,rax
     df: je      0ECh
     e1: call    rax
     e3: nop     [rcx-20h]
     ea: jmp     0FCh
     ec: mov     rdi,rbp
     ef: lea     rsi,[ro+4]
     f6: call    qword ptr [sym2]
     fc: call    ryo_h_Unreachable
    101: ud2
    103: jmp     90h
    105: mov     rax,[rbp-18h]
    109: sub     rax,[rbp-20h]
    10d: mov     [rbp-40h],rax
    111: mov     [rbp-28h],rax
    115: mov     qword ptr [rbp-30h],1
    11d: mov     [rbp-38h],rax
    121: mov     rax,[rbp+18h]
    125: mov     [rbp-48h],rax
    129: cmp     rax,[rbp-18h]
    12d: jae     30h
    133: jmp     90h

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+28h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+20h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-18h]
     1f: cmp     rax,[rbp-20h]
     23: jb      103h
     29: jmp     105h
     2e: xchg    ax,ax
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-60h],rax
     38: mov     rax,[rbp+18h]
     3c: mov     [rbp-58h],rax
     40: mov     rax,[rbp-60h]
     44: mov     [rbp-68h],rax
     48: imul    rcx,[rbp-20h],4
     4d: add     rax,rcx
     50: mov     [rbp-70h],rax
     54: mov     [rbp-50h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-48h],rax
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-10h],rax
     68: mov     rax,[rbp-48h]
     6c: mov     [rbp-8],rax
     70: mov     edi,0FFFFFFF0h
     75: mov     esi,10h
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     rax,[rbp+18h]
     94: mov     [rbp-28h],rax
     98: mov     rax,[rbp-20h]
     9c: mov     [rbp-0A0h],rax
     a3: mov     rax,[rbp-18h]
     a7: mov     [rbp-98h],rax
     ae: mov     rax,[rbp-28h]
     b2: mov     [rbp-90h],rax
     b9: mov     rax,[rbp+30h]
     bd: mov     [rbp-88h],rax
     c4: lea     rdi,[sym0]
     cb: lea     rsi,[site1]
     d2: mov     edx,0FFFFFF88h
     d7: call    ryo_h_CallExt
     dc: test    rax,rax
     df: je      0ECh
     e1: call    rax
     e3: nop     [rcx-20h]
     ea: jmp     0FCh
     ec: mov     rdi,rbp
     ef: lea     rsi,[ro+4]
     f6: call    qword ptr [sym2]
     fc: call    ryo_h_Unreachable
    101: ud2
    103: jmp     90h
    105: mov     rax,[rbp-18h]
    109: sub     rax,[rbp-20h]
    10d: mov     [rbp-40h],rax
    111: mov     [rbp-28h],rax
    115: mov     qword ptr [rbp-30h],1
    11d: mov     [rbp-38h],rax
    121: mov     rax,[rbp+18h]
    125: mov     [rbp-48h],rax
    129: cmp     rax,[rbp-18h]
    12d: jae     30h
    133: jmp     90h

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: cmp     rax,[rbp-18h]
     1f: jae     80h
     21: mov     rax,[rbp-18h]
     25: mov     [rbp-80h],rax
     29: mov     rax,[rbp-20h]
     2d: mov     [rbp-78h],rax
     31: mov     rax,[rbp-20h]
     35: mov     [rbp-70h],rax
     39: mov     rax,[rbp+28h]
     3d: mov     [rbp-68h],rax
     41: lea     rdi,[sym0]
     48: lea     rsi,[site1]
     4f: mov     edx,0FFFFFFA0h
     54: call    ryo_h_CallExt
     59: test    rax,rax
     5c: je      69h
     5e: call    rax
     60: nop     [rcx-20h]
     67: jmp     79h
     69: mov     rdi,rbp
     6c: lea     rsi,[ro+4]
     73: call    qword ptr [sym2]
     79: call    ryo_h_Unreachable
     7e: ud2
     80: mov     rax,[rbp-20h]
     84: sub     rax,[rbp-18h]
     88: mov     [rbp-28h],rax
     8c: mov     rax,[rbp+10h]
     90: mov     [rbp-48h],rax
     94: mov     rax,[rbp+18h]
     98: mov     [rbp-40h],rax
     9c: mov     rax,[rbp-48h]
     a0: mov     [rbp-50h],rax
     a4: imul    rcx,[rbp-18h],4
     a9: add     rax,rcx
     ac: mov     [rbp-58h],rax
     b0: mov     [rbp-38h],rax
     b4: mov     rax,[rbp-28h]
     b8: mov     [rbp-30h],rax
     bc: mov     rax,[rbp-38h]
     c0: mov     [rbp-10h],rax
     c4: mov     rax,[rbp-30h]
     c8: mov     [rbp-8],rax
     cc: mov     edi,0FFFFFFF0h
     d1: mov     esi,10h
     d6: call    ryo_h_Ret
     db: leave
     dc: ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: cmp     rax,[rbp-18h]
     1f: jae     80h
     21: mov     rax,[rbp-18h]
     25: mov     [rbp-80h],rax
     29: mov     rax,[rbp-20h]
     2d: mov     [rbp-78h],rax
     31: mov     rax,[rbp-20h]
     35: mov     [rbp-70h],rax
     39: mov     rax,[rbp+28h]
     3d: mov     [rbp-68h],rax
     41: lea     rdi,[sym0]
     48: lea     rsi,[site1]
     4f: mov     edx,0FFFFFFA0h
     54: call    ryo_h_CallExt
     59: test    rax,rax
     5c: je      69h
     5e: call    rax
     60: nop     [rcx-20h]
     67: jmp     79h
     69: mov     rdi,rbp
     6c: lea     rsi,[ro+4]
     73: call    qword ptr [sym2]
     79: call    ryo_h_Unreachable
     7e: ud2
     80: mov     rax,[rbp-20h]
     84: sub     rax,[rbp-18h]
     88: mov     [rbp-28h],rax
     8c: mov     rax,[rbp+10h]
     90: mov     [rbp-48h],rax
     94: mov     rax,[rbp+18h]
     98: mov     [rbp-40h],rax
     9c: mov     rax,[rbp-48h]
     a0: mov     [rbp-50h],rax
     a4: imul    rcx,[rbp-18h],4
     a9: add     rax,rcx
     ac: mov     [rbp-58h],rax
     b0: mov     [rbp-38h],rax
     b4: mov     rax,[rbp-28h]
     b8: mov     [rbp-30h],rax
     bc: mov     rax,[rbp-38h]
     c0: mov     [rbp-10h],rax
     c4: mov     rax,[rbp-30h]
     c8: mov     [rbp-8],rax
     cc: mov     edi,0FFFFFFF0h
     d1: mov     esi,10h
     d6: call    ryo_h_Ret
     db: leave
     dc: ret

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-28h],rax
     10: mov     qword ptr [rbp-20h],0
     18: mov     [rbp-18h],rax
     1c: mov     edi,0FFFFFFC0h
     21: mov     esi,0FFFFFFE0h
     26: call    ryo_h_MovW128
     2b: mov     edi,0FFFFFFB0h
     30: mov     esi,10h
     35: call    ryo_h_MovW128
     3a: mov     rax,[rbp+28h]
     3e: mov     [rbp-30h],rax
     42: call    fn0
     47: nop     [rcx-10h]
     4e: mov     edi,0FFFFFFF0h
     53: mov     esi,10h
     58: call    ryo_h_Ret
     5d: leave
     5e: ret

fn <std::slice::Iter<'_, u32> as std::iter::IntoIterator>::into_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFF0h
     1c: mov     esi,10h
     21: call    ryo_h_Ret
     26: leave
     27: ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::enumerate
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     qword ptr [rbp-8],0
     1f: mov     edi,0FFFFFFE8h
     24: mov     esi,18h
     29: call    ryo_h_Ret
     2e: leave
     2f: ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     byte ptr [rbp-79h],0
      f: test    byte ptr [rbp-79h],0FFh
     13: je      2Bh
     15: mov     rax,[rbp+18h]
     19: mov     [rbp-50h],rax
     1d: mov     [rbp-48h],rax
     21: cmp     rax,0
     25: sete    [rbp-39h]
     29: jmp     57h
     2b: mov     rax,[rbp+18h]
     2f: mov     [rbp-50h],rax
     33: mov     [rbp-48h],rax
     37: mov     rax,[rbp+10h]
     3b: mov     [rbp-58h],rax
     3f: mov     [rbp-50h],rax
     43: mov     rax,[rbp-48h]
     47: mov     [rbp-58h],rax
     4b: mov     rax,[rbp-50h]
     4f: cmp     rax,[rbp-58h]
     53: sete    [rbp-39h]
     57: test    byte ptr [rbp-39h],0FFh
     5b: je      81h
     5d: mov     byte ptr [rbp-2Ah],0
     61: lea     rax,[rbp+20h]
     65: mov     [rbp-80h],rax
     69: mov     [rbp-0A0h],rax
     70: call    fn0
     75: nop     [rcx-80h]
     7c: jmp     195h
     81: mov     byte ptr [rbp-2Ah],0
     85: mov     byte ptr [rbp-29h],1
     89: mov     qword ptr [rbp-18h],0
     91: mov     byte ptr [rbp-79h],0
     95: test    byte ptr [rbp-79h],0FFh
     99: je      0A9h
     9b: mov     rax,[rbp+18h]
     9f: mov     [rbp-40h],rax
     a3: mov     [rbp-20h],rax
     a7: jmp     0F0h
     a9: mov     rax,[rbp+18h]
     ad: mov     [rbp-48h],rax
     b1: mov     [rbp-40h],rax
     b5: mov     rax,[rbp+10h]
     b9: mov     [rbp-48h],rax
     bd: mov     rax,[rbp-40h]
     c1: mov     [rbp-50h],rax
     c5: mov     rax,[rbp-48h]
     c9: mov     [rbp-58h],rax
     cd: mov     rax,[rbp-40h]
     d1: mov     [rbp-60h],rax
     d5: mov     byte ptr [rbp-79h],1
     d9: test    byte ptr [rbp-79h],0FFh
     dd: je      258h
     e3: jmp     215h
     e8: nop     [rax+rax]
     f0: lea     rax,[rbp+20h]
     f4: mov     [rbp-40h],rax
     f8: mov     byte ptr [rbp-29h],0
     fc: mov     rax,[rbp+10h]
    100: mov     [rbp-60h],rax
    104: mov     rax,[rbp-18h]
    108: mov     [rbp-68h],rax
    10c: mov     rax,[rbp-60h]
    110: mov     [rbp-78h],rax
    114: imul    rcx,[rbp-68h],4
    119: add     rax,rcx
    11c: mov     [rbp-70h],rax
    120: mov     [rbp-58h],rax
    124: mov     [rbp-50h],rax
    128: mov     [rbp-28h],rax
    12c: mov     [rbp-48h],rax
    130: mov     rax,[rbp-40h]
    134: mov     [rbp-0A0h],rax
    13b: mov     rax,[rbp-48h]
    13f: mov     [rbp-98h],rax
    146: call    fn1
    14b: nop     [rcx-20h]
    152: mov     byte ptr [rbp-79h],1
    156: test    byte ptr [rbp-79h],0FFh
    15a: je      35Eh
    160: jmp     32Bh
    165: nop     [rax+rax]
    16e: xchg    ax,ax
    170: lea     rax,[rbp+20h]
    174: mov     [rbp-80h],rax
    178: mov     [rbp-0A0h],rax
    17f: call    fn2
    184: nop     [rcx-80h]
    18b: jmp     195h
    18d: nop     [rax]
    190: jmp     0F0h
    195: xor     edi,edi
    197: xor     esi,esi
    199: call    ryo_h_Ret
    19e: leave
    19f: ret
    1a0: lea     rax,[rbp+20h]
    1a4: mov     [rbp-80h],rax
    1a8: mov     [rbp-0A0h],rax
    1af: call    fn3
    1b4: nop     [rcx-80h]
    1bb: jmp     200h
    1bd: nop     [rax]
    1c0: mov     edi,0FFFFFFC8h
    1c5: call    ryo_h_Resume
    1ca: ud2
    1cc: nop     [rax]
    1d0: jmp     1A0h
    1d2: nop     [rax+rax]
    1db: nop     [rax+rax]
    1e0: test    byte ptr [rbp-29h],0FFh
    1e4: je      1A0h
    1e6: jmp     1D0h
    1e8: nop     [rax+rax]
    1f0: jmp     1C0h
    1f2: nop     [rax+rax]
    1fb: nop     [rax+rax]
    200: test    byte ptr [rbp-2Ah],0FFh
    204: je      1C0h
    206: jmp     1F0h
    208: nop     [rax+rax]
    210: jmp     0F0h
    215: mov     rax,[rbp-40h]
    219: mov     [rbp-68h],rax
    21d: mov     rax,[rbp-48h]
    221: mov     [rbp-70h],rax
    225: mov     rax,[rbp-68h]
    229: mov     [rbp-0A0h],rax
    230: mov     rax,[rbp-70h]
    234: mov     [rbp-98h],rax
    23b: mov     edi,0FFFFFF70h
    240: lea     rsi,[k4]
    247: call    ryo_h_AddrAbs
    24c: call    fn5
    251: nop     [rcx-2Ah]
    258: mov     qword ptr [rbp-80h],0
    260: cmp     qword ptr [rbp-80h],4
    265: setb    [rbp-61h]
    269: test    byte ptr [rbp-61h],0FFh
    26d: je      2BFh
    26f: mov     qword ptr [rbp-80h],4
    277: mov     rax,[rbp-80h]
    27b: mov     rcx,7FFFFFFFFFFFFFFFh
    285: cmp     rax,rcx
    288: setbe   [rbp-62h]
    28c: test    byte ptr [rbp-62h],0FFh
    290: je      2BFh
    292: mov     rax,[rbp-60h]
    296: sub     rax,[rbp-58h]
    29a: mov     [rbp-20h],rax
    29e: mov     qword ptr [rbp-80h],4
    2a6: mov     edi,0FFFFFFE0h
    2ab: mov     esi,0FFFFFFE0h
    2b0: mov     edx,0FFFFFF80h
    2b5: call    ryo_h_DivUW64
    2ba: jmp     210h
    2bf: mov     edi,0FFFFFF60h
    2c4: lea     rsi,[k6]
    2cb: call    ryo_h_AddrAbs
    2d0: mov     qword ptr [rbp-98h],49h
    2db: mov     edi,0FFFFFF70h
    2e0: lea     rsi,[k7]
    2e7: call    ryo_h_AddrAbs
    2ec: lea     rdi,[sym8]
    2f3: lea     rsi,[site9]
    2fa: mov     edx,0FFFFFF80h
    2ff: call    ryo_h_CallExt
    304: test    rax,rax
    307: je      314h
    309: call    rax
    30b: nop     [rcx-2Ah]
    312: jmp     324h
    314: mov     rdi,rbp
    317: lea     rsi,[ro+4]
    31e: call    qword ptr [sym10]
    324: call    ryo_h_Unreachable
    329: ud2
    32b: mov     rax,[rbp-18h]
    32f: mov     [rbp-0A0h],rax
    336: mov     qword ptr [rbp-98h],1
    341: mov     edi,0FFFFFF70h
    346: lea     rsi,[k11]
    34d: call    ryo_h_AddrAbs
    352: call    fn12
    357: nop     [rcx-2Ah]
    35e: mov     rax,[rbp-18h]
    362: add     rax,1
    366: mov     [rbp-40h],rax
    36a: mov     [rbp-18h],rax
    36e: mov     [rbp-48h],rax
    372: mov     rax,[rbp-20h]
    376: mov     [rbp-50h],rax
    37a: mov     rax,[rbp-48h]
    37e: cmp     rax,[rbp-50h]
    382: je      170h
    388: jmp     190h
    38d: nop     [rax]
    390: lea     rdi,[sym13]
    397: lea     rsi,[site14]
    39e: mov     edx,0FFFFFF80h
    3a3: call    ryo_h_CallExt
    3a8: test    rax,rax
    3ab: je      3B8h
    3ad: call    rax
    3af: nop     [rcx-78h]
    3b6: jmp     3C8h
    3b8: mov     rdi,rbp
    3bb: lea     rsi,[ro+20]
    3c2: call    qword ptr [sym15]
    3c8: call    ryo_h_Unreachable
    3cd: ud2
    3cf: mov     rdi,rax
    3d2: mov     esi,0FFFFFFC8h
    3d7: call    ryo_h_Lpad
    3dc: jmp     200h
    3e1: mov     rdi,rax
    3e4: mov     esi,0FFFFFFC8h
    3e9: call    ryo_h_Lpad
    3ee: jmp     1E0h
    3f3: mov     rdi,rax
    3f6: mov     esi,0FFFFFFC8h
    3fb: call    ryo_h_Lpad
    400: jmp     390h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-0A1h],0
     12: test    byte ptr [rbp-0A1h],0FFh
     19: je      31h
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-58h],rax
     23: mov     [rbp-50h],rax
     27: cmp     rax,0
     2b: sete    [rbp-41h]
     2f: jmp     5Dh
     31: mov     rax,[rbp+18h]
     35: mov     [rbp-58h],rax
     39: mov     [rbp-50h],rax
     3d: mov     rax,[rbp+10h]
     41: mov     [rbp-60h],rax
     45: mov     [rbp-58h],rax
     49: mov     rax,[rbp-50h]
     4d: mov     [rbp-60h],rax
     51: mov     rax,[rbp-58h]
     55: cmp     rax,[rbp-60h]
     59: sete    [rbp-41h]
     5d: test    byte ptr [rbp-41h],0FFh
     61: je      74h
     63: mov     byte ptr [rbp-32h],0
     67: mov     rax,[rbp+20h]
     6b: mov     [rbp-8],rax
     6f: jmp     1C5h
     74: mov     byte ptr [rbp-32h],0
     78: mov     byte ptr [rbp-31h],1
     7c: mov     rax,[rbp+20h]
     80: mov     [rbp-48h],rax
     84: mov     qword ptr [rbp-20h],0
     8c: mov     byte ptr [rbp-0A1h],0
     93: test    byte ptr [rbp-0A1h],0FFh
     9a: je      0AAh
     9c: mov     rax,[rbp+18h]
     a0: mov     [rbp-50h],rax
     a4: mov     [rbp-28h],rax
     a8: jmp     0F0h
     aa: mov     rax,[rbp+18h]
     ae: mov     [rbp-58h],rax
     b2: mov     [rbp-50h],rax
     b6: mov     rax,[rbp+10h]
     ba: mov     [rbp-58h],rax
     be: mov     rax,[rbp-50h]
     c2: mov     [rbp-60h],rax
     c6: mov     rax,[rbp-58h]
     ca: mov     [rbp-68h],rax
     ce: mov     rax,[rbp-50h]
     d2: mov     [rbp-70h],rax
     d6: mov     byte ptr [rbp-0A1h],1
     dd: test    byte ptr [rbp-0A1h],0FFh
     e4: je      278h
     ea: jmp     235h
     ef: nop
     f0: lea     rax,[rbp+28h]
     f4: mov     [rbp-58h],rax
     f8: mov     byte ptr [rbp-31h],0
     fc: mov     rax,[rbp-48h]
    100: mov     [rbp-70h],rax
    104: mov     rax,[rbp+10h]
    108: mov     [rbp-88h],rax
    10f: mov     rax,[rbp-20h]
    113: mov     [rbp-90h],rax
    11a: mov     rax,[rbp-88h]
    121: mov     [rbp-0A0h],rax
    128: imul    rcx,[rbp-90h],4
    130: add     rax,rcx
    133: mov     [rbp-98h],rax
    13a: mov     [rbp-80h],rax
    13e: mov     [rbp-78h],rax
    142: mov     [rbp-30h],rax
    146: mov     rax,[rbp-70h]
    14a: mov     [rbp-68h],rax
    14e: mov     rax,[rbp-30h]
    152: mov     [rbp-60h],rax
    156: mov     rax,[rbp-58h]
    15a: mov     [rbp-0C0h],rax
    161: mov     rax,[rbp-68h]
    165: mov     [rbp-0B8h],rax
    16c: mov     rax,[rbp-60h]
    170: mov     [rbp-0B0h],rax
    177: call    fn0
    17c: nop     [rcx-50h]
    183: mov     rax,[rbp-50h]
    187: mov     [rbp-48h],rax
    18b: mov     byte ptr [rbp-0A1h],1
    192: test    byte ptr [rbp-0A1h],0FFh
    199: je      38Dh
    19f: jmp     35Ah
    1a4: nop     [rax+rax]
    1ad: nop     [rax]
    1b0: mov     rax,[rbp-48h]
    1b4: mov     [rbp-8],rax
    1b8: jmp     1C5h
    1ba: nop     [rax+rax]
    1c0: jmp     0F0h
    1c5: mov     edi,0FFFFFFF8h
    1ca: mov     esi,8
    1cf: call    ryo_h_Ret
    1d4: leave
    1d5: ret
    1d6: nop     [rax+rax]
    1df: nop
    1e0: jmp     222h
    1e2: nop     [rax+rax]
    1eb: nop     [rax+rax]
    1f0: mov     edi,0FFFFFFC0h
    1f5: call    ryo_h_Resume
    1fa: ud2
    1fc: nop     [rax]
    200: jmp     1E0h
    202: nop     [rax+rax]
    20b: nop     [rax+rax]
    210: test    byte ptr [rbp-31h],0FFh
    214: je      1E0h
    216: jmp     200h
    218: nop     [rax+rax]
    220: jmp     1F0h
    222: test    byte ptr [rbp-32h],0FFh
    226: je      1F0h
    228: jmp     220h
    22a: nop     [rax+rax]
    230: jmp     0F0h
    235: mov     rax,[rbp-50h]
    239: mov     [rbp-78h],rax
    23d: mov     rax,[rbp-58h]
    241: mov     [rbp-80h],rax
    245: mov     rax,[rbp-78h]
    249: mov     [rbp-0C0h],rax
    250: mov     rax,[rbp-80h]
    254: mov     [rbp-0B8h],rax
    25b: mov     edi,0FFFFFF50h
    260: lea     rsi,[k1]
    267: call    ryo_h_AddrAbs
    26c: call    fn2
    271: nop     [rcx-32h]
    278: mov     qword ptr [rbp-0A8h],0
    283: cmp     qword ptr [rbp-0A8h],4
    28b: setb    [rbp-71h]
    28f: test    byte ptr [rbp-71h],0FFh
    293: je      2EEh
    295: mov     qword ptr [rbp-0A8h],4
    2a0: mov     rax,[rbp-0A8h]
    2a7: mov     rcx,7FFFFFFFFFFFFFFFh
    2b1: cmp     rax,rcx
    2b4: setbe   [rbp-72h]
    2b8: test    byte ptr [rbp-72h],0FFh
    2bc: je      2EEh
    2be: mov     rax,[rbp-70h]
    2c2: sub     rax,[rbp-68h]
    2c6: mov     [rbp-28h],rax
    2ca: mov     qword ptr [rbp-0A8h],4
    2d5: mov     edi,0FFFFFFD8h
    2da: mov     esi,0FFFFFFD8h
    2df: mov     edx,0FFFFFF58h
    2e4: call    ryo_h_DivUW64
    2e9: jmp     230h
    2ee: mov     edi,0FFFFFF40h
    2f3: lea     rsi,[k3]
    2fa: call    ryo_h_AddrAbs
    2ff: mov     qword ptr [rbp-0B8h],49h
    30a: mov     edi,0FFFFFF50h
    30f: lea     rsi,[k4]
    316: call    ryo_h_AddrAbs
    31b: lea     rdi,[sym5]
    322: lea     rsi,[site6]
    329: mov     edx,0FFFFFF58h
    32e: call    ryo_h_CallExt
    333: test    rax,rax
    336: je      343h
    338: call    rax
    33a: nop     [rcx-32h]
    341: jmp     353h
    343: mov     rdi,rbp
    346: lea     rsi,[ro+4]
    34d: call    qword ptr [sym7]
    353: call    ryo_h_Unreachable
    358: ud2
    35a: mov     rax,[rbp-20h]
    35e: mov     [rbp-0C0h],rax
    365: mov     qword ptr [rbp-0B8h],1
    370: mov     edi,0FFFFFF50h
    375: lea     rsi,[k8]
    37c: call    ryo_h_AddrAbs
    381: call    fn9
    386: nop     [rcx-32h]
    38d: mov     rax,[rbp-20h]
    391: add     rax,1
    395: mov     [rbp-50h],rax
    399: mov     [rbp-20h],rax
    39d: mov     [rbp-58h],rax
    3a1: mov     rax,[rbp-28h]
    3a5: mov     [rbp-60h],rax
    3a9: mov     rax,[rbp-58h]
    3ad: cmp     rax,[rbp-60h]
    3b1: je      1B0h
    3b7: jmp     1C0h
    3bc: mov     rdi,rax
    3bf: mov     esi,0FFFFFFC0h
    3c4: call    ryo_h_Lpad
    3c9: jmp     210h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::map::<(u32, u32), {closure@bench/sort.rs:59:50: 59:54}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFF0h
     1c: mov     esi,10h
     21: call    ryo_h_Ret
     26: leave
     27: ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-38h],rax
     16: mov     rax,[rbp+10h]
     1a: mov     rax,[rax+8]
     1e: mov     [rbp-40h],rax
     22: mov     byte ptr [rbp-59h],0
     26: test    byte ptr [rbp-59h],0FFh
     2a: je      56h
     2c: mov     [rbp-48h],rax
     30: cmp     rax,0
     34: jne     43h
     36: mov     qword ptr [rbp-8],0
     3e: jmp     0D2h
     43: mov     byte ptr [rbp-59h],1
     47: test    byte ptr [rbp-59h],0FFh
     4b: je      110h
     51: jmp     0E3h
     56: mov     rax,[rbp-40h]
     5a: mov     [rbp-50h],rax
     5e: mov     rax,[rbp-38h]
     62: mov     [rbp-30h],rax
     66: mov     rax,[rbp-50h]
     6a: mov     [rbp-58h],rax
     6e: mov     rax,[rbp-30h]
     72: cmp     rax,[rbp-58h]
     76: sete    [rbp-41h]
     7a: test    byte ptr [rbp-41h],0FFh
     7e: je      8Ah
     80: mov     qword ptr [rbp-8],0
     88: jmp     0D2h
     8a: mov     qword ptr [rbp-60h],1
     92: mov     rax,[rbp-30h]
     96: imul    rcx,[rbp-60h],4
     9b: add     rax,rcx
     9e: mov     [rbp-50h],rax
     a2: mov     [rbp-48h],rax
     a6: mov     rax,[rbp+10h]
     aa: mov     rcx,[rbp-48h]
     ae: mov     [rax],rcx
     b1: nop     [rax+rax]
     ba: nop     [rax+rax]
     c0: mov     rax,[rbp-38h]
     c4: mov     [rbp-50h],rax
     c8: mov     [rbp-48h],rax
     cc: mov     [rbp-8],rax
     d0: jmp     0D2h
     d2: mov     edi,0FFFFFFF8h
     d7: mov     esi,8
     dc: call    ryo_h_Ret
     e1: leave
     e2: ret
     e3: mov     rax,[rbp-48h]
     e7: mov     [rbp-80h],rax
     eb: mov     qword ptr [rbp-78h],1
     f3: mov     edi,0FFFFFF90h
     f8: lea     rsi,[k0]
     ff: call    ryo_h_AddrAbs
    104: call    fn1
    109: nop     [rcx-28h]
    110: mov     rax,[rbp-48h]
    114: sub     rax,1
    118: mov     [rbp-10h],rax
    11c: mov     rax,[rbp+10h]
    120: mov     rcx,[rbp-10h]
    124: mov     [rax+8],rcx
    128: jmp     0C0h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-59h],0
      f: test    byte ptr [rbp-59h],0FFh
     13: je      27h
     15: mov     rax,[rbp+10h]
     19: mov     rax,[rax+8]
     1d: mov     [rbp-28h],rax
     21: mov     [rbp-20h],rax
     25: jmp     70h
     27: mov     rax,[rbp+10h]
     2b: mov     rax,[rax+8]
     2f: mov     [rbp-30h],rax
     33: mov     [rbp-28h],rax
     37: mov     rax,[rbp+10h]
     3b: mov     rax,[rax]
     3e: mov     [rbp-30h],rax
     42: mov     rax,[rbp-28h]
     46: mov     [rbp-38h],rax
     4a: mov     rax,[rbp-30h]
     4e: mov     [rbp-40h],rax
     52: mov     rax,[rbp-28h]
     56: mov     [rbp-48h],rax
     5a: mov     byte ptr [rbp-59h],1
     5e: test    byte ptr [rbp-59h],0FFh
     62: je      0EFh
     68: jmp     0B2h
     6a: nop     [rax+rax]
     70: mov     rax,[rbp-20h]
     74: mov     [rbp-28h],rax
     78: mov     rax,[rbp-20h]
     7c: mov     [rbp-30h],rax
     80: mov     qword ptr [rbp-38h],1
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-18h],rax
     90: mov     edi,0FFFFFFF0h
     95: mov     esi,0FFFFFFC8h
     9a: call    ryo_h_MovW128
     9f: mov     edi,0FFFFFFE8h
     a4: mov     esi,18h
     a9: call    ryo_h_Ret
     ae: leave
     af: ret
     b0: jmp     70h
     b2: mov     rax,[rbp-28h]
     b6: mov     [rbp-50h],rax
     ba: mov     rax,[rbp-30h]
     be: mov     [rbp-58h],rax
     c2: mov     rax,[rbp-50h]
     c6: mov     [rbp-80h],rax
     ca: mov     rax,[rbp-58h]
     ce: mov     [rbp-78h],rax
     d2: mov     edi,0FFFFFF90h
     d7: lea     rsi,[k0]
     de: call    ryo_h_AddrAbs
     e3: call    fn1
     e8: nop     [rcx-20h]
     ef: mov     qword ptr [rbp-60h],0
     f7: cmp     qword ptr [rbp-60h],4
     fc: setb    [rbp-49h]
    100: test    byte ptr [rbp-49h],0FFh
    104: je      156h
    106: mov     qword ptr [rbp-60h],4
    10e: mov     rax,[rbp-60h]
    112: mov     rcx,7FFFFFFFFFFFFFFFh
    11c: cmp     rax,rcx
    11f: setbe   [rbp-4Ah]
    123: test    byte ptr [rbp-4Ah],0FFh
    127: je      156h
    129: mov     rax,[rbp-48h]
    12d: sub     rax,[rbp-40h]
    131: mov     [rbp-20h],rax
    135: mov     qword ptr [rbp-60h],4
    13d: mov     edi,0FFFFFFE0h
    142: mov     esi,0FFFFFFE0h
    147: mov     edx,0FFFFFFA0h
    14c: call    ryo_h_DivUW64
    151: jmp     0B0h
    156: mov     edi,0FFFFFF80h
    15b: lea     rsi,[k2]
    162: call    ryo_h_AddrAbs
    167: mov     qword ptr [rbp-78h],49h
    16f: mov     edi,0FFFFFF90h
    174: lea     rsi,[k3]
    17b: call    ryo_h_AddrAbs
    180: lea     rdi,[sym4]
    187: lea     rsi,[site5]
    18e: mov     edx,0FFFFFFA0h
    193: call    ryo_h_CallExt
    198: test    rax,rax
    19b: je      1A8h
    19d: call    rax
    19f: nop     [rcx-20h]
    1a6: jmp     1B8h
    1a8: mov     rdi,rbp
    1ab: lea     rsi,[ro+4]
    1b2: call    qword ptr [sym6]
    1b8: call    ryo_h_Unreachable
    1bd: ud2

fn <std::vec::Vec<(u32, u32)> as std::iter::FromIterator<(u32, u32)>>::from_iter::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFC0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: call    fn0
     1c: nop     [rcx-28h]
     23: mov     edi,0FFFFFFC0h
     28: mov     esi,0FFFFFFD8h
     2d: call    ryo_h_MovW128
     32: call    fn1
     37: nop     [rcx-18h]
     3e: mov     edi,0FFFFFFE8h
     43: mov     esi,18h
     48: call    ryo_h_Ret
     4d: leave
     4e: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::DerefMut>::deref_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-30h],rax
     14: mov     [rbp-28h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-28h]
     28: mov     [rbp-20h],rax
     2c: mov     rax,[rbp-30h]
     30: mov     [rbp-18h],rax
     34: mov     rax,[rbp-20h]
     38: mov     [rbp-10h],rax
     3c: mov     rax,[rbp-18h]
     40: mov     [rbp-8],rax
     44: mov     edi,0FFFFFFF0h
     49: mov     esi,10h
     4e: call    ryo_h_Ret
     53: leave
     54: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-20h],rax
     24: mov     rax,[rbp-18h]
     28: mov     [rbp-10h],rax
     2c: mov     rax,[rbp-20h]
     30: mov     [rbp-8],rax
     34: mov     rax,[rbp-10h]
     38: mov     [rbp-20h],rax
     3c: mov     rax,[rbp-8]
     40: mov     [rbp-18h],rax
     44: mov     edi,0FFFFFFC0h
     49: mov     esi,0FFFFFFE0h
     4e: call    ryo_h_MovW128
     53: mov     edi,0FFFFFFD8h
     58: lea     rsi,[sym0]
     5f: call    ryo_h_AddrSym
     64: mov     rdi,rbp
     67: lea     rsi,[ro+4]
     6e: call    qword ptr [sym1]
     74: xor     edi,edi
     76: xor     esi,esi
     78: call    ryo_h_Ret
     7d: leave
     7e: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     [rbp-30h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-38h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-28h],rax
     2c: mov     rax,[rbp-38h]
     30: mov     [rbp-20h],rax
     34: mov     rax,[rbp-28h]
     38: mov     [rbp-18h],rax
     3c: mov     rax,[rbp-20h]
     40: mov     [rbp-10h],rax
     44: mov     rax,[rbp+18h]
     48: mov     [rbp-50h],rax
     4c: mov     edi,0FFFFFFA0h
     51: mov     esi,0FFFFFFE8h
     56: call    ryo_h_MovW128
     5b: mov     rax,[rbp+20h]
     5f: mov     [rbp-48h],rax
     63: call    fn0
     68: nop     [rcx-8]
     6f: mov     edi,0FFFFFFF8h
     74: mov     esi,8
     79: call    ryo_h_Ret
     7e: leave
     7f: ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_extend::SpecExtend<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::spec_extend
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFE8h
     15: mov     esi,18h
     1a: call    ryo_h_MovW128
     1f: call    fn0
     24: nop     [rcx]
     2b: xor     edi,edi
     2d: xor     esi,esi
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter::SpecFromIter<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: call    fn0
     1c: nop     [rcx-18h]
     23: mov     edi,0FFFFFFE8h
     28: mov     esi,18h
     2d: call    ryo_h_Ret
     32: leave
     33: ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter_nested::SpecFromIterNested<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     byte ptr [rbp-21h],1
      f: lea     rax,[rbp+10h]
     13: mov     [rbp-68h],rax
     17: mov     [rbp-0E0h],rax
     1e: call    fn0
     23: nop     [rcx-60h]
     2a: mov     rax,[rbp-58h]
     2e: mov     [rbp-20h],rax
     32: mov     edi,0FFFFFFE0h
     37: xor     esi,esi
     39: mov     edx,2
     3e: call    ryo_h_SwitchDenseW64
     43: lea     rcx,[54h]
     4a: movsxd  rax,[rcx+rax*4]
     4e: add     rax,rcx
     51: jmp     rax
     53: int3
     54: .long   60h
     58: .long   160h
     5c: .long   284h
     60: mov     edi,0FFFFFF80h
     65: lea     rsi,[k1]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-78h],11h
     79: mov     rax,[rbp-80h]
     7d: mov     [rbp-0A0h],rax
     84: mov     rax,[rbp-78h]
     88: mov     [rbp-98h],rax
     8f: mov     rax,[rbp-0A0h]
     96: mov     [rbp-90h],rax
     9d: mov     [rbp-88h],rax
     a4: mov     edi,0FFFFFF48h
     a9: lea     rsi,[k2]
     b0: call    ryo_h_AddrAbs
     b5: mov     qword ptr [rbp-0B0h],11h
     c0: mov     rax,[rbp-0B0h]
     c7: mov     [rbp-0A8h],rax
     ce: shl     rax,1
     d2: mov     [rbp-0A0h],rax
     d9: or      rax,1
     dd: mov     [rbp-98h],rax
     e4: mov     [rbp-90h],rax
     eb: mov     rax,[rbp-88h]
     f2: mov     [rbp-70h],rax
     f6: mov     rax,[rbp-90h]
     fd: mov     [rbp-68h],rax
    101: mov     edi,0FFFFFF20h
    106: mov     esi,0FFFFFF90h
    10b: call    ryo_h_MovW128
    110: mov     edi,0FFFFFF30h
    115: lea     rsi,[k3]
    11c: call    ryo_h_AddrAbs
    121: lea     rdi,[sym4]
    128: lea     rsi,[site5]
    12f: mov     edx,0FFFFFF40h
    134: call    ryo_h_CallExt
    139: test    rax,rax
    13c: je      149h
    13e: call    rax
    140: nop     [rcx-20h]
    147: jmp     159h
    149: mov     rdi,rbp
    14c: lea     rsi,[ro+4]
    153: call    qword ptr [sym6]
    159: call    ryo_h_Unreachable
    15e: ud2
    160: mov     rax,[rbp-50h]
    164: mov     [rbp-68h],rax
    168: mov     [rbp-0E0h],rax
    16f: mov     edi,0FFFFFF28h
    174: lea     rsi,[k7]
    17b: mov     edx,10h
    180: call    ryo_h_Const
    185: call    fn8
    18a: nop     [rcx-88h]
    191: jmp     218h
    196: nop     [rax+rax]
    19f: nop
    1a0: mov     edi,0FFFFFFE8h
    1a5: mov     esi,0FFFFFFB8h
    1aa: mov     edx,18h
    1af: call    ryo_h_Copy
    1b4: mov     edi,0FFFFFFE8h
    1b9: mov     esi,18h
    1be: call    ryo_h_Ret
    1c3: leave
    1c4: ret
    1c5: nop     [rax+rax]
    1ce: xchg    ax,ax
    1d0: lea     rax,[rbp-48h]
    1d4: mov     [rbp-0C0h],rax
    1db: mov     [rbp-0E0h],rax
    1e2: call    fn9
    1e7: nop     [rcx-0C0h]
    1ee: jmp     210h
    1f0: mov     edi,0FFFFFFD0h
    1f5: call    ryo_h_Resume
    1fa: ud2
    1fc: nop     [rax]
    200: jmp     1F0h
    202: nop     [rax+rax]
    20b: nop     [rax+rax]
    210: test    byte ptr [rbp-21h],0FFh
    214: je      1F0h
    216: jmp     200h
    218: mov     edi,0FFFFFF88h
    21d: mov     esi,0FFFFFF78h
    222: call    ryo_h_MovW128
    227: mov     edi,0FFFFFFB8h
    22c: mov     esi,0FFFFFF88h
    231: call    ryo_h_MovW128
    236: mov     qword ptr [rbp-38h],0
    23e: lea     rax,[rbp-48h]
    242: mov     [rbp-50h],rax
    246: mov     byte ptr [rbp-21h],0
    24a: mov     edi,0FFFFFFA0h
    24f: mov     esi,10h
    254: call    ryo_h_MovW128
    259: mov     rax,[rbp-50h]
    25d: mov     [rbp-0E0h],rax
    264: mov     edi,0FFFFFF28h
    269: mov     esi,0FFFFFFA0h
    26e: call    ryo_h_MovW128
    273: call    fn10
    278: nop     [rcx-20h]
    27f: jmp     1A0h
    284: call    ryo_h_Unreachable
    289: ud2
    28b: nop     [rax+rax]
    290: lea     rdi,[sym11]
    297: lea     rsi,[site12]
    29e: mov     edx,0FFFFFF40h
    2a3: call    ryo_h_CallExt
    2a8: test    rax,rax
    2ab: je      2B8h
    2ad: call    rax
    2af: nop     [rcx-0B8h]
    2b6: jmp     2C8h
    2b8: mov     rdi,rbp
    2bb: lea     rsi,[ro+20]
    2c2: call    qword ptr [sym13]
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     rdi,rax
    2d2: mov     esi,0FFFFFFD0h
    2d7: call    ryo_h_Lpad
    2dc: jmp     210h
    2e1: mov     rdi,rax
    2e4: mov     esi,0FFFFFFD0h
    2e9: call    ryo_h_Lpad
    2ee: jmp     290h
    2f0: mov     rdi,rax
    2f3: mov     esi,0FFFFFFD0h
    2f8: call    ryo_h_Lpad
    2fd: jmp     1D0h

fn <std::vec::Vec<u32> as std::clone::Clone>::clone
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+10h]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-60h],rax
     18: call    fn0
     1d: nop     [rcx-18h]
     24: mov     rax,[rbp+10h]
     28: mov     rax,[rax+8]
     2c: mov     [rbp-48h],rax
     30: mov     [rbp-40h],rax
     34: mov     rax,[rbp+10h]
     38: mov     rax,[rax+10h]
     3c: mov     [rbp-48h],rax
     40: mov     rax,[rbp-40h]
     44: mov     [rbp-38h],rax
     48: mov     rax,[rbp-48h]
     4c: mov     [rbp-30h],rax
     50: mov     rax,[rbp-38h]
     54: mov     [rbp-28h],rax
     58: mov     rax,[rbp-30h]
     5c: mov     [rbp-20h],rax
     60: mov     edi,0FFFFFFA0h
     65: mov     esi,0FFFFFFD8h
     6a: call    ryo_h_MovW128
     6f: call    fn1
     74: nop     [rcx-18h]
     7b: mov     edi,0FFFFFFE8h
     80: mov     esi,18h
     85: call    ryo_h_Ret
     8a: leave
     8b: ret

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     [rbp-30h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-38h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-28h],rax
     2c: mov     rax,[rbp-38h]
     30: mov     [rbp-20h],rax
     34: mov     rax,[rbp-28h]
     38: mov     [rbp-18h],rax
     3c: mov     rax,[rbp-20h]
     40: mov     [rbp-10h],rax
     44: mov     edi,0FFFFFFB0h
     49: mov     esi,0FFFFFFE8h
     4e: call    ryo_h_MovW128
     53: mov     rax,[rbp+18h]
     57: mov     [rbp-40h],rax
     5b: call    fn0
     60: nop     [rcx-1]
     67: mov     edi,0FFFFFFFFh
     6c: mov     esi,1
     71: call    ryo_h_Ret
     76: leave
     77: ret

fn <std::vec::Vec<u32> as std::iter::FromIterator<u32>>::from_iter::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFB0h
      d: mov     esi,10h
     12: mov     edx,18h
     17: call    ryo_h_Copy
     1c: call    fn0
     21: nop     [rcx-30h]
     28: mov     edi,0FFFFFFB0h
     2d: mov     esi,0FFFFFFD0h
     32: mov     edx,18h
     37: call    ryo_h_Copy
     3c: call    fn1
     41: nop     [rcx-18h]
     48: mov     edi,0FFFFFFE8h
     4d: mov     esi,18h
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <std::vec::Vec<u32> as std::ops::Deref>::deref
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-30h],rax
     14: mov     [rbp-28h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-28h]
     28: mov     [rbp-20h],rax
     2c: mov     rax,[rbp-30h]
     30: mov     [rbp-18h],rax
     34: mov     rax,[rbp-20h]
     38: mov     [rbp-10h],rax
     3c: mov     rax,[rbp-18h]
     40: mov     [rbp-8],rax
     44: mov     edi,0FFFFFFF0h
     49: mov     esi,10h
     4e: call    ryo_h_Ret
     53: leave
     54: ret

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-30h],rax
     14: mov     [rbp-28h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-28h]
     28: mov     [rbp-20h],rax
     2c: mov     rax,[rbp-30h]
     30: mov     [rbp-18h],rax
     34: mov     rax,[rbp-20h]
     38: mov     [rbp-10h],rax
     3c: mov     rax,[rbp-18h]
     40: mov     [rbp-8],rax
     44: mov     edi,0FFFFFFF0h
     49: mov     esi,10h
     4e: call    ryo_h_Ret
     53: leave
     54: ret

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-20h],rax
     24: mov     rax,[rbp-18h]
     28: mov     [rbp-10h],rax
     2c: mov     rax,[rbp-20h]
     30: mov     [rbp-8],rax
     34: mov     rax,[rbp-10h]
     38: mov     [rbp-20h],rax
     3c: mov     rax,[rbp-8]
     40: mov     [rbp-18h],rax
     44: mov     edi,0FFFFFFC0h
     49: mov     esi,0FFFFFFE0h
     4e: call    ryo_h_MovW128
     53: mov     edi,0FFFFFFD8h
     58: lea     rsi,[sym0]
     5f: call    ryo_h_AddrSym
     64: mov     rdi,rbp
     67: lea     rsi,[ro+4]
     6e: call    qword ptr [sym1]
     74: xor     edi,edi
     76: xor     esi,esi
     78: call    ryo_h_Ret
     7d: leave
     7e: ret

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-40h],rax
     14: call    fn0
     19: nop     [rcx-10h]
     20: jmp     3Bh
     22: nop     [rax+rax]
     2b: nop     [rax+rax]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: mov     rax,[rbp-10h]
     3f: mov     [rbp-20h],rax
     43: mov     rax,[rbp-8]
     47: mov     [rbp-18h],rax
     4b: mov     rax,[rbp+10h]
     4f: mov     [rbp-40h],rax
     53: mov     edi,0FFFFFFC8h
     58: mov     esi,0FFFFFFE0h
     5d: call    ryo_h_MovW128
     62: call    fn1
     67: nop     [rcx]
     6e: jmp     30h

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::spec_extend
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFE8h
     15: mov     esi,18h
     1a: mov     edx,18h
     1f: call    ryo_h_Copy
     24: call    fn0
     29: nop     [rcx]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter::SpecFromIter<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,10h
     12: mov     edx,18h
     17: call    ryo_h_Copy
     1c: call    fn0
     21: nop     [rcx-18h]
     28: mov     edi,0FFFFFFE8h
     2d: mov     esi,18h
     32: call    ryo_h_Ret
     37: leave
     38: ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter_nested::SpecFromIterNested<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     byte ptr [rbp-21h],1
      f: lea     rax,[rbp+10h]
     13: mov     [rbp-68h],rax
     17: mov     [rbp-0E0h],rax
     1e: call    fn0
     23: nop     [rcx-60h]
     2a: mov     rax,[rbp-58h]
     2e: mov     [rbp-20h],rax
     32: mov     edi,0FFFFFFE0h
     37: xor     esi,esi
     39: mov     edx,2
     3e: call    ryo_h_SwitchDenseW64
     43: lea     rcx,[54h]
     4a: movsxd  rax,[rcx+rax*4]
     4e: add     rax,rcx
     51: jmp     rax
     53: int3
     54: .long   60h
     58: .long   160h
     5c: .long   28eh
     60: mov     edi,0FFFFFF80h
     65: lea     rsi,[k1]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-78h],11h
     79: mov     rax,[rbp-80h]
     7d: mov     [rbp-0A0h],rax
     84: mov     rax,[rbp-78h]
     88: mov     [rbp-98h],rax
     8f: mov     rax,[rbp-0A0h]
     96: mov     [rbp-90h],rax
     9d: mov     [rbp-88h],rax
     a4: mov     edi,0FFFFFF48h
     a9: lea     rsi,[k2]
     b0: call    ryo_h_AddrAbs
     b5: mov     qword ptr [rbp-0B0h],11h
     c0: mov     rax,[rbp-0B0h]
     c7: mov     [rbp-0A8h],rax
     ce: shl     rax,1
     d2: mov     [rbp-0A0h],rax
     d9: or      rax,1
     dd: mov     [rbp-98h],rax
     e4: mov     [rbp-90h],rax
     eb: mov     rax,[rbp-88h]
     f2: mov     [rbp-70h],rax
     f6: mov     rax,[rbp-90h]
     fd: mov     [rbp-68h],rax
    101: mov     edi,0FFFFFF20h
    106: mov     esi,0FFFFFF90h
    10b: call    ryo_h_MovW128
    110: mov     edi,0FFFFFF30h
    115: lea     rsi,[k3]
    11c: call    ryo_h_AddrAbs
    121: lea     rdi,[sym4]
    128: lea     rsi,[site5]
    12f: mov     edx,0FFFFFF40h
    134: call    ryo_h_CallExt
    139: test    rax,rax
    13c: je      149h
    13e: call    rax
    140: nop     [rcx-20h]
    147: jmp     159h
    149: mov     rdi,rbp
    14c: lea     rsi,[ro+4]
    153: call    qword ptr [sym6]
    159: call    ryo_h_Unreachable
    15e: ud2
    160: mov     rax,[rbp-50h]
    164: mov     [rbp-68h],rax
    168: mov     [rbp-0E0h],rax
    16f: mov     edi,0FFFFFF28h
    174: lea     rsi,[k7]
    17b: mov     edx,10h
    180: call    ryo_h_Const
    185: call    fn8
    18a: nop     [rcx-88h]
    191: jmp     218h
    196: nop     [rax+rax]
    19f: nop
    1a0: mov     edi,0FFFFFFE8h
    1a5: mov     esi,0FFFFFFB8h
    1aa: mov     edx,18h
    1af: call    ryo_h_Copy
    1b4: mov     edi,0FFFFFFE8h
    1b9: mov     esi,18h
    1be: call    ryo_h_Ret
    1c3: leave
    1c4: ret
    1c5: nop     [rax+rax]
    1ce: xchg    ax,ax
    1d0: lea     rax,[rbp-48h]
    1d4: mov     [rbp-0C0h],rax
    1db: mov     [rbp-0E0h],rax
    1e2: call    fn9
    1e7: nop     [rcx-0C0h]
    1ee: jmp     210h
    1f0: mov     edi,0FFFFFFD0h
    1f5: call    ryo_h_Resume
    1fa: ud2
    1fc: nop     [rax]
    200: jmp     1F0h
    202: nop     [rax+rax]
    20b: nop     [rax+rax]
    210: test    byte ptr [rbp-21h],0FFh
    214: je      1F0h
    216: jmp     200h
    218: mov     edi,0FFFFFF88h
    21d: mov     esi,0FFFFFF78h
    222: call    ryo_h_MovW128
    227: mov     edi,0FFFFFFB8h
    22c: mov     esi,0FFFFFF88h
    231: call    ryo_h_MovW128
    236: mov     qword ptr [rbp-38h],0
    23e: lea     rax,[rbp-48h]
    242: mov     [rbp-50h],rax
    246: mov     byte ptr [rbp-21h],0
    24a: mov     edi,0FFFFFF98h
    24f: mov     esi,10h
    254: mov     edx,18h
    259: call    ryo_h_Copy
    25e: mov     rax,[rbp-50h]
    262: mov     [rbp-0E0h],rax
    269: mov     edi,0FFFFFF28h
    26e: mov     esi,0FFFFFF98h
    273: mov     edx,18h
    278: call    ryo_h_Copy
    27d: call    fn10
    282: nop     [rcx-20h]
    289: jmp     1A0h
    28e: call    ryo_h_Unreachable
    293: ud2
    295: nop     [rax+rax]
    29e: xchg    ax,ax
    2a0: lea     rdi,[sym11]
    2a7: lea     rsi,[site12]
    2ae: mov     edx,0FFFFFF40h
    2b3: call    ryo_h_CallExt
    2b8: test    rax,rax
    2bb: je      2C8h
    2bd: call    rax
    2bf: nop     [rcx-0B8h]
    2c6: jmp     2D8h
    2c8: mov     rdi,rbp
    2cb: lea     rsi,[ro+20]
    2d2: call    qword ptr [sym13]
    2d8: call    ryo_h_Unreachable
    2dd: ud2
    2df: mov     rdi,rax
    2e2: mov     esi,0FFFFFFD0h
    2e7: call    ryo_h_Lpad
    2ec: jmp     210h
    2f1: mov     rdi,rax
    2f4: mov     esi,0FFFFFFD0h
    2f9: call    ryo_h_Lpad
    2fe: jmp     2A0h
    300: mov     rdi,rax
    303: mov     esi,0FFFFFFD0h
    308: call    ryo_h_Lpad
    30d: jmp     1D0h

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-10h],rax
     14: mov     rax,[rbp+10h]
     18: mov     rax,[rax]
     1b: mov     [rbp-8],rax
     1f: mov     rcx,[rbp-10h]
     23: mov     [rax],rcx
     26: xor     edi,edi
     28: xor     esi,esi
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn <u32 as core::slice::cmp::SlicePartialEq<u32>>::equal_same_length
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: imul    rax,[rbp+20h],4
      d: mov     [rbp-10h],rax
     11: mov     rax,[rbp+10h]
     15: mov     [rbp-18h],rax
     19: mov     rax,[rbp+18h]
     1d: mov     [rbp-20h],rax
     21: mov     rdi,rbp
     24: lea     rsi,[ro+4]
     2b: call    qword ptr [sym0]
     31: cmp     dword ptr [rbp-8],0
     35: sete    [rbp-1]
     39: mov     edi,0FFFFFFFFh
     3e: mov     esi,1
     43: call    ryo_h_Ret
     48: leave
     49: ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     qword ptr [rbp-18h],4
     10: cmp     qword ptr [rbp-18h],8
     15: setbe   [rbp-1]
     19: test    byte ptr [rbp-1],0FFh
     1d: je      5Eh
     1f: mov     qword ptr [rbp-18h],4
     27: imul    rax,[rbp-18h],20h
     2c: mov     [rbp-10h],rax
     30: cmp     rax,1000h
     37: ja      5Eh
     39: mov     edi,0FFFFFFC0h
     3e: mov     esi,10h
     43: call    ryo_h_MovW128
     48: mov     rax,[rbp+20h]
     4c: mov     [rbp-30h],rax
     50: call    fn0
     55: nop     [rcx]
     5c: jmp     0B0h
     5e: mov     qword ptr [rbp-18h],4
     66: imul    rax,[rbp-18h],30h
     6b: mov     [rbp-10h],rax
     6f: cmp     rax,1000h
     76: ja      9Dh
     78: mov     edi,0FFFFFFC0h
     7d: mov     esi,10h
     82: call    ryo_h_MovW128
     87: mov     rax,[rbp+20h]
     8b: mov     [rbp-30h],rax
     8f: call    fn1
     94: nop     [rcx]
     9b: jmp     0B0h
     9d: mov     rax,[rbp+18h]
     a1: mov     [rbp-10h],rax
     a5: cmp     rax,2
     a9: jae     0BBh
     ab: jmp     0E8h
     ad: nop     [rax]
     b0: xor     edi,edi
     b2: xor     esi,esi
     b4: call    ryo_h_Ret
     b9: leave
     ba: ret
     bb: mov     edi,0FFFFFFC0h
     c0: mov     esi,10h
     c5: call    ryo_h_MovW128
     ca: mov     qword ptr [rbp-30h],1
     d2: mov     rax,[rbp+20h]
     d6: mov     [rbp-28h],rax
     da: call    fn2
     df: nop     [rcx]
     e6: jmp     0E8h
     e8: jmp     0B0h

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     qword ptr [rbp-20h],4
     10: cmp     qword ptr [rbp-20h],8
     15: setbe   [rbp-9]
     19: test    byte ptr [rbp-9],0FFh
     1d: je      43h
     1f: mov     qword ptr [rbp-20h],4
     27: imul    rax,[rbp-20h],20h
     2c: mov     [rbp-18h],rax
     30: cmp     rax,1000h
     37: ja      43h
     39: mov     qword ptr [rbp-8],20h
     41: jmp     6Fh
     43: mov     qword ptr [rbp-20h],4
     4b: imul    rax,[rbp-20h],30h
     50: mov     [rbp-18h],rax
     54: cmp     rax,1000h
     5b: ja      67h
     5d: mov     qword ptr [rbp-8],20h
     65: jmp     6Fh
     67: mov     qword ptr [rbp-8],10h
     6f: mov     edi,0FFFFFFF8h
     74: mov     esi,8
     79: call    ryo_h_Ret
     7e: leave
     7f: ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFE0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+20h]
     1b: mov     [rbp-10h],rax
     1f: call    fn0
     24: nop     [rcx]
     2b: xor     edi,edi
     2d: xor     esi,esi
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: call    fn0
      d: nop     [rcx-8]
     14: mov     edi,0FFFFFFF8h
     19: mov     esi,8
     1e: call    ryo_h_Ret
     23: leave
     24: ret

fn <u32 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-58h],rax
     13: mov     [rbp-0C0h],rax
     1a: mov     edi,0FFFFFF48h
     1f: lea     rsi,[k0]
     26: mov     edx,10h
     2b: call    ryo_h_Const
     30: call    fn1
     35: nop     [rcx-78h]
     3c: jmp     91h
     3e: xchg    ax,ax
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-38h],rax
     48: mov     rax,[rbp+18h]
     4c: mov     [rbp-30h],rax
     50: mov     rax,[rbp-38h]
     54: mov     [rbp-68h],rax
     58: mov     rax,[rbp-10h]
     5c: mov     [rbp-40h],rax
     60: mov     [rbp-70h],rax
     64: mov     byte ptr [rbp-81h],1
     6b: test    byte ptr [rbp-81h],0FFh
     72: je      124h
     78: jmp     0C0h
     7a: nop     [rax+rax]
     80: mov     edi,0FFFFFFE8h
     85: mov     esi,18h
     8a: call    ryo_h_Ret
     8f: leave
     90: ret
     91: mov     edi,0FFFFFF98h
     96: mov     esi,0FFFFFF88h
     9b: call    ryo_h_MovW128
     a0: mov     edi,0FFFFFFE8h
     a5: mov     esi,0FFFFFF98h
     aa: call    ryo_h_MovW128
     af: mov     qword ptr [rbp-8],0
     b7: cmp     qword ptr [rbp-58h],0
     bc: ja      40h
     be: jmp     80h
     c0: mov     rax,[rbp-38h]
     c4: mov     [rbp-78h],rax
     c8: mov     rax,[rbp-40h]
     cc: mov     [rbp-80h],rax
     d0: mov     rax,[rbp-78h]
     d4: mov     [rbp-0C0h],rax
     db: mov     rax,[rbp-80h]
     df: mov     [rbp-0B8h],rax
     e6: mov     qword ptr [rbp-0B0h],4
     f1: mov     qword ptr [rbp-0A8h],4
     fc: mov     rax,[rbp-58h]
    100: mov     [rbp-0A0h],rax
    107: mov     edi,0FFFFFF68h
    10c: lea     rsi,[k2]
    113: call    ryo_h_AddrAbs
    118: call    fn3
    11d: nop     [rcx-40h]
    124: imul    rax,[rbp-58h],4
    129: mov     [rbp-88h],rax
    130: mov     edi,0FFFFFF90h
    135: mov     esi,0FFFFFF98h
    13a: mov     edx,0FFFFFF78h
    13f: call    ryo_h_Memcpy
    144: mov     byte ptr [rbp-81h],1
    14b: test    byte ptr [rbp-81h],0FFh
    152: je      170h
    154: mov     qword ptr [rbp-88h],4
    15f: cmp     qword ptr [rbp-88h],0
    167: je      1B5h
    169: jmp     1BFh
    16b: nop     [rax+rax]
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-8],rax
    178: jmp     80h
    17d: nop     [rax]
    180: mov     rax,[rbp-58h]
    184: mov     [rbp-0C0h],rax
    18b: mov     rax,[rbp-68h]
    18f: mov     [rbp-0B8h],rax
    196: mov     edi,0FFFFFF50h
    19b: lea     rsi,[k4]
    1a2: call    ryo_h_AddrAbs
    1a7: call    fn5
    1ac: nop     [rcx-40h]
    1b3: jmp     170h
    1b5: mov     qword ptr [rbp-68h],0FFFFFFFFFFFFFFFFh
    1bd: jmp     180h
    1bf: mov     rax,[rbp-18h]
    1c3: mov     [rbp-70h],rax
    1c7: mov     [rbp-68h],rax
    1cb: jmp     180h

fn <usize as std::cmp::Ord>::max
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-9],1
      c: lea     rax,[rbp+18h]
     10: mov     [rbp-28h],rax
     14: lea     rax,[rbp+10h]
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-28h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-38h],rax
     2c: call    fn0
     31: nop     [rcx-19h]
     38: test    byte ptr [rbp-19h],0FFh
     3c: je      4Ch
     3e: mov     byte ptr [rbp-9],0
     42: mov     rax,[rbp+10h]
     46: mov     [rbp-8],rax
     4a: jmp     54h
     4c: mov     rax,[rbp+18h]
     50: mov     [rbp-8],rax
     54: mov     edi,0FFFFFFF8h
     59: mov     esi,8
     5e: call    ryo_h_Ret
     63: leave
     64: ret
     65: nop     [rax+rax]
     6e: xchg    ax,ax
     70: jmp     92h
     72: nop     [rax+rax]
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFE8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: test    byte ptr [rbp-9],0FFh
     96: je      80h
     98: jmp     90h
     9a: mov     rdi,rax
     9d: mov     esi,0FFFFFFE8h
     a2: call    ryo_h_Lpad
     a7: jmp     70h

fn <usize as std::cmp::Ord>::min
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-9],1
      c: lea     rax,[rbp+18h]
     10: mov     [rbp-28h],rax
     14: lea     rax,[rbp+10h]
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-28h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-38h],rax
     2c: call    fn0
     31: nop     [rcx-19h]
     38: test    byte ptr [rbp-19h],0FFh
     3c: je      48h
     3e: mov     rax,[rbp+18h]
     42: mov     [rbp-8],rax
     46: jmp     54h
     48: mov     byte ptr [rbp-9],0
     4c: mov     rax,[rbp+10h]
     50: mov     [rbp-8],rax
     54: mov     edi,0FFFFFFF8h
     59: mov     esi,8
     5e: call    ryo_h_Ret
     63: leave
     64: ret
     65: nop     [rax+rax]
     6e: xchg    ax,ax
     70: jmp     92h
     72: nop     [rax+rax]
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFE8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: test    byte ptr [rbp-9],0FFh
     96: je      80h
     98: jmp     90h
     9a: mov     rdi,rax
     9d: mov     esi,0FFFFFFE8h
     a2: call    ryo_h_Lpad
     a7: jmp     70h

fn <usize as std::iter::Step>::forward_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-9],1
      c: test    byte ptr [rbp-9],0FFh
     10: je      3Fh
     12: mov     rax,[rbp+10h]
     16: mov     [rbp-30h],rax
     1a: mov     rax,[rbp+18h]
     1e: mov     [rbp-28h],rax
     22: mov     edi,0FFFFFFE0h
     27: lea     rsi,[k0]
     2e: call    ryo_h_AddrAbs
     33: call    fn1
     38: nop     [rcx-8]
     3f: mov     rax,[rbp+10h]
     43: add     rax,[rbp+18h]
     47: mov     [rbp-8],rax
     4b: mov     edi,0FFFFFFF8h
     50: mov     esi,8
     55: call    ryo_h_Ret
     5a: leave
     5b: ret

fn <usize as std::iter::Step>::steps_between
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-20h],rax
     13: mov     rax,[rbp+18h]
     17: mov     rax,[rax]
     1a: mov     [rbp-28h],rax
     1e: cmp     rax,[rbp-20h]
     22: jb      51h
     24: sub     rax,[rbp-20h]
     28: mov     [rbp-38h],rax
     2c: mov     [rbp-40h],rax
     30: mov     qword ptr [rbp-48h],1
     38: mov     rax,[rbp-38h]
     3c: mov     [rbp-18h],rax
     40: mov     edi,0FFFFFFF0h
     45: mov     esi,0FFFFFFB8h
     4a: call    ryo_h_MovW128
     4f: jmp     6Fh
     51: mov     qword ptr [rbp-18h],0
     59: mov     edi,0FFFFFFF0h
     5e: lea     rsi,[k0]
     65: mov     edx,10h
     6a: call    ryo_h_Const
     6f: mov     edi,0FFFFFFE8h
     74: mov     esi,18h
     79: call    ryo_h_Ret
     7e: leave
     7f: ret

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp+20h]
     14: cmp     rax,[rbp-10h]
     18: jb      6Dh
     1a: mov     [rbp-40h],rax
     1e: mov     rax,[rbp-10h]
     22: mov     [rbp-38h],rax
     26: mov     rax,[rbp+28h]
     2a: mov     [rbp-30h],rax
     2e: lea     rdi,[sym0]
     35: lea     rsi,[site1]
     3c: mov     edx,0FFFFFFE0h
     41: call    ryo_h_CallExt
     46: test    rax,rax
     49: je      56h
     4b: call    rax
     4d: nop     [rcx-11h]
     54: jmp     66h
     56: mov     rdi,rbp
     59: lea     rsi,[ro+4]
     60: call    qword ptr [sym2]
     66: call    ryo_h_Unreachable
     6b: ud2
     6d: mov     rax,[rbp+10h]
     71: imul    rcx,[rbp+20h],8
     76: add     rax,rcx
     79: mov     [rbp-20h],rax
     7d: mov     [rbp-8],rax
     81: mov     edi,0FFFFFFF8h
     86: mov     esi,8
     8b: call    ryo_h_Ret
     90: leave
     91: ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: cmp     rax,[rbp+18h]
     13: jae     20h
     15: xor     edi,edi
     17: xor     esi,esi
     19: call    ryo_h_Ret
     1e: leave
     1f: ret
     20: mov     edi,0FFFFFFF0h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: mov     qword ptr [rbp-8],0D6h
     39: mov     rax,[rbp-10h]
     3d: mov     [rbp-48h],rax
     41: mov     rax,[rbp-8]
     45: mov     [rbp-40h],rax
     49: mov     rax,[rbp-48h]
     4d: mov     [rbp-38h],rax
     51: mov     [rbp-30h],rax
     55: mov     edi,0FFFFFFA0h
     5a: lea     rsi,[k1]
     61: call    ryo_h_AddrAbs
     66: mov     qword ptr [rbp-58h],0D6h
     6e: mov     rax,[rbp-58h]
     72: mov     [rbp-50h],rax
     76: shl     rax,1
     7a: mov     [rbp-48h],rax
     7e: or      rax,1
     82: mov     [rbp-40h],rax
     86: mov     [rbp-38h],rax
     8a: mov     rax,[rbp-30h]
     8e: mov     [rbp-28h],rax
     92: mov     rax,[rbp-38h]
     96: mov     [rbp-20h],rax
     9a: mov     edi,0FFFFFF70h
     9f: mov     esi,0FFFFFFD8h
     a4: call    ryo_h_MovW128
     a9: mov     byte ptr [rbp-80h],0
     ad: mov     rax,[rbp+20h]
     b1: mov     [rbp-78h],rax
     b5: lea     rdi,[sym2]
     bc: lea     rsi,[site3]
     c3: mov     edx,0FFFFFF98h
     c8: call    ryo_h_CallExt
     cd: test    rax,rax
     d0: je      0DDh
     d2: call    rax
     d4: nop     [rcx-10h]
     db: jmp     0EDh
     dd: mov     rdi,rbp
     e0: lea     rsi,[ro+4]
     e7: call    qword ptr [sym4]
     ed: call    ryo_h_Unreachable
     f2: ud2

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: lea     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     [rbp-20h],rax
     14: call    fn0
     19: nop     [rcx-4]
     20: mov     edi,0FFFFFFFCh
     25: mov     esi,4
     2a: call    ryo_h_Ret
     2f: leave
     30: ret
     31: nop     [rax+rax]
     3a: nop     [rax+rax]
     40: mov     edi,0FFFFFFE8h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE8h
     54: call    ryo_h_Lpad
     59: jmp     40h

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: call    fn0
     18: nop     [rcx-4]
     1f: mov     edi,0FFFFFFFCh
     24: mov     esi,4
     29: call    ryo_h_Ret
     2e: leave
     2f: ret

fn Rng::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     dword ptr [rbp-54h],0Dh
     1a: mov     eax,[rbp-54h]
     1d: mov     [rbp-1Ch],eax
     20: cmp     eax,40h
     23: jb      75h
     25: mov     edi,0FFFFFF90h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: lea     rdi,[sym1]
     3d: lea     rsi,[site2]
     44: mov     edx,0FFFFFFA8h
     49: call    ryo_h_CallExt
     4e: test    rax,rax
     51: je      5Eh
     53: call    rax
     55: nop     [rcx-4Dh]
     5c: jmp     6Eh
     5e: mov     rdi,rbp
     61: lea     rsi,[ro+4]
     68: call    qword ptr [sym3]
     6e: call    ryo_h_Unreachable
     73: ud2
     75: mov     rax,[rbp-18h]
     79: shl     rax,0Dh
     7d: mov     [rbp-10h],rax
     81: mov     rax,[rbp+10h]
     85: mov     rax,[rax]
     88: mov     [rbp-58h],rax
     8c: xor     rax,[rbp-10h]
     90: mov     [rbp-60h],rax
     94: mov     rax,[rbp+10h]
     98: mov     rcx,[rbp-60h]
     9c: mov     [rax],rcx
     9f: mov     rax,[rbp+10h]
     a3: mov     rax,[rax]
     a6: mov     [rbp-30h],rax
     aa: mov     dword ptr [rbp-54h],7
     b1: mov     eax,[rbp-54h]
     b4: mov     [rbp-34h],eax
     b7: cmp     eax,40h
     ba: jb      10Ch
     bc: mov     edi,0FFFFFF90h
     c1: lea     rsi,[k4]
     c8: call    ryo_h_AddrAbs
     cd: lea     rdi,[sym5]
     d4: lea     rsi,[site6]
     db: mov     edx,0FFFFFFA8h
     e0: call    ryo_h_CallExt
     e5: test    rax,rax
     e8: je      0F5h
     ea: call    rax
     ec: nop     [rcx-4Dh]
     f3: jmp     105h
     f5: mov     rdi,rbp
     f8: lea     rsi,[ro+4]
     ff: call    qword ptr [sym7]
    105: call    ryo_h_Unreachable
    10a: ud2
    10c: mov     rax,[rbp-30h]
    110: shr     rax,7
    114: mov     [rbp-28h],rax
    118: mov     rax,[rbp+10h]
    11c: mov     rax,[rax]
    11f: mov     [rbp-58h],rax
    123: xor     rax,[rbp-28h]
    127: mov     [rbp-60h],rax
    12b: mov     rax,[rbp+10h]
    12f: mov     rcx,[rbp-60h]
    133: mov     [rax],rcx
    136: mov     rax,[rbp+10h]
    13a: mov     rax,[rax]
    13d: mov     [rbp-48h],rax
    141: mov     dword ptr [rbp-54h],11h
    148: mov     eax,[rbp-54h]
    14b: mov     [rbp-4Ch],eax
    14e: cmp     eax,40h
    151: jb      1A3h
    153: mov     edi,0FFFFFF90h
    158: lea     rsi,[k8]
    15f: call    ryo_h_AddrAbs
    164: lea     rdi,[sym9]
    16b: lea     rsi,[site10]
    172: mov     edx,0FFFFFFA8h
    177: call    ryo_h_CallExt
    17c: test    rax,rax
    17f: je      18Ch
    181: call    rax
    183: nop     [rcx-4Dh]
    18a: jmp     19Ch
    18c: mov     rdi,rbp
    18f: lea     rsi,[ro+4]
    196: call    qword ptr [sym11]
    19c: call    ryo_h_Unreachable
    1a1: ud2
    1a3: mov     rax,[rbp-48h]
    1a7: shl     rax,11h
    1ab: mov     [rbp-40h],rax
    1af: mov     rax,[rbp+10h]
    1b3: mov     rax,[rax]
    1b6: mov     [rbp-58h],rax
    1ba: xor     rax,[rbp-40h]
    1be: mov     [rbp-60h],rax
    1c2: mov     rax,[rbp+10h]
    1c6: mov     rcx,[rbp-60h]
    1ca: mov     [rax],rcx
    1cd: mov     rax,[rbp+10h]
    1d1: mov     rax,[rax]
    1d4: mov     [rbp-8],rax
    1d8: mov     edi,0FFFFFFF8h
    1dd: mov     esi,8
    1e2: call    ryo_h_Ret
    1e7: leave
    1e8: ret

fn alloc::raw_vec::RawVec::<u32>::grow_one
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rax]
     13: mov     [rbp-28h],rax
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-8]
     1f: mov     [rbp-60h],rax
     23: mov     rax,[rbp-20h]
     27: mov     [rbp-58h],rax
     2b: mov     qword ptr [rbp-50h],1
     33: mov     edi,0FFFFFFB8h
     38: lea     rsi,[k0]
     3f: mov     edx,10h
     44: call    ryo_h_Const
     49: lea     rdi,[sym1]
     50: lea     rsi,[site2]
     57: mov     edx,0FFFFFFC8h
     5c: call    ryo_h_CallExt
     61: test    rax,rax
     64: je      71h
     66: call    rax
     68: nop     [rcx-18h]
     6f: jmp     81h
     71: mov     rdi,rbp
     74: lea     rsi,[ro+4]
     7b: call    qword ptr [sym3]
     81: mov     edi,0FFFFFFCCh
     86: mov     esi,0FFFFFFE8h
     8b: mov     rdx,0FFFFFFFFFFFFFFFFh
     92: xor     ecx,ecx
     94: xor     r8d,r8d
     97: mov     r9d,1
     9d: call    ryo_h_DiscrNicheW64
     a2: mov     edi,0FFFFFFD0h
     a7: mov     esi,0FFFFFFCCh
     ac: call    ryo_h_ZextW32W64
     b1: mov     edi,0FFFFFFD0h
     b6: xor     esi,esi
     b8: mov     edx,2
     bd: call    ryo_h_SwitchDenseW64
     c2: lea     rcx,[0D4h]
     c9: movsxd  rax,[rcx+rax*4]
     cd: add     rax,rcx
     d0: jmp     rax
     d2: int3
     d3: int3
     d4: .long   13dh
     d8: .long   e0h
     dc: .long   148h
     e0: mov     edi,0FFFFFFD8h
     e5: mov     esi,0FFFFFFE8h
     ea: call    ryo_h_MovW128
     ef: mov     edi,0FFFFFFA0h
     f4: mov     esi,0FFFFFFD8h
     f9: call    ryo_h_MovW128
     fe: lea     rdi,[sym4]
    105: lea     rsi,[site5]
    10c: mov     edx,0FFFFFFC8h
    111: call    ryo_h_CallExt
    116: test    rax,rax
    119: je      126h
    11b: call    rax
    11d: nop     [rcx]
    124: jmp     136h
    126: mov     rdi,rbp
    129: lea     rsi,[ro+20]
    130: call    qword ptr [sym6]
    136: call    ryo_h_Unreachable
    13b: ud2
    13d: xor     edi,edi
    13f: xor     esi,esi
    141: call    ryo_h_Ret
    146: leave
    147: ret
    148: call    ryo_h_Unreachable
    14d: ud2

fn alloc::raw_vec::RawVecInner::with_capacity_in
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-90h],rax
     16: mov     byte ptr [rbp-88h],0
     1d: mov     edi,0FFFFFF80h
     22: mov     esi,18h
     27: call    ryo_h_MovW128
     2c: lea     rdi,[sym0]
     33: lea     rsi,[site1]
     3a: mov     edx,0FFFFFF90h
     3f: call    ryo_h_CallExt
     44: test    rax,rax
     47: je      54h
     49: call    rax
     4b: nop     [rcx-40h]
     52: jmp     64h
     54: mov     rdi,rbp
     57: lea     rsi,[ro+4]
     5e: call    qword ptr [sym2]
     64: mov     rax,[rbp-40h]
     68: mov     [rbp-18h],rax
     6c: mov     edi,0FFFFFFE8h
     71: xor     esi,esi
     73: mov     edx,2
     78: call    ryo_h_SwitchDenseW64
     7d: lea     rcx,[90h]
     84: movsxd  rax,[rcx+rax*4]
     88: add     rax,rcx
     8b: jmp     rax
     8d: int3
     8e: int3
     8f: int3
     90: .long   100h
     94: .long   a3h
     98: .long   9ch
     9c: call    ryo_h_Unreachable
     a1: ud2
     a3: mov     edi,0FFFFFFB0h
     a8: mov     esi,0FFFFFFC8h
     ad: call    ryo_h_MovW128
     b2: mov     edi,0FFFFFF70h
     b7: mov     esi,0FFFFFFB0h
     bc: call    ryo_h_MovW128
     c1: lea     rdi,[sym3]
     c8: lea     rsi,[site4]
     cf: mov     edx,0FFFFFF90h
     d4: call    ryo_h_CallExt
     d9: test    rax,rax
     dc: je      0E9h
     de: call    rax
     e0: nop     [rcx-20h]
     e7: jmp     0F9h
     e9: mov     rdi,rbp
     ec: lea     rsi,[ro+20]
     f3: call    qword ptr [sym5]
     f9: call    ryo_h_Unreachable
     fe: ud2
    100: mov     edi,0FFFFFFF0h
    105: mov     esi,0FFFFFFC8h
    10a: call    ryo_h_MovW128
    10f: mov     rax,[rbp+20h]
    113: mov     [rbp-60h],rax
    117: cmp     rax,0
    11b: je      14Ah
    11d: jmp     154h
    11f: nop
    120: mov     rax,[rbp-58h]
    124: sub     rax,0
    128: mov     [rbp-50h],rax
    12c: cmp     rax,[rbp+10h]
    130: setb    [rbp-42h]
    134: movzx   eax,byte ptr [rbp-42h]
    138: xor     al,1
    13b: mov     [rbp-41h],al
    13e: mov     byte ptr [rbp-69h],1
    142: test    byte ptr [rbp-69h],0FFh
    146: je      189h
    148: jmp     162h
    14a: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    152: jmp     120h
    154: mov     rax,[rbp-10h]
    158: mov     [rbp-68h],rax
    15c: mov     [rbp-58h],rax
    160: jmp     120h
    162: movzx   eax,byte ptr [rbp-41h]
    166: mov     [rbp-90h],al
    16c: mov     edi,0FFFFFF78h
    171: lea     rsi,[k6]
    178: call    ryo_h_AddrAbs
    17d: call    fn7
    182: nop     [rcx-28h]
    189: mov     edi,0FFFFFFF0h
    18e: mov     esi,10h
    193: call    ryo_h_Ret
    198: leave
    199: ret

fn checksum
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFB0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: call    fn0
     1c: nop     [rcx-30h]
     23: mov     edi,0FFFFFFB0h
     28: mov     esi,0FFFFFFD0h
     2d: call    ryo_h_MovW128
     32: call    fn1
     37: nop     [rcx-20h]
     3e: mov     edi,0FFFFFFB0h
     43: mov     esi,0FFFFFFE0h
     48: mov     edx,18h
     4d: call    ryo_h_Copy
     52: mov     qword ptr [rbp-38h],0
     5a: call    fn2
     5f: nop     [rcx-8]
     66: mov     edi,0FFFFFFF8h
     6b: mov     esi,8
     70: call    ryo_h_Ret
     75: leave
     76: ret

fn checksum::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp+28h]
     14: mov     [rbp-40h],rax
     18: mov     eax,[rax]
     1a: mov     [rbp-14h],eax
     1d: mov     rax,[rbp+18h]
     21: mov     [rbp-50h],rax
     25: mov     qword ptr [rbp-48h],1Fh
     2d: call    fn0
     32: nop     [rcx-20h]
     39: mov     edi,0FFFFFFD0h
     3e: mov     esi,0FFFFFFECh
     43: call    ryo_h_ZextW32W64
     48: mov     rax,[rbp-10h]
     4c: mov     [rbp-38h],rax
     50: mov     rax,[rbp-30h]
     54: xor     rax,[rbp-38h]
     58: mov     [rbp-28h],rax
     5c: mov     rax,[rbp-20h]
     60: mov     [rbp-50h],rax
     64: mov     rax,[rbp-28h]
     68: mov     [rbp-48h],rax
     6c: call    fn1
     71: nop     [rcx-8]
     78: mov     edi,0FFFFFFF8h
     7d: mov     esi,8
     82: call    ryo_h_Ret
     87: leave
     88: ret

fn core::fmt::num::<impl std::fmt::Debug for u32>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     eax,[rax+10h]
      f: mov     [rbp-0Ch],eax
     12: and     eax,2000000h
     18: mov     [rbp-8],eax
     1b: cmp     eax,0
     1e: setne   [rbp-2]
     22: test    byte ptr [rbp-2],0FFh
     26: je      75h
     28: mov     rax,[rbp+10h]
     2c: mov     [rbp-30h],rax
     30: mov     rax,[rbp+18h]
     34: mov     [rbp-28h],rax
     38: lea     rdi,[sym0]
     3f: lea     rsi,[site1]
     46: mov     edx,0FFFFFFE8h
     4b: call    ryo_h_CallExt
     50: test    rax,rax
     53: je      60h
     55: call    rax
     57: nop     [rcx-1]
     5e: jmp     70h
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym2]
     70: jmp     127h
     75: mov     rax,[rbp+18h]
     79: mov     eax,[rax+10h]
     7c: mov     [rbp-0Ch],eax
     7f: and     eax,4000000h
     85: mov     [rbp-8],eax
     88: cmp     eax,0
     8b: setne   [rbp-3]
     8f: test    byte ptr [rbp-3],0FFh
     93: je      0DFh
     95: mov     rax,[rbp+10h]
     99: mov     [rbp-30h],rax
     9d: mov     rax,[rbp+18h]
     a1: mov     [rbp-28h],rax
     a5: lea     rdi,[sym3]
     ac: lea     rsi,[site4]
     b3: mov     edx,0FFFFFFE8h
     b8: call    ryo_h_CallExt
     bd: test    rax,rax
     c0: je      0CDh
     c2: call    rax
     c4: nop     [rcx-1]
     cb: jmp     0DDh
     cd: mov     rdi,rbp
     d0: lea     rsi,[ro+4]
     d7: call    qword ptr [sym5]
     dd: jmp     127h
     df: mov     rax,[rbp+10h]
     e3: mov     [rbp-30h],rax
     e7: mov     rax,[rbp+18h]
     eb: mov     [rbp-28h],rax
     ef: lea     rdi,[sym6]
     f6: lea     rsi,[site7]
     fd: mov     edx,0FFFFFFE8h
    102: call    ryo_h_CallExt
    107: test    rax,rax
    10a: je      117h
    10c: call    rax
    10e: nop     [rcx-1]
    115: jmp     127h
    117: mov     rdi,rbp
    11a: lea     rsi,[ro+4]
    121: call    qword ptr [sym8]
    127: mov     edi,0FFFFFFFFh
    12c: mov     esi,1
    131: call    ryo_h_Ret
    136: leave
    137: ret

fn core::fmt::rt::Argument::<'_>::new_debug::<(u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFC0h
     19: lea     rsi,[sym0]
     20: call    ryo_h_AddrSym
     25: mov     rax,[rbp-40h]
     29: mov     [rbp-38h],rax
     2d: mov     rax,[rbp-30h]
     31: mov     [rbp-28h],rax
     35: mov     rax,[rbp-38h]
     39: mov     [rbp-20h],rax
     3d: mov     edi,0FFFFFFF0h
     42: mov     esi,0FFFFFFD8h
     47: call    ryo_h_MovW128
     4c: mov     edi,0FFFFFFF0h
     51: mov     esi,10h
     56: call    ryo_h_Ret
     5b: leave
     5c: ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFC0h
     19: lea     rsi,[sym0]
     20: call    ryo_h_AddrSym
     25: mov     rax,[rbp-40h]
     29: mov     [rbp-38h],rax
     2d: mov     rax,[rbp-30h]
     31: mov     [rbp-28h],rax
     35: mov     rax,[rbp-38h]
     39: mov     [rbp-20h],rax
     3d: mov     edi,0FFFFFFF0h
     42: mov     esi,0FFFFFFD8h
     47: call    ryo_h_MovW128
     4c: mov     edi,0FFFFFFF0h
     51: mov     esi,10h
     56: call    ryo_h_Ret
     5b: leave
     5c: ret

fn core::fmt::rt::Argument::<'_>::new_lower_hex::<u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFC0h
     19: lea     rsi,[sym0]
     20: call    ryo_h_AddrSym
     25: mov     rax,[rbp-40h]
     29: mov     [rbp-38h],rax
     2d: mov     rax,[rbp-30h]
     31: mov     [rbp-28h],rax
     35: mov     rax,[rbp-38h]
     39: mov     [rbp-20h],rax
     3d: mov     edi,0FFFFFFF0h
     42: mov     esi,0FFFFFFD8h
     47: call    ryo_h_MovW128
     4c: mov     edi,0FFFFFFF0h
     51: mov     esi,10h
     56: call    ryo_h_Ret
     5b: leave
     5c: ret

fn core::num::<impl u64>::wrapping_add
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: add     rax,[rbp+18h]
     10: mov     [rbp-8],rax
     14: mov     edi,0FFFFFFF8h
     19: mov     esi,8
     1e: call    ryo_h_Ret
     23: leave
     24: ret

fn core::num::<impl u64>::wrapping_mul
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: imul    rax,[rbp+18h]
     11: mov     [rbp-8],rax
     15: mov     edi,0FFFFFFF8h
     1a: mov     esi,8
     1f: call    ryo_h_Ret
     24: leave
     25: ret

fn core::num::<impl usize>::unchecked_add::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-38h],rax
     1b: mov     edi,0FFFFFFD8h
     20: mov     esi,0FFFFFFE0h
     25: mov     edx,0FFFFFFD0h
     2a: mov     ecx,0FFFFFFC8h
     2f: call    ryo_h_AddOvfUW64
     34: movzx   eax,byte ptr [rbp-20h]
     38: mov     [rbp-11h],al
     3b: test    byte ptr [rbp-11h],0FFh
     3f: je      119h
     45: mov     edi,0FFFFFFF0h
     4a: lea     rsi,[k0]
     51: call    ryo_h_AddrAbs
     56: mov     qword ptr [rbp-8],0BAh
     5e: mov     rax,[rbp-10h]
     62: mov     [rbp-48h],rax
     66: mov     rax,[rbp-8]
     6a: mov     [rbp-40h],rax
     6e: mov     rax,[rbp-48h]
     72: mov     [rbp-38h],rax
     76: mov     [rbp-30h],rax
     7a: mov     edi,0FFFFFFA0h
     7f: lea     rsi,[k1]
     86: call    ryo_h_AddrAbs
     8b: mov     qword ptr [rbp-58h],0BAh
     93: mov     rax,[rbp-58h]
     97: mov     [rbp-50h],rax
     9b: shl     rax,1
     9f: mov     [rbp-48h],rax
     a3: or      rax,1
     a7: mov     [rbp-40h],rax
     ab: mov     [rbp-38h],rax
     af: mov     rax,[rbp-30h]
     b3: mov     [rbp-28h],rax
     b7: mov     rax,[rbp-38h]
     bb: mov     [rbp-20h],rax
     bf: mov     edi,0FFFFFF70h
     c4: mov     esi,0FFFFFFD8h
     c9: call    ryo_h_MovW128
     ce: mov     byte ptr [rbp-80h],0
     d2: mov     rax,[rbp+20h]
     d6: mov     [rbp-78h],rax
     da: lea     rdi,[sym2]
     e1: lea     rsi,[site3]
     e8: mov     edx,0FFFFFF98h
     ed: call    ryo_h_CallExt
     f2: test    rax,rax
     f5: je      102h
     f7: call    rax
     f9: nop     [rcx-10h]
    100: jmp     112h
    102: mov     rdi,rbp
    105: lea     rsi,[ro+4]
    10c: call    qword ptr [sym4]
    112: call    ryo_h_Unreachable
    117: ud2
    119: xor     edi,edi
    11b: xor     esi,esi
    11d: call    ryo_h_Ret
    122: leave
    123: ret

fn core::num::<impl usize>::unchecked_sub::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-38h],rax
     1b: mov     edi,0FFFFFFD8h
     20: mov     esi,0FFFFFFE0h
     25: mov     edx,0FFFFFFD0h
     2a: mov     ecx,0FFFFFFC8h
     2f: call    ryo_h_SubOvfUW64
     34: movzx   eax,byte ptr [rbp-20h]
     38: mov     [rbp-11h],al
     3b: test    byte ptr [rbp-11h],0FFh
     3f: je      119h
     45: mov     edi,0FFFFFFF0h
     4a: lea     rsi,[k0]
     51: call    ryo_h_AddrAbs
     56: mov     qword ptr [rbp-8],0BAh
     5e: mov     rax,[rbp-10h]
     62: mov     [rbp-48h],rax
     66: mov     rax,[rbp-8]
     6a: mov     [rbp-40h],rax
     6e: mov     rax,[rbp-48h]
     72: mov     [rbp-38h],rax
     76: mov     [rbp-30h],rax
     7a: mov     edi,0FFFFFFA0h
     7f: lea     rsi,[k1]
     86: call    ryo_h_AddrAbs
     8b: mov     qword ptr [rbp-58h],0BAh
     93: mov     rax,[rbp-58h]
     97: mov     [rbp-50h],rax
     9b: shl     rax,1
     9f: mov     [rbp-48h],rax
     a3: or      rax,1
     a7: mov     [rbp-40h],rax
     ab: mov     [rbp-38h],rax
     af: mov     rax,[rbp-30h]
     b3: mov     [rbp-28h],rax
     b7: mov     rax,[rbp-38h]
     bb: mov     [rbp-20h],rax
     bf: mov     edi,0FFFFFF70h
     c4: mov     esi,0FFFFFFD8h
     c9: call    ryo_h_MovW128
     ce: mov     byte ptr [rbp-80h],0
     d2: mov     rax,[rbp+20h]
     d6: mov     [rbp-78h],rax
     da: lea     rdi,[sym2]
     e1: lea     rsi,[site3]
     e8: mov     edx,0FFFFFF98h
     ed: call    ryo_h_CallExt
     f2: test    rax,rax
     f5: je      102h
     f7: call    rax
     f9: nop     [rcx-10h]
    100: jmp     112h
    102: mov     rdi,rbp
    105: lea     rsi,[ro+4]
    10c: call    qword ptr [sym4]
    112: call    ryo_h_Unreachable
    117: ud2
    119: xor     edi,edi
    11b: xor     esi,esi
    11d: call    ryo_h_Ret
    122: leave
    123: ret

fn core::panicking::assert_failed::<std::vec::Vec<u32>, std::vec::Vec<u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: lea     rax,[rbp+10h]
      f: mov     [rbp-18h],rax
     13: mov     [rbp-10h],rax
     17: mov     edi,0FFFFFFF8h
     1c: lea     rsi,[k0]
     23: call    ryo_h_AddrAbs
     28: lea     rax,[rbp+18h]
     2c: mov     [rbp-30h],rax
     30: mov     [rbp-28h],rax
     34: mov     edi,0FFFFFFE0h
     39: lea     rsi,[k1]
     40: call    ryo_h_AddrAbs
     45: movzx   eax,byte ptr [rbp+30h]
     49: mov     [rbp-50h],al
     4c: mov     edi,0FFFFFF80h
     51: mov     esi,0FFFFFFF0h
     56: call    ryo_h_MovW128
     5b: mov     edi,0FFFFFF90h
     60: mov     esi,0FFFFFFD8h
     65: call    ryo_h_MovW128
     6a: mov     edi,0FFFFFFA0h
     6f: mov     esi,20h
     74: call    ryo_h_MovW128
     79: mov     rax,[rbp+38h]
     7d: mov     [rbp-48h],rax
     81: lea     rdi,[sym2]
     88: lea     rsi,[site3]
     8f: mov     edx,0FFFFFFC8h
     94: call    ryo_h_CallExt
     99: test    rax,rax
     9c: je      0A9h
     9e: call    rax
     a0: nop     [rcx]
     a7: jmp     0B9h
     a9: mov     rdi,rbp
     ac: lea     rsi,[ro+4]
     b3: call    qword ptr [sym4]
     b9: call    ryo_h_Unreachable
     be: ud2

fn core::slice::<impl [(u32, u32)]>::reverse
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-8],rax
     13: mov     qword ptr [rbp-70h],2
     1b: mov     edi,0FFFFFFB0h
     20: mov     esi,0FFFFFFF8h
     25: mov     edx,0FFFFFF90h
     2a: call    ryo_h_DivUW64
     2f: mov     rax,[rbp+10h]
     33: mov     [rbp-48h],rax
     37: mov     rax,[rbp+18h]
     3b: mov     [rbp-40h],rax
     3f: mov     rax,[rbp-48h]
     43: mov     [rbp-30h],rax
     47: imul    rcx,[rbp-8],8
     4c: add     rax,rcx
     4f: mov     [rbp-38h],rax
     53: mov     byte ptr [rbp-69h],1
     57: test    byte ptr [rbp-69h],0FFh
     5b: je      0B8h
     5d: jmp     6Bh
     5f: nop
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: mov     rax,[rbp-48h]
     6f: mov     [rbp-58h],rax
     73: mov     [rbp-0A0h],rax
     7a: mov     qword ptr [rbp-98h],8
     85: mov     qword ptr [rbp-90h],4
     90: mov     rax,[rbp-50h]
     94: mov     [rbp-88h],rax
     9b: mov     edi,0FFFFFF80h
     a0: lea     rsi,[k0]
     a7: call    ryo_h_AddrAbs
     ac: call    fn1
     b1: nop     [rcx-48h]
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-60h],rax
     c0: mov     rax,[rbp-50h]
     c4: mov     [rbp-58h],rax
     c8: mov     rax,[rbp-60h]
     cc: mov     [rbp-18h],rax
     d0: mov     rax,[rbp-58h]
     d4: mov     [rbp-10h],rax
     d8: mov     byte ptr [rbp-69h],0
     dc: test    byte ptr [rbp-69h],0FFh
     e0: je      10Ah
     e2: jmp     100h
     e4: nop     [rax+rax]
     ed: nop     [rax]
     f0: mov     byte ptr [rbp-69h],1
     f4: test    byte ptr [rbp-69h],0FFh
     f8: je      185h
     fe: jmp     138h
    100: mov     rax,[rbp-38h]
    104: mov     [rbp-58h],rax
    108: jmp     0F0h
    10a: mov     rax,[rbp-50h]
    10e: mov     [rbp-68h],rax
    112: mov     qword ptr [rbp-70h],0
    11a: mov     rax,[rbp-70h]
    11e: sub     rax,[rbp-68h]
    122: mov     [rbp-60h],rax
    126: mov     rax,[rbp-38h]
    12a: imul    rcx,[rbp-60h],8
    12f: add     rax,rcx
    132: mov     [rbp-58h],rax
    136: jmp     0F0h
    138: mov     rax,[rbp-58h]
    13c: mov     [rbp-60h],rax
    140: mov     [rbp-0A0h],rax
    147: mov     qword ptr [rbp-98h],8
    152: mov     qword ptr [rbp-90h],4
    15d: mov     rax,[rbp-50h]
    161: mov     [rbp-88h],rax
    168: mov     edi,0FFFFFF80h
    16d: lea     rsi,[k2]
    174: call    ryo_h_AddrAbs
    179: call    fn3
    17e: nop     [rcx-48h]
    185: mov     rax,[rbp-58h]
    189: mov     [rbp-68h],rax
    18d: mov     rax,[rbp-50h]
    191: mov     [rbp-60h],rax
    195: mov     rax,[rbp-68h]
    199: mov     [rbp-28h],rax
    19d: mov     rax,[rbp-60h]
    1a1: mov     [rbp-20h],rax
    1a5: mov     edi,0FFFFFF60h
    1aa: mov     esi,0FFFFFFE8h
    1af: call    ryo_h_MovW128
    1b4: mov     edi,0FFFFFF70h
    1b9: mov     esi,0FFFFFFD8h
    1be: call    ryo_h_MovW128
    1c3: mov     rax,[rbp-50h]
    1c7: mov     [rbp-80h],rax
    1cb: call    fn4
    1d0: nop     [rcx-28h]
    1d7: jmp     60h

fn core::slice::<impl [(u32, u32)]>::split_at_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-50h],rax
     13: cmp     rax,[rbp+20h]
     17: jb      89h
     19: mov     edi,0FFFFFF40h
     1e: mov     esi,10h
     23: call    ryo_h_MovW128
     28: mov     rax,[rbp+20h]
     2c: mov     [rbp-0B0h],rax
     33: mov     edi,0FFFFFF58h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: call    fn1
     49: nop     [rcx-68h]
     50: mov     edi,0FFFFFFC0h
     55: mov     esi,0FFFFFF98h
     5a: mov     edx,20h
     5f: call    ryo_h_Copy
     64: mov     edi,0FFFFFFE0h
     69: mov     esi,0FFFFFFC0h
     6e: mov     edx,20h
     73: call    ryo_h_Copy
     78: mov     edi,0FFFFFFE0h
     7d: mov     esi,20h
     82: call    ryo_h_Ret
     87: leave
     88: ret
     89: mov     edi,0FFFFFFA0h
     8e: lea     rsi,[k2]
     95: call    ryo_h_AddrAbs
     9a: mov     qword ptr [rbp-58h],9
     a2: mov     rax,[rbp-60h]
     a6: mov     [rbp-80h],rax
     aa: mov     rax,[rbp-58h]
     ae: mov     [rbp-78h],rax
     b2: mov     rax,[rbp-80h]
     b6: mov     [rbp-70h],rax
     ba: mov     [rbp-68h],rax
     be: mov     edi,0FFFFFF68h
     c3: lea     rsi,[k3]
     ca: call    ryo_h_AddrAbs
     cf: mov     qword ptr [rbp-90h],9
     da: mov     rax,[rbp-90h]
     e1: mov     [rbp-88h],rax
     e8: shl     rax,1
     ec: mov     [rbp-80h],rax
     f0: or      rax,1
     f4: mov     [rbp-78h],rax
     f8: mov     [rbp-70h],rax
     fc: mov     rax,[rbp-68h]
    100: mov     [rbp-50h],rax
    104: mov     rax,[rbp-70h]
    108: mov     [rbp-48h],rax
    10c: mov     edi,0FFFFFF40h
    111: mov     esi,0FFFFFFB0h
    116: call    ryo_h_MovW128
    11b: mov     rax,[rbp+28h]
    11f: mov     [rbp-0B0h],rax
    126: lea     rdi,[sym4]
    12d: lea     rsi,[site5]
    134: mov     edx,0FFFFFF60h
    139: call    ryo_h_CallExt
    13e: test    rax,rax
    141: je      14Eh
    143: call    rax
    145: nop     [rcx-20h]
    14c: jmp     15Eh
    14e: mov     rdi,rbp
    151: lea     rsi,[ro+4]
    158: call    qword ptr [sym6]
    15e: call    ryo_h_Unreachable
    163: ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-38h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-28h],rax
     23: mov     rax,[rbp-30h]
     27: mov     [rbp-40h],rax
     2b: mov     byte ptr [rbp-81h],1
     32: test    byte ptr [rbp-81h],0FFh
     39: je      68h
     3b: mov     rax,[rbp+20h]
     3f: mov     [rbp-0B0h],rax
     46: mov     rax,[rbp-38h]
     4a: mov     [rbp-0A8h],rax
     51: mov     rax,[rbp+28h]
     55: mov     [rbp-0A0h],rax
     5c: call    fn0
     61: nop     [rcx-20h]
     68: mov     byte ptr [rbp-81h],1
     6f: test    byte ptr [rbp-81h],0FFh
     76: je      0BFh
     78: mov     rax,[rbp-30h]
     7c: mov     [rbp-58h],rax
     80: mov     [rbp-0B0h],rax
     87: mov     qword ptr [rbp-0A8h],8
     92: mov     qword ptr [rbp-0A0h],4
     9d: mov     rax,[rbp+20h]
     a1: mov     [rbp-98h],rax
     a8: mov     rax,[rbp+28h]
     ac: mov     [rbp-90h],rax
     b3: call    fn1
     b8: nop     [rcx-30h]
     bf: mov     rax,[rbp-40h]
     c3: mov     [rbp-60h],rax
     c7: mov     rax,[rbp+20h]
     cb: mov     [rbp-58h],rax
     cf: mov     rax,[rbp-60h]
     d3: mov     [rbp-50h],rax
     d7: mov     rax,[rbp-58h]
     db: mov     [rbp-48h],rax
     df: mov     rax,[rbp-40h]
     e3: imul    rcx,[rbp+20h],8
     e8: add     rax,rcx
     eb: mov     [rbp-68h],rax
     ef: mov     rax,[rbp-38h]
     f3: sub     rax,[rbp+20h]
     f7: mov     [rbp-70h],rax
     fb: mov     byte ptr [rbp-81h],1
    102: test    byte ptr [rbp-81h],0FFh
    109: je      152h
    10b: mov     rax,[rbp-68h]
    10f: mov     [rbp-78h],rax
    113: mov     [rbp-0B0h],rax
    11a: mov     qword ptr [rbp-0A8h],8
    125: mov     qword ptr [rbp-0A0h],4
    130: mov     rax,[rbp-70h]
    134: mov     [rbp-98h],rax
    13b: mov     rax,[rbp+28h]
    13f: mov     [rbp-90h],rax
    146: call    fn2
    14b: nop     [rcx-30h]
    152: mov     rax,[rbp-68h]
    156: mov     [rbp-80h],rax
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-78h],rax
    162: mov     rax,[rbp-80h]
    166: mov     [rbp-60h],rax
    16a: mov     rax,[rbp-78h]
    16e: mov     [rbp-58h],rax
    172: mov     edi,0FFFFFFE0h
    177: mov     esi,0FFFFFFB0h
    17c: call    ryo_h_MovW128
    181: mov     edi,0FFFFFFF0h
    186: mov     esi,0FFFFFFA0h
    18b: call    ryo_h_MovW128
    190: mov     edi,0FFFFFFE0h
    195: mov     esi,20h
    19a: call    ryo_h_Ret
    19f: leave
    1a0: ret

fn core::slice::<impl [T]>::reverse::revswap::<(u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     edi,0FFFFFF50h
     10: mov     esi,10h
     15: call    ryo_h_MovW128
     1a: mov     rax,[rbp+30h]
     1e: mov     [rbp-0A0h],rax
     25: mov     edi,0FFFFFF68h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: call    fn1
     3b: nop     [rcx-60h]
     42: mov     edi,0FFFFFFC0h
     47: mov     esi,0FFFFFFA0h
     4c: call    ryo_h_MovW128
     51: mov     edi,0FFFFFF50h
     56: mov     esi,20h
     5b: call    ryo_h_MovW128
     60: mov     rax,[rbp+30h]
     64: mov     [rbp-0A0h],rax
     6b: mov     edi,0FFFFFF68h
     70: lea     rsi,[k2]
     77: call    ryo_h_AddrAbs
     7c: call    fn3
     81: nop     [rcx-70h]
     88: mov     edi,0FFFFFFB0h
     8d: mov     esi,0FFFFFF90h
     92: call    ryo_h_MovW128
     97: mov     qword ptr [rbp-58h],0
     9f: nop
     a0: mov     rax,[rbp-58h]
     a4: mov     [rbp-60h],rax
     a8: cmp     rax,[rbp+30h]
     ac: jae     247h
     b2: mov     rax,[rbp-58h]
     b6: mov     [rbp-60h],rax
     ba: mov     rax,[rbp-38h]
     be: mov     [rbp-10h],rax
     c2: mov     rax,[rbp-60h]
     c6: cmp     rax,[rbp-10h]
     ca: jb      12Eh
     cc: mov     [rbp-0B0h],rax
     d3: mov     rax,[rbp-10h]
     d7: mov     [rbp-0A8h],rax
     de: mov     edi,0FFFFFF60h
     e3: lea     rsi,[k4]
     ea: call    ryo_h_AddrAbs
     ef: lea     rdi,[sym5]
     f6: lea     rsi,[site6]
     fd: mov     edx,0FFFFFF80h
    102: call    ryo_h_CallExt
    107: test    rax,rax
    10a: je      117h
    10c: call    rax
    10e: nop     [rcx-78h]
    115: jmp     127h
    117: mov     rdi,rbp
    11a: lea     rsi,[ro+4]
    121: call    qword ptr [sym7]
    127: call    ryo_h_Unreachable
    12c: ud2
    12e: mov     rax,[rbp-40h]
    132: imul    rcx,[rbp-60h],8
    137: add     rax,rcx
    13a: mov     [rbp-80h],rax
    13e: mov     [rbp-8],rax
    142: mov     rax,[rbp+30h]
    146: sub     rax,1
    14a: mov     [rbp-70h],rax
    14e: mov     rax,[rbp-58h]
    152: mov     [rbp-78h],rax
    156: mov     rax,[rbp-70h]
    15a: sub     rax,[rbp-78h]
    15e: mov     [rbp-68h],rax
    162: mov     rax,[rbp-48h]
    166: mov     [rbp-28h],rax
    16a: mov     rax,[rbp-68h]
    16e: cmp     rax,[rbp-28h]
    172: jb      1D6h
    174: mov     [rbp-0B0h],rax
    17b: mov     rax,[rbp-28h]
    17f: mov     [rbp-0A8h],rax
    186: mov     edi,0FFFFFF60h
    18b: lea     rsi,[k8]
    192: call    ryo_h_AddrAbs
    197: lea     rdi,[sym9]
    19e: lea     rsi,[site10]
    1a5: mov     edx,0FFFFFF80h
    1aa: call    ryo_h_CallExt
    1af: test    rax,rax
    1b2: je      1BFh
    1b4: call    rax
    1b6: nop     [rcx-78h]
    1bd: jmp     1CFh
    1bf: mov     rdi,rbp
    1c2: lea     rsi,[ro+4]
    1c9: call    qword ptr [sym11]
    1cf: call    ryo_h_Unreachable
    1d4: ud2
    1d6: mov     rax,[rbp-50h]
    1da: imul    rcx,[rbp-68h],8
    1df: add     rax,rcx
    1e2: mov     [rbp-80h],rax
    1e6: mov     [rbp-20h],rax
    1ea: mov     rax,[rbp-8]
    1ee: mov     [rbp-70h],rax
    1f2: mov     rax,[rbp-20h]
    1f6: mov     [rbp-78h],rax
    1fa: mov     qword ptr [rbp-88h],8
    205: mov     edi,0FFFFFF80h
    20a: mov     esi,0FFFFFF90h
    20f: xor     edx,edx
    211: mov     ecx,8
    216: call    ryo_h_LoadCopy
    21b: mov     edi,0FFFFFF90h
    220: mov     esi,0FFFFFF88h
    225: mov     edx,0FFFFFF78h
    22a: call    ryo_h_Memcpy
    22f: mov     edi,0FFFFFF88h
    234: xor     esi,esi
    236: mov     edx,0FFFFFF80h
    23b: mov     ecx,8
    240: call    ryo_h_StoreCopy
    245: jmp     252h
    247: xor     edi,edi
    249: xor     esi,esi
    24b: call    ryo_h_Ret
    250: leave
    251: ret
    252: mov     rax,[rbp-58h]
    256: add     rax,1
    25a: mov     [rbp-58h],rax
    25e: jmp     0A0h

fn core::slice::<impl [T]>::reverse::revswap::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     edi,0FFFFFF50h
     10: mov     esi,10h
     15: call    ryo_h_MovW128
     1a: mov     rax,[rbp+30h]
     1e: mov     [rbp-0A0h],rax
     25: mov     edi,0FFFFFF68h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: call    fn1
     3b: nop     [rcx-60h]
     42: mov     edi,0FFFFFFC0h
     47: mov     esi,0FFFFFFA0h
     4c: call    ryo_h_MovW128
     51: mov     edi,0FFFFFF50h
     56: mov     esi,20h
     5b: call    ryo_h_MovW128
     60: mov     rax,[rbp+30h]
     64: mov     [rbp-0A0h],rax
     6b: mov     edi,0FFFFFF68h
     70: lea     rsi,[k2]
     77: call    ryo_h_AddrAbs
     7c: call    fn3
     81: nop     [rcx-70h]
     88: mov     edi,0FFFFFFB0h
     8d: mov     esi,0FFFFFF90h
     92: call    ryo_h_MovW128
     97: mov     qword ptr [rbp-58h],0
     9f: nop
     a0: mov     rax,[rbp-58h]
     a4: mov     [rbp-60h],rax
     a8: cmp     rax,[rbp+30h]
     ac: jae     247h
     b2: mov     rax,[rbp-58h]
     b6: mov     [rbp-60h],rax
     ba: mov     rax,[rbp-38h]
     be: mov     [rbp-10h],rax
     c2: mov     rax,[rbp-60h]
     c6: cmp     rax,[rbp-10h]
     ca: jb      12Eh
     cc: mov     [rbp-0B0h],rax
     d3: mov     rax,[rbp-10h]
     d7: mov     [rbp-0A8h],rax
     de: mov     edi,0FFFFFF60h
     e3: lea     rsi,[k4]
     ea: call    ryo_h_AddrAbs
     ef: lea     rdi,[sym5]
     f6: lea     rsi,[site6]
     fd: mov     edx,0FFFFFF80h
    102: call    ryo_h_CallExt
    107: test    rax,rax
    10a: je      117h
    10c: call    rax
    10e: nop     [rcx-78h]
    115: jmp     127h
    117: mov     rdi,rbp
    11a: lea     rsi,[ro+4]
    121: call    qword ptr [sym7]
    127: call    ryo_h_Unreachable
    12c: ud2
    12e: mov     rax,[rbp-40h]
    132: imul    rcx,[rbp-60h],4
    137: add     rax,rcx
    13a: mov     [rbp-80h],rax
    13e: mov     [rbp-8],rax
    142: mov     rax,[rbp+30h]
    146: sub     rax,1
    14a: mov     [rbp-70h],rax
    14e: mov     rax,[rbp-58h]
    152: mov     [rbp-78h],rax
    156: mov     rax,[rbp-70h]
    15a: sub     rax,[rbp-78h]
    15e: mov     [rbp-68h],rax
    162: mov     rax,[rbp-48h]
    166: mov     [rbp-28h],rax
    16a: mov     rax,[rbp-68h]
    16e: cmp     rax,[rbp-28h]
    172: jb      1D6h
    174: mov     [rbp-0B0h],rax
    17b: mov     rax,[rbp-28h]
    17f: mov     [rbp-0A8h],rax
    186: mov     edi,0FFFFFF60h
    18b: lea     rsi,[k8]
    192: call    ryo_h_AddrAbs
    197: lea     rdi,[sym9]
    19e: lea     rsi,[site10]
    1a5: mov     edx,0FFFFFF80h
    1aa: call    ryo_h_CallExt
    1af: test    rax,rax
    1b2: je      1BFh
    1b4: call    rax
    1b6: nop     [rcx-78h]
    1bd: jmp     1CFh
    1bf: mov     rdi,rbp
    1c2: lea     rsi,[ro+4]
    1c9: call    qword ptr [sym11]
    1cf: call    ryo_h_Unreachable
    1d4: ud2
    1d6: mov     rax,[rbp-50h]
    1da: imul    rcx,[rbp-68h],4
    1df: add     rax,rcx
    1e2: mov     [rbp-80h],rax
    1e6: mov     [rbp-20h],rax
    1ea: mov     rax,[rbp-8]
    1ee: mov     [rbp-70h],rax
    1f2: mov     rax,[rbp-20h]
    1f6: mov     [rbp-78h],rax
    1fa: mov     qword ptr [rbp-88h],4
    205: mov     edi,0FFFFFF80h
    20a: mov     esi,0FFFFFF90h
    20f: xor     edx,edx
    211: mov     ecx,4
    216: call    ryo_h_LoadCopy
    21b: mov     edi,0FFFFFF90h
    220: mov     esi,0FFFFFF88h
    225: mov     edx,0FFFFFF78h
    22a: call    ryo_h_Memcpy
    22f: mov     edi,0FFFFFF88h
    234: xor     esi,esi
    236: mov     edx,0FFFFFF80h
    23b: mov     ecx,4
    240: call    ryo_h_StoreCopy
    245: jmp     252h
    247: xor     edi,edi
    249: xor     esi,esi
    24b: call    ryo_h_Ret
    250: leave
    251: ret
    252: mov     rax,[rbp-58h]
    256: add     rax,1
    25a: mov     [rbp-58h],rax
    25e: jmp     0A0h

fn core::slice::<impl [T]>::split_at_mut_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jb      20h
     15: xor     edi,edi
     17: xor     esi,esi
     19: call    ryo_h_Ret
     1e: leave
     1f: ret
     20: mov     edi,0FFFFFFF0h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: mov     qword ptr [rbp-8],0DDh
     39: mov     rax,[rbp-10h]
     3d: mov     [rbp-48h],rax
     41: mov     rax,[rbp-8]
     45: mov     [rbp-40h],rax
     49: mov     rax,[rbp-48h]
     4d: mov     [rbp-38h],rax
     51: mov     [rbp-30h],rax
     55: mov     edi,0FFFFFFA0h
     5a: lea     rsi,[k1]
     61: call    ryo_h_AddrAbs
     66: mov     qword ptr [rbp-58h],0DDh
     6e: mov     rax,[rbp-58h]
     72: mov     [rbp-50h],rax
     76: shl     rax,1
     7a: mov     [rbp-48h],rax
     7e: or      rax,1
     82: mov     [rbp-40h],rax
     86: mov     [rbp-38h],rax
     8a: mov     rax,[rbp-30h]
     8e: mov     [rbp-28h],rax
     92: mov     rax,[rbp-38h]
     96: mov     [rbp-20h],rax
     9a: mov     edi,0FFFFFF70h
     9f: mov     esi,0FFFFFFD8h
     a4: call    ryo_h_MovW128
     a9: mov     byte ptr [rbp-80h],0
     ad: mov     rax,[rbp+20h]
     b1: mov     [rbp-78h],rax
     b5: lea     rdi,[sym2]
     bc: lea     rsi,[site3]
     c3: mov     edx,0FFFFFF98h
     c8: call    ryo_h_CallExt
     cd: test    rax,rax
     d0: je      0DDh
     d2: call    rax
     d4: nop     [rcx-10h]
     db: jmp     0EDh
     dd: mov     rdi,rbp
     e0: lea     rsi,[ro+4]
     e7: call    qword ptr [sym4]
     ed: call    ryo_h_Unreachable
     f2: ud2

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jae     2Ah
     15: mov     rax,[rbp+20h]
     19: cmp     rax,[rbp+10h]
     1d: jae     2Ah
     1f: xor     edi,edi
     21: xor     esi,esi
     23: call    ryo_h_Ret
     28: leave
     29: ret
     2a: mov     edi,0FFFFFFF0h
     2f: lea     rsi,[k0]
     36: call    ryo_h_AddrAbs
     3b: mov     qword ptr [rbp-8],0DAh
     43: mov     rax,[rbp-10h]
     47: mov     [rbp-48h],rax
     4b: mov     rax,[rbp-8]
     4f: mov     [rbp-40h],rax
     53: mov     rax,[rbp-48h]
     57: mov     [rbp-38h],rax
     5b: mov     [rbp-30h],rax
     5f: mov     edi,0FFFFFFA0h
     64: lea     rsi,[k1]
     6b: call    ryo_h_AddrAbs
     70: mov     qword ptr [rbp-58h],0DAh
     78: mov     rax,[rbp-58h]
     7c: mov     [rbp-50h],rax
     80: shl     rax,1
     84: mov     [rbp-48h],rax
     88: or      rax,1
     8c: mov     [rbp-40h],rax
     90: mov     [rbp-38h],rax
     94: mov     rax,[rbp-30h]
     98: mov     [rbp-28h],rax
     9c: mov     rax,[rbp-38h]
     a0: mov     [rbp-20h],rax
     a4: mov     edi,0FFFFFF70h
     a9: mov     esi,0FFFFFFD8h
     ae: call    ryo_h_MovW128
     b3: mov     byte ptr [rbp-80h],0
     b7: mov     rax,[rbp+28h]
     bb: mov     [rbp-78h],rax
     bf: lea     rdi,[sym2]
     c6: lea     rsi,[site3]
     cd: mov     edx,0FFFFFF98h
     d2: call    ryo_h_CallExt
     d7: test    rax,rax
     da: je      0E7h
     dc: call    rax
     de: nop     [rcx-10h]
     e5: jmp     0F7h
     e7: mov     rdi,rbp
     ea: lea     rsi,[ro+4]
     f1: call    qword ptr [sym4]
     f7: call    ryo_h_Unreachable
     fc: ud2

fn core::slice::<impl [u32]>::copy_from_slice
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFE0h
     1c: mov     esi,20h
     21: call    ryo_h_MovW128
     26: mov     rax,[rbp+30h]
     2a: mov     [rbp-10h],rax
     2e: call    fn0
     33: nop     [rcx]
     3a: xor     edi,edi
     3c: xor     esi,esi
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn core::slice::<impl [u32]>::iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFE0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: call    fn0
     1c: nop     [rcx-10h]
     23: mov     edi,0FFFFFFF0h
     28: mov     esi,10h
     2d: call    ryo_h_Ret
     32: leave
     33: ret

fn core::slice::<impl [u32]>::reverse
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-8],rax
     13: mov     qword ptr [rbp-70h],2
     1b: mov     edi,0FFFFFFB0h
     20: mov     esi,0FFFFFFF8h
     25: mov     edx,0FFFFFF90h
     2a: call    ryo_h_DivUW64
     2f: mov     rax,[rbp+10h]
     33: mov     [rbp-48h],rax
     37: mov     rax,[rbp+18h]
     3b: mov     [rbp-40h],rax
     3f: mov     rax,[rbp-48h]
     43: mov     [rbp-30h],rax
     47: imul    rcx,[rbp-8],4
     4c: add     rax,rcx
     4f: mov     [rbp-38h],rax
     53: mov     byte ptr [rbp-69h],1
     57: test    byte ptr [rbp-69h],0FFh
     5b: je      0B8h
     5d: jmp     6Bh
     5f: nop
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: mov     rax,[rbp-48h]
     6f: mov     [rbp-58h],rax
     73: mov     [rbp-0A0h],rax
     7a: mov     qword ptr [rbp-98h],4
     85: mov     qword ptr [rbp-90h],4
     90: mov     rax,[rbp-50h]
     94: mov     [rbp-88h],rax
     9b: mov     edi,0FFFFFF80h
     a0: lea     rsi,[k0]
     a7: call    ryo_h_AddrAbs
     ac: call    fn1
     b1: nop     [rcx-48h]
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-60h],rax
     c0: mov     rax,[rbp-50h]
     c4: mov     [rbp-58h],rax
     c8: mov     rax,[rbp-60h]
     cc: mov     [rbp-18h],rax
     d0: mov     rax,[rbp-58h]
     d4: mov     [rbp-10h],rax
     d8: mov     byte ptr [rbp-69h],0
     dc: test    byte ptr [rbp-69h],0FFh
     e0: je      10Ah
     e2: jmp     100h
     e4: nop     [rax+rax]
     ed: nop     [rax]
     f0: mov     byte ptr [rbp-69h],1
     f4: test    byte ptr [rbp-69h],0FFh
     f8: je      185h
     fe: jmp     138h
    100: mov     rax,[rbp-38h]
    104: mov     [rbp-58h],rax
    108: jmp     0F0h
    10a: mov     rax,[rbp-50h]
    10e: mov     [rbp-68h],rax
    112: mov     qword ptr [rbp-70h],0
    11a: mov     rax,[rbp-70h]
    11e: sub     rax,[rbp-68h]
    122: mov     [rbp-60h],rax
    126: mov     rax,[rbp-38h]
    12a: imul    rcx,[rbp-60h],4
    12f: add     rax,rcx
    132: mov     [rbp-58h],rax
    136: jmp     0F0h
    138: mov     rax,[rbp-58h]
    13c: mov     [rbp-60h],rax
    140: mov     [rbp-0A0h],rax
    147: mov     qword ptr [rbp-98h],4
    152: mov     qword ptr [rbp-90h],4
    15d: mov     rax,[rbp-50h]
    161: mov     [rbp-88h],rax
    168: mov     edi,0FFFFFF80h
    16d: lea     rsi,[k2]
    174: call    ryo_h_AddrAbs
    179: call    fn3
    17e: nop     [rcx-48h]
    185: mov     rax,[rbp-58h]
    189: mov     [rbp-68h],rax
    18d: mov     rax,[rbp-50h]
    191: mov     [rbp-60h],rax
    195: mov     rax,[rbp-68h]
    199: mov     [rbp-28h],rax
    19d: mov     rax,[rbp-60h]
    1a1: mov     [rbp-20h],rax
    1a5: mov     edi,0FFFFFF60h
    1aa: mov     esi,0FFFFFFE8h
    1af: call    ryo_h_MovW128
    1b4: mov     edi,0FFFFFF70h
    1b9: mov     esi,0FFFFFFD8h
    1be: call    ryo_h_MovW128
    1c3: mov     rax,[rbp-50h]
    1c7: mov     [rbp-80h],rax
    1cb: call    fn4
    1d0: nop     [rcx-28h]
    1d7: jmp     60h

fn core::slice::<impl [u32]>::sort_unstable
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: lea     rax,[rbp]
      c: mov     [rbp-8],rax
     10: mov     edi,0FFFFFFE0h
     15: mov     esi,10h
     1a: call    ryo_h_MovW128
     1f: mov     rax,[rbp-8]
     23: mov     [rbp-10h],rax
     27: call    fn0
     2c: nop     [rcx]
     33: xor     edi,edi
     35: xor     esi,esi
     37: call    ryo_h_Ret
     3c: leave
     3d: ret

fn core::slice::<impl [u32]>::split_at_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-50h],rax
     13: cmp     rax,[rbp+20h]
     17: jb      89h
     19: mov     edi,0FFFFFF40h
     1e: mov     esi,10h
     23: call    ryo_h_MovW128
     28: mov     rax,[rbp+20h]
     2c: mov     [rbp-0B0h],rax
     33: mov     edi,0FFFFFF58h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: call    fn1
     49: nop     [rcx-68h]
     50: mov     edi,0FFFFFFC0h
     55: mov     esi,0FFFFFF98h
     5a: mov     edx,20h
     5f: call    ryo_h_Copy
     64: mov     edi,0FFFFFFE0h
     69: mov     esi,0FFFFFFC0h
     6e: mov     edx,20h
     73: call    ryo_h_Copy
     78: mov     edi,0FFFFFFE0h
     7d: mov     esi,20h
     82: call    ryo_h_Ret
     87: leave
     88: ret
     89: mov     edi,0FFFFFFA0h
     8e: lea     rsi,[k2]
     95: call    ryo_h_AddrAbs
     9a: mov     qword ptr [rbp-58h],9
     a2: mov     rax,[rbp-60h]
     a6: mov     [rbp-80h],rax
     aa: mov     rax,[rbp-58h]
     ae: mov     [rbp-78h],rax
     b2: mov     rax,[rbp-80h]
     b6: mov     [rbp-70h],rax
     ba: mov     [rbp-68h],rax
     be: mov     edi,0FFFFFF68h
     c3: lea     rsi,[k3]
     ca: call    ryo_h_AddrAbs
     cf: mov     qword ptr [rbp-90h],9
     da: mov     rax,[rbp-90h]
     e1: mov     [rbp-88h],rax
     e8: shl     rax,1
     ec: mov     [rbp-80h],rax
     f0: or      rax,1
     f4: mov     [rbp-78h],rax
     f8: mov     [rbp-70h],rax
     fc: mov     rax,[rbp-68h]
    100: mov     [rbp-50h],rax
    104: mov     rax,[rbp-70h]
    108: mov     [rbp-48h],rax
    10c: mov     edi,0FFFFFF40h
    111: mov     esi,0FFFFFFB0h
    116: call    ryo_h_MovW128
    11b: mov     rax,[rbp+28h]
    11f: mov     [rbp-0B0h],rax
    126: lea     rdi,[sym4]
    12d: lea     rsi,[site5]
    134: mov     edx,0FFFFFF60h
    139: call    ryo_h_CallExt
    13e: test    rax,rax
    141: je      14Eh
    143: call    rax
    145: nop     [rcx-20h]
    14c: jmp     15Eh
    14e: mov     rdi,rbp
    151: lea     rsi,[ro+4]
    158: call    qword ptr [sym6]
    15e: call    ryo_h_Unreachable
    163: ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-38h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-28h],rax
     23: mov     rax,[rbp-30h]
     27: mov     [rbp-40h],rax
     2b: mov     byte ptr [rbp-81h],1
     32: test    byte ptr [rbp-81h],0FFh
     39: je      68h
     3b: mov     rax,[rbp+20h]
     3f: mov     [rbp-0B0h],rax
     46: mov     rax,[rbp-38h]
     4a: mov     [rbp-0A8h],rax
     51: mov     rax,[rbp+28h]
     55: mov     [rbp-0A0h],rax
     5c: call    fn0
     61: nop     [rcx-20h]
     68: mov     byte ptr [rbp-81h],1
     6f: test    byte ptr [rbp-81h],0FFh
     76: je      0BFh
     78: mov     rax,[rbp-30h]
     7c: mov     [rbp-58h],rax
     80: mov     [rbp-0B0h],rax
     87: mov     qword ptr [rbp-0A8h],4
     92: mov     qword ptr [rbp-0A0h],4
     9d: mov     rax,[rbp+20h]
     a1: mov     [rbp-98h],rax
     a8: mov     rax,[rbp+28h]
     ac: mov     [rbp-90h],rax
     b3: call    fn1
     b8: nop     [rcx-30h]
     bf: mov     rax,[rbp-40h]
     c3: mov     [rbp-60h],rax
     c7: mov     rax,[rbp+20h]
     cb: mov     [rbp-58h],rax
     cf: mov     rax,[rbp-60h]
     d3: mov     [rbp-50h],rax
     d7: mov     rax,[rbp-58h]
     db: mov     [rbp-48h],rax
     df: mov     rax,[rbp-40h]
     e3: imul    rcx,[rbp+20h],4
     e8: add     rax,rcx
     eb: mov     [rbp-68h],rax
     ef: mov     rax,[rbp-38h]
     f3: sub     rax,[rbp+20h]
     f7: mov     [rbp-70h],rax
     fb: mov     byte ptr [rbp-81h],1
    102: test    byte ptr [rbp-81h],0FFh
    109: je      152h
    10b: mov     rax,[rbp-68h]
    10f: mov     [rbp-78h],rax
    113: mov     [rbp-0B0h],rax
    11a: mov     qword ptr [rbp-0A8h],4
    125: mov     qword ptr [rbp-0A0h],4
    130: mov     rax,[rbp-70h]
    134: mov     [rbp-98h],rax
    13b: mov     rax,[rbp+28h]
    13f: mov     [rbp-90h],rax
    146: call    fn2
    14b: nop     [rcx-30h]
    152: mov     rax,[rbp-68h]
    156: mov     [rbp-80h],rax
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-78h],rax
    162: mov     rax,[rbp-80h]
    166: mov     [rbp-60h],rax
    16a: mov     rax,[rbp-78h]
    16e: mov     [rbp-58h],rax
    172: mov     edi,0FFFFFFE0h
    177: mov     esi,0FFFFFFB0h
    17c: call    ryo_h_MovW128
    181: mov     edi,0FFFFFFF0h
    186: mov     esi,0FFFFFFA0h
    18b: call    ryo_h_MovW128
    190: mov     edi,0FFFFFFE0h
    195: mov     esi,20h
    19a: call    ryo_h_Ret
    19f: leave
    1a0: ret

fn core::slice::<impl [u32]>::swap
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+20h]
     14: cmp     rax,[rbp-8]
     18: jb      6Dh
     1a: mov     [rbp-40h],rax
     1e: mov     rax,[rbp-8]
     22: mov     [rbp-38h],rax
     26: mov     rax,[rbp+30h]
     2a: mov     [rbp-30h],rax
     2e: lea     rdi,[sym0]
     35: lea     rsi,[site1]
     3c: mov     edx,0FFFFFFE8h
     41: call    ryo_h_CallExt
     46: test    rax,rax
     49: je      56h
     4b: call    rax
     4d: nop     [rcx-0Ah]
     54: jmp     66h
     56: mov     rdi,rbp
     59: lea     rsi,[ro+4]
     60: call    qword ptr [sym2]
     66: call    ryo_h_Unreachable
     6b: ud2
     6d: mov     rax,[rbp+28h]
     71: cmp     rax,[rbp-8]
     75: jb      0CAh
     77: mov     [rbp-40h],rax
     7b: mov     rax,[rbp-8]
     7f: mov     [rbp-38h],rax
     83: mov     rax,[rbp+30h]
     87: mov     [rbp-30h],rax
     8b: lea     rdi,[sym3]
     92: lea     rsi,[site4]
     99: mov     edx,0FFFFFFE8h
     9e: call    ryo_h_CallExt
     a3: test    rax,rax
     a6: je      0B3h
     a8: call    rax
     aa: nop     [rcx-0Ah]
     b1: jmp     0C3h
     b3: mov     rdi,rbp
     b6: lea     rsi,[ro+4]
     bd: call    qword ptr [sym5]
     c3: call    ryo_h_Unreachable
     c8: ud2
     ca: mov     edi,0FFFFFFC0h
     cf: mov     esi,10h
     d4: call    ryo_h_MovW128
     d9: mov     rax,[rbp+20h]
     dd: mov     [rbp-30h],rax
     e1: mov     rax,[rbp+28h]
     e5: mov     [rbp-28h],rax
     e9: mov     rax,[rbp+30h]
     ed: mov     [rbp-20h],rax
     f1: call    fn6
     f6: nop     [rcx-0Ah]
     fd: xor     edi,edi
     ff: xor     esi,esi
    101: call    ryo_h_Ret
    106: leave
    107: ret

fn core::slice::<impl [u32]>::swap_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-19h],1
      c: test    byte ptr [rbp-19h],0FFh
     10: je      42h
     12: mov     rax,[rbp+18h]
     16: mov     [rbp-8],rax
     1a: mov     [rbp-40h],rax
     1e: mov     rax,[rbp+20h]
     22: mov     [rbp-38h],rax
     26: mov     rax,[rbp+28h]
     2a: mov     [rbp-30h],rax
     2e: mov     rax,[rbp+30h]
     32: mov     [rbp-28h],rax
     36: call    fn0
     3b: nop     [rcx]
     42: mov     rax,[rbp+10h]
     46: mov     [rbp-18h],rax
     4a: mov     rax,[rbp+18h]
     4e: mov     [rbp-10h],rax
     52: mov     rax,[rbp-18h]
     56: mov     [rbp-8],rax
     5a: imul    rcx,[rbp+20h],4
     5f: add     rax,rcx
     62: mov     [rbp-10h],rax
     66: mov     rax,[rbp-8]
     6a: imul    rcx,[rbp+28h],4
     6f: add     rax,rcx
     72: mov     [rbp-18h],rax
     76: mov     rax,[rbp-10h]
     7a: mov     [rbp-40h],rax
     7e: mov     rax,[rbp-18h]
     82: mov     [rbp-38h],rax
     86: call    fn1
     8b: nop     [rcx]
     92: xor     edi,edi
     94: xor     esi,esi
     96: call    ryo_h_Ret
     9b: leave
     9c: ret

fn core::slice::copy_from_slice_impl::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+28h]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-8]
     1f: cmp     rax,[rbp-10h]
     23: je      7Eh
     25: mov     [rbp-90h],rax
     2c: mov     rax,[rbp-10h]
     30: mov     [rbp-88h],rax
     37: mov     rax,[rbp+30h]
     3b: mov     [rbp-80h],rax
     3f: lea     rdi,[sym0]
     46: lea     rsi,[site1]
     4d: mov     edx,0FFFFFFA8h
     52: call    ryo_h_CallExt
     57: test    rax,rax
     5a: je      67h
     5c: call    rax
     5e: nop     [rcx-10h]
     65: jmp     77h
     67: mov     rdi,rbp
     6a: lea     rsi,[ro+4]
     71: call    qword ptr [sym2]
     77: call    ryo_h_Unreachable
     7c: ud2
     7e: mov     rax,[rbp+20h]
     82: mov     [rbp-20h],rax
     86: mov     rax,[rbp+28h]
     8a: mov     [rbp-18h],rax
     8e: mov     rax,[rbp-20h]
     92: mov     [rbp-38h],rax
     96: mov     rax,[rbp+10h]
     9a: mov     [rbp-30h],rax
     9e: mov     rax,[rbp+18h]
     a2: mov     [rbp-28h],rax
     a6: mov     rax,[rbp-30h]
     aa: mov     [rbp-40h],rax
     ae: mov     byte ptr [rbp-51h],1
     b2: test    byte ptr [rbp-51h],0FFh
     b6: je      113h
     b8: mov     rax,[rbp-20h]
     bc: mov     [rbp-48h],rax
     c0: mov     rax,[rbp-30h]
     c4: mov     [rbp-50h],rax
     c8: mov     rax,[rbp-48h]
     cc: mov     [rbp-90h],rax
     d3: mov     rax,[rbp-50h]
     d7: mov     [rbp-88h],rax
     de: mov     qword ptr [rbp-80h],4
     e6: mov     qword ptr [rbp-78h],4
     ee: mov     rax,[rbp-8]
     f2: mov     [rbp-70h],rax
     f6: mov     edi,0FFFFFF98h
     fb: lea     rsi,[k3]
    102: call    ryo_h_AddrAbs
    107: call    fn4
    10c: nop     [rcx-30h]
    113: imul    rax,[rbp-8],4
    118: mov     [rbp-58h],rax
    11c: mov     edi,0FFFFFFC0h
    121: mov     esi,0FFFFFFC8h
    126: mov     edx,0FFFFFFA8h
    12b: call    ryo_h_Memcpy
    130: xor     edi,edi
    132: xor     esi,esi
    134: call    ryo_h_Ret
    139: leave
    13a: ret

fn core::slice::index::<impl std::ops::Index<std::ops::Range<usize>> for [u32]>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,20h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFC0h
     1c: mov     esi,10h
     21: call    ryo_h_MovW128
     26: mov     rax,[rbp+30h]
     2a: mov     [rbp-20h],rax
     2e: call    fn0
     33: nop     [rcx-10h]
     3a: mov     edi,0FFFFFFF0h
     3f: mov     esi,10h
     44: call    ryo_h_Ret
     49: leave
     4a: ret

fn core::slice::index::<impl std::ops::Index<std::ops::RangeFrom<usize>> for [u32]>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: call    ryo_h_MovW128
     1f: mov     rax,[rbp+28h]
     23: mov     [rbp-18h],rax
     27: call    fn0
     2c: nop     [rcx-10h]
     33: mov     edi,0FFFFFFF0h
     38: mov     esi,10h
     3d: call    ryo_h_Ret
     42: leave
     43: ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeFrom<usize>> for [u32]>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: call    ryo_h_MovW128
     1f: mov     rax,[rbp+28h]
     23: mov     [rbp-18h],rax
     27: call    fn0
     2c: nop     [rcx-10h]
     33: mov     edi,0FFFFFFF0h
     38: mov     esi,10h
     3d: call    ryo_h_Ret
     42: leave
     43: ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeTo<usize>> for [u32]>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: call    ryo_h_MovW128
     1f: mov     rax,[rbp+28h]
     23: mov     [rbp-18h],rax
     27: call    fn0
     2c: nop     [rcx-10h]
     33: mov     edi,0FFFFFFF0h
     38: mov     esi,10h
     3d: call    ryo_h_Ret
     42: leave
     43: ret

fn core::slice::sort::shared::find_existing_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,2
     17: jae     26h
     19: mov     [rbp-10h],rax
     1d: mov     byte ptr [rbp-8],0
     21: jmp     105h
     26: mov     qword ptr [rbp-18h],2
     2e: mov     byte ptr [rbp-59h],1
     32: test    byte ptr [rbp-59h],0FFh
     36: je      143h
     3c: jmp     116h
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: test    byte ptr [rbp-21h],0FFh
     54: je      0B0h
     56: nop     [rax+rax]
     5f: nop
     60: mov     rax,[rbp-18h]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: jae     0A6h
     6e: mov     rax,[rbp-18h]
     72: mov     [rbp-48h],rax
     76: mov     byte ptr [rbp-59h],1
     7a: test    byte ptr [rbp-59h],0FFh
     7e: je      224h
     84: jmp     1F7h
     89: nop     [rax]
     90: test    byte ptr [rbp-23h],0FFh
     94: je      0A4h
     96: mov     rax,[rbp-18h]
     9a: add     rax,1
     9e: mov     [rbp-18h],rax
     a2: jmp     60h
     a4: jmp     0A6h
     a6: jmp     0F6h
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-30h],rax
     b8: cmp     rax,[rbp-20h]
     bc: jae     0F6h
     be: mov     rax,[rbp-18h]
     c2: mov     [rbp-48h],rax
     c6: mov     byte ptr [rbp-59h],1
     ca: test    byte ptr [rbp-59h],0FFh
     ce: je      315h
     d4: jmp     2E8h
     d9: nop     [rax]
     e0: test    byte ptr [rbp-23h],0FFh
     e4: je      0E8h
     e6: jmp     0F6h
     e8: mov     rax,[rbp-18h]
     ec: add     rax,1
     f0: mov     [rbp-18h],rax
     f4: jmp     0B0h
     f6: mov     rax,[rbp-18h]
     fa: mov     [rbp-10h],rax
     fe: movzx   eax,byte ptr [rbp-21h]
    102: mov     [rbp-8],al
    105: mov     edi,0FFFFFFF0h
    10a: mov     esi,10h
    10f: call    ryo_h_Ret
    114: leave
    115: ret
    116: mov     qword ptr [rbp-80h],1
    11e: mov     rax,[rbp-20h]
    122: mov     [rbp-78h],rax
    126: mov     edi,0FFFFFF90h
    12b: lea     rsi,[k0]
    132: call    ryo_h_AddrAbs
    137: call    fn1
    13c: nop     [rcx-18h]
    143: mov     qword ptr [rbp-60h],1
    14b: mov     rax,[rbp-60h]
    14f: cmp     rax,[rbp-20h]
    153: setb    [rbp-22h]
    157: mov     rax,[rbp+10h]
    15b: lea     rax,[rax+8]
    15f: mov     [rbp-48h],rax
    163: mov     [rbp-40h],rax
    167: mov     byte ptr [rbp-59h],1
    16b: test    byte ptr [rbp-59h],0FFh
    16f: je      19Eh
    171: mov     qword ptr [rbp-80h],0
    179: mov     rax,[rbp-20h]
    17d: mov     [rbp-78h],rax
    181: mov     edi,0FFFFFF90h
    186: lea     rsi,[k2]
    18d: call    ryo_h_AddrAbs
    192: call    fn3
    197: nop     [rcx-18h]
    19e: mov     qword ptr [rbp-60h],0
    1a6: mov     rax,[rbp-60h]
    1aa: cmp     rax,[rbp-20h]
    1ae: setb    [rbp-22h]
    1b2: mov     rax,[rbp+10h]
    1b6: mov     [rbp-50h],rax
    1ba: mov     [rbp-48h],rax
    1be: mov     rax,[rbp-40h]
    1c2: mov     [rbp-38h],rax
    1c6: mov     rax,[rbp-48h]
    1ca: mov     [rbp-30h],rax
    1ce: mov     rax,[rbp+20h]
    1d2: mov     [rbp-80h],rax
    1d6: mov     rax,[rbp-38h]
    1da: mov     [rbp-78h],rax
    1de: mov     rax,[rbp-30h]
    1e2: mov     [rbp-70h],rax
    1e6: call    fn4
    1eb: nop     [rcx-21h]
    1f2: jmp     50h
    1f7: mov     rax,[rbp-48h]
    1fb: mov     [rbp-80h],rax
    1ff: mov     rax,[rbp-20h]
    203: mov     [rbp-78h],rax
    207: mov     edi,0FFFFFF90h
    20c: lea     rsi,[k5]
    213: call    ryo_h_AddrAbs
    218: call    fn6
    21d: nop     [rcx-18h]
    224: mov     rax,[rbp-48h]
    228: cmp     rax,[rbp-20h]
    22c: setb    [rbp-24h]
    230: mov     rax,[rbp+10h]
    234: imul    rcx,[rbp-48h],8
    239: add     rax,rcx
    23c: mov     [rbp-60h],rax
    240: mov     [rbp-50h],rax
    244: mov     [rbp-40h],rax
    248: mov     rax,[rbp-18h]
    24c: mov     [rbp-58h],rax
    250: sub     rax,1
    254: mov     [rbp-50h],rax
    258: mov     byte ptr [rbp-59h],1
    25c: test    byte ptr [rbp-59h],0FFh
    260: je      28Bh
    262: mov     [rbp-80h],rax
    266: mov     rax,[rbp-20h]
    26a: mov     [rbp-78h],rax
    26e: mov     edi,0FFFFFF90h
    273: lea     rsi,[k7]
    27a: call    ryo_h_AddrAbs
    27f: call    fn8
    284: nop     [rcx-18h]
    28b: mov     rax,[rbp-50h]
    28f: cmp     rax,[rbp-20h]
    293: setb    [rbp-24h]
    297: mov     rax,[rbp+10h]
    29b: imul    rcx,[rbp-50h],8
    2a0: add     rax,rcx
    2a3: mov     [rbp-60h],rax
    2a7: mov     [rbp-58h],rax
    2ab: mov     [rbp-48h],rax
    2af: mov     rax,[rbp-40h]
    2b3: mov     [rbp-38h],rax
    2b7: mov     rax,[rbp-48h]
    2bb: mov     [rbp-30h],rax
    2bf: mov     rax,[rbp+20h]
    2c3: mov     [rbp-80h],rax
    2c7: mov     rax,[rbp-38h]
    2cb: mov     [rbp-78h],rax
    2cf: mov     rax,[rbp-30h]
    2d3: mov     [rbp-70h],rax
    2d7: call    fn9
    2dc: nop     [rcx-23h]
    2e3: jmp     90h
    2e8: mov     rax,[rbp-48h]
    2ec: mov     [rbp-80h],rax
    2f0: mov     rax,[rbp-20h]
    2f4: mov     [rbp-78h],rax
    2f8: mov     edi,0FFFFFF90h
    2fd: lea     rsi,[k10]
    304: call    ryo_h_AddrAbs
    309: call    fn11
    30e: nop     [rcx-18h]
    315: mov     rax,[rbp-48h]
    319: cmp     rax,[rbp-20h]
    31d: setb    [rbp-24h]
    321: mov     rax,[rbp+10h]
    325: imul    rcx,[rbp-48h],8
    32a: add     rax,rcx
    32d: mov     [rbp-60h],rax
    331: mov     [rbp-50h],rax
    335: mov     [rbp-40h],rax
    339: mov     rax,[rbp-18h]
    33d: mov     [rbp-58h],rax
    341: sub     rax,1
    345: mov     [rbp-50h],rax
    349: mov     byte ptr [rbp-59h],1
    34d: test    byte ptr [rbp-59h],0FFh
    351: je      37Ch
    353: mov     [rbp-80h],rax
    357: mov     rax,[rbp-20h]
    35b: mov     [rbp-78h],rax
    35f: mov     edi,0FFFFFF90h
    364: lea     rsi,[k12]
    36b: call    ryo_h_AddrAbs
    370: call    fn13
    375: nop     [rcx-18h]
    37c: mov     rax,[rbp-50h]
    380: cmp     rax,[rbp-20h]
    384: setb    [rbp-24h]
    388: mov     rax,[rbp+10h]
    38c: imul    rcx,[rbp-50h],8
    391: add     rax,rcx
    394: mov     [rbp-60h],rax
    398: mov     [rbp-58h],rax
    39c: mov     [rbp-48h],rax
    3a0: mov     rax,[rbp-40h]
    3a4: mov     [rbp-38h],rax
    3a8: mov     rax,[rbp-48h]
    3ac: mov     [rbp-30h],rax
    3b0: mov     rax,[rbp+20h]
    3b4: mov     [rbp-80h],rax
    3b8: mov     rax,[rbp-38h]
    3bc: mov     [rbp-78h],rax
    3c0: mov     rax,[rbp-30h]
    3c4: mov     [rbp-70h],rax
    3c8: call    fn14
    3cd: nop     [rcx-23h]
    3d4: jmp     0E0h

fn core::slice::sort::shared::find_existing_run::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,2
     17: jae     26h
     19: mov     [rbp-10h],rax
     1d: mov     byte ptr [rbp-8],0
     21: jmp     105h
     26: mov     qword ptr [rbp-18h],2
     2e: mov     byte ptr [rbp-59h],1
     32: test    byte ptr [rbp-59h],0FFh
     36: je      143h
     3c: jmp     116h
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: test    byte ptr [rbp-21h],0FFh
     54: je      0B0h
     56: nop     [rax+rax]
     5f: nop
     60: mov     rax,[rbp-18h]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: jae     0A6h
     6e: mov     rax,[rbp-18h]
     72: mov     [rbp-48h],rax
     76: mov     byte ptr [rbp-59h],1
     7a: test    byte ptr [rbp-59h],0FFh
     7e: je      224h
     84: jmp     1F7h
     89: nop     [rax]
     90: test    byte ptr [rbp-23h],0FFh
     94: je      0A4h
     96: mov     rax,[rbp-18h]
     9a: add     rax,1
     9e: mov     [rbp-18h],rax
     a2: jmp     60h
     a4: jmp     0A6h
     a6: jmp     0F6h
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-30h],rax
     b8: cmp     rax,[rbp-20h]
     bc: jae     0F6h
     be: mov     rax,[rbp-18h]
     c2: mov     [rbp-48h],rax
     c6: mov     byte ptr [rbp-59h],1
     ca: test    byte ptr [rbp-59h],0FFh
     ce: je      315h
     d4: jmp     2E8h
     d9: nop     [rax]
     e0: test    byte ptr [rbp-23h],0FFh
     e4: je      0E8h
     e6: jmp     0F6h
     e8: mov     rax,[rbp-18h]
     ec: add     rax,1
     f0: mov     [rbp-18h],rax
     f4: jmp     0B0h
     f6: mov     rax,[rbp-18h]
     fa: mov     [rbp-10h],rax
     fe: movzx   eax,byte ptr [rbp-21h]
    102: mov     [rbp-8],al
    105: mov     edi,0FFFFFFF0h
    10a: mov     esi,10h
    10f: call    ryo_h_Ret
    114: leave
    115: ret
    116: mov     qword ptr [rbp-80h],1
    11e: mov     rax,[rbp-20h]
    122: mov     [rbp-78h],rax
    126: mov     edi,0FFFFFF90h
    12b: lea     rsi,[k0]
    132: call    ryo_h_AddrAbs
    137: call    fn1
    13c: nop     [rcx-18h]
    143: mov     qword ptr [rbp-60h],1
    14b: mov     rax,[rbp-60h]
    14f: cmp     rax,[rbp-20h]
    153: setb    [rbp-22h]
    157: mov     rax,[rbp+10h]
    15b: lea     rax,[rax+4]
    15f: mov     [rbp-48h],rax
    163: mov     [rbp-40h],rax
    167: mov     byte ptr [rbp-59h],1
    16b: test    byte ptr [rbp-59h],0FFh
    16f: je      19Eh
    171: mov     qword ptr [rbp-80h],0
    179: mov     rax,[rbp-20h]
    17d: mov     [rbp-78h],rax
    181: mov     edi,0FFFFFF90h
    186: lea     rsi,[k2]
    18d: call    ryo_h_AddrAbs
    192: call    fn3
    197: nop     [rcx-18h]
    19e: mov     qword ptr [rbp-60h],0
    1a6: mov     rax,[rbp-60h]
    1aa: cmp     rax,[rbp-20h]
    1ae: setb    [rbp-22h]
    1b2: mov     rax,[rbp+10h]
    1b6: mov     [rbp-50h],rax
    1ba: mov     [rbp-48h],rax
    1be: mov     rax,[rbp-40h]
    1c2: mov     [rbp-38h],rax
    1c6: mov     rax,[rbp-48h]
    1ca: mov     [rbp-30h],rax
    1ce: mov     rax,[rbp+20h]
    1d2: mov     [rbp-80h],rax
    1d6: mov     rax,[rbp-38h]
    1da: mov     [rbp-78h],rax
    1de: mov     rax,[rbp-30h]
    1e2: mov     [rbp-70h],rax
    1e6: call    fn4
    1eb: nop     [rcx-21h]
    1f2: jmp     50h
    1f7: mov     rax,[rbp-48h]
    1fb: mov     [rbp-80h],rax
    1ff: mov     rax,[rbp-20h]
    203: mov     [rbp-78h],rax
    207: mov     edi,0FFFFFF90h
    20c: lea     rsi,[k5]
    213: call    ryo_h_AddrAbs
    218: call    fn6
    21d: nop     [rcx-18h]
    224: mov     rax,[rbp-48h]
    228: cmp     rax,[rbp-20h]
    22c: setb    [rbp-24h]
    230: mov     rax,[rbp+10h]
    234: imul    rcx,[rbp-48h],4
    239: add     rax,rcx
    23c: mov     [rbp-60h],rax
    240: mov     [rbp-50h],rax
    244: mov     [rbp-40h],rax
    248: mov     rax,[rbp-18h]
    24c: mov     [rbp-58h],rax
    250: sub     rax,1
    254: mov     [rbp-50h],rax
    258: mov     byte ptr [rbp-59h],1
    25c: test    byte ptr [rbp-59h],0FFh
    260: je      28Bh
    262: mov     [rbp-80h],rax
    266: mov     rax,[rbp-20h]
    26a: mov     [rbp-78h],rax
    26e: mov     edi,0FFFFFF90h
    273: lea     rsi,[k7]
    27a: call    ryo_h_AddrAbs
    27f: call    fn8
    284: nop     [rcx-18h]
    28b: mov     rax,[rbp-50h]
    28f: cmp     rax,[rbp-20h]
    293: setb    [rbp-24h]
    297: mov     rax,[rbp+10h]
    29b: imul    rcx,[rbp-50h],4
    2a0: add     rax,rcx
    2a3: mov     [rbp-60h],rax
    2a7: mov     [rbp-58h],rax
    2ab: mov     [rbp-48h],rax
    2af: mov     rax,[rbp-40h]
    2b3: mov     [rbp-38h],rax
    2b7: mov     rax,[rbp-48h]
    2bb: mov     [rbp-30h],rax
    2bf: mov     rax,[rbp+20h]
    2c3: mov     [rbp-80h],rax
    2c7: mov     rax,[rbp-38h]
    2cb: mov     [rbp-78h],rax
    2cf: mov     rax,[rbp-30h]
    2d3: mov     [rbp-70h],rax
    2d7: call    fn9
    2dc: nop     [rcx-23h]
    2e3: jmp     90h
    2e8: mov     rax,[rbp-48h]
    2ec: mov     [rbp-80h],rax
    2f0: mov     rax,[rbp-20h]
    2f4: mov     [rbp-78h],rax
    2f8: mov     edi,0FFFFFF90h
    2fd: lea     rsi,[k10]
    304: call    ryo_h_AddrAbs
    309: call    fn11
    30e: nop     [rcx-18h]
    315: mov     rax,[rbp-48h]
    319: cmp     rax,[rbp-20h]
    31d: setb    [rbp-24h]
    321: mov     rax,[rbp+10h]
    325: imul    rcx,[rbp-48h],4
    32a: add     rax,rcx
    32d: mov     [rbp-60h],rax
    331: mov     [rbp-50h],rax
    335: mov     [rbp-40h],rax
    339: mov     rax,[rbp-18h]
    33d: mov     [rbp-58h],rax
    341: sub     rax,1
    345: mov     [rbp-50h],rax
    349: mov     byte ptr [rbp-59h],1
    34d: test    byte ptr [rbp-59h],0FFh
    351: je      37Ch
    353: mov     [rbp-80h],rax
    357: mov     rax,[rbp-20h]
    35b: mov     [rbp-78h],rax
    35f: mov     edi,0FFFFFF90h
    364: lea     rsi,[k12]
    36b: call    ryo_h_AddrAbs
    370: call    fn13
    375: nop     [rcx-18h]
    37c: mov     rax,[rbp-50h]
    380: cmp     rax,[rbp-20h]
    384: setb    [rbp-24h]
    388: mov     rax,[rbp+10h]
    38c: imul    rcx,[rbp-50h],4
    391: add     rax,rcx
    394: mov     [rbp-60h],rax
    398: mov     [rbp-58h],rax
    39c: mov     [rbp-48h],rax
    3a0: mov     rax,[rbp-40h]
    3a4: mov     [rbp-38h],rax
    3a8: mov     rax,[rbp-48h]
    3ac: mov     [rbp-30h],rax
    3b0: mov     rax,[rbp+20h]
    3b4: mov     [rbp-80h],rax
    3b8: mov     rax,[rbp-38h]
    3bc: mov     [rbp-78h],rax
    3c0: mov     rax,[rbp-30h]
    3c4: mov     [rbp-70h],rax
    3c8: call    fn14
    3cd: nop     [rcx-23h]
    3d4: jmp     0E0h

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-28h],rax
     13: cmp     rax,8
     17: jae     20h
     19: call    ryo_h_Abort
     1e: ud2
     20: mov     rax,[rbp+10h]
     24: mov     [rbp-20h],rax
     28: mov     rax,[rbp+18h]
     2c: mov     [rbp-18h],rax
     30: mov     rax,[rbp-20h]
     34: mov     [rbp-10h],rax
     38: mov     qword ptr [rbp-80h],8
     40: mov     edi,0FFFFFFD0h
     45: mov     esi,0FFFFFFD8h
     4a: mov     edx,0FFFFFF80h
     4f: call    ryo_h_DivUW64
     54: imul    rax,[rbp-30h],4
     59: mov     [rbp-40h],rax
     5d: mov     rax,[rbp-10h]
     61: imul    rcx,[rbp-40h],8
     66: add     rax,rcx
     69: mov     [rbp-38h],rax
     6d: imul    rax,[rbp-30h],7
     72: mov     [rbp-48h],rax
     76: mov     rax,[rbp-10h]
     7a: imul    rcx,[rbp-48h],8
     7f: add     rax,rcx
     82: mov     [rbp-40h],rax
     86: cmp     qword ptr [rbp-28h],40h
     8b: jae     0F0h
     8d: mov     rax,[rbp-10h]
     91: mov     [rbp-58h],rax
     95: mov     rax,[rbp-38h]
     99: mov     [rbp-60h],rax
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-68h],rax
     a5: mov     rax,[rbp-58h]
     a9: mov     [rbp-0B0h],rax
     b0: mov     rax,[rbp-60h]
     b4: mov     [rbp-0A8h],rax
     bb: mov     rax,[rbp-68h]
     bf: mov     [rbp-0A0h],rax
     c6: mov     rax,[rbp+20h]
     ca: mov     [rbp-98h],rax
     d1: call    fn0
     d6: nop     [rcx-50h]
     dd: mov     byte ptr [rbp-79h],1
     e1: test    byte ptr [rbp-79h],0FFh
     e5: je      1C5h
     eb: jmp     182h
     f0: mov     rax,[rbp-10h]
     f4: mov     [rbp-0B0h],rax
     fb: mov     rax,[rbp-38h]
     ff: mov     [rbp-0A8h],rax
    106: mov     rax,[rbp-40h]
    10a: mov     [rbp-0A0h],rax
    111: mov     rax,[rbp-30h]
    115: mov     [rbp-98h],rax
    11c: mov     rax,[rbp+20h]
    120: mov     [rbp-90h],rax
    127: call    fn1
    12c: nop     [rcx-50h]
    133: mov     byte ptr [rbp-79h],1
    137: test    byte ptr [rbp-79h],0FFh
    13b: je      2E8h
    141: jmp     2A5h
    146: nop     [rax+rax]
    14f: nop
    150: mov     rax,[rbp-8]
    154: mov     [rbp-38h],rax
    158: cmp     rax,[rbp-28h]
    15c: setb    [rbp-29h]
    160: mov     byte ptr [rbp-79h],1
    164: test    byte ptr [rbp-79h],0FFh
    168: je      3E2h
    16e: jmp     3BBh
    173: nop     [rax+rax]
    17c: nop     [rax]
    180: jmp     150h
    182: mov     rax,[rbp-50h]
    186: mov     [rbp-70h],rax
    18a: mov     rax,[rbp-20h]
    18e: mov     [rbp-78h],rax
    192: mov     rax,[rbp-70h]
    196: mov     [rbp-0B0h],rax
    19d: mov     rax,[rbp-78h]
    1a1: mov     [rbp-0A8h],rax
    1a8: mov     edi,0FFFFFF60h
    1ad: lea     rsi,[k2]
    1b4: call    ryo_h_AddrAbs
    1b9: call    fn3
    1be: nop     [rcx-20h]
    1c5: mov     qword ptr [rbp-80h],0
    1cd: cmp     qword ptr [rbp-80h],8
    1d2: setb    [rbp-42h]
    1d6: test    byte ptr [rbp-42h],0FFh
    1da: je      22Ch
    1dc: mov     qword ptr [rbp-80h],8
    1e4: mov     rax,[rbp-80h]
    1e8: mov     rcx,7FFFFFFFFFFFFFFFh
    1f2: cmp     rax,rcx
    1f5: setbe   [rbp-43h]
    1f9: test    byte ptr [rbp-43h],0FFh
    1fd: je      22Ch
    1ff: mov     rax,[rbp-50h]
    203: sub     rax,[rbp-10h]
    207: mov     [rbp-8],rax
    20b: mov     qword ptr [rbp-80h],8
    213: mov     edi,0FFFFFFF8h
    218: mov     esi,0FFFFFFF8h
    21d: mov     edx,0FFFFFF80h
    222: call    ryo_h_DivUW64
    227: jmp     180h
    22c: mov     edi,0FFFFFF50h
    231: lea     rsi,[k4]
    238: call    ryo_h_AddrAbs
    23d: mov     qword ptr [rbp-0A8h],49h
    248: mov     edi,0FFFFFF60h
    24d: lea     rsi,[k5]
    254: call    ryo_h_AddrAbs
    259: lea     rdi,[sym6]
    260: lea     rsi,[site7]
    267: mov     edx,0FFFFFF80h
    26c: call    ryo_h_CallExt
    271: test    rax,rax
    274: je      281h
    276: call    rax
    278: nop     [rcx-20h]
    27f: jmp     291h
    281: mov     rdi,rbp
    284: lea     rsi,[ro+4]
    28b: call    qword ptr [sym8]
    291: call    ryo_h_Unreachable
    296: ud2
    298: nop     [rax+rax]
    2a0: jmp     150h
    2a5: mov     rax,[rbp-50h]
    2a9: mov     [rbp-58h],rax
    2ad: mov     rax,[rbp-20h]
    2b1: mov     [rbp-60h],rax
    2b5: mov     rax,[rbp-58h]
    2b9: mov     [rbp-0B0h],rax
    2c0: mov     rax,[rbp-60h]
    2c4: mov     [rbp-0A8h],rax
    2cb: mov     edi,0FFFFFF60h
    2d0: lea     rsi,[k9]
    2d7: call    ryo_h_AddrAbs
    2dc: call    fn10
    2e1: nop     [rcx-20h]
    2e8: mov     qword ptr [rbp-80h],0
    2f0: cmp     qword ptr [rbp-80h],8
    2f5: setb    [rbp-42h]
    2f9: test    byte ptr [rbp-42h],0FFh
    2fd: je      34Fh
    2ff: mov     qword ptr [rbp-80h],8
    307: mov     rax,[rbp-80h]
    30b: mov     rcx,7FFFFFFFFFFFFFFFh
    315: cmp     rax,rcx
    318: setbe   [rbp-43h]
    31c: test    byte ptr [rbp-43h],0FFh
    320: je      34Fh
    322: mov     rax,[rbp-50h]
    326: sub     rax,[rbp-10h]
    32a: mov     [rbp-8],rax
    32e: mov     qword ptr [rbp-80h],8
    336: mov     edi,0FFFFFFF8h
    33b: mov     esi,0FFFFFFF8h
    340: mov     edx,0FFFFFF80h
    345: call    ryo_h_DivUW64
    34a: jmp     2A0h
    34f: mov     edi,0FFFFFF50h
    354: lea     rsi,[k11]
    35b: call    ryo_h_AddrAbs
    360: mov     qword ptr [rbp-0A8h],49h
    36b: mov     edi,0FFFFFF60h
    370: lea     rsi,[k12]
    377: call    ryo_h_AddrAbs
    37c: lea     rdi,[sym13]
    383: lea     rsi,[site14]
    38a: mov     edx,0FFFFFF80h
    38f: call    ryo_h_CallExt
    394: test    rax,rax
    397: je      3A4h
    399: call    rax
    39b: nop     [rcx-20h]
    3a2: jmp     3B4h
    3a4: mov     rdi,rbp
    3a7: lea     rsi,[ro+4]
    3ae: call    qword ptr [sym15]
    3b4: call    ryo_h_Unreachable
    3b9: ud2
    3bb: movzx   eax,byte ptr [rbp-29h]
    3bf: mov     [rbp-0B0h],al
    3c5: mov     edi,0FFFFFF58h
    3ca: lea     rsi,[k16]
    3d1: call    ryo_h_AddrAbs
    3d6: call    fn17
    3db: nop     [rcx-20h]
    3e2: mov     edi,0FFFFFFF8h
    3e7: mov     esi,8
    3ec: call    ryo_h_Ret
    3f1: leave
    3f2: ret

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-28h],rax
     13: cmp     rax,8
     17: jae     20h
     19: call    ryo_h_Abort
     1e: ud2
     20: mov     rax,[rbp+10h]
     24: mov     [rbp-20h],rax
     28: mov     rax,[rbp+18h]
     2c: mov     [rbp-18h],rax
     30: mov     rax,[rbp-20h]
     34: mov     [rbp-10h],rax
     38: mov     qword ptr [rbp-80h],8
     40: mov     edi,0FFFFFFD0h
     45: mov     esi,0FFFFFFD8h
     4a: mov     edx,0FFFFFF80h
     4f: call    ryo_h_DivUW64
     54: imul    rax,[rbp-30h],4
     59: mov     [rbp-40h],rax
     5d: mov     rax,[rbp-10h]
     61: imul    rcx,[rbp-40h],4
     66: add     rax,rcx
     69: mov     [rbp-38h],rax
     6d: imul    rax,[rbp-30h],7
     72: mov     [rbp-48h],rax
     76: mov     rax,[rbp-10h]
     7a: imul    rcx,[rbp-48h],4
     7f: add     rax,rcx
     82: mov     [rbp-40h],rax
     86: cmp     qword ptr [rbp-28h],40h
     8b: jae     0F0h
     8d: mov     rax,[rbp-10h]
     91: mov     [rbp-58h],rax
     95: mov     rax,[rbp-38h]
     99: mov     [rbp-60h],rax
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-68h],rax
     a5: mov     rax,[rbp-58h]
     a9: mov     [rbp-0B0h],rax
     b0: mov     rax,[rbp-60h]
     b4: mov     [rbp-0A8h],rax
     bb: mov     rax,[rbp-68h]
     bf: mov     [rbp-0A0h],rax
     c6: mov     rax,[rbp+20h]
     ca: mov     [rbp-98h],rax
     d1: call    fn0
     d6: nop     [rcx-50h]
     dd: mov     byte ptr [rbp-79h],1
     e1: test    byte ptr [rbp-79h],0FFh
     e5: je      1C5h
     eb: jmp     182h
     f0: mov     rax,[rbp-10h]
     f4: mov     [rbp-0B0h],rax
     fb: mov     rax,[rbp-38h]
     ff: mov     [rbp-0A8h],rax
    106: mov     rax,[rbp-40h]
    10a: mov     [rbp-0A0h],rax
    111: mov     rax,[rbp-30h]
    115: mov     [rbp-98h],rax
    11c: mov     rax,[rbp+20h]
    120: mov     [rbp-90h],rax
    127: call    fn1
    12c: nop     [rcx-50h]
    133: mov     byte ptr [rbp-79h],1
    137: test    byte ptr [rbp-79h],0FFh
    13b: je      2E8h
    141: jmp     2A5h
    146: nop     [rax+rax]
    14f: nop
    150: mov     rax,[rbp-8]
    154: mov     [rbp-38h],rax
    158: cmp     rax,[rbp-28h]
    15c: setb    [rbp-29h]
    160: mov     byte ptr [rbp-79h],1
    164: test    byte ptr [rbp-79h],0FFh
    168: je      3E2h
    16e: jmp     3BBh
    173: nop     [rax+rax]
    17c: nop     [rax]
    180: jmp     150h
    182: mov     rax,[rbp-50h]
    186: mov     [rbp-70h],rax
    18a: mov     rax,[rbp-20h]
    18e: mov     [rbp-78h],rax
    192: mov     rax,[rbp-70h]
    196: mov     [rbp-0B0h],rax
    19d: mov     rax,[rbp-78h]
    1a1: mov     [rbp-0A8h],rax
    1a8: mov     edi,0FFFFFF60h
    1ad: lea     rsi,[k2]
    1b4: call    ryo_h_AddrAbs
    1b9: call    fn3
    1be: nop     [rcx-20h]
    1c5: mov     qword ptr [rbp-80h],0
    1cd: cmp     qword ptr [rbp-80h],4
    1d2: setb    [rbp-42h]
    1d6: test    byte ptr [rbp-42h],0FFh
    1da: je      22Ch
    1dc: mov     qword ptr [rbp-80h],4
    1e4: mov     rax,[rbp-80h]
    1e8: mov     rcx,7FFFFFFFFFFFFFFFh
    1f2: cmp     rax,rcx
    1f5: setbe   [rbp-43h]
    1f9: test    byte ptr [rbp-43h],0FFh
    1fd: je      22Ch
    1ff: mov     rax,[rbp-50h]
    203: sub     rax,[rbp-10h]
    207: mov     [rbp-8],rax
    20b: mov     qword ptr [rbp-80h],4
    213: mov     edi,0FFFFFFF8h
    218: mov     esi,0FFFFFFF8h
    21d: mov     edx,0FFFFFF80h
    222: call    ryo_h_DivUW64
    227: jmp     180h
    22c: mov     edi,0FFFFFF50h
    231: lea     rsi,[k4]
    238: call    ryo_h_AddrAbs
    23d: mov     qword ptr [rbp-0A8h],49h
    248: mov     edi,0FFFFFF60h
    24d: lea     rsi,[k5]
    254: call    ryo_h_AddrAbs
    259: lea     rdi,[sym6]
    260: lea     rsi,[site7]
    267: mov     edx,0FFFFFF80h
    26c: call    ryo_h_CallExt
    271: test    rax,rax
    274: je      281h
    276: call    rax
    278: nop     [rcx-20h]
    27f: jmp     291h
    281: mov     rdi,rbp
    284: lea     rsi,[ro+4]
    28b: call    qword ptr [sym8]
    291: call    ryo_h_Unreachable
    296: ud2
    298: nop     [rax+rax]
    2a0: jmp     150h
    2a5: mov     rax,[rbp-50h]
    2a9: mov     [rbp-58h],rax
    2ad: mov     rax,[rbp-20h]
    2b1: mov     [rbp-60h],rax
    2b5: mov     rax,[rbp-58h]
    2b9: mov     [rbp-0B0h],rax
    2c0: mov     rax,[rbp-60h]
    2c4: mov     [rbp-0A8h],rax
    2cb: mov     edi,0FFFFFF60h
    2d0: lea     rsi,[k9]
    2d7: call    ryo_h_AddrAbs
    2dc: call    fn10
    2e1: nop     [rcx-20h]
    2e8: mov     qword ptr [rbp-80h],0
    2f0: cmp     qword ptr [rbp-80h],4
    2f5: setb    [rbp-42h]
    2f9: test    byte ptr [rbp-42h],0FFh
    2fd: je      34Fh
    2ff: mov     qword ptr [rbp-80h],4
    307: mov     rax,[rbp-80h]
    30b: mov     rcx,7FFFFFFFFFFFFFFFh
    315: cmp     rax,rcx
    318: setbe   [rbp-43h]
    31c: test    byte ptr [rbp-43h],0FFh
    320: je      34Fh
    322: mov     rax,[rbp-50h]
    326: sub     rax,[rbp-10h]
    32a: mov     [rbp-8],rax
    32e: mov     qword ptr [rbp-80h],4
    336: mov     edi,0FFFFFFF8h
    33b: mov     esi,0FFFFFFF8h
    340: mov     edx,0FFFFFF80h
    345: call    ryo_h_DivUW64
    34a: jmp     2A0h
    34f: mov     edi,0FFFFFF50h
    354: lea     rsi,[k11]
    35b: call    ryo_h_AddrAbs
    360: mov     qword ptr [rbp-0A8h],49h
    36b: mov     edi,0FFFFFF60h
    370: lea     rsi,[k12]
    377: call    ryo_h_AddrAbs
    37c: lea     rdi,[sym13]
    383: lea     rsi,[site14]
    38a: mov     edx,0FFFFFF80h
    38f: call    ryo_h_CallExt
    394: test    rax,rax
    397: je      3A4h
    399: call    rax
    39b: nop     [rcx-20h]
    3a2: jmp     3B4h
    3a4: mov     rdi,rbp
    3a7: lea     rsi,[ro+4]
    3ae: call    qword ptr [sym15]
    3b4: call    ryo_h_Unreachable
    3b9: ud2
    3bb: movzx   eax,byte ptr [rbp-29h]
    3bf: mov     [rbp-0B0h],al
    3c5: mov     edi,0FFFFFF58h
    3ca: lea     rsi,[k16]
    3d1: call    ryo_h_AddrAbs
    3d6: call    fn17
    3db: nop     [rcx-20h]
    3e2: mov     edi,0FFFFFFF8h
    3e7: mov     esi,8
    3ec: call    ryo_h_Ret
    3f1: leave
    3f2: ret

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp+28h]
     1c: mov     [rbp-40h],rax
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-38h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-30h],rax
     30: call    fn0
     35: nop     [rcx-9]
     3c: mov     rax,[rbp+10h]
     40: mov     [rbp-20h],rax
     44: mov     rax,[rbp+20h]
     48: mov     [rbp-18h],rax
     4c: mov     rax,[rbp+28h]
     50: mov     [rbp-40h],rax
     54: mov     rax,[rbp-20h]
     58: mov     [rbp-38h],rax
     5c: mov     rax,[rbp-18h]
     60: mov     [rbp-30h],rax
     64: call    fn1
     69: nop     [rcx-0Ah]
     70: movzx   eax,byte ptr [rbp-9]
     74: cmp     al,[rbp-0Ah]
     77: jne     0D1h
     79: mov     rax,[rbp+18h]
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp+20h]
     85: mov     [rbp-18h],rax
     89: mov     rax,[rbp+28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-20h]
     95: mov     [rbp-38h],rax
     99: mov     rax,[rbp-18h]
     9d: mov     [rbp-30h],rax
     a1: call    fn2
     a6: nop     [rcx-0Ch]
     ad: movzx   eax,byte ptr [rbp-0Ch]
     b1: xor     al,[rbp-9]
     b4: mov     [rbp-0Dh],al
     b7: test    byte ptr [rbp-0Dh],0FFh
     bb: je      0C7h
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-8],rax
     c5: jmp     0CFh
     c7: mov     rax,[rbp+18h]
     cb: mov     [rbp-8],rax
     cf: jmp     0D9h
     d1: mov     rax,[rbp+10h]
     d5: mov     [rbp-8],rax
     d9: mov     edi,0FFFFFFF8h
     de: mov     esi,8
     e3: call    ryo_h_Ret
     e8: leave
     e9: ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp+28h]
     1c: mov     [rbp-40h],rax
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-38h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-30h],rax
     30: call    fn0
     35: nop     [rcx-9]
     3c: mov     rax,[rbp+10h]
     40: mov     [rbp-20h],rax
     44: mov     rax,[rbp+20h]
     48: mov     [rbp-18h],rax
     4c: mov     rax,[rbp+28h]
     50: mov     [rbp-40h],rax
     54: mov     rax,[rbp-20h]
     58: mov     [rbp-38h],rax
     5c: mov     rax,[rbp-18h]
     60: mov     [rbp-30h],rax
     64: call    fn1
     69: nop     [rcx-0Ah]
     70: movzx   eax,byte ptr [rbp-9]
     74: cmp     al,[rbp-0Ah]
     77: jne     0D1h
     79: mov     rax,[rbp+18h]
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp+20h]
     85: mov     [rbp-18h],rax
     89: mov     rax,[rbp+28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-20h]
     95: mov     [rbp-38h],rax
     99: mov     rax,[rbp-18h]
     9d: mov     [rbp-30h],rax
     a1: call    fn2
     a6: nop     [rcx-0Ch]
     ad: movzx   eax,byte ptr [rbp-0Ch]
     b1: xor     al,[rbp-9]
     b4: mov     [rbp-0Dh],al
     b7: test    byte ptr [rbp-0Dh],0FFh
     bb: je      0C7h
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-8],rax
     c5: jmp     0CFh
     c7: mov     rax,[rbp+18h]
     cb: mov     [rbp-8],rax
     cf: jmp     0D9h
     d1: mov     rax,[rbp+10h]
     d5: mov     [rbp-8],rax
     d9: mov     edi,0FFFFFFF8h
     de: mov     esi,8
     e3: call    ryo_h_Ret
     e8: leave
     e9: ret

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: imul    rax,[rbp+28h],8
      d: mov     [rbp-28h],rax
     11: cmp     rax,40h
     15: jb      16Fh
     1b: mov     qword ptr [rbp-48h],8
     23: mov     edi,0FFFFFFD8h
     28: mov     esi,28h
     2d: mov     edx,0FFFFFFB8h
     32: call    ryo_h_DivUW64
     37: mov     rax,[rbp+10h]
     3b: mov     [rbp-30h],rax
     3f: mov     rax,[rbp+10h]
     43: mov     [rbp-40h],rax
     47: imul    rax,[rbp-28h],4
     4c: mov     [rbp-10h],rax
     50: mov     rax,[rbp-40h]
     54: imul    rcx,[rbp-10h],8
     59: add     rax,rcx
     5c: mov     [rbp-38h],rax
     60: imul    rax,[rbp-28h],7
     65: mov     [rbp-18h],rax
     69: mov     rax,[rbp+10h]
     6d: imul    rcx,[rbp-18h],8
     72: add     rax,rcx
     75: mov     [rbp-40h],rax
     79: mov     rax,[rbp-30h]
     7d: mov     [rbp-70h],rax
     81: mov     rax,[rbp-38h]
     85: mov     [rbp-68h],rax
     89: mov     rax,[rbp-40h]
     8d: mov     [rbp-60h],rax
     91: mov     rax,[rbp-28h]
     95: mov     [rbp-58h],rax
     99: mov     rax,[rbp+30h]
     9d: mov     [rbp-50h],rax
     a1: call    fn0
     a6: nop     [rcx+10h]
     ad: mov     rax,[rbp+18h]
     b1: mov     [rbp-30h],rax
     b5: mov     rax,[rbp+18h]
     b9: mov     [rbp-40h],rax
     bd: imul    rcx,[rbp-10h],8
     c2: add     rax,rcx
     c5: mov     [rbp-38h],rax
     c9: mov     rax,[rbp+18h]
     cd: imul    rcx,[rbp-18h],8
     d2: add     rax,rcx
     d5: mov     [rbp-40h],rax
     d9: mov     rax,[rbp-30h]
     dd: mov     [rbp-70h],rax
     e1: mov     rax,[rbp-38h]
     e5: mov     [rbp-68h],rax
     e9: mov     rax,[rbp-40h]
     ed: mov     [rbp-60h],rax
     f1: mov     rax,[rbp-28h]
     f5: mov     [rbp-58h],rax
     f9: mov     rax,[rbp+30h]
     fd: mov     [rbp-50h],rax
    101: call    fn1
    106: nop     [rcx+18h]
    10d: mov     rax,[rbp+20h]
    111: mov     [rbp-30h],rax
    115: mov     rax,[rbp+20h]
    119: mov     [rbp-40h],rax
    11d: imul    rcx,[rbp-10h],8
    122: add     rax,rcx
    125: mov     [rbp-38h],rax
    129: mov     rax,[rbp+20h]
    12d: imul    rcx,[rbp-18h],8
    132: add     rax,rcx
    135: mov     [rbp-40h],rax
    139: mov     rax,[rbp-30h]
    13d: mov     [rbp-70h],rax
    141: mov     rax,[rbp-38h]
    145: mov     [rbp-68h],rax
    149: mov     rax,[rbp-40h]
    14d: mov     [rbp-60h],rax
    151: mov     rax,[rbp-28h]
    155: mov     [rbp-58h],rax
    159: mov     rax,[rbp+30h]
    15d: mov     [rbp-50h],rax
    161: call    fn2
    166: nop     [rcx+20h]
    16d: jmp     16Fh
    16f: mov     rax,[rbp+10h]
    173: mov     [rbp-20h],rax
    177: mov     rax,[rbp+18h]
    17b: mov     [rbp-28h],rax
    17f: mov     rax,[rbp+20h]
    183: mov     [rbp-30h],rax
    187: mov     rax,[rbp-20h]
    18b: mov     [rbp-70h],rax
    18f: mov     rax,[rbp-28h]
    193: mov     [rbp-68h],rax
    197: mov     rax,[rbp-30h]
    19b: mov     [rbp-60h],rax
    19f: mov     rax,[rbp+30h]
    1a3: mov     [rbp-58h],rax
    1a7: call    fn3
    1ac: nop     [rcx-8]
    1b3: mov     edi,0FFFFFFF8h
    1b8: mov     esi,8
    1bd: call    ryo_h_Ret
    1c2: leave
    1c3: ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: imul    rax,[rbp+28h],8
      d: mov     [rbp-28h],rax
     11: cmp     rax,40h
     15: jb      16Fh
     1b: mov     qword ptr [rbp-48h],8
     23: mov     edi,0FFFFFFD8h
     28: mov     esi,28h
     2d: mov     edx,0FFFFFFB8h
     32: call    ryo_h_DivUW64
     37: mov     rax,[rbp+10h]
     3b: mov     [rbp-30h],rax
     3f: mov     rax,[rbp+10h]
     43: mov     [rbp-40h],rax
     47: imul    rax,[rbp-28h],4
     4c: mov     [rbp-10h],rax
     50: mov     rax,[rbp-40h]
     54: imul    rcx,[rbp-10h],4
     59: add     rax,rcx
     5c: mov     [rbp-38h],rax
     60: imul    rax,[rbp-28h],7
     65: mov     [rbp-18h],rax
     69: mov     rax,[rbp+10h]
     6d: imul    rcx,[rbp-18h],4
     72: add     rax,rcx
     75: mov     [rbp-40h],rax
     79: mov     rax,[rbp-30h]
     7d: mov     [rbp-70h],rax
     81: mov     rax,[rbp-38h]
     85: mov     [rbp-68h],rax
     89: mov     rax,[rbp-40h]
     8d: mov     [rbp-60h],rax
     91: mov     rax,[rbp-28h]
     95: mov     [rbp-58h],rax
     99: mov     rax,[rbp+30h]
     9d: mov     [rbp-50h],rax
     a1: call    fn0
     a6: nop     [rcx+10h]
     ad: mov     rax,[rbp+18h]
     b1: mov     [rbp-30h],rax
     b5: mov     rax,[rbp+18h]
     b9: mov     [rbp-40h],rax
     bd: imul    rcx,[rbp-10h],4
     c2: add     rax,rcx
     c5: mov     [rbp-38h],rax
     c9: mov     rax,[rbp+18h]
     cd: imul    rcx,[rbp-18h],4
     d2: add     rax,rcx
     d5: mov     [rbp-40h],rax
     d9: mov     rax,[rbp-30h]
     dd: mov     [rbp-70h],rax
     e1: mov     rax,[rbp-38h]
     e5: mov     [rbp-68h],rax
     e9: mov     rax,[rbp-40h]
     ed: mov     [rbp-60h],rax
     f1: mov     rax,[rbp-28h]
     f5: mov     [rbp-58h],rax
     f9: mov     rax,[rbp+30h]
     fd: mov     [rbp-50h],rax
    101: call    fn1
    106: nop     [rcx+18h]
    10d: mov     rax,[rbp+20h]
    111: mov     [rbp-30h],rax
    115: mov     rax,[rbp+20h]
    119: mov     [rbp-40h],rax
    11d: imul    rcx,[rbp-10h],4
    122: add     rax,rcx
    125: mov     [rbp-38h],rax
    129: mov     rax,[rbp+20h]
    12d: imul    rcx,[rbp-18h],4
    132: add     rax,rcx
    135: mov     [rbp-40h],rax
    139: mov     rax,[rbp-30h]
    13d: mov     [rbp-70h],rax
    141: mov     rax,[rbp-38h]
    145: mov     [rbp-68h],rax
    149: mov     rax,[rbp-40h]
    14d: mov     [rbp-60h],rax
    151: mov     rax,[rbp-28h]
    155: mov     [rbp-58h],rax
    159: mov     rax,[rbp+30h]
    15d: mov     [rbp-50h],rax
    161: call    fn2
    166: nop     [rcx+20h]
    16d: jmp     16Fh
    16f: mov     rax,[rbp+10h]
    173: mov     [rbp-20h],rax
    177: mov     rax,[rbp+18h]
    17b: mov     [rbp-28h],rax
    17f: mov     rax,[rbp+20h]
    183: mov     [rbp-30h],rax
    187: mov     rax,[rbp-20h]
    18b: mov     [rbp-70h],rax
    18f: mov     rax,[rbp-28h]
    193: mov     [rbp-68h],rax
    197: mov     rax,[rbp-30h]
    19b: mov     [rbp-60h],rax
    19f: mov     rax,[rbp+30h]
    1a3: mov     [rbp-58h],rax
    1a7: call    fn3
    1ac: nop     [rcx-8]
    1b3: mov     edi,0FFFFFFF8h
    1b8: mov     esi,8
    1bd: call    ryo_h_Ret
    1c2: leave
    1c3: ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-68h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-78h],rax
     23: mov     rax,[rbp-80h]
     27: mov     [rbp-70h],rax
     2b: mov     qword ptr [rbp-0A8h],2
     36: mov     edi,0FFFFFF88h
     3b: mov     esi,0FFFFFF98h
     40: mov     edx,0FFFFFF58h
     45: call    ryo_h_DivUW64
     4a: cmp     qword ptr [rbp-78h],0
     4f: setne   [rbp-79h]
     53: mov     rax,[rbp-70h]
     57: mov     [rbp-28h],rax
     5b: mov     rax,[rbp-70h]
     5f: imul    rcx,[rbp-78h],8
     64: add     rax,rcx
     67: mov     [rbp-30h],rax
     6b: mov     rax,[rbp-78h]
     6f: sub     rax,1
     73: mov     [rbp-80h],rax
     77: mov     rax,[rbp-70h]
     7b: imul    rcx,[rbp-80h],8
     80: add     rax,rcx
     83: mov     [rbp-38h],rax
     87: mov     rax,[rbp-68h]
     8b: sub     rax,1
     8f: mov     [rbp-8],rax
     93: mov     rax,[rbp-70h]
     97: imul    rcx,[rbp-8],8
     9c: add     rax,rcx
     9f: mov     [rbp-40h],rax
     a3: mov     rax,[rbp+20h]
     a7: mov     [rbp-80h],rax
     ab: imul    rcx,[rbp-8],8
     b0: add     rax,rcx
     b3: mov     [rbp-48h],rax
     b7: mov     qword ptr [rbp-18h],0
     bf: mov     rax,[rbp-78h]
     c3: mov     [rbp-10h],rax
     c7: nop     [rax+rax]
     d0: mov     rax,[rbp-18h]
     d4: mov     [rbp-88h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-90h],rax
     e6: mov     rax,[rbp-88h]
     ed: cmp     rax,[rbp-90h]
     f4: setb    [rbp-79h]
     f8: test    byte ptr [rbp-79h],0FFh
     fc: je      270h
    102: jmp     253h
    107: nop     [rax+rax]
    110: mov     rax,[rbp-90h]
    117: mov     [rbp-28h],rax
    11b: mov     rax,[rbp-88h]
    122: mov     [rbp-30h],rax
    126: mov     rax,[rbp-80h]
    12a: mov     [rbp+20h],rax
    12e: mov     rax,[rbp-38h]
    132: mov     [rbp-0E0h],rax
    139: mov     rax,[rbp-40h]
    13d: mov     [rbp-0D8h],rax
    144: mov     rax,[rbp-48h]
    148: mov     [rbp-0D0h],rax
    14f: mov     rax,[rbp+28h]
    153: mov     [rbp-0C8h],rax
    15a: call    fn0
    15f: nop     [rcx-90h]
    166: mov     rax,[rbp-90h]
    16d: mov     [rbp-38h],rax
    171: mov     rax,[rbp-88h]
    178: mov     [rbp-40h],rax
    17c: mov     rax,[rbp-80h]
    180: mov     [rbp-48h],rax
    184: jmp     0D0h
    189: nop     [rax]
    190: jmp     1F0h
    192: nop     [rax+rax]
    19b: nop     [rax+rax]
    1a0: mov     rax,[rbp-28h]
    1a4: mov     [rbp-98h],rax
    1ab: cmp     rax,[rbp-80h]
    1af: setb    [rbp-8Ah]
    1b6: test    byte ptr [rbp-8Ah],0FFh
    1bd: je      1C9h
    1bf: mov     rax,[rbp-28h]
    1c3: mov     [rbp-50h],rax
    1c7: jmp     1D1h
    1c9: mov     rax,[rbp-30h]
    1cd: mov     [rbp-50h],rax
    1d1: mov     byte ptr [rbp-0A1h],1
    1d8: test    byte ptr [rbp-0A1h],0FFh
    1df: je      3EDh
    1e5: jmp     37Dh
    1ea: nop     [rax+rax]
    1f0: mov     rax,[rbp-28h]
    1f4: cmp     rax,[rbp-80h]
    1f8: je      1FCh
    1fa: jmp     209h
    1fc: mov     rax,[rbp-30h]
    200: cmp     rax,[rbp-88h]
    207: je      248h
    209: lea     rdi,[sym1]
    210: lea     rsi,[site2]
    217: mov     edx,0FFFFFF58h
    21c: call    ryo_h_CallExt
    221: test    rax,rax
    224: je      231h
    226: call    rax
    228: nop     [rcx-50h]
    22f: jmp     241h
    231: mov     rdi,rbp
    234: lea     rsi,[ro+4]
    23b: call    qword ptr [sym3]
    241: call    ryo_h_Unreachable
    246: ud2
    248: xor     edi,edi
    24a: xor     esi,esi
    24c: call    ryo_h_Ret
    251: leave
    252: ret
    253: mov     rax,[rbp-18h]
    257: mov     [rbp-88h],rax
    25e: mov     byte ptr [rbp-0A1h],1
    265: test    byte ptr [rbp-0A1h],0FFh
    26c: je      2C9h
    26e: jmp     293h
    270: mov     qword ptr [rbp-0A8h],1
    27b: mov     rax,[rbp-38h]
    27f: imul    rcx,[rbp-0A8h],8
    287: add     rax,rcx
    28a: mov     [rbp-80h],rax
    28e: jmp     31Ch
    293: mov     rax,[rbp-88h]
    29a: mov     [rbp-0E0h],rax
    2a1: mov     qword ptr [rbp-0D8h],1
    2ac: mov     edi,0FFFFFF30h
    2b1: lea     rsi,[k4]
    2b8: call    ryo_h_AddrAbs
    2bd: call    fn5
    2c2: nop     [rcx-60h]
    2c9: mov     rax,[rbp-88h]
    2d0: add     rax,1
    2d4: mov     [rbp-90h],rax
    2db: mov     [rbp-18h],rax
    2df: mov     rax,[rbp-28h]
    2e3: mov     [rbp-0E0h],rax
    2ea: mov     rax,[rbp-30h]
    2ee: mov     [rbp-0D8h],rax
    2f5: mov     rax,[rbp+20h]
    2f9: mov     [rbp-0D0h],rax
    300: mov     rax,[rbp+28h]
    304: mov     [rbp-0C8h],rax
    30b: call    fn6
    310: nop     [rcx-90h]
    317: jmp     110h
    31c: mov     qword ptr [rbp-0A8h],1
    327: mov     rax,[rbp-40h]
    32b: imul    rcx,[rbp-0A8h],8
    333: add     rax,rcx
    336: mov     [rbp-88h],rax
    33d: mov     qword ptr [rbp-0A8h],2
    348: mov     edi,0FFFFFF68h
    34d: mov     esi,0FFFFFF98h
    352: mov     edx,0FFFFFF58h
    357: call    ryo_h_RemUW64
    35c: cmp     qword ptr [rbp-98h],0
    364: sete    [rbp-89h]
    36b: test    byte ptr [rbp-89h],0FFh
    372: je      1A0h
    378: jmp     190h
    37d: mov     rax,[rbp-50h]
    381: mov     [rbp-98h],rax
    388: mov     rax,[rbp+20h]
    38c: mov     [rbp-0A0h],rax
    393: mov     rax,[rbp-98h]
    39a: mov     [rbp-0E0h],rax
    3a1: mov     rax,[rbp-0A0h]
    3a8: mov     [rbp-0D8h],rax
    3af: mov     qword ptr [rbp-0D0h],8
    3ba: mov     qword ptr [rbp-0C8h],4
    3c5: mov     qword ptr [rbp-0C0h],1
    3d0: mov     edi,0FFFFFF48h
    3d5: lea     rsi,[k7]
    3dc: call    ryo_h_AddrAbs
    3e1: call    fn8
    3e6: nop     [rcx-60h]
    3ed: mov     qword ptr [rbp-0A8h],1
    3f8: imul    rax,[rbp-0A8h],8
    400: mov     [rbp-0B0h],rax
    407: mov     edi,20h
    40c: mov     esi,0FFFFFFB0h
    411: mov     edx,0FFFFFF50h
    416: call    ryo_h_Memcpy
    41b: mov     edi,0FFFFFF60h
    420: mov     esi,0FFFFFF76h
    425: call    ryo_h_ZextW8W64
    42a: mov     rax,[rbp-28h]
    42e: imul    rcx,[rbp-0A0h],8
    436: add     rax,rcx
    439: mov     [rbp-98h],rax
    440: mov     [rbp-28h],rax
    444: movzx   eax,byte ptr [rbp-8Ah]
    44b: xor     al,1
    44e: mov     [rbp-8Bh],al
    454: mov     edi,0FFFFFF60h
    459: mov     esi,0FFFFFF75h
    45e: call    ryo_h_ZextW8W64
    463: mov     rax,[rbp-30h]
    467: imul    rcx,[rbp-0A0h],8
    46f: add     rax,rcx
    472: mov     [rbp-98h],rax
    479: mov     [rbp-30h],rax
    47d: jmp     1F0h

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-68h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-78h],rax
     23: mov     rax,[rbp-80h]
     27: mov     [rbp-70h],rax
     2b: mov     qword ptr [rbp-0A8h],2
     36: mov     edi,0FFFFFF88h
     3b: mov     esi,0FFFFFF98h
     40: mov     edx,0FFFFFF58h
     45: call    ryo_h_DivUW64
     4a: cmp     qword ptr [rbp-78h],0
     4f: setne   [rbp-79h]
     53: mov     rax,[rbp-70h]
     57: mov     [rbp-28h],rax
     5b: mov     rax,[rbp-70h]
     5f: imul    rcx,[rbp-78h],4
     64: add     rax,rcx
     67: mov     [rbp-30h],rax
     6b: mov     rax,[rbp-78h]
     6f: sub     rax,1
     73: mov     [rbp-80h],rax
     77: mov     rax,[rbp-70h]
     7b: imul    rcx,[rbp-80h],4
     80: add     rax,rcx
     83: mov     [rbp-38h],rax
     87: mov     rax,[rbp-68h]
     8b: sub     rax,1
     8f: mov     [rbp-8],rax
     93: mov     rax,[rbp-70h]
     97: imul    rcx,[rbp-8],4
     9c: add     rax,rcx
     9f: mov     [rbp-40h],rax
     a3: mov     rax,[rbp+20h]
     a7: mov     [rbp-80h],rax
     ab: imul    rcx,[rbp-8],4
     b0: add     rax,rcx
     b3: mov     [rbp-48h],rax
     b7: mov     qword ptr [rbp-18h],0
     bf: mov     rax,[rbp-78h]
     c3: mov     [rbp-10h],rax
     c7: nop     [rax+rax]
     d0: mov     rax,[rbp-18h]
     d4: mov     [rbp-88h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-90h],rax
     e6: mov     rax,[rbp-88h]
     ed: cmp     rax,[rbp-90h]
     f4: setb    [rbp-79h]
     f8: test    byte ptr [rbp-79h],0FFh
     fc: je      270h
    102: jmp     253h
    107: nop     [rax+rax]
    110: mov     rax,[rbp-90h]
    117: mov     [rbp-28h],rax
    11b: mov     rax,[rbp-88h]
    122: mov     [rbp-30h],rax
    126: mov     rax,[rbp-80h]
    12a: mov     [rbp+20h],rax
    12e: mov     rax,[rbp-38h]
    132: mov     [rbp-0E0h],rax
    139: mov     rax,[rbp-40h]
    13d: mov     [rbp-0D8h],rax
    144: mov     rax,[rbp-48h]
    148: mov     [rbp-0D0h],rax
    14f: mov     rax,[rbp+28h]
    153: mov     [rbp-0C8h],rax
    15a: call    fn0
    15f: nop     [rcx-90h]
    166: mov     rax,[rbp-90h]
    16d: mov     [rbp-38h],rax
    171: mov     rax,[rbp-88h]
    178: mov     [rbp-40h],rax
    17c: mov     rax,[rbp-80h]
    180: mov     [rbp-48h],rax
    184: jmp     0D0h
    189: nop     [rax]
    190: jmp     1F0h
    192: nop     [rax+rax]
    19b: nop     [rax+rax]
    1a0: mov     rax,[rbp-28h]
    1a4: mov     [rbp-98h],rax
    1ab: cmp     rax,[rbp-80h]
    1af: setb    [rbp-8Ah]
    1b6: test    byte ptr [rbp-8Ah],0FFh
    1bd: je      1C9h
    1bf: mov     rax,[rbp-28h]
    1c3: mov     [rbp-50h],rax
    1c7: jmp     1D1h
    1c9: mov     rax,[rbp-30h]
    1cd: mov     [rbp-50h],rax
    1d1: mov     byte ptr [rbp-0A1h],1
    1d8: test    byte ptr [rbp-0A1h],0FFh
    1df: je      3EDh
    1e5: jmp     37Dh
    1ea: nop     [rax+rax]
    1f0: mov     rax,[rbp-28h]
    1f4: cmp     rax,[rbp-80h]
    1f8: je      1FCh
    1fa: jmp     209h
    1fc: mov     rax,[rbp-30h]
    200: cmp     rax,[rbp-88h]
    207: je      248h
    209: lea     rdi,[sym1]
    210: lea     rsi,[site2]
    217: mov     edx,0FFFFFF58h
    21c: call    ryo_h_CallExt
    221: test    rax,rax
    224: je      231h
    226: call    rax
    228: nop     [rcx-50h]
    22f: jmp     241h
    231: mov     rdi,rbp
    234: lea     rsi,[ro+4]
    23b: call    qword ptr [sym3]
    241: call    ryo_h_Unreachable
    246: ud2
    248: xor     edi,edi
    24a: xor     esi,esi
    24c: call    ryo_h_Ret
    251: leave
    252: ret
    253: mov     rax,[rbp-18h]
    257: mov     [rbp-88h],rax
    25e: mov     byte ptr [rbp-0A1h],1
    265: test    byte ptr [rbp-0A1h],0FFh
    26c: je      2C9h
    26e: jmp     293h
    270: mov     qword ptr [rbp-0A8h],1
    27b: mov     rax,[rbp-38h]
    27f: imul    rcx,[rbp-0A8h],4
    287: add     rax,rcx
    28a: mov     [rbp-80h],rax
    28e: jmp     31Ch
    293: mov     rax,[rbp-88h]
    29a: mov     [rbp-0E0h],rax
    2a1: mov     qword ptr [rbp-0D8h],1
    2ac: mov     edi,0FFFFFF30h
    2b1: lea     rsi,[k4]
    2b8: call    ryo_h_AddrAbs
    2bd: call    fn5
    2c2: nop     [rcx-60h]
    2c9: mov     rax,[rbp-88h]
    2d0: add     rax,1
    2d4: mov     [rbp-90h],rax
    2db: mov     [rbp-18h],rax
    2df: mov     rax,[rbp-28h]
    2e3: mov     [rbp-0E0h],rax
    2ea: mov     rax,[rbp-30h]
    2ee: mov     [rbp-0D8h],rax
    2f5: mov     rax,[rbp+20h]
    2f9: mov     [rbp-0D0h],rax
    300: mov     rax,[rbp+28h]
    304: mov     [rbp-0C8h],rax
    30b: call    fn6
    310: nop     [rcx-90h]
    317: jmp     110h
    31c: mov     qword ptr [rbp-0A8h],1
    327: mov     rax,[rbp-40h]
    32b: imul    rcx,[rbp-0A8h],4
    333: add     rax,rcx
    336: mov     [rbp-88h],rax
    33d: mov     qword ptr [rbp-0A8h],2
    348: mov     edi,0FFFFFF68h
    34d: mov     esi,0FFFFFF98h
    352: mov     edx,0FFFFFF58h
    357: call    ryo_h_RemUW64
    35c: cmp     qword ptr [rbp-98h],0
    364: sete    [rbp-89h]
    36b: test    byte ptr [rbp-89h],0FFh
    372: je      1A0h
    378: jmp     190h
    37d: mov     rax,[rbp-50h]
    381: mov     [rbp-98h],rax
    388: mov     rax,[rbp+20h]
    38c: mov     [rbp-0A0h],rax
    393: mov     rax,[rbp-98h]
    39a: mov     [rbp-0E0h],rax
    3a1: mov     rax,[rbp-0A0h]
    3a8: mov     [rbp-0D8h],rax
    3af: mov     qword ptr [rbp-0D0h],4
    3ba: mov     qword ptr [rbp-0C8h],4
    3c5: mov     qword ptr [rbp-0C0h],1
    3d0: mov     edi,0FFFFFF48h
    3d5: lea     rsi,[k7]
    3dc: call    ryo_h_AddrAbs
    3e1: call    fn8
    3e6: nop     [rcx-60h]
    3ed: mov     qword ptr [rbp-0A8h],1
    3f8: imul    rax,[rbp-0A8h],4
    400: mov     [rbp-0B0h],rax
    407: mov     edi,20h
    40c: mov     esi,0FFFFFFB0h
    411: mov     edx,0FFFFFF50h
    416: call    ryo_h_Memcpy
    41b: mov     edi,0FFFFFF60h
    420: mov     esi,0FFFFFF76h
    425: call    ryo_h_ZextW8W64
    42a: mov     rax,[rbp-28h]
    42e: imul    rcx,[rbp-0A0h],4
    436: add     rax,rcx
    439: mov     [rbp-98h],rax
    440: mov     [rbp-28h],rax
    444: movzx   eax,byte ptr [rbp-8Ah]
    44b: xor     al,1
    44e: mov     [rbp-8Bh],al
    454: mov     edi,0FFFFFF60h
    459: mov     esi,0FFFFFF75h
    45e: call    ryo_h_ZextW8W64
    463: mov     rax,[rbp-30h]
    467: imul    rcx,[rbp-0A0h],4
    46f: add     rax,rcx
    472: mov     [rbp-98h],rax
    479: mov     [rbp-30h],rax
    47d: jmp     1F0h

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-71h],0
      f: test    byte ptr [rbp-71h],0FFh
     13: je      17Ch
     19: jmp     172h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      5Bh
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-40h],rax
     2e: mov     rax,[rax]
     31: mov     [rbp-38h],rax
     35: mov     [rbp-40h],rax
     39: mov     [rbp-30h],rax
     3d: lea     rax,[rbp-30h]
     41: mov     [rbp-50h],rax
     45: mov     [rbp-48h],rax
     49: mov     rax,[rbp+18h]
     4d: mov     [rbp-40h],rax
     51: mov     qword ptr [rbp-38h],1
     59: jmp     60h
     5b: jmp     0E3h
     60: mov     rax,[rbp-8]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-50h],rax
     6c: mov     rax,[rbp-40h]
     70: mov     [rbp-58h],rax
     74: mov     byte ptr [rbp-71h],1
     78: test    byte ptr [rbp-71h],0FFh
     7c: je      1FAh
     82: jmp     196h
     87: nop     [rax+rax]
     90: jmp     0C8h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: mov     byte ptr [rbp-71h],0
     a4: test    byte ptr [rbp-71h],0FFh
     a8: je      2B4h
     ae: jmp     2AAh
     b3: nop     [rax+rax]
     bc: nop     [rax]
     c0: test    byte ptr [rbp-49h],0FFh
     c4: je      0C8h
     c6: jmp     60h
     c8: lea     rax,[rbp-48h]
     cc: mov     [rbp-78h],rax
     d0: mov     [rbp-0B0h],rax
     d7: call    fn0
     dc: nop     [rcx-78h]
     e3: xor     edi,edi
     e5: xor     esi,esi
     e7: call    ryo_h_Ret
     ec: leave
     ed: ret
     ee: xchg    ax,ax
     f0: lea     rax,[rbp-48h]
     f4: mov     [rbp-78h],rax
     f8: mov     [rbp-0B0h],rax
     ff: call    fn1
    104: nop     [rcx-78h]
    10b: mov     edi,0FFFFFFD8h
    110: call    ryo_h_Resume
    115: ud2
    117: nop     [rax+rax]
    120: mov     rax,[rbp+18h]
    124: mov     [rbp-48h],rax
    128: mov     rax,[rbp-8]
    12c: mov     [rbp-50h],rax
    130: mov     rax,[rbp-48h]
    134: mov     [rbp-40h],rax
    138: mov     rax,[rbp-50h]
    13c: mov     [rbp-38h],rax
    140: mov     rax,[rbp+20h]
    144: mov     [rbp-0B0h],rax
    14b: mov     rax,[rbp-40h]
    14f: mov     [rbp-0A8h],rax
    156: mov     rax,[rbp-38h]
    15a: mov     [rbp-0A0h],rax
    161: call    fn2
    166: nop     [rcx-29h]
    16d: jmp     20h
    172: mov     rax,[rbp+18h]
    176: mov     [rbp-8],rax
    17a: jmp     120h
    17c: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    184: mov     rax,[rbp+18h]
    188: imul    rcx,[rbp-78h],8
    18d: add     rax,rcx
    190: mov     [rbp-8],rax
    194: jmp     120h
    196: mov     rax,[rbp-18h]
    19a: mov     [rbp-60h],rax
    19e: mov     rax,[rbp-58h]
    1a2: mov     [rbp-68h],rax
    1a6: mov     rax,[rbp-60h]
    1aa: mov     [rbp-0B0h],rax
    1b1: mov     rax,[rbp-68h]
    1b5: mov     [rbp-0A8h],rax
    1bc: mov     qword ptr [rbp-0A0h],8
    1c7: mov     qword ptr [rbp-98h],4
    1d2: mov     qword ptr [rbp-90h],1
    1dd: mov     edi,0FFFFFF78h
    1e2: lea     rsi,[k3]
    1e9: call    ryo_h_AddrAbs
    1ee: call    fn4
    1f3: nop     [rcx-20h]
    1fa: mov     qword ptr [rbp-78h],1
    202: imul    rax,[rbp-78h],8
    207: mov     [rbp-80h],rax
    20b: mov     edi,0FFFFFFA8h
    210: mov     esi,0FFFFFFB0h
    215: mov     edx,0FFFFFF80h
    21a: call    ryo_h_Memcpy
    21f: mov     rax,[rbp-8]
    223: mov     [rbp-50h],rax
    227: mov     [rbp-40h],rax
    22b: mov     rax,[rbp-8]
    22f: mov     [rbp-58h],rax
    233: cmp     rax,[rbp+10h]
    237: je      90h
    23d: jmp     0A0h
    242: nop     [rax+rax]
    24b: nop     [rax+rax]
    250: mov     rax,[rbp-50h]
    254: mov     [rbp-8],rax
    258: lea     rax,[rbp-30h]
    25c: mov     [rbp-68h],rax
    260: mov     rax,[rbp-8]
    264: mov     [rbp-70h],rax
    268: mov     rax,[rbp-68h]
    26c: mov     [rbp-60h],rax
    270: mov     rax,[rbp-70h]
    274: mov     [rbp-58h],rax
    278: mov     rax,[rbp+20h]
    27c: mov     [rbp-0B0h],rax
    283: mov     rax,[rbp-60h]
    287: mov     [rbp-0A8h],rax
    28e: mov     rax,[rbp-58h]
    292: mov     [rbp-0A0h],rax
    299: call    fn5
    29e: nop     [rcx-49h]
    2a5: jmp     0C0h
    2aa: mov     rax,[rbp-8]
    2ae: mov     [rbp-50h],rax
    2b2: jmp     250h
    2b4: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    2bc: mov     rax,[rbp-8]
    2c0: imul    rcx,[rbp-78h],8
    2c5: add     rax,rcx
    2c8: mov     [rbp-50h],rax
    2cc: jmp     250h
    2ce: xchg    ax,ax
    2d0: lea     rdi,[sym6]
    2d7: lea     rsi,[site7]
    2de: mov     edx,0FFFFFF88h
    2e3: call    ryo_h_CallExt
    2e8: test    rax,rax
    2eb: je      2F8h
    2ed: call    rax
    2ef: nop     [rcx-70h]
    2f6: jmp     308h
    2f8: mov     rdi,rbp
    2fb: lea     rsi,[ro+4]
    302: call    qword ptr [sym8]
    308: call    ryo_h_Unreachable
    30d: ud2
    30f: mov     rdi,rax
    312: mov     esi,0FFFFFFD8h
    317: call    ryo_h_Lpad
    31c: jmp     2D0h
    31e: mov     rdi,rax
    321: mov     esi,0FFFFFFD8h
    326: call    ryo_h_Lpad
    32b: jmp     0F0h

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-69h],0
      f: test    byte ptr [rbp-69h],0FFh
     13: je      17Ch
     19: jmp     172h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      57h
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-38h],rax
     2e: mov     eax,[rax]
     30: mov     [rbp-30h],eax
     33: mov     [rbp-34h],eax
     36: mov     [rbp-2Ch],eax
     39: lea     rax,[rbp-2Ch]
     3d: mov     [rbp-50h],rax
     41: mov     [rbp-48h],rax
     45: mov     rax,[rbp+18h]
     49: mov     [rbp-40h],rax
     4d: mov     qword ptr [rbp-38h],1
     55: jmp     60h
     57: jmp     0E3h
     5c: nop     [rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-50h],rax
     6c: mov     rax,[rbp-40h]
     70: mov     [rbp-58h],rax
     74: mov     byte ptr [rbp-69h],1
     78: test    byte ptr [rbp-69h],0FFh
     7c: je      1FAh
     82: jmp     196h
     87: nop     [rax+rax]
     90: jmp     0C8h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: mov     byte ptr [rbp-69h],0
     a4: test    byte ptr [rbp-69h],0FFh
     a8: je      2B4h
     ae: jmp     2AAh
     b3: nop     [rax+rax]
     bc: nop     [rax]
     c0: test    byte ptr [rbp-2Dh],0FFh
     c4: je      0C8h
     c6: jmp     60h
     c8: lea     rax,[rbp-48h]
     cc: mov     [rbp-70h],rax
     d0: mov     [rbp-0B0h],rax
     d7: call    fn0
     dc: nop     [rcx-70h]
     e3: xor     edi,edi
     e5: xor     esi,esi
     e7: call    ryo_h_Ret
     ec: leave
     ed: ret
     ee: xchg    ax,ax
     f0: lea     rax,[rbp-48h]
     f4: mov     [rbp-70h],rax
     f8: mov     [rbp-0B0h],rax
     ff: call    fn1
    104: nop     [rcx-70h]
    10b: mov     edi,0FFFFFFD8h
    110: call    ryo_h_Resume
    115: ud2
    117: nop     [rax+rax]
    120: mov     rax,[rbp+18h]
    124: mov     [rbp-48h],rax
    128: mov     rax,[rbp-8]
    12c: mov     [rbp-50h],rax
    130: mov     rax,[rbp-48h]
    134: mov     [rbp-40h],rax
    138: mov     rax,[rbp-50h]
    13c: mov     [rbp-38h],rax
    140: mov     rax,[rbp+20h]
    144: mov     [rbp-0B0h],rax
    14b: mov     rax,[rbp-40h]
    14f: mov     [rbp-0A8h],rax
    156: mov     rax,[rbp-38h]
    15a: mov     [rbp-0A0h],rax
    161: call    fn2
    166: nop     [rcx-29h]
    16d: jmp     20h
    172: mov     rax,[rbp+18h]
    176: mov     [rbp-8],rax
    17a: jmp     120h
    17c: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    184: mov     rax,[rbp+18h]
    188: imul    rcx,[rbp-70h],4
    18d: add     rax,rcx
    190: mov     [rbp-8],rax
    194: jmp     120h
    196: mov     rax,[rbp-18h]
    19a: mov     [rbp-60h],rax
    19e: mov     rax,[rbp-58h]
    1a2: mov     [rbp-68h],rax
    1a6: mov     rax,[rbp-60h]
    1aa: mov     [rbp-0B0h],rax
    1b1: mov     rax,[rbp-68h]
    1b5: mov     [rbp-0A8h],rax
    1bc: mov     qword ptr [rbp-0A0h],4
    1c7: mov     qword ptr [rbp-98h],4
    1d2: mov     qword ptr [rbp-90h],1
    1dd: mov     edi,0FFFFFF78h
    1e2: lea     rsi,[k3]
    1e9: call    ryo_h_AddrAbs
    1ee: call    fn4
    1f3: nop     [rcx-20h]
    1fa: mov     qword ptr [rbp-70h],1
    202: imul    rax,[rbp-70h],4
    207: mov     [rbp-78h],rax
    20b: mov     edi,0FFFFFFA8h
    210: mov     esi,0FFFFFFB0h
    215: mov     edx,0FFFFFF88h
    21a: call    ryo_h_Memcpy
    21f: mov     rax,[rbp-8]
    223: mov     [rbp-50h],rax
    227: mov     [rbp-40h],rax
    22b: mov     rax,[rbp-8]
    22f: mov     [rbp-50h],rax
    233: cmp     rax,[rbp+10h]
    237: je      90h
    23d: jmp     0A0h
    242: nop     [rax+rax]
    24b: nop     [rax+rax]
    250: mov     rax,[rbp-50h]
    254: mov     [rbp-8],rax
    258: lea     rax,[rbp-2Ch]
    25c: mov     [rbp-60h],rax
    260: mov     rax,[rbp-8]
    264: mov     [rbp-68h],rax
    268: mov     rax,[rbp-60h]
    26c: mov     [rbp-58h],rax
    270: mov     rax,[rbp-68h]
    274: mov     [rbp-50h],rax
    278: mov     rax,[rbp+20h]
    27c: mov     [rbp-0B0h],rax
    283: mov     rax,[rbp-58h]
    287: mov     [rbp-0A8h],rax
    28e: mov     rax,[rbp-50h]
    292: mov     [rbp-0A0h],rax
    299: call    fn5
    29e: nop     [rcx-2Dh]
    2a5: jmp     0C0h
    2aa: mov     rax,[rbp-8]
    2ae: mov     [rbp-50h],rax
    2b2: jmp     250h
    2b4: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    2bc: mov     rax,[rbp-8]
    2c0: imul    rcx,[rbp-70h],4
    2c5: add     rax,rcx
    2c8: mov     [rbp-50h],rax
    2cc: jmp     250h
    2ce: xchg    ax,ax
    2d0: lea     rdi,[sym6]
    2d7: lea     rsi,[site7]
    2de: mov     edx,0FFFFFF90h
    2e3: call    ryo_h_CallExt
    2e8: test    rax,rax
    2eb: je      2F8h
    2ed: call    rax
    2ef: nop     [rcx-68h]
    2f6: jmp     308h
    2f8: mov     rdi,rbp
    2fb: lea     rsi,[ro+4]
    302: call    qword ptr [sym8]
    308: call    ryo_h_Unreachable
    30d: ud2
    30f: mov     rdi,rax
    312: mov     esi,0FFFFFFD8h
    317: call    ryo_h_Lpad
    31c: jmp     2D0h
    31e: mov     rdi,rax
    321: mov     esi,0FFFFFFD8h
    326: call    ryo_h_Lpad
    32b: jmp     0F0h

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp+20h],0
     15: je      1Dh
     17: cmp     rax,[rbp+20h]
     1b: jae     24h
     1d: call    ryo_h_Abort
     22: ud2
     24: mov     rax,[rbp+10h]
     28: mov     [rbp-28h],rax
     2c: mov     rax,[rbp+18h]
     30: mov     [rbp-20h],rax
     34: mov     rax,[rbp-28h]
     38: mov     [rbp-18h],rax
     3c: imul    rcx,[rbp-10h],8
     41: add     rax,rcx
     44: mov     [rbp-20h],rax
     48: mov     rax,[rbp-18h]
     4c: imul    rcx,[rbp+20h],8
     51: add     rax,rcx
     54: mov     [rbp-8],rax
     58: nop     [rax+rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: je      0B8h
     6e: mov     rax,[rbp-8]
     72: mov     [rbp-30h],rax
     76: mov     rax,[rbp-18h]
     7a: mov     [rbp-50h],rax
     7e: mov     rax,[rbp-30h]
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp+28h]
     8a: mov     [rbp-40h],rax
     8e: call    fn0
     93: nop     [rcx-8]
     9a: mov     qword ptr [rbp-38h],1
     a2: mov     rax,[rbp-8]
     a6: imul    rcx,[rbp-38h],8
     ab: add     rax,rcx
     ae: mov     [rbp-30h],rax
     b2: mov     [rbp-8],rax
     b6: jmp     60h
     b8: xor     edi,edi
     ba: xor     esi,esi
     bc: call    ryo_h_Ret
     c1: leave
     c2: ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp+20h],0
     15: je      1Dh
     17: cmp     rax,[rbp+20h]
     1b: jae     24h
     1d: call    ryo_h_Abort
     22: ud2
     24: mov     rax,[rbp+10h]
     28: mov     [rbp-28h],rax
     2c: mov     rax,[rbp+18h]
     30: mov     [rbp-20h],rax
     34: mov     rax,[rbp-28h]
     38: mov     [rbp-18h],rax
     3c: imul    rcx,[rbp-10h],4
     41: add     rax,rcx
     44: mov     [rbp-20h],rax
     48: mov     rax,[rbp-18h]
     4c: imul    rcx,[rbp+20h],4
     51: add     rax,rcx
     54: mov     [rbp-8],rax
     58: nop     [rax+rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: je      0B8h
     6e: mov     rax,[rbp-8]
     72: mov     [rbp-30h],rax
     76: mov     rax,[rbp-18h]
     7a: mov     [rbp-50h],rax
     7e: mov     rax,[rbp-30h]
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp+28h]
     8a: mov     [rbp-40h],rax
     8e: call    fn0
     93: nop     [rcx-8]
     9a: mov     qword ptr [rbp-38h],1
     a2: mov     rax,[rbp-8]
     a6: imul    rcx,[rbp-38h],4
     ab: add     rax,rcx
     ae: mov     [rbp-30h],rax
     b2: mov     [rbp-8],rax
     b6: jmp     60h
     b8: xor     edi,edi
     ba: xor     esi,esi
     bc: call    ryo_h_Ret
     c1: leave
     c2: ret

fn core::slice::sort::shared::smallsort::merge_down::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-50h],rax
     1b: mov     rax,[rbp-48h]
     1f: mov     [rbp-40h],rax
     23: mov     rax,[rbp-50h]
     27: mov     [rbp-38h],rax
     2b: mov     rax,[rbp+28h]
     2f: mov     [rbp-90h],rax
     36: mov     rax,[rbp-40h]
     3a: mov     [rbp-88h],rax
     41: mov     rax,[rbp-38h]
     45: mov     [rbp-80h],rax
     49: call    fn0
     4e: nop     [rcx-19h]
     55: movzx   eax,byte ptr [rbp-19h]
     59: xor     al,1
     5c: mov     [rbp-29h],al
     5f: test    byte ptr [rbp-29h],0FFh
     63: je      6Fh
     65: mov     rax,[rbp+18h]
     69: mov     [rbp-28h],rax
     6d: jmp     77h
     6f: mov     rax,[rbp+10h]
     73: mov     [rbp-28h],rax
     77: mov     rax,[rbp+20h]
     7b: mov     [rbp-38h],rax
     7f: mov     byte ptr [rbp-51h],1
     83: test    byte ptr [rbp-51h],0FFh
     87: je      0E4h
     89: mov     rax,[rbp-28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-38h]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-40h]
     9d: mov     [rbp-90h],rax
     a4: mov     rax,[rbp-48h]
     a8: mov     [rbp-88h],rax
     af: mov     qword ptr [rbp-80h],8
     b7: mov     qword ptr [rbp-78h],4
     bf: mov     qword ptr [rbp-70h],1
     c7: mov     edi,0FFFFFF98h
     cc: lea     rsi,[k1]
     d3: call    ryo_h_AddrAbs
     d8: call    fn2
     dd: nop     [rcx-28h]
     e4: mov     qword ptr [rbp-58h],1
     ec: imul    rax,[rbp-58h],8
     f1: mov     [rbp-60h],rax
     f5: mov     edi,0FFFFFFC8h
     fa: mov     esi,0FFFFFFD8h
     ff: mov     edx,0FFFFFFA0h
    104: call    ryo_h_Memcpy
    109: mov     edi,0FFFFFFC0h
    10e: mov     esi,0FFFFFFD7h
    113: call    ryo_h_ZextW8W64
    118: mov     rax,[rbp-40h]
    11c: mov     [rbp-50h],rax
    120: mov     qword ptr [rbp-58h],0
    128: mov     rax,[rbp-58h]
    12c: sub     rax,[rbp-50h]
    130: mov     [rbp-48h],rax
    134: mov     rax,[rbp+18h]
    138: imul    rcx,[rbp-48h],8
    13d: add     rax,rcx
    140: mov     [rbp-38h],rax
    144: mov     [rbp+18h],rax
    148: mov     edi,0FFFFFFC0h
    14d: mov     esi,0FFFFFFE7h
    152: call    ryo_h_ZextW8W64
    157: mov     rax,[rbp-40h]
    15b: mov     [rbp-50h],rax
    15f: mov     qword ptr [rbp-58h],0
    167: mov     rax,[rbp-58h]
    16b: sub     rax,[rbp-50h]
    16f: mov     [rbp-48h],rax
    173: mov     rax,[rbp+10h]
    177: imul    rcx,[rbp-48h],8
    17c: add     rax,rcx
    17f: mov     [rbp-38h],rax
    183: mov     [rbp+10h],rax
    187: mov     byte ptr [rbp-51h],0
    18b: test    byte ptr [rbp-51h],0FFh
    18f: je      1DBh
    191: jmp     1D1h
    193: nop     [rax+rax]
    19c: nop     [rax]
    1a0: mov     rax,[rbp-38h]
    1a4: mov     [rbp+20h],rax
    1a8: mov     rax,[rbp+10h]
    1ac: mov     [rbp-18h],rax
    1b0: mov     rax,[rbp+18h]
    1b4: mov     [rbp-10h],rax
    1b8: mov     rax,[rbp+20h]
    1bc: mov     [rbp-8],rax
    1c0: mov     edi,0FFFFFFE8h
    1c5: mov     esi,18h
    1ca: call    ryo_h_Ret
    1cf: leave
    1d0: ret
    1d1: mov     rax,[rbp+20h]
    1d5: mov     [rbp-38h],rax
    1d9: jmp     1A0h
    1db: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    1e3: mov     rax,[rbp+20h]
    1e7: imul    rcx,[rbp-58h],8
    1ec: add     rax,rcx
    1ef: mov     [rbp-38h],rax
    1f3: jmp     1A0h

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-50h],rax
     1b: mov     rax,[rbp-48h]
     1f: mov     [rbp-40h],rax
     23: mov     rax,[rbp-50h]
     27: mov     [rbp-38h],rax
     2b: mov     rax,[rbp+28h]
     2f: mov     [rbp-90h],rax
     36: mov     rax,[rbp-40h]
     3a: mov     [rbp-88h],rax
     41: mov     rax,[rbp-38h]
     45: mov     [rbp-80h],rax
     49: call    fn0
     4e: nop     [rcx-19h]
     55: movzx   eax,byte ptr [rbp-19h]
     59: xor     al,1
     5c: mov     [rbp-29h],al
     5f: test    byte ptr [rbp-29h],0FFh
     63: je      6Fh
     65: mov     rax,[rbp+18h]
     69: mov     [rbp-28h],rax
     6d: jmp     77h
     6f: mov     rax,[rbp+10h]
     73: mov     [rbp-28h],rax
     77: mov     rax,[rbp+20h]
     7b: mov     [rbp-38h],rax
     7f: mov     byte ptr [rbp-51h],1
     83: test    byte ptr [rbp-51h],0FFh
     87: je      0E4h
     89: mov     rax,[rbp-28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-38h]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-40h]
     9d: mov     [rbp-90h],rax
     a4: mov     rax,[rbp-48h]
     a8: mov     [rbp-88h],rax
     af: mov     qword ptr [rbp-80h],4
     b7: mov     qword ptr [rbp-78h],4
     bf: mov     qword ptr [rbp-70h],1
     c7: mov     edi,0FFFFFF98h
     cc: lea     rsi,[k1]
     d3: call    ryo_h_AddrAbs
     d8: call    fn2
     dd: nop     [rcx-28h]
     e4: mov     qword ptr [rbp-58h],1
     ec: imul    rax,[rbp-58h],4
     f1: mov     [rbp-60h],rax
     f5: mov     edi,0FFFFFFC8h
     fa: mov     esi,0FFFFFFD8h
     ff: mov     edx,0FFFFFFA0h
    104: call    ryo_h_Memcpy
    109: mov     edi,0FFFFFFC0h
    10e: mov     esi,0FFFFFFD7h
    113: call    ryo_h_ZextW8W64
    118: mov     rax,[rbp-40h]
    11c: mov     [rbp-50h],rax
    120: mov     qword ptr [rbp-58h],0
    128: mov     rax,[rbp-58h]
    12c: sub     rax,[rbp-50h]
    130: mov     [rbp-48h],rax
    134: mov     rax,[rbp+18h]
    138: imul    rcx,[rbp-48h],4
    13d: add     rax,rcx
    140: mov     [rbp-38h],rax
    144: mov     [rbp+18h],rax
    148: mov     edi,0FFFFFFC0h
    14d: mov     esi,0FFFFFFE7h
    152: call    ryo_h_ZextW8W64
    157: mov     rax,[rbp-40h]
    15b: mov     [rbp-50h],rax
    15f: mov     qword ptr [rbp-58h],0
    167: mov     rax,[rbp-58h]
    16b: sub     rax,[rbp-50h]
    16f: mov     [rbp-48h],rax
    173: mov     rax,[rbp+10h]
    177: imul    rcx,[rbp-48h],4
    17c: add     rax,rcx
    17f: mov     [rbp-38h],rax
    183: mov     [rbp+10h],rax
    187: mov     byte ptr [rbp-51h],0
    18b: test    byte ptr [rbp-51h],0FFh
    18f: je      1DBh
    191: jmp     1D1h
    193: nop     [rax+rax]
    19c: nop     [rax]
    1a0: mov     rax,[rbp-38h]
    1a4: mov     [rbp+20h],rax
    1a8: mov     rax,[rbp+10h]
    1ac: mov     [rbp-18h],rax
    1b0: mov     rax,[rbp+18h]
    1b4: mov     [rbp-10h],rax
    1b8: mov     rax,[rbp+20h]
    1bc: mov     [rbp-8],rax
    1c0: mov     edi,0FFFFFFE8h
    1c5: mov     esi,18h
    1ca: call    ryo_h_Ret
    1cf: leave
    1d0: ret
    1d1: mov     rax,[rbp+20h]
    1d5: mov     [rbp-38h],rax
    1d9: jmp     1A0h
    1db: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    1e3: mov     rax,[rbp+20h]
    1e7: imul    rcx,[rbp-58h],4
    1ec: add     rax,rcx
    1ef: mov     [rbp-38h],rax
    1f3: jmp     1A0h

fn core::slice::sort::shared::smallsort::merge_up::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-50h],rax
     1b: mov     rax,[rbp-48h]
     1f: mov     [rbp-40h],rax
     23: mov     rax,[rbp-50h]
     27: mov     [rbp-38h],rax
     2b: mov     rax,[rbp+28h]
     2f: mov     [rbp-90h],rax
     36: mov     rax,[rbp-40h]
     3a: mov     [rbp-88h],rax
     41: mov     rax,[rbp-38h]
     45: mov     [rbp-80h],rax
     49: call    fn0
     4e: nop     [rcx-19h]
     55: movzx   eax,byte ptr [rbp-19h]
     59: xor     al,1
     5c: mov     [rbp-29h],al
     5f: test    byte ptr [rbp-29h],0FFh
     63: je      6Fh
     65: mov     rax,[rbp+10h]
     69: mov     [rbp-28h],rax
     6d: jmp     77h
     6f: mov     rax,[rbp+18h]
     73: mov     [rbp-28h],rax
     77: mov     rax,[rbp+20h]
     7b: mov     [rbp-38h],rax
     7f: mov     byte ptr [rbp-51h],1
     83: test    byte ptr [rbp-51h],0FFh
     87: je      0E4h
     89: mov     rax,[rbp-28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-38h]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-40h]
     9d: mov     [rbp-90h],rax
     a4: mov     rax,[rbp-48h]
     a8: mov     [rbp-88h],rax
     af: mov     qword ptr [rbp-80h],8
     b7: mov     qword ptr [rbp-78h],4
     bf: mov     qword ptr [rbp-70h],1
     c7: mov     edi,0FFFFFF98h
     cc: lea     rsi,[k1]
     d3: call    ryo_h_AddrAbs
     d8: call    fn2
     dd: nop     [rcx-28h]
     e4: mov     qword ptr [rbp-58h],1
     ec: imul    rax,[rbp-58h],8
     f1: mov     [rbp-60h],rax
     f5: mov     edi,0FFFFFFC8h
     fa: mov     esi,0FFFFFFD8h
     ff: mov     edx,0FFFFFFA0h
    104: call    ryo_h_Memcpy
    109: mov     edi,0FFFFFFC0h
    10e: mov     esi,0FFFFFFE7h
    113: call    ryo_h_ZextW8W64
    118: mov     rax,[rbp+18h]
    11c: imul    rcx,[rbp-40h],8
    121: add     rax,rcx
    124: mov     [rbp-38h],rax
    128: mov     [rbp+18h],rax
    12c: mov     edi,0FFFFFFC0h
    131: mov     esi,0FFFFFFD7h
    136: call    ryo_h_ZextW8W64
    13b: mov     rax,[rbp+10h]
    13f: imul    rcx,[rbp-40h],8
    144: add     rax,rcx
    147: mov     [rbp-38h],rax
    14b: mov     [rbp+10h],rax
    14f: mov     qword ptr [rbp-58h],1
    157: mov     rax,[rbp+20h]
    15b: imul    rcx,[rbp-58h],8
    160: add     rax,rcx
    163: mov     [rbp-38h],rax
    167: mov     [rbp+20h],rax
    16b: mov     rax,[rbp+10h]
    16f: mov     [rbp-18h],rax
    173: mov     rax,[rbp+18h]
    177: mov     [rbp-10h],rax
    17b: mov     rax,[rbp+20h]
    17f: mov     [rbp-8],rax
    183: mov     edi,0FFFFFFE8h
    188: mov     esi,18h
    18d: call    ryo_h_Ret
    192: leave
    193: ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-50h],rax
     1b: mov     rax,[rbp-48h]
     1f: mov     [rbp-40h],rax
     23: mov     rax,[rbp-50h]
     27: mov     [rbp-38h],rax
     2b: mov     rax,[rbp+28h]
     2f: mov     [rbp-90h],rax
     36: mov     rax,[rbp-40h]
     3a: mov     [rbp-88h],rax
     41: mov     rax,[rbp-38h]
     45: mov     [rbp-80h],rax
     49: call    fn0
     4e: nop     [rcx-19h]
     55: movzx   eax,byte ptr [rbp-19h]
     59: xor     al,1
     5c: mov     [rbp-29h],al
     5f: test    byte ptr [rbp-29h],0FFh
     63: je      6Fh
     65: mov     rax,[rbp+10h]
     69: mov     [rbp-28h],rax
     6d: jmp     77h
     6f: mov     rax,[rbp+18h]
     73: mov     [rbp-28h],rax
     77: mov     rax,[rbp+20h]
     7b: mov     [rbp-38h],rax
     7f: mov     byte ptr [rbp-51h],1
     83: test    byte ptr [rbp-51h],0FFh
     87: je      0E4h
     89: mov     rax,[rbp-28h]
     8d: mov     [rbp-40h],rax
     91: mov     rax,[rbp-38h]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-40h]
     9d: mov     [rbp-90h],rax
     a4: mov     rax,[rbp-48h]
     a8: mov     [rbp-88h],rax
     af: mov     qword ptr [rbp-80h],4
     b7: mov     qword ptr [rbp-78h],4
     bf: mov     qword ptr [rbp-70h],1
     c7: mov     edi,0FFFFFF98h
     cc: lea     rsi,[k1]
     d3: call    ryo_h_AddrAbs
     d8: call    fn2
     dd: nop     [rcx-28h]
     e4: mov     qword ptr [rbp-58h],1
     ec: imul    rax,[rbp-58h],4
     f1: mov     [rbp-60h],rax
     f5: mov     edi,0FFFFFFC8h
     fa: mov     esi,0FFFFFFD8h
     ff: mov     edx,0FFFFFFA0h
    104: call    ryo_h_Memcpy
    109: mov     edi,0FFFFFFC0h
    10e: mov     esi,0FFFFFFE7h
    113: call    ryo_h_ZextW8W64
    118: mov     rax,[rbp+18h]
    11c: imul    rcx,[rbp-40h],4
    121: add     rax,rcx
    124: mov     [rbp-38h],rax
    128: mov     [rbp+18h],rax
    12c: mov     edi,0FFFFFFC0h
    131: mov     esi,0FFFFFFD7h
    136: call    ryo_h_ZextW8W64
    13b: mov     rax,[rbp+10h]
    13f: imul    rcx,[rbp-40h],4
    144: add     rax,rcx
    147: mov     [rbp-38h],rax
    14b: mov     [rbp+10h],rax
    14f: mov     qword ptr [rbp-58h],1
    157: mov     rax,[rbp+20h]
    15b: imul    rcx,[rbp-58h],4
    160: add     rax,rcx
    163: mov     [rbp-38h],rax
    167: mov     [rbp+20h],rax
    16b: mov     rax,[rbp+10h]
    16f: mov     [rbp-18h],rax
    173: mov     rax,[rbp+18h]
    177: mov     [rbp-10h],rax
    17b: mov     rax,[rbp+20h]
    17f: mov     [rbp-8],rax
    183: mov     edi,0FFFFFFE8h
    188: mov     esi,18h
    18d: call    ryo_h_Ret
    192: leave
    193: ret

fn core::slice::sort::shared::smallsort::small_sort_general::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,130h
      b: lea     rax,[rbp-0E0h]
     12: mov     [rbp-20h],rax
     16: mov     [rbp-0E8h],rax
     1d: mov     byte ptr [rbp-0F9h],1
     24: test    byte ptr [rbp-0F9h],0FFh
     2b: je      8Bh
     2d: jmp     3Bh
     2f: nop
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: mov     rax,[rbp-20h]
     3f: mov     [rbp-0F0h],rax
     46: mov     [rbp-130h],rax
     4d: mov     qword ptr [rbp-128h],4
     58: mov     qword ptr [rbp-120h],4
     63: mov     qword ptr [rbp-118h],30h
     6e: mov     edi,0FFFFFEF0h
     73: lea     rsi,[k0]
     7a: call    ryo_h_AddrAbs
     7f: call    fn1
     84: nop     [rcx-20h]
     8b: mov     rax,[rbp-20h]
     8f: mov     [rbp-0F8h],rax
     96: mov     qword ptr [rbp-0F0h],30h
     a1: mov     [rbp-10h],rax
     a5: mov     rax,[rbp-0F0h]
     ac: mov     [rbp-8],rax
     b0: mov     edi,0FFFFFED0h
     b5: mov     esi,10h
     ba: call    ryo_h_MovW128
     bf: mov     edi,0FFFFFEE0h
     c4: mov     esi,0FFFFFFF0h
     c9: call    ryo_h_MovW128
     ce: mov     rax,[rbp+20h]
     d2: mov     [rbp-110h],rax
     d9: call    fn2
     de: nop     [rcx-18h]
     e5: jmp     30h

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,190h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: cmp     rax,2
     1a: jae     21h
     1c: jmp     50Ah
     21: mov     rax,[rbp+28h]
     25: mov     [rbp-0A0h],rax
     2c: mov     rax,[rbp-90h]
     33: add     rax,10h
     37: mov     [rbp-0A8h],rax
     3e: mov     rax,[rbp-0A0h]
     45: cmp     rax,[rbp-0A8h]
     4c: jae     55h
     4e: call    ryo_h_Abort
     53: ud2
     55: mov     rax,[rbp+10h]
     59: mov     [rbp-60h],rax
     5d: mov     rax,[rbp+18h]
     61: mov     [rbp-58h],rax
     65: mov     rax,[rbp-60h]
     69: mov     [rbp-98h],rax
     70: mov     qword ptr [rbp-150h],2
     7b: mov     edi,0FFFFFF60h
     80: mov     esi,0FFFFFF70h
     85: mov     edx,0FFFFFEB0h
     8a: call    ryo_h_DivUW64
     8f: mov     rax,[rbp+20h]
     93: mov     [rbp-70h],rax
     97: mov     rax,[rbp+28h]
     9b: mov     [rbp-68h],rax
     9f: mov     rax,[rbp-70h]
     a3: mov     [rbp-8],rax
     a7: mov     byte ptr [rbp-149h],1
     ae: test    byte ptr [rbp-149h],0FFh
     b5: je      1C1h
     bb: cmp     qword ptr [rbp-90h],10h
     c3: jb      1C1h
     c9: imul    rcx,[rbp-90h],8
     d1: add     rax,rcx
     d4: mov     [rbp-0B8h],rax
     db: mov     rax,[rbp-98h]
     e2: mov     [rbp-190h],rax
     e9: mov     rax,[rbp-8]
     ed: mov     [rbp-188h],rax
     f4: mov     rax,[rbp-0B8h]
     fb: mov     [rbp-180h],rax
    102: mov     rax,[rbp+30h]
    106: mov     [rbp-178h],rax
    10d: call    fn0
    112: nop     [rcx-8]
    119: mov     rax,[rbp-98h]
    120: imul    rcx,[rbp-0A0h],8
    128: add     rax,rcx
    12b: mov     [rbp-0B8h],rax
    132: mov     rax,[rbp-8]
    136: imul    rcx,[rbp-0A0h],8
    13e: add     rax,rcx
    141: mov     [rbp-0C0h],rax
    148: mov     rax,[rbp-90h]
    14f: add     rax,8
    153: mov     [rbp-0D0h],rax
    15a: mov     rax,[rbp-8]
    15e: imul    rcx,[rbp-0D0h],8
    166: add     rax,rcx
    169: mov     [rbp-0C8h],rax
    170: mov     rax,[rbp-0B8h]
    177: mov     [rbp-190h],rax
    17e: mov     rax,[rbp-0C0h]
    185: mov     [rbp-188h],rax
    18c: mov     rax,[rbp-0C8h]
    193: mov     [rbp-180h],rax
    19a: mov     rax,[rbp+30h]
    19e: mov     [rbp-178h],rax
    1a5: call    fn1
    1aa: nop     [rcx-8]
    1b1: mov     qword ptr [rbp-0A8h],8
    1bc: jmp     2A0h
    1c1: cmp     qword ptr [rbp-90h],8
    1c9: jb      279h
    1cf: mov     rax,[rbp-60h]
    1d3: mov     [rbp-0B8h],rax
    1da: mov     [rbp-190h],rax
    1e1: mov     rax,[rbp-8]
    1e5: mov     [rbp-188h],rax
    1ec: mov     rax,[rbp+30h]
    1f0: mov     [rbp-180h],rax
    1f7: call    fn2
    1fc: nop     [rcx-8]
    203: mov     rax,[rbp-98h]
    20a: imul    rcx,[rbp-0A0h],8
    212: add     rax,rcx
    215: mov     [rbp-0C0h],rax
    21c: mov     [rbp-0B8h],rax
    223: mov     rax,[rbp-8]
    227: imul    rcx,[rbp-0A0h],8
    22f: add     rax,rcx
    232: mov     [rbp-0C0h],rax
    239: mov     rax,[rbp-0B8h]
    240: mov     [rbp-190h],rax
    247: mov     rax,[rbp-0C0h]
    24e: mov     [rbp-188h],rax
    255: mov     rax,[rbp+30h]
    259: mov     [rbp-180h],rax
    260: call    fn3
    265: nop     [rcx-8]
    26c: mov     qword ptr [rbp-0A8h],4
    277: jmp     2A0h
    279: mov     rax,[rbp-60h]
    27d: mov     [rbp-0B8h],rax
    284: mov     byte ptr [rbp-149h],1
    28b: test    byte ptr [rbp-149h],0FFh
    292: je      5F3h
    298: jmp     583h
    29d: nop     [rax]
    2a0: mov     qword ptr [rbp-0D8h],0
    2ab: mov     rax,[rbp-0A0h]
    2b2: mov     [rbp-0D0h],rax
    2b9: mov     edi,0FFFFFF18h
    2be: mov     esi,0FFFFFF28h
    2c3: call    ryo_h_MovW128
    2c8: mov     edi,0FFFFFEF8h
    2cd: lea     rsi,[k4]
    2d4: mov     edx,10h
    2d9: call    ryo_h_Const
    2de: mov     edi,0FFFFFF08h
    2e3: mov     esi,0FFFFFF18h
    2e8: call    ryo_h_MovW128
    2ed: mov     edi,0FFFFFEB8h
    2f2: mov     esi,0FFFFFEF8h
    2f7: mov     edx,20h
    2fc: call    ryo_h_Copy
    301: mov     edi,0FFFFFED8h
    306: mov     esi,0FFFFFEB8h
    30b: mov     edx,20h
    310: call    ryo_h_Copy
    315: mov     edi,0FFFFFF38h
    31a: mov     esi,0FFFFFED8h
    31f: mov     edx,20h
    324: call    ryo_h_Copy
    329: mov     edi,0FFFFFF18h
    32e: mov     esi,0FFFFFF38h
    333: mov     edx,20h
    338: call    ryo_h_Copy
    33d: nop     [rax]
    340: lea     rax,[rbp-0E8h]
    347: mov     [rbp-110h],rax
    34e: mov     [rbp-108h],rax
    355: mov     qword ptr [rbp-100h],2
    360: mov     edi,0FFFFFE70h
    365: mov     esi,0FFFFFEF8h
    36a: call    ryo_h_MovW128
    36f: call    fn5
    374: nop     [rcx-0F8h]
    37b: jmp     715h
    380: call    ryo_h_Unreachable
    385: ud2
    387: mov     rax,[rbp-0F0h]
    38e: mov     [rbp-100h],rax
    395: mov     rax,[rbp-98h]
    39c: imul    rcx,[rbp-100h],8
    3a4: add     rax,rcx
    3a7: mov     [rbp-108h],rax
    3ae: mov     rax,[rbp-8]
    3b2: imul    rcx,[rbp-100h],8
    3ba: add     rax,rcx
    3bd: mov     [rbp-110h],rax
    3c4: cmp     qword ptr [rbp-100h],0
    3cc: je      3F3h
    3ce: jmp     400h
    3d0: lea     rax,[rbp-0E8h]
    3d7: mov     [rbp-150h],rax
    3de: mov     [rbp-190h],rax
    3e5: call    fn6
    3ea: nop     [rcx-150h]
    3f1: jmp     472h
    3f3: mov     rax,[rbp-0A0h]
    3fa: mov     [rbp-28h],rax
    3fe: jmp     412h
    400: mov     rax,[rbp-90h]
    407: sub     rax,[rbp-0A0h]
    40e: mov     [rbp-28h],rax
    412: mov     rax,[rbp-0A8h]
    419: mov     [rbp-118h],rax
    420: mov     [rbp-38h],rax
    424: mov     rax,[rbp-28h]
    428: mov     [rbp-30h],rax
    42c: nop     [rax]
    430: mov     rax,[rbp-38h]
    434: mov     [rbp-130h],rax
    43b: mov     rax,[rbp-30h]
    43f: mov     [rbp-138h],rax
    446: mov     rax,[rbp-130h]
    44d: cmp     rax,[rbp-138h]
    454: setb    [rbp-121h]
    45b: test    byte ptr [rbp-121h],0FFh
    462: je      76Dh
    468: jmp     750h
    46d: nop     [rax]
    470: jmp     430h
    472: mov     rax,[rbp-70h]
    476: mov     [rbp-0C8h],rax
    47d: mov     [rbp-0C0h],rax
    484: mov     rax,[rbp-98h]
    48b: mov     [rbp-0B8h],rax
    492: mov     rax,[rbp-90h]
    499: mov     [rbp-0B0h],rax
    4a0: mov     rax,[rbp-0C0h]
    4a7: mov     [rbp-0D8h],rax
    4ae: mov     rax,[rbp-0B0h]
    4b5: mov     [rbp-0E0h],rax
    4bc: mov     byte ptr [rbp-149h],1
    4c3: test    byte ptr [rbp-149h],0FFh
    4ca: je      94Ah
    4d0: jmp     8F4h
    4d5: nop     [rax+rax]
    4de: xchg    ax,ax
    4e0: mov     rax,[rbp-0C0h]
    4e7: mov     [rbp-0C8h],rax
    4ee: mov     rax,[rbp-0B8h]
    4f5: mov     [rbp-0D0h],rax
    4fc: mov     rax,[rbp-0B0h]
    503: mov     [rbp-0D8h],rax
    50a: xor     edi,edi
    50c: xor     esi,esi
    50e: call    ryo_h_Ret
    513: leave
    514: ret
    515: nop     [rax+rax]
    51e: xchg    ax,ax
    520: lea     rax,[rbp-0E8h]
    527: mov     [rbp-150h],rax
    52e: mov     [rbp-190h],rax
    535: call    fn7
    53a: nop     [rcx-150h]
    541: nop     [rax+rax]
    54a: nop     [rax+rax]
    550: mov     edi,0FFFFFF78h
    555: call    ryo_h_Resume
    55a: ud2
    55c: nop     [rax]
    560: lea     rax,[rbp-0C0h]
    567: mov     [rbp-150h],rax
    56e: mov     [rbp-190h],rax
    575: call    fn8
    57a: nop     [rcx-150h]
    581: jmp     550h
    583: mov     rax,[rbp-60h]
    587: mov     [rbp-0C0h],rax
    58e: mov     rax,[rbp-70h]
    592: mov     [rbp-0C8h],rax
    599: mov     rax,[rbp-0C0h]
    5a0: mov     [rbp-190h],rax
    5a7: mov     rax,[rbp-0C8h]
    5ae: mov     [rbp-188h],rax
    5b5: mov     qword ptr [rbp-180h],8
    5c0: mov     qword ptr [rbp-178h],4
    5cb: mov     qword ptr [rbp-170h],1
    5d6: mov     edi,0FFFFFE98h
    5db: lea     rsi,[k9]
    5e2: call    ryo_h_AddrAbs
    5e7: call    fn10
    5ec: nop     [rcx-70h]
    5f3: mov     qword ptr [rbp-150h],1
    5fe: imul    rax,[rbp-150h],8
    606: mov     [rbp-158h],rax
    60d: mov     edi,0FFFFFFF8h
    612: mov     esi,0FFFFFF48h
    617: mov     edx,0FFFFFEA8h
    61c: call    ryo_h_Memcpy
    621: mov     rax,[rbp-98h]
    628: imul    rcx,[rbp-0A0h],8
    630: add     rax,rcx
    633: mov     [rbp-10h],rax
    637: mov     [rbp-0B8h],rax
    63e: mov     rax,[rbp-8]
    642: imul    rcx,[rbp-0A0h],8
    64a: add     rax,rcx
    64d: mov     [rbp-0C0h],rax
    654: mov     byte ptr [rbp-149h],1
    65b: test    byte ptr [rbp-149h],0FFh
    662: je      6D7h
    664: mov     rax,[rbp-10h]
    668: mov     [rbp-0C8h],rax
    66f: mov     rax,[rbp-0C0h]
    676: mov     [rbp-0D0h],rax
    67d: mov     rax,[rbp-0C8h]
    684: mov     [rbp-190h],rax
    68b: mov     rax,[rbp-0D0h]
    692: mov     [rbp-188h],rax
    699: mov     qword ptr [rbp-180h],8
    6a4: mov     qword ptr [rbp-178h],4
    6af: mov     qword ptr [rbp-170h],1
    6ba: mov     edi,0FFFFFE98h
    6bf: lea     rsi,[k11]
    6c6: call    ryo_h_AddrAbs
    6cb: call    fn12
    6d0: nop     [rcx-70h]
    6d7: mov     qword ptr [rbp-150h],1
    6e2: imul    rax,[rbp-150h],8
    6ea: mov     [rbp-158h],rax
    6f1: mov     edi,0FFFFFF40h
    6f6: mov     esi,0FFFFFF48h
    6fb: mov     edx,0FFFFFEA8h
    700: call    ryo_h_Memcpy
    705: mov     qword ptr [rbp-0A8h],1
    710: jmp     2A0h
    715: mov     rax,[rbp-0F8h]
    71c: mov     [rbp-20h],rax
    720: mov     edi,0FFFFFFE0h
    725: xor     esi,esi
    727: mov     edx,2
    72c: call    ryo_h_SwitchDenseW64
    731: lea     rcx,[744h]
    738: movsxd  rax,[rcx+rax*4]
    73c: add     rax,rcx
    73f: jmp     rax
    741: int3
    742: int3
    743: int3
    744: .long   3d0h
    748: .long   387h
    74c: .long   380h
    750: mov     rax,[rbp-38h]
    754: mov     [rbp-130h],rax
    75b: mov     byte ptr [rbp-149h],1
    762: test    byte ptr [rbp-149h],0FFh
    769: je      7A8h
    76b: jmp     772h
    76d: jmp     340h
    772: mov     rax,[rbp-130h]
    779: mov     [rbp-190h],rax
    780: mov     qword ptr [rbp-188h],1
    78b: mov     edi,0FFFFFE80h
    790: lea     rsi,[k13]
    797: call    ryo_h_AddrAbs
    79c: call    fn14
    7a1: nop     [rcx-80h]
    7a8: mov     rax,[rbp-130h]
    7af: add     rax,1
    7b3: mov     [rbp-138h],rax
    7ba: mov     [rbp-38h],rax
    7be: mov     rax,[rbp-130h]
    7c5: mov     [rbp-118h],rax
    7cc: mov     qword ptr [rbp-120h],1
    7d7: mov     [rbp-128h],rax
    7de: mov     rax,[rbp-108h]
    7e5: imul    rcx,[rbp-128h],8
    7ed: add     rax,rcx
    7f0: mov     [rbp-48h],rax
    7f4: mov     [rbp-130h],rax
    7fb: mov     rax,[rbp-110h]
    802: imul    rcx,[rbp-128h],8
    80a: add     rax,rcx
    80d: mov     [rbp-50h],rax
    811: mov     byte ptr [rbp-149h],1
    818: test    byte ptr [rbp-149h],0FFh
    81f: je      891h
    821: mov     rax,[rbp-48h]
    825: mov     [rbp-138h],rax
    82c: mov     rax,[rbp-50h]
    830: mov     [rbp-140h],rax
    837: mov     rax,[rbp-138h]
    83e: mov     [rbp-190h],rax
    845: mov     rax,[rbp-140h]
    84c: mov     [rbp-188h],rax
    853: mov     qword ptr [rbp-180h],8
    85e: mov     qword ptr [rbp-178h],4
    869: mov     qword ptr [rbp-170h],1
    874: mov     edi,0FFFFFE98h
    879: lea     rsi,[k15]
    880: call    ryo_h_AddrAbs
    885: call    fn16
    88a: nop     [rcx-80h]
    891: mov     qword ptr [rbp-150h],1
    89c: imul    rax,[rbp-150h],8
    8a4: mov     [rbp-158h],rax
    8ab: mov     edi,0FFFFFFB0h
    8b0: mov     esi,0FFFFFED0h
    8b5: mov     edx,0FFFFFEA8h
    8ba: call    ryo_h_Memcpy
    8bf: mov     rax,[rbp-110h]
    8c6: mov     [rbp-190h],rax
    8cd: mov     rax,[rbp-50h]
    8d1: mov     [rbp-188h],rax
    8d8: mov     rax,[rbp+30h]
    8dc: mov     [rbp-180h],rax
    8e3: call    fn17
    8e8: nop     [rcx-50h]
    8ef: jmp     470h
    8f4: mov     rax,[rbp-0D8h]
    8fb: mov     [rbp-0E8h],rax
    902: mov     [rbp-190h],rax
    909: mov     qword ptr [rbp-188h],8
    914: mov     qword ptr [rbp-180h],4
    91f: mov     rax,[rbp-0E0h]
    926: mov     [rbp-178h],rax
    92d: mov     edi,0FFFFFE90h
    932: lea     rsi,[k18]
    939: call    ryo_h_AddrAbs
    93e: call    fn19
    943: nop     [rcx-80h]
    94a: mov     rax,[rbp-0D8h]
    951: mov     [rbp-0F0h],rax
    958: mov     rax,[rbp-0E0h]
    95f: mov     [rbp-0E8h],rax
    966: mov     rax,[rbp-0F0h]
    96d: mov     [rbp-0D0h],rax
    974: mov     rax,[rbp-0E8h]
    97b: mov     [rbp-0C8h],rax
    982: mov     rax,[rbp-0B8h]
    989: mov     [rbp-0D8h],rax
    990: mov     edi,0FFFFFE70h
    995: mov     esi,0FFFFFF30h
    99a: call    ryo_h_MovW128
    99f: mov     rax,[rbp-0D8h]
    9a6: mov     [rbp-180h],rax
    9ad: mov     rax,[rbp+30h]
    9b1: mov     [rbp-178h],rax
    9b8: call    fn20
    9bd: nop     [rcx-50h]
    9c4: jmp     4E0h
    9c9: nop     [rax]
    9d0: lea     rdi,[sym21]
    9d7: lea     rsi,[site22]
    9de: mov     edx,0FFFFFEB0h
    9e3: call    ryo_h_CallExt
    9e8: test    rax,rax
    9eb: je      9F8h
    9ed: call    rax
    9ef: nop     [rcx-148h]
    9f6: jmp     0A08h
    9f8: mov     rdi,rbp
    9fb: lea     rsi,[ro+4]
    a02: call    qword ptr [sym23]
    a08: call    ryo_h_Unreachable
    a0d: ud2
    a0f: mov     rdi,rax
    a12: mov     esi,0FFFFFF78h
    a17: call    ryo_h_Lpad
    a1c: jmp     520h
    a21: mov     rdi,rax
    a24: mov     esi,0FFFFFF78h
    a29: call    ryo_h_Lpad
    a2e: jmp     9D0h
    a30: mov     rdi,rax
    a33: mov     esi,0FFFFFF78h
    a38: call    ryo_h_Lpad
    a3d: jmp     560h

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,190h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: cmp     rax,2
     1a: jae     21h
     1c: jmp     50Ah
     21: mov     rax,[rbp+28h]
     25: mov     [rbp-0A0h],rax
     2c: mov     rax,[rbp-90h]
     33: add     rax,10h
     37: mov     [rbp-0A8h],rax
     3e: mov     rax,[rbp-0A0h]
     45: cmp     rax,[rbp-0A8h]
     4c: jae     55h
     4e: call    ryo_h_Abort
     53: ud2
     55: mov     rax,[rbp+10h]
     59: mov     [rbp-60h],rax
     5d: mov     rax,[rbp+18h]
     61: mov     [rbp-58h],rax
     65: mov     rax,[rbp-60h]
     69: mov     [rbp-98h],rax
     70: mov     qword ptr [rbp-150h],2
     7b: mov     edi,0FFFFFF60h
     80: mov     esi,0FFFFFF70h
     85: mov     edx,0FFFFFEB0h
     8a: call    ryo_h_DivUW64
     8f: mov     rax,[rbp+20h]
     93: mov     [rbp-70h],rax
     97: mov     rax,[rbp+28h]
     9b: mov     [rbp-68h],rax
     9f: mov     rax,[rbp-70h]
     a3: mov     [rbp-8],rax
     a7: mov     byte ptr [rbp-149h],1
     ae: test    byte ptr [rbp-149h],0FFh
     b5: je      1C1h
     bb: cmp     qword ptr [rbp-90h],10h
     c3: jb      1C1h
     c9: imul    rcx,[rbp-90h],4
     d1: add     rax,rcx
     d4: mov     [rbp-0B8h],rax
     db: mov     rax,[rbp-98h]
     e2: mov     [rbp-190h],rax
     e9: mov     rax,[rbp-8]
     ed: mov     [rbp-188h],rax
     f4: mov     rax,[rbp-0B8h]
     fb: mov     [rbp-180h],rax
    102: mov     rax,[rbp+30h]
    106: mov     [rbp-178h],rax
    10d: call    fn0
    112: nop     [rcx-8]
    119: mov     rax,[rbp-98h]
    120: imul    rcx,[rbp-0A0h],4
    128: add     rax,rcx
    12b: mov     [rbp-0B8h],rax
    132: mov     rax,[rbp-8]
    136: imul    rcx,[rbp-0A0h],4
    13e: add     rax,rcx
    141: mov     [rbp-0C0h],rax
    148: mov     rax,[rbp-90h]
    14f: add     rax,8
    153: mov     [rbp-0D0h],rax
    15a: mov     rax,[rbp-8]
    15e: imul    rcx,[rbp-0D0h],4
    166: add     rax,rcx
    169: mov     [rbp-0C8h],rax
    170: mov     rax,[rbp-0B8h]
    177: mov     [rbp-190h],rax
    17e: mov     rax,[rbp-0C0h]
    185: mov     [rbp-188h],rax
    18c: mov     rax,[rbp-0C8h]
    193: mov     [rbp-180h],rax
    19a: mov     rax,[rbp+30h]
    19e: mov     [rbp-178h],rax
    1a5: call    fn1
    1aa: nop     [rcx-8]
    1b1: mov     qword ptr [rbp-0A8h],8
    1bc: jmp     2A0h
    1c1: cmp     qword ptr [rbp-90h],8
    1c9: jb      279h
    1cf: mov     rax,[rbp-60h]
    1d3: mov     [rbp-0B8h],rax
    1da: mov     [rbp-190h],rax
    1e1: mov     rax,[rbp-8]
    1e5: mov     [rbp-188h],rax
    1ec: mov     rax,[rbp+30h]
    1f0: mov     [rbp-180h],rax
    1f7: call    fn2
    1fc: nop     [rcx-8]
    203: mov     rax,[rbp-98h]
    20a: imul    rcx,[rbp-0A0h],4
    212: add     rax,rcx
    215: mov     [rbp-0C0h],rax
    21c: mov     [rbp-0B8h],rax
    223: mov     rax,[rbp-8]
    227: imul    rcx,[rbp-0A0h],4
    22f: add     rax,rcx
    232: mov     [rbp-0C0h],rax
    239: mov     rax,[rbp-0B8h]
    240: mov     [rbp-190h],rax
    247: mov     rax,[rbp-0C0h]
    24e: mov     [rbp-188h],rax
    255: mov     rax,[rbp+30h]
    259: mov     [rbp-180h],rax
    260: call    fn3
    265: nop     [rcx-8]
    26c: mov     qword ptr [rbp-0A8h],4
    277: jmp     2A0h
    279: mov     rax,[rbp-60h]
    27d: mov     [rbp-0B8h],rax
    284: mov     byte ptr [rbp-149h],1
    28b: test    byte ptr [rbp-149h],0FFh
    292: je      5F3h
    298: jmp     583h
    29d: nop     [rax]
    2a0: mov     qword ptr [rbp-0D8h],0
    2ab: mov     rax,[rbp-0A0h]
    2b2: mov     [rbp-0D0h],rax
    2b9: mov     edi,0FFFFFF18h
    2be: mov     esi,0FFFFFF28h
    2c3: call    ryo_h_MovW128
    2c8: mov     edi,0FFFFFEF8h
    2cd: lea     rsi,[k4]
    2d4: mov     edx,10h
    2d9: call    ryo_h_Const
    2de: mov     edi,0FFFFFF08h
    2e3: mov     esi,0FFFFFF18h
    2e8: call    ryo_h_MovW128
    2ed: mov     edi,0FFFFFEB8h
    2f2: mov     esi,0FFFFFEF8h
    2f7: mov     edx,20h
    2fc: call    ryo_h_Copy
    301: mov     edi,0FFFFFED8h
    306: mov     esi,0FFFFFEB8h
    30b: mov     edx,20h
    310: call    ryo_h_Copy
    315: mov     edi,0FFFFFF38h
    31a: mov     esi,0FFFFFED8h
    31f: mov     edx,20h
    324: call    ryo_h_Copy
    329: mov     edi,0FFFFFF18h
    32e: mov     esi,0FFFFFF38h
    333: mov     edx,20h
    338: call    ryo_h_Copy
    33d: nop     [rax]
    340: lea     rax,[rbp-0E8h]
    347: mov     [rbp-110h],rax
    34e: mov     [rbp-108h],rax
    355: mov     qword ptr [rbp-100h],2
    360: mov     edi,0FFFFFE70h
    365: mov     esi,0FFFFFEF8h
    36a: call    ryo_h_MovW128
    36f: call    fn5
    374: nop     [rcx-0F8h]
    37b: jmp     715h
    380: call    ryo_h_Unreachable
    385: ud2
    387: mov     rax,[rbp-0F0h]
    38e: mov     [rbp-100h],rax
    395: mov     rax,[rbp-98h]
    39c: imul    rcx,[rbp-100h],4
    3a4: add     rax,rcx
    3a7: mov     [rbp-108h],rax
    3ae: mov     rax,[rbp-8]
    3b2: imul    rcx,[rbp-100h],4
    3ba: add     rax,rcx
    3bd: mov     [rbp-110h],rax
    3c4: cmp     qword ptr [rbp-100h],0
    3cc: je      3F3h
    3ce: jmp     400h
    3d0: lea     rax,[rbp-0E8h]
    3d7: mov     [rbp-150h],rax
    3de: mov     [rbp-190h],rax
    3e5: call    fn6
    3ea: nop     [rcx-150h]
    3f1: jmp     472h
    3f3: mov     rax,[rbp-0A0h]
    3fa: mov     [rbp-28h],rax
    3fe: jmp     412h
    400: mov     rax,[rbp-90h]
    407: sub     rax,[rbp-0A0h]
    40e: mov     [rbp-28h],rax
    412: mov     rax,[rbp-0A8h]
    419: mov     [rbp-118h],rax
    420: mov     [rbp-38h],rax
    424: mov     rax,[rbp-28h]
    428: mov     [rbp-30h],rax
    42c: nop     [rax]
    430: mov     rax,[rbp-38h]
    434: mov     [rbp-130h],rax
    43b: mov     rax,[rbp-30h]
    43f: mov     [rbp-138h],rax
    446: mov     rax,[rbp-130h]
    44d: cmp     rax,[rbp-138h]
    454: setb    [rbp-121h]
    45b: test    byte ptr [rbp-121h],0FFh
    462: je      76Dh
    468: jmp     750h
    46d: nop     [rax]
    470: jmp     430h
    472: mov     rax,[rbp-70h]
    476: mov     [rbp-0C8h],rax
    47d: mov     [rbp-0C0h],rax
    484: mov     rax,[rbp-98h]
    48b: mov     [rbp-0B8h],rax
    492: mov     rax,[rbp-90h]
    499: mov     [rbp-0B0h],rax
    4a0: mov     rax,[rbp-0C0h]
    4a7: mov     [rbp-0D8h],rax
    4ae: mov     rax,[rbp-0B0h]
    4b5: mov     [rbp-0E0h],rax
    4bc: mov     byte ptr [rbp-149h],1
    4c3: test    byte ptr [rbp-149h],0FFh
    4ca: je      94Ah
    4d0: jmp     8F4h
    4d5: nop     [rax+rax]
    4de: xchg    ax,ax
    4e0: mov     rax,[rbp-0C0h]
    4e7: mov     [rbp-0C8h],rax
    4ee: mov     rax,[rbp-0B8h]
    4f5: mov     [rbp-0D0h],rax
    4fc: mov     rax,[rbp-0B0h]
    503: mov     [rbp-0D8h],rax
    50a: xor     edi,edi
    50c: xor     esi,esi
    50e: call    ryo_h_Ret
    513: leave
    514: ret
    515: nop     [rax+rax]
    51e: xchg    ax,ax
    520: lea     rax,[rbp-0E8h]
    527: mov     [rbp-150h],rax
    52e: mov     [rbp-190h],rax
    535: call    fn7
    53a: nop     [rcx-150h]
    541: nop     [rax+rax]
    54a: nop     [rax+rax]
    550: mov     edi,0FFFFFF78h
    555: call    ryo_h_Resume
    55a: ud2
    55c: nop     [rax]
    560: lea     rax,[rbp-0C0h]
    567: mov     [rbp-150h],rax
    56e: mov     [rbp-190h],rax
    575: call    fn8
    57a: nop     [rcx-150h]
    581: jmp     550h
    583: mov     rax,[rbp-60h]
    587: mov     [rbp-0C0h],rax
    58e: mov     rax,[rbp-70h]
    592: mov     [rbp-0C8h],rax
    599: mov     rax,[rbp-0C0h]
    5a0: mov     [rbp-190h],rax
    5a7: mov     rax,[rbp-0C8h]
    5ae: mov     [rbp-188h],rax
    5b5: mov     qword ptr [rbp-180h],4
    5c0: mov     qword ptr [rbp-178h],4
    5cb: mov     qword ptr [rbp-170h],1
    5d6: mov     edi,0FFFFFE98h
    5db: lea     rsi,[k9]
    5e2: call    ryo_h_AddrAbs
    5e7: call    fn10
    5ec: nop     [rcx-70h]
    5f3: mov     qword ptr [rbp-150h],1
    5fe: imul    rax,[rbp-150h],4
    606: mov     [rbp-158h],rax
    60d: mov     edi,0FFFFFFF8h
    612: mov     esi,0FFFFFF48h
    617: mov     edx,0FFFFFEA8h
    61c: call    ryo_h_Memcpy
    621: mov     rax,[rbp-98h]
    628: imul    rcx,[rbp-0A0h],4
    630: add     rax,rcx
    633: mov     [rbp-10h],rax
    637: mov     [rbp-0B8h],rax
    63e: mov     rax,[rbp-8]
    642: imul    rcx,[rbp-0A0h],4
    64a: add     rax,rcx
    64d: mov     [rbp-0C0h],rax
    654: mov     byte ptr [rbp-149h],1
    65b: test    byte ptr [rbp-149h],0FFh
    662: je      6D7h
    664: mov     rax,[rbp-10h]
    668: mov     [rbp-0C8h],rax
    66f: mov     rax,[rbp-0C0h]
    676: mov     [rbp-0D0h],rax
    67d: mov     rax,[rbp-0C8h]
    684: mov     [rbp-190h],rax
    68b: mov     rax,[rbp-0D0h]
    692: mov     [rbp-188h],rax
    699: mov     qword ptr [rbp-180h],4
    6a4: mov     qword ptr [rbp-178h],4
    6af: mov     qword ptr [rbp-170h],1
    6ba: mov     edi,0FFFFFE98h
    6bf: lea     rsi,[k11]
    6c6: call    ryo_h_AddrAbs
    6cb: call    fn12
    6d0: nop     [rcx-70h]
    6d7: mov     qword ptr [rbp-150h],1
    6e2: imul    rax,[rbp-150h],4
    6ea: mov     [rbp-158h],rax
    6f1: mov     edi,0FFFFFF40h
    6f6: mov     esi,0FFFFFF48h
    6fb: mov     edx,0FFFFFEA8h
    700: call    ryo_h_Memcpy
    705: mov     qword ptr [rbp-0A8h],1
    710: jmp     2A0h
    715: mov     rax,[rbp-0F8h]
    71c: mov     [rbp-20h],rax
    720: mov     edi,0FFFFFFE0h
    725: xor     esi,esi
    727: mov     edx,2
    72c: call    ryo_h_SwitchDenseW64
    731: lea     rcx,[744h]
    738: movsxd  rax,[rcx+rax*4]
    73c: add     rax,rcx
    73f: jmp     rax
    741: int3
    742: int3
    743: int3
    744: .long   3d0h
    748: .long   387h
    74c: .long   380h
    750: mov     rax,[rbp-38h]
    754: mov     [rbp-130h],rax
    75b: mov     byte ptr [rbp-149h],1
    762: test    byte ptr [rbp-149h],0FFh
    769: je      7A8h
    76b: jmp     772h
    76d: jmp     340h
    772: mov     rax,[rbp-130h]
    779: mov     [rbp-190h],rax
    780: mov     qword ptr [rbp-188h],1
    78b: mov     edi,0FFFFFE80h
    790: lea     rsi,[k13]
    797: call    ryo_h_AddrAbs
    79c: call    fn14
    7a1: nop     [rcx-80h]
    7a8: mov     rax,[rbp-130h]
    7af: add     rax,1
    7b3: mov     [rbp-138h],rax
    7ba: mov     [rbp-38h],rax
    7be: mov     rax,[rbp-130h]
    7c5: mov     [rbp-118h],rax
    7cc: mov     qword ptr [rbp-120h],1
    7d7: mov     [rbp-128h],rax
    7de: mov     rax,[rbp-108h]
    7e5: imul    rcx,[rbp-128h],4
    7ed: add     rax,rcx
    7f0: mov     [rbp-48h],rax
    7f4: mov     [rbp-130h],rax
    7fb: mov     rax,[rbp-110h]
    802: imul    rcx,[rbp-128h],4
    80a: add     rax,rcx
    80d: mov     [rbp-50h],rax
    811: mov     byte ptr [rbp-149h],1
    818: test    byte ptr [rbp-149h],0FFh
    81f: je      891h
    821: mov     rax,[rbp-48h]
    825: mov     [rbp-138h],rax
    82c: mov     rax,[rbp-50h]
    830: mov     [rbp-140h],rax
    837: mov     rax,[rbp-138h]
    83e: mov     [rbp-190h],rax
    845: mov     rax,[rbp-140h]
    84c: mov     [rbp-188h],rax
    853: mov     qword ptr [rbp-180h],4
    85e: mov     qword ptr [rbp-178h],4
    869: mov     qword ptr [rbp-170h],1
    874: mov     edi,0FFFFFE98h
    879: lea     rsi,[k15]
    880: call    ryo_h_AddrAbs
    885: call    fn16
    88a: nop     [rcx-80h]
    891: mov     qword ptr [rbp-150h],1
    89c: imul    rax,[rbp-150h],4
    8a4: mov     [rbp-158h],rax
    8ab: mov     edi,0FFFFFFB0h
    8b0: mov     esi,0FFFFFED0h
    8b5: mov     edx,0FFFFFEA8h
    8ba: call    ryo_h_Memcpy
    8bf: mov     rax,[rbp-110h]
    8c6: mov     [rbp-190h],rax
    8cd: mov     rax,[rbp-50h]
    8d1: mov     [rbp-188h],rax
    8d8: mov     rax,[rbp+30h]
    8dc: mov     [rbp-180h],rax
    8e3: call    fn17
    8e8: nop     [rcx-50h]
    8ef: jmp     470h
    8f4: mov     rax,[rbp-0D8h]
    8fb: mov     [rbp-0E8h],rax
    902: mov     [rbp-190h],rax
    909: mov     qword ptr [rbp-188h],4
    914: mov     qword ptr [rbp-180h],4
    91f: mov     rax,[rbp-0E0h]
    926: mov     [rbp-178h],rax
    92d: mov     edi,0FFFFFE90h
    932: lea     rsi,[k18]
    939: call    ryo_h_AddrAbs
    93e: call    fn19
    943: nop     [rcx-80h]
    94a: mov     rax,[rbp-0D8h]
    951: mov     [rbp-0F0h],rax
    958: mov     rax,[rbp-0E0h]
    95f: mov     [rbp-0E8h],rax
    966: mov     rax,[rbp-0F0h]
    96d: mov     [rbp-0D0h],rax
    974: mov     rax,[rbp-0E8h]
    97b: mov     [rbp-0C8h],rax
    982: mov     rax,[rbp-0B8h]
    989: mov     [rbp-0D8h],rax
    990: mov     edi,0FFFFFE70h
    995: mov     esi,0FFFFFF30h
    99a: call    ryo_h_MovW128
    99f: mov     rax,[rbp-0D8h]
    9a6: mov     [rbp-180h],rax
    9ad: mov     rax,[rbp+30h]
    9b1: mov     [rbp-178h],rax
    9b8: call    fn20
    9bd: nop     [rcx-50h]
    9c4: jmp     4E0h
    9c9: nop     [rax]
    9d0: lea     rdi,[sym21]
    9d7: lea     rsi,[site22]
    9de: mov     edx,0FFFFFEB0h
    9e3: call    ryo_h_CallExt
    9e8: test    rax,rax
    9eb: je      9F8h
    9ed: call    rax
    9ef: nop     [rcx-148h]
    9f6: jmp     0A08h
    9f8: mov     rdi,rbp
    9fb: lea     rsi,[ro+4]
    a02: call    qword ptr [sym23]
    a08: call    ryo_h_Unreachable
    a0d: ud2
    a0f: mov     rdi,rax
    a12: mov     esi,0FFFFFF78h
    a17: call    ryo_h_Lpad
    a1c: jmp     520h
    a21: mov     rdi,rax
    a24: mov     esi,0FFFFFF78h
    a29: call    ryo_h_Lpad
    a2e: jmp     9D0h
    a30: mov     rdi,rax
    a33: mov     esi,0FFFFFF78h
    a38: call    ryo_h_Lpad
    a3d: jmp     560h

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,160h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     rax,2
     17: jae     1Eh
     19: jmp     2D0h
     1e: cmp     qword ptr [rbp-60h],20h
     23: jbe     2Ch
     25: call    ryo_h_Abort
     2a: ud2
     2c: mov     qword ptr [rbp-128h],2
     37: mov     edi,0FFFFFF18h
     3c: mov     esi,0FFFFFFA0h
     41: mov     edx,0FFFFFED8h
     46: call    ryo_h_DivUW64
     4b: cmp     qword ptr [rbp-60h],12h
     50: setb    [rbp-0E9h]
     57: mov     rax,[rbp+10h]
     5b: mov     [rbp-40h],rax
     5f: mov     rax,[rbp+18h]
     63: mov     [rbp-38h],rax
     67: mov     rax,[rbp-40h]
     6b: mov     [rbp-0F8h],rax
     72: test    byte ptr [rbp-0E9h],0FFh
     79: je      85h
     7b: mov     rax,[rbp-60h]
     7f: mov     [rbp-8],rax
     83: jmp     90h
     85: mov     rax,[rbp-0E8h]
     8c: mov     [rbp-8],rax
     90: mov     byte ptr [rbp-121h],1
     97: test    byte ptr [rbp-121h],0FFh
     9e: je      32Bh
     a4: jmp     2DBh
     a9: nop     [rax]
     b0: mov     rax,[rbp-20h]
     b4: mov     [rbp-110h],rax
     bb: mov     rax,[rbp-18h]
     bf: mov     [rbp-108h],rax
     c6: mov     [rbp-100h],rax
     cd: cmp     rax,0Dh
     d1: jb      112h
     d3: mov     edi,0FFFFFEF8h
     d8: mov     esi,0FFFFFFE0h
     dd: call    ryo_h_MovW128
     e2: mov     edi,0FFFFFEA0h
     e7: mov     esi,0FFFFFEF8h
     ec: call    ryo_h_MovW128
     f1: mov     rax,[rbp+20h]
     f5: mov     [rbp-150h],rax
     fc: call    fn0
    101: nop     [rcx-10h]
    108: mov     qword ptr [rbp-10h],0Dh
    110: jmp     17Ch
    112: mov     rax,[rbp-20h]
    116: mov     [rbp-110h],rax
    11d: mov     rax,[rbp-18h]
    121: mov     [rbp-108h],rax
    128: mov     [rbp-100h],rax
    12f: cmp     rax,9
    133: jb      174h
    135: mov     edi,0FFFFFEF8h
    13a: mov     esi,0FFFFFFE0h
    13f: call    ryo_h_MovW128
    144: mov     edi,0FFFFFEA0h
    149: mov     esi,0FFFFFEF8h
    14e: call    ryo_h_MovW128
    153: mov     rax,[rbp+20h]
    157: mov     [rbp-150h],rax
    15e: call    fn1
    163: nop     [rcx-10h]
    16a: mov     qword ptr [rbp-10h],9
    172: jmp     17Ch
    174: mov     qword ptr [rbp-10h],1
    17c: mov     edi,0FFFFFEF8h
    181: mov     esi,0FFFFFFE0h
    186: call    ryo_h_MovW128
    18b: mov     edi,0FFFFFEA0h
    190: mov     esi,0FFFFFEF8h
    195: call    ryo_h_MovW128
    19a: mov     rax,[rbp-10h]
    19e: mov     [rbp-150h],rax
    1a5: mov     rax,[rbp+20h]
    1a9: mov     [rbp-148h],rax
    1b0: call    fn2
    1b5: nop     [rcx-10h]
    1bc: test    byte ptr [rbp-0E9h],0FFh
    1c3: je      1CAh
    1c5: jmp     2D0h
    1ca: mov     rax,[rbp-20h]
    1ce: mov     [rbp-110h],rax
    1d5: mov     rax,[rbp-18h]
    1d9: mov     [rbp-108h],rax
    1e0: mov     rax,[rbp-110h]
    1e7: mov     [rbp-120h],rax
    1ee: mov     rax,[rbp-108h]
    1f5: mov     [rbp-118h],rax
    1fc: mov     rax,[rbp-120h]
    203: mov     [rbp-100h],rax
    20a: mov     rax,[rbp-40h]
    20e: mov     [rbp-108h],rax
    215: mov     rax,[rbp-100h]
    21c: cmp     rax,[rbp-108h]
    223: je      24Dh
    225: lea     rax,[rbp-0E0h]
    22c: mov     [rbp-48h],rax
    230: mov     [rbp-28h],rax
    234: mov     byte ptr [rbp-121h],1
    23b: test    byte ptr [rbp-121h],0FFh
    242: je      43Ch
    248: jmp     3ECh
    24d: mov     rax,[rbp-0F8h]
    254: imul    rcx,[rbp-0E8h],4
    25c: add     rax,rcx
    25f: mov     [rbp-100h],rax
    266: mov     rax,[rbp-60h]
    26a: sub     rax,[rbp-0E8h]
    271: mov     [rbp-108h],rax
    278: mov     byte ptr [rbp-121h],1
    27f: test    byte ptr [rbp-121h],0FFh
    286: je      3B5h
    28c: jmp     35Fh
    291: nop     [rax+rax]
    29a: nop     [rax+rax]
    2a0: mov     rax,[rbp-48h]
    2a4: mov     [rbp-100h],rax
    2ab: mov     byte ptr [rbp-121h],1
    2b2: test    byte ptr [rbp-121h],0FFh
    2b9: je      50Bh
    2bf: jmp     49Bh
    2c4: nop     [rax+rax]
    2cd: nop     [rax]
    2d0: xor     edi,edi
    2d2: xor     esi,esi
    2d4: call    ryo_h_Ret
    2d9: leave
    2da: ret
    2db: mov     rax,[rbp-40h]
    2df: mov     [rbp-100h],rax
    2e6: mov     [rbp-160h],rax
    2ed: mov     qword ptr [rbp-158h],4
    2f8: mov     qword ptr [rbp-150h],4
    303: mov     rax,[rbp-8]
    307: mov     [rbp-148h],rax
    30e: mov     edi,0FFFFFEC0h
    313: lea     rsi,[k3]
    31a: call    ryo_h_AddrAbs
    31f: call    fn4
    324: nop     [rcx-40h]
    32b: mov     rax,[rbp-0F8h]
    332: mov     [rbp-108h],rax
    339: mov     rax,[rbp-8]
    33d: mov     [rbp-100h],rax
    344: mov     rax,[rbp-108h]
    34b: mov     [rbp-20h],rax
    34f: mov     rax,[rbp-100h]
    356: mov     [rbp-18h],rax
    35a: jmp     0B0h
    35f: mov     rax,[rbp-100h]
    366: mov     [rbp-110h],rax
    36d: mov     [rbp-160h],rax
    374: mov     qword ptr [rbp-158h],4
    37f: mov     qword ptr [rbp-150h],4
    38a: mov     rax,[rbp-108h]
    391: mov     [rbp-148h],rax
    398: mov     edi,0FFFFFEC0h
    39d: lea     rsi,[k5]
    3a4: call    ryo_h_AddrAbs
    3a9: call    fn6
    3ae: nop     [rcx-48h]
    3b5: mov     rax,[rbp-100h]
    3bc: mov     [rbp-118h],rax
    3c3: mov     rax,[rbp-108h]
    3ca: mov     [rbp-110h],rax
    3d1: mov     rax,[rbp-118h]
    3d8: mov     [rbp-20h],rax
    3dc: mov     rax,[rbp-110h]
    3e3: mov     [rbp-18h],rax
    3e7: jmp     0B0h
    3ec: mov     rax,[rbp-40h]
    3f0: mov     [rbp-110h],rax
    3f7: mov     [rbp-160h],rax
    3fe: mov     qword ptr [rbp-158h],4
    409: mov     qword ptr [rbp-150h],4
    414: mov     rax,[rbp-60h]
    418: mov     [rbp-148h],rax
    41f: mov     edi,0FFFFFEC0h
    424: lea     rsi,[k7]
    42b: call    ryo_h_AddrAbs
    430: call    fn8
    435: nop     [rcx-48h]
    43c: mov     rax,[rbp-0F8h]
    443: mov     [rbp-58h],rax
    447: mov     rax,[rbp-60h]
    44b: mov     [rbp-50h],rax
    44f: mov     rax,[rbp-58h]
    453: mov     [rbp-108h],rax
    45a: mov     rax,[rbp-50h]
    45e: mov     [rbp-100h],rax
    465: mov     edi,0FFFFFEA0h
    46a: mov     esi,0FFFFFEF8h
    46f: call    ryo_h_MovW128
    474: mov     rax,[rbp-28h]
    478: mov     [rbp-150h],rax
    47f: mov     rax,[rbp+20h]
    483: mov     [rbp-148h],rax
    48a: call    fn9
    48f: nop     [rcx-30h]
    496: jmp     2A0h
    49b: mov     rax,[rbp-48h]
    49f: mov     [rbp-108h],rax
    4a6: mov     rax,[rbp-40h]
    4aa: mov     [rbp-110h],rax
    4b1: mov     rax,[rbp-108h]
    4b8: mov     [rbp-160h],rax
    4bf: mov     rax,[rbp-110h]
    4c6: mov     [rbp-158h],rax
    4cd: mov     qword ptr [rbp-150h],4
    4d8: mov     qword ptr [rbp-148h],4
    4e3: mov     rax,[rbp-60h]
    4e7: mov     [rbp-140h],rax
    4ee: mov     edi,0FFFFFEC8h
    4f3: lea     rsi,[k10]
    4fa: call    ryo_h_AddrAbs
    4ff: call    fn11
    504: nop     [rcx-58h]
    50b: imul    rax,[rbp-60h],4
    510: mov     [rbp-128h],rax
    517: mov     edi,0FFFFFF08h
    51c: mov     esi,0FFFFFF00h
    521: mov     edx,0FFFFFED8h
    526: call    ryo_h_Memcpy
    52b: jmp     2D0h

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     rax,0Dh
     14: jae     1Dh
     16: call    ryo_h_Abort
     1b: ud2
     1d: mov     rax,[rbp+10h]
     21: mov     [rbp-18h],rax
     25: mov     rax,[rbp+18h]
     29: mov     [rbp-10h],rax
     2d: mov     rax,[rbp-18h]
     31: mov     [rbp-8],rax
     35: mov     [rbp-40h],rax
     39: mov     qword ptr [rbp-38h],0
     41: mov     qword ptr [rbp-30h],0Ch
     49: mov     rax,[rbp+20h]
     4d: mov     [rbp-28h],rax
     51: call    fn0
     56: nop     [rcx]
     5d: mov     rax,[rbp-8]
     61: mov     [rbp-40h],rax
     65: mov     qword ptr [rbp-38h],1
     6d: mov     qword ptr [rbp-30h],0Ah
     75: mov     rax,[rbp+20h]
     79: mov     [rbp-28h],rax
     7d: call    fn1
     82: nop     [rcx]
     89: mov     rax,[rbp-8]
     8d: mov     [rbp-40h],rax
     91: mov     qword ptr [rbp-38h],2
     99: mov     qword ptr [rbp-30h],9
     a1: mov     rax,[rbp+20h]
     a5: mov     [rbp-28h],rax
     a9: call    fn2
     ae: nop     [rcx]
     b5: mov     rax,[rbp-8]
     b9: mov     [rbp-40h],rax
     bd: mov     qword ptr [rbp-38h],3
     c5: mov     qword ptr [rbp-30h],7
     cd: mov     rax,[rbp+20h]
     d1: mov     [rbp-28h],rax
     d5: call    fn3
     da: nop     [rcx]
     e1: mov     rax,[rbp-8]
     e5: mov     [rbp-40h],rax
     e9: mov     qword ptr [rbp-38h],5
     f1: mov     qword ptr [rbp-30h],0Bh
     f9: mov     rax,[rbp+20h]
     fd: mov     [rbp-28h],rax
    101: call    fn4
    106: nop     [rcx]
    10d: mov     rax,[rbp-8]
    111: mov     [rbp-40h],rax
    115: mov     qword ptr [rbp-38h],6
    11d: mov     qword ptr [rbp-30h],8
    125: mov     rax,[rbp+20h]
    129: mov     [rbp-28h],rax
    12d: call    fn5
    132: nop     [rcx]
    139: mov     rax,[rbp-8]
    13d: mov     [rbp-40h],rax
    141: mov     qword ptr [rbp-38h],1
    149: mov     qword ptr [rbp-30h],6
    151: mov     rax,[rbp+20h]
    155: mov     [rbp-28h],rax
    159: call    fn6
    15e: nop     [rcx]
    165: mov     rax,[rbp-8]
    169: mov     [rbp-40h],rax
    16d: mov     qword ptr [rbp-38h],2
    175: mov     qword ptr [rbp-30h],3
    17d: mov     rax,[rbp+20h]
    181: mov     [rbp-28h],rax
    185: call    fn7
    18a: nop     [rcx]
    191: mov     rax,[rbp-8]
    195: mov     [rbp-40h],rax
    199: mov     qword ptr [rbp-38h],4
    1a1: mov     qword ptr [rbp-30h],0Bh
    1a9: mov     rax,[rbp+20h]
    1ad: mov     [rbp-28h],rax
    1b1: call    fn8
    1b6: nop     [rcx]
    1bd: mov     rax,[rbp-8]
    1c1: mov     [rbp-40h],rax
    1c5: mov     qword ptr [rbp-38h],7
    1cd: mov     qword ptr [rbp-30h],9
    1d5: mov     rax,[rbp+20h]
    1d9: mov     [rbp-28h],rax
    1dd: call    fn9
    1e2: nop     [rcx]
    1e9: mov     rax,[rbp-8]
    1ed: mov     [rbp-40h],rax
    1f1: mov     qword ptr [rbp-38h],8
    1f9: mov     qword ptr [rbp-30h],0Ah
    201: mov     rax,[rbp+20h]
    205: mov     [rbp-28h],rax
    209: call    fn10
    20e: nop     [rcx]
    215: mov     rax,[rbp-8]
    219: mov     [rbp-40h],rax
    21d: mov     qword ptr [rbp-38h],0
    225: mov     qword ptr [rbp-30h],4
    22d: mov     rax,[rbp+20h]
    231: mov     [rbp-28h],rax
    235: call    fn11
    23a: nop     [rcx]
    241: mov     rax,[rbp-8]
    245: mov     [rbp-40h],rax
    249: mov     qword ptr [rbp-38h],1
    251: mov     qword ptr [rbp-30h],2
    259: mov     rax,[rbp+20h]
    25d: mov     [rbp-28h],rax
    261: call    fn12
    266: nop     [rcx]
    26d: mov     rax,[rbp-8]
    271: mov     [rbp-40h],rax
    275: mov     qword ptr [rbp-38h],3
    27d: mov     qword ptr [rbp-30h],6
    285: mov     rax,[rbp+20h]
    289: mov     [rbp-28h],rax
    28d: call    fn13
    292: nop     [rcx]
    299: mov     rax,[rbp-8]
    29d: mov     [rbp-40h],rax
    2a1: mov     qword ptr [rbp-38h],7
    2a9: mov     qword ptr [rbp-30h],8
    2b1: mov     rax,[rbp+20h]
    2b5: mov     [rbp-28h],rax
    2b9: call    fn14
    2be: nop     [rcx]
    2c5: mov     rax,[rbp-8]
    2c9: mov     [rbp-40h],rax
    2cd: mov     qword ptr [rbp-38h],9
    2d5: mov     qword ptr [rbp-30h],0Ah
    2dd: mov     rax,[rbp+20h]
    2e1: mov     [rbp-28h],rax
    2e5: call    fn15
    2ea: nop     [rcx]
    2f1: mov     rax,[rbp-8]
    2f5: mov     [rbp-40h],rax
    2f9: mov     qword ptr [rbp-38h],0Bh
    301: mov     qword ptr [rbp-30h],0Ch
    309: mov     rax,[rbp+20h]
    30d: mov     [rbp-28h],rax
    311: call    fn16
    316: nop     [rcx]
    31d: mov     rax,[rbp-8]
    321: mov     [rbp-40h],rax
    325: mov     qword ptr [rbp-38h],4
    32d: mov     qword ptr [rbp-30h],6
    335: mov     rax,[rbp+20h]
    339: mov     [rbp-28h],rax
    33d: call    fn17
    342: nop     [rcx]
    349: mov     rax,[rbp-8]
    34d: mov     [rbp-40h],rax
    351: mov     qword ptr [rbp-38h],5
    359: mov     qword ptr [rbp-30h],9
    361: mov     rax,[rbp+20h]
    365: mov     [rbp-28h],rax
    369: call    fn18
    36e: nop     [rcx]
    375: mov     rax,[rbp-8]
    379: mov     [rbp-40h],rax
    37d: mov     qword ptr [rbp-38h],8
    385: mov     qword ptr [rbp-30h],0Bh
    38d: mov     rax,[rbp+20h]
    391: mov     [rbp-28h],rax
    395: call    fn19
    39a: nop     [rcx]
    3a1: mov     rax,[rbp-8]
    3a5: mov     [rbp-40h],rax
    3a9: mov     qword ptr [rbp-38h],0Ah
    3b1: mov     qword ptr [rbp-30h],0Ch
    3b9: mov     rax,[rbp+20h]
    3bd: mov     [rbp-28h],rax
    3c1: call    fn20
    3c6: nop     [rcx]
    3cd: mov     rax,[rbp-8]
    3d1: mov     [rbp-40h],rax
    3d5: mov     qword ptr [rbp-38h],0
    3dd: mov     qword ptr [rbp-30h],5
    3e5: mov     rax,[rbp+20h]
    3e9: mov     [rbp-28h],rax
    3ed: call    fn21
    3f2: nop     [rcx]
    3f9: mov     rax,[rbp-8]
    3fd: mov     [rbp-40h],rax
    401: mov     qword ptr [rbp-38h],3
    409: mov     qword ptr [rbp-30h],8
    411: mov     rax,[rbp+20h]
    415: mov     [rbp-28h],rax
    419: call    fn22
    41e: nop     [rcx]
    425: mov     rax,[rbp-8]
    429: mov     [rbp-40h],rax
    42d: mov     qword ptr [rbp-38h],4
    435: mov     qword ptr [rbp-30h],7
    43d: mov     rax,[rbp+20h]
    441: mov     [rbp-28h],rax
    445: call    fn23
    44a: nop     [rcx]
    451: mov     rax,[rbp-8]
    455: mov     [rbp-40h],rax
    459: mov     qword ptr [rbp-38h],6
    461: mov     qword ptr [rbp-30h],0Bh
    469: mov     rax,[rbp+20h]
    46d: mov     [rbp-28h],rax
    471: call    fn24
    476: nop     [rcx]
    47d: mov     rax,[rbp-8]
    481: mov     [rbp-40h],rax
    485: mov     qword ptr [rbp-38h],9
    48d: mov     qword ptr [rbp-30h],0Ah
    495: mov     rax,[rbp+20h]
    499: mov     [rbp-28h],rax
    49d: call    fn25
    4a2: nop     [rcx]
    4a9: mov     rax,[rbp-8]
    4ad: mov     [rbp-40h],rax
    4b1: mov     qword ptr [rbp-38h],0
    4b9: mov     qword ptr [rbp-30h],1
    4c1: mov     rax,[rbp+20h]
    4c5: mov     [rbp-28h],rax
    4c9: call    fn26
    4ce: nop     [rcx]
    4d5: mov     rax,[rbp-8]
    4d9: mov     [rbp-40h],rax
    4dd: mov     qword ptr [rbp-38h],2
    4e5: mov     qword ptr [rbp-30h],5
    4ed: mov     rax,[rbp+20h]
    4f1: mov     [rbp-28h],rax
    4f5: call    fn27
    4fa: nop     [rcx]
    501: mov     rax,[rbp-8]
    505: mov     [rbp-40h],rax
    509: mov     qword ptr [rbp-38h],6
    511: mov     qword ptr [rbp-30h],9
    519: mov     rax,[rbp+20h]
    51d: mov     [rbp-28h],rax
    521: call    fn28
    526: nop     [rcx]
    52d: mov     rax,[rbp-8]
    531: mov     [rbp-40h],rax
    535: mov     qword ptr [rbp-38h],7
    53d: mov     qword ptr [rbp-30h],8
    545: mov     rax,[rbp+20h]
    549: mov     [rbp-28h],rax
    54d: call    fn29
    552: nop     [rcx]
    559: mov     rax,[rbp-8]
    55d: mov     [rbp-40h],rax
    561: mov     qword ptr [rbp-38h],0Ah
    569: mov     qword ptr [rbp-30h],0Bh
    571: mov     rax,[rbp+20h]
    575: mov     [rbp-28h],rax
    579: call    fn30
    57e: nop     [rcx]
    585: mov     rax,[rbp-8]
    589: mov     [rbp-40h],rax
    58d: mov     qword ptr [rbp-38h],1
    595: mov     qword ptr [rbp-30h],3
    59d: mov     rax,[rbp+20h]
    5a1: mov     [rbp-28h],rax
    5a5: call    fn31
    5aa: nop     [rcx]
    5b1: mov     rax,[rbp-8]
    5b5: mov     [rbp-40h],rax
    5b9: mov     qword ptr [rbp-38h],2
    5c1: mov     qword ptr [rbp-30h],4
    5c9: mov     rax,[rbp+20h]
    5cd: mov     [rbp-28h],rax
    5d1: call    fn32
    5d6: nop     [rcx]
    5dd: mov     rax,[rbp-8]
    5e1: mov     [rbp-40h],rax
    5e5: mov     qword ptr [rbp-38h],5
    5ed: mov     qword ptr [rbp-30h],6
    5f5: mov     rax,[rbp+20h]
    5f9: mov     [rbp-28h],rax
    5fd: call    fn33
    602: nop     [rcx]
    609: mov     rax,[rbp-8]
    60d: mov     [rbp-40h],rax
    611: mov     qword ptr [rbp-38h],9
    619: mov     qword ptr [rbp-30h],0Ah
    621: mov     rax,[rbp+20h]
    625: mov     [rbp-28h],rax
    629: call    fn34
    62e: nop     [rcx]
    635: mov     rax,[rbp-8]
    639: mov     [rbp-40h],rax
    63d: mov     qword ptr [rbp-38h],1
    645: mov     qword ptr [rbp-30h],2
    64d: mov     rax,[rbp+20h]
    651: mov     [rbp-28h],rax
    655: call    fn35
    65a: nop     [rcx]
    661: mov     rax,[rbp-8]
    665: mov     [rbp-40h],rax
    669: mov     qword ptr [rbp-38h],3
    671: mov     qword ptr [rbp-30h],4
    679: mov     rax,[rbp+20h]
    67d: mov     [rbp-28h],rax
    681: call    fn36
    686: nop     [rcx]
    68d: mov     rax,[rbp-8]
    691: mov     [rbp-40h],rax
    695: mov     qword ptr [rbp-38h],5
    69d: mov     qword ptr [rbp-30h],7
    6a5: mov     rax,[rbp+20h]
    6a9: mov     [rbp-28h],rax
    6ad: call    fn37
    6b2: nop     [rcx]
    6b9: mov     rax,[rbp-8]
    6bd: mov     [rbp-40h],rax
    6c1: mov     qword ptr [rbp-38h],6
    6c9: mov     qword ptr [rbp-30h],8
    6d1: mov     rax,[rbp+20h]
    6d5: mov     [rbp-28h],rax
    6d9: call    fn38
    6de: nop     [rcx]
    6e5: mov     rax,[rbp-8]
    6e9: mov     [rbp-40h],rax
    6ed: mov     qword ptr [rbp-38h],2
    6f5: mov     qword ptr [rbp-30h],3
    6fd: mov     rax,[rbp+20h]
    701: mov     [rbp-28h],rax
    705: call    fn39
    70a: nop     [rcx]
    711: mov     rax,[rbp-8]
    715: mov     [rbp-40h],rax
    719: mov     qword ptr [rbp-38h],4
    721: mov     qword ptr [rbp-30h],5
    729: mov     rax,[rbp+20h]
    72d: mov     [rbp-28h],rax
    731: call    fn40
    736: nop     [rcx]
    73d: mov     rax,[rbp-8]
    741: mov     [rbp-40h],rax
    745: mov     qword ptr [rbp-38h],6
    74d: mov     qword ptr [rbp-30h],7
    755: mov     rax,[rbp+20h]
    759: mov     [rbp-28h],rax
    75d: call    fn41
    762: nop     [rcx]
    769: mov     rax,[rbp-8]
    76d: mov     [rbp-40h],rax
    771: mov     qword ptr [rbp-38h],8
    779: mov     qword ptr [rbp-30h],9
    781: mov     rax,[rbp+20h]
    785: mov     [rbp-28h],rax
    789: call    fn42
    78e: nop     [rcx]
    795: mov     rax,[rbp-8]
    799: mov     [rbp-40h],rax
    79d: mov     qword ptr [rbp-38h],3
    7a5: mov     qword ptr [rbp-30h],4
    7ad: mov     rax,[rbp+20h]
    7b1: mov     [rbp-28h],rax
    7b5: call    fn43
    7ba: nop     [rcx]
    7c1: mov     rax,[rbp-8]
    7c5: mov     [rbp-40h],rax
    7c9: mov     qword ptr [rbp-38h],5
    7d1: mov     qword ptr [rbp-30h],6
    7d9: mov     rax,[rbp+20h]
    7dd: mov     [rbp-28h],rax
    7e1: call    fn44
    7e6: nop     [rcx]
    7ed: xor     edi,edi
    7ef: xor     esi,esi
    7f1: call    ryo_h_Ret
    7f6: leave
    7f7: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rax,[rbp+10h]
     17: imul    rcx,[rbp-78h],8
     1c: add     rax,rcx
     1f: mov     [rbp-28h],rax
     23: mov     [rbp-20h],rax
     27: mov     rax,[rbp+10h]
     2b: mov     [rbp-30h],rax
     2f: mov     rax,[rbp-20h]
     33: mov     [rbp-18h],rax
     37: mov     rax,[rbp-30h]
     3b: mov     [rbp-10h],rax
     3f: mov     rax,[rbp+20h]
     43: mov     [rbp-0B0h],rax
     4a: mov     rax,[rbp-18h]
     4e: mov     [rbp-0A8h],rax
     55: mov     rax,[rbp-10h]
     59: mov     [rbp-0A0h],rax
     60: call    fn0
     65: nop     [rcx-1]
     6c: mov     qword ptr [rbp-78h],3
     74: mov     rax,[rbp+10h]
     78: imul    rcx,[rbp-78h],8
     7d: add     rax,rcx
     80: mov     [rbp-28h],rax
     84: mov     [rbp-20h],rax
     88: mov     qword ptr [rbp-78h],2
     90: mov     rax,[rbp+10h]
     94: imul    rcx,[rbp-78h],8
     99: add     rax,rcx
     9c: mov     [rbp-38h],rax
     a0: mov     [rbp-30h],rax
     a4: mov     rax,[rbp-20h]
     a8: mov     [rbp-18h],rax
     ac: mov     rax,[rbp-30h]
     b0: mov     [rbp-10h],rax
     b4: mov     rax,[rbp+20h]
     b8: mov     [rbp-0B0h],rax
     bf: mov     rax,[rbp-18h]
     c3: mov     [rbp-0A8h],rax
     ca: mov     rax,[rbp-10h]
     ce: mov     [rbp-0A0h],rax
     d5: call    fn1
     da: nop     [rcx-2]
     e1: mov     edi,0FFFFFFE8h
     e6: mov     esi,0FFFFFFFFh
     eb: call    ryo_h_ZextW8W64
     f0: mov     rax,[rbp+10h]
     f4: imul    rcx,[rbp-18h],8
     f9: add     rax,rcx
     fc: mov     [rbp-10h],rax
    100: movzx   eax,byte ptr [rbp-1]
    104: xor     al,1
    107: mov     [rbp-3],al
    10a: mov     edi,0FFFFFFE0h
    10f: mov     esi,0FFFFFFFDh
    114: call    ryo_h_ZextW8W64
    119: mov     rax,[rbp+10h]
    11d: imul    rcx,[rbp-20h],8
    122: add     rax,rcx
    125: mov     [rbp-18h],rax
    129: mov     edi,0FFFFFFD0h
    12e: mov     esi,0FFFFFFFEh
    133: call    ryo_h_ZextW8W64
    138: mov     qword ptr [rbp-78h],2
    140: mov     rax,[rbp-78h]
    144: add     rax,[rbp-30h]
    148: mov     [rbp-28h],rax
    14c: mov     rax,[rbp+10h]
    150: imul    rcx,[rbp-28h],8
    155: add     rax,rcx
    158: mov     [rbp-20h],rax
    15c: movzx   eax,byte ptr [rbp-2]
    160: xor     al,1
    163: mov     [rbp-3],al
    166: mov     edi,0FFFFFFC8h
    16b: mov     esi,0FFFFFFFDh
    170: call    ryo_h_ZextW8W64
    175: mov     qword ptr [rbp-78h],2
    17d: mov     rax,[rbp-78h]
    181: add     rax,[rbp-38h]
    185: mov     [rbp-30h],rax
    189: mov     rax,[rbp+10h]
    18d: imul    rcx,[rbp-30h],8
    192: add     rax,rcx
    195: mov     [rbp-28h],rax
    199: mov     rax,[rbp-20h]
    19d: mov     [rbp-40h],rax
    1a1: mov     rax,[rbp-10h]
    1a5: mov     [rbp-48h],rax
    1a9: mov     rax,[rbp-40h]
    1ad: mov     [rbp-38h],rax
    1b1: mov     rax,[rbp-48h]
    1b5: mov     [rbp-30h],rax
    1b9: mov     rax,[rbp+20h]
    1bd: mov     [rbp-0B0h],rax
    1c4: mov     rax,[rbp-38h]
    1c8: mov     [rbp-0A8h],rax
    1cf: mov     rax,[rbp-30h]
    1d3: mov     [rbp-0A0h],rax
    1da: call    fn2
    1df: nop     [rcx-3]
    1e6: mov     rax,[rbp-28h]
    1ea: mov     [rbp-40h],rax
    1ee: mov     rax,[rbp-18h]
    1f2: mov     [rbp-48h],rax
    1f6: mov     rax,[rbp-40h]
    1fa: mov     [rbp-38h],rax
    1fe: mov     rax,[rbp-48h]
    202: mov     [rbp-30h],rax
    206: mov     rax,[rbp+20h]
    20a: mov     [rbp-0B0h],rax
    211: mov     rax,[rbp-38h]
    215: mov     [rbp-0A8h],rax
    21c: mov     rax,[rbp-30h]
    220: mov     [rbp-0A0h],rax
    227: call    fn3
    22c: nop     [rcx-4]
    233: movzx   eax,byte ptr [rbp-3]
    237: mov     [rbp-0A8h],al
    23d: mov     rax,[rbp-20h]
    241: mov     [rbp-0B0h],rax
    248: mov     rax,[rbp-10h]
    24c: mov     [rbp-0A0h],rax
    253: call    fn4
    258: nop     [rcx-30h]
    25f: movzx   eax,byte ptr [rbp-4]
    263: mov     [rbp-0A8h],al
    269: mov     rax,[rbp-18h]
    26d: mov     [rbp-0B0h],rax
    274: mov     rax,[rbp-28h]
    278: mov     [rbp-0A0h],rax
    27f: call    fn5
    284: nop     [rcx-38h]
    28b: movzx   eax,byte ptr [rbp-4]
    28f: mov     [rbp-0A8h],al
    295: mov     rax,[rbp-20h]
    299: mov     [rbp-0B0h],rax
    2a0: mov     rax,[rbp-18h]
    2a4: mov     [rbp-0A0h],rax
    2ab: call    fn6
    2b0: nop     [rcx-48h]
    2b7: movzx   eax,byte ptr [rbp-3]
    2bb: mov     [rbp-0A8h],al
    2c1: mov     rax,[rbp-10h]
    2c5: mov     [rbp-0B0h],rax
    2cc: mov     rax,[rbp-48h]
    2d0: mov     [rbp-0A0h],rax
    2d7: call    fn7
    2dc: nop     [rcx-40h]
    2e3: movzx   eax,byte ptr [rbp-3]
    2e7: mov     [rbp-0A8h],al
    2ed: mov     rax,[rbp-18h]
    2f1: mov     [rbp-0B0h],rax
    2f8: mov     rax,[rbp-20h]
    2fc: mov     [rbp-0A0h],rax
    303: call    fn8
    308: nop     [rcx-50h]
    30f: movzx   eax,byte ptr [rbp-4]
    313: mov     [rbp-0A8h],al
    319: mov     rax,[rbp-28h]
    31d: mov     [rbp-0B0h],rax
    324: mov     rax,[rbp-50h]
    328: mov     [rbp-0A0h],rax
    32f: call    fn9
    334: nop     [rcx-48h]
    33b: mov     rax,[rbp-48h]
    33f: mov     [rbp-60h],rax
    343: mov     rax,[rbp-40h]
    347: mov     [rbp-68h],rax
    34b: mov     rax,[rbp-60h]
    34f: mov     [rbp-58h],rax
    353: mov     rax,[rbp-68h]
    357: mov     [rbp-50h],rax
    35b: mov     rax,[rbp+20h]
    35f: mov     [rbp-0B0h],rax
    366: mov     rax,[rbp-58h]
    36a: mov     [rbp-0A8h],rax
    371: mov     rax,[rbp-50h]
    375: mov     [rbp-0A0h],rax
    37c: call    fn10
    381: nop     [rcx-5]
    388: movzx   eax,byte ptr [rbp-5]
    38c: mov     [rbp-0A8h],al
    392: mov     rax,[rbp-48h]
    396: mov     [rbp-0B0h],rax
    39d: mov     rax,[rbp-40h]
    3a1: mov     [rbp-0A0h],rax
    3a8: call    fn11
    3ad: nop     [rcx-50h]
    3b4: movzx   eax,byte ptr [rbp-5]
    3b8: mov     [rbp-0A8h],al
    3be: mov     rax,[rbp-40h]
    3c2: mov     [rbp-0B0h],rax
    3c9: mov     rax,[rbp-48h]
    3cd: mov     [rbp-0A0h],rax
    3d4: call    fn12
    3d9: nop     [rcx-58h]
    3e0: mov     byte ptr [rbp-71h],1
    3e4: test    byte ptr [rbp-71h],0FFh
    3e8: je      44Eh
    3ea: mov     rax,[rbp-30h]
    3ee: mov     [rbp-60h],rax
    3f2: mov     rax,[rbp+18h]
    3f6: mov     [rbp-68h],rax
    3fa: mov     rax,[rbp-60h]
    3fe: mov     [rbp-0B0h],rax
    405: mov     rax,[rbp-68h]
    409: mov     [rbp-0A8h],rax
    410: mov     qword ptr [rbp-0A0h],8
    41b: mov     qword ptr [rbp-98h],4
    426: mov     qword ptr [rbp-90h],1
    431: mov     edi,0FFFFFF78h
    436: lea     rsi,[k13]
    43d: call    ryo_h_AddrAbs
    442: call    fn14
    447: nop     [rcx]
    44e: mov     qword ptr [rbp-78h],1
    456: imul    rax,[rbp-78h],8
    45b: mov     [rbp-80h],rax
    45f: mov     edi,18h
    464: mov     esi,0FFFFFFD0h
    469: mov     edx,0FFFFFF80h
    46e: call    ryo_h_Memcpy
    473: mov     qword ptr [rbp-78h],1
    47b: mov     rax,[rbp+18h]
    47f: imul    rcx,[rbp-78h],8
    484: add     rax,rcx
    487: mov     [rbp-60h],rax
    48b: mov     byte ptr [rbp-71h],1
    48f: test    byte ptr [rbp-71h],0FFh
    493: je      4F9h
    495: mov     rax,[rbp-50h]
    499: mov     [rbp-68h],rax
    49d: mov     rax,[rbp-60h]
    4a1: mov     [rbp-70h],rax
    4a5: mov     rax,[rbp-68h]
    4a9: mov     [rbp-0B0h],rax
    4b0: mov     rax,[rbp-70h]
    4b4: mov     [rbp-0A8h],rax
    4bb: mov     qword ptr [rbp-0A0h],8
    4c6: mov     qword ptr [rbp-98h],4
    4d1: mov     qword ptr [rbp-90h],1
    4dc: mov     edi,0FFFFFF78h
    4e1: lea     rsi,[k15]
    4e8: call    ryo_h_AddrAbs
    4ed: call    fn16
    4f2: nop     [rcx]
    4f9: mov     qword ptr [rbp-78h],1
    501: imul    rax,[rbp-78h],8
    506: mov     [rbp-80h],rax
    50a: mov     edi,0FFFFFFA0h
    50f: mov     esi,0FFFFFFB0h
    514: mov     edx,0FFFFFF80h
    519: call    ryo_h_Memcpy
    51e: mov     qword ptr [rbp-78h],2
    526: mov     rax,[rbp+18h]
    52a: imul    rcx,[rbp-78h],8
    52f: add     rax,rcx
    532: mov     [rbp-60h],rax
    536: mov     byte ptr [rbp-71h],1
    53a: test    byte ptr [rbp-71h],0FFh
    53e: je      5A4h
    540: mov     rax,[rbp-58h]
    544: mov     [rbp-68h],rax
    548: mov     rax,[rbp-60h]
    54c: mov     [rbp-70h],rax
    550: mov     rax,[rbp-68h]
    554: mov     [rbp-0B0h],rax
    55b: mov     rax,[rbp-70h]
    55f: mov     [rbp-0A8h],rax
    566: mov     qword ptr [rbp-0A0h],8
    571: mov     qword ptr [rbp-98h],4
    57c: mov     qword ptr [rbp-90h],1
    587: mov     edi,0FFFFFF78h
    58c: lea     rsi,[k17]
    593: call    ryo_h_AddrAbs
    598: call    fn18
    59d: nop     [rcx]
    5a4: mov     qword ptr [rbp-78h],1
    5ac: imul    rax,[rbp-78h],8
    5b1: mov     [rbp-80h],rax
    5b5: mov     edi,0FFFFFFA0h
    5ba: mov     esi,0FFFFFFA8h
    5bf: mov     edx,0FFFFFF80h
    5c4: call    ryo_h_Memcpy
    5c9: mov     qword ptr [rbp-78h],3
    5d1: mov     rax,[rbp+18h]
    5d5: imul    rcx,[rbp-78h],8
    5da: add     rax,rcx
    5dd: mov     [rbp-60h],rax
    5e1: mov     byte ptr [rbp-71h],1
    5e5: test    byte ptr [rbp-71h],0FFh
    5e9: je      64Fh
    5eb: mov     rax,[rbp-38h]
    5ef: mov     [rbp-68h],rax
    5f3: mov     rax,[rbp-60h]
    5f7: mov     [rbp-70h],rax
    5fb: mov     rax,[rbp-68h]
    5ff: mov     [rbp-0B0h],rax
    606: mov     rax,[rbp-70h]
    60a: mov     [rbp-0A8h],rax
    611: mov     qword ptr [rbp-0A0h],8
    61c: mov     qword ptr [rbp-98h],4
    627: mov     qword ptr [rbp-90h],1
    632: mov     edi,0FFFFFF78h
    637: lea     rsi,[k19]
    63e: call    ryo_h_AddrAbs
    643: call    fn20
    648: nop     [rcx]
    64f: mov     qword ptr [rbp-78h],1
    657: imul    rax,[rbp-78h],8
    65c: mov     [rbp-80h],rax
    660: mov     edi,0FFFFFFA0h
    665: mov     esi,0FFFFFFC8h
    66a: mov     edx,0FFFFFF80h
    66f: call    ryo_h_Memcpy
    674: xor     edi,edi
    676: xor     esi,esi
    678: call    ryo_h_Ret
    67d: leave
    67e: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rax,[rbp+10h]
     17: imul    rcx,[rbp-78h],4
     1c: add     rax,rcx
     1f: mov     [rbp-28h],rax
     23: mov     [rbp-20h],rax
     27: mov     rax,[rbp+10h]
     2b: mov     [rbp-30h],rax
     2f: mov     rax,[rbp-20h]
     33: mov     [rbp-18h],rax
     37: mov     rax,[rbp-30h]
     3b: mov     [rbp-10h],rax
     3f: mov     rax,[rbp+20h]
     43: mov     [rbp-0B0h],rax
     4a: mov     rax,[rbp-18h]
     4e: mov     [rbp-0A8h],rax
     55: mov     rax,[rbp-10h]
     59: mov     [rbp-0A0h],rax
     60: call    fn0
     65: nop     [rcx-1]
     6c: mov     qword ptr [rbp-78h],3
     74: mov     rax,[rbp+10h]
     78: imul    rcx,[rbp-78h],4
     7d: add     rax,rcx
     80: mov     [rbp-28h],rax
     84: mov     [rbp-20h],rax
     88: mov     qword ptr [rbp-78h],2
     90: mov     rax,[rbp+10h]
     94: imul    rcx,[rbp-78h],4
     99: add     rax,rcx
     9c: mov     [rbp-38h],rax
     a0: mov     [rbp-30h],rax
     a4: mov     rax,[rbp-20h]
     a8: mov     [rbp-18h],rax
     ac: mov     rax,[rbp-30h]
     b0: mov     [rbp-10h],rax
     b4: mov     rax,[rbp+20h]
     b8: mov     [rbp-0B0h],rax
     bf: mov     rax,[rbp-18h]
     c3: mov     [rbp-0A8h],rax
     ca: mov     rax,[rbp-10h]
     ce: mov     [rbp-0A0h],rax
     d5: call    fn1
     da: nop     [rcx-2]
     e1: mov     edi,0FFFFFFE8h
     e6: mov     esi,0FFFFFFFFh
     eb: call    ryo_h_ZextW8W64
     f0: mov     rax,[rbp+10h]
     f4: imul    rcx,[rbp-18h],4
     f9: add     rax,rcx
     fc: mov     [rbp-10h],rax
    100: movzx   eax,byte ptr [rbp-1]
    104: xor     al,1
    107: mov     [rbp-3],al
    10a: mov     edi,0FFFFFFE0h
    10f: mov     esi,0FFFFFFFDh
    114: call    ryo_h_ZextW8W64
    119: mov     rax,[rbp+10h]
    11d: imul    rcx,[rbp-20h],4
    122: add     rax,rcx
    125: mov     [rbp-18h],rax
    129: mov     edi,0FFFFFFD0h
    12e: mov     esi,0FFFFFFFEh
    133: call    ryo_h_ZextW8W64
    138: mov     qword ptr [rbp-78h],2
    140: mov     rax,[rbp-78h]
    144: add     rax,[rbp-30h]
    148: mov     [rbp-28h],rax
    14c: mov     rax,[rbp+10h]
    150: imul    rcx,[rbp-28h],4
    155: add     rax,rcx
    158: mov     [rbp-20h],rax
    15c: movzx   eax,byte ptr [rbp-2]
    160: xor     al,1
    163: mov     [rbp-3],al
    166: mov     edi,0FFFFFFC8h
    16b: mov     esi,0FFFFFFFDh
    170: call    ryo_h_ZextW8W64
    175: mov     qword ptr [rbp-78h],2
    17d: mov     rax,[rbp-78h]
    181: add     rax,[rbp-38h]
    185: mov     [rbp-30h],rax
    189: mov     rax,[rbp+10h]
    18d: imul    rcx,[rbp-30h],4
    192: add     rax,rcx
    195: mov     [rbp-28h],rax
    199: mov     rax,[rbp-20h]
    19d: mov     [rbp-40h],rax
    1a1: mov     rax,[rbp-10h]
    1a5: mov     [rbp-48h],rax
    1a9: mov     rax,[rbp-40h]
    1ad: mov     [rbp-38h],rax
    1b1: mov     rax,[rbp-48h]
    1b5: mov     [rbp-30h],rax
    1b9: mov     rax,[rbp+20h]
    1bd: mov     [rbp-0B0h],rax
    1c4: mov     rax,[rbp-38h]
    1c8: mov     [rbp-0A8h],rax
    1cf: mov     rax,[rbp-30h]
    1d3: mov     [rbp-0A0h],rax
    1da: call    fn2
    1df: nop     [rcx-3]
    1e6: mov     rax,[rbp-28h]
    1ea: mov     [rbp-40h],rax
    1ee: mov     rax,[rbp-18h]
    1f2: mov     [rbp-48h],rax
    1f6: mov     rax,[rbp-40h]
    1fa: mov     [rbp-38h],rax
    1fe: mov     rax,[rbp-48h]
    202: mov     [rbp-30h],rax
    206: mov     rax,[rbp+20h]
    20a: mov     [rbp-0B0h],rax
    211: mov     rax,[rbp-38h]
    215: mov     [rbp-0A8h],rax
    21c: mov     rax,[rbp-30h]
    220: mov     [rbp-0A0h],rax
    227: call    fn3
    22c: nop     [rcx-4]
    233: movzx   eax,byte ptr [rbp-3]
    237: mov     [rbp-0A8h],al
    23d: mov     rax,[rbp-20h]
    241: mov     [rbp-0B0h],rax
    248: mov     rax,[rbp-10h]
    24c: mov     [rbp-0A0h],rax
    253: call    fn4
    258: nop     [rcx-30h]
    25f: movzx   eax,byte ptr [rbp-4]
    263: mov     [rbp-0A8h],al
    269: mov     rax,[rbp-18h]
    26d: mov     [rbp-0B0h],rax
    274: mov     rax,[rbp-28h]
    278: mov     [rbp-0A0h],rax
    27f: call    fn5
    284: nop     [rcx-38h]
    28b: movzx   eax,byte ptr [rbp-4]
    28f: mov     [rbp-0A8h],al
    295: mov     rax,[rbp-20h]
    299: mov     [rbp-0B0h],rax
    2a0: mov     rax,[rbp-18h]
    2a4: mov     [rbp-0A0h],rax
    2ab: call    fn6
    2b0: nop     [rcx-48h]
    2b7: movzx   eax,byte ptr [rbp-3]
    2bb: mov     [rbp-0A8h],al
    2c1: mov     rax,[rbp-10h]
    2c5: mov     [rbp-0B0h],rax
    2cc: mov     rax,[rbp-48h]
    2d0: mov     [rbp-0A0h],rax
    2d7: call    fn7
    2dc: nop     [rcx-40h]
    2e3: movzx   eax,byte ptr [rbp-3]
    2e7: mov     [rbp-0A8h],al
    2ed: mov     rax,[rbp-18h]
    2f1: mov     [rbp-0B0h],rax
    2f8: mov     rax,[rbp-20h]
    2fc: mov     [rbp-0A0h],rax
    303: call    fn8
    308: nop     [rcx-50h]
    30f: movzx   eax,byte ptr [rbp-4]
    313: mov     [rbp-0A8h],al
    319: mov     rax,[rbp-28h]
    31d: mov     [rbp-0B0h],rax
    324: mov     rax,[rbp-50h]
    328: mov     [rbp-0A0h],rax
    32f: call    fn9
    334: nop     [rcx-48h]
    33b: mov     rax,[rbp-48h]
    33f: mov     [rbp-60h],rax
    343: mov     rax,[rbp-40h]
    347: mov     [rbp-68h],rax
    34b: mov     rax,[rbp-60h]
    34f: mov     [rbp-58h],rax
    353: mov     rax,[rbp-68h]
    357: mov     [rbp-50h],rax
    35b: mov     rax,[rbp+20h]
    35f: mov     [rbp-0B0h],rax
    366: mov     rax,[rbp-58h]
    36a: mov     [rbp-0A8h],rax
    371: mov     rax,[rbp-50h]
    375: mov     [rbp-0A0h],rax
    37c: call    fn10
    381: nop     [rcx-5]
    388: movzx   eax,byte ptr [rbp-5]
    38c: mov     [rbp-0A8h],al
    392: mov     rax,[rbp-48h]
    396: mov     [rbp-0B0h],rax
    39d: mov     rax,[rbp-40h]
    3a1: mov     [rbp-0A0h],rax
    3a8: call    fn11
    3ad: nop     [rcx-50h]
    3b4: movzx   eax,byte ptr [rbp-5]
    3b8: mov     [rbp-0A8h],al
    3be: mov     rax,[rbp-40h]
    3c2: mov     [rbp-0B0h],rax
    3c9: mov     rax,[rbp-48h]
    3cd: mov     [rbp-0A0h],rax
    3d4: call    fn12
    3d9: nop     [rcx-58h]
    3e0: mov     byte ptr [rbp-71h],1
    3e4: test    byte ptr [rbp-71h],0FFh
    3e8: je      44Eh
    3ea: mov     rax,[rbp-30h]
    3ee: mov     [rbp-60h],rax
    3f2: mov     rax,[rbp+18h]
    3f6: mov     [rbp-68h],rax
    3fa: mov     rax,[rbp-60h]
    3fe: mov     [rbp-0B0h],rax
    405: mov     rax,[rbp-68h]
    409: mov     [rbp-0A8h],rax
    410: mov     qword ptr [rbp-0A0h],4
    41b: mov     qword ptr [rbp-98h],4
    426: mov     qword ptr [rbp-90h],1
    431: mov     edi,0FFFFFF78h
    436: lea     rsi,[k13]
    43d: call    ryo_h_AddrAbs
    442: call    fn14
    447: nop     [rcx]
    44e: mov     qword ptr [rbp-78h],1
    456: imul    rax,[rbp-78h],4
    45b: mov     [rbp-80h],rax
    45f: mov     edi,18h
    464: mov     esi,0FFFFFFD0h
    469: mov     edx,0FFFFFF80h
    46e: call    ryo_h_Memcpy
    473: mov     qword ptr [rbp-78h],1
    47b: mov     rax,[rbp+18h]
    47f: imul    rcx,[rbp-78h],4
    484: add     rax,rcx
    487: mov     [rbp-60h],rax
    48b: mov     byte ptr [rbp-71h],1
    48f: test    byte ptr [rbp-71h],0FFh
    493: je      4F9h
    495: mov     rax,[rbp-50h]
    499: mov     [rbp-68h],rax
    49d: mov     rax,[rbp-60h]
    4a1: mov     [rbp-70h],rax
    4a5: mov     rax,[rbp-68h]
    4a9: mov     [rbp-0B0h],rax
    4b0: mov     rax,[rbp-70h]
    4b4: mov     [rbp-0A8h],rax
    4bb: mov     qword ptr [rbp-0A0h],4
    4c6: mov     qword ptr [rbp-98h],4
    4d1: mov     qword ptr [rbp-90h],1
    4dc: mov     edi,0FFFFFF78h
    4e1: lea     rsi,[k15]
    4e8: call    ryo_h_AddrAbs
    4ed: call    fn16
    4f2: nop     [rcx]
    4f9: mov     qword ptr [rbp-78h],1
    501: imul    rax,[rbp-78h],4
    506: mov     [rbp-80h],rax
    50a: mov     edi,0FFFFFFA0h
    50f: mov     esi,0FFFFFFB0h
    514: mov     edx,0FFFFFF80h
    519: call    ryo_h_Memcpy
    51e: mov     qword ptr [rbp-78h],2
    526: mov     rax,[rbp+18h]
    52a: imul    rcx,[rbp-78h],4
    52f: add     rax,rcx
    532: mov     [rbp-60h],rax
    536: mov     byte ptr [rbp-71h],1
    53a: test    byte ptr [rbp-71h],0FFh
    53e: je      5A4h
    540: mov     rax,[rbp-58h]
    544: mov     [rbp-68h],rax
    548: mov     rax,[rbp-60h]
    54c: mov     [rbp-70h],rax
    550: mov     rax,[rbp-68h]
    554: mov     [rbp-0B0h],rax
    55b: mov     rax,[rbp-70h]
    55f: mov     [rbp-0A8h],rax
    566: mov     qword ptr [rbp-0A0h],4
    571: mov     qword ptr [rbp-98h],4
    57c: mov     qword ptr [rbp-90h],1
    587: mov     edi,0FFFFFF78h
    58c: lea     rsi,[k17]
    593: call    ryo_h_AddrAbs
    598: call    fn18
    59d: nop     [rcx]
    5a4: mov     qword ptr [rbp-78h],1
    5ac: imul    rax,[rbp-78h],4
    5b1: mov     [rbp-80h],rax
    5b5: mov     edi,0FFFFFFA0h
    5ba: mov     esi,0FFFFFFA8h
    5bf: mov     edx,0FFFFFF80h
    5c4: call    ryo_h_Memcpy
    5c9: mov     qword ptr [rbp-78h],3
    5d1: mov     rax,[rbp+18h]
    5d5: imul    rcx,[rbp-78h],4
    5da: add     rax,rcx
    5dd: mov     [rbp-60h],rax
    5e1: mov     byte ptr [rbp-71h],1
    5e5: test    byte ptr [rbp-71h],0FFh
    5e9: je      64Fh
    5eb: mov     rax,[rbp-38h]
    5ef: mov     [rbp-68h],rax
    5f3: mov     rax,[rbp-60h]
    5f7: mov     [rbp-70h],rax
    5fb: mov     rax,[rbp-68h]
    5ff: mov     [rbp-0B0h],rax
    606: mov     rax,[rbp-70h]
    60a: mov     [rbp-0A8h],rax
    611: mov     qword ptr [rbp-0A0h],4
    61c: mov     qword ptr [rbp-98h],4
    627: mov     qword ptr [rbp-90h],1
    632: mov     edi,0FFFFFF78h
    637: lea     rsi,[k19]
    63e: call    ryo_h_AddrAbs
    643: call    fn20
    648: nop     [rcx]
    64f: mov     qword ptr [rbp-78h],1
    657: imul    rax,[rbp-78h],4
    65c: mov     [rbp-80h],rax
    660: mov     edi,0FFFFFFA0h
    665: mov     esi,0FFFFFFC8h
    66a: mov     edx,0FFFFFF80h
    66f: call    ryo_h_Memcpy
    674: xor     edi,edi
    676: xor     esi,esi
    678: call    ryo_h_Ret
    67d: leave
    67e: ret

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-60h],rax
     14: mov     rax,[rbp+20h]
     18: mov     [rbp-58h],rax
     1c: mov     rax,[rbp+28h]
     20: mov     [rbp-50h],rax
     24: call    fn0
     29: nop     [rcx]
     30: mov     qword ptr [rbp-30h],4
     38: mov     rax,[rbp+10h]
     3c: imul    rcx,[rbp-30h],8
     41: add     rax,rcx
     44: mov     [rbp-10h],rax
     48: mov     [rbp-8],rax
     4c: mov     qword ptr [rbp-30h],4
     54: mov     rax,[rbp+20h]
     58: imul    rcx,[rbp-30h],8
     5d: add     rax,rcx
     60: mov     [rbp-10h],rax
     64: mov     rax,[rbp-8]
     68: mov     [rbp-60h],rax
     6c: mov     rax,[rbp-10h]
     70: mov     [rbp-58h],rax
     74: mov     rax,[rbp+28h]
     78: mov     [rbp-50h],rax
     7c: call    fn1
     81: nop     [rcx]
     88: mov     rax,[rbp+20h]
     8c: mov     [rbp-18h],rax
     90: mov     byte ptr [rbp-29h],1
     94: test    byte ptr [rbp-29h],0FFh
     98: je      0ECh
     9a: jmp     0ABh
     9c: nop     [rax]
     a0: xor     edi,edi
     a2: xor     esi,esi
     a4: call    ryo_h_Ret
     a9: leave
     aa: ret
     ab: mov     rax,[rbp+20h]
     af: mov     [rbp-20h],rax
     b3: mov     [rbp-60h],rax
     b7: mov     qword ptr [rbp-58h],8
     bf: mov     qword ptr [rbp-50h],4
     c7: mov     qword ptr [rbp-48h],8
     cf: mov     edi,0FFFFFFC0h
     d4: lea     rsi,[k2]
     db: call    ryo_h_AddrAbs
     e0: call    fn3
     e5: nop     [rcx]
     ec: mov     rax,[rbp-18h]
     f0: mov     [rbp-28h],rax
     f4: mov     qword ptr [rbp-20h],8
     fc: mov     [rbp-10h],rax
    100: mov     rax,[rbp-20h]
    104: mov     [rbp-8],rax
    108: mov     edi,0FFFFFFA0h
    10d: mov     esi,0FFFFFFF0h
    112: call    ryo_h_MovW128
    117: mov     rax,[rbp+18h]
    11b: mov     [rbp-50h],rax
    11f: mov     rax,[rbp+28h]
    123: mov     [rbp-48h],rax
    127: call    fn4
    12c: nop     [rcx]
    133: jmp     0A0h

fn core::slice::sort::shared::smallsort::sort8_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-60h],rax
     14: mov     rax,[rbp+20h]
     18: mov     [rbp-58h],rax
     1c: mov     rax,[rbp+28h]
     20: mov     [rbp-50h],rax
     24: call    fn0
     29: nop     [rcx]
     30: mov     qword ptr [rbp-30h],4
     38: mov     rax,[rbp+10h]
     3c: imul    rcx,[rbp-30h],4
     41: add     rax,rcx
     44: mov     [rbp-10h],rax
     48: mov     [rbp-8],rax
     4c: mov     qword ptr [rbp-30h],4
     54: mov     rax,[rbp+20h]
     58: imul    rcx,[rbp-30h],4
     5d: add     rax,rcx
     60: mov     [rbp-10h],rax
     64: mov     rax,[rbp-8]
     68: mov     [rbp-60h],rax
     6c: mov     rax,[rbp-10h]
     70: mov     [rbp-58h],rax
     74: mov     rax,[rbp+28h]
     78: mov     [rbp-50h],rax
     7c: call    fn1
     81: nop     [rcx]
     88: mov     rax,[rbp+20h]
     8c: mov     [rbp-18h],rax
     90: mov     byte ptr [rbp-29h],1
     94: test    byte ptr [rbp-29h],0FFh
     98: je      0ECh
     9a: jmp     0ABh
     9c: nop     [rax]
     a0: xor     edi,edi
     a2: xor     esi,esi
     a4: call    ryo_h_Ret
     a9: leave
     aa: ret
     ab: mov     rax,[rbp+20h]
     af: mov     [rbp-20h],rax
     b3: mov     [rbp-60h],rax
     b7: mov     qword ptr [rbp-58h],4
     bf: mov     qword ptr [rbp-50h],4
     c7: mov     qword ptr [rbp-48h],8
     cf: mov     edi,0FFFFFFC0h
     d4: lea     rsi,[k2]
     db: call    ryo_h_AddrAbs
     e0: call    fn3
     e5: nop     [rcx]
     ec: mov     rax,[rbp-18h]
     f0: mov     [rbp-28h],rax
     f4: mov     qword ptr [rbp-20h],8
     fc: mov     [rbp-10h],rax
    100: mov     rax,[rbp-20h]
    104: mov     [rbp-8],rax
    108: mov     edi,0FFFFFFA0h
    10d: mov     esi,0FFFFFFF0h
    112: call    ryo_h_MovW128
    117: mov     rax,[rbp+18h]
    11b: mov     [rbp-50h],rax
    11f: mov     rax,[rbp+28h]
    123: mov     [rbp-48h],rax
    127: call    fn4
    12c: nop     [rcx]
    133: jmp     0A0h

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     rax,9
     14: jae     1Dh
     16: call    ryo_h_Abort
     1b: ud2
     1d: mov     rax,[rbp+10h]
     21: mov     [rbp-18h],rax
     25: mov     rax,[rbp+18h]
     29: mov     [rbp-10h],rax
     2d: mov     rax,[rbp-18h]
     31: mov     [rbp-8],rax
     35: mov     [rbp-40h],rax
     39: mov     qword ptr [rbp-38h],0
     41: mov     qword ptr [rbp-30h],3
     49: mov     rax,[rbp+20h]
     4d: mov     [rbp-28h],rax
     51: call    fn0
     56: nop     [rcx]
     5d: mov     rax,[rbp-8]
     61: mov     [rbp-40h],rax
     65: mov     qword ptr [rbp-38h],1
     6d: mov     qword ptr [rbp-30h],7
     75: mov     rax,[rbp+20h]
     79: mov     [rbp-28h],rax
     7d: call    fn1
     82: nop     [rcx]
     89: mov     rax,[rbp-8]
     8d: mov     [rbp-40h],rax
     91: mov     qword ptr [rbp-38h],2
     99: mov     qword ptr [rbp-30h],5
     a1: mov     rax,[rbp+20h]
     a5: mov     [rbp-28h],rax
     a9: call    fn2
     ae: nop     [rcx]
     b5: mov     rax,[rbp-8]
     b9: mov     [rbp-40h],rax
     bd: mov     qword ptr [rbp-38h],4
     c5: mov     qword ptr [rbp-30h],8
     cd: mov     rax,[rbp+20h]
     d1: mov     [rbp-28h],rax
     d5: call    fn3
     da: nop     [rcx]
     e1: mov     rax,[rbp-8]
     e5: mov     [rbp-40h],rax
     e9: mov     qword ptr [rbp-38h],0
     f1: mov     qword ptr [rbp-30h],7
     f9: mov     rax,[rbp+20h]
     fd: mov     [rbp-28h],rax
    101: call    fn4
    106: nop     [rcx]
    10d: mov     rax,[rbp-8]
    111: mov     [rbp-40h],rax
    115: mov     qword ptr [rbp-38h],2
    11d: mov     qword ptr [rbp-30h],4
    125: mov     rax,[rbp+20h]
    129: mov     [rbp-28h],rax
    12d: call    fn5
    132: nop     [rcx]
    139: mov     rax,[rbp-8]
    13d: mov     [rbp-40h],rax
    141: mov     qword ptr [rbp-38h],3
    149: mov     qword ptr [rbp-30h],8
    151: mov     rax,[rbp+20h]
    155: mov     [rbp-28h],rax
    159: call    fn6
    15e: nop     [rcx]
    165: mov     rax,[rbp-8]
    169: mov     [rbp-40h],rax
    16d: mov     qword ptr [rbp-38h],5
    175: mov     qword ptr [rbp-30h],6
    17d: mov     rax,[rbp+20h]
    181: mov     [rbp-28h],rax
    185: call    fn7
    18a: nop     [rcx]
    191: mov     rax,[rbp-8]
    195: mov     [rbp-40h],rax
    199: mov     qword ptr [rbp-38h],0
    1a1: mov     qword ptr [rbp-30h],2
    1a9: mov     rax,[rbp+20h]
    1ad: mov     [rbp-28h],rax
    1b1: call    fn8
    1b6: nop     [rcx]
    1bd: mov     rax,[rbp-8]
    1c1: mov     [rbp-40h],rax
    1c5: mov     qword ptr [rbp-38h],1
    1cd: mov     qword ptr [rbp-30h],3
    1d5: mov     rax,[rbp+20h]
    1d9: mov     [rbp-28h],rax
    1dd: call    fn9
    1e2: nop     [rcx]
    1e9: mov     rax,[rbp-8]
    1ed: mov     [rbp-40h],rax
    1f1: mov     qword ptr [rbp-38h],4
    1f9: mov     qword ptr [rbp-30h],5
    201: mov     rax,[rbp+20h]
    205: mov     [rbp-28h],rax
    209: call    fn10
    20e: nop     [rcx]
    215: mov     rax,[rbp-8]
    219: mov     [rbp-40h],rax
    21d: mov     qword ptr [rbp-38h],7
    225: mov     qword ptr [rbp-30h],8
    22d: mov     rax,[rbp+20h]
    231: mov     [rbp-28h],rax
    235: call    fn11
    23a: nop     [rcx]
    241: mov     rax,[rbp-8]
    245: mov     [rbp-40h],rax
    249: mov     qword ptr [rbp-38h],1
    251: mov     qword ptr [rbp-30h],4
    259: mov     rax,[rbp+20h]
    25d: mov     [rbp-28h],rax
    261: call    fn12
    266: nop     [rcx]
    26d: mov     rax,[rbp-8]
    271: mov     [rbp-40h],rax
    275: mov     qword ptr [rbp-38h],3
    27d: mov     qword ptr [rbp-30h],6
    285: mov     rax,[rbp+20h]
    289: mov     [rbp-28h],rax
    28d: call    fn13
    292: nop     [rcx]
    299: mov     rax,[rbp-8]
    29d: mov     [rbp-40h],rax
    2a1: mov     qword ptr [rbp-38h],5
    2a9: mov     qword ptr [rbp-30h],7
    2b1: mov     rax,[rbp+20h]
    2b5: mov     [rbp-28h],rax
    2b9: call    fn14
    2be: nop     [rcx]
    2c5: mov     rax,[rbp-8]
    2c9: mov     [rbp-40h],rax
    2cd: mov     qword ptr [rbp-38h],0
    2d5: mov     qword ptr [rbp-30h],1
    2dd: mov     rax,[rbp+20h]
    2e1: mov     [rbp-28h],rax
    2e5: call    fn15
    2ea: nop     [rcx]
    2f1: mov     rax,[rbp-8]
    2f5: mov     [rbp-40h],rax
    2f9: mov     qword ptr [rbp-38h],2
    301: mov     qword ptr [rbp-30h],4
    309: mov     rax,[rbp+20h]
    30d: mov     [rbp-28h],rax
    311: call    fn16
    316: nop     [rcx]
    31d: mov     rax,[rbp-8]
    321: mov     [rbp-40h],rax
    325: mov     qword ptr [rbp-38h],3
    32d: mov     qword ptr [rbp-30h],5
    335: mov     rax,[rbp+20h]
    339: mov     [rbp-28h],rax
    33d: call    fn17
    342: nop     [rcx]
    349: mov     rax,[rbp-8]
    34d: mov     [rbp-40h],rax
    351: mov     qword ptr [rbp-38h],6
    359: mov     qword ptr [rbp-30h],8
    361: mov     rax,[rbp+20h]
    365: mov     [rbp-28h],rax
    369: call    fn18
    36e: nop     [rcx]
    375: mov     rax,[rbp-8]
    379: mov     [rbp-40h],rax
    37d: mov     qword ptr [rbp-38h],2
    385: mov     qword ptr [rbp-30h],3
    38d: mov     rax,[rbp+20h]
    391: mov     [rbp-28h],rax
    395: call    fn19
    39a: nop     [rcx]
    3a1: mov     rax,[rbp-8]
    3a5: mov     [rbp-40h],rax
    3a9: mov     qword ptr [rbp-38h],4
    3b1: mov     qword ptr [rbp-30h],5
    3b9: mov     rax,[rbp+20h]
    3bd: mov     [rbp-28h],rax
    3c1: call    fn20
    3c6: nop     [rcx]
    3cd: mov     rax,[rbp-8]
    3d1: mov     [rbp-40h],rax
    3d5: mov     qword ptr [rbp-38h],6
    3dd: mov     qword ptr [rbp-30h],7
    3e5: mov     rax,[rbp+20h]
    3e9: mov     [rbp-28h],rax
    3ed: call    fn21
    3f2: nop     [rcx]
    3f9: mov     rax,[rbp-8]
    3fd: mov     [rbp-40h],rax
    401: mov     qword ptr [rbp-38h],1
    409: mov     qword ptr [rbp-30h],2
    411: mov     rax,[rbp+20h]
    415: mov     [rbp-28h],rax
    419: call    fn22
    41e: nop     [rcx]
    425: mov     rax,[rbp-8]
    429: mov     [rbp-40h],rax
    42d: mov     qword ptr [rbp-38h],3
    435: mov     qword ptr [rbp-30h],4
    43d: mov     rax,[rbp+20h]
    441: mov     [rbp-28h],rax
    445: call    fn23
    44a: nop     [rcx]
    451: mov     rax,[rbp-8]
    455: mov     [rbp-40h],rax
    459: mov     qword ptr [rbp-38h],5
    461: mov     qword ptr [rbp-30h],6
    469: mov     rax,[rbp+20h]
    46d: mov     [rbp-28h],rax
    471: call    fn24
    476: nop     [rcx]
    47d: xor     edi,edi
    47f: xor     esi,esi
    481: call    ryo_h_Ret
    486: leave
    487: ret

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: imul    rcx,[rbp+18h],4
     14: add     rax,rcx
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp+10h]
     1f: imul    rcx,[rbp+20h],4
     24: add     rax,rcx
     27: mov     [rbp-18h],rax
     2b: mov     [rbp-38h],rax
     2f: mov     rax,[rbp-10h]
     33: mov     [rbp-40h],rax
     37: mov     rax,[rbp-38h]
     3b: mov     [rbp-30h],rax
     3f: mov     rax,[rbp-40h]
     43: mov     [rbp-28h],rax
     47: mov     rax,[rbp+28h]
     4b: mov     [rbp-90h],rax
     52: mov     rax,[rbp-30h]
     56: mov     [rbp-88h],rax
     5d: mov     rax,[rbp-28h]
     61: mov     [rbp-80h],rax
     65: call    fn0
     6a: nop     [rcx-19h]
     71: movzx   eax,byte ptr [rbp-19h]
     75: mov     [rbp-88h],al
     7b: mov     rax,[rbp-18h]
     7f: mov     [rbp-90h],rax
     86: mov     rax,[rbp-10h]
     8a: mov     [rbp-80h],rax
     8e: call    fn1
     93: nop     [rcx-28h]
     9a: movzx   eax,byte ptr [rbp-19h]
     9e: mov     [rbp-88h],al
     a4: mov     rax,[rbp-10h]
     a8: mov     [rbp-90h],rax
     af: mov     rax,[rbp-18h]
     b3: mov     [rbp-80h],rax
     b7: call    fn2
     bc: nop     [rcx-30h]
     c3: mov     rax,[rbp-30h]
     c7: mov     [rbp-40h],rax
     cb: mov     eax,[rax]
     cd: mov     [rbp-34h],eax
     d0: mov     [rbp-38h],eax
     d3: mov     [rbp-20h],eax
     d6: mov     rax,[rbp-28h]
     da: mov     [rbp-38h],rax
     de: mov     byte ptr [rbp-49h],1
     e2: test    byte ptr [rbp-49h],0FFh
     e6: je      171h
     ec: jmp     10Bh
     ee: xchg    ax,ax
     f0: lea     rax,[rbp-20h]
     f4: mov     [rbp-38h],rax
     f8: mov     byte ptr [rbp-49h],1
     fc: test    byte ptr [rbp-49h],0FFh
    100: je      1F6h
    106: jmp     19Bh
    10b: mov     rax,[rbp-28h]
    10f: mov     [rbp-40h],rax
    113: mov     rax,[rbp-10h]
    117: mov     [rbp-48h],rax
    11b: mov     byte ptr [rbp-49h],0
    11f: test    byte ptr [rbp-49h],0FFh
    123: je      12Bh
    125: mov     byte ptr [rbp-1Ah],1
    129: jmp     12Fh
    12b: mov     byte ptr [rbp-1Ah],0
    12f: mov     rax,[rbp-40h]
    133: mov     [rbp-90h],rax
    13a: mov     rax,[rbp-48h]
    13e: mov     [rbp-88h],rax
    145: mov     qword ptr [rbp-80h],4
    14d: movzx   eax,byte ptr [rbp-1Ah]
    151: mov     [rbp-78h],al
    154: mov     edi,0FFFFFF90h
    159: lea     rsi,[k3]
    160: call    ryo_h_AddrAbs
    165: call    fn4
    16a: nop     [rcx-8]
    171: mov     qword ptr [rbp-50h],1
    179: imul    rax,[rbp-50h],4
    17e: mov     [rbp-58h],rax
    182: mov     edi,0FFFFFFF0h
    187: mov     esi,0FFFFFFC8h
    18c: mov     edx,0FFFFFFA8h
    191: call    ryo_h_Memmove
    196: jmp     0F0h
    19b: mov     rax,[rbp-38h]
    19f: mov     [rbp-40h],rax
    1a3: mov     rax,[rbp-18h]
    1a7: mov     [rbp-48h],rax
    1ab: mov     rax,[rbp-40h]
    1af: mov     [rbp-90h],rax
    1b6: mov     rax,[rbp-48h]
    1ba: mov     [rbp-88h],rax
    1c1: mov     qword ptr [rbp-80h],4
    1c9: mov     qword ptr [rbp-78h],4
    1d1: mov     qword ptr [rbp-70h],1
    1d9: mov     edi,0FFFFFF98h
    1de: lea     rsi,[k5]
    1e5: call    ryo_h_AddrAbs
    1ea: call    fn6
    1ef: nop     [rcx-8]
    1f6: mov     qword ptr [rbp-50h],1
    1fe: imul    rax,[rbp-50h],4
    203: mov     [rbp-58h],rax
    207: mov     edi,0FFFFFFE8h
    20c: mov     esi,0FFFFFFC8h
    211: mov     edx,0FFFFFFA8h
    216: call    ryo_h_Memcpy
    21b: xor     edi,edi
    21d: xor     esi,esi
    21f: call    ryo_h_Ret
    224: leave
    225: ret

fn core::slice::sort::stable::AlignedStorage::<(u32, u32), 4096>::as_uninit_slice_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     qword ptr [rbp-60h],8
     13: cmp     qword ptr [rbp-60h],0
     18: sete    [rbp-11h]
     1c: test    byte ptr [rbp-11h],0FFh
     20: je      72h
     22: mov     edi,0FFFFFF70h
     27: lea     rsi,[k0]
     2e: call    ryo_h_AddrAbs
     33: lea     rdi,[sym1]
     3a: lea     rsi,[site2]
     41: mov     edx,0FFFFFFA0h
     46: call    ryo_h_CallExt
     4b: test    rax,rax
     4e: je      5Bh
     50: call    rax
     52: nop     [rcx-58h]
     59: jmp     6Bh
     5b: mov     rdi,rbp
     5e: lea     rsi,[ro+4]
     65: call    qword ptr [sym3]
     6b: call    ryo_h_Unreachable
     70: ud2
     72: mov     qword ptr [rbp-60h],1000h
     7a: mov     qword ptr [rbp-68h],8
     82: mov     edi,0FFFFFFD0h
     87: mov     esi,0FFFFFFA0h
     8c: mov     edx,0FFFFFF98h
     91: call    ryo_h_DivUW64
     96: mov     rax,[rbp+10h]
     9a: mov     [rbp-58h],rax
     9e: mov     [rbp-50h],rax
     a2: mov     qword ptr [rbp-48h],1000h
     aa: mov     [rbp-28h],rax
     ae: mov     rax,[rbp-48h]
     b2: mov     [rbp-20h],rax
     b6: mov     rax,[rbp-28h]
     ba: mov     [rbp-40h],rax
     be: mov     rax,[rbp-28h]
     c2: mov     [rbp-38h],rax
     c6: mov     byte ptr [rbp-59h],1
     ca: test    byte ptr [rbp-59h],0FFh
     ce: je      117h
     d0: mov     rax,[rbp-28h]
     d4: mov     [rbp-40h],rax
     d8: mov     [rbp-90h],rax
     df: mov     qword ptr [rbp-88h],8
     ea: mov     qword ptr [rbp-80h],4
     f2: mov     rax,[rbp-30h]
     f6: mov     [rbp-78h],rax
     fa: mov     edi,0FFFFFF90h
     ff: lea     rsi,[k4]
    106: call    ryo_h_AddrAbs
    10b: call    fn5
    110: nop     [rcx-28h]
    117: mov     rax,[rbp-38h]
    11b: mov     [rbp-48h],rax
    11f: mov     rax,[rbp-30h]
    123: mov     [rbp-40h],rax
    127: mov     rax,[rbp-48h]
    12b: mov     [rbp-10h],rax
    12f: mov     rax,[rbp-40h]
    133: mov     [rbp-8],rax
    137: mov     edi,0FFFFFFF0h
    13c: mov     esi,10h
    141: call    ryo_h_Ret
    146: leave
    147: ret

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-18h],rax
     13: cmp     rax,[rbp+30h]
     17: jb      0ADh
     1d: mov     rax,[rbp+10h]
     21: mov     [rbp-40h],rax
     25: mov     rax,[rbp+18h]
     29: mov     [rbp-38h],rax
     2d: mov     edi,0FFFFFF60h
     32: mov     esi,0FFFFFFC0h
     37: call    ryo_h_MovW128
     3c: mov     rax,[rbp+40h]
     40: mov     [rbp-90h],rax
     47: call    fn0
     4c: nop     [rcx-30h]
     53: mov     rax,[rbp-30h]
     57: mov     [rbp-20h],rax
     5b: movzx   eax,byte ptr [rbp-28h]
     5f: mov     [rbp-0Bh],al
     62: mov     rax,[rbp-20h]
     66: cmp     rax,[rbp-18h]
     6a: setbe   [rbp-9]
     6e: cmp     rax,[rbp+30h]
     72: jb      0ADh
     74: test    byte ptr [rbp-0Bh],0FFh
     78: je      90h
     7a: cmp     rax,0
     7e: jb      151h
     84: jmp     1C2h
     89: nop     [rax]
     90: mov     rax,[rbp-20h]
     94: shl     rax,1
     98: mov     [rbp-30h],rax
     9c: or      rax,1
     a0: mov     [rbp-28h],rax
     a4: mov     [rbp-8],rax
     a8: jmp     140h
     ad: test    byte ptr [rbp+38h],0FFh
     b1: je      10Ah
     b3: call    fn1
     b8: nop     [rcx-28h]
     bf: mov     rax,[rbp-28h]
     c3: mov     [rbp-0A0h],rax
     ca: mov     rax,[rbp-18h]
     ce: mov     [rbp-98h],rax
     d5: call    fn2
     da: nop     [rcx-20h]
     e1: jmp     216h
     e6: nop     [rax+rax]
     ef: nop
     f0: mov     rax,[rbp-20h]
     f4: shl     rax,1
     f8: mov     [rbp-30h],rax
     fc: or      rax,1
    100: mov     [rbp-28h],rax
    104: mov     [rbp-8],rax
    108: jmp     140h
    10a: mov     rax,[rbp+30h]
    10e: mov     [rbp-0A0h],rax
    115: mov     rax,[rbp-18h]
    119: mov     [rbp-98h],rax
    120: call    fn3
    125: nop     [rcx-20h]
    12c: jmp     336h
    131: nop     [rax+rax]
    13a: nop     [rax+rax]
    140: mov     edi,0FFFFFFF8h
    145: mov     esi,8
    14a: call    ryo_h_Ret
    14f: leave
    150: ret
    151: mov     qword ptr [rbp-0A0h],0
    15c: mov     rax,[rbp-20h]
    160: mov     [rbp-98h],rax
    167: mov     rax,[rbp-18h]
    16b: mov     [rbp-90h],rax
    172: mov     edi,0FFFFFF78h
    177: lea     rsi,[k4]
    17e: call    ryo_h_AddrAbs
    183: lea     rdi,[sym5]
    18a: lea     rsi,[site6]
    191: mov     edx,0FFFFFFA0h
    196: call    ryo_h_CallExt
    19b: test    rax,rax
    19e: je      1ABh
    1a0: call    rax
    1a2: nop     [rcx-9]
    1a9: jmp     1BBh
    1ab: mov     rdi,rbp
    1ae: lea     rsi,[ro+4]
    1b5: call    qword ptr [sym7]
    1bb: call    ryo_h_Unreachable
    1c0: ud2
    1c2: mov     rax,[rbp+10h]
    1c6: mov     [rbp-50h],rax
    1ca: mov     rax,[rbp+18h]
    1ce: mov     [rbp-48h],rax
    1d2: mov     rax,[rbp-50h]
    1d6: mov     [rbp-58h],rax
    1da: mov     [rbp-40h],rax
    1de: mov     rax,[rbp-20h]
    1e2: mov     [rbp-38h],rax
    1e6: mov     rax,[rbp-40h]
    1ea: mov     [rbp-30h],rax
    1ee: mov     rax,[rbp-38h]
    1f2: mov     [rbp-28h],rax
    1f6: mov     edi,0FFFFFF60h
    1fb: mov     esi,0FFFFFFD0h
    200: call    ryo_h_MovW128
    205: call    fn8
    20a: nop     [rcx-9]
    211: jmp     90h
    216: cmp     qword ptr [rbp-20h],0
    21b: jb      321h
    221: jmp     323h
    226: nop     [rax+rax]
    22f: nop
    230: mov     rax,[rbp+10h]
    234: mov     [rbp-50h],rax
    238: mov     rax,[rbp+18h]
    23c: mov     [rbp-48h],rax
    240: mov     rax,[rbp-50h]
    244: mov     [rbp-58h],rax
    248: mov     [rbp-40h],rax
    24c: mov     rax,[rbp-20h]
    250: mov     [rbp-38h],rax
    254: mov     rax,[rbp-40h]
    258: mov     [rbp-30h],rax
    25c: mov     rax,[rbp-38h]
    260: mov     [rbp-28h],rax
    264: mov     edi,0FFFFFF60h
    269: mov     esi,0FFFFFFD0h
    26e: call    ryo_h_MovW128
    273: mov     edi,0FFFFFF70h
    278: mov     esi,20h
    27d: call    ryo_h_MovW128
    282: mov     dword ptr [rbp-78h],0
    289: mov     qword ptr [rbp-80h],0
    291: mov     rax,[rbp+40h]
    295: mov     [rbp-70h],rax
    299: call    fn9
    29e: nop     [rcx-9]
    2a5: jmp     0F0h
    2aa: nop     [rax+rax]
    2b0: mov     qword ptr [rbp-0A0h],0
    2bb: mov     rax,[rbp-20h]
    2bf: mov     [rbp-98h],rax
    2c6: mov     rax,[rbp-18h]
    2ca: mov     [rbp-90h],rax
    2d1: mov     edi,0FFFFFF78h
    2d6: lea     rsi,[k10]
    2dd: call    ryo_h_AddrAbs
    2e2: lea     rdi,[sym11]
    2e9: lea     rsi,[site12]
    2f0: mov     edx,0FFFFFFA0h
    2f5: call    ryo_h_CallExt
    2fa: test    rax,rax
    2fd: je      30Ah
    2ff: call    rax
    301: nop     [rcx-9]
    308: jmp     31Ah
    30a: mov     rdi,rbp
    30d: lea     rsi,[ro+4]
    314: call    qword ptr [sym13]
    31a: call    ryo_h_Unreachable
    31f: ud2
    321: jmp     2B0h
    323: mov     rax,[rbp-18h]
    327: cmp     rax,[rbp-20h]
    32b: jae     230h
    331: jmp     2B0h
    336: mov     rax,[rbp-20h]
    33a: shl     rax,1
    33e: mov     [rbp-28h],rax
    342: mov     [rbp-8],rax
    346: jmp     140h

fn core::slice::sort::stable::drift::logical_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-28h],rax
     13: mov     rax,[rbp+28h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-28h]
     1f: cmp     rax,[rbp-38h]
     23: setbe   [rbp-29h]
     27: test    byte ptr [rbp-29h],0FFh
     2b: je      6Fh
     2d: mov     rax,[rbp+30h]
     31: mov     [rbp-40h],rax
     35: and     rax,1
     39: mov     [rbp-38h],rax
     3d: cmp     rax,1
     41: sete    [rbp-2Ah]
     45: test    byte ptr [rbp-2Ah],0FFh
     49: je      4Dh
     4b: jmp     6Fh
     4d: mov     rax,[rbp+38h]
     51: mov     [rbp-40h],rax
     55: and     rax,1
     59: mov     [rbp-38h],rax
     5d: cmp     rax,1
     61: sete    [rbp-2Bh]
     65: test    byte ptr [rbp-2Bh],0FFh
     69: je      156h
     6f: mov     rax,[rbp+30h]
     73: mov     [rbp-20h],rax
     77: and     rax,1
     7b: mov     [rbp-38h],rax
     7f: cmp     rax,1
     83: sete    [rbp-2Ch]
     87: test    byte ptr [rbp-2Ch],0FFh
     8b: jne     0B0h
     8d: mov     rax,[rbp-20h]
     91: shr     rax,1
     95: mov     [rbp-10h],rax
     99: cmp     rax,0
     9d: jb      261h
     a3: jmp     263h
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp+38h]
     b4: mov     [rbp-40h],rax
     b8: and     rax,1
     bc: mov     [rbp-38h],rax
     c0: cmp     rax,1
     c4: sete    [rbp-2Ch]
     c8: test    byte ptr [rbp-2Ch],0FFh
     cc: je      0D0h
     ce: jmp     0F0h
     d0: mov     rax,[rbp-20h]
     d4: shr     rax,1
     d8: mov     [rbp-18h],rax
     dc: mov     rax,[rbp-28h]
     e0: cmp     rax,[rbp-18h]
     e4: jb      276h
     ea: jmp     2E7h
     ef: nop
     f0: mov     rax,[rbp-20h]
     f4: shr     rax,1
     f8: mov     [rbp-38h],rax
     fc: mov     edi,0FFFFFF50h
    101: mov     esi,10h
    106: call    ryo_h_MovW128
    10b: mov     edi,0FFFFFF60h
    110: mov     esi,20h
    115: call    ryo_h_MovW128
    11a: mov     rax,[rbp-38h]
    11e: mov     [rbp-90h],rax
    125: mov     rax,[rbp+40h]
    129: mov     [rbp-88h],rax
    130: call    fn0
    135: nop     [rcx-18h]
    13c: mov     rax,[rbp-28h]
    140: shl     rax,1
    144: mov     [rbp-40h],rax
    148: or      rax,1
    14c: mov     [rbp-38h],rax
    150: mov     [rbp-8],rax
    154: jmp     166h
    156: mov     rax,[rbp-28h]
    15a: shl     rax,1
    15e: mov     [rbp-38h],rax
    162: mov     [rbp-8],rax
    166: mov     edi,0FFFFFFF8h
    16b: mov     esi,8
    170: call    ryo_h_Ret
    175: leave
    176: ret
    177: nop     [rax+rax]
    180: mov     rax,[rbp+10h]
    184: mov     [rbp-60h],rax
    188: mov     rax,[rbp+18h]
    18c: mov     [rbp-58h],rax
    190: mov     rax,[rbp-60h]
    194: mov     [rbp-68h],rax
    198: mov     [rbp-50h],rax
    19c: mov     rax,[rbp-10h]
    1a0: mov     [rbp-48h],rax
    1a4: mov     rax,[rbp-50h]
    1a8: mov     [rbp-40h],rax
    1ac: mov     rax,[rbp-48h]
    1b0: mov     [rbp-38h],rax
    1b4: mov     edi,0FFFFFF50h
    1b9: mov     esi,0FFFFFFC0h
    1be: call    ryo_h_MovW128
    1c3: mov     edi,0FFFFFF60h
    1c8: mov     esi,20h
    1cd: call    ryo_h_MovW128
    1d2: mov     rax,[rbp+40h]
    1d6: mov     [rbp-90h],rax
    1dd: call    fn1
    1e2: nop     [rcx-8]
    1e9: jmp     0B0h
    1ee: xchg    ax,ax
    1f0: mov     qword ptr [rbp-0B0h],0
    1fb: mov     rax,[rbp-10h]
    1ff: mov     [rbp-0A8h],rax
    206: mov     rax,[rbp-28h]
    20a: mov     [rbp-0A0h],rax
    211: mov     edi,0FFFFFF68h
    216: lea     rsi,[k2]
    21d: call    ryo_h_AddrAbs
    222: lea     rdi,[sym3]
    229: lea     rsi,[site4]
    230: mov     edx,0FFFFFF80h
    235: call    ryo_h_CallExt
    23a: test    rax,rax
    23d: je      24Ah
    23f: call    rax
    241: nop     [rcx-18h]
    248: jmp     25Ah
    24a: mov     rdi,rbp
    24d: lea     rsi,[ro+4]
    254: call    qword ptr [sym5]
    25a: call    ryo_h_Unreachable
    25f: ud2
    261: jmp     1F0h
    263: mov     rax,[rbp-28h]
    267: cmp     rax,[rbp-10h]
    26b: jae     180h
    271: jmp     1F0h
    276: mov     rax,[rbp-18h]
    27a: mov     [rbp-0B0h],rax
    281: mov     rax,[rbp-28h]
    285: mov     [rbp-0A8h],rax
    28c: mov     rax,[rbp-28h]
    290: mov     [rbp-0A0h],rax
    297: mov     edi,0FFFFFF68h
    29c: lea     rsi,[k6]
    2a3: call    ryo_h_AddrAbs
    2a8: lea     rdi,[sym7]
    2af: lea     rsi,[site8]
    2b6: mov     edx,0FFFFFF80h
    2bb: call    ryo_h_CallExt
    2c0: test    rax,rax
    2c3: je      2D0h
    2c5: call    rax
    2c7: nop     [rcx-18h]
    2ce: jmp     2E0h
    2d0: mov     rdi,rbp
    2d3: lea     rsi,[ro+4]
    2da: call    qword ptr [sym9]
    2e0: call    ryo_h_Unreachable
    2e5: ud2
    2e7: mov     rax,[rbp-28h]
    2eb: sub     rax,[rbp-18h]
    2ef: mov     [rbp-48h],rax
    2f3: mov     rax,[rbp+10h]
    2f7: mov     [rbp-68h],rax
    2fb: mov     rax,[rbp+18h]
    2ff: mov     [rbp-60h],rax
    303: mov     rax,[rbp-68h]
    307: mov     [rbp-70h],rax
    30b: imul    rcx,[rbp-18h],8
    310: add     rax,rcx
    313: mov     [rbp-78h],rax
    317: mov     [rbp-58h],rax
    31b: mov     rax,[rbp-48h]
    31f: mov     [rbp-50h],rax
    323: mov     rax,[rbp-58h]
    327: mov     [rbp-40h],rax
    32b: mov     rax,[rbp-50h]
    32f: mov     [rbp-38h],rax
    333: mov     edi,0FFFFFF50h
    338: mov     esi,0FFFFFFC0h
    33d: call    ryo_h_MovW128
    342: mov     edi,0FFFFFF60h
    347: mov     esi,20h
    34c: call    ryo_h_MovW128
    351: mov     rax,[rbp+40h]
    355: mov     [rbp-90h],rax
    35c: call    fn10
    361: nop     [rcx-10h]
    368: jmp     0F0h

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,390h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     rax,2
     17: jae     1Eh
     19: jmp     5D1h
     1e: mov     rax,[rbp-60h]
     22: mov     [rbp-70h],rax
     26: cmp     rax,0
     2a: sete    [rbp-79h]
     2e: test    byte ptr [rbp-79h],0FFh
     32: je      5DCh
     38: mov     edi,0FFFFFC70h
     3d: lea     rsi,[k0]
     44: call    ryo_h_AddrAbs
     49: lea     rdi,[sym1]
     50: lea     rsi,[site2]
     57: mov     edx,0FFFFFCB0h
     5c: call    ryo_h_CallExt
     61: test    rax,rax
     64: je      71h
     66: call    rax
     68: nop     [rcx-348h]
     6f: jmp     81h
     71: mov     rdi,rbp
     74: lea     rsi,[ro+4]
     7b: call    qword ptr [sym3]
     81: call    ryo_h_Unreachable
     86: ud2
     88: nop     [rax+rax]
     90: mov     qword ptr [rbp-350h],2
     9b: mov     edi,0FFFFFF78h
     a0: mov     esi,0FFFFFFA0h
     a5: mov     edx,0FFFFFCB0h
     aa: call    ryo_h_DivUW64
     af: mov     rax,[rbp-60h]
     b3: sub     rax,[rbp-88h]
     ba: mov     [rbp-80h],rax
     be: mov     [rbp-390h],rax
     c5: mov     qword ptr [rbp-388h],40h
     d0: call    fn4
     d5: nop     [rcx-70h]
     dc: jmp     6AFh
     e1: nop     [rax+rax]
     ea: nop     [rax+rax]
     f0: mov     rax,[rbp-60h]
     f4: mov     [rbp-390h],rax
     fb: lea     rdi,[sym5]
    102: lea     rsi,[site6]
    109: mov     edx,0FFFFFCB0h
    10e: call    ryo_h_CallExt
    113: test    rax,rax
    116: je      123h
    118: call    rax
    11a: nop     [rcx-70h]
    121: jmp     133h
    123: mov     rdi,rbp
    126: lea     rsi,[ro+20]
    12d: call    qword ptr [sym7]
    133: nop     [rax+rax]
    13c: nop     [rax]
    140: mov     qword ptr [rbp-78h],0
    148: mov     edi,0FFFFFD78h
    14d: lea     rsi,[k8]
    154: mov     edx,210h
    159: call    ryo_h_Const
    15e: lea     rax,[rbp-288h]
    165: mov     [rbp-50h],rax
    169: mov     [rbp-298h],rax
    170: mov     rax,[rbp-50h]
    174: mov     [rbp-290h],rax
    17b: mov     edi,0FFFFFD2Eh
    180: lea     rsi,[k9]
    187: mov     edx,42h
    18c: call    ryo_h_Const
    191: lea     rax,[rbp-2D2h]
    198: mov     [rbp-58h],rax
    19c: mov     [rbp-2E8h],rax
    1a3: mov     rax,[rbp-58h]
    1a7: mov     [rbp-2E0h],rax
    1ae: mov     qword ptr [rbp-2E8h],0
    1b9: mov     qword ptr [rbp-38h],1
    1c1: nop     [rax+rax]
    1ca: nop     [rax+rax]
    1d0: mov     rax,[rbp-2E8h]
    1d7: mov     [rbp-2F0h],rax
    1de: cmp     rax,[rbp-60h]
    1e2: jae     350h
    1e8: mov     rax,[rbp-2E8h]
    1ef: mov     [rbp-20h],rax
    1f3: mov     rax,[rbp-60h]
    1f7: cmp     rax,[rbp-20h]
    1fb: jb      6B4h
    201: jmp     725h
    206: nop     [rax+rax]
    20f: nop
    210: mov     rax,[rbp-2E8h]
    217: mov     [rbp-2F8h],rax
    21e: mov     rax,[rbp-38h]
    222: mov     [rbp-308h],rax
    229: shr     rax,1
    22d: mov     [rbp-300h],rax
    234: mov     rax,[rbp-2F8h]
    23b: sub     rax,[rbp-300h]
    242: mov     [rbp-2F0h],rax
    249: mov     rax,[rbp-2E8h]
    250: mov     [rbp-2F8h],rax
    257: mov     rax,[rbp-2E8h]
    25e: mov     [rbp-308h],rax
    265: mov     rax,[rbp-18h]
    269: mov     [rbp-318h],rax
    270: shr     rax,1
    274: mov     [rbp-310h],rax
    27b: mov     rax,[rbp-308h]
    282: add     rax,[rbp-310h]
    289: mov     [rbp-300h],rax
    290: mov     rax,[rbp-68h]
    294: mov     [rbp-308h],rax
    29b: mov     rax,[rbp-2F0h]
    2a2: mov     [rbp-318h],rax
    2a9: mov     rax,[rbp-2F8h]
    2b0: mov     [rbp-320h],rax
    2b7: mov     rax,[rbp-318h]
    2be: add     rax,[rbp-320h]
    2c5: mov     [rbp-310h],rax
    2cc: mov     rax,[rbp-300h]
    2d3: mov     [rbp-328h],rax
    2da: mov     rax,[rbp-320h]
    2e1: add     rax,[rbp-328h]
    2e8: mov     [rbp-318h],rax
    2ef: mov     rax,[rbp-308h]
    2f6: imul    rax,[rbp-310h]
    2fe: mov     [rbp-330h],rax
    305: mov     rax,[rbp-308h]
    30c: imul    rax,[rbp-318h]
    314: mov     [rbp-338h],rax
    31b: mov     rax,[rbp-330h]
    322: xor     rax,[rbp-338h]
    329: mov     [rbp-328h],rax
    330: mov     edi,0FFFFFCB4h
    335: mov     esi,0FFFFFCD8h
    33a: call    ryo_h_CtlzW64
    33f: mov     eax,[rbp-34Ch]
    345: mov     [rbp-2D8h],eax
    34b: jmp     7F5h
    350: mov     qword ptr [rbp-18h],1
    358: mov     byte ptr [rbp-21h],0
    35c: nop     [rax]
    360: mov     rax,[rbp-78h]
    364: mov     [rbp-2F0h],rax
    36b: cmp     rax,1
    36f: jbe     4B3h
    375: mov     rax,[rbp-78h]
    379: mov     [rbp-300h],rax
    380: sub     rax,1
    384: mov     [rbp-2F8h],rax
    38b: mov     rax,[rbp-2E0h]
    392: imul    rcx,[rbp-2F8h],1
    39a: add     rax,rcx
    39d: mov     [rbp-2F0h],rax
    3a4: movzx   eax,byte ptr [rax]
    3a7: mov     [rbp-2D5h],al
    3ad: movzx   eax,byte ptr [rbp-21h]
    3b1: mov     [rbp-2D6h],al
    3b7: movzx   eax,byte ptr [rbp-2D5h]
    3be: cmp     al,[rbp-2D6h]
    3c4: jb      4B1h
    3ca: mov     rax,[rbp-78h]
    3ce: mov     [rbp-308h],rax
    3d5: sub     rax,1
    3d9: mov     [rbp-300h],rax
    3e0: mov     rax,[rbp-290h]
    3e7: imul    rcx,[rbp-300h],8
    3ef: add     rax,rcx
    3f2: mov     [rbp-2F8h],rax
    3f9: mov     rax,[rax]
    3fc: mov     [rbp-2F0h],rax
    403: mov     [rbp-308h],rax
    40a: shr     rax,1
    40e: mov     [rbp-300h],rax
    415: mov     rax,[rbp-38h]
    419: mov     [rbp-310h],rax
    420: shr     rax,1
    424: mov     [rbp-308h],rax
    42b: mov     rax,[rbp-300h]
    432: add     rax,[rbp-308h]
    439: mov     [rbp-2F8h],rax
    440: mov     rax,[rbp-2E8h]
    447: mov     [rbp-308h],rax
    44e: sub     rax,[rbp-2F8h]
    455: mov     [rbp-300h],rax
    45c: mov     rax,[rbp-2E8h]
    463: mov     [rbp-30h],rax
    467: mov     rax,[rbp+10h]
    46b: mov     [rbp-330h],rax
    472: mov     rax,[rbp+18h]
    476: mov     [rbp-328h],rax
    47d: mov     byte ptr [rbp-349h],1
    484: test    byte ptr [rbp-349h],0FFh
    48b: je      84Ah
    491: jmp     809h
    496: nop     [rax+rax]
    49f: nop
    4a0: mov     rax,[rbp-78h]
    4a4: sub     rax,1
    4a8: mov     [rbp-78h],rax
    4ac: jmp     360h
    4b1: jmp     4B3h
    4b3: mov     rax,[rbp-38h]
    4b7: mov     [rbp-2F0h],rax
    4be: mov     rax,[rbp-78h]
    4c2: mov     [rbp-300h],rax
    4c9: mov     rax,[rbp-290h]
    4d0: imul    rcx,[rbp-300h],8
    4d8: add     rax,rcx
    4db: mov     [rbp-2F8h],rax
    4e2: mov     rcx,[rbp-2F0h]
    4e9: mov     [rax],rcx
    4ec: mov     rax,[rbp-78h]
    4f0: mov     [rbp-2F8h],rax
    4f7: mov     rax,[rbp-2E0h]
    4fe: imul    rcx,[rbp-2F8h],1
    506: add     rax,rcx
    509: mov     [rbp-2F0h],rax
    510: movzx   ecx,byte ptr [rbp-21h]
    514: mov     [rax],cl
    516: mov     rax,[rbp-78h]
    51a: add     rax,1
    51e: mov     [rbp-78h],rax
    522: mov     rax,[rbp-2E8h]
    529: mov     [rbp-2F0h],rax
    530: cmp     rax,[rbp-60h]
    534: jb      562h
    536: mov     rax,[rbp-38h]
    53a: mov     [rbp-2F8h],rax
    541: and     rax,1
    545: mov     [rbp-2F0h],rax
    54c: cmp     rax,1
    550: sete    [rbp-2D3h]
    557: test    byte ptr [rbp-2D3h],0FFh
    55e: je      59Ch
    560: jmp     59Ah
    562: mov     rax,[rbp-18h]
    566: mov     [rbp-2F8h],rax
    56d: shr     rax,1
    571: mov     [rbp-2F0h],rax
    578: mov     rax,[rbp-2E8h]
    57f: add     rax,[rbp-2F0h]
    586: mov     [rbp-2E8h],rax
    58d: mov     rax,[rbp-18h]
    591: mov     [rbp-38h],rax
    595: jmp     1D0h
    59a: jmp     5D1h
    59c: mov     edi,0FFFFFC70h
    5a1: mov     esi,10h
    5a6: call    ryo_h_MovW128
    5ab: mov     edi,0FFFFFC80h
    5b0: mov     esi,20h
    5b5: call    ryo_h_MovW128
    5ba: mov     rax,[rbp+38h]
    5be: mov     [rbp-370h],rax
    5c5: call    fn10
    5ca: nop     [rcx-38h]
    5d1: xor     edi,edi
    5d3: xor     esi,esi
    5d5: call    ryo_h_Ret
    5da: leave
    5db: ret
    5dc: mov     rax,4000000000000000h
    5e6: mov     [rbp-350h],rax
    5ed: mov     edi,0FFFFFF88h
    5f2: mov     esi,0FFFFFCB0h
    5f7: mov     edx,0FFFFFF90h
    5fc: call    ryo_h_DivUW64
    601: test    byte ptr [rbp-79h],0FFh
    605: je      657h
    607: mov     edi,0FFFFFC70h
    60c: lea     rsi,[k11]
    613: call    ryo_h_AddrAbs
    618: lea     rdi,[sym12]
    61f: lea     rsi,[site13]
    626: mov     edx,0FFFFFCB0h
    62b: call    ryo_h_CallExt
    630: test    rax,rax
    633: je      640h
    635: call    rax
    637: nop     [rcx-348h]
    63e: jmp     650h
    640: mov     rdi,rbp
    643: lea     rsi,[ro+4]
    64a: call    qword ptr [sym14]
    650: call    ryo_h_Unreachable
    655: ud2
    657: mov     rax,4000000000000000h
    661: mov     [rbp-350h],rax
    668: mov     edi,0FFFFFF78h
    66d: mov     esi,0FFFFFCB0h
    672: mov     edx,0FFFFFF90h
    677: call    ryo_h_RemUW64
    67c: cmp     qword ptr [rbp-88h],0
    684: jbe     694h
    686: mov     rax,[rbp-78h]
    68a: add     rax,1
    68e: mov     [rbp-68h],rax
    692: jmp     69Ch
    694: mov     rax,[rbp-78h]
    698: mov     [rbp-68h],rax
    69c: cmp     qword ptr [rbp-60h],1000h
    6a4: jbe     90h
    6aa: jmp     0F0h
    6af: jmp     140h
    6b4: mov     rax,[rbp-20h]
    6b8: mov     [rbp-390h],rax
    6bf: mov     rax,[rbp-60h]
    6c3: mov     [rbp-388h],rax
    6ca: mov     rax,[rbp-60h]
    6ce: mov     [rbp-380h],rax
    6d5: mov     edi,0FFFFFC88h
    6da: lea     rsi,[k15]
    6e1: call    ryo_h_AddrAbs
    6e6: lea     rdi,[sym16]
    6ed: lea     rsi,[site17]
    6f4: mov     edx,0FFFFFCB0h
    6f9: call    ryo_h_CallExt
    6fe: test    rax,rax
    701: je      70Eh
    703: call    rax
    705: nop     [rcx-58h]
    70c: jmp     71Eh
    70e: mov     rdi,rbp
    711: lea     rsi,[ro+36]
    718: call    qword ptr [sym18]
    71e: call    ryo_h_Unreachable
    723: ud2
    725: mov     rax,[rbp-60h]
    729: sub     rax,[rbp-20h]
    72d: mov     [rbp-300h],rax
    734: mov     rax,[rbp+10h]
    738: mov     [rbp-320h],rax
    73f: mov     rax,[rbp+18h]
    743: mov     [rbp-318h],rax
    74a: mov     rax,[rbp-320h]
    751: mov     [rbp-328h],rax
    758: imul    rcx,[rbp-20h],8
    75d: add     rax,rcx
    760: mov     [rbp-330h],rax
    767: mov     [rbp-310h],rax
    76e: mov     rax,[rbp-300h]
    775: mov     [rbp-308h],rax
    77c: mov     rax,[rbp-310h]
    783: mov     [rbp-2F8h],rax
    78a: mov     rax,[rbp-308h]
    791: mov     [rbp-2F0h],rax
    798: mov     rax,[rbp-70h]
    79c: mov     [rbp-300h],rax
    7a3: mov     edi,0FFFFFC70h
    7a8: mov     esi,0FFFFFD08h
    7ad: call    ryo_h_MovW128
    7b2: mov     edi,0FFFFFC80h
    7b7: mov     esi,20h
    7bc: call    ryo_h_MovW128
    7c1: mov     rax,[rbp-300h]
    7c8: mov     [rbp-370h],rax
    7cf: movzx   eax,byte ptr [rbp+30h]
    7d3: mov     [rbp-368h],al
    7d9: mov     rax,[rbp+38h]
    7dd: mov     [rbp-360h],rax
    7e4: call    fn19
    7e9: nop     [rcx-18h]
    7f0: jmp     210h
    7f5: mov     edi,0FFFFFFDFh
    7fa: mov     esi,0FFFFFD28h
    7ff: call    ryo_h_TruncW32W8
    804: jmp     360h
    809: mov     rax,[rbp-300h]
    810: mov     [rbp-390h],rax
    817: mov     rax,[rbp-30h]
    81b: mov     [rbp-388h],rax
    822: mov     rax,[rbp-60h]
    826: mov     [rbp-380h],rax
    82d: mov     edi,0FFFFFC88h
    832: lea     rsi,[k20]
    839: call    ryo_h_AddrAbs
    83e: call    fn21
    843: nop     [rcx-58h]
    84a: mov     rax,[rbp-30h]
    84e: sub     rax,[rbp-300h]
    855: mov     [rbp-338h],rax
    85c: mov     rax,[rbp-330h]
    863: mov     [rbp-340h],rax
    86a: imul    rcx,[rbp-300h],8
    872: add     rax,rcx
    875: mov     [rbp-348h],rax
    87c: mov     [rbp-320h],rax
    883: mov     rax,[rbp-338h]
    88a: mov     [rbp-318h],rax
    891: mov     rax,[rbp-320h]
    898: mov     [rbp-310h],rax
    89f: mov     rax,[rbp-318h]
    8a6: mov     [rbp-308h],rax
    8ad: mov     rax,[rbp-38h]
    8b1: mov     [rbp-318h],rax
    8b8: mov     edi,0FFFFFC70h
    8bd: mov     esi,0FFFFFCF0h
    8c2: call    ryo_h_MovW128
    8c7: mov     edi,0FFFFFC80h
    8cc: mov     esi,20h
    8d1: call    ryo_h_MovW128
    8d6: mov     rax,[rbp-2F0h]
    8dd: mov     [rbp-370h],rax
    8e4: mov     rax,[rbp-318h]
    8eb: mov     [rbp-368h],rax
    8f2: mov     rax,[rbp+38h]
    8f6: mov     [rbp-360h],rax
    8fd: call    fn22
    902: nop     [rcx-38h]
    909: jmp     4A0h

fn core::slice::sort::stable::drift::stable_quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-18h],rax
     13: or      rax,1
     17: mov     [rbp-10h],rax
     1b: mov     [rbp-18h],rax
     1f: mov     edi,0FFFFFFC4h
     24: mov     esi,0FFFFFFE8h
     29: xor     edx,edx
     2b: xor     ecx,ecx
     2d: xor     r8d,r8d
     30: mov     r9d,1
     36: call    ryo_h_DiscrNicheW64
     3b: mov     edi,0FFFFFFE0h
     40: mov     esi,0FFFFFFC4h
     45: call    ryo_h_ZextW32W64
     4a: mov     edi,0FFFFFFE0h
     4f: xor     esi,esi
     51: mov     edx,2
     56: call    ryo_h_SwitchDenseW64
     5b: lea     rcx,[6Ch]
     62: movsxd  rax,[rcx+rax*4]
     66: add     rax,rcx
     69: jmp     rax
     6b: int3
     6c: .long   92h
     70: .long   e2h
     74: .long   8bh
     78: nop     [rax+rax]
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret
     8b: call    ryo_h_Unreachable
     90: ud2
     92: mov     edi,0FFFFFF80h
     97: lea     rsi,[k0]
     9e: call    ryo_h_AddrAbs
     a3: lea     rdi,[sym1]
     aa: lea     rsi,[site2]
     b1: mov     edx,0FFFFFFC0h
     b6: call    ryo_h_CallExt
     bb: test    rax,rax
     be: je      0CBh
     c0: call    rax
     c2: nop     [rcx]
     c9: jmp     0DBh
     cb: mov     rdi,rbp
     ce: lea     rsi,[ro+4]
     d5: call    qword ptr [sym3]
     db: call    ryo_h_Unreachable
     e0: ud2
     e2: mov     rax,[rbp-18h]
     e6: mov     [rbp-28h],rax
     ea: mov     [rbp-38h],rax
     ee: mov     edi,0FFFFFFC4h
     f3: mov     esi,0FFFFFFC8h
     f8: call    ryo_h_CtlzW64
     fd: mov     eax,[rbp-3Ch]
    100: mov     [rbp-2Ch],eax
    103: mov     dword ptr [rbp-3Ch],3Fh
    10a: mov     eax,[rbp-3Ch]
    10d: sub     eax,[rbp-2Ch]
    110: mov     [rbp-4],eax
    113: mov     dword ptr [rbp-3Ch],2
    11a: mov     eax,[rbp-3Ch]
    11d: imul    eax,[rbp-4]
    121: mov     [rbp-8],eax
    124: mov     edi,0FFFFFF80h
    129: mov     esi,10h
    12e: call    ryo_h_MovW128
    133: mov     edi,0FFFFFF90h
    138: mov     esi,20h
    13d: call    ryo_h_MovW128
    142: mov     eax,[rbp-8]
    145: mov     [rbp-58h],eax
    148: mov     qword ptr [rbp-60h],0
    150: mov     rax,[rbp+30h]
    154: mov     [rbp-50h],rax
    158: call    fn4
    15d: nop     [rcx]
    164: jmp     80h

fn core::slice::sort::stable::driftsort_main::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}, std::vec::Vec<(u32, u32)>>
      0: push    rbp
      1: mov     rbp,rsp
      4: mov     eax,2090h
      9: call    ryo_probe_stack
      e: sub     rsp,2090h
     15: mov     byte ptr [rbp-19h],0
     19: mov     qword ptr [rbp-2048h],8
     24: cmp     qword ptr [rbp-2048h],0
     2c: sete    [rbp-1]
     30: test    byte ptr [rbp-1],0FFh
     34: je      86h
     36: mov     edi,0FFFFDF70h
     3b: lea     rsi,[k0]
     42: call    ryo_h_AddrAbs
     47: lea     rdi,[sym1]
     4e: lea     rsi,[site2]
     55: mov     edx,0FFFFDFB8h
     5a: call    ryo_h_CallExt
     5f: test    rax,rax
     62: je      6Fh
     64: call    rax
     66: nop     [rcx-2040h]
     6d: jmp     7Fh
     6f: mov     rdi,rbp
     72: lea     rsi,[ro+4]
     79: call    qword ptr [sym3]
     7f: call    ryo_h_Unreachable
     84: ud2
     86: mov     qword ptr [rbp-2048h],7A1200h
     91: mov     qword ptr [rbp-2050h],8
     9c: mov     edi,0FFFFFFD0h
     a1: mov     esi,0FFFFDFB8h
     a6: mov     edx,0FFFFDFB0h
     ab: call    ryo_h_DivUW64
     b0: mov     rax,[rbp+18h]
     b4: mov     [rbp-38h],rax
     b8: mov     qword ptr [rbp-2048h],2
     c3: mov     edi,0FFFFFFA8h
     c8: mov     esi,0FFFFFFC8h
     cd: mov     edx,0FFFFDFB8h
     d2: call    ryo_h_DivUW64
     d7: mov     rax,[rbp-38h]
     db: sub     rax,[rbp-58h]
     df: mov     [rbp-50h],rax
     e3: mov     rax,[rbp-38h]
     e7: mov     [rbp-2090h],rax
     ee: mov     rax,[rbp-30h]
     f2: mov     [rbp-2088h],rax
     f9: call    fn4
     fe: nop     [rcx-58h]
    105: jmp     268h
    10a: nop     [rax+rax]
    110: mov     rax,[rbp-10h]
    114: mov     [rbp-1068h],rax
    11b: cmp     rax,[rbp-40h]
    11f: jb      123h
    121: jmp     173h
    123: mov     rax,[rbp-40h]
    127: mov     [rbp-2090h],rax
    12e: call    fn5
    133: nop     [rcx-1078h]
    13a: mov     byte ptr [rbp-19h],1
    13e: mov     edi,0FFFFEFA8h
    143: mov     esi,0FFFFEF88h
    148: mov     edx,18h
    14d: call    ryo_h_Copy
    152: lea     rax,[rbp-1058h]
    159: mov     [rbp-1068h],rax
    160: mov     [rbp-2090h],rax
    167: call    fn6
    16c: nop     [rcx-18h]
    173: call    fn7
    178: nop     [rcx-1070h]
    17f: imul    rax,[rbp-1070h],2
    187: mov     [rbp-1068h],rax
    18e: mov     rax,[rbp-38h]
    192: cmp     rax,[rbp-1068h]
    199: setbe   [rbp-1059h]
    1a0: mov     edi,0FFFFDF70h
    1a5: mov     esi,10h
    1aa: call    ryo_h_MovW128
    1af: mov     edi,0FFFFDF80h
    1b4: mov     esi,0FFFFFFE8h
    1b9: call    ryo_h_MovW128
    1be: movzx   eax,byte ptr [rbp-1059h]
    1c5: mov     [rbp-2070h],al
    1cb: mov     rax,[rbp+20h]
    1cf: mov     [rbp-2068h],rax
    1d6: call    fn8
    1db: nop     [rcx-18h]
    1e2: test    byte ptr [rbp-19h],0FFh
    1e6: jne     20Ch
    1e8: nop     [rax+rax]
    1f0: xor     edi,edi
    1f2: xor     esi,esi
    1f4: call    ryo_h_Ret
    1f9: leave
    1fa: ret
    1fb: nop     [rax+rax]
    200: mov     edi,0FFFFFFD8h
    205: call    ryo_h_Resume
    20a: ud2
    20c: lea     rax,[rbp-1058h]
    213: mov     [rbp-2048h],rax
    21a: mov     [rbp-2090h],rax
    221: call    fn9
    226: nop     [rcx-2048h]
    22d: jmp     1F0h
    22f: nop
    230: lea     rax,[rbp-1058h]
    237: mov     [rbp-2048h],rax
    23e: mov     [rbp-2090h],rax
    245: call    fn10
    24a: nop     [rcx-2048h]
    251: jmp     200h
    253: nop     [rax+rax]
    25c: nop     [rax]
    260: test    byte ptr [rbp-19h],0FFh
    264: je      200h
    266: jmp     230h
    268: mov     rax,[rbp-50h]
    26c: mov     [rbp-2090h],rax
    273: mov     rax,[rbp-58h]
    277: mov     [rbp-2088h],rax
    27e: call    fn11
    283: nop     [rcx-48h]
    28a: mov     rax,[rbp-48h]
    28e: mov     [rbp-2090h],rax
    295: mov     qword ptr [rbp-2088h],30h
    2a0: call    fn12
    2a5: nop     [rcx-40h]
    2ac: mov     edi,0FFFFDFC0h
    2b1: lea     rsi,[k13]
    2b8: mov     edx,1
    2bd: call    ryo_h_Const
    2c2: lea     rax,[rbp-2040h]
    2c9: mov     [rbp-2048h],rax
    2d0: lea     rax,[rax+1]
    2d4: mov     [rbp-2050h],rax
    2db: mov     qword ptr [rbp-2058h],1
    2e6: mov     edi,0FFFFDFB0h
    2eb: mov     esi,0FFFFDFB8h
    2f0: mov     edx,0FFFFDFA8h
    2f5: call    ryo_h_Memcpy
    2fa: mov     rax,[rbp-2048h]
    301: lea     rax,[rax+2]
    305: mov     [rbp-2050h],rax
    30c: mov     qword ptr [rbp-2058h],2
    317: mov     edi,0FFFFDFB0h
    31c: mov     esi,0FFFFDFB8h
    321: mov     edx,0FFFFDFA8h
    326: call    ryo_h_Memcpy
    32b: mov     rax,[rbp-2048h]
    332: lea     rax,[rax+4]
    336: mov     [rbp-2050h],rax
    33d: mov     qword ptr [rbp-2058h],4
    348: mov     edi,0FFFFDFB0h
    34d: mov     esi,0FFFFDFB8h
    352: mov     edx,0FFFFDFA8h
    357: call    ryo_h_Memcpy
    35c: mov     rax,[rbp-2048h]
    363: lea     rax,[rax+8]
    367: mov     [rbp-2050h],rax
    36e: mov     qword ptr [rbp-2058h],8
    379: mov     edi,0FFFFDFB0h
    37e: mov     esi,0FFFFDFB8h
    383: mov     edx,0FFFFDFA8h
    388: call    ryo_h_Memcpy
    38d: mov     rax,[rbp-2048h]
    394: lea     rax,[rax+10h]
    398: mov     [rbp-2050h],rax
    39f: mov     qword ptr [rbp-2058h],10h
    3aa: mov     edi,0FFFFDFB0h
    3af: mov     esi,0FFFFDFB8h
    3b4: mov     edx,0FFFFDFA8h
    3b9: call    ryo_h_Memcpy
    3be: mov     rax,[rbp-2048h]
    3c5: lea     rax,[rax+20h]
    3c9: mov     [rbp-2050h],rax
    3d0: mov     qword ptr [rbp-2058h],20h
    3db: mov     edi,0FFFFDFB0h
    3e0: mov     esi,0FFFFDFB8h
    3e5: mov     edx,0FFFFDFA8h
    3ea: call    ryo_h_Memcpy
    3ef: mov     rax,[rbp-2048h]
    3f6: lea     rax,[rax+40h]
    3fa: mov     [rbp-2050h],rax
    401: mov     qword ptr [rbp-2058h],40h
    40c: mov     edi,0FFFFDFB0h
    411: mov     esi,0FFFFDFB8h
    416: mov     edx,0FFFFDFA8h
    41b: call    ryo_h_Memcpy
    420: mov     rax,[rbp-2048h]
    427: lea     rax,[rax+80h]
    42e: mov     [rbp-2050h],rax
    435: mov     qword ptr [rbp-2058h],80h
    440: mov     edi,0FFFFDFB0h
    445: mov     esi,0FFFFDFB8h
    44a: mov     edx,0FFFFDFA8h
    44f: call    ryo_h_Memcpy
    454: mov     rax,[rbp-2048h]
    45b: lea     rax,[rax+100h]
    462: mov     [rbp-2050h],rax
    469: mov     qword ptr [rbp-2058h],100h
    474: mov     edi,0FFFFDFB0h
    479: mov     esi,0FFFFDFB8h
    47e: mov     edx,0FFFFDFA8h
    483: call    ryo_h_Memcpy
    488: mov     rax,[rbp-2048h]
    48f: lea     rax,[rax+200h]
    496: mov     [rbp-2050h],rax
    49d: mov     qword ptr [rbp-2058h],200h
    4a8: mov     edi,0FFFFDFB0h
    4ad: mov     esi,0FFFFDFB8h
    4b2: mov     edx,0FFFFDFA8h
    4b7: call    ryo_h_Memcpy
    4bc: mov     rax,[rbp-2048h]
    4c3: lea     rax,[rax+400h]
    4ca: mov     [rbp-2050h],rax
    4d1: mov     qword ptr [rbp-2058h],400h
    4dc: mov     edi,0FFFFDFB0h
    4e1: mov     esi,0FFFFDFB8h
    4e6: mov     edx,0FFFFDFA8h
    4eb: call    ryo_h_Memcpy
    4f0: mov     rax,[rbp-2048h]
    4f7: lea     rax,[rax+800h]
    4fe: mov     [rbp-2050h],rax
    505: mov     qword ptr [rbp-2058h],800h
    510: mov     edi,0FFFFDFB0h
    515: mov     esi,0FFFFDFB8h
    51a: mov     edx,0FFFFDFA8h
    51f: call    ryo_h_Memcpy
    524: mov     edi,0FFFFEFC0h
    529: mov     esi,0FFFFDFC0h
    52e: mov     edx,1000h
    533: call    ryo_h_Copy
    538: lea     rax,[rbp-1040h]
    53f: mov     [rbp-1048h],rax
    546: mov     [rbp-2090h],rax
    54d: call    fn14
    552: nop     [rcx-18h]
    559: jmp     110h
    55e: xchg    ax,ax
    560: lea     rdi,[sym15]
    567: lea     rsi,[site16]
    56e: mov     edx,0FFFFDFB8h
    573: call    ryo_h_CallExt
    578: test    rax,rax
    57b: je      588h
    57d: call    rax
    57f: nop     [rcx-2040h]
    586: jmp     598h
    588: mov     rdi,rbp
    58b: lea     rsi,[ro+4]
    592: call    qword ptr [sym17]
    598: call    ryo_h_Unreachable
    59d: ud2
    59f: mov     rdi,rax
    5a2: mov     esi,0FFFFFFD8h
    5a7: call    ryo_h_Lpad
    5ac: jmp     260h
    5b1: mov     rdi,rax
    5b4: mov     esi,0FFFFFFD8h
    5b9: call    ryo_h_Lpad
    5be: jmp     560h

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_down::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax+10h]
     18: mov     [rbp-30h],rax
     1c: mov     byte ptr [rbp-51h],0
     20: test    byte ptr [rbp-51h],0FFh
     24: je      0C2h
     2a: jmp     0B8h
     2f: nop
     30: test    byte ptr [rbp-29h],0FFh
     34: je      40h
     36: mov     rax,[rbp-8]
     3a: mov     [rbp-18h],rax
     3e: jmp     48h
     40: mov     rax,[rbp-10h]
     44: mov     [rbp-18h],rax
     48: mov     rax,[rbp-18h]
     4c: mov     [rbp-38h],rax
     50: mov     rax,[rbp+28h]
     54: mov     [rbp-40h],rax
     58: mov     byte ptr [rbp-51h],1
     5c: test    byte ptr [rbp-51h],0FFh
     60: je      1F6h
     66: jmp     19Bh
     6b: nop     [rax+rax]
     70: mov     rax,[rbp+10h]
     74: mov     rax,[rax+8]
     78: mov     [rbp-38h],rax
     7c: mov     [rbp-28h],rax
     80: cmp     rax,[rbp+20h]
     84: jne     9Bh
     86: nop     [rax+rax]
     8f: nop
     90: xor     edi,edi
     92: xor     esi,esi
     94: call    ryo_h_Ret
     99: leave
     9a: ret
     9b: jmp     10h
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+8]
     a8: mov     [rbp-30h],rax
     ac: mov     byte ptr [rbp-51h],0
     b0: test    byte ptr [rbp-51h],0FFh
     b4: je      0FDh
     b6: jmp     0F3h
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-8],rax
     c0: jmp     0A0h
     c2: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
     ca: mov     rax,[rbp-30h]
     ce: imul    rcx,[rbp-58h],8
     d3: add     rax,rcx
     d6: mov     [rbp-8],rax
     da: jmp     0A0h
     dc: nop     [rax]
     e0: mov     byte ptr [rbp-51h],0
     e4: test    byte ptr [rbp-51h],0FFh
     e8: je      181h
     ee: jmp     177h
     f3: mov     rax,[rbp-30h]
     f7: mov     [rbp-10h],rax
     fb: jmp     0E0h
     fd: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    105: mov     rax,[rbp-30h]
    109: imul    rcx,[rbp-58h],8
    10e: add     rax,rcx
    111: mov     [rbp-10h],rax
    115: jmp     0E0h
    117: nop     [rax+rax]
    120: mov     rax,[rbp-30h]
    124: mov     [rbp+28h],rax
    128: mov     rax,[rbp-10h]
    12c: mov     [rbp-48h],rax
    130: mov     rax,[rbp-8]
    134: mov     [rbp-50h],rax
    138: mov     rax,[rbp-48h]
    13c: mov     [rbp-40h],rax
    140: mov     rax,[rbp-50h]
    144: mov     [rbp-38h],rax
    148: mov     rax,[rbp+30h]
    14c: mov     [rbp-90h],rax
    153: mov     rax,[rbp-40h]
    157: mov     [rbp-88h],rax
    15e: mov     rax,[rbp-38h]
    162: mov     [rbp-80h],rax
    166: call    fn0
    16b: nop     [rcx-29h]
    172: jmp     30h
    177: mov     rax,[rbp+28h]
    17b: mov     [rbp-30h],rax
    17f: jmp     120h
    181: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    189: mov     rax,[rbp+28h]
    18d: imul    rcx,[rbp-58h],8
    192: add     rax,rcx
    195: mov     [rbp-30h],rax
    199: jmp     120h
    19b: mov     rax,[rbp-18h]
    19f: mov     [rbp-48h],rax
    1a3: mov     rax,[rbp-40h]
    1a7: mov     [rbp-50h],rax
    1ab: mov     rax,[rbp-48h]
    1af: mov     [rbp-90h],rax
    1b6: mov     rax,[rbp-50h]
    1ba: mov     [rbp-88h],rax
    1c1: mov     qword ptr [rbp-80h],8
    1c9: mov     qword ptr [rbp-78h],4
    1d1: mov     qword ptr [rbp-70h],1
    1d9: mov     edi,0FFFFFF98h
    1de: lea     rsi,[k1]
    1e5: call    ryo_h_AddrAbs
    1ea: call    fn2
    1ef: nop     [rcx-28h]
    1f6: mov     qword ptr [rbp-58h],1
    1fe: imul    rax,[rbp-58h],8
    203: mov     [rbp-60h],rax
    207: mov     edi,0FFFFFFC0h
    20c: mov     esi,0FFFFFFC8h
    211: mov     edx,0FFFFFFA0h
    216: call    ryo_h_Memcpy
    21b: movzx   eax,byte ptr [rbp-29h]
    21f: xor     al,1
    222: mov     [rbp-2Ah],al
    225: mov     edi,0FFFFFFC0h
    22a: mov     esi,0FFFFFFD6h
    22f: call    ryo_h_ZextW8W64
    234: mov     rax,[rbp-8]
    238: imul    rcx,[rbp-40h],8
    23d: add     rax,rcx
    240: mov     [rbp-38h],rax
    244: mov     rax,[rbp+10h]
    248: mov     rcx,[rbp-38h]
    24c: mov     [rax+10h],rcx
    250: mov     edi,0FFFFFFC0h
    255: mov     esi,0FFFFFFD7h
    25a: call    ryo_h_ZextW8W64
    25f: mov     rax,[rbp-10h]
    263: imul    rcx,[rbp-40h],8
    268: add     rax,rcx
    26b: mov     [rbp-38h],rax
    26f: mov     rax,[rbp+10h]
    273: mov     rcx,[rbp-38h]
    277: mov     [rax+8],rcx
    27b: mov     rax,[rbp+10h]
    27f: mov     rax,[rax+10h]
    283: mov     [rbp-38h],rax
    287: mov     [rbp-20h],rax
    28b: cmp     rax,[rbp+18h]
    28f: je      90h
    295: jmp     70h

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_up::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax]
     17: mov     [rbp-40h],rax
     1b: mov     rax,[rbp+10h]
     1f: mov     rax,[rax+8]
     23: mov     [rbp-48h],rax
     27: mov     rax,[rbp-40h]
     2b: cmp     rax,[rbp-48h]
     2f: je      0DCh
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-18h],rax
     3d: cmp     rax,[rbp+20h]
     41: je      0DCh
     47: mov     rax,[rbp+18h]
     4b: mov     [rbp-50h],rax
     4f: mov     rax,[rbp+10h]
     53: mov     rax,[rax]
     56: mov     [rbp-30h],rax
     5a: mov     [rbp-58h],rax
     5e: mov     rax,[rbp-50h]
     62: mov     [rbp-48h],rax
     66: mov     rax,[rbp-58h]
     6a: mov     [rbp-40h],rax
     6e: mov     rax,[rbp+28h]
     72: mov     [rbp-0A0h],rax
     79: mov     rax,[rbp-48h]
     7d: mov     [rbp-98h],rax
     84: mov     rax,[rbp-40h]
     88: mov     [rbp-90h],rax
     8f: call    fn0
     94: nop     [rcx-19h]
     9b: movzx   eax,byte ptr [rbp-19h]
     9f: xor     al,1
     a2: mov     [rbp-33h],al
     a5: test    byte ptr [rbp-33h],0FFh
     a9: je      0BCh
     ab: mov     rax,[rbp+10h]
     af: mov     rax,[rax]
     b2: mov     [rbp-40h],rax
     b6: mov     [rbp-28h],rax
     ba: jmp     0C4h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-28h],rax
     c4: mov     rax,[rbp+10h]
     c8: mov     rax,[rax+10h]
     cc: mov     [rbp-40h],rax
     d0: mov     byte ptr [rbp-59h],1
     d4: test    byte ptr [rbp-59h],0FFh
     d8: je      148h
     da: jmp     0E7h
     dc: xor     edi,edi
     de: xor     esi,esi
     e0: call    ryo_h_Ret
     e5: leave
     e6: ret
     e7: mov     rax,[rbp-28h]
     eb: mov     [rbp-48h],rax
     ef: mov     rax,[rbp-40h]
     f3: mov     [rbp-50h],rax
     f7: mov     rax,[rbp-48h]
     fb: mov     [rbp-0A0h],rax
    102: mov     rax,[rbp-50h]
    106: mov     [rbp-98h],rax
    10d: mov     qword ptr [rbp-90h],8
    118: mov     qword ptr [rbp-88h],4
    123: mov     qword ptr [rbp-80h],1
    12b: mov     edi,0FFFFFF88h
    130: lea     rsi,[k1]
    137: call    ryo_h_AddrAbs
    13c: call    fn2
    141: nop     [rcx-30h]
    148: mov     qword ptr [rbp-60h],1
    150: imul    rax,[rbp-60h],8
    155: mov     [rbp-68h],rax
    159: mov     edi,0FFFFFFC0h
    15e: mov     esi,0FFFFFFD8h
    163: mov     edx,0FFFFFF98h
    168: call    ryo_h_Memcpy
    16d: mov     rax,[rbp+10h]
    171: mov     rax,[rax]
    174: mov     [rbp-48h],rax
    178: mov     edi,0FFFFFFB0h
    17d: mov     esi,0FFFFFFCDh
    182: call    ryo_h_ZextW8W64
    187: mov     rax,[rbp-48h]
    18b: imul    rcx,[rbp-50h],8
    190: add     rax,rcx
    193: mov     [rbp-40h],rax
    197: mov     rax,[rbp+10h]
    19b: mov     rcx,[rbp-40h]
    19f: mov     [rax],rcx
    1a2: mov     edi,0FFFFFFB8h
    1a7: mov     esi,0FFFFFFE7h
    1ac: call    ryo_h_ZextW8W64
    1b1: mov     rax,[rbp+18h]
    1b5: imul    rcx,[rbp-48h],8
    1ba: add     rax,rcx
    1bd: mov     [rbp-40h],rax
    1c1: mov     [rbp+18h],rax
    1c5: mov     rax,[rbp+10h]
    1c9: mov     rax,[rax+10h]
    1cd: mov     [rbp-48h],rax
    1d1: mov     qword ptr [rbp-60h],1
    1d9: imul    rcx,[rbp-60h],8
    1de: add     rax,rcx
    1e1: mov     [rbp-40h],rax
    1e5: mov     rax,[rbp+10h]
    1e9: mov     rcx,[rbp-40h]
    1ed: mov     [rax+10h],rcx
    1f1: jmp     10h

fn core::slice::sort::stable::merge::merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: cmp     qword ptr [rbp+30h],0
     18: je      60h
     1a: mov     rax,[rbp+30h]
     1e: cmp     rax,[rbp-48h]
     22: jae     60h
     24: mov     rax,[rbp+28h]
     28: mov     [rbp-58h],rax
     2c: mov     rax,[rbp-48h]
     30: sub     rax,[rbp+30h]
     34: mov     [rbp-8],rax
     38: mov     rax,[rbp+30h]
     3c: mov     [rbp-0D0h],rax
     43: mov     rax,[rbp-8]
     47: mov     [rbp-0C8h],rax
     4e: call    fn0
     53: nop     [rcx-60h]
     5a: jmp     25Ah
     5f: nop
     60: jmp     21Bh
     65: nop     [rax+rax]
     6e: xchg    ax,ax
     70: mov     rax,[rbp+20h]
     74: mov     [rbp-28h],rax
     78: mov     rax,[rbp+28h]
     7c: mov     [rbp-20h],rax
     80: mov     rax,[rbp-28h]
     84: mov     [rbp-58h],rax
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-50h],rax
     90: mov     rax,[rbp+10h]
     94: mov     [rbp-38h],rax
     98: mov     rax,[rbp+18h]
     9c: mov     [rbp-30h],rax
     a0: mov     rax,[rbp-38h]
     a4: mov     [rbp-10h],rax
     a8: imul    rcx,[rbp+30h],8
     ad: add     rax,rcx
     b0: mov     [rbp-58h],rax
     b4: mov     rax,[rbp-10h]
     b8: imul    rcx,[rbp-48h],8
     bd: add     rax,rcx
     c0: mov     [rbp-60h],rax
     c4: mov     rax,[rbp+30h]
     c8: cmp     rax,[rbp-8]
     cc: setbe   [rbp-61h]
     d0: test    byte ptr [rbp-61h],0FFh
     d4: je      0D8h
     d6: jmp     0E0h
     d8: mov     rax,[rbp-58h]
     dc: mov     [rbp-10h],rax
     e0: test    byte ptr [rbp-61h],0FFh
     e4: je      0E8h
     e6: jmp     0F0h
     e8: mov     rax,[rbp-8]
     ec: mov     [rbp+30h],rax
     f0: mov     rax,[rbp-10h]
     f4: mov     [rbp-18h],rax
     f8: mov     [rbp-70h],rax
     fc: mov     rax,[rbp+30h]
    100: mov     [rbp-78h],rax
    104: mov     byte ptr [rbp-99h],1
    10b: test    byte ptr [rbp-99h],0FFh
    112: je      2D7h
    118: jmp     26Dh
    11d: nop     [rax]
    120: lea     rax,[rbp-80h]
    124: mov     [rbp-88h],rax
    12b: mov     rax,[rbp-58h]
    12f: mov     [rbp-90h],rax
    136: mov     rax,[rbp-60h]
    13a: mov     [rbp-98h],rax
    141: mov     rax,[rbp-88h]
    148: mov     [rbp-0D0h],rax
    14f: mov     rax,[rbp-90h]
    156: mov     [rbp-0C8h],rax
    15d: mov     rax,[rbp-98h]
    164: mov     [rbp-0C0h],rax
    16b: mov     rax,[rbp+38h]
    16f: mov     [rbp-0B8h],rax
    176: call    fn1
    17b: nop     [rcx-18h]
    182: jmp     1FDh
    184: nop     [rax+rax]
    18d: nop     [rax]
    190: lea     rax,[rbp-80h]
    194: mov     [rbp-88h],rax
    19b: mov     rax,[rbp-38h]
    19f: mov     [rbp-90h],rax
    1a6: mov     rax,[rbp-28h]
    1aa: mov     [rbp-98h],rax
    1b1: mov     rax,[rbp-88h]
    1b8: mov     [rbp-0D0h],rax
    1bf: mov     rax,[rbp-90h]
    1c6: mov     [rbp-0C8h],rax
    1cd: mov     rax,[rbp-98h]
    1d4: mov     [rbp-0C0h],rax
    1db: mov     rax,[rbp-60h]
    1df: mov     [rbp-0B8h],rax
    1e6: mov     rax,[rbp+38h]
    1ea: mov     [rbp-0B0h],rax
    1f1: call    fn2
    1f6: nop     [rcx-18h]
    1fd: lea     rax,[rbp-80h]
    201: mov     [rbp-0A0h],rax
    208: mov     [rbp-0D0h],rax
    20f: call    fn3
    214: nop     [rcx-0A0h]
    21b: xor     edi,edi
    21d: xor     esi,esi
    21f: call    ryo_h_Ret
    224: leave
    225: ret
    226: nop     [rax+rax]
    22f: nop
    230: lea     rax,[rbp-80h]
    234: mov     [rbp-0A0h],rax
    23b: mov     [rbp-0D0h],rax
    242: call    fn4
    247: nop     [rcx-0A0h]
    24e: mov     edi,0FFFFFFC0h
    253: call    ryo_h_Resume
    258: ud2
    25a: mov     rax,[rbp-58h]
    25e: cmp     rax,[rbp-60h]
    262: jb      60h
    268: jmp     70h
    26d: mov     rax,[rbp-18h]
    271: mov     [rbp-80h],rax
    275: mov     rax,[rbp-28h]
    279: mov     [rbp-88h],rax
    280: mov     rax,[rbp-80h]
    284: mov     [rbp-0D0h],rax
    28b: mov     rax,[rbp-88h]
    292: mov     [rbp-0C8h],rax
    299: mov     qword ptr [rbp-0C0h],8
    2a4: mov     qword ptr [rbp-0B8h],4
    2af: mov     rax,[rbp-78h]
    2b3: mov     [rbp-0B0h],rax
    2ba: mov     edi,0FFFFFF58h
    2bf: lea     rsi,[k5]
    2c6: call    ryo_h_AddrAbs
    2cb: call    fn6
    2d0: nop     [rcx-38h]
    2d7: imul    rax,[rbp-78h],8
    2dc: mov     [rbp-0A0h],rax
    2e3: mov     edi,0FFFFFFB0h
    2e8: mov     esi,0FFFFFF90h
    2ed: mov     edx,0FFFFFF60h
    2f2: call    ryo_h_Memcpy
    2f7: mov     rax,[rbp-50h]
    2fb: imul    rcx,[rbp+30h],8
    300: add     rax,rcx
    303: mov     [rbp-88h],rax
    30a: mov     rax,[rbp-50h]
    30e: mov     [rbp-80h],rax
    312: mov     rax,[rbp-88h]
    319: mov     [rbp-78h],rax
    31d: mov     rax,[rbp-10h]
    321: mov     [rbp-70h],rax
    325: test    byte ptr [rbp-61h],0FFh
    329: je      190h
    32f: jmp     120h
    334: nop     [rax+rax]
    33d: nop     [rax]
    340: lea     rdi,[sym7]
    347: lea     rsi,[site8]
    34e: mov     edx,0FFFFFF60h
    353: call    ryo_h_CallExt
    358: test    rax,rax
    35b: je      368h
    35d: call    rax
    35f: nop     [rcx-98h]
    366: jmp     378h
    368: mov     rdi,rbp
    36b: lea     rsi,[ro+4]
    372: call    qword ptr [sym9]
    378: call    ryo_h_Unreachable
    37d: ud2
    37f: mov     rdi,rax
    382: mov     esi,0FFFFFFC0h
    387: call    ryo_h_Lpad
    38c: jmp     230h
    391: mov     rdi,rax
    394: mov     esi,0FFFFFFC0h
    399: call    ryo_h_Lpad
    39e: jmp     340h

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+18h]
     10: mov     [rbp-20h],rax
     14: mov     byte ptr [rbp-29h],0
     18: test    byte ptr [rbp-29h],0FFh
     1c: je      0AEh
     22: jmp     0A4h
     27: nop     [rax+rax]
     30: mov     rax,[rbp+10h]
     34: mov     rax,[rax]
     37: mov     [rbp-10h],rax
     3b: jmp     4Ch
     3d: nop     [rax]
     40: mov     rax,[rbp+10h]
     44: mov     rax,[rax+18h]
     48: mov     [rbp-10h],rax
     4c: mov     rax,[rbp+10h]
     50: mov     rax,[rax+10h]
     54: mov     [rbp-18h],rax
     58: mov     rax,[rbp-10h]
     5c: imul    rcx,[rbp-18h],8
     61: add     rax,rcx
     64: mov     [rbp-8],rax
     68: mov     rax,[rbp+10h]
     6c: mov     rax,[rax+8]
     70: mov     [rbp-18h],rax
     74: mov     byte ptr [rbp-29h],1
     78: test    byte ptr [rbp-29h],0FFh
     7c: je      11Dh
     82: jmp     0C8h
     84: nop     [rax+rax]
     8d: nop     [rax]
     90: mov     rax,[rbp+10h]
     94: mov     rcx,[rbp-18h]
     98: mov     [rax+18h],rcx
     9c: test    byte ptr [rbp+18h],0FFh
     a0: je      40h
     a2: jmp     30h
     a4: mov     rax,[rbp-20h]
     a8: mov     [rbp-18h],rax
     ac: jmp     90h
     ae: mov     qword ptr [rbp-30h],0FFFFFFFFFFFFFFFFh
     b6: mov     rax,[rbp-20h]
     ba: imul    rcx,[rbp-30h],8
     bf: add     rax,rcx
     c2: mov     [rbp-18h],rax
     c6: jmp     90h
     c8: mov     rax,[rbp-18h]
     cc: mov     [rbp-20h],rax
     d0: mov     rax,[rbp-8]
     d4: mov     [rbp-28h],rax
     d8: mov     rax,[rbp-20h]
     dc: mov     [rbp-70h],rax
     e0: mov     rax,[rbp-28h]
     e4: mov     [rbp-68h],rax
     e8: mov     qword ptr [rbp-60h],8
     f0: mov     qword ptr [rbp-58h],4
     f8: mov     qword ptr [rbp-50h],1
    100: mov     edi,0FFFFFFB8h
    105: lea     rsi,[k0]
    10c: call    ryo_h_AddrAbs
    111: call    fn1
    116: nop     [rcx-10h]
    11d: mov     qword ptr [rbp-30h],1
    125: imul    rax,[rbp-30h],8
    12a: mov     [rbp-38h],rax
    12e: mov     edi,0FFFFFFF8h
    133: mov     esi,0FFFFFFE8h
    138: mov     edx,0FFFFFFC8h
    13d: call    ryo_h_Memcpy
    142: mov     edi,0FFFFFFE8h
    147: mov     esi,18h
    14c: call    ryo_h_ZextW8W64
    151: mov     rax,[rbp+10h]
    155: mov     rax,[rax+10h]
    159: mov     [rbp-30h],rax
    15d: add     rax,[rbp-18h]
    161: mov     [rbp-40h],rax
    165: mov     rax,[rbp+10h]
    169: mov     rcx,[rbp-40h]
    16d: mov     [rax+10h],rcx
    171: mov     rax,[rbp+10h]
    175: mov     rax,[rax+8]
    179: mov     [rbp-20h],rax
    17d: mov     qword ptr [rbp-30h],1
    185: imul    rcx,[rbp-30h],8
    18a: add     rax,rcx
    18d: mov     [rbp-18h],rax
    191: mov     rax,[rbp+10h]
    195: mov     rcx,[rbp-18h]
    199: mov     [rax+8],rcx
    19d: mov     edi,0FFFFFFF8h
    1a2: mov     esi,8
    1a7: call    ryo_h_Ret
    1ac: leave
    1ad: ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-88h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-80h],rax
     23: mov     [rbp-78h],rax
     27: call    fn0
     2c: nop     [rcx-80h]
     33: mov     rax,[rbp-80h]
     37: cmp     rax,[rbp-78h]
     3b: jb      77h
     3d: mov     edi,0FFFFFEF0h
     42: mov     esi,10h
     47: call    ryo_h_MovW128
     4c: mov     edi,0FFFFFF00h
     51: mov     esi,20h
     56: call    ryo_h_MovW128
     5b: mov     rax,[rbp+40h]
     5f: mov     [rbp-0F0h],rax
     66: call    fn1
     6b: nop     [rcx]
     72: jmp     48Bh
     77: mov     eax,[rbp+38h]
     7a: mov     [rbp-70h],eax
     7d: cmp     eax,0
     80: jne     0C0h
     82: mov     edi,0FFFFFEF0h
     87: mov     esi,10h
     8c: call    ryo_h_MovW128
     91: mov     edi,0FFFFFF00h
     96: mov     esi,20h
     9b: call    ryo_h_MovW128
     a0: mov     byte ptr [rbp-0F0h],1
     a7: mov     rax,[rbp+40h]
     ab: mov     [rbp-0E8h],rax
     b2: call    fn2
     b7: nop     [rcx]
     be: jmp     107h
     c0: mov     eax,[rbp+38h]
     c3: sub     eax,1
     c6: mov     [rbp+38h],eax
     c9: mov     rax,[rbp+10h]
     cd: mov     [rbp-90h],rax
     d4: mov     rax,[rbp+18h]
     d8: mov     [rbp-88h],rax
     df: mov     edi,0FFFFFEF0h
     e4: mov     esi,0FFFFFF70h
     e9: call    ryo_h_MovW128
     ee: mov     rax,[rbp+40h]
     f2: mov     [rbp-100h],rax
     f9: call    fn3
     fe: nop     [rcx-80h]
    105: jmp     10Ch
    107: jmp     48Bh
    10c: mov     rax,[rbp+10h]
    110: mov     [rbp-10h],rax
    114: mov     rax,[rbp+18h]
    118: mov     [rbp-8],rax
    11c: mov     [rbp-18h],rax
    120: mov     rax,[rbp-80h]
    124: cmp     rax,[rbp-18h]
    128: jb      18Ch
    12a: mov     [rbp-110h],rax
    131: mov     rax,[rbp-18h]
    135: mov     [rbp-108h],rax
    13c: mov     edi,0FFFFFF00h
    141: lea     rsi,[k4]
    148: call    ryo_h_AddrAbs
    14d: lea     rdi,[sym5]
    154: lea     rsi,[site6]
    15b: mov     edx,0FFFFFF28h
    160: call    ryo_h_CallExt
    165: test    rax,rax
    168: je      175h
    16a: call    rax
    16c: nop     [rcx-0D0h]
    173: jmp     185h
    175: mov     rdi,rbp
    178: lea     rsi,[ro+4]
    17f: call    qword ptr [sym7]
    185: call    ryo_h_Unreachable
    18a: ud2
    18c: mov     rax,[rbp+10h]
    190: imul    rcx,[rbp-80h],8
    195: add     rax,rcx
    198: mov     [rbp-0D8h],rax
    19f: mov     [rbp-98h],rax
    1a6: mov     [rbp-90h],rax
    1ad: mov     rax,[rax]
    1b0: mov     [rbp-88h],rax
    1b7: call    fn8
    1bc: nop     [rcx-69h]
    1c3: jmp     496h
    1c8: mov     rax,[rbp+30h]
    1cc: mov     [rbp-90h],rax
    1d3: mov     rax,[rbp+10h]
    1d7: mov     [rbp-50h],rax
    1db: mov     rax,[rbp+18h]
    1df: mov     [rbp-48h],rax
    1e3: mov     [rbp-58h],rax
    1e7: mov     rax,[rbp-80h]
    1eb: cmp     rax,[rbp-58h]
    1ef: jb      253h
    1f1: mov     [rbp-110h],rax
    1f8: mov     rax,[rbp-58h]
    1fc: mov     [rbp-108h],rax
    203: mov     edi,0FFFFFF00h
    208: lea     rsi,[k9]
    20f: call    ryo_h_AddrAbs
    214: lea     rdi,[sym10]
    21b: lea     rsi,[site11]
    222: mov     edx,0FFFFFF28h
    227: call    ryo_h_CallExt
    22c: test    rax,rax
    22f: je      23Ch
    231: call    rax
    233: nop     [rcx-0D0h]
    23a: jmp     24Ch
    23c: mov     rdi,rbp
    23f: lea     rsi,[ro+4]
    246: call    qword ptr [sym12]
    24c: call    ryo_h_Unreachable
    251: ud2
    253: mov     rax,[rbp+10h]
    257: imul    rcx,[rbp-80h],8
    25c: add     rax,rcx
    25f: mov     [rbp-0D8h],rax
    266: mov     [rbp-0A8h],rax
    26d: mov     rax,[rbp-90h]
    274: mov     [rbp-0A0h],rax
    27b: mov     rax,[rbp-0A8h]
    282: mov     [rbp-98h],rax
    289: mov     rax,[rbp+40h]
    28d: mov     [rbp-110h],rax
    294: mov     rax,[rbp-0A0h]
    29b: mov     [rbp-108h],rax
    2a2: mov     rax,[rbp-98h]
    2a9: mov     [rbp-100h],rax
    2b0: call    fn13
    2b5: nop     [rcx-6Ah]
    2bc: movzx   eax,byte ptr [rbp-6Ah]
    2c0: xor     al,1
    2c3: mov     [rbp-31h],al
    2c6: mov     qword ptr [rbp-68h],0
    2ce: movzx   eax,byte ptr [rbp-31h]
    2d2: mov     [rbp-6Ah],al
    2d5: test    byte ptr [rbp-6Ah],0FFh
    2d9: jne     349h
    2db: nop     [rax+rax]
    2e0: mov     edi,0FFFFFF68h
    2e5: mov     esi,10h
    2ea: call    ryo_h_MovW128
    2ef: mov     edi,0FFFFFEF0h
    2f4: mov     esi,0FFFFFF68h
    2f9: call    ryo_h_MovW128
    2fe: mov     edi,0FFFFFF00h
    303: mov     esi,20h
    308: call    ryo_h_MovW128
    30d: mov     rax,[rbp-80h]
    311: mov     [rbp-0F0h],rax
    318: mov     byte ptr [rbp-0E8h],0
    31f: mov     rax,[rbp+40h]
    323: mov     [rbp-0E0h],rax
    32a: call    fn14
    32f: nop     [rcx-68h]
    336: mov     rax,[rbp-68h]
    33a: mov     [rbp-90h],rax
    341: cmp     rax,0
    345: sete    [rbp-31h]
    349: test    byte ptr [rbp-31h],0FFh
    34d: je      3E2h
    353: mov     edi,0FFFFFF60h
    358: mov     esi,10h
    35d: call    ryo_h_MovW128
    362: mov     rax,[rbp+40h]
    366: mov     [rbp-0B0h],rax
    36d: lea     rax,[rbp-0B0h]
    374: mov     [rbp-0A8h],rax
    37b: mov     edi,0FFFFFEF0h
    380: mov     esi,0FFFFFF60h
    385: call    ryo_h_MovW128
    38a: mov     edi,0FFFFFF00h
    38f: mov     esi,20h
    394: call    ryo_h_MovW128
    399: mov     rax,[rbp-80h]
    39d: mov     [rbp-0F0h],rax
    3a4: mov     byte ptr [rbp-0E8h],1
    3ab: mov     rax,[rbp-0A8h]
    3b2: mov     [rbp-0E0h],rax
    3b9: call    fn15
    3be: nop     [rcx-90h]
    3c5: mov     rax,[rbp+18h]
    3c9: mov     [rbp-98h],rax
    3d0: cmp     rax,[rbp-90h]
    3d7: jb      533h
    3dd: jmp     5ADh
    3e2: mov     edi,0FFFFFEF0h
    3e7: mov     esi,10h
    3ec: call    ryo_h_MovW128
    3f1: mov     rax,[rbp-68h]
    3f5: mov     [rbp-100h],rax
    3fc: mov     edi,0FFFFFF08h
    401: lea     rsi,[k16]
    408: call    ryo_h_AddrAbs
    40d: call    fn17
    412: nop     [rcx-0B8h]
    419: mov     edi,10h
    41e: mov     esi,0FFFFFF48h
    423: call    ryo_h_MovW128
    428: mov     edi,0FFFFFF68h
    42d: mov     esi,0FFFFFF58h
    432: call    ryo_h_MovW128
    437: mov     eax,[rbp+38h]
    43a: mov     [rbp-70h],eax
    43d: mov     edi,0FFFFFEF0h
    442: mov     esi,0FFFFFF68h
    447: call    ryo_h_MovW128
    44c: mov     edi,0FFFFFF00h
    451: mov     esi,20h
    456: call    ryo_h_MovW128
    45b: mov     eax,[rbp-70h]
    45e: mov     [rbp-0E8h],eax
    464: mov     rax,[rbp-28h]
    468: mov     [rbp-0F0h],rax
    46f: mov     rax,[rbp+40h]
    473: mov     [rbp-0E0h],rax
    47a: call    fn18
    47f: nop     [rcx-68h]
    486: jmp     10h
    48b: xor     edi,edi
    48d: xor     esi,esi
    48f: call    ryo_h_Ret
    494: leave
    495: ret
    496: lea     rax,[rbp-88h]
    49d: mov     [rbp-0A0h],rax
    4a4: mov     [rbp-98h],rax
    4ab: mov     [rbp-90h],rax
    4b2: test    byte ptr [rbp-69h],0FFh
    4b6: je      529h
    4b8: jmp     51Ch
    4ba: nop     [rax+rax]
    4c0: mov     byte ptr [rbp-31h],0
    4c4: mov     edi,0FFFFFF2Ch
    4c9: mov     esi,30h
    4ce: xor     edx,edx
    4d0: xor     ecx,ecx
    4d2: xor     r8d,r8d
    4d5: mov     r9d,1
    4db: call    ryo_h_DiscrNicheW64
    4e0: mov     edi,0FFFFFFC0h
    4e5: mov     esi,0FFFFFF2Ch
    4ea: call    ryo_h_ZextW32W64
    4ef: mov     edi,0FFFFFFC0h
    4f4: xor     esi,esi
    4f6: mov     edx,2
    4fb: call    ryo_h_SwitchDenseW64
    500: lea     rcx,[510h]
    507: movsxd  rax,[rcx+rax*4]
    50b: add     rax,rcx
    50e: jmp     rax
    510: .long   637h
    514: .long   1c8h
    518: .long   630h
    51c: mov     rax,[rbp-90h]
    523: mov     [rbp-28h],rax
    527: jmp     4C0h
    529: mov     qword ptr [rbp-28h],0
    531: jmp     4C0h
    533: mov     rax,[rbp-90h]
    53a: mov     [rbp-110h],rax
    541: mov     rax,[rbp-98h]
    548: mov     [rbp-108h],rax
    54f: mov     rax,[rbp-98h]
    556: mov     [rbp-100h],rax
    55d: mov     edi,0FFFFFF08h
    562: lea     rsi,[k19]
    569: call    ryo_h_AddrAbs
    56e: lea     rdi,[sym20]
    575: lea     rsi,[site21]
    57c: mov     edx,0FFFFFF28h
    581: call    ryo_h_CallExt
    586: test    rax,rax
    589: je      596h
    58b: call    rax
    58d: nop     [rcx-69h]
    594: jmp     5A6h
    596: mov     rdi,rbp
    599: lea     rsi,[ro+20]
    5a0: call    qword ptr [sym22]
    5a6: call    ryo_h_Unreachable
    5ab: ud2
    5ad: mov     rax,[rbp-98h]
    5b4: sub     rax,[rbp-90h]
    5bb: mov     [rbp-0A0h],rax
    5c2: mov     rax,[rbp+10h]
    5c6: mov     [rbp-0C0h],rax
    5cd: mov     rax,[rbp+18h]
    5d1: mov     [rbp-0B8h],rax
    5d8: mov     rax,[rbp-0C0h]
    5df: mov     [rbp-0C8h],rax
    5e6: imul    rcx,[rbp-90h],8
    5ee: add     rax,rcx
    5f1: mov     [rbp-0D0h],rax
    5f8: mov     [rbp-0B0h],rax
    5ff: mov     rax,[rbp-0A0h]
    606: mov     [rbp-0A8h],rax
    60d: mov     rax,[rbp-0B0h]
    614: mov     [rbp+10h],rax
    618: mov     rax,[rbp-0A8h]
    61f: mov     [rbp+18h],rax
    623: mov     qword ptr [rbp+30h],0
    62b: jmp     10h
    630: call    ryo_h_Unreachable
    635: ud2
    637: mov     qword ptr [rbp-68h],0
    63f: jmp     2E0h

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+20h]
     17: mov     [rbp-28h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-20h],rax
     23: mov     rax,[rbp-10h]
     27: mov     [rbp-40h],rax
     2b: mov     rax,[rbp-28h]
     2f: mov     [rbp-38h],rax
     33: mov     rax,[rbp-20h]
     37: mov     [rbp-30h],rax
     3b: call    fn0
     40: nop     [rcx-11h]
     47: movzx   eax,byte ptr [rbp-11h]
     4b: xor     al,1
     4e: mov     [rbp-1],al
     51: mov     edi,0FFFFFFFFh
     56: mov     esi,1
     5b: call    ryo_h_Ret
     60: leave
     61: ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,150h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: mov     rax,[rbp+28h]
     1a: mov     [rbp-0A0h],rax
     21: cmp     rax,[rbp-90h]
     28: jae     36h
     2a: mov     byte ptr [rbp-91h],1
     31: jmp     55Dh
     36: mov     rax,[rbp-90h]
     3d: cmp     rax,[rbp+30h]
     41: setbe   [rbp-91h]
     48: test    byte ptr [rbp-91h],0FFh
     4f: je      564h
     55: jmp     55Dh
     5a: nop     [rax+rax]
     60: mov     byte ptr [rbp-109h],1
     67: test    byte ptr [rbp-109h],0FFh
     6e: je      360h
     74: mov     rax,[rbp+30h]
     78: mov     [rbp-0E0h],rax
     7f: mov     [rbp-150h],rax
     86: mov     qword ptr [rbp-148h],3
     91: mov     rdi,rbp
     94: lea     rsi,[ro+4]
     9b: call    qword ptr [sym0]
     a1: jmp     61Fh
     a6: nop     [rax+rax]
     af: nop
     b0: mov     rax,[rbp-0C0h]
     b7: mov     [rbp-0E0h],rax
     be: cmp     rax,[rbp-0D0h]
     c5: jae     360h
     cb: lea     rax,[rbp-0C8h]
     d2: mov     [rbp-0E8h],rax
     d9: mov     rax,[rbp-0C0h]
     e0: mov     [rbp-38h],rax
     e4: mov     [rbp-100h],rax
     eb: mov     rax,[rbp-0A8h]
     f2: mov     [rbp-108h],rax
     f9: mov     rax,[rbp-100h]
    100: mov     [rbp-0F8h],rax
    107: mov     rax,[rbp-108h]
    10e: mov     [rbp-0F0h],rax
    115: mov     rax,[rbp+40h]
    119: mov     [rbp-150h],rax
    120: mov     rax,[rbp-0F8h]
    127: mov     [rbp-148h],rax
    12e: mov     rax,[rbp-0F0h]
    135: mov     [rbp-140h],rax
    13c: call    fn1
    141: nop     [rcx-0D2h]
    148: mov     rax,[rbp-0E8h]
    14f: mov     [rbp-150h],rax
    156: movzx   eax,byte ptr [rbp-0D2h]
    15d: mov     [rbp-148h],al
    163: call    fn2
    168: nop     [rcx-0E0h]
    16f: lea     rax,[rbp-0C8h]
    176: mov     [rbp-0E8h],rax
    17d: mov     rax,[rbp-0C0h]
    184: mov     [rbp-40h],rax
    188: mov     [rbp-100h],rax
    18f: mov     rax,[rbp-0A8h]
    196: mov     [rbp-108h],rax
    19d: mov     rax,[rbp-100h]
    1a4: mov     [rbp-0F8h],rax
    1ab: mov     rax,[rbp-108h]
    1b2: mov     [rbp-0F0h],rax
    1b9: mov     rax,[rbp+40h]
    1bd: mov     [rbp-150h],rax
    1c4: mov     rax,[rbp-0F8h]
    1cb: mov     [rbp-148h],rax
    1d2: mov     rax,[rbp-0F0h]
    1d9: mov     [rbp-140h],rax
    1e0: call    fn3
    1e5: nop     [rcx-0D2h]
    1ec: mov     rax,[rbp-0E8h]
    1f3: mov     [rbp-150h],rax
    1fa: movzx   eax,byte ptr [rbp-0D2h]
    201: mov     [rbp-148h],al
    207: call    fn4
    20c: nop     [rcx-0E0h]
    213: lea     rax,[rbp-0C8h]
    21a: mov     [rbp-0E8h],rax
    221: mov     rax,[rbp-0C0h]
    228: mov     [rbp-48h],rax
    22c: mov     [rbp-100h],rax
    233: mov     rax,[rbp-0A8h]
    23a: mov     [rbp-108h],rax
    241: mov     rax,[rbp-100h]
    248: mov     [rbp-0F8h],rax
    24f: mov     rax,[rbp-108h]
    256: mov     [rbp-0F0h],rax
    25d: mov     rax,[rbp+40h]
    261: mov     [rbp-150h],rax
    268: mov     rax,[rbp-0F8h]
    26f: mov     [rbp-148h],rax
    276: mov     rax,[rbp-0F0h]
    27d: mov     [rbp-140h],rax
    284: call    fn5
    289: nop     [rcx-0D2h]
    290: mov     rax,[rbp-0E8h]
    297: mov     [rbp-150h],rax
    29e: movzx   eax,byte ptr [rbp-0D2h]
    2a5: mov     [rbp-148h],al
    2ab: call    fn6
    2b0: nop     [rcx-0E0h]
    2b7: lea     rax,[rbp-0C8h]
    2be: mov     [rbp-0E8h],rax
    2c5: mov     rax,[rbp-0C0h]
    2cc: mov     [rbp-50h],rax
    2d0: mov     [rbp-100h],rax
    2d7: mov     rax,[rbp-0A8h]
    2de: mov     [rbp-108h],rax
    2e5: mov     rax,[rbp-100h]
    2ec: mov     [rbp-0F8h],rax
    2f3: mov     rax,[rbp-108h]
    2fa: mov     [rbp-0F0h],rax
    301: mov     rax,[rbp+40h]
    305: mov     [rbp-150h],rax
    30c: mov     rax,[rbp-0F8h]
    313: mov     [rbp-148h],rax
    31a: mov     rax,[rbp-0F0h]
    321: mov     [rbp-140h],rax
    328: call    fn7
    32d: nop     [rcx-0D2h]
    334: mov     rax,[rbp-0E8h]
    33b: mov     [rbp-150h],rax
    342: movzx   eax,byte ptr [rbp-0D2h]
    349: mov     [rbp-148h],al
    34f: call    fn8
    354: nop     [rcx-0E0h]
    35b: jmp     0B0h
    360: mov     rax,[rbp+30h]
    364: mov     [rbp-0D8h],rax
    36b: mov     rax,[rbp-98h]
    372: imul    rcx,[rbp-0D8h],8
    37a: add     rax,rcx
    37d: mov     [rbp-0D0h],rax
    384: nop     [rax+rax]
    38d: nop     [rax]
    390: mov     rax,[rbp-0C0h]
    397: mov     [rbp-0E0h],rax
    39e: cmp     rax,[rbp-0D0h]
    3a5: jae     454h
    3ab: lea     rax,[rbp-0C8h]
    3b2: mov     [rbp-0E8h],rax
    3b9: mov     rax,[rbp-0C0h]
    3c0: mov     [rbp-58h],rax
    3c4: mov     [rbp-100h],rax
    3cb: mov     rax,[rbp-0A8h]
    3d2: mov     [rbp-108h],rax
    3d9: mov     rax,[rbp-100h]
    3e0: mov     [rbp-0F8h],rax
    3e7: mov     rax,[rbp-108h]
    3ee: mov     [rbp-0F0h],rax
    3f5: mov     rax,[rbp+40h]
    3f9: mov     [rbp-150h],rax
    400: mov     rax,[rbp-0F8h]
    407: mov     [rbp-148h],rax
    40e: mov     rax,[rbp-0F0h]
    415: mov     [rbp-140h],rax
    41c: call    fn9
    421: nop     [rcx-0D2h]
    428: mov     rax,[rbp-0E8h]
    42f: mov     [rbp-150h],rax
    436: movzx   eax,byte ptr [rbp-0D2h]
    43d: mov     [rbp-148h],al
    443: call    fn10
    448: nop     [rcx-0E0h]
    44f: jmp     390h
    454: mov     rax,[rbp+30h]
    458: cmp     rax,[rbp-90h]
    45f: jne     472h
    461: call    fn11
    466: nop     [rcx-0CAh]
    46d: jmp     63Dh
    472: lea     rax,[rbp-0C8h]
    479: mov     [rbp-0D8h],rax
    480: mov     [rbp-150h],rax
    487: movzx   eax,byte ptr [rbp+38h]
    48b: mov     [rbp-148h],al
    491: call    fn12
    496: nop     [rcx-10h]
    49d: mov     rax,[rbp-90h]
    4a4: mov     [rbp+30h],rax
    4a8: jmp     60h
    4ad: nop     [rax]
    4b0: mov     byte ptr [rbp-109h],1
    4b7: test    byte ptr [rbp-109h],0FFh
    4be: je      6D2h
    4c4: jmp     65Fh
    4c9: nop     [rax]
    4d0: mov     rax,[rbp+10h]
    4d4: mov     [rbp-78h],rax
    4d8: mov     rax,[rbp+18h]
    4dc: mov     [rbp-70h],rax
    4e0: mov     rax,[rbp-78h]
    4e4: mov     [rbp-0D0h],rax
    4eb: mov     rax,[rbp-68h]
    4ef: mov     [rbp-0D8h],rax
    4f6: mov     rax,[rbp-0B8h]
    4fd: mov     [rbp-0E0h],rax
    504: mov     byte ptr [rbp-109h],1
    50b: test    byte ptr [rbp-109h],0FFh
    512: je      778h
    518: jmp     705h
    51d: nop     [rax]
    520: mov     rax,[rbp-20h]
    524: mov     [rbp-0F0h],rax
    52b: mov     rax,[rbp-18h]
    52f: mov     [rbp-0F8h],rax
    536: mov     rax,[rbp-0F0h]
    53d: cmp     rax,[rbp-0F8h]
    544: setb    [rbp-0E1h]
    54b: test    byte ptr [rbp-0E1h],0FFh
    552: je      7ECh
    558: jmp     7CFh
    55d: call    ryo_h_Abort
    562: ud2
    564: mov     rax,[rbp+10h]
    568: mov     [rbp-0A8h],rax
    56f: mov     rax,[rbp+18h]
    573: mov     [rbp-0A0h],rax
    57a: mov     rax,[rbp-0A8h]
    581: mov     [rbp-98h],rax
    588: mov     rax,[rbp+20h]
    58c: mov     [rbp-68h],rax
    590: mov     rax,[rbp+28h]
    594: mov     [rbp-60h],rax
    598: mov     rax,[rbp-68h]
    59c: mov     [rbp-0A8h],rax
    5a3: mov     rax,[rbp-68h]
    5a7: mov     [rbp-0A0h],rax
    5ae: mov     rax,[rbp-98h]
    5b5: imul    rcx,[rbp+30h],8
    5ba: add     rax,rcx
    5bd: mov     [rbp-0A8h],rax
    5c4: mov     rax,[rbp-0A0h]
    5cb: imul    rcx,[rbp-90h],8
    5d3: add     rax,rcx
    5d6: mov     [rbp-0D0h],rax
    5dd: mov     rax,[rbp-0A0h]
    5e4: mov     [rbp-0C8h],rax
    5eb: mov     rax,[rbp-98h]
    5f2: mov     [rbp-0C0h],rax
    5f9: mov     qword ptr [rbp-0B8h],0
    604: mov     rax,[rbp-0D0h]
    60b: mov     [rbp-0B0h],rax
    612: mov     qword ptr [rbp-10h],0
    61a: jmp     60h
    61f: mov     rax,[rbp-98h]
    626: imul    rcx,[rbp-0D8h],8
    62e: add     rax,rcx
    631: mov     [rbp-0D0h],rax
    638: jmp     0B0h
    63d: movzx   eax,byte ptr [rbp-0CAh]
    644: xor     al,1
    647: mov     [rbp-0C9h],al
    64d: test    byte ptr [rbp-0C9h],0FFh
    654: je      4D0h
    65a: jmp     4B0h
    65f: mov     rax,[rbp-0A8h]
    666: mov     [rbp-0D8h],rax
    66d: mov     rax,[rbp-10h]
    671: mov     [rbp-0E0h],rax
    678: mov     rax,[rbp-0D8h]
    67f: mov     [rbp-150h],rax
    686: mov     rax,[rbp-0E0h]
    68d: mov     [rbp-148h],rax
    694: mov     qword ptr [rbp-140h],8
    69f: mov     qword ptr [rbp-138h],4
    6aa: mov     qword ptr [rbp-130h],1
    6b5: mov     edi,0FFFFFED8h
    6ba: lea     rsi,[k13]
    6c1: call    ryo_h_AddrAbs
    6c6: call    fn14
    6cb: nop     [rcx-68h]
    6d2: mov     qword ptr [rbp-110h],1
    6dd: imul    rax,[rbp-110h],8
    6e5: mov     [rbp-118h],rax
    6ec: mov     edi,0FFFFFFF0h
    6f1: mov     esi,0FFFFFF58h
    6f6: mov     edx,0FFFFFEE8h
    6fb: call    ryo_h_Memcpy
    700: jmp     4D0h
    705: mov     rax,[rbp-68h]
    709: mov     [rbp-0E8h],rax
    710: mov     rax,[rbp-78h]
    714: mov     [rbp-0F0h],rax
    71b: mov     rax,[rbp-0E8h]
    722: mov     [rbp-150h],rax
    729: mov     rax,[rbp-0F0h]
    730: mov     [rbp-148h],rax
    737: mov     qword ptr [rbp-140h],8
    742: mov     qword ptr [rbp-138h],4
    74d: mov     rax,[rbp-0E0h]
    754: mov     [rbp-130h],rax
    75b: mov     edi,0FFFFFED8h
    760: lea     rsi,[k15]
    767: call    ryo_h_AddrAbs
    76c: call    fn16
    771: nop     [rcx-78h]
    778: imul    rax,[rbp-0E0h],8
    780: mov     [rbp-110h],rax
    787: mov     edi,0FFFFFF30h
    78c: mov     esi,0FFFFFF28h
    791: mov     edx,0FFFFFEF0h
    796: call    ryo_h_Memcpy
    79b: mov     rax,[rbp-0B8h]
    7a2: mov     [rbp-0E0h],rax
    7a9: mov     rax,[rbp-90h]
    7b0: sub     rax,[rbp-0E0h]
    7b7: mov     [rbp-0D8h],rax
    7be: mov     qword ptr [rbp-20h],0
    7c6: mov     [rbp-18h],rax
    7ca: jmp     520h
    7cf: mov     rax,[rbp-20h]
    7d3: mov     [rbp-0F0h],rax
    7da: mov     byte ptr [rbp-109h],1
    7e1: test    byte ptr [rbp-109h],0FFh
    7e8: je      83Eh
    7ea: jmp     808h
    7ec: mov     rax,[rbp-0B8h]
    7f3: mov     [rbp-8],rax
    7f7: mov     edi,0FFFFFFF8h
    7fc: mov     esi,8
    801: call    ryo_h_Ret
    806: leave
    807: ret
    808: mov     rax,[rbp-0F0h]
    80f: mov     [rbp-150h],rax
    816: mov     qword ptr [rbp-148h],1
    821: mov     edi,0FFFFFEC0h
    826: lea     rsi,[k17]
    82d: call    ryo_h_AddrAbs
    832: call    fn18
    837: nop     [rcx-88h]
    83e: mov     rax,[rbp-0F0h]
    845: add     rax,1
    849: mov     [rbp-0F8h],rax
    850: mov     [rbp-20h],rax
    854: mov     rax,[rbp-0F0h]
    85b: mov     [rbp-0D8h],rax
    862: mov     qword ptr [rbp-0E0h],1
    86d: mov     [rbp-0E8h],rax
    874: mov     rax,[rbp-90h]
    87b: sub     rax,1
    87f: mov     [rbp-100h],rax
    886: sub     rax,[rbp-0E8h]
    88d: mov     [rbp-0F8h],rax
    894: mov     rax,[rbp-0A0h]
    89b: imul    rcx,[rbp-0F8h],8
    8a3: add     rax,rcx
    8a6: mov     [rbp-30h],rax
    8aa: mov     [rbp-0F0h],rax
    8b1: mov     rax,[rbp-0B8h]
    8b8: mov     [rbp-108h],rax
    8bf: add     rax,[rbp-0E8h]
    8c6: mov     [rbp-100h],rax
    8cd: mov     rax,[rbp-0D0h]
    8d4: imul    rcx,[rbp-100h],8
    8dc: add     rax,rcx
    8df: mov     [rbp-0F8h],rax
    8e6: mov     byte ptr [rbp-109h],1
    8ed: test    byte ptr [rbp-109h],0FFh
    8f4: je      969h
    8f6: mov     rax,[rbp-30h]
    8fa: mov     [rbp-100h],rax
    901: mov     rax,[rbp-0F8h]
    908: mov     [rbp-108h],rax
    90f: mov     rax,[rbp-100h]
    916: mov     [rbp-150h],rax
    91d: mov     rax,[rbp-108h]
    924: mov     [rbp-148h],rax
    92b: mov     qword ptr [rbp-140h],8
    936: mov     qword ptr [rbp-138h],4
    941: mov     qword ptr [rbp-130h],1
    94c: mov     edi,0FFFFFED8h
    951: lea     rsi,[k19]
    958: call    ryo_h_AddrAbs
    95d: call    fn20
    962: nop     [rcx-88h]
    969: mov     qword ptr [rbp-110h],1
    974: imul    rax,[rbp-110h],8
    97c: mov     [rbp-118h],rax
    983: mov     edi,0FFFFFF08h
    988: mov     esi,0FFFFFF10h
    98d: mov     edx,0FFFFFEE8h
    992: call    ryo_h_Memcpy
    997: jmp     520h

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,150h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: mov     rax,[rbp+28h]
     1a: mov     [rbp-0A0h],rax
     21: cmp     rax,[rbp-90h]
     28: jae     36h
     2a: mov     byte ptr [rbp-91h],1
     31: jmp     55Dh
     36: mov     rax,[rbp-90h]
     3d: cmp     rax,[rbp+30h]
     41: setbe   [rbp-91h]
     48: test    byte ptr [rbp-91h],0FFh
     4f: je      564h
     55: jmp     55Dh
     5a: nop     [rax+rax]
     60: mov     byte ptr [rbp-109h],1
     67: test    byte ptr [rbp-109h],0FFh
     6e: je      360h
     74: mov     rax,[rbp+30h]
     78: mov     [rbp-0E0h],rax
     7f: mov     [rbp-150h],rax
     86: mov     qword ptr [rbp-148h],3
     91: mov     rdi,rbp
     94: lea     rsi,[ro+4]
     9b: call    qword ptr [sym0]
     a1: jmp     61Fh
     a6: nop     [rax+rax]
     af: nop
     b0: mov     rax,[rbp-0C0h]
     b7: mov     [rbp-0E0h],rax
     be: cmp     rax,[rbp-0D0h]
     c5: jae     360h
     cb: lea     rax,[rbp-0C8h]
     d2: mov     [rbp-0E8h],rax
     d9: mov     rax,[rbp-0C0h]
     e0: mov     [rbp-38h],rax
     e4: mov     [rbp-100h],rax
     eb: mov     rax,[rbp-0A8h]
     f2: mov     [rbp-108h],rax
     f9: mov     rax,[rbp-100h]
    100: mov     [rbp-0F8h],rax
    107: mov     rax,[rbp-108h]
    10e: mov     [rbp-0F0h],rax
    115: mov     rax,[rbp+40h]
    119: mov     [rbp-150h],rax
    120: mov     rax,[rbp-0F8h]
    127: mov     [rbp-148h],rax
    12e: mov     rax,[rbp-0F0h]
    135: mov     [rbp-140h],rax
    13c: call    fn1
    141: nop     [rcx-0D2h]
    148: mov     rax,[rbp-0E8h]
    14f: mov     [rbp-150h],rax
    156: movzx   eax,byte ptr [rbp-0D2h]
    15d: mov     [rbp-148h],al
    163: call    fn2
    168: nop     [rcx-0E0h]
    16f: lea     rax,[rbp-0C8h]
    176: mov     [rbp-0E8h],rax
    17d: mov     rax,[rbp-0C0h]
    184: mov     [rbp-40h],rax
    188: mov     [rbp-100h],rax
    18f: mov     rax,[rbp-0A8h]
    196: mov     [rbp-108h],rax
    19d: mov     rax,[rbp-100h]
    1a4: mov     [rbp-0F8h],rax
    1ab: mov     rax,[rbp-108h]
    1b2: mov     [rbp-0F0h],rax
    1b9: mov     rax,[rbp+40h]
    1bd: mov     [rbp-150h],rax
    1c4: mov     rax,[rbp-0F8h]
    1cb: mov     [rbp-148h],rax
    1d2: mov     rax,[rbp-0F0h]
    1d9: mov     [rbp-140h],rax
    1e0: call    fn3
    1e5: nop     [rcx-0D2h]
    1ec: mov     rax,[rbp-0E8h]
    1f3: mov     [rbp-150h],rax
    1fa: movzx   eax,byte ptr [rbp-0D2h]
    201: mov     [rbp-148h],al
    207: call    fn4
    20c: nop     [rcx-0E0h]
    213: lea     rax,[rbp-0C8h]
    21a: mov     [rbp-0E8h],rax
    221: mov     rax,[rbp-0C0h]
    228: mov     [rbp-48h],rax
    22c: mov     [rbp-100h],rax
    233: mov     rax,[rbp-0A8h]
    23a: mov     [rbp-108h],rax
    241: mov     rax,[rbp-100h]
    248: mov     [rbp-0F8h],rax
    24f: mov     rax,[rbp-108h]
    256: mov     [rbp-0F0h],rax
    25d: mov     rax,[rbp+40h]
    261: mov     [rbp-150h],rax
    268: mov     rax,[rbp-0F8h]
    26f: mov     [rbp-148h],rax
    276: mov     rax,[rbp-0F0h]
    27d: mov     [rbp-140h],rax
    284: call    fn5
    289: nop     [rcx-0D2h]
    290: mov     rax,[rbp-0E8h]
    297: mov     [rbp-150h],rax
    29e: movzx   eax,byte ptr [rbp-0D2h]
    2a5: mov     [rbp-148h],al
    2ab: call    fn6
    2b0: nop     [rcx-0E0h]
    2b7: lea     rax,[rbp-0C8h]
    2be: mov     [rbp-0E8h],rax
    2c5: mov     rax,[rbp-0C0h]
    2cc: mov     [rbp-50h],rax
    2d0: mov     [rbp-100h],rax
    2d7: mov     rax,[rbp-0A8h]
    2de: mov     [rbp-108h],rax
    2e5: mov     rax,[rbp-100h]
    2ec: mov     [rbp-0F8h],rax
    2f3: mov     rax,[rbp-108h]
    2fa: mov     [rbp-0F0h],rax
    301: mov     rax,[rbp+40h]
    305: mov     [rbp-150h],rax
    30c: mov     rax,[rbp-0F8h]
    313: mov     [rbp-148h],rax
    31a: mov     rax,[rbp-0F0h]
    321: mov     [rbp-140h],rax
    328: call    fn7
    32d: nop     [rcx-0D2h]
    334: mov     rax,[rbp-0E8h]
    33b: mov     [rbp-150h],rax
    342: movzx   eax,byte ptr [rbp-0D2h]
    349: mov     [rbp-148h],al
    34f: call    fn8
    354: nop     [rcx-0E0h]
    35b: jmp     0B0h
    360: mov     rax,[rbp+30h]
    364: mov     [rbp-0D8h],rax
    36b: mov     rax,[rbp-98h]
    372: imul    rcx,[rbp-0D8h],8
    37a: add     rax,rcx
    37d: mov     [rbp-0D0h],rax
    384: nop     [rax+rax]
    38d: nop     [rax]
    390: mov     rax,[rbp-0C0h]
    397: mov     [rbp-0E0h],rax
    39e: cmp     rax,[rbp-0D0h]
    3a5: jae     454h
    3ab: lea     rax,[rbp-0C8h]
    3b2: mov     [rbp-0E8h],rax
    3b9: mov     rax,[rbp-0C0h]
    3c0: mov     [rbp-58h],rax
    3c4: mov     [rbp-100h],rax
    3cb: mov     rax,[rbp-0A8h]
    3d2: mov     [rbp-108h],rax
    3d9: mov     rax,[rbp-100h]
    3e0: mov     [rbp-0F8h],rax
    3e7: mov     rax,[rbp-108h]
    3ee: mov     [rbp-0F0h],rax
    3f5: mov     rax,[rbp+40h]
    3f9: mov     [rbp-150h],rax
    400: mov     rax,[rbp-0F8h]
    407: mov     [rbp-148h],rax
    40e: mov     rax,[rbp-0F0h]
    415: mov     [rbp-140h],rax
    41c: call    fn9
    421: nop     [rcx-0D2h]
    428: mov     rax,[rbp-0E8h]
    42f: mov     [rbp-150h],rax
    436: movzx   eax,byte ptr [rbp-0D2h]
    43d: mov     [rbp-148h],al
    443: call    fn10
    448: nop     [rcx-0E0h]
    44f: jmp     390h
    454: mov     rax,[rbp+30h]
    458: cmp     rax,[rbp-90h]
    45f: jne     472h
    461: call    fn11
    466: nop     [rcx-0CAh]
    46d: jmp     63Dh
    472: lea     rax,[rbp-0C8h]
    479: mov     [rbp-0D8h],rax
    480: mov     [rbp-150h],rax
    487: movzx   eax,byte ptr [rbp+38h]
    48b: mov     [rbp-148h],al
    491: call    fn12
    496: nop     [rcx-10h]
    49d: mov     rax,[rbp-90h]
    4a4: mov     [rbp+30h],rax
    4a8: jmp     60h
    4ad: nop     [rax]
    4b0: mov     byte ptr [rbp-109h],1
    4b7: test    byte ptr [rbp-109h],0FFh
    4be: je      6D2h
    4c4: jmp     65Fh
    4c9: nop     [rax]
    4d0: mov     rax,[rbp+10h]
    4d4: mov     [rbp-78h],rax
    4d8: mov     rax,[rbp+18h]
    4dc: mov     [rbp-70h],rax
    4e0: mov     rax,[rbp-78h]
    4e4: mov     [rbp-0D0h],rax
    4eb: mov     rax,[rbp-68h]
    4ef: mov     [rbp-0D8h],rax
    4f6: mov     rax,[rbp-0B8h]
    4fd: mov     [rbp-0E0h],rax
    504: mov     byte ptr [rbp-109h],1
    50b: test    byte ptr [rbp-109h],0FFh
    512: je      778h
    518: jmp     705h
    51d: nop     [rax]
    520: mov     rax,[rbp-20h]
    524: mov     [rbp-0F0h],rax
    52b: mov     rax,[rbp-18h]
    52f: mov     [rbp-0F8h],rax
    536: mov     rax,[rbp-0F0h]
    53d: cmp     rax,[rbp-0F8h]
    544: setb    [rbp-0E1h]
    54b: test    byte ptr [rbp-0E1h],0FFh
    552: je      7ECh
    558: jmp     7CFh
    55d: call    ryo_h_Abort
    562: ud2
    564: mov     rax,[rbp+10h]
    568: mov     [rbp-0A8h],rax
    56f: mov     rax,[rbp+18h]
    573: mov     [rbp-0A0h],rax
    57a: mov     rax,[rbp-0A8h]
    581: mov     [rbp-98h],rax
    588: mov     rax,[rbp+20h]
    58c: mov     [rbp-68h],rax
    590: mov     rax,[rbp+28h]
    594: mov     [rbp-60h],rax
    598: mov     rax,[rbp-68h]
    59c: mov     [rbp-0A8h],rax
    5a3: mov     rax,[rbp-68h]
    5a7: mov     [rbp-0A0h],rax
    5ae: mov     rax,[rbp-98h]
    5b5: imul    rcx,[rbp+30h],8
    5ba: add     rax,rcx
    5bd: mov     [rbp-0A8h],rax
    5c4: mov     rax,[rbp-0A0h]
    5cb: imul    rcx,[rbp-90h],8
    5d3: add     rax,rcx
    5d6: mov     [rbp-0D0h],rax
    5dd: mov     rax,[rbp-0A0h]
    5e4: mov     [rbp-0C8h],rax
    5eb: mov     rax,[rbp-98h]
    5f2: mov     [rbp-0C0h],rax
    5f9: mov     qword ptr [rbp-0B8h],0
    604: mov     rax,[rbp-0D0h]
    60b: mov     [rbp-0B0h],rax
    612: mov     qword ptr [rbp-10h],0
    61a: jmp     60h
    61f: mov     rax,[rbp-98h]
    626: imul    rcx,[rbp-0D8h],8
    62e: add     rax,rcx
    631: mov     [rbp-0D0h],rax
    638: jmp     0B0h
    63d: movzx   eax,byte ptr [rbp-0CAh]
    644: xor     al,1
    647: mov     [rbp-0C9h],al
    64d: test    byte ptr [rbp-0C9h],0FFh
    654: je      4D0h
    65a: jmp     4B0h
    65f: mov     rax,[rbp-0A8h]
    666: mov     [rbp-0D8h],rax
    66d: mov     rax,[rbp-10h]
    671: mov     [rbp-0E0h],rax
    678: mov     rax,[rbp-0D8h]
    67f: mov     [rbp-150h],rax
    686: mov     rax,[rbp-0E0h]
    68d: mov     [rbp-148h],rax
    694: mov     qword ptr [rbp-140h],8
    69f: mov     qword ptr [rbp-138h],4
    6aa: mov     qword ptr [rbp-130h],1
    6b5: mov     edi,0FFFFFED8h
    6ba: lea     rsi,[k13]
    6c1: call    ryo_h_AddrAbs
    6c6: call    fn14
    6cb: nop     [rcx-68h]
    6d2: mov     qword ptr [rbp-110h],1
    6dd: imul    rax,[rbp-110h],8
    6e5: mov     [rbp-118h],rax
    6ec: mov     edi,0FFFFFFF0h
    6f1: mov     esi,0FFFFFF58h
    6f6: mov     edx,0FFFFFEE8h
    6fb: call    ryo_h_Memcpy
    700: jmp     4D0h
    705: mov     rax,[rbp-68h]
    709: mov     [rbp-0E8h],rax
    710: mov     rax,[rbp-78h]
    714: mov     [rbp-0F0h],rax
    71b: mov     rax,[rbp-0E8h]
    722: mov     [rbp-150h],rax
    729: mov     rax,[rbp-0F0h]
    730: mov     [rbp-148h],rax
    737: mov     qword ptr [rbp-140h],8
    742: mov     qword ptr [rbp-138h],4
    74d: mov     rax,[rbp-0E0h]
    754: mov     [rbp-130h],rax
    75b: mov     edi,0FFFFFED8h
    760: lea     rsi,[k15]
    767: call    ryo_h_AddrAbs
    76c: call    fn16
    771: nop     [rcx-78h]
    778: imul    rax,[rbp-0E0h],8
    780: mov     [rbp-110h],rax
    787: mov     edi,0FFFFFF30h
    78c: mov     esi,0FFFFFF28h
    791: mov     edx,0FFFFFEF0h
    796: call    ryo_h_Memcpy
    79b: mov     rax,[rbp-0B8h]
    7a2: mov     [rbp-0E0h],rax
    7a9: mov     rax,[rbp-90h]
    7b0: sub     rax,[rbp-0E0h]
    7b7: mov     [rbp-0D8h],rax
    7be: mov     qword ptr [rbp-20h],0
    7c6: mov     [rbp-18h],rax
    7ca: jmp     520h
    7cf: mov     rax,[rbp-20h]
    7d3: mov     [rbp-0F0h],rax
    7da: mov     byte ptr [rbp-109h],1
    7e1: test    byte ptr [rbp-109h],0FFh
    7e8: je      83Eh
    7ea: jmp     808h
    7ec: mov     rax,[rbp-0B8h]
    7f3: mov     [rbp-8],rax
    7f7: mov     edi,0FFFFFFF8h
    7fc: mov     esi,8
    801: call    ryo_h_Ret
    806: leave
    807: ret
    808: mov     rax,[rbp-0F0h]
    80f: mov     [rbp-150h],rax
    816: mov     qword ptr [rbp-148h],1
    821: mov     edi,0FFFFFEC0h
    826: lea     rsi,[k17]
    82d: call    ryo_h_AddrAbs
    832: call    fn18
    837: nop     [rcx-88h]
    83e: mov     rax,[rbp-0F0h]
    845: add     rax,1
    849: mov     [rbp-0F8h],rax
    850: mov     [rbp-20h],rax
    854: mov     rax,[rbp-0F0h]
    85b: mov     [rbp-0D8h],rax
    862: mov     qword ptr [rbp-0E0h],1
    86d: mov     [rbp-0E8h],rax
    874: mov     rax,[rbp-90h]
    87b: sub     rax,1
    87f: mov     [rbp-100h],rax
    886: sub     rax,[rbp-0E8h]
    88d: mov     [rbp-0F8h],rax
    894: mov     rax,[rbp-0A0h]
    89b: imul    rcx,[rbp-0F8h],8
    8a3: add     rax,rcx
    8a6: mov     [rbp-30h],rax
    8aa: mov     [rbp-0F0h],rax
    8b1: mov     rax,[rbp-0B8h]
    8b8: mov     [rbp-108h],rax
    8bf: add     rax,[rbp-0E8h]
    8c6: mov     [rbp-100h],rax
    8cd: mov     rax,[rbp-0D0h]
    8d4: imul    rcx,[rbp-100h],8
    8dc: add     rax,rcx
    8df: mov     [rbp-0F8h],rax
    8e6: mov     byte ptr [rbp-109h],1
    8ed: test    byte ptr [rbp-109h],0FFh
    8f4: je      969h
    8f6: mov     rax,[rbp-30h]
    8fa: mov     [rbp-100h],rax
    901: mov     rax,[rbp-0F8h]
    908: mov     [rbp-108h],rax
    90f: mov     rax,[rbp-100h]
    916: mov     [rbp-150h],rax
    91d: mov     rax,[rbp-108h]
    924: mov     [rbp-148h],rax
    92b: mov     qword ptr [rbp-140h],8
    936: mov     qword ptr [rbp-138h],4
    941: mov     qword ptr [rbp-130h],1
    94c: mov     edi,0FFFFFED8h
    951: lea     rsi,[k19]
    958: call    ryo_h_AddrAbs
    95d: call    fn20
    962: nop     [rcx-88h]
    969: mov     qword ptr [rbp-110h],1
    974: imul    rax,[rbp-110h],8
    97c: mov     [rbp-118h],rax
    983: mov     edi,0FFFFFF08h
    988: mov     esi,0FFFFFF10h
    98d: mov     edx,0FFFFFEE8h
    992: call    ryo_h_Memcpy
    997: jmp     520h

fn core::slice::sort::unstable::heapsort::heapsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     qword ptr [rbp-0A8h],2
     1e: mov     edi,0FFFFFF98h
     23: mov     esi,0FFFFFFB8h
     28: mov     edx,0FFFFFF58h
     2d: call    ryo_h_DivUW64
     32: mov     rax,[rbp-48h]
     36: add     rax,[rbp-68h]
     3a: mov     [rbp-60h],rax
     3e: mov     qword ptr [rbp-58h],0
     46: mov     [rbp-50h],rax
     4a: mov     edi,0FFFFFFF0h
     4f: mov     esi,0FFFFFFA8h
     54: call    ryo_h_MovW128
     59: nop     [rax]
     60: mov     rax,[rbp-10h]
     64: mov     [rbp-68h],rax
     68: mov     rax,[rbp-8]
     6c: mov     [rbp-70h],rax
     70: mov     rax,[rbp-68h]
     74: cmp     rax,[rbp-70h]
     78: setb    [rbp-59h]
     7c: test    byte ptr [rbp-59h],0FFh
     80: je      18Fh
     86: jmp     175h
     8b: nop     [rax+rax]
     90: mov     rax,[rbp-60h]
     94: sub     rax,[rbp-48h]
     98: mov     [rbp-20h],rax
     9c: jmp     140h
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: mov     qword ptr [rbp-0A8h],0
     bb: mov     rax,[rbp-0A8h]
     c2: cmp     rax,[rbp-48h]
     c6: setb    [rbp-62h]
     ca: test    byte ptr [rbp-62h],0FFh
     ce: jne     20Dh
     d4: mov     qword ptr [rbp-0D0h],0
     df: mov     rax,[rbp-48h]
     e3: mov     [rbp-0C8h],rax
     ea: mov     edi,0FFFFFF40h
     ef: lea     rsi,[k0]
     f6: call    ryo_h_AddrAbs
     fb: lea     rdi,[sym1]
    102: lea     rsi,[site2]
    109: mov     edx,0FFFFFF58h
    10e: call    ryo_h_CallExt
    113: test    rax,rax
    116: je      123h
    118: call    rax
    11a: nop     [rcx-0A0h]
    121: jmp     133h
    123: mov     rdi,rbp
    126: lea     rsi,[ro+4]
    12d: call    qword ptr [sym3]
    133: call    ryo_h_Unreachable
    138: ud2
    13a: nop     [rax+rax]
    140: mov     rax,[rbp-60h]
    144: mov     [rbp-0D0h],rax
    14b: mov     rax,[rbp-48h]
    14f: mov     [rbp-0C8h],rax
    156: call    fn4
    15b: nop     [rcx-28h]
    162: jmp     2C0h
    167: nop     [rax+rax]
    170: jmp     60h
    175: mov     rax,[rbp-8]
    179: mov     [rbp-70h],rax
    17d: mov     byte ptr [rbp-0A1h],1
    184: test    byte ptr [rbp-0A1h],0FFh
    18b: je      1CDh
    18d: jmp     19Ah
    18f: xor     edi,edi
    191: xor     esi,esi
    193: call    ryo_h_Ret
    198: leave
    199: ret
    19a: mov     rax,[rbp-70h]
    19e: mov     [rbp-0D0h],rax
    1a5: mov     qword ptr [rbp-0C8h],1
    1b0: mov     edi,0FFFFFF40h
    1b5: lea     rsi,[k5]
    1bc: call    ryo_h_AddrAbs
    1c1: call    fn6
    1c6: nop     [rcx-40h]
    1cd: mov     rax,[rbp-70h]
    1d1: sub     rax,1
    1d5: mov     [rbp-68h],rax
    1d9: mov     [rbp-8],rax
    1dd: mov     [rbp-68h],rax
    1e1: mov     [rbp-50h],rax
    1e5: mov     qword ptr [rbp-58h],1
    1ed: mov     [rbp-60h],rax
    1f1: cmp     rax,[rbp-48h]
    1f5: jae     90h
    1fb: jmp     0B0h
    200: mov     qword ptr [rbp-20h],0
    208: jmp     140h
    20d: mov     rax,[rbp-60h]
    211: cmp     rax,[rbp-48h]
    215: jb      279h
    217: mov     [rbp-0D0h],rax
    21e: mov     rax,[rbp-48h]
    222: mov     [rbp-0C8h],rax
    229: mov     edi,0FFFFFF40h
    22e: lea     rsi,[k7]
    235: call    ryo_h_AddrAbs
    23a: lea     rdi,[sym8]
    241: lea     rsi,[site9]
    248: mov     edx,0FFFFFF58h
    24d: call    ryo_h_CallExt
    252: test    rax,rax
    255: je      262h
    257: call    rax
    259: nop     [rcx-0A0h]
    260: jmp     272h
    262: mov     rdi,rbp
    265: lea     rsi,[ro+4]
    26c: call    qword ptr [sym10]
    272: call    ryo_h_Unreachable
    277: ud2
    279: mov     edi,0FFFFFF30h
    27e: mov     esi,10h
    283: call    ryo_h_MovW128
    288: mov     qword ptr [rbp-0C0h],0
    293: mov     rax,[rbp-60h]
    297: mov     [rbp-0B8h],rax
    29e: mov     edi,0FFFFFF50h
    2a3: lea     rsi,[k11]
    2aa: call    ryo_h_AddrAbs
    2af: call    fn12
    2b4: nop     [rcx-40h]
    2bb: jmp     200h
    2c0: cmp     qword ptr [rbp-28h],0
    2c5: jb      3C1h
    2cb: jmp     3C3h
    2d0: mov     rax,[rbp+10h]
    2d4: mov     [rbp-98h],rax
    2db: mov     rax,[rbp+18h]
    2df: mov     [rbp-90h],rax
    2e6: mov     rax,[rbp-98h]
    2ed: mov     [rbp-0A0h],rax
    2f4: mov     [rbp-88h],rax
    2fb: mov     rax,[rbp-28h]
    2ff: mov     [rbp-80h],rax
    303: mov     rax,[rbp-88h]
    30a: mov     [rbp-70h],rax
    30e: mov     rax,[rbp-80h]
    312: mov     [rbp-68h],rax
    316: mov     edi,0FFFFFF30h
    31b: mov     esi,0FFFFFF90h
    320: call    ryo_h_MovW128
    325: mov     rax,[rbp-20h]
    329: mov     [rbp-0C0h],rax
    330: mov     rax,[rbp+20h]
    334: mov     [rbp-0B8h],rax
    33b: call    fn13
    340: nop     [rcx-20h]
    347: jmp     170h
    34c: nop     [rax]
    350: mov     qword ptr [rbp-0D0h],0
    35b: mov     rax,[rbp-28h]
    35f: mov     [rbp-0C8h],rax
    366: mov     rax,[rbp-48h]
    36a: mov     [rbp-0C0h],rax
    371: mov     edi,0FFFFFF48h
    376: lea     rsi,[k14]
    37d: call    ryo_h_AddrAbs
    382: lea     rdi,[sym15]
    389: lea     rsi,[site16]
    390: mov     edx,0FFFFFF58h
    395: call    ryo_h_CallExt
    39a: test    rax,rax
    39d: je      3AAh
    39f: call    rax
    3a1: nop     [rcx-40h]
    3a8: jmp     3BAh
    3aa: mov     rdi,rbp
    3ad: lea     rsi,[ro+20]
    3b4: call    qword ptr [sym17]
    3ba: call    ryo_h_Unreachable
    3bf: ud2
    3c1: jmp     350h
    3c3: mov     rax,[rbp-48h]
    3c7: cmp     rax,[rbp-28h]
    3cb: jae     2D0h
    3d1: jmp     350h

fn core::slice::sort::unstable::heapsort::sift_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-20h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-8],rax
     1b: mov     rax,[rbp-20h]
     1f: cmp     rax,[rbp-8]
     23: setbe   [rbp-11h]
     27: mov     rax,[rbp+10h]
     2b: mov     [rbp-28h],rax
     2f: mov     rax,[rbp+18h]
     33: mov     [rbp-20h],rax
     37: mov     rax,[rbp-28h]
     3b: mov     [rbp-18h],rax
     3f: nop
     40: mov     rax,[rbp+20h]
     44: mov     [rbp-28h],rax
     48: mov     qword ptr [rbp-70h],2
     50: mov     rax,[rbp-70h]
     54: imul    rax,[rbp-28h]
     59: mov     [rbp-20h],rax
     5d: add     rax,1
     61: mov     [rbp-10h],rax
     65: mov     [rbp-28h],rax
     69: cmp     rax,[rbp-8]
     6d: jb      74h
     6f: jmp     1D5h
     74: mov     rax,[rbp-10h]
     78: mov     [rbp-30h],rax
     7c: add     rax,1
     80: mov     [rbp-28h],rax
     84: cmp     rax,[rbp-8]
     88: jae     109h
     8a: mov     rax,[rbp-10h]
     8e: mov     [rbp-50h],rax
     92: mov     rax,[rbp-18h]
     96: imul    rcx,[rbp-50h],4
     9b: add     rax,rcx
     9e: mov     [rbp-48h],rax
     a2: mov     [rbp-40h],rax
     a6: mov     rax,[rbp-10h]
     aa: mov     [rbp-68h],rax
     ae: add     rax,1
     b2: mov     [rbp-60h],rax
     b6: mov     rax,[rbp-18h]
     ba: imul    rcx,[rbp-60h],4
     bf: add     rax,rcx
     c2: mov     [rbp-58h],rax
     c6: mov     [rbp-50h],rax
     ca: mov     rax,[rbp-40h]
     ce: mov     [rbp-38h],rax
     d2: mov     rax,[rbp-50h]
     d6: mov     [rbp-30h],rax
     da: mov     rax,[rbp+28h]
     de: mov     [rbp-0A0h],rax
     e5: mov     rax,[rbp-38h]
     e9: mov     [rbp-98h],rax
     f0: mov     rax,[rbp-30h]
     f4: mov     [rbp-90h],rax
     fb: call    fn0
    100: nop     [rcx-1Ah]
    107: jmp     10Bh
    109: jmp     126h
    10b: mov     edi,0FFFFFFD8h
    110: mov     esi,0FFFFFFE6h
    115: call    ryo_h_ZextW8W64
    11a: mov     rax,[rbp-10h]
    11e: add     rax,[rbp-28h]
    122: mov     [rbp-10h],rax
    126: mov     rax,[rbp+20h]
    12a: mov     [rbp-48h],rax
    12e: mov     rax,[rbp-18h]
    132: imul    rcx,[rbp-48h],4
    137: add     rax,rcx
    13a: mov     [rbp-40h],rax
    13e: mov     [rbp-38h],rax
    142: mov     rax,[rbp-10h]
    146: mov     [rbp-58h],rax
    14a: mov     rax,[rbp-18h]
    14e: imul    rcx,[rbp-58h],4
    153: add     rax,rcx
    156: mov     [rbp-50h],rax
    15a: mov     [rbp-48h],rax
    15e: mov     rax,[rbp-38h]
    162: mov     [rbp-30h],rax
    166: mov     rax,[rbp-48h]
    16a: mov     [rbp-28h],rax
    16e: mov     rax,[rbp+28h]
    172: mov     [rbp-0A0h],rax
    179: mov     rax,[rbp-30h]
    17d: mov     [rbp-98h],rax
    184: mov     rax,[rbp-28h]
    188: mov     [rbp-90h],rax
    18f: call    fn1
    194: nop     [rcx-19h]
    19b: test    byte ptr [rbp-19h],0FFh
    19f: je      1D5h
    1a1: mov     rax,[rbp-18h]
    1a5: imul    rcx,[rbp+20h],4
    1aa: add     rax,rcx
    1ad: mov     [rbp-20h],rax
    1b1: mov     rax,[rbp-10h]
    1b5: mov     [rbp-30h],rax
    1b9: mov     rax,[rbp-18h]
    1bd: imul    rcx,[rbp-30h],4
    1c2: add     rax,rcx
    1c5: mov     [rbp-28h],rax
    1c9: mov     byte ptr [rbp-69h],1
    1cd: test    byte ptr [rbp-69h],0FFh
    1d1: je      241h
    1d3: jmp     1E0h
    1d5: xor     edi,edi
    1d7: xor     esi,esi
    1d9: call    ryo_h_Ret
    1de: leave
    1df: ret
    1e0: mov     rax,[rbp-20h]
    1e4: mov     [rbp-30h],rax
    1e8: mov     rax,[rbp-28h]
    1ec: mov     [rbp-38h],rax
    1f0: mov     rax,[rbp-30h]
    1f4: mov     [rbp-0A0h],rax
    1fb: mov     rax,[rbp-38h]
    1ff: mov     [rbp-98h],rax
    206: mov     qword ptr [rbp-90h],4
    211: mov     qword ptr [rbp-88h],4
    21c: mov     qword ptr [rbp-80h],1
    224: mov     edi,0FFFFFF88h
    229: lea     rsi,[k2]
    230: call    ryo_h_AddrAbs
    235: call    fn3
    23a: nop     [rcx-10h]
    241: mov     rax,[rbp-20h]
    245: mov     [rbp-38h],rax
    249: mov     qword ptr [rbp-30h],1
    251: mov     edi,0FFFFFFB0h
    256: mov     esi,0FFFFFFC8h
    25b: call    ryo_h_MovW128
    260: imul    rax,[rbp-48h],4
    265: mov     [rbp-40h],rax
    269: jmp     2BFh
    26b: mov     rax,[rbp-48h]
    26f: mov     [rbp-50h],rax
    273: mov     rax,[rbp-20h]
    277: mov     [rbp-60h],rax
    27b: mov     rax,[rbp-28h]
    27f: mov     [rbp-68h],rax
    283: mov     rax,[rbp-60h]
    287: mov     [rbp-0A0h],rax
    28e: mov     rax,[rbp-68h]
    292: mov     [rbp-98h],rax
    299: mov     rax,[rbp-50h]
    29d: mov     [rbp-90h],rax
    2a4: call    fn4
    2a9: nop     [rcx-10h]
    2b0: jmp     2B2h
    2b2: mov     rax,[rbp-10h]
    2b6: mov     [rbp+20h],rax
    2ba: jmp     40h
    2bf: mov     rax,[rbp-40h]
    2c3: mov     [rbp-48h],rax
    2c7: mov     edi,0FFFFFF94h
    2cc: mov     esi,0FFFFFFB8h
    2d1: xor     edx,edx
    2d3: xor     ecx,ecx
    2d5: xor     r8d,r8d
    2d8: mov     r9d,1
    2de: call    ryo_h_DiscrNicheW64
    2e3: mov     edi,0FFFFFFA8h
    2e8: mov     esi,0FFFFFF94h
    2ed: call    ryo_h_ZextW32W64
    2f2: mov     edi,0FFFFFFA8h
    2f7: xor     esi,esi
    2f9: mov     edx,2
    2fe: call    ryo_h_SwitchDenseW64
    303: lea     rcx,[314h]
    30a: movsxd  rax,[rcx+rax*4]
    30e: add     rax,rcx
    311: jmp     rax
    313: int3
    314: .long   2b2h
    318: .long   26bh
    31c: .long   320h
    320: call    ryo_h_Unreachable
    325: ud2

fn core::slice::sort::unstable::ipnsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-30h],rax
     23: mov     edi,0FFFFFF80h
     28: mov     esi,0FFFFFFC8h
     2d: call    ryo_h_MovW128
     32: mov     rax,[rbp+20h]
     36: mov     [rbp-70h],rax
     3a: call    fn0
     3f: nop     [rcx-28h]
     46: mov     rax,[rbp-28h]
     4a: mov     [rbp-18h],rax
     4e: movzx   eax,byte ptr [rbp-20h]
     52: mov     [rbp-5],al
     55: mov     rax,[rbp-18h]
     59: cmp     rax,[rbp-10h]
     5d: setbe   [rbp-6]
     61: cmp     rax,[rbp-10h]
     65: jne     8Ah
     67: test    byte ptr [rbp-5],0FFh
     6b: je      88h
     6d: mov     edi,0FFFFFF80h
     72: mov     esi,10h
     77: call    ryo_h_MovW128
     7c: call    fn1
     81: nop     [rcx]
     88: jmp     100h
     8a: mov     rax,[rbp-10h]
     8e: or      rax,1
     92: mov     [rbp-28h],rax
     96: mov     [rbp-30h],rax
     9a: mov     edi,0FFFFFFB4h
     9f: mov     esi,0FFFFFFD0h
     a4: xor     edx,edx
     a6: xor     ecx,ecx
     a8: xor     r8d,r8d
     ab: mov     r9d,1
     b1: call    ryo_h_DiscrNicheW64
     b6: mov     edi,0FFFFFFC8h
     bb: mov     esi,0FFFFFFB4h
     c0: call    ryo_h_ZextW32W64
     c5: mov     edi,0FFFFFFC8h
     ca: xor     esi,esi
     cc: mov     edx,2
     d1: call    ryo_h_SwitchDenseW64
     d6: lea     rcx,[0E8h]
     dd: movsxd  rax,[rcx+rax*4]
     e1: add     rax,rcx
     e4: jmp     rax
     e6: int3
     e7: int3
     e8: .long   112h
     ec: .long   162h
     f0: .long   10bh
     f4: nop     [rax+rax]
     fd: nop     [rax]
    100: xor     edi,edi
    102: xor     esi,esi
    104: call    ryo_h_Ret
    109: leave
    10a: ret
    10b: call    ryo_h_Unreachable
    110: ud2
    112: mov     edi,0FFFFFF80h
    117: lea     rsi,[k2]
    11e: call    ryo_h_AddrAbs
    123: lea     rdi,[sym3]
    12a: lea     rsi,[site4]
    131: mov     edx,0FFFFFFB0h
    136: call    ryo_h_CallExt
    13b: test    rax,rax
    13e: je      14Bh
    140: call    rax
    142: nop     [rcx]
    149: jmp     15Bh
    14b: mov     rdi,rbp
    14e: lea     rsi,[ro+4]
    155: call    qword ptr [sym5]
    15b: call    ryo_h_Unreachable
    160: ud2
    162: mov     rax,[rbp-30h]
    166: mov     [rbp-40h],rax
    16a: mov     [rbp-48h],rax
    16e: mov     edi,0FFFFFFB4h
    173: mov     esi,0FFFFFFB8h
    178: call    ryo_h_CtlzW64
    17d: mov     eax,[rbp-4Ch]
    180: mov     [rbp-20h],eax
    183: mov     dword ptr [rbp-4Ch],3Fh
    18a: mov     eax,[rbp-4Ch]
    18d: sub     eax,[rbp-20h]
    190: mov     [rbp-4],eax
    193: mov     dword ptr [rbp-4Ch],2
    19a: mov     eax,[rbp-4Ch]
    19d: imul    eax,[rbp-4]
    1a1: mov     [rbp-1Ch],eax
    1a4: mov     edi,0FFFFFF80h
    1a9: mov     esi,10h
    1ae: call    ryo_h_MovW128
    1b3: mov     qword ptr [rbp-70h],0
    1bb: mov     eax,[rbp-1Ch]
    1be: mov     [rbp-68h],eax
    1c1: mov     rax,[rbp+20h]
    1c5: mov     [rbp-60h],rax
    1c9: call    fn6
    1ce: nop     [rcx]
    1d5: jmp     100h

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,0
     17: jne     26h
     19: mov     qword ptr [rbp-8],0
     21: jmp     207h
     26: mov     rax,[rbp+20h]
     2a: cmp     rax,[rbp-20h]
     2e: jb      37h
     30: call    ryo_h_Abort
     35: ud2
     37: mov     edi,0FFFFFF70h
     3c: mov     esi,10h
     41: call    ryo_h_MovW128
     46: mov     qword ptr [rbp-80h],0
     4e: mov     rax,[rbp+20h]
     52: mov     [rbp-78h],rax
     56: mov     edi,0FFFFFF90h
     5b: lea     rsi,[k0]
     62: call    ryo_h_AddrAbs
     67: call    fn1
     6c: nop     [rcx-8]
     73: mov     edi,0FFFFFF70h
     78: mov     esi,10h
     7d: call    ryo_h_MovW128
     82: mov     qword ptr [rbp-80h],1
     8a: mov     edi,0FFFFFF88h
     8f: lea     rsi,[k2]
     96: call    ryo_h_AddrAbs
     9b: call    fn3
     a0: nop     [rcx-60h]
     a7: mov     edi,0FFFFFFD0h
     ac: mov     esi,0FFFFFFA0h
     b1: call    ryo_h_MovW128
     b6: mov     edi,0FFFFFFC0h
     bb: mov     esi,0FFFFFFB0h
     c0: call    ryo_h_MovW128
     c5: mov     rax,[rbp-28h]
     c9: mov     [rbp-10h],rax
     cd: mov     qword ptr [rbp-68h],0
     d5: mov     rax,[rbp-68h]
     d9: cmp     rax,[rbp-10h]
     dd: setb    [rbp-11h]
     e1: test    byte ptr [rbp-11h],0FFh
     e5: jne     14Dh
     e7: mov     qword ptr [rbp-90h],0
     f2: mov     rax,[rbp-10h]
     f6: mov     [rbp-88h],rax
     fd: mov     edi,0FFFFFF80h
    102: lea     rsi,[k4]
    109: call    ryo_h_AddrAbs
    10e: lea     rdi,[sym5]
    115: lea     rsi,[site6]
    11c: mov     edx,0FFFFFF98h
    121: call    ryo_h_CallExt
    126: test    rax,rax
    129: je      136h
    12b: call    rax
    12d: nop     [rcx-60h]
    134: jmp     146h
    136: mov     rdi,rbp
    139: lea     rsi,[ro+4]
    140: call    qword ptr [sym7]
    146: call    ryo_h_Unreachable
    14b: ud2
    14d: mov     rax,[rbp-30h]
    151: mov     [rbp-48h],rax
    155: mov     [rbp-50h],rax
    159: mov     edi,0FFFFFF98h
    15e: lea     rsi,[sym8]
    165: call    ryo_h_AddrSym
    16a: mov     edi,0FFFFFF70h
    16f: mov     esi,0FFFFFFC0h
    174: call    ryo_h_MovW128
    179: mov     rax,[rbp-50h]
    17d: mov     [rbp-80h],rax
    181: mov     rax,[rbp+28h]
    185: mov     [rbp-78h],rax
    189: mov     edi,0FFFFFF98h
    18e: lea     rsi,[site9]
    195: call    ryo_h_CallInd
    19a: test    rax,rax
    19d: je      1AAh
    19f: call    rax
    1a1: nop     [rcx-8]
    1a8: jmp     1BAh
    1aa: mov     rdi,rbp
    1ad: lea     rsi,[ro+20]
    1b4: call    qword ptr [sym10]
    1ba: mov     rax,[rbp-8]
    1be: cmp     rax,[rbp-20h]
    1c2: jb      1CBh
    1c4: call    ryo_h_Abort
    1c9: ud2
    1cb: mov     edi,0FFFFFF70h
    1d0: mov     esi,10h
    1d5: call    ryo_h_MovW128
    1da: mov     qword ptr [rbp-80h],0
    1e2: mov     rax,[rbp-8]
    1e6: mov     [rbp-78h],rax
    1ea: mov     edi,0FFFFFF90h
    1ef: lea     rsi,[k11]
    1f6: call    ryo_h_AddrAbs
    1fb: call    fn12
    200: nop     [rcx-11h]
    207: mov     edi,0FFFFFFF8h
    20c: mov     esi,8
    211: call    ryo_h_Ret
    216: leave
    217: ret

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,0
     17: jne     26h
     19: mov     qword ptr [rbp-8],0
     21: jmp     207h
     26: mov     rax,[rbp+20h]
     2a: cmp     rax,[rbp-20h]
     2e: jb      37h
     30: call    ryo_h_Abort
     35: ud2
     37: mov     edi,0FFFFFF70h
     3c: mov     esi,10h
     41: call    ryo_h_MovW128
     46: mov     qword ptr [rbp-80h],0
     4e: mov     rax,[rbp+20h]
     52: mov     [rbp-78h],rax
     56: mov     edi,0FFFFFF90h
     5b: lea     rsi,[k0]
     62: call    ryo_h_AddrAbs
     67: call    fn1
     6c: nop     [rcx-8]
     73: mov     edi,0FFFFFF70h
     78: mov     esi,10h
     7d: call    ryo_h_MovW128
     82: mov     qword ptr [rbp-80h],1
     8a: mov     edi,0FFFFFF88h
     8f: lea     rsi,[k2]
     96: call    ryo_h_AddrAbs
     9b: call    fn3
     a0: nop     [rcx-60h]
     a7: mov     edi,0FFFFFFD0h
     ac: mov     esi,0FFFFFFA0h
     b1: call    ryo_h_MovW128
     b6: mov     edi,0FFFFFFC0h
     bb: mov     esi,0FFFFFFB0h
     c0: call    ryo_h_MovW128
     c5: mov     rax,[rbp-28h]
     c9: mov     [rbp-10h],rax
     cd: mov     qword ptr [rbp-68h],0
     d5: mov     rax,[rbp-68h]
     d9: cmp     rax,[rbp-10h]
     dd: setb    [rbp-11h]
     e1: test    byte ptr [rbp-11h],0FFh
     e5: jne     14Dh
     e7: mov     qword ptr [rbp-90h],0
     f2: mov     rax,[rbp-10h]
     f6: mov     [rbp-88h],rax
     fd: mov     edi,0FFFFFF80h
    102: lea     rsi,[k4]
    109: call    ryo_h_AddrAbs
    10e: lea     rdi,[sym5]
    115: lea     rsi,[site6]
    11c: mov     edx,0FFFFFF98h
    121: call    ryo_h_CallExt
    126: test    rax,rax
    129: je      136h
    12b: call    rax
    12d: nop     [rcx-60h]
    134: jmp     146h
    136: mov     rdi,rbp
    139: lea     rsi,[ro+4]
    140: call    qword ptr [sym7]
    146: call    ryo_h_Unreachable
    14b: ud2
    14d: mov     rax,[rbp-30h]
    151: mov     [rbp-48h],rax
    155: mov     [rbp-50h],rax
    159: mov     edi,0FFFFFF98h
    15e: lea     rsi,[sym8]
    165: call    ryo_h_AddrSym
    16a: mov     edi,0FFFFFF70h
    16f: mov     esi,0FFFFFFC0h
    174: call    ryo_h_MovW128
    179: mov     rax,[rbp-50h]
    17d: mov     [rbp-80h],rax
    181: mov     rax,[rbp+28h]
    185: mov     [rbp-78h],rax
    189: mov     edi,0FFFFFF98h
    18e: lea     rsi,[site9]
    195: call    ryo_h_CallInd
    19a: test    rax,rax
    19d: je      1AAh
    19f: call    rax
    1a1: nop     [rcx-8]
    1a8: jmp     1BAh
    1aa: mov     rdi,rbp
    1ad: lea     rsi,[ro+20]
    1b4: call    qword ptr [sym10]
    1ba: mov     rax,[rbp-8]
    1be: cmp     rax,[rbp-20h]
    1c2: jb      1CBh
    1c4: call    ryo_h_Abort
    1c9: ud2
    1cb: mov     edi,0FFFFFF70h
    1d0: mov     esi,10h
    1d5: call    ryo_h_MovW128
    1da: mov     qword ptr [rbp-80h],0
    1e2: mov     rax,[rbp-8]
    1e6: mov     [rbp-78h],rax
    1ea: mov     edi,0FFFFFF90h
    1ef: lea     rsi,[k11]
    1f6: call    ryo_h_AddrAbs
    1fb: call    fn12
    200: nop     [rcx-11h]
    207: mov     edi,0FFFFFFF8h
    20c: mov     esi,8
    211: call    ryo_h_Ret
    216: leave
    217: ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-30h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: mov     rax,[rbp-20h]
     27: mov     [rbp-38h],rax
     2b: cmp     qword ptr [rbp-30h],0
     30: jne     3Fh
     32: mov     qword ptr [rbp-8],0
     3a: jmp     2EFh
     3f: lea     rax,[rbp-38h]
     43: mov     [rbp-58h],rax
     47: mov     rax,[rbp+28h]
     4b: mov     [rbp-50h],rax
     4f: mov     rax,[rbp+20h]
     53: mov     [rbp-48h],rax
     57: mov     rax,[rbp-58h]
     5b: mov     [rbp-40h],rax
     5f: mov     rax,[rbp-20h]
     63: mov     [rbp-60h],rax
     67: mov     eax,[rax]
     69: mov     [rbp-58h],eax
     6c: mov     [rbp-5Ch],eax
     6f: mov     [rbp-54h],eax
     72: mov     qword ptr [rbp-0A8h],1
     7d: mov     rax,[rbp-38h]
     81: imul    rcx,[rbp-0A8h],4
     89: add     rax,rcx
     8c: mov     [rbp-80h],rax
     90: lea     rax,[rbp-54h]
     94: mov     [rbp-98h],rax
     9b: mov     rax,[rbp-38h]
     9f: mov     [rbp-90h],rax
     a6: mov     rax,[rbp-98h]
     ad: mov     [rbp-88h],rax
     b4: mov     rax,[rbp-80h]
     b8: mov     [rbp-68h],rax
     bc: mov     qword ptr [rbp-60h],0
     c4: mov     edi,0FFFFFF88h
     c9: mov     esi,0FFFFFF70h
     ce: call    ryo_h_MovW128
     d3: mov     qword ptr [rbp-0A8h],2
     de: mov     rax,[rbp-0A8h]
     e5: sub     rax,1
     e9: mov     [rbp-90h],rax
     f0: mov     rax,[rbp-30h]
     f4: sub     rax,[rbp-90h]
     fb: mov     [rbp-88h],rax
    102: mov     rax,[rbp-38h]
    106: imul    rcx,[rbp-88h],4
    10e: add     rax,rcx
    111: mov     [rbp-80h],rax
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: mov     rax,[rbp-68h]
    124: mov     [rbp-88h],rax
    12b: cmp     rax,[rbp-80h]
    12f: jae     22Ch
    135: mov     qword ptr [rbp-0A8h],2
    140: cmp     qword ptr [rbp-0A8h],2
    148: sete    [rbp-56h]
    14c: test    byte ptr [rbp-56h],0FFh
    150: je      1E2h
    156: lea     rax,[rbp-50h]
    15a: mov     [rbp-88h],rax
    161: lea     rax,[rbp-78h]
    165: mov     [rbp-98h],rax
    16c: mov     [rbp-90h],rax
    173: mov     rax,[rbp-88h]
    17a: mov     [rbp-0C0h],rax
    181: mov     rax,[rbp-90h]
    188: mov     [rbp-0B8h],rax
    18f: call    fn0
    194: nop     [rcx-10h]
    19b: lea     rax,[rbp-50h]
    19f: mov     [rbp-88h],rax
    1a6: lea     rax,[rbp-78h]
    1aa: mov     [rbp-98h],rax
    1b1: mov     [rbp-90h],rax
    1b8: mov     rax,[rbp-88h]
    1bf: mov     [rbp-0C0h],rax
    1c6: mov     rax,[rbp-90h]
    1cd: mov     [rbp-0B8h],rax
    1d4: call    fn1
    1d9: nop     [rcx-10h]
    1e0: jmp     227h
    1e2: lea     rax,[rbp-50h]
    1e6: mov     [rbp-88h],rax
    1ed: lea     rax,[rbp-78h]
    1f1: mov     [rbp-98h],rax
    1f8: mov     [rbp-90h],rax
    1ff: mov     rax,[rbp-88h]
    206: mov     [rbp-0C0h],rax
    20d: mov     rax,[rbp-90h]
    214: mov     [rbp-0B8h],rax
    21b: call    fn2
    220: nop     [rcx-10h]
    227: jmp     120h
    22c: mov     rax,[rbp-38h]
    230: imul    rcx,[rbp-30h],4
    235: add     rax,rcx
    238: mov     [rbp-88h],rax
    23f: nop
    240: mov     rax,[rbp-68h]
    244: mov     [rbp-90h],rax
    24b: cmp     rax,[rbp-88h]
    252: sete    [rbp-55h]
    256: test    byte ptr [rbp-55h],0FFh
    25a: je      269h
    25c: mov     rax,[rbp-70h]
    260: mov     [rbp-90h],rax
    267: jmp     274h
    269: mov     rax,[rbp-68h]
    26d: mov     [rbp-90h],rax
    274: mov     rax,[rbp-90h]
    27b: mov     [rbp-68h],rax
    27f: lea     rax,[rbp-50h]
    283: mov     [rbp-90h],rax
    28a: lea     rax,[rbp-78h]
    28e: mov     [rbp-0A0h],rax
    295: mov     [rbp-98h],rax
    29c: mov     rax,[rbp-90h]
    2a3: mov     [rbp-0C0h],rax
    2aa: mov     rax,[rbp-98h]
    2b1: mov     [rbp-0B8h],rax
    2b8: call    fn3
    2bd: nop     [rcx-10h]
    2c4: test    byte ptr [rbp-55h],0FFh
    2c8: je      2EAh
    2ca: mov     rax,[rbp-78h]
    2ce: mov     [rbp-90h],rax
    2d5: mov     rax,[rbp-70h]
    2d9: mov     [rbp-98h],rax
    2e0: mov     rax,[rbp-60h]
    2e4: mov     [rbp-8],rax
    2e8: jmp     2EFh
    2ea: jmp     240h
    2ef: mov     edi,0FFFFFFF8h
    2f4: mov     esi,8
    2f9: call    ryo_h_Ret
    2fe: leave
    2ff: ret
    300: mov     edi,0FFFFFFD8h
    305: call    ryo_h_Resume
    30a: ud2
    30c: nop     [rax]
    310: lea     rax,[rbp-78h]
    314: mov     [rbp-0A8h],rax
    31b: mov     [rbp-0C0h],rax
    322: call    fn4
    327: nop     [rcx-0A8h]
    32e: jmp     300h
    330: lea     rdi,[sym5]
    337: lea     rsi,[site6]
    33e: mov     edx,0FFFFFF58h
    343: call    ryo_h_CallExt
    348: test    rax,rax
    34b: je      358h
    34d: call    rax
    34f: nop     [rcx-0A0h]
    356: jmp     368h
    358: mov     rdi,rbp
    35b: lea     rsi,[ro+4]
    362: call    qword ptr [sym7]
    368: call    ryo_h_Unreachable
    36d: ud2
    36f: mov     rdi,rax
    372: mov     esi,0FFFFFFD8h
    377: call    ryo_h_Lpad
    37c: jmp     310h
    37e: mov     rdi,rax
    381: mov     esi,0FFFFFFD8h
    386: call    ryo_h_Lpad
    38b: jmp     330h

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-10h],rax
     16: mov     rax,[rbp+18h]
     1a: mov     rax,[rax+10h]
     1e: mov     [rbp-18h],rax
     22: mov     [rbp-48h],rax
     26: mov     rax,[rbp+10h]
     2a: mov     rax,[rax+8]
     2e: mov     [rbp-20h],rax
     32: mov     rax,[rbp-48h]
     36: mov     [rbp-40h],rax
     3a: mov     rax,[rbp-20h]
     3e: mov     [rbp-38h],rax
     42: mov     rax,[rbp-10h]
     46: mov     [rbp-0A0h],rax
     4d: mov     rax,[rbp-40h]
     51: mov     [rbp-98h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-90h],rax
     63: call    fn0
     68: nop     [rcx-29h]
     6f: mov     rax,[rbp+10h]
     73: mov     rax,[rax+10h]
     77: mov     [rbp-28h],rax
     7b: mov     rax,[rax]
     7e: mov     [rbp-40h],rax
     82: mov     rax,[rbp+18h]
     86: mov     rax,[rax+18h]
     8a: mov     [rbp-48h],rax
     8e: mov     rax,[rbp-40h]
     92: imul    rcx,[rbp-48h],4
     97: add     rax,rcx
     9a: mov     [rbp-38h],rax
     9e: mov     [rbp-40h],rax
     a2: mov     rax,[rbp+18h]
     a6: mov     rax,[rax]
     a9: mov     [rbp-48h],rax
     ad: mov     byte ptr [rbp-59h],1
     b1: test    byte ptr [rbp-59h],0FFh
     b5: je      14Fh
     bb: jmp     0E3h
     bd: nop     [rax]
     c0: mov     rax,[rbp+18h]
     c4: mov     rax,[rax+10h]
     c8: mov     [rbp-8],rax
     cc: mov     [rbp-40h],rax
     d0: mov     byte ptr [rbp-59h],1
     d4: test    byte ptr [rbp-59h],0FFh
     d8: je      1DAh
     de: jmp     179h
     e3: mov     rax,[rbp-38h]
     e7: mov     [rbp-50h],rax
     eb: mov     rax,[rbp-48h]
     ef: mov     [rbp-58h],rax
     f3: mov     byte ptr [rbp-59h],0
     f7: test    byte ptr [rbp-59h],0FFh
     fb: je      103h
     fd: mov     byte ptr [rbp-2Ah],1
    101: jmp     107h
    103: mov     byte ptr [rbp-2Ah],0
    107: mov     rax,[rbp-50h]
    10b: mov     [rbp-0A0h],rax
    112: mov     rax,[rbp-58h]
    116: mov     [rbp-98h],rax
    11d: mov     qword ptr [rbp-90h],4
    128: movzx   eax,byte ptr [rbp-2Ah]
    12c: mov     [rbp-88h],al
    132: mov     edi,0FFFFFF80h
    137: lea     rsi,[k1]
    13e: call    ryo_h_AddrAbs
    143: call    fn2
    148: nop     [rcx-28h]
    14f: mov     qword ptr [rbp-60h],1
    157: imul    rax,[rbp-60h],4
    15c: mov     [rbp-68h],rax
    160: mov     edi,0FFFFFFB8h
    165: mov     esi,0FFFFFFC0h
    16a: mov     edx,0FFFFFF98h
    16f: call    ryo_h_Memmove
    174: jmp     0C0h
    179: mov     rax,[rbp-8]
    17d: mov     [rbp-48h],rax
    181: mov     rax,[rbp-38h]
    185: mov     [rbp-50h],rax
    189: mov     rax,[rbp-48h]
    18d: mov     [rbp-0A0h],rax
    194: mov     rax,[rbp-50h]
    198: mov     [rbp-98h],rax
    19f: mov     qword ptr [rbp-90h],4
    1aa: mov     qword ptr [rbp-88h],4
    1b5: mov     qword ptr [rbp-80h],1
    1bd: mov     edi,0FFFFFF88h
    1c2: lea     rsi,[k3]
    1c9: call    ryo_h_AddrAbs
    1ce: call    fn4
    1d3: nop     [rcx-28h]
    1da: mov     qword ptr [rbp-60h],1
    1e2: imul    rax,[rbp-60h],4
    1e7: mov     [rbp-68h],rax
    1eb: mov     edi,0FFFFFFC8h
    1f0: mov     esi,0FFFFFFC0h
    1f5: mov     edx,0FFFFFF98h
    1fa: call    ryo_h_Memcpy
    1ff: mov     rax,[rbp+18h]
    203: mov     rax,[rax+10h]
    207: mov     [rbp-40h],rax
    20b: mov     rax,[rbp+18h]
    20f: mov     rcx,[rbp-40h]
    213: mov     [rax],rcx
    216: mov     edi,0FFFFFFC0h
    21b: mov     esi,0FFFFFFD7h
    220: call    ryo_h_ZextW8W64
    225: mov     rax,[rbp+18h]
    229: mov     rax,[rax+18h]
    22d: mov     [rbp-60h],rax
    231: add     rax,[rbp-40h]
    235: mov     [rbp-70h],rax
    239: mov     rax,[rbp+18h]
    23d: mov     rcx,[rbp-70h]
    241: mov     [rax+18h],rcx
    245: mov     rax,[rbp+18h]
    249: mov     rax,[rax+10h]
    24d: mov     [rbp-48h],rax
    251: mov     qword ptr [rbp-60h],1
    259: imul    rcx,[rbp-60h],4
    25e: add     rax,rcx
    261: mov     [rbp-40h],rax
    265: mov     rax,[rbp+18h]
    269: mov     rcx,[rbp-40h]
    26d: mov     [rax+10h],rcx
    271: xor     edi,edi
    273: xor     esi,esi
    275: call    ryo_h_Ret
    27a: leave
    27b: ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-30h],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: mov     rax,[rbp-20h]
     27: mov     [rbp-38h],rax
     2b: cmp     qword ptr [rbp-30h],0
     30: jne     3Fh
     32: mov     qword ptr [rbp-8],0
     3a: jmp     2EFh
     3f: lea     rax,[rbp-38h]
     43: mov     [rbp-58h],rax
     47: mov     rax,[rbp+28h]
     4b: mov     [rbp-50h],rax
     4f: mov     rax,[rbp+20h]
     53: mov     [rbp-48h],rax
     57: mov     rax,[rbp-58h]
     5b: mov     [rbp-40h],rax
     5f: mov     rax,[rbp-20h]
     63: mov     [rbp-60h],rax
     67: mov     eax,[rax]
     69: mov     [rbp-58h],eax
     6c: mov     [rbp-5Ch],eax
     6f: mov     [rbp-54h],eax
     72: mov     qword ptr [rbp-0A8h],1
     7d: mov     rax,[rbp-38h]
     81: imul    rcx,[rbp-0A8h],4
     89: add     rax,rcx
     8c: mov     [rbp-80h],rax
     90: lea     rax,[rbp-54h]
     94: mov     [rbp-98h],rax
     9b: mov     rax,[rbp-38h]
     9f: mov     [rbp-90h],rax
     a6: mov     rax,[rbp-98h]
     ad: mov     [rbp-88h],rax
     b4: mov     rax,[rbp-80h]
     b8: mov     [rbp-68h],rax
     bc: mov     qword ptr [rbp-60h],0
     c4: mov     edi,0FFFFFF88h
     c9: mov     esi,0FFFFFF70h
     ce: call    ryo_h_MovW128
     d3: mov     qword ptr [rbp-0A8h],2
     de: mov     rax,[rbp-0A8h]
     e5: sub     rax,1
     e9: mov     [rbp-90h],rax
     f0: mov     rax,[rbp-30h]
     f4: sub     rax,[rbp-90h]
     fb: mov     [rbp-88h],rax
    102: mov     rax,[rbp-38h]
    106: imul    rcx,[rbp-88h],4
    10e: add     rax,rcx
    111: mov     [rbp-80h],rax
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: mov     rax,[rbp-68h]
    124: mov     [rbp-88h],rax
    12b: cmp     rax,[rbp-80h]
    12f: jae     22Ch
    135: mov     qword ptr [rbp-0A8h],2
    140: cmp     qword ptr [rbp-0A8h],2
    148: sete    [rbp-56h]
    14c: test    byte ptr [rbp-56h],0FFh
    150: je      1E2h
    156: lea     rax,[rbp-50h]
    15a: mov     [rbp-88h],rax
    161: lea     rax,[rbp-78h]
    165: mov     [rbp-98h],rax
    16c: mov     [rbp-90h],rax
    173: mov     rax,[rbp-88h]
    17a: mov     [rbp-0C0h],rax
    181: mov     rax,[rbp-90h]
    188: mov     [rbp-0B8h],rax
    18f: call    fn0
    194: nop     [rcx-10h]
    19b: lea     rax,[rbp-50h]
    19f: mov     [rbp-88h],rax
    1a6: lea     rax,[rbp-78h]
    1aa: mov     [rbp-98h],rax
    1b1: mov     [rbp-90h],rax
    1b8: mov     rax,[rbp-88h]
    1bf: mov     [rbp-0C0h],rax
    1c6: mov     rax,[rbp-90h]
    1cd: mov     [rbp-0B8h],rax
    1d4: call    fn1
    1d9: nop     [rcx-10h]
    1e0: jmp     227h
    1e2: lea     rax,[rbp-50h]
    1e6: mov     [rbp-88h],rax
    1ed: lea     rax,[rbp-78h]
    1f1: mov     [rbp-98h],rax
    1f8: mov     [rbp-90h],rax
    1ff: mov     rax,[rbp-88h]
    206: mov     [rbp-0C0h],rax
    20d: mov     rax,[rbp-90h]
    214: mov     [rbp-0B8h],rax
    21b: call    fn2
    220: nop     [rcx-10h]
    227: jmp     120h
    22c: mov     rax,[rbp-38h]
    230: imul    rcx,[rbp-30h],4
    235: add     rax,rcx
    238: mov     [rbp-88h],rax
    23f: nop
    240: mov     rax,[rbp-68h]
    244: mov     [rbp-90h],rax
    24b: cmp     rax,[rbp-88h]
    252: sete    [rbp-55h]
    256: test    byte ptr [rbp-55h],0FFh
    25a: je      269h
    25c: mov     rax,[rbp-70h]
    260: mov     [rbp-90h],rax
    267: jmp     274h
    269: mov     rax,[rbp-68h]
    26d: mov     [rbp-90h],rax
    274: mov     rax,[rbp-90h]
    27b: mov     [rbp-68h],rax
    27f: lea     rax,[rbp-50h]
    283: mov     [rbp-90h],rax
    28a: lea     rax,[rbp-78h]
    28e: mov     [rbp-0A0h],rax
    295: mov     [rbp-98h],rax
    29c: mov     rax,[rbp-90h]
    2a3: mov     [rbp-0C0h],rax
    2aa: mov     rax,[rbp-98h]
    2b1: mov     [rbp-0B8h],rax
    2b8: call    fn3
    2bd: nop     [rcx-10h]
    2c4: test    byte ptr [rbp-55h],0FFh
    2c8: je      2EAh
    2ca: mov     rax,[rbp-78h]
    2ce: mov     [rbp-90h],rax
    2d5: mov     rax,[rbp-70h]
    2d9: mov     [rbp-98h],rax
    2e0: mov     rax,[rbp-60h]
    2e4: mov     [rbp-8],rax
    2e8: jmp     2EFh
    2ea: jmp     240h
    2ef: mov     edi,0FFFFFFF8h
    2f4: mov     esi,8
    2f9: call    ryo_h_Ret
    2fe: leave
    2ff: ret
    300: mov     edi,0FFFFFFD8h
    305: call    ryo_h_Resume
    30a: ud2
    30c: nop     [rax]
    310: lea     rax,[rbp-78h]
    314: mov     [rbp-0A8h],rax
    31b: mov     [rbp-0C0h],rax
    322: call    fn4
    327: nop     [rcx-0A8h]
    32e: jmp     300h
    330: lea     rdi,[sym5]
    337: lea     rsi,[site6]
    33e: mov     edx,0FFFFFF58h
    343: call    ryo_h_CallExt
    348: test    rax,rax
    34b: je      358h
    34d: call    rax
    34f: nop     [rcx-0A0h]
    356: jmp     368h
    358: mov     rdi,rbp
    35b: lea     rsi,[ro+4]
    362: call    qword ptr [sym7]
    368: call    ryo_h_Unreachable
    36d: ud2
    36f: mov     rdi,rax
    372: mov     esi,0FFFFFFD8h
    377: call    ryo_h_Lpad
    37c: jmp     310h
    37e: mov     rdi,rax
    381: mov     esi,0FFFFFFD8h
    386: call    ryo_h_Lpad
    38b: jmp     330h

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-10h],rax
     16: mov     rax,[rbp+18h]
     1a: mov     rax,[rax+10h]
     1e: mov     [rbp-18h],rax
     22: mov     [rbp-48h],rax
     26: mov     rax,[rbp+10h]
     2a: mov     rax,[rax+8]
     2e: mov     [rbp-20h],rax
     32: mov     rax,[rbp-48h]
     36: mov     [rbp-40h],rax
     3a: mov     rax,[rbp-20h]
     3e: mov     [rbp-38h],rax
     42: mov     rax,[rbp-10h]
     46: mov     [rbp-0A0h],rax
     4d: mov     rax,[rbp-40h]
     51: mov     [rbp-98h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-90h],rax
     63: call    fn0
     68: nop     [rcx-29h]
     6f: mov     rax,[rbp+10h]
     73: mov     rax,[rax+10h]
     77: mov     [rbp-28h],rax
     7b: mov     rax,[rax]
     7e: mov     [rbp-40h],rax
     82: mov     rax,[rbp+18h]
     86: mov     rax,[rax+18h]
     8a: mov     [rbp-48h],rax
     8e: mov     rax,[rbp-40h]
     92: imul    rcx,[rbp-48h],4
     97: add     rax,rcx
     9a: mov     [rbp-38h],rax
     9e: mov     [rbp-40h],rax
     a2: mov     rax,[rbp+18h]
     a6: mov     rax,[rax]
     a9: mov     [rbp-48h],rax
     ad: mov     byte ptr [rbp-59h],1
     b1: test    byte ptr [rbp-59h],0FFh
     b5: je      14Fh
     bb: jmp     0E3h
     bd: nop     [rax]
     c0: mov     rax,[rbp+18h]
     c4: mov     rax,[rax+10h]
     c8: mov     [rbp-8],rax
     cc: mov     [rbp-40h],rax
     d0: mov     byte ptr [rbp-59h],1
     d4: test    byte ptr [rbp-59h],0FFh
     d8: je      1DAh
     de: jmp     179h
     e3: mov     rax,[rbp-38h]
     e7: mov     [rbp-50h],rax
     eb: mov     rax,[rbp-48h]
     ef: mov     [rbp-58h],rax
     f3: mov     byte ptr [rbp-59h],0
     f7: test    byte ptr [rbp-59h],0FFh
     fb: je      103h
     fd: mov     byte ptr [rbp-2Ah],1
    101: jmp     107h
    103: mov     byte ptr [rbp-2Ah],0
    107: mov     rax,[rbp-50h]
    10b: mov     [rbp-0A0h],rax
    112: mov     rax,[rbp-58h]
    116: mov     [rbp-98h],rax
    11d: mov     qword ptr [rbp-90h],4
    128: movzx   eax,byte ptr [rbp-2Ah]
    12c: mov     [rbp-88h],al
    132: mov     edi,0FFFFFF80h
    137: lea     rsi,[k1]
    13e: call    ryo_h_AddrAbs
    143: call    fn2
    148: nop     [rcx-28h]
    14f: mov     qword ptr [rbp-60h],1
    157: imul    rax,[rbp-60h],4
    15c: mov     [rbp-68h],rax
    160: mov     edi,0FFFFFFB8h
    165: mov     esi,0FFFFFFC0h
    16a: mov     edx,0FFFFFF98h
    16f: call    ryo_h_Memmove
    174: jmp     0C0h
    179: mov     rax,[rbp-8]
    17d: mov     [rbp-48h],rax
    181: mov     rax,[rbp-38h]
    185: mov     [rbp-50h],rax
    189: mov     rax,[rbp-48h]
    18d: mov     [rbp-0A0h],rax
    194: mov     rax,[rbp-50h]
    198: mov     [rbp-98h],rax
    19f: mov     qword ptr [rbp-90h],4
    1aa: mov     qword ptr [rbp-88h],4
    1b5: mov     qword ptr [rbp-80h],1
    1bd: mov     edi,0FFFFFF88h
    1c2: lea     rsi,[k3]
    1c9: call    ryo_h_AddrAbs
    1ce: call    fn4
    1d3: nop     [rcx-28h]
    1da: mov     qword ptr [rbp-60h],1
    1e2: imul    rax,[rbp-60h],4
    1e7: mov     [rbp-68h],rax
    1eb: mov     edi,0FFFFFFC8h
    1f0: mov     esi,0FFFFFFC0h
    1f5: mov     edx,0FFFFFF98h
    1fa: call    ryo_h_Memcpy
    1ff: mov     rax,[rbp+18h]
    203: mov     rax,[rax+10h]
    207: mov     [rbp-40h],rax
    20b: mov     rax,[rbp+18h]
    20f: mov     rcx,[rbp-40h]
    213: mov     [rax],rcx
    216: mov     edi,0FFFFFFC0h
    21b: mov     esi,0FFFFFFD7h
    220: call    ryo_h_ZextW8W64
    225: mov     rax,[rbp+18h]
    229: mov     rax,[rax+18h]
    22d: mov     [rbp-60h],rax
    231: add     rax,[rbp-40h]
    235: mov     [rbp-70h],rax
    239: mov     rax,[rbp+18h]
    23d: mov     rcx,[rbp-70h]
    241: mov     [rax+18h],rcx
    245: mov     rax,[rbp+18h]
    249: mov     rax,[rax+10h]
    24d: mov     [rbp-48h],rax
    251: mov     qword ptr [rbp-60h],1
    259: imul    rcx,[rbp-60h],4
    25e: add     rax,rcx
    261: mov     [rbp-40h],rax
    265: mov     rax,[rbp+18h]
    269: mov     rcx,[rbp-40h]
    26d: mov     [rax+10h],rcx
    271: xor     edi,edi
    273: xor     esi,esi
    275: call    ryo_h_Ret
    27a: leave
    27b: ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-58h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     [rbp-50h],rax
     20: mov     [rbp-48h],rax
     24: call    fn0
     29: nop     [rcx-50h]
     30: mov     rax,[rbp-50h]
     34: cmp     rax,[rbp-48h]
     38: jb      65h
     3a: mov     edi,0FFFFFF30h
     3f: mov     esi,10h
     44: call    ryo_h_MovW128
     49: mov     rax,[rbp+30h]
     4d: mov     [rbp-0C0h],rax
     54: call    fn1
     59: nop     [rcx]
     60: jmp     482h
     65: mov     eax,[rbp+28h]
     68: mov     [rbp-40h],eax
     6b: cmp     eax,0
     6e: jne     98h
     70: mov     edi,0FFFFFF30h
     75: mov     esi,10h
     7a: call    ryo_h_MovW128
     7f: mov     rax,[rbp+30h]
     83: mov     [rbp-0C0h],rax
     8a: call    fn2
     8f: nop     [rcx]
     96: jmp     0D9h
     98: mov     eax,[rbp+28h]
     9b: sub     eax,1
     9e: mov     [rbp+28h],eax
     a1: mov     rax,[rbp+10h]
     a5: mov     [rbp-58h],rax
     a9: mov     rax,[rbp+18h]
     ad: mov     [rbp-50h],rax
     b1: mov     edi,0FFFFFF30h
     b6: mov     esi,0FFFFFFA8h
     bb: call    ryo_h_MovW128
     c0: mov     rax,[rbp+30h]
     c4: mov     [rbp-0C0h],rax
     cb: call    fn3
     d0: nop     [rcx-48h]
     d7: jmp     0DEh
     d9: jmp     482h
     de: mov     edi,0FFFFFF5Ch
     e3: mov     esi,20h
     e8: xor     edx,edx
     ea: xor     ecx,ecx
     ec: xor     r8d,r8d
     ef: mov     r9d,1
     f5: call    ryo_h_DiscrNicheW64
     fa: mov     edi,0FFFFFFF8h
     ff: mov     esi,0FFFFFF5Ch
    104: call    ryo_h_ZextW32W64
    109: mov     edi,0FFFFFFF8h
    10e: xor     esi,esi
    110: mov     edx,2
    115: call    ryo_h_SwitchDenseW64
    11a: lea     rcx,[12Ch]
    121: movsxd  rax,[rcx+rax*4]
    125: add     rax,rcx
    128: jmp     rax
    12a: int3
    12b: int3
    12c: .long   28fh
    130: .long   138h
    134: .long   563h
    138: mov     rax,[rbp+20h]
    13c: mov     [rbp-50h],rax
    140: mov     rax,[rbp+10h]
    144: mov     [rbp-18h],rax
    148: mov     rax,[rbp+18h]
    14c: mov     [rbp-10h],rax
    150: mov     [rbp-20h],rax
    154: mov     rax,[rbp-48h]
    158: cmp     rax,[rbp-20h]
    15c: jb      1C0h
    15e: mov     [rbp-0D0h],rax
    165: mov     rax,[rbp-20h]
    169: mov     [rbp-0C8h],rax
    170: mov     edi,0FFFFFF40h
    175: lea     rsi,[k4]
    17c: call    ryo_h_AddrAbs
    181: lea     rdi,[sym5]
    188: lea     rsi,[site6]
    18f: mov     edx,0FFFFFF58h
    194: call    ryo_h_CallExt
    199: test    rax,rax
    19c: je      1A9h
    19e: call    rax
    1a0: nop     [rcx-0A0h]
    1a7: jmp     1B9h
    1a9: mov     rdi,rbp
    1ac: lea     rsi,[ro+4]
    1b3: call    qword ptr [sym7]
    1b9: call    ryo_h_Unreachable
    1be: ud2
    1c0: mov     rax,[rbp+10h]
    1c4: imul    rcx,[rbp-48h],4
    1c9: add     rax,rcx
    1cc: mov     [rbp-0A8h],rax
    1d3: mov     [rbp-68h],rax
    1d7: mov     rax,[rbp-50h]
    1db: mov     [rbp-60h],rax
    1df: mov     rax,[rbp-68h]
    1e3: mov     [rbp-58h],rax
    1e7: mov     rax,[rbp+30h]
    1eb: mov     [rbp-0D0h],rax
    1f2: mov     rax,[rbp-60h]
    1f6: mov     [rbp-0C8h],rax
    1fd: mov     rax,[rbp-58h]
    201: mov     [rbp-0C0h],rax
    208: call    fn8
    20d: nop     [rcx-3Ah]
    214: test    byte ptr [rbp-3Ah],0FFh
    218: je      21Ch
    21a: jmp     28Fh
    21c: mov     edi,0FFFFFF98h
    221: mov     esi,10h
    226: call    ryo_h_MovW128
    22b: mov     rax,[rbp+30h]
    22f: mov     [rbp-78h],rax
    233: lea     rax,[rbp-78h]
    237: mov     [rbp-70h],rax
    23b: mov     edi,0FFFFFF30h
    240: mov     esi,0FFFFFF98h
    245: call    ryo_h_MovW128
    24a: mov     rax,[rbp-48h]
    24e: mov     [rbp-0C0h],rax
    255: mov     rax,[rbp-70h]
    259: mov     [rbp-0B8h],rax
    260: call    fn9
    265: nop     [rcx-58h]
    26c: mov     rax,[rbp-58h]
    270: add     rax,1
    274: mov     [rbp-30h],rax
    278: mov     rax,[rbp+18h]
    27c: mov     [rbp-60h],rax
    280: cmp     rax,[rbp-30h]
    284: jb      48Dh
    28a: jmp     4FEh
    28f: mov     edi,0FFFFFFA0h
    294: mov     esi,10h
    299: call    ryo_h_MovW128
    29e: mov     edi,0FFFFFF30h
    2a3: mov     esi,0FFFFFFA0h
    2a8: call    ryo_h_MovW128
    2ad: mov     rax,[rbp-48h]
    2b1: mov     [rbp-0C0h],rax
    2b8: mov     rax,[rbp+30h]
    2bc: mov     [rbp-0B8h],rax
    2c3: call    fn10
    2c8: nop     [rcx-50h]
    2cf: mov     rax,[rbp+10h]
    2d3: mov     [rbp-68h],rax
    2d7: mov     rax,[rbp+18h]
    2db: mov     [rbp-60h],rax
    2df: mov     [rbp-58h],rax
    2e3: mov     rax,[rbp-50h]
    2e7: cmp     rax,[rbp-58h]
    2eb: setb    [rbp-3Ah]
    2ef: mov     edi,0FFFFFF30h
    2f4: mov     esi,10h
    2f9: call    ryo_h_MovW128
    2fe: mov     rax,[rbp-50h]
    302: mov     [rbp-0C0h],rax
    309: mov     edi,0FFFFFF48h
    30e: lea     rsi,[k11]
    315: call    ryo_h_AddrAbs
    31a: call    fn12
    31f: nop     [rcx-90h]
    326: mov     edi,0FFFFFFA0h
    32b: mov     esi,0FFFFFF70h
    330: call    ryo_h_MovW128
    335: mov     edi,0FFFFFF90h
    33a: mov     esi,0FFFFFF80h
    33f: call    ryo_h_MovW128
    344: mov     edi,0FFFFFF30h
    349: mov     esi,0FFFFFF90h
    34e: call    ryo_h_MovW128
    353: mov     qword ptr [rbp-0C0h],1
    35e: mov     edi,0FFFFFF48h
    363: lea     rsi,[k13]
    36a: call    ryo_h_AddrAbs
    36f: call    fn14
    374: nop     [rcx-0A0h]
    37b: mov     edi,0FFFFFF80h
    380: mov     esi,0FFFFFF60h
    385: call    ryo_h_MovW128
    38a: mov     edi,10h
    38f: mov     esi,0FFFFFF70h
    394: call    ryo_h_MovW128
    399: mov     rax,[rbp-78h]
    39d: mov     [rbp-38h],rax
    3a1: mov     qword ptr [rbp-0A8h],0
    3ac: mov     rax,[rbp-0A8h]
    3b3: cmp     rax,[rbp-38h]
    3b7: setb    [rbp-39h]
    3bb: test    byte ptr [rbp-39h],0FFh
    3bf: jne     427h
    3c1: mov     qword ptr [rbp-0D0h],0
    3cc: mov     rax,[rbp-38h]
    3d0: mov     [rbp-0C8h],rax
    3d7: mov     edi,0FFFFFF40h
    3dc: lea     rsi,[k15]
    3e3: call    ryo_h_AddrAbs
    3e8: lea     rdi,[sym16]
    3ef: lea     rsi,[site17]
    3f6: mov     edx,0FFFFFF58h
    3fb: call    ryo_h_CallExt
    400: test    rax,rax
    403: je      410h
    405: call    rax
    407: nop     [rcx-0A0h]
    40e: jmp     420h
    410: mov     rdi,rbp
    413: lea     rsi,[ro+4]
    41a: call    qword ptr [sym18]
    420: call    ryo_h_Unreachable
    425: ud2
    427: mov     rax,[rbp-80h]
    42b: mov     [rbp-88h],rax
    432: mov     eax,[rbp+28h]
    435: mov     [rbp-40h],eax
    438: mov     edi,0FFFFFF30h
    43d: mov     esi,0FFFFFFA0h
    442: call    ryo_h_MovW128
    447: mov     rax,[rbp+20h]
    44b: mov     [rbp-0C0h],rax
    452: mov     eax,[rbp-40h]
    455: mov     [rbp-0B8h],eax
    45b: mov     rax,[rbp+30h]
    45f: mov     [rbp-0B0h],rax
    466: call    fn19
    46b: nop     [rcx-39h]
    472: mov     rax,[rbp-88h]
    479: mov     [rbp+20h],rax
    47d: jmp     10h
    482: xor     edi,edi
    484: xor     esi,esi
    486: call    ryo_h_Ret
    48b: leave
    48c: ret
    48d: mov     rax,[rbp-30h]
    491: mov     [rbp-0D0h],rax
    498: mov     rax,[rbp-60h]
    49c: mov     [rbp-0C8h],rax
    4a3: mov     rax,[rbp-60h]
    4a7: mov     [rbp-0C0h],rax
    4ae: mov     edi,0FFFFFF48h
    4b3: lea     rsi,[k20]
    4ba: call    ryo_h_AddrAbs
    4bf: lea     rdi,[sym21]
    4c6: lea     rsi,[site22]
    4cd: mov     edx,0FFFFFF58h
    4d2: call    ryo_h_CallExt
    4d7: test    rax,rax
    4da: je      4E7h
    4dc: call    rax
    4de: nop     [rcx-39h]
    4e5: jmp     4F7h
    4e7: mov     rdi,rbp
    4ea: lea     rsi,[ro+20]
    4f1: call    qword ptr [sym23]
    4f7: call    ryo_h_Unreachable
    4fc: ud2
    4fe: mov     rax,[rbp-60h]
    502: sub     rax,[rbp-30h]
    506: mov     [rbp-68h],rax
    50a: mov     rax,[rbp+10h]
    50e: mov     [rbp-88h],rax
    515: mov     rax,[rbp+18h]
    519: mov     [rbp-80h],rax
    51d: mov     rax,[rbp-88h]
    524: mov     [rbp-90h],rax
    52b: imul    rcx,[rbp-30h],4
    530: add     rax,rcx
    533: mov     [rbp-98h],rax
    53a: mov     [rbp-78h],rax
    53e: mov     rax,[rbp-68h]
    542: mov     [rbp-70h],rax
    546: mov     rax,[rbp-78h]
    54a: mov     [rbp+10h],rax
    54e: mov     rax,[rbp-70h]
    552: mov     [rbp+18h],rax
    556: mov     qword ptr [rbp+20h],0
    55e: jmp     10h
    563: call    ryo_h_Unreachable
    568: ud2

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+20h]
     17: mov     [rbp-28h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-20h],rax
     23: mov     rax,[rbp-10h]
     27: mov     [rbp-40h],rax
     2b: mov     rax,[rbp-28h]
     2f: mov     [rbp-38h],rax
     33: mov     rax,[rbp-20h]
     37: mov     [rbp-30h],rax
     3b: call    fn0
     40: nop     [rcx-11h]
     47: movzx   eax,byte ptr [rbp-11h]
     4b: xor     al,1
     4e: mov     [rbp-1],al
     51: mov     edi,0FFFFFFFFh
     56: mov     esi,1
     5b: call    ryo_h_Ret
     60: leave
     61: ret

fn core::slice::sort::unstable::sort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-0Ah],0
      c: test    byte ptr [rbp-0Ah],0FFh
     10: jne     50h
     12: mov     rax,[rbp+18h]
     16: mov     [rbp-8],rax
     1a: cmp     rax,2
     1e: setb    [rbp-9]
     22: test    byte ptr [rbp-9],0FFh
     26: je      5Dh
     28: jmp     5Bh
     2a: nop     [rax+rax]
     30: jmp     50h
     32: nop     [rax+rax]
     3b: nop     [rax+rax]
     40: jmp     50h
     42: nop     [rax+rax]
     4b: nop     [rax+rax]
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: jmp     50h
     5d: cmp     qword ptr [rbp-8],14h
     62: setbe   [rbp-9]
     66: test    byte ptr [rbp-9],0FFh
     6a: je      99h
     6c: mov     edi,0FFFFFFD0h
     71: mov     esi,10h
     76: call    ryo_h_MovW128
     7b: mov     qword ptr [rbp-20h],1
     83: mov     rax,[rbp+20h]
     87: mov     [rbp-18h],rax
     8b: call    fn0
     90: nop     [rcx]
     97: jmp     30h
     99: mov     edi,0FFFFFFD0h
     9e: mov     esi,10h
     a3: call    ryo_h_MovW128
     a8: mov     rax,[rbp+20h]
     ac: mov     [rbp-20h],rax
     b0: call    fn1
     b5: nop     [rcx]
     bc: jmp     40h

fn core::ub_checks::maybe_is_nonoverlapping::runtime
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+20h]
     1f: mov     [rbp-38h],rax
     23: mov     rax,[rbp+28h]
     27: mov     [rbp-60h],rax
     2b: mov     edi,0FFFFFFA8h
     30: mov     esi,0FFFFFFB0h
     35: mov     edx,0FFFFFFC8h
     3a: mov     ecx,0FFFFFFA0h
     3f: call    ryo_h_MulOvfUW64
     44: mov     rax,[rbp-58h]
     48: mov     [rbp-38h],rax
     4c: movzx   eax,byte ptr [rbp-50h]
     50: mov     [rbp-1Dh],al
     53: mov     rax,[rbp-38h]
     57: mov     [rbp-68h],rax
     5b: test    byte ptr [rbp-1Dh],0FFh
     5f: je      0B9h
     61: mov     edi,0FFFFFF80h
     66: lea     rsi,[k0]
     6d: call    ryo_h_AddrAbs
     72: mov     qword ptr [rbp-78h],3Dh
     7a: lea     rdi,[sym1]
     81: lea     rsi,[site2]
     88: mov     edx,0FFFFFF90h
     8d: call    ryo_h_CallExt
     92: test    rax,rax
     95: je      0A2h
     97: call    rax
     99: nop     [rcx-1]
     a0: jmp     0B2h
     a2: mov     rdi,rbp
     a5: lea     rsi,[ro+4]
     ac: call    qword ptr [sym3]
     b2: call    ryo_h_Unreachable
     b7: ud2
     b9: mov     rax,[rbp-68h]
     bd: mov     [rbp-40h],rax
     c1: mov     qword ptr [rbp-48h],1
     c9: mov     [rbp-38h],rax
     cd: mov     rax,[rbp-28h]
     d1: cmp     rax,[rbp-30h]
     d5: jae     0E5h
     d7: mov     rax,[rbp-30h]
     db: sub     rax,[rbp-28h]
     df: mov     [rbp-10h],rax
     e3: jmp     0F1h
     e5: mov     rax,[rbp-28h]
     e9: sub     rax,[rbp-30h]
     ed: mov     [rbp-10h],rax
     f1: mov     rax,[rbp-38h]
     f5: cmp     rax,[rbp-10h]
     f9: setbe   [rbp-1]
     fd: mov     edi,0FFFFFFFFh
    102: mov     esi,1
    107: call    ryo_h_Ret
    10c: leave
    10d: ret

fn main
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,330h
      b: mov     qword ptr [rbp-330h],3D090h
     16: call    fn0
     1b: nop     [rcx-8]
     22: mov     rax,2545F4914F6CDD1Dh
     2c: mov     [rbp-10h],rax
     30: mov     qword ptr [rbp-50h],0
     38: mov     rax,[rbp-8]
     3c: mov     [rbp-48h],rax
     40: lea     rax,[rbp-10h]
     44: mov     [rbp-60h],rax
     48: mov     [rbp-58h],rax
     4c: mov     edi,0FFFFFCD0h
     51: mov     esi,0FFFFFFB0h
     56: call    ryo_h_MovW128
     5b: mov     rax,[rbp-58h]
     5f: mov     [rbp-320h],rax
     66: call    fn1
     6b: nop     [rcx-40h]
     72: mov     edi,0FFFFFCD0h
     77: mov     esi,0FFFFFFC0h
     7c: mov     edx,18h
     81: call    ryo_h_Copy
     86: call    fn2
     8b: nop     [rcx-28h]
     92: lea     rax,[rbp-28h]
     96: mov     [rbp-80h],rax
     9a: mov     [rbp-330h],rax
     a1: call    fn3
     a6: nop     [rcx-78h]
     ad: lea     rax,[rbp-78h]
     b1: mov     [rbp-98h],rax
     b8: mov     [rbp-330h],rax
     bf: call    fn4
     c4: nop     [rcx-90h]
     cb: mov     edi,0FFFFFCD0h
     d0: mov     esi,0FFFFFF70h
     d5: call    ryo_h_MovW128
     da: call    fn5
     df: nop     [rcx-80h]
     e6: lea     rax,[rbp-28h]
     ea: mov     [rbp-0B8h],rax
     f1: mov     [rbp-330h],rax
     f8: call    fn6
     fd: nop     [rcx-0B0h]
    104: lea     rax,[rbp-0B0h]
    10b: mov     [rbp-0D0h],rax
    112: mov     [rbp-330h],rax
    119: call    fn7
    11e: nop     [rcx-0C8h]
    125: mov     rax,[rbp-8]
    129: mov     [rbp-330h],rax
    130: call    fn8
    135: nop     [rcx-0F0h]
    13c: lea     rax,[rbp-0F0h]
    143: mov     [rbp-0D8h],rax
    14a: mov     edi,0FFFFFCD0h
    14f: mov     esi,0FFFFFF38h
    154: call    ryo_h_MovW128
    159: mov     rax,[rbp-0D8h]
    160: mov     [rbp-320h],rax
    167: call    fn9
    16c: nop     [rcx-0B8h]
    173: lea     rax,[rbp-0F0h]
    17a: mov     [rbp-2F8h],rax
    181: mov     [rbp-330h],rax
    188: call    fn10
    18d: nop     [rcx-2F8h]
    194: lea     rax,[rbp-78h]
    198: mov     [rbp-108h],rax
    19f: lea     rax,[rbp-0B0h]
    1a6: mov     [rbp-110h],rax
    1ad: mov     rax,[rbp-108h]
    1b4: mov     [rbp-100h],rax
    1bb: mov     rax,[rbp-110h]
    1c2: mov     [rbp-0F8h],rax
    1c9: mov     rax,[rbp-100h]
    1d0: mov     [rbp-118h],rax
    1d7: mov     rax,[rbp-0F8h]
    1de: mov     [rbp-120h],rax
    1e5: mov     rax,[rbp-118h]
    1ec: mov     [rbp-330h],rax
    1f3: mov     rax,[rbp-120h]
    1fa: mov     [rbp-328h],rax
    201: call    fn11
    206: nop     [rcx-121h]
    20d: test    byte ptr [rbp-121h],0FFh
    214: je      236h
    216: lea     rax,[rbp-28h]
    21a: mov     [rbp-188h],rax
    221: mov     [rbp-330h],rax
    228: call    fn12
    22d: nop     [rcx-180h]
    234: jmp     2A4h
    236: mov     byte ptr [rbp-122h],0
    23d: mov     qword ptr [rbp-138h],0
    248: movzx   eax,byte ptr [rbp-122h]
    24f: mov     [rbp-310h],al
    255: mov     rax,[rbp-118h]
    25c: mov     [rbp-330h],rax
    263: mov     rax,[rbp-120h]
    26a: mov     [rbp-328h],rax
    271: mov     edi,0FFFFFCE0h
    276: mov     esi,0FFFFFEC8h
    27b: call    ryo_h_MovW128
    280: mov     edi,0FFFFFCF8h
    285: lea     rsi,[k13]
    28c: call    ryo_h_AddrAbs
    291: call    fn14
    296: nop     [rcx-122h]
    29d: call    ryo_h_Unreachable
    2a2: ud2
    2a4: mov     edi,0FFFFFCD0h
    2a9: mov     esi,0FFFFFE80h
    2ae: call    ryo_h_MovW128
    2b3: call    fn15
    2b8: nop     [rcx-170h]
    2bf: mov     edi,0FFFFFCD0h
    2c4: mov     esi,0FFFFFE90h
    2c9: call    ryo_h_MovW128
    2ce: call    fn16
    2d3: nop     [rcx-160h]
    2da: mov     edi,0FFFFFCD0h
    2df: mov     esi,0FFFFFEA0h
    2e4: call    ryo_h_MovW128
    2e9: call    fn17
    2ee: nop     [rcx-150h]
    2f5: lea     rax,[rbp-150h]
    2fc: mov     [rbp-1A0h],rax
    303: mov     [rbp-330h],rax
    30a: call    fn18
    30f: nop     [rcx-198h]
    316: mov     edi,0FFFFFCD0h
    31b: mov     esi,0FFFFFE68h
    320: call    ryo_h_MovW128
    325: call    fn19
    32a: nop     [rcx-188h]
    331: lea     rax,[rbp-78h]
    335: mov     [rbp-1F8h],rax
    33c: mov     [rbp-330h],rax
    343: call    fn20
    348: nop     [rcx-1F0h]
    34f: mov     edi,0FFFFFCD0h
    354: mov     esi,0FFFFFE10h
    359: call    ryo_h_MovW128
    35e: call    fn21
    363: nop     [rcx-1E0h]
    36a: lea     rax,[rbp-1E0h]
    371: mov     [rbp-1D8h],rax
    378: lea     rax,[rbp-150h]
    37f: mov     [rbp-208h],rax
    386: mov     [rbp-330h],rax
    38d: mov     qword ptr [rbp-328h],0
    398: mov     edi,0FFFFFCE0h
    39d: lea     rsi,[k22]
    3a4: call    ryo_h_AddrAbs
    3a9: call    fn23
    3ae: nop     [rcx-200h]
    3b5: lea     rax,[rbp-150h]
    3bc: mov     [rbp-218h],rax
    3c3: mov     qword ptr [rbp-2F8h],1
    3ce: mov     edi,0FFFFFDD0h
    3d3: mov     esi,0FFFFFDD8h
    3d8: mov     edx,0FFFFFFF8h
    3dd: mov     ecx,0FFFFFD08h
    3e2: call    ryo_h_SubOvfUW64
    3e7: test    byte ptr [rbp-228h],0FFh
    3ee: je      440h
    3f0: mov     edi,0FFFFFCD0h
    3f5: lea     rsi,[k24]
    3fc: call    ryo_h_AddrAbs
    401: lea     rdi,[sym25]
    408: lea     rsi,[site26]
    40f: mov     edx,0FFFFFD08h
    414: call    ryo_h_CallExt
    419: test    rax,rax
    41c: je      429h
    41e: call    rax
    420: nop     [rcx-2F0h]
    427: jmp     439h
    429: mov     rdi,rbp
    42c: lea     rsi,[ro+4]
    433: call    qword ptr [sym27]
    439: call    ryo_h_Unreachable
    43e: ud2
    440: mov     rax,[rbp-230h]
    447: mov     [rbp-220h],rax
    44e: mov     rax,[rbp-218h]
    455: mov     [rbp-330h],rax
    45c: mov     rax,[rbp-220h]
    463: mov     [rbp-328h],rax
    46a: mov     edi,0FFFFFCE0h
    46f: lea     rsi,[k28]
    476: call    ryo_h_AddrAbs
    47b: call    fn29
    480: nop     [rcx-210h]
    487: lea     rax,[rbp-8]
    48b: mov     [rbp-238h],rax
    492: mov     rax,[rbp-1D8h]
    499: mov     [rbp-1D0h],rax
    4a0: mov     rax,[rbp-200h]
    4a7: mov     [rbp-1C8h],rax
    4ae: mov     rax,[rbp-210h]
    4b5: mov     [rbp-1C0h],rax
    4bc: mov     rax,[rbp-238h]
    4c3: mov     [rbp-1B8h],rax
    4ca: mov     [rbp-2D0h],rax
    4d1: mov     [rbp-330h],rax
    4d8: call    fn30
    4dd: nop     [rcx-288h]
    4e4: mov     rax,[rbp-1D0h]
    4eb: mov     [rbp-2D8h],rax
    4f2: mov     [rbp-330h],rax
    4f9: call    fn31
    4fe: nop     [rcx-298h]
    505: mov     rax,[rbp-1C8h]
    50c: mov     [rbp-2E0h],rax
    513: mov     [rbp-330h],rax
    51a: call    fn32
    51f: nop     [rcx-2A8h]
    526: mov     rax,[rbp-1C0h]
    52d: mov     [rbp-2E8h],rax
    534: mov     [rbp-330h],rax
    53b: call    fn33
    540: nop     [rcx-2B8h]
    547: mov     edi,0FFFFFD88h
    54c: mov     esi,0FFFFFD78h
    551: call    ryo_h_MovW128
    556: mov     edi,0FFFFFD98h
    55b: mov     esi,0FFFFFD68h
    560: call    ryo_h_MovW128
    565: mov     edi,0FFFFFDA8h
    56a: mov     esi,0FFFFFD58h
    56f: call    ryo_h_MovW128
    574: mov     edi,0FFFFFDB8h
    579: mov     esi,0FFFFFD48h
    57e: call    ryo_h_MovW128
    583: mov     edi,0FFFFFD40h
    588: lea     rsi,[k34]
    58f: call    ryo_h_AddrAbs
    594: lea     rax,[rbp-278h]
    59b: mov     [rbp-2C8h],rax
    5a2: mov     rax,[rbp-2C0h]
    5a9: mov     [rbp-330h],rax
    5b0: mov     rax,[rbp-2C8h]
    5b7: mov     [rbp-328h],rax
    5be: call    fn35
    5c3: nop     [rcx-1B0h]
    5ca: mov     edi,0FFFFFCD0h
    5cf: mov     esi,0FFFFFE50h
    5d4: call    ryo_h_MovW128
    5d9: lea     rdi,[sym36]
    5e0: lea     rsi,[site37]
    5e7: mov     edx,0FFFFFD08h
    5ec: call    ryo_h_CallExt
    5f1: test    rax,rax
    5f4: je      601h
    5f6: call    rax
    5f8: nop     [rcx-1A0h]
    5ff: jmp     611h
    601: mov     rdi,rbp
    604: lea     rsi,[ro+20]
    60b: call    qword ptr [sym38]
    611: lea     rax,[rbp-150h]
    618: mov     [rbp-2F8h],rax
    61f: mov     [rbp-330h],rax
    626: call    fn39
    62b: nop     [rcx-2F8h]
    632: lea     rax,[rbp-0B0h]
    639: mov     [rbp-2F8h],rax
    640: mov     [rbp-330h],rax
    647: call    fn40
    64c: nop     [rcx-2F8h]
    653: lea     rax,[rbp-78h]
    657: mov     [rbp-2F8h],rax
    65e: mov     [rbp-330h],rax
    665: call    fn41
    66a: nop     [rcx-2F8h]
    671: lea     rax,[rbp-28h]
    675: mov     [rbp-2F8h],rax
    67c: mov     [rbp-330h],rax
    683: call    fn42
    688: nop     [rcx-2F8h]
    68f: xor     edi,edi
    691: xor     esi,esi
    693: call    ryo_h_Ret
    698: leave
    699: ret
    69a: nop     [rax+rax]
    6a0: lea     rax,[rbp-150h]
    6a7: mov     [rbp-2F8h],rax
    6ae: mov     [rbp-330h],rax
    6b5: call    fn43
    6ba: nop     [rcx-2F8h]
    6c1: jmp     700h
    6c3: nop     [rax+rax]
    6cc: nop     [rax]
    6d0: lea     rax,[rbp-0F0h]
    6d7: mov     [rbp-2F8h],rax
    6de: mov     [rbp-330h],rax
    6e5: call    fn44
    6ea: nop     [rcx-2F8h]
    6f1: nop     [rax+rax]
    6fa: nop     [rax+rax]
    700: lea     rax,[rbp-0B0h]
    707: mov     [rbp-2F8h],rax
    70e: mov     [rbp-330h],rax
    715: call    fn45
    71a: nop     [rcx-2F8h]
    721: nop     [rax+rax]
    72a: nop     [rax+rax]
    730: lea     rax,[rbp-78h]
    734: mov     [rbp-2F8h],rax
    73b: mov     [rbp-330h],rax
    742: call    fn46
    747: nop     [rcx-2F8h]
    74e: xchg    ax,ax
    750: lea     rax,[rbp-28h]
    754: mov     [rbp-2F8h],rax
    75b: mov     [rbp-330h],rax
    762: call    fn47
    767: nop     [rcx-2F8h]
    76e: mov     edi,0FFFFFD10h
    773: call    ryo_h_Resume
    778: ud2
    77a: nop     [rax+rax]
    780: lea     rdi,[sym48]
    787: lea     rsi,[site49]
    78e: mov     edx,0FFFFFD08h
    793: call    ryo_h_CallExt
    798: test    rax,rax
    79b: je      7A8h
    79d: call    rax
    79f: nop     [rcx-2F0h]
    7a6: jmp     7B8h
    7a8: mov     rdi,rbp
    7ab: lea     rsi,[ro+4]
    7b2: call    qword ptr [sym50]
    7b8: call    ryo_h_Unreachable
    7bd: ud2
    7bf: mov     rdi,rax
    7c2: mov     esi,0FFFFFD10h
    7c7: call    ryo_h_Lpad
    7cc: jmp     750h
    7ce: mov     rdi,rax
    7d1: mov     esi,0FFFFFD10h
    7d6: call    ryo_h_Lpad
    7db: jmp     730h
    7e0: mov     rdi,rax
    7e3: mov     esi,0FFFFFD10h
    7e8: call    ryo_h_Lpad
    7ed: jmp     700h
    7f2: mov     rdi,rax
    7f5: mov     esi,0FFFFFD10h
    7fa: call    ryo_h_Lpad
    7ff: jmp     6D0h
    804: mov     rdi,rax
    807: mov     esi,0FFFFFD10h
    80c: call    ryo_h_Lpad
    811: jmp     6A0h
    816: mov     rdi,rax
    819: mov     esi,0FFFFFD10h
    81e: call    ryo_h_Lpad
    823: jmp     780h

fn main::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     [rbp-20h],rax
     17: call    fn0
     1c: nop     [rcx-10h]
     23: mov     edi,0FFFFFFFCh
     28: mov     esi,0FFFFFFF0h
     2d: call    ryo_h_TruncW64W32
     32: mov     edi,0FFFFFFFCh
     37: mov     esi,4
     3c: call    ryo_h_Ret
     41: leave
     42: ret

fn main::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     eax,[rax]
      e: mov     [rbp-0Ch],eax
     11: mov     dword ptr [rbp-18h],3E8h
     18: cmp     dword ptr [rbp-18h],0
     1c: sete    [rbp-11h]
     20: test    byte ptr [rbp-11h],0FFh
     24: je      76h
     26: mov     edi,0FFFFFFD0h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: lea     rdi,[sym1]
     3e: lea     rsi,[site2]
     45: mov     edx,0FFFFFFE0h
     4a: call    ryo_h_CallExt
     4f: test    rax,rax
     52: je      5Fh
     54: call    rax
     56: nop     [rcx-11h]
     5d: jmp     6Fh
     5f: mov     rdi,rbp
     62: lea     rsi,[ro+4]
     69: call    qword ptr [sym3]
     6f: call    ryo_h_Unreachable
     74: ud2
     76: mov     dword ptr [rbp-18h],3E8h
     7d: mov     edi,0FFFFFFF0h
     82: mov     esi,0FFFFFFF4h
     87: mov     edx,0FFFFFFE8h
     8c: call    ryo_h_RemUW32
     91: mov     eax,[rbp-10h]
     94: mov     [rbp-8],eax
     97: mov     eax,[rbp-0Ch]
     9a: mov     [rbp-4],eax
     9d: mov     edi,0FFFFFFF8h
     a2: mov     esi,8
     a7: call    ryo_h_Ret
     ac: leave
     ad: ret

fn main::{closure#2}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+18h]
      c: mov     eax,[rax]
      e: mov     [rbp-4],eax
     11: mov     edi,0FFFFFFFCh
     16: mov     esi,4
     1b: call    ryo_h_Ret
     20: leave
     21: ret

fn merge_sort
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,380h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-18h],rax
     1b: mov     [rbp-10h],rax
     1f: cmp     rax,10h
     23: ja      49Ah
     29: mov     rax,[rbp+10h]
     2d: mov     [rbp-58h],rax
     31: mov     rax,[rbp+18h]
     35: mov     [rbp-50h],rax
     39: mov     [rbp-48h],rax
     3d: mov     qword ptr [rbp-40h],1
     45: mov     [rbp-38h],rax
     49: mov     edi,0FFFFFC80h
     4e: mov     esi,0FFFFFFC0h
     53: call    ryo_h_MovW128
     58: call    fn0
     5d: nop     [rcx-30h]
     64: mov     edi,0FFFFFF98h
     69: mov     esi,0FFFFFFD0h
     6e: call    ryo_h_MovW128
     73: nop     [rax+rax]
     7c: nop     [rax]
     80: lea     rax,[rbp-68h]
     84: mov     [rbp-80h],rax
     88: mov     [rbp-380h],rax
     8f: call    fn1
     94: nop     [rcx-78h]
     9b: mov     rax,[rbp-78h]
     9f: mov     [rbp-88h],rax
     a6: mov     edi,0FFFFFF78h
     ab: xor     esi,esi
     ad: mov     edx,2
     b2: call    ryo_h_SwitchDenseW64
     b7: lea     rcx,[0C8h]
     be: movsxd  rax,[rcx+rax*4]
     c2: add     rax,rcx
     c5: jmp     rax
     c7: int3
     c8: .long   cc2h
     cc: .long   dbh
     d0: .long   d4h
     d4: call    ryo_h_Unreachable
     d9: ud2
     db: mov     rax,[rbp-70h]
     df: mov     [rbp-90h],rax
     e6: mov     [rbp-98h],rax
     ed: nop     [rax]
     f0: mov     rax,[rbp-98h]
     f7: mov     [rbp-0A8h],rax
     fe: cmp     rax,0
    102: jbe     80h
    108: mov     rax,[rbp-98h]
    10f: mov     [rbp-0C0h],rax
    116: mov     qword ptr [rbp-358h],1
    121: mov     edi,0FFFFFF30h
    126: mov     esi,0FFFFFF38h
    12b: mov     edx,0FFFFFF40h
    130: mov     ecx,0FFFFFCA8h
    135: call    ryo_h_SubOvfUW64
    13a: test    byte ptr [rbp-0C8h],0FFh
    141: je      193h
    143: mov     edi,0FFFFFC80h
    148: lea     rsi,[k2]
    14f: call    ryo_h_AddrAbs
    154: lea     rdi,[sym3]
    15b: lea     rsi,[site4]
    162: mov     edx,0FFFFFCA8h
    167: call    ryo_h_CallExt
    16c: test    rax,rax
    16f: je      17Ch
    171: call    rax
    173: nop     [rcx-350h]
    17a: jmp     18Ch
    17c: mov     rdi,rbp
    17f: lea     rsi,[ro+4]
    186: call    qword ptr [sym5]
    18c: call    ryo_h_Unreachable
    191: ud2
    193: mov     rax,[rbp-0D0h]
    19a: mov     [rbp-0B8h],rax
    1a1: mov     rax,[rbp+10h]
    1a5: mov     [rbp-0E0h],rax
    1ac: mov     rax,[rbp+18h]
    1b0: mov     [rbp-0D8h],rax
    1b7: mov     [rbp-0E8h],rax
    1be: mov     rax,[rbp-0B8h]
    1c5: cmp     rax,[rbp-0E8h]
    1cc: jb      233h
    1ce: mov     [rbp-380h],rax
    1d5: mov     rax,[rbp-0E8h]
    1dc: mov     [rbp-378h],rax
    1e3: mov     edi,0FFFFFC90h
    1e8: lea     rsi,[k6]
    1ef: call    ryo_h_AddrAbs
    1f4: lea     rdi,[sym7]
    1fb: lea     rsi,[site8]
    202: mov     edx,0FFFFFCA8h
    207: call    ryo_h_CallExt
    20c: test    rax,rax
    20f: je      21Ch
    211: call    rax
    213: nop     [rcx-350h]
    21a: jmp     22Ch
    21c: mov     rdi,rbp
    21f: lea     rsi,[ro+4]
    226: call    qword ptr [sym9]
    22c: call    ryo_h_Unreachable
    231: ud2
    233: mov     rax,[rbp+10h]
    237: imul    rcx,[rbp-0B8h],4
    23f: add     rax,rcx
    242: mov     [rbp-358h],rax
    249: mov     eax,[rax]
    24b: mov     [rbp-0B0h],eax
    251: mov     rax,[rbp-98h]
    258: mov     [rbp-0F8h],rax
    25f: mov     rax,[rbp+10h]
    263: mov     [rbp-108h],rax
    26a: mov     rax,[rbp+18h]
    26e: mov     [rbp-100h],rax
    275: mov     [rbp-110h],rax
    27c: mov     rax,[rbp-0F8h]
    283: cmp     rax,[rbp-110h]
    28a: jb      2F1h
    28c: mov     [rbp-380h],rax
    293: mov     rax,[rbp-110h]
    29a: mov     [rbp-378h],rax
    2a1: mov     edi,0FFFFFC90h
    2a6: lea     rsi,[k10]
    2ad: call    ryo_h_AddrAbs
    2b2: lea     rdi,[sym11]
    2b9: lea     rsi,[site12]
    2c0: mov     edx,0FFFFFCA8h
    2c5: call    ryo_h_CallExt
    2ca: test    rax,rax
    2cd: je      2DAh
    2cf: call    rax
    2d1: nop     [rcx-350h]
    2d8: jmp     2EAh
    2da: mov     rdi,rbp
    2dd: lea     rsi,[ro+4]
    2e4: call    qword ptr [sym13]
    2ea: call    ryo_h_Unreachable
    2ef: ud2
    2f1: mov     rax,[rbp+10h]
    2f5: imul    rcx,[rbp-0F8h],4
    2fd: add     rax,rcx
    300: mov     [rbp-358h],rax
    307: mov     eax,[rax]
    309: mov     [rbp-0F0h],eax
    30f: cmp     eax,[rbp-0B0h]
    315: jae     80h
    31b: mov     rax,[rbp-98h]
    322: mov     [rbp-128h],rax
    329: mov     qword ptr [rbp-358h],1
    334: mov     edi,0FFFFFEC8h
    339: mov     esi,0FFFFFED0h
    33e: mov     edx,0FFFFFED8h
    343: mov     ecx,0FFFFFCA8h
    348: call    ryo_h_SubOvfUW64
    34d: test    byte ptr [rbp-130h],0FFh
    354: je      3A6h
    356: mov     edi,0FFFFFC80h
    35b: lea     rsi,[k14]
    362: call    ryo_h_AddrAbs
    367: lea     rdi,[sym15]
    36e: lea     rsi,[site16]
    375: mov     edx,0FFFFFCA8h
    37a: call    ryo_h_CallExt
    37f: test    rax,rax
    382: je      38Fh
    384: call    rax
    386: nop     [rcx-350h]
    38d: jmp     39Fh
    38f: mov     rdi,rbp
    392: lea     rsi,[ro+4]
    399: call    qword ptr [sym17]
    39f: call    ryo_h_Unreachable
    3a4: ud2
    3a6: mov     rax,[rbp-138h]
    3ad: mov     [rbp-120h],rax
    3b4: mov     rax,[rbp-98h]
    3bb: mov     [rbp-140h],rax
    3c2: mov     edi,0FFFFFC80h
    3c7: mov     esi,10h
    3cc: call    ryo_h_MovW128
    3d1: mov     rax,[rbp-120h]
    3d8: mov     [rbp-370h],rax
    3df: mov     rax,[rbp-140h]
    3e6: mov     [rbp-368h],rax
    3ed: mov     edi,0FFFFFCA0h
    3f2: lea     rsi,[k18]
    3f9: call    ryo_h_AddrAbs
    3fe: call    fn19
    403: nop     [rcx-111h]
    40a: mov     qword ptr [rbp-358h],1
    415: mov     edi,0FFFFFEB0h
    41a: mov     esi,0FFFFFEB8h
    41f: mov     edx,0FFFFFF68h
    424: mov     ecx,0FFFFFCA8h
    429: call    ryo_h_SubOvfUW64
    42e: test    byte ptr [rbp-148h],0FFh
    435: je      487h
    437: mov     edi,0FFFFFC80h
    43c: lea     rsi,[k20]
    443: call    ryo_h_AddrAbs
    448: lea     rdi,[sym21]
    44f: lea     rsi,[site22]
    456: mov     edx,0FFFFFCA8h
    45b: call    ryo_h_CallExt
    460: test    rax,rax
    463: je      470h
    465: call    rax
    467: nop     [rcx-350h]
    46e: jmp     480h
    470: mov     rdi,rbp
    473: lea     rsi,[ro+4]
    47a: call    qword ptr [sym23]
    480: call    ryo_h_Unreachable
    485: ud2
    487: mov     rax,[rbp-150h]
    48e: mov     [rbp-98h],rax
    495: jmp     0F0h
    49a: mov     rax,[rbp+10h]
    49e: mov     [rbp-170h],rax
    4a5: mov     rax,[rbp+18h]
    4a9: mov     [rbp-168h],rax
    4b0: mov     [rbp-160h],rax
    4b7: mov     qword ptr [rbp-358h],2
    4c2: cmp     qword ptr [rbp-358h],0
    4ca: sete    [rbp-171h]
    4d1: test    byte ptr [rbp-171h],0FFh
    4d8: je      52Ah
    4da: mov     edi,0FFFFFC80h
    4df: lea     rsi,[k24]
    4e6: call    ryo_h_AddrAbs
    4eb: lea     rdi,[sym25]
    4f2: lea     rsi,[site26]
    4f9: mov     edx,0FFFFFCA8h
    4fe: call    ryo_h_CallExt
    503: test    rax,rax
    506: je      513h
    508: call    rax
    50a: nop     [rcx-350h]
    511: jmp     523h
    513: mov     rdi,rbp
    516: lea     rsi,[ro+4]
    51d: call    qword ptr [sym27]
    523: call    ryo_h_Unreachable
    528: ud2
    52a: mov     qword ptr [rbp-358h],2
    535: mov     edi,0FFFFFEA8h
    53a: mov     esi,0FFFFFEA0h
    53f: mov     edx,0FFFFFCA8h
    544: call    ryo_h_DivUW64
    549: mov     rax,[rbp-158h]
    550: mov     [rbp-190h],rax
    557: mov     edi,0FFFFFC80h
    55c: mov     esi,10h
    561: call    ryo_h_MovW128
    566: mov     rax,[rbp-190h]
    56d: mov     [rbp-370h],rax
    574: mov     edi,0FFFFFC98h
    579: lea     rsi,[k28]
    580: call    ryo_h_AddrAbs
    585: call    fn29
    58a: nop     [rcx-188h]
    591: mov     edi,0FFFFFC80h
    596: mov     esi,0FFFFFE78h
    59b: call    ryo_h_MovW128
    5a0: mov     rax,[rbp+20h]
    5a4: mov     [rbp-370h],rax
    5ab: call    fn30
    5b0: nop     [rcx-171h]
    5b7: mov     rax,[rbp-158h]
    5be: mov     [rbp-1A8h],rax
    5c5: mov     edi,0FFFFFC80h
    5ca: mov     esi,10h
    5cf: call    ryo_h_MovW128
    5d4: mov     rax,[rbp-1A8h]
    5db: mov     [rbp-370h],rax
    5e2: mov     edi,0FFFFFC98h
    5e7: lea     rsi,[k31]
    5ee: call    ryo_h_AddrAbs
    5f3: call    fn32
    5f8: nop     [rcx-1A0h]
    5ff: mov     edi,0FFFFFC80h
    604: mov     esi,0FFFFFE60h
    609: call    ryo_h_MovW128
    60e: mov     rax,[rbp+20h]
    612: mov     [rbp-370h],rax
    619: call    fn33
    61e: nop     [rcx-190h]
    625: mov     rax,[rbp+20h]
    629: mov     [rbp-380h],rax
    630: call    fn34
    635: nop     [rcx-1A8h]
    63c: mov     qword ptr [rbp-1C8h],0
    647: mov     rax,[rbp-158h]
    64e: mov     [rbp-1C0h],rax
    655: mov     rax,[rbp-1C8h]
    65c: mov     [rbp-1B0h],rax
    663: mov     rax,[rbp-1C0h]
    66a: mov     [rbp-1B8h],rax
    671: nop     [rax+rax]
    67a: nop     [rax+rax]
    680: mov     rax,[rbp-1B0h]
    687: mov     [rbp-1D8h],rax
    68e: cmp     rax,[rbp-158h]
    695: jae     0B44h
    69b: mov     rax,[rbp-1B8h]
    6a2: mov     [rbp-1E8h],rax
    6a9: mov     rax,[rbp+10h]
    6ad: mov     [rbp-200h],rax
    6b4: mov     rax,[rbp+18h]
    6b8: mov     [rbp-1F8h],rax
    6bf: mov     [rbp-1F0h],rax
    6c6: mov     rax,[rbp-1E8h]
    6cd: cmp     rax,[rbp-1F0h]
    6d4: jae     0B44h
    6da: mov     rax,[rbp-1B0h]
    6e1: mov     [rbp-210h],rax
    6e8: mov     rax,[rbp+10h]
    6ec: mov     [rbp-220h],rax
    6f3: mov     rax,[rbp+18h]
    6f7: mov     [rbp-218h],rax
    6fe: mov     [rbp-228h],rax
    705: mov     rax,[rbp-210h]
    70c: cmp     rax,[rbp-228h]
    713: jb      77Ah
    715: mov     [rbp-380h],rax
    71c: mov     rax,[rbp-228h]
    723: mov     [rbp-378h],rax
    72a: mov     edi,0FFFFFC90h
    72f: lea     rsi,[k35]
    736: call    ryo_h_AddrAbs
    73b: lea     rdi,[sym36]
    742: lea     rsi,[site37]
    749: mov     edx,0FFFFFCA8h
    74e: call    ryo_h_CallExt
    753: test    rax,rax
    756: je      763h
    758: call    rax
    75a: nop     [rcx-350h]
    761: jmp     773h
    763: mov     rdi,rbp
    766: lea     rsi,[ro+4]
    76d: call    qword ptr [sym38]
    773: call    ryo_h_Unreachable
    778: ud2
    77a: mov     rax,[rbp+10h]
    77e: imul    rcx,[rbp-210h],4
    786: add     rax,rcx
    789: mov     [rbp-358h],rax
    790: mov     eax,[rax]
    792: mov     [rbp-208h],eax
    798: mov     rax,[rbp-1B8h]
    79f: mov     [rbp-238h],rax
    7a6: mov     rax,[rbp+10h]
    7aa: mov     [rbp-248h],rax
    7b1: mov     rax,[rbp+18h]
    7b5: mov     [rbp-240h],rax
    7bc: mov     [rbp-250h],rax
    7c3: mov     rax,[rbp-238h]
    7ca: cmp     rax,[rbp-250h]
    7d1: jb      838h
    7d3: mov     [rbp-380h],rax
    7da: mov     rax,[rbp-250h]
    7e1: mov     [rbp-378h],rax
    7e8: mov     edi,0FFFFFC90h
    7ed: lea     rsi,[k39]
    7f4: call    ryo_h_AddrAbs
    7f9: lea     rdi,[sym40]
    800: lea     rsi,[site41]
    807: mov     edx,0FFFFFCA8h
    80c: call    ryo_h_CallExt
    811: test    rax,rax
    814: je      821h
    816: call    rax
    818: nop     [rcx-350h]
    81f: jmp     831h
    821: mov     rdi,rbp
    824: lea     rsi,[ro+4]
    82b: call    qword ptr [sym42]
    831: call    ryo_h_Unreachable
    836: ud2
    838: mov     rax,[rbp+10h]
    83c: imul    rcx,[rbp-238h],4
    844: add     rax,rcx
    847: mov     [rbp-358h],rax
    84e: mov     eax,[rax]
    850: mov     [rbp-230h],eax
    856: cmp     eax,[rbp-208h]
    85c: jb      9D3h
    862: mov     rax,[rbp-1B0h]
    869: mov     [rbp-260h],rax
    870: mov     rax,[rbp+10h]
    874: mov     [rbp-270h],rax
    87b: mov     rax,[rbp+18h]
    87f: mov     [rbp-268h],rax
    886: mov     [rbp-278h],rax
    88d: mov     rax,[rbp-260h]
    894: cmp     rax,[rbp-278h]
    89b: jb      902h
    89d: mov     [rbp-380h],rax
    8a4: mov     rax,[rbp-278h]
    8ab: mov     [rbp-378h],rax
    8b2: mov     edi,0FFFFFC90h
    8b7: lea     rsi,[k43]
    8be: call    ryo_h_AddrAbs
    8c3: lea     rdi,[sym44]
    8ca: lea     rsi,[site45]
    8d1: mov     edx,0FFFFFCA8h
    8d6: call    ryo_h_CallExt
    8db: test    rax,rax
    8de: je      8EBh
    8e0: call    rax
    8e2: nop     [rcx-350h]
    8e9: jmp     8FBh
    8eb: mov     rdi,rbp
    8ee: lea     rsi,[ro+4]
    8f5: call    qword ptr [sym46]
    8fb: call    ryo_h_Unreachable
    900: ud2
    902: mov     rax,[rbp+10h]
    906: imul    rcx,[rbp-260h],4
    90e: add     rax,rcx
    911: mov     [rbp-358h],rax
    918: mov     eax,[rax]
    91a: mov     [rbp-258h],eax
    920: mov     rax,[rbp+20h]
    924: mov     [rbp-380h],rax
    92b: mov     eax,[rbp-258h]
    931: mov     [rbp-378h],eax
    937: call    fn47
    93c: nop     [rcx-251h]
    943: mov     qword ptr [rbp-358h],1
    94e: mov     edi,0FFFFFD70h
    953: mov     esi,0FFFFFD78h
    958: mov     edx,0FFFFFE50h
    95d: mov     ecx,0FFFFFCA8h
    962: call    ryo_h_AddOvfUW64
    967: test    byte ptr [rbp-288h],0FFh
    96e: je      9C0h
    970: mov     edi,0FFFFFC80h
    975: lea     rsi,[k48]
    97c: call    ryo_h_AddrAbs
    981: lea     rdi,[sym49]
    988: lea     rsi,[site50]
    98f: mov     edx,0FFFFFCA8h
    994: call    ryo_h_CallExt
    999: test    rax,rax
    99c: je      9A9h
    99e: call    rax
    9a0: nop     [rcx-350h]
    9a7: jmp     9B9h
    9a9: mov     rdi,rbp
    9ac: lea     rsi,[ro+4]
    9b3: call    qword ptr [sym51]
    9b9: call    ryo_h_Unreachable
    9be: ud2
    9c0: mov     rax,[rbp-290h]
    9c7: mov     [rbp-1B0h],rax
    9ce: jmp     680h
    9d3: mov     rax,[rbp-1B8h]
    9da: mov     [rbp-2A0h],rax
    9e1: mov     rax,[rbp+10h]
    9e5: mov     [rbp-2B0h],rax
    9ec: mov     rax,[rbp+18h]
    9f0: mov     [rbp-2A8h],rax
    9f7: mov     [rbp-2B8h],rax
    9fe: mov     rax,[rbp-2A0h]
    a05: cmp     rax,[rbp-2B8h]
    a0c: jb      0A73h
    a0e: mov     [rbp-380h],rax
    a15: mov     rax,[rbp-2B8h]
    a1c: mov     [rbp-378h],rax
    a23: mov     edi,0FFFFFC90h
    a28: lea     rsi,[k52]
    a2f: call    ryo_h_AddrAbs
    a34: lea     rdi,[sym53]
    a3b: lea     rsi,[site54]
    a42: mov     edx,0FFFFFCA8h
    a47: call    ryo_h_CallExt
    a4c: test    rax,rax
    a4f: je      0A5Ch
    a51: call    rax
    a53: nop     [rcx-350h]
    a5a: jmp     0A6Ch
    a5c: mov     rdi,rbp
    a5f: lea     rsi,[ro+4]
    a66: call    qword ptr [sym55]
    a6c: call    ryo_h_Unreachable
    a71: ud2
    a73: mov     rax,[rbp+10h]
    a77: imul    rcx,[rbp-2A0h],4
    a7f: add     rax,rcx
    a82: mov     [rbp-358h],rax
    a89: mov     eax,[rax]
    a8b: mov     [rbp-294h],eax
    a91: mov     rax,[rbp+20h]
    a95: mov     [rbp-380h],rax
    a9c: mov     eax,[rbp-294h]
    aa2: mov     [rbp-378h],eax
    aa8: call    fn56
    aad: nop     [rcx-290h]
    ab4: mov     qword ptr [rbp-358h],1
    abf: mov     edi,0FFFFFD30h
    ac4: mov     esi,0FFFFFD38h
    ac9: mov     edx,0FFFFFE48h
    ace: mov     ecx,0FFFFFCA8h
    ad3: call    ryo_h_AddOvfUW64
    ad8: test    byte ptr [rbp-2C8h],0FFh
    adf: je      0B31h
    ae1: mov     edi,0FFFFFC80h
    ae6: lea     rsi,[k57]
    aed: call    ryo_h_AddrAbs
    af2: lea     rdi,[sym58]
    af9: lea     rsi,[site59]
    b00: mov     edx,0FFFFFCA8h
    b05: call    ryo_h_CallExt
    b0a: test    rax,rax
    b0d: je      0B1Ah
    b0f: call    rax
    b11: nop     [rcx-350h]
    b18: jmp     0B2Ah
    b1a: mov     rdi,rbp
    b1d: lea     rsi,[ro+4]
    b24: call    qword ptr [sym60]
    b2a: call    ryo_h_Unreachable
    b2f: ud2
    b31: mov     rax,[rbp-2D0h]
    b38: mov     [rbp-1B8h],rax
    b3f: jmp     680h
    b44: mov     rax,[rbp+10h]
    b48: mov     [rbp-2F0h],rax
    b4f: mov     rax,[rbp+18h]
    b53: mov     [rbp-2E8h],rax
    b5a: mov     rax,[rbp-1B0h]
    b61: mov     [rbp-308h],rax
    b68: mov     [rbp-300h],rax
    b6f: mov     rax,[rbp-158h]
    b76: mov     [rbp-2F8h],rax
    b7d: mov     edi,0FFFFFC80h
    b82: mov     esi,0FFFFFD10h
    b87: call    ryo_h_MovW128
    b8c: mov     edi,0FFFFFC90h
    b91: mov     esi,0FFFFFD00h
    b96: call    ryo_h_MovW128
    b9b: mov     edi,0FFFFFCA0h
    ba0: lea     rsi,[k61]
    ba7: call    ryo_h_AddrAbs
    bac: call    fn62
    bb1: nop     [rcx-2E0h]
    bb8: mov     rax,[rbp+20h]
    bbc: mov     [rbp-380h],rax
    bc3: mov     edi,0FFFFFC88h
    bc8: mov     esi,0FFFFFD20h
    bcd: call    ryo_h_MovW128
    bd2: call    fn63
    bd7: nop     [rcx-2D0h]
    bde: mov     rax,[rbp+10h]
    be2: mov     [rbp-328h],rax
    be9: mov     rax,[rbp+18h]
    bed: mov     [rbp-320h],rax
    bf4: mov     rax,[rbp-1B8h]
    bfb: mov     [rbp-338h],rax
    c02: mov     [rbp-330h],rax
    c09: mov     edi,0FFFFFC80h
    c0e: mov     esi,0FFFFFCD8h
    c13: call    ryo_h_MovW128
    c18: mov     rax,[rbp-330h]
    c1f: mov     [rbp-370h],rax
    c26: mov     edi,0FFFFFC98h
    c2b: lea     rsi,[k64]
    c32: call    ryo_h_AddrAbs
    c37: call    fn65
    c3c: nop     [rcx-318h]
    c43: mov     rax,[rbp+20h]
    c47: mov     [rbp-380h],rax
    c4e: mov     edi,0FFFFFC88h
    c53: mov     esi,0FFFFFCE8h
    c58: call    ryo_h_MovW128
    c5d: call    fn66
    c62: nop     [rcx-308h]
    c69: mov     rax,[rbp+20h]
    c6d: mov     [rbp-350h],rax
    c74: mov     [rbp-380h],rax
    c7b: call    fn67
    c80: nop     [rcx-348h]
    c87: mov     edi,0FFFFFC80h
    c8c: mov     esi,10h
    c91: call    ryo_h_MovW128
    c96: mov     edi,0FFFFFC90h
    c9b: mov     esi,0FFFFFCB8h
    ca0: call    ryo_h_MovW128
    ca5: mov     edi,0FFFFFCA0h
    caa: lea     rsi,[k68]
    cb1: call    ryo_h_AddrAbs
    cb6: call    fn69
    cbb: nop     [rcx-338h]
    cc2: xor     edi,edi
    cc4: xor     esi,esi
    cc6: call    ryo_h_Ret
    ccb: leave
    ccc: ret

fn std::array::iter::iter_inner::PolymorphicIter::<[std::mem::MaybeUninit<usize>]>::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-58h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     rax,[rax]
     1e: mov     [rbp-60h],rax
     22: mov     rax,[rbp-58h]
     26: sub     rax,[rbp-60h]
     2a: mov     [rbp-50h],rax
     2e: cmp     rax,0
     32: jbe     51h
     34: mov     rax,[rbp+10h]
     38: mov     rax,[rax]
     3b: mov     [rbp-50h],rax
     3f: mov     byte ptr [rbp-99h],1
     46: test    byte ptr [rbp-99h],0FFh
     4d: je      0CAh
     4f: jmp     97h
     51: mov     edi,0FFFFFFC0h
     56: lea     rsi,[k0]
     5d: mov     edx,10h
     62: call    ryo_h_Const
     67: mov     rax,[rbp+10h]
     6b: lea     rax,[rax+10h]
     6f: mov     [rbp-28h],rax
     73: mov     rax,[rbp+18h]
     77: mov     [rbp-20h],rax
     7b: mov     edi,0FFFFFF68h
     80: mov     esi,0FFFFFFD8h
     85: call    ryo_h_MovW128
     8a: mov     qword ptr [rbp-10h],0
     92: jmp     150h
     97: mov     rax,[rbp-50h]
     9b: mov     [rbp-0C0h],rax
     a2: mov     qword ptr [rbp-0B8h],1
     ad: mov     edi,0FFFFFF50h
     b2: lea     rsi,[k1]
     b9: call    ryo_h_AddrAbs
     be: call    fn2
     c3: nop     [rcx-30h]
     ca: mov     rax,[rbp-50h]
     ce: add     rax,1
     d2: mov     [rbp-58h],rax
     d6: mov     rax,[rbp+10h]
     da: mov     rcx,[rbp-58h]
     de: mov     [rax],rcx
     e1: mov     rax,[rbp-50h]
     e5: mov     [rbp-38h],rax
     e9: mov     qword ptr [rbp-40h],1
     f1: mov     rax,[rbp+10h]
     f5: lea     rax,[rax+10h]
     f9: mov     [rbp-28h],rax
     fd: mov     rax,[rbp+18h]
    101: mov     [rbp-20h],rax
    105: mov     edi,0FFFFFF68h
    10a: mov     esi,0FFFFFFD8h
    10f: call    ryo_h_MovW128
    114: mov     rax,[rbp-38h]
    118: mov     [rbp-48h],rax
    11c: mov     edi,0FFFFFF78h
    121: mov     esi,0FFFFFFD8h
    126: call    ryo_h_MovW128
    12b: mov     edi,0FFFFFFA0h
    130: mov     esi,0FFFFFFD8h
    135: call    ryo_h_MovW128
    13a: mov     byte ptr [rbp-99h],1
    141: test    byte ptr [rbp-99h],0FFh
    148: je      19Ch
    14a: jmp     161h
    14c: nop     [rax]
    150: mov     edi,0FFFFFFF0h
    155: mov     esi,10h
    15a: call    ryo_h_Ret
    15f: leave
    160: ret
    161: mov     rax,[rbp-20h]
    165: mov     [rbp-70h],rax
    169: mov     rax,[rbp-48h]
    16d: mov     [rbp-0C0h],rax
    174: mov     rax,[rbp-70h]
    178: mov     [rbp-0B8h],rax
    17f: mov     edi,0FFFFFF50h
    184: lea     rsi,[k3]
    18b: call    ryo_h_AddrAbs
    190: call    fn4
    195: nop     [rcx-30h]
    19c: mov     rax,[rbp-20h]
    1a0: mov     [rbp-78h],rax
    1a4: mov     rax,[rbp-48h]
    1a8: cmp     rax,[rbp-78h]
    1ac: setb    [rbp-69h]
    1b0: mov     rax,[rbp-28h]
    1b4: imul    rcx,[rbp-48h],8
    1b9: add     rax,rcx
    1bc: mov     [rbp-0A0h],rax
    1c3: mov     [rbp-68h],rax
    1c7: mov     rdi,rbp
    1ca: lea     rsi,[ro+4]
    1d1: call    qword ptr [sym5]
    1d7: mov     rax,[rbp-68h]
    1db: mov     [rbp-70h],rax
    1df: mov     rax,[rax]
    1e2: mov     [rbp-50h],rax
    1e6: mov     [rbp-8],rax
    1ea: mov     qword ptr [rbp-10h],1
    1f2: jmp     150h

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     eax,[rax]
      e: mov     [rbp-8],eax
     11: mov     rax,[rbp+18h]
     15: mov     eax,[rax]
     17: mov     [rbp-0Ch],eax
     1a: mov     eax,[rbp-8]
     1d: cmp     eax,[rbp-0Ch]
     20: setb    [rbp-1]
     24: mov     edi,0FFFFFFFFh
     29: mov     esi,1
     2e: call    ryo_h_Ret
     33: leave
     34: ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     rax,[rax]
     1a: mov     [rbp-18h],rax
     1e: mov     rax,[rbp-10h]
     22: cmp     rax,[rbp-18h]
     26: setb    [rbp-1]
     2a: mov     edi,0FFFFFFFFh
     2f: mov     esi,1
     34: call    ryo_h_Ret
     39: leave
     3a: ret

fn std::fmt::Arguments::<'_>::new::<22, 4>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-20h],rax
     18: mov     rax,[rbp-18h]
     1c: mov     [rbp-10h],rax
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-8],rax
     28: mov     edi,0FFFFFFF0h
     2d: mov     esi,10h
     32: call    ryo_h_Ret
     37: leave
     38: ret

fn std::fmt::DebugList::<'_, '_>::entries::<&u32, std::slice::Iter<'_, u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     edi,0FFFFFF70h
     10: mov     esi,18h
     15: call    ryo_h_MovW128
     1a: call    fn0
     1f: nop     [rcx-28h]
     26: mov     edi,0FFFFFFC8h
     2b: mov     esi,0FFFFFFD8h
     30: call    ryo_h_MovW128
     35: nop     [rax+rax]
     3e: xchg    ax,ax
     40: lea     rax,[rbp-38h]
     44: mov     [rbp-48h],rax
     48: mov     [rbp-90h],rax
     4f: call    fn1
     54: nop     [rcx-40h]
     5b: mov     edi,0FFFFFF8Ch
     60: mov     esi,0FFFFFFC0h
     65: xor     edx,edx
     67: xor     ecx,ecx
     69: xor     r8d,r8d
     6c: mov     r9d,1
     72: call    ryo_h_DiscrNicheW64
     77: mov     edi,0FFFFFFF0h
     7c: mov     esi,0FFFFFF8Ch
     81: call    ryo_h_ZextW32W64
     86: mov     edi,0FFFFFFF0h
     8b: xor     esi,esi
     8d: mov     edx,2
     92: call    ryo_h_SwitchDenseW64
     97: lea     rcx,[0A8h]
     9e: movsxd  rax,[rcx+rax*4]
     a2: add     rax,rcx
     a5: jmp     rax
     a7: int3
     a8: .long   134h
     ac: .long   bbh
     b0: .long   b4h
     b4: call    ryo_h_Unreachable
     b9: ud2
     bb: mov     rax,[rbp-40h]
     bf: mov     [rbp-50h],rax
     c3: lea     rax,[rbp-50h]
     c7: mov     [rbp-70h],rax
     cb: mov     [rbp-68h],rax
     cf: mov     edi,0FFFFFFA0h
     d4: lea     rsi,[k2]
     db: call    ryo_h_AddrAbs
     e0: mov     rax,[rbp+10h]
     e4: mov     [rbp-90h],rax
     eb: mov     edi,0FFFFFF78h
     f0: mov     esi,0FFFFFF98h
     f5: call    ryo_h_MovW128
     fa: lea     rdi,[sym3]
    101: lea     rsi,[site4]
    108: mov     edx,0FFFFFF88h
    10d: call    ryo_h_CallExt
    112: test    rax,rax
    115: je      122h
    117: call    rax
    119: nop     [rcx-58h]
    120: jmp     132h
    122: mov     rdi,rbp
    125: lea     rsi,[ro+4]
    12c: call    qword ptr [sym5]
    132: jmp     136h
    134: jmp     13Bh
    136: jmp     40h
    13b: mov     rax,[rbp+10h]
    13f: mov     [rbp-8],rax
    143: mov     edi,0FFFFFFF8h
    148: mov     esi,8
    14d: call    ryo_h_Ret
    152: leave
    153: ret
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     edi,0FFFFFFE8h
    165: call    ryo_h_Resume
    16a: ud2
    16c: mov     rdi,rax
    16f: mov     esi,0FFFFFFE8h
    174: call    ryo_h_Lpad
    179: jmp     160h
    17b: mov     rdi,rax
    17e: mov     esi,0FFFFFFE8h
    183: call    ryo_h_Lpad
    188: jmp     160h

fn std::hint::assert_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: test    byte ptr [rbp+10h],0FFh
      f: jne     0E9h
     15: mov     edi,0FFFFFFF0h
     1a: lea     rsi,[k0]
     21: call    ryo_h_AddrAbs
     26: mov     qword ptr [rbp-8],0DDh
     2e: mov     rax,[rbp-10h]
     32: mov     [rbp-40h],rax
     36: mov     rax,[rbp-8]
     3a: mov     [rbp-38h],rax
     3e: mov     rax,[rbp-40h]
     42: mov     [rbp-30h],rax
     46: mov     [rbp-28h],rax
     4a: mov     edi,0FFFFFFA8h
     4f: lea     rsi,[k1]
     56: call    ryo_h_AddrAbs
     5b: mov     qword ptr [rbp-50h],0DDh
     63: mov     rax,[rbp-50h]
     67: mov     [rbp-48h],rax
     6b: shl     rax,1
     6f: mov     [rbp-40h],rax
     73: or      rax,1
     77: mov     [rbp-38h],rax
     7b: mov     [rbp-30h],rax
     7f: mov     rax,[rbp-28h]
     83: mov     [rbp-20h],rax
     87: mov     rax,[rbp-30h]
     8b: mov     [rbp-18h],rax
     8f: mov     edi,0FFFFFF80h
     94: mov     esi,0FFFFFFE0h
     99: call    ryo_h_MovW128
     9e: mov     byte ptr [rbp-70h],0
     a2: mov     rax,[rbp+18h]
     a6: mov     [rbp-68h],rax
     aa: lea     rdi,[sym2]
     b1: lea     rsi,[site3]
     b8: mov     edx,0FFFFFFA0h
     bd: call    ryo_h_CallExt
     c2: test    rax,rax
     c5: je      0D2h
     c7: call    rax
     c9: nop     [rcx-10h]
     d0: jmp     0E2h
     d2: mov     rdi,rbp
     d5: lea     rsi,[ro+4]
     dc: call    qword ptr [sym4]
     e2: call    ryo_h_Unreachable
     e7: ud2
     e9: xor     edi,edi
     eb: xor     esi,esi
     ed: call    ryo_h_Ret
     f2: leave
     f3: ret

fn std::hint::black_box::<usize>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     edi,0FFFFFFF8h
     15: mov     esi,8
     1a: call    ryo_h_Ret
     1f: leave
     20: ret

fn std::hint::select_unpredictable::<*const (u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-40h],rax
     13: mov     [rbp-38h],rax
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+20h]
     1f: mov     [rbp-48h],rax
     23: mov     [rbp-40h],rax
     27: mov     [rbp-38h],rax
     2b: lea     rax,[rbp-30h]
     2f: mov     [rbp-48h],rax
     33: mov     [rbp-40h],rax
     37: lea     rax,[rbp-38h]
     3b: mov     [rbp-50h],rax
     3f: mov     [rbp-48h],rax
     43: movzx   eax,byte ptr [rbp+18h]
     47: mov     [rbp-88h],al
     4d: mov     rax,[rbp-40h]
     51: mov     [rbp-90h],rax
     58: mov     rax,[rbp-48h]
     5c: mov     [rbp-80h],rax
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym0]
     70: movzx   eax,byte ptr [rbp+18h]
     74: mov     [rbp-88h],al
     7a: mov     rax,[rbp-48h]
     7e: mov     [rbp-90h],rax
     85: mov     rax,[rbp-40h]
     89: mov     [rbp-80h],rax
     8d: mov     rdi,rbp
     90: lea     rsi,[ro+16]
     97: call    qword ptr [sym1]
     9d: mov     rax,[rbp-50h]
     a1: mov     [rbp-58h],rax
     a5: mov     rax,[rbp-20h]
     a9: mov     [rbp-60h],rax
     ad: mov     [rbp-90h],rax
     b4: mov     edi,0FFFFFF88h
     b9: lea     rsi,[sym2]
     c0: call    ryo_h_AddrSym
     c5: mov     rdi,rbp
     c8: lea     rsi,[ro+28]
     cf: call    qword ptr [sym3]
     d5: jmp     12Dh
     d7: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     177h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     edi,0FFFFFFD8h
    105: call    ryo_h_Resume
    10a: ud2
    10c: nop     [rax]
    110: lea     rax,[rbp-58h]
    114: mov     [rbp-78h],rax
    118: mov     [rbp-90h],rax
    11f: call    fn5
    124: nop     [rcx-78h]
    12b: jmp     100h
    12d: mov     rax,[rbp-58h]
    131: mov     [rbp-60h],rax
    135: mov     rax,[rbp-30h]
    139: mov     [rbp-68h],rax
    13d: mov     rax,[rbp-38h]
    141: mov     [rbp-70h],rax
    145: movzx   eax,byte ptr [rbp+18h]
    149: mov     [rbp-88h],al
    14f: mov     rax,[rbp-68h]
    153: mov     [rbp-90h],rax
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-80h],rax
    162: mov     rdi,rbp
    165: lea     rsi,[ro+44]
    16c: call    qword ptr [sym6]
    172: jmp     0E0h
    177: mov     rax,[rbp-60h]
    17b: mov     [rbp-8],rax
    17f: mov     edi,0FFFFFFF8h
    184: mov     esi,8
    189: call    ryo_h_Ret
    18e: leave
    18f: ret
    190: lea     rdi,[sym7]
    197: lea     rsi,[site8]
    19e: mov     edx,0FFFFFF88h
    1a3: call    ryo_h_CallExt
    1a8: test    rax,rax
    1ab: je      1B8h
    1ad: call    rax
    1af: nop     [rcx-70h]
    1b6: jmp     1C8h
    1b8: mov     rdi,rbp
    1bb: lea     rsi,[ro+56]
    1c2: call    qword ptr [sym9]
    1c8: call    ryo_h_Unreachable
    1cd: ud2
    1cf: mov     rdi,rax
    1d2: mov     esi,0FFFFFFD8h
    1d7: call    ryo_h_Lpad
    1dc: jmp     110h
    1e1: mov     rdi,rax
    1e4: mov     esi,0FFFFFFD8h
    1e9: call    ryo_h_Lpad
    1ee: jmp     190h

fn std::hint::select_unpredictable::<*const u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-40h],rax
     13: mov     [rbp-38h],rax
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+20h]
     1f: mov     [rbp-48h],rax
     23: mov     [rbp-40h],rax
     27: mov     [rbp-38h],rax
     2b: lea     rax,[rbp-30h]
     2f: mov     [rbp-48h],rax
     33: mov     [rbp-40h],rax
     37: lea     rax,[rbp-38h]
     3b: mov     [rbp-50h],rax
     3f: mov     [rbp-48h],rax
     43: movzx   eax,byte ptr [rbp+18h]
     47: mov     [rbp-88h],al
     4d: mov     rax,[rbp-40h]
     51: mov     [rbp-90h],rax
     58: mov     rax,[rbp-48h]
     5c: mov     [rbp-80h],rax
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym0]
     70: movzx   eax,byte ptr [rbp+18h]
     74: mov     [rbp-88h],al
     7a: mov     rax,[rbp-48h]
     7e: mov     [rbp-90h],rax
     85: mov     rax,[rbp-40h]
     89: mov     [rbp-80h],rax
     8d: mov     rdi,rbp
     90: lea     rsi,[ro+16]
     97: call    qword ptr [sym1]
     9d: mov     rax,[rbp-50h]
     a1: mov     [rbp-58h],rax
     a5: mov     rax,[rbp-20h]
     a9: mov     [rbp-60h],rax
     ad: mov     [rbp-90h],rax
     b4: mov     edi,0FFFFFF88h
     b9: lea     rsi,[sym2]
     c0: call    ryo_h_AddrSym
     c5: mov     rdi,rbp
     c8: lea     rsi,[ro+28]
     cf: call    qword ptr [sym3]
     d5: jmp     12Dh
     d7: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     177h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     edi,0FFFFFFD8h
    105: call    ryo_h_Resume
    10a: ud2
    10c: nop     [rax]
    110: lea     rax,[rbp-58h]
    114: mov     [rbp-78h],rax
    118: mov     [rbp-90h],rax
    11f: call    fn5
    124: nop     [rcx-78h]
    12b: jmp     100h
    12d: mov     rax,[rbp-58h]
    131: mov     [rbp-60h],rax
    135: mov     rax,[rbp-30h]
    139: mov     [rbp-68h],rax
    13d: mov     rax,[rbp-38h]
    141: mov     [rbp-70h],rax
    145: movzx   eax,byte ptr [rbp+18h]
    149: mov     [rbp-88h],al
    14f: mov     rax,[rbp-68h]
    153: mov     [rbp-90h],rax
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-80h],rax
    162: mov     rdi,rbp
    165: lea     rsi,[ro+44]
    16c: call    qword ptr [sym6]
    172: jmp     0E0h
    177: mov     rax,[rbp-60h]
    17b: mov     [rbp-8],rax
    17f: mov     edi,0FFFFFFF8h
    184: mov     esi,8
    189: call    ryo_h_Ret
    18e: leave
    18f: ret
    190: lea     rdi,[sym7]
    197: lea     rsi,[site8]
    19e: mov     edx,0FFFFFF88h
    1a3: call    ryo_h_CallExt
    1a8: test    rax,rax
    1ab: je      1B8h
    1ad: call    rax
    1af: nop     [rcx-70h]
    1b6: jmp     1C8h
    1b8: mov     rdi,rbp
    1bb: lea     rsi,[ro+56]
    1c2: call    qword ptr [sym9]
    1c8: call    ryo_h_Unreachable
    1cd: ud2
    1cf: mov     rdi,rax
    1d2: mov     esi,0FFFFFFD8h
    1d7: call    ryo_h_Lpad
    1dc: jmp     110h
    1e1: mov     rdi,rax
    1e4: mov     esi,0FFFFFFD8h
    1e9: call    ryo_h_Lpad
    1ee: jmp     190h

fn std::hint::select_unpredictable::<*mut u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-40h],rax
     13: mov     [rbp-38h],rax
     17: mov     [rbp-30h],rax
     1b: mov     rax,[rbp+20h]
     1f: mov     [rbp-48h],rax
     23: mov     [rbp-40h],rax
     27: mov     [rbp-38h],rax
     2b: lea     rax,[rbp-30h]
     2f: mov     [rbp-48h],rax
     33: mov     [rbp-40h],rax
     37: lea     rax,[rbp-38h]
     3b: mov     [rbp-50h],rax
     3f: mov     [rbp-48h],rax
     43: movzx   eax,byte ptr [rbp+18h]
     47: mov     [rbp-88h],al
     4d: mov     rax,[rbp-40h]
     51: mov     [rbp-90h],rax
     58: mov     rax,[rbp-48h]
     5c: mov     [rbp-80h],rax
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym0]
     70: movzx   eax,byte ptr [rbp+18h]
     74: mov     [rbp-88h],al
     7a: mov     rax,[rbp-48h]
     7e: mov     [rbp-90h],rax
     85: mov     rax,[rbp-40h]
     89: mov     [rbp-80h],rax
     8d: mov     rdi,rbp
     90: lea     rsi,[ro+16]
     97: call    qword ptr [sym1]
     9d: mov     rax,[rbp-50h]
     a1: mov     [rbp-58h],rax
     a5: mov     rax,[rbp-20h]
     a9: mov     [rbp-60h],rax
     ad: mov     [rbp-90h],rax
     b4: mov     edi,0FFFFFF88h
     b9: lea     rsi,[sym2]
     c0: call    ryo_h_AddrSym
     c5: mov     rdi,rbp
     c8: lea     rsi,[ro+28]
     cf: call    qword ptr [sym3]
     d5: jmp     12Dh
     d7: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     177h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     edi,0FFFFFFD8h
    105: call    ryo_h_Resume
    10a: ud2
    10c: nop     [rax]
    110: lea     rax,[rbp-58h]
    114: mov     [rbp-78h],rax
    118: mov     [rbp-90h],rax
    11f: call    fn5
    124: nop     [rcx-78h]
    12b: jmp     100h
    12d: mov     rax,[rbp-58h]
    131: mov     [rbp-60h],rax
    135: mov     rax,[rbp-30h]
    139: mov     [rbp-68h],rax
    13d: mov     rax,[rbp-38h]
    141: mov     [rbp-70h],rax
    145: movzx   eax,byte ptr [rbp+18h]
    149: mov     [rbp-88h],al
    14f: mov     rax,[rbp-68h]
    153: mov     [rbp-90h],rax
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-80h],rax
    162: mov     rdi,rbp
    165: lea     rsi,[ro+44]
    16c: call    qword ptr [sym6]
    172: jmp     0E0h
    177: mov     rax,[rbp-60h]
    17b: mov     [rbp-8],rax
    17f: mov     edi,0FFFFFFF8h
    184: mov     esi,8
    189: call    ryo_h_Ret
    18e: leave
    18f: ret
    190: lea     rdi,[sym7]
    197: lea     rsi,[site8]
    19e: mov     edx,0FFFFFF88h
    1a3: call    ryo_h_CallExt
    1a8: test    rax,rax
    1ab: je      1B8h
    1ad: call    rax
    1af: nop     [rcx-70h]
    1b6: jmp     1C8h
    1b8: mov     rdi,rbp
    1bb: lea     rsi,[ro+56]
    1c2: call    qword ptr [sym9]
    1c8: call    ryo_h_Unreachable
    1cd: ud2
    1cf: mov     rdi,rax
    1d2: mov     esi,0FFFFFFD8h
    1d7: call    ryo_h_Lpad
    1dc: jmp     110h
    1e1: mov     rdi,rax
    1e4: mov     esi,0FFFFFFD8h
    1e9: call    ryo_h_Lpad
    1ee: jmp     190h

fn std::intrinsics::cold_path
      0: push    rbp
      1: mov     rbp,rsp
      4: xor     edi,edi
      6: xor     esi,esi
      8: call    ryo_h_Ret
      d: leave
      e: ret

fn std::intrinsics::select_unpredictable::<*mut *const (u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::select_unpredictable::<*mut *const u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::select_unpredictable::<*mut *mut u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const (u32, u32)>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*mut u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: test    byte ptr [rbp+18h],0FFh
      c: je      18h
      e: mov     rax,[rbp+10h]
     12: mov     [rbp-8],rax
     16: jmp     20h
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-8],rax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::intrinsics::typed_swap_nonoverlapping::<(u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-30h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-28h],rax
     18: mov     qword ptr [rbp-20h],1
     20: mov     edi,0FFFFFFE8h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: call    fn1
     36: nop     [rcx]
     3d: xor     edi,edi
     3f: xor     esi,esi
     41: call    ryo_h_Ret
     46: leave
     47: ret
     48: nop     [rax+rax]
     50: lea     rdi,[sym2]
     57: lea     rsi,[site3]
     5e: mov     edx,0FFFFFFF0h
     63: call    ryo_h_CallExt
     68: test    rax,rax
     6b: je      78h
     6d: call    rax
     6f: nop     [rcx-8]
     76: jmp     88h
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym4]
     88: call    ryo_h_Unreachable
     8d: ud2
     8f: mov     rdi,rax
     92: mov     esi,0FFFFFFF8h
     97: call    ryo_h_Lpad
     9c: jmp     50h

fn std::intrinsics::typed_swap_nonoverlapping::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-30h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-28h],rax
     18: mov     qword ptr [rbp-20h],1
     20: mov     edi,0FFFFFFE8h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: call    fn1
     36: nop     [rcx]
     3d: xor     edi,edi
     3f: xor     esi,esi
     41: call    ryo_h_Ret
     46: leave
     47: ret
     48: nop     [rax+rax]
     50: lea     rdi,[sym2]
     57: lea     rsi,[site3]
     5e: mov     edx,0FFFFFFF0h
     63: call    ryo_h_CallExt
     68: test    rax,rax
     6b: je      78h
     6d: call    rax
     6f: nop     [rcx-8]
     76: jmp     88h
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym4]
     88: call    ryo_h_Unreachable
     8d: ud2
     8f: mov     rdi,rax
     92: mov     esi,0FFFFFFF8h
     97: call    ryo_h_Lpad
     9c: jmp     50h

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp-8]
     1c: mov     [rbp-20h],rax
     20: mov     rax,[rbp-10h]
     24: mov     [rbp-18h],rax
     28: call    fn0
     2d: nop     [rcx]
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     eax,[rbp+18h]
     13: mov     [rbp-0Ch],eax
     16: mov     rax,[rbp-8]
     1a: mov     [rbp-20h],rax
     1e: mov     eax,[rbp-0Ch]
     21: mov     [rbp-18h],eax
     24: call    fn0
     29: nop     [rcx]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     byte ptr [rbp-1],1
     14: mov     rax,[rbp+10h]
     18: lea     rax,[rax+18h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp+18h]
     24: mov     [rbp-38h],rax
     28: mov     rax,[rbp-30h]
     2c: mov     [rbp-50h],rax
     30: mov     rax,[rbp-38h]
     34: mov     [rbp-48h],rax
     38: call    fn0
     3d: nop     [rcx-28h]
     44: mov     byte ptr [rbp-1],0
     48: mov     rax,[rbp-28h]
     4c: mov     [rbp-20h],rax
     50: mov     rax,[rbp-18h]
     54: mov     [rbp-50h],rax
     58: mov     rax,[rbp-20h]
     5c: mov     [rbp-48h],rax
     60: call    fn1
     65: nop     [rcx]
     6c: xor     edi,edi
     6e: xor     esi,esi
     70: call    ryo_h_Ret
     75: leave
     76: ret
     77: nop     [rax+rax]
     80: mov     edi,0FFFFFFF0h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-1],0FFh
     a4: je      80h
     a6: jmp     90h
     a8: mov     rdi,rax
     ab: mov     esi,0FFFFFFF0h
     b0: call    ryo_h_Lpad
     b5: jmp     0A0h

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     byte ptr [rbp-1],1
     14: mov     rax,[rbp+10h]
     18: lea     rax,[rax+18h]
     1c: mov     [rbp-28h],rax
     20: mov     rax,[rbp+18h]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-40h],rax
     30: mov     rax,[rbp-30h]
     34: mov     [rbp-38h],rax
     38: call    fn0
     3d: nop     [rcx-20h]
     44: mov     byte ptr [rbp-1],0
     48: mov     eax,[rbp-20h]
     4b: mov     [rbp-1Ch],eax
     4e: mov     rax,[rbp-18h]
     52: mov     [rbp-40h],rax
     56: mov     eax,[rbp-1Ch]
     59: mov     [rbp-38h],eax
     5c: call    fn1
     61: nop     [rcx]
     68: xor     edi,edi
     6a: xor     esi,esi
     6c: call    ryo_h_Ret
     71: leave
     72: ret
     73: nop     [rax+rax]
     7c: nop     [rax]
     80: mov     edi,0FFFFFFF0h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-1],0FFh
     a4: je      80h
     a6: jmp     90h
     a8: mov     rdi,rax
     ab: mov     esi,0FFFFFFF0h
     b0: call    ryo_h_Lpad
     b5: jmp     0A0h

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: call    fn0
     15: nop     [rcx-10h]
     1c: mov     edi,0FFFFFFF0h
     21: mov     esi,10h
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+8]
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-28h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-38h],rax
     2c: call    fn0
     31: nop     [rcx-19h]
     38: test    byte ptr [rbp-19h],0FFh
     3c: je      70h
     3e: mov     rax,[rbp+10h]
     42: mov     [rbp-28h],rax
     46: mov     rax,[rbp+10h]
     4a: lea     rax,[rax+8]
     4e: mov     [rbp-30h],rax
     52: mov     rax,[rbp-28h]
     56: mov     [rbp-40h],rax
     5a: mov     rax,[rbp-30h]
     5e: mov     [rbp-38h],rax
     62: call    fn1
     67: nop     [rcx-18h]
     6e: jmp     8Eh
     70: mov     qword ptr [rbp-18h],0
     78: mov     edi,0FFFFFFF0h
     7d: lea     rsi,[k2]
     84: mov     edx,10h
     89: call    ryo_h_Const
     8e: mov     edi,0FFFFFFE8h
     93: mov     esi,18h
     98: call    ryo_h_Ret
     9d: leave
     9e: ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFF9Ch
     10: mov     esi,18h
     15: call    ryo_h_CtpopW64
     1a: mov     eax,[rbp-64h]
     1d: mov     [rbp-8],eax
     20: jmp     149h
     25: nop     [rax+rax]
     2e: xchg    ax,ax
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-20h],rax
     38: mov     [rbp-18h],rax
     3c: mov     rax,[rbp+18h]
     40: sub     rax,1
     44: mov     [rbp-20h],rax
     48: mov     rax,[rbp-18h]
     4c: and     rax,[rbp-20h]
     50: mov     [rbp-10h],rax
     54: cmp     rax,0
     58: sete    [rbp-1]
     5c: mov     edi,0FFFFFFFFh
     61: mov     esi,1
     66: call    ryo_h_Ret
     6b: leave
     6c: ret
     6d: nop     [rax]
     70: mov     edi,0FFFFFFD8h
     75: lea     rsi,[k0]
     7c: call    ryo_h_AddrAbs
     81: mov     qword ptr [rbp-20h],2Ah
     89: mov     rax,[rbp-28h]
     8d: mov     [rbp-48h],rax
     91: mov     rax,[rbp-20h]
     95: mov     [rbp-40h],rax
     99: mov     rax,[rbp-48h]
     9d: mov     [rbp-38h],rax
     a1: mov     [rbp-30h],rax
     a5: mov     edi,0FFFFFFA0h
     aa: lea     rsi,[k1]
     b1: call    ryo_h_AddrAbs
     b6: mov     qword ptr [rbp-58h],2Ah
     be: mov     rax,[rbp-58h]
     c2: mov     [rbp-50h],rax
     c6: shl     rax,1
     ca: mov     [rbp-48h],rax
     ce: or      rax,1
     d2: mov     [rbp-40h],rax
     d6: mov     [rbp-38h],rax
     da: mov     rax,[rbp-30h]
     de: mov     [rbp-18h],rax
     e2: mov     rax,[rbp-38h]
     e6: mov     [rbp-10h],rax
     ea: mov     edi,0FFFFFF80h
     ef: mov     esi,0FFFFFFE8h
     f4: call    ryo_h_MovW128
     f9: mov     edi,0FFFFFF90h
     fe: lea     rsi,[k2]
    105: call    ryo_h_AddrAbs
    10a: lea     rdi,[sym3]
    111: lea     rsi,[site4]
    118: mov     edx,0FFFFFF98h
    11d: call    ryo_h_CallExt
    122: test    rax,rax
    125: je      132h
    127: call    rax
    129: nop     [rcx-1]
    130: jmp     142h
    132: mov     rdi,rbp
    135: lea     rsi,[ro+4]
    13c: call    qword ptr [sym5]
    142: call    ryo_h_Unreachable
    147: ud2
    149: cmp     dword ptr [rbp-8],1
    14d: sete    [rbp-2]
    151: test    byte ptr [rbp-2],0FFh
    155: je      70h
    15b: jmp     30h

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: cmp     rax,[rbp+18h]
     13: jb      20h
     15: xor     edi,edi
     17: xor     esi,esi
     19: call    ryo_h_Ret
     1e: leave
     1f: ret
     20: mov     edi,0FFFFFFF0h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: mov     qword ptr [rbp-8],0C9h
     39: mov     rax,[rbp-10h]
     3d: mov     [rbp-48h],rax
     41: mov     rax,[rbp-8]
     45: mov     [rbp-40h],rax
     49: mov     rax,[rbp-48h]
     4d: mov     [rbp-38h],rax
     51: mov     [rbp-30h],rax
     55: mov     edi,0FFFFFFA0h
     5a: lea     rsi,[k1]
     61: call    ryo_h_AddrAbs
     66: mov     qword ptr [rbp-58h],0C9h
     6e: mov     rax,[rbp-58h]
     72: mov     [rbp-50h],rax
     76: shl     rax,1
     7a: mov     [rbp-48h],rax
     7e: or      rax,1
     82: mov     [rbp-40h],rax
     86: mov     [rbp-38h],rax
     8a: mov     rax,[rbp-30h]
     8e: mov     [rbp-28h],rax
     92: mov     rax,[rbp-38h]
     96: mov     [rbp-20h],rax
     9a: mov     edi,0FFFFFF70h
     9f: mov     esi,0FFFFFFD8h
     a4: call    ryo_h_MovW128
     a9: mov     byte ptr [rbp-80h],0
     ad: mov     rax,[rbp+20h]
     b1: mov     [rbp-78h],rax
     b5: lea     rdi,[sym2]
     bc: lea     rsi,[site3]
     c3: mov     edx,0FFFFFF98h
     c8: call    ryo_h_CallExt
     cd: test    rax,rax
     d0: je      0DDh
     d2: call    rax
     d4: nop     [rcx-10h]
     db: jmp     0EDh
     dd: mov     rdi,rbp
     e0: lea     rsi,[ro+4]
     e7: call    qword ptr [sym4]
     ed: call    ryo_h_Unreachable
     f2: ud2

fn std::ptr::copy::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-90h],rax
     16: mov     rax,[rbp+20h]
     1a: mov     [rbp-88h],rax
     21: call    fn0
     26: nop     [rcx-1Ah]
     2d: jmp     1B2h
     32: nop     [rax+rax]
     3b: nop     [rax+rax]
     40: xor     edi,edi
     42: xor     esi,esi
     44: call    ryo_h_Ret
     49: leave
     4a: ret
     4b: nop     [rax+rax]
     50: jmp     60h
     52: nop     [rax+rax]
     5b: nop     [rax+rax]
     60: mov     edi,0FFFFFFF0h
     65: lea     rsi,[k1]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-8],0DDh
     79: mov     rax,[rbp-10h]
     7d: mov     [rbp-50h],rax
     81: mov     rax,[rbp-8]
     85: mov     [rbp-48h],rax
     89: mov     rax,[rbp-50h]
     8d: mov     [rbp-40h],rax
     91: mov     [rbp-38h],rax
     95: mov     edi,0FFFFFF98h
     9a: lea     rsi,[k2]
     a1: call    ryo_h_AddrAbs
     a6: mov     qword ptr [rbp-60h],0DDh
     ae: mov     rax,[rbp-60h]
     b2: mov     [rbp-58h],rax
     b6: shl     rax,1
     ba: mov     [rbp-50h],rax
     be: or      rax,1
     c2: mov     [rbp-48h],rax
     c6: mov     [rbp-40h],rax
     ca: mov     rax,[rbp-38h]
     ce: mov     [rbp-30h],rax
     d2: mov     rax,[rbp-40h]
     d6: mov     [rbp-28h],rax
     da: mov     edi,0FFFFFF70h
     df: mov     esi,0FFFFFFD0h
     e4: call    ryo_h_MovW128
     e9: mov     byte ptr [rbp-80h],0
     ed: mov     rax,[rbp+30h]
     f1: mov     [rbp-78h],rax
     f5: lea     rdi,[sym3]
     fc: lea     rsi,[site4]
    103: mov     edx,0FFFFFF90h
    108: call    ryo_h_CallExt
    10d: test    rax,rax
    110: je      11Dh
    112: call    rax
    114: nop     [rcx-10h]
    11b: jmp     12Dh
    11d: mov     rdi,rbp
    120: lea     rsi,[ro+4]
    127: call    qword ptr [sym5]
    12d: call    ryo_h_Unreachable
    132: ud2
    134: nop     [rax+rax]
    13d: nop     [rax]
    140: test    byte ptr [rbp+28h],0FFh
    144: je      18Ch
    146: jmp     155h
    148: nop     [rax+rax]
    150: jmp     60h
    155: mov     rax,[rbp+18h]
    159: mov     [rbp-28h],rax
    15d: mov     rax,[rbp+20h]
    161: mov     [rbp-30h],rax
    165: mov     rax,[rbp-28h]
    169: mov     [rbp-90h],rax
    170: mov     rax,[rbp+20h]
    174: mov     [rbp-88h],rax
    17b: call    fn6
    180: nop     [rcx-1Bh]
    187: jmp     209h
    18c: mov     rax,[rbp+10h]
    190: mov     [rbp-28h],rax
    194: cmp     rax,0
    198: sete    [rbp-1Bh]
    19c: movzx   eax,byte ptr [rbp-1Bh]
    1a0: xor     al,1
    1a3: mov     [rbp-19h],al
    1a6: test    byte ptr [rbp-19h],0FFh
    1aa: je      60h
    1b0: jmp     211h
    1b2: test    byte ptr [rbp-1Ah],0FFh
    1b6: je      150h
    1b8: jmp     140h
    1ba: nop     [rax+rax]
    1c0: jmp     50h
    1c5: nop     [rax+rax]
    1ce: xchg    ax,ax
    1d0: jmp     40h
    1d5: nop     [rax+rax]
    1de: xchg    ax,ax
    1e0: mov     rax,[rbp+18h]
    1e4: mov     [rbp-38h],rax
    1e8: cmp     rax,0
    1ec: sete    [rbp-1Ch]
    1f0: movzx   eax,byte ptr [rbp-1Ch]
    1f4: xor     al,1
    1f7: mov     [rbp-1Ah],al
    1fa: test    byte ptr [rbp-1Ah],0FFh
    1fe: je      50h
    204: jmp     40h
    209: test    byte ptr [rbp-1Bh],0FFh
    20d: je      1C0h
    20f: jmp     1D0h
    211: mov     rax,[rbp+18h]
    215: mov     [rbp-28h],rax
    219: mov     rax,[rbp+20h]
    21d: mov     [rbp-30h],rax
    221: mov     rax,[rbp-28h]
    225: mov     [rbp-90h],rax
    22c: mov     rax,[rbp+20h]
    230: mov     [rbp-88h],rax
    237: call    fn7
    23c: nop     [rcx-1Bh]
    243: test    byte ptr [rbp-1Bh],0FFh
    247: je      1C0h
    24d: jmp     1E0h
    24f: nop
    250: lea     rdi,[sym8]
    257: lea     rsi,[site9]
    25e: mov     edx,0FFFFFF90h
    263: call    ryo_h_CallExt
    268: test    rax,rax
    26b: je      278h
    26d: call    rax
    26f: nop     [rcx-68h]
    276: jmp     288h
    278: mov     rdi,rbp
    27b: lea     rsi,[ro+20]
    282: call    qword ptr [sym10]
    288: call    ryo_h_Unreachable
    28d: ud2
    28f: mov     rdi,rax
    292: mov     esi,0FFFFFFE8h
    297: call    ryo_h_Lpad
    29c: jmp     250h

fn std::ptr::copy_nonoverlapping::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: cmp     qword ptr [rbp+30h],0
     10: jne     18h
     12: mov     byte ptr [rbp-1],1
     16: jmp     21h
     18: cmp     qword ptr [rbp+20h],0
     1d: sete    [rbp-1]
     21: movzx   eax,byte ptr [rbp-1]
     25: mov     [rbp-2Bh],al
     28: mov     rax,[rbp+10h]
     2c: mov     [rbp-0A0h],rax
     33: mov     rax,[rbp+28h]
     37: mov     [rbp-98h],rax
     3e: call    fn0
     43: nop     [rcx-2Ch]
     4a: jmp     203h
     4f: nop
     50: mov     rax,[rbp+18h]
     54: mov     [rbp-10h],rax
     58: mov     [rbp-0A0h],rax
     5f: mov     rax,[rbp+28h]
     63: mov     [rbp-98h],rax
     6a: call    fn1
     6f: nop     [rcx-2Ch]
     76: jmp     253h
     7b: nop     [rax+rax]
     80: mov     rax,[rbp+10h]
     84: mov     [rbp-0A0h],rax
     8b: mov     rax,[rbp-10h]
     8f: mov     [rbp-98h],rax
     96: mov     rax,[rbp+20h]
     9a: mov     [rbp-90h],rax
     a1: mov     rax,[rbp+30h]
     a5: mov     [rbp-88h],rax
     ac: call    fn2
     b1: nop     [rcx-29h]
     b8: jmp     25Bh
     bd: nop     [rax]
     c0: jmp     0D0h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: mov     edi,0FFFFFFE0h
     d5: lea     rsi,[k3]
     dc: call    ryo_h_AddrAbs
     e1: mov     qword ptr [rbp-18h],11Bh
     e9: mov     rax,[rbp-20h]
     ed: mov     [rbp-60h],rax
     f1: mov     rax,[rbp-18h]
     f5: mov     [rbp-58h],rax
     f9: mov     rax,[rbp-60h]
     fd: mov     [rbp-50h],rax
    101: mov     [rbp-48h],rax
    105: mov     edi,0FFFFFF88h
    10a: lea     rsi,[k4]
    111: call    ryo_h_AddrAbs
    116: mov     qword ptr [rbp-70h],11Bh
    11e: mov     rax,[rbp-70h]
    122: mov     [rbp-68h],rax
    126: shl     rax,1
    12a: mov     [rbp-60h],rax
    12e: or      rax,1
    132: mov     [rbp-58h],rax
    136: mov     [rbp-50h],rax
    13a: mov     rax,[rbp-48h]
    13e: mov     [rbp-40h],rax
    142: mov     rax,[rbp-50h]
    146: mov     [rbp-38h],rax
    14a: mov     edi,0FFFFFF60h
    14f: mov     esi,0FFFFFFC0h
    154: call    ryo_h_MovW128
    159: mov     byte ptr [rbp-90h],0
    160: mov     rax,[rbp+38h]
    164: mov     [rbp-88h],rax
    16b: lea     rdi,[sym5]
    172: lea     rsi,[site6]
    179: mov     edx,0FFFFFF80h
    17e: call    ryo_h_CallExt
    183: test    rax,rax
    186: je      193h
    188: call    rax
    18a: nop     [rcx-20h]
    191: jmp     1A3h
    193: mov     rdi,rbp
    196: lea     rsi,[ro+4]
    19d: call    qword ptr [sym7]
    1a3: call    ryo_h_Unreachable
    1a8: ud2
    1aa: nop     [rax+rax]
    1b0: xor     edi,edi
    1b2: xor     esi,esi
    1b4: call    ryo_h_Ret
    1b9: leave
    1ba: ret
    1bb: nop     [rax+rax]
    1c0: test    byte ptr [rbp-2Bh],0FFh
    1c4: je      1DAh
    1c6: jmp     1D5h
    1c8: nop     [rax+rax]
    1d0: jmp     0D0h
    1d5: jmp     50h
    1da: mov     rax,[rbp+10h]
    1de: mov     [rbp-38h],rax
    1e2: cmp     rax,0
    1e6: sete    [rbp-2Dh]
    1ea: movzx   eax,byte ptr [rbp-2Dh]
    1ee: xor     al,1
    1f1: mov     [rbp-2Ah],al
    1f4: test    byte ptr [rbp-2Ah],0FFh
    1f8: je      0D0h
    1fe: jmp     50h
    203: test    byte ptr [rbp-2Ch],0FFh
    207: je      1D0h
    209: jmp     1C0h
    20b: nop     [rax+rax]
    210: test    byte ptr [rbp-1],0FFh
    214: je      22Ah
    216: jmp     225h
    218: nop     [rax+rax]
    220: jmp     0C0h
    225: jmp     80h
    22a: mov     rax,[rbp+18h]
    22e: mov     [rbp-38h],rax
    232: cmp     rax,0
    236: sete    [rbp-2Dh]
    23a: movzx   eax,byte ptr [rbp-2Dh]
    23e: xor     al,1
    241: mov     [rbp-2Bh],al
    244: test    byte ptr [rbp-2Bh],0FFh
    248: je      0C0h
    24e: jmp     80h
    253: test    byte ptr [rbp-2Ch],0FFh
    257: je      220h
    259: jmp     210h
    25b: test    byte ptr [rbp-29h],0FFh
    25f: je      0D0h
    265: jmp     1B0h
    26a: nop     [rax+rax]
    270: lea     rdi,[sym8]
    277: lea     rsi,[site9]
    27e: mov     edx,0FFFFFF80h
    283: call    ryo_h_CallExt
    288: test    rax,rax
    28b: je      298h
    28d: call    rax
    28f: nop     [rcx-78h]
    296: jmp     2A8h
    298: mov     rdi,rbp
    29b: lea     rsi,[ro+20]
    2a2: call    qword ptr [sym10]
    2a8: call    ryo_h_Unreachable
    2ad: ud2
    2af: mov     rdi,rax
    2b2: mov     esi,0FFFFFFD8h
    2b7: call    ryo_h_Lpad
    2bc: jmp     270h

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<(u32, u32)>> - shim(Some(alloc::raw_vec::RawVec<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u32>> - shim(Some(alloc::raw_vec::RawVec<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<core::slice::sort::stable::merge::MergeState<(u32, u32)>> - shim(Some(core::slice::sort::stable::merge::MergeState<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<core::slice::sort::unstable::quicksort::GapGuardRaw<u32>> - shim(Some(core::slice::sort::unstable::quicksort::GapGuardRaw<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<std::array::IntoIter<usize, 2>> - shim(Some(std::array::IntoIter<usize, 2>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*mut u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*mut u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<std::vec::Vec<(u32, u32)>> - shim(Some(std::vec::Vec<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-20h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: jmp     6Ah
     22: nop     [rax+rax]
     2b: nop     [rax+rax]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: nop     [rax+rax]
     40: mov     edi,0FFFFFFF0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: mov     rax,[rbp+10h]
     54: mov     [rbp-18h],rax
     58: mov     [rbp-20h],rax
     5c: call    fn1
     61: nop     [rcx-18h]
     68: jmp     40h
     6a: mov     rax,[rbp+10h]
     6e: mov     [rbp-18h],rax
     72: mov     [rbp-20h],rax
     76: call    fn2
     7b: nop     [rcx-18h]
     82: jmp     30h
     84: nop     [rax+rax]
     8d: nop     [rax]
     90: lea     rdi,[sym3]
     97: lea     rsi,[site4]
     9e: mov     edx,0FFFFFFE8h
     a3: call    ryo_h_CallExt
     a8: test    rax,rax
     ab: je      0B8h
     ad: call    rax
     af: nop     [rcx-10h]
     b6: jmp     0C8h
     b8: mov     rdi,rbp
     bb: lea     rsi,[ro+4]
     c2: call    qword ptr [sym5]
     c8: call    ryo_h_Unreachable
     cd: ud2
     cf: mov     rdi,rax
     d2: mov     esi,0FFFFFFF0h
     d7: call    ryo_h_Lpad
     dc: jmp     50h
     e1: mov     rdi,rax
     e4: mov     esi,0FFFFFFF0h
     e9: call    ryo_h_Lpad
     ee: jmp     90h

fn std::ptr::drop_glue::<std::vec::Vec<u32>> - shim(Some(std::vec::Vec<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-20h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: jmp     6Ah
     22: nop     [rax+rax]
     2b: nop     [rax+rax]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: nop     [rax+rax]
     40: mov     edi,0FFFFFFF0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: mov     rax,[rbp+10h]
     54: mov     [rbp-18h],rax
     58: mov     [rbp-20h],rax
     5c: call    fn1
     61: nop     [rcx-18h]
     68: jmp     40h
     6a: mov     rax,[rbp+10h]
     6e: mov     [rbp-18h],rax
     72: mov     [rbp-20h],rax
     76: call    fn2
     7b: nop     [rcx-18h]
     82: jmp     30h
     84: nop     [rax+rax]
     8d: nop     [rax]
     90: lea     rdi,[sym3]
     97: lea     rsi,[site4]
     9e: mov     edx,0FFFFFFE8h
     a3: call    ryo_h_CallExt
     a8: test    rax,rax
     ab: je      0B8h
     ad: call    rax
     af: nop     [rcx-10h]
     b6: jmp     0C8h
     b8: mov     rdi,rbp
     bb: lea     rsi,[ro+4]
     c2: call    qword ptr [sym5]
     c8: call    ryo_h_Unreachable
     cd: ud2
     cf: mov     rdi,rax
     d2: mov     esi,0FFFFFFF0h
     d7: call    ryo_h_Lpad
     dc: jmp     50h
     e1: mov     rdi,rax
     e4: mov     esi,0FFFFFFF0h
     e9: call    ryo_h_Lpad
     ee: jmp     90h

fn std::ptr::drop_glue::<std::vec::set_len_on_drop::SetLenOnDrop<'_>> - shim(Some(std::vec::set_len_on_drop::SetLenOnDrop<'_>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::ptr::swap::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: lea     rax,[rbp-24h]
     17: mov     [rbp-18h],rax
     1b: mov     [rbp-38h],rax
     1f: mov     byte ptr [rbp-49h],1
     23: test    byte ptr [rbp-49h],0FFh
     27: je      84h
     29: mov     rax,[rbp+10h]
     2d: mov     [rbp-40h],rax
     31: mov     rax,[rbp-18h]
     35: mov     [rbp-48h],rax
     39: mov     rax,[rbp-40h]
     3d: mov     [rbp-90h],rax
     44: mov     rax,[rbp-48h]
     48: mov     [rbp-88h],rax
     4f: mov     qword ptr [rbp-80h],4
     57: mov     qword ptr [rbp-78h],4
     5f: mov     qword ptr [rbp-70h],1
     67: mov     edi,0FFFFFF98h
     6c: lea     rsi,[k0]
     73: call    ryo_h_AddrAbs
     78: call    fn1
     7d: nop     [rcx-18h]
     84: mov     qword ptr [rbp-50h],1
     8c: imul    rax,[rbp-50h],4
     91: mov     [rbp-58h],rax
     95: mov     edi,0FFFFFFC8h
     9a: mov     esi,0FFFFFFD0h
     9f: mov     edx,0FFFFFFA8h
     a4: call    ryo_h_Memcpy
     a9: mov     rax,[rbp+18h]
     ad: mov     [rbp-30h],rax
     b1: mov     byte ptr [rbp-49h],1
     b5: test    byte ptr [rbp-49h],0FFh
     b9: je      155h
     bf: jmp     0EFh
     c1: nop     [rax+rax]
     ca: nop     [rax+rax]
     d0: lea     rax,[rbp-24h]
     d4: mov     [rbp-20h],rax
     d8: mov     [rbp-30h],rax
     dc: mov     byte ptr [rbp-49h],1
     e0: test    byte ptr [rbp-49h],0FFh
     e4: je      1DAh
     ea: jmp     17Fh
     ef: mov     rax,[rbp+18h]
     f3: mov     [rbp-38h],rax
     f7: mov     rax,[rbp+10h]
     fb: mov     [rbp-40h],rax
     ff: mov     byte ptr [rbp-49h],0
    103: test    byte ptr [rbp-49h],0FFh
    107: je      10Fh
    109: mov     byte ptr [rbp-25h],1
    10d: jmp     113h
    10f: mov     byte ptr [rbp-25h],0
    113: mov     rax,[rbp-38h]
    117: mov     [rbp-90h],rax
    11e: mov     rax,[rbp-40h]
    122: mov     [rbp-88h],rax
    129: mov     qword ptr [rbp-80h],4
    131: movzx   eax,byte ptr [rbp-25h]
    135: mov     [rbp-78h],al
    138: mov     edi,0FFFFFF90h
    13d: lea     rsi,[k2]
    144: call    ryo_h_AddrAbs
    149: call    fn3
    14e: nop     [rcx-18h]
    155: mov     qword ptr [rbp-50h],1
    15d: imul    rax,[rbp-50h],4
    162: mov     [rbp-58h],rax
    166: mov     edi,10h
    16b: mov     esi,0FFFFFFD0h
    170: mov     edx,0FFFFFFA8h
    175: call    ryo_h_Memmove
    17a: jmp     0D0h
    17f: mov     rax,[rbp-20h]
    183: mov     [rbp-38h],rax
    187: mov     rax,[rbp+18h]
    18b: mov     [rbp-40h],rax
    18f: mov     rax,[rbp-38h]
    193: mov     [rbp-90h],rax
    19a: mov     rax,[rbp-40h]
    19e: mov     [rbp-88h],rax
    1a5: mov     qword ptr [rbp-80h],4
    1ad: mov     qword ptr [rbp-78h],4
    1b5: mov     qword ptr [rbp-70h],1
    1bd: mov     edi,0FFFFFF98h
    1c2: lea     rsi,[k4]
    1c9: call    ryo_h_AddrAbs
    1ce: call    fn5
    1d3: nop     [rcx-20h]
    1da: mov     qword ptr [rbp-50h],1
    1e2: imul    rax,[rbp-50h],4
    1e7: mov     [rbp-58h],rax
    1eb: mov     edi,18h
    1f0: mov     esi,0FFFFFFD0h
    1f5: mov     edx,0FFFFFFA8h
    1fa: call    ryo_h_Memcpy
    1ff: xor     edi,edi
    201: xor     esi,esi
    203: call    ryo_h_Ret
    208: leave
    209: ret

fn std::ptr::swap_chunk::<1>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-1],al
     12: mov     rax,[rbp+18h]
     16: movzx   eax,byte ptr [rax]
     19: mov     [rbp-2],al
     1c: mov     rax,[rbp+10h]
     20: movzx   ecx,byte ptr [rbp-2]
     24: mov     [rax],cl
     26: mov     rax,[rbp+18h]
     2a: movzx   ecx,byte ptr [rbp-1]
     2e: mov     [rax],cl
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret

fn std::ptr::swap_chunk::<2>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,word ptr [rax]
      f: mov     [rbp-2],ax
     13: mov     rax,[rbp+18h]
     17: movzx   eax,word ptr [rax]
     1a: mov     [rbp-4],ax
     1e: mov     rax,[rbp+10h]
     22: movzx   ecx,word ptr [rbp-4]
     26: mov     [rax],cx
     29: mov     rax,[rbp+18h]
     2d: movzx   ecx,word ptr [rbp-2]
     31: mov     [rax],cx
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret

fn std::ptr::swap_chunk::<4>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     eax,[rax]
      e: mov     [rbp-4],eax
     11: mov     rax,[rbp+18h]
     15: mov     eax,[rax]
     17: mov     [rbp-8],eax
     1a: mov     rax,[rbp+10h]
     1e: mov     ecx,[rbp-8]
     21: mov     [rax],ecx
     23: mov     rax,[rbp+18h]
     27: mov     ecx,[rbp-4]
     2a: mov     [rax],ecx
     2c: xor     edi,edi
     2e: xor     esi,esi
     30: call    ryo_h_Ret
     35: leave
     36: ret

fn std::ptr::swap_chunk::<8>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+18h]
     17: mov     rax,[rax]
     1a: mov     [rbp-10h],rax
     1e: mov     rax,[rbp+10h]
     22: mov     rcx,[rbp-10h]
     26: mov     [rax],rcx
     29: mov     rax,[rbp+18h]
     2d: mov     rcx,[rbp-8]
     31: mov     [rax],rcx
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret

fn std::ptr::swap_nonoverlapping::<(u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-41h],1
      f: test    byte ptr [rbp-41h],0FFh
     13: je      61h
     15: mov     rax,[rbp+10h]
     19: mov     [rbp-8],rax
     1d: mov     rax,[rbp+18h]
     21: mov     [rbp-10h],rax
     25: mov     rax,[rbp-8]
     29: mov     [rbp-80h],rax
     2d: mov     rax,[rbp-10h]
     31: mov     [rbp-78h],rax
     35: mov     qword ptr [rbp-70h],8
     3d: mov     qword ptr [rbp-68h],4
     45: mov     rax,[rbp+20h]
     49: mov     [rbp-60h],rax
     4d: mov     rax,[rbp+28h]
     51: mov     [rbp-58h],rax
     55: call    fn0
     5a: nop     [rcx]
     61: mov     rax,[rbp+10h]
     65: mov     [rbp-10h],rax
     69: mov     rax,[rbp+20h]
     6d: mov     [rbp-8],rax
     71: mov     edi,0FFFFFFD8h
     76: mov     esi,0FFFFFFF0h
     7b: call    ryo_h_MovW128
     80: imul    rax,[rbp-20h],8
     85: mov     [rbp-18h],rax
     89: jmp     0D4h
     8b: mov     rax,[rbp-20h]
     8f: mov     [rbp-28h],rax
     93: mov     rax,[rbp+10h]
     97: mov     [rbp-38h],rax
     9b: mov     rax,[rbp+18h]
     9f: mov     [rbp-40h],rax
     a3: mov     rax,[rbp-38h]
     a7: mov     [rbp-80h],rax
     ab: mov     rax,[rbp-40h]
     af: mov     [rbp-78h],rax
     b3: mov     rax,[rbp-28h]
     b7: mov     [rbp-70h],rax
     bb: call    fn1
     c0: nop     [rcx]
     c7: jmp     0C9h
     c9: xor     edi,edi
     cb: xor     esi,esi
     cd: call    ryo_h_Ret
     d2: leave
     d3: ret
     d4: mov     rax,[rbp-18h]
     d8: mov     [rbp-20h],rax
     dc: mov     edi,0FFFFFFBCh
     e1: mov     esi,0FFFFFFE0h
     e6: xor     edx,edx
     e8: xor     ecx,ecx
     ea: xor     r8d,r8d
     ed: mov     r9d,1
     f3: call    ryo_h_DiscrNicheW64
     f8: mov     edi,0FFFFFFD0h
     fd: mov     esi,0FFFFFFBCh
    102: call    ryo_h_ZextW32W64
    107: mov     edi,0FFFFFFD0h
    10c: xor     esi,esi
    10e: mov     edx,2
    113: call    ryo_h_SwitchDenseW64
    118: lea     rcx,[128h]
    11f: movsxd  rax,[rcx+rax*4]
    123: add     rax,rcx
    126: jmp     rax
    128: .long   c9h
    12c: .long   8bh
    130: .long   134h
    134: call    ryo_h_Unreachable
    139: ud2

fn std::ptr::swap_nonoverlapping::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-41h],1
      f: test    byte ptr [rbp-41h],0FFh
     13: je      61h
     15: mov     rax,[rbp+10h]
     19: mov     [rbp-8],rax
     1d: mov     rax,[rbp+18h]
     21: mov     [rbp-10h],rax
     25: mov     rax,[rbp-8]
     29: mov     [rbp-80h],rax
     2d: mov     rax,[rbp-10h]
     31: mov     [rbp-78h],rax
     35: mov     qword ptr [rbp-70h],4
     3d: mov     qword ptr [rbp-68h],4
     45: mov     rax,[rbp+20h]
     49: mov     [rbp-60h],rax
     4d: mov     rax,[rbp+28h]
     51: mov     [rbp-58h],rax
     55: call    fn0
     5a: nop     [rcx]
     61: mov     rax,[rbp+10h]
     65: mov     [rbp-10h],rax
     69: mov     rax,[rbp+20h]
     6d: mov     [rbp-8],rax
     71: mov     edi,0FFFFFFD8h
     76: mov     esi,0FFFFFFF0h
     7b: call    ryo_h_MovW128
     80: imul    rax,[rbp-20h],4
     85: mov     [rbp-18h],rax
     89: jmp     0D4h
     8b: mov     rax,[rbp-20h]
     8f: mov     [rbp-28h],rax
     93: mov     rax,[rbp+10h]
     97: mov     [rbp-38h],rax
     9b: mov     rax,[rbp+18h]
     9f: mov     [rbp-40h],rax
     a3: mov     rax,[rbp-38h]
     a7: mov     [rbp-80h],rax
     ab: mov     rax,[rbp-40h]
     af: mov     [rbp-78h],rax
     b3: mov     rax,[rbp-28h]
     b7: mov     [rbp-70h],rax
     bb: call    fn1
     c0: nop     [rcx]
     c7: jmp     0C9h
     c9: xor     edi,edi
     cb: xor     esi,esi
     cd: call    ryo_h_Ret
     d2: leave
     d3: ret
     d4: mov     rax,[rbp-18h]
     d8: mov     [rbp-20h],rax
     dc: mov     edi,0FFFFFFBCh
     e1: mov     esi,0FFFFFFE0h
     e6: xor     edx,edx
     e8: xor     ecx,ecx
     ea: xor     r8d,r8d
     ed: mov     r9d,1
     f3: call    ryo_h_DiscrNicheW64
     f8: mov     edi,0FFFFFFD0h
     fd: mov     esi,0FFFFFFBCh
    102: call    ryo_h_ZextW32W64
    107: mov     edi,0FFFFFFD0h
    10c: xor     esi,esi
    10e: mov     edx,2
    113: call    ryo_h_SwitchDenseW64
    118: lea     rcx,[128h]
    11f: movsxd  rax,[rcx+rax*4]
    123: add     rax,rcx
    126: jmp     rax
    128: .long   c9h
    12c: .long   8bh
    130: .long   134h
    134: call    ryo_h_Unreachable
    139: ud2

fn std::ptr::swap_nonoverlapping::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: cmp     qword ptr [rbp+20h],0
     10: jne     18h
     12: mov     byte ptr [rbp-1],1
     16: jmp     21h
     18: cmp     qword ptr [rbp+30h],0
     1d: sete    [rbp-1]
     21: mov     rax,[rbp+10h]
     25: mov     [rbp-10h],rax
     29: movzx   eax,byte ptr [rbp-1]
     2d: mov     [rbp-33h],al
     30: mov     rax,[rbp-10h]
     34: mov     [rbp-0B0h],rax
     3b: mov     rax,[rbp+28h]
     3f: mov     [rbp-0A8h],rax
     46: call    fn0
     4b: nop     [rcx-34h]
     52: jmp     213h
     57: nop     [rax+rax]
     60: mov     rax,[rbp+18h]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-0B0h],rax
     6f: mov     rax,[rbp+28h]
     73: mov     [rbp-0A8h],rax
     7a: call    fn1
     7f: nop     [rcx-34h]
     86: jmp     263h
     8b: nop     [rax+rax]
     90: mov     rax,[rbp-10h]
     94: mov     [rbp-0B0h],rax
     9b: mov     rax,[rbp-18h]
     9f: mov     [rbp-0A8h],rax
     a6: mov     rax,[rbp+20h]
     aa: mov     [rbp-0A0h],rax
     b1: mov     rax,[rbp+30h]
     b5: mov     [rbp-98h],rax
     bc: call    fn2
     c1: nop     [rcx-31h]
     c8: jmp     26Bh
     cd: nop     [rax]
     d0: jmp     0E0h
     d2: nop     [rax+rax]
     db: nop     [rax+rax]
     e0: mov     edi,0FFFFFFD8h
     e5: lea     rsi,[k3]
     ec: call    ryo_h_AddrAbs
     f1: mov     qword ptr [rbp-20h],11Bh
     f9: mov     rax,[rbp-28h]
     fd: mov     [rbp-68h],rax
    101: mov     rax,[rbp-20h]
    105: mov     [rbp-60h],rax
    109: mov     rax,[rbp-68h]
    10d: mov     [rbp-58h],rax
    111: mov     [rbp-50h],rax
    115: mov     edi,0FFFFFF80h
    11a: lea     rsi,[k4]
    121: call    ryo_h_AddrAbs
    126: mov     qword ptr [rbp-78h],11Bh
    12e: mov     rax,[rbp-78h]
    132: mov     [rbp-70h],rax
    136: shl     rax,1
    13a: mov     [rbp-68h],rax
    13e: or      rax,1
    142: mov     [rbp-60h],rax
    146: mov     [rbp-58h],rax
    14a: mov     rax,[rbp-50h]
    14e: mov     [rbp-48h],rax
    152: mov     rax,[rbp-58h]
    156: mov     [rbp-40h],rax
    15a: mov     edi,0FFFFFF50h
    15f: mov     esi,0FFFFFFB8h
    164: call    ryo_h_MovW128
    169: mov     byte ptr [rbp-0A0h],0
    170: mov     rax,[rbp+38h]
    174: mov     [rbp-98h],rax
    17b: lea     rdi,[sym5]
    182: lea     rsi,[site6]
    189: mov     edx,0FFFFFF78h
    18e: call    ryo_h_CallExt
    193: test    rax,rax
    196: je      1A3h
    198: call    rax
    19a: nop     [rcx-28h]
    1a1: jmp     1B3h
    1a3: mov     rdi,rbp
    1a6: lea     rsi,[ro+4]
    1ad: call    qword ptr [sym7]
    1b3: call    ryo_h_Unreachable
    1b8: ud2
    1ba: nop     [rax+rax]
    1c0: xor     edi,edi
    1c2: xor     esi,esi
    1c4: call    ryo_h_Ret
    1c9: leave
    1ca: ret
    1cb: nop     [rax+rax]
    1d0: test    byte ptr [rbp-33h],0FFh
    1d4: je      1EAh
    1d6: jmp     1E5h
    1d8: nop     [rax+rax]
    1e0: jmp     0E0h
    1e5: jmp     60h
    1ea: mov     rax,[rbp+10h]
    1ee: mov     [rbp-40h],rax
    1f2: cmp     rax,0
    1f6: sete    [rbp-35h]
    1fa: movzx   eax,byte ptr [rbp-35h]
    1fe: xor     al,1
    201: mov     [rbp-32h],al
    204: test    byte ptr [rbp-32h],0FFh
    208: je      0E0h
    20e: jmp     60h
    213: test    byte ptr [rbp-34h],0FFh
    217: je      1E0h
    219: jmp     1D0h
    21b: nop     [rax+rax]
    220: test    byte ptr [rbp-1],0FFh
    224: je      23Ah
    226: jmp     235h
    228: nop     [rax+rax]
    230: jmp     0D0h
    235: jmp     90h
    23a: mov     rax,[rbp+18h]
    23e: mov     [rbp-40h],rax
    242: cmp     rax,0
    246: sete    [rbp-35h]
    24a: movzx   eax,byte ptr [rbp-35h]
    24e: xor     al,1
    251: mov     [rbp-33h],al
    254: test    byte ptr [rbp-33h],0FFh
    258: je      0D0h
    25e: jmp     90h
    263: test    byte ptr [rbp-34h],0FFh
    267: je      230h
    269: jmp     220h
    26b: test    byte ptr [rbp-31h],0FFh
    26f: je      0E0h
    275: jmp     1C0h
    27a: nop     [rax+rax]
    280: lea     rdi,[sym8]
    287: lea     rsi,[site9]
    28e: mov     edx,0FFFFFF78h
    293: call    ryo_h_CallExt
    298: test    rax,rax
    29b: je      2A8h
    29d: call    rax
    29f: nop     [rcx-80h]
    2a6: jmp     2B8h
    2a8: mov     rdi,rbp
    2ab: lea     rsi,[ro+20]
    2b2: call    qword ptr [sym10]
    2b8: call    ryo_h_Unreachable
    2bd: ud2
    2bf: mov     rdi,rax
    2c2: mov     esi,0FFFFFFD0h
    2c7: call    ryo_h_Lpad
    2cc: jmp     280h

fn std::ptr::swap_nonoverlapping_bytes
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-18h],rax
     10: mov     qword ptr [rbp-58h],8
     18: mov     edi,0FFFFFFE0h
     1d: mov     esi,0FFFFFFE8h
     22: mov     edx,0FFFFFFA8h
     27: call    ryo_h_DivUW64
     2c: mov     qword ptr [rbp-58h],8
     34: mov     edi,0FFFFFFD8h
     39: mov     esi,0FFFFFFE8h
     3e: mov     edx,0FFFFFFA8h
     43: call    ryo_h_RemUW64
     48: mov     rax,[rbp-20h]
     4c: mov     [rbp-30h],rax
     50: mov     edi,0FFFFFFACh
     55: mov     esi,0FFFFFFD0h
     5a: xor     edx,edx
     5c: xor     ecx,ecx
     5e: xor     r8d,r8d
     61: mov     r9d,1
     67: call    ryo_h_DiscrNicheW64
     6c: mov     edi,0FFFFFFF8h
     71: mov     esi,0FFFFFFACh
     76: call    ryo_h_ZextW32W64
     7b: mov     edi,0FFFFFFF8h
     80: xor     esi,esi
     82: mov     edx,2
     87: call    ryo_h_SwitchDenseW64
     8c: lea     rcx,[9Ch]
     93: movsxd  rax,[rcx+rax*4]
     97: add     rax,rcx
     9a: jmp     rax
     9c: .long   e6h
     a0: .long   a8h
     a4: .long   1aah
     a8: mov     rax,[rbp-30h]
     ac: mov     [rbp-38h],rax
     b0: mov     rax,[rbp+10h]
     b4: mov     [rbp-40h],rax
     b8: mov     rax,[rbp+18h]
     bc: mov     [rbp-48h],rax
     c0: mov     rax,[rbp-40h]
     c4: mov     [rbp-70h],rax
     c8: mov     rax,[rbp-48h]
     cc: mov     [rbp-68h],rax
     d0: mov     rax,[rbp-38h]
     d4: mov     [rbp-60h],rax
     d8: call    fn0
     dd: nop     [rcx-8]
     e4: jmp     0E6h
     e6: mov     rax,[rbp-28h]
     ea: mov     [rbp-30h],rax
     ee: mov     edi,0FFFFFFACh
     f3: mov     esi,0FFFFFFD0h
     f8: xor     edx,edx
     fa: xor     ecx,ecx
     fc: xor     r8d,r8d
     ff: mov     r9d,1
    105: call    ryo_h_DiscrNicheW64
    10a: mov     edi,0FFFFFFF0h
    10f: mov     esi,0FFFFFFACh
    114: call    ryo_h_ZextW32W64
    119: mov     edi,0FFFFFFF0h
    11e: xor     esi,esi
    120: mov     edx,2
    125: call    ryo_h_SwitchDenseW64
    12a: lea     rcx,[13Ch]
    131: movsxd  rax,[rcx+rax*4]
    135: add     rax,rcx
    138: jmp     rax
    13a: int3
    13b: int3
    13c: .long   19fh
    140: .long   148h
    144: .long   1aah
    148: mov     rax,[rbp-30h]
    14c: mov     [rbp-38h],rax
    150: imul    rax,[rbp-20h],8
    155: mov     [rbp-40h],rax
    159: mov     rax,[rbp+10h]
    15d: imul    rcx,[rbp-40h],1
    162: add     rax,rcx
    165: mov     [rbp-48h],rax
    169: mov     rax,[rbp+18h]
    16d: imul    rcx,[rbp-40h],1
    172: add     rax,rcx
    175: mov     [rbp-50h],rax
    179: mov     rax,[rbp-48h]
    17d: mov     [rbp-70h],rax
    181: mov     rax,[rbp-50h]
    185: mov     [rbp-68h],rax
    189: mov     rax,[rbp-38h]
    18d: mov     [rbp-60h],rax
    191: call    fn1
    196: nop     [rcx-10h]
    19d: jmp     19Fh
    19f: xor     edi,edi
    1a1: xor     esi,esi
    1a3: call    ryo_h_Ret
    1a8: leave
    1a9: ret
    1aa: call    ryo_h_Unreachable
    1af: ud2

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-30h],rax
     13: mov     qword ptr [rbp-10h],0
     1b: mov     [rbp-8],rax
     1f: nop
     20: mov     rax,[rbp-10h]
     24: mov     [rbp-50h],rax
     28: mov     rax,[rbp-8]
     2c: mov     [rbp-58h],rax
     30: mov     rax,[rbp-50h]
     34: cmp     rax,[rbp-58h]
     38: setb    [rbp-41h]
     3c: test    byte ptr [rbp-41h],0FFh
     40: je      66h
     42: jmp     52h
     44: nop     [rax+rax]
     4d: nop     [rax]
     50: jmp     20h
     52: mov     rax,[rbp-10h]
     56: mov     [rbp-50h],rax
     5a: mov     byte ptr [rbp-69h],1
     5e: test    byte ptr [rbp-69h],0FFh
     62: je      0A4h
     64: jmp     71h
     66: xor     edi,edi
     68: xor     esi,esi
     6a: call    ryo_h_Ret
     6f: leave
     70: ret
     71: mov     rax,[rbp-50h]
     75: mov     [rbp-90h],rax
     7c: mov     qword ptr [rbp-88h],1
     87: mov     edi,0FFFFFF80h
     8c: lea     rsi,[k0]
     93: call    ryo_h_AddrAbs
     98: call    fn1
     9d: nop     [rcx-28h]
     a4: mov     rax,[rbp-50h]
     a8: add     rax,1
     ac: mov     [rbp-58h],rax
     b0: mov     [rbp-10h],rax
     b4: mov     rax,[rbp-50h]
     b8: mov     [rbp-38h],rax
     bc: mov     qword ptr [rbp-40h],1
     c4: mov     [rbp-48h],rax
     c8: mov     rax,[rbp+10h]
     cc: imul    rcx,[rbp-48h],8
     d1: add     rax,rcx
     d4: mov     [rbp-58h],rax
     d8: mov     [rbp-50h],rax
     dc: mov     rax,[rbp+18h]
     e0: imul    rcx,[rbp-48h],8
     e5: add     rax,rcx
     e8: mov     [rbp-68h],rax
     ec: mov     [rbp-60h],rax
     f0: mov     rax,[rbp-50h]
     f4: mov     [rbp-90h],rax
     fb: mov     rax,[rbp-60h]
     ff: mov     [rbp-88h],rax
    106: call    fn2
    10b: nop     [rcx-18h]
    112: jmp     50h

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-20h],rax
     10: mov     qword ptr [rbp-28h],0
     18: and     rax,4
     1c: mov     [rbp-30h],rax
     20: cmp     rax,0
     24: je      90h
     26: mov     rax,[rbp-28h]
     2a: mov     [rbp-48h],rax
     2e: mov     rax,[rbp+10h]
     32: imul    rcx,[rbp-48h],1
     37: add     rax,rcx
     3a: mov     [rbp-40h],rax
     3e: mov     [rbp-38h],rax
     42: mov     [rbp-30h],rax
     46: mov     rax,[rbp-28h]
     4a: mov     [rbp-58h],rax
     4e: mov     rax,[rbp+18h]
     52: imul    rcx,[rbp-58h],1
     57: add     rax,rcx
     5a: mov     [rbp-50h],rax
     5e: mov     [rbp-48h],rax
     62: mov     [rbp-40h],rax
     66: mov     rax,[rbp-30h]
     6a: mov     [rbp-70h],rax
     6e: mov     rax,[rbp-40h]
     72: mov     [rbp-68h],rax
     76: call    fn0
     7b: nop     [rcx]
     82: mov     rax,[rbp-28h]
     86: or      rax,4
     8a: mov     [rbp-28h],rax
     8e: jmp     90h
     90: mov     rax,[rbp-20h]
     94: and     rax,2
     98: mov     [rbp-30h],rax
     9c: cmp     rax,0
     a0: je      10Ch
     a2: mov     rax,[rbp-28h]
     a6: mov     [rbp-48h],rax
     aa: mov     rax,[rbp+10h]
     ae: imul    rcx,[rbp-48h],1
     b3: add     rax,rcx
     b6: mov     [rbp-40h],rax
     ba: mov     [rbp-38h],rax
     be: mov     [rbp-30h],rax
     c2: mov     rax,[rbp-28h]
     c6: mov     [rbp-58h],rax
     ca: mov     rax,[rbp+18h]
     ce: imul    rcx,[rbp-58h],1
     d3: add     rax,rcx
     d6: mov     [rbp-50h],rax
     da: mov     [rbp-48h],rax
     de: mov     [rbp-40h],rax
     e2: mov     rax,[rbp-30h]
     e6: mov     [rbp-70h],rax
     ea: mov     rax,[rbp-40h]
     ee: mov     [rbp-68h],rax
     f2: call    fn1
     f7: nop     [rcx]
     fe: mov     rax,[rbp-28h]
    102: or      rax,2
    106: mov     [rbp-28h],rax
    10a: jmp     10Ch
    10c: mov     rax,[rbp-20h]
    110: and     rax,1
    114: mov     [rbp-30h],rax
    118: cmp     rax,0
    11c: je      188h
    11e: mov     rax,[rbp-28h]
    122: mov     [rbp-48h],rax
    126: mov     rax,[rbp+10h]
    12a: imul    rcx,[rbp-48h],1
    12f: add     rax,rcx
    132: mov     [rbp-40h],rax
    136: mov     [rbp-38h],rax
    13a: mov     [rbp-30h],rax
    13e: mov     rax,[rbp-28h]
    142: mov     [rbp-58h],rax
    146: mov     rax,[rbp+18h]
    14a: imul    rcx,[rbp-58h],1
    14f: add     rax,rcx
    152: mov     [rbp-50h],rax
    156: mov     [rbp-48h],rax
    15a: mov     [rbp-40h],rax
    15e: mov     rax,[rbp-30h]
    162: mov     [rbp-70h],rax
    166: mov     rax,[rbp-40h]
    16a: mov     [rbp-68h],rax
    16e: call    fn2
    173: nop     [rcx]
    17a: mov     rax,[rbp-28h]
    17e: or      rax,1
    182: mov     [rbp-28h],rax
    186: jmp     188h
    188: xor     edi,edi
    18a: xor     esi,esi
    18c: call    ryo_h_Ret
    191: leave
    192: ret

fn std::rt::lang_start::<()>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rax,[rbp-28h]
     14: mov     [rbp-20h],rax
     18: mov     [rbp-18h],rax
     1c: mov     edi,0FFFFFFF0h
     21: lea     rsi,[k0]
     28: call    ryo_h_AddrAbs
     2d: mov     edi,0FFFFFFA0h
     32: mov     esi,0FFFFFFE8h
     37: call    ryo_h_MovW128
     3c: mov     rax,[rbp+18h]
     40: mov     [rbp-50h],rax
     44: mov     rax,[rbp+20h]
     48: mov     [rbp-48h],rax
     4c: movzx   eax,byte ptr [rbp+28h]
     50: mov     [rbp-40h],al
     53: lea     rdi,[sym1]
     5a: lea     rsi,[site2]
     61: mov     edx,0FFFFFFD0h
     66: call    ryo_h_CallExt
     6b: test    rax,rax
     6e: je      7Bh
     70: call    rax
     72: nop     [rcx-8]
     79: jmp     8Bh
     7b: mov     rdi,rbp
     7e: lea     rsi,[ro+4]
     85: call    qword ptr [sym3]
     8b: mov     edi,0FFFFFFF8h
     90: mov     esi,8
     95: call    ryo_h_Ret
     9a: leave
     9b: ret

fn std::rt::lang_start::<()>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     [rbp-20h],rax
     17: call    fn0
     1c: nop     [rcx-4]
     23: call    fn1
     28: nop     [rcx-5]
     2f: movzx   eax,byte ptr [rbp-5]
     33: mov     [rbp-6],al
     36: mov     edi,0FFFFFFFCh
     3b: mov     esi,0FFFFFFFAh
     40: call    ryo_h_ZextW8W32
     45: mov     edi,0FFFFFFFCh
     4a: mov     esi,4
     4f: call    ryo_h_Ret
     54: leave
     55: ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: lea     rax,[rbp+20h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-10h],rax
     14: mov     edi,0FFFFFFD0h
     19: mov     esi,10h
     1e: call    ryo_h_MovW128
     23: mov     rax,[rbp-10h]
     27: mov     [rbp-20h],rax
     2b: call    fn0
     30: nop     [rcx]
     37: xor     edi,edi
     39: xor     esi,esi
     3b: call    ryo_h_Ret
     40: leave
     41: ret
     42: nop     [rax+rax]
     4b: nop     [rax+rax]
     50: mov     edi,0FFFFFFF8h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFF8h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-50h],rax
     23: mov     rax,[rbp-38h]
     27: mov     [rbp-48h],rax
     2b: call    fn0
     30: nop     [rcx-2Ch]
     37: lea     rax,[rbp-2Ch]
     3b: mov     [rbp-28h],rax
     3f: mov     rax,[rbp+10h]
     43: mov     rax,[rax]
     46: mov     [rbp-18h],rax
     4a: mov     rax,[rbp+20h]
     4e: mov     [rbp-40h],rax
     52: mov     rax,[rbp-18h]
     56: mov     [rbp-50h],rax
     5a: mov     rax,[rbp-40h]
     5e: mov     [rbp-48h],rax
     62: call    fn1
     67: nop     [rcx-30h]
     6e: lea     rax,[rbp-30h]
     72: mov     [rbp-38h],rax
     76: mov     rax,[rbp-28h]
     7a: mov     [rbp-50h],rax
     7e: mov     rax,[rbp-38h]
     82: mov     [rbp-48h],rax
     86: call    fn2
     8b: nop     [rcx-1]
     92: mov     edi,0FFFFFFFFh
     97: mov     esi,1
     9c: call    ryo_h_Ret
     a1: leave
     a2: ret
     a3: nop     [rax+rax]
     ac: nop     [rax]
     b0: mov     edi,0FFFFFFE0h
     b5: call    ryo_h_Resume
     ba: ud2
     bc: mov     rdi,rax
     bf: mov     esi,0FFFFFFE0h
     c4: call    ryo_h_Lpad
     c9: jmp     0B0h
     cb: mov     rdi,rax
     ce: mov     esi,0FFFFFFE0h
     d3: call    ryo_h_Lpad
     d8: jmp     0B0h

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::as_uninit_slice_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-40h],rax
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp+10h]
     1f: mov     rax,[rax+10h]
     23: mov     [rbp-40h],rax
     27: mov     rax,[rbp-38h]
     2b: imul    rcx,[rbp-40h],8
     30: add     rax,rcx
     33: mov     [rbp-30h],rax
     37: mov     [rbp-28h],rax
     3b: mov     qword ptr [rbp-50h],8
     43: cmp     qword ptr [rbp-50h],0
     48: je      74h
     4a: jmp     7Eh
     4c: nop     [rax]
     50: mov     rax,[rbp+10h]
     54: mov     rax,[rax+10h]
     58: mov     [rbp-48h],rax
     5c: mov     rax,[rbp-40h]
     60: sub     rax,[rbp-48h]
     64: mov     [rbp-38h],rax
     68: mov     byte ptr [rbp-49h],1
     6c: test    byte ptr [rbp-49h],0FFh
     70: je      0D0h
     72: jmp     8Fh
     74: mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
     7c: jmp     50h
     7e: mov     rax,[rbp+10h]
     82: mov     rax,[rax]
     85: mov     [rbp-48h],rax
     89: mov     [rbp-40h],rax
     8d: jmp     50h
     8f: mov     rax,[rbp-30h]
     93: mov     [rbp-40h],rax
     97: mov     [rbp-80h],rax
     9b: mov     qword ptr [rbp-78h],8
     a3: mov     qword ptr [rbp-70h],4
     ab: mov     rax,[rbp-38h]
     af: mov     [rbp-68h],rax
     b3: mov     edi,0FFFFFFA0h
     b8: lea     rsi,[k0]
     bf: call    ryo_h_AddrAbs
     c4: call    fn1
     c9: nop     [rcx-20h]
     d0: mov     rax,[rbp-30h]
     d4: mov     [rbp-48h],rax
     d8: mov     rax,[rbp-38h]
     dc: mov     [rbp-40h],rax
     e0: mov     rax,[rbp-48h]
     e4: mov     [rbp-10h],rax
     e8: mov     rax,[rbp-40h]
     ec: mov     [rbp-8],rax
     f0: mov     edi,0FFFFFFF0h
     f5: mov     esi,10h
     fa: call    ryo_h_Ret
     ff: leave
    100: ret

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::with_capacity
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-50h],rax
     10: mov     edi,0FFFFFFB8h
     15: lea     rsi,[k0]
     1c: mov     edx,10h
     21: call    ryo_h_Const
     26: call    fn1
     2b: nop     [rcx-38h]
     32: mov     edi,0FFFFFFD8h
     37: mov     esi,0FFFFFFC8h
     3c: call    ryo_h_MovW128
     41: mov     edi,0FFFFFFE8h
     46: mov     esi,0FFFFFFD8h
     4b: call    ryo_h_MovW128
     50: mov     qword ptr [rbp-8],0
     58: mov     edi,0FFFFFFE8h
     5d: mov     esi,18h
     62: call    ryo_h_Ret
     67: leave
     68: ret

fn std::slice::Iter::<'_, u32>::make_slice
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     [rbp-28h],rax
     1a: mov     byte ptr [rbp-61h],0
     1e: test    byte ptr [rbp-61h],0FFh
     22: je      36h
     24: mov     rax,[rbp+10h]
     28: mov     rax,[rax+8]
     2c: mov     [rbp-30h],rax
     30: mov     [rbp-20h],rax
     34: jmp     80h
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax+8]
     3e: mov     [rbp-38h],rax
     42: mov     [rbp-30h],rax
     46: mov     rax,[rbp+10h]
     4a: mov     rax,[rax]
     4d: mov     [rbp-38h],rax
     51: mov     rax,[rbp-30h]
     55: mov     [rbp-40h],rax
     59: mov     rax,[rbp-38h]
     5d: mov     [rbp-48h],rax
     61: mov     rax,[rbp-30h]
     65: mov     [rbp-50h],rax
     69: mov     byte ptr [rbp-61h],1
     6d: test    byte ptr [rbp-61h],0FFh
     71: je      0E5h
     73: jmp     0A2h
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: mov     byte ptr [rbp-61h],1
     84: test    byte ptr [rbp-61h],0FFh
     88: je      1FFh
     8e: jmp     1B8h
     93: nop     [rax+rax]
     9c: nop     [rax]
     a0: jmp     80h
     a2: mov     rax,[rbp-30h]
     a6: mov     [rbp-58h],rax
     aa: mov     rax,[rbp-38h]
     ae: mov     [rbp-60h],rax
     b2: mov     rax,[rbp-58h]
     b6: mov     [rbp-90h],rax
     bd: mov     rax,[rbp-60h]
     c1: mov     [rbp-88h],rax
     c8: mov     edi,0FFFFFF80h
     cd: lea     rsi,[k0]
     d4: call    ryo_h_AddrAbs
     d9: call    fn1
     de: nop     [rcx-20h]
     e5: mov     qword ptr [rbp-68h],0
     ed: cmp     qword ptr [rbp-68h],4
     f2: setb    [rbp-51h]
     f6: test    byte ptr [rbp-51h],0FFh
     fa: je      14Ch
     fc: mov     qword ptr [rbp-68h],4
    104: mov     rax,[rbp-68h]
    108: mov     rcx,7FFFFFFFFFFFFFFFh
    112: cmp     rax,rcx
    115: setbe   [rbp-52h]
    119: test    byte ptr [rbp-52h],0FFh
    11d: je      14Ch
    11f: mov     rax,[rbp-50h]
    123: sub     rax,[rbp-48h]
    127: mov     [rbp-20h],rax
    12b: mov     qword ptr [rbp-68h],4
    133: mov     edi,0FFFFFFE0h
    138: mov     esi,0FFFFFFE0h
    13d: mov     edx,0FFFFFF98h
    142: call    ryo_h_DivUW64
    147: jmp     0A0h
    14c: mov     edi,0FFFFFF70h
    151: lea     rsi,[k2]
    158: call    ryo_h_AddrAbs
    15d: mov     qword ptr [rbp-88h],49h
    168: mov     edi,0FFFFFF80h
    16d: lea     rsi,[k3]
    174: call    ryo_h_AddrAbs
    179: lea     rdi,[sym4]
    180: lea     rsi,[site5]
    187: mov     edx,0FFFFFF98h
    18c: call    ryo_h_CallExt
    191: test    rax,rax
    194: je      1A1h
    196: call    rax
    198: nop     [rcx-20h]
    19f: jmp     1B1h
    1a1: mov     rdi,rbp
    1a4: lea     rsi,[ro+4]
    1ab: call    qword ptr [sym6]
    1b1: call    ryo_h_Unreachable
    1b6: ud2
    1b8: mov     rax,[rbp-18h]
    1bc: mov     [rbp-30h],rax
    1c0: mov     [rbp-90h],rax
    1c7: mov     qword ptr [rbp-88h],4
    1d2: mov     qword ptr [rbp-80h],4
    1da: mov     rax,[rbp-20h]
    1de: mov     [rbp-78h],rax
    1e2: mov     edi,0FFFFFF90h
    1e7: lea     rsi,[k7]
    1ee: call    ryo_h_AddrAbs
    1f3: call    fn8
    1f8: nop     [rcx-20h]
    1ff: mov     rax,[rbp-28h]
    203: mov     [rbp-38h],rax
    207: mov     rax,[rbp-20h]
    20b: mov     [rbp-30h],rax
    20f: mov     rax,[rbp-38h]
    213: mov     [rbp-10h],rax
    217: mov     rax,[rbp-30h]
    21b: mov     [rbp-8],rax
    21f: mov     edi,0FFFFFFF0h
    224: mov     esi,10h
    229: call    ryo_h_Ret
    22e: leave
    22f: ret

fn std::slice::Iter::<'_, u32>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-20h],rax
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-48h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     [rbp-40h],rax
     20: mov     edi,0FFFFFFC8h
     25: mov     esi,0FFFFFFB8h
     2a: call    ryo_h_MovW128
     2f: mov     edi,0FFFFFFB0h
     34: mov     esi,0FFFFFFC8h
     39: call    ryo_h_MovW128
     3e: mov     rax,[rbp-50h]
     42: mov     [rbp-40h],rax
     46: mov     [rbp-28h],rax
     4a: mov     byte ptr [rbp-51h],0
     4e: test    byte ptr [rbp-51h],0FFh
     52: je      5Eh
     54: mov     rax,[rbp-20h]
     58: mov     [rbp-18h],rax
     5c: jmp     76h
     5e: mov     rax,[rbp-28h]
     62: mov     [rbp-38h],rax
     66: imul    rcx,[rbp-20h],4
     6b: add     rax,rcx
     6e: mov     [rbp-30h],rax
     72: mov     [rbp-18h],rax
     76: mov     rax,[rbp-28h]
     7a: mov     [rbp-10h],rax
     7e: mov     rax,[rbp-18h]
     82: mov     [rbp-8],rax
     86: mov     edi,0FFFFFFF0h
     8b: mov     esi,10h
     90: call    ryo_h_Ret
     95: leave
     96: ret

fn std::slice::from_raw_parts::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     [rbp-90h],rax
     1a: mov     rax,[rbp+20h]
     1e: mov     [rbp-88h],rax
     25: call    fn0
     2a: nop     [rcx-1Ah]
     31: jmp     185h
     36: nop     [rax+rax]
     3f: nop
     40: cmp     qword ptr [rbp+18h],0
     45: je      18Dh
     4b: jmp     197h
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: nop     [rax+rax]
     60: jmp     70h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     edi,0FFFFFFF0h
     75: lea     rsi,[k1]
     7c: call    ryo_h_AddrAbs
     81: mov     qword ptr [rbp-8],117h
     89: mov     rax,[rbp-10h]
     8d: mov     [rbp-50h],rax
     91: mov     rax,[rbp-8]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-50h]
     9d: mov     [rbp-40h],rax
     a1: mov     [rbp-38h],rax
     a5: mov     edi,0FFFFFF98h
     aa: lea     rsi,[k2]
     b1: call    ryo_h_AddrAbs
     b6: mov     qword ptr [rbp-60h],117h
     be: mov     rax,[rbp-60h]
     c2: mov     [rbp-58h],rax
     c6: shl     rax,1
     ca: mov     [rbp-50h],rax
     ce: or      rax,1
     d2: mov     [rbp-48h],rax
     d6: mov     [rbp-40h],rax
     da: mov     rax,[rbp-38h]
     de: mov     [rbp-30h],rax
     e2: mov     rax,[rbp-40h]
     e6: mov     [rbp-28h],rax
     ea: mov     edi,0FFFFFF70h
     ef: mov     esi,0FFFFFFD0h
     f4: call    ryo_h_MovW128
     f9: mov     byte ptr [rbp-80h],0
     fd: mov     rax,[rbp+30h]
    101: mov     [rbp-78h],rax
    105: lea     rdi,[sym3]
    10c: lea     rsi,[site4]
    113: mov     edx,0FFFFFF90h
    118: call    ryo_h_CallExt
    11d: test    rax,rax
    120: je      12Dh
    122: call    rax
    124: nop     [rcx-10h]
    12b: jmp     13Dh
    12d: mov     rdi,rbp
    130: lea     rsi,[ro+4]
    137: call    qword ptr [sym5]
    13d: call    ryo_h_Unreachable
    142: ud2
    144: nop     [rax+rax]
    14d: nop     [rax]
    150: mov     rax,[rbp+10h]
    154: mov     [rbp-30h],rax
    158: cmp     rax,0
    15c: sete    [rbp-1Bh]
    160: movzx   eax,byte ptr [rbp-1Bh]
    164: xor     al,1
    167: mov     [rbp-19h],al
    16a: test    byte ptr [rbp-19h],0FFh
    16e: je      70h
    174: jmp     40h
    179: nop     [rax]
    180: jmp     70h
    185: test    byte ptr [rbp-1Ah],0FFh
    189: je      180h
    18b: jmp     150h
    18d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    195: jmp     1B9h
    197: mov     rax,7FFFFFFFFFFFFFFFh
    1a1: mov     [rbp-70h],rax
    1a5: mov     edi,0FFFFFFD8h
    1aa: mov     esi,0FFFFFF90h
    1af: mov     edx,18h
    1b4: call    ryo_h_DivUW64
    1b9: mov     rax,[rbp+28h]
    1bd: cmp     rax,[rbp-28h]
    1c1: setbe   [rbp-1Ah]
    1c5: test    byte ptr [rbp-1Ah],0FFh
    1c9: je      60h
    1cf: jmp     50h
    1d4: nop     [rax+rax]
    1dd: nop     [rax]
    1e0: lea     rdi,[sym6]
    1e7: lea     rsi,[site7]
    1ee: mov     edx,0FFFFFF90h
    1f3: call    ryo_h_CallExt
    1f8: test    rax,rax
    1fb: je      208h
    1fd: call    rax
    1ff: nop     [rcx-68h]
    206: jmp     218h
    208: mov     rdi,rbp
    20b: lea     rsi,[ro+20]
    212: call    qword ptr [sym8]
    218: call    ryo_h_Unreachable
    21d: ud2
    21f: mov     rdi,rax
    222: mov     esi,0FFFFFFE8h
    227: call    ryo_h_Lpad
    22c: jmp     1E0h

fn std::slice::from_raw_parts_mut::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     [rbp-90h],rax
     1a: mov     rax,[rbp+20h]
     1e: mov     [rbp-88h],rax
     25: call    fn0
     2a: nop     [rcx-1Ah]
     31: jmp     185h
     36: nop     [rax+rax]
     3f: nop
     40: cmp     qword ptr [rbp+18h],0
     45: je      18Dh
     4b: jmp     197h
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: nop     [rax+rax]
     60: jmp     70h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     edi,0FFFFFFF0h
     75: lea     rsi,[k1]
     7c: call    ryo_h_AddrAbs
     81: mov     qword ptr [rbp-8],11Bh
     89: mov     rax,[rbp-10h]
     8d: mov     [rbp-50h],rax
     91: mov     rax,[rbp-8]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-50h]
     9d: mov     [rbp-40h],rax
     a1: mov     [rbp-38h],rax
     a5: mov     edi,0FFFFFF98h
     aa: lea     rsi,[k2]
     b1: call    ryo_h_AddrAbs
     b6: mov     qword ptr [rbp-60h],11Bh
     be: mov     rax,[rbp-60h]
     c2: mov     [rbp-58h],rax
     c6: shl     rax,1
     ca: mov     [rbp-50h],rax
     ce: or      rax,1
     d2: mov     [rbp-48h],rax
     d6: mov     [rbp-40h],rax
     da: mov     rax,[rbp-38h]
     de: mov     [rbp-30h],rax
     e2: mov     rax,[rbp-40h]
     e6: mov     [rbp-28h],rax
     ea: mov     edi,0FFFFFF70h
     ef: mov     esi,0FFFFFFD0h
     f4: call    ryo_h_MovW128
     f9: mov     byte ptr [rbp-80h],0
     fd: mov     rax,[rbp+30h]
    101: mov     [rbp-78h],rax
    105: lea     rdi,[sym3]
    10c: lea     rsi,[site4]
    113: mov     edx,0FFFFFF90h
    118: call    ryo_h_CallExt
    11d: test    rax,rax
    120: je      12Dh
    122: call    rax
    124: nop     [rcx-10h]
    12b: jmp     13Dh
    12d: mov     rdi,rbp
    130: lea     rsi,[ro+4]
    137: call    qword ptr [sym5]
    13d: call    ryo_h_Unreachable
    142: ud2
    144: nop     [rax+rax]
    14d: nop     [rax]
    150: mov     rax,[rbp+10h]
    154: mov     [rbp-30h],rax
    158: cmp     rax,0
    15c: sete    [rbp-1Bh]
    160: movzx   eax,byte ptr [rbp-1Bh]
    164: xor     al,1
    167: mov     [rbp-19h],al
    16a: test    byte ptr [rbp-19h],0FFh
    16e: je      70h
    174: jmp     40h
    179: nop     [rax]
    180: jmp     70h
    185: test    byte ptr [rbp-1Ah],0FFh
    189: je      180h
    18b: jmp     150h
    18d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    195: jmp     1B9h
    197: mov     rax,7FFFFFFFFFFFFFFFh
    1a1: mov     [rbp-70h],rax
    1a5: mov     edi,0FFFFFFD8h
    1aa: mov     esi,0FFFFFF90h
    1af: mov     edx,18h
    1b4: call    ryo_h_DivUW64
    1b9: mov     rax,[rbp+28h]
    1bd: cmp     rax,[rbp-28h]
    1c1: setbe   [rbp-1Ah]
    1c5: test    byte ptr [rbp-1Ah],0FFh
    1c9: je      60h
    1cf: jmp     50h
    1d4: nop     [rax+rax]
    1dd: nop     [rax]
    1e0: lea     rdi,[sym6]
    1e7: lea     rsi,[site7]
    1ee: mov     edx,0FFFFFF90h
    1f3: call    ryo_h_CallExt
    1f8: test    rax,rax
    1fb: je      208h
    1fd: call    rax
    1ff: nop     [rcx-68h]
    206: jmp     218h
    208: mov     rdi,rbp
    20b: lea     rsi,[ro+20]
    212: call    qword ptr [sym8]
    218: call    ryo_h_Unreachable
    21d: ud2
    21f: mov     rdi,rax
    222: mov     esi,0FFFFFFE8h
    227: call    ryo_h_Lpad
    22c: jmp     1E0h

fn std::slice::stable_sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: lea     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: mov     byte ptr [rbp-1Ah],0
     14: test    byte ptr [rbp-1Ah],0FFh
     18: je      42h
     1a: jmp     40h
     1c: nop     [rax]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret
     2b: nop     [rax+rax]
     30: mov     edi,0FFFFFFF8h
     35: call    ryo_h_Resume
     3a: ud2
     3c: nop     [rax]
     40: jmp     20h
     42: mov     rax,[rbp+18h]
     46: mov     [rbp-18h],rax
     4a: cmp     rax,2
     4e: setb    [rbp-19h]
     52: test    byte ptr [rbp-19h],0FFh
     56: je      74h
     58: jmp     72h
     5a: nop     [rax+rax]
     60: jmp     40h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: jmp     40h
     72: jmp     70h
     74: cmp     qword ptr [rbp-18h],14h
     79: setbe   [rbp-19h]
     7d: test    byte ptr [rbp-19h],0FFh
     81: je      0B0h
     83: mov     edi,0FFFFFFC0h
     88: mov     esi,10h
     8d: call    ryo_h_MovW128
     92: mov     qword ptr [rbp-30h],1
     9a: mov     rax,[rbp-10h]
     9e: mov     [rbp-28h],rax
     a2: call    fn0
     a7: nop     [rcx]
     ae: jmp     0D5h
     b0: mov     edi,0FFFFFFC0h
     b5: mov     esi,10h
     ba: call    ryo_h_MovW128
     bf: mov     rax,[rbp-10h]
     c3: mov     [rbp-30h],rax
     c7: call    fn1
     cc: nop     [rcx]
     d3: jmp     60h
     d5: jmp     70h
     d7: mov     rdi,rax
     da: mov     esi,0FFFFFFF8h
     df: call    ryo_h_Lpad
     e4: jmp     30h

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: call    fn0
     15: nop     [rcx]
     1c: xor     edi,edi
     1e: xor     esi,esi
     20: call    ryo_h_Ret
     25: leave
     26: ret

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,100h
      b: mov     byte ptr [rbp-49h],1
      f: lea     rax,[rbp+18h]
     13: mov     [rbp-68h],rax
     17: mov     [rbp-100h],rax
     1e: call    fn0
     23: nop     [rcx-90h]
     2a: mov     rax,[rbp-90h]
     31: mov     [rbp-68h],rax
     35: mov     edi,0FFFFFF88h
     3a: mov     esi,0FFFFFF78h
     3f: call    ryo_h_MovW128
     44: mov     rax,[rbp-78h]
     48: mov     [rbp-8],rax
     4c: mov     edi,0FFFFFFF8h
     51: xor     esi,esi
     53: mov     edx,2
     58: call    ryo_h_SwitchDenseW64
     5d: lea     rcx,[70h]
     64: movsxd  rax,[rcx+rax*4]
     68: add     rax,rcx
     6b: jmp     rax
     6d: int3
     6e: int3
     6f: int3
     70: .long   15bh
     74: .long   7ch
     78: .long   298h
     7c: mov     rax,[rbp-70h]
     80: mov     [rbp-80h],rax
     84: mov     rax,[rbp+10h]
     88: mov     [rbp-100h],rax
     8f: mov     rax,[rbp-80h]
     93: mov     [rbp-0F8h],rax
     9a: call    fn1
     9f: nop     [rcx-48h]
     a6: mov     rax,[rbp+10h]
     aa: mov     rax,[rax+8]
     ae: mov     [rbp-90h],rax
     b5: mov     [rbp-88h],rax
     bc: mov     rax,[rbp+10h]
     c0: lea     rax,[rax+10h]
     c4: mov     [rbp-0A0h],rax
     cb: mov     rax,[rax]
     ce: mov     [rbp-0A8h],rax
     d5: mov     rax,[rbp-0A0h]
     dc: mov     [rbp-98h],rax
     e3: mov     rax,[rbp-0A8h]
     ea: mov     [rbp-90h],rax
     f1: mov     byte ptr [rbp-49h],0
     f5: mov     edi,0FFFFFF58h
     fa: mov     esi,18h
     ff: call    ryo_h_MovW128
    104: mov     rax,[rbp-88h]
    10b: mov     [rbp-0B0h],rax
    112: mov     edi,0FFFFFF40h
    117: mov     esi,0FFFFFF68h
    11c: call    ryo_h_MovW128
    121: mov     edi,0FFFFFF00h
    126: mov     esi,0FFFFFF58h
    12b: call    ryo_h_MovW128
    130: mov     edi,0FFFFFF10h
    135: mov     esi,0FFFFFF40h
    13a: mov     edx,18h
    13f: call    ryo_h_Copy
    144: call    fn2
    149: nop     [rcx-48h]
    150: xor     edi,edi
    152: xor     esi,esi
    154: call    ryo_h_Ret
    159: leave
    15a: ret
    15b: mov     edi,0FFFFFF68h
    160: lea     rsi,[k3]
    167: call    ryo_h_AddrAbs
    16c: mov     qword ptr [rbp-90h],11h
    177: mov     rax,[rbp-98h]
    17e: mov     [rbp-0B8h],rax
    185: mov     rax,[rbp-90h]
    18c: mov     [rbp-0B0h],rax
    193: mov     rax,[rbp-0B8h]
    19a: mov     [rbp-0A8h],rax
    1a1: mov     [rbp-0A0h],rax
    1a8: mov     edi,0FFFFFF30h
    1ad: lea     rsi,[k4]
    1b4: call    ryo_h_AddrAbs
    1b9: mov     qword ptr [rbp-0C8h],11h
    1c4: mov     rax,[rbp-0C8h]
    1cb: mov     [rbp-0C0h],rax
    1d2: shl     rax,1
    1d6: mov     [rbp-0B8h],rax
    1dd: or      rax,1
    1e1: mov     [rbp-0B0h],rax
    1e8: mov     [rbp-0A8h],rax
    1ef: mov     rax,[rbp-0A0h]
    1f6: mov     [rbp-88h],rax
    1fd: mov     rax,[rbp-0A8h]
    204: mov     [rbp-80h],rax
    208: mov     edi,0FFFFFF00h
    20d: mov     esi,0FFFFFF78h
    212: call    ryo_h_MovW128
    217: mov     edi,0FFFFFF10h
    21c: lea     rsi,[k5]
    223: call    ryo_h_AddrAbs
    228: lea     rdi,[sym6]
    22f: lea     rsi,[site7]
    236: mov     edx,0FFFFFF28h
    23b: call    ryo_h_CallExt
    240: test    rax,rax
    243: je      250h
    245: call    rax
    247: nop     [rcx-48h]
    24e: jmp     260h
    250: mov     rdi,rbp
    253: lea     rsi,[ro+4]
    25a: call    qword ptr [sym8]
    260: call    ryo_h_Unreachable
    265: ud2
    267: nop     [rax+rax]
    270: mov     edi,0FFFFFFA0h
    275: call    ryo_h_Resume
    27a: ud2
    27c: nop     [rax]
    280: jmp     270h
    282: nop     [rax+rax]
    28b: nop     [rax+rax]
    290: test    byte ptr [rbp-49h],0FFh
    294: je      270h
    296: jmp     280h
    298: call    ryo_h_Unreachable
    29d: ud2
    29f: mov     rdi,rax
    2a2: mov     esi,0FFFFFFA0h
    2a7: call    ryo_h_Lpad
    2ac: jmp     290h

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-10h],rax
     14: mov     rax,[rbp+10h]
     18: mov     rax,[rax+8]
     1c: mov     [rbp-18h],rax
     20: mov     rax,[rbp-10h]
     24: imul    rcx,[rbp-18h],8
     29: add     rax,rcx
     2c: mov     [rbp-8],rax
     30: mov     rcx,[rbp+18h]
     34: mov     [rax],rcx
     37: mov     rax,[rbp+10h]
     3b: mov     rax,[rax+8]
     3f: mov     [rbp-20h],rax
     43: add     rax,1
     47: mov     [rbp-30h],rax
     4b: mov     rax,[rbp+10h]
     4f: mov     rcx,[rbp-30h]
     53: mov     [rax+8],rcx
     57: xor     edi,edi
     59: xor     esi,esi
     5b: call    ryo_h_Ret
     60: leave
     61: ret

fn std::vec::Vec::<(u32, u32)>::reserve
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+10h]
     13: mov     [rbp-18h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-20h],rax
     1f: mov     edi,0FFFFFFD0h
     24: lea     rsi,[k0]
     2b: mov     edx,10h
     30: call    ryo_h_Const
     35: mov     rax,[rbp-28h]
     39: mov     [rbp-50h],rax
     3d: cmp     rax,0
     41: je      0EFh
     47: jmp     0F9h
     4c: nop     [rax]
     50: mov     rax,[rbp-20h]
     54: mov     [rbp-90h],rax
     5b: mov     rax,[rbp-18h]
     5f: mov     [rbp-88h],rax
     66: mov     rax,[rbp+18h]
     6a: mov     [rbp-80h],rax
     6e: mov     edi,0FFFFFF88h
     73: mov     esi,0FFFFFFD0h
     78: call    ryo_h_MovW128
     7d: lea     rdi,[sym1]
     84: lea     rsi,[site2]
     8b: mov     edx,0FFFFFFA0h
     90: call    ryo_h_CallExt
     95: test    rax,rax
     98: je      0A5h
     9a: call    rax
     9c: nop     [rcx-8]
     a3: jmp     0B5h
     a5: mov     rdi,rbp
     a8: lea     rsi,[ro+4]
     af: call    qword ptr [sym3]
     b5: nop     [rax+rax]
     be: xchg    ax,ax
     c0: xor     edi,edi
     c2: xor     esi,esi
     c4: call    ryo_h_Ret
     c9: leave
     ca: ret
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp-48h]
     d4: sub     rax,[rbp-18h]
     d8: mov     [rbp-40h],rax
     dc: cmp     rax,[rbp+18h]
     e0: setb    [rbp-31h]
     e4: test    byte ptr [rbp-31h],0FFh
     e8: je      0C0h
     ea: jmp     50h
     ef: mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
     f7: jmp     0D0h
     f9: mov     rax,[rbp-20h]
     fd: mov     rax,[rax]
    100: mov     [rbp-58h],rax
    104: mov     [rbp-48h],rax
    108: jmp     0D0h

fn std::vec::Vec::<T, A>::set_len::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jb      20h
     15: xor     edi,edi
     17: xor     esi,esi
     19: call    ryo_h_Ret
     1e: leave
     1f: ret
     20: mov     edi,0FFFFFFF0h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: mov     qword ptr [rbp-8],0C6h
     39: mov     rax,[rbp-10h]
     3d: mov     [rbp-48h],rax
     41: mov     rax,[rbp-8]
     45: mov     [rbp-40h],rax
     49: mov     rax,[rbp-48h]
     4d: mov     [rbp-38h],rax
     51: mov     [rbp-30h],rax
     55: mov     edi,0FFFFFFA0h
     5a: lea     rsi,[k1]
     61: call    ryo_h_AddrAbs
     66: mov     qword ptr [rbp-58h],0C6h
     6e: mov     rax,[rbp-58h]
     72: mov     [rbp-50h],rax
     76: shl     rax,1
     7a: mov     [rbp-48h],rax
     7e: or      rax,1
     82: mov     [rbp-40h],rax
     86: mov     [rbp-38h],rax
     8a: mov     rax,[rbp-30h]
     8e: mov     [rbp-28h],rax
     92: mov     rax,[rbp-38h]
     96: mov     [rbp-20h],rax
     9a: mov     edi,0FFFFFF70h
     9f: mov     esi,0FFFFFFD8h
     a4: call    ryo_h_MovW128
     a9: mov     byte ptr [rbp-80h],0
     ad: mov     rax,[rbp+20h]
     b1: mov     [rbp-78h],rax
     b5: lea     rdi,[sym2]
     bc: lea     rsi,[site3]
     c3: mov     edx,0FFFFFF98h
     c8: call    ryo_h_CallExt
     cd: test    rax,rax
     d0: je      0DDh
     d2: call    rax
     d4: nop     [rcx-10h]
     db: jmp     0EDh
     dd: mov     rdi,rbp
     e0: lea     rsi,[ro+4]
     e7: call    qword ptr [sym4]
     ed: call    ryo_h_Unreachable
     f2: ud2

fn std::vec::Vec::<u32>::append_elements
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+10h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp-8]
     1f: mov     [rbp-78h],rax
     23: call    fn0
     28: nop     [rcx]
     2f: mov     rax,[rbp+10h]
     33: mov     rax,[rax+10h]
     37: mov     [rbp-10h],rax
     3b: mov     rcx,1FFFFFFFFFFFFFFFh
     45: cmp     rax,rcx
     48: setbe   [rbp-11h]
     4c: cmp     qword ptr [rbp-8],0
     51: jbe     90h
     53: mov     rax,[rbp+18h]
     57: mov     [rbp-20h],rax
     5b: mov     rax,[rbp+10h]
     5f: mov     rax,[rax+8]
     63: mov     [rbp-38h],rax
     67: mov     [rbp-30h],rax
     6b: imul    rcx,[rbp-10h],4
     70: add     rax,rcx
     73: mov     [rbp-28h],rax
     77: mov     byte ptr [rbp-39h],1
     7b: test    byte ptr [rbp-39h],0FFh
     7f: je      110h
     85: jmp     0BBh
     87: nop     [rax+rax]
     90: mov     rax,[rbp+10h]
     94: mov     rax,[rax+10h]
     98: mov     [rbp-40h],rax
     9c: add     rax,[rbp-8]
     a0: mov     [rbp-50h],rax
     a4: mov     rax,[rbp+10h]
     a8: mov     rcx,[rbp-50h]
     ac: mov     [rax+10h],rcx
     b0: xor     edi,edi
     b2: xor     esi,esi
     b4: call    ryo_h_Ret
     b9: leave
     ba: ret
     bb: mov     rax,[rbp+18h]
     bf: mov     [rbp-30h],rax
     c3: mov     rax,[rbp-28h]
     c7: mov     [rbp-38h],rax
     cb: mov     rax,[rbp-30h]
     cf: mov     [rbp-80h],rax
     d3: mov     rax,[rbp-38h]
     d7: mov     [rbp-78h],rax
     db: mov     qword ptr [rbp-70h],4
     e3: mov     qword ptr [rbp-68h],4
     eb: mov     rax,[rbp-8]
     ef: mov     [rbp-60h],rax
     f3: mov     edi,0FFFFFFA8h
     f8: lea     rsi,[k1]
     ff: call    ryo_h_AddrAbs
    104: call    fn2
    109: nop     [rcx-8]
    110: imul    rax,[rbp-8],4
    115: mov     [rbp-40h],rax
    119: mov     edi,0FFFFFFD8h
    11e: mov     esi,0FFFFFFE0h
    123: mov     edx,0FFFFFFC0h
    128: call    ryo_h_Memcpy
    12d: jmp     90h

fn std::vec::Vec::<u32>::clear
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-20h],rax
     24: mov     rax,[rbp-18h]
     28: mov     [rbp-10h],rax
     2c: mov     rax,[rbp-20h]
     30: mov     [rbp-8],rax
     34: mov     qword ptr [rbp-30h],0
     3c: mov     rax,[rbp+10h]
     40: mov     rcx,[rbp-30h]
     44: mov     [rax+10h],rcx
     48: mov     rax,[rbp-10h]
     4c: mov     [rbp-20h],rax
     50: mov     rax,[rbp-8]
     54: mov     [rbp-18h],rax
     58: mov     edi,0FFFFFFC0h
     5d: mov     esi,0FFFFFFE0h
     62: call    ryo_h_MovW128
     67: mov     edi,0FFFFFFD8h
     6c: lea     rsi,[sym0]
     73: call    ryo_h_AddrSym
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym1]
     88: xor     edi,edi
     8a: xor     esi,esi
     8c: call    ryo_h_Ret
     91: leave
     92: ret

fn std::vec::Vec::<u32>::extend_from_slice
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-48h],rax
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-40h],rax
     20: mov     edi,0FFFFFFD0h
     25: mov     esi,0FFFFFFB8h
     2a: call    ryo_h_MovW128
     2f: mov     edi,0FFFFFFB0h
     34: mov     esi,0FFFFFFD0h
     39: call    ryo_h_MovW128
     3e: mov     rax,[rbp-50h]
     42: mov     [rbp-40h],rax
     46: mov     [rbp-20h],rax
     4a: mov     byte ptr [rbp-51h],0
     4e: test    byte ptr [rbp-51h],0FFh
     52: je      75h
     54: jmp     6Bh
     56: nop     [rax+rax]
     5f: nop
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: mov     rax,[rbp-18h]
     6f: mov     [rbp-38h],rax
     73: jmp     8Dh
     75: mov     rax,[rbp-20h]
     79: mov     [rbp-30h],rax
     7d: imul    rcx,[rbp-18h],4
     82: add     rax,rcx
     85: mov     [rbp-28h],rax
     89: mov     [rbp-38h],rax
     8d: mov     rax,[rbp-20h]
     91: mov     [rbp-10h],rax
     95: mov     rax,[rbp-38h]
     99: mov     [rbp-8],rax
     9d: mov     rax,[rbp+10h]
     a1: mov     [rbp-70h],rax
     a5: mov     edi,0FFFFFF98h
     aa: mov     esi,0FFFFFFF0h
     af: call    ryo_h_MovW128
     b4: call    fn0
     b9: nop     [rcx]
     c0: jmp     60h

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     byte ptr [rbp-49h],1
      f: lea     rax,[rbp+18h]
     13: mov     [rbp-68h],rax
     17: mov     [rbp-110h],rax
     1e: call    fn0
     23: nop     [rcx-90h]
     2a: mov     rax,[rbp-90h]
     31: mov     [rbp-68h],rax
     35: mov     edi,0FFFFFF88h
     3a: mov     esi,0FFFFFF78h
     3f: call    ryo_h_MovW128
     44: mov     rax,[rbp-78h]
     48: mov     [rbp-8],rax
     4c: mov     edi,0FFFFFFF8h
     51: xor     esi,esi
     53: mov     edx,2
     58: call    ryo_h_SwitchDenseW64
     5d: lea     rcx,[70h]
     64: movsxd  rax,[rcx+rax*4]
     68: add     rax,rcx
     6b: jmp     rax
     6d: int3
     6e: int3
     6f: int3
     70: .long   165h
     74: .long   7ch
     78: .long   2a8h
     7c: mov     rax,[rbp-70h]
     80: mov     [rbp-80h],rax
     84: mov     rax,[rbp+10h]
     88: mov     [rbp-110h],rax
     8f: mov     rax,[rbp-80h]
     93: mov     [rbp-108h],rax
     9a: call    fn1
     9f: nop     [rcx-48h]
     a6: mov     rax,[rbp+10h]
     aa: mov     rax,[rax+8]
     ae: mov     [rbp-90h],rax
     b5: mov     [rbp-88h],rax
     bc: mov     rax,[rbp+10h]
     c0: lea     rax,[rax+10h]
     c4: mov     [rbp-0A0h],rax
     cb: mov     rax,[rax]
     ce: mov     [rbp-0A8h],rax
     d5: mov     rax,[rbp-0A0h]
     dc: mov     [rbp-98h],rax
     e3: mov     rax,[rbp-0A8h]
     ea: mov     [rbp-90h],rax
     f1: mov     byte ptr [rbp-49h],0
     f5: mov     edi,0FFFFFF50h
     fa: mov     esi,18h
     ff: mov     edx,18h
    104: call    ryo_h_Copy
    109: mov     rax,[rbp-88h]
    110: mov     [rbp-0B8h],rax
    117: mov     edi,0FFFFFF38h
    11c: mov     esi,0FFFFFF68h
    121: call    ryo_h_MovW128
    126: mov     edi,0FFFFFEF0h
    12b: mov     esi,0FFFFFF50h
    130: mov     edx,18h
    135: call    ryo_h_Copy
    13a: mov     edi,0FFFFFF08h
    13f: mov     esi,0FFFFFF38h
    144: mov     edx,18h
    149: call    ryo_h_Copy
    14e: call    fn2
    153: nop     [rcx-48h]
    15a: xor     edi,edi
    15c: xor     esi,esi
    15e: call    ryo_h_Ret
    163: leave
    164: ret
    165: mov     edi,0FFFFFF68h
    16a: lea     rsi,[k3]
    171: call    ryo_h_AddrAbs
    176: mov     qword ptr [rbp-90h],11h
    181: mov     rax,[rbp-98h]
    188: mov     [rbp-0B8h],rax
    18f: mov     rax,[rbp-90h]
    196: mov     [rbp-0B0h],rax
    19d: mov     rax,[rbp-0B8h]
    1a4: mov     [rbp-0A8h],rax
    1ab: mov     [rbp-0A0h],rax
    1b2: mov     edi,0FFFFFF30h
    1b7: lea     rsi,[k4]
    1be: call    ryo_h_AddrAbs
    1c3: mov     qword ptr [rbp-0C8h],11h
    1ce: mov     rax,[rbp-0C8h]
    1d5: mov     [rbp-0C0h],rax
    1dc: shl     rax,1
    1e0: mov     [rbp-0B8h],rax
    1e7: or      rax,1
    1eb: mov     [rbp-0B0h],rax
    1f2: mov     [rbp-0A8h],rax
    1f9: mov     rax,[rbp-0A0h]
    200: mov     [rbp-88h],rax
    207: mov     rax,[rbp-0A8h]
    20e: mov     [rbp-80h],rax
    212: mov     edi,0FFFFFEF0h
    217: mov     esi,0FFFFFF78h
    21c: call    ryo_h_MovW128
    221: mov     edi,0FFFFFF00h
    226: lea     rsi,[k5]
    22d: call    ryo_h_AddrAbs
    232: lea     rdi,[sym6]
    239: lea     rsi,[site7]
    240: mov     edx,0FFFFFF28h
    245: call    ryo_h_CallExt
    24a: test    rax,rax
    24d: je      25Ah
    24f: call    rax
    251: nop     [rcx-48h]
    258: jmp     26Ah
    25a: mov     rdi,rbp
    25d: lea     rsi,[ro+4]
    264: call    qword ptr [sym8]
    26a: call    ryo_h_Unreachable
    26f: ud2
    271: nop     [rax+rax]
    27a: nop     [rax+rax]
    280: mov     edi,0FFFFFFA0h
    285: call    ryo_h_Resume
    28a: ud2
    28c: nop     [rax]
    290: jmp     280h
    292: nop     [rax+rax]
    29b: nop     [rax+rax]
    2a0: test    byte ptr [rbp-49h],0FFh
    2a4: je      280h
    2a6: jmp     290h
    2a8: call    ryo_h_Unreachable
    2ad: ud2
    2af: mov     rdi,rax
    2b2: mov     esi,0FFFFFFA0h
    2b7: call    ryo_h_Lpad
    2bc: jmp     2A0h

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-10h],rax
     14: mov     rax,[rbp+10h]
     18: mov     rax,[rax+8]
     1c: mov     [rbp-18h],rax
     20: mov     rax,[rbp-10h]
     24: imul    rcx,[rbp-18h],4
     29: add     rax,rcx
     2c: mov     [rbp-8],rax
     30: mov     ecx,[rbp+18h]
     33: mov     [rax],ecx
     35: mov     rax,[rbp+10h]
     39: mov     rax,[rax+8]
     3d: mov     [rbp-20h],rax
     41: add     rax,1
     45: mov     [rbp-30h],rax
     49: mov     rax,[rbp+10h]
     4d: mov     rcx,[rbp-30h]
     51: mov     [rax+8],rcx
     55: xor     edi,edi
     57: xor     esi,esi
     59: call    ryo_h_Ret
     5e: leave
     5f: ret

fn std::vec::Vec::<u32>::push
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     eax,[rbp+18h]
     13: mov     [rbp-18h],eax
     16: call    fn0
     1b: nop     [rcx-8]
     22: xor     edi,edi
     24: xor     esi,esi
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn std::vec::Vec::<u32>::push_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-30h],rax
     14: mov     qword ptr [rbp-50h],4
     1c: cmp     qword ptr [rbp-50h],0
     21: je      0E3h
     27: jmp     0EDh
     2c: nop     [rax]
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-40h],rax
     38: mov     [rbp-60h],rax
     3c: call    fn0
     41: nop     [rcx-10h]
     48: jmp     50h
     4a: nop     [rax+rax]
     50: mov     rax,[rbp+10h]
     54: mov     rax,[rax+8]
     58: mov     [rbp-40h],rax
     5c: mov     [rbp-38h],rax
     60: imul    rcx,[rbp-30h],4
     65: add     rax,rcx
     68: mov     [rbp-18h],rax
     6c: mov     eax,[rbp+18h]
     6f: mov     [rbp-34h],eax
     72: mov     rax,[rbp-18h]
     76: mov     ecx,[rbp-34h]
     79: mov     [rax],ecx
     7b: mov     rax,[rbp-30h]
     7f: add     rax,1
     83: mov     [rbp-50h],rax
     87: mov     rax,[rbp+10h]
     8b: mov     rcx,[rbp-50h]
     8f: mov     [rax+10h],rcx
     93: mov     rax,[rbp-18h]
     97: mov     [rbp-8],rax
     9b: mov     edi,0FFFFFFF8h
     a0: mov     esi,8
     a5: call    ryo_h_Ret
     aa: leave
     ab: ret
     ac: nop     [rax]
     b0: mov     edi,0FFFFFFD8h
     b5: call    ryo_h_Resume
     ba: ud2
     bc: nop     [rax]
     c0: jmp     0B0h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp-30h]
     d4: cmp     rax,[rbp-40h]
     d8: je      30h
     de: jmp     50h
     e3: mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
     eb: jmp     0D0h
     ed: mov     rax,[rbp+10h]
     f1: mov     rax,[rax]
     f4: mov     [rbp-48h],rax
     f8: mov     [rbp-40h],rax
     fc: jmp     0D0h
     fe: mov     rdi,rax
    101: mov     esi,0FFFFFFD8h
    106: call    ryo_h_Lpad
    10b: jmp     0C0h

fn std::vec::Vec::<u32>::reserve
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+10h]
     13: mov     [rbp-18h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-20h],rax
     1f: mov     edi,0FFFFFFD0h
     24: lea     rsi,[k0]
     2b: mov     edx,10h
     30: call    ryo_h_Const
     35: mov     rax,[rbp-28h]
     39: mov     [rbp-50h],rax
     3d: cmp     rax,0
     41: je      0EFh
     47: jmp     0F9h
     4c: nop     [rax]
     50: mov     rax,[rbp-20h]
     54: mov     [rbp-90h],rax
     5b: mov     rax,[rbp-18h]
     5f: mov     [rbp-88h],rax
     66: mov     rax,[rbp+18h]
     6a: mov     [rbp-80h],rax
     6e: mov     edi,0FFFFFF88h
     73: mov     esi,0FFFFFFD0h
     78: call    ryo_h_MovW128
     7d: lea     rdi,[sym1]
     84: lea     rsi,[site2]
     8b: mov     edx,0FFFFFFA0h
     90: call    ryo_h_CallExt
     95: test    rax,rax
     98: je      0A5h
     9a: call    rax
     9c: nop     [rcx-8]
     a3: jmp     0B5h
     a5: mov     rdi,rbp
     a8: lea     rsi,[ro+4]
     af: call    qword ptr [sym3]
     b5: nop     [rax+rax]
     be: xchg    ax,ax
     c0: xor     edi,edi
     c2: xor     esi,esi
     c4: call    ryo_h_Ret
     c9: leave
     ca: ret
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp-48h]
     d4: sub     rax,[rbp-18h]
     d8: mov     [rbp-40h],rax
     dc: cmp     rax,[rbp+18h]
     e0: setb    [rbp-31h]
     e4: test    byte ptr [rbp-31h],0FFh
     e8: je      0C0h
     ea: jmp     50h
     ef: mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
     f7: jmp     0D0h
     f9: mov     rax,[rbp-20h]
     fd: mov     rax,[rax]
    100: mov     [rbp-58h],rax
    104: mov     [rbp-48h],rax
    108: jmp     0D0h

fn std::vec::Vec::<u32>::with_capacity
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-50h],rax
     10: mov     edi,0FFFFFFB8h
     15: lea     rsi,[k0]
     1c: mov     edx,10h
     21: call    ryo_h_Const
     26: call    fn1
     2b: nop     [rcx-38h]
     32: mov     edi,0FFFFFFD8h
     37: mov     esi,0FFFFFFC8h
     3c: call    ryo_h_MovW128
     41: mov     edi,0FFFFFFE8h
     46: mov     esi,0FFFFFFD8h
     4b: call    ryo_h_MovW128
     50: mov     qword ptr [rbp-8],0
     58: mov     edi,0FFFFFFE8h
     5d: mov     esi,18h
     62: call    ryo_h_Ret
     67: leave
     68: ret

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u32>>::eq
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-48h],rax
     17: mov     [rbp-40h],rax
     1b: mov     rax,[rbp+10h]
     1f: mov     rax,[rax+10h]
     23: mov     [rbp-20h],rax
     27: mov     rax,[rbp-40h]
     2b: mov     [rbp-18h],rax
     2f: mov     rax,[rbp-20h]
     33: mov     [rbp-10h],rax
     37: mov     rax,[rbp+18h]
     3b: mov     rax,[rax+8]
     3f: mov     [rbp-48h],rax
     43: mov     [rbp-40h],rax
     47: mov     rax,[rbp+18h]
     4b: mov     rax,[rax+10h]
     4f: mov     [rbp-38h],rax
     53: mov     rax,[rbp-40h]
     57: mov     [rbp-30h],rax
     5b: mov     rax,[rbp-38h]
     5f: mov     [rbp-28h],rax
     63: mov     rax,[rbp-20h]
     67: cmp     rax,[rbp-38h]
     6b: jne     0C3h
     6d: mov     rax,[rbp-18h]
     71: mov     [rbp-58h],rax
     75: mov     rax,[rbp-10h]
     79: mov     [rbp-50h],rax
     7d: mov     rax,[rbp-58h]
     81: mov     [rbp-48h],rax
     85: mov     rax,[rbp-30h]
     89: mov     [rbp-60h],rax
     8d: mov     rax,[rbp-28h]
     91: mov     [rbp-58h],rax
     95: mov     rax,[rbp-60h]
     99: mov     [rbp-50h],rax
     9d: mov     rax,[rbp-48h]
     a1: mov     [rbp-80h],rax
     a5: mov     rax,[rbp-50h]
     a9: mov     [rbp-78h],rax
     ad: mov     rax,[rbp-20h]
     b1: mov     [rbp-70h],rax
     b5: call    fn0
     ba: nop     [rcx-1]
     c1: jmp     0C7h
     c3: mov     byte ptr [rbp-1],0
     c7: mov     edi,0FFFFFFFFh
     cc: mov     esi,1
     d1: call    ryo_h_Ret
     d6: leave
     d7: ret

