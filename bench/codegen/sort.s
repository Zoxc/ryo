fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     [rbp-20h],rax
     17: mov     rdx,[rbp+18h]
     1b: mov     [rbp-18h],rdx
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
     17: mov     rdx,[rbp+18h]
     1b: mov     [rbp-18h],rdx
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
     6c: mov     rdx,[rbp+10h]
     70: lea     rdx,[rdx+4]
     74: mov     [rbp-30h],rdx
     78: lea     rsi,[rbp-20h]
     7c: mov     [rbp-40h],rsi
     80: lea     rdi,[rbp-28h]
     84: mov     [rbp-58h],rdi
     88: mov     [rbp-50h],rdi
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
     f4: lea     rdx,[rbp-30h]
     f8: mov     [rbp-58h],rdx
     fc: mov     [rbp-50h],rdx
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
     56: mov     rdx,[rbp+18h]
     5a: mov     [rbp-40h],rdx
     5e: mov     rsi,[rbp+10h]
     62: mov     [rbp-70h],rsi
     66: mov     rdi,[rbp+18h]
     6a: mov     [rbp-68h],rdi
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
    12e: mov     rdx,[rbp-60h]
    132: mov     [rbp-30h],rdx
    136: mov     rsi,[rbp-18h]
    13a: mov     [rbp-0A0h],rsi
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
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+8]
     1b: mov     [rbp-10h],rdx
     1f: mov     rsi,[rbp+10h]
     23: mov     rsi,[rsi+10h]
     27: mov     [rbp-18h],rsi
     2b: mov     byte ptr [rbp-29h],1
     2f: test    byte ptr [rbp-29h],0FFh
     33: je      76h
     35: mov     [rbp-20h],rax
     39: mov     [rbp-28h],rdx
     3d: mov     [rbp-60h],rax
     41: mov     [rbp-58h],rdx
     45: mov     qword ptr [rbp-50h],8
     4d: mov     qword ptr [rbp-48h],4
     55: mov     [rbp-40h],rsi
     59: mov     edi,0FFFFFFC8h
     5e: lea     rsi,[k0]
     65: call    ryo_h_AddrAbs
     6a: call    fn1
     6f: nop     [rcx]
     76: imul    rax,[rbp-18h],8
     7b: mov     [rbp-30h],rax
     7f: mov     edi,0FFFFFFF0h
     84: mov     esi,0FFFFFFF8h
     89: mov     edx,0FFFFFFD0h
     8e: call    ryo_h_Memcpy
     93: xor     edi,edi
     95: xor     esi,esi
     97: call    ryo_h_Ret
     9c: leave
     9d: ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+8]
     1b: mov     [rbp-10h],rdx
     1f: mov     rsi,[rbp+10h]
     23: mov     rsi,[rsi+10h]
     27: mov     [rbp-18h],rsi
     2b: mov     byte ptr [rbp-29h],1
     2f: test    byte ptr [rbp-29h],0FFh
     33: je      76h
     35: mov     [rbp-20h],rax
     39: mov     [rbp-28h],rdx
     3d: mov     [rbp-60h],rax
     41: mov     [rbp-58h],rdx
     45: mov     qword ptr [rbp-50h],4
     4d: mov     qword ptr [rbp-48h],4
     55: mov     [rbp-40h],rsi
     59: mov     edi,0FFFFFFC8h
     5e: lea     rsi,[k0]
     65: call    ryo_h_AddrAbs
     6a: call    fn1
     6f: nop     [rcx]
     76: imul    rax,[rbp-18h],4
     7b: mov     [rbp-30h],rax
     7f: mov     edi,0FFFFFFF0h
     84: mov     esi,0FFFFFFF8h
     89: mov     edx,0FFFFFFD0h
     8e: call    ryo_h_Memcpy
     93: xor     edi,edi
     95: xor     esi,esi
     97: call    ryo_h_Ret
     9c: leave
     9d: ret

fn <core::slice::sort::stable::merge::MergeState<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-20h],rax
     17: mov     rdx,[rbp+10h]
     1b: mov     rdx,[rdx]
     1e: mov     [rbp-8],rdx
     22: mov     [rbp-28h],rdx
     26: mov     [rbp-30h],rax
     2a: mov     byte ptr [rbp-41h],1
     2e: test    byte ptr [rbp-41h],0FFh
     32: je      0A3h
     34: jmp     6Eh
     36: nop     [rax+rax]
     3f: nop
     40: mov     rax,[rbp+10h]
     44: mov     rax,[rax]
     47: mov     [rbp-10h],rax
     4b: mov     [rbp-20h],rax
     4f: mov     rdx,[rbp+10h]
     53: mov     rdx,[rdx+10h]
     57: mov     [rbp-28h],rdx
     5b: mov     byte ptr [rbp-41h],1
     5f: test    byte ptr [rbp-41h],0FFh
     63: je      1C0h
     69: jmp     173h
     6e: mov     rax,[rbp-20h]
     72: mov     [rbp-38h],rax
     76: mov     rdx,[rbp-8]
     7a: mov     [rbp-40h],rdx
     7e: mov     [rbp-80h],rax
     82: mov     [rbp-78h],rdx
     86: mov     edi,0FFFFFF90h
     8b: lea     rsi,[k0]
     92: call    ryo_h_AddrAbs
     97: call    fn1
     9c: nop     [rcx-10h]
     a3: mov     qword ptr [rbp-48h],0
     ab: cmp     qword ptr [rbp-48h],8
     b0: setb    [rbp-31h]
     b4: test    byte ptr [rbp-31h],0FFh
     b8: je      10Ah
     ba: mov     qword ptr [rbp-48h],8
     c2: mov     r8,[rbp-48h]
     c6: mov     rcx,7FFFFFFFFFFFFFFFh
     d0: cmp     r8,rcx
     d3: setbe   [rbp-32h]
     d7: test    byte ptr [rbp-32h],0FFh
     db: je      10Ah
     dd: mov     r10,[rbp-30h]
     e1: sub     r10,[rbp-28h]
     e5: mov     [rbp-18h],r10
     e9: mov     qword ptr [rbp-48h],8
     f1: mov     edi,0FFFFFFE8h
     f6: mov     esi,0FFFFFFE8h
     fb: mov     edx,0FFFFFFB8h
    100: call    ryo_h_DivUW64
    105: jmp     40h
    10a: mov     edi,0FFFFFF80h
    10f: lea     rsi,[k2]
    116: call    ryo_h_AddrAbs
    11b: mov     qword ptr [rbp-78h],49h
    123: mov     edi,0FFFFFF90h
    128: lea     rsi,[k3]
    12f: call    ryo_h_AddrAbs
    134: lea     rdi,[sym4]
    13b: lea     rsi,[site5]
    142: mov     edx,0FFFFFFB8h
    147: call    ryo_h_CallExt
    14c: test    rax,rax
    14f: je      15Ch
    151: call    rax
    153: nop     [rcx-10h]
    15a: jmp     16Ch
    15c: mov     rdi,rbp
    15f: lea     rsi,[ro+4]
    166: call    qword ptr [sym6]
    16c: call    ryo_h_Unreachable
    171: ud2
    173: mov     rax,[rbp-10h]
    177: mov     [rbp-30h],rax
    17b: mov     rdx,[rbp-28h]
    17f: mov     [rbp-38h],rdx
    183: mov     [rbp-80h],rax
    187: mov     [rbp-78h],rdx
    18b: mov     qword ptr [rbp-70h],8
    193: mov     qword ptr [rbp-68h],4
    19b: mov     r8,[rbp-18h]
    19f: mov     [rbp-60h],r8
    1a3: mov     edi,0FFFFFFA8h
    1a8: lea     rsi,[k7]
    1af: call    ryo_h_AddrAbs
    1b4: call    fn8
    1b9: nop     [rcx-10h]
    1c0: imul    rax,[rbp-18h],8
    1c5: mov     [rbp-48h],rax
    1c9: mov     edi,0FFFFFFD8h
    1ce: mov     esi,0FFFFFFE0h
    1d3: mov     edx,0FFFFFFB8h
    1d8: call    ryo_h_Memcpy
    1dd: xor     edi,edi
    1df: xor     esi,esi
    1e1: call    ryo_h_Ret
    1e6: leave
    1e7: ret

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     [rbp-10h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx]
     1f: mov     [rbp-18h],rdx
     23: mov     byte ptr [rbp-29h],1
     27: test    byte ptr [rbp-29h],0FFh
     2b: je      76h
     2d: mov     r8,[rbp-8]
     31: mov     [rbp-20h],r8
     35: mov     [rbp-28h],rdx
     39: mov     [rbp-70h],r8
     3d: mov     [rbp-68h],rdx
     41: mov     qword ptr [rbp-60h],4
     49: mov     qword ptr [rbp-58h],4
     51: mov     qword ptr [rbp-50h],1
     59: mov     edi,0FFFFFFB8h
     5e: lea     rsi,[k0]
     65: call    ryo_h_AddrAbs
     6a: call    fn1
     6f: nop     [rcx-8]
     76: mov     qword ptr [rbp-30h],1
     7e: imul    rdx,[rbp-30h],4
     83: mov     [rbp-38h],rdx
     87: mov     edi,0FFFFFFE8h
     8c: mov     esi,0FFFFFFF0h
     91: mov     edx,0FFFFFFC8h
     96: call    ryo_h_Memcpy
     9b: xor     edi,edi
     9d: xor     esi,esi
     9f: call    ryo_h_Ret
     a4: leave
     a5: ret

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
     10: mov     rdx,[rbp+20h]
     14: mov     [rbp-10h],rdx
     18: mov     [rbp-30h],rax
     1c: mov     [rbp-28h],rdx
     20: call    fn0
     25: nop     [rcx-1]
     2c: mov     edi,0FFFFFFFFh
     31: mov     esi,1
     36: call    ryo_h_Ret
     3b: leave
     3c: ret

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
     12: mov     rsi,[rbp+10h]
     16: mov     [rbp-20h],rsi
     1a: mov     [rbp-30h],rsi
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
     17: mov     rdx,[rbp+10h]
     1b: mov     rdx,[rdx]
     1e: mov     [rbp-60h],rdx
     22: mov     [rbp-58h],rdx
     26: mov     rsi,[rbp+20h]
     2a: mov     [rbp-50h],rsi
     2e: mov     rdi,[rbp+18h]
     32: mov     [rbp-48h],rdi
     36: mov     edi,0FFFFFFC0h
     3b: mov     esi,0FFFFFFA8h
     40: call    ryo_h_MovW128
     45: mov     rax,[rbp-30h]
     49: mov     [rbp-90h],rax
     50: mov     rdx,[rbp-48h]
     54: mov     [rbp-88h],rdx
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
    103: mov     rdx,[rbp-28h]
    107: mov     [rbp-8],rdx
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
     3a: mov     rdx,[rbp-20h]
     3e: mov     [rbp-38h],rdx
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
     54: .long   95h
     58: .long   60h
     5c: .long   108h
     60: mov     rax,[rbp-20h]
     64: mov     [rbp-30h],rax
     68: lea     rdx,[rbp+20h]
     6c: mov     [rbp-38h],rdx
     70: mov     byte ptr [rbp-9],0
     74: mov     [rbp-40h],rax
     78: mov     [rbp-60h],rdx
     7c: mov     [rbp-58h],rax
     80: call    fn1
     85: nop     [rcx-8]
     8c: mov     byte ptr [rbp-9],1
     90: jmp     10h
     95: lea     rax,[rbp+20h]
     99: mov     [rbp-48h],rax
     9d: mov     [rbp-60h],rax
     a1: call    fn2
     a6: nop     [rcx-48h]
     ad: xor     edi,edi
     af: xor     esi,esi
     b1: call    ryo_h_Ret
     b6: leave
     b7: ret
     b8: nop     [rax+rax]
     c0: lea     rax,[rbp+20h]
     c4: mov     [rbp-48h],rax
     c8: mov     [rbp-60h],rax
     cc: call    fn3
     d1: nop     [rcx-48h]
     d8: nop     [rax+rax]
     e0: mov     edi,0FFFFFFE8h
     e5: call    ryo_h_Resume
     ea: ud2
     ec: nop     [rax]
     f0: jmp     0C0h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: test    byte ptr [rbp-9],0FFh
    104: je      0C0h
    106: jmp     0F0h
    108: call    ryo_h_Unreachable
    10d: ud2
    10f: nop
    110: lea     rdi,[sym4]
    117: lea     rsi,[site5]
    11e: mov     edx,0FFFFFFB8h
    123: call    ryo_h_CallExt
    128: test    rax,rax
    12b: je      138h
    12d: call    rax
    12f: nop     [rcx-40h]
    136: jmp     148h
    138: mov     rdi,rbp
    13b: lea     rsi,[ro+4]
    142: call    qword ptr [sym6]
    148: call    ryo_h_Unreachable
    14d: ud2
    14f: mov     rdi,rax
    152: mov     esi,0FFFFFFE8h
    157: call    ryo_h_Lpad
    15c: jmp     100h
    15e: mov     rdi,rax
    161: mov     esi,0FFFFFFE8h
    166: call    ryo_h_Lpad
    16b: jmp     0E0h
    170: mov     rdi,rax
    173: mov     esi,0FFFFFFE8h
    178: call    ryo_h_Lpad
    17d: jmp     110h

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
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+8]
     18: mov     [rbp-28h],rdx
     1c: mov     [rbp-40h],rax
     20: mov     [rbp-38h],rdx
     24: call    fn0
     29: nop     [rcx-11h]
     30: test    byte ptr [rbp-11h],0FFh
     34: je      76h
     36: mov     rdx,[rbp+10h]
     3a: mov     rdx,[rdx]
     3d: mov     [rbp-20h],rdx
     41: mov     [rbp-40h],rdx
     45: mov     qword ptr [rbp-38h],1
     4d: call    fn1
     52: nop     [rcx-28h]
     59: mov     rax,[rbp+10h]
     5d: mov     rcx,[rbp-28h]
     61: mov     [rax],rcx
     64: mov     rdx,[rbp-20h]
     68: mov     [rbp-8],rdx
     6c: mov     qword ptr [rbp-10h],1
     74: jmp     7Eh
     76: mov     qword ptr [rbp-10h],0
     7e: mov     edi,0FFFFFFF0h
     83: mov     esi,10h
     88: call    ryo_h_Ret
     8d: leave
     8e: ret

fn <std::ops::Range<usize> as std::slice::SliceIndex<[T]>>::get_unchecked_mut::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jb      29h
     15: mov     rdx,[rbp+20h]
     19: cmp     rdx,rax
     1c: jb      29h
     1e: xor     edi,edi
     20: xor     esi,esi
     22: call    ryo_h_Ret
     27: leave
     28: ret
     29: mov     edi,0FFFFFFF0h
     2e: lea     rsi,[k0]
     35: call    ryo_h_AddrAbs
     3a: mov     qword ptr [rbp-8],0DAh
     42: mov     rdx,[rbp-10h]
     46: mov     [rbp-48h],rdx
     4a: mov     rsi,[rbp-8]
     4e: mov     [rbp-40h],rsi
     52: mov     [rbp-38h],rdx
     56: mov     [rbp-30h],rdx
     5a: mov     edi,0FFFFFFA0h
     5f: lea     rsi,[k1]
     66: call    ryo_h_AddrAbs
     6b: mov     qword ptr [rbp-58h],0DAh
     73: mov     rdx,[rbp-58h]
     77: mov     [rbp-50h],rdx
     7b: shl     rdx,1
     7f: mov     [rbp-48h],rdx
     83: or      rdx,1
     87: mov     [rbp-40h],rdx
     8b: mov     [rbp-38h],rdx
     8f: mov     rsi,[rbp-30h]
     93: mov     [rbp-28h],rsi
     97: mov     [rbp-20h],rdx
     9b: mov     edi,0FFFFFF70h
     a0: mov     esi,0FFFFFFD8h
     a5: call    ryo_h_MovW128
     aa: mov     byte ptr [rbp-80h],0
     ae: mov     rdx,[rbp+28h]
     b2: mov     [rbp-78h],rdx
     b6: lea     rdi,[sym2]
     bd: lea     rsi,[site3]
     c4: mov     edx,0FFFFFF98h
     c9: call    ryo_h_CallExt
     ce: test    rax,rax
     d1: je      0DEh
     d3: call    rax
     d5: nop     [rcx-10h]
     dc: jmp     0EEh
     de: mov     rdi,rbp
     e1: lea     rsi,[ro+4]
     e8: call    qword ptr [sym4]
     ee: call    ryo_h_Unreachable
     f3: ud2

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+28h]
      f: mov     [rbp-18h],rax
     13: mov     rdx,[rbp+20h]
     17: mov     [rbp-20h],rdx
     1b: cmp     rax,rdx
     1e: jb      0EFh
     24: jmp     0F1h
     29: nop     [rax]
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-60h],rax
     38: mov     rdx,[rbp+18h]
     3c: mov     [rbp-58h],rdx
     40: mov     [rbp-68h],rax
     44: imul    rcx,[rbp-20h],4
     49: add     rax,rcx
     4c: mov     [rbp-70h],rax
     50: mov     [rbp-50h],rax
     54: mov     rsi,[rbp-38h]
     58: mov     [rbp-48h],rsi
     5c: mov     [rbp-10h],rax
     60: mov     [rbp-8],rsi
     64: mov     edi,0FFFFFFF0h
     69: mov     esi,10h
     6e: call    ryo_h_Ret
     73: leave
     74: ret
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: mov     rax,[rbp+18h]
     84: mov     [rbp-28h],rax
     88: mov     rdx,[rbp-20h]
     8c: mov     [rbp-0A0h],rdx
     93: mov     rsi,[rbp-18h]
     97: mov     [rbp-98h],rsi
     9e: mov     [rbp-90h],rax
     a5: mov     rdi,[rbp+30h]
     a9: mov     [rbp-88h],rdi
     b0: lea     rdi,[sym0]
     b7: lea     rsi,[site1]
     be: mov     edx,0FFFFFF88h
     c3: call    ryo_h_CallExt
     c8: test    rax,rax
     cb: je      0D8h
     cd: call    rax
     cf: nop     [rcx-20h]
     d6: jmp     0E8h
     d8: mov     rdi,rbp
     db: lea     rsi,[ro+4]
     e2: call    qword ptr [sym2]
     e8: call    ryo_h_Unreachable
     ed: ud2
     ef: jmp     80h
     f1: mov     rax,[rbp-18h]
     f5: sub     rax,[rbp-20h]
     f9: mov     [rbp-40h],rax
     fd: mov     [rbp-28h],rax
    101: mov     qword ptr [rbp-30h],1
    109: mov     [rbp-38h],rax
    10d: mov     rsi,[rbp+18h]
    111: mov     [rbp-48h],rsi
    115: cmp     rsi,[rbp-18h]
    119: jae     30h
    11f: jmp     80h

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+28h]
      f: mov     [rbp-18h],rax
     13: mov     rdx,[rbp+20h]
     17: mov     [rbp-20h],rdx
     1b: cmp     rax,rdx
     1e: jb      0EFh
     24: jmp     0F1h
     29: nop     [rax]
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-60h],rax
     38: mov     rdx,[rbp+18h]
     3c: mov     [rbp-58h],rdx
     40: mov     [rbp-68h],rax
     44: imul    rcx,[rbp-20h],4
     49: add     rax,rcx
     4c: mov     [rbp-70h],rax
     50: mov     [rbp-50h],rax
     54: mov     rsi,[rbp-38h]
     58: mov     [rbp-48h],rsi
     5c: mov     [rbp-10h],rax
     60: mov     [rbp-8],rsi
     64: mov     edi,0FFFFFFF0h
     69: mov     esi,10h
     6e: call    ryo_h_Ret
     73: leave
     74: ret
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: mov     rax,[rbp+18h]
     84: mov     [rbp-28h],rax
     88: mov     rdx,[rbp-20h]
     8c: mov     [rbp-0A0h],rdx
     93: mov     rsi,[rbp-18h]
     97: mov     [rbp-98h],rsi
     9e: mov     [rbp-90h],rax
     a5: mov     rdi,[rbp+30h]
     a9: mov     [rbp-88h],rdi
     b0: lea     rdi,[sym0]
     b7: lea     rsi,[site1]
     be: mov     edx,0FFFFFF88h
     c3: call    ryo_h_CallExt
     c8: test    rax,rax
     cb: je      0D8h
     cd: call    rax
     cf: nop     [rcx-20h]
     d6: jmp     0E8h
     d8: mov     rdi,rbp
     db: lea     rsi,[ro+4]
     e2: call    qword ptr [sym2]
     e8: call    ryo_h_Unreachable
     ed: ud2
     ef: jmp     80h
     f1: mov     rax,[rbp-18h]
     f5: sub     rax,[rbp-20h]
     f9: mov     [rbp-40h],rax
     fd: mov     [rbp-28h],rax
    101: mov     qword ptr [rbp-30h],1
    109: mov     [rbp-38h],rax
    10d: mov     rsi,[rbp+18h]
    111: mov     [rbp-48h],rsi
    115: cmp     rsi,[rbp-18h]
    119: jae     30h
    11f: jmp     80h

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-20h],rdx
     1b: cmp     rdx,rax
     1e: jae     77h
     20: mov     [rbp-80h],rax
     24: mov     [rbp-78h],rdx
     28: mov     rsi,[rbp-20h]
     2c: mov     [rbp-70h],rsi
     30: mov     rdi,[rbp+28h]
     34: mov     [rbp-68h],rdi
     38: lea     rdi,[sym0]
     3f: lea     rsi,[site1]
     46: mov     edx,0FFFFFFA0h
     4b: call    ryo_h_CallExt
     50: test    rax,rax
     53: je      60h
     55: call    rax
     57: nop     [rcx-20h]
     5e: jmp     70h
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym2]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     rax,[rbp-20h]
     7b: sub     rax,[rbp-18h]
     7f: mov     [rbp-28h],rax
     83: mov     rdx,[rbp+10h]
     87: mov     [rbp-48h],rdx
     8b: mov     rsi,[rbp+18h]
     8f: mov     [rbp-40h],rsi
     93: mov     [rbp-50h],rdx
     97: imul    rcx,[rbp-18h],4
     9c: add     rdx,rcx
     9f: mov     [rbp-58h],rdx
     a3: mov     [rbp-38h],rdx
     a7: mov     [rbp-30h],rax
     ab: mov     [rbp-10h],rdx
     af: mov     [rbp-8],rax
     b3: mov     edi,0FFFFFFF0h
     b8: mov     esi,10h
     bd: call    ryo_h_Ret
     c2: leave
     c3: ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-20h],rdx
     1b: cmp     rdx,rax
     1e: jae     77h
     20: mov     [rbp-80h],rax
     24: mov     [rbp-78h],rdx
     28: mov     rsi,[rbp-20h]
     2c: mov     [rbp-70h],rsi
     30: mov     rdi,[rbp+28h]
     34: mov     [rbp-68h],rdi
     38: lea     rdi,[sym0]
     3f: lea     rsi,[site1]
     46: mov     edx,0FFFFFFA0h
     4b: call    ryo_h_CallExt
     50: test    rax,rax
     53: je      60h
     55: call    rax
     57: nop     [rcx-20h]
     5e: jmp     70h
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym2]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     rax,[rbp-20h]
     7b: sub     rax,[rbp-18h]
     7f: mov     [rbp-28h],rax
     83: mov     rdx,[rbp+10h]
     87: mov     [rbp-48h],rdx
     8b: mov     rsi,[rbp+18h]
     8f: mov     [rbp-40h],rsi
     93: mov     [rbp-50h],rdx
     97: imul    rcx,[rbp-18h],4
     9c: add     rdx,rcx
     9f: mov     [rbp-58h],rdx
     a3: mov     [rbp-38h],rdx
     a7: mov     [rbp-30h],rax
     ab: mov     [rbp-10h],rdx
     af: mov     [rbp-8],rax
     b3: mov     edi,0FFFFFFF0h
     b8: mov     esi,10h
     bd: call    ryo_h_Ret
     c2: leave
     c3: ret

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
     15: mov     rsi,[rbp+18h]
     19: mov     [rbp-50h],rsi
     1d: mov     [rbp-48h],rsi
     21: cmp     rsi,0
     25: sete    [rbp-39h]
     29: jmp     4Eh
     2b: mov     rax,[rbp+18h]
     2f: mov     [rbp-50h],rax
     33: mov     [rbp-48h],rax
     37: mov     rdx,[rbp+10h]
     3b: mov     [rbp-58h],rdx
     3f: mov     [rbp-50h],rdx
     43: mov     [rbp-58h],rax
     47: cmp     rdx,rax
     4a: sete    [rbp-39h]
     4e: test    byte ptr [rbp-39h],0FFh
     52: je      78h
     54: mov     byte ptr [rbp-2Ah],0
     58: lea     rsi,[rbp+20h]
     5c: mov     [rbp-80h],rsi
     60: mov     [rbp-0A0h],rsi
     67: call    fn0
     6c: nop     [rcx-80h]
     73: jmp     175h
     78: mov     byte ptr [rbp-2Ah],0
     7c: mov     byte ptr [rbp-29h],1
     80: mov     qword ptr [rbp-18h],0
     88: mov     byte ptr [rbp-79h],0
     8c: test    byte ptr [rbp-79h],0FFh
     90: je      0A0h
     92: mov     r9,[rbp+18h]
     96: mov     [rbp-40h],r9
     9a: mov     [rbp-20h],r9
     9e: jmp     0E0h
     a0: mov     rax,[rbp+18h]
     a4: mov     [rbp-48h],rax
     a8: mov     [rbp-40h],rax
     ac: mov     rdx,[rbp+10h]
     b0: mov     [rbp-48h],rdx
     b4: mov     [rbp-50h],rax
     b8: mov     [rbp-58h],rdx
     bc: mov     rsi,[rbp-40h]
     c0: mov     [rbp-60h],rsi
     c4: mov     byte ptr [rbp-79h],1
     c8: test    byte ptr [rbp-79h],0FFh
     cc: je      230h
     d2: jmp     1F5h
     d7: nop     [rax+rax]
     e0: lea     rax,[rbp+20h]
     e4: mov     [rbp-40h],rax
     e8: mov     byte ptr [rbp-29h],0
     ec: mov     rsi,[rbp+10h]
     f0: mov     [rbp-60h],rsi
     f4: mov     rdi,[rbp-18h]
     f8: mov     [rbp-68h],rdi
     fc: mov     [rbp-78h],rsi
    100: imul    rcx,rdi,4
    104: add     rsi,rcx
    107: mov     [rbp-70h],rsi
    10b: mov     [rbp-58h],rsi
    10f: mov     [rbp-50h],rsi
    113: mov     [rbp-28h],rsi
    117: mov     [rbp-48h],rsi
    11b: mov     [rbp-0A0h],rax
    122: mov     [rbp-98h],rsi
    129: call    fn1
    12e: nop     [rcx-20h]
    135: mov     byte ptr [rbp-79h],1
    139: test    byte ptr [rbp-79h],0FFh
    13d: je      336h
    143: jmp     303h
    148: nop     [rax+rax]
    150: lea     rax,[rbp+20h]
    154: mov     [rbp-80h],rax
    158: mov     [rbp-0A0h],rax
    15f: call    fn2
    164: nop     [rcx-80h]
    16b: jmp     175h
    16d: nop     [rax]
    170: jmp     0E0h
    175: xor     edi,edi
    177: xor     esi,esi
    179: call    ryo_h_Ret
    17e: leave
    17f: ret
    180: lea     rax,[rbp+20h]
    184: mov     [rbp-80h],rax
    188: mov     [rbp-0A0h],rax
    18f: call    fn3
    194: nop     [rcx-80h]
    19b: jmp     1E0h
    19d: nop     [rax]
    1a0: mov     edi,0FFFFFFC8h
    1a5: call    ryo_h_Resume
    1aa: ud2
    1ac: nop     [rax]
    1b0: jmp     180h
    1b2: nop     [rax+rax]
    1bb: nop     [rax+rax]
    1c0: test    byte ptr [rbp-29h],0FFh
    1c4: je      180h
    1c6: jmp     1B0h
    1c8: nop     [rax+rax]
    1d0: jmp     1A0h
    1d2: nop     [rax+rax]
    1db: nop     [rax+rax]
    1e0: test    byte ptr [rbp-2Ah],0FFh
    1e4: je      1A0h
    1e6: jmp     1D0h
    1e8: nop     [rax+rax]
    1f0: jmp     0E0h
    1f5: mov     rax,[rbp-40h]
    1f9: mov     [rbp-68h],rax
    1fd: mov     rdx,[rbp-48h]
    201: mov     [rbp-70h],rdx
    205: mov     [rbp-0A0h],rax
    20c: mov     [rbp-98h],rdx
    213: mov     edi,0FFFFFF70h
    218: lea     rsi,[k4]
    21f: call    ryo_h_AddrAbs
    224: call    fn5
    229: nop     [rcx-2Ah]
    230: mov     qword ptr [rbp-80h],0
    238: cmp     qword ptr [rbp-80h],4
    23d: setb    [rbp-61h]
    241: test    byte ptr [rbp-61h],0FFh
    245: je      297h
    247: mov     qword ptr [rbp-80h],4
    24f: mov     r8,[rbp-80h]
    253: mov     rcx,7FFFFFFFFFFFFFFFh
    25d: cmp     r8,rcx
    260: setbe   [rbp-62h]
    264: test    byte ptr [rbp-62h],0FFh
    268: je      297h
    26a: mov     r10,[rbp-60h]
    26e: sub     r10,[rbp-58h]
    272: mov     [rbp-20h],r10
    276: mov     qword ptr [rbp-80h],4
    27e: mov     edi,0FFFFFFE0h
    283: mov     esi,0FFFFFFE0h
    288: mov     edx,0FFFFFF80h
    28d: call    ryo_h_DivUW64
    292: jmp     1F0h
    297: mov     edi,0FFFFFF60h
    29c: lea     rsi,[k6]
    2a3: call    ryo_h_AddrAbs
    2a8: mov     qword ptr [rbp-98h],49h
    2b3: mov     edi,0FFFFFF70h
    2b8: lea     rsi,[k7]
    2bf: call    ryo_h_AddrAbs
    2c4: lea     rdi,[sym8]
    2cb: lea     rsi,[site9]
    2d2: mov     edx,0FFFFFF80h
    2d7: call    ryo_h_CallExt
    2dc: test    rax,rax
    2df: je      2ECh
    2e1: call    rax
    2e3: nop     [rcx-2Ah]
    2ea: jmp     2FCh
    2ec: mov     rdi,rbp
    2ef: lea     rsi,[ro+4]
    2f6: call    qword ptr [sym10]
    2fc: call    ryo_h_Unreachable
    301: ud2
    303: mov     rax,[rbp-18h]
    307: mov     [rbp-0A0h],rax
    30e: mov     qword ptr [rbp-98h],1
    319: mov     edi,0FFFFFF70h
    31e: lea     rsi,[k11]
    325: call    ryo_h_AddrAbs
    32a: call    fn12
    32f: nop     [rcx-2Ah]
    336: mov     rax,[rbp-18h]
    33a: add     rax,1
    33e: mov     [rbp-40h],rax
    342: mov     [rbp-18h],rax
    346: mov     [rbp-48h],rax
    34a: mov     rdx,[rbp-20h]
    34e: mov     [rbp-50h],rdx
    352: cmp     rax,rdx
    355: je      150h
    35b: jmp     170h
    360: lea     rdi,[sym13]
    367: lea     rsi,[site14]
    36e: mov     edx,0FFFFFF80h
    373: call    ryo_h_CallExt
    378: test    rax,rax
    37b: je      388h
    37d: call    rax
    37f: nop     [rcx-78h]
    386: jmp     398h
    388: mov     rdi,rbp
    38b: lea     rsi,[ro+20]
    392: call    qword ptr [sym15]
    398: call    ryo_h_Unreachable
    39d: ud2
    39f: mov     rdi,rax
    3a2: mov     esi,0FFFFFFC8h
    3a7: call    ryo_h_Lpad
    3ac: jmp     1E0h
    3b1: mov     rdi,rax
    3b4: mov     esi,0FFFFFFC8h
    3b9: call    ryo_h_Lpad
    3be: jmp     1C0h
    3c3: mov     rdi,rax
    3c6: mov     esi,0FFFFFFC8h
    3cb: call    ryo_h_Lpad
    3d0: jmp     360h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-0A1h],0
     12: test    byte ptr [rbp-0A1h],0FFh
     19: je      31h
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-58h],rsi
     23: mov     [rbp-50h],rsi
     27: cmp     rsi,0
     2b: sete    [rbp-41h]
     2f: jmp     54h
     31: mov     rax,[rbp+18h]
     35: mov     [rbp-58h],rax
     39: mov     [rbp-50h],rax
     3d: mov     rdx,[rbp+10h]
     41: mov     [rbp-60h],rdx
     45: mov     [rbp-58h],rdx
     49: mov     [rbp-60h],rax
     4d: cmp     rdx,rax
     50: sete    [rbp-41h]
     54: test    byte ptr [rbp-41h],0FFh
     58: je      6Bh
     5a: mov     byte ptr [rbp-32h],0
     5e: mov     rsi,[rbp+20h]
     62: mov     [rbp-8],rsi
     66: jmp     195h
     6b: mov     byte ptr [rbp-32h],0
     6f: mov     byte ptr [rbp-31h],1
     73: mov     rsi,[rbp+20h]
     77: mov     [rbp-48h],rsi
     7b: mov     qword ptr [rbp-20h],0
     83: mov     byte ptr [rbp-0A1h],0
     8a: test    byte ptr [rbp-0A1h],0FFh
     91: je      0A1h
     93: mov     r10,[rbp+18h]
     97: mov     [rbp-50h],r10
     9b: mov     [rbp-28h],r10
     9f: jmp     0E0h
     a1: mov     rax,[rbp+18h]
     a5: mov     [rbp-58h],rax
     a9: mov     [rbp-50h],rax
     ad: mov     rdx,[rbp+10h]
     b1: mov     [rbp-58h],rdx
     b5: mov     [rbp-60h],rax
     b9: mov     [rbp-68h],rdx
     bd: mov     rsi,[rbp-50h]
     c1: mov     [rbp-70h],rsi
     c5: mov     byte ptr [rbp-0A1h],1
     cc: test    byte ptr [rbp-0A1h],0FFh
     d3: je      240h
     d9: jmp     205h
     de: xchg    ax,ax
     e0: lea     rax,[rbp+28h]
     e4: mov     [rbp-58h],rax
     e8: mov     byte ptr [rbp-31h],0
     ec: mov     rsi,[rbp-48h]
     f0: mov     [rbp-70h],rsi
     f4: mov     rdi,[rbp+10h]
     f8: mov     [rbp-88h],rdi
     ff: mov     r8,[rbp-20h]
    103: mov     [rbp-90h],r8
    10a: mov     [rbp-0A0h],rdi
    111: imul    rcx,r8,4
    115: add     rdi,rcx
    118: mov     [rbp-98h],rdi
    11f: mov     [rbp-80h],rdi
    123: mov     [rbp-78h],rdi
    127: mov     [rbp-30h],rdi
    12b: mov     [rbp-68h],rsi
    12f: mov     [rbp-60h],rdi
    133: mov     [rbp-0C0h],rax
    13a: mov     [rbp-0B8h],rsi
    141: mov     [rbp-0B0h],rdi
    148: call    fn0
    14d: nop     [rcx-50h]
    154: mov     rax,[rbp-50h]
    158: mov     [rbp-48h],rax
    15c: mov     byte ptr [rbp-0A1h],1
    163: test    byte ptr [rbp-0A1h],0FFh
    16a: je      355h
    170: jmp     322h
    175: nop     [rax+rax]
    17e: xchg    ax,ax
    180: mov     rax,[rbp-48h]
    184: mov     [rbp-8],rax
    188: jmp     195h
    18a: nop     [rax+rax]
    190: jmp     0E0h
    195: mov     edi,0FFFFFFF8h
    19a: mov     esi,8
    19f: call    ryo_h_Ret
    1a4: leave
    1a5: ret
    1a6: nop     [rax+rax]
    1af: nop
    1b0: jmp     1F2h
    1b2: nop     [rax+rax]
    1bb: nop     [rax+rax]
    1c0: mov     edi,0FFFFFFC0h
    1c5: call    ryo_h_Resume
    1ca: ud2
    1cc: nop     [rax]
    1d0: jmp     1B0h
    1d2: nop     [rax+rax]
    1db: nop     [rax+rax]
    1e0: test    byte ptr [rbp-31h],0FFh
    1e4: je      1B0h
    1e6: jmp     1D0h
    1e8: nop     [rax+rax]
    1f0: jmp     1C0h
    1f2: test    byte ptr [rbp-32h],0FFh
    1f6: je      1C0h
    1f8: jmp     1F0h
    1fa: nop     [rax+rax]
    200: jmp     0E0h
    205: mov     rax,[rbp-50h]
    209: mov     [rbp-78h],rax
    20d: mov     rdx,[rbp-58h]
    211: mov     [rbp-80h],rdx
    215: mov     [rbp-0C0h],rax
    21c: mov     [rbp-0B8h],rdx
    223: mov     edi,0FFFFFF50h
    228: lea     rsi,[k1]
    22f: call    ryo_h_AddrAbs
    234: call    fn2
    239: nop     [rcx-32h]
    240: mov     qword ptr [rbp-0A8h],0
    24b: cmp     qword ptr [rbp-0A8h],4
    253: setb    [rbp-71h]
    257: test    byte ptr [rbp-71h],0FFh
    25b: je      2B6h
    25d: mov     qword ptr [rbp-0A8h],4
    268: mov     r8,[rbp-0A8h]
    26f: mov     rcx,7FFFFFFFFFFFFFFFh
    279: cmp     r8,rcx
    27c: setbe   [rbp-72h]
    280: test    byte ptr [rbp-72h],0FFh
    284: je      2B6h
    286: mov     r10,[rbp-70h]
    28a: sub     r10,[rbp-68h]
    28e: mov     [rbp-28h],r10
    292: mov     qword ptr [rbp-0A8h],4
    29d: mov     edi,0FFFFFFD8h
    2a2: mov     esi,0FFFFFFD8h
    2a7: mov     edx,0FFFFFF58h
    2ac: call    ryo_h_DivUW64
    2b1: jmp     200h
    2b6: mov     edi,0FFFFFF40h
    2bb: lea     rsi,[k3]
    2c2: call    ryo_h_AddrAbs
    2c7: mov     qword ptr [rbp-0B8h],49h
    2d2: mov     edi,0FFFFFF50h
    2d7: lea     rsi,[k4]
    2de: call    ryo_h_AddrAbs
    2e3: lea     rdi,[sym5]
    2ea: lea     rsi,[site6]
    2f1: mov     edx,0FFFFFF58h
    2f6: call    ryo_h_CallExt
    2fb: test    rax,rax
    2fe: je      30Bh
    300: call    rax
    302: nop     [rcx-32h]
    309: jmp     31Bh
    30b: mov     rdi,rbp
    30e: lea     rsi,[ro+4]
    315: call    qword ptr [sym7]
    31b: call    ryo_h_Unreachable
    320: ud2
    322: mov     rax,[rbp-20h]
    326: mov     [rbp-0C0h],rax
    32d: mov     qword ptr [rbp-0B8h],1
    338: mov     edi,0FFFFFF50h
    33d: lea     rsi,[k8]
    344: call    ryo_h_AddrAbs
    349: call    fn9
    34e: nop     [rcx-32h]
    355: mov     rax,[rbp-20h]
    359: add     rax,1
    35d: mov     [rbp-50h],rax
    361: mov     [rbp-20h],rax
    365: mov     [rbp-58h],rax
    369: mov     rdx,[rbp-28h]
    36d: mov     [rbp-60h],rdx
    371: cmp     rax,rdx
    374: je      180h
    37a: jmp     190h
    37f: mov     rdi,rax
    382: mov     esi,0FFFFFFC0h
    387: call    ryo_h_Lpad
    38c: jmp     1E0h

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
     16: mov     rdx,[rbp+10h]
     1a: mov     rdx,[rdx+8]
     1e: mov     [rbp-40h],rdx
     22: mov     byte ptr [rbp-59h],0
     26: test    byte ptr [rbp-59h],0FFh
     2a: je      56h
     2c: mov     [rbp-48h],rdx
     30: cmp     rdx,0
     34: jne     43h
     36: mov     qword ptr [rbp-8],0
     3e: jmp     0C2h
     43: mov     byte ptr [rbp-59h],1
     47: test    byte ptr [rbp-59h],0FFh
     4b: je      100h
     51: jmp     0D3h
     56: mov     rax,[rbp-40h]
     5a: mov     [rbp-50h],rax
     5e: mov     rdx,[rbp-38h]
     62: mov     [rbp-30h],rdx
     66: mov     [rbp-58h],rax
     6a: cmp     rdx,rax
     6d: sete    [rbp-41h]
     71: test    byte ptr [rbp-41h],0FFh
     75: je      81h
     77: mov     qword ptr [rbp-8],0
     7f: jmp     0C2h
     81: mov     qword ptr [rbp-60h],1
     89: mov     rdx,[rbp-30h]
     8d: imul    rcx,[rbp-60h],4
     92: add     rdx,rcx
     95: mov     [rbp-50h],rdx
     99: mov     [rbp-48h],rdx
     9d: mov     rsi,[rbp+10h]
     a1: mov     rcx,[rbp-48h]
     a5: mov     [rsi],rcx
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp-38h]
     b4: mov     [rbp-50h],rax
     b8: mov     [rbp-48h],rax
     bc: mov     [rbp-8],rax
     c0: jmp     0C2h
     c2: mov     edi,0FFFFFFF8h
     c7: mov     esi,8
     cc: call    ryo_h_Ret
     d1: leave
     d2: ret
     d3: mov     rax,[rbp-48h]
     d7: mov     [rbp-80h],rax
     db: mov     qword ptr [rbp-78h],1
     e3: mov     edi,0FFFFFF90h
     e8: lea     rsi,[k0]
     ef: call    ryo_h_AddrAbs
     f4: call    fn1
     f9: nop     [rcx-28h]
    100: mov     rax,[rbp-48h]
    104: sub     rax,1
    108: mov     [rbp-10h],rax
    10c: mov     rdx,[rbp+10h]
    110: mov     rcx,[rbp-10h]
    114: mov     [rdx+8],rcx
    118: jmp     0B0h

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-59h],0
      f: test    byte ptr [rbp-59h],0FFh
     13: je      27h
     15: mov     rsi,[rbp+10h]
     19: mov     rsi,[rsi+8]
     1d: mov     [rbp-28h],rsi
     21: mov     [rbp-20h],rsi
     25: jmp     60h
     27: mov     rax,[rbp+10h]
     2b: mov     rax,[rax+8]
     2f: mov     [rbp-30h],rax
     33: mov     [rbp-28h],rax
     37: mov     rdx,[rbp+10h]
     3b: mov     rdx,[rdx]
     3e: mov     [rbp-30h],rdx
     42: mov     [rbp-38h],rax
     46: mov     [rbp-40h],rdx
     4a: mov     rsi,[rbp-28h]
     4e: mov     [rbp-48h],rsi
     52: mov     byte ptr [rbp-59h],1
     56: test    byte ptr [rbp-59h],0FFh
     5a: je      0D7h
     5c: jmp     0A2h
     5e: xchg    ax,ax
     60: mov     rax,[rbp-20h]
     64: mov     [rbp-28h],rax
     68: mov     rdx,[rbp-20h]
     6c: mov     [rbp-30h],rdx
     70: mov     qword ptr [rbp-38h],1
     78: mov     [rbp-18h],rax
     7c: mov     edi,0FFFFFFF0h
     81: mov     esi,0FFFFFFC8h
     86: call    ryo_h_MovW128
     8b: mov     edi,0FFFFFFE8h
     90: mov     esi,18h
     95: call    ryo_h_Ret
     9a: leave
     9b: ret
     9c: nop     [rax]
     a0: jmp     60h
     a2: mov     rax,[rbp-28h]
     a6: mov     [rbp-50h],rax
     aa: mov     rdx,[rbp-30h]
     ae: mov     [rbp-58h],rdx
     b2: mov     [rbp-80h],rax
     b6: mov     [rbp-78h],rdx
     ba: mov     edi,0FFFFFF90h
     bf: lea     rsi,[k0]
     c6: call    ryo_h_AddrAbs
     cb: call    fn1
     d0: nop     [rcx-20h]
     d7: mov     qword ptr [rbp-60h],0
     df: cmp     qword ptr [rbp-60h],4
     e4: setb    [rbp-49h]
     e8: test    byte ptr [rbp-49h],0FFh
     ec: je      13Eh
     ee: mov     qword ptr [rbp-60h],4
     f6: mov     r8,[rbp-60h]
     fa: mov     rcx,7FFFFFFFFFFFFFFFh
    104: cmp     r8,rcx
    107: setbe   [rbp-4Ah]
    10b: test    byte ptr [rbp-4Ah],0FFh
    10f: je      13Eh
    111: mov     r10,[rbp-48h]
    115: sub     r10,[rbp-40h]
    119: mov     [rbp-20h],r10
    11d: mov     qword ptr [rbp-60h],4
    125: mov     edi,0FFFFFFE0h
    12a: mov     esi,0FFFFFFE0h
    12f: mov     edx,0FFFFFFA0h
    134: call    ryo_h_DivUW64
    139: jmp     0A0h
    13e: mov     edi,0FFFFFF80h
    143: lea     rsi,[k2]
    14a: call    ryo_h_AddrAbs
    14f: mov     qword ptr [rbp-78h],49h
    157: mov     edi,0FFFFFF90h
    15c: lea     rsi,[k3]
    163: call    ryo_h_AddrAbs
    168: lea     rdi,[sym4]
    16f: lea     rsi,[site5]
    176: mov     edx,0FFFFFFA0h
    17b: call    ryo_h_CallExt
    180: test    rax,rax
    183: je      190h
    185: call    rax
    187: nop     [rcx-20h]
    18e: jmp     1A0h
    190: mov     rdi,rbp
    193: lea     rsi,[ro+4]
    19a: call    qword ptr [sym6]
    1a0: call    ryo_h_Unreachable
    1a5: ud2

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
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-30h],rdx
     24: mov     [rbp-20h],rax
     28: mov     [rbp-18h],rdx
     2c: mov     [rbp-10h],rax
     30: mov     [rbp-8],rdx
     34: mov     edi,0FFFFFFF0h
     39: mov     esi,10h
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-20h],rdx
     24: mov     [rbp-10h],rax
     28: mov     [rbp-8],rdx
     2c: mov     [rbp-20h],rax
     30: mov     [rbp-18h],rdx
     34: mov     edi,0FFFFFFC0h
     39: mov     esi,0FFFFFFE0h
     3e: call    ryo_h_MovW128
     43: mov     edi,0FFFFFFD8h
     48: lea     rsi,[sym0]
     4f: call    ryo_h_AddrSym
     54: mov     rdi,rbp
     57: lea     rsi,[ro+4]
     5e: call    qword ptr [sym1]
     64: xor     edi,edi
     66: xor     esi,esi
     68: call    ryo_h_Ret
     6d: leave
     6e: ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     [rbp-30h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-38h],rdx
     24: mov     [rbp-28h],rax
     28: mov     [rbp-20h],rdx
     2c: mov     [rbp-18h],rax
     30: mov     [rbp-10h],rdx
     34: mov     rsi,[rbp+18h]
     38: mov     [rbp-50h],rsi
     3c: mov     edi,0FFFFFFA0h
     41: mov     esi,0FFFFFFE8h
     46: call    ryo_h_MovW128
     4b: mov     rax,[rbp+20h]
     4f: mov     [rbp-48h],rax
     53: call    fn0
     58: nop     [rcx-8]
     5f: mov     edi,0FFFFFFF8h
     64: mov     esi,8
     69: call    ryo_h_Ret
     6e: leave
     6f: ret

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
      f: lea     rdx,[rbp+10h]
     13: mov     [rbp-68h],rdx
     17: mov     [rbp-0E0h],rdx
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
     58: .long   152h
     5c: .long   274h
     60: mov     edi,0FFFFFF80h
     65: lea     rsi,[k1]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-78h],11h
     79: mov     rdx,[rbp-80h]
     7d: mov     [rbp-0A0h],rdx
     84: mov     rsi,[rbp-78h]
     88: mov     [rbp-98h],rsi
     8f: mov     [rbp-90h],rdx
     96: mov     [rbp-88h],rdx
     9d: mov     edi,0FFFFFF48h
     a2: lea     rsi,[k2]
     a9: call    ryo_h_AddrAbs
     ae: mov     qword ptr [rbp-0B0h],11h
     b9: mov     rdx,[rbp-0B0h]
     c0: mov     [rbp-0A8h],rdx
     c7: shl     rdx,1
     cb: mov     [rbp-0A0h],rdx
     d2: or      rdx,1
     d6: mov     [rbp-98h],rdx
     dd: mov     [rbp-90h],rdx
     e4: mov     rsi,[rbp-88h]
     eb: mov     [rbp-70h],rsi
     ef: mov     [rbp-68h],rdx
     f3: mov     edi,0FFFFFF20h
     f8: mov     esi,0FFFFFF90h
     fd: call    ryo_h_MovW128
    102: mov     edi,0FFFFFF30h
    107: lea     rsi,[k3]
    10e: call    ryo_h_AddrAbs
    113: lea     rdi,[sym4]
    11a: lea     rsi,[site5]
    121: mov     edx,0FFFFFF40h
    126: call    ryo_h_CallExt
    12b: test    rax,rax
    12e: je      13Bh
    130: call    rax
    132: nop     [rcx-20h]
    139: jmp     14Bh
    13b: mov     rdi,rbp
    13e: lea     rsi,[ro+4]
    145: call    qword ptr [sym6]
    14b: call    ryo_h_Unreachable
    150: ud2
    152: mov     rax,[rbp-50h]
    156: mov     [rbp-68h],rax
    15a: mov     [rbp-0E0h],rax
    161: mov     edi,0FFFFFF28h
    166: lea     rsi,[k7]
    16d: mov     edx,10h
    172: call    ryo_h_Const
    177: call    fn8
    17c: nop     [rcx-88h]
    183: jmp     208h
    188: nop     [rax+rax]
    190: mov     edi,0FFFFFFE8h
    195: mov     esi,0FFFFFFB8h
    19a: mov     edx,18h
    19f: call    ryo_h_Copy
    1a4: mov     edi,0FFFFFFE8h
    1a9: mov     esi,18h
    1ae: call    ryo_h_Ret
    1b3: leave
    1b4: ret
    1b5: nop     [rax+rax]
    1be: xchg    ax,ax
    1c0: lea     rax,[rbp-48h]
    1c4: mov     [rbp-0C0h],rax
    1cb: mov     [rbp-0E0h],rax
    1d2: call    fn9
    1d7: nop     [rcx-0C0h]
    1de: jmp     200h
    1e0: mov     edi,0FFFFFFD0h
    1e5: call    ryo_h_Resume
    1ea: ud2
    1ec: nop     [rax]
    1f0: jmp     1E0h
    1f2: nop     [rax+rax]
    1fb: nop     [rax+rax]
    200: test    byte ptr [rbp-21h],0FFh
    204: je      1E0h
    206: jmp     1F0h
    208: mov     edi,0FFFFFF88h
    20d: mov     esi,0FFFFFF78h
    212: call    ryo_h_MovW128
    217: mov     edi,0FFFFFFB8h
    21c: mov     esi,0FFFFFF88h
    221: call    ryo_h_MovW128
    226: mov     qword ptr [rbp-38h],0
    22e: lea     rdx,[rbp-48h]
    232: mov     [rbp-50h],rdx
    236: mov     byte ptr [rbp-21h],0
    23a: mov     edi,0FFFFFFA0h
    23f: mov     esi,10h
    244: call    ryo_h_MovW128
    249: mov     rax,[rbp-50h]
    24d: mov     [rbp-0E0h],rax
    254: mov     edi,0FFFFFF28h
    259: mov     esi,0FFFFFFA0h
    25e: call    ryo_h_MovW128
    263: call    fn10
    268: nop     [rcx-20h]
    26f: jmp     190h
    274: call    ryo_h_Unreachable
    279: ud2
    27b: nop     [rax+rax]
    280: lea     rdi,[sym11]
    287: lea     rsi,[site12]
    28e: mov     edx,0FFFFFF40h
    293: call    ryo_h_CallExt
    298: test    rax,rax
    29b: je      2A8h
    29d: call    rax
    29f: nop     [rcx-0B8h]
    2a6: jmp     2B8h
    2a8: mov     rdi,rbp
    2ab: lea     rsi,[ro+20]
    2b2: call    qword ptr [sym13]
    2b8: call    ryo_h_Unreachable
    2bd: ud2
    2bf: mov     rdi,rax
    2c2: mov     esi,0FFFFFFD0h
    2c7: call    ryo_h_Lpad
    2cc: jmp     200h
    2d1: mov     rdi,rax
    2d4: mov     esi,0FFFFFFD0h
    2d9: call    ryo_h_Lpad
    2de: jmp     280h
    2e0: mov     rdi,rax
    2e3: mov     esi,0FFFFFFD0h
    2e8: call    ryo_h_Lpad
    2ed: jmp     1C0h

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
     34: mov     rdx,[rbp+10h]
     38: mov     rdx,[rdx+10h]
     3c: mov     [rbp-48h],rdx
     40: mov     [rbp-38h],rax
     44: mov     [rbp-30h],rdx
     48: mov     [rbp-28h],rax
     4c: mov     [rbp-20h],rdx
     50: mov     edi,0FFFFFFA0h
     55: mov     esi,0FFFFFFD8h
     5a: call    ryo_h_MovW128
     5f: call    fn1
     64: nop     [rcx-18h]
     6b: mov     edi,0FFFFFFE8h
     70: mov     esi,18h
     75: call    ryo_h_Ret
     7a: leave
     7b: ret

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-38h],rax
     14: mov     [rbp-30h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-38h],rdx
     24: mov     [rbp-28h],rax
     28: mov     [rbp-20h],rdx
     2c: mov     [rbp-18h],rax
     30: mov     [rbp-10h],rdx
     34: mov     edi,0FFFFFFB0h
     39: mov     esi,0FFFFFFE8h
     3e: call    ryo_h_MovW128
     43: mov     rax,[rbp+18h]
     47: mov     [rbp-40h],rax
     4b: call    fn0
     50: nop     [rcx-1]
     57: mov     edi,0FFFFFFFFh
     5c: mov     esi,1
     61: call    ryo_h_Ret
     66: leave
     67: ret

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
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-30h],rdx
     24: mov     [rbp-20h],rax
     28: mov     [rbp-18h],rdx
     2c: mov     [rbp-10h],rax
     30: mov     [rbp-8],rdx
     34: mov     edi,0FFFFFFF0h
     39: mov     esi,10h
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-30h],rax
     14: mov     [rbp-28h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-30h],rdx
     24: mov     [rbp-20h],rax
     28: mov     [rbp-18h],rdx
     2c: mov     [rbp-10h],rax
     30: mov     [rbp-8],rdx
     34: mov     edi,0FFFFFFF0h
     39: mov     esi,10h
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-20h],rdx
     24: mov     [rbp-10h],rax
     28: mov     [rbp-8],rdx
     2c: mov     [rbp-20h],rax
     30: mov     [rbp-18h],rdx
     34: mov     edi,0FFFFFFC0h
     39: mov     esi,0FFFFFFE0h
     3e: call    ryo_h_MovW128
     43: mov     edi,0FFFFFFD8h
     48: lea     rsi,[sym0]
     4f: call    ryo_h_AddrSym
     54: mov     rdi,rbp
     57: lea     rsi,[ro+4]
     5e: call    qword ptr [sym1]
     64: xor     edi,edi
     66: xor     esi,esi
     68: call    ryo_h_Ret
     6d: leave
     6e: ret

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
     43: mov     rdx,[rbp-8]
     47: mov     [rbp-18h],rdx
     4b: mov     rsi,[rbp+10h]
     4f: mov     [rbp-40h],rsi
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
      f: lea     rdx,[rbp+10h]
     13: mov     [rbp-68h],rdx
     17: mov     [rbp-0E0h],rdx
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
     58: .long   152h
     5c: .long   27eh
     60: mov     edi,0FFFFFF80h
     65: lea     rsi,[k1]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-78h],11h
     79: mov     rdx,[rbp-80h]
     7d: mov     [rbp-0A0h],rdx
     84: mov     rsi,[rbp-78h]
     88: mov     [rbp-98h],rsi
     8f: mov     [rbp-90h],rdx
     96: mov     [rbp-88h],rdx
     9d: mov     edi,0FFFFFF48h
     a2: lea     rsi,[k2]
     a9: call    ryo_h_AddrAbs
     ae: mov     qword ptr [rbp-0B0h],11h
     b9: mov     rdx,[rbp-0B0h]
     c0: mov     [rbp-0A8h],rdx
     c7: shl     rdx,1
     cb: mov     [rbp-0A0h],rdx
     d2: or      rdx,1
     d6: mov     [rbp-98h],rdx
     dd: mov     [rbp-90h],rdx
     e4: mov     rsi,[rbp-88h]
     eb: mov     [rbp-70h],rsi
     ef: mov     [rbp-68h],rdx
     f3: mov     edi,0FFFFFF20h
     f8: mov     esi,0FFFFFF90h
     fd: call    ryo_h_MovW128
    102: mov     edi,0FFFFFF30h
    107: lea     rsi,[k3]
    10e: call    ryo_h_AddrAbs
    113: lea     rdi,[sym4]
    11a: lea     rsi,[site5]
    121: mov     edx,0FFFFFF40h
    126: call    ryo_h_CallExt
    12b: test    rax,rax
    12e: je      13Bh
    130: call    rax
    132: nop     [rcx-20h]
    139: jmp     14Bh
    13b: mov     rdi,rbp
    13e: lea     rsi,[ro+4]
    145: call    qword ptr [sym6]
    14b: call    ryo_h_Unreachable
    150: ud2
    152: mov     rax,[rbp-50h]
    156: mov     [rbp-68h],rax
    15a: mov     [rbp-0E0h],rax
    161: mov     edi,0FFFFFF28h
    166: lea     rsi,[k7]
    16d: mov     edx,10h
    172: call    ryo_h_Const
    177: call    fn8
    17c: nop     [rcx-88h]
    183: jmp     208h
    188: nop     [rax+rax]
    190: mov     edi,0FFFFFFE8h
    195: mov     esi,0FFFFFFB8h
    19a: mov     edx,18h
    19f: call    ryo_h_Copy
    1a4: mov     edi,0FFFFFFE8h
    1a9: mov     esi,18h
    1ae: call    ryo_h_Ret
    1b3: leave
    1b4: ret
    1b5: nop     [rax+rax]
    1be: xchg    ax,ax
    1c0: lea     rax,[rbp-48h]
    1c4: mov     [rbp-0C0h],rax
    1cb: mov     [rbp-0E0h],rax
    1d2: call    fn9
    1d7: nop     [rcx-0C0h]
    1de: jmp     200h
    1e0: mov     edi,0FFFFFFD0h
    1e5: call    ryo_h_Resume
    1ea: ud2
    1ec: nop     [rax]
    1f0: jmp     1E0h
    1f2: nop     [rax+rax]
    1fb: nop     [rax+rax]
    200: test    byte ptr [rbp-21h],0FFh
    204: je      1E0h
    206: jmp     1F0h
    208: mov     edi,0FFFFFF88h
    20d: mov     esi,0FFFFFF78h
    212: call    ryo_h_MovW128
    217: mov     edi,0FFFFFFB8h
    21c: mov     esi,0FFFFFF88h
    221: call    ryo_h_MovW128
    226: mov     qword ptr [rbp-38h],0
    22e: lea     rdx,[rbp-48h]
    232: mov     [rbp-50h],rdx
    236: mov     byte ptr [rbp-21h],0
    23a: mov     edi,0FFFFFF98h
    23f: mov     esi,10h
    244: mov     edx,18h
    249: call    ryo_h_Copy
    24e: mov     rax,[rbp-50h]
    252: mov     [rbp-0E0h],rax
    259: mov     edi,0FFFFFF28h
    25e: mov     esi,0FFFFFF98h
    263: mov     edx,18h
    268: call    ryo_h_Copy
    26d: call    fn10
    272: nop     [rcx-20h]
    279: jmp     190h
    27e: call    ryo_h_Unreachable
    283: ud2
    285: nop     [rax+rax]
    28e: xchg    ax,ax
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
    2dc: jmp     200h
    2e1: mov     rdi,rax
    2e4: mov     esi,0FFFFFFD0h
    2e9: call    ryo_h_Lpad
    2ee: jmp     290h
    2f0: mov     rdi,rax
    2f3: mov     esi,0FFFFFFD0h
    2f8: call    ryo_h_Lpad
    2fd: jmp     1C0h

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-10h],rax
     14: mov     rdx,[rbp+10h]
     18: mov     rdx,[rdx]
     1b: mov     [rbp-8],rdx
     1f: mov     rcx,[rbp-10h]
     23: mov     [rdx],rcx
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
     11: mov     rdx,[rbp+10h]
     15: mov     [rbp-18h],rdx
     19: mov     rsi,[rbp+18h]
     1d: mov     [rbp-20h],rsi
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
     27: imul    r8,[rbp-18h],20h
     2c: mov     [rbp-10h],r8
     30: cmp     r8,1000h
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
     66: imul    rdx,[rbp-18h],30h
     6b: mov     [rbp-10h],rdx
     6f: cmp     rdx,1000h
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
     d2: mov     rdx,[rbp+20h]
     d6: mov     [rbp-28h],rdx
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
     27: imul    r8,[rbp-20h],20h
     2c: mov     [rbp-18h],r8
     30: cmp     r8,1000h
     37: ja      43h
     39: mov     qword ptr [rbp-8],20h
     41: jmp     6Fh
     43: mov     qword ptr [rbp-20h],4
     4b: imul    rdx,[rbp-20h],30h
     50: mov     [rbp-18h],rdx
     54: cmp     rdx,1000h
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
     48: mov     rdx,[rbp+18h]
     4c: mov     [rbp-30h],rdx
     50: mov     [rbp-68h],rax
     54: mov     rsi,[rbp-10h]
     58: mov     [rbp-40h],rsi
     5c: mov     [rbp-70h],rsi
     60: mov     byte ptr [rbp-81h],1
     67: test    byte ptr [rbp-81h],0FFh
     6e: je      11Ch
     74: jmp     0C0h
     76: nop     [rax+rax]
     7f: nop
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
     c8: mov     rdx,[rbp-40h]
     cc: mov     [rbp-80h],rdx
     d0: mov     [rbp-0C0h],rax
     d7: mov     [rbp-0B8h],rdx
     de: mov     qword ptr [rbp-0B0h],4
     e9: mov     qword ptr [rbp-0A8h],4
     f4: mov     r8,[rbp-58h]
     f8: mov     [rbp-0A0h],r8
     ff: mov     edi,0FFFFFF68h
    104: lea     rsi,[k2]
    10b: call    ryo_h_AddrAbs
    110: call    fn3
    115: nop     [rcx-40h]
    11c: imul    rax,[rbp-58h],4
    121: mov     [rbp-88h],rax
    128: mov     edi,0FFFFFF90h
    12d: mov     esi,0FFFFFF98h
    132: mov     edx,0FFFFFF78h
    137: call    ryo_h_Memcpy
    13c: mov     byte ptr [rbp-81h],1
    143: test    byte ptr [rbp-81h],0FFh
    14a: je      170h
    14c: mov     qword ptr [rbp-88h],4
    157: cmp     qword ptr [rbp-88h],0
    15f: je      1B5h
    161: jmp     1BFh
    163: nop     [rax+rax]
    16c: nop     [rax]
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-8],rax
    178: jmp     80h
    17d: nop     [rax]
    180: mov     rax,[rbp-58h]
    184: mov     [rbp-0C0h],rax
    18b: mov     rdx,[rbp-68h]
    18f: mov     [rbp-0B8h],rdx
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
      c: lea     rdx,[rbp+18h]
     10: mov     [rbp-28h],rdx
     14: lea     rsi,[rbp+10h]
     18: mov     [rbp-30h],rsi
     1c: mov     [rbp-40h],rdx
     20: mov     [rbp-38h],rsi
     24: call    fn0
     29: nop     [rcx-19h]
     30: test    byte ptr [rbp-19h],0FFh
     34: je      44h
     36: mov     byte ptr [rbp-9],0
     3a: mov     rsi,[rbp+10h]
     3e: mov     [rbp-8],rsi
     42: jmp     4Ch
     44: mov     rax,[rbp+18h]
     48: mov     [rbp-8],rax
     4c: mov     edi,0FFFFFFF8h
     51: mov     esi,8
     56: call    ryo_h_Ret
     5b: leave
     5c: ret
     5d: nop     [rax]
     60: jmp     82h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     edi,0FFFFFFE8h
     75: call    ryo_h_Resume
     7a: ud2
     7c: nop     [rax]
     80: jmp     70h
     82: test    byte ptr [rbp-9],0FFh
     86: je      70h
     88: jmp     80h
     8a: mov     rdi,rax
     8d: mov     esi,0FFFFFFE8h
     92: call    ryo_h_Lpad
     97: jmp     60h

fn <usize as std::cmp::Ord>::min
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-9],1
      c: lea     rdx,[rbp+18h]
     10: mov     [rbp-28h],rdx
     14: lea     rsi,[rbp+10h]
     18: mov     [rbp-30h],rsi
     1c: mov     [rbp-40h],rdx
     20: mov     [rbp-38h],rsi
     24: call    fn0
     29: nop     [rcx-19h]
     30: test    byte ptr [rbp-19h],0FFh
     34: je      40h
     36: mov     rdx,[rbp+18h]
     3a: mov     [rbp-8],rdx
     3e: jmp     4Ch
     40: mov     byte ptr [rbp-9],0
     44: mov     rdx,[rbp+10h]
     48: mov     [rbp-8],rdx
     4c: mov     edi,0FFFFFFF8h
     51: mov     esi,8
     56: call    ryo_h_Ret
     5b: leave
     5c: ret
     5d: nop     [rax]
     60: jmp     82h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     edi,0FFFFFFE8h
     75: call    ryo_h_Resume
     7a: ud2
     7c: nop     [rax]
     80: jmp     70h
     82: test    byte ptr [rbp-9],0FFh
     86: je      70h
     88: jmp     80h
     8a: mov     rdi,rax
     8d: mov     esi,0FFFFFFE8h
     92: call    ryo_h_Lpad
     97: jmp     60h

fn <usize as std::iter::Step>::forward_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-9],1
      c: test    byte ptr [rbp-9],0FFh
     10: je      3Fh
     12: mov     rsi,[rbp+10h]
     16: mov     [rbp-30h],rsi
     1a: mov     rdi,[rbp+18h]
     1e: mov     [rbp-28h],rdi
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
     13: mov     rdx,[rbp+18h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-28h],rdx
     1e: cmp     rdx,rax
     21: jb      4Fh
     23: sub     rdx,rax
     26: mov     [rbp-38h],rdx
     2a: mov     [rbp-40h],rdx
     2e: mov     qword ptr [rbp-48h],1
     36: mov     rdi,[rbp-38h]
     3a: mov     [rbp-18h],rdi
     3e: mov     edi,0FFFFFFF0h
     43: mov     esi,0FFFFFFB8h
     48: call    ryo_h_MovW128
     4d: jmp     6Dh
     4f: mov     qword ptr [rbp-18h],0
     57: mov     edi,0FFFFFFF0h
     5c: lea     rsi,[k0]
     63: mov     edx,10h
     68: call    ryo_h_Const
     6d: mov     edi,0FFFFFFE8h
     72: mov     esi,18h
     77: call    ryo_h_Ret
     7c: leave
     7d: ret

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     rdx,[rbp+20h]
     14: cmp     rdx,rax
     17: jb      68h
     19: mov     [rbp-40h],rdx
     1d: mov     [rbp-38h],rax
     21: mov     rsi,[rbp+28h]
     25: mov     [rbp-30h],rsi
     29: lea     rdi,[sym0]
     30: lea     rsi,[site1]
     37: mov     edx,0FFFFFFE0h
     3c: call    ryo_h_CallExt
     41: test    rax,rax
     44: je      51h
     46: call    rax
     48: nop     [rcx-11h]
     4f: jmp     61h
     51: mov     rdi,rbp
     54: lea     rsi,[ro+4]
     5b: call    qword ptr [sym2]
     61: call    ryo_h_Unreachable
     66: ud2
     68: mov     rax,[rbp+10h]
     6c: imul    rcx,[rbp+20h],8
     71: add     rax,rcx
     74: mov     [rbp-20h],rax
     78: mov     [rbp-8],rax
     7c: mov     edi,0FFFFFFF8h
     81: mov     esi,8
     86: call    ryo_h_Ret
     8b: leave
     8c: ret

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
     39: mov     rdx,[rbp-10h]
     3d: mov     [rbp-48h],rdx
     41: mov     rsi,[rbp-8]
     45: mov     [rbp-40h],rsi
     49: mov     [rbp-38h],rdx
     4d: mov     [rbp-30h],rdx
     51: mov     edi,0FFFFFFA0h
     56: lea     rsi,[k1]
     5d: call    ryo_h_AddrAbs
     62: mov     qword ptr [rbp-58h],0D6h
     6a: mov     rdx,[rbp-58h]
     6e: mov     [rbp-50h],rdx
     72: shl     rdx,1
     76: mov     [rbp-48h],rdx
     7a: or      rdx,1
     7e: mov     [rbp-40h],rdx
     82: mov     [rbp-38h],rdx
     86: mov     rsi,[rbp-30h]
     8a: mov     [rbp-28h],rsi
     8e: mov     [rbp-20h],rdx
     92: mov     edi,0FFFFFF70h
     97: mov     esi,0FFFFFFD8h
     9c: call    ryo_h_MovW128
     a1: mov     byte ptr [rbp-80h],0
     a5: mov     rdx,[rbp+20h]
     a9: mov     [rbp-78h],rdx
     ad: lea     rdi,[sym2]
     b4: lea     rsi,[site3]
     bb: mov     edx,0FFFFFF98h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-10h]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+4]
     df: call    qword ptr [sym4]
     e5: call    ryo_h_Unreachable
     ea: ud2

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
     1a: mov     esi,[rbp-54h]
     1d: mov     [rbp-1Ch],esi
     20: cmp     esi,40h
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
     81: mov     rdx,[rbp+10h]
     85: mov     rdx,[rdx]
     88: mov     [rbp-58h],rdx
     8c: xor     rdx,rax
     8f: mov     [rbp-60h],rdx
     93: mov     rsi,[rbp+10h]
     97: mov     rcx,[rbp-60h]
     9b: mov     [rsi],rcx
     9e: mov     rdi,[rbp+10h]
     a2: mov     rdi,[rdi]
     a5: mov     [rbp-30h],rdi
     a9: mov     dword ptr [rbp-54h],7
     b0: mov     r9d,[rbp-54h]
     b4: mov     [rbp-34h],r9d
     b8: cmp     r9d,40h
     bc: jb      10Eh
     be: mov     edi,0FFFFFF90h
     c3: lea     rsi,[k4]
     ca: call    ryo_h_AddrAbs
     cf: lea     rdi,[sym5]
     d6: lea     rsi,[site6]
     dd: mov     edx,0FFFFFFA8h
     e2: call    ryo_h_CallExt
     e7: test    rax,rax
     ea: je      0F7h
     ec: call    rax
     ee: nop     [rcx-4Dh]
     f5: jmp     107h
     f7: mov     rdi,rbp
     fa: lea     rsi,[ro+4]
    101: call    qword ptr [sym7]
    107: call    ryo_h_Unreachable
    10c: ud2
    10e: mov     rax,[rbp-30h]
    112: shr     rax,7
    116: mov     [rbp-28h],rax
    11a: mov     rdx,[rbp+10h]
    11e: mov     rdx,[rdx]
    121: mov     [rbp-58h],rdx
    125: xor     rdx,rax
    128: mov     [rbp-60h],rdx
    12c: mov     rsi,[rbp+10h]
    130: mov     rcx,[rbp-60h]
    134: mov     [rsi],rcx
    137: mov     rdi,[rbp+10h]
    13b: mov     rdi,[rdi]
    13e: mov     [rbp-48h],rdi
    142: mov     dword ptr [rbp-54h],11h
    149: mov     r9d,[rbp-54h]
    14d: mov     [rbp-4Ch],r9d
    151: cmp     r9d,40h
    155: jb      1A7h
    157: mov     edi,0FFFFFF90h
    15c: lea     rsi,[k8]
    163: call    ryo_h_AddrAbs
    168: lea     rdi,[sym9]
    16f: lea     rsi,[site10]
    176: mov     edx,0FFFFFFA8h
    17b: call    ryo_h_CallExt
    180: test    rax,rax
    183: je      190h
    185: call    rax
    187: nop     [rcx-4Dh]
    18e: jmp     1A0h
    190: mov     rdi,rbp
    193: lea     rsi,[ro+4]
    19a: call    qword ptr [sym11]
    1a0: call    ryo_h_Unreachable
    1a5: ud2
    1a7: mov     rax,[rbp-48h]
    1ab: shl     rax,11h
    1af: mov     [rbp-40h],rax
    1b3: mov     rdx,[rbp+10h]
    1b7: mov     rdx,[rdx]
    1ba: mov     [rbp-58h],rdx
    1be: xor     rdx,rax
    1c1: mov     [rbp-60h],rdx
    1c5: mov     rsi,[rbp+10h]
    1c9: mov     rcx,[rbp-60h]
    1cd: mov     [rsi],rcx
    1d0: mov     rdi,[rbp+10h]
    1d4: mov     rdi,[rdi]
    1d7: mov     [rbp-8],rdi
    1db: mov     edi,0FFFFFFF8h
    1e0: mov     esi,8
    1e5: call    ryo_h_Ret
    1ea: leave
    1eb: ret

fn alloc::raw_vec::RawVec::<u32>::grow_one
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rax]
     13: mov     [rbp-28h],rax
     17: mov     [rbp-20h],rax
     1b: mov     rdx,[rbp-8]
     1f: mov     [rbp-60h],rdx
     23: mov     [rbp-58h],rax
     27: mov     qword ptr [rbp-50h],1
     2f: mov     edi,0FFFFFFB8h
     34: lea     rsi,[k0]
     3b: mov     edx,10h
     40: call    ryo_h_Const
     45: lea     rdi,[sym1]
     4c: lea     rsi,[site2]
     53: mov     edx,0FFFFFFC8h
     58: call    ryo_h_CallExt
     5d: test    rax,rax
     60: je      6Dh
     62: call    rax
     64: nop     [rcx-18h]
     6b: jmp     7Dh
     6d: mov     rdi,rbp
     70: lea     rsi,[ro+4]
     77: call    qword ptr [sym3]
     7d: mov     edi,0FFFFFFCCh
     82: mov     esi,0FFFFFFE8h
     87: mov     rdx,0FFFFFFFFFFFFFFFFh
     8e: xor     ecx,ecx
     90: xor     r8d,r8d
     93: mov     r9d,1
     99: call    ryo_h_DiscrNicheW64
     9e: mov     edi,0FFFFFFD0h
     a3: mov     esi,0FFFFFFCCh
     a8: call    ryo_h_ZextW32W64
     ad: mov     edi,0FFFFFFD0h
     b2: xor     esi,esi
     b4: mov     edx,2
     b9: call    ryo_h_SwitchDenseW64
     be: lea     rcx,[0D0h]
     c5: movsxd  rax,[rcx+rax*4]
     c9: add     rax,rcx
     cc: jmp     rax
     ce: int3
     cf: int3
     d0: .long   139h
     d4: .long   dch
     d8: .long   144h
     dc: mov     edi,0FFFFFFD8h
     e1: mov     esi,0FFFFFFE8h
     e6: call    ryo_h_MovW128
     eb: mov     edi,0FFFFFFA0h
     f0: mov     esi,0FFFFFFD8h
     f5: call    ryo_h_MovW128
     fa: lea     rdi,[sym4]
    101: lea     rsi,[site5]
    108: mov     edx,0FFFFFFC8h
    10d: call    ryo_h_CallExt
    112: test    rax,rax
    115: je      122h
    117: call    rax
    119: nop     [rcx]
    120: jmp     132h
    122: mov     rdi,rbp
    125: lea     rsi,[ro+20]
    12c: call    qword ptr [sym6]
    132: call    ryo_h_Unreachable
    137: ud2
    139: xor     edi,edi
    13b: xor     esi,esi
    13d: call    ryo_h_Ret
    142: leave
    143: ret
    144: call    ryo_h_Unreachable
    149: ud2

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
    134: movzx   edx,byte ptr [rbp-42h]
    138: xor     dl,1
    13b: mov     [rbp-41h],dl
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
     10: mov     rdx,[rbp+28h]
     14: mov     [rbp-40h],rdx
     18: mov     edx,[rdx]
     1a: mov     [rbp-14h],edx
     1d: mov     rsi,[rbp+18h]
     21: mov     [rbp-50h],rsi
     25: mov     qword ptr [rbp-48h],1Fh
     2d: call    fn0
     32: nop     [rcx-20h]
     39: mov     edi,0FFFFFFD0h
     3e: mov     esi,0FFFFFFECh
     43: call    ryo_h_ZextW32W64
     48: mov     rax,[rbp-10h]
     4c: mov     [rbp-38h],rax
     50: mov     rdx,[rbp-30h]
     54: xor     rdx,rax
     57: mov     [rbp-28h],rdx
     5b: mov     rsi,[rbp-20h]
     5f: mov     [rbp-50h],rsi
     63: mov     [rbp-48h],rdx
     67: call    fn1
     6c: nop     [rcx-8]
     73: mov     edi,0FFFFFFF8h
     78: mov     esi,8
     7d: call    ryo_h_Ret
     82: leave
     83: ret

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
     28: mov     rdi,[rbp+10h]
     2c: mov     [rbp-30h],rdi
     30: mov     r8,[rbp+18h]
     34: mov     [rbp-28h],r8
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
     95: mov     rdi,[rbp+10h]
     99: mov     [rbp-30h],rdi
     9d: mov     r8,[rbp+18h]
     a1: mov     [rbp-28h],r8
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
     e7: mov     rdx,[rbp+18h]
     eb: mov     [rbp-28h],rdx
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
     2d: mov     rdx,[rbp-30h]
     31: mov     [rbp-28h],rdx
     35: mov     [rbp-20h],rax
     39: mov     edi,0FFFFFFF0h
     3e: mov     esi,0FFFFFFD8h
     43: call    ryo_h_MovW128
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

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
     2d: mov     rdx,[rbp-30h]
     31: mov     [rbp-28h],rdx
     35: mov     [rbp-20h],rax
     39: mov     edi,0FFFFFFF0h
     3e: mov     esi,0FFFFFFD8h
     43: call    ryo_h_MovW128
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

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
     2d: mov     rdx,[rbp-30h]
     31: mov     [rbp-28h],rdx
     35: mov     [rbp-20h],rax
     39: mov     edi,0FFFFFFF0h
     3e: mov     esi,0FFFFFFD8h
     43: call    ryo_h_MovW128
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,10h
     52: call    ryo_h_Ret
     57: leave
     58: ret

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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-38h],rdx
     1b: mov     edi,0FFFFFFD8h
     20: mov     esi,0FFFFFFE0h
     25: mov     edx,0FFFFFFD0h
     2a: mov     ecx,0FFFFFFC8h
     2f: call    ryo_h_AddOvfUW64
     34: movzx   eax,byte ptr [rbp-20h]
     38: mov     [rbp-11h],al
     3b: test    byte ptr [rbp-11h],0FFh
     3f: je      111h
     45: mov     edi,0FFFFFFF0h
     4a: lea     rsi,[k0]
     51: call    ryo_h_AddrAbs
     56: mov     qword ptr [rbp-8],0BAh
     5e: mov     rdx,[rbp-10h]
     62: mov     [rbp-48h],rdx
     66: mov     rsi,[rbp-8]
     6a: mov     [rbp-40h],rsi
     6e: mov     [rbp-38h],rdx
     72: mov     [rbp-30h],rdx
     76: mov     edi,0FFFFFFA0h
     7b: lea     rsi,[k1]
     82: call    ryo_h_AddrAbs
     87: mov     qword ptr [rbp-58h],0BAh
     8f: mov     rdx,[rbp-58h]
     93: mov     [rbp-50h],rdx
     97: shl     rdx,1
     9b: mov     [rbp-48h],rdx
     9f: or      rdx,1
     a3: mov     [rbp-40h],rdx
     a7: mov     [rbp-38h],rdx
     ab: mov     rsi,[rbp-30h]
     af: mov     [rbp-28h],rsi
     b3: mov     [rbp-20h],rdx
     b7: mov     edi,0FFFFFF70h
     bc: mov     esi,0FFFFFFD8h
     c1: call    ryo_h_MovW128
     c6: mov     byte ptr [rbp-80h],0
     ca: mov     rdx,[rbp+20h]
     ce: mov     [rbp-78h],rdx
     d2: lea     rdi,[sym2]
     d9: lea     rsi,[site3]
     e0: mov     edx,0FFFFFF98h
     e5: call    ryo_h_CallExt
     ea: test    rax,rax
     ed: je      0FAh
     ef: call    rax
     f1: nop     [rcx-10h]
     f8: jmp     10Ah
     fa: mov     rdi,rbp
     fd: lea     rsi,[ro+4]
    104: call    qword ptr [sym4]
    10a: call    ryo_h_Unreachable
    10f: ud2
    111: xor     edi,edi
    113: xor     esi,esi
    115: call    ryo_h_Ret
    11a: leave
    11b: ret

fn core::num::<impl usize>::unchecked_sub::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-38h],rdx
     1b: mov     edi,0FFFFFFD8h
     20: mov     esi,0FFFFFFE0h
     25: mov     edx,0FFFFFFD0h
     2a: mov     ecx,0FFFFFFC8h
     2f: call    ryo_h_SubOvfUW64
     34: movzx   eax,byte ptr [rbp-20h]
     38: mov     [rbp-11h],al
     3b: test    byte ptr [rbp-11h],0FFh
     3f: je      111h
     45: mov     edi,0FFFFFFF0h
     4a: lea     rsi,[k0]
     51: call    ryo_h_AddrAbs
     56: mov     qword ptr [rbp-8],0BAh
     5e: mov     rdx,[rbp-10h]
     62: mov     [rbp-48h],rdx
     66: mov     rsi,[rbp-8]
     6a: mov     [rbp-40h],rsi
     6e: mov     [rbp-38h],rdx
     72: mov     [rbp-30h],rdx
     76: mov     edi,0FFFFFFA0h
     7b: lea     rsi,[k1]
     82: call    ryo_h_AddrAbs
     87: mov     qword ptr [rbp-58h],0BAh
     8f: mov     rdx,[rbp-58h]
     93: mov     [rbp-50h],rdx
     97: shl     rdx,1
     9b: mov     [rbp-48h],rdx
     9f: or      rdx,1
     a3: mov     [rbp-40h],rdx
     a7: mov     [rbp-38h],rdx
     ab: mov     rsi,[rbp-30h]
     af: mov     [rbp-28h],rsi
     b3: mov     [rbp-20h],rdx
     b7: mov     edi,0FFFFFF70h
     bc: mov     esi,0FFFFFFD8h
     c1: call    ryo_h_MovW128
     c6: mov     byte ptr [rbp-80h],0
     ca: mov     rdx,[rbp+20h]
     ce: mov     [rbp-78h],rdx
     d2: lea     rdi,[sym2]
     d9: lea     rsi,[site3]
     e0: mov     edx,0FFFFFF98h
     e5: call    ryo_h_CallExt
     ea: test    rax,rax
     ed: je      0FAh
     ef: call    rax
     f1: nop     [rcx-10h]
     f8: jmp     10Ah
     fa: mov     rdi,rbp
     fd: lea     rsi,[ro+4]
    104: call    qword ptr [sym4]
    10a: call    ryo_h_Unreachable
    10f: ud2
    111: xor     edi,edi
    113: xor     esi,esi
    115: call    ryo_h_Ret
    11a: leave
    11b: ret

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
     37: mov     rdx,[rbp+18h]
     3b: mov     [rbp-40h],rdx
     3f: mov     [rbp-30h],rax
     43: imul    rcx,[rbp-8],8
     48: add     rax,rcx
     4b: mov     [rbp-38h],rax
     4f: mov     byte ptr [rbp-69h],1
     53: test    byte ptr [rbp-69h],0FFh
     57: je      0B8h
     59: jmp     6Bh
     5b: nop     [rax+rax]
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
     90: mov     rdi,[rbp-50h]
     94: mov     [rbp-88h],rdi
     9b: mov     edi,0FFFFFF80h
     a0: lea     rsi,[k0]
     a7: call    ryo_h_AddrAbs
     ac: call    fn1
     b1: nop     [rcx-48h]
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-60h],rax
     c0: mov     rdx,[rbp-50h]
     c4: mov     [rbp-58h],rdx
     c8: mov     [rbp-18h],rax
     cc: mov     [rbp-10h],rdx
     d0: mov     byte ptr [rbp-69h],0
     d4: test    byte ptr [rbp-69h],0FFh
     d8: je      0FAh
     da: jmp     0F0h
     dc: nop     [rax]
     e0: mov     byte ptr [rbp-69h],1
     e4: test    byte ptr [rbp-69h],0FFh
     e8: je      173h
     ee: jmp     126h
     f0: mov     rax,[rbp-38h]
     f4: mov     [rbp-58h],rax
     f8: jmp     0E0h
     fa: mov     rax,[rbp-50h]
     fe: mov     [rbp-68h],rax
    102: mov     qword ptr [rbp-70h],0
    10a: mov     rsi,[rbp-70h]
    10e: sub     rsi,rax
    111: mov     [rbp-60h],rsi
    115: mov     rdi,[rbp-38h]
    119: imul    rcx,rsi,8
    11d: add     rdi,rcx
    120: mov     [rbp-58h],rdi
    124: jmp     0E0h
    126: mov     rax,[rbp-58h]
    12a: mov     [rbp-60h],rax
    12e: mov     [rbp-0A0h],rax
    135: mov     qword ptr [rbp-98h],8
    140: mov     qword ptr [rbp-90h],4
    14b: mov     rdi,[rbp-50h]
    14f: mov     [rbp-88h],rdi
    156: mov     edi,0FFFFFF80h
    15b: lea     rsi,[k2]
    162: call    ryo_h_AddrAbs
    167: call    fn3
    16c: nop     [rcx-48h]
    173: mov     rax,[rbp-58h]
    177: mov     [rbp-68h],rax
    17b: mov     rdx,[rbp-50h]
    17f: mov     [rbp-60h],rdx
    183: mov     [rbp-28h],rax
    187: mov     [rbp-20h],rdx
    18b: mov     edi,0FFFFFF60h
    190: mov     esi,0FFFFFFE8h
    195: call    ryo_h_MovW128
    19a: mov     edi,0FFFFFF70h
    19f: mov     esi,0FFFFFFD8h
    1a4: call    ryo_h_MovW128
    1a9: mov     rax,[rbp-50h]
    1ad: mov     [rbp-80h],rax
    1b1: call    fn4
    1b6: nop     [rcx-28h]
    1bd: jmp     60h

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
     a2: mov     rdx,[rbp-60h]
     a6: mov     [rbp-80h],rdx
     aa: mov     rsi,[rbp-58h]
     ae: mov     [rbp-78h],rsi
     b2: mov     [rbp-70h],rdx
     b6: mov     [rbp-68h],rdx
     ba: mov     edi,0FFFFFF68h
     bf: lea     rsi,[k3]
     c6: call    ryo_h_AddrAbs
     cb: mov     qword ptr [rbp-90h],9
     d6: mov     rdx,[rbp-90h]
     dd: mov     [rbp-88h],rdx
     e4: shl     rdx,1
     e8: mov     [rbp-80h],rdx
     ec: or      rdx,1
     f0: mov     [rbp-78h],rdx
     f4: mov     [rbp-70h],rdx
     f8: mov     rsi,[rbp-68h]
     fc: mov     [rbp-50h],rsi
    100: mov     [rbp-48h],rdx
    104: mov     edi,0FFFFFF40h
    109: mov     esi,0FFFFFFB0h
    10e: call    ryo_h_MovW128
    113: mov     rax,[rbp+28h]
    117: mov     [rbp-0B0h],rax
    11e: lea     rdi,[sym4]
    125: lea     rsi,[site5]
    12c: mov     edx,0FFFFFF60h
    131: call    ryo_h_CallExt
    136: test    rax,rax
    139: je      146h
    13b: call    rax
    13d: nop     [rcx-20h]
    144: jmp     156h
    146: mov     rdi,rbp
    149: lea     rsi,[ro+4]
    150: call    qword ptr [sym6]
    156: call    ryo_h_Unreachable
    15b: ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-38h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-30h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-28h],rsi
     23: mov     [rbp-40h],rdx
     27: mov     byte ptr [rbp-81h],1
     2e: test    byte ptr [rbp-81h],0FFh
     35: je      60h
     37: mov     r9,[rbp+20h]
     3b: mov     [rbp-0B0h],r9
     42: mov     [rbp-0A8h],rax
     49: mov     r10,[rbp+28h]
     4d: mov     [rbp-0A0h],r10
     54: call    fn0
     59: nop     [rcx-20h]
     60: mov     byte ptr [rbp-81h],1
     67: test    byte ptr [rbp-81h],0FFh
     6e: je      0B7h
     70: mov     rsi,[rbp-30h]
     74: mov     [rbp-58h],rsi
     78: mov     [rbp-0B0h],rsi
     7f: mov     qword ptr [rbp-0A8h],8
     8a: mov     qword ptr [rbp-0A0h],4
     95: mov     r9,[rbp+20h]
     99: mov     [rbp-98h],r9
     a0: mov     r10,[rbp+28h]
     a4: mov     [rbp-90h],r10
     ab: call    fn1
     b0: nop     [rcx-30h]
     b7: mov     rax,[rbp-40h]
     bb: mov     [rbp-60h],rax
     bf: mov     rdx,[rbp+20h]
     c3: mov     [rbp-58h],rdx
     c7: mov     [rbp-50h],rax
     cb: mov     [rbp-48h],rdx
     cf: mov     rsi,[rbp-40h]
     d3: imul    rcx,[rbp+20h],8
     d8: add     rsi,rcx
     db: mov     [rbp-68h],rsi
     df: mov     rdi,[rbp-38h]
     e3: sub     rdi,[rbp+20h]
     e7: mov     [rbp-70h],rdi
     eb: mov     byte ptr [rbp-81h],1
     f2: test    byte ptr [rbp-81h],0FFh
     f9: je      13Ah
     fb: mov     [rbp-78h],rsi
     ff: mov     [rbp-0B0h],rsi
    106: mov     qword ptr [rbp-0A8h],8
    111: mov     qword ptr [rbp-0A0h],4
    11c: mov     [rbp-98h],rdi
    123: mov     r8,[rbp+28h]
    127: mov     [rbp-90h],r8
    12e: call    fn2
    133: nop     [rcx-30h]
    13a: mov     rax,[rbp-68h]
    13e: mov     [rbp-80h],rax
    142: mov     rdx,[rbp-70h]
    146: mov     [rbp-78h],rdx
    14a: mov     [rbp-60h],rax
    14e: mov     [rbp-58h],rdx
    152: mov     edi,0FFFFFFE0h
    157: mov     esi,0FFFFFFB0h
    15c: call    ryo_h_MovW128
    161: mov     edi,0FFFFFFF0h
    166: mov     esi,0FFFFFFA0h
    16b: call    ryo_h_MovW128
    170: mov     edi,0FFFFFFE0h
    175: mov     esi,20h
    17a: call    ryo_h_Ret
    17f: leave
    180: ret

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
     ac: jae     22Ch
     b2: mov     rdx,[rbp-58h]
     b6: mov     [rbp-60h],rdx
     ba: mov     rsi,[rbp-38h]
     be: mov     [rbp-10h],rsi
     c2: cmp     rdx,rsi
     c5: jb      125h
     c7: mov     [rbp-0B0h],rdx
     ce: mov     [rbp-0A8h],rsi
     d5: mov     edi,0FFFFFF60h
     da: lea     rsi,[k4]
     e1: call    ryo_h_AddrAbs
     e6: lea     rdi,[sym5]
     ed: lea     rsi,[site6]
     f4: mov     edx,0FFFFFF80h
     f9: call    ryo_h_CallExt
     fe: test    rax,rax
    101: je      10Eh
    103: call    rax
    105: nop     [rcx-78h]
    10c: jmp     11Eh
    10e: mov     rdi,rbp
    111: lea     rsi,[ro+4]
    118: call    qword ptr [sym7]
    11e: call    ryo_h_Unreachable
    123: ud2
    125: mov     rax,[rbp-40h]
    129: imul    rcx,[rbp-60h],8
    12e: add     rax,rcx
    131: mov     [rbp-80h],rax
    135: mov     [rbp-8],rax
    139: mov     rdx,[rbp+30h]
    13d: sub     rdx,1
    141: mov     [rbp-70h],rdx
    145: mov     rsi,[rbp-58h]
    149: mov     [rbp-78h],rsi
    14d: sub     rdx,rsi
    150: mov     [rbp-68h],rdx
    154: mov     rdi,[rbp-48h]
    158: mov     [rbp-28h],rdi
    15c: cmp     rdx,rdi
    15f: jb      1BFh
    161: mov     [rbp-0B0h],rdx
    168: mov     [rbp-0A8h],rdi
    16f: mov     edi,0FFFFFF60h
    174: lea     rsi,[k8]
    17b: call    ryo_h_AddrAbs
    180: lea     rdi,[sym9]
    187: lea     rsi,[site10]
    18e: mov     edx,0FFFFFF80h
    193: call    ryo_h_CallExt
    198: test    rax,rax
    19b: je      1A8h
    19d: call    rax
    19f: nop     [rcx-78h]
    1a6: jmp     1B8h
    1a8: mov     rdi,rbp
    1ab: lea     rsi,[ro+4]
    1b2: call    qword ptr [sym11]
    1b8: call    ryo_h_Unreachable
    1bd: ud2
    1bf: mov     rax,[rbp-50h]
    1c3: imul    rcx,[rbp-68h],8
    1c8: add     rax,rcx
    1cb: mov     [rbp-80h],rax
    1cf: mov     [rbp-20h],rax
    1d3: mov     rdx,[rbp-8]
    1d7: mov     [rbp-70h],rdx
    1db: mov     [rbp-78h],rax
    1df: mov     qword ptr [rbp-88h],8
    1ea: mov     edi,0FFFFFF80h
    1ef: mov     esi,0FFFFFF90h
    1f4: xor     edx,edx
    1f6: mov     ecx,8
    1fb: call    ryo_h_LoadCopy
    200: mov     edi,0FFFFFF90h
    205: mov     esi,0FFFFFF88h
    20a: mov     edx,0FFFFFF78h
    20f: call    ryo_h_Memcpy
    214: mov     edi,0FFFFFF88h
    219: xor     esi,esi
    21b: mov     edx,0FFFFFF80h
    220: mov     ecx,8
    225: call    ryo_h_StoreCopy
    22a: jmp     237h
    22c: xor     edi,edi
    22e: xor     esi,esi
    230: call    ryo_h_Ret
    235: leave
    236: ret
    237: mov     rax,[rbp-58h]
    23b: add     rax,1
    23f: mov     [rbp-58h],rax
    243: jmp     0A0h

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
     ac: jae     22Ch
     b2: mov     rdx,[rbp-58h]
     b6: mov     [rbp-60h],rdx
     ba: mov     rsi,[rbp-38h]
     be: mov     [rbp-10h],rsi
     c2: cmp     rdx,rsi
     c5: jb      125h
     c7: mov     [rbp-0B0h],rdx
     ce: mov     [rbp-0A8h],rsi
     d5: mov     edi,0FFFFFF60h
     da: lea     rsi,[k4]
     e1: call    ryo_h_AddrAbs
     e6: lea     rdi,[sym5]
     ed: lea     rsi,[site6]
     f4: mov     edx,0FFFFFF80h
     f9: call    ryo_h_CallExt
     fe: test    rax,rax
    101: je      10Eh
    103: call    rax
    105: nop     [rcx-78h]
    10c: jmp     11Eh
    10e: mov     rdi,rbp
    111: lea     rsi,[ro+4]
    118: call    qword ptr [sym7]
    11e: call    ryo_h_Unreachable
    123: ud2
    125: mov     rax,[rbp-40h]
    129: imul    rcx,[rbp-60h],4
    12e: add     rax,rcx
    131: mov     [rbp-80h],rax
    135: mov     [rbp-8],rax
    139: mov     rdx,[rbp+30h]
    13d: sub     rdx,1
    141: mov     [rbp-70h],rdx
    145: mov     rsi,[rbp-58h]
    149: mov     [rbp-78h],rsi
    14d: sub     rdx,rsi
    150: mov     [rbp-68h],rdx
    154: mov     rdi,[rbp-48h]
    158: mov     [rbp-28h],rdi
    15c: cmp     rdx,rdi
    15f: jb      1BFh
    161: mov     [rbp-0B0h],rdx
    168: mov     [rbp-0A8h],rdi
    16f: mov     edi,0FFFFFF60h
    174: lea     rsi,[k8]
    17b: call    ryo_h_AddrAbs
    180: lea     rdi,[sym9]
    187: lea     rsi,[site10]
    18e: mov     edx,0FFFFFF80h
    193: call    ryo_h_CallExt
    198: test    rax,rax
    19b: je      1A8h
    19d: call    rax
    19f: nop     [rcx-78h]
    1a6: jmp     1B8h
    1a8: mov     rdi,rbp
    1ab: lea     rsi,[ro+4]
    1b2: call    qword ptr [sym11]
    1b8: call    ryo_h_Unreachable
    1bd: ud2
    1bf: mov     rax,[rbp-50h]
    1c3: imul    rcx,[rbp-68h],4
    1c8: add     rax,rcx
    1cb: mov     [rbp-80h],rax
    1cf: mov     [rbp-20h],rax
    1d3: mov     rdx,[rbp-8]
    1d7: mov     [rbp-70h],rdx
    1db: mov     [rbp-78h],rax
    1df: mov     qword ptr [rbp-88h],4
    1ea: mov     edi,0FFFFFF80h
    1ef: mov     esi,0FFFFFF90h
    1f4: xor     edx,edx
    1f6: mov     ecx,4
    1fb: call    ryo_h_LoadCopy
    200: mov     edi,0FFFFFF90h
    205: mov     esi,0FFFFFF88h
    20a: mov     edx,0FFFFFF78h
    20f: call    ryo_h_Memcpy
    214: mov     edi,0FFFFFF88h
    219: xor     esi,esi
    21b: mov     edx,0FFFFFF80h
    220: mov     ecx,4
    225: call    ryo_h_StoreCopy
    22a: jmp     237h
    22c: xor     edi,edi
    22e: xor     esi,esi
    230: call    ryo_h_Ret
    235: leave
    236: ret
    237: mov     rax,[rbp-58h]
    23b: add     rax,1
    23f: mov     [rbp-58h],rax
    243: jmp     0A0h

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
     39: mov     rdx,[rbp-10h]
     3d: mov     [rbp-48h],rdx
     41: mov     rsi,[rbp-8]
     45: mov     [rbp-40h],rsi
     49: mov     [rbp-38h],rdx
     4d: mov     [rbp-30h],rdx
     51: mov     edi,0FFFFFFA0h
     56: lea     rsi,[k1]
     5d: call    ryo_h_AddrAbs
     62: mov     qword ptr [rbp-58h],0DDh
     6a: mov     rdx,[rbp-58h]
     6e: mov     [rbp-50h],rdx
     72: shl     rdx,1
     76: mov     [rbp-48h],rdx
     7a: or      rdx,1
     7e: mov     [rbp-40h],rdx
     82: mov     [rbp-38h],rdx
     86: mov     rsi,[rbp-30h]
     8a: mov     [rbp-28h],rsi
     8e: mov     [rbp-20h],rdx
     92: mov     edi,0FFFFFF70h
     97: mov     esi,0FFFFFFD8h
     9c: call    ryo_h_MovW128
     a1: mov     byte ptr [rbp-80h],0
     a5: mov     rdx,[rbp+20h]
     a9: mov     [rbp-78h],rdx
     ad: lea     rdi,[sym2]
     b4: lea     rsi,[site3]
     bb: mov     edx,0FFFFFF98h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-10h]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+4]
     df: call    qword ptr [sym4]
     e5: call    ryo_h_Unreachable
     ea: ud2

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: cmp     rax,[rbp+10h]
     13: jae     2Ah
     15: mov     rdx,[rbp+20h]
     19: cmp     rdx,[rbp+10h]
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
     43: mov     rdx,[rbp-10h]
     47: mov     [rbp-48h],rdx
     4b: mov     rsi,[rbp-8]
     4f: mov     [rbp-40h],rsi
     53: mov     [rbp-38h],rdx
     57: mov     [rbp-30h],rdx
     5b: mov     edi,0FFFFFFA0h
     60: lea     rsi,[k1]
     67: call    ryo_h_AddrAbs
     6c: mov     qword ptr [rbp-58h],0DAh
     74: mov     rdx,[rbp-58h]
     78: mov     [rbp-50h],rdx
     7c: shl     rdx,1
     80: mov     [rbp-48h],rdx
     84: or      rdx,1
     88: mov     [rbp-40h],rdx
     8c: mov     [rbp-38h],rdx
     90: mov     rsi,[rbp-30h]
     94: mov     [rbp-28h],rsi
     98: mov     [rbp-20h],rdx
     9c: mov     edi,0FFFFFF70h
     a1: mov     esi,0FFFFFFD8h
     a6: call    ryo_h_MovW128
     ab: mov     byte ptr [rbp-80h],0
     af: mov     rdx,[rbp+28h]
     b3: mov     [rbp-78h],rdx
     b7: lea     rdi,[sym2]
     be: lea     rsi,[site3]
     c5: mov     edx,0FFFFFF98h
     ca: call    ryo_h_CallExt
     cf: test    rax,rax
     d2: je      0DFh
     d4: call    rax
     d6: nop     [rcx-10h]
     dd: jmp     0EFh
     df: mov     rdi,rbp
     e2: lea     rsi,[ro+4]
     e9: call    qword ptr [sym4]
     ef: call    ryo_h_Unreachable
     f4: ud2

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
     37: mov     rdx,[rbp+18h]
     3b: mov     [rbp-40h],rdx
     3f: mov     [rbp-30h],rax
     43: imul    rcx,[rbp-8],4
     48: add     rax,rcx
     4b: mov     [rbp-38h],rax
     4f: mov     byte ptr [rbp-69h],1
     53: test    byte ptr [rbp-69h],0FFh
     57: je      0B8h
     59: jmp     6Bh
     5b: nop     [rax+rax]
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
     90: mov     rdi,[rbp-50h]
     94: mov     [rbp-88h],rdi
     9b: mov     edi,0FFFFFF80h
     a0: lea     rsi,[k0]
     a7: call    ryo_h_AddrAbs
     ac: call    fn1
     b1: nop     [rcx-48h]
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-60h],rax
     c0: mov     rdx,[rbp-50h]
     c4: mov     [rbp-58h],rdx
     c8: mov     [rbp-18h],rax
     cc: mov     [rbp-10h],rdx
     d0: mov     byte ptr [rbp-69h],0
     d4: test    byte ptr [rbp-69h],0FFh
     d8: je      0FAh
     da: jmp     0F0h
     dc: nop     [rax]
     e0: mov     byte ptr [rbp-69h],1
     e4: test    byte ptr [rbp-69h],0FFh
     e8: je      173h
     ee: jmp     126h
     f0: mov     rax,[rbp-38h]
     f4: mov     [rbp-58h],rax
     f8: jmp     0E0h
     fa: mov     rax,[rbp-50h]
     fe: mov     [rbp-68h],rax
    102: mov     qword ptr [rbp-70h],0
    10a: mov     rsi,[rbp-70h]
    10e: sub     rsi,rax
    111: mov     [rbp-60h],rsi
    115: mov     rdi,[rbp-38h]
    119: imul    rcx,rsi,4
    11d: add     rdi,rcx
    120: mov     [rbp-58h],rdi
    124: jmp     0E0h
    126: mov     rax,[rbp-58h]
    12a: mov     [rbp-60h],rax
    12e: mov     [rbp-0A0h],rax
    135: mov     qword ptr [rbp-98h],4
    140: mov     qword ptr [rbp-90h],4
    14b: mov     rdi,[rbp-50h]
    14f: mov     [rbp-88h],rdi
    156: mov     edi,0FFFFFF80h
    15b: lea     rsi,[k2]
    162: call    ryo_h_AddrAbs
    167: call    fn3
    16c: nop     [rcx-48h]
    173: mov     rax,[rbp-58h]
    177: mov     [rbp-68h],rax
    17b: mov     rdx,[rbp-50h]
    17f: mov     [rbp-60h],rdx
    183: mov     [rbp-28h],rax
    187: mov     [rbp-20h],rdx
    18b: mov     edi,0FFFFFF60h
    190: mov     esi,0FFFFFFE8h
    195: call    ryo_h_MovW128
    19a: mov     edi,0FFFFFF70h
    19f: mov     esi,0FFFFFFD8h
    1a4: call    ryo_h_MovW128
    1a9: mov     rax,[rbp-50h]
    1ad: mov     [rbp-80h],rax
    1b1: call    fn4
    1b6: nop     [rcx-28h]
    1bd: jmp     60h

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
     a2: mov     rdx,[rbp-60h]
     a6: mov     [rbp-80h],rdx
     aa: mov     rsi,[rbp-58h]
     ae: mov     [rbp-78h],rsi
     b2: mov     [rbp-70h],rdx
     b6: mov     [rbp-68h],rdx
     ba: mov     edi,0FFFFFF68h
     bf: lea     rsi,[k3]
     c6: call    ryo_h_AddrAbs
     cb: mov     qword ptr [rbp-90h],9
     d6: mov     rdx,[rbp-90h]
     dd: mov     [rbp-88h],rdx
     e4: shl     rdx,1
     e8: mov     [rbp-80h],rdx
     ec: or      rdx,1
     f0: mov     [rbp-78h],rdx
     f4: mov     [rbp-70h],rdx
     f8: mov     rsi,[rbp-68h]
     fc: mov     [rbp-50h],rsi
    100: mov     [rbp-48h],rdx
    104: mov     edi,0FFFFFF40h
    109: mov     esi,0FFFFFFB0h
    10e: call    ryo_h_MovW128
    113: mov     rax,[rbp+28h]
    117: mov     [rbp-0B0h],rax
    11e: lea     rdi,[sym4]
    125: lea     rsi,[site5]
    12c: mov     edx,0FFFFFF60h
    131: call    ryo_h_CallExt
    136: test    rax,rax
    139: je      146h
    13b: call    rax
    13d: nop     [rcx-20h]
    144: jmp     156h
    146: mov     rdi,rbp
    149: lea     rsi,[ro+4]
    150: call    qword ptr [sym6]
    156: call    ryo_h_Unreachable
    15b: ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-38h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-30h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-28h],rsi
     23: mov     [rbp-40h],rdx
     27: mov     byte ptr [rbp-81h],1
     2e: test    byte ptr [rbp-81h],0FFh
     35: je      60h
     37: mov     r9,[rbp+20h]
     3b: mov     [rbp-0B0h],r9
     42: mov     [rbp-0A8h],rax
     49: mov     r10,[rbp+28h]
     4d: mov     [rbp-0A0h],r10
     54: call    fn0
     59: nop     [rcx-20h]
     60: mov     byte ptr [rbp-81h],1
     67: test    byte ptr [rbp-81h],0FFh
     6e: je      0B7h
     70: mov     rsi,[rbp-30h]
     74: mov     [rbp-58h],rsi
     78: mov     [rbp-0B0h],rsi
     7f: mov     qword ptr [rbp-0A8h],4
     8a: mov     qword ptr [rbp-0A0h],4
     95: mov     r9,[rbp+20h]
     99: mov     [rbp-98h],r9
     a0: mov     r10,[rbp+28h]
     a4: mov     [rbp-90h],r10
     ab: call    fn1
     b0: nop     [rcx-30h]
     b7: mov     rax,[rbp-40h]
     bb: mov     [rbp-60h],rax
     bf: mov     rdx,[rbp+20h]
     c3: mov     [rbp-58h],rdx
     c7: mov     [rbp-50h],rax
     cb: mov     [rbp-48h],rdx
     cf: mov     rsi,[rbp-40h]
     d3: imul    rcx,[rbp+20h],4
     d8: add     rsi,rcx
     db: mov     [rbp-68h],rsi
     df: mov     rdi,[rbp-38h]
     e3: sub     rdi,[rbp+20h]
     e7: mov     [rbp-70h],rdi
     eb: mov     byte ptr [rbp-81h],1
     f2: test    byte ptr [rbp-81h],0FFh
     f9: je      13Ah
     fb: mov     [rbp-78h],rsi
     ff: mov     [rbp-0B0h],rsi
    106: mov     qword ptr [rbp-0A8h],4
    111: mov     qword ptr [rbp-0A0h],4
    11c: mov     [rbp-98h],rdi
    123: mov     r8,[rbp+28h]
    127: mov     [rbp-90h],r8
    12e: call    fn2
    133: nop     [rcx-30h]
    13a: mov     rax,[rbp-68h]
    13e: mov     [rbp-80h],rax
    142: mov     rdx,[rbp-70h]
    146: mov     [rbp-78h],rdx
    14a: mov     [rbp-60h],rax
    14e: mov     [rbp-58h],rdx
    152: mov     edi,0FFFFFFE0h
    157: mov     esi,0FFFFFFB0h
    15c: call    ryo_h_MovW128
    161: mov     edi,0FFFFFFF0h
    166: mov     esi,0FFFFFFA0h
    16b: call    ryo_h_MovW128
    170: mov     edi,0FFFFFFE0h
    175: mov     esi,20h
    17a: call    ryo_h_Ret
    17f: leave
    180: ret

fn core::slice::<impl [u32]>::swap
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-8],rax
     10: mov     rdx,[rbp+20h]
     14: cmp     rdx,rax
     17: jb      68h
     19: mov     [rbp-40h],rdx
     1d: mov     [rbp-38h],rax
     21: mov     rsi,[rbp+30h]
     25: mov     [rbp-30h],rsi
     29: lea     rdi,[sym0]
     30: lea     rsi,[site1]
     37: mov     edx,0FFFFFFE8h
     3c: call    ryo_h_CallExt
     41: test    rax,rax
     44: je      51h
     46: call    rax
     48: nop     [rcx-0Ah]
     4f: jmp     61h
     51: mov     rdi,rbp
     54: lea     rsi,[ro+4]
     5b: call    qword ptr [sym2]
     61: call    ryo_h_Unreachable
     66: ud2
     68: mov     rax,[rbp+28h]
     6c: cmp     rax,[rbp-8]
     70: jb      0C5h
     72: mov     [rbp-40h],rax
     76: mov     rdx,[rbp-8]
     7a: mov     [rbp-38h],rdx
     7e: mov     rsi,[rbp+30h]
     82: mov     [rbp-30h],rsi
     86: lea     rdi,[sym3]
     8d: lea     rsi,[site4]
     94: mov     edx,0FFFFFFE8h
     99: call    ryo_h_CallExt
     9e: test    rax,rax
     a1: je      0AEh
     a3: call    rax
     a5: nop     [rcx-0Ah]
     ac: jmp     0BEh
     ae: mov     rdi,rbp
     b1: lea     rsi,[ro+4]
     b8: call    qword ptr [sym5]
     be: call    ryo_h_Unreachable
     c3: ud2
     c5: mov     edi,0FFFFFFC0h
     ca: mov     esi,10h
     cf: call    ryo_h_MovW128
     d4: mov     rax,[rbp+20h]
     d8: mov     [rbp-30h],rax
     dc: mov     rdx,[rbp+28h]
     e0: mov     [rbp-28h],rdx
     e4: mov     rsi,[rbp+30h]
     e8: mov     [rbp-20h],rsi
     ec: call    fn6
     f1: nop     [rcx-0Ah]
     f8: xor     edi,edi
     fa: xor     esi,esi
     fc: call    ryo_h_Ret
    101: leave
    102: ret

fn core::slice::<impl [u32]>::swap_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     byte ptr [rbp-19h],1
      c: test    byte ptr [rbp-19h],0FFh
     10: je      42h
     12: mov     rsi,[rbp+18h]
     16: mov     [rbp-8],rsi
     1a: mov     [rbp-40h],rsi
     1e: mov     rdi,[rbp+20h]
     22: mov     [rbp-38h],rdi
     26: mov     r8,[rbp+28h]
     2a: mov     [rbp-30h],r8
     2e: mov     r9,[rbp+30h]
     32: mov     [rbp-28h],r9
     36: call    fn0
     3b: nop     [rcx]
     42: mov     rax,[rbp+10h]
     46: mov     [rbp-18h],rax
     4a: mov     rdx,[rbp+18h]
     4e: mov     [rbp-10h],rdx
     52: mov     [rbp-8],rax
     56: imul    rcx,[rbp+20h],4
     5b: add     rax,rcx
     5e: mov     [rbp-10h],rax
     62: mov     rsi,[rbp-8]
     66: imul    rcx,[rbp+28h],4
     6b: add     rsi,rcx
     6e: mov     [rbp-18h],rsi
     72: mov     [rbp-40h],rax
     76: mov     [rbp-38h],rsi
     7a: call    fn1
     7f: nop     [rcx]
     86: xor     edi,edi
     88: xor     esi,esi
     8a: call    ryo_h_Ret
     8f: leave
     90: ret

fn core::slice::copy_from_slice_impl::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-8],rax
     13: mov     rdx,[rbp+28h]
     17: mov     [rbp-10h],rdx
     1b: cmp     rax,rdx
     1e: je      75h
     20: mov     [rbp-90h],rax
     27: mov     [rbp-88h],rdx
     2e: mov     rsi,[rbp+30h]
     32: mov     [rbp-80h],rsi
     36: lea     rdi,[sym0]
     3d: lea     rsi,[site1]
     44: mov     edx,0FFFFFFA8h
     49: call    ryo_h_CallExt
     4e: test    rax,rax
     51: je      5Eh
     53: call    rax
     55: nop     [rcx-10h]
     5c: jmp     6Eh
     5e: mov     rdi,rbp
     61: lea     rsi,[ro+4]
     68: call    qword ptr [sym2]
     6e: call    ryo_h_Unreachable
     73: ud2
     75: mov     rax,[rbp+20h]
     79: mov     [rbp-20h],rax
     7d: mov     rdx,[rbp+28h]
     81: mov     [rbp-18h],rdx
     85: mov     [rbp-38h],rax
     89: mov     rsi,[rbp+10h]
     8d: mov     [rbp-30h],rsi
     91: mov     rdi,[rbp+18h]
     95: mov     [rbp-28h],rdi
     99: mov     [rbp-40h],rsi
     9d: mov     byte ptr [rbp-51h],1
     a1: test    byte ptr [rbp-51h],0FFh
     a5: je      0FAh
     a7: mov     r10,[rbp-20h]
     ab: mov     [rbp-48h],r10
     af: mov     r11,[rbp-30h]
     b3: mov     [rbp-50h],r11
     b7: mov     [rbp-90h],r10
     be: mov     [rbp-88h],r11
     c5: mov     qword ptr [rbp-80h],4
     cd: mov     qword ptr [rbp-78h],4
     d5: mov     r8,[rbp-8]
     d9: mov     [rbp-70h],r8
     dd: mov     edi,0FFFFFF98h
     e2: lea     rsi,[k3]
     e9: call    ryo_h_AddrAbs
     ee: call    fn4
     f3: nop     [rcx-30h]
     fa: imul    rax,[rbp-8],4
     ff: mov     [rbp-58h],rax
    103: mov     edi,0FFFFFFC0h
    108: mov     esi,0FFFFFFC8h
    10d: mov     edx,0FFFFFFA8h
    112: call    ryo_h_Memcpy
    117: xor     edi,edi
    119: xor     esi,esi
    11b: call    ryo_h_Ret
    120: leave
    121: ret

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
     6e: mov     rdx,[rbp-18h]
     72: mov     [rbp-48h],rdx
     76: mov     byte ptr [rbp-59h],1
     7a: test    byte ptr [rbp-59h],0FFh
     7e: je      218h
     84: jmp     1EBh
     89: nop     [rax]
     90: test    byte ptr [rbp-23h],0FFh
     94: je      0A4h
     96: mov     rdx,[rbp-18h]
     9a: add     rdx,1
     9e: mov     [rbp-18h],rdx
     a2: jmp     60h
     a4: jmp     0A6h
     a6: jmp     0F6h
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-30h],rax
     b8: cmp     rax,[rbp-20h]
     bc: jae     0F6h
     be: mov     rdx,[rbp-18h]
     c2: mov     [rbp-48h],rdx
     c6: mov     byte ptr [rbp-59h],1
     ca: test    byte ptr [rbp-59h],0FFh
     ce: je      2FBh
     d4: jmp     2CEh
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
     fe: movzx   edx,byte ptr [rbp-21h]
    102: mov     [rbp-8],dl
    105: mov     edi,0FFFFFFF0h
    10a: mov     esi,10h
    10f: call    ryo_h_Ret
    114: leave
    115: ret
    116: mov     qword ptr [rbp-80h],1
    11e: mov     rdx,[rbp-20h]
    122: mov     [rbp-78h],rdx
    126: mov     edi,0FFFFFF90h
    12b: lea     rsi,[k0]
    132: call    ryo_h_AddrAbs
    137: call    fn1
    13c: nop     [rcx-18h]
    143: mov     qword ptr [rbp-60h],1
    14b: mov     rdx,[rbp-60h]
    14f: cmp     rdx,[rbp-20h]
    153: setb    [rbp-22h]
    157: mov     rsi,[rbp+10h]
    15b: lea     rsi,[rsi+8]
    15f: mov     [rbp-48h],rsi
    163: mov     [rbp-40h],rsi
    167: mov     byte ptr [rbp-59h],1
    16b: test    byte ptr [rbp-59h],0FFh
    16f: je      19Eh
    171: mov     qword ptr [rbp-80h],0
    179: mov     r10,[rbp-20h]
    17d: mov     [rbp-78h],r10
    181: mov     edi,0FFFFFF90h
    186: lea     rsi,[k2]
    18d: call    ryo_h_AddrAbs
    192: call    fn3
    197: nop     [rcx-18h]
    19e: mov     qword ptr [rbp-60h],0
    1a6: mov     rdx,[rbp-60h]
    1aa: cmp     rdx,[rbp-20h]
    1ae: setb    [rbp-22h]
    1b2: mov     rsi,[rbp+10h]
    1b6: mov     [rbp-50h],rsi
    1ba: mov     [rbp-48h],rsi
    1be: mov     rdi,[rbp-40h]
    1c2: mov     [rbp-38h],rdi
    1c6: mov     [rbp-30h],rsi
    1ca: mov     r8,[rbp+20h]
    1ce: mov     [rbp-80h],r8
    1d2: mov     [rbp-78h],rdi
    1d6: mov     [rbp-70h],rsi
    1da: call    fn4
    1df: nop     [rcx-21h]
    1e6: jmp     50h
    1eb: mov     rax,[rbp-48h]
    1ef: mov     [rbp-80h],rax
    1f3: mov     rdx,[rbp-20h]
    1f7: mov     [rbp-78h],rdx
    1fb: mov     edi,0FFFFFF90h
    200: lea     rsi,[k5]
    207: call    ryo_h_AddrAbs
    20c: call    fn6
    211: nop     [rcx-18h]
    218: mov     rax,[rbp-48h]
    21c: cmp     rax,[rbp-20h]
    220: setb    [rbp-24h]
    224: mov     rdx,[rbp+10h]
    228: imul    rcx,rax,8
    22c: add     rdx,rcx
    22f: mov     [rbp-60h],rdx
    233: mov     [rbp-50h],rdx
    237: mov     [rbp-40h],rdx
    23b: mov     rsi,[rbp-18h]
    23f: mov     [rbp-58h],rsi
    243: sub     rsi,1
    247: mov     [rbp-50h],rsi
    24b: mov     byte ptr [rbp-59h],1
    24f: test    byte ptr [rbp-59h],0FFh
    253: je      27Eh
    255: mov     [rbp-80h],rsi
    259: mov     r9,[rbp-20h]
    25d: mov     [rbp-78h],r9
    261: mov     edi,0FFFFFF90h
    266: lea     rsi,[k7]
    26d: call    ryo_h_AddrAbs
    272: call    fn8
    277: nop     [rcx-18h]
    27e: mov     rax,[rbp-50h]
    282: cmp     rax,[rbp-20h]
    286: setb    [rbp-24h]
    28a: mov     rdx,[rbp+10h]
    28e: imul    rcx,rax,8
    292: add     rdx,rcx
    295: mov     [rbp-60h],rdx
    299: mov     [rbp-58h],rdx
    29d: mov     [rbp-48h],rdx
    2a1: mov     rsi,[rbp-40h]
    2a5: mov     [rbp-38h],rsi
    2a9: mov     [rbp-30h],rdx
    2ad: mov     rdi,[rbp+20h]
    2b1: mov     [rbp-80h],rdi
    2b5: mov     [rbp-78h],rsi
    2b9: mov     [rbp-70h],rdx
    2bd: call    fn9
    2c2: nop     [rcx-23h]
    2c9: jmp     90h
    2ce: mov     rax,[rbp-48h]
    2d2: mov     [rbp-80h],rax
    2d6: mov     rdx,[rbp-20h]
    2da: mov     [rbp-78h],rdx
    2de: mov     edi,0FFFFFF90h
    2e3: lea     rsi,[k10]
    2ea: call    ryo_h_AddrAbs
    2ef: call    fn11
    2f4: nop     [rcx-18h]
    2fb: mov     rax,[rbp-48h]
    2ff: cmp     rax,[rbp-20h]
    303: setb    [rbp-24h]
    307: mov     rdx,[rbp+10h]
    30b: imul    rcx,rax,8
    30f: add     rdx,rcx
    312: mov     [rbp-60h],rdx
    316: mov     [rbp-50h],rdx
    31a: mov     [rbp-40h],rdx
    31e: mov     rsi,[rbp-18h]
    322: mov     [rbp-58h],rsi
    326: sub     rsi,1
    32a: mov     [rbp-50h],rsi
    32e: mov     byte ptr [rbp-59h],1
    332: test    byte ptr [rbp-59h],0FFh
    336: je      361h
    338: mov     [rbp-80h],rsi
    33c: mov     r9,[rbp-20h]
    340: mov     [rbp-78h],r9
    344: mov     edi,0FFFFFF90h
    349: lea     rsi,[k12]
    350: call    ryo_h_AddrAbs
    355: call    fn13
    35a: nop     [rcx-18h]
    361: mov     rax,[rbp-50h]
    365: cmp     rax,[rbp-20h]
    369: setb    [rbp-24h]
    36d: mov     rdx,[rbp+10h]
    371: imul    rcx,rax,8
    375: add     rdx,rcx
    378: mov     [rbp-60h],rdx
    37c: mov     [rbp-58h],rdx
    380: mov     [rbp-48h],rdx
    384: mov     rsi,[rbp-40h]
    388: mov     [rbp-38h],rsi
    38c: mov     [rbp-30h],rdx
    390: mov     rdi,[rbp+20h]
    394: mov     [rbp-80h],rdi
    398: mov     [rbp-78h],rsi
    39c: mov     [rbp-70h],rdx
    3a0: call    fn14
    3a5: nop     [rcx-23h]
    3ac: jmp     0E0h

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
     6e: mov     rdx,[rbp-18h]
     72: mov     [rbp-48h],rdx
     76: mov     byte ptr [rbp-59h],1
     7a: test    byte ptr [rbp-59h],0FFh
     7e: je      218h
     84: jmp     1EBh
     89: nop     [rax]
     90: test    byte ptr [rbp-23h],0FFh
     94: je      0A4h
     96: mov     rdx,[rbp-18h]
     9a: add     rdx,1
     9e: mov     [rbp-18h],rdx
     a2: jmp     60h
     a4: jmp     0A6h
     a6: jmp     0F6h
     a8: nop     [rax+rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-30h],rax
     b8: cmp     rax,[rbp-20h]
     bc: jae     0F6h
     be: mov     rdx,[rbp-18h]
     c2: mov     [rbp-48h],rdx
     c6: mov     byte ptr [rbp-59h],1
     ca: test    byte ptr [rbp-59h],0FFh
     ce: je      2FBh
     d4: jmp     2CEh
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
     fe: movzx   edx,byte ptr [rbp-21h]
    102: mov     [rbp-8],dl
    105: mov     edi,0FFFFFFF0h
    10a: mov     esi,10h
    10f: call    ryo_h_Ret
    114: leave
    115: ret
    116: mov     qword ptr [rbp-80h],1
    11e: mov     rdx,[rbp-20h]
    122: mov     [rbp-78h],rdx
    126: mov     edi,0FFFFFF90h
    12b: lea     rsi,[k0]
    132: call    ryo_h_AddrAbs
    137: call    fn1
    13c: nop     [rcx-18h]
    143: mov     qword ptr [rbp-60h],1
    14b: mov     rdx,[rbp-60h]
    14f: cmp     rdx,[rbp-20h]
    153: setb    [rbp-22h]
    157: mov     rsi,[rbp+10h]
    15b: lea     rsi,[rsi+4]
    15f: mov     [rbp-48h],rsi
    163: mov     [rbp-40h],rsi
    167: mov     byte ptr [rbp-59h],1
    16b: test    byte ptr [rbp-59h],0FFh
    16f: je      19Eh
    171: mov     qword ptr [rbp-80h],0
    179: mov     r10,[rbp-20h]
    17d: mov     [rbp-78h],r10
    181: mov     edi,0FFFFFF90h
    186: lea     rsi,[k2]
    18d: call    ryo_h_AddrAbs
    192: call    fn3
    197: nop     [rcx-18h]
    19e: mov     qword ptr [rbp-60h],0
    1a6: mov     rdx,[rbp-60h]
    1aa: cmp     rdx,[rbp-20h]
    1ae: setb    [rbp-22h]
    1b2: mov     rsi,[rbp+10h]
    1b6: mov     [rbp-50h],rsi
    1ba: mov     [rbp-48h],rsi
    1be: mov     rdi,[rbp-40h]
    1c2: mov     [rbp-38h],rdi
    1c6: mov     [rbp-30h],rsi
    1ca: mov     r8,[rbp+20h]
    1ce: mov     [rbp-80h],r8
    1d2: mov     [rbp-78h],rdi
    1d6: mov     [rbp-70h],rsi
    1da: call    fn4
    1df: nop     [rcx-21h]
    1e6: jmp     50h
    1eb: mov     rax,[rbp-48h]
    1ef: mov     [rbp-80h],rax
    1f3: mov     rdx,[rbp-20h]
    1f7: mov     [rbp-78h],rdx
    1fb: mov     edi,0FFFFFF90h
    200: lea     rsi,[k5]
    207: call    ryo_h_AddrAbs
    20c: call    fn6
    211: nop     [rcx-18h]
    218: mov     rax,[rbp-48h]
    21c: cmp     rax,[rbp-20h]
    220: setb    [rbp-24h]
    224: mov     rdx,[rbp+10h]
    228: imul    rcx,rax,4
    22c: add     rdx,rcx
    22f: mov     [rbp-60h],rdx
    233: mov     [rbp-50h],rdx
    237: mov     [rbp-40h],rdx
    23b: mov     rsi,[rbp-18h]
    23f: mov     [rbp-58h],rsi
    243: sub     rsi,1
    247: mov     [rbp-50h],rsi
    24b: mov     byte ptr [rbp-59h],1
    24f: test    byte ptr [rbp-59h],0FFh
    253: je      27Eh
    255: mov     [rbp-80h],rsi
    259: mov     r9,[rbp-20h]
    25d: mov     [rbp-78h],r9
    261: mov     edi,0FFFFFF90h
    266: lea     rsi,[k7]
    26d: call    ryo_h_AddrAbs
    272: call    fn8
    277: nop     [rcx-18h]
    27e: mov     rax,[rbp-50h]
    282: cmp     rax,[rbp-20h]
    286: setb    [rbp-24h]
    28a: mov     rdx,[rbp+10h]
    28e: imul    rcx,rax,4
    292: add     rdx,rcx
    295: mov     [rbp-60h],rdx
    299: mov     [rbp-58h],rdx
    29d: mov     [rbp-48h],rdx
    2a1: mov     rsi,[rbp-40h]
    2a5: mov     [rbp-38h],rsi
    2a9: mov     [rbp-30h],rdx
    2ad: mov     rdi,[rbp+20h]
    2b1: mov     [rbp-80h],rdi
    2b5: mov     [rbp-78h],rsi
    2b9: mov     [rbp-70h],rdx
    2bd: call    fn9
    2c2: nop     [rcx-23h]
    2c9: jmp     90h
    2ce: mov     rax,[rbp-48h]
    2d2: mov     [rbp-80h],rax
    2d6: mov     rdx,[rbp-20h]
    2da: mov     [rbp-78h],rdx
    2de: mov     edi,0FFFFFF90h
    2e3: lea     rsi,[k10]
    2ea: call    ryo_h_AddrAbs
    2ef: call    fn11
    2f4: nop     [rcx-18h]
    2fb: mov     rax,[rbp-48h]
    2ff: cmp     rax,[rbp-20h]
    303: setb    [rbp-24h]
    307: mov     rdx,[rbp+10h]
    30b: imul    rcx,rax,4
    30f: add     rdx,rcx
    312: mov     [rbp-60h],rdx
    316: mov     [rbp-50h],rdx
    31a: mov     [rbp-40h],rdx
    31e: mov     rsi,[rbp-18h]
    322: mov     [rbp-58h],rsi
    326: sub     rsi,1
    32a: mov     [rbp-50h],rsi
    32e: mov     byte ptr [rbp-59h],1
    332: test    byte ptr [rbp-59h],0FFh
    336: je      361h
    338: mov     [rbp-80h],rsi
    33c: mov     r9,[rbp-20h]
    340: mov     [rbp-78h],r9
    344: mov     edi,0FFFFFF90h
    349: lea     rsi,[k12]
    350: call    ryo_h_AddrAbs
    355: call    fn13
    35a: nop     [rcx-18h]
    361: mov     rax,[rbp-50h]
    365: cmp     rax,[rbp-20h]
    369: setb    [rbp-24h]
    36d: mov     rdx,[rbp+10h]
    371: imul    rcx,rax,4
    375: add     rdx,rcx
    378: mov     [rbp-60h],rdx
    37c: mov     [rbp-58h],rdx
    380: mov     [rbp-48h],rdx
    384: mov     rsi,[rbp-40h]
    388: mov     [rbp-38h],rsi
    38c: mov     [rbp-30h],rdx
    390: mov     rdi,[rbp+20h]
    394: mov     [rbp-80h],rdi
    398: mov     [rbp-78h],rsi
    39c: mov     [rbp-70h],rdx
    3a0: call    fn14
    3a5: nop     [rcx-23h]
    3ac: jmp     0E0h

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
     28: mov     rdx,[rbp+18h]
     2c: mov     [rbp-18h],rdx
     30: mov     [rbp-10h],rax
     34: mov     qword ptr [rbp-80h],8
     3c: mov     edi,0FFFFFFD0h
     41: mov     esi,0FFFFFFD8h
     46: mov     edx,0FFFFFF80h
     4b: call    ryo_h_DivUW64
     50: imul    rax,[rbp-30h],4
     55: mov     [rbp-40h],rax
     59: mov     rdx,[rbp-10h]
     5d: imul    rcx,rax,8
     61: add     rdx,rcx
     64: mov     [rbp-38h],rdx
     68: imul    rsi,[rbp-30h],7
     6d: mov     [rbp-48h],rsi
     71: mov     rdi,[rbp-10h]
     75: imul    rcx,rsi,8
     79: add     rdi,rcx
     7c: mov     [rbp-40h],rdi
     80: cmp     qword ptr [rbp-28h],40h
     85: jae     0D6h
     87: mov     r9,[rbp-10h]
     8b: mov     [rbp-58h],r9
     8f: mov     [rbp-60h],rdx
     93: mov     [rbp-68h],rdi
     97: mov     [rbp-0B0h],r9
     9e: mov     [rbp-0A8h],rdx
     a5: mov     [rbp-0A0h],rdi
     ac: mov     r10,[rbp+20h]
     b0: mov     [rbp-98h],r10
     b7: call    fn0
     bc: nop     [rcx-50h]
     c3: mov     byte ptr [rbp-79h],1
     c7: test    byte ptr [rbp-79h],0FFh
     cb: je      19Dh
     d1: jmp     162h
     d6: mov     rax,[rbp-10h]
     da: mov     [rbp-0B0h],rax
     e1: mov     rdx,[rbp-38h]
     e5: mov     [rbp-0A8h],rdx
     ec: mov     rsi,[rbp-40h]
     f0: mov     [rbp-0A0h],rsi
     f7: mov     rdi,[rbp-30h]
     fb: mov     [rbp-98h],rdi
    102: mov     r8,[rbp+20h]
    106: mov     [rbp-90h],r8
    10d: call    fn1
    112: nop     [rcx-50h]
    119: mov     byte ptr [rbp-79h],1
    11d: test    byte ptr [rbp-79h],0FFh
    121: je      2B0h
    127: jmp     275h
    12c: nop     [rax]
    130: mov     rax,[rbp-8]
    134: mov     [rbp-38h],rax
    138: cmp     rax,[rbp-28h]
    13c: setb    [rbp-29h]
    140: mov     byte ptr [rbp-79h],1
    144: test    byte ptr [rbp-79h],0FFh
    148: je      3AAh
    14e: jmp     383h
    153: nop     [rax+rax]
    15c: nop     [rax]
    160: jmp     130h
    162: mov     rax,[rbp-50h]
    166: mov     [rbp-70h],rax
    16a: mov     rdx,[rbp-20h]
    16e: mov     [rbp-78h],rdx
    172: mov     [rbp-0B0h],rax
    179: mov     [rbp-0A8h],rdx
    180: mov     edi,0FFFFFF60h
    185: lea     rsi,[k2]
    18c: call    ryo_h_AddrAbs
    191: call    fn3
    196: nop     [rcx-20h]
    19d: mov     qword ptr [rbp-80h],0
    1a5: cmp     qword ptr [rbp-80h],8
    1aa: setb    [rbp-42h]
    1ae: test    byte ptr [rbp-42h],0FFh
    1b2: je      204h
    1b4: mov     qword ptr [rbp-80h],8
    1bc: mov     r8,[rbp-80h]
    1c0: mov     rcx,7FFFFFFFFFFFFFFFh
    1ca: cmp     r8,rcx
    1cd: setbe   [rbp-43h]
    1d1: test    byte ptr [rbp-43h],0FFh
    1d5: je      204h
    1d7: mov     r10,[rbp-50h]
    1db: sub     r10,[rbp-10h]
    1df: mov     [rbp-8],r10
    1e3: mov     qword ptr [rbp-80h],8
    1eb: mov     edi,0FFFFFFF8h
    1f0: mov     esi,0FFFFFFF8h
    1f5: mov     edx,0FFFFFF80h
    1fa: call    ryo_h_DivUW64
    1ff: jmp     160h
    204: mov     edi,0FFFFFF50h
    209: lea     rsi,[k4]
    210: call    ryo_h_AddrAbs
    215: mov     qword ptr [rbp-0A8h],49h
    220: mov     edi,0FFFFFF60h
    225: lea     rsi,[k5]
    22c: call    ryo_h_AddrAbs
    231: lea     rdi,[sym6]
    238: lea     rsi,[site7]
    23f: mov     edx,0FFFFFF80h
    244: call    ryo_h_CallExt
    249: test    rax,rax
    24c: je      259h
    24e: call    rax
    250: nop     [rcx-20h]
    257: jmp     269h
    259: mov     rdi,rbp
    25c: lea     rsi,[ro+4]
    263: call    qword ptr [sym8]
    269: call    ryo_h_Unreachable
    26e: ud2
    270: jmp     130h
    275: mov     rax,[rbp-50h]
    279: mov     [rbp-58h],rax
    27d: mov     rdx,[rbp-20h]
    281: mov     [rbp-60h],rdx
    285: mov     [rbp-0B0h],rax
    28c: mov     [rbp-0A8h],rdx
    293: mov     edi,0FFFFFF60h
    298: lea     rsi,[k9]
    29f: call    ryo_h_AddrAbs
    2a4: call    fn10
    2a9: nop     [rcx-20h]
    2b0: mov     qword ptr [rbp-80h],0
    2b8: cmp     qword ptr [rbp-80h],8
    2bd: setb    [rbp-42h]
    2c1: test    byte ptr [rbp-42h],0FFh
    2c5: je      317h
    2c7: mov     qword ptr [rbp-80h],8
    2cf: mov     r8,[rbp-80h]
    2d3: mov     rcx,7FFFFFFFFFFFFFFFh
    2dd: cmp     r8,rcx
    2e0: setbe   [rbp-43h]
    2e4: test    byte ptr [rbp-43h],0FFh
    2e8: je      317h
    2ea: mov     r10,[rbp-50h]
    2ee: sub     r10,[rbp-10h]
    2f2: mov     [rbp-8],r10
    2f6: mov     qword ptr [rbp-80h],8
    2fe: mov     edi,0FFFFFFF8h
    303: mov     esi,0FFFFFFF8h
    308: mov     edx,0FFFFFF80h
    30d: call    ryo_h_DivUW64
    312: jmp     270h
    317: mov     edi,0FFFFFF50h
    31c: lea     rsi,[k11]
    323: call    ryo_h_AddrAbs
    328: mov     qword ptr [rbp-0A8h],49h
    333: mov     edi,0FFFFFF60h
    338: lea     rsi,[k12]
    33f: call    ryo_h_AddrAbs
    344: lea     rdi,[sym13]
    34b: lea     rsi,[site14]
    352: mov     edx,0FFFFFF80h
    357: call    ryo_h_CallExt
    35c: test    rax,rax
    35f: je      36Ch
    361: call    rax
    363: nop     [rcx-20h]
    36a: jmp     37Ch
    36c: mov     rdi,rbp
    36f: lea     rsi,[ro+4]
    376: call    qword ptr [sym15]
    37c: call    ryo_h_Unreachable
    381: ud2
    383: movzx   eax,byte ptr [rbp-29h]
    387: mov     [rbp-0B0h],al
    38d: mov     edi,0FFFFFF58h
    392: lea     rsi,[k16]
    399: call    ryo_h_AddrAbs
    39e: call    fn17
    3a3: nop     [rcx-20h]
    3aa: mov     edi,0FFFFFFF8h
    3af: mov     esi,8
    3b4: call    ryo_h_Ret
    3b9: leave
    3ba: ret

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
     28: mov     rdx,[rbp+18h]
     2c: mov     [rbp-18h],rdx
     30: mov     [rbp-10h],rax
     34: mov     qword ptr [rbp-80h],8
     3c: mov     edi,0FFFFFFD0h
     41: mov     esi,0FFFFFFD8h
     46: mov     edx,0FFFFFF80h
     4b: call    ryo_h_DivUW64
     50: imul    rax,[rbp-30h],4
     55: mov     [rbp-40h],rax
     59: mov     rdx,[rbp-10h]
     5d: imul    rcx,rax,4
     61: add     rdx,rcx
     64: mov     [rbp-38h],rdx
     68: imul    rsi,[rbp-30h],7
     6d: mov     [rbp-48h],rsi
     71: mov     rdi,[rbp-10h]
     75: imul    rcx,rsi,4
     79: add     rdi,rcx
     7c: mov     [rbp-40h],rdi
     80: cmp     qword ptr [rbp-28h],40h
     85: jae     0D6h
     87: mov     r9,[rbp-10h]
     8b: mov     [rbp-58h],r9
     8f: mov     [rbp-60h],rdx
     93: mov     [rbp-68h],rdi
     97: mov     [rbp-0B0h],r9
     9e: mov     [rbp-0A8h],rdx
     a5: mov     [rbp-0A0h],rdi
     ac: mov     r10,[rbp+20h]
     b0: mov     [rbp-98h],r10
     b7: call    fn0
     bc: nop     [rcx-50h]
     c3: mov     byte ptr [rbp-79h],1
     c7: test    byte ptr [rbp-79h],0FFh
     cb: je      19Dh
     d1: jmp     162h
     d6: mov     rax,[rbp-10h]
     da: mov     [rbp-0B0h],rax
     e1: mov     rdx,[rbp-38h]
     e5: mov     [rbp-0A8h],rdx
     ec: mov     rsi,[rbp-40h]
     f0: mov     [rbp-0A0h],rsi
     f7: mov     rdi,[rbp-30h]
     fb: mov     [rbp-98h],rdi
    102: mov     r8,[rbp+20h]
    106: mov     [rbp-90h],r8
    10d: call    fn1
    112: nop     [rcx-50h]
    119: mov     byte ptr [rbp-79h],1
    11d: test    byte ptr [rbp-79h],0FFh
    121: je      2B0h
    127: jmp     275h
    12c: nop     [rax]
    130: mov     rax,[rbp-8]
    134: mov     [rbp-38h],rax
    138: cmp     rax,[rbp-28h]
    13c: setb    [rbp-29h]
    140: mov     byte ptr [rbp-79h],1
    144: test    byte ptr [rbp-79h],0FFh
    148: je      3AAh
    14e: jmp     383h
    153: nop     [rax+rax]
    15c: nop     [rax]
    160: jmp     130h
    162: mov     rax,[rbp-50h]
    166: mov     [rbp-70h],rax
    16a: mov     rdx,[rbp-20h]
    16e: mov     [rbp-78h],rdx
    172: mov     [rbp-0B0h],rax
    179: mov     [rbp-0A8h],rdx
    180: mov     edi,0FFFFFF60h
    185: lea     rsi,[k2]
    18c: call    ryo_h_AddrAbs
    191: call    fn3
    196: nop     [rcx-20h]
    19d: mov     qword ptr [rbp-80h],0
    1a5: cmp     qword ptr [rbp-80h],4
    1aa: setb    [rbp-42h]
    1ae: test    byte ptr [rbp-42h],0FFh
    1b2: je      204h
    1b4: mov     qword ptr [rbp-80h],4
    1bc: mov     r8,[rbp-80h]
    1c0: mov     rcx,7FFFFFFFFFFFFFFFh
    1ca: cmp     r8,rcx
    1cd: setbe   [rbp-43h]
    1d1: test    byte ptr [rbp-43h],0FFh
    1d5: je      204h
    1d7: mov     r10,[rbp-50h]
    1db: sub     r10,[rbp-10h]
    1df: mov     [rbp-8],r10
    1e3: mov     qword ptr [rbp-80h],4
    1eb: mov     edi,0FFFFFFF8h
    1f0: mov     esi,0FFFFFFF8h
    1f5: mov     edx,0FFFFFF80h
    1fa: call    ryo_h_DivUW64
    1ff: jmp     160h
    204: mov     edi,0FFFFFF50h
    209: lea     rsi,[k4]
    210: call    ryo_h_AddrAbs
    215: mov     qword ptr [rbp-0A8h],49h
    220: mov     edi,0FFFFFF60h
    225: lea     rsi,[k5]
    22c: call    ryo_h_AddrAbs
    231: lea     rdi,[sym6]
    238: lea     rsi,[site7]
    23f: mov     edx,0FFFFFF80h
    244: call    ryo_h_CallExt
    249: test    rax,rax
    24c: je      259h
    24e: call    rax
    250: nop     [rcx-20h]
    257: jmp     269h
    259: mov     rdi,rbp
    25c: lea     rsi,[ro+4]
    263: call    qword ptr [sym8]
    269: call    ryo_h_Unreachable
    26e: ud2
    270: jmp     130h
    275: mov     rax,[rbp-50h]
    279: mov     [rbp-58h],rax
    27d: mov     rdx,[rbp-20h]
    281: mov     [rbp-60h],rdx
    285: mov     [rbp-0B0h],rax
    28c: mov     [rbp-0A8h],rdx
    293: mov     edi,0FFFFFF60h
    298: lea     rsi,[k9]
    29f: call    ryo_h_AddrAbs
    2a4: call    fn10
    2a9: nop     [rcx-20h]
    2b0: mov     qword ptr [rbp-80h],0
    2b8: cmp     qword ptr [rbp-80h],4
    2bd: setb    [rbp-42h]
    2c1: test    byte ptr [rbp-42h],0FFh
    2c5: je      317h
    2c7: mov     qword ptr [rbp-80h],4
    2cf: mov     r8,[rbp-80h]
    2d3: mov     rcx,7FFFFFFFFFFFFFFFh
    2dd: cmp     r8,rcx
    2e0: setbe   [rbp-43h]
    2e4: test    byte ptr [rbp-43h],0FFh
    2e8: je      317h
    2ea: mov     r10,[rbp-50h]
    2ee: sub     r10,[rbp-10h]
    2f2: mov     [rbp-8],r10
    2f6: mov     qword ptr [rbp-80h],4
    2fe: mov     edi,0FFFFFFF8h
    303: mov     esi,0FFFFFFF8h
    308: mov     edx,0FFFFFF80h
    30d: call    ryo_h_DivUW64
    312: jmp     270h
    317: mov     edi,0FFFFFF50h
    31c: lea     rsi,[k11]
    323: call    ryo_h_AddrAbs
    328: mov     qword ptr [rbp-0A8h],49h
    333: mov     edi,0FFFFFF60h
    338: lea     rsi,[k12]
    33f: call    ryo_h_AddrAbs
    344: lea     rdi,[sym13]
    34b: lea     rsi,[site14]
    352: mov     edx,0FFFFFF80h
    357: call    ryo_h_CallExt
    35c: test    rax,rax
    35f: je      36Ch
    361: call    rax
    363: nop     [rcx-20h]
    36a: jmp     37Ch
    36c: mov     rdi,rbp
    36f: lea     rsi,[ro+4]
    376: call    qword ptr [sym15]
    37c: call    ryo_h_Unreachable
    381: ud2
    383: movzx   eax,byte ptr [rbp-29h]
    387: mov     [rbp-0B0h],al
    38d: mov     edi,0FFFFFF58h
    392: lea     rsi,[k16]
    399: call    ryo_h_AddrAbs
    39e: call    fn17
    3a3: nop     [rcx-20h]
    3aa: mov     edi,0FFFFFFF8h
    3af: mov     esi,8
    3b4: call    ryo_h_Ret
    3b9: leave
    3ba: ret

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-18h],rdx
     18: mov     rsi,[rbp+28h]
     1c: mov     [rbp-40h],rsi
     20: mov     [rbp-38h],rax
     24: mov     [rbp-30h],rdx
     28: call    fn0
     2d: nop     [rcx-9]
     34: mov     rax,[rbp+10h]
     38: mov     [rbp-20h],rax
     3c: mov     rdx,[rbp+20h]
     40: mov     [rbp-18h],rdx
     44: mov     rsi,[rbp+28h]
     48: mov     [rbp-40h],rsi
     4c: mov     [rbp-38h],rax
     50: mov     [rbp-30h],rdx
     54: call    fn1
     59: nop     [rcx-0Ah]
     60: movzx   eax,byte ptr [rbp-9]
     64: cmp     al,[rbp-0Ah]
     67: jne     0B9h
     69: mov     rdx,[rbp+18h]
     6d: mov     [rbp-20h],rdx
     71: mov     rsi,[rbp+20h]
     75: mov     [rbp-18h],rsi
     79: mov     rdi,[rbp+28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-38h],rdx
     85: mov     [rbp-30h],rsi
     89: call    fn2
     8e: nop     [rcx-0Ch]
     95: movzx   eax,byte ptr [rbp-0Ch]
     99: xor     al,[rbp-9]
     9c: mov     [rbp-0Dh],al
     9f: test    byte ptr [rbp-0Dh],0FFh
     a3: je      0AFh
     a5: mov     rsi,[rbp+20h]
     a9: mov     [rbp-8],rsi
     ad: jmp     0B7h
     af: mov     rax,[rbp+18h]
     b3: mov     [rbp-8],rax
     b7: jmp     0C1h
     b9: mov     rax,[rbp+10h]
     bd: mov     [rbp-8],rax
     c1: mov     edi,0FFFFFFF8h
     c6: mov     esi,8
     cb: call    ryo_h_Ret
     d0: leave
     d1: ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-18h],rdx
     18: mov     rsi,[rbp+28h]
     1c: mov     [rbp-40h],rsi
     20: mov     [rbp-38h],rax
     24: mov     [rbp-30h],rdx
     28: call    fn0
     2d: nop     [rcx-9]
     34: mov     rax,[rbp+10h]
     38: mov     [rbp-20h],rax
     3c: mov     rdx,[rbp+20h]
     40: mov     [rbp-18h],rdx
     44: mov     rsi,[rbp+28h]
     48: mov     [rbp-40h],rsi
     4c: mov     [rbp-38h],rax
     50: mov     [rbp-30h],rdx
     54: call    fn1
     59: nop     [rcx-0Ah]
     60: movzx   eax,byte ptr [rbp-9]
     64: cmp     al,[rbp-0Ah]
     67: jne     0B9h
     69: mov     rdx,[rbp+18h]
     6d: mov     [rbp-20h],rdx
     71: mov     rsi,[rbp+20h]
     75: mov     [rbp-18h],rsi
     79: mov     rdi,[rbp+28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-38h],rdx
     85: mov     [rbp-30h],rsi
     89: call    fn2
     8e: nop     [rcx-0Ch]
     95: movzx   eax,byte ptr [rbp-0Ch]
     99: xor     al,[rbp-9]
     9c: mov     [rbp-0Dh],al
     9f: test    byte ptr [rbp-0Dh],0FFh
     a3: je      0AFh
     a5: mov     rsi,[rbp+20h]
     a9: mov     [rbp-8],rsi
     ad: jmp     0B7h
     af: mov     rax,[rbp+18h]
     b3: mov     [rbp-8],rax
     b7: jmp     0C1h
     b9: mov     rax,[rbp+10h]
     bd: mov     [rbp-8],rax
     c1: mov     edi,0FFFFFFF8h
     c6: mov     esi,8
     cb: call    ryo_h_Ret
     d0: leave
     d1: ret

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: imul    rax,[rbp+28h],8
      d: mov     [rbp-28h],rax
     11: cmp     rax,40h
     15: jb      145h
     1b: mov     qword ptr [rbp-48h],8
     23: mov     edi,0FFFFFFD8h
     28: mov     esi,28h
     2d: mov     edx,0FFFFFFB8h
     32: call    ryo_h_DivUW64
     37: mov     rax,[rbp+10h]
     3b: mov     [rbp-30h],rax
     3f: mov     rdx,[rbp+10h]
     43: mov     [rbp-40h],rdx
     47: imul    rsi,[rbp-28h],4
     4c: mov     [rbp-10h],rsi
     50: imul    rcx,rsi,8
     54: add     rdx,rcx
     57: mov     [rbp-38h],rdx
     5b: imul    rdi,[rbp-28h],7
     60: mov     [rbp-18h],rdi
     64: mov     r8,[rbp+10h]
     68: imul    rcx,rdi,8
     6c: add     r8,rcx
     6f: mov     [rbp-40h],r8
     73: mov     [rbp-70h],rax
     77: mov     [rbp-68h],rdx
     7b: mov     [rbp-60h],r8
     7f: mov     r9,[rbp-28h]
     83: mov     [rbp-58h],r9
     87: mov     r10,[rbp+30h]
     8b: mov     [rbp-50h],r10
     8f: call    fn0
     94: nop     [rcx+10h]
     9b: mov     rax,[rbp+18h]
     9f: mov     [rbp-30h],rax
     a3: mov     rdx,[rbp+18h]
     a7: mov     [rbp-40h],rdx
     ab: imul    rcx,[rbp-10h],8
     b0: add     rdx,rcx
     b3: mov     [rbp-38h],rdx
     b7: mov     rsi,[rbp+18h]
     bb: imul    rcx,[rbp-18h],8
     c0: add     rsi,rcx
     c3: mov     [rbp-40h],rsi
     c7: mov     [rbp-70h],rax
     cb: mov     [rbp-68h],rdx
     cf: mov     [rbp-60h],rsi
     d3: mov     rdi,[rbp-28h]
     d7: mov     [rbp-58h],rdi
     db: mov     r8,[rbp+30h]
     df: mov     [rbp-50h],r8
     e3: call    fn1
     e8: nop     [rcx+18h]
     ef: mov     rax,[rbp+20h]
     f3: mov     [rbp-30h],rax
     f7: mov     rdx,[rbp+20h]
     fb: mov     [rbp-40h],rdx
     ff: imul    rcx,[rbp-10h],8
    104: add     rdx,rcx
    107: mov     [rbp-38h],rdx
    10b: mov     rsi,[rbp+20h]
    10f: imul    rcx,[rbp-18h],8
    114: add     rsi,rcx
    117: mov     [rbp-40h],rsi
    11b: mov     [rbp-70h],rax
    11f: mov     [rbp-68h],rdx
    123: mov     [rbp-60h],rsi
    127: mov     rdi,[rbp-28h]
    12b: mov     [rbp-58h],rdi
    12f: mov     r8,[rbp+30h]
    133: mov     [rbp-50h],r8
    137: call    fn2
    13c: nop     [rcx+20h]
    143: jmp     145h
    145: mov     rax,[rbp+10h]
    149: mov     [rbp-20h],rax
    14d: mov     rdx,[rbp+18h]
    151: mov     [rbp-28h],rdx
    155: mov     rsi,[rbp+20h]
    159: mov     [rbp-30h],rsi
    15d: mov     [rbp-70h],rax
    161: mov     [rbp-68h],rdx
    165: mov     [rbp-60h],rsi
    169: mov     rdi,[rbp+30h]
    16d: mov     [rbp-58h],rdi
    171: call    fn3
    176: nop     [rcx-8]
    17d: mov     edi,0FFFFFFF8h
    182: mov     esi,8
    187: call    ryo_h_Ret
    18c: leave
    18d: ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: imul    rax,[rbp+28h],8
      d: mov     [rbp-28h],rax
     11: cmp     rax,40h
     15: jb      145h
     1b: mov     qword ptr [rbp-48h],8
     23: mov     edi,0FFFFFFD8h
     28: mov     esi,28h
     2d: mov     edx,0FFFFFFB8h
     32: call    ryo_h_DivUW64
     37: mov     rax,[rbp+10h]
     3b: mov     [rbp-30h],rax
     3f: mov     rdx,[rbp+10h]
     43: mov     [rbp-40h],rdx
     47: imul    rsi,[rbp-28h],4
     4c: mov     [rbp-10h],rsi
     50: imul    rcx,rsi,4
     54: add     rdx,rcx
     57: mov     [rbp-38h],rdx
     5b: imul    rdi,[rbp-28h],7
     60: mov     [rbp-18h],rdi
     64: mov     r8,[rbp+10h]
     68: imul    rcx,rdi,4
     6c: add     r8,rcx
     6f: mov     [rbp-40h],r8
     73: mov     [rbp-70h],rax
     77: mov     [rbp-68h],rdx
     7b: mov     [rbp-60h],r8
     7f: mov     r9,[rbp-28h]
     83: mov     [rbp-58h],r9
     87: mov     r10,[rbp+30h]
     8b: mov     [rbp-50h],r10
     8f: call    fn0
     94: nop     [rcx+10h]
     9b: mov     rax,[rbp+18h]
     9f: mov     [rbp-30h],rax
     a3: mov     rdx,[rbp+18h]
     a7: mov     [rbp-40h],rdx
     ab: imul    rcx,[rbp-10h],4
     b0: add     rdx,rcx
     b3: mov     [rbp-38h],rdx
     b7: mov     rsi,[rbp+18h]
     bb: imul    rcx,[rbp-18h],4
     c0: add     rsi,rcx
     c3: mov     [rbp-40h],rsi
     c7: mov     [rbp-70h],rax
     cb: mov     [rbp-68h],rdx
     cf: mov     [rbp-60h],rsi
     d3: mov     rdi,[rbp-28h]
     d7: mov     [rbp-58h],rdi
     db: mov     r8,[rbp+30h]
     df: mov     [rbp-50h],r8
     e3: call    fn1
     e8: nop     [rcx+18h]
     ef: mov     rax,[rbp+20h]
     f3: mov     [rbp-30h],rax
     f7: mov     rdx,[rbp+20h]
     fb: mov     [rbp-40h],rdx
     ff: imul    rcx,[rbp-10h],4
    104: add     rdx,rcx
    107: mov     [rbp-38h],rdx
    10b: mov     rsi,[rbp+20h]
    10f: imul    rcx,[rbp-18h],4
    114: add     rsi,rcx
    117: mov     [rbp-40h],rsi
    11b: mov     [rbp-70h],rax
    11f: mov     [rbp-68h],rdx
    123: mov     [rbp-60h],rsi
    127: mov     rdi,[rbp-28h]
    12b: mov     [rbp-58h],rdi
    12f: mov     r8,[rbp+30h]
    133: mov     [rbp-50h],r8
    137: call    fn2
    13c: nop     [rcx+20h]
    143: jmp     145h
    145: mov     rax,[rbp+10h]
    149: mov     [rbp-20h],rax
    14d: mov     rdx,[rbp+18h]
    151: mov     [rbp-28h],rdx
    155: mov     rsi,[rbp+20h]
    159: mov     [rbp-30h],rsi
    15d: mov     [rbp-70h],rax
    161: mov     [rbp-68h],rdx
    165: mov     [rbp-60h],rsi
    169: mov     rdi,[rbp+30h]
    16d: mov     [rbp-58h],rdi
    171: call    fn3
    176: nop     [rcx-8]
    17d: mov     edi,0FFFFFFF8h
    182: mov     esi,8
    187: call    ryo_h_Ret
    18c: leave
    18d: ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-68h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-80h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-78h],rsi
     23: mov     [rbp-70h],rdx
     27: mov     qword ptr [rbp-0A8h],2
     32: mov     edi,0FFFFFF88h
     37: mov     esi,0FFFFFF98h
     3c: mov     edx,0FFFFFF58h
     41: call    ryo_h_DivUW64
     46: cmp     qword ptr [rbp-78h],0
     4b: setne   [rbp-79h]
     4f: mov     rdx,[rbp-70h]
     53: mov     [rbp-28h],rdx
     57: mov     rsi,[rbp-70h]
     5b: imul    rcx,[rbp-78h],8
     60: add     rsi,rcx
     63: mov     [rbp-30h],rsi
     67: mov     rdi,[rbp-78h]
     6b: sub     rdi,1
     6f: mov     [rbp-80h],rdi
     73: mov     r8,[rbp-70h]
     77: imul    rcx,rdi,8
     7b: add     r8,rcx
     7e: mov     [rbp-38h],r8
     82: mov     r9,[rbp-68h]
     86: sub     r9,1
     8a: mov     [rbp-8],r9
     8e: mov     r10,[rbp-70h]
     92: imul    rcx,r9,8
     96: add     r10,rcx
     99: mov     [rbp-40h],r10
     9d: mov     r11,[rbp+20h]
     a1: mov     [rbp-80h],r11
     a5: imul    rcx,r9,8
     a9: add     r11,rcx
     ac: mov     [rbp-48h],r11
     b0: mov     qword ptr [rbp-18h],0
     b8: mov     rdi,[rbp-78h]
     bc: mov     [rbp-10h],rdi
     c0: mov     rax,[rbp-18h]
     c4: mov     [rbp-88h],rax
     cb: mov     rdx,[rbp-10h]
     cf: mov     [rbp-90h],rdx
     d6: cmp     rax,rdx
     d9: setb    [rbp-79h]
     dd: test    byte ptr [rbp-79h],0FFh
     e1: je      250h
     e7: jmp     233h
     ec: nop     [rax]
     f0: mov     rax,[rbp-90h]
     f7: mov     [rbp-28h],rax
     fb: mov     rdx,[rbp-88h]
    102: mov     [rbp-30h],rdx
    106: mov     rsi,[rbp-80h]
    10a: mov     [rbp+20h],rsi
    10e: mov     rdi,[rbp-38h]
    112: mov     [rbp-0E0h],rdi
    119: mov     r8,[rbp-40h]
    11d: mov     [rbp-0D8h],r8
    124: mov     r9,[rbp-48h]
    128: mov     [rbp-0D0h],r9
    12f: mov     r10,[rbp+28h]
    133: mov     [rbp-0C8h],r10
    13a: call    fn0
    13f: nop     [rcx-90h]
    146: mov     rax,[rbp-90h]
    14d: mov     [rbp-38h],rax
    151: mov     rdx,[rbp-88h]
    158: mov     [rbp-40h],rdx
    15c: mov     rsi,[rbp-80h]
    160: mov     [rbp-48h],rsi
    164: jmp     0C0h
    169: nop     [rax]
    170: jmp     1D0h
    172: nop     [rax+rax]
    17b: nop     [rax+rax]
    180: mov     rax,[rbp-28h]
    184: mov     [rbp-98h],rax
    18b: cmp     rax,[rbp-80h]
    18f: setb    [rbp-8Ah]
    196: test    byte ptr [rbp-8Ah],0FFh
    19d: je      1A9h
    19f: mov     rsi,[rbp-28h]
    1a3: mov     [rbp-50h],rsi
    1a7: jmp     1B1h
    1a9: mov     rax,[rbp-30h]
    1ad: mov     [rbp-50h],rax
    1b1: mov     byte ptr [rbp-0A1h],1
    1b8: test    byte ptr [rbp-0A1h],0FFh
    1bf: je      3BFh
    1c5: jmp     35Dh
    1ca: nop     [rax+rax]
    1d0: mov     rax,[rbp-28h]
    1d4: cmp     rax,[rbp-80h]
    1d8: je      1DCh
    1da: jmp     1E9h
    1dc: mov     rax,[rbp-30h]
    1e0: cmp     rax,[rbp-88h]
    1e7: je      228h
    1e9: lea     rdi,[sym1]
    1f0: lea     rsi,[site2]
    1f7: mov     edx,0FFFFFF58h
    1fc: call    ryo_h_CallExt
    201: test    rax,rax
    204: je      211h
    206: call    rax
    208: nop     [rcx-50h]
    20f: jmp     221h
    211: mov     rdi,rbp
    214: lea     rsi,[ro+4]
    21b: call    qword ptr [sym3]
    221: call    ryo_h_Unreachable
    226: ud2
    228: xor     edi,edi
    22a: xor     esi,esi
    22c: call    ryo_h_Ret
    231: leave
    232: ret
    233: mov     rax,[rbp-18h]
    237: mov     [rbp-88h],rax
    23e: mov     byte ptr [rbp-0A1h],1
    245: test    byte ptr [rbp-0A1h],0FFh
    24c: je      2A9h
    24e: jmp     273h
    250: mov     qword ptr [rbp-0A8h],1
    25b: mov     rdx,[rbp-38h]
    25f: imul    rcx,[rbp-0A8h],8
    267: add     rdx,rcx
    26a: mov     [rbp-80h],rdx
    26e: jmp     2FCh
    273: mov     rax,[rbp-88h]
    27a: mov     [rbp-0E0h],rax
    281: mov     qword ptr [rbp-0D8h],1
    28c: mov     edi,0FFFFFF30h
    291: lea     rsi,[k4]
    298: call    ryo_h_AddrAbs
    29d: call    fn5
    2a2: nop     [rcx-60h]
    2a9: mov     rax,[rbp-88h]
    2b0: add     rax,1
    2b4: mov     [rbp-90h],rax
    2bb: mov     [rbp-18h],rax
    2bf: mov     rdx,[rbp-28h]
    2c3: mov     [rbp-0E0h],rdx
    2ca: mov     rsi,[rbp-30h]
    2ce: mov     [rbp-0D8h],rsi
    2d5: mov     rdi,[rbp+20h]
    2d9: mov     [rbp-0D0h],rdi
    2e0: mov     r8,[rbp+28h]
    2e4: mov     [rbp-0C8h],r8
    2eb: call    fn6
    2f0: nop     [rcx-90h]
    2f7: jmp     0F0h
    2fc: mov     qword ptr [rbp-0A8h],1
    307: mov     rdx,[rbp-40h]
    30b: imul    rcx,[rbp-0A8h],8
    313: add     rdx,rcx
    316: mov     [rbp-88h],rdx
    31d: mov     qword ptr [rbp-0A8h],2
    328: mov     edi,0FFFFFF68h
    32d: mov     esi,0FFFFFF98h
    332: mov     edx,0FFFFFF58h
    337: call    ryo_h_RemUW64
    33c: cmp     qword ptr [rbp-98h],0
    344: sete    [rbp-89h]
    34b: test    byte ptr [rbp-89h],0FFh
    352: je      180h
    358: jmp     170h
    35d: mov     rax,[rbp-50h]
    361: mov     [rbp-98h],rax
    368: mov     rdx,[rbp+20h]
    36c: mov     [rbp-0A0h],rdx
    373: mov     [rbp-0E0h],rax
    37a: mov     [rbp-0D8h],rdx
    381: mov     qword ptr [rbp-0D0h],8
    38c: mov     qword ptr [rbp-0C8h],4
    397: mov     qword ptr [rbp-0C0h],1
    3a2: mov     edi,0FFFFFF48h
    3a7: lea     rsi,[k7]
    3ae: call    ryo_h_AddrAbs
    3b3: call    fn8
    3b8: nop     [rcx-60h]
    3bf: mov     qword ptr [rbp-0A8h],1
    3ca: imul    rdx,[rbp-0A8h],8
    3d2: mov     [rbp-0B0h],rdx
    3d9: mov     edi,20h
    3de: mov     esi,0FFFFFFB0h
    3e3: mov     edx,0FFFFFF50h
    3e8: call    ryo_h_Memcpy
    3ed: mov     edi,0FFFFFF60h
    3f2: mov     esi,0FFFFFF76h
    3f7: call    ryo_h_ZextW8W64
    3fc: mov     rax,[rbp-28h]
    400: imul    rcx,[rbp-0A0h],8
    408: add     rax,rcx
    40b: mov     [rbp-98h],rax
    412: mov     [rbp-28h],rax
    416: movzx   edx,byte ptr [rbp-8Ah]
    41d: xor     dl,1
    420: mov     [rbp-8Bh],dl
    426: mov     edi,0FFFFFF60h
    42b: mov     esi,0FFFFFF75h
    430: call    ryo_h_ZextW8W64
    435: mov     rax,[rbp-30h]
    439: imul    rcx,[rbp-0A0h],8
    441: add     rax,rcx
    444: mov     [rbp-98h],rax
    44b: mov     [rbp-30h],rax
    44f: jmp     1D0h

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-68h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-80h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-78h],rsi
     23: mov     [rbp-70h],rdx
     27: mov     qword ptr [rbp-0A8h],2
     32: mov     edi,0FFFFFF88h
     37: mov     esi,0FFFFFF98h
     3c: mov     edx,0FFFFFF58h
     41: call    ryo_h_DivUW64
     46: cmp     qword ptr [rbp-78h],0
     4b: setne   [rbp-79h]
     4f: mov     rdx,[rbp-70h]
     53: mov     [rbp-28h],rdx
     57: mov     rsi,[rbp-70h]
     5b: imul    rcx,[rbp-78h],4
     60: add     rsi,rcx
     63: mov     [rbp-30h],rsi
     67: mov     rdi,[rbp-78h]
     6b: sub     rdi,1
     6f: mov     [rbp-80h],rdi
     73: mov     r8,[rbp-70h]
     77: imul    rcx,rdi,4
     7b: add     r8,rcx
     7e: mov     [rbp-38h],r8
     82: mov     r9,[rbp-68h]
     86: sub     r9,1
     8a: mov     [rbp-8],r9
     8e: mov     r10,[rbp-70h]
     92: imul    rcx,r9,4
     96: add     r10,rcx
     99: mov     [rbp-40h],r10
     9d: mov     r11,[rbp+20h]
     a1: mov     [rbp-80h],r11
     a5: imul    rcx,r9,4
     a9: add     r11,rcx
     ac: mov     [rbp-48h],r11
     b0: mov     qword ptr [rbp-18h],0
     b8: mov     rdi,[rbp-78h]
     bc: mov     [rbp-10h],rdi
     c0: mov     rax,[rbp-18h]
     c4: mov     [rbp-88h],rax
     cb: mov     rdx,[rbp-10h]
     cf: mov     [rbp-90h],rdx
     d6: cmp     rax,rdx
     d9: setb    [rbp-79h]
     dd: test    byte ptr [rbp-79h],0FFh
     e1: je      250h
     e7: jmp     233h
     ec: nop     [rax]
     f0: mov     rax,[rbp-90h]
     f7: mov     [rbp-28h],rax
     fb: mov     rdx,[rbp-88h]
    102: mov     [rbp-30h],rdx
    106: mov     rsi,[rbp-80h]
    10a: mov     [rbp+20h],rsi
    10e: mov     rdi,[rbp-38h]
    112: mov     [rbp-0E0h],rdi
    119: mov     r8,[rbp-40h]
    11d: mov     [rbp-0D8h],r8
    124: mov     r9,[rbp-48h]
    128: mov     [rbp-0D0h],r9
    12f: mov     r10,[rbp+28h]
    133: mov     [rbp-0C8h],r10
    13a: call    fn0
    13f: nop     [rcx-90h]
    146: mov     rax,[rbp-90h]
    14d: mov     [rbp-38h],rax
    151: mov     rdx,[rbp-88h]
    158: mov     [rbp-40h],rdx
    15c: mov     rsi,[rbp-80h]
    160: mov     [rbp-48h],rsi
    164: jmp     0C0h
    169: nop     [rax]
    170: jmp     1D0h
    172: nop     [rax+rax]
    17b: nop     [rax+rax]
    180: mov     rax,[rbp-28h]
    184: mov     [rbp-98h],rax
    18b: cmp     rax,[rbp-80h]
    18f: setb    [rbp-8Ah]
    196: test    byte ptr [rbp-8Ah],0FFh
    19d: je      1A9h
    19f: mov     rsi,[rbp-28h]
    1a3: mov     [rbp-50h],rsi
    1a7: jmp     1B1h
    1a9: mov     rax,[rbp-30h]
    1ad: mov     [rbp-50h],rax
    1b1: mov     byte ptr [rbp-0A1h],1
    1b8: test    byte ptr [rbp-0A1h],0FFh
    1bf: je      3BFh
    1c5: jmp     35Dh
    1ca: nop     [rax+rax]
    1d0: mov     rax,[rbp-28h]
    1d4: cmp     rax,[rbp-80h]
    1d8: je      1DCh
    1da: jmp     1E9h
    1dc: mov     rax,[rbp-30h]
    1e0: cmp     rax,[rbp-88h]
    1e7: je      228h
    1e9: lea     rdi,[sym1]
    1f0: lea     rsi,[site2]
    1f7: mov     edx,0FFFFFF58h
    1fc: call    ryo_h_CallExt
    201: test    rax,rax
    204: je      211h
    206: call    rax
    208: nop     [rcx-50h]
    20f: jmp     221h
    211: mov     rdi,rbp
    214: lea     rsi,[ro+4]
    21b: call    qword ptr [sym3]
    221: call    ryo_h_Unreachable
    226: ud2
    228: xor     edi,edi
    22a: xor     esi,esi
    22c: call    ryo_h_Ret
    231: leave
    232: ret
    233: mov     rax,[rbp-18h]
    237: mov     [rbp-88h],rax
    23e: mov     byte ptr [rbp-0A1h],1
    245: test    byte ptr [rbp-0A1h],0FFh
    24c: je      2A9h
    24e: jmp     273h
    250: mov     qword ptr [rbp-0A8h],1
    25b: mov     rdx,[rbp-38h]
    25f: imul    rcx,[rbp-0A8h],4
    267: add     rdx,rcx
    26a: mov     [rbp-80h],rdx
    26e: jmp     2FCh
    273: mov     rax,[rbp-88h]
    27a: mov     [rbp-0E0h],rax
    281: mov     qword ptr [rbp-0D8h],1
    28c: mov     edi,0FFFFFF30h
    291: lea     rsi,[k4]
    298: call    ryo_h_AddrAbs
    29d: call    fn5
    2a2: nop     [rcx-60h]
    2a9: mov     rax,[rbp-88h]
    2b0: add     rax,1
    2b4: mov     [rbp-90h],rax
    2bb: mov     [rbp-18h],rax
    2bf: mov     rdx,[rbp-28h]
    2c3: mov     [rbp-0E0h],rdx
    2ca: mov     rsi,[rbp-30h]
    2ce: mov     [rbp-0D8h],rsi
    2d5: mov     rdi,[rbp+20h]
    2d9: mov     [rbp-0D0h],rdi
    2e0: mov     r8,[rbp+28h]
    2e4: mov     [rbp-0C8h],r8
    2eb: call    fn6
    2f0: nop     [rcx-90h]
    2f7: jmp     0F0h
    2fc: mov     qword ptr [rbp-0A8h],1
    307: mov     rdx,[rbp-40h]
    30b: imul    rcx,[rbp-0A8h],4
    313: add     rdx,rcx
    316: mov     [rbp-88h],rdx
    31d: mov     qword ptr [rbp-0A8h],2
    328: mov     edi,0FFFFFF68h
    32d: mov     esi,0FFFFFF98h
    332: mov     edx,0FFFFFF58h
    337: call    ryo_h_RemUW64
    33c: cmp     qword ptr [rbp-98h],0
    344: sete    [rbp-89h]
    34b: test    byte ptr [rbp-89h],0FFh
    352: je      180h
    358: jmp     170h
    35d: mov     rax,[rbp-50h]
    361: mov     [rbp-98h],rax
    368: mov     rdx,[rbp+20h]
    36c: mov     [rbp-0A0h],rdx
    373: mov     [rbp-0E0h],rax
    37a: mov     [rbp-0D8h],rdx
    381: mov     qword ptr [rbp-0D0h],4
    38c: mov     qword ptr [rbp-0C8h],4
    397: mov     qword ptr [rbp-0C0h],1
    3a2: mov     edi,0FFFFFF48h
    3a7: lea     rsi,[k7]
    3ae: call    ryo_h_AddrAbs
    3b3: call    fn8
    3b8: nop     [rcx-60h]
    3bf: mov     qword ptr [rbp-0A8h],1
    3ca: imul    rdx,[rbp-0A8h],4
    3d2: mov     [rbp-0B0h],rdx
    3d9: mov     edi,20h
    3de: mov     esi,0FFFFFFB0h
    3e3: mov     edx,0FFFFFF50h
    3e8: call    ryo_h_Memcpy
    3ed: mov     edi,0FFFFFF60h
    3f2: mov     esi,0FFFFFF76h
    3f7: call    ryo_h_ZextW8W64
    3fc: mov     rax,[rbp-28h]
    400: imul    rcx,[rbp-0A0h],4
    408: add     rax,rcx
    40b: mov     [rbp-98h],rax
    412: mov     [rbp-28h],rax
    416: movzx   edx,byte ptr [rbp-8Ah]
    41d: xor     dl,1
    420: mov     [rbp-8Bh],dl
    426: mov     edi,0FFFFFF60h
    42b: mov     esi,0FFFFFF75h
    430: call    ryo_h_ZextW8W64
    435: mov     rax,[rbp-30h]
    439: imul    rcx,[rbp-0A0h],4
    441: add     rax,rcx
    444: mov     [rbp-98h],rax
    44b: mov     [rbp-30h],rax
    44f: jmp     1D0h

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-71h],0
      f: test    byte ptr [rbp-71h],0FFh
     13: je      16Ch
     19: jmp     162h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      5Bh
     26: mov     rdx,[rbp+18h]
     2a: mov     [rbp-40h],rdx
     2e: mov     rdx,[rdx]
     31: mov     [rbp-38h],rdx
     35: mov     [rbp-40h],rdx
     39: mov     [rbp-30h],rdx
     3d: lea     rsi,[rbp-30h]
     41: mov     [rbp-50h],rsi
     45: mov     [rbp-48h],rsi
     49: mov     rdi,[rbp+18h]
     4d: mov     [rbp-40h],rdi
     51: mov     qword ptr [rbp-38h],1
     59: jmp     60h
     5b: jmp     0E3h
     60: mov     rax,[rbp-8]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-50h],rax
     6c: mov     rdx,[rbp-40h]
     70: mov     [rbp-58h],rdx
     74: mov     byte ptr [rbp-71h],1
     78: test    byte ptr [rbp-71h],0FFh
     7c: je      1E2h
     82: jmp     186h
     87: nop     [rax+rax]
     90: jmp     0C8h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: mov     byte ptr [rbp-71h],0
     a4: test    byte ptr [rbp-71h],0FFh
     a8: je      280h
     ae: jmp     276h
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
    128: mov     rdx,[rbp-8]
    12c: mov     [rbp-50h],rdx
    130: mov     [rbp-40h],rax
    134: mov     [rbp-38h],rdx
    138: mov     rsi,[rbp+20h]
    13c: mov     [rbp-0B0h],rsi
    143: mov     [rbp-0A8h],rax
    14a: mov     [rbp-0A0h],rdx
    151: call    fn2
    156: nop     [rcx-29h]
    15d: jmp     20h
    162: mov     rax,[rbp+18h]
    166: mov     [rbp-8],rax
    16a: jmp     120h
    16c: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    174: mov     rdx,[rbp+18h]
    178: imul    rcx,[rbp-78h],8
    17d: add     rdx,rcx
    180: mov     [rbp-8],rdx
    184: jmp     120h
    186: mov     rax,[rbp-18h]
    18a: mov     [rbp-60h],rax
    18e: mov     rdx,[rbp-58h]
    192: mov     [rbp-68h],rdx
    196: mov     [rbp-0B0h],rax
    19d: mov     [rbp-0A8h],rdx
    1a4: mov     qword ptr [rbp-0A0h],8
    1af: mov     qword ptr [rbp-98h],4
    1ba: mov     qword ptr [rbp-90h],1
    1c5: mov     edi,0FFFFFF78h
    1ca: lea     rsi,[k3]
    1d1: call    ryo_h_AddrAbs
    1d6: call    fn4
    1db: nop     [rcx-20h]
    1e2: mov     qword ptr [rbp-78h],1
    1ea: imul    rdx,[rbp-78h],8
    1ef: mov     [rbp-80h],rdx
    1f3: mov     edi,0FFFFFFA8h
    1f8: mov     esi,0FFFFFFB0h
    1fd: mov     edx,0FFFFFF80h
    202: call    ryo_h_Memcpy
    207: mov     rax,[rbp-8]
    20b: mov     [rbp-50h],rax
    20f: mov     [rbp-40h],rax
    213: mov     rdx,[rbp-8]
    217: mov     [rbp-58h],rdx
    21b: cmp     rdx,[rbp+10h]
    21f: je      90h
    225: jmp     0A0h
    22a: nop     [rax+rax]
    230: mov     rax,[rbp-50h]
    234: mov     [rbp-8],rax
    238: lea     rdx,[rbp-30h]
    23c: mov     [rbp-68h],rdx
    240: mov     [rbp-70h],rax
    244: mov     [rbp-60h],rdx
    248: mov     [rbp-58h],rax
    24c: mov     rsi,[rbp+20h]
    250: mov     [rbp-0B0h],rsi
    257: mov     [rbp-0A8h],rdx
    25e: mov     [rbp-0A0h],rax
    265: call    fn5
    26a: nop     [rcx-49h]
    271: jmp     0C0h
    276: mov     rax,[rbp-8]
    27a: mov     [rbp-50h],rax
    27e: jmp     230h
    280: mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    288: mov     rdx,[rbp-8]
    28c: imul    rcx,[rbp-78h],8
    291: add     rdx,rcx
    294: mov     [rbp-50h],rdx
    298: jmp     230h
    29a: nop     [rax+rax]
    2a0: lea     rdi,[sym6]
    2a7: lea     rsi,[site7]
    2ae: mov     edx,0FFFFFF88h
    2b3: call    ryo_h_CallExt
    2b8: test    rax,rax
    2bb: je      2C8h
    2bd: call    rax
    2bf: nop     [rcx-70h]
    2c6: jmp     2D8h
    2c8: mov     rdi,rbp
    2cb: lea     rsi,[ro+4]
    2d2: call    qword ptr [sym8]
    2d8: call    ryo_h_Unreachable
    2dd: ud2
    2df: mov     rdi,rax
    2e2: mov     esi,0FFFFFFD8h
    2e7: call    ryo_h_Lpad
    2ec: jmp     2A0h
    2ee: mov     rdi,rax
    2f1: mov     esi,0FFFFFFD8h
    2f6: call    ryo_h_Lpad
    2fb: jmp     0F0h

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-69h],0
      f: test    byte ptr [rbp-69h],0FFh
     13: je      16Ch
     19: jmp     162h
     1e: xchg    ax,ax
     20: test    byte ptr [rbp-29h],0FFh
     24: je      57h
     26: mov     rdx,[rbp+18h]
     2a: mov     [rbp-38h],rdx
     2e: mov     edx,[rdx]
     30: mov     [rbp-30h],edx
     33: mov     [rbp-34h],edx
     36: mov     [rbp-2Ch],edx
     39: lea     rsi,[rbp-2Ch]
     3d: mov     [rbp-50h],rsi
     41: mov     [rbp-48h],rsi
     45: mov     rdi,[rbp+18h]
     49: mov     [rbp-40h],rdi
     4d: mov     qword ptr [rbp-38h],1
     55: jmp     60h
     57: jmp     0E3h
     5c: nop     [rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-50h],rax
     6c: mov     rdx,[rbp-40h]
     70: mov     [rbp-58h],rdx
     74: mov     byte ptr [rbp-69h],1
     78: test    byte ptr [rbp-69h],0FFh
     7c: je      1E2h
     82: jmp     186h
     87: nop     [rax+rax]
     90: jmp     0C8h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: mov     byte ptr [rbp-69h],0
     a4: test    byte ptr [rbp-69h],0FFh
     a8: je      280h
     ae: jmp     276h
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
    128: mov     rdx,[rbp-8]
    12c: mov     [rbp-50h],rdx
    130: mov     [rbp-40h],rax
    134: mov     [rbp-38h],rdx
    138: mov     rsi,[rbp+20h]
    13c: mov     [rbp-0B0h],rsi
    143: mov     [rbp-0A8h],rax
    14a: mov     [rbp-0A0h],rdx
    151: call    fn2
    156: nop     [rcx-29h]
    15d: jmp     20h
    162: mov     rax,[rbp+18h]
    166: mov     [rbp-8],rax
    16a: jmp     120h
    16c: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    174: mov     rdx,[rbp+18h]
    178: imul    rcx,[rbp-70h],4
    17d: add     rdx,rcx
    180: mov     [rbp-8],rdx
    184: jmp     120h
    186: mov     rax,[rbp-18h]
    18a: mov     [rbp-60h],rax
    18e: mov     rdx,[rbp-58h]
    192: mov     [rbp-68h],rdx
    196: mov     [rbp-0B0h],rax
    19d: mov     [rbp-0A8h],rdx
    1a4: mov     qword ptr [rbp-0A0h],4
    1af: mov     qword ptr [rbp-98h],4
    1ba: mov     qword ptr [rbp-90h],1
    1c5: mov     edi,0FFFFFF78h
    1ca: lea     rsi,[k3]
    1d1: call    ryo_h_AddrAbs
    1d6: call    fn4
    1db: nop     [rcx-20h]
    1e2: mov     qword ptr [rbp-70h],1
    1ea: imul    rdx,[rbp-70h],4
    1ef: mov     [rbp-78h],rdx
    1f3: mov     edi,0FFFFFFA8h
    1f8: mov     esi,0FFFFFFB0h
    1fd: mov     edx,0FFFFFF88h
    202: call    ryo_h_Memcpy
    207: mov     rax,[rbp-8]
    20b: mov     [rbp-50h],rax
    20f: mov     [rbp-40h],rax
    213: mov     rdx,[rbp-8]
    217: mov     [rbp-50h],rdx
    21b: cmp     rdx,[rbp+10h]
    21f: je      90h
    225: jmp     0A0h
    22a: nop     [rax+rax]
    230: mov     rax,[rbp-50h]
    234: mov     [rbp-8],rax
    238: lea     rdx,[rbp-2Ch]
    23c: mov     [rbp-60h],rdx
    240: mov     [rbp-68h],rax
    244: mov     [rbp-58h],rdx
    248: mov     [rbp-50h],rax
    24c: mov     rsi,[rbp+20h]
    250: mov     [rbp-0B0h],rsi
    257: mov     [rbp-0A8h],rdx
    25e: mov     [rbp-0A0h],rax
    265: call    fn5
    26a: nop     [rcx-2Dh]
    271: jmp     0C0h
    276: mov     rax,[rbp-8]
    27a: mov     [rbp-50h],rax
    27e: jmp     230h
    280: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    288: mov     rdx,[rbp-8]
    28c: imul    rcx,[rbp-70h],4
    291: add     rdx,rcx
    294: mov     [rbp-50h],rdx
    298: jmp     230h
    29a: nop     [rax+rax]
    2a0: lea     rdi,[sym6]
    2a7: lea     rsi,[site7]
    2ae: mov     edx,0FFFFFF90h
    2b3: call    ryo_h_CallExt
    2b8: test    rax,rax
    2bb: je      2C8h
    2bd: call    rax
    2bf: nop     [rcx-68h]
    2c6: jmp     2D8h
    2c8: mov     rdi,rbp
    2cb: lea     rsi,[ro+4]
    2d2: call    qword ptr [sym8]
    2d8: call    ryo_h_Unreachable
    2dd: ud2
    2df: mov     rdi,rax
    2e2: mov     esi,0FFFFFFD8h
    2e7: call    ryo_h_Lpad
    2ec: jmp     2A0h
    2ee: mov     rdi,rax
    2f1: mov     esi,0FFFFFFD8h
    2f6: call    ryo_h_Lpad
    2fb: jmp     0F0h

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
     2c: mov     rdx,[rbp+18h]
     30: mov     [rbp-20h],rdx
     34: mov     [rbp-18h],rax
     38: imul    rcx,[rbp-10h],8
     3d: add     rax,rcx
     40: mov     [rbp-20h],rax
     44: mov     rsi,[rbp-18h]
     48: imul    rcx,[rbp+20h],8
     4d: add     rsi,rcx
     50: mov     [rbp-8],rsi
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: je      0B4h
     6e: mov     rdx,[rbp-8]
     72: mov     [rbp-30h],rdx
     76: mov     rsi,[rbp-18h]
     7a: mov     [rbp-50h],rsi
     7e: mov     [rbp-48h],rdx
     82: mov     rdi,[rbp+28h]
     86: mov     [rbp-40h],rdi
     8a: call    fn0
     8f: nop     [rcx-8]
     96: mov     qword ptr [rbp-38h],1
     9e: mov     rdx,[rbp-8]
     a2: imul    rcx,[rbp-38h],8
     a7: add     rdx,rcx
     aa: mov     [rbp-30h],rdx
     ae: mov     [rbp-8],rdx
     b2: jmp     60h
     b4: xor     edi,edi
     b6: xor     esi,esi
     b8: call    ryo_h_Ret
     bd: leave
     be: ret

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
     2c: mov     rdx,[rbp+18h]
     30: mov     [rbp-20h],rdx
     34: mov     [rbp-18h],rax
     38: imul    rcx,[rbp-10h],4
     3d: add     rax,rcx
     40: mov     [rbp-20h],rax
     44: mov     rsi,[rbp-18h]
     48: imul    rcx,[rbp+20h],4
     4d: add     rsi,rcx
     50: mov     [rbp-8],rsi
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: mov     rax,[rbp-8]
     64: mov     [rbp-30h],rax
     68: cmp     rax,[rbp-20h]
     6c: je      0B4h
     6e: mov     rdx,[rbp-8]
     72: mov     [rbp-30h],rdx
     76: mov     rsi,[rbp-18h]
     7a: mov     [rbp-50h],rsi
     7e: mov     [rbp-48h],rdx
     82: mov     rdi,[rbp+28h]
     86: mov     [rbp-40h],rdi
     8a: call    fn0
     8f: nop     [rcx-8]
     96: mov     qword ptr [rbp-38h],1
     9e: mov     rdx,[rbp-8]
     a2: imul    rcx,[rbp-38h],4
     a7: add     rdx,rcx
     aa: mov     [rbp-30h],rdx
     ae: mov     [rbp-8],rdx
     b2: jmp     60h
     b4: xor     edi,edi
     b6: xor     esi,esi
     b8: call    ryo_h_Ret
     bd: leave
     be: ret

fn core::slice::sort::shared::smallsort::merge_down::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-50h],rdx
     1b: mov     [rbp-40h],rax
     1f: mov     [rbp-38h],rdx
     23: mov     rsi,[rbp+28h]
     27: mov     [rbp-90h],rsi
     2e: mov     [rbp-88h],rax
     35: mov     [rbp-80h],rdx
     39: call    fn0
     3e: nop     [rcx-19h]
     45: movzx   eax,byte ptr [rbp-19h]
     49: xor     al,1
     4c: mov     [rbp-29h],al
     4f: test    byte ptr [rbp-29h],0FFh
     53: je      5Fh
     55: mov     rsi,[rbp+18h]
     59: mov     [rbp-28h],rsi
     5d: jmp     67h
     5f: mov     rax,[rbp+10h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rbp+20h]
     6b: mov     [rbp-38h],rax
     6f: mov     byte ptr [rbp-51h],1
     73: test    byte ptr [rbp-51h],0FFh
     77: je      0C8h
     79: mov     rdi,[rbp-28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-48h],rax
     85: mov     [rbp-90h],rdi
     8c: mov     [rbp-88h],rax
     93: mov     qword ptr [rbp-80h],8
     9b: mov     qword ptr [rbp-78h],4
     a3: mov     qword ptr [rbp-70h],1
     ab: mov     edi,0FFFFFF98h
     b0: lea     rsi,[k1]
     b7: call    ryo_h_AddrAbs
     bc: call    fn2
     c1: nop     [rcx-28h]
     c8: mov     qword ptr [rbp-58h],1
     d0: imul    rdx,[rbp-58h],8
     d5: mov     [rbp-60h],rdx
     d9: mov     edi,0FFFFFFC8h
     de: mov     esi,0FFFFFFD8h
     e3: mov     edx,0FFFFFFA0h
     e8: call    ryo_h_Memcpy
     ed: mov     edi,0FFFFFFC0h
     f2: mov     esi,0FFFFFFD7h
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp-40h]
    100: mov     [rbp-50h],rax
    104: mov     qword ptr [rbp-58h],0
    10c: mov     rsi,[rbp-58h]
    110: sub     rsi,rax
    113: mov     [rbp-48h],rsi
    117: mov     rdi,[rbp+18h]
    11b: imul    rcx,rsi,8
    11f: add     rdi,rcx
    122: mov     [rbp-38h],rdi
    126: mov     [rbp+18h],rdi
    12a: mov     edi,0FFFFFFC0h
    12f: mov     esi,0FFFFFFE7h
    134: call    ryo_h_ZextW8W64
    139: mov     rax,[rbp-40h]
    13d: mov     [rbp-50h],rax
    141: mov     qword ptr [rbp-58h],0
    149: mov     rsi,[rbp-58h]
    14d: sub     rsi,rax
    150: mov     [rbp-48h],rsi
    154: mov     rdi,[rbp+10h]
    158: imul    rcx,rsi,8
    15c: add     rdi,rcx
    15f: mov     [rbp-38h],rdi
    163: mov     [rbp+10h],rdi
    167: mov     byte ptr [rbp-51h],0
    16b: test    byte ptr [rbp-51h],0FFh
    16f: je      1B7h
    171: jmp     1ADh
    173: nop     [rax+rax]
    17c: nop     [rax]
    180: mov     rax,[rbp-38h]
    184: mov     [rbp+20h],rax
    188: mov     rdx,[rbp+10h]
    18c: mov     [rbp-18h],rdx
    190: mov     rsi,[rbp+18h]
    194: mov     [rbp-10h],rsi
    198: mov     [rbp-8],rax
    19c: mov     edi,0FFFFFFE8h
    1a1: mov     esi,18h
    1a6: call    ryo_h_Ret
    1ab: leave
    1ac: ret
    1ad: mov     rax,[rbp+20h]
    1b1: mov     [rbp-38h],rax
    1b5: jmp     180h
    1b7: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    1bf: mov     rdx,[rbp+20h]
    1c3: imul    rcx,[rbp-58h],8
    1c8: add     rdx,rcx
    1cb: mov     [rbp-38h],rdx
    1cf: jmp     180h

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-50h],rdx
     1b: mov     [rbp-40h],rax
     1f: mov     [rbp-38h],rdx
     23: mov     rsi,[rbp+28h]
     27: mov     [rbp-90h],rsi
     2e: mov     [rbp-88h],rax
     35: mov     [rbp-80h],rdx
     39: call    fn0
     3e: nop     [rcx-19h]
     45: movzx   eax,byte ptr [rbp-19h]
     49: xor     al,1
     4c: mov     [rbp-29h],al
     4f: test    byte ptr [rbp-29h],0FFh
     53: je      5Fh
     55: mov     rsi,[rbp+18h]
     59: mov     [rbp-28h],rsi
     5d: jmp     67h
     5f: mov     rax,[rbp+10h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rbp+20h]
     6b: mov     [rbp-38h],rax
     6f: mov     byte ptr [rbp-51h],1
     73: test    byte ptr [rbp-51h],0FFh
     77: je      0C8h
     79: mov     rdi,[rbp-28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-48h],rax
     85: mov     [rbp-90h],rdi
     8c: mov     [rbp-88h],rax
     93: mov     qword ptr [rbp-80h],4
     9b: mov     qword ptr [rbp-78h],4
     a3: mov     qword ptr [rbp-70h],1
     ab: mov     edi,0FFFFFF98h
     b0: lea     rsi,[k1]
     b7: call    ryo_h_AddrAbs
     bc: call    fn2
     c1: nop     [rcx-28h]
     c8: mov     qword ptr [rbp-58h],1
     d0: imul    rdx,[rbp-58h],4
     d5: mov     [rbp-60h],rdx
     d9: mov     edi,0FFFFFFC8h
     de: mov     esi,0FFFFFFD8h
     e3: mov     edx,0FFFFFFA0h
     e8: call    ryo_h_Memcpy
     ed: mov     edi,0FFFFFFC0h
     f2: mov     esi,0FFFFFFD7h
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp-40h]
    100: mov     [rbp-50h],rax
    104: mov     qword ptr [rbp-58h],0
    10c: mov     rsi,[rbp-58h]
    110: sub     rsi,rax
    113: mov     [rbp-48h],rsi
    117: mov     rdi,[rbp+18h]
    11b: imul    rcx,rsi,4
    11f: add     rdi,rcx
    122: mov     [rbp-38h],rdi
    126: mov     [rbp+18h],rdi
    12a: mov     edi,0FFFFFFC0h
    12f: mov     esi,0FFFFFFE7h
    134: call    ryo_h_ZextW8W64
    139: mov     rax,[rbp-40h]
    13d: mov     [rbp-50h],rax
    141: mov     qword ptr [rbp-58h],0
    149: mov     rsi,[rbp-58h]
    14d: sub     rsi,rax
    150: mov     [rbp-48h],rsi
    154: mov     rdi,[rbp+10h]
    158: imul    rcx,rsi,4
    15c: add     rdi,rcx
    15f: mov     [rbp-38h],rdi
    163: mov     [rbp+10h],rdi
    167: mov     byte ptr [rbp-51h],0
    16b: test    byte ptr [rbp-51h],0FFh
    16f: je      1B7h
    171: jmp     1ADh
    173: nop     [rax+rax]
    17c: nop     [rax]
    180: mov     rax,[rbp-38h]
    184: mov     [rbp+20h],rax
    188: mov     rdx,[rbp+10h]
    18c: mov     [rbp-18h],rdx
    190: mov     rsi,[rbp+18h]
    194: mov     [rbp-10h],rsi
    198: mov     [rbp-8],rax
    19c: mov     edi,0FFFFFFE8h
    1a1: mov     esi,18h
    1a6: call    ryo_h_Ret
    1ab: leave
    1ac: ret
    1ad: mov     rax,[rbp+20h]
    1b1: mov     [rbp-38h],rax
    1b5: jmp     180h
    1b7: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    1bf: mov     rdx,[rbp+20h]
    1c3: imul    rcx,[rbp-58h],4
    1c8: add     rdx,rcx
    1cb: mov     [rbp-38h],rdx
    1cf: jmp     180h

fn core::slice::sort::shared::smallsort::merge_up::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-50h],rdx
     1b: mov     [rbp-40h],rax
     1f: mov     [rbp-38h],rdx
     23: mov     rsi,[rbp+28h]
     27: mov     [rbp-90h],rsi
     2e: mov     [rbp-88h],rax
     35: mov     [rbp-80h],rdx
     39: call    fn0
     3e: nop     [rcx-19h]
     45: movzx   eax,byte ptr [rbp-19h]
     49: xor     al,1
     4c: mov     [rbp-29h],al
     4f: test    byte ptr [rbp-29h],0FFh
     53: je      5Fh
     55: mov     rsi,[rbp+10h]
     59: mov     [rbp-28h],rsi
     5d: jmp     67h
     5f: mov     rax,[rbp+18h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rbp+20h]
     6b: mov     [rbp-38h],rax
     6f: mov     byte ptr [rbp-51h],1
     73: test    byte ptr [rbp-51h],0FFh
     77: je      0C8h
     79: mov     rdi,[rbp-28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-48h],rax
     85: mov     [rbp-90h],rdi
     8c: mov     [rbp-88h],rax
     93: mov     qword ptr [rbp-80h],8
     9b: mov     qword ptr [rbp-78h],4
     a3: mov     qword ptr [rbp-70h],1
     ab: mov     edi,0FFFFFF98h
     b0: lea     rsi,[k1]
     b7: call    ryo_h_AddrAbs
     bc: call    fn2
     c1: nop     [rcx-28h]
     c8: mov     qword ptr [rbp-58h],1
     d0: imul    rdx,[rbp-58h],8
     d5: mov     [rbp-60h],rdx
     d9: mov     edi,0FFFFFFC8h
     de: mov     esi,0FFFFFFD8h
     e3: mov     edx,0FFFFFFA0h
     e8: call    ryo_h_Memcpy
     ed: mov     edi,0FFFFFFC0h
     f2: mov     esi,0FFFFFFE7h
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp+18h]
    100: imul    rcx,[rbp-40h],8
    105: add     rax,rcx
    108: mov     [rbp-38h],rax
    10c: mov     [rbp+18h],rax
    110: mov     edi,0FFFFFFC0h
    115: mov     esi,0FFFFFFD7h
    11a: call    ryo_h_ZextW8W64
    11f: mov     rax,[rbp+10h]
    123: imul    rcx,[rbp-40h],8
    128: add     rax,rcx
    12b: mov     [rbp-38h],rax
    12f: mov     [rbp+10h],rax
    133: mov     qword ptr [rbp-58h],1
    13b: mov     rsi,[rbp+20h]
    13f: imul    rcx,[rbp-58h],8
    144: add     rsi,rcx
    147: mov     [rbp-38h],rsi
    14b: mov     [rbp+20h],rsi
    14f: mov     [rbp-18h],rax
    153: mov     rdi,[rbp+18h]
    157: mov     [rbp-10h],rdi
    15b: mov     [rbp-8],rsi
    15f: mov     edi,0FFFFFFE8h
    164: mov     esi,18h
    169: call    ryo_h_Ret
    16e: leave
    16f: ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-50h],rdx
     1b: mov     [rbp-40h],rax
     1f: mov     [rbp-38h],rdx
     23: mov     rsi,[rbp+28h]
     27: mov     [rbp-90h],rsi
     2e: mov     [rbp-88h],rax
     35: mov     [rbp-80h],rdx
     39: call    fn0
     3e: nop     [rcx-19h]
     45: movzx   eax,byte ptr [rbp-19h]
     49: xor     al,1
     4c: mov     [rbp-29h],al
     4f: test    byte ptr [rbp-29h],0FFh
     53: je      5Fh
     55: mov     rsi,[rbp+10h]
     59: mov     [rbp-28h],rsi
     5d: jmp     67h
     5f: mov     rax,[rbp+18h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rbp+20h]
     6b: mov     [rbp-38h],rax
     6f: mov     byte ptr [rbp-51h],1
     73: test    byte ptr [rbp-51h],0FFh
     77: je      0C8h
     79: mov     rdi,[rbp-28h]
     7d: mov     [rbp-40h],rdi
     81: mov     [rbp-48h],rax
     85: mov     [rbp-90h],rdi
     8c: mov     [rbp-88h],rax
     93: mov     qword ptr [rbp-80h],4
     9b: mov     qword ptr [rbp-78h],4
     a3: mov     qword ptr [rbp-70h],1
     ab: mov     edi,0FFFFFF98h
     b0: lea     rsi,[k1]
     b7: call    ryo_h_AddrAbs
     bc: call    fn2
     c1: nop     [rcx-28h]
     c8: mov     qword ptr [rbp-58h],1
     d0: imul    rdx,[rbp-58h],4
     d5: mov     [rbp-60h],rdx
     d9: mov     edi,0FFFFFFC8h
     de: mov     esi,0FFFFFFD8h
     e3: mov     edx,0FFFFFFA0h
     e8: call    ryo_h_Memcpy
     ed: mov     edi,0FFFFFFC0h
     f2: mov     esi,0FFFFFFE7h
     f7: call    ryo_h_ZextW8W64
     fc: mov     rax,[rbp+18h]
    100: imul    rcx,[rbp-40h],4
    105: add     rax,rcx
    108: mov     [rbp-38h],rax
    10c: mov     [rbp+18h],rax
    110: mov     edi,0FFFFFFC0h
    115: mov     esi,0FFFFFFD7h
    11a: call    ryo_h_ZextW8W64
    11f: mov     rax,[rbp+10h]
    123: imul    rcx,[rbp-40h],4
    128: add     rax,rcx
    12b: mov     [rbp-38h],rax
    12f: mov     [rbp+10h],rax
    133: mov     qword ptr [rbp-58h],1
    13b: mov     rsi,[rbp+20h]
    13f: imul    rcx,[rbp-58h],4
    144: add     rsi,rcx
    147: mov     [rbp-38h],rsi
    14b: mov     [rbp+20h],rsi
    14f: mov     [rbp-18h],rax
    153: mov     rdi,[rbp+18h]
    157: mov     [rbp-10h],rdi
    15b: mov     [rbp-8],rsi
    15f: mov     edi,0FFFFFFE8h
    164: mov     esi,18h
    169: call    ryo_h_Ret
    16e: leave
    16f: ret

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
     a5: mov     rsi,[rbp-0F0h]
     ac: mov     [rbp-8],rsi
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
     1c: jmp     4AAh
     21: mov     rax,[rbp+28h]
     25: mov     [rbp-0A0h],rax
     2c: mov     rdx,[rbp-90h]
     33: add     rdx,10h
     37: mov     [rbp-0A8h],rdx
     3e: cmp     rax,rdx
     41: jae     4Ah
     43: call    ryo_h_Abort
     48: ud2
     4a: mov     rax,[rbp+10h]
     4e: mov     [rbp-60h],rax
     52: mov     rdx,[rbp+18h]
     56: mov     [rbp-58h],rdx
     5a: mov     [rbp-98h],rax
     61: mov     qword ptr [rbp-150h],2
     6c: mov     edi,0FFFFFF60h
     71: mov     esi,0FFFFFF70h
     76: mov     edx,0FFFFFEB0h
     7b: call    ryo_h_DivUW64
     80: mov     rax,[rbp+20h]
     84: mov     [rbp-70h],rax
     88: mov     rdx,[rbp+28h]
     8c: mov     [rbp-68h],rdx
     90: mov     [rbp-8],rax
     94: mov     byte ptr [rbp-149h],1
     9b: test    byte ptr [rbp-149h],0FFh
     a2: je      18Eh
     a8: cmp     qword ptr [rbp-90h],10h
     b0: jb      18Eh
     b6: imul    rcx,[rbp-90h],8
     be: add     rax,rcx
     c1: mov     [rbp-0B8h],rax
     c8: mov     r9,[rbp-98h]
     cf: mov     [rbp-190h],r9
     d6: mov     r10,[rbp-8]
     da: mov     [rbp-188h],r10
     e1: mov     [rbp-180h],rax
     e8: mov     r11,[rbp+30h]
     ec: mov     [rbp-178h],r11
     f3: call    fn0
     f8: nop     [rcx-8]
     ff: mov     rax,[rbp-98h]
    106: imul    rcx,[rbp-0A0h],8
    10e: add     rax,rcx
    111: mov     [rbp-0B8h],rax
    118: mov     rdx,[rbp-8]
    11c: imul    rcx,[rbp-0A0h],8
    124: add     rdx,rcx
    127: mov     [rbp-0C0h],rdx
    12e: mov     rsi,[rbp-90h]
    135: add     rsi,8
    139: mov     [rbp-0D0h],rsi
    140: mov     rdi,[rbp-8]
    144: imul    rcx,rsi,8
    148: add     rdi,rcx
    14b: mov     [rbp-0C8h],rdi
    152: mov     [rbp-190h],rax
    159: mov     [rbp-188h],rdx
    160: mov     [rbp-180h],rdi
    167: mov     r8,[rbp+30h]
    16b: mov     [rbp-178h],r8
    172: call    fn1
    177: nop     [rcx-8]
    17e: mov     qword ptr [rbp-0A8h],8
    189: jmp     260h
    18e: cmp     qword ptr [rbp-90h],8
    196: jb      238h
    19c: mov     rdx,[rbp-60h]
    1a0: mov     [rbp-0B8h],rdx
    1a7: mov     [rbp-190h],rdx
    1ae: mov     rsi,[rbp-8]
    1b2: mov     [rbp-188h],rsi
    1b9: mov     rdi,[rbp+30h]
    1bd: mov     [rbp-180h],rdi
    1c4: call    fn2
    1c9: nop     [rcx-8]
    1d0: mov     rax,[rbp-98h]
    1d7: imul    rcx,[rbp-0A0h],8
    1df: add     rax,rcx
    1e2: mov     [rbp-0C0h],rax
    1e9: mov     [rbp-0B8h],rax
    1f0: mov     rdx,[rbp-8]
    1f4: imul    rcx,[rbp-0A0h],8
    1fc: add     rdx,rcx
    1ff: mov     [rbp-0C0h],rdx
    206: mov     [rbp-190h],rax
    20d: mov     [rbp-188h],rdx
    214: mov     rsi,[rbp+30h]
    218: mov     [rbp-180h],rsi
    21f: call    fn3
    224: nop     [rcx-8]
    22b: mov     qword ptr [rbp-0A8h],4
    236: jmp     260h
    238: mov     rax,[rbp-60h]
    23c: mov     [rbp-0B8h],rax
    243: mov     byte ptr [rbp-149h],1
    24a: test    byte ptr [rbp-149h],0FFh
    251: je      585h
    257: jmp     523h
    25c: nop     [rax]
    260: mov     qword ptr [rbp-0D8h],0
    26b: mov     rdx,[rbp-0A0h]
    272: mov     [rbp-0D0h],rdx
    279: mov     edi,0FFFFFF18h
    27e: mov     esi,0FFFFFF28h
    283: call    ryo_h_MovW128
    288: mov     edi,0FFFFFEF8h
    28d: lea     rsi,[k4]
    294: mov     edx,10h
    299: call    ryo_h_Const
    29e: mov     edi,0FFFFFF08h
    2a3: mov     esi,0FFFFFF18h
    2a8: call    ryo_h_MovW128
    2ad: mov     edi,0FFFFFEB8h
    2b2: mov     esi,0FFFFFEF8h
    2b7: mov     edx,20h
    2bc: call    ryo_h_Copy
    2c1: mov     edi,0FFFFFED8h
    2c6: mov     esi,0FFFFFEB8h
    2cb: mov     edx,20h
    2d0: call    ryo_h_Copy
    2d5: mov     edi,0FFFFFF38h
    2da: mov     esi,0FFFFFED8h
    2df: mov     edx,20h
    2e4: call    ryo_h_Copy
    2e9: mov     edi,0FFFFFF18h
    2ee: mov     esi,0FFFFFF38h
    2f3: mov     edx,20h
    2f8: call    ryo_h_Copy
    2fd: nop     [rax]
    300: lea     rax,[rbp-0E8h]
    307: mov     [rbp-110h],rax
    30e: mov     [rbp-108h],rax
    315: mov     qword ptr [rbp-100h],2
    320: mov     edi,0FFFFFE70h
    325: mov     esi,0FFFFFEF8h
    32a: call    ryo_h_MovW128
    32f: call    fn5
    334: nop     [rcx-0F8h]
    33b: jmp     692h
    340: call    ryo_h_Unreachable
    345: ud2
    347: mov     rax,[rbp-0F0h]
    34e: mov     [rbp-100h],rax
    355: mov     rdx,[rbp-98h]
    35c: imul    rcx,rax,8
    360: add     rdx,rcx
    363: mov     [rbp-108h],rdx
    36a: mov     rsi,[rbp-8]
    36e: imul    rcx,rax,8
    372: add     rsi,rcx
    375: mov     [rbp-110h],rsi
    37c: cmp     rax,0
    380: je      3A7h
    382: jmp     3B4h
    384: lea     rax,[rbp-0E8h]
    38b: mov     [rbp-150h],rax
    392: mov     [rbp-190h],rax
    399: call    fn6
    39e: nop     [rcx-150h]
    3a5: jmp     422h
    3a7: mov     rax,[rbp-0A0h]
    3ae: mov     [rbp-28h],rax
    3b2: jmp     3C6h
    3b4: mov     rax,[rbp-90h]
    3bb: sub     rax,[rbp-0A0h]
    3c2: mov     [rbp-28h],rax
    3c6: mov     rax,[rbp-0A8h]
    3cd: mov     [rbp-118h],rax
    3d4: mov     [rbp-38h],rax
    3d8: mov     rdx,[rbp-28h]
    3dc: mov     [rbp-30h],rdx
    3e0: mov     rax,[rbp-38h]
    3e4: mov     [rbp-130h],rax
    3eb: mov     rdx,[rbp-30h]
    3ef: mov     [rbp-138h],rdx
    3f6: cmp     rax,rdx
    3f9: setb    [rbp-121h]
    400: test    byte ptr [rbp-121h],0FFh
    407: je      6E9h
    40d: jmp     6CCh
    412: nop     [rax+rax]
    41b: nop     [rax+rax]
    420: jmp     3E0h
    422: mov     rax,[rbp-70h]
    426: mov     [rbp-0C8h],rax
    42d: mov     [rbp-0C0h],rax
    434: mov     rdx,[rbp-98h]
    43b: mov     [rbp-0B8h],rdx
    442: mov     rsi,[rbp-90h]
    449: mov     [rbp-0B0h],rsi
    450: mov     [rbp-0D8h],rax
    457: mov     [rbp-0E0h],rsi
    45e: mov     byte ptr [rbp-149h],1
    465: test    byte ptr [rbp-149h],0FFh
    46c: je      8ACh
    472: jmp     856h
    477: nop     [rax+rax]
    480: mov     rax,[rbp-0C0h]
    487: mov     [rbp-0C8h],rax
    48e: mov     rdx,[rbp-0B8h]
    495: mov     [rbp-0D0h],rdx
    49c: mov     rsi,[rbp-0B0h]
    4a3: mov     [rbp-0D8h],rsi
    4aa: xor     edi,edi
    4ac: xor     esi,esi
    4ae: call    ryo_h_Ret
    4b3: leave
    4b4: ret
    4b5: nop     [rax+rax]
    4be: xchg    ax,ax
    4c0: lea     rax,[rbp-0E8h]
    4c7: mov     [rbp-150h],rax
    4ce: mov     [rbp-190h],rax
    4d5: call    fn7
    4da: nop     [rcx-150h]
    4e1: nop     [rax+rax]
    4ea: nop     [rax+rax]
    4f0: mov     edi,0FFFFFF78h
    4f5: call    ryo_h_Resume
    4fa: ud2
    4fc: nop     [rax]
    500: lea     rax,[rbp-0C0h]
    507: mov     [rbp-150h],rax
    50e: mov     [rbp-190h],rax
    515: call    fn8
    51a: nop     [rcx-150h]
    521: jmp     4F0h
    523: mov     rax,[rbp-60h]
    527: mov     [rbp-0C0h],rax
    52e: mov     rdx,[rbp-70h]
    532: mov     [rbp-0C8h],rdx
    539: mov     [rbp-190h],rax
    540: mov     [rbp-188h],rdx
    547: mov     qword ptr [rbp-180h],8
    552: mov     qword ptr [rbp-178h],4
    55d: mov     qword ptr [rbp-170h],1
    568: mov     edi,0FFFFFE98h
    56d: lea     rsi,[k9]
    574: call    ryo_h_AddrAbs
    579: call    fn10
    57e: nop     [rcx-70h]
    585: mov     qword ptr [rbp-150h],1
    590: imul    rdx,[rbp-150h],8
    598: mov     [rbp-158h],rdx
    59f: mov     edi,0FFFFFFF8h
    5a4: mov     esi,0FFFFFF48h
    5a9: mov     edx,0FFFFFEA8h
    5ae: call    ryo_h_Memcpy
    5b3: mov     rax,[rbp-98h]
    5ba: imul    rcx,[rbp-0A0h],8
    5c2: add     rax,rcx
    5c5: mov     [rbp-10h],rax
    5c9: mov     [rbp-0B8h],rax
    5d0: mov     rdx,[rbp-8]
    5d4: imul    rcx,[rbp-0A0h],8
    5dc: add     rdx,rcx
    5df: mov     [rbp-0C0h],rdx
    5e6: mov     byte ptr [rbp-149h],1
    5ed: test    byte ptr [rbp-149h],0FFh
    5f4: je      654h
    5f6: mov     r8,[rbp-10h]
    5fa: mov     [rbp-0C8h],r8
    601: mov     [rbp-0D0h],rdx
    608: mov     [rbp-190h],r8
    60f: mov     [rbp-188h],rdx
    616: mov     qword ptr [rbp-180h],8
    621: mov     qword ptr [rbp-178h],4
    62c: mov     qword ptr [rbp-170h],1
    637: mov     edi,0FFFFFE98h
    63c: lea     rsi,[k11]
    643: call    ryo_h_AddrAbs
    648: call    fn12
    64d: nop     [rcx-70h]
    654: mov     qword ptr [rbp-150h],1
    65f: imul    rdx,[rbp-150h],8
    667: mov     [rbp-158h],rdx
    66e: mov     edi,0FFFFFF40h
    673: mov     esi,0FFFFFF48h
    678: mov     edx,0FFFFFEA8h
    67d: call    ryo_h_Memcpy
    682: mov     qword ptr [rbp-0A8h],1
    68d: jmp     260h
    692: mov     rax,[rbp-0F8h]
    699: mov     [rbp-20h],rax
    69d: mov     edi,0FFFFFFE0h
    6a2: xor     esi,esi
    6a4: mov     edx,2
    6a9: call    ryo_h_SwitchDenseW64
    6ae: lea     rcx,[6C0h]
    6b5: movsxd  rax,[rcx+rax*4]
    6b9: add     rax,rcx
    6bc: jmp     rax
    6be: int3
    6bf: int3
    6c0: .long   384h
    6c4: .long   347h
    6c8: .long   340h
    6cc: mov     rax,[rbp-38h]
    6d0: mov     [rbp-130h],rax
    6d7: mov     byte ptr [rbp-149h],1
    6de: test    byte ptr [rbp-149h],0FFh
    6e5: je      724h
    6e7: jmp     6EEh
    6e9: jmp     300h
    6ee: mov     rax,[rbp-130h]
    6f5: mov     [rbp-190h],rax
    6fc: mov     qword ptr [rbp-188h],1
    707: mov     edi,0FFFFFE80h
    70c: lea     rsi,[k13]
    713: call    ryo_h_AddrAbs
    718: call    fn14
    71d: nop     [rcx-80h]
    724: mov     rax,[rbp-130h]
    72b: add     rax,1
    72f: mov     [rbp-138h],rax
    736: mov     [rbp-38h],rax
    73a: mov     rdx,[rbp-130h]
    741: mov     [rbp-118h],rdx
    748: mov     qword ptr [rbp-120h],1
    753: mov     [rbp-128h],rdx
    75a: mov     rdi,[rbp-108h]
    761: imul    rcx,rdx,8
    765: add     rdi,rcx
    768: mov     [rbp-48h],rdi
    76c: mov     [rbp-130h],rdi
    773: mov     r8,[rbp-110h]
    77a: imul    rcx,rdx,8
    77e: add     r8,rcx
    781: mov     [rbp-50h],r8
    785: mov     byte ptr [rbp-149h],1
    78c: test    byte ptr [rbp-149h],0FFh
    793: je      7F3h
    795: mov     r11,[rbp-48h]
    799: mov     [rbp-138h],r11
    7a0: mov     [rbp-140h],r8
    7a7: mov     [rbp-190h],r11
    7ae: mov     [rbp-188h],r8
    7b5: mov     qword ptr [rbp-180h],8
    7c0: mov     qword ptr [rbp-178h],4
    7cb: mov     qword ptr [rbp-170h],1
    7d6: mov     edi,0FFFFFE98h
    7db: lea     rsi,[k15]
    7e2: call    ryo_h_AddrAbs
    7e7: call    fn16
    7ec: nop     [rcx-80h]
    7f3: mov     qword ptr [rbp-150h],1
    7fe: imul    rdx,[rbp-150h],8
    806: mov     [rbp-158h],rdx
    80d: mov     edi,0FFFFFFB0h
    812: mov     esi,0FFFFFED0h
    817: mov     edx,0FFFFFEA8h
    81c: call    ryo_h_Memcpy
    821: mov     rax,[rbp-110h]
    828: mov     [rbp-190h],rax
    82f: mov     rdx,[rbp-50h]
    833: mov     [rbp-188h],rdx
    83a: mov     rsi,[rbp+30h]
    83e: mov     [rbp-180h],rsi
    845: call    fn17
    84a: nop     [rcx-50h]
    851: jmp     420h
    856: mov     rax,[rbp-0D8h]
    85d: mov     [rbp-0E8h],rax
    864: mov     [rbp-190h],rax
    86b: mov     qword ptr [rbp-188h],8
    876: mov     qword ptr [rbp-180h],4
    881: mov     rdi,[rbp-0E0h]
    888: mov     [rbp-178h],rdi
    88f: mov     edi,0FFFFFE90h
    894: lea     rsi,[k18]
    89b: call    ryo_h_AddrAbs
    8a0: call    fn19
    8a5: nop     [rcx-80h]
    8ac: mov     rax,[rbp-0D8h]
    8b3: mov     [rbp-0F0h],rax
    8ba: mov     rdx,[rbp-0E0h]
    8c1: mov     [rbp-0E8h],rdx
    8c8: mov     [rbp-0D0h],rax
    8cf: mov     [rbp-0C8h],rdx
    8d6: mov     rsi,[rbp-0B8h]
    8dd: mov     [rbp-0D8h],rsi
    8e4: mov     edi,0FFFFFE70h
    8e9: mov     esi,0FFFFFF30h
    8ee: call    ryo_h_MovW128
    8f3: mov     rax,[rbp-0D8h]
    8fa: mov     [rbp-180h],rax
    901: mov     rdx,[rbp+30h]
    905: mov     [rbp-178h],rdx
    90c: call    fn20
    911: nop     [rcx-50h]
    918: jmp     480h
    91d: nop     [rax]
    920: lea     rdi,[sym21]
    927: lea     rsi,[site22]
    92e: mov     edx,0FFFFFEB0h
    933: call    ryo_h_CallExt
    938: test    rax,rax
    93b: je      948h
    93d: call    rax
    93f: nop     [rcx-148h]
    946: jmp     958h
    948: mov     rdi,rbp
    94b: lea     rsi,[ro+4]
    952: call    qword ptr [sym23]
    958: call    ryo_h_Unreachable
    95d: ud2
    95f: mov     rdi,rax
    962: mov     esi,0FFFFFF78h
    967: call    ryo_h_Lpad
    96c: jmp     4C0h
    971: mov     rdi,rax
    974: mov     esi,0FFFFFF78h
    979: call    ryo_h_Lpad
    97e: jmp     920h
    980: mov     rdi,rax
    983: mov     esi,0FFFFFF78h
    988: call    ryo_h_Lpad
    98d: jmp     500h

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,190h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: cmp     rax,2
     1a: jae     21h
     1c: jmp     4AAh
     21: mov     rax,[rbp+28h]
     25: mov     [rbp-0A0h],rax
     2c: mov     rdx,[rbp-90h]
     33: add     rdx,10h
     37: mov     [rbp-0A8h],rdx
     3e: cmp     rax,rdx
     41: jae     4Ah
     43: call    ryo_h_Abort
     48: ud2
     4a: mov     rax,[rbp+10h]
     4e: mov     [rbp-60h],rax
     52: mov     rdx,[rbp+18h]
     56: mov     [rbp-58h],rdx
     5a: mov     [rbp-98h],rax
     61: mov     qword ptr [rbp-150h],2
     6c: mov     edi,0FFFFFF60h
     71: mov     esi,0FFFFFF70h
     76: mov     edx,0FFFFFEB0h
     7b: call    ryo_h_DivUW64
     80: mov     rax,[rbp+20h]
     84: mov     [rbp-70h],rax
     88: mov     rdx,[rbp+28h]
     8c: mov     [rbp-68h],rdx
     90: mov     [rbp-8],rax
     94: mov     byte ptr [rbp-149h],1
     9b: test    byte ptr [rbp-149h],0FFh
     a2: je      18Eh
     a8: cmp     qword ptr [rbp-90h],10h
     b0: jb      18Eh
     b6: imul    rcx,[rbp-90h],4
     be: add     rax,rcx
     c1: mov     [rbp-0B8h],rax
     c8: mov     r9,[rbp-98h]
     cf: mov     [rbp-190h],r9
     d6: mov     r10,[rbp-8]
     da: mov     [rbp-188h],r10
     e1: mov     [rbp-180h],rax
     e8: mov     r11,[rbp+30h]
     ec: mov     [rbp-178h],r11
     f3: call    fn0
     f8: nop     [rcx-8]
     ff: mov     rax,[rbp-98h]
    106: imul    rcx,[rbp-0A0h],4
    10e: add     rax,rcx
    111: mov     [rbp-0B8h],rax
    118: mov     rdx,[rbp-8]
    11c: imul    rcx,[rbp-0A0h],4
    124: add     rdx,rcx
    127: mov     [rbp-0C0h],rdx
    12e: mov     rsi,[rbp-90h]
    135: add     rsi,8
    139: mov     [rbp-0D0h],rsi
    140: mov     rdi,[rbp-8]
    144: imul    rcx,rsi,4
    148: add     rdi,rcx
    14b: mov     [rbp-0C8h],rdi
    152: mov     [rbp-190h],rax
    159: mov     [rbp-188h],rdx
    160: mov     [rbp-180h],rdi
    167: mov     r8,[rbp+30h]
    16b: mov     [rbp-178h],r8
    172: call    fn1
    177: nop     [rcx-8]
    17e: mov     qword ptr [rbp-0A8h],8
    189: jmp     260h
    18e: cmp     qword ptr [rbp-90h],8
    196: jb      238h
    19c: mov     rdx,[rbp-60h]
    1a0: mov     [rbp-0B8h],rdx
    1a7: mov     [rbp-190h],rdx
    1ae: mov     rsi,[rbp-8]
    1b2: mov     [rbp-188h],rsi
    1b9: mov     rdi,[rbp+30h]
    1bd: mov     [rbp-180h],rdi
    1c4: call    fn2
    1c9: nop     [rcx-8]
    1d0: mov     rax,[rbp-98h]
    1d7: imul    rcx,[rbp-0A0h],4
    1df: add     rax,rcx
    1e2: mov     [rbp-0C0h],rax
    1e9: mov     [rbp-0B8h],rax
    1f0: mov     rdx,[rbp-8]
    1f4: imul    rcx,[rbp-0A0h],4
    1fc: add     rdx,rcx
    1ff: mov     [rbp-0C0h],rdx
    206: mov     [rbp-190h],rax
    20d: mov     [rbp-188h],rdx
    214: mov     rsi,[rbp+30h]
    218: mov     [rbp-180h],rsi
    21f: call    fn3
    224: nop     [rcx-8]
    22b: mov     qword ptr [rbp-0A8h],4
    236: jmp     260h
    238: mov     rax,[rbp-60h]
    23c: mov     [rbp-0B8h],rax
    243: mov     byte ptr [rbp-149h],1
    24a: test    byte ptr [rbp-149h],0FFh
    251: je      585h
    257: jmp     523h
    25c: nop     [rax]
    260: mov     qword ptr [rbp-0D8h],0
    26b: mov     rdx,[rbp-0A0h]
    272: mov     [rbp-0D0h],rdx
    279: mov     edi,0FFFFFF18h
    27e: mov     esi,0FFFFFF28h
    283: call    ryo_h_MovW128
    288: mov     edi,0FFFFFEF8h
    28d: lea     rsi,[k4]
    294: mov     edx,10h
    299: call    ryo_h_Const
    29e: mov     edi,0FFFFFF08h
    2a3: mov     esi,0FFFFFF18h
    2a8: call    ryo_h_MovW128
    2ad: mov     edi,0FFFFFEB8h
    2b2: mov     esi,0FFFFFEF8h
    2b7: mov     edx,20h
    2bc: call    ryo_h_Copy
    2c1: mov     edi,0FFFFFED8h
    2c6: mov     esi,0FFFFFEB8h
    2cb: mov     edx,20h
    2d0: call    ryo_h_Copy
    2d5: mov     edi,0FFFFFF38h
    2da: mov     esi,0FFFFFED8h
    2df: mov     edx,20h
    2e4: call    ryo_h_Copy
    2e9: mov     edi,0FFFFFF18h
    2ee: mov     esi,0FFFFFF38h
    2f3: mov     edx,20h
    2f8: call    ryo_h_Copy
    2fd: nop     [rax]
    300: lea     rax,[rbp-0E8h]
    307: mov     [rbp-110h],rax
    30e: mov     [rbp-108h],rax
    315: mov     qword ptr [rbp-100h],2
    320: mov     edi,0FFFFFE70h
    325: mov     esi,0FFFFFEF8h
    32a: call    ryo_h_MovW128
    32f: call    fn5
    334: nop     [rcx-0F8h]
    33b: jmp     692h
    340: call    ryo_h_Unreachable
    345: ud2
    347: mov     rax,[rbp-0F0h]
    34e: mov     [rbp-100h],rax
    355: mov     rdx,[rbp-98h]
    35c: imul    rcx,rax,4
    360: add     rdx,rcx
    363: mov     [rbp-108h],rdx
    36a: mov     rsi,[rbp-8]
    36e: imul    rcx,rax,4
    372: add     rsi,rcx
    375: mov     [rbp-110h],rsi
    37c: cmp     rax,0
    380: je      3A7h
    382: jmp     3B4h
    384: lea     rax,[rbp-0E8h]
    38b: mov     [rbp-150h],rax
    392: mov     [rbp-190h],rax
    399: call    fn6
    39e: nop     [rcx-150h]
    3a5: jmp     422h
    3a7: mov     rax,[rbp-0A0h]
    3ae: mov     [rbp-28h],rax
    3b2: jmp     3C6h
    3b4: mov     rax,[rbp-90h]
    3bb: sub     rax,[rbp-0A0h]
    3c2: mov     [rbp-28h],rax
    3c6: mov     rax,[rbp-0A8h]
    3cd: mov     [rbp-118h],rax
    3d4: mov     [rbp-38h],rax
    3d8: mov     rdx,[rbp-28h]
    3dc: mov     [rbp-30h],rdx
    3e0: mov     rax,[rbp-38h]
    3e4: mov     [rbp-130h],rax
    3eb: mov     rdx,[rbp-30h]
    3ef: mov     [rbp-138h],rdx
    3f6: cmp     rax,rdx
    3f9: setb    [rbp-121h]
    400: test    byte ptr [rbp-121h],0FFh
    407: je      6E9h
    40d: jmp     6CCh
    412: nop     [rax+rax]
    41b: nop     [rax+rax]
    420: jmp     3E0h
    422: mov     rax,[rbp-70h]
    426: mov     [rbp-0C8h],rax
    42d: mov     [rbp-0C0h],rax
    434: mov     rdx,[rbp-98h]
    43b: mov     [rbp-0B8h],rdx
    442: mov     rsi,[rbp-90h]
    449: mov     [rbp-0B0h],rsi
    450: mov     [rbp-0D8h],rax
    457: mov     [rbp-0E0h],rsi
    45e: mov     byte ptr [rbp-149h],1
    465: test    byte ptr [rbp-149h],0FFh
    46c: je      8ACh
    472: jmp     856h
    477: nop     [rax+rax]
    480: mov     rax,[rbp-0C0h]
    487: mov     [rbp-0C8h],rax
    48e: mov     rdx,[rbp-0B8h]
    495: mov     [rbp-0D0h],rdx
    49c: mov     rsi,[rbp-0B0h]
    4a3: mov     [rbp-0D8h],rsi
    4aa: xor     edi,edi
    4ac: xor     esi,esi
    4ae: call    ryo_h_Ret
    4b3: leave
    4b4: ret
    4b5: nop     [rax+rax]
    4be: xchg    ax,ax
    4c0: lea     rax,[rbp-0E8h]
    4c7: mov     [rbp-150h],rax
    4ce: mov     [rbp-190h],rax
    4d5: call    fn7
    4da: nop     [rcx-150h]
    4e1: nop     [rax+rax]
    4ea: nop     [rax+rax]
    4f0: mov     edi,0FFFFFF78h
    4f5: call    ryo_h_Resume
    4fa: ud2
    4fc: nop     [rax]
    500: lea     rax,[rbp-0C0h]
    507: mov     [rbp-150h],rax
    50e: mov     [rbp-190h],rax
    515: call    fn8
    51a: nop     [rcx-150h]
    521: jmp     4F0h
    523: mov     rax,[rbp-60h]
    527: mov     [rbp-0C0h],rax
    52e: mov     rdx,[rbp-70h]
    532: mov     [rbp-0C8h],rdx
    539: mov     [rbp-190h],rax
    540: mov     [rbp-188h],rdx
    547: mov     qword ptr [rbp-180h],4
    552: mov     qword ptr [rbp-178h],4
    55d: mov     qword ptr [rbp-170h],1
    568: mov     edi,0FFFFFE98h
    56d: lea     rsi,[k9]
    574: call    ryo_h_AddrAbs
    579: call    fn10
    57e: nop     [rcx-70h]
    585: mov     qword ptr [rbp-150h],1
    590: imul    rdx,[rbp-150h],4
    598: mov     [rbp-158h],rdx
    59f: mov     edi,0FFFFFFF8h
    5a4: mov     esi,0FFFFFF48h
    5a9: mov     edx,0FFFFFEA8h
    5ae: call    ryo_h_Memcpy
    5b3: mov     rax,[rbp-98h]
    5ba: imul    rcx,[rbp-0A0h],4
    5c2: add     rax,rcx
    5c5: mov     [rbp-10h],rax
    5c9: mov     [rbp-0B8h],rax
    5d0: mov     rdx,[rbp-8]
    5d4: imul    rcx,[rbp-0A0h],4
    5dc: add     rdx,rcx
    5df: mov     [rbp-0C0h],rdx
    5e6: mov     byte ptr [rbp-149h],1
    5ed: test    byte ptr [rbp-149h],0FFh
    5f4: je      654h
    5f6: mov     r8,[rbp-10h]
    5fa: mov     [rbp-0C8h],r8
    601: mov     [rbp-0D0h],rdx
    608: mov     [rbp-190h],r8
    60f: mov     [rbp-188h],rdx
    616: mov     qword ptr [rbp-180h],4
    621: mov     qword ptr [rbp-178h],4
    62c: mov     qword ptr [rbp-170h],1
    637: mov     edi,0FFFFFE98h
    63c: lea     rsi,[k11]
    643: call    ryo_h_AddrAbs
    648: call    fn12
    64d: nop     [rcx-70h]
    654: mov     qword ptr [rbp-150h],1
    65f: imul    rdx,[rbp-150h],4
    667: mov     [rbp-158h],rdx
    66e: mov     edi,0FFFFFF40h
    673: mov     esi,0FFFFFF48h
    678: mov     edx,0FFFFFEA8h
    67d: call    ryo_h_Memcpy
    682: mov     qword ptr [rbp-0A8h],1
    68d: jmp     260h
    692: mov     rax,[rbp-0F8h]
    699: mov     [rbp-20h],rax
    69d: mov     edi,0FFFFFFE0h
    6a2: xor     esi,esi
    6a4: mov     edx,2
    6a9: call    ryo_h_SwitchDenseW64
    6ae: lea     rcx,[6C0h]
    6b5: movsxd  rax,[rcx+rax*4]
    6b9: add     rax,rcx
    6bc: jmp     rax
    6be: int3
    6bf: int3
    6c0: .long   384h
    6c4: .long   347h
    6c8: .long   340h
    6cc: mov     rax,[rbp-38h]
    6d0: mov     [rbp-130h],rax
    6d7: mov     byte ptr [rbp-149h],1
    6de: test    byte ptr [rbp-149h],0FFh
    6e5: je      724h
    6e7: jmp     6EEh
    6e9: jmp     300h
    6ee: mov     rax,[rbp-130h]
    6f5: mov     [rbp-190h],rax
    6fc: mov     qword ptr [rbp-188h],1
    707: mov     edi,0FFFFFE80h
    70c: lea     rsi,[k13]
    713: call    ryo_h_AddrAbs
    718: call    fn14
    71d: nop     [rcx-80h]
    724: mov     rax,[rbp-130h]
    72b: add     rax,1
    72f: mov     [rbp-138h],rax
    736: mov     [rbp-38h],rax
    73a: mov     rdx,[rbp-130h]
    741: mov     [rbp-118h],rdx
    748: mov     qword ptr [rbp-120h],1
    753: mov     [rbp-128h],rdx
    75a: mov     rdi,[rbp-108h]
    761: imul    rcx,rdx,4
    765: add     rdi,rcx
    768: mov     [rbp-48h],rdi
    76c: mov     [rbp-130h],rdi
    773: mov     r8,[rbp-110h]
    77a: imul    rcx,rdx,4
    77e: add     r8,rcx
    781: mov     [rbp-50h],r8
    785: mov     byte ptr [rbp-149h],1
    78c: test    byte ptr [rbp-149h],0FFh
    793: je      7F3h
    795: mov     r11,[rbp-48h]
    799: mov     [rbp-138h],r11
    7a0: mov     [rbp-140h],r8
    7a7: mov     [rbp-190h],r11
    7ae: mov     [rbp-188h],r8
    7b5: mov     qword ptr [rbp-180h],4
    7c0: mov     qword ptr [rbp-178h],4
    7cb: mov     qword ptr [rbp-170h],1
    7d6: mov     edi,0FFFFFE98h
    7db: lea     rsi,[k15]
    7e2: call    ryo_h_AddrAbs
    7e7: call    fn16
    7ec: nop     [rcx-80h]
    7f3: mov     qword ptr [rbp-150h],1
    7fe: imul    rdx,[rbp-150h],4
    806: mov     [rbp-158h],rdx
    80d: mov     edi,0FFFFFFB0h
    812: mov     esi,0FFFFFED0h
    817: mov     edx,0FFFFFEA8h
    81c: call    ryo_h_Memcpy
    821: mov     rax,[rbp-110h]
    828: mov     [rbp-190h],rax
    82f: mov     rdx,[rbp-50h]
    833: mov     [rbp-188h],rdx
    83a: mov     rsi,[rbp+30h]
    83e: mov     [rbp-180h],rsi
    845: call    fn17
    84a: nop     [rcx-50h]
    851: jmp     420h
    856: mov     rax,[rbp-0D8h]
    85d: mov     [rbp-0E8h],rax
    864: mov     [rbp-190h],rax
    86b: mov     qword ptr [rbp-188h],4
    876: mov     qword ptr [rbp-180h],4
    881: mov     rdi,[rbp-0E0h]
    888: mov     [rbp-178h],rdi
    88f: mov     edi,0FFFFFE90h
    894: lea     rsi,[k18]
    89b: call    ryo_h_AddrAbs
    8a0: call    fn19
    8a5: nop     [rcx-80h]
    8ac: mov     rax,[rbp-0D8h]
    8b3: mov     [rbp-0F0h],rax
    8ba: mov     rdx,[rbp-0E0h]
    8c1: mov     [rbp-0E8h],rdx
    8c8: mov     [rbp-0D0h],rax
    8cf: mov     [rbp-0C8h],rdx
    8d6: mov     rsi,[rbp-0B8h]
    8dd: mov     [rbp-0D8h],rsi
    8e4: mov     edi,0FFFFFE70h
    8e9: mov     esi,0FFFFFF30h
    8ee: call    ryo_h_MovW128
    8f3: mov     rax,[rbp-0D8h]
    8fa: mov     [rbp-180h],rax
    901: mov     rdx,[rbp+30h]
    905: mov     [rbp-178h],rdx
    90c: call    fn20
    911: nop     [rcx-50h]
    918: jmp     480h
    91d: nop     [rax]
    920: lea     rdi,[sym21]
    927: lea     rsi,[site22]
    92e: mov     edx,0FFFFFEB0h
    933: call    ryo_h_CallExt
    938: test    rax,rax
    93b: je      948h
    93d: call    rax
    93f: nop     [rcx-148h]
    946: jmp     958h
    948: mov     rdi,rbp
    94b: lea     rsi,[ro+4]
    952: call    qword ptr [sym23]
    958: call    ryo_h_Unreachable
    95d: ud2
    95f: mov     rdi,rax
    962: mov     esi,0FFFFFF78h
    967: call    ryo_h_Lpad
    96c: jmp     4C0h
    971: mov     rdi,rax
    974: mov     esi,0FFFFFF78h
    979: call    ryo_h_Lpad
    97e: jmp     920h
    980: mov     rdi,rax
    983: mov     esi,0FFFFFF78h
    988: call    ryo_h_Lpad
    98d: jmp     500h

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,160h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     rax,2
     17: jae     1Eh
     19: jmp     2B0h
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
     57: mov     rdx,[rbp+10h]
     5b: mov     [rbp-40h],rdx
     5f: mov     rsi,[rbp+18h]
     63: mov     [rbp-38h],rsi
     67: mov     [rbp-0F8h],rdx
     6e: test    byte ptr [rbp-0E9h],0FFh
     75: je      81h
     77: mov     r8,[rbp-60h]
     7b: mov     [rbp-8],r8
     7f: jmp     8Ch
     81: mov     rax,[rbp-0E8h]
     88: mov     [rbp-8],rax
     8c: mov     byte ptr [rbp-121h],1
     93: test    byte ptr [rbp-121h],0FFh
     9a: je      30Bh
     a0: jmp     2BBh
     a5: nop     [rax+rax]
     ae: xchg    ax,ax
     b0: mov     rax,[rbp-20h]
     b4: mov     [rbp-110h],rax
     bb: mov     rdx,[rbp-18h]
     bf: mov     [rbp-108h],rdx
     c6: mov     [rbp-100h],rdx
     cd: cmp     rdx,0Dh
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
    11d: mov     rdx,[rbp-18h]
    121: mov     [rbp-108h],rdx
    128: mov     [rbp-100h],rdx
    12f: cmp     rdx,9
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
    1a5: mov     rdx,[rbp+20h]
    1a9: mov     [rbp-148h],rdx
    1b0: call    fn2
    1b5: nop     [rcx-10h]
    1bc: test    byte ptr [rbp-0E9h],0FFh
    1c3: je      1CAh
    1c5: jmp     2B0h
    1ca: mov     rax,[rbp-20h]
    1ce: mov     [rbp-110h],rax
    1d5: mov     rdx,[rbp-18h]
    1d9: mov     [rbp-108h],rdx
    1e0: mov     [rbp-120h],rax
    1e7: mov     [rbp-118h],rdx
    1ee: mov     [rbp-100h],rax
    1f5: mov     rsi,[rbp-40h]
    1f9: mov     [rbp-108h],rsi
    200: cmp     rax,rsi
    203: je      22Dh
    205: lea     rdi,[rbp-0E0h]
    20c: mov     [rbp-48h],rdi
    210: mov     [rbp-28h],rdi
    214: mov     byte ptr [rbp-121h],1
    21b: test    byte ptr [rbp-121h],0FFh
    222: je      400h
    228: jmp     3B0h
    22d: mov     rax,[rbp-0F8h]
    234: imul    rcx,[rbp-0E8h],4
    23c: add     rax,rcx
    23f: mov     [rbp-100h],rax
    246: mov     rdx,[rbp-60h]
    24a: sub     rdx,[rbp-0E8h]
    251: mov     [rbp-108h],rdx
    258: mov     byte ptr [rbp-121h],1
    25f: test    byte ptr [rbp-121h],0FFh
    266: je      387h
    26c: jmp     331h
    271: nop     [rax+rax]
    27a: nop     [rax+rax]
    280: mov     rax,[rbp-48h]
    284: mov     [rbp-100h],rax
    28b: mov     byte ptr [rbp-121h],1
    292: test    byte ptr [rbp-121h],0FFh
    299: je      4B9h
    29f: jmp     457h
    2a4: nop     [rax+rax]
    2ad: nop     [rax]
    2b0: xor     edi,edi
    2b2: xor     esi,esi
    2b4: call    ryo_h_Ret
    2b9: leave
    2ba: ret
    2bb: mov     rax,[rbp-40h]
    2bf: mov     [rbp-100h],rax
    2c6: mov     [rbp-160h],rax
    2cd: mov     qword ptr [rbp-158h],4
    2d8: mov     qword ptr [rbp-150h],4
    2e3: mov     rdi,[rbp-8]
    2e7: mov     [rbp-148h],rdi
    2ee: mov     edi,0FFFFFEC0h
    2f3: lea     rsi,[k3]
    2fa: call    ryo_h_AddrAbs
    2ff: call    fn4
    304: nop     [rcx-40h]
    30b: mov     rax,[rbp-0F8h]
    312: mov     [rbp-108h],rax
    319: mov     rdx,[rbp-8]
    31d: mov     [rbp-100h],rdx
    324: mov     [rbp-20h],rax
    328: mov     [rbp-18h],rdx
    32c: jmp     0B0h
    331: mov     rax,[rbp-100h]
    338: mov     [rbp-110h],rax
    33f: mov     [rbp-160h],rax
    346: mov     qword ptr [rbp-158h],4
    351: mov     qword ptr [rbp-150h],4
    35c: mov     rdi,[rbp-108h]
    363: mov     [rbp-148h],rdi
    36a: mov     edi,0FFFFFEC0h
    36f: lea     rsi,[k5]
    376: call    ryo_h_AddrAbs
    37b: call    fn6
    380: nop     [rcx-48h]
    387: mov     rax,[rbp-100h]
    38e: mov     [rbp-118h],rax
    395: mov     rdx,[rbp-108h]
    39c: mov     [rbp-110h],rdx
    3a3: mov     [rbp-20h],rax
    3a7: mov     [rbp-18h],rdx
    3ab: jmp     0B0h
    3b0: mov     rax,[rbp-40h]
    3b4: mov     [rbp-110h],rax
    3bb: mov     [rbp-160h],rax
    3c2: mov     qword ptr [rbp-158h],4
    3cd: mov     qword ptr [rbp-150h],4
    3d8: mov     rdi,[rbp-60h]
    3dc: mov     [rbp-148h],rdi
    3e3: mov     edi,0FFFFFEC0h
    3e8: lea     rsi,[k7]
    3ef: call    ryo_h_AddrAbs
    3f4: call    fn8
    3f9: nop     [rcx-48h]
    400: mov     rax,[rbp-0F8h]
    407: mov     [rbp-58h],rax
    40b: mov     rdx,[rbp-60h]
    40f: mov     [rbp-50h],rdx
    413: mov     [rbp-108h],rax
    41a: mov     [rbp-100h],rdx
    421: mov     edi,0FFFFFEA0h
    426: mov     esi,0FFFFFEF8h
    42b: call    ryo_h_MovW128
    430: mov     rax,[rbp-28h]
    434: mov     [rbp-150h],rax
    43b: mov     rdx,[rbp+20h]
    43f: mov     [rbp-148h],rdx
    446: call    fn9
    44b: nop     [rcx-30h]
    452: jmp     280h
    457: mov     rax,[rbp-48h]
    45b: mov     [rbp-108h],rax
    462: mov     rdx,[rbp-40h]
    466: mov     [rbp-110h],rdx
    46d: mov     [rbp-160h],rax
    474: mov     [rbp-158h],rdx
    47b: mov     qword ptr [rbp-150h],4
    486: mov     qword ptr [rbp-148h],4
    491: mov     r8,[rbp-60h]
    495: mov     [rbp-140h],r8
    49c: mov     edi,0FFFFFEC8h
    4a1: lea     rsi,[k10]
    4a8: call    ryo_h_AddrAbs
    4ad: call    fn11
    4b2: nop     [rcx-58h]
    4b9: imul    rax,[rbp-60h],4
    4be: mov     [rbp-128h],rax
    4c5: mov     edi,0FFFFFF08h
    4ca: mov     esi,0FFFFFF00h
    4cf: mov     edx,0FFFFFED8h
    4d4: call    ryo_h_Memcpy
    4d9: jmp     2B0h

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
     25: mov     rdx,[rbp+18h]
     29: mov     [rbp-10h],rdx
     2d: mov     [rbp-8],rax
     31: mov     [rbp-40h],rax
     35: mov     qword ptr [rbp-38h],0
     3d: mov     qword ptr [rbp-30h],0Ch
     45: mov     r8,[rbp+20h]
     49: mov     [rbp-28h],r8
     4d: call    fn0
     52: nop     [rcx]
     59: mov     rax,[rbp-8]
     5d: mov     [rbp-40h],rax
     61: mov     qword ptr [rbp-38h],1
     69: mov     qword ptr [rbp-30h],0Ah
     71: mov     rdi,[rbp+20h]
     75: mov     [rbp-28h],rdi
     79: call    fn1
     7e: nop     [rcx]
     85: mov     rax,[rbp-8]
     89: mov     [rbp-40h],rax
     8d: mov     qword ptr [rbp-38h],2
     95: mov     qword ptr [rbp-30h],9
     9d: mov     rdi,[rbp+20h]
     a1: mov     [rbp-28h],rdi
     a5: call    fn2
     aa: nop     [rcx]
     b1: mov     rax,[rbp-8]
     b5: mov     [rbp-40h],rax
     b9: mov     qword ptr [rbp-38h],3
     c1: mov     qword ptr [rbp-30h],7
     c9: mov     rdi,[rbp+20h]
     cd: mov     [rbp-28h],rdi
     d1: call    fn3
     d6: nop     [rcx]
     dd: mov     rax,[rbp-8]
     e1: mov     [rbp-40h],rax
     e5: mov     qword ptr [rbp-38h],5
     ed: mov     qword ptr [rbp-30h],0Bh
     f5: mov     rdi,[rbp+20h]
     f9: mov     [rbp-28h],rdi
     fd: call    fn4
    102: nop     [rcx]
    109: mov     rax,[rbp-8]
    10d: mov     [rbp-40h],rax
    111: mov     qword ptr [rbp-38h],6
    119: mov     qword ptr [rbp-30h],8
    121: mov     rdi,[rbp+20h]
    125: mov     [rbp-28h],rdi
    129: call    fn5
    12e: nop     [rcx]
    135: mov     rax,[rbp-8]
    139: mov     [rbp-40h],rax
    13d: mov     qword ptr [rbp-38h],1
    145: mov     qword ptr [rbp-30h],6
    14d: mov     rdi,[rbp+20h]
    151: mov     [rbp-28h],rdi
    155: call    fn6
    15a: nop     [rcx]
    161: mov     rax,[rbp-8]
    165: mov     [rbp-40h],rax
    169: mov     qword ptr [rbp-38h],2
    171: mov     qword ptr [rbp-30h],3
    179: mov     rdi,[rbp+20h]
    17d: mov     [rbp-28h],rdi
    181: call    fn7
    186: nop     [rcx]
    18d: mov     rax,[rbp-8]
    191: mov     [rbp-40h],rax
    195: mov     qword ptr [rbp-38h],4
    19d: mov     qword ptr [rbp-30h],0Bh
    1a5: mov     rdi,[rbp+20h]
    1a9: mov     [rbp-28h],rdi
    1ad: call    fn8
    1b2: nop     [rcx]
    1b9: mov     rax,[rbp-8]
    1bd: mov     [rbp-40h],rax
    1c1: mov     qword ptr [rbp-38h],7
    1c9: mov     qword ptr [rbp-30h],9
    1d1: mov     rdi,[rbp+20h]
    1d5: mov     [rbp-28h],rdi
    1d9: call    fn9
    1de: nop     [rcx]
    1e5: mov     rax,[rbp-8]
    1e9: mov     [rbp-40h],rax
    1ed: mov     qword ptr [rbp-38h],8
    1f5: mov     qword ptr [rbp-30h],0Ah
    1fd: mov     rdi,[rbp+20h]
    201: mov     [rbp-28h],rdi
    205: call    fn10
    20a: nop     [rcx]
    211: mov     rax,[rbp-8]
    215: mov     [rbp-40h],rax
    219: mov     qword ptr [rbp-38h],0
    221: mov     qword ptr [rbp-30h],4
    229: mov     rdi,[rbp+20h]
    22d: mov     [rbp-28h],rdi
    231: call    fn11
    236: nop     [rcx]
    23d: mov     rax,[rbp-8]
    241: mov     [rbp-40h],rax
    245: mov     qword ptr [rbp-38h],1
    24d: mov     qword ptr [rbp-30h],2
    255: mov     rdi,[rbp+20h]
    259: mov     [rbp-28h],rdi
    25d: call    fn12
    262: nop     [rcx]
    269: mov     rax,[rbp-8]
    26d: mov     [rbp-40h],rax
    271: mov     qword ptr [rbp-38h],3
    279: mov     qword ptr [rbp-30h],6
    281: mov     rdi,[rbp+20h]
    285: mov     [rbp-28h],rdi
    289: call    fn13
    28e: nop     [rcx]
    295: mov     rax,[rbp-8]
    299: mov     [rbp-40h],rax
    29d: mov     qword ptr [rbp-38h],7
    2a5: mov     qword ptr [rbp-30h],8
    2ad: mov     rdi,[rbp+20h]
    2b1: mov     [rbp-28h],rdi
    2b5: call    fn14
    2ba: nop     [rcx]
    2c1: mov     rax,[rbp-8]
    2c5: mov     [rbp-40h],rax
    2c9: mov     qword ptr [rbp-38h],9
    2d1: mov     qword ptr [rbp-30h],0Ah
    2d9: mov     rdi,[rbp+20h]
    2dd: mov     [rbp-28h],rdi
    2e1: call    fn15
    2e6: nop     [rcx]
    2ed: mov     rax,[rbp-8]
    2f1: mov     [rbp-40h],rax
    2f5: mov     qword ptr [rbp-38h],0Bh
    2fd: mov     qword ptr [rbp-30h],0Ch
    305: mov     rdi,[rbp+20h]
    309: mov     [rbp-28h],rdi
    30d: call    fn16
    312: nop     [rcx]
    319: mov     rax,[rbp-8]
    31d: mov     [rbp-40h],rax
    321: mov     qword ptr [rbp-38h],4
    329: mov     qword ptr [rbp-30h],6
    331: mov     rdi,[rbp+20h]
    335: mov     [rbp-28h],rdi
    339: call    fn17
    33e: nop     [rcx]
    345: mov     rax,[rbp-8]
    349: mov     [rbp-40h],rax
    34d: mov     qword ptr [rbp-38h],5
    355: mov     qword ptr [rbp-30h],9
    35d: mov     rdi,[rbp+20h]
    361: mov     [rbp-28h],rdi
    365: call    fn18
    36a: nop     [rcx]
    371: mov     rax,[rbp-8]
    375: mov     [rbp-40h],rax
    379: mov     qword ptr [rbp-38h],8
    381: mov     qword ptr [rbp-30h],0Bh
    389: mov     rdi,[rbp+20h]
    38d: mov     [rbp-28h],rdi
    391: call    fn19
    396: nop     [rcx]
    39d: mov     rax,[rbp-8]
    3a1: mov     [rbp-40h],rax
    3a5: mov     qword ptr [rbp-38h],0Ah
    3ad: mov     qword ptr [rbp-30h],0Ch
    3b5: mov     rdi,[rbp+20h]
    3b9: mov     [rbp-28h],rdi
    3bd: call    fn20
    3c2: nop     [rcx]
    3c9: mov     rax,[rbp-8]
    3cd: mov     [rbp-40h],rax
    3d1: mov     qword ptr [rbp-38h],0
    3d9: mov     qword ptr [rbp-30h],5
    3e1: mov     rdi,[rbp+20h]
    3e5: mov     [rbp-28h],rdi
    3e9: call    fn21
    3ee: nop     [rcx]
    3f5: mov     rax,[rbp-8]
    3f9: mov     [rbp-40h],rax
    3fd: mov     qword ptr [rbp-38h],3
    405: mov     qword ptr [rbp-30h],8
    40d: mov     rdi,[rbp+20h]
    411: mov     [rbp-28h],rdi
    415: call    fn22
    41a: nop     [rcx]
    421: mov     rax,[rbp-8]
    425: mov     [rbp-40h],rax
    429: mov     qword ptr [rbp-38h],4
    431: mov     qword ptr [rbp-30h],7
    439: mov     rdi,[rbp+20h]
    43d: mov     [rbp-28h],rdi
    441: call    fn23
    446: nop     [rcx]
    44d: mov     rax,[rbp-8]
    451: mov     [rbp-40h],rax
    455: mov     qword ptr [rbp-38h],6
    45d: mov     qword ptr [rbp-30h],0Bh
    465: mov     rdi,[rbp+20h]
    469: mov     [rbp-28h],rdi
    46d: call    fn24
    472: nop     [rcx]
    479: mov     rax,[rbp-8]
    47d: mov     [rbp-40h],rax
    481: mov     qword ptr [rbp-38h],9
    489: mov     qword ptr [rbp-30h],0Ah
    491: mov     rdi,[rbp+20h]
    495: mov     [rbp-28h],rdi
    499: call    fn25
    49e: nop     [rcx]
    4a5: mov     rax,[rbp-8]
    4a9: mov     [rbp-40h],rax
    4ad: mov     qword ptr [rbp-38h],0
    4b5: mov     qword ptr [rbp-30h],1
    4bd: mov     rdi,[rbp+20h]
    4c1: mov     [rbp-28h],rdi
    4c5: call    fn26
    4ca: nop     [rcx]
    4d1: mov     rax,[rbp-8]
    4d5: mov     [rbp-40h],rax
    4d9: mov     qword ptr [rbp-38h],2
    4e1: mov     qword ptr [rbp-30h],5
    4e9: mov     rdi,[rbp+20h]
    4ed: mov     [rbp-28h],rdi
    4f1: call    fn27
    4f6: nop     [rcx]
    4fd: mov     rax,[rbp-8]
    501: mov     [rbp-40h],rax
    505: mov     qword ptr [rbp-38h],6
    50d: mov     qword ptr [rbp-30h],9
    515: mov     rdi,[rbp+20h]
    519: mov     [rbp-28h],rdi
    51d: call    fn28
    522: nop     [rcx]
    529: mov     rax,[rbp-8]
    52d: mov     [rbp-40h],rax
    531: mov     qword ptr [rbp-38h],7
    539: mov     qword ptr [rbp-30h],8
    541: mov     rdi,[rbp+20h]
    545: mov     [rbp-28h],rdi
    549: call    fn29
    54e: nop     [rcx]
    555: mov     rax,[rbp-8]
    559: mov     [rbp-40h],rax
    55d: mov     qword ptr [rbp-38h],0Ah
    565: mov     qword ptr [rbp-30h],0Bh
    56d: mov     rdi,[rbp+20h]
    571: mov     [rbp-28h],rdi
    575: call    fn30
    57a: nop     [rcx]
    581: mov     rax,[rbp-8]
    585: mov     [rbp-40h],rax
    589: mov     qword ptr [rbp-38h],1
    591: mov     qword ptr [rbp-30h],3
    599: mov     rdi,[rbp+20h]
    59d: mov     [rbp-28h],rdi
    5a1: call    fn31
    5a6: nop     [rcx]
    5ad: mov     rax,[rbp-8]
    5b1: mov     [rbp-40h],rax
    5b5: mov     qword ptr [rbp-38h],2
    5bd: mov     qword ptr [rbp-30h],4
    5c5: mov     rdi,[rbp+20h]
    5c9: mov     [rbp-28h],rdi
    5cd: call    fn32
    5d2: nop     [rcx]
    5d9: mov     rax,[rbp-8]
    5dd: mov     [rbp-40h],rax
    5e1: mov     qword ptr [rbp-38h],5
    5e9: mov     qword ptr [rbp-30h],6
    5f1: mov     rdi,[rbp+20h]
    5f5: mov     [rbp-28h],rdi
    5f9: call    fn33
    5fe: nop     [rcx]
    605: mov     rax,[rbp-8]
    609: mov     [rbp-40h],rax
    60d: mov     qword ptr [rbp-38h],9
    615: mov     qword ptr [rbp-30h],0Ah
    61d: mov     rdi,[rbp+20h]
    621: mov     [rbp-28h],rdi
    625: call    fn34
    62a: nop     [rcx]
    631: mov     rax,[rbp-8]
    635: mov     [rbp-40h],rax
    639: mov     qword ptr [rbp-38h],1
    641: mov     qword ptr [rbp-30h],2
    649: mov     rdi,[rbp+20h]
    64d: mov     [rbp-28h],rdi
    651: call    fn35
    656: nop     [rcx]
    65d: mov     rax,[rbp-8]
    661: mov     [rbp-40h],rax
    665: mov     qword ptr [rbp-38h],3
    66d: mov     qword ptr [rbp-30h],4
    675: mov     rdi,[rbp+20h]
    679: mov     [rbp-28h],rdi
    67d: call    fn36
    682: nop     [rcx]
    689: mov     rax,[rbp-8]
    68d: mov     [rbp-40h],rax
    691: mov     qword ptr [rbp-38h],5
    699: mov     qword ptr [rbp-30h],7
    6a1: mov     rdi,[rbp+20h]
    6a5: mov     [rbp-28h],rdi
    6a9: call    fn37
    6ae: nop     [rcx]
    6b5: mov     rax,[rbp-8]
    6b9: mov     [rbp-40h],rax
    6bd: mov     qword ptr [rbp-38h],6
    6c5: mov     qword ptr [rbp-30h],8
    6cd: mov     rdi,[rbp+20h]
    6d1: mov     [rbp-28h],rdi
    6d5: call    fn38
    6da: nop     [rcx]
    6e1: mov     rax,[rbp-8]
    6e5: mov     [rbp-40h],rax
    6e9: mov     qword ptr [rbp-38h],2
    6f1: mov     qword ptr [rbp-30h],3
    6f9: mov     rdi,[rbp+20h]
    6fd: mov     [rbp-28h],rdi
    701: call    fn39
    706: nop     [rcx]
    70d: mov     rax,[rbp-8]
    711: mov     [rbp-40h],rax
    715: mov     qword ptr [rbp-38h],4
    71d: mov     qword ptr [rbp-30h],5
    725: mov     rdi,[rbp+20h]
    729: mov     [rbp-28h],rdi
    72d: call    fn40
    732: nop     [rcx]
    739: mov     rax,[rbp-8]
    73d: mov     [rbp-40h],rax
    741: mov     qword ptr [rbp-38h],6
    749: mov     qword ptr [rbp-30h],7
    751: mov     rdi,[rbp+20h]
    755: mov     [rbp-28h],rdi
    759: call    fn41
    75e: nop     [rcx]
    765: mov     rax,[rbp-8]
    769: mov     [rbp-40h],rax
    76d: mov     qword ptr [rbp-38h],8
    775: mov     qword ptr [rbp-30h],9
    77d: mov     rdi,[rbp+20h]
    781: mov     [rbp-28h],rdi
    785: call    fn42
    78a: nop     [rcx]
    791: mov     rax,[rbp-8]
    795: mov     [rbp-40h],rax
    799: mov     qword ptr [rbp-38h],3
    7a1: mov     qword ptr [rbp-30h],4
    7a9: mov     rdi,[rbp+20h]
    7ad: mov     [rbp-28h],rdi
    7b1: call    fn43
    7b6: nop     [rcx]
    7bd: mov     rax,[rbp-8]
    7c1: mov     [rbp-40h],rax
    7c5: mov     qword ptr [rbp-38h],5
    7cd: mov     qword ptr [rbp-30h],6
    7d5: mov     rdi,[rbp+20h]
    7d9: mov     [rbp-28h],rdi
    7dd: call    fn44
    7e2: nop     [rcx]
    7e9: xor     edi,edi
    7eb: xor     esi,esi
    7ed: call    ryo_h_Ret
    7f2: leave
    7f3: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rdx,[rbp+10h]
     17: imul    rcx,[rbp-78h],8
     1c: add     rdx,rcx
     1f: mov     [rbp-28h],rdx
     23: mov     [rbp-20h],rdx
     27: mov     rsi,[rbp+10h]
     2b: mov     [rbp-30h],rsi
     2f: mov     [rbp-18h],rdx
     33: mov     [rbp-10h],rsi
     37: mov     rdi,[rbp+20h]
     3b: mov     [rbp-0B0h],rdi
     42: mov     [rbp-0A8h],rdx
     49: mov     [rbp-0A0h],rsi
     50: call    fn0
     55: nop     [rcx-1]
     5c: mov     qword ptr [rbp-78h],3
     64: mov     rdx,[rbp+10h]
     68: imul    rcx,[rbp-78h],8
     6d: add     rdx,rcx
     70: mov     [rbp-28h],rdx
     74: mov     [rbp-20h],rdx
     78: mov     qword ptr [rbp-78h],2
     80: mov     rdi,[rbp+10h]
     84: imul    rcx,[rbp-78h],8
     89: add     rdi,rcx
     8c: mov     [rbp-38h],rdi
     90: mov     [rbp-30h],rdi
     94: mov     [rbp-18h],rdx
     98: mov     [rbp-10h],rdi
     9c: mov     r8,[rbp+20h]
     a0: mov     [rbp-0B0h],r8
     a7: mov     [rbp-0A8h],rdx
     ae: mov     [rbp-0A0h],rdi
     b5: call    fn1
     ba: nop     [rcx-2]
     c1: mov     edi,0FFFFFFE8h
     c6: mov     esi,0FFFFFFFFh
     cb: call    ryo_h_ZextW8W64
     d0: mov     rax,[rbp+10h]
     d4: imul    rcx,[rbp-18h],8
     d9: add     rax,rcx
     dc: mov     [rbp-10h],rax
     e0: movzx   edx,byte ptr [rbp-1]
     e4: xor     dl,1
     e7: mov     [rbp-3],dl
     ea: mov     edi,0FFFFFFE0h
     ef: mov     esi,0FFFFFFFDh
     f4: call    ryo_h_ZextW8W64
     f9: mov     rax,[rbp+10h]
     fd: imul    rcx,[rbp-20h],8
    102: add     rax,rcx
    105: mov     [rbp-18h],rax
    109: mov     edi,0FFFFFFD0h
    10e: mov     esi,0FFFFFFFEh
    113: call    ryo_h_ZextW8W64
    118: mov     qword ptr [rbp-78h],2
    120: mov     rdx,[rbp-78h]
    124: add     rdx,[rbp-30h]
    128: mov     [rbp-28h],rdx
    12c: mov     rsi,[rbp+10h]
    130: imul    rcx,rdx,8
    134: add     rsi,rcx
    137: mov     [rbp-20h],rsi
    13b: movzx   edi,byte ptr [rbp-2]
    13f: xor     dil,1
    143: mov     [rbp-3],dil
    147: mov     edi,0FFFFFFC8h
    14c: mov     esi,0FFFFFFFDh
    151: call    ryo_h_ZextW8W64
    156: mov     qword ptr [rbp-78h],2
    15e: mov     rdx,[rbp-78h]
    162: add     rdx,[rbp-38h]
    166: mov     [rbp-30h],rdx
    16a: mov     rsi,[rbp+10h]
    16e: imul    rcx,rdx,8
    172: add     rsi,rcx
    175: mov     [rbp-28h],rsi
    179: mov     rdi,[rbp-20h]
    17d: mov     [rbp-40h],rdi
    181: mov     r8,[rbp-10h]
    185: mov     [rbp-48h],r8
    189: mov     [rbp-38h],rdi
    18d: mov     [rbp-30h],r8
    191: mov     r9,[rbp+20h]
    195: mov     [rbp-0B0h],r9
    19c: mov     [rbp-0A8h],rdi
    1a3: mov     [rbp-0A0h],r8
    1aa: call    fn2
    1af: nop     [rcx-3]
    1b6: mov     rax,[rbp-28h]
    1ba: mov     [rbp-40h],rax
    1be: mov     rdx,[rbp-18h]
    1c2: mov     [rbp-48h],rdx
    1c6: mov     [rbp-38h],rax
    1ca: mov     [rbp-30h],rdx
    1ce: mov     rsi,[rbp+20h]
    1d2: mov     [rbp-0B0h],rsi
    1d9: mov     [rbp-0A8h],rax
    1e0: mov     [rbp-0A0h],rdx
    1e7: call    fn3
    1ec: nop     [rcx-4]
    1f3: movzx   eax,byte ptr [rbp-3]
    1f7: mov     [rbp-0A8h],al
    1fd: mov     rdx,[rbp-20h]
    201: mov     [rbp-0B0h],rdx
    208: mov     rsi,[rbp-10h]
    20c: mov     [rbp-0A0h],rsi
    213: call    fn4
    218: nop     [rcx-30h]
    21f: movzx   eax,byte ptr [rbp-4]
    223: mov     [rbp-0A8h],al
    229: mov     rdx,[rbp-18h]
    22d: mov     [rbp-0B0h],rdx
    234: mov     rsi,[rbp-28h]
    238: mov     [rbp-0A0h],rsi
    23f: call    fn5
    244: nop     [rcx-38h]
    24b: movzx   eax,byte ptr [rbp-4]
    24f: mov     [rbp-0A8h],al
    255: mov     rdx,[rbp-20h]
    259: mov     [rbp-0B0h],rdx
    260: mov     rsi,[rbp-18h]
    264: mov     [rbp-0A0h],rsi
    26b: call    fn6
    270: nop     [rcx-48h]
    277: movzx   eax,byte ptr [rbp-3]
    27b: mov     [rbp-0A8h],al
    281: mov     rdx,[rbp-10h]
    285: mov     [rbp-0B0h],rdx
    28c: mov     rsi,[rbp-48h]
    290: mov     [rbp-0A0h],rsi
    297: call    fn7
    29c: nop     [rcx-40h]
    2a3: movzx   eax,byte ptr [rbp-3]
    2a7: mov     [rbp-0A8h],al
    2ad: mov     rdx,[rbp-18h]
    2b1: mov     [rbp-0B0h],rdx
    2b8: mov     rsi,[rbp-20h]
    2bc: mov     [rbp-0A0h],rsi
    2c3: call    fn8
    2c8: nop     [rcx-50h]
    2cf: movzx   eax,byte ptr [rbp-4]
    2d3: mov     [rbp-0A8h],al
    2d9: mov     rdx,[rbp-28h]
    2dd: mov     [rbp-0B0h],rdx
    2e4: mov     rsi,[rbp-50h]
    2e8: mov     [rbp-0A0h],rsi
    2ef: call    fn9
    2f4: nop     [rcx-48h]
    2fb: mov     rax,[rbp-48h]
    2ff: mov     [rbp-60h],rax
    303: mov     rdx,[rbp-40h]
    307: mov     [rbp-68h],rdx
    30b: mov     [rbp-58h],rax
    30f: mov     [rbp-50h],rdx
    313: mov     rsi,[rbp+20h]
    317: mov     [rbp-0B0h],rsi
    31e: mov     [rbp-0A8h],rax
    325: mov     [rbp-0A0h],rdx
    32c: call    fn10
    331: nop     [rcx-5]
    338: movzx   eax,byte ptr [rbp-5]
    33c: mov     [rbp-0A8h],al
    342: mov     rdx,[rbp-48h]
    346: mov     [rbp-0B0h],rdx
    34d: mov     rsi,[rbp-40h]
    351: mov     [rbp-0A0h],rsi
    358: call    fn11
    35d: nop     [rcx-50h]
    364: movzx   eax,byte ptr [rbp-5]
    368: mov     [rbp-0A8h],al
    36e: mov     rdx,[rbp-40h]
    372: mov     [rbp-0B0h],rdx
    379: mov     rsi,[rbp-48h]
    37d: mov     [rbp-0A0h],rsi
    384: call    fn12
    389: nop     [rcx-58h]
    390: mov     byte ptr [rbp-71h],1
    394: test    byte ptr [rbp-71h],0FFh
    398: je      3F6h
    39a: mov     rsi,[rbp-30h]
    39e: mov     [rbp-60h],rsi
    3a2: mov     rdi,[rbp+18h]
    3a6: mov     [rbp-68h],rdi
    3aa: mov     [rbp-0B0h],rsi
    3b1: mov     [rbp-0A8h],rdi
    3b8: mov     qword ptr [rbp-0A0h],8
    3c3: mov     qword ptr [rbp-98h],4
    3ce: mov     qword ptr [rbp-90h],1
    3d9: mov     edi,0FFFFFF78h
    3de: lea     rsi,[k13]
    3e5: call    ryo_h_AddrAbs
    3ea: call    fn14
    3ef: nop     [rcx]
    3f6: mov     qword ptr [rbp-78h],1
    3fe: imul    rdx,[rbp-78h],8
    403: mov     [rbp-80h],rdx
    407: mov     edi,18h
    40c: mov     esi,0FFFFFFD0h
    411: mov     edx,0FFFFFF80h
    416: call    ryo_h_Memcpy
    41b: mov     qword ptr [rbp-78h],1
    423: mov     rdx,[rbp+18h]
    427: imul    rcx,[rbp-78h],8
    42c: add     rdx,rcx
    42f: mov     [rbp-60h],rdx
    433: mov     byte ptr [rbp-71h],1
    437: test    byte ptr [rbp-71h],0FFh
    43b: je      495h
    43d: mov     r8,[rbp-50h]
    441: mov     [rbp-68h],r8
    445: mov     [rbp-70h],rdx
    449: mov     [rbp-0B0h],r8
    450: mov     [rbp-0A8h],rdx
    457: mov     qword ptr [rbp-0A0h],8
    462: mov     qword ptr [rbp-98h],4
    46d: mov     qword ptr [rbp-90h],1
    478: mov     edi,0FFFFFF78h
    47d: lea     rsi,[k15]
    484: call    ryo_h_AddrAbs
    489: call    fn16
    48e: nop     [rcx]
    495: mov     qword ptr [rbp-78h],1
    49d: imul    rdx,[rbp-78h],8
    4a2: mov     [rbp-80h],rdx
    4a6: mov     edi,0FFFFFFA0h
    4ab: mov     esi,0FFFFFFB0h
    4b0: mov     edx,0FFFFFF80h
    4b5: call    ryo_h_Memcpy
    4ba: mov     qword ptr [rbp-78h],2
    4c2: mov     rdx,[rbp+18h]
    4c6: imul    rcx,[rbp-78h],8
    4cb: add     rdx,rcx
    4ce: mov     [rbp-60h],rdx
    4d2: mov     byte ptr [rbp-71h],1
    4d6: test    byte ptr [rbp-71h],0FFh
    4da: je      534h
    4dc: mov     r8,[rbp-58h]
    4e0: mov     [rbp-68h],r8
    4e4: mov     [rbp-70h],rdx
    4e8: mov     [rbp-0B0h],r8
    4ef: mov     [rbp-0A8h],rdx
    4f6: mov     qword ptr [rbp-0A0h],8
    501: mov     qword ptr [rbp-98h],4
    50c: mov     qword ptr [rbp-90h],1
    517: mov     edi,0FFFFFF78h
    51c: lea     rsi,[k17]
    523: call    ryo_h_AddrAbs
    528: call    fn18
    52d: nop     [rcx]
    534: mov     qword ptr [rbp-78h],1
    53c: imul    rdx,[rbp-78h],8
    541: mov     [rbp-80h],rdx
    545: mov     edi,0FFFFFFA0h
    54a: mov     esi,0FFFFFFA8h
    54f: mov     edx,0FFFFFF80h
    554: call    ryo_h_Memcpy
    559: mov     qword ptr [rbp-78h],3
    561: mov     rdx,[rbp+18h]
    565: imul    rcx,[rbp-78h],8
    56a: add     rdx,rcx
    56d: mov     [rbp-60h],rdx
    571: mov     byte ptr [rbp-71h],1
    575: test    byte ptr [rbp-71h],0FFh
    579: je      5D3h
    57b: mov     r8,[rbp-38h]
    57f: mov     [rbp-68h],r8
    583: mov     [rbp-70h],rdx
    587: mov     [rbp-0B0h],r8
    58e: mov     [rbp-0A8h],rdx
    595: mov     qword ptr [rbp-0A0h],8
    5a0: mov     qword ptr [rbp-98h],4
    5ab: mov     qword ptr [rbp-90h],1
    5b6: mov     edi,0FFFFFF78h
    5bb: lea     rsi,[k19]
    5c2: call    ryo_h_AddrAbs
    5c7: call    fn20
    5cc: nop     [rcx]
    5d3: mov     qword ptr [rbp-78h],1
    5db: imul    rdx,[rbp-78h],8
    5e0: mov     [rbp-80h],rdx
    5e4: mov     edi,0FFFFFFA0h
    5e9: mov     esi,0FFFFFFC8h
    5ee: mov     edx,0FFFFFF80h
    5f3: call    ryo_h_Memcpy
    5f8: xor     edi,edi
    5fa: xor     esi,esi
    5fc: call    ryo_h_Ret
    601: leave
    602: ret

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     qword ptr [rbp-78h],1
     13: mov     rdx,[rbp+10h]
     17: imul    rcx,[rbp-78h],4
     1c: add     rdx,rcx
     1f: mov     [rbp-28h],rdx
     23: mov     [rbp-20h],rdx
     27: mov     rsi,[rbp+10h]
     2b: mov     [rbp-30h],rsi
     2f: mov     [rbp-18h],rdx
     33: mov     [rbp-10h],rsi
     37: mov     rdi,[rbp+20h]
     3b: mov     [rbp-0B0h],rdi
     42: mov     [rbp-0A8h],rdx
     49: mov     [rbp-0A0h],rsi
     50: call    fn0
     55: nop     [rcx-1]
     5c: mov     qword ptr [rbp-78h],3
     64: mov     rdx,[rbp+10h]
     68: imul    rcx,[rbp-78h],4
     6d: add     rdx,rcx
     70: mov     [rbp-28h],rdx
     74: mov     [rbp-20h],rdx
     78: mov     qword ptr [rbp-78h],2
     80: mov     rdi,[rbp+10h]
     84: imul    rcx,[rbp-78h],4
     89: add     rdi,rcx
     8c: mov     [rbp-38h],rdi
     90: mov     [rbp-30h],rdi
     94: mov     [rbp-18h],rdx
     98: mov     [rbp-10h],rdi
     9c: mov     r8,[rbp+20h]
     a0: mov     [rbp-0B0h],r8
     a7: mov     [rbp-0A8h],rdx
     ae: mov     [rbp-0A0h],rdi
     b5: call    fn1
     ba: nop     [rcx-2]
     c1: mov     edi,0FFFFFFE8h
     c6: mov     esi,0FFFFFFFFh
     cb: call    ryo_h_ZextW8W64
     d0: mov     rax,[rbp+10h]
     d4: imul    rcx,[rbp-18h],4
     d9: add     rax,rcx
     dc: mov     [rbp-10h],rax
     e0: movzx   edx,byte ptr [rbp-1]
     e4: xor     dl,1
     e7: mov     [rbp-3],dl
     ea: mov     edi,0FFFFFFE0h
     ef: mov     esi,0FFFFFFFDh
     f4: call    ryo_h_ZextW8W64
     f9: mov     rax,[rbp+10h]
     fd: imul    rcx,[rbp-20h],4
    102: add     rax,rcx
    105: mov     [rbp-18h],rax
    109: mov     edi,0FFFFFFD0h
    10e: mov     esi,0FFFFFFFEh
    113: call    ryo_h_ZextW8W64
    118: mov     qword ptr [rbp-78h],2
    120: mov     rdx,[rbp-78h]
    124: add     rdx,[rbp-30h]
    128: mov     [rbp-28h],rdx
    12c: mov     rsi,[rbp+10h]
    130: imul    rcx,rdx,4
    134: add     rsi,rcx
    137: mov     [rbp-20h],rsi
    13b: movzx   edi,byte ptr [rbp-2]
    13f: xor     dil,1
    143: mov     [rbp-3],dil
    147: mov     edi,0FFFFFFC8h
    14c: mov     esi,0FFFFFFFDh
    151: call    ryo_h_ZextW8W64
    156: mov     qword ptr [rbp-78h],2
    15e: mov     rdx,[rbp-78h]
    162: add     rdx,[rbp-38h]
    166: mov     [rbp-30h],rdx
    16a: mov     rsi,[rbp+10h]
    16e: imul    rcx,rdx,4
    172: add     rsi,rcx
    175: mov     [rbp-28h],rsi
    179: mov     rdi,[rbp-20h]
    17d: mov     [rbp-40h],rdi
    181: mov     r8,[rbp-10h]
    185: mov     [rbp-48h],r8
    189: mov     [rbp-38h],rdi
    18d: mov     [rbp-30h],r8
    191: mov     r9,[rbp+20h]
    195: mov     [rbp-0B0h],r9
    19c: mov     [rbp-0A8h],rdi
    1a3: mov     [rbp-0A0h],r8
    1aa: call    fn2
    1af: nop     [rcx-3]
    1b6: mov     rax,[rbp-28h]
    1ba: mov     [rbp-40h],rax
    1be: mov     rdx,[rbp-18h]
    1c2: mov     [rbp-48h],rdx
    1c6: mov     [rbp-38h],rax
    1ca: mov     [rbp-30h],rdx
    1ce: mov     rsi,[rbp+20h]
    1d2: mov     [rbp-0B0h],rsi
    1d9: mov     [rbp-0A8h],rax
    1e0: mov     [rbp-0A0h],rdx
    1e7: call    fn3
    1ec: nop     [rcx-4]
    1f3: movzx   eax,byte ptr [rbp-3]
    1f7: mov     [rbp-0A8h],al
    1fd: mov     rdx,[rbp-20h]
    201: mov     [rbp-0B0h],rdx
    208: mov     rsi,[rbp-10h]
    20c: mov     [rbp-0A0h],rsi
    213: call    fn4
    218: nop     [rcx-30h]
    21f: movzx   eax,byte ptr [rbp-4]
    223: mov     [rbp-0A8h],al
    229: mov     rdx,[rbp-18h]
    22d: mov     [rbp-0B0h],rdx
    234: mov     rsi,[rbp-28h]
    238: mov     [rbp-0A0h],rsi
    23f: call    fn5
    244: nop     [rcx-38h]
    24b: movzx   eax,byte ptr [rbp-4]
    24f: mov     [rbp-0A8h],al
    255: mov     rdx,[rbp-20h]
    259: mov     [rbp-0B0h],rdx
    260: mov     rsi,[rbp-18h]
    264: mov     [rbp-0A0h],rsi
    26b: call    fn6
    270: nop     [rcx-48h]
    277: movzx   eax,byte ptr [rbp-3]
    27b: mov     [rbp-0A8h],al
    281: mov     rdx,[rbp-10h]
    285: mov     [rbp-0B0h],rdx
    28c: mov     rsi,[rbp-48h]
    290: mov     [rbp-0A0h],rsi
    297: call    fn7
    29c: nop     [rcx-40h]
    2a3: movzx   eax,byte ptr [rbp-3]
    2a7: mov     [rbp-0A8h],al
    2ad: mov     rdx,[rbp-18h]
    2b1: mov     [rbp-0B0h],rdx
    2b8: mov     rsi,[rbp-20h]
    2bc: mov     [rbp-0A0h],rsi
    2c3: call    fn8
    2c8: nop     [rcx-50h]
    2cf: movzx   eax,byte ptr [rbp-4]
    2d3: mov     [rbp-0A8h],al
    2d9: mov     rdx,[rbp-28h]
    2dd: mov     [rbp-0B0h],rdx
    2e4: mov     rsi,[rbp-50h]
    2e8: mov     [rbp-0A0h],rsi
    2ef: call    fn9
    2f4: nop     [rcx-48h]
    2fb: mov     rax,[rbp-48h]
    2ff: mov     [rbp-60h],rax
    303: mov     rdx,[rbp-40h]
    307: mov     [rbp-68h],rdx
    30b: mov     [rbp-58h],rax
    30f: mov     [rbp-50h],rdx
    313: mov     rsi,[rbp+20h]
    317: mov     [rbp-0B0h],rsi
    31e: mov     [rbp-0A8h],rax
    325: mov     [rbp-0A0h],rdx
    32c: call    fn10
    331: nop     [rcx-5]
    338: movzx   eax,byte ptr [rbp-5]
    33c: mov     [rbp-0A8h],al
    342: mov     rdx,[rbp-48h]
    346: mov     [rbp-0B0h],rdx
    34d: mov     rsi,[rbp-40h]
    351: mov     [rbp-0A0h],rsi
    358: call    fn11
    35d: nop     [rcx-50h]
    364: movzx   eax,byte ptr [rbp-5]
    368: mov     [rbp-0A8h],al
    36e: mov     rdx,[rbp-40h]
    372: mov     [rbp-0B0h],rdx
    379: mov     rsi,[rbp-48h]
    37d: mov     [rbp-0A0h],rsi
    384: call    fn12
    389: nop     [rcx-58h]
    390: mov     byte ptr [rbp-71h],1
    394: test    byte ptr [rbp-71h],0FFh
    398: je      3F6h
    39a: mov     rsi,[rbp-30h]
    39e: mov     [rbp-60h],rsi
    3a2: mov     rdi,[rbp+18h]
    3a6: mov     [rbp-68h],rdi
    3aa: mov     [rbp-0B0h],rsi
    3b1: mov     [rbp-0A8h],rdi
    3b8: mov     qword ptr [rbp-0A0h],4
    3c3: mov     qword ptr [rbp-98h],4
    3ce: mov     qword ptr [rbp-90h],1
    3d9: mov     edi,0FFFFFF78h
    3de: lea     rsi,[k13]
    3e5: call    ryo_h_AddrAbs
    3ea: call    fn14
    3ef: nop     [rcx]
    3f6: mov     qword ptr [rbp-78h],1
    3fe: imul    rdx,[rbp-78h],4
    403: mov     [rbp-80h],rdx
    407: mov     edi,18h
    40c: mov     esi,0FFFFFFD0h
    411: mov     edx,0FFFFFF80h
    416: call    ryo_h_Memcpy
    41b: mov     qword ptr [rbp-78h],1
    423: mov     rdx,[rbp+18h]
    427: imul    rcx,[rbp-78h],4
    42c: add     rdx,rcx
    42f: mov     [rbp-60h],rdx
    433: mov     byte ptr [rbp-71h],1
    437: test    byte ptr [rbp-71h],0FFh
    43b: je      495h
    43d: mov     r8,[rbp-50h]
    441: mov     [rbp-68h],r8
    445: mov     [rbp-70h],rdx
    449: mov     [rbp-0B0h],r8
    450: mov     [rbp-0A8h],rdx
    457: mov     qword ptr [rbp-0A0h],4
    462: mov     qword ptr [rbp-98h],4
    46d: mov     qword ptr [rbp-90h],1
    478: mov     edi,0FFFFFF78h
    47d: lea     rsi,[k15]
    484: call    ryo_h_AddrAbs
    489: call    fn16
    48e: nop     [rcx]
    495: mov     qword ptr [rbp-78h],1
    49d: imul    rdx,[rbp-78h],4
    4a2: mov     [rbp-80h],rdx
    4a6: mov     edi,0FFFFFFA0h
    4ab: mov     esi,0FFFFFFB0h
    4b0: mov     edx,0FFFFFF80h
    4b5: call    ryo_h_Memcpy
    4ba: mov     qword ptr [rbp-78h],2
    4c2: mov     rdx,[rbp+18h]
    4c6: imul    rcx,[rbp-78h],4
    4cb: add     rdx,rcx
    4ce: mov     [rbp-60h],rdx
    4d2: mov     byte ptr [rbp-71h],1
    4d6: test    byte ptr [rbp-71h],0FFh
    4da: je      534h
    4dc: mov     r8,[rbp-58h]
    4e0: mov     [rbp-68h],r8
    4e4: mov     [rbp-70h],rdx
    4e8: mov     [rbp-0B0h],r8
    4ef: mov     [rbp-0A8h],rdx
    4f6: mov     qword ptr [rbp-0A0h],4
    501: mov     qword ptr [rbp-98h],4
    50c: mov     qword ptr [rbp-90h],1
    517: mov     edi,0FFFFFF78h
    51c: lea     rsi,[k17]
    523: call    ryo_h_AddrAbs
    528: call    fn18
    52d: nop     [rcx]
    534: mov     qword ptr [rbp-78h],1
    53c: imul    rdx,[rbp-78h],4
    541: mov     [rbp-80h],rdx
    545: mov     edi,0FFFFFFA0h
    54a: mov     esi,0FFFFFFA8h
    54f: mov     edx,0FFFFFF80h
    554: call    ryo_h_Memcpy
    559: mov     qword ptr [rbp-78h],3
    561: mov     rdx,[rbp+18h]
    565: imul    rcx,[rbp-78h],4
    56a: add     rdx,rcx
    56d: mov     [rbp-60h],rdx
    571: mov     byte ptr [rbp-71h],1
    575: test    byte ptr [rbp-71h],0FFh
    579: je      5D3h
    57b: mov     r8,[rbp-38h]
    57f: mov     [rbp-68h],r8
    583: mov     [rbp-70h],rdx
    587: mov     [rbp-0B0h],r8
    58e: mov     [rbp-0A8h],rdx
    595: mov     qword ptr [rbp-0A0h],4
    5a0: mov     qword ptr [rbp-98h],4
    5ab: mov     qword ptr [rbp-90h],1
    5b6: mov     edi,0FFFFFF78h
    5bb: lea     rsi,[k19]
    5c2: call    ryo_h_AddrAbs
    5c7: call    fn20
    5cc: nop     [rcx]
    5d3: mov     qword ptr [rbp-78h],1
    5db: imul    rdx,[rbp-78h],4
    5e0: mov     [rbp-80h],rdx
    5e4: mov     edi,0FFFFFFA0h
    5e9: mov     esi,0FFFFFFC8h
    5ee: mov     edx,0FFFFFF80h
    5f3: call    ryo_h_Memcpy
    5f8: xor     edi,edi
    5fa: xor     esi,esi
    5fc: call    ryo_h_Ret
    601: leave
    602: ret

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-60h],rax
     14: mov     rdx,[rbp+20h]
     18: mov     [rbp-58h],rdx
     1c: mov     rsi,[rbp+28h]
     20: mov     [rbp-50h],rsi
     24: call    fn0
     29: nop     [rcx]
     30: mov     qword ptr [rbp-30h],4
     38: mov     rdx,[rbp+10h]
     3c: imul    rcx,[rbp-30h],8
     41: add     rdx,rcx
     44: mov     [rbp-10h],rdx
     48: mov     [rbp-8],rdx
     4c: mov     qword ptr [rbp-30h],4
     54: mov     rdi,[rbp+20h]
     58: imul    rcx,[rbp-30h],8
     5d: add     rdi,rcx
     60: mov     [rbp-10h],rdi
     64: mov     [rbp-60h],rdx
     68: mov     [rbp-58h],rdi
     6c: mov     r8,[rbp+28h]
     70: mov     [rbp-50h],r8
     74: call    fn1
     79: nop     [rcx]
     80: mov     rax,[rbp+20h]
     84: mov     [rbp-18h],rax
     88: mov     byte ptr [rbp-29h],1
     8c: test    byte ptr [rbp-29h],0FFh
     90: je      0ECh
     92: jmp     0ABh
     94: nop     [rax+rax]
     9d: nop     [rax]
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
    100: mov     rsi,[rbp-20h]
    104: mov     [rbp-8],rsi
    108: mov     edi,0FFFFFFA0h
    10d: mov     esi,0FFFFFFF0h
    112: call    ryo_h_MovW128
    117: mov     rax,[rbp+18h]
    11b: mov     [rbp-50h],rax
    11f: mov     rdx,[rbp+28h]
    123: mov     [rbp-48h],rdx
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
     14: mov     rdx,[rbp+20h]
     18: mov     [rbp-58h],rdx
     1c: mov     rsi,[rbp+28h]
     20: mov     [rbp-50h],rsi
     24: call    fn0
     29: nop     [rcx]
     30: mov     qword ptr [rbp-30h],4
     38: mov     rdx,[rbp+10h]
     3c: imul    rcx,[rbp-30h],4
     41: add     rdx,rcx
     44: mov     [rbp-10h],rdx
     48: mov     [rbp-8],rdx
     4c: mov     qword ptr [rbp-30h],4
     54: mov     rdi,[rbp+20h]
     58: imul    rcx,[rbp-30h],4
     5d: add     rdi,rcx
     60: mov     [rbp-10h],rdi
     64: mov     [rbp-60h],rdx
     68: mov     [rbp-58h],rdi
     6c: mov     r8,[rbp+28h]
     70: mov     [rbp-50h],r8
     74: call    fn1
     79: nop     [rcx]
     80: mov     rax,[rbp+20h]
     84: mov     [rbp-18h],rax
     88: mov     byte ptr [rbp-29h],1
     8c: test    byte ptr [rbp-29h],0FFh
     90: je      0ECh
     92: jmp     0ABh
     94: nop     [rax+rax]
     9d: nop     [rax]
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
    100: mov     rsi,[rbp-20h]
    104: mov     [rbp-8],rsi
    108: mov     edi,0FFFFFFA0h
    10d: mov     esi,0FFFFFFF0h
    112: call    ryo_h_MovW128
    117: mov     rax,[rbp+18h]
    11b: mov     [rbp-50h],rax
    11f: mov     rdx,[rbp+28h]
    123: mov     [rbp-48h],rdx
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
     25: mov     rdx,[rbp+18h]
     29: mov     [rbp-10h],rdx
     2d: mov     [rbp-8],rax
     31: mov     [rbp-40h],rax
     35: mov     qword ptr [rbp-38h],0
     3d: mov     qword ptr [rbp-30h],3
     45: mov     r8,[rbp+20h]
     49: mov     [rbp-28h],r8
     4d: call    fn0
     52: nop     [rcx]
     59: mov     rax,[rbp-8]
     5d: mov     [rbp-40h],rax
     61: mov     qword ptr [rbp-38h],1
     69: mov     qword ptr [rbp-30h],7
     71: mov     rdi,[rbp+20h]
     75: mov     [rbp-28h],rdi
     79: call    fn1
     7e: nop     [rcx]
     85: mov     rax,[rbp-8]
     89: mov     [rbp-40h],rax
     8d: mov     qword ptr [rbp-38h],2
     95: mov     qword ptr [rbp-30h],5
     9d: mov     rdi,[rbp+20h]
     a1: mov     [rbp-28h],rdi
     a5: call    fn2
     aa: nop     [rcx]
     b1: mov     rax,[rbp-8]
     b5: mov     [rbp-40h],rax
     b9: mov     qword ptr [rbp-38h],4
     c1: mov     qword ptr [rbp-30h],8
     c9: mov     rdi,[rbp+20h]
     cd: mov     [rbp-28h],rdi
     d1: call    fn3
     d6: nop     [rcx]
     dd: mov     rax,[rbp-8]
     e1: mov     [rbp-40h],rax
     e5: mov     qword ptr [rbp-38h],0
     ed: mov     qword ptr [rbp-30h],7
     f5: mov     rdi,[rbp+20h]
     f9: mov     [rbp-28h],rdi
     fd: call    fn4
    102: nop     [rcx]
    109: mov     rax,[rbp-8]
    10d: mov     [rbp-40h],rax
    111: mov     qword ptr [rbp-38h],2
    119: mov     qword ptr [rbp-30h],4
    121: mov     rdi,[rbp+20h]
    125: mov     [rbp-28h],rdi
    129: call    fn5
    12e: nop     [rcx]
    135: mov     rax,[rbp-8]
    139: mov     [rbp-40h],rax
    13d: mov     qword ptr [rbp-38h],3
    145: mov     qword ptr [rbp-30h],8
    14d: mov     rdi,[rbp+20h]
    151: mov     [rbp-28h],rdi
    155: call    fn6
    15a: nop     [rcx]
    161: mov     rax,[rbp-8]
    165: mov     [rbp-40h],rax
    169: mov     qword ptr [rbp-38h],5
    171: mov     qword ptr [rbp-30h],6
    179: mov     rdi,[rbp+20h]
    17d: mov     [rbp-28h],rdi
    181: call    fn7
    186: nop     [rcx]
    18d: mov     rax,[rbp-8]
    191: mov     [rbp-40h],rax
    195: mov     qword ptr [rbp-38h],0
    19d: mov     qword ptr [rbp-30h],2
    1a5: mov     rdi,[rbp+20h]
    1a9: mov     [rbp-28h],rdi
    1ad: call    fn8
    1b2: nop     [rcx]
    1b9: mov     rax,[rbp-8]
    1bd: mov     [rbp-40h],rax
    1c1: mov     qword ptr [rbp-38h],1
    1c9: mov     qword ptr [rbp-30h],3
    1d1: mov     rdi,[rbp+20h]
    1d5: mov     [rbp-28h],rdi
    1d9: call    fn9
    1de: nop     [rcx]
    1e5: mov     rax,[rbp-8]
    1e9: mov     [rbp-40h],rax
    1ed: mov     qword ptr [rbp-38h],4
    1f5: mov     qword ptr [rbp-30h],5
    1fd: mov     rdi,[rbp+20h]
    201: mov     [rbp-28h],rdi
    205: call    fn10
    20a: nop     [rcx]
    211: mov     rax,[rbp-8]
    215: mov     [rbp-40h],rax
    219: mov     qword ptr [rbp-38h],7
    221: mov     qword ptr [rbp-30h],8
    229: mov     rdi,[rbp+20h]
    22d: mov     [rbp-28h],rdi
    231: call    fn11
    236: nop     [rcx]
    23d: mov     rax,[rbp-8]
    241: mov     [rbp-40h],rax
    245: mov     qword ptr [rbp-38h],1
    24d: mov     qword ptr [rbp-30h],4
    255: mov     rdi,[rbp+20h]
    259: mov     [rbp-28h],rdi
    25d: call    fn12
    262: nop     [rcx]
    269: mov     rax,[rbp-8]
    26d: mov     [rbp-40h],rax
    271: mov     qword ptr [rbp-38h],3
    279: mov     qword ptr [rbp-30h],6
    281: mov     rdi,[rbp+20h]
    285: mov     [rbp-28h],rdi
    289: call    fn13
    28e: nop     [rcx]
    295: mov     rax,[rbp-8]
    299: mov     [rbp-40h],rax
    29d: mov     qword ptr [rbp-38h],5
    2a5: mov     qword ptr [rbp-30h],7
    2ad: mov     rdi,[rbp+20h]
    2b1: mov     [rbp-28h],rdi
    2b5: call    fn14
    2ba: nop     [rcx]
    2c1: mov     rax,[rbp-8]
    2c5: mov     [rbp-40h],rax
    2c9: mov     qword ptr [rbp-38h],0
    2d1: mov     qword ptr [rbp-30h],1
    2d9: mov     rdi,[rbp+20h]
    2dd: mov     [rbp-28h],rdi
    2e1: call    fn15
    2e6: nop     [rcx]
    2ed: mov     rax,[rbp-8]
    2f1: mov     [rbp-40h],rax
    2f5: mov     qword ptr [rbp-38h],2
    2fd: mov     qword ptr [rbp-30h],4
    305: mov     rdi,[rbp+20h]
    309: mov     [rbp-28h],rdi
    30d: call    fn16
    312: nop     [rcx]
    319: mov     rax,[rbp-8]
    31d: mov     [rbp-40h],rax
    321: mov     qword ptr [rbp-38h],3
    329: mov     qword ptr [rbp-30h],5
    331: mov     rdi,[rbp+20h]
    335: mov     [rbp-28h],rdi
    339: call    fn17
    33e: nop     [rcx]
    345: mov     rax,[rbp-8]
    349: mov     [rbp-40h],rax
    34d: mov     qword ptr [rbp-38h],6
    355: mov     qword ptr [rbp-30h],8
    35d: mov     rdi,[rbp+20h]
    361: mov     [rbp-28h],rdi
    365: call    fn18
    36a: nop     [rcx]
    371: mov     rax,[rbp-8]
    375: mov     [rbp-40h],rax
    379: mov     qword ptr [rbp-38h],2
    381: mov     qword ptr [rbp-30h],3
    389: mov     rdi,[rbp+20h]
    38d: mov     [rbp-28h],rdi
    391: call    fn19
    396: nop     [rcx]
    39d: mov     rax,[rbp-8]
    3a1: mov     [rbp-40h],rax
    3a5: mov     qword ptr [rbp-38h],4
    3ad: mov     qword ptr [rbp-30h],5
    3b5: mov     rdi,[rbp+20h]
    3b9: mov     [rbp-28h],rdi
    3bd: call    fn20
    3c2: nop     [rcx]
    3c9: mov     rax,[rbp-8]
    3cd: mov     [rbp-40h],rax
    3d1: mov     qword ptr [rbp-38h],6
    3d9: mov     qword ptr [rbp-30h],7
    3e1: mov     rdi,[rbp+20h]
    3e5: mov     [rbp-28h],rdi
    3e9: call    fn21
    3ee: nop     [rcx]
    3f5: mov     rax,[rbp-8]
    3f9: mov     [rbp-40h],rax
    3fd: mov     qword ptr [rbp-38h],1
    405: mov     qword ptr [rbp-30h],2
    40d: mov     rdi,[rbp+20h]
    411: mov     [rbp-28h],rdi
    415: call    fn22
    41a: nop     [rcx]
    421: mov     rax,[rbp-8]
    425: mov     [rbp-40h],rax
    429: mov     qword ptr [rbp-38h],3
    431: mov     qword ptr [rbp-30h],4
    439: mov     rdi,[rbp+20h]
    43d: mov     [rbp-28h],rdi
    441: call    fn23
    446: nop     [rcx]
    44d: mov     rax,[rbp-8]
    451: mov     [rbp-40h],rax
    455: mov     qword ptr [rbp-38h],5
    45d: mov     qword ptr [rbp-30h],6
    465: mov     rdi,[rbp+20h]
    469: mov     [rbp-28h],rdi
    46d: call    fn24
    472: nop     [rcx]
    479: xor     edi,edi
    47b: xor     esi,esi
    47d: call    ryo_h_Ret
    482: leave
    483: ret

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: imul    rcx,[rbp+18h],4
     14: add     rax,rcx
     17: mov     [rbp-10h],rax
     1b: mov     rdx,[rbp+10h]
     1f: imul    rcx,[rbp+20h],4
     24: add     rdx,rcx
     27: mov     [rbp-18h],rdx
     2b: mov     [rbp-38h],rdx
     2f: mov     [rbp-40h],rax
     33: mov     [rbp-30h],rdx
     37: mov     [rbp-28h],rax
     3b: mov     rsi,[rbp+28h]
     3f: mov     [rbp-90h],rsi
     46: mov     [rbp-88h],rdx
     4d: mov     [rbp-80h],rax
     51: call    fn0
     56: nop     [rcx-19h]
     5d: movzx   eax,byte ptr [rbp-19h]
     61: mov     [rbp-88h],al
     67: mov     rdx,[rbp-18h]
     6b: mov     [rbp-90h],rdx
     72: mov     rsi,[rbp-10h]
     76: mov     [rbp-80h],rsi
     7a: call    fn1
     7f: nop     [rcx-28h]
     86: movzx   eax,byte ptr [rbp-19h]
     8a: mov     [rbp-88h],al
     90: mov     rdx,[rbp-10h]
     94: mov     [rbp-90h],rdx
     9b: mov     rsi,[rbp-18h]
     9f: mov     [rbp-80h],rsi
     a3: call    fn2
     a8: nop     [rcx-30h]
     af: mov     rax,[rbp-30h]
     b3: mov     [rbp-40h],rax
     b7: mov     eax,[rax]
     b9: mov     [rbp-34h],eax
     bc: mov     [rbp-38h],eax
     bf: mov     [rbp-20h],eax
     c2: mov     rdx,[rbp-28h]
     c6: mov     [rbp-38h],rdx
     ca: mov     byte ptr [rbp-49h],1
     ce: test    byte ptr [rbp-49h],0FFh
     d2: je      162h
     d8: jmp     0FBh
     da: nop     [rax+rax]
     e0: lea     rax,[rbp-20h]
     e4: mov     [rbp-38h],rax
     e8: mov     byte ptr [rbp-49h],1
     ec: test    byte ptr [rbp-49h],0FFh
     f0: je      1DFh
     f6: jmp     18Ch
     fb: mov     rax,[rbp-28h]
     ff: mov     [rbp-40h],rax
    103: mov     rdx,[rbp-10h]
    107: mov     [rbp-48h],rdx
    10b: mov     byte ptr [rbp-49h],0
    10f: test    byte ptr [rbp-49h],0FFh
    113: je      11Bh
    115: mov     byte ptr [rbp-1Ah],1
    119: jmp     11Fh
    11b: mov     byte ptr [rbp-1Ah],0
    11f: mov     rax,[rbp-40h]
    123: mov     [rbp-90h],rax
    12a: mov     rdx,[rbp-48h]
    12e: mov     [rbp-88h],rdx
    135: mov     qword ptr [rbp-80h],4
    13d: movzx   edi,byte ptr [rbp-1Ah]
    141: mov     [rbp-78h],dil
    145: mov     edi,0FFFFFF90h
    14a: lea     rsi,[k3]
    151: call    ryo_h_AddrAbs
    156: call    fn4
    15b: nop     [rcx-8]
    162: mov     qword ptr [rbp-50h],1
    16a: imul    rdx,[rbp-50h],4
    16f: mov     [rbp-58h],rdx
    173: mov     edi,0FFFFFFF0h
    178: mov     esi,0FFFFFFC8h
    17d: mov     edx,0FFFFFFA8h
    182: call    ryo_h_Memmove
    187: jmp     0E0h
    18c: mov     rax,[rbp-38h]
    190: mov     [rbp-40h],rax
    194: mov     rdx,[rbp-18h]
    198: mov     [rbp-48h],rdx
    19c: mov     [rbp-90h],rax
    1a3: mov     [rbp-88h],rdx
    1aa: mov     qword ptr [rbp-80h],4
    1b2: mov     qword ptr [rbp-78h],4
    1ba: mov     qword ptr [rbp-70h],1
    1c2: mov     edi,0FFFFFF98h
    1c7: lea     rsi,[k5]
    1ce: call    ryo_h_AddrAbs
    1d3: call    fn6
    1d8: nop     [rcx-8]
    1df: mov     qword ptr [rbp-50h],1
    1e7: imul    rdx,[rbp-50h],4
    1ec: mov     [rbp-58h],rdx
    1f0: mov     edi,0FFFFFFE8h
    1f5: mov     esi,0FFFFFFC8h
    1fa: mov     edx,0FFFFFFA8h
    1ff: call    ryo_h_Memcpy
    204: xor     edi,edi
    206: xor     esi,esi
    208: call    ryo_h_Ret
    20d: leave
    20e: ret

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
     ae: mov     rsi,[rbp-48h]
     b2: mov     [rbp-20h],rsi
     b6: mov     [rbp-40h],rax
     ba: mov     rdi,[rbp-28h]
     be: mov     [rbp-38h],rdi
     c2: mov     byte ptr [rbp-59h],1
     c6: test    byte ptr [rbp-59h],0FFh
     ca: je      113h
     cc: mov     r10,[rbp-28h]
     d0: mov     [rbp-40h],r10
     d4: mov     [rbp-90h],r10
     db: mov     qword ptr [rbp-88h],8
     e6: mov     qword ptr [rbp-80h],4
     ee: mov     rax,[rbp-30h]
     f2: mov     [rbp-78h],rax
     f6: mov     edi,0FFFFFF90h
     fb: lea     rsi,[k4]
    102: call    ryo_h_AddrAbs
    107: call    fn5
    10c: nop     [rcx-28h]
    113: mov     rax,[rbp-38h]
    117: mov     [rbp-48h],rax
    11b: mov     rdx,[rbp-30h]
    11f: mov     [rbp-40h],rdx
    123: mov     [rbp-10h],rax
    127: mov     [rbp-8],rdx
    12b: mov     edi,0FFFFFFF0h
    130: mov     esi,10h
    135: call    ryo_h_Ret
    13a: leave
    13b: ret

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-18h],rax
     13: cmp     rax,[rbp+30h]
     17: jb      0ADh
     1d: mov     rdx,[rbp+10h]
     21: mov     [rbp-40h],rdx
     25: mov     rsi,[rbp+18h]
     29: mov     [rbp-38h],rsi
     2d: mov     edi,0FFFFFF60h
     32: mov     esi,0FFFFFFC0h
     37: call    ryo_h_MovW128
     3c: mov     rax,[rbp+40h]
     40: mov     [rbp-90h],rax
     47: call    fn0
     4c: nop     [rcx-30h]
     53: mov     rax,[rbp-30h]
     57: mov     [rbp-20h],rax
     5b: movzx   edx,byte ptr [rbp-28h]
     5f: mov     [rbp-0Bh],dl
     62: cmp     rax,[rbp-18h]
     66: setbe   [rbp-9]
     6a: cmp     rax,[rbp+30h]
     6e: jb      0ADh
     70: test    byte ptr [rbp-0Bh],0FFh
     74: je      90h
     76: cmp     rax,0
     7a: jb      151h
     80: jmp     1C2h
     85: nop     [rax+rax]
     8e: xchg    ax,ax
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
     ca: mov     rdx,[rbp-18h]
     ce: mov     [rbp-98h],rdx
     d5: call    fn2
     da: nop     [rcx-20h]
     e1: jmp     20Ah
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
    115: mov     rdx,[rbp-18h]
    119: mov     [rbp-98h],rdx
    120: call    fn3
    125: nop     [rcx-20h]
    12c: jmp     316h
    131: nop     [rax+rax]
    13a: nop     [rax+rax]
    140: mov     edi,0FFFFFFF8h
    145: mov     esi,8
    14a: call    ryo_h_Ret
    14f: leave
    150: ret
    151: mov     qword ptr [rbp-0A0h],0
    15c: mov     rdx,[rbp-20h]
    160: mov     [rbp-98h],rdx
    167: mov     rsi,[rbp-18h]
    16b: mov     [rbp-90h],rsi
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
    1ca: mov     rdx,[rbp+18h]
    1ce: mov     [rbp-48h],rdx
    1d2: mov     [rbp-58h],rax
    1d6: mov     [rbp-40h],rax
    1da: mov     rsi,[rbp-20h]
    1de: mov     [rbp-38h],rsi
    1e2: mov     [rbp-30h],rax
    1e6: mov     [rbp-28h],rsi
    1ea: mov     edi,0FFFFFF60h
    1ef: mov     esi,0FFFFFFD0h
    1f4: call    ryo_h_MovW128
    1f9: call    fn8
    1fe: nop     [rcx-9]
    205: jmp     90h
    20a: cmp     qword ptr [rbp-20h],0
    20f: jb      301h
    215: jmp     303h
    21a: nop     [rax+rax]
    220: mov     rax,[rbp+10h]
    224: mov     [rbp-50h],rax
    228: mov     rdx,[rbp+18h]
    22c: mov     [rbp-48h],rdx
    230: mov     [rbp-58h],rax
    234: mov     [rbp-40h],rax
    238: mov     rsi,[rbp-20h]
    23c: mov     [rbp-38h],rsi
    240: mov     [rbp-30h],rax
    244: mov     [rbp-28h],rsi
    248: mov     edi,0FFFFFF60h
    24d: mov     esi,0FFFFFFD0h
    252: call    ryo_h_MovW128
    257: mov     edi,0FFFFFF70h
    25c: mov     esi,20h
    261: call    ryo_h_MovW128
    266: mov     dword ptr [rbp-78h],0
    26d: mov     qword ptr [rbp-80h],0
    275: mov     rsi,[rbp+40h]
    279: mov     [rbp-70h],rsi
    27d: call    fn9
    282: nop     [rcx-9]
    289: jmp     0F0h
    28e: xchg    ax,ax
    290: mov     qword ptr [rbp-0A0h],0
    29b: mov     rdx,[rbp-20h]
    29f: mov     [rbp-98h],rdx
    2a6: mov     rsi,[rbp-18h]
    2aa: mov     [rbp-90h],rsi
    2b1: mov     edi,0FFFFFF78h
    2b6: lea     rsi,[k10]
    2bd: call    ryo_h_AddrAbs
    2c2: lea     rdi,[sym11]
    2c9: lea     rsi,[site12]
    2d0: mov     edx,0FFFFFFA0h
    2d5: call    ryo_h_CallExt
    2da: test    rax,rax
    2dd: je      2EAh
    2df: call    rax
    2e1: nop     [rcx-9]
    2e8: jmp     2FAh
    2ea: mov     rdi,rbp
    2ed: lea     rsi,[ro+4]
    2f4: call    qword ptr [sym13]
    2fa: call    ryo_h_Unreachable
    2ff: ud2
    301: jmp     290h
    303: mov     rax,[rbp-18h]
    307: cmp     rax,[rbp-20h]
    30b: jae     220h
    311: jmp     290h
    316: mov     rax,[rbp-20h]
    31a: shl     rax,1
    31e: mov     [rbp-28h],rax
    322: mov     [rbp-8],rax
    326: jmp     140h

fn core::slice::sort::stable::drift::logical_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-28h],rax
     13: mov     rdx,[rbp+28h]
     17: mov     [rbp-38h],rdx
     1b: cmp     rax,rdx
     1e: setbe   [rbp-29h]
     22: test    byte ptr [rbp-29h],0FFh
     26: je      6Ah
     28: mov     rdi,[rbp+30h]
     2c: mov     [rbp-40h],rdi
     30: and     rdi,1
     34: mov     [rbp-38h],rdi
     38: cmp     rdi,1
     3c: sete    [rbp-2Ah]
     40: test    byte ptr [rbp-2Ah],0FFh
     44: je      48h
     46: jmp     6Ah
     48: mov     rax,[rbp+38h]
     4c: mov     [rbp-40h],rax
     50: and     rax,1
     54: mov     [rbp-38h],rax
     58: cmp     rax,1
     5c: sete    [rbp-2Bh]
     60: test    byte ptr [rbp-2Bh],0FFh
     64: je      156h
     6a: mov     rax,[rbp+30h]
     6e: mov     [rbp-20h],rax
     72: and     rax,1
     76: mov     [rbp-38h],rax
     7a: cmp     rax,1
     7e: sete    [rbp-2Ch]
     82: test    byte ptr [rbp-2Ch],0FFh
     86: jne     0B0h
     88: mov     rdi,[rbp-20h]
     8c: shr     rdi,1
     90: mov     [rbp-10h],rdi
     94: cmp     rdi,0
     98: jb      261h
     9e: jmp     263h
     a3: nop     [rax+rax]
     ac: nop     [rax]
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
     dc: mov     rdx,[rbp-28h]
     e0: cmp     rdx,rax
     e3: jb      276h
     e9: jmp     2E7h
     ee: xchg    ax,ax
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
    125: mov     rdx,[rbp+40h]
    129: mov     [rbp-88h],rdx
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
    188: mov     rdx,[rbp+18h]
    18c: mov     [rbp-58h],rdx
    190: mov     [rbp-68h],rax
    194: mov     [rbp-50h],rax
    198: mov     rsi,[rbp-10h]
    19c: mov     [rbp-48h],rsi
    1a0: mov     [rbp-40h],rax
    1a4: mov     [rbp-38h],rsi
    1a8: mov     edi,0FFFFFF50h
    1ad: mov     esi,0FFFFFFC0h
    1b2: call    ryo_h_MovW128
    1b7: mov     edi,0FFFFFF60h
    1bc: mov     esi,20h
    1c1: call    ryo_h_MovW128
    1c6: mov     rax,[rbp+40h]
    1ca: mov     [rbp-90h],rax
    1d1: call    fn1
    1d6: nop     [rcx-8]
    1dd: jmp     0B0h
    1e2: nop     [rax+rax]
    1eb: nop     [rax+rax]
    1f0: mov     qword ptr [rbp-0B0h],0
    1fb: mov     rdx,[rbp-10h]
    1ff: mov     [rbp-0A8h],rdx
    206: mov     rsi,[rbp-28h]
    20a: mov     [rbp-0A0h],rsi
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
    281: mov     rdx,[rbp-28h]
    285: mov     [rbp-0A8h],rdx
    28c: mov     rsi,[rbp-28h]
    290: mov     [rbp-0A0h],rsi
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
    2f3: mov     rdx,[rbp+10h]
    2f7: mov     [rbp-68h],rdx
    2fb: mov     rsi,[rbp+18h]
    2ff: mov     [rbp-60h],rsi
    303: mov     [rbp-70h],rdx
    307: imul    rcx,[rbp-18h],8
    30c: add     rdx,rcx
    30f: mov     [rbp-78h],rdx
    313: mov     [rbp-58h],rdx
    317: mov     [rbp-50h],rax
    31b: mov     [rbp-40h],rdx
    31f: mov     [rbp-38h],rax
    323: mov     edi,0FFFFFF50h
    328: mov     esi,0FFFFFFC0h
    32d: call    ryo_h_MovW128
    332: mov     edi,0FFFFFF60h
    337: mov     esi,20h
    33c: call    ryo_h_MovW128
    341: mov     rax,[rbp+40h]
    345: mov     [rbp-90h],rax
    34c: call    fn10
    351: nop     [rcx-10h]
    358: jmp     0F0h

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,390h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     rax,2
     17: jae     1Eh
     19: jmp     556h
     1e: mov     rax,[rbp-60h]
     22: mov     [rbp-70h],rax
     26: cmp     rax,0
     2a: sete    [rbp-79h]
     2e: test    byte ptr [rbp-79h],0FFh
     32: je      561h
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
     dc: jmp     634h
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
    170: mov     rdx,[rbp-50h]
    174: mov     [rbp-290h],rdx
    17b: mov     edi,0FFFFFD2Eh
    180: lea     rsi,[k9]
    187: mov     edx,42h
    18c: call    ryo_h_Const
    191: lea     rax,[rbp-2D2h]
    198: mov     [rbp-58h],rax
    19c: mov     [rbp-2E8h],rax
    1a3: mov     rdx,[rbp-58h]
    1a7: mov     [rbp-2E0h],rdx
    1ae: mov     qword ptr [rbp-2E8h],0
    1b9: mov     qword ptr [rbp-38h],1
    1c1: nop     [rax+rax]
    1ca: nop     [rax+rax]
    1d0: mov     rax,[rbp-2E8h]
    1d7: mov     [rbp-2F0h],rax
    1de: cmp     rax,[rbp-60h]
    1e2: jae     2F5h
    1e8: mov     rdx,[rbp-2E8h]
    1ef: mov     [rbp-20h],rdx
    1f3: mov     rsi,[rbp-60h]
    1f7: cmp     rsi,rdx
    1fa: jb      639h
    200: jmp     6AAh
    205: nop     [rax+rax]
    20e: xchg    ax,ax
    210: mov     rax,[rbp-2E8h]
    217: mov     [rbp-2F8h],rax
    21e: mov     rdx,[rbp-38h]
    222: mov     [rbp-308h],rdx
    229: shr     rdx,1
    22d: mov     [rbp-300h],rdx
    234: sub     rax,rdx
    237: mov     [rbp-2F0h],rax
    23e: mov     rsi,[rbp-2E8h]
    245: mov     [rbp-2F8h],rsi
    24c: mov     rdi,[rbp-2E8h]
    253: mov     [rbp-308h],rdi
    25a: mov     r8,[rbp-18h]
    25e: mov     [rbp-318h],r8
    265: shr     r8,1
    269: mov     [rbp-310h],r8
    270: add     rdi,r8
    273: mov     [rbp-300h],rdi
    27a: mov     r9,[rbp-68h]
    27e: mov     [rbp-308h],r9
    285: mov     [rbp-318h],rax
    28c: mov     [rbp-320h],rsi
    293: add     rax,rsi
    296: mov     [rbp-310h],rax
    29d: mov     [rbp-328h],rdi
    2a4: add     rsi,rdi
    2a7: mov     [rbp-318h],rsi
    2ae: imul    r9,rax
    2b2: mov     [rbp-330h],r9
    2b9: mov     r10,[rbp-308h]
    2c0: imul    r10,rsi
    2c4: mov     [rbp-338h],r10
    2cb: xor     r9,r10
    2ce: mov     [rbp-328h],r9
    2d5: mov     edi,0FFFFFCB4h
    2da: mov     esi,0FFFFFCD8h
    2df: call    ryo_h_CtlzW64
    2e4: mov     eax,[rbp-34Ch]
    2ea: mov     [rbp-2D8h],eax
    2f0: jmp     75Eh
    2f5: mov     qword ptr [rbp-18h],1
    2fd: mov     byte ptr [rbp-21h],0
    301: nop     [rax+rax]
    30a: nop     [rax+rax]
    310: mov     rax,[rbp-78h]
    314: mov     [rbp-2F0h],rax
    31b: cmp     rax,1
    31f: jbe     443h
    325: mov     rsi,[rbp-78h]
    329: mov     [rbp-300h],rsi
    330: sub     rsi,1
    334: mov     [rbp-2F8h],rsi
    33b: mov     rdi,[rbp-2E0h]
    342: imul    rcx,rsi,1
    346: add     rdi,rcx
    349: mov     [rbp-2F0h],rdi
    350: movzx   edi,byte ptr [rdi]
    353: mov     [rbp-2D5h],dil
    35a: movzx   r8d,byte ptr [rbp-21h]
    35f: mov     [rbp-2D6h],r8b
    366: cmp     dil,r8b
    369: jb      441h
    36f: mov     r9,[rbp-78h]
    373: mov     [rbp-308h],r9
    37a: sub     r9,1
    37e: mov     [rbp-300h],r9
    385: mov     r10,[rbp-290h]
    38c: imul    rcx,r9,8
    390: add     r10,rcx
    393: mov     [rbp-2F8h],r10
    39a: mov     r10,[r10]
    39d: mov     [rbp-2F0h],r10
    3a4: mov     [rbp-308h],r10
    3ab: shr     r10,1
    3af: mov     [rbp-300h],r10
    3b6: mov     r11,[rbp-38h]
    3ba: mov     [rbp-310h],r11
    3c1: shr     r11,1
    3c5: mov     [rbp-308h],r11
    3cc: add     r10,r11
    3cf: mov     [rbp-2F8h],r10
    3d6: mov     rax,[rbp-2E8h]
    3dd: mov     [rbp-308h],rax
    3e4: sub     rax,r10
    3e7: mov     [rbp-300h],rax
    3ee: mov     rdx,[rbp-2E8h]
    3f5: mov     [rbp-30h],rdx
    3f9: mov     rsi,[rbp+10h]
    3fd: mov     [rbp-330h],rsi
    404: mov     r9,[rbp+18h]
    408: mov     [rbp-328h],r9
    40f: mov     byte ptr [rbp-349h],1
    416: test    byte ptr [rbp-349h],0FFh
    41d: je      7B3h
    423: jmp     772h
    428: nop     [rax+rax]
    430: mov     rax,[rbp-78h]
    434: sub     rax,1
    438: mov     [rbp-78h],rax
    43c: jmp     310h
    441: jmp     443h
    443: mov     rax,[rbp-38h]
    447: mov     [rbp-2F0h],rax
    44e: mov     rdx,[rbp-78h]
    452: mov     [rbp-300h],rdx
    459: mov     rsi,[rbp-290h]
    460: imul    rcx,rdx,8
    464: add     rsi,rcx
    467: mov     [rbp-2F8h],rsi
    46e: mov     rcx,[rbp-2F0h]
    475: mov     [rsi],rcx
    478: mov     rdi,[rbp-78h]
    47c: mov     [rbp-2F8h],rdi
    483: mov     r8,[rbp-2E0h]
    48a: imul    rcx,rdi,1
    48e: add     r8,rcx
    491: mov     [rbp-2F0h],r8
    498: movzx   ecx,byte ptr [rbp-21h]
    49c: mov     [r8],cl
    49f: mov     r9,[rbp-78h]
    4a3: add     r9,1
    4a7: mov     [rbp-78h],r9
    4ab: mov     r10,[rbp-2E8h]
    4b2: mov     [rbp-2F0h],r10
    4b9: cmp     r10,[rbp-60h]
    4bd: jb      4EBh
    4bf: mov     r11,[rbp-38h]
    4c3: mov     [rbp-2F8h],r11
    4ca: and     r11,1
    4ce: mov     [rbp-2F0h],r11
    4d5: cmp     r11,1
    4d9: sete    [rbp-2D3h]
    4e0: test    byte ptr [rbp-2D3h],0FFh
    4e7: je      521h
    4e9: jmp     51Fh
    4eb: mov     rax,[rbp-18h]
    4ef: mov     [rbp-2F8h],rax
    4f6: shr     rax,1
    4fa: mov     [rbp-2F0h],rax
    501: mov     rdx,[rbp-2E8h]
    508: add     rdx,rax
    50b: mov     [rbp-2E8h],rdx
    512: mov     rsi,[rbp-18h]
    516: mov     [rbp-38h],rsi
    51a: jmp     1D0h
    51f: jmp     556h
    521: mov     edi,0FFFFFC70h
    526: mov     esi,10h
    52b: call    ryo_h_MovW128
    530: mov     edi,0FFFFFC80h
    535: mov     esi,20h
    53a: call    ryo_h_MovW128
    53f: mov     rax,[rbp+38h]
    543: mov     [rbp-370h],rax
    54a: call    fn10
    54f: nop     [rcx-38h]
    556: xor     edi,edi
    558: xor     esi,esi
    55a: call    ryo_h_Ret
    55f: leave
    560: ret
    561: mov     rax,4000000000000000h
    56b: mov     [rbp-350h],rax
    572: mov     edi,0FFFFFF88h
    577: mov     esi,0FFFFFCB0h
    57c: mov     edx,0FFFFFF90h
    581: call    ryo_h_DivUW64
    586: test    byte ptr [rbp-79h],0FFh
    58a: je      5DCh
    58c: mov     edi,0FFFFFC70h
    591: lea     rsi,[k11]
    598: call    ryo_h_AddrAbs
    59d: lea     rdi,[sym12]
    5a4: lea     rsi,[site13]
    5ab: mov     edx,0FFFFFCB0h
    5b0: call    ryo_h_CallExt
    5b5: test    rax,rax
    5b8: je      5C5h
    5ba: call    rax
    5bc: nop     [rcx-348h]
    5c3: jmp     5D5h
    5c5: mov     rdi,rbp
    5c8: lea     rsi,[ro+4]
    5cf: call    qword ptr [sym14]
    5d5: call    ryo_h_Unreachable
    5da: ud2
    5dc: mov     rax,4000000000000000h
    5e6: mov     [rbp-350h],rax
    5ed: mov     edi,0FFFFFF78h
    5f2: mov     esi,0FFFFFCB0h
    5f7: mov     edx,0FFFFFF90h
    5fc: call    ryo_h_RemUW64
    601: cmp     qword ptr [rbp-88h],0
    609: jbe     619h
    60b: mov     rdx,[rbp-78h]
    60f: add     rdx,1
    613: mov     [rbp-68h],rdx
    617: jmp     621h
    619: mov     rax,[rbp-78h]
    61d: mov     [rbp-68h],rax
    621: cmp     qword ptr [rbp-60h],1000h
    629: jbe     90h
    62f: jmp     0F0h
    634: jmp     140h
    639: mov     rax,[rbp-20h]
    63d: mov     [rbp-390h],rax
    644: mov     rdx,[rbp-60h]
    648: mov     [rbp-388h],rdx
    64f: mov     rsi,[rbp-60h]
    653: mov     [rbp-380h],rsi
    65a: mov     edi,0FFFFFC88h
    65f: lea     rsi,[k15]
    666: call    ryo_h_AddrAbs
    66b: lea     rdi,[sym16]
    672: lea     rsi,[site17]
    679: mov     edx,0FFFFFCB0h
    67e: call    ryo_h_CallExt
    683: test    rax,rax
    686: je      693h
    688: call    rax
    68a: nop     [rcx-58h]
    691: jmp     6A3h
    693: mov     rdi,rbp
    696: lea     rsi,[ro+36]
    69d: call    qword ptr [sym18]
    6a3: call    ryo_h_Unreachable
    6a8: ud2
    6aa: mov     rax,[rbp-60h]
    6ae: sub     rax,[rbp-20h]
    6b2: mov     [rbp-300h],rax
    6b9: mov     rdx,[rbp+10h]
    6bd: mov     [rbp-320h],rdx
    6c4: mov     rsi,[rbp+18h]
    6c8: mov     [rbp-318h],rsi
    6cf: mov     [rbp-328h],rdx
    6d6: imul    rcx,[rbp-20h],8
    6db: add     rdx,rcx
    6de: mov     [rbp-330h],rdx
    6e5: mov     [rbp-310h],rdx
    6ec: mov     [rbp-308h],rax
    6f3: mov     [rbp-2F8h],rdx
    6fa: mov     [rbp-2F0h],rax
    701: mov     rdi,[rbp-70h]
    705: mov     [rbp-300h],rdi
    70c: mov     edi,0FFFFFC70h
    711: mov     esi,0FFFFFD08h
    716: call    ryo_h_MovW128
    71b: mov     edi,0FFFFFC80h
    720: mov     esi,20h
    725: call    ryo_h_MovW128
    72a: mov     rax,[rbp-300h]
    731: mov     [rbp-370h],rax
    738: movzx   edx,byte ptr [rbp+30h]
    73c: mov     [rbp-368h],dl
    742: mov     rsi,[rbp+38h]
    746: mov     [rbp-360h],rsi
    74d: call    fn19
    752: nop     [rcx-18h]
    759: jmp     210h
    75e: mov     edi,0FFFFFFDFh
    763: mov     esi,0FFFFFD28h
    768: call    ryo_h_TruncW32W8
    76d: jmp     310h
    772: mov     rax,[rbp-300h]
    779: mov     [rbp-390h],rax
    780: mov     rdx,[rbp-30h]
    784: mov     [rbp-388h],rdx
    78b: mov     rsi,[rbp-60h]
    78f: mov     [rbp-380h],rsi
    796: mov     edi,0FFFFFC88h
    79b: lea     rsi,[k20]
    7a2: call    ryo_h_AddrAbs
    7a7: call    fn21
    7ac: nop     [rcx-58h]
    7b3: mov     rax,[rbp-30h]
    7b7: sub     rax,[rbp-300h]
    7be: mov     [rbp-338h],rax
    7c5: mov     rdx,[rbp-330h]
    7cc: mov     [rbp-340h],rdx
    7d3: imul    rcx,[rbp-300h],8
    7db: add     rdx,rcx
    7de: mov     [rbp-348h],rdx
    7e5: mov     [rbp-320h],rdx
    7ec: mov     [rbp-318h],rax
    7f3: mov     [rbp-310h],rdx
    7fa: mov     [rbp-308h],rax
    801: mov     rsi,[rbp-38h]
    805: mov     [rbp-318h],rsi
    80c: mov     edi,0FFFFFC70h
    811: mov     esi,0FFFFFCF0h
    816: call    ryo_h_MovW128
    81b: mov     edi,0FFFFFC80h
    820: mov     esi,20h
    825: call    ryo_h_MovW128
    82a: mov     rax,[rbp-2F0h]
    831: mov     [rbp-370h],rax
    838: mov     rdx,[rbp-318h]
    83f: mov     [rbp-368h],rdx
    846: mov     rsi,[rbp+38h]
    84a: mov     [rbp-360h],rsi
    851: call    fn22
    856: nop     [rcx-38h]
    85d: jmp     430h

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
    10a: mov     esi,[rbp-3Ch]
    10d: sub     esi,eax
    10f: mov     [rbp-4],esi
    112: mov     dword ptr [rbp-3Ch],2
    119: mov     r8d,[rbp-3Ch]
    11d: imul    r8d,esi
    121: mov     [rbp-8],r8d
    125: mov     edi,0FFFFFF80h
    12a: mov     esi,10h
    12f: call    ryo_h_MovW128
    134: mov     edi,0FFFFFF90h
    139: mov     esi,20h
    13e: call    ryo_h_MovW128
    143: mov     eax,[rbp-8]
    146: mov     [rbp-58h],eax
    149: mov     qword ptr [rbp-60h],0
    151: mov     rsi,[rbp+30h]
    155: mov     [rbp-50h],rsi
    159: call    fn4
    15e: nop     [rcx]
    165: jmp     80h

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
     e3: mov     rdx,[rbp-38h]
     e7: mov     [rbp-2090h],rdx
     ee: mov     rsi,[rbp-30h]
     f2: mov     [rbp-2088h],rsi
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
    18e: mov     rdx,[rbp-38h]
    192: cmp     rdx,rax
    195: setbe   [rbp-1059h]
    19c: mov     edi,0FFFFDF70h
    1a1: mov     esi,10h
    1a6: call    ryo_h_MovW128
    1ab: mov     edi,0FFFFDF80h
    1b0: mov     esi,0FFFFFFE8h
    1b5: call    ryo_h_MovW128
    1ba: movzx   eax,byte ptr [rbp-1059h]
    1c1: mov     [rbp-2070h],al
    1c7: mov     rdx,[rbp+20h]
    1cb: mov     [rbp-2068h],rdx
    1d2: call    fn8
    1d7: nop     [rcx-18h]
    1de: test    byte ptr [rbp-19h],0FFh
    1e2: jne     20Ch
    1e4: nop     [rax+rax]
    1ed: nop     [rax]
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
    273: mov     rdx,[rbp-58h]
    277: mov     [rbp-2088h],rdx
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
     36: mov     rdx,[rbp-8]
     3a: mov     [rbp-18h],rdx
     3e: jmp     48h
     40: mov     rax,[rbp-10h]
     44: mov     [rbp-18h],rax
     48: mov     rax,[rbp-18h]
     4c: mov     [rbp-38h],rax
     50: mov     rdx,[rbp+28h]
     54: mov     [rbp-40h],rdx
     58: mov     byte ptr [rbp-51h],1
     5c: test    byte ptr [rbp-51h],0FFh
     60: je      1CEh
     66: jmp     17Bh
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
     b4: je      0F6h
     b6: jmp     0ECh
     b8: mov     rax,[rbp-30h]
     bc: mov     [rbp-8],rax
     c0: jmp     0A0h
     c2: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
     ca: mov     rdx,[rbp-30h]
     ce: imul    rcx,[rbp-58h],8
     d3: add     rdx,rcx
     d6: mov     [rbp-8],rdx
     da: jmp     0A0h
     dc: nop     [rax]
     e0: mov     byte ptr [rbp-51h],0
     e4: test    byte ptr [rbp-51h],0FFh
     e8: je      161h
     ea: jmp     157h
     ec: mov     rax,[rbp-30h]
     f0: mov     [rbp-10h],rax
     f4: jmp     0E0h
     f6: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
     fe: mov     rdx,[rbp-30h]
    102: imul    rcx,[rbp-58h],8
    107: add     rdx,rcx
    10a: mov     [rbp-10h],rdx
    10e: jmp     0E0h
    110: mov     rax,[rbp-30h]
    114: mov     [rbp+28h],rax
    118: mov     rdx,[rbp-10h]
    11c: mov     [rbp-48h],rdx
    120: mov     rsi,[rbp-8]
    124: mov     [rbp-50h],rsi
    128: mov     [rbp-40h],rdx
    12c: mov     [rbp-38h],rsi
    130: mov     rdi,[rbp+30h]
    134: mov     [rbp-90h],rdi
    13b: mov     [rbp-88h],rdx
    142: mov     [rbp-80h],rsi
    146: call    fn0
    14b: nop     [rcx-29h]
    152: jmp     30h
    157: mov     rax,[rbp+28h]
    15b: mov     [rbp-30h],rax
    15f: jmp     110h
    161: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    169: mov     rdx,[rbp+28h]
    16d: imul    rcx,[rbp-58h],8
    172: add     rdx,rcx
    175: mov     [rbp-30h],rdx
    179: jmp     110h
    17b: mov     rax,[rbp-18h]
    17f: mov     [rbp-48h],rax
    183: mov     rdx,[rbp-40h]
    187: mov     [rbp-50h],rdx
    18b: mov     [rbp-90h],rax
    192: mov     [rbp-88h],rdx
    199: mov     qword ptr [rbp-80h],8
    1a1: mov     qword ptr [rbp-78h],4
    1a9: mov     qword ptr [rbp-70h],1
    1b1: mov     edi,0FFFFFF98h
    1b6: lea     rsi,[k1]
    1bd: call    ryo_h_AddrAbs
    1c2: call    fn2
    1c7: nop     [rcx-28h]
    1ce: mov     qword ptr [rbp-58h],1
    1d6: imul    rdx,[rbp-58h],8
    1db: mov     [rbp-60h],rdx
    1df: mov     edi,0FFFFFFC0h
    1e4: mov     esi,0FFFFFFC8h
    1e9: mov     edx,0FFFFFFA0h
    1ee: call    ryo_h_Memcpy
    1f3: movzx   eax,byte ptr [rbp-29h]
    1f7: xor     al,1
    1fa: mov     [rbp-2Ah],al
    1fd: mov     edi,0FFFFFFC0h
    202: mov     esi,0FFFFFFD6h
    207: call    ryo_h_ZextW8W64
    20c: mov     rax,[rbp-8]
    210: imul    rcx,[rbp-40h],8
    215: add     rax,rcx
    218: mov     [rbp-38h],rax
    21c: mov     rdx,[rbp+10h]
    220: mov     rcx,[rbp-38h]
    224: mov     [rdx+10h],rcx
    228: mov     edi,0FFFFFFC0h
    22d: mov     esi,0FFFFFFD7h
    232: call    ryo_h_ZextW8W64
    237: mov     rax,[rbp-10h]
    23b: imul    rcx,[rbp-40h],8
    240: add     rax,rcx
    243: mov     [rbp-38h],rax
    247: mov     rdx,[rbp+10h]
    24b: mov     rcx,[rbp-38h]
    24f: mov     [rdx+8],rcx
    253: mov     rsi,[rbp+10h]
    257: mov     rsi,[rsi+10h]
    25b: mov     [rbp-38h],rsi
    25f: mov     [rbp-20h],rsi
    263: cmp     rsi,[rbp+18h]
    267: je      90h
    26d: jmp     70h

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_up::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax]
     17: mov     [rbp-40h],rax
     1b: mov     rdx,[rbp+10h]
     1f: mov     rdx,[rdx+8]
     23: mov     [rbp-48h],rdx
     27: cmp     rax,rdx
     2a: je      0C7h
     30: mov     rsi,[rbp+18h]
     34: mov     [rbp-18h],rsi
     38: cmp     rsi,[rbp+20h]
     3c: je      0C7h
     42: mov     rdi,[rbp+18h]
     46: mov     [rbp-50h],rdi
     4a: mov     r8,[rbp+10h]
     4e: mov     r8,[r8]
     51: mov     [rbp-30h],r8
     55: mov     [rbp-58h],r8
     59: mov     [rbp-48h],rdi
     5d: mov     [rbp-40h],r8
     61: mov     r9,[rbp+28h]
     65: mov     [rbp-0A0h],r9
     6c: mov     [rbp-98h],rdi
     73: mov     [rbp-90h],r8
     7a: call    fn0
     7f: nop     [rcx-19h]
     86: movzx   eax,byte ptr [rbp-19h]
     8a: xor     al,1
     8d: mov     [rbp-33h],al
     90: test    byte ptr [rbp-33h],0FFh
     94: je      0A7h
     96: mov     rsi,[rbp+10h]
     9a: mov     rsi,[rsi]
     9d: mov     [rbp-40h],rsi
     a1: mov     [rbp-28h],rsi
     a5: jmp     0AFh
     a7: mov     rax,[rbp+18h]
     ab: mov     [rbp-28h],rax
     af: mov     rax,[rbp+10h]
     b3: mov     rax,[rax+10h]
     b7: mov     [rbp-40h],rax
     bb: mov     byte ptr [rbp-59h],1
     bf: test    byte ptr [rbp-59h],0FFh
     c3: je      12Bh
     c5: jmp     0D2h
     c7: xor     edi,edi
     c9: xor     esi,esi
     cb: call    ryo_h_Ret
     d0: leave
     d1: ret
     d2: mov     rax,[rbp-28h]
     d6: mov     [rbp-48h],rax
     da: mov     rdx,[rbp-40h]
     de: mov     [rbp-50h],rdx
     e2: mov     [rbp-0A0h],rax
     e9: mov     [rbp-98h],rdx
     f0: mov     qword ptr [rbp-90h],8
     fb: mov     qword ptr [rbp-88h],4
    106: mov     qword ptr [rbp-80h],1
    10e: mov     edi,0FFFFFF88h
    113: lea     rsi,[k1]
    11a: call    ryo_h_AddrAbs
    11f: call    fn2
    124: nop     [rcx-30h]
    12b: mov     qword ptr [rbp-60h],1
    133: imul    rdx,[rbp-60h],8
    138: mov     [rbp-68h],rdx
    13c: mov     edi,0FFFFFFC0h
    141: mov     esi,0FFFFFFD8h
    146: mov     edx,0FFFFFF98h
    14b: call    ryo_h_Memcpy
    150: mov     rax,[rbp+10h]
    154: mov     rax,[rax]
    157: mov     [rbp-48h],rax
    15b: mov     edi,0FFFFFFB0h
    160: mov     esi,0FFFFFFCDh
    165: call    ryo_h_ZextW8W64
    16a: mov     rax,[rbp-48h]
    16e: imul    rcx,[rbp-50h],8
    173: add     rax,rcx
    176: mov     [rbp-40h],rax
    17a: mov     rdx,[rbp+10h]
    17e: mov     rcx,[rbp-40h]
    182: mov     [rdx],rcx
    185: mov     edi,0FFFFFFB8h
    18a: mov     esi,0FFFFFFE7h
    18f: call    ryo_h_ZextW8W64
    194: mov     rax,[rbp+18h]
    198: imul    rcx,[rbp-48h],8
    19d: add     rax,rcx
    1a0: mov     [rbp-40h],rax
    1a4: mov     [rbp+18h],rax
    1a8: mov     rdx,[rbp+10h]
    1ac: mov     rdx,[rdx+10h]
    1b0: mov     [rbp-48h],rdx
    1b4: mov     qword ptr [rbp-60h],1
    1bc: imul    rcx,[rbp-60h],8
    1c1: add     rdx,rcx
    1c4: mov     [rbp-40h],rdx
    1c8: mov     rdi,[rbp+10h]
    1cc: mov     rcx,[rbp-40h]
    1d0: mov     [rdi+10h],rcx
    1d4: jmp     10h

fn core::slice::sort::stable::merge::merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-48h],rax
     13: cmp     qword ptr [rbp+30h],0
     18: je      60h
     1a: mov     rsi,[rbp+30h]
     1e: cmp     rsi,rax
     21: jae     60h
     23: mov     rdi,[rbp+28h]
     27: mov     [rbp-58h],rdi
     2b: sub     rax,rsi
     2e: mov     [rbp-8],rax
     32: mov     [rbp-0D0h],rsi
     39: mov     [rbp-0C8h],rax
     40: call    fn0
     45: nop     [rcx-60h]
     4c: jmp     22Ah
     51: nop     [rax+rax]
     5a: nop     [rax+rax]
     60: jmp     1E6h
     65: nop     [rax+rax]
     6e: xchg    ax,ax
     70: mov     rax,[rbp+20h]
     74: mov     [rbp-28h],rax
     78: mov     rdx,[rbp+28h]
     7c: mov     [rbp-20h],rdx
     80: mov     [rbp-58h],rax
     84: mov     rsi,[rbp-28h]
     88: mov     [rbp-50h],rsi
     8c: mov     rdi,[rbp+10h]
     90: mov     [rbp-38h],rdi
     94: mov     r8,[rbp+18h]
     98: mov     [rbp-30h],r8
     9c: mov     [rbp-10h],rdi
     a0: imul    rcx,[rbp+30h],8
     a5: add     rdi,rcx
     a8: mov     [rbp-58h],rdi
     ac: mov     r9,[rbp-10h]
     b0: imul    rcx,[rbp-48h],8
     b5: add     r9,rcx
     b8: mov     [rbp-60h],r9
     bc: mov     r10,[rbp+30h]
     c0: cmp     r10,[rbp-8]
     c4: setbe   [rbp-61h]
     c8: test    byte ptr [rbp-61h],0FFh
     cc: je      0D0h
     ce: jmp     0D8h
     d0: mov     rax,[rbp-58h]
     d4: mov     [rbp-10h],rax
     d8: test    byte ptr [rbp-61h],0FFh
     dc: je      0E0h
     de: jmp     0E8h
     e0: mov     rax,[rbp-8]
     e4: mov     [rbp+30h],rax
     e8: mov     rax,[rbp-10h]
     ec: mov     [rbp-18h],rax
     f0: mov     [rbp-70h],rax
     f4: mov     rdx,[rbp+30h]
     f8: mov     [rbp-78h],rdx
     fc: mov     byte ptr [rbp-99h],1
    103: test    byte ptr [rbp-99h],0FFh
    10a: je      29Ch
    110: jmp     23Dh
    115: nop     [rax+rax]
    11e: xchg    ax,ax
    120: lea     rax,[rbp-80h]
    124: mov     [rbp-88h],rax
    12b: mov     rdx,[rbp-58h]
    12f: mov     [rbp-90h],rdx
    136: mov     rsi,[rbp-60h]
    13a: mov     [rbp-98h],rsi
    141: mov     [rbp-0D0h],rax
    148: mov     [rbp-0C8h],rdx
    14f: mov     [rbp-0C0h],rsi
    156: mov     rdi,[rbp+38h]
    15a: mov     [rbp-0B8h],rdi
    161: call    fn1
    166: nop     [rcx-18h]
    16d: jmp     1C8h
    16f: nop
    170: lea     rax,[rbp-80h]
    174: mov     [rbp-88h],rax
    17b: mov     rdx,[rbp-38h]
    17f: mov     [rbp-90h],rdx
    186: mov     rsi,[rbp-28h]
    18a: mov     [rbp-98h],rsi
    191: mov     [rbp-0D0h],rax
    198: mov     [rbp-0C8h],rdx
    19f: mov     [rbp-0C0h],rsi
    1a6: mov     rdi,[rbp-60h]
    1aa: mov     [rbp-0B8h],rdi
    1b1: mov     r8,[rbp+38h]
    1b5: mov     [rbp-0B0h],r8
    1bc: call    fn2
    1c1: nop     [rcx-18h]
    1c8: lea     rax,[rbp-80h]
    1cc: mov     [rbp-0A0h],rax
    1d3: mov     [rbp-0D0h],rax
    1da: call    fn3
    1df: nop     [rcx-0A0h]
    1e6: xor     edi,edi
    1e8: xor     esi,esi
    1ea: call    ryo_h_Ret
    1ef: leave
    1f0: ret
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: lea     rax,[rbp-80h]
    204: mov     [rbp-0A0h],rax
    20b: mov     [rbp-0D0h],rax
    212: call    fn4
    217: nop     [rcx-0A0h]
    21e: mov     edi,0FFFFFFC0h
    223: call    ryo_h_Resume
    228: ud2
    22a: mov     rax,[rbp-58h]
    22e: cmp     rax,[rbp-60h]
    232: jb      60h
    238: jmp     70h
    23d: mov     rax,[rbp-18h]
    241: mov     [rbp-80h],rax
    245: mov     rdx,[rbp-28h]
    249: mov     [rbp-88h],rdx
    250: mov     [rbp-0D0h],rax
    257: mov     [rbp-0C8h],rdx
    25e: mov     qword ptr [rbp-0C0h],8
    269: mov     qword ptr [rbp-0B8h],4
    274: mov     r8,[rbp-78h]
    278: mov     [rbp-0B0h],r8
    27f: mov     edi,0FFFFFF58h
    284: lea     rsi,[k5]
    28b: call    ryo_h_AddrAbs
    290: call    fn6
    295: nop     [rcx-38h]
    29c: imul    rax,[rbp-78h],8
    2a1: mov     [rbp-0A0h],rax
    2a8: mov     edi,0FFFFFFB0h
    2ad: mov     esi,0FFFFFF90h
    2b2: mov     edx,0FFFFFF60h
    2b7: call    ryo_h_Memcpy
    2bc: mov     rax,[rbp-50h]
    2c0: imul    rcx,[rbp+30h],8
    2c5: add     rax,rcx
    2c8: mov     [rbp-88h],rax
    2cf: mov     rdx,[rbp-50h]
    2d3: mov     [rbp-80h],rdx
    2d7: mov     [rbp-78h],rax
    2db: mov     rsi,[rbp-10h]
    2df: mov     [rbp-70h],rsi
    2e3: test    byte ptr [rbp-61h],0FFh
    2e7: je      170h
    2ed: jmp     120h
    2f2: nop     [rax+rax]
    2fb: nop     [rax+rax]
    300: lea     rdi,[sym7]
    307: lea     rsi,[site8]
    30e: mov     edx,0FFFFFF60h
    313: call    ryo_h_CallExt
    318: test    rax,rax
    31b: je      328h
    31d: call    rax
    31f: nop     [rcx-98h]
    326: jmp     338h
    328: mov     rdi,rbp
    32b: lea     rsi,[ro+4]
    332: call    qword ptr [sym9]
    338: call    ryo_h_Unreachable
    33d: ud2
    33f: mov     rdi,rax
    342: mov     esi,0FFFFFFC0h
    347: call    ryo_h_Lpad
    34c: jmp     200h
    351: mov     rdi,rax
    354: mov     esi,0FFFFFFC0h
    359: call    ryo_h_Lpad
    35e: jmp     300h

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
     58: mov     rdx,[rbp-10h]
     5c: imul    rcx,rax,8
     60: add     rdx,rcx
     63: mov     [rbp-8],rdx
     67: mov     rsi,[rbp+10h]
     6b: mov     rsi,[rsi+8]
     6f: mov     [rbp-18h],rsi
     73: mov     byte ptr [rbp-29h],1
     77: test    byte ptr [rbp-29h],0FFh
     7b: je      115h
     81: jmp     0C8h
     83: nop     [rax+rax]
     8c: nop     [rax]
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
     b6: mov     rdx,[rbp-20h]
     ba: imul    rcx,[rbp-30h],8
     bf: add     rdx,rcx
     c2: mov     [rbp-18h],rdx
     c6: jmp     90h
     c8: mov     rax,[rbp-18h]
     cc: mov     [rbp-20h],rax
     d0: mov     rdx,[rbp-8]
     d4: mov     [rbp-28h],rdx
     d8: mov     [rbp-70h],rax
     dc: mov     [rbp-68h],rdx
     e0: mov     qword ptr [rbp-60h],8
     e8: mov     qword ptr [rbp-58h],4
     f0: mov     qword ptr [rbp-50h],1
     f8: mov     edi,0FFFFFFB8h
     fd: lea     rsi,[k0]
    104: call    ryo_h_AddrAbs
    109: call    fn1
    10e: nop     [rcx-10h]
    115: mov     qword ptr [rbp-30h],1
    11d: imul    rdx,[rbp-30h],8
    122: mov     [rbp-38h],rdx
    126: mov     edi,0FFFFFFF8h
    12b: mov     esi,0FFFFFFE8h
    130: mov     edx,0FFFFFFC8h
    135: call    ryo_h_Memcpy
    13a: mov     edi,0FFFFFFE8h
    13f: mov     esi,18h
    144: call    ryo_h_ZextW8W64
    149: mov     rax,[rbp+10h]
    14d: mov     rax,[rax+10h]
    151: mov     [rbp-30h],rax
    155: add     rax,[rbp-18h]
    159: mov     [rbp-40h],rax
    15d: mov     rdx,[rbp+10h]
    161: mov     rcx,[rbp-40h]
    165: mov     [rdx+10h],rcx
    169: mov     rsi,[rbp+10h]
    16d: mov     rsi,[rsi+8]
    171: mov     [rbp-20h],rsi
    175: mov     qword ptr [rbp-30h],1
    17d: imul    rcx,[rbp-30h],8
    182: add     rsi,rcx
    185: mov     [rbp-18h],rsi
    189: mov     r8,[rbp+10h]
    18d: mov     rcx,[rbp-18h]
    191: mov     [r8+8],rcx
    195: mov     edi,0FFFFFFF8h
    19a: mov     esi,8
    19f: call    ryo_h_Ret
    1a4: leave
    1a5: ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-88h],rax
     1b: mov     rdx,[rbp+18h]
     1f: mov     [rbp-80h],rdx
     23: mov     [rbp-78h],rdx
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
     72: jmp     46Bh
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
     a7: mov     rdx,[rbp+40h]
     ab: mov     [rbp-0E8h],rdx
     b2: call    fn2
     b7: nop     [rcx]
     be: jmp     107h
     c0: mov     eax,[rbp+38h]
     c3: sub     eax,1
     c6: mov     [rbp+38h],eax
     c9: mov     rdx,[rbp+10h]
     cd: mov     [rbp-90h],rdx
     d4: mov     rsi,[rbp+18h]
     d8: mov     [rbp-88h],rsi
     df: mov     edi,0FFFFFEF0h
     e4: mov     esi,0FFFFFF70h
     e9: call    ryo_h_MovW128
     ee: mov     rax,[rbp+40h]
     f2: mov     [rbp-100h],rax
     f9: call    fn3
     fe: nop     [rcx-80h]
    105: jmp     10Ch
    107: jmp     46Bh
    10c: mov     rax,[rbp+10h]
    110: mov     [rbp-10h],rax
    114: mov     rdx,[rbp+18h]
    118: mov     [rbp-8],rdx
    11c: mov     [rbp-18h],rdx
    120: mov     rsi,[rbp-80h]
    124: cmp     rsi,rdx
    127: jb      187h
    129: mov     [rbp-110h],rsi
    130: mov     [rbp-108h],rdx
    137: mov     edi,0FFFFFF00h
    13c: lea     rsi,[k4]
    143: call    ryo_h_AddrAbs
    148: lea     rdi,[sym5]
    14f: lea     rsi,[site6]
    156: mov     edx,0FFFFFF28h
    15b: call    ryo_h_CallExt
    160: test    rax,rax
    163: je      170h
    165: call    rax
    167: nop     [rcx-0D0h]
    16e: jmp     180h
    170: mov     rdi,rbp
    173: lea     rsi,[ro+4]
    17a: call    qword ptr [sym7]
    180: call    ryo_h_Unreachable
    185: ud2
    187: mov     rax,[rbp+10h]
    18b: imul    rcx,[rbp-80h],8
    190: add     rax,rcx
    193: mov     [rbp-0D8h],rax
    19a: mov     [rbp-98h],rax
    1a1: mov     [rbp-90h],rax
    1a8: mov     rax,[rax]
    1ab: mov     [rbp-88h],rax
    1b2: call    fn8
    1b7: nop     [rcx-69h]
    1be: jmp     476h
    1c3: mov     rax,[rbp+30h]
    1c7: mov     [rbp-90h],rax
    1ce: mov     rdx,[rbp+10h]
    1d2: mov     [rbp-50h],rdx
    1d6: mov     rsi,[rbp+18h]
    1da: mov     [rbp-48h],rsi
    1de: mov     [rbp-58h],rsi
    1e2: mov     rdi,[rbp-80h]
    1e6: cmp     rdi,rsi
    1e9: jb      249h
    1eb: mov     [rbp-110h],rdi
    1f2: mov     [rbp-108h],rsi
    1f9: mov     edi,0FFFFFF00h
    1fe: lea     rsi,[k9]
    205: call    ryo_h_AddrAbs
    20a: lea     rdi,[sym10]
    211: lea     rsi,[site11]
    218: mov     edx,0FFFFFF28h
    21d: call    ryo_h_CallExt
    222: test    rax,rax
    225: je      232h
    227: call    rax
    229: nop     [rcx-0D0h]
    230: jmp     242h
    232: mov     rdi,rbp
    235: lea     rsi,[ro+4]
    23c: call    qword ptr [sym12]
    242: call    ryo_h_Unreachable
    247: ud2
    249: mov     rax,[rbp+10h]
    24d: imul    rcx,[rbp-80h],8
    252: add     rax,rcx
    255: mov     [rbp-0D8h],rax
    25c: mov     [rbp-0A8h],rax
    263: mov     rdx,[rbp-90h]
    26a: mov     [rbp-0A0h],rdx
    271: mov     [rbp-98h],rax
    278: mov     rsi,[rbp+40h]
    27c: mov     [rbp-110h],rsi
    283: mov     [rbp-108h],rdx
    28a: mov     [rbp-100h],rax
    291: call    fn13
    296: nop     [rcx-6Ah]
    29d: movzx   eax,byte ptr [rbp-6Ah]
    2a1: xor     al,1
    2a4: mov     [rbp-31h],al
    2a7: mov     qword ptr [rbp-68h],0
    2af: movzx   esi,byte ptr [rbp-31h]
    2b3: mov     [rbp-6Ah],sil
    2b7: test    byte ptr [rbp-6Ah],0FFh
    2bb: jne     329h
    2bd: nop     [rax]
    2c0: mov     edi,0FFFFFF68h
    2c5: mov     esi,10h
    2ca: call    ryo_h_MovW128
    2cf: mov     edi,0FFFFFEF0h
    2d4: mov     esi,0FFFFFF68h
    2d9: call    ryo_h_MovW128
    2de: mov     edi,0FFFFFF00h
    2e3: mov     esi,20h
    2e8: call    ryo_h_MovW128
    2ed: mov     rax,[rbp-80h]
    2f1: mov     [rbp-0F0h],rax
    2f8: mov     byte ptr [rbp-0E8h],0
    2ff: mov     rsi,[rbp+40h]
    303: mov     [rbp-0E0h],rsi
    30a: call    fn14
    30f: nop     [rcx-68h]
    316: mov     rax,[rbp-68h]
    31a: mov     [rbp-90h],rax
    321: cmp     rax,0
    325: sete    [rbp-31h]
    329: test    byte ptr [rbp-31h],0FFh
    32d: je      3C2h
    333: mov     edi,0FFFFFF60h
    338: mov     esi,10h
    33d: call    ryo_h_MovW128
    342: mov     rax,[rbp+40h]
    346: mov     [rbp-0B0h],rax
    34d: lea     rdx,[rbp-0B0h]
    354: mov     [rbp-0A8h],rdx
    35b: mov     edi,0FFFFFEF0h
    360: mov     esi,0FFFFFF60h
    365: call    ryo_h_MovW128
    36a: mov     edi,0FFFFFF00h
    36f: mov     esi,20h
    374: call    ryo_h_MovW128
    379: mov     rax,[rbp-80h]
    37d: mov     [rbp-0F0h],rax
    384: mov     byte ptr [rbp-0E8h],1
    38b: mov     rsi,[rbp-0A8h]
    392: mov     [rbp-0E0h],rsi
    399: call    fn15
    39e: nop     [rcx-90h]
    3a5: mov     rax,[rbp+18h]
    3a9: mov     [rbp-98h],rax
    3b0: cmp     rax,[rbp-90h]
    3b7: jb      513h
    3bd: jmp     58Dh
    3c2: mov     edi,0FFFFFEF0h
    3c7: mov     esi,10h
    3cc: call    ryo_h_MovW128
    3d1: mov     rax,[rbp-68h]
    3d5: mov     [rbp-100h],rax
    3dc: mov     edi,0FFFFFF08h
    3e1: lea     rsi,[k16]
    3e8: call    ryo_h_AddrAbs
    3ed: call    fn17
    3f2: nop     [rcx-0B8h]
    3f9: mov     edi,10h
    3fe: mov     esi,0FFFFFF48h
    403: call    ryo_h_MovW128
    408: mov     edi,0FFFFFF68h
    40d: mov     esi,0FFFFFF58h
    412: call    ryo_h_MovW128
    417: mov     eax,[rbp+38h]
    41a: mov     [rbp-70h],eax
    41d: mov     edi,0FFFFFEF0h
    422: mov     esi,0FFFFFF68h
    427: call    ryo_h_MovW128
    42c: mov     edi,0FFFFFF00h
    431: mov     esi,20h
    436: call    ryo_h_MovW128
    43b: mov     eax,[rbp-70h]
    43e: mov     [rbp-0E8h],eax
    444: mov     rdx,[rbp-28h]
    448: mov     [rbp-0F0h],rdx
    44f: mov     rsi,[rbp+40h]
    453: mov     [rbp-0E0h],rsi
    45a: call    fn18
    45f: nop     [rcx-68h]
    466: jmp     10h
    46b: xor     edi,edi
    46d: xor     esi,esi
    46f: call    ryo_h_Ret
    474: leave
    475: ret
    476: lea     rax,[rbp-88h]
    47d: mov     [rbp-0A0h],rax
    484: mov     [rbp-98h],rax
    48b: mov     [rbp-90h],rax
    492: test    byte ptr [rbp-69h],0FFh
    496: je      509h
    498: jmp     4FCh
    49a: nop     [rax+rax]
    4a0: mov     byte ptr [rbp-31h],0
    4a4: mov     edi,0FFFFFF2Ch
    4a9: mov     esi,30h
    4ae: xor     edx,edx
    4b0: xor     ecx,ecx
    4b2: xor     r8d,r8d
    4b5: mov     r9d,1
    4bb: call    ryo_h_DiscrNicheW64
    4c0: mov     edi,0FFFFFFC0h
    4c5: mov     esi,0FFFFFF2Ch
    4ca: call    ryo_h_ZextW32W64
    4cf: mov     edi,0FFFFFFC0h
    4d4: xor     esi,esi
    4d6: mov     edx,2
    4db: call    ryo_h_SwitchDenseW64
    4e0: lea     rcx,[4F0h]
    4e7: movsxd  rax,[rcx+rax*4]
    4eb: add     rax,rcx
    4ee: jmp     rax
    4f0: .long   5fbh
    4f4: .long   1c3h
    4f8: .long   5f4h
    4fc: mov     rax,[rbp-90h]
    503: mov     [rbp-28h],rax
    507: jmp     4A0h
    509: mov     qword ptr [rbp-28h],0
    511: jmp     4A0h
    513: mov     rax,[rbp-90h]
    51a: mov     [rbp-110h],rax
    521: mov     rdx,[rbp-98h]
    528: mov     [rbp-108h],rdx
    52f: mov     rsi,[rbp-98h]
    536: mov     [rbp-100h],rsi
    53d: mov     edi,0FFFFFF08h
    542: lea     rsi,[k19]
    549: call    ryo_h_AddrAbs
    54e: lea     rdi,[sym20]
    555: lea     rsi,[site21]
    55c: mov     edx,0FFFFFF28h
    561: call    ryo_h_CallExt
    566: test    rax,rax
    569: je      576h
    56b: call    rax
    56d: nop     [rcx-69h]
    574: jmp     586h
    576: mov     rdi,rbp
    579: lea     rsi,[ro+20]
    580: call    qword ptr [sym22]
    586: call    ryo_h_Unreachable
    58b: ud2
    58d: mov     rax,[rbp-98h]
    594: sub     rax,[rbp-90h]
    59b: mov     [rbp-0A0h],rax
    5a2: mov     rdx,[rbp+10h]
    5a6: mov     [rbp-0C0h],rdx
    5ad: mov     rsi,[rbp+18h]
    5b1: mov     [rbp-0B8h],rsi
    5b8: mov     [rbp-0C8h],rdx
    5bf: imul    rcx,[rbp-90h],8
    5c7: add     rdx,rcx
    5ca: mov     [rbp-0D0h],rdx
    5d1: mov     [rbp-0B0h],rdx
    5d8: mov     [rbp-0A8h],rax
    5df: mov     [rbp+10h],rdx
    5e3: mov     [rbp+18h],rax
    5e7: mov     qword ptr [rbp+30h],0
    5ef: jmp     10h
    5f4: call    ryo_h_Unreachable
    5f9: ud2
    5fb: mov     qword ptr [rbp-68h],0
    603: jmp     2C0h

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+20h]
     17: mov     [rbp-28h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-20h],rsi
     23: mov     [rbp-40h],rax
     27: mov     [rbp-38h],rdx
     2b: mov     [rbp-30h],rsi
     2f: call    fn0
     34: nop     [rcx-11h]
     3b: movzx   eax,byte ptr [rbp-11h]
     3f: xor     al,1
     42: mov     [rbp-1],al
     45: mov     edi,0FFFFFFFFh
     4a: mov     esi,1
     4f: call    ryo_h_Ret
     54: leave
     55: ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,150h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: mov     rdx,[rbp+28h]
     1a: mov     [rbp-0A0h],rdx
     21: cmp     rdx,rax
     24: jae     32h
     26: mov     byte ptr [rbp-91h],1
     2d: jmp     4C2h
     32: mov     rax,[rbp-90h]
     39: cmp     rax,[rbp+30h]
     3d: setbe   [rbp-91h]
     44: test    byte ptr [rbp-91h],0FFh
     4b: je      4C9h
     51: jmp     4C2h
     56: nop     [rax+rax]
     5f: nop
     60: mov     byte ptr [rbp-109h],1
     67: test    byte ptr [rbp-109h],0FFh
     6e: je      2F0h
     74: mov     rsi,[rbp+30h]
     78: mov     [rbp-0E0h],rsi
     7f: mov     [rbp-150h],rsi
     86: mov     qword ptr [rbp-148h],3
     91: mov     rdi,rbp
     94: lea     rsi,[ro+4]
     9b: call    qword ptr [sym0]
     a1: jmp     564h
     a6: nop     [rax+rax]
     af: nop
     b0: mov     rax,[rbp-0C0h]
     b7: mov     [rbp-0E0h],rax
     be: cmp     rax,[rbp-0D0h]
     c5: jae     2F0h
     cb: lea     rdx,[rbp-0C8h]
     d2: mov     [rbp-0E8h],rdx
     d9: mov     rsi,[rbp-0C0h]
     e0: mov     [rbp-38h],rsi
     e4: mov     [rbp-100h],rsi
     eb: mov     rdi,[rbp-0A8h]
     f2: mov     [rbp-108h],rdi
     f9: mov     [rbp-0F8h],rsi
    100: mov     [rbp-0F0h],rdi
    107: mov     r8,[rbp+40h]
    10b: mov     [rbp-150h],r8
    112: mov     [rbp-148h],rsi
    119: mov     [rbp-140h],rdi
    120: call    fn1
    125: nop     [rcx-0D2h]
    12c: mov     rax,[rbp-0E8h]
    133: mov     [rbp-150h],rax
    13a: movzx   edx,byte ptr [rbp-0D2h]
    141: mov     [rbp-148h],dl
    147: call    fn2
    14c: nop     [rcx-0E0h]
    153: lea     rax,[rbp-0C8h]
    15a: mov     [rbp-0E8h],rax
    161: mov     rdx,[rbp-0C0h]
    168: mov     [rbp-40h],rdx
    16c: mov     [rbp-100h],rdx
    173: mov     rsi,[rbp-0A8h]
    17a: mov     [rbp-108h],rsi
    181: mov     [rbp-0F8h],rdx
    188: mov     [rbp-0F0h],rsi
    18f: mov     rdi,[rbp+40h]
    193: mov     [rbp-150h],rdi
    19a: mov     [rbp-148h],rdx
    1a1: mov     [rbp-140h],rsi
    1a8: call    fn3
    1ad: nop     [rcx-0D2h]
    1b4: mov     rax,[rbp-0E8h]
    1bb: mov     [rbp-150h],rax
    1c2: movzx   edx,byte ptr [rbp-0D2h]
    1c9: mov     [rbp-148h],dl
    1cf: call    fn4
    1d4: nop     [rcx-0E0h]
    1db: lea     rax,[rbp-0C8h]
    1e2: mov     [rbp-0E8h],rax
    1e9: mov     rdx,[rbp-0C0h]
    1f0: mov     [rbp-48h],rdx
    1f4: mov     [rbp-100h],rdx
    1fb: mov     rsi,[rbp-0A8h]
    202: mov     [rbp-108h],rsi
    209: mov     [rbp-0F8h],rdx
    210: mov     [rbp-0F0h],rsi
    217: mov     rdi,[rbp+40h]
    21b: mov     [rbp-150h],rdi
    222: mov     [rbp-148h],rdx
    229: mov     [rbp-140h],rsi
    230: call    fn5
    235: nop     [rcx-0D2h]
    23c: mov     rax,[rbp-0E8h]
    243: mov     [rbp-150h],rax
    24a: movzx   edx,byte ptr [rbp-0D2h]
    251: mov     [rbp-148h],dl
    257: call    fn6
    25c: nop     [rcx-0E0h]
    263: lea     rax,[rbp-0C8h]
    26a: mov     [rbp-0E8h],rax
    271: mov     rdx,[rbp-0C0h]
    278: mov     [rbp-50h],rdx
    27c: mov     [rbp-100h],rdx
    283: mov     rsi,[rbp-0A8h]
    28a: mov     [rbp-108h],rsi
    291: mov     [rbp-0F8h],rdx
    298: mov     [rbp-0F0h],rsi
    29f: mov     rdi,[rbp+40h]
    2a3: mov     [rbp-150h],rdi
    2aa: mov     [rbp-148h],rdx
    2b1: mov     [rbp-140h],rsi
    2b8: call    fn7
    2bd: nop     [rcx-0D2h]
    2c4: mov     rax,[rbp-0E8h]
    2cb: mov     [rbp-150h],rax
    2d2: movzx   edx,byte ptr [rbp-0D2h]
    2d9: mov     [rbp-148h],dl
    2df: call    fn8
    2e4: nop     [rcx-0E0h]
    2eb: jmp     0B0h
    2f0: mov     rax,[rbp+30h]
    2f4: mov     [rbp-0D8h],rax
    2fb: mov     rdx,[rbp-98h]
    302: imul    rcx,rax,8
    306: add     rdx,rcx
    309: mov     [rbp-0D0h],rdx
    310: mov     rax,[rbp-0C0h]
    317: mov     [rbp-0E0h],rax
    31e: cmp     rax,[rbp-0D0h]
    325: jae     3B8h
    32b: lea     rdx,[rbp-0C8h]
    332: mov     [rbp-0E8h],rdx
    339: mov     rsi,[rbp-0C0h]
    340: mov     [rbp-58h],rsi
    344: mov     [rbp-100h],rsi
    34b: mov     rdi,[rbp-0A8h]
    352: mov     [rbp-108h],rdi
    359: mov     [rbp-0F8h],rsi
    360: mov     [rbp-0F0h],rdi
    367: mov     r8,[rbp+40h]
    36b: mov     [rbp-150h],r8
    372: mov     [rbp-148h],rsi
    379: mov     [rbp-140h],rdi
    380: call    fn9
    385: nop     [rcx-0D2h]
    38c: mov     rax,[rbp-0E8h]
    393: mov     [rbp-150h],rax
    39a: movzx   edx,byte ptr [rbp-0D2h]
    3a1: mov     [rbp-148h],dl
    3a7: call    fn10
    3ac: nop     [rcx-0E0h]
    3b3: jmp     310h
    3b8: mov     rax,[rbp+30h]
    3bc: cmp     rax,[rbp-90h]
    3c3: jne     3D6h
    3c5: call    fn11
    3ca: nop     [rcx-0CAh]
    3d1: jmp     582h
    3d6: lea     rax,[rbp-0C8h]
    3dd: mov     [rbp-0D8h],rax
    3e4: mov     [rbp-150h],rax
    3eb: movzx   edx,byte ptr [rbp+38h]
    3ef: mov     [rbp-148h],dl
    3f5: call    fn12
    3fa: nop     [rcx-10h]
    401: mov     rax,[rbp-90h]
    408: mov     [rbp+30h],rax
    40c: jmp     60h
    411: nop     [rax+rax]
    41a: nop     [rax+rax]
    420: mov     byte ptr [rbp-109h],1
    427: test    byte ptr [rbp-109h],0FFh
    42e: je      609h
    434: jmp     5A4h
    439: nop     [rax]
    440: mov     rax,[rbp+10h]
    444: mov     [rbp-78h],rax
    448: mov     rdx,[rbp+18h]
    44c: mov     [rbp-70h],rdx
    450: mov     [rbp-0D0h],rax
    457: mov     rsi,[rbp-68h]
    45b: mov     [rbp-0D8h],rsi
    462: mov     rdi,[rbp-0B8h]
    469: mov     [rbp-0E0h],rdi
    470: mov     byte ptr [rbp-109h],1
    477: test    byte ptr [rbp-109h],0FFh
    47e: je      6A1h
    484: jmp     63Ch
    489: nop     [rax]
    490: mov     rax,[rbp-20h]
    494: mov     [rbp-0F0h],rax
    49b: mov     rdx,[rbp-18h]
    49f: mov     [rbp-0F8h],rdx
    4a6: cmp     rax,rdx
    4a9: setb    [rbp-0E1h]
    4b0: test    byte ptr [rbp-0E1h],0FFh
    4b7: je      711h
    4bd: jmp     6F4h
    4c2: call    ryo_h_Abort
    4c7: ud2
    4c9: mov     rax,[rbp+10h]
    4cd: mov     [rbp-0A8h],rax
    4d4: mov     rdx,[rbp+18h]
    4d8: mov     [rbp-0A0h],rdx
    4df: mov     [rbp-98h],rax
    4e6: mov     rsi,[rbp+20h]
    4ea: mov     [rbp-68h],rsi
    4ee: mov     rdi,[rbp+28h]
    4f2: mov     [rbp-60h],rdi
    4f6: mov     [rbp-0A8h],rsi
    4fd: mov     r8,[rbp-68h]
    501: mov     [rbp-0A0h],r8
    508: imul    rcx,[rbp+30h],8
    50d: add     rax,rcx
    510: mov     [rbp-0A8h],rax
    517: imul    rcx,[rbp-90h],8
    51f: add     r8,rcx
    522: mov     [rbp-0D0h],r8
    529: mov     r9,[rbp-0A0h]
    530: mov     [rbp-0C8h],r9
    537: mov     r10,[rbp-98h]
    53e: mov     [rbp-0C0h],r10
    545: mov     qword ptr [rbp-0B8h],0
    550: mov     [rbp-0B0h],r8
    557: mov     qword ptr [rbp-10h],0
    55f: jmp     60h
    564: mov     rax,[rbp-98h]
    56b: imul    rcx,[rbp-0D8h],8
    573: add     rax,rcx
    576: mov     [rbp-0D0h],rax
    57d: jmp     0B0h
    582: movzx   eax,byte ptr [rbp-0CAh]
    589: xor     al,1
    58c: mov     [rbp-0C9h],al
    592: test    byte ptr [rbp-0C9h],0FFh
    599: je      440h
    59f: jmp     420h
    5a4: mov     rax,[rbp-0A8h]
    5ab: mov     [rbp-0D8h],rax
    5b2: mov     rdx,[rbp-10h]
    5b6: mov     [rbp-0E0h],rdx
    5bd: mov     [rbp-150h],rax
    5c4: mov     [rbp-148h],rdx
    5cb: mov     qword ptr [rbp-140h],8
    5d6: mov     qword ptr [rbp-138h],4
    5e1: mov     qword ptr [rbp-130h],1
    5ec: mov     edi,0FFFFFED8h
    5f1: lea     rsi,[k13]
    5f8: call    ryo_h_AddrAbs
    5fd: call    fn14
    602: nop     [rcx-68h]
    609: mov     qword ptr [rbp-110h],1
    614: imul    rdx,[rbp-110h],8
    61c: mov     [rbp-118h],rdx
    623: mov     edi,0FFFFFFF0h
    628: mov     esi,0FFFFFF58h
    62d: mov     edx,0FFFFFEE8h
    632: call    ryo_h_Memcpy
    637: jmp     440h
    63c: mov     rax,[rbp-68h]
    640: mov     [rbp-0E8h],rax
    647: mov     rdx,[rbp-78h]
    64b: mov     [rbp-0F0h],rdx
    652: mov     [rbp-150h],rax
    659: mov     [rbp-148h],rdx
    660: mov     qword ptr [rbp-140h],8
    66b: mov     qword ptr [rbp-138h],4
    676: mov     r8,[rbp-0E0h]
    67d: mov     [rbp-130h],r8
    684: mov     edi,0FFFFFED8h
    689: lea     rsi,[k15]
    690: call    ryo_h_AddrAbs
    695: call    fn16
    69a: nop     [rcx-78h]
    6a1: imul    rax,[rbp-0E0h],8
    6a9: mov     [rbp-110h],rax
    6b0: mov     edi,0FFFFFF30h
    6b5: mov     esi,0FFFFFF28h
    6ba: mov     edx,0FFFFFEF0h
    6bf: call    ryo_h_Memcpy
    6c4: mov     rax,[rbp-0B8h]
    6cb: mov     [rbp-0E0h],rax
    6d2: mov     rdx,[rbp-90h]
    6d9: sub     rdx,rax
    6dc: mov     [rbp-0D8h],rdx
    6e3: mov     qword ptr [rbp-20h],0
    6eb: mov     [rbp-18h],rdx
    6ef: jmp     490h
    6f4: mov     rax,[rbp-20h]
    6f8: mov     [rbp-0F0h],rax
    6ff: mov     byte ptr [rbp-109h],1
    706: test    byte ptr [rbp-109h],0FFh
    70d: je      763h
    70f: jmp     72Dh
    711: mov     rax,[rbp-0B8h]
    718: mov     [rbp-8],rax
    71c: mov     edi,0FFFFFFF8h
    721: mov     esi,8
    726: call    ryo_h_Ret
    72b: leave
    72c: ret
    72d: mov     rax,[rbp-0F0h]
    734: mov     [rbp-150h],rax
    73b: mov     qword ptr [rbp-148h],1
    746: mov     edi,0FFFFFEC0h
    74b: lea     rsi,[k17]
    752: call    ryo_h_AddrAbs
    757: call    fn18
    75c: nop     [rcx-88h]
    763: mov     rax,[rbp-0F0h]
    76a: add     rax,1
    76e: mov     [rbp-0F8h],rax
    775: mov     [rbp-20h],rax
    779: mov     rdx,[rbp-0F0h]
    780: mov     [rbp-0D8h],rdx
    787: mov     qword ptr [rbp-0E0h],1
    792: mov     [rbp-0E8h],rdx
    799: mov     rdi,[rbp-90h]
    7a0: sub     rdi,1
    7a4: mov     [rbp-100h],rdi
    7ab: sub     rdi,rdx
    7ae: mov     [rbp-0F8h],rdi
    7b5: mov     r8,[rbp-0A0h]
    7bc: imul    rcx,rdi,8
    7c0: add     r8,rcx
    7c3: mov     [rbp-30h],r8
    7c7: mov     [rbp-0F0h],r8
    7ce: mov     r9,[rbp-0B8h]
    7d5: mov     [rbp-108h],r9
    7dc: add     r9,rdx
    7df: mov     [rbp-100h],r9
    7e6: mov     r10,[rbp-0D0h]
    7ed: imul    rcx,r9,8
    7f1: add     r10,rcx
    7f4: mov     [rbp-0F8h],r10
    7fb: mov     byte ptr [rbp-109h],1
    802: test    byte ptr [rbp-109h],0FFh
    809: je      869h
    80b: mov     rdi,[rbp-30h]
    80f: mov     [rbp-100h],rdi
    816: mov     [rbp-108h],r10
    81d: mov     [rbp-150h],rdi
    824: mov     [rbp-148h],r10
    82b: mov     qword ptr [rbp-140h],8
    836: mov     qword ptr [rbp-138h],4
    841: mov     qword ptr [rbp-130h],1
    84c: mov     edi,0FFFFFED8h
    851: lea     rsi,[k19]
    858: call    ryo_h_AddrAbs
    85d: call    fn20
    862: nop     [rcx-88h]
    869: mov     qword ptr [rbp-110h],1
    874: imul    rdx,[rbp-110h],8
    87c: mov     [rbp-118h],rdx
    883: mov     edi,0FFFFFF08h
    888: mov     esi,0FFFFFF10h
    88d: mov     edx,0FFFFFEE8h
    892: call    ryo_h_Memcpy
    897: jmp     490h

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,150h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-90h],rax
     16: mov     rdx,[rbp+28h]
     1a: mov     [rbp-0A0h],rdx
     21: cmp     rdx,rax
     24: jae     32h
     26: mov     byte ptr [rbp-91h],1
     2d: jmp     4C2h
     32: mov     rax,[rbp-90h]
     39: cmp     rax,[rbp+30h]
     3d: setbe   [rbp-91h]
     44: test    byte ptr [rbp-91h],0FFh
     4b: je      4C9h
     51: jmp     4C2h
     56: nop     [rax+rax]
     5f: nop
     60: mov     byte ptr [rbp-109h],1
     67: test    byte ptr [rbp-109h],0FFh
     6e: je      2F0h
     74: mov     rsi,[rbp+30h]
     78: mov     [rbp-0E0h],rsi
     7f: mov     [rbp-150h],rsi
     86: mov     qword ptr [rbp-148h],3
     91: mov     rdi,rbp
     94: lea     rsi,[ro+4]
     9b: call    qword ptr [sym0]
     a1: jmp     564h
     a6: nop     [rax+rax]
     af: nop
     b0: mov     rax,[rbp-0C0h]
     b7: mov     [rbp-0E0h],rax
     be: cmp     rax,[rbp-0D0h]
     c5: jae     2F0h
     cb: lea     rdx,[rbp-0C8h]
     d2: mov     [rbp-0E8h],rdx
     d9: mov     rsi,[rbp-0C0h]
     e0: mov     [rbp-38h],rsi
     e4: mov     [rbp-100h],rsi
     eb: mov     rdi,[rbp-0A8h]
     f2: mov     [rbp-108h],rdi
     f9: mov     [rbp-0F8h],rsi
    100: mov     [rbp-0F0h],rdi
    107: mov     r8,[rbp+40h]
    10b: mov     [rbp-150h],r8
    112: mov     [rbp-148h],rsi
    119: mov     [rbp-140h],rdi
    120: call    fn1
    125: nop     [rcx-0D2h]
    12c: mov     rax,[rbp-0E8h]
    133: mov     [rbp-150h],rax
    13a: movzx   edx,byte ptr [rbp-0D2h]
    141: mov     [rbp-148h],dl
    147: call    fn2
    14c: nop     [rcx-0E0h]
    153: lea     rax,[rbp-0C8h]
    15a: mov     [rbp-0E8h],rax
    161: mov     rdx,[rbp-0C0h]
    168: mov     [rbp-40h],rdx
    16c: mov     [rbp-100h],rdx
    173: mov     rsi,[rbp-0A8h]
    17a: mov     [rbp-108h],rsi
    181: mov     [rbp-0F8h],rdx
    188: mov     [rbp-0F0h],rsi
    18f: mov     rdi,[rbp+40h]
    193: mov     [rbp-150h],rdi
    19a: mov     [rbp-148h],rdx
    1a1: mov     [rbp-140h],rsi
    1a8: call    fn3
    1ad: nop     [rcx-0D2h]
    1b4: mov     rax,[rbp-0E8h]
    1bb: mov     [rbp-150h],rax
    1c2: movzx   edx,byte ptr [rbp-0D2h]
    1c9: mov     [rbp-148h],dl
    1cf: call    fn4
    1d4: nop     [rcx-0E0h]
    1db: lea     rax,[rbp-0C8h]
    1e2: mov     [rbp-0E8h],rax
    1e9: mov     rdx,[rbp-0C0h]
    1f0: mov     [rbp-48h],rdx
    1f4: mov     [rbp-100h],rdx
    1fb: mov     rsi,[rbp-0A8h]
    202: mov     [rbp-108h],rsi
    209: mov     [rbp-0F8h],rdx
    210: mov     [rbp-0F0h],rsi
    217: mov     rdi,[rbp+40h]
    21b: mov     [rbp-150h],rdi
    222: mov     [rbp-148h],rdx
    229: mov     [rbp-140h],rsi
    230: call    fn5
    235: nop     [rcx-0D2h]
    23c: mov     rax,[rbp-0E8h]
    243: mov     [rbp-150h],rax
    24a: movzx   edx,byte ptr [rbp-0D2h]
    251: mov     [rbp-148h],dl
    257: call    fn6
    25c: nop     [rcx-0E0h]
    263: lea     rax,[rbp-0C8h]
    26a: mov     [rbp-0E8h],rax
    271: mov     rdx,[rbp-0C0h]
    278: mov     [rbp-50h],rdx
    27c: mov     [rbp-100h],rdx
    283: mov     rsi,[rbp-0A8h]
    28a: mov     [rbp-108h],rsi
    291: mov     [rbp-0F8h],rdx
    298: mov     [rbp-0F0h],rsi
    29f: mov     rdi,[rbp+40h]
    2a3: mov     [rbp-150h],rdi
    2aa: mov     [rbp-148h],rdx
    2b1: mov     [rbp-140h],rsi
    2b8: call    fn7
    2bd: nop     [rcx-0D2h]
    2c4: mov     rax,[rbp-0E8h]
    2cb: mov     [rbp-150h],rax
    2d2: movzx   edx,byte ptr [rbp-0D2h]
    2d9: mov     [rbp-148h],dl
    2df: call    fn8
    2e4: nop     [rcx-0E0h]
    2eb: jmp     0B0h
    2f0: mov     rax,[rbp+30h]
    2f4: mov     [rbp-0D8h],rax
    2fb: mov     rdx,[rbp-98h]
    302: imul    rcx,rax,8
    306: add     rdx,rcx
    309: mov     [rbp-0D0h],rdx
    310: mov     rax,[rbp-0C0h]
    317: mov     [rbp-0E0h],rax
    31e: cmp     rax,[rbp-0D0h]
    325: jae     3B8h
    32b: lea     rdx,[rbp-0C8h]
    332: mov     [rbp-0E8h],rdx
    339: mov     rsi,[rbp-0C0h]
    340: mov     [rbp-58h],rsi
    344: mov     [rbp-100h],rsi
    34b: mov     rdi,[rbp-0A8h]
    352: mov     [rbp-108h],rdi
    359: mov     [rbp-0F8h],rsi
    360: mov     [rbp-0F0h],rdi
    367: mov     r8,[rbp+40h]
    36b: mov     [rbp-150h],r8
    372: mov     [rbp-148h],rsi
    379: mov     [rbp-140h],rdi
    380: call    fn9
    385: nop     [rcx-0D2h]
    38c: mov     rax,[rbp-0E8h]
    393: mov     [rbp-150h],rax
    39a: movzx   edx,byte ptr [rbp-0D2h]
    3a1: mov     [rbp-148h],dl
    3a7: call    fn10
    3ac: nop     [rcx-0E0h]
    3b3: jmp     310h
    3b8: mov     rax,[rbp+30h]
    3bc: cmp     rax,[rbp-90h]
    3c3: jne     3D6h
    3c5: call    fn11
    3ca: nop     [rcx-0CAh]
    3d1: jmp     582h
    3d6: lea     rax,[rbp-0C8h]
    3dd: mov     [rbp-0D8h],rax
    3e4: mov     [rbp-150h],rax
    3eb: movzx   edx,byte ptr [rbp+38h]
    3ef: mov     [rbp-148h],dl
    3f5: call    fn12
    3fa: nop     [rcx-10h]
    401: mov     rax,[rbp-90h]
    408: mov     [rbp+30h],rax
    40c: jmp     60h
    411: nop     [rax+rax]
    41a: nop     [rax+rax]
    420: mov     byte ptr [rbp-109h],1
    427: test    byte ptr [rbp-109h],0FFh
    42e: je      609h
    434: jmp     5A4h
    439: nop     [rax]
    440: mov     rax,[rbp+10h]
    444: mov     [rbp-78h],rax
    448: mov     rdx,[rbp+18h]
    44c: mov     [rbp-70h],rdx
    450: mov     [rbp-0D0h],rax
    457: mov     rsi,[rbp-68h]
    45b: mov     [rbp-0D8h],rsi
    462: mov     rdi,[rbp-0B8h]
    469: mov     [rbp-0E0h],rdi
    470: mov     byte ptr [rbp-109h],1
    477: test    byte ptr [rbp-109h],0FFh
    47e: je      6A1h
    484: jmp     63Ch
    489: nop     [rax]
    490: mov     rax,[rbp-20h]
    494: mov     [rbp-0F0h],rax
    49b: mov     rdx,[rbp-18h]
    49f: mov     [rbp-0F8h],rdx
    4a6: cmp     rax,rdx
    4a9: setb    [rbp-0E1h]
    4b0: test    byte ptr [rbp-0E1h],0FFh
    4b7: je      711h
    4bd: jmp     6F4h
    4c2: call    ryo_h_Abort
    4c7: ud2
    4c9: mov     rax,[rbp+10h]
    4cd: mov     [rbp-0A8h],rax
    4d4: mov     rdx,[rbp+18h]
    4d8: mov     [rbp-0A0h],rdx
    4df: mov     [rbp-98h],rax
    4e6: mov     rsi,[rbp+20h]
    4ea: mov     [rbp-68h],rsi
    4ee: mov     rdi,[rbp+28h]
    4f2: mov     [rbp-60h],rdi
    4f6: mov     [rbp-0A8h],rsi
    4fd: mov     r8,[rbp-68h]
    501: mov     [rbp-0A0h],r8
    508: imul    rcx,[rbp+30h],8
    50d: add     rax,rcx
    510: mov     [rbp-0A8h],rax
    517: imul    rcx,[rbp-90h],8
    51f: add     r8,rcx
    522: mov     [rbp-0D0h],r8
    529: mov     r9,[rbp-0A0h]
    530: mov     [rbp-0C8h],r9
    537: mov     r10,[rbp-98h]
    53e: mov     [rbp-0C0h],r10
    545: mov     qword ptr [rbp-0B8h],0
    550: mov     [rbp-0B0h],r8
    557: mov     qword ptr [rbp-10h],0
    55f: jmp     60h
    564: mov     rax,[rbp-98h]
    56b: imul    rcx,[rbp-0D8h],8
    573: add     rax,rcx
    576: mov     [rbp-0D0h],rax
    57d: jmp     0B0h
    582: movzx   eax,byte ptr [rbp-0CAh]
    589: xor     al,1
    58c: mov     [rbp-0C9h],al
    592: test    byte ptr [rbp-0C9h],0FFh
    599: je      440h
    59f: jmp     420h
    5a4: mov     rax,[rbp-0A8h]
    5ab: mov     [rbp-0D8h],rax
    5b2: mov     rdx,[rbp-10h]
    5b6: mov     [rbp-0E0h],rdx
    5bd: mov     [rbp-150h],rax
    5c4: mov     [rbp-148h],rdx
    5cb: mov     qword ptr [rbp-140h],8
    5d6: mov     qword ptr [rbp-138h],4
    5e1: mov     qword ptr [rbp-130h],1
    5ec: mov     edi,0FFFFFED8h
    5f1: lea     rsi,[k13]
    5f8: call    ryo_h_AddrAbs
    5fd: call    fn14
    602: nop     [rcx-68h]
    609: mov     qword ptr [rbp-110h],1
    614: imul    rdx,[rbp-110h],8
    61c: mov     [rbp-118h],rdx
    623: mov     edi,0FFFFFFF0h
    628: mov     esi,0FFFFFF58h
    62d: mov     edx,0FFFFFEE8h
    632: call    ryo_h_Memcpy
    637: jmp     440h
    63c: mov     rax,[rbp-68h]
    640: mov     [rbp-0E8h],rax
    647: mov     rdx,[rbp-78h]
    64b: mov     [rbp-0F0h],rdx
    652: mov     [rbp-150h],rax
    659: mov     [rbp-148h],rdx
    660: mov     qword ptr [rbp-140h],8
    66b: mov     qword ptr [rbp-138h],4
    676: mov     r8,[rbp-0E0h]
    67d: mov     [rbp-130h],r8
    684: mov     edi,0FFFFFED8h
    689: lea     rsi,[k15]
    690: call    ryo_h_AddrAbs
    695: call    fn16
    69a: nop     [rcx-78h]
    6a1: imul    rax,[rbp-0E0h],8
    6a9: mov     [rbp-110h],rax
    6b0: mov     edi,0FFFFFF30h
    6b5: mov     esi,0FFFFFF28h
    6ba: mov     edx,0FFFFFEF0h
    6bf: call    ryo_h_Memcpy
    6c4: mov     rax,[rbp-0B8h]
    6cb: mov     [rbp-0E0h],rax
    6d2: mov     rdx,[rbp-90h]
    6d9: sub     rdx,rax
    6dc: mov     [rbp-0D8h],rdx
    6e3: mov     qword ptr [rbp-20h],0
    6eb: mov     [rbp-18h],rdx
    6ef: jmp     490h
    6f4: mov     rax,[rbp-20h]
    6f8: mov     [rbp-0F0h],rax
    6ff: mov     byte ptr [rbp-109h],1
    706: test    byte ptr [rbp-109h],0FFh
    70d: je      763h
    70f: jmp     72Dh
    711: mov     rax,[rbp-0B8h]
    718: mov     [rbp-8],rax
    71c: mov     edi,0FFFFFFF8h
    721: mov     esi,8
    726: call    ryo_h_Ret
    72b: leave
    72c: ret
    72d: mov     rax,[rbp-0F0h]
    734: mov     [rbp-150h],rax
    73b: mov     qword ptr [rbp-148h],1
    746: mov     edi,0FFFFFEC0h
    74b: lea     rsi,[k17]
    752: call    ryo_h_AddrAbs
    757: call    fn18
    75c: nop     [rcx-88h]
    763: mov     rax,[rbp-0F0h]
    76a: add     rax,1
    76e: mov     [rbp-0F8h],rax
    775: mov     [rbp-20h],rax
    779: mov     rdx,[rbp-0F0h]
    780: mov     [rbp-0D8h],rdx
    787: mov     qword ptr [rbp-0E0h],1
    792: mov     [rbp-0E8h],rdx
    799: mov     rdi,[rbp-90h]
    7a0: sub     rdi,1
    7a4: mov     [rbp-100h],rdi
    7ab: sub     rdi,rdx
    7ae: mov     [rbp-0F8h],rdi
    7b5: mov     r8,[rbp-0A0h]
    7bc: imul    rcx,rdi,8
    7c0: add     r8,rcx
    7c3: mov     [rbp-30h],r8
    7c7: mov     [rbp-0F0h],r8
    7ce: mov     r9,[rbp-0B8h]
    7d5: mov     [rbp-108h],r9
    7dc: add     r9,rdx
    7df: mov     [rbp-100h],r9
    7e6: mov     r10,[rbp-0D0h]
    7ed: imul    rcx,r9,8
    7f1: add     r10,rcx
    7f4: mov     [rbp-0F8h],r10
    7fb: mov     byte ptr [rbp-109h],1
    802: test    byte ptr [rbp-109h],0FFh
    809: je      869h
    80b: mov     rdi,[rbp-30h]
    80f: mov     [rbp-100h],rdi
    816: mov     [rbp-108h],r10
    81d: mov     [rbp-150h],rdi
    824: mov     [rbp-148h],r10
    82b: mov     qword ptr [rbp-140h],8
    836: mov     qword ptr [rbp-138h],4
    841: mov     qword ptr [rbp-130h],1
    84c: mov     edi,0FFFFFED8h
    851: lea     rsi,[k19]
    858: call    ryo_h_AddrAbs
    85d: call    fn20
    862: nop     [rcx-88h]
    869: mov     qword ptr [rbp-110h],1
    874: imul    rdx,[rbp-110h],8
    87c: mov     [rbp-118h],rdx
    883: mov     edi,0FFFFFF08h
    888: mov     esi,0FFFFFF10h
    88d: mov     edx,0FFFFFEE8h
    892: call    ryo_h_Memcpy
    897: jmp     490h

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
     68: mov     rdx,[rbp-8]
     6c: mov     [rbp-70h],rdx
     70: cmp     rax,rdx
     73: setb    [rbp-59h]
     77: test    byte ptr [rbp-59h],0FFh
     7b: je      18Fh
     81: jmp     175h
     86: nop     [rax+rax]
     8f: nop
     90: mov     rax,[rbp-60h]
     94: sub     rax,[rbp-48h]
     98: mov     [rbp-20h],rax
     9c: jmp     140h
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: mov     qword ptr [rbp-0A8h],0
     bb: mov     rdx,[rbp-0A8h]
     c2: cmp     rdx,[rbp-48h]
     c6: setb    [rbp-62h]
     ca: test    byte ptr [rbp-62h],0FFh
     ce: jne     20Dh
     d4: mov     qword ptr [rbp-0D0h],0
     df: mov     r8,[rbp-48h]
     e3: mov     [rbp-0C8h],r8
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
    14b: mov     rdx,[rbp-48h]
    14f: mov     [rbp-0C8h],rdx
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
    21e: mov     rdx,[rbp-48h]
    222: mov     [rbp-0C8h],rdx
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
    293: mov     rdx,[rbp-60h]
    297: mov     [rbp-0B8h],rdx
    29e: mov     edi,0FFFFFF50h
    2a3: lea     rsi,[k11]
    2aa: call    ryo_h_AddrAbs
    2af: call    fn12
    2b4: nop     [rcx-40h]
    2bb: jmp     200h
    2c0: cmp     qword ptr [rbp-28h],0
    2c5: jb      3B1h
    2cb: jmp     3B3h
    2d0: mov     rax,[rbp+10h]
    2d4: mov     [rbp-98h],rax
    2db: mov     rdx,[rbp+18h]
    2df: mov     [rbp-90h],rdx
    2e6: mov     [rbp-0A0h],rax
    2ed: mov     [rbp-88h],rax
    2f4: mov     rsi,[rbp-28h]
    2f8: mov     [rbp-80h],rsi
    2fc: mov     [rbp-70h],rax
    300: mov     [rbp-68h],rsi
    304: mov     edi,0FFFFFF30h
    309: mov     esi,0FFFFFF90h
    30e: call    ryo_h_MovW128
    313: mov     rax,[rbp-20h]
    317: mov     [rbp-0C0h],rax
    31e: mov     rdx,[rbp+20h]
    322: mov     [rbp-0B8h],rdx
    329: call    fn13
    32e: nop     [rcx-20h]
    335: jmp     170h
    33a: nop     [rax+rax]
    340: mov     qword ptr [rbp-0D0h],0
    34b: mov     rdx,[rbp-28h]
    34f: mov     [rbp-0C8h],rdx
    356: mov     rsi,[rbp-48h]
    35a: mov     [rbp-0C0h],rsi
    361: mov     edi,0FFFFFF48h
    366: lea     rsi,[k14]
    36d: call    ryo_h_AddrAbs
    372: lea     rdi,[sym15]
    379: lea     rsi,[site16]
    380: mov     edx,0FFFFFF58h
    385: call    ryo_h_CallExt
    38a: test    rax,rax
    38d: je      39Ah
    38f: call    rax
    391: nop     [rcx-40h]
    398: jmp     3AAh
    39a: mov     rdi,rbp
    39d: lea     rsi,[ro+20]
    3a4: call    qword ptr [sym17]
    3aa: call    ryo_h_Unreachable
    3af: ud2
    3b1: jmp     340h
    3b3: mov     rax,[rbp-48h]
    3b7: cmp     rax,[rbp-28h]
    3bb: jae     2D0h
    3c1: jmp     340h

fn core::slice::sort::unstable::heapsort::sift_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-20h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-8],rdx
     1b: cmp     rax,rdx
     1e: setbe   [rbp-11h]
     22: mov     rsi,[rbp+10h]
     26: mov     [rbp-28h],rsi
     2a: mov     rdi,[rbp+18h]
     2e: mov     [rbp-20h],rdi
     32: mov     [rbp-18h],rsi
     36: nop     [rax+rax]
     3f: nop
     40: mov     rax,[rbp+20h]
     44: mov     [rbp-28h],rax
     48: mov     qword ptr [rbp-70h],2
     50: mov     rsi,[rbp-70h]
     54: imul    rsi,rax
     58: mov     [rbp-20h],rsi
     5c: add     rsi,1
     60: mov     [rbp-10h],rsi
     64: mov     [rbp-28h],rsi
     68: cmp     rsi,[rbp-8]
     6c: jb      73h
     6e: jmp     1AFh
     73: mov     rax,[rbp-10h]
     77: mov     [rbp-30h],rax
     7b: add     rax,1
     7f: mov     [rbp-28h],rax
     83: cmp     rax,[rbp-8]
     87: jae     0F6h
     89: mov     rdx,[rbp-10h]
     8d: mov     [rbp-50h],rdx
     91: mov     rsi,[rbp-18h]
     95: imul    rcx,rdx,4
     99: add     rsi,rcx
     9c: mov     [rbp-48h],rsi
     a0: mov     [rbp-40h],rsi
     a4: mov     rdi,[rbp-10h]
     a8: mov     [rbp-68h],rdi
     ac: add     rdi,1
     b0: mov     [rbp-60h],rdi
     b4: mov     r8,[rbp-18h]
     b8: imul    rcx,rdi,4
     bc: add     r8,rcx
     bf: mov     [rbp-58h],r8
     c3: mov     [rbp-50h],r8
     c7: mov     [rbp-38h],rsi
     cb: mov     [rbp-30h],r8
     cf: mov     r9,[rbp+28h]
     d3: mov     [rbp-0A0h],r9
     da: mov     [rbp-98h],rsi
     e1: mov     [rbp-90h],r8
     e8: call    fn0
     ed: nop     [rcx-1Ah]
     f4: jmp     0F8h
     f6: jmp     113h
     f8: mov     edi,0FFFFFFD8h
     fd: mov     esi,0FFFFFFE6h
    102: call    ryo_h_ZextW8W64
    107: mov     rax,[rbp-10h]
    10b: add     rax,[rbp-28h]
    10f: mov     [rbp-10h],rax
    113: mov     rax,[rbp+20h]
    117: mov     [rbp-48h],rax
    11b: mov     rdx,[rbp-18h]
    11f: imul    rcx,rax,4
    123: add     rdx,rcx
    126: mov     [rbp-40h],rdx
    12a: mov     [rbp-38h],rdx
    12e: mov     rsi,[rbp-10h]
    132: mov     [rbp-58h],rsi
    136: mov     rdi,[rbp-18h]
    13a: imul    rcx,rsi,4
    13e: add     rdi,rcx
    141: mov     [rbp-50h],rdi
    145: mov     [rbp-48h],rdi
    149: mov     [rbp-30h],rdx
    14d: mov     [rbp-28h],rdi
    151: mov     r8,[rbp+28h]
    155: mov     [rbp-0A0h],r8
    15c: mov     [rbp-98h],rdx
    163: mov     [rbp-90h],rdi
    16a: call    fn1
    16f: nop     [rcx-19h]
    176: test    byte ptr [rbp-19h],0FFh
    17a: je      1AFh
    17c: mov     rdx,[rbp-18h]
    180: imul    rcx,[rbp+20h],4
    185: add     rdx,rcx
    188: mov     [rbp-20h],rdx
    18c: mov     rsi,[rbp-10h]
    190: mov     [rbp-30h],rsi
    194: mov     rdi,[rbp-18h]
    198: imul    rcx,rsi,4
    19c: add     rdi,rcx
    19f: mov     [rbp-28h],rdi
    1a3: mov     byte ptr [rbp-69h],1
    1a7: test    byte ptr [rbp-69h],0FFh
    1ab: je      213h
    1ad: jmp     1BAh
    1af: xor     edi,edi
    1b1: xor     esi,esi
    1b3: call    ryo_h_Ret
    1b8: leave
    1b9: ret
    1ba: mov     rax,[rbp-20h]
    1be: mov     [rbp-30h],rax
    1c2: mov     rdx,[rbp-28h]
    1c6: mov     [rbp-38h],rdx
    1ca: mov     [rbp-0A0h],rax
    1d1: mov     [rbp-98h],rdx
    1d8: mov     qword ptr [rbp-90h],4
    1e3: mov     qword ptr [rbp-88h],4
    1ee: mov     qword ptr [rbp-80h],1
    1f6: mov     edi,0FFFFFF88h
    1fb: lea     rsi,[k2]
    202: call    ryo_h_AddrAbs
    207: call    fn3
    20c: nop     [rcx-10h]
    213: mov     rax,[rbp-20h]
    217: mov     [rbp-38h],rax
    21b: mov     qword ptr [rbp-30h],1
    223: mov     edi,0FFFFFFB0h
    228: mov     esi,0FFFFFFC8h
    22d: call    ryo_h_MovW128
    232: imul    rax,[rbp-48h],4
    237: mov     [rbp-40h],rax
    23b: jmp     285h
    23d: mov     rax,[rbp-48h]
    241: mov     [rbp-50h],rax
    245: mov     rdx,[rbp-20h]
    249: mov     [rbp-60h],rdx
    24d: mov     rsi,[rbp-28h]
    251: mov     [rbp-68h],rsi
    255: mov     [rbp-0A0h],rdx
    25c: mov     [rbp-98h],rsi
    263: mov     [rbp-90h],rax
    26a: call    fn4
    26f: nop     [rcx-10h]
    276: jmp     278h
    278: mov     rax,[rbp-10h]
    27c: mov     [rbp+20h],rax
    280: jmp     40h
    285: mov     rax,[rbp-40h]
    289: mov     [rbp-48h],rax
    28d: mov     edi,0FFFFFF94h
    292: mov     esi,0FFFFFFB8h
    297: xor     edx,edx
    299: xor     ecx,ecx
    29b: xor     r8d,r8d
    29e: mov     r9d,1
    2a4: call    ryo_h_DiscrNicheW64
    2a9: mov     edi,0FFFFFFA8h
    2ae: mov     esi,0FFFFFF94h
    2b3: call    ryo_h_ZextW32W64
    2b8: mov     edi,0FFFFFFA8h
    2bd: xor     esi,esi
    2bf: mov     edx,2
    2c4: call    ryo_h_SwitchDenseW64
    2c9: lea     rcx,[2DCh]
    2d0: movsxd  rax,[rcx+rax*4]
    2d4: add     rax,rcx
    2d7: jmp     rax
    2d9: int3
    2da: int3
    2db: int3
    2dc: .long   278h
    2e0: .long   23dh
    2e4: .long   2e8h
    2e8: call    ryo_h_Unreachable
    2ed: ud2

fn core::slice::sort::unstable::ipnsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-38h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-30h],rsi
     23: mov     edi,0FFFFFF80h
     28: mov     esi,0FFFFFFC8h
     2d: call    ryo_h_MovW128
     32: mov     rax,[rbp+20h]
     36: mov     [rbp-70h],rax
     3a: call    fn0
     3f: nop     [rcx-28h]
     46: mov     rax,[rbp-28h]
     4a: mov     [rbp-18h],rax
     4e: movzx   edx,byte ptr [rbp-20h]
     52: mov     [rbp-5],dl
     55: cmp     rax,[rbp-10h]
     59: setbe   [rbp-6]
     5d: cmp     rax,[rbp-10h]
     61: jne     86h
     63: test    byte ptr [rbp-5],0FFh
     67: je      84h
     69: mov     edi,0FFFFFF80h
     6e: mov     esi,10h
     73: call    ryo_h_MovW128
     78: call    fn1
     7d: nop     [rcx]
     84: jmp     0F0h
     86: mov     rax,[rbp-10h]
     8a: or      rax,1
     8e: mov     [rbp-28h],rax
     92: mov     [rbp-30h],rax
     96: mov     edi,0FFFFFFB4h
     9b: mov     esi,0FFFFFFD0h
     a0: xor     edx,edx
     a2: xor     ecx,ecx
     a4: xor     r8d,r8d
     a7: mov     r9d,1
     ad: call    ryo_h_DiscrNicheW64
     b2: mov     edi,0FFFFFFC8h
     b7: mov     esi,0FFFFFFB4h
     bc: call    ryo_h_ZextW32W64
     c1: mov     edi,0FFFFFFC8h
     c6: xor     esi,esi
     c8: mov     edx,2
     cd: call    ryo_h_SwitchDenseW64
     d2: lea     rcx,[0E4h]
     d9: movsxd  rax,[rcx+rax*4]
     dd: add     rax,rcx
     e0: jmp     rax
     e2: int3
     e3: int3
     e4: .long   102h
     e8: .long   152h
     ec: .long   fbh
     f0: xor     edi,edi
     f2: xor     esi,esi
     f4: call    ryo_h_Ret
     f9: leave
     fa: ret
     fb: call    ryo_h_Unreachable
    100: ud2
    102: mov     edi,0FFFFFF80h
    107: lea     rsi,[k2]
    10e: call    ryo_h_AddrAbs
    113: lea     rdi,[sym3]
    11a: lea     rsi,[site4]
    121: mov     edx,0FFFFFFB0h
    126: call    ryo_h_CallExt
    12b: test    rax,rax
    12e: je      13Bh
    130: call    rax
    132: nop     [rcx]
    139: jmp     14Bh
    13b: mov     rdi,rbp
    13e: lea     rsi,[ro+4]
    145: call    qword ptr [sym5]
    14b: call    ryo_h_Unreachable
    150: ud2
    152: mov     rax,[rbp-30h]
    156: mov     [rbp-40h],rax
    15a: mov     [rbp-48h],rax
    15e: mov     edi,0FFFFFFB4h
    163: mov     esi,0FFFFFFB8h
    168: call    ryo_h_CtlzW64
    16d: mov     eax,[rbp-4Ch]
    170: mov     [rbp-20h],eax
    173: mov     dword ptr [rbp-4Ch],3Fh
    17a: mov     esi,[rbp-4Ch]
    17d: sub     esi,eax
    17f: mov     [rbp-4],esi
    182: mov     dword ptr [rbp-4Ch],2
    189: mov     r8d,[rbp-4Ch]
    18d: imul    r8d,esi
    191: mov     [rbp-1Ch],r8d
    195: mov     edi,0FFFFFF80h
    19a: mov     esi,10h
    19f: call    ryo_h_MovW128
    1a4: mov     qword ptr [rbp-70h],0
    1ac: mov     edx,[rbp-1Ch]
    1af: mov     [rbp-68h],edx
    1b2: mov     rsi,[rbp+20h]
    1b6: mov     [rbp-60h],rsi
    1ba: call    fn6
    1bf: nop     [rcx]
    1c6: jmp     0F0h

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,0
     17: jne     26h
     19: mov     qword ptr [rbp-8],0
     21: jmp     202h
     26: mov     rax,[rbp+20h]
     2a: cmp     rax,[rbp-20h]
     2e: jb      37h
     30: call    ryo_h_Abort
     35: ud2
     37: mov     edi,0FFFFFF70h
     3c: mov     esi,10h
     41: call    ryo_h_MovW128
     46: mov     qword ptr [rbp-80h],0
     4e: mov     rdx,[rbp+20h]
     52: mov     [rbp-78h],rdx
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
     d5: mov     rsi,[rbp-68h]
     d9: cmp     rsi,rax
     dc: setb    [rbp-11h]
     e0: test    byte ptr [rbp-11h],0FFh
     e4: jne     148h
     e6: mov     qword ptr [rbp-90h],0
     f1: mov     [rbp-88h],rax
     f8: mov     edi,0FFFFFF80h
     fd: lea     rsi,[k4]
    104: call    ryo_h_AddrAbs
    109: lea     rdi,[sym5]
    110: lea     rsi,[site6]
    117: mov     edx,0FFFFFF98h
    11c: call    ryo_h_CallExt
    121: test    rax,rax
    124: je      131h
    126: call    rax
    128: nop     [rcx-60h]
    12f: jmp     141h
    131: mov     rdi,rbp
    134: lea     rsi,[ro+4]
    13b: call    qword ptr [sym7]
    141: call    ryo_h_Unreachable
    146: ud2
    148: mov     rax,[rbp-30h]
    14c: mov     [rbp-48h],rax
    150: mov     [rbp-50h],rax
    154: mov     edi,0FFFFFF98h
    159: lea     rsi,[sym8]
    160: call    ryo_h_AddrSym
    165: mov     edi,0FFFFFF70h
    16a: mov     esi,0FFFFFFC0h
    16f: call    ryo_h_MovW128
    174: mov     rax,[rbp-50h]
    178: mov     [rbp-80h],rax
    17c: mov     rdx,[rbp+28h]
    180: mov     [rbp-78h],rdx
    184: mov     edi,0FFFFFF98h
    189: lea     rsi,[site9]
    190: call    ryo_h_CallInd
    195: test    rax,rax
    198: je      1A5h
    19a: call    rax
    19c: nop     [rcx-8]
    1a3: jmp     1B5h
    1a5: mov     rdi,rbp
    1a8: lea     rsi,[ro+20]
    1af: call    qword ptr [sym10]
    1b5: mov     rax,[rbp-8]
    1b9: cmp     rax,[rbp-20h]
    1bd: jb      1C6h
    1bf: call    ryo_h_Abort
    1c4: ud2
    1c6: mov     edi,0FFFFFF70h
    1cb: mov     esi,10h
    1d0: call    ryo_h_MovW128
    1d5: mov     qword ptr [rbp-80h],0
    1dd: mov     rdx,[rbp-8]
    1e1: mov     [rbp-78h],rdx
    1e5: mov     edi,0FFFFFF90h
    1ea: lea     rsi,[k11]
    1f1: call    ryo_h_AddrAbs
    1f6: call    fn12
    1fb: nop     [rcx-11h]
    202: mov     edi,0FFFFFFF8h
    207: mov     esi,8
    20c: call    ryo_h_Ret
    211: leave
    212: ret

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,0
     17: jne     26h
     19: mov     qword ptr [rbp-8],0
     21: jmp     202h
     26: mov     rax,[rbp+20h]
     2a: cmp     rax,[rbp-20h]
     2e: jb      37h
     30: call    ryo_h_Abort
     35: ud2
     37: mov     edi,0FFFFFF70h
     3c: mov     esi,10h
     41: call    ryo_h_MovW128
     46: mov     qword ptr [rbp-80h],0
     4e: mov     rdx,[rbp+20h]
     52: mov     [rbp-78h],rdx
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
     d5: mov     rsi,[rbp-68h]
     d9: cmp     rsi,rax
     dc: setb    [rbp-11h]
     e0: test    byte ptr [rbp-11h],0FFh
     e4: jne     148h
     e6: mov     qword ptr [rbp-90h],0
     f1: mov     [rbp-88h],rax
     f8: mov     edi,0FFFFFF80h
     fd: lea     rsi,[k4]
    104: call    ryo_h_AddrAbs
    109: lea     rdi,[sym5]
    110: lea     rsi,[site6]
    117: mov     edx,0FFFFFF98h
    11c: call    ryo_h_CallExt
    121: test    rax,rax
    124: je      131h
    126: call    rax
    128: nop     [rcx-60h]
    12f: jmp     141h
    131: mov     rdi,rbp
    134: lea     rsi,[ro+4]
    13b: call    qword ptr [sym7]
    141: call    ryo_h_Unreachable
    146: ud2
    148: mov     rax,[rbp-30h]
    14c: mov     [rbp-48h],rax
    150: mov     [rbp-50h],rax
    154: mov     edi,0FFFFFF98h
    159: lea     rsi,[sym8]
    160: call    ryo_h_AddrSym
    165: mov     edi,0FFFFFF70h
    16a: mov     esi,0FFFFFFC0h
    16f: call    ryo_h_MovW128
    174: mov     rax,[rbp-50h]
    178: mov     [rbp-80h],rax
    17c: mov     rdx,[rbp+28h]
    180: mov     [rbp-78h],rdx
    184: mov     edi,0FFFFFF98h
    189: lea     rsi,[site9]
    190: call    ryo_h_CallInd
    195: test    rax,rax
    198: je      1A5h
    19a: call    rax
    19c: nop     [rcx-8]
    1a3: jmp     1B5h
    1a5: mov     rdi,rbp
    1a8: lea     rsi,[ro+20]
    1af: call    qword ptr [sym10]
    1b5: mov     rax,[rbp-8]
    1b9: cmp     rax,[rbp-20h]
    1bd: jb      1C6h
    1bf: call    ryo_h_Abort
    1c4: ud2
    1c6: mov     edi,0FFFFFF70h
    1cb: mov     esi,10h
    1d0: call    ryo_h_MovW128
    1d5: mov     qword ptr [rbp-80h],0
    1dd: mov     rdx,[rbp-8]
    1e1: mov     [rbp-78h],rdx
    1e5: mov     edi,0FFFFFF90h
    1ea: lea     rsi,[k11]
    1f1: call    ryo_h_AddrAbs
    1f6: call    fn12
    1fb: nop     [rcx-11h]
    202: mov     edi,0FFFFFFF8h
    207: mov     esi,8
    20c: call    ryo_h_Ret
    211: leave
    212: ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-30h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-20h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-18h],rsi
     23: mov     [rbp-38h],rdx
     27: cmp     rax,0
     2b: jne     3Ah
     2d: mov     qword ptr [rbp-8],0
     35: jmp     2A1h
     3a: lea     rax,[rbp-38h]
     3e: mov     [rbp-58h],rax
     42: mov     rdx,[rbp+28h]
     46: mov     [rbp-50h],rdx
     4a: mov     rsi,[rbp+20h]
     4e: mov     [rbp-48h],rsi
     52: mov     [rbp-40h],rax
     56: mov     rdi,[rbp-20h]
     5a: mov     [rbp-60h],rdi
     5e: mov     edi,[rdi]
     60: mov     [rbp-58h],edi
     63: mov     [rbp-5Ch],edi
     66: mov     [rbp-54h],edi
     69: mov     qword ptr [rbp-0A8h],1
     74: mov     r9,[rbp-38h]
     78: imul    rcx,[rbp-0A8h],4
     80: add     r9,rcx
     83: mov     [rbp-80h],r9
     87: lea     r10,[rbp-54h]
     8b: mov     [rbp-98h],r10
     92: mov     r11,[rbp-38h]
     96: mov     [rbp-90h],r11
     9d: mov     [rbp-88h],r10
     a4: mov     [rbp-68h],r9
     a8: mov     qword ptr [rbp-60h],0
     b0: mov     edi,0FFFFFF88h
     b5: mov     esi,0FFFFFF70h
     ba: call    ryo_h_MovW128
     bf: mov     qword ptr [rbp-0A8h],2
     ca: mov     rdx,[rbp-0A8h]
     d1: sub     rdx,1
     d5: mov     [rbp-90h],rdx
     dc: mov     rsi,[rbp-30h]
     e0: sub     rsi,rdx
     e3: mov     [rbp-88h],rsi
     ea: mov     rdi,[rbp-38h]
     ee: imul    rcx,rsi,4
     f2: add     rdi,rcx
     f5: mov     [rbp-80h],rdi
     f9: nop     [rax]
    100: mov     rax,[rbp-68h]
    104: mov     [rbp-88h],rax
    10b: cmp     rax,[rbp-80h]
    10f: jae     1DEh
    115: mov     qword ptr [rbp-0A8h],2
    120: cmp     qword ptr [rbp-0A8h],2
    128: sete    [rbp-56h]
    12c: test    byte ptr [rbp-56h],0FFh
    130: je      1A2h
    132: lea     r8,[rbp-50h]
    136: mov     [rbp-88h],r8
    13d: lea     r9,[rbp-78h]
    141: mov     [rbp-98h],r9
    148: mov     [rbp-90h],r9
    14f: mov     [rbp-0C0h],r8
    156: mov     [rbp-0B8h],r9
    15d: call    fn0
    162: nop     [rcx-10h]
    169: lea     rax,[rbp-50h]
    16d: mov     [rbp-88h],rax
    174: lea     rdx,[rbp-78h]
    178: mov     [rbp-98h],rdx
    17f: mov     [rbp-90h],rdx
    186: mov     [rbp-0C0h],rax
    18d: mov     [rbp-0B8h],rdx
    194: call    fn1
    199: nop     [rcx-10h]
    1a0: jmp     1D9h
    1a2: lea     rax,[rbp-50h]
    1a6: mov     [rbp-88h],rax
    1ad: lea     rdx,[rbp-78h]
    1b1: mov     [rbp-98h],rdx
    1b8: mov     [rbp-90h],rdx
    1bf: mov     [rbp-0C0h],rax
    1c6: mov     [rbp-0B8h],rdx
    1cd: call    fn2
    1d2: nop     [rcx-10h]
    1d9: jmp     100h
    1de: mov     rax,[rbp-38h]
    1e2: imul    rcx,[rbp-30h],4
    1e7: add     rax,rcx
    1ea: mov     [rbp-88h],rax
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: mov     rax,[rbp-68h]
    204: mov     [rbp-90h],rax
    20b: cmp     rax,[rbp-88h]
    212: sete    [rbp-55h]
    216: test    byte ptr [rbp-55h],0FFh
    21a: je      229h
    21c: mov     rsi,[rbp-70h]
    220: mov     [rbp-90h],rsi
    227: jmp     234h
    229: mov     rax,[rbp-68h]
    22d: mov     [rbp-90h],rax
    234: mov     rax,[rbp-90h]
    23b: mov     [rbp-68h],rax
    23f: lea     rdx,[rbp-50h]
    243: mov     [rbp-90h],rdx
    24a: lea     rsi,[rbp-78h]
    24e: mov     [rbp-0A0h],rsi
    255: mov     [rbp-98h],rsi
    25c: mov     [rbp-0C0h],rdx
    263: mov     [rbp-0B8h],rsi
    26a: call    fn3
    26f: nop     [rcx-10h]
    276: test    byte ptr [rbp-55h],0FFh
    27a: je      29Ch
    27c: mov     rdx,[rbp-78h]
    280: mov     [rbp-90h],rdx
    287: mov     rsi,[rbp-70h]
    28b: mov     [rbp-98h],rsi
    292: mov     rdi,[rbp-60h]
    296: mov     [rbp-8],rdi
    29a: jmp     2A1h
    29c: jmp     200h
    2a1: mov     edi,0FFFFFFF8h
    2a6: mov     esi,8
    2ab: call    ryo_h_Ret
    2b0: leave
    2b1: ret
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
    2c0: mov     edi,0FFFFFFD8h
    2c5: call    ryo_h_Resume
    2ca: ud2
    2cc: nop     [rax]
    2d0: lea     rax,[rbp-78h]
    2d4: mov     [rbp-0A8h],rax
    2db: mov     [rbp-0C0h],rax
    2e2: call    fn4
    2e7: nop     [rcx-0A8h]
    2ee: jmp     2C0h
    2f0: lea     rdi,[sym5]
    2f7: lea     rsi,[site6]
    2fe: mov     edx,0FFFFFF58h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-0A0h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+4]
    322: call    qword ptr [sym7]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFFD8h
    337: call    ryo_h_Lpad
    33c: jmp     2D0h
    33e: mov     rdi,rax
    341: mov     esi,0FFFFFFD8h
    346: call    ryo_h_Lpad
    34b: jmp     2F0h

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-10h],rax
     16: mov     rdx,[rbp+18h]
     1a: mov     rdx,[rdx+10h]
     1e: mov     [rbp-18h],rdx
     22: mov     [rbp-48h],rdx
     26: mov     rsi,[rbp+10h]
     2a: mov     rsi,[rsi+8]
     2e: mov     [rbp-20h],rsi
     32: mov     [rbp-40h],rdx
     36: mov     [rbp-38h],rsi
     3a: mov     [rbp-0A0h],rax
     41: mov     [rbp-98h],rdx
     48: mov     [rbp-90h],rsi
     4f: call    fn0
     54: nop     [rcx-29h]
     5b: mov     rax,[rbp+10h]
     5f: mov     rax,[rax+10h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rax]
     6a: mov     [rbp-40h],rax
     6e: mov     rdx,[rbp+18h]
     72: mov     rdx,[rdx+18h]
     76: mov     [rbp-48h],rdx
     7a: imul    rcx,rdx,4
     7e: add     rax,rcx
     81: mov     [rbp-38h],rax
     85: mov     [rbp-40h],rax
     89: mov     rsi,[rbp+18h]
     8d: mov     rsi,[rsi]
     90: mov     [rbp-48h],rsi
     94: mov     byte ptr [rbp-59h],1
     98: test    byte ptr [rbp-59h],0FFh
     9c: je      140h
     a2: jmp     0D3h
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: mov     rax,[rbp+18h]
     b4: mov     rax,[rax+10h]
     b8: mov     [rbp-8],rax
     bc: mov     [rbp-40h],rax
     c0: mov     byte ptr [rbp-59h],1
     c4: test    byte ptr [rbp-59h],0FFh
     c8: je      1C3h
     ce: jmp     16Ah
     d3: mov     rax,[rbp-38h]
     d7: mov     [rbp-50h],rax
     db: mov     rdx,[rbp-48h]
     df: mov     [rbp-58h],rdx
     e3: mov     byte ptr [rbp-59h],0
     e7: test    byte ptr [rbp-59h],0FFh
     eb: je      0F3h
     ed: mov     byte ptr [rbp-2Ah],1
     f1: jmp     0F7h
     f3: mov     byte ptr [rbp-2Ah],0
     f7: mov     rax,[rbp-50h]
     fb: mov     [rbp-0A0h],rax
    102: mov     rdx,[rbp-58h]
    106: mov     [rbp-98h],rdx
    10d: mov     qword ptr [rbp-90h],4
    118: movzx   edi,byte ptr [rbp-2Ah]
    11c: mov     [rbp-88h],dil
    123: mov     edi,0FFFFFF80h
    128: lea     rsi,[k1]
    12f: call    ryo_h_AddrAbs
    134: call    fn2
    139: nop     [rcx-28h]
    140: mov     qword ptr [rbp-60h],1
    148: imul    rdx,[rbp-60h],4
    14d: mov     [rbp-68h],rdx
    151: mov     edi,0FFFFFFB8h
    156: mov     esi,0FFFFFFC0h
    15b: mov     edx,0FFFFFF98h
    160: call    ryo_h_Memmove
    165: jmp     0B0h
    16a: mov     rax,[rbp-8]
    16e: mov     [rbp-48h],rax
    172: mov     rdx,[rbp-38h]
    176: mov     [rbp-50h],rdx
    17a: mov     [rbp-0A0h],rax
    181: mov     [rbp-98h],rdx
    188: mov     qword ptr [rbp-90h],4
    193: mov     qword ptr [rbp-88h],4
    19e: mov     qword ptr [rbp-80h],1
    1a6: mov     edi,0FFFFFF88h
    1ab: lea     rsi,[k3]
    1b2: call    ryo_h_AddrAbs
    1b7: call    fn4
    1bc: nop     [rcx-28h]
    1c3: mov     qword ptr [rbp-60h],1
    1cb: imul    rdx,[rbp-60h],4
    1d0: mov     [rbp-68h],rdx
    1d4: mov     edi,0FFFFFFC8h
    1d9: mov     esi,0FFFFFFC0h
    1de: mov     edx,0FFFFFF98h
    1e3: call    ryo_h_Memcpy
    1e8: mov     rax,[rbp+18h]
    1ec: mov     rax,[rax+10h]
    1f0: mov     [rbp-40h],rax
    1f4: mov     rdx,[rbp+18h]
    1f8: mov     rcx,[rbp-40h]
    1fc: mov     [rdx],rcx
    1ff: mov     edi,0FFFFFFC0h
    204: mov     esi,0FFFFFFD7h
    209: call    ryo_h_ZextW8W64
    20e: mov     rax,[rbp+18h]
    212: mov     rax,[rax+18h]
    216: mov     [rbp-60h],rax
    21a: add     rax,[rbp-40h]
    21e: mov     [rbp-70h],rax
    222: mov     rdx,[rbp+18h]
    226: mov     rcx,[rbp-70h]
    22a: mov     [rdx+18h],rcx
    22e: mov     rsi,[rbp+18h]
    232: mov     rsi,[rsi+10h]
    236: mov     [rbp-48h],rsi
    23a: mov     qword ptr [rbp-60h],1
    242: imul    rcx,[rbp-60h],4
    247: add     rsi,rcx
    24a: mov     [rbp-40h],rsi
    24e: mov     r8,[rbp+18h]
    252: mov     rcx,[rbp-40h]
    256: mov     [r8+10h],rcx
    25a: xor     edi,edi
    25c: xor     esi,esi
    25e: call    ryo_h_Ret
    263: leave
    264: ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-30h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-20h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-18h],rsi
     23: mov     [rbp-38h],rdx
     27: cmp     rax,0
     2b: jne     3Ah
     2d: mov     qword ptr [rbp-8],0
     35: jmp     2A1h
     3a: lea     rax,[rbp-38h]
     3e: mov     [rbp-58h],rax
     42: mov     rdx,[rbp+28h]
     46: mov     [rbp-50h],rdx
     4a: mov     rsi,[rbp+20h]
     4e: mov     [rbp-48h],rsi
     52: mov     [rbp-40h],rax
     56: mov     rdi,[rbp-20h]
     5a: mov     [rbp-60h],rdi
     5e: mov     edi,[rdi]
     60: mov     [rbp-58h],edi
     63: mov     [rbp-5Ch],edi
     66: mov     [rbp-54h],edi
     69: mov     qword ptr [rbp-0A8h],1
     74: mov     r9,[rbp-38h]
     78: imul    rcx,[rbp-0A8h],4
     80: add     r9,rcx
     83: mov     [rbp-80h],r9
     87: lea     r10,[rbp-54h]
     8b: mov     [rbp-98h],r10
     92: mov     r11,[rbp-38h]
     96: mov     [rbp-90h],r11
     9d: mov     [rbp-88h],r10
     a4: mov     [rbp-68h],r9
     a8: mov     qword ptr [rbp-60h],0
     b0: mov     edi,0FFFFFF88h
     b5: mov     esi,0FFFFFF70h
     ba: call    ryo_h_MovW128
     bf: mov     qword ptr [rbp-0A8h],2
     ca: mov     rdx,[rbp-0A8h]
     d1: sub     rdx,1
     d5: mov     [rbp-90h],rdx
     dc: mov     rsi,[rbp-30h]
     e0: sub     rsi,rdx
     e3: mov     [rbp-88h],rsi
     ea: mov     rdi,[rbp-38h]
     ee: imul    rcx,rsi,4
     f2: add     rdi,rcx
     f5: mov     [rbp-80h],rdi
     f9: nop     [rax]
    100: mov     rax,[rbp-68h]
    104: mov     [rbp-88h],rax
    10b: cmp     rax,[rbp-80h]
    10f: jae     1DEh
    115: mov     qword ptr [rbp-0A8h],2
    120: cmp     qword ptr [rbp-0A8h],2
    128: sete    [rbp-56h]
    12c: test    byte ptr [rbp-56h],0FFh
    130: je      1A2h
    132: lea     r8,[rbp-50h]
    136: mov     [rbp-88h],r8
    13d: lea     r9,[rbp-78h]
    141: mov     [rbp-98h],r9
    148: mov     [rbp-90h],r9
    14f: mov     [rbp-0C0h],r8
    156: mov     [rbp-0B8h],r9
    15d: call    fn0
    162: nop     [rcx-10h]
    169: lea     rax,[rbp-50h]
    16d: mov     [rbp-88h],rax
    174: lea     rdx,[rbp-78h]
    178: mov     [rbp-98h],rdx
    17f: mov     [rbp-90h],rdx
    186: mov     [rbp-0C0h],rax
    18d: mov     [rbp-0B8h],rdx
    194: call    fn1
    199: nop     [rcx-10h]
    1a0: jmp     1D9h
    1a2: lea     rax,[rbp-50h]
    1a6: mov     [rbp-88h],rax
    1ad: lea     rdx,[rbp-78h]
    1b1: mov     [rbp-98h],rdx
    1b8: mov     [rbp-90h],rdx
    1bf: mov     [rbp-0C0h],rax
    1c6: mov     [rbp-0B8h],rdx
    1cd: call    fn2
    1d2: nop     [rcx-10h]
    1d9: jmp     100h
    1de: mov     rax,[rbp-38h]
    1e2: imul    rcx,[rbp-30h],4
    1e7: add     rax,rcx
    1ea: mov     [rbp-88h],rax
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: mov     rax,[rbp-68h]
    204: mov     [rbp-90h],rax
    20b: cmp     rax,[rbp-88h]
    212: sete    [rbp-55h]
    216: test    byte ptr [rbp-55h],0FFh
    21a: je      229h
    21c: mov     rsi,[rbp-70h]
    220: mov     [rbp-90h],rsi
    227: jmp     234h
    229: mov     rax,[rbp-68h]
    22d: mov     [rbp-90h],rax
    234: mov     rax,[rbp-90h]
    23b: mov     [rbp-68h],rax
    23f: lea     rdx,[rbp-50h]
    243: mov     [rbp-90h],rdx
    24a: lea     rsi,[rbp-78h]
    24e: mov     [rbp-0A0h],rsi
    255: mov     [rbp-98h],rsi
    25c: mov     [rbp-0C0h],rdx
    263: mov     [rbp-0B8h],rsi
    26a: call    fn3
    26f: nop     [rcx-10h]
    276: test    byte ptr [rbp-55h],0FFh
    27a: je      29Ch
    27c: mov     rdx,[rbp-78h]
    280: mov     [rbp-90h],rdx
    287: mov     rsi,[rbp-70h]
    28b: mov     [rbp-98h],rsi
    292: mov     rdi,[rbp-60h]
    296: mov     [rbp-8],rdi
    29a: jmp     2A1h
    29c: jmp     200h
    2a1: mov     edi,0FFFFFFF8h
    2a6: mov     esi,8
    2ab: call    ryo_h_Ret
    2b0: leave
    2b1: ret
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
    2c0: mov     edi,0FFFFFFD8h
    2c5: call    ryo_h_Resume
    2ca: ud2
    2cc: nop     [rax]
    2d0: lea     rax,[rbp-78h]
    2d4: mov     [rbp-0A8h],rax
    2db: mov     [rbp-0C0h],rax
    2e2: call    fn4
    2e7: nop     [rcx-0A8h]
    2ee: jmp     2C0h
    2f0: lea     rdi,[sym5]
    2f7: lea     rsi,[site6]
    2fe: mov     edx,0FFFFFF58h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-0A0h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+4]
    322: call    qword ptr [sym7]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFFD8h
    337: call    ryo_h_Lpad
    33c: jmp     2D0h
    33e: mov     rdi,rax
    341: mov     esi,0FFFFFFD8h
    346: call    ryo_h_Lpad
    34b: jmp     2F0h

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-10h],rax
     16: mov     rdx,[rbp+18h]
     1a: mov     rdx,[rdx+10h]
     1e: mov     [rbp-18h],rdx
     22: mov     [rbp-48h],rdx
     26: mov     rsi,[rbp+10h]
     2a: mov     rsi,[rsi+8]
     2e: mov     [rbp-20h],rsi
     32: mov     [rbp-40h],rdx
     36: mov     [rbp-38h],rsi
     3a: mov     [rbp-0A0h],rax
     41: mov     [rbp-98h],rdx
     48: mov     [rbp-90h],rsi
     4f: call    fn0
     54: nop     [rcx-29h]
     5b: mov     rax,[rbp+10h]
     5f: mov     rax,[rax+10h]
     63: mov     [rbp-28h],rax
     67: mov     rax,[rax]
     6a: mov     [rbp-40h],rax
     6e: mov     rdx,[rbp+18h]
     72: mov     rdx,[rdx+18h]
     76: mov     [rbp-48h],rdx
     7a: imul    rcx,rdx,4
     7e: add     rax,rcx
     81: mov     [rbp-38h],rax
     85: mov     [rbp-40h],rax
     89: mov     rsi,[rbp+18h]
     8d: mov     rsi,[rsi]
     90: mov     [rbp-48h],rsi
     94: mov     byte ptr [rbp-59h],1
     98: test    byte ptr [rbp-59h],0FFh
     9c: je      140h
     a2: jmp     0D3h
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: mov     rax,[rbp+18h]
     b4: mov     rax,[rax+10h]
     b8: mov     [rbp-8],rax
     bc: mov     [rbp-40h],rax
     c0: mov     byte ptr [rbp-59h],1
     c4: test    byte ptr [rbp-59h],0FFh
     c8: je      1C3h
     ce: jmp     16Ah
     d3: mov     rax,[rbp-38h]
     d7: mov     [rbp-50h],rax
     db: mov     rdx,[rbp-48h]
     df: mov     [rbp-58h],rdx
     e3: mov     byte ptr [rbp-59h],0
     e7: test    byte ptr [rbp-59h],0FFh
     eb: je      0F3h
     ed: mov     byte ptr [rbp-2Ah],1
     f1: jmp     0F7h
     f3: mov     byte ptr [rbp-2Ah],0
     f7: mov     rax,[rbp-50h]
     fb: mov     [rbp-0A0h],rax
    102: mov     rdx,[rbp-58h]
    106: mov     [rbp-98h],rdx
    10d: mov     qword ptr [rbp-90h],4
    118: movzx   edi,byte ptr [rbp-2Ah]
    11c: mov     [rbp-88h],dil
    123: mov     edi,0FFFFFF80h
    128: lea     rsi,[k1]
    12f: call    ryo_h_AddrAbs
    134: call    fn2
    139: nop     [rcx-28h]
    140: mov     qword ptr [rbp-60h],1
    148: imul    rdx,[rbp-60h],4
    14d: mov     [rbp-68h],rdx
    151: mov     edi,0FFFFFFB8h
    156: mov     esi,0FFFFFFC0h
    15b: mov     edx,0FFFFFF98h
    160: call    ryo_h_Memmove
    165: jmp     0B0h
    16a: mov     rax,[rbp-8]
    16e: mov     [rbp-48h],rax
    172: mov     rdx,[rbp-38h]
    176: mov     [rbp-50h],rdx
    17a: mov     [rbp-0A0h],rax
    181: mov     [rbp-98h],rdx
    188: mov     qword ptr [rbp-90h],4
    193: mov     qword ptr [rbp-88h],4
    19e: mov     qword ptr [rbp-80h],1
    1a6: mov     edi,0FFFFFF88h
    1ab: lea     rsi,[k3]
    1b2: call    ryo_h_AddrAbs
    1b7: call    fn4
    1bc: nop     [rcx-28h]
    1c3: mov     qword ptr [rbp-60h],1
    1cb: imul    rdx,[rbp-60h],4
    1d0: mov     [rbp-68h],rdx
    1d4: mov     edi,0FFFFFFC8h
    1d9: mov     esi,0FFFFFFC0h
    1de: mov     edx,0FFFFFF98h
    1e3: call    ryo_h_Memcpy
    1e8: mov     rax,[rbp+18h]
    1ec: mov     rax,[rax+10h]
    1f0: mov     [rbp-40h],rax
    1f4: mov     rdx,[rbp+18h]
    1f8: mov     rcx,[rbp-40h]
    1fc: mov     [rdx],rcx
    1ff: mov     edi,0FFFFFFC0h
    204: mov     esi,0FFFFFFD7h
    209: call    ryo_h_ZextW8W64
    20e: mov     rax,[rbp+18h]
    212: mov     rax,[rax+18h]
    216: mov     [rbp-60h],rax
    21a: add     rax,[rbp-40h]
    21e: mov     [rbp-70h],rax
    222: mov     rdx,[rbp+18h]
    226: mov     rcx,[rbp-70h]
    22a: mov     [rdx+18h],rcx
    22e: mov     rsi,[rbp+18h]
    232: mov     rsi,[rsi+10h]
    236: mov     [rbp-48h],rsi
    23a: mov     qword ptr [rbp-60h],1
    242: imul    rcx,[rbp-60h],4
    247: add     rsi,rcx
    24a: mov     [rbp-40h],rsi
    24e: mov     r8,[rbp+18h]
    252: mov     rcx,[rbp-40h]
    256: mov     [r8+10h],rcx
    25a: xor     edi,edi
    25c: xor     esi,esi
    25e: call    ryo_h_Ret
    263: leave
    264: ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-58h],rax
     18: mov     rdx,[rbp+18h]
     1c: mov     [rbp-50h],rdx
     20: mov     [rbp-48h],rdx
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
     60: jmp     46Ah
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
     a1: mov     rdx,[rbp+10h]
     a5: mov     [rbp-58h],rdx
     a9: mov     rsi,[rbp+18h]
     ad: mov     [rbp-50h],rsi
     b1: mov     edi,0FFFFFF30h
     b6: mov     esi,0FFFFFFA8h
     bb: call    ryo_h_MovW128
     c0: mov     rax,[rbp+30h]
     c4: mov     [rbp-0C0h],rax
     cb: call    fn3
     d0: nop     [rcx-48h]
     d7: jmp     0DEh
     d9: jmp     46Ah
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
    12c: .long   27dh
    130: .long   138h
    134: .long   538h
    138: mov     rax,[rbp+20h]
    13c: mov     [rbp-50h],rax
    140: mov     rdx,[rbp+10h]
    144: mov     [rbp-18h],rdx
    148: mov     rsi,[rbp+18h]
    14c: mov     [rbp-10h],rsi
    150: mov     [rbp-20h],rsi
    154: mov     rdi,[rbp-48h]
    158: cmp     rdi,rsi
    15b: jb      1BBh
    15d: mov     [rbp-0D0h],rdi
    164: mov     [rbp-0C8h],rsi
    16b: mov     edi,0FFFFFF40h
    170: lea     rsi,[k4]
    177: call    ryo_h_AddrAbs
    17c: lea     rdi,[sym5]
    183: lea     rsi,[site6]
    18a: mov     edx,0FFFFFF58h
    18f: call    ryo_h_CallExt
    194: test    rax,rax
    197: je      1A4h
    199: call    rax
    19b: nop     [rcx-0A0h]
    1a2: jmp     1B4h
    1a4: mov     rdi,rbp
    1a7: lea     rsi,[ro+4]
    1ae: call    qword ptr [sym7]
    1b4: call    ryo_h_Unreachable
    1b9: ud2
    1bb: mov     rax,[rbp+10h]
    1bf: imul    rcx,[rbp-48h],4
    1c4: add     rax,rcx
    1c7: mov     [rbp-0A8h],rax
    1ce: mov     [rbp-68h],rax
    1d2: mov     rdx,[rbp-50h]
    1d6: mov     [rbp-60h],rdx
    1da: mov     [rbp-58h],rax
    1de: mov     rsi,[rbp+30h]
    1e2: mov     [rbp-0D0h],rsi
    1e9: mov     [rbp-0C8h],rdx
    1f0: mov     [rbp-0C0h],rax
    1f7: call    fn8
    1fc: nop     [rcx-3Ah]
    203: test    byte ptr [rbp-3Ah],0FFh
    207: je      20Bh
    209: jmp     27Dh
    20b: mov     edi,0FFFFFF98h
    210: mov     esi,10h
    215: call    ryo_h_MovW128
    21a: mov     rax,[rbp+30h]
    21e: mov     [rbp-78h],rax
    222: lea     rdx,[rbp-78h]
    226: mov     [rbp-70h],rdx
    22a: mov     edi,0FFFFFF30h
    22f: mov     esi,0FFFFFF98h
    234: call    ryo_h_MovW128
    239: mov     rax,[rbp-48h]
    23d: mov     [rbp-0C0h],rax
    244: mov     rdx,[rbp-70h]
    248: mov     [rbp-0B8h],rdx
    24f: call    fn9
    254: nop     [rcx-58h]
    25b: mov     rax,[rbp-58h]
    25f: add     rax,1
    263: mov     [rbp-30h],rax
    267: mov     rdx,[rbp+18h]
    26b: mov     [rbp-60h],rdx
    26f: cmp     rdx,rax
    272: jb      475h
    278: jmp     4E6h
    27d: mov     edi,0FFFFFFA0h
    282: mov     esi,10h
    287: call    ryo_h_MovW128
    28c: mov     edi,0FFFFFF30h
    291: mov     esi,0FFFFFFA0h
    296: call    ryo_h_MovW128
    29b: mov     rax,[rbp-48h]
    29f: mov     [rbp-0C0h],rax
    2a6: mov     rdx,[rbp+30h]
    2aa: mov     [rbp-0B8h],rdx
    2b1: call    fn10
    2b6: nop     [rcx-50h]
    2bd: mov     rax,[rbp+10h]
    2c1: mov     [rbp-68h],rax
    2c5: mov     rdx,[rbp+18h]
    2c9: mov     [rbp-60h],rdx
    2cd: mov     [rbp-58h],rdx
    2d1: mov     rsi,[rbp-50h]
    2d5: cmp     rsi,rdx
    2d8: setb    [rbp-3Ah]
    2dc: mov     edi,0FFFFFF30h
    2e1: mov     esi,10h
    2e6: call    ryo_h_MovW128
    2eb: mov     rax,[rbp-50h]
    2ef: mov     [rbp-0C0h],rax
    2f6: mov     edi,0FFFFFF48h
    2fb: lea     rsi,[k11]
    302: call    ryo_h_AddrAbs
    307: call    fn12
    30c: nop     [rcx-90h]
    313: mov     edi,0FFFFFFA0h
    318: mov     esi,0FFFFFF70h
    31d: call    ryo_h_MovW128
    322: mov     edi,0FFFFFF90h
    327: mov     esi,0FFFFFF80h
    32c: call    ryo_h_MovW128
    331: mov     edi,0FFFFFF30h
    336: mov     esi,0FFFFFF90h
    33b: call    ryo_h_MovW128
    340: mov     qword ptr [rbp-0C0h],1
    34b: mov     edi,0FFFFFF48h
    350: lea     rsi,[k13]
    357: call    ryo_h_AddrAbs
    35c: call    fn14
    361: nop     [rcx-0A0h]
    368: mov     edi,0FFFFFF80h
    36d: mov     esi,0FFFFFF60h
    372: call    ryo_h_MovW128
    377: mov     edi,10h
    37c: mov     esi,0FFFFFF70h
    381: call    ryo_h_MovW128
    386: mov     rax,[rbp-78h]
    38a: mov     [rbp-38h],rax
    38e: mov     qword ptr [rbp-0A8h],0
    399: mov     rsi,[rbp-0A8h]
    3a0: cmp     rsi,rax
    3a3: setb    [rbp-39h]
    3a7: test    byte ptr [rbp-39h],0FFh
    3ab: jne     40Fh
    3ad: mov     qword ptr [rbp-0D0h],0
    3b8: mov     [rbp-0C8h],rax
    3bf: mov     edi,0FFFFFF40h
    3c4: lea     rsi,[k15]
    3cb: call    ryo_h_AddrAbs
    3d0: lea     rdi,[sym16]
    3d7: lea     rsi,[site17]
    3de: mov     edx,0FFFFFF58h
    3e3: call    ryo_h_CallExt
    3e8: test    rax,rax
    3eb: je      3F8h
    3ed: call    rax
    3ef: nop     [rcx-0A0h]
    3f6: jmp     408h
    3f8: mov     rdi,rbp
    3fb: lea     rsi,[ro+4]
    402: call    qword ptr [sym18]
    408: call    ryo_h_Unreachable
    40d: ud2
    40f: mov     rax,[rbp-80h]
    413: mov     [rbp-88h],rax
    41a: mov     edx,[rbp+28h]
    41d: mov     [rbp-40h],edx
    420: mov     edi,0FFFFFF30h
    425: mov     esi,0FFFFFFA0h
    42a: call    ryo_h_MovW128
    42f: mov     rax,[rbp+20h]
    433: mov     [rbp-0C0h],rax
    43a: mov     edx,[rbp-40h]
    43d: mov     [rbp-0B8h],edx
    443: mov     rsi,[rbp+30h]
    447: mov     [rbp-0B0h],rsi
    44e: call    fn19
    453: nop     [rcx-39h]
    45a: mov     rax,[rbp-88h]
    461: mov     [rbp+20h],rax
    465: jmp     10h
    46a: xor     edi,edi
    46c: xor     esi,esi
    46e: call    ryo_h_Ret
    473: leave
    474: ret
    475: mov     rax,[rbp-30h]
    479: mov     [rbp-0D0h],rax
    480: mov     rdx,[rbp-60h]
    484: mov     [rbp-0C8h],rdx
    48b: mov     rsi,[rbp-60h]
    48f: mov     [rbp-0C0h],rsi
    496: mov     edi,0FFFFFF48h
    49b: lea     rsi,[k20]
    4a2: call    ryo_h_AddrAbs
    4a7: lea     rdi,[sym21]
    4ae: lea     rsi,[site22]
    4b5: mov     edx,0FFFFFF58h
    4ba: call    ryo_h_CallExt
    4bf: test    rax,rax
    4c2: je      4CFh
    4c4: call    rax
    4c6: nop     [rcx-39h]
    4cd: jmp     4DFh
    4cf: mov     rdi,rbp
    4d2: lea     rsi,[ro+20]
    4d9: call    qword ptr [sym23]
    4df: call    ryo_h_Unreachable
    4e4: ud2
    4e6: mov     rax,[rbp-60h]
    4ea: sub     rax,[rbp-30h]
    4ee: mov     [rbp-68h],rax
    4f2: mov     rdx,[rbp+10h]
    4f6: mov     [rbp-88h],rdx
    4fd: mov     rsi,[rbp+18h]
    501: mov     [rbp-80h],rsi
    505: mov     [rbp-90h],rdx
    50c: imul    rcx,[rbp-30h],4
    511: add     rdx,rcx
    514: mov     [rbp-98h],rdx
    51b: mov     [rbp-78h],rdx
    51f: mov     [rbp-70h],rax
    523: mov     [rbp+10h],rdx
    527: mov     [rbp+18h],rax
    52b: mov     qword ptr [rbp+20h],0
    533: jmp     10h
    538: call    ryo_h_Unreachable
    53d: ud2

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+20h]
     17: mov     [rbp-28h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-20h],rsi
     23: mov     [rbp-40h],rax
     27: mov     [rbp-38h],rdx
     2b: mov     [rbp-30h],rsi
     2f: call    fn0
     34: nop     [rcx-11h]
     3b: movzx   eax,byte ptr [rbp-11h]
     3f: xor     al,1
     42: mov     [rbp-1],al
     45: mov     edi,0FFFFFFFFh
     4a: mov     esi,1
     4f: call    ryo_h_Ret
     54: leave
     55: ret

fn core::slice::sort::unstable::sort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-0Ah],0
      c: test    byte ptr [rbp-0Ah],0FFh
     10: jne     50h
     12: mov     rsi,[rbp+18h]
     16: mov     [rbp-8],rsi
     1a: cmp     rsi,2
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
     83: mov     rdx,[rbp+20h]
     87: mov     [rbp-18h],rdx
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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-30h],rdx
     1b: mov     rsi,[rbp+20h]
     1f: mov     [rbp-38h],rsi
     23: mov     rdi,[rbp+28h]
     27: mov     [rbp-60h],rdi
     2b: mov     edi,0FFFFFFA8h
     30: mov     esi,0FFFFFFB0h
     35: mov     edx,0FFFFFFC8h
     3a: mov     ecx,0FFFFFFA0h
     3f: call    ryo_h_MulOvfUW64
     44: mov     rax,[rbp-58h]
     48: mov     [rbp-38h],rax
     4c: movzx   edx,byte ptr [rbp-50h]
     50: mov     [rbp-1Dh],dl
     53: mov     [rbp-68h],rax
     57: test    byte ptr [rbp-1Dh],0FFh
     5b: je      0B5h
     5d: mov     edi,0FFFFFF80h
     62: lea     rsi,[k0]
     69: call    ryo_h_AddrAbs
     6e: mov     qword ptr [rbp-78h],3Dh
     76: lea     rdi,[sym1]
     7d: lea     rsi,[site2]
     84: mov     edx,0FFFFFF90h
     89: call    ryo_h_CallExt
     8e: test    rax,rax
     91: je      9Eh
     93: call    rax
     95: nop     [rcx-1]
     9c: jmp     0AEh
     9e: mov     rdi,rbp
     a1: lea     rsi,[ro+4]
     a8: call    qword ptr [sym3]
     ae: call    ryo_h_Unreachable
     b3: ud2
     b5: mov     rax,[rbp-68h]
     b9: mov     [rbp-40h],rax
     bd: mov     qword ptr [rbp-48h],1
     c5: mov     [rbp-38h],rax
     c9: mov     rsi,[rbp-28h]
     cd: cmp     rsi,[rbp-30h]
     d1: jae     0E0h
     d3: mov     rdi,[rbp-30h]
     d7: sub     rdi,rsi
     da: mov     [rbp-10h],rdi
     de: jmp     0ECh
     e0: mov     rax,[rbp-28h]
     e4: sub     rax,[rbp-30h]
     e8: mov     [rbp-10h],rax
     ec: mov     rax,[rbp-38h]
     f0: cmp     rax,[rbp-10h]
     f4: setbe   [rbp-1]
     f8: mov     edi,0FFFFFFFFh
     fd: mov     esi,1
    102: call    ryo_h_Ret
    107: leave
    108: ret

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
     38: mov     rsi,[rbp-8]
     3c: mov     [rbp-48h],rsi
     40: lea     rdi,[rbp-10h]
     44: mov     [rbp-60h],rdi
     48: mov     [rbp-58h],rdi
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
    19f: lea     rdx,[rbp-0B0h]
    1a6: mov     [rbp-110h],rdx
    1ad: mov     [rbp-100h],rax
    1b4: mov     [rbp-0F8h],rdx
    1bb: mov     [rbp-118h],rax
    1c2: mov     [rbp-120h],rdx
    1c9: mov     [rbp-330h],rax
    1d0: mov     [rbp-328h],rdx
    1d7: call    fn11
    1dc: nop     [rcx-121h]
    1e3: test    byte ptr [rbp-121h],0FFh
    1ea: je      20Ch
    1ec: lea     rdx,[rbp-28h]
    1f0: mov     [rbp-188h],rdx
    1f7: mov     [rbp-330h],rdx
    1fe: call    fn12
    203: nop     [rcx-180h]
    20a: jmp     27Bh
    20c: mov     byte ptr [rbp-122h],0
    213: mov     qword ptr [rbp-138h],0
    21e: movzx   esi,byte ptr [rbp-122h]
    225: mov     [rbp-310h],sil
    22c: mov     rdi,[rbp-118h]
    233: mov     [rbp-330h],rdi
    23a: mov     r8,[rbp-120h]
    241: mov     [rbp-328h],r8
    248: mov     edi,0FFFFFCE0h
    24d: mov     esi,0FFFFFEC8h
    252: call    ryo_h_MovW128
    257: mov     edi,0FFFFFCF8h
    25c: lea     rsi,[k13]
    263: call    ryo_h_AddrAbs
    268: call    fn14
    26d: nop     [rcx-122h]
    274: call    ryo_h_Unreachable
    279: ud2
    27b: mov     edi,0FFFFFCD0h
    280: mov     esi,0FFFFFE80h
    285: call    ryo_h_MovW128
    28a: call    fn15
    28f: nop     [rcx-170h]
    296: mov     edi,0FFFFFCD0h
    29b: mov     esi,0FFFFFE90h
    2a0: call    ryo_h_MovW128
    2a5: call    fn16
    2aa: nop     [rcx-160h]
    2b1: mov     edi,0FFFFFCD0h
    2b6: mov     esi,0FFFFFEA0h
    2bb: call    ryo_h_MovW128
    2c0: call    fn17
    2c5: nop     [rcx-150h]
    2cc: lea     rax,[rbp-150h]
    2d3: mov     [rbp-1A0h],rax
    2da: mov     [rbp-330h],rax
    2e1: call    fn18
    2e6: nop     [rcx-198h]
    2ed: mov     edi,0FFFFFCD0h
    2f2: mov     esi,0FFFFFE68h
    2f7: call    ryo_h_MovW128
    2fc: call    fn19
    301: nop     [rcx-188h]
    308: lea     rax,[rbp-78h]
    30c: mov     [rbp-1F8h],rax
    313: mov     [rbp-330h],rax
    31a: call    fn20
    31f: nop     [rcx-1F0h]
    326: mov     edi,0FFFFFCD0h
    32b: mov     esi,0FFFFFE10h
    330: call    ryo_h_MovW128
    335: call    fn21
    33a: nop     [rcx-1E0h]
    341: lea     rax,[rbp-1E0h]
    348: mov     [rbp-1D8h],rax
    34f: lea     rdx,[rbp-150h]
    356: mov     [rbp-208h],rdx
    35d: mov     [rbp-330h],rdx
    364: mov     qword ptr [rbp-328h],0
    36f: mov     edi,0FFFFFCE0h
    374: lea     rsi,[k22]
    37b: call    ryo_h_AddrAbs
    380: call    fn23
    385: nop     [rcx-200h]
    38c: lea     rax,[rbp-150h]
    393: mov     [rbp-218h],rax
    39a: mov     qword ptr [rbp-2F8h],1
    3a5: mov     edi,0FFFFFDD0h
    3aa: mov     esi,0FFFFFDD8h
    3af: mov     edx,0FFFFFFF8h
    3b4: mov     ecx,0FFFFFD08h
    3b9: call    ryo_h_SubOvfUW64
    3be: test    byte ptr [rbp-228h],0FFh
    3c5: je      417h
    3c7: mov     edi,0FFFFFCD0h
    3cc: lea     rsi,[k24]
    3d3: call    ryo_h_AddrAbs
    3d8: lea     rdi,[sym25]
    3df: lea     rsi,[site26]
    3e6: mov     edx,0FFFFFD08h
    3eb: call    ryo_h_CallExt
    3f0: test    rax,rax
    3f3: je      400h
    3f5: call    rax
    3f7: nop     [rcx-2F0h]
    3fe: jmp     410h
    400: mov     rdi,rbp
    403: lea     rsi,[ro+4]
    40a: call    qword ptr [sym27]
    410: call    ryo_h_Unreachable
    415: ud2
    417: mov     rax,[rbp-230h]
    41e: mov     [rbp-220h],rax
    425: mov     rdx,[rbp-218h]
    42c: mov     [rbp-330h],rdx
    433: mov     [rbp-328h],rax
    43a: mov     edi,0FFFFFCE0h
    43f: lea     rsi,[k28]
    446: call    ryo_h_AddrAbs
    44b: call    fn29
    450: nop     [rcx-210h]
    457: lea     rax,[rbp-8]
    45b: mov     [rbp-238h],rax
    462: mov     rdx,[rbp-1D8h]
    469: mov     [rbp-1D0h],rdx
    470: mov     rsi,[rbp-200h]
    477: mov     [rbp-1C8h],rsi
    47e: mov     rdi,[rbp-210h]
    485: mov     [rbp-1C0h],rdi
    48c: mov     [rbp-1B8h],rax
    493: mov     [rbp-2D0h],rax
    49a: mov     [rbp-330h],rax
    4a1: call    fn30
    4a6: nop     [rcx-288h]
    4ad: mov     rax,[rbp-1D0h]
    4b4: mov     [rbp-2D8h],rax
    4bb: mov     [rbp-330h],rax
    4c2: call    fn31
    4c7: nop     [rcx-298h]
    4ce: mov     rax,[rbp-1C8h]
    4d5: mov     [rbp-2E0h],rax
    4dc: mov     [rbp-330h],rax
    4e3: call    fn32
    4e8: nop     [rcx-2A8h]
    4ef: mov     rax,[rbp-1C0h]
    4f6: mov     [rbp-2E8h],rax
    4fd: mov     [rbp-330h],rax
    504: call    fn33
    509: nop     [rcx-2B8h]
    510: mov     edi,0FFFFFD88h
    515: mov     esi,0FFFFFD78h
    51a: call    ryo_h_MovW128
    51f: mov     edi,0FFFFFD98h
    524: mov     esi,0FFFFFD68h
    529: call    ryo_h_MovW128
    52e: mov     edi,0FFFFFDA8h
    533: mov     esi,0FFFFFD58h
    538: call    ryo_h_MovW128
    53d: mov     edi,0FFFFFDB8h
    542: mov     esi,0FFFFFD48h
    547: call    ryo_h_MovW128
    54c: mov     edi,0FFFFFD40h
    551: lea     rsi,[k34]
    558: call    ryo_h_AddrAbs
    55d: lea     rax,[rbp-278h]
    564: mov     [rbp-2C8h],rax
    56b: mov     rdx,[rbp-2C0h]
    572: mov     [rbp-330h],rdx
    579: mov     [rbp-328h],rax
    580: call    fn35
    585: nop     [rcx-1B0h]
    58c: mov     edi,0FFFFFCD0h
    591: mov     esi,0FFFFFE50h
    596: call    ryo_h_MovW128
    59b: lea     rdi,[sym36]
    5a2: lea     rsi,[site37]
    5a9: mov     edx,0FFFFFD08h
    5ae: call    ryo_h_CallExt
    5b3: test    rax,rax
    5b6: je      5C3h
    5b8: call    rax
    5ba: nop     [rcx-1A0h]
    5c1: jmp     5D3h
    5c3: mov     rdi,rbp
    5c6: lea     rsi,[ro+20]
    5cd: call    qword ptr [sym38]
    5d3: lea     rax,[rbp-150h]
    5da: mov     [rbp-2F8h],rax
    5e1: mov     [rbp-330h],rax
    5e8: call    fn39
    5ed: nop     [rcx-2F8h]
    5f4: lea     rax,[rbp-0B0h]
    5fb: mov     [rbp-2F8h],rax
    602: mov     [rbp-330h],rax
    609: call    fn40
    60e: nop     [rcx-2F8h]
    615: lea     rax,[rbp-78h]
    619: mov     [rbp-2F8h],rax
    620: mov     [rbp-330h],rax
    627: call    fn41
    62c: nop     [rcx-2F8h]
    633: lea     rax,[rbp-28h]
    637: mov     [rbp-2F8h],rax
    63e: mov     [rbp-330h],rax
    645: call    fn42
    64a: nop     [rcx-2F8h]
    651: xor     edi,edi
    653: xor     esi,esi
    655: call    ryo_h_Ret
    65a: leave
    65b: ret
    65c: nop     [rax]
    660: lea     rax,[rbp-150h]
    667: mov     [rbp-2F8h],rax
    66e: mov     [rbp-330h],rax
    675: call    fn43
    67a: nop     [rcx-2F8h]
    681: jmp     6C0h
    683: nop     [rax+rax]
    68c: nop     [rax]
    690: lea     rax,[rbp-0F0h]
    697: mov     [rbp-2F8h],rax
    69e: mov     [rbp-330h],rax
    6a5: call    fn44
    6aa: nop     [rcx-2F8h]
    6b1: nop     [rax+rax]
    6ba: nop     [rax+rax]
    6c0: lea     rax,[rbp-0B0h]
    6c7: mov     [rbp-2F8h],rax
    6ce: mov     [rbp-330h],rax
    6d5: call    fn45
    6da: nop     [rcx-2F8h]
    6e1: nop     [rax+rax]
    6ea: nop     [rax+rax]
    6f0: lea     rax,[rbp-78h]
    6f4: mov     [rbp-2F8h],rax
    6fb: mov     [rbp-330h],rax
    702: call    fn46
    707: nop     [rcx-2F8h]
    70e: xchg    ax,ax
    710: lea     rax,[rbp-28h]
    714: mov     [rbp-2F8h],rax
    71b: mov     [rbp-330h],rax
    722: call    fn47
    727: nop     [rcx-2F8h]
    72e: mov     edi,0FFFFFD10h
    733: call    ryo_h_Resume
    738: ud2
    73a: nop     [rax+rax]
    740: lea     rdi,[sym48]
    747: lea     rsi,[site49]
    74e: mov     edx,0FFFFFD08h
    753: call    ryo_h_CallExt
    758: test    rax,rax
    75b: je      768h
    75d: call    rax
    75f: nop     [rcx-2F0h]
    766: jmp     778h
    768: mov     rdi,rbp
    76b: lea     rsi,[ro+4]
    772: call    qword ptr [sym50]
    778: call    ryo_h_Unreachable
    77d: ud2
    77f: mov     rdi,rax
    782: mov     esi,0FFFFFD10h
    787: call    ryo_h_Lpad
    78c: jmp     710h
    78e: mov     rdi,rax
    791: mov     esi,0FFFFFD10h
    796: call    ryo_h_Lpad
    79b: jmp     6F0h
    7a0: mov     rdi,rax
    7a3: mov     esi,0FFFFFD10h
    7a8: call    ryo_h_Lpad
    7ad: jmp     6C0h
    7b2: mov     rdi,rax
    7b5: mov     esi,0FFFFFD10h
    7ba: call    ryo_h_Lpad
    7bf: jmp     690h
    7c4: mov     rdi,rax
    7c7: mov     esi,0FFFFFD10h
    7cc: call    ryo_h_Lpad
    7d1: jmp     660h
    7d6: mov     rdi,rax
    7d9: mov     esi,0FFFFFD10h
    7de: call    ryo_h_Lpad
    7e3: jmp     740h

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
     97: mov     edx,[rbp-0Ch]
     9a: mov     [rbp-4],edx
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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-18h],rdx
     1b: mov     [rbp-10h],rdx
     1f: cmp     rdx,10h
     23: ja      476h
     29: mov     rdi,[rbp+10h]
     2d: mov     [rbp-58h],rdi
     31: mov     r8,[rbp+18h]
     35: mov     [rbp-50h],r8
     39: mov     [rbp-48h],r8
     3d: mov     qword ptr [rbp-40h],1
     45: mov     [rbp-38h],r8
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
     c8: .long   c33h
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
    108: mov     rsi,[rbp-98h]
    10f: mov     [rbp-0C0h],rsi
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
    1a1: mov     rdx,[rbp+10h]
    1a5: mov     [rbp-0E0h],rdx
    1ac: mov     rsi,[rbp+18h]
    1b0: mov     [rbp-0D8h],rsi
    1b7: mov     [rbp-0E8h],rsi
    1be: cmp     rax,rsi
    1c1: jb      221h
    1c3: mov     [rbp-380h],rax
    1ca: mov     [rbp-378h],rsi
    1d1: mov     edi,0FFFFFC90h
    1d6: lea     rsi,[k6]
    1dd: call    ryo_h_AddrAbs
    1e2: lea     rdi,[sym7]
    1e9: lea     rsi,[site8]
    1f0: mov     edx,0FFFFFCA8h
    1f5: call    ryo_h_CallExt
    1fa: test    rax,rax
    1fd: je      20Ah
    1ff: call    rax
    201: nop     [rcx-350h]
    208: jmp     21Ah
    20a: mov     rdi,rbp
    20d: lea     rsi,[ro+4]
    214: call    qword ptr [sym9]
    21a: call    ryo_h_Unreachable
    21f: ud2
    221: mov     rax,[rbp+10h]
    225: imul    rcx,[rbp-0B8h],4
    22d: add     rax,rcx
    230: mov     [rbp-358h],rax
    237: mov     eax,[rax]
    239: mov     [rbp-0B0h],eax
    23f: mov     rdx,[rbp-98h]
    246: mov     [rbp-0F8h],rdx
    24d: mov     rsi,[rbp+10h]
    251: mov     [rbp-108h],rsi
    258: mov     rdi,[rbp+18h]
    25c: mov     [rbp-100h],rdi
    263: mov     [rbp-110h],rdi
    26a: cmp     rdx,rdi
    26d: jb      2CDh
    26f: mov     [rbp-380h],rdx
    276: mov     [rbp-378h],rdi
    27d: mov     edi,0FFFFFC90h
    282: lea     rsi,[k10]
    289: call    ryo_h_AddrAbs
    28e: lea     rdi,[sym11]
    295: lea     rsi,[site12]
    29c: mov     edx,0FFFFFCA8h
    2a1: call    ryo_h_CallExt
    2a6: test    rax,rax
    2a9: je      2B6h
    2ab: call    rax
    2ad: nop     [rcx-350h]
    2b4: jmp     2C6h
    2b6: mov     rdi,rbp
    2b9: lea     rsi,[ro+4]
    2c0: call    qword ptr [sym13]
    2c6: call    ryo_h_Unreachable
    2cb: ud2
    2cd: mov     rax,[rbp+10h]
    2d1: imul    rcx,[rbp-0F8h],4
    2d9: add     rax,rcx
    2dc: mov     [rbp-358h],rax
    2e3: mov     eax,[rax]
    2e5: mov     [rbp-0F0h],eax
    2eb: cmp     eax,[rbp-0B0h]
    2f1: jae     80h
    2f7: mov     rdx,[rbp-98h]
    2fe: mov     [rbp-128h],rdx
    305: mov     qword ptr [rbp-358h],1
    310: mov     edi,0FFFFFEC8h
    315: mov     esi,0FFFFFED0h
    31a: mov     edx,0FFFFFED8h
    31f: mov     ecx,0FFFFFCA8h
    324: call    ryo_h_SubOvfUW64
    329: test    byte ptr [rbp-130h],0FFh
    330: je      382h
    332: mov     edi,0FFFFFC80h
    337: lea     rsi,[k14]
    33e: call    ryo_h_AddrAbs
    343: lea     rdi,[sym15]
    34a: lea     rsi,[site16]
    351: mov     edx,0FFFFFCA8h
    356: call    ryo_h_CallExt
    35b: test    rax,rax
    35e: je      36Bh
    360: call    rax
    362: nop     [rcx-350h]
    369: jmp     37Bh
    36b: mov     rdi,rbp
    36e: lea     rsi,[ro+4]
    375: call    qword ptr [sym17]
    37b: call    ryo_h_Unreachable
    380: ud2
    382: mov     rax,[rbp-138h]
    389: mov     [rbp-120h],rax
    390: mov     rdx,[rbp-98h]
    397: mov     [rbp-140h],rdx
    39e: mov     edi,0FFFFFC80h
    3a3: mov     esi,10h
    3a8: call    ryo_h_MovW128
    3ad: mov     rax,[rbp-120h]
    3b4: mov     [rbp-370h],rax
    3bb: mov     rdx,[rbp-140h]
    3c2: mov     [rbp-368h],rdx
    3c9: mov     edi,0FFFFFCA0h
    3ce: lea     rsi,[k18]
    3d5: call    ryo_h_AddrAbs
    3da: call    fn19
    3df: nop     [rcx-111h]
    3e6: mov     qword ptr [rbp-358h],1
    3f1: mov     edi,0FFFFFEB0h
    3f6: mov     esi,0FFFFFEB8h
    3fb: mov     edx,0FFFFFF68h
    400: mov     ecx,0FFFFFCA8h
    405: call    ryo_h_SubOvfUW64
    40a: test    byte ptr [rbp-148h],0FFh
    411: je      463h
    413: mov     edi,0FFFFFC80h
    418: lea     rsi,[k20]
    41f: call    ryo_h_AddrAbs
    424: lea     rdi,[sym21]
    42b: lea     rsi,[site22]
    432: mov     edx,0FFFFFCA8h
    437: call    ryo_h_CallExt
    43c: test    rax,rax
    43f: je      44Ch
    441: call    rax
    443: nop     [rcx-350h]
    44a: jmp     45Ch
    44c: mov     rdi,rbp
    44f: lea     rsi,[ro+4]
    456: call    qword ptr [sym23]
    45c: call    ryo_h_Unreachable
    461: ud2
    463: mov     rax,[rbp-150h]
    46a: mov     [rbp-98h],rax
    471: jmp     0F0h
    476: mov     rax,[rbp+10h]
    47a: mov     [rbp-170h],rax
    481: mov     rdx,[rbp+18h]
    485: mov     [rbp-168h],rdx
    48c: mov     [rbp-160h],rdx
    493: mov     qword ptr [rbp-358h],2
    49e: cmp     qword ptr [rbp-358h],0
    4a6: sete    [rbp-171h]
    4ad: test    byte ptr [rbp-171h],0FFh
    4b4: je      506h
    4b6: mov     edi,0FFFFFC80h
    4bb: lea     rsi,[k24]
    4c2: call    ryo_h_AddrAbs
    4c7: lea     rdi,[sym25]
    4ce: lea     rsi,[site26]
    4d5: mov     edx,0FFFFFCA8h
    4da: call    ryo_h_CallExt
    4df: test    rax,rax
    4e2: je      4EFh
    4e4: call    rax
    4e6: nop     [rcx-350h]
    4ed: jmp     4FFh
    4ef: mov     rdi,rbp
    4f2: lea     rsi,[ro+4]
    4f9: call    qword ptr [sym27]
    4ff: call    ryo_h_Unreachable
    504: ud2
    506: mov     qword ptr [rbp-358h],2
    511: mov     edi,0FFFFFEA8h
    516: mov     esi,0FFFFFEA0h
    51b: mov     edx,0FFFFFCA8h
    520: call    ryo_h_DivUW64
    525: mov     rax,[rbp-158h]
    52c: mov     [rbp-190h],rax
    533: mov     edi,0FFFFFC80h
    538: mov     esi,10h
    53d: call    ryo_h_MovW128
    542: mov     rax,[rbp-190h]
    549: mov     [rbp-370h],rax
    550: mov     edi,0FFFFFC98h
    555: lea     rsi,[k28]
    55c: call    ryo_h_AddrAbs
    561: call    fn29
    566: nop     [rcx-188h]
    56d: mov     edi,0FFFFFC80h
    572: mov     esi,0FFFFFE78h
    577: call    ryo_h_MovW128
    57c: mov     rax,[rbp+20h]
    580: mov     [rbp-370h],rax
    587: call    fn30
    58c: nop     [rcx-171h]
    593: mov     rax,[rbp-158h]
    59a: mov     [rbp-1A8h],rax
    5a1: mov     edi,0FFFFFC80h
    5a6: mov     esi,10h
    5ab: call    ryo_h_MovW128
    5b0: mov     rax,[rbp-1A8h]
    5b7: mov     [rbp-370h],rax
    5be: mov     edi,0FFFFFC98h
    5c3: lea     rsi,[k31]
    5ca: call    ryo_h_AddrAbs
    5cf: call    fn32
    5d4: nop     [rcx-1A0h]
    5db: mov     edi,0FFFFFC80h
    5e0: mov     esi,0FFFFFE60h
    5e5: call    ryo_h_MovW128
    5ea: mov     rax,[rbp+20h]
    5ee: mov     [rbp-370h],rax
    5f5: call    fn33
    5fa: nop     [rcx-190h]
    601: mov     rax,[rbp+20h]
    605: mov     [rbp-380h],rax
    60c: call    fn34
    611: nop     [rcx-1A8h]
    618: mov     qword ptr [rbp-1C8h],0
    623: mov     rdx,[rbp-158h]
    62a: mov     [rbp-1C0h],rdx
    631: mov     rsi,[rbp-1C8h]
    638: mov     [rbp-1B0h],rsi
    63f: mov     [rbp-1B8h],rdx
    646: nop     [rax+rax]
    64f: nop
    650: mov     rax,[rbp-1B0h]
    657: mov     [rbp-1D8h],rax
    65e: cmp     rax,[rbp-158h]
    665: jae     0AB5h
    66b: mov     rdx,[rbp-1B8h]
    672: mov     [rbp-1E8h],rdx
    679: mov     rsi,[rbp+10h]
    67d: mov     [rbp-200h],rsi
    684: mov     rdi,[rbp+18h]
    688: mov     [rbp-1F8h],rdi
    68f: mov     [rbp-1F0h],rdi
    696: cmp     rdx,rdi
    699: jae     0AB5h
    69f: mov     r8,[rbp-1B0h]
    6a6: mov     [rbp-210h],r8
    6ad: mov     r9,[rbp+10h]
    6b1: mov     [rbp-220h],r9
    6b8: mov     r10,[rbp+18h]
    6bc: mov     [rbp-218h],r10
    6c3: mov     [rbp-228h],r10
    6ca: cmp     r8,r10
    6cd: jb      72Dh
    6cf: mov     [rbp-380h],r8
    6d6: mov     [rbp-378h],r10
    6dd: mov     edi,0FFFFFC90h
    6e2: lea     rsi,[k35]
    6e9: call    ryo_h_AddrAbs
    6ee: lea     rdi,[sym36]
    6f5: lea     rsi,[site37]
    6fc: mov     edx,0FFFFFCA8h
    701: call    ryo_h_CallExt
    706: test    rax,rax
    709: je      716h
    70b: call    rax
    70d: nop     [rcx-350h]
    714: jmp     726h
    716: mov     rdi,rbp
    719: lea     rsi,[ro+4]
    720: call    qword ptr [sym38]
    726: call    ryo_h_Unreachable
    72b: ud2
    72d: mov     rax,[rbp+10h]
    731: imul    rcx,[rbp-210h],4
    739: add     rax,rcx
    73c: mov     [rbp-358h],rax
    743: mov     eax,[rax]
    745: mov     [rbp-208h],eax
    74b: mov     rdx,[rbp-1B8h]
    752: mov     [rbp-238h],rdx
    759: mov     rsi,[rbp+10h]
    75d: mov     [rbp-248h],rsi
    764: mov     rdi,[rbp+18h]
    768: mov     [rbp-240h],rdi
    76f: mov     [rbp-250h],rdi
    776: cmp     rdx,rdi
    779: jb      7D9h
    77b: mov     [rbp-380h],rdx
    782: mov     [rbp-378h],rdi
    789: mov     edi,0FFFFFC90h
    78e: lea     rsi,[k39]
    795: call    ryo_h_AddrAbs
    79a: lea     rdi,[sym40]
    7a1: lea     rsi,[site41]
    7a8: mov     edx,0FFFFFCA8h
    7ad: call    ryo_h_CallExt
    7b2: test    rax,rax
    7b5: je      7C2h
    7b7: call    rax
    7b9: nop     [rcx-350h]
    7c0: jmp     7D2h
    7c2: mov     rdi,rbp
    7c5: lea     rsi,[ro+4]
    7cc: call    qword ptr [sym42]
    7d2: call    ryo_h_Unreachable
    7d7: ud2
    7d9: mov     rax,[rbp+10h]
    7dd: imul    rcx,[rbp-238h],4
    7e5: add     rax,rcx
    7e8: mov     [rbp-358h],rax
    7ef: mov     eax,[rax]
    7f1: mov     [rbp-230h],eax
    7f7: cmp     eax,[rbp-208h]
    7fd: jb      95Ch
    803: mov     rdx,[rbp-1B0h]
    80a: mov     [rbp-260h],rdx
    811: mov     rsi,[rbp+10h]
    815: mov     [rbp-270h],rsi
    81c: mov     rdi,[rbp+18h]
    820: mov     [rbp-268h],rdi
    827: mov     [rbp-278h],rdi
    82e: cmp     rdx,rdi
    831: jb      891h
    833: mov     [rbp-380h],rdx
    83a: mov     [rbp-378h],rdi
    841: mov     edi,0FFFFFC90h
    846: lea     rsi,[k43]
    84d: call    ryo_h_AddrAbs
    852: lea     rdi,[sym44]
    859: lea     rsi,[site45]
    860: mov     edx,0FFFFFCA8h
    865: call    ryo_h_CallExt
    86a: test    rax,rax
    86d: je      87Ah
    86f: call    rax
    871: nop     [rcx-350h]
    878: jmp     88Ah
    87a: mov     rdi,rbp
    87d: lea     rsi,[ro+4]
    884: call    qword ptr [sym46]
    88a: call    ryo_h_Unreachable
    88f: ud2
    891: mov     rax,[rbp+10h]
    895: imul    rcx,[rbp-260h],4
    89d: add     rax,rcx
    8a0: mov     [rbp-358h],rax
    8a7: mov     eax,[rax]
    8a9: mov     [rbp-258h],eax
    8af: mov     rdx,[rbp+20h]
    8b3: mov     [rbp-380h],rdx
    8ba: mov     [rbp-378h],eax
    8c0: call    fn47
    8c5: nop     [rcx-251h]
    8cc: mov     qword ptr [rbp-358h],1
    8d7: mov     edi,0FFFFFD70h
    8dc: mov     esi,0FFFFFD78h
    8e1: mov     edx,0FFFFFE50h
    8e6: mov     ecx,0FFFFFCA8h
    8eb: call    ryo_h_AddOvfUW64
    8f0: test    byte ptr [rbp-288h],0FFh
    8f7: je      949h
    8f9: mov     edi,0FFFFFC80h
    8fe: lea     rsi,[k48]
    905: call    ryo_h_AddrAbs
    90a: lea     rdi,[sym49]
    911: lea     rsi,[site50]
    918: mov     edx,0FFFFFCA8h
    91d: call    ryo_h_CallExt
    922: test    rax,rax
    925: je      932h
    927: call    rax
    929: nop     [rcx-350h]
    930: jmp     942h
    932: mov     rdi,rbp
    935: lea     rsi,[ro+4]
    93c: call    qword ptr [sym51]
    942: call    ryo_h_Unreachable
    947: ud2
    949: mov     rax,[rbp-290h]
    950: mov     [rbp-1B0h],rax
    957: jmp     650h
    95c: mov     rax,[rbp-1B8h]
    963: mov     [rbp-2A0h],rax
    96a: mov     rdx,[rbp+10h]
    96e: mov     [rbp-2B0h],rdx
    975: mov     rsi,[rbp+18h]
    979: mov     [rbp-2A8h],rsi
    980: mov     [rbp-2B8h],rsi
    987: cmp     rax,rsi
    98a: jb      9EAh
    98c: mov     [rbp-380h],rax
    993: mov     [rbp-378h],rsi
    99a: mov     edi,0FFFFFC90h
    99f: lea     rsi,[k52]
    9a6: call    ryo_h_AddrAbs
    9ab: lea     rdi,[sym53]
    9b2: lea     rsi,[site54]
    9b9: mov     edx,0FFFFFCA8h
    9be: call    ryo_h_CallExt
    9c3: test    rax,rax
    9c6: je      9D3h
    9c8: call    rax
    9ca: nop     [rcx-350h]
    9d1: jmp     9E3h
    9d3: mov     rdi,rbp
    9d6: lea     rsi,[ro+4]
    9dd: call    qword ptr [sym55]
    9e3: call    ryo_h_Unreachable
    9e8: ud2
    9ea: mov     rax,[rbp+10h]
    9ee: imul    rcx,[rbp-2A0h],4
    9f6: add     rax,rcx
    9f9: mov     [rbp-358h],rax
    a00: mov     eax,[rax]
    a02: mov     [rbp-294h],eax
    a08: mov     rdx,[rbp+20h]
    a0c: mov     [rbp-380h],rdx
    a13: mov     [rbp-378h],eax
    a19: call    fn56
    a1e: nop     [rcx-290h]
    a25: mov     qword ptr [rbp-358h],1
    a30: mov     edi,0FFFFFD30h
    a35: mov     esi,0FFFFFD38h
    a3a: mov     edx,0FFFFFE48h
    a3f: mov     ecx,0FFFFFCA8h
    a44: call    ryo_h_AddOvfUW64
    a49: test    byte ptr [rbp-2C8h],0FFh
    a50: je      0AA2h
    a52: mov     edi,0FFFFFC80h
    a57: lea     rsi,[k57]
    a5e: call    ryo_h_AddrAbs
    a63: lea     rdi,[sym58]
    a6a: lea     rsi,[site59]
    a71: mov     edx,0FFFFFCA8h
    a76: call    ryo_h_CallExt
    a7b: test    rax,rax
    a7e: je      0A8Bh
    a80: call    rax
    a82: nop     [rcx-350h]
    a89: jmp     0A9Bh
    a8b: mov     rdi,rbp
    a8e: lea     rsi,[ro+4]
    a95: call    qword ptr [sym60]
    a9b: call    ryo_h_Unreachable
    aa0: ud2
    aa2: mov     rax,[rbp-2D0h]
    aa9: mov     [rbp-1B8h],rax
    ab0: jmp     650h
    ab5: mov     rax,[rbp+10h]
    ab9: mov     [rbp-2F0h],rax
    ac0: mov     rdx,[rbp+18h]
    ac4: mov     [rbp-2E8h],rdx
    acb: mov     rsi,[rbp-1B0h]
    ad2: mov     [rbp-308h],rsi
    ad9: mov     [rbp-300h],rsi
    ae0: mov     rdi,[rbp-158h]
    ae7: mov     [rbp-2F8h],rdi
    aee: mov     edi,0FFFFFC80h
    af3: mov     esi,0FFFFFD10h
    af8: call    ryo_h_MovW128
    afd: mov     edi,0FFFFFC90h
    b02: mov     esi,0FFFFFD00h
    b07: call    ryo_h_MovW128
    b0c: mov     edi,0FFFFFCA0h
    b11: lea     rsi,[k61]
    b18: call    ryo_h_AddrAbs
    b1d: call    fn62
    b22: nop     [rcx-2E0h]
    b29: mov     rax,[rbp+20h]
    b2d: mov     [rbp-380h],rax
    b34: mov     edi,0FFFFFC88h
    b39: mov     esi,0FFFFFD20h
    b3e: call    ryo_h_MovW128
    b43: call    fn63
    b48: nop     [rcx-2D0h]
    b4f: mov     rax,[rbp+10h]
    b53: mov     [rbp-328h],rax
    b5a: mov     rdx,[rbp+18h]
    b5e: mov     [rbp-320h],rdx
    b65: mov     rsi,[rbp-1B8h]
    b6c: mov     [rbp-338h],rsi
    b73: mov     [rbp-330h],rsi
    b7a: mov     edi,0FFFFFC80h
    b7f: mov     esi,0FFFFFCD8h
    b84: call    ryo_h_MovW128
    b89: mov     rax,[rbp-330h]
    b90: mov     [rbp-370h],rax
    b97: mov     edi,0FFFFFC98h
    b9c: lea     rsi,[k64]
    ba3: call    ryo_h_AddrAbs
    ba8: call    fn65
    bad: nop     [rcx-318h]
    bb4: mov     rax,[rbp+20h]
    bb8: mov     [rbp-380h],rax
    bbf: mov     edi,0FFFFFC88h
    bc4: mov     esi,0FFFFFCE8h
    bc9: call    ryo_h_MovW128
    bce: call    fn66
    bd3: nop     [rcx-308h]
    bda: mov     rax,[rbp+20h]
    bde: mov     [rbp-350h],rax
    be5: mov     [rbp-380h],rax
    bec: call    fn67
    bf1: nop     [rcx-348h]
    bf8: mov     edi,0FFFFFC80h
    bfd: mov     esi,10h
    c02: call    ryo_h_MovW128
    c07: mov     edi,0FFFFFC90h
    c0c: mov     esi,0FFFFFCB8h
    c11: call    ryo_h_MovW128
    c16: mov     edi,0FFFFFCA0h
    c1b: lea     rsi,[k68]
    c22: call    ryo_h_AddrAbs
    c27: call    fn69
    c2c: nop     [rcx-338h]
    c33: xor     edi,edi
    c35: xor     esi,esi
    c37: call    ryo_h_Ret
    c3c: leave
    c3d: ret

fn std::array::iter::iter_inner::PolymorphicIter::<[std::mem::MaybeUninit<usize>]>::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-58h],rax
     17: mov     rdx,[rbp+10h]
     1b: mov     rdx,[rdx]
     1e: mov     [rbp-60h],rdx
     22: sub     rax,rdx
     25: mov     [rbp-50h],rax
     29: cmp     rax,0
     2d: jbe     4Ch
     2f: mov     rdi,[rbp+10h]
     33: mov     rdi,[rdi]
     36: mov     [rbp-50h],rdi
     3a: mov     byte ptr [rbp-99h],1
     41: test    byte ptr [rbp-99h],0FFh
     48: je      0C5h
     4a: jmp     92h
     4c: mov     edi,0FFFFFFC0h
     51: lea     rsi,[k0]
     58: mov     edx,10h
     5d: call    ryo_h_Const
     62: mov     rax,[rbp+10h]
     66: lea     rax,[rax+10h]
     6a: mov     [rbp-28h],rax
     6e: mov     rdx,[rbp+18h]
     72: mov     [rbp-20h],rdx
     76: mov     edi,0FFFFFF68h
     7b: mov     esi,0FFFFFFD8h
     80: call    ryo_h_MovW128
     85: mov     qword ptr [rbp-10h],0
     8d: jmp     150h
     92: mov     rax,[rbp-50h]
     96: mov     [rbp-0C0h],rax
     9d: mov     qword ptr [rbp-0B8h],1
     a8: mov     edi,0FFFFFF50h
     ad: lea     rsi,[k1]
     b4: call    ryo_h_AddrAbs
     b9: call    fn2
     be: nop     [rcx-30h]
     c5: mov     rax,[rbp-50h]
     c9: add     rax,1
     cd: mov     [rbp-58h],rax
     d1: mov     rdx,[rbp+10h]
     d5: mov     rcx,[rbp-58h]
     d9: mov     [rdx],rcx
     dc: mov     rsi,[rbp-50h]
     e0: mov     [rbp-38h],rsi
     e4: mov     qword ptr [rbp-40h],1
     ec: mov     r8,[rbp+10h]
     f0: lea     r8,[r8+10h]
     f4: mov     [rbp-28h],r8
     f8: mov     r9,[rbp+18h]
     fc: mov     [rbp-20h],r9
    100: mov     edi,0FFFFFF68h
    105: mov     esi,0FFFFFFD8h
    10a: call    ryo_h_MovW128
    10f: mov     rax,[rbp-38h]
    113: mov     [rbp-48h],rax
    117: mov     edi,0FFFFFF78h
    11c: mov     esi,0FFFFFFD8h
    121: call    ryo_h_MovW128
    126: mov     edi,0FFFFFFA0h
    12b: mov     esi,0FFFFFFD8h
    130: call    ryo_h_MovW128
    135: mov     byte ptr [rbp-99h],1
    13c: test    byte ptr [rbp-99h],0FFh
    143: je      198h
    145: jmp     161h
    147: nop     [rax+rax]
    150: mov     edi,0FFFFFFF0h
    155: mov     esi,10h
    15a: call    ryo_h_Ret
    15f: leave
    160: ret
    161: mov     rax,[rbp-20h]
    165: mov     [rbp-70h],rax
    169: mov     rdx,[rbp-48h]
    16d: mov     [rbp-0C0h],rdx
    174: mov     [rbp-0B8h],rax
    17b: mov     edi,0FFFFFF50h
    180: lea     rsi,[k3]
    187: call    ryo_h_AddrAbs
    18c: call    fn4
    191: nop     [rcx-30h]
    198: mov     rax,[rbp-20h]
    19c: mov     [rbp-78h],rax
    1a0: mov     rdx,[rbp-48h]
    1a4: cmp     rdx,rax
    1a7: setb    [rbp-69h]
    1ab: mov     rsi,[rbp-28h]
    1af: imul    rcx,rdx,8
    1b3: add     rsi,rcx
    1b6: mov     [rbp-0A0h],rsi
    1bd: mov     [rbp-68h],rsi
    1c1: mov     rdi,rbp
    1c4: lea     rsi,[ro+4]
    1cb: call    qword ptr [sym5]
    1d1: mov     rax,[rbp-68h]
    1d5: mov     [rbp-70h],rax
    1d9: mov     rax,[rax]
    1dc: mov     [rbp-50h],rax
    1e0: mov     [rbp-8],rax
    1e4: mov     qword ptr [rbp-10h],1
    1ec: jmp     150h

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     eax,[rax]
      e: mov     [rbp-8],eax
     11: mov     rdx,[rbp+18h]
     15: mov     edx,[rdx]
     17: mov     [rbp-0Ch],edx
     1a: cmp     eax,edx
     1c: setb    [rbp-1]
     20: mov     edi,0FFFFFFFFh
     25: mov     esi,1
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-18h],rdx
     1e: cmp     rax,rdx
     21: setb    [rbp-1]
     25: mov     edi,0FFFFFFFFh
     2a: mov     esi,1
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn std::fmt::Arguments::<'_>::new::<22, 4>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-20h],rdx
     18: mov     [rbp-10h],rax
     1c: mov     [rbp-8],rdx
     20: mov     edi,0FFFFFFF0h
     25: mov     esi,10h
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

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
     c3: lea     rdx,[rbp-50h]
     c7: mov     [rbp-70h],rdx
     cb: mov     [rbp-68h],rdx
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
      f: jne     0E1h
     15: mov     edi,0FFFFFFF0h
     1a: lea     rsi,[k0]
     21: call    ryo_h_AddrAbs
     26: mov     qword ptr [rbp-8],0DDh
     2e: mov     rdx,[rbp-10h]
     32: mov     [rbp-40h],rdx
     36: mov     rsi,[rbp-8]
     3a: mov     [rbp-38h],rsi
     3e: mov     [rbp-30h],rdx
     42: mov     [rbp-28h],rdx
     46: mov     edi,0FFFFFFA8h
     4b: lea     rsi,[k1]
     52: call    ryo_h_AddrAbs
     57: mov     qword ptr [rbp-50h],0DDh
     5f: mov     rdx,[rbp-50h]
     63: mov     [rbp-48h],rdx
     67: shl     rdx,1
     6b: mov     [rbp-40h],rdx
     6f: or      rdx,1
     73: mov     [rbp-38h],rdx
     77: mov     [rbp-30h],rdx
     7b: mov     rsi,[rbp-28h]
     7f: mov     [rbp-20h],rsi
     83: mov     [rbp-18h],rdx
     87: mov     edi,0FFFFFF80h
     8c: mov     esi,0FFFFFFE0h
     91: call    ryo_h_MovW128
     96: mov     byte ptr [rbp-70h],0
     9a: mov     rdx,[rbp+18h]
     9e: mov     [rbp-68h],rdx
     a2: lea     rdi,[sym2]
     a9: lea     rsi,[site3]
     b0: mov     edx,0FFFFFFA0h
     b5: call    ryo_h_CallExt
     ba: test    rax,rax
     bd: je      0CAh
     bf: call    rax
     c1: nop     [rcx-10h]
     c8: jmp     0DAh
     ca: mov     rdi,rbp
     cd: lea     rsi,[ro+4]
     d4: call    qword ptr [sym4]
     da: call    ryo_h_Unreachable
     df: ud2
     e1: xor     edi,edi
     e3: xor     esi,esi
     e5: call    ryo_h_Ret
     ea: leave
     eb: ret

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
     1b: mov     rdx,[rbp+20h]
     1f: mov     [rbp-48h],rdx
     23: mov     [rbp-40h],rdx
     27: mov     [rbp-38h],rdx
     2b: lea     rsi,[rbp-30h]
     2f: mov     [rbp-48h],rsi
     33: mov     [rbp-40h],rsi
     37: lea     rdi,[rbp-38h]
     3b: mov     [rbp-50h],rdi
     3f: mov     [rbp-48h],rdi
     43: movzx   r8d,byte ptr [rbp+18h]
     48: mov     [rbp-88h],r8b
     4f: mov     [rbp-90h],rsi
     56: mov     [rbp-80h],rdi
     5a: mov     rdi,rbp
     5d: lea     rsi,[ro+4]
     64: call    qword ptr [sym0]
     6a: movzx   eax,byte ptr [rbp+18h]
     6e: mov     [rbp-88h],al
     74: mov     rdx,[rbp-48h]
     78: mov     [rbp-90h],rdx
     7f: mov     rsi,[rbp-40h]
     83: mov     [rbp-80h],rsi
     87: mov     rdi,rbp
     8a: lea     rsi,[ro+16]
     91: call    qword ptr [sym1]
     97: mov     rax,[rbp-50h]
     9b: mov     [rbp-58h],rax
     9f: mov     rdx,[rbp-20h]
     a3: mov     [rbp-60h],rdx
     a7: mov     [rbp-90h],rdx
     ae: mov     edi,0FFFFFF88h
     b3: lea     rsi,[sym2]
     ba: call    ryo_h_AddrSym
     bf: mov     rdi,rbp
     c2: lea     rsi,[ro+28]
     c9: call    qword ptr [sym3]
     cf: jmp     12Dh
     d1: nop     [rax+rax]
     da: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     170h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
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
    135: mov     rdx,[rbp-30h]
    139: mov     [rbp-68h],rdx
    13d: mov     rsi,[rbp-38h]
    141: mov     [rbp-70h],rsi
    145: movzx   edi,byte ptr [rbp+18h]
    149: mov     [rbp-88h],dil
    150: mov     [rbp-90h],rdx
    157: mov     [rbp-80h],rsi
    15b: mov     rdi,rbp
    15e: lea     rsi,[ro+44]
    165: call    qword ptr [sym6]
    16b: jmp     0E0h
    170: mov     rax,[rbp-60h]
    174: mov     [rbp-8],rax
    178: mov     edi,0FFFFFFF8h
    17d: mov     esi,8
    182: call    ryo_h_Ret
    187: leave
    188: ret
    189: nop     [rax]
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
     1b: mov     rdx,[rbp+20h]
     1f: mov     [rbp-48h],rdx
     23: mov     [rbp-40h],rdx
     27: mov     [rbp-38h],rdx
     2b: lea     rsi,[rbp-30h]
     2f: mov     [rbp-48h],rsi
     33: mov     [rbp-40h],rsi
     37: lea     rdi,[rbp-38h]
     3b: mov     [rbp-50h],rdi
     3f: mov     [rbp-48h],rdi
     43: movzx   r8d,byte ptr [rbp+18h]
     48: mov     [rbp-88h],r8b
     4f: mov     [rbp-90h],rsi
     56: mov     [rbp-80h],rdi
     5a: mov     rdi,rbp
     5d: lea     rsi,[ro+4]
     64: call    qword ptr [sym0]
     6a: movzx   eax,byte ptr [rbp+18h]
     6e: mov     [rbp-88h],al
     74: mov     rdx,[rbp-48h]
     78: mov     [rbp-90h],rdx
     7f: mov     rsi,[rbp-40h]
     83: mov     [rbp-80h],rsi
     87: mov     rdi,rbp
     8a: lea     rsi,[ro+16]
     91: call    qword ptr [sym1]
     97: mov     rax,[rbp-50h]
     9b: mov     [rbp-58h],rax
     9f: mov     rdx,[rbp-20h]
     a3: mov     [rbp-60h],rdx
     a7: mov     [rbp-90h],rdx
     ae: mov     edi,0FFFFFF88h
     b3: lea     rsi,[sym2]
     ba: call    ryo_h_AddrSym
     bf: mov     rdi,rbp
     c2: lea     rsi,[ro+28]
     c9: call    qword ptr [sym3]
     cf: jmp     12Dh
     d1: nop     [rax+rax]
     da: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     170h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
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
    135: mov     rdx,[rbp-30h]
    139: mov     [rbp-68h],rdx
    13d: mov     rsi,[rbp-38h]
    141: mov     [rbp-70h],rsi
    145: movzx   edi,byte ptr [rbp+18h]
    149: mov     [rbp-88h],dil
    150: mov     [rbp-90h],rdx
    157: mov     [rbp-80h],rsi
    15b: mov     rdi,rbp
    15e: lea     rsi,[ro+44]
    165: call    qword ptr [sym6]
    16b: jmp     0E0h
    170: mov     rax,[rbp-60h]
    174: mov     [rbp-8],rax
    178: mov     edi,0FFFFFFF8h
    17d: mov     esi,8
    182: call    ryo_h_Ret
    187: leave
    188: ret
    189: nop     [rax]
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
     1b: mov     rdx,[rbp+20h]
     1f: mov     [rbp-48h],rdx
     23: mov     [rbp-40h],rdx
     27: mov     [rbp-38h],rdx
     2b: lea     rsi,[rbp-30h]
     2f: mov     [rbp-48h],rsi
     33: mov     [rbp-40h],rsi
     37: lea     rdi,[rbp-38h]
     3b: mov     [rbp-50h],rdi
     3f: mov     [rbp-48h],rdi
     43: movzx   r8d,byte ptr [rbp+18h]
     48: mov     [rbp-88h],r8b
     4f: mov     [rbp-90h],rsi
     56: mov     [rbp-80h],rdi
     5a: mov     rdi,rbp
     5d: lea     rsi,[ro+4]
     64: call    qword ptr [sym0]
     6a: movzx   eax,byte ptr [rbp+18h]
     6e: mov     [rbp-88h],al
     74: mov     rdx,[rbp-48h]
     78: mov     [rbp-90h],rdx
     7f: mov     rsi,[rbp-40h]
     83: mov     [rbp-80h],rsi
     87: mov     rdi,rbp
     8a: lea     rsi,[ro+16]
     91: call    qword ptr [sym1]
     97: mov     rax,[rbp-50h]
     9b: mov     [rbp-58h],rax
     9f: mov     rdx,[rbp-20h]
     a3: mov     [rbp-60h],rdx
     a7: mov     [rbp-90h],rdx
     ae: mov     edi,0FFFFFF88h
     b3: lea     rsi,[sym2]
     ba: call    ryo_h_AddrSym
     bf: mov     rdi,rbp
     c2: lea     rsi,[ro+28]
     c9: call    qword ptr [sym3]
     cf: jmp     12Dh
     d1: nop     [rax+rax]
     da: nop     [rax+rax]
     e0: mov     rdi,rbp
     e3: lea     rsi,[ro+16]
     ea: call    qword ptr [sym4]
     f0: jmp     170h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
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
    135: mov     rdx,[rbp-30h]
    139: mov     [rbp-68h],rdx
    13d: mov     rsi,[rbp-38h]
    141: mov     [rbp-70h],rsi
    145: movzx   edi,byte ptr [rbp+18h]
    149: mov     [rbp-88h],dil
    150: mov     [rbp-90h],rdx
    157: mov     [rbp-80h],rsi
    15b: mov     rdi,rbp
    15e: lea     rsi,[ro+44]
    165: call    qword ptr [sym6]
    16b: jmp     0E0h
    170: mov     rax,[rbp-60h]
    174: mov     [rbp-8],rax
    178: mov     edi,0FFFFFFF8h
    17d: mov     esi,8
    182: call    ryo_h_Ret
    187: leave
    188: ret
    189: nop     [rax]
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
      e: mov     rdx,[rbp+10h]
     12: mov     [rbp-8],rdx
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
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-28h],rdx
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
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-28h],rdx
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
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-10h],rdx
     18: mov     [rbp-20h],rax
     1c: mov     [rbp-18h],rdx
     20: call    fn0
     25: nop     [rcx]
     2c: xor     edi,edi
     2e: xor     esi,esi
     30: call    ryo_h_Ret
     35: leave
     36: ret

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     edx,[rbp+18h]
     13: mov     [rbp-0Ch],edx
     16: mov     [rbp-20h],rax
     1a: mov     [rbp-18h],edx
     1d: call    fn0
     22: nop     [rcx]
     29: xor     edi,edi
     2b: xor     esi,esi
     2d: call    ryo_h_Ret
     32: leave
     33: ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     byte ptr [rbp-1],1
     14: mov     rsi,[rbp+10h]
     18: lea     rsi,[rsi+18h]
     1c: mov     [rbp-30h],rsi
     20: mov     rdi,[rbp+18h]
     24: mov     [rbp-38h],rdi
     28: mov     [rbp-50h],rsi
     2c: mov     [rbp-48h],rdi
     30: call    fn0
     35: nop     [rcx-28h]
     3c: mov     byte ptr [rbp-1],0
     40: mov     rdx,[rbp-28h]
     44: mov     [rbp-20h],rdx
     48: mov     rsi,[rbp-18h]
     4c: mov     [rbp-50h],rsi
     50: mov     [rbp-48h],rdx
     54: call    fn1
     59: nop     [rcx]
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: nop     [rax+rax]
     70: mov     edi,0FFFFFFF0h
     75: call    ryo_h_Resume
     7a: ud2
     7c: nop     [rax]
     80: jmp     70h
     82: nop     [rax+rax]
     8b: nop     [rax+rax]
     90: test    byte ptr [rbp-1],0FFh
     94: je      70h
     96: jmp     80h
     98: mov     rdi,rax
     9b: mov     esi,0FFFFFFF0h
     a0: call    ryo_h_Lpad
     a5: jmp     90h

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     byte ptr [rbp-1],1
     14: mov     rsi,[rbp+10h]
     18: lea     rsi,[rsi+18h]
     1c: mov     [rbp-28h],rsi
     20: mov     rdi,[rbp+18h]
     24: mov     [rbp-30h],rdi
     28: mov     [rbp-40h],rsi
     2c: mov     [rbp-38h],rdi
     30: call    fn0
     35: nop     [rcx-20h]
     3c: mov     byte ptr [rbp-1],0
     40: mov     edx,[rbp-20h]
     43: mov     [rbp-1Ch],edx
     46: mov     rsi,[rbp-18h]
     4a: mov     [rbp-40h],rsi
     4e: mov     [rbp-38h],edx
     51: call    fn1
     56: nop     [rcx]
     5d: xor     edi,edi
     5f: xor     esi,esi
     61: call    ryo_h_Ret
     66: leave
     67: ret
     68: nop     [rax+rax]
     70: mov     edi,0FFFFFFF0h
     75: call    ryo_h_Resume
     7a: ud2
     7c: nop     [rax]
     80: jmp     70h
     82: nop     [rax+rax]
     8b: nop     [rax+rax]
     90: test    byte ptr [rbp-1],0FFh
     94: je      70h
     96: jmp     80h
     98: mov     rdi,rax
     9b: mov     esi,0FFFFFFF0h
     a0: call    ryo_h_Lpad
     a5: jmp     90h

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
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+8]
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-40h],rax
     20: mov     [rbp-38h],rdx
     24: call    fn0
     29: nop     [rcx-19h]
     30: test    byte ptr [rbp-19h],0FFh
     34: je      60h
     36: mov     rdx,[rbp+10h]
     3a: mov     [rbp-28h],rdx
     3e: mov     rsi,[rbp+10h]
     42: lea     rsi,[rsi+8]
     46: mov     [rbp-30h],rsi
     4a: mov     [rbp-40h],rdx
     4e: mov     [rbp-38h],rsi
     52: call    fn1
     57: nop     [rcx-18h]
     5e: jmp     7Eh
     60: mov     qword ptr [rbp-18h],0
     68: mov     edi,0FFFFFFF0h
     6d: lea     rsi,[k2]
     74: mov     edx,10h
     79: call    ryo_h_Const
     7e: mov     edi,0FFFFFFE8h
     83: mov     esi,18h
     88: call    ryo_h_Ret
     8d: leave
     8e: ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFF9Ch
     10: mov     esi,18h
     15: call    ryo_h_CtpopW64
     1a: mov     eax,[rbp-64h]
     1d: mov     [rbp-8],eax
     20: jmp     141h
     25: nop     [rax+rax]
     2e: xchg    ax,ax
     30: mov     rax,[rbp+10h]
     34: mov     [rbp-20h],rax
     38: mov     [rbp-18h],rax
     3c: mov     rdx,[rbp+18h]
     40: sub     rdx,1
     44: mov     [rbp-20h],rdx
     48: and     rax,rdx
     4b: mov     [rbp-10h],rax
     4f: cmp     rax,0
     53: sete    [rbp-1]
     57: mov     edi,0FFFFFFFFh
     5c: mov     esi,1
     61: call    ryo_h_Ret
     66: leave
     67: ret
     68: nop     [rax+rax]
     70: mov     edi,0FFFFFFD8h
     75: lea     rsi,[k0]
     7c: call    ryo_h_AddrAbs
     81: mov     qword ptr [rbp-20h],2Ah
     89: mov     rdx,[rbp-28h]
     8d: mov     [rbp-48h],rdx
     91: mov     rsi,[rbp-20h]
     95: mov     [rbp-40h],rsi
     99: mov     [rbp-38h],rdx
     9d: mov     [rbp-30h],rdx
     a1: mov     edi,0FFFFFFA0h
     a6: lea     rsi,[k1]
     ad: call    ryo_h_AddrAbs
     b2: mov     qword ptr [rbp-58h],2Ah
     ba: mov     rdx,[rbp-58h]
     be: mov     [rbp-50h],rdx
     c2: shl     rdx,1
     c6: mov     [rbp-48h],rdx
     ca: or      rdx,1
     ce: mov     [rbp-40h],rdx
     d2: mov     [rbp-38h],rdx
     d6: mov     rsi,[rbp-30h]
     da: mov     [rbp-18h],rsi
     de: mov     [rbp-10h],rdx
     e2: mov     edi,0FFFFFF80h
     e7: mov     esi,0FFFFFFE8h
     ec: call    ryo_h_MovW128
     f1: mov     edi,0FFFFFF90h
     f6: lea     rsi,[k2]
     fd: call    ryo_h_AddrAbs
    102: lea     rdi,[sym3]
    109: lea     rsi,[site4]
    110: mov     edx,0FFFFFF98h
    115: call    ryo_h_CallExt
    11a: test    rax,rax
    11d: je      12Ah
    11f: call    rax
    121: nop     [rcx-1]
    128: jmp     13Ah
    12a: mov     rdi,rbp
    12d: lea     rsi,[ro+4]
    134: call    qword ptr [sym5]
    13a: call    ryo_h_Unreachable
    13f: ud2
    141: cmp     dword ptr [rbp-8],1
    145: sete    [rbp-2]
    149: test    byte ptr [rbp-2],0FFh
    14d: je      70h
    153: jmp     30h

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
     39: mov     rdx,[rbp-10h]
     3d: mov     [rbp-48h],rdx
     41: mov     rsi,[rbp-8]
     45: mov     [rbp-40h],rsi
     49: mov     [rbp-38h],rdx
     4d: mov     [rbp-30h],rdx
     51: mov     edi,0FFFFFFA0h
     56: lea     rsi,[k1]
     5d: call    ryo_h_AddrAbs
     62: mov     qword ptr [rbp-58h],0C9h
     6a: mov     rdx,[rbp-58h]
     6e: mov     [rbp-50h],rdx
     72: shl     rdx,1
     76: mov     [rbp-48h],rdx
     7a: or      rdx,1
     7e: mov     [rbp-40h],rdx
     82: mov     [rbp-38h],rdx
     86: mov     rsi,[rbp-30h]
     8a: mov     [rbp-28h],rsi
     8e: mov     [rbp-20h],rdx
     92: mov     edi,0FFFFFF70h
     97: mov     esi,0FFFFFFD8h
     9c: call    ryo_h_MovW128
     a1: mov     byte ptr [rbp-80h],0
     a5: mov     rdx,[rbp+20h]
     a9: mov     [rbp-78h],rdx
     ad: lea     rdi,[sym2]
     b4: lea     rsi,[site3]
     bb: mov     edx,0FFFFFF98h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-10h]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+4]
     df: call    qword ptr [sym4]
     e5: call    ryo_h_Unreachable
     ea: ud2

fn std::ptr::copy::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-90h],rax
     16: mov     rdx,[rbp+20h]
     1a: mov     [rbp-88h],rdx
     21: call    fn0
     26: nop     [rcx-1Ah]
     2d: jmp     1A0h
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
     79: mov     rdx,[rbp-10h]
     7d: mov     [rbp-50h],rdx
     81: mov     rsi,[rbp-8]
     85: mov     [rbp-48h],rsi
     89: mov     [rbp-40h],rdx
     8d: mov     [rbp-38h],rdx
     91: mov     edi,0FFFFFF98h
     96: lea     rsi,[k2]
     9d: call    ryo_h_AddrAbs
     a2: mov     qword ptr [rbp-60h],0DDh
     aa: mov     rdx,[rbp-60h]
     ae: mov     [rbp-58h],rdx
     b2: shl     rdx,1
     b6: mov     [rbp-50h],rdx
     ba: or      rdx,1
     be: mov     [rbp-48h],rdx
     c2: mov     [rbp-40h],rdx
     c6: mov     rsi,[rbp-38h]
     ca: mov     [rbp-30h],rsi
     ce: mov     [rbp-28h],rdx
     d2: mov     edi,0FFFFFF70h
     d7: mov     esi,0FFFFFFD0h
     dc: call    ryo_h_MovW128
     e1: mov     byte ptr [rbp-80h],0
     e5: mov     rdx,[rbp+30h]
     e9: mov     [rbp-78h],rdx
     ed: lea     rdi,[sym3]
     f4: lea     rsi,[site4]
     fb: mov     edx,0FFFFFF90h
    100: call    ryo_h_CallExt
    105: test    rax,rax
    108: je      115h
    10a: call    rax
    10c: nop     [rcx-10h]
    113: jmp     125h
    115: mov     rdi,rbp
    118: lea     rsi,[ro+4]
    11f: call    qword ptr [sym5]
    125: call    ryo_h_Unreachable
    12a: ud2
    12c: nop     [rax]
    130: test    byte ptr [rbp+28h],0FFh
    134: je      178h
    136: jmp     145h
    138: nop     [rax+rax]
    140: jmp     60h
    145: mov     rax,[rbp+18h]
    149: mov     [rbp-28h],rax
    14d: mov     rdx,[rbp+20h]
    151: mov     [rbp-30h],rdx
    155: mov     [rbp-90h],rax
    15c: mov     rsi,[rbp+20h]
    160: mov     [rbp-88h],rsi
    167: call    fn6
    16c: nop     [rcx-1Bh]
    173: jmp     1FBh
    178: mov     rax,[rbp+10h]
    17c: mov     [rbp-28h],rax
    180: cmp     rax,0
    184: sete    [rbp-1Bh]
    188: movzx   esi,byte ptr [rbp-1Bh]
    18c: xor     sil,1
    190: mov     [rbp-19h],sil
    194: test    byte ptr [rbp-19h],0FFh
    198: je      60h
    19e: jmp     203h
    1a0: test    byte ptr [rbp-1Ah],0FFh
    1a4: je      140h
    1a6: jmp     130h
    1a8: nop     [rax+rax]
    1b0: jmp     50h
    1b5: nop     [rax+rax]
    1be: xchg    ax,ax
    1c0: jmp     40h
    1c5: nop     [rax+rax]
    1ce: xchg    ax,ax
    1d0: mov     rax,[rbp+18h]
    1d4: mov     [rbp-38h],rax
    1d8: cmp     rax,0
    1dc: sete    [rbp-1Ch]
    1e0: movzx   esi,byte ptr [rbp-1Ch]
    1e4: xor     sil,1
    1e8: mov     [rbp-1Ah],sil
    1ec: test    byte ptr [rbp-1Ah],0FFh
    1f0: je      50h
    1f6: jmp     40h
    1fb: test    byte ptr [rbp-1Bh],0FFh
    1ff: je      1B0h
    201: jmp     1C0h
    203: mov     rax,[rbp+18h]
    207: mov     [rbp-28h],rax
    20b: mov     rdx,[rbp+20h]
    20f: mov     [rbp-30h],rdx
    213: mov     [rbp-90h],rax
    21a: mov     rsi,[rbp+20h]
    21e: mov     [rbp-88h],rsi
    225: call    fn7
    22a: nop     [rcx-1Bh]
    231: test    byte ptr [rbp-1Bh],0FFh
    235: je      1B0h
    23b: jmp     1D0h
    23d: nop     [rax]
    240: lea     rdi,[sym8]
    247: lea     rsi,[site9]
    24e: mov     edx,0FFFFFF90h
    253: call    ryo_h_CallExt
    258: test    rax,rax
    25b: je      268h
    25d: call    rax
    25f: nop     [rcx-68h]
    266: jmp     278h
    268: mov     rdi,rbp
    26b: lea     rsi,[ro+20]
    272: call    qword ptr [sym10]
    278: call    ryo_h_Unreachable
    27d: ud2
    27f: mov     rdi,rax
    282: mov     esi,0FFFFFFE8h
    287: call    ryo_h_Lpad
    28c: jmp     240h

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
     28: mov     rdx,[rbp+10h]
     2c: mov     [rbp-0A0h],rdx
     33: mov     rsi,[rbp+28h]
     37: mov     [rbp-98h],rsi
     3e: call    fn0
     43: nop     [rcx-2Ch]
     4a: jmp     205h
     4f: nop
     50: mov     rax,[rbp+18h]
     54: mov     [rbp-10h],rax
     58: mov     [rbp-0A0h],rax
     5f: mov     rdx,[rbp+28h]
     63: mov     [rbp-98h],rdx
     6a: call    fn1
     6f: nop     [rcx-2Ch]
     76: jmp     255h
     7b: nop     [rax+rax]
     80: mov     rax,[rbp+10h]
     84: mov     [rbp-0A0h],rax
     8b: mov     rdx,[rbp-10h]
     8f: mov     [rbp-98h],rdx
     96: mov     rsi,[rbp+20h]
     9a: mov     [rbp-90h],rsi
     a1: mov     rdi,[rbp+30h]
     a5: mov     [rbp-88h],rdi
     ac: call    fn2
     b1: nop     [rcx-29h]
     b8: jmp     25Dh
     bd: nop     [rax]
     c0: jmp     0D0h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: mov     edi,0FFFFFFE0h
     d5: lea     rsi,[k3]
     dc: call    ryo_h_AddrAbs
     e1: mov     qword ptr [rbp-18h],11Bh
     e9: mov     rdx,[rbp-20h]
     ed: mov     [rbp-60h],rdx
     f1: mov     rsi,[rbp-18h]
     f5: mov     [rbp-58h],rsi
     f9: mov     [rbp-50h],rdx
     fd: mov     [rbp-48h],rdx
    101: mov     edi,0FFFFFF88h
    106: lea     rsi,[k4]
    10d: call    ryo_h_AddrAbs
    112: mov     qword ptr [rbp-70h],11Bh
    11a: mov     rdx,[rbp-70h]
    11e: mov     [rbp-68h],rdx
    122: shl     rdx,1
    126: mov     [rbp-60h],rdx
    12a: or      rdx,1
    12e: mov     [rbp-58h],rdx
    132: mov     [rbp-50h],rdx
    136: mov     rsi,[rbp-48h]
    13a: mov     [rbp-40h],rsi
    13e: mov     [rbp-38h],rdx
    142: mov     edi,0FFFFFF60h
    147: mov     esi,0FFFFFFC0h
    14c: call    ryo_h_MovW128
    151: mov     byte ptr [rbp-90h],0
    158: mov     rdx,[rbp+38h]
    15c: mov     [rbp-88h],rdx
    163: lea     rdi,[sym5]
    16a: lea     rsi,[site6]
    171: mov     edx,0FFFFFF80h
    176: call    ryo_h_CallExt
    17b: test    rax,rax
    17e: je      18Bh
    180: call    rax
    182: nop     [rcx-20h]
    189: jmp     19Bh
    18b: mov     rdi,rbp
    18e: lea     rsi,[ro+4]
    195: call    qword ptr [sym7]
    19b: call    ryo_h_Unreachable
    1a0: ud2
    1a2: nop     [rax+rax]
    1ab: nop     [rax+rax]
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
    1ea: movzx   esi,byte ptr [rbp-2Dh]
    1ee: xor     sil,1
    1f2: mov     [rbp-2Ah],sil
    1f6: test    byte ptr [rbp-2Ah],0FFh
    1fa: je      0D0h
    200: jmp     50h
    205: test    byte ptr [rbp-2Ch],0FFh
    209: je      1D0h
    20b: jmp     1C0h
    20d: nop     [rax]
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
    23a: movzx   esi,byte ptr [rbp-2Dh]
    23e: xor     sil,1
    242: mov     [rbp-2Bh],sil
    246: test    byte ptr [rbp-2Bh],0FFh
    24a: je      0C0h
    250: jmp     80h
    255: test    byte ptr [rbp-2Ch],0FFh
    259: je      220h
    25b: jmp     210h
    25d: test    byte ptr [rbp-29h],0FFh
    261: je      0D0h
    267: jmp     1B0h
    26c: nop     [rax]
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
     13: lea     rdx,[rbp-24h]
     17: mov     [rbp-18h],rdx
     1b: mov     [rbp-38h],rdx
     1f: mov     byte ptr [rbp-49h],1
     23: test    byte ptr [rbp-49h],0FFh
     27: je      7Ch
     29: mov     r8,[rbp+10h]
     2d: mov     [rbp-40h],r8
     31: mov     r9,[rbp-18h]
     35: mov     [rbp-48h],r9
     39: mov     [rbp-90h],r8
     40: mov     [rbp-88h],r9
     47: mov     qword ptr [rbp-80h],4
     4f: mov     qword ptr [rbp-78h],4
     57: mov     qword ptr [rbp-70h],1
     5f: mov     edi,0FFFFFF98h
     64: lea     rsi,[k0]
     6b: call    ryo_h_AddrAbs
     70: call    fn1
     75: nop     [rcx-18h]
     7c: mov     qword ptr [rbp-50h],1
     84: imul    rdx,[rbp-50h],4
     89: mov     [rbp-58h],rdx
     8d: mov     edi,0FFFFFFC8h
     92: mov     esi,0FFFFFFD0h
     97: mov     edx,0FFFFFFA8h
     9c: call    ryo_h_Memcpy
     a1: mov     rax,[rbp+18h]
     a5: mov     [rbp-30h],rax
     a9: mov     byte ptr [rbp-49h],1
     ad: test    byte ptr [rbp-49h],0FFh
     b1: je      146h
     b7: jmp     0DFh
     b9: nop     [rax]
     c0: lea     rax,[rbp-24h]
     c4: mov     [rbp-20h],rax
     c8: mov     [rbp-30h],rax
     cc: mov     byte ptr [rbp-49h],1
     d0: test    byte ptr [rbp-49h],0FFh
     d4: je      1C3h
     da: jmp     170h
     df: mov     rax,[rbp+18h]
     e3: mov     [rbp-38h],rax
     e7: mov     rdx,[rbp+10h]
     eb: mov     [rbp-40h],rdx
     ef: mov     byte ptr [rbp-49h],0
     f3: test    byte ptr [rbp-49h],0FFh
     f7: je      0FFh
     f9: mov     byte ptr [rbp-25h],1
     fd: jmp     103h
     ff: mov     byte ptr [rbp-25h],0
    103: mov     rax,[rbp-38h]
    107: mov     [rbp-90h],rax
    10e: mov     rdx,[rbp-40h]
    112: mov     [rbp-88h],rdx
    119: mov     qword ptr [rbp-80h],4
    121: movzx   edi,byte ptr [rbp-25h]
    125: mov     [rbp-78h],dil
    129: mov     edi,0FFFFFF90h
    12e: lea     rsi,[k2]
    135: call    ryo_h_AddrAbs
    13a: call    fn3
    13f: nop     [rcx-18h]
    146: mov     qword ptr [rbp-50h],1
    14e: imul    rdx,[rbp-50h],4
    153: mov     [rbp-58h],rdx
    157: mov     edi,10h
    15c: mov     esi,0FFFFFFD0h
    161: mov     edx,0FFFFFFA8h
    166: call    ryo_h_Memmove
    16b: jmp     0C0h
    170: mov     rax,[rbp-20h]
    174: mov     [rbp-38h],rax
    178: mov     rdx,[rbp+18h]
    17c: mov     [rbp-40h],rdx
    180: mov     [rbp-90h],rax
    187: mov     [rbp-88h],rdx
    18e: mov     qword ptr [rbp-80h],4
    196: mov     qword ptr [rbp-78h],4
    19e: mov     qword ptr [rbp-70h],1
    1a6: mov     edi,0FFFFFF98h
    1ab: lea     rsi,[k4]
    1b2: call    ryo_h_AddrAbs
    1b7: call    fn5
    1bc: nop     [rcx-20h]
    1c3: mov     qword ptr [rbp-50h],1
    1cb: imul    rdx,[rbp-50h],4
    1d0: mov     [rbp-58h],rdx
    1d4: mov     edi,18h
    1d9: mov     esi,0FFFFFFD0h
    1de: mov     edx,0FFFFFFA8h
    1e3: call    ryo_h_Memcpy
    1e8: xor     edi,edi
    1ea: xor     esi,esi
    1ec: call    ryo_h_Ret
    1f1: leave
    1f2: ret

fn std::ptr::swap_chunk::<1>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-1],al
     12: mov     rdx,[rbp+18h]
     16: movzx   edx,byte ptr [rdx]
     19: mov     [rbp-2],dl
     1c: mov     rsi,[rbp+10h]
     20: movzx   ecx,byte ptr [rbp-2]
     24: mov     [rsi],cl
     26: mov     rdi,[rbp+18h]
     2a: movzx   ecx,byte ptr [rbp-1]
     2e: mov     [rdi],cl
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
     13: mov     rdx,[rbp+18h]
     17: movzx   edx,word ptr [rdx]
     1a: mov     [rbp-4],dx
     1e: mov     rsi,[rbp+10h]
     22: movzx   ecx,word ptr [rbp-4]
     26: mov     [rsi],cx
     29: mov     rdi,[rbp+18h]
     2d: movzx   ecx,word ptr [rbp-2]
     31: mov     [rdi],cx
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
     11: mov     rdx,[rbp+18h]
     15: mov     edx,[rdx]
     17: mov     [rbp-8],edx
     1a: mov     rsi,[rbp+10h]
     1e: mov     ecx,[rbp-8]
     21: mov     [rsi],ecx
     23: mov     rdi,[rbp+18h]
     27: mov     ecx,[rbp-4]
     2a: mov     [rdi],ecx
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
     13: mov     rdx,[rbp+18h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-10h],rdx
     1e: mov     rsi,[rbp+10h]
     22: mov     rcx,[rbp-10h]
     26: mov     [rsi],rcx
     29: mov     rdi,[rbp+18h]
     2d: mov     rcx,[rbp-8]
     31: mov     [rdi],rcx
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
     13: je      59h
     15: mov     rsi,[rbp+10h]
     19: mov     [rbp-8],rsi
     1d: mov     rdi,[rbp+18h]
     21: mov     [rbp-10h],rdi
     25: mov     [rbp-80h],rsi
     29: mov     [rbp-78h],rdi
     2d: mov     qword ptr [rbp-70h],8
     35: mov     qword ptr [rbp-68h],4
     3d: mov     r10,[rbp+20h]
     41: mov     [rbp-60h],r10
     45: mov     r11,[rbp+28h]
     49: mov     [rbp-58h],r11
     4d: call    fn0
     52: nop     [rcx]
     59: mov     rax,[rbp+10h]
     5d: mov     [rbp-10h],rax
     61: mov     rdx,[rbp+20h]
     65: mov     [rbp-8],rdx
     69: mov     edi,0FFFFFFD8h
     6e: mov     esi,0FFFFFFF0h
     73: call    ryo_h_MovW128
     78: imul    rax,[rbp-20h],8
     7d: mov     [rbp-18h],rax
     81: jmp     0C0h
     83: mov     rax,[rbp-20h]
     87: mov     [rbp-28h],rax
     8b: mov     rdx,[rbp+10h]
     8f: mov     [rbp-38h],rdx
     93: mov     rsi,[rbp+18h]
     97: mov     [rbp-40h],rsi
     9b: mov     [rbp-80h],rdx
     9f: mov     [rbp-78h],rsi
     a3: mov     [rbp-70h],rax
     a7: call    fn1
     ac: nop     [rcx]
     b3: jmp     0B5h
     b5: xor     edi,edi
     b7: xor     esi,esi
     b9: call    ryo_h_Ret
     be: leave
     bf: ret
     c0: mov     rax,[rbp-18h]
     c4: mov     [rbp-20h],rax
     c8: mov     edi,0FFFFFFBCh
     cd: mov     esi,0FFFFFFE0h
     d2: xor     edx,edx
     d4: xor     ecx,ecx
     d6: xor     r8d,r8d
     d9: mov     r9d,1
     df: call    ryo_h_DiscrNicheW64
     e4: mov     edi,0FFFFFFD0h
     e9: mov     esi,0FFFFFFBCh
     ee: call    ryo_h_ZextW32W64
     f3: mov     edi,0FFFFFFD0h
     f8: xor     esi,esi
     fa: mov     edx,2
     ff: call    ryo_h_SwitchDenseW64
    104: lea     rcx,[114h]
    10b: movsxd  rax,[rcx+rax*4]
    10f: add     rax,rcx
    112: jmp     rax
    114: .long   b5h
    118: .long   83h
    11c: .long   120h
    120: call    ryo_h_Unreachable
    125: ud2

fn std::ptr::swap_nonoverlapping::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-41h],1
      f: test    byte ptr [rbp-41h],0FFh
     13: je      59h
     15: mov     rsi,[rbp+10h]
     19: mov     [rbp-8],rsi
     1d: mov     rdi,[rbp+18h]
     21: mov     [rbp-10h],rdi
     25: mov     [rbp-80h],rsi
     29: mov     [rbp-78h],rdi
     2d: mov     qword ptr [rbp-70h],4
     35: mov     qword ptr [rbp-68h],4
     3d: mov     r10,[rbp+20h]
     41: mov     [rbp-60h],r10
     45: mov     r11,[rbp+28h]
     49: mov     [rbp-58h],r11
     4d: call    fn0
     52: nop     [rcx]
     59: mov     rax,[rbp+10h]
     5d: mov     [rbp-10h],rax
     61: mov     rdx,[rbp+20h]
     65: mov     [rbp-8],rdx
     69: mov     edi,0FFFFFFD8h
     6e: mov     esi,0FFFFFFF0h
     73: call    ryo_h_MovW128
     78: imul    rax,[rbp-20h],4
     7d: mov     [rbp-18h],rax
     81: jmp     0C0h
     83: mov     rax,[rbp-20h]
     87: mov     [rbp-28h],rax
     8b: mov     rdx,[rbp+10h]
     8f: mov     [rbp-38h],rdx
     93: mov     rsi,[rbp+18h]
     97: mov     [rbp-40h],rsi
     9b: mov     [rbp-80h],rdx
     9f: mov     [rbp-78h],rsi
     a3: mov     [rbp-70h],rax
     a7: call    fn1
     ac: nop     [rcx]
     b3: jmp     0B5h
     b5: xor     edi,edi
     b7: xor     esi,esi
     b9: call    ryo_h_Ret
     be: leave
     bf: ret
     c0: mov     rax,[rbp-18h]
     c4: mov     [rbp-20h],rax
     c8: mov     edi,0FFFFFFBCh
     cd: mov     esi,0FFFFFFE0h
     d2: xor     edx,edx
     d4: xor     ecx,ecx
     d6: xor     r8d,r8d
     d9: mov     r9d,1
     df: call    ryo_h_DiscrNicheW64
     e4: mov     edi,0FFFFFFD0h
     e9: mov     esi,0FFFFFFBCh
     ee: call    ryo_h_ZextW32W64
     f3: mov     edi,0FFFFFFD0h
     f8: xor     esi,esi
     fa: mov     edx,2
     ff: call    ryo_h_SwitchDenseW64
    104: lea     rcx,[114h]
    10b: movsxd  rax,[rcx+rax*4]
    10f: add     rax,rcx
    112: jmp     rax
    114: .long   b5h
    118: .long   83h
    11c: .long   120h
    120: call    ryo_h_Unreachable
    125: ud2

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
     29: movzx   edx,byte ptr [rbp-1]
     2d: mov     [rbp-33h],dl
     30: mov     [rbp-0B0h],rax
     37: mov     rsi,[rbp+28h]
     3b: mov     [rbp-0A8h],rsi
     42: call    fn0
     47: nop     [rcx-34h]
     4e: jmp     215h
     53: nop     [rax+rax]
     5c: nop     [rax]
     60: mov     rax,[rbp+18h]
     64: mov     [rbp-18h],rax
     68: mov     [rbp-0B0h],rax
     6f: mov     rdx,[rbp+28h]
     73: mov     [rbp-0A8h],rdx
     7a: call    fn1
     7f: nop     [rcx-34h]
     86: jmp     265h
     8b: nop     [rax+rax]
     90: mov     rax,[rbp-10h]
     94: mov     [rbp-0B0h],rax
     9b: mov     rdx,[rbp-18h]
     9f: mov     [rbp-0A8h],rdx
     a6: mov     rsi,[rbp+20h]
     aa: mov     [rbp-0A0h],rsi
     b1: mov     rdi,[rbp+30h]
     b5: mov     [rbp-98h],rdi
     bc: call    fn2
     c1: nop     [rcx-31h]
     c8: jmp     26Dh
     cd: nop     [rax]
     d0: jmp     0E0h
     d2: nop     [rax+rax]
     db: nop     [rax+rax]
     e0: mov     edi,0FFFFFFD8h
     e5: lea     rsi,[k3]
     ec: call    ryo_h_AddrAbs
     f1: mov     qword ptr [rbp-20h],11Bh
     f9: mov     rdx,[rbp-28h]
     fd: mov     [rbp-68h],rdx
    101: mov     rsi,[rbp-20h]
    105: mov     [rbp-60h],rsi
    109: mov     [rbp-58h],rdx
    10d: mov     [rbp-50h],rdx
    111: mov     edi,0FFFFFF80h
    116: lea     rsi,[k4]
    11d: call    ryo_h_AddrAbs
    122: mov     qword ptr [rbp-78h],11Bh
    12a: mov     rdx,[rbp-78h]
    12e: mov     [rbp-70h],rdx
    132: shl     rdx,1
    136: mov     [rbp-68h],rdx
    13a: or      rdx,1
    13e: mov     [rbp-60h],rdx
    142: mov     [rbp-58h],rdx
    146: mov     rsi,[rbp-50h]
    14a: mov     [rbp-48h],rsi
    14e: mov     [rbp-40h],rdx
    152: mov     edi,0FFFFFF50h
    157: mov     esi,0FFFFFFB8h
    15c: call    ryo_h_MovW128
    161: mov     byte ptr [rbp-0A0h],0
    168: mov     rdx,[rbp+38h]
    16c: mov     [rbp-98h],rdx
    173: lea     rdi,[sym5]
    17a: lea     rsi,[site6]
    181: mov     edx,0FFFFFF78h
    186: call    ryo_h_CallExt
    18b: test    rax,rax
    18e: je      19Bh
    190: call    rax
    192: nop     [rcx-28h]
    199: jmp     1ABh
    19b: mov     rdi,rbp
    19e: lea     rsi,[ro+4]
    1a5: call    qword ptr [sym7]
    1ab: call    ryo_h_Unreachable
    1b0: ud2
    1b2: nop     [rax+rax]
    1bb: nop     [rax+rax]
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
    1fa: movzx   esi,byte ptr [rbp-35h]
    1fe: xor     sil,1
    202: mov     [rbp-32h],sil
    206: test    byte ptr [rbp-32h],0FFh
    20a: je      0E0h
    210: jmp     60h
    215: test    byte ptr [rbp-34h],0FFh
    219: je      1E0h
    21b: jmp     1D0h
    21d: nop     [rax]
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
    24a: movzx   esi,byte ptr [rbp-35h]
    24e: xor     sil,1
    252: mov     [rbp-33h],sil
    256: test    byte ptr [rbp-33h],0FFh
    25a: je      0D0h
    260: jmp     90h
    265: test    byte ptr [rbp-34h],0FFh
    269: je      230h
    26b: jmp     220h
    26d: test    byte ptr [rbp-31h],0FFh
    271: je      0E0h
    277: jmp     1C0h
    27c: nop     [rax]
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
     9c: .long   dah
     a0: .long   a8h
     a4: .long   190h
     a8: mov     rax,[rbp-30h]
     ac: mov     [rbp-38h],rax
     b0: mov     rdx,[rbp+10h]
     b4: mov     [rbp-40h],rdx
     b8: mov     rsi,[rbp+18h]
     bc: mov     [rbp-48h],rsi
     c0: mov     [rbp-70h],rdx
     c4: mov     [rbp-68h],rsi
     c8: mov     [rbp-60h],rax
     cc: call    fn0
     d1: nop     [rcx-8]
     d8: jmp     0DAh
     da: mov     rax,[rbp-28h]
     de: mov     [rbp-30h],rax
     e2: mov     edi,0FFFFFFACh
     e7: mov     esi,0FFFFFFD0h
     ec: xor     edx,edx
     ee: xor     ecx,ecx
     f0: xor     r8d,r8d
     f3: mov     r9d,1
     f9: call    ryo_h_DiscrNicheW64
     fe: mov     edi,0FFFFFFF0h
    103: mov     esi,0FFFFFFACh
    108: call    ryo_h_ZextW32W64
    10d: mov     edi,0FFFFFFF0h
    112: xor     esi,esi
    114: mov     edx,2
    119: call    ryo_h_SwitchDenseW64
    11e: lea     rcx,[130h]
    125: movsxd  rax,[rcx+rax*4]
    129: add     rax,rcx
    12c: jmp     rax
    12e: int3
    12f: int3
    130: .long   185h
    134: .long   13ch
    138: .long   190h
    13c: mov     rax,[rbp-30h]
    140: mov     [rbp-38h],rax
    144: imul    rdx,[rbp-20h],8
    149: mov     [rbp-40h],rdx
    14d: mov     rsi,[rbp+10h]
    151: imul    rcx,rdx,1
    155: add     rsi,rcx
    158: mov     [rbp-48h],rsi
    15c: mov     rdi,[rbp+18h]
    160: imul    rcx,rdx,1
    164: add     rdi,rcx
    167: mov     [rbp-50h],rdi
    16b: mov     [rbp-70h],rsi
    16f: mov     [rbp-68h],rdi
    173: mov     [rbp-60h],rax
    177: call    fn1
    17c: nop     [rcx-10h]
    183: jmp     185h
    185: xor     edi,edi
    187: xor     esi,esi
    189: call    ryo_h_Ret
    18e: leave
    18f: ret
    190: call    ryo_h_Unreachable
    195: ud2

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
     28: mov     rdx,[rbp-8]
     2c: mov     [rbp-58h],rdx
     30: cmp     rax,rdx
     33: setb    [rbp-41h]
     37: test    byte ptr [rbp-41h],0FFh
     3b: je      56h
     3d: jmp     42h
     3f: nop
     40: jmp     20h
     42: mov     rax,[rbp-10h]
     46: mov     [rbp-50h],rax
     4a: mov     byte ptr [rbp-69h],1
     4e: test    byte ptr [rbp-69h],0FFh
     52: je      94h
     54: jmp     61h
     56: xor     edi,edi
     58: xor     esi,esi
     5a: call    ryo_h_Ret
     5f: leave
     60: ret
     61: mov     rax,[rbp-50h]
     65: mov     [rbp-90h],rax
     6c: mov     qword ptr [rbp-88h],1
     77: mov     edi,0FFFFFF80h
     7c: lea     rsi,[k0]
     83: call    ryo_h_AddrAbs
     88: call    fn1
     8d: nop     [rcx-28h]
     94: mov     rax,[rbp-50h]
     98: add     rax,1
     9c: mov     [rbp-58h],rax
     a0: mov     [rbp-10h],rax
     a4: mov     rdx,[rbp-50h]
     a8: mov     [rbp-38h],rdx
     ac: mov     qword ptr [rbp-40h],1
     b4: mov     [rbp-48h],rdx
     b8: mov     rdi,[rbp+10h]
     bc: imul    rcx,rdx,8
     c0: add     rdi,rcx
     c3: mov     [rbp-58h],rdi
     c7: mov     [rbp-50h],rdi
     cb: mov     r8,[rbp+18h]
     cf: imul    rcx,rdx,8
     d3: add     r8,rcx
     d6: mov     [rbp-68h],r8
     da: mov     [rbp-60h],r8
     de: mov     [rbp-90h],rdi
     e5: mov     [rbp-88h],r8
     ec: call    fn2
     f1: nop     [rcx-18h]
     f8: jmp     40h

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
     24: je      86h
     26: mov     rdi,[rbp-28h]
     2a: mov     [rbp-48h],rdi
     2e: mov     r8,[rbp+10h]
     32: imul    rcx,rdi,1
     36: add     r8,rcx
     39: mov     [rbp-40h],r8
     3d: mov     [rbp-38h],r8
     41: mov     [rbp-30h],r8
     45: mov     r9,[rbp-28h]
     49: mov     [rbp-58h],r9
     4d: mov     r10,[rbp+18h]
     51: imul    rcx,r9,1
     55: add     r10,rcx
     58: mov     [rbp-50h],r10
     5c: mov     [rbp-48h],r10
     60: mov     [rbp-40h],r10
     64: mov     [rbp-70h],r8
     68: mov     [rbp-68h],r10
     6c: call    fn0
     71: nop     [rcx]
     78: mov     rax,[rbp-28h]
     7c: or      rax,4
     80: mov     [rbp-28h],rax
     84: jmp     86h
     86: mov     rax,[rbp-20h]
     8a: and     rax,2
     8e: mov     [rbp-30h],rax
     92: cmp     rax,0
     96: je      0F8h
     98: mov     rsi,[rbp-28h]
     9c: mov     [rbp-48h],rsi
     a0: mov     rdi,[rbp+10h]
     a4: imul    rcx,rsi,1
     a8: add     rdi,rcx
     ab: mov     [rbp-40h],rdi
     af: mov     [rbp-38h],rdi
     b3: mov     [rbp-30h],rdi
     b7: mov     r8,[rbp-28h]
     bb: mov     [rbp-58h],r8
     bf: mov     r9,[rbp+18h]
     c3: imul    rcx,r8,1
     c7: add     r9,rcx
     ca: mov     [rbp-50h],r9
     ce: mov     [rbp-48h],r9
     d2: mov     [rbp-40h],r9
     d6: mov     [rbp-70h],rdi
     da: mov     [rbp-68h],r9
     de: call    fn1
     e3: nop     [rcx]
     ea: mov     rax,[rbp-28h]
     ee: or      rax,2
     f2: mov     [rbp-28h],rax
     f6: jmp     0F8h
     f8: mov     rax,[rbp-20h]
     fc: and     rax,1
    100: mov     [rbp-30h],rax
    104: cmp     rax,0
    108: je      16Ah
    10a: mov     rsi,[rbp-28h]
    10e: mov     [rbp-48h],rsi
    112: mov     rdi,[rbp+10h]
    116: imul    rcx,rsi,1
    11a: add     rdi,rcx
    11d: mov     [rbp-40h],rdi
    121: mov     [rbp-38h],rdi
    125: mov     [rbp-30h],rdi
    129: mov     r8,[rbp-28h]
    12d: mov     [rbp-58h],r8
    131: mov     r9,[rbp+18h]
    135: imul    rcx,r8,1
    139: add     r9,rcx
    13c: mov     [rbp-50h],r9
    140: mov     [rbp-48h],r9
    144: mov     [rbp-40h],r9
    148: mov     [rbp-70h],rdi
    14c: mov     [rbp-68h],r9
    150: call    fn2
    155: nop     [rcx]
    15c: mov     rax,[rbp-28h]
    160: or      rax,1
    164: mov     [rbp-28h],rax
    168: jmp     16Ah
    16a: xor     edi,edi
    16c: xor     esi,esi
    16e: call    ryo_h_Ret
    173: leave
    174: ret

fn std::rt::lang_start::<()>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rdx,[rbp-28h]
     14: mov     [rbp-20h],rdx
     18: mov     [rbp-18h],rdx
     1c: mov     edi,0FFFFFFF0h
     21: lea     rsi,[k0]
     28: call    ryo_h_AddrAbs
     2d: mov     edi,0FFFFFFA0h
     32: mov     esi,0FFFFFFE8h
     37: call    ryo_h_MovW128
     3c: mov     rax,[rbp+18h]
     40: mov     [rbp-50h],rax
     44: mov     rdx,[rbp+20h]
     48: mov     [rbp-48h],rdx
     4c: movzx   esi,byte ptr [rbp+28h]
     50: mov     [rbp-40h],sil
     54: lea     rdi,[sym1]
     5b: lea     rsi,[site2]
     62: mov     edx,0FFFFFFD0h
     67: call    ryo_h_CallExt
     6c: test    rax,rax
     6f: je      7Ch
     71: call    rax
     73: nop     [rcx-8]
     7a: jmp     8Ch
     7c: mov     rdi,rbp
     7f: lea     rsi,[ro+4]
     86: call    qword ptr [sym3]
     8c: mov     edi,0FFFFFFF8h
     91: mov     esi,8
     96: call    ryo_h_Ret
     9b: leave
     9c: ret

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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-38h],rdx
     1b: mov     [rbp-50h],rax
     1f: mov     [rbp-48h],rdx
     23: call    fn0
     28: nop     [rcx-2Ch]
     2f: lea     rax,[rbp-2Ch]
     33: mov     [rbp-28h],rax
     37: mov     rdx,[rbp+10h]
     3b: mov     rdx,[rdx]
     3e: mov     [rbp-18h],rdx
     42: mov     rsi,[rbp+20h]
     46: mov     [rbp-40h],rsi
     4a: mov     [rbp-50h],rdx
     4e: mov     [rbp-48h],rsi
     52: call    fn1
     57: nop     [rcx-30h]
     5e: lea     rax,[rbp-30h]
     62: mov     [rbp-38h],rax
     66: mov     rdx,[rbp-28h]
     6a: mov     [rbp-50h],rdx
     6e: mov     [rbp-48h],rax
     72: call    fn2
     77: nop     [rcx-1]
     7e: mov     edi,0FFFFFFFFh
     83: mov     esi,1
     88: call    ryo_h_Ret
     8d: leave
     8e: ret
     8f: nop
     90: mov     edi,0FFFFFFE0h
     95: call    ryo_h_Resume
     9a: ud2
     9c: mov     rdi,rax
     9f: mov     esi,0FFFFFFE0h
     a4: call    ryo_h_Lpad
     a9: jmp     90h
     ab: mov     rdi,rax
     ae: mov     esi,0FFFFFFE0h
     b3: call    ryo_h_Lpad
     b8: jmp     90h

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::as_uninit_slice_mut
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-40h],rax
     17: mov     [rbp-38h],rax
     1b: mov     rdx,[rbp+10h]
     1f: mov     rdx,[rdx+10h]
     23: mov     [rbp-40h],rdx
     27: imul    rcx,rdx,8
     2b: add     rax,rcx
     2e: mov     [rbp-30h],rax
     32: mov     [rbp-28h],rax
     36: mov     qword ptr [rbp-50h],8
     3e: cmp     qword ptr [rbp-50h],0
     43: je      73h
     45: jmp     7Dh
     47: nop     [rax+rax]
     50: mov     rax,[rbp+10h]
     54: mov     rax,[rax+10h]
     58: mov     [rbp-48h],rax
     5c: mov     rdx,[rbp-40h]
     60: sub     rdx,rax
     63: mov     [rbp-38h],rdx
     67: mov     byte ptr [rbp-49h],1
     6b: test    byte ptr [rbp-49h],0FFh
     6f: je      0CFh
     71: jmp     8Eh
     73: mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
     7b: jmp     50h
     7d: mov     rax,[rbp+10h]
     81: mov     rax,[rax]
     84: mov     [rbp-48h],rax
     88: mov     [rbp-40h],rax
     8c: jmp     50h
     8e: mov     rax,[rbp-30h]
     92: mov     [rbp-40h],rax
     96: mov     [rbp-80h],rax
     9a: mov     qword ptr [rbp-78h],8
     a2: mov     qword ptr [rbp-70h],4
     aa: mov     rdi,[rbp-38h]
     ae: mov     [rbp-68h],rdi
     b2: mov     edi,0FFFFFFA0h
     b7: lea     rsi,[k0]
     be: call    ryo_h_AddrAbs
     c3: call    fn1
     c8: nop     [rcx-20h]
     cf: mov     rax,[rbp-30h]
     d3: mov     [rbp-48h],rax
     d7: mov     rdx,[rbp-38h]
     db: mov     [rbp-40h],rdx
     df: mov     [rbp-10h],rax
     e3: mov     [rbp-8],rdx
     e7: mov     edi,0FFFFFFF0h
     ec: mov     esi,10h
     f1: call    ryo_h_Ret
     f6: leave
     f7: ret

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
     24: mov     rdi,[rbp+10h]
     28: mov     rdi,[rdi+8]
     2c: mov     [rbp-30h],rdi
     30: mov     [rbp-20h],rdi
     34: jmp     70h
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax+8]
     3e: mov     [rbp-38h],rax
     42: mov     [rbp-30h],rax
     46: mov     rdx,[rbp+10h]
     4a: mov     rdx,[rdx]
     4d: mov     [rbp-38h],rdx
     51: mov     [rbp-40h],rax
     55: mov     [rbp-48h],rdx
     59: mov     rsi,[rbp-30h]
     5d: mov     [rbp-50h],rsi
     61: mov     byte ptr [rbp-61h],1
     65: test    byte ptr [rbp-61h],0FFh
     69: je      0CDh
     6b: jmp     92h
     6d: nop     [rax]
     70: mov     byte ptr [rbp-61h],1
     74: test    byte ptr [rbp-61h],0FFh
     78: je      1E7h
     7e: jmp     1A0h
     83: nop     [rax+rax]
     8c: nop     [rax]
     90: jmp     70h
     92: mov     rax,[rbp-30h]
     96: mov     [rbp-58h],rax
     9a: mov     rdx,[rbp-38h]
     9e: mov     [rbp-60h],rdx
     a2: mov     [rbp-90h],rax
     a9: mov     [rbp-88h],rdx
     b0: mov     edi,0FFFFFF80h
     b5: lea     rsi,[k0]
     bc: call    ryo_h_AddrAbs
     c1: call    fn1
     c6: nop     [rcx-20h]
     cd: mov     qword ptr [rbp-68h],0
     d5: cmp     qword ptr [rbp-68h],4
     da: setb    [rbp-51h]
     de: test    byte ptr [rbp-51h],0FFh
     e2: je      134h
     e4: mov     qword ptr [rbp-68h],4
     ec: mov     r8,[rbp-68h]
     f0: mov     rcx,7FFFFFFFFFFFFFFFh
     fa: cmp     r8,rcx
     fd: setbe   [rbp-52h]
    101: test    byte ptr [rbp-52h],0FFh
    105: je      134h
    107: mov     r10,[rbp-50h]
    10b: sub     r10,[rbp-48h]
    10f: mov     [rbp-20h],r10
    113: mov     qword ptr [rbp-68h],4
    11b: mov     edi,0FFFFFFE0h
    120: mov     esi,0FFFFFFE0h
    125: mov     edx,0FFFFFF98h
    12a: call    ryo_h_DivUW64
    12f: jmp     90h
    134: mov     edi,0FFFFFF70h
    139: lea     rsi,[k2]
    140: call    ryo_h_AddrAbs
    145: mov     qword ptr [rbp-88h],49h
    150: mov     edi,0FFFFFF80h
    155: lea     rsi,[k3]
    15c: call    ryo_h_AddrAbs
    161: lea     rdi,[sym4]
    168: lea     rsi,[site5]
    16f: mov     edx,0FFFFFF98h
    174: call    ryo_h_CallExt
    179: test    rax,rax
    17c: je      189h
    17e: call    rax
    180: nop     [rcx-20h]
    187: jmp     199h
    189: mov     rdi,rbp
    18c: lea     rsi,[ro+4]
    193: call    qword ptr [sym6]
    199: call    ryo_h_Unreachable
    19e: ud2
    1a0: mov     rax,[rbp-18h]
    1a4: mov     [rbp-30h],rax
    1a8: mov     [rbp-90h],rax
    1af: mov     qword ptr [rbp-88h],4
    1ba: mov     qword ptr [rbp-80h],4
    1c2: mov     rdi,[rbp-20h]
    1c6: mov     [rbp-78h],rdi
    1ca: mov     edi,0FFFFFF90h
    1cf: lea     rsi,[k7]
    1d6: call    ryo_h_AddrAbs
    1db: call    fn8
    1e0: nop     [rcx-20h]
    1e7: mov     rax,[rbp-28h]
    1eb: mov     [rbp-38h],rax
    1ef: mov     rdx,[rbp-20h]
    1f3: mov     [rbp-30h],rdx
    1f7: mov     [rbp-10h],rax
    1fb: mov     [rbp-8],rdx
    1ff: mov     edi,0FFFFFFF0h
    204: mov     esi,10h
    209: call    ryo_h_Ret
    20e: leave
    20f: ret

fn std::slice::Iter::<'_, u32>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-20h],rax
     10: mov     rdx,[rbp+10h]
     14: mov     [rbp-48h],rdx
     18: mov     rsi,[rbp+18h]
     1c: mov     [rbp-40h],rsi
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
     54: mov     rdi,[rbp-20h]
     58: mov     [rbp-18h],rdi
     5c: jmp     76h
     5e: mov     rax,[rbp-28h]
     62: mov     [rbp-38h],rax
     66: imul    rcx,[rbp-20h],4
     6b: add     rax,rcx
     6e: mov     [rbp-30h],rax
     72: mov     [rbp-18h],rax
     76: mov     rax,[rbp-28h]
     7a: mov     [rbp-10h],rax
     7e: mov     rdx,[rbp-18h]
     82: mov     [rbp-8],rdx
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
     1a: mov     rdx,[rbp+20h]
     1e: mov     [rbp-88h],rdx
     25: call    fn0
     2a: nop     [rcx-1Ah]
     31: jmp     175h
     36: nop     [rax+rax]
     3f: nop
     40: cmp     qword ptr [rbp+18h],0
     45: je      17Dh
     4b: jmp     187h
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
     89: mov     rdx,[rbp-10h]
     8d: mov     [rbp-50h],rdx
     91: mov     rsi,[rbp-8]
     95: mov     [rbp-48h],rsi
     99: mov     [rbp-40h],rdx
     9d: mov     [rbp-38h],rdx
     a1: mov     edi,0FFFFFF98h
     a6: lea     rsi,[k2]
     ad: call    ryo_h_AddrAbs
     b2: mov     qword ptr [rbp-60h],117h
     ba: mov     rdx,[rbp-60h]
     be: mov     [rbp-58h],rdx
     c2: shl     rdx,1
     c6: mov     [rbp-50h],rdx
     ca: or      rdx,1
     ce: mov     [rbp-48h],rdx
     d2: mov     [rbp-40h],rdx
     d6: mov     rsi,[rbp-38h]
     da: mov     [rbp-30h],rsi
     de: mov     [rbp-28h],rdx
     e2: mov     edi,0FFFFFF70h
     e7: mov     esi,0FFFFFFD0h
     ec: call    ryo_h_MovW128
     f1: mov     byte ptr [rbp-80h],0
     f5: mov     rdx,[rbp+30h]
     f9: mov     [rbp-78h],rdx
     fd: lea     rdi,[sym3]
    104: lea     rsi,[site4]
    10b: mov     edx,0FFFFFF90h
    110: call    ryo_h_CallExt
    115: test    rax,rax
    118: je      125h
    11a: call    rax
    11c: nop     [rcx-10h]
    123: jmp     135h
    125: mov     rdi,rbp
    128: lea     rsi,[ro+4]
    12f: call    qword ptr [sym5]
    135: call    ryo_h_Unreachable
    13a: ud2
    13c: nop     [rax]
    140: mov     rax,[rbp+10h]
    144: mov     [rbp-30h],rax
    148: cmp     rax,0
    14c: sete    [rbp-1Bh]
    150: movzx   esi,byte ptr [rbp-1Bh]
    154: xor     sil,1
    158: mov     [rbp-19h],sil
    15c: test    byte ptr [rbp-19h],0FFh
    160: je      70h
    166: jmp     40h
    16b: nop     [rax+rax]
    170: jmp     70h
    175: test    byte ptr [rbp-1Ah],0FFh
    179: je      170h
    17b: jmp     140h
    17d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    185: jmp     1A9h
    187: mov     rax,7FFFFFFFFFFFFFFFh
    191: mov     [rbp-70h],rax
    195: mov     edi,0FFFFFFD8h
    19a: mov     esi,0FFFFFF90h
    19f: mov     edx,18h
    1a4: call    ryo_h_DivUW64
    1a9: mov     rax,[rbp+28h]
    1ad: cmp     rax,[rbp-28h]
    1b1: setbe   [rbp-1Ah]
    1b5: test    byte ptr [rbp-1Ah],0FFh
    1b9: je      60h
    1bf: jmp     50h
    1c4: nop     [rax+rax]
    1cd: nop     [rax]
    1d0: lea     rdi,[sym6]
    1d7: lea     rsi,[site7]
    1de: mov     edx,0FFFFFF90h
    1e3: call    ryo_h_CallExt
    1e8: test    rax,rax
    1eb: je      1F8h
    1ed: call    rax
    1ef: nop     [rcx-68h]
    1f6: jmp     208h
    1f8: mov     rdi,rbp
    1fb: lea     rsi,[ro+20]
    202: call    qword ptr [sym8]
    208: call    ryo_h_Unreachable
    20d: ud2
    20f: mov     rdi,rax
    212: mov     esi,0FFFFFFE8h
    217: call    ryo_h_Lpad
    21c: jmp     1D0h

fn std::slice::from_raw_parts_mut::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-28h],rax
     13: mov     [rbp-90h],rax
     1a: mov     rdx,[rbp+20h]
     1e: mov     [rbp-88h],rdx
     25: call    fn0
     2a: nop     [rcx-1Ah]
     31: jmp     175h
     36: nop     [rax+rax]
     3f: nop
     40: cmp     qword ptr [rbp+18h],0
     45: je      17Dh
     4b: jmp     187h
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
     89: mov     rdx,[rbp-10h]
     8d: mov     [rbp-50h],rdx
     91: mov     rsi,[rbp-8]
     95: mov     [rbp-48h],rsi
     99: mov     [rbp-40h],rdx
     9d: mov     [rbp-38h],rdx
     a1: mov     edi,0FFFFFF98h
     a6: lea     rsi,[k2]
     ad: call    ryo_h_AddrAbs
     b2: mov     qword ptr [rbp-60h],11Bh
     ba: mov     rdx,[rbp-60h]
     be: mov     [rbp-58h],rdx
     c2: shl     rdx,1
     c6: mov     [rbp-50h],rdx
     ca: or      rdx,1
     ce: mov     [rbp-48h],rdx
     d2: mov     [rbp-40h],rdx
     d6: mov     rsi,[rbp-38h]
     da: mov     [rbp-30h],rsi
     de: mov     [rbp-28h],rdx
     e2: mov     edi,0FFFFFF70h
     e7: mov     esi,0FFFFFFD0h
     ec: call    ryo_h_MovW128
     f1: mov     byte ptr [rbp-80h],0
     f5: mov     rdx,[rbp+30h]
     f9: mov     [rbp-78h],rdx
     fd: lea     rdi,[sym3]
    104: lea     rsi,[site4]
    10b: mov     edx,0FFFFFF90h
    110: call    ryo_h_CallExt
    115: test    rax,rax
    118: je      125h
    11a: call    rax
    11c: nop     [rcx-10h]
    123: jmp     135h
    125: mov     rdi,rbp
    128: lea     rsi,[ro+4]
    12f: call    qword ptr [sym5]
    135: call    ryo_h_Unreachable
    13a: ud2
    13c: nop     [rax]
    140: mov     rax,[rbp+10h]
    144: mov     [rbp-30h],rax
    148: cmp     rax,0
    14c: sete    [rbp-1Bh]
    150: movzx   esi,byte ptr [rbp-1Bh]
    154: xor     sil,1
    158: mov     [rbp-19h],sil
    15c: test    byte ptr [rbp-19h],0FFh
    160: je      70h
    166: jmp     40h
    16b: nop     [rax+rax]
    170: jmp     70h
    175: test    byte ptr [rbp-1Ah],0FFh
    179: je      170h
    17b: jmp     140h
    17d: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    185: jmp     1A9h
    187: mov     rax,7FFFFFFFFFFFFFFFh
    191: mov     [rbp-70h],rax
    195: mov     edi,0FFFFFFD8h
    19a: mov     esi,0FFFFFF90h
    19f: mov     edx,18h
    1a4: call    ryo_h_DivUW64
    1a9: mov     rax,[rbp+28h]
    1ad: cmp     rax,[rbp-28h]
    1b1: setbe   [rbp-1Ah]
    1b5: test    byte ptr [rbp-1Ah],0FFh
    1b9: je      60h
    1bf: jmp     50h
    1c4: nop     [rax+rax]
    1cd: nop     [rax]
    1d0: lea     rdi,[sym6]
    1d7: lea     rsi,[site7]
    1de: mov     edx,0FFFFFF90h
    1e3: call    ryo_h_CallExt
    1e8: test    rax,rax
    1eb: je      1F8h
    1ed: call    rax
    1ef: nop     [rcx-68h]
    1f6: jmp     208h
    1f8: mov     rdi,rbp
    1fb: lea     rsi,[ro+20]
    202: call    qword ptr [sym8]
    208: call    ryo_h_Unreachable
    20d: ud2
    20f: mov     rdi,rax
    212: mov     esi,0FFFFFFE8h
    217: call    ryo_h_Lpad
    21c: jmp     1D0h

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
     9a: mov     rdx,[rbp-10h]
     9e: mov     [rbp-28h],rdx
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
      f: lea     rdx,[rbp+18h]
     13: mov     [rbp-68h],rdx
     17: mov     [rbp-100h],rdx
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
     70: .long   150h
     74: .long   7ch
     78: .long   278h
     7c: mov     rax,[rbp-70h]
     80: mov     [rbp-80h],rax
     84: mov     rdx,[rbp+10h]
     88: mov     [rbp-100h],rdx
     8f: mov     [rbp-0F8h],rax
     96: call    fn1
     9b: nop     [rcx-48h]
     a2: mov     rax,[rbp+10h]
     a6: mov     rax,[rax+8]
     aa: mov     [rbp-90h],rax
     b1: mov     [rbp-88h],rax
     b8: mov     rdx,[rbp+10h]
     bc: lea     rdx,[rdx+10h]
     c0: mov     [rbp-0A0h],rdx
     c7: mov     rdx,[rdx]
     ca: mov     [rbp-0A8h],rdx
     d1: mov     rsi,[rbp-0A0h]
     d8: mov     [rbp-98h],rsi
     df: mov     [rbp-90h],rdx
     e6: mov     byte ptr [rbp-49h],0
     ea: mov     edi,0FFFFFF58h
     ef: mov     esi,18h
     f4: call    ryo_h_MovW128
     f9: mov     rax,[rbp-88h]
    100: mov     [rbp-0B0h],rax
    107: mov     edi,0FFFFFF40h
    10c: mov     esi,0FFFFFF68h
    111: call    ryo_h_MovW128
    116: mov     edi,0FFFFFF00h
    11b: mov     esi,0FFFFFF58h
    120: call    ryo_h_MovW128
    125: mov     edi,0FFFFFF10h
    12a: mov     esi,0FFFFFF40h
    12f: mov     edx,18h
    134: call    ryo_h_Copy
    139: call    fn2
    13e: nop     [rcx-48h]
    145: xor     edi,edi
    147: xor     esi,esi
    149: call    ryo_h_Ret
    14e: leave
    14f: ret
    150: mov     edi,0FFFFFF68h
    155: lea     rsi,[k3]
    15c: call    ryo_h_AddrAbs
    161: mov     qword ptr [rbp-90h],11h
    16c: mov     rdx,[rbp-98h]
    173: mov     [rbp-0B8h],rdx
    17a: mov     rsi,[rbp-90h]
    181: mov     [rbp-0B0h],rsi
    188: mov     [rbp-0A8h],rdx
    18f: mov     [rbp-0A0h],rdx
    196: mov     edi,0FFFFFF30h
    19b: lea     rsi,[k4]
    1a2: call    ryo_h_AddrAbs
    1a7: mov     qword ptr [rbp-0C8h],11h
    1b2: mov     rdx,[rbp-0C8h]
    1b9: mov     [rbp-0C0h],rdx
    1c0: shl     rdx,1
    1c4: mov     [rbp-0B8h],rdx
    1cb: or      rdx,1
    1cf: mov     [rbp-0B0h],rdx
    1d6: mov     [rbp-0A8h],rdx
    1dd: mov     rsi,[rbp-0A0h]
    1e4: mov     [rbp-88h],rsi
    1eb: mov     [rbp-80h],rdx
    1ef: mov     edi,0FFFFFF00h
    1f4: mov     esi,0FFFFFF78h
    1f9: call    ryo_h_MovW128
    1fe: mov     edi,0FFFFFF10h
    203: lea     rsi,[k5]
    20a: call    ryo_h_AddrAbs
    20f: lea     rdi,[sym6]
    216: lea     rsi,[site7]
    21d: mov     edx,0FFFFFF28h
    222: call    ryo_h_CallExt
    227: test    rax,rax
    22a: je      237h
    22c: call    rax
    22e: nop     [rcx-48h]
    235: jmp     247h
    237: mov     rdi,rbp
    23a: lea     rsi,[ro+4]
    241: call    qword ptr [sym8]
    247: call    ryo_h_Unreachable
    24c: ud2
    24e: xchg    ax,ax
    250: mov     edi,0FFFFFFA0h
    255: call    ryo_h_Resume
    25a: ud2
    25c: nop     [rax]
    260: jmp     250h
    262: nop     [rax+rax]
    26b: nop     [rax+rax]
    270: test    byte ptr [rbp-49h],0FFh
    274: je      250h
    276: jmp     260h
    278: call    ryo_h_Unreachable
    27d: ud2
    27f: mov     rdi,rax
    282: mov     esi,0FFFFFFA0h
    287: call    ryo_h_Lpad
    28c: jmp     270h

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-10h],rax
     14: mov     rdx,[rbp+10h]
     18: mov     rdx,[rdx+8]
     1c: mov     [rbp-18h],rdx
     20: imul    rcx,rdx,8
     24: add     rax,rcx
     27: mov     [rbp-8],rax
     2b: mov     rcx,[rbp+18h]
     2f: mov     [rax],rcx
     32: mov     rsi,[rbp+10h]
     36: mov     rsi,[rsi+8]
     3a: mov     [rbp-20h],rsi
     3e: add     rsi,1
     42: mov     [rbp-30h],rsi
     46: mov     rdi,[rbp+10h]
     4a: mov     rcx,[rbp-30h]
     4e: mov     [rdi+8],rcx
     52: xor     edi,edi
     54: xor     esi,esi
     56: call    ryo_h_Ret
     5b: leave
     5c: ret

fn std::vec::Vec::<(u32, u32)>::reserve
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+10h]
     13: mov     [rbp-18h],rax
     17: mov     rdx,[rbp+10h]
     1b: mov     [rbp-20h],rdx
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
     5b: mov     rdx,[rbp-18h]
     5f: mov     [rbp-88h],rdx
     66: mov     rsi,[rbp+18h]
     6a: mov     [rbp-80h],rsi
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
     39: mov     rdx,[rbp-10h]
     3d: mov     [rbp-48h],rdx
     41: mov     rsi,[rbp-8]
     45: mov     [rbp-40h],rsi
     49: mov     [rbp-38h],rdx
     4d: mov     [rbp-30h],rdx
     51: mov     edi,0FFFFFFA0h
     56: lea     rsi,[k1]
     5d: call    ryo_h_AddrAbs
     62: mov     qword ptr [rbp-58h],0C6h
     6a: mov     rdx,[rbp-58h]
     6e: mov     [rbp-50h],rdx
     72: shl     rdx,1
     76: mov     [rbp-48h],rdx
     7a: or      rdx,1
     7e: mov     [rbp-40h],rdx
     82: mov     [rbp-38h],rdx
     86: mov     rsi,[rbp-30h]
     8a: mov     [rbp-28h],rsi
     8e: mov     [rbp-20h],rdx
     92: mov     edi,0FFFFFF70h
     97: mov     esi,0FFFFFFD8h
     9c: call    ryo_h_MovW128
     a1: mov     byte ptr [rbp-80h],0
     a5: mov     rdx,[rbp+20h]
     a9: mov     [rbp-78h],rdx
     ad: lea     rdi,[sym2]
     b4: lea     rsi,[site3]
     bb: mov     edx,0FFFFFF98h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-10h]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+4]
     df: call    qword ptr [sym4]
     e5: call    ryo_h_Unreachable
     ea: ud2

fn std::vec::Vec::<u32>::append_elements
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-8],rax
     13: mov     rdx,[rbp+10h]
     17: mov     [rbp-80h],rdx
     1b: mov     [rbp-78h],rax
     1f: call    fn0
     24: nop     [rcx]
     2b: mov     rax,[rbp+10h]
     2f: mov     rax,[rax+10h]
     33: mov     [rbp-10h],rax
     37: mov     rcx,1FFFFFFFFFFFFFFFh
     41: cmp     rax,rcx
     44: setbe   [rbp-11h]
     48: cmp     qword ptr [rbp-8],0
     4d: jbe     80h
     4f: mov     rsi,[rbp+18h]
     53: mov     [rbp-20h],rsi
     57: mov     rdi,[rbp+10h]
     5b: mov     rdi,[rdi+8]
     5f: mov     [rbp-38h],rdi
     63: mov     [rbp-30h],rdi
     67: imul    rcx,rax,4
     6b: add     rdi,rcx
     6e: mov     [rbp-28h],rdi
     72: mov     byte ptr [rbp-39h],1
     76: test    byte ptr [rbp-39h],0FFh
     7a: je      0F8h
     7c: jmp     0ABh
     7e: xchg    ax,ax
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax+10h]
     88: mov     [rbp-40h],rax
     8c: add     rax,[rbp-8]
     90: mov     [rbp-50h],rax
     94: mov     rdx,[rbp+10h]
     98: mov     rcx,[rbp-50h]
     9c: mov     [rdx+10h],rcx
     a0: xor     edi,edi
     a2: xor     esi,esi
     a4: call    ryo_h_Ret
     a9: leave
     aa: ret
     ab: mov     rax,[rbp+18h]
     af: mov     [rbp-30h],rax
     b3: mov     rdx,[rbp-28h]
     b7: mov     [rbp-38h],rdx
     bb: mov     [rbp-80h],rax
     bf: mov     [rbp-78h],rdx
     c3: mov     qword ptr [rbp-70h],4
     cb: mov     qword ptr [rbp-68h],4
     d3: mov     r8,[rbp-8]
     d7: mov     [rbp-60h],r8
     db: mov     edi,0FFFFFFA8h
     e0: lea     rsi,[k1]
     e7: call    ryo_h_AddrAbs
     ec: call    fn2
     f1: nop     [rcx-8]
     f8: imul    rax,[rbp-8],4
     fd: mov     [rbp-40h],rax
    101: mov     edi,0FFFFFFD8h
    106: mov     esi,0FFFFFFE0h
    10b: mov     edx,0FFFFFFC0h
    110: call    ryo_h_Memcpy
    115: jmp     80h

fn std::vec::Vec::<u32>::clear
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-20h],rax
     14: mov     [rbp-18h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-20h],rdx
     24: mov     [rbp-10h],rax
     28: mov     [rbp-8],rdx
     2c: mov     qword ptr [rbp-30h],0
     34: mov     rdi,[rbp+10h]
     38: mov     rcx,[rbp-30h]
     3c: mov     [rdi+10h],rcx
     40: mov     r8,[rbp-10h]
     44: mov     [rbp-20h],r8
     48: mov     r9,[rbp-8]
     4c: mov     [rbp-18h],r9
     50: mov     edi,0FFFFFFC0h
     55: mov     esi,0FFFFFFE0h
     5a: call    ryo_h_MovW128
     5f: mov     edi,0FFFFFFD8h
     64: lea     rsi,[sym0]
     6b: call    ryo_h_AddrSym
     70: mov     rdi,rbp
     73: lea     rsi,[ro+4]
     7a: call    qword ptr [sym1]
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret

fn std::vec::Vec::<u32>::extend_from_slice
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-48h],rdx
     18: mov     rsi,[rbp+20h]
     1c: mov     [rbp-40h],rsi
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
     95: mov     rdx,[rbp-38h]
     99: mov     [rbp-8],rdx
     9d: mov     rsi,[rbp+10h]
     a1: mov     [rbp-70h],rsi
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
      f: lea     rdx,[rbp+18h]
     13: mov     [rbp-68h],rdx
     17: mov     [rbp-110h],rdx
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
     70: .long   15ah
     74: .long   7ch
     78: .long   288h
     7c: mov     rax,[rbp-70h]
     80: mov     [rbp-80h],rax
     84: mov     rdx,[rbp+10h]
     88: mov     [rbp-110h],rdx
     8f: mov     [rbp-108h],rax
     96: call    fn1
     9b: nop     [rcx-48h]
     a2: mov     rax,[rbp+10h]
     a6: mov     rax,[rax+8]
     aa: mov     [rbp-90h],rax
     b1: mov     [rbp-88h],rax
     b8: mov     rdx,[rbp+10h]
     bc: lea     rdx,[rdx+10h]
     c0: mov     [rbp-0A0h],rdx
     c7: mov     rdx,[rdx]
     ca: mov     [rbp-0A8h],rdx
     d1: mov     rsi,[rbp-0A0h]
     d8: mov     [rbp-98h],rsi
     df: mov     [rbp-90h],rdx
     e6: mov     byte ptr [rbp-49h],0
     ea: mov     edi,0FFFFFF50h
     ef: mov     esi,18h
     f4: mov     edx,18h
     f9: call    ryo_h_Copy
     fe: mov     rax,[rbp-88h]
    105: mov     [rbp-0B8h],rax
    10c: mov     edi,0FFFFFF38h
    111: mov     esi,0FFFFFF68h
    116: call    ryo_h_MovW128
    11b: mov     edi,0FFFFFEF0h
    120: mov     esi,0FFFFFF50h
    125: mov     edx,18h
    12a: call    ryo_h_Copy
    12f: mov     edi,0FFFFFF08h
    134: mov     esi,0FFFFFF38h
    139: mov     edx,18h
    13e: call    ryo_h_Copy
    143: call    fn2
    148: nop     [rcx-48h]
    14f: xor     edi,edi
    151: xor     esi,esi
    153: call    ryo_h_Ret
    158: leave
    159: ret
    15a: mov     edi,0FFFFFF68h
    15f: lea     rsi,[k3]
    166: call    ryo_h_AddrAbs
    16b: mov     qword ptr [rbp-90h],11h
    176: mov     rdx,[rbp-98h]
    17d: mov     [rbp-0B8h],rdx
    184: mov     rsi,[rbp-90h]
    18b: mov     [rbp-0B0h],rsi
    192: mov     [rbp-0A8h],rdx
    199: mov     [rbp-0A0h],rdx
    1a0: mov     edi,0FFFFFF30h
    1a5: lea     rsi,[k4]
    1ac: call    ryo_h_AddrAbs
    1b1: mov     qword ptr [rbp-0C8h],11h
    1bc: mov     rdx,[rbp-0C8h]
    1c3: mov     [rbp-0C0h],rdx
    1ca: shl     rdx,1
    1ce: mov     [rbp-0B8h],rdx
    1d5: or      rdx,1
    1d9: mov     [rbp-0B0h],rdx
    1e0: mov     [rbp-0A8h],rdx
    1e7: mov     rsi,[rbp-0A0h]
    1ee: mov     [rbp-88h],rsi
    1f5: mov     [rbp-80h],rdx
    1f9: mov     edi,0FFFFFEF0h
    1fe: mov     esi,0FFFFFF78h
    203: call    ryo_h_MovW128
    208: mov     edi,0FFFFFF00h
    20d: lea     rsi,[k5]
    214: call    ryo_h_AddrAbs
    219: lea     rdi,[sym6]
    220: lea     rsi,[site7]
    227: mov     edx,0FFFFFF28h
    22c: call    ryo_h_CallExt
    231: test    rax,rax
    234: je      241h
    236: call    rax
    238: nop     [rcx-48h]
    23f: jmp     251h
    241: mov     rdi,rbp
    244: lea     rsi,[ro+4]
    24b: call    qword ptr [sym8]
    251: call    ryo_h_Unreachable
    256: ud2
    258: nop     [rax+rax]
    260: mov     edi,0FFFFFFA0h
    265: call    ryo_h_Resume
    26a: ud2
    26c: nop     [rax]
    270: jmp     260h
    272: nop     [rax+rax]
    27b: nop     [rax+rax]
    280: test    byte ptr [rbp-49h],0FFh
    284: je      260h
    286: jmp     270h
    288: call    ryo_h_Unreachable
    28d: ud2
    28f: mov     rdi,rax
    292: mov     esi,0FFFFFFA0h
    297: call    ryo_h_Lpad
    29c: jmp     280h

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-10h],rax
     14: mov     rdx,[rbp+10h]
     18: mov     rdx,[rdx+8]
     1c: mov     [rbp-18h],rdx
     20: imul    rcx,rdx,4
     24: add     rax,rcx
     27: mov     [rbp-8],rax
     2b: mov     ecx,[rbp+18h]
     2e: mov     [rax],ecx
     30: mov     rsi,[rbp+10h]
     34: mov     rsi,[rsi+8]
     38: mov     [rbp-20h],rsi
     3c: add     rsi,1
     40: mov     [rbp-30h],rsi
     44: mov     rdi,[rbp+10h]
     48: mov     rcx,[rbp-30h]
     4c: mov     [rdi+8],rcx
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret

fn std::vec::Vec::<u32>::push
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     edx,[rbp+18h]
     13: mov     [rbp-18h],edx
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
     6c: mov     edx,[rbp+18h]
     6f: mov     [rbp-34h],edx
     72: mov     ecx,[rbp-34h]
     75: mov     [rax],ecx
     77: mov     rsi,[rbp-30h]
     7b: add     rsi,1
     7f: mov     [rbp-50h],rsi
     83: mov     rdi,[rbp+10h]
     87: mov     rcx,[rbp-50h]
     8b: mov     [rdi+10h],rcx
     8f: mov     r8,[rbp-18h]
     93: mov     [rbp-8],r8
     97: mov     edi,0FFFFFFF8h
     9c: mov     esi,8
     a1: call    ryo_h_Ret
     a6: leave
     a7: ret
     a8: nop     [rax+rax]
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
     17: mov     rdx,[rbp+10h]
     1b: mov     [rbp-20h],rdx
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
     5b: mov     rdx,[rbp-18h]
     5f: mov     [rbp-88h],rdx
     66: mov     rsi,[rbp+18h]
     6a: mov     [rbp-80h],rsi
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
     1b: mov     rdx,[rbp+10h]
     1f: mov     rdx,[rdx+10h]
     23: mov     [rbp-20h],rdx
     27: mov     [rbp-18h],rax
     2b: mov     [rbp-10h],rdx
     2f: mov     rsi,[rbp+18h]
     33: mov     rsi,[rsi+8]
     37: mov     [rbp-48h],rsi
     3b: mov     [rbp-40h],rsi
     3f: mov     rdi,[rbp+18h]
     43: mov     rdi,[rdi+10h]
     47: mov     [rbp-38h],rdi
     4b: mov     [rbp-30h],rsi
     4f: mov     [rbp-28h],rdi
     53: mov     r8,[rbp-20h]
     57: cmp     r8,[rbp-38h]
     5b: jne     8Fh
     5d: mov     [rbp-58h],rax
     61: mov     [rbp-50h],rdx
     65: mov     [rbp-48h],rax
     69: mov     [rbp-60h],rsi
     6d: mov     [rbp-58h],rdi
     71: mov     [rbp-50h],rsi
     75: mov     [rbp-80h],rax
     79: mov     [rbp-78h],rsi
     7d: mov     [rbp-70h],r8
     81: call    fn0
     86: nop     [rcx-1]
     8d: jmp     93h
     8f: mov     byte ptr [rbp-1],0
     93: mov     edi,0FFFFFFFFh
     98: mov     esi,1
     9d: call    ryo_h_Ret
     a2: leave
     a3: ret

