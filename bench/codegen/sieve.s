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

fn <bool as std::vec::is_zero::IsZero>::is_zero
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-2],al
     12: movzx   eax,byte ptr [rbp-2]
     16: xor     al,1
     19: mov     [rbp-1],al
     1c: mov     edi,0FFFFFFFFh
     21: mov     esi,1
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     byte ptr [rbp-1Ah],1
      f: mov     byte ptr [rbp-19h],1
     13: lea     rax,[rbp+18h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-0B0h],rax
     26: call    fn0
     2b: nop     [rcx-29h]
     32: test    byte ptr [rbp-29h],0FFh
     36: je      0A1h
     38: mov     byte ptr [rbp-19h],0
     3c: mov     rax,[rbp+10h]
     40: mov     [rbp-0B0h],rax
     47: mov     byte ptr [rbp-0A8h],1
     4e: mov     edi,0FFFFFF60h
     53: lea     rsi,[k1]
     5a: mov     edx,10h
     5f: call    ryo_h_Const
     64: lea     rdi,[sym2]
     6b: lea     rsi,[site3]
     72: mov     edx,0FFFFFF78h
     77: call    ryo_h_CallExt
     7c: test    rax,rax
     7f: je      8Ch
     81: call    rax
     83: nop     [rcx-68h]
     8a: jmp     9Ch
     8c: mov     rdi,rbp
     8f: lea     rsi,[ro+4]
     96: call    qword ptr [sym4]
     9c: jmp     18Ah
     a1: mov     byte ptr [rbp-19h],0
     a5: mov     rax,[rbp+10h]
     a9: mov     [rbp-0B0h],rax
     b0: mov     edi,0FFFFFF58h
     b5: lea     rsi,[k5]
     bc: mov     edx,10h
     c1: call    ryo_h_Const
     c6: call    fn6
     cb: nop     [rcx-60h]
     d2: jmp     25Eh
     d7: nop     [rax+rax]
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
    12b: mov     rax,[rbp-88h]
    132: mov     [rbp-0B0h],rax
    139: call    fn7
    13e: nop     [rcx-88h]
    145: jmp     180h
    147: nop     [rax+rax]
    150: test    byte ptr [rbp-1Ah],0FFh
    154: jne     188h
    156: nop     [rax+rax]
    15f: nop
    160: mov     edi,0FFFFFFD8h
    165: call    ryo_h_Resume
    16a: ud2
    16c: nop     [rax]
    170: jmp     150h
    172: nop     [rax+rax]
    17b: nop     [rax+rax]
    180: test    byte ptr [rbp-19h],0FFh
    184: je      150h
    186: jmp     170h
    188: jmp     160h
    18a: mov     rax,[rbp-68h]
    18e: mov     [rbp-70h],rax
    192: mov     edi,0FFFFFF90h
    197: xor     esi,esi
    199: mov     edx,2
    19e: call    ryo_h_SwitchDenseW64
    1a3: lea     rcx,[1B4h]
    1aa: movsxd  rax,[rcx+rax*4]
    1ae: add     rax,rcx
    1b1: jmp     rax
    1b3: int3
    1b4: .long   224h
    1b8: .long   1c7h
    1bc: .long   1c0h
    1c0: call    ryo_h_Unreachable
    1c5: ud2
    1c7: mov     edi,0FFFFFF80h
    1cc: mov     esi,0FFFFFFA0h
    1d1: call    ryo_h_MovW128
    1d6: mov     edi,0FFFFFF50h
    1db: mov     esi,0FFFFFF80h
    1e0: call    ryo_h_MovW128
    1e5: lea     rdi,[sym8]
    1ec: lea     rsi,[site9]
    1f3: mov     edx,0FFFFFF78h
    1f8: call    ryo_h_CallExt
    1fd: test    rax,rax
    200: je      20Dh
    202: call    rax
    204: nop     [rcx-1Ah]
    20b: jmp     21Dh
    20d: mov     rdi,rbp
    210: lea     rsi,[ro+20]
    217: call    qword ptr [sym10]
    21d: call    ryo_h_Unreachable
    222: ud2
    224: mov     edi,0FFFFFFB0h
    229: mov     esi,0FFFFFFA0h
    22e: call    ryo_h_MovW128
    233: mov     edi,0FFFFFFC0h
    238: mov     esi,0FFFFFFB0h
    23d: call    ryo_h_MovW128
    242: mov     edi,0FFFFFFE8h
    247: mov     esi,0FFFFFFC0h
    24c: call    ryo_h_MovW128
    251: mov     rax,[rbp+10h]
    255: mov     [rbp-8],rax
    259: jmp     100h
    25e: mov     edi,0FFFFFFB0h
    263: mov     esi,0FFFFFFA0h
    268: call    ryo_h_MovW128
    26d: mov     edi,0FFFFFFC0h
    272: mov     esi,0FFFFFFB0h
    277: call    ryo_h_MovW128
    27c: mov     qword ptr [rbp-30h],0
    284: lea     rax,[rbp-40h]
    288: mov     [rbp-48h],rax
    28c: mov     byte ptr [rbp-1Ah],0
    290: movzx   eax,byte ptr [rbp+18h]
    294: mov     [rbp-49h],al
    297: mov     rax,[rbp-48h]
    29b: mov     [rbp-0B0h],rax
    2a2: mov     rax,[rbp+10h]
    2a6: mov     [rbp-0A8h],rax
    2ad: movzx   eax,byte ptr [rbp-49h]
    2b1: mov     [rbp-0A0h],al
    2b7: call    fn11
    2bc: nop     [rcx-18h]
    2c3: jmp     0E0h
    2c8: nop     [rax+rax]
    2d0: lea     rdi,[sym12]
    2d7: lea     rsi,[site13]
    2de: mov     edx,0FFFFFF78h
    2e3: call    ryo_h_CallExt
    2e8: test    rax,rax
    2eb: je      2F8h
    2ed: call    rax
    2ef: nop     [rcx-80h]
    2f6: jmp     308h
    2f8: mov     rdi,rbp
    2fb: lea     rsi,[ro+36]
    302: call    qword ptr [sym14]
    308: call    ryo_h_Unreachable
    30d: ud2
    30f: mov     rdi,rax
    312: mov     esi,0FFFFFFD8h
    317: call    ryo_h_Lpad
    31c: jmp     180h
    321: mov     rdi,rax
    324: mov     esi,0FFFFFFD8h
    329: call    ryo_h_Lpad
    32e: jmp     2D0h
    330: mov     rdi,rax
    333: mov     esi,0FFFFFFD8h
    338: call    ryo_h_Lpad
    33d: jmp     120h

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
     18: mov     rax,[rbp-30h]
     1c: mov     [rbp-28h],rax
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-40h],rax
     28: mov     rax,[rbp-28h]
     2c: mov     [rbp-38h],rax
     30: call    fn0
     35: nop     [rcx-11h]
     3c: mov     edi,0FFFFFFF8h
     41: mov     esi,0FFFFFFEFh
     46: call    ryo_h_ZextW8W64
     4b: mov     edi,0FFFFFFF8h
     50: mov     esi,8
     55: call    ryo_h_Ret
     5a: leave
     5b: ret
     5c: nop     [rax]
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
     18: mov     rax,[rbp-50h]
     1c: mov     [rbp-70h],rax
     20: call    fn0
     25: nop     [rcx-48h]
     2c: mov     edi,0FFFFFFD0h
     31: mov     esi,0FFFFFFC0h
     36: call    ryo_h_MovW128
     3b: mov     rax,[rbp-30h]
     3f: mov     [rbp-50h],rax
     43: mov     edi,0FFFFFFB0h
     48: xor     esi,esi
     4a: mov     edx,2
     4f: call    ryo_h_SwitchDenseW64
     54: lea     rcx,[64h]
     5b: movsxd  rax,[rcx+rax*4]
     5f: add     rax,rcx
     62: jmp     rax
     64: .long   14eh
     68: .long   158h
     6c: .long   147h
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
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-30h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx-10h]
     2c: mov     edi,0FFFFFFF0h
     31: mov     esi,10h
     36: call    ryo_h_Ret
     3b: leave
     3c: ret

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     qword ptr [rbp-18h],1
     10: cmp     qword ptr [rbp-18h],1
     15: sete    [rbp-19h]
     19: mov     rax,[rbp+10h]
     1d: mov     [rbp-28h],rax
     21: mov     rax,[rbp-28h]
     25: mov     [rbp-8],rax
     29: mov     qword ptr [rbp-10h],1
     31: mov     edi,0FFFFFFF0h
     36: mov     esi,10h
     3b: call    ryo_h_Ret
     40: leave
     41: ret

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
     34: .long   69h
     38: .long   47h
     3c: .long   40h
     40: call    ryo_h_Unreachable
     45: ud2
     47: mov     rax,[rbp+18h]
     4b: mov     [rbp-20h],rax
     4f: mov     rax,[rbp-20h]
     53: mov     [rbp-28h],rax
     57: mov     rax,[rbp-28h]
     5b: mov     [rbp-8],rax
     5f: mov     qword ptr [rbp-10h],1
     67: jmp     71h
     69: mov     qword ptr [rbp-10h],0
     71: mov     edi,0FFFFFFF0h
     76: mov     esi,10h
     7b: call    ryo_h_Ret
     80: leave
     81: ret

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
     58: .long   91h
     5c: .long   77h
     60: .long   70h
     64: nop     [rax+rax]
     6d: nop     [rax]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     rax,[rbp-18h]
     7b: mov     [rbp-30h],rax
     7f: mov     rax,[rbp-30h]
     83: mov     [rbp-8],rax
     87: mov     qword ptr [rbp-10h],1
     8f: jmp     0B3h
     91: mov     qword ptr [rbp-10h],0
     99: jmp     0B3h
     9b: nop     [rax+rax]
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
     1e: je      32Fh
     24: jmp     32Ah
     29: nop     [rax]
     30: mov     byte ptr [rbp-2Ah],0
     34: call    fn0
     39: nop     [rcx-10h]
     40: jmp     2C1h
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
     9a: je      1A4h
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+8]
     a8: mov     [rbp-50h],rax
     ac: mov     rax,[rbp-50h]
     b0: mov     [rbp-0A0h],rax
     b7: mov     qword ptr [rbp-98h],1
     c2: call    fn2
     c7: nop     [rcx-48h]
     ce: mov     rax,[rbp+10h]
     d2: mov     rax,[rax+8]
     d6: mov     [rbp-50h],rax
     da: mov     rax,[rbp+10h]
     de: mov     rcx,[rbp-48h]
     e2: mov     [rax+8],rcx
     e6: lea     rax,[rbp+18h]
     ea: mov     [rbp-78h],rax
     ee: mov     byte ptr [rbp-29h],0
     f2: mov     rax,[rbp-50h]
     f6: mov     [rbp-80h],rax
     fa: mov     rax,[rbp-78h]
     fe: mov     [rbp-0A0h],rax
    105: mov     rax,[rbp-80h]
    109: mov     [rbp-98h],rax
    110: call    fn3
    115: nop     [rcx-70h]
    11c: mov     edi,0FFFFFF60h
    121: mov     esi,0FFFFFF90h
    126: call    ryo_h_MovW128
    12b: call    fn4
    130: nop     [rcx-60h]
    137: mov     rax,[rbp-60h]
    13b: mov     [rbp-20h],rax
    13f: mov     edi,0FFFFFFE0h
    144: xor     esi,esi
    146: mov     edx,2
    14b: call    ryo_h_SwitchDenseW64
    150: lea     rcx,[160h]
    157: movsxd  rax,[rcx+rax*4]
    15b: add     rax,rcx
    15e: jmp     rax
    160: .long   177h
    164: .long   180h
    168: .long   170h
    16c: nop     [rax]
    170: call    ryo_h_Unreachable
    175: ud2
    177: mov     byte ptr [rbp-29h],1
    17b: jmp     60h
    180: mov     rax,[rbp-58h]
    184: mov     [rbp-68h],rax
    188: mov     rax,[rbp-68h]
    18c: mov     [rbp-0A0h],rax
    193: call    fn5
    198: nop     [rcx-10h]
    19f: jmp     2C1h
    1a4: mov     byte ptr [rbp-90h],1
    1ab: mov     rax,[rbp+10h]
    1af: movzx   ecx,byte ptr [rbp-90h]
    1b6: mov     [rax+10h],cl
    1b9: mov     rax,[rbp+10h]
    1bd: mov     [rbp-48h],rax
    1c1: mov     rax,[rbp+10h]
    1c5: lea     rax,[rax+8]
    1c9: mov     [rbp-50h],rax
    1cd: mov     rax,[rbp-48h]
    1d1: mov     [rbp-0A0h],rax
    1d8: mov     rax,[rbp-50h]
    1dc: mov     [rbp-98h],rax
    1e3: call    fn6
    1e8: nop     [rcx-39h]
    1ef: test    byte ptr [rbp-39h],0FFh
    1f3: je      2AFh
    1f9: lea     rax,[rbp+18h]
    1fd: mov     [rbp-68h],rax
    201: mov     byte ptr [rbp-29h],0
    205: mov     rax,[rbp+10h]
    209: mov     rax,[rax]
    20c: mov     [rbp-78h],rax
    210: mov     rax,[rbp-78h]
    214: mov     [rbp-70h],rax
    218: mov     rax,[rbp-68h]
    21c: mov     [rbp-0A0h],rax
    223: mov     rax,[rbp-70h]
    227: mov     [rbp-98h],rax
    22e: call    fn7
    233: nop     [rcx-60h]
    23a: mov     edi,0FFFFFF60h
    23f: mov     esi,0FFFFFFA0h
    244: call    ryo_h_MovW128
    249: call    fn8
    24e: nop     [rcx-50h]
    255: mov     rax,[rbp-50h]
    259: mov     [rbp-28h],rax
    25d: mov     edi,0FFFFFFD8h
    262: xor     esi,esi
    264: mov     edx,2
    269: call    ryo_h_SwitchDenseW64
    26e: lea     rcx,[280h]
    275: movsxd  rax,[rcx+rax*4]
    279: add     rax,rcx
    27c: jmp     rax
    27e: int3
    27f: int3
    280: .long   28ch
    284: .long   28eh
    288: .long   170h
    28c: jmp     2AFh
    28e: mov     rax,[rbp-48h]
    292: mov     [rbp-58h],rax
    296: mov     rax,[rbp-58h]
    29a: mov     [rbp-0A0h],rax
    2a1: call    fn9
    2a6: nop     [rcx-10h]
    2ad: jmp     2C1h
    2af: mov     byte ptr [rbp-29h],0
    2b3: call    fn10
    2b8: nop     [rcx-10h]
    2bf: jmp     2C1h
    2c1: mov     edi,0FFFFFFF0h
    2c6: mov     esi,10h
    2cb: call    ryo_h_Ret
    2d0: leave
    2d1: ret
    2d2: nop     [rax+rax]
    2db: nop     [rax+rax]
    2e0: jmp     322h
    2e2: nop     [rax+rax]
    2eb: nop     [rax+rax]
    2f0: mov     edi,0FFFFFFC8h
    2f5: call    ryo_h_Resume
    2fa: ud2
    2fc: nop     [rax]
    300: jmp     2E0h
    302: nop     [rax+rax]
    30b: nop     [rax+rax]
    310: test    byte ptr [rbp-29h],0FFh
    314: je      2E0h
    316: jmp     300h
    318: nop     [rax+rax]
    320: jmp     2F0h
    322: test    byte ptr [rbp-2Ah],0FFh
    326: je      2F0h
    328: jmp     320h
    32a: jmp     30h
    32f: mov     rax,[rbp+10h]
    333: mov     [rbp-48h],rax
    337: mov     rax,[rbp+10h]
    33b: lea     rax,[rax+8]
    33f: mov     [rbp-50h],rax
    343: mov     rax,[rbp-48h]
    347: mov     [rbp-0A0h],rax
    34e: mov     rax,[rbp-50h]
    352: mov     [rbp-98h],rax
    359: call    fn11
    35e: nop     [rcx-3Bh]
    365: movzx   eax,byte ptr [rbp-3Bh]
    369: xor     al,1
    36c: mov     [rbp-39h],al
    36f: test    byte ptr [rbp-39h],0FFh
    373: je      50h
    379: jmp     30h
    37e: mov     rdi,rax
    381: mov     esi,0FFFFFFC8h
    386: call    ryo_h_Lpad
    38b: jmp     2E0h
    390: mov     rdi,rax
    393: mov     esi,0FFFFFFC8h
    398: call    ryo_h_Lpad
    39d: jmp     310h

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
    14f: imul    rcx,[rbp-90h],1
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
    1cf: je      39Eh
    1d5: jmp     36Bh
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
    2b3: cmp     qword ptr [rbp-0A8h],1
    2bb: setb    [rbp-71h]
    2bf: test    byte ptr [rbp-71h],0FFh
    2c3: je      2FFh
    2c5: mov     qword ptr [rbp-0A8h],1
    2d0: mov     rax,[rbp-0A8h]
    2d7: mov     rcx,7FFFFFFFFFFFFFFFh
    2e1: cmp     rax,rcx
    2e4: setbe   [rbp-72h]
    2e8: test    byte ptr [rbp-72h],0FFh
    2ec: je      2FFh
    2ee: mov     rax,[rbp-70h]
    2f2: sub     rax,[rbp-68h]
    2f6: mov     [rbp-28h],rax
    2fa: jmp     260h
    2ff: mov     edi,0FFFFFF40h
    304: lea     rsi,[k3]
    30b: call    ryo_h_AddrAbs
    310: mov     qword ptr [rbp-0B8h],49h
    31b: mov     edi,0FFFFFF50h
    320: lea     rsi,[k4]
    327: call    ryo_h_AddrAbs
    32c: lea     rdi,[sym5]
    333: lea     rsi,[site6]
    33a: mov     edx,0FFFFFF58h
    33f: call    ryo_h_CallExt
    344: test    rax,rax
    347: je      354h
    349: call    rax
    34b: nop     [rcx-32h]
    352: jmp     364h
    354: mov     rdi,rbp
    357: lea     rsi,[ro+4]
    35e: call    qword ptr [sym7]
    364: call    ryo_h_Unreachable
    369: ud2
    36b: mov     rax,[rbp-20h]
    36f: mov     [rbp-0C0h],rax
    376: mov     qword ptr [rbp-0B8h],1
    381: mov     edi,0FFFFFF50h
    386: lea     rsi,[k8]
    38d: call    ryo_h_AddrAbs
    392: call    fn9
    397: nop     [rcx-32h]
    39e: mov     rax,[rbp-20h]
    3a2: add     rax,1
    3a6: mov     [rbp-50h],rax
    3aa: mov     rax,[rbp-50h]
    3ae: mov     [rbp-20h],rax
    3b2: mov     rax,[rbp-20h]
    3b6: mov     [rbp-58h],rax
    3ba: mov     rax,[rbp-28h]
    3be: mov     [rbp-60h],rax
    3c2: mov     rax,[rbp-58h]
    3c6: cmp     rax,[rbp-60h]
    3ca: je      1E0h
    3d0: jmp     1F0h
    3d5: mov     rdi,rax
    3d8: mov     esi,0FFFFFFC0h
    3dd: call    ryo_h_Lpad
    3e2: jmp     240h

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
    107: cmp     qword ptr [rbp-60h],1
    10c: setb    [rbp-49h]
    110: test    byte ptr [rbp-49h],0FFh
    114: je      14Ah
    116: mov     qword ptr [rbp-60h],1
    11e: mov     rax,[rbp-60h]
    122: mov     rcx,7FFFFFFFFFFFFFFFh
    12c: cmp     rax,rcx
    12f: setbe   [rbp-4Ah]
    133: test    byte ptr [rbp-4Ah],0FFh
    137: je      14Ah
    139: mov     rax,[rbp-48h]
    13d: sub     rax,[rbp-40h]
    141: mov     [rbp-20h],rax
    145: jmp     0C0h
    14a: mov     edi,0FFFFFF80h
    14f: lea     rsi,[k2]
    156: call    ryo_h_AddrAbs
    15b: mov     qword ptr [rbp-78h],49h
    163: mov     edi,0FFFFFF90h
    168: lea     rsi,[k3]
    16f: call    ryo_h_AddrAbs
    174: lea     rdi,[sym4]
    17b: lea     rsi,[site5]
    182: mov     edx,0FFFFFFA0h
    187: call    ryo_h_CallExt
    18c: test    rax,rax
    18f: je      19Ch
    191: call    rax
    193: nop     [rcx-20h]
    19a: jmp     1ACh
    19c: mov     rdi,rbp
    19f: lea     rsi,[ro+4]
    1a6: call    qword ptr [sym6]
    1ac: call    ryo_h_Unreachable
    1b1: ud2

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

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
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
     75: imul    rcx,[rbp+20h],1
     7a: add     rax,rcx
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp-20h]
     85: mov     [rbp-8],rax
     89: mov     edi,0FFFFFFF8h
     8e: mov     esi,8
     93: call    ryo_h_Ret
     98: leave
     99: ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
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
     75: imul    rcx,[rbp+20h],1
     7a: add     rax,rcx
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp-20h]
     85: mov     [rbp-8],rax
     89: mov     edi,0FFFFFFF8h
     8e: mov     esi,8
     93: call    ryo_h_Ret
     98: leave
     99: ret

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
     41: mov     rax,[rbp-60h]
     45: mov     [rbp-1B0h],rax
     4c: call    fn2
     51: nop     [rcx-58h]
     58: mov     edi,0FFFFFE50h
     5d: mov     esi,0FFFFFFA8h
     62: call    ryo_h_MovW128
     67: call    fn3
     6c: nop     [rcx-48h]
     73: mov     edi,0FFFFFE50h
     78: mov     esi,0FFFFFFB8h
     7d: call    ryo_h_MovW128
     82: call    fn4
     87: nop     [rcx-38h]
     8e: mov     edi,0FFFFFE50h
     93: mov     esi,0FFFFFFC8h
     98: call    ryo_h_MovW128
     9d: call    fn5
     a2: nop     [rcx-28h]
     a9: mov     qword ptr [rbp-1B0h],0
     b4: mov     rax,[rbp-8]
     b8: mov     [rbp-1A8h],rax
     bf: call    fn6
     c4: nop     [rcx-0B0h]
     cb: mov     edi,0FFFFFE50h
     d0: mov     esi,0FFFFFF50h
     d5: mov     edx,18h
     da: call    ryo_h_Copy
     df: call    fn7
     e4: nop     [rcx-98h]
     eb: lea     rax,[rbp-98h]
     f2: mov     [rbp-80h],rax
     f6: lea     rax,[rbp-20h]
     fa: mov     [rbp-0C0h],rax
    101: mov     rax,[rbp-0C0h]
    108: mov     [rbp-0B8h],rax
    10f: mov     rax,[rbp-80h]
    113: mov     [rbp-1B0h],rax
    11a: mov     rax,[rbp-0B8h]
    121: mov     [rbp-1A8h],rax
    128: call    fn8
    12d: nop     [rcx-78h]
    134: mov     edi,0FFFFFE50h
    139: mov     esi,0FFFFFF88h
    13e: call    ryo_h_MovW128
    143: mov     edi,0FFFFFE60h
    148: lea     rsi,[k9]
    14f: call    ryo_h_AddrAbs
    154: call    fn10
    159: nop     [rcx-68h]
    160: lea     rax,[rbp-28h]
    164: mov     [rbp-0F0h],rax
    16b: lea     rax,[rbp-8]
    16f: mov     [rbp-0F8h],rax
    176: lea     rax,[rbp-68h]
    17a: mov     [rbp-100h],rax
    181: mov     rax,[rbp-0F0h]
    188: mov     [rbp-0E8h],rax
    18f: mov     rax,[rbp-0F8h]
    196: mov     [rbp-0E0h],rax
    19d: mov     rax,[rbp-100h]
    1a4: mov     [rbp-0D8h],rax
    1ab: mov     rax,[rbp-0E8h]
    1b2: mov     [rbp-178h],rax
    1b9: mov     rax,[rbp-178h]
    1c0: mov     [rbp-1B0h],rax
    1c7: call    fn11
    1cc: nop     [rcx-140h]
    1d3: mov     rax,[rbp-0E0h]
    1da: mov     [rbp-180h],rax
    1e1: mov     rax,[rbp-180h]
    1e8: mov     [rbp-1B0h],rax
    1ef: call    fn12
    1f4: nop     [rcx-150h]
    1fb: mov     rax,[rbp-0D8h]
    202: mov     [rbp-188h],rax
    209: mov     rax,[rbp-188h]
    210: mov     [rbp-1B0h],rax
    217: call    fn13
    21c: nop     [rcx-160h]
    223: mov     edi,0FFFFFED0h
    228: mov     esi,0FFFFFEC0h
    22d: call    ryo_h_MovW128
    232: mov     edi,0FFFFFEE0h
    237: mov     esi,0FFFFFEB0h
    23c: call    ryo_h_MovW128
    241: mov     edi,0FFFFFEF0h
    246: mov     esi,0FFFFFEA0h
    24b: call    ryo_h_MovW128
    250: mov     edi,0FFFFFE98h
    255: lea     rsi,[k14]
    25c: call    ryo_h_AddrAbs
    261: lea     rax,[rbp-130h]
    268: mov     [rbp-170h],rax
    26f: mov     rax,[rbp-168h]
    276: mov     [rbp-1B0h],rax
    27d: mov     rax,[rbp-170h]
    284: mov     [rbp-1A8h],rax
    28b: call    fn15
    290: nop     [rcx-0D0h]
    297: mov     edi,0FFFFFE50h
    29c: mov     esi,0FFFFFF30h
    2a1: call    ryo_h_MovW128
    2a6: lea     rdi,[sym16]
    2ad: lea     rsi,[site17]
    2b4: mov     edx,0FFFFFE68h
    2b9: call    ryo_h_CallExt
    2be: test    rax,rax
    2c1: je      2CEh
    2c3: call    rax
    2c5: nop     [rcx-0C0h]
    2cc: jmp     2DEh
    2ce: mov     rdi,rbp
    2d1: lea     rsi,[ro+4]
    2d8: call    qword ptr [sym18]
    2de: lea     rax,[rbp-20h]
    2e2: mov     [rbp-198h],rax
    2e9: mov     rax,[rbp-198h]
    2f0: mov     [rbp-1B0h],rax
    2f7: call    fn19
    2fc: nop     [rcx-198h]
    303: xor     edi,edi
    305: xor     esi,esi
    307: call    ryo_h_Ret
    30c: leave
    30d: ret
    30e: xchg    ax,ax
    310: lea     rax,[rbp-20h]
    314: mov     [rbp-198h],rax
    31b: mov     rax,[rbp-198h]
    322: mov     [rbp-1B0h],rax
    329: call    fn20
    32e: nop     [rcx-198h]
    335: mov     edi,0FFFFFE70h
    33a: call    ryo_h_Resume
    33f: ud2
    341: nop     [rax+rax]
    34a: nop     [rax+rax]
    350: lea     rdi,[sym21]
    357: lea     rsi,[site22]
    35e: mov     edx,0FFFFFE68h
    363: call    ryo_h_CallExt
    368: test    rax,rax
    36b: je      378h
    36d: call    rax
    36f: nop     [rcx-190h]
    376: jmp     388h
    378: mov     rdi,rbp
    37b: lea     rsi,[ro+20]
    382: call    qword ptr [sym23]
    388: call    ryo_h_Unreachable
    38d: ud2
    38f: mov     rdi,rax
    392: mov     esi,0FFFFFE70h
    397: call    ryo_h_Lpad
    39c: jmp     310h
    3a1: mov     rdi,rax
    3a4: mov     esi,0FFFFFE70h
    3a9: call    ryo_h_Lpad
    3ae: jmp     350h

fn main::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+18h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp-10h]
     17: movzx   eax,byte ptr [rax]
     1a: mov     [rbp-1],al
     1d: mov     edi,0FFFFFFFFh
     22: mov     esi,1
     27: call    ryo_h_Ret
     2c: leave
     2d: ret

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
     1e: mov     rax,[rbp-20h]
     22: mov     [rbp-40h],rax
     26: mov     rax,[rbp-10h]
     2a: mov     [rbp-38h],rax
     2e: mov     edi,0FFFFFFD0h
     33: lea     rsi,[k0]
     3a: call    ryo_h_AddrAbs
     3f: call    fn1
     44: nop     [rcx-18h]
     4b: mov     rax,[rbp-18h]
     4f: movzx   eax,byte ptr [rax]
     52: mov     [rbp-1],al
     55: mov     edi,0FFFFFFFFh
     5a: mov     esi,1
     5f: call    ryo_h_Ret
     64: leave
     65: ret

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
     94: mov     rax,[rbp-38h]
     98: mov     [rbp-168h],rax
     9f: call    fn4
     a4: nop     [rcx-30h]
     ab: lea     rax,[rbp-30h]
     af: mov     [rbp-58h],rax
     b3: mov     rax,[rbp-58h]
     b7: mov     [rbp-170h],rax
     be: mov     qword ptr [rbp-168h],0
     c9: mov     edi,0FFFFFEA0h
     ce: lea     rsi,[k5]
     d5: call    ryo_h_AddrAbs
     da: call    fn6
     df: nop     [rcx-50h]
     e6: mov     byte ptr [rbp-150h],0
     ed: mov     rax,[rbp-50h]
     f1: movzx   ecx,byte ptr [rbp-150h]
     f8: mov     [rax],cl
     fa: lea     rax,[rbp-30h]
     fe: mov     [rbp-68h],rax
    102: mov     rax,[rbp-68h]
    106: mov     [rbp-170h],rax
    10d: mov     qword ptr [rbp-168h],1
    118: mov     edi,0FFFFFEA0h
    11d: lea     rsi,[k7]
    124: call    ryo_h_AddrAbs
    129: call    fn8
    12e: nop     [rcx-60h]
    135: mov     byte ptr [rbp-150h],0
    13c: mov     rax,[rbp-60h]
    140: movzx   ecx,byte ptr [rbp-150h]
    147: mov     [rax],cl
    149: mov     qword ptr [rbp-70h],2
    151: nop     [rax+rax]
    15a: nop     [rax+rax]
    160: mov     rax,[rbp-70h]
    164: mov     [rbp-88h],rax
    16b: mov     rax,[rbp-70h]
    16f: mov     [rbp-90h],rax
    176: mov     edi,0FFFFFF60h
    17b: mov     esi,0FFFFFF68h
    180: mov     edx,0FFFFFF78h
    185: mov     ecx,0FFFFFF70h
    18a: call    ryo_h_MulOvfUW64
    18f: test    byte ptr [rbp-98h],0FFh
    196: je      1E8h
    198: mov     edi,0FFFFFE90h
    19d: lea     rsi,[k9]
    1a4: call    ryo_h_AddrAbs
    1a9: lea     rdi,[sym10]
    1b0: lea     rsi,[site11]
    1b7: mov     edx,0FFFFFEB8h
    1bc: call    ryo_h_CallExt
    1c1: test    rax,rax
    1c4: je      1D1h
    1c6: call    rax
    1c8: nop     [rcx-140h]
    1cf: jmp     1E1h
    1d1: mov     rdi,rbp
    1d4: lea     rsi,[ro+4]
    1db: call    qword ptr [sym12]
    1e1: call    ryo_h_Unreachable
    1e6: ud2
    1e8: mov     rax,[rbp-0A0h]
    1ef: mov     [rbp-80h],rax
    1f3: mov     rax,[rbp+10h]
    1f7: cmp     rax,[rbp-80h]
    1fb: jb      4B5h
    201: lea     rax,[rbp-30h]
    205: mov     [rbp-0B8h],rax
    20c: mov     rax,[rbp-70h]
    210: mov     [rbp-0C0h],rax
    217: mov     rax,[rbp-0B8h]
    21e: mov     [rbp-170h],rax
    225: mov     rax,[rbp-0C0h]
    22c: mov     [rbp-168h],rax
    233: mov     edi,0FFFFFEA0h
    238: lea     rsi,[k13]
    23f: call    ryo_h_AddrAbs
    244: call    fn14
    249: nop     [rcx-0B0h]
    250: mov     rax,[rbp-0B0h]
    257: movzx   eax,byte ptr [rax]
    25a: mov     [rbp-0A1h],al
    260: test    byte ptr [rbp-0A1h],0FFh
    267: je      428h
    26d: mov     rax,[rbp-70h]
    271: mov     [rbp-0D0h],rax
    278: mov     rax,[rbp-70h]
    27c: mov     [rbp-0D8h],rax
    283: mov     edi,0FFFFFF18h
    288: mov     esi,0FFFFFF20h
    28d: mov     edx,0FFFFFF30h
    292: mov     ecx,0FFFFFF28h
    297: call    ryo_h_MulOvfUW64
    29c: test    byte ptr [rbp-0E0h],0FFh
    2a3: je      2F5h
    2a5: mov     edi,0FFFFFE90h
    2aa: lea     rsi,[k15]
    2b1: call    ryo_h_AddrAbs
    2b6: lea     rdi,[sym16]
    2bd: lea     rsi,[site17]
    2c4: mov     edx,0FFFFFEB8h
    2c9: call    ryo_h_CallExt
    2ce: test    rax,rax
    2d1: je      2DEh
    2d3: call    rax
    2d5: nop     [rcx-140h]
    2dc: jmp     2EEh
    2de: mov     rdi,rbp
    2e1: lea     rsi,[ro+4]
    2e8: call    qword ptr [sym18]
    2ee: call    ryo_h_Unreachable
    2f3: ud2
    2f5: mov     rax,[rbp-0E8h]
    2fc: mov     [rbp-0C8h],rax
    303: nop     [rax+rax]
    30c: nop     [rax]
    310: mov     rax,[rbp-0C8h]
    317: mov     [rbp-0F8h],rax
    31e: mov     rax,[rbp+10h]
    322: cmp     rax,[rbp-0F8h]
    329: jb      428h
    32f: lea     rax,[rbp-30h]
    333: mov     [rbp-108h],rax
    33a: mov     rax,[rbp-0C8h]
    341: mov     [rbp-110h],rax
    348: mov     rax,[rbp-108h]
    34f: mov     [rbp-170h],rax
    356: mov     rax,[rbp-110h]
    35d: mov     [rbp-168h],rax
    364: mov     edi,0FFFFFEA0h
    369: lea     rsi,[k19]
    370: call    ryo_h_AddrAbs
    375: call    fn20
    37a: nop     [rcx-100h]
    381: mov     byte ptr [rbp-150h],0
    388: mov     rax,[rbp-100h]
    38f: movzx   ecx,byte ptr [rbp-150h]
    396: mov     [rax],cl
    398: mov     rax,[rbp-70h]
    39c: mov     [rbp-118h],rax
    3a3: mov     edi,0FFFFFED8h
    3a8: mov     esi,0FFFFFEE0h
    3ad: mov     edx,0FFFFFF38h
    3b2: mov     ecx,0FFFFFEE8h
    3b7: call    ryo_h_AddOvfUW64
    3bc: test    byte ptr [rbp-120h],0FFh
    3c3: je      415h
    3c5: mov     edi,0FFFFFE90h
    3ca: lea     rsi,[k21]
    3d1: call    ryo_h_AddrAbs
    3d6: lea     rdi,[sym22]
    3dd: lea     rsi,[site23]
    3e4: mov     edx,0FFFFFEB8h
    3e9: call    ryo_h_CallExt
    3ee: test    rax,rax
    3f1: je      3FEh
    3f3: call    rax
    3f5: nop     [rcx-140h]
    3fc: jmp     40Eh
    3fe: mov     rdi,rbp
    401: lea     rsi,[ro+4]
    408: call    qword ptr [sym24]
    40e: call    ryo_h_Unreachable
    413: ud2
    415: mov     rax,[rbp-128h]
    41c: mov     [rbp-0C8h],rax
    423: jmp     310h
    428: mov     qword ptr [rbp-148h],1
    433: mov     edi,0FFFFFEC8h
    438: mov     esi,0FFFFFED0h
    43d: mov     edx,0FFFFFF90h
    442: mov     ecx,0FFFFFEB8h
    447: call    ryo_h_AddOvfUW64
    44c: test    byte ptr [rbp-130h],0FFh
    453: je      4A5h
    455: mov     edi,0FFFFFE90h
    45a: lea     rsi,[k25]
    461: call    ryo_h_AddrAbs
    466: lea     rdi,[sym26]
    46d: lea     rsi,[site27]
    474: mov     edx,0FFFFFEB8h
    479: call    ryo_h_CallExt
    47e: test    rax,rax
    481: je      48Eh
    483: call    rax
    485: nop     [rcx-140h]
    48c: jmp     49Eh
    48e: mov     rdi,rbp
    491: lea     rsi,[ro+4]
    498: call    qword ptr [sym28]
    49e: call    ryo_h_Unreachable
    4a3: ud2
    4a5: mov     rax,[rbp-138h]
    4ac: mov     [rbp-70h],rax
    4b0: jmp     160h
    4b5: mov     edi,0FFFFFFE8h
    4ba: mov     esi,0FFFFFFD0h
    4bf: mov     edx,18h
    4c4: call    ryo_h_Copy
    4c9: mov     edi,0FFFFFFE8h
    4ce: mov     esi,18h
    4d3: call    ryo_h_Ret
    4d8: leave
    4d9: ret
    4da: nop     [rax+rax]
    4e0: lea     rax,[rbp-30h]
    4e4: mov     [rbp-148h],rax
    4eb: mov     rax,[rbp-148h]
    4f2: mov     [rbp-170h],rax
    4f9: call    fn29
    4fe: nop     [rcx-148h]
    505: mov     edi,0FFFFFEC0h
    50a: call    ryo_h_Resume
    50f: ud2
    511: nop     [rax+rax]
    51a: nop     [rax+rax]
    520: lea     rdi,[sym30]
    527: lea     rsi,[site31]
    52e: mov     edx,0FFFFFEB8h
    533: call    ryo_h_CallExt
    538: test    rax,rax
    53b: je      548h
    53d: call    rax
    53f: nop     [rcx-140h]
    546: jmp     558h
    548: mov     rdi,rbp
    54b: lea     rsi,[ro+4]
    552: call    qword ptr [sym32]
    558: call    ryo_h_Unreachable
    55d: ud2
    55f: mov     rdi,rax
    562: mov     esi,0FFFFFEC0h
    567: call    ryo_h_Lpad
    56c: jmp     4E0h
    571: mov     rdi,rax
    574: mov     esi,0FFFFFEC0h
    579: call    ryo_h_Lpad
    57e: jmp     520h

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

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rax,[rbp+18h]
     14: mov     [rbp-38h],rax
     18: mov     rax,[rbp-38h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp-28h]
     24: mov     [rbp-50h],rax
     28: mov     rax,[rbp-30h]
     2c: mov     [rbp-48h],rax
     30: call    fn0
     35: nop     [rcx-19h]
     3c: test    byte ptr [rbp-19h],0FFh
     40: je      5Ch
     42: mov     rax,[rbp+18h]
     46: mov     [rbp-28h],rax
     4a: mov     rax,[rbp-28h]
     4e: mov     [rbp-8],rax
     52: mov     qword ptr [rbp-10h],1
     5a: jmp     64h
     5c: mov     qword ptr [rbp-10h],0
     64: mov     edi,0FFFFFFF0h
     69: mov     esi,10h
     6e: call    ryo_h_Ret
     73: leave
     74: ret
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: mov     edi,0FFFFFFE8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: mov     rdi,rax
     8f: mov     esi,0FFFFFFE8h
     94: call    ryo_h_Lpad
     99: jmp     80h

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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
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

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
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
     6e: imul    rcx,[rbp-20h],1
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
     3d: mov     rax,[rbp-60h]
     41: mov     [rbp-58h],rax
     45: mov     rax,[rbp+10h]
     49: mov     rax,[rax+10h]
     4d: mov     [rbp-60h],rax
     51: mov     rax,[rbp-60h]
     55: mov     rcx,7FFFFFFFFFFFFFFFh
     5f: cmp     rax,rcx
     62: setbe   [rbp-61h]
     66: mov     rax,[rbp-58h]
     6a: imul    rcx,[rbp-60h],1
     6f: add     rax,rcx
     72: mov     [rbp-8],rax
     76: mov     rax,[rbp+10h]
     7a: lea     rax,[rax+10h]
     7e: mov     [rbp-68h],rax
     82: mov     rax,[rbp-68h]
     86: mov     rax,[rax]
     89: mov     [rbp-70h],rax
     8d: mov     rax,[rbp-68h]
     91: mov     [rbp-60h],rax
     95: mov     rax,[rbp-70h]
     99: mov     [rbp-58h],rax
     9d: mov     qword ptr [rbp-18h],1
     a5: mov     rax,[rbp+18h]
     a9: mov     [rbp-10h],rax
     ad: nop     [rax]
     b0: mov     rax,[rbp-18h]
     b4: mov     [rbp-70h],rax
     b8: mov     rax,[rbp-10h]
     bc: mov     [rbp-78h],rax
     c0: mov     rax,[rbp-70h]
     c4: cmp     rax,[rbp-78h]
     c8: setb    [rbp-61h]
     cc: test    byte ptr [rbp-61h],0FFh
     d0: je      21Ch
     d6: jmp     208h
     db: nop     [rax+rax]
     e0: mov     rax,[rbp-68h]
     e4: movzx   ecx,byte ptr [rbp-69h]
     e8: mov     [rax],cl
     ea: mov     qword ptr [rbp-80h],1
     f2: mov     rax,[rbp-8]
     f6: imul    rcx,[rbp-80h],1
     fb: add     rax,rcx
     fe: mov     [rbp-68h],rax
    102: mov     rax,[rbp-68h]
    106: mov     [rbp-8],rax
    10a: mov     rax,[rbp-58h]
    10e: add     rax,1
    112: mov     [rbp-58h],rax
    116: jmp     0B0h
    118: nop     [rax+rax]
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
    149: mov     rax,[rbp-80h]
    14d: mov     [rbp-0A0h],rax
    154: call    fn1
    159: nop     [rcx-80h]
    160: jmp     29Fh
    165: nop     [rax+rax]
    16e: xchg    ax,ax
    170: lea     rax,[rbp-60h]
    174: mov     [rbp-80h],rax
    178: mov     rax,[rbp-80h]
    17c: mov     [rbp-0A0h],rax
    183: call    fn2
    188: nop     [rcx-80h]
    18f: test    byte ptr [rbp-31h],0FFh
    193: jne     1ECh
    195: nop     [rax+rax]
    19e: xchg    ax,ax
    1a0: xor     edi,edi
    1a2: xor     esi,esi
    1a4: call    ryo_h_Ret
    1a9: leave
    1aa: ret
    1ab: nop     [rax+rax]
    1b0: lea     rax,[rbp-60h]
    1b4: mov     [rbp-80h],rax
    1b8: mov     rax,[rbp-80h]
    1bc: mov     [rbp-0A0h],rax
    1c3: call    fn3
    1c8: nop     [rcx-80h]
    1cf: jmp     200h
    1d1: nop     [rax+rax]
    1da: nop     [rax+rax]
    1e0: mov     edi,0FFFFFFB0h
    1e5: call    ryo_h_Resume
    1ea: ud2
    1ec: jmp     1A0h
    1ee: xchg    ax,ax
    1f0: jmp     1E0h
    1f2: nop     [rax+rax]
    1fb: nop     [rax+rax]
    200: test    byte ptr [rbp-31h],0FFh
    204: je      1E0h
    206: jmp     1F0h
    208: mov     rax,[rbp-18h]
    20c: mov     [rbp-70h],rax
    210: mov     byte ptr [rbp-79h],1
    214: test    byte ptr [rbp-79h],0FFh
    218: je      25Fh
    21a: jmp     22Ch
    21c: cmp     qword ptr [rbp+18h],0
    221: ja      120h
    227: jmp     170h
    22c: mov     rax,[rbp-70h]
    230: mov     [rbp-0A0h],rax
    237: mov     qword ptr [rbp-98h],1
    242: mov     edi,0FFFFFF70h
    247: lea     rsi,[k4]
    24e: call    ryo_h_AddrAbs
    253: call    fn5
    258: nop     [rcx-48h]
    25f: mov     rax,[rbp-70h]
    263: add     rax,1
    267: mov     [rbp-78h],rax
    26b: mov     rax,[rbp-78h]
    26f: mov     [rbp-18h],rax
    273: mov     rax,[rbp-8]
    277: mov     [rbp-68h],rax
    27b: lea     rax,[rbp+20h]
    27f: mov     [rbp-78h],rax
    283: mov     rax,[rbp-78h]
    287: mov     [rbp-0A0h],rax
    28e: call    fn6
    293: nop     [rcx-69h]
    29a: jmp     0E0h
    29f: jmp     1A0h
    2a4: nop     [rax+rax]
    2ad: nop     [rax]
    2b0: lea     rdi,[sym7]
    2b7: lea     rsi,[site8]
    2be: mov     edx,0FFFFFF80h
    2c3: call    ryo_h_CallExt
    2c8: test    rax,rax
    2cb: je      2D8h
    2cd: call    rax
    2cf: nop     [rcx-78h]
    2d6: jmp     2E8h
    2d8: mov     rdi,rbp
    2db: lea     rsi,[ro+4]
    2e2: call    qword ptr [sym9]
    2e8: call    ryo_h_Unreachable
    2ed: ud2
    2ef: mov     rdi,rax
    2f2: mov     esi,0FFFFFFB0h
    2f7: call    ryo_h_Lpad
    2fc: jmp     200h
    301: mov     rdi,rax
    304: mov     esi,0FFFFFFB0h
    309: call    ryo_h_Lpad
    30e: jmp     2B0h
    310: mov     rdi,rax
    313: mov     esi,0FFFFFFB0h
    318: call    ryo_h_Lpad
    31d: jmp     1B0h

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

