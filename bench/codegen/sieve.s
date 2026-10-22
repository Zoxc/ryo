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

fn <alloc::raw_vec::RawVec<bool> as std::ops::Drop>::drop
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

fn <bool as std::vec::is_zero::IsZero>::is_zero
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-2],al
     12: xor     al,1
     15: mov     [rbp-1],al
     18: mov     edi,0FFFFFFFFh
     1d: mov     esi,1
     22: call    ryo_h_Ret
     27: leave
     28: ret

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-1Ah],1
      f: mov     byte ptr [rbp-19h],1
     13: lea     rax,[rbp+18h]
     17: mov     [rbp-38h],rax
     1b: mov     [rbp-0B0h],rax
     22: call    fn0
     27: nop     [rcx-29h]
     2e: test    byte ptr [rbp-29h],0FFh
     32: je      9Dh
     34: mov     byte ptr [rbp-19h],0
     38: mov     rax,[rbp+10h]
     3c: mov     [rbp-0B0h],rax
     43: mov     byte ptr [rbp-0A8h],1
     4a: mov     edi,0FFFFFF60h
     4f: lea     rsi,[k1]
     56: mov     edx,10h
     5b: call    ryo_h_Const
     60: lea     rdi,[sym2]
     67: lea     rsi,[site3]
     6e: mov     edx,0FFFFFF78h
     73: call    ryo_h_CallExt
     78: test    rax,rax
     7b: je      88h
     7d: call    rax
     7f: nop     [rcx-68h]
     86: jmp     98h
     88: mov     rdi,rbp
     8b: lea     rsi,[ro+4]
     92: call    qword ptr [sym4]
     98: jmp     17Ah
     9d: mov     byte ptr [rbp-19h],0
     a1: mov     rax,[rbp+10h]
     a5: mov     [rbp-0B0h],rax
     ac: mov     edi,0FFFFFF58h
     b1: lea     rsi,[k5]
     b8: mov     edx,10h
     bd: call    ryo_h_Const
     c2: call    fn6
     c7: nop     [rcx-60h]
     ce: jmp     24Eh
     d3: nop     [rax+rax]
     dc: nop     [rax]
     e0: mov     edi,0FFFFFFE8h
     e5: mov     esi,0FFFFFFC0h
     ea: mov     edx,18h
     ef: call    ryo_h_Copy
     f4: nop     [rax+rax]
     fd: nop     [rax]
    100: mov     edi,0FFFFFFE8h
    105: mov     esi,18h
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: lea     rax,[rbp-40h]
    124: mov     [rbp-88h],rax
    12b: mov     [rbp-0B0h],rax
    132: call    fn7
    137: nop     [rcx-88h]
    13e: jmp     170h
    140: test    byte ptr [rbp-1Ah],0FFh
    144: jne     178h
    146: nop     [rax+rax]
    14f: nop
    150: mov     edi,0FFFFFFD8h
    155: call    ryo_h_Resume
    15a: ud2
    15c: nop     [rax]
    160: jmp     140h
    162: nop     [rax+rax]
    16b: nop     [rax+rax]
    170: test    byte ptr [rbp-19h],0FFh
    174: je      140h
    176: jmp     160h
    178: jmp     150h
    17a: mov     rax,[rbp-68h]
    17e: mov     [rbp-70h],rax
    182: mov     edi,0FFFFFF90h
    187: xor     esi,esi
    189: mov     edx,2
    18e: call    ryo_h_SwitchDenseW64
    193: lea     rcx,[1A4h]
    19a: movsxd  rax,[rcx+rax*4]
    19e: add     rax,rcx
    1a1: jmp     rax
    1a3: int3
    1a4: .long   214h
    1a8: .long   1b7h
    1ac: .long   1b0h
    1b0: call    ryo_h_Unreachable
    1b5: ud2
    1b7: mov     edi,0FFFFFF80h
    1bc: mov     esi,0FFFFFFA0h
    1c1: call    ryo_h_MovW128
    1c6: mov     edi,0FFFFFF50h
    1cb: mov     esi,0FFFFFF80h
    1d0: call    ryo_h_MovW128
    1d5: lea     rdi,[sym8]
    1dc: lea     rsi,[site9]
    1e3: mov     edx,0FFFFFF78h
    1e8: call    ryo_h_CallExt
    1ed: test    rax,rax
    1f0: je      1FDh
    1f2: call    rax
    1f4: nop     [rcx-1Ah]
    1fb: jmp     20Dh
    1fd: mov     rdi,rbp
    200: lea     rsi,[ro+20]
    207: call    qword ptr [sym10]
    20d: call    ryo_h_Unreachable
    212: ud2
    214: mov     edi,0FFFFFFB0h
    219: mov     esi,0FFFFFFA0h
    21e: call    ryo_h_MovW128
    223: mov     edi,0FFFFFFC0h
    228: mov     esi,0FFFFFFB0h
    22d: call    ryo_h_MovW128
    232: mov     edi,0FFFFFFE8h
    237: mov     esi,0FFFFFFC0h
    23c: call    ryo_h_MovW128
    241: mov     rax,[rbp+10h]
    245: mov     [rbp-8],rax
    249: jmp     100h
    24e: mov     edi,0FFFFFFB0h
    253: mov     esi,0FFFFFFA0h
    258: call    ryo_h_MovW128
    25d: mov     edi,0FFFFFFC0h
    262: mov     esi,0FFFFFFB0h
    267: call    ryo_h_MovW128
    26c: mov     qword ptr [rbp-30h],0
    274: lea     rax,[rbp-40h]
    278: mov     [rbp-48h],rax
    27c: mov     byte ptr [rbp-1Ah],0
    280: movzx   eax,byte ptr [rbp+18h]
    284: mov     [rbp-49h],al
    287: mov     rax,[rbp-48h]
    28b: mov     [rbp-0B0h],rax
    292: mov     rax,[rbp+10h]
    296: mov     [rbp-0A8h],rax
    29d: movzx   eax,byte ptr [rbp-49h]
    2a1: mov     [rbp-0A0h],al
    2a7: call    fn11
    2ac: nop     [rcx-18h]
    2b3: jmp     0E0h
    2b8: nop     [rax+rax]
    2c0: lea     rdi,[sym12]
    2c7: lea     rsi,[site13]
    2ce: mov     edx,0FFFFFF78h
    2d3: call    ryo_h_CallExt
    2d8: test    rax,rax
    2db: je      2E8h
    2dd: call    rax
    2df: nop     [rcx-80h]
    2e6: jmp     2F8h
    2e8: mov     rdi,rbp
    2eb: lea     rsi,[ro+36]
    2f2: call    qword ptr [sym14]
    2f8: call    ryo_h_Unreachable
    2fd: ud2
    2ff: mov     rdi,rax
    302: mov     esi,0FFFFFFD8h
    307: call    ryo_h_Lpad
    30c: jmp     170h
    311: mov     rdi,rax
    314: mov     esi,0FFFFFFD8h
    319: call    ryo_h_Lpad
    31e: jmp     2C0h
    320: mov     rdi,rax
    323: mov     esi,0FFFFFFD8h
    328: call    ryo_h_Lpad
    32d: jmp     120h

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

fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: lea     rax,[rbp+18h]
     14: mov     [rbp-30h],rax
     18: mov     [rbp-28h],rax
     1c: mov     rax,[rbp-20h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-28h]
     28: mov     [rbp-38h],rax
     2c: call    fn0
     31: nop     [rcx-11h]
     38: mov     edi,0FFFFFFF8h
     3d: mov     esi,0FFFFFFEFh
     42: call    ryo_h_ZextW8W64
     47: mov     edi,0FFFFFFF8h
     4c: mov     esi,8
     51: call    ryo_h_Ret
     56: leave
     57: ret
     58: nop     [rax+rax]
     60: mov     edi,0FFFFFFF0h
     65: call    ryo_h_Resume
     6a: ud2
     6c: mov     rdi,rax
     6f: mov     esi,0FFFFFFF0h
     74: call    ryo_h_Lpad
     79: jmp     60h

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-11h],1
      c: mov     byte ptr [rbp-12h],1
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-50h],rax
     18: mov     [rbp-70h],rax
     1c: call    fn0
     21: nop     [rcx-48h]
     28: mov     edi,0FFFFFFD0h
     2d: mov     esi,0FFFFFFC0h
     32: call    ryo_h_MovW128
     37: mov     rax,[rbp-30h]
     3b: mov     [rbp-50h],rax
     3f: mov     edi,0FFFFFFB0h
     44: xor     esi,esi
     46: mov     edx,2
     4b: call    ryo_h_SwitchDenseW64
     50: lea     rcx,[60h]
     57: movsxd  rax,[rcx+rax*4]
     5b: add     rax,rcx
     5e: jmp     rax
     60: .long   14eh
     64: .long   158h
     68: .long   147h
     6c: nop     [rax]
     70: mov     edi,0FFFFFFC0h
     75: mov     esi,0FFFFFFD0h
     7a: call    ryo_h_MovW128
     7f: mov     edi,0FFFFFF90h
     84: mov     esi,0FFFFFFC0h
     89: call    ryo_h_MovW128
     8e: mov     qword ptr [rbp-60h],0
     96: call    fn1
     9b: nop     [rcx-8]
     a2: jmp     162h
     a7: nop     [rax+rax]
     b0: mov     edi,0FFFFFFF8h
     b5: mov     esi,8
     ba: call    ryo_h_Ret
     bf: leave
     c0: ret
     c1: nop     [rax+rax]
     ca: nop     [rax+rax]
     d0: mov     edi,0FFFFFFE0h
     d5: call    ryo_h_Resume
     da: ud2
     dc: nop     [rax]
     e0: test    byte ptr [rbp-11h],0FFh
     e4: je      0D0h
     e6: jmp     0D0h
     e8: nop     [rax+rax]
     f0: jmp     0E0h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: test    byte ptr [rbp-12h],0FFh
    104: je      0E0h
    106: jmp     0F0h
    108: nop     [rax+rax]
    110: mov     byte ptr [rbp-12h],0
    114: mov     edi,0FFFFFFC0h
    119: mov     esi,10h
    11e: call    ryo_h_MovW128
    123: mov     byte ptr [rbp-11h],0
    127: mov     edi,0FFFFFF90h
    12c: mov     esi,0FFFFFFC0h
    131: call    ryo_h_MovW128
    136: call    fn2
    13b: nop     [rcx-30h]
    142: jmp     70h
    147: call    ryo_h_Unreachable
    14c: ud2
    14e: mov     qword ptr [rbp-10h],0FFFFFFFFFFFFFFFFh
    156: jmp     110h
    158: mov     rax,[rbp-28h]
    15c: mov     [rbp-10h],rax
    160: jmp     110h
    162: mov     rax,[rbp-8]
    166: mov     [rbp-70h],rax
    16a: mov     rax,[rbp-10h]
    16e: mov     [rbp-68h],rax
    172: call    fn3
    177: nop     [rcx-10h]
    17e: jmp     0B0h
    183: mov     rdi,rax
    186: mov     esi,0FFFFFFE0h
    18b: call    ryo_h_Lpad
    190: jmp     100h

fn <std::iter::Rev<std::ops::RangeInclusive<usize>> as std::iter::Iterator>::find::<{closure@bench/sieve.rs:25:39: 25:43}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-30h],rax
     14: mov     rax,[rbp+18h]
     18: mov     [rbp-28h],rax
     1c: call    fn0
     21: nop     [rcx-10h]
     28: mov     edi,0FFFFFFF0h
     2d: mov     esi,10h
     32: call    ryo_h_Ret
     37: leave
     38: ret

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     qword ptr [rbp-18h],1
     10: cmp     qword ptr [rbp-18h],1
     15: sete    [rbp-19h]
     19: mov     rax,[rbp+10h]
     1d: mov     [rbp-28h],rax
     21: mov     [rbp-8],rax
     25: mov     qword ptr [rbp-10h],1
     2d: mov     edi,0FFFFFFF0h
     32: mov     esi,10h
     37: call    ryo_h_Ret
     3c: leave
     3d: ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::branch
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     edi,0FFFFFFE8h
     15: xor     esi,esi
     17: mov     edx,2
     1c: call    ryo_h_SwitchDenseW64
     21: lea     rcx,[34h]
     28: movsxd  rax,[rcx+rax*4]
     2c: add     rax,rcx
     2f: jmp     rax
     31: int3
     32: int3
     33: int3
     34: .long   61h
     38: .long   47h
     3c: .long   40h
     40: call    ryo_h_Unreachable
     45: ud2
     47: mov     rax,[rbp+18h]
     4b: mov     [rbp-20h],rax
     4f: mov     [rbp-28h],rax
     53: mov     [rbp-8],rax
     57: mov     qword ptr [rbp-10h],1
     5f: jmp     69h
     61: mov     qword ptr [rbp-10h],0
     69: mov     edi,0FFFFFFF0h
     6e: mov     esi,10h
     73: call    ryo_h_Ret
     78: leave
     79: ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::from_output
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-10h],0
     10: mov     edi,0FFFFFFF0h
     15: mov     esi,10h
     1a: call    ryo_h_Ret
     1f: leave
     20: ret

fn <std::ops::RangeInclusive<usize> as std::iter::DoubleEndedIterator>::rfind::<{closure@bench/sieve.rs:25:39: 25:43}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-28h],rax
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-50h],rax
     18: mov     rax,[rbp-28h]
     1c: mov     [rbp-48h],rax
     20: call    fn0
     25: nop     [rcx-20h]
     2c: mov     rax,[rbp-20h]
     30: mov     [rbp-28h],rax
     34: mov     edi,0FFFFFFD8h
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
     58: .long   8dh
     5c: .long   77h
     60: .long   70h
     64: nop     [rax+rax]
     6d: nop     [rax]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     rax,[rbp-18h]
     7b: mov     [rbp-30h],rax
     7f: mov     [rbp-8],rax
     83: mov     qword ptr [rbp-10h],1
     8b: jmp     0B3h
     8d: mov     qword ptr [rbp-10h],0
     95: jmp     0B3h
     97: nop     [rax+rax]
     a0: mov     edi,0FFFFFFF0h
     a5: mov     esi,10h
     aa: call    ryo_h_Ret
     af: leave
     b0: ret
     b1: jmp     0A0h
     b3: mov     rax,[rbp-20h]
     b7: mov     [rbp-38h],rax
     bb: mov     edi,0FFFFFFC8h
     c0: xor     esi,esi
     c2: mov     edx,2
     c7: call    ryo_h_SwitchDenseW64
     cc: lea     rcx,[0DCh]
     d3: movsxd  rax,[rcx+rax*4]
     d7: add     rax,rcx
     da: jmp     rax
     dc: .long   b1h
     e0: .long   a0h
     e4: .long   70h

fn <std::ops::RangeInclusive<usize> as std::iter::Iterator>::rev
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

fn <std::ops::RangeInclusive<usize> as std::iter::range::RangeInclusiveIteratorImpl>::spec_try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     byte ptr [rbp-2Ah],1
      f: mov     rax,[rbp+10h]
     13: movzx   eax,byte ptr [rax+10h]
     17: mov     [rbp-3Ah],al
     1a: test    byte ptr [rbp-3Ah],0FFh
     1e: je      31Fh
     24: jmp     31Ah
     29: nop     [rax]
     30: mov     byte ptr [rbp-2Ah],0
     34: call    fn0
     39: nop     [rcx-10h]
     40: jmp     2B5h
     45: nop     [rax+rax]
     4e: xchg    ax,ax
     50: mov     byte ptr [rbp-2Ah],0
     54: mov     byte ptr [rbp-29h],1
     58: nop     [rax+rax]
     60: mov     rax,[rbp+10h]
     64: mov     [rbp-48h],rax
     68: mov     rax,[rbp+10h]
     6c: lea     rax,[rax+8]
     70: mov     [rbp-50h],rax
     74: mov     rax,[rbp-48h]
     78: mov     [rbp-0A0h],rax
     7f: mov     rax,[rbp-50h]
     83: mov     [rbp-98h],rax
     8a: call    fn1
     8f: nop     [rcx-39h]
     96: test    byte ptr [rbp-39h],0FFh
     9a: je      1A0h
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+8]
     a8: mov     [rbp-50h],rax
     ac: mov     [rbp-0A0h],rax
     b3: mov     qword ptr [rbp-98h],1
     be: call    fn2
     c3: nop     [rcx-48h]
     ca: mov     rax,[rbp+10h]
     ce: mov     rax,[rax+8]
     d2: mov     [rbp-50h],rax
     d6: mov     rax,[rbp+10h]
     da: mov     rcx,[rbp-48h]
     de: mov     [rax+8],rcx
     e2: lea     rax,[rbp+18h]
     e6: mov     [rbp-78h],rax
     ea: mov     byte ptr [rbp-29h],0
     ee: mov     rax,[rbp-50h]
     f2: mov     [rbp-80h],rax
     f6: mov     rax,[rbp-78h]
     fa: mov     [rbp-0A0h],rax
    101: mov     rax,[rbp-80h]
    105: mov     [rbp-98h],rax
    10c: call    fn3
    111: nop     [rcx-70h]
    118: mov     edi,0FFFFFF60h
    11d: mov     esi,0FFFFFF90h
    122: call    ryo_h_MovW128
    127: call    fn4
    12c: nop     [rcx-60h]
    133: mov     rax,[rbp-60h]
    137: mov     [rbp-20h],rax
    13b: mov     edi,0FFFFFFE0h
    140: xor     esi,esi
    142: mov     edx,2
    147: call    ryo_h_SwitchDenseW64
    14c: lea     rcx,[15Ch]
    153: movsxd  rax,[rcx+rax*4]
    157: add     rax,rcx
    15a: jmp     rax
    15c: .long   177h
    160: .long   180h
    164: .long   170h
    168: nop     [rax+rax]
    170: call    ryo_h_Unreachable
    175: ud2
    177: mov     byte ptr [rbp-29h],1
    17b: jmp     60h
    180: mov     rax,[rbp-58h]
    184: mov     [rbp-68h],rax
    188: mov     [rbp-0A0h],rax
    18f: call    fn5
    194: nop     [rcx-10h]
    19b: jmp     2B5h
    1a0: mov     byte ptr [rbp-90h],1
    1a7: mov     rax,[rbp+10h]
    1ab: movzx   ecx,byte ptr [rbp-90h]
    1b2: mov     [rax+10h],cl
    1b5: mov     rax,[rbp+10h]
    1b9: mov     [rbp-48h],rax
    1bd: mov     rax,[rbp+10h]
    1c1: lea     rax,[rax+8]
    1c5: mov     [rbp-50h],rax
    1c9: mov     rax,[rbp-48h]
    1cd: mov     [rbp-0A0h],rax
    1d4: mov     rax,[rbp-50h]
    1d8: mov     [rbp-98h],rax
    1df: call    fn6
    1e4: nop     [rcx-39h]
    1eb: test    byte ptr [rbp-39h],0FFh
    1ef: je      2A3h
    1f5: lea     rax,[rbp+18h]
    1f9: mov     [rbp-68h],rax
    1fd: mov     byte ptr [rbp-29h],0
    201: mov     rax,[rbp+10h]
    205: mov     rax,[rax]
    208: mov     [rbp-78h],rax
    20c: mov     [rbp-70h],rax
    210: mov     rax,[rbp-68h]
    214: mov     [rbp-0A0h],rax
    21b: mov     rax,[rbp-70h]
    21f: mov     [rbp-98h],rax
    226: call    fn7
    22b: nop     [rcx-60h]
    232: mov     edi,0FFFFFF60h
    237: mov     esi,0FFFFFFA0h
    23c: call    ryo_h_MovW128
    241: call    fn8
    246: nop     [rcx-50h]
    24d: mov     rax,[rbp-50h]
    251: mov     [rbp-28h],rax
    255: mov     edi,0FFFFFFD8h
    25a: xor     esi,esi
    25c: mov     edx,2
    261: call    ryo_h_SwitchDenseW64
    266: lea     rcx,[278h]
    26d: movsxd  rax,[rcx+rax*4]
    271: add     rax,rcx
    274: jmp     rax
    276: int3
    277: int3
    278: .long   284h
    27c: .long   286h
    280: .long   170h
    284: jmp     2A3h
    286: mov     rax,[rbp-48h]
    28a: mov     [rbp-58h],rax
    28e: mov     [rbp-0A0h],rax
    295: call    fn9
    29a: nop     [rcx-10h]
    2a1: jmp     2B5h
    2a3: mov     byte ptr [rbp-29h],0
    2a7: call    fn10
    2ac: nop     [rcx-10h]
    2b3: jmp     2B5h
    2b5: mov     edi,0FFFFFFF0h
    2ba: mov     esi,10h
    2bf: call    ryo_h_Ret
    2c4: leave
    2c5: ret
    2c6: nop     [rax+rax]
    2cf: nop
    2d0: jmp     312h
    2d2: nop     [rax+rax]
    2db: nop     [rax+rax]
    2e0: mov     edi,0FFFFFFC8h
    2e5: call    ryo_h_Resume
    2ea: ud2
    2ec: nop     [rax]
    2f0: jmp     2D0h
    2f2: nop     [rax+rax]
    2fb: nop     [rax+rax]
    300: test    byte ptr [rbp-29h],0FFh
    304: je      2D0h
    306: jmp     2F0h
    308: nop     [rax+rax]
    310: jmp     2E0h
    312: test    byte ptr [rbp-2Ah],0FFh
    316: je      2E0h
    318: jmp     310h
    31a: jmp     30h
    31f: mov     rax,[rbp+10h]
    323: mov     [rbp-48h],rax
    327: mov     rax,[rbp+10h]
    32b: lea     rax,[rax+8]
    32f: mov     [rbp-50h],rax
    333: mov     rax,[rbp-48h]
    337: mov     [rbp-0A0h],rax
    33e: mov     rax,[rbp-50h]
    342: mov     [rbp-98h],rax
    349: call    fn11
    34e: nop     [rcx-3Bh]
    355: movzx   eax,byte ptr [rbp-3Bh]
    359: xor     al,1
    35c: mov     [rbp-39h],al
    35f: test    byte ptr [rbp-39h],0FFh
    363: je      50h
    369: jmp     30h
    36e: mov     rdi,rax
    371: mov     esi,0FFFFFFC8h
    376: call    ryo_h_Lpad
    37b: jmp     2D0h
    380: mov     rdi,rax
    383: mov     esi,0FFFFFFC8h
    388: call    ryo_h_Lpad
    38d: jmp     300h

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::filter::<{closure@bench/sieve.rs:24:37: 24:42}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
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
    128: imul    rcx,[rbp-90h],1
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
    199: je      36Eh
    19f: jmp     33Bh
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
    283: cmp     qword ptr [rbp-0A8h],1
    28b: setb    [rbp-71h]
    28f: test    byte ptr [rbp-71h],0FFh
    293: je      2CFh
    295: mov     qword ptr [rbp-0A8h],1
    2a0: mov     rax,[rbp-0A8h]
    2a7: mov     rcx,7FFFFFFFFFFFFFFFh
    2b1: cmp     rax,rcx
    2b4: setbe   [rbp-72h]
    2b8: test    byte ptr [rbp-72h],0FFh
    2bc: je      2CFh
    2be: mov     rax,[rbp-70h]
    2c2: sub     rax,[rbp-68h]
    2c6: mov     [rbp-28h],rax
    2ca: jmp     230h
    2cf: mov     edi,0FFFFFF40h
    2d4: lea     rsi,[k3]
    2db: call    ryo_h_AddrAbs
    2e0: mov     qword ptr [rbp-0B8h],49h
    2eb: mov     edi,0FFFFFF50h
    2f0: lea     rsi,[k4]
    2f7: call    ryo_h_AddrAbs
    2fc: lea     rdi,[sym5]
    303: lea     rsi,[site6]
    30a: mov     edx,0FFFFFF58h
    30f: call    ryo_h_CallExt
    314: test    rax,rax
    317: je      324h
    319: call    rax
    31b: nop     [rcx-32h]
    322: jmp     334h
    324: mov     rdi,rbp
    327: lea     rsi,[ro+4]
    32e: call    qword ptr [sym7]
    334: call    ryo_h_Unreachable
    339: ud2
    33b: mov     rax,[rbp-20h]
    33f: mov     [rbp-0C0h],rax
    346: mov     qword ptr [rbp-0B8h],1
    351: mov     edi,0FFFFFF50h
    356: lea     rsi,[k8]
    35d: call    ryo_h_AddrAbs
    362: call    fn9
    367: nop     [rcx-32h]
    36e: mov     rax,[rbp-20h]
    372: add     rax,1
    376: mov     [rbp-50h],rax
    37a: mov     [rbp-20h],rax
    37e: mov     [rbp-58h],rax
    382: mov     rax,[rbp-28h]
    386: mov     [rbp-60h],rax
    38a: mov     rax,[rbp-58h]
    38e: cmp     rax,[rbp-60h]
    392: je      1B0h
    398: jmp     1C0h
    39d: mov     rdi,rax
    3a0: mov     esi,0FFFFFFC0h
    3a5: call    ryo_h_Lpad
    3aa: jmp     210h

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::map::<usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::size_hint
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
     f7: cmp     qword ptr [rbp-60h],1
     fc: setb    [rbp-49h]
    100: test    byte ptr [rbp-49h],0FFh
    104: je      13Ah
    106: mov     qword ptr [rbp-60h],1
    10e: mov     rax,[rbp-60h]
    112: mov     rcx,7FFFFFFFFFFFFFFFh
    11c: cmp     rax,rcx
    11f: setbe   [rbp-4Ah]
    123: test    byte ptr [rbp-4Ah],0FFh
    127: je      13Ah
    129: mov     rax,[rbp-48h]
    12d: sub     rax,[rbp-40h]
    131: mov     [rbp-20h],rax
    135: jmp     0B0h
    13a: mov     edi,0FFFFFF80h
    13f: lea     rsi,[k2]
    146: call    ryo_h_AddrAbs
    14b: mov     qword ptr [rbp-78h],49h
    153: mov     edi,0FFFFFF90h
    158: lea     rsi,[k3]
    15f: call    ryo_h_AddrAbs
    164: lea     rdi,[sym4]
    16b: lea     rsi,[site5]
    172: mov     edx,0FFFFFFA0h
    177: call    ryo_h_CallExt
    17c: test    rax,rax
    17f: je      18Ch
    181: call    rax
    183: nop     [rcx-20h]
    18a: jmp     19Ch
    18c: mov     rdi,rbp
    18f: lea     rsi,[ro+4]
    196: call    qword ptr [sym6]
    19c: call    ryo_h_Unreachable
    1a1: ud2

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: cmp     rax,[rbp+18h]
     10: setbe   [rbp-1]
     14: mov     byte ptr [rbp-2],1
     18: test    byte ptr [rbp-2],0FFh
     1c: je      42h
     1e: movzx   eax,byte ptr [rbp-1]
     22: mov     [rbp-20h],al
     25: mov     edi,0FFFFFFE8h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: call    fn1
     3b: nop     [rcx]
     42: xor     edi,edi
     44: xor     esi,esi
     46: call    ryo_h_Ret
     4b: leave
     4c: ret

fn <std::vec::Vec<bool> as std::ops::Deref>::deref
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

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
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

fn <usize as std::iter::Step>::backward_unchecked
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
     43: sub     rax,[rbp+18h]
     47: mov     [rbp-8],rax
     4b: mov     edi,0FFFFFFF8h
     50: mov     esi,8
     55: call    ryo_h_Ret
     5a: leave
     5b: ret

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFE8h
      d: mov     esi,0FFFFFFF0h
     12: mov     edx,18h
     17: mov     ecx,20h
     1c: call    ryo_h_AddOvfUW64
     21: test    byte ptr [rbp-10h],0FFh
     25: je      77h
     27: mov     edi,0FFFFFFD0h
     2c: lea     rsi,[k0]
     33: call    ryo_h_AddrAbs
     38: lea     rdi,[sym1]
     3f: lea     rsi,[site2]
     46: mov     edx,0FFFFFFE0h
     4b: call    ryo_h_CallExt
     50: test    rax,rax
     53: je      60h
     55: call    rax
     57: nop     [rcx-18h]
     5e: jmp     70h
     60: mov     rdi,rbp
     63: lea     rsi,[ro+4]
     6a: call    qword ptr [sym3]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     rax,[rbp-18h]
     7b: mov     [rbp-8],rax
     7f: mov     edi,0FFFFFFF8h
     84: mov     esi,8
     89: call    ryo_h_Ret
     8e: leave
     8f: ret

fn <usize as std::slice::SliceIndex<[bool]>>::index
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
     71: imul    rcx,[rbp+20h],1
     76: add     rax,rcx
     79: mov     [rbp-20h],rax
     7d: mov     [rbp-8],rax
     81: mov     edi,0FFFFFFF8h
     86: mov     esi,8
     8b: call    ryo_h_Ret
     90: leave
     91: ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
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
     71: imul    rcx,[rbp+20h],1
     76: add     rax,rcx
     79: mov     [rbp-20h],rax
     7d: mov     [rbp-8],rax
     81: mov     edi,0FFFFFFF8h
     86: mov     esi,8
     8b: call    ryo_h_Ret
     90: leave
     91: ret

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

fn core::slice::<impl [bool]>::iter
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

fn main
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,1B0h
      b: mov     qword ptr [rbp-1B0h],0C65D40h
     16: call    fn0
     1b: nop     [rcx-8]
     22: mov     rax,[rbp-8]
     26: mov     [rbp-1B0h],rax
     2d: call    fn1
     32: nop     [rcx-20h]
     39: lea     rax,[rbp-20h]
     3d: mov     [rbp-60h],rax
     41: mov     [rbp-1B0h],rax
     48: call    fn2
     4d: nop     [rcx-58h]
     54: mov     edi,0FFFFFE50h
     59: mov     esi,0FFFFFFA8h
     5e: call    ryo_h_MovW128
     63: call    fn3
     68: nop     [rcx-48h]
     6f: mov     edi,0FFFFFE50h
     74: mov     esi,0FFFFFFB8h
     79: call    ryo_h_MovW128
     7e: call    fn4
     83: nop     [rcx-38h]
     8a: mov     edi,0FFFFFE50h
     8f: mov     esi,0FFFFFFC8h
     94: call    ryo_h_MovW128
     99: call    fn5
     9e: nop     [rcx-28h]
     a5: mov     qword ptr [rbp-1B0h],0
     b0: mov     rax,[rbp-8]
     b4: mov     [rbp-1A8h],rax
     bb: call    fn6
     c0: nop     [rcx-0B0h]
     c7: mov     edi,0FFFFFE50h
     cc: mov     esi,0FFFFFF50h
     d1: mov     edx,18h
     d6: call    ryo_h_Copy
     db: call    fn7
     e0: nop     [rcx-98h]
     e7: lea     rax,[rbp-98h]
     ee: mov     [rbp-80h],rax
     f2: lea     rax,[rbp-20h]
     f6: mov     [rbp-0C0h],rax
     fd: mov     [rbp-0B8h],rax
    104: mov     rax,[rbp-80h]
    108: mov     [rbp-1B0h],rax
    10f: mov     rax,[rbp-0B8h]
    116: mov     [rbp-1A8h],rax
    11d: call    fn8
    122: nop     [rcx-78h]
    129: mov     edi,0FFFFFE50h
    12e: mov     esi,0FFFFFF88h
    133: call    ryo_h_MovW128
    138: mov     edi,0FFFFFE60h
    13d: lea     rsi,[k9]
    144: call    ryo_h_AddrAbs
    149: call    fn10
    14e: nop     [rcx-68h]
    155: lea     rax,[rbp-28h]
    159: mov     [rbp-0F0h],rax
    160: lea     rax,[rbp-8]
    164: mov     [rbp-0F8h],rax
    16b: lea     rax,[rbp-68h]
    16f: mov     [rbp-100h],rax
    176: mov     rax,[rbp-0F0h]
    17d: mov     [rbp-0E8h],rax
    184: mov     rax,[rbp-0F8h]
    18b: mov     [rbp-0E0h],rax
    192: mov     rax,[rbp-100h]
    199: mov     [rbp-0D8h],rax
    1a0: mov     rax,[rbp-0E8h]
    1a7: mov     [rbp-178h],rax
    1ae: mov     [rbp-1B0h],rax
    1b5: call    fn11
    1ba: nop     [rcx-140h]
    1c1: mov     rax,[rbp-0E0h]
    1c8: mov     [rbp-180h],rax
    1cf: mov     [rbp-1B0h],rax
    1d6: call    fn12
    1db: nop     [rcx-150h]
    1e2: mov     rax,[rbp-0D8h]
    1e9: mov     [rbp-188h],rax
    1f0: mov     [rbp-1B0h],rax
    1f7: call    fn13
    1fc: nop     [rcx-160h]
    203: mov     edi,0FFFFFED0h
    208: mov     esi,0FFFFFEC0h
    20d: call    ryo_h_MovW128
    212: mov     edi,0FFFFFEE0h
    217: mov     esi,0FFFFFEB0h
    21c: call    ryo_h_MovW128
    221: mov     edi,0FFFFFEF0h
    226: mov     esi,0FFFFFEA0h
    22b: call    ryo_h_MovW128
    230: mov     edi,0FFFFFE98h
    235: lea     rsi,[k14]
    23c: call    ryo_h_AddrAbs
    241: lea     rax,[rbp-130h]
    248: mov     [rbp-170h],rax
    24f: mov     rax,[rbp-168h]
    256: mov     [rbp-1B0h],rax
    25d: mov     rax,[rbp-170h]
    264: mov     [rbp-1A8h],rax
    26b: call    fn15
    270: nop     [rcx-0D0h]
    277: mov     edi,0FFFFFE50h
    27c: mov     esi,0FFFFFF30h
    281: call    ryo_h_MovW128
    286: lea     rdi,[sym16]
    28d: lea     rsi,[site17]
    294: mov     edx,0FFFFFE68h
    299: call    ryo_h_CallExt
    29e: test    rax,rax
    2a1: je      2AEh
    2a3: call    rax
    2a5: nop     [rcx-0C0h]
    2ac: jmp     2BEh
    2ae: mov     rdi,rbp
    2b1: lea     rsi,[ro+4]
    2b8: call    qword ptr [sym18]
    2be: lea     rax,[rbp-20h]
    2c2: mov     [rbp-198h],rax
    2c9: mov     [rbp-1B0h],rax
    2d0: call    fn19
    2d5: nop     [rcx-198h]
    2dc: xor     edi,edi
    2de: xor     esi,esi
    2e0: call    ryo_h_Ret
    2e5: leave
    2e6: ret
    2e7: nop     [rax+rax]
    2f0: lea     rax,[rbp-20h]
    2f4: mov     [rbp-198h],rax
    2fb: mov     [rbp-1B0h],rax
    302: call    fn20
    307: nop     [rcx-198h]
    30e: mov     edi,0FFFFFE70h
    313: call    ryo_h_Resume
    318: ud2
    31a: nop     [rax+rax]
    320: lea     rdi,[sym21]
    327: lea     rsi,[site22]
    32e: mov     edx,0FFFFFE68h
    333: call    ryo_h_CallExt
    338: test    rax,rax
    33b: je      348h
    33d: call    rax
    33f: nop     [rcx-190h]
    346: jmp     358h
    348: mov     rdi,rbp
    34b: lea     rsi,[ro+20]
    352: call    qword ptr [sym23]
    358: call    ryo_h_Unreachable
    35d: ud2
    35f: mov     rdi,rax
    362: mov     esi,0FFFFFE70h
    367: call    ryo_h_Lpad
    36c: jmp     2F0h
    36e: mov     rdi,rax
    371: mov     esi,0FFFFFE70h
    376: call    ryo_h_Lpad
    37b: jmp     320h

fn main::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+18h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: movzx   eax,byte ptr [rax]
     16: mov     [rbp-1],al
     19: mov     edi,0FFFFFFFFh
     1e: mov     esi,1
     23: call    ryo_h_Ret
     28: leave
     29: ret

fn main::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax]
     1a: mov     [rbp-20h],rax
     1e: mov     [rbp-40h],rax
     22: mov     rax,[rbp-10h]
     26: mov     [rbp-38h],rax
     2a: mov     edi,0FFFFFFD0h
     2f: lea     rsi,[k0]
     36: call    ryo_h_AddrAbs
     3b: call    fn1
     40: nop     [rcx-18h]
     47: mov     rax,[rbp-18h]
     4b: movzx   eax,byte ptr [rax]
     4e: mov     [rbp-1],al
     51: mov     edi,0FFFFFFFFh
     56: mov     esi,1
     5b: call    ryo_h_Ret
     60: leave
     61: ret

fn sieve
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,170h
      b: mov     qword ptr [rbp-148h],1
     16: mov     edi,0FFFFFFB8h
     1b: mov     esi,0FFFFFFC0h
     20: mov     edx,10h
     25: mov     ecx,0FFFFFEB8h
     2a: call    ryo_h_AddOvfUW64
     2f: test    byte ptr [rbp-40h],0FFh
     33: je      85h
     35: mov     edi,0FFFFFE90h
     3a: lea     rsi,[k0]
     41: call    ryo_h_AddrAbs
     46: lea     rdi,[sym1]
     4d: lea     rsi,[site2]
     54: mov     edx,0FFFFFEB8h
     59: call    ryo_h_CallExt
     5e: test    rax,rax
     61: je      6Eh
     63: call    rax
     65: nop     [rcx-140h]
     6c: jmp     7Eh
     6e: mov     rdi,rbp
     71: lea     rsi,[ro+4]
     78: call    qword ptr [sym3]
     7e: call    ryo_h_Unreachable
     83: ud2
     85: mov     rax,[rbp-48h]
     89: mov     [rbp-38h],rax
     8d: mov     byte ptr [rbp-170h],1
     94: mov     [rbp-168h],rax
     9b: call    fn4
     a0: nop     [rcx-30h]
     a7: lea     rax,[rbp-30h]
     ab: mov     [rbp-58h],rax
     af: mov     [rbp-170h],rax
     b6: mov     qword ptr [rbp-168h],0
     c1: mov     edi,0FFFFFEA0h
     c6: lea     rsi,[k5]
     cd: call    ryo_h_AddrAbs
     d2: call    fn6
     d7: nop     [rcx-50h]
     de: mov     byte ptr [rbp-150h],0
     e5: mov     rax,[rbp-50h]
     e9: movzx   ecx,byte ptr [rbp-150h]
     f0: mov     [rax],cl
     f2: lea     rax,[rbp-30h]
     f6: mov     [rbp-68h],rax
     fa: mov     [rbp-170h],rax
    101: mov     qword ptr [rbp-168h],1
    10c: mov     edi,0FFFFFEA0h
    111: lea     rsi,[k7]
    118: call    ryo_h_AddrAbs
    11d: call    fn8
    122: nop     [rcx-60h]
    129: mov     byte ptr [rbp-150h],0
    130: mov     rax,[rbp-60h]
    134: movzx   ecx,byte ptr [rbp-150h]
    13b: mov     [rax],cl
    13d: mov     qword ptr [rbp-70h],2
    145: nop     [rax+rax]
    14e: xchg    ax,ax
    150: mov     rax,[rbp-70h]
    154: mov     [rbp-88h],rax
    15b: mov     rax,[rbp-70h]
    15f: mov     [rbp-90h],rax
    166: mov     edi,0FFFFFF60h
    16b: mov     esi,0FFFFFF68h
    170: mov     edx,0FFFFFF78h
    175: mov     ecx,0FFFFFF70h
    17a: call    ryo_h_MulOvfUW64
    17f: test    byte ptr [rbp-98h],0FFh
    186: je      1D8h
    188: mov     edi,0FFFFFE90h
    18d: lea     rsi,[k9]
    194: call    ryo_h_AddrAbs
    199: lea     rdi,[sym10]
    1a0: lea     rsi,[site11]
    1a7: mov     edx,0FFFFFEB8h
    1ac: call    ryo_h_CallExt
    1b1: test    rax,rax
    1b4: je      1C1h
    1b6: call    rax
    1b8: nop     [rcx-140h]
    1bf: jmp     1D1h
    1c1: mov     rdi,rbp
    1c4: lea     rsi,[ro+4]
    1cb: call    qword ptr [sym12]
    1d1: call    ryo_h_Unreachable
    1d6: ud2
    1d8: mov     rax,[rbp-0A0h]
    1df: mov     [rbp-80h],rax
    1e3: mov     rax,[rbp+10h]
    1e7: cmp     rax,[rbp-80h]
    1eb: jb      4A5h
    1f1: lea     rax,[rbp-30h]
    1f5: mov     [rbp-0B8h],rax
    1fc: mov     rax,[rbp-70h]
    200: mov     [rbp-0C0h],rax
    207: mov     rax,[rbp-0B8h]
    20e: mov     [rbp-170h],rax
    215: mov     rax,[rbp-0C0h]
    21c: mov     [rbp-168h],rax
    223: mov     edi,0FFFFFEA0h
    228: lea     rsi,[k13]
    22f: call    ryo_h_AddrAbs
    234: call    fn14
    239: nop     [rcx-0B0h]
    240: mov     rax,[rbp-0B0h]
    247: movzx   eax,byte ptr [rax]
    24a: mov     [rbp-0A1h],al
    250: test    byte ptr [rbp-0A1h],0FFh
    257: je      418h
    25d: mov     rax,[rbp-70h]
    261: mov     [rbp-0D0h],rax
    268: mov     rax,[rbp-70h]
    26c: mov     [rbp-0D8h],rax
    273: mov     edi,0FFFFFF18h
    278: mov     esi,0FFFFFF20h
    27d: mov     edx,0FFFFFF30h
    282: mov     ecx,0FFFFFF28h
    287: call    ryo_h_MulOvfUW64
    28c: test    byte ptr [rbp-0E0h],0FFh
    293: je      2E5h
    295: mov     edi,0FFFFFE90h
    29a: lea     rsi,[k15]
    2a1: call    ryo_h_AddrAbs
    2a6: lea     rdi,[sym16]
    2ad: lea     rsi,[site17]
    2b4: mov     edx,0FFFFFEB8h
    2b9: call    ryo_h_CallExt
    2be: test    rax,rax
    2c1: je      2CEh
    2c3: call    rax
    2c5: nop     [rcx-140h]
    2cc: jmp     2DEh
    2ce: mov     rdi,rbp
    2d1: lea     rsi,[ro+4]
    2d8: call    qword ptr [sym18]
    2de: call    ryo_h_Unreachable
    2e3: ud2
    2e5: mov     rax,[rbp-0E8h]
    2ec: mov     [rbp-0C8h],rax
    2f3: nop     [rax+rax]
    2fc: nop     [rax]
    300: mov     rax,[rbp-0C8h]
    307: mov     [rbp-0F8h],rax
    30e: mov     rax,[rbp+10h]
    312: cmp     rax,[rbp-0F8h]
    319: jb      418h
    31f: lea     rax,[rbp-30h]
    323: mov     [rbp-108h],rax
    32a: mov     rax,[rbp-0C8h]
    331: mov     [rbp-110h],rax
    338: mov     rax,[rbp-108h]
    33f: mov     [rbp-170h],rax
    346: mov     rax,[rbp-110h]
    34d: mov     [rbp-168h],rax
    354: mov     edi,0FFFFFEA0h
    359: lea     rsi,[k19]
    360: call    ryo_h_AddrAbs
    365: call    fn20
    36a: nop     [rcx-100h]
    371: mov     byte ptr [rbp-150h],0
    378: mov     rax,[rbp-100h]
    37f: movzx   ecx,byte ptr [rbp-150h]
    386: mov     [rax],cl
    388: mov     rax,[rbp-70h]
    38c: mov     [rbp-118h],rax
    393: mov     edi,0FFFFFED8h
    398: mov     esi,0FFFFFEE0h
    39d: mov     edx,0FFFFFF38h
    3a2: mov     ecx,0FFFFFEE8h
    3a7: call    ryo_h_AddOvfUW64
    3ac: test    byte ptr [rbp-120h],0FFh
    3b3: je      405h
    3b5: mov     edi,0FFFFFE90h
    3ba: lea     rsi,[k21]
    3c1: call    ryo_h_AddrAbs
    3c6: lea     rdi,[sym22]
    3cd: lea     rsi,[site23]
    3d4: mov     edx,0FFFFFEB8h
    3d9: call    ryo_h_CallExt
    3de: test    rax,rax
    3e1: je      3EEh
    3e3: call    rax
    3e5: nop     [rcx-140h]
    3ec: jmp     3FEh
    3ee: mov     rdi,rbp
    3f1: lea     rsi,[ro+4]
    3f8: call    qword ptr [sym24]
    3fe: call    ryo_h_Unreachable
    403: ud2
    405: mov     rax,[rbp-128h]
    40c: mov     [rbp-0C8h],rax
    413: jmp     300h
    418: mov     qword ptr [rbp-148h],1
    423: mov     edi,0FFFFFEC8h
    428: mov     esi,0FFFFFED0h
    42d: mov     edx,0FFFFFF90h
    432: mov     ecx,0FFFFFEB8h
    437: call    ryo_h_AddOvfUW64
    43c: test    byte ptr [rbp-130h],0FFh
    443: je      495h
    445: mov     edi,0FFFFFE90h
    44a: lea     rsi,[k25]
    451: call    ryo_h_AddrAbs
    456: lea     rdi,[sym26]
    45d: lea     rsi,[site27]
    464: mov     edx,0FFFFFEB8h
    469: call    ryo_h_CallExt
    46e: test    rax,rax
    471: je      47Eh
    473: call    rax
    475: nop     [rcx-140h]
    47c: jmp     48Eh
    47e: mov     rdi,rbp
    481: lea     rsi,[ro+4]
    488: call    qword ptr [sym28]
    48e: call    ryo_h_Unreachable
    493: ud2
    495: mov     rax,[rbp-138h]
    49c: mov     [rbp-70h],rax
    4a0: jmp     150h
    4a5: mov     edi,0FFFFFFE8h
    4aa: mov     esi,0FFFFFFD0h
    4af: mov     edx,18h
    4b4: call    ryo_h_Copy
    4b9: mov     edi,0FFFFFFE8h
    4be: mov     esi,18h
    4c3: call    ryo_h_Ret
    4c8: leave
    4c9: ret
    4ca: nop     [rax+rax]
    4d0: lea     rax,[rbp-30h]
    4d4: mov     [rbp-148h],rax
    4db: mov     [rbp-170h],rax
    4e2: call    fn29
    4e7: nop     [rcx-148h]
    4ee: mov     edi,0FFFFFEC0h
    4f3: call    ryo_h_Resume
    4f8: ud2
    4fa: nop     [rax+rax]
    500: lea     rdi,[sym30]
    507: lea     rsi,[site31]
    50e: mov     edx,0FFFFFEB8h
    513: call    ryo_h_CallExt
    518: test    rax,rax
    51b: je      528h
    51d: call    rax
    51f: nop     [rcx-140h]
    526: jmp     538h
    528: mov     rdi,rbp
    52b: lea     rsi,[ro+4]
    532: call    qword ptr [sym32]
    538: call    ryo_h_Unreachable
    53d: ud2
    53f: mov     rdi,rax
    542: mov     esi,0FFFFFEC0h
    547: call    ryo_h_Lpad
    54c: jmp     4D0h
    54e: mov     rdi,rax
    551: mov     esi,0FFFFFEC0h
    556: call    ryo_h_Lpad
    55b: jmp     500h

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-1],al
     12: mov     edi,0FFFFFFFFh
     17: mov     esi,1
     1c: call    ryo_h_Ret
     21: leave
     22: ret

fn std::cmp::impls::<impl std::cmp::PartialEq for usize>::eq
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
     26: sete    [rbp-1]
     2a: mov     edi,0FFFFFFFFh
     2f: mov     esi,1
     34: call    ryo_h_Ret
     39: leave
     3a: ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le
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
     26: setbe   [rbp-1]
     2a: mov     edi,0FFFFFFFFh
     2f: mov     esi,1
     34: call    ryo_h_Ret
     39: leave
     3a: ret

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

fn std::fmt::Arguments::<'_>::new::<39, 3>
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

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rax,[rbp+18h]
     14: mov     [rbp-38h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-28h]
     20: mov     [rbp-50h],rax
     24: mov     rax,[rbp-30h]
     28: mov     [rbp-48h],rax
     2c: call    fn0
     31: nop     [rcx-19h]
     38: test    byte ptr [rbp-19h],0FFh
     3c: je      54h
     3e: mov     rax,[rbp+18h]
     42: mov     [rbp-28h],rax
     46: mov     [rbp-8],rax
     4a: mov     qword ptr [rbp-10h],1
     52: jmp     5Ch
     54: mov     qword ptr [rbp-10h],0
     5c: mov     edi,0FFFFFFF0h
     61: mov     esi,10h
     66: call    ryo_h_Ret
     6b: leave
     6c: ret
     6d: nop     [rax]
     70: mov     edi,0FFFFFFE8h
     75: call    ryo_h_Resume
     7a: ud2
     7c: mov     rdi,rax
     7f: mov     esi,0FFFFFFE8h
     84: call    ryo_h_Lpad
     89: jmp     70h

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     byte ptr [rbp-9],1
     14: mov     rax,[rbp+18h]
     18: mov     [rbp-38h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     [rbp-48h],rax
     24: mov     rax,[rbp+20h]
     28: mov     [rbp-50h],rax
     2c: mov     rax,[rbp-48h]
     30: mov     [rbp-70h],rax
     34: mov     rax,[rbp-50h]
     38: mov     [rbp-68h],rax
     3c: call    fn0
     41: nop     [rcx-40h]
     48: mov     byte ptr [rbp-9],0
     4c: mov     rax,[rbp-38h]
     50: mov     [rbp-30h],rax
     54: mov     rax,[rbp-40h]
     58: mov     [rbp-28h],rax
     5c: mov     rax,[rbp-20h]
     60: mov     [rbp-70h],rax
     64: mov     rax,[rbp-30h]
     68: mov     [rbp-68h],rax
     6c: mov     rax,[rbp-28h]
     70: mov     [rbp-60h],rax
     74: call    fn1
     79: nop     [rcx-8]
     80: mov     edi,0FFFFFFF8h
     85: mov     esi,8
     8a: call    ryo_h_Ret
     8f: leave
     90: ret
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: mov     edi,0FFFFFFE8h
     a5: call    ryo_h_Resume
     aa: ud2
     ac: nop     [rax]
     b0: jmp     0A0h
     b2: nop     [rax+rax]
     bb: nop     [rax+rax]
     c0: test    byte ptr [rbp-9],0FFh
     c4: je      0A0h
     c6: jmp     0B0h
     c8: mov     rdi,rax
     cb: mov     esi,0FFFFFFE8h
     d0: call    ryo_h_Lpad
     d5: jmp     0C0h

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-18h],rax
     18: call    fn0
     1d: nop     [rcx-10h]
     24: mov     edi,0FFFFFFF0h
     29: mov     esi,10h
     2e: call    ryo_h_Ret
     33: leave
     34: ret

fn std::ops::RangeInclusive::<usize>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-10h],rax
     18: mov     byte ptr [rbp-8],0
     1c: mov     edi,0FFFFFFE8h
     21: mov     esi,18h
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn std::option::Option::<usize>::unwrap
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     edi,0FFFFFFF0h
     15: xor     esi,esi
     17: mov     edx,2
     1c: call    ryo_h_SwitchDenseW64
     21: lea     rcx,[34h]
     28: movsxd  rax,[rcx+rax*4]
     2c: add     rax,rcx
     2f: jmp     rax
     31: int3
     32: int3
     33: int3
     34: .long   47h
     38: .long   8eh
     3c: .long   40h
     40: call    ryo_h_Unreachable
     45: ud2
     47: mov     rax,[rbp+20h]
     4b: mov     [rbp-20h],rax
     4f: lea     rdi,[sym0]
     56: lea     rsi,[site1]
     5d: mov     edx,0FFFFFFE8h
     62: call    ryo_h_CallExt
     67: test    rax,rax
     6a: je      77h
     6c: call    rax
     6e: nop     [rcx-10h]
     75: jmp     87h
     77: mov     rdi,rbp
     7a: lea     rsi,[ro+4]
     81: call    qword ptr [sym2]
     87: call    ryo_h_Unreachable
     8c: ud2
     8e: mov     rax,[rbp+18h]
     92: mov     [rbp-8],rax
     96: mov     edi,0FFFFFFF8h
     9b: mov     esi,8
     a0: call    ryo_h_Ret
     a5: leave
     a6: ret

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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
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

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
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

fn std::slice::Iter::<'_, bool>::new
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
     66: imul    rcx,[rbp-20h],1
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

fn std::vec::Vec::<bool>::extend_with
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     byte ptr [rbp-31h],1
      f: mov     rax,[rbp+10h]
     13: mov     [rbp-0A0h],rax
     1a: mov     rax,[rbp+18h]
     1e: mov     [rbp-98h],rax
     25: call    fn0
     2a: nop     [rcx]
     31: mov     rax,[rbp+10h]
     35: mov     rax,[rax+8]
     39: mov     [rbp-60h],rax
     3d: mov     [rbp-58h],rax
     41: mov     rax,[rbp+10h]
     45: mov     rax,[rax+10h]
     49: mov     [rbp-60h],rax
     4d: mov     rcx,7FFFFFFFFFFFFFFFh
     57: cmp     rax,rcx
     5a: setbe   [rbp-61h]
     5e: mov     rax,[rbp-58h]
     62: imul    rcx,[rbp-60h],1
     67: add     rax,rcx
     6a: mov     [rbp-8],rax
     6e: mov     rax,[rbp+10h]
     72: lea     rax,[rax+10h]
     76: mov     [rbp-68h],rax
     7a: mov     rax,[rax]
     7d: mov     [rbp-70h],rax
     81: mov     rax,[rbp-68h]
     85: mov     [rbp-60h],rax
     89: mov     rax,[rbp-70h]
     8d: mov     [rbp-58h],rax
     91: mov     qword ptr [rbp-18h],1
     99: mov     rax,[rbp+18h]
     9d: mov     [rbp-10h],rax
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-70h],rax
     b8: mov     rax,[rbp-10h]
     bc: mov     [rbp-78h],rax
     c0: mov     rax,[rbp-70h]
     c4: cmp     rax,[rbp-78h]
     c8: setb    [rbp-61h]
     cc: test    byte ptr [rbp-61h],0FFh
     d0: je      20Ch
     d6: jmp     1F8h
     db: nop     [rax+rax]
     e0: mov     rax,[rbp-68h]
     e4: movzx   ecx,byte ptr [rbp-69h]
     e8: mov     [rax],cl
     ea: mov     qword ptr [rbp-80h],1
     f2: mov     rax,[rbp-8]
     f6: imul    rcx,[rbp-80h],1
     fb: add     rax,rcx
     fe: mov     [rbp-68h],rax
    102: mov     [rbp-8],rax
    106: mov     rax,[rbp-58h]
    10a: add     rax,1
    10e: mov     [rbp-58h],rax
    112: jmp     0B0h
    114: nop     [rax+rax]
    11d: nop     [rax]
    120: mov     byte ptr [rbp-31h],0
    124: movzx   eax,byte ptr [rbp+20h]
    128: mov     [rbp-62h],al
    12b: mov     rax,[rbp-8]
    12f: movzx   ecx,byte ptr [rbp-62h]
    133: mov     [rax],cl
    135: mov     rax,[rbp-58h]
    139: add     rax,1
    13d: mov     [rbp-58h],rax
    141: lea     rax,[rbp-60h]
    145: mov     [rbp-80h],rax
    149: mov     [rbp-0A0h],rax
    150: call    fn1
    155: nop     [rcx-80h]
    15c: jmp     287h
    161: nop     [rax+rax]
    16a: nop     [rax+rax]
    170: lea     rax,[rbp-60h]
    174: mov     [rbp-80h],rax
    178: mov     [rbp-0A0h],rax
    17f: call    fn2
    184: nop     [rcx-80h]
    18b: test    byte ptr [rbp-31h],0FFh
    18f: jne     1DCh
    191: nop     [rax+rax]
    19a: nop     [rax+rax]
    1a0: xor     edi,edi
    1a2: xor     esi,esi
    1a4: call    ryo_h_Ret
    1a9: leave
    1aa: ret
    1ab: nop     [rax+rax]
    1b0: lea     rax,[rbp-60h]
    1b4: mov     [rbp-80h],rax
    1b8: mov     [rbp-0A0h],rax
    1bf: call    fn3
    1c4: nop     [rcx-80h]
    1cb: jmp     1F0h
    1cd: nop     [rax]
    1d0: mov     edi,0FFFFFFB0h
    1d5: call    ryo_h_Resume
    1da: ud2
    1dc: jmp     1A0h
    1de: xchg    ax,ax
    1e0: jmp     1D0h
    1e2: nop     [rax+rax]
    1eb: nop     [rax+rax]
    1f0: test    byte ptr [rbp-31h],0FFh
    1f4: je      1D0h
    1f6: jmp     1E0h
    1f8: mov     rax,[rbp-18h]
    1fc: mov     [rbp-70h],rax
    200: mov     byte ptr [rbp-79h],1
    204: test    byte ptr [rbp-79h],0FFh
    208: je      24Fh
    20a: jmp     21Ch
    20c: cmp     qword ptr [rbp+18h],0
    211: ja      120h
    217: jmp     170h
    21c: mov     rax,[rbp-70h]
    220: mov     [rbp-0A0h],rax
    227: mov     qword ptr [rbp-98h],1
    232: mov     edi,0FFFFFF70h
    237: lea     rsi,[k4]
    23e: call    ryo_h_AddrAbs
    243: call    fn5
    248: nop     [rcx-48h]
    24f: mov     rax,[rbp-70h]
    253: add     rax,1
    257: mov     [rbp-78h],rax
    25b: mov     [rbp-18h],rax
    25f: mov     rax,[rbp-8]
    263: mov     [rbp-68h],rax
    267: lea     rax,[rbp+20h]
    26b: mov     [rbp-78h],rax
    26f: mov     [rbp-0A0h],rax
    276: call    fn6
    27b: nop     [rcx-69h]
    282: jmp     0E0h
    287: jmp     1A0h
    28c: nop     [rax]
    290: lea     rdi,[sym7]
    297: lea     rsi,[site8]
    29e: mov     edx,0FFFFFF80h
    2a3: call    ryo_h_CallExt
    2a8: test    rax,rax
    2ab: je      2B8h
    2ad: call    rax
    2af: nop     [rcx-78h]
    2b6: jmp     2C8h
    2b8: mov     rdi,rbp
    2bb: lea     rsi,[ro+4]
    2c2: call    qword ptr [sym9]
    2c8: call    ryo_h_Unreachable
    2cd: ud2
    2cf: mov     rdi,rax
    2d2: mov     esi,0FFFFFFB0h
    2d7: call    ryo_h_Lpad
    2dc: jmp     1F0h
    2e1: mov     rdi,rax
    2e4: mov     esi,0FFFFFFB0h
    2e9: call    ryo_h_Lpad
    2ee: jmp     290h
    2f0: mov     rdi,rax
    2f3: mov     esi,0FFFFFFB0h
    2f8: call    ryo_h_Lpad
    2fd: jmp     1B0h

fn std::vec::Vec::<bool>::reserve
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

fn std::vec::from_elem::<bool>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: movzx   eax,byte ptr [rbp+10h]
      c: mov     [rbp-28h],al
      f: mov     rax,[rbp+18h]
     13: mov     [rbp-30h],rax
     17: call    fn0
     1c: nop     [rcx-18h]
     23: mov     edi,0FFFFFFE8h
     28: mov     esi,18h
     2d: call    ryo_h_Ret
     32: leave
     33: ret

