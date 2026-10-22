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
     13: lea     rsi,[rbp+18h]
     17: mov     [rbp-38h],rsi
     1b: mov     [rbp-0B0h],rsi
     22: call    fn0
     27: nop     [rcx-29h]
     2e: test    byte ptr [rbp-29h],0FFh
     32: je      9Dh
     34: mov     byte ptr [rbp-19h],0
     38: mov     rsi,[rbp+10h]
     3c: mov     [rbp-0B0h],rsi
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
     a1: mov     rdx,[rbp+10h]
     a5: mov     [rbp-0B0h],rdx
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
    274: lea     rdx,[rbp-40h]
    278: mov     [rbp-48h],rdx
    27c: mov     byte ptr [rbp-1Ah],0
    280: movzx   edi,byte ptr [rbp+18h]
    284: mov     [rbp-49h],dil
    288: mov     [rbp-0B0h],rdx
    28f: mov     r8,[rbp+10h]
    293: mov     [rbp-0A8h],r8
    29a: mov     [rbp-0A0h],dil
    2a1: call    fn11
    2a6: nop     [rcx-18h]
    2ad: jmp     0E0h
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
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
     10: lea     rdx,[rbp+18h]
     14: mov     [rbp-30h],rdx
     18: mov     [rbp-28h],rdx
     1c: mov     [rbp-40h],rax
     20: mov     [rbp-38h],rdx
     24: call    fn0
     29: nop     [rcx-11h]
     30: mov     edi,0FFFFFFF8h
     35: mov     esi,0FFFFFFEFh
     3a: call    ryo_h_ZextW8W64
     3f: mov     edi,0FFFFFFF8h
     44: mov     esi,8
     49: call    ryo_h_Ret
     4e: leave
     4f: ret
     50: mov     edi,0FFFFFFF0h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFF0h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-11h],1
      c: mov     byte ptr [rbp-12h],1
     10: lea     rsi,[rbp+10h]
     14: mov     [rbp-50h],rsi
     18: mov     [rbp-70h],rsi
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
    16a: mov     rdx,[rbp-10h]
    16e: mov     [rbp-68h],rdx
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
     14: mov     rdx,[rbp+18h]
     18: mov     [rbp-28h],rdx
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
     19: mov     rsi,[rbp+10h]
     1d: mov     [rbp-28h],rsi
     21: mov     [rbp-8],rsi
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
     10: mov     rdx,[rbp+10h]
     14: mov     [rbp-50h],rdx
     18: mov     [rbp-48h],rax
     1c: call    fn0
     21: nop     [rcx-20h]
     28: mov     rax,[rbp-20h]
     2c: mov     [rbp-28h],rax
     30: mov     edi,0FFFFFFD8h
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
     54: .long   7dh
     58: .long   67h
     5c: .long   60h
     60: call    ryo_h_Unreachable
     65: ud2
     67: mov     rax,[rbp-18h]
     6b: mov     [rbp-30h],rax
     6f: mov     [rbp-8],rax
     73: mov     qword ptr [rbp-10h],1
     7b: jmp     0A3h
     7d: mov     qword ptr [rbp-10h],0
     85: jmp     0A3h
     87: nop     [rax+rax]
     90: mov     edi,0FFFFFFF0h
     95: mov     esi,10h
     9a: call    ryo_h_Ret
     9f: leave
     a0: ret
     a1: jmp     90h
     a3: mov     rax,[rbp-20h]
     a7: mov     [rbp-38h],rax
     ab: mov     edi,0FFFFFFC8h
     b0: xor     esi,esi
     b2: mov     edx,2
     b7: call    ryo_h_SwitchDenseW64
     bc: lea     rcx,[0CCh]
     c3: movsxd  rax,[rcx+rax*4]
     c7: add     rax,rcx
     ca: jmp     rax
     cc: .long   a1h
     d0: .long   90h
     d4: .long   60h

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
      f: mov     rdx,[rbp+10h]
     13: movzx   edx,byte ptr [rdx+10h]
     17: mov     [rbp-3Ah],dl
     1a: test    byte ptr [rbp-3Ah],0FFh
     1e: je      2FFh
     24: jmp     2FAh
     29: nop     [rax]
     30: mov     byte ptr [rbp-2Ah],0
     34: call    fn0
     39: nop     [rcx-10h]
     40: jmp     295h
     45: nop     [rax+rax]
     4e: xchg    ax,ax
     50: mov     byte ptr [rbp-2Ah],0
     54: mov     byte ptr [rbp-29h],1
     58: nop     [rax+rax]
     60: mov     rax,[rbp+10h]
     64: mov     [rbp-48h],rax
     68: mov     rdx,[rbp+10h]
     6c: lea     rdx,[rdx+8]
     70: mov     [rbp-50h],rdx
     74: mov     [rbp-0A0h],rax
     7b: mov     [rbp-98h],rdx
     82: call    fn1
     87: nop     [rcx-39h]
     8e: test    byte ptr [rbp-39h],0FFh
     92: je      190h
     98: mov     rdx,[rbp+10h]
     9c: mov     rdx,[rdx+8]
     a0: mov     [rbp-50h],rdx
     a4: mov     [rbp-0A0h],rdx
     ab: mov     qword ptr [rbp-98h],1
     b6: call    fn2
     bb: nop     [rcx-48h]
     c2: mov     rax,[rbp+10h]
     c6: mov     rax,[rax+8]
     ca: mov     [rbp-50h],rax
     ce: mov     rdx,[rbp+10h]
     d2: mov     rcx,[rbp-48h]
     d6: mov     [rdx+8],rcx
     da: lea     rsi,[rbp+18h]
     de: mov     [rbp-78h],rsi
     e2: mov     byte ptr [rbp-29h],0
     e6: mov     r8,[rbp-50h]
     ea: mov     [rbp-80h],r8
     ee: mov     [rbp-0A0h],rsi
     f5: mov     [rbp-98h],r8
     fc: call    fn3
    101: nop     [rcx-70h]
    108: mov     edi,0FFFFFF60h
    10d: mov     esi,0FFFFFF90h
    112: call    ryo_h_MovW128
    117: call    fn4
    11c: nop     [rcx-60h]
    123: mov     rax,[rbp-60h]
    127: mov     [rbp-20h],rax
    12b: mov     edi,0FFFFFFE0h
    130: xor     esi,esi
    132: mov     edx,2
    137: call    ryo_h_SwitchDenseW64
    13c: lea     rcx,[14Ch]
    143: movsxd  rax,[rcx+rax*4]
    147: add     rax,rcx
    14a: jmp     rax
    14c: .long   167h
    150: .long   170h
    154: .long   160h
    158: nop     [rax+rax]
    160: call    ryo_h_Unreachable
    165: ud2
    167: mov     byte ptr [rbp-29h],1
    16b: jmp     60h
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-68h],rax
    178: mov     [rbp-0A0h],rax
    17f: call    fn5
    184: nop     [rcx-10h]
    18b: jmp     295h
    190: mov     byte ptr [rbp-90h],1
    197: mov     rdx,[rbp+10h]
    19b: movzx   ecx,byte ptr [rbp-90h]
    1a2: mov     [rdx+10h],cl
    1a5: mov     rsi,[rbp+10h]
    1a9: mov     [rbp-48h],rsi
    1ad: mov     rdi,[rbp+10h]
    1b1: lea     rdi,[rdi+8]
    1b5: mov     [rbp-50h],rdi
    1b9: mov     [rbp-0A0h],rsi
    1c0: mov     [rbp-98h],rdi
    1c7: call    fn6
    1cc: nop     [rcx-39h]
    1d3: test    byte ptr [rbp-39h],0FFh
    1d7: je      283h
    1dd: lea     rdx,[rbp+18h]
    1e1: mov     [rbp-68h],rdx
    1e5: mov     byte ptr [rbp-29h],0
    1e9: mov     rdi,[rbp+10h]
    1ed: mov     rdi,[rdi]
    1f0: mov     [rbp-78h],rdi
    1f4: mov     [rbp-70h],rdi
    1f8: mov     [rbp-0A0h],rdx
    1ff: mov     [rbp-98h],rdi
    206: call    fn7
    20b: nop     [rcx-60h]
    212: mov     edi,0FFFFFF60h
    217: mov     esi,0FFFFFFA0h
    21c: call    ryo_h_MovW128
    221: call    fn8
    226: nop     [rcx-50h]
    22d: mov     rax,[rbp-50h]
    231: mov     [rbp-28h],rax
    235: mov     edi,0FFFFFFD8h
    23a: xor     esi,esi
    23c: mov     edx,2
    241: call    ryo_h_SwitchDenseW64
    246: lea     rcx,[258h]
    24d: movsxd  rax,[rcx+rax*4]
    251: add     rax,rcx
    254: jmp     rax
    256: int3
    257: int3
    258: .long   264h
    25c: .long   266h
    260: .long   160h
    264: jmp     283h
    266: mov     rax,[rbp-48h]
    26a: mov     [rbp-58h],rax
    26e: mov     [rbp-0A0h],rax
    275: call    fn9
    27a: nop     [rcx-10h]
    281: jmp     295h
    283: mov     byte ptr [rbp-29h],0
    287: call    fn10
    28c: nop     [rcx-10h]
    293: jmp     295h
    295: mov     edi,0FFFFFFF0h
    29a: mov     esi,10h
    29f: call    ryo_h_Ret
    2a4: leave
    2a5: ret
    2a6: nop     [rax+rax]
    2af: nop
    2b0: jmp     2F2h
    2b2: nop     [rax+rax]
    2bb: nop     [rax+rax]
    2c0: mov     edi,0FFFFFFC8h
    2c5: call    ryo_h_Resume
    2ca: ud2
    2cc: nop     [rax]
    2d0: jmp     2B0h
    2d2: nop     [rax+rax]
    2db: nop     [rax+rax]
    2e0: test    byte ptr [rbp-29h],0FFh
    2e4: je      2B0h
    2e6: jmp     2D0h
    2e8: nop     [rax+rax]
    2f0: jmp     2C0h
    2f2: test    byte ptr [rbp-2Ah],0FFh
    2f6: je      2C0h
    2f8: jmp     2F0h
    2fa: jmp     30h
    2ff: mov     rax,[rbp+10h]
    303: mov     [rbp-48h],rax
    307: mov     rdx,[rbp+10h]
    30b: lea     rdx,[rdx+8]
    30f: mov     [rbp-50h],rdx
    313: mov     [rbp-0A0h],rax
    31a: mov     [rbp-98h],rdx
    321: call    fn11
    326: nop     [rcx-3Bh]
    32d: movzx   eax,byte ptr [rbp-3Bh]
    331: xor     al,1
    334: mov     [rbp-39h],al
    337: test    byte ptr [rbp-39h],0FFh
    33b: je      50h
    341: jmp     30h
    346: mov     rdi,rax
    349: mov     esi,0FFFFFFC8h
    34e: call    ryo_h_Lpad
    353: jmp     2B0h
    358: mov     rdi,rax
    35b: mov     esi,0FFFFFFC8h
    360: call    ryo_h_Lpad
    365: jmp     2E0h

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
    111: imul    rcx,r8,1
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
    16a: je      336h
    170: jmp     303h
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
    24b: cmp     qword ptr [rbp-0A8h],1
    253: setb    [rbp-71h]
    257: test    byte ptr [rbp-71h],0FFh
    25b: je      297h
    25d: mov     qword ptr [rbp-0A8h],1
    268: mov     r8,[rbp-0A8h]
    26f: mov     rcx,7FFFFFFFFFFFFFFFh
    279: cmp     r8,rcx
    27c: setbe   [rbp-72h]
    280: test    byte ptr [rbp-72h],0FFh
    284: je      297h
    286: mov     r10,[rbp-70h]
    28a: sub     r10,[rbp-68h]
    28e: mov     [rbp-28h],r10
    292: jmp     200h
    297: mov     edi,0FFFFFF40h
    29c: lea     rsi,[k3]
    2a3: call    ryo_h_AddrAbs
    2a8: mov     qword ptr [rbp-0B8h],49h
    2b3: mov     edi,0FFFFFF50h
    2b8: lea     rsi,[k4]
    2bf: call    ryo_h_AddrAbs
    2c4: lea     rdi,[sym5]
    2cb: lea     rsi,[site6]
    2d2: mov     edx,0FFFFFF58h
    2d7: call    ryo_h_CallExt
    2dc: test    rax,rax
    2df: je      2ECh
    2e1: call    rax
    2e3: nop     [rcx-32h]
    2ea: jmp     2FCh
    2ec: mov     rdi,rbp
    2ef: lea     rsi,[ro+4]
    2f6: call    qword ptr [sym7]
    2fc: call    ryo_h_Unreachable
    301: ud2
    303: mov     rax,[rbp-20h]
    307: mov     [rbp-0C0h],rax
    30e: mov     qword ptr [rbp-0B8h],1
    319: mov     edi,0FFFFFF50h
    31e: lea     rsi,[k8]
    325: call    ryo_h_AddrAbs
    32a: call    fn9
    32f: nop     [rcx-32h]
    336: mov     rax,[rbp-20h]
    33a: add     rax,1
    33e: mov     [rbp-50h],rax
    342: mov     [rbp-20h],rax
    346: mov     [rbp-58h],rax
    34a: mov     rdx,[rbp-28h]
    34e: mov     [rbp-60h],rdx
    352: cmp     rax,rdx
    355: je      180h
    35b: jmp     190h
    360: mov     rdi,rax
    363: mov     esi,0FFFFFFC0h
    368: call    ryo_h_Lpad
    36d: jmp     1E0h

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
     df: cmp     qword ptr [rbp-60h],1
     e4: setb    [rbp-49h]
     e8: test    byte ptr [rbp-49h],0FFh
     ec: je      11Fh
     ee: mov     qword ptr [rbp-60h],1
     f6: mov     r8,[rbp-60h]
     fa: mov     rcx,7FFFFFFFFFFFFFFFh
    104: cmp     r8,rcx
    107: setbe   [rbp-4Ah]
    10b: test    byte ptr [rbp-4Ah],0FFh
    10f: je      11Fh
    111: mov     r10,[rbp-48h]
    115: sub     r10,[rbp-40h]
    119: mov     [rbp-20h],r10
    11d: jmp     0A0h
    11f: mov     edi,0FFFFFF80h
    124: lea     rsi,[k2]
    12b: call    ryo_h_AddrAbs
    130: mov     qword ptr [rbp-78h],49h
    138: mov     edi,0FFFFFF90h
    13d: lea     rsi,[k3]
    144: call    ryo_h_AddrAbs
    149: lea     rdi,[sym4]
    150: lea     rsi,[site5]
    157: mov     edx,0FFFFFFA0h
    15c: call    ryo_h_CallExt
    161: test    rax,rax
    164: je      171h
    166: call    rax
    168: nop     [rcx-20h]
    16f: jmp     181h
    171: mov     rdi,rbp
    174: lea     rsi,[ro+4]
    17b: call    qword ptr [sym6]
    181: call    ryo_h_Unreachable
    186: ud2

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: cmp     rax,[rbp+18h]
     10: setbe   [rbp-1]
     14: mov     byte ptr [rbp-2],1
     18: test    byte ptr [rbp-2],0FFh
     1c: je      43h
     1e: movzx   edi,byte ptr [rbp-1]
     22: mov     [rbp-20h],dil
     26: mov     edi,0FFFFFFE8h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: call    fn1
     3c: nop     [rcx]
     43: xor     edi,edi
     45: xor     esi,esi
     47: call    ryo_h_Ret
     4c: leave
     4d: ret

fn <std::vec::Vec<bool> as std::ops::Deref>::deref
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

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
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

fn <usize as std::iter::Step>::backward_unchecked
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
     6c: imul    rcx,[rbp+20h],1
     71: add     rax,rcx
     74: mov     [rbp-20h],rax
     78: mov     [rbp-8],rax
     7c: mov     edi,0FFFFFFF8h
     81: mov     esi,8
     86: call    ryo_h_Ret
     8b: leave
     8c: ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
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
     6c: imul    rcx,[rbp+20h],1
     71: add     rax,rcx
     74: mov     [rbp-20h],rax
     78: mov     [rbp-8],rax
     7c: mov     edi,0FFFFFFF8h
     81: mov     esi,8
     86: call    ryo_h_Ret
     8b: leave
     8c: ret

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
     b0: mov     rdx,[rbp-8]
     b4: mov     [rbp-1A8h],rdx
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
     f2: lea     rdx,[rbp-20h]
     f6: mov     [rbp-0C0h],rdx
     fd: mov     [rbp-0B8h],rdx
    104: mov     [rbp-1B0h],rax
    10b: mov     [rbp-1A8h],rdx
    112: call    fn8
    117: nop     [rcx-78h]
    11e: mov     edi,0FFFFFE50h
    123: mov     esi,0FFFFFF88h
    128: call    ryo_h_MovW128
    12d: mov     edi,0FFFFFE60h
    132: lea     rsi,[k9]
    139: call    ryo_h_AddrAbs
    13e: call    fn10
    143: nop     [rcx-68h]
    14a: lea     rax,[rbp-28h]
    14e: mov     [rbp-0F0h],rax
    155: lea     rdx,[rbp-8]
    159: mov     [rbp-0F8h],rdx
    160: lea     rsi,[rbp-68h]
    164: mov     [rbp-100h],rsi
    16b: mov     [rbp-0E8h],rax
    172: mov     [rbp-0E0h],rdx
    179: mov     [rbp-0D8h],rsi
    180: mov     [rbp-178h],rax
    187: mov     [rbp-1B0h],rax
    18e: call    fn11
    193: nop     [rcx-140h]
    19a: mov     rax,[rbp-0E0h]
    1a1: mov     [rbp-180h],rax
    1a8: mov     [rbp-1B0h],rax
    1af: call    fn12
    1b4: nop     [rcx-150h]
    1bb: mov     rax,[rbp-0D8h]
    1c2: mov     [rbp-188h],rax
    1c9: mov     [rbp-1B0h],rax
    1d0: call    fn13
    1d5: nop     [rcx-160h]
    1dc: mov     edi,0FFFFFED0h
    1e1: mov     esi,0FFFFFEC0h
    1e6: call    ryo_h_MovW128
    1eb: mov     edi,0FFFFFEE0h
    1f0: mov     esi,0FFFFFEB0h
    1f5: call    ryo_h_MovW128
    1fa: mov     edi,0FFFFFEF0h
    1ff: mov     esi,0FFFFFEA0h
    204: call    ryo_h_MovW128
    209: mov     edi,0FFFFFE98h
    20e: lea     rsi,[k14]
    215: call    ryo_h_AddrAbs
    21a: lea     rax,[rbp-130h]
    221: mov     [rbp-170h],rax
    228: mov     rdx,[rbp-168h]
    22f: mov     [rbp-1B0h],rdx
    236: mov     [rbp-1A8h],rax
    23d: call    fn15
    242: nop     [rcx-0D0h]
    249: mov     edi,0FFFFFE50h
    24e: mov     esi,0FFFFFF30h
    253: call    ryo_h_MovW128
    258: lea     rdi,[sym16]
    25f: lea     rsi,[site17]
    266: mov     edx,0FFFFFE68h
    26b: call    ryo_h_CallExt
    270: test    rax,rax
    273: je      280h
    275: call    rax
    277: nop     [rcx-0C0h]
    27e: jmp     290h
    280: mov     rdi,rbp
    283: lea     rsi,[ro+4]
    28a: call    qword ptr [sym18]
    290: lea     rax,[rbp-20h]
    294: mov     [rbp-198h],rax
    29b: mov     [rbp-1B0h],rax
    2a2: call    fn19
    2a7: nop     [rcx-198h]
    2ae: xor     edi,edi
    2b0: xor     esi,esi
    2b2: call    ryo_h_Ret
    2b7: leave
    2b8: ret
    2b9: nop     [rax]
    2c0: lea     rax,[rbp-20h]
    2c4: mov     [rbp-198h],rax
    2cb: mov     [rbp-1B0h],rax
    2d2: call    fn20
    2d7: nop     [rcx-198h]
    2de: mov     edi,0FFFFFE70h
    2e3: call    ryo_h_Resume
    2e8: ud2
    2ea: nop     [rax+rax]
    2f0: lea     rdi,[sym21]
    2f7: lea     rsi,[site22]
    2fe: mov     edx,0FFFFFE68h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-190h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+20]
    322: call    qword ptr [sym23]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFE70h
    337: call    ryo_h_Lpad
    33c: jmp     2C0h
    33e: mov     rdi,rax
    341: mov     esi,0FFFFFE70h
    346: call    ryo_h_Lpad
    34b: jmp     2F0h

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
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-20h],rdx
     1e: mov     [rbp-40h],rdx
     22: mov     [rbp-38h],rax
     26: mov     edi,0FFFFFFD0h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: call    fn1
     3c: nop     [rcx-18h]
     43: mov     rax,[rbp-18h]
     47: movzx   eax,byte ptr [rax]
     4a: mov     [rbp-1],al
     4d: mov     edi,0FFFFFFFFh
     52: mov     esi,1
     57: call    ryo_h_Ret
     5c: leave
     5d: ret

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
     e5: mov     rdx,[rbp-50h]
     e9: movzx   ecx,byte ptr [rbp-150h]
     f0: mov     [rdx],cl
     f2: lea     rsi,[rbp-30h]
     f6: mov     [rbp-68h],rsi
     fa: mov     [rbp-170h],rsi
    101: mov     qword ptr [rbp-168h],1
    10c: mov     edi,0FFFFFEA0h
    111: lea     rsi,[k7]
    118: call    ryo_h_AddrAbs
    11d: call    fn8
    122: nop     [rcx-60h]
    129: mov     byte ptr [rbp-150h],0
    130: mov     rdx,[rbp-60h]
    134: movzx   ecx,byte ptr [rbp-150h]
    13b: mov     [rdx],cl
    13d: mov     qword ptr [rbp-70h],2
    145: nop     [rax+rax]
    14e: xchg    ax,ax
    150: mov     rax,[rbp-70h]
    154: mov     [rbp-88h],rax
    15b: mov     rdx,[rbp-70h]
    15f: mov     [rbp-90h],rdx
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
    1e3: mov     rdx,[rbp+10h]
    1e7: cmp     rdx,rax
    1ea: jb      483h
    1f0: lea     rsi,[rbp-30h]
    1f4: mov     [rbp-0B8h],rsi
    1fb: mov     rdi,[rbp-70h]
    1ff: mov     [rbp-0C0h],rdi
    206: mov     [rbp-170h],rsi
    20d: mov     [rbp-168h],rdi
    214: mov     edi,0FFFFFEA0h
    219: lea     rsi,[k13]
    220: call    ryo_h_AddrAbs
    225: call    fn14
    22a: nop     [rcx-0B0h]
    231: mov     rax,[rbp-0B0h]
    238: movzx   eax,byte ptr [rax]
    23b: mov     [rbp-0A1h],al
    241: test    byte ptr [rbp-0A1h],0FFh
    248: je      3F6h
    24e: mov     rsi,[rbp-70h]
    252: mov     [rbp-0D0h],rsi
    259: mov     rdi,[rbp-70h]
    25d: mov     [rbp-0D8h],rdi
    264: mov     edi,0FFFFFF18h
    269: mov     esi,0FFFFFF20h
    26e: mov     edx,0FFFFFF30h
    273: mov     ecx,0FFFFFF28h
    278: call    ryo_h_MulOvfUW64
    27d: test    byte ptr [rbp-0E0h],0FFh
    284: je      2D6h
    286: mov     edi,0FFFFFE90h
    28b: lea     rsi,[k15]
    292: call    ryo_h_AddrAbs
    297: lea     rdi,[sym16]
    29e: lea     rsi,[site17]
    2a5: mov     edx,0FFFFFEB8h
    2aa: call    ryo_h_CallExt
    2af: test    rax,rax
    2b2: je      2BFh
    2b4: call    rax
    2b6: nop     [rcx-140h]
    2bd: jmp     2CFh
    2bf: mov     rdi,rbp
    2c2: lea     rsi,[ro+4]
    2c9: call    qword ptr [sym18]
    2cf: call    ryo_h_Unreachable
    2d4: ud2
    2d6: mov     rax,[rbp-0E8h]
    2dd: mov     [rbp-0C8h],rax
    2e4: nop     [rax+rax]
    2ed: nop     [rax]
    2f0: mov     rax,[rbp-0C8h]
    2f7: mov     [rbp-0F8h],rax
    2fe: mov     rdx,[rbp+10h]
    302: cmp     rdx,rax
    305: jb      3F6h
    30b: lea     rsi,[rbp-30h]
    30f: mov     [rbp-108h],rsi
    316: mov     rdi,[rbp-0C8h]
    31d: mov     [rbp-110h],rdi
    324: mov     [rbp-170h],rsi
    32b: mov     [rbp-168h],rdi
    332: mov     edi,0FFFFFEA0h
    337: lea     rsi,[k19]
    33e: call    ryo_h_AddrAbs
    343: call    fn20
    348: nop     [rcx-100h]
    34f: mov     byte ptr [rbp-150h],0
    356: mov     rdx,[rbp-100h]
    35d: movzx   ecx,byte ptr [rbp-150h]
    364: mov     [rdx],cl
    366: mov     rsi,[rbp-70h]
    36a: mov     [rbp-118h],rsi
    371: mov     edi,0FFFFFED8h
    376: mov     esi,0FFFFFEE0h
    37b: mov     edx,0FFFFFF38h
    380: mov     ecx,0FFFFFEE8h
    385: call    ryo_h_AddOvfUW64
    38a: test    byte ptr [rbp-120h],0FFh
    391: je      3E3h
    393: mov     edi,0FFFFFE90h
    398: lea     rsi,[k21]
    39f: call    ryo_h_AddrAbs
    3a4: lea     rdi,[sym22]
    3ab: lea     rsi,[site23]
    3b2: mov     edx,0FFFFFEB8h
    3b7: call    ryo_h_CallExt
    3bc: test    rax,rax
    3bf: je      3CCh
    3c1: call    rax
    3c3: nop     [rcx-140h]
    3ca: jmp     3DCh
    3cc: mov     rdi,rbp
    3cf: lea     rsi,[ro+4]
    3d6: call    qword ptr [sym24]
    3dc: call    ryo_h_Unreachable
    3e1: ud2
    3e3: mov     rax,[rbp-128h]
    3ea: mov     [rbp-0C8h],rax
    3f1: jmp     2F0h
    3f6: mov     qword ptr [rbp-148h],1
    401: mov     edi,0FFFFFEC8h
    406: mov     esi,0FFFFFED0h
    40b: mov     edx,0FFFFFF90h
    410: mov     ecx,0FFFFFEB8h
    415: call    ryo_h_AddOvfUW64
    41a: test    byte ptr [rbp-130h],0FFh
    421: je      473h
    423: mov     edi,0FFFFFE90h
    428: lea     rsi,[k25]
    42f: call    ryo_h_AddrAbs
    434: lea     rdi,[sym26]
    43b: lea     rsi,[site27]
    442: mov     edx,0FFFFFEB8h
    447: call    ryo_h_CallExt
    44c: test    rax,rax
    44f: je      45Ch
    451: call    rax
    453: nop     [rcx-140h]
    45a: jmp     46Ch
    45c: mov     rdi,rbp
    45f: lea     rsi,[ro+4]
    466: call    qword ptr [sym28]
    46c: call    ryo_h_Unreachable
    471: ud2
    473: mov     rax,[rbp-138h]
    47a: mov     [rbp-70h],rax
    47e: jmp     150h
    483: mov     edi,0FFFFFFE8h
    488: mov     esi,0FFFFFFD0h
    48d: mov     edx,18h
    492: call    ryo_h_Copy
    497: mov     edi,0FFFFFFE8h
    49c: mov     esi,18h
    4a1: call    ryo_h_Ret
    4a6: leave
    4a7: ret
    4a8: nop     [rax+rax]
    4b0: lea     rax,[rbp-30h]
    4b4: mov     [rbp-148h],rax
    4bb: mov     [rbp-170h],rax
    4c2: call    fn29
    4c7: nop     [rcx-148h]
    4ce: mov     edi,0FFFFFEC0h
    4d3: call    ryo_h_Resume
    4d8: ud2
    4da: nop     [rax+rax]
    4e0: lea     rdi,[sym30]
    4e7: lea     rsi,[site31]
    4ee: mov     edx,0FFFFFEB8h
    4f3: call    ryo_h_CallExt
    4f8: test    rax,rax
    4fb: je      508h
    4fd: call    rax
    4ff: nop     [rcx-140h]
    506: jmp     518h
    508: mov     rdi,rbp
    50b: lea     rsi,[ro+4]
    512: call    qword ptr [sym32]
    518: call    ryo_h_Unreachable
    51d: ud2
    51f: mov     rdi,rax
    522: mov     esi,0FFFFFEC0h
    527: call    ryo_h_Lpad
    52c: jmp     4B0h
    52e: mov     rdi,rax
    531: mov     esi,0FFFFFEC0h
    536: call    ryo_h_Lpad
    53b: jmp     4E0h

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
     13: mov     rdx,[rbp+18h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-18h],rdx
     1e: cmp     rax,rdx
     21: sete    [rbp-1]
     25: mov     edi,0FFFFFFFFh
     2a: mov     esi,1
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le
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
     21: setbe   [rbp-1]
     25: mov     edi,0FFFFFFFFh
     2a: mov     esi,1
     2f: call    ryo_h_Ret
     34: leave
     35: ret

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

fn std::fmt::Arguments::<'_>::new::<39, 3>
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

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-28h],rax
     10: lea     rdx,[rbp+18h]
     14: mov     [rbp-38h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-50h],rax
     20: mov     [rbp-48h],rdx
     24: call    fn0
     29: nop     [rcx-19h]
     30: test    byte ptr [rbp-19h],0FFh
     34: je      4Ch
     36: mov     rdx,[rbp+18h]
     3a: mov     [rbp-28h],rdx
     3e: mov     [rbp-8],rdx
     42: mov     qword ptr [rbp-10h],1
     4a: jmp     54h
     4c: mov     qword ptr [rbp-10h],0
     54: mov     edi,0FFFFFFF0h
     59: mov     esi,10h
     5e: call    ryo_h_Ret
     63: leave
     64: ret
     65: nop     [rax+rax]
     6e: xchg    ax,ax
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
     14: mov     rsi,[rbp+18h]
     18: mov     [rbp-38h],rsi
     1c: mov     rdi,[rbp+10h]
     20: mov     [rbp-48h],rdi
     24: mov     r8,[rbp+20h]
     28: mov     [rbp-50h],r8
     2c: mov     [rbp-70h],rdi
     30: mov     [rbp-68h],r8
     34: call    fn0
     39: nop     [rcx-40h]
     40: mov     byte ptr [rbp-9],0
     44: mov     rdx,[rbp-38h]
     48: mov     [rbp-30h],rdx
     4c: mov     rsi,[rbp-40h]
     50: mov     [rbp-28h],rsi
     54: mov     rdi,[rbp-20h]
     58: mov     [rbp-70h],rdi
     5c: mov     [rbp-68h],rdx
     60: mov     [rbp-60h],rsi
     64: call    fn1
     69: nop     [rcx-8]
     70: mov     edi,0FFFFFFF8h
     75: mov     esi,8
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     edi,0FFFFFFE8h
     95: call    ryo_h_Resume
     9a: ud2
     9c: nop     [rax]
     a0: jmp     90h
     a2: nop     [rax+rax]
     ab: nop     [rax+rax]
     b0: test    byte ptr [rbp-9],0FFh
     b4: je      90h
     b6: jmp     0A0h
     b8: mov     rdi,rax
     bb: mov     esi,0FFFFFFE8h
     c0: call    ryo_h_Lpad
     c5: jmp     0B0h

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-18h],rdx
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
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-10h],rdx
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

fn std::slice::Iter::<'_, bool>::new
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
     66: imul    rcx,[rbp-20h],1
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
      f: mov     rdx,[rbp+10h]
     13: mov     [rbp-0A0h],rdx
     1a: mov     rsi,[rbp+18h]
     1e: mov     [rbp-98h],rsi
     25: call    fn0
     2a: nop     [rcx]
     31: mov     rax,[rbp+10h]
     35: mov     rax,[rax+8]
     39: mov     [rbp-60h],rax
     3d: mov     [rbp-58h],rax
     41: mov     rdx,[rbp+10h]
     45: mov     rdx,[rdx+10h]
     49: mov     [rbp-60h],rdx
     4d: mov     rcx,7FFFFFFFFFFFFFFFh
     57: cmp     rdx,rcx
     5a: setbe   [rbp-61h]
     5e: imul    rcx,rdx,1
     62: add     rax,rcx
     65: mov     [rbp-8],rax
     69: mov     rsi,[rbp+10h]
     6d: lea     rsi,[rsi+10h]
     71: mov     [rbp-68h],rsi
     75: mov     rsi,[rsi]
     78: mov     [rbp-70h],rsi
     7c: mov     rdi,[rbp-68h]
     80: mov     [rbp-60h],rdi
     84: mov     [rbp-58h],rsi
     88: mov     qword ptr [rbp-18h],1
     90: mov     r9,[rbp+18h]
     94: mov     [rbp-10h],r9
     98: nop     [rax+rax]
     a0: mov     rax,[rbp-18h]
     a4: mov     [rbp-70h],rax
     a8: mov     rdx,[rbp-10h]
     ac: mov     [rbp-78h],rdx
     b0: cmp     rax,rdx
     b3: setb    [rbp-61h]
     b7: test    byte ptr [rbp-61h],0FFh
     bb: je      1FCh
     c1: jmp     1E8h
     c6: nop     [rax+rax]
     cf: nop
     d0: mov     rax,[rbp-68h]
     d4: movzx   ecx,byte ptr [rbp-69h]
     d8: mov     [rax],cl
     da: mov     qword ptr [rbp-80h],1
     e2: mov     rsi,[rbp-8]
     e6: imul    rcx,[rbp-80h],1
     eb: add     rsi,rcx
     ee: mov     [rbp-68h],rsi
     f2: mov     [rbp-8],rsi
     f6: mov     rdi,[rbp-58h]
     fa: add     rdi,1
     fe: mov     [rbp-58h],rdi
    102: jmp     0A0h
    104: nop     [rax+rax]
    10d: nop     [rax]
    110: mov     byte ptr [rbp-31h],0
    114: movzx   edx,byte ptr [rbp+20h]
    118: mov     [rbp-62h],dl
    11b: mov     rsi,[rbp-8]
    11f: movzx   ecx,byte ptr [rbp-62h]
    123: mov     [rsi],cl
    125: mov     rdi,[rbp-58h]
    129: add     rdi,1
    12d: mov     [rbp-58h],rdi
    131: lea     r8,[rbp-60h]
    135: mov     [rbp-80h],r8
    139: mov     [rbp-0A0h],r8
    140: call    fn1
    145: nop     [rcx-80h]
    14c: jmp     277h
    151: nop     [rax+rax]
    15a: nop     [rax+rax]
    160: lea     rax,[rbp-60h]
    164: mov     [rbp-80h],rax
    168: mov     [rbp-0A0h],rax
    16f: call    fn2
    174: nop     [rcx-80h]
    17b: test    byte ptr [rbp-31h],0FFh
    17f: jne     1CCh
    181: nop     [rax+rax]
    18a: nop     [rax+rax]
    190: xor     edi,edi
    192: xor     esi,esi
    194: call    ryo_h_Ret
    199: leave
    19a: ret
    19b: nop     [rax+rax]
    1a0: lea     rax,[rbp-60h]
    1a4: mov     [rbp-80h],rax
    1a8: mov     [rbp-0A0h],rax
    1af: call    fn3
    1b4: nop     [rcx-80h]
    1bb: jmp     1E0h
    1bd: nop     [rax]
    1c0: mov     edi,0FFFFFFB0h
    1c5: call    ryo_h_Resume
    1ca: ud2
    1cc: jmp     190h
    1ce: xchg    ax,ax
    1d0: jmp     1C0h
    1d2: nop     [rax+rax]
    1db: nop     [rax+rax]
    1e0: test    byte ptr [rbp-31h],0FFh
    1e4: je      1C0h
    1e6: jmp     1D0h
    1e8: mov     rax,[rbp-18h]
    1ec: mov     [rbp-70h],rax
    1f0: mov     byte ptr [rbp-79h],1
    1f4: test    byte ptr [rbp-79h],0FFh
    1f8: je      23Fh
    1fa: jmp     20Ch
    1fc: cmp     qword ptr [rbp+18h],0
    201: ja      110h
    207: jmp     160h
    20c: mov     rax,[rbp-70h]
    210: mov     [rbp-0A0h],rax
    217: mov     qword ptr [rbp-98h],1
    222: mov     edi,0FFFFFF70h
    227: lea     rsi,[k4]
    22e: call    ryo_h_AddrAbs
    233: call    fn5
    238: nop     [rcx-48h]
    23f: mov     rax,[rbp-70h]
    243: add     rax,1
    247: mov     [rbp-78h],rax
    24b: mov     [rbp-18h],rax
    24f: mov     rdx,[rbp-8]
    253: mov     [rbp-68h],rdx
    257: lea     rsi,[rbp+20h]
    25b: mov     [rbp-78h],rsi
    25f: mov     [rbp-0A0h],rsi
    266: call    fn6
    26b: nop     [rcx-69h]
    272: jmp     0D0h
    277: jmp     190h
    27c: nop     [rax]
    280: lea     rdi,[sym7]
    287: lea     rsi,[site8]
    28e: mov     edx,0FFFFFF80h
    293: call    ryo_h_CallExt
    298: test    rax,rax
    29b: je      2A8h
    29d: call    rax
    29f: nop     [rcx-78h]
    2a6: jmp     2B8h
    2a8: mov     rdi,rbp
    2ab: lea     rsi,[ro+4]
    2b2: call    qword ptr [sym9]
    2b8: call    ryo_h_Unreachable
    2bd: ud2
    2bf: mov     rdi,rax
    2c2: mov     esi,0FFFFFFB0h
    2c7: call    ryo_h_Lpad
    2cc: jmp     1E0h
    2d1: mov     rdi,rax
    2d4: mov     esi,0FFFFFFB0h
    2d9: call    ryo_h_Lpad
    2de: jmp     280h
    2e0: mov     rdi,rax
    2e3: mov     esi,0FFFFFFB0h
    2e8: call    ryo_h_Lpad
    2ed: jmp     1A0h

fn std::vec::Vec::<bool>::reserve
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

fn std::vec::from_elem::<bool>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: movzx   eax,byte ptr [rbp+10h]
      c: mov     [rbp-28h],al
      f: mov     rdx,[rbp+18h]
     13: mov     [rbp-30h],rdx
     17: call    fn0
     1c: nop     [rcx-18h]
     23: mov     edi,0FFFFFFE8h
     28: mov     esi,18h
     2d: call    ryo_h_Ret
     32: leave
     33: ret

