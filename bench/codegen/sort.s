fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp-10h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx-1]
     2f: mov     edi,0FFFFFFFFh
     34: mov     esi,1
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn <&u32 as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp-10h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx-1]
     2f: mov     edi,0FFFFFFFFh
     34: mov     esi,1
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

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
     88: mov     rax,[rbp-58h]
     8c: mov     [rbp-50h],rax
     90: mov     edi,0FFFFFFB8h
     95: lea     rsi,[k4]
     9c: call    ryo_h_AddrAbs
     a1: mov     rax,[rbp-40h]
     a5: mov     [rbp-80h],rax
     a9: mov     edi,0FFFFFF88h
     ae: mov     esi,0FFFFFFB0h
     b3: call    ryo_h_MovW128
     b8: lea     rdi,[sym5]
     bf: lea     rsi,[site6]
     c6: mov     edx,0FFFFFFA0h
     cb: call    ryo_h_CallExt
     d0: test    rax,rax
     d3: je      0E0h
     d5: call    rax
     d7: nop     [rcx-38h]
     de: jmp     0F0h
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+20]
     ea: call    qword ptr [sym7]
     f0: lea     rax,[rbp-20h]
     f4: mov     [rbp-40h],rax
     f8: lea     rax,[rbp-30h]
     fc: mov     [rbp-58h],rax
    100: mov     rax,[rbp-58h]
    104: mov     [rbp-50h],rax
    108: mov     edi,0FFFFFFB8h
    10d: lea     rsi,[k8]
    114: call    ryo_h_AddrAbs
    119: mov     rax,[rbp-40h]
    11d: mov     [rbp-80h],rax
    121: mov     edi,0FFFFFF88h
    126: mov     esi,0FFFFFFB0h
    12b: call    ryo_h_MovW128
    130: lea     rdi,[sym9]
    137: lea     rsi,[site10]
    13e: mov     edx,0FFFFFFA0h
    143: call    ryo_h_CallExt
    148: test    rax,rax
    14b: je      158h
    14d: call    rax
    14f: nop     [rcx-38h]
    156: jmp     168h
    158: mov     rdi,rbp
    15b: lea     rsi,[ro+20]
    162: call    qword ptr [sym11]
    168: lea     rax,[rbp-20h]
    16c: mov     [rbp-38h],rax
    170: mov     rax,[rbp-38h]
    174: mov     [rbp-80h],rax
    178: lea     rdi,[sym12]
    17f: lea     rsi,[site13]
    186: mov     edx,0FFFFFFA0h
    18b: call    ryo_h_CallExt
    190: test    rax,rax
    193: je      1A0h
    195: call    rax
    197: nop     [rcx-1]
    19e: jmp     1B0h
    1a0: mov     rdi,rbp
    1a3: lea     rsi,[ro+36]
    1aa: call    qword ptr [sym14]
    1b0: mov     edi,0FFFFFFFFh
    1b5: mov     esi,1
    1ba: call    ryo_h_Ret
    1bf: leave
    1c0: ret

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
     94: mov     rax,[rbp-68h]
     98: mov     [rbp-48h],rax
     9c: mov     byte ptr [rbp-79h],0
     a0: test    byte ptr [rbp-79h],0FFh
     a4: je      10Eh
     a6: jmp     104h
     a8: nop     [rax+rax]
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
    10c: jmp     12Eh
    10e: mov     rax,[rbp-48h]
    112: mov     [rbp-58h],rax
    116: mov     rax,[rbp-58h]
    11a: imul    rcx,[rbp-40h],4
    11f: add     rax,rcx
    122: mov     [rbp-50h],rax
    126: mov     rax,[rbp-50h]
    12a: mov     [rbp-60h],rax
    12e: mov     rax,[rbp-48h]
    132: mov     [rbp-38h],rax
    136: mov     rax,[rbp-60h]
    13a: mov     [rbp-30h],rax
    13e: mov     rax,[rbp-18h]
    142: mov     [rbp-0A0h],rax
    149: mov     edi,0FFFFFF68h
    14e: mov     esi,0FFFFFFC8h
    153: call    ryo_h_MovW128
    158: call    fn6
    15d: nop     [rcx-10h]
    164: jmp     0B0h

fn <alloc::raw_vec::RawVec<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFD8h
     1d: lea     rsi,[k0]
     24: mov     edx,10h
     29: call    ryo_h_Const
     2e: lea     rdi,[sym1]
     35: lea     rsi,[site2]
     3c: mov     edx,0FFFFFFF0h
     41: call    ryo_h_CallExt
     46: test    rax,rax
     49: je      56h
     4b: call    rax
     4d: nop     [rcx]
     54: jmp     66h
     56: mov     rdi,rbp
     59: lea     rsi,[ro+4]
     60: call    qword ptr [sym3]
     66: xor     edi,edi
     68: xor     esi,esi
     6a: call    ryo_h_Ret
     6f: leave
     70: ret

fn <alloc::raw_vec::RawVec<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFD8h
     1d: lea     rsi,[k0]
     24: mov     edx,10h
     29: call    ryo_h_Const
     2e: lea     rdi,[sym1]
     35: lea     rsi,[site2]
     3c: mov     edx,0FFFFFFF0h
     41: call    ryo_h_CallExt
     46: test    rax,rax
     49: je      56h
     4b: call    rax
     4d: nop     [rcx]
     54: jmp     66h
     56: mov     rdi,rbp
     59: lea     rsi,[ro+4]
     60: call    qword ptr [sym3]
     66: xor     edi,edi
     68: xor     esi,esi
     6a: call    ryo_h_Ret
     6f: leave
     70: ret

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
     22: mov     rax,[rbp-8]
     26: mov     [rbp-28h],rax
     2a: mov     rax,[rbp-20h]
     2e: mov     [rbp-30h],rax
     32: mov     byte ptr [rbp-41h],1
     36: test    byte ptr [rbp-41h],0FFh
     3a: je      0AFh
     3c: jmp     72h
     3e: xchg    ax,ax
     40: mov     rax,[rbp+10h]
     44: mov     rax,[rax]
     47: mov     [rbp-10h],rax
     4b: mov     rax,[rbp-10h]
     4f: mov     [rbp-20h],rax
     53: mov     rax,[rbp+10h]
     57: mov     rax,[rax+10h]
     5b: mov     [rbp-28h],rax
     5f: mov     byte ptr [rbp-41h],1
     63: test    byte ptr [rbp-41h],0FFh
     67: je      1D4h
     6d: jmp     17Fh
     72: mov     rax,[rbp-20h]
     76: mov     [rbp-38h],rax
     7a: mov     rax,[rbp-8]
     7e: mov     [rbp-40h],rax
     82: mov     rax,[rbp-38h]
     86: mov     [rbp-80h],rax
     8a: mov     rax,[rbp-40h]
     8e: mov     [rbp-78h],rax
     92: mov     edi,0FFFFFF90h
     97: lea     rsi,[k0]
     9e: call    ryo_h_AddrAbs
     a3: call    fn1
     a8: nop     [rcx-10h]
     af: mov     qword ptr [rbp-48h],0
     b7: cmp     qword ptr [rbp-48h],8
     bc: setb    [rbp-31h]
     c0: test    byte ptr [rbp-31h],0FFh
     c4: je      116h
     c6: mov     qword ptr [rbp-48h],8
     ce: mov     rax,[rbp-48h]
     d2: mov     rcx,7FFFFFFFFFFFFFFFh
     dc: cmp     rax,rcx
     df: setbe   [rbp-32h]
     e3: test    byte ptr [rbp-32h],0FFh
     e7: je      116h
     e9: mov     rax,[rbp-30h]
     ed: sub     rax,[rbp-28h]
     f1: mov     [rbp-18h],rax
     f5: mov     qword ptr [rbp-48h],8
     fd: mov     edi,0FFFFFFE8h
    102: mov     esi,0FFFFFFE8h
    107: mov     edx,0FFFFFFB8h
    10c: call    ryo_h_DivUW64
    111: jmp     40h
    116: mov     edi,0FFFFFF80h
    11b: lea     rsi,[k2]
    122: call    ryo_h_AddrAbs
    127: mov     qword ptr [rbp-78h],49h
    12f: mov     edi,0FFFFFF90h
    134: lea     rsi,[k3]
    13b: call    ryo_h_AddrAbs
    140: lea     rdi,[sym4]
    147: lea     rsi,[site5]
    14e: mov     edx,0FFFFFFB8h
    153: call    ryo_h_CallExt
    158: test    rax,rax
    15b: je      168h
    15d: call    rax
    15f: nop     [rcx-10h]
    166: jmp     178h
    168: mov     rdi,rbp
    16b: lea     rsi,[ro+4]
    172: call    qword ptr [sym6]
    178: call    ryo_h_Unreachable
    17d: ud2
    17f: mov     rax,[rbp-10h]
    183: mov     [rbp-30h],rax
    187: mov     rax,[rbp-28h]
    18b: mov     [rbp-38h],rax
    18f: mov     rax,[rbp-30h]
    193: mov     [rbp-80h],rax
    197: mov     rax,[rbp-38h]
    19b: mov     [rbp-78h],rax
    19f: mov     qword ptr [rbp-70h],8
    1a7: mov     qword ptr [rbp-68h],4
    1af: mov     rax,[rbp-18h]
    1b3: mov     [rbp-60h],rax
    1b7: mov     edi,0FFFFFFA8h
    1bc: lea     rsi,[k7]
    1c3: call    ryo_h_AddrAbs
    1c8: call    fn8
    1cd: nop     [rcx-10h]
    1d4: imul    rax,[rbp-18h],8
    1d9: mov     [rbp-48h],rax
    1dd: mov     edi,0FFFFFFD8h
    1e2: mov     esi,0FFFFFFE0h
    1e7: mov     edx,0FFFFFFB8h
    1ec: call    ryo_h_Memcpy
    1f1: xor     edi,edi
    1f3: xor     esi,esi
    1f5: call    ryo_h_Ret
    1fa: leave
    1fb: ret

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     rax,[rbp-8]
     18: mov     [rbp-10h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax]
     23: mov     [rbp-18h],rax
     27: mov     byte ptr [rbp-29h],1
     2b: test    byte ptr [rbp-29h],0FFh
     2f: je      86h
     31: mov     rax,[rbp-8]
     35: mov     [rbp-20h],rax
     39: mov     rax,[rbp-18h]
     3d: mov     [rbp-28h],rax
     41: mov     rax,[rbp-20h]
     45: mov     [rbp-70h],rax
     49: mov     rax,[rbp-28h]
     4d: mov     [rbp-68h],rax
     51: mov     qword ptr [rbp-60h],4
     59: mov     qword ptr [rbp-58h],4
     61: mov     qword ptr [rbp-50h],1
     69: mov     edi,0FFFFFFB8h
     6e: lea     rsi,[k0]
     75: call    ryo_h_AddrAbs
     7a: call    fn1
     7f: nop     [rcx-8]
     86: mov     qword ptr [rbp-30h],1
     8e: imul    rax,[rbp-30h],4
     93: mov     [rbp-38h],rax
     97: mov     edi,0FFFFFFE8h
     9c: mov     esi,0FFFFFFF0h
     a1: mov     edx,0FFFFFFC8h
     a6: call    ryo_h_Memcpy
     ab: xor     edi,edi
     ad: xor     esi,esi
     af: call    ryo_h_Ret
     b4: leave
     b5: ret

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
     1a: mov     rax,[rbp-20h]
     1e: mov     [rbp-30h],rax
     22: mov     edi,0FFFFFFD8h
     27: lea     rsi,[sym0]
     2e: call    ryo_h_AddrSym
     33: mov     rdi,rbp
     36: lea     rsi,[ro+4]
     3d: call    qword ptr [sym1]
     43: jmp     5Bh
     45: nop     [rax+rax]
     4e: xchg    ax,ax
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
     13: mov     rax,[rbp-8]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-20h],rax
     23: mov     edi,0FFFFFFE8h
     28: lea     rsi,[sym0]
     2f: call    ryo_h_AddrSym
     34: mov     rdi,rbp
     37: lea     rsi,[ro+4]
     3e: call    qword ptr [sym1]
     44: xor     edi,edi
     46: xor     esi,esi
     48: call    ryo_h_Ret
     4d: leave
     4e: ret

fn <std::hint::select_unpredictable::DropOnPanic<*const u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp-8]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-20h],rax
     23: mov     edi,0FFFFFFE8h
     28: lea     rsi,[sym0]
     2f: call    ryo_h_AddrSym
     34: mov     rdi,rbp
     37: lea     rsi,[ro+4]
     3e: call    qword ptr [sym1]
     44: xor     edi,edi
     46: xor     esi,esi
     48: call    ryo_h_Ret
     4d: leave
     4e: ret

fn <std::hint::select_unpredictable::DropOnPanic<*mut u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp-8]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-20h],rax
     23: mov     edi,0FFFFFFE8h
     28: lea     rsi,[sym0]
     2f: call    ryo_h_AddrSym
     34: mov     rdi,rbp
     37: lea     rsi,[ro+4]
     3e: call    qword ptr [sym1]
     44: xor     edi,edi
     46: xor     esi,esi
     48: call    ryo_h_Ret
     4d: leave
     4e: ret

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
     22: mov     rax,[rbp-60h]
     26: mov     [rbp-58h],rax
     2a: mov     rax,[rbp+20h]
     2e: mov     [rbp-50h],rax
     32: mov     rax,[rbp+18h]
     36: mov     [rbp-48h],rax
     3a: mov     edi,0FFFFFFC0h
     3f: mov     esi,0FFFFFFA8h
     44: call    ryo_h_MovW128
     49: mov     rax,[rbp-30h]
     4d: mov     [rbp-90h],rax
     54: mov     rax,[rbp-48h]
     58: mov     [rbp-88h],rax
     5f: mov     edi,0FFFFFF80h
     64: mov     esi,0FFFFFFC0h
     69: call    ryo_h_MovW128
     6e: call    fn0
     73: nop     [rcx-28h]
     7a: mov     rax,[rbp+10h]
     7e: mov     rax,[rax]
     81: mov     [rbp-68h],rax
     85: mov     qword ptr [rbp-70h],1
     8d: mov     edi,0FFFFFFE8h
     92: mov     esi,0FFFFFFF0h
     97: mov     edx,0FFFFFF98h
     9c: mov     ecx,0FFFFFF90h
     a1: call    ryo_h_AddOvfUW64
     a6: test    byte ptr [rbp-10h],0FFh
     aa: je      0FCh
     ac: mov     edi,0FFFFFF70h
     b1: lea     rsi,[k1]
     b8: call    ryo_h_AddrAbs
     bd: lea     rdi,[sym2]
     c4: lea     rsi,[site3]
     cb: mov     edx,0FFFFFF98h
     d0: call    ryo_h_CallExt
     d5: test    rax,rax
     d8: je      0E5h
     da: call    rax
     dc: nop     [rcx-60h]
     e3: jmp     0F5h
     e5: mov     rdi,rbp
     e8: lea     rsi,[ro+4]
     ef: call    qword ptr [sym4]
     f5: call    ryo_h_Unreachable
     fa: ud2
     fc: mov     rax,[rbp+10h]
    100: mov     rcx,[rbp-18h]
    104: mov     [rax],rcx
    107: mov     rax,[rbp-28h]
    10b: mov     [rbp-8],rax
    10f: mov     edi,0FFFFFFF8h
    114: mov     esi,8
    119: call    ryo_h_Ret
    11e: leave
    11f: ret
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
     1f: mov     rax,[rbp-28h]
     23: mov     [rbp-20h],rax
     27: mov     edi,0FFFFFFB0h
     2c: mov     esi,0FFFFFFE8h
     31: call    ryo_h_MovW128
     36: mov     rax,[rbp+28h]
     3a: mov     [rbp-40h],rax
     3e: mov     rax,[rbp-20h]
     42: mov     [rbp-38h],rax
     46: call    fn0
     4b: nop     [rcx-8]
     52: mov     edi,0FFFFFFF8h
     57: mov     esi,8
     5c: call    ryo_h_Ret
     61: leave
     62: ret

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
     14: mov     rax,[rbp-20h]
     18: mov     [rbp-30h],rax
     1c: call    fn0
     21: nop     [rcx-18h]
     28: mov     edi,0FFFFFFE8h
     2d: mov     esi,18h
     32: call    ryo_h_Ret
     37: leave
     38: ret

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
     10: mov     rax,[rbp-20h]
     14: mov     [rbp-30h],rax
     18: call    fn0
     1d: nop     [rcx-18h]
     24: mov     edi,0FFFFFFE8h
     29: mov     esi,18h
     2e: call    ryo_h_Ret
     33: leave
     34: ret

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
     18: mov     rax,[rbp-30h]
     1c: mov     [rbp-60h],rax
     20: call    fn0
     25: nop     [rcx-28h]
     2c: mov     rax,[rbp-28h]
     30: mov     [rbp-8],rax
     34: mov     edi,0FFFFFFF8h
     39: xor     esi,esi
     3b: mov     edx,2
     40: call    ryo_h_SwitchDenseW64
     45: lea     rcx,[58h]
     4c: movsxd  rax,[rcx+rax*4]
     50: add     rax,rcx
     53: jmp     rax
     55: int3
     56: int3
     57: int3
     58: .long   a5h
     5c: .long   64h
     60: .long   118h
     64: mov     rax,[rbp-20h]
     68: mov     [rbp-30h],rax
     6c: lea     rax,[rbp+20h]
     70: mov     [rbp-38h],rax
     74: mov     byte ptr [rbp-9],0
     78: mov     rax,[rbp-30h]
     7c: mov     [rbp-40h],rax
     80: mov     rax,[rbp-38h]
     84: mov     [rbp-60h],rax
     88: mov     rax,[rbp-40h]
     8c: mov     [rbp-58h],rax
     90: call    fn1
     95: nop     [rcx-8]
     9c: mov     byte ptr [rbp-9],1
     a0: jmp     10h
     a5: lea     rax,[rbp+20h]
     a9: mov     [rbp-48h],rax
     ad: mov     rax,[rbp-48h]
     b1: mov     [rbp-60h],rax
     b5: call    fn2
     ba: nop     [rcx-48h]
     c1: xor     edi,edi
     c3: xor     esi,esi
     c5: call    ryo_h_Ret
     ca: leave
     cb: ret
     cc: nop     [rax]
     d0: lea     rax,[rbp+20h]
     d4: mov     [rbp-48h],rax
     d8: mov     rax,[rbp-48h]
     dc: mov     [rbp-60h],rax
     e0: call    fn3
     e5: nop     [rcx-48h]
     ec: nop     [rax]
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
     3c: je      82h
     3e: mov     rax,[rbp+10h]
     42: mov     rax,[rax]
     45: mov     [rbp-20h],rax
     49: mov     rax,[rbp-20h]
     4d: mov     [rbp-40h],rax
     51: mov     qword ptr [rbp-38h],1
     59: call    fn1
     5e: nop     [rcx-28h]
     65: mov     rax,[rbp+10h]
     69: mov     rcx,[rbp-28h]
     6d: mov     [rax],rcx
     70: mov     rax,[rbp-20h]
     74: mov     [rbp-8],rax
     78: mov     qword ptr [rbp-10h],1
     80: jmp     8Ah
     82: mov     qword ptr [rbp-10h],0
     8a: mov     edi,0FFFFFFF0h
     8f: mov     esi,10h
     94: call    ryo_h_Ret
     99: leave
     9a: ret

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
     5b: mov     rax,[rbp-38h]
     5f: mov     [rbp-30h],rax
     63: mov     edi,0FFFFFFA0h
     68: lea     rsi,[k1]
     6f: call    ryo_h_AddrAbs
     74: mov     qword ptr [rbp-58h],0DAh
     7c: mov     rax,[rbp-58h]
     80: mov     [rbp-50h],rax
     84: mov     rax,[rbp-50h]
     88: shl     rax,1
     8c: mov     [rbp-48h],rax
     90: mov     rax,[rbp-48h]
     94: or      rax,1
     98: mov     [rbp-40h],rax
     9c: mov     rax,[rbp-40h]
     a0: mov     [rbp-38h],rax
     a4: mov     rax,[rbp-30h]
     a8: mov     [rbp-28h],rax
     ac: mov     rax,[rbp-38h]
     b0: mov     [rbp-20h],rax
     b4: mov     edi,0FFFFFF70h
     b9: mov     esi,0FFFFFFD8h
     be: call    ryo_h_MovW128
     c3: mov     byte ptr [rbp-80h],0
     c7: mov     rax,[rbp+28h]
     cb: mov     [rbp-78h],rax
     cf: lea     rdi,[sym2]
     d6: lea     rsi,[site3]
     dd: mov     edx,0FFFFFF98h
     e2: call    ryo_h_CallExt
     e7: test    rax,rax
     ea: je      0F7h
     ec: call    rax
     ee: nop     [rcx-10h]
     f5: jmp     107h
     f7: mov     rdi,rbp
     fa: lea     rsi,[ro+4]
    101: call    qword ptr [sym4]
    107: call    ryo_h_Unreachable
    10c: ud2

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
     48: mov     rax,[rbp-68h]
     4c: imul    rcx,[rbp-20h],4
     51: add     rax,rcx
     54: mov     [rbp-70h],rax
     58: mov     rax,[rbp-70h]
     5c: mov     [rbp-50h],rax
     60: mov     rax,[rbp-38h]
     64: mov     [rbp-48h],rax
     68: mov     rax,[rbp-50h]
     6c: mov     [rbp-10h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-8],rax
     78: mov     edi,0FFFFFFF0h
     7d: mov     esi,10h
     82: call    ryo_h_Ret
     87: leave
     88: ret
     89: nop     [rax]
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
    111: mov     rax,[rbp-40h]
    115: mov     [rbp-28h],rax
    119: mov     qword ptr [rbp-30h],1
    121: mov     rax,[rbp-28h]
    125: mov     [rbp-38h],rax
    129: mov     rax,[rbp+18h]
    12d: mov     [rbp-48h],rax
    131: mov     rax,[rbp-48h]
    135: cmp     rax,[rbp-18h]
    139: jae     30h
    13f: jmp     90h

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
     48: mov     rax,[rbp-68h]
     4c: imul    rcx,[rbp-20h],4
     51: add     rax,rcx
     54: mov     [rbp-70h],rax
     58: mov     rax,[rbp-70h]
     5c: mov     [rbp-50h],rax
     60: mov     rax,[rbp-38h]
     64: mov     [rbp-48h],rax
     68: mov     rax,[rbp-50h]
     6c: mov     [rbp-10h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-8],rax
     78: mov     edi,0FFFFFFF0h
     7d: mov     esi,10h
     82: call    ryo_h_Ret
     87: leave
     88: ret
     89: nop     [rax]
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
    111: mov     rax,[rbp-40h]
    115: mov     [rbp-28h],rax
    119: mov     qword ptr [rbp-30h],1
    121: mov     rax,[rbp-28h]
    125: mov     [rbp-38h],rax
    129: mov     rax,[rbp+18h]
    12d: mov     [rbp-48h],rax
    131: mov     rax,[rbp-48h]
    135: cmp     rax,[rbp-18h]
    139: jae     30h
    13f: jmp     90h

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-20h]
     1f: cmp     rax,[rbp-18h]
     23: jae     84h
     25: mov     rax,[rbp-18h]
     29: mov     [rbp-80h],rax
     2d: mov     rax,[rbp-20h]
     31: mov     [rbp-78h],rax
     35: mov     rax,[rbp-20h]
     39: mov     [rbp-70h],rax
     3d: mov     rax,[rbp+28h]
     41: mov     [rbp-68h],rax
     45: lea     rdi,[sym0]
     4c: lea     rsi,[site1]
     53: mov     edx,0FFFFFFA0h
     58: call    ryo_h_CallExt
     5d: test    rax,rax
     60: je      6Dh
     62: call    rax
     64: nop     [rcx-20h]
     6b: jmp     7Dh
     6d: mov     rdi,rbp
     70: lea     rsi,[ro+4]
     77: call    qword ptr [sym2]
     7d: call    ryo_h_Unreachable
     82: ud2
     84: mov     rax,[rbp-20h]
     88: sub     rax,[rbp-18h]
     8c: mov     [rbp-28h],rax
     90: mov     rax,[rbp+10h]
     94: mov     [rbp-48h],rax
     98: mov     rax,[rbp+18h]
     9c: mov     [rbp-40h],rax
     a0: mov     rax,[rbp-48h]
     a4: mov     [rbp-50h],rax
     a8: mov     rax,[rbp-50h]
     ac: imul    rcx,[rbp-18h],4
     b1: add     rax,rcx
     b4: mov     [rbp-58h],rax
     b8: mov     rax,[rbp-58h]
     bc: mov     [rbp-38h],rax
     c0: mov     rax,[rbp-28h]
     c4: mov     [rbp-30h],rax
     c8: mov     rax,[rbp-38h]
     cc: mov     [rbp-10h],rax
     d0: mov     rax,[rbp-30h]
     d4: mov     [rbp-8],rax
     d8: mov     edi,0FFFFFFF0h
     dd: mov     esi,10h
     e2: call    ryo_h_Ret
     e7: leave
     e8: ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-20h]
     1f: cmp     rax,[rbp-18h]
     23: jae     84h
     25: mov     rax,[rbp-18h]
     29: mov     [rbp-80h],rax
     2d: mov     rax,[rbp-20h]
     31: mov     [rbp-78h],rax
     35: mov     rax,[rbp-20h]
     39: mov     [rbp-70h],rax
     3d: mov     rax,[rbp+28h]
     41: mov     [rbp-68h],rax
     45: lea     rdi,[sym0]
     4c: lea     rsi,[site1]
     53: mov     edx,0FFFFFFA0h
     58: call    ryo_h_CallExt
     5d: test    rax,rax
     60: je      6Dh
     62: call    rax
     64: nop     [rcx-20h]
     6b: jmp     7Dh
     6d: mov     rdi,rbp
     70: lea     rsi,[ro+4]
     77: call    qword ptr [sym2]
     7d: call    ryo_h_Unreachable
     82: ud2
     84: mov     rax,[rbp-20h]
     88: sub     rax,[rbp-18h]
     8c: mov     [rbp-28h],rax
     90: mov     rax,[rbp+10h]
     94: mov     [rbp-48h],rax
     98: mov     rax,[rbp+18h]
     9c: mov     [rbp-40h],rax
     a0: mov     rax,[rbp-48h]
     a4: mov     [rbp-50h],rax
     a8: mov     rax,[rbp-50h]
     ac: imul    rcx,[rbp-18h],4
     b1: add     rax,rcx
     b4: mov     [rbp-58h],rax
     b8: mov     rax,[rbp-58h]
     bc: mov     [rbp-38h],rax
     c0: mov     rax,[rbp-28h]
     c4: mov     [rbp-30h],rax
     c8: mov     rax,[rbp-38h]
     cc: mov     [rbp-10h],rax
     d0: mov     rax,[rbp-30h]
     d4: mov     [rbp-8],rax
     d8: mov     edi,0FFFFFFF0h
     dd: mov     esi,10h
     e2: call    ryo_h_Ret
     e7: leave
     e8: ret

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-28h],rax
     10: mov     qword ptr [rbp-20h],0
     18: mov     rax,[rbp-28h]
     1c: mov     [rbp-18h],rax
     20: mov     edi,0FFFFFFC0h
     25: mov     esi,0FFFFFFE0h
     2a: call    ryo_h_MovW128
     2f: mov     edi,0FFFFFFB0h
     34: mov     esi,10h
     39: call    ryo_h_MovW128
     3e: mov     rax,[rbp+28h]
     42: mov     [rbp-30h],rax
     46: call    fn0
     4b: nop     [rcx-10h]
     52: mov     edi,0FFFFFFF0h
     57: mov     esi,10h
     5c: call    ryo_h_Ret
     61: leave
     62: ret

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
     13: je      30h
     15: mov     rax,[rbp+18h]
     19: mov     [rbp-50h],rax
     1d: mov     rax,[rbp-50h]
     21: mov     [rbp-48h],rax
     25: cmp     qword ptr [rbp-48h],0
     2a: sete    [rbp-39h]
     2e: jmp     64h
     30: mov     rax,[rbp+18h]
     34: mov     [rbp-50h],rax
     38: mov     rax,[rbp-50h]
     3c: mov     [rbp-48h],rax
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-58h],rax
     48: mov     rax,[rbp-58h]
     4c: mov     [rbp-50h],rax
     50: mov     rax,[rbp-48h]
     54: mov     [rbp-58h],rax
     58: mov     rax,[rbp-50h]
     5c: cmp     rax,[rbp-58h]
     60: sete    [rbp-39h]
     64: test    byte ptr [rbp-39h],0FFh
     68: je      92h
     6a: mov     byte ptr [rbp-2Ah],0
     6e: lea     rax,[rbp+20h]
     72: mov     [rbp-80h],rax
     76: mov     rax,[rbp-80h]
     7a: mov     [rbp-0A0h],rax
     81: call    fn0
     86: nop     [rcx-80h]
     8d: jmp     1D5h
     92: mov     byte ptr [rbp-2Ah],0
     96: mov     byte ptr [rbp-29h],1
     9a: mov     qword ptr [rbp-18h],0
     a2: mov     byte ptr [rbp-79h],0
     a6: test    byte ptr [rbp-79h],0FFh
     aa: je      0BEh
     ac: mov     rax,[rbp+18h]
     b0: mov     [rbp-40h],rax
     b4: mov     rax,[rbp-40h]
     b8: mov     [rbp-20h],rax
     bc: jmp     110h
     be: mov     rax,[rbp+18h]
     c2: mov     [rbp-48h],rax
     c6: mov     rax,[rbp-48h]
     ca: mov     [rbp-40h],rax
     ce: mov     rax,[rbp+10h]
     d2: mov     [rbp-48h],rax
     d6: mov     rax,[rbp-40h]
     da: mov     [rbp-50h],rax
     de: mov     rax,[rbp-48h]
     e2: mov     [rbp-58h],rax
     e6: mov     rax,[rbp-40h]
     ea: mov     [rbp-60h],rax
     ee: mov     byte ptr [rbp-79h],1
     f2: test    byte ptr [rbp-79h],0FFh
     f6: je      2A8h
     fc: jmp     265h
    101: nop     [rax+rax]
    10a: nop     [rax+rax]
    110: lea     rax,[rbp+20h]
    114: mov     [rbp-40h],rax
    118: mov     byte ptr [rbp-29h],0
    11c: mov     rax,[rbp+10h]
    120: mov     [rbp-60h],rax
    124: mov     rax,[rbp-18h]
    128: mov     [rbp-68h],rax
    12c: mov     rax,[rbp-60h]
    130: mov     [rbp-78h],rax
    134: mov     rax,[rbp-78h]
    138: imul    rcx,[rbp-68h],4
    13d: add     rax,rcx
    140: mov     [rbp-70h],rax
    144: mov     rax,[rbp-70h]
    148: mov     [rbp-58h],rax
    14c: mov     rax,[rbp-58h]
    150: mov     [rbp-50h],rax
    154: mov     rax,[rbp-50h]
    158: mov     [rbp-28h],rax
    15c: mov     rax,[rbp-28h]
    160: mov     [rbp-48h],rax
    164: mov     rax,[rbp-40h]
    168: mov     [rbp-0A0h],rax
    16f: mov     rax,[rbp-48h]
    173: mov     [rbp-98h],rax
    17a: call    fn1
    17f: nop     [rcx-20h]
    186: mov     byte ptr [rbp-79h],1
    18a: test    byte ptr [rbp-79h],0FFh
    18e: je      3AEh
    194: jmp     37Bh
    199: nop     [rax]
    1a0: lea     rax,[rbp+20h]
    1a4: mov     [rbp-80h],rax
    1a8: mov     rax,[rbp-80h]
    1ac: mov     [rbp-0A0h],rax
    1b3: call    fn2
    1b8: nop     [rcx-80h]
    1bf: jmp     1D5h
    1c1: nop     [rax+rax]
    1ca: nop     [rax+rax]
    1d0: jmp     110h
    1d5: xor     edi,edi
    1d7: xor     esi,esi
    1d9: call    ryo_h_Ret
    1de: leave
    1df: ret
    1e0: lea     rax,[rbp+20h]
    1e4: mov     [rbp-80h],rax
    1e8: mov     rax,[rbp-80h]
    1ec: mov     [rbp-0A0h],rax
    1f3: call    fn3
    1f8: nop     [rcx-80h]
    1ff: jmp     250h
    201: nop     [rax+rax]
    20a: nop     [rax+rax]
    210: mov     edi,0FFFFFFC8h
    215: call    ryo_h_Resume
    21a: ud2
    21c: nop     [rax]
    220: jmp     1E0h
    222: nop     [rax+rax]
    22b: nop     [rax+rax]
    230: test    byte ptr [rbp-29h],0FFh
    234: je      1E0h
    236: jmp     220h
    238: nop     [rax+rax]
    240: jmp     210h
    242: nop     [rax+rax]
    24b: nop     [rax+rax]
    250: test    byte ptr [rbp-2Ah],0FFh
    254: je      210h
    256: jmp     240h
    258: nop     [rax+rax]
    260: jmp     110h
    265: mov     rax,[rbp-40h]
    269: mov     [rbp-68h],rax
    26d: mov     rax,[rbp-48h]
    271: mov     [rbp-70h],rax
    275: mov     rax,[rbp-68h]
    279: mov     [rbp-0A0h],rax
    280: mov     rax,[rbp-70h]
    284: mov     [rbp-98h],rax
    28b: mov     edi,0FFFFFF70h
    290: lea     rsi,[k4]
    297: call    ryo_h_AddrAbs
    29c: call    fn5
    2a1: nop     [rcx-2Ah]
    2a8: mov     qword ptr [rbp-80h],0
    2b0: cmp     qword ptr [rbp-80h],4
    2b5: setb    [rbp-61h]
    2b9: test    byte ptr [rbp-61h],0FFh
    2bd: je      30Fh
    2bf: mov     qword ptr [rbp-80h],4
    2c7: mov     rax,[rbp-80h]
    2cb: mov     rcx,7FFFFFFFFFFFFFFFh
    2d5: cmp     rax,rcx
    2d8: setbe   [rbp-62h]
    2dc: test    byte ptr [rbp-62h],0FFh
    2e0: je      30Fh
    2e2: mov     rax,[rbp-60h]
    2e6: sub     rax,[rbp-58h]
    2ea: mov     [rbp-20h],rax
    2ee: mov     qword ptr [rbp-80h],4
    2f6: mov     edi,0FFFFFFE0h
    2fb: mov     esi,0FFFFFFE0h
    300: mov     edx,0FFFFFF80h
    305: call    ryo_h_DivUW64
    30a: jmp     260h
    30f: mov     edi,0FFFFFF60h
    314: lea     rsi,[k6]
    31b: call    ryo_h_AddrAbs
    320: mov     qword ptr [rbp-98h],49h
    32b: mov     edi,0FFFFFF70h
    330: lea     rsi,[k7]
    337: call    ryo_h_AddrAbs
    33c: lea     rdi,[sym8]
    343: lea     rsi,[site9]
    34a: mov     edx,0FFFFFF80h
    34f: call    ryo_h_CallExt
    354: test    rax,rax
    357: je      364h
    359: call    rax
    35b: nop     [rcx-2Ah]
    362: jmp     374h
    364: mov     rdi,rbp
    367: lea     rsi,[ro+4]
    36e: call    qword ptr [sym10]
    374: call    ryo_h_Unreachable
    379: ud2
    37b: mov     rax,[rbp-18h]
    37f: mov     [rbp-0A0h],rax
    386: mov     qword ptr [rbp-98h],1
    391: mov     edi,0FFFFFF70h
    396: lea     rsi,[k11]
    39d: call    ryo_h_AddrAbs
    3a2: call    fn12
    3a7: nop     [rcx-2Ah]
    3ae: mov     rax,[rbp-18h]
    3b2: add     rax,1
    3b6: mov     [rbp-40h],rax
    3ba: mov     rax,[rbp-40h]
    3be: mov     [rbp-18h],rax
    3c2: mov     rax,[rbp-18h]
    3c6: mov     [rbp-48h],rax
    3ca: mov     rax,[rbp-20h]
    3ce: mov     [rbp-50h],rax
    3d2: mov     rax,[rbp-48h]
    3d6: cmp     rax,[rbp-50h]
    3da: je      1A0h
    3e0: jmp     1D0h
    3e5: nop     [rax+rax]
    3ee: xchg    ax,ax
    3f0: lea     rdi,[sym13]
    3f7: lea     rsi,[site14]
    3fe: mov     edx,0FFFFFF80h
    403: call    ryo_h_CallExt
    408: test    rax,rax
    40b: je      418h
    40d: call    rax
    40f: nop     [rcx-78h]
    416: jmp     428h
    418: mov     rdi,rbp
    41b: lea     rsi,[ro+20]
    422: call    qword ptr [sym15]
    428: call    ryo_h_Unreachable
    42d: ud2
    42f: mov     rdi,rax
    432: mov     esi,0FFFFFFC8h
    437: call    ryo_h_Lpad
    43c: jmp     250h
    441: mov     rdi,rax
    444: mov     esi,0FFFFFFC8h
    449: call    ryo_h_Lpad
    44e: jmp     230h
    453: mov     rdi,rax
    456: mov     esi,0FFFFFFC8h
    45b: call    ryo_h_Lpad
    460: jmp     3F0h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-0A1h],0
     12: test    byte ptr [rbp-0A1h],0FFh
     19: je      36h
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-58h],rax
     23: mov     rax,[rbp-58h]
     27: mov     [rbp-50h],rax
     2b: cmp     qword ptr [rbp-50h],0
     30: sete    [rbp-41h]
     34: jmp     6Ah
     36: mov     rax,[rbp+18h]
     3a: mov     [rbp-58h],rax
     3e: mov     rax,[rbp-58h]
     42: mov     [rbp-50h],rax
     46: mov     rax,[rbp+10h]
     4a: mov     [rbp-60h],rax
     4e: mov     rax,[rbp-60h]
     52: mov     [rbp-58h],rax
     56: mov     rax,[rbp-50h]
     5a: mov     [rbp-60h],rax
     5e: mov     rax,[rbp-58h]
     62: cmp     rax,[rbp-60h]
     66: sete    [rbp-41h]
     6a: test    byte ptr [rbp-41h],0FFh
     6e: je      81h
     70: mov     byte ptr [rbp-32h],0
     74: mov     rax,[rbp+20h]
     78: mov     [rbp-8],rax
     7c: jmp     1F5h
     81: mov     byte ptr [rbp-32h],0
     85: mov     byte ptr [rbp-31h],1
     89: mov     rax,[rbp+20h]
     8d: mov     [rbp-48h],rax
     91: mov     qword ptr [rbp-20h],0
     99: mov     byte ptr [rbp-0A1h],0
     a0: test    byte ptr [rbp-0A1h],0FFh
     a7: je      0BBh
     a9: mov     rax,[rbp+18h]
     ad: mov     [rbp-50h],rax
     b1: mov     rax,[rbp-50h]
     b5: mov     [rbp-28h],rax
     b9: jmp     110h
     bb: mov     rax,[rbp+18h]
     bf: mov     [rbp-58h],rax
     c3: mov     rax,[rbp-58h]
     c7: mov     [rbp-50h],rax
     cb: mov     rax,[rbp+10h]
     cf: mov     [rbp-58h],rax
     d3: mov     rax,[rbp-50h]
     d7: mov     [rbp-60h],rax
     db: mov     rax,[rbp-58h]
     df: mov     [rbp-68h],rax
     e3: mov     rax,[rbp-50h]
     e7: mov     [rbp-70h],rax
     eb: mov     byte ptr [rbp-0A1h],1
     f2: test    byte ptr [rbp-0A1h],0FFh
     f9: je      2A8h
     ff: jmp     265h
    104: nop     [rax+rax]
    10d: nop     [rax]
    110: lea     rax,[rbp+28h]
    114: mov     [rbp-58h],rax
    118: mov     byte ptr [rbp-31h],0
    11c: mov     rax,[rbp-48h]
    120: mov     [rbp-70h],rax
    124: mov     rax,[rbp+10h]
    128: mov     [rbp-88h],rax
    12f: mov     rax,[rbp-20h]
    133: mov     [rbp-90h],rax
    13a: mov     rax,[rbp-88h]
    141: mov     [rbp-0A0h],rax
    148: mov     rax,[rbp-0A0h]
    14f: imul    rcx,[rbp-90h],4
    157: add     rax,rcx
    15a: mov     [rbp-98h],rax
    161: mov     rax,[rbp-98h]
    168: mov     [rbp-80h],rax
    16c: mov     rax,[rbp-80h]
    170: mov     [rbp-78h],rax
    174: mov     rax,[rbp-78h]
    178: mov     [rbp-30h],rax
    17c: mov     rax,[rbp-70h]
    180: mov     [rbp-68h],rax
    184: mov     rax,[rbp-30h]
    188: mov     [rbp-60h],rax
    18c: mov     rax,[rbp-58h]
    190: mov     [rbp-0C0h],rax
    197: mov     rax,[rbp-68h]
    19b: mov     [rbp-0B8h],rax
    1a2: mov     rax,[rbp-60h]
    1a6: mov     [rbp-0B0h],rax
    1ad: call    fn0
    1b2: nop     [rcx-50h]
    1b9: mov     rax,[rbp-50h]
    1bd: mov     [rbp-48h],rax
    1c1: mov     byte ptr [rbp-0A1h],1
    1c8: test    byte ptr [rbp-0A1h],0FFh
    1cf: je      3BDh
    1d5: jmp     38Ah
    1da: nop     [rax+rax]
    1e0: mov     rax,[rbp-48h]
    1e4: mov     [rbp-8],rax
    1e8: jmp     1F5h
    1ea: nop     [rax+rax]
    1f0: jmp     110h
    1f5: mov     edi,0FFFFFFF8h
    1fa: mov     esi,8
    1ff: call    ryo_h_Ret
    204: leave
    205: ret
    206: nop     [rax+rax]
    20f: nop
    210: jmp     252h
    212: nop     [rax+rax]
    21b: nop     [rax+rax]
    220: mov     edi,0FFFFFFC0h
    225: call    ryo_h_Resume
    22a: ud2
    22c: nop     [rax]
    230: jmp     210h
    232: nop     [rax+rax]
    23b: nop     [rax+rax]
    240: test    byte ptr [rbp-31h],0FFh
    244: je      210h
    246: jmp     230h
    248: nop     [rax+rax]
    250: jmp     220h
    252: test    byte ptr [rbp-32h],0FFh
    256: je      220h
    258: jmp     250h
    25a: nop     [rax+rax]
    260: jmp     110h
    265: mov     rax,[rbp-50h]
    269: mov     [rbp-78h],rax
    26d: mov     rax,[rbp-58h]
    271: mov     [rbp-80h],rax
    275: mov     rax,[rbp-78h]
    279: mov     [rbp-0C0h],rax
    280: mov     rax,[rbp-80h]
    284: mov     [rbp-0B8h],rax
    28b: mov     edi,0FFFFFF50h
    290: lea     rsi,[k1]
    297: call    ryo_h_AddrAbs
    29c: call    fn2
    2a1: nop     [rcx-32h]
    2a8: mov     qword ptr [rbp-0A8h],0
    2b3: cmp     qword ptr [rbp-0A8h],4
    2bb: setb    [rbp-71h]
    2bf: test    byte ptr [rbp-71h],0FFh
    2c3: je      31Eh
    2c5: mov     qword ptr [rbp-0A8h],4
    2d0: mov     rax,[rbp-0A8h]
    2d7: mov     rcx,7FFFFFFFFFFFFFFFh
    2e1: cmp     rax,rcx
    2e4: setbe   [rbp-72h]
    2e8: test    byte ptr [rbp-72h],0FFh
    2ec: je      31Eh
    2ee: mov     rax,[rbp-70h]
    2f2: sub     rax,[rbp-68h]
    2f6: mov     [rbp-28h],rax
    2fa: mov     qword ptr [rbp-0A8h],4
    305: mov     edi,0FFFFFFD8h
    30a: mov     esi,0FFFFFFD8h
    30f: mov     edx,0FFFFFF58h
    314: call    ryo_h_DivUW64
    319: jmp     260h
    31e: mov     edi,0FFFFFF40h
    323: lea     rsi,[k3]
    32a: call    ryo_h_AddrAbs
    32f: mov     qword ptr [rbp-0B8h],49h
    33a: mov     edi,0FFFFFF50h
    33f: lea     rsi,[k4]
    346: call    ryo_h_AddrAbs
    34b: lea     rdi,[sym5]
    352: lea     rsi,[site6]
    359: mov     edx,0FFFFFF58h
    35e: call    ryo_h_CallExt
    363: test    rax,rax
    366: je      373h
    368: call    rax
    36a: nop     [rcx-32h]
    371: jmp     383h
    373: mov     rdi,rbp
    376: lea     rsi,[ro+4]
    37d: call    qword ptr [sym7]
    383: call    ryo_h_Unreachable
    388: ud2
    38a: mov     rax,[rbp-20h]
    38e: mov     [rbp-0C0h],rax
    395: mov     qword ptr [rbp-0B8h],1
    3a0: mov     edi,0FFFFFF50h
    3a5: lea     rsi,[k8]
    3ac: call    ryo_h_AddrAbs
    3b1: call    fn9
    3b6: nop     [rcx-32h]
    3bd: mov     rax,[rbp-20h]
    3c1: add     rax,1
    3c5: mov     [rbp-50h],rax
    3c9: mov     rax,[rbp-50h]
    3cd: mov     [rbp-20h],rax
    3d1: mov     rax,[rbp-20h]
    3d5: mov     [rbp-58h],rax
    3d9: mov     rax,[rbp-28h]
    3dd: mov     [rbp-60h],rax
    3e1: mov     rax,[rbp-58h]
    3e5: cmp     rax,[rbp-60h]
    3e9: je      1E0h
    3ef: jmp     1F0h
    3f4: mov     rdi,rax
    3f7: mov     esi,0FFFFFFC0h
    3fc: call    ryo_h_Lpad
    401: jmp     240h

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
     2a: je      5Bh
     2c: mov     rax,[rbp-40h]
     30: mov     [rbp-48h],rax
     34: cmp     qword ptr [rbp-48h],0
     39: jne     48h
     3b: mov     qword ptr [rbp-8],0
     43: jmp     0DAh
     48: mov     byte ptr [rbp-59h],1
     4c: test    byte ptr [rbp-59h],0FFh
     50: je      118h
     56: jmp     0EBh
     5b: mov     rax,[rbp-40h]
     5f: mov     [rbp-50h],rax
     63: mov     rax,[rbp-38h]
     67: mov     [rbp-30h],rax
     6b: mov     rax,[rbp-50h]
     6f: mov     [rbp-58h],rax
     73: mov     rax,[rbp-30h]
     77: cmp     rax,[rbp-58h]
     7b: sete    [rbp-41h]
     7f: test    byte ptr [rbp-41h],0FFh
     83: je      8Fh
     85: mov     qword ptr [rbp-8],0
     8d: jmp     0DAh
     8f: mov     qword ptr [rbp-60h],1
     97: mov     rax,[rbp-30h]
     9b: imul    rcx,[rbp-60h],4
     a0: add     rax,rcx
     a3: mov     [rbp-50h],rax
     a7: mov     rax,[rbp-50h]
     ab: mov     [rbp-48h],rax
     af: mov     rax,[rbp+10h]
     b3: mov     rcx,[rbp-48h]
     b7: mov     [rax],rcx
     ba: nop     [rax+rax]
     c0: mov     rax,[rbp-38h]
     c4: mov     [rbp-50h],rax
     c8: mov     rax,[rbp-50h]
     cc: mov     [rbp-48h],rax
     d0: mov     rax,[rbp-48h]
     d4: mov     [rbp-8],rax
     d8: jmp     0DAh
     da: mov     edi,0FFFFFFF8h
     df: mov     esi,8
     e4: call    ryo_h_Ret
     e9: leave
     ea: ret
     eb: mov     rax,[rbp-48h]
     ef: mov     [rbp-80h],rax
     f3: mov     qword ptr [rbp-78h],1
     fb: mov     edi,0FFFFFF90h
    100: lea     rsi,[k0]
    107: call    ryo_h_AddrAbs
    10c: call    fn1
    111: nop     [rcx-28h]
    118: mov     rax,[rbp-48h]
    11c: sub     rax,1
    120: mov     [rbp-10h],rax
    124: mov     rax,[rbp+10h]
    128: mov     rcx,[rbp-10h]
    12c: mov     [rax+8],rcx
    130: jmp     0C0h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-59h],0
      f: test    byte ptr [rbp-59h],0FFh
     13: je      2Bh
     15: mov     rax,[rbp+10h]
     19: mov     rax,[rax+8]
     1d: mov     [rbp-28h],rax
     21: mov     rax,[rbp-28h]
     25: mov     [rbp-20h],rax
     29: jmp     80h
     2b: mov     rax,[rbp+10h]
     2f: mov     rax,[rax+8]
     33: mov     [rbp-30h],rax
     37: mov     rax,[rbp-30h]
     3b: mov     [rbp-28h],rax
     3f: mov     rax,[rbp+10h]
     43: mov     rax,[rax]
     46: mov     [rbp-30h],rax
     4a: mov     rax,[rbp-28h]
     4e: mov     [rbp-38h],rax
     52: mov     rax,[rbp-30h]
     56: mov     [rbp-40h],rax
     5a: mov     rax,[rbp-28h]
     5e: mov     [rbp-48h],rax
     62: mov     byte ptr [rbp-59h],1
     66: test    byte ptr [rbp-59h],0FFh
     6a: je      0FFh
     70: jmp     0C2h
     72: nop     [rax+rax]
     7b: nop     [rax+rax]
     80: mov     rax,[rbp-20h]
     84: mov     [rbp-28h],rax
     88: mov     rax,[rbp-20h]
     8c: mov     [rbp-30h],rax
     90: mov     qword ptr [rbp-38h],1
     98: mov     rax,[rbp-28h]
     9c: mov     [rbp-18h],rax
     a0: mov     edi,0FFFFFFF0h
     a5: mov     esi,0FFFFFFC8h
     aa: call    ryo_h_MovW128
     af: mov     edi,0FFFFFFE8h
     b4: mov     esi,18h
     b9: call    ryo_h_Ret
     be: leave
     bf: ret
     c0: jmp     80h
     c2: mov     rax,[rbp-28h]
     c6: mov     [rbp-50h],rax
     ca: mov     rax,[rbp-30h]
     ce: mov     [rbp-58h],rax
     d2: mov     rax,[rbp-50h]
     d6: mov     [rbp-80h],rax
     da: mov     rax,[rbp-58h]
     de: mov     [rbp-78h],rax
     e2: mov     edi,0FFFFFF90h
     e7: lea     rsi,[k0]
     ee: call    ryo_h_AddrAbs
     f3: call    fn1
     f8: nop     [rcx-20h]
     ff: mov     qword ptr [rbp-60h],0
    107: cmp     qword ptr [rbp-60h],4
    10c: setb    [rbp-49h]
    110: test    byte ptr [rbp-49h],0FFh
    114: je      166h
    116: mov     qword ptr [rbp-60h],4
    11e: mov     rax,[rbp-60h]
    122: mov     rcx,7FFFFFFFFFFFFFFFh
    12c: cmp     rax,rcx
    12f: setbe   [rbp-4Ah]
    133: test    byte ptr [rbp-4Ah],0FFh
    137: je      166h
    139: mov     rax,[rbp-48h]
    13d: sub     rax,[rbp-40h]
    141: mov     [rbp-20h],rax
    145: mov     qword ptr [rbp-60h],4
    14d: mov     edi,0FFFFFFE0h
    152: mov     esi,0FFFFFFE0h
    157: mov     edx,0FFFFFFA0h
    15c: call    ryo_h_DivUW64
    161: jmp     0C0h
    166: mov     edi,0FFFFFF80h
    16b: lea     rsi,[k2]
    172: call    ryo_h_AddrAbs
    177: mov     qword ptr [rbp-78h],49h
    17f: mov     edi,0FFFFFF90h
    184: lea     rsi,[k3]
    18b: call    ryo_h_AddrAbs
    190: lea     rdi,[sym4]
    197: lea     rsi,[site5]
    19e: mov     edx,0FFFFFFA0h
    1a3: call    ryo_h_CallExt
    1a8: test    rax,rax
    1ab: je      1B8h
    1ad: call    rax
    1af: nop     [rcx-20h]
    1b6: jmp     1C8h
    1b8: mov     rdi,rbp
    1bb: lea     rsi,[ro+4]
    1c2: call    qword ptr [sym6]
    1c8: call    ryo_h_Unreachable
    1cd: ud2

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
     14: mov     rax,[rbp-30h]
     18: mov     [rbp-28h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-20h],rax
     30: mov     rax,[rbp-30h]
     34: mov     [rbp-18h],rax
     38: mov     rax,[rbp-20h]
     3c: mov     [rbp-10h],rax
     40: mov     rax,[rbp-18h]
     44: mov     [rbp-8],rax
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     rax,[rbp-20h]
     18: mov     [rbp-18h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-20h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-10h],rax
     30: mov     rax,[rbp-20h]
     34: mov     [rbp-8],rax
     38: mov     rax,[rbp-10h]
     3c: mov     [rbp-20h],rax
     40: mov     rax,[rbp-8]
     44: mov     [rbp-18h],rax
     48: mov     edi,0FFFFFFC0h
     4d: mov     esi,0FFFFFFE0h
     52: call    ryo_h_MovW128
     57: mov     edi,0FFFFFFD8h
     5c: lea     rsi,[sym0]
     63: call    ryo_h_AddrSym
     68: mov     rdi,rbp
     6b: lea     rsi,[ro+4]
     72: call    qword ptr [sym1]
     78: xor     edi,edi
     7a: xor     esi,esi
     7c: call    ryo_h_Ret
     81: leave
     82: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     rax,[rbp-38h]
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-38h],rax
     28: mov     rax,[rbp-30h]
     2c: mov     [rbp-28h],rax
     30: mov     rax,[rbp-38h]
     34: mov     [rbp-20h],rax
     38: mov     rax,[rbp-28h]
     3c: mov     [rbp-18h],rax
     40: mov     rax,[rbp-20h]
     44: mov     [rbp-10h],rax
     48: mov     rax,[rbp+18h]
     4c: mov     [rbp-50h],rax
     50: mov     edi,0FFFFFFA0h
     55: mov     esi,0FFFFFFE8h
     5a: call    ryo_h_MovW128
     5f: mov     rax,[rbp+20h]
     63: mov     [rbp-48h],rax
     67: call    fn0
     6c: nop     [rcx-8]
     73: mov     edi,0FFFFFFF8h
     78: mov     esi,8
     7d: call    ryo_h_Ret
     82: leave
     83: ret

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
     17: mov     rax,[rbp-68h]
     1b: mov     [rbp-0E0h],rax
     22: call    fn0
     27: nop     [rcx-60h]
     2e: mov     rax,[rbp-58h]
     32: mov     [rbp-20h],rax
     36: mov     edi,0FFFFFFE0h
     3b: xor     esi,esi
     3d: mov     edx,2
     42: call    ryo_h_SwitchDenseW64
     47: lea     rcx,[58h]
     4e: movsxd  rax,[rcx+rax*4]
     52: add     rax,rcx
     55: jmp     rax
     57: int3
     58: .long   64h
     5c: .long   180h
     60: .long   2b4h
     64: mov     edi,0FFFFFF80h
     69: lea     rsi,[k1]
     70: call    ryo_h_AddrAbs
     75: mov     qword ptr [rbp-78h],11h
     7d: mov     rax,[rbp-80h]
     81: mov     [rbp-0A0h],rax
     88: mov     rax,[rbp-78h]
     8c: mov     [rbp-98h],rax
     93: mov     rax,[rbp-0A0h]
     9a: mov     [rbp-90h],rax
     a1: mov     rax,[rbp-90h]
     a8: mov     [rbp-88h],rax
     af: mov     edi,0FFFFFF48h
     b4: lea     rsi,[k2]
     bb: call    ryo_h_AddrAbs
     c0: mov     qword ptr [rbp-0B0h],11h
     cb: mov     rax,[rbp-0B0h]
     d2: mov     [rbp-0A8h],rax
     d9: mov     rax,[rbp-0A8h]
     e0: shl     rax,1
     e4: mov     [rbp-0A0h],rax
     eb: mov     rax,[rbp-0A0h]
     f2: or      rax,1
     f6: mov     [rbp-98h],rax
     fd: mov     rax,[rbp-98h]
    104: mov     [rbp-90h],rax
    10b: mov     rax,[rbp-88h]
    112: mov     [rbp-70h],rax
    116: mov     rax,[rbp-90h]
    11d: mov     [rbp-68h],rax
    121: mov     edi,0FFFFFF20h
    126: mov     esi,0FFFFFF90h
    12b: call    ryo_h_MovW128
    130: mov     edi,0FFFFFF30h
    135: lea     rsi,[k3]
    13c: call    ryo_h_AddrAbs
    141: lea     rdi,[sym4]
    148: lea     rsi,[site5]
    14f: mov     edx,0FFFFFF40h
    154: call    ryo_h_CallExt
    159: test    rax,rax
    15c: je      169h
    15e: call    rax
    160: nop     [rcx-20h]
    167: jmp     179h
    169: mov     rdi,rbp
    16c: lea     rsi,[ro+4]
    173: call    qword ptr [sym6]
    179: call    ryo_h_Unreachable
    17e: ud2
    180: mov     rax,[rbp-50h]
    184: mov     [rbp-68h],rax
    188: mov     rax,[rbp-68h]
    18c: mov     [rbp-0E0h],rax
    193: mov     edi,0FFFFFF28h
    198: lea     rsi,[k7]
    19f: mov     edx,10h
    1a4: call    ryo_h_Const
    1a9: call    fn8
    1ae: nop     [rcx-88h]
    1b5: jmp     248h
    1ba: nop     [rax+rax]
    1c0: mov     edi,0FFFFFFE8h
    1c5: mov     esi,0FFFFFFB8h
    1ca: mov     edx,18h
    1cf: call    ryo_h_Copy
    1d4: mov     edi,0FFFFFFE8h
    1d9: mov     esi,18h
    1de: call    ryo_h_Ret
    1e3: leave
    1e4: ret
    1e5: nop     [rax+rax]
    1ee: xchg    ax,ax
    1f0: lea     rax,[rbp-48h]
    1f4: mov     [rbp-0C0h],rax
    1fb: mov     rax,[rbp-0C0h]
    202: mov     [rbp-0E0h],rax
    209: call    fn9
    20e: nop     [rcx-0C0h]
    215: jmp     240h
    217: nop     [rax+rax]
    220: mov     edi,0FFFFFFD0h
    225: call    ryo_h_Resume
    22a: ud2
    22c: nop     [rax]
    230: jmp     220h
    232: nop     [rax+rax]
    23b: nop     [rax+rax]
    240: test    byte ptr [rbp-21h],0FFh
    244: je      220h
    246: jmp     230h
    248: mov     edi,0FFFFFF88h
    24d: mov     esi,0FFFFFF78h
    252: call    ryo_h_MovW128
    257: mov     edi,0FFFFFFB8h
    25c: mov     esi,0FFFFFF88h
    261: call    ryo_h_MovW128
    266: mov     qword ptr [rbp-38h],0
    26e: lea     rax,[rbp-48h]
    272: mov     [rbp-50h],rax
    276: mov     byte ptr [rbp-21h],0
    27a: mov     edi,0FFFFFFA0h
    27f: mov     esi,10h
    284: call    ryo_h_MovW128
    289: mov     rax,[rbp-50h]
    28d: mov     [rbp-0E0h],rax
    294: mov     edi,0FFFFFF28h
    299: mov     esi,0FFFFFFA0h
    29e: call    ryo_h_MovW128
    2a3: call    fn10
    2a8: nop     [rcx-20h]
    2af: jmp     1C0h
    2b4: call    ryo_h_Unreachable
    2b9: ud2
    2bb: nop     [rax+rax]
    2c0: lea     rdi,[sym11]
    2c7: lea     rsi,[site12]
    2ce: mov     edx,0FFFFFF40h
    2d3: call    ryo_h_CallExt
    2d8: test    rax,rax
    2db: je      2E8h
    2dd: call    rax
    2df: nop     [rcx-0B8h]
    2e6: jmp     2F8h
    2e8: mov     rdi,rbp
    2eb: lea     rsi,[ro+20]
    2f2: call    qword ptr [sym13]
    2f8: call    ryo_h_Unreachable
    2fd: ud2
    2ff: mov     rdi,rax
    302: mov     esi,0FFFFFFD0h
    307: call    ryo_h_Lpad
    30c: jmp     240h
    311: mov     rdi,rax
    314: mov     esi,0FFFFFFD0h
    319: call    ryo_h_Lpad
    31e: jmp     2C0h
    320: mov     rdi,rax
    323: mov     esi,0FFFFFFD0h
    328: call    ryo_h_Lpad
    32d: jmp     1F0h

fn <std::vec::Vec<u32> as std::clone::Clone>::clone
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+10h]
     10: mov     [rbp-20h],rax
     14: mov     rax,[rbp-20h]
     18: mov     [rbp-60h],rax
     1c: call    fn0
     21: nop     [rcx-18h]
     28: mov     rax,[rbp+10h]
     2c: mov     rax,[rax+8]
     30: mov     [rbp-48h],rax
     34: mov     rax,[rbp-48h]
     38: mov     [rbp-40h],rax
     3c: mov     rax,[rbp+10h]
     40: mov     rax,[rax+10h]
     44: mov     [rbp-48h],rax
     48: mov     rax,[rbp-40h]
     4c: mov     [rbp-38h],rax
     50: mov     rax,[rbp-48h]
     54: mov     [rbp-30h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-28h],rax
     60: mov     rax,[rbp-30h]
     64: mov     [rbp-20h],rax
     68: mov     edi,0FFFFFFA0h
     6d: mov     esi,0FFFFFFD8h
     72: call    ryo_h_MovW128
     77: call    fn1
     7c: nop     [rcx-18h]
     83: mov     edi,0FFFFFFE8h
     88: mov     esi,18h
     8d: call    ryo_h_Ret
     92: leave
     93: ret

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     rax,[rbp-38h]
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-38h],rax
     28: mov     rax,[rbp-30h]
     2c: mov     [rbp-28h],rax
     30: mov     rax,[rbp-38h]
     34: mov     [rbp-20h],rax
     38: mov     rax,[rbp-28h]
     3c: mov     [rbp-18h],rax
     40: mov     rax,[rbp-20h]
     44: mov     [rbp-10h],rax
     48: mov     edi,0FFFFFFB0h
     4d: mov     esi,0FFFFFFE8h
     52: call    ryo_h_MovW128
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-40h],rax
     5f: call    fn0
     64: nop     [rcx-1]
     6b: mov     edi,0FFFFFFFFh
     70: mov     esi,1
     75: call    ryo_h_Ret
     7a: leave
     7b: ret

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
     14: mov     rax,[rbp-30h]
     18: mov     [rbp-28h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-20h],rax
     30: mov     rax,[rbp-30h]
     34: mov     [rbp-18h],rax
     38: mov     rax,[rbp-20h]
     3c: mov     [rbp-10h],rax
     40: mov     rax,[rbp-18h]
     44: mov     [rbp-8],rax
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-30h],rax
     14: mov     rax,[rbp-30h]
     18: mov     [rbp-28h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-20h],rax
     30: mov     rax,[rbp-30h]
     34: mov     [rbp-18h],rax
     38: mov     rax,[rbp-20h]
     3c: mov     [rbp-10h],rax
     40: mov     rax,[rbp-18h]
     44: mov     [rbp-8],rax
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     rax,[rbp-20h]
     18: mov     [rbp-18h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-20h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-10h],rax
     30: mov     rax,[rbp-20h]
     34: mov     [rbp-8],rax
     38: mov     rax,[rbp-10h]
     3c: mov     [rbp-20h],rax
     40: mov     rax,[rbp-8]
     44: mov     [rbp-18h],rax
     48: mov     edi,0FFFFFFC0h
     4d: mov     esi,0FFFFFFE0h
     52: call    ryo_h_MovW128
     57: mov     edi,0FFFFFFD8h
     5c: lea     rsi,[sym0]
     63: call    ryo_h_AddrSym
     68: mov     rdi,rbp
     6b: lea     rsi,[ro+4]
     72: call    qword ptr [sym1]
     78: xor     edi,edi
     7a: xor     esi,esi
     7c: call    ryo_h_Ret
     81: leave
     82: ret

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-40h],rax
     18: call    fn0
     1d: nop     [rcx-10h]
     24: jmp     3Bh
     26: nop     [rax+rax]
     2f: nop
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
     17: mov     rax,[rbp-68h]
     1b: mov     [rbp-0E0h],rax
     22: call    fn0
     27: nop     [rcx-60h]
     2e: mov     rax,[rbp-58h]
     32: mov     [rbp-20h],rax
     36: mov     edi,0FFFFFFE0h
     3b: xor     esi,esi
     3d: mov     edx,2
     42: call    ryo_h_SwitchDenseW64
     47: lea     rcx,[58h]
     4e: movsxd  rax,[rcx+rax*4]
     52: add     rax,rcx
     55: jmp     rax
     57: int3
     58: .long   64h
     5c: .long   180h
     60: .long   2beh
     64: mov     edi,0FFFFFF80h
     69: lea     rsi,[k1]
     70: call    ryo_h_AddrAbs
     75: mov     qword ptr [rbp-78h],11h
     7d: mov     rax,[rbp-80h]
     81: mov     [rbp-0A0h],rax
     88: mov     rax,[rbp-78h]
     8c: mov     [rbp-98h],rax
     93: mov     rax,[rbp-0A0h]
     9a: mov     [rbp-90h],rax
     a1: mov     rax,[rbp-90h]
     a8: mov     [rbp-88h],rax
     af: mov     edi,0FFFFFF48h
     b4: lea     rsi,[k2]
     bb: call    ryo_h_AddrAbs
     c0: mov     qword ptr [rbp-0B0h],11h
     cb: mov     rax,[rbp-0B0h]
     d2: mov     [rbp-0A8h],rax
     d9: mov     rax,[rbp-0A8h]
     e0: shl     rax,1
     e4: mov     [rbp-0A0h],rax
     eb: mov     rax,[rbp-0A0h]
     f2: or      rax,1
     f6: mov     [rbp-98h],rax
     fd: mov     rax,[rbp-98h]
    104: mov     [rbp-90h],rax
    10b: mov     rax,[rbp-88h]
    112: mov     [rbp-70h],rax
    116: mov     rax,[rbp-90h]
    11d: mov     [rbp-68h],rax
    121: mov     edi,0FFFFFF20h
    126: mov     esi,0FFFFFF90h
    12b: call    ryo_h_MovW128
    130: mov     edi,0FFFFFF30h
    135: lea     rsi,[k3]
    13c: call    ryo_h_AddrAbs
    141: lea     rdi,[sym4]
    148: lea     rsi,[site5]
    14f: mov     edx,0FFFFFF40h
    154: call    ryo_h_CallExt
    159: test    rax,rax
    15c: je      169h
    15e: call    rax
    160: nop     [rcx-20h]
    167: jmp     179h
    169: mov     rdi,rbp
    16c: lea     rsi,[ro+4]
    173: call    qword ptr [sym6]
    179: call    ryo_h_Unreachable
    17e: ud2
    180: mov     rax,[rbp-50h]
    184: mov     [rbp-68h],rax
    188: mov     rax,[rbp-68h]
    18c: mov     [rbp-0E0h],rax
    193: mov     edi,0FFFFFF28h
    198: lea     rsi,[k7]
    19f: mov     edx,10h
    1a4: call    ryo_h_Const
    1a9: call    fn8
    1ae: nop     [rcx-88h]
    1b5: jmp     248h
    1ba: nop     [rax+rax]
    1c0: mov     edi,0FFFFFFE8h
    1c5: mov     esi,0FFFFFFB8h
    1ca: mov     edx,18h
    1cf: call    ryo_h_Copy
    1d4: mov     edi,0FFFFFFE8h
    1d9: mov     esi,18h
    1de: call    ryo_h_Ret
    1e3: leave
    1e4: ret
    1e5: nop     [rax+rax]
    1ee: xchg    ax,ax
    1f0: lea     rax,[rbp-48h]
    1f4: mov     [rbp-0C0h],rax
    1fb: mov     rax,[rbp-0C0h]
    202: mov     [rbp-0E0h],rax
    209: call    fn9
    20e: nop     [rcx-0C0h]
    215: jmp     240h
    217: nop     [rax+rax]
    220: mov     edi,0FFFFFFD0h
    225: call    ryo_h_Resume
    22a: ud2
    22c: nop     [rax]
    230: jmp     220h
    232: nop     [rax+rax]
    23b: nop     [rax+rax]
    240: test    byte ptr [rbp-21h],0FFh
    244: je      220h
    246: jmp     230h
    248: mov     edi,0FFFFFF88h
    24d: mov     esi,0FFFFFF78h
    252: call    ryo_h_MovW128
    257: mov     edi,0FFFFFFB8h
    25c: mov     esi,0FFFFFF88h
    261: call    ryo_h_MovW128
    266: mov     qword ptr [rbp-38h],0
    26e: lea     rax,[rbp-48h]
    272: mov     [rbp-50h],rax
    276: mov     byte ptr [rbp-21h],0
    27a: mov     edi,0FFFFFF98h
    27f: mov     esi,10h
    284: mov     edx,18h
    289: call    ryo_h_Copy
    28e: mov     rax,[rbp-50h]
    292: mov     [rbp-0E0h],rax
    299: mov     edi,0FFFFFF28h
    29e: mov     esi,0FFFFFF98h
    2a3: mov     edx,18h
    2a8: call    ryo_h_Copy
    2ad: call    fn10
    2b2: nop     [rcx-20h]
    2b9: jmp     1C0h
    2be: call    ryo_h_Unreachable
    2c3: ud2
    2c5: nop     [rax+rax]
    2ce: xchg    ax,ax
    2d0: lea     rdi,[sym11]
    2d7: lea     rsi,[site12]
    2de: mov     edx,0FFFFFF40h
    2e3: call    ryo_h_CallExt
    2e8: test    rax,rax
    2eb: je      2F8h
    2ed: call    rax
    2ef: nop     [rcx-0B8h]
    2f6: jmp     308h
    2f8: mov     rdi,rbp
    2fb: lea     rsi,[ro+20]
    302: call    qword ptr [sym13]
    308: call    ryo_h_Unreachable
    30d: ud2
    30f: mov     rdi,rax
    312: mov     esi,0FFFFFFD0h
    317: call    ryo_h_Lpad
    31c: jmp     240h
    321: mov     rdi,rax
    324: mov     esi,0FFFFFFD0h
    329: call    ryo_h_Lpad
    32e: jmp     2D0h
    330: mov     rdi,rax
    333: mov     esi,0FFFFFFD0h
    338: call    ryo_h_Lpad
    33d: jmp     1F0h

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
     1f: mov     rax,[rbp-8]
     23: mov     rcx,[rbp-10h]
     27: mov     [rax],rcx
     2a: xor     edi,edi
     2c: xor     esi,esi
     2e: call    ryo_h_Ret
     33: leave
     34: ret

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
     1d: je      5Fh
     1f: mov     qword ptr [rbp-18h],4
     27: imul    rax,[rbp-18h],20h
     2c: mov     [rbp-10h],rax
     30: cmp     qword ptr [rbp-10h],1000h
     38: ja      5Fh
     3a: mov     edi,0FFFFFFC0h
     3f: mov     esi,10h
     44: call    ryo_h_MovW128
     49: mov     rax,[rbp+20h]
     4d: mov     [rbp-30h],rax
     51: call    fn0
     56: nop     [rcx]
     5d: jmp     0B0h
     5f: mov     qword ptr [rbp-18h],4
     67: imul    rax,[rbp-18h],30h
     6c: mov     [rbp-10h],rax
     70: cmp     qword ptr [rbp-10h],1000h
     78: ja      9Fh
     7a: mov     edi,0FFFFFFC0h
     7f: mov     esi,10h
     84: call    ryo_h_MovW128
     89: mov     rax,[rbp+20h]
     8d: mov     [rbp-30h],rax
     91: call    fn1
     96: nop     [rcx]
     9d: jmp     0B0h
     9f: mov     rax,[rbp+18h]
     a3: mov     [rbp-10h],rax
     a7: cmp     qword ptr [rbp-10h],2
     ac: jae     0BBh
     ae: jmp     0E8h
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
     1d: je      44h
     1f: mov     qword ptr [rbp-20h],4
     27: imul    rax,[rbp-20h],20h
     2c: mov     [rbp-18h],rax
     30: cmp     qword ptr [rbp-18h],1000h
     38: ja      44h
     3a: mov     qword ptr [rbp-8],20h
     42: jmp     71h
     44: mov     qword ptr [rbp-20h],4
     4c: imul    rax,[rbp-20h],30h
     51: mov     [rbp-18h],rax
     55: cmp     qword ptr [rbp-18h],1000h
     5d: ja      69h
     5f: mov     qword ptr [rbp-8],20h
     67: jmp     71h
     69: mov     qword ptr [rbp-8],10h
     71: mov     edi,0FFFFFFF8h
     76: mov     esi,8
     7b: call    ryo_h_Ret
     80: leave
     81: ret

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
     13: mov     rax,[rbp-58h]
     17: mov     [rbp-0C0h],rax
     1e: mov     edi,0FFFFFF48h
     23: lea     rsi,[k0]
     2a: mov     edx,10h
     2f: call    ryo_h_Const
     34: call    fn1
     39: nop     [rcx-78h]
     40: jmp     0A1h
     42: nop     [rax+rax]
     4b: nop     [rax+rax]
     50: mov     rax,[rbp+10h]
     54: mov     [rbp-38h],rax
     58: mov     rax,[rbp+18h]
     5c: mov     [rbp-30h],rax
     60: mov     rax,[rbp-38h]
     64: mov     [rbp-68h],rax
     68: mov     rax,[rbp-10h]
     6c: mov     [rbp-40h],rax
     70: mov     rax,[rbp-40h]
     74: mov     [rbp-70h],rax
     78: mov     byte ptr [rbp-81h],1
     7f: test    byte ptr [rbp-81h],0FFh
     86: je      134h
     8c: jmp     0D0h
     8e: xchg    ax,ax
     90: mov     edi,0FFFFFFE8h
     95: mov     esi,18h
     9a: call    ryo_h_Ret
     9f: leave
     a0: ret
     a1: mov     edi,0FFFFFF98h
     a6: mov     esi,0FFFFFF88h
     ab: call    ryo_h_MovW128
     b0: mov     edi,0FFFFFFE8h
     b5: mov     esi,0FFFFFF98h
     ba: call    ryo_h_MovW128
     bf: mov     qword ptr [rbp-8],0
     c7: cmp     qword ptr [rbp-58h],0
     cc: ja      50h
     ce: jmp     90h
     d0: mov     rax,[rbp-38h]
     d4: mov     [rbp-78h],rax
     d8: mov     rax,[rbp-40h]
     dc: mov     [rbp-80h],rax
     e0: mov     rax,[rbp-78h]
     e4: mov     [rbp-0C0h],rax
     eb: mov     rax,[rbp-80h]
     ef: mov     [rbp-0B8h],rax
     f6: mov     qword ptr [rbp-0B0h],4
    101: mov     qword ptr [rbp-0A8h],4
    10c: mov     rax,[rbp-58h]
    110: mov     [rbp-0A0h],rax
    117: mov     edi,0FFFFFF68h
    11c: lea     rsi,[k2]
    123: call    ryo_h_AddrAbs
    128: call    fn3
    12d: nop     [rcx-40h]
    134: imul    rax,[rbp-58h],4
    139: mov     [rbp-88h],rax
    140: mov     edi,0FFFFFF90h
    145: mov     esi,0FFFFFF98h
    14a: mov     edx,0FFFFFF78h
    14f: call    ryo_h_Memcpy
    154: mov     byte ptr [rbp-81h],1
    15b: test    byte ptr [rbp-81h],0FFh
    162: je      180h
    164: mov     qword ptr [rbp-88h],4
    16f: cmp     qword ptr [rbp-88h],0
    177: je      1C5h
    179: jmp     1CFh
    17b: nop     [rax+rax]
    180: mov     rax,[rbp-58h]
    184: mov     [rbp-8],rax
    188: jmp     90h
    18d: nop     [rax]
    190: mov     rax,[rbp-58h]
    194: mov     [rbp-0C0h],rax
    19b: mov     rax,[rbp-68h]
    19f: mov     [rbp-0B8h],rax
    1a6: mov     edi,0FFFFFF50h
    1ab: lea     rsi,[k4]
    1b2: call    ryo_h_AddrAbs
    1b7: call    fn5
    1bc: nop     [rcx-40h]
    1c3: jmp     180h
    1c5: mov     qword ptr [rbp-68h],0FFFFFFFFFFFFFFFFh
    1cd: jmp     190h
    1cf: mov     rax,[rbp-18h]
    1d3: mov     [rbp-70h],rax
    1d7: mov     rax,[rbp-70h]
    1db: mov     [rbp-68h],rax
    1df: jmp     190h

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
     1e: mov     rax,[rbp-28h]
     22: cmp     rax,[rbp-20h]
     26: jb      5Dh
     28: mov     rax,[rbp-28h]
     2c: sub     rax,[rbp-20h]
     30: mov     [rbp-38h],rax
     34: mov     rax,[rbp-38h]
     38: mov     [rbp-40h],rax
     3c: mov     qword ptr [rbp-48h],1
     44: mov     rax,[rbp-38h]
     48: mov     [rbp-18h],rax
     4c: mov     edi,0FFFFFFF0h
     51: mov     esi,0FFFFFFB8h
     56: call    ryo_h_MovW128
     5b: jmp     7Bh
     5d: mov     qword ptr [rbp-18h],0
     65: mov     edi,0FFFFFFF0h
     6a: lea     rsi,[k0]
     71: mov     edx,10h
     76: call    ryo_h_Const
     7b: mov     edi,0FFFFFFE8h
     80: mov     esi,18h
     85: call    ryo_h_Ret
     8a: leave
     8b: ret

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp+20h]
     14: cmp     rax,[rbp-10h]
     18: jb      71h
     1a: mov     rax,[rbp+20h]
     1e: mov     [rbp-40h],rax
     22: mov     rax,[rbp-10h]
     26: mov     [rbp-38h],rax
     2a: mov     rax,[rbp+28h]
     2e: mov     [rbp-30h],rax
     32: lea     rdi,[sym0]
     39: lea     rsi,[site1]
     40: mov     edx,0FFFFFFE0h
     45: call    ryo_h_CallExt
     4a: test    rax,rax
     4d: je      5Ah
     4f: call    rax
     51: nop     [rcx-11h]
     58: jmp     6Ah
     5a: mov     rdi,rbp
     5d: lea     rsi,[ro+4]
     64: call    qword ptr [sym2]
     6a: call    ryo_h_Unreachable
     6f: ud2
     71: mov     rax,[rbp+10h]
     75: imul    rcx,[rbp+20h],8
     7a: add     rax,rcx
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp-20h]
     85: mov     [rbp-8],rax
     89: mov     edi,0FFFFFFF8h
     8e: mov     esi,8
     93: call    ryo_h_Ret
     98: leave
     99: ret

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
     51: mov     rax,[rbp-38h]
     55: mov     [rbp-30h],rax
     59: mov     edi,0FFFFFFA0h
     5e: lea     rsi,[k1]
     65: call    ryo_h_AddrAbs
     6a: mov     qword ptr [rbp-58h],0D6h
     72: mov     rax,[rbp-58h]
     76: mov     [rbp-50h],rax
     7a: mov     rax,[rbp-50h]
     7e: shl     rax,1
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp-48h]
     8a: or      rax,1
     8e: mov     [rbp-40h],rax
     92: mov     rax,[rbp-40h]
     96: mov     [rbp-38h],rax
     9a: mov     rax,[rbp-30h]
     9e: mov     [rbp-28h],rax
     a2: mov     rax,[rbp-38h]
     a6: mov     [rbp-20h],rax
     aa: mov     edi,0FFFFFF70h
     af: mov     esi,0FFFFFFD8h
     b4: call    ryo_h_MovW128
     b9: mov     byte ptr [rbp-80h],0
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-78h],rax
     c5: lea     rdi,[sym2]
     cc: lea     rsi,[site3]
     d3: mov     edx,0FFFFFF98h
     d8: call    ryo_h_CallExt
     dd: test    rax,rax
     e0: je      0EDh
     e2: call    rax
     e4: nop     [rcx-10h]
     eb: jmp     0FDh
     ed: mov     rdi,rbp
     f0: lea     rsi,[ro+4]
     f7: call    qword ptr [sym4]
     fd: call    ryo_h_Unreachable
    102: ud2

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: lea     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp-10h]
     14: mov     [rbp-20h],rax
     18: call    fn0
     1d: nop     [rcx-4]
     24: mov     edi,0FFFFFFFCh
     29: mov     esi,4
     2e: call    ryo_h_Ret
     33: leave
     34: ret
     35: nop     [rax+rax]
     3e: xchg    ax,ax
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
     20: cmp     dword ptr [rbp-1Ch],40h
     24: jb      76h
     26: mov     edi,0FFFFFF90h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: lea     rdi,[sym1]
     3e: lea     rsi,[site2]
     45: mov     edx,0FFFFFFA8h
     4a: call    ryo_h_CallExt
     4f: test    rax,rax
     52: je      5Fh
     54: call    rax
     56: nop     [rcx-4Dh]
     5d: jmp     6Fh
     5f: mov     rdi,rbp
     62: lea     rsi,[ro+4]
     69: call    qword ptr [sym3]
     6f: call    ryo_h_Unreachable
     74: ud2
     76: mov     rax,[rbp-18h]
     7a: shl     rax,0Dh
     7e: mov     [rbp-10h],rax
     82: mov     rax,[rbp+10h]
     86: mov     rax,[rax]
     89: mov     [rbp-58h],rax
     8d: mov     rax,[rbp-58h]
     91: xor     rax,[rbp-10h]
     95: mov     [rbp-60h],rax
     99: mov     rax,[rbp+10h]
     9d: mov     rcx,[rbp-60h]
     a1: mov     [rax],rcx
     a4: mov     rax,[rbp+10h]
     a8: mov     rax,[rax]
     ab: mov     [rbp-30h],rax
     af: mov     dword ptr [rbp-54h],7
     b6: mov     eax,[rbp-54h]
     b9: mov     [rbp-34h],eax
     bc: cmp     dword ptr [rbp-34h],40h
     c0: jb      112h
     c2: mov     edi,0FFFFFF90h
     c7: lea     rsi,[k4]
     ce: call    ryo_h_AddrAbs
     d3: lea     rdi,[sym5]
     da: lea     rsi,[site6]
     e1: mov     edx,0FFFFFFA8h
     e6: call    ryo_h_CallExt
     eb: test    rax,rax
     ee: je      0FBh
     f0: call    rax
     f2: nop     [rcx-4Dh]
     f9: jmp     10Bh
     fb: mov     rdi,rbp
     fe: lea     rsi,[ro+4]
    105: call    qword ptr [sym7]
    10b: call    ryo_h_Unreachable
    110: ud2
    112: mov     rax,[rbp-30h]
    116: shr     rax,7
    11a: mov     [rbp-28h],rax
    11e: mov     rax,[rbp+10h]
    122: mov     rax,[rax]
    125: mov     [rbp-58h],rax
    129: mov     rax,[rbp-58h]
    12d: xor     rax,[rbp-28h]
    131: mov     [rbp-60h],rax
    135: mov     rax,[rbp+10h]
    139: mov     rcx,[rbp-60h]
    13d: mov     [rax],rcx
    140: mov     rax,[rbp+10h]
    144: mov     rax,[rax]
    147: mov     [rbp-48h],rax
    14b: mov     dword ptr [rbp-54h],11h
    152: mov     eax,[rbp-54h]
    155: mov     [rbp-4Ch],eax
    158: cmp     dword ptr [rbp-4Ch],40h
    15c: jb      1AEh
    15e: mov     edi,0FFFFFF90h
    163: lea     rsi,[k8]
    16a: call    ryo_h_AddrAbs
    16f: lea     rdi,[sym9]
    176: lea     rsi,[site10]
    17d: mov     edx,0FFFFFFA8h
    182: call    ryo_h_CallExt
    187: test    rax,rax
    18a: je      197h
    18c: call    rax
    18e: nop     [rcx-4Dh]
    195: jmp     1A7h
    197: mov     rdi,rbp
    19a: lea     rsi,[ro+4]
    1a1: call    qword ptr [sym11]
    1a7: call    ryo_h_Unreachable
    1ac: ud2
    1ae: mov     rax,[rbp-48h]
    1b2: shl     rax,11h
    1b6: mov     [rbp-40h],rax
    1ba: mov     rax,[rbp+10h]
    1be: mov     rax,[rax]
    1c1: mov     [rbp-58h],rax
    1c5: mov     rax,[rbp-58h]
    1c9: xor     rax,[rbp-40h]
    1cd: mov     [rbp-60h],rax
    1d1: mov     rax,[rbp+10h]
    1d5: mov     rcx,[rbp-60h]
    1d9: mov     [rax],rcx
    1dc: mov     rax,[rbp+10h]
    1e0: mov     rax,[rax]
    1e3: mov     [rbp-8],rax
    1e7: mov     edi,0FFFFFFF8h
    1ec: mov     esi,8
    1f1: call    ryo_h_Ret
    1f6: leave
    1f7: ret

fn alloc::raw_vec::RawVec::<u32>::grow_one
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     rax,[rax]
     17: mov     [rbp-28h],rax
     1b: mov     rax,[rbp-28h]
     1f: mov     [rbp-20h],rax
     23: mov     rax,[rbp-8]
     27: mov     [rbp-60h],rax
     2b: mov     rax,[rbp-20h]
     2f: mov     [rbp-58h],rax
     33: mov     qword ptr [rbp-50h],1
     3b: mov     edi,0FFFFFFB8h
     40: lea     rsi,[k0]
     47: mov     edx,10h
     4c: call    ryo_h_Const
     51: lea     rdi,[sym1]
     58: lea     rsi,[site2]
     5f: mov     edx,0FFFFFFC8h
     64: call    ryo_h_CallExt
     69: test    rax,rax
     6c: je      79h
     6e: call    rax
     70: nop     [rcx-18h]
     77: jmp     89h
     79: mov     rdi,rbp
     7c: lea     rsi,[ro+4]
     83: call    qword ptr [sym3]
     89: mov     edi,0FFFFFFCCh
     8e: mov     esi,0FFFFFFE8h
     93: mov     rdx,0FFFFFFFFFFFFFFFFh
     9a: xor     ecx,ecx
     9c: xor     r8d,r8d
     9f: mov     r9d,1
     a5: call    ryo_h_DiscrNicheW64
     aa: mov     edi,0FFFFFFD0h
     af: mov     esi,0FFFFFFCCh
     b4: call    ryo_h_ZextW32W64
     b9: mov     edi,0FFFFFFD0h
     be: xor     esi,esi
     c0: mov     edx,2
     c5: call    ryo_h_SwitchDenseW64
     ca: lea     rcx,[0DCh]
     d1: movsxd  rax,[rcx+rax*4]
     d5: add     rax,rcx
     d8: jmp     rax
     da: int3
     db: int3
     dc: .long   145h
     e0: .long   e8h
     e4: .long   150h
     e8: mov     edi,0FFFFFFD8h
     ed: mov     esi,0FFFFFFE8h
     f2: call    ryo_h_MovW128
     f7: mov     edi,0FFFFFFA0h
     fc: mov     esi,0FFFFFFD8h
    101: call    ryo_h_MovW128
    106: lea     rdi,[sym4]
    10d: lea     rsi,[site5]
    114: mov     edx,0FFFFFFC8h
    119: call    ryo_h_CallExt
    11e: test    rax,rax
    121: je      12Eh
    123: call    rax
    125: nop     [rcx]
    12c: jmp     13Eh
    12e: mov     rdi,rbp
    131: lea     rsi,[ro+20]
    138: call    qword ptr [sym6]
    13e: call    ryo_h_Unreachable
    143: ud2
    145: xor     edi,edi
    147: xor     esi,esi
    149: call    ryo_h_Ret
    14e: leave
    14f: ret
    150: call    ryo_h_Unreachable
    155: ud2

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
    117: cmp     qword ptr [rbp-60h],0
    11c: je      14Eh
    11e: jmp     158h
    120: mov     rax,[rbp-58h]
    124: sub     rax,0
    128: mov     [rbp-50h],rax
    12c: mov     rax,[rbp-50h]
    130: cmp     rax,[rbp+10h]
    134: setb    [rbp-42h]
    138: movzx   eax,byte ptr [rbp-42h]
    13c: xor     al,1
    13f: mov     [rbp-41h],al
    142: mov     byte ptr [rbp-69h],1
    146: test    byte ptr [rbp-69h],0FFh
    14a: je      191h
    14c: jmp     16Ah
    14e: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    156: jmp     120h
    158: mov     rax,[rbp-10h]
    15c: mov     [rbp-68h],rax
    160: mov     rax,[rbp-68h]
    164: mov     [rbp-58h],rax
    168: jmp     120h
    16a: movzx   eax,byte ptr [rbp-41h]
    16e: mov     [rbp-90h],al
    174: mov     edi,0FFFFFF78h
    179: lea     rsi,[k6]
    180: call    ryo_h_AddrAbs
    185: call    fn7
    18a: nop     [rcx-28h]
    191: mov     edi,0FFFFFFF0h
    196: mov     esi,10h
    19b: call    ryo_h_Ret
    1a0: leave
    1a1: ret

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
     18: mov     rax,[rbp-40h]
     1c: mov     eax,[rax]
     1e: mov     [rbp-14h],eax
     21: mov     rax,[rbp+18h]
     25: mov     [rbp-50h],rax
     29: mov     qword ptr [rbp-48h],1Fh
     31: call    fn0
     36: nop     [rcx-20h]
     3d: mov     edi,0FFFFFFD0h
     42: mov     esi,0FFFFFFECh
     47: call    ryo_h_ZextW32W64
     4c: mov     rax,[rbp-10h]
     50: mov     [rbp-38h],rax
     54: mov     rax,[rbp-30h]
     58: xor     rax,[rbp-38h]
     5c: mov     [rbp-28h],rax
     60: mov     rax,[rbp-20h]
     64: mov     [rbp-50h],rax
     68: mov     rax,[rbp-28h]
     6c: mov     [rbp-48h],rax
     70: call    fn1
     75: nop     [rcx-8]
     7c: mov     edi,0FFFFFFF8h
     81: mov     esi,8
     86: call    ryo_h_Ret
     8b: leave
     8c: ret

fn core::fmt::num::<impl std::fmt::Debug for u32>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     eax,[rax+10h]
      f: mov     [rbp-0Ch],eax
     12: mov     eax,[rbp-0Ch]
     15: and     eax,2000000h
     1b: mov     [rbp-8],eax
     1e: cmp     dword ptr [rbp-8],0
     22: setne   [rbp-2]
     26: test    byte ptr [rbp-2],0FFh
     2a: je      79h
     2c: mov     rax,[rbp+10h]
     30: mov     [rbp-30h],rax
     34: mov     rax,[rbp+18h]
     38: mov     [rbp-28h],rax
     3c: lea     rdi,[sym0]
     43: lea     rsi,[site1]
     4a: mov     edx,0FFFFFFE8h
     4f: call    ryo_h_CallExt
     54: test    rax,rax
     57: je      64h
     59: call    rax
     5b: nop     [rcx-1]
     62: jmp     74h
     64: mov     rdi,rbp
     67: lea     rsi,[ro+4]
     6e: call    qword ptr [sym2]
     74: jmp     12Fh
     79: mov     rax,[rbp+18h]
     7d: mov     eax,[rax+10h]
     80: mov     [rbp-0Ch],eax
     83: mov     eax,[rbp-0Ch]
     86: and     eax,4000000h
     8c: mov     [rbp-8],eax
     8f: cmp     dword ptr [rbp-8],0
     93: setne   [rbp-3]
     97: test    byte ptr [rbp-3],0FFh
     9b: je      0E7h
     9d: mov     rax,[rbp+10h]
     a1: mov     [rbp-30h],rax
     a5: mov     rax,[rbp+18h]
     a9: mov     [rbp-28h],rax
     ad: lea     rdi,[sym3]
     b4: lea     rsi,[site4]
     bb: mov     edx,0FFFFFFE8h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-1]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+4]
     df: call    qword ptr [sym5]
     e5: jmp     12Fh
     e7: mov     rax,[rbp+10h]
     eb: mov     [rbp-30h],rax
     ef: mov     rax,[rbp+18h]
     f3: mov     [rbp-28h],rax
     f7: lea     rdi,[sym6]
     fe: lea     rsi,[site7]
    105: mov     edx,0FFFFFFE8h
    10a: call    ryo_h_CallExt
    10f: test    rax,rax
    112: je      11Fh
    114: call    rax
    116: nop     [rcx-1]
    11d: jmp     12Fh
    11f: mov     rdi,rbp
    122: lea     rsi,[ro+4]
    129: call    qword ptr [sym8]
    12f: mov     edi,0FFFFFFFFh
    134: mov     esi,1
    139: call    ryo_h_Ret
    13e: leave
    13f: ret

fn core::fmt::rt::Argument::<'_>::new_debug::<(u32, u32)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFC0h
     1d: lea     rsi,[sym0]
     24: call    ryo_h_AddrSym
     29: mov     rax,[rbp-40h]
     2d: mov     [rbp-38h],rax
     31: mov     rax,[rbp-30h]
     35: mov     [rbp-28h],rax
     39: mov     rax,[rbp-38h]
     3d: mov     [rbp-20h],rax
     41: mov     edi,0FFFFFFF0h
     46: mov     esi,0FFFFFFD8h
     4b: call    ryo_h_MovW128
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,10h
     5a: call    ryo_h_Ret
     5f: leave
     60: ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFC0h
     1d: lea     rsi,[sym0]
     24: call    ryo_h_AddrSym
     29: mov     rax,[rbp-40h]
     2d: mov     [rbp-38h],rax
     31: mov     rax,[rbp-30h]
     35: mov     [rbp-28h],rax
     39: mov     rax,[rbp-38h]
     3d: mov     [rbp-20h],rax
     41: mov     edi,0FFFFFFF0h
     46: mov     esi,0FFFFFFD8h
     4b: call    ryo_h_MovW128
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,10h
     5a: call    ryo_h_Ret
     5f: leave
     60: ret

fn core::fmt::rt::Argument::<'_>::new_lower_hex::<u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFC0h
     1d: lea     rsi,[sym0]
     24: call    ryo_h_AddrSym
     29: mov     rax,[rbp-40h]
     2d: mov     [rbp-38h],rax
     31: mov     rax,[rbp-30h]
     35: mov     [rbp-28h],rax
     39: mov     rax,[rbp-38h]
     3d: mov     [rbp-20h],rax
     41: mov     edi,0FFFFFFF0h
     46: mov     esi,0FFFFFFD8h
     4b: call    ryo_h_MovW128
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,10h
     5a: call    ryo_h_Ret
     5f: leave
     60: ret

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
     3f: je      129h
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
     76: mov     rax,[rbp-38h]
     7a: mov     [rbp-30h],rax
     7e: mov     edi,0FFFFFFA0h
     83: lea     rsi,[k1]
     8a: call    ryo_h_AddrAbs
     8f: mov     qword ptr [rbp-58h],0BAh
     97: mov     rax,[rbp-58h]
     9b: mov     [rbp-50h],rax
     9f: mov     rax,[rbp-50h]
     a3: shl     rax,1
     a7: mov     [rbp-48h],rax
     ab: mov     rax,[rbp-48h]
     af: or      rax,1
     b3: mov     [rbp-40h],rax
     b7: mov     rax,[rbp-40h]
     bb: mov     [rbp-38h],rax
     bf: mov     rax,[rbp-30h]
     c3: mov     [rbp-28h],rax
     c7: mov     rax,[rbp-38h]
     cb: mov     [rbp-20h],rax
     cf: mov     edi,0FFFFFF70h
     d4: mov     esi,0FFFFFFD8h
     d9: call    ryo_h_MovW128
     de: mov     byte ptr [rbp-80h],0
     e2: mov     rax,[rbp+20h]
     e6: mov     [rbp-78h],rax
     ea: lea     rdi,[sym2]
     f1: lea     rsi,[site3]
     f8: mov     edx,0FFFFFF98h
     fd: call    ryo_h_CallExt
    102: test    rax,rax
    105: je      112h
    107: call    rax
    109: nop     [rcx-10h]
    110: jmp     122h
    112: mov     rdi,rbp
    115: lea     rsi,[ro+4]
    11c: call    qword ptr [sym4]
    122: call    ryo_h_Unreachable
    127: ud2
    129: xor     edi,edi
    12b: xor     esi,esi
    12d: call    ryo_h_Ret
    132: leave
    133: ret

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
     3f: je      129h
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
     76: mov     rax,[rbp-38h]
     7a: mov     [rbp-30h],rax
     7e: mov     edi,0FFFFFFA0h
     83: lea     rsi,[k1]
     8a: call    ryo_h_AddrAbs
     8f: mov     qword ptr [rbp-58h],0BAh
     97: mov     rax,[rbp-58h]
     9b: mov     [rbp-50h],rax
     9f: mov     rax,[rbp-50h]
     a3: shl     rax,1
     a7: mov     [rbp-48h],rax
     ab: mov     rax,[rbp-48h]
     af: or      rax,1
     b3: mov     [rbp-40h],rax
     b7: mov     rax,[rbp-40h]
     bb: mov     [rbp-38h],rax
     bf: mov     rax,[rbp-30h]
     c3: mov     [rbp-28h],rax
     c7: mov     rax,[rbp-38h]
     cb: mov     [rbp-20h],rax
     cf: mov     edi,0FFFFFF70h
     d4: mov     esi,0FFFFFFD8h
     d9: call    ryo_h_MovW128
     de: mov     byte ptr [rbp-80h],0
     e2: mov     rax,[rbp+20h]
     e6: mov     [rbp-78h],rax
     ea: lea     rdi,[sym2]
     f1: lea     rsi,[site3]
     f8: mov     edx,0FFFFFF98h
     fd: call    ryo_h_CallExt
    102: test    rax,rax
    105: je      112h
    107: call    rax
    109: nop     [rcx-10h]
    110: jmp     122h
    112: mov     rdi,rbp
    115: lea     rsi,[ro+4]
    11c: call    qword ptr [sym4]
    122: call    ryo_h_Unreachable
    127: ud2
    129: xor     edi,edi
    12b: xor     esi,esi
    12d: call    ryo_h_Ret
    132: leave
    133: ret

fn core::panicking::assert_failed::<std::vec::Vec<u32>, std::vec::Vec<u32>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: lea     rax,[rbp+10h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp-18h]
     17: mov     [rbp-10h],rax
     1b: mov     edi,0FFFFFFF8h
     20: lea     rsi,[k0]
     27: call    ryo_h_AddrAbs
     2c: lea     rax,[rbp+18h]
     30: mov     [rbp-30h],rax
     34: mov     rax,[rbp-30h]
     38: mov     [rbp-28h],rax
     3c: mov     edi,0FFFFFFE0h
     41: lea     rsi,[k1]
     48: call    ryo_h_AddrAbs
     4d: movzx   eax,byte ptr [rbp+30h]
     51: mov     [rbp-50h],al
     54: mov     edi,0FFFFFF80h
     59: mov     esi,0FFFFFFF0h
     5e: call    ryo_h_MovW128
     63: mov     edi,0FFFFFF90h
     68: mov     esi,0FFFFFFD8h
     6d: call    ryo_h_MovW128
     72: mov     edi,0FFFFFFA0h
     77: mov     esi,20h
     7c: call    ryo_h_MovW128
     81: mov     rax,[rbp+38h]
     85: mov     [rbp-48h],rax
     89: lea     rdi,[sym2]
     90: lea     rsi,[site3]
     97: mov     edx,0FFFFFFC8h
     9c: call    ryo_h_CallExt
     a1: test    rax,rax
     a4: je      0B1h
     a6: call    rax
     a8: nop     [rcx]
     af: jmp     0C1h
     b1: mov     rdi,rbp
     b4: lea     rsi,[ro+4]
     bb: call    qword ptr [sym4]
     c1: call    ryo_h_Unreachable
     c6: ud2

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
     47: mov     rax,[rbp-30h]
     4b: imul    rcx,[rbp-8],8
     50: add     rax,rcx
     53: mov     [rbp-38h],rax
     57: mov     byte ptr [rbp-69h],1
     5b: test    byte ptr [rbp-69h],0FFh
     5f: je      0CCh
     61: jmp     7Bh
     63: nop     [rax+rax]
     6c: nop     [rax]
     70: xor     edi,edi
     72: xor     esi,esi
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: mov     rax,[rbp-48h]
     7f: mov     [rbp-58h],rax
     83: mov     rax,[rbp-58h]
     87: mov     [rbp-0A0h],rax
     8e: mov     qword ptr [rbp-98h],8
     99: mov     qword ptr [rbp-90h],4
     a4: mov     rax,[rbp-50h]
     a8: mov     [rbp-88h],rax
     af: mov     edi,0FFFFFF80h
     b4: lea     rsi,[k0]
     bb: call    ryo_h_AddrAbs
     c0: call    fn1
     c5: nop     [rcx-48h]
     cc: mov     rax,[rbp-30h]
     d0: mov     [rbp-60h],rax
     d4: mov     rax,[rbp-50h]
     d8: mov     [rbp-58h],rax
     dc: mov     rax,[rbp-60h]
     e0: mov     [rbp-18h],rax
     e4: mov     rax,[rbp-58h]
     e8: mov     [rbp-10h],rax
     ec: mov     byte ptr [rbp-69h],0
     f0: test    byte ptr [rbp-69h],0FFh
     f4: je      11Ah
     f6: jmp     110h
     f8: nop     [rax+rax]
    100: mov     byte ptr [rbp-69h],1
    104: test    byte ptr [rbp-69h],0FFh
    108: je      199h
    10e: jmp     148h
    110: mov     rax,[rbp-38h]
    114: mov     [rbp-58h],rax
    118: jmp     100h
    11a: mov     rax,[rbp-50h]
    11e: mov     [rbp-68h],rax
    122: mov     qword ptr [rbp-70h],0
    12a: mov     rax,[rbp-70h]
    12e: sub     rax,[rbp-68h]
    132: mov     [rbp-60h],rax
    136: mov     rax,[rbp-38h]
    13a: imul    rcx,[rbp-60h],8
    13f: add     rax,rcx
    142: mov     [rbp-58h],rax
    146: jmp     100h
    148: mov     rax,[rbp-58h]
    14c: mov     [rbp-60h],rax
    150: mov     rax,[rbp-60h]
    154: mov     [rbp-0A0h],rax
    15b: mov     qword ptr [rbp-98h],8
    166: mov     qword ptr [rbp-90h],4
    171: mov     rax,[rbp-50h]
    175: mov     [rbp-88h],rax
    17c: mov     edi,0FFFFFF80h
    181: lea     rsi,[k2]
    188: call    ryo_h_AddrAbs
    18d: call    fn3
    192: nop     [rcx-48h]
    199: mov     rax,[rbp-58h]
    19d: mov     [rbp-68h],rax
    1a1: mov     rax,[rbp-50h]
    1a5: mov     [rbp-60h],rax
    1a9: mov     rax,[rbp-68h]
    1ad: mov     [rbp-28h],rax
    1b1: mov     rax,[rbp-60h]
    1b5: mov     [rbp-20h],rax
    1b9: mov     edi,0FFFFFF60h
    1be: mov     esi,0FFFFFFE8h
    1c3: call    ryo_h_MovW128
    1c8: mov     edi,0FFFFFF70h
    1cd: mov     esi,0FFFFFFD8h
    1d2: call    ryo_h_MovW128
    1d7: mov     rax,[rbp-50h]
    1db: mov     [rbp-80h],rax
    1df: call    fn4
    1e4: nop     [rcx-28h]
    1eb: jmp     70h

fn core::slice::<impl [(u32, u32)]>::split_at_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-50h],rax
     13: mov     rax,[rbp-50h]
     17: cmp     rax,[rbp+20h]
     1b: jb      8Dh
     1d: mov     edi,0FFFFFF40h
     22: mov     esi,10h
     27: call    ryo_h_MovW128
     2c: mov     rax,[rbp+20h]
     30: mov     [rbp-0B0h],rax
     37: mov     edi,0FFFFFF58h
     3c: lea     rsi,[k0]
     43: call    ryo_h_AddrAbs
     48: call    fn1
     4d: nop     [rcx-68h]
     54: mov     edi,0FFFFFFC0h
     59: mov     esi,0FFFFFF98h
     5e: mov     edx,20h
     63: call    ryo_h_Copy
     68: mov     edi,0FFFFFFE0h
     6d: mov     esi,0FFFFFFC0h
     72: mov     edx,20h
     77: call    ryo_h_Copy
     7c: mov     edi,0FFFFFFE0h
     81: mov     esi,20h
     86: call    ryo_h_Ret
     8b: leave
     8c: ret
     8d: mov     edi,0FFFFFFA0h
     92: lea     rsi,[k2]
     99: call    ryo_h_AddrAbs
     9e: mov     qword ptr [rbp-58h],9
     a6: mov     rax,[rbp-60h]
     aa: mov     [rbp-80h],rax
     ae: mov     rax,[rbp-58h]
     b2: mov     [rbp-78h],rax
     b6: mov     rax,[rbp-80h]
     ba: mov     [rbp-70h],rax
     be: mov     rax,[rbp-70h]
     c2: mov     [rbp-68h],rax
     c6: mov     edi,0FFFFFF68h
     cb: lea     rsi,[k3]
     d2: call    ryo_h_AddrAbs
     d7: mov     qword ptr [rbp-90h],9
     e2: mov     rax,[rbp-90h]
     e9: mov     [rbp-88h],rax
     f0: mov     rax,[rbp-88h]
     f7: shl     rax,1
     fb: mov     [rbp-80h],rax
     ff: mov     rax,[rbp-80h]
    103: or      rax,1
    107: mov     [rbp-78h],rax
    10b: mov     rax,[rbp-78h]
    10f: mov     [rbp-70h],rax
    113: mov     rax,[rbp-68h]
    117: mov     [rbp-50h],rax
    11b: mov     rax,[rbp-70h]
    11f: mov     [rbp-48h],rax
    123: mov     edi,0FFFFFF40h
    128: mov     esi,0FFFFFFB0h
    12d: call    ryo_h_MovW128
    132: mov     rax,[rbp+28h]
    136: mov     [rbp-0B0h],rax
    13d: lea     rdi,[sym4]
    144: lea     rsi,[site5]
    14b: mov     edx,0FFFFFF60h
    150: call    ryo_h_CallExt
    155: test    rax,rax
    158: je      165h
    15a: call    rax
    15c: nop     [rcx-20h]
    163: jmp     175h
    165: mov     rdi,rbp
    168: lea     rsi,[ro+4]
    16f: call    qword ptr [sym6]
    175: call    ryo_h_Unreachable
    17a: ud2

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
     76: je      0C3h
     78: mov     rax,[rbp-30h]
     7c: mov     [rbp-58h],rax
     80: mov     rax,[rbp-58h]
     84: mov     [rbp-0B0h],rax
     8b: mov     qword ptr [rbp-0A8h],8
     96: mov     qword ptr [rbp-0A0h],4
     a1: mov     rax,[rbp+20h]
     a5: mov     [rbp-98h],rax
     ac: mov     rax,[rbp+28h]
     b0: mov     [rbp-90h],rax
     b7: call    fn1
     bc: nop     [rcx-30h]
     c3: mov     rax,[rbp-40h]
     c7: mov     [rbp-60h],rax
     cb: mov     rax,[rbp+20h]
     cf: mov     [rbp-58h],rax
     d3: mov     rax,[rbp-60h]
     d7: mov     [rbp-50h],rax
     db: mov     rax,[rbp-58h]
     df: mov     [rbp-48h],rax
     e3: mov     rax,[rbp-40h]
     e7: imul    rcx,[rbp+20h],8
     ec: add     rax,rcx
     ef: mov     [rbp-68h],rax
     f3: mov     rax,[rbp-38h]
     f7: sub     rax,[rbp+20h]
     fb: mov     [rbp-70h],rax
     ff: mov     byte ptr [rbp-81h],1
    106: test    byte ptr [rbp-81h],0FFh
    10d: je      15Ah
    10f: mov     rax,[rbp-68h]
    113: mov     [rbp-78h],rax
    117: mov     rax,[rbp-78h]
    11b: mov     [rbp-0B0h],rax
    122: mov     qword ptr [rbp-0A8h],8
    12d: mov     qword ptr [rbp-0A0h],4
    138: mov     rax,[rbp-70h]
    13c: mov     [rbp-98h],rax
    143: mov     rax,[rbp+28h]
    147: mov     [rbp-90h],rax
    14e: call    fn2
    153: nop     [rcx-30h]
    15a: mov     rax,[rbp-68h]
    15e: mov     [rbp-80h],rax
    162: mov     rax,[rbp-70h]
    166: mov     [rbp-78h],rax
    16a: mov     rax,[rbp-80h]
    16e: mov     [rbp-60h],rax
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-58h],rax
    17a: mov     edi,0FFFFFFE0h
    17f: mov     esi,0FFFFFFB0h
    184: call    ryo_h_MovW128
    189: mov     edi,0FFFFFFF0h
    18e: mov     esi,0FFFFFFA0h
    193: call    ryo_h_MovW128
    198: mov     edi,0FFFFFFE0h
    19d: mov     esi,20h
    1a2: call    ryo_h_Ret
    1a7: leave
    1a8: ret

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
     a8: mov     rax,[rbp-60h]
     ac: cmp     rax,[rbp+30h]
     b0: jae     25Bh
     b6: mov     rax,[rbp-58h]
     ba: mov     [rbp-60h],rax
     be: mov     rax,[rbp-38h]
     c2: mov     [rbp-10h],rax
     c6: mov     rax,[rbp-60h]
     ca: cmp     rax,[rbp-10h]
     ce: jb      136h
     d0: mov     rax,[rbp-60h]
     d4: mov     [rbp-0B0h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-0A8h],rax
     e6: mov     edi,0FFFFFF60h
     eb: lea     rsi,[k4]
     f2: call    ryo_h_AddrAbs
     f7: lea     rdi,[sym5]
     fe: lea     rsi,[site6]
    105: mov     edx,0FFFFFF80h
    10a: call    ryo_h_CallExt
    10f: test    rax,rax
    112: je      11Fh
    114: call    rax
    116: nop     [rcx-78h]
    11d: jmp     12Fh
    11f: mov     rdi,rbp
    122: lea     rsi,[ro+4]
    129: call    qword ptr [sym7]
    12f: call    ryo_h_Unreachable
    134: ud2
    136: mov     rax,[rbp-40h]
    13a: imul    rcx,[rbp-60h],8
    13f: add     rax,rcx
    142: mov     [rbp-80h],rax
    146: mov     rax,[rbp-80h]
    14a: mov     [rbp-8],rax
    14e: mov     rax,[rbp+30h]
    152: sub     rax,1
    156: mov     [rbp-70h],rax
    15a: mov     rax,[rbp-58h]
    15e: mov     [rbp-78h],rax
    162: mov     rax,[rbp-70h]
    166: sub     rax,[rbp-78h]
    16a: mov     [rbp-68h],rax
    16e: mov     rax,[rbp-48h]
    172: mov     [rbp-28h],rax
    176: mov     rax,[rbp-68h]
    17a: cmp     rax,[rbp-28h]
    17e: jb      1E6h
    180: mov     rax,[rbp-68h]
    184: mov     [rbp-0B0h],rax
    18b: mov     rax,[rbp-28h]
    18f: mov     [rbp-0A8h],rax
    196: mov     edi,0FFFFFF60h
    19b: lea     rsi,[k8]
    1a2: call    ryo_h_AddrAbs
    1a7: lea     rdi,[sym9]
    1ae: lea     rsi,[site10]
    1b5: mov     edx,0FFFFFF80h
    1ba: call    ryo_h_CallExt
    1bf: test    rax,rax
    1c2: je      1CFh
    1c4: call    rax
    1c6: nop     [rcx-78h]
    1cd: jmp     1DFh
    1cf: mov     rdi,rbp
    1d2: lea     rsi,[ro+4]
    1d9: call    qword ptr [sym11]
    1df: call    ryo_h_Unreachable
    1e4: ud2
    1e6: mov     rax,[rbp-50h]
    1ea: imul    rcx,[rbp-68h],8
    1ef: add     rax,rcx
    1f2: mov     [rbp-80h],rax
    1f6: mov     rax,[rbp-80h]
    1fa: mov     [rbp-20h],rax
    1fe: mov     rax,[rbp-8]
    202: mov     [rbp-70h],rax
    206: mov     rax,[rbp-20h]
    20a: mov     [rbp-78h],rax
    20e: mov     qword ptr [rbp-88h],8
    219: mov     edi,0FFFFFF80h
    21e: mov     esi,0FFFFFF90h
    223: xor     edx,edx
    225: mov     ecx,8
    22a: call    ryo_h_LoadCopy
    22f: mov     edi,0FFFFFF90h
    234: mov     esi,0FFFFFF88h
    239: mov     edx,0FFFFFF78h
    23e: call    ryo_h_Memcpy
    243: mov     edi,0FFFFFF88h
    248: xor     esi,esi
    24a: mov     edx,0FFFFFF80h
    24f: mov     ecx,8
    254: call    ryo_h_StoreCopy
    259: jmp     266h
    25b: xor     edi,edi
    25d: xor     esi,esi
    25f: call    ryo_h_Ret
    264: leave
    265: ret
    266: mov     rax,[rbp-58h]
    26a: add     rax,1
    26e: mov     [rbp-58h],rax
    272: jmp     0A0h

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
     a8: mov     rax,[rbp-60h]
     ac: cmp     rax,[rbp+30h]
     b0: jae     25Bh
     b6: mov     rax,[rbp-58h]
     ba: mov     [rbp-60h],rax
     be: mov     rax,[rbp-38h]
     c2: mov     [rbp-10h],rax
     c6: mov     rax,[rbp-60h]
     ca: cmp     rax,[rbp-10h]
     ce: jb      136h
     d0: mov     rax,[rbp-60h]
     d4: mov     [rbp-0B0h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-0A8h],rax
     e6: mov     edi,0FFFFFF60h
     eb: lea     rsi,[k4]
     f2: call    ryo_h_AddrAbs
     f7: lea     rdi,[sym5]
     fe: lea     rsi,[site6]
    105: mov     edx,0FFFFFF80h
    10a: call    ryo_h_CallExt
    10f: test    rax,rax
    112: je      11Fh
    114: call    rax
    116: nop     [rcx-78h]
    11d: jmp     12Fh
    11f: mov     rdi,rbp
    122: lea     rsi,[ro+4]
    129: call    qword ptr [sym7]
    12f: call    ryo_h_Unreachable
    134: ud2
    136: mov     rax,[rbp-40h]
    13a: imul    rcx,[rbp-60h],4
    13f: add     rax,rcx
    142: mov     [rbp-80h],rax
    146: mov     rax,[rbp-80h]
    14a: mov     [rbp-8],rax
    14e: mov     rax,[rbp+30h]
    152: sub     rax,1
    156: mov     [rbp-70h],rax
    15a: mov     rax,[rbp-58h]
    15e: mov     [rbp-78h],rax
    162: mov     rax,[rbp-70h]
    166: sub     rax,[rbp-78h]
    16a: mov     [rbp-68h],rax
    16e: mov     rax,[rbp-48h]
    172: mov     [rbp-28h],rax
    176: mov     rax,[rbp-68h]
    17a: cmp     rax,[rbp-28h]
    17e: jb      1E6h
    180: mov     rax,[rbp-68h]
    184: mov     [rbp-0B0h],rax
    18b: mov     rax,[rbp-28h]
    18f: mov     [rbp-0A8h],rax
    196: mov     edi,0FFFFFF60h
    19b: lea     rsi,[k8]
    1a2: call    ryo_h_AddrAbs
    1a7: lea     rdi,[sym9]
    1ae: lea     rsi,[site10]
    1b5: mov     edx,0FFFFFF80h
    1ba: call    ryo_h_CallExt
    1bf: test    rax,rax
    1c2: je      1CFh
    1c4: call    rax
    1c6: nop     [rcx-78h]
    1cd: jmp     1DFh
    1cf: mov     rdi,rbp
    1d2: lea     rsi,[ro+4]
    1d9: call    qword ptr [sym11]
    1df: call    ryo_h_Unreachable
    1e4: ud2
    1e6: mov     rax,[rbp-50h]
    1ea: imul    rcx,[rbp-68h],4
    1ef: add     rax,rcx
    1f2: mov     [rbp-80h],rax
    1f6: mov     rax,[rbp-80h]
    1fa: mov     [rbp-20h],rax
    1fe: mov     rax,[rbp-8]
    202: mov     [rbp-70h],rax
    206: mov     rax,[rbp-20h]
    20a: mov     [rbp-78h],rax
    20e: mov     qword ptr [rbp-88h],4
    219: mov     edi,0FFFFFF80h
    21e: mov     esi,0FFFFFF90h
    223: xor     edx,edx
    225: mov     ecx,4
    22a: call    ryo_h_LoadCopy
    22f: mov     edi,0FFFFFF90h
    234: mov     esi,0FFFFFF88h
    239: mov     edx,0FFFFFF78h
    23e: call    ryo_h_Memcpy
    243: mov     edi,0FFFFFF88h
    248: xor     esi,esi
    24a: mov     edx,0FFFFFF80h
    24f: mov     ecx,4
    254: call    ryo_h_StoreCopy
    259: jmp     266h
    25b: xor     edi,edi
    25d: xor     esi,esi
    25f: call    ryo_h_Ret
    264: leave
    265: ret
    266: mov     rax,[rbp-58h]
    26a: add     rax,1
    26e: mov     [rbp-58h],rax
    272: jmp     0A0h

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
     51: mov     rax,[rbp-38h]
     55: mov     [rbp-30h],rax
     59: mov     edi,0FFFFFFA0h
     5e: lea     rsi,[k1]
     65: call    ryo_h_AddrAbs
     6a: mov     qword ptr [rbp-58h],0DDh
     72: mov     rax,[rbp-58h]
     76: mov     [rbp-50h],rax
     7a: mov     rax,[rbp-50h]
     7e: shl     rax,1
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp-48h]
     8a: or      rax,1
     8e: mov     [rbp-40h],rax
     92: mov     rax,[rbp-40h]
     96: mov     [rbp-38h],rax
     9a: mov     rax,[rbp-30h]
     9e: mov     [rbp-28h],rax
     a2: mov     rax,[rbp-38h]
     a6: mov     [rbp-20h],rax
     aa: mov     edi,0FFFFFF70h
     af: mov     esi,0FFFFFFD8h
     b4: call    ryo_h_MovW128
     b9: mov     byte ptr [rbp-80h],0
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-78h],rax
     c5: lea     rdi,[sym2]
     cc: lea     rsi,[site3]
     d3: mov     edx,0FFFFFF98h
     d8: call    ryo_h_CallExt
     dd: test    rax,rax
     e0: je      0EDh
     e2: call    rax
     e4: nop     [rcx-10h]
     eb: jmp     0FDh
     ed: mov     rdi,rbp
     f0: lea     rsi,[ro+4]
     f7: call    qword ptr [sym4]
     fd: call    ryo_h_Unreachable
    102: ud2

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
     5b: mov     rax,[rbp-38h]
     5f: mov     [rbp-30h],rax
     63: mov     edi,0FFFFFFA0h
     68: lea     rsi,[k1]
     6f: call    ryo_h_AddrAbs
     74: mov     qword ptr [rbp-58h],0DAh
     7c: mov     rax,[rbp-58h]
     80: mov     [rbp-50h],rax
     84: mov     rax,[rbp-50h]
     88: shl     rax,1
     8c: mov     [rbp-48h],rax
     90: mov     rax,[rbp-48h]
     94: or      rax,1
     98: mov     [rbp-40h],rax
     9c: mov     rax,[rbp-40h]
     a0: mov     [rbp-38h],rax
     a4: mov     rax,[rbp-30h]
     a8: mov     [rbp-28h],rax
     ac: mov     rax,[rbp-38h]
     b0: mov     [rbp-20h],rax
     b4: mov     edi,0FFFFFF70h
     b9: mov     esi,0FFFFFFD8h
     be: call    ryo_h_MovW128
     c3: mov     byte ptr [rbp-80h],0
     c7: mov     rax,[rbp+28h]
     cb: mov     [rbp-78h],rax
     cf: lea     rdi,[sym2]
     d6: lea     rsi,[site3]
     dd: mov     edx,0FFFFFF98h
     e2: call    ryo_h_CallExt
     e7: test    rax,rax
     ea: je      0F7h
     ec: call    rax
     ee: nop     [rcx-10h]
     f5: jmp     107h
     f7: mov     rdi,rbp
     fa: lea     rsi,[ro+4]
    101: call    qword ptr [sym4]
    107: call    ryo_h_Unreachable
    10c: ud2

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
     47: mov     rax,[rbp-30h]
     4b: imul    rcx,[rbp-8],4
     50: add     rax,rcx
     53: mov     [rbp-38h],rax
     57: mov     byte ptr [rbp-69h],1
     5b: test    byte ptr [rbp-69h],0FFh
     5f: je      0CCh
     61: jmp     7Bh
     63: nop     [rax+rax]
     6c: nop     [rax]
     70: xor     edi,edi
     72: xor     esi,esi
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: mov     rax,[rbp-48h]
     7f: mov     [rbp-58h],rax
     83: mov     rax,[rbp-58h]
     87: mov     [rbp-0A0h],rax
     8e: mov     qword ptr [rbp-98h],4
     99: mov     qword ptr [rbp-90h],4
     a4: mov     rax,[rbp-50h]
     a8: mov     [rbp-88h],rax
     af: mov     edi,0FFFFFF80h
     b4: lea     rsi,[k0]
     bb: call    ryo_h_AddrAbs
     c0: call    fn1
     c5: nop     [rcx-48h]
     cc: mov     rax,[rbp-30h]
     d0: mov     [rbp-60h],rax
     d4: mov     rax,[rbp-50h]
     d8: mov     [rbp-58h],rax
     dc: mov     rax,[rbp-60h]
     e0: mov     [rbp-18h],rax
     e4: mov     rax,[rbp-58h]
     e8: mov     [rbp-10h],rax
     ec: mov     byte ptr [rbp-69h],0
     f0: test    byte ptr [rbp-69h],0FFh
     f4: je      11Ah
     f6: jmp     110h
     f8: nop     [rax+rax]
    100: mov     byte ptr [rbp-69h],1
    104: test    byte ptr [rbp-69h],0FFh
    108: je      199h
    10e: jmp     148h
    110: mov     rax,[rbp-38h]
    114: mov     [rbp-58h],rax
    118: jmp     100h
    11a: mov     rax,[rbp-50h]
    11e: mov     [rbp-68h],rax
    122: mov     qword ptr [rbp-70h],0
    12a: mov     rax,[rbp-70h]
    12e: sub     rax,[rbp-68h]
    132: mov     [rbp-60h],rax
    136: mov     rax,[rbp-38h]
    13a: imul    rcx,[rbp-60h],4
    13f: add     rax,rcx
    142: mov     [rbp-58h],rax
    146: jmp     100h
    148: mov     rax,[rbp-58h]
    14c: mov     [rbp-60h],rax
    150: mov     rax,[rbp-60h]
    154: mov     [rbp-0A0h],rax
    15b: mov     qword ptr [rbp-98h],4
    166: mov     qword ptr [rbp-90h],4
    171: mov     rax,[rbp-50h]
    175: mov     [rbp-88h],rax
    17c: mov     edi,0FFFFFF80h
    181: lea     rsi,[k2]
    188: call    ryo_h_AddrAbs
    18d: call    fn3
    192: nop     [rcx-48h]
    199: mov     rax,[rbp-58h]
    19d: mov     [rbp-68h],rax
    1a1: mov     rax,[rbp-50h]
    1a5: mov     [rbp-60h],rax
    1a9: mov     rax,[rbp-68h]
    1ad: mov     [rbp-28h],rax
    1b1: mov     rax,[rbp-60h]
    1b5: mov     [rbp-20h],rax
    1b9: mov     edi,0FFFFFF60h
    1be: mov     esi,0FFFFFFE8h
    1c3: call    ryo_h_MovW128
    1c8: mov     edi,0FFFFFF70h
    1cd: mov     esi,0FFFFFFD8h
    1d2: call    ryo_h_MovW128
    1d7: mov     rax,[rbp-50h]
    1db: mov     [rbp-80h],rax
    1df: call    fn4
    1e4: nop     [rcx-28h]
    1eb: jmp     70h

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
     13: mov     rax,[rbp-50h]
     17: cmp     rax,[rbp+20h]
     1b: jb      8Dh
     1d: mov     edi,0FFFFFF40h
     22: mov     esi,10h
     27: call    ryo_h_MovW128
     2c: mov     rax,[rbp+20h]
     30: mov     [rbp-0B0h],rax
     37: mov     edi,0FFFFFF58h
     3c: lea     rsi,[k0]
     43: call    ryo_h_AddrAbs
     48: call    fn1
     4d: nop     [rcx-68h]
     54: mov     edi,0FFFFFFC0h
     59: mov     esi,0FFFFFF98h
     5e: mov     edx,20h
     63: call    ryo_h_Copy
     68: mov     edi,0FFFFFFE0h
     6d: mov     esi,0FFFFFFC0h
     72: mov     edx,20h
     77: call    ryo_h_Copy
     7c: mov     edi,0FFFFFFE0h
     81: mov     esi,20h
     86: call    ryo_h_Ret
     8b: leave
     8c: ret
     8d: mov     edi,0FFFFFFA0h
     92: lea     rsi,[k2]
     99: call    ryo_h_AddrAbs
     9e: mov     qword ptr [rbp-58h],9
     a6: mov     rax,[rbp-60h]
     aa: mov     [rbp-80h],rax
     ae: mov     rax,[rbp-58h]
     b2: mov     [rbp-78h],rax
     b6: mov     rax,[rbp-80h]
     ba: mov     [rbp-70h],rax
     be: mov     rax,[rbp-70h]
     c2: mov     [rbp-68h],rax
     c6: mov     edi,0FFFFFF68h
     cb: lea     rsi,[k3]
     d2: call    ryo_h_AddrAbs
     d7: mov     qword ptr [rbp-90h],9
     e2: mov     rax,[rbp-90h]
     e9: mov     [rbp-88h],rax
     f0: mov     rax,[rbp-88h]
     f7: shl     rax,1
     fb: mov     [rbp-80h],rax
     ff: mov     rax,[rbp-80h]
    103: or      rax,1
    107: mov     [rbp-78h],rax
    10b: mov     rax,[rbp-78h]
    10f: mov     [rbp-70h],rax
    113: mov     rax,[rbp-68h]
    117: mov     [rbp-50h],rax
    11b: mov     rax,[rbp-70h]
    11f: mov     [rbp-48h],rax
    123: mov     edi,0FFFFFF40h
    128: mov     esi,0FFFFFFB0h
    12d: call    ryo_h_MovW128
    132: mov     rax,[rbp+28h]
    136: mov     [rbp-0B0h],rax
    13d: lea     rdi,[sym4]
    144: lea     rsi,[site5]
    14b: mov     edx,0FFFFFF60h
    150: call    ryo_h_CallExt
    155: test    rax,rax
    158: je      165h
    15a: call    rax
    15c: nop     [rcx-20h]
    163: jmp     175h
    165: mov     rdi,rbp
    168: lea     rsi,[ro+4]
    16f: call    qword ptr [sym6]
    175: call    ryo_h_Unreachable
    17a: ud2

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
     76: je      0C3h
     78: mov     rax,[rbp-30h]
     7c: mov     [rbp-58h],rax
     80: mov     rax,[rbp-58h]
     84: mov     [rbp-0B0h],rax
     8b: mov     qword ptr [rbp-0A8h],4
     96: mov     qword ptr [rbp-0A0h],4
     a1: mov     rax,[rbp+20h]
     a5: mov     [rbp-98h],rax
     ac: mov     rax,[rbp+28h]
     b0: mov     [rbp-90h],rax
     b7: call    fn1
     bc: nop     [rcx-30h]
     c3: mov     rax,[rbp-40h]
     c7: mov     [rbp-60h],rax
     cb: mov     rax,[rbp+20h]
     cf: mov     [rbp-58h],rax
     d3: mov     rax,[rbp-60h]
     d7: mov     [rbp-50h],rax
     db: mov     rax,[rbp-58h]
     df: mov     [rbp-48h],rax
     e3: mov     rax,[rbp-40h]
     e7: imul    rcx,[rbp+20h],4
     ec: add     rax,rcx
     ef: mov     [rbp-68h],rax
     f3: mov     rax,[rbp-38h]
     f7: sub     rax,[rbp+20h]
     fb: mov     [rbp-70h],rax
     ff: mov     byte ptr [rbp-81h],1
    106: test    byte ptr [rbp-81h],0FFh
    10d: je      15Ah
    10f: mov     rax,[rbp-68h]
    113: mov     [rbp-78h],rax
    117: mov     rax,[rbp-78h]
    11b: mov     [rbp-0B0h],rax
    122: mov     qword ptr [rbp-0A8h],4
    12d: mov     qword ptr [rbp-0A0h],4
    138: mov     rax,[rbp-70h]
    13c: mov     [rbp-98h],rax
    143: mov     rax,[rbp+28h]
    147: mov     [rbp-90h],rax
    14e: call    fn2
    153: nop     [rcx-30h]
    15a: mov     rax,[rbp-68h]
    15e: mov     [rbp-80h],rax
    162: mov     rax,[rbp-70h]
    166: mov     [rbp-78h],rax
    16a: mov     rax,[rbp-80h]
    16e: mov     [rbp-60h],rax
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-58h],rax
    17a: mov     edi,0FFFFFFE0h
    17f: mov     esi,0FFFFFFB0h
    184: call    ryo_h_MovW128
    189: mov     edi,0FFFFFFF0h
    18e: mov     esi,0FFFFFFA0h
    193: call    ryo_h_MovW128
    198: mov     edi,0FFFFFFE0h
    19d: mov     esi,20h
    1a2: call    ryo_h_Ret
    1a7: leave
    1a8: ret

fn core::slice::<impl [u32]>::swap
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+20h]
     14: cmp     rax,[rbp-8]
     18: jb      71h
     1a: mov     rax,[rbp+20h]
     1e: mov     [rbp-40h],rax
     22: mov     rax,[rbp-8]
     26: mov     [rbp-38h],rax
     2a: mov     rax,[rbp+30h]
     2e: mov     [rbp-30h],rax
     32: lea     rdi,[sym0]
     39: lea     rsi,[site1]
     40: mov     edx,0FFFFFFE8h
     45: call    ryo_h_CallExt
     4a: test    rax,rax
     4d: je      5Ah
     4f: call    rax
     51: nop     [rcx-0Ah]
     58: jmp     6Ah
     5a: mov     rdi,rbp
     5d: lea     rsi,[ro+4]
     64: call    qword ptr [sym2]
     6a: call    ryo_h_Unreachable
     6f: ud2
     71: mov     rax,[rbp+28h]
     75: cmp     rax,[rbp-8]
     79: jb      0D2h
     7b: mov     rax,[rbp+28h]
     7f: mov     [rbp-40h],rax
     83: mov     rax,[rbp-8]
     87: mov     [rbp-38h],rax
     8b: mov     rax,[rbp+30h]
     8f: mov     [rbp-30h],rax
     93: lea     rdi,[sym3]
     9a: lea     rsi,[site4]
     a1: mov     edx,0FFFFFFE8h
     a6: call    ryo_h_CallExt
     ab: test    rax,rax
     ae: je      0BBh
     b0: call    rax
     b2: nop     [rcx-0Ah]
     b9: jmp     0CBh
     bb: mov     rdi,rbp
     be: lea     rsi,[ro+4]
     c5: call    qword ptr [sym5]
     cb: call    ryo_h_Unreachable
     d0: ud2
     d2: mov     edi,0FFFFFFC0h
     d7: mov     esi,10h
     dc: call    ryo_h_MovW128
     e1: mov     rax,[rbp+20h]
     e5: mov     [rbp-30h],rax
     e9: mov     rax,[rbp+28h]
     ed: mov     [rbp-28h],rax
     f1: mov     rax,[rbp+30h]
     f5: mov     [rbp-20h],rax
     f9: call    fn6
     fe: nop     [rcx-0Ah]
    105: xor     edi,edi
    107: xor     esi,esi
    109: call    ryo_h_Ret
    10e: leave
    10f: ret

fn core::slice::<impl [u32]>::swap_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-19h],1
      c: test    byte ptr [rbp-19h],0FFh
     10: je      46h
     12: mov     rax,[rbp+18h]
     16: mov     [rbp-8],rax
     1a: mov     rax,[rbp-8]
     1e: mov     [rbp-40h],rax
     22: mov     rax,[rbp+20h]
     26: mov     [rbp-38h],rax
     2a: mov     rax,[rbp+28h]
     2e: mov     [rbp-30h],rax
     32: mov     rax,[rbp+30h]
     36: mov     [rbp-28h],rax
     3a: call    fn0
     3f: nop     [rcx]
     46: mov     rax,[rbp+10h]
     4a: mov     [rbp-18h],rax
     4e: mov     rax,[rbp+18h]
     52: mov     [rbp-10h],rax
     56: mov     rax,[rbp-18h]
     5a: mov     [rbp-8],rax
     5e: mov     rax,[rbp-8]
     62: imul    rcx,[rbp+20h],4
     67: add     rax,rcx
     6a: mov     [rbp-10h],rax
     6e: mov     rax,[rbp-8]
     72: imul    rcx,[rbp+28h],4
     77: add     rax,rcx
     7a: mov     [rbp-18h],rax
     7e: mov     rax,[rbp-10h]
     82: mov     [rbp-40h],rax
     86: mov     rax,[rbp-18h]
     8a: mov     [rbp-38h],rax
     8e: call    fn1
     93: nop     [rcx]
     9a: xor     edi,edi
     9c: xor     esi,esi
     9e: call    ryo_h_Ret
     a3: leave
     a4: ret

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
     23: je      82h
     25: mov     rax,[rbp-8]
     29: mov     [rbp-90h],rax
     30: mov     rax,[rbp-10h]
     34: mov     [rbp-88h],rax
     3b: mov     rax,[rbp+30h]
     3f: mov     [rbp-80h],rax
     43: lea     rdi,[sym0]
     4a: lea     rsi,[site1]
     51: mov     edx,0FFFFFFA8h
     56: call    ryo_h_CallExt
     5b: test    rax,rax
     5e: je      6Bh
     60: call    rax
     62: nop     [rcx-10h]
     69: jmp     7Bh
     6b: mov     rdi,rbp
     6e: lea     rsi,[ro+4]
     75: call    qword ptr [sym2]
     7b: call    ryo_h_Unreachable
     80: ud2
     82: mov     rax,[rbp+20h]
     86: mov     [rbp-20h],rax
     8a: mov     rax,[rbp+28h]
     8e: mov     [rbp-18h],rax
     92: mov     rax,[rbp-20h]
     96: mov     [rbp-38h],rax
     9a: mov     rax,[rbp+10h]
     9e: mov     [rbp-30h],rax
     a2: mov     rax,[rbp+18h]
     a6: mov     [rbp-28h],rax
     aa: mov     rax,[rbp-30h]
     ae: mov     [rbp-40h],rax
     b2: mov     byte ptr [rbp-51h],1
     b6: test    byte ptr [rbp-51h],0FFh
     ba: je      117h
     bc: mov     rax,[rbp-20h]
     c0: mov     [rbp-48h],rax
     c4: mov     rax,[rbp-30h]
     c8: mov     [rbp-50h],rax
     cc: mov     rax,[rbp-48h]
     d0: mov     [rbp-90h],rax
     d7: mov     rax,[rbp-50h]
     db: mov     [rbp-88h],rax
     e2: mov     qword ptr [rbp-80h],4
     ea: mov     qword ptr [rbp-78h],4
     f2: mov     rax,[rbp-8]
     f6: mov     [rbp-70h],rax
     fa: mov     edi,0FFFFFF98h
     ff: lea     rsi,[k3]
    106: call    ryo_h_AddrAbs
    10b: call    fn4
    110: nop     [rcx-30h]
    117: imul    rax,[rbp-8],4
    11c: mov     [rbp-58h],rax
    120: mov     edi,0FFFFFFC0h
    125: mov     esi,0FFFFFFC8h
    12a: mov     edx,0FFFFFFA8h
    12f: call    ryo_h_Memcpy
    134: xor     edi,edi
    136: xor     esi,esi
    138: call    ryo_h_Ret
    13d: leave
    13e: ret

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
     13: cmp     qword ptr [rbp-20h],2
     18: jae     2Bh
     1a: mov     rax,[rbp-20h]
     1e: mov     [rbp-10h],rax
     22: mov     byte ptr [rbp-8],0
     26: jmp     105h
     2b: mov     qword ptr [rbp-18h],2
     33: mov     byte ptr [rbp-59h],1
     37: test    byte ptr [rbp-59h],0FFh
     3b: je      143h
     41: jmp     116h
     46: nop     [rax+rax]
     4f: nop
     50: test    byte ptr [rbp-21h],0FFh
     54: je      0B0h
     56: nop     [rax+rax]
     5f: nop
     60: mov     rax,[rbp-18h]
     64: mov     [rbp-30h],rax
     68: mov     rax,[rbp-30h]
     6c: cmp     rax,[rbp-20h]
     70: jae     0A6h
     72: mov     rax,[rbp-18h]
     76: mov     [rbp-48h],rax
     7a: mov     byte ptr [rbp-59h],1
     7e: test    byte ptr [rbp-59h],0FFh
     82: je      22Ch
     88: jmp     1FFh
     8d: nop     [rax]
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
     b8: mov     rax,[rbp-30h]
     bc: cmp     rax,[rbp-20h]
     c0: jae     0F6h
     c2: mov     rax,[rbp-18h]
     c6: mov     [rbp-48h],rax
     ca: mov     byte ptr [rbp-59h],1
     ce: test    byte ptr [rbp-59h],0FFh
     d2: je      335h
     d8: jmp     308h
     dd: nop     [rax]
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
    163: mov     rax,[rbp-48h]
    167: mov     [rbp-40h],rax
    16b: mov     byte ptr [rbp-59h],1
    16f: test    byte ptr [rbp-59h],0FFh
    173: je      1A2h
    175: mov     qword ptr [rbp-80h],0
    17d: mov     rax,[rbp-20h]
    181: mov     [rbp-78h],rax
    185: mov     edi,0FFFFFF90h
    18a: lea     rsi,[k2]
    191: call    ryo_h_AddrAbs
    196: call    fn3
    19b: nop     [rcx-18h]
    1a2: mov     qword ptr [rbp-60h],0
    1aa: mov     rax,[rbp-60h]
    1ae: cmp     rax,[rbp-20h]
    1b2: setb    [rbp-22h]
    1b6: mov     rax,[rbp+10h]
    1ba: mov     [rbp-50h],rax
    1be: mov     rax,[rbp-50h]
    1c2: mov     [rbp-48h],rax
    1c6: mov     rax,[rbp-40h]
    1ca: mov     [rbp-38h],rax
    1ce: mov     rax,[rbp-48h]
    1d2: mov     [rbp-30h],rax
    1d6: mov     rax,[rbp+20h]
    1da: mov     [rbp-80h],rax
    1de: mov     rax,[rbp-38h]
    1e2: mov     [rbp-78h],rax
    1e6: mov     rax,[rbp-30h]
    1ea: mov     [rbp-70h],rax
    1ee: call    fn4
    1f3: nop     [rcx-21h]
    1fa: jmp     50h
    1ff: mov     rax,[rbp-48h]
    203: mov     [rbp-80h],rax
    207: mov     rax,[rbp-20h]
    20b: mov     [rbp-78h],rax
    20f: mov     edi,0FFFFFF90h
    214: lea     rsi,[k5]
    21b: call    ryo_h_AddrAbs
    220: call    fn6
    225: nop     [rcx-18h]
    22c: mov     rax,[rbp-48h]
    230: cmp     rax,[rbp-20h]
    234: setb    [rbp-24h]
    238: mov     rax,[rbp+10h]
    23c: imul    rcx,[rbp-48h],8
    241: add     rax,rcx
    244: mov     [rbp-60h],rax
    248: mov     rax,[rbp-60h]
    24c: mov     [rbp-50h],rax
    250: mov     rax,[rbp-50h]
    254: mov     [rbp-40h],rax
    258: mov     rax,[rbp-18h]
    25c: mov     [rbp-58h],rax
    260: mov     rax,[rbp-58h]
    264: sub     rax,1
    268: mov     [rbp-50h],rax
    26c: mov     byte ptr [rbp-59h],1
    270: test    byte ptr [rbp-59h],0FFh
    274: je      2A3h
    276: mov     rax,[rbp-50h]
    27a: mov     [rbp-80h],rax
    27e: mov     rax,[rbp-20h]
    282: mov     [rbp-78h],rax
    286: mov     edi,0FFFFFF90h
    28b: lea     rsi,[k7]
    292: call    ryo_h_AddrAbs
    297: call    fn8
    29c: nop     [rcx-18h]
    2a3: mov     rax,[rbp-50h]
    2a7: cmp     rax,[rbp-20h]
    2ab: setb    [rbp-24h]
    2af: mov     rax,[rbp+10h]
    2b3: imul    rcx,[rbp-50h],8
    2b8: add     rax,rcx
    2bb: mov     [rbp-60h],rax
    2bf: mov     rax,[rbp-60h]
    2c3: mov     [rbp-58h],rax
    2c7: mov     rax,[rbp-58h]
    2cb: mov     [rbp-48h],rax
    2cf: mov     rax,[rbp-40h]
    2d3: mov     [rbp-38h],rax
    2d7: mov     rax,[rbp-48h]
    2db: mov     [rbp-30h],rax
    2df: mov     rax,[rbp+20h]
    2e3: mov     [rbp-80h],rax
    2e7: mov     rax,[rbp-38h]
    2eb: mov     [rbp-78h],rax
    2ef: mov     rax,[rbp-30h]
    2f3: mov     [rbp-70h],rax
    2f7: call    fn9
    2fc: nop     [rcx-23h]
    303: jmp     90h
    308: mov     rax,[rbp-48h]
    30c: mov     [rbp-80h],rax
    310: mov     rax,[rbp-20h]
    314: mov     [rbp-78h],rax
    318: mov     edi,0FFFFFF90h
    31d: lea     rsi,[k10]
    324: call    ryo_h_AddrAbs
    329: call    fn11
    32e: nop     [rcx-18h]
    335: mov     rax,[rbp-48h]
    339: cmp     rax,[rbp-20h]
    33d: setb    [rbp-24h]
    341: mov     rax,[rbp+10h]
    345: imul    rcx,[rbp-48h],8
    34a: add     rax,rcx
    34d: mov     [rbp-60h],rax
    351: mov     rax,[rbp-60h]
    355: mov     [rbp-50h],rax
    359: mov     rax,[rbp-50h]
    35d: mov     [rbp-40h],rax
    361: mov     rax,[rbp-18h]
    365: mov     [rbp-58h],rax
    369: mov     rax,[rbp-58h]
    36d: sub     rax,1
    371: mov     [rbp-50h],rax
    375: mov     byte ptr [rbp-59h],1
    379: test    byte ptr [rbp-59h],0FFh
    37d: je      3ACh
    37f: mov     rax,[rbp-50h]
    383: mov     [rbp-80h],rax
    387: mov     rax,[rbp-20h]
    38b: mov     [rbp-78h],rax
    38f: mov     edi,0FFFFFF90h
    394: lea     rsi,[k12]
    39b: call    ryo_h_AddrAbs
    3a0: call    fn13
    3a5: nop     [rcx-18h]
    3ac: mov     rax,[rbp-50h]
    3b0: cmp     rax,[rbp-20h]
    3b4: setb    [rbp-24h]
    3b8: mov     rax,[rbp+10h]
    3bc: imul    rcx,[rbp-50h],8
    3c1: add     rax,rcx
    3c4: mov     [rbp-60h],rax
    3c8: mov     rax,[rbp-60h]
    3cc: mov     [rbp-58h],rax
    3d0: mov     rax,[rbp-58h]
    3d4: mov     [rbp-48h],rax
    3d8: mov     rax,[rbp-40h]
    3dc: mov     [rbp-38h],rax
    3e0: mov     rax,[rbp-48h]
    3e4: mov     [rbp-30h],rax
    3e8: mov     rax,[rbp+20h]
    3ec: mov     [rbp-80h],rax
    3f0: mov     rax,[rbp-38h]
    3f4: mov     [rbp-78h],rax
    3f8: mov     rax,[rbp-30h]
    3fc: mov     [rbp-70h],rax
    400: call    fn14
    405: nop     [rcx-23h]
    40c: jmp     0E0h

fn core::slice::sort::shared::find_existing_run::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     qword ptr [rbp-20h],2
     18: jae     2Bh
     1a: mov     rax,[rbp-20h]
     1e: mov     [rbp-10h],rax
     22: mov     byte ptr [rbp-8],0
     26: jmp     105h
     2b: mov     qword ptr [rbp-18h],2
     33: mov     byte ptr [rbp-59h],1
     37: test    byte ptr [rbp-59h],0FFh
     3b: je      143h
     41: jmp     116h
     46: nop     [rax+rax]
     4f: nop
     50: test    byte ptr [rbp-21h],0FFh
     54: je      0B0h
     56: nop     [rax+rax]
     5f: nop
     60: mov     rax,[rbp-18h]
     64: mov     [rbp-30h],rax
     68: mov     rax,[rbp-30h]
     6c: cmp     rax,[rbp-20h]
     70: jae     0A6h
     72: mov     rax,[rbp-18h]
     76: mov     [rbp-48h],rax
     7a: mov     byte ptr [rbp-59h],1
     7e: test    byte ptr [rbp-59h],0FFh
     82: je      22Ch
     88: jmp     1FFh
     8d: nop     [rax]
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
     b8: mov     rax,[rbp-30h]
     bc: cmp     rax,[rbp-20h]
     c0: jae     0F6h
     c2: mov     rax,[rbp-18h]
     c6: mov     [rbp-48h],rax
     ca: mov     byte ptr [rbp-59h],1
     ce: test    byte ptr [rbp-59h],0FFh
     d2: je      335h
     d8: jmp     308h
     dd: nop     [rax]
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
    163: mov     rax,[rbp-48h]
    167: mov     [rbp-40h],rax
    16b: mov     byte ptr [rbp-59h],1
    16f: test    byte ptr [rbp-59h],0FFh
    173: je      1A2h
    175: mov     qword ptr [rbp-80h],0
    17d: mov     rax,[rbp-20h]
    181: mov     [rbp-78h],rax
    185: mov     edi,0FFFFFF90h
    18a: lea     rsi,[k2]
    191: call    ryo_h_AddrAbs
    196: call    fn3
    19b: nop     [rcx-18h]
    1a2: mov     qword ptr [rbp-60h],0
    1aa: mov     rax,[rbp-60h]
    1ae: cmp     rax,[rbp-20h]
    1b2: setb    [rbp-22h]
    1b6: mov     rax,[rbp+10h]
    1ba: mov     [rbp-50h],rax
    1be: mov     rax,[rbp-50h]
    1c2: mov     [rbp-48h],rax
    1c6: mov     rax,[rbp-40h]
    1ca: mov     [rbp-38h],rax
    1ce: mov     rax,[rbp-48h]
    1d2: mov     [rbp-30h],rax
    1d6: mov     rax,[rbp+20h]
    1da: mov     [rbp-80h],rax
    1de: mov     rax,[rbp-38h]
    1e2: mov     [rbp-78h],rax
    1e6: mov     rax,[rbp-30h]
    1ea: mov     [rbp-70h],rax
    1ee: call    fn4
    1f3: nop     [rcx-21h]
    1fa: jmp     50h
    1ff: mov     rax,[rbp-48h]
    203: mov     [rbp-80h],rax
    207: mov     rax,[rbp-20h]
    20b: mov     [rbp-78h],rax
    20f: mov     edi,0FFFFFF90h
    214: lea     rsi,[k5]
    21b: call    ryo_h_AddrAbs
    220: call    fn6
    225: nop     [rcx-18h]
    22c: mov     rax,[rbp-48h]
    230: cmp     rax,[rbp-20h]
    234: setb    [rbp-24h]
    238: mov     rax,[rbp+10h]
    23c: imul    rcx,[rbp-48h],4
    241: add     rax,rcx
    244: mov     [rbp-60h],rax
    248: mov     rax,[rbp-60h]
    24c: mov     [rbp-50h],rax
    250: mov     rax,[rbp-50h]
    254: mov     [rbp-40h],rax
    258: mov     rax,[rbp-18h]
    25c: mov     [rbp-58h],rax
    260: mov     rax,[rbp-58h]
    264: sub     rax,1
    268: mov     [rbp-50h],rax
    26c: mov     byte ptr [rbp-59h],1
    270: test    byte ptr [rbp-59h],0FFh
    274: je      2A3h
    276: mov     rax,[rbp-50h]
    27a: mov     [rbp-80h],rax
    27e: mov     rax,[rbp-20h]
    282: mov     [rbp-78h],rax
    286: mov     edi,0FFFFFF90h
    28b: lea     rsi,[k7]
    292: call    ryo_h_AddrAbs
    297: call    fn8
    29c: nop     [rcx-18h]
    2a3: mov     rax,[rbp-50h]
    2a7: cmp     rax,[rbp-20h]
    2ab: setb    [rbp-24h]
    2af: mov     rax,[rbp+10h]
    2b3: imul    rcx,[rbp-50h],4
    2b8: add     rax,rcx
    2bb: mov     [rbp-60h],rax
    2bf: mov     rax,[rbp-60h]
    2c3: mov     [rbp-58h],rax
    2c7: mov     rax,[rbp-58h]
    2cb: mov     [rbp-48h],rax
    2cf: mov     rax,[rbp-40h]
    2d3: mov     [rbp-38h],rax
    2d7: mov     rax,[rbp-48h]
    2db: mov     [rbp-30h],rax
    2df: mov     rax,[rbp+20h]
    2e3: mov     [rbp-80h],rax
    2e7: mov     rax,[rbp-38h]
    2eb: mov     [rbp-78h],rax
    2ef: mov     rax,[rbp-30h]
    2f3: mov     [rbp-70h],rax
    2f7: call    fn9
    2fc: nop     [rcx-23h]
    303: jmp     90h
    308: mov     rax,[rbp-48h]
    30c: mov     [rbp-80h],rax
    310: mov     rax,[rbp-20h]
    314: mov     [rbp-78h],rax
    318: mov     edi,0FFFFFF90h
    31d: lea     rsi,[k10]
    324: call    ryo_h_AddrAbs
    329: call    fn11
    32e: nop     [rcx-18h]
    335: mov     rax,[rbp-48h]
    339: cmp     rax,[rbp-20h]
    33d: setb    [rbp-24h]
    341: mov     rax,[rbp+10h]
    345: imul    rcx,[rbp-48h],4
    34a: add     rax,rcx
    34d: mov     [rbp-60h],rax
    351: mov     rax,[rbp-60h]
    355: mov     [rbp-50h],rax
    359: mov     rax,[rbp-50h]
    35d: mov     [rbp-40h],rax
    361: mov     rax,[rbp-18h]
    365: mov     [rbp-58h],rax
    369: mov     rax,[rbp-58h]
    36d: sub     rax,1
    371: mov     [rbp-50h],rax
    375: mov     byte ptr [rbp-59h],1
    379: test    byte ptr [rbp-59h],0FFh
    37d: je      3ACh
    37f: mov     rax,[rbp-50h]
    383: mov     [rbp-80h],rax
    387: mov     rax,[rbp-20h]
    38b: mov     [rbp-78h],rax
    38f: mov     edi,0FFFFFF90h
    394: lea     rsi,[k12]
    39b: call    ryo_h_AddrAbs
    3a0: call    fn13
    3a5: nop     [rcx-18h]
    3ac: mov     rax,[rbp-50h]
    3b0: cmp     rax,[rbp-20h]
    3b4: setb    [rbp-24h]
    3b8: mov     rax,[rbp+10h]
    3bc: imul    rcx,[rbp-50h],4
    3c1: add     rax,rcx
    3c4: mov     [rbp-60h],rax
    3c8: mov     rax,[rbp-60h]
    3cc: mov     [rbp-58h],rax
    3d0: mov     rax,[rbp-58h]
    3d4: mov     [rbp-48h],rax
    3d8: mov     rax,[rbp-40h]
    3dc: mov     [rbp-38h],rax
    3e0: mov     rax,[rbp-48h]
    3e4: mov     [rbp-30h],rax
    3e8: mov     rax,[rbp+20h]
    3ec: mov     [rbp-80h],rax
    3f0: mov     rax,[rbp-38h]
    3f4: mov     [rbp-78h],rax
    3f8: mov     rax,[rbp-30h]
    3fc: mov     [rbp-70h],rax
    400: call    fn14
    405: nop     [rcx-23h]
    40c: jmp     0E0h

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-28h],rax
     13: cmp     qword ptr [rbp-28h],8
     18: jae     21h
     1a: call    ryo_h_Abort
     1f: ud2
     21: mov     rax,[rbp+10h]
     25: mov     [rbp-20h],rax
     29: mov     rax,[rbp+18h]
     2d: mov     [rbp-18h],rax
     31: mov     rax,[rbp-20h]
     35: mov     [rbp-10h],rax
     39: mov     qword ptr [rbp-80h],8
     41: mov     edi,0FFFFFFD0h
     46: mov     esi,0FFFFFFD8h
     4b: mov     edx,0FFFFFF80h
     50: call    ryo_h_DivUW64
     55: imul    rax,[rbp-30h],4
     5a: mov     [rbp-40h],rax
     5e: mov     rax,[rbp-10h]
     62: imul    rcx,[rbp-40h],8
     67: add     rax,rcx
     6a: mov     [rbp-38h],rax
     6e: imul    rax,[rbp-30h],7
     73: mov     [rbp-48h],rax
     77: mov     rax,[rbp-10h]
     7b: imul    rcx,[rbp-48h],8
     80: add     rax,rcx
     83: mov     [rbp-40h],rax
     87: cmp     qword ptr [rbp-28h],40h
     8c: jae     0F1h
     8e: mov     rax,[rbp-10h]
     92: mov     [rbp-58h],rax
     96: mov     rax,[rbp-38h]
     9a: mov     [rbp-60h],rax
     9e: mov     rax,[rbp-40h]
     a2: mov     [rbp-68h],rax
     a6: mov     rax,[rbp-58h]
     aa: mov     [rbp-0B0h],rax
     b1: mov     rax,[rbp-60h]
     b5: mov     [rbp-0A8h],rax
     bc: mov     rax,[rbp-68h]
     c0: mov     [rbp-0A0h],rax
     c7: mov     rax,[rbp+20h]
     cb: mov     [rbp-98h],rax
     d2: call    fn0
     d7: nop     [rcx-50h]
     de: mov     byte ptr [rbp-79h],1
     e2: test    byte ptr [rbp-79h],0FFh
     e6: je      1C5h
     ec: jmp     182h
     f1: mov     rax,[rbp-10h]
     f5: mov     [rbp-0B0h],rax
     fc: mov     rax,[rbp-38h]
    100: mov     [rbp-0A8h],rax
    107: mov     rax,[rbp-40h]
    10b: mov     [rbp-0A0h],rax
    112: mov     rax,[rbp-30h]
    116: mov     [rbp-98h],rax
    11d: mov     rax,[rbp+20h]
    121: mov     [rbp-90h],rax
    128: call    fn1
    12d: nop     [rcx-50h]
    134: mov     byte ptr [rbp-79h],1
    138: test    byte ptr [rbp-79h],0FFh
    13c: je      2E8h
    142: jmp     2A5h
    147: nop     [rax+rax]
    150: mov     rax,[rbp-8]
    154: mov     [rbp-38h],rax
    158: mov     rax,[rbp-38h]
    15c: cmp     rax,[rbp-28h]
    160: setb    [rbp-29h]
    164: mov     byte ptr [rbp-79h],1
    168: test    byte ptr [rbp-79h],0FFh
    16c: je      3E2h
    172: jmp     3BBh
    177: nop     [rax+rax]
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
     13: cmp     qword ptr [rbp-28h],8
     18: jae     21h
     1a: call    ryo_h_Abort
     1f: ud2
     21: mov     rax,[rbp+10h]
     25: mov     [rbp-20h],rax
     29: mov     rax,[rbp+18h]
     2d: mov     [rbp-18h],rax
     31: mov     rax,[rbp-20h]
     35: mov     [rbp-10h],rax
     39: mov     qword ptr [rbp-80h],8
     41: mov     edi,0FFFFFFD0h
     46: mov     esi,0FFFFFFD8h
     4b: mov     edx,0FFFFFF80h
     50: call    ryo_h_DivUW64
     55: imul    rax,[rbp-30h],4
     5a: mov     [rbp-40h],rax
     5e: mov     rax,[rbp-10h]
     62: imul    rcx,[rbp-40h],4
     67: add     rax,rcx
     6a: mov     [rbp-38h],rax
     6e: imul    rax,[rbp-30h],7
     73: mov     [rbp-48h],rax
     77: mov     rax,[rbp-10h]
     7b: imul    rcx,[rbp-48h],4
     80: add     rax,rcx
     83: mov     [rbp-40h],rax
     87: cmp     qword ptr [rbp-28h],40h
     8c: jae     0F1h
     8e: mov     rax,[rbp-10h]
     92: mov     [rbp-58h],rax
     96: mov     rax,[rbp-38h]
     9a: mov     [rbp-60h],rax
     9e: mov     rax,[rbp-40h]
     a2: mov     [rbp-68h],rax
     a6: mov     rax,[rbp-58h]
     aa: mov     [rbp-0B0h],rax
     b1: mov     rax,[rbp-60h]
     b5: mov     [rbp-0A8h],rax
     bc: mov     rax,[rbp-68h]
     c0: mov     [rbp-0A0h],rax
     c7: mov     rax,[rbp+20h]
     cb: mov     [rbp-98h],rax
     d2: call    fn0
     d7: nop     [rcx-50h]
     de: mov     byte ptr [rbp-79h],1
     e2: test    byte ptr [rbp-79h],0FFh
     e6: je      1C5h
     ec: jmp     182h
     f1: mov     rax,[rbp-10h]
     f5: mov     [rbp-0B0h],rax
     fc: mov     rax,[rbp-38h]
    100: mov     [rbp-0A8h],rax
    107: mov     rax,[rbp-40h]
    10b: mov     [rbp-0A0h],rax
    112: mov     rax,[rbp-30h]
    116: mov     [rbp-98h],rax
    11d: mov     rax,[rbp+20h]
    121: mov     [rbp-90h],rax
    128: call    fn1
    12d: nop     [rcx-50h]
    134: mov     byte ptr [rbp-79h],1
    138: test    byte ptr [rbp-79h],0FFh
    13c: je      2E8h
    142: jmp     2A5h
    147: nop     [rax+rax]
    150: mov     rax,[rbp-8]
    154: mov     [rbp-38h],rax
    158: mov     rax,[rbp-38h]
    15c: cmp     rax,[rbp-28h]
    160: setb    [rbp-29h]
    164: mov     byte ptr [rbp-79h],1
    168: test    byte ptr [rbp-79h],0FFh
    16c: je      3E2h
    172: jmp     3BBh
    177: nop     [rax+rax]
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
     11: cmp     qword ptr [rbp-28h],40h
     16: jb      178h
     1c: mov     qword ptr [rbp-48h],8
     24: mov     edi,0FFFFFFD8h
     29: mov     esi,28h
     2e: mov     edx,0FFFFFFB8h
     33: call    ryo_h_DivUW64
     38: mov     rax,[rbp+10h]
     3c: mov     [rbp-30h],rax
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-40h],rax
     48: imul    rax,[rbp-28h],4
     4d: mov     [rbp-10h],rax
     51: mov     rax,[rbp-40h]
     55: imul    rcx,[rbp-10h],8
     5a: add     rax,rcx
     5d: mov     [rbp-38h],rax
     61: imul    rax,[rbp-28h],7
     66: mov     [rbp-18h],rax
     6a: mov     rax,[rbp+10h]
     6e: imul    rcx,[rbp-18h],8
     73: add     rax,rcx
     76: mov     [rbp-40h],rax
     7a: mov     rax,[rbp-30h]
     7e: mov     [rbp-70h],rax
     82: mov     rax,[rbp-38h]
     86: mov     [rbp-68h],rax
     8a: mov     rax,[rbp-40h]
     8e: mov     [rbp-60h],rax
     92: mov     rax,[rbp-28h]
     96: mov     [rbp-58h],rax
     9a: mov     rax,[rbp+30h]
     9e: mov     [rbp-50h],rax
     a2: call    fn0
     a7: nop     [rcx+10h]
     ae: mov     rax,[rbp+18h]
     b2: mov     [rbp-30h],rax
     b6: mov     rax,[rbp+18h]
     ba: mov     [rbp-40h],rax
     be: mov     rax,[rbp-40h]
     c2: imul    rcx,[rbp-10h],8
     c7: add     rax,rcx
     ca: mov     [rbp-38h],rax
     ce: mov     rax,[rbp+18h]
     d2: imul    rcx,[rbp-18h],8
     d7: add     rax,rcx
     da: mov     [rbp-40h],rax
     de: mov     rax,[rbp-30h]
     e2: mov     [rbp-70h],rax
     e6: mov     rax,[rbp-38h]
     ea: mov     [rbp-68h],rax
     ee: mov     rax,[rbp-40h]
     f2: mov     [rbp-60h],rax
     f6: mov     rax,[rbp-28h]
     fa: mov     [rbp-58h],rax
     fe: mov     rax,[rbp+30h]
    102: mov     [rbp-50h],rax
    106: call    fn1
    10b: nop     [rcx+18h]
    112: mov     rax,[rbp+20h]
    116: mov     [rbp-30h],rax
    11a: mov     rax,[rbp+20h]
    11e: mov     [rbp-40h],rax
    122: mov     rax,[rbp-40h]
    126: imul    rcx,[rbp-10h],8
    12b: add     rax,rcx
    12e: mov     [rbp-38h],rax
    132: mov     rax,[rbp+20h]
    136: imul    rcx,[rbp-18h],8
    13b: add     rax,rcx
    13e: mov     [rbp-40h],rax
    142: mov     rax,[rbp-30h]
    146: mov     [rbp-70h],rax
    14a: mov     rax,[rbp-38h]
    14e: mov     [rbp-68h],rax
    152: mov     rax,[rbp-40h]
    156: mov     [rbp-60h],rax
    15a: mov     rax,[rbp-28h]
    15e: mov     [rbp-58h],rax
    162: mov     rax,[rbp+30h]
    166: mov     [rbp-50h],rax
    16a: call    fn2
    16f: nop     [rcx+20h]
    176: jmp     178h
    178: mov     rax,[rbp+10h]
    17c: mov     [rbp-20h],rax
    180: mov     rax,[rbp+18h]
    184: mov     [rbp-28h],rax
    188: mov     rax,[rbp+20h]
    18c: mov     [rbp-30h],rax
    190: mov     rax,[rbp-20h]
    194: mov     [rbp-70h],rax
    198: mov     rax,[rbp-28h]
    19c: mov     [rbp-68h],rax
    1a0: mov     rax,[rbp-30h]
    1a4: mov     [rbp-60h],rax
    1a8: mov     rax,[rbp+30h]
    1ac: mov     [rbp-58h],rax
    1b0: call    fn3
    1b5: nop     [rcx-8]
    1bc: mov     edi,0FFFFFFF8h
    1c1: mov     esi,8
    1c6: call    ryo_h_Ret
    1cb: leave
    1cc: ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: imul    rax,[rbp+28h],8
      d: mov     [rbp-28h],rax
     11: cmp     qword ptr [rbp-28h],40h
     16: jb      178h
     1c: mov     qword ptr [rbp-48h],8
     24: mov     edi,0FFFFFFD8h
     29: mov     esi,28h
     2e: mov     edx,0FFFFFFB8h
     33: call    ryo_h_DivUW64
     38: mov     rax,[rbp+10h]
     3c: mov     [rbp-30h],rax
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-40h],rax
     48: imul    rax,[rbp-28h],4
     4d: mov     [rbp-10h],rax
     51: mov     rax,[rbp-40h]
     55: imul    rcx,[rbp-10h],4
     5a: add     rax,rcx
     5d: mov     [rbp-38h],rax
     61: imul    rax,[rbp-28h],7
     66: mov     [rbp-18h],rax
     6a: mov     rax,[rbp+10h]
     6e: imul    rcx,[rbp-18h],4
     73: add     rax,rcx
     76: mov     [rbp-40h],rax
     7a: mov     rax,[rbp-30h]
     7e: mov     [rbp-70h],rax
     82: mov     rax,[rbp-38h]
     86: mov     [rbp-68h],rax
     8a: mov     rax,[rbp-40h]
     8e: mov     [rbp-60h],rax
     92: mov     rax,[rbp-28h]
     96: mov     [rbp-58h],rax
     9a: mov     rax,[rbp+30h]
     9e: mov     [rbp-50h],rax
     a2: call    fn0
     a7: nop     [rcx+10h]
     ae: mov     rax,[rbp+18h]
     b2: mov     [rbp-30h],rax
     b6: mov     rax,[rbp+18h]
     ba: mov     [rbp-40h],rax
     be: mov     rax,[rbp-40h]
     c2: imul    rcx,[rbp-10h],4
     c7: add     rax,rcx
     ca: mov     [rbp-38h],rax
     ce: mov     rax,[rbp+18h]
     d2: imul    rcx,[rbp-18h],4
     d7: add     rax,rcx
     da: mov     [rbp-40h],rax
     de: mov     rax,[rbp-30h]
     e2: mov     [rbp-70h],rax
     e6: mov     rax,[rbp-38h]
     ea: mov     [rbp-68h],rax
     ee: mov     rax,[rbp-40h]
     f2: mov     [rbp-60h],rax
     f6: mov     rax,[rbp-28h]
     fa: mov     [rbp-58h],rax
     fe: mov     rax,[rbp+30h]
    102: mov     [rbp-50h],rax
    106: call    fn1
    10b: nop     [rcx+18h]
    112: mov     rax,[rbp+20h]
    116: mov     [rbp-30h],rax
    11a: mov     rax,[rbp+20h]
    11e: mov     [rbp-40h],rax
    122: mov     rax,[rbp-40h]
    126: imul    rcx,[rbp-10h],4
    12b: add     rax,rcx
    12e: mov     [rbp-38h],rax
    132: mov     rax,[rbp+20h]
    136: imul    rcx,[rbp-18h],4
    13b: add     rax,rcx
    13e: mov     [rbp-40h],rax
    142: mov     rax,[rbp-30h]
    146: mov     [rbp-70h],rax
    14a: mov     rax,[rbp-38h]
    14e: mov     [rbp-68h],rax
    152: mov     rax,[rbp-40h]
    156: mov     [rbp-60h],rax
    15a: mov     rax,[rbp-28h]
    15e: mov     [rbp-58h],rax
    162: mov     rax,[rbp+30h]
    166: mov     [rbp-50h],rax
    16a: call    fn2
    16f: nop     [rcx+20h]
    176: jmp     178h
    178: mov     rax,[rbp+10h]
    17c: mov     [rbp-20h],rax
    180: mov     rax,[rbp+18h]
    184: mov     [rbp-28h],rax
    188: mov     rax,[rbp+20h]
    18c: mov     [rbp-30h],rax
    190: mov     rax,[rbp-20h]
    194: mov     [rbp-70h],rax
    198: mov     rax,[rbp-28h]
    19c: mov     [rbp-68h],rax
    1a0: mov     rax,[rbp-30h]
    1a4: mov     [rbp-60h],rax
    1a8: mov     rax,[rbp+30h]
    1ac: mov     [rbp-58h],rax
    1b0: call    fn3
    1b5: nop     [rcx-8]
    1bc: mov     edi,0FFFFFFF8h
    1c1: mov     esi,8
    1c6: call    ryo_h_Ret
    1cb: leave
    1cc: ret

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
     ab: mov     rax,[rbp-80h]
     af: imul    rcx,[rbp-8],8
     b4: add     rax,rcx
     b7: mov     [rbp-48h],rax
     bb: mov     qword ptr [rbp-18h],0
     c3: mov     rax,[rbp-78h]
     c7: mov     [rbp-10h],rax
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp-18h]
     d4: mov     [rbp-88h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-90h],rax
     e6: mov     rax,[rbp-88h]
     ed: cmp     rax,[rbp-90h]
     f4: setb    [rbp-79h]
     f8: test    byte ptr [rbp-79h],0FFh
     fc: je      280h
    102: jmp     263h
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
    190: jmp     200h
    192: nop     [rax+rax]
    19b: nop     [rax+rax]
    1a0: mov     rax,[rbp-28h]
    1a4: mov     [rbp-98h],rax
    1ab: mov     rax,[rbp-98h]
    1b2: cmp     rax,[rbp-80h]
    1b6: setb    [rbp-8Ah]
    1bd: test    byte ptr [rbp-8Ah],0FFh
    1c4: je      1D0h
    1c6: mov     rax,[rbp-28h]
    1ca: mov     [rbp-50h],rax
    1ce: jmp     1D8h
    1d0: mov     rax,[rbp-30h]
    1d4: mov     [rbp-50h],rax
    1d8: mov     byte ptr [rbp-0A1h],1
    1df: test    byte ptr [rbp-0A1h],0FFh
    1e6: je      404h
    1ec: jmp     394h
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: mov     rax,[rbp-28h]
    204: cmp     rax,[rbp-80h]
    208: je      20Ch
    20a: jmp     219h
    20c: mov     rax,[rbp-30h]
    210: cmp     rax,[rbp-88h]
    217: je      258h
    219: lea     rdi,[sym1]
    220: lea     rsi,[site2]
    227: mov     edx,0FFFFFF58h
    22c: call    ryo_h_CallExt
    231: test    rax,rax
    234: je      241h
    236: call    rax
    238: nop     [rcx-50h]
    23f: jmp     251h
    241: mov     rdi,rbp
    244: lea     rsi,[ro+4]
    24b: call    qword ptr [sym3]
    251: call    ryo_h_Unreachable
    256: ud2
    258: xor     edi,edi
    25a: xor     esi,esi
    25c: call    ryo_h_Ret
    261: leave
    262: ret
    263: mov     rax,[rbp-18h]
    267: mov     [rbp-88h],rax
    26e: mov     byte ptr [rbp-0A1h],1
    275: test    byte ptr [rbp-0A1h],0FFh
    27c: je      2D9h
    27e: jmp     2A3h
    280: mov     qword ptr [rbp-0A8h],1
    28b: mov     rax,[rbp-38h]
    28f: imul    rcx,[rbp-0A8h],8
    297: add     rax,rcx
    29a: mov     [rbp-80h],rax
    29e: jmp     333h
    2a3: mov     rax,[rbp-88h]
    2aa: mov     [rbp-0E0h],rax
    2b1: mov     qword ptr [rbp-0D8h],1
    2bc: mov     edi,0FFFFFF30h
    2c1: lea     rsi,[k4]
    2c8: call    ryo_h_AddrAbs
    2cd: call    fn5
    2d2: nop     [rcx-60h]
    2d9: mov     rax,[rbp-88h]
    2e0: add     rax,1
    2e4: mov     [rbp-90h],rax
    2eb: mov     rax,[rbp-90h]
    2f2: mov     [rbp-18h],rax
    2f6: mov     rax,[rbp-28h]
    2fa: mov     [rbp-0E0h],rax
    301: mov     rax,[rbp-30h]
    305: mov     [rbp-0D8h],rax
    30c: mov     rax,[rbp+20h]
    310: mov     [rbp-0D0h],rax
    317: mov     rax,[rbp+28h]
    31b: mov     [rbp-0C8h],rax
    322: call    fn6
    327: nop     [rcx-90h]
    32e: jmp     110h
    333: mov     qword ptr [rbp-0A8h],1
    33e: mov     rax,[rbp-40h]
    342: imul    rcx,[rbp-0A8h],8
    34a: add     rax,rcx
    34d: mov     [rbp-88h],rax
    354: mov     qword ptr [rbp-0A8h],2
    35f: mov     edi,0FFFFFF68h
    364: mov     esi,0FFFFFF98h
    369: mov     edx,0FFFFFF58h
    36e: call    ryo_h_RemUW64
    373: cmp     qword ptr [rbp-98h],0
    37b: sete    [rbp-89h]
    382: test    byte ptr [rbp-89h],0FFh
    389: je      1A0h
    38f: jmp     190h
    394: mov     rax,[rbp-50h]
    398: mov     [rbp-98h],rax
    39f: mov     rax,[rbp+20h]
    3a3: mov     [rbp-0A0h],rax
    3aa: mov     rax,[rbp-98h]
    3b1: mov     [rbp-0E0h],rax
    3b8: mov     rax,[rbp-0A0h]
    3bf: mov     [rbp-0D8h],rax
    3c6: mov     qword ptr [rbp-0D0h],8
    3d1: mov     qword ptr [rbp-0C8h],4
    3dc: mov     qword ptr [rbp-0C0h],1
    3e7: mov     edi,0FFFFFF48h
    3ec: lea     rsi,[k7]
    3f3: call    ryo_h_AddrAbs
    3f8: call    fn8
    3fd: nop     [rcx-60h]
    404: mov     qword ptr [rbp-0A8h],1
    40f: imul    rax,[rbp-0A8h],8
    417: mov     [rbp-0B0h],rax
    41e: mov     edi,20h
    423: mov     esi,0FFFFFFB0h
    428: mov     edx,0FFFFFF50h
    42d: call    ryo_h_Memcpy
    432: mov     edi,0FFFFFF60h
    437: mov     esi,0FFFFFF76h
    43c: call    ryo_h_ZextW8W64
    441: mov     rax,[rbp-28h]
    445: imul    rcx,[rbp-0A0h],8
    44d: add     rax,rcx
    450: mov     [rbp-98h],rax
    457: mov     rax,[rbp-98h]
    45e: mov     [rbp-28h],rax
    462: movzx   eax,byte ptr [rbp-8Ah]
    469: xor     al,1
    46c: mov     [rbp-8Bh],al
    472: mov     edi,0FFFFFF60h
    477: mov     esi,0FFFFFF75h
    47c: call    ryo_h_ZextW8W64
    481: mov     rax,[rbp-30h]
    485: imul    rcx,[rbp-0A0h],8
    48d: add     rax,rcx
    490: mov     [rbp-98h],rax
    497: mov     rax,[rbp-98h]
    49e: mov     [rbp-30h],rax
    4a2: jmp     200h

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
     ab: mov     rax,[rbp-80h]
     af: imul    rcx,[rbp-8],4
     b4: add     rax,rcx
     b7: mov     [rbp-48h],rax
     bb: mov     qword ptr [rbp-18h],0
     c3: mov     rax,[rbp-78h]
     c7: mov     [rbp-10h],rax
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp-18h]
     d4: mov     [rbp-88h],rax
     db: mov     rax,[rbp-10h]
     df: mov     [rbp-90h],rax
     e6: mov     rax,[rbp-88h]
     ed: cmp     rax,[rbp-90h]
     f4: setb    [rbp-79h]
     f8: test    byte ptr [rbp-79h],0FFh
     fc: je      280h
    102: jmp     263h
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
    190: jmp     200h
    192: nop     [rax+rax]
    19b: nop     [rax+rax]
    1a0: mov     rax,[rbp-28h]
    1a4: mov     [rbp-98h],rax
    1ab: mov     rax,[rbp-98h]
    1b2: cmp     rax,[rbp-80h]
    1b6: setb    [rbp-8Ah]
    1bd: test    byte ptr [rbp-8Ah],0FFh
    1c4: je      1D0h
    1c6: mov     rax,[rbp-28h]
    1ca: mov     [rbp-50h],rax
    1ce: jmp     1D8h
    1d0: mov     rax,[rbp-30h]
    1d4: mov     [rbp-50h],rax
    1d8: mov     byte ptr [rbp-0A1h],1
    1df: test    byte ptr [rbp-0A1h],0FFh
    1e6: je      404h
    1ec: jmp     394h
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: mov     rax,[rbp-28h]
    204: cmp     rax,[rbp-80h]
    208: je      20Ch
    20a: jmp     219h
    20c: mov     rax,[rbp-30h]
    210: cmp     rax,[rbp-88h]
    217: je      258h
    219: lea     rdi,[sym1]
    220: lea     rsi,[site2]
    227: mov     edx,0FFFFFF58h
    22c: call    ryo_h_CallExt
    231: test    rax,rax
    234: je      241h
    236: call    rax
    238: nop     [rcx-50h]
    23f: jmp     251h
    241: mov     rdi,rbp
    244: lea     rsi,[ro+4]
    24b: call    qword ptr [sym3]
    251: call    ryo_h_Unreachable
    256: ud2
    258: xor     edi,edi
    25a: xor     esi,esi
    25c: call    ryo_h_Ret
    261: leave
    262: ret
    263: mov     rax,[rbp-18h]
    267: mov     [rbp-88h],rax
    26e: mov     byte ptr [rbp-0A1h],1
    275: test    byte ptr [rbp-0A1h],0FFh
    27c: je      2D9h
    27e: jmp     2A3h
    280: mov     qword ptr [rbp-0A8h],1
    28b: mov     rax,[rbp-38h]
    28f: imul    rcx,[rbp-0A8h],4
    297: add     rax,rcx
    29a: mov     [rbp-80h],rax
    29e: jmp     333h
    2a3: mov     rax,[rbp-88h]
    2aa: mov     [rbp-0E0h],rax
    2b1: mov     qword ptr [rbp-0D8h],1
    2bc: mov     edi,0FFFFFF30h
    2c1: lea     rsi,[k4]
    2c8: call    ryo_h_AddrAbs
    2cd: call    fn5
    2d2: nop     [rcx-60h]
    2d9: mov     rax,[rbp-88h]
    2e0: add     rax,1
    2e4: mov     [rbp-90h],rax
    2eb: mov     rax,[rbp-90h]
    2f2: mov     [rbp-18h],rax
    2f6: mov     rax,[rbp-28h]
    2fa: mov     [rbp-0E0h],rax
    301: mov     rax,[rbp-30h]
    305: mov     [rbp-0D8h],rax
    30c: mov     rax,[rbp+20h]
    310: mov     [rbp-0D0h],rax
    317: mov     rax,[rbp+28h]
    31b: mov     [rbp-0C8h],rax
    322: call    fn6
    327: nop     [rcx-90h]
    32e: jmp     110h
    333: mov     qword ptr [rbp-0A8h],1
    33e: mov     rax,[rbp-40h]
    342: imul    rcx,[rbp-0A8h],4
    34a: add     rax,rcx
    34d: mov     [rbp-88h],rax
    354: mov     qword ptr [rbp-0A8h],2
    35f: mov     edi,0FFFFFF68h
    364: mov     esi,0FFFFFF98h
    369: mov     edx,0FFFFFF58h
    36e: call    ryo_h_RemUW64
    373: cmp     qword ptr [rbp-98h],0
    37b: sete    [rbp-89h]
    382: test    byte ptr [rbp-89h],0FFh
    389: je      1A0h
    38f: jmp     190h
    394: mov     rax,[rbp-50h]
    398: mov     [rbp-98h],rax
    39f: mov     rax,[rbp+20h]
    3a3: mov     [rbp-0A0h],rax
    3aa: mov     rax,[rbp-98h]
    3b1: mov     [rbp-0E0h],rax
    3b8: mov     rax,[rbp-0A0h]
    3bf: mov     [rbp-0D8h],rax
    3c6: mov     qword ptr [rbp-0D0h],4
    3d1: mov     qword ptr [rbp-0C8h],4
    3dc: mov     qword ptr [rbp-0C0h],1
    3e7: mov     edi,0FFFFFF48h
    3ec: lea     rsi,[k7]
    3f3: call    ryo_h_AddrAbs
    3f8: call    fn8
    3fd: nop     [rcx-60h]
    404: mov     qword ptr [rbp-0A8h],1
    40f: imul    rax,[rbp-0A8h],4
    417: mov     [rbp-0B0h],rax
    41e: mov     edi,20h
    423: mov     esi,0FFFFFFB0h
    428: mov     edx,0FFFFFF50h
    42d: call    ryo_h_Memcpy
    432: mov     edi,0FFFFFF60h
    437: mov     esi,0FFFFFF76h
    43c: call    ryo_h_ZextW8W64
    441: mov     rax,[rbp-28h]
    445: imul    rcx,[rbp-0A0h],4
    44d: add     rax,rcx
    450: mov     [rbp-98h],rax
    457: mov     rax,[rbp-98h]
    45e: mov     [rbp-28h],rax
    462: movzx   eax,byte ptr [rbp-8Ah]
    469: xor     al,1
    46c: mov     [rbp-8Bh],al
    472: mov     edi,0FFFFFF60h
    477: mov     esi,0FFFFFF75h
    47c: call    ryo_h_ZextW8W64
    481: mov     rax,[rbp-30h]
    485: imul    rcx,[rbp-0A0h],4
    48d: add     rax,rcx
    490: mov     [rbp-98h],rax
    497: mov     rax,[rbp-98h]
    49e: mov     [rbp-30h],rax
    4a2: jmp     200h

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-71h],0
      f: test    byte ptr [rbp-71h],0FFh
     13: je      19Ch
     19: jmp     192h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      6Bh
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-40h],rax
     2e: mov     rax,[rbp-40h]
     32: mov     rax,[rax]
     35: mov     [rbp-38h],rax
     39: mov     rax,[rbp-38h]
     3d: mov     [rbp-40h],rax
     41: mov     rax,[rbp-40h]
     45: mov     [rbp-30h],rax
     49: lea     rax,[rbp-30h]
     4d: mov     [rbp-50h],rax
     51: mov     rax,[rbp-50h]
     55: mov     [rbp-48h],rax
     59: mov     rax,[rbp+18h]
     5d: mov     [rbp-40h],rax
     61: mov     qword ptr [rbp-38h],1
     69: jmp     70h
     6b: jmp     0F7h
     70: mov     rax,[rbp-8]
     74: mov     [rbp-18h],rax
     78: mov     rax,[rbp-18h]
     7c: mov     [rbp-50h],rax
     80: mov     rax,[rbp-40h]
     84: mov     [rbp-58h],rax
     88: mov     byte ptr [rbp-71h],1
     8c: test    byte ptr [rbp-71h],0FFh
     90: je      21Ah
     96: jmp     1B6h
     9b: nop     [rax+rax]
     a0: jmp     0D8h
     a2: nop     [rax+rax]
     ab: nop     [rax+rax]
     b0: mov     byte ptr [rbp-71h],0
     b4: test    byte ptr [rbp-71h],0FFh
     b8: je      2D4h
     be: jmp     2CAh
     c3: nop     [rax+rax]
     cc: nop     [rax]
     d0: test    byte ptr [rbp-49h],0FFh
     d4: je      0D8h
     d6: jmp     70h
     d8: lea     rax,[rbp-48h]
     dc: mov     [rbp-78h],rax
     e0: mov     rax,[rbp-78h]
     e4: mov     [rbp-0B0h],rax
     eb: call    fn0
     f0: nop     [rcx-78h]
     f7: xor     edi,edi
     f9: xor     esi,esi
     fb: call    ryo_h_Ret
    100: leave
    101: ret
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: lea     rax,[rbp-48h]
    114: mov     [rbp-78h],rax
    118: mov     rax,[rbp-78h]
    11c: mov     [rbp-0B0h],rax
    123: call    fn1
    128: nop     [rcx-78h]
    12f: mov     edi,0FFFFFFD8h
    134: call    ryo_h_Resume
    139: ud2
    13b: nop     [rax+rax]
    140: mov     rax,[rbp+18h]
    144: mov     [rbp-48h],rax
    148: mov     rax,[rbp-8]
    14c: mov     [rbp-50h],rax
    150: mov     rax,[rbp-48h]
    154: mov     [rbp-40h],rax
    158: mov     rax,[rbp-50h]
    15c: mov     [rbp-38h],rax
    160: mov     rax,[rbp+20h]
    164: mov     [rbp-0B0h],rax
    16b: mov     rax,[rbp-40h]
    16f: mov     [rbp-0A8h],rax
    176: mov     rax,[rbp-38h]
    17a: mov     [rbp-0A0h],rax
    181: call    fn2
    186: nop     [rcx-29h]
    18d: jmp     20h
    192: mov     rax,[rbp+18h]
    196: mov     [rbp-8],rax
    19a: jmp     140h
    19c: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    1a4: mov     rax,[rbp+18h]
    1a8: imul    rcx,[rbp-78h],8
    1ad: add     rax,rcx
    1b0: mov     [rbp-8],rax
    1b4: jmp     140h
    1b6: mov     rax,[rbp-18h]
    1ba: mov     [rbp-60h],rax
    1be: mov     rax,[rbp-58h]
    1c2: mov     [rbp-68h],rax
    1c6: mov     rax,[rbp-60h]
    1ca: mov     [rbp-0B0h],rax
    1d1: mov     rax,[rbp-68h]
    1d5: mov     [rbp-0A8h],rax
    1dc: mov     qword ptr [rbp-0A0h],8
    1e7: mov     qword ptr [rbp-98h],4
    1f2: mov     qword ptr [rbp-90h],1
    1fd: mov     edi,0FFFFFF78h
    202: lea     rsi,[k3]
    209: call    ryo_h_AddrAbs
    20e: call    fn4
    213: nop     [rcx-20h]
    21a: mov     qword ptr [rbp-78h],1
    222: imul    rax,[rbp-78h],8
    227: mov     [rbp-80h],rax
    22b: mov     edi,0FFFFFFA8h
    230: mov     esi,0FFFFFFB0h
    235: mov     edx,0FFFFFF80h
    23a: call    ryo_h_Memcpy
    23f: mov     rax,[rbp-8]
    243: mov     [rbp-50h],rax
    247: mov     rax,[rbp-50h]
    24b: mov     [rbp-40h],rax
    24f: mov     rax,[rbp-8]
    253: mov     [rbp-58h],rax
    257: mov     rax,[rbp-58h]
    25b: cmp     rax,[rbp+10h]
    25f: je      0A0h
    265: jmp     0B0h
    26a: nop     [rax+rax]
    270: mov     rax,[rbp-50h]
    274: mov     [rbp-8],rax
    278: lea     rax,[rbp-30h]
    27c: mov     [rbp-68h],rax
    280: mov     rax,[rbp-8]
    284: mov     [rbp-70h],rax
    288: mov     rax,[rbp-68h]
    28c: mov     [rbp-60h],rax
    290: mov     rax,[rbp-70h]
    294: mov     [rbp-58h],rax
    298: mov     rax,[rbp+20h]
    29c: mov     [rbp-0B0h],rax
    2a3: mov     rax,[rbp-60h]
    2a7: mov     [rbp-0A8h],rax
    2ae: mov     rax,[rbp-58h]
    2b2: mov     [rbp-0A0h],rax
    2b9: call    fn5
    2be: nop     [rcx-49h]
    2c5: jmp     0D0h
    2ca: mov     rax,[rbp-8]
    2ce: mov     [rbp-50h],rax
    2d2: jmp     270h
    2d4: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    2dc: mov     rax,[rbp-8]
    2e0: imul    rcx,[rbp-78h],8
    2e5: add     rax,rcx
    2e8: mov     [rbp-50h],rax
    2ec: jmp     270h
    2ee: xchg    ax,ax
    2f0: lea     rdi,[sym6]
    2f7: lea     rsi,[site7]
    2fe: mov     edx,0FFFFFF88h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-70h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+4]
    322: call    qword ptr [sym8]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFFD8h
    337: call    ryo_h_Lpad
    33c: jmp     2F0h
    33e: mov     rdi,rax
    341: mov     esi,0FFFFFFD8h
    346: call    ryo_h_Lpad
    34b: jmp     110h

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-69h],0
      f: test    byte ptr [rbp-69h],0FFh
     13: je      19Ch
     19: jmp     192h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      65h
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-38h],rax
     2e: mov     rax,[rbp-38h]
     32: mov     eax,[rax]
     34: mov     [rbp-30h],eax
     37: mov     eax,[rbp-30h]
     3a: mov     [rbp-34h],eax
     3d: mov     eax,[rbp-34h]
     40: mov     [rbp-2Ch],eax
     43: lea     rax,[rbp-2Ch]
     47: mov     [rbp-50h],rax
     4b: mov     rax,[rbp-50h]
     4f: mov     [rbp-48h],rax
     53: mov     rax,[rbp+18h]
     57: mov     [rbp-40h],rax
     5b: mov     qword ptr [rbp-38h],1
     63: jmp     70h
     65: jmp     0F7h
     6a: nop     [rax+rax]
     70: mov     rax,[rbp-8]
     74: mov     [rbp-18h],rax
     78: mov     rax,[rbp-18h]
     7c: mov     [rbp-50h],rax
     80: mov     rax,[rbp-40h]
     84: mov     [rbp-58h],rax
     88: mov     byte ptr [rbp-69h],1
     8c: test    byte ptr [rbp-69h],0FFh
     90: je      21Ah
     96: jmp     1B6h
     9b: nop     [rax+rax]
     a0: jmp     0D8h
     a2: nop     [rax+rax]
     ab: nop     [rax+rax]
     b0: mov     byte ptr [rbp-69h],0
     b4: test    byte ptr [rbp-69h],0FFh
     b8: je      2D4h
     be: jmp     2CAh
     c3: nop     [rax+rax]
     cc: nop     [rax]
     d0: test    byte ptr [rbp-2Dh],0FFh
     d4: je      0D8h
     d6: jmp     70h
     d8: lea     rax,[rbp-48h]
     dc: mov     [rbp-70h],rax
     e0: mov     rax,[rbp-70h]
     e4: mov     [rbp-0B0h],rax
     eb: call    fn0
     f0: nop     [rcx-70h]
     f7: xor     edi,edi
     f9: xor     esi,esi
     fb: call    ryo_h_Ret
    100: leave
    101: ret
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: lea     rax,[rbp-48h]
    114: mov     [rbp-70h],rax
    118: mov     rax,[rbp-70h]
    11c: mov     [rbp-0B0h],rax
    123: call    fn1
    128: nop     [rcx-70h]
    12f: mov     edi,0FFFFFFD8h
    134: call    ryo_h_Resume
    139: ud2
    13b: nop     [rax+rax]
    140: mov     rax,[rbp+18h]
    144: mov     [rbp-48h],rax
    148: mov     rax,[rbp-8]
    14c: mov     [rbp-50h],rax
    150: mov     rax,[rbp-48h]
    154: mov     [rbp-40h],rax
    158: mov     rax,[rbp-50h]
    15c: mov     [rbp-38h],rax
    160: mov     rax,[rbp+20h]
    164: mov     [rbp-0B0h],rax
    16b: mov     rax,[rbp-40h]
    16f: mov     [rbp-0A8h],rax
    176: mov     rax,[rbp-38h]
    17a: mov     [rbp-0A0h],rax
    181: call    fn2
    186: nop     [rcx-29h]
    18d: jmp     20h
    192: mov     rax,[rbp+18h]
    196: mov     [rbp-8],rax
    19a: jmp     140h
    19c: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    1a4: mov     rax,[rbp+18h]
    1a8: imul    rcx,[rbp-70h],4
    1ad: add     rax,rcx
    1b0: mov     [rbp-8],rax
    1b4: jmp     140h
    1b6: mov     rax,[rbp-18h]
    1ba: mov     [rbp-60h],rax
    1be: mov     rax,[rbp-58h]
    1c2: mov     [rbp-68h],rax
    1c6: mov     rax,[rbp-60h]
    1ca: mov     [rbp-0B0h],rax
    1d1: mov     rax,[rbp-68h]
    1d5: mov     [rbp-0A8h],rax
    1dc: mov     qword ptr [rbp-0A0h],4
    1e7: mov     qword ptr [rbp-98h],4
    1f2: mov     qword ptr [rbp-90h],1
    1fd: mov     edi,0FFFFFF78h
    202: lea     rsi,[k3]
    209: call    ryo_h_AddrAbs
    20e: call    fn4
    213: nop     [rcx-20h]
    21a: mov     qword ptr [rbp-70h],1
    222: imul    rax,[rbp-70h],4
    227: mov     [rbp-78h],rax
    22b: mov     edi,0FFFFFFA8h
    230: mov     esi,0FFFFFFB0h
    235: mov     edx,0FFFFFF88h
    23a: call    ryo_h_Memcpy
    23f: mov     rax,[rbp-8]
    243: mov     [rbp-50h],rax
    247: mov     rax,[rbp-50h]
    24b: mov     [rbp-40h],rax
    24f: mov     rax,[rbp-8]
    253: mov     [rbp-50h],rax
    257: mov     rax,[rbp-50h]
    25b: cmp     rax,[rbp+10h]
    25f: je      0A0h
    265: jmp     0B0h
    26a: nop     [rax+rax]
    270: mov     rax,[rbp-50h]
    274: mov     [rbp-8],rax
    278: lea     rax,[rbp-2Ch]
    27c: mov     [rbp-60h],rax
    280: mov     rax,[rbp-8]
    284: mov     [rbp-68h],rax
    288: mov     rax,[rbp-60h]
    28c: mov     [rbp-58h],rax
    290: mov     rax,[rbp-68h]
    294: mov     [rbp-50h],rax
    298: mov     rax,[rbp+20h]
    29c: mov     [rbp-0B0h],rax
    2a3: mov     rax,[rbp-58h]
    2a7: mov     [rbp-0A8h],rax
    2ae: mov     rax,[rbp-50h]
    2b2: mov     [rbp-0A0h],rax
    2b9: call    fn5
    2be: nop     [rcx-2Dh]
    2c5: jmp     0D0h
    2ca: mov     rax,[rbp-8]
    2ce: mov     [rbp-50h],rax
    2d2: jmp     270h
    2d4: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    2dc: mov     rax,[rbp-8]
    2e0: imul    rcx,[rbp-70h],4
    2e5: add     rax,rcx
    2e8: mov     [rbp-50h],rax
    2ec: jmp     270h
    2ee: xchg    ax,ax
    2f0: lea     rdi,[sym6]
    2f7: lea     rsi,[site7]
    2fe: mov     edx,0FFFFFF90h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-68h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+4]
    322: call    qword ptr [sym8]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFFD8h
    337: call    ryo_h_Lpad
    33c: jmp     2F0h
    33e: mov     rdi,rax
    341: mov     esi,0FFFFFFD8h
    346: call    ryo_h_Lpad
    34b: jmp     110h

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp+20h],0
     15: je      21h
     17: mov     rax,[rbp-10h]
     1b: cmp     rax,[rbp+20h]
     1f: jae     28h
     21: call    ryo_h_Abort
     26: ud2
     28: mov     rax,[rbp+10h]
     2c: mov     [rbp-28h],rax
     30: mov     rax,[rbp+18h]
     34: mov     [rbp-20h],rax
     38: mov     rax,[rbp-28h]
     3c: mov     [rbp-18h],rax
     40: mov     rax,[rbp-18h]
     44: imul    rcx,[rbp-10h],8
     49: add     rax,rcx
     4c: mov     [rbp-20h],rax
     50: mov     rax,[rbp-18h]
     54: imul    rcx,[rbp+20h],8
     59: add     rax,rcx
     5c: mov     [rbp-8],rax
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: mov     rax,[rbp-30h]
     6c: cmp     rax,[rbp-20h]
     70: je      0C0h
     72: mov     rax,[rbp-8]
     76: mov     [rbp-30h],rax
     7a: mov     rax,[rbp-18h]
     7e: mov     [rbp-50h],rax
     82: mov     rax,[rbp-30h]
     86: mov     [rbp-48h],rax
     8a: mov     rax,[rbp+28h]
     8e: mov     [rbp-40h],rax
     92: call    fn0
     97: nop     [rcx-8]
     9e: mov     qword ptr [rbp-38h],1
     a6: mov     rax,[rbp-8]
     aa: imul    rcx,[rbp-38h],8
     af: add     rax,rcx
     b2: mov     [rbp-30h],rax
     b6: mov     rax,[rbp-30h]
     ba: mov     [rbp-8],rax
     be: jmp     60h
     c0: xor     edi,edi
     c2: xor     esi,esi
     c4: call    ryo_h_Ret
     c9: leave
     ca: ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp+20h],0
     15: je      21h
     17: mov     rax,[rbp-10h]
     1b: cmp     rax,[rbp+20h]
     1f: jae     28h
     21: call    ryo_h_Abort
     26: ud2
     28: mov     rax,[rbp+10h]
     2c: mov     [rbp-28h],rax
     30: mov     rax,[rbp+18h]
     34: mov     [rbp-20h],rax
     38: mov     rax,[rbp-28h]
     3c: mov     [rbp-18h],rax
     40: mov     rax,[rbp-18h]
     44: imul    rcx,[rbp-10h],4
     49: add     rax,rcx
     4c: mov     [rbp-20h],rax
     50: mov     rax,[rbp-18h]
     54: imul    rcx,[rbp+20h],4
     59: add     rax,rcx
     5c: mov     [rbp-8],rax
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: mov     rax,[rbp-30h]
     6c: cmp     rax,[rbp-20h]
     70: je      0C0h
     72: mov     rax,[rbp-8]
     76: mov     [rbp-30h],rax
     7a: mov     rax,[rbp-18h]
     7e: mov     [rbp-50h],rax
     82: mov     rax,[rbp-30h]
     86: mov     [rbp-48h],rax
     8a: mov     rax,[rbp+28h]
     8e: mov     [rbp-40h],rax
     92: call    fn0
     97: nop     [rcx-8]
     9e: mov     qword ptr [rbp-38h],1
     a6: mov     rax,[rbp-8]
     aa: imul    rcx,[rbp-38h],4
     af: add     rax,rcx
     b2: mov     [rbp-30h],rax
     b6: mov     rax,[rbp-30h]
     ba: mov     [rbp-8],rax
     be: jmp     60h
     c0: xor     edi,edi
     c2: xor     esi,esi
     c4: call    ryo_h_Ret
     c9: leave
     ca: ret

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
    144: mov     rax,[rbp-38h]
    148: mov     [rbp+18h],rax
    14c: mov     edi,0FFFFFFC0h
    151: mov     esi,0FFFFFFE7h
    156: call    ryo_h_ZextW8W64
    15b: mov     rax,[rbp-40h]
    15f: mov     [rbp-50h],rax
    163: mov     qword ptr [rbp-58h],0
    16b: mov     rax,[rbp-58h]
    16f: sub     rax,[rbp-50h]
    173: mov     [rbp-48h],rax
    177: mov     rax,[rbp+10h]
    17b: imul    rcx,[rbp-48h],8
    180: add     rax,rcx
    183: mov     [rbp-38h],rax
    187: mov     rax,[rbp-38h]
    18b: mov     [rbp+10h],rax
    18f: mov     byte ptr [rbp-51h],0
    193: test    byte ptr [rbp-51h],0FFh
    197: je      1DBh
    199: jmp     1D1h
    19b: nop     [rax+rax]
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
    144: mov     rax,[rbp-38h]
    148: mov     [rbp+18h],rax
    14c: mov     edi,0FFFFFFC0h
    151: mov     esi,0FFFFFFE7h
    156: call    ryo_h_ZextW8W64
    15b: mov     rax,[rbp-40h]
    15f: mov     [rbp-50h],rax
    163: mov     qword ptr [rbp-58h],0
    16b: mov     rax,[rbp-58h]
    16f: sub     rax,[rbp-50h]
    173: mov     [rbp-48h],rax
    177: mov     rax,[rbp+10h]
    17b: imul    rcx,[rbp-48h],4
    180: add     rax,rcx
    183: mov     [rbp-38h],rax
    187: mov     rax,[rbp-38h]
    18b: mov     [rbp+10h],rax
    18f: mov     byte ptr [rbp-51h],0
    193: test    byte ptr [rbp-51h],0FFh
    197: je      1DBh
    199: jmp     1D1h
    19b: nop     [rax+rax]
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
    128: mov     rax,[rbp-38h]
    12c: mov     [rbp+18h],rax
    130: mov     edi,0FFFFFFC0h
    135: mov     esi,0FFFFFFD7h
    13a: call    ryo_h_ZextW8W64
    13f: mov     rax,[rbp+10h]
    143: imul    rcx,[rbp-40h],8
    148: add     rax,rcx
    14b: mov     [rbp-38h],rax
    14f: mov     rax,[rbp-38h]
    153: mov     [rbp+10h],rax
    157: mov     qword ptr [rbp-58h],1
    15f: mov     rax,[rbp+20h]
    163: imul    rcx,[rbp-58h],8
    168: add     rax,rcx
    16b: mov     [rbp-38h],rax
    16f: mov     rax,[rbp-38h]
    173: mov     [rbp+20h],rax
    177: mov     rax,[rbp+10h]
    17b: mov     [rbp-18h],rax
    17f: mov     rax,[rbp+18h]
    183: mov     [rbp-10h],rax
    187: mov     rax,[rbp+20h]
    18b: mov     [rbp-8],rax
    18f: mov     edi,0FFFFFFE8h
    194: mov     esi,18h
    199: call    ryo_h_Ret
    19e: leave
    19f: ret

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
    128: mov     rax,[rbp-38h]
    12c: mov     [rbp+18h],rax
    130: mov     edi,0FFFFFFC0h
    135: mov     esi,0FFFFFFD7h
    13a: call    ryo_h_ZextW8W64
    13f: mov     rax,[rbp+10h]
    143: imul    rcx,[rbp-40h],4
    148: add     rax,rcx
    14b: mov     [rbp-38h],rax
    14f: mov     rax,[rbp-38h]
    153: mov     [rbp+10h],rax
    157: mov     qword ptr [rbp-58h],1
    15f: mov     rax,[rbp+20h]
    163: imul    rcx,[rbp-58h],4
    168: add     rax,rcx
    16b: mov     [rbp-38h],rax
    16f: mov     rax,[rbp-38h]
    173: mov     [rbp+20h],rax
    177: mov     rax,[rbp+10h]
    17b: mov     [rbp-18h],rax
    17f: mov     rax,[rbp+18h]
    183: mov     [rbp-10h],rax
    187: mov     rax,[rbp+20h]
    18b: mov     [rbp-8],rax
    18f: mov     edi,0FFFFFFE8h
    194: mov     esi,18h
    199: call    ryo_h_Ret
    19e: leave
    19f: ret

fn core::slice::sort::shared::smallsort::small_sort_general::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,130h
      b: lea     rax,[rbp-0E0h]
     12: mov     [rbp-20h],rax
     16: mov     rax,[rbp-20h]
     1a: mov     [rbp-0E8h],rax
     21: mov     byte ptr [rbp-0F9h],1
     28: test    byte ptr [rbp-0F9h],0FFh
     2f: je      0A2h
     31: jmp     4Bh
     33: nop     [rax+rax]
     3c: nop     [rax]
     40: xor     edi,edi
     42: xor     esi,esi
     44: call    ryo_h_Ret
     49: leave
     4a: ret
     4b: mov     rax,[rbp-20h]
     4f: mov     [rbp-0F0h],rax
     56: mov     rax,[rbp-0F0h]
     5d: mov     [rbp-130h],rax
     64: mov     qword ptr [rbp-128h],4
     6f: mov     qword ptr [rbp-120h],4
     7a: mov     qword ptr [rbp-118h],30h
     85: mov     edi,0FFFFFEF0h
     8a: lea     rsi,[k0]
     91: call    ryo_h_AddrAbs
     96: call    fn1
     9b: nop     [rcx-20h]
     a2: mov     rax,[rbp-20h]
     a6: mov     [rbp-0F8h],rax
     ad: mov     qword ptr [rbp-0F0h],30h
     b8: mov     rax,[rbp-0F8h]
     bf: mov     [rbp-10h],rax
     c3: mov     rax,[rbp-0F0h]
     ca: mov     [rbp-8],rax
     ce: mov     edi,0FFFFFED0h
     d3: mov     esi,10h
     d8: call    ryo_h_MovW128
     dd: mov     edi,0FFFFFEE0h
     e2: mov     esi,0FFFFFFF0h
     e7: call    ryo_h_MovW128
     ec: mov     rax,[rbp+20h]
     f0: mov     [rbp-110h],rax
     f7: call    fn2
     fc: nop     [rcx-18h]
    103: jmp     40h

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,190h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: cmp     qword ptr [rbp-90h],2
     1e: jae     25h
     20: jmp     54Ah
     25: mov     rax,[rbp+28h]
     29: mov     [rbp-0A0h],rax
     30: mov     rax,[rbp-90h]
     37: add     rax,10h
     3b: mov     [rbp-0A8h],rax
     42: mov     rax,[rbp-0A0h]
     49: cmp     rax,[rbp-0A8h]
     50: jae     59h
     52: call    ryo_h_Abort
     57: ud2
     59: mov     rax,[rbp+10h]
     5d: mov     [rbp-60h],rax
     61: mov     rax,[rbp+18h]
     65: mov     [rbp-58h],rax
     69: mov     rax,[rbp-60h]
     6d: mov     [rbp-98h],rax
     74: mov     qword ptr [rbp-150h],2
     7f: mov     edi,0FFFFFF60h
     84: mov     esi,0FFFFFF70h
     89: mov     edx,0FFFFFEB0h
     8e: call    ryo_h_DivUW64
     93: mov     rax,[rbp+20h]
     97: mov     [rbp-70h],rax
     9b: mov     rax,[rbp+28h]
     9f: mov     [rbp-68h],rax
     a3: mov     rax,[rbp-70h]
     a7: mov     [rbp-8],rax
     ab: mov     byte ptr [rbp-149h],1
     b2: test    byte ptr [rbp-149h],0FFh
     b9: je      1C9h
     bf: cmp     qword ptr [rbp-90h],10h
     c7: jb      1C9h
     cd: mov     rax,[rbp-8]
     d1: imul    rcx,[rbp-90h],8
     d9: add     rax,rcx
     dc: mov     [rbp-0B8h],rax
     e3: mov     rax,[rbp-98h]
     ea: mov     [rbp-190h],rax
     f1: mov     rax,[rbp-8]
     f5: mov     [rbp-188h],rax
     fc: mov     rax,[rbp-0B8h]
    103: mov     [rbp-180h],rax
    10a: mov     rax,[rbp+30h]
    10e: mov     [rbp-178h],rax
    115: call    fn0
    11a: nop     [rcx-8]
    121: mov     rax,[rbp-98h]
    128: imul    rcx,[rbp-0A0h],8
    130: add     rax,rcx
    133: mov     [rbp-0B8h],rax
    13a: mov     rax,[rbp-8]
    13e: imul    rcx,[rbp-0A0h],8
    146: add     rax,rcx
    149: mov     [rbp-0C0h],rax
    150: mov     rax,[rbp-90h]
    157: add     rax,8
    15b: mov     [rbp-0D0h],rax
    162: mov     rax,[rbp-8]
    166: imul    rcx,[rbp-0D0h],8
    16e: add     rax,rcx
    171: mov     [rbp-0C8h],rax
    178: mov     rax,[rbp-0B8h]
    17f: mov     [rbp-190h],rax
    186: mov     rax,[rbp-0C0h]
    18d: mov     [rbp-188h],rax
    194: mov     rax,[rbp-0C8h]
    19b: mov     [rbp-180h],rax
    1a2: mov     rax,[rbp+30h]
    1a6: mov     [rbp-178h],rax
    1ad: call    fn1
    1b2: nop     [rcx-8]
    1b9: mov     qword ptr [rbp-0A8h],8
    1c4: jmp     2C0h
    1c9: cmp     qword ptr [rbp-90h],8
    1d1: jb      28Fh
    1d7: mov     rax,[rbp-60h]
    1db: mov     [rbp-0B8h],rax
    1e2: mov     rax,[rbp-0B8h]
    1e9: mov     [rbp-190h],rax
    1f0: mov     rax,[rbp-8]
    1f4: mov     [rbp-188h],rax
    1fb: mov     rax,[rbp+30h]
    1ff: mov     [rbp-180h],rax
    206: call    fn2
    20b: nop     [rcx-8]
    212: mov     rax,[rbp-98h]
    219: imul    rcx,[rbp-0A0h],8
    221: add     rax,rcx
    224: mov     [rbp-0C0h],rax
    22b: mov     rax,[rbp-0C0h]
    232: mov     [rbp-0B8h],rax
    239: mov     rax,[rbp-8]
    23d: imul    rcx,[rbp-0A0h],8
    245: add     rax,rcx
    248: mov     [rbp-0C0h],rax
    24f: mov     rax,[rbp-0B8h]
    256: mov     [rbp-190h],rax
    25d: mov     rax,[rbp-0C0h]
    264: mov     [rbp-188h],rax
    26b: mov     rax,[rbp+30h]
    26f: mov     [rbp-180h],rax
    276: call    fn3
    27b: nop     [rcx-8]
    282: mov     qword ptr [rbp-0A8h],4
    28d: jmp     2C0h
    28f: mov     rax,[rbp-60h]
    293: mov     [rbp-0B8h],rax
    29a: mov     byte ptr [rbp-149h],1
    2a1: test    byte ptr [rbp-149h],0FFh
    2a8: je      63Ah
    2ae: jmp     5CAh
    2b3: nop     [rax+rax]
    2bc: nop     [rax]
    2c0: mov     qword ptr [rbp-0D8h],0
    2cb: mov     rax,[rbp-0A0h]
    2d2: mov     [rbp-0D0h],rax
    2d9: mov     edi,0FFFFFF18h
    2de: mov     esi,0FFFFFF28h
    2e3: call    ryo_h_MovW128
    2e8: mov     edi,0FFFFFEF8h
    2ed: lea     rsi,[k4]
    2f4: mov     edx,10h
    2f9: call    ryo_h_Const
    2fe: mov     edi,0FFFFFF08h
    303: mov     esi,0FFFFFF18h
    308: call    ryo_h_MovW128
    30d: mov     edi,0FFFFFEB8h
    312: mov     esi,0FFFFFEF8h
    317: mov     edx,20h
    31c: call    ryo_h_Copy
    321: mov     edi,0FFFFFED8h
    326: mov     esi,0FFFFFEB8h
    32b: mov     edx,20h
    330: call    ryo_h_Copy
    335: mov     edi,0FFFFFF38h
    33a: mov     esi,0FFFFFED8h
    33f: mov     edx,20h
    344: call    ryo_h_Copy
    349: mov     edi,0FFFFFF18h
    34e: mov     esi,0FFFFFF38h
    353: mov     edx,20h
    358: call    ryo_h_Copy
    35d: nop     [rax]
    360: lea     rax,[rbp-0E8h]
    367: mov     [rbp-110h],rax
    36e: mov     rax,[rbp-110h]
    375: mov     [rbp-108h],rax
    37c: mov     qword ptr [rbp-100h],2
    387: mov     edi,0FFFFFE70h
    38c: mov     esi,0FFFFFEF8h
    391: call    ryo_h_MovW128
    396: call    fn5
    39b: nop     [rcx-0F8h]
    3a2: jmp     760h
    3a7: nop     [rax+rax]
    3b0: call    ryo_h_Unreachable
    3b5: ud2
    3b7: mov     rax,[rbp-0F0h]
    3be: mov     [rbp-100h],rax
    3c5: mov     rax,[rbp-98h]
    3cc: imul    rcx,[rbp-100h],8
    3d4: add     rax,rcx
    3d7: mov     [rbp-108h],rax
    3de: mov     rax,[rbp-8]
    3e2: imul    rcx,[rbp-100h],8
    3ea: add     rax,rcx
    3ed: mov     [rbp-110h],rax
    3f4: cmp     qword ptr [rbp-100h],0
    3fc: je      42Dh
    3fe: jmp     43Ah
    400: lea     rax,[rbp-0E8h]
    407: mov     [rbp-150h],rax
    40e: mov     rax,[rbp-150h]
    415: mov     [rbp-190h],rax
    41c: call    fn6
    421: nop     [rcx-150h]
    428: jmp     4B2h
    42d: mov     rax,[rbp-0A0h]
    434: mov     [rbp-28h],rax
    438: jmp     44Ch
    43a: mov     rax,[rbp-90h]
    441: sub     rax,[rbp-0A0h]
    448: mov     [rbp-28h],rax
    44c: mov     rax,[rbp-0A8h]
    453: mov     [rbp-118h],rax
    45a: mov     rax,[rbp-118h]
    461: mov     [rbp-38h],rax
    465: mov     rax,[rbp-28h]
    469: mov     [rbp-30h],rax
    46d: nop     [rax]
    470: mov     rax,[rbp-38h]
    474: mov     [rbp-130h],rax
    47b: mov     rax,[rbp-30h]
    47f: mov     [rbp-138h],rax
    486: mov     rax,[rbp-130h]
    48d: cmp     rax,[rbp-138h]
    494: setb    [rbp-121h]
    49b: test    byte ptr [rbp-121h],0FFh
    4a2: je      7B5h
    4a8: jmp     798h
    4ad: nop     [rax]
    4b0: jmp     470h
    4b2: mov     rax,[rbp-70h]
    4b6: mov     [rbp-0C8h],rax
    4bd: mov     rax,[rbp-0C8h]
    4c4: mov     [rbp-0C0h],rax
    4cb: mov     rax,[rbp-98h]
    4d2: mov     [rbp-0B8h],rax
    4d9: mov     rax,[rbp-90h]
    4e0: mov     [rbp-0B0h],rax
    4e7: mov     rax,[rbp-0C0h]
    4ee: mov     [rbp-0D8h],rax
    4f5: mov     rax,[rbp-0B0h]
    4fc: mov     [rbp-0E0h],rax
    503: mov     byte ptr [rbp-149h],1
    50a: test    byte ptr [rbp-149h],0FFh
    511: je      9ABh
    517: jmp     94Eh
    51c: nop     [rax]
    520: mov     rax,[rbp-0C0h]
    527: mov     [rbp-0C8h],rax
    52e: mov     rax,[rbp-0B8h]
    535: mov     [rbp-0D0h],rax
    53c: mov     rax,[rbp-0B0h]
    543: mov     [rbp-0D8h],rax
    54a: xor     edi,edi
    54c: xor     esi,esi
    54e: call    ryo_h_Ret
    553: leave
    554: ret
    555: nop     [rax+rax]
    55e: xchg    ax,ax
    560: lea     rax,[rbp-0E8h]
    567: mov     [rbp-150h],rax
    56e: mov     rax,[rbp-150h]
    575: mov     [rbp-190h],rax
    57c: call    fn7
    581: nop     [rcx-150h]
    588: nop     [rax+rax]
    590: mov     edi,0FFFFFF78h
    595: call    ryo_h_Resume
    59a: ud2
    59c: nop     [rax]
    5a0: lea     rax,[rbp-0C0h]
    5a7: mov     [rbp-150h],rax
    5ae: mov     rax,[rbp-150h]
    5b5: mov     [rbp-190h],rax
    5bc: call    fn8
    5c1: nop     [rcx-150h]
    5c8: jmp     590h
    5ca: mov     rax,[rbp-60h]
    5ce: mov     [rbp-0C0h],rax
    5d5: mov     rax,[rbp-70h]
    5d9: mov     [rbp-0C8h],rax
    5e0: mov     rax,[rbp-0C0h]
    5e7: mov     [rbp-190h],rax
    5ee: mov     rax,[rbp-0C8h]
    5f5: mov     [rbp-188h],rax
    5fc: mov     qword ptr [rbp-180h],8
    607: mov     qword ptr [rbp-178h],4
    612: mov     qword ptr [rbp-170h],1
    61d: mov     edi,0FFFFFE98h
    622: lea     rsi,[k9]
    629: call    ryo_h_AddrAbs
    62e: call    fn10
    633: nop     [rcx-70h]
    63a: mov     qword ptr [rbp-150h],1
    645: imul    rax,[rbp-150h],8
    64d: mov     [rbp-158h],rax
    654: mov     edi,0FFFFFFF8h
    659: mov     esi,0FFFFFF48h
    65e: mov     edx,0FFFFFEA8h
    663: call    ryo_h_Memcpy
    668: mov     rax,[rbp-98h]
    66f: imul    rcx,[rbp-0A0h],8
    677: add     rax,rcx
    67a: mov     [rbp-10h],rax
    67e: mov     rax,[rbp-10h]
    682: mov     [rbp-0B8h],rax
    689: mov     rax,[rbp-8]
    68d: imul    rcx,[rbp-0A0h],8
    695: add     rax,rcx
    698: mov     [rbp-0C0h],rax
    69f: mov     byte ptr [rbp-149h],1
    6a6: test    byte ptr [rbp-149h],0FFh
    6ad: je      722h
    6af: mov     rax,[rbp-10h]
    6b3: mov     [rbp-0C8h],rax
    6ba: mov     rax,[rbp-0C0h]
    6c1: mov     [rbp-0D0h],rax
    6c8: mov     rax,[rbp-0C8h]
    6cf: mov     [rbp-190h],rax
    6d6: mov     rax,[rbp-0D0h]
    6dd: mov     [rbp-188h],rax
    6e4: mov     qword ptr [rbp-180h],8
    6ef: mov     qword ptr [rbp-178h],4
    6fa: mov     qword ptr [rbp-170h],1
    705: mov     edi,0FFFFFE98h
    70a: lea     rsi,[k11]
    711: call    ryo_h_AddrAbs
    716: call    fn12
    71b: nop     [rcx-70h]
    722: mov     qword ptr [rbp-150h],1
    72d: imul    rax,[rbp-150h],8
    735: mov     [rbp-158h],rax
    73c: mov     edi,0FFFFFF40h
    741: mov     esi,0FFFFFF48h
    746: mov     edx,0FFFFFEA8h
    74b: call    ryo_h_Memcpy
    750: mov     qword ptr [rbp-0A8h],1
    75b: jmp     2C0h
    760: mov     rax,[rbp-0F8h]
    767: mov     [rbp-20h],rax
    76b: mov     edi,0FFFFFFE0h
    770: xor     esi,esi
    772: mov     edx,2
    777: call    ryo_h_SwitchDenseW64
    77c: lea     rcx,[78Ch]
    783: movsxd  rax,[rcx+rax*4]
    787: add     rax,rcx
    78a: jmp     rax
    78c: .long   400h
    790: .long   3b7h
    794: .long   3b0h
    798: mov     rax,[rbp-38h]
    79c: mov     [rbp-130h],rax
    7a3: mov     byte ptr [rbp-149h],1
    7aa: test    byte ptr [rbp-149h],0FFh
    7b1: je      7F0h
    7b3: jmp     7BAh
    7b5: jmp     360h
    7ba: mov     rax,[rbp-130h]
    7c1: mov     [rbp-190h],rax
    7c8: mov     qword ptr [rbp-188h],1
    7d3: mov     edi,0FFFFFE80h
    7d8: lea     rsi,[k13]
    7df: call    ryo_h_AddrAbs
    7e4: call    fn14
    7e9: nop     [rcx-80h]
    7f0: mov     rax,[rbp-130h]
    7f7: add     rax,1
    7fb: mov     [rbp-138h],rax
    802: mov     rax,[rbp-138h]
    809: mov     [rbp-38h],rax
    80d: mov     rax,[rbp-130h]
    814: mov     [rbp-118h],rax
    81b: mov     qword ptr [rbp-120h],1
    826: mov     rax,[rbp-118h]
    82d: mov     [rbp-128h],rax
    834: mov     rax,[rbp-108h]
    83b: imul    rcx,[rbp-128h],8
    843: add     rax,rcx
    846: mov     [rbp-48h],rax
    84a: mov     rax,[rbp-48h]
    84e: mov     [rbp-130h],rax
    855: mov     rax,[rbp-110h]
    85c: imul    rcx,[rbp-128h],8
    864: add     rax,rcx
    867: mov     [rbp-50h],rax
    86b: mov     byte ptr [rbp-149h],1
    872: test    byte ptr [rbp-149h],0FFh
    879: je      8EBh
    87b: mov     rax,[rbp-48h]
    87f: mov     [rbp-138h],rax
    886: mov     rax,[rbp-50h]
    88a: mov     [rbp-140h],rax
    891: mov     rax,[rbp-138h]
    898: mov     [rbp-190h],rax
    89f: mov     rax,[rbp-140h]
    8a6: mov     [rbp-188h],rax
    8ad: mov     qword ptr [rbp-180h],8
    8b8: mov     qword ptr [rbp-178h],4
    8c3: mov     qword ptr [rbp-170h],1
    8ce: mov     edi,0FFFFFE98h
    8d3: lea     rsi,[k15]
    8da: call    ryo_h_AddrAbs
    8df: call    fn16
    8e4: nop     [rcx-80h]
    8eb: mov     qword ptr [rbp-150h],1
    8f6: imul    rax,[rbp-150h],8
    8fe: mov     [rbp-158h],rax
    905: mov     edi,0FFFFFFB0h
    90a: mov     esi,0FFFFFED0h
    90f: mov     edx,0FFFFFEA8h
    914: call    ryo_h_Memcpy
    919: mov     rax,[rbp-110h]
    920: mov     [rbp-190h],rax
    927: mov     rax,[rbp-50h]
    92b: mov     [rbp-188h],rax
    932: mov     rax,[rbp+30h]
    936: mov     [rbp-180h],rax
    93d: call    fn17
    942: nop     [rcx-50h]
    949: jmp     4B0h
    94e: mov     rax,[rbp-0D8h]
    955: mov     [rbp-0E8h],rax
    95c: mov     rax,[rbp-0E8h]
    963: mov     [rbp-190h],rax
    96a: mov     qword ptr [rbp-188h],8
    975: mov     qword ptr [rbp-180h],4
    980: mov     rax,[rbp-0E0h]
    987: mov     [rbp-178h],rax
    98e: mov     edi,0FFFFFE90h
    993: lea     rsi,[k18]
    99a: call    ryo_h_AddrAbs
    99f: call    fn19
    9a4: nop     [rcx-80h]
    9ab: mov     rax,[rbp-0D8h]
    9b2: mov     [rbp-0F0h],rax
    9b9: mov     rax,[rbp-0E0h]
    9c0: mov     [rbp-0E8h],rax
    9c7: mov     rax,[rbp-0F0h]
    9ce: mov     [rbp-0D0h],rax
    9d5: mov     rax,[rbp-0E8h]
    9dc: mov     [rbp-0C8h],rax
    9e3: mov     rax,[rbp-0B8h]
    9ea: mov     [rbp-0D8h],rax
    9f1: mov     edi,0FFFFFE70h
    9f6: mov     esi,0FFFFFF30h
    9fb: call    ryo_h_MovW128
    a00: mov     rax,[rbp-0D8h]
    a07: mov     [rbp-180h],rax
    a0e: mov     rax,[rbp+30h]
    a12: mov     [rbp-178h],rax
    a19: call    fn20
    a1e: nop     [rcx-50h]
    a25: jmp     520h
    a2a: nop     [rax+rax]
    a30: lea     rdi,[sym21]
    a37: lea     rsi,[site22]
    a3e: mov     edx,0FFFFFEB0h
    a43: call    ryo_h_CallExt
    a48: test    rax,rax
    a4b: je      0A58h
    a4d: call    rax
    a4f: nop     [rcx-148h]
    a56: jmp     0A68h
    a58: mov     rdi,rbp
    a5b: lea     rsi,[ro+4]
    a62: call    qword ptr [sym23]
    a68: call    ryo_h_Unreachable
    a6d: ud2
    a6f: mov     rdi,rax
    a72: mov     esi,0FFFFFF78h
    a77: call    ryo_h_Lpad
    a7c: jmp     560h
    a81: mov     rdi,rax
    a84: mov     esi,0FFFFFF78h
    a89: call    ryo_h_Lpad
    a8e: jmp     0A30h
    a90: mov     rdi,rax
    a93: mov     esi,0FFFFFF78h
    a98: call    ryo_h_Lpad
    a9d: jmp     5A0h

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,190h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: cmp     qword ptr [rbp-90h],2
     1e: jae     25h
     20: jmp     54Ah
     25: mov     rax,[rbp+28h]
     29: mov     [rbp-0A0h],rax
     30: mov     rax,[rbp-90h]
     37: add     rax,10h
     3b: mov     [rbp-0A8h],rax
     42: mov     rax,[rbp-0A0h]
     49: cmp     rax,[rbp-0A8h]
     50: jae     59h
     52: call    ryo_h_Abort
     57: ud2
     59: mov     rax,[rbp+10h]
     5d: mov     [rbp-60h],rax
     61: mov     rax,[rbp+18h]
     65: mov     [rbp-58h],rax
     69: mov     rax,[rbp-60h]
     6d: mov     [rbp-98h],rax
     74: mov     qword ptr [rbp-150h],2
     7f: mov     edi,0FFFFFF60h
     84: mov     esi,0FFFFFF70h
     89: mov     edx,0FFFFFEB0h
     8e: call    ryo_h_DivUW64
     93: mov     rax,[rbp+20h]
     97: mov     [rbp-70h],rax
     9b: mov     rax,[rbp+28h]
     9f: mov     [rbp-68h],rax
     a3: mov     rax,[rbp-70h]
     a7: mov     [rbp-8],rax
     ab: mov     byte ptr [rbp-149h],1
     b2: test    byte ptr [rbp-149h],0FFh
     b9: je      1C9h
     bf: cmp     qword ptr [rbp-90h],10h
     c7: jb      1C9h
     cd: mov     rax,[rbp-8]
     d1: imul    rcx,[rbp-90h],4
     d9: add     rax,rcx
     dc: mov     [rbp-0B8h],rax
     e3: mov     rax,[rbp-98h]
     ea: mov     [rbp-190h],rax
     f1: mov     rax,[rbp-8]
     f5: mov     [rbp-188h],rax
     fc: mov     rax,[rbp-0B8h]
    103: mov     [rbp-180h],rax
    10a: mov     rax,[rbp+30h]
    10e: mov     [rbp-178h],rax
    115: call    fn0
    11a: nop     [rcx-8]
    121: mov     rax,[rbp-98h]
    128: imul    rcx,[rbp-0A0h],4
    130: add     rax,rcx
    133: mov     [rbp-0B8h],rax
    13a: mov     rax,[rbp-8]
    13e: imul    rcx,[rbp-0A0h],4
    146: add     rax,rcx
    149: mov     [rbp-0C0h],rax
    150: mov     rax,[rbp-90h]
    157: add     rax,8
    15b: mov     [rbp-0D0h],rax
    162: mov     rax,[rbp-8]
    166: imul    rcx,[rbp-0D0h],4
    16e: add     rax,rcx
    171: mov     [rbp-0C8h],rax
    178: mov     rax,[rbp-0B8h]
    17f: mov     [rbp-190h],rax
    186: mov     rax,[rbp-0C0h]
    18d: mov     [rbp-188h],rax
    194: mov     rax,[rbp-0C8h]
    19b: mov     [rbp-180h],rax
    1a2: mov     rax,[rbp+30h]
    1a6: mov     [rbp-178h],rax
    1ad: call    fn1
    1b2: nop     [rcx-8]
    1b9: mov     qword ptr [rbp-0A8h],8
    1c4: jmp     2C0h
    1c9: cmp     qword ptr [rbp-90h],8
    1d1: jb      28Fh
    1d7: mov     rax,[rbp-60h]
    1db: mov     [rbp-0B8h],rax
    1e2: mov     rax,[rbp-0B8h]
    1e9: mov     [rbp-190h],rax
    1f0: mov     rax,[rbp-8]
    1f4: mov     [rbp-188h],rax
    1fb: mov     rax,[rbp+30h]
    1ff: mov     [rbp-180h],rax
    206: call    fn2
    20b: nop     [rcx-8]
    212: mov     rax,[rbp-98h]
    219: imul    rcx,[rbp-0A0h],4
    221: add     rax,rcx
    224: mov     [rbp-0C0h],rax
    22b: mov     rax,[rbp-0C0h]
    232: mov     [rbp-0B8h],rax
    239: mov     rax,[rbp-8]
    23d: imul    rcx,[rbp-0A0h],4
    245: add     rax,rcx
    248: mov     [rbp-0C0h],rax
    24f: mov     rax,[rbp-0B8h]
    256: mov     [rbp-190h],rax
    25d: mov     rax,[rbp-0C0h]
    264: mov     [rbp-188h],rax
    26b: mov     rax,[rbp+30h]
    26f: mov     [rbp-180h],rax
    276: call    fn3
    27b: nop     [rcx-8]
    282: mov     qword ptr [rbp-0A8h],4
    28d: jmp     2C0h
    28f: mov     rax,[rbp-60h]
    293: mov     [rbp-0B8h],rax
    29a: mov     byte ptr [rbp-149h],1
    2a1: test    byte ptr [rbp-149h],0FFh
    2a8: je      63Ah
    2ae: jmp     5CAh
    2b3: nop     [rax+rax]
    2bc: nop     [rax]
    2c0: mov     qword ptr [rbp-0D8h],0
    2cb: mov     rax,[rbp-0A0h]
    2d2: mov     [rbp-0D0h],rax
    2d9: mov     edi,0FFFFFF18h
    2de: mov     esi,0FFFFFF28h
    2e3: call    ryo_h_MovW128
    2e8: mov     edi,0FFFFFEF8h
    2ed: lea     rsi,[k4]
    2f4: mov     edx,10h
    2f9: call    ryo_h_Const
    2fe: mov     edi,0FFFFFF08h
    303: mov     esi,0FFFFFF18h
    308: call    ryo_h_MovW128
    30d: mov     edi,0FFFFFEB8h
    312: mov     esi,0FFFFFEF8h
    317: mov     edx,20h
    31c: call    ryo_h_Copy
    321: mov     edi,0FFFFFED8h
    326: mov     esi,0FFFFFEB8h
    32b: mov     edx,20h
    330: call    ryo_h_Copy
    335: mov     edi,0FFFFFF38h
    33a: mov     esi,0FFFFFED8h
    33f: mov     edx,20h
    344: call    ryo_h_Copy
    349: mov     edi,0FFFFFF18h
    34e: mov     esi,0FFFFFF38h
    353: mov     edx,20h
    358: call    ryo_h_Copy
    35d: nop     [rax]
    360: lea     rax,[rbp-0E8h]
    367: mov     [rbp-110h],rax
    36e: mov     rax,[rbp-110h]
    375: mov     [rbp-108h],rax
    37c: mov     qword ptr [rbp-100h],2
    387: mov     edi,0FFFFFE70h
    38c: mov     esi,0FFFFFEF8h
    391: call    ryo_h_MovW128
    396: call    fn5
    39b: nop     [rcx-0F8h]
    3a2: jmp     760h
    3a7: nop     [rax+rax]
    3b0: call    ryo_h_Unreachable
    3b5: ud2
    3b7: mov     rax,[rbp-0F0h]
    3be: mov     [rbp-100h],rax
    3c5: mov     rax,[rbp-98h]
    3cc: imul    rcx,[rbp-100h],4
    3d4: add     rax,rcx
    3d7: mov     [rbp-108h],rax
    3de: mov     rax,[rbp-8]
    3e2: imul    rcx,[rbp-100h],4
    3ea: add     rax,rcx
    3ed: mov     [rbp-110h],rax
    3f4: cmp     qword ptr [rbp-100h],0
    3fc: je      42Dh
    3fe: jmp     43Ah
    400: lea     rax,[rbp-0E8h]
    407: mov     [rbp-150h],rax
    40e: mov     rax,[rbp-150h]
    415: mov     [rbp-190h],rax
    41c: call    fn6
    421: nop     [rcx-150h]
    428: jmp     4B2h
    42d: mov     rax,[rbp-0A0h]
    434: mov     [rbp-28h],rax
    438: jmp     44Ch
    43a: mov     rax,[rbp-90h]
    441: sub     rax,[rbp-0A0h]
    448: mov     [rbp-28h],rax
    44c: mov     rax,[rbp-0A8h]
    453: mov     [rbp-118h],rax
    45a: mov     rax,[rbp-118h]
    461: mov     [rbp-38h],rax
    465: mov     rax,[rbp-28h]
    469: mov     [rbp-30h],rax
    46d: nop     [rax]
    470: mov     rax,[rbp-38h]
    474: mov     [rbp-130h],rax
    47b: mov     rax,[rbp-30h]
    47f: mov     [rbp-138h],rax
    486: mov     rax,[rbp-130h]
    48d: cmp     rax,[rbp-138h]
    494: setb    [rbp-121h]
    49b: test    byte ptr [rbp-121h],0FFh
    4a2: je      7B5h
    4a8: jmp     798h
    4ad: nop     [rax]
    4b0: jmp     470h
    4b2: mov     rax,[rbp-70h]
    4b6: mov     [rbp-0C8h],rax
    4bd: mov     rax,[rbp-0C8h]
    4c4: mov     [rbp-0C0h],rax
    4cb: mov     rax,[rbp-98h]
    4d2: mov     [rbp-0B8h],rax
    4d9: mov     rax,[rbp-90h]
    4e0: mov     [rbp-0B0h],rax
    4e7: mov     rax,[rbp-0C0h]
    4ee: mov     [rbp-0D8h],rax
    4f5: mov     rax,[rbp-0B0h]
    4fc: mov     [rbp-0E0h],rax
    503: mov     byte ptr [rbp-149h],1
    50a: test    byte ptr [rbp-149h],0FFh
    511: je      9ABh
    517: jmp     94Eh
    51c: nop     [rax]
    520: mov     rax,[rbp-0C0h]
    527: mov     [rbp-0C8h],rax
    52e: mov     rax,[rbp-0B8h]
    535: mov     [rbp-0D0h],rax
    53c: mov     rax,[rbp-0B0h]
    543: mov     [rbp-0D8h],rax
    54a: xor     edi,edi
    54c: xor     esi,esi
    54e: call    ryo_h_Ret
    553: leave
    554: ret
    555: nop     [rax+rax]
    55e: xchg    ax,ax
    560: lea     rax,[rbp-0E8h]
    567: mov     [rbp-150h],rax
    56e: mov     rax,[rbp-150h]
    575: mov     [rbp-190h],rax
    57c: call    fn7
    581: nop     [rcx-150h]
    588: nop     [rax+rax]
    590: mov     edi,0FFFFFF78h
    595: call    ryo_h_Resume
    59a: ud2
    59c: nop     [rax]
    5a0: lea     rax,[rbp-0C0h]
    5a7: mov     [rbp-150h],rax
    5ae: mov     rax,[rbp-150h]
    5b5: mov     [rbp-190h],rax
    5bc: call    fn8
    5c1: nop     [rcx-150h]
    5c8: jmp     590h
    5ca: mov     rax,[rbp-60h]
    5ce: mov     [rbp-0C0h],rax
    5d5: mov     rax,[rbp-70h]
    5d9: mov     [rbp-0C8h],rax
    5e0: mov     rax,[rbp-0C0h]
    5e7: mov     [rbp-190h],rax
    5ee: mov     rax,[rbp-0C8h]
    5f5: mov     [rbp-188h],rax
    5fc: mov     qword ptr [rbp-180h],4
    607: mov     qword ptr [rbp-178h],4
    612: mov     qword ptr [rbp-170h],1
    61d: mov     edi,0FFFFFE98h
    622: lea     rsi,[k9]
    629: call    ryo_h_AddrAbs
    62e: call    fn10
    633: nop     [rcx-70h]
    63a: mov     qword ptr [rbp-150h],1
    645: imul    rax,[rbp-150h],4
    64d: mov     [rbp-158h],rax
    654: mov     edi,0FFFFFFF8h
    659: mov     esi,0FFFFFF48h
    65e: mov     edx,0FFFFFEA8h
    663: call    ryo_h_Memcpy
    668: mov     rax,[rbp-98h]
    66f: imul    rcx,[rbp-0A0h],4
    677: add     rax,rcx
    67a: mov     [rbp-10h],rax
    67e: mov     rax,[rbp-10h]
    682: mov     [rbp-0B8h],rax
    689: mov     rax,[rbp-8]
    68d: imul    rcx,[rbp-0A0h],4
    695: add     rax,rcx
    698: mov     [rbp-0C0h],rax
    69f: mov     byte ptr [rbp-149h],1
    6a6: test    byte ptr [rbp-149h],0FFh
    6ad: je      722h
    6af: mov     rax,[rbp-10h]
    6b3: mov     [rbp-0C8h],rax
    6ba: mov     rax,[rbp-0C0h]
    6c1: mov     [rbp-0D0h],rax
    6c8: mov     rax,[rbp-0C8h]
    6cf: mov     [rbp-190h],rax
    6d6: mov     rax,[rbp-0D0h]
    6dd: mov     [rbp-188h],rax
    6e4: mov     qword ptr [rbp-180h],4
    6ef: mov     qword ptr [rbp-178h],4
    6fa: mov     qword ptr [rbp-170h],1
    705: mov     edi,0FFFFFE98h
    70a: lea     rsi,[k11]
    711: call    ryo_h_AddrAbs
    716: call    fn12
    71b: nop     [rcx-70h]
    722: mov     qword ptr [rbp-150h],1
    72d: imul    rax,[rbp-150h],4
    735: mov     [rbp-158h],rax
    73c: mov     edi,0FFFFFF40h
    741: mov     esi,0FFFFFF48h
    746: mov     edx,0FFFFFEA8h
    74b: call    ryo_h_Memcpy
    750: mov     qword ptr [rbp-0A8h],1
    75b: jmp     2C0h
    760: mov     rax,[rbp-0F8h]
    767: mov     [rbp-20h],rax
    76b: mov     edi,0FFFFFFE0h
    770: xor     esi,esi
    772: mov     edx,2
    777: call    ryo_h_SwitchDenseW64
    77c: lea     rcx,[78Ch]
    783: movsxd  rax,[rcx+rax*4]
    787: add     rax,rcx
    78a: jmp     rax
    78c: .long   400h
    790: .long   3b7h
    794: .long   3b0h
    798: mov     rax,[rbp-38h]
    79c: mov     [rbp-130h],rax
    7a3: mov     byte ptr [rbp-149h],1
    7aa: test    byte ptr [rbp-149h],0FFh
    7b1: je      7F0h
    7b3: jmp     7BAh
    7b5: jmp     360h
    7ba: mov     rax,[rbp-130h]
    7c1: mov     [rbp-190h],rax
    7c8: mov     qword ptr [rbp-188h],1
    7d3: mov     edi,0FFFFFE80h
    7d8: lea     rsi,[k13]
    7df: call    ryo_h_AddrAbs
    7e4: call    fn14
    7e9: nop     [rcx-80h]
    7f0: mov     rax,[rbp-130h]
    7f7: add     rax,1
    7fb: mov     [rbp-138h],rax
    802: mov     rax,[rbp-138h]
    809: mov     [rbp-38h],rax
    80d: mov     rax,[rbp-130h]
    814: mov     [rbp-118h],rax
    81b: mov     qword ptr [rbp-120h],1
    826: mov     rax,[rbp-118h]
    82d: mov     [rbp-128h],rax
    834: mov     rax,[rbp-108h]
    83b: imul    rcx,[rbp-128h],4
    843: add     rax,rcx
    846: mov     [rbp-48h],rax
    84a: mov     rax,[rbp-48h]
    84e: mov     [rbp-130h],rax
    855: mov     rax,[rbp-110h]
    85c: imul    rcx,[rbp-128h],4
    864: add     rax,rcx
    867: mov     [rbp-50h],rax
    86b: mov     byte ptr [rbp-149h],1
    872: test    byte ptr [rbp-149h],0FFh
    879: je      8EBh
    87b: mov     rax,[rbp-48h]
    87f: mov     [rbp-138h],rax
    886: mov     rax,[rbp-50h]
    88a: mov     [rbp-140h],rax
    891: mov     rax,[rbp-138h]
    898: mov     [rbp-190h],rax
    89f: mov     rax,[rbp-140h]
    8a6: mov     [rbp-188h],rax
    8ad: mov     qword ptr [rbp-180h],4
    8b8: mov     qword ptr [rbp-178h],4
    8c3: mov     qword ptr [rbp-170h],1
    8ce: mov     edi,0FFFFFE98h
    8d3: lea     rsi,[k15]
    8da: call    ryo_h_AddrAbs
    8df: call    fn16
    8e4: nop     [rcx-80h]
    8eb: mov     qword ptr [rbp-150h],1
    8f6: imul    rax,[rbp-150h],4
    8fe: mov     [rbp-158h],rax
    905: mov     edi,0FFFFFFB0h
    90a: mov     esi,0FFFFFED0h
    90f: mov     edx,0FFFFFEA8h
    914: call    ryo_h_Memcpy
    919: mov     rax,[rbp-110h]
    920: mov     [rbp-190h],rax
    927: mov     rax,[rbp-50h]
    92b: mov     [rbp-188h],rax
    932: mov     rax,[rbp+30h]
    936: mov     [rbp-180h],rax
    93d: call    fn17
    942: nop     [rcx-50h]
    949: jmp     4B0h
    94e: mov     rax,[rbp-0D8h]
    955: mov     [rbp-0E8h],rax
    95c: mov     rax,[rbp-0E8h]
    963: mov     [rbp-190h],rax
    96a: mov     qword ptr [rbp-188h],4
    975: mov     qword ptr [rbp-180h],4
    980: mov     rax,[rbp-0E0h]
    987: mov     [rbp-178h],rax
    98e: mov     edi,0FFFFFE90h
    993: lea     rsi,[k18]
    99a: call    ryo_h_AddrAbs
    99f: call    fn19
    9a4: nop     [rcx-80h]
    9ab: mov     rax,[rbp-0D8h]
    9b2: mov     [rbp-0F0h],rax
    9b9: mov     rax,[rbp-0E0h]
    9c0: mov     [rbp-0E8h],rax
    9c7: mov     rax,[rbp-0F0h]
    9ce: mov     [rbp-0D0h],rax
    9d5: mov     rax,[rbp-0E8h]
    9dc: mov     [rbp-0C8h],rax
    9e3: mov     rax,[rbp-0B8h]
    9ea: mov     [rbp-0D8h],rax
    9f1: mov     edi,0FFFFFE70h
    9f6: mov     esi,0FFFFFF30h
    9fb: call    ryo_h_MovW128
    a00: mov     rax,[rbp-0D8h]
    a07: mov     [rbp-180h],rax
    a0e: mov     rax,[rbp+30h]
    a12: mov     [rbp-178h],rax
    a19: call    fn20
    a1e: nop     [rcx-50h]
    a25: jmp     520h
    a2a: nop     [rax+rax]
    a30: lea     rdi,[sym21]
    a37: lea     rsi,[site22]
    a3e: mov     edx,0FFFFFEB0h
    a43: call    ryo_h_CallExt
    a48: test    rax,rax
    a4b: je      0A58h
    a4d: call    rax
    a4f: nop     [rcx-148h]
    a56: jmp     0A68h
    a58: mov     rdi,rbp
    a5b: lea     rsi,[ro+4]
    a62: call    qword ptr [sym23]
    a68: call    ryo_h_Unreachable
    a6d: ud2
    a6f: mov     rdi,rax
    a72: mov     esi,0FFFFFF78h
    a77: call    ryo_h_Lpad
    a7c: jmp     560h
    a81: mov     rdi,rax
    a84: mov     esi,0FFFFFF78h
    a89: call    ryo_h_Lpad
    a8e: jmp     0A30h
    a90: mov     rdi,rax
    a93: mov     esi,0FFFFFF78h
    a98: call    ryo_h_Lpad
    a9d: jmp     5A0h

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,160h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     qword ptr [rbp-60h],2
     18: jae     1Fh
     1a: jmp     2E0h
     1f: cmp     qword ptr [rbp-60h],20h
     24: jbe     2Dh
     26: call    ryo_h_Abort
     2b: ud2
     2d: mov     qword ptr [rbp-128h],2
     38: mov     edi,0FFFFFF18h
     3d: mov     esi,0FFFFFFA0h
     42: mov     edx,0FFFFFED8h
     47: call    ryo_h_DivUW64
     4c: cmp     qword ptr [rbp-60h],12h
     51: setb    [rbp-0E9h]
     58: mov     rax,[rbp+10h]
     5c: mov     [rbp-40h],rax
     60: mov     rax,[rbp+18h]
     64: mov     [rbp-38h],rax
     68: mov     rax,[rbp-40h]
     6c: mov     [rbp-0F8h],rax
     73: test    byte ptr [rbp-0E9h],0FFh
     7a: je      86h
     7c: mov     rax,[rbp-60h]
     80: mov     [rbp-8],rax
     84: jmp     91h
     86: mov     rax,[rbp-0E8h]
     8d: mov     [rbp-8],rax
     91: mov     byte ptr [rbp-121h],1
     98: test    byte ptr [rbp-121h],0FFh
     9f: je      342h
     a5: jmp     2EBh
     aa: nop     [rax+rax]
     b0: mov     rax,[rbp-20h]
     b4: mov     [rbp-110h],rax
     bb: mov     rax,[rbp-18h]
     bf: mov     [rbp-108h],rax
     c6: mov     rax,[rbp-108h]
     cd: mov     [rbp-100h],rax
     d4: cmp     qword ptr [rbp-100h],0Dh
     dc: jb      11Dh
     de: mov     edi,0FFFFFEF8h
     e3: mov     esi,0FFFFFFE0h
     e8: call    ryo_h_MovW128
     ed: mov     edi,0FFFFFEA0h
     f2: mov     esi,0FFFFFEF8h
     f7: call    ryo_h_MovW128
     fc: mov     rax,[rbp+20h]
    100: mov     [rbp-150h],rax
    107: call    fn0
    10c: nop     [rcx-10h]
    113: mov     qword ptr [rbp-10h],0Dh
    11b: jmp     192h
    11d: mov     rax,[rbp-20h]
    121: mov     [rbp-110h],rax
    128: mov     rax,[rbp-18h]
    12c: mov     [rbp-108h],rax
    133: mov     rax,[rbp-108h]
    13a: mov     [rbp-100h],rax
    141: cmp     qword ptr [rbp-100h],9
    149: jb      18Ah
    14b: mov     edi,0FFFFFEF8h
    150: mov     esi,0FFFFFFE0h
    155: call    ryo_h_MovW128
    15a: mov     edi,0FFFFFEA0h
    15f: mov     esi,0FFFFFEF8h
    164: call    ryo_h_MovW128
    169: mov     rax,[rbp+20h]
    16d: mov     [rbp-150h],rax
    174: call    fn1
    179: nop     [rcx-10h]
    180: mov     qword ptr [rbp-10h],9
    188: jmp     192h
    18a: mov     qword ptr [rbp-10h],1
    192: mov     edi,0FFFFFEF8h
    197: mov     esi,0FFFFFFE0h
    19c: call    ryo_h_MovW128
    1a1: mov     edi,0FFFFFEA0h
    1a6: mov     esi,0FFFFFEF8h
    1ab: call    ryo_h_MovW128
    1b0: mov     rax,[rbp-10h]
    1b4: mov     [rbp-150h],rax
    1bb: mov     rax,[rbp+20h]
    1bf: mov     [rbp-148h],rax
    1c6: call    fn2
    1cb: nop     [rcx-10h]
    1d2: test    byte ptr [rbp-0E9h],0FFh
    1d9: je      1E0h
    1db: jmp     2E0h
    1e0: mov     rax,[rbp-20h]
    1e4: mov     [rbp-110h],rax
    1eb: mov     rax,[rbp-18h]
    1ef: mov     [rbp-108h],rax
    1f6: mov     rax,[rbp-110h]
    1fd: mov     [rbp-120h],rax
    204: mov     rax,[rbp-108h]
    20b: mov     [rbp-118h],rax
    212: mov     rax,[rbp-120h]
    219: mov     [rbp-100h],rax
    220: mov     rax,[rbp-40h]
    224: mov     [rbp-108h],rax
    22b: mov     rax,[rbp-100h]
    232: cmp     rax,[rbp-108h]
    239: je      267h
    23b: lea     rax,[rbp-0E0h]
    242: mov     [rbp-48h],rax
    246: mov     rax,[rbp-48h]
    24a: mov     [rbp-28h],rax
    24e: mov     byte ptr [rbp-121h],1
    255: test    byte ptr [rbp-121h],0FFh
    25c: je      461h
    262: jmp     40Ah
    267: mov     rax,[rbp-0F8h]
    26e: imul    rcx,[rbp-0E8h],4
    276: add     rax,rcx
    279: mov     [rbp-100h],rax
    280: mov     rax,[rbp-60h]
    284: sub     rax,[rbp-0E8h]
    28b: mov     [rbp-108h],rax
    292: mov     byte ptr [rbp-121h],1
    299: test    byte ptr [rbp-121h],0FFh
    2a0: je      3D3h
    2a6: jmp     376h
    2ab: nop     [rax+rax]
    2b0: mov     rax,[rbp-48h]
    2b4: mov     [rbp-100h],rax
    2bb: mov     byte ptr [rbp-121h],1
    2c2: test    byte ptr [rbp-121h],0FFh
    2c9: je      530h
    2cf: jmp     4C0h
    2d4: nop     [rax+rax]
    2dd: nop     [rax]
    2e0: xor     edi,edi
    2e2: xor     esi,esi
    2e4: call    ryo_h_Ret
    2e9: leave
    2ea: ret
    2eb: mov     rax,[rbp-40h]
    2ef: mov     [rbp-100h],rax
    2f6: mov     rax,[rbp-100h]
    2fd: mov     [rbp-160h],rax
    304: mov     qword ptr [rbp-158h],4
    30f: mov     qword ptr [rbp-150h],4
    31a: mov     rax,[rbp-8]
    31e: mov     [rbp-148h],rax
    325: mov     edi,0FFFFFEC0h
    32a: lea     rsi,[k3]
    331: call    ryo_h_AddrAbs
    336: call    fn4
    33b: nop     [rcx-40h]
    342: mov     rax,[rbp-0F8h]
    349: mov     [rbp-108h],rax
    350: mov     rax,[rbp-8]
    354: mov     [rbp-100h],rax
    35b: mov     rax,[rbp-108h]
    362: mov     [rbp-20h],rax
    366: mov     rax,[rbp-100h]
    36d: mov     [rbp-18h],rax
    371: jmp     0B0h
    376: mov     rax,[rbp-100h]
    37d: mov     [rbp-110h],rax
    384: mov     rax,[rbp-110h]
    38b: mov     [rbp-160h],rax
    392: mov     qword ptr [rbp-158h],4
    39d: mov     qword ptr [rbp-150h],4
    3a8: mov     rax,[rbp-108h]
    3af: mov     [rbp-148h],rax
    3b6: mov     edi,0FFFFFEC0h
    3bb: lea     rsi,[k5]
    3c2: call    ryo_h_AddrAbs
    3c7: call    fn6
    3cc: nop     [rcx-48h]
    3d3: mov     rax,[rbp-100h]
    3da: mov     [rbp-118h],rax
    3e1: mov     rax,[rbp-108h]
    3e8: mov     [rbp-110h],rax
    3ef: mov     rax,[rbp-118h]
    3f6: mov     [rbp-20h],rax
    3fa: mov     rax,[rbp-110h]
    401: mov     [rbp-18h],rax
    405: jmp     0B0h
    40a: mov     rax,[rbp-40h]
    40e: mov     [rbp-110h],rax
    415: mov     rax,[rbp-110h]
    41c: mov     [rbp-160h],rax
    423: mov     qword ptr [rbp-158h],4
    42e: mov     qword ptr [rbp-150h],4
    439: mov     rax,[rbp-60h]
    43d: mov     [rbp-148h],rax
    444: mov     edi,0FFFFFEC0h
    449: lea     rsi,[k7]
    450: call    ryo_h_AddrAbs
    455: call    fn8
    45a: nop     [rcx-48h]
    461: mov     rax,[rbp-0F8h]
    468: mov     [rbp-58h],rax
    46c: mov     rax,[rbp-60h]
    470: mov     [rbp-50h],rax
    474: mov     rax,[rbp-58h]
    478: mov     [rbp-108h],rax
    47f: mov     rax,[rbp-50h]
    483: mov     [rbp-100h],rax
    48a: mov     edi,0FFFFFEA0h
    48f: mov     esi,0FFFFFEF8h
    494: call    ryo_h_MovW128
    499: mov     rax,[rbp-28h]
    49d: mov     [rbp-150h],rax
    4a4: mov     rax,[rbp+20h]
    4a8: mov     [rbp-148h],rax
    4af: call    fn9
    4b4: nop     [rcx-30h]
    4bb: jmp     2B0h
    4c0: mov     rax,[rbp-48h]
    4c4: mov     [rbp-108h],rax
    4cb: mov     rax,[rbp-40h]
    4cf: mov     [rbp-110h],rax
    4d6: mov     rax,[rbp-108h]
    4dd: mov     [rbp-160h],rax
    4e4: mov     rax,[rbp-110h]
    4eb: mov     [rbp-158h],rax
    4f2: mov     qword ptr [rbp-150h],4
    4fd: mov     qword ptr [rbp-148h],4
    508: mov     rax,[rbp-60h]
    50c: mov     [rbp-140h],rax
    513: mov     edi,0FFFFFEC8h
    518: lea     rsi,[k10]
    51f: call    ryo_h_AddrAbs
    524: call    fn11
    529: nop     [rcx-58h]
    530: imul    rax,[rbp-60h],4
    535: mov     [rbp-128h],rax
    53c: mov     edi,0FFFFFF08h
    541: mov     esi,0FFFFFF00h
    546: mov     edx,0FFFFFED8h
    54b: call    ryo_h_Memcpy
    550: jmp     2E0h

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp-10h],0Dh
     15: jae     1Eh
     17: call    ryo_h_Abort
     1c: ud2
     1e: mov     rax,[rbp+10h]
     22: mov     [rbp-18h],rax
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-10h],rax
     2e: mov     rax,[rbp-18h]
     32: mov     [rbp-8],rax
     36: mov     rax,[rbp-8]
     3a: mov     [rbp-40h],rax
     3e: mov     qword ptr [rbp-38h],0
     46: mov     qword ptr [rbp-30h],0Ch
     4e: mov     rax,[rbp+20h]
     52: mov     [rbp-28h],rax
     56: call    fn0
     5b: nop     [rcx]
     62: mov     rax,[rbp-8]
     66: mov     [rbp-40h],rax
     6a: mov     qword ptr [rbp-38h],1
     72: mov     qword ptr [rbp-30h],0Ah
     7a: mov     rax,[rbp+20h]
     7e: mov     [rbp-28h],rax
     82: call    fn1
     87: nop     [rcx]
     8e: mov     rax,[rbp-8]
     92: mov     [rbp-40h],rax
     96: mov     qword ptr [rbp-38h],2
     9e: mov     qword ptr [rbp-30h],9
     a6: mov     rax,[rbp+20h]
     aa: mov     [rbp-28h],rax
     ae: call    fn2
     b3: nop     [rcx]
     ba: mov     rax,[rbp-8]
     be: mov     [rbp-40h],rax
     c2: mov     qword ptr [rbp-38h],3
     ca: mov     qword ptr [rbp-30h],7
     d2: mov     rax,[rbp+20h]
     d6: mov     [rbp-28h],rax
     da: call    fn3
     df: nop     [rcx]
     e6: mov     rax,[rbp-8]
     ea: mov     [rbp-40h],rax
     ee: mov     qword ptr [rbp-38h],5
     f6: mov     qword ptr [rbp-30h],0Bh
     fe: mov     rax,[rbp+20h]
    102: mov     [rbp-28h],rax
    106: call    fn4
    10b: nop     [rcx]
    112: mov     rax,[rbp-8]
    116: mov     [rbp-40h],rax
    11a: mov     qword ptr [rbp-38h],6
    122: mov     qword ptr [rbp-30h],8
    12a: mov     rax,[rbp+20h]
    12e: mov     [rbp-28h],rax
    132: call    fn5
    137: nop     [rcx]
    13e: mov     rax,[rbp-8]
    142: mov     [rbp-40h],rax
    146: mov     qword ptr [rbp-38h],1
    14e: mov     qword ptr [rbp-30h],6
    156: mov     rax,[rbp+20h]
    15a: mov     [rbp-28h],rax
    15e: call    fn6
    163: nop     [rcx]
    16a: mov     rax,[rbp-8]
    16e: mov     [rbp-40h],rax
    172: mov     qword ptr [rbp-38h],2
    17a: mov     qword ptr [rbp-30h],3
    182: mov     rax,[rbp+20h]
    186: mov     [rbp-28h],rax
    18a: call    fn7
    18f: nop     [rcx]
    196: mov     rax,[rbp-8]
    19a: mov     [rbp-40h],rax
    19e: mov     qword ptr [rbp-38h],4
    1a6: mov     qword ptr [rbp-30h],0Bh
    1ae: mov     rax,[rbp+20h]
    1b2: mov     [rbp-28h],rax
    1b6: call    fn8
    1bb: nop     [rcx]
    1c2: mov     rax,[rbp-8]
    1c6: mov     [rbp-40h],rax
    1ca: mov     qword ptr [rbp-38h],7
    1d2: mov     qword ptr [rbp-30h],9
    1da: mov     rax,[rbp+20h]
    1de: mov     [rbp-28h],rax
    1e2: call    fn9
    1e7: nop     [rcx]
    1ee: mov     rax,[rbp-8]
    1f2: mov     [rbp-40h],rax
    1f6: mov     qword ptr [rbp-38h],8
    1fe: mov     qword ptr [rbp-30h],0Ah
    206: mov     rax,[rbp+20h]
    20a: mov     [rbp-28h],rax
    20e: call    fn10
    213: nop     [rcx]
    21a: mov     rax,[rbp-8]
    21e: mov     [rbp-40h],rax
    222: mov     qword ptr [rbp-38h],0
    22a: mov     qword ptr [rbp-30h],4
    232: mov     rax,[rbp+20h]
    236: mov     [rbp-28h],rax
    23a: call    fn11
    23f: nop     [rcx]
    246: mov     rax,[rbp-8]
    24a: mov     [rbp-40h],rax
    24e: mov     qword ptr [rbp-38h],1
    256: mov     qword ptr [rbp-30h],2
    25e: mov     rax,[rbp+20h]
    262: mov     [rbp-28h],rax
    266: call    fn12
    26b: nop     [rcx]
    272: mov     rax,[rbp-8]
    276: mov     [rbp-40h],rax
    27a: mov     qword ptr [rbp-38h],3
    282: mov     qword ptr [rbp-30h],6
    28a: mov     rax,[rbp+20h]
    28e: mov     [rbp-28h],rax
    292: call    fn13
    297: nop     [rcx]
    29e: mov     rax,[rbp-8]
    2a2: mov     [rbp-40h],rax
    2a6: mov     qword ptr [rbp-38h],7
    2ae: mov     qword ptr [rbp-30h],8
    2b6: mov     rax,[rbp+20h]
    2ba: mov     [rbp-28h],rax
    2be: call    fn14
    2c3: nop     [rcx]
    2ca: mov     rax,[rbp-8]
    2ce: mov     [rbp-40h],rax
    2d2: mov     qword ptr [rbp-38h],9
    2da: mov     qword ptr [rbp-30h],0Ah
    2e2: mov     rax,[rbp+20h]
    2e6: mov     [rbp-28h],rax
    2ea: call    fn15
    2ef: nop     [rcx]
    2f6: mov     rax,[rbp-8]
    2fa: mov     [rbp-40h],rax
    2fe: mov     qword ptr [rbp-38h],0Bh
    306: mov     qword ptr [rbp-30h],0Ch
    30e: mov     rax,[rbp+20h]
    312: mov     [rbp-28h],rax
    316: call    fn16
    31b: nop     [rcx]
    322: mov     rax,[rbp-8]
    326: mov     [rbp-40h],rax
    32a: mov     qword ptr [rbp-38h],4
    332: mov     qword ptr [rbp-30h],6
    33a: mov     rax,[rbp+20h]
    33e: mov     [rbp-28h],rax
    342: call    fn17
    347: nop     [rcx]
    34e: mov     rax,[rbp-8]
    352: mov     [rbp-40h],rax
    356: mov     qword ptr [rbp-38h],5
    35e: mov     qword ptr [rbp-30h],9
    366: mov     rax,[rbp+20h]
    36a: mov     [rbp-28h],rax
    36e: call    fn18
    373: nop     [rcx]
    37a: mov     rax,[rbp-8]
    37e: mov     [rbp-40h],rax
    382: mov     qword ptr [rbp-38h],8
    38a: mov     qword ptr [rbp-30h],0Bh
    392: mov     rax,[rbp+20h]
    396: mov     [rbp-28h],rax
    39a: call    fn19
    39f: nop     [rcx]
    3a6: mov     rax,[rbp-8]
    3aa: mov     [rbp-40h],rax
    3ae: mov     qword ptr [rbp-38h],0Ah
    3b6: mov     qword ptr [rbp-30h],0Ch
    3be: mov     rax,[rbp+20h]
    3c2: mov     [rbp-28h],rax
    3c6: call    fn20
    3cb: nop     [rcx]
    3d2: mov     rax,[rbp-8]
    3d6: mov     [rbp-40h],rax
    3da: mov     qword ptr [rbp-38h],0
    3e2: mov     qword ptr [rbp-30h],5
    3ea: mov     rax,[rbp+20h]
    3ee: mov     [rbp-28h],rax
    3f2: call    fn21
    3f7: nop     [rcx]
    3fe: mov     rax,[rbp-8]
    402: mov     [rbp-40h],rax
    406: mov     qword ptr [rbp-38h],3
    40e: mov     qword ptr [rbp-30h],8
    416: mov     rax,[rbp+20h]
    41a: mov     [rbp-28h],rax
    41e: call    fn22
    423: nop     [rcx]
    42a: mov     rax,[rbp-8]
    42e: mov     [rbp-40h],rax
    432: mov     qword ptr [rbp-38h],4
    43a: mov     qword ptr [rbp-30h],7
    442: mov     rax,[rbp+20h]
    446: mov     [rbp-28h],rax
    44a: call    fn23
    44f: nop     [rcx]
    456: mov     rax,[rbp-8]
    45a: mov     [rbp-40h],rax
    45e: mov     qword ptr [rbp-38h],6
    466: mov     qword ptr [rbp-30h],0Bh
    46e: mov     rax,[rbp+20h]
    472: mov     [rbp-28h],rax
    476: call    fn24
    47b: nop     [rcx]
    482: mov     rax,[rbp-8]
    486: mov     [rbp-40h],rax
    48a: mov     qword ptr [rbp-38h],9
    492: mov     qword ptr [rbp-30h],0Ah
    49a: mov     rax,[rbp+20h]
    49e: mov     [rbp-28h],rax
    4a2: call    fn25
    4a7: nop     [rcx]
    4ae: mov     rax,[rbp-8]
    4b2: mov     [rbp-40h],rax
    4b6: mov     qword ptr [rbp-38h],0
    4be: mov     qword ptr [rbp-30h],1
    4c6: mov     rax,[rbp+20h]
    4ca: mov     [rbp-28h],rax
    4ce: call    fn26
    4d3: nop     [rcx]
    4da: mov     rax,[rbp-8]
    4de: mov     [rbp-40h],rax
    4e2: mov     qword ptr [rbp-38h],2
    4ea: mov     qword ptr [rbp-30h],5
    4f2: mov     rax,[rbp+20h]
    4f6: mov     [rbp-28h],rax
    4fa: call    fn27
    4ff: nop     [rcx]
    506: mov     rax,[rbp-8]
    50a: mov     [rbp-40h],rax
    50e: mov     qword ptr [rbp-38h],6
    516: mov     qword ptr [rbp-30h],9
    51e: mov     rax,[rbp+20h]
    522: mov     [rbp-28h],rax
    526: call    fn28
    52b: nop     [rcx]
    532: mov     rax,[rbp-8]
    536: mov     [rbp-40h],rax
    53a: mov     qword ptr [rbp-38h],7
    542: mov     qword ptr [rbp-30h],8
    54a: mov     rax,[rbp+20h]
    54e: mov     [rbp-28h],rax
    552: call    fn29
    557: nop     [rcx]
    55e: mov     rax,[rbp-8]
    562: mov     [rbp-40h],rax
    566: mov     qword ptr [rbp-38h],0Ah
    56e: mov     qword ptr [rbp-30h],0Bh
    576: mov     rax,[rbp+20h]
    57a: mov     [rbp-28h],rax
    57e: call    fn30
    583: nop     [rcx]
    58a: mov     rax,[rbp-8]
    58e: mov     [rbp-40h],rax
    592: mov     qword ptr [rbp-38h],1
    59a: mov     qword ptr [rbp-30h],3
    5a2: mov     rax,[rbp+20h]
    5a6: mov     [rbp-28h],rax
    5aa: call    fn31
    5af: nop     [rcx]
    5b6: mov     rax,[rbp-8]
    5ba: mov     [rbp-40h],rax
    5be: mov     qword ptr [rbp-38h],2
    5c6: mov     qword ptr [rbp-30h],4
    5ce: mov     rax,[rbp+20h]
    5d2: mov     [rbp-28h],rax
    5d6: call    fn32
    5db: nop     [rcx]
    5e2: mov     rax,[rbp-8]
    5e6: mov     [rbp-40h],rax
    5ea: mov     qword ptr [rbp-38h],5
    5f2: mov     qword ptr [rbp-30h],6
    5fa: mov     rax,[rbp+20h]
    5fe: mov     [rbp-28h],rax
    602: call    fn33
    607: nop     [rcx]
    60e: mov     rax,[rbp-8]
    612: mov     [rbp-40h],rax
    616: mov     qword ptr [rbp-38h],9
    61e: mov     qword ptr [rbp-30h],0Ah
    626: mov     rax,[rbp+20h]
    62a: mov     [rbp-28h],rax
    62e: call    fn34
    633: nop     [rcx]
    63a: mov     rax,[rbp-8]
    63e: mov     [rbp-40h],rax
    642: mov     qword ptr [rbp-38h],1
    64a: mov     qword ptr [rbp-30h],2
    652: mov     rax,[rbp+20h]
    656: mov     [rbp-28h],rax
    65a: call    fn35
    65f: nop     [rcx]
    666: mov     rax,[rbp-8]
    66a: mov     [rbp-40h],rax
    66e: mov     qword ptr [rbp-38h],3
    676: mov     qword ptr [rbp-30h],4
    67e: mov     rax,[rbp+20h]
    682: mov     [rbp-28h],rax
    686: call    fn36
    68b: nop     [rcx]
    692: mov     rax,[rbp-8]
    696: mov     [rbp-40h],rax
    69a: mov     qword ptr [rbp-38h],5
    6a2: mov     qword ptr [rbp-30h],7
    6aa: mov     rax,[rbp+20h]
    6ae: mov     [rbp-28h],rax
    6b2: call    fn37
    6b7: nop     [rcx]
    6be: mov     rax,[rbp-8]
    6c2: mov     [rbp-40h],rax
    6c6: mov     qword ptr [rbp-38h],6
    6ce: mov     qword ptr [rbp-30h],8
    6d6: mov     rax,[rbp+20h]
    6da: mov     [rbp-28h],rax
    6de: call    fn38
    6e3: nop     [rcx]
    6ea: mov     rax,[rbp-8]
    6ee: mov     [rbp-40h],rax
    6f2: mov     qword ptr [rbp-38h],2
    6fa: mov     qword ptr [rbp-30h],3
    702: mov     rax,[rbp+20h]
    706: mov     [rbp-28h],rax
    70a: call    fn39
    70f: nop     [rcx]
    716: mov     rax,[rbp-8]
    71a: mov     [rbp-40h],rax
    71e: mov     qword ptr [rbp-38h],4
    726: mov     qword ptr [rbp-30h],5
    72e: mov     rax,[rbp+20h]
    732: mov     [rbp-28h],rax
    736: call    fn40
    73b: nop     [rcx]
    742: mov     rax,[rbp-8]
    746: mov     [rbp-40h],rax
    74a: mov     qword ptr [rbp-38h],6
    752: mov     qword ptr [rbp-30h],7
    75a: mov     rax,[rbp+20h]
    75e: mov     [rbp-28h],rax
    762: call    fn41
    767: nop     [rcx]
    76e: mov     rax,[rbp-8]
    772: mov     [rbp-40h],rax
    776: mov     qword ptr [rbp-38h],8
    77e: mov     qword ptr [rbp-30h],9
    786: mov     rax,[rbp+20h]
    78a: mov     [rbp-28h],rax
    78e: call    fn42
    793: nop     [rcx]
    79a: mov     rax,[rbp-8]
    79e: mov     [rbp-40h],rax
    7a2: mov     qword ptr [rbp-38h],3
    7aa: mov     qword ptr [rbp-30h],4
    7b2: mov     rax,[rbp+20h]
    7b6: mov     [rbp-28h],rax
    7ba: call    fn43
    7bf: nop     [rcx]
    7c6: mov     rax,[rbp-8]
    7ca: mov     [rbp-40h],rax
    7ce: mov     qword ptr [rbp-38h],5
    7d6: mov     qword ptr [rbp-30h],6
    7de: mov     rax,[rbp+20h]
    7e2: mov     [rbp-28h],rax
    7e6: call    fn44
    7eb: nop     [rcx]
    7f2: xor     edi,edi
    7f4: xor     esi,esi
    7f6: call    ryo_h_Ret
    7fb: leave
    7fc: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rax,[rbp+10h]
     17: imul    rcx,[rbp-78h],8
     1c: add     rax,rcx
     1f: mov     [rbp-28h],rax
     23: mov     rax,[rbp-28h]
     27: mov     [rbp-20h],rax
     2b: mov     rax,[rbp+10h]
     2f: mov     [rbp-30h],rax
     33: mov     rax,[rbp-20h]
     37: mov     [rbp-18h],rax
     3b: mov     rax,[rbp-30h]
     3f: mov     [rbp-10h],rax
     43: mov     rax,[rbp+20h]
     47: mov     [rbp-0B0h],rax
     4e: mov     rax,[rbp-18h]
     52: mov     [rbp-0A8h],rax
     59: mov     rax,[rbp-10h]
     5d: mov     [rbp-0A0h],rax
     64: call    fn0
     69: nop     [rcx-1]
     70: mov     qword ptr [rbp-78h],3
     78: mov     rax,[rbp+10h]
     7c: imul    rcx,[rbp-78h],8
     81: add     rax,rcx
     84: mov     [rbp-28h],rax
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-20h],rax
     90: mov     qword ptr [rbp-78h],2
     98: mov     rax,[rbp+10h]
     9c: imul    rcx,[rbp-78h],8
     a1: add     rax,rcx
     a4: mov     [rbp-38h],rax
     a8: mov     rax,[rbp-38h]
     ac: mov     [rbp-30h],rax
     b0: mov     rax,[rbp-20h]
     b4: mov     [rbp-18h],rax
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-10h],rax
     c0: mov     rax,[rbp+20h]
     c4: mov     [rbp-0B0h],rax
     cb: mov     rax,[rbp-18h]
     cf: mov     [rbp-0A8h],rax
     d6: mov     rax,[rbp-10h]
     da: mov     [rbp-0A0h],rax
     e1: call    fn1
     e6: nop     [rcx-2]
     ed: mov     edi,0FFFFFFE8h
     f2: mov     esi,0FFFFFFFFh
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp+10h]
    100: imul    rcx,[rbp-18h],8
    105: add     rax,rcx
    108: mov     [rbp-10h],rax
    10c: movzx   eax,byte ptr [rbp-1]
    110: xor     al,1
    113: mov     [rbp-3],al
    116: mov     edi,0FFFFFFE0h
    11b: mov     esi,0FFFFFFFDh
    120: call    ryo_h_ZextW8W64
    125: mov     rax,[rbp+10h]
    129: imul    rcx,[rbp-20h],8
    12e: add     rax,rcx
    131: mov     [rbp-18h],rax
    135: mov     edi,0FFFFFFD0h
    13a: mov     esi,0FFFFFFFEh
    13f: call    ryo_h_ZextW8W64
    144: mov     qword ptr [rbp-78h],2
    14c: mov     rax,[rbp-78h]
    150: add     rax,[rbp-30h]
    154: mov     [rbp-28h],rax
    158: mov     rax,[rbp+10h]
    15c: imul    rcx,[rbp-28h],8
    161: add     rax,rcx
    164: mov     [rbp-20h],rax
    168: movzx   eax,byte ptr [rbp-2]
    16c: xor     al,1
    16f: mov     [rbp-3],al
    172: mov     edi,0FFFFFFC8h
    177: mov     esi,0FFFFFFFDh
    17c: call    ryo_h_ZextW8W64
    181: mov     qword ptr [rbp-78h],2
    189: mov     rax,[rbp-78h]
    18d: add     rax,[rbp-38h]
    191: mov     [rbp-30h],rax
    195: mov     rax,[rbp+10h]
    199: imul    rcx,[rbp-30h],8
    19e: add     rax,rcx
    1a1: mov     [rbp-28h],rax
    1a5: mov     rax,[rbp-20h]
    1a9: mov     [rbp-40h],rax
    1ad: mov     rax,[rbp-10h]
    1b1: mov     [rbp-48h],rax
    1b5: mov     rax,[rbp-40h]
    1b9: mov     [rbp-38h],rax
    1bd: mov     rax,[rbp-48h]
    1c1: mov     [rbp-30h],rax
    1c5: mov     rax,[rbp+20h]
    1c9: mov     [rbp-0B0h],rax
    1d0: mov     rax,[rbp-38h]
    1d4: mov     [rbp-0A8h],rax
    1db: mov     rax,[rbp-30h]
    1df: mov     [rbp-0A0h],rax
    1e6: call    fn2
    1eb: nop     [rcx-3]
    1f2: mov     rax,[rbp-28h]
    1f6: mov     [rbp-40h],rax
    1fa: mov     rax,[rbp-18h]
    1fe: mov     [rbp-48h],rax
    202: mov     rax,[rbp-40h]
    206: mov     [rbp-38h],rax
    20a: mov     rax,[rbp-48h]
    20e: mov     [rbp-30h],rax
    212: mov     rax,[rbp+20h]
    216: mov     [rbp-0B0h],rax
    21d: mov     rax,[rbp-38h]
    221: mov     [rbp-0A8h],rax
    228: mov     rax,[rbp-30h]
    22c: mov     [rbp-0A0h],rax
    233: call    fn3
    238: nop     [rcx-4]
    23f: movzx   eax,byte ptr [rbp-3]
    243: mov     [rbp-0A8h],al
    249: mov     rax,[rbp-20h]
    24d: mov     [rbp-0B0h],rax
    254: mov     rax,[rbp-10h]
    258: mov     [rbp-0A0h],rax
    25f: call    fn4
    264: nop     [rcx-30h]
    26b: movzx   eax,byte ptr [rbp-4]
    26f: mov     [rbp-0A8h],al
    275: mov     rax,[rbp-18h]
    279: mov     [rbp-0B0h],rax
    280: mov     rax,[rbp-28h]
    284: mov     [rbp-0A0h],rax
    28b: call    fn5
    290: nop     [rcx-38h]
    297: movzx   eax,byte ptr [rbp-4]
    29b: mov     [rbp-0A8h],al
    2a1: mov     rax,[rbp-20h]
    2a5: mov     [rbp-0B0h],rax
    2ac: mov     rax,[rbp-18h]
    2b0: mov     [rbp-0A0h],rax
    2b7: call    fn6
    2bc: nop     [rcx-48h]
    2c3: movzx   eax,byte ptr [rbp-3]
    2c7: mov     [rbp-0A8h],al
    2cd: mov     rax,[rbp-10h]
    2d1: mov     [rbp-0B0h],rax
    2d8: mov     rax,[rbp-48h]
    2dc: mov     [rbp-0A0h],rax
    2e3: call    fn7
    2e8: nop     [rcx-40h]
    2ef: movzx   eax,byte ptr [rbp-3]
    2f3: mov     [rbp-0A8h],al
    2f9: mov     rax,[rbp-18h]
    2fd: mov     [rbp-0B0h],rax
    304: mov     rax,[rbp-20h]
    308: mov     [rbp-0A0h],rax
    30f: call    fn8
    314: nop     [rcx-50h]
    31b: movzx   eax,byte ptr [rbp-4]
    31f: mov     [rbp-0A8h],al
    325: mov     rax,[rbp-28h]
    329: mov     [rbp-0B0h],rax
    330: mov     rax,[rbp-50h]
    334: mov     [rbp-0A0h],rax
    33b: call    fn9
    340: nop     [rcx-48h]
    347: mov     rax,[rbp-48h]
    34b: mov     [rbp-60h],rax
    34f: mov     rax,[rbp-40h]
    353: mov     [rbp-68h],rax
    357: mov     rax,[rbp-60h]
    35b: mov     [rbp-58h],rax
    35f: mov     rax,[rbp-68h]
    363: mov     [rbp-50h],rax
    367: mov     rax,[rbp+20h]
    36b: mov     [rbp-0B0h],rax
    372: mov     rax,[rbp-58h]
    376: mov     [rbp-0A8h],rax
    37d: mov     rax,[rbp-50h]
    381: mov     [rbp-0A0h],rax
    388: call    fn10
    38d: nop     [rcx-5]
    394: movzx   eax,byte ptr [rbp-5]
    398: mov     [rbp-0A8h],al
    39e: mov     rax,[rbp-48h]
    3a2: mov     [rbp-0B0h],rax
    3a9: mov     rax,[rbp-40h]
    3ad: mov     [rbp-0A0h],rax
    3b4: call    fn11
    3b9: nop     [rcx-50h]
    3c0: movzx   eax,byte ptr [rbp-5]
    3c4: mov     [rbp-0A8h],al
    3ca: mov     rax,[rbp-40h]
    3ce: mov     [rbp-0B0h],rax
    3d5: mov     rax,[rbp-48h]
    3d9: mov     [rbp-0A0h],rax
    3e0: call    fn12
    3e5: nop     [rcx-58h]
    3ec: mov     byte ptr [rbp-71h],1
    3f0: test    byte ptr [rbp-71h],0FFh
    3f4: je      45Ah
    3f6: mov     rax,[rbp-30h]
    3fa: mov     [rbp-60h],rax
    3fe: mov     rax,[rbp+18h]
    402: mov     [rbp-68h],rax
    406: mov     rax,[rbp-60h]
    40a: mov     [rbp-0B0h],rax
    411: mov     rax,[rbp-68h]
    415: mov     [rbp-0A8h],rax
    41c: mov     qword ptr [rbp-0A0h],8
    427: mov     qword ptr [rbp-98h],4
    432: mov     qword ptr [rbp-90h],1
    43d: mov     edi,0FFFFFF78h
    442: lea     rsi,[k13]
    449: call    ryo_h_AddrAbs
    44e: call    fn14
    453: nop     [rcx]
    45a: mov     qword ptr [rbp-78h],1
    462: imul    rax,[rbp-78h],8
    467: mov     [rbp-80h],rax
    46b: mov     edi,18h
    470: mov     esi,0FFFFFFD0h
    475: mov     edx,0FFFFFF80h
    47a: call    ryo_h_Memcpy
    47f: mov     qword ptr [rbp-78h],1
    487: mov     rax,[rbp+18h]
    48b: imul    rcx,[rbp-78h],8
    490: add     rax,rcx
    493: mov     [rbp-60h],rax
    497: mov     byte ptr [rbp-71h],1
    49b: test    byte ptr [rbp-71h],0FFh
    49f: je      505h
    4a1: mov     rax,[rbp-50h]
    4a5: mov     [rbp-68h],rax
    4a9: mov     rax,[rbp-60h]
    4ad: mov     [rbp-70h],rax
    4b1: mov     rax,[rbp-68h]
    4b5: mov     [rbp-0B0h],rax
    4bc: mov     rax,[rbp-70h]
    4c0: mov     [rbp-0A8h],rax
    4c7: mov     qword ptr [rbp-0A0h],8
    4d2: mov     qword ptr [rbp-98h],4
    4dd: mov     qword ptr [rbp-90h],1
    4e8: mov     edi,0FFFFFF78h
    4ed: lea     rsi,[k15]
    4f4: call    ryo_h_AddrAbs
    4f9: call    fn16
    4fe: nop     [rcx]
    505: mov     qword ptr [rbp-78h],1
    50d: imul    rax,[rbp-78h],8
    512: mov     [rbp-80h],rax
    516: mov     edi,0FFFFFFA0h
    51b: mov     esi,0FFFFFFB0h
    520: mov     edx,0FFFFFF80h
    525: call    ryo_h_Memcpy
    52a: mov     qword ptr [rbp-78h],2
    532: mov     rax,[rbp+18h]
    536: imul    rcx,[rbp-78h],8
    53b: add     rax,rcx
    53e: mov     [rbp-60h],rax
    542: mov     byte ptr [rbp-71h],1
    546: test    byte ptr [rbp-71h],0FFh
    54a: je      5B0h
    54c: mov     rax,[rbp-58h]
    550: mov     [rbp-68h],rax
    554: mov     rax,[rbp-60h]
    558: mov     [rbp-70h],rax
    55c: mov     rax,[rbp-68h]
    560: mov     [rbp-0B0h],rax
    567: mov     rax,[rbp-70h]
    56b: mov     [rbp-0A8h],rax
    572: mov     qword ptr [rbp-0A0h],8
    57d: mov     qword ptr [rbp-98h],4
    588: mov     qword ptr [rbp-90h],1
    593: mov     edi,0FFFFFF78h
    598: lea     rsi,[k17]
    59f: call    ryo_h_AddrAbs
    5a4: call    fn18
    5a9: nop     [rcx]
    5b0: mov     qword ptr [rbp-78h],1
    5b8: imul    rax,[rbp-78h],8
    5bd: mov     [rbp-80h],rax
    5c1: mov     edi,0FFFFFFA0h
    5c6: mov     esi,0FFFFFFA8h
    5cb: mov     edx,0FFFFFF80h
    5d0: call    ryo_h_Memcpy
    5d5: mov     qword ptr [rbp-78h],3
    5dd: mov     rax,[rbp+18h]
    5e1: imul    rcx,[rbp-78h],8
    5e6: add     rax,rcx
    5e9: mov     [rbp-60h],rax
    5ed: mov     byte ptr [rbp-71h],1
    5f1: test    byte ptr [rbp-71h],0FFh
    5f5: je      65Bh
    5f7: mov     rax,[rbp-38h]
    5fb: mov     [rbp-68h],rax
    5ff: mov     rax,[rbp-60h]
    603: mov     [rbp-70h],rax
    607: mov     rax,[rbp-68h]
    60b: mov     [rbp-0B0h],rax
    612: mov     rax,[rbp-70h]
    616: mov     [rbp-0A8h],rax
    61d: mov     qword ptr [rbp-0A0h],8
    628: mov     qword ptr [rbp-98h],4
    633: mov     qword ptr [rbp-90h],1
    63e: mov     edi,0FFFFFF78h
    643: lea     rsi,[k19]
    64a: call    ryo_h_AddrAbs
    64f: call    fn20
    654: nop     [rcx]
    65b: mov     qword ptr [rbp-78h],1
    663: imul    rax,[rbp-78h],8
    668: mov     [rbp-80h],rax
    66c: mov     edi,0FFFFFFA0h
    671: mov     esi,0FFFFFFC8h
    676: mov     edx,0FFFFFF80h
    67b: call    ryo_h_Memcpy
    680: xor     edi,edi
    682: xor     esi,esi
    684: call    ryo_h_Ret
    689: leave
    68a: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rax,[rbp+10h]
     17: imul    rcx,[rbp-78h],4
     1c: add     rax,rcx
     1f: mov     [rbp-28h],rax
     23: mov     rax,[rbp-28h]
     27: mov     [rbp-20h],rax
     2b: mov     rax,[rbp+10h]
     2f: mov     [rbp-30h],rax
     33: mov     rax,[rbp-20h]
     37: mov     [rbp-18h],rax
     3b: mov     rax,[rbp-30h]
     3f: mov     [rbp-10h],rax
     43: mov     rax,[rbp+20h]
     47: mov     [rbp-0B0h],rax
     4e: mov     rax,[rbp-18h]
     52: mov     [rbp-0A8h],rax
     59: mov     rax,[rbp-10h]
     5d: mov     [rbp-0A0h],rax
     64: call    fn0
     69: nop     [rcx-1]
     70: mov     qword ptr [rbp-78h],3
     78: mov     rax,[rbp+10h]
     7c: imul    rcx,[rbp-78h],4
     81: add     rax,rcx
     84: mov     [rbp-28h],rax
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-20h],rax
     90: mov     qword ptr [rbp-78h],2
     98: mov     rax,[rbp+10h]
     9c: imul    rcx,[rbp-78h],4
     a1: add     rax,rcx
     a4: mov     [rbp-38h],rax
     a8: mov     rax,[rbp-38h]
     ac: mov     [rbp-30h],rax
     b0: mov     rax,[rbp-20h]
     b4: mov     [rbp-18h],rax
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-10h],rax
     c0: mov     rax,[rbp+20h]
     c4: mov     [rbp-0B0h],rax
     cb: mov     rax,[rbp-18h]
     cf: mov     [rbp-0A8h],rax
     d6: mov     rax,[rbp-10h]
     da: mov     [rbp-0A0h],rax
     e1: call    fn1
     e6: nop     [rcx-2]
     ed: mov     edi,0FFFFFFE8h
     f2: mov     esi,0FFFFFFFFh
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp+10h]
    100: imul    rcx,[rbp-18h],4
    105: add     rax,rcx
    108: mov     [rbp-10h],rax
    10c: movzx   eax,byte ptr [rbp-1]
    110: xor     al,1
    113: mov     [rbp-3],al
    116: mov     edi,0FFFFFFE0h
    11b: mov     esi,0FFFFFFFDh
    120: call    ryo_h_ZextW8W64
    125: mov     rax,[rbp+10h]
    129: imul    rcx,[rbp-20h],4
    12e: add     rax,rcx
    131: mov     [rbp-18h],rax
    135: mov     edi,0FFFFFFD0h
    13a: mov     esi,0FFFFFFFEh
    13f: call    ryo_h_ZextW8W64
    144: mov     qword ptr [rbp-78h],2
    14c: mov     rax,[rbp-78h]
    150: add     rax,[rbp-30h]
    154: mov     [rbp-28h],rax
    158: mov     rax,[rbp+10h]
    15c: imul    rcx,[rbp-28h],4
    161: add     rax,rcx
    164: mov     [rbp-20h],rax
    168: movzx   eax,byte ptr [rbp-2]
    16c: xor     al,1
    16f: mov     [rbp-3],al
    172: mov     edi,0FFFFFFC8h
    177: mov     esi,0FFFFFFFDh
    17c: call    ryo_h_ZextW8W64
    181: mov     qword ptr [rbp-78h],2
    189: mov     rax,[rbp-78h]
    18d: add     rax,[rbp-38h]
    191: mov     [rbp-30h],rax
    195: mov     rax,[rbp+10h]
    199: imul    rcx,[rbp-30h],4
    19e: add     rax,rcx
    1a1: mov     [rbp-28h],rax
    1a5: mov     rax,[rbp-20h]
    1a9: mov     [rbp-40h],rax
    1ad: mov     rax,[rbp-10h]
    1b1: mov     [rbp-48h],rax
    1b5: mov     rax,[rbp-40h]
    1b9: mov     [rbp-38h],rax
    1bd: mov     rax,[rbp-48h]
    1c1: mov     [rbp-30h],rax
    1c5: mov     rax,[rbp+20h]
    1c9: mov     [rbp-0B0h],rax
    1d0: mov     rax,[rbp-38h]
    1d4: mov     [rbp-0A8h],rax
    1db: mov     rax,[rbp-30h]
    1df: mov     [rbp-0A0h],rax
    1e6: call    fn2
    1eb: nop     [rcx-3]
    1f2: mov     rax,[rbp-28h]
    1f6: mov     [rbp-40h],rax
    1fa: mov     rax,[rbp-18h]
    1fe: mov     [rbp-48h],rax
    202: mov     rax,[rbp-40h]
    206: mov     [rbp-38h],rax
    20a: mov     rax,[rbp-48h]
    20e: mov     [rbp-30h],rax
    212: mov     rax,[rbp+20h]
    216: mov     [rbp-0B0h],rax
    21d: mov     rax,[rbp-38h]
    221: mov     [rbp-0A8h],rax
    228: mov     rax,[rbp-30h]
    22c: mov     [rbp-0A0h],rax
    233: call    fn3
    238: nop     [rcx-4]
    23f: movzx   eax,byte ptr [rbp-3]
    243: mov     [rbp-0A8h],al
    249: mov     rax,[rbp-20h]
    24d: mov     [rbp-0B0h],rax
    254: mov     rax,[rbp-10h]
    258: mov     [rbp-0A0h],rax
    25f: call    fn4
    264: nop     [rcx-30h]
    26b: movzx   eax,byte ptr [rbp-4]
    26f: mov     [rbp-0A8h],al
    275: mov     rax,[rbp-18h]
    279: mov     [rbp-0B0h],rax
    280: mov     rax,[rbp-28h]
    284: mov     [rbp-0A0h],rax
    28b: call    fn5
    290: nop     [rcx-38h]
    297: movzx   eax,byte ptr [rbp-4]
    29b: mov     [rbp-0A8h],al
    2a1: mov     rax,[rbp-20h]
    2a5: mov     [rbp-0B0h],rax
    2ac: mov     rax,[rbp-18h]
    2b0: mov     [rbp-0A0h],rax
    2b7: call    fn6
    2bc: nop     [rcx-48h]
    2c3: movzx   eax,byte ptr [rbp-3]
    2c7: mov     [rbp-0A8h],al
    2cd: mov     rax,[rbp-10h]
    2d1: mov     [rbp-0B0h],rax
    2d8: mov     rax,[rbp-48h]
    2dc: mov     [rbp-0A0h],rax
    2e3: call    fn7
    2e8: nop     [rcx-40h]
    2ef: movzx   eax,byte ptr [rbp-3]
    2f3: mov     [rbp-0A8h],al
    2f9: mov     rax,[rbp-18h]
    2fd: mov     [rbp-0B0h],rax
    304: mov     rax,[rbp-20h]
    308: mov     [rbp-0A0h],rax
    30f: call    fn8
    314: nop     [rcx-50h]
    31b: movzx   eax,byte ptr [rbp-4]
    31f: mov     [rbp-0A8h],al
    325: mov     rax,[rbp-28h]
    329: mov     [rbp-0B0h],rax
    330: mov     rax,[rbp-50h]
    334: mov     [rbp-0A0h],rax
    33b: call    fn9
    340: nop     [rcx-48h]
    347: mov     rax,[rbp-48h]
    34b: mov     [rbp-60h],rax
    34f: mov     rax,[rbp-40h]
    353: mov     [rbp-68h],rax
    357: mov     rax,[rbp-60h]
    35b: mov     [rbp-58h],rax
    35f: mov     rax,[rbp-68h]
    363: mov     [rbp-50h],rax
    367: mov     rax,[rbp+20h]
    36b: mov     [rbp-0B0h],rax
    372: mov     rax,[rbp-58h]
    376: mov     [rbp-0A8h],rax
    37d: mov     rax,[rbp-50h]
    381: mov     [rbp-0A0h],rax
    388: call    fn10
    38d: nop     [rcx-5]
    394: movzx   eax,byte ptr [rbp-5]
    398: mov     [rbp-0A8h],al
    39e: mov     rax,[rbp-48h]
    3a2: mov     [rbp-0B0h],rax
    3a9: mov     rax,[rbp-40h]
    3ad: mov     [rbp-0A0h],rax
    3b4: call    fn11
    3b9: nop     [rcx-50h]
    3c0: movzx   eax,byte ptr [rbp-5]
    3c4: mov     [rbp-0A8h],al
    3ca: mov     rax,[rbp-40h]
    3ce: mov     [rbp-0B0h],rax
    3d5: mov     rax,[rbp-48h]
    3d9: mov     [rbp-0A0h],rax
    3e0: call    fn12
    3e5: nop     [rcx-58h]
    3ec: mov     byte ptr [rbp-71h],1
    3f0: test    byte ptr [rbp-71h],0FFh
    3f4: je      45Ah
    3f6: mov     rax,[rbp-30h]
    3fa: mov     [rbp-60h],rax
    3fe: mov     rax,[rbp+18h]
    402: mov     [rbp-68h],rax
    406: mov     rax,[rbp-60h]
    40a: mov     [rbp-0B0h],rax
    411: mov     rax,[rbp-68h]
    415: mov     [rbp-0A8h],rax
    41c: mov     qword ptr [rbp-0A0h],4
    427: mov     qword ptr [rbp-98h],4
    432: mov     qword ptr [rbp-90h],1
    43d: mov     edi,0FFFFFF78h
    442: lea     rsi,[k13]
    449: call    ryo_h_AddrAbs
    44e: call    fn14
    453: nop     [rcx]
    45a: mov     qword ptr [rbp-78h],1
    462: imul    rax,[rbp-78h],4
    467: mov     [rbp-80h],rax
    46b: mov     edi,18h
    470: mov     esi,0FFFFFFD0h
    475: mov     edx,0FFFFFF80h
    47a: call    ryo_h_Memcpy
    47f: mov     qword ptr [rbp-78h],1
    487: mov     rax,[rbp+18h]
    48b: imul    rcx,[rbp-78h],4
    490: add     rax,rcx
    493: mov     [rbp-60h],rax
    497: mov     byte ptr [rbp-71h],1
    49b: test    byte ptr [rbp-71h],0FFh
    49f: je      505h
    4a1: mov     rax,[rbp-50h]
    4a5: mov     [rbp-68h],rax
    4a9: mov     rax,[rbp-60h]
    4ad: mov     [rbp-70h],rax
    4b1: mov     rax,[rbp-68h]
    4b5: mov     [rbp-0B0h],rax
    4bc: mov     rax,[rbp-70h]
    4c0: mov     [rbp-0A8h],rax
    4c7: mov     qword ptr [rbp-0A0h],4
    4d2: mov     qword ptr [rbp-98h],4
    4dd: mov     qword ptr [rbp-90h],1
    4e8: mov     edi,0FFFFFF78h
    4ed: lea     rsi,[k15]
    4f4: call    ryo_h_AddrAbs
    4f9: call    fn16
    4fe: nop     [rcx]
    505: mov     qword ptr [rbp-78h],1
    50d: imul    rax,[rbp-78h],4
    512: mov     [rbp-80h],rax
    516: mov     edi,0FFFFFFA0h
    51b: mov     esi,0FFFFFFB0h
    520: mov     edx,0FFFFFF80h
    525: call    ryo_h_Memcpy
    52a: mov     qword ptr [rbp-78h],2
    532: mov     rax,[rbp+18h]
    536: imul    rcx,[rbp-78h],4
    53b: add     rax,rcx
    53e: mov     [rbp-60h],rax
    542: mov     byte ptr [rbp-71h],1
    546: test    byte ptr [rbp-71h],0FFh
    54a: je      5B0h
    54c: mov     rax,[rbp-58h]
    550: mov     [rbp-68h],rax
    554: mov     rax,[rbp-60h]
    558: mov     [rbp-70h],rax
    55c: mov     rax,[rbp-68h]
    560: mov     [rbp-0B0h],rax
    567: mov     rax,[rbp-70h]
    56b: mov     [rbp-0A8h],rax
    572: mov     qword ptr [rbp-0A0h],4
    57d: mov     qword ptr [rbp-98h],4
    588: mov     qword ptr [rbp-90h],1
    593: mov     edi,0FFFFFF78h
    598: lea     rsi,[k17]
    59f: call    ryo_h_AddrAbs
    5a4: call    fn18
    5a9: nop     [rcx]
    5b0: mov     qword ptr [rbp-78h],1
    5b8: imul    rax,[rbp-78h],4
    5bd: mov     [rbp-80h],rax
    5c1: mov     edi,0FFFFFFA0h
    5c6: mov     esi,0FFFFFFA8h
    5cb: mov     edx,0FFFFFF80h
    5d0: call    ryo_h_Memcpy
    5d5: mov     qword ptr [rbp-78h],3
    5dd: mov     rax,[rbp+18h]
    5e1: imul    rcx,[rbp-78h],4
    5e6: add     rax,rcx
    5e9: mov     [rbp-60h],rax
    5ed: mov     byte ptr [rbp-71h],1
    5f1: test    byte ptr [rbp-71h],0FFh
    5f5: je      65Bh
    5f7: mov     rax,[rbp-38h]
    5fb: mov     [rbp-68h],rax
    5ff: mov     rax,[rbp-60h]
    603: mov     [rbp-70h],rax
    607: mov     rax,[rbp-68h]
    60b: mov     [rbp-0B0h],rax
    612: mov     rax,[rbp-70h]
    616: mov     [rbp-0A8h],rax
    61d: mov     qword ptr [rbp-0A0h],4
    628: mov     qword ptr [rbp-98h],4
    633: mov     qword ptr [rbp-90h],1
    63e: mov     edi,0FFFFFF78h
    643: lea     rsi,[k19]
    64a: call    ryo_h_AddrAbs
    64f: call    fn20
    654: nop     [rcx]
    65b: mov     qword ptr [rbp-78h],1
    663: imul    rax,[rbp-78h],4
    668: mov     [rbp-80h],rax
    66c: mov     edi,0FFFFFFA0h
    671: mov     esi,0FFFFFFC8h
    676: mov     edx,0FFFFFF80h
    67b: call    ryo_h_Memcpy
    680: xor     edi,edi
    682: xor     esi,esi
    684: call    ryo_h_Ret
    689: leave
    68a: ret

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-60h],rax
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-58h],rax
     20: mov     rax,[rbp+28h]
     24: mov     [rbp-50h],rax
     28: call    fn0
     2d: nop     [rcx]
     34: mov     qword ptr [rbp-30h],4
     3c: mov     rax,[rbp+10h]
     40: imul    rcx,[rbp-30h],8
     45: add     rax,rcx
     48: mov     [rbp-10h],rax
     4c: mov     rax,[rbp-10h]
     50: mov     [rbp-8],rax
     54: mov     qword ptr [rbp-30h],4
     5c: mov     rax,[rbp+20h]
     60: imul    rcx,[rbp-30h],8
     65: add     rax,rcx
     68: mov     [rbp-10h],rax
     6c: mov     rax,[rbp-8]
     70: mov     [rbp-60h],rax
     74: mov     rax,[rbp-10h]
     78: mov     [rbp-58h],rax
     7c: mov     rax,[rbp+28h]
     80: mov     [rbp-50h],rax
     84: call    fn1
     89: nop     [rcx]
     90: mov     rax,[rbp+20h]
     94: mov     [rbp-18h],rax
     98: mov     byte ptr [rbp-29h],1
     9c: test    byte ptr [rbp-29h],0FFh
     a0: je      100h
     a2: jmp     0BBh
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: xor     edi,edi
     b2: xor     esi,esi
     b4: call    ryo_h_Ret
     b9: leave
     ba: ret
     bb: mov     rax,[rbp+20h]
     bf: mov     [rbp-20h],rax
     c3: mov     rax,[rbp-20h]
     c7: mov     [rbp-60h],rax
     cb: mov     qword ptr [rbp-58h],8
     d3: mov     qword ptr [rbp-50h],4
     db: mov     qword ptr [rbp-48h],8
     e3: mov     edi,0FFFFFFC0h
     e8: lea     rsi,[k2]
     ef: call    ryo_h_AddrAbs
     f4: call    fn3
     f9: nop     [rcx]
    100: mov     rax,[rbp-18h]
    104: mov     [rbp-28h],rax
    108: mov     qword ptr [rbp-20h],8
    110: mov     rax,[rbp-28h]
    114: mov     [rbp-10h],rax
    118: mov     rax,[rbp-20h]
    11c: mov     [rbp-8],rax
    120: mov     edi,0FFFFFFA0h
    125: mov     esi,0FFFFFFF0h
    12a: call    ryo_h_MovW128
    12f: mov     rax,[rbp+18h]
    133: mov     [rbp-50h],rax
    137: mov     rax,[rbp+28h]
    13b: mov     [rbp-48h],rax
    13f: call    fn4
    144: nop     [rcx]
    14b: jmp     0B0h

fn core::slice::sort::shared::smallsort::sort8_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-60h],rax
     18: mov     rax,[rbp+20h]
     1c: mov     [rbp-58h],rax
     20: mov     rax,[rbp+28h]
     24: mov     [rbp-50h],rax
     28: call    fn0
     2d: nop     [rcx]
     34: mov     qword ptr [rbp-30h],4
     3c: mov     rax,[rbp+10h]
     40: imul    rcx,[rbp-30h],4
     45: add     rax,rcx
     48: mov     [rbp-10h],rax
     4c: mov     rax,[rbp-10h]
     50: mov     [rbp-8],rax
     54: mov     qword ptr [rbp-30h],4
     5c: mov     rax,[rbp+20h]
     60: imul    rcx,[rbp-30h],4
     65: add     rax,rcx
     68: mov     [rbp-10h],rax
     6c: mov     rax,[rbp-8]
     70: mov     [rbp-60h],rax
     74: mov     rax,[rbp-10h]
     78: mov     [rbp-58h],rax
     7c: mov     rax,[rbp+28h]
     80: mov     [rbp-50h],rax
     84: call    fn1
     89: nop     [rcx]
     90: mov     rax,[rbp+20h]
     94: mov     [rbp-18h],rax
     98: mov     byte ptr [rbp-29h],1
     9c: test    byte ptr [rbp-29h],0FFh
     a0: je      100h
     a2: jmp     0BBh
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: xor     edi,edi
     b2: xor     esi,esi
     b4: call    ryo_h_Ret
     b9: leave
     ba: ret
     bb: mov     rax,[rbp+20h]
     bf: mov     [rbp-20h],rax
     c3: mov     rax,[rbp-20h]
     c7: mov     [rbp-60h],rax
     cb: mov     qword ptr [rbp-58h],4
     d3: mov     qword ptr [rbp-50h],4
     db: mov     qword ptr [rbp-48h],8
     e3: mov     edi,0FFFFFFC0h
     e8: lea     rsi,[k2]
     ef: call    ryo_h_AddrAbs
     f4: call    fn3
     f9: nop     [rcx]
    100: mov     rax,[rbp-18h]
    104: mov     [rbp-28h],rax
    108: mov     qword ptr [rbp-20h],8
    110: mov     rax,[rbp-28h]
    114: mov     [rbp-10h],rax
    118: mov     rax,[rbp-20h]
    11c: mov     [rbp-8],rax
    120: mov     edi,0FFFFFFA0h
    125: mov     esi,0FFFFFFF0h
    12a: call    ryo_h_MovW128
    12f: mov     rax,[rbp+18h]
    133: mov     [rbp-50h],rax
    137: mov     rax,[rbp+28h]
    13b: mov     [rbp-48h],rax
    13f: call    fn4
    144: nop     [rcx]
    14b: jmp     0B0h

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: cmp     qword ptr [rbp-10h],9
     15: jae     1Eh
     17: call    ryo_h_Abort
     1c: ud2
     1e: mov     rax,[rbp+10h]
     22: mov     [rbp-18h],rax
     26: mov     rax,[rbp+18h]
     2a: mov     [rbp-10h],rax
     2e: mov     rax,[rbp-18h]
     32: mov     [rbp-8],rax
     36: mov     rax,[rbp-8]
     3a: mov     [rbp-40h],rax
     3e: mov     qword ptr [rbp-38h],0
     46: mov     qword ptr [rbp-30h],3
     4e: mov     rax,[rbp+20h]
     52: mov     [rbp-28h],rax
     56: call    fn0
     5b: nop     [rcx]
     62: mov     rax,[rbp-8]
     66: mov     [rbp-40h],rax
     6a: mov     qword ptr [rbp-38h],1
     72: mov     qword ptr [rbp-30h],7
     7a: mov     rax,[rbp+20h]
     7e: mov     [rbp-28h],rax
     82: call    fn1
     87: nop     [rcx]
     8e: mov     rax,[rbp-8]
     92: mov     [rbp-40h],rax
     96: mov     qword ptr [rbp-38h],2
     9e: mov     qword ptr [rbp-30h],5
     a6: mov     rax,[rbp+20h]
     aa: mov     [rbp-28h],rax
     ae: call    fn2
     b3: nop     [rcx]
     ba: mov     rax,[rbp-8]
     be: mov     [rbp-40h],rax
     c2: mov     qword ptr [rbp-38h],4
     ca: mov     qword ptr [rbp-30h],8
     d2: mov     rax,[rbp+20h]
     d6: mov     [rbp-28h],rax
     da: call    fn3
     df: nop     [rcx]
     e6: mov     rax,[rbp-8]
     ea: mov     [rbp-40h],rax
     ee: mov     qword ptr [rbp-38h],0
     f6: mov     qword ptr [rbp-30h],7
     fe: mov     rax,[rbp+20h]
    102: mov     [rbp-28h],rax
    106: call    fn4
    10b: nop     [rcx]
    112: mov     rax,[rbp-8]
    116: mov     [rbp-40h],rax
    11a: mov     qword ptr [rbp-38h],2
    122: mov     qword ptr [rbp-30h],4
    12a: mov     rax,[rbp+20h]
    12e: mov     [rbp-28h],rax
    132: call    fn5
    137: nop     [rcx]
    13e: mov     rax,[rbp-8]
    142: mov     [rbp-40h],rax
    146: mov     qword ptr [rbp-38h],3
    14e: mov     qword ptr [rbp-30h],8
    156: mov     rax,[rbp+20h]
    15a: mov     [rbp-28h],rax
    15e: call    fn6
    163: nop     [rcx]
    16a: mov     rax,[rbp-8]
    16e: mov     [rbp-40h],rax
    172: mov     qword ptr [rbp-38h],5
    17a: mov     qword ptr [rbp-30h],6
    182: mov     rax,[rbp+20h]
    186: mov     [rbp-28h],rax
    18a: call    fn7
    18f: nop     [rcx]
    196: mov     rax,[rbp-8]
    19a: mov     [rbp-40h],rax
    19e: mov     qword ptr [rbp-38h],0
    1a6: mov     qword ptr [rbp-30h],2
    1ae: mov     rax,[rbp+20h]
    1b2: mov     [rbp-28h],rax
    1b6: call    fn8
    1bb: nop     [rcx]
    1c2: mov     rax,[rbp-8]
    1c6: mov     [rbp-40h],rax
    1ca: mov     qword ptr [rbp-38h],1
    1d2: mov     qword ptr [rbp-30h],3
    1da: mov     rax,[rbp+20h]
    1de: mov     [rbp-28h],rax
    1e2: call    fn9
    1e7: nop     [rcx]
    1ee: mov     rax,[rbp-8]
    1f2: mov     [rbp-40h],rax
    1f6: mov     qword ptr [rbp-38h],4
    1fe: mov     qword ptr [rbp-30h],5
    206: mov     rax,[rbp+20h]
    20a: mov     [rbp-28h],rax
    20e: call    fn10
    213: nop     [rcx]
    21a: mov     rax,[rbp-8]
    21e: mov     [rbp-40h],rax
    222: mov     qword ptr [rbp-38h],7
    22a: mov     qword ptr [rbp-30h],8
    232: mov     rax,[rbp+20h]
    236: mov     [rbp-28h],rax
    23a: call    fn11
    23f: nop     [rcx]
    246: mov     rax,[rbp-8]
    24a: mov     [rbp-40h],rax
    24e: mov     qword ptr [rbp-38h],1
    256: mov     qword ptr [rbp-30h],4
    25e: mov     rax,[rbp+20h]
    262: mov     [rbp-28h],rax
    266: call    fn12
    26b: nop     [rcx]
    272: mov     rax,[rbp-8]
    276: mov     [rbp-40h],rax
    27a: mov     qword ptr [rbp-38h],3
    282: mov     qword ptr [rbp-30h],6
    28a: mov     rax,[rbp+20h]
    28e: mov     [rbp-28h],rax
    292: call    fn13
    297: nop     [rcx]
    29e: mov     rax,[rbp-8]
    2a2: mov     [rbp-40h],rax
    2a6: mov     qword ptr [rbp-38h],5
    2ae: mov     qword ptr [rbp-30h],7
    2b6: mov     rax,[rbp+20h]
    2ba: mov     [rbp-28h],rax
    2be: call    fn14
    2c3: nop     [rcx]
    2ca: mov     rax,[rbp-8]
    2ce: mov     [rbp-40h],rax
    2d2: mov     qword ptr [rbp-38h],0
    2da: mov     qword ptr [rbp-30h],1
    2e2: mov     rax,[rbp+20h]
    2e6: mov     [rbp-28h],rax
    2ea: call    fn15
    2ef: nop     [rcx]
    2f6: mov     rax,[rbp-8]
    2fa: mov     [rbp-40h],rax
    2fe: mov     qword ptr [rbp-38h],2
    306: mov     qword ptr [rbp-30h],4
    30e: mov     rax,[rbp+20h]
    312: mov     [rbp-28h],rax
    316: call    fn16
    31b: nop     [rcx]
    322: mov     rax,[rbp-8]
    326: mov     [rbp-40h],rax
    32a: mov     qword ptr [rbp-38h],3
    332: mov     qword ptr [rbp-30h],5
    33a: mov     rax,[rbp+20h]
    33e: mov     [rbp-28h],rax
    342: call    fn17
    347: nop     [rcx]
    34e: mov     rax,[rbp-8]
    352: mov     [rbp-40h],rax
    356: mov     qword ptr [rbp-38h],6
    35e: mov     qword ptr [rbp-30h],8
    366: mov     rax,[rbp+20h]
    36a: mov     [rbp-28h],rax
    36e: call    fn18
    373: nop     [rcx]
    37a: mov     rax,[rbp-8]
    37e: mov     [rbp-40h],rax
    382: mov     qword ptr [rbp-38h],2
    38a: mov     qword ptr [rbp-30h],3
    392: mov     rax,[rbp+20h]
    396: mov     [rbp-28h],rax
    39a: call    fn19
    39f: nop     [rcx]
    3a6: mov     rax,[rbp-8]
    3aa: mov     [rbp-40h],rax
    3ae: mov     qword ptr [rbp-38h],4
    3b6: mov     qword ptr [rbp-30h],5
    3be: mov     rax,[rbp+20h]
    3c2: mov     [rbp-28h],rax
    3c6: call    fn20
    3cb: nop     [rcx]
    3d2: mov     rax,[rbp-8]
    3d6: mov     [rbp-40h],rax
    3da: mov     qword ptr [rbp-38h],6
    3e2: mov     qword ptr [rbp-30h],7
    3ea: mov     rax,[rbp+20h]
    3ee: mov     [rbp-28h],rax
    3f2: call    fn21
    3f7: nop     [rcx]
    3fe: mov     rax,[rbp-8]
    402: mov     [rbp-40h],rax
    406: mov     qword ptr [rbp-38h],1
    40e: mov     qword ptr [rbp-30h],2
    416: mov     rax,[rbp+20h]
    41a: mov     [rbp-28h],rax
    41e: call    fn22
    423: nop     [rcx]
    42a: mov     rax,[rbp-8]
    42e: mov     [rbp-40h],rax
    432: mov     qword ptr [rbp-38h],3
    43a: mov     qword ptr [rbp-30h],4
    442: mov     rax,[rbp+20h]
    446: mov     [rbp-28h],rax
    44a: call    fn23
    44f: nop     [rcx]
    456: mov     rax,[rbp-8]
    45a: mov     [rbp-40h],rax
    45e: mov     qword ptr [rbp-38h],5
    466: mov     qword ptr [rbp-30h],6
    46e: mov     rax,[rbp+20h]
    472: mov     [rbp-28h],rax
    476: call    fn24
    47b: nop     [rcx]
    482: xor     edi,edi
    484: xor     esi,esi
    486: call    ryo_h_Ret
    48b: leave
    48c: ret

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
     2b: mov     rax,[rbp-18h]
     2f: mov     [rbp-38h],rax
     33: mov     rax,[rbp-10h]
     37: mov     [rbp-40h],rax
     3b: mov     rax,[rbp-38h]
     3f: mov     [rbp-30h],rax
     43: mov     rax,[rbp-40h]
     47: mov     [rbp-28h],rax
     4b: mov     rax,[rbp+28h]
     4f: mov     [rbp-90h],rax
     56: mov     rax,[rbp-30h]
     5a: mov     [rbp-88h],rax
     61: mov     rax,[rbp-28h]
     65: mov     [rbp-80h],rax
     69: call    fn0
     6e: nop     [rcx-19h]
     75: movzx   eax,byte ptr [rbp-19h]
     79: mov     [rbp-88h],al
     7f: mov     rax,[rbp-18h]
     83: mov     [rbp-90h],rax
     8a: mov     rax,[rbp-10h]
     8e: mov     [rbp-80h],rax
     92: call    fn1
     97: nop     [rcx-28h]
     9e: movzx   eax,byte ptr [rbp-19h]
     a2: mov     [rbp-88h],al
     a8: mov     rax,[rbp-10h]
     ac: mov     [rbp-90h],rax
     b3: mov     rax,[rbp-18h]
     b7: mov     [rbp-80h],rax
     bb: call    fn2
     c0: nop     [rcx-30h]
     c7: mov     rax,[rbp-30h]
     cb: mov     [rbp-40h],rax
     cf: mov     rax,[rbp-40h]
     d3: mov     eax,[rax]
     d5: mov     [rbp-34h],eax
     d8: mov     eax,[rbp-34h]
     db: mov     [rbp-38h],eax
     de: mov     eax,[rbp-38h]
     e1: mov     [rbp-20h],eax
     e4: mov     rax,[rbp-28h]
     e8: mov     [rbp-38h],rax
     ec: mov     byte ptr [rbp-49h],1
     f0: test    byte ptr [rbp-49h],0FFh
     f4: je      181h
     fa: jmp     11Bh
     fc: nop     [rax]
    100: lea     rax,[rbp-20h]
    104: mov     [rbp-38h],rax
    108: mov     byte ptr [rbp-49h],1
    10c: test    byte ptr [rbp-49h],0FFh
    110: je      206h
    116: jmp     1ABh
    11b: mov     rax,[rbp-28h]
    11f: mov     [rbp-40h],rax
    123: mov     rax,[rbp-10h]
    127: mov     [rbp-48h],rax
    12b: mov     byte ptr [rbp-49h],0
    12f: test    byte ptr [rbp-49h],0FFh
    133: je      13Bh
    135: mov     byte ptr [rbp-1Ah],1
    139: jmp     13Fh
    13b: mov     byte ptr [rbp-1Ah],0
    13f: mov     rax,[rbp-40h]
    143: mov     [rbp-90h],rax
    14a: mov     rax,[rbp-48h]
    14e: mov     [rbp-88h],rax
    155: mov     qword ptr [rbp-80h],4
    15d: movzx   eax,byte ptr [rbp-1Ah]
    161: mov     [rbp-78h],al
    164: mov     edi,0FFFFFF90h
    169: lea     rsi,[k3]
    170: call    ryo_h_AddrAbs
    175: call    fn4
    17a: nop     [rcx-8]
    181: mov     qword ptr [rbp-50h],1
    189: imul    rax,[rbp-50h],4
    18e: mov     [rbp-58h],rax
    192: mov     edi,0FFFFFFF0h
    197: mov     esi,0FFFFFFC8h
    19c: mov     edx,0FFFFFFA8h
    1a1: call    ryo_h_Memmove
    1a6: jmp     100h
    1ab: mov     rax,[rbp-38h]
    1af: mov     [rbp-40h],rax
    1b3: mov     rax,[rbp-18h]
    1b7: mov     [rbp-48h],rax
    1bb: mov     rax,[rbp-40h]
    1bf: mov     [rbp-90h],rax
    1c6: mov     rax,[rbp-48h]
    1ca: mov     [rbp-88h],rax
    1d1: mov     qword ptr [rbp-80h],4
    1d9: mov     qword ptr [rbp-78h],4
    1e1: mov     qword ptr [rbp-70h],1
    1e9: mov     edi,0FFFFFF98h
    1ee: lea     rsi,[k5]
    1f5: call    ryo_h_AddrAbs
    1fa: call    fn6
    1ff: nop     [rcx-8]
    206: mov     qword ptr [rbp-50h],1
    20e: imul    rax,[rbp-50h],4
    213: mov     [rbp-58h],rax
    217: mov     edi,0FFFFFFE8h
    21c: mov     esi,0FFFFFFC8h
    221: mov     edx,0FFFFFFA8h
    226: call    ryo_h_Memcpy
    22b: xor     edi,edi
    22d: xor     esi,esi
    22f: call    ryo_h_Ret
    234: leave
    235: ret

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
     9e: mov     rax,[rbp-58h]
     a2: mov     [rbp-50h],rax
     a6: mov     qword ptr [rbp-48h],1000h
     ae: mov     rax,[rbp-50h]
     b2: mov     [rbp-28h],rax
     b6: mov     rax,[rbp-48h]
     ba: mov     [rbp-20h],rax
     be: mov     rax,[rbp-28h]
     c2: mov     [rbp-40h],rax
     c6: mov     rax,[rbp-28h]
     ca: mov     [rbp-38h],rax
     ce: mov     byte ptr [rbp-59h],1
     d2: test    byte ptr [rbp-59h],0FFh
     d6: je      123h
     d8: mov     rax,[rbp-28h]
     dc: mov     [rbp-40h],rax
     e0: mov     rax,[rbp-40h]
     e4: mov     [rbp-90h],rax
     eb: mov     qword ptr [rbp-88h],8
     f6: mov     qword ptr [rbp-80h],4
     fe: mov     rax,[rbp-30h]
    102: mov     [rbp-78h],rax
    106: mov     edi,0FFFFFF90h
    10b: lea     rsi,[k4]
    112: call    ryo_h_AddrAbs
    117: call    fn5
    11c: nop     [rcx-28h]
    123: mov     rax,[rbp-38h]
    127: mov     [rbp-48h],rax
    12b: mov     rax,[rbp-30h]
    12f: mov     [rbp-40h],rax
    133: mov     rax,[rbp-48h]
    137: mov     [rbp-10h],rax
    13b: mov     rax,[rbp-40h]
    13f: mov     [rbp-8],rax
    143: mov     edi,0FFFFFFF0h
    148: mov     esi,10h
    14d: call    ryo_h_Ret
    152: leave
    153: ret

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp-18h]
     17: cmp     rax,[rbp+30h]
     1b: jb      0C5h
     21: mov     rax,[rbp+10h]
     25: mov     [rbp-40h],rax
     29: mov     rax,[rbp+18h]
     2d: mov     [rbp-38h],rax
     31: mov     edi,0FFFFFF60h
     36: mov     esi,0FFFFFFC0h
     3b: call    ryo_h_MovW128
     40: mov     rax,[rbp+40h]
     44: mov     [rbp-90h],rax
     4b: call    fn0
     50: nop     [rcx-30h]
     57: mov     rax,[rbp-30h]
     5b: mov     [rbp-20h],rax
     5f: movzx   eax,byte ptr [rbp-28h]
     63: mov     [rbp-0Bh],al
     66: mov     rax,[rbp-20h]
     6a: cmp     rax,[rbp-18h]
     6e: setbe   [rbp-9]
     72: mov     rax,[rbp-20h]
     76: cmp     rax,[rbp+30h]
     7a: jb      0C5h
     7c: test    byte ptr [rbp-0Bh],0FFh
     80: je      0A0h
     82: cmp     qword ptr [rbp-20h],0
     87: jb      161h
     8d: jmp     1D2h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: mov     rax,[rbp-20h]
     a4: shl     rax,1
     a8: mov     [rbp-30h],rax
     ac: mov     rax,[rbp-30h]
     b0: or      rax,1
     b4: mov     [rbp-28h],rax
     b8: mov     rax,[rbp-28h]
     bc: mov     [rbp-8],rax
     c0: jmp     150h
     c5: test    byte ptr [rbp+38h],0FFh
     c9: je      122h
     cb: call    fn1
     d0: nop     [rcx-28h]
     d7: mov     rax,[rbp-28h]
     db: mov     [rbp-0A0h],rax
     e2: mov     rax,[rbp-18h]
     e6: mov     [rbp-98h],rax
     ed: call    fn2
     f2: nop     [rcx-20h]
     f9: jmp     22Ah
     fe: xchg    ax,ax
    100: mov     rax,[rbp-20h]
    104: shl     rax,1
    108: mov     [rbp-30h],rax
    10c: mov     rax,[rbp-30h]
    110: or      rax,1
    114: mov     [rbp-28h],rax
    118: mov     rax,[rbp-28h]
    11c: mov     [rbp-8],rax
    120: jmp     150h
    122: mov     rax,[rbp+30h]
    126: mov     [rbp-0A0h],rax
    12d: mov     rax,[rbp-18h]
    131: mov     [rbp-98h],rax
    138: call    fn3
    13d: nop     [rcx-20h]
    144: jmp     346h
    149: nop     [rax]
    150: mov     edi,0FFFFFFF8h
    155: mov     esi,8
    15a: call    ryo_h_Ret
    15f: leave
    160: ret
    161: mov     qword ptr [rbp-0A0h],0
    16c: mov     rax,[rbp-20h]
    170: mov     [rbp-98h],rax
    177: mov     rax,[rbp-18h]
    17b: mov     [rbp-90h],rax
    182: mov     edi,0FFFFFF78h
    187: lea     rsi,[k4]
    18e: call    ryo_h_AddrAbs
    193: lea     rdi,[sym5]
    19a: lea     rsi,[site6]
    1a1: mov     edx,0FFFFFFA0h
    1a6: call    ryo_h_CallExt
    1ab: test    rax,rax
    1ae: je      1BBh
    1b0: call    rax
    1b2: nop     [rcx-9]
    1b9: jmp     1CBh
    1bb: mov     rdi,rbp
    1be: lea     rsi,[ro+4]
    1c5: call    qword ptr [sym7]
    1cb: call    ryo_h_Unreachable
    1d0: ud2
    1d2: mov     rax,[rbp+10h]
    1d6: mov     [rbp-50h],rax
    1da: mov     rax,[rbp+18h]
    1de: mov     [rbp-48h],rax
    1e2: mov     rax,[rbp-50h]
    1e6: mov     [rbp-58h],rax
    1ea: mov     rax,[rbp-58h]
    1ee: mov     [rbp-40h],rax
    1f2: mov     rax,[rbp-20h]
    1f6: mov     [rbp-38h],rax
    1fa: mov     rax,[rbp-40h]
    1fe: mov     [rbp-30h],rax
    202: mov     rax,[rbp-38h]
    206: mov     [rbp-28h],rax
    20a: mov     edi,0FFFFFF60h
    20f: mov     esi,0FFFFFFD0h
    214: call    ryo_h_MovW128
    219: call    fn8
    21e: nop     [rcx-9]
    225: jmp     0A0h
    22a: cmp     qword ptr [rbp-20h],0
    22f: jb      331h
    235: jmp     333h
    23a: nop     [rax+rax]
    240: mov     rax,[rbp+10h]
    244: mov     [rbp-50h],rax
    248: mov     rax,[rbp+18h]
    24c: mov     [rbp-48h],rax
    250: mov     rax,[rbp-50h]
    254: mov     [rbp-58h],rax
    258: mov     rax,[rbp-58h]
    25c: mov     [rbp-40h],rax
    260: mov     rax,[rbp-20h]
    264: mov     [rbp-38h],rax
    268: mov     rax,[rbp-40h]
    26c: mov     [rbp-30h],rax
    270: mov     rax,[rbp-38h]
    274: mov     [rbp-28h],rax
    278: mov     edi,0FFFFFF60h
    27d: mov     esi,0FFFFFFD0h
    282: call    ryo_h_MovW128
    287: mov     edi,0FFFFFF70h
    28c: mov     esi,20h
    291: call    ryo_h_MovW128
    296: mov     dword ptr [rbp-78h],0
    29d: mov     qword ptr [rbp-80h],0
    2a5: mov     rax,[rbp+40h]
    2a9: mov     [rbp-70h],rax
    2ad: call    fn9
    2b2: nop     [rcx-9]
    2b9: jmp     100h
    2be: xchg    ax,ax
    2c0: mov     qword ptr [rbp-0A0h],0
    2cb: mov     rax,[rbp-20h]
    2cf: mov     [rbp-98h],rax
    2d6: mov     rax,[rbp-18h]
    2da: mov     [rbp-90h],rax
    2e1: mov     edi,0FFFFFF78h
    2e6: lea     rsi,[k10]
    2ed: call    ryo_h_AddrAbs
    2f2: lea     rdi,[sym11]
    2f9: lea     rsi,[site12]
    300: mov     edx,0FFFFFFA0h
    305: call    ryo_h_CallExt
    30a: test    rax,rax
    30d: je      31Ah
    30f: call    rax
    311: nop     [rcx-9]
    318: jmp     32Ah
    31a: mov     rdi,rbp
    31d: lea     rsi,[ro+4]
    324: call    qword ptr [sym13]
    32a: call    ryo_h_Unreachable
    32f: ud2
    331: jmp     2C0h
    333: mov     rax,[rbp-18h]
    337: cmp     rax,[rbp-20h]
    33b: jae     240h
    341: jmp     2C0h
    346: mov     rax,[rbp-20h]
    34a: shl     rax,1
    34e: mov     [rbp-28h],rax
    352: mov     rax,[rbp-28h]
    356: mov     [rbp-8],rax
    35a: jmp     150h

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
     2b: je      79h
     2d: mov     rax,[rbp+30h]
     31: mov     [rbp-40h],rax
     35: mov     rax,[rbp-40h]
     39: and     rax,1
     3d: mov     [rbp-38h],rax
     41: cmp     qword ptr [rbp-38h],1
     46: sete    [rbp-2Ah]
     4a: test    byte ptr [rbp-2Ah],0FFh
     4e: je      52h
     50: jmp     79h
     52: mov     rax,[rbp+38h]
     56: mov     [rbp-40h],rax
     5a: mov     rax,[rbp-40h]
     5e: and     rax,1
     62: mov     [rbp-38h],rax
     66: cmp     qword ptr [rbp-38h],1
     6b: sete    [rbp-2Bh]
     6f: test    byte ptr [rbp-2Bh],0FFh
     73: je      17Eh
     79: mov     rax,[rbp+30h]
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp-20h]
     85: and     rax,1
     89: mov     [rbp-38h],rax
     8d: cmp     qword ptr [rbp-38h],1
     92: sete    [rbp-2Ch]
     96: test    byte ptr [rbp-2Ch],0FFh
     9a: jne     0C0h
     9c: mov     rax,[rbp-20h]
     a0: shr     rax,1
     a4: mov     [rbp-10h],rax
     a8: cmp     qword ptr [rbp-10h],0
     ad: jb      2A1h
     b3: jmp     2A3h
     b8: nop     [rax+rax]
     c0: mov     rax,[rbp+38h]
     c4: mov     [rbp-40h],rax
     c8: mov     rax,[rbp-40h]
     cc: and     rax,1
     d0: mov     [rbp-38h],rax
     d4: cmp     qword ptr [rbp-38h],1
     d9: sete    [rbp-2Ch]
     dd: test    byte ptr [rbp-2Ch],0FFh
     e1: je      0E5h
     e3: jmp     110h
     e5: mov     rax,[rbp-20h]
     e9: shr     rax,1
     ed: mov     [rbp-18h],rax
     f1: mov     rax,[rbp-28h]
     f5: cmp     rax,[rbp-18h]
     f9: jb      2B6h
     ff: jmp     327h
    104: nop     [rax+rax]
    10d: nop     [rax]
    110: mov     rax,[rbp-20h]
    114: shr     rax,1
    118: mov     [rbp-38h],rax
    11c: mov     edi,0FFFFFF50h
    121: mov     esi,10h
    126: call    ryo_h_MovW128
    12b: mov     edi,0FFFFFF60h
    130: mov     esi,20h
    135: call    ryo_h_MovW128
    13a: mov     rax,[rbp-38h]
    13e: mov     [rbp-90h],rax
    145: mov     rax,[rbp+40h]
    149: mov     [rbp-88h],rax
    150: call    fn0
    155: nop     [rcx-18h]
    15c: mov     rax,[rbp-28h]
    160: shl     rax,1
    164: mov     [rbp-40h],rax
    168: mov     rax,[rbp-40h]
    16c: or      rax,1
    170: mov     [rbp-38h],rax
    174: mov     rax,[rbp-38h]
    178: mov     [rbp-8],rax
    17c: jmp     192h
    17e: mov     rax,[rbp-28h]
    182: shl     rax,1
    186: mov     [rbp-38h],rax
    18a: mov     rax,[rbp-38h]
    18e: mov     [rbp-8],rax
    192: mov     edi,0FFFFFFF8h
    197: mov     esi,8
    19c: call    ryo_h_Ret
    1a1: leave
    1a2: ret
    1a3: nop     [rax+rax]
    1ac: nop     [rax]
    1b0: mov     rax,[rbp+10h]
    1b4: mov     [rbp-60h],rax
    1b8: mov     rax,[rbp+18h]
    1bc: mov     [rbp-58h],rax
    1c0: mov     rax,[rbp-60h]
    1c4: mov     [rbp-68h],rax
    1c8: mov     rax,[rbp-68h]
    1cc: mov     [rbp-50h],rax
    1d0: mov     rax,[rbp-10h]
    1d4: mov     [rbp-48h],rax
    1d8: mov     rax,[rbp-50h]
    1dc: mov     [rbp-40h],rax
    1e0: mov     rax,[rbp-48h]
    1e4: mov     [rbp-38h],rax
    1e8: mov     edi,0FFFFFF50h
    1ed: mov     esi,0FFFFFFC0h
    1f2: call    ryo_h_MovW128
    1f7: mov     edi,0FFFFFF60h
    1fc: mov     esi,20h
    201: call    ryo_h_MovW128
    206: mov     rax,[rbp+40h]
    20a: mov     [rbp-90h],rax
    211: call    fn1
    216: nop     [rcx-8]
    21d: jmp     0C0h
    222: nop     [rax+rax]
    22b: nop     [rax+rax]
    230: mov     qword ptr [rbp-0B0h],0
    23b: mov     rax,[rbp-10h]
    23f: mov     [rbp-0A8h],rax
    246: mov     rax,[rbp-28h]
    24a: mov     [rbp-0A0h],rax
    251: mov     edi,0FFFFFF68h
    256: lea     rsi,[k2]
    25d: call    ryo_h_AddrAbs
    262: lea     rdi,[sym3]
    269: lea     rsi,[site4]
    270: mov     edx,0FFFFFF80h
    275: call    ryo_h_CallExt
    27a: test    rax,rax
    27d: je      28Ah
    27f: call    rax
    281: nop     [rcx-18h]
    288: jmp     29Ah
    28a: mov     rdi,rbp
    28d: lea     rsi,[ro+4]
    294: call    qword ptr [sym5]
    29a: call    ryo_h_Unreachable
    29f: ud2
    2a1: jmp     230h
    2a3: mov     rax,[rbp-28h]
    2a7: cmp     rax,[rbp-10h]
    2ab: jae     1B0h
    2b1: jmp     230h
    2b6: mov     rax,[rbp-18h]
    2ba: mov     [rbp-0B0h],rax
    2c1: mov     rax,[rbp-28h]
    2c5: mov     [rbp-0A8h],rax
    2cc: mov     rax,[rbp-28h]
    2d0: mov     [rbp-0A0h],rax
    2d7: mov     edi,0FFFFFF68h
    2dc: lea     rsi,[k6]
    2e3: call    ryo_h_AddrAbs
    2e8: lea     rdi,[sym7]
    2ef: lea     rsi,[site8]
    2f6: mov     edx,0FFFFFF80h
    2fb: call    ryo_h_CallExt
    300: test    rax,rax
    303: je      310h
    305: call    rax
    307: nop     [rcx-18h]
    30e: jmp     320h
    310: mov     rdi,rbp
    313: lea     rsi,[ro+4]
    31a: call    qword ptr [sym9]
    320: call    ryo_h_Unreachable
    325: ud2
    327: mov     rax,[rbp-28h]
    32b: sub     rax,[rbp-18h]
    32f: mov     [rbp-48h],rax
    333: mov     rax,[rbp+10h]
    337: mov     [rbp-68h],rax
    33b: mov     rax,[rbp+18h]
    33f: mov     [rbp-60h],rax
    343: mov     rax,[rbp-68h]
    347: mov     [rbp-70h],rax
    34b: mov     rax,[rbp-70h]
    34f: imul    rcx,[rbp-18h],8
    354: add     rax,rcx
    357: mov     [rbp-78h],rax
    35b: mov     rax,[rbp-78h]
    35f: mov     [rbp-58h],rax
    363: mov     rax,[rbp-48h]
    367: mov     [rbp-50h],rax
    36b: mov     rax,[rbp-58h]
    36f: mov     [rbp-40h],rax
    373: mov     rax,[rbp-50h]
    377: mov     [rbp-38h],rax
    37b: mov     edi,0FFFFFF50h
    380: mov     esi,0FFFFFFC0h
    385: call    ryo_h_MovW128
    38a: mov     edi,0FFFFFF60h
    38f: mov     esi,20h
    394: call    ryo_h_MovW128
    399: mov     rax,[rbp+40h]
    39d: mov     [rbp-90h],rax
    3a4: call    fn10
    3a9: nop     [rcx-10h]
    3b0: jmp     110h

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,390h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     qword ptr [rbp-60h],2
     18: jae     1Fh
     1a: jmp     648h
     1f: mov     rax,[rbp-60h]
     23: mov     [rbp-70h],rax
     27: cmp     qword ptr [rbp-70h],0
     2c: sete    [rbp-79h]
     30: test    byte ptr [rbp-79h],0FFh
     34: je      653h
     3a: mov     edi,0FFFFFC70h
     3f: lea     rsi,[k0]
     46: call    ryo_h_AddrAbs
     4b: lea     rdi,[sym1]
     52: lea     rsi,[site2]
     59: mov     edx,0FFFFFCB0h
     5e: call    ryo_h_CallExt
     63: test    rax,rax
     66: je      73h
     68: call    rax
     6a: nop     [rcx-348h]
     71: jmp     83h
     73: mov     rdi,rbp
     76: lea     rsi,[ro+4]
     7d: call    qword ptr [sym3]
     83: call    ryo_h_Unreachable
     88: ud2
     8a: nop     [rax+rax]
     90: mov     qword ptr [rbp-350h],2
     9b: mov     edi,0FFFFFF78h
     a0: mov     esi,0FFFFFFA0h
     a5: mov     edx,0FFFFFCB0h
     aa: call    ryo_h_DivUW64
     af: mov     rax,[rbp-60h]
     b3: sub     rax,[rbp-88h]
     ba: mov     [rbp-80h],rax
     be: mov     rax,[rbp-80h]
     c2: mov     [rbp-390h],rax
     c9: mov     qword ptr [rbp-388h],40h
     d4: call    fn4
     d9: nop     [rcx-70h]
     e0: jmp     726h
     e5: nop     [rax+rax]
     ee: xchg    ax,ax
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
    169: mov     rax,[rbp-50h]
    16d: mov     [rbp-298h],rax
    174: mov     rax,[rbp-50h]
    178: mov     [rbp-290h],rax
    17f: mov     edi,0FFFFFD2Eh
    184: lea     rsi,[k9]
    18b: mov     edx,42h
    190: call    ryo_h_Const
    195: lea     rax,[rbp-2D2h]
    19c: mov     [rbp-58h],rax
    1a0: mov     rax,[rbp-58h]
    1a4: mov     [rbp-2E8h],rax
    1ab: mov     rax,[rbp-58h]
    1af: mov     [rbp-2E0h],rax
    1b6: mov     qword ptr [rbp-2E8h],0
    1c1: mov     qword ptr [rbp-38h],1
    1c9: nop     [rax]
    1d0: mov     rax,[rbp-2E8h]
    1d7: mov     [rbp-2F0h],rax
    1de: mov     rax,[rbp-2F0h]
    1e5: cmp     rax,[rbp-60h]
    1e9: jae     35Eh
    1ef: mov     rax,[rbp-2E8h]
    1f6: mov     [rbp-20h],rax
    1fa: mov     rax,[rbp-60h]
    1fe: cmp     rax,[rbp-20h]
    202: jb      72Bh
    208: jmp     79Ch
    20d: nop     [rax]
    210: mov     rax,[rbp-2E8h]
    217: mov     [rbp-2F8h],rax
    21e: mov     rax,[rbp-38h]
    222: mov     [rbp-308h],rax
    229: mov     rax,[rbp-308h]
    230: shr     rax,1
    234: mov     [rbp-300h],rax
    23b: mov     rax,[rbp-2F8h]
    242: sub     rax,[rbp-300h]
    249: mov     [rbp-2F0h],rax
    250: mov     rax,[rbp-2E8h]
    257: mov     [rbp-2F8h],rax
    25e: mov     rax,[rbp-2E8h]
    265: mov     [rbp-308h],rax
    26c: mov     rax,[rbp-18h]
    270: mov     [rbp-318h],rax
    277: mov     rax,[rbp-318h]
    27e: shr     rax,1
    282: mov     [rbp-310h],rax
    289: mov     rax,[rbp-308h]
    290: add     rax,[rbp-310h]
    297: mov     [rbp-300h],rax
    29e: mov     rax,[rbp-68h]
    2a2: mov     [rbp-308h],rax
    2a9: mov     rax,[rbp-2F0h]
    2b0: mov     [rbp-318h],rax
    2b7: mov     rax,[rbp-2F8h]
    2be: mov     [rbp-320h],rax
    2c5: mov     rax,[rbp-318h]
    2cc: add     rax,[rbp-320h]
    2d3: mov     [rbp-310h],rax
    2da: mov     rax,[rbp-300h]
    2e1: mov     [rbp-328h],rax
    2e8: mov     rax,[rbp-320h]
    2ef: add     rax,[rbp-328h]
    2f6: mov     [rbp-318h],rax
    2fd: mov     rax,[rbp-308h]
    304: imul    rax,[rbp-310h]
    30c: mov     [rbp-330h],rax
    313: mov     rax,[rbp-308h]
    31a: imul    rax,[rbp-318h]
    322: mov     [rbp-338h],rax
    329: mov     rax,[rbp-330h]
    330: xor     rax,[rbp-338h]
    337: mov     [rbp-328h],rax
    33e: mov     edi,0FFFFFCB4h
    343: mov     esi,0FFFFFCD8h
    348: call    ryo_h_CtlzW64
    34d: mov     eax,[rbp-34Ch]
    353: mov     [rbp-2D8h],eax
    359: jmp     87Ah
    35e: mov     qword ptr [rbp-18h],1
    366: mov     byte ptr [rbp-21h],0
    36a: nop     [rax+rax]
    370: mov     rax,[rbp-78h]
    374: mov     [rbp-2F0h],rax
    37b: cmp     qword ptr [rbp-2F0h],1
    383: jbe     503h
    389: mov     rax,[rbp-78h]
    38d: mov     [rbp-300h],rax
    394: mov     rax,[rbp-300h]
    39b: sub     rax,1
    39f: mov     [rbp-2F8h],rax
    3a6: mov     rax,[rbp-2E0h]
    3ad: imul    rcx,[rbp-2F8h],1
    3b5: add     rax,rcx
    3b8: mov     [rbp-2F0h],rax
    3bf: mov     rax,[rbp-2F0h]
    3c6: movzx   eax,byte ptr [rax]
    3c9: mov     [rbp-2D5h],al
    3cf: movzx   eax,byte ptr [rbp-21h]
    3d3: mov     [rbp-2D6h],al
    3d9: movzx   eax,byte ptr [rbp-2D5h]
    3e0: cmp     al,[rbp-2D6h]
    3e6: jb      501h
    3ec: mov     rax,[rbp-78h]
    3f0: mov     [rbp-308h],rax
    3f7: mov     rax,[rbp-308h]
    3fe: sub     rax,1
    402: mov     [rbp-300h],rax
    409: mov     rax,[rbp-290h]
    410: imul    rcx,[rbp-300h],8
    418: add     rax,rcx
    41b: mov     [rbp-2F8h],rax
    422: mov     rax,[rbp-2F8h]
    429: mov     rax,[rax]
    42c: mov     [rbp-2F0h],rax
    433: mov     rax,[rbp-2F0h]
    43a: mov     [rbp-308h],rax
    441: mov     rax,[rbp-308h]
    448: shr     rax,1
    44c: mov     [rbp-300h],rax
    453: mov     rax,[rbp-38h]
    457: mov     [rbp-310h],rax
    45e: mov     rax,[rbp-310h]
    465: shr     rax,1
    469: mov     [rbp-308h],rax
    470: mov     rax,[rbp-300h]
    477: add     rax,[rbp-308h]
    47e: mov     [rbp-2F8h],rax
    485: mov     rax,[rbp-2E8h]
    48c: mov     [rbp-308h],rax
    493: mov     rax,[rbp-308h]
    49a: sub     rax,[rbp-2F8h]
    4a1: mov     [rbp-300h],rax
    4a8: mov     rax,[rbp-2E8h]
    4af: mov     [rbp-30h],rax
    4b3: mov     rax,[rbp+10h]
    4b7: mov     [rbp-330h],rax
    4be: mov     rax,[rbp+18h]
    4c2: mov     [rbp-328h],rax
    4c9: mov     byte ptr [rbp-349h],1
    4d0: test    byte ptr [rbp-349h],0FFh
    4d7: je      8CFh
    4dd: jmp     88Eh
    4e2: nop     [rax+rax]
    4eb: nop     [rax+rax]
    4f0: mov     rax,[rbp-78h]
    4f4: sub     rax,1
    4f8: mov     [rbp-78h],rax
    4fc: jmp     370h
    501: jmp     503h
    503: mov     rax,[rbp-38h]
    507: mov     [rbp-2F0h],rax
    50e: mov     rax,[rbp-78h]
    512: mov     [rbp-300h],rax
    519: mov     rax,[rbp-290h]
    520: imul    rcx,[rbp-300h],8
    528: add     rax,rcx
    52b: mov     [rbp-2F8h],rax
    532: mov     rax,[rbp-2F8h]
    539: mov     rcx,[rbp-2F0h]
    540: mov     [rax],rcx
    543: mov     rax,[rbp-78h]
    547: mov     [rbp-2F8h],rax
    54e: mov     rax,[rbp-2E0h]
    555: imul    rcx,[rbp-2F8h],1
    55d: add     rax,rcx
    560: mov     [rbp-2F0h],rax
    567: mov     rax,[rbp-2F0h]
    56e: movzx   ecx,byte ptr [rbp-21h]
    572: mov     [rax],cl
    574: mov     rax,[rbp-78h]
    578: add     rax,1
    57c: mov     [rbp-78h],rax
    580: mov     rax,[rbp-2E8h]
    587: mov     [rbp-2F0h],rax
    58e: mov     rax,[rbp-2F0h]
    595: cmp     rax,[rbp-60h]
    599: jb      5D2h
    59b: mov     rax,[rbp-38h]
    59f: mov     [rbp-2F8h],rax
    5a6: mov     rax,[rbp-2F8h]
    5ad: and     rax,1
    5b1: mov     [rbp-2F0h],rax
    5b8: cmp     qword ptr [rbp-2F0h],1
    5c0: sete    [rbp-2D3h]
    5c7: test    byte ptr [rbp-2D3h],0FFh
    5ce: je      613h
    5d0: jmp     611h
    5d2: mov     rax,[rbp-18h]
    5d6: mov     [rbp-2F8h],rax
    5dd: mov     rax,[rbp-2F8h]
    5e4: shr     rax,1
    5e8: mov     [rbp-2F0h],rax
    5ef: mov     rax,[rbp-2E8h]
    5f6: add     rax,[rbp-2F0h]
    5fd: mov     [rbp-2E8h],rax
    604: mov     rax,[rbp-18h]
    608: mov     [rbp-38h],rax
    60c: jmp     1D0h
    611: jmp     648h
    613: mov     edi,0FFFFFC70h
    618: mov     esi,10h
    61d: call    ryo_h_MovW128
    622: mov     edi,0FFFFFC80h
    627: mov     esi,20h
    62c: call    ryo_h_MovW128
    631: mov     rax,[rbp+38h]
    635: mov     [rbp-370h],rax
    63c: call    fn10
    641: nop     [rcx-38h]
    648: xor     edi,edi
    64a: xor     esi,esi
    64c: call    ryo_h_Ret
    651: leave
    652: ret
    653: mov     rax,4000000000000000h
    65d: mov     [rbp-350h],rax
    664: mov     edi,0FFFFFF88h
    669: mov     esi,0FFFFFCB0h
    66e: mov     edx,0FFFFFF90h
    673: call    ryo_h_DivUW64
    678: test    byte ptr [rbp-79h],0FFh
    67c: je      6CEh
    67e: mov     edi,0FFFFFC70h
    683: lea     rsi,[k11]
    68a: call    ryo_h_AddrAbs
    68f: lea     rdi,[sym12]
    696: lea     rsi,[site13]
    69d: mov     edx,0FFFFFCB0h
    6a2: call    ryo_h_CallExt
    6a7: test    rax,rax
    6aa: je      6B7h
    6ac: call    rax
    6ae: nop     [rcx-348h]
    6b5: jmp     6C7h
    6b7: mov     rdi,rbp
    6ba: lea     rsi,[ro+4]
    6c1: call    qword ptr [sym14]
    6c7: call    ryo_h_Unreachable
    6cc: ud2
    6ce: mov     rax,4000000000000000h
    6d8: mov     [rbp-350h],rax
    6df: mov     edi,0FFFFFF78h
    6e4: mov     esi,0FFFFFCB0h
    6e9: mov     edx,0FFFFFF90h
    6ee: call    ryo_h_RemUW64
    6f3: cmp     qword ptr [rbp-88h],0
    6fb: jbe     70Bh
    6fd: mov     rax,[rbp-78h]
    701: add     rax,1
    705: mov     [rbp-68h],rax
    709: jmp     713h
    70b: mov     rax,[rbp-78h]
    70f: mov     [rbp-68h],rax
    713: cmp     qword ptr [rbp-60h],1000h
    71b: jbe     90h
    721: jmp     0F0h
    726: jmp     140h
    72b: mov     rax,[rbp-20h]
    72f: mov     [rbp-390h],rax
    736: mov     rax,[rbp-60h]
    73a: mov     [rbp-388h],rax
    741: mov     rax,[rbp-60h]
    745: mov     [rbp-380h],rax
    74c: mov     edi,0FFFFFC88h
    751: lea     rsi,[k15]
    758: call    ryo_h_AddrAbs
    75d: lea     rdi,[sym16]
    764: lea     rsi,[site17]
    76b: mov     edx,0FFFFFCB0h
    770: call    ryo_h_CallExt
    775: test    rax,rax
    778: je      785h
    77a: call    rax
    77c: nop     [rcx-58h]
    783: jmp     795h
    785: mov     rdi,rbp
    788: lea     rsi,[ro+36]
    78f: call    qword ptr [sym18]
    795: call    ryo_h_Unreachable
    79a: ud2
    79c: mov     rax,[rbp-60h]
    7a0: sub     rax,[rbp-20h]
    7a4: mov     [rbp-300h],rax
    7ab: mov     rax,[rbp+10h]
    7af: mov     [rbp-320h],rax
    7b6: mov     rax,[rbp+18h]
    7ba: mov     [rbp-318h],rax
    7c1: mov     rax,[rbp-320h]
    7c8: mov     [rbp-328h],rax
    7cf: mov     rax,[rbp-328h]
    7d6: imul    rcx,[rbp-20h],8
    7db: add     rax,rcx
    7de: mov     [rbp-330h],rax
    7e5: mov     rax,[rbp-330h]
    7ec: mov     [rbp-310h],rax
    7f3: mov     rax,[rbp-300h]
    7fa: mov     [rbp-308h],rax
    801: mov     rax,[rbp-310h]
    808: mov     [rbp-2F8h],rax
    80f: mov     rax,[rbp-308h]
    816: mov     [rbp-2F0h],rax
    81d: mov     rax,[rbp-70h]
    821: mov     [rbp-300h],rax
    828: mov     edi,0FFFFFC70h
    82d: mov     esi,0FFFFFD08h
    832: call    ryo_h_MovW128
    837: mov     edi,0FFFFFC80h
    83c: mov     esi,20h
    841: call    ryo_h_MovW128
    846: mov     rax,[rbp-300h]
    84d: mov     [rbp-370h],rax
    854: movzx   eax,byte ptr [rbp+30h]
    858: mov     [rbp-368h],al
    85e: mov     rax,[rbp+38h]
    862: mov     [rbp-360h],rax
    869: call    fn19
    86e: nop     [rcx-18h]
    875: jmp     210h
    87a: mov     edi,0FFFFFFDFh
    87f: mov     esi,0FFFFFD28h
    884: call    ryo_h_TruncW32W8
    889: jmp     370h
    88e: mov     rax,[rbp-300h]
    895: mov     [rbp-390h],rax
    89c: mov     rax,[rbp-30h]
    8a0: mov     [rbp-388h],rax
    8a7: mov     rax,[rbp-60h]
    8ab: mov     [rbp-380h],rax
    8b2: mov     edi,0FFFFFC88h
    8b7: lea     rsi,[k20]
    8be: call    ryo_h_AddrAbs
    8c3: call    fn21
    8c8: nop     [rcx-58h]
    8cf: mov     rax,[rbp-30h]
    8d3: sub     rax,[rbp-300h]
    8da: mov     [rbp-338h],rax
    8e1: mov     rax,[rbp-330h]
    8e8: mov     [rbp-340h],rax
    8ef: mov     rax,[rbp-340h]
    8f6: imul    rcx,[rbp-300h],8
    8fe: add     rax,rcx
    901: mov     [rbp-348h],rax
    908: mov     rax,[rbp-348h]
    90f: mov     [rbp-320h],rax
    916: mov     rax,[rbp-338h]
    91d: mov     [rbp-318h],rax
    924: mov     rax,[rbp-320h]
    92b: mov     [rbp-310h],rax
    932: mov     rax,[rbp-318h]
    939: mov     [rbp-308h],rax
    940: mov     rax,[rbp-38h]
    944: mov     [rbp-318h],rax
    94b: mov     edi,0FFFFFC70h
    950: mov     esi,0FFFFFCF0h
    955: call    ryo_h_MovW128
    95a: mov     edi,0FFFFFC80h
    95f: mov     esi,20h
    964: call    ryo_h_MovW128
    969: mov     rax,[rbp-2F0h]
    970: mov     [rbp-370h],rax
    977: mov     rax,[rbp-318h]
    97e: mov     [rbp-368h],rax
    985: mov     rax,[rbp+38h]
    989: mov     [rbp-360h],rax
    990: call    fn22
    995: nop     [rcx-38h]
    99c: jmp     4F0h

fn core::slice::sort::stable::drift::stable_quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp-18h]
     17: or      rax,1
     1b: mov     [rbp-10h],rax
     1f: mov     rax,[rbp-10h]
     23: mov     [rbp-18h],rax
     27: mov     edi,0FFFFFFC4h
     2c: mov     esi,0FFFFFFE8h
     31: xor     edx,edx
     33: xor     ecx,ecx
     35: xor     r8d,r8d
     38: mov     r9d,1
     3e: call    ryo_h_DiscrNicheW64
     43: mov     edi,0FFFFFFE0h
     48: mov     esi,0FFFFFFC4h
     4d: call    ryo_h_ZextW32W64
     52: mov     edi,0FFFFFFE0h
     57: xor     esi,esi
     59: mov     edx,2
     5e: call    ryo_h_SwitchDenseW64
     63: lea     rcx,[74h]
     6a: movsxd  rax,[rcx+rax*4]
     6e: add     rax,rcx
     71: jmp     rax
     73: int3
     74: .long   92h
     78: .long   e2h
     7c: .long   8bh
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
     ea: mov     rax,[rbp-28h]
     ee: mov     [rbp-38h],rax
     f2: mov     edi,0FFFFFFC4h
     f7: mov     esi,0FFFFFFC8h
     fc: call    ryo_h_CtlzW64
    101: mov     eax,[rbp-3Ch]
    104: mov     [rbp-2Ch],eax
    107: mov     dword ptr [rbp-3Ch],3Fh
    10e: mov     eax,[rbp-3Ch]
    111: sub     eax,[rbp-2Ch]
    114: mov     [rbp-4],eax
    117: mov     dword ptr [rbp-3Ch],2
    11e: mov     eax,[rbp-3Ch]
    121: imul    eax,[rbp-4]
    125: mov     [rbp-8],eax
    128: mov     edi,0FFFFFF80h
    12d: mov     esi,10h
    132: call    ryo_h_MovW128
    137: mov     edi,0FFFFFF90h
    13c: mov     esi,20h
    141: call    ryo_h_MovW128
    146: mov     eax,[rbp-8]
    149: mov     [rbp-58h],eax
    14c: mov     qword ptr [rbp-60h],0
    154: mov     rax,[rbp+30h]
    158: mov     [rbp-50h],rax
    15c: call    fn4
    161: nop     [rcx]
    168: jmp     80h

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
    105: jmp     288h
    10a: nop     [rax+rax]
    110: mov     rax,[rbp-10h]
    114: mov     [rbp-1068h],rax
    11b: mov     rax,[rbp-1068h]
    122: cmp     rax,[rbp-40h]
    126: jb      12Ah
    128: jmp     181h
    12a: mov     rax,[rbp-40h]
    12e: mov     [rbp-2090h],rax
    135: call    fn5
    13a: nop     [rcx-1078h]
    141: mov     byte ptr [rbp-19h],1
    145: mov     edi,0FFFFEFA8h
    14a: mov     esi,0FFFFEF88h
    14f: mov     edx,18h
    154: call    ryo_h_Copy
    159: lea     rax,[rbp-1058h]
    160: mov     [rbp-1068h],rax
    167: mov     rax,[rbp-1068h]
    16e: mov     [rbp-2090h],rax
    175: call    fn6
    17a: nop     [rcx-18h]
    181: call    fn7
    186: nop     [rcx-1070h]
    18d: imul    rax,[rbp-1070h],2
    195: mov     [rbp-1068h],rax
    19c: mov     rax,[rbp-38h]
    1a0: cmp     rax,[rbp-1068h]
    1a7: setbe   [rbp-1059h]
    1ae: mov     edi,0FFFFDF70h
    1b3: mov     esi,10h
    1b8: call    ryo_h_MovW128
    1bd: mov     edi,0FFFFDF80h
    1c2: mov     esi,0FFFFFFE8h
    1c7: call    ryo_h_MovW128
    1cc: movzx   eax,byte ptr [rbp-1059h]
    1d3: mov     [rbp-2070h],al
    1d9: mov     rax,[rbp+20h]
    1dd: mov     [rbp-2068h],rax
    1e4: call    fn8
    1e9: nop     [rcx-18h]
    1f0: test    byte ptr [rbp-19h],0FFh
    1f4: jne     21Ch
    1f6: nop     [rax+rax]
    1ff: nop
    200: xor     edi,edi
    202: xor     esi,esi
    204: call    ryo_h_Ret
    209: leave
    20a: ret
    20b: nop     [rax+rax]
    210: mov     edi,0FFFFFFD8h
    215: call    ryo_h_Resume
    21a: ud2
    21c: lea     rax,[rbp-1058h]
    223: mov     [rbp-2048h],rax
    22a: mov     rax,[rbp-2048h]
    231: mov     [rbp-2090h],rax
    238: call    fn9
    23d: nop     [rcx-2048h]
    244: jmp     200h
    246: nop     [rax+rax]
    24f: nop
    250: lea     rax,[rbp-1058h]
    257: mov     [rbp-2048h],rax
    25e: mov     rax,[rbp-2048h]
    265: mov     [rbp-2090h],rax
    26c: call    fn10
    271: nop     [rcx-2048h]
    278: jmp     210h
    27a: nop     [rax+rax]
    280: test    byte ptr [rbp-19h],0FFh
    284: je      210h
    286: jmp     250h
    288: mov     rax,[rbp-50h]
    28c: mov     [rbp-2090h],rax
    293: mov     rax,[rbp-58h]
    297: mov     [rbp-2088h],rax
    29e: call    fn11
    2a3: nop     [rcx-48h]
    2aa: mov     rax,[rbp-48h]
    2ae: mov     [rbp-2090h],rax
    2b5: mov     qword ptr [rbp-2088h],30h
    2c0: call    fn12
    2c5: nop     [rcx-40h]
    2cc: mov     edi,0FFFFDFC0h
    2d1: lea     rsi,[k13]
    2d8: mov     edx,1
    2dd: call    ryo_h_Const
    2e2: lea     rax,[rbp-2040h]
    2e9: mov     [rbp-2048h],rax
    2f0: mov     rax,[rbp-2048h]
    2f7: lea     rax,[rax+1]
    2fb: mov     [rbp-2050h],rax
    302: mov     qword ptr [rbp-2058h],1
    30d: mov     edi,0FFFFDFB0h
    312: mov     esi,0FFFFDFB8h
    317: mov     edx,0FFFFDFA8h
    31c: call    ryo_h_Memcpy
    321: mov     rax,[rbp-2048h]
    328: lea     rax,[rax+2]
    32c: mov     [rbp-2050h],rax
    333: mov     qword ptr [rbp-2058h],2
    33e: mov     edi,0FFFFDFB0h
    343: mov     esi,0FFFFDFB8h
    348: mov     edx,0FFFFDFA8h
    34d: call    ryo_h_Memcpy
    352: mov     rax,[rbp-2048h]
    359: lea     rax,[rax+4]
    35d: mov     [rbp-2050h],rax
    364: mov     qword ptr [rbp-2058h],4
    36f: mov     edi,0FFFFDFB0h
    374: mov     esi,0FFFFDFB8h
    379: mov     edx,0FFFFDFA8h
    37e: call    ryo_h_Memcpy
    383: mov     rax,[rbp-2048h]
    38a: lea     rax,[rax+8]
    38e: mov     [rbp-2050h],rax
    395: mov     qword ptr [rbp-2058h],8
    3a0: mov     edi,0FFFFDFB0h
    3a5: mov     esi,0FFFFDFB8h
    3aa: mov     edx,0FFFFDFA8h
    3af: call    ryo_h_Memcpy
    3b4: mov     rax,[rbp-2048h]
    3bb: lea     rax,[rax+10h]
    3bf: mov     [rbp-2050h],rax
    3c6: mov     qword ptr [rbp-2058h],10h
    3d1: mov     edi,0FFFFDFB0h
    3d6: mov     esi,0FFFFDFB8h
    3db: mov     edx,0FFFFDFA8h
    3e0: call    ryo_h_Memcpy
    3e5: mov     rax,[rbp-2048h]
    3ec: lea     rax,[rax+20h]
    3f0: mov     [rbp-2050h],rax
    3f7: mov     qword ptr [rbp-2058h],20h
    402: mov     edi,0FFFFDFB0h
    407: mov     esi,0FFFFDFB8h
    40c: mov     edx,0FFFFDFA8h
    411: call    ryo_h_Memcpy
    416: mov     rax,[rbp-2048h]
    41d: lea     rax,[rax+40h]
    421: mov     [rbp-2050h],rax
    428: mov     qword ptr [rbp-2058h],40h
    433: mov     edi,0FFFFDFB0h
    438: mov     esi,0FFFFDFB8h
    43d: mov     edx,0FFFFDFA8h
    442: call    ryo_h_Memcpy
    447: mov     rax,[rbp-2048h]
    44e: lea     rax,[rax+80h]
    455: mov     [rbp-2050h],rax
    45c: mov     qword ptr [rbp-2058h],80h
    467: mov     edi,0FFFFDFB0h
    46c: mov     esi,0FFFFDFB8h
    471: mov     edx,0FFFFDFA8h
    476: call    ryo_h_Memcpy
    47b: mov     rax,[rbp-2048h]
    482: lea     rax,[rax+100h]
    489: mov     [rbp-2050h],rax
    490: mov     qword ptr [rbp-2058h],100h
    49b: mov     edi,0FFFFDFB0h
    4a0: mov     esi,0FFFFDFB8h
    4a5: mov     edx,0FFFFDFA8h
    4aa: call    ryo_h_Memcpy
    4af: mov     rax,[rbp-2048h]
    4b6: lea     rax,[rax+200h]
    4bd: mov     [rbp-2050h],rax
    4c4: mov     qword ptr [rbp-2058h],200h
    4cf: mov     edi,0FFFFDFB0h
    4d4: mov     esi,0FFFFDFB8h
    4d9: mov     edx,0FFFFDFA8h
    4de: call    ryo_h_Memcpy
    4e3: mov     rax,[rbp-2048h]
    4ea: lea     rax,[rax+400h]
    4f1: mov     [rbp-2050h],rax
    4f8: mov     qword ptr [rbp-2058h],400h
    503: mov     edi,0FFFFDFB0h
    508: mov     esi,0FFFFDFB8h
    50d: mov     edx,0FFFFDFA8h
    512: call    ryo_h_Memcpy
    517: mov     rax,[rbp-2048h]
    51e: lea     rax,[rax+800h]
    525: mov     [rbp-2050h],rax
    52c: mov     qword ptr [rbp-2058h],800h
    537: mov     edi,0FFFFDFB0h
    53c: mov     esi,0FFFFDFB8h
    541: mov     edx,0FFFFDFA8h
    546: call    ryo_h_Memcpy
    54b: mov     edi,0FFFFEFC0h
    550: mov     esi,0FFFFDFC0h
    555: mov     edx,1000h
    55a: call    ryo_h_Copy
    55f: lea     rax,[rbp-1040h]
    566: mov     [rbp-1048h],rax
    56d: mov     rax,[rbp-1048h]
    574: mov     [rbp-2090h],rax
    57b: call    fn14
    580: nop     [rcx-18h]
    587: jmp     110h
    58c: nop     [rax]
    590: lea     rdi,[sym15]
    597: lea     rsi,[site16]
    59e: mov     edx,0FFFFDFB8h
    5a3: call    ryo_h_CallExt
    5a8: test    rax,rax
    5ab: je      5B8h
    5ad: call    rax
    5af: nop     [rcx-2040h]
    5b6: jmp     5C8h
    5b8: mov     rdi,rbp
    5bb: lea     rsi,[ro+4]
    5c2: call    qword ptr [sym17]
    5c8: call    ryo_h_Unreachable
    5cd: ud2
    5cf: mov     rdi,rax
    5d2: mov     esi,0FFFFFFD8h
    5d7: call    ryo_h_Lpad
    5dc: jmp     280h
    5e1: mov     rdi,rax
    5e4: mov     esi,0FFFFFFD8h
    5e9: call    ryo_h_Lpad
    5ee: jmp     590h

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
     7c: mov     rax,[rbp-38h]
     80: mov     [rbp-28h],rax
     84: mov     rax,[rbp-28h]
     88: cmp     rax,[rbp+20h]
     8c: jne     9Bh
     8e: xchg    ax,ax
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
    287: mov     rax,[rbp-38h]
    28b: mov     [rbp-20h],rax
    28f: mov     rax,[rbp-20h]
    293: cmp     rax,[rbp+18h]
    297: je      90h
    29d: jmp     70h

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
     2f: je      0E8h
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-18h],rax
     3d: mov     rax,[rbp-18h]
     41: cmp     rax,[rbp+20h]
     45: je      0E8h
     4b: mov     rax,[rbp+18h]
     4f: mov     [rbp-50h],rax
     53: mov     rax,[rbp+10h]
     57: mov     rax,[rax]
     5a: mov     [rbp-30h],rax
     5e: mov     rax,[rbp-30h]
     62: mov     [rbp-58h],rax
     66: mov     rax,[rbp-50h]
     6a: mov     [rbp-48h],rax
     6e: mov     rax,[rbp-58h]
     72: mov     [rbp-40h],rax
     76: mov     rax,[rbp+28h]
     7a: mov     [rbp-0A0h],rax
     81: mov     rax,[rbp-48h]
     85: mov     [rbp-98h],rax
     8c: mov     rax,[rbp-40h]
     90: mov     [rbp-90h],rax
     97: call    fn0
     9c: nop     [rcx-19h]
     a3: movzx   eax,byte ptr [rbp-19h]
     a7: xor     al,1
     aa: mov     [rbp-33h],al
     ad: test    byte ptr [rbp-33h],0FFh
     b1: je      0C8h
     b3: mov     rax,[rbp+10h]
     b7: mov     rax,[rax]
     ba: mov     [rbp-40h],rax
     be: mov     rax,[rbp-40h]
     c2: mov     [rbp-28h],rax
     c6: jmp     0D0h
     c8: mov     rax,[rbp+18h]
     cc: mov     [rbp-28h],rax
     d0: mov     rax,[rbp+10h]
     d4: mov     rax,[rax+10h]
     d8: mov     [rbp-40h],rax
     dc: mov     byte ptr [rbp-59h],1
     e0: test    byte ptr [rbp-59h],0FFh
     e4: je      154h
     e6: jmp     0F3h
     e8: xor     edi,edi
     ea: xor     esi,esi
     ec: call    ryo_h_Ret
     f1: leave
     f2: ret
     f3: mov     rax,[rbp-28h]
     f7: mov     [rbp-48h],rax
     fb: mov     rax,[rbp-40h]
     ff: mov     [rbp-50h],rax
    103: mov     rax,[rbp-48h]
    107: mov     [rbp-0A0h],rax
    10e: mov     rax,[rbp-50h]
    112: mov     [rbp-98h],rax
    119: mov     qword ptr [rbp-90h],8
    124: mov     qword ptr [rbp-88h],4
    12f: mov     qword ptr [rbp-80h],1
    137: mov     edi,0FFFFFF88h
    13c: lea     rsi,[k1]
    143: call    ryo_h_AddrAbs
    148: call    fn2
    14d: nop     [rcx-30h]
    154: mov     qword ptr [rbp-60h],1
    15c: imul    rax,[rbp-60h],8
    161: mov     [rbp-68h],rax
    165: mov     edi,0FFFFFFC0h
    16a: mov     esi,0FFFFFFD8h
    16f: mov     edx,0FFFFFF98h
    174: call    ryo_h_Memcpy
    179: mov     rax,[rbp+10h]
    17d: mov     rax,[rax]
    180: mov     [rbp-48h],rax
    184: mov     edi,0FFFFFFB0h
    189: mov     esi,0FFFFFFCDh
    18e: call    ryo_h_ZextW8W64
    193: mov     rax,[rbp-48h]
    197: imul    rcx,[rbp-50h],8
    19c: add     rax,rcx
    19f: mov     [rbp-40h],rax
    1a3: mov     rax,[rbp+10h]
    1a7: mov     rcx,[rbp-40h]
    1ab: mov     [rax],rcx
    1ae: mov     edi,0FFFFFFB8h
    1b3: mov     esi,0FFFFFFE7h
    1b8: call    ryo_h_ZextW8W64
    1bd: mov     rax,[rbp+18h]
    1c1: imul    rcx,[rbp-48h],8
    1c6: add     rax,rcx
    1c9: mov     [rbp-40h],rax
    1cd: mov     rax,[rbp-40h]
    1d1: mov     [rbp+18h],rax
    1d5: mov     rax,[rbp+10h]
    1d9: mov     rax,[rax+10h]
    1dd: mov     [rbp-48h],rax
    1e1: mov     qword ptr [rbp-60h],1
    1e9: mov     rax,[rbp-48h]
    1ed: imul    rcx,[rbp-60h],8
    1f2: add     rax,rcx
    1f5: mov     [rbp-40h],rax
    1f9: mov     rax,[rbp+10h]
    1fd: mov     rcx,[rbp-40h]
    201: mov     [rax+10h],rcx
    205: jmp     10h

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
     5a: jmp     271h
     5f: nop
     60: jmp     232h
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
     a8: mov     rax,[rbp-10h]
     ac: imul    rcx,[rbp+30h],8
     b1: add     rax,rcx
     b4: mov     [rbp-58h],rax
     b8: mov     rax,[rbp-10h]
     bc: imul    rcx,[rbp-48h],8
     c1: add     rax,rcx
     c4: mov     [rbp-60h],rax
     c8: mov     rax,[rbp+30h]
     cc: cmp     rax,[rbp-8]
     d0: setbe   [rbp-61h]
     d4: test    byte ptr [rbp-61h],0FFh
     d8: je      0DCh
     da: jmp     0E4h
     dc: mov     rax,[rbp-58h]
     e0: mov     [rbp-10h],rax
     e4: test    byte ptr [rbp-61h],0FFh
     e8: je      0ECh
     ea: jmp     0F4h
     ec: mov     rax,[rbp-8]
     f0: mov     [rbp+30h],rax
     f4: mov     rax,[rbp-10h]
     f8: mov     [rbp-18h],rax
     fc: mov     rax,[rbp-18h]
    100: mov     [rbp-70h],rax
    104: mov     rax,[rbp+30h]
    108: mov     [rbp-78h],rax
    10c: mov     byte ptr [rbp-99h],1
    113: test    byte ptr [rbp-99h],0FFh
    11a: je      2EEh
    120: jmp     284h
    125: nop     [rax+rax]
    12e: xchg    ax,ax
    130: lea     rax,[rbp-80h]
    134: mov     [rbp-88h],rax
    13b: mov     rax,[rbp-58h]
    13f: mov     [rbp-90h],rax
    146: mov     rax,[rbp-60h]
    14a: mov     [rbp-98h],rax
    151: mov     rax,[rbp-88h]
    158: mov     [rbp-0D0h],rax
    15f: mov     rax,[rbp-90h]
    166: mov     [rbp-0C8h],rax
    16d: mov     rax,[rbp-98h]
    174: mov     [rbp-0C0h],rax
    17b: mov     rax,[rbp+38h]
    17f: mov     [rbp-0B8h],rax
    186: call    fn1
    18b: nop     [rcx-18h]
    192: jmp     20Dh
    194: nop     [rax+rax]
    19d: nop     [rax]
    1a0: lea     rax,[rbp-80h]
    1a4: mov     [rbp-88h],rax
    1ab: mov     rax,[rbp-38h]
    1af: mov     [rbp-90h],rax
    1b6: mov     rax,[rbp-28h]
    1ba: mov     [rbp-98h],rax
    1c1: mov     rax,[rbp-88h]
    1c8: mov     [rbp-0D0h],rax
    1cf: mov     rax,[rbp-90h]
    1d6: mov     [rbp-0C8h],rax
    1dd: mov     rax,[rbp-98h]
    1e4: mov     [rbp-0C0h],rax
    1eb: mov     rax,[rbp-60h]
    1ef: mov     [rbp-0B8h],rax
    1f6: mov     rax,[rbp+38h]
    1fa: mov     [rbp-0B0h],rax
    201: call    fn2
    206: nop     [rcx-18h]
    20d: lea     rax,[rbp-80h]
    211: mov     [rbp-0A0h],rax
    218: mov     rax,[rbp-0A0h]
    21f: mov     [rbp-0D0h],rax
    226: call    fn3
    22b: nop     [rcx-0A0h]
    232: xor     edi,edi
    234: xor     esi,esi
    236: call    ryo_h_Ret
    23b: leave
    23c: ret
    23d: nop     [rax]
    240: lea     rax,[rbp-80h]
    244: mov     [rbp-0A0h],rax
    24b: mov     rax,[rbp-0A0h]
    252: mov     [rbp-0D0h],rax
    259: call    fn4
    25e: nop     [rcx-0A0h]
    265: mov     edi,0FFFFFFC0h
    26a: call    ryo_h_Resume
    26f: ud2
    271: mov     rax,[rbp-58h]
    275: cmp     rax,[rbp-60h]
    279: jb      60h
    27f: jmp     70h
    284: mov     rax,[rbp-18h]
    288: mov     [rbp-80h],rax
    28c: mov     rax,[rbp-28h]
    290: mov     [rbp-88h],rax
    297: mov     rax,[rbp-80h]
    29b: mov     [rbp-0D0h],rax
    2a2: mov     rax,[rbp-88h]
    2a9: mov     [rbp-0C8h],rax
    2b0: mov     qword ptr [rbp-0C0h],8
    2bb: mov     qword ptr [rbp-0B8h],4
    2c6: mov     rax,[rbp-78h]
    2ca: mov     [rbp-0B0h],rax
    2d1: mov     edi,0FFFFFF58h
    2d6: lea     rsi,[k5]
    2dd: call    ryo_h_AddrAbs
    2e2: call    fn6
    2e7: nop     [rcx-38h]
    2ee: imul    rax,[rbp-78h],8
    2f3: mov     [rbp-0A0h],rax
    2fa: mov     edi,0FFFFFFB0h
    2ff: mov     esi,0FFFFFF90h
    304: mov     edx,0FFFFFF60h
    309: call    ryo_h_Memcpy
    30e: mov     rax,[rbp-50h]
    312: imul    rcx,[rbp+30h],8
    317: add     rax,rcx
    31a: mov     [rbp-88h],rax
    321: mov     rax,[rbp-50h]
    325: mov     [rbp-80h],rax
    329: mov     rax,[rbp-88h]
    330: mov     [rbp-78h],rax
    334: mov     rax,[rbp-10h]
    338: mov     [rbp-70h],rax
    33c: test    byte ptr [rbp-61h],0FFh
    340: je      1A0h
    346: jmp     130h
    34b: nop     [rax+rax]
    350: lea     rdi,[sym7]
    357: lea     rsi,[site8]
    35e: mov     edx,0FFFFFF60h
    363: call    ryo_h_CallExt
    368: test    rax,rax
    36b: je      378h
    36d: call    rax
    36f: nop     [rcx-98h]
    376: jmp     388h
    378: mov     rdi,rbp
    37b: lea     rsi,[ro+4]
    382: call    qword ptr [sym9]
    388: call    ryo_h_Unreachable
    38d: ud2
    38f: mov     rdi,rax
    392: mov     esi,0FFFFFFC0h
    397: call    ryo_h_Lpad
    39c: jmp     240h
    3a1: mov     rdi,rax
    3a4: mov     esi,0FFFFFFC0h
    3a9: call    ryo_h_Lpad
    3ae: jmp     350h

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
    15d: mov     rax,[rbp-30h]
    161: add     rax,[rbp-18h]
    165: mov     [rbp-40h],rax
    169: mov     rax,[rbp+10h]
    16d: mov     rcx,[rbp-40h]
    171: mov     [rax+10h],rcx
    175: mov     rax,[rbp+10h]
    179: mov     rax,[rax+8]
    17d: mov     [rbp-20h],rax
    181: mov     qword ptr [rbp-30h],1
    189: mov     rax,[rbp-20h]
    18d: imul    rcx,[rbp-30h],8
    192: add     rax,rcx
    195: mov     [rbp-18h],rax
    199: mov     rax,[rbp+10h]
    19d: mov     rcx,[rbp-18h]
    1a1: mov     [rax+8],rcx
    1a5: mov     edi,0FFFFFFF8h
    1aa: mov     esi,8
    1af: call    ryo_h_Ret
    1b4: leave
    1b5: ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-88h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-80h],rax
     23: mov     rax,[rbp-80h]
     27: mov     [rbp-78h],rax
     2b: call    fn0
     30: nop     [rcx-80h]
     37: mov     rax,[rbp-80h]
     3b: cmp     rax,[rbp-78h]
     3f: jb      7Bh
     41: mov     edi,0FFFFFEF0h
     46: mov     esi,10h
     4b: call    ryo_h_MovW128
     50: mov     edi,0FFFFFF00h
     55: mov     esi,20h
     5a: call    ryo_h_MovW128
     5f: mov     rax,[rbp+40h]
     63: mov     [rbp-0F0h],rax
     6a: call    fn1
     6f: nop     [rcx]
     76: jmp     4C6h
     7b: mov     eax,[rbp+38h]
     7e: mov     [rbp-70h],eax
     81: cmp     dword ptr [rbp-70h],0
     85: jne     0C5h
     87: mov     edi,0FFFFFEF0h
     8c: mov     esi,10h
     91: call    ryo_h_MovW128
     96: mov     edi,0FFFFFF00h
     9b: mov     esi,20h
     a0: call    ryo_h_MovW128
     a5: mov     byte ptr [rbp-0F0h],1
     ac: mov     rax,[rbp+40h]
     b0: mov     [rbp-0E8h],rax
     b7: call    fn2
     bc: nop     [rcx]
     c3: jmp     10Ch
     c5: mov     eax,[rbp+38h]
     c8: sub     eax,1
     cb: mov     [rbp+38h],eax
     ce: mov     rax,[rbp+10h]
     d2: mov     [rbp-90h],rax
     d9: mov     rax,[rbp+18h]
     dd: mov     [rbp-88h],rax
     e4: mov     edi,0FFFFFEF0h
     e9: mov     esi,0FFFFFF70h
     ee: call    ryo_h_MovW128
     f3: mov     rax,[rbp+40h]
     f7: mov     [rbp-100h],rax
     fe: call    fn3
    103: nop     [rcx-80h]
    10a: jmp     111h
    10c: jmp     4C6h
    111: mov     rax,[rbp+10h]
    115: mov     [rbp-10h],rax
    119: mov     rax,[rbp+18h]
    11d: mov     [rbp-8],rax
    121: mov     rax,[rbp-8]
    125: mov     [rbp-18h],rax
    129: mov     rax,[rbp-80h]
    12d: cmp     rax,[rbp-18h]
    131: jb      199h
    133: mov     rax,[rbp-80h]
    137: mov     [rbp-110h],rax
    13e: mov     rax,[rbp-18h]
    142: mov     [rbp-108h],rax
    149: mov     edi,0FFFFFF00h
    14e: lea     rsi,[k4]
    155: call    ryo_h_AddrAbs
    15a: lea     rdi,[sym5]
    161: lea     rsi,[site6]
    168: mov     edx,0FFFFFF28h
    16d: call    ryo_h_CallExt
    172: test    rax,rax
    175: je      182h
    177: call    rax
    179: nop     [rcx-0D0h]
    180: jmp     192h
    182: mov     rdi,rbp
    185: lea     rsi,[ro+4]
    18c: call    qword ptr [sym7]
    192: call    ryo_h_Unreachable
    197: ud2
    199: mov     rax,[rbp+10h]
    19d: imul    rcx,[rbp-80h],8
    1a2: add     rax,rcx
    1a5: mov     [rbp-0D8h],rax
    1ac: mov     rax,[rbp-0D8h]
    1b3: mov     [rbp-98h],rax
    1ba: mov     rax,[rbp-98h]
    1c1: mov     [rbp-90h],rax
    1c8: mov     rax,[rbp-90h]
    1cf: mov     rax,[rax]
    1d2: mov     [rbp-88h],rax
    1d9: call    fn8
    1de: nop     [rcx-69h]
    1e5: jmp     4D1h
    1ea: mov     rax,[rbp+30h]
    1ee: mov     [rbp-90h],rax
    1f5: mov     rax,[rbp+10h]
    1f9: mov     [rbp-50h],rax
    1fd: mov     rax,[rbp+18h]
    201: mov     [rbp-48h],rax
    205: mov     rax,[rbp-48h]
    209: mov     [rbp-58h],rax
    20d: mov     rax,[rbp-80h]
    211: cmp     rax,[rbp-58h]
    215: jb      27Dh
    217: mov     rax,[rbp-80h]
    21b: mov     [rbp-110h],rax
    222: mov     rax,[rbp-58h]
    226: mov     [rbp-108h],rax
    22d: mov     edi,0FFFFFF00h
    232: lea     rsi,[k9]
    239: call    ryo_h_AddrAbs
    23e: lea     rdi,[sym10]
    245: lea     rsi,[site11]
    24c: mov     edx,0FFFFFF28h
    251: call    ryo_h_CallExt
    256: test    rax,rax
    259: je      266h
    25b: call    rax
    25d: nop     [rcx-0D0h]
    264: jmp     276h
    266: mov     rdi,rbp
    269: lea     rsi,[ro+4]
    270: call    qword ptr [sym12]
    276: call    ryo_h_Unreachable
    27b: ud2
    27d: mov     rax,[rbp+10h]
    281: imul    rcx,[rbp-80h],8
    286: add     rax,rcx
    289: mov     [rbp-0D8h],rax
    290: mov     rax,[rbp-0D8h]
    297: mov     [rbp-0A8h],rax
    29e: mov     rax,[rbp-90h]
    2a5: mov     [rbp-0A0h],rax
    2ac: mov     rax,[rbp-0A8h]
    2b3: mov     [rbp-98h],rax
    2ba: mov     rax,[rbp+40h]
    2be: mov     [rbp-110h],rax
    2c5: mov     rax,[rbp-0A0h]
    2cc: mov     [rbp-108h],rax
    2d3: mov     rax,[rbp-98h]
    2da: mov     [rbp-100h],rax
    2e1: call    fn13
    2e6: nop     [rcx-6Ah]
    2ed: movzx   eax,byte ptr [rbp-6Ah]
    2f1: xor     al,1
    2f4: mov     [rbp-31h],al
    2f7: mov     qword ptr [rbp-68h],0
    2ff: movzx   eax,byte ptr [rbp-31h]
    303: mov     [rbp-6Ah],al
    306: test    byte ptr [rbp-6Ah],0FFh
    30a: jne     37Dh
    30c: nop     [rax]
    310: mov     edi,0FFFFFF68h
    315: mov     esi,10h
    31a: call    ryo_h_MovW128
    31f: mov     edi,0FFFFFEF0h
    324: mov     esi,0FFFFFF68h
    329: call    ryo_h_MovW128
    32e: mov     edi,0FFFFFF00h
    333: mov     esi,20h
    338: call    ryo_h_MovW128
    33d: mov     rax,[rbp-80h]
    341: mov     [rbp-0F0h],rax
    348: mov     byte ptr [rbp-0E8h],0
    34f: mov     rax,[rbp+40h]
    353: mov     [rbp-0E0h],rax
    35a: call    fn14
    35f: nop     [rcx-68h]
    366: mov     rax,[rbp-68h]
    36a: mov     [rbp-90h],rax
    371: cmp     qword ptr [rbp-90h],0
    379: sete    [rbp-31h]
    37d: test    byte ptr [rbp-31h],0FFh
    381: je      41Dh
    387: mov     edi,0FFFFFF60h
    38c: mov     esi,10h
    391: call    ryo_h_MovW128
    396: mov     rax,[rbp+40h]
    39a: mov     [rbp-0B0h],rax
    3a1: lea     rax,[rbp-0B0h]
    3a8: mov     [rbp-0A8h],rax
    3af: mov     edi,0FFFFFEF0h
    3b4: mov     esi,0FFFFFF60h
    3b9: call    ryo_h_MovW128
    3be: mov     edi,0FFFFFF00h
    3c3: mov     esi,20h
    3c8: call    ryo_h_MovW128
    3cd: mov     rax,[rbp-80h]
    3d1: mov     [rbp-0F0h],rax
    3d8: mov     byte ptr [rbp-0E8h],1
    3df: mov     rax,[rbp-0A8h]
    3e6: mov     [rbp-0E0h],rax
    3ed: call    fn15
    3f2: nop     [rcx-90h]
    3f9: mov     rax,[rbp+18h]
    3fd: mov     [rbp-98h],rax
    404: mov     rax,[rbp-98h]
    40b: cmp     rax,[rbp-90h]
    412: jb      583h
    418: jmp     5FDh
    41d: mov     edi,0FFFFFEF0h
    422: mov     esi,10h
    427: call    ryo_h_MovW128
    42c: mov     rax,[rbp-68h]
    430: mov     [rbp-100h],rax
    437: mov     edi,0FFFFFF08h
    43c: lea     rsi,[k16]
    443: call    ryo_h_AddrAbs
    448: call    fn17
    44d: nop     [rcx-0B8h]
    454: mov     edi,10h
    459: mov     esi,0FFFFFF48h
    45e: call    ryo_h_MovW128
    463: mov     edi,0FFFFFF68h
    468: mov     esi,0FFFFFF58h
    46d: call    ryo_h_MovW128
    472: mov     eax,[rbp+38h]
    475: mov     [rbp-70h],eax
    478: mov     edi,0FFFFFEF0h
    47d: mov     esi,0FFFFFF68h
    482: call    ryo_h_MovW128
    487: mov     edi,0FFFFFF00h
    48c: mov     esi,20h
    491: call    ryo_h_MovW128
    496: mov     eax,[rbp-70h]
    499: mov     [rbp-0E8h],eax
    49f: mov     rax,[rbp-28h]
    4a3: mov     [rbp-0F0h],rax
    4aa: mov     rax,[rbp+40h]
    4ae: mov     [rbp-0E0h],rax
    4b5: call    fn18
    4ba: nop     [rcx-68h]
    4c1: jmp     10h
    4c6: xor     edi,edi
    4c8: xor     esi,esi
    4ca: call    ryo_h_Ret
    4cf: leave
    4d0: ret
    4d1: lea     rax,[rbp-88h]
    4d8: mov     [rbp-0A0h],rax
    4df: mov     rax,[rbp-0A0h]
    4e6: mov     [rbp-98h],rax
    4ed: mov     rax,[rbp-98h]
    4f4: mov     [rbp-90h],rax
    4fb: test    byte ptr [rbp-69h],0FFh
    4ff: je      579h
    501: jmp     56Ch
    503: nop     [rax+rax]
    50c: nop     [rax]
    510: mov     byte ptr [rbp-31h],0
    514: mov     edi,0FFFFFF2Ch
    519: mov     esi,30h
    51e: xor     edx,edx
    520: xor     ecx,ecx
    522: xor     r8d,r8d
    525: mov     r9d,1
    52b: call    ryo_h_DiscrNicheW64
    530: mov     edi,0FFFFFFC0h
    535: mov     esi,0FFFFFF2Ch
    53a: call    ryo_h_ZextW32W64
    53f: mov     edi,0FFFFFFC0h
    544: xor     esi,esi
    546: mov     edx,2
    54b: call    ryo_h_SwitchDenseW64
    550: lea     rcx,[560h]
    557: movsxd  rax,[rcx+rax*4]
    55b: add     rax,rcx
    55e: jmp     rax
    560: .long   695h
    564: .long   1eah
    568: .long   68eh
    56c: mov     rax,[rbp-90h]
    573: mov     [rbp-28h],rax
    577: jmp     510h
    579: mov     qword ptr [rbp-28h],0
    581: jmp     510h
    583: mov     rax,[rbp-90h]
    58a: mov     [rbp-110h],rax
    591: mov     rax,[rbp-98h]
    598: mov     [rbp-108h],rax
    59f: mov     rax,[rbp-98h]
    5a6: mov     [rbp-100h],rax
    5ad: mov     edi,0FFFFFF08h
    5b2: lea     rsi,[k19]
    5b9: call    ryo_h_AddrAbs
    5be: lea     rdi,[sym20]
    5c5: lea     rsi,[site21]
    5cc: mov     edx,0FFFFFF28h
    5d1: call    ryo_h_CallExt
    5d6: test    rax,rax
    5d9: je      5E6h
    5db: call    rax
    5dd: nop     [rcx-69h]
    5e4: jmp     5F6h
    5e6: mov     rdi,rbp
    5e9: lea     rsi,[ro+20]
    5f0: call    qword ptr [sym22]
    5f6: call    ryo_h_Unreachable
    5fb: ud2
    5fd: mov     rax,[rbp-98h]
    604: sub     rax,[rbp-90h]
    60b: mov     [rbp-0A0h],rax
    612: mov     rax,[rbp+10h]
    616: mov     [rbp-0C0h],rax
    61d: mov     rax,[rbp+18h]
    621: mov     [rbp-0B8h],rax
    628: mov     rax,[rbp-0C0h]
    62f: mov     [rbp-0C8h],rax
    636: mov     rax,[rbp-0C8h]
    63d: imul    rcx,[rbp-90h],8
    645: add     rax,rcx
    648: mov     [rbp-0D0h],rax
    64f: mov     rax,[rbp-0D0h]
    656: mov     [rbp-0B0h],rax
    65d: mov     rax,[rbp-0A0h]
    664: mov     [rbp-0A8h],rax
    66b: mov     rax,[rbp-0B0h]
    672: mov     [rbp+10h],rax
    676: mov     rax,[rbp-0A8h]
    67d: mov     [rbp+18h],rax
    681: mov     qword ptr [rbp+30h],0
    689: jmp     10h
    68e: call    ryo_h_Unreachable
    693: ud2
    695: mov     qword ptr [rbp-68h],0
    69d: jmp     310h

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
     21: mov     rax,[rbp-0A0h]
     28: cmp     rax,[rbp-90h]
     2f: jae     3Dh
     31: mov     byte ptr [rbp-91h],1
     38: jmp     58Dh
     3d: mov     rax,[rbp-90h]
     44: cmp     rax,[rbp+30h]
     48: setbe   [rbp-91h]
     4f: test    byte ptr [rbp-91h],0FFh
     56: je      594h
     5c: jmp     58Dh
     61: nop     [rax+rax]
     6a: nop     [rax+rax]
     70: mov     byte ptr [rbp-109h],1
     77: test    byte ptr [rbp-109h],0FFh
     7e: je      387h
     84: mov     rax,[rbp+30h]
     88: mov     [rbp-0E0h],rax
     8f: mov     rax,[rbp-0E0h]
     96: mov     [rbp-150h],rax
     9d: mov     qword ptr [rbp-148h],3
     a8: mov     rdi,rbp
     ab: lea     rsi,[ro+4]
     b2: call    qword ptr [sym0]
     b8: jmp     64Fh
     bd: nop     [rax]
     c0: mov     rax,[rbp-0C0h]
     c7: mov     [rbp-0E0h],rax
     ce: mov     rax,[rbp-0E0h]
     d5: cmp     rax,[rbp-0D0h]
     dc: jae     387h
     e2: lea     rax,[rbp-0C8h]
     e9: mov     [rbp-0E8h],rax
     f0: mov     rax,[rbp-0C0h]
     f7: mov     [rbp-38h],rax
     fb: mov     rax,[rbp-38h]
     ff: mov     [rbp-100h],rax
    106: mov     rax,[rbp-0A8h]
    10d: mov     [rbp-108h],rax
    114: mov     rax,[rbp-100h]
    11b: mov     [rbp-0F8h],rax
    122: mov     rax,[rbp-108h]
    129: mov     [rbp-0F0h],rax
    130: mov     rax,[rbp+40h]
    134: mov     [rbp-150h],rax
    13b: mov     rax,[rbp-0F8h]
    142: mov     [rbp-148h],rax
    149: mov     rax,[rbp-0F0h]
    150: mov     [rbp-140h],rax
    157: call    fn1
    15c: nop     [rcx-0D2h]
    163: mov     rax,[rbp-0E8h]
    16a: mov     [rbp-150h],rax
    171: movzx   eax,byte ptr [rbp-0D2h]
    178: mov     [rbp-148h],al
    17e: call    fn2
    183: nop     [rcx-0E0h]
    18a: lea     rax,[rbp-0C8h]
    191: mov     [rbp-0E8h],rax
    198: mov     rax,[rbp-0C0h]
    19f: mov     [rbp-40h],rax
    1a3: mov     rax,[rbp-40h]
    1a7: mov     [rbp-100h],rax
    1ae: mov     rax,[rbp-0A8h]
    1b5: mov     [rbp-108h],rax
    1bc: mov     rax,[rbp-100h]
    1c3: mov     [rbp-0F8h],rax
    1ca: mov     rax,[rbp-108h]
    1d1: mov     [rbp-0F0h],rax
    1d8: mov     rax,[rbp+40h]
    1dc: mov     [rbp-150h],rax
    1e3: mov     rax,[rbp-0F8h]
    1ea: mov     [rbp-148h],rax
    1f1: mov     rax,[rbp-0F0h]
    1f8: mov     [rbp-140h],rax
    1ff: call    fn3
    204: nop     [rcx-0D2h]
    20b: mov     rax,[rbp-0E8h]
    212: mov     [rbp-150h],rax
    219: movzx   eax,byte ptr [rbp-0D2h]
    220: mov     [rbp-148h],al
    226: call    fn4
    22b: nop     [rcx-0E0h]
    232: lea     rax,[rbp-0C8h]
    239: mov     [rbp-0E8h],rax
    240: mov     rax,[rbp-0C0h]
    247: mov     [rbp-48h],rax
    24b: mov     rax,[rbp-48h]
    24f: mov     [rbp-100h],rax
    256: mov     rax,[rbp-0A8h]
    25d: mov     [rbp-108h],rax
    264: mov     rax,[rbp-100h]
    26b: mov     [rbp-0F8h],rax
    272: mov     rax,[rbp-108h]
    279: mov     [rbp-0F0h],rax
    280: mov     rax,[rbp+40h]
    284: mov     [rbp-150h],rax
    28b: mov     rax,[rbp-0F8h]
    292: mov     [rbp-148h],rax
    299: mov     rax,[rbp-0F0h]
    2a0: mov     [rbp-140h],rax
    2a7: call    fn5
    2ac: nop     [rcx-0D2h]
    2b3: mov     rax,[rbp-0E8h]
    2ba: mov     [rbp-150h],rax
    2c1: movzx   eax,byte ptr [rbp-0D2h]
    2c8: mov     [rbp-148h],al
    2ce: call    fn6
    2d3: nop     [rcx-0E0h]
    2da: lea     rax,[rbp-0C8h]
    2e1: mov     [rbp-0E8h],rax
    2e8: mov     rax,[rbp-0C0h]
    2ef: mov     [rbp-50h],rax
    2f3: mov     rax,[rbp-50h]
    2f7: mov     [rbp-100h],rax
    2fe: mov     rax,[rbp-0A8h]
    305: mov     [rbp-108h],rax
    30c: mov     rax,[rbp-100h]
    313: mov     [rbp-0F8h],rax
    31a: mov     rax,[rbp-108h]
    321: mov     [rbp-0F0h],rax
    328: mov     rax,[rbp+40h]
    32c: mov     [rbp-150h],rax
    333: mov     rax,[rbp-0F8h]
    33a: mov     [rbp-148h],rax
    341: mov     rax,[rbp-0F0h]
    348: mov     [rbp-140h],rax
    34f: call    fn7
    354: nop     [rcx-0D2h]
    35b: mov     rax,[rbp-0E8h]
    362: mov     [rbp-150h],rax
    369: movzx   eax,byte ptr [rbp-0D2h]
    370: mov     [rbp-148h],al
    376: call    fn8
    37b: nop     [rcx-0E0h]
    382: jmp     0C0h
    387: mov     rax,[rbp+30h]
    38b: mov     [rbp-0D8h],rax
    392: mov     rax,[rbp-98h]
    399: imul    rcx,[rbp-0D8h],8
    3a1: add     rax,rcx
    3a4: mov     [rbp-0D0h],rax
    3ab: nop     [rax+rax]
    3b0: mov     rax,[rbp-0C0h]
    3b7: mov     [rbp-0E0h],rax
    3be: mov     rax,[rbp-0E0h]
    3c5: cmp     rax,[rbp-0D0h]
    3cc: jae     47Fh
    3d2: lea     rax,[rbp-0C8h]
    3d9: mov     [rbp-0E8h],rax
    3e0: mov     rax,[rbp-0C0h]
    3e7: mov     [rbp-58h],rax
    3eb: mov     rax,[rbp-58h]
    3ef: mov     [rbp-100h],rax
    3f6: mov     rax,[rbp-0A8h]
    3fd: mov     [rbp-108h],rax
    404: mov     rax,[rbp-100h]
    40b: mov     [rbp-0F8h],rax
    412: mov     rax,[rbp-108h]
    419: mov     [rbp-0F0h],rax
    420: mov     rax,[rbp+40h]
    424: mov     [rbp-150h],rax
    42b: mov     rax,[rbp-0F8h]
    432: mov     [rbp-148h],rax
    439: mov     rax,[rbp-0F0h]
    440: mov     [rbp-140h],rax
    447: call    fn9
    44c: nop     [rcx-0D2h]
    453: mov     rax,[rbp-0E8h]
    45a: mov     [rbp-150h],rax
    461: movzx   eax,byte ptr [rbp-0D2h]
    468: mov     [rbp-148h],al
    46e: call    fn10
    473: nop     [rcx-0E0h]
    47a: jmp     3B0h
    47f: mov     rax,[rbp+30h]
    483: cmp     rax,[rbp-90h]
    48a: jne     49Dh
    48c: call    fn11
    491: nop     [rcx-0CAh]
    498: jmp     66Dh
    49d: lea     rax,[rbp-0C8h]
    4a4: mov     [rbp-0D8h],rax
    4ab: mov     rax,[rbp-0D8h]
    4b2: mov     [rbp-150h],rax
    4b9: movzx   eax,byte ptr [rbp+38h]
    4bd: mov     [rbp-148h],al
    4c3: call    fn12
    4c8: nop     [rcx-10h]
    4cf: mov     rax,[rbp-90h]
    4d6: mov     [rbp+30h],rax
    4da: jmp     70h
    4df: nop
    4e0: mov     byte ptr [rbp-109h],1
    4e7: test    byte ptr [rbp-109h],0FFh
    4ee: je      702h
    4f4: jmp     68Fh
    4f9: nop     [rax]
    500: mov     rax,[rbp+10h]
    504: mov     [rbp-78h],rax
    508: mov     rax,[rbp+18h]
    50c: mov     [rbp-70h],rax
    510: mov     rax,[rbp-78h]
    514: mov     [rbp-0D0h],rax
    51b: mov     rax,[rbp-68h]
    51f: mov     [rbp-0D8h],rax
    526: mov     rax,[rbp-0B8h]
    52d: mov     [rbp-0E0h],rax
    534: mov     byte ptr [rbp-109h],1
    53b: test    byte ptr [rbp-109h],0FFh
    542: je      7A8h
    548: jmp     735h
    54d: nop     [rax]
    550: mov     rax,[rbp-20h]
    554: mov     [rbp-0F0h],rax
    55b: mov     rax,[rbp-18h]
    55f: mov     [rbp-0F8h],rax
    566: mov     rax,[rbp-0F0h]
    56d: cmp     rax,[rbp-0F8h]
    574: setb    [rbp-0E1h]
    57b: test    byte ptr [rbp-0E1h],0FFh
    582: je      823h
    588: jmp     806h
    58d: call    ryo_h_Abort
    592: ud2
    594: mov     rax,[rbp+10h]
    598: mov     [rbp-0A8h],rax
    59f: mov     rax,[rbp+18h]
    5a3: mov     [rbp-0A0h],rax
    5aa: mov     rax,[rbp-0A8h]
    5b1: mov     [rbp-98h],rax
    5b8: mov     rax,[rbp+20h]
    5bc: mov     [rbp-68h],rax
    5c0: mov     rax,[rbp+28h]
    5c4: mov     [rbp-60h],rax
    5c8: mov     rax,[rbp-68h]
    5cc: mov     [rbp-0A8h],rax
    5d3: mov     rax,[rbp-68h]
    5d7: mov     [rbp-0A0h],rax
    5de: mov     rax,[rbp-98h]
    5e5: imul    rcx,[rbp+30h],8
    5ea: add     rax,rcx
    5ed: mov     [rbp-0A8h],rax
    5f4: mov     rax,[rbp-0A0h]
    5fb: imul    rcx,[rbp-90h],8
    603: add     rax,rcx
    606: mov     [rbp-0D0h],rax
    60d: mov     rax,[rbp-0A0h]
    614: mov     [rbp-0C8h],rax
    61b: mov     rax,[rbp-98h]
    622: mov     [rbp-0C0h],rax
    629: mov     qword ptr [rbp-0B8h],0
    634: mov     rax,[rbp-0D0h]
    63b: mov     [rbp-0B0h],rax
    642: mov     qword ptr [rbp-10h],0
    64a: jmp     70h
    64f: mov     rax,[rbp-98h]
    656: imul    rcx,[rbp-0D8h],8
    65e: add     rax,rcx
    661: mov     [rbp-0D0h],rax
    668: jmp     0C0h
    66d: movzx   eax,byte ptr [rbp-0CAh]
    674: xor     al,1
    677: mov     [rbp-0C9h],al
    67d: test    byte ptr [rbp-0C9h],0FFh
    684: je      500h
    68a: jmp     4E0h
    68f: mov     rax,[rbp-0A8h]
    696: mov     [rbp-0D8h],rax
    69d: mov     rax,[rbp-10h]
    6a1: mov     [rbp-0E0h],rax
    6a8: mov     rax,[rbp-0D8h]
    6af: mov     [rbp-150h],rax
    6b6: mov     rax,[rbp-0E0h]
    6bd: mov     [rbp-148h],rax
    6c4: mov     qword ptr [rbp-140h],8
    6cf: mov     qword ptr [rbp-138h],4
    6da: mov     qword ptr [rbp-130h],1
    6e5: mov     edi,0FFFFFED8h
    6ea: lea     rsi,[k13]
    6f1: call    ryo_h_AddrAbs
    6f6: call    fn14
    6fb: nop     [rcx-68h]
    702: mov     qword ptr [rbp-110h],1
    70d: imul    rax,[rbp-110h],8
    715: mov     [rbp-118h],rax
    71c: mov     edi,0FFFFFFF0h
    721: mov     esi,0FFFFFF58h
    726: mov     edx,0FFFFFEE8h
    72b: call    ryo_h_Memcpy
    730: jmp     500h
    735: mov     rax,[rbp-68h]
    739: mov     [rbp-0E8h],rax
    740: mov     rax,[rbp-78h]
    744: mov     [rbp-0F0h],rax
    74b: mov     rax,[rbp-0E8h]
    752: mov     [rbp-150h],rax
    759: mov     rax,[rbp-0F0h]
    760: mov     [rbp-148h],rax
    767: mov     qword ptr [rbp-140h],8
    772: mov     qword ptr [rbp-138h],4
    77d: mov     rax,[rbp-0E0h]
    784: mov     [rbp-130h],rax
    78b: mov     edi,0FFFFFED8h
    790: lea     rsi,[k15]
    797: call    ryo_h_AddrAbs
    79c: call    fn16
    7a1: nop     [rcx-78h]
    7a8: imul    rax,[rbp-0E0h],8
    7b0: mov     [rbp-110h],rax
    7b7: mov     edi,0FFFFFF30h
    7bc: mov     esi,0FFFFFF28h
    7c1: mov     edx,0FFFFFEF0h
    7c6: call    ryo_h_Memcpy
    7cb: mov     rax,[rbp-0B8h]
    7d2: mov     [rbp-0E0h],rax
    7d9: mov     rax,[rbp-90h]
    7e0: sub     rax,[rbp-0E0h]
    7e7: mov     [rbp-0D8h],rax
    7ee: mov     qword ptr [rbp-20h],0
    7f6: mov     rax,[rbp-0D8h]
    7fd: mov     [rbp-18h],rax
    801: jmp     550h
    806: mov     rax,[rbp-20h]
    80a: mov     [rbp-0F0h],rax
    811: mov     byte ptr [rbp-109h],1
    818: test    byte ptr [rbp-109h],0FFh
    81f: je      875h
    821: jmp     83Fh
    823: mov     rax,[rbp-0B8h]
    82a: mov     [rbp-8],rax
    82e: mov     edi,0FFFFFFF8h
    833: mov     esi,8
    838: call    ryo_h_Ret
    83d: leave
    83e: ret
    83f: mov     rax,[rbp-0F0h]
    846: mov     [rbp-150h],rax
    84d: mov     qword ptr [rbp-148h],1
    858: mov     edi,0FFFFFEC0h
    85d: lea     rsi,[k17]
    864: call    ryo_h_AddrAbs
    869: call    fn18
    86e: nop     [rcx-88h]
    875: mov     rax,[rbp-0F0h]
    87c: add     rax,1
    880: mov     [rbp-0F8h],rax
    887: mov     rax,[rbp-0F8h]
    88e: mov     [rbp-20h],rax
    892: mov     rax,[rbp-0F0h]
    899: mov     [rbp-0D8h],rax
    8a0: mov     qword ptr [rbp-0E0h],1
    8ab: mov     rax,[rbp-0D8h]
    8b2: mov     [rbp-0E8h],rax
    8b9: mov     rax,[rbp-90h]
    8c0: sub     rax,1
    8c4: mov     [rbp-100h],rax
    8cb: mov     rax,[rbp-100h]
    8d2: sub     rax,[rbp-0E8h]
    8d9: mov     [rbp-0F8h],rax
    8e0: mov     rax,[rbp-0A0h]
    8e7: imul    rcx,[rbp-0F8h],8
    8ef: add     rax,rcx
    8f2: mov     [rbp-30h],rax
    8f6: mov     rax,[rbp-30h]
    8fa: mov     [rbp-0F0h],rax
    901: mov     rax,[rbp-0B8h]
    908: mov     [rbp-108h],rax
    90f: mov     rax,[rbp-108h]
    916: add     rax,[rbp-0E8h]
    91d: mov     [rbp-100h],rax
    924: mov     rax,[rbp-0D0h]
    92b: imul    rcx,[rbp-100h],8
    933: add     rax,rcx
    936: mov     [rbp-0F8h],rax
    93d: mov     byte ptr [rbp-109h],1
    944: test    byte ptr [rbp-109h],0FFh
    94b: je      9C0h
    94d: mov     rax,[rbp-30h]
    951: mov     [rbp-100h],rax
    958: mov     rax,[rbp-0F8h]
    95f: mov     [rbp-108h],rax
    966: mov     rax,[rbp-100h]
    96d: mov     [rbp-150h],rax
    974: mov     rax,[rbp-108h]
    97b: mov     [rbp-148h],rax
    982: mov     qword ptr [rbp-140h],8
    98d: mov     qword ptr [rbp-138h],4
    998: mov     qword ptr [rbp-130h],1
    9a3: mov     edi,0FFFFFED8h
    9a8: lea     rsi,[k19]
    9af: call    ryo_h_AddrAbs
    9b4: call    fn20
    9b9: nop     [rcx-88h]
    9c0: mov     qword ptr [rbp-110h],1
    9cb: imul    rax,[rbp-110h],8
    9d3: mov     [rbp-118h],rax
    9da: mov     edi,0FFFFFF08h
    9df: mov     esi,0FFFFFF10h
    9e4: mov     edx,0FFFFFEE8h
    9e9: call    ryo_h_Memcpy
    9ee: jmp     550h

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,150h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: mov     rax,[rbp+28h]
     1a: mov     [rbp-0A0h],rax
     21: mov     rax,[rbp-0A0h]
     28: cmp     rax,[rbp-90h]
     2f: jae     3Dh
     31: mov     byte ptr [rbp-91h],1
     38: jmp     58Dh
     3d: mov     rax,[rbp-90h]
     44: cmp     rax,[rbp+30h]
     48: setbe   [rbp-91h]
     4f: test    byte ptr [rbp-91h],0FFh
     56: je      594h
     5c: jmp     58Dh
     61: nop     [rax+rax]
     6a: nop     [rax+rax]
     70: mov     byte ptr [rbp-109h],1
     77: test    byte ptr [rbp-109h],0FFh
     7e: je      387h
     84: mov     rax,[rbp+30h]
     88: mov     [rbp-0E0h],rax
     8f: mov     rax,[rbp-0E0h]
     96: mov     [rbp-150h],rax
     9d: mov     qword ptr [rbp-148h],3
     a8: mov     rdi,rbp
     ab: lea     rsi,[ro+4]
     b2: call    qword ptr [sym0]
     b8: jmp     64Fh
     bd: nop     [rax]
     c0: mov     rax,[rbp-0C0h]
     c7: mov     [rbp-0E0h],rax
     ce: mov     rax,[rbp-0E0h]
     d5: cmp     rax,[rbp-0D0h]
     dc: jae     387h
     e2: lea     rax,[rbp-0C8h]
     e9: mov     [rbp-0E8h],rax
     f0: mov     rax,[rbp-0C0h]
     f7: mov     [rbp-38h],rax
     fb: mov     rax,[rbp-38h]
     ff: mov     [rbp-100h],rax
    106: mov     rax,[rbp-0A8h]
    10d: mov     [rbp-108h],rax
    114: mov     rax,[rbp-100h]
    11b: mov     [rbp-0F8h],rax
    122: mov     rax,[rbp-108h]
    129: mov     [rbp-0F0h],rax
    130: mov     rax,[rbp+40h]
    134: mov     [rbp-150h],rax
    13b: mov     rax,[rbp-0F8h]
    142: mov     [rbp-148h],rax
    149: mov     rax,[rbp-0F0h]
    150: mov     [rbp-140h],rax
    157: call    fn1
    15c: nop     [rcx-0D2h]
    163: mov     rax,[rbp-0E8h]
    16a: mov     [rbp-150h],rax
    171: movzx   eax,byte ptr [rbp-0D2h]
    178: mov     [rbp-148h],al
    17e: call    fn2
    183: nop     [rcx-0E0h]
    18a: lea     rax,[rbp-0C8h]
    191: mov     [rbp-0E8h],rax
    198: mov     rax,[rbp-0C0h]
    19f: mov     [rbp-40h],rax
    1a3: mov     rax,[rbp-40h]
    1a7: mov     [rbp-100h],rax
    1ae: mov     rax,[rbp-0A8h]
    1b5: mov     [rbp-108h],rax
    1bc: mov     rax,[rbp-100h]
    1c3: mov     [rbp-0F8h],rax
    1ca: mov     rax,[rbp-108h]
    1d1: mov     [rbp-0F0h],rax
    1d8: mov     rax,[rbp+40h]
    1dc: mov     [rbp-150h],rax
    1e3: mov     rax,[rbp-0F8h]
    1ea: mov     [rbp-148h],rax
    1f1: mov     rax,[rbp-0F0h]
    1f8: mov     [rbp-140h],rax
    1ff: call    fn3
    204: nop     [rcx-0D2h]
    20b: mov     rax,[rbp-0E8h]
    212: mov     [rbp-150h],rax
    219: movzx   eax,byte ptr [rbp-0D2h]
    220: mov     [rbp-148h],al
    226: call    fn4
    22b: nop     [rcx-0E0h]
    232: lea     rax,[rbp-0C8h]
    239: mov     [rbp-0E8h],rax
    240: mov     rax,[rbp-0C0h]
    247: mov     [rbp-48h],rax
    24b: mov     rax,[rbp-48h]
    24f: mov     [rbp-100h],rax
    256: mov     rax,[rbp-0A8h]
    25d: mov     [rbp-108h],rax
    264: mov     rax,[rbp-100h]
    26b: mov     [rbp-0F8h],rax
    272: mov     rax,[rbp-108h]
    279: mov     [rbp-0F0h],rax
    280: mov     rax,[rbp+40h]
    284: mov     [rbp-150h],rax
    28b: mov     rax,[rbp-0F8h]
    292: mov     [rbp-148h],rax
    299: mov     rax,[rbp-0F0h]
    2a0: mov     [rbp-140h],rax
    2a7: call    fn5
    2ac: nop     [rcx-0D2h]
    2b3: mov     rax,[rbp-0E8h]
    2ba: mov     [rbp-150h],rax
    2c1: movzx   eax,byte ptr [rbp-0D2h]
    2c8: mov     [rbp-148h],al
    2ce: call    fn6
    2d3: nop     [rcx-0E0h]
    2da: lea     rax,[rbp-0C8h]
    2e1: mov     [rbp-0E8h],rax
    2e8: mov     rax,[rbp-0C0h]
    2ef: mov     [rbp-50h],rax
    2f3: mov     rax,[rbp-50h]
    2f7: mov     [rbp-100h],rax
    2fe: mov     rax,[rbp-0A8h]
    305: mov     [rbp-108h],rax
    30c: mov     rax,[rbp-100h]
    313: mov     [rbp-0F8h],rax
    31a: mov     rax,[rbp-108h]
    321: mov     [rbp-0F0h],rax
    328: mov     rax,[rbp+40h]
    32c: mov     [rbp-150h],rax
    333: mov     rax,[rbp-0F8h]
    33a: mov     [rbp-148h],rax
    341: mov     rax,[rbp-0F0h]
    348: mov     [rbp-140h],rax
    34f: call    fn7
    354: nop     [rcx-0D2h]
    35b: mov     rax,[rbp-0E8h]
    362: mov     [rbp-150h],rax
    369: movzx   eax,byte ptr [rbp-0D2h]
    370: mov     [rbp-148h],al
    376: call    fn8
    37b: nop     [rcx-0E0h]
    382: jmp     0C0h
    387: mov     rax,[rbp+30h]
    38b: mov     [rbp-0D8h],rax
    392: mov     rax,[rbp-98h]
    399: imul    rcx,[rbp-0D8h],8
    3a1: add     rax,rcx
    3a4: mov     [rbp-0D0h],rax
    3ab: nop     [rax+rax]
    3b0: mov     rax,[rbp-0C0h]
    3b7: mov     [rbp-0E0h],rax
    3be: mov     rax,[rbp-0E0h]
    3c5: cmp     rax,[rbp-0D0h]
    3cc: jae     47Fh
    3d2: lea     rax,[rbp-0C8h]
    3d9: mov     [rbp-0E8h],rax
    3e0: mov     rax,[rbp-0C0h]
    3e7: mov     [rbp-58h],rax
    3eb: mov     rax,[rbp-58h]
    3ef: mov     [rbp-100h],rax
    3f6: mov     rax,[rbp-0A8h]
    3fd: mov     [rbp-108h],rax
    404: mov     rax,[rbp-100h]
    40b: mov     [rbp-0F8h],rax
    412: mov     rax,[rbp-108h]
    419: mov     [rbp-0F0h],rax
    420: mov     rax,[rbp+40h]
    424: mov     [rbp-150h],rax
    42b: mov     rax,[rbp-0F8h]
    432: mov     [rbp-148h],rax
    439: mov     rax,[rbp-0F0h]
    440: mov     [rbp-140h],rax
    447: call    fn9
    44c: nop     [rcx-0D2h]
    453: mov     rax,[rbp-0E8h]
    45a: mov     [rbp-150h],rax
    461: movzx   eax,byte ptr [rbp-0D2h]
    468: mov     [rbp-148h],al
    46e: call    fn10
    473: nop     [rcx-0E0h]
    47a: jmp     3B0h
    47f: mov     rax,[rbp+30h]
    483: cmp     rax,[rbp-90h]
    48a: jne     49Dh
    48c: call    fn11
    491: nop     [rcx-0CAh]
    498: jmp     66Dh
    49d: lea     rax,[rbp-0C8h]
    4a4: mov     [rbp-0D8h],rax
    4ab: mov     rax,[rbp-0D8h]
    4b2: mov     [rbp-150h],rax
    4b9: movzx   eax,byte ptr [rbp+38h]
    4bd: mov     [rbp-148h],al
    4c3: call    fn12
    4c8: nop     [rcx-10h]
    4cf: mov     rax,[rbp-90h]
    4d6: mov     [rbp+30h],rax
    4da: jmp     70h
    4df: nop
    4e0: mov     byte ptr [rbp-109h],1
    4e7: test    byte ptr [rbp-109h],0FFh
    4ee: je      702h
    4f4: jmp     68Fh
    4f9: nop     [rax]
    500: mov     rax,[rbp+10h]
    504: mov     [rbp-78h],rax
    508: mov     rax,[rbp+18h]
    50c: mov     [rbp-70h],rax
    510: mov     rax,[rbp-78h]
    514: mov     [rbp-0D0h],rax
    51b: mov     rax,[rbp-68h]
    51f: mov     [rbp-0D8h],rax
    526: mov     rax,[rbp-0B8h]
    52d: mov     [rbp-0E0h],rax
    534: mov     byte ptr [rbp-109h],1
    53b: test    byte ptr [rbp-109h],0FFh
    542: je      7A8h
    548: jmp     735h
    54d: nop     [rax]
    550: mov     rax,[rbp-20h]
    554: mov     [rbp-0F0h],rax
    55b: mov     rax,[rbp-18h]
    55f: mov     [rbp-0F8h],rax
    566: mov     rax,[rbp-0F0h]
    56d: cmp     rax,[rbp-0F8h]
    574: setb    [rbp-0E1h]
    57b: test    byte ptr [rbp-0E1h],0FFh
    582: je      823h
    588: jmp     806h
    58d: call    ryo_h_Abort
    592: ud2
    594: mov     rax,[rbp+10h]
    598: mov     [rbp-0A8h],rax
    59f: mov     rax,[rbp+18h]
    5a3: mov     [rbp-0A0h],rax
    5aa: mov     rax,[rbp-0A8h]
    5b1: mov     [rbp-98h],rax
    5b8: mov     rax,[rbp+20h]
    5bc: mov     [rbp-68h],rax
    5c0: mov     rax,[rbp+28h]
    5c4: mov     [rbp-60h],rax
    5c8: mov     rax,[rbp-68h]
    5cc: mov     [rbp-0A8h],rax
    5d3: mov     rax,[rbp-68h]
    5d7: mov     [rbp-0A0h],rax
    5de: mov     rax,[rbp-98h]
    5e5: imul    rcx,[rbp+30h],8
    5ea: add     rax,rcx
    5ed: mov     [rbp-0A8h],rax
    5f4: mov     rax,[rbp-0A0h]
    5fb: imul    rcx,[rbp-90h],8
    603: add     rax,rcx
    606: mov     [rbp-0D0h],rax
    60d: mov     rax,[rbp-0A0h]
    614: mov     [rbp-0C8h],rax
    61b: mov     rax,[rbp-98h]
    622: mov     [rbp-0C0h],rax
    629: mov     qword ptr [rbp-0B8h],0
    634: mov     rax,[rbp-0D0h]
    63b: mov     [rbp-0B0h],rax
    642: mov     qword ptr [rbp-10h],0
    64a: jmp     70h
    64f: mov     rax,[rbp-98h]
    656: imul    rcx,[rbp-0D8h],8
    65e: add     rax,rcx
    661: mov     [rbp-0D0h],rax
    668: jmp     0C0h
    66d: movzx   eax,byte ptr [rbp-0CAh]
    674: xor     al,1
    677: mov     [rbp-0C9h],al
    67d: test    byte ptr [rbp-0C9h],0FFh
    684: je      500h
    68a: jmp     4E0h
    68f: mov     rax,[rbp-0A8h]
    696: mov     [rbp-0D8h],rax
    69d: mov     rax,[rbp-10h]
    6a1: mov     [rbp-0E0h],rax
    6a8: mov     rax,[rbp-0D8h]
    6af: mov     [rbp-150h],rax
    6b6: mov     rax,[rbp-0E0h]
    6bd: mov     [rbp-148h],rax
    6c4: mov     qword ptr [rbp-140h],8
    6cf: mov     qword ptr [rbp-138h],4
    6da: mov     qword ptr [rbp-130h],1
    6e5: mov     edi,0FFFFFED8h
    6ea: lea     rsi,[k13]
    6f1: call    ryo_h_AddrAbs
    6f6: call    fn14
    6fb: nop     [rcx-68h]
    702: mov     qword ptr [rbp-110h],1
    70d: imul    rax,[rbp-110h],8
    715: mov     [rbp-118h],rax
    71c: mov     edi,0FFFFFFF0h
    721: mov     esi,0FFFFFF58h
    726: mov     edx,0FFFFFEE8h
    72b: call    ryo_h_Memcpy
    730: jmp     500h
    735: mov     rax,[rbp-68h]
    739: mov     [rbp-0E8h],rax
    740: mov     rax,[rbp-78h]
    744: mov     [rbp-0F0h],rax
    74b: mov     rax,[rbp-0E8h]
    752: mov     [rbp-150h],rax
    759: mov     rax,[rbp-0F0h]
    760: mov     [rbp-148h],rax
    767: mov     qword ptr [rbp-140h],8
    772: mov     qword ptr [rbp-138h],4
    77d: mov     rax,[rbp-0E0h]
    784: mov     [rbp-130h],rax
    78b: mov     edi,0FFFFFED8h
    790: lea     rsi,[k15]
    797: call    ryo_h_AddrAbs
    79c: call    fn16
    7a1: nop     [rcx-78h]
    7a8: imul    rax,[rbp-0E0h],8
    7b0: mov     [rbp-110h],rax
    7b7: mov     edi,0FFFFFF30h
    7bc: mov     esi,0FFFFFF28h
    7c1: mov     edx,0FFFFFEF0h
    7c6: call    ryo_h_Memcpy
    7cb: mov     rax,[rbp-0B8h]
    7d2: mov     [rbp-0E0h],rax
    7d9: mov     rax,[rbp-90h]
    7e0: sub     rax,[rbp-0E0h]
    7e7: mov     [rbp-0D8h],rax
    7ee: mov     qword ptr [rbp-20h],0
    7f6: mov     rax,[rbp-0D8h]
    7fd: mov     [rbp-18h],rax
    801: jmp     550h
    806: mov     rax,[rbp-20h]
    80a: mov     [rbp-0F0h],rax
    811: mov     byte ptr [rbp-109h],1
    818: test    byte ptr [rbp-109h],0FFh
    81f: je      875h
    821: jmp     83Fh
    823: mov     rax,[rbp-0B8h]
    82a: mov     [rbp-8],rax
    82e: mov     edi,0FFFFFFF8h
    833: mov     esi,8
    838: call    ryo_h_Ret
    83d: leave
    83e: ret
    83f: mov     rax,[rbp-0F0h]
    846: mov     [rbp-150h],rax
    84d: mov     qword ptr [rbp-148h],1
    858: mov     edi,0FFFFFEC0h
    85d: lea     rsi,[k17]
    864: call    ryo_h_AddrAbs
    869: call    fn18
    86e: nop     [rcx-88h]
    875: mov     rax,[rbp-0F0h]
    87c: add     rax,1
    880: mov     [rbp-0F8h],rax
    887: mov     rax,[rbp-0F8h]
    88e: mov     [rbp-20h],rax
    892: mov     rax,[rbp-0F0h]
    899: mov     [rbp-0D8h],rax
    8a0: mov     qword ptr [rbp-0E0h],1
    8ab: mov     rax,[rbp-0D8h]
    8b2: mov     [rbp-0E8h],rax
    8b9: mov     rax,[rbp-90h]
    8c0: sub     rax,1
    8c4: mov     [rbp-100h],rax
    8cb: mov     rax,[rbp-100h]
    8d2: sub     rax,[rbp-0E8h]
    8d9: mov     [rbp-0F8h],rax
    8e0: mov     rax,[rbp-0A0h]
    8e7: imul    rcx,[rbp-0F8h],8
    8ef: add     rax,rcx
    8f2: mov     [rbp-30h],rax
    8f6: mov     rax,[rbp-30h]
    8fa: mov     [rbp-0F0h],rax
    901: mov     rax,[rbp-0B8h]
    908: mov     [rbp-108h],rax
    90f: mov     rax,[rbp-108h]
    916: add     rax,[rbp-0E8h]
    91d: mov     [rbp-100h],rax
    924: mov     rax,[rbp-0D0h]
    92b: imul    rcx,[rbp-100h],8
    933: add     rax,rcx
    936: mov     [rbp-0F8h],rax
    93d: mov     byte ptr [rbp-109h],1
    944: test    byte ptr [rbp-109h],0FFh
    94b: je      9C0h
    94d: mov     rax,[rbp-30h]
    951: mov     [rbp-100h],rax
    958: mov     rax,[rbp-0F8h]
    95f: mov     [rbp-108h],rax
    966: mov     rax,[rbp-100h]
    96d: mov     [rbp-150h],rax
    974: mov     rax,[rbp-108h]
    97b: mov     [rbp-148h],rax
    982: mov     qword ptr [rbp-140h],8
    98d: mov     qword ptr [rbp-138h],4
    998: mov     qword ptr [rbp-130h],1
    9a3: mov     edi,0FFFFFED8h
    9a8: lea     rsi,[k19]
    9af: call    ryo_h_AddrAbs
    9b4: call    fn20
    9b9: nop     [rcx-88h]
    9c0: mov     qword ptr [rbp-110h],1
    9cb: imul    rax,[rbp-110h],8
    9d3: mov     [rbp-118h],rax
    9da: mov     edi,0FFFFFF08h
    9df: mov     esi,0FFFFFF10h
    9e4: mov     edx,0FFFFFEE8h
    9e9: call    ryo_h_Memcpy
    9ee: jmp     550h

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
     46: mov     rax,[rbp-60h]
     4a: mov     [rbp-50h],rax
     4e: mov     edi,0FFFFFFF0h
     53: mov     esi,0FFFFFFA8h
     58: call    ryo_h_MovW128
     5d: nop     [rax]
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
     ce: jne     22Dh
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
    162: jmp     2E4h
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
    1d9: mov     rax,[rbp-68h]
    1dd: mov     [rbp-8],rax
    1e1: mov     rax,[rbp-8]
    1e5: mov     [rbp-68h],rax
    1e9: mov     rax,[rbp-68h]
    1ed: mov     [rbp-50h],rax
    1f1: mov     qword ptr [rbp-58h],1
    1f9: mov     rax,[rbp-50h]
    1fd: mov     [rbp-60h],rax
    201: mov     rax,[rbp-60h]
    205: cmp     rax,[rbp-48h]
    209: jae     90h
    20f: jmp     0B0h
    214: nop     [rax+rax]
    21d: nop     [rax]
    220: mov     qword ptr [rbp-20h],0
    228: jmp     140h
    22d: mov     rax,[rbp-60h]
    231: cmp     rax,[rbp-48h]
    235: jb      29Dh
    237: mov     rax,[rbp-60h]
    23b: mov     [rbp-0D0h],rax
    242: mov     rax,[rbp-48h]
    246: mov     [rbp-0C8h],rax
    24d: mov     edi,0FFFFFF40h
    252: lea     rsi,[k7]
    259: call    ryo_h_AddrAbs
    25e: lea     rdi,[sym8]
    265: lea     rsi,[site9]
    26c: mov     edx,0FFFFFF58h
    271: call    ryo_h_CallExt
    276: test    rax,rax
    279: je      286h
    27b: call    rax
    27d: nop     [rcx-0A0h]
    284: jmp     296h
    286: mov     rdi,rbp
    289: lea     rsi,[ro+4]
    290: call    qword ptr [sym10]
    296: call    ryo_h_Unreachable
    29b: ud2
    29d: mov     edi,0FFFFFF30h
    2a2: mov     esi,10h
    2a7: call    ryo_h_MovW128
    2ac: mov     qword ptr [rbp-0C0h],0
    2b7: mov     rax,[rbp-60h]
    2bb: mov     [rbp-0B8h],rax
    2c2: mov     edi,0FFFFFF50h
    2c7: lea     rsi,[k11]
    2ce: call    ryo_h_AddrAbs
    2d3: call    fn12
    2d8: nop     [rcx-40h]
    2df: jmp     220h
    2e4: cmp     qword ptr [rbp-28h],0
    2e9: jb      401h
    2ef: jmp     403h
    2f4: nop     [rax+rax]
    2fd: nop     [rax]
    300: mov     rax,[rbp+10h]
    304: mov     [rbp-98h],rax
    30b: mov     rax,[rbp+18h]
    30f: mov     [rbp-90h],rax
    316: mov     rax,[rbp-98h]
    31d: mov     [rbp-0A0h],rax
    324: mov     rax,[rbp-0A0h]
    32b: mov     [rbp-88h],rax
    332: mov     rax,[rbp-28h]
    336: mov     [rbp-80h],rax
    33a: mov     rax,[rbp-88h]
    341: mov     [rbp-70h],rax
    345: mov     rax,[rbp-80h]
    349: mov     [rbp-68h],rax
    34d: mov     edi,0FFFFFF30h
    352: mov     esi,0FFFFFF90h
    357: call    ryo_h_MovW128
    35c: mov     rax,[rbp-20h]
    360: mov     [rbp-0C0h],rax
    367: mov     rax,[rbp+20h]
    36b: mov     [rbp-0B8h],rax
    372: call    fn13
    377: nop     [rcx-20h]
    37e: jmp     170h
    383: nop     [rax+rax]
    38c: nop     [rax]
    390: mov     qword ptr [rbp-0D0h],0
    39b: mov     rax,[rbp-28h]
    39f: mov     [rbp-0C8h],rax
    3a6: mov     rax,[rbp-48h]
    3aa: mov     [rbp-0C0h],rax
    3b1: mov     edi,0FFFFFF48h
    3b6: lea     rsi,[k14]
    3bd: call    ryo_h_AddrAbs
    3c2: lea     rdi,[sym15]
    3c9: lea     rsi,[site16]
    3d0: mov     edx,0FFFFFF58h
    3d5: call    ryo_h_CallExt
    3da: test    rax,rax
    3dd: je      3EAh
    3df: call    rax
    3e1: nop     [rcx-40h]
    3e8: jmp     3FAh
    3ea: mov     rdi,rbp
    3ed: lea     rsi,[ro+20]
    3f4: call    qword ptr [sym17]
    3fa: call    ryo_h_Unreachable
    3ff: ud2
    401: jmp     390h
    403: mov     rax,[rbp-48h]
    407: cmp     rax,[rbp-28h]
    40b: jae     300h
    411: jmp     390h

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
     5d: mov     rax,[rbp-20h]
     61: add     rax,1
     65: mov     [rbp-10h],rax
     69: mov     rax,[rbp-10h]
     6d: mov     [rbp-28h],rax
     71: mov     rax,[rbp-28h]
     75: cmp     rax,[rbp-8]
     79: jb      80h
     7b: jmp     201h
     80: mov     rax,[rbp-10h]
     84: mov     [rbp-30h],rax
     88: mov     rax,[rbp-30h]
     8c: add     rax,1
     90: mov     [rbp-28h],rax
     94: mov     rax,[rbp-28h]
     98: cmp     rax,[rbp-8]
     9c: jae     12Dh
     a2: mov     rax,[rbp-10h]
     a6: mov     [rbp-50h],rax
     aa: mov     rax,[rbp-18h]
     ae: imul    rcx,[rbp-50h],4
     b3: add     rax,rcx
     b6: mov     [rbp-48h],rax
     ba: mov     rax,[rbp-48h]
     be: mov     [rbp-40h],rax
     c2: mov     rax,[rbp-10h]
     c6: mov     [rbp-68h],rax
     ca: mov     rax,[rbp-68h]
     ce: add     rax,1
     d2: mov     [rbp-60h],rax
     d6: mov     rax,[rbp-18h]
     da: imul    rcx,[rbp-60h],4
     df: add     rax,rcx
     e2: mov     [rbp-58h],rax
     e6: mov     rax,[rbp-58h]
     ea: mov     [rbp-50h],rax
     ee: mov     rax,[rbp-40h]
     f2: mov     [rbp-38h],rax
     f6: mov     rax,[rbp-50h]
     fa: mov     [rbp-30h],rax
     fe: mov     rax,[rbp+28h]
    102: mov     [rbp-0A0h],rax
    109: mov     rax,[rbp-38h]
    10d: mov     [rbp-98h],rax
    114: mov     rax,[rbp-30h]
    118: mov     [rbp-90h],rax
    11f: call    fn0
    124: nop     [rcx-1Ah]
    12b: jmp     12Fh
    12d: jmp     14Ah
    12f: mov     edi,0FFFFFFD8h
    134: mov     esi,0FFFFFFE6h
    139: call    ryo_h_ZextW8W64
    13e: mov     rax,[rbp-10h]
    142: add     rax,[rbp-28h]
    146: mov     [rbp-10h],rax
    14a: mov     rax,[rbp+20h]
    14e: mov     [rbp-48h],rax
    152: mov     rax,[rbp-18h]
    156: imul    rcx,[rbp-48h],4
    15b: add     rax,rcx
    15e: mov     [rbp-40h],rax
    162: mov     rax,[rbp-40h]
    166: mov     [rbp-38h],rax
    16a: mov     rax,[rbp-10h]
    16e: mov     [rbp-58h],rax
    172: mov     rax,[rbp-18h]
    176: imul    rcx,[rbp-58h],4
    17b: add     rax,rcx
    17e: mov     [rbp-50h],rax
    182: mov     rax,[rbp-50h]
    186: mov     [rbp-48h],rax
    18a: mov     rax,[rbp-38h]
    18e: mov     [rbp-30h],rax
    192: mov     rax,[rbp-48h]
    196: mov     [rbp-28h],rax
    19a: mov     rax,[rbp+28h]
    19e: mov     [rbp-0A0h],rax
    1a5: mov     rax,[rbp-30h]
    1a9: mov     [rbp-98h],rax
    1b0: mov     rax,[rbp-28h]
    1b4: mov     [rbp-90h],rax
    1bb: call    fn1
    1c0: nop     [rcx-19h]
    1c7: test    byte ptr [rbp-19h],0FFh
    1cb: je      201h
    1cd: mov     rax,[rbp-18h]
    1d1: imul    rcx,[rbp+20h],4
    1d6: add     rax,rcx
    1d9: mov     [rbp-20h],rax
    1dd: mov     rax,[rbp-10h]
    1e1: mov     [rbp-30h],rax
    1e5: mov     rax,[rbp-18h]
    1e9: imul    rcx,[rbp-30h],4
    1ee: add     rax,rcx
    1f1: mov     [rbp-28h],rax
    1f5: mov     byte ptr [rbp-69h],1
    1f9: test    byte ptr [rbp-69h],0FFh
    1fd: je      26Dh
    1ff: jmp     20Ch
    201: xor     edi,edi
    203: xor     esi,esi
    205: call    ryo_h_Ret
    20a: leave
    20b: ret
    20c: mov     rax,[rbp-20h]
    210: mov     [rbp-30h],rax
    214: mov     rax,[rbp-28h]
    218: mov     [rbp-38h],rax
    21c: mov     rax,[rbp-30h]
    220: mov     [rbp-0A0h],rax
    227: mov     rax,[rbp-38h]
    22b: mov     [rbp-98h],rax
    232: mov     qword ptr [rbp-90h],4
    23d: mov     qword ptr [rbp-88h],4
    248: mov     qword ptr [rbp-80h],1
    250: mov     edi,0FFFFFF88h
    255: lea     rsi,[k2]
    25c: call    ryo_h_AddrAbs
    261: call    fn3
    266: nop     [rcx-10h]
    26d: mov     rax,[rbp-20h]
    271: mov     [rbp-38h],rax
    275: mov     qword ptr [rbp-30h],1
    27d: mov     edi,0FFFFFFB0h
    282: mov     esi,0FFFFFFC8h
    287: call    ryo_h_MovW128
    28c: imul    rax,[rbp-48h],4
    291: mov     [rbp-40h],rax
    295: jmp     2EBh
    297: mov     rax,[rbp-48h]
    29b: mov     [rbp-50h],rax
    29f: mov     rax,[rbp-20h]
    2a3: mov     [rbp-60h],rax
    2a7: mov     rax,[rbp-28h]
    2ab: mov     [rbp-68h],rax
    2af: mov     rax,[rbp-60h]
    2b3: mov     [rbp-0A0h],rax
    2ba: mov     rax,[rbp-68h]
    2be: mov     [rbp-98h],rax
    2c5: mov     rax,[rbp-50h]
    2c9: mov     [rbp-90h],rax
    2d0: call    fn4
    2d5: nop     [rcx-10h]
    2dc: jmp     2DEh
    2de: mov     rax,[rbp-10h]
    2e2: mov     [rbp+20h],rax
    2e6: jmp     40h
    2eb: mov     rax,[rbp-40h]
    2ef: mov     [rbp-48h],rax
    2f3: mov     edi,0FFFFFF94h
    2f8: mov     esi,0FFFFFFB8h
    2fd: xor     edx,edx
    2ff: xor     ecx,ecx
    301: xor     r8d,r8d
    304: mov     r9d,1
    30a: call    ryo_h_DiscrNicheW64
    30f: mov     edi,0FFFFFFA8h
    314: mov     esi,0FFFFFF94h
    319: call    ryo_h_ZextW32W64
    31e: mov     edi,0FFFFFFA8h
    323: xor     esi,esi
    325: mov     edx,2
    32a: call    ryo_h_SwitchDenseW64
    32f: lea     rcx,[340h]
    336: movsxd  rax,[rcx+rax*4]
    33a: add     rax,rcx
    33d: jmp     rax
    33f: int3
    340: .long   2deh
    344: .long   297h
    348: .long   34ch
    34c: call    ryo_h_Unreachable
    351: ud2

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
     61: mov     rax,[rbp-18h]
     65: cmp     rax,[rbp-10h]
     69: jne     8Eh
     6b: test    byte ptr [rbp-5],0FFh
     6f: je      8Ch
     71: mov     edi,0FFFFFF80h
     76: mov     esi,10h
     7b: call    ryo_h_MovW128
     80: call    fn1
     85: nop     [rcx]
     8c: jmp     100h
     8e: mov     rax,[rbp-10h]
     92: or      rax,1
     96: mov     [rbp-28h],rax
     9a: mov     rax,[rbp-28h]
     9e: mov     [rbp-30h],rax
     a2: mov     edi,0FFFFFFB4h
     a7: mov     esi,0FFFFFFD0h
     ac: xor     edx,edx
     ae: xor     ecx,ecx
     b0: xor     r8d,r8d
     b3: mov     r9d,1
     b9: call    ryo_h_DiscrNicheW64
     be: mov     edi,0FFFFFFC8h
     c3: mov     esi,0FFFFFFB4h
     c8: call    ryo_h_ZextW32W64
     cd: mov     edi,0FFFFFFC8h
     d2: xor     esi,esi
     d4: mov     edx,2
     d9: call    ryo_h_SwitchDenseW64
     de: lea     rcx,[0F0h]
     e5: movsxd  rax,[rcx+rax*4]
     e9: add     rax,rcx
     ec: jmp     rax
     ee: int3
     ef: int3
     f0: .long   112h
     f4: .long   162h
     f8: .long   10bh
     fc: nop     [rax]
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
    16a: mov     rax,[rbp-40h]
    16e: mov     [rbp-48h],rax
    172: mov     edi,0FFFFFFB4h
    177: mov     esi,0FFFFFFB8h
    17c: call    ryo_h_CtlzW64
    181: mov     eax,[rbp-4Ch]
    184: mov     [rbp-20h],eax
    187: mov     dword ptr [rbp-4Ch],3Fh
    18e: mov     eax,[rbp-4Ch]
    191: sub     eax,[rbp-20h]
    194: mov     [rbp-4],eax
    197: mov     dword ptr [rbp-4Ch],2
    19e: mov     eax,[rbp-4Ch]
    1a1: imul    eax,[rbp-4]
    1a5: mov     [rbp-1Ch],eax
    1a8: mov     edi,0FFFFFF80h
    1ad: mov     esi,10h
    1b2: call    ryo_h_MovW128
    1b7: mov     qword ptr [rbp-70h],0
    1bf: mov     eax,[rbp-1Ch]
    1c2: mov     [rbp-68h],eax
    1c5: mov     rax,[rbp+20h]
    1c9: mov     [rbp-60h],rax
    1cd: call    fn6
    1d2: nop     [rcx]
    1d9: jmp     100h

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     qword ptr [rbp-20h],0
     18: jne     27h
     1a: mov     qword ptr [rbp-8],0
     22: jmp     20Ch
     27: mov     rax,[rbp+20h]
     2b: cmp     rax,[rbp-20h]
     2f: jb      38h
     31: call    ryo_h_Abort
     36: ud2
     38: mov     edi,0FFFFFF70h
     3d: mov     esi,10h
     42: call    ryo_h_MovW128
     47: mov     qword ptr [rbp-80h],0
     4f: mov     rax,[rbp+20h]
     53: mov     [rbp-78h],rax
     57: mov     edi,0FFFFFF90h
     5c: lea     rsi,[k0]
     63: call    ryo_h_AddrAbs
     68: call    fn1
     6d: nop     [rcx-8]
     74: mov     edi,0FFFFFF70h
     79: mov     esi,10h
     7e: call    ryo_h_MovW128
     83: mov     qword ptr [rbp-80h],1
     8b: mov     edi,0FFFFFF88h
     90: lea     rsi,[k2]
     97: call    ryo_h_AddrAbs
     9c: call    fn3
     a1: nop     [rcx-60h]
     a8: mov     edi,0FFFFFFD0h
     ad: mov     esi,0FFFFFFA0h
     b2: call    ryo_h_MovW128
     b7: mov     edi,0FFFFFFC0h
     bc: mov     esi,0FFFFFFB0h
     c1: call    ryo_h_MovW128
     c6: mov     rax,[rbp-28h]
     ca: mov     [rbp-10h],rax
     ce: mov     qword ptr [rbp-68h],0
     d6: mov     rax,[rbp-68h]
     da: cmp     rax,[rbp-10h]
     de: setb    [rbp-11h]
     e2: test    byte ptr [rbp-11h],0FFh
     e6: jne     14Eh
     e8: mov     qword ptr [rbp-90h],0
     f3: mov     rax,[rbp-10h]
     f7: mov     [rbp-88h],rax
     fe: mov     edi,0FFFFFF80h
    103: lea     rsi,[k4]
    10a: call    ryo_h_AddrAbs
    10f: lea     rdi,[sym5]
    116: lea     rsi,[site6]
    11d: mov     edx,0FFFFFF98h
    122: call    ryo_h_CallExt
    127: test    rax,rax
    12a: je      137h
    12c: call    rax
    12e: nop     [rcx-60h]
    135: jmp     147h
    137: mov     rdi,rbp
    13a: lea     rsi,[ro+4]
    141: call    qword ptr [sym7]
    147: call    ryo_h_Unreachable
    14c: ud2
    14e: mov     rax,[rbp-30h]
    152: mov     [rbp-48h],rax
    156: mov     rax,[rbp-48h]
    15a: mov     [rbp-50h],rax
    15e: mov     edi,0FFFFFF98h
    163: lea     rsi,[sym8]
    16a: call    ryo_h_AddrSym
    16f: mov     edi,0FFFFFF70h
    174: mov     esi,0FFFFFFC0h
    179: call    ryo_h_MovW128
    17e: mov     rax,[rbp-50h]
    182: mov     [rbp-80h],rax
    186: mov     rax,[rbp+28h]
    18a: mov     [rbp-78h],rax
    18e: mov     edi,0FFFFFF98h
    193: lea     rsi,[site9]
    19a: call    ryo_h_CallInd
    19f: test    rax,rax
    1a2: je      1AFh
    1a4: call    rax
    1a6: nop     [rcx-8]
    1ad: jmp     1BFh
    1af: mov     rdi,rbp
    1b2: lea     rsi,[ro+20]
    1b9: call    qword ptr [sym10]
    1bf: mov     rax,[rbp-8]
    1c3: cmp     rax,[rbp-20h]
    1c7: jb      1D0h
    1c9: call    ryo_h_Abort
    1ce: ud2
    1d0: mov     edi,0FFFFFF70h
    1d5: mov     esi,10h
    1da: call    ryo_h_MovW128
    1df: mov     qword ptr [rbp-80h],0
    1e7: mov     rax,[rbp-8]
    1eb: mov     [rbp-78h],rax
    1ef: mov     edi,0FFFFFF90h
    1f4: lea     rsi,[k11]
    1fb: call    ryo_h_AddrAbs
    200: call    fn12
    205: nop     [rcx-11h]
    20c: mov     edi,0FFFFFFF8h
    211: mov     esi,8
    216: call    ryo_h_Ret
    21b: leave
    21c: ret

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     qword ptr [rbp-20h],0
     18: jne     27h
     1a: mov     qword ptr [rbp-8],0
     22: jmp     20Ch
     27: mov     rax,[rbp+20h]
     2b: cmp     rax,[rbp-20h]
     2f: jb      38h
     31: call    ryo_h_Abort
     36: ud2
     38: mov     edi,0FFFFFF70h
     3d: mov     esi,10h
     42: call    ryo_h_MovW128
     47: mov     qword ptr [rbp-80h],0
     4f: mov     rax,[rbp+20h]
     53: mov     [rbp-78h],rax
     57: mov     edi,0FFFFFF90h
     5c: lea     rsi,[k0]
     63: call    ryo_h_AddrAbs
     68: call    fn1
     6d: nop     [rcx-8]
     74: mov     edi,0FFFFFF70h
     79: mov     esi,10h
     7e: call    ryo_h_MovW128
     83: mov     qword ptr [rbp-80h],1
     8b: mov     edi,0FFFFFF88h
     90: lea     rsi,[k2]
     97: call    ryo_h_AddrAbs
     9c: call    fn3
     a1: nop     [rcx-60h]
     a8: mov     edi,0FFFFFFD0h
     ad: mov     esi,0FFFFFFA0h
     b2: call    ryo_h_MovW128
     b7: mov     edi,0FFFFFFC0h
     bc: mov     esi,0FFFFFFB0h
     c1: call    ryo_h_MovW128
     c6: mov     rax,[rbp-28h]
     ca: mov     [rbp-10h],rax
     ce: mov     qword ptr [rbp-68h],0
     d6: mov     rax,[rbp-68h]
     da: cmp     rax,[rbp-10h]
     de: setb    [rbp-11h]
     e2: test    byte ptr [rbp-11h],0FFh
     e6: jne     14Eh
     e8: mov     qword ptr [rbp-90h],0
     f3: mov     rax,[rbp-10h]
     f7: mov     [rbp-88h],rax
     fe: mov     edi,0FFFFFF80h
    103: lea     rsi,[k4]
    10a: call    ryo_h_AddrAbs
    10f: lea     rdi,[sym5]
    116: lea     rsi,[site6]
    11d: mov     edx,0FFFFFF98h
    122: call    ryo_h_CallExt
    127: test    rax,rax
    12a: je      137h
    12c: call    rax
    12e: nop     [rcx-60h]
    135: jmp     147h
    137: mov     rdi,rbp
    13a: lea     rsi,[ro+4]
    141: call    qword ptr [sym7]
    147: call    ryo_h_Unreachable
    14c: ud2
    14e: mov     rax,[rbp-30h]
    152: mov     [rbp-48h],rax
    156: mov     rax,[rbp-48h]
    15a: mov     [rbp-50h],rax
    15e: mov     edi,0FFFFFF98h
    163: lea     rsi,[sym8]
    16a: call    ryo_h_AddrSym
    16f: mov     edi,0FFFFFF70h
    174: mov     esi,0FFFFFFC0h
    179: call    ryo_h_MovW128
    17e: mov     rax,[rbp-50h]
    182: mov     [rbp-80h],rax
    186: mov     rax,[rbp+28h]
    18a: mov     [rbp-78h],rax
    18e: mov     edi,0FFFFFF98h
    193: lea     rsi,[site9]
    19a: call    ryo_h_CallInd
    19f: test    rax,rax
    1a2: je      1AFh
    1a4: call    rax
    1a6: nop     [rcx-8]
    1ad: jmp     1BFh
    1af: mov     rdi,rbp
    1b2: lea     rsi,[ro+20]
    1b9: call    qword ptr [sym10]
    1bf: mov     rax,[rbp-8]
    1c3: cmp     rax,[rbp-20h]
    1c7: jb      1D0h
    1c9: call    ryo_h_Abort
    1ce: ud2
    1d0: mov     edi,0FFFFFF70h
    1d5: mov     esi,10h
    1da: call    ryo_h_MovW128
    1df: mov     qword ptr [rbp-80h],0
    1e7: mov     rax,[rbp-8]
    1eb: mov     [rbp-78h],rax
    1ef: mov     edi,0FFFFFF90h
    1f4: lea     rsi,[k11]
    1fb: call    ryo_h_AddrAbs
    200: call    fn12
    205: nop     [rcx-11h]
    20c: mov     edi,0FFFFFFF8h
    211: mov     esi,8
    216: call    ryo_h_Ret
    21b: leave
    21c: ret

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
     3a: jmp     31Dh
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
     67: mov     rax,[rbp-60h]
     6b: mov     eax,[rax]
     6d: mov     [rbp-58h],eax
     70: mov     eax,[rbp-58h]
     73: mov     [rbp-5Ch],eax
     76: mov     eax,[rbp-5Ch]
     79: mov     [rbp-54h],eax
     7c: mov     qword ptr [rbp-0A8h],1
     87: mov     rax,[rbp-38h]
     8b: imul    rcx,[rbp-0A8h],4
     93: add     rax,rcx
     96: mov     [rbp-80h],rax
     9a: lea     rax,[rbp-54h]
     9e: mov     [rbp-98h],rax
     a5: mov     rax,[rbp-38h]
     a9: mov     [rbp-90h],rax
     b0: mov     rax,[rbp-98h]
     b7: mov     [rbp-88h],rax
     be: mov     rax,[rbp-80h]
     c2: mov     [rbp-68h],rax
     c6: mov     qword ptr [rbp-60h],0
     ce: mov     edi,0FFFFFF88h
     d3: mov     esi,0FFFFFF70h
     d8: call    ryo_h_MovW128
     dd: mov     qword ptr [rbp-0A8h],2
     e8: mov     rax,[rbp-0A8h]
     ef: sub     rax,1
     f3: mov     [rbp-90h],rax
     fa: mov     rax,[rbp-30h]
     fe: sub     rax,[rbp-90h]
    105: mov     [rbp-88h],rax
    10c: mov     rax,[rbp-38h]
    110: imul    rcx,[rbp-88h],4
    118: add     rax,rcx
    11b: mov     [rbp-80h],rax
    11f: nop
    120: mov     rax,[rbp-68h]
    124: mov     [rbp-88h],rax
    12b: mov     rax,[rbp-88h]
    132: cmp     rax,[rbp-80h]
    136: jae     248h
    13c: mov     qword ptr [rbp-0A8h],2
    147: cmp     qword ptr [rbp-0A8h],2
    14f: sete    [rbp-56h]
    153: test    byte ptr [rbp-56h],0FFh
    157: je      1F7h
    15d: lea     rax,[rbp-50h]
    161: mov     [rbp-88h],rax
    168: lea     rax,[rbp-78h]
    16c: mov     [rbp-98h],rax
    173: mov     rax,[rbp-98h]
    17a: mov     [rbp-90h],rax
    181: mov     rax,[rbp-88h]
    188: mov     [rbp-0C0h],rax
    18f: mov     rax,[rbp-90h]
    196: mov     [rbp-0B8h],rax
    19d: call    fn0
    1a2: nop     [rcx-10h]
    1a9: lea     rax,[rbp-50h]
    1ad: mov     [rbp-88h],rax
    1b4: lea     rax,[rbp-78h]
    1b8: mov     [rbp-98h],rax
    1bf: mov     rax,[rbp-98h]
    1c6: mov     [rbp-90h],rax
    1cd: mov     rax,[rbp-88h]
    1d4: mov     [rbp-0C0h],rax
    1db: mov     rax,[rbp-90h]
    1e2: mov     [rbp-0B8h],rax
    1e9: call    fn1
    1ee: nop     [rcx-10h]
    1f5: jmp     243h
    1f7: lea     rax,[rbp-50h]
    1fb: mov     [rbp-88h],rax
    202: lea     rax,[rbp-78h]
    206: mov     [rbp-98h],rax
    20d: mov     rax,[rbp-98h]
    214: mov     [rbp-90h],rax
    21b: mov     rax,[rbp-88h]
    222: mov     [rbp-0C0h],rax
    229: mov     rax,[rbp-90h]
    230: mov     [rbp-0B8h],rax
    237: call    fn2
    23c: nop     [rcx-10h]
    243: jmp     120h
    248: mov     rax,[rbp-38h]
    24c: imul    rcx,[rbp-30h],4
    251: add     rax,rcx
    254: mov     [rbp-88h],rax
    25b: nop     [rax+rax]
    260: mov     rax,[rbp-68h]
    264: mov     [rbp-90h],rax
    26b: mov     rax,[rbp-90h]
    272: cmp     rax,[rbp-88h]
    279: sete    [rbp-55h]
    27d: test    byte ptr [rbp-55h],0FFh
    281: je      290h
    283: mov     rax,[rbp-70h]
    287: mov     [rbp-90h],rax
    28e: jmp     29Bh
    290: mov     rax,[rbp-68h]
    294: mov     [rbp-90h],rax
    29b: mov     rax,[rbp-90h]
    2a2: mov     [rbp-68h],rax
    2a6: lea     rax,[rbp-50h]
    2aa: mov     [rbp-90h],rax
    2b1: lea     rax,[rbp-78h]
    2b5: mov     [rbp-0A0h],rax
    2bc: mov     rax,[rbp-0A0h]
    2c3: mov     [rbp-98h],rax
    2ca: mov     rax,[rbp-90h]
    2d1: mov     [rbp-0C0h],rax
    2d8: mov     rax,[rbp-98h]
    2df: mov     [rbp-0B8h],rax
    2e6: call    fn3
    2eb: nop     [rcx-10h]
    2f2: test    byte ptr [rbp-55h],0FFh
    2f6: je      318h
    2f8: mov     rax,[rbp-78h]
    2fc: mov     [rbp-90h],rax
    303: mov     rax,[rbp-70h]
    307: mov     [rbp-98h],rax
    30e: mov     rax,[rbp-60h]
    312: mov     [rbp-8],rax
    316: jmp     31Dh
    318: jmp     260h
    31d: mov     edi,0FFFFFFF8h
    322: mov     esi,8
    327: call    ryo_h_Ret
    32c: leave
    32d: ret
    32e: xchg    ax,ax
    330: mov     edi,0FFFFFFD8h
    335: call    ryo_h_Resume
    33a: ud2
    33c: nop     [rax]
    340: lea     rax,[rbp-78h]
    344: mov     [rbp-0A8h],rax
    34b: mov     rax,[rbp-0A8h]
    352: mov     [rbp-0C0h],rax
    359: call    fn4
    35e: nop     [rcx-0A8h]
    365: jmp     330h
    367: nop     [rax+rax]
    370: lea     rdi,[sym5]
    377: lea     rsi,[site6]
    37e: mov     edx,0FFFFFF58h
    383: call    ryo_h_CallExt
    388: test    rax,rax
    38b: je      398h
    38d: call    rax
    38f: nop     [rcx-0A0h]
    396: jmp     3A8h
    398: mov     rdi,rbp
    39b: lea     rsi,[ro+4]
    3a2: call    qword ptr [sym7]
    3a8: call    ryo_h_Unreachable
    3ad: ud2
    3af: mov     rdi,rax
    3b2: mov     esi,0FFFFFFD8h
    3b7: call    ryo_h_Lpad
    3bc: jmp     340h
    3be: mov     rdi,rax
    3c1: mov     esi,0FFFFFFD8h
    3c6: call    ryo_h_Lpad
    3cb: jmp     370h

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
     22: mov     rax,[rbp-18h]
     26: mov     [rbp-48h],rax
     2a: mov     rax,[rbp+10h]
     2e: mov     rax,[rax+8]
     32: mov     [rbp-20h],rax
     36: mov     rax,[rbp-48h]
     3a: mov     [rbp-40h],rax
     3e: mov     rax,[rbp-20h]
     42: mov     [rbp-38h],rax
     46: mov     rax,[rbp-10h]
     4a: mov     [rbp-0A0h],rax
     51: mov     rax,[rbp-40h]
     55: mov     [rbp-98h],rax
     5c: mov     rax,[rbp-38h]
     60: mov     [rbp-90h],rax
     67: call    fn0
     6c: nop     [rcx-29h]
     73: mov     rax,[rbp+10h]
     77: mov     rax,[rax+10h]
     7b: mov     [rbp-28h],rax
     7f: mov     rax,[rbp-28h]
     83: mov     rax,[rax]
     86: mov     [rbp-40h],rax
     8a: mov     rax,[rbp+18h]
     8e: mov     rax,[rax+18h]
     92: mov     [rbp-48h],rax
     96: mov     rax,[rbp-40h]
     9a: imul    rcx,[rbp-48h],4
     9f: add     rax,rcx
     a2: mov     [rbp-38h],rax
     a6: mov     rax,[rbp-38h]
     aa: mov     [rbp-40h],rax
     ae: mov     rax,[rbp+18h]
     b2: mov     rax,[rax]
     b5: mov     [rbp-48h],rax
     b9: mov     byte ptr [rbp-59h],1
     bd: test    byte ptr [rbp-59h],0FFh
     c1: je      163h
     c7: jmp     0F7h
     c9: nop     [rax]
     d0: mov     rax,[rbp+18h]
     d4: mov     rax,[rax+10h]
     d8: mov     [rbp-8],rax
     dc: mov     rax,[rbp-8]
     e0: mov     [rbp-40h],rax
     e4: mov     byte ptr [rbp-59h],1
     e8: test    byte ptr [rbp-59h],0FFh
     ec: je      1EEh
     f2: jmp     18Dh
     f7: mov     rax,[rbp-38h]
     fb: mov     [rbp-50h],rax
     ff: mov     rax,[rbp-48h]
    103: mov     [rbp-58h],rax
    107: mov     byte ptr [rbp-59h],0
    10b: test    byte ptr [rbp-59h],0FFh
    10f: je      117h
    111: mov     byte ptr [rbp-2Ah],1
    115: jmp     11Bh
    117: mov     byte ptr [rbp-2Ah],0
    11b: mov     rax,[rbp-50h]
    11f: mov     [rbp-0A0h],rax
    126: mov     rax,[rbp-58h]
    12a: mov     [rbp-98h],rax
    131: mov     qword ptr [rbp-90h],4
    13c: movzx   eax,byte ptr [rbp-2Ah]
    140: mov     [rbp-88h],al
    146: mov     edi,0FFFFFF80h
    14b: lea     rsi,[k1]
    152: call    ryo_h_AddrAbs
    157: call    fn2
    15c: nop     [rcx-28h]
    163: mov     qword ptr [rbp-60h],1
    16b: imul    rax,[rbp-60h],4
    170: mov     [rbp-68h],rax
    174: mov     edi,0FFFFFFB8h
    179: mov     esi,0FFFFFFC0h
    17e: mov     edx,0FFFFFF98h
    183: call    ryo_h_Memmove
    188: jmp     0D0h
    18d: mov     rax,[rbp-8]
    191: mov     [rbp-48h],rax
    195: mov     rax,[rbp-38h]
    199: mov     [rbp-50h],rax
    19d: mov     rax,[rbp-48h]
    1a1: mov     [rbp-0A0h],rax
    1a8: mov     rax,[rbp-50h]
    1ac: mov     [rbp-98h],rax
    1b3: mov     qword ptr [rbp-90h],4
    1be: mov     qword ptr [rbp-88h],4
    1c9: mov     qword ptr [rbp-80h],1
    1d1: mov     edi,0FFFFFF88h
    1d6: lea     rsi,[k3]
    1dd: call    ryo_h_AddrAbs
    1e2: call    fn4
    1e7: nop     [rcx-28h]
    1ee: mov     qword ptr [rbp-60h],1
    1f6: imul    rax,[rbp-60h],4
    1fb: mov     [rbp-68h],rax
    1ff: mov     edi,0FFFFFFC8h
    204: mov     esi,0FFFFFFC0h
    209: mov     edx,0FFFFFF98h
    20e: call    ryo_h_Memcpy
    213: mov     rax,[rbp+18h]
    217: mov     rax,[rax+10h]
    21b: mov     [rbp-40h],rax
    21f: mov     rax,[rbp+18h]
    223: mov     rcx,[rbp-40h]
    227: mov     [rax],rcx
    22a: mov     edi,0FFFFFFC0h
    22f: mov     esi,0FFFFFFD7h
    234: call    ryo_h_ZextW8W64
    239: mov     rax,[rbp+18h]
    23d: mov     rax,[rax+18h]
    241: mov     [rbp-60h],rax
    245: mov     rax,[rbp-60h]
    249: add     rax,[rbp-40h]
    24d: mov     [rbp-70h],rax
    251: mov     rax,[rbp+18h]
    255: mov     rcx,[rbp-70h]
    259: mov     [rax+18h],rcx
    25d: mov     rax,[rbp+18h]
    261: mov     rax,[rax+10h]
    265: mov     [rbp-48h],rax
    269: mov     qword ptr [rbp-60h],1
    271: mov     rax,[rbp-48h]
    275: imul    rcx,[rbp-60h],4
    27a: add     rax,rcx
    27d: mov     [rbp-40h],rax
    281: mov     rax,[rbp+18h]
    285: mov     rcx,[rbp-40h]
    289: mov     [rax+10h],rcx
    28d: xor     edi,edi
    28f: xor     esi,esi
    291: call    ryo_h_Ret
    296: leave
    297: ret

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
     3a: jmp     31Dh
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
     67: mov     rax,[rbp-60h]
     6b: mov     eax,[rax]
     6d: mov     [rbp-58h],eax
     70: mov     eax,[rbp-58h]
     73: mov     [rbp-5Ch],eax
     76: mov     eax,[rbp-5Ch]
     79: mov     [rbp-54h],eax
     7c: mov     qword ptr [rbp-0A8h],1
     87: mov     rax,[rbp-38h]
     8b: imul    rcx,[rbp-0A8h],4
     93: add     rax,rcx
     96: mov     [rbp-80h],rax
     9a: lea     rax,[rbp-54h]
     9e: mov     [rbp-98h],rax
     a5: mov     rax,[rbp-38h]
     a9: mov     [rbp-90h],rax
     b0: mov     rax,[rbp-98h]
     b7: mov     [rbp-88h],rax
     be: mov     rax,[rbp-80h]
     c2: mov     [rbp-68h],rax
     c6: mov     qword ptr [rbp-60h],0
     ce: mov     edi,0FFFFFF88h
     d3: mov     esi,0FFFFFF70h
     d8: call    ryo_h_MovW128
     dd: mov     qword ptr [rbp-0A8h],2
     e8: mov     rax,[rbp-0A8h]
     ef: sub     rax,1
     f3: mov     [rbp-90h],rax
     fa: mov     rax,[rbp-30h]
     fe: sub     rax,[rbp-90h]
    105: mov     [rbp-88h],rax
    10c: mov     rax,[rbp-38h]
    110: imul    rcx,[rbp-88h],4
    118: add     rax,rcx
    11b: mov     [rbp-80h],rax
    11f: nop
    120: mov     rax,[rbp-68h]
    124: mov     [rbp-88h],rax
    12b: mov     rax,[rbp-88h]
    132: cmp     rax,[rbp-80h]
    136: jae     248h
    13c: mov     qword ptr [rbp-0A8h],2
    147: cmp     qword ptr [rbp-0A8h],2
    14f: sete    [rbp-56h]
    153: test    byte ptr [rbp-56h],0FFh
    157: je      1F7h
    15d: lea     rax,[rbp-50h]
    161: mov     [rbp-88h],rax
    168: lea     rax,[rbp-78h]
    16c: mov     [rbp-98h],rax
    173: mov     rax,[rbp-98h]
    17a: mov     [rbp-90h],rax
    181: mov     rax,[rbp-88h]
    188: mov     [rbp-0C0h],rax
    18f: mov     rax,[rbp-90h]
    196: mov     [rbp-0B8h],rax
    19d: call    fn0
    1a2: nop     [rcx-10h]
    1a9: lea     rax,[rbp-50h]
    1ad: mov     [rbp-88h],rax
    1b4: lea     rax,[rbp-78h]
    1b8: mov     [rbp-98h],rax
    1bf: mov     rax,[rbp-98h]
    1c6: mov     [rbp-90h],rax
    1cd: mov     rax,[rbp-88h]
    1d4: mov     [rbp-0C0h],rax
    1db: mov     rax,[rbp-90h]
    1e2: mov     [rbp-0B8h],rax
    1e9: call    fn1
    1ee: nop     [rcx-10h]
    1f5: jmp     243h
    1f7: lea     rax,[rbp-50h]
    1fb: mov     [rbp-88h],rax
    202: lea     rax,[rbp-78h]
    206: mov     [rbp-98h],rax
    20d: mov     rax,[rbp-98h]
    214: mov     [rbp-90h],rax
    21b: mov     rax,[rbp-88h]
    222: mov     [rbp-0C0h],rax
    229: mov     rax,[rbp-90h]
    230: mov     [rbp-0B8h],rax
    237: call    fn2
    23c: nop     [rcx-10h]
    243: jmp     120h
    248: mov     rax,[rbp-38h]
    24c: imul    rcx,[rbp-30h],4
    251: add     rax,rcx
    254: mov     [rbp-88h],rax
    25b: nop     [rax+rax]
    260: mov     rax,[rbp-68h]
    264: mov     [rbp-90h],rax
    26b: mov     rax,[rbp-90h]
    272: cmp     rax,[rbp-88h]
    279: sete    [rbp-55h]
    27d: test    byte ptr [rbp-55h],0FFh
    281: je      290h
    283: mov     rax,[rbp-70h]
    287: mov     [rbp-90h],rax
    28e: jmp     29Bh
    290: mov     rax,[rbp-68h]
    294: mov     [rbp-90h],rax
    29b: mov     rax,[rbp-90h]
    2a2: mov     [rbp-68h],rax
    2a6: lea     rax,[rbp-50h]
    2aa: mov     [rbp-90h],rax
    2b1: lea     rax,[rbp-78h]
    2b5: mov     [rbp-0A0h],rax
    2bc: mov     rax,[rbp-0A0h]
    2c3: mov     [rbp-98h],rax
    2ca: mov     rax,[rbp-90h]
    2d1: mov     [rbp-0C0h],rax
    2d8: mov     rax,[rbp-98h]
    2df: mov     [rbp-0B8h],rax
    2e6: call    fn3
    2eb: nop     [rcx-10h]
    2f2: test    byte ptr [rbp-55h],0FFh
    2f6: je      318h
    2f8: mov     rax,[rbp-78h]
    2fc: mov     [rbp-90h],rax
    303: mov     rax,[rbp-70h]
    307: mov     [rbp-98h],rax
    30e: mov     rax,[rbp-60h]
    312: mov     [rbp-8],rax
    316: jmp     31Dh
    318: jmp     260h
    31d: mov     edi,0FFFFFFF8h
    322: mov     esi,8
    327: call    ryo_h_Ret
    32c: leave
    32d: ret
    32e: xchg    ax,ax
    330: mov     edi,0FFFFFFD8h
    335: call    ryo_h_Resume
    33a: ud2
    33c: nop     [rax]
    340: lea     rax,[rbp-78h]
    344: mov     [rbp-0A8h],rax
    34b: mov     rax,[rbp-0A8h]
    352: mov     [rbp-0C0h],rax
    359: call    fn4
    35e: nop     [rcx-0A8h]
    365: jmp     330h
    367: nop     [rax+rax]
    370: lea     rdi,[sym5]
    377: lea     rsi,[site6]
    37e: mov     edx,0FFFFFF58h
    383: call    ryo_h_CallExt
    388: test    rax,rax
    38b: je      398h
    38d: call    rax
    38f: nop     [rcx-0A0h]
    396: jmp     3A8h
    398: mov     rdi,rbp
    39b: lea     rsi,[ro+4]
    3a2: call    qword ptr [sym7]
    3a8: call    ryo_h_Unreachable
    3ad: ud2
    3af: mov     rdi,rax
    3b2: mov     esi,0FFFFFFD8h
    3b7: call    ryo_h_Lpad
    3bc: jmp     340h
    3be: mov     rdi,rax
    3c1: mov     esi,0FFFFFFD8h
    3c6: call    ryo_h_Lpad
    3cb: jmp     370h

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
     22: mov     rax,[rbp-18h]
     26: mov     [rbp-48h],rax
     2a: mov     rax,[rbp+10h]
     2e: mov     rax,[rax+8]
     32: mov     [rbp-20h],rax
     36: mov     rax,[rbp-48h]
     3a: mov     [rbp-40h],rax
     3e: mov     rax,[rbp-20h]
     42: mov     [rbp-38h],rax
     46: mov     rax,[rbp-10h]
     4a: mov     [rbp-0A0h],rax
     51: mov     rax,[rbp-40h]
     55: mov     [rbp-98h],rax
     5c: mov     rax,[rbp-38h]
     60: mov     [rbp-90h],rax
     67: call    fn0
     6c: nop     [rcx-29h]
     73: mov     rax,[rbp+10h]
     77: mov     rax,[rax+10h]
     7b: mov     [rbp-28h],rax
     7f: mov     rax,[rbp-28h]
     83: mov     rax,[rax]
     86: mov     [rbp-40h],rax
     8a: mov     rax,[rbp+18h]
     8e: mov     rax,[rax+18h]
     92: mov     [rbp-48h],rax
     96: mov     rax,[rbp-40h]
     9a: imul    rcx,[rbp-48h],4
     9f: add     rax,rcx
     a2: mov     [rbp-38h],rax
     a6: mov     rax,[rbp-38h]
     aa: mov     [rbp-40h],rax
     ae: mov     rax,[rbp+18h]
     b2: mov     rax,[rax]
     b5: mov     [rbp-48h],rax
     b9: mov     byte ptr [rbp-59h],1
     bd: test    byte ptr [rbp-59h],0FFh
     c1: je      163h
     c7: jmp     0F7h
     c9: nop     [rax]
     d0: mov     rax,[rbp+18h]
     d4: mov     rax,[rax+10h]
     d8: mov     [rbp-8],rax
     dc: mov     rax,[rbp-8]
     e0: mov     [rbp-40h],rax
     e4: mov     byte ptr [rbp-59h],1
     e8: test    byte ptr [rbp-59h],0FFh
     ec: je      1EEh
     f2: jmp     18Dh
     f7: mov     rax,[rbp-38h]
     fb: mov     [rbp-50h],rax
     ff: mov     rax,[rbp-48h]
    103: mov     [rbp-58h],rax
    107: mov     byte ptr [rbp-59h],0
    10b: test    byte ptr [rbp-59h],0FFh
    10f: je      117h
    111: mov     byte ptr [rbp-2Ah],1
    115: jmp     11Bh
    117: mov     byte ptr [rbp-2Ah],0
    11b: mov     rax,[rbp-50h]
    11f: mov     [rbp-0A0h],rax
    126: mov     rax,[rbp-58h]
    12a: mov     [rbp-98h],rax
    131: mov     qword ptr [rbp-90h],4
    13c: movzx   eax,byte ptr [rbp-2Ah]
    140: mov     [rbp-88h],al
    146: mov     edi,0FFFFFF80h
    14b: lea     rsi,[k1]
    152: call    ryo_h_AddrAbs
    157: call    fn2
    15c: nop     [rcx-28h]
    163: mov     qword ptr [rbp-60h],1
    16b: imul    rax,[rbp-60h],4
    170: mov     [rbp-68h],rax
    174: mov     edi,0FFFFFFB8h
    179: mov     esi,0FFFFFFC0h
    17e: mov     edx,0FFFFFF98h
    183: call    ryo_h_Memmove
    188: jmp     0D0h
    18d: mov     rax,[rbp-8]
    191: mov     [rbp-48h],rax
    195: mov     rax,[rbp-38h]
    199: mov     [rbp-50h],rax
    19d: mov     rax,[rbp-48h]
    1a1: mov     [rbp-0A0h],rax
    1a8: mov     rax,[rbp-50h]
    1ac: mov     [rbp-98h],rax
    1b3: mov     qword ptr [rbp-90h],4
    1be: mov     qword ptr [rbp-88h],4
    1c9: mov     qword ptr [rbp-80h],1
    1d1: mov     edi,0FFFFFF88h
    1d6: lea     rsi,[k3]
    1dd: call    ryo_h_AddrAbs
    1e2: call    fn4
    1e7: nop     [rcx-28h]
    1ee: mov     qword ptr [rbp-60h],1
    1f6: imul    rax,[rbp-60h],4
    1fb: mov     [rbp-68h],rax
    1ff: mov     edi,0FFFFFFC8h
    204: mov     esi,0FFFFFFC0h
    209: mov     edx,0FFFFFF98h
    20e: call    ryo_h_Memcpy
    213: mov     rax,[rbp+18h]
    217: mov     rax,[rax+10h]
    21b: mov     [rbp-40h],rax
    21f: mov     rax,[rbp+18h]
    223: mov     rcx,[rbp-40h]
    227: mov     [rax],rcx
    22a: mov     edi,0FFFFFFC0h
    22f: mov     esi,0FFFFFFD7h
    234: call    ryo_h_ZextW8W64
    239: mov     rax,[rbp+18h]
    23d: mov     rax,[rax+18h]
    241: mov     [rbp-60h],rax
    245: mov     rax,[rbp-60h]
    249: add     rax,[rbp-40h]
    24d: mov     [rbp-70h],rax
    251: mov     rax,[rbp+18h]
    255: mov     rcx,[rbp-70h]
    259: mov     [rax+18h],rcx
    25d: mov     rax,[rbp+18h]
    261: mov     rax,[rax+10h]
    265: mov     [rbp-48h],rax
    269: mov     qword ptr [rbp-60h],1
    271: mov     rax,[rbp-48h]
    275: imul    rcx,[rbp-60h],4
    27a: add     rax,rcx
    27d: mov     [rbp-40h],rax
    281: mov     rax,[rbp+18h]
    285: mov     rcx,[rbp-40h]
    289: mov     [rax+10h],rcx
    28d: xor     edi,edi
    28f: xor     esi,esi
    291: call    ryo_h_Ret
    296: leave
    297: ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-58h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     [rbp-50h],rax
     20: mov     rax,[rbp-50h]
     24: mov     [rbp-48h],rax
     28: call    fn0
     2d: nop     [rcx-50h]
     34: mov     rax,[rbp-50h]
     38: cmp     rax,[rbp-48h]
     3c: jb      69h
     3e: mov     edi,0FFFFFF30h
     43: mov     esi,10h
     48: call    ryo_h_MovW128
     4d: mov     rax,[rbp+30h]
     51: mov     [rbp-0C0h],rax
     58: call    fn1
     5d: nop     [rcx]
     64: jmp     49Dh
     69: mov     eax,[rbp+28h]
     6c: mov     [rbp-40h],eax
     6f: cmp     dword ptr [rbp-40h],0
     73: jne     9Dh
     75: mov     edi,0FFFFFF30h
     7a: mov     esi,10h
     7f: call    ryo_h_MovW128
     84: mov     rax,[rbp+30h]
     88: mov     [rbp-0C0h],rax
     8f: call    fn2
     94: nop     [rcx]
     9b: jmp     0DEh
     9d: mov     eax,[rbp+28h]
     a0: sub     eax,1
     a3: mov     [rbp+28h],eax
     a6: mov     rax,[rbp+10h]
     aa: mov     [rbp-58h],rax
     ae: mov     rax,[rbp+18h]
     b2: mov     [rbp-50h],rax
     b6: mov     edi,0FFFFFF30h
     bb: mov     esi,0FFFFFFA8h
     c0: call    ryo_h_MovW128
     c5: mov     rax,[rbp+30h]
     c9: mov     [rbp-0C0h],rax
     d0: call    fn3
     d5: nop     [rcx-48h]
     dc: jmp     0E3h
     de: jmp     49Dh
     e3: mov     edi,0FFFFFF5Ch
     e8: mov     esi,20h
     ed: xor     edx,edx
     ef: xor     ecx,ecx
     f1: xor     r8d,r8d
     f4: mov     r9d,1
     fa: call    ryo_h_DiscrNicheW64
     ff: mov     edi,0FFFFFFF8h
    104: mov     esi,0FFFFFF5Ch
    109: call    ryo_h_ZextW32W64
    10e: mov     edi,0FFFFFFF8h
    113: xor     esi,esi
    115: mov     edx,2
    11a: call    ryo_h_SwitchDenseW64
    11f: lea     rcx,[130h]
    126: movsxd  rax,[rcx+rax*4]
    12a: add     rax,rcx
    12d: jmp     rax
    12f: int3
    130: .long   2a6h
    134: .long   13ch
    138: .long   58ch
    13c: mov     rax,[rbp+20h]
    140: mov     [rbp-50h],rax
    144: mov     rax,[rbp+10h]
    148: mov     [rbp-18h],rax
    14c: mov     rax,[rbp+18h]
    150: mov     [rbp-10h],rax
    154: mov     rax,[rbp-10h]
    158: mov     [rbp-20h],rax
    15c: mov     rax,[rbp-48h]
    160: cmp     rax,[rbp-20h]
    164: jb      1CCh
    166: mov     rax,[rbp-48h]
    16a: mov     [rbp-0D0h],rax
    171: mov     rax,[rbp-20h]
    175: mov     [rbp-0C8h],rax
    17c: mov     edi,0FFFFFF40h
    181: lea     rsi,[k4]
    188: call    ryo_h_AddrAbs
    18d: lea     rdi,[sym5]
    194: lea     rsi,[site6]
    19b: mov     edx,0FFFFFF58h
    1a0: call    ryo_h_CallExt
    1a5: test    rax,rax
    1a8: je      1B5h
    1aa: call    rax
    1ac: nop     [rcx-0A0h]
    1b3: jmp     1C5h
    1b5: mov     rdi,rbp
    1b8: lea     rsi,[ro+4]
    1bf: call    qword ptr [sym7]
    1c5: call    ryo_h_Unreachable
    1ca: ud2
    1cc: mov     rax,[rbp+10h]
    1d0: imul    rcx,[rbp-48h],4
    1d5: add     rax,rcx
    1d8: mov     [rbp-0A8h],rax
    1df: mov     rax,[rbp-0A8h]
    1e6: mov     [rbp-68h],rax
    1ea: mov     rax,[rbp-50h]
    1ee: mov     [rbp-60h],rax
    1f2: mov     rax,[rbp-68h]
    1f6: mov     [rbp-58h],rax
    1fa: mov     rax,[rbp+30h]
    1fe: mov     [rbp-0D0h],rax
    205: mov     rax,[rbp-60h]
    209: mov     [rbp-0C8h],rax
    210: mov     rax,[rbp-58h]
    214: mov     [rbp-0C0h],rax
    21b: call    fn8
    220: nop     [rcx-3Ah]
    227: test    byte ptr [rbp-3Ah],0FFh
    22b: je      22Fh
    22d: jmp     2A6h
    22f: mov     edi,0FFFFFF98h
    234: mov     esi,10h
    239: call    ryo_h_MovW128
    23e: mov     rax,[rbp+30h]
    242: mov     [rbp-78h],rax
    246: lea     rax,[rbp-78h]
    24a: mov     [rbp-70h],rax
    24e: mov     edi,0FFFFFF30h
    253: mov     esi,0FFFFFF98h
    258: call    ryo_h_MovW128
    25d: mov     rax,[rbp-48h]
    261: mov     [rbp-0C0h],rax
    268: mov     rax,[rbp-70h]
    26c: mov     [rbp-0B8h],rax
    273: call    fn9
    278: nop     [rcx-58h]
    27f: mov     rax,[rbp-58h]
    283: add     rax,1
    287: mov     [rbp-30h],rax
    28b: mov     rax,[rbp+18h]
    28f: mov     [rbp-60h],rax
    293: mov     rax,[rbp-60h]
    297: cmp     rax,[rbp-30h]
    29b: jb      4A8h
    2a1: jmp     519h
    2a6: mov     edi,0FFFFFFA0h
    2ab: mov     esi,10h
    2b0: call    ryo_h_MovW128
    2b5: mov     edi,0FFFFFF30h
    2ba: mov     esi,0FFFFFFA0h
    2bf: call    ryo_h_MovW128
    2c4: mov     rax,[rbp-48h]
    2c8: mov     [rbp-0C0h],rax
    2cf: mov     rax,[rbp+30h]
    2d3: mov     [rbp-0B8h],rax
    2da: call    fn10
    2df: nop     [rcx-50h]
    2e6: mov     rax,[rbp+10h]
    2ea: mov     [rbp-68h],rax
    2ee: mov     rax,[rbp+18h]
    2f2: mov     [rbp-60h],rax
    2f6: mov     rax,[rbp-60h]
    2fa: mov     [rbp-58h],rax
    2fe: mov     rax,[rbp-50h]
    302: cmp     rax,[rbp-58h]
    306: setb    [rbp-3Ah]
    30a: mov     edi,0FFFFFF30h
    30f: mov     esi,10h
    314: call    ryo_h_MovW128
    319: mov     rax,[rbp-50h]
    31d: mov     [rbp-0C0h],rax
    324: mov     edi,0FFFFFF48h
    329: lea     rsi,[k11]
    330: call    ryo_h_AddrAbs
    335: call    fn12
    33a: nop     [rcx-90h]
    341: mov     edi,0FFFFFFA0h
    346: mov     esi,0FFFFFF70h
    34b: call    ryo_h_MovW128
    350: mov     edi,0FFFFFF90h
    355: mov     esi,0FFFFFF80h
    35a: call    ryo_h_MovW128
    35f: mov     edi,0FFFFFF30h
    364: mov     esi,0FFFFFF90h
    369: call    ryo_h_MovW128
    36e: mov     qword ptr [rbp-0C0h],1
    379: mov     edi,0FFFFFF48h
    37e: lea     rsi,[k13]
    385: call    ryo_h_AddrAbs
    38a: call    fn14
    38f: nop     [rcx-0A0h]
    396: mov     edi,0FFFFFF80h
    39b: mov     esi,0FFFFFF60h
    3a0: call    ryo_h_MovW128
    3a5: mov     edi,10h
    3aa: mov     esi,0FFFFFF70h
    3af: call    ryo_h_MovW128
    3b4: mov     rax,[rbp-78h]
    3b8: mov     [rbp-38h],rax
    3bc: mov     qword ptr [rbp-0A8h],0
    3c7: mov     rax,[rbp-0A8h]
    3ce: cmp     rax,[rbp-38h]
    3d2: setb    [rbp-39h]
    3d6: test    byte ptr [rbp-39h],0FFh
    3da: jne     442h
    3dc: mov     qword ptr [rbp-0D0h],0
    3e7: mov     rax,[rbp-38h]
    3eb: mov     [rbp-0C8h],rax
    3f2: mov     edi,0FFFFFF40h
    3f7: lea     rsi,[k15]
    3fe: call    ryo_h_AddrAbs
    403: lea     rdi,[sym16]
    40a: lea     rsi,[site17]
    411: mov     edx,0FFFFFF58h
    416: call    ryo_h_CallExt
    41b: test    rax,rax
    41e: je      42Bh
    420: call    rax
    422: nop     [rcx-0A0h]
    429: jmp     43Bh
    42b: mov     rdi,rbp
    42e: lea     rsi,[ro+4]
    435: call    qword ptr [sym18]
    43b: call    ryo_h_Unreachable
    440: ud2
    442: mov     rax,[rbp-80h]
    446: mov     [rbp-88h],rax
    44d: mov     eax,[rbp+28h]
    450: mov     [rbp-40h],eax
    453: mov     edi,0FFFFFF30h
    458: mov     esi,0FFFFFFA0h
    45d: call    ryo_h_MovW128
    462: mov     rax,[rbp+20h]
    466: mov     [rbp-0C0h],rax
    46d: mov     eax,[rbp-40h]
    470: mov     [rbp-0B8h],eax
    476: mov     rax,[rbp+30h]
    47a: mov     [rbp-0B0h],rax
    481: call    fn19
    486: nop     [rcx-39h]
    48d: mov     rax,[rbp-88h]
    494: mov     [rbp+20h],rax
    498: jmp     10h
    49d: xor     edi,edi
    49f: xor     esi,esi
    4a1: call    ryo_h_Ret
    4a6: leave
    4a7: ret
    4a8: mov     rax,[rbp-30h]
    4ac: mov     [rbp-0D0h],rax
    4b3: mov     rax,[rbp-60h]
    4b7: mov     [rbp-0C8h],rax
    4be: mov     rax,[rbp-60h]
    4c2: mov     [rbp-0C0h],rax
    4c9: mov     edi,0FFFFFF48h
    4ce: lea     rsi,[k20]
    4d5: call    ryo_h_AddrAbs
    4da: lea     rdi,[sym21]
    4e1: lea     rsi,[site22]
    4e8: mov     edx,0FFFFFF58h
    4ed: call    ryo_h_CallExt
    4f2: test    rax,rax
    4f5: je      502h
    4f7: call    rax
    4f9: nop     [rcx-39h]
    500: jmp     512h
    502: mov     rdi,rbp
    505: lea     rsi,[ro+20]
    50c: call    qword ptr [sym23]
    512: call    ryo_h_Unreachable
    517: ud2
    519: mov     rax,[rbp-60h]
    51d: sub     rax,[rbp-30h]
    521: mov     [rbp-68h],rax
    525: mov     rax,[rbp+10h]
    529: mov     [rbp-88h],rax
    530: mov     rax,[rbp+18h]
    534: mov     [rbp-80h],rax
    538: mov     rax,[rbp-88h]
    53f: mov     [rbp-90h],rax
    546: mov     rax,[rbp-90h]
    54d: imul    rcx,[rbp-30h],4
    552: add     rax,rcx
    555: mov     [rbp-98h],rax
    55c: mov     rax,[rbp-98h]
    563: mov     [rbp-78h],rax
    567: mov     rax,[rbp-68h]
    56b: mov     [rbp-70h],rax
    56f: mov     rax,[rbp-78h]
    573: mov     [rbp+10h],rax
    577: mov     rax,[rbp-70h]
    57b: mov     [rbp+18h],rax
    57f: mov     qword ptr [rbp+20h],0
    587: jmp     10h
    58c: call    ryo_h_Unreachable
    591: ud2

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
     1a: cmp     qword ptr [rbp-8],2
     1f: setb    [rbp-9]
     23: test    byte ptr [rbp-9],0FFh
     27: je      5Dh
     29: jmp     5Bh
     2b: nop     [rax+rax]
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
     c9: mov     rax,[rbp-40h]
     cd: mov     [rbp-38h],rax
     d1: mov     rax,[rbp-28h]
     d5: cmp     rax,[rbp-30h]
     d9: jae     0E9h
     db: mov     rax,[rbp-30h]
     df: sub     rax,[rbp-28h]
     e3: mov     [rbp-10h],rax
     e7: jmp     0F5h
     e9: mov     rax,[rbp-28h]
     ed: sub     rax,[rbp-30h]
     f1: mov     [rbp-10h],rax
     f5: mov     rax,[rbp-38h]
     f9: cmp     rax,[rbp-10h]
     fd: setbe   [rbp-1]
    101: mov     edi,0FFFFFFFFh
    106: mov     esi,1
    10b: call    ryo_h_Ret
    110: leave
    111: ret

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
     48: mov     rax,[rbp-60h]
     4c: mov     [rbp-58h],rax
     50: mov     edi,0FFFFFCD0h
     55: mov     esi,0FFFFFFB0h
     5a: call    ryo_h_MovW128
     5f: mov     rax,[rbp-58h]
     63: mov     [rbp-320h],rax
     6a: call    fn1
     6f: nop     [rcx-40h]
     76: mov     edi,0FFFFFCD0h
     7b: mov     esi,0FFFFFFC0h
     80: mov     edx,18h
     85: call    ryo_h_Copy
     8a: call    fn2
     8f: nop     [rcx-28h]
     96: lea     rax,[rbp-28h]
     9a: mov     [rbp-80h],rax
     9e: mov     rax,[rbp-80h]
     a2: mov     [rbp-330h],rax
     a9: call    fn3
     ae: nop     [rcx-78h]
     b5: lea     rax,[rbp-78h]
     b9: mov     [rbp-98h],rax
     c0: mov     rax,[rbp-98h]
     c7: mov     [rbp-330h],rax
     ce: call    fn4
     d3: nop     [rcx-90h]
     da: mov     edi,0FFFFFCD0h
     df: mov     esi,0FFFFFF70h
     e4: call    ryo_h_MovW128
     e9: call    fn5
     ee: nop     [rcx-80h]
     f5: lea     rax,[rbp-28h]
     f9: mov     [rbp-0B8h],rax
    100: mov     rax,[rbp-0B8h]
    107: mov     [rbp-330h],rax
    10e: call    fn6
    113: nop     [rcx-0B0h]
    11a: lea     rax,[rbp-0B0h]
    121: mov     [rbp-0D0h],rax
    128: mov     rax,[rbp-0D0h]
    12f: mov     [rbp-330h],rax
    136: call    fn7
    13b: nop     [rcx-0C8h]
    142: mov     rax,[rbp-8]
    146: mov     [rbp-330h],rax
    14d: call    fn8
    152: nop     [rcx-0F0h]
    159: lea     rax,[rbp-0F0h]
    160: mov     [rbp-0D8h],rax
    167: mov     edi,0FFFFFCD0h
    16c: mov     esi,0FFFFFF38h
    171: call    ryo_h_MovW128
    176: mov     rax,[rbp-0D8h]
    17d: mov     [rbp-320h],rax
    184: call    fn9
    189: nop     [rcx-0B8h]
    190: lea     rax,[rbp-0F0h]
    197: mov     [rbp-2F8h],rax
    19e: mov     rax,[rbp-2F8h]
    1a5: mov     [rbp-330h],rax
    1ac: call    fn10
    1b1: nop     [rcx-2F8h]
    1b8: lea     rax,[rbp-78h]
    1bc: mov     [rbp-108h],rax
    1c3: lea     rax,[rbp-0B0h]
    1ca: mov     [rbp-110h],rax
    1d1: mov     rax,[rbp-108h]
    1d8: mov     [rbp-100h],rax
    1df: mov     rax,[rbp-110h]
    1e6: mov     [rbp-0F8h],rax
    1ed: mov     rax,[rbp-100h]
    1f4: mov     [rbp-118h],rax
    1fb: mov     rax,[rbp-0F8h]
    202: mov     [rbp-120h],rax
    209: mov     rax,[rbp-118h]
    210: mov     [rbp-330h],rax
    217: mov     rax,[rbp-120h]
    21e: mov     [rbp-328h],rax
    225: call    fn11
    22a: nop     [rcx-121h]
    231: test    byte ptr [rbp-121h],0FFh
    238: je      261h
    23a: lea     rax,[rbp-28h]
    23e: mov     [rbp-188h],rax
    245: mov     rax,[rbp-188h]
    24c: mov     [rbp-330h],rax
    253: call    fn12
    258: nop     [rcx-180h]
    25f: jmp     2CFh
    261: mov     byte ptr [rbp-122h],0
    268: mov     qword ptr [rbp-138h],0
    273: movzx   eax,byte ptr [rbp-122h]
    27a: mov     [rbp-310h],al
    280: mov     rax,[rbp-118h]
    287: mov     [rbp-330h],rax
    28e: mov     rax,[rbp-120h]
    295: mov     [rbp-328h],rax
    29c: mov     edi,0FFFFFCE0h
    2a1: mov     esi,0FFFFFEC8h
    2a6: call    ryo_h_MovW128
    2ab: mov     edi,0FFFFFCF8h
    2b0: lea     rsi,[k13]
    2b7: call    ryo_h_AddrAbs
    2bc: call    fn14
    2c1: nop     [rcx-122h]
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     edi,0FFFFFCD0h
    2d4: mov     esi,0FFFFFE80h
    2d9: call    ryo_h_MovW128
    2de: call    fn15
    2e3: nop     [rcx-170h]
    2ea: mov     edi,0FFFFFCD0h
    2ef: mov     esi,0FFFFFE90h
    2f4: call    ryo_h_MovW128
    2f9: call    fn16
    2fe: nop     [rcx-160h]
    305: mov     edi,0FFFFFCD0h
    30a: mov     esi,0FFFFFEA0h
    30f: call    ryo_h_MovW128
    314: call    fn17
    319: nop     [rcx-150h]
    320: lea     rax,[rbp-150h]
    327: mov     [rbp-1A0h],rax
    32e: mov     rax,[rbp-1A0h]
    335: mov     [rbp-330h],rax
    33c: call    fn18
    341: nop     [rcx-198h]
    348: mov     edi,0FFFFFCD0h
    34d: mov     esi,0FFFFFE68h
    352: call    ryo_h_MovW128
    357: call    fn19
    35c: nop     [rcx-188h]
    363: lea     rax,[rbp-78h]
    367: mov     [rbp-1F8h],rax
    36e: mov     rax,[rbp-1F8h]
    375: mov     [rbp-330h],rax
    37c: call    fn20
    381: nop     [rcx-1F0h]
    388: mov     edi,0FFFFFCD0h
    38d: mov     esi,0FFFFFE10h
    392: call    ryo_h_MovW128
    397: call    fn21
    39c: nop     [rcx-1E0h]
    3a3: lea     rax,[rbp-1E0h]
    3aa: mov     [rbp-1D8h],rax
    3b1: lea     rax,[rbp-150h]
    3b8: mov     [rbp-208h],rax
    3bf: mov     rax,[rbp-208h]
    3c6: mov     [rbp-330h],rax
    3cd: mov     qword ptr [rbp-328h],0
    3d8: mov     edi,0FFFFFCE0h
    3dd: lea     rsi,[k22]
    3e4: call    ryo_h_AddrAbs
    3e9: call    fn23
    3ee: nop     [rcx-200h]
    3f5: lea     rax,[rbp-150h]
    3fc: mov     [rbp-218h],rax
    403: mov     qword ptr [rbp-2F8h],1
    40e: mov     edi,0FFFFFDD0h
    413: mov     esi,0FFFFFDD8h
    418: mov     edx,0FFFFFFF8h
    41d: mov     ecx,0FFFFFD08h
    422: call    ryo_h_SubOvfUW64
    427: test    byte ptr [rbp-228h],0FFh
    42e: je      480h
    430: mov     edi,0FFFFFCD0h
    435: lea     rsi,[k24]
    43c: call    ryo_h_AddrAbs
    441: lea     rdi,[sym25]
    448: lea     rsi,[site26]
    44f: mov     edx,0FFFFFD08h
    454: call    ryo_h_CallExt
    459: test    rax,rax
    45c: je      469h
    45e: call    rax
    460: nop     [rcx-2F0h]
    467: jmp     479h
    469: mov     rdi,rbp
    46c: lea     rsi,[ro+4]
    473: call    qword ptr [sym27]
    479: call    ryo_h_Unreachable
    47e: ud2
    480: mov     rax,[rbp-230h]
    487: mov     [rbp-220h],rax
    48e: mov     rax,[rbp-218h]
    495: mov     [rbp-330h],rax
    49c: mov     rax,[rbp-220h]
    4a3: mov     [rbp-328h],rax
    4aa: mov     edi,0FFFFFCE0h
    4af: lea     rsi,[k28]
    4b6: call    ryo_h_AddrAbs
    4bb: call    fn29
    4c0: nop     [rcx-210h]
    4c7: lea     rax,[rbp-8]
    4cb: mov     [rbp-238h],rax
    4d2: mov     rax,[rbp-1D8h]
    4d9: mov     [rbp-1D0h],rax
    4e0: mov     rax,[rbp-200h]
    4e7: mov     [rbp-1C8h],rax
    4ee: mov     rax,[rbp-210h]
    4f5: mov     [rbp-1C0h],rax
    4fc: mov     rax,[rbp-238h]
    503: mov     [rbp-1B8h],rax
    50a: mov     rax,[rbp-1B8h]
    511: mov     [rbp-2D0h],rax
    518: mov     rax,[rbp-2D0h]
    51f: mov     [rbp-330h],rax
    526: call    fn30
    52b: nop     [rcx-288h]
    532: mov     rax,[rbp-1D0h]
    539: mov     [rbp-2D8h],rax
    540: mov     rax,[rbp-2D8h]
    547: mov     [rbp-330h],rax
    54e: call    fn31
    553: nop     [rcx-298h]
    55a: mov     rax,[rbp-1C8h]
    561: mov     [rbp-2E0h],rax
    568: mov     rax,[rbp-2E0h]
    56f: mov     [rbp-330h],rax
    576: call    fn32
    57b: nop     [rcx-2A8h]
    582: mov     rax,[rbp-1C0h]
    589: mov     [rbp-2E8h],rax
    590: mov     rax,[rbp-2E8h]
    597: mov     [rbp-330h],rax
    59e: call    fn33
    5a3: nop     [rcx-2B8h]
    5aa: mov     edi,0FFFFFD88h
    5af: mov     esi,0FFFFFD78h
    5b4: call    ryo_h_MovW128
    5b9: mov     edi,0FFFFFD98h
    5be: mov     esi,0FFFFFD68h
    5c3: call    ryo_h_MovW128
    5c8: mov     edi,0FFFFFDA8h
    5cd: mov     esi,0FFFFFD58h
    5d2: call    ryo_h_MovW128
    5d7: mov     edi,0FFFFFDB8h
    5dc: mov     esi,0FFFFFD48h
    5e1: call    ryo_h_MovW128
    5e6: mov     edi,0FFFFFD40h
    5eb: lea     rsi,[k34]
    5f2: call    ryo_h_AddrAbs
    5f7: lea     rax,[rbp-278h]
    5fe: mov     [rbp-2C8h],rax
    605: mov     rax,[rbp-2C0h]
    60c: mov     [rbp-330h],rax
    613: mov     rax,[rbp-2C8h]
    61a: mov     [rbp-328h],rax
    621: call    fn35
    626: nop     [rcx-1B0h]
    62d: mov     edi,0FFFFFCD0h
    632: mov     esi,0FFFFFE50h
    637: call    ryo_h_MovW128
    63c: lea     rdi,[sym36]
    643: lea     rsi,[site37]
    64a: mov     edx,0FFFFFD08h
    64f: call    ryo_h_CallExt
    654: test    rax,rax
    657: je      664h
    659: call    rax
    65b: nop     [rcx-1A0h]
    662: jmp     674h
    664: mov     rdi,rbp
    667: lea     rsi,[ro+20]
    66e: call    qword ptr [sym38]
    674: lea     rax,[rbp-150h]
    67b: mov     [rbp-2F8h],rax
    682: mov     rax,[rbp-2F8h]
    689: mov     [rbp-330h],rax
    690: call    fn39
    695: nop     [rcx-2F8h]
    69c: lea     rax,[rbp-0B0h]
    6a3: mov     [rbp-2F8h],rax
    6aa: mov     rax,[rbp-2F8h]
    6b1: mov     [rbp-330h],rax
    6b8: call    fn40
    6bd: nop     [rcx-2F8h]
    6c4: lea     rax,[rbp-78h]
    6c8: mov     [rbp-2F8h],rax
    6cf: mov     rax,[rbp-2F8h]
    6d6: mov     [rbp-330h],rax
    6dd: call    fn41
    6e2: nop     [rcx-2F8h]
    6e9: lea     rax,[rbp-28h]
    6ed: mov     [rbp-2F8h],rax
    6f4: mov     rax,[rbp-2F8h]
    6fb: mov     [rbp-330h],rax
    702: call    fn42
    707: nop     [rcx-2F8h]
    70e: xor     edi,edi
    710: xor     esi,esi
    712: call    ryo_h_Ret
    717: leave
    718: ret
    719: nop     [rax]
    720: lea     rax,[rbp-150h]
    727: mov     [rbp-2F8h],rax
    72e: mov     rax,[rbp-2F8h]
    735: mov     [rbp-330h],rax
    73c: call    fn43
    741: nop     [rcx-2F8h]
    748: jmp     780h
    74a: nop     [rax+rax]
    750: lea     rax,[rbp-0F0h]
    757: mov     [rbp-2F8h],rax
    75e: mov     rax,[rbp-2F8h]
    765: mov     [rbp-330h],rax
    76c: call    fn44
    771: nop     [rcx-2F8h]
    778: nop     [rax+rax]
    780: lea     rax,[rbp-0B0h]
    787: mov     [rbp-2F8h],rax
    78e: mov     rax,[rbp-2F8h]
    795: mov     [rbp-330h],rax
    79c: call    fn45
    7a1: nop     [rcx-2F8h]
    7a8: nop     [rax+rax]
    7b0: lea     rax,[rbp-78h]
    7b4: mov     [rbp-2F8h],rax
    7bb: mov     rax,[rbp-2F8h]
    7c2: mov     [rbp-330h],rax
    7c9: call    fn46
    7ce: nop     [rcx-2F8h]
    7d5: nop     [rax+rax]
    7de: xchg    ax,ax
    7e0: lea     rax,[rbp-28h]
    7e4: mov     [rbp-2F8h],rax
    7eb: mov     rax,[rbp-2F8h]
    7f2: mov     [rbp-330h],rax
    7f9: call    fn47
    7fe: nop     [rcx-2F8h]
    805: mov     edi,0FFFFFD10h
    80a: call    ryo_h_Resume
    80f: ud2
    811: nop     [rax+rax]
    81a: nop     [rax+rax]
    820: lea     rdi,[sym48]
    827: lea     rsi,[site49]
    82e: mov     edx,0FFFFFD08h
    833: call    ryo_h_CallExt
    838: test    rax,rax
    83b: je      848h
    83d: call    rax
    83f: nop     [rcx-2F0h]
    846: jmp     858h
    848: mov     rdi,rbp
    84b: lea     rsi,[ro+4]
    852: call    qword ptr [sym50]
    858: call    ryo_h_Unreachable
    85d: ud2
    85f: mov     rdi,rax
    862: mov     esi,0FFFFFD10h
    867: call    ryo_h_Lpad
    86c: jmp     7E0h
    871: mov     rdi,rax
    874: mov     esi,0FFFFFD10h
    879: call    ryo_h_Lpad
    87e: jmp     7B0h
    883: mov     rdi,rax
    886: mov     esi,0FFFFFD10h
    88b: call    ryo_h_Lpad
    890: jmp     780h
    895: mov     rdi,rax
    898: mov     esi,0FFFFFD10h
    89d: call    ryo_h_Lpad
    8a2: jmp     750h
    8a7: mov     rdi,rax
    8aa: mov     esi,0FFFFFD10h
    8af: call    ryo_h_Lpad
    8b4: jmp     720h
    8b9: mov     rdi,rax
    8bc: mov     esi,0FFFFFD10h
    8c1: call    ryo_h_Lpad
    8c6: jmp     820h

fn main::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp-18h]
     17: mov     [rbp-20h],rax
     1b: call    fn0
     20: nop     [rcx-10h]
     27: mov     edi,0FFFFFFFCh
     2c: mov     esi,0FFFFFFF0h
     31: call    ryo_h_TruncW64W32
     36: mov     edi,0FFFFFFFCh
     3b: mov     esi,4
     40: call    ryo_h_Ret
     45: leave
     46: ret

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
     1b: mov     rax,[rbp-18h]
     1f: mov     [rbp-10h],rax
     23: cmp     qword ptr [rbp-10h],10h
     28: ja      4DEh
     2e: mov     rax,[rbp+10h]
     32: mov     [rbp-58h],rax
     36: mov     rax,[rbp+18h]
     3a: mov     [rbp-50h],rax
     3e: mov     rax,[rbp-50h]
     42: mov     [rbp-48h],rax
     46: mov     qword ptr [rbp-40h],1
     4e: mov     rax,[rbp-48h]
     52: mov     [rbp-38h],rax
     56: mov     edi,0FFFFFC80h
     5b: mov     esi,0FFFFFFC0h
     60: call    ryo_h_MovW128
     65: call    fn0
     6a: nop     [rcx-30h]
     71: mov     edi,0FFFFFF98h
     76: mov     esi,0FFFFFFD0h
     7b: call    ryo_h_MovW128
     80: lea     rax,[rbp-68h]
     84: mov     [rbp-80h],rax
     88: mov     rax,[rbp-80h]
     8c: mov     [rbp-380h],rax
     93: call    fn1
     98: nop     [rcx-78h]
     9f: mov     rax,[rbp-78h]
     a3: mov     [rbp-88h],rax
     aa: mov     edi,0FFFFFF78h
     af: xor     esi,esi
     b1: mov     edx,2
     b6: call    ryo_h_SwitchDenseW64
     bb: lea     rcx,[0CCh]
     c2: movsxd  rax,[rcx+rax*4]
     c6: add     rax,rcx
     c9: jmp     rax
     cb: int3
     cc: .long   d7fh
     d0: .long   dfh
     d4: .long   d8h
     d8: call    ryo_h_Unreachable
     dd: ud2
     df: mov     rax,[rbp-70h]
     e3: mov     [rbp-90h],rax
     ea: mov     rax,[rbp-90h]
     f1: mov     [rbp-98h],rax
     f8: nop     [rax+rax]
    100: mov     rax,[rbp-98h]
    107: mov     [rbp-0A8h],rax
    10e: cmp     qword ptr [rbp-0A8h],0
    116: jbe     80h
    11c: mov     rax,[rbp-98h]
    123: mov     [rbp-0C0h],rax
    12a: mov     qword ptr [rbp-358h],1
    135: mov     edi,0FFFFFF30h
    13a: mov     esi,0FFFFFF38h
    13f: mov     edx,0FFFFFF40h
    144: mov     ecx,0FFFFFCA8h
    149: call    ryo_h_SubOvfUW64
    14e: test    byte ptr [rbp-0C8h],0FFh
    155: je      1A7h
    157: mov     edi,0FFFFFC80h
    15c: lea     rsi,[k2]
    163: call    ryo_h_AddrAbs
    168: lea     rdi,[sym3]
    16f: lea     rsi,[site4]
    176: mov     edx,0FFFFFCA8h
    17b: call    ryo_h_CallExt
    180: test    rax,rax
    183: je      190h
    185: call    rax
    187: nop     [rcx-350h]
    18e: jmp     1A0h
    190: mov     rdi,rbp
    193: lea     rsi,[ro+4]
    19a: call    qword ptr [sym5]
    1a0: call    ryo_h_Unreachable
    1a5: ud2
    1a7: mov     rax,[rbp-0D0h]
    1ae: mov     [rbp-0B8h],rax
    1b5: mov     rax,[rbp+10h]
    1b9: mov     [rbp-0E0h],rax
    1c0: mov     rax,[rbp+18h]
    1c4: mov     [rbp-0D8h],rax
    1cb: mov     rax,[rbp-0D8h]
    1d2: mov     [rbp-0E8h],rax
    1d9: mov     rax,[rbp-0B8h]
    1e0: cmp     rax,[rbp-0E8h]
    1e7: jb      255h
    1e9: mov     rax,[rbp-0B8h]
    1f0: mov     [rbp-380h],rax
    1f7: mov     rax,[rbp-0E8h]
    1fe: mov     [rbp-378h],rax
    205: mov     edi,0FFFFFC90h
    20a: lea     rsi,[k6]
    211: call    ryo_h_AddrAbs
    216: lea     rdi,[sym7]
    21d: lea     rsi,[site8]
    224: mov     edx,0FFFFFCA8h
    229: call    ryo_h_CallExt
    22e: test    rax,rax
    231: je      23Eh
    233: call    rax
    235: nop     [rcx-350h]
    23c: jmp     24Eh
    23e: mov     rdi,rbp
    241: lea     rsi,[ro+4]
    248: call    qword ptr [sym9]
    24e: call    ryo_h_Unreachable
    253: ud2
    255: mov     rax,[rbp+10h]
    259: imul    rcx,[rbp-0B8h],4
    261: add     rax,rcx
    264: mov     [rbp-358h],rax
    26b: mov     rax,[rbp-358h]
    272: mov     eax,[rax]
    274: mov     [rbp-0B0h],eax
    27a: mov     rax,[rbp-98h]
    281: mov     [rbp-0F8h],rax
    288: mov     rax,[rbp+10h]
    28c: mov     [rbp-108h],rax
    293: mov     rax,[rbp+18h]
    297: mov     [rbp-100h],rax
    29e: mov     rax,[rbp-100h]
    2a5: mov     [rbp-110h],rax
    2ac: mov     rax,[rbp-0F8h]
    2b3: cmp     rax,[rbp-110h]
    2ba: jb      328h
    2bc: mov     rax,[rbp-0F8h]
    2c3: mov     [rbp-380h],rax
    2ca: mov     rax,[rbp-110h]
    2d1: mov     [rbp-378h],rax
    2d8: mov     edi,0FFFFFC90h
    2dd: lea     rsi,[k10]
    2e4: call    ryo_h_AddrAbs
    2e9: lea     rdi,[sym11]
    2f0: lea     rsi,[site12]
    2f7: mov     edx,0FFFFFCA8h
    2fc: call    ryo_h_CallExt
    301: test    rax,rax
    304: je      311h
    306: call    rax
    308: nop     [rcx-350h]
    30f: jmp     321h
    311: mov     rdi,rbp
    314: lea     rsi,[ro+4]
    31b: call    qword ptr [sym13]
    321: call    ryo_h_Unreachable
    326: ud2
    328: mov     rax,[rbp+10h]
    32c: imul    rcx,[rbp-0F8h],4
    334: add     rax,rcx
    337: mov     [rbp-358h],rax
    33e: mov     rax,[rbp-358h]
    345: mov     eax,[rax]
    347: mov     [rbp-0F0h],eax
    34d: mov     eax,[rbp-0F0h]
    353: cmp     eax,[rbp-0B0h]
    359: jae     80h
    35f: mov     rax,[rbp-98h]
    366: mov     [rbp-128h],rax
    36d: mov     qword ptr [rbp-358h],1
    378: mov     edi,0FFFFFEC8h
    37d: mov     esi,0FFFFFED0h
    382: mov     edx,0FFFFFED8h
    387: mov     ecx,0FFFFFCA8h
    38c: call    ryo_h_SubOvfUW64
    391: test    byte ptr [rbp-130h],0FFh
    398: je      3EAh
    39a: mov     edi,0FFFFFC80h
    39f: lea     rsi,[k14]
    3a6: call    ryo_h_AddrAbs
    3ab: lea     rdi,[sym15]
    3b2: lea     rsi,[site16]
    3b9: mov     edx,0FFFFFCA8h
    3be: call    ryo_h_CallExt
    3c3: test    rax,rax
    3c6: je      3D3h
    3c8: call    rax
    3ca: nop     [rcx-350h]
    3d1: jmp     3E3h
    3d3: mov     rdi,rbp
    3d6: lea     rsi,[ro+4]
    3dd: call    qword ptr [sym17]
    3e3: call    ryo_h_Unreachable
    3e8: ud2
    3ea: mov     rax,[rbp-138h]
    3f1: mov     [rbp-120h],rax
    3f8: mov     rax,[rbp-98h]
    3ff: mov     [rbp-140h],rax
    406: mov     edi,0FFFFFC80h
    40b: mov     esi,10h
    410: call    ryo_h_MovW128
    415: mov     rax,[rbp-120h]
    41c: mov     [rbp-370h],rax
    423: mov     rax,[rbp-140h]
    42a: mov     [rbp-368h],rax
    431: mov     edi,0FFFFFCA0h
    436: lea     rsi,[k18]
    43d: call    ryo_h_AddrAbs
    442: call    fn19
    447: nop     [rcx-111h]
    44e: mov     qword ptr [rbp-358h],1
    459: mov     edi,0FFFFFEB0h
    45e: mov     esi,0FFFFFEB8h
    463: mov     edx,0FFFFFF68h
    468: mov     ecx,0FFFFFCA8h
    46d: call    ryo_h_SubOvfUW64
    472: test    byte ptr [rbp-148h],0FFh
    479: je      4CBh
    47b: mov     edi,0FFFFFC80h
    480: lea     rsi,[k20]
    487: call    ryo_h_AddrAbs
    48c: lea     rdi,[sym21]
    493: lea     rsi,[site22]
    49a: mov     edx,0FFFFFCA8h
    49f: call    ryo_h_CallExt
    4a4: test    rax,rax
    4a7: je      4B4h
    4a9: call    rax
    4ab: nop     [rcx-350h]
    4b2: jmp     4C4h
    4b4: mov     rdi,rbp
    4b7: lea     rsi,[ro+4]
    4be: call    qword ptr [sym23]
    4c4: call    ryo_h_Unreachable
    4c9: ud2
    4cb: mov     rax,[rbp-150h]
    4d2: mov     [rbp-98h],rax
    4d9: jmp     100h
    4de: mov     rax,[rbp+10h]
    4e2: mov     [rbp-170h],rax
    4e9: mov     rax,[rbp+18h]
    4ed: mov     [rbp-168h],rax
    4f4: mov     rax,[rbp-168h]
    4fb: mov     [rbp-160h],rax
    502: mov     qword ptr [rbp-358h],2
    50d: cmp     qword ptr [rbp-358h],0
    515: sete    [rbp-171h]
    51c: test    byte ptr [rbp-171h],0FFh
    523: je      575h
    525: mov     edi,0FFFFFC80h
    52a: lea     rsi,[k24]
    531: call    ryo_h_AddrAbs
    536: lea     rdi,[sym25]
    53d: lea     rsi,[site26]
    544: mov     edx,0FFFFFCA8h
    549: call    ryo_h_CallExt
    54e: test    rax,rax
    551: je      55Eh
    553: call    rax
    555: nop     [rcx-350h]
    55c: jmp     56Eh
    55e: mov     rdi,rbp
    561: lea     rsi,[ro+4]
    568: call    qword ptr [sym27]
    56e: call    ryo_h_Unreachable
    573: ud2
    575: mov     qword ptr [rbp-358h],2
    580: mov     edi,0FFFFFEA8h
    585: mov     esi,0FFFFFEA0h
    58a: mov     edx,0FFFFFCA8h
    58f: call    ryo_h_DivUW64
    594: mov     rax,[rbp-158h]
    59b: mov     [rbp-190h],rax
    5a2: mov     edi,0FFFFFC80h
    5a7: mov     esi,10h
    5ac: call    ryo_h_MovW128
    5b1: mov     rax,[rbp-190h]
    5b8: mov     [rbp-370h],rax
    5bf: mov     edi,0FFFFFC98h
    5c4: lea     rsi,[k28]
    5cb: call    ryo_h_AddrAbs
    5d0: call    fn29
    5d5: nop     [rcx-188h]
    5dc: mov     edi,0FFFFFC80h
    5e1: mov     esi,0FFFFFE78h
    5e6: call    ryo_h_MovW128
    5eb: mov     rax,[rbp+20h]
    5ef: mov     [rbp-370h],rax
    5f6: call    fn30
    5fb: nop     [rcx-171h]
    602: mov     rax,[rbp-158h]
    609: mov     [rbp-1A8h],rax
    610: mov     edi,0FFFFFC80h
    615: mov     esi,10h
    61a: call    ryo_h_MovW128
    61f: mov     rax,[rbp-1A8h]
    626: mov     [rbp-370h],rax
    62d: mov     edi,0FFFFFC98h
    632: lea     rsi,[k31]
    639: call    ryo_h_AddrAbs
    63e: call    fn32
    643: nop     [rcx-1A0h]
    64a: mov     edi,0FFFFFC80h
    64f: mov     esi,0FFFFFE60h
    654: call    ryo_h_MovW128
    659: mov     rax,[rbp+20h]
    65d: mov     [rbp-370h],rax
    664: call    fn33
    669: nop     [rcx-190h]
    670: mov     rax,[rbp+20h]
    674: mov     [rbp-380h],rax
    67b: call    fn34
    680: nop     [rcx-1A8h]
    687: mov     qword ptr [rbp-1C8h],0
    692: mov     rax,[rbp-158h]
    699: mov     [rbp-1C0h],rax
    6a0: mov     rax,[rbp-1C8h]
    6a7: mov     [rbp-1B0h],rax
    6ae: mov     rax,[rbp-1C0h]
    6b5: mov     [rbp-1B8h],rax
    6bc: nop     [rax]
    6c0: mov     rax,[rbp-1B0h]
    6c7: mov     [rbp-1D8h],rax
    6ce: mov     rax,[rbp-1D8h]
    6d5: cmp     rax,[rbp-158h]
    6dc: jae     0BECh
    6e2: mov     rax,[rbp-1B8h]
    6e9: mov     [rbp-1E8h],rax
    6f0: mov     rax,[rbp+10h]
    6f4: mov     [rbp-200h],rax
    6fb: mov     rax,[rbp+18h]
    6ff: mov     [rbp-1F8h],rax
    706: mov     rax,[rbp-1F8h]
    70d: mov     [rbp-1F0h],rax
    714: mov     rax,[rbp-1E8h]
    71b: cmp     rax,[rbp-1F0h]
    722: jae     0BECh
    728: mov     rax,[rbp-1B0h]
    72f: mov     [rbp-210h],rax
    736: mov     rax,[rbp+10h]
    73a: mov     [rbp-220h],rax
    741: mov     rax,[rbp+18h]
    745: mov     [rbp-218h],rax
    74c: mov     rax,[rbp-218h]
    753: mov     [rbp-228h],rax
    75a: mov     rax,[rbp-210h]
    761: cmp     rax,[rbp-228h]
    768: jb      7D6h
    76a: mov     rax,[rbp-210h]
    771: mov     [rbp-380h],rax
    778: mov     rax,[rbp-228h]
    77f: mov     [rbp-378h],rax
    786: mov     edi,0FFFFFC90h
    78b: lea     rsi,[k35]
    792: call    ryo_h_AddrAbs
    797: lea     rdi,[sym36]
    79e: lea     rsi,[site37]
    7a5: mov     edx,0FFFFFCA8h
    7aa: call    ryo_h_CallExt
    7af: test    rax,rax
    7b2: je      7BFh
    7b4: call    rax
    7b6: nop     [rcx-350h]
    7bd: jmp     7CFh
    7bf: mov     rdi,rbp
    7c2: lea     rsi,[ro+4]
    7c9: call    qword ptr [sym38]
    7cf: call    ryo_h_Unreachable
    7d4: ud2
    7d6: mov     rax,[rbp+10h]
    7da: imul    rcx,[rbp-210h],4
    7e2: add     rax,rcx
    7e5: mov     [rbp-358h],rax
    7ec: mov     rax,[rbp-358h]
    7f3: mov     eax,[rax]
    7f5: mov     [rbp-208h],eax
    7fb: mov     rax,[rbp-1B8h]
    802: mov     [rbp-238h],rax
    809: mov     rax,[rbp+10h]
    80d: mov     [rbp-248h],rax
    814: mov     rax,[rbp+18h]
    818: mov     [rbp-240h],rax
    81f: mov     rax,[rbp-240h]
    826: mov     [rbp-250h],rax
    82d: mov     rax,[rbp-238h]
    834: cmp     rax,[rbp-250h]
    83b: jb      8A9h
    83d: mov     rax,[rbp-238h]
    844: mov     [rbp-380h],rax
    84b: mov     rax,[rbp-250h]
    852: mov     [rbp-378h],rax
    859: mov     edi,0FFFFFC90h
    85e: lea     rsi,[k39]
    865: call    ryo_h_AddrAbs
    86a: lea     rdi,[sym40]
    871: lea     rsi,[site41]
    878: mov     edx,0FFFFFCA8h
    87d: call    ryo_h_CallExt
    882: test    rax,rax
    885: je      892h
    887: call    rax
    889: nop     [rcx-350h]
    890: jmp     8A2h
    892: mov     rdi,rbp
    895: lea     rsi,[ro+4]
    89c: call    qword ptr [sym42]
    8a2: call    ryo_h_Unreachable
    8a7: ud2
    8a9: mov     rax,[rbp+10h]
    8ad: imul    rcx,[rbp-238h],4
    8b5: add     rax,rcx
    8b8: mov     [rbp-358h],rax
    8bf: mov     rax,[rbp-358h]
    8c6: mov     eax,[rax]
    8c8: mov     [rbp-230h],eax
    8ce: mov     eax,[rbp-230h]
    8d4: cmp     eax,[rbp-208h]
    8da: jb      0A66h
    8e0: mov     rax,[rbp-1B0h]
    8e7: mov     [rbp-260h],rax
    8ee: mov     rax,[rbp+10h]
    8f2: mov     [rbp-270h],rax
    8f9: mov     rax,[rbp+18h]
    8fd: mov     [rbp-268h],rax
    904: mov     rax,[rbp-268h]
    90b: mov     [rbp-278h],rax
    912: mov     rax,[rbp-260h]
    919: cmp     rax,[rbp-278h]
    920: jb      98Eh
    922: mov     rax,[rbp-260h]
    929: mov     [rbp-380h],rax
    930: mov     rax,[rbp-278h]
    937: mov     [rbp-378h],rax
    93e: mov     edi,0FFFFFC90h
    943: lea     rsi,[k43]
    94a: call    ryo_h_AddrAbs
    94f: lea     rdi,[sym44]
    956: lea     rsi,[site45]
    95d: mov     edx,0FFFFFCA8h
    962: call    ryo_h_CallExt
    967: test    rax,rax
    96a: je      977h
    96c: call    rax
    96e: nop     [rcx-350h]
    975: jmp     987h
    977: mov     rdi,rbp
    97a: lea     rsi,[ro+4]
    981: call    qword ptr [sym46]
    987: call    ryo_h_Unreachable
    98c: ud2
    98e: mov     rax,[rbp+10h]
    992: imul    rcx,[rbp-260h],4
    99a: add     rax,rcx
    99d: mov     [rbp-358h],rax
    9a4: mov     rax,[rbp-358h]
    9ab: mov     eax,[rax]
    9ad: mov     [rbp-258h],eax
    9b3: mov     rax,[rbp+20h]
    9b7: mov     [rbp-380h],rax
    9be: mov     eax,[rbp-258h]
    9c4: mov     [rbp-378h],eax
    9ca: call    fn47
    9cf: nop     [rcx-251h]
    9d6: mov     qword ptr [rbp-358h],1
    9e1: mov     edi,0FFFFFD70h
    9e6: mov     esi,0FFFFFD78h
    9eb: mov     edx,0FFFFFE50h
    9f0: mov     ecx,0FFFFFCA8h
    9f5: call    ryo_h_AddOvfUW64
    9fa: test    byte ptr [rbp-288h],0FFh
    a01: je      0A53h
    a03: mov     edi,0FFFFFC80h
    a08: lea     rsi,[k48]
    a0f: call    ryo_h_AddrAbs
    a14: lea     rdi,[sym49]
    a1b: lea     rsi,[site50]
    a22: mov     edx,0FFFFFCA8h
    a27: call    ryo_h_CallExt
    a2c: test    rax,rax
    a2f: je      0A3Ch
    a31: call    rax
    a33: nop     [rcx-350h]
    a3a: jmp     0A4Ch
    a3c: mov     rdi,rbp
    a3f: lea     rsi,[ro+4]
    a46: call    qword ptr [sym51]
    a4c: call    ryo_h_Unreachable
    a51: ud2
    a53: mov     rax,[rbp-290h]
    a5a: mov     [rbp-1B0h],rax
    a61: jmp     6C0h
    a66: mov     rax,[rbp-1B8h]
    a6d: mov     [rbp-2A0h],rax
    a74: mov     rax,[rbp+10h]
    a78: mov     [rbp-2B0h],rax
    a7f: mov     rax,[rbp+18h]
    a83: mov     [rbp-2A8h],rax
    a8a: mov     rax,[rbp-2A8h]
    a91: mov     [rbp-2B8h],rax
    a98: mov     rax,[rbp-2A0h]
    a9f: cmp     rax,[rbp-2B8h]
    aa6: jb      0B14h
    aa8: mov     rax,[rbp-2A0h]
    aaf: mov     [rbp-380h],rax
    ab6: mov     rax,[rbp-2B8h]
    abd: mov     [rbp-378h],rax
    ac4: mov     edi,0FFFFFC90h
    ac9: lea     rsi,[k52]
    ad0: call    ryo_h_AddrAbs
    ad5: lea     rdi,[sym53]
    adc: lea     rsi,[site54]
    ae3: mov     edx,0FFFFFCA8h
    ae8: call    ryo_h_CallExt
    aed: test    rax,rax
    af0: je      0AFDh
    af2: call    rax
    af4: nop     [rcx-350h]
    afb: jmp     0B0Dh
    afd: mov     rdi,rbp
    b00: lea     rsi,[ro+4]
    b07: call    qword ptr [sym55]
    b0d: call    ryo_h_Unreachable
    b12: ud2
    b14: mov     rax,[rbp+10h]
    b18: imul    rcx,[rbp-2A0h],4
    b20: add     rax,rcx
    b23: mov     [rbp-358h],rax
    b2a: mov     rax,[rbp-358h]
    b31: mov     eax,[rax]
    b33: mov     [rbp-294h],eax
    b39: mov     rax,[rbp+20h]
    b3d: mov     [rbp-380h],rax
    b44: mov     eax,[rbp-294h]
    b4a: mov     [rbp-378h],eax
    b50: call    fn56
    b55: nop     [rcx-290h]
    b5c: mov     qword ptr [rbp-358h],1
    b67: mov     edi,0FFFFFD30h
    b6c: mov     esi,0FFFFFD38h
    b71: mov     edx,0FFFFFE48h
    b76: mov     ecx,0FFFFFCA8h
    b7b: call    ryo_h_AddOvfUW64
    b80: test    byte ptr [rbp-2C8h],0FFh
    b87: je      0BD9h
    b89: mov     edi,0FFFFFC80h
    b8e: lea     rsi,[k57]
    b95: call    ryo_h_AddrAbs
    b9a: lea     rdi,[sym58]
    ba1: lea     rsi,[site59]
    ba8: mov     edx,0FFFFFCA8h
    bad: call    ryo_h_CallExt
    bb2: test    rax,rax
    bb5: je      0BC2h
    bb7: call    rax
    bb9: nop     [rcx-350h]
    bc0: jmp     0BD2h
    bc2: mov     rdi,rbp
    bc5: lea     rsi,[ro+4]
    bcc: call    qword ptr [sym60]
    bd2: call    ryo_h_Unreachable
    bd7: ud2
    bd9: mov     rax,[rbp-2D0h]
    be0: mov     [rbp-1B8h],rax
    be7: jmp     6C0h
    bec: mov     rax,[rbp+10h]
    bf0: mov     [rbp-2F0h],rax
    bf7: mov     rax,[rbp+18h]
    bfb: mov     [rbp-2E8h],rax
    c02: mov     rax,[rbp-1B0h]
    c09: mov     [rbp-308h],rax
    c10: mov     rax,[rbp-308h]
    c17: mov     [rbp-300h],rax
    c1e: mov     rax,[rbp-158h]
    c25: mov     [rbp-2F8h],rax
    c2c: mov     edi,0FFFFFC80h
    c31: mov     esi,0FFFFFD10h
    c36: call    ryo_h_MovW128
    c3b: mov     edi,0FFFFFC90h
    c40: mov     esi,0FFFFFD00h
    c45: call    ryo_h_MovW128
    c4a: mov     edi,0FFFFFCA0h
    c4f: lea     rsi,[k61]
    c56: call    ryo_h_AddrAbs
    c5b: call    fn62
    c60: nop     [rcx-2E0h]
    c67: mov     rax,[rbp+20h]
    c6b: mov     [rbp-380h],rax
    c72: mov     edi,0FFFFFC88h
    c77: mov     esi,0FFFFFD20h
    c7c: call    ryo_h_MovW128
    c81: call    fn63
    c86: nop     [rcx-2D0h]
    c8d: mov     rax,[rbp+10h]
    c91: mov     [rbp-328h],rax
    c98: mov     rax,[rbp+18h]
    c9c: mov     [rbp-320h],rax
    ca3: mov     rax,[rbp-1B8h]
    caa: mov     [rbp-338h],rax
    cb1: mov     rax,[rbp-338h]
    cb8: mov     [rbp-330h],rax
    cbf: mov     edi,0FFFFFC80h
    cc4: mov     esi,0FFFFFCD8h
    cc9: call    ryo_h_MovW128
    cce: mov     rax,[rbp-330h]
    cd5: mov     [rbp-370h],rax
    cdc: mov     edi,0FFFFFC98h
    ce1: lea     rsi,[k64]
    ce8: call    ryo_h_AddrAbs
    ced: call    fn65
    cf2: nop     [rcx-318h]
    cf9: mov     rax,[rbp+20h]
    cfd: mov     [rbp-380h],rax
    d04: mov     edi,0FFFFFC88h
    d09: mov     esi,0FFFFFCE8h
    d0e: call    ryo_h_MovW128
    d13: call    fn66
    d18: nop     [rcx-308h]
    d1f: mov     rax,[rbp+20h]
    d23: mov     [rbp-350h],rax
    d2a: mov     rax,[rbp-350h]
    d31: mov     [rbp-380h],rax
    d38: call    fn67
    d3d: nop     [rcx-348h]
    d44: mov     edi,0FFFFFC80h
    d49: mov     esi,10h
    d4e: call    ryo_h_MovW128
    d53: mov     edi,0FFFFFC90h
    d58: mov     esi,0FFFFFCB8h
    d5d: call    ryo_h_MovW128
    d62: mov     edi,0FFFFFCA0h
    d67: lea     rsi,[k68]
    d6e: call    ryo_h_AddrAbs
    d73: call    fn69
    d78: nop     [rcx-338h]
    d7f: xor     edi,edi
    d81: xor     esi,esi
    d83: call    ryo_h_Ret
    d88: leave
    d89: ret

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
     2e: cmp     qword ptr [rbp-50h],0
     33: jbe     52h
     35: mov     rax,[rbp+10h]
     39: mov     rax,[rax]
     3c: mov     [rbp-50h],rax
     40: mov     byte ptr [rbp-99h],1
     47: test    byte ptr [rbp-99h],0FFh
     4e: je      0CBh
     50: jmp     98h
     52: mov     edi,0FFFFFFC0h
     57: lea     rsi,[k0]
     5e: mov     edx,10h
     63: call    ryo_h_Const
     68: mov     rax,[rbp+10h]
     6c: lea     rax,[rax+10h]
     70: mov     [rbp-28h],rax
     74: mov     rax,[rbp+18h]
     78: mov     [rbp-20h],rax
     7c: mov     edi,0FFFFFF68h
     81: mov     esi,0FFFFFFD8h
     86: call    ryo_h_MovW128
     8b: mov     qword ptr [rbp-10h],0
     93: jmp     150h
     98: mov     rax,[rbp-50h]
     9c: mov     [rbp-0C0h],rax
     a3: mov     qword ptr [rbp-0B8h],1
     ae: mov     edi,0FFFFFF50h
     b3: lea     rsi,[k1]
     ba: call    ryo_h_AddrAbs
     bf: call    fn2
     c4: nop     [rcx-30h]
     cb: mov     rax,[rbp-50h]
     cf: add     rax,1
     d3: mov     [rbp-58h],rax
     d7: mov     rax,[rbp+10h]
     db: mov     rcx,[rbp-58h]
     df: mov     [rax],rcx
     e2: mov     rax,[rbp-50h]
     e6: mov     [rbp-38h],rax
     ea: mov     qword ptr [rbp-40h],1
     f2: mov     rax,[rbp+10h]
     f6: lea     rax,[rax+10h]
     fa: mov     [rbp-28h],rax
     fe: mov     rax,[rbp+18h]
    102: mov     [rbp-20h],rax
    106: mov     edi,0FFFFFF68h
    10b: mov     esi,0FFFFFFD8h
    110: call    ryo_h_MovW128
    115: mov     rax,[rbp-38h]
    119: mov     [rbp-48h],rax
    11d: mov     edi,0FFFFFF78h
    122: mov     esi,0FFFFFFD8h
    127: call    ryo_h_MovW128
    12c: mov     edi,0FFFFFFA0h
    131: mov     esi,0FFFFFFD8h
    136: call    ryo_h_MovW128
    13b: mov     byte ptr [rbp-99h],1
    142: test    byte ptr [rbp-99h],0FFh
    149: je      19Ch
    14b: jmp     161h
    14d: nop     [rax]
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
    1c3: mov     rax,[rbp-0A0h]
    1ca: mov     [rbp-68h],rax
    1ce: mov     rdi,rbp
    1d1: lea     rsi,[ro+4]
    1d8: call    qword ptr [sym5]
    1de: mov     rax,[rbp-68h]
    1e2: mov     [rbp-70h],rax
    1e6: mov     rax,[rbp-70h]
    1ea: mov     rax,[rax]
    1ed: mov     [rbp-50h],rax
    1f1: mov     rax,[rbp-50h]
    1f5: mov     [rbp-8],rax
    1f9: mov     qword ptr [rbp-10h],1
    201: jmp     150h

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
     48: mov     rax,[rbp-48h]
     4c: mov     [rbp-90h],rax
     53: call    fn1
     58: nop     [rcx-40h]
     5f: mov     edi,0FFFFFF8Ch
     64: mov     esi,0FFFFFFC0h
     69: xor     edx,edx
     6b: xor     ecx,ecx
     6d: xor     r8d,r8d
     70: mov     r9d,1
     76: call    ryo_h_DiscrNicheW64
     7b: mov     edi,0FFFFFFF0h
     80: mov     esi,0FFFFFF8Ch
     85: call    ryo_h_ZextW32W64
     8a: mov     edi,0FFFFFFF0h
     8f: xor     esi,esi
     91: mov     edx,2
     96: call    ryo_h_SwitchDenseW64
     9b: lea     rcx,[0ACh]
     a2: movsxd  rax,[rcx+rax*4]
     a6: add     rax,rcx
     a9: jmp     rax
     ab: int3
     ac: .long   13ch
     b0: .long   bfh
     b4: .long   b8h
     b8: call    ryo_h_Unreachable
     bd: ud2
     bf: mov     rax,[rbp-40h]
     c3: mov     [rbp-50h],rax
     c7: lea     rax,[rbp-50h]
     cb: mov     [rbp-70h],rax
     cf: mov     rax,[rbp-70h]
     d3: mov     [rbp-68h],rax
     d7: mov     edi,0FFFFFFA0h
     dc: lea     rsi,[k2]
     e3: call    ryo_h_AddrAbs
     e8: mov     rax,[rbp+10h]
     ec: mov     [rbp-90h],rax
     f3: mov     edi,0FFFFFF78h
     f8: mov     esi,0FFFFFF98h
     fd: call    ryo_h_MovW128
    102: lea     rdi,[sym3]
    109: lea     rsi,[site4]
    110: mov     edx,0FFFFFF88h
    115: call    ryo_h_CallExt
    11a: test    rax,rax
    11d: je      12Ah
    11f: call    rax
    121: nop     [rcx-58h]
    128: jmp     13Ah
    12a: mov     rdi,rbp
    12d: lea     rsi,[ro+4]
    134: call    qword ptr [sym5]
    13a: jmp     13Eh
    13c: jmp     143h
    13e: jmp     40h
    143: mov     rax,[rbp+10h]
    147: mov     [rbp-8],rax
    14b: mov     edi,0FFFFFFF8h
    150: mov     esi,8
    155: call    ryo_h_Ret
    15a: leave
    15b: ret
    15c: nop     [rax]
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
      f: jne     0F9h
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
     46: mov     rax,[rbp-30h]
     4a: mov     [rbp-28h],rax
     4e: mov     edi,0FFFFFFA8h
     53: lea     rsi,[k1]
     5a: call    ryo_h_AddrAbs
     5f: mov     qword ptr [rbp-50h],0DDh
     67: mov     rax,[rbp-50h]
     6b: mov     [rbp-48h],rax
     6f: mov     rax,[rbp-48h]
     73: shl     rax,1
     77: mov     [rbp-40h],rax
     7b: mov     rax,[rbp-40h]
     7f: or      rax,1
     83: mov     [rbp-38h],rax
     87: mov     rax,[rbp-38h]
     8b: mov     [rbp-30h],rax
     8f: mov     rax,[rbp-28h]
     93: mov     [rbp-20h],rax
     97: mov     rax,[rbp-30h]
     9b: mov     [rbp-18h],rax
     9f: mov     edi,0FFFFFF80h
     a4: mov     esi,0FFFFFFE0h
     a9: call    ryo_h_MovW128
     ae: mov     byte ptr [rbp-70h],0
     b2: mov     rax,[rbp+18h]
     b6: mov     [rbp-68h],rax
     ba: lea     rdi,[sym2]
     c1: lea     rsi,[site3]
     c8: mov     edx,0FFFFFFA0h
     cd: call    ryo_h_CallExt
     d2: test    rax,rax
     d5: je      0E2h
     d7: call    rax
     d9: nop     [rcx-10h]
     e0: jmp     0F2h
     e2: mov     rdi,rbp
     e5: lea     rsi,[ro+4]
     ec: call    qword ptr [sym4]
     f2: call    ryo_h_Unreachable
     f7: ud2
     f9: xor     edi,edi
     fb: xor     esi,esi
     fd: call    ryo_h_Ret
    102: leave
    103: ret

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
     13: mov     rax,[rbp-40h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp+20h]
     27: mov     [rbp-48h],rax
     2b: mov     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     rax,[rbp-40h]
     37: mov     [rbp-38h],rax
     3b: lea     rax,[rbp-30h]
     3f: mov     [rbp-48h],rax
     43: mov     rax,[rbp-48h]
     47: mov     [rbp-40h],rax
     4b: lea     rax,[rbp-38h]
     4f: mov     [rbp-50h],rax
     53: mov     rax,[rbp-50h]
     57: mov     [rbp-48h],rax
     5b: movzx   eax,byte ptr [rbp+18h]
     5f: mov     [rbp-88h],al
     65: mov     rax,[rbp-40h]
     69: mov     [rbp-90h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-80h],rax
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym0]
     88: movzx   eax,byte ptr [rbp+18h]
     8c: mov     [rbp-88h],al
     92: mov     rax,[rbp-48h]
     96: mov     [rbp-90h],rax
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-80h],rax
     a5: mov     rdi,rbp
     a8: lea     rsi,[ro+16]
     af: call    qword ptr [sym1]
     b5: mov     rax,[rbp-50h]
     b9: mov     [rbp-58h],rax
     bd: mov     rax,[rbp-20h]
     c1: mov     [rbp-60h],rax
     c5: mov     rax,[rbp-60h]
     c9: mov     [rbp-90h],rax
     d0: mov     edi,0FFFFFF88h
     d5: lea     rsi,[sym2]
     dc: call    ryo_h_AddrSym
     e1: mov     rdi,rbp
     e4: lea     rsi,[ro+28]
     eb: call    qword ptr [sym3]
     f1: jmp     151h
     f3: nop     [rax+rax]
     fc: nop     [rax]
    100: mov     rdi,rbp
    103: lea     rsi,[ro+16]
    10a: call    qword ptr [sym4]
    110: jmp     19Bh
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: mov     edi,0FFFFFFD8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: nop     [rax]
    130: lea     rax,[rbp-58h]
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-90h],rax
    143: call    fn5
    148: nop     [rcx-78h]
    14f: jmp     120h
    151: mov     rax,[rbp-58h]
    155: mov     [rbp-60h],rax
    159: mov     rax,[rbp-30h]
    15d: mov     [rbp-68h],rax
    161: mov     rax,[rbp-38h]
    165: mov     [rbp-70h],rax
    169: movzx   eax,byte ptr [rbp+18h]
    16d: mov     [rbp-88h],al
    173: mov     rax,[rbp-68h]
    177: mov     [rbp-90h],rax
    17e: mov     rax,[rbp-70h]
    182: mov     [rbp-80h],rax
    186: mov     rdi,rbp
    189: lea     rsi,[ro+44]
    190: call    qword ptr [sym6]
    196: jmp     100h
    19b: mov     rax,[rbp-60h]
    19f: mov     [rbp-8],rax
    1a3: mov     edi,0FFFFFFF8h
    1a8: mov     esi,8
    1ad: call    ryo_h_Ret
    1b2: leave
    1b3: ret
    1b4: nop     [rax+rax]
    1bd: nop     [rax]
    1c0: lea     rdi,[sym7]
    1c7: lea     rsi,[site8]
    1ce: mov     edx,0FFFFFF88h
    1d3: call    ryo_h_CallExt
    1d8: test    rax,rax
    1db: je      1E8h
    1dd: call    rax
    1df: nop     [rcx-70h]
    1e6: jmp     1F8h
    1e8: mov     rdi,rbp
    1eb: lea     rsi,[ro+56]
    1f2: call    qword ptr [sym9]
    1f8: call    ryo_h_Unreachable
    1fd: ud2
    1ff: mov     rdi,rax
    202: mov     esi,0FFFFFFD8h
    207: call    ryo_h_Lpad
    20c: jmp     130h
    211: mov     rdi,rax
    214: mov     esi,0FFFFFFD8h
    219: call    ryo_h_Lpad
    21e: jmp     1C0h

fn std::hint::select_unpredictable::<*const u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-40h],rax
     13: mov     rax,[rbp-40h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp+20h]
     27: mov     [rbp-48h],rax
     2b: mov     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     rax,[rbp-40h]
     37: mov     [rbp-38h],rax
     3b: lea     rax,[rbp-30h]
     3f: mov     [rbp-48h],rax
     43: mov     rax,[rbp-48h]
     47: mov     [rbp-40h],rax
     4b: lea     rax,[rbp-38h]
     4f: mov     [rbp-50h],rax
     53: mov     rax,[rbp-50h]
     57: mov     [rbp-48h],rax
     5b: movzx   eax,byte ptr [rbp+18h]
     5f: mov     [rbp-88h],al
     65: mov     rax,[rbp-40h]
     69: mov     [rbp-90h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-80h],rax
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym0]
     88: movzx   eax,byte ptr [rbp+18h]
     8c: mov     [rbp-88h],al
     92: mov     rax,[rbp-48h]
     96: mov     [rbp-90h],rax
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-80h],rax
     a5: mov     rdi,rbp
     a8: lea     rsi,[ro+16]
     af: call    qword ptr [sym1]
     b5: mov     rax,[rbp-50h]
     b9: mov     [rbp-58h],rax
     bd: mov     rax,[rbp-20h]
     c1: mov     [rbp-60h],rax
     c5: mov     rax,[rbp-60h]
     c9: mov     [rbp-90h],rax
     d0: mov     edi,0FFFFFF88h
     d5: lea     rsi,[sym2]
     dc: call    ryo_h_AddrSym
     e1: mov     rdi,rbp
     e4: lea     rsi,[ro+28]
     eb: call    qword ptr [sym3]
     f1: jmp     151h
     f3: nop     [rax+rax]
     fc: nop     [rax]
    100: mov     rdi,rbp
    103: lea     rsi,[ro+16]
    10a: call    qword ptr [sym4]
    110: jmp     19Bh
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: mov     edi,0FFFFFFD8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: nop     [rax]
    130: lea     rax,[rbp-58h]
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-90h],rax
    143: call    fn5
    148: nop     [rcx-78h]
    14f: jmp     120h
    151: mov     rax,[rbp-58h]
    155: mov     [rbp-60h],rax
    159: mov     rax,[rbp-30h]
    15d: mov     [rbp-68h],rax
    161: mov     rax,[rbp-38h]
    165: mov     [rbp-70h],rax
    169: movzx   eax,byte ptr [rbp+18h]
    16d: mov     [rbp-88h],al
    173: mov     rax,[rbp-68h]
    177: mov     [rbp-90h],rax
    17e: mov     rax,[rbp-70h]
    182: mov     [rbp-80h],rax
    186: mov     rdi,rbp
    189: lea     rsi,[ro+44]
    190: call    qword ptr [sym6]
    196: jmp     100h
    19b: mov     rax,[rbp-60h]
    19f: mov     [rbp-8],rax
    1a3: mov     edi,0FFFFFFF8h
    1a8: mov     esi,8
    1ad: call    ryo_h_Ret
    1b2: leave
    1b3: ret
    1b4: nop     [rax+rax]
    1bd: nop     [rax]
    1c0: lea     rdi,[sym7]
    1c7: lea     rsi,[site8]
    1ce: mov     edx,0FFFFFF88h
    1d3: call    ryo_h_CallExt
    1d8: test    rax,rax
    1db: je      1E8h
    1dd: call    rax
    1df: nop     [rcx-70h]
    1e6: jmp     1F8h
    1e8: mov     rdi,rbp
    1eb: lea     rsi,[ro+56]
    1f2: call    qword ptr [sym9]
    1f8: call    ryo_h_Unreachable
    1fd: ud2
    1ff: mov     rdi,rax
    202: mov     esi,0FFFFFFD8h
    207: call    ryo_h_Lpad
    20c: jmp     130h
    211: mov     rdi,rax
    214: mov     esi,0FFFFFFD8h
    219: call    ryo_h_Lpad
    21e: jmp     1C0h

fn std::hint::select_unpredictable::<*mut u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-40h],rax
     13: mov     rax,[rbp-40h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp+20h]
     27: mov     [rbp-48h],rax
     2b: mov     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     rax,[rbp-40h]
     37: mov     [rbp-38h],rax
     3b: lea     rax,[rbp-30h]
     3f: mov     [rbp-48h],rax
     43: mov     rax,[rbp-48h]
     47: mov     [rbp-40h],rax
     4b: lea     rax,[rbp-38h]
     4f: mov     [rbp-50h],rax
     53: mov     rax,[rbp-50h]
     57: mov     [rbp-48h],rax
     5b: movzx   eax,byte ptr [rbp+18h]
     5f: mov     [rbp-88h],al
     65: mov     rax,[rbp-40h]
     69: mov     [rbp-90h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-80h],rax
     78: mov     rdi,rbp
     7b: lea     rsi,[ro+4]
     82: call    qword ptr [sym0]
     88: movzx   eax,byte ptr [rbp+18h]
     8c: mov     [rbp-88h],al
     92: mov     rax,[rbp-48h]
     96: mov     [rbp-90h],rax
     9d: mov     rax,[rbp-40h]
     a1: mov     [rbp-80h],rax
     a5: mov     rdi,rbp
     a8: lea     rsi,[ro+16]
     af: call    qword ptr [sym1]
     b5: mov     rax,[rbp-50h]
     b9: mov     [rbp-58h],rax
     bd: mov     rax,[rbp-20h]
     c1: mov     [rbp-60h],rax
     c5: mov     rax,[rbp-60h]
     c9: mov     [rbp-90h],rax
     d0: mov     edi,0FFFFFF88h
     d5: lea     rsi,[sym2]
     dc: call    ryo_h_AddrSym
     e1: mov     rdi,rbp
     e4: lea     rsi,[ro+28]
     eb: call    qword ptr [sym3]
     f1: jmp     151h
     f3: nop     [rax+rax]
     fc: nop     [rax]
    100: mov     rdi,rbp
    103: lea     rsi,[ro+16]
    10a: call    qword ptr [sym4]
    110: jmp     19Bh
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: mov     edi,0FFFFFFD8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: nop     [rax]
    130: lea     rax,[rbp-58h]
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-90h],rax
    143: call    fn5
    148: nop     [rcx-78h]
    14f: jmp     120h
    151: mov     rax,[rbp-58h]
    155: mov     [rbp-60h],rax
    159: mov     rax,[rbp-30h]
    15d: mov     [rbp-68h],rax
    161: mov     rax,[rbp-38h]
    165: mov     [rbp-70h],rax
    169: movzx   eax,byte ptr [rbp+18h]
    16d: mov     [rbp-88h],al
    173: mov     rax,[rbp-68h]
    177: mov     [rbp-90h],rax
    17e: mov     rax,[rbp-70h]
    182: mov     [rbp-80h],rax
    186: mov     rdi,rbp
    189: lea     rsi,[ro+44]
    190: call    qword ptr [sym6]
    196: jmp     100h
    19b: mov     rax,[rbp-60h]
    19f: mov     [rbp-8],rax
    1a3: mov     edi,0FFFFFFF8h
    1a8: mov     esi,8
    1ad: call    ryo_h_Ret
    1b2: leave
    1b3: ret
    1b4: nop     [rax+rax]
    1bd: nop     [rax]
    1c0: lea     rdi,[sym7]
    1c7: lea     rsi,[site8]
    1ce: mov     edx,0FFFFFF88h
    1d3: call    ryo_h_CallExt
    1d8: test    rax,rax
    1db: je      1E8h
    1dd: call    rax
    1df: nop     [rcx-70h]
    1e6: jmp     1F8h
    1e8: mov     rdi,rbp
    1eb: lea     rsi,[ro+56]
    1f2: call    qword ptr [sym9]
    1f8: call    ryo_h_Unreachable
    1fd: ud2
    1ff: mov     rdi,rax
    202: mov     esi,0FFFFFFD8h
    207: call    ryo_h_Lpad
    20c: jmp     130h
    211: mov     rdi,rax
    214: mov     esi,0FFFFFFD8h
    219: call    ryo_h_Lpad
    21e: jmp     1C0h

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
     20: jmp     169h
     25: nop     [rax+rax]
     2e: xchg    ax,ax
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-20h],rax
     38: mov     rax,[rbp-20h]
     3c: mov     [rbp-18h],rax
     40: mov     rax,[rbp+18h]
     44: sub     rax,1
     48: mov     [rbp-20h],rax
     4c: mov     rax,[rbp-18h]
     50: and     rax,[rbp-20h]
     54: mov     [rbp-10h],rax
     58: cmp     qword ptr [rbp-10h],0
     5d: sete    [rbp-1]
     61: mov     edi,0FFFFFFFFh
     66: mov     esi,1
     6b: call    ryo_h_Ret
     70: leave
     71: ret
     72: nop     [rax+rax]
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFD8h
     85: lea     rsi,[k0]
     8c: call    ryo_h_AddrAbs
     91: mov     qword ptr [rbp-20h],2Ah
     99: mov     rax,[rbp-28h]
     9d: mov     [rbp-48h],rax
     a1: mov     rax,[rbp-20h]
     a5: mov     [rbp-40h],rax
     a9: mov     rax,[rbp-48h]
     ad: mov     [rbp-38h],rax
     b1: mov     rax,[rbp-38h]
     b5: mov     [rbp-30h],rax
     b9: mov     edi,0FFFFFFA0h
     be: lea     rsi,[k1]
     c5: call    ryo_h_AddrAbs
     ca: mov     qword ptr [rbp-58h],2Ah
     d2: mov     rax,[rbp-58h]
     d6: mov     [rbp-50h],rax
     da: mov     rax,[rbp-50h]
     de: shl     rax,1
     e2: mov     [rbp-48h],rax
     e6: mov     rax,[rbp-48h]
     ea: or      rax,1
     ee: mov     [rbp-40h],rax
     f2: mov     rax,[rbp-40h]
     f6: mov     [rbp-38h],rax
     fa: mov     rax,[rbp-30h]
     fe: mov     [rbp-18h],rax
    102: mov     rax,[rbp-38h]
    106: mov     [rbp-10h],rax
    10a: mov     edi,0FFFFFF80h
    10f: mov     esi,0FFFFFFE8h
    114: call    ryo_h_MovW128
    119: mov     edi,0FFFFFF90h
    11e: lea     rsi,[k2]
    125: call    ryo_h_AddrAbs
    12a: lea     rdi,[sym3]
    131: lea     rsi,[site4]
    138: mov     edx,0FFFFFF98h
    13d: call    ryo_h_CallExt
    142: test    rax,rax
    145: je      152h
    147: call    rax
    149: nop     [rcx-1]
    150: jmp     162h
    152: mov     rdi,rbp
    155: lea     rsi,[ro+4]
    15c: call    qword ptr [sym5]
    162: call    ryo_h_Unreachable
    167: ud2
    169: cmp     dword ptr [rbp-8],1
    16d: sete    [rbp-2]
    171: test    byte ptr [rbp-2],0FFh
    175: je      80h
    17b: jmp     30h

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
     51: mov     rax,[rbp-38h]
     55: mov     [rbp-30h],rax
     59: mov     edi,0FFFFFFA0h
     5e: lea     rsi,[k1]
     65: call    ryo_h_AddrAbs
     6a: mov     qword ptr [rbp-58h],0C9h
     72: mov     rax,[rbp-58h]
     76: mov     [rbp-50h],rax
     7a: mov     rax,[rbp-50h]
     7e: shl     rax,1
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp-48h]
     8a: or      rax,1
     8e: mov     [rbp-40h],rax
     92: mov     rax,[rbp-40h]
     96: mov     [rbp-38h],rax
     9a: mov     rax,[rbp-30h]
     9e: mov     [rbp-28h],rax
     a2: mov     rax,[rbp-38h]
     a6: mov     [rbp-20h],rax
     aa: mov     edi,0FFFFFF70h
     af: mov     esi,0FFFFFFD8h
     b4: call    ryo_h_MovW128
     b9: mov     byte ptr [rbp-80h],0
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-78h],rax
     c5: lea     rdi,[sym2]
     cc: lea     rsi,[site3]
     d3: mov     edx,0FFFFFF98h
     d8: call    ryo_h_CallExt
     dd: test    rax,rax
     e0: je      0EDh
     e2: call    rax
     e4: nop     [rcx-10h]
     eb: jmp     0FDh
     ed: mov     rdi,rbp
     f0: lea     rsi,[ro+4]
     f7: call    qword ptr [sym4]
     fd: call    ryo_h_Unreachable
    102: ud2

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
     2d: jmp     1C3h
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
     91: mov     rax,[rbp-40h]
     95: mov     [rbp-38h],rax
     99: mov     edi,0FFFFFF98h
     9e: lea     rsi,[k2]
     a5: call    ryo_h_AddrAbs
     aa: mov     qword ptr [rbp-60h],0DDh
     b2: mov     rax,[rbp-60h]
     b6: mov     [rbp-58h],rax
     ba: mov     rax,[rbp-58h]
     be: shl     rax,1
     c2: mov     [rbp-50h],rax
     c6: mov     rax,[rbp-50h]
     ca: or      rax,1
     ce: mov     [rbp-48h],rax
     d2: mov     rax,[rbp-48h]
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
    150: test    byte ptr [rbp+28h],0FFh
    154: je      19Ch
    156: jmp     165h
    158: nop     [rax+rax]
    160: jmp     60h
    165: mov     rax,[rbp+18h]
    169: mov     [rbp-28h],rax
    16d: mov     rax,[rbp+20h]
    171: mov     [rbp-30h],rax
    175: mov     rax,[rbp-28h]
    179: mov     [rbp-90h],rax
    180: mov     rax,[rbp+20h]
    184: mov     [rbp-88h],rax
    18b: call    fn6
    190: nop     [rcx-1Bh]
    197: jmp     21Ah
    19c: mov     rax,[rbp+10h]
    1a0: mov     [rbp-28h],rax
    1a4: cmp     qword ptr [rbp-28h],0
    1a9: sete    [rbp-1Bh]
    1ad: movzx   eax,byte ptr [rbp-1Bh]
    1b1: xor     al,1
    1b4: mov     [rbp-19h],al
    1b7: test    byte ptr [rbp-19h],0FFh
    1bb: je      60h
    1c1: jmp     222h
    1c3: test    byte ptr [rbp-1Ah],0FFh
    1c7: je      160h
    1c9: jmp     150h
    1cb: nop     [rax+rax]
    1d0: jmp     50h
    1d5: nop     [rax+rax]
    1de: xchg    ax,ax
    1e0: jmp     40h
    1e5: nop     [rax+rax]
    1ee: xchg    ax,ax
    1f0: mov     rax,[rbp+18h]
    1f4: mov     [rbp-38h],rax
    1f8: cmp     qword ptr [rbp-38h],0
    1fd: sete    [rbp-1Ch]
    201: movzx   eax,byte ptr [rbp-1Ch]
    205: xor     al,1
    208: mov     [rbp-1Ah],al
    20b: test    byte ptr [rbp-1Ah],0FFh
    20f: je      50h
    215: jmp     40h
    21a: test    byte ptr [rbp-1Bh],0FFh
    21e: je      1D0h
    220: jmp     1E0h
    222: mov     rax,[rbp+18h]
    226: mov     [rbp-28h],rax
    22a: mov     rax,[rbp+20h]
    22e: mov     [rbp-30h],rax
    232: mov     rax,[rbp-28h]
    236: mov     [rbp-90h],rax
    23d: mov     rax,[rbp+20h]
    241: mov     [rbp-88h],rax
    248: call    fn7
    24d: nop     [rcx-1Bh]
    254: test    byte ptr [rbp-1Bh],0FFh
    258: je      1D0h
    25e: jmp     1F0h
    260: lea     rdi,[sym8]
    267: lea     rsi,[site9]
    26e: mov     edx,0FFFFFF90h
    273: call    ryo_h_CallExt
    278: test    rax,rax
    27b: je      288h
    27d: call    rax
    27f: nop     [rcx-68h]
    286: jmp     298h
    288: mov     rdi,rbp
    28b: lea     rsi,[ro+20]
    292: call    qword ptr [sym10]
    298: call    ryo_h_Unreachable
    29d: ud2
    29f: mov     rdi,rax
    2a2: mov     esi,0FFFFFFE8h
    2a7: call    ryo_h_Lpad
    2ac: jmp     260h

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
     4a: jmp     214h
     4f: nop
     50: mov     rax,[rbp+18h]
     54: mov     [rbp-10h],rax
     58: mov     rax,[rbp-10h]
     5c: mov     [rbp-0A0h],rax
     63: mov     rax,[rbp+28h]
     67: mov     [rbp-98h],rax
     6e: call    fn1
     73: nop     [rcx-2Ch]
     7a: jmp     264h
     7f: nop
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
     b8: jmp     26Ch
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
    101: mov     rax,[rbp-50h]
    105: mov     [rbp-48h],rax
    109: mov     edi,0FFFFFF88h
    10e: lea     rsi,[k4]
    115: call    ryo_h_AddrAbs
    11a: mov     qword ptr [rbp-70h],11Bh
    122: mov     rax,[rbp-70h]
    126: mov     [rbp-68h],rax
    12a: mov     rax,[rbp-68h]
    12e: shl     rax,1
    132: mov     [rbp-60h],rax
    136: mov     rax,[rbp-60h]
    13a: or      rax,1
    13e: mov     [rbp-58h],rax
    142: mov     rax,[rbp-58h]
    146: mov     [rbp-50h],rax
    14a: mov     rax,[rbp-48h]
    14e: mov     [rbp-40h],rax
    152: mov     rax,[rbp-50h]
    156: mov     [rbp-38h],rax
    15a: mov     edi,0FFFFFF60h
    15f: mov     esi,0FFFFFFC0h
    164: call    ryo_h_MovW128
    169: mov     byte ptr [rbp-90h],0
    170: mov     rax,[rbp+38h]
    174: mov     [rbp-88h],rax
    17b: lea     rdi,[sym5]
    182: lea     rsi,[site6]
    189: mov     edx,0FFFFFF80h
    18e: call    ryo_h_CallExt
    193: test    rax,rax
    196: je      1A3h
    198: call    rax
    19a: nop     [rcx-20h]
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
    1d0: test    byte ptr [rbp-2Bh],0FFh
    1d4: je      1EAh
    1d6: jmp     1E5h
    1d8: nop     [rax+rax]
    1e0: jmp     0D0h
    1e5: jmp     50h
    1ea: mov     rax,[rbp+10h]
    1ee: mov     [rbp-38h],rax
    1f2: cmp     qword ptr [rbp-38h],0
    1f7: sete    [rbp-2Dh]
    1fb: movzx   eax,byte ptr [rbp-2Dh]
    1ff: xor     al,1
    202: mov     [rbp-2Ah],al
    205: test    byte ptr [rbp-2Ah],0FFh
    209: je      0D0h
    20f: jmp     50h
    214: test    byte ptr [rbp-2Ch],0FFh
    218: je      1E0h
    21a: jmp     1D0h
    21c: nop     [rax]
    220: test    byte ptr [rbp-1],0FFh
    224: je      23Ah
    226: jmp     235h
    228: nop     [rax+rax]
    230: jmp     0C0h
    235: jmp     80h
    23a: mov     rax,[rbp+18h]
    23e: mov     [rbp-38h],rax
    242: cmp     qword ptr [rbp-38h],0
    247: sete    [rbp-2Dh]
    24b: movzx   eax,byte ptr [rbp-2Dh]
    24f: xor     al,1
    252: mov     [rbp-2Bh],al
    255: test    byte ptr [rbp-2Bh],0FFh
    259: je      0C0h
    25f: jmp     80h
    264: test    byte ptr [rbp-2Ch],0FFh
    268: je      230h
    26a: jmp     220h
    26c: test    byte ptr [rbp-29h],0FFh
    270: je      0D0h
    276: jmp     1C0h
    27b: nop     [rax+rax]
    280: lea     rdi,[sym8]
    287: lea     rsi,[site9]
    28e: mov     edx,0FFFFFF80h
    293: call    ryo_h_CallExt
    298: test    rax,rax
    29b: je      2A8h
    29d: call    rax
    29f: nop     [rcx-78h]
    2a6: jmp     2B8h
    2a8: mov     rdi,rbp
    2ab: lea     rsi,[ro+20]
    2b2: call    qword ptr [sym10]
    2b8: call    ryo_h_Unreachable
    2bd: ud2
    2bf: mov     rdi,rax
    2c2: mov     esi,0FFFFFFD8h
    2c7: call    ryo_h_Lpad
    2cc: jmp     280h

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<(u32, u32)>> - shim(Some(alloc::raw_vec::RawVec<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u32>> - shim(Some(alloc::raw_vec::RawVec<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<core::slice::sort::stable::merge::MergeState<(u32, u32)>> - shim(Some(core::slice::sort::stable::merge::MergeState<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<core::slice::sort::unstable::quicksort::GapGuardRaw<u32>> - shim(Some(core::slice::sort::unstable::quicksort::GapGuardRaw<u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<std::array::IntoIter<usize, 2>> - shim(Some(std::array::IntoIter<usize, 2>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*mut u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*mut u32>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<std::vec::Vec<(u32, u32)>> - shim(Some(std::vec::Vec<(u32, u32)>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-20h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: jmp     6Eh
     26: nop     [rax+rax]
     2f: nop
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
     58: mov     rax,[rbp-18h]
     5c: mov     [rbp-20h],rax
     60: call    fn1
     65: nop     [rcx-18h]
     6c: jmp     40h
     6e: mov     rax,[rbp+10h]
     72: mov     [rbp-18h],rax
     76: mov     rax,[rbp-18h]
     7a: mov     [rbp-20h],rax
     7e: call    fn2
     83: nop     [rcx-18h]
     8a: jmp     30h
     8c: nop     [rax]
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
     10: mov     rax,[rbp-8]
     14: mov     [rbp-20h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: jmp     6Eh
     26: nop     [rax+rax]
     2f: nop
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
     58: mov     rax,[rbp-18h]
     5c: mov     [rbp-20h],rax
     60: call    fn1
     65: nop     [rcx-18h]
     6c: jmp     40h
     6e: mov     rax,[rbp+10h]
     72: mov     [rbp-18h],rax
     76: mov     rax,[rbp-18h]
     7a: mov     [rbp-20h],rax
     7e: call    fn2
     83: nop     [rcx-18h]
     8a: jmp     30h
     8c: nop     [rax]
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
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::swap::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: lea     rax,[rbp-24h]
     17: mov     [rbp-18h],rax
     1b: mov     rax,[rbp-18h]
     1f: mov     [rbp-38h],rax
     23: mov     byte ptr [rbp-49h],1
     27: test    byte ptr [rbp-49h],0FFh
     2b: je      88h
     2d: mov     rax,[rbp+10h]
     31: mov     [rbp-40h],rax
     35: mov     rax,[rbp-18h]
     39: mov     [rbp-48h],rax
     3d: mov     rax,[rbp-40h]
     41: mov     [rbp-90h],rax
     48: mov     rax,[rbp-48h]
     4c: mov     [rbp-88h],rax
     53: mov     qword ptr [rbp-80h],4
     5b: mov     qword ptr [rbp-78h],4
     63: mov     qword ptr [rbp-70h],1
     6b: mov     edi,0FFFFFF98h
     70: lea     rsi,[k0]
     77: call    ryo_h_AddrAbs
     7c: call    fn1
     81: nop     [rcx-18h]
     88: mov     qword ptr [rbp-50h],1
     90: imul    rax,[rbp-50h],4
     95: mov     [rbp-58h],rax
     99: mov     edi,0FFFFFFC8h
     9e: mov     esi,0FFFFFFD0h
     a3: mov     edx,0FFFFFFA8h
     a8: call    ryo_h_Memcpy
     ad: mov     rax,[rbp+18h]
     b1: mov     [rbp-30h],rax
     b5: mov     byte ptr [rbp-49h],1
     b9: test    byte ptr [rbp-49h],0FFh
     bd: je      159h
     c3: jmp     0F3h
     c5: nop     [rax+rax]
     ce: xchg    ax,ax
     d0: lea     rax,[rbp-24h]
     d4: mov     [rbp-20h],rax
     d8: mov     rax,[rbp-20h]
     dc: mov     [rbp-30h],rax
     e0: mov     byte ptr [rbp-49h],1
     e4: test    byte ptr [rbp-49h],0FFh
     e8: je      1DEh
     ee: jmp     183h
     f3: mov     rax,[rbp+18h]
     f7: mov     [rbp-38h],rax
     fb: mov     rax,[rbp+10h]
     ff: mov     [rbp-40h],rax
    103: mov     byte ptr [rbp-49h],0
    107: test    byte ptr [rbp-49h],0FFh
    10b: je      113h
    10d: mov     byte ptr [rbp-25h],1
    111: jmp     117h
    113: mov     byte ptr [rbp-25h],0
    117: mov     rax,[rbp-38h]
    11b: mov     [rbp-90h],rax
    122: mov     rax,[rbp-40h]
    126: mov     [rbp-88h],rax
    12d: mov     qword ptr [rbp-80h],4
    135: movzx   eax,byte ptr [rbp-25h]
    139: mov     [rbp-78h],al
    13c: mov     edi,0FFFFFF90h
    141: lea     rsi,[k2]
    148: call    ryo_h_AddrAbs
    14d: call    fn3
    152: nop     [rcx-18h]
    159: mov     qword ptr [rbp-50h],1
    161: imul    rax,[rbp-50h],4
    166: mov     [rbp-58h],rax
    16a: mov     edi,10h
    16f: mov     esi,0FFFFFFD0h
    174: mov     edx,0FFFFFFA8h
    179: call    ryo_h_Memmove
    17e: jmp     0D0h
    183: mov     rax,[rbp-20h]
    187: mov     [rbp-38h],rax
    18b: mov     rax,[rbp+18h]
    18f: mov     [rbp-40h],rax
    193: mov     rax,[rbp-38h]
    197: mov     [rbp-90h],rax
    19e: mov     rax,[rbp-40h]
    1a2: mov     [rbp-88h],rax
    1a9: mov     qword ptr [rbp-80h],4
    1b1: mov     qword ptr [rbp-78h],4
    1b9: mov     qword ptr [rbp-70h],1
    1c1: mov     edi,0FFFFFF98h
    1c6: lea     rsi,[k4]
    1cd: call    ryo_h_AddrAbs
    1d2: call    fn5
    1d7: nop     [rcx-20h]
    1de: mov     qword ptr [rbp-50h],1
    1e6: imul    rax,[rbp-50h],4
    1eb: mov     [rbp-58h],rax
    1ef: mov     edi,18h
    1f4: mov     esi,0FFFFFFD0h
    1f9: mov     edx,0FFFFFFA8h
    1fe: call    ryo_h_Memcpy
    203: xor     edi,edi
    205: xor     esi,esi
    207: call    ryo_h_Ret
    20c: leave
    20d: ret

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
     52: jmp     224h
     57: nop     [rax+rax]
     60: mov     rax,[rbp+18h]
     64: mov     [rbp-18h],rax
     68: mov     rax,[rbp-18h]
     6c: mov     [rbp-0B0h],rax
     73: mov     rax,[rbp+28h]
     77: mov     [rbp-0A8h],rax
     7e: call    fn1
     83: nop     [rcx-34h]
     8a: jmp     274h
     8f: nop
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
     c8: jmp     27Ch
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
    111: mov     rax,[rbp-58h]
    115: mov     [rbp-50h],rax
    119: mov     edi,0FFFFFF80h
    11e: lea     rsi,[k4]
    125: call    ryo_h_AddrAbs
    12a: mov     qword ptr [rbp-78h],11Bh
    132: mov     rax,[rbp-78h]
    136: mov     [rbp-70h],rax
    13a: mov     rax,[rbp-70h]
    13e: shl     rax,1
    142: mov     [rbp-68h],rax
    146: mov     rax,[rbp-68h]
    14a: or      rax,1
    14e: mov     [rbp-60h],rax
    152: mov     rax,[rbp-60h]
    156: mov     [rbp-58h],rax
    15a: mov     rax,[rbp-50h]
    15e: mov     [rbp-48h],rax
    162: mov     rax,[rbp-58h]
    166: mov     [rbp-40h],rax
    16a: mov     edi,0FFFFFF50h
    16f: mov     esi,0FFFFFFB8h
    174: call    ryo_h_MovW128
    179: mov     byte ptr [rbp-0A0h],0
    180: mov     rax,[rbp+38h]
    184: mov     [rbp-98h],rax
    18b: lea     rdi,[sym5]
    192: lea     rsi,[site6]
    199: mov     edx,0FFFFFF78h
    19e: call    ryo_h_CallExt
    1a3: test    rax,rax
    1a6: je      1B3h
    1a8: call    rax
    1aa: nop     [rcx-28h]
    1b1: jmp     1C3h
    1b3: mov     rdi,rbp
    1b6: lea     rsi,[ro+4]
    1bd: call    qword ptr [sym7]
    1c3: call    ryo_h_Unreachable
    1c8: ud2
    1ca: nop     [rax+rax]
    1d0: xor     edi,edi
    1d2: xor     esi,esi
    1d4: call    ryo_h_Ret
    1d9: leave
    1da: ret
    1db: nop     [rax+rax]
    1e0: test    byte ptr [rbp-33h],0FFh
    1e4: je      1FAh
    1e6: jmp     1F5h
    1e8: nop     [rax+rax]
    1f0: jmp     0E0h
    1f5: jmp     60h
    1fa: mov     rax,[rbp+10h]
    1fe: mov     [rbp-40h],rax
    202: cmp     qword ptr [rbp-40h],0
    207: sete    [rbp-35h]
    20b: movzx   eax,byte ptr [rbp-35h]
    20f: xor     al,1
    212: mov     [rbp-32h],al
    215: test    byte ptr [rbp-32h],0FFh
    219: je      0E0h
    21f: jmp     60h
    224: test    byte ptr [rbp-34h],0FFh
    228: je      1F0h
    22a: jmp     1E0h
    22c: nop     [rax]
    230: test    byte ptr [rbp-1],0FFh
    234: je      24Ah
    236: jmp     245h
    238: nop     [rax+rax]
    240: jmp     0D0h
    245: jmp     90h
    24a: mov     rax,[rbp+18h]
    24e: mov     [rbp-40h],rax
    252: cmp     qword ptr [rbp-40h],0
    257: sete    [rbp-35h]
    25b: movzx   eax,byte ptr [rbp-35h]
    25f: xor     al,1
    262: mov     [rbp-33h],al
    265: test    byte ptr [rbp-33h],0FFh
    269: je      0D0h
    26f: jmp     90h
    274: test    byte ptr [rbp-34h],0FFh
    278: je      240h
    27a: jmp     230h
    27c: test    byte ptr [rbp-31h],0FFh
    280: je      0E0h
    286: jmp     1D0h
    28b: nop     [rax+rax]
    290: lea     rdi,[sym8]
    297: lea     rsi,[site9]
    29e: mov     edx,0FFFFFF78h
    2a3: call    ryo_h_CallExt
    2a8: test    rax,rax
    2ab: je      2B8h
    2ad: call    rax
    2af: nop     [rcx-80h]
    2b6: jmp     2C8h
    2b8: mov     rdi,rbp
    2bb: lea     rsi,[ro+20]
    2c2: call    qword ptr [sym10]
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     rdi,rax
    2d2: mov     esi,0FFFFFFD0h
    2d7: call    ryo_h_Lpad
    2dc: jmp     290h

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
     1b: mov     rax,[rbp-30h]
     1f: mov     [rbp-8],rax
     23: nop     [rax+rax]
     2c: nop     [rax]
     30: mov     rax,[rbp-10h]
     34: mov     [rbp-50h],rax
     38: mov     rax,[rbp-8]
     3c: mov     [rbp-58h],rax
     40: mov     rax,[rbp-50h]
     44: cmp     rax,[rbp-58h]
     48: setb    [rbp-41h]
     4c: test    byte ptr [rbp-41h],0FFh
     50: je      76h
     52: jmp     62h
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: jmp     30h
     62: mov     rax,[rbp-10h]
     66: mov     [rbp-50h],rax
     6a: mov     byte ptr [rbp-69h],1
     6e: test    byte ptr [rbp-69h],0FFh
     72: je      0B4h
     74: jmp     81h
     76: xor     edi,edi
     78: xor     esi,esi
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: mov     rax,[rbp-50h]
     85: mov     [rbp-90h],rax
     8c: mov     qword ptr [rbp-88h],1
     97: mov     edi,0FFFFFF80h
     9c: lea     rsi,[k0]
     a3: call    ryo_h_AddrAbs
     a8: call    fn1
     ad: nop     [rcx-28h]
     b4: mov     rax,[rbp-50h]
     b8: add     rax,1
     bc: mov     [rbp-58h],rax
     c0: mov     rax,[rbp-58h]
     c4: mov     [rbp-10h],rax
     c8: mov     rax,[rbp-50h]
     cc: mov     [rbp-38h],rax
     d0: mov     qword ptr [rbp-40h],1
     d8: mov     rax,[rbp-38h]
     dc: mov     [rbp-48h],rax
     e0: mov     rax,[rbp+10h]
     e4: imul    rcx,[rbp-48h],8
     e9: add     rax,rcx
     ec: mov     [rbp-58h],rax
     f0: mov     rax,[rbp-58h]
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp+18h]
     fc: imul    rcx,[rbp-48h],8
    101: add     rax,rcx
    104: mov     [rbp-68h],rax
    108: mov     rax,[rbp-68h]
    10c: mov     [rbp-60h],rax
    110: mov     rax,[rbp-50h]
    114: mov     [rbp-90h],rax
    11b: mov     rax,[rbp-60h]
    11f: mov     [rbp-88h],rax
    126: call    fn2
    12b: nop     [rcx-18h]
    132: jmp     60h

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-20h],rax
     10: mov     qword ptr [rbp-28h],0
     18: mov     rax,[rbp-20h]
     1c: and     rax,4
     20: mov     [rbp-30h],rax
     24: cmp     qword ptr [rbp-30h],0
     29: je      0A5h
     2b: mov     rax,[rbp-28h]
     2f: mov     [rbp-48h],rax
     33: mov     rax,[rbp+10h]
     37: imul    rcx,[rbp-48h],1
     3c: add     rax,rcx
     3f: mov     [rbp-40h],rax
     43: mov     rax,[rbp-40h]
     47: mov     [rbp-38h],rax
     4b: mov     rax,[rbp-38h]
     4f: mov     [rbp-30h],rax
     53: mov     rax,[rbp-28h]
     57: mov     [rbp-58h],rax
     5b: mov     rax,[rbp+18h]
     5f: imul    rcx,[rbp-58h],1
     64: add     rax,rcx
     67: mov     [rbp-50h],rax
     6b: mov     rax,[rbp-50h]
     6f: mov     [rbp-48h],rax
     73: mov     rax,[rbp-48h]
     77: mov     [rbp-40h],rax
     7b: mov     rax,[rbp-30h]
     7f: mov     [rbp-70h],rax
     83: mov     rax,[rbp-40h]
     87: mov     [rbp-68h],rax
     8b: call    fn0
     90: nop     [rcx]
     97: mov     rax,[rbp-28h]
     9b: or      rax,4
     9f: mov     [rbp-28h],rax
     a3: jmp     0A5h
     a5: mov     rax,[rbp-20h]
     a9: and     rax,2
     ad: mov     [rbp-30h],rax
     b1: cmp     qword ptr [rbp-30h],0
     b6: je      132h
     b8: mov     rax,[rbp-28h]
     bc: mov     [rbp-48h],rax
     c0: mov     rax,[rbp+10h]
     c4: imul    rcx,[rbp-48h],1
     c9: add     rax,rcx
     cc: mov     [rbp-40h],rax
     d0: mov     rax,[rbp-40h]
     d4: mov     [rbp-38h],rax
     d8: mov     rax,[rbp-38h]
     dc: mov     [rbp-30h],rax
     e0: mov     rax,[rbp-28h]
     e4: mov     [rbp-58h],rax
     e8: mov     rax,[rbp+18h]
     ec: imul    rcx,[rbp-58h],1
     f1: add     rax,rcx
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp-50h]
     fc: mov     [rbp-48h],rax
    100: mov     rax,[rbp-48h]
    104: mov     [rbp-40h],rax
    108: mov     rax,[rbp-30h]
    10c: mov     [rbp-70h],rax
    110: mov     rax,[rbp-40h]
    114: mov     [rbp-68h],rax
    118: call    fn1
    11d: nop     [rcx]
    124: mov     rax,[rbp-28h]
    128: or      rax,2
    12c: mov     [rbp-28h],rax
    130: jmp     132h
    132: mov     rax,[rbp-20h]
    136: and     rax,1
    13a: mov     [rbp-30h],rax
    13e: cmp     qword ptr [rbp-30h],0
    143: je      1BFh
    145: mov     rax,[rbp-28h]
    149: mov     [rbp-48h],rax
    14d: mov     rax,[rbp+10h]
    151: imul    rcx,[rbp-48h],1
    156: add     rax,rcx
    159: mov     [rbp-40h],rax
    15d: mov     rax,[rbp-40h]
    161: mov     [rbp-38h],rax
    165: mov     rax,[rbp-38h]
    169: mov     [rbp-30h],rax
    16d: mov     rax,[rbp-28h]
    171: mov     [rbp-58h],rax
    175: mov     rax,[rbp+18h]
    179: imul    rcx,[rbp-58h],1
    17e: add     rax,rcx
    181: mov     [rbp-50h],rax
    185: mov     rax,[rbp-50h]
    189: mov     [rbp-48h],rax
    18d: mov     rax,[rbp-48h]
    191: mov     [rbp-40h],rax
    195: mov     rax,[rbp-30h]
    199: mov     [rbp-70h],rax
    19d: mov     rax,[rbp-40h]
    1a1: mov     [rbp-68h],rax
    1a5: call    fn2
    1aa: nop     [rcx]
    1b1: mov     rax,[rbp-28h]
    1b5: or      rax,1
    1b9: mov     [rbp-28h],rax
    1bd: jmp     1BFh
    1bf: xor     edi,edi
    1c1: xor     esi,esi
    1c3: call    ryo_h_Ret
    1c8: leave
    1c9: ret

fn std::rt::lang_start::<()>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rax,[rbp-28h]
     14: mov     [rbp-20h],rax
     18: mov     rax,[rbp-20h]
     1c: mov     [rbp-18h],rax
     20: mov     edi,0FFFFFFF0h
     25: lea     rsi,[k0]
     2c: call    ryo_h_AddrAbs
     31: mov     edi,0FFFFFFA0h
     36: mov     esi,0FFFFFFE8h
     3b: call    ryo_h_MovW128
     40: mov     rax,[rbp+18h]
     44: mov     [rbp-50h],rax
     48: mov     rax,[rbp+20h]
     4c: mov     [rbp-48h],rax
     50: movzx   eax,byte ptr [rbp+28h]
     54: mov     [rbp-40h],al
     57: lea     rdi,[sym1]
     5e: lea     rsi,[site2]
     65: mov     edx,0FFFFFFD0h
     6a: call    ryo_h_CallExt
     6f: test    rax,rax
     72: je      7Fh
     74: call    rax
     76: nop     [rcx-8]
     7d: jmp     8Fh
     7f: mov     rdi,rbp
     82: lea     rsi,[ro+4]
     89: call    qword ptr [sym3]
     8f: mov     edi,0FFFFFFF8h
     94: mov     esi,8
     99: call    ryo_h_Ret
     9e: leave
     9f: ret

fn std::rt::lang_start::<()>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp-10h]
     17: mov     [rbp-20h],rax
     1b: call    fn0
     20: nop     [rcx-4]
     27: call    fn1
     2c: nop     [rcx-5]
     33: movzx   eax,byte ptr [rbp-5]
     37: mov     [rbp-6],al
     3a: mov     edi,0FFFFFFFCh
     3f: mov     esi,0FFFFFFFAh
     44: call    ryo_h_ZextW8W32
     49: mov     edi,0FFFFFFFCh
     4e: mov     esi,4
     53: call    ryo_h_Ret
     58: leave
     59: ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: lea     rax,[rbp+20h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-10h],rax
     18: mov     edi,0FFFFFFD0h
     1d: mov     esi,10h
     22: call    ryo_h_MovW128
     27: mov     rax,[rbp-10h]
     2b: mov     [rbp-20h],rax
     2f: call    fn0
     34: nop     [rcx]
     3b: xor     edi,edi
     3d: xor     esi,esi
     3f: call    ryo_h_Ret
     44: leave
     45: ret
     46: nop     [rax+rax]
     4f: nop
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
     17: mov     rax,[rbp-40h]
     1b: mov     [rbp-38h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+10h]
     27: mov     [rbp-40h],rax
     2b: mov     rax,[rbp-38h]
     2f: imul    rcx,[rbp-40h],8
     34: add     rax,rcx
     37: mov     [rbp-30h],rax
     3b: mov     rax,[rbp-30h]
     3f: mov     [rbp-28h],rax
     43: mov     qword ptr [rbp-50h],8
     4b: cmp     qword ptr [rbp-50h],0
     50: je      84h
     52: jmp     8Eh
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: mov     rax,[rbp+10h]
     64: mov     rax,[rax+10h]
     68: mov     [rbp-48h],rax
     6c: mov     rax,[rbp-40h]
     70: sub     rax,[rbp-48h]
     74: mov     [rbp-38h],rax
     78: mov     byte ptr [rbp-49h],1
     7c: test    byte ptr [rbp-49h],0FFh
     80: je      0E8h
     82: jmp     0A3h
     84: mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
     8c: jmp     60h
     8e: mov     rax,[rbp+10h]
     92: mov     rax,[rax]
     95: mov     [rbp-48h],rax
     99: mov     rax,[rbp-48h]
     9d: mov     [rbp-40h],rax
     a1: jmp     60h
     a3: mov     rax,[rbp-30h]
     a7: mov     [rbp-40h],rax
     ab: mov     rax,[rbp-40h]
     af: mov     [rbp-80h],rax
     b3: mov     qword ptr [rbp-78h],8
     bb: mov     qword ptr [rbp-70h],4
     c3: mov     rax,[rbp-38h]
     c7: mov     [rbp-68h],rax
     cb: mov     edi,0FFFFFFA0h
     d0: lea     rsi,[k0]
     d7: call    ryo_h_AddrAbs
     dc: call    fn1
     e1: nop     [rcx-20h]
     e8: mov     rax,[rbp-30h]
     ec: mov     [rbp-48h],rax
     f0: mov     rax,[rbp-38h]
     f4: mov     [rbp-40h],rax
     f8: mov     rax,[rbp-48h]
     fc: mov     [rbp-10h],rax
    100: mov     rax,[rbp-40h]
    104: mov     [rbp-8],rax
    108: mov     edi,0FFFFFFF0h
    10d: mov     esi,10h
    112: call    ryo_h_Ret
    117: leave
    118: ret

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
     16: mov     rax,[rbp-18h]
     1a: mov     [rbp-28h],rax
     1e: mov     byte ptr [rbp-61h],0
     22: test    byte ptr [rbp-61h],0FFh
     26: je      3Eh
     28: mov     rax,[rbp+10h]
     2c: mov     rax,[rax+8]
     30: mov     [rbp-30h],rax
     34: mov     rax,[rbp-30h]
     38: mov     [rbp-20h],rax
     3c: jmp     90h
     3e: mov     rax,[rbp+10h]
     42: mov     rax,[rax+8]
     46: mov     [rbp-38h],rax
     4a: mov     rax,[rbp-38h]
     4e: mov     [rbp-30h],rax
     52: mov     rax,[rbp+10h]
     56: mov     rax,[rax]
     59: mov     [rbp-38h],rax
     5d: mov     rax,[rbp-30h]
     61: mov     [rbp-40h],rax
     65: mov     rax,[rbp-38h]
     69: mov     [rbp-48h],rax
     6d: mov     rax,[rbp-30h]
     71: mov     [rbp-50h],rax
     75: mov     byte ptr [rbp-61h],1
     79: test    byte ptr [rbp-61h],0FFh
     7d: je      0F5h
     7f: jmp     0B2h
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     byte ptr [rbp-61h],1
     94: test    byte ptr [rbp-61h],0FFh
     98: je      213h
     9e: jmp     1C8h
     a3: nop     [rax+rax]
     ac: nop     [rax]
     b0: jmp     90h
     b2: mov     rax,[rbp-30h]
     b6: mov     [rbp-58h],rax
     ba: mov     rax,[rbp-38h]
     be: mov     [rbp-60h],rax
     c2: mov     rax,[rbp-58h]
     c6: mov     [rbp-90h],rax
     cd: mov     rax,[rbp-60h]
     d1: mov     [rbp-88h],rax
     d8: mov     edi,0FFFFFF80h
     dd: lea     rsi,[k0]
     e4: call    ryo_h_AddrAbs
     e9: call    fn1
     ee: nop     [rcx-20h]
     f5: mov     qword ptr [rbp-68h],0
     fd: cmp     qword ptr [rbp-68h],4
    102: setb    [rbp-51h]
    106: test    byte ptr [rbp-51h],0FFh
    10a: je      15Ch
    10c: mov     qword ptr [rbp-68h],4
    114: mov     rax,[rbp-68h]
    118: mov     rcx,7FFFFFFFFFFFFFFFh
    122: cmp     rax,rcx
    125: setbe   [rbp-52h]
    129: test    byte ptr [rbp-52h],0FFh
    12d: je      15Ch
    12f: mov     rax,[rbp-50h]
    133: sub     rax,[rbp-48h]
    137: mov     [rbp-20h],rax
    13b: mov     qword ptr [rbp-68h],4
    143: mov     edi,0FFFFFFE0h
    148: mov     esi,0FFFFFFE0h
    14d: mov     edx,0FFFFFF98h
    152: call    ryo_h_DivUW64
    157: jmp     0B0h
    15c: mov     edi,0FFFFFF70h
    161: lea     rsi,[k2]
    168: call    ryo_h_AddrAbs
    16d: mov     qword ptr [rbp-88h],49h
    178: mov     edi,0FFFFFF80h
    17d: lea     rsi,[k3]
    184: call    ryo_h_AddrAbs
    189: lea     rdi,[sym4]
    190: lea     rsi,[site5]
    197: mov     edx,0FFFFFF98h
    19c: call    ryo_h_CallExt
    1a1: test    rax,rax
    1a4: je      1B1h
    1a6: call    rax
    1a8: nop     [rcx-20h]
    1af: jmp     1C1h
    1b1: mov     rdi,rbp
    1b4: lea     rsi,[ro+4]
    1bb: call    qword ptr [sym6]
    1c1: call    ryo_h_Unreachable
    1c6: ud2
    1c8: mov     rax,[rbp-18h]
    1cc: mov     [rbp-30h],rax
    1d0: mov     rax,[rbp-30h]
    1d4: mov     [rbp-90h],rax
    1db: mov     qword ptr [rbp-88h],4
    1e6: mov     qword ptr [rbp-80h],4
    1ee: mov     rax,[rbp-20h]
    1f2: mov     [rbp-78h],rax
    1f6: mov     edi,0FFFFFF90h
    1fb: lea     rsi,[k7]
    202: call    ryo_h_AddrAbs
    207: call    fn8
    20c: nop     [rcx-20h]
    213: mov     rax,[rbp-28h]
    217: mov     [rbp-38h],rax
    21b: mov     rax,[rbp-20h]
    21f: mov     [rbp-30h],rax
    223: mov     rax,[rbp-38h]
    227: mov     [rbp-10h],rax
    22b: mov     rax,[rbp-30h]
    22f: mov     [rbp-8],rax
    233: mov     edi,0FFFFFFF0h
    238: mov     esi,10h
    23d: call    ryo_h_Ret
    242: leave
    243: ret

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
     46: mov     rax,[rbp-40h]
     4a: mov     [rbp-28h],rax
     4e: mov     byte ptr [rbp-51h],0
     52: test    byte ptr [rbp-51h],0FFh
     56: je      62h
     58: mov     rax,[rbp-20h]
     5c: mov     [rbp-18h],rax
     60: jmp     82h
     62: mov     rax,[rbp-28h]
     66: mov     [rbp-38h],rax
     6a: mov     rax,[rbp-38h]
     6e: imul    rcx,[rbp-20h],4
     73: add     rax,rcx
     76: mov     [rbp-30h],rax
     7a: mov     rax,[rbp-30h]
     7e: mov     [rbp-18h],rax
     82: mov     rax,[rbp-28h]
     86: mov     [rbp-10h],rax
     8a: mov     rax,[rbp-18h]
     8e: mov     [rbp-8],rax
     92: mov     edi,0FFFFFFF0h
     97: mov     esi,10h
     9c: call    ryo_h_Ret
     a1: leave
     a2: ret

fn std::slice::from_raw_parts::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     rax,[rbp-28h]
     17: mov     [rbp-90h],rax
     1e: mov     rax,[rbp+20h]
     22: mov     [rbp-88h],rax
     29: call    fn0
     2e: nop     [rcx-1Ah]
     35: jmp     195h
     3a: nop     [rax+rax]
     40: cmp     qword ptr [rbp+18h],0
     45: je      19Dh
     4b: jmp     1A7h
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
     a1: mov     rax,[rbp-40h]
     a5: mov     [rbp-38h],rax
     a9: mov     edi,0FFFFFF98h
     ae: lea     rsi,[k2]
     b5: call    ryo_h_AddrAbs
     ba: mov     qword ptr [rbp-60h],117h
     c2: mov     rax,[rbp-60h]
     c6: mov     [rbp-58h],rax
     ca: mov     rax,[rbp-58h]
     ce: shl     rax,1
     d2: mov     [rbp-50h],rax
     d6: mov     rax,[rbp-50h]
     da: or      rax,1
     de: mov     [rbp-48h],rax
     e2: mov     rax,[rbp-48h]
     e6: mov     [rbp-40h],rax
     ea: mov     rax,[rbp-38h]
     ee: mov     [rbp-30h],rax
     f2: mov     rax,[rbp-40h]
     f6: mov     [rbp-28h],rax
     fa: mov     edi,0FFFFFF70h
     ff: mov     esi,0FFFFFFD0h
    104: call    ryo_h_MovW128
    109: mov     byte ptr [rbp-80h],0
    10d: mov     rax,[rbp+30h]
    111: mov     [rbp-78h],rax
    115: lea     rdi,[sym3]
    11c: lea     rsi,[site4]
    123: mov     edx,0FFFFFF90h
    128: call    ryo_h_CallExt
    12d: test    rax,rax
    130: je      13Dh
    132: call    rax
    134: nop     [rcx-10h]
    13b: jmp     14Dh
    13d: mov     rdi,rbp
    140: lea     rsi,[ro+4]
    147: call    qword ptr [sym5]
    14d: call    ryo_h_Unreachable
    152: ud2
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     rax,[rbp+10h]
    164: mov     [rbp-30h],rax
    168: cmp     qword ptr [rbp-30h],0
    16d: sete    [rbp-1Bh]
    171: movzx   eax,byte ptr [rbp-1Bh]
    175: xor     al,1
    178: mov     [rbp-19h],al
    17b: test    byte ptr [rbp-19h],0FFh
    17f: je      70h
    185: jmp     40h
    18a: nop     [rax+rax]
    190: jmp     70h
    195: test    byte ptr [rbp-1Ah],0FFh
    199: je      190h
    19b: jmp     160h
    19d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    1a5: jmp     1C9h
    1a7: mov     rax,7FFFFFFFFFFFFFFFh
    1b1: mov     [rbp-70h],rax
    1b5: mov     edi,0FFFFFFD8h
    1ba: mov     esi,0FFFFFF90h
    1bf: mov     edx,18h
    1c4: call    ryo_h_DivUW64
    1c9: mov     rax,[rbp+28h]
    1cd: cmp     rax,[rbp-28h]
    1d1: setbe   [rbp-1Ah]
    1d5: test    byte ptr [rbp-1Ah],0FFh
    1d9: je      60h
    1df: jmp     50h
    1e4: nop     [rax+rax]
    1ed: nop     [rax]
    1f0: lea     rdi,[sym6]
    1f7: lea     rsi,[site7]
    1fe: mov     edx,0FFFFFF90h
    203: call    ryo_h_CallExt
    208: test    rax,rax
    20b: je      218h
    20d: call    rax
    20f: nop     [rcx-68h]
    216: jmp     228h
    218: mov     rdi,rbp
    21b: lea     rsi,[ro+20]
    222: call    qword ptr [sym8]
    228: call    ryo_h_Unreachable
    22d: ud2
    22f: mov     rdi,rax
    232: mov     esi,0FFFFFFE8h
    237: call    ryo_h_Lpad
    23c: jmp     1F0h

fn std::slice::from_raw_parts_mut::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     rax,[rbp-28h]
     17: mov     [rbp-90h],rax
     1e: mov     rax,[rbp+20h]
     22: mov     [rbp-88h],rax
     29: call    fn0
     2e: nop     [rcx-1Ah]
     35: jmp     195h
     3a: nop     [rax+rax]
     40: cmp     qword ptr [rbp+18h],0
     45: je      19Dh
     4b: jmp     1A7h
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
     a1: mov     rax,[rbp-40h]
     a5: mov     [rbp-38h],rax
     a9: mov     edi,0FFFFFF98h
     ae: lea     rsi,[k2]
     b5: call    ryo_h_AddrAbs
     ba: mov     qword ptr [rbp-60h],11Bh
     c2: mov     rax,[rbp-60h]
     c6: mov     [rbp-58h],rax
     ca: mov     rax,[rbp-58h]
     ce: shl     rax,1
     d2: mov     [rbp-50h],rax
     d6: mov     rax,[rbp-50h]
     da: or      rax,1
     de: mov     [rbp-48h],rax
     e2: mov     rax,[rbp-48h]
     e6: mov     [rbp-40h],rax
     ea: mov     rax,[rbp-38h]
     ee: mov     [rbp-30h],rax
     f2: mov     rax,[rbp-40h]
     f6: mov     [rbp-28h],rax
     fa: mov     edi,0FFFFFF70h
     ff: mov     esi,0FFFFFFD0h
    104: call    ryo_h_MovW128
    109: mov     byte ptr [rbp-80h],0
    10d: mov     rax,[rbp+30h]
    111: mov     [rbp-78h],rax
    115: lea     rdi,[sym3]
    11c: lea     rsi,[site4]
    123: mov     edx,0FFFFFF90h
    128: call    ryo_h_CallExt
    12d: test    rax,rax
    130: je      13Dh
    132: call    rax
    134: nop     [rcx-10h]
    13b: jmp     14Dh
    13d: mov     rdi,rbp
    140: lea     rsi,[ro+4]
    147: call    qword ptr [sym5]
    14d: call    ryo_h_Unreachable
    152: ud2
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     rax,[rbp+10h]
    164: mov     [rbp-30h],rax
    168: cmp     qword ptr [rbp-30h],0
    16d: sete    [rbp-1Bh]
    171: movzx   eax,byte ptr [rbp-1Bh]
    175: xor     al,1
    178: mov     [rbp-19h],al
    17b: test    byte ptr [rbp-19h],0FFh
    17f: je      70h
    185: jmp     40h
    18a: nop     [rax+rax]
    190: jmp     70h
    195: test    byte ptr [rbp-1Ah],0FFh
    199: je      190h
    19b: jmp     160h
    19d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    1a5: jmp     1C9h
    1a7: mov     rax,7FFFFFFFFFFFFFFFh
    1b1: mov     [rbp-70h],rax
    1b5: mov     edi,0FFFFFFD8h
    1ba: mov     esi,0FFFFFF90h
    1bf: mov     edx,18h
    1c4: call    ryo_h_DivUW64
    1c9: mov     rax,[rbp+28h]
    1cd: cmp     rax,[rbp-28h]
    1d1: setbe   [rbp-1Ah]
    1d5: test    byte ptr [rbp-1Ah],0FFh
    1d9: je      60h
    1df: jmp     50h
    1e4: nop     [rax+rax]
    1ed: nop     [rax]
    1f0: lea     rdi,[sym6]
    1f7: lea     rsi,[site7]
    1fe: mov     edx,0FFFFFF90h
    203: call    ryo_h_CallExt
    208: test    rax,rax
    20b: je      218h
    20d: call    rax
    20f: nop     [rcx-68h]
    216: jmp     228h
    218: mov     rdi,rbp
    21b: lea     rsi,[ro+20]
    222: call    qword ptr [sym8]
    228: call    ryo_h_Unreachable
    22d: ud2
    22f: mov     rdi,rax
    232: mov     esi,0FFFFFFE8h
    237: call    ryo_h_Lpad
    23c: jmp     1F0h

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
     4a: cmp     qword ptr [rbp-18h],2
     4f: setb    [rbp-19h]
     53: test    byte ptr [rbp-19h],0FFh
     57: je      74h
     59: jmp     72h
     5b: nop     [rax+rax]
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
     17: mov     rax,[rbp-68h]
     1b: mov     [rbp-100h],rax
     22: call    fn0
     27: nop     [rcx-90h]
     2e: mov     rax,[rbp-90h]
     35: mov     [rbp-68h],rax
     39: mov     edi,0FFFFFF88h
     3e: mov     esi,0FFFFFF78h
     43: call    ryo_h_MovW128
     48: mov     rax,[rbp-78h]
     4c: mov     [rbp-8],rax
     50: mov     edi,0FFFFFFF8h
     55: xor     esi,esi
     57: mov     edx,2
     5c: call    ryo_h_SwitchDenseW64
     61: lea     rcx,[74h]
     68: movsxd  rax,[rcx+rax*4]
     6c: add     rax,rcx
     6f: jmp     rax
     71: int3
     72: int3
     73: int3
     74: .long   16dh
     78: .long   80h
     7c: .long   2c8h
     80: mov     rax,[rbp-70h]
     84: mov     [rbp-80h],rax
     88: mov     rax,[rbp+10h]
     8c: mov     [rbp-100h],rax
     93: mov     rax,[rbp-80h]
     97: mov     [rbp-0F8h],rax
     9e: call    fn1
     a3: nop     [rcx-48h]
     aa: mov     rax,[rbp+10h]
     ae: mov     rax,[rax+8]
     b2: mov     [rbp-90h],rax
     b9: mov     rax,[rbp-90h]
     c0: mov     [rbp-88h],rax
     c7: mov     rax,[rbp+10h]
     cb: lea     rax,[rax+10h]
     cf: mov     [rbp-0A0h],rax
     d6: mov     rax,[rbp-0A0h]
     dd: mov     rax,[rax]
     e0: mov     [rbp-0A8h],rax
     e7: mov     rax,[rbp-0A0h]
     ee: mov     [rbp-98h],rax
     f5: mov     rax,[rbp-0A8h]
     fc: mov     [rbp-90h],rax
    103: mov     byte ptr [rbp-49h],0
    107: mov     edi,0FFFFFF58h
    10c: mov     esi,18h
    111: call    ryo_h_MovW128
    116: mov     rax,[rbp-88h]
    11d: mov     [rbp-0B0h],rax
    124: mov     edi,0FFFFFF40h
    129: mov     esi,0FFFFFF68h
    12e: call    ryo_h_MovW128
    133: mov     edi,0FFFFFF00h
    138: mov     esi,0FFFFFF58h
    13d: call    ryo_h_MovW128
    142: mov     edi,0FFFFFF10h
    147: mov     esi,0FFFFFF40h
    14c: mov     edx,18h
    151: call    ryo_h_Copy
    156: call    fn2
    15b: nop     [rcx-48h]
    162: xor     edi,edi
    164: xor     esi,esi
    166: call    ryo_h_Ret
    16b: leave
    16c: ret
    16d: mov     edi,0FFFFFF68h
    172: lea     rsi,[k3]
    179: call    ryo_h_AddrAbs
    17e: mov     qword ptr [rbp-90h],11h
    189: mov     rax,[rbp-98h]
    190: mov     [rbp-0B8h],rax
    197: mov     rax,[rbp-90h]
    19e: mov     [rbp-0B0h],rax
    1a5: mov     rax,[rbp-0B8h]
    1ac: mov     [rbp-0A8h],rax
    1b3: mov     rax,[rbp-0A8h]
    1ba: mov     [rbp-0A0h],rax
    1c1: mov     edi,0FFFFFF30h
    1c6: lea     rsi,[k4]
    1cd: call    ryo_h_AddrAbs
    1d2: mov     qword ptr [rbp-0C8h],11h
    1dd: mov     rax,[rbp-0C8h]
    1e4: mov     [rbp-0C0h],rax
    1eb: mov     rax,[rbp-0C0h]
    1f2: shl     rax,1
    1f6: mov     [rbp-0B8h],rax
    1fd: mov     rax,[rbp-0B8h]
    204: or      rax,1
    208: mov     [rbp-0B0h],rax
    20f: mov     rax,[rbp-0B0h]
    216: mov     [rbp-0A8h],rax
    21d: mov     rax,[rbp-0A0h]
    224: mov     [rbp-88h],rax
    22b: mov     rax,[rbp-0A8h]
    232: mov     [rbp-80h],rax
    236: mov     edi,0FFFFFF00h
    23b: mov     esi,0FFFFFF78h
    240: call    ryo_h_MovW128
    245: mov     edi,0FFFFFF10h
    24a: lea     rsi,[k5]
    251: call    ryo_h_AddrAbs
    256: lea     rdi,[sym6]
    25d: lea     rsi,[site7]
    264: mov     edx,0FFFFFF28h
    269: call    ryo_h_CallExt
    26e: test    rax,rax
    271: je      27Eh
    273: call    rax
    275: nop     [rcx-48h]
    27c: jmp     28Eh
    27e: mov     rdi,rbp
    281: lea     rsi,[ro+4]
    288: call    qword ptr [sym8]
    28e: call    ryo_h_Unreachable
    293: ud2
    295: nop     [rax+rax]
    29e: xchg    ax,ax
    2a0: mov     edi,0FFFFFFA0h
    2a5: call    ryo_h_Resume
    2aa: ud2
    2ac: nop     [rax]
    2b0: jmp     2A0h
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
    2c0: test    byte ptr [rbp-49h],0FFh
    2c4: je      2A0h
    2c6: jmp     2B0h
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     rdi,rax
    2d2: mov     esi,0FFFFFFA0h
    2d7: call    ryo_h_Lpad
    2dc: jmp     2C0h

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
     30: mov     rax,[rbp-8]
     34: mov     rcx,[rbp+18h]
     38: mov     [rax],rcx
     3b: mov     rax,[rbp+10h]
     3f: mov     rax,[rax+8]
     43: mov     [rbp-20h],rax
     47: mov     rax,[rbp-20h]
     4b: add     rax,1
     4f: mov     [rbp-30h],rax
     53: mov     rax,[rbp+10h]
     57: mov     rcx,[rbp-30h]
     5b: mov     [rax+8],rcx
     5f: xor     edi,edi
     61: xor     esi,esi
     63: call    ryo_h_Ret
     68: leave
     69: ret

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
     3d: cmp     qword ptr [rbp-50h],0
     42: je      0F3h
     48: jmp     0FDh
     4d: nop     [rax]
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
     dc: mov     rax,[rbp-40h]
     e0: cmp     rax,[rbp+18h]
     e4: setb    [rbp-31h]
     e8: test    byte ptr [rbp-31h],0FFh
     ec: je      0C0h
     ee: jmp     50h
     f3: mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
     fb: jmp     0D0h
     fd: mov     rax,[rbp-20h]
    101: mov     rax,[rax]
    104: mov     [rbp-58h],rax
    108: mov     rax,[rbp-58h]
    10c: mov     [rbp-48h],rax
    110: jmp     0D0h

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
     51: mov     rax,[rbp-38h]
     55: mov     [rbp-30h],rax
     59: mov     edi,0FFFFFFA0h
     5e: lea     rsi,[k1]
     65: call    ryo_h_AddrAbs
     6a: mov     qword ptr [rbp-58h],0C6h
     72: mov     rax,[rbp-58h]
     76: mov     [rbp-50h],rax
     7a: mov     rax,[rbp-50h]
     7e: shl     rax,1
     82: mov     [rbp-48h],rax
     86: mov     rax,[rbp-48h]
     8a: or      rax,1
     8e: mov     [rbp-40h],rax
     92: mov     rax,[rbp-40h]
     96: mov     [rbp-38h],rax
     9a: mov     rax,[rbp-30h]
     9e: mov     [rbp-28h],rax
     a2: mov     rax,[rbp-38h]
     a6: mov     [rbp-20h],rax
     aa: mov     edi,0FFFFFF70h
     af: mov     esi,0FFFFFFD8h
     b4: call    ryo_h_MovW128
     b9: mov     byte ptr [rbp-80h],0
     bd: mov     rax,[rbp+20h]
     c1: mov     [rbp-78h],rax
     c5: lea     rdi,[sym2]
     cc: lea     rsi,[site3]
     d3: mov     edx,0FFFFFF98h
     d8: call    ryo_h_CallExt
     dd: test    rax,rax
     e0: je      0EDh
     e2: call    rax
     e4: nop     [rcx-10h]
     eb: jmp     0FDh
     ed: mov     rdi,rbp
     f0: lea     rsi,[ro+4]
     f7: call    qword ptr [sym4]
     fd: call    ryo_h_Unreachable
    102: ud2

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
     3b: mov     rax,[rbp-10h]
     3f: mov     rcx,1FFFFFFFFFFFFFFFh
     49: cmp     rax,rcx
     4c: setbe   [rbp-11h]
     50: cmp     qword ptr [rbp-8],0
     55: jbe     0A0h
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-20h],rax
     5f: mov     rax,[rbp+10h]
     63: mov     rax,[rax+8]
     67: mov     [rbp-38h],rax
     6b: mov     rax,[rbp-38h]
     6f: mov     [rbp-30h],rax
     73: mov     rax,[rbp-30h]
     77: imul    rcx,[rbp-10h],4
     7c: add     rax,rcx
     7f: mov     [rbp-28h],rax
     83: mov     byte ptr [rbp-39h],1
     87: test    byte ptr [rbp-39h],0FFh
     8b: je      124h
     91: jmp     0CFh
     93: nop     [rax+rax]
     9c: nop     [rax]
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+10h]
     a8: mov     [rbp-40h],rax
     ac: mov     rax,[rbp-40h]
     b0: add     rax,[rbp-8]
     b4: mov     [rbp-50h],rax
     b8: mov     rax,[rbp+10h]
     bc: mov     rcx,[rbp-50h]
     c0: mov     [rax+10h],rcx
     c4: xor     edi,edi
     c6: xor     esi,esi
     c8: call    ryo_h_Ret
     cd: leave
     ce: ret
     cf: mov     rax,[rbp+18h]
     d3: mov     [rbp-30h],rax
     d7: mov     rax,[rbp-28h]
     db: mov     [rbp-38h],rax
     df: mov     rax,[rbp-30h]
     e3: mov     [rbp-80h],rax
     e7: mov     rax,[rbp-38h]
     eb: mov     [rbp-78h],rax
     ef: mov     qword ptr [rbp-70h],4
     f7: mov     qword ptr [rbp-68h],4
     ff: mov     rax,[rbp-8]
    103: mov     [rbp-60h],rax
    107: mov     edi,0FFFFFFA8h
    10c: lea     rsi,[k1]
    113: call    ryo_h_AddrAbs
    118: call    fn2
    11d: nop     [rcx-8]
    124: imul    rax,[rbp-8],4
    129: mov     [rbp-40h],rax
    12d: mov     edi,0FFFFFFD8h
    132: mov     esi,0FFFFFFE0h
    137: mov     edx,0FFFFFFC0h
    13c: call    ryo_h_Memcpy
    141: jmp     0A0h

fn std::vec::Vec::<u32>::clear
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     rax,[rbp-20h]
     18: mov     [rbp-18h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-20h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-10h],rax
     30: mov     rax,[rbp-20h]
     34: mov     [rbp-8],rax
     38: mov     qword ptr [rbp-30h],0
     40: mov     rax,[rbp+10h]
     44: mov     rcx,[rbp-30h]
     48: mov     [rax+10h],rcx
     4c: mov     rax,[rbp-10h]
     50: mov     [rbp-20h],rax
     54: mov     rax,[rbp-8]
     58: mov     [rbp-18h],rax
     5c: mov     edi,0FFFFFFC0h
     61: mov     esi,0FFFFFFE0h
     66: call    ryo_h_MovW128
     6b: mov     edi,0FFFFFFD8h
     70: lea     rsi,[sym0]
     77: call    ryo_h_AddrSym
     7c: mov     rdi,rbp
     7f: lea     rsi,[ro+4]
     86: call    qword ptr [sym1]
     8c: xor     edi,edi
     8e: xor     esi,esi
     90: call    ryo_h_Ret
     95: leave
     96: ret

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
     46: mov     rax,[rbp-40h]
     4a: mov     [rbp-20h],rax
     4e: mov     byte ptr [rbp-51h],0
     52: test    byte ptr [rbp-51h],0FFh
     56: je      75h
     58: jmp     6Bh
     5a: nop     [rax+rax]
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: mov     rax,[rbp-18h]
     6f: mov     [rbp-38h],rax
     73: jmp     95h
     75: mov     rax,[rbp-20h]
     79: mov     [rbp-30h],rax
     7d: mov     rax,[rbp-30h]
     81: imul    rcx,[rbp-18h],4
     86: add     rax,rcx
     89: mov     [rbp-28h],rax
     8d: mov     rax,[rbp-28h]
     91: mov     [rbp-38h],rax
     95: mov     rax,[rbp-20h]
     99: mov     [rbp-10h],rax
     9d: mov     rax,[rbp-38h]
     a1: mov     [rbp-8],rax
     a5: mov     rax,[rbp+10h]
     a9: mov     [rbp-70h],rax
     ad: mov     edi,0FFFFFF98h
     b2: mov     esi,0FFFFFFF0h
     b7: call    ryo_h_MovW128
     bc: call    fn0
     c1: nop     [rcx]
     c8: jmp     60h

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     byte ptr [rbp-49h],1
      f: lea     rax,[rbp+18h]
     13: mov     [rbp-68h],rax
     17: mov     rax,[rbp-68h]
     1b: mov     [rbp-110h],rax
     22: call    fn0
     27: nop     [rcx-90h]
     2e: mov     rax,[rbp-90h]
     35: mov     [rbp-68h],rax
     39: mov     edi,0FFFFFF88h
     3e: mov     esi,0FFFFFF78h
     43: call    ryo_h_MovW128
     48: mov     rax,[rbp-78h]
     4c: mov     [rbp-8],rax
     50: mov     edi,0FFFFFFF8h
     55: xor     esi,esi
     57: mov     edx,2
     5c: call    ryo_h_SwitchDenseW64
     61: lea     rcx,[74h]
     68: movsxd  rax,[rcx+rax*4]
     6c: add     rax,rcx
     6f: jmp     rax
     71: int3
     72: int3
     73: int3
     74: .long   177h
     78: .long   80h
     7c: .long   2c8h
     80: mov     rax,[rbp-70h]
     84: mov     [rbp-80h],rax
     88: mov     rax,[rbp+10h]
     8c: mov     [rbp-110h],rax
     93: mov     rax,[rbp-80h]
     97: mov     [rbp-108h],rax
     9e: call    fn1
     a3: nop     [rcx-48h]
     aa: mov     rax,[rbp+10h]
     ae: mov     rax,[rax+8]
     b2: mov     [rbp-90h],rax
     b9: mov     rax,[rbp-90h]
     c0: mov     [rbp-88h],rax
     c7: mov     rax,[rbp+10h]
     cb: lea     rax,[rax+10h]
     cf: mov     [rbp-0A0h],rax
     d6: mov     rax,[rbp-0A0h]
     dd: mov     rax,[rax]
     e0: mov     [rbp-0A8h],rax
     e7: mov     rax,[rbp-0A0h]
     ee: mov     [rbp-98h],rax
     f5: mov     rax,[rbp-0A8h]
     fc: mov     [rbp-90h],rax
    103: mov     byte ptr [rbp-49h],0
    107: mov     edi,0FFFFFF50h
    10c: mov     esi,18h
    111: mov     edx,18h
    116: call    ryo_h_Copy
    11b: mov     rax,[rbp-88h]
    122: mov     [rbp-0B8h],rax
    129: mov     edi,0FFFFFF38h
    12e: mov     esi,0FFFFFF68h
    133: call    ryo_h_MovW128
    138: mov     edi,0FFFFFEF0h
    13d: mov     esi,0FFFFFF50h
    142: mov     edx,18h
    147: call    ryo_h_Copy
    14c: mov     edi,0FFFFFF08h
    151: mov     esi,0FFFFFF38h
    156: mov     edx,18h
    15b: call    ryo_h_Copy
    160: call    fn2
    165: nop     [rcx-48h]
    16c: xor     edi,edi
    16e: xor     esi,esi
    170: call    ryo_h_Ret
    175: leave
    176: ret
    177: mov     edi,0FFFFFF68h
    17c: lea     rsi,[k3]
    183: call    ryo_h_AddrAbs
    188: mov     qword ptr [rbp-90h],11h
    193: mov     rax,[rbp-98h]
    19a: mov     [rbp-0B8h],rax
    1a1: mov     rax,[rbp-90h]
    1a8: mov     [rbp-0B0h],rax
    1af: mov     rax,[rbp-0B8h]
    1b6: mov     [rbp-0A8h],rax
    1bd: mov     rax,[rbp-0A8h]
    1c4: mov     [rbp-0A0h],rax
    1cb: mov     edi,0FFFFFF30h
    1d0: lea     rsi,[k4]
    1d7: call    ryo_h_AddrAbs
    1dc: mov     qword ptr [rbp-0C8h],11h
    1e7: mov     rax,[rbp-0C8h]
    1ee: mov     [rbp-0C0h],rax
    1f5: mov     rax,[rbp-0C0h]
    1fc: shl     rax,1
    200: mov     [rbp-0B8h],rax
    207: mov     rax,[rbp-0B8h]
    20e: or      rax,1
    212: mov     [rbp-0B0h],rax
    219: mov     rax,[rbp-0B0h]
    220: mov     [rbp-0A8h],rax
    227: mov     rax,[rbp-0A0h]
    22e: mov     [rbp-88h],rax
    235: mov     rax,[rbp-0A8h]
    23c: mov     [rbp-80h],rax
    240: mov     edi,0FFFFFEF0h
    245: mov     esi,0FFFFFF78h
    24a: call    ryo_h_MovW128
    24f: mov     edi,0FFFFFF00h
    254: lea     rsi,[k5]
    25b: call    ryo_h_AddrAbs
    260: lea     rdi,[sym6]
    267: lea     rsi,[site7]
    26e: mov     edx,0FFFFFF28h
    273: call    ryo_h_CallExt
    278: test    rax,rax
    27b: je      288h
    27d: call    rax
    27f: nop     [rcx-48h]
    286: jmp     298h
    288: mov     rdi,rbp
    28b: lea     rsi,[ro+4]
    292: call    qword ptr [sym8]
    298: call    ryo_h_Unreachable
    29d: ud2
    29f: nop
    2a0: mov     edi,0FFFFFFA0h
    2a5: call    ryo_h_Resume
    2aa: ud2
    2ac: nop     [rax]
    2b0: jmp     2A0h
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
    2c0: test    byte ptr [rbp-49h],0FFh
    2c4: je      2A0h
    2c6: jmp     2B0h
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     rdi,rax
    2d2: mov     esi,0FFFFFFA0h
    2d7: call    ryo_h_Lpad
    2dc: jmp     2C0h

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
     30: mov     rax,[rbp-8]
     34: mov     ecx,[rbp+18h]
     37: mov     [rax],ecx
     39: mov     rax,[rbp+10h]
     3d: mov     rax,[rax+8]
     41: mov     [rbp-20h],rax
     45: mov     rax,[rbp-20h]
     49: add     rax,1
     4d: mov     [rbp-30h],rax
     51: mov     rax,[rbp+10h]
     55: mov     rcx,[rbp-30h]
     59: mov     [rax+8],rcx
     5d: xor     edi,edi
     5f: xor     esi,esi
     61: call    ryo_h_Ret
     66: leave
     67: ret

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
     21: je      0F3h
     27: jmp     0FDh
     2c: nop     [rax]
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-40h],rax
     38: mov     rax,[rbp-40h]
     3c: mov     [rbp-60h],rax
     40: call    fn0
     45: nop     [rcx-10h]
     4c: jmp     50h
     4e: xchg    ax,ax
     50: mov     rax,[rbp+10h]
     54: mov     rax,[rax+8]
     58: mov     [rbp-40h],rax
     5c: mov     rax,[rbp-40h]
     60: mov     [rbp-38h],rax
     64: mov     rax,[rbp-38h]
     68: imul    rcx,[rbp-30h],4
     6d: add     rax,rcx
     70: mov     [rbp-18h],rax
     74: mov     eax,[rbp+18h]
     77: mov     [rbp-34h],eax
     7a: mov     rax,[rbp-18h]
     7e: mov     ecx,[rbp-34h]
     81: mov     [rax],ecx
     83: mov     rax,[rbp-30h]
     87: add     rax,1
     8b: mov     [rbp-50h],rax
     8f: mov     rax,[rbp+10h]
     93: mov     rcx,[rbp-50h]
     97: mov     [rax+10h],rcx
     9b: mov     rax,[rbp-18h]
     9f: mov     [rbp-8],rax
     a3: mov     edi,0FFFFFFF8h
     a8: mov     esi,8
     ad: call    ryo_h_Ret
     b2: leave
     b3: ret
     b4: nop     [rax+rax]
     bd: nop     [rax]
     c0: mov     edi,0FFFFFFD8h
     c5: call    ryo_h_Resume
     ca: ud2
     cc: nop     [rax]
     d0: jmp     0C0h
     d2: nop     [rax+rax]
     db: nop     [rax+rax]
     e0: mov     rax,[rbp-30h]
     e4: cmp     rax,[rbp-40h]
     e8: je      30h
     ee: jmp     50h
     f3: mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
     fb: jmp     0E0h
     fd: mov     rax,[rbp+10h]
    101: mov     rax,[rax]
    104: mov     [rbp-48h],rax
    108: mov     rax,[rbp-48h]
    10c: mov     [rbp-40h],rax
    110: jmp     0E0h
    112: mov     rdi,rax
    115: mov     esi,0FFFFFFD8h
    11a: call    ryo_h_Lpad
    11f: jmp     0D0h

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
     3d: cmp     qword ptr [rbp-50h],0
     42: je      0F3h
     48: jmp     0FDh
     4d: nop     [rax]
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
     dc: mov     rax,[rbp-40h]
     e0: cmp     rax,[rbp+18h]
     e4: setb    [rbp-31h]
     e8: test    byte ptr [rbp-31h],0FFh
     ec: je      0C0h
     ee: jmp     50h
     f3: mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
     fb: jmp     0D0h
     fd: mov     rax,[rbp-20h]
    101: mov     rax,[rax]
    104: mov     [rbp-58h],rax
    108: mov     rax,[rbp-58h]
    10c: mov     [rbp-48h],rax
    110: jmp     0D0h

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
     17: mov     rax,[rbp-48h]
     1b: mov     [rbp-40h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+10h]
     27: mov     [rbp-20h],rax
     2b: mov     rax,[rbp-40h]
     2f: mov     [rbp-18h],rax
     33: mov     rax,[rbp-20h]
     37: mov     [rbp-10h],rax
     3b: mov     rax,[rbp+18h]
     3f: mov     rax,[rax+8]
     43: mov     [rbp-48h],rax
     47: mov     rax,[rbp-48h]
     4b: mov     [rbp-40h],rax
     4f: mov     rax,[rbp+18h]
     53: mov     rax,[rax+10h]
     57: mov     [rbp-38h],rax
     5b: mov     rax,[rbp-40h]
     5f: mov     [rbp-30h],rax
     63: mov     rax,[rbp-38h]
     67: mov     [rbp-28h],rax
     6b: mov     rax,[rbp-20h]
     6f: cmp     rax,[rbp-38h]
     73: jne     0CBh
     75: mov     rax,[rbp-18h]
     79: mov     [rbp-58h],rax
     7d: mov     rax,[rbp-10h]
     81: mov     [rbp-50h],rax
     85: mov     rax,[rbp-58h]
     89: mov     [rbp-48h],rax
     8d: mov     rax,[rbp-30h]
     91: mov     [rbp-60h],rax
     95: mov     rax,[rbp-28h]
     99: mov     [rbp-58h],rax
     9d: mov     rax,[rbp-60h]
     a1: mov     [rbp-50h],rax
     a5: mov     rax,[rbp-48h]
     a9: mov     [rbp-80h],rax
     ad: mov     rax,[rbp-50h]
     b1: mov     [rbp-78h],rax
     b5: mov     rax,[rbp-20h]
     b9: mov     [rbp-70h],rax
     bd: call    fn0
     c2: nop     [rcx-1]
     c9: jmp     0CFh
     cb: mov     byte ptr [rbp-1],0
     cf: mov     edi,0FFFFFFFFh
     d4: mov     esi,1
     d9: call    ryo_h_Ret
     de: leave
     df: ret

