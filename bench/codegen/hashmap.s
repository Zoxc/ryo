fn <! as std::sys::thread_local::native::lazy::DestroyedState>::register_dtor::<std::cell::Cell<(u64, u64)>>
      0: push    rbp
      1: mov     rbp,rsp
      4: xor     edi,edi
      6: xor     esi,esi
      8: call    ryo_h_Ret
      d: leave
      e: ret

fn <&mut core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write::write_fmt::SpecWriteFmt>::spec_write_fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-28h],rax
     10: mov     [rbp-60h],rax
     14: call    fn0
     19: nop     [rcx-20h]
     20: mov     edi,0FFFFFFCCh
     25: mov     esi,0FFFFFFE0h
     2a: xor     edx,edx
     2c: xor     ecx,ecx
     2e: xor     r8d,r8d
     31: mov     r9d,1
     37: call    ryo_h_DiscrNicheW64
     3c: mov     edi,0FFFFFFF0h
     41: mov     esi,0FFFFFFCCh
     46: call    ryo_h_ZextW32W64
     4b: mov     edi,0FFFFFFF0h
     50: xor     esi,esi
     52: mov     edx,2
     57: call    ryo_h_SwitchDenseW64
     5c: lea     rcx,[6Ch]
     63: movsxd  rax,[rcx+rax*4]
     67: add     rax,rcx
     6a: jmp     rax
     6c: .long   ach
     70: .long   78h
     74: .long   12ch
     78: mov     edi,0FFFFFFD0h
     7d: mov     esi,0FFFFFFE0h
     82: call    ryo_h_MovW128
     87: mov     rax,[rbp+10h]
     8b: mov     [rbp-60h],rax
     8f: mov     edi,0FFFFFFA8h
     94: mov     esi,0FFFFFFD0h
     99: call    ryo_h_MovW128
     9e: call    fn1
     a3: nop     [rcx-1]
     aa: jmp     11Bh
     ac: mov     rax,[rbp+10h]
     b0: mov     [rbp-20h],rax
     b4: mov     edi,0FFFFFFE8h
     b9: lea     rsi,[k2]
     c0: call    ryo_h_AddrAbs
     c5: mov     edi,0FFFFFFA0h
     ca: mov     esi,0FFFFFFE0h
     cf: call    ryo_h_MovW128
     d4: mov     edi,0FFFFFFB0h
     d9: mov     esi,18h
     de: call    ryo_h_MovW128
     e3: lea     rdi,[sym3]
     ea: lea     rsi,[site4]
     f1: mov     edx,0FFFFFFC8h
     f6: call    ryo_h_CallExt
     fb: test    rax,rax
     fe: je      10Bh
    100: call    rax
    102: nop     [rcx-1]
    109: jmp     11Bh
    10b: mov     rdi,rbp
    10e: lea     rsi,[ro+4]
    115: call    qword ptr [sym5]
    11b: mov     edi,0FFFFFFFFh
    120: mov     esi,1
    125: call    ryo_h_Ret
    12a: leave
    12b: ret
    12c: call    ryo_h_Unreachable
    131: ud2

fn <&u64 as std::ops::Rem<u64>>::rem
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: cmp     qword ptr [rbp+18h],0
     18: jne     61h
     1a: mov     rax,[rbp+20h]
     1e: mov     [rbp-30h],rax
     22: lea     rdi,[sym0]
     29: lea     rsi,[site1]
     30: mov     edx,0FFFFFFE0h
     35: call    ryo_h_CallExt
     3a: test    rax,rax
     3d: je      4Ah
     3f: call    rax
     41: nop     [rcx-11h]
     48: jmp     5Ah
     4a: mov     rdi,rbp
     4d: lea     rsi,[ro+4]
     54: call    qword ptr [sym2]
     5a: call    ryo_h_Unreachable
     5f: ud2
     61: mov     edi,0FFFFFFF8h
     66: mov     esi,0FFFFFFF0h
     6b: mov     edx,18h
     70: call    ryo_h_RemUW64
     75: mov     edi,0FFFFFFF8h
     7a: mov     esi,8
     7f: call    ryo_h_Ret
     84: leave
     85: ret

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

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     edi,0FFFFFFD8h
      d: mov     esi,10h
     12: xor     edx,edx
     14: mov     ecx,20h
     19: call    ryo_h_LoadCopy
     1e: mov     rax,[rbp+10h]
     22: mov     rax,[rax+30h]
     26: mov     [rbp-50h],rax
     2a: mov     [rbp-48h],rax
     2e: and     rax,0FFh
     35: mov     [rbp-40h],rax
     39: shl     rax,38h
     3d: mov     [rbp-38h],rax
     41: mov     rax,[rbp+10h]
     45: mov     rax,[rax+38h]
     49: mov     [rbp-40h],rax
     4d: mov     rax,[rbp-38h]
     51: or      rax,[rbp-40h]
     55: mov     [rbp-30h],rax
     59: mov     rax,[rbp-10h]
     5d: xor     rax,[rbp-30h]
     61: mov     [rbp-10h],rax
     65: lea     rax,[rbp-28h]
     69: mov     [rbp-38h],rax
     6d: mov     [rbp-60h],rax
     71: call    fn0
     76: nop     [rcx-8]
     7d: mov     rax,[rbp-28h]
     81: xor     rax,[rbp-30h]
     85: mov     [rbp-28h],rax
     89: mov     rax,[rbp-20h]
     8d: xor     rax,0FFh
     94: mov     [rbp-20h],rax
     98: lea     rax,[rbp-28h]
     9c: mov     [rbp-38h],rax
     a0: mov     [rbp-60h],rax
     a4: call    fn1
     a9: nop     [rcx-8]
     b0: mov     rax,[rbp-28h]
     b4: mov     [rbp-48h],rax
     b8: mov     rax,[rbp-18h]
     bc: mov     [rbp-50h],rax
     c0: mov     rax,[rbp-48h]
     c4: xor     rax,[rbp-50h]
     c8: mov     [rbp-40h],rax
     cc: mov     rax,[rbp-20h]
     d0: mov     [rbp-48h],rax
     d4: mov     rax,[rbp-40h]
     d8: xor     rax,[rbp-48h]
     dc: mov     [rbp-38h],rax
     e0: mov     rax,[rbp-10h]
     e4: mov     [rbp-40h],rax
     e8: mov     rax,[rbp-38h]
     ec: xor     rax,[rbp-40h]
     f0: mov     [rbp-8],rax
     f4: mov     edi,0FFFFFFF8h
     f9: mov     esi,8
     fe: call    ryo_h_Ret
    103: leave
    104: ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+30h]
     1b: mov     [rbp-68h],rax
     1f: add     rax,[rbp-18h]
     23: mov     [rbp-70h],rax
     27: mov     rax,[rbp+10h]
     2b: mov     rcx,[rbp-70h]
     2f: mov     [rax+30h],rcx
     33: mov     qword ptr [rbp-8],0
     3b: mov     rax,[rbp+10h]
     3f: mov     rax,[rax+40h]
     43: mov     [rbp-20h],rax
     47: cmp     rax,0
     4b: je      1B3h
     51: mov     rax,[rbp+10h]
     55: mov     rax,[rax+40h]
     59: mov     [rbp-20h],rax
     5d: mov     qword ptr [rbp-68h],8
     65: mov     rax,[rbp-68h]
     69: sub     rax,[rbp-20h]
     6d: mov     [rbp-8],rax
     71: mov     [rbp-38h],rax
     75: mov     rax,[rbp-18h]
     79: mov     [rbp-0A0h],rax
     80: mov     rax,[rbp-38h]
     84: mov     [rbp-98h],rax
     8b: call    fn0
     90: nop     [rcx-30h]
     97: jmp     2D3h
     9c: nop     [rax]
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+40h]
     a8: mov     [rbp-38h],rax
     ac: mov     qword ptr [rbp-68h],8
     b4: mov     rax,[rbp-68h]
     b8: imul    rax,[rbp-38h]
     bd: mov     [rbp-30h],rax
     c1: mov     edi,0FFFFFFE0h
     c6: mov     esi,0FFFFFFD8h
     cb: mov     edx,0FFFFFFD0h
     d0: call    ryo_h_ShlW64
     d5: mov     rax,[rbp+10h]
     d9: mov     rax,[rax+38h]
     dd: mov     [rbp-68h],rax
     e1: or      rax,[rbp-20h]
     e5: mov     [rbp-70h],rax
     e9: mov     rax,[rbp+10h]
     ed: mov     rcx,[rbp-70h]
     f1: mov     [rax+38h],rcx
     f5: mov     rax,[rbp-8]
     f9: mov     [rbp-28h],rax
     fd: mov     rax,[rbp-18h]
    101: cmp     rax,[rbp-28h]
    105: jae     12Ch
    107: mov     rax,[rbp+10h]
    10b: mov     rax,[rax+40h]
    10f: mov     [rbp-68h],rax
    113: add     rax,[rbp-18h]
    117: mov     [rbp-70h],rax
    11b: mov     rax,[rbp+10h]
    11f: mov     rcx,[rbp-70h]
    123: mov     [rax+40h],rcx
    127: jmp     2C8h
    12c: mov     rax,[rbp+10h]
    130: mov     rax,[rax+38h]
    134: mov     [rbp-28h],rax
    138: mov     rax,[rbp+10h]
    13c: mov     rax,[rax+18h]
    140: mov     [rbp-68h],rax
    144: xor     rax,[rbp-28h]
    148: mov     [rbp-70h],rax
    14c: mov     rax,[rbp+10h]
    150: mov     rcx,[rbp-70h]
    154: mov     [rax+18h],rcx
    158: mov     rax,[rbp+10h]
    15c: mov     [rbp-28h],rax
    160: mov     [rbp-0A0h],rax
    167: call    fn1
    16c: nop     [rcx-8]
    173: mov     rax,[rbp+10h]
    177: mov     rax,[rax+38h]
    17b: mov     [rbp-28h],rax
    17f: mov     rax,[rbp+10h]
    183: mov     rax,[rax]
    186: mov     [rbp-68h],rax
    18a: xor     rax,[rbp-28h]
    18e: mov     [rbp-70h],rax
    192: mov     rax,[rbp+10h]
    196: mov     rcx,[rbp-70h]
    19a: mov     [rax],rcx
    19d: mov     qword ptr [rbp-70h],0
    1a5: mov     rax,[rbp+10h]
    1a9: mov     rcx,[rbp-70h]
    1ad: mov     [rax+40h],rcx
    1b1: jmp     1B3h
    1b3: mov     rax,[rbp-8]
    1b7: mov     [rbp-28h],rax
    1bb: mov     rax,[rbp-18h]
    1bf: sub     rax,[rbp-28h]
    1c3: mov     [rbp-20h],rax
    1c7: and     rax,7
    1cb: mov     [rbp-28h],rax
    1cf: nop
    1d0: mov     rax,[rbp-8]
    1d4: mov     [rbp-38h],rax
    1d8: mov     rax,[rbp-20h]
    1dc: sub     rax,[rbp-28h]
    1e0: mov     [rbp-40h],rax
    1e4: mov     rax,[rbp-38h]
    1e8: cmp     rax,[rbp-40h]
    1ec: jae     27Fh
    1f2: mov     qword ptr [rbp-38h],0
    1fa: mov     rax,[rbp+18h]
    1fe: mov     [rbp-58h],rax
    202: mov     rax,[rbp+20h]
    206: mov     [rbp-50h],rax
    20a: mov     rax,[rbp-58h]
    20e: mov     [rbp-48h],rax
    212: mov     rax,[rbp-8]
    216: mov     [rbp-50h],rax
    21a: mov     rax,[rbp-48h]
    21e: imul    rcx,[rbp-50h],1
    223: add     rax,rcx
    226: mov     [rbp-40h],rax
    22a: lea     rax,[rbp-38h]
    22e: mov     [rbp-50h],rax
    232: mov     [rbp-48h],rax
    236: mov     byte ptr [rbp-61h],1
    23a: test    byte ptr [rbp-61h],0FFh
    23e: je      36Ah
    244: jmp     309h
    249: nop     [rax]
    250: mov     rax,[rbp+10h]
    254: mov     rax,[rax]
    257: mov     [rbp-68h],rax
    25b: xor     rax,[rbp-10h]
    25f: mov     [rbp-70h],rax
    263: mov     rax,[rbp+10h]
    267: mov     rcx,[rbp-70h]
    26b: mov     [rax],rcx
    26e: mov     rax,[rbp-8]
    272: add     rax,8
    276: mov     [rbp-8],rax
    27a: jmp     1D0h
    27f: mov     edi,0FFFFFF60h
    284: mov     esi,18h
    289: call    ryo_h_MovW128
    28e: mov     rax,[rbp-8]
    292: mov     [rbp-90h],rax
    299: mov     rax,[rbp-28h]
    29d: mov     [rbp-88h],rax
    2a4: call    fn2
    2a9: nop     [rcx-30h]
    2b0: mov     rax,[rbp+10h]
    2b4: mov     rcx,[rbp-30h]
    2b8: mov     [rax+38h],rcx
    2bc: mov     rax,[rbp+10h]
    2c0: mov     rcx,[rbp-28h]
    2c4: mov     [rax+40h],rcx
    2c8: xor     edi,edi
    2ca: xor     esi,esi
    2cc: call    ryo_h_Ret
    2d1: leave
    2d2: ret
    2d3: mov     edi,0FFFFFF60h
    2d8: mov     esi,18h
    2dd: call    ryo_h_MovW128
    2e2: mov     qword ptr [rbp-90h],0
    2ed: mov     rax,[rbp-30h]
    2f1: mov     [rbp-88h],rax
    2f8: call    fn3
    2fd: nop     [rcx-28h]
    304: jmp     0A0h
    309: mov     rax,[rbp-40h]
    30d: mov     [rbp-58h],rax
    311: mov     rax,[rbp-50h]
    315: mov     [rbp-60h],rax
    319: mov     rax,[rbp-58h]
    31d: mov     [rbp-0A0h],rax
    324: mov     rax,[rbp-60h]
    328: mov     [rbp-98h],rax
    32f: mov     qword ptr [rbp-90h],1
    33a: mov     qword ptr [rbp-88h],1
    345: mov     qword ptr [rbp-80h],8
    34d: mov     edi,0FFFFFF88h
    352: lea     rsi,[k4]
    359: call    ryo_h_AddrAbs
    35e: call    fn5
    363: nop     [rcx-10h]
    36a: mov     qword ptr [rbp-68h],8
    372: imul    rax,[rbp-68h],1
    377: mov     [rbp-70h],rax
    37b: mov     edi,0FFFFFFB8h
    380: mov     esi,0FFFFFFC0h
    385: mov     edx,0FFFFFF90h
    38a: call    ryo_h_Memcpy
    38f: mov     rax,[rbp-38h]
    393: mov     [rbp-10h],rax
    397: mov     rax,[rbp+10h]
    39b: mov     rax,[rax+18h]
    39f: mov     [rbp-68h],rax
    3a3: xor     rax,[rbp-10h]
    3a7: mov     [rbp-70h],rax
    3ab: mov     rax,[rbp+10h]
    3af: mov     rcx,[rbp-70h]
    3b3: mov     [rax+18h],rcx
    3b7: mov     rax,[rbp+10h]
    3bb: mov     [rbp-38h],rax
    3bf: mov     [rbp-0A0h],rax
    3c6: call    fn6
    3cb: nop     [rcx-10h]
    3d2: jmp     250h

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFF0h
      d: mov     esi,18h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-40h],rax
     1f: mov     edi,0FFFFFFC8h
     24: mov     esi,0FFFFFFF0h
     29: call    ryo_h_MovW128
     2e: call    fn0
     33: nop     [rcx]
     3a: mov     byte ptr [rbp-19h],0FFh
     3e: lea     rax,[rbp-19h]
     42: mov     [rbp-18h],rax
     46: mov     [rbp-10h],rax
     4a: mov     qword ptr [rbp-8],1
     52: mov     rax,[rbp+10h]
     56: mov     [rbp-40h],rax
     5a: mov     edi,0FFFFFFC8h
     5f: mov     esi,0FFFFFFF0h
     64: call    ryo_h_MovW128
     69: call    fn1
     6e: nop     [rcx]
     75: xor     edi,edi
     77: xor     esi,esi
     79: call    ryo_h_Ret
     7e: leave
     7f: ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+10h]
     1b: mov     [rbp-18h],rax
     1f: mov     rax,[rbp-10h]
     23: add     rax,[rbp-18h]
     27: mov     [rbp-8],rax
     2b: mov     rax,[rbp+10h]
     2f: mov     rcx,[rbp-8]
     33: mov     [rax],rcx
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax+8]
     3e: mov     [rbp-10h],rax
     42: mov     rax,[rbp+10h]
     46: mov     rax,[rax+18h]
     4a: mov     [rbp-18h],rax
     4e: mov     rax,[rbp-10h]
     52: add     rax,[rbp-18h]
     56: mov     [rbp-8],rax
     5a: mov     rax,[rbp+10h]
     5e: mov     rcx,[rbp-8]
     62: mov     [rax+8],rcx
     66: mov     rax,[rbp+10h]
     6a: mov     rax,[rax+10h]
     6e: mov     [rbp-10h],rax
     72: mov     dword ptr [rbp-1Ch],0Dh
     79: mov     edi,0FFFFFFF8h
     7e: mov     esi,0FFFFFFF0h
     83: mov     edx,0FFFFFFE4h
     88: call    ryo_h_RotlW64
     8d: mov     rax,[rbp+10h]
     91: mov     rcx,[rbp-8]
     95: mov     [rax+10h],rcx
     99: mov     rax,[rbp+10h]
     9d: mov     rax,[rax]
     a0: mov     [rbp-8],rax
     a4: mov     rax,[rbp+10h]
     a8: mov     rax,[rax+10h]
     ac: mov     [rbp-20h],rax
     b0: xor     rax,[rbp-8]
     b4: mov     [rbp-30h],rax
     b8: mov     rax,[rbp+10h]
     bc: mov     rcx,[rbp-30h]
     c0: mov     [rax+10h],rcx
     c4: mov     rax,[rbp+10h]
     c8: mov     rax,[rax+18h]
     cc: mov     [rbp-10h],rax
     d0: mov     dword ptr [rbp-1Ch],10h
     d7: mov     edi,0FFFFFFF8h
     dc: mov     esi,0FFFFFFF0h
     e1: mov     edx,0FFFFFFE4h
     e6: call    ryo_h_RotlW64
     eb: mov     rax,[rbp+10h]
     ef: mov     rcx,[rbp-8]
     f3: mov     [rax+18h],rcx
     f7: mov     rax,[rbp+10h]
     fb: mov     rax,[rax+8]
     ff: mov     [rbp-8],rax
    103: mov     rax,[rbp+10h]
    107: mov     rax,[rax+18h]
    10b: mov     [rbp-20h],rax
    10f: xor     rax,[rbp-8]
    113: mov     [rbp-30h],rax
    117: mov     rax,[rbp+10h]
    11b: mov     rcx,[rbp-30h]
    11f: mov     [rax+18h],rcx
    123: mov     rax,[rbp+10h]
    127: mov     rax,[rax]
    12a: mov     [rbp-10h],rax
    12e: mov     dword ptr [rbp-1Ch],20h
    135: mov     edi,0FFFFFFF8h
    13a: mov     esi,0FFFFFFF0h
    13f: mov     edx,0FFFFFFE4h
    144: call    ryo_h_RotlW64
    149: mov     rax,[rbp+10h]
    14d: mov     rcx,[rbp-8]
    151: mov     [rax],rcx
    154: mov     rax,[rbp+10h]
    158: mov     rax,[rax+8]
    15c: mov     [rbp-10h],rax
    160: mov     rax,[rbp+10h]
    164: mov     rax,[rax+10h]
    168: mov     [rbp-18h],rax
    16c: mov     rax,[rbp-10h]
    170: add     rax,[rbp-18h]
    174: mov     [rbp-8],rax
    178: mov     rax,[rbp+10h]
    17c: mov     rcx,[rbp-8]
    180: mov     [rax+8],rcx
    184: mov     rax,[rbp+10h]
    188: mov     rax,[rax]
    18b: mov     [rbp-10h],rax
    18f: mov     rax,[rbp+10h]
    193: mov     rax,[rax+18h]
    197: mov     [rbp-18h],rax
    19b: mov     rax,[rbp-10h]
    19f: add     rax,[rbp-18h]
    1a3: mov     [rbp-8],rax
    1a7: mov     rax,[rbp+10h]
    1ab: mov     rcx,[rbp-8]
    1af: mov     [rax],rcx
    1b2: mov     rax,[rbp+10h]
    1b6: mov     rax,[rax+10h]
    1ba: mov     [rbp-10h],rax
    1be: mov     dword ptr [rbp-1Ch],11h
    1c5: mov     edi,0FFFFFFF8h
    1ca: mov     esi,0FFFFFFF0h
    1cf: mov     edx,0FFFFFFE4h
    1d4: call    ryo_h_RotlW64
    1d9: mov     rax,[rbp+10h]
    1dd: mov     rcx,[rbp-8]
    1e1: mov     [rax+10h],rcx
    1e5: mov     rax,[rbp+10h]
    1e9: mov     rax,[rax+8]
    1ed: mov     [rbp-8],rax
    1f1: mov     rax,[rbp+10h]
    1f5: mov     rax,[rax+10h]
    1f9: mov     [rbp-20h],rax
    1fd: xor     rax,[rbp-8]
    201: mov     [rbp-30h],rax
    205: mov     rax,[rbp+10h]
    209: mov     rcx,[rbp-30h]
    20d: mov     [rax+10h],rcx
    211: mov     rax,[rbp+10h]
    215: mov     rax,[rax+18h]
    219: mov     [rbp-10h],rax
    21d: mov     dword ptr [rbp-1Ch],15h
    224: mov     edi,0FFFFFFF8h
    229: mov     esi,0FFFFFFF0h
    22e: mov     edx,0FFFFFFE4h
    233: call    ryo_h_RotlW64
    238: mov     rax,[rbp+10h]
    23c: mov     rcx,[rbp-8]
    240: mov     [rax+18h],rcx
    244: mov     rax,[rbp+10h]
    248: mov     rax,[rax]
    24b: mov     [rbp-8],rax
    24f: mov     rax,[rbp+10h]
    253: mov     rax,[rax+18h]
    257: mov     [rbp-20h],rax
    25b: xor     rax,[rbp-8]
    25f: mov     [rbp-30h],rax
    263: mov     rax,[rbp+10h]
    267: mov     rcx,[rbp-30h]
    26b: mov     [rax+18h],rcx
    26f: mov     rax,[rbp+10h]
    273: mov     rax,[rax+8]
    277: mov     [rbp-10h],rax
    27b: mov     dword ptr [rbp-1Ch],20h
    282: mov     edi,0FFFFFFF8h
    287: mov     esi,0FFFFFFF0h
    28c: mov     edx,0FFFFFFE4h
    291: call    ryo_h_RotlW64
    296: mov     rax,[rbp+10h]
    29a: mov     rcx,[rbp-8]
    29e: mov     [rax+8],rcx
    2a2: xor     edi,edi
    2a4: xor     esi,esi
    2a6: call    ryo_h_Ret
    2ab: leave
    2ac: ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+10h]
     1b: mov     [rbp-18h],rax
     1f: mov     rax,[rbp-10h]
     23: add     rax,[rbp-18h]
     27: mov     [rbp-8],rax
     2b: mov     rax,[rbp+10h]
     2f: mov     rcx,[rbp-8]
     33: mov     [rax],rcx
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax+8]
     3e: mov     [rbp-10h],rax
     42: mov     rax,[rbp+10h]
     46: mov     rax,[rax+18h]
     4a: mov     [rbp-18h],rax
     4e: mov     rax,[rbp-10h]
     52: add     rax,[rbp-18h]
     56: mov     [rbp-8],rax
     5a: mov     rax,[rbp+10h]
     5e: mov     rcx,[rbp-8]
     62: mov     [rax+8],rcx
     66: mov     rax,[rbp+10h]
     6a: mov     rax,[rax+10h]
     6e: mov     [rbp-10h],rax
     72: mov     dword ptr [rbp-1Ch],0Dh
     79: mov     edi,0FFFFFFF8h
     7e: mov     esi,0FFFFFFF0h
     83: mov     edx,0FFFFFFE4h
     88: call    ryo_h_RotlW64
     8d: mov     rax,[rbp+10h]
     91: mov     rcx,[rbp-8]
     95: mov     [rax+10h],rcx
     99: mov     rax,[rbp+10h]
     9d: mov     rax,[rax]
     a0: mov     [rbp-8],rax
     a4: mov     rax,[rbp+10h]
     a8: mov     rax,[rax+10h]
     ac: mov     [rbp-20h],rax
     b0: xor     rax,[rbp-8]
     b4: mov     [rbp-30h],rax
     b8: mov     rax,[rbp+10h]
     bc: mov     rcx,[rbp-30h]
     c0: mov     [rax+10h],rcx
     c4: mov     rax,[rbp+10h]
     c8: mov     rax,[rax+18h]
     cc: mov     [rbp-10h],rax
     d0: mov     dword ptr [rbp-1Ch],10h
     d7: mov     edi,0FFFFFFF8h
     dc: mov     esi,0FFFFFFF0h
     e1: mov     edx,0FFFFFFE4h
     e6: call    ryo_h_RotlW64
     eb: mov     rax,[rbp+10h]
     ef: mov     rcx,[rbp-8]
     f3: mov     [rax+18h],rcx
     f7: mov     rax,[rbp+10h]
     fb: mov     rax,[rax+8]
     ff: mov     [rbp-8],rax
    103: mov     rax,[rbp+10h]
    107: mov     rax,[rax+18h]
    10b: mov     [rbp-20h],rax
    10f: xor     rax,[rbp-8]
    113: mov     [rbp-30h],rax
    117: mov     rax,[rbp+10h]
    11b: mov     rcx,[rbp-30h]
    11f: mov     [rax+18h],rcx
    123: mov     rax,[rbp+10h]
    127: mov     rax,[rax]
    12a: mov     [rbp-10h],rax
    12e: mov     dword ptr [rbp-1Ch],20h
    135: mov     edi,0FFFFFFF8h
    13a: mov     esi,0FFFFFFF0h
    13f: mov     edx,0FFFFFFE4h
    144: call    ryo_h_RotlW64
    149: mov     rax,[rbp+10h]
    14d: mov     rcx,[rbp-8]
    151: mov     [rax],rcx
    154: mov     rax,[rbp+10h]
    158: mov     rax,[rax+8]
    15c: mov     [rbp-10h],rax
    160: mov     rax,[rbp+10h]
    164: mov     rax,[rax+10h]
    168: mov     [rbp-18h],rax
    16c: mov     rax,[rbp-10h]
    170: add     rax,[rbp-18h]
    174: mov     [rbp-8],rax
    178: mov     rax,[rbp+10h]
    17c: mov     rcx,[rbp-8]
    180: mov     [rax+8],rcx
    184: mov     rax,[rbp+10h]
    188: mov     rax,[rax]
    18b: mov     [rbp-10h],rax
    18f: mov     rax,[rbp+10h]
    193: mov     rax,[rax+18h]
    197: mov     [rbp-18h],rax
    19b: mov     rax,[rbp-10h]
    19f: add     rax,[rbp-18h]
    1a3: mov     [rbp-8],rax
    1a7: mov     rax,[rbp+10h]
    1ab: mov     rcx,[rbp-8]
    1af: mov     [rax],rcx
    1b2: mov     rax,[rbp+10h]
    1b6: mov     rax,[rax+10h]
    1ba: mov     [rbp-10h],rax
    1be: mov     dword ptr [rbp-1Ch],11h
    1c5: mov     edi,0FFFFFFF8h
    1ca: mov     esi,0FFFFFFF0h
    1cf: mov     edx,0FFFFFFE4h
    1d4: call    ryo_h_RotlW64
    1d9: mov     rax,[rbp+10h]
    1dd: mov     rcx,[rbp-8]
    1e1: mov     [rax+10h],rcx
    1e5: mov     rax,[rbp+10h]
    1e9: mov     rax,[rax+8]
    1ed: mov     [rbp-8],rax
    1f1: mov     rax,[rbp+10h]
    1f5: mov     rax,[rax+10h]
    1f9: mov     [rbp-20h],rax
    1fd: xor     rax,[rbp-8]
    201: mov     [rbp-30h],rax
    205: mov     rax,[rbp+10h]
    209: mov     rcx,[rbp-30h]
    20d: mov     [rax+10h],rcx
    211: mov     rax,[rbp+10h]
    215: mov     rax,[rax+18h]
    219: mov     [rbp-10h],rax
    21d: mov     dword ptr [rbp-1Ch],15h
    224: mov     edi,0FFFFFFF8h
    229: mov     esi,0FFFFFFF0h
    22e: mov     edx,0FFFFFFE4h
    233: call    ryo_h_RotlW64
    238: mov     rax,[rbp+10h]
    23c: mov     rcx,[rbp-8]
    240: mov     [rax+18h],rcx
    244: mov     rax,[rbp+10h]
    248: mov     rax,[rax]
    24b: mov     [rbp-8],rax
    24f: mov     rax,[rbp+10h]
    253: mov     rax,[rax+18h]
    257: mov     [rbp-20h],rax
    25b: xor     rax,[rbp-8]
    25f: mov     [rbp-30h],rax
    263: mov     rax,[rbp+10h]
    267: mov     rcx,[rbp-30h]
    26b: mov     [rax+18h],rcx
    26f: mov     rax,[rbp+10h]
    273: mov     rax,[rax+8]
    277: mov     [rbp-10h],rax
    27b: mov     dword ptr [rbp-1Ch],20h
    282: mov     edi,0FFFFFFF8h
    287: mov     esi,0FFFFFFF0h
    28c: mov     edx,0FFFFFFE4h
    291: call    ryo_h_RotlW64
    296: mov     rax,[rbp+10h]
    29a: mov     rcx,[rbp-8]
    29e: mov     [rax+8],rcx
    2a2: mov     rax,[rbp+10h]
    2a6: mov     rax,[rax]
    2a9: mov     [rbp-10h],rax
    2ad: mov     rax,[rbp+10h]
    2b1: mov     rax,[rax+10h]
    2b5: mov     [rbp-18h],rax
    2b9: mov     rax,[rbp-10h]
    2bd: add     rax,[rbp-18h]
    2c1: mov     [rbp-8],rax
    2c5: mov     rax,[rbp+10h]
    2c9: mov     rcx,[rbp-8]
    2cd: mov     [rax],rcx
    2d0: mov     rax,[rbp+10h]
    2d4: mov     rax,[rax+8]
    2d8: mov     [rbp-10h],rax
    2dc: mov     rax,[rbp+10h]
    2e0: mov     rax,[rax+18h]
    2e4: mov     [rbp-18h],rax
    2e8: mov     rax,[rbp-10h]
    2ec: add     rax,[rbp-18h]
    2f0: mov     [rbp-8],rax
    2f4: mov     rax,[rbp+10h]
    2f8: mov     rcx,[rbp-8]
    2fc: mov     [rax+8],rcx
    300: mov     rax,[rbp+10h]
    304: mov     rax,[rax+10h]
    308: mov     [rbp-10h],rax
    30c: mov     dword ptr [rbp-1Ch],0Dh
    313: mov     edi,0FFFFFFF8h
    318: mov     esi,0FFFFFFF0h
    31d: mov     edx,0FFFFFFE4h
    322: call    ryo_h_RotlW64
    327: mov     rax,[rbp+10h]
    32b: mov     rcx,[rbp-8]
    32f: mov     [rax+10h],rcx
    333: mov     rax,[rbp+10h]
    337: mov     rax,[rax]
    33a: mov     [rbp-8],rax
    33e: mov     rax,[rbp+10h]
    342: mov     rax,[rax+10h]
    346: mov     [rbp-20h],rax
    34a: xor     rax,[rbp-8]
    34e: mov     [rbp-30h],rax
    352: mov     rax,[rbp+10h]
    356: mov     rcx,[rbp-30h]
    35a: mov     [rax+10h],rcx
    35e: mov     rax,[rbp+10h]
    362: mov     rax,[rax+18h]
    366: mov     [rbp-10h],rax
    36a: mov     dword ptr [rbp-1Ch],10h
    371: mov     edi,0FFFFFFF8h
    376: mov     esi,0FFFFFFF0h
    37b: mov     edx,0FFFFFFE4h
    380: call    ryo_h_RotlW64
    385: mov     rax,[rbp+10h]
    389: mov     rcx,[rbp-8]
    38d: mov     [rax+18h],rcx
    391: mov     rax,[rbp+10h]
    395: mov     rax,[rax+8]
    399: mov     [rbp-8],rax
    39d: mov     rax,[rbp+10h]
    3a1: mov     rax,[rax+18h]
    3a5: mov     [rbp-20h],rax
    3a9: xor     rax,[rbp-8]
    3ad: mov     [rbp-30h],rax
    3b1: mov     rax,[rbp+10h]
    3b5: mov     rcx,[rbp-30h]
    3b9: mov     [rax+18h],rcx
    3bd: mov     rax,[rbp+10h]
    3c1: mov     rax,[rax]
    3c4: mov     [rbp-10h],rax
    3c8: mov     dword ptr [rbp-1Ch],20h
    3cf: mov     edi,0FFFFFFF8h
    3d4: mov     esi,0FFFFFFF0h
    3d9: mov     edx,0FFFFFFE4h
    3de: call    ryo_h_RotlW64
    3e3: mov     rax,[rbp+10h]
    3e7: mov     rcx,[rbp-8]
    3eb: mov     [rax],rcx
    3ee: mov     rax,[rbp+10h]
    3f2: mov     rax,[rax+8]
    3f6: mov     [rbp-10h],rax
    3fa: mov     rax,[rbp+10h]
    3fe: mov     rax,[rax+10h]
    402: mov     [rbp-18h],rax
    406: mov     rax,[rbp-10h]
    40a: add     rax,[rbp-18h]
    40e: mov     [rbp-8],rax
    412: mov     rax,[rbp+10h]
    416: mov     rcx,[rbp-8]
    41a: mov     [rax+8],rcx
    41e: mov     rax,[rbp+10h]
    422: mov     rax,[rax]
    425: mov     [rbp-10h],rax
    429: mov     rax,[rbp+10h]
    42d: mov     rax,[rax+18h]
    431: mov     [rbp-18h],rax
    435: mov     rax,[rbp-10h]
    439: add     rax,[rbp-18h]
    43d: mov     [rbp-8],rax
    441: mov     rax,[rbp+10h]
    445: mov     rcx,[rbp-8]
    449: mov     [rax],rcx
    44c: mov     rax,[rbp+10h]
    450: mov     rax,[rax+10h]
    454: mov     [rbp-10h],rax
    458: mov     dword ptr [rbp-1Ch],11h
    45f: mov     edi,0FFFFFFF8h
    464: mov     esi,0FFFFFFF0h
    469: mov     edx,0FFFFFFE4h
    46e: call    ryo_h_RotlW64
    473: mov     rax,[rbp+10h]
    477: mov     rcx,[rbp-8]
    47b: mov     [rax+10h],rcx
    47f: mov     rax,[rbp+10h]
    483: mov     rax,[rax+8]
    487: mov     [rbp-8],rax
    48b: mov     rax,[rbp+10h]
    48f: mov     rax,[rax+10h]
    493: mov     [rbp-20h],rax
    497: xor     rax,[rbp-8]
    49b: mov     [rbp-30h],rax
    49f: mov     rax,[rbp+10h]
    4a3: mov     rcx,[rbp-30h]
    4a7: mov     [rax+10h],rcx
    4ab: mov     rax,[rbp+10h]
    4af: mov     rax,[rax+18h]
    4b3: mov     [rbp-10h],rax
    4b7: mov     dword ptr [rbp-1Ch],15h
    4be: mov     edi,0FFFFFFF8h
    4c3: mov     esi,0FFFFFFF0h
    4c8: mov     edx,0FFFFFFE4h
    4cd: call    ryo_h_RotlW64
    4d2: mov     rax,[rbp+10h]
    4d6: mov     rcx,[rbp-8]
    4da: mov     [rax+18h],rcx
    4de: mov     rax,[rbp+10h]
    4e2: mov     rax,[rax]
    4e5: mov     [rbp-8],rax
    4e9: mov     rax,[rbp+10h]
    4ed: mov     rax,[rax+18h]
    4f1: mov     [rbp-20h],rax
    4f5: xor     rax,[rbp-8]
    4f9: mov     [rbp-30h],rax
    4fd: mov     rax,[rbp+10h]
    501: mov     rcx,[rbp-30h]
    505: mov     [rax+18h],rcx
    509: mov     rax,[rbp+10h]
    50d: mov     rax,[rax+8]
    511: mov     [rbp-10h],rax
    515: mov     dword ptr [rbp-1Ch],20h
    51c: mov     edi,0FFFFFFF8h
    521: mov     esi,0FFFFFFF0h
    526: mov     edx,0FFFFFFE4h
    52b: call    ryo_h_RotlW64
    530: mov     rax,[rbp+10h]
    534: mov     rcx,[rbp-8]
    538: mov     [rax+8],rcx
    53c: mov     rax,[rbp+10h]
    540: mov     rax,[rax]
    543: mov     [rbp-10h],rax
    547: mov     rax,[rbp+10h]
    54b: mov     rax,[rax+10h]
    54f: mov     [rbp-18h],rax
    553: mov     rax,[rbp-10h]
    557: add     rax,[rbp-18h]
    55b: mov     [rbp-8],rax
    55f: mov     rax,[rbp+10h]
    563: mov     rcx,[rbp-8]
    567: mov     [rax],rcx
    56a: mov     rax,[rbp+10h]
    56e: mov     rax,[rax+8]
    572: mov     [rbp-10h],rax
    576: mov     rax,[rbp+10h]
    57a: mov     rax,[rax+18h]
    57e: mov     [rbp-18h],rax
    582: mov     rax,[rbp-10h]
    586: add     rax,[rbp-18h]
    58a: mov     [rbp-8],rax
    58e: mov     rax,[rbp+10h]
    592: mov     rcx,[rbp-8]
    596: mov     [rax+8],rcx
    59a: mov     rax,[rbp+10h]
    59e: mov     rax,[rax+10h]
    5a2: mov     [rbp-10h],rax
    5a6: mov     dword ptr [rbp-1Ch],0Dh
    5ad: mov     edi,0FFFFFFF8h
    5b2: mov     esi,0FFFFFFF0h
    5b7: mov     edx,0FFFFFFE4h
    5bc: call    ryo_h_RotlW64
    5c1: mov     rax,[rbp+10h]
    5c5: mov     rcx,[rbp-8]
    5c9: mov     [rax+10h],rcx
    5cd: mov     rax,[rbp+10h]
    5d1: mov     rax,[rax]
    5d4: mov     [rbp-8],rax
    5d8: mov     rax,[rbp+10h]
    5dc: mov     rax,[rax+10h]
    5e0: mov     [rbp-20h],rax
    5e4: xor     rax,[rbp-8]
    5e8: mov     [rbp-30h],rax
    5ec: mov     rax,[rbp+10h]
    5f0: mov     rcx,[rbp-30h]
    5f4: mov     [rax+10h],rcx
    5f8: mov     rax,[rbp+10h]
    5fc: mov     rax,[rax+18h]
    600: mov     [rbp-10h],rax
    604: mov     dword ptr [rbp-1Ch],10h
    60b: mov     edi,0FFFFFFF8h
    610: mov     esi,0FFFFFFF0h
    615: mov     edx,0FFFFFFE4h
    61a: call    ryo_h_RotlW64
    61f: mov     rax,[rbp+10h]
    623: mov     rcx,[rbp-8]
    627: mov     [rax+18h],rcx
    62b: mov     rax,[rbp+10h]
    62f: mov     rax,[rax+8]
    633: mov     [rbp-8],rax
    637: mov     rax,[rbp+10h]
    63b: mov     rax,[rax+18h]
    63f: mov     [rbp-20h],rax
    643: xor     rax,[rbp-8]
    647: mov     [rbp-30h],rax
    64b: mov     rax,[rbp+10h]
    64f: mov     rcx,[rbp-30h]
    653: mov     [rax+18h],rcx
    657: mov     rax,[rbp+10h]
    65b: mov     rax,[rax]
    65e: mov     [rbp-10h],rax
    662: mov     dword ptr [rbp-1Ch],20h
    669: mov     edi,0FFFFFFF8h
    66e: mov     esi,0FFFFFFF0h
    673: mov     edx,0FFFFFFE4h
    678: call    ryo_h_RotlW64
    67d: mov     rax,[rbp+10h]
    681: mov     rcx,[rbp-8]
    685: mov     [rax],rcx
    688: mov     rax,[rbp+10h]
    68c: mov     rax,[rax+8]
    690: mov     [rbp-10h],rax
    694: mov     rax,[rbp+10h]
    698: mov     rax,[rax+10h]
    69c: mov     [rbp-18h],rax
    6a0: mov     rax,[rbp-10h]
    6a4: add     rax,[rbp-18h]
    6a8: mov     [rbp-8],rax
    6ac: mov     rax,[rbp+10h]
    6b0: mov     rcx,[rbp-8]
    6b4: mov     [rax+8],rcx
    6b8: mov     rax,[rbp+10h]
    6bc: mov     rax,[rax]
    6bf: mov     [rbp-10h],rax
    6c3: mov     rax,[rbp+10h]
    6c7: mov     rax,[rax+18h]
    6cb: mov     [rbp-18h],rax
    6cf: mov     rax,[rbp-10h]
    6d3: add     rax,[rbp-18h]
    6d7: mov     [rbp-8],rax
    6db: mov     rax,[rbp+10h]
    6df: mov     rcx,[rbp-8]
    6e3: mov     [rax],rcx
    6e6: mov     rax,[rbp+10h]
    6ea: mov     rax,[rax+10h]
    6ee: mov     [rbp-10h],rax
    6f2: mov     dword ptr [rbp-1Ch],11h
    6f9: mov     edi,0FFFFFFF8h
    6fe: mov     esi,0FFFFFFF0h
    703: mov     edx,0FFFFFFE4h
    708: call    ryo_h_RotlW64
    70d: mov     rax,[rbp+10h]
    711: mov     rcx,[rbp-8]
    715: mov     [rax+10h],rcx
    719: mov     rax,[rbp+10h]
    71d: mov     rax,[rax+8]
    721: mov     [rbp-8],rax
    725: mov     rax,[rbp+10h]
    729: mov     rax,[rax+10h]
    72d: mov     [rbp-20h],rax
    731: xor     rax,[rbp-8]
    735: mov     [rbp-30h],rax
    739: mov     rax,[rbp+10h]
    73d: mov     rcx,[rbp-30h]
    741: mov     [rax+10h],rcx
    745: mov     rax,[rbp+10h]
    749: mov     rax,[rax+18h]
    74d: mov     [rbp-10h],rax
    751: mov     dword ptr [rbp-1Ch],15h
    758: mov     edi,0FFFFFFF8h
    75d: mov     esi,0FFFFFFF0h
    762: mov     edx,0FFFFFFE4h
    767: call    ryo_h_RotlW64
    76c: mov     rax,[rbp+10h]
    770: mov     rcx,[rbp-8]
    774: mov     [rax+18h],rcx
    778: mov     rax,[rbp+10h]
    77c: mov     rax,[rax]
    77f: mov     [rbp-8],rax
    783: mov     rax,[rbp+10h]
    787: mov     rax,[rax+18h]
    78b: mov     [rbp-20h],rax
    78f: xor     rax,[rbp-8]
    793: mov     [rbp-30h],rax
    797: mov     rax,[rbp+10h]
    79b: mov     rcx,[rbp-30h]
    79f: mov     [rax+18h],rcx
    7a3: mov     rax,[rbp+10h]
    7a7: mov     rax,[rax+8]
    7ab: mov     [rbp-10h],rax
    7af: mov     dword ptr [rbp-1Ch],20h
    7b6: mov     edi,0FFFFFFF8h
    7bb: mov     esi,0FFFFFFF0h
    7c0: mov     edx,0FFFFFFE4h
    7c5: call    ryo_h_RotlW64
    7ca: mov     rax,[rbp+10h]
    7ce: mov     rcx,[rbp-8]
    7d2: mov     [rax+8],rcx
    7d6: xor     edi,edi
    7d8: xor     esi,esi
    7da: call    ryo_h_Ret
    7df: leave
    7e0: ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     [rbp-30h],rax
     17: call    fn0
     1c: nop     [rcx-10h]
     23: lea     rax,[rbp-10h]
     27: mov     [rbp-20h],rax
     2b: mov     [rbp-30h],rax
     2f: call    fn1
     34: nop     [rcx-20h]
     3b: xor     edi,edi
     3d: xor     esi,esi
     3f: call    ryo_h_Ret
     44: leave
     45: ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-19h],1
      c: test    byte ptr [rbp-19h],0FFh
     10: je      3Bh
     12: mov     rax,[rbp+10h]
     16: mov     [rbp-18h],rax
     1a: mov     [rbp-30h],rax
     1e: mov     edi,0FFFFFFD8h
     23: lea     rsi,[k0]
     2a: call    ryo_h_AddrAbs
     2f: call    fn1
     34: nop     [rcx-8]
     3b: mov     rax,[rbp+10h]
     3f: mov     [rbp-10h],rax
     43: mov     [rbp-8],rax
     47: mov     edi,0FFFFFFF8h
     4c: mov     esi,8
     51: call    ryo_h_Ret
     56: leave
     57: ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_char
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFBCh
     10: mov     esi,4
     15: call    ryo_h_Zero
     1a: lea     rax,[rbp-44h]
     1e: mov     [rbp-40h],rax
     22: mov     [rbp-38h],rax
     26: mov     qword ptr [rbp-30h],4
     2e: mov     eax,[rbp+18h]
     31: mov     [rbp-48h],eax
     34: mov     [rbp-80h],eax
     37: mov     edi,0FFFFFF88h
     3c: mov     esi,0FFFFFFC8h
     41: call    ryo_h_MovW128
     46: call    fn0
     4b: nop     [rcx-58h]
     52: jmp     71h
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: mov     edi,0FFFFFFFFh
     65: mov     esi,1
     6a: call    ryo_h_Ret
     6f: leave
     70: ret
     71: mov     rax,[rbp-58h]
     75: mov     [rbp-68h],rax
     79: mov     rax,[rbp-50h]
     7d: mov     [rbp-60h],rax
     81: mov     edi,0FFFFFFE8h
     86: mov     esi,0FFFFFF98h
     8b: call    ryo_h_MovW128
     90: mov     rax,[rbp-18h]
     94: mov     [rbp-28h],rax
     98: mov     rax,[rbp-10h]
     9c: mov     [rbp-20h],rax
     a0: mov     rax,[rbp+10h]
     a4: mov     [rbp-80h],rax
     a8: mov     edi,0FFFFFF88h
     ad: mov     esi,0FFFFFFD8h
     b2: call    ryo_h_MovW128
     b7: call    fn1
     bc: nop     [rcx-1]
     c3: jmp     60h

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFE8h
     15: mov     esi,18h
     1a: call    ryo_h_MovW128
     1f: call    fn0
     24: nop     [rcx-1]
     2b: mov     edi,0FFFFFFFFh
     30: mov     esi,1
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_str
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     edi,0FFFFFFC8h
     18: mov     esi,18h
     1d: call    ryo_h_MovW128
     22: mov     rax,[rbp-18h]
     26: mov     [rbp-60h],rax
     2a: mov     edi,0FFFFFFA8h
     2f: mov     esi,0FFFFFFC8h
     34: call    ryo_h_MovW128
     39: call    fn0
     3e: nop     [rcx-28h]
     45: mov     edi,0FFFFFFBCh
     4a: mov     esi,0FFFFFFD8h
     4f: xor     edx,edx
     51: xor     ecx,ecx
     53: xor     r8d,r8d
     56: mov     r9d,1
     5c: call    ryo_h_DiscrNicheW64
     61: mov     edi,0FFFFFFF0h
     66: mov     esi,0FFFFFFBCh
     6b: call    ryo_h_ZextW32W64
     70: mov     edi,0FFFFFFF0h
     75: xor     esi,esi
     77: mov     edx,2
     7c: call    ryo_h_SwitchDenseW64
     81: lea     rcx,[94h]
     88: movsxd  rax,[rcx+rax*4]
     8c: add     rax,rcx
     8f: jmp     rax
     91: int3
     92: int3
     93: int3
     94: .long   cdh
     98: .long   a7h
     9c: .long   a0h
     a0: call    ryo_h_Unreachable
     a5: ud2
     a7: mov     rax,[rbp-28h]
     ab: mov     [rbp-40h],rax
     af: mov     rax,[rbp+10h]
     b3: lea     rax,[rax+8]
     b7: mov     [rbp-48h],rax
     bb: mov     [rbp-60h],rax
     bf: call    fn1
     c4: nop     [rcx-48h]
     cb: jmp     0D3h
     cd: mov     byte ptr [rbp-1],0
     d1: jmp     108h
     d3: mov     rax,[rbp+10h]
     d7: mov     rcx,[rbp-28h]
     db: mov     [rax+8],rcx
     df: mov     byte ptr [rbp-1],1
     e3: jmp     108h
     e5: nop     [rax+rax]
     ee: xchg    ax,ax
     f0: mov     rax,[rbp+10h]
     f4: mov     rcx,[rbp-28h]
     f8: mov     [rax+8],rcx
     fc: mov     edi,0FFFFFFE0h
    101: call    ryo_h_Resume
    106: ud2
    108: mov     edi,0FFFFFFFFh
    10d: mov     esi,1
    112: call    ryo_h_Ret
    117: leave
    118: ret
    119: mov     rdi,rax
    11c: mov     esi,0FFFFFFE0h
    121: call    ryo_h_Lpad
    126: jmp     0F0h

fn <fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn} as std::ops::FnOnce<()>>::call_once - shim(fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn})
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: call    fn0
      d: nop     [rcx-10h]
     14: mov     edi,0FFFFFFF0h
     19: mov     esi,10h
     1e: call    ryo_h_Ret
     23: leave
     24: ret

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

fn <for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned} as std::ops::FnOnce<(&str,)>>::call_once - shim(for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned})
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFD8h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFC0h
     1c: mov     esi,0FFFFFFD8h
     21: call    ryo_h_MovW128
     26: call    fn0
     2b: nop     [rcx-18h]
     32: mov     edi,0FFFFFFE8h
     37: mov     esi,18h
     3c: call    ryo_h_Ret
     41: leave
     42: ret

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFC0h
     10: mov     esi,10h
     15: mov     edx,20h
     1a: call    ryo_h_Copy
     1f: mov     rax,[rbp+30h]
     23: mov     [rbp-48h],rax
     27: lea     rax,[rbp+40h]
     2b: mov     [rbp-20h],rax
     2f: mov     [rbp-18h],rax
     33: mov     edi,0FFFFFF80h
     38: mov     esi,0FFFFFFC0h
     3d: mov     edx,20h
     42: call    ryo_h_Copy
     47: mov     rax,[rbp-48h]
     4b: mov     [rbp-60h],rax
     4f: mov     rax,[rbp+38h]
     53: mov     [rbp-58h],rax
     57: mov     rax,[rbp-18h]
     5b: mov     [rbp-50h],rax
     5f: call    fn0
     64: nop     [rcx-8]
     6b: jmp     9Ch
     6d: nop     [rax]
     70: mov     edi,0FFFFFFF8h
     75: mov     esi,8
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     edi,0FFFFFFF0h
     95: call    ryo_h_Resume
     9a: ud2
     9c: jmp     70h
     9e: mov     rdi,rax
     a1: mov     esi,0FFFFFFF0h
     a6: call    ryo_h_Lpad
     ab: jmp     90h

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-51h],0
      f: test    byte ptr [rbp-51h],0FFh
     13: je      0C7h
     19: jmp     0BAh
     1e: xchg    ax,ax
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret
     31: nop     [rax+rax]
     3a: nop     [rax+rax]
     40: mov     rax,[rbp-20h]
     44: mov     [rbp-30h],rax
     48: mov     [rbp-20h],rax
     4c: mov     rax,[rbp-30h]
     50: lea     rax,[rax+8]
     54: mov     [rbp-28h],rax
     58: mov     rax,[rbp+10h]
     5c: mov     rax,[rax]
     5f: mov     [rbp-18h],rax
     63: mov     rax,[rbp-20h]
     67: mov     [rbp-50h],rax
     6b: mov     rax,[rbp-28h]
     6f: mov     [rbp-48h],rax
     73: mov     rax,[rbp+18h]
     77: mov     [rbp-40h],rax
     7b: mov     edi,0FFFFFFC8h
     80: mov     esi,0FFFFFFB0h
     85: call    ryo_h_MovW128
     8a: mov     rax,[rbp-18h]
     8e: mov     [rbp-80h],rax
     92: mov     rax,[rbp-40h]
     96: mov     [rbp-78h],rax
     9a: mov     edi,0FFFFFF90h
     9f: mov     esi,0FFFFFFC8h
     a4: call    ryo_h_MovW128
     a9: call    fn0
     ae: nop     [rcx-8]
     b5: jmp     20h
     ba: mov     qword ptr [rbp-20h],8
     c2: jmp     40h
     c7: mov     rax,[rbp+20h]
     cb: mov     [rbp-38h],rax
     cf: mov     [rbp-28h],rax
     d3: mov     byte ptr [rbp-51h],0
     d7: test    byte ptr [rbp-51h],0FFh
     db: je      0EFh
     dd: jmp     0E5h
     df: nop
     e0: jmp     40h
     e5: mov     rax,[rbp-28h]
     e9: mov     [rbp-20h],rax
     ed: jmp     0E0h
     ef: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
     f7: mov     rax,[rbp-28h]
     fb: imul    rcx,[rbp-58h],10h
    100: add     rax,rcx
    103: mov     [rbp-20h],rax
    107: jmp     0E0h

fn <hashbrown::raw::RawTable<(std::string::String, usize)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+20h]
     18: mov     [rbp-10h],rax
     1c: mov     rax,[rbp-8]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-10h]
     28: mov     [rbp-28h],rax
     2c: mov     edi,0FFFFFFE0h
     31: lea     rsi,[k0]
     38: mov     edx,10h
     3d: call    ryo_h_Const
     42: call    fn1
     47: nop     [rcx]
     4e: xor     edi,edi
     50: xor     esi,esi
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <hashbrown::raw::RawTable<(u64, u64)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+20h]
     18: mov     [rbp-10h],rax
     1c: mov     rax,[rbp-8]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-10h]
     28: mov     [rbp-28h],rax
     2c: mov     edi,0FFFFFFE0h
     31: lea     rsi,[k0]
     38: mov     edx,10h
     3d: call    ryo_h_Const
     42: call    fn1
     47: nop     [rcx]
     4e: xor     edi,edi
     50: xor     esi,esi
     52: call    ryo_h_Ret
     57: leave
     58: ret

fn <hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     rax,[rbp+10h]
     18: mov     [rbp-18h],rax
     1c: mov     [rbp-10h],rax
     20: mov     rax,[rbp-8]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-10h]
     2c: mov     [rbp-28h],rax
     30: call    fn0
     35: nop     [rcx]
     3c: xor     edi,edi
     3e: xor     esi,esi
     40: call    ryo_h_Ret
     45: leave
     46: ret

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+18h]
     18: mov     [rbp-18h],rax
     1c: mov     [rbp-10h],rax
     20: mov     rax,[rbp-8]
     24: mov     [rbp-30h],rax
     28: mov     rax,[rbp-10h]
     2c: mov     [rbp-28h],rax
     30: call    fn0
     35: nop     [rcx]
     3c: xor     edi,edi
     3e: xor     esi,esi
     40: call    ryo_h_Ret
     45: leave
     46: ret

fn <std::alloc::Global as std::alloc::Allocator>::allocate
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFD0h
      d: mov     esi,18h
     12: call    ryo_h_MovW128
     17: mov     byte ptr [rbp-20h],0
     1b: call    fn0
     20: nop     [rcx-10h]
     27: mov     edi,0FFFFFFF0h
     2c: mov     esi,10h
     31: call    ryo_h_Ret
     36: leave
     37: ret

fn <std::alloc::Global as std::alloc::Allocator>::deallocate
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+28h]
      c: mov     [rbp-20h],rax
     10: cmp     rax,0
     14: je      70h
     16: mov     rax,[rbp+20h]
     1a: mov     [rbp-28h],rax
     1e: mov     rax,[rbp+18h]
     22: mov     [rbp-50h],rax
     26: mov     rax,[rbp-20h]
     2a: mov     [rbp-48h],rax
     2e: mov     rax,[rbp-28h]
     32: mov     [rbp-40h],rax
     36: lea     rdi,[sym0]
     3d: lea     rsi,[site1]
     44: mov     edx,0FFFFFFD0h
     49: call    ryo_h_CallExt
     4e: test    rax,rax
     51: je      5Eh
     53: call    rax
     55: nop     [rcx]
     5c: jmp     6Eh
     5e: mov     rdi,rbp
     61: lea     rsi,[ro+4]
     68: call    qword ptr [sym2]
     6e: jmp     7Bh
     70: xor     edi,edi
     72: xor     esi,esi
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: jmp     70h

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFB8h
     10: mov     esi,10h
     15: mov     edx,28h
     1a: call    ryo_h_Copy
     1f: lea     rax,[rbp+40h]
     23: mov     [rbp-20h],rax
     27: mov     [rbp-18h],rax
     2b: mov     edi,0FFFFFF80h
     30: mov     esi,0FFFFFFB8h
     35: mov     edx,28h
     3a: call    ryo_h_Copy
     3f: mov     rax,[rbp+38h]
     43: mov     [rbp-58h],rax
     47: mov     rax,[rbp-18h]
     4b: mov     [rbp-50h],rax
     4f: call    fn0
     54: nop     [rcx-8]
     5b: jmp     8Ch
     5d: nop     [rax]
     60: mov     edi,0FFFFFFF8h
     65: mov     esi,8
     6a: call    ryo_h_Ret
     6f: leave
     70: ret
     71: nop     [rax+rax]
     7a: nop     [rax+rax]
     80: mov     edi,0FFFFFFF0h
     85: call    ryo_h_Resume
     8a: ud2
     8c: jmp     60h
     8e: mov     rdi,rax
     91: mov     esi,0FFFFFFF0h
     96: call    ryo_h_Lpad
     9b: jmp     80h

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+28h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-28h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-20h],rax
     2b: mov     rax,[rbp-10h]
     2f: mov     [rbp-40h],rax
     33: mov     rax,[rbp-28h]
     37: mov     [rbp-38h],rax
     3b: mov     rax,[rbp-20h]
     3f: mov     [rbp-30h],rax
     43: call    fn0
     48: nop     [rcx-8]
     4f: mov     edi,0FFFFFFF8h
     54: mov     esi,8
     59: call    ryo_h_Ret
     5e: leave
     5f: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     [rbp-20h],rax
     14: call    fn0
     19: nop     [rcx-8]
     20: mov     edi,0FFFFFFF8h
     25: mov     esi,8
     2a: call    ryo_h_Ret
     2f: leave
     30: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFD8h
     19: mov     esi,18h
     1e: call    ryo_h_MovW128
     23: call    fn0
     28: nop     [rcx]
     2f: xor     edi,edi
     31: xor     esi,esi
     33: call    ryo_h_Ret
     38: leave
     39: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     [rbp-30h],rax
     14: mov     edi,0FFFFFFD8h
     19: mov     esi,18h
     1e: call    ryo_h_MovW128
     23: call    fn0
     28: nop     [rcx-8]
     2f: xor     edi,edi
     31: xor     esi,esi
     33: call    ryo_h_Ret
     38: leave
     39: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-20h],rax
     10: lea     rax,[rbp-20h]
     14: mov     [rbp-18h],rax
     18: mov     [rbp-10h],rax
     1c: mov     qword ptr [rbp-8],8
     24: mov     rax,[rbp+10h]
     28: mov     [rbp-40h],rax
     2c: mov     edi,0FFFFFFC8h
     31: mov     esi,0FFFFFFF0h
     36: call    ryo_h_MovW128
     3b: call    fn0
     40: nop     [rcx]
     47: xor     edi,edi
     49: xor     esi,esi
     4b: call    ryo_h_Ret
     50: leave
     51: ret

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,160h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-98h],rax
     19: mov     rax,[rbp+10h]
     1d: mov     rax,[rax+8]
     21: mov     [rbp-0A0h],rax
     28: mov     qword ptr [rbp-150h],0
     33: mov     qword ptr [rbp-148h],0
     3e: mov     qword ptr [rbp-140h],0
     49: mov     qword ptr [rbp-138h],0
     54: mov     rax,[rbp-98h]
     5b: mov     [rbp-110h],rax
     62: mov     rax,[rbp-0A0h]
     69: mov     [rbp-108h],rax
     70: mov     qword ptr [rbp-100h],0
     7b: mov     edi,0FFFFFED0h
     80: mov     esi,0FFFFFEB0h
     85: mov     edx,20h
     8a: call    ryo_h_Copy
     8f: mov     qword ptr [rbp-0F8h],0
     9a: mov     qword ptr [rbp-0F0h],0
     a5: lea     rax,[rbp-130h]
     ac: mov     [rbp-138h],rax
     b3: mov     [rbp-160h],rax
     ba: call    fn0
     bf: nop     [rcx-48h]
     c6: mov     edi,0FFFFFF18h
     cb: mov     esi,0FFFFFED0h
     d0: mov     edx,48h
     d5: call    ryo_h_Copy
     da: mov     edi,0FFFFFF70h
     df: mov     esi,0FFFFFF18h
     e4: mov     edx,48h
     e9: call    ryo_h_Copy
     ee: mov     edi,0FFFFFFB8h
     f3: mov     esi,0FFFFFF70h
     f8: mov     edx,48h
     fd: call    ryo_h_Copy
    102: mov     edi,0FFFFFFB8h
    107: mov     esi,48h
    10c: call    ryo_h_Ret
    111: leave
    112: ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-80h],rax
     13: call    fn0
     18: nop     [rcx-58h]
     1f: lea     rax,[rbp+18h]
     23: mov     [rbp-60h],rax
     27: lea     rax,[rbp-58h]
     2b: mov     [rbp-68h],rax
     2f: mov     rax,[rbp-60h]
     33: mov     [rbp-80h],rax
     37: mov     rax,[rbp-68h]
     3b: mov     [rbp-78h],rax
     3f: call    fn1
     44: nop     [rcx-8]
     4b: lea     rax,[rbp-58h]
     4f: mov     [rbp-60h],rax
     53: mov     [rbp-80h],rax
     57: call    fn2
     5c: nop     [rcx-8]
     63: mov     edi,0FFFFFFF8h
     68: mov     esi,8
     6d: call    ryo_h_Ret
     72: leave
     73: ret
     74: nop     [rax+rax]
     7d: nop     [rax]
     80: mov     edi,0FFFFFFF0h
     85: call    ryo_h_Resume
     8a: ud2
     8c: mov     rdi,rax
     8f: mov     esi,0FFFFFFF0h
     94: call    ryo_h_Lpad
     99: jmp     80h
     9b: mov     rdi,rax
     9e: mov     esi,0FFFFFFF0h
     a3: call    ryo_h_Lpad
     a8: jmp     80h

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-80h],rax
     13: call    fn0
     18: nop     [rcx-58h]
     1f: lea     rax,[rbp+18h]
     23: mov     [rbp-60h],rax
     27: lea     rax,[rbp-58h]
     2b: mov     [rbp-68h],rax
     2f: mov     rax,[rbp-60h]
     33: mov     [rbp-80h],rax
     37: mov     rax,[rbp-68h]
     3b: mov     [rbp-78h],rax
     3f: call    fn1
     44: nop     [rcx-8]
     4b: lea     rax,[rbp-58h]
     4f: mov     [rbp-60h],rax
     53: mov     [rbp-80h],rax
     57: call    fn2
     5c: nop     [rcx-8]
     63: mov     edi,0FFFFFFF8h
     68: mov     esi,8
     6d: call    ryo_h_Ret
     72: leave
     73: ret
     74: nop     [rax+rax]
     7d: nop     [rax]
     80: mov     edi,0FFFFFFF0h
     85: call    ryo_h_Resume
     8a: ud2
     8c: mov     rdi,rax
     8f: mov     esi,0FFFFFFF0h
     94: call    ryo_h_Lpad
     99: jmp     80h
     9b: mov     rdi,rax
     9e: mov     esi,0FFFFFFF0h
     a3: call    ryo_h_Lpad
     a8: jmp     80h

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::IntoIterator>::into_iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFE0h
      d: mov     esi,10h
     12: mov     edx,20h
     17: call    ryo_h_Copy
     1c: mov     edi,0FFFFFFE0h
     21: mov     esi,20h
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::Iterator>::next
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

fn <std::ops::Range<u32> as std::iter::IntoIterator>::into_iter
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

fn <std::ops::Range<u32> as std::iter::range::RangeIteratorImpl>::spec_next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+4]
     18: mov     [rbp-20h],rax
     1c: mov     rax,[rbp-18h]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-20h]
     28: mov     [rbp-28h],rax
     2c: call    fn0
     31: nop     [rcx-9]
     38: test    byte ptr [rbp-9],0FFh
     3c: je      76h
     3e: mov     rax,[rbp+10h]
     42: mov     eax,[rax]
     44: mov     [rbp-10h],eax
     47: mov     [rbp-30h],eax
     4a: mov     qword ptr [rbp-28h],1
     52: call    fn1
     57: nop     [rcx-14h]
     5e: mov     rax,[rbp+10h]
     62: mov     ecx,[rbp-14h]
     65: mov     [rax],ecx
     67: mov     eax,[rbp-10h]
     6a: mov     [rbp-4],eax
     6d: mov     dword ptr [rbp-8],1
     74: jmp     7Dh
     76: mov     dword ptr [rbp-8],0
     7d: mov     edi,0FFFFFFF8h
     82: mov     esi,8
     87: call    ryo_h_Ret
     8c: leave
     8d: ret

fn <std::ops::Range<u64> as std::iter::IntoIterator>::into_iter
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

fn <std::ops::Range<u64> as std::iter::Iterator>::step_by
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     edi,0FFFFFFC0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     rax,[rbp+20h]
     1b: mov     [rbp-30h],rax
     1f: call    fn0
     24: nop     [rcx-20h]
     2b: mov     edi,0FFFFFFE0h
     30: mov     esi,20h
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

fn <std::ops::Range<u64> as std::iter::range::RangeIteratorImpl>::spec_next
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

fn <std::string::String as std::cmp::PartialEq>::eq
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp+18h]
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp-10h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp-18h]
     24: mov     [rbp-28h],rax
     28: call    fn0
     2d: nop     [rcx-1]
     34: mov     edi,0FFFFFFFFh
     39: mov     esi,1
     3e: call    ryo_h_Ret
     43: leave
     44: ret

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-40h],rax
     14: mov     [rbp-38h],rax
     18: mov     rax,[rbp+10h]
     1c: mov     rax,[rax+10h]
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-38h]
     28: mov     [rbp-30h],rax
     2c: mov     rax,[rbp-40h]
     30: mov     [rbp-28h],rax
     34: mov     rax,[rbp-30h]
     38: mov     [rbp-20h],rax
     3c: mov     rax,[rbp-28h]
     40: mov     [rbp-18h],rax
     44: mov     edi,0FFFFFFF0h
     49: mov     esi,0FFFFFFE0h
     4e: call    ryo_h_MovW128
     53: mov     rax,[rbp+18h]
     57: mov     [rbp-60h],rax
     5b: mov     edi,0FFFFFFA8h
     60: mov     esi,0FFFFFFF0h
     65: call    ryo_h_MovW128
     6a: call    fn0
     6f: nop     [rcx]
     76: xor     edi,edi
     78: xor     esi,esi
     7a: call    ryo_h_Ret
     7f: leave
     80: ret

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_all
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: nop     [rax+rax]
     10: mov     edi,0FFFFFFB8h
     15: mov     esi,18h
     1a: call    ryo_h_MovW128
     1f: mov     rax,[rbp-40h]
     23: mov     [rbp-50h],rax
     27: cmp     rax,0
     2b: sete    [rbp-31h]
     2f: test    byte ptr [rbp-31h],0FFh
     33: je      42h
     35: mov     qword ptr [rbp-8],0
     3d: jmp     165h
     42: mov     edi,0FFFFFFA8h
     47: mov     esi,18h
     4c: call    ryo_h_MovW128
     51: mov     rax,[rbp+10h]
     55: mov     [rbp-0C0h],rax
     5c: mov     edi,0FFFFFF48h
     61: mov     esi,0FFFFFFA8h
     66: call    ryo_h_MovW128
     6b: lea     rdi,[sym0]
     72: lea     rsi,[site1]
     79: mov     edx,0FFFFFF68h
     7e: call    ryo_h_CallExt
     83: test    rax,rax
     86: je      93h
     88: call    rax
     8a: nop     [rcx-48h]
     91: jmp     0A3h
     93: mov     rdi,rbp
     96: lea     rsi,[ro+4]
     9d: call    qword ptr [sym2]
     a3: mov     rax,[rbp-48h]
     a7: mov     [rbp-10h],rax
     ab: mov     edi,0FFFFFFF0h
     b0: xor     esi,esi
     b2: mov     edx,2
     b7: call    ryo_h_SwitchDenseW64
     bc: lea     rcx,[0CCh]
     c3: movsxd  rax,[rcx+rax*4]
     c7: add     rax,rcx
     ca: jmp     rax
     cc: .long   e7h
     d0: .long   f0h
     d4: .long   e0h
     d8: nop     [rax+rax]
     e0: call    ryo_h_Unreachable
     e5: ud2
     e7: cmp     qword ptr [rbp-40h],0
     ec: je      12Ch
     ee: jmp     10Dh
     f0: lea     rax,[rbp-40h]
     f4: mov     [rbp-50h],rax
     f8: mov     [rbp-0C0h],rax
     ff: call    fn3
    104: nop     [rcx-32h]
    10b: jmp     13Fh
    10d: mov     rax,[rbp-40h]
    111: mov     [rbp-50h],rax
    115: mov     rax,[rbp+20h]
    119: mov     [rbp-58h],rax
    11d: cmp     rax,[rbp-50h]
    121: jb      233h
    127: jmp     2A4h
    12c: mov     edi,0FFFFFFF8h
    131: lea     rsi,[k4]
    138: call    ryo_h_AddrAbs
    13d: jmp     165h
    13f: test    byte ptr [rbp-32h],0FFh
    143: je      147h
    145: jmp     1B0h
    147: mov     rax,[rbp-40h]
    14b: mov     [rbp-50h],rax
    14f: mov     [rbp-8],rax
    153: jmp     165h
    155: nop     [rax+rax]
    15e: xchg    ax,ax
    160: jmp     10h
    165: mov     edi,0FFFFFFF8h
    16a: mov     esi,8
    16f: call    ryo_h_Ret
    174: leave
    175: ret
    176: nop     [rax+rax]
    17f: nop
    180: mov     edi,0FFFFFFD0h
    185: call    ryo_h_Resume
    18a: ud2
    18c: lea     rax,[rbp-40h]
    190: mov     [rbp-98h],rax
    197: mov     [rbp-0C0h],rax
    19e: call    fn5
    1a3: nop     [rcx-98h]
    1aa: jmp     160h
    1ac: nop     [rax]
    1b0: mov     rax,[rbp-48h]
    1b4: mov     [rbp-20h],rax
    1b8: mov     edi,0FFFFFFE0h
    1bd: xor     esi,esi
    1bf: mov     edx,2
    1c4: call    ryo_h_SwitchDenseW64
    1c9: lea     rcx,[1DCh]
    1d0: movsxd  rax,[rcx+rax*4]
    1d4: add     rax,rcx
    1d7: jmp     rax
    1d9: int3
    1da: int3
    1db: int3
    1dc: .long   160h
    1e0: .long   18ch
    1e4: .long   e0h
    1e8: nop     [rax+rax]
    1f0: lea     rax,[rbp-40h]
    1f4: mov     [rbp-98h],rax
    1fb: mov     [rbp-0C0h],rax
    202: call    fn6
    207: nop     [rcx-98h]
    20e: jmp     180h
    213: nop     [rax+rax]
    21c: nop     [rax]
    220: mov     rax,[rbp-48h]
    224: mov     [rbp-28h],rax
    228: cmp     rax,1
    22c: je      1F0h
    22e: jmp     180h
    233: mov     rax,[rbp-50h]
    237: mov     [rbp-0C0h],rax
    23e: mov     rax,[rbp-58h]
    242: mov     [rbp-0B8h],rax
    249: mov     rax,[rbp-58h]
    24d: mov     [rbp-0B0h],rax
    254: mov     edi,0FFFFFF58h
    259: lea     rsi,[k7]
    260: call    ryo_h_AddrAbs
    265: lea     rdi,[sym8]
    26c: lea     rsi,[site9]
    273: mov     edx,0FFFFFF68h
    278: call    ryo_h_CallExt
    27d: test    rax,rax
    280: je      28Dh
    282: call    rax
    284: nop     [rcx-28h]
    28b: jmp     29Dh
    28d: mov     rdi,rbp
    290: lea     rsi,[ro+20]
    297: call    qword ptr [sym10]
    29d: call    ryo_h_Unreachable
    2a2: ud2
    2a4: mov     rax,[rbp-58h]
    2a8: sub     rax,[rbp-50h]
    2ac: mov     [rbp-60h],rax
    2b0: mov     rax,[rbp+18h]
    2b4: mov     [rbp-80h],rax
    2b8: mov     rax,[rbp+20h]
    2bc: mov     [rbp-78h],rax
    2c0: mov     rax,[rbp-80h]
    2c4: mov     [rbp-88h],rax
    2cb: imul    rcx,[rbp-50h],1
    2d0: add     rax,rcx
    2d3: mov     [rbp-90h],rax
    2da: mov     [rbp-70h],rax
    2de: mov     rax,[rbp-60h]
    2e2: mov     [rbp-68h],rax
    2e6: mov     rax,[rbp-70h]
    2ea: mov     [rbp+18h],rax
    2ee: mov     rax,[rbp-68h]
    2f2: mov     [rbp+20h],rax
    2f6: jmp     1B0h
    2fb: nop     [rax+rax]
    300: lea     rdi,[sym11]
    307: lea     rsi,[site12]
    30e: mov     edx,0FFFFFF68h
    313: call    ryo_h_CallExt
    318: test    rax,rax
    31b: je      328h
    31d: call    rax
    31f: nop     [rcx-90h]
    326: jmp     338h
    328: mov     rdi,rbp
    32b: lea     rsi,[ro+36]
    332: call    qword ptr [sym13]
    338: call    ryo_h_Unreachable
    33d: ud2
    33f: mov     rdi,rax
    342: mov     esi,0FFFFFFD0h
    347: call    ryo_h_Lpad
    34c: jmp     220h
    351: mov     rdi,rax
    354: mov     esi,0FFFFFFD0h
    359: call    ryo_h_Lpad
    35e: jmp     300h

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-28h],rax
     10: mov     [rbp-60h],rax
     14: call    fn0
     19: nop     [rcx-20h]
     20: mov     edi,0FFFFFFBCh
     25: mov     esi,0FFFFFFE0h
     2a: xor     edx,edx
     2c: xor     ecx,ecx
     2e: xor     r8d,r8d
     31: mov     r9d,1
     37: call    ryo_h_DiscrNicheW64
     3c: mov     edi,0FFFFFFF0h
     41: mov     esi,0FFFFFFBCh
     46: call    ryo_h_ZextW32W64
     4b: mov     edi,0FFFFFFF0h
     50: xor     esi,esi
     52: mov     edx,2
     57: call    ryo_h_SwitchDenseW64
     5c: lea     rcx,[6Ch]
     63: movsxd  rax,[rcx+rax*4]
     67: add     rax,rcx
     6a: jmp     rax
     6c: .long   bbh
     70: .long   78h
     74: .long   efh
     78: mov     edi,0FFFFFFD0h
     7d: mov     esi,0FFFFFFE0h
     82: call    ryo_h_MovW128
     87: mov     edi,0FFFFFFC0h
     8c: mov     esi,0FFFFFFD0h
     91: call    ryo_h_MovW128
     96: mov     rax,[rbp+10h]
     9a: mov     [rbp-60h],rax
     9e: mov     edi,0FFFFFFA8h
     a3: mov     esi,0FFFFFFC0h
     a8: call    ryo_h_MovW128
     ad: call    fn1
     b2: nop     [rcx-8]
     b9: jmp     0DEh
     bb: mov     rax,[rbp+10h]
     bf: mov     [rbp-60h],rax
     c3: mov     edi,0FFFFFFA8h
     c8: mov     esi,18h
     cd: call    ryo_h_MovW128
     d2: call    fn2
     d7: nop     [rcx-8]
     de: mov     edi,0FFFFFFF8h
     e3: mov     esi,8
     e8: call    ryo_h_Ret
     ed: leave
     ee: ret
     ef: call    ryo_h_Unreachable
     f4: ud2

fn <u32 as std::iter::Step>::forward_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     edi,0FFFFFFF8h
      d: mov     esi,18h
     12: call    ryo_h_TruncW64W32
     17: mov     byte ptr [rbp-9],1
     1b: test    byte ptr [rbp-9],0FFh
     1f: je      4Ah
     21: mov     eax,[rbp+10h]
     24: mov     [rbp-20h],eax
     27: mov     eax,[rbp-8]
     2a: mov     [rbp-1Ch],eax
     2d: mov     edi,0FFFFFFE8h
     32: lea     rsi,[k0]
     39: call    ryo_h_AddrAbs
     3e: call    fn1
     43: nop     [rcx-4]
     4a: mov     eax,[rbp+10h]
     4d: add     eax,[rbp-8]
     50: mov     [rbp-4],eax
     53: mov     edi,0FFFFFFFCh
     58: mov     esi,4
     5d: call    ryo_h_Ret
     62: leave
     63: ret

fn <u64 as hashbrown::Equivalent<u64>>::equivalent
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-30h],rax
     10: call    fn0
     15: nop     [rcx-20h]
     1c: mov     rax,[rbp+10h]
     20: mov     [rbp-30h],rax
     24: mov     rax,[rbp-20h]
     28: mov     [rbp-28h],rax
     2c: call    fn1
     31: nop     [rcx-1]
     38: mov     edi,0FFFFFFFFh
     3d: mov     esi,1
     42: call    ryo_h_Ret
     47: leave
     48: ret

fn <u64 as std::borrow::Borrow<u64>>::borrow
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

fn <u64 as std::iter::Step>::forward_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     byte ptr [rbp-11h],1
     14: test    byte ptr [rbp-11h],0FFh
     18: je      47h
     1a: mov     rax,[rbp+10h]
     1e: mov     [rbp-30h],rax
     22: mov     rax,[rbp-10h]
     26: mov     [rbp-28h],rax
     2a: mov     edi,0FFFFFFE0h
     2f: lea     rsi,[k0]
     36: call    ryo_h_AddrAbs
     3b: call    fn1
     40: nop     [rcx-8]
     47: mov     rax,[rbp+10h]
     4b: add     rax,[rbp-10h]
     4f: mov     [rbp-8],rax
     53: mov     edi,0FFFFFFF8h
     58: mov     esi,8
     5d: call    ryo_h_Ret
     62: leave
     63: ret

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: imul    rax,[rbp+20h],1
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

fn <u8 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
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
     e6: mov     qword ptr [rbp-0B0h],1
     f1: mov     qword ptr [rbp-0A8h],1
     fc: mov     rax,[rbp-58h]
    100: mov     [rbp-0A0h],rax
    107: mov     edi,0FFFFFF68h
    10c: lea     rsi,[k2]
    113: call    ryo_h_AddrAbs
    118: call    fn3
    11d: nop     [rcx-40h]
    124: imul    rax,[rbp-58h],1
    129: mov     [rbp-88h],rax
    130: mov     edi,0FFFFFF90h
    135: mov     esi,0FFFFFF98h
    13a: mov     edx,0FFFFFF78h
    13f: call    ryo_h_Memcpy
    144: mov     byte ptr [rbp-81h],1
    14b: test    byte ptr [rbp-81h],0FFh
    152: je      170h
    154: mov     qword ptr [rbp-88h],1
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

fn <usize as std::default::Default>::default
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-8],0
     10: mov     edi,0FFFFFFF8h
     15: mov     esi,8
     1a: call    ryo_h_Ret
     1f: leave
     20: ret

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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-18h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-10h]
     20: mov     [rbp-28h],rax
     24: call    fn0
     29: nop     [rcx-1]
     30: mov     edi,0FFFFFFFFh
     35: mov     esi,1
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: mov     edi,0FFFFFFE0h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFE0h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: xor     edx,edx
     1c: call    ryo_h_LoadW128
     21: mov     rax,[rbp-10h]
     25: mov     [rbp-20h],rax
     29: call    fn0
     2e: nop     [rcx-1]
     35: mov     edi,0FFFFFFFFh
     3a: mov     esi,1
     3f: call    ryo_h_Ret
     44: leave
     45: ret

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+20h]
     14: mov     [rbp-10h],rax
     18: lea     rax,[rbp+10h]
     1c: mov     [rbp-20h],rax
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-18h]
     28: mov     [rbp-38h],rax
     2c: mov     rax,[rbp-10h]
     30: mov     [rbp-30h],rax
     34: call    fn0
     39: nop     [rcx-8]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: nop     [rax+rax]
     5a: nop     [rax+rax]
     60: mov     edi,0FFFFFFD8h
     65: call    ryo_h_Resume
     6a: ud2
     6c: mov     rdi,rax
     6f: mov     esi,0FFFFFFD8h
     74: call    ryo_h_Lpad
     79: jmp     60h

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+20h]
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     rax,[rax]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-28h],rax
     2b: mov     rax,[rbp-10h]
     2f: mov     [rbp-20h],rax
     33: call    fn0
     38: nop     [rcx-8]
     3f: mov     edi,0FFFFFFF8h
     44: mov     esi,8
     49: call    ryo_h_Ret
     4e: leave
     4f: ret

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-10h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-8]
     20: mov     [rbp-28h],rax
     24: call    fn0
     29: nop     [rcx]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: nop     [rax+rax]
     40: mov     edi,0FFFFFFE8h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE8h
     54: call    ryo_h_Lpad
     59: jmp     40h

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-18h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-10h]
     20: mov     [rbp-28h],rax
     24: call    fn0
     29: nop     [rcx-1]
     30: mov     edi,0FFFFFFFFh
     35: mov     esi,1
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: mov     edi,0FFFFFFE0h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFE0h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: xor     edx,edx
     1c: call    ryo_h_LoadW128
     21: mov     rax,[rbp-10h]
     25: mov     [rbp-20h],rax
     29: call    fn0
     2e: nop     [rcx-1]
     35: mov     edi,0FFFFFFFFh
     3a: mov     esi,1
     3f: call    ryo_h_Ret
     44: leave
     45: ret

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-18h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-10h]
     20: mov     [rbp-28h],rax
     24: call    fn0
     29: nop     [rcx-1]
     30: mov     edi,0FFFFFFFFh
     35: mov     esi,1
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: mov     edi,0FFFFFFE0h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFE0h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,10h
     1a: xor     edx,edx
     1c: call    ryo_h_LoadW128
     21: mov     rax,[rbp-10h]
     25: mov     [rbp-20h],rax
     29: call    fn0
     2e: nop     [rcx-1]
     35: mov     edi,0FFFFFFFFh
     3a: mov     esi,1
     3f: call    ryo_h_Ret
     44: leave
     45: ret

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+20h]
     14: mov     [rbp-10h],rax
     18: lea     rax,[rbp+10h]
     1c: mov     [rbp-20h],rax
     20: mov     [rbp-40h],rax
     24: mov     rax,[rbp-18h]
     28: mov     [rbp-38h],rax
     2c: mov     rax,[rbp-10h]
     30: mov     [rbp-30h],rax
     34: call    fn0
     39: nop     [rcx-8]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: nop     [rax+rax]
     5a: nop     [rax+rax]
     60: mov     edi,0FFFFFFD8h
     65: call    ryo_h_Resume
     6a: ud2
     6c: mov     rdi,rax
     6f: mov     esi,0FFFFFFD8h
     74: call    ryo_h_Lpad
     79: jmp     60h

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+20h]
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     rax,[rax]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-28h],rax
     2b: mov     rax,[rbp-10h]
     2f: mov     [rbp-20h],rax
     33: call    fn0
     38: nop     [rcx-8]
     3f: mov     edi,0FFFFFFF8h
     44: mov     esi,8
     49: call    ryo_h_Ret
     4e: leave
     4f: ret

fn <{closure@std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}} as std::ops::FnOnce<(std::option::Option<&mut std::option::Option<std::cell::Cell<(u64, u64)>>>,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-18h],rax
     18: mov     [rbp-30h],rax
     1c: mov     rax,[rbp-10h]
     20: mov     [rbp-28h],rax
     24: call    fn0
     29: nop     [rcx-8]
     30: mov     edi,0FFFFFFF8h
     35: mov     esi,8
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: mov     edi,0FFFFFFE0h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFE0h
     64: call    ryo_h_Lpad
     69: jmp     50h

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

fn core::core_arch::simd::Simd::<i8, 16>::splat
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rdi,rbp
      b: lea     rsi,[ro+4]
     12: call    qword ptr [sym0]
     18: mov     edi,0FFFFFFF0h
     1d: mov     esi,10h
     22: call    ryo_h_Ret
     27: leave
     28: ret

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i
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

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
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

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
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

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-20h],rax
     17: mov     rax,[rbp+18h]
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx]
     2b: xor     edi,edi
     2d: xor     esi,esi
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-20h],rax
     17: mov     rax,[rbp+18h]
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx]
     2b: xor     edi,edi
     2d: xor     esi,esi
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn core::hash::impls::<impl std::hash::Hash for u64>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-8]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx]
     2f: xor     edi,edi
     31: xor     esi,esi
     33: call    ryo_h_Ret
     38: leave
     39: ret

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-10h],0
     10: mov     rax,[rbp+10h]
     14: mov     rcx,[rbp-10h]
     18: mov     [rax+30h],rcx
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+20h]
     24: mov     [rbp-8],rax
     28: mov     rcx,736F6D6570736575h
     32: xor     rax,rcx
     35: mov     [rbp-10h],rax
     39: mov     rax,[rbp+10h]
     3d: mov     rcx,[rbp-10h]
     41: mov     [rax],rcx
     44: mov     rax,[rbp+10h]
     48: mov     rax,[rax+28h]
     4c: mov     [rbp-8],rax
     50: mov     rcx,646F72616E646F6Dh
     5a: xor     rax,rcx
     5d: mov     [rbp-10h],rax
     61: mov     rax,[rbp+10h]
     65: mov     rcx,[rbp-10h]
     69: mov     [rax+10h],rcx
     6d: mov     rax,[rbp+10h]
     71: mov     rax,[rax+20h]
     75: mov     [rbp-8],rax
     79: mov     rcx,6C7967656E657261h
     83: xor     rax,rcx
     86: mov     [rbp-10h],rax
     8a: mov     rax,[rbp+10h]
     8e: mov     rcx,[rbp-10h]
     92: mov     [rax+8],rcx
     96: mov     rax,[rbp+10h]
     9a: mov     rax,[rax+28h]
     9e: mov     [rbp-8],rax
     a2: mov     rcx,7465646279746573h
     ac: xor     rax,rcx
     af: mov     [rbp-10h],rax
     b3: mov     rax,[rbp+10h]
     b7: mov     rcx,[rbp-10h]
     bb: mov     [rax+18h],rcx
     bf: mov     qword ptr [rbp-10h],0
     c7: mov     rax,[rbp+10h]
     cb: mov     rcx,[rbp-10h]
     cf: mov     [rax+40h],rcx
     d3: xor     edi,edi
     d5: xor     esi,esi
     d7: call    ryo_h_Ret
     dc: leave
     dd: ret

fn core::hash::sip::u8to64_le
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     qword ptr [rbp-38h],0
     13: mov     qword ptr [rbp-8],0
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-50h],rax
     23: add     rax,3
     27: mov     [rbp-48h],rax
     2b: cmp     rax,[rbp+28h]
     2f: jae     0A0h
     31: mov     dword ptr [rbp-40h],0
     38: mov     rax,[rbp+10h]
     3c: mov     [rbp-60h],rax
     40: mov     rax,[rbp+18h]
     44: mov     [rbp-58h],rax
     48: mov     rax,[rbp-60h]
     4c: mov     [rbp-50h],rax
     50: mov     rax,[rbp-38h]
     54: mov     [rbp-60h],rax
     58: mov     rax,[rbp+20h]
     5c: add     rax,[rbp-60h]
     60: mov     [rbp-58h],rax
     64: mov     rax,[rbp-50h]
     68: imul    rcx,[rbp-58h],1
     6d: add     rax,rcx
     70: mov     [rbp-48h],rax
     74: lea     rax,[rbp-40h]
     78: mov     [rbp-58h],rax
     7c: mov     [rbp-50h],rax
     80: mov     byte ptr [rbp-79h],1
     84: test    byte ptr [rbp-79h],0FFh
     88: je      1D5h
     8e: jmp     171h
     93: nop     [rax+rax]
     9c: nop     [rax]
     a0: mov     rax,[rbp-38h]
     a4: mov     [rbp-50h],rax
     a8: add     rax,1
     ac: mov     [rbp-48h],rax
     b0: cmp     rax,[rbp+28h]
     b4: jae     120h
     b6: mov     word ptr [rbp-3Ch],0
     bc: mov     rax,[rbp+10h]
     c0: mov     [rbp-70h],rax
     c4: mov     rax,[rbp+18h]
     c8: mov     [rbp-68h],rax
     cc: mov     rax,[rbp-70h]
     d0: mov     [rbp-60h],rax
     d4: mov     rax,[rbp-38h]
     d8: mov     [rbp-70h],rax
     dc: mov     rax,[rbp+20h]
     e0: add     rax,[rbp-70h]
     e4: mov     [rbp-68h],rax
     e8: mov     rax,[rbp-60h]
     ec: imul    rcx,[rbp-68h],1
     f1: add     rax,rcx
     f4: mov     [rbp-58h],rax
     f8: lea     rax,[rbp-3Ch]
     fc: mov     [rbp-68h],rax
    100: mov     [rbp-60h],rax
    104: mov     byte ptr [rbp-79h],1
    108: test    byte ptr [rbp-79h],0FFh
    10c: je      287h
    112: jmp     223h
    117: nop     [rax+rax]
    120: mov     rax,[rbp-38h]
    124: mov     [rbp-48h],rax
    128: cmp     rax,[rbp+28h]
    12c: jae     160h
    12e: mov     rax,[rbp-38h]
    132: mov     [rbp-60h],rax
    136: mov     rax,[rbp+20h]
    13a: add     rax,[rbp-60h]
    13e: mov     [rbp-58h],rax
    142: mov     byte ptr [rbp-79h],1
    146: test    byte ptr [rbp-79h],0FFh
    14a: je      342h
    150: jmp     307h
    155: nop     [rax+rax]
    15e: xchg    ax,ax
    160: mov     edi,0FFFFFFF8h
    165: mov     esi,8
    16a: call    ryo_h_Ret
    16f: leave
    170: ret
    171: mov     rax,[rbp-48h]
    175: mov     [rbp-60h],rax
    179: mov     rax,[rbp-58h]
    17d: mov     [rbp-68h],rax
    181: mov     rax,[rbp-60h]
    185: mov     [rbp-0C0h],rax
    18c: mov     rax,[rbp-68h]
    190: mov     [rbp-0B8h],rax
    197: mov     qword ptr [rbp-0B0h],1
    1a2: mov     qword ptr [rbp-0A8h],1
    1ad: mov     qword ptr [rbp-0A0h],4
    1b8: mov     edi,0FFFFFF68h
    1bd: lea     rsi,[k0]
    1c4: call    ryo_h_AddrAbs
    1c9: call    fn1
    1ce: nop     [rcx-21h]
    1d5: mov     qword ptr [rbp-80h],4
    1dd: imul    rax,[rbp-80h],1
    1e2: mov     [rbp-88h],rax
    1e9: mov     edi,0FFFFFFB0h
    1ee: mov     esi,0FFFFFFB8h
    1f3: mov     edx,0FFFFFF78h
    1f8: call    ryo_h_Memcpy
    1fd: mov     eax,[rbp-40h]
    200: mov     [rbp-0Ch],eax
    203: mov     edi,0FFFFFFF8h
    208: mov     esi,0FFFFFFF4h
    20d: call    ryo_h_ZextW32W64
    212: mov     rax,[rbp-38h]
    216: add     rax,4
    21a: mov     [rbp-38h],rax
    21e: jmp     0A0h
    223: mov     rax,[rbp-58h]
    227: mov     [rbp-70h],rax
    22b: mov     rax,[rbp-68h]
    22f: mov     [rbp-78h],rax
    233: mov     rax,[rbp-70h]
    237: mov     [rbp-0C0h],rax
    23e: mov     rax,[rbp-78h]
    242: mov     [rbp-0B8h],rax
    249: mov     qword ptr [rbp-0B0h],1
    254: mov     qword ptr [rbp-0A8h],1
    25f: mov     qword ptr [rbp-0A0h],2
    26a: mov     edi,0FFFFFF68h
    26f: lea     rsi,[k2]
    276: call    ryo_h_AddrAbs
    27b: call    fn3
    280: nop     [rcx-21h]
    287: mov     qword ptr [rbp-80h],2
    28f: imul    rax,[rbp-80h],1
    294: mov     [rbp-88h],rax
    29b: mov     edi,0FFFFFFA0h
    2a0: mov     esi,0FFFFFFA8h
    2a5: mov     edx,0FFFFFF78h
    2aa: call    ryo_h_Memcpy
    2af: movzx   eax,word ptr [rbp-3Ch]
    2b3: mov     [rbp-0Eh],ax
    2b7: mov     edi,0FFFFFFB0h
    2bc: mov     esi,0FFFFFFF2h
    2c1: call    ryo_h_ZextW16W64
    2c6: mov     rax,[rbp-38h]
    2ca: mov     [rbp-60h],rax
    2ce: imul    rax,8
    2d2: mov     [rbp-58h],rax
    2d6: mov     edi,0FFFFFFB8h
    2db: mov     esi,0FFFFFFB0h
    2e0: mov     edx,0FFFFFFA8h
    2e5: call    ryo_h_ShlW64
    2ea: mov     rax,[rbp-8]
    2ee: or      rax,[rbp-48h]
    2f2: mov     [rbp-8],rax
    2f6: mov     rax,[rbp-38h]
    2fa: add     rax,2
    2fe: mov     [rbp-38h],rax
    302: jmp     120h
    307: mov     rax,[rbp+18h]
    30b: mov     [rbp-60h],rax
    30f: mov     rax,[rbp-58h]
    313: mov     [rbp-0C0h],rax
    31a: mov     rax,[rbp-60h]
    31e: mov     [rbp-0B8h],rax
    325: mov     edi,0FFFFFF50h
    32a: lea     rsi,[k4]
    331: call    ryo_h_AddrAbs
    336: call    fn5
    33b: nop     [rcx-30h]
    342: mov     rax,[rbp+18h]
    346: mov     [rbp-60h],rax
    34a: mov     rax,[rbp-58h]
    34e: cmp     rax,[rbp-60h]
    352: setb    [rbp-3Bh]
    356: mov     rax,[rbp+10h]
    35a: imul    rcx,[rbp-58h],1
    35f: add     rax,rcx
    362: mov     [rbp-80h],rax
    366: mov     [rbp-30h],rax
    36a: movzx   eax,byte ptr [rax]
    36d: mov     [rbp-3Ah],al
    370: mov     edi,0FFFFFFB0h
    375: mov     esi,0FFFFFFC6h
    37a: call    ryo_h_ZextW8W64
    37f: mov     rax,[rbp-38h]
    383: mov     [rbp-60h],rax
    387: imul    rax,8
    38b: mov     [rbp-58h],rax
    38f: mov     edi,0FFFFFFB8h
    394: mov     esi,0FFFFFFB0h
    399: mov     edx,0FFFFFFA8h
    39e: call    ryo_h_ShlW64
    3a3: mov     rax,[rbp-8]
    3a7: or      rax,[rbp-48h]
    3ab: mov     [rbp-8],rax
    3af: mov     rax,[rbp-38h]
    3b3: add     rax,1
    3b7: mov     [rbp-38h],rax
    3bb: jmp     160h

fn core::io::error::repr::Repr::data::{closure#0}
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

fn core::io::error::repr::decode_repr::<&core::io::error::Custom, {closure@core::io::error::repr::Repr::data::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-21h],1
      f: mov     rax,[rbp+10h]
     13: mov     [rbp-18h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-78h],rax
     1f: and     rax,3
     23: mov     [rbp-80h],rax
     27: mov     edi,0FFFFFF80h
     2c: xor     esi,esi
     2e: mov     edx,4
     33: call    ryo_h_SwitchDenseW64
     38: lea     rcx,[48h]
     3f: movsxd  rax,[rcx+rax*4]
     43: add     rax,rcx
     46: jmp     rax
     48: .long   fdh
     4c: .long   c8h
     50: .long   160h
     54: .long   128h
     58: .long   5ch
     5c: mov     edi,0FFFFFF40h
     61: lea     rsi,[k0]
     68: call    ryo_h_AddrAbs
     6d: mov     qword ptr [rbp-0B8h],28h
     78: mov     edi,0FFFFFF50h
     7d: lea     rsi,[k1]
     84: call    ryo_h_AddrAbs
     89: lea     rdi,[sym2]
     90: lea     rsi,[site3]
     97: mov     edx,0FFFFFF58h
     9c: call    ryo_h_CallExt
     a1: test    rax,rax
     a4: je      0B1h
     a6: call    rax
     a8: nop     [rcx-20h]
     af: jmp     0C1h
     b1: mov     rdi,rbp
     b4: lea     rsi,[ro+4]
     bb: call    qword ptr [sym4]
     c1: call    ryo_h_Unreachable
     c6: ud2
     c8: mov     rax,[rbp+10h]
     cc: mov     [rbp-98h],rax
     d3: mov     rax,[rbp+10h]
     d7: mov     [rbp-0A0h],rax
     de: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     e9: imul    rcx,[rbp-0A8h],1
     f1: add     rax,rcx
     f4: mov     [rbp-68h],rax
     f8: jmp     29Ch
     fd: mov     rax,[rbp+10h]
    101: mov     [rbp-30h],rax
    105: mov     rax,[rbp+10h]
    109: mov     [rbp-90h],rax
    110: mov     rax,[rbp-30h]
    114: mov     [rbp-88h],rax
    11b: mov     [rbp-8],rax
    11f: mov     byte ptr [rbp-10h],2
    123: jmp     2EBh
    128: mov     rax,[rbp-78h]
    12c: shr     rax,20h
    130: mov     [rbp-90h],rax
    137: mov     edi,0FFFFFF7Ch
    13c: mov     esi,0FFFFFF70h
    141: call    ryo_h_TruncW64W32
    146: mov     eax,[rbp-84h]
    14c: mov     [rbp-0C0h],eax
    152: call    fn5
    157: nop     [rcx-86h]
    15e: jmp     197h
    160: mov     rax,[rbp-78h]
    164: mov     [rbp-98h],rax
    16b: sar     rax,20h
    16f: mov     [rbp-90h],rax
    176: mov     edi,0FFFFFF7Ch
    17b: mov     esi,0FFFFFF70h
    180: call    ryo_h_TruncW64W32
    185: mov     eax,[rbp-84h]
    18b: mov     [rbp-0Ch],eax
    18e: mov     byte ptr [rbp-10h],0
    192: jmp     2EBh
    197: mov     edi,0FFFFFF5Ch
    19c: mov     esi,0FFFFFF7Ah
    1a1: mov     edx,0FFh
    1a6: xor     ecx,ecx
    1a8: xor     r8d,r8d
    1ab: mov     r9d,1
    1b1: call    ryo_h_DiscrNicheW8
    1b6: mov     edi,0FFFFFF70h
    1bb: mov     esi,0FFFFFF5Ch
    1c0: call    ryo_h_ZextW32W64
    1c5: mov     edi,0FFFFFF70h
    1ca: xor     esi,esi
    1cc: mov     edx,2
    1d1: call    ryo_h_SwitchDenseW64
    1d6: lea     rcx,[1E8h]
    1dd: movsxd  rax,[rcx+rax*4]
    1e1: add     rax,rcx
    1e4: jmp     rax
    1e6: int3
    1e7: int3
    1e8: .long   267h
    1ec: .long   286h
    1f0: .long   260h
    1f4: nop     [rax+rax]
    1fd: nop     [rax]
    200: mov     rax,[rbp-90h]
    207: mov     [rbp-8],rax
    20b: mov     byte ptr [rbp-10h],3
    20f: nop
    210: mov     edi,0FFFFFFF0h
    215: mov     esi,10h
    21a: call    ryo_h_Ret
    21f: leave
    220: ret
    221: nop     [rax+rax]
    22a: nop     [rax+rax]
    230: mov     edi,0FFFFFF90h
    235: call    ryo_h_Resume
    23a: ud2
    23c: nop     [rax]
    240: jmp     230h
    242: nop     [rax+rax]
    24b: nop     [rax+rax]
    250: test    byte ptr [rbp-21h],0FFh
    254: je      230h
    256: jmp     240h
    258: nop     [rax+rax]
    260: call    ryo_h_Unreachable
    265: ud2
    267: mov     edi,0FFFFFF40h
    26c: lea     rsi,[k6]
    273: call    ryo_h_AddrAbs
    278: call    fn7
    27d: nop     [rcx-58h]
    284: jmp     260h
    286: movzx   eax,byte ptr [rbp-86h]
    28d: mov     [rbp-85h],al
    293: mov     [rbp-0Fh],al
    296: mov     byte ptr [rbp-10h],1
    29a: jmp     2EBh
    29c: mov     rax,[rbp-68h]
    2a0: mov     [rbp-90h],rax
    2a7: mov     rax,[rbp+10h]
    2ab: mov     [rbp-98h],rax
    2b2: mov     rax,[rbp-68h]
    2b6: mov     [rbp-0A0h],rax
    2bd: mov     rax,[rbp-68h]
    2c1: mov     [rbp-88h],rax
    2c8: mov     byte ptr [rbp-21h],0
    2cc: mov     [rbp-98h],rax
    2d3: mov     [rbp-0C0h],rax
    2da: call    fn8
    2df: nop     [rcx-90h]
    2e6: jmp     200h
    2eb: jmp     210h
    2f0: mov     rdi,rax
    2f3: mov     esi,0FFFFFF90h
    2f8: call    ryo_h_Lpad
    2fd: jmp     250h

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-21h],1
      f: mov     rax,[rbp+10h]
     13: mov     [rbp-18h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-78h],rax
     1f: and     rax,3
     23: mov     [rbp-80h],rax
     27: mov     edi,0FFFFFF80h
     2c: xor     esi,esi
     2e: mov     edx,4
     33: call    ryo_h_SwitchDenseW64
     38: lea     rcx,[48h]
     3f: movsxd  rax,[rcx+rax*4]
     43: add     rax,rcx
     46: jmp     rax
     48: .long   fdh
     4c: .long   c8h
     50: .long   160h
     54: .long   128h
     58: .long   5ch
     5c: mov     edi,0FFFFFF40h
     61: lea     rsi,[k0]
     68: call    ryo_h_AddrAbs
     6d: mov     qword ptr [rbp-0B8h],28h
     78: mov     edi,0FFFFFF50h
     7d: lea     rsi,[k1]
     84: call    ryo_h_AddrAbs
     89: lea     rdi,[sym2]
     90: lea     rsi,[site3]
     97: mov     edx,0FFFFFF58h
     9c: call    ryo_h_CallExt
     a1: test    rax,rax
     a4: je      0B1h
     a6: call    rax
     a8: nop     [rcx-20h]
     af: jmp     0C1h
     b1: mov     rdi,rbp
     b4: lea     rsi,[ro+4]
     bb: call    qword ptr [sym4]
     c1: call    ryo_h_Unreachable
     c6: ud2
     c8: mov     rax,[rbp+10h]
     cc: mov     [rbp-98h],rax
     d3: mov     rax,[rbp+10h]
     d7: mov     [rbp-0A0h],rax
     de: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     e9: imul    rcx,[rbp-0A8h],1
     f1: add     rax,rcx
     f4: mov     [rbp-68h],rax
     f8: jmp     29Ch
     fd: mov     rax,[rbp+10h]
    101: mov     [rbp-30h],rax
    105: mov     rax,[rbp+10h]
    109: mov     [rbp-90h],rax
    110: mov     rax,[rbp-30h]
    114: mov     [rbp-88h],rax
    11b: mov     [rbp-8],rax
    11f: mov     byte ptr [rbp-10h],2
    123: jmp     2EBh
    128: mov     rax,[rbp-78h]
    12c: shr     rax,20h
    130: mov     [rbp-90h],rax
    137: mov     edi,0FFFFFF7Ch
    13c: mov     esi,0FFFFFF70h
    141: call    ryo_h_TruncW64W32
    146: mov     eax,[rbp-84h]
    14c: mov     [rbp-0C0h],eax
    152: call    fn5
    157: nop     [rcx-86h]
    15e: jmp     197h
    160: mov     rax,[rbp-78h]
    164: mov     [rbp-98h],rax
    16b: sar     rax,20h
    16f: mov     [rbp-90h],rax
    176: mov     edi,0FFFFFF7Ch
    17b: mov     esi,0FFFFFF70h
    180: call    ryo_h_TruncW64W32
    185: mov     eax,[rbp-84h]
    18b: mov     [rbp-0Ch],eax
    18e: mov     byte ptr [rbp-10h],0
    192: jmp     2EBh
    197: mov     edi,0FFFFFF5Ch
    19c: mov     esi,0FFFFFF7Ah
    1a1: mov     edx,0FFh
    1a6: xor     ecx,ecx
    1a8: xor     r8d,r8d
    1ab: mov     r9d,1
    1b1: call    ryo_h_DiscrNicheW8
    1b6: mov     edi,0FFFFFF70h
    1bb: mov     esi,0FFFFFF5Ch
    1c0: call    ryo_h_ZextW32W64
    1c5: mov     edi,0FFFFFF70h
    1ca: xor     esi,esi
    1cc: mov     edx,2
    1d1: call    ryo_h_SwitchDenseW64
    1d6: lea     rcx,[1E8h]
    1dd: movsxd  rax,[rcx+rax*4]
    1e1: add     rax,rcx
    1e4: jmp     rax
    1e6: int3
    1e7: int3
    1e8: .long   267h
    1ec: .long   286h
    1f0: .long   260h
    1f4: nop     [rax+rax]
    1fd: nop     [rax]
    200: mov     rax,[rbp-90h]
    207: mov     [rbp-8],rax
    20b: mov     byte ptr [rbp-10h],3
    20f: nop
    210: mov     edi,0FFFFFFF0h
    215: mov     esi,10h
    21a: call    ryo_h_Ret
    21f: leave
    220: ret
    221: nop     [rax+rax]
    22a: nop     [rax+rax]
    230: mov     edi,0FFFFFF90h
    235: call    ryo_h_Resume
    23a: ud2
    23c: nop     [rax]
    240: jmp     230h
    242: nop     [rax+rax]
    24b: nop     [rax+rax]
    250: test    byte ptr [rbp-21h],0FFh
    254: je      230h
    256: jmp     240h
    258: nop     [rax+rax]
    260: call    ryo_h_Unreachable
    265: ud2
    267: mov     edi,0FFFFFF40h
    26c: lea     rsi,[k6]
    273: call    ryo_h_AddrAbs
    278: call    fn7
    27d: nop     [rcx-58h]
    284: jmp     260h
    286: movzx   eax,byte ptr [rbp-86h]
    28d: mov     [rbp-85h],al
    293: mov     [rbp-0Fh],al
    296: mov     byte ptr [rbp-10h],1
    29a: jmp     2EBh
    29c: mov     rax,[rbp-68h]
    2a0: mov     [rbp-90h],rax
    2a7: mov     rax,[rbp+10h]
    2ab: mov     [rbp-98h],rax
    2b2: mov     rax,[rbp-68h]
    2b6: mov     [rbp-0A0h],rax
    2bd: mov     rax,[rbp-68h]
    2c1: mov     [rbp-88h],rax
    2c8: mov     byte ptr [rbp-21h],0
    2cc: mov     [rbp-98h],rax
    2d3: mov     [rbp-0C0h],rax
    2da: call    fn8
    2df: nop     [rcx-90h]
    2e6: jmp     200h
    2eb: jmp     210h
    2f0: mov     rdi,rax
    2f3: mov     esi,0FFFFFF90h
    2f8: call    ryo_h_Lpad
    2fd: jmp     250h

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     qword ptr [rbp-28h],0
     1b: lea     rax,[rbp-30h]
     1f: mov     [rbp-50h],rax
     23: mov     [rbp-48h],rax
     27: mov     edi,0FFFFFFC0h
     2c: lea     rsi,[k0]
     33: call    ryo_h_AddrAbs
     38: mov     edi,0FFFFFF40h
     3d: mov     esi,0FFFFFFB8h
     42: call    ryo_h_MovW128
     47: mov     edi,0FFFFFF50h
     4c: mov     esi,18h
     51: call    ryo_h_MovW128
     56: lea     rdi,[sym1]
     5d: lea     rsi,[site2]
     64: mov     edx,0FFFFFF60h
     69: call    ryo_h_CallExt
     6e: test    rax,rax
     71: je      7Eh
     73: call    rax
     75: nop     [rcx-31h]
     7c: jmp     8Eh
     7e: mov     rdi,rbp
     81: lea     rsi,[ro+4]
     88: call    qword ptr [sym3]
     8e: mov     edi,0FFFFFFF0h
     93: mov     esi,0FFFFFFCFh
     98: call    ryo_h_ZextW8W64
     9d: mov     edi,0FFFFFFF0h
     a2: xor     esi,esi
     a4: mov     edx,2
     a9: call    ryo_h_SwitchDenseW64
     ae: lea     rcx,[0C0h]
     b5: movsxd  rax,[rcx+rax*4]
     b9: add     rax,rcx
     bc: jmp     rax
     be: int3
     bf: int3
     c0: .long   119h
     c4: .long   d3h
     c8: .long   cch
     cc: call    ryo_h_Unreachable
     d1: ud2
     d3: mov     edi,0FFFFFF64h
     d8: mov     esi,0FFFFFFD8h
     dd: xor     edx,edx
     df: xor     ecx,ecx
     e1: xor     r8d,r8d
     e4: mov     r9d,1
     ea: call    ryo_h_DiscrNicheW64
     ef: mov     edi,0FFFFFFC0h
     f4: mov     esi,0FFFFFF64h
     f9: call    ryo_h_ZextW32W64
     fe: cmp     qword ptr [rbp-40h],0
    103: sete    [rbp-33h]
    107: movzx   eax,byte ptr [rbp-33h]
    10b: xor     al,1
    10e: mov     [rbp-32h],al
    111: test    byte ptr [rbp-32h],0FFh
    115: je      151h
    117: jmp     144h
    119: mov     qword ptr [rbp-8],0
    121: lea     rax,[rbp-28h]
    125: mov     [rbp-0A0h],rax
    12c: mov     [rbp-0C0h],rax
    133: call    fn4
    138: nop     [rcx-0A0h]
    13f: jmp     233h
    144: mov     rax,[rbp-28h]
    148: mov     [rbp-8],rax
    14c: jmp     233h
    151: mov     edi,0FFFFFFA0h
    156: lea     rsi,[k5]
    15d: call    ryo_h_AddrAbs
    162: mov     qword ptr [rbp-58h],56h
    16a: mov     rax,[rbp-60h]
    16e: mov     [rbp-80h],rax
    172: mov     rax,[rbp-58h]
    176: mov     [rbp-78h],rax
    17a: mov     rax,[rbp-80h]
    17e: mov     [rbp-70h],rax
    182: mov     [rbp-68h],rax
    186: mov     edi,0FFFFFF68h
    18b: lea     rsi,[k6]
    192: call    ryo_h_AddrAbs
    197: mov     qword ptr [rbp-90h],56h
    1a2: mov     rax,[rbp-90h]
    1a9: mov     [rbp-88h],rax
    1b0: shl     rax,1
    1b4: mov     [rbp-80h],rax
    1b8: or      rax,1
    1bc: mov     [rbp-78h],rax
    1c0: mov     [rbp-70h],rax
    1c4: mov     rax,[rbp-68h]
    1c8: mov     [rbp-48h],rax
    1cc: mov     rax,[rbp-70h]
    1d0: mov     [rbp-40h],rax
    1d4: mov     edi,0FFFFFF40h
    1d9: mov     esi,0FFFFFFB8h
    1de: call    ryo_h_MovW128
    1e3: mov     edi,0FFFFFF50h
    1e8: lea     rsi,[k7]
    1ef: call    ryo_h_AddrAbs
    1f4: lea     rdi,[sym8]
    1fb: lea     rsi,[site9]
    202: mov     edx,0FFFFFF60h
    207: call    ryo_h_CallExt
    20c: test    rax,rax
    20f: je      21Ch
    211: call    rax
    213: nop     [rcx-18h]
    21a: jmp     22Ch
    21c: mov     rdi,rbp
    21f: lea     rsi,[ro+20]
    226: call    qword ptr [sym10]
    22c: call    ryo_h_Unreachable
    231: ud2
    233: mov     edi,0FFFFFFF8h
    238: mov     esi,8
    23d: call    ryo_h_Ret
    242: leave
    243: ret
    244: nop     [rax+rax]
    24d: nop     [rax]
    250: lea     rax,[rbp-30h]
    254: mov     [rbp-0A0h],rax
    25b: mov     [rbp-0C0h],rax
    262: call    fn11
    267: nop     [rcx-0A0h]
    26e: mov     edi,0FFFFFFE0h
    273: call    ryo_h_Resume
    278: ud2
    27a: nop     [rax+rax]
    280: lea     rdi,[sym12]
    287: lea     rsi,[site13]
    28e: mov     edx,0FFFFFF60h
    293: call    ryo_h_CallExt
    298: test    rax,rax
    29b: je      2A8h
    29d: call    rax
    29f: nop     [rcx-98h]
    2a6: jmp     2B8h
    2a8: mov     rdi,rbp
    2ab: lea     rsi,[ro+36]
    2b2: call    qword ptr [sym14]
    2b8: call    ryo_h_Unreachable
    2bd: ud2
    2bf: mov     rdi,rax
    2c2: mov     esi,0FFFFFFE0h
    2c7: call    ryo_h_Lpad
    2cc: jmp     250h
    2ce: mov     rdi,rax
    2d1: mov     esi,0FFFFFFE0h
    2d6: call    ryo_h_Lpad
    2db: jmp     280h

fn core::num::<impl u32>::unchecked_add::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     edi,0FFFFFFE4h
     10: mov     esi,0FFFFFFE8h
     15: mov     edx,10h
     1a: mov     ecx,14h
     1f: call    ryo_h_AddOvfUW32
     24: movzx   eax,byte ptr [rbp-18h]
     28: mov     [rbp-11h],al
     2b: test    byte ptr [rbp-11h],0FFh
     2f: je      109h
     35: mov     edi,0FFFFFFF0h
     3a: lea     rsi,[k0]
     41: call    ryo_h_AddrAbs
     46: mov     qword ptr [rbp-8],0B8h
     4e: mov     rax,[rbp-10h]
     52: mov     [rbp-48h],rax
     56: mov     rax,[rbp-8]
     5a: mov     [rbp-40h],rax
     5e: mov     rax,[rbp-48h]
     62: mov     [rbp-38h],rax
     66: mov     [rbp-30h],rax
     6a: mov     edi,0FFFFFFA0h
     6f: lea     rsi,[k1]
     76: call    ryo_h_AddrAbs
     7b: mov     qword ptr [rbp-58h],0B8h
     83: mov     rax,[rbp-58h]
     87: mov     [rbp-50h],rax
     8b: shl     rax,1
     8f: mov     [rbp-48h],rax
     93: or      rax,1
     97: mov     [rbp-40h],rax
     9b: mov     [rbp-38h],rax
     9f: mov     rax,[rbp-30h]
     a3: mov     [rbp-28h],rax
     a7: mov     rax,[rbp-38h]
     ab: mov     [rbp-20h],rax
     af: mov     edi,0FFFFFF70h
     b4: mov     esi,0FFFFFFD8h
     b9: call    ryo_h_MovW128
     be: mov     byte ptr [rbp-80h],0
     c2: mov     rax,[rbp+18h]
     c6: mov     [rbp-78h],rax
     ca: lea     rdi,[sym2]
     d1: lea     rsi,[site3]
     d8: mov     edx,0FFFFFF98h
     dd: call    ryo_h_CallExt
     e2: test    rax,rax
     e5: je      0F2h
     e7: call    rax
     e9: nop     [rcx-10h]
     f0: jmp     102h
     f2: mov     rdi,rbp
     f5: lea     rsi,[ro+4]
     fc: call    qword ptr [sym4]
    102: call    ryo_h_Unreachable
    107: ud2
    109: xor     edi,edi
    10b: xor     esi,esi
    10d: call    ryo_h_Ret
    112: leave
    113: ret

fn core::num::<impl u64>::unchecked_add::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     edi,0FFFFFFD8h
     10: mov     esi,0FFFFFFE0h
     15: mov     edx,10h
     1a: mov     ecx,18h
     1f: call    ryo_h_AddOvfUW64
     24: movzx   eax,byte ptr [rbp-20h]
     28: mov     [rbp-11h],al
     2b: test    byte ptr [rbp-11h],0FFh
     2f: je      109h
     35: mov     edi,0FFFFFFF0h
     3a: lea     rsi,[k0]
     41: call    ryo_h_AddrAbs
     46: mov     qword ptr [rbp-8],0B8h
     4e: mov     rax,[rbp-10h]
     52: mov     [rbp-48h],rax
     56: mov     rax,[rbp-8]
     5a: mov     [rbp-40h],rax
     5e: mov     rax,[rbp-48h]
     62: mov     [rbp-38h],rax
     66: mov     [rbp-30h],rax
     6a: mov     edi,0FFFFFFA0h
     6f: lea     rsi,[k1]
     76: call    ryo_h_AddrAbs
     7b: mov     qword ptr [rbp-58h],0B8h
     83: mov     rax,[rbp-58h]
     87: mov     [rbp-50h],rax
     8b: shl     rax,1
     8f: mov     [rbp-48h],rax
     93: or      rax,1
     97: mov     [rbp-40h],rax
     9b: mov     [rbp-38h],rax
     9f: mov     rax,[rbp-30h]
     a3: mov     [rbp-28h],rax
     a7: mov     rax,[rbp-38h]
     ab: mov     [rbp-20h],rax
     af: mov     edi,0FFFFFF70h
     b4: mov     esi,0FFFFFFD8h
     b9: call    ryo_h_MovW128
     be: mov     byte ptr [rbp-80h],0
     c2: mov     rax,[rbp+20h]
     c6: mov     [rbp-78h],rax
     ca: lea     rdi,[sym2]
     d1: lea     rsi,[site3]
     d8: mov     edx,0FFFFFF98h
     dd: call    ryo_h_CallExt
     e2: test    rax,rax
     e5: je      0F2h
     e7: call    rax
     e9: nop     [rcx-10h]
     f0: jmp     102h
     f2: mov     rdi,rbp
     f5: lea     rsi,[ro+4]
     fc: call    qword ptr [sym4]
    102: call    ryo_h_Unreachable
    107: ud2
    109: xor     edi,edi
    10b: xor     esi,esi
    10d: call    ryo_h_Ret
    112: leave
    113: ret

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

fn hashbrown::control::group::sse2::Group::convert_special_to_empty_and_full_to_deleted
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFA8h
     10: lea     rsi,[sym0]
     17: call    ryo_h_AddrSym
     1c: mov     rdi,rbp
     1f: lea     rsi,[ro+4]
     26: call    qword ptr [sym1]
     2c: mov     edi,0FFFFFFC0h
     31: mov     esi,10h
     36: call    ryo_h_MovW128
     3b: mov     edi,0FFFFFF80h
     40: mov     esi,0FFFFFFE0h
     45: call    ryo_h_MovW128
     4a: mov     edi,0FFFFFF90h
     4f: mov     esi,0FFFFFFC0h
     54: call    ryo_h_MovW128
     59: mov     edi,0FFFFFFA8h
     5e: lea     rsi,[sym2]
     65: call    ryo_h_AddrSym
     6a: mov     rdi,rbp
     6d: lea     rsi,[ro+20]
     74: call    qword ptr [sym3]
     7a: mov     byte ptr [rbp-80h],80h
     7e: mov     edi,0FFFFFFA8h
     83: lea     rsi,[sym4]
     8a: call    ryo_h_AddrSym
     8f: mov     rdi,rbp
     92: lea     rsi,[ro+36]
     99: call    qword ptr [sym5]
     9f: mov     edi,0FFFFFF80h
     a4: mov     esi,0FFFFFFD0h
     a9: call    ryo_h_MovW128
     ae: mov     edi,0FFFFFF90h
     b3: mov     esi,0FFFFFFB0h
     b8: call    ryo_h_MovW128
     bd: mov     edi,0FFFFFFA8h
     c2: lea     rsi,[sym6]
     c9: call    ryo_h_AddrSym
     ce: mov     rdi,rbp
     d1: lea     rsi,[ro+52]
     d8: call    qword ptr [sym7]
     de: mov     edi,0FFFFFFF0h
     e3: mov     esi,0FFFFFFC0h
     e8: call    ryo_h_MovW128
     ed: mov     edi,0FFFFFFF0h
     f2: mov     esi,10h
     f7: call    ryo_h_Ret
     fc: leave
     fd: ret

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+18h]
     13: mov     [rbp-30h],rax
     17: cmp     rax,0
     1b: sete    [rbp-21h]
     1f: test    byte ptr [rbp-21h],0FFh
     23: je      2Fh
     25: mov     qword ptr [rbp-8],0
     2d: jmp     70h
     2f: mov     rax,[rbp+10h]
     33: lea     rax,[rax+20h]
     37: mov     [rbp-38h],rax
     3b: mov     [rbp-0A0h],rax
     42: mov     rax,[rbp+18h]
     46: mov     [rbp-98h],rax
     4d: call    fn0
     52: nop     [rcx-30h]
     59: jmp     81h
     5b: nop     [rax+rax]
     60: call    ryo_h_Unreachable
     65: ud2
     67: nop     [rax+rax]
     70: mov     edi,0FFFFFFF8h
     75: mov     esi,8
     7a: call    ryo_h_Ret
     7f: leave
     80: ret
     81: mov     rax,[rbp+10h]
     85: mov     [rbp-40h],rax
     89: mov     rax,[rbp+18h]
     8d: mov     [rbp-48h],rax
     91: mov     rax,[rbp-40h]
     95: mov     [rbp-0A0h],rax
     9c: mov     rax,[rbp-30h]
     a0: mov     [rbp-98h],rax
     a7: mov     rax,[rbp-48h]
     ab: mov     [rbp-90h],rax
     b2: call    fn1
     b7: nop     [rcx-50h]
     be: mov     edi,0FFFFFF84h
     c3: mov     esi,0FFFFFFB0h
     c8: xor     edx,edx
     ca: xor     ecx,ecx
     cc: xor     r8d,r8d
     cf: mov     r9d,1
     d5: call    ryo_h_DiscrNicheW64
     da: mov     edi,0FFFFFFA8h
     df: mov     esi,0FFFFFF84h
     e4: call    ryo_h_ZextW32W64
     e9: mov     edi,0FFFFFFA8h
     ee: xor     esi,esi
     f0: mov     edx,2
     f5: call    ryo_h_SwitchDenseW64
     fa: lea     rcx,[10Ch]
    101: movsxd  rax,[rcx+rax*4]
    105: add     rax,rcx
    108: jmp     rax
    10a: int3
    10b: int3
    10c: .long   118h
    110: .long   125h
    114: .long   60h
    118: mov     qword ptr [rbp-8],0
    120: jmp     70h
    125: mov     rax,[rbp-50h]
    129: mov     [rbp-78h],rax
    12d: mov     byte ptr [rbp-79h],0
    131: test    byte ptr [rbp-79h],0FFh
    135: je      16Bh
    137: jmp     161h
    139: nop     [rax]
    140: mov     rax,[rbp-68h]
    144: mov     [rbp-60h],rax
    148: mov     [rbp-38h],rax
    14c: mov     [rbp-18h],rax
    150: lea     rax,[rax+8]
    154: mov     [rbp-40h],rax
    158: mov     [rbp-8],rax
    15c: jmp     70h
    161: mov     qword ptr [rbp-68h],8
    169: jmp     140h
    16b: mov     rax,[rbp-78h]
    16f: mov     [rbp-70h],rax
    173: mov     byte ptr [rbp-79h],0
    177: test    byte ptr [rbp-79h],0FFh
    17b: je      18Ch
    17d: jmp     182h
    17f: nop
    180: jmp     140h
    182: mov     rax,[rbp-70h]
    186: mov     [rbp-68h],rax
    18a: jmp     180h
    18c: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    194: mov     rax,[rbp-70h]
    198: imul    rcx,[rbp-80h],10h
    19d: add     rax,rcx
    1a0: mov     [rbp-68h],rax
    1a4: jmp     180h

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-0A0h],rax
     19: mov     [rbp-70h],rax
     1d: mov     byte ptr [rbp-0B1h],0
     24: test    byte ptr [rbp-0B1h],0FFh
     2b: je      90h
     2d: jmp     83h
     2f: nop
     30: mov     rax,[rbp+10h]
     34: mov     rax,[rax+18h]
     38: mov     [rbp-90h],rax
     3f: mov     edi,0FFFFFFA0h
     44: mov     esi,0FFFFFF78h
     49: mov     edx,20h
     4e: call    ryo_h_Copy
     53: mov     rax,[rbp-90h]
     5a: mov     [rbp-40h],rax
     5e: mov     edi,0FFFFFFD8h
     63: mov     esi,0FFFFFFA0h
     68: mov     edx,28h
     6d: call    ryo_h_Copy
     72: mov     edi,0FFFFFFD8h
     77: mov     esi,28h
     7c: call    ryo_h_Ret
     81: leave
     82: ret
     83: mov     qword ptr [rbp-0A8h],1
     8e: jmp     9Eh
     90: mov     rax,[rbp-0A0h]
     97: mov     [rbp-0A8h],rax
     9e: mov     rax,[rbp-0A8h]
     a5: mov     [rbp-78h],rax
     a9: mov     [rbp-68h],rax
     ad: mov     rax,[rbp+10h]
     b1: mov     rax,[rax]
     b4: mov     [rbp-98h],rax
     bb: mov     [rbp-90h],rax
     c2: mov     rax,[rbp+10h]
     c6: mov     rax,[rax+8]
     ca: mov     [rbp-0B0h],rax
     d1: add     rax,1
     d5: mov     [rbp-98h],rax
     dc: mov     rax,[rbp-90h]
     e3: mov     [rbp-0C8h],rax
     ea: mov     rax,[rbp-68h]
     ee: mov     [rbp-0D0h],rax
     f5: mov     rax,[rbp-98h]
     fc: mov     [rbp-0C0h],rax
    103: call    fn0
    108: nop     [rcx-88h]
    10f: jmp     30h

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0F0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-0A0h],rax
     19: mov     [rbp-70h],rax
     1d: mov     byte ptr [rbp-0C9h],0
     24: test    byte ptr [rbp-0C9h],0FFh
     2b: je      154h
     31: jmp     147h
     36: nop     [rax+rax]
     3f: nop
     40: mov     rax,[rbp-68h]
     44: mov     [rbp-98h],rax
     4b: cmp     rax,0
     4f: je      1D8h
     55: jmp     1E8h
     5a: nop     [rax+rax]
     60: call    ryo_h_Unreachable
     65: ud2
     67: mov     rax,[rbp-90h]
     6e: mov     [rbp-98h],rax
     75: mov     byte ptr [rbp-0C9h],0
     7c: test    byte ptr [rbp-0C9h],0FFh
     83: je      309h
     89: jmp     2F9h
     8e: xchg    ax,ax
     90: jmp     0DCh
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-0A9h],0FFh
     a7: je      0ABh
     a9: jmp     0D7h
     ab: mov     rax,[rbp+10h]
     af: mov     [rbp-0B8h],rax
     b6: mov     [rbp-0F0h],rax
     bd: mov     rax,[rbp-98h]
     c4: mov     [rbp-0E8h],rax
     cb: call    fn0
     d0: nop     [rcx-48h]
     d7: jmp     40h
     dc: xor     edi,edi
     de: xor     esi,esi
     e0: call    ryo_h_Ret
     e5: leave
     e6: ret
     e7: nop     [rax+rax]
     f0: mov     edi,0FFFFFFA0h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: nop     [rax]
    100: mov     rax,[rbp+10h]
    104: mov     rax,[rax+18h]
    108: mov     [rbp-90h],rax
    10f: mov     edi,0FFFFFFD8h
    114: mov     esi,0FFFFFF78h
    119: mov     edx,20h
    11e: call    ryo_h_Copy
    123: mov     rax,[rbp-90h]
    12a: mov     [rbp-8],rax
    12e: mov     edi,0FFFFFF78h
    133: mov     esi,0FFFFFFD8h
    138: mov     edx,28h
    13d: call    ryo_h_Copy
    142: jmp     40h
    147: mov     qword ptr [rbp-0A8h],1
    152: jmp     162h
    154: mov     rax,[rbp-0A0h]
    15b: mov     [rbp-0A8h],rax
    162: mov     rax,[rbp-0A8h]
    169: mov     [rbp-78h],rax
    16d: mov     [rbp-68h],rax
    171: mov     rax,[rbp+10h]
    175: mov     rax,[rax]
    178: mov     [rbp-98h],rax
    17f: mov     [rbp-90h],rax
    186: mov     rax,[rbp+10h]
    18a: mov     rax,[rax+8]
    18e: mov     [rbp-0B0h],rax
    195: add     rax,1
    199: mov     [rbp-98h],rax
    1a0: mov     rax,[rbp-90h]
    1a7: mov     [rbp-0E8h],rax
    1ae: mov     rax,[rbp-68h]
    1b2: mov     [rbp-0F0h],rax
    1b9: mov     rax,[rbp-98h]
    1c0: mov     [rbp-0E0h],rax
    1c7: call    fn1
    1cc: nop     [rcx-88h]
    1d3: jmp     100h
    1d8: mov     qword ptr [rbp-90h],0
    1e3: jmp     90h
    1e8: lea     rax,[rbp-88h]
    1ef: mov     [rbp-98h],rax
    1f6: mov     [rbp-0F0h],rax
    1fd: call    fn2
    202: nop     [rcx-90h]
    209: mov     rax,[rbp-68h]
    20d: sub     rax,1
    211: mov     [rbp-68h],rax
    215: mov     edi,0FFFFFF34h
    21a: mov     esi,0FFFFFF70h
    21f: xor     edx,edx
    221: xor     ecx,ecx
    223: xor     r8d,r8d
    226: mov     r9d,1
    22c: call    ryo_h_DiscrNicheW64
    231: mov     edi,0FFFFFFC0h
    236: mov     esi,0FFFFFF34h
    23b: call    ryo_h_ZextW32W64
    240: mov     edi,0FFFFFFC0h
    245: xor     esi,esi
    247: mov     edx,2
    24c: call    ryo_h_SwitchDenseW64
    251: lea     rcx,[264h]
    258: movsxd  rax,[rcx+rax*4]
    25c: add     rax,rcx
    25f: jmp     rax
    261: int3
    262: int3
    263: int3
    264: .long   90h
    268: .long   67h
    26c: .long   60h
    270: mov     rax,[rbp-0A0h]
    277: mov     [rbp-0B0h],rax
    27e: mov     [rbp-0A0h],rax
    285: mov     rax,[rbp-0B0h]
    28c: lea     rax,[rax+8]
    290: mov     [rbp-0A8h],rax
    297: lea     rax,[rbp+18h]
    29b: mov     [rbp-0B8h],rax
    2a2: mov     rax,[rbp-0A0h]
    2a9: mov     [rbp-0C8h],rax
    2b0: mov     rax,[rbp-0A8h]
    2b7: mov     [rbp-0C0h],rax
    2be: mov     rax,[rbp-0B8h]
    2c5: mov     [rbp-0F0h],rax
    2cc: mov     rax,[rbp-0C8h]
    2d3: mov     [rbp-0E8h],rax
    2da: mov     rax,[rbp-0C0h]
    2e1: mov     [rbp-0E0h],rax
    2e8: call    fn3
    2ed: nop     [rcx-0A9h]
    2f4: jmp     0A0h
    2f9: mov     qword ptr [rbp-0A0h],8
    304: jmp     270h
    309: mov     rax,[rbp-98h]
    310: mov     [rbp-0B8h],rax
    317: mov     [rbp-0A8h],rax
    31e: mov     byte ptr [rbp-0C9h],0
    325: test    byte ptr [rbp-0C9h],0FFh
    32c: je      345h
    32e: jmp     335h
    330: jmp     270h
    335: mov     rax,[rbp-0A8h]
    33c: mov     [rbp-0A0h],rax
    343: jmp     330h
    345: mov     qword ptr [rbp-0D0h],0FFFFFFFFFFFFFFFFh
    350: mov     rax,[rbp-0A8h]
    357: imul    rcx,[rbp-0D0h],10h
    35f: add     rax,rcx
    362: mov     [rbp-0A0h],rax
    369: jmp     330h
    36b: mov     rdi,rax
    36e: mov     esi,0FFFFFFA0h
    373: call    ryo_h_Lpad
    378: jmp     0F0h

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-18h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-28h],rax
     2b: call    fn0
     30: nop     [rcx-1]
     37: mov     edi,0FFFFFFFFh
     3c: mov     esi,1
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-18h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-28h],rax
     2b: call    fn0
     30: nop     [rcx-8]
     37: mov     edi,0FFFFFFF8h
     3c: mov     esi,8
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-18h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-18h]
     27: mov     [rbp-28h],rax
     2b: call    fn0
     30: nop     [rcx-8]
     37: mov     edi,0FFFFFFF8h
     3c: mov     esi,8
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn hashbrown::raw::FullBucketsIndices::next_impl
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: movzx   eax,word ptr [rax+18h]
     18: mov     [rbp-0ACh],ax
     1f: mov     [rbp-92h],ax
     26: mov     edi,0FFFFFF50h
     2b: mov     esi,0FFFFFF6Eh
     30: xor     edx,edx
     32: xor     ecx,ecx
     34: xor     r8d,r8d
     37: mov     r9d,1
     3d: call    ryo_h_DiscrNicheW16
     42: mov     edi,0FFFFFF60h
     47: mov     esi,0FFFFFF50h
     4c: call    ryo_h_ZextW32W64
     51: mov     edi,0FFFFFF60h
     56: xor     esi,esi
     58: mov     edx,2
     5d: call    ryo_h_SwitchDenseW64
     62: lea     rcx,[74h]
     69: movsxd  rax,[rcx+rax*4]
     6d: add     rax,rcx
     70: jmp     rax
     72: int3
     73: int3
     74: .long   bch
     78: .long   87h
     7c: .long   80h
     80: call    ryo_h_Unreachable
     85: ud2
     87: movzx   eax,word ptr [rbp-92h]
     8e: mov     [rbp-94h],ax
     95: mov     [rbp-0AAh],ax
     9c: mov     edi,0FFFFFF50h
     a1: mov     esi,0FFFFFF56h
     a6: call    ryo_h_CttzW16
     ab: mov     eax,[rbp-0B0h]
     b1: mov     [rbp-98h],eax
     b7: jmp     17Ch
     bc: mov     edi,0FFFFFF70h
     c1: lea     rsi,[k0]
     c8: mov     edx,10h
     cd: call    ryo_h_Const
     d2: mov     qword ptr [rbp-88h],0
     dd: cmp     qword ptr [rbp-88h],0
     e5: sete    [rbp-89h]
     ec: mov     rax,[rbp+10h]
     f0: mov     rax,[rax]
     f3: mov     [rbp-90h],rax
     fa: mov     [rbp-88h],rax
    101: mov     qword ptr [rbp-0B8h],10h
    10c: imul    rcx,[rbp-0B8h],1
    114: add     rax,rcx
    117: mov     [rbp-80h],rax
    11b: mov     [rbp-78h],rax
    11f: mov     rax,[rbp+10h]
    123: mov     rcx,[rbp-78h]
    127: mov     [rax],rcx
    12a: mov     rax,[rbp+10h]
    12e: mov     rax,[rax]
    131: mov     [rbp-28h],rax
    135: mov     [rbp-88h],rax
    13c: mov     rax,[rbp-28h]
    140: mov     [rbp-80h],rax
    144: mov     rax,[rbp-28h]
    148: mov     [rbp-88h],rax
    14f: mov     [rbp-0D0h],rax
    156: mov     edi,0FFFFFF48h
    15b: lea     rsi,[sym1]
    162: call    ryo_h_AddrSym
    167: mov     rdi,rbp
    16a: lea     rsi,[ro+4]
    171: call    qword ptr [sym2]
    177: jmp     244h
    17c: mov     edi,0FFFFFF58h
    181: mov     esi,0FFFFFF68h
    186: call    ryo_h_ZextW32W64
    18b: mov     rax,[rbp-0A8h]
    192: mov     [rbp-88h],rax
    199: mov     qword ptr [rbp-90h],1
    1a4: mov     [rbp-40h],rax
    1a8: mov     rax,[rbp+10h]
    1ac: movzx   eax,word ptr [rax+18h]
    1b0: mov     [rbp-88h],ax
    1b7: sub     eax,1
    1ba: mov     [rbp-86h],ax
    1c1: movzx   eax,word ptr [rbp-88h]
    1c8: and     ax,[rbp-86h]
    1cf: mov     [rbp-84h],ax
    1d6: movzx   eax,word ptr [rbp-84h]
    1dd: mov     [rbp-82h],ax
    1e4: mov     rax,[rbp+10h]
    1e8: movzx   ecx,word ptr [rbp-82h]
    1ef: mov     [rax+18h],cx
    1f3: mov     rax,[rbp-40h]
    1f7: mov     [rbp-78h],rax
    1fb: mov     qword ptr [rbp-80h],1
    203: mov     [rbp-88h],rax
    20a: mov     rax,[rbp+10h]
    20e: mov     rax,[rax+8]
    212: mov     [rbp-98h],rax
    219: add     rax,[rbp-88h]
    220: mov     [rbp-90h],rax
    227: mov     [rbp-8],rax
    22b: mov     qword ptr [rbp-10h],1
    233: mov     edi,0FFFFFFF0h
    238: mov     esi,10h
    23d: call    ryo_h_Ret
    242: leave
    243: ret
    244: mov     edi,0FFFFFF30h
    249: mov     esi,0FFFFFF90h
    24e: call    ryo_h_MovW128
    253: mov     edi,0FFFFFF48h
    258: lea     rsi,[sym3]
    25f: call    ryo_h_AddrSym
    264: mov     rdi,rbp
    267: lea     rsi,[ro+20]
    26e: call    qword ptr [sym4]
    274: mov     edi,0FFFFFF88h
    279: mov     esi,0FFFFFF84h
    27e: call    ryo_h_TruncW32W16
    283: mov     edi,0FFFFFF8Ah
    288: mov     esi,0FFFFFF88h
    28d: call    ryo_h_NotW16
    292: movzx   eax,word ptr [rbp-76h]
    296: mov     [rbp-74h],ax
    29a: mov     [rbp-72h],ax
    29e: mov     rax,[rbp+10h]
    2a2: movzx   ecx,word ptr [rbp-72h]
    2a6: mov     [rax+18h],cx
    2aa: mov     rax,[rbp+10h]
    2ae: mov     rax,[rax+8]
    2b2: mov     [rbp-0B8h],rax
    2b9: add     rax,10h
    2bd: mov     [rbp-0C0h],rax
    2c4: mov     rax,[rbp+10h]
    2c8: mov     rcx,[rbp-0C0h]
    2cf: mov     [rax+8],rcx
    2d3: jmp     10h

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: imul    rcx,[rbp+20h],1
     14: add     rax,rcx
     17: mov     [rbp-98h],rax
     1e: mov     rax,[rbp+18h]
     22: mov     [rbp-0A0h],rax
     29: mov     rax,[rbp+18h]
     2d: mov     [rbp-0A8h],rax
     34: mov     [rbp-0C0h],rax
     3b: mov     edi,0FFFFFF50h
     40: lea     rsi,[sym0]
     47: call    ryo_h_AddrSym
     4c: mov     rdi,rbp
     4f: lea     rsi,[ro+4]
     56: call    qword ptr [sym1]
     5c: mov     edi,0FFFFFF40h
     61: mov     esi,0FFFFFF70h
     66: call    ryo_h_MovW128
     6b: mov     edi,0FFFFFF50h
     70: lea     rsi,[sym2]
     77: call    ryo_h_AddrSym
     7c: mov     rdi,rbp
     7f: lea     rsi,[ro+20]
     86: call    qword ptr [sym3]
     8c: mov     edi,0FFFFFF64h
     91: mov     esi,0FFFFFF60h
     96: call    ryo_h_TruncW32W16
     9b: mov     edi,0FFFFFF66h
     a0: mov     esi,0FFFFFF64h
     a5: call    ryo_h_NotW16
     aa: movzx   eax,word ptr [rbp-9Ah]
     b1: mov     [rbp-4Ch],ax
     b5: mov     qword ptr [rbp-0B0h],10h
     c0: mov     rax,[rbp+18h]
     c4: imul    rcx,[rbp-0B0h],1
     cc: add     rax,rcx
     cf: mov     [rbp-60h],rax
     d3: movzx   eax,word ptr [rbp-4Ch]
     d7: mov     [rbp-9Ah],ax
     de: mov     [rbp-8],ax
     e2: mov     rax,[rbp+10h]
     e6: mov     [rbp-20h],rax
     ea: mov     rax,[rbp-60h]
     ee: mov     [rbp-18h],rax
     f2: mov     rax,[rbp-98h]
     f9: mov     [rbp-10h],rax
     fd: mov     edi,0FFFFFFE0h
    102: mov     esi,20h
    107: call    ryo_h_Ret
    10c: leave
    10d: ret

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: movzx   eax,word ptr [rax+18h]
     18: mov     [rbp-0ACh],ax
     1f: mov     [rbp-92h],ax
     26: mov     edi,0FFFFFF44h
     2b: mov     esi,0FFFFFF6Eh
     30: xor     edx,edx
     32: xor     ecx,ecx
     34: xor     r8d,r8d
     37: mov     r9d,1
     3d: call    ryo_h_DiscrNicheW16
     42: mov     edi,0FFFFFF60h
     47: mov     esi,0FFFFFF44h
     4c: call    ryo_h_ZextW32W64
     51: mov     edi,0FFFFFF60h
     56: xor     esi,esi
     58: mov     edx,2
     5d: call    ryo_h_SwitchDenseW64
     62: lea     rcx,[74h]
     69: movsxd  rax,[rcx+rax*4]
     6d: add     rax,rcx
     70: jmp     rax
     72: int3
     73: int3
     74: .long   15ah
     78: .long   128h
     7c: .long   121h
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax+8]
     88: mov     [rbp-80h],rax
     8c: mov     rax,[rbp+10h]
     90: mov     rax,[rax+10h]
     94: mov     [rbp-88h],rax
     9b: mov     rax,[rbp-80h]
     9f: cmp     rax,[rbp-88h]
     a6: jb      0C0h
     a8: mov     qword ptr [rbp-8],0
     b0: jmp     110h
     b2: nop     [rax+rax]
     bb: nop     [rax+rax]
     c0: mov     rax,[rbp+10h]
     c4: mov     rax,[rax+8]
     c8: mov     [rbp-28h],rax
     cc: mov     [rbp-80h],rax
     d0: mov     rax,[rbp-28h]
     d4: mov     [rbp-88h],rax
     db: mov     [rbp-0D0h],rax
     e2: mov     edi,0FFFFFF40h
     e7: lea     rsi,[sym0]
     ee: call    ryo_h_AddrSym
     f3: mov     rdi,rbp
     f6: lea     rsi,[ro+4]
     fd: call    qword ptr [sym1]
    103: jmp     31Bh
    108: nop     [rax+rax]
    110: mov     edi,0FFFFFFF8h
    115: mov     esi,8
    11a: call    ryo_h_Ret
    11f: leave
    120: ret
    121: call    ryo_h_Unreachable
    126: ud2
    128: movzx   eax,word ptr [rbp-92h]
    12f: mov     [rbp-94h],ax
    136: mov     [rbp-0AAh],ax
    13d: mov     edi,0FFFFFF44h
    142: mov     esi,0FFFFFF56h
    147: call    ryo_h_CttzW16
    14c: mov     eax,[rbp-0BCh]
    152: mov     [rbp-98h],eax
    158: jmp     1A3h
    15a: mov     edi,0FFFFFF70h
    15f: lea     rsi,[k2]
    166: mov     edx,10h
    16b: call    ryo_h_Const
    170: mov     qword ptr [rbp-88h],0
    17b: cmp     qword ptr [rbp-88h],0
    183: sete    [rbp-89h]
    18a: mov     byte ptr [rbp-0B9h],0
    191: test    byte ptr [rbp-0B9h],0FFh
    198: je      0C0h
    19e: jmp     80h
    1a3: mov     edi,0FFFFFF58h
    1a8: mov     esi,0FFFFFF68h
    1ad: call    ryo_h_ZextW32W64
    1b2: mov     rax,[rbp-0A8h]
    1b9: mov     [rbp-88h],rax
    1c0: mov     qword ptr [rbp-90h],1
    1cb: mov     [rbp-48h],rax
    1cf: mov     rax,[rbp+10h]
    1d3: movzx   eax,word ptr [rax+18h]
    1d7: mov     [rbp-88h],ax
    1de: sub     eax,1
    1e1: mov     [rbp-86h],ax
    1e8: movzx   eax,word ptr [rbp-88h]
    1ef: and     ax,[rbp-86h]
    1f6: mov     [rbp-84h],ax
    1fd: movzx   eax,word ptr [rbp-84h]
    204: mov     [rbp-82h],ax
    20b: mov     rax,[rbp+10h]
    20f: movzx   ecx,word ptr [rbp-82h]
    216: mov     [rax+18h],cx
    21a: mov     rax,[rbp-48h]
    21e: mov     [rbp-78h],rax
    222: mov     qword ptr [rbp-80h],1
    22a: mov     [rbp-88h],rax
    231: mov     byte ptr [rbp-0B9h],0
    238: test    byte ptr [rbp-0B9h],0FFh
    23f: je      274h
    241: mov     rax,[rbp+10h]
    245: mov     rax,[rax]
    248: mov     [rbp-0B8h],rax
    24f: mov     [rbp-0B0h],rax
    256: mov     [rbp-0A8h],rax
    25d: add     rax,[rbp-88h]
    264: mov     [rbp-0A0h],rax
    26b: mov     [rbp-98h],rax
    272: jmp     2A0h
    274: mov     rax,[rbp+10h]
    278: mov     rax,[rax]
    27b: mov     [rbp-0A8h],rax
    282: mov     [rbp-0A0h],rax
    289: mov     byte ptr [rbp-0B9h],0
    290: test    byte ptr [rbp-0B9h],0FFh
    297: je      2D2h
    299: jmp     2C2h
    29b: nop     [rax+rax]
    2a0: mov     rax,[rbp-98h]
    2a7: mov     [rbp-0A0h],rax
    2ae: mov     [rbp-90h],rax
    2b5: mov     [rbp-8],rax
    2b9: jmp     110h
    2be: xchg    ax,ax
    2c0: jmp     2A0h
    2c2: mov     rax,[rbp-0A0h]
    2c9: mov     [rbp-98h],rax
    2d0: jmp     2C0h
    2d2: mov     rax,[rbp-88h]
    2d9: mov     [rbp-0B0h],rax
    2e0: mov     qword ptr [rbp-0C0h],0
    2eb: mov     rax,[rbp-0C0h]
    2f2: sub     rax,[rbp-0B0h]
    2f9: mov     [rbp-0A8h],rax
    300: mov     rax,[rbp-0A0h]
    307: imul    rcx,[rbp-0A8h],20h
    30f: add     rax,rcx
    312: mov     [rbp-98h],rax
    319: jmp     2C0h
    31b: mov     edi,0FFFFFF30h
    320: mov     esi,0FFFFFF90h
    325: call    ryo_h_MovW128
    32a: mov     edi,0FFFFFF40h
    32f: lea     rsi,[sym3]
    336: call    ryo_h_AddrSym
    33b: mov     rdi,rbp
    33e: lea     rsi,[ro+20]
    345: call    qword ptr [sym4]
    34b: mov     edi,0FFFFFF88h
    350: mov     esi,0FFFFFF84h
    355: call    ryo_h_TruncW32W16
    35a: mov     edi,0FFFFFF8Ah
    35f: mov     esi,0FFFFFF88h
    364: call    ryo_h_NotW16
    369: movzx   eax,word ptr [rbp-76h]
    36d: mov     [rbp-74h],ax
    371: mov     [rbp-72h],ax
    375: mov     rax,[rbp+10h]
    379: movzx   ecx,word ptr [rbp-72h]
    37d: mov     [rax+18h],cx
    381: mov     byte ptr [rbp-0B9h],0
    388: test    byte ptr [rbp-0B9h],0FFh
    38f: je      3BEh
    391: mov     rax,[rbp+10h]
    395: mov     rax,[rax]
    398: mov     [rbp-0A0h],rax
    39f: mov     [rbp-98h],rax
    3a6: mov     [rbp-90h],rax
    3ad: add     rax,10h
    3b1: mov     [rbp-88h],rax
    3b8: mov     [rbp-80h],rax
    3bc: jmp     3F0h
    3be: mov     rax,[rbp+10h]
    3c2: mov     rax,[rax]
    3c5: mov     [rbp-90h],rax
    3cc: mov     [rbp-88h],rax
    3d3: mov     byte ptr [rbp-0B9h],0
    3da: test    byte ptr [rbp-0B9h],0FFh
    3e1: je      45Fh
    3e3: jmp     452h
    3e5: nop     [rax+rax]
    3ee: xchg    ax,ax
    3f0: mov     rax,[rbp-80h]
    3f4: mov     [rbp-88h],rax
    3fb: mov     [rbp-78h],rax
    3ff: mov     rax,[rbp+10h]
    403: mov     rcx,[rbp-78h]
    407: mov     [rax],rcx
    40a: mov     rax,[rbp+10h]
    40e: mov     rax,[rax+8]
    412: mov     [rbp-80h],rax
    416: mov     qword ptr [rbp-0C0h],10h
    421: imul    rcx,[rbp-0C0h],1
    429: add     rax,rcx
    42c: mov     [rbp-78h],rax
    430: mov     rax,[rbp+10h]
    434: mov     rcx,[rbp-78h]
    438: mov     [rax+8],rcx
    43c: jmp     10h
    441: nop     [rax+rax]
    44a: nop     [rax+rax]
    450: jmp     3F0h
    452: mov     rax,[rbp-88h]
    459: mov     [rbp-80h],rax
    45d: jmp     450h
    45f: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    46a: mov     rax,[rbp-88h]
    471: imul    rcx,[rbp-0C0h],20h
    479: add     rax,rcx
    47c: mov     [rbp-80h],rax
    480: jmp     450h

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     byte ptr [rbp-31h],1
      f: nop
     10: movzx   eax,word ptr [rbp+28h]
     14: mov     [rbp-0B4h],ax
     1b: mov     [rbp-9Ah],ax
     22: mov     edi,0FFFFFF3Ch
     27: mov     esi,0FFFFFF66h
     2c: xor     edx,edx
     2e: xor     ecx,ecx
     30: xor     r8d,r8d
     33: mov     r9d,1
     39: call    ryo_h_DiscrNicheW16
     3e: mov     edi,0FFFFFF58h
     43: mov     esi,0FFFFFF3Ch
     48: call    ryo_h_ZextW32W64
     4d: mov     edi,0FFFFFF58h
     52: xor     esi,esi
     54: mov     edx,2
     59: call    ryo_h_SwitchDenseW64
     5e: lea     rcx,[70h]
     65: movsxd  rax,[rcx+rax*4]
     69: add     rax,rcx
     6c: jmp     rax
     6e: int3
     6f: int3
     70: .long   173h
     74: .long   141h
     78: .long   13ah
     7c: nop     [rax]
     80: mov     byte ptr [rbp-31h],1
     84: mov     rax,[rbp-0A0h]
     8b: mov     [rbp+38h],rax
     8f: mov     rax,[rbp+30h]
     93: sub     rax,1
     97: mov     [rbp+30h],rax
     9b: jmp     10h
     a0: mov     byte ptr [rbp-31h],0
     a4: mov     rax,[rbp+38h]
     a8: mov     [rbp-8],rax
     ac: jmp     0F7h
     ae: xchg    ax,ax
     b0: mov     rax,[rbp+18h]
     b4: mov     [rbp-28h],rax
     b8: mov     [rbp-88h],rax
     bf: mov     rax,[rbp-28h]
     c3: mov     [rbp-90h],rax
     ca: mov     [rbp-0E0h],rax
     d1: mov     edi,0FFFFFF38h
     d6: lea     rsi,[sym0]
     dd: call    ryo_h_AddrSym
     e2: mov     rdi,rbp
     e5: lea     rsi,[ro+4]
     ec: call    qword ptr [sym1]
     f2: jmp     38Eh
     f7: mov     edi,0FFFFFFF8h
     fc: mov     esi,8
    101: call    ryo_h_Ret
    106: leave
    107: ret
    108: nop     [rax+rax]
    110: jmp     132h
    112: nop     [rax+rax]
    11b: nop     [rax+rax]
    120: mov     edi,0FFFFFF88h
    125: call    ryo_h_Resume
    12a: ud2
    12c: nop     [rax]
    130: jmp     120h
    132: test    byte ptr [rbp-31h],0FFh
    136: je      120h
    138: jmp     130h
    13a: call    ryo_h_Unreachable
    13f: ud2
    141: movzx   eax,word ptr [rbp-9Ah]
    148: mov     [rbp-9Ch],ax
    14f: mov     [rbp-0B2h],ax
    156: mov     edi,0FFFFFF3Ch
    15b: mov     esi,0FFFFFF4Eh
    160: call    ryo_h_CttzW16
    165: mov     eax,[rbp-0C4h]
    16b: mov     [rbp-0A0h],eax
    171: jmp     1BAh
    173: mov     edi,0FFFFFF68h
    178: lea     rsi,[k2]
    17f: mov     edx,10h
    184: call    ryo_h_Const
    189: mov     qword ptr [rbp-90h],0
    194: cmp     qword ptr [rbp-90h],0
    19c: sete    [rbp-91h]
    1a3: mov     rax,[rbp+30h]
    1a7: mov     [rbp-80h],rax
    1ab: cmp     rax,0
    1af: je      0A0h
    1b5: jmp     0B0h
    1ba: mov     edi,0FFFFFF50h
    1bf: mov     esi,0FFFFFF60h
    1c4: call    ryo_h_ZextW32W64
    1c9: mov     rax,[rbp-0B0h]
    1d0: mov     [rbp-90h],rax
    1d7: mov     qword ptr [rbp-98h],1
    1e2: mov     [rbp-48h],rax
    1e6: movzx   eax,word ptr [rbp+28h]
    1ea: mov     [rbp-90h],ax
    1f1: sub     eax,1
    1f4: mov     [rbp-8Eh],ax
    1fb: movzx   eax,word ptr [rbp-90h]
    202: and     ax,[rbp-8Eh]
    209: mov     [rbp-8Ch],ax
    210: movzx   eax,word ptr [rbp-8Ch]
    217: mov     [rbp-8Ah],ax
    21e: mov     [rbp+28h],ax
    222: mov     rax,[rbp-48h]
    226: mov     [rbp-80h],rax
    22a: mov     qword ptr [rbp-88h],1
    235: mov     [rbp-90h],rax
    23c: mov     byte ptr [rbp-0C1h],0
    243: test    byte ptr [rbp-0C1h],0FFh
    24a: je      27Ch
    24c: mov     rax,[rbp+10h]
    250: mov     [rbp-0C0h],rax
    257: mov     [rbp-0B8h],rax
    25e: mov     [rbp-0B0h],rax
    265: add     rax,[rbp-90h]
    26c: mov     [rbp-0A8h],rax
    273: mov     [rbp-0A0h],rax
    27a: jmp     2B0h
    27c: mov     rax,[rbp+10h]
    280: mov     [rbp-0B0h],rax
    287: mov     [rbp-0A8h],rax
    28e: mov     byte ptr [rbp-0C1h],0
    295: test    byte ptr [rbp-0C1h],0FFh
    29c: je      345h
    2a2: jmp     335h
    2a7: nop     [rax+rax]
    2b0: mov     rax,[rbp-0A0h]
    2b7: mov     [rbp-0A8h],rax
    2be: mov     [rbp-98h],rax
    2c5: lea     rax,[rbp+40h]
    2c9: mov     [rbp-0A8h],rax
    2d0: mov     byte ptr [rbp-31h],0
    2d4: mov     rax,[rbp+38h]
    2d8: mov     [rbp-0C0h],rax
    2df: mov     [rbp-0B8h],rax
    2e6: mov     rax,[rbp-98h]
    2ed: mov     [rbp-0B0h],rax
    2f4: mov     rax,[rbp-0A8h]
    2fb: mov     [rbp-0E0h],rax
    302: mov     rax,[rbp-0B8h]
    309: mov     [rbp-0D8h],rax
    310: mov     rax,[rbp-0B0h]
    317: mov     [rbp-0D0h],rax
    31e: call    fn3
    323: nop     [rcx-0A0h]
    32a: jmp     80h
    32f: nop
    330: jmp     2B0h
    335: mov     rax,[rbp-0A8h]
    33c: mov     [rbp-0A0h],rax
    343: jmp     330h
    345: mov     rax,[rbp-90h]
    34c: mov     [rbp-0B8h],rax
    353: mov     qword ptr [rbp-0C8h],0
    35e: mov     rax,[rbp-0C8h]
    365: sub     rax,[rbp-0B8h]
    36c: mov     [rbp-0B0h],rax
    373: mov     rax,[rbp-0A8h]
    37a: imul    rcx,[rbp-0B0h],10h
    382: add     rax,rcx
    385: mov     [rbp-0A0h],rax
    38c: jmp     330h
    38e: mov     edi,0FFFFFF20h
    393: mov     esi,0FFFFFF90h
    398: call    ryo_h_MovW128
    39d: mov     edi,0FFFFFF38h
    3a2: lea     rsi,[sym4]
    3a9: call    ryo_h_AddrSym
    3ae: mov     rdi,rbp
    3b1: lea     rsi,[ro+20]
    3b8: call    qword ptr [sym5]
    3be: mov     edi,0FFFFFF80h
    3c3: mov     esi,0FFFFFF7Ch
    3c8: call    ryo_h_TruncW32W16
    3cd: mov     edi,0FFFFFF82h
    3d2: mov     esi,0FFFFFF80h
    3d7: call    ryo_h_NotW16
    3dc: movzx   eax,word ptr [rbp-7Eh]
    3e0: mov     [rbp-7Ch],ax
    3e4: mov     [rbp-7Ah],ax
    3e8: mov     [rbp+28h],ax
    3ec: mov     byte ptr [rbp-0C1h],0
    3f3: test    byte ptr [rbp-0C1h],0FFh
    3fa: je      429h
    3fc: mov     rax,[rbp+10h]
    400: mov     [rbp-0A8h],rax
    407: mov     [rbp-0A0h],rax
    40e: mov     [rbp-98h],rax
    415: add     rax,10h
    419: mov     [rbp-90h],rax
    420: mov     [rbp-88h],rax
    427: jmp     450h
    429: mov     rax,[rbp+10h]
    42d: mov     [rbp-98h],rax
    434: mov     [rbp-90h],rax
    43b: mov     byte ptr [rbp-0C1h],0
    442: test    byte ptr [rbp-0C1h],0FFh
    449: je      4B2h
    44b: jmp     4A2h
    44d: nop     [rax]
    450: mov     rax,[rbp-88h]
    457: mov     [rbp-90h],rax
    45e: mov     [rbp-80h],rax
    462: mov     [rbp+10h],rax
    466: mov     rax,[rbp+18h]
    46a: mov     [rbp-88h],rax
    471: mov     qword ptr [rbp-0C8h],10h
    47c: imul    rcx,[rbp-0C8h],1
    484: add     rax,rcx
    487: mov     [rbp-80h],rax
    48b: mov     [rbp+18h],rax
    48f: jmp     10h
    494: nop     [rax+rax]
    49d: nop     [rax]
    4a0: jmp     450h
    4a2: mov     rax,[rbp-90h]
    4a9: mov     [rbp-88h],rax
    4b0: jmp     4A0h
    4b2: mov     qword ptr [rbp-0C8h],0FFFFFFFFFFFFFFF0h
    4bd: mov     rax,[rbp-90h]
    4c4: imul    rcx,[rbp-0C8h],10h
    4cc: add     rax,rcx
    4cf: mov     [rbp-88h],rax
    4d6: jmp     4A0h
    4d8: mov     rdi,rax
    4db: mov     esi,0FFFFFF88h
    4e0: call    ryo_h_Lpad
    4e5: jmp     110h

fn hashbrown::raw::RawIterRange::<(u64, u64)>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: imul    rcx,[rbp+20h],1
     14: add     rax,rcx
     17: mov     [rbp-98h],rax
     1e: mov     rax,[rbp+18h]
     22: mov     [rbp-0A0h],rax
     29: mov     rax,[rbp+18h]
     2d: mov     [rbp-0A8h],rax
     34: mov     [rbp-0C0h],rax
     3b: mov     edi,0FFFFFF50h
     40: lea     rsi,[sym0]
     47: call    ryo_h_AddrSym
     4c: mov     rdi,rbp
     4f: lea     rsi,[ro+4]
     56: call    qword ptr [sym1]
     5c: mov     edi,0FFFFFF40h
     61: mov     esi,0FFFFFF70h
     66: call    ryo_h_MovW128
     6b: mov     edi,0FFFFFF50h
     70: lea     rsi,[sym2]
     77: call    ryo_h_AddrSym
     7c: mov     rdi,rbp
     7f: lea     rsi,[ro+20]
     86: call    qword ptr [sym3]
     8c: mov     edi,0FFFFFF64h
     91: mov     esi,0FFFFFF60h
     96: call    ryo_h_TruncW32W16
     9b: mov     edi,0FFFFFF66h
     a0: mov     esi,0FFFFFF64h
     a5: call    ryo_h_NotW16
     aa: movzx   eax,word ptr [rbp-9Ah]
     b1: mov     [rbp-4Ch],ax
     b5: mov     qword ptr [rbp-0B0h],10h
     c0: mov     rax,[rbp+18h]
     c4: imul    rcx,[rbp-0B0h],1
     cc: add     rax,rcx
     cf: mov     [rbp-60h],rax
     d3: movzx   eax,word ptr [rbp-4Ch]
     d7: mov     [rbp-9Ah],ax
     de: mov     [rbp-8],ax
     e2: mov     rax,[rbp+10h]
     e6: mov     [rbp-20h],rax
     ea: mov     rax,[rbp-60h]
     ee: mov     [rbp-18h],rax
     f2: mov     rax,[rbp-98h]
     f9: mov     [rbp-10h],rax
     fd: mov     edi,0FFFFFFE0h
    102: mov     esi,20h
    107: call    ryo_h_Ret
    10c: leave
    10d: ret

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: movzx   eax,word ptr [rax+18h]
     18: mov     [rbp-0ACh],ax
     1f: mov     [rbp-92h],ax
     26: mov     edi,0FFFFFF44h
     2b: mov     esi,0FFFFFF6Eh
     30: xor     edx,edx
     32: xor     ecx,ecx
     34: xor     r8d,r8d
     37: mov     r9d,1
     3d: call    ryo_h_DiscrNicheW16
     42: mov     edi,0FFFFFF60h
     47: mov     esi,0FFFFFF44h
     4c: call    ryo_h_ZextW32W64
     51: mov     edi,0FFFFFF60h
     56: xor     esi,esi
     58: mov     edx,2
     5d: call    ryo_h_SwitchDenseW64
     62: lea     rcx,[74h]
     69: movsxd  rax,[rcx+rax*4]
     6d: add     rax,rcx
     70: jmp     rax
     72: int3
     73: int3
     74: .long   15ah
     78: .long   128h
     7c: .long   121h
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax+8]
     88: mov     [rbp-80h],rax
     8c: mov     rax,[rbp+10h]
     90: mov     rax,[rax+10h]
     94: mov     [rbp-88h],rax
     9b: mov     rax,[rbp-80h]
     9f: cmp     rax,[rbp-88h]
     a6: jb      0C0h
     a8: mov     qword ptr [rbp-8],0
     b0: jmp     110h
     b2: nop     [rax+rax]
     bb: nop     [rax+rax]
     c0: mov     rax,[rbp+10h]
     c4: mov     rax,[rax+8]
     c8: mov     [rbp-28h],rax
     cc: mov     [rbp-80h],rax
     d0: mov     rax,[rbp-28h]
     d4: mov     [rbp-88h],rax
     db: mov     [rbp-0D0h],rax
     e2: mov     edi,0FFFFFF40h
     e7: lea     rsi,[sym0]
     ee: call    ryo_h_AddrSym
     f3: mov     rdi,rbp
     f6: lea     rsi,[ro+4]
     fd: call    qword ptr [sym1]
    103: jmp     31Bh
    108: nop     [rax+rax]
    110: mov     edi,0FFFFFFF8h
    115: mov     esi,8
    11a: call    ryo_h_Ret
    11f: leave
    120: ret
    121: call    ryo_h_Unreachable
    126: ud2
    128: movzx   eax,word ptr [rbp-92h]
    12f: mov     [rbp-94h],ax
    136: mov     [rbp-0AAh],ax
    13d: mov     edi,0FFFFFF44h
    142: mov     esi,0FFFFFF56h
    147: call    ryo_h_CttzW16
    14c: mov     eax,[rbp-0BCh]
    152: mov     [rbp-98h],eax
    158: jmp     1A3h
    15a: mov     edi,0FFFFFF70h
    15f: lea     rsi,[k2]
    166: mov     edx,10h
    16b: call    ryo_h_Const
    170: mov     qword ptr [rbp-88h],0
    17b: cmp     qword ptr [rbp-88h],0
    183: sete    [rbp-89h]
    18a: mov     byte ptr [rbp-0B9h],0
    191: test    byte ptr [rbp-0B9h],0FFh
    198: je      0C0h
    19e: jmp     80h
    1a3: mov     edi,0FFFFFF58h
    1a8: mov     esi,0FFFFFF68h
    1ad: call    ryo_h_ZextW32W64
    1b2: mov     rax,[rbp-0A8h]
    1b9: mov     [rbp-88h],rax
    1c0: mov     qword ptr [rbp-90h],1
    1cb: mov     [rbp-48h],rax
    1cf: mov     rax,[rbp+10h]
    1d3: movzx   eax,word ptr [rax+18h]
    1d7: mov     [rbp-88h],ax
    1de: sub     eax,1
    1e1: mov     [rbp-86h],ax
    1e8: movzx   eax,word ptr [rbp-88h]
    1ef: and     ax,[rbp-86h]
    1f6: mov     [rbp-84h],ax
    1fd: movzx   eax,word ptr [rbp-84h]
    204: mov     [rbp-82h],ax
    20b: mov     rax,[rbp+10h]
    20f: movzx   ecx,word ptr [rbp-82h]
    216: mov     [rax+18h],cx
    21a: mov     rax,[rbp-48h]
    21e: mov     [rbp-78h],rax
    222: mov     qword ptr [rbp-80h],1
    22a: mov     [rbp-88h],rax
    231: mov     byte ptr [rbp-0B9h],0
    238: test    byte ptr [rbp-0B9h],0FFh
    23f: je      274h
    241: mov     rax,[rbp+10h]
    245: mov     rax,[rax]
    248: mov     [rbp-0B8h],rax
    24f: mov     [rbp-0B0h],rax
    256: mov     [rbp-0A8h],rax
    25d: add     rax,[rbp-88h]
    264: mov     [rbp-0A0h],rax
    26b: mov     [rbp-98h],rax
    272: jmp     2A0h
    274: mov     rax,[rbp+10h]
    278: mov     rax,[rax]
    27b: mov     [rbp-0A8h],rax
    282: mov     [rbp-0A0h],rax
    289: mov     byte ptr [rbp-0B9h],0
    290: test    byte ptr [rbp-0B9h],0FFh
    297: je      2D2h
    299: jmp     2C2h
    29b: nop     [rax+rax]
    2a0: mov     rax,[rbp-98h]
    2a7: mov     [rbp-0A0h],rax
    2ae: mov     [rbp-90h],rax
    2b5: mov     [rbp-8],rax
    2b9: jmp     110h
    2be: xchg    ax,ax
    2c0: jmp     2A0h
    2c2: mov     rax,[rbp-0A0h]
    2c9: mov     [rbp-98h],rax
    2d0: jmp     2C0h
    2d2: mov     rax,[rbp-88h]
    2d9: mov     [rbp-0B0h],rax
    2e0: mov     qword ptr [rbp-0C0h],0
    2eb: mov     rax,[rbp-0C0h]
    2f2: sub     rax,[rbp-0B0h]
    2f9: mov     [rbp-0A8h],rax
    300: mov     rax,[rbp-0A0h]
    307: imul    rcx,[rbp-0A8h],10h
    30f: add     rax,rcx
    312: mov     [rbp-98h],rax
    319: jmp     2C0h
    31b: mov     edi,0FFFFFF30h
    320: mov     esi,0FFFFFF90h
    325: call    ryo_h_MovW128
    32a: mov     edi,0FFFFFF40h
    32f: lea     rsi,[sym3]
    336: call    ryo_h_AddrSym
    33b: mov     rdi,rbp
    33e: lea     rsi,[ro+20]
    345: call    qword ptr [sym4]
    34b: mov     edi,0FFFFFF88h
    350: mov     esi,0FFFFFF84h
    355: call    ryo_h_TruncW32W16
    35a: mov     edi,0FFFFFF8Ah
    35f: mov     esi,0FFFFFF88h
    364: call    ryo_h_NotW16
    369: movzx   eax,word ptr [rbp-76h]
    36d: mov     [rbp-74h],ax
    371: mov     [rbp-72h],ax
    375: mov     rax,[rbp+10h]
    379: movzx   ecx,word ptr [rbp-72h]
    37d: mov     [rax+18h],cx
    381: mov     byte ptr [rbp-0B9h],0
    388: test    byte ptr [rbp-0B9h],0FFh
    38f: je      3BEh
    391: mov     rax,[rbp+10h]
    395: mov     rax,[rax]
    398: mov     [rbp-0A0h],rax
    39f: mov     [rbp-98h],rax
    3a6: mov     [rbp-90h],rax
    3ad: add     rax,10h
    3b1: mov     [rbp-88h],rax
    3b8: mov     [rbp-80h],rax
    3bc: jmp     3F0h
    3be: mov     rax,[rbp+10h]
    3c2: mov     rax,[rax]
    3c5: mov     [rbp-90h],rax
    3cc: mov     [rbp-88h],rax
    3d3: mov     byte ptr [rbp-0B9h],0
    3da: test    byte ptr [rbp-0B9h],0FFh
    3e1: je      45Fh
    3e3: jmp     452h
    3e5: nop     [rax+rax]
    3ee: xchg    ax,ax
    3f0: mov     rax,[rbp-80h]
    3f4: mov     [rbp-88h],rax
    3fb: mov     [rbp-78h],rax
    3ff: mov     rax,[rbp+10h]
    403: mov     rcx,[rbp-78h]
    407: mov     [rax],rcx
    40a: mov     rax,[rbp+10h]
    40e: mov     rax,[rax+8]
    412: mov     [rbp-80h],rax
    416: mov     qword ptr [rbp-0C0h],10h
    421: imul    rcx,[rbp-0C0h],1
    429: add     rax,rcx
    42c: mov     [rbp-78h],rax
    430: mov     rax,[rbp+10h]
    434: mov     rcx,[rbp-78h]
    438: mov     [rax+8],rcx
    43c: jmp     10h
    441: nop     [rax+rax]
    44a: nop     [rax+rax]
    450: jmp     3F0h
    452: mov     rax,[rbp-88h]
    459: mov     [rbp-80h],rax
    45d: jmp     450h
    45f: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    46a: mov     rax,[rbp-88h]
    471: imul    rcx,[rbp-0C0h],10h
    479: add     rax,rcx
    47c: mov     [rbp-80h],rax
    480: jmp     450h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     [rbp-78h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     [rbp-70h],rax
     27: lea     rax,[rbp-78h]
     2b: mov     [rbp-68h],rax
     2f: mov     [rbp-60h],rax
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rax,[rbp+18h]
     53: mov     [rbp-0A8h],rax
     5a: mov     edi,0FFFFFF60h
     5f: mov     esi,0FFFFFFA0h
     64: call    ryo_h_MovW128
     69: call    fn1
     6e: nop     [rcx-48h]
     75: mov     rax,[rbp-48h]
     79: mov     [rbp-10h],rax
     7d: mov     edi,0FFFFFFF0h
     82: xor     esi,esi
     84: mov     edx,2
     89: call    ryo_h_SwitchDenseW64
     8e: lea     rcx,[0A0h]
     95: movsxd  rax,[rcx+rax*4]
     99: add     rax,rcx
     9c: jmp     rax
     9e: int3
     9f: int3
     a0: .long   b3h
     a4: .long   bdh
     a8: .long   ach
     ac: call    ryo_h_Unreachable
     b1: ud2
     b3: mov     qword ptr [rbp-8],0
     bb: jmp     0F0h
     bd: mov     rax,[rbp-40h]
     c1: mov     [rbp-50h],rax
     c5: mov     rax,[rbp+10h]
     c9: mov     rax,[rax]
     cc: mov     [rbp-68h],rax
     d0: mov     [rbp-60h],rax
     d4: mov     byte ptr [rbp-89h],0
     db: test    byte ptr [rbp-89h],0FFh
     e2: je      12Eh
     e4: jmp     11Ch
     e6: nop     [rax+rax]
     ef: nop
     f0: mov     edi,0FFFFFFF8h
     f5: mov     esi,8
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: nop     [rax+rax]
    10a: nop     [rax+rax]
    110: mov     edi,0FFFFFFC8h
    115: call    ryo_h_Resume
    11a: ud2
    11c: mov     rax,[rbp-50h]
    120: add     rax,1
    124: mov     [rbp-78h],rax
    128: mov     [rbp-70h],rax
    12c: jmp     150h
    12e: mov     rax,[rbp-68h]
    132: mov     [rbp-78h],rax
    136: mov     byte ptr [rbp-89h],0
    13d: test    byte ptr [rbp-89h],0FFh
    144: je      17Ch
    146: jmp     172h
    148: nop     [rax+rax]
    150: mov     rax,[rbp-70h]
    154: mov     [rbp-78h],rax
    158: mov     [rbp-58h],rax
    15c: mov     [rbp-8],rax
    160: jmp     0F0h
    162: nop     [rax+rax]
    16b: nop     [rax+rax]
    170: jmp     150h
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-70h],rax
    17a: jmp     170h
    17c: mov     rax,[rbp-50h]
    180: mov     [rbp-88h],rax
    187: mov     qword ptr [rbp-90h],0
    192: mov     rax,[rbp-90h]
    199: sub     rax,[rbp-88h]
    1a0: mov     [rbp-80h],rax
    1a4: mov     rax,[rbp-78h]
    1a8: imul    rcx,[rbp-80h],20h
    1ad: add     rax,rcx
    1b0: mov     [rbp-70h],rax
    1b4: jmp     170h
    1b6: mov     rdi,rax
    1b9: mov     esi,0FFFFFFC8h
    1be: call    ryo_h_Lpad
    1c3: jmp     110h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rax,[rbp+10h]
     1a: mov     rax,[rax+8]
     1e: mov     [rbp-20h],rax
     22: mov     rax,[rax]
     25: mov     [rbp-68h],rax
     29: mov     [rbp-60h],rax
     2d: mov     byte ptr [rbp-89h],0
     34: test    byte ptr [rbp-89h],0FFh
     3b: je      63h
     3d: jmp     51h
     3f: nop
     40: mov     edi,0FFFFFFFFh
     45: mov     esi,1
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+18h]
     55: add     rax,1
     59: mov     [rbp-78h],rax
     5d: mov     [rbp-70h],rax
     61: jmp     80h
     63: mov     rax,[rbp-68h]
     67: mov     [rbp-78h],rax
     6b: mov     byte ptr [rbp-89h],0
     72: test    byte ptr [rbp-89h],0FFh
     79: je      0BCh
     7b: jmp     0B2h
     7d: nop     [rax]
     80: mov     rax,[rbp-70h]
     84: mov     [rbp-48h],rax
     88: mov     byte ptr [rbp-89h],0
     8f: test    byte ptr [rbp-89h],0FFh
     96: je      13Dh
     9c: jmp     133h
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rax,[rbp-90h]
     d9: sub     rax,[rbp-88h]
     e0: mov     [rbp-80h],rax
     e4: mov     rax,[rbp-78h]
     e8: imul    rcx,[rbp-80h],20h
     ed: add     rax,rcx
     f0: mov     [rbp-70h],rax
     f4: jmp     0B0h
     f6: nop     [rax+rax]
     ff: nop
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rax,[rbp-18h]
    110: mov     [rbp-0A0h],rax
    117: mov     rax,[rbp-50h]
    11b: mov     [rbp-98h],rax
    122: call    fn0
    127: nop     [rcx-1]
    12e: jmp     40h
    133: mov     qword ptr [rbp-60h],8
    13b: jmp     100h
    13d: mov     rax,[rbp-48h]
    141: mov     [rbp-68h],rax
    145: mov     byte ptr [rbp-89h],0
    14c: test    byte ptr [rbp-89h],0FFh
    153: je      16Ch
    155: jmp     162h
    157: nop     [rax+rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rax,[rbp-68h]
    17b: imul    rcx,[rbp-90h],20h
    183: add     rax,rcx
    186: mov     [rbp-60h],rax
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     [rbp-0B0h],rax
     1a: mov     rax,[rbp+18h]
     1e: mov     [rbp-0A8h],rax
     25: call    fn0
     2a: nop     [rcx-28h]
     31: jmp     70h
     33: nop     [rax+rax]
     3c: nop     [rax]
     40: mov     edi,0FFFFFFA0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: lea     rax,[rbp+20h]
     54: mov     [rbp-98h],rax
     5b: mov     [rbp-0B0h],rax
     62: call    fn1
     67: nop     [rcx-98h]
     6e: jmp     40h
     70: mov     rax,[rbp+10h]
     74: mov     rax,[rax]
     77: mov     [rbp-80h],rax
     7b: mov     [rbp-78h],rax
     7f: imul    rcx,[rbp-28h],1
     84: add     rax,rcx
     87: mov     [rbp-70h],rax
     8b: mov     [rbp-68h],rax
     8f: movzx   eax,byte ptr [rax]
     92: mov     [rbp-51h],al
     95: mov     rax,[rbp+18h]
     99: shr     rax,39h
     9d: mov     [rbp-70h],rax
     a1: and     rax,7Fh
     a5: mov     [rbp-78h],rax
     a9: mov     edi,0FFFFFF9Eh
     ae: mov     esi,0FFFFFF88h
     b3: call    ryo_h_TruncW64W8
     b8: movzx   eax,byte ptr [rbp-62h]
     bc: mov     [rbp-61h],al
     bf: mov     rax,[rbp-28h]
     c3: sub     rax,10h
     c7: mov     [rbp-80h],rax
     cb: mov     rax,[rbp+10h]
     cf: mov     rax,[rax+8]
     d3: mov     [rbp-88h],rax
     da: mov     rax,[rbp-80h]
     de: and     rax,[rbp-88h]
     e5: mov     [rbp-78h],rax
     e9: add     rax,10h
     ed: mov     [rbp-70h],rax
     f1: mov     rax,[rbp+10h]
     f5: mov     rax,[rax]
     f8: mov     [rbp-90h],rax
     ff: mov     [rbp-88h],rax
    106: imul    rcx,[rbp-28h],1
    10b: add     rax,rcx
    10e: mov     [rbp-80h],rax
    112: mov     [rbp-78h],rax
    116: movzx   ecx,byte ptr [rbp-61h]
    11a: mov     [rax],cl
    11c: mov     rax,[rbp+10h]
    120: mov     rax,[rax]
    123: mov     [rbp-90h],rax
    12a: mov     [rbp-88h],rax
    131: imul    rcx,[rbp-70h],1
    136: add     rax,rcx
    139: mov     [rbp-80h],rax
    13d: mov     [rbp-78h],rax
    141: movzx   ecx,byte ptr [rbp-61h]
    145: mov     [rax],cl
    147: mov     rax,[rbp+10h]
    14b: mov     rax,[rax]
    14e: mov     [rbp-70h],rax
    152: mov     [rbp-68h],rax
    156: mov     byte ptr [rbp-91h],0
    15d: test    byte ptr [rbp-91h],0FFh
    164: je      178h
    166: mov     rax,[rbp-28h]
    16a: add     rax,1
    16e: mov     [rbp-80h],rax
    172: mov     [rbp-78h],rax
    176: jmp     1A0h
    178: mov     rax,[rbp-70h]
    17c: mov     [rbp-80h],rax
    180: mov     byte ptr [rbp-91h],0
    187: test    byte ptr [rbp-91h],0FFh
    18e: je      23Fh
    194: jmp     235h
    199: nop     [rax]
    1a0: mov     rax,[rbp-78h]
    1a4: mov     [rbp-50h],rax
    1a8: mov     [rbp-8],rax
    1ac: movzx   eax,byte ptr [rbp-51h]
    1b0: and     al,1
    1b3: mov     [rbp-6Ah],al
    1b6: cmp     byte ptr [rbp-6Ah],0
    1ba: setne   [rbp-69h]
    1be: mov     edi,0FFFFFF98h
    1c3: mov     esi,0FFFFFF97h
    1c8: call    ryo_h_ZextW8W64
    1cd: mov     rax,[rbp+10h]
    1d1: mov     rax,[rax+10h]
    1d5: mov     [rbp-98h],rax
    1dc: sub     rax,[rbp-68h]
    1e0: mov     [rbp-0A0h],rax
    1e7: mov     rax,[rbp+10h]
    1eb: mov     rcx,[rbp-0A0h]
    1f2: mov     [rax+10h],rcx
    1f6: mov     edi,0FFFFFF80h
    1fb: mov     esi,20h
    200: mov     edx,20h
    205: call    ryo_h_Copy
    20a: mov     byte ptr [rbp-91h],0
    211: test    byte ptr [rbp-91h],0FFh
    218: je      2DDh
    21e: jmp     2D0h
    223: nop     [rax+rax]
    22c: nop     [rax]
    230: jmp     1A0h
    235: mov     rax,[rbp-80h]
    239: mov     [rbp-78h],rax
    23d: jmp     230h
    23f: mov     rax,[rbp-28h]
    243: mov     [rbp-90h],rax
    24a: mov     qword ptr [rbp-98h],0
    255: mov     rax,[rbp-98h]
    25c: sub     rax,[rbp-90h]
    263: mov     [rbp-88h],rax
    26a: mov     rax,[rbp-80h]
    26e: imul    rcx,[rbp-88h],20h
    276: add     rax,rcx
    279: mov     [rbp-78h],rax
    27d: jmp     230h
    27f: nop
    280: mov     edi,0FFFFFF78h
    285: xor     esi,esi
    287: mov     edx,0FFFFFF80h
    28c: mov     ecx,20h
    291: call    ryo_h_StoreCopy
    296: mov     rax,[rbp+10h]
    29a: mov     rax,[rax+18h]
    29e: mov     [rbp-98h],rax
    2a5: add     rax,1
    2a9: mov     [rbp-0A0h],rax
    2b0: mov     rax,[rbp+10h]
    2b4: mov     rcx,[rbp-0A0h]
    2bb: mov     [rax+18h],rcx
    2bf: mov     edi,0FFFFFFF8h
    2c4: mov     esi,8
    2c9: call    ryo_h_Ret
    2ce: leave
    2cf: ret
    2d0: mov     qword ptr [rbp-88h],8
    2db: jmp     280h
    2dd: mov     rax,[rbp-50h]
    2e1: mov     [rbp-90h],rax
    2e8: mov     byte ptr [rbp-91h],0
    2ef: test    byte ptr [rbp-91h],0FFh
    2f6: je      315h
    2f8: jmp     305h
    2fa: nop     [rax+rax]
    300: jmp     280h
    305: mov     rax,[rbp-90h]
    30c: mov     [rbp-88h],rax
    313: jmp     300h
    315: mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    320: mov     rax,[rbp-90h]
    327: imul    rcx,[rbp-98h],20h
    32f: add     rax,rcx
    332: mov     [rbp-88h],rax
    339: jmp     300h
    33b: nop     [rax+rax]
    340: lea     rdi,[sym2]
    347: lea     rsi,[site3]
    34e: mov     edx,0FFFFFF68h
    353: call    ryo_h_CallExt
    358: test    rax,rax
    35b: je      368h
    35d: call    rax
    35f: nop     [rcx-90h]
    366: jmp     378h
    368: mov     rdi,rbp
    36b: lea     rsi,[ro+4]
    372: call    qword ptr [sym4]
    378: call    ryo_h_Unreachable
    37d: ud2
    37f: mov     rdi,rax
    382: mov     esi,0FFFFFFA0h
    387: call    ryo_h_Lpad
    38c: jmp     50h
    391: mov     rdi,rax
    394: mov     esi,0FFFFFFA0h
    399: call    ryo_h_Lpad
    39e: jmp     340h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-38h],rax
     14: cmp     rax,[rbp+18h]
     18: setb    [rbp-29h]
     1c: test    byte ptr [rbp-29h],0FFh
     20: je      0E1h
     26: jmp     0A8h
     2b: nop     [rax+rax]
     30: mov     edi,0FFFFFFBCh
     35: mov     esi,0FFFFFFC8h
     3a: mov     rdx,0FFFFFFFFFFFFFFFFh
     41: xor     ecx,ecx
     43: xor     r8d,r8d
     46: mov     r9d,1
     4c: call    ryo_h_DiscrNicheW64
     51: mov     edi,0FFFFFFC0h
     56: mov     esi,0FFFFFFBCh
     5b: call    ryo_h_ZextW32W64
     60: cmp     qword ptr [rbp-40h],0
     65: sete    [rbp-19h]
     69: nop     [rax]
     70: xor     edi,edi
     72: xor     esi,esi
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFD8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-1],0FFh
     a4: je      80h
     a6: jmp     90h
     a8: mov     byte ptr [rbp-1],0
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-40h],rax
     b4: mov     rax,[rbp+10h]
     b8: mov     [rbp-70h],rax
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-60h],rax
     c4: mov     rax,[rbp-40h]
     c8: mov     [rbp-68h],rax
     cc: mov     byte ptr [rbp-58h],1
     d0: call    fn0
     d5: nop     [rcx-38h]
     dc: jmp     30h
     e1: jmp     70h
     e3: mov     rdi,rax
     e6: mov     esi,0FFFFFFD8h
     eb: call    ryo_h_Lpad
     f0: jmp     0A0h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: mov     rax,[rbp+10h]
     17: lea     rax,[rax+20h]
     1b: mov     [rbp-28h],rax
     1f: lea     rax,[rbp+18h]
     23: mov     [rbp-50h],rax
     27: mov     [rbp-48h],rax
     2b: lea     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     [rbp-38h],rax
     37: mov     edi,0FFFFFFD0h
     3c: lea     rsi,[k0]
     43: call    ryo_h_AddrAbs
     48: mov     byte ptr [rbp-59h],1
     4c: test    byte ptr [rbp-59h],0FFh
     50: je      6Dh
     52: mov     edi,0FFFFFFA8h
     57: lea     rsi,[sym1]
     5e: call    ryo_h_AddrSym
     63: mov     rax,[rbp-58h]
     67: mov     [rbp-50h],rax
     6b: jmp     75h
     6d: mov     qword ptr [rbp-50h],0
     75: mov     rax,[rbp-20h]
     79: mov     [rbp-0B0h],rax
     80: mov     rax,[rbp-28h]
     84: mov     [rbp-0A8h],rax
     8b: mov     rax,[rbp+20h]
     8f: mov     [rbp-90h],rax
     96: mov     edi,0FFFFFF60h
     9b: mov     esi,0FFFFFFC8h
     a0: call    ryo_h_MovW128
     a5: movzx   eax,byte ptr [rbp+28h]
     a9: mov     [rbp-78h],al
     ac: mov     edi,0FFFFFF78h
     b1: lea     rsi,[k2]
     b8: mov     edx,10h
     bd: call    ryo_h_Const
     c2: mov     rax,[rbp-50h]
     c6: mov     [rbp-70h],rax
     ca: call    fn3
     cf: nop     [rcx-10h]
     d6: mov     edi,0FFFFFFF0h
     db: mov     esi,10h
     e0: call    ryo_h_Ret
     e5: leave
     e6: ret
     e7: nop     [rax+rax]
     f0: mov     edi,0FFFFFFE8h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: mov     rdi,rax
     ff: mov     esi,0FFFFFFE8h
    104: call    ryo_h_Lpad
    109: jmp     0F0h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rax,[rbp+18h]
     1a: mov     rax,[rax]
     1d: mov     [rbp-60h],rax
     21: mov     [rbp-58h],rax
     25: mov     byte ptr [rbp-81h],0
     2c: test    byte ptr [rbp-81h],0FFh
     33: je      63h
     35: jmp     51h
     37: nop     [rax+rax]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+20h]
     55: add     rax,1
     59: mov     [rbp-70h],rax
     5d: mov     [rbp-68h],rax
     61: jmp     80h
     63: mov     rax,[rbp-60h]
     67: mov     [rbp-70h],rax
     6b: mov     byte ptr [rbp-81h],0
     72: test    byte ptr [rbp-81h],0FFh
     79: je      0ACh
     7b: jmp     0A2h
     7d: nop     [rax]
     80: mov     rax,[rbp-68h]
     84: mov     [rbp-40h],rax
     88: mov     byte ptr [rbp-81h],0
     8f: test    byte ptr [rbp-81h],0FFh
     96: je      11Dh
     9c: jmp     113h
     9e: xchg    ax,ax
     a0: jmp     80h
     a2: mov     rax,[rbp-70h]
     a6: mov     [rbp-68h],rax
     aa: jmp     0A0h
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-80h],rax
     b4: mov     qword ptr [rbp-88h],0
     bf: mov     rax,[rbp-88h]
     c6: sub     rax,[rbp-80h]
     ca: mov     [rbp-78h],rax
     ce: mov     rax,[rbp-70h]
     d2: imul    rcx,[rbp-78h],20h
     d7: add     rax,rcx
     da: mov     [rbp-68h],rax
     de: jmp     0A0h
     e0: mov     rax,[rbp-58h]
     e4: mov     [rbp-50h],rax
     e8: mov     [rbp-48h],rax
     ec: mov     rax,[rbp-18h]
     f0: mov     [rbp-0A0h],rax
     f7: mov     rax,[rbp-48h]
     fb: mov     [rbp-98h],rax
    102: call    fn0
    107: nop     [rcx-8]
    10e: jmp     40h
    113: mov     qword ptr [rbp-58h],8
    11b: jmp     0E0h
    11d: mov     rax,[rbp-40h]
    121: mov     [rbp-60h],rax
    125: mov     byte ptr [rbp-81h],0
    12c: test    byte ptr [rbp-81h],0FFh
    133: je      14Ch
    135: jmp     142h
    137: nop     [rax+rax]
    140: jmp     0E0h
    142: mov     rax,[rbp-60h]
    146: mov     [rbp-58h],rax
    14a: jmp     140h
    14c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    157: mov     rax,[rbp-60h]
    15b: imul    rcx,[rbp-88h],20h
    163: add     rax,rcx
    166: mov     [rbp-58h],rax
    16a: jmp     140h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: mov     [rbp-20h],rax
     18: call    fn0
     1d: nop     [rcx]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp+10h]
     14: mov     [rbp-40h],rax
     18: mov     rax,[rbp-10h]
     1c: mov     [rbp-38h],rax
     20: call    fn0
     25: nop     [rcx]
     2c: mov     byte ptr [rbp-21h],0
     30: test    byte ptr [rbp-21h],0FFh
     34: je      79h
     36: jmp     6Fh
     38: nop     [rax+rax]
     40: mov     rax,[rbp-10h]
     44: mov     [rbp-18h],rax
     48: mov     [rbp-40h],rax
     4c: mov     edi,0FFFFFFD8h
     51: lea     rsi,[sym1]
     58: call    ryo_h_AddrSym
     5d: mov     rdi,rbp
     60: lea     rsi,[ro+4]
     67: call    qword ptr [sym2]
     6d: jmp     0C6h
     6f: mov     qword ptr [rbp-10h],8
     77: jmp     40h
     79: mov     rax,[rbp+18h]
     7d: mov     [rbp-20h],rax
     81: mov     [rbp-18h],rax
     85: mov     byte ptr [rbp-21h],0
     89: test    byte ptr [rbp-21h],0FFh
     8d: je      0ACh
     8f: jmp     0A2h
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: jmp     40h
     a2: mov     rax,[rbp-18h]
     a6: mov     [rbp-10h],rax
     aa: jmp     0A0h
     ac: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
     b4: mov     rax,[rbp-18h]
     b8: imul    rcx,[rbp-28h],10h
     bd: add     rax,rcx
     c0: mov     [rbp-10h],rax
     c4: jmp     0A0h
     c6: xor     edi,edi
     c8: xor     esi,esi
     ca: call    ryo_h_Ret
     cf: leave
     d0: ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     [rbp-10h],rax
     17: mov     byte ptr [rbp-33h],0
     1b: test    byte ptr [rbp-33h],0FFh
     1f: je      7Fh
     21: jmp     62h
     23: nop     [rax+rax]
     2c: nop     [rax]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: nop     [rax+rax]
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-10h],rax
     48: mov     [rbp-60h],rax
     4c: mov     rax,[rbp-8]
     50: mov     [rbp-58h],rax
     54: call    fn0
     59: nop     [rcx-8]
     60: jmp     30h
     62: mov     rax,[rbp+18h]
     66: mov     rax,[rax]
     69: mov     [rbp-30h],rax
     6d: mov     [rbp-28h],rax
     71: mov     [rbp-20h],rax
     75: sub     rax,1
     79: mov     [rbp-8],rax
     7d: jmp     40h
     7f: mov     rax,[rbp-18h]
     83: mov     [rbp-20h],rax
     87: mov     rax,[rbp+18h]
     8b: mov     rax,[rax]
     8e: mov     [rbp-30h],rax
     92: mov     [rbp-28h],rax
     96: mov     qword ptr [rbp-40h],0
     9e: cmp     qword ptr [rbp-40h],10h
     a3: setb    [rbp-31h]
     a7: test    byte ptr [rbp-31h],0FFh
     ab: je      107h
     ad: jmp     0BAh
     af: nop
     b0: mov     rax,[rbp-30h]
     b4: mov     [rbp-8],rax
     b8: jmp     40h
     ba: mov     qword ptr [rbp-40h],10h
     c2: mov     rax,[rbp-40h]
     c6: mov     rcx,7FFFFFFFFFFFFFFFh
     d0: cmp     rax,rcx
     d3: setbe   [rbp-32h]
     d7: test    byte ptr [rbp-32h],0FFh
     db: je      107h
     dd: mov     rax,[rbp-20h]
     e1: sub     rax,[rbp-28h]
     e5: mov     [rbp-30h],rax
     e9: mov     qword ptr [rbp-40h],10h
     f1: mov     edi,0FFFFFFD0h
     f6: mov     esi,0FFFFFFD0h
     fb: mov     edx,0FFFFFFC0h
    100: call    ryo_h_DivSW64
    105: jmp     0B0h
    107: mov     edi,0FFFFFFA0h
    10c: lea     rsi,[k1]
    113: call    ryo_h_AddrAbs
    118: mov     qword ptr [rbp-58h],49h
    120: mov     edi,0FFFFFFB0h
    125: lea     rsi,[k2]
    12c: call    ryo_h_AddrAbs
    131: lea     rdi,[sym3]
    138: lea     rsi,[site4]
    13f: mov     edx,0FFFFFFC0h
    144: call    ryo_h_CallExt
    149: test    rax,rax
    14c: je      159h
    14e: call    rax
    150: nop     [rcx-8]
    157: jmp     169h
    159: mov     rdi,rbp
    15c: lea     rsi,[ro+4]
    163: call    qword ptr [sym5]
    169: call    ryo_h_Unreachable
    16e: ud2

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     [rbp-78h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     [rbp-70h],rax
     27: lea     rax,[rbp-78h]
     2b: mov     [rbp-68h],rax
     2f: mov     [rbp-60h],rax
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rax,[rbp+18h]
     53: mov     [rbp-0A8h],rax
     5a: mov     edi,0FFFFFF60h
     5f: mov     esi,0FFFFFFA0h
     64: call    ryo_h_MovW128
     69: call    fn1
     6e: nop     [rcx-48h]
     75: mov     rax,[rbp-48h]
     79: mov     [rbp-10h],rax
     7d: mov     edi,0FFFFFFF0h
     82: xor     esi,esi
     84: mov     edx,2
     89: call    ryo_h_SwitchDenseW64
     8e: lea     rcx,[0A0h]
     95: movsxd  rax,[rcx+rax*4]
     99: add     rax,rcx
     9c: jmp     rax
     9e: int3
     9f: int3
     a0: .long   b3h
     a4: .long   bdh
     a8: .long   ach
     ac: call    ryo_h_Unreachable
     b1: ud2
     b3: mov     qword ptr [rbp-8],0
     bb: jmp     0F0h
     bd: mov     rax,[rbp-40h]
     c1: mov     [rbp-50h],rax
     c5: mov     rax,[rbp+10h]
     c9: mov     rax,[rax]
     cc: mov     [rbp-68h],rax
     d0: mov     [rbp-60h],rax
     d4: mov     byte ptr [rbp-89h],0
     db: test    byte ptr [rbp-89h],0FFh
     e2: je      12Eh
     e4: jmp     11Ch
     e6: nop     [rax+rax]
     ef: nop
     f0: mov     edi,0FFFFFFF8h
     f5: mov     esi,8
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: nop     [rax+rax]
    10a: nop     [rax+rax]
    110: mov     edi,0FFFFFFC8h
    115: call    ryo_h_Resume
    11a: ud2
    11c: mov     rax,[rbp-50h]
    120: add     rax,1
    124: mov     [rbp-78h],rax
    128: mov     [rbp-70h],rax
    12c: jmp     150h
    12e: mov     rax,[rbp-68h]
    132: mov     [rbp-78h],rax
    136: mov     byte ptr [rbp-89h],0
    13d: test    byte ptr [rbp-89h],0FFh
    144: je      17Ch
    146: jmp     172h
    148: nop     [rax+rax]
    150: mov     rax,[rbp-70h]
    154: mov     [rbp-78h],rax
    158: mov     [rbp-58h],rax
    15c: mov     [rbp-8],rax
    160: jmp     0F0h
    162: nop     [rax+rax]
    16b: nop     [rax+rax]
    170: jmp     150h
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-70h],rax
    17a: jmp     170h
    17c: mov     rax,[rbp-50h]
    180: mov     [rbp-88h],rax
    187: mov     qword ptr [rbp-90h],0
    192: mov     rax,[rbp-90h]
    199: sub     rax,[rbp-88h]
    1a0: mov     [rbp-80h],rax
    1a4: mov     rax,[rbp-78h]
    1a8: imul    rcx,[rbp-80h],10h
    1ad: add     rax,rcx
    1b0: mov     [rbp-70h],rax
    1b4: jmp     170h
    1b6: mov     rdi,rax
    1b9: mov     esi,0FFFFFFC8h
    1be: call    ryo_h_Lpad
    1c3: jmp     110h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rax,[rbp+10h]
     1a: mov     rax,[rax+8]
     1e: mov     [rbp-20h],rax
     22: mov     rax,[rax]
     25: mov     [rbp-68h],rax
     29: mov     [rbp-60h],rax
     2d: mov     byte ptr [rbp-89h],0
     34: test    byte ptr [rbp-89h],0FFh
     3b: je      63h
     3d: jmp     51h
     3f: nop
     40: mov     edi,0FFFFFFFFh
     45: mov     esi,1
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+18h]
     55: add     rax,1
     59: mov     [rbp-78h],rax
     5d: mov     [rbp-70h],rax
     61: jmp     80h
     63: mov     rax,[rbp-68h]
     67: mov     [rbp-78h],rax
     6b: mov     byte ptr [rbp-89h],0
     72: test    byte ptr [rbp-89h],0FFh
     79: je      0BCh
     7b: jmp     0B2h
     7d: nop     [rax]
     80: mov     rax,[rbp-70h]
     84: mov     [rbp-48h],rax
     88: mov     byte ptr [rbp-89h],0
     8f: test    byte ptr [rbp-89h],0FFh
     96: je      13Dh
     9c: jmp     133h
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rax,[rbp-90h]
     d9: sub     rax,[rbp-88h]
     e0: mov     [rbp-80h],rax
     e4: mov     rax,[rbp-78h]
     e8: imul    rcx,[rbp-80h],10h
     ed: add     rax,rcx
     f0: mov     [rbp-70h],rax
     f4: jmp     0B0h
     f6: nop     [rax+rax]
     ff: nop
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rax,[rbp-18h]
    110: mov     [rbp-0A0h],rax
    117: mov     rax,[rbp-50h]
    11b: mov     [rbp-98h],rax
    122: call    fn0
    127: nop     [rcx-1]
    12e: jmp     40h
    133: mov     qword ptr [rbp-60h],8
    13b: jmp     100h
    13d: mov     rax,[rbp-48h]
    141: mov     [rbp-68h],rax
    145: mov     byte ptr [rbp-89h],0
    14c: test    byte ptr [rbp-89h],0FFh
    153: je      16Ch
    155: jmp     162h
    157: nop     [rax+rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rax,[rbp-68h]
    17b: imul    rcx,[rbp-90h],10h
    183: add     rax,rcx
    186: mov     [rbp-60h],rax
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     [rbp-78h],rax
     1f: mov     rax,[rbp+10h]
     23: mov     [rbp-70h],rax
     27: lea     rax,[rbp-78h]
     2b: mov     [rbp-68h],rax
     2f: mov     [rbp-60h],rax
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rax,[rbp+18h]
     53: mov     [rbp-0A8h],rax
     5a: mov     edi,0FFFFFF60h
     5f: mov     esi,0FFFFFFA0h
     64: call    ryo_h_MovW128
     69: call    fn1
     6e: nop     [rcx-48h]
     75: mov     rax,[rbp-48h]
     79: mov     [rbp-10h],rax
     7d: mov     edi,0FFFFFFF0h
     82: xor     esi,esi
     84: mov     edx,2
     89: call    ryo_h_SwitchDenseW64
     8e: lea     rcx,[0A0h]
     95: movsxd  rax,[rcx+rax*4]
     99: add     rax,rcx
     9c: jmp     rax
     9e: int3
     9f: int3
     a0: .long   b3h
     a4: .long   bdh
     a8: .long   ach
     ac: call    ryo_h_Unreachable
     b1: ud2
     b3: mov     qword ptr [rbp-8],0
     bb: jmp     0F0h
     bd: mov     rax,[rbp-40h]
     c1: mov     [rbp-50h],rax
     c5: mov     rax,[rbp+10h]
     c9: mov     rax,[rax]
     cc: mov     [rbp-68h],rax
     d0: mov     [rbp-60h],rax
     d4: mov     byte ptr [rbp-89h],0
     db: test    byte ptr [rbp-89h],0FFh
     e2: je      12Eh
     e4: jmp     11Ch
     e6: nop     [rax+rax]
     ef: nop
     f0: mov     edi,0FFFFFFF8h
     f5: mov     esi,8
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: nop     [rax+rax]
    10a: nop     [rax+rax]
    110: mov     edi,0FFFFFFC8h
    115: call    ryo_h_Resume
    11a: ud2
    11c: mov     rax,[rbp-50h]
    120: add     rax,1
    124: mov     [rbp-78h],rax
    128: mov     [rbp-70h],rax
    12c: jmp     150h
    12e: mov     rax,[rbp-68h]
    132: mov     [rbp-78h],rax
    136: mov     byte ptr [rbp-89h],0
    13d: test    byte ptr [rbp-89h],0FFh
    144: je      17Ch
    146: jmp     172h
    148: nop     [rax+rax]
    150: mov     rax,[rbp-70h]
    154: mov     [rbp-78h],rax
    158: mov     [rbp-58h],rax
    15c: mov     [rbp-8],rax
    160: jmp     0F0h
    162: nop     [rax+rax]
    16b: nop     [rax+rax]
    170: jmp     150h
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-70h],rax
    17a: jmp     170h
    17c: mov     rax,[rbp-50h]
    180: mov     [rbp-88h],rax
    187: mov     qword ptr [rbp-90h],0
    192: mov     rax,[rbp-90h]
    199: sub     rax,[rbp-88h]
    1a0: mov     [rbp-80h],rax
    1a4: mov     rax,[rbp-78h]
    1a8: imul    rcx,[rbp-80h],10h
    1ad: add     rax,rcx
    1b0: mov     [rbp-70h],rax
    1b4: jmp     170h
    1b6: mov     rdi,rax
    1b9: mov     esi,0FFFFFFC8h
    1be: call    ryo_h_Lpad
    1c3: jmp     110h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rax,[rbp+10h]
     1a: mov     rax,[rax+8]
     1e: mov     [rbp-20h],rax
     22: mov     rax,[rax]
     25: mov     [rbp-68h],rax
     29: mov     [rbp-60h],rax
     2d: mov     byte ptr [rbp-89h],0
     34: test    byte ptr [rbp-89h],0FFh
     3b: je      63h
     3d: jmp     51h
     3f: nop
     40: mov     edi,0FFFFFFFFh
     45: mov     esi,1
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+18h]
     55: add     rax,1
     59: mov     [rbp-78h],rax
     5d: mov     [rbp-70h],rax
     61: jmp     80h
     63: mov     rax,[rbp-68h]
     67: mov     [rbp-78h],rax
     6b: mov     byte ptr [rbp-89h],0
     72: test    byte ptr [rbp-89h],0FFh
     79: je      0BCh
     7b: jmp     0B2h
     7d: nop     [rax]
     80: mov     rax,[rbp-70h]
     84: mov     [rbp-48h],rax
     88: mov     byte ptr [rbp-89h],0
     8f: test    byte ptr [rbp-89h],0FFh
     96: je      13Dh
     9c: jmp     133h
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rax,[rbp-90h]
     d9: sub     rax,[rbp-88h]
     e0: mov     [rbp-80h],rax
     e4: mov     rax,[rbp-78h]
     e8: imul    rcx,[rbp-80h],10h
     ed: add     rax,rcx
     f0: mov     [rbp-70h],rax
     f4: jmp     0B0h
     f6: nop     [rax+rax]
     ff: nop
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rax,[rbp-18h]
    110: mov     [rbp-0A0h],rax
    117: mov     rax,[rbp-50h]
    11b: mov     [rbp-98h],rax
    122: call    fn0
    127: nop     [rcx-1]
    12e: jmp     40h
    133: mov     qword ptr [rbp-60h],8
    13b: jmp     100h
    13d: mov     rax,[rbp-48h]
    141: mov     [rbp-68h],rax
    145: mov     byte ptr [rbp-89h],0
    14c: test    byte ptr [rbp-89h],0FFh
    153: je      16Ch
    155: jmp     162h
    157: nop     [rax+rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rax,[rbp-68h]
    17b: imul    rcx,[rbp-90h],10h
    183: add     rax,rcx
    186: mov     [rbp-60h],rax
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     [rbp-0B0h],rax
     1a: mov     rax,[rbp+18h]
     1e: mov     [rbp-0A8h],rax
     25: call    fn0
     2a: nop     [rcx-28h]
     31: jmp     52h
     33: nop     [rax+rax]
     3c: nop     [rax]
     40: mov     edi,0FFFFFFA0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: jmp     40h
     52: mov     rax,[rbp+10h]
     56: mov     rax,[rax]
     59: mov     [rbp-80h],rax
     5d: mov     [rbp-78h],rax
     61: imul    rcx,[rbp-28h],1
     66: add     rax,rcx
     69: mov     [rbp-70h],rax
     6d: mov     [rbp-68h],rax
     71: movzx   eax,byte ptr [rax]
     74: mov     [rbp-51h],al
     77: mov     rax,[rbp+18h]
     7b: shr     rax,39h
     7f: mov     [rbp-70h],rax
     83: and     rax,7Fh
     87: mov     [rbp-78h],rax
     8b: mov     edi,0FFFFFF9Eh
     90: mov     esi,0FFFFFF88h
     95: call    ryo_h_TruncW64W8
     9a: movzx   eax,byte ptr [rbp-62h]
     9e: mov     [rbp-61h],al
     a1: mov     rax,[rbp-28h]
     a5: sub     rax,10h
     a9: mov     [rbp-80h],rax
     ad: mov     rax,[rbp+10h]
     b1: mov     rax,[rax+8]
     b5: mov     [rbp-88h],rax
     bc: mov     rax,[rbp-80h]
     c0: and     rax,[rbp-88h]
     c7: mov     [rbp-78h],rax
     cb: add     rax,10h
     cf: mov     [rbp-70h],rax
     d3: mov     rax,[rbp+10h]
     d7: mov     rax,[rax]
     da: mov     [rbp-90h],rax
     e1: mov     [rbp-88h],rax
     e8: imul    rcx,[rbp-28h],1
     ed: add     rax,rcx
     f0: mov     [rbp-80h],rax
     f4: mov     [rbp-78h],rax
     f8: movzx   ecx,byte ptr [rbp-61h]
     fc: mov     [rax],cl
     fe: mov     rax,[rbp+10h]
    102: mov     rax,[rax]
    105: mov     [rbp-90h],rax
    10c: mov     [rbp-88h],rax
    113: imul    rcx,[rbp-70h],1
    118: add     rax,rcx
    11b: mov     [rbp-80h],rax
    11f: mov     [rbp-78h],rax
    123: movzx   ecx,byte ptr [rbp-61h]
    127: mov     [rax],cl
    129: mov     rax,[rbp+10h]
    12d: mov     rax,[rax]
    130: mov     [rbp-70h],rax
    134: mov     [rbp-68h],rax
    138: mov     byte ptr [rbp-91h],0
    13f: test    byte ptr [rbp-91h],0FFh
    146: je      15Ah
    148: mov     rax,[rbp-28h]
    14c: add     rax,1
    150: mov     [rbp-80h],rax
    154: mov     [rbp-78h],rax
    158: jmp     180h
    15a: mov     rax,[rbp-70h]
    15e: mov     [rbp-80h],rax
    162: mov     byte ptr [rbp-91h],0
    169: test    byte ptr [rbp-91h],0FFh
    170: je      20Fh
    176: jmp     205h
    17b: nop     [rax+rax]
    180: mov     rax,[rbp-78h]
    184: mov     [rbp-50h],rax
    188: mov     [rbp-8],rax
    18c: movzx   eax,byte ptr [rbp-51h]
    190: and     al,1
    193: mov     [rbp-6Ah],al
    196: cmp     byte ptr [rbp-6Ah],0
    19a: setne   [rbp-69h]
    19e: mov     edi,0FFFFFF98h
    1a3: mov     esi,0FFFFFF97h
    1a8: call    ryo_h_ZextW8W64
    1ad: mov     rax,[rbp+10h]
    1b1: mov     rax,[rax+10h]
    1b5: mov     [rbp-98h],rax
    1bc: sub     rax,[rbp-68h]
    1c0: mov     [rbp-0A0h],rax
    1c7: mov     rax,[rbp+10h]
    1cb: mov     rcx,[rbp-0A0h]
    1d2: mov     [rax+10h],rcx
    1d6: mov     edi,0FFFFFF90h
    1db: mov     esi,20h
    1e0: call    ryo_h_MovW128
    1e5: mov     byte ptr [rbp-91h],0
    1ec: test    byte ptr [rbp-91h],0FFh
    1f3: je      2A5h
    1f9: jmp     29Bh
    1fe: xchg    ax,ax
    200: jmp     180h
    205: mov     rax,[rbp-80h]
    209: mov     [rbp-78h],rax
    20d: jmp     200h
    20f: mov     rax,[rbp-28h]
    213: mov     [rbp-90h],rax
    21a: mov     qword ptr [rbp-98h],0
    225: mov     rax,[rbp-98h]
    22c: sub     rax,[rbp-90h]
    233: mov     [rbp-88h],rax
    23a: mov     rax,[rbp-80h]
    23e: imul    rcx,[rbp-88h],10h
    246: add     rax,rcx
    249: mov     [rbp-78h],rax
    24d: jmp     200h
    24f: nop
    250: mov     edi,0FFFFFF88h
    255: xor     esi,esi
    257: mov     edx,0FFFFFF90h
    25c: call    ryo_h_StoreW128
    261: mov     rax,[rbp+10h]
    265: mov     rax,[rax+18h]
    269: mov     [rbp-98h],rax
    270: add     rax,1
    274: mov     [rbp-0A0h],rax
    27b: mov     rax,[rbp+10h]
    27f: mov     rcx,[rbp-0A0h]
    286: mov     [rax+18h],rcx
    28a: mov     edi,0FFFFFFF8h
    28f: mov     esi,8
    294: call    ryo_h_Ret
    299: leave
    29a: ret
    29b: mov     qword ptr [rbp-78h],8
    2a3: jmp     250h
    2a5: mov     rax,[rbp-50h]
    2a9: mov     [rbp-80h],rax
    2ad: mov     byte ptr [rbp-91h],0
    2b4: test    byte ptr [rbp-91h],0FFh
    2bb: je      2CCh
    2bd: jmp     2C2h
    2bf: nop
    2c0: jmp     250h
    2c2: mov     rax,[rbp-80h]
    2c6: mov     [rbp-78h],rax
    2ca: jmp     2C0h
    2cc: mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    2d7: mov     rax,[rbp-80h]
    2db: imul    rcx,[rbp-98h],10h
    2e3: add     rax,rcx
    2e6: mov     [rbp-78h],rax
    2ea: jmp     2C0h
    2ec: mov     rdi,rax
    2ef: mov     esi,0FFFFFFA0h
    2f4: call    ryo_h_Lpad
    2f9: jmp     50h

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-38h],rax
     14: cmp     rax,[rbp+18h]
     18: setb    [rbp-29h]
     1c: test    byte ptr [rbp-29h],0FFh
     20: je      0E1h
     26: jmp     0A8h
     2b: nop     [rax+rax]
     30: mov     edi,0FFFFFFBCh
     35: mov     esi,0FFFFFFC8h
     3a: mov     rdx,0FFFFFFFFFFFFFFFFh
     41: xor     ecx,ecx
     43: xor     r8d,r8d
     46: mov     r9d,1
     4c: call    ryo_h_DiscrNicheW64
     51: mov     edi,0FFFFFFC0h
     56: mov     esi,0FFFFFFBCh
     5b: call    ryo_h_ZextW32W64
     60: cmp     qword ptr [rbp-40h],0
     65: sete    [rbp-19h]
     69: nop     [rax]
     70: xor     edi,edi
     72: xor     esi,esi
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFD8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-1],0FFh
     a4: je      80h
     a6: jmp     90h
     a8: mov     byte ptr [rbp-1],0
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-40h],rax
     b4: mov     rax,[rbp+10h]
     b8: mov     [rbp-70h],rax
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-60h],rax
     c4: mov     rax,[rbp-40h]
     c8: mov     [rbp-68h],rax
     cc: mov     byte ptr [rbp-58h],1
     d0: call    fn0
     d5: nop     [rcx-38h]
     dc: jmp     30h
     e1: jmp     70h
     e3: mov     rdi,rax
     e6: mov     esi,0FFFFFFD8h
     eb: call    ryo_h_Lpad
     f0: jmp     0A0h

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: mov     rax,[rbp+10h]
     17: lea     rax,[rax+20h]
     1b: mov     [rbp-28h],rax
     1f: lea     rax,[rbp+18h]
     23: mov     [rbp-50h],rax
     27: mov     [rbp-48h],rax
     2b: lea     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     [rbp-38h],rax
     37: mov     edi,0FFFFFFD0h
     3c: lea     rsi,[k0]
     43: call    ryo_h_AddrAbs
     48: mov     byte ptr [rbp-59h],0
     4c: test    byte ptr [rbp-59h],0FFh
     50: je      6Dh
     52: mov     edi,0FFFFFFA8h
     57: lea     rsi,[sym1]
     5e: call    ryo_h_AddrSym
     63: mov     rax,[rbp-58h]
     67: mov     [rbp-50h],rax
     6b: jmp     75h
     6d: mov     qword ptr [rbp-50h],0
     75: mov     rax,[rbp-20h]
     79: mov     [rbp-0B0h],rax
     80: mov     rax,[rbp-28h]
     84: mov     [rbp-0A8h],rax
     8b: mov     rax,[rbp+20h]
     8f: mov     [rbp-90h],rax
     96: mov     edi,0FFFFFF60h
     9b: mov     esi,0FFFFFFC8h
     a0: call    ryo_h_MovW128
     a5: movzx   eax,byte ptr [rbp+28h]
     a9: mov     [rbp-78h],al
     ac: mov     edi,0FFFFFF78h
     b1: lea     rsi,[k2]
     b8: mov     edx,10h
     bd: call    ryo_h_Const
     c2: mov     rax,[rbp-50h]
     c6: mov     [rbp-70h],rax
     ca: call    fn3
     cf: nop     [rcx-10h]
     d6: mov     edi,0FFFFFFF0h
     db: mov     esi,10h
     e0: call    ryo_h_Ret
     e5: leave
     e6: ret
     e7: nop     [rax+rax]
     f0: mov     edi,0FFFFFFE8h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: mov     rdi,rax
     ff: mov     esi,0FFFFFFE8h
    104: call    ryo_h_Lpad
    109: jmp     0F0h

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rax,[rbp+18h]
     1a: mov     rax,[rax]
     1d: mov     [rbp-60h],rax
     21: mov     [rbp-58h],rax
     25: mov     byte ptr [rbp-81h],0
     2c: test    byte ptr [rbp-81h],0FFh
     33: je      63h
     35: jmp     51h
     37: nop     [rax+rax]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+20h]
     55: add     rax,1
     59: mov     [rbp-70h],rax
     5d: mov     [rbp-68h],rax
     61: jmp     80h
     63: mov     rax,[rbp-60h]
     67: mov     [rbp-70h],rax
     6b: mov     byte ptr [rbp-81h],0
     72: test    byte ptr [rbp-81h],0FFh
     79: je      0ACh
     7b: jmp     0A2h
     7d: nop     [rax]
     80: mov     rax,[rbp-68h]
     84: mov     [rbp-40h],rax
     88: mov     byte ptr [rbp-81h],0
     8f: test    byte ptr [rbp-81h],0FFh
     96: je      11Dh
     9c: jmp     113h
     9e: xchg    ax,ax
     a0: jmp     80h
     a2: mov     rax,[rbp-70h]
     a6: mov     [rbp-68h],rax
     aa: jmp     0A0h
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-80h],rax
     b4: mov     qword ptr [rbp-88h],0
     bf: mov     rax,[rbp-88h]
     c6: sub     rax,[rbp-80h]
     ca: mov     [rbp-78h],rax
     ce: mov     rax,[rbp-70h]
     d2: imul    rcx,[rbp-78h],10h
     d7: add     rax,rcx
     da: mov     [rbp-68h],rax
     de: jmp     0A0h
     e0: mov     rax,[rbp-58h]
     e4: mov     [rbp-50h],rax
     e8: mov     [rbp-48h],rax
     ec: mov     rax,[rbp-18h]
     f0: mov     [rbp-0A0h],rax
     f7: mov     rax,[rbp-48h]
     fb: mov     [rbp-98h],rax
    102: call    fn0
    107: nop     [rcx-8]
    10e: jmp     40h
    113: mov     qword ptr [rbp-58h],8
    11b: jmp     0E0h
    11d: mov     rax,[rbp-40h]
    121: mov     [rbp-60h],rax
    125: mov     byte ptr [rbp-81h],0
    12c: test    byte ptr [rbp-81h],0FFh
    133: je      14Ch
    135: jmp     142h
    137: nop     [rax+rax]
    140: jmp     0E0h
    142: mov     rax,[rbp-60h]
    146: mov     [rbp-58h],rax
    14a: jmp     140h
    14c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    157: mov     rax,[rbp-60h]
    15b: imul    rcx,[rbp-88h],10h
    163: add     rax,rcx
    166: mov     [rbp-58h],rax
    16a: jmp     140h

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],1
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0B2h
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+18h]
     27: mov     [rbp-50h],rax
     2b: cmp     rax,0
     2f: je      0B2h
     35: mov     rax,[rbp+10h]
     39: mov     rax,[rax]
     3c: mov     [rbp-88h],rax
     43: mov     [rbp-58h],rax
     47: mov     byte ptr [rbp-99h],0
     4e: test    byte ptr [rbp-99h],0FFh
     55: je      10Eh
     5b: jmp     101h
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-80h],rax
     68: cmp     rax,0
     6c: je      183h
     72: jmp     190h
     77: nop     [rax+rax]
     80: call    ryo_h_Unreachable
     85: ud2
     87: mov     rax,[rbp-78h]
     8b: mov     [rbp-80h],rax
     8f: mov     byte ptr [rbp-99h],0
     96: test    byte ptr [rbp-99h],0FFh
     9d: je      240h
     a3: jmp     233h
     a8: nop     [rax+rax]
     b0: jmp     0B2h
     b2: xor     edi,edi
     b4: xor     esi,esi
     b6: call    ryo_h_Ret
     bb: leave
     bc: ret
     bd: nop     [rax]
     c0: mov     rax,[rbp+10h]
     c4: mov     rax,[rax+18h]
     c8: mov     [rbp-78h],rax
     cc: mov     edi,0FFFFFFD8h
     d1: mov     esi,0FFFFFF90h
     d6: mov     edx,20h
     db: call    ryo_h_Copy
     e0: mov     rax,[rbp-78h]
     e4: mov     [rbp-8],rax
     e8: mov     edi,0FFFFFF90h
     ed: mov     esi,0FFFFFFD8h
     f2: mov     edx,28h
     f7: call    ryo_h_Copy
     fc: jmp     60h
    101: mov     qword ptr [rbp-90h],1
    10c: jmp     11Ch
    10e: mov     rax,[rbp-88h]
    115: mov     [rbp-90h],rax
    11c: mov     rax,[rbp-90h]
    123: mov     [rbp-60h],rax
    127: mov     [rbp-50h],rax
    12b: mov     rax,[rbp+10h]
    12f: mov     rax,[rax]
    132: mov     [rbp-80h],rax
    136: mov     [rbp-78h],rax
    13a: mov     rax,[rbp+10h]
    13e: mov     rax,[rax+8]
    142: mov     [rbp-98h],rax
    149: add     rax,1
    14d: mov     [rbp-80h],rax
    151: mov     rax,[rbp-78h]
    155: mov     [rbp-0B8h],rax
    15c: mov     rax,[rbp-50h]
    160: mov     [rbp-0C0h],rax
    167: mov     rax,[rbp-80h]
    16b: mov     [rbp-0B0h],rax
    172: call    fn0
    177: nop     [rcx-70h]
    17e: jmp     0C0h
    183: mov     qword ptr [rbp-78h],0
    18b: jmp     0B0h
    190: lea     rax,[rbp-70h]
    194: mov     [rbp-80h],rax
    198: mov     [rbp-0C0h],rax
    19f: call    fn1
    1a4: nop     [rcx-78h]
    1ab: mov     rax,[rbp-50h]
    1af: sub     rax,1
    1b3: mov     [rbp-50h],rax
    1b7: mov     edi,0FFFFFF64h
    1bc: mov     esi,0FFFFFF88h
    1c1: xor     edx,edx
    1c3: xor     ecx,ecx
    1c5: xor     r8d,r8d
    1c8: mov     r9d,1
    1ce: call    ryo_h_DiscrNicheW64
    1d3: mov     edi,0FFFFFFC8h
    1d8: mov     esi,0FFFFFF64h
    1dd: call    ryo_h_ZextW32W64
    1e2: mov     edi,0FFFFFFC8h
    1e7: xor     esi,esi
    1e9: mov     edx,2
    1ee: call    ryo_h_SwitchDenseW64
    1f3: lea     rcx,[204h]
    1fa: movsxd  rax,[rcx+rax*4]
    1fe: add     rax,rcx
    201: jmp     rax
    203: int3
    204: .long   b0h
    208: .long   87h
    20c: .long   80h
    210: mov     rax,[rbp-88h]
    217: mov     [rbp-90h],rax
    21e: mov     [rbp-0C0h],rax
    225: call    fn2
    22a: nop     [rcx-48h]
    231: jmp     2A8h
    233: mov     qword ptr [rbp-88h],8
    23e: jmp     210h
    240: mov     rax,[rbp-80h]
    244: mov     [rbp-98h],rax
    24b: mov     [rbp-90h],rax
    252: mov     byte ptr [rbp-99h],0
    259: test    byte ptr [rbp-99h],0FFh
    260: je      282h
    262: jmp     272h
    264: nop     [rax+rax]
    26d: nop     [rax]
    270: jmp     210h
    272: mov     rax,[rbp-90h]
    279: mov     [rbp-88h],rax
    280: jmp     270h
    282: mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    28d: mov     rax,[rbp-90h]
    294: imul    rcx,[rbp-0A0h],20h
    29c: add     rax,rcx
    29f: mov     [rbp-88h],rax
    2a6: jmp     270h
    2a8: jmp     60h

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],0
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0B2h
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+18h]
     27: mov     [rbp-50h],rax
     2b: cmp     rax,0
     2f: je      0B2h
     35: mov     rax,[rbp+10h]
     39: mov     rax,[rax]
     3c: mov     [rbp-88h],rax
     43: mov     [rbp-58h],rax
     47: mov     byte ptr [rbp-99h],0
     4e: test    byte ptr [rbp-99h],0FFh
     55: je      10Eh
     5b: jmp     101h
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-80h],rax
     68: cmp     rax,0
     6c: je      183h
     72: jmp     190h
     77: nop     [rax+rax]
     80: call    ryo_h_Unreachable
     85: ud2
     87: mov     rax,[rbp-78h]
     8b: mov     [rbp-80h],rax
     8f: mov     byte ptr [rbp-99h],0
     96: test    byte ptr [rbp-99h],0FFh
     9d: je      255h
     a3: jmp     248h
     a8: nop     [rax+rax]
     b0: jmp     0B2h
     b2: xor     edi,edi
     b4: xor     esi,esi
     b6: call    ryo_h_Ret
     bb: leave
     bc: ret
     bd: nop     [rax]
     c0: mov     rax,[rbp+10h]
     c4: mov     rax,[rax+18h]
     c8: mov     [rbp-78h],rax
     cc: mov     edi,0FFFFFFD8h
     d1: mov     esi,0FFFFFF90h
     d6: mov     edx,20h
     db: call    ryo_h_Copy
     e0: mov     rax,[rbp-78h]
     e4: mov     [rbp-8],rax
     e8: mov     edi,0FFFFFF90h
     ed: mov     esi,0FFFFFFD8h
     f2: mov     edx,28h
     f7: call    ryo_h_Copy
     fc: jmp     60h
    101: mov     qword ptr [rbp-90h],1
    10c: jmp     11Ch
    10e: mov     rax,[rbp-88h]
    115: mov     [rbp-90h],rax
    11c: mov     rax,[rbp-90h]
    123: mov     [rbp-60h],rax
    127: mov     [rbp-50h],rax
    12b: mov     rax,[rbp+10h]
    12f: mov     rax,[rax]
    132: mov     [rbp-80h],rax
    136: mov     [rbp-78h],rax
    13a: mov     rax,[rbp+10h]
    13e: mov     rax,[rax+8]
    142: mov     [rbp-98h],rax
    149: add     rax,1
    14d: mov     [rbp-80h],rax
    151: mov     rax,[rbp-78h]
    155: mov     [rbp-0B8h],rax
    15c: mov     rax,[rbp-50h]
    160: mov     [rbp-0C0h],rax
    167: mov     rax,[rbp-80h]
    16b: mov     [rbp-0B0h],rax
    172: call    fn0
    177: nop     [rcx-70h]
    17e: jmp     0C0h
    183: mov     qword ptr [rbp-78h],0
    18b: jmp     0B0h
    190: lea     rax,[rbp-70h]
    194: mov     [rbp-80h],rax
    198: mov     [rbp-0C0h],rax
    19f: call    fn1
    1a4: nop     [rcx-78h]
    1ab: mov     rax,[rbp-50h]
    1af: sub     rax,1
    1b3: mov     [rbp-50h],rax
    1b7: mov     edi,0FFFFFF64h
    1bc: mov     esi,0FFFFFF88h
    1c1: xor     edx,edx
    1c3: xor     ecx,ecx
    1c5: xor     r8d,r8d
    1c8: mov     r9d,1
    1ce: call    ryo_h_DiscrNicheW64
    1d3: mov     edi,0FFFFFFC8h
    1d8: mov     esi,0FFFFFF64h
    1dd: call    ryo_h_ZextW32W64
    1e2: mov     edi,0FFFFFFC8h
    1e7: xor     esi,esi
    1e9: mov     edx,2
    1ee: call    ryo_h_SwitchDenseW64
    1f3: lea     rcx,[204h]
    1fa: movsxd  rax,[rcx+rax*4]
    1fe: add     rax,rcx
    201: jmp     rax
    203: int3
    204: .long   b0h
    208: .long   87h
    20c: .long   80h
    210: mov     rax,[rbp-88h]
    217: mov     [rbp-90h],rax
    21e: mov     [rbp-0C0h],rax
    225: mov     edi,0FFFFFF60h
    22a: lea     rsi,[sym2]
    231: call    ryo_h_AddrSym
    236: mov     rdi,rbp
    239: lea     rsi,[ro+4]
    240: call    qword ptr [sym3]
    246: jmp     2B8h
    248: mov     qword ptr [rbp-88h],8
    253: jmp     210h
    255: mov     rax,[rbp-80h]
    259: mov     [rbp-98h],rax
    260: mov     [rbp-90h],rax
    267: mov     byte ptr [rbp-99h],0
    26e: test    byte ptr [rbp-99h],0FFh
    275: je      292h
    277: jmp     282h
    279: nop     [rax]
    280: jmp     210h
    282: mov     rax,[rbp-90h]
    289: mov     [rbp-88h],rax
    290: jmp     280h
    292: mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    29d: mov     rax,[rbp-90h]
    2a4: imul    rcx,[rbp-0A0h],10h
    2ac: add     rax,rcx
    2af: mov     [rbp-88h],rax
    2b6: jmp     280h
    2b8: jmp     60h

fn hashbrown::raw::RawTableInner::drop_inner_table::<(std::string::String, usize), std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-28h],rax
     17: cmp     rax,0
     1b: sete    [rbp-19h]
     1f: test    byte ptr [rbp-19h],0FFh
     23: jne     80h
     25: mov     rax,[rbp+10h]
     29: mov     [rbp-90h],rax
     30: call    fn0
     35: nop     [rcx]
     3c: mov     rax,[rbp+10h]
     40: mov     rax,[rax+8]
     44: mov     [rbp-50h],rax
     48: add     rax,1
     4c: mov     [rbp-40h],rax
     50: mov     edi,0FFFFFF70h
     55: mov     esi,20h
     5a: call    ryo_h_MovW128
     5f: mov     rax,[rbp-40h]
     63: mov     [rbp-80h],rax
     67: call    fn1
     6c: nop     [rcx-38h]
     73: jmp     92h
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret
     8b: nop     [rax+rax]
     90: jmp     80h
     92: mov     edi,0FFFFFF94h
     97: mov     esi,0FFFFFFC8h
     9c: xor     edx,edx
     9e: xor     ecx,ecx
     a0: xor     r8d,r8d
     a3: mov     r9d,1
     a9: call    ryo_h_DiscrNicheW64
     ae: mov     edi,0FFFFFFC0h
     b3: mov     esi,0FFFFFF94h
     b8: call    ryo_h_ZextW32W64
     bd: cmp     qword ptr [rbp-40h],1
     c2: sete    [rbp-1Ah]
     c6: mov     edi,0FFFFFFA0h
     cb: mov     esi,0FFFFFFC8h
     d0: call    ryo_h_MovW128
     d5: mov     rax,[rbp-28h]
     d9: mov     [rbp-68h],rax
     dd: mov     rax,[rbp+10h]
     e1: mov     rax,[rax]
     e4: mov     [rbp-38h],rax
     e8: mov     [rbp-30h],rax
     ec: mov     rax,[rbp-68h]
     f0: mov     [rbp-40h],rax
     f4: mov     qword ptr [rbp-70h],0
     fc: mov     rax,[rbp-70h]
    100: sub     rax,[rbp-40h]
    104: mov     [rbp-38h],rax
    108: mov     rax,[rbp-30h]
    10c: imul    rcx,[rbp-38h],1
    111: add     rax,rcx
    114: mov     [rbp-28h],rax
    118: mov     [rbp-48h],rax
    11c: mov     rax,[rbp+18h]
    120: mov     [rbp-90h],rax
    127: mov     rax,[rbp-48h]
    12b: mov     [rbp-88h],rax
    132: mov     edi,0FFFFFF80h
    137: mov     esi,0FFFFFFA0h
    13c: call    ryo_h_MovW128
    141: call    fn2
    146: nop     [rcx]
    14d: jmp     90h

fn hashbrown::raw::RawTableInner::drop_inner_table::<(u64, u64), std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-28h],rax
     17: cmp     rax,0
     1b: sete    [rbp-19h]
     1f: test    byte ptr [rbp-19h],0FFh
     23: jne     80h
     25: mov     rax,[rbp+10h]
     29: mov     [rbp-90h],rax
     30: call    fn0
     35: nop     [rcx]
     3c: mov     rax,[rbp+10h]
     40: mov     rax,[rax+8]
     44: mov     [rbp-50h],rax
     48: add     rax,1
     4c: mov     [rbp-40h],rax
     50: mov     edi,0FFFFFF70h
     55: mov     esi,20h
     5a: call    ryo_h_MovW128
     5f: mov     rax,[rbp-40h]
     63: mov     [rbp-80h],rax
     67: call    fn1
     6c: nop     [rcx-38h]
     73: jmp     92h
     75: nop     [rax+rax]
     7e: xchg    ax,ax
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret
     8b: nop     [rax+rax]
     90: jmp     80h
     92: mov     edi,0FFFFFF94h
     97: mov     esi,0FFFFFFC8h
     9c: xor     edx,edx
     9e: xor     ecx,ecx
     a0: xor     r8d,r8d
     a3: mov     r9d,1
     a9: call    ryo_h_DiscrNicheW64
     ae: mov     edi,0FFFFFFC0h
     b3: mov     esi,0FFFFFF94h
     b8: call    ryo_h_ZextW32W64
     bd: cmp     qword ptr [rbp-40h],1
     c2: sete    [rbp-1Ah]
     c6: mov     edi,0FFFFFFA0h
     cb: mov     esi,0FFFFFFC8h
     d0: call    ryo_h_MovW128
     d5: mov     rax,[rbp-28h]
     d9: mov     [rbp-68h],rax
     dd: mov     rax,[rbp+10h]
     e1: mov     rax,[rax]
     e4: mov     [rbp-38h],rax
     e8: mov     [rbp-30h],rax
     ec: mov     rax,[rbp-68h]
     f0: mov     [rbp-40h],rax
     f4: mov     qword ptr [rbp-70h],0
     fc: mov     rax,[rbp-70h]
    100: sub     rax,[rbp-40h]
    104: mov     [rbp-38h],rax
    108: mov     rax,[rbp-30h]
    10c: imul    rcx,[rbp-38h],1
    111: add     rax,rcx
    114: mov     [rbp-28h],rax
    118: mov     [rbp-48h],rax
    11c: mov     rax,[rbp+18h]
    120: mov     [rbp-90h],rax
    127: mov     rax,[rbp-48h]
    12b: mov     [rbp-88h],rax
    132: mov     edi,0FFFFFF80h
    137: mov     esi,0FFFFFFA0h
    13c: call    ryo_h_MovW128
    141: call    fn2
    146: nop     [rcx]
    14d: jmp     90h

fn hashbrown::raw::RawTableInner::erase
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: sub     rax,10h
     13: mov     [rbp-68h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     rax,[rax+8]
     1f: mov     [rbp-70h],rax
     23: mov     rax,[rbp-68h]
     27: and     rax,[rbp-70h]
     2b: mov     [rbp-60h],rax
     2f: mov     rax,[rbp+10h]
     33: mov     rax,[rax]
     36: mov     [rbp-78h],rax
     3a: mov     [rbp-70h],rax
     3e: imul    rcx,[rbp-60h],1
     43: add     rax,rcx
     46: mov     [rbp-20h],rax
     4a: mov     [rbp-68h],rax
     4e: mov     rax,[rbp-20h]
     52: mov     [rbp-70h],rax
     56: mov     [rbp-0C0h],rax
     5d: mov     edi,0FFFFFF70h
     62: lea     rsi,[sym0]
     69: call    ryo_h_AddrSym
     6e: mov     rdi,rbp
     71: lea     rsi,[ro+4]
     78: call    qword ptr [sym1]
     7e: jmp     17Dh
     83: nop     [rax+rax]
     8c: nop     [rax]
     90: mov     byte ptr [rbp-11h],80h
     94: jmp     0CDh
     96: nop     [rax+rax]
     9f: nop
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+10h]
     a8: mov     [rbp-90h],rax
     af: add     rax,1
     b3: mov     [rbp-0A0h],rax
     ba: mov     rax,[rbp+10h]
     be: mov     rcx,[rbp-0A0h]
     c5: mov     [rax+10h],rcx
     c9: mov     byte ptr [rbp-11h],0FFh
     cd: mov     rax,[rbp+18h]
     d1: sub     rax,10h
     d5: mov     [rbp-78h],rax
     d9: mov     rax,[rbp+10h]
     dd: mov     rax,[rax+8]
     e1: mov     [rbp-80h],rax
     e5: mov     rax,[rbp-78h]
     e9: and     rax,[rbp-80h]
     ed: mov     [rbp-70h],rax
     f1: add     rax,10h
     f5: mov     [rbp-68h],rax
     f9: mov     rax,[rbp+10h]
     fd: mov     rax,[rax]
    100: mov     [rbp-88h],rax
    107: mov     [rbp-80h],rax
    10b: imul    rcx,[rbp+18h],1
    110: add     rax,rcx
    113: mov     [rbp-78h],rax
    117: mov     [rbp-70h],rax
    11b: movzx   ecx,byte ptr [rbp-11h]
    11f: mov     [rax],cl
    121: mov     rax,[rbp+10h]
    125: mov     rax,[rax]
    128: mov     [rbp-88h],rax
    12f: mov     [rbp-80h],rax
    133: imul    rcx,[rbp-68h],1
    138: add     rax,rcx
    13b: mov     [rbp-78h],rax
    13f: mov     [rbp-70h],rax
    143: movzx   ecx,byte ptr [rbp-11h]
    147: mov     [rax],cl
    149: mov     rax,[rbp+10h]
    14d: mov     rax,[rax+18h]
    151: mov     [rbp-90h],rax
    158: sub     rax,1
    15c: mov     [rbp-0A0h],rax
    163: mov     rax,[rbp+10h]
    167: mov     rcx,[rbp-0A0h]
    16e: mov     [rax+18h],rcx
    172: xor     edi,edi
    174: xor     esi,esi
    176: call    ryo_h_Ret
    17b: leave
    17c: ret
    17d: mov     byte ptr [rbp-0C0h],0FFh
    184: mov     edi,0FFFFFF70h
    189: lea     rsi,[sym2]
    190: call    ryo_h_AddrSym
    195: mov     rdi,rbp
    198: lea     rsi,[ro+20]
    19f: call    qword ptr [sym3]
    1a5: mov     edi,0FFFFFF40h
    1aa: mov     esi,0FFFFFFD0h
    1af: call    ryo_h_MovW128
    1b4: mov     edi,0FFFFFF50h
    1b9: mov     esi,0FFFFFF80h
    1be: call    ryo_h_MovW128
    1c3: mov     edi,0FFFFFF70h
    1c8: lea     rsi,[sym4]
    1cf: call    ryo_h_AddrSym
    1d4: mov     rdi,rbp
    1d7: lea     rsi,[ro+36]
    1de: call    qword ptr [sym5]
    1e4: mov     edi,0FFFFFF40h
    1e9: mov     esi,0FFFFFF90h
    1ee: call    ryo_h_MovW128
    1f3: mov     edi,0FFFFFF70h
    1f8: lea     rsi,[sym6]
    1ff: call    ryo_h_AddrSym
    204: mov     rdi,rbp
    207: lea     rsi,[ro+52]
    20e: call    qword ptr [sym7]
    214: mov     edi,0FFFFFFCEh
    219: mov     esi,0FFFFFF8Ch
    21e: call    ryo_h_TruncW32W16
    223: mov     rax,[rbp+10h]
    227: mov     rax,[rax]
    22a: mov     [rbp-78h],rax
    22e: mov     [rbp-70h],rax
    232: imul    rcx,[rbp+18h],1
    237: add     rax,rcx
    23a: mov     [rbp-40h],rax
    23e: mov     [rbp-68h],rax
    242: mov     rax,[rbp-40h]
    246: mov     [rbp-70h],rax
    24a: mov     [rbp-0C0h],rax
    251: mov     edi,0FFFFFF70h
    256: lea     rsi,[sym8]
    25d: call    ryo_h_AddrSym
    262: mov     rdi,rbp
    265: lea     rsi,[ro+68]
    26c: call    qword ptr [sym9]
    272: mov     byte ptr [rbp-0C0h],0FFh
    279: mov     edi,0FFFFFF70h
    27e: lea     rsi,[sym10]
    285: call    ryo_h_AddrSym
    28a: mov     rdi,rbp
    28d: lea     rsi,[ro+20]
    294: call    qword ptr [sym11]
    29a: mov     edi,0FFFFFF40h
    29f: mov     esi,0FFFFFFB0h
    2a4: call    ryo_h_MovW128
    2a9: mov     edi,0FFFFFF50h
    2ae: mov     esi,0FFFFFF80h
    2b3: call    ryo_h_MovW128
    2b8: mov     edi,0FFFFFF70h
    2bd: lea     rsi,[sym12]
    2c4: call    ryo_h_AddrSym
    2c9: mov     rdi,rbp
    2cc: lea     rsi,[ro+36]
    2d3: call    qword ptr [sym13]
    2d9: mov     edi,0FFFFFF40h
    2de: mov     esi,0FFFFFF90h
    2e3: call    ryo_h_MovW128
    2e8: mov     edi,0FFFFFF70h
    2ed: lea     rsi,[sym14]
    2f4: call    ryo_h_AddrSym
    2f9: mov     rdi,rbp
    2fc: lea     rsi,[ro+52]
    303: call    qword ptr [sym15]
    309: mov     edi,0FFFFFFAEh
    30e: mov     esi,0FFFFFF8Ch
    313: call    ryo_h_TruncW32W16
    318: mov     edi,0FFFFFF74h
    31d: mov     esi,0FFFFFFCEh
    322: call    ryo_h_CtlzW16
    327: mov     eax,[rbp-8Ch]
    32d: mov     [rbp-74h],eax
    330: mov     edi,0FFFFFF90h
    335: mov     esi,0FFFFFF8Ch
    33a: call    ryo_h_ZextW32W64
    33f: mov     edi,0FFFFFF74h
    344: mov     esi,0FFFFFFAEh
    349: call    ryo_h_CttzW16
    34e: mov     eax,[rbp-8Ch]
    354: mov     [rbp-7Ch],eax
    357: mov     edi,0FFFFFF88h
    35c: mov     esi,0FFFFFF84h
    361: call    ryo_h_ZextW32W64
    366: mov     rax,[rbp-70h]
    36a: add     rax,[rbp-78h]
    36e: mov     [rbp-68h],rax
    372: cmp     rax,10h
    376: jae     90h
    37c: jmp     0A0h

fn hashbrown::raw::RawTableInner::fallible_with_capacity::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,100h
      b: cmp     qword ptr [rbp+28h],0
     10: jne     2Dh
     12: mov     edi,0FFFFFFE0h
     17: lea     rsi,[k0]
     1e: mov     edx,20h
     23: call    ryo_h_Const
     28: jmp     100h
     2d: mov     rax,[rbp+28h]
     31: mov     [rbp-100h],rax
     38: mov     edi,0FFFFFF08h
     3d: mov     esi,18h
     42: call    ryo_h_MovW128
     47: call    fn1
     4c: nop     [rcx-90h]
     53: mov     rax,[rbp-90h]
     5a: mov     [rbp-98h],rax
     61: mov     edi,0FFFFFF68h
     66: xor     esi,esi
     68: mov     edx,2
     6d: call    ryo_h_SwitchDenseW64
     72: lea     rcx,[84h]
     79: movsxd  rax,[rcx+rax*4]
     7d: add     rax,rcx
     80: jmp     rax
     82: int3
     83: int3
     84: .long   121h
     88: .long   165h
     8c: .long   90h
     90: call    ryo_h_Unreachable
     95: ud2
     97: nop     [rax+rax]
     a0: mov     edi,0FFFFFF34h
     a5: mov     esi,0FFFFFF60h
     aa: xor     edx,edx
     ac: mov     ecx,1
     b1: mov     r8d,1
     b7: xor     r9d,r9d
     ba: call    ryo_h_DiscrNicheW64
     bf: mov     edi,0FFFFFF58h
     c4: mov     esi,0FFFFFF34h
     c9: call    ryo_h_ZextW32W64
     ce: mov     edi,0FFFFFF58h
     d3: xor     esi,esi
     d5: mov     edx,2
     da: call    ryo_h_SwitchDenseW64
     df: lea     rcx,[0F0h]
     e6: movsxd  rax,[rcx+rax*4]
     ea: add     rax,rcx
     ed: jmp     rax
     ef: int3
     f0: .long   2efh
     f4: .long   266h
     f8: .long   90h
     fc: nop     [rax]
    100: jmp     110h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: mov     edi,0FFFFFFE0h
    115: mov     esi,20h
    11a: call    ryo_h_Ret
    11f: leave
    120: ret
    121: movzx   eax,byte ptr [rbp+30h]
    125: mov     [rbp-100h],al
    12b: lea     rdi,[sym2]
    132: lea     rsi,[site3]
    139: mov     edx,0FFFFFF30h
    13e: call    ryo_h_CallExt
    143: test    rax,rax
    146: je      153h
    148: call    rax
    14a: nop     [rcx-0A8h]
    151: jmp     163h
    153: mov     rdi,rbp
    156: lea     rsi,[ro+4]
    15d: call    qword ptr [sym4]
    163: jmp     1D6h
    165: mov     rax,[rbp-88h]
    16c: mov     [rbp-0A0h],rax
    173: mov     [rbp-78h],rax
    177: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    17f: mov     [rbp-88h],rax
    186: mov     [rbp-68h],rax
    18a: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    192: mov     [rbp-30h],rax
    196: mov     rax,[rbp+10h]
    19a: mov     [rbp-100h],rax
    1a1: mov     edi,0FFFFFF08h
    1a6: mov     esi,18h
    1ab: call    ryo_h_MovW128
    1b0: mov     rax,[rbp-30h]
    1b4: mov     [rbp-0E8h],rax
    1bb: movzx   eax,byte ptr [rbp+30h]
    1bf: mov     [rbp-0E0h],al
    1c5: call    fn5
    1ca: nop     [rcx-0A0h]
    1d1: jmp     0A0h
    1d6: mov     edi,0FFFFFF80h
    1db: mov     esi,0FFFFFF58h
    1e0: call    ryo_h_MovW128
    1e5: mov     edi,0FFFFFF70h
    1ea: mov     esi,0FFFFFF80h
    1ef: call    ryo_h_MovW128
    1f4: mov     edi,0FFFFFF60h
    1f9: mov     esi,0FFFFFF70h
    1fe: call    ryo_h_MovW128
    203: mov     edi,0FFFFFF90h
    208: mov     esi,0FFFFFF60h
    20d: call    ryo_h_MovW128
    212: mov     edi,0FFFFFF80h
    217: mov     esi,0FFFFFF90h
    21c: call    ryo_h_MovW128
    221: mov     qword ptr [rbp-88h],1
    22c: cmp     qword ptr [rbp-88h],1
    234: sete    [rbp-99h]
    23b: mov     edi,0FFFFFF68h
    240: mov     esi,0FFFFFF80h
    245: call    ryo_h_MovW128
    24a: mov     edi,0FFFFFFE8h
    24f: mov     esi,0FFFFFF68h
    254: call    ryo_h_MovW128
    259: mov     qword ptr [rbp-20h],0
    261: jmp     110h
    266: mov     edi,0FFFFFF48h
    26b: mov     esi,0FFFFFF68h
    270: call    ryo_h_MovW128
    275: mov     edi,0FFFFFF38h
    27a: mov     esi,0FFFFFF48h
    27f: call    ryo_h_MovW128
    284: mov     edi,0FFFFFF88h
    289: mov     esi,0FFFFFF38h
    28e: call    ryo_h_MovW128
    293: mov     qword ptr [rbp-80h],0
    29b: mov     edi,0FFFFFF70h
    2a0: mov     esi,0FFFFFF88h
    2a5: call    ryo_h_MovW128
    2aa: mov     qword ptr [rbp-98h],1
    2b5: cmp     qword ptr [rbp-98h],1
    2bd: sete    [rbp-0A9h]
    2c4: mov     edi,0FFFFFF58h
    2c9: mov     esi,0FFFFFF70h
    2ce: call    ryo_h_MovW128
    2d3: mov     edi,0FFFFFFE8h
    2d8: mov     esi,0FFFFFF58h
    2dd: call    ryo_h_MovW128
    2e2: mov     qword ptr [rbp-20h],0
    2ea: jmp     110h
    2ef: mov     edi,0FFFFFF38h
    2f4: mov     esi,0FFFFFF60h
    2f9: mov     edx,20h
    2fe: call    ryo_h_Copy
    303: mov     edi,0FFFFFF80h
    308: mov     esi,0FFFFFF38h
    30d: mov     edx,20h
    312: call    ryo_h_Copy
    317: mov     edi,0FFFFFFB0h
    31c: mov     esi,0FFFFFF80h
    321: mov     edx,20h
    326: call    ryo_h_Copy
    32b: mov     rax,[rbp-50h]
    32f: mov     [rbp-80h],rax
    333: mov     [rbp-78h],rax
    337: mov     rax,[rbp-48h]
    33b: mov     [rbp-90h],rax
    342: add     rax,1
    346: mov     [rbp-88h],rax
    34d: add     rax,10h
    351: mov     [rbp-60h],rax
    355: mov     rax,[rbp-78h]
    359: mov     [rbp-90h],rax
    360: mov     rax,[rbp-60h]
    364: mov     [rbp-88h],rax
    36b: mov     rax,[rbp-90h]
    372: mov     [rbp-70h],rax
    376: mov     rax,[rbp-88h]
    37d: mov     [rbp-68h],rax
    381: mov     rax,[rbp-70h]
    385: mov     [rbp-88h],rax
    38c: mov     rax,[rbp-68h]
    390: mov     [rbp-80h],rax
    394: mov     rax,[rbp-88h]
    39b: mov     [rbp-78h],rax
    39f: mov     byte ptr [rbp-0C9h],0FFh
    3a6: imul    rax,[rbp-60h],1
    3ab: mov     [rbp-0D8h],rax
    3b2: mov     edi,0FFFFFF88h
    3b7: mov     esi,0FFFFFF37h
    3bc: mov     edx,0FFFFFF28h
    3c1: call    ryo_h_Memset
    3c6: mov     edi,0FFFFFFE0h
    3cb: mov     esi,0FFFFFFB0h
    3d0: mov     edx,20h
    3d5: call    ryo_h_Copy
    3da: jmp     100h

fn hashbrown::raw::RawTableInner::find_inner
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: shr     rax,39h
     13: mov     [rbp-78h],rax
     17: and     rax,7Fh
     1b: mov     [rbp-80h],rax
     1f: mov     edi,0FFFFFFD7h
     24: mov     esi,0FFFFFF80h
     29: call    ryo_h_TruncW64W8
     2e: mov     rax,[rbp+18h]
     32: mov     [rbp-90h],rax
     39: mov     rax,[rbp+10h]
     3d: mov     rax,[rax+8]
     41: mov     [rbp-98h],rax
     48: mov     rax,[rbp-90h]
     4f: and     rax,[rbp-98h]
     56: mov     [rbp-88h],rax
     5d: mov     [rbp-80h],rax
     61: mov     qword ptr [rbp-78h],0
     69: nop     [rax]
     70: mov     rax,[rbp-80h]
     74: mov     [rbp-90h],rax
     7b: mov     rax,[rbp+10h]
     7f: mov     rax,[rax]
     82: mov     [rbp-0A0h],rax
     89: mov     [rbp-98h],rax
     90: imul    rcx,[rbp-90h],1
     98: add     rax,rcx
     9b: mov     [rbp-38h],rax
     9f: mov     [rbp-88h],rax
     a6: mov     rax,[rbp-38h]
     aa: mov     [rbp-90h],rax
     b1: mov     [rbp-0E0h],rax
     b8: mov     edi,0FFFFFF40h
     bd: lea     rsi,[sym0]
     c4: call    ryo_h_AddrSym
     c9: mov     rdi,rbp
     cc: lea     rsi,[ro+4]
     d3: call    qword ptr [sym1]
     d9: jmp     171h
     de: xchg    ax,ax
     e0: movzx   eax,word ptr [rbp-12h]
     e4: mov     [rbp-0B6h],ax
     eb: mov     [rbp-6Ch],ax
     ef: mov     edi,0FFFFFF44h
     f4: mov     esi,0FFFFFF94h
     f9: xor     edx,edx
     fb: xor     ecx,ecx
     fd: xor     r8d,r8d
    100: mov     r9d,1
    106: call    ryo_h_DiscrNicheW16
    10b: mov     edi,0FFFFFF58h
    110: mov     esi,0FFFFFF44h
    115: call    ryo_h_ZextW32W64
    11a: mov     edi,0FFFFFF58h
    11f: xor     esi,esi
    121: mov     edx,2
    126: call    ryo_h_SwitchDenseW64
    12b: lea     rcx,[13Ch]
    132: movsxd  rax,[rcx+rax*4]
    136: add     rax,rcx
    139: jmp     rax
    13b: int3
    13c: .long   257h
    140: .long   22eh
    144: .long   148h
    148: call    ryo_h_Unreachable
    14d: ud2
    14f: nop
    150: test    byte ptr [rbp-6Bh],0FFh
    154: je      471h
    15a: jmp     459h
    15f: nop
    160: mov     edi,0FFFFFFF0h
    165: mov     esi,10h
    16a: call    ryo_h_Ret
    16f: leave
    170: ret
    171: movzx   eax,byte ptr [rbp-29h]
    175: mov     [rbp-6Dh],al
    178: mov     [rbp-0E0h],al
    17e: mov     edi,0FFFFFF40h
    183: lea     rsi,[sym2]
    18a: call    ryo_h_AddrSym
    18f: mov     rdi,rbp
    192: lea     rsi,[ro+20]
    199: call    qword ptr [sym3]
    19f: mov     edi,0FFFFFF20h
    1a4: mov     esi,0FFFFFFB0h
    1a9: call    ryo_h_MovW128
    1ae: mov     edi,0FFFFFF30h
    1b3: mov     esi,0FFFFFF60h
    1b8: call    ryo_h_MovW128
    1bd: mov     edi,0FFFFFF40h
    1c2: lea     rsi,[sym4]
    1c9: call    ryo_h_AddrSym
    1ce: mov     rdi,rbp
    1d1: lea     rsi,[ro+36]
    1d8: call    qword ptr [sym5]
    1de: mov     edi,0FFFFFF20h
    1e3: mov     esi,0FFFFFF70h
    1e8: call    ryo_h_MovW128
    1ed: mov     edi,0FFFFFF40h
    1f2: lea     rsi,[sym6]
    1f9: call    ryo_h_AddrSym
    1fe: mov     rdi,rbp
    201: lea     rsi,[ro+52]
    208: call    qword ptr [sym7]
    20e: mov     edi,0FFFFFF92h
    213: mov     esi,0FFFFFF6Ch
    218: call    ryo_h_TruncW32W16
    21d: movzx   eax,word ptr [rbp-6Eh]
    221: mov     [rbp-6Ch],ax
    225: mov     [rbp-12h],ax
    229: jmp     0E0h
    22e: movzx   eax,word ptr [rbp-6Ch]
    232: mov     [rbp-6Eh],ax
    236: mov     [rbp-70h],ax
    23a: mov     edi,0FFFFFF44h
    23f: mov     esi,0FFFFFF90h
    244: call    ryo_h_CttzW16
    249: mov     eax,[rbp-0BCh]
    24f: mov     [rbp-0B4h],eax
    255: jmp     2B1h
    257: mov     edi,0FFFFFF60h
    25c: lea     rsi,[k8]
    263: mov     edx,10h
    268: call    ryo_h_Const
    26d: mov     qword ptr [rbp-98h],0
    278: cmp     qword ptr [rbp-98h],0
    280: sete    [rbp-6Bh]
    284: mov     byte ptr [rbp-0E0h],0FFh
    28b: mov     edi,0FFFFFF40h
    290: lea     rsi,[sym9]
    297: call    ryo_h_AddrSym
    29c: mov     rdi,rbp
    29f: lea     rsi,[ro+20]
    2a6: call    qword ptr [sym10]
    2ac: jmp     3C9h
    2b1: mov     edi,0FFFFFF50h
    2b6: mov     esi,0FFFFFF4Ch
    2bb: call    ryo_h_ZextW32W64
    2c0: mov     rax,[rbp-0B0h]
    2c7: mov     [rbp-98h],rax
    2ce: mov     qword ptr [rbp-0A0h],1
    2d9: mov     [rbp-68h],rax
    2dd: movzx   eax,word ptr [rbp-12h]
    2e1: mov     [rbp-92h],ax
    2e8: sub     eax,1
    2eb: mov     [rbp-70h],ax
    2ef: movzx   eax,word ptr [rbp-92h]
    2f6: and     ax,[rbp-70h]
    2fa: mov     [rbp-6Eh],ax
    2fe: movzx   eax,word ptr [rbp-6Eh]
    302: mov     [rbp-6Ch],ax
    306: mov     [rbp-12h],ax
    30a: mov     rax,[rbp-68h]
    30e: mov     [rbp-88h],rax
    315: mov     qword ptr [rbp-90h],1
    320: mov     [rbp-98h],rax
    327: mov     rax,[rbp-80h]
    32b: mov     [rbp-0B0h],rax
    332: add     rax,[rbp-98h]
    339: mov     [rbp-0A8h],rax
    340: mov     rax,[rbp+10h]
    344: mov     rax,[rax+8]
    348: mov     [rbp-0B0h],rax
    34f: mov     rax,[rbp-0A8h]
    356: and     rax,[rbp-0B0h]
    35d: mov     [rbp-0A0h],rax
    364: mov     [rbp-0A8h],rax
    36b: mov     rax,[rbp+28h]
    36f: mov     rax,[rax+20h]
    373: mov     [rbp-0C0h],rax
    37a: mov     rax,[rbp+20h]
    37e: mov     [rbp-0E0h],rax
    385: mov     rax,[rbp-0A8h]
    38c: mov     [rbp-0D8h],rax
    393: mov     edi,0FFFFFF40h
    398: lea     rsi,[site11]
    39f: call    ryo_h_CallInd
    3a4: test    rax,rax
    3a7: je      3B4h
    3a9: call    rax
    3ab: nop     [rcx-6Bh]
    3b2: jmp     3C4h
    3b4: mov     rdi,rbp
    3b7: lea     rsi,[ro+68]
    3be: call    qword ptr [sym12]
    3c4: jmp     150h
    3c9: mov     edi,0FFFFFF20h
    3ce: mov     esi,0FFFFFFB0h
    3d3: call    ryo_h_MovW128
    3d8: mov     edi,0FFFFFF30h
    3dd: mov     esi,0FFFFFF60h
    3e2: call    ryo_h_MovW128
    3e7: mov     edi,0FFFFFF40h
    3ec: lea     rsi,[sym13]
    3f3: call    ryo_h_AddrSym
    3f8: mov     rdi,rbp
    3fb: lea     rsi,[ro+36]
    402: call    qword ptr [sym14]
    408: mov     edi,0FFFFFF20h
    40d: mov     esi,0FFFFFF70h
    412: call    ryo_h_MovW128
    417: mov     edi,0FFFFFF40h
    41c: lea     rsi,[sym15]
    423: call    ryo_h_AddrSym
    428: mov     rdi,rbp
    42b: lea     rsi,[ro+84]
    432: call    qword ptr [sym16]
    438: mov     edi,0FFFFFF96h
    43d: mov     esi,0FFFFFF90h
    442: call    ryo_h_TruncW32W16
    447: cmp     word ptr [rbp-6Ah],0
    44c: setne   [rbp-6Bh]
    450: cmp     word ptr [rbp-6Ah],0
    455: je      491h
    457: jmp     476h
    459: mov     rax,[rbp-0A0h]
    460: mov     [rbp-8],rax
    464: mov     qword ptr [rbp-10h],1
    46c: jmp     160h
    471: jmp     0E0h
    476: mov     edi,0FFFFFFF0h
    47b: lea     rsi,[k17]
    482: mov     edx,10h
    487: call    ryo_h_Const
    48c: jmp     160h
    491: mov     rax,[rbp+10h]
    495: mov     rax,[rax+8]
    499: mov     [rbp-88h],rax
    4a0: mov     rax,[rbp-78h]
    4a4: add     rax,10h
    4a8: mov     [rbp-78h],rax
    4ac: mov     [rbp-90h],rax
    4b3: mov     rax,[rbp-80h]
    4b7: add     rax,[rbp-90h]
    4be: mov     [rbp-80h],rax
    4c2: and     rax,[rbp-88h]
    4c9: mov     [rbp-80h],rax
    4cd: jmp     70h

fn hashbrown::raw::RawTableInner::find_insert_index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-50h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+8]
     1b: mov     [rbp-58h],rax
     1f: mov     rax,[rbp-50h]
     23: and     rax,[rbp-58h]
     27: mov     [rbp-48h],rax
     2b: mov     [rbp-40h],rax
     2f: mov     qword ptr [rbp-38h],0
     37: nop     [rax+rax]
     40: mov     rax,[rbp-40h]
     44: mov     [rbp-60h],rax
     48: mov     rax,[rbp+10h]
     4c: mov     rax,[rax]
     4f: mov     [rbp-70h],rax
     53: mov     [rbp-68h],rax
     57: imul    rcx,[rbp-60h],1
     5c: add     rax,rcx
     5f: mov     [rbp-20h],rax
     63: mov     [rbp-58h],rax
     67: mov     rax,[rbp-20h]
     6b: mov     [rbp-60h],rax
     6f: mov     [rbp-90h],rax
     76: mov     edi,0FFFFFF88h
     7b: lea     rsi,[sym0]
     82: call    ryo_h_AddrSym
     87: mov     rdi,rbp
     8a: lea     rsi,[ro+4]
     91: call    qword ptr [sym1]
     97: jmp     0D1h
     99: nop     [rax]
     a0: mov     rax,[rbp-60h]
     a4: mov     [rbp-28h],rax
     a8: cmp     rax,1
     ac: sete    [rbp-2Ah]
     b0: cmp     rax,1
     b4: je      11Ch
     b6: jmp     154h
     bb: nop     [rax+rax]
     c0: mov     edi,0FFFFFFF8h
     c5: mov     esi,8
     ca: call    ryo_h_Ret
     cf: leave
     d0: ret
     d1: mov     edi,0FFFFFFB0h
     d6: mov     esi,0FFFFFF90h
     db: call    ryo_h_MovW128
     e0: lea     rax,[rbp-50h]
     e4: mov     [rbp-68h],rax
     e8: lea     rax,[rbp-40h]
     ec: mov     [rbp-70h],rax
     f0: mov     rax,[rbp+10h]
     f4: mov     [rbp-90h],rax
     fb: mov     rax,[rbp-68h]
     ff: mov     [rbp-88h],rax
    106: mov     rax,[rbp-70h]
    10a: mov     [rbp-80h],rax
    10e: call    fn2
    113: nop     [rcx-60h]
    11a: jmp     0A0h
    11c: cmp     qword ptr [rbp-28h],1
    121: sete    [rbp-29h]
    125: mov     rax,[rbp-58h]
    129: mov     [rbp-68h],rax
    12d: mov     rax,[rbp+10h]
    131: mov     [rbp-90h],rax
    138: mov     rax,[rbp-68h]
    13c: mov     [rbp-88h],rax
    143: call    fn3
    148: nop     [rcx-8]
    14f: jmp     0C0h
    154: mov     rax,[rbp+10h]
    158: mov     rax,[rax+8]
    15c: mov     [rbp-68h],rax
    160: mov     rax,[rbp-38h]
    164: add     rax,10h
    168: mov     [rbp-38h],rax
    16c: mov     [rbp-70h],rax
    170: mov     rax,[rbp-40h]
    174: add     rax,[rbp-70h]
    178: mov     [rbp-40h],rax
    17c: and     rax,[rbp-68h]
    180: mov     [rbp-40h],rax
    184: jmp     40h

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     edi,0FFFFFFB0h
      d: mov     esi,18h
     12: xor     edx,edx
     14: call    ryo_h_LoadW128
     19: mov     edi,0FFFFFF90h
     1e: mov     esi,0FFFFFFB0h
     23: call    ryo_h_MovW128
     28: mov     edi,0FFFFFFA0h
     2d: lea     rsi,[sym0]
     34: call    ryo_h_AddrSym
     39: mov     rdi,rbp
     3c: lea     rsi,[ro+4]
     43: call    qword ptr [sym1]
     49: jmp     61h
     4b: nop     [rax+rax]
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,10h
     5a: call    ryo_h_Ret
     5f: leave
     60: ret
     61: mov     edi,0FFFFFFD6h
     66: mov     esi,0FFFFFFC8h
     6b: call    ryo_h_TruncW32W16
     70: movzx   eax,word ptr [rbp-2Ah]
     74: mov     [rbp-36h],ax
     78: mov     edi,0FFFFFFA4h
     7d: mov     esi,0FFFFFFCAh
     82: xor     edx,edx
     84: xor     ecx,ecx
     86: xor     r8d,r8d
     89: mov     r9d,1
     8f: call    ryo_h_DiscrNicheW16
     94: mov     edi,0FFFFFFC0h
     99: mov     esi,0FFFFFFA4h
     9e: call    ryo_h_ZextW32W64
     a3: mov     edi,0FFFFFFC0h
     a8: xor     esi,esi
     aa: mov     edx,2
     af: call    ryo_h_SwitchDenseW64
     b4: lea     rcx,[0C4h]
     bb: movsxd  rax,[rcx+rax*4]
     bf: add     rax,rcx
     c2: jmp     rax
     c4: .long   f3h
     c8: .long   d0h
     cc: .long   192h
     d0: movzx   eax,word ptr [rbp-36h]
     d4: mov     [rbp-38h],ax
     d8: mov     [rbp-4Eh],ax
     dc: mov     edi,0FFFFFFA4h
     e1: mov     esi,0FFFFFFB2h
     e6: call    ryo_h_CttzW16
     eb: mov     eax,[rbp-5Ch]
     ee: mov     [rbp-4Ch],eax
     f1: jmp     11Bh
     f3: mov     edi,0FFFFFFE0h
     f8: lea     rsi,[k2]
     ff: mov     edx,10h
    104: call    ryo_h_Const
    109: mov     rax,[rbp-20h]
    10d: mov     [rbp-40h],rax
    111: cmp     rax,1
    115: sete    [rbp-35h]
    119: jmp     199h
    11b: mov     edi,0FFFFFFB8h
    120: mov     esi,0FFFFFFB4h
    125: call    ryo_h_ZextW32W64
    12a: mov     rax,[rbp-48h]
    12e: mov     [rbp-18h],rax
    132: mov     qword ptr [rbp-20h],1
    13a: mov     rax,[rbp-20h]
    13e: mov     [rbp-40h],rax
    142: cmp     rax,1
    146: sete    [rbp-35h]
    14a: mov     rax,[rbp+20h]
    14e: mov     rax,[rax]
    151: mov     [rbp-50h],rax
    155: mov     rax,[rbp-18h]
    159: mov     [rbp-58h],rax
    15d: mov     rax,[rbp-50h]
    161: add     rax,[rbp-58h]
    165: mov     [rbp-48h],rax
    169: mov     rax,[rbp+10h]
    16d: mov     rax,[rax+8]
    171: mov     [rbp-50h],rax
    175: mov     rax,[rbp-48h]
    179: and     rax,[rbp-50h]
    17d: mov     [rbp-40h],rax
    181: mov     [rbp-8],rax
    185: mov     qword ptr [rbp-10h],1
    18d: jmp     50h
    192: call    ryo_h_Unreachable
    197: ud2
    199: mov     edi,0FFFFFFF0h
    19e: lea     rsi,[k3]
    1a5: mov     edx,10h
    1aa: call    ryo_h_Const
    1af: jmp     50h

fn hashbrown::raw::RawTableInner::fix_insert_index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-58h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax]
     1a: mov     [rbp-78h],rax
     1e: mov     [rbp-70h],rax
     22: imul    rcx,[rbp-58h],1
     27: add     rax,rcx
     2a: mov     [rbp-68h],rax
     2e: mov     [rbp-60h],rax
     32: movzx   eax,byte ptr [rax]
     35: mov     [rbp-50h],al
     38: and     al,80h
     3b: mov     [rbp-4Fh],al
     3e: cmp     byte ptr [rbp-4Fh],0
     42: sete    [rbp-4Eh]
     46: test    byte ptr [rbp-4Eh],0FFh
     4a: je      0AAh
     4c: jmp     69h
     4e: xchg    ax,ax
     50: mov     rax,[rbp+18h]
     54: mov     [rbp-8],rax
     58: mov     edi,0FFFFFFF8h
     5d: mov     esi,8
     62: call    ryo_h_Ret
     67: leave
     68: ret
     69: mov     rax,[rbp+10h]
     6d: mov     rax,[rax]
     70: mov     [rbp-10h],rax
     74: mov     [rbp-68h],rax
     78: mov     rax,[rbp-10h]
     7c: mov     [rbp-70h],rax
     80: mov     [rbp-90h],rax
     87: mov     edi,0FFFFFF80h
     8c: lea     rsi,[sym0]
     93: call    ryo_h_AddrSym
     98: mov     rdi,rbp
     9b: lea     rsi,[ro+4]
     a2: call    qword ptr [sym1]
     a8: jmp     0ACh
     aa: jmp     50h
     ac: mov     edi,0FFFFFF70h
     b1: mov     esi,0FFFFFFC0h
     b6: call    ryo_h_MovW128
     bb: mov     edi,0FFFFFF80h
     c0: lea     rsi,[sym2]
     c7: call    ryo_h_AddrSym
     cc: mov     rdi,rbp
     cf: lea     rsi,[ro+20]
     d6: call    qword ptr [sym3]
     dc: mov     edi,0FFFFFFBEh
     e1: mov     esi,0FFFFFF9Ch
     e6: call    ryo_h_TruncW32W16
     eb: movzx   eax,word ptr [rbp-42h]
     ef: mov     [rbp-50h],ax
     f3: mov     edi,0FFFFFF84h
     f8: mov     esi,0FFFFFFB0h
     fd: xor     edx,edx
     ff: xor     ecx,ecx
    101: xor     r8d,r8d
    104: mov     r9d,1
    10a: call    ryo_h_DiscrNicheW16
    10f: mov     edi,0FFFFFF98h
    114: mov     esi,0FFFFFF84h
    119: call    ryo_h_ZextW32W64
    11e: mov     edi,0FFFFFF98h
    123: xor     esi,esi
    125: mov     edx,2
    12a: call    ryo_h_SwitchDenseW64
    12f: lea     rcx,[140h]
    136: movsxd  rax,[rcx+rax*4]
    13a: add     rax,rcx
    13d: jmp     rax
    13f: int3
    140: .long   190h
    144: .long   16dh
    148: .long   1c9h
    14c: nop     [rax]
    150: mov     rax,[rbp-60h]
    154: mov     [rbp-68h],rax
    158: cmp     rax,1
    15c: sete    [rbp-4Dh]
    160: mov     rax,[rbp-58h]
    164: mov     [rbp+18h],rax
    168: jmp     50h
    16d: movzx   eax,word ptr [rbp-50h]
    171: mov     [rbp-6Ah],ax
    175: mov     [rbp-6Ch],ax
    179: mov     edi,0FFFFFF84h
    17e: mov     esi,0FFFFFF94h
    183: call    ryo_h_CttzW16
    188: mov     eax,[rbp-7Ch]
    18b: mov     [rbp-70h],eax
    18e: jmp     1A8h
    190: mov     edi,0FFFFFFA0h
    195: lea     rsi,[k4]
    19c: mov     edx,10h
    1a1: call    ryo_h_Const
    1a6: jmp     150h
    1a8: mov     edi,0FFFFFF88h
    1ad: mov     esi,0FFFFFF90h
    1b2: call    ryo_h_ZextW32W64
    1b7: mov     rax,[rbp-78h]
    1bb: mov     [rbp-58h],rax
    1bf: mov     qword ptr [rbp-60h],1
    1c7: jmp     150h
    1c9: call    ryo_h_Unreachable
    1ce: ud2

fn hashbrown::raw::RawTableInner::new_uninitialized::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     rax,[rbp+28h]
      f: mov     [rbp-88h],rax
     16: mov     edi,0FFFFFEF0h
     1b: mov     esi,18h
     20: call    ryo_h_MovW128
     25: mov     rax,[rbp-88h]
     2c: mov     [rbp-100h],rax
     33: call    fn0
     38: nop     [rcx-0A8h]
     3f: jmp     6Ch
     41: nop     [rax+rax]
     4a: nop     [rax+rax]
     50: mov     edi,0FFFFFFE8h
     55: mov     esi,0FFFFFF70h
     5a: call    ryo_h_MovW128
     5f: mov     qword ptr [rbp-20h],0
     67: jmp     2E0h
     6c: mov     edi,0FFFFFF14h
     71: mov     esi,0FFFFFF58h
     76: xor     edx,edx
     78: xor     ecx,ecx
     7a: xor     r8d,r8d
     7d: mov     r9d,1
     83: call    ryo_h_DiscrNicheW64
     88: mov     edi,0FFFFFFD0h
     8d: mov     esi,0FFFFFF14h
     92: call    ryo_h_ZextW32W64
     97: mov     edi,0FFFFFFD0h
     9c: xor     esi,esi
     9e: mov     edx,2
     a3: call    ryo_h_SwitchDenseW64
     a8: lea     rcx,[0B8h]
     af: movsxd  rax,[rcx+rax*4]
     b3: add     rax,rcx
     b6: jmp     rax
     b8: .long   109h
     bc: .long   c4h
     c0: .long   150h
     c4: mov     edi,0FFFFFF70h
     c9: mov     esi,0FFFFFF58h
     ce: call    ryo_h_MovW128
     d3: mov     rax,[rbp-98h]
     da: mov     [rbp-78h],rax
     de: mov     rax,[rbp+10h]
     e2: mov     [rbp-110h],rax
     e9: mov     edi,0FFFFFEF8h
     ee: mov     esi,0FFFFFF70h
     f3: call    ryo_h_MovW128
     f8: call    fn1
     fd: nop     [rcx-0B8h]
    104: jmp     2F1h
    109: movzx   eax,byte ptr [rbp+30h]
    10d: mov     [rbp-110h],al
    113: lea     rdi,[sym2]
    11a: lea     rsi,[site3]
    121: mov     edx,0FFFFFF10h
    126: call    ryo_h_CallExt
    12b: test    rax,rax
    12e: je      13Bh
    130: call    rax
    132: nop     [rcx-90h]
    139: jmp     14Bh
    13b: mov     rdi,rbp
    13e: lea     rsi,[ro+4]
    145: call    qword ptr [sym4]
    14b: jmp     50h
    150: call    ryo_h_Unreachable
    155: ud2
    157: nop     [rax+rax]
    160: mov     rax,[rbp+18h]
    164: mov     [rbp-0E0h],rax
    16b: mov     rax,[rbp+20h]
    16f: mov     [rbp-0E8h],rax
    176: mov     rax,[rbp-38h]
    17a: sub     rax,10h
    17e: mov     [rbp-0C8h],rax
    185: mov     rax,[rbp-0E0h]
    18c: add     rax,1
    190: mov     [rbp-0D0h],rax
    197: cmp     rax,0
    19b: jne     40Ah
    1a1: mov     edi,0FFFFFEF0h
    1a6: lea     rsi,[k5]
    1ad: call    ryo_h_AddrAbs
    1b2: lea     rdi,[sym6]
    1b9: lea     rsi,[site7]
    1c0: mov     edx,0FFFFFF10h
    1c5: call    ryo_h_CallExt
    1ca: test    rax,rax
    1cd: je      1DAh
    1cf: call    rax
    1d1: nop     [rcx-0E8h]
    1d8: jmp     1EAh
    1da: mov     rdi,rbp
    1dd: lea     rsi,[ro+20]
    1e4: call    qword ptr [sym8]
    1ea: call    ryo_h_Unreachable
    1ef: ud2
    1f1: nop     [rax+rax]
    1fa: nop     [rax+rax]
    200: mov     edi,0FFFFFF14h
    205: mov     esi,0FFFFFF30h
    20a: xor     edx,edx
    20c: xor     ecx,ecx
    20e: xor     r8d,r8d
    211: mov     r9d,1
    217: call    ryo_h_DiscrNicheW64
    21c: mov     edi,0FFFFFF28h
    221: mov     esi,0FFFFFF14h
    226: call    ryo_h_ZextW32W64
    22b: cmp     qword ptr [rbp-0D8h],1
    233: sete    [rbp-79h]
    237: mov     edi,0FFFFFF18h
    23c: mov     esi,0FFFFFF30h
    241: call    ryo_h_MovW128
    246: mov     rax,[rbp-0C0h]
    24d: mov     [rbp-78h],rax
    251: jmp     260h
    253: nop     [rax+rax]
    25c: nop     [rax]
    260: mov     rax,[rbp-70h]
    264: mov     [rbp-0C0h],rax
    26b: mov     [rbp-98h],rax
    272: mov     [rbp-0B0h],rax
    279: imul    rcx,[rbp-78h],1
    27e: add     rax,rcx
    281: mov     [rbp-0A8h],rax
    288: mov     [rbp-0A0h],rax
    28f: mov     rax,[rbp+28h]
    293: mov     [rbp-0D0h],rax
    29a: sub     rax,1
    29e: mov     [rbp-0C8h],rax
    2a5: mov     rax,[rbp+28h]
    2a9: sub     rax,1
    2ad: mov     [rbp-60h],rax
    2b1: cmp     rax,8
    2b5: jb      4BDh
    2bb: jmp     4BFh
    2c0: mov     edi,0FFFFFFE8h
    2c5: mov     esi,0FFFFFF48h
    2ca: call    ryo_h_MovW128
    2cf: mov     qword ptr [rbp-20h],0
    2d7: nop     [rax+rax]
    2e0: mov     edi,0FFFFFFE0h
    2e5: mov     esi,20h
    2ea: call    ryo_h_Ret
    2ef: leave
    2f0: ret
    2f1: mov     edi,0FFFFFF14h
    2f6: mov     esi,0FFFFFF48h
    2fb: xor     edx,edx
    2fd: mov     ecx,1
    302: mov     r8d,1
    308: xor     r9d,r9d
    30b: call    ryo_h_DiscrNicheW64
    310: mov     edi,0FFFFFF40h
    315: mov     esi,0FFFFFF14h
    31a: call    ryo_h_ZextW32W64
    31f: mov     edi,0FFFFFF40h
    324: xor     esi,esi
    326: mov     edx,2
    32b: call    ryo_h_SwitchDenseW64
    330: lea     rcx,[340h]
    337: movsxd  rax,[rcx+rax*4]
    33b: add     rax,rcx
    33e: jmp     rax
    340: .long   3a2h
    344: .long   34ch
    348: .long   150h
    34c: movzx   eax,byte ptr [rbp+30h]
    350: mov     [rbp-110h],al
    356: mov     edi,0FFFFFEF8h
    35b: mov     esi,0FFFFFF70h
    360: call    ryo_h_MovW128
    365: lea     rdi,[sym9]
    36c: lea     rsi,[site10]
    373: mov     edx,0FFFFFF10h
    378: call    ryo_h_CallExt
    37d: test    rax,rax
    380: je      38Dh
    382: call    rax
    384: nop     [rcx-0B8h]
    38b: jmp     39Dh
    38d: mov     rdi,rbp
    390: lea     rsi,[ro+36]
    397: call    qword ptr [sym11]
    39d: jmp     2C0h
    3a2: mov     edi,0FFFFFF30h
    3a7: mov     esi,0FFFFFF48h
    3ac: call    ryo_h_MovW128
    3b1: mov     edi,0FFFFFF58h
    3b6: mov     esi,0FFFFFF30h
    3bb: call    ryo_h_MovW128
    3c0: mov     edi,0FFFFFF48h
    3c5: mov     esi,0FFFFFF58h
    3ca: call    ryo_h_MovW128
    3cf: mov     edi,0FFFFFF90h
    3d4: mov     esi,0FFFFFF48h
    3d9: call    ryo_h_MovW128
    3de: mov     rax,[rbp-68h]
    3e2: mov     [rbp-38h],rax
    3e6: mov     rax,[rbp-88h]
    3ed: mov     [rbp-0C0h],rax
    3f4: mov     rax,[rbp-38h]
    3f8: cmp     rax,[rbp-0C0h]
    3ff: jne     160h
    405: jmp     260h
    40a: mov     edi,0FFFFFF40h
    40f: mov     esi,0FFFFFF38h
    414: mov     edx,0FFFFFF30h
    419: call    ryo_h_DivUW64
    41e: mov     rax,[rbp-0C0h]
    425: mov     [rbp-0D8h],rax
    42c: mov     edi,0FFFFFF14h
    431: mov     esi,0FFFFFF28h
    436: call    ryo_h_CtlzW64
    43b: mov     eax,[rbp-0ECh]
    441: mov     [rbp-80h],eax
    444: mov     edi,0FFFFFF30h
    449: mov     esi,0FFFFFF80h
    44e: call    ryo_h_ZextW32W64
    453: mov     qword ptr [rbp-0F0h],3Fh
    45e: mov     rax,[rbp-0F0h]
    465: sub     rax,[rbp-0D0h]
    46c: mov     [rbp-0C8h],rax
    473: mov     qword ptr [rbp-0F0h],1
    47e: mov     edi,28h
    483: mov     esi,0FFFFFF10h
    488: mov     edx,0FFFFFF38h
    48d: call    ryo_h_ShlW64
    492: mov     edi,0FFFFFEF0h
    497: mov     esi,18h
    49c: call    ryo_h_MovW128
    4a1: mov     rax,[rbp+28h]
    4a5: mov     [rbp-100h],rax
    4ac: call    fn12
    4b1: nop     [rcx-0D0h]
    4b8: jmp     200h
    4bd: jmp     4F9h
    4bf: mov     rax,[rbp-60h]
    4c3: add     rax,1
    4c7: mov     [rbp-0D8h],rax
    4ce: mov     qword ptr [rbp-0F0h],8
    4d9: mov     edi,0FFFFFF30h
    4de: mov     esi,0FFFFFF28h
    4e3: mov     edx,0FFFFFF10h
    4e8: call    ryo_h_DivUW64
    4ed: imul    rax,[rbp-0D0h],7
    4f5: mov     [rbp-60h],rax
    4f9: mov     rax,[rbp-0C8h]
    500: mov     [rbp-0B8h],rax
    507: mov     rax,[rbp-0A0h]
    50e: mov     [rbp-0C0h],rax
    515: mov     rax,[rbp-60h]
    519: mov     [rbp-0B0h],rax
    520: mov     qword ptr [rbp-0A8h],0
    52b: mov     edi,0FFFFFFE0h
    530: mov     esi,0FFFFFF40h
    535: mov     edx,20h
    53a: call    ryo_h_Copy
    53f: jmp     2E0h

fn hashbrown::raw::RawTableInner::prepare_rehash_in_place
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,120h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-0A8h],rax
     1a: add     rax,1
     1e: mov     [rbp-0A0h],rax
     25: mov     qword ptr [rbp-98h],0
     30: mov     [rbp-90h],rax
     37: mov     edi,0FFFFFEE0h
     3c: mov     esi,0FFFFFF68h
     41: call    ryo_h_MovW128
     46: mov     qword ptr [rbp-110h],10h
     51: call    fn0
     56: nop     [rcx-20h]
     5d: jmp     19Bh
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     rax,[rbp-10h]
     74: mov     [rbp-0C0h],rax
     7b: add     rax,1
     7f: mov     [rbp-0B8h],rax
     86: mov     [rbp-0C0h],rax
     8d: mov     edi,0FFFFFF0Ch
     92: mov     esi,0FFFFFF40h
     97: xor     edx,edx
     99: xor     ecx,ecx
     9b: xor     r8d,r8d
     9e: mov     r9d,1
     a4: call    ryo_h_DiscrNicheW64
     a9: mov     edi,0FFFFFF38h
     ae: mov     esi,0FFFFFF0Ch
     b3: call    ryo_h_ZextW32W64
     b8: cmp     qword ptr [rbp-0C8h],1
     c0: sete    [rbp-81h]
     c7: mov     rax,[rbp-0C0h]
     ce: mov     [rbp-0B0h],rax
     d5: mov     [rbp-0A8h],rax
     dc: mov     [rbp-0A0h],rax
     e3: mov     rax,[rbp-18h]
     e7: mov     [rbp-0A0h],rax
     ee: cmp     rax,0
     f2: ja      1A0h
     f8: jmp     24Ch
     fd: nop     [rax]
    100: mov     edi,0FFFFFF10h
    105: mov     esi,0FFFFFF40h
    10a: call    ryo_h_MovW128
    10f: mov     rax,[rbp+10h]
    113: mov     rax,[rax]
    116: mov     [rbp-0D8h],rax
    11d: mov     [rbp-0D0h],rax
    124: imul    rcx,[rbp-0A0h],1
    12c: add     rax,rcx
    12f: mov     [rbp-58h],rax
    133: mov     [rbp-0C8h],rax
    13a: mov     rax,[rbp-58h]
    13e: mov     [rbp-0D0h],rax
    145: mov     [rbp-120h],rax
    14c: mov     edi,0FFFFFEF0h
    151: mov     esi,0FFFFFF10h
    156: call    ryo_h_MovW128
    15b: mov     edi,0FFFFFF08h
    160: lea     rsi,[sym1]
    167: call    ryo_h_AddrSym
    16c: mov     rdi,rbp
    16f: lea     rsi,[ro+4]
    176: call    qword ptr [sym2]
    17c: jmp     2AFh
    181: nop     [rax+rax]
    18a: nop     [rax+rax]
    190: xor     edi,edi
    192: xor     esi,esi
    194: call    ryo_h_Ret
    199: leave
    19a: ret
    19b: jmp     70h
    1a0: mov     rax,[rbp-20h]
    1a4: mov     [rbp-0B0h],rax
    1ab: add     rax,[rbp-0A8h]
    1b2: mov     [rbp-0B8h],rax
    1b9: mov     [rbp-20h],rax
    1bd: mov     rax,[rbp-0A0h]
    1c4: sub     rax,1
    1c8: mov     [rbp-18h],rax
    1cc: mov     rax,[rbp-0B0h]
    1d3: mov     [rbp-90h],rax
    1da: mov     qword ptr [rbp-98h],1
    1e5: mov     [rbp-0A0h],rax
    1ec: mov     rax,[rbp+10h]
    1f0: mov     rax,[rax]
    1f3: mov     [rbp-0C8h],rax
    1fa: mov     [rbp-0C0h],rax
    201: imul    rcx,[rbp-0A0h],1
    209: add     rax,rcx
    20c: mov     [rbp-38h],rax
    210: mov     [rbp-0B8h],rax
    217: mov     rax,[rbp-38h]
    21b: mov     [rbp-0C0h],rax
    222: mov     [rbp-120h],rax
    229: mov     edi,0FFFFFF08h
    22e: lea     rsi,[sym3]
    235: call    ryo_h_AddrSym
    23a: mov     rdi,rbp
    23d: lea     rsi,[ro+20]
    244: call    qword ptr [sym4]
    24a: jmp     280h
    24c: mov     rax,[rbp+10h]
    250: mov     rax,[rax+8]
    254: mov     [rbp-98h],rax
    25b: add     rax,1
    25f: mov     [rbp-90h],rax
    266: cmp     rax,10h
    26a: setb    [rbp-82h]
    271: test    byte ptr [rbp-82h],0FFh
    278: je      34Ch
    27e: jmp     2B4h
    280: mov     edi,0FFFFFF50h
    285: mov     esi,0FFFFFF30h
    28a: call    ryo_h_MovW128
    28f: mov     edi,0FFFFFEE0h
    294: mov     esi,0FFFFFF50h
    299: call    ryo_h_MovW128
    29e: call    fn5
    2a3: nop     [rcx-0C0h]
    2aa: jmp     100h
    2af: jmp     70h
    2b4: mov     rax,[rbp+10h]
    2b8: mov     rax,[rax]
    2bb: mov     [rbp-78h],rax
    2bf: mov     [rbp-90h],rax
    2c6: mov     rax,[rbp+10h]
    2ca: mov     rax,[rax]
    2cd: mov     [rbp-0B0h],rax
    2d4: mov     [rbp-0A8h],rax
    2db: mov     qword ptr [rbp-0F8h],10h
    2e6: imul    rcx,[rbp-0F8h],1
    2ee: add     rax,rcx
    2f1: mov     [rbp-0A0h],rax
    2f8: mov     [rbp-98h],rax
    2ff: mov     rax,[rbp+10h]
    303: mov     rax,[rax+8]
    307: mov     [rbp-0A8h],rax
    30e: add     rax,1
    312: mov     [rbp-0A0h],rax
    319: mov     rax,[rbp-78h]
    31d: mov     [rbp-0A8h],rax
    324: imul    rax,[rbp-0A0h],1
    32c: mov     [rbp-0F8h],rax
    333: mov     edi,0FFFFFF68h
    338: mov     esi,0FFFFFF58h
    33d: mov     edx,0FFFFFF08h
    342: call    ryo_h_Memmove
    347: jmp     3E1h
    34c: mov     rax,[rbp+10h]
    350: mov     rax,[rax]
    353: mov     [rbp-80h],rax
    357: mov     [rbp-90h],rax
    35e: mov     rax,[rbp+10h]
    362: mov     rax,[rax+8]
    366: mov     [rbp-0A8h],rax
    36d: add     rax,1
    371: mov     [rbp-0A0h],rax
    378: mov     rax,[rbp+10h]
    37c: mov     rax,[rax]
    37f: mov     [rbp-0B8h],rax
    386: mov     [rbp-0B0h],rax
    38d: imul    rcx,[rbp-0A0h],1
    395: add     rax,rcx
    398: mov     [rbp-0A8h],rax
    39f: mov     [rbp-98h],rax
    3a6: mov     rax,[rbp-80h]
    3aa: mov     [rbp-0A0h],rax
    3b1: mov     qword ptr [rbp-0F8h],10h
    3bc: imul    rax,[rbp-0F8h],1
    3c4: mov     [rbp-100h],rax
    3cb: mov     edi,0FFFFFF68h
    3d0: mov     esi,0FFFFFF60h
    3d5: mov     edx,0FFFFFF00h
    3da: call    ryo_h_Memmove
    3df: jmp     3E6h
    3e1: jmp     190h
    3e6: jmp     190h

fn hashbrown::raw::RawTableInner::prepare_resize::<std::alloc::Global>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-30h],rax
     17: cmp     rax,0
     1b: sete    [rbp-21h]
     1f: test    byte ptr [rbp-21h],0FFh
     23: jne     80h
     25: mov     rax,[rbp+10h]
     29: mov     rax,[rax]
     2c: mov     [rbp-8],rax
     30: mov     edi,0FFFFFFC8h
     35: mov     esi,10h
     3a: mov     edx,8
     3f: call    ryo_h_LoadW128
     44: mov     rax,[rbp+18h]
     48: mov     rax,[rax+8]
     4c: mov     [rbp-68h],rax
     50: add     rax,1
     54: mov     [rbp-58h],rax
     58: mov     edi,0FFFFFF50h
     5d: mov     esi,0FFFFFFC8h
     62: call    ryo_h_MovW128
     67: mov     rax,[rbp-58h]
     6b: mov     [rbp-0A0h],rax
     72: call    fn0
     77: nop     [rcx-50h]
     7e: jmp     92h
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret
     8b: nop     [rax+rax]
     90: jmp     80h
     92: mov     edi,0FFFFFF7Ch
     97: mov     esi,0FFFFFFB0h
     9c: xor     edx,edx
     9e: xor     ecx,ecx
     a0: xor     r8d,r8d
     a3: mov     r9d,1
     a9: call    ryo_h_DiscrNicheW64
     ae: mov     edi,0FFFFFFA8h
     b3: mov     esi,0FFFFFF7Ch
     b8: call    ryo_h_ZextW32W64
     bd: cmp     qword ptr [rbp-58h],1
     c2: sete    [rbp-22h]
     c6: mov     edi,0FFFFFF88h
     cb: mov     esi,0FFFFFFB0h
     d0: call    ryo_h_MovW128
     d5: mov     rax,[rbp-40h]
     d9: mov     [rbp-80h],rax
     dd: mov     rax,[rbp+18h]
     e1: mov     rax,[rax]
     e4: mov     [rbp-50h],rax
     e8: mov     [rbp-48h],rax
     ec: mov     rax,[rbp-80h]
     f0: mov     [rbp-58h],rax
     f4: mov     qword ptr [rbp-88h],0
     ff: mov     rax,[rbp-88h]
    106: sub     rax,[rbp-58h]
    10a: mov     [rbp-50h],rax
    10e: mov     rax,[rbp-48h]
    112: imul    rcx,[rbp-50h],1
    117: add     rax,rcx
    11a: mov     [rbp-40h],rax
    11e: mov     [rbp-60h],rax
    122: mov     rax,[rbp-8]
    126: mov     [rbp-0B0h],rax
    12d: mov     rax,[rbp-60h]
    131: mov     [rbp-0A8h],rax
    138: mov     edi,0FFFFFF60h
    13d: mov     esi,0FFFFFF88h
    142: call    ryo_h_MovW128
    147: call    fn1
    14c: nop     [rcx-8]
    153: jmp     90h

fn hashbrown::raw::RawTableInner::rehash_in_place
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,1F0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-1F0h],rax
     16: call    fn0
     1b: nop     [rcx]
     22: mov     rax,[rbp+30h]
     26: mov     [rbp-168h],rax
     2d: mov     rax,[rbp+28h]
     31: mov     [rbp-160h],rax
     38: mov     edi,0FFFFFEB0h
     3d: mov     esi,0FFFFFE98h
     42: call    ryo_h_MovW128
     47: mov     rax,[rbp+10h]
     4b: mov     [rbp-158h],rax
     52: mov     [rbp-0C8h],rax
     59: mov     rax,[rax+8]
     5d: mov     [rbp-168h],rax
     64: add     rax,1
     68: mov     [rbp-160h],rax
     6f: mov     qword ptr [rbp-10h],0
     77: mov     [rbp-8],rax
     7b: nop     [rax+rax]
     80: mov     rax,[rbp-10h]
     84: mov     [rbp-178h],rax
     8b: mov     rax,[rbp-8]
     8f: mov     [rbp-180h],rax
     96: mov     rax,[rbp-178h]
     9d: cmp     rax,[rbp-180h]
     a4: setb    [rbp-169h]
     ab: test    byte ptr [rbp-169h],0FFh
     b2: je      577h
     b8: jmp     4D3h
     bd: nop     [rax]
     c0: call    ryo_h_Unreachable
     c5: ud2
     c7: nop     [rax+rax]
     d0: jmp     490h
     d5: nop     [rax+rax]
     de: xchg    ax,ax
     e0: mov     rax,[rbp-158h]
     e7: mov     [rbp-0D8h],rax
     ee: mov     rax,[rax]
     f1: mov     [rbp-198h],rax
     f8: mov     [rbp-180h],rax
     ff: mov     rax,[rbp-170h]
    106: add     rax,1
    10a: mov     [rbp-190h],rax
    111: imul    rax,[rbp+28h]
    116: mov     [rbp-188h],rax
    11d: mov     [rbp-1A0h],rax
    124: mov     qword ptr [rbp-1D0h],0
    12f: mov     rax,[rbp-1D0h]
    136: sub     rax,[rbp-1A0h]
    13d: mov     [rbp-190h],rax
    144: mov     rax,[rbp-180h]
    14b: imul    rcx,[rbp-190h],1
    153: add     rax,rcx
    156: mov     [rbp-178h],rax
    15d: nop     [rax]
    160: mov     rax,[rbp-158h]
    167: mov     [rbp-0E0h],rax
    16e: mov     [rbp-190h],rax
    175: mov     rax,[rbp-170h]
    17c: mov     [rbp-188h],rax
    183: mov     rax,[rbp+20h]
    187: mov     rax,[rax+28h]
    18b: mov     [rbp-1D0h],rax
    192: mov     rax,[rbp+18h]
    196: mov     [rbp-1F0h],rax
    19d: mov     rax,[rbp-190h]
    1a4: mov     [rbp-1E8h],rax
    1ab: mov     rax,[rbp-188h]
    1b2: mov     [rbp-1E0h],rax
    1b9: mov     edi,0FFFFFE30h
    1be: lea     rsi,[site1]
    1c5: call    ryo_h_CallInd
    1ca: test    rax,rax
    1cd: je      1DAh
    1cf: call    rax
    1d1: nop     [rcx-180h]
    1d8: jmp     1EAh
    1da: mov     rdi,rbp
    1dd: lea     rsi,[ro+4]
    1e4: call    qword ptr [sym2]
    1ea: mov     rax,[rbp-158h]
    1f1: mov     [rbp-0E8h],rax
    1f8: mov     [rbp-190h],rax
    1ff: mov     [rbp-1F0h],rax
    206: mov     rax,[rbp-180h]
    20d: mov     [rbp-1E8h],rax
    214: call    fn3
    219: nop     [rcx-188h]
    220: mov     rax,[rbp-158h]
    227: mov     [rbp-0F0h],rax
    22e: mov     rax,[rbp-180h]
    235: mov     [rbp-198h],rax
    23c: mov     rax,[rbp-0F0h]
    243: mov     rax,[rax+8]
    247: mov     [rbp-1A0h],rax
    24e: mov     rax,[rbp-198h]
    255: and     rax,[rbp-1A0h]
    25c: mov     [rbp-1A8h],rax
    263: mov     rax,[rbp-170h]
    26a: sub     rax,[rbp-1A8h]
    271: mov     [rbp-1B0h],rax
    278: mov     rax,[rbp-0F0h]
    27f: mov     rax,[rax+8]
    283: mov     [rbp-1B8h],rax
    28a: mov     rax,[rbp-1B0h]
    291: and     rax,[rbp-1B8h]
    298: mov     [rbp-1A0h],rax
    29f: mov     qword ptr [rbp-1D0h],10h
    2aa: mov     edi,0FFFFFE68h
    2af: mov     esi,0FFFFFE60h
    2b4: mov     edx,0FFFFFE30h
    2b9: call    ryo_h_DivUW64
    2be: mov     rax,[rbp-188h]
    2c5: sub     rax,[rbp-1A8h]
    2cc: mov     [rbp-1B8h],rax
    2d3: mov     rax,[rbp-0F0h]
    2da: mov     rax,[rax+8]
    2de: mov     [rbp-1C0h],rax
    2e5: mov     rax,[rbp-1B8h]
    2ec: and     rax,[rbp-1C0h]
    2f3: mov     [rbp-1B0h],rax
    2fa: mov     qword ptr [rbp-1D0h],10h
    305: mov     edi,0FFFFFE60h
    30a: mov     esi,0FFFFFE50h
    30f: mov     edx,0FFFFFE30h
    314: call    ryo_h_DivUW64
    319: mov     rax,[rbp-198h]
    320: cmp     rax,[rbp-1A0h]
    327: sete    [rbp-189h]
    32e: test    byte ptr [rbp-189h],0FFh
    335: je      6A3h
    33b: jmp     59Fh
    340: mov     rax,[rbp-158h]
    347: mov     [rbp-110h],rax
    34e: mov     rax,[rbp-170h]
    355: sub     rax,10h
    359: mov     [rbp-1B0h],rax
    360: mov     rax,[rbp-110h]
    367: mov     rax,[rax+8]
    36b: mov     [rbp-1B8h],rax
    372: mov     rax,[rbp-1B0h]
    379: and     rax,[rbp-1B8h]
    380: mov     [rbp-1A8h],rax
    387: add     rax,10h
    38b: mov     [rbp-1A0h],rax
    392: mov     rax,[rbp-110h]
    399: mov     rax,[rax]
    39c: mov     [rbp-1C0h],rax
    3a3: mov     [rbp-1B8h],rax
    3aa: imul    rcx,[rbp-170h],1
    3b2: add     rax,rcx
    3b5: mov     [rbp-1B0h],rax
    3bc: mov     [rbp-1A8h],rax
    3c3: mov     byte ptr [rbp-1D0h],0FFh
    3ca: movzx   ecx,byte ptr [rbp-1D0h]
    3d1: mov     [rax],cl
    3d3: mov     rax,[rbp-110h]
    3da: mov     rax,[rax]
    3dd: mov     [rbp-1C0h],rax
    3e4: mov     [rbp-1B8h],rax
    3eb: imul    rcx,[rbp-1A0h],1
    3f3: add     rax,rcx
    3f6: mov     [rbp-1B0h],rax
    3fd: mov     [rbp-1A8h],rax
    404: mov     byte ptr [rbp-1D0h],0FFh
    40b: movzx   ecx,byte ptr [rbp-1D0h]
    412: mov     [rax],cl
    414: mov     rax,[rbp-178h]
    41b: mov     [rbp-1A0h],rax
    422: imul    rax,[rbp+28h],1
    427: mov     [rbp-1D0h],rax
    42e: mov     edi,0FFFFFE70h
    433: mov     esi,0FFFFFE60h
    438: mov     edx,0FFFFFE30h
    43d: call    ryo_h_Memcpy
    442: jmp     490h
    444: nop     [rax+rax]
    44d: nop     [rax]
    450: mov     rax,[rbp-178h]
    457: mov     [rbp-1A8h],rax
    45e: mov     rax,[rbp+28h]
    462: mov     [rbp-1A0h],rax
    469: mov     edi,0FFFFFE40h
    46e: mov     esi,0FFFFFE58h
    473: call    ryo_h_MovW128
    478: imul    rax,[rbp-1B8h],1
    480: mov     [rbp-1B0h],rax
    487: jmp     8C6h
    48c: nop     [rax]
    490: jmp     80h
    495: nop     [rax+rax]
    49e: xchg    ax,ax
    4a0: mov     edi,0FFFFFEC0h
    4a5: call    ryo_h_Resume
    4aa: ud2
    4ac: nop     [rax]
    4b0: lea     rax,[rbp-158h]
    4b7: mov     [rbp-1D0h],rax
    4be: mov     [rbp-1F0h],rax
    4c5: call    fn4
    4ca: nop     [rcx-1D0h]
    4d1: jmp     4A0h
    4d3: mov     rax,[rbp-10h]
    4d7: mov     [rbp-178h],rax
    4de: add     rax,1
    4e2: mov     [rbp-180h],rax
    4e9: mov     [rbp-10h],rax
    4ed: mov     rax,[rbp-178h]
    4f4: mov     [rbp-160h],rax
    4fb: mov     qword ptr [rbp-168h],1
    506: mov     [rbp-170h],rax
    50d: mov     rax,[rbp-158h]
    514: mov     [rbp-0D0h],rax
    51b: mov     rax,[rax]
    51e: mov     [rbp-190h],rax
    525: mov     [rbp-188h],rax
    52c: imul    rcx,[rbp-170h],1
    534: add     rax,rcx
    537: mov     [rbp-180h],rax
    53e: mov     [rbp-28h],rax
    542: movzx   eax,byte ptr [rax]
    545: mov     [rbp-173h],al
    54b: cmp     al,80h
    54e: sete    [rbp-172h]
    555: movzx   eax,byte ptr [rbp-172h]
    55c: xor     al,1
    55f: mov     [rbp-171h],al
    565: test    byte ptr [rbp-171h],0FFh
    56c: je      0E0h
    572: jmp     0D0h
    577: mov     rax,[rbp-158h]
    57e: mov     [rbp-118h],rax
    585: mov     rax,[rax+8]
    589: mov     [rbp-0A8h],rax
    590: cmp     rax,8
    594: jb      92Ch
    59a: jmp     92Eh
    59f: mov     rax,[rbp-158h]
    5a6: mov     [rbp-0F8h],rax
    5ad: mov     rax,[rbp-180h]
    5b4: shr     rax,39h
    5b8: mov     [rbp-198h],rax
    5bf: and     rax,7Fh
    5c3: mov     [rbp-1A0h],rax
    5ca: mov     edi,0FFFFFE76h
    5cf: mov     esi,0FFFFFE60h
    5d4: call    ryo_h_TruncW64W8
    5d9: movzx   eax,byte ptr [rbp-18Ah]
    5e0: mov     [rbp-189h],al
    5e6: mov     rax,[rbp-170h]
    5ed: sub     rax,10h
    5f1: mov     [rbp-1A8h],rax
    5f8: mov     rax,[rbp-0F8h]
    5ff: mov     rax,[rax+8]
    603: mov     [rbp-1B0h],rax
    60a: mov     rax,[rbp-1A8h]
    611: and     rax,[rbp-1B0h]
    618: mov     [rbp-1A0h],rax
    61f: add     rax,10h
    623: mov     [rbp-198h],rax
    62a: mov     rax,[rbp-0F8h]
    631: mov     rax,[rax]
    634: mov     [rbp-1B8h],rax
    63b: mov     [rbp-1B0h],rax
    642: imul    rcx,[rbp-170h],1
    64a: add     rax,rcx
    64d: mov     [rbp-1A8h],rax
    654: mov     [rbp-1A0h],rax
    65b: movzx   ecx,byte ptr [rbp-189h]
    662: mov     [rax],cl
    664: mov     rax,[rbp-0F8h]
    66b: mov     rax,[rax]
    66e: mov     [rbp-1B8h],rax
    675: mov     [rbp-1B0h],rax
    67c: imul    rcx,[rbp-198h],1
    684: add     rax,rcx
    687: mov     [rbp-1A8h],rax
    68e: mov     [rbp-1A0h],rax
    695: movzx   ecx,byte ptr [rbp-189h]
    69c: mov     [rax],cl
    69e: jmp     490h
    6a3: mov     rax,[rbp-158h]
    6aa: mov     [rbp-100h],rax
    6b1: mov     rax,[rax]
    6b4: mov     [rbp-1B0h],rax
    6bb: mov     [rbp-198h],rax
    6c2: mov     rax,[rbp-188h]
    6c9: add     rax,1
    6cd: mov     [rbp-1A8h],rax
    6d4: imul    rax,[rbp+28h]
    6d9: mov     [rbp-1A0h],rax
    6e0: mov     [rbp-1B8h],rax
    6e7: mov     qword ptr [rbp-1D0h],0
    6f2: mov     rax,[rbp-1D0h]
    6f9: sub     rax,[rbp-1B8h]
    700: mov     [rbp-1A8h],rax
    707: mov     rax,[rbp-198h]
    70e: imul    rcx,[rbp-1A8h],1
    716: add     rax,rcx
    719: mov     [rbp-190h],rax
    720: mov     rax,[rbp-158h]
    727: mov     [rbp-108h],rax
    72e: mov     rax,[rax]
    731: mov     [rbp-1B8h],rax
    738: mov     [rbp-1B0h],rax
    73f: imul    rcx,[rbp-188h],1
    747: add     rax,rcx
    74a: mov     [rbp-1A8h],rax
    751: mov     [rbp-1A0h],rax
    758: movzx   eax,byte ptr [rax]
    75b: mov     [rbp-191h],al
    761: mov     rax,[rbp-180h]
    768: shr     rax,39h
    76c: mov     [rbp-1A0h],rax
    773: and     rax,7Fh
    777: mov     [rbp-1A8h],rax
    77e: mov     edi,0FFFFFE6Dh
    783: mov     esi,0FFFFFE58h
    788: call    ryo_h_TruncW64W8
    78d: movzx   eax,byte ptr [rbp-193h]
    794: mov     [rbp-192h],al
    79a: mov     rax,[rbp-188h]
    7a1: sub     rax,10h
    7a5: mov     [rbp-1B0h],rax
    7ac: mov     rax,[rbp-108h]
    7b3: mov     rax,[rax+8]
    7b7: mov     [rbp-1B8h],rax
    7be: mov     rax,[rbp-1B0h]
    7c5: and     rax,[rbp-1B8h]
    7cc: mov     [rbp-1A8h],rax
    7d3: add     rax,10h
    7d7: mov     [rbp-1A0h],rax
    7de: mov     rax,[rbp-108h]
    7e5: mov     rax,[rax]
    7e8: mov     [rbp-1C0h],rax
    7ef: mov     [rbp-1B8h],rax
    7f6: imul    rcx,[rbp-188h],1
    7fe: add     rax,rcx
    801: mov     [rbp-1B0h],rax
    808: mov     [rbp-1A8h],rax
    80f: movzx   ecx,byte ptr [rbp-192h]
    816: mov     [rax],cl
    818: mov     rax,[rbp-108h]
    81f: mov     rax,[rax]
    822: mov     [rbp-1C0h],rax
    829: mov     [rbp-1B8h],rax
    830: imul    rcx,[rbp-1A0h],1
    838: add     rax,rcx
    83b: mov     [rbp-1B0h],rax
    842: mov     [rbp-1A8h],rax
    849: movzx   ecx,byte ptr [rbp-192h]
    850: mov     [rax],cl
    852: movzx   eax,byte ptr [rbp-191h]
    859: mov     [rbp-193h],al
    85f: cmp     al,0FFh
    862: sete    [rbp-192h]
    869: test    byte ptr [rbp-192h],0FFh
    870: je      450h
    876: jmp     340h
    87b: mov     rax,[rbp-1B8h]
    882: mov     [rbp-1C0h],rax
    889: mov     rax,[rbp-178h]
    890: mov     [rbp-1F0h],rax
    897: mov     rax,[rbp-190h]
    89e: mov     [rbp-1E8h],rax
    8a5: mov     rax,[rbp-1C0h]
    8ac: mov     [rbp-1E0h],rax
    8b3: call    fn5
    8b8: nop     [rcx-138h]
    8bf: jmp     8C1h
    8c1: jmp     160h
    8c6: mov     rax,[rbp-1B0h]
    8cd: mov     [rbp-1B8h],rax
    8d4: mov     edi,0FFFFFE34h
    8d9: mov     esi,0FFFFFE48h
    8de: xor     edx,edx
    8e0: xor     ecx,ecx
    8e2: xor     r8d,r8d
    8e5: mov     r9d,1
    8eb: call    ryo_h_DiscrNicheW64
    8f0: mov     edi,0FFFFFE38h
    8f5: mov     esi,0FFFFFE34h
    8fa: call    ryo_h_ZextW32W64
    8ff: mov     edi,0FFFFFE38h
    904: xor     esi,esi
    906: mov     edx,2
    90b: call    ryo_h_SwitchDenseW64
    910: lea     rcx,[920h]
    917: movsxd  rax,[rcx+rax*4]
    91b: add     rax,rcx
    91e: jmp     rax
    920: .long   8c1h
    924: .long   87bh
    928: .long   c0h
    92c: jmp     96Eh
    92e: mov     rax,[rbp-0A8h]
    935: add     rax,1
    939: mov     [rbp-170h],rax
    940: mov     qword ptr [rbp-1D0h],8
    94b: mov     edi,0FFFFFE98h
    950: mov     esi,0FFFFFE90h
    955: mov     edx,0FFFFFE30h
    95a: call    ryo_h_DivUW64
    95f: imul    rax,[rbp-168h],7
    967: mov     [rbp-0A8h],rax
    96e: mov     rax,[rbp-158h]
    975: mov     [rbp-120h],rax
    97c: mov     rax,[rax+18h]
    980: mov     [rbp-160h],rax
    987: mov     rax,[rbp-158h]
    98e: mov     [rbp-128h],rax
    995: mov     rax,[rbp-0A8h]
    99c: sub     rax,[rbp-160h]
    9a3: mov     [rbp-1D0h],rax
    9aa: mov     rax,[rbp-128h]
    9b1: mov     rcx,[rbp-1D0h]
    9b8: mov     [rax+10h],rcx
    9bc: mov     rax,[rbp-150h]
    9c3: mov     [rbp-168h],rax
    9ca: mov     rax,[rbp-148h]
    9d1: mov     [rbp-170h],rax
    9d8: mov     rax,[rbp-158h]
    9df: mov     [rbp-160h],rax
    9e6: xor     edi,edi
    9e8: xor     esi,esi
    9ea: call    ryo_h_Ret
    9ef: leave
    9f0: ret
    9f1: nop     [rax+rax]
    9fa: nop     [rax+rax]
    a00: lea     rdi,[sym6]
    a07: lea     rsi,[site7]
    a0e: mov     edx,0FFFFFE30h
    a13: call    ryo_h_CallExt
    a18: test    rax,rax
    a1b: je      0A28h
    a1d: call    rax
    a1f: nop     [rcx-1C8h]
    a26: jmp     0A38h
    a28: mov     rdi,rbp
    a2b: lea     rsi,[ro+20]
    a32: call    qword ptr [sym8]
    a38: call    ryo_h_Unreachable
    a3d: ud2
    a3f: mov     rdi,rax
    a42: mov     esi,0FFFFFEC0h
    a47: call    ryo_h_Lpad
    a4c: jmp     4B0h
    a51: mov     rdi,rax
    a54: mov     esi,0FFFFFEC0h
    a59: call    ryo_h_Lpad
    a5e: jmp     0A00h

fn hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     rax,[rbp+18h]
      f: mov     rax,[rax]
     12: mov     [rbp-38h],rax
     16: mov     rax,[rax+8]
     1a: mov     [rbp-98h],rax
     21: add     rax,1
     25: mov     [rbp-90h],rax
     2c: mov     qword ptr [rbp-10h],0
     34: mov     [rbp-8],rax
     38: nop     [rax+rax]
     40: mov     rax,[rbp-10h]
     44: mov     [rbp-0A8h],rax
     4b: mov     rax,[rbp-8]
     4f: mov     [rbp-0B0h],rax
     56: mov     rax,[rbp-0A8h]
     5d: cmp     rax,[rbp-0B0h]
     64: setb    [rbp-99h]
     6b: test    byte ptr [rbp-99h],0FFh
     72: je      376h
     78: jmp     2E5h
     7d: nop     [rax]
     80: call    ryo_h_Unreachable
     85: ud2
     87: nop     [rax+rax]
     90: mov     rax,[rbp+18h]
     94: mov     rax,[rax]
     97: mov     [rbp-50h],rax
     9b: mov     rax,[rbp-0A0h]
     a2: sub     rax,10h
     a6: mov     [rbp-0C0h],rax
     ad: mov     rax,[rbp-50h]
     b1: mov     rax,[rax+8]
     b5: mov     [rbp-0C8h],rax
     bc: mov     rax,[rbp-0C0h]
     c3: and     rax,[rbp-0C8h]
     ca: mov     [rbp-0B8h],rax
     d1: add     rax,10h
     d5: mov     [rbp-0B0h],rax
     dc: mov     rax,[rbp-50h]
     e0: mov     rax,[rax]
     e3: mov     [rbp-0D0h],rax
     ea: mov     [rbp-0C8h],rax
     f1: imul    rcx,[rbp-0A0h],1
     f9: add     rax,rcx
     fc: mov     [rbp-0C0h],rax
    103: mov     [rbp-0B8h],rax
    10a: mov     byte ptr [rbp-0F0h],0FFh
    111: movzx   ecx,byte ptr [rbp-0F0h]
    118: mov     [rax],cl
    11a: mov     rax,[rbp-50h]
    11e: mov     rax,[rax]
    121: mov     [rbp-0D0h],rax
    128: mov     [rbp-0C8h],rax
    12f: imul    rcx,[rbp-0B0h],1
    137: add     rax,rcx
    13a: mov     [rbp-0C0h],rax
    141: mov     [rbp-0B8h],rax
    148: mov     byte ptr [rbp-0F0h],0FFh
    14f: movzx   ecx,byte ptr [rbp-0F0h]
    156: mov     [rax],cl
    158: mov     rax,[rbp+10h]
    15c: mov     rax,[rax]
    15f: mov     [rbp-0F0h],rax
    166: mov     edi,0FFFFFF0Ch
    16b: mov     esi,0FFFFFF10h
    170: xor     edx,edx
    172: xor     ecx,ecx
    174: xor     r8d,r8d
    177: mov     r9d,1
    17d: call    ryo_h_DiscrNicheW64
    182: mov     edi,0FFFFFFD8h
    187: mov     esi,0FFFFFF0Ch
    18c: call    ryo_h_ZextW32W64
    191: mov     edi,0FFFFFFD8h
    196: xor     esi,esi
    198: mov     edx,2
    19d: call    ryo_h_SwitchDenseW64
    1a2: lea     rcx,[1B4h]
    1a9: movsxd  rax,[rcx+rax*4]
    1ad: add     rax,rcx
    1b0: jmp     rax
    1b2: int3
    1b3: int3
    1b4: .long   296h
    1b8: .long   1c0h
    1bc: .long   80h
    1c0: mov     rax,[rbp+10h]
    1c4: mov     rax,[rax]
    1c7: mov     [rbp-0B0h],rax
    1ce: mov     rax,[rbp+18h]
    1d2: mov     rax,[rax]
    1d5: mov     [rbp-58h],rax
    1d9: mov     rax,[rbp+10h]
    1dd: mov     rax,[rax+8]
    1e1: mov     [rbp-0C0h],rax
    1e8: mov     rax,[rbp-58h]
    1ec: mov     rax,[rax]
    1ef: mov     [rbp-0E0h],rax
    1f6: mov     [rbp-0C8h],rax
    1fd: mov     rax,[rbp-0A0h]
    204: add     rax,1
    208: mov     [rbp-0D8h],rax
    20f: imul    rax,[rbp-0C0h]
    217: mov     [rbp-0D0h],rax
    21e: mov     [rbp-0E8h],rax
    225: mov     qword ptr [rbp-0F0h],0
    230: mov     rax,[rbp-0F0h]
    237: sub     rax,[rbp-0E8h]
    23e: mov     [rbp-0D8h],rax
    245: mov     rax,[rbp-0C8h]
    24c: imul    rcx,[rbp-0D8h],1
    254: add     rax,rcx
    257: mov     [rbp-0B8h],rax
    25e: mov     [rbp-110h],rax
    265: mov     edi,0FFFFFF50h
    26a: lea     rsi,[site0]
    271: call    ryo_h_CallInd
    276: test    rax,rax
    279: je      286h
    27b: call    rax
    27d: nop     [rcx-28h]
    284: jmp     296h
    286: mov     rdi,rbp
    289: lea     rsi,[ro+4]
    290: call    qword ptr [sym1]
    296: mov     rax,[rbp+18h]
    29a: mov     rax,[rax]
    29d: mov     [rbp-60h],rax
    2a1: mov     rax,[rbp+18h]
    2a5: mov     rax,[rax]
    2a8: mov     [rbp-68h],rax
    2ac: mov     rax,[rax+18h]
    2b0: mov     [rbp-0F0h],rax
    2b7: sub     rax,1
    2bb: mov     [rbp-100h],rax
    2c2: mov     rax,[rbp-60h]
    2c6: mov     rcx,[rbp-100h]
    2cd: mov     [rax+18h],rcx
    2d1: nop     [rax+rax]
    2da: nop     [rax+rax]
    2e0: jmp     40h
    2e5: mov     rax,[rbp-10h]
    2e9: mov     [rbp-0A8h],rax
    2f0: add     rax,1
    2f4: mov     [rbp-0B0h],rax
    2fb: mov     [rbp-10h],rax
    2ff: mov     rax,[rbp-0A8h]
    306: mov     [rbp-90h],rax
    30d: mov     qword ptr [rbp-98h],1
    318: mov     [rbp-0A0h],rax
    31f: mov     rax,[rbp+18h]
    323: mov     rax,[rax]
    326: mov     [rbp-40h],rax
    32a: mov     rax,[rax]
    32d: mov     [rbp-0C0h],rax
    334: mov     [rbp-0B8h],rax
    33b: imul    rcx,[rbp-0A0h],1
    343: add     rax,rcx
    346: mov     [rbp-0B0h],rax
    34d: mov     [rbp-20h],rax
    351: movzx   eax,byte ptr [rax]
    354: mov     [rbp-0A2h],al
    35a: cmp     al,80h
    35d: sete    [rbp-0A1h]
    364: test    byte ptr [rbp-0A1h],0FFh
    36b: je      2E0h
    371: jmp     90h
    376: mov     rax,[rbp+18h]
    37a: mov     rax,[rax]
    37d: mov     [rbp-48h],rax
    381: mov     rax,[rax+8]
    385: mov     [rbp-30h],rax
    389: cmp     rax,8
    38d: jae     391h
    38f: jmp     3CBh
    391: mov     rax,[rbp-30h]
    395: add     rax,1
    399: mov     [rbp-0A0h],rax
    3a0: mov     qword ptr [rbp-0F0h],8
    3ab: mov     edi,0FFFFFF68h
    3b0: mov     esi,0FFFFFF60h
    3b5: mov     edx,0FFFFFF10h
    3ba: call    ryo_h_DivUW64
    3bf: imul    rax,[rbp-98h],7
    3c7: mov     [rbp-30h],rax
    3cb: mov     rax,[rbp+18h]
    3cf: mov     rax,[rax]
    3d2: mov     [rbp-70h],rax
    3d6: mov     rax,[rax+18h]
    3da: mov     [rbp-90h],rax
    3e1: mov     rax,[rbp+18h]
    3e5: mov     rax,[rax]
    3e8: mov     [rbp-78h],rax
    3ec: mov     rax,[rbp-30h]
    3f0: sub     rax,[rbp-90h]
    3f7: mov     [rbp-0F0h],rax
    3fe: mov     rax,[rbp-78h]
    402: mov     rcx,[rbp-0F0h]
    409: mov     [rax+10h],rcx
    40d: xor     edi,edi
    40f: xor     esi,esi
    411: call    ryo_h_Ret
    416: leave
    417: ret

fn hashbrown::raw::RawTableInner::reserve_rehash_inner::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+18h]
     13: mov     [rbp-20h],rax
     17: mov     edi,0FFFFFFB8h
     1c: mov     esi,0FFFFFFC0h
     21: mov     edx,0FFFFFFE0h
     26: mov     ecx,30h
     2b: call    ryo_h_AddOvfUW64
     30: movzx   eax,byte ptr [rbp-40h]
     34: mov     [rbp-31h],al
     37: test    byte ptr [rbp-31h],0FFh
     3b: je      1A5h
     41: jmp     15Eh
     46: nop     [rax+rax]
     4f: nop
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,0FFFFFFD8h
     5a: call    ryo_h_MovW128
     5f: jmp     14Dh
     64: nop     [rax+rax]
     6d: nop     [rax]
     70: mov     rax,[rbp+38h]
     74: mov     [rbp-30h],rax
     78: mov     rax,[rbp+10h]
     7c: mov     [rbp-90h],rax
     83: mov     edi,0FFFFFF78h
     88: mov     esi,20h
     8d: call    ryo_h_MovW128
     92: mov     rax,[rbp-30h]
     96: mov     [rbp-78h],rax
     9a: mov     rax,[rbp+50h]
     9e: mov     [rbp-70h],rax
     a2: call    fn0
     a7: nop     [rcx-18h]
     ae: mov     edi,0FFFFFFF0h
     b3: lea     rsi,[k1]
     ba: mov     edx,10h
     bf: call    ryo_h_Const
     c4: jmp     14Dh
     c9: nop     [rax]
     d0: mov     rax,[rbp-18h]
     d4: add     rax,1
     d8: mov     [rbp-38h],rax
     dc: mov     rax,[rbp-20h]
     e0: mov     [rbp-90h],rax
     e7: mov     rax,[rbp-38h]
     eb: mov     [rbp-88h],rax
     f2: call    fn2
     f7: nop     [rcx-30h]
     fe: mov     rax,[rbp+10h]
    102: mov     [rbp-90h],rax
    109: mov     rax,[rbp+18h]
    10d: mov     [rbp-88h],rax
    114: mov     rax,[rbp-30h]
    118: mov     [rbp-70h],rax
    11c: mov     edi,0FFFFFF80h
    121: mov     esi,20h
    126: call    ryo_h_MovW128
    12b: movzx   eax,byte ptr [rbp+48h]
    12f: mov     [rbp-68h],al
    132: mov     edi,0FFFFFFA0h
    137: mov     esi,38h
    13c: call    ryo_h_MovW128
    141: call    fn3
    146: nop     [rcx-10h]
    14d: mov     edi,0FFFFFFF0h
    152: mov     esi,10h
    157: call    ryo_h_Ret
    15c: leave
    15d: ret
    15e: movzx   eax,byte ptr [rbp+48h]
    162: mov     [rbp-90h],al
    168: lea     rdi,[sym4]
    16f: lea     rsi,[site5]
    176: mov     edx,0FFFFFFB0h
    17b: call    ryo_h_CallExt
    180: test    rax,rax
    183: je      190h
    185: call    rax
    187: nop     [rcx-28h]
    18e: jmp     1A0h
    190: mov     rdi,rbp
    193: lea     rsi,[ro+4]
    19a: call    qword ptr [sym6]
    1a0: jmp     50h
    1a5: mov     rax,[rbp-20h]
    1a9: add     rax,[rbp+30h]
    1ad: mov     [rbp-38h],rax
    1b1: mov     [rbp-28h],rax
    1b5: mov     qword ptr [rbp-30h],1
    1bd: mov     [rbp-20h],rax
    1c1: mov     rax,[rbp+10h]
    1c5: mov     rax,[rax+8]
    1c9: mov     [rbp-18h],rax
    1cd: cmp     rax,8
    1d1: jae     1D5h
    1d3: jmp     206h
    1d5: mov     rax,[rbp-18h]
    1d9: add     rax,1
    1dd: mov     [rbp-38h],rax
    1e1: mov     qword ptr [rbp-50h],8
    1e9: mov     edi,0FFFFFFD0h
    1ee: mov     esi,0FFFFFFC8h
    1f3: mov     edx,0FFFFFFB0h
    1f8: call    ryo_h_DivUW64
    1fd: imul    rax,[rbp-30h],7
    202: mov     [rbp-18h],rax
    206: mov     rax,[rbp-18h]
    20a: mov     [rbp-38h],rax
    20e: mov     qword ptr [rbp-50h],2
    216: mov     edi,0FFFFFFD0h
    21b: mov     esi,0FFFFFFC8h
    220: mov     edx,0FFFFFFB0h
    225: call    ryo_h_DivUW64
    22a: mov     rax,[rbp-30h]
    22e: cmp     rax,[rbp-20h]
    232: jae     70h
    238: jmp     0D0h

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,240h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-240h],rax
     16: mov     edi,0FFFFFDC8h
     1b: mov     esi,40h
     20: call    ryo_h_MovW128
     25: mov     rax,[rbp+30h]
     29: mov     [rbp-228h],rax
     30: movzx   eax,byte ptr [rbp+38h]
     34: mov     [rbp-220h],al
     3a: call    fn0
     3f: nop     [rcx-1A0h]
     46: jmp     24Dh
     4b: nop     [rax+rax]
     50: call    ryo_h_Unreachable
     55: ud2
     57: nop     [rax+rax]
     60: lea     rax,[rbp-110h]
     67: mov     [rbp-128h],rax
     6e: mov     rax,[rax+10h]
     72: mov     [rbp-130h],rax
     79: cmp     rax,0
     7d: je      5B3h
     83: jmp     5CEh
     88: mov     rax,[rbp-118h]
     8f: mov     [rbp-130h],rax
     96: mov     rax,[rbp+10h]
     9a: mov     [rbp-148h],rax
     a1: mov     rax,[rbp-130h]
     a8: mov     [rbp-140h],rax
     af: mov     rax,[rbp+28h]
     b3: mov     rax,[rax+28h]
     b7: mov     [rbp-1F0h],rax
     be: mov     rax,[rbp+20h]
     c2: mov     [rbp-240h],rax
     c9: mov     rax,[rbp-148h]
     d0: mov     [rbp-238h],rax
     d7: mov     rax,[rbp-140h]
     de: mov     [rbp-230h],rax
     e5: mov     edi,0FFFFFE10h
     ea: lea     rsi,[site1]
     f1: call    ryo_h_CallInd
     f6: test    rax,rax
     f9: je      106h
     fb: call    rax
     fd: nop     [rcx-138h]
    104: jmp     116h
    106: mov     rdi,rbp
    109: lea     rsi,[ro+4]
    110: call    qword ptr [sym2]
    116: jmp     1C3h
    11b: nop     [rax+rax]
    120: mov     rax,[rbp+10h]
    124: mov     rax,[rax+18h]
    128: mov     [rbp-0F8h],rax
    12f: mov     rax,[rbp-0C8h]
    136: sub     rax,[rbp-0F8h]
    13d: mov     [rbp-0C8h],rax
    144: mov     rax,[rbp+10h]
    148: mov     rax,[rax+18h]
    14c: mov     [rbp-0F8h],rax
    153: mov     [rbp-0C0h],rax
    15a: mov     rax,[rbp+10h]
    15e: mov     [rbp-0F8h],rax
    165: lea     rax,[rbp-0D8h]
    16c: mov     [rbp-100h],rax
    173: mov     qword ptr [rbp-218h],20h
    17e: mov     edi,0FFFFFDF0h
    183: mov     esi,0FFFFFF08h
    188: xor     edx,edx
    18a: mov     ecx,20h
    18f: call    ryo_h_LoadCopy
    194: mov     edi,0FFFFFF08h
    199: mov     esi,0FFFFFF00h
    19e: mov     edx,0FFFFFDE8h
    1a3: call    ryo_h_Memcpy
    1a8: mov     edi,0FFFFFF00h
    1ad: xor     esi,esi
    1af: mov     edx,0FFFFFDF0h
    1b4: mov     ecx,20h
    1b9: call    ryo_h_StoreCopy
    1be: jmp     888h
    1c3: lea     rax,[rbp-0D8h]
    1ca: mov     [rbp-140h],rax
    1d1: mov     [rbp-240h],rax
    1d8: mov     rax,[rbp-138h]
    1df: mov     [rbp-238h],rax
    1e6: call    fn3
    1eb: nop     [rcx-0B0h]
    1f2: jmp     650h
    1f7: nop     [rax+rax]
    200: mov     edi,0FFFFFFF0h
    205: mov     esi,10h
    20a: call    ryo_h_Ret
    20f: leave
    210: ret
    211: nop     [rax+rax]
    21a: nop     [rax+rax]
    220: lea     rax,[rbp-0F0h]
    227: mov     [rbp-1F0h],rax
    22e: mov     [rbp-240h],rax
    235: call    fn4
    23a: nop     [rcx-1F0h]
    241: mov     edi,0FFFFFF48h
    246: call    ryo_h_Resume
    24b: ud2
    24d: mov     edi,0FFFFFE14h
    252: mov     esi,0FFFFFE60h
    257: xor     edx,edx
    259: mov     ecx,1
    25e: mov     r8d,1
    264: xor     r9d,r9d
    267: call    ryo_h_DiscrNicheW64
    26c: mov     edi,0FFFFFE38h
    271: mov     esi,0FFFFFE14h
    276: call    ryo_h_ZextW32W64
    27b: mov     edi,0FFFFFE38h
    280: xor     esi,esi
    282: mov     edx,2
    287: call    ryo_h_SwitchDenseW64
    28c: lea     rcx,[29Ch]
    293: movsxd  rax,[rcx+rax*4]
    297: add     rax,rcx
    29a: jmp     rax
    29c: .long   3b6h
    2a0: .long   2a8h
    2a4: .long   50h
    2a8: mov     edi,0FFFFFE28h
    2ad: mov     esi,0FFFFFE68h
    2b2: call    ryo_h_MovW128
    2b7: mov     edi,0FFFFFE18h
    2bc: mov     esi,0FFFFFE28h
    2c1: call    ryo_h_MovW128
    2c6: mov     edi,0FFFFFE88h
    2cb: mov     esi,0FFFFFE18h
    2d0: call    ryo_h_MovW128
    2d5: mov     qword ptr [rbp-180h],0
    2e0: mov     edi,0FFFFFE70h
    2e5: mov     esi,0FFFFFE88h
    2ea: call    ryo_h_MovW128
    2ef: mov     qword ptr [rbp-198h],1
    2fa: cmp     qword ptr [rbp-198h],1
    302: sete    [rbp-199h]
    309: mov     edi,0FFFFFE30h
    30e: mov     esi,0FFFFFE70h
    313: call    ryo_h_MovW128
    318: mov     edi,0FFFFFEA8h
    31d: mov     esi,0FFFFFE30h
    322: call    ryo_h_MovW128
    327: mov     qword ptr [rbp-160h],0
    332: mov     edi,0FFFFFE90h
    337: mov     esi,0FFFFFEA8h
    33c: call    ryo_h_MovW128
    341: mov     edi,0FFFFFE80h
    346: mov     esi,0FFFFFE90h
    34b: call    ryo_h_MovW128
    350: mov     edi,0FFFFFEE0h
    355: mov     esi,0FFFFFE80h
    35a: call    ryo_h_MovW128
    35f: mov     qword ptr [rbp-128h],0
    36a: mov     edi,0FFFFFEC8h
    36f: mov     esi,0FFFFFEE0h
    374: call    ryo_h_MovW128
    379: mov     qword ptr [rbp-140h],1
    384: cmp     qword ptr [rbp-140h],1
    38c: sete    [rbp-151h]
    393: mov     edi,0FFFFFEB0h
    398: mov     esi,0FFFFFEC8h
    39d: call    ryo_h_MovW128
    3a2: mov     edi,0FFFFFFF0h
    3a7: mov     esi,0FFFFFEB0h
    3ac: call    ryo_h_MovW128
    3b1: jmp     200h
    3b6: mov     edi,0FFFFFE18h
    3bb: mov     esi,0FFFFFE60h
    3c0: mov     edx,20h
    3c5: call    ryo_h_Copy
    3ca: mov     edi,0FFFFFE80h
    3cf: mov     esi,0FFFFFE18h
    3d4: mov     edx,20h
    3d9: call    ryo_h_Copy
    3de: mov     edi,0FFFFFE40h
    3e3: mov     esi,0FFFFFE80h
    3e8: mov     edx,20h
    3ed: call    ryo_h_Copy
    3f2: mov     rax,[rbp+18h]
    3f6: mov     [rbp-1D8h],rax
    3fd: mov     edi,0FFFFFE30h
    402: mov     esi,40h
    407: call    ryo_h_MovW128
    40c: mov     edi,0FFFFFE68h
    411: mov     esi,0FFFFFE28h
    416: mov     edx,18h
    41b: call    ryo_h_Copy
    420: mov     edi,0FFFFFE80h
    425: mov     esi,0FFFFFE40h
    42a: mov     edx,20h
    42f: call    ryo_h_Copy
    434: mov     edi,0FFFFFEA0h
    439: mov     esi,0FFFFFE68h
    43e: mov     edx,38h
    443: call    ryo_h_Copy
    448: mov     edi,0FFFFFE68h
    44d: mov     esi,0FFFFFEA0h
    452: mov     edx,38h
    457: call    ryo_h_Copy
    45c: mov     edi,0FFFFFED8h
    461: mov     esi,0FFFFFE68h
    466: mov     edx,38h
    46b: call    ryo_h_Copy
    470: mov     edi,0FFFFFEA0h
    475: mov     esi,0FFFFFED8h
    47a: mov     edx,38h
    47f: call    ryo_h_Copy
    484: mov     edi,0FFFFFF10h
    489: mov     esi,0FFFFFEA0h
    48e: mov     edx,38h
    493: call    ryo_h_Copy
    498: mov     rax,[rbp+10h]
    49c: mov     rax,[rax]
    49f: mov     [rbp-118h],rax
    4a6: mov     [rbp-110h],rax
    4ad: mov     rax,[rbp-118h]
    4b4: mov     [rbp-0F8h],rax
    4bb: mov     rax,[rbp-118h]
    4c2: mov     [rbp-108h],rax
    4c9: mov     rax,[rbp-118h]
    4d0: mov     [rbp-120h],rax
    4d7: mov     [rbp-240h],rax
    4de: mov     edi,0FFFFFE10h
    4e3: lea     rsi,[sym5]
    4ea: call    ryo_h_AddrSym
    4ef: mov     rdi,rbp
    4f2: lea     rsi,[ro+20]
    4f9: call    qword ptr [sym6]
    4ff: mov     edi,0FFFFFDC0h
    504: mov     esi,0FFFFFED0h
    509: call    ryo_h_MovW128
    50e: mov     edi,0FFFFFE10h
    513: lea     rsi,[sym7]
    51a: call    ryo_h_AddrSym
    51f: mov     rdi,rbp
    522: lea     rsi,[ro+36]
    529: call    qword ptr [sym8]
    52f: mov     edi,0FFFFFF00h
    534: mov     esi,0FFFFFEFCh
    539: call    ryo_h_TruncW32W16
    53e: mov     edi,0FFFFFF02h
    543: mov     esi,0FFFFFF00h
    548: call    ryo_h_NotW16
    54d: movzx   eax,word ptr [rbp-0FEh]
    554: mov     [rbp-0FCh],ax
    55b: mov     [rbp-0FAh],ax
    562: mov     rax,[rbp+10h]
    566: mov     rax,[rax+18h]
    56a: mov     [rbp-108h],rax
    571: movzx   eax,word ptr [rbp-0FAh]
    578: mov     [rbp-18h],ax
    57c: mov     qword ptr [rbp-28h],0
    584: mov     rax,[rbp-118h]
    58b: mov     [rbp-30h],rax
    58f: mov     rax,[rbp-108h]
    596: mov     [rbp-20h],rax
    59a: mov     edi,0FFFFFEF0h
    59f: mov     esi,0FFFFFFD0h
    5a4: mov     edx,20h
    5a9: call    ryo_h_Copy
    5ae: jmp     60h
    5b3: mov     edi,0FFFFFEE0h
    5b8: lea     rsi,[k9]
    5bf: mov     edx,10h
    5c4: call    ryo_h_Const
    5c9: jmp     120h
    5ce: mov     rax,[rbp-128h]
    5d5: mov     [rbp-240h],rax
    5dc: call    fn10
    5e1: nop     [rcx-120h]
    5e8: mov     rax,[rbp-128h]
    5ef: mov     rax,[rax+10h]
    5f3: mov     [rbp-1F0h],rax
    5fa: sub     rax,1
    5fe: mov     [rbp-200h],rax
    605: mov     rax,[rbp-128h]
    60c: mov     rcx,[rbp-200h]
    613: mov     [rax+10h],rcx
    617: mov     rax,[rbp-120h]
    61e: mov     [rbp-38h],rax
    622: mov     edi,0FFFFFFC8h
    627: xor     esi,esi
    629: mov     edx,2
    62e: call    ryo_h_SwitchDenseW64
    633: lea     rcx,[644h]
    63a: movsxd  rax,[rcx+rax*4]
    63e: add     rax,rcx
    641: jmp     rax
    643: int3
    644: .long   120h
    648: .long   88h
    64c: .long   50h
    650: mov     rax,[rbp-0D8h]
    657: mov     [rbp-158h],rax
    65e: mov     [rbp-150h],rax
    665: imul    rcx,[rbp-0B0h],1
    66d: add     rax,rcx
    670: mov     [rbp-148h],rax
    677: mov     [rbp-140h],rax
    67e: movzx   eax,byte ptr [rax]
    681: mov     [rbp-169h],al
    687: mov     rax,[rbp-138h]
    68e: shr     rax,39h
    692: mov     [rbp-148h],rax
    699: and     rax,7Fh
    69d: mov     [rbp-150h],rax
    6a4: mov     edi,0FFFFFEC6h
    6a9: mov     esi,0FFFFFEB0h
    6ae: call    ryo_h_TruncW64W8
    6b3: movzx   eax,byte ptr [rbp-13Ah]
    6ba: mov     [rbp-139h],al
    6c0: mov     rax,[rbp-0B0h]
    6c7: sub     rax,10h
    6cb: mov     [rbp-158h],rax
    6d2: mov     rax,[rbp-0D0h]
    6d9: mov     [rbp-160h],rax
    6e0: mov     rax,[rbp-158h]
    6e7: and     rax,[rbp-160h]
    6ee: mov     [rbp-150h],rax
    6f5: add     rax,10h
    6f9: mov     [rbp-148h],rax
    700: mov     rax,[rbp-0D8h]
    707: mov     [rbp-168h],rax
    70e: mov     [rbp-160h],rax
    715: imul    rcx,[rbp-0B0h],1
    71d: add     rax,rcx
    720: mov     [rbp-158h],rax
    727: mov     [rbp-150h],rax
    72e: movzx   ecx,byte ptr [rbp-139h]
    735: mov     [rax],cl
    737: mov     rax,[rbp-0D8h]
    73e: mov     [rbp-168h],rax
    745: mov     [rbp-160h],rax
    74c: imul    rcx,[rbp-148h],1
    754: add     rax,rcx
    757: mov     [rbp-158h],rax
    75e: mov     [rbp-150h],rax
    765: movzx   ecx,byte ptr [rbp-139h]
    76c: mov     [rax],cl
    76e: mov     rax,[rbp+40h]
    772: mov     [rbp-50h],rax
    776: mov     rax,[rbp+10h]
    77a: mov     rax,[rax]
    77d: mov     [rbp-168h],rax
    784: mov     [rbp-150h],rax
    78b: mov     rax,[rbp-130h]
    792: add     rax,1
    796: mov     [rbp-160h],rax
    79d: imul    rax,[rbp-50h]
    7a2: mov     [rbp-158h],rax
    7a9: mov     [rbp-170h],rax
    7b0: mov     qword ptr [rbp-1F0h],0
    7bb: mov     rax,[rbp-1F0h]
    7c2: sub     rax,[rbp-170h]
    7c9: mov     [rbp-160h],rax
    7d0: mov     rax,[rbp-150h]
    7d7: imul    rcx,[rbp-160h],1
    7df: add     rax,rcx
    7e2: mov     [rbp-148h],rax
    7e9: mov     [rbp-140h],rax
    7f0: mov     rax,[rbp-0D8h]
    7f7: mov     [rbp-168h],rax
    7fe: mov     [rbp-150h],rax
    805: mov     rax,[rbp-0B0h]
    80c: add     rax,1
    810: mov     [rbp-160h],rax
    817: imul    rax,[rbp-50h]
    81c: mov     [rbp-158h],rax
    823: mov     [rbp-170h],rax
    82a: mov     qword ptr [rbp-1F0h],0
    835: mov     rax,[rbp-1F0h]
    83c: sub     rax,[rbp-170h]
    843: mov     [rbp-160h],rax
    84a: mov     rax,[rbp-150h]
    851: imul    rcx,[rbp-160h],1
    859: add     rax,rcx
    85c: mov     [rbp-148h],rax
    863: imul    rax,[rbp-50h],1
    868: mov     [rbp-1F0h],rax
    86f: mov     edi,0FFFFFEB8h
    874: mov     esi,0FFFFFEC0h
    879: mov     edx,0FFFFFE10h
    87e: call    ryo_h_Memcpy
    883: jmp     60h
    888: mov     edi,0FFFFFFF0h
    88d: lea     rsi,[k11]
    894: mov     edx,10h
    899: call    ryo_h_Const
    89e: lea     rax,[rbp-0F0h]
    8a5: mov     [rbp-1F0h],rax
    8ac: mov     [rbp-240h],rax
    8b3: call    fn12
    8b8: nop     [rcx-1F0h]
    8bf: jmp     200h
    8c4: nop     [rax+rax]
    8cd: nop     [rax]
    8d0: lea     rdi,[sym13]
    8d7: lea     rsi,[site14]
    8de: mov     edx,0FFFFFE10h
    8e3: call    ryo_h_CallExt
    8e8: test    rax,rax
    8eb: je      8F8h
    8ed: call    rax
    8ef: nop     [rcx-1E8h]
    8f6: jmp     908h
    8f8: mov     rdi,rbp
    8fb: lea     rsi,[ro+52]
    902: call    qword ptr [sym15]
    908: call    ryo_h_Unreachable
    90d: ud2
    90f: mov     rdi,rax
    912: mov     esi,0FFFFFF48h
    917: call    ryo_h_Lpad
    91c: jmp     220h
    921: mov     rdi,rax
    924: mov     esi,0FFFFFF48h
    929: call    ryo_h_Lpad
    92e: jmp     8D0h

fn hashbrown::raw::TableLayout::calculate_layout_for
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-48h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-50h],rax
     1b: mov     rax,[rbp-48h]
     1f: mov     [rbp-0A0h],rax
     26: mov     rax,[rbp+20h]
     2a: mov     [rbp-0C0h],rax
     31: mov     edi,0FFFFFF48h
     36: mov     esi,0FFFFFF50h
     3b: mov     edx,0FFFFFF60h
     40: mov     ecx,0FFFFFF40h
     45: call    ryo_h_MulOvfUW64
     4a: mov     rax,[rbp-0B8h]
     51: mov     [rbp-0A0h],rax
     58: movzx   eax,byte ptr [rbp-0B0h]
     5f: mov     [rbp-0A1h],al
     65: mov     rax,[rbp-0A0h]
     6c: mov     [rbp-0C8h],rax
     73: test    byte ptr [rbp-0A1h],0FFh
     7a: je      14Bh
     80: jmp     111h
     85: nop     [rax+rax]
     8e: xchg    ax,ax
     90: mov     qword ptr [rbp-18h],0
     98: jmp     0F0h
     9a: nop     [rax+rax]
     a0: mov     rax,[rbp-50h]
     a4: mov     [rbp-88h],rax
     ab: mov     rax,[rbp-40h]
     af: mov     [rbp-78h],rax
     b3: mov     rax,[rbp-88h]
     ba: mov     [rbp-80h],rax
     be: mov     edi,0FFFFFF90h
     c3: mov     esi,0FFFFFF80h
     c8: call    ryo_h_MovW128
     cd: mov     rax,[rbp-58h]
     d1: mov     [rbp-60h],rax
     d5: mov     edi,0FFFFFFE8h
     da: mov     esi,0FFFFFF90h
     df: mov     edx,18h
     e4: call    ryo_h_Copy
     e9: jmp     100h
     eb: nop     [rax+rax]
     f0: jmp     100h
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: mov     edi,0FFFFFFE8h
    105: mov     esi,18h
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: mov     edi,0FFFFFF68h
    116: lea     rsi,[k0]
    11d: mov     edx,10h
    122: call    ryo_h_Const
    127: mov     qword ptr [rbp-90h],0
    132: cmp     qword ptr [rbp-90h],0
    13a: sete    [rbp-91h]
    141: mov     qword ptr [rbp-18h],0
    149: jmp     100h
    14b: mov     rax,[rbp-0C8h]
    152: mov     [rbp-90h],rax
    159: mov     qword ptr [rbp-98h],1
    164: mov     [rbp-0A0h],rax
    16b: mov     [rbp-80h],rax
    16f: mov     qword ptr [rbp-88h],0
    17a: mov     [rbp-28h],rax
    17e: mov     rax,[rbp-50h]
    182: sub     rax,1
    186: mov     [rbp-30h],rax
    18a: mov     edi,0FFFFFF60h
    18f: mov     esi,0FFFFFF68h
    194: mov     edx,0FFFFFFD8h
    199: mov     ecx,0FFFFFFD0h
    19e: call    ryo_h_AddOvfUW64
    1a3: movzx   eax,byte ptr [rbp-98h]
    1aa: mov     [rbp-89h],al
    1b0: test    byte ptr [rbp-89h],0FFh
    1b7: je      1EDh
    1b9: mov     edi,0FFFFFF88h
    1be: lea     rsi,[k1]
    1c5: mov     edx,10h
    1ca: call    ryo_h_Const
    1cf: mov     qword ptr [rbp-70h],0
    1d7: cmp     qword ptr [rbp-70h],0
    1dc: sete    [rbp-71h]
    1e0: mov     qword ptr [rbp-18h],0
    1e8: jmp     100h
    1ed: mov     rax,[rbp-28h]
    1f1: add     rax,[rbp-30h]
    1f5: mov     [rbp-90h],rax
    1fc: mov     [rbp-70h],rax
    200: mov     qword ptr [rbp-78h],1
    208: mov     [rbp-90h],rax
    20f: mov     [rbp-60h],rax
    213: mov     qword ptr [rbp-68h],0
    21b: mov     [rbp-38h],rax
    21f: mov     edi,0FFFFFF90h
    224: mov     esi,0FFFFFFD0h
    229: call    ryo_h_NotW64
    22e: mov     rax,[rbp-38h]
    232: and     rax,[rbp-70h]
    236: mov     [rbp-58h],rax
    23a: mov     rax,[rbp+20h]
    23e: add     rax,10h
    242: mov     [rbp-80h],rax
    246: mov     edi,0FFFFFF68h
    24b: mov     esi,0FFFFFF70h
    250: mov     edx,0FFFFFFA8h
    255: mov     ecx,0FFFFFF80h
    25a: call    ryo_h_AddOvfUW64
    25f: movzx   eax,byte ptr [rbp-90h]
    266: mov     [rbp-81h],al
    26c: test    byte ptr [rbp-81h],0FFh
    273: je      2A9h
    275: mov     edi,0FFFFFF88h
    27a: lea     rsi,[k2]
    281: mov     edx,10h
    286: call    ryo_h_Const
    28b: mov     qword ptr [rbp-70h],0
    293: cmp     qword ptr [rbp-70h],0
    298: sete    [rbp-71h]
    29c: mov     qword ptr [rbp-18h],0
    2a4: jmp     0F0h
    2a9: mov     rax,[rbp-58h]
    2ad: add     rax,[rbp-80h]
    2b1: mov     [rbp-88h],rax
    2b8: mov     [rbp-70h],rax
    2bc: mov     qword ptr [rbp-78h],1
    2c4: mov     [rbp-80h],rax
    2c8: mov     [rbp-60h],rax
    2cc: mov     qword ptr [rbp-68h],0
    2d4: mov     [rbp-40h],rax
    2d8: mov     rax,7FFFFFFFFFFFFFFFh
    2e2: mov     [rbp-0D0h],rax
    2e9: sub     rax,[rbp-30h]
    2ed: mov     [rbp-68h],rax
    2f1: cmp     rax,[rbp-40h]
    2f5: jb      90h
    2fb: jmp     0A0h

fn hashbrown::raw::capacity_to_buckets
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: cmp     qword ptr [rbp+10h],0Fh
     10: jae     106h
     16: mov     rax,[rbp+18h]
     1a: mov     [rbp-38h],rax
     1e: mov     qword ptr [rbp-0A8h],0
     29: mov     rax,[rbp-0A8h]
     30: cmp     rax,[rbp-38h]
     34: setbe   [rbp-3Bh]
     38: test    byte ptr [rbp-3Bh],0FFh
     3c: je      60h
     3e: jmp     89h
     40: mov     qword ptr [rbp-30h],3
     48: jmp     9Ah
     4a: nop     [rax+rax]
     50: mov     qword ptr [rbp-30h],0Eh
     58: jmp     9Ah
     5a: nop     [rax+rax]
     60: mov     qword ptr [rbp-0A8h],2
     6b: mov     rax,[rbp-0A8h]
     72: cmp     rax,[rbp-38h]
     76: setbe   [rbp-39h]
     7a: test    byte ptr [rbp-39h],0FFh
     7e: je      40h
     80: cmp     qword ptr [rbp-38h],3
     85: jbe     92h
     87: jmp     40h
     89: cmp     qword ptr [rbp-38h],1
     8e: jbe     50h
     90: jmp     60h
     92: mov     qword ptr [rbp-30h],7
     9a: mov     rax,[rbp-30h]
     9e: mov     [rbp-0C0h],rax
     a5: mov     rax,[rbp+10h]
     a9: mov     [rbp-0B8h],rax
     b0: call    fn0
     b5: nop     [rcx-60h]
     bc: cmp     qword ptr [rbp-60h],4
     c1: jae     0CDh
     c3: mov     qword ptr [rbp-48h],4
     cb: jmp     0E6h
     cd: cmp     qword ptr [rbp-60h],8
     d2: jae     0DEh
     d4: mov     qword ptr [rbp-48h],8
     dc: jmp     0E6h
     de: mov     qword ptr [rbp-48h],10h
     e6: mov     rax,[rbp+20h]
     ea: mov     [rbp-98h],rax
     f1: mov     rax,[rbp-48h]
     f5: mov     [rbp-68h],rax
     f9: cmp     qword ptr [rbp-38h],0
     fe: je      1D0h
    104: jmp     181h
    106: mov     rax,[rbp+10h]
    10a: mov     [rbp-80h],rax
    10e: mov     qword ptr [rbp-0A8h],8
    119: mov     edi,0FFFFFF68h
    11e: mov     esi,0FFFFFF70h
    123: mov     edx,0FFFFFF80h
    128: mov     ecx,0FFFFFF58h
    12d: call    ryo_h_MulOvfUW64
    132: mov     rax,[rbp-98h]
    139: mov     [rbp-80h],rax
    13d: movzx   eax,byte ptr [rbp-90h]
    144: mov     [rbp-81h],al
    14a: mov     rax,[rbp-80h]
    14e: mov     [rbp-0A0h],rax
    155: test    byte ptr [rbp-81h],0FFh
    15c: je      233h
    162: jmp     1F1h
    167: nop     [rax+rax]
    170: mov     edi,0FFFFFFF0h
    175: mov     esi,10h
    17a: call    ryo_h_Ret
    17f: leave
    180: ret
    181: mov     rax,[rbp-38h]
    185: mov     [rbp-70h],rax
    189: mov     rax,[rbp-68h]
    18d: mov     [rbp-88h],rax
    194: mov     edi,0FFFFFF80h
    199: mov     esi,0FFFFFF88h
    19e: mov     edx,0FFFFFF90h
    1a3: mov     ecx,0FFFFFF78h
    1a8: call    ryo_h_MulOvfUW64
    1ad: mov     rax,[rbp-80h]
    1b1: mov     [rbp-70h],rax
    1b5: movzx   eax,byte ptr [rbp-78h]
    1b9: mov     [rbp-52h],al
    1bc: mov     rax,[rbp-70h]
    1c0: mov     [rbp-90h],rax
    1c7: test    byte ptr [rbp-52h],0FFh
    1cb: je      1EFh
    1cd: jmp     1E2h
    1cf: nop
    1d0: mov     rax,[rbp-48h]
    1d4: mov     [rbp-8],rax
    1d8: mov     qword ptr [rbp-10h],1
    1e0: jmp     170h
    1e2: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    1ed: jmp     1D0h
    1ef: jmp     1D0h
    1f1: mov     edi,0FFFFFF88h
    1f6: lea     rsi,[k1]
    1fd: mov     edx,10h
    202: call    ryo_h_Const
    207: mov     qword ptr [rbp-70h],0
    20f: cmp     qword ptr [rbp-70h],0
    214: sete    [rbp-71h]
    218: mov     edi,0FFFFFFF0h
    21d: lea     rsi,[k2]
    224: mov     edx,10h
    229: call    ryo_h_Const
    22e: jmp     170h
    233: mov     rax,[rbp-0A0h]
    23a: mov     [rbp-70h],rax
    23e: mov     qword ptr [rbp-78h],1
    246: mov     [rbp-80h],rax
    24a: mov     [rbp-60h],rax
    24e: mov     qword ptr [rbp-68h],0
    256: mov     [rbp-50h],rax
    25a: mov     qword ptr [rbp-0A8h],7
    265: mov     edi,0FFFFFFA8h
    26a: mov     esi,0FFFFFFB0h
    26f: mov     edx,0FFFFFF58h
    274: call    ryo_h_DivUW64
    279: cmp     qword ptr [rbp-58h],1
    27e: jbe     34Ah
    284: jmp     357h
    289: nop     [rax]
    290: mov     rax,[rbp-78h]
    294: mov     [rbp-60h],rax
    298: mov     rax,[rbp+18h]
    29c: mov     [rbp-98h],rax
    2a3: mov     rax,[rbp+20h]
    2a7: mov     [rbp-0A0h],rax
    2ae: cmp     qword ptr [rbp-98h],0
    2b6: je      410h
    2bc: jmp     3B1h
    2c1: nop     [rax+rax]
    2ca: nop     [rax+rax]
    2d0: mov     qword ptr [rbp-0A8h],1
    2db: mov     edi,0FFFFFF88h
    2e0: mov     esi,0FFFFFF90h
    2e5: mov     edx,0FFFFFF98h
    2ea: mov     ecx,0FFFFFF58h
    2ef: call    ryo_h_AddOvfUW64
    2f4: test    byte ptr [rbp-70h],0FFh
    2f8: je      290h
    2fa: mov     edi,0FFFFFF40h
    2ff: lea     rsi,[k3]
    306: call    ryo_h_AddrAbs
    30b: lea     rdi,[sym4]
    312: lea     rsi,[site5]
    319: mov     edx,0FFFFFF58h
    31e: call    ryo_h_CallExt
    323: test    rax,rax
    326: je      333h
    328: call    rax
    32a: nop     [rcx-0A0h]
    331: jmp     343h
    333: mov     rdi,rbp
    336: lea     rsi,[ro+4]
    33d: call    qword ptr [sym6]
    343: call    ryo_h_Unreachable
    348: ud2
    34a: mov     qword ptr [rbp-68h],0
    352: jmp     2D0h
    357: mov     rax,[rbp-58h]
    35b: sub     rax,1
    35f: mov     [rbp-80h],rax
    363: mov     edi,0FFFFFF5Ch
    368: mov     esi,0FFFFFF80h
    36d: call    ryo_h_CtlzW64
    372: mov     eax,[rbp-0A4h]
    378: mov     [rbp-84h],eax
    37e: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    389: mov     edi,0FFFFFF50h
    38e: mov     esi,0FFFFFF7Ch
    393: call    ryo_h_ZextW32W64
    398: mov     edi,0FFFFFF98h
    39d: mov     esi,0FFFFFF58h
    3a2: mov     edx,0FFFFFF50h
    3a7: call    ryo_h_ShrUW64
    3ac: jmp     2D0h
    3b1: mov     rax,[rbp-98h]
    3b8: mov     [rbp-68h],rax
    3bc: mov     rax,[rbp-60h]
    3c0: mov     [rbp-88h],rax
    3c7: mov     edi,0FFFFFF80h
    3cc: mov     esi,0FFFFFF88h
    3d1: mov     edx,0FFFFFF98h
    3d6: mov     ecx,0FFFFFF78h
    3db: call    ryo_h_MulOvfUW64
    3e0: mov     rax,[rbp-80h]
    3e4: mov     [rbp-68h],rax
    3e8: movzx   eax,byte ptr [rbp-78h]
    3ec: mov     [rbp-69h],al
    3ef: mov     rax,[rbp-68h]
    3f3: mov     [rbp-90h],rax
    3fa: test    byte ptr [rbp-69h],0FFh
    3fe: je      432h
    400: jmp     425h
    402: nop     [rax+rax]
    40b: nop     [rax+rax]
    410: mov     rax,[rbp-60h]
    414: mov     [rbp-8],rax
    418: mov     qword ptr [rbp-10h],1
    420: jmp     170h
    425: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    430: jmp     410h
    432: jmp     410h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+20h]
     13: mov     [rbp-48h],rax
     17: lea     rax,[rbp+18h]
     1b: mov     [rbp-50h],rax
     1f: mov     rax,[rbp-48h]
     23: mov     [rbp-0B0h],rax
     2a: mov     rax,[rbp-50h]
     2e: mov     [rbp-0A8h],rax
     35: call    fn0
     3a: nop     [rcx-40h]
     41: jmp     19Ah
     46: nop     [rax+rax]
     4f: nop
     50: mov     edi,0FFFFFF74h
     55: mov     esi,0FFFFFFB8h
     5a: xor     edx,edx
     5c: xor     ecx,ecx
     5e: xor     r8d,r8d
     61: mov     r9d,1
     67: call    ryo_h_DiscrNicheW64
     6c: mov     edi,0FFFFFFD0h
     71: mov     esi,0FFFFFF74h
     76: call    ryo_h_ZextW32W64
     7b: mov     edi,0FFFFFFD0h
     80: xor     esi,esi
     82: mov     edx,2
     87: call    ryo_h_SwitchDenseW64
     8c: lea     rcx,[9Ch]
     93: movsxd  rax,[rcx+rax*4]
     97: add     rax,rcx
     9a: jmp     rax
     9c: .long   ffh
     a0: .long   a8h
     a4: .long   23fh
     a8: mov     rax,[rbp-48h]
     ac: mov     [rbp-50h],rax
     b0: mov     rax,[rbp+10h]
     b4: mov     [rbp-68h],rax
     b8: mov     rax,[rbp-50h]
     bc: mov     [rbp-60h],rax
     c0: mov     rax,[rbp-68h]
     c4: mov     [rbp-58h],rax
     c8: mov     edi,0FFFFFFE0h
     cd: mov     esi,0FFFFFFA0h
     d2: call    ryo_h_MovW128
     d7: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
     df: lea     rax,[rbp+18h]
     e3: mov     [rbp-90h],rax
     ea: mov     [rbp-0B0h],rax
     f1: call    fn1
     f6: nop     [rcx-90h]
     fd: jmp     150h
     ff: mov     rax,[rbp+10h]
    103: mov     [rbp-48h],rax
    107: mov     rax,[rbp+10h]
    10b: lea     rax,[rax+20h]
    10f: mov     [rbp-58h],rax
    113: mov     [rbp-50h],rax
    117: mov     rax,[rbp-48h]
    11b: mov     [rbp-0B0h],rax
    122: mov     qword ptr [rbp-0A8h],1
    12d: mov     rax,[rbp-50h]
    131: mov     [rbp-0A0h],rax
    138: call    fn2
    13d: nop     [rcx-30h]
    144: jmp     1E0h
    149: nop     [rax]
    150: mov     edi,0FFFFFFD8h
    155: mov     esi,28h
    15a: call    ryo_h_Ret
    15f: leave
    160: ret
    161: nop     [rax+rax]
    16a: nop     [rax+rax]
    170: lea     rax,[rbp+18h]
    174: mov     [rbp-90h],rax
    17b: mov     [rbp-0B0h],rax
    182: call    fn3
    187: nop     [rcx-90h]
    18e: mov     edi,0FFFFFFC8h
    193: call    ryo_h_Resume
    198: ud2
    19a: mov     rax,[rbp+10h]
    19e: mov     [rbp-50h],rax
    1a2: lea     rax,[rbp+18h]
    1a6: mov     [rbp-60h],rax
    1aa: mov     [rbp-58h],rax
    1ae: mov     rax,[rbp-50h]
    1b2: mov     [rbp-0B0h],rax
    1b9: mov     rax,[rbp-40h]
    1bd: mov     [rbp-0A8h],rax
    1c4: mov     rax,[rbp-58h]
    1c8: mov     [rbp-0A0h],rax
    1cf: call    fn4
    1d4: nop     [rcx-48h]
    1db: jmp     50h
    1e0: mov     edi,0FFFFFF80h
    1e5: mov     esi,18h
    1ea: mov     edx,18h
    1ef: call    ryo_h_Copy
    1f4: mov     rax,[rbp+10h]
    1f8: mov     [rbp-88h],rax
    1ff: mov     rax,[rbp-40h]
    203: mov     [rbp-48h],rax
    207: mov     edi,0FFFFFF98h
    20c: mov     esi,0FFFFFF80h
    211: mov     edx,18h
    216: call    ryo_h_Copy
    21b: mov     rax,[rbp-88h]
    222: mov     [rbp-50h],rax
    226: mov     edi,0FFFFFFD8h
    22b: mov     esi,0FFFFFF98h
    230: mov     edx,28h
    235: call    ryo_h_Copy
    23a: jmp     150h
    23f: call    ryo_h_Unreachable
    244: ud2
    246: nop     [rax+rax]
    24f: nop
    250: lea     rdi,[sym5]
    257: lea     rsi,[site6]
    25e: mov     edx,0FFFFFF70h
    263: call    ryo_h_CallExt
    268: test    rax,rax
    26b: je      278h
    26d: call    rax
    26f: nop     [rcx-88h]
    276: jmp     288h
    278: mov     rdi,rbp
    27b: lea     rsi,[ro+4]
    282: call    qword ptr [sym7]
    288: call    ryo_h_Unreachable
    28d: ud2
    28f: mov     rdi,rax
    292: mov     esi,0FFFFFFC8h
    297: call    ryo_h_Lpad
    29c: jmp     170h
    2a1: mov     rdi,rax
    2a4: mov     esi,0FFFFFFC8h
    2a9: call    ryo_h_Lpad
    2ae: jmp     250h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-18h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-10h]
     27: mov     [rbp-28h],rax
     2b: call    fn0
     30: nop     [rcx-1]
     37: mov     edi,0FFFFFFFFh
     3c: mov     esi,1
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+20h]
     13: mov     [rbp-38h],rax
     17: lea     rax,[rbp+18h]
     1b: mov     [rbp-40h],rax
     1f: mov     rax,[rbp-38h]
     23: mov     [rbp-80h],rax
     27: mov     rax,[rbp-40h]
     2b: mov     [rbp-78h],rax
     2f: call    fn0
     34: nop     [rcx-30h]
     3b: jmp     13Ch
     40: mov     edi,0FFFFFFA4h
     45: mov     esi,0FFFFFFC8h
     4a: xor     edx,edx
     4c: xor     ecx,ecx
     4e: xor     r8d,r8d
     51: mov     r9d,1
     57: call    ryo_h_DiscrNicheW64
     5c: mov     edi,0FFFFFFE0h
     61: mov     esi,0FFFFFFA4h
     66: call    ryo_h_ZextW32W64
     6b: mov     edi,0FFFFFFE0h
     70: xor     esi,esi
     72: mov     edx,2
     77: call    ryo_h_SwitchDenseW64
     7c: lea     rcx,[8Ch]
     83: movsxd  rax,[rcx+rax*4]
     87: add     rax,rcx
     8a: jmp     rax
     8c: .long   d1h
     90: .long   98h
     94: .long   1bah
     98: mov     rax,[rbp-38h]
     9c: mov     [rbp-40h],rax
     a0: mov     rax,[rbp+10h]
     a4: mov     [rbp-58h],rax
     a8: mov     rax,[rbp-40h]
     ac: mov     [rbp-50h],rax
     b0: mov     rax,[rbp-58h]
     b4: mov     [rbp-48h],rax
     b8: mov     edi,0FFFFFFF0h
     bd: mov     esi,0FFFFFFB0h
     c2: call    ryo_h_MovW128
     c7: mov     qword ptr [rbp-18h],0
     cf: jmp     110h
     d1: mov     rax,[rbp+10h]
     d5: mov     [rbp-38h],rax
     d9: mov     rax,[rbp+10h]
     dd: lea     rax,[rax+20h]
     e1: mov     [rbp-48h],rax
     e5: mov     [rbp-40h],rax
     e9: mov     rax,[rbp-38h]
     ed: mov     [rbp-80h],rax
     f1: mov     qword ptr [rbp-78h],1
     f9: mov     rax,[rbp-40h]
     fd: mov     [rbp-70h],rax
    101: call    fn1
    106: nop     [rcx-20h]
    10d: jmp     179h
    10f: nop
    110: mov     edi,0FFFFFFE8h
    115: mov     esi,18h
    11a: call    ryo_h_Ret
    11f: leave
    120: ret
    121: nop     [rax+rax]
    12a: nop     [rax+rax]
    130: mov     edi,0FFFFFFD8h
    135: call    ryo_h_Resume
    13a: ud2
    13c: mov     rax,[rbp+10h]
    140: mov     [rbp-40h],rax
    144: lea     rax,[rbp+18h]
    148: mov     [rbp-50h],rax
    14c: mov     [rbp-48h],rax
    150: mov     rax,[rbp-40h]
    154: mov     [rbp-80h],rax
    158: mov     rax,[rbp-30h]
    15c: mov     [rbp-78h],rax
    160: mov     rax,[rbp-48h]
    164: mov     [rbp-70h],rax
    168: call    fn2
    16d: nop     [rcx-38h]
    174: jmp     40h
    179: mov     rax,[rbp+18h]
    17d: mov     [rbp-50h],rax
    181: mov     rax,[rbp+10h]
    185: mov     [rbp-58h],rax
    189: mov     rax,[rbp-30h]
    18d: mov     [rbp-40h],rax
    191: mov     rax,[rbp-50h]
    195: mov     [rbp-38h],rax
    199: mov     rax,[rbp-58h]
    19d: mov     [rbp-48h],rax
    1a1: mov     edi,0FFFFFFE8h
    1a6: mov     esi,0FFFFFFB8h
    1ab: mov     edx,18h
    1b0: call    ryo_h_Copy
    1b5: jmp     110h
    1ba: call    ryo_h_Unreachable
    1bf: ud2
    1c1: mov     rdi,rax
    1c4: mov     esi,0FFFFFFD8h
    1c9: call    ryo_h_Lpad
    1ce: jmp     130h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rax,[rbp+10h]
     14: mov     rax,[rax]
     17: mov     [rbp-10h],rax
     1b: mov     rax,[rbp-18h]
     1f: mov     [rbp-30h],rax
     23: mov     rax,[rbp-10h]
     27: mov     [rbp-28h],rax
     2b: call    fn0
     30: nop     [rcx-1]
     37: mov     edi,0FFFFFFFFh
     3c: mov     esi,1
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn main
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,570h
      b: mov     qword ptr [rbp-570h],50910h
     16: call    fn0
     1b: nop     [rcx-8]
     22: call    fn1
     27: nop     [rcx-38h]
     2e: mov     qword ptr [rbp-40h],1
     36: mov     qword ptr [rbp-60h],0
     3e: mov     rax,[rbp-8]
     42: mov     [rbp-58h],rax
     46: mov     edi,0FFFFFA90h
     4b: mov     esi,0FFFFFFA0h
     50: call    ryo_h_MovW128
     55: call    fn2
     5a: nop     [rcx-50h]
     61: mov     edi,0FFFFFF90h
     66: mov     esi,0FFFFFFB0h
     6b: call    ryo_h_MovW128
     70: lea     rax,[rbp-70h]
     74: mov     [rbp-88h],rax
     7b: mov     [rbp-570h],rax
     82: call    fn3
     87: nop     [rcx-80h]
     8e: mov     rax,[rbp-80h]
     92: mov     [rbp-90h],rax
     99: mov     edi,0FFFFFF70h
     9e: xor     esi,esi
     a0: mov     edx,2
     a5: call    ryo_h_SwitchDenseW64
     aa: lea     rcx,[0BCh]
     b1: movsxd  rax,[rcx+rax*4]
     b5: add     rax,rcx
     b8: jmp     rax
     ba: int3
     bb: int3
     bc: .long   116h
     c0: .long   d7h
     c4: .long   d0h
     c8: nop     [rax+rax]
     d0: call    ryo_h_Unreachable
     d5: ud2
     d7: mov     rax,[rbp-78h]
     db: mov     [rbp-98h],rax
     e2: mov     rax,[rbp-40h]
     e6: mov     [rbp-0B0h],rax
     ed: mov     [rbp-570h],rax
     f4: mov     rax,5851F42D4C957F2Dh
     fe: mov     [rbp-568h],rax
    105: call    fn4
    10a: nop     [rcx-0A8h]
    111: jmp     19Bh
    116: mov     qword ptr [rbp-108h],0
    121: mov     qword ptr [rbp-110h],0
    12c: mov     dword ptr [rbp-534h],14h
    136: mov     eax,[rbp-534h]
    13c: mov     [rbp-16Ch],eax
    142: cmp     eax,40h
    145: jb      350h
    14b: mov     edi,0FFFFFA90h
    150: lea     rsi,[k5]
    157: call    ryo_h_AddrAbs
    15c: lea     rdi,[sym6]
    163: lea     rsi,[site7]
    16a: mov     edx,0FFFFFAC8h
    16f: call    ryo_h_CallExt
    174: test    rax,rax
    177: je      184h
    179: call    rax
    17b: nop     [rcx-530h]
    182: jmp     194h
    184: mov     rdi,rbp
    187: lea     rsi,[ro+4]
    18e: call    qword ptr [sym8]
    194: call    ryo_h_Unreachable
    199: ud2
    19b: mov     rax,[rbp-0A8h]
    1a2: mov     [rbp-570h],rax
    1a9: mov     rax,14057B7EF767814Fh
    1b3: mov     [rbp-568h],rax
    1ba: call    fn9
    1bf: nop     [rcx-0A0h]
    1c6: mov     rax,[rbp-0A0h]
    1cd: mov     [rbp-40h],rax
    1d1: lea     rax,[rbp-38h]
    1d5: mov     [rbp-0D8h],rax
    1dc: mov     rax,[rbp-40h]
    1e0: mov     [rbp-0E8h],rax
    1e7: mov     dword ptr [rbp-534h],2Ch
    1f1: mov     eax,[rbp-534h]
    1f7: mov     [rbp-0ECh],eax
    1fd: cmp     eax,40h
    200: jb      252h
    202: mov     edi,0FFFFFA90h
    207: lea     rsi,[k10]
    20e: call    ryo_h_AddrAbs
    213: lea     rdi,[sym11]
    21a: lea     rsi,[site12]
    221: mov     edx,0FFFFFAC8h
    226: call    ryo_h_CallExt
    22b: test    rax,rax
    22e: je      23Bh
    230: call    rax
    232: nop     [rcx-530h]
    239: jmp     24Bh
    23b: mov     rdi,rbp
    23e: lea     rsi,[ro+4]
    245: call    qword ptr [sym13]
    24b: call    ryo_h_Unreachable
    250: ud2
    252: mov     rax,[rbp-0E8h]
    259: shr     rax,2Ch
    25d: mov     [rbp-0E0h],rax
    264: mov     rax,[rbp-0D8h]
    26b: mov     [rbp-570h],rax
    272: mov     rax,[rbp-0E0h]
    279: mov     [rbp-568h],rax
    280: call    fn14
    285: nop     [rcx-0D0h]
    28c: mov     edi,0FFFFFA90h
    291: mov     esi,0FFFFFF30h
    296: mov     edx,18h
    29b: call    ryo_h_Copy
    2a0: mov     qword ptr [rbp-558h],0
    2ab: call    fn15
    2b0: nop     [rcx-0B8h]
    2b7: mov     rax,[rbp-0B8h]
    2be: mov     rax,[rax]
    2c1: mov     [rbp-538h],rax
    2c8: mov     edi,0FFFFFF00h
    2cd: mov     esi,0FFFFFF08h
    2d2: mov     edx,0FFFFFAC8h
    2d7: mov     ecx,0FFFFFF68h
    2dc: call    ryo_h_AddOvfUW64
    2e1: test    byte ptr [rbp-0F8h],0FFh
    2e8: je      33Ah
    2ea: mov     edi,0FFFFFA90h
    2ef: lea     rsi,[k16]
    2f6: call    ryo_h_AddrAbs
    2fb: lea     rdi,[sym17]
    302: lea     rsi,[site18]
    309: mov     edx,0FFFFFAC8h
    30e: call    ryo_h_CallExt
    313: test    rax,rax
    316: je      323h
    318: call    rax
    31a: nop     [rcx-530h]
    321: jmp     333h
    323: mov     rdi,rbp
    326: lea     rsi,[ro+4]
    32d: call    qword ptr [sym19]
    333: call    ryo_h_Unreachable
    338: ud2
    33a: mov     rax,[rbp-0B8h]
    341: mov     rcx,[rbp-100h]
    348: mov     [rax],rcx
    34b: jmp     70h
    350: mov     qword ptr [rbp-538h],1
    35b: mov     rax,[rbp-538h]
    362: shl     rax,14h
    366: mov     [rbp-168h],rax
    36d: mov     qword ptr [rbp-160h],0
    378: mov     [rbp-158h],rax
    37f: mov     edi,0FFFFFA90h
    384: mov     esi,0FFFFFEA0h
    389: call    ryo_h_MovW128
    38e: mov     qword ptr [rbp-560h],2
    399: call    fn20
    39e: nop     [rcx-150h]
    3a5: mov     edi,0FFFFFA90h
    3aa: mov     esi,0FFFFFEB0h
    3af: mov     edx,20h
    3b4: call    ryo_h_Copy
    3b9: call    fn21
    3be: nop     [rcx-130h]
    3c5: mov     edi,0FFFFFE70h
    3ca: mov     esi,0FFFFFED0h
    3cf: mov     edx,20h
    3d4: call    ryo_h_Copy
    3d9: nop     [rax]
    3e0: lea     rax,[rbp-190h]
    3e7: mov     [rbp-1A8h],rax
    3ee: mov     [rbp-570h],rax
    3f5: call    fn22
    3fa: nop     [rcx-1A0h]
    401: mov     rax,[rbp-1A0h]
    408: mov     [rbp-1B0h],rax
    40f: mov     edi,0FFFFFE50h
    414: xor     esi,esi
    416: mov     edx,2
    41b: call    ryo_h_SwitchDenseW64
    420: lea     rcx,[430h]
    427: movsxd  rax,[rcx+rax*4]
    42b: add     rax,rcx
    42e: jmp     rax
    430: .long   48dh
    434: .long   43ch
    438: .long   d0h
    43c: mov     rax,[rbp-198h]
    443: mov     [rbp-1B8h],rax
    44a: lea     rax,[rbp-38h]
    44e: mov     [rbp-1C8h],rax
    455: lea     rax,[rbp-1B8h]
    45c: mov     [rbp-1D0h],rax
    463: mov     rax,[rbp-1C8h]
    46a: mov     [rbp-570h],rax
    471: mov     rax,[rbp-1D0h]
    478: mov     [rbp-568h],rax
    47f: call    fn23
    484: nop     [rcx-1C0h]
    48b: jmp     4B0h
    48d: lea     rax,[rbp-38h]
    491: mov     [rbp-218h],rax
    498: mov     [rbp-570h],rax
    49f: call    fn24
    4a4: nop     [rcx-210h]
    4ab: jmp     5FBh
    4b0: mov     edi,0FFFFFACCh
    4b5: mov     esi,0FFFFFE40h
    4ba: xor     edx,edx
    4bc: xor     ecx,ecx
    4be: xor     r8d,r8d
    4c1: mov     r9d,1
    4c7: call    ryo_h_DiscrNicheW64
    4cc: mov     edi,0FFFFFE28h
    4d1: mov     esi,0FFFFFACCh
    4d6: call    ryo_h_ZextW32W64
    4db: mov     edi,0FFFFFE28h
    4e0: xor     esi,esi
    4e2: mov     edx,2
    4e7: call    ryo_h_SwitchDenseW64
    4ec: lea     rcx,[4FCh]
    4f3: movsxd  rax,[rcx+rax*4]
    4f7: add     rax,rcx
    4fa: jmp     rax
    4fc: .long   3e0h
    500: .long   508h
    504: .long   d0h
    508: mov     rax,[rbp-1C0h]
    50f: mov     [rbp-1E0h],rax
    516: mov     qword ptr [rbp-538h],1
    521: mov     edi,0FFFFFE10h
    526: mov     esi,0FFFFFE18h
    52b: mov     edx,0FFFFFEF8h
    530: mov     ecx,0FFFFFAC8h
    535: call    ryo_h_AddOvfUW64
    53a: test    byte ptr [rbp-1E8h],0FFh
    541: je      593h
    543: mov     edi,0FFFFFA90h
    548: lea     rsi,[k25]
    54f: call    ryo_h_AddrAbs
    554: lea     rdi,[sym26]
    55b: lea     rsi,[site27]
    562: mov     edx,0FFFFFAC8h
    567: call    ryo_h_CallExt
    56c: test    rax,rax
    56f: je      57Ch
    571: call    rax
    573: nop     [rcx-530h]
    57a: jmp     58Ch
    57c: mov     rdi,rbp
    57f: lea     rsi,[ro+4]
    586: call    qword ptr [sym28]
    58c: call    ryo_h_Unreachable
    591: ud2
    593: mov     rax,[rbp-1F0h]
    59a: mov     [rbp-108h],rax
    5a1: mov     rax,[rbp-110h]
    5a8: mov     [rbp-200h],rax
    5af: mov     rax,[rbp-1E0h]
    5b6: mov     rax,[rax]
    5b9: mov     [rbp-208h],rax
    5c0: mov     rax,[rbp-200h]
    5c7: mov     [rbp-570h],rax
    5ce: mov     rax,[rbp-208h]
    5d5: mov     [rbp-568h],rax
    5dc: call    fn29
    5e1: nop     [rcx-1F8h]
    5e8: mov     rax,[rbp-1F8h]
    5ef: mov     [rbp-110h],rax
    5f6: jmp     3E0h
    5fb: lea     rax,[rbp-38h]
    5ff: mov     [rbp-220h],rax
    606: mov     [rbp-570h],rax
    60d: call    fn30
    612: nop     [rcx-218h]
    619: lea     rax,[rbp-38h]
    61d: mov     [rbp-258h],rax
    624: mov     [rbp-570h],rax
    62b: call    fn31
    630: nop     [rcx-250h]
    637: mov     edi,0FFFFFA90h
    63c: mov     esi,0FFFFFDB0h
    641: mov     edx,28h
    646: call    ryo_h_Copy
    64b: mov     qword ptr [rbp-548h],0
    656: call    fn32
    65b: nop     [rcx-228h]
    662: call    fn33
    667: nop     [rcx-288h]
    66e: mov     dword ptr [rbp-298h],0
    678: mov     dword ptr [rbp-294h],1FBD0h
    682: mov     rax,[rbp-298h]
    689: mov     [rbp-570h],rax
    690: call    fn34
    695: nop     [rcx-290h]
    69c: mov     rax,[rbp-290h]
    6a3: mov     [rbp-2A0h],rax
    6aa: nop     [rax+rax]
    6b0: lea     rax,[rbp-2A0h]
    6b7: mov     [rbp-2B0h],rax
    6be: mov     [rbp-570h],rax
    6c5: call    fn35
    6ca: nop     [rcx-2A8h]
    6d1: mov     edi,0FFFFFD48h
    6d6: mov     esi,0FFFFFD58h
    6db: call    ryo_h_ZextW32W64
    6e0: mov     edi,0FFFFFD48h
    6e5: xor     esi,esi
    6e7: mov     edx,2
    6ec: call    ryo_h_SwitchDenseW64
    6f1: lea     rcx,[704h]
    6f8: movsxd  rax,[rcx+rax*4]
    6fc: add     rax,rcx
    6ff: jmp     rax
    701: int3
    702: int3
    703: int3
    704: .long   79bh
    708: .long   710h
    70c: .long   d0h
    710: mov     eax,[rbp-2A4h]
    716: mov     [rbp-2BCh],eax
    71c: lea     rax,[rbp-288h]
    723: mov     [rbp-2F8h],rax
    72a: mov     dword ptr [rbp-534h],138Bh
    734: cmp     dword ptr [rbp-534h],0
    73b: sete    [rbp-34Dh]
    742: test    byte ptr [rbp-34Dh],0FFh
    749: je      7BEh
    74b: mov     edi,0FFFFFA90h
    750: lea     rsi,[k36]
    757: call    ryo_h_AddrAbs
    75c: lea     rdi,[sym37]
    763: lea     rsi,[site38]
    76a: mov     edx,0FFFFFAC8h
    76f: call    ryo_h_CallExt
    774: test    rax,rax
    777: je      784h
    779: call    rax
    77b: nop     [rcx-530h]
    782: jmp     794h
    784: mov     rdi,rbp
    787: lea     rsi,[ro+4]
    78e: call    qword ptr [sym39]
    794: call    ryo_h_Unreachable
    799: ud2
    79b: lea     rax,[rbp-38h]
    79f: mov     [rbp-3E8h],rax
    7a6: mov     [rbp-570h],rax
    7ad: call    fn40
    7b2: nop     [rcx-3E0h]
    7b9: jmp     98Eh
    7be: mov     dword ptr [rbp-534h],138Bh
    7c8: mov     edi,0FFFFFCB4h
    7cd: mov     esi,0FFFFFD44h
    7d2: mov     edx,0FFFFFACCh
    7d7: call    ryo_h_RemUW32
    7dc: lea     rax,[rbp-34Ch]
    7e3: mov     [rbp-348h],rax
    7ea: mov     [rbp-340h],rax
    7f1: mov     [rbp-4F8h],rax
    7f8: mov     [rbp-570h],rax
    7ff: call    fn41
    804: nop     [rcx-370h]
    80b: mov     edi,0FFFFFCA0h
    810: mov     esi,0FFFFFC90h
    815: call    ryo_h_MovW128
    81a: mov     edi,0FFFFFC88h
    81f: lea     rsi,[k42]
    826: call    ryo_h_AddrAbs
    82b: lea     rax,[rbp-360h]
    832: mov     [rbp-380h],rax
    839: mov     rax,[rbp-378h]
    840: mov     [rbp-570h],rax
    847: mov     rax,[rbp-380h]
    84e: mov     [rbp-568h],rax
    855: call    fn43
    85a: nop     [rcx-338h]
    861: mov     edi,0FFFFFA90h
    866: mov     esi,0FFFFFCC8h
    86b: call    ryo_h_MovW128
    870: call    fn44
    875: nop     [rcx-328h]
    87c: mov     edi,0FFFFFA90h
    881: mov     esi,0FFFFFCD8h
    886: mov     edx,18h
    88b: call    ryo_h_Copy
    890: call    fn45
    895: nop     [rcx-310h]
    89c: mov     rax,[rbp-2F8h]
    8a3: mov     [rbp-570h],rax
    8aa: mov     edi,0FFFFFA98h
    8af: mov     esi,0FFFFFCF0h
    8b4: mov     edx,18h
    8b9: call    ryo_h_Copy
    8be: call    fn46
    8c3: nop     [rcx-2F0h]
    8ca: mov     edi,0FFFFFA90h
    8cf: mov     esi,0FFFFFD10h
    8d4: mov     edx,28h
    8d9: call    ryo_h_Copy
    8de: call    fn47
    8e3: nop     [rcx-2C8h]
    8ea: mov     rax,[rbp-2C8h]
    8f1: mov     rax,[rax]
    8f4: mov     [rbp-538h],rax
    8fb: mov     qword ptr [rbp-540h],1
    906: mov     edi,0FFFFFC70h
    90b: mov     esi,0FFFFFC78h
    910: mov     edx,0FFFFFAC8h
    915: mov     ecx,0FFFFFAC0h
    91a: call    ryo_h_AddOvfUW64
    91f: test    byte ptr [rbp-388h],0FFh
    926: je      978h
    928: mov     edi,0FFFFFA90h
    92d: lea     rsi,[k48]
    934: call    ryo_h_AddrAbs
    939: lea     rdi,[sym49]
    940: lea     rsi,[site50]
    947: mov     edx,0FFFFFAC8h
    94c: call    ryo_h_CallExt
    951: test    rax,rax
    954: je      961h
    956: call    rax
    958: nop     [rcx-530h]
    95f: jmp     971h
    961: mov     rdi,rbp
    964: lea     rsi,[ro+4]
    96b: call    qword ptr [sym51]
    971: call    ryo_h_Unreachable
    976: ud2
    978: mov     rax,[rbp-2C8h]
    97f: mov     rcx,[rbp-390h]
    986: mov     [rax],rcx
    989: jmp     6B0h
    98e: lea     rax,[rbp-3E0h]
    995: mov     [rbp-3D8h],rax
    99c: lea     rax,[rbp-288h]
    9a3: mov     [rbp-400h],rax
    9aa: mov     [rbp-570h],rax
    9b1: call    fn52
    9b6: nop     [rcx-3F8h]
    9bd: lea     rax,[rbp-3F8h]
    9c4: mov     [rbp-3F0h],rax
    9cb: lea     rax,[rbp-210h]
    9d2: mov     [rbp-408h],rax
    9d9: lea     rax,[rbp-108h]
    9e0: mov     [rbp-410h],rax
    9e7: lea     rax,[rbp-110h]
    9ee: mov     [rbp-418h],rax
    9f5: lea     rax,[rbp-228h]
    9fc: mov     [rbp-420h],rax
    a03: mov     rax,[rbp-3D8h]
    a0a: mov     [rbp-3D0h],rax
    a11: mov     rax,[rbp-3F0h]
    a18: mov     [rbp-3C8h],rax
    a1f: mov     rax,[rbp-408h]
    a26: mov     [rbp-3C0h],rax
    a2d: mov     rax,[rbp-410h]
    a34: mov     [rbp-3B8h],rax
    a3b: mov     rax,[rbp-418h]
    a42: mov     [rbp-3B0h],rax
    a49: mov     rax,[rbp-420h]
    a50: mov     [rbp-3A8h],rax
    a57: mov     rax,[rbp-3C0h]
    a5e: mov     [rbp-500h],rax
    a65: mov     [rbp-570h],rax
    a6c: call    fn53
    a71: nop     [rcx-490h]
    a78: mov     rax,[rbp-3B8h]
    a7f: mov     [rbp-508h],rax
    a86: mov     [rbp-570h],rax
    a8d: call    fn54
    a92: nop     [rcx-4A0h]
    a99: mov     rax,[rbp-3B0h]
    aa0: mov     [rbp-510h],rax
    aa7: mov     [rbp-570h],rax
    aae: call    fn55
    ab3: nop     [rcx-4B0h]
    aba: mov     rax,[rbp-3D0h]
    ac1: mov     [rbp-518h],rax
    ac8: mov     [rbp-570h],rax
    acf: call    fn56
    ad4: nop     [rcx-4C0h]
    adb: mov     rax,[rbp-3A8h]
    ae2: mov     [rbp-520h],rax
    ae9: mov     [rbp-570h],rax
    af0: call    fn57
    af5: nop     [rcx-4D0h]
    afc: mov     rax,[rbp-3C8h]
    b03: mov     [rbp-528h],rax
    b0a: mov     [rbp-570h],rax
    b11: call    fn58
    b16: nop     [rcx-4E0h]
    b1d: mov     edi,0FFFFFB80h
    b22: mov     esi,0FFFFFB70h
    b27: call    ryo_h_MovW128
    b2c: mov     edi,0FFFFFB90h
    b31: mov     esi,0FFFFFB60h
    b36: call    ryo_h_MovW128
    b3b: mov     edi,0FFFFFBA0h
    b40: mov     esi,0FFFFFB50h
    b45: call    ryo_h_MovW128
    b4a: mov     edi,0FFFFFBB0h
    b4f: mov     esi,0FFFFFB40h
    b54: call    ryo_h_MovW128
    b59: mov     edi,0FFFFFBC0h
    b5e: mov     esi,0FFFFFB30h
    b63: call    ryo_h_MovW128
    b68: mov     edi,0FFFFFBD0h
    b6d: mov     esi,0FFFFFB20h
    b72: call    ryo_h_MovW128
    b77: mov     edi,0FFFFFB18h
    b7c: lea     rsi,[k59]
    b83: call    ryo_h_AddrAbs
    b88: lea     rax,[rbp-480h]
    b8f: mov     [rbp-4F0h],rax
    b96: mov     rax,[rbp-4E8h]
    b9d: mov     [rbp-570h],rax
    ba4: mov     rax,[rbp-4F0h]
    bab: mov     [rbp-568h],rax
    bb2: call    fn60
    bb7: nop     [rcx-3A0h]
    bbe: mov     edi,0FFFFFA90h
    bc3: mov     esi,0FFFFFC60h
    bc8: call    ryo_h_MovW128
    bcd: lea     rdi,[sym61]
    bd4: lea     rsi,[site62]
    bdb: mov     edx,0FFFFFAC8h
    be0: call    ryo_h_CallExt
    be5: test    rax,rax
    be8: je      0BF5h
    bea: call    rax
    bec: nop     [rcx-390h]
    bf3: jmp     0C05h
    bf5: mov     rdi,rbp
    bf8: lea     rsi,[ro+20]
    bff: call    qword ptr [sym63]
    c05: lea     rax,[rbp-288h]
    c0c: mov     [rbp-538h],rax
    c13: mov     [rbp-570h],rax
    c1a: call    fn64
    c1f: nop     [rcx-538h]
    c26: lea     rax,[rbp-38h]
    c2a: mov     [rbp-538h],rax
    c31: mov     [rbp-570h],rax
    c38: call    fn65
    c3d: nop     [rcx-538h]
    c44: xor     edi,edi
    c46: xor     esi,esi
    c48: call    ryo_h_Ret
    c4d: leave
    c4e: ret
    c4f: nop
    c50: lea     rax,[rbp-288h]
    c57: mov     [rbp-538h],rax
    c5e: mov     [rbp-570h],rax
    c65: call    fn66
    c6a: nop     [rcx-538h]
    c71: nop     [rax+rax]
    c7a: nop     [rax+rax]
    c80: lea     rax,[rbp-38h]
    c84: mov     [rbp-538h],rax
    c8b: mov     [rbp-570h],rax
    c92: call    fn67
    c97: nop     [rcx-538h]
    c9e: mov     edi,0FFFFFAD0h
    ca3: call    ryo_h_Resume
    ca8: ud2
    caa: nop     [rax+rax]
    cb0: lea     rdi,[sym68]
    cb7: lea     rsi,[site69]
    cbe: mov     edx,0FFFFFAC8h
    cc3: call    ryo_h_CallExt
    cc8: test    rax,rax
    ccb: je      0CD8h
    ccd: call    rax
    ccf: nop     [rcx-530h]
    cd6: jmp     0CE8h
    cd8: mov     rdi,rbp
    cdb: lea     rsi,[ro+4]
    ce2: call    qword ptr [sym70]
    ce8: call    ryo_h_Unreachable
    ced: ud2
    cef: mov     rdi,rax
    cf2: mov     esi,0FFFFFAD0h
    cf7: call    ryo_h_Lpad
    cfc: jmp     0C80h
    cfe: mov     rdi,rax
    d01: mov     esi,0FFFFFAD0h
    d06: call    ryo_h_Lpad
    d0b: jmp     0C50h
    d10: mov     rdi,rax
    d13: mov     esi,0FFFFFAD0h
    d18: call    ryo_h_Lpad
    d1d: jmp     0CB0h

fn main::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-30h],rax
     10: mov     qword ptr [rbp-28h],3
     18: mov     edi,0FFFFFFE0h
     1d: lea     rsi,[k0]
     24: call    ryo_h_AddrAbs
     29: call    fn1
     2e: nop     [rcx-10h]
     35: cmp     qword ptr [rbp-10h],0
     3a: setne   [rbp-1]
     3e: mov     edi,0FFFFFFFFh
     43: mov     esi,1
     48: call    ryo_h_Ret
     4d: leave
     4e: ret

fn main::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+20h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp-10h]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx-8]
     2f: mov     edi,0FFFFFFF8h
     34: mov     esi,8
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn std::alloc::Global::alloc_impl_runtime
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-60h],rax
     13: cmp     rax,0
     17: je      21h
     19: test    byte ptr [rbp+20h],0FFh
     1d: je      9Dh
     1f: jmp     60h
     21: mov     rax,[rbp+10h]
     25: mov     [rbp-38h],rax
     29: mov     [rbp-78h],rax
     2d: mov     rax,[rbp-38h]
     31: mov     [rbp-90h],rax
     38: mov     [rbp-88h],rax
     3f: mov     qword ptr [rbp-80h],0
     47: mov     byte ptr [rbp-91h],1
     4e: test    byte ptr [rbp-91h],0FFh
     55: je      150h
     5b: jmp     121h
     60: lea     rdi,[sym0]
     67: lea     rsi,[site1]
     6e: mov     edx,0FFFFFF68h
     73: call    ryo_h_CallExt
     78: test    rax,rax
     7b: je      88h
     7d: call    rax
     7f: nop     [rcx-38h]
     86: jmp     98h
     88: mov     rdi,rbp
     8b: lea     rsi,[ro+4]
     92: call    qword ptr [sym2]
     98: jmp     170h
     9d: lea     rdi,[sym3]
     a4: lea     rsi,[site4]
     ab: mov     edx,0FFFFFF68h
     b0: call    ryo_h_CallExt
     b5: test    rax,rax
     b8: je      0C5h
     ba: call    rax
     bc: nop     [rcx-48h]
     c3: jmp     0D5h
     c5: mov     rdi,rbp
     c8: lea     rsi,[ro+20]
     cf: call    qword ptr [sym5]
     d5: jmp     1CBh
     da: nop     [rax+rax]
     e0: mov     rax,[rbp-28h]
     e4: mov     [rbp-88h],rax
     eb: cmp     rax,0
     ef: sete    [rbp-79h]
     f3: test    byte ptr [rbp-79h],0FFh
     f7: je      262h
     fd: jmp     226h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: mov     edi,0FFFFFFF0h
    115: mov     esi,10h
    11a: call    ryo_h_Ret
    11f: leave
    120: ret
    121: mov     rax,[rbp-38h]
    125: mov     [rbp-90h],rax
    12c: mov     [rbp-0B0h],rax
    133: mov     edi,0FFFFFF58h
    138: lea     rsi,[k6]
    13f: call    ryo_h_AddrAbs
    144: call    fn7
    149: nop     [rcx-38h]
    150: mov     edi,0FFFFFF90h
    155: mov     esi,0FFFFFF78h
    15a: call    ryo_h_MovW128
    15f: mov     edi,0FFFFFFF0h
    164: mov     esi,0FFFFFF90h
    169: call    ryo_h_MovW128
    16e: jmp     110h
    170: mov     rax,[rbp+10h]
    174: mov     [rbp-68h],rax
    178: mov     rax,[rbp-60h]
    17c: mov     [rbp-0B0h],rax
    183: mov     rax,[rbp-68h]
    187: mov     [rbp-0A8h],rax
    18e: lea     rdi,[sym8]
    195: lea     rsi,[site9]
    19c: mov     edx,0FFFFFF68h
    1a1: call    ryo_h_CallExt
    1a6: test    rax,rax
    1a9: je      1B6h
    1ab: call    rax
    1ad: nop     [rcx-28h]
    1b4: jmp     1C6h
    1b6: mov     rdi,rbp
    1b9: lea     rsi,[ro+36]
    1c0: call    qword ptr [sym10]
    1c6: jmp     0E0h
    1cb: mov     rax,[rbp+10h]
    1cf: mov     [rbp-68h],rax
    1d3: mov     rax,[rbp-60h]
    1d7: mov     [rbp-0B0h],rax
    1de: mov     rax,[rbp-68h]
    1e2: mov     [rbp-0A8h],rax
    1e9: lea     rdi,[sym11]
    1f0: lea     rsi,[site12]
    1f7: mov     edx,0FFFFFF68h
    1fc: call    ryo_h_CallExt
    201: test    rax,rax
    204: je      211h
    206: call    rax
    208: nop     [rcx-28h]
    20f: jmp     221h
    211: mov     rdi,rbp
    214: lea     rsi,[ro+36]
    21b: call    qword ptr [sym13]
    221: jmp     0E0h
    226: mov     qword ptr [rbp-78h],0
    22e: mov     qword ptr [rbp-70h],0
    236: mov     qword ptr [rbp-70h],1
    23e: cmp     qword ptr [rbp-70h],1
    243: sete    [rbp-71h]
    247: mov     edi,0FFFFFFF0h
    24c: lea     rsi,[k14]
    253: mov     edx,10h
    258: call    ryo_h_Const
    25d: jmp     110h
    262: mov     byte ptr [rbp-91h],1
    269: test    byte ptr [rbp-91h],0FFh
    270: je      2A1h
    272: mov     rax,[rbp-28h]
    276: mov     [rbp-90h],rax
    27d: mov     [rbp-0B0h],rax
    284: mov     edi,0FFFFFF58h
    289: lea     rsi,[k15]
    290: call    ryo_h_AddrAbs
    295: call    fn16
    29a: nop     [rcx-58h]
    2a1: mov     rax,[rbp-28h]
    2a5: mov     [rbp-88h],rax
    2ac: mov     [rbp-78h],rax
    2b0: mov     [rbp-80h],rax
    2b4: mov     [rbp-70h],rax
    2b8: mov     [rbp-78h],rax
    2bc: mov     [rbp-68h],rax
    2c0: mov     [rbp-30h],rax
    2c4: mov     [rbp-88h],rax
    2cb: mov     [rbp-80h],rax
    2cf: mov     rax,[rbp-60h]
    2d3: mov     [rbp-78h],rax
    2d7: mov     byte ptr [rbp-91h],1
    2de: test    byte ptr [rbp-91h],0FFh
    2e5: je      316h
    2e7: mov     rax,[rbp-30h]
    2eb: mov     [rbp-88h],rax
    2f2: mov     [rbp-0B0h],rax
    2f9: mov     edi,0FFFFFF58h
    2fe: lea     rsi,[k17]
    305: call    ryo_h_AddrAbs
    30a: call    fn18
    30f: nop     [rcx-58h]
    316: mov     edi,0FFFFFF90h
    31b: mov     esi,0FFFFFF80h
    320: call    ryo_h_MovW128
    325: mov     edi,0FFFFFFF0h
    32a: mov     esi,0FFFFFF90h
    32f: call    ryo_h_MovW128
    334: jmp     110h

fn std::arch::x86_64::__m128i::as_i8x16
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

fn std::char::encode_utf8_raw
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: cmp     dword ptr [rbp+10h],80h
     12: jb      110h
     18: jmp     0E0h
     1d: nop     [rax]
     20: mov     eax,[rbp+10h]
     23: mov     [rbp-70h],eax
     26: mov     rax,[rbp-18h]
     2a: mov     [rbp-80h],rax
     2e: mov     rax,[rbp-20h]
     32: mov     [rbp-78h],rax
     36: mov     edi,0FFFFFF98h
     3b: lea     rsi,[k0]
     42: call    ryo_h_AddrAbs
     47: call    fn1
     4c: nop     [rcx-20h]
     53: call    ryo_h_Unreachable
     58: ud2
     5a: nop     [rax+rax]
     60: mov     rax,[rbp+18h]
     64: mov     [rbp-48h],rax
     68: mov     rax,[rbp+20h]
     6c: mov     [rbp-40h],rax
     70: mov     rax,[rbp-48h]
     74: mov     [rbp-38h],rax
     78: mov     eax,[rbp+10h]
     7b: mov     [rbp-80h],eax
     7e: mov     rax,[rbp-38h]
     82: mov     [rbp-78h],rax
     86: call    fn2
     8b: nop     [rcx-20h]
     92: mov     rax,[rbp+18h]
     96: mov     [rbp-30h],rax
     9a: mov     rax,[rbp+20h]
     9e: mov     [rbp-28h],rax
     a2: mov     rax,[rbp-30h]
     a6: mov     [rbp-38h],rax
     aa: mov     byte ptr [rbp-49h],1
     ae: test    byte ptr [rbp-49h],0FFh
     b2: je      15Bh
     b8: jmp     11Ah
     ba: nop     [rax+rax]
     c0: mov     rax,[rbp+20h]
     c4: mov     [rbp-20h],rax
     c8: mov     rax,[rbp-18h]
     cc: mov     [rbp-40h],rax
     d0: mov     rax,[rbp-20h]
     d4: cmp     rax,[rbp-40h]
     d8: jb      20h
     de: jmp     60h
     e0: cmp     dword ptr [rbp+10h],800h
     e7: jb      106h
     e9: cmp     dword ptr [rbp+10h],10000h
     f0: jb      0FCh
     f2: mov     qword ptr [rbp-18h],4
     fa: jmp     0C0h
     fc: mov     qword ptr [rbp-18h],3
    104: jmp     0C0h
    106: mov     qword ptr [rbp-18h],2
    10e: jmp     0C0h
    110: mov     qword ptr [rbp-18h],1
    118: jmp     0C0h
    11a: mov     rax,[rbp-30h]
    11e: mov     [rbp-40h],rax
    122: mov     [rbp-80h],rax
    126: mov     qword ptr [rbp-78h],1
    12e: mov     qword ptr [rbp-70h],1
    136: mov     rax,[rbp-18h]
    13a: mov     [rbp-68h],rax
    13e: mov     edi,0FFFFFFA0h
    143: lea     rsi,[k3]
    14a: call    ryo_h_AddrAbs
    14f: call    fn4
    154: nop     [rcx-30h]
    15b: mov     rax,[rbp-38h]
    15f: mov     [rbp-48h],rax
    163: mov     rax,[rbp-18h]
    167: mov     [rbp-40h],rax
    16b: mov     rax,[rbp-48h]
    16f: mov     [rbp-10h],rax
    173: mov     rax,[rbp-40h]
    177: mov     [rbp-8],rax
    17b: mov     edi,0FFFFFFF0h
    180: mov     esi,10h
    185: call    ryo_h_Ret
    18a: leave
    18b: ret

fn std::char::encode_utf8_raw::do_panic::runtime
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: lea     rax,[rbp+10h]
      f: mov     [rbp-8],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-10h],rax
     1b: lea     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: mov     rax,[rbp-8]
     27: mov     [rbp-98h],rax
     2e: mov     [rbp-80h],rax
     32: mov     edi,0FFFFFF70h
     37: lea     rsi,[sym0]
     3e: call    ryo_h_AddrSym
     43: mov     rax,[rbp-90h]
     4a: mov     [rbp-88h],rax
     51: mov     rax,[rbp-80h]
     55: mov     [rbp-78h],rax
     59: mov     rax,[rbp-88h]
     60: mov     [rbp-70h],rax
     64: mov     edi,0FFFFFF98h
     69: mov     esi,0FFFFFF88h
     6e: call    ryo_h_MovW128
     73: mov     rax,[rbp-10h]
     77: mov     [rbp-0A8h],rax
     7e: mov     [rbp-90h],rax
     85: mov     edi,0FFFFFF60h
     8a: lea     rsi,[sym1]
     91: call    ryo_h_AddrSym
     96: mov     rax,[rbp-0A0h]
     9d: mov     [rbp-98h],rax
     a4: mov     rax,[rbp-90h]
     ab: mov     [rbp-88h],rax
     b2: mov     rax,[rbp-98h]
     b9: mov     [rbp-80h],rax
     bd: mov     edi,0FFFFFF88h
     c2: mov     esi,0FFFFFF78h
     c7: call    ryo_h_MovW128
     cc: mov     rax,[rbp-18h]
     d0: mov     [rbp-0B8h],rax
     d7: mov     [rbp-0A0h],rax
     de: mov     edi,0FFFFFF50h
     e3: lea     rsi,[sym2]
     ea: call    ryo_h_AddrSym
     ef: mov     rax,[rbp-0B0h]
     f6: mov     [rbp-0A8h],rax
     fd: mov     rax,[rbp-0A0h]
    104: mov     [rbp-98h],rax
    10b: mov     rax,[rbp-0A8h]
    112: mov     [rbp-90h],rax
    119: mov     edi,0FFFFFF78h
    11e: mov     esi,0FFFFFF68h
    123: call    ryo_h_MovW128
    128: mov     edi,0FFFFFFA8h
    12d: mov     esi,0FFFFFF98h
    132: call    ryo_h_MovW128
    137: mov     edi,0FFFFFFB8h
    13c: mov     esi,0FFFFFF88h
    141: call    ryo_h_MovW128
    146: mov     edi,0FFFFFFC8h
    14b: mov     esi,0FFFFFF78h
    150: call    ryo_h_MovW128
    155: lea     rax,[rbp-58h]
    159: mov     [rbp-60h],rax
    15d: mov     edi,0FFFFFF98h
    162: lea     rsi,[k3]
    169: call    ryo_h_AddrAbs
    16e: mov     rax,[rbp-60h]
    172: mov     [rbp-70h],rax
    176: mov     rax,[rbp-68h]
    17a: mov     [rbp-28h],rax
    17e: mov     rax,[rbp-70h]
    182: mov     [rbp-20h],rax
    186: mov     edi,0FFFFFF20h
    18b: mov     esi,0FFFFFFD8h
    190: call    ryo_h_MovW128
    195: mov     rax,[rbp+28h]
    199: mov     [rbp-0D0h],rax
    1a0: lea     rdi,[sym4]
    1a7: lea     rsi,[site5]
    1ae: mov     edx,0FFFFFF40h
    1b3: call    ryo_h_CallExt
    1b8: test    rax,rax
    1bb: je      1C8h
    1bd: call    rax
    1bf: nop     [rcx]
    1c6: jmp     1D8h
    1c8: mov     rdi,rbp
    1cb: lea     rsi,[ro+4]
    1d2: call    qword ptr [sym6]
    1d8: call    ryo_h_Unreachable
    1dd: ud2

fn std::char::encode_utf8_raw_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: cmp     dword ptr [rbp+10h],80h
      f: jb      15Bh
     15: jmp     12Bh
     1a: nop     [rax+rax]
     20: movzx   eax,byte ptr [rbp-0Ah]
     24: or      al,0C0h
     27: mov     [rbp-20h],al
     2a: mov     rax,[rbp+18h]
     2e: movzx   ecx,byte ptr [rbp-20h]
     32: mov     [rax],cl
     34: mov     qword ptr [rbp-20h],1
     3c: mov     rax,[rbp+18h]
     40: imul    rcx,[rbp-20h],1
     45: add     rax,rcx
     48: mov     [rbp-18h],rax
     4c: movzx   ecx,byte ptr [rbp-9]
     50: mov     [rax],cl
     52: jmp     120h
     57: nop     [rax+rax]
     60: cmp     qword ptr [rbp-8],3
     65: jne     0B9h
     67: movzx   eax,byte ptr [rbp-0Bh]
     6b: or      al,0E0h
     6e: mov     [rbp-20h],al
     71: mov     rax,[rbp+18h]
     75: movzx   ecx,byte ptr [rbp-20h]
     79: mov     [rax],cl
     7b: mov     qword ptr [rbp-20h],1
     83: mov     rax,[rbp+18h]
     87: imul    rcx,[rbp-20h],1
     8c: add     rax,rcx
     8f: mov     [rbp-18h],rax
     93: movzx   ecx,byte ptr [rbp-0Ah]
     97: mov     [rax],cl
     99: mov     qword ptr [rbp-20h],2
     a1: mov     rax,[rbp+18h]
     a5: imul    rcx,[rbp-20h],1
     aa: add     rax,rcx
     ad: mov     [rbp-18h],rax
     b1: movzx   ecx,byte ptr [rbp-9]
     b5: mov     [rax],cl
     b7: jmp     120h
     b9: mov     rax,[rbp+18h]
     bd: movzx   ecx,byte ptr [rbp-0Ch]
     c1: mov     [rax],cl
     c3: mov     qword ptr [rbp-20h],1
     cb: mov     rax,[rbp+18h]
     cf: imul    rcx,[rbp-20h],1
     d4: add     rax,rcx
     d7: mov     [rbp-18h],rax
     db: movzx   ecx,byte ptr [rbp-0Bh]
     df: mov     [rax],cl
     e1: mov     qword ptr [rbp-20h],2
     e9: mov     rax,[rbp+18h]
     ed: imul    rcx,[rbp-20h],1
     f2: add     rax,rcx
     f5: mov     [rbp-18h],rax
     f9: movzx   ecx,byte ptr [rbp-0Ah]
     fd: mov     [rax],cl
     ff: mov     qword ptr [rbp-20h],3
    107: mov     rax,[rbp+18h]
    10b: imul    rcx,[rbp-20h],1
    110: add     rax,rcx
    113: mov     [rbp-18h],rax
    117: movzx   ecx,byte ptr [rbp-9]
    11b: mov     [rax],cl
    11d: jmp     120h
    11f: nop
    120: xor     edi,edi
    122: xor     esi,esi
    124: call    ryo_h_Ret
    129: leave
    12a: ret
    12b: cmp     dword ptr [rbp+10h],800h
    132: jb      151h
    134: cmp     dword ptr [rbp+10h],10000h
    13b: jb      147h
    13d: mov     qword ptr [rbp-8],4
    145: jmp     17Eh
    147: mov     qword ptr [rbp-8],3
    14f: jmp     17Eh
    151: mov     qword ptr [rbp-8],2
    159: jmp     17Eh
    15b: mov     qword ptr [rbp-8],1
    163: mov     edi,0FFFFFFE0h
    168: mov     esi,10h
    16d: call    ryo_h_TruncW32W8
    172: mov     rax,[rbp+18h]
    176: movzx   ecx,byte ptr [rbp-20h]
    17a: mov     [rax],cl
    17c: jmp     120h
    17e: mov     eax,[rbp+10h]
    181: and     eax,3Fh
    184: mov     [rbp-10h],eax
    187: mov     edi,0FFFFFFF6h
    18c: mov     esi,0FFFFFFF0h
    191: call    ryo_h_TruncW32W8
    196: movzx   eax,byte ptr [rbp-0Ah]
    19a: or      al,80h
    19d: mov     [rbp-9],al
    1a0: mov     eax,[rbp+10h]
    1a3: shr     eax,6
    1a6: mov     [rbp-14h],eax
    1a9: and     eax,3Fh
    1ac: mov     [rbp-10h],eax
    1af: mov     edi,0FFFFFFF5h
    1b4: mov     esi,0FFFFFFF0h
    1b9: call    ryo_h_TruncW32W8
    1be: movzx   eax,byte ptr [rbp-0Bh]
    1c2: or      al,80h
    1c5: mov     [rbp-0Ah],al
    1c8: mov     eax,[rbp+10h]
    1cb: shr     eax,0Ch
    1ce: mov     [rbp-14h],eax
    1d1: and     eax,3Fh
    1d4: mov     [rbp-10h],eax
    1d7: mov     edi,0FFFFFFF4h
    1dc: mov     esi,0FFFFFFF0h
    1e1: call    ryo_h_TruncW32W8
    1e6: movzx   eax,byte ptr [rbp-0Ch]
    1ea: or      al,80h
    1ed: mov     [rbp-0Bh],al
    1f0: mov     eax,[rbp+10h]
    1f3: shr     eax,12h
    1f6: mov     [rbp-18h],eax
    1f9: and     eax,3Fh
    1fc: mov     [rbp-14h],eax
    1ff: mov     edi,0FFFFFFF3h
    204: mov     esi,0FFFFFFECh
    209: call    ryo_h_TruncW32W8
    20e: movzx   eax,byte ptr [rbp-0Dh]
    212: or      al,0F0h
    215: mov     [rbp-0Ch],al
    218: mov     rax,[rbp-8]
    21c: mov     [rbp-18h],rax
    220: cmp     rax,2
    224: je      20h
    22a: jmp     60h

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt
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

fn std::collections::HashMap::<std::string::String, usize>::entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-58h],rax
     13: mov     [rbp-0D0h],rax
     1a: mov     edi,0FFFFFF38h
     1f: mov     esi,18h
     24: mov     edx,18h
     29: call    ryo_h_Copy
     2e: call    fn0
     33: nop     [rcx-50h]
     3a: mov     edi,0FFFFFF54h
     3f: mov     esi,0FFFFFFB0h
     44: mov     rdx,0FFFFFFFFFFFFFFFFh
     4b: xor     ecx,ecx
     4d: xor     r8d,r8d
     50: mov     r9d,1
     56: call    ryo_h_DiscrNicheW64
     5b: mov     edi,0FFFFFFA8h
     60: mov     esi,0FFFFFF54h
     65: call    ryo_h_ZextW32W64
     6a: mov     edi,0FFFFFFA8h
     6f: xor     esi,esi
     71: mov     edx,2
     76: call    ryo_h_SwitchDenseW64
     7b: lea     rcx,[8Ch]
     82: movsxd  rax,[rcx+rax*4]
     86: add     rax,rcx
     89: jmp     rax
     8b: int3
     8c: .long   f6h
     90: .long   b8h
     94: .long   b1h
     98: nop     [rax+rax]
     a0: mov     edi,0FFFFFFD8h
     a5: mov     esi,28h
     aa: call    ryo_h_Ret
     af: leave
     b0: ret
     b1: call    ryo_h_Unreachable
     b6: ud2
     b8: mov     edi,0FFFFFF80h
     bd: mov     esi,0FFFFFFB0h
     c2: mov     edx,28h
     c7: call    ryo_h_Copy
     cc: mov     edi,0FFFFFF58h
     d1: mov     esi,0FFFFFF80h
     d6: mov     edx,28h
     db: call    ryo_h_Copy
     e0: mov     edi,0FFFFFFD8h
     e5: mov     esi,0FFFFFF58h
     ea: mov     edx,28h
     ef: call    ryo_h_Copy
     f4: jmp     0A0h
     f6: mov     edi,0FFFFFF98h
     fb: mov     esi,0FFFFFFB8h
    100: call    ryo_h_MovW128
    105: mov     edi,0FFFFFF88h
    10a: mov     esi,0FFFFFF98h
    10f: call    ryo_h_MovW128
    114: mov     edi,0FFFFFFE0h
    119: mov     esi,0FFFFFF88h
    11e: call    ryo_h_MovW128
    123: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    12b: jmp     0A0h

fn std::collections::HashMap::<std::string::String, usize>::len
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+18h]
     10: mov     [rbp-8],rax
     14: mov     edi,0FFFFFFF8h
     19: mov     esi,8
     1e: call    ryo_h_Ret
     23: leave
     24: ret

fn std::collections::HashMap::<std::string::String, usize>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     edi,0FFFFFF60h
     10: lea     rsi,[k0]
     17: call    ryo_h_AddrAbs
     1c: call    fn1
     21: nop     [rcx-40h]
     28: mov     edi,0FFFFFF70h
     2d: lea     rsi,[k2]
     34: mov     edx,20h
     39: call    ryo_h_Const
     3e: mov     edi,0FFFFFFB0h
     43: mov     esi,0FFFFFFC0h
     48: call    ryo_h_MovW128
     4d: mov     edi,0FFFFFF90h
     52: mov     esi,0FFFFFF70h
     57: mov     edx,20h
     5c: call    ryo_h_Copy
     61: mov     edi,0FFFFFFD0h
     66: mov     esi,0FFFFFF90h
     6b: mov     edx,30h
     70: call    ryo_h_Copy
     75: mov     edi,0FFFFFFD0h
     7a: mov     esi,30h
     7f: call    ryo_h_Ret
     84: leave
     85: ret

fn std::collections::HashMap::<u64, u64>::entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-38h],rax
     13: mov     [rbp-80h],rax
     17: mov     rax,[rbp+18h]
     1b: mov     [rbp-78h],rax
     1f: call    fn0
     24: nop     [rcx-30h]
     2b: mov     edi,0FFFFFF94h
     30: mov     esi,0FFFFFFD0h
     35: xor     edx,edx
     37: xor     ecx,ecx
     39: xor     r8d,r8d
     3c: mov     r9d,1
     42: call    ryo_h_DiscrNicheW64
     47: mov     edi,0FFFFFFC8h
     4c: mov     esi,0FFFFFF94h
     51: call    ryo_h_ZextW32W64
     56: mov     edi,0FFFFFFC8h
     5b: xor     esi,esi
     5d: mov     edx,2
     62: call    ryo_h_SwitchDenseW64
     67: lea     rcx,[78h]
     6e: movsxd  rax,[rcx+rax*4]
     72: add     rax,rcx
     75: jmp     rax
     77: int3
     78: .long   e6h
     7c: .long   a8h
     80: .long   a1h
     84: nop     [rax+rax]
     8d: nop     [rax]
     90: mov     edi,0FFFFFFE8h
     95: mov     esi,18h
     9a: call    ryo_h_Ret
     9f: leave
     a0: ret
     a1: call    ryo_h_Unreachable
     a6: ud2
     a8: mov     edi,0FFFFFFB0h
     ad: mov     esi,0FFFFFFD0h
     b2: mov     edx,18h
     b7: call    ryo_h_Copy
     bc: mov     edi,0FFFFFF98h
     c1: mov     esi,0FFFFFFB0h
     c6: mov     edx,18h
     cb: call    ryo_h_Copy
     d0: mov     edi,0FFFFFFE8h
     d5: mov     esi,0FFFFFF98h
     da: mov     edx,18h
     df: call    ryo_h_Copy
     e4: jmp     90h
     e6: mov     edi,0FFFFFFB8h
     eb: mov     esi,0FFFFFFD8h
     f0: call    ryo_h_MovW128
     f5: mov     edi,0FFFFFFA8h
     fa: mov     esi,0FFFFFFB8h
     ff: call    ryo_h_MovW128
    104: mov     edi,0FFFFFFF0h
    109: mov     esi,0FFFFFFA8h
    10e: call    ryo_h_MovW128
    113: mov     qword ptr [rbp-18h],0
    11b: jmp     90h

fn std::collections::HashMap::<u64, u64>::get::<u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     [rbp-20h],rax
     14: mov     rax,[rbp+18h]
     18: mov     [rbp-18h],rax
     1c: call    fn0
     21: nop     [rcx-8]
     28: mov     edi,0FFFFFFF8h
     2d: mov     esi,8
     32: call    ryo_h_Ret
     37: leave
     38: ret

fn std::collections::HashMap::<u64, u64>::len
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+18h]
     10: mov     [rbp-8],rax
     14: mov     edi,0FFFFFFF8h
     19: mov     esi,8
     1e: call    ryo_h_Ret
     23: leave
     24: ret

fn std::collections::HashMap::<u64, u64>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     edi,0FFFFFF60h
     10: lea     rsi,[k0]
     17: call    ryo_h_AddrAbs
     1c: call    fn1
     21: nop     [rcx-40h]
     28: mov     edi,0FFFFFF70h
     2d: lea     rsi,[k2]
     34: mov     edx,20h
     39: call    ryo_h_Const
     3e: mov     edi,0FFFFFFB0h
     43: mov     esi,0FFFFFFC0h
     48: call    ryo_h_MovW128
     4d: mov     edi,0FFFFFF90h
     52: mov     esi,0FFFFFF70h
     57: mov     edx,20h
     5c: call    ryo_h_Copy
     61: mov     edi,0FFFFFFD0h
     66: mov     esi,0FFFFFF90h
     6b: mov     edx,30h
     70: call    ryo_h_Copy
     75: mov     edi,0FFFFFFD0h
     7a: mov     esi,30h
     7f: call    ryo_h_Ret
     84: leave
     85: ret

fn std::collections::HashMap::<u64, u64>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-10h],rax
     14: call    fn0
     19: nop     [rcx]
     20: xor     edi,edi
     22: xor     esi,esi
     24: call    ryo_h_Ret
     29: leave
     2a: ret

fn std::collections::HashMap::<u64, u64>::values
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-80h],rax
     13: mov     [rbp-90h],rax
     1a: call    fn0
     1f: nop     [rcx-78h]
     26: mov     edi,0FFFFFFB0h
     2b: mov     esi,0FFFFFF88h
     30: mov     edx,28h
     35: call    ryo_h_Copy
     3a: mov     edi,0FFFFFFD8h
     3f: mov     esi,0FFFFFFB0h
     44: mov     edx,28h
     49: call    ryo_h_Copy
     4e: mov     edi,0FFFFFFD8h
     53: mov     esi,28h
     58: call    ryo_h_Ret
     5d: leave
     5e: ret

fn std::collections::hash_map::Entry::<'_, std::string::String, usize>::or_default
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     edi,0FFFFFF24h
     10: mov     esi,10h
     15: mov     rdx,0FFFFFFFFFFFFFFFFh
     1c: xor     ecx,ecx
     1e: xor     r8d,r8d
     21: mov     r9d,1
     27: call    ryo_h_DiscrNicheW64
     2c: mov     edi,0FFFFFFF0h
     31: mov     esi,0FFFFFF24h
     36: call    ryo_h_ZextW32W64
     3b: mov     edi,0FFFFFFF0h
     40: xor     esi,esi
     42: mov     edx,2
     47: call    ryo_h_SwitchDenseW64
     4c: lea     rcx,[5Ch]
     53: movsxd  rax,[rcx+rax*4]
     57: add     rax,rcx
     5a: jmp     rax
     5c: .long   a9h
     60: .long   6fh
     64: .long   68h
     68: call    ryo_h_Unreachable
     6d: ud2
     6f: mov     edi,0FFFFFFA8h
     74: mov     esi,10h
     79: mov     edx,28h
     7e: call    ryo_h_Copy
     83: mov     byte ptr [rbp-11h],1
     87: mov     edi,0FFFFFF80h
     8c: mov     esi,0FFFFFFA8h
     91: mov     edx,28h
     96: call    ryo_h_Copy
     9b: call    fn0
     a0: nop     [rcx-88h]
     a7: jmp     0D2h
     a9: mov     rax,[rbp+18h]
     ad: mov     [rbp-58h],rax
     b1: mov     rax,[rbp+20h]
     b5: mov     [rbp-50h],rax
     b9: mov     byte ptr [rbp-0D9h],0
     c0: test    byte ptr [rbp-0D9h],0FFh
     c7: je      1ECh
     cd: jmp     1E2h
     d2: mov     byte ptr [rbp-11h],0
     d6: mov     rax,[rbp-60h]
     da: mov     [rbp-0B8h],rax
     e1: mov     edi,0FFFFFF30h
     e6: mov     esi,0FFFFFF80h
     eb: mov     edx,18h
     f0: call    ryo_h_Copy
     f5: mov     rax,[rbp-68h]
     f9: mov     [rbp-0D8h],rax
    100: mov     edi,0FFFFFF50h
    105: mov     esi,0FFFFFF30h
    10a: mov     edx,18h
    10f: call    ryo_h_Copy
    114: mov     rax,[rbp-88h]
    11b: mov     [rbp-98h],rax
    122: mov     rax,[rbp-0D8h]
    129: mov     [rbp-110h],rax
    130: mov     rax,[rbp-0B8h]
    137: mov     [rbp-108h],rax
    13e: mov     edi,0FFFFFF00h
    143: mov     esi,0FFFFFF50h
    148: mov     edx,20h
    14d: call    ryo_h_Copy
    152: call    fn1
    157: nop     [rcx-90h]
    15e: jmp     23Ch
    163: nop     [rax+rax]
    16c: nop     [rax]
    170: mov     edi,0FFFFFFF8h
    175: mov     esi,8
    17a: call    ryo_h_Ret
    17f: leave
    180: ret
    181: nop     [rax+rax]
    18a: nop     [rax+rax]
    190: mov     edi,0FFFFFFD0h
    195: call    ryo_h_Resume
    19a: ud2
    19c: nop     [rax]
    1a0: lea     rax,[rbp-80h]
    1a4: mov     [rbp-0E0h],rax
    1ab: mov     [rbp-110h],rax
    1b2: call    fn2
    1b7: nop     [rcx-0E0h]
    1be: jmp     190h
    1c0: test    byte ptr [rbp-11h],0FFh
    1c4: je      190h
    1c6: jmp     1A0h
    1c8: nop     [rax+rax]
    1d0: mov     rax,[rbp-40h]
    1d4: mov     [rbp-38h],rax
    1d8: lea     rax,[rax+18h]
    1dc: mov     [rbp-8],rax
    1e0: jmp     170h
    1e2: mov     qword ptr [rbp-40h],8
    1ea: jmp     1D0h
    1ec: mov     rax,[rbp-58h]
    1f0: mov     [rbp-48h],rax
    1f4: mov     byte ptr [rbp-0D9h],0
    1fb: test    byte ptr [rbp-0D9h],0FFh
    202: je      21Ch
    204: jmp     212h
    206: nop     [rax+rax]
    20f: nop
    210: jmp     1D0h
    212: mov     rax,[rbp-48h]
    216: mov     [rbp-40h],rax
    21a: jmp     210h
    21c: mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    227: mov     rax,[rbp-48h]
    22b: imul    rcx,[rbp-0E0h],20h
    233: add     rax,rcx
    236: mov     [rbp-40h],rax
    23a: jmp     210h
    23c: mov     byte ptr [rbp-0D9h],0
    243: test    byte ptr [rbp-0D9h],0FFh
    24a: je      278h
    24c: jmp     26Bh
    24e: xchg    ax,ax
    250: mov     rax,[rbp-0A0h]
    257: mov     [rbp-98h],rax
    25e: lea     rax,[rax+18h]
    262: mov     [rbp-8],rax
    266: jmp     170h
    26b: mov     qword ptr [rbp-0A0h],8
    276: jmp     250h
    278: mov     rax,[rbp-90h]
    27f: mov     [rbp-0B0h],rax
    286: mov     [rbp-0A8h],rax
    28d: mov     byte ptr [rbp-0D9h],0
    294: test    byte ptr [rbp-0D9h],0FFh
    29b: je      2B2h
    29d: jmp     2A2h
    29f: nop
    2a0: jmp     250h
    2a2: mov     rax,[rbp-0A8h]
    2a9: mov     [rbp-0A0h],rax
    2b0: jmp     2A0h
    2b2: mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    2bd: mov     rax,[rbp-0A8h]
    2c4: imul    rcx,[rbp-0E0h],20h
    2cc: add     rax,rcx
    2cf: mov     [rbp-0A0h],rax
    2d6: jmp     2A0h
    2d8: nop     [rax+rax]
    2e0: lea     rdi,[sym3]
    2e7: lea     rsi,[site4]
    2ee: mov     edx,0FFFFFF20h
    2f3: call    ryo_h_CallExt
    2f8: test    rax,rax
    2fb: je      308h
    2fd: call    rax
    2ff: nop     [rcx-0D8h]
    306: jmp     318h
    308: mov     rdi,rbp
    30b: lea     rsi,[ro+4]
    312: call    qword ptr [sym5]
    318: call    ryo_h_Unreachable
    31d: ud2
    31f: mov     rdi,rax
    322: mov     esi,0FFFFFFD0h
    327: call    ryo_h_Lpad
    32c: jmp     1C0h
    331: mov     rdi,rax
    334: mov     esi,0FFFFFFD0h
    339: call    ryo_h_Lpad
    33e: jmp     2E0h

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     edi,0FFFFFF84h
     10: mov     esi,10h
     15: xor     edx,edx
     17: xor     ecx,ecx
     19: xor     r8d,r8d
     1c: mov     r9d,1
     22: call    ryo_h_DiscrNicheW64
     27: mov     edi,0FFFFFFF0h
     2c: mov     esi,0FFFFFF84h
     31: call    ryo_h_ZextW32W64
     36: mov     edi,0FFFFFFF0h
     3b: xor     esi,esi
     3d: mov     edx,2
     42: call    ryo_h_SwitchDenseW64
     47: lea     rcx,[58h]
     4e: movsxd  rax,[rcx+rax*4]
     52: add     rax,rcx
     55: jmp     rax
     57: int3
     58: .long   d2h
     5c: .long   6bh
     60: .long   64h
     64: call    ryo_h_Unreachable
     69: ud2
     6b: mov     rax,[rbp+18h]
     6f: mov     [rbp-68h],rax
     73: mov     rax,[rbp+20h]
     77: mov     [rbp-70h],rax
     7b: mov     rax,[rbp+10h]
     7f: mov     [rbp-78h],rax
     83: mov     byte ptr [rbp-11h],0
     87: mov     rax,[rbp+28h]
     8b: mov     [rbp-38h],rax
     8f: mov     rax,[rbp-70h]
     93: mov     [rbp-50h],rax
     97: mov     rax,[rbp-38h]
     9b: mov     [rbp-48h],rax
     9f: mov     rax,[rbp-78h]
     a3: mov     [rbp-0A0h],rax
     aa: mov     rax,[rbp-68h]
     ae: mov     [rbp-98h],rax
     b5: mov     edi,0FFFFFF70h
     ba: mov     esi,0FFFFFFB0h
     bf: call    ryo_h_MovW128
     c4: call    fn0
     c9: nop     [rcx-40h]
     d0: jmp     148h
     d2: mov     rax,[rbp+18h]
     d6: mov     [rbp-58h],rax
     da: mov     rax,[rbp+20h]
     de: mov     [rbp-50h],rax
     e2: mov     byte ptr [rbp-79h],0
     e6: test    byte ptr [rbp-79h],0FFh
     ea: je      1EFh
     f0: jmp     1E5h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: mov     edi,0FFFFFFD0h
    125: call    ryo_h_Resume
    12a: ud2
    12c: nop     [rax]
    130: jmp     120h
    132: nop     [rax+rax]
    13b: nop     [rax+rax]
    140: test    byte ptr [rbp-11h],0FFh
    144: je      120h
    146: jmp     130h
    148: mov     byte ptr [rbp-79h],0
    14c: test    byte ptr [rbp-79h],0FFh
    150: je      17Ch
    152: jmp     172h
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     rax,[rbp-50h]
    164: mov     [rbp-48h],rax
    168: lea     rax,[rax+8]
    16c: mov     [rbp-8],rax
    170: jmp     100h
    172: mov     qword ptr [rbp-50h],8
    17a: jmp     160h
    17c: mov     rax,[rbp-40h]
    180: mov     [rbp-60h],rax
    184: mov     [rbp-58h],rax
    188: mov     byte ptr [rbp-79h],0
    18c: test    byte ptr [rbp-79h],0FFh
    190: je      1ACh
    192: jmp     1A2h
    194: nop     [rax+rax]
    19d: nop     [rax]
    1a0: jmp     160h
    1a2: mov     rax,[rbp-58h]
    1a6: mov     [rbp-50h],rax
    1aa: jmp     1A0h
    1ac: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    1b4: mov     rax,[rbp-58h]
    1b8: imul    rcx,[rbp-80h],10h
    1bd: add     rax,rcx
    1c0: mov     [rbp-50h],rax
    1c4: jmp     1A0h
    1c6: nop     [rax+rax]
    1cf: nop
    1d0: mov     rax,[rbp-40h]
    1d4: mov     [rbp-38h],rax
    1d8: lea     rax,[rax+8]
    1dc: mov     [rbp-8],rax
    1e0: jmp     100h
    1e5: mov     qword ptr [rbp-40h],8
    1ed: jmp     1D0h
    1ef: mov     rax,[rbp-58h]
    1f3: mov     [rbp-48h],rax
    1f7: mov     byte ptr [rbp-79h],0
    1fb: test    byte ptr [rbp-79h],0FFh
    1ff: je      21Ch
    201: jmp     212h
    203: nop     [rax+rax]
    20c: nop     [rax]
    210: jmp     1D0h
    212: mov     rax,[rbp-48h]
    216: mov     [rbp-40h],rax
    21a: jmp     210h
    21c: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    224: mov     rax,[rbp-48h]
    228: imul    rcx,[rbp-80h],10h
    22d: add     rax,rcx
    230: mov     [rbp-40h],rax
    234: jmp     210h
    236: mov     rdi,rax
    239: mov     esi,0FFFFFFD0h
    23e: call    ryo_h_Lpad
    243: jmp     140h

fn std::fmt::Arguments::<'_>::as_statically_known_str
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-28h],rax
     17: mov     [rbp-20h],rax
     1b: and     rax,1
     1f: mov     [rbp-28h],rax
     23: cmp     rax,1
     27: je      5Fh
     29: jmp     8Ah
     2b: nop     [rax+rax]
     30: test    byte ptr [rbp-19h],0FFh
     34: je      38h
     36: jmp     4Eh
     38: mov     edi,0FFFFFFF0h
     3d: lea     rsi,[k0]
     44: mov     edx,10h
     49: call    ryo_h_Const
     4e: mov     edi,0FFFFFFF0h
     53: mov     esi,10h
     58: call    ryo_h_Ret
     5d: leave
     5e: ret
     5f: mov     rax,[rbp+10h]
     63: mov     rax,[rax]
     66: mov     [rbp-50h],rax
     6a: mov     [rbp-28h],rax
     6e: mov     rax,[rbp-20h]
     72: shr     rax,1
     76: mov     [rbp-58h],rax
     7a: mov     byte ptr [rbp-69h],1
     7e: test    byte ptr [rbp-69h],0FFh
     82: je      140h
     88: jmp     0F3h
     8a: mov     edi,0FFFFFFF0h
     8f: lea     rsi,[k1]
     96: mov     edx,10h
     9b: call    ryo_h_Const
     a0: mov     edi,0FFFFFF94h
     a5: mov     esi,0FFFFFFF0h
     aa: xor     edx,edx
     ac: xor     ecx,ecx
     ae: xor     r8d,r8d
     b1: mov     r9d,1
     b7: call    ryo_h_DiscrNicheW64
     bc: mov     edi,0FFFFFFD8h
     c1: mov     esi,0FFFFFF94h
     c6: call    ryo_h_ZextW32W64
     cb: cmp     qword ptr [rbp-28h],1
     d0: sete    [rbp-1Ah]
     d4: movzx   eax,byte ptr [rbp-1Ah]
     d8: mov     [rbp-0A0h],al
     de: mov     rdi,rbp
     e1: lea     rsi,[ro+4]
     e8: call    qword ptr [sym2]
     ee: jmp     30h
     f3: mov     rax,[rbp-50h]
     f7: mov     [rbp-60h],rax
     fb: mov     [rbp-0A0h],rax
    102: mov     qword ptr [rbp-98h],1
    10d: mov     qword ptr [rbp-90h],1
    118: mov     rax,[rbp-58h]
    11c: mov     [rbp-88h],rax
    123: mov     edi,0FFFFFF80h
    128: lea     rsi,[k3]
    12f: call    ryo_h_AddrAbs
    134: call    fn4
    139: nop     [rcx-18h]
    140: mov     rax,[rbp-28h]
    144: mov     [rbp-68h],rax
    148: mov     rax,[rbp-58h]
    14c: mov     [rbp-60h],rax
    150: mov     rax,[rbp-68h]
    154: mov     [rbp-48h],rax
    158: mov     rax,[rbp-60h]
    15c: mov     [rbp-40h],rax
    160: mov     edi,0FFFFFFC8h
    165: mov     esi,0FFFFFFB8h
    16a: call    ryo_h_MovW128
    16f: mov     edi,0FFFFFFF0h
    174: mov     esi,0FFFFFFC8h
    179: call    ryo_h_MovW128
    17e: jmp     0A0h

fn std::fmt::Arguments::<'_>::new::<4, 1>
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

fn std::fmt::Arguments::<'_>::new::<59, 6>
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

fn std::fmt::format
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-40h],rax
     13: mov     [rbp-38h],rax
     17: and     rax,1
     1b: mov     [rbp-40h],rax
     1f: cmp     rax,1
     23: je      41h
     25: jmp     6Fh
     27: nop     [rax+rax]
     30: mov     edi,0FFFFFFE8h
     35: mov     esi,18h
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: mov     rax,[rbp+10h]
     45: mov     [rbp-68h],rax
     49: mov     [rbp-40h],rax
     4d: mov     rax,[rbp-38h]
     51: shr     rax,1
     55: mov     [rbp-70h],rax
     59: mov     byte ptr [rbp-81h],1
     60: test    byte ptr [rbp-81h],0FFh
     67: je      114h
     6d: jmp     0C7h
     6f: mov     edi,0FFFFFFD0h
     74: lea     rsi,[k0]
     7b: mov     edx,10h
     80: call    ryo_h_Const
     85: nop     [rax+rax]
     8e: xchg    ax,ax
     90: lea     rax,[rbp+10h]
     94: mov     [rbp-40h],rax
     98: mov     [rbp-38h],rax
     9c: mov     edi,0FFFFFF58h
     a1: mov     esi,0FFFFFFD0h
     a6: call    ryo_h_MovW128
     ab: mov     rax,[rbp-38h]
     af: mov     [rbp-0B0h],rax
     b6: call    fn1
     bb: nop     [rcx-18h]
     c2: jmp     30h
     c7: mov     rax,[rbp-68h]
     cb: mov     [rbp-78h],rax
     cf: mov     [rbp-0B0h],rax
     d6: mov     qword ptr [rbp-0A8h],1
     e1: mov     qword ptr [rbp-0A0h],1
     ec: mov     rax,[rbp-70h]
     f0: mov     [rbp-98h],rax
     f7: mov     edi,0FFFFFF70h
     fc: lea     rsi,[k2]
    103: call    ryo_h_AddrAbs
    108: call    fn3
    10d: nop     [rcx-20h]
    114: mov     rax,[rbp-40h]
    118: mov     [rbp-80h],rax
    11c: mov     rax,[rbp-70h]
    120: mov     [rbp-78h],rax
    124: mov     rax,[rbp-80h]
    128: mov     [rbp-60h],rax
    12c: mov     rax,[rbp-78h]
    130: mov     [rbp-58h],rax
    134: mov     edi,0FFFFFFB0h
    139: mov     esi,0FFFFFFA0h
    13e: call    ryo_h_MovW128
    143: mov     edi,0FFFFFFD0h
    148: mov     esi,0FFFFFFB0h
    14d: call    ryo_h_MovW128
    152: jmp     90h

fn std::fmt::format::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-20h],rax
     10: mov     edi,0FFFFFFD0h
     15: mov     esi,0FFFFFFE0h
     1a: xor     edx,edx
     1c: call    ryo_h_LoadW128
     21: mov     edi,0FFFFFFB0h
     26: mov     esi,0FFFFFFD0h
     2b: call    ryo_h_MovW128
     30: lea     rdi,[sym0]
     37: lea     rsi,[site1]
     3e: mov     edx,0FFFFFFC8h
     43: call    ryo_h_CallExt
     48: test    rax,rax
     4b: je      58h
     4d: call    rax
     4f: nop     [rcx-18h]
     56: jmp     68h
     58: mov     rdi,rbp
     5b: lea     rsi,[ro+4]
     62: call    qword ptr [sym2]
     68: mov     edi,0FFFFFFE8h
     6d: mov     esi,18h
     72: call    ryo_h_Ret
     77: leave
     78: ret

fn std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: lea     rdi,[sym0]
      f: lea     rsi,[site1]
     16: mov     edx,0FFFFFFC8h
     1b: call    ryo_h_CallExt
     20: test    rax,rax
     23: je      30h
     25: call    rax
     27: nop     [rcx-20h]
     2e: jmp     40h
     30: mov     rdi,rbp
     33: lea     rsi,[ro+4]
     3a: call    qword ptr [sym2]
     40: mov     edi,0FFFFFFD0h
     45: mov     esi,0FFFFFFE0h
     4a: call    ryo_h_MovW128
     4f: mov     edi,0FFFFFFF0h
     54: mov     esi,0FFFFFFD0h
     59: call    ryo_h_MovW128
     5e: mov     edi,0FFFFFFF0h
     63: mov     esi,10h
     68: call    ryo_h_Ret
     6d: leave
     6e: ret

fn std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     edi,0FFFFFFE8h
      d: lea     rsi,[sym0]
     14: call    ryo_h_AddrSym
     19: mov     rdi,rbp
     1c: lea     rsi,[ro+4]
     23: call    qword ptr [sym1]
     29: mov     rax,[rbp-10h]
     2d: mov     [rbp-30h],rax
     31: mov     rax,[rbp+18h]
     35: mov     [rbp-28h],rax
     39: call    fn2
     3e: nop     [rcx-8]
     45: mov     edi,0FFFFFFF8h
     4a: mov     esi,8
     4f: call    ryo_h_Ret
     54: leave
     55: ret

fn std::hash::RandomState::new::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-30h],rax
     10: mov     [rbp-28h],rax
     14: mov     rax,[rax]
     17: mov     [rbp-18h],rax
     1b: mov     rax,[rbp-28h]
     1f: mov     rax,[rax+8]
     23: mov     [rbp-20h],rax
     27: mov     rax,[rbp-18h]
     2b: add     rax,1
     2f: mov     [rbp-38h],rax
     33: mov     [rbp-30h],rax
     37: mov     rax,[rbp-20h]
     3b: mov     [rbp-28h],rax
     3f: mov     rax,[rbp+10h]
     43: mov     [rbp-40h],rax
     47: mov     [rbp-38h],rax
     4b: mov     edi,0FFFFFFC8h
     50: xor     esi,esi
     52: mov     edx,0FFFFFFD0h
     57: call    ryo_h_StoreW128
     5c: mov     rax,[rbp-18h]
     60: mov     [rbp-10h],rax
     64: mov     rax,[rbp-20h]
     68: mov     [rbp-8],rax
     6c: mov     edi,0FFFFFFF0h
     71: mov     esi,10h
     76: call    ryo_h_Ret
     7b: leave
     7c: ret

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

fn std::hint::black_box::<u64>
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

fn std::hint::must_use::<std::string::String>
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

fn std::hint::unreachable_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFF0h
     10: lea     rsi,[k0]
     17: call    ryo_h_AddrAbs
     1c: mov     qword ptr [rbp-8],0C7h
     24: mov     rax,[rbp-10h]
     28: mov     [rbp-40h],rax
     2c: mov     rax,[rbp-8]
     30: mov     [rbp-38h],rax
     34: mov     rax,[rbp-40h]
     38: mov     [rbp-30h],rax
     3c: mov     [rbp-28h],rax
     40: mov     edi,0FFFFFFA8h
     45: lea     rsi,[k1]
     4c: call    ryo_h_AddrAbs
     51: mov     qword ptr [rbp-50h],0C7h
     59: mov     rax,[rbp-50h]
     5d: mov     [rbp-48h],rax
     61: shl     rax,1
     65: mov     [rbp-40h],rax
     69: or      rax,1
     6d: mov     [rbp-38h],rax
     71: mov     [rbp-30h],rax
     75: mov     rax,[rbp-28h]
     79: mov     [rbp-20h],rax
     7d: mov     rax,[rbp-30h]
     81: mov     [rbp-18h],rax
     85: mov     edi,0FFFFFF80h
     8a: mov     esi,0FFFFFFE0h
     8f: call    ryo_h_MovW128
     94: mov     byte ptr [rbp-70h],0
     98: mov     rax,[rbp+10h]
     9c: mov     [rbp-68h],rax
     a0: lea     rdi,[sym2]
     a7: lea     rsi,[site3]
     ae: mov     edx,0FFFFFFA0h
     b3: call    ryo_h_CallExt
     b8: test    rax,rax
     bb: je      0C8h
     bd: call    rax
     bf: nop     [rcx-10h]
     c6: jmp     0D8h
     c8: mov     rdi,rbp
     cb: lea     rsi,[ro+4]
     d2: call    qword ptr [sym4]
     d8: call    ryo_h_Unreachable
     dd: ud2

fn std::intrinsics::cold_path
      0: push    rbp
      1: mov     rbp,rsp
      4: xor     edi,edi
      6: xor     esi,esi
      8: call    ryo_h_Ret
      d: leave
      e: ret

fn std::intrinsics::is_val_statically_known::<bool>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     byte ptr [rbp-1],0
      c: mov     edi,0FFFFFFFFh
     11: mov     esi,1
     16: call    ryo_h_Ret
     1b: leave
     1c: ret

fn std::intrinsics::rotate_left::<u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     qword ptr [rbp-30h],8
     10: mov     edi,0FFFFFFDCh
     15: mov     esi,0FFFFFFD0h
     1a: call    ryo_h_TruncW64W32
     1f: imul    eax,[rbp-24h],8
     23: mov     [rbp-20h],eax
     26: cmp     eax,0
     29: jne     7Bh
     2b: mov     edi,0FFFFFFB0h
     30: lea     rsi,[k0]
     37: call    ryo_h_AddrAbs
     3c: lea     rdi,[sym1]
     43: lea     rsi,[site2]
     4a: mov     edx,0FFFFFFD0h
     4f: call    ryo_h_CallExt
     54: test    rax,rax
     57: je      64h
     59: call    rax
     5b: nop     [rcx-24h]
     62: jmp     74h
     64: mov     rdi,rbp
     67: lea     rsi,[ro+4]
     6e: call    qword ptr [sym3]
     74: call    ryo_h_Unreachable
     79: ud2
     7b: mov     edi,0FFFFFFE4h
     80: mov     esi,18h
     85: mov     edx,0FFFFFFE0h
     8a: call    ryo_h_RemUW32
     8f: mov     edi,0FFFFFFD0h
     94: mov     esi,0FFFFFFE4h
     99: call    ryo_h_ZextW32W64
     9e: mov     qword ptr [rbp-38h],3Fh
     a6: mov     rax,[rbp-38h]
     aa: sub     rax,[rbp-30h]
     ae: mov     [rbp-38h],rax
     b2: mov     edi,0FFFFFFC0h
     b7: mov     esi,10h
     bc: mov     edx,0FFFFFFD0h
     c1: call    ryo_h_ShlW64
     c6: mov     rax,[rbp+10h]
     ca: shr     rax,1
     ce: mov     [rbp-48h],rax
     d2: mov     edi,0FFFFFFB8h
     d7: mov     esi,0FFFFFFB8h
     dc: mov     edx,0FFFFFFC8h
     e1: call    ryo_h_ShrUW64
     e6: mov     rax,[rbp-40h]
     ea: or      rax,[rbp-48h]
     ee: mov     [rbp-8],rax
     f2: mov     edi,0FFFFFFF8h
     f7: mov     esi,8
     fc: call    ryo_h_Ret
    101: leave
    102: ret
    103: nop     [rax+rax]
    10c: nop     [rax]
    110: lea     rdi,[sym4]
    117: lea     rsi,[site5]
    11e: mov     edx,0FFFFFFD0h
    123: call    ryo_h_CallExt
    128: test    rax,rax
    12b: je      138h
    12d: call    rax
    12f: nop     [rcx-24h]
    136: jmp     148h
    138: mov     rdi,rbp
    13b: lea     rsi,[ro+4]
    142: call    qword ptr [sym6]
    148: call    ryo_h_Unreachable
    14d: ud2
    14f: mov     rdi,rax
    152: mov     esi,0FFFFFFE8h
    157: call    ryo_h_Lpad
    15c: jmp     110h

fn std::intrinsics::typed_swap_nonoverlapping::<hashbrown::raw::RawTableInner>
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

fn std::io::Error::is_interrupted
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-58h],rax
     16: mov     [rbp-80h],rax
     1a: call    fn0
     1f: nop     [rcx-50h]
     26: jmp     101h
     2b: nop     [rax+rax]
     30: call    ryo_h_Unreachable
     35: ud2
     37: mov     rax,[rbp-48h]
     3b: mov     [rbp-38h],rax
     3f: movzx   eax,byte ptr [rax+10h]
     43: mov     [rbp-69h],al
     46: mov     edi,0FFFFFFA8h
     4b: mov     esi,0FFFFFF97h
     50: call    ryo_h_ZextW8W64
     55: cmp     qword ptr [rbp-58h],23h
     5a: sete    [rbp-1]
     5e: jmp     0F0h
     63: movzx   eax,byte ptr [rbp-4Fh]
     67: mov     [rbp-51h],al
     6a: mov     edi,0FFFFFFA0h
     6f: mov     esi,0FFFFFFAFh
     74: call    ryo_h_ZextW8W64
     79: cmp     qword ptr [rbp-60h],23h
     7e: sete    [rbp-1]
     82: jmp     0F0h
     84: mov     rax,[rbp-48h]
     88: mov     [rbp-20h],rax
     8c: movzx   eax,byte ptr [rax+20h]
     90: mov     [rbp-69h],al
     93: mov     edi,0FFFFFFA8h
     98: mov     esi,0FFFFFF97h
     9d: call    ryo_h_ZextW8W64
     a2: cmp     qword ptr [rbp-58h],23h
     a7: sete    [rbp-1]
     ab: jmp     0F0h
     ad: mov     eax,[rbp-4Ch]
     b0: mov     [rbp-54h],eax
     b3: lea     rdi,[sym1]
     ba: lea     rsi,[site2]
     c1: mov     edx,0FFFFFF90h
     c6: call    ryo_h_CallExt
     cb: test    rax,rax
     ce: je      0DBh
     d0: call    rax
     d2: nop     [rcx-60h]
     d9: jmp     0EBh
     db: mov     rdi,rbp
     de: lea     rsi,[ro+4]
     e5: call    qword ptr [sym3]
     eb: jmp     148h
     ed: nop     [rax]
     f0: mov     edi,0FFFFFFFFh
     f5: mov     esi,1
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: mov     edi,0FFFFFFE8h
    106: mov     esi,0FFFFFFB0h
    10b: call    ryo_h_ZextW8W64
    110: mov     edi,0FFFFFFE8h
    115: xor     esi,esi
    117: mov     edx,4
    11c: call    ryo_h_SwitchDenseW64
    121: lea     rcx,[134h]
    128: movsxd  rax,[rcx+rax*4]
    12c: add     rax,rcx
    12f: jmp     rax
    131: int3
    132: int3
    133: int3
    134: .long   adh
    138: .long   63h
    13c: .long   37h
    140: .long   84h
    144: .long   30h
    148: mov     rax,[rbp-60h]
    14c: mov     rax,[rax+10h]
    150: mov     [rbp-68h],rax
    154: mov     eax,[rbp-54h]
    157: mov     [rbp-80h],eax
    15a: mov     edi,0FFFFFF98h
    15f: lea     rsi,[site4]
    166: call    ryo_h_CallInd
    16b: test    rax,rax
    16e: je      17Bh
    170: call    rax
    172: nop     [rcx-1]
    179: jmp     18Bh
    17b: mov     rdi,rbp
    17e: lea     rsi,[ro+20]
    185: call    qword ptr [sym5]
    18b: jmp     0F0h

fn std::io::ErrorKind::from_prim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,170h
      b: cmp     dword ptr [rbp+10h],0
      f: jne     1Ah
     11: mov     byte ptr [rbp-1],0
     15: jmp     282h
     1a: cmp     dword ptr [rbp+10h],1
     1e: jne     29h
     20: mov     byte ptr [rbp-1],1
     24: jmp     282h
     29: cmp     dword ptr [rbp+10h],2
     2d: jne     38h
     2f: mov     byte ptr [rbp-1],2
     33: jmp     282h
     38: cmp     dword ptr [rbp+10h],3
     3c: jne     47h
     3e: mov     byte ptr [rbp-1],3
     42: jmp     282h
     47: cmp     dword ptr [rbp+10h],4
     4b: jne     56h
     4d: mov     byte ptr [rbp-1],4
     51: jmp     282h
     56: cmp     dword ptr [rbp+10h],5
     5a: jne     65h
     5c: mov     byte ptr [rbp-1],5
     60: jmp     282h
     65: cmp     dword ptr [rbp+10h],6
     69: jne     74h
     6b: mov     byte ptr [rbp-1],6
     6f: jmp     282h
     74: cmp     dword ptr [rbp+10h],7
     78: jne     83h
     7a: mov     byte ptr [rbp-1],7
     7e: jmp     282h
     83: cmp     dword ptr [rbp+10h],8
     87: jne     92h
     89: mov     byte ptr [rbp-1],8
     8d: jmp     282h
     92: cmp     dword ptr [rbp+10h],9
     96: jne     0A1h
     98: mov     byte ptr [rbp-1],9
     9c: jmp     282h
     a1: cmp     dword ptr [rbp+10h],0Ah
     a5: jne     0B0h
     a7: mov     byte ptr [rbp-1],0Ah
     ab: jmp     282h
     b0: cmp     dword ptr [rbp+10h],0Bh
     b4: jne     0BFh
     b6: mov     byte ptr [rbp-1],0Bh
     ba: jmp     282h
     bf: cmp     dword ptr [rbp+10h],0Ch
     c3: jne     0CEh
     c5: mov     byte ptr [rbp-1],0Ch
     c9: jmp     282h
     ce: cmp     dword ptr [rbp+10h],0Dh
     d2: jne     0DDh
     d4: mov     byte ptr [rbp-1],0Dh
     d8: jmp     282h
     dd: cmp     dword ptr [rbp+10h],0Eh
     e1: jne     0ECh
     e3: mov     byte ptr [rbp-1],0Eh
     e7: jmp     282h
     ec: cmp     dword ptr [rbp+10h],0Fh
     f0: jne     0FBh
     f2: mov     byte ptr [rbp-1],0Fh
     f6: jmp     282h
     fb: cmp     dword ptr [rbp+10h],10h
     ff: jne     10Ah
    101: mov     byte ptr [rbp-1],10h
    105: jmp     282h
    10a: cmp     dword ptr [rbp+10h],11h
    10e: jne     119h
    110: mov     byte ptr [rbp-1],11h
    114: jmp     282h
    119: cmp     dword ptr [rbp+10h],12h
    11d: jne     128h
    11f: mov     byte ptr [rbp-1],12h
    123: jmp     282h
    128: cmp     dword ptr [rbp+10h],13h
    12c: jne     137h
    12e: mov     byte ptr [rbp-1],13h
    132: jmp     282h
    137: cmp     dword ptr [rbp+10h],14h
    13b: jne     146h
    13d: mov     byte ptr [rbp-1],14h
    141: jmp     282h
    146: cmp     dword ptr [rbp+10h],15h
    14a: jne     155h
    14c: mov     byte ptr [rbp-1],15h
    150: jmp     282h
    155: cmp     dword ptr [rbp+10h],16h
    159: jne     164h
    15b: mov     byte ptr [rbp-1],16h
    15f: jmp     282h
    164: cmp     dword ptr [rbp+10h],17h
    168: jne     173h
    16a: mov     byte ptr [rbp-1],17h
    16e: jmp     282h
    173: cmp     dword ptr [rbp+10h],18h
    177: jne     182h
    179: mov     byte ptr [rbp-1],18h
    17d: jmp     282h
    182: cmp     dword ptr [rbp+10h],19h
    186: jne     191h
    188: mov     byte ptr [rbp-1],19h
    18c: jmp     282h
    191: cmp     dword ptr [rbp+10h],1Ah
    195: jne     1A0h
    197: mov     byte ptr [rbp-1],1Ah
    19b: jmp     282h
    1a0: cmp     dword ptr [rbp+10h],1Bh
    1a4: jne     1AFh
    1a6: mov     byte ptr [rbp-1],1Bh
    1aa: jmp     282h
    1af: cmp     dword ptr [rbp+10h],1Ch
    1b3: jne     1BEh
    1b5: mov     byte ptr [rbp-1],1Ch
    1b9: jmp     282h
    1be: cmp     dword ptr [rbp+10h],1Dh
    1c2: jne     1CDh
    1c4: mov     byte ptr [rbp-1],1Dh
    1c8: jmp     282h
    1cd: cmp     dword ptr [rbp+10h],1Eh
    1d1: jne     1DCh
    1d3: mov     byte ptr [rbp-1],1Eh
    1d7: jmp     282h
    1dc: cmp     dword ptr [rbp+10h],1Fh
    1e0: jne     1EBh
    1e2: mov     byte ptr [rbp-1],1Fh
    1e6: jmp     282h
    1eb: cmp     dword ptr [rbp+10h],20h
    1ef: jne     1FAh
    1f1: mov     byte ptr [rbp-1],20h
    1f5: jmp     282h
    1fa: cmp     dword ptr [rbp+10h],21h
    1fe: jne     206h
    200: mov     byte ptr [rbp-1],21h
    204: jmp     282h
    206: cmp     dword ptr [rbp+10h],22h
    20a: jne     212h
    20c: mov     byte ptr [rbp-1],22h
    210: jmp     282h
    212: cmp     dword ptr [rbp+10h],23h
    216: jne     21Eh
    218: mov     byte ptr [rbp-1],23h
    21c: jmp     282h
    21e: cmp     dword ptr [rbp+10h],2Ah
    222: jne     22Ah
    224: mov     byte ptr [rbp-1],2Ah
    228: jmp     282h
    22a: cmp     dword ptr [rbp+10h],25h
    22e: jne     236h
    230: mov     byte ptr [rbp-1],25h
    234: jmp     282h
    236: cmp     dword ptr [rbp+10h],24h
    23a: jne     242h
    23c: mov     byte ptr [rbp-1],24h
    240: jmp     282h
    242: cmp     dword ptr [rbp+10h],26h
    246: jne     24Eh
    248: mov     byte ptr [rbp-1],26h
    24c: jmp     282h
    24e: cmp     dword ptr [rbp+10h],27h
    252: jne     25Ah
    254: mov     byte ptr [rbp-1],27h
    258: jmp     282h
    25a: cmp     dword ptr [rbp+10h],28h
    25e: jne     266h
    260: mov     byte ptr [rbp-1],28h
    264: jmp     282h
    266: cmp     dword ptr [rbp+10h],29h
    26a: jne     272h
    26c: mov     byte ptr [rbp-1],29h
    270: jmp     282h
    272: cmp     dword ptr [rbp+10h],2Bh
    276: jne     27Eh
    278: mov     byte ptr [rbp-1],2Bh
    27c: jmp     282h
    27e: mov     byte ptr [rbp-1],0FFh
    282: mov     edi,0FFFFFFFFh
    287: mov     esi,1
    28c: call    ryo_h_Ret
    291: leave
    292: ret

fn std::iter::StepBy::<std::ops::Range<u64>>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-21h],1
      c: cmp     qword ptr [rbp+20h],0
     11: je      4Bh
     13: mov     byte ptr [rbp-21h],0
     17: mov     edi,0FFFFFFB0h
     1c: mov     esi,10h
     21: call    ryo_h_MovW128
     26: mov     edi,0FFFFFF90h
     2b: mov     esi,0FFFFFFB0h
     30: call    ryo_h_MovW128
     35: mov     rax,[rbp+20h]
     39: mov     [rbp-60h],rax
     3d: call    fn0
     42: nop     [rcx-40h]
     49: jmp     0B4h
     4b: mov     edi,0FFFFFF90h
     50: lea     rsi,[k1]
     57: call    ryo_h_AddrAbs
     5c: mov     qword ptr [rbp-68h],1Bh
     64: mov     edi,0FFFFFFA0h
     69: lea     rsi,[k2]
     70: call    ryo_h_AddrAbs
     75: lea     rdi,[sym3]
     7c: lea     rsi,[site4]
     83: mov     edx,0FFFFFFA8h
     88: call    ryo_h_CallExt
     8d: test    rax,rax
     90: je      9Dh
     92: call    rax
     94: nop     [rcx-20h]
     9b: jmp     0ADh
     9d: mov     rdi,rbp
     a0: lea     rsi,[ro+4]
     a7: call    qword ptr [sym5]
     ad: call    ryo_h_Unreachable
     b2: ud2
     b4: mov     rax,[rbp+20h]
     b8: sub     rax,1
     bc: mov     [rbp-48h],rax
     c0: mov     edi,0FFFFFFE0h
     c5: mov     esi,0FFFFFFC0h
     ca: call    ryo_h_MovW128
     cf: mov     rax,[rbp-48h]
     d3: mov     [rbp-10h],rax
     d7: mov     byte ptr [rbp-8],1
     db: mov     edi,0FFFFFFE0h
     e0: mov     esi,20h
     e5: call    ryo_h_Ret
     ea: leave
     eb: ret
     ec: nop     [rax]
     f0: mov     edi,0FFFFFFD0h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: nop     [rax]
    100: jmp     0F0h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: test    byte ptr [rbp-21h],0FFh
    114: je      0F0h
    116: jmp     100h
    118: mov     rdi,rax
    11b: mov     esi,0FFFFFFD0h
    120: call    ryo_h_Lpad
    125: jmp     110h

fn std::iter::StepBy::<std::ops::Range<usize>>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-21h],1
      c: cmp     qword ptr [rbp+20h],0
     11: je      4Bh
     13: mov     byte ptr [rbp-21h],0
     17: mov     edi,0FFFFFFB0h
     1c: mov     esi,10h
     21: call    ryo_h_MovW128
     26: mov     edi,0FFFFFF90h
     2b: mov     esi,0FFFFFFB0h
     30: call    ryo_h_MovW128
     35: mov     rax,[rbp+20h]
     39: mov     [rbp-60h],rax
     3d: call    fn0
     42: nop     [rcx-40h]
     49: jmp     0B4h
     4b: mov     edi,0FFFFFF90h
     50: lea     rsi,[k1]
     57: call    ryo_h_AddrAbs
     5c: mov     qword ptr [rbp-68h],1Bh
     64: mov     edi,0FFFFFFA0h
     69: lea     rsi,[k2]
     70: call    ryo_h_AddrAbs
     75: lea     rdi,[sym3]
     7c: lea     rsi,[site4]
     83: mov     edx,0FFFFFFA8h
     88: call    ryo_h_CallExt
     8d: test    rax,rax
     90: je      9Dh
     92: call    rax
     94: nop     [rcx-20h]
     9b: jmp     0ADh
     9d: mov     rdi,rbp
     a0: lea     rsi,[ro+4]
     a7: call    qword ptr [sym5]
     ad: call    ryo_h_Unreachable
     b2: ud2
     b4: mov     rax,[rbp+20h]
     b8: sub     rax,1
     bc: mov     [rbp-48h],rax
     c0: mov     edi,0FFFFFFE0h
     c5: mov     esi,0FFFFFFC0h
     ca: call    ryo_h_MovW128
     cf: mov     rax,[rbp-48h]
     d3: mov     [rbp-10h],rax
     d7: mov     byte ptr [rbp-8],1
     db: mov     edi,0FFFFFFE0h
     e0: mov     esi,20h
     e5: call    ryo_h_Ret
     ea: leave
     eb: ret
     ec: nop     [rax]
     f0: mov     edi,0FFFFFFD0h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: nop     [rax]
    100: jmp     0F0h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: test    byte ptr [rbp-21h],0FFh
    114: je      0F0h
    116: jmp     100h
    118: mov     rdi,rax
    11b: mov     esi,0FFFFFFD0h
    120: call    ryo_h_Lpad
    125: jmp     110h

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<u64>> for std::ops::Range<u64>>::setup
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-60h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-68h],rax
     1b: mov     rax,[rbp-60h]
     1f: cmp     rax,[rbp-68h]
     23: setb    [rbp-51h]
     27: test    byte ptr [rbp-51h],0FFh
     2b: je      45h
     2d: mov     rax,[rbp+10h]
     31: mov     [rbp-60h],rax
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-68h],rax
     3d: cmp     rax,[rbp-60h]
     41: jae     0AFh
     43: jmp     0C1h
     45: mov     qword ptr [rbp-50h],0
     4d: nop     [rax]
     50: cmp     qword ptr [rbp+20h],0
     55: sete    [rbp-59h]
     59: test    byte ptr [rbp-59h],0FFh
     5d: je      0CBh
     5f: mov     edi,0FFFFFF80h
     64: lea     rsi,[k0]
     6b: call    ryo_h_AddrAbs
     70: lea     rdi,[sym1]
     77: lea     rsi,[site2]
     7e: mov     edx,0FFFFFF88h
     83: call    ryo_h_CallExt
     88: test    rax,rax
     8b: je      98h
     8d: call    rax
     8f: nop     [rcx-70h]
     96: jmp     0A8h
     98: mov     rdi,rbp
     9b: lea     rsi,[ro+4]
     a2: call    qword ptr [sym3]
     a8: call    ryo_h_Unreachable
     ad: ud2
     af: mov     rax,[rbp-68h]
     b3: sub     rax,[rbp-60h]
     b7: mov     [rbp-70h],rax
     bb: mov     [rbp-50h],rax
     bf: jmp     0C9h
     c1: mov     qword ptr [rbp-50h],0
     c9: jmp     50h
     cb: mov     edi,0FFFFFFA8h
     d0: mov     esi,0FFFFFFB0h
     d5: mov     edx,20h
     da: call    ryo_h_DivUW64
     df: test    byte ptr [rbp-59h],0FFh
     e3: je      135h
     e5: mov     edi,0FFFFFF80h
     ea: lea     rsi,[k4]
     f1: call    ryo_h_AddrAbs
     f6: lea     rdi,[sym5]
     fd: lea     rsi,[site6]
    104: mov     edx,0FFFFFF88h
    109: call    ryo_h_CallExt
    10e: test    rax,rax
    111: je      11Eh
    113: call    rax
    115: nop     [rcx-70h]
    11c: jmp     12Eh
    11e: mov     rdi,rbp
    121: lea     rsi,[ro+4]
    128: call    qword ptr [sym7]
    12e: call    ryo_h_Unreachable
    133: ud2
    135: mov     edi,0FFFFFF98h
    13a: mov     esi,0FFFFFFB0h
    13f: mov     edx,20h
    144: call    ryo_h_RemUW64
    149: cmp     qword ptr [rbp-68h],0
    14e: jbe     15Eh
    150: mov     rax,[rbp-58h]
    154: add     rax,1
    158: mov     [rbp-20h],rax
    15c: jmp     166h
    15e: mov     rax,[rbp-58h]
    162: mov     [rbp-20h],rax
    166: mov     rax,[rbp-20h]
    16a: mov     [rbp+18h],rax
    16e: mov     edi,0FFFFFFF0h
    173: mov     esi,10h
    178: call    ryo_h_MovW128
    17d: mov     edi,0FFFFFFF0h
    182: mov     esi,10h
    187: call    ryo_h_Ret
    18c: leave
    18d: ret

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<usize>> for std::ops::Range<usize>>::setup
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-60h],rax
     13: mov     rax,[rbp+18h]
     17: mov     [rbp-68h],rax
     1b: mov     rax,[rbp-60h]
     1f: cmp     rax,[rbp-68h]
     23: setb    [rbp-51h]
     27: test    byte ptr [rbp-51h],0FFh
     2b: je      45h
     2d: mov     rax,[rbp+10h]
     31: mov     [rbp-60h],rax
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-68h],rax
     3d: cmp     rax,[rbp-60h]
     41: jae     0AFh
     43: jmp     0BDh
     45: mov     qword ptr [rbp-50h],0
     4d: nop     [rax]
     50: cmp     qword ptr [rbp+20h],0
     55: sete    [rbp-59h]
     59: test    byte ptr [rbp-59h],0FFh
     5d: je      0C7h
     5f: mov     edi,0FFFFFF80h
     64: lea     rsi,[k0]
     6b: call    ryo_h_AddrAbs
     70: lea     rdi,[sym1]
     77: lea     rsi,[site2]
     7e: mov     edx,0FFFFFF90h
     83: call    ryo_h_CallExt
     88: test    rax,rax
     8b: je      98h
     8d: call    rax
     8f: nop     [rcx-68h]
     96: jmp     0A8h
     98: mov     rdi,rbp
     9b: lea     rsi,[ro+4]
     a2: call    qword ptr [sym3]
     a8: call    ryo_h_Unreachable
     ad: ud2
     af: mov     rax,[rbp-68h]
     b3: sub     rax,[rbp-60h]
     b7: mov     [rbp-50h],rax
     bb: jmp     0C5h
     bd: mov     qword ptr [rbp-50h],0
     c5: jmp     50h
     c7: mov     edi,0FFFFFFA8h
     cc: mov     esi,0FFFFFFB0h
     d1: mov     edx,20h
     d6: call    ryo_h_DivUW64
     db: test    byte ptr [rbp-59h],0FFh
     df: je      131h
     e1: mov     edi,0FFFFFF80h
     e6: lea     rsi,[k4]
     ed: call    ryo_h_AddrAbs
     f2: lea     rdi,[sym5]
     f9: lea     rsi,[site6]
    100: mov     edx,0FFFFFF90h
    105: call    ryo_h_CallExt
    10a: test    rax,rax
    10d: je      11Ah
    10f: call    rax
    111: nop     [rcx-68h]
    118: jmp     12Ah
    11a: mov     rdi,rbp
    11d: lea     rsi,[ro+4]
    124: call    qword ptr [sym7]
    12a: call    ryo_h_Unreachable
    12f: ud2
    131: mov     edi,0FFFFFF98h
    136: mov     esi,0FFFFFFB0h
    13b: mov     edx,20h
    140: call    ryo_h_RemUW64
    145: cmp     qword ptr [rbp-68h],0
    14a: jbe     15Ah
    14c: mov     rax,[rbp-58h]
    150: add     rax,1
    154: mov     [rbp-20h],rax
    158: jmp     162h
    15a: mov     rax,[rbp-58h]
    15e: mov     [rbp-20h],rax
    162: mov     rax,[rbp-20h]
    166: mov     [rbp+18h],rax
    16a: mov     edi,0FFFFFFF0h
    16f: mov     esi,10h
    174: call    ryo_h_MovW128
    179: mov     edi,0FFFFFFF0h
    17e: mov     esi,10h
    183: call    ryo_h_Ret
    188: leave
    189: ret

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-50h],rax
     14: add     rax,1
     18: mov     [rbp-48h],rax
     1c: mov     [rbp-50h],rax
     20: mov     edi,0FFFFFFA4h
     25: mov     esi,0FFFFFFB0h
     2a: xor     edx,edx
     2c: xor     ecx,ecx
     2e: xor     r8d,r8d
     31: mov     r9d,1
     37: call    ryo_h_DiscrNicheW64
     3c: mov     edi,0FFFFFFA8h
     41: mov     esi,0FFFFFFA4h
     46: call    ryo_h_ZextW32W64
     4b: mov     edi,0FFFFFFA8h
     50: xor     esi,esi
     52: mov     edx,2
     57: call    ryo_h_SwitchDenseW64
     5c: lea     rcx,[6Ch]
     63: movsxd  rax,[rcx+rax*4]
     67: add     rax,rcx
     6a: jmp     rax
     6c: .long   107h
     70: .long   126h
     74: .long   100h
     78: nop     [rax+rax]
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax]
     87: mov     [rbp-38h],rax
     8b: add     rax,[rbp-20h]
     8f: mov     [rbp-40h],rax
     93: mov     rax,[rbp+10h]
     97: mov     rcx,[rbp-40h]
     9b: mov     [rax],rcx
     9e: mov     rax,[rbp-28h]
     a2: sub     rax,1
     a6: mov     [rbp-60h],rax
     aa: mov     rax,[rbp+10h]
     ae: mov     rcx,[rbp-60h]
     b2: mov     [rax+8],rcx
     b6: mov     rax,[rbp-38h]
     ba: mov     [rbp-8],rax
     be: mov     qword ptr [rbp-10h],1
     c6: jmp     0E6h
     c8: nop     [rax+rax]
     d0: mov     edi,0FFFFFFF0h
     d5: lea     rsi,[k0]
     dc: mov     edx,10h
     e1: call    ryo_h_Const
     e6: mov     edi,0FFFFFFF0h
     eb: mov     esi,10h
     f0: call    ryo_h_Ret
     f5: leave
     f6: ret
     f7: nop     [rax+rax]
    100: call    ryo_h_Unreachable
    105: ud2
    107: mov     edi,0FFFFFF90h
    10c: lea     rsi,[k1]
    113: call    ryo_h_AddrAbs
    118: call    fn2
    11d: nop     [rcx-18h]
    124: jmp     100h
    126: mov     rax,[rbp-50h]
    12a: mov     [rbp-40h],rax
    12e: mov     [rbp-38h],rax
    132: mov     [rbp-20h],rax
    136: mov     [rbp-28h],rax
    13a: mov     byte ptr [rbp-30h],0
    13e: mov     rax,[rbp+10h]
    142: mov     rax,[rax+8]
    146: mov     [rbp-28h],rax
    14a: cmp     rax,0
    14e: ja      80h
    154: jmp     0D0h

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u32>>::next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: call    fn0
     15: nop     [rcx-8]
     1c: mov     edi,0FFFFFFF8h
     21: mov     esi,8
     26: call    ryo_h_Ret
     2b: leave
     2c: ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
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

fn std::mem::size_of::<std::arch::x86_64::__m128i>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-8],10h
     10: mov     edi,0FFFFFFF8h
     15: mov     esi,8
     1a: call    ryo_h_Ret
     1f: leave
     20: ret

fn std::num::NonZero::<T>::new_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFF0h
     10: lea     rsi,[k0]
     17: call    ryo_h_AddrAbs
     1c: mov     qword ptr [rbp-8],0D1h
     24: mov     rax,[rbp-10h]
     28: mov     [rbp-40h],rax
     2c: mov     rax,[rbp-8]
     30: mov     [rbp-38h],rax
     34: mov     rax,[rbp-40h]
     38: mov     [rbp-30h],rax
     3c: mov     [rbp-28h],rax
     40: mov     edi,0FFFFFFA8h
     45: lea     rsi,[k1]
     4c: call    ryo_h_AddrAbs
     51: mov     qword ptr [rbp-50h],0D1h
     59: mov     rax,[rbp-50h]
     5d: mov     [rbp-48h],rax
     61: shl     rax,1
     65: mov     [rbp-40h],rax
     69: or      rax,1
     6d: mov     [rbp-38h],rax
     71: mov     [rbp-30h],rax
     75: mov     rax,[rbp-28h]
     79: mov     [rbp-20h],rax
     7d: mov     rax,[rbp-30h]
     81: mov     [rbp-18h],rax
     85: mov     edi,0FFFFFF80h
     8a: mov     esi,0FFFFFFE0h
     8f: call    ryo_h_MovW128
     94: mov     byte ptr [rbp-70h],0
     98: mov     rax,[rbp+10h]
     9c: mov     [rbp-68h],rax
     a0: lea     rdi,[sym2]
     a7: lea     rsi,[site3]
     ae: mov     edx,0FFFFFFA0h
     b3: call    ryo_h_CallExt
     b8: test    rax,rax
     bb: je      0C8h
     bd: call    rax
     bf: nop     [rcx-10h]
     c6: jmp     0D8h
     c8: mov     rdi,rbp
     cb: lea     rsi,[ro+4]
     d2: call    qword ptr [sym4]
     d8: call    ryo_h_Unreachable
     dd: ud2

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-22h],1
      c: mov     byte ptr [rbp-21h],1
     10: mov     edi,0FFFFFFACh
     15: mov     esi,18h
     1a: xor     edx,edx
     1c: xor     ecx,ecx
     1e: xor     r8d,r8d
     21: mov     r9d,1
     27: call    ryo_h_DiscrNicheW64
     2c: mov     edi,0FFFFFFE0h
     31: mov     esi,0FFFFFFACh
     36: call    ryo_h_ZextW32W64
     3b: mov     edi,0FFFFFFE0h
     40: xor     esi,esi
     42: mov     edx,2
     47: call    ryo_h_SwitchDenseW64
     4c: lea     rcx,[5Ch]
     53: movsxd  rax,[rcx+rax*4]
     57: add     rax,rcx
     5a: jmp     rax
     5c: .long   6fh
     60: .long   8dh
     64: .long   68h
     68: call    ryo_h_Unreachable
     6d: ud2
     6f: mov     byte ptr [rbp-22h],0
     73: mov     rax,[rbp+10h]
     77: mov     [rbp-38h],rax
     7b: mov     [rbp-70h],rax
     7f: call    fn0
     84: nop     [rcx-18h]
     8b: jmp     0CCh
     8d: mov     edi,0FFFFFFC0h
     92: mov     esi,18h
     97: call    ryo_h_MovW128
     9c: mov     byte ptr [rbp-21h],0
     a0: mov     edi,0FFFFFFB0h
     a5: mov     esi,0FFFFFFC0h
     aa: call    ryo_h_MovW128
     af: mov     edi,0FFFFFF90h
     b4: mov     esi,0FFFFFFB0h
     b9: call    ryo_h_MovW128
     be: call    fn1
     c3: nop     [rcx-18h]
     ca: jmp     0CCh
     cc: mov     edi,0FFFFFFE8h
     d1: mov     esi,18h
     d6: call    ryo_h_Ret
     db: leave
     dc: ret
     dd: nop     [rax]
     e0: test    byte ptr [rbp-22h],0FFh
     e4: jne     118h
     e6: nop     [rax+rax]
     ef: nop
     f0: mov     edi,0FFFFFFD0h
     f5: call    ryo_h_Resume
     fa: ud2
     fc: nop     [rax]
    100: jmp     0E0h
    102: nop     [rax+rax]
    10b: nop     [rax+rax]
    110: test    byte ptr [rbp-21h],0FFh
    114: je      0E0h
    116: jmp     100h
    118: jmp     0F0h
    11a: mov     rdi,rax
    11d: mov     esi,0FFFFFFD0h
    122: call    ryo_h_Lpad
    127: jmp     110h

fn std::ptr::NonNull::<T>::new_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: cmp     rax,0
     17: sete    [rbp-11h]
     1b: test    byte ptr [rbp-11h],0FFh
     1f: je      0F9h
     25: mov     edi,0FFFFFFF0h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: mov     qword ptr [rbp-8],0D2h
     3e: mov     rax,[rbp-10h]
     42: mov     [rbp-48h],rax
     46: mov     rax,[rbp-8]
     4a: mov     [rbp-40h],rax
     4e: mov     rax,[rbp-48h]
     52: mov     [rbp-38h],rax
     56: mov     [rbp-30h],rax
     5a: mov     edi,0FFFFFFA0h
     5f: lea     rsi,[k1]
     66: call    ryo_h_AddrAbs
     6b: mov     qword ptr [rbp-58h],0D2h
     73: mov     rax,[rbp-58h]
     77: mov     [rbp-50h],rax
     7b: shl     rax,1
     7f: mov     [rbp-48h],rax
     83: or      rax,1
     87: mov     [rbp-40h],rax
     8b: mov     [rbp-38h],rax
     8f: mov     rax,[rbp-30h]
     93: mov     [rbp-28h],rax
     97: mov     rax,[rbp-38h]
     9b: mov     [rbp-20h],rax
     9f: mov     edi,0FFFFFF70h
     a4: mov     esi,0FFFFFFD8h
     a9: call    ryo_h_MovW128
     ae: mov     byte ptr [rbp-80h],0
     b2: mov     rax,[rbp+18h]
     b6: mov     [rbp-78h],rax
     ba: lea     rdi,[sym2]
     c1: lea     rsi,[site3]
     c8: mov     edx,0FFFFFF98h
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

fn std::ptr::copy_nonoverlapping::<u8>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     byte ptr [rbp-11h],1
      c: test    byte ptr [rbp-11h],0FFh
     10: je      67h
     12: mov     rax,[rbp+10h]
     16: mov     [rbp-8],rax
     1a: mov     rax,[rbp+18h]
     1e: mov     [rbp-10h],rax
     22: mov     rax,[rbp-8]
     26: mov     [rbp-50h],rax
     2a: mov     rax,[rbp-10h]
     2e: mov     [rbp-48h],rax
     32: mov     qword ptr [rbp-40h],1
     3a: mov     qword ptr [rbp-38h],1
     42: mov     rax,[rbp+20h]
     46: mov     [rbp-30h],rax
     4a: mov     edi,0FFFFFFD8h
     4f: lea     rsi,[k0]
     56: call    ryo_h_AddrAbs
     5b: call    fn1
     60: nop     [rcx]
     67: imul    rax,[rbp+20h],1
     6c: mov     [rbp-18h],rax
     70: mov     edi,18h
     75: mov     esi,10h
     7a: mov     edx,0FFFFFFE8h
     7f: call    ryo_h_Memcpy
     84: xor     edi,edi
     86: xor     esi,esi
     88: call    ryo_h_Ret
     8d: leave
     8e: ret

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

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-20h],rax
     14: lea     rdi,[sym0]
     1b: lea     rsi,[site1]
     22: mov     edx,0FFFFFFF0h
     27: call    ryo_h_CallExt
     2c: test    rax,rax
     2f: je      3Ch
     31: call    rax
     33: nop     [rcx-8]
     3a: jmp     4Ch
     3c: mov     rdi,rbp
     3f: lea     rsi,[ro+4]
     46: call    qword ptr [sym2]
     4c: xor     edi,edi
     4e: xor     esi,esi
     50: call    ryo_h_Ret
     55: leave
     56: ret

fn std::ptr::drop_glue::<core::io::error::CustomOwner> - shim(Some(core::io::error::CustomOwner))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-20h],rax
     14: lea     rdi,[sym0]
     1b: lea     rsi,[site1]
     22: mov     edx,0FFFFFFF0h
     27: call    ryo_h_CallExt
     2c: test    rax,rax
     2f: je      3Ch
     31: call    rax
     33: nop     [rcx-8]
     3a: jmp     4Ch
     3c: mov     rdi,rbp
     3f: lea     rsi,[ro+4]
     46: call    qword ptr [sym2]
     4c: xor     edi,edi
     4e: xor     esi,esi
     50: call    ryo_h_Ret
     55: leave
     56: ret

fn std::ptr::drop_glue::<core::io::error::ErrorData<core::io::error::CustomOwner>> - shim(Some(core::io::error::ErrorData<core::io::error::CustomOwner>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: movzx   eax,byte ptr [rax]
      f: mov     [rbp-11h],al
     12: mov     edi,0FFFFFFF8h
     17: mov     esi,0FFFFFFEFh
     1c: call    ryo_h_ZextW8W64
     21: mov     edi,0FFFFFFF8h
     26: xor     esi,esi
     28: mov     edx,3
     2d: call    ryo_h_SwitchDenseW64
     32: lea     rcx,[44h]
     39: movsxd  rax,[rcx+rax*4]
     3d: add     rax,rcx
     40: jmp     rax
     42: int3
     43: int3
     44: .long   60h
     48: .long   60h
     4c: .long   60h
     50: .long   6bh
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: xor     edi,edi
     62: xor     esi,esi
     64: call    ryo_h_Ret
     69: leave
     6a: ret
     6b: mov     rax,[rbp+10h]
     6f: lea     rax,[rax+8]
     73: mov     [rbp-18h],rax
     77: mov     [rbp-20h],rax
     7b: call    fn0
     80: nop     [rcx-18h]
     87: jmp     60h

fn std::ptr::drop_glue::<core::io::error::repr::Repr> - shim(Some(core::io::error::repr::Repr))
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

fn std::ptr::drop_glue::<core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>> - shim(Some(core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(std::string::String, usize)>> - shim(Some(hashbrown::raw::RawTable<(std::string::String, usize)>))
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

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(u64, u64)>> - shim(Some(hashbrown::raw::RawTable<(u64, u64)>))
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

fn std::ptr::drop_glue::<hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>> - shim(Some(hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>))
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

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>))
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

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize>> - shim(Some(std::collections::HashMap<std::string::String, usize>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64>> - shim(Some(std::collections::HashMap<u64, u64>))
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

fn std::ptr::drop_glue::<std::collections::hash_map::VacantEntry<'_, std::string::String, usize>> - shim(Some(std::collections::hash_map::VacantEntry<'_, std::string::String, usize>))
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

fn std::ptr::drop_glue::<std::io::Error> - shim(Some(std::io::Error))
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

fn std::ptr::drop_glue::<std::result::Result<(), std::io::Error>> - shim(Some(std::result::Result<(), std::io::Error>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     edi,0FFFFFFE4h
     18: mov     esi,0FFFFFFE8h
     1d: xor     edx,edx
     1f: xor     ecx,ecx
     21: xor     r8d,r8d
     24: mov     r9d,1
     2a: call    ryo_h_DiscrNicheW64
     2f: mov     edi,0FFFFFFF8h
     34: mov     esi,0FFFFFFE4h
     39: call    ryo_h_ZextW32W64
     3e: cmp     qword ptr [rbp-8],0
     43: jne     5Bh
     45: nop     [rax+rax]
     4e: xchg    ax,ax
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: mov     rax,[rbp+10h]
     5f: mov     [rbp-18h],rax
     63: mov     [rbp-30h],rax
     67: call    fn0
     6c: nop     [rcx-18h]
     73: jmp     50h

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
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

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     [rbp-20h],rax
     14: lea     rdi,[sym0]
     1b: lea     rsi,[site1]
     22: mov     edx,0FFFFFFE8h
     27: call    ryo_h_CallExt
     2c: test    rax,rax
     2f: je      3Ch
     31: call    rax
     33: nop     [rcx-8]
     3a: jmp     4Ch
     3c: mov     rdi,rbp
     3f: lea     rsi,[ro+4]
     46: call    qword ptr [sym2]
     4c: jmp     8Ah
     4e: xchg    ax,ax
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret
     5b: nop     [rax+rax]
     60: mov     edi,0FFFFFFF0h
     65: call    ryo_h_Resume
     6a: ud2
     6c: nop     [rax]
     70: mov     rax,[rbp+10h]
     74: mov     [rbp-18h],rax
     78: mov     [rbp-20h],rax
     7c: call    fn3
     81: nop     [rcx-18h]
     88: jmp     60h
     8a: mov     rax,[rbp+10h]
     8e: mov     [rbp-18h],rax
     92: mov     [rbp-20h],rax
     96: call    fn4
     9b: nop     [rcx-18h]
     a2: jmp     50h
     a4: nop     [rax+rax]
     ad: nop     [rax]
     b0: lea     rdi,[sym5]
     b7: lea     rsi,[site6]
     be: mov     edx,0FFFFFFE8h
     c3: call    ryo_h_CallExt
     c8: test    rax,rax
     cb: je      0D8h
     cd: call    rax
     cf: nop     [rcx-10h]
     d6: jmp     0E8h
     d8: mov     rdi,rbp
     db: lea     rsi,[ro+20]
     e2: call    qword ptr [sym7]
     e8: call    ryo_h_Unreachable
     ed: ud2
     ef: mov     rdi,rax
     f2: mov     esi,0FFFFFFF0h
     f7: call    ryo_h_Lpad
     fc: jmp     70h
    101: mov     rdi,rax
    104: mov     esi,0FFFFFFF0h
    109: call    ryo_h_Lpad
    10e: jmp     0B0h

fn std::ptr::replace::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-90h],rax
     16: mov     rax,[rbp+18h]
     1a: mov     [rbp-88h],rax
     21: call    fn0
     26: nop     [rcx-1Ah]
     2d: jmp     173h
     32: nop     [rax+rax]
     3b: nop     [rax+rax]
     40: xor     edi,edi
     42: xor     esi,esi
     44: call    ryo_h_Ret
     49: leave
     4a: ret
     4b: nop     [rax+rax]
     50: mov     edi,0FFFFFFF0h
     55: lea     rsi,[k1]
     5c: call    ryo_h_AddrAbs
     61: mov     qword ptr [rbp-8],0DDh
     69: mov     rax,[rbp-10h]
     6d: mov     [rbp-50h],rax
     71: mov     rax,[rbp-8]
     75: mov     [rbp-48h],rax
     79: mov     rax,[rbp-50h]
     7d: mov     [rbp-40h],rax
     81: mov     [rbp-38h],rax
     85: mov     edi,0FFFFFF98h
     8a: lea     rsi,[k2]
     91: call    ryo_h_AddrAbs
     96: mov     qword ptr [rbp-60h],0DDh
     9e: mov     rax,[rbp-60h]
     a2: mov     [rbp-58h],rax
     a6: shl     rax,1
     aa: mov     [rbp-50h],rax
     ae: or      rax,1
     b2: mov     [rbp-48h],rax
     b6: mov     [rbp-40h],rax
     ba: mov     rax,[rbp-38h]
     be: mov     [rbp-30h],rax
     c2: mov     rax,[rbp-40h]
     c6: mov     [rbp-28h],rax
     ca: mov     edi,0FFFFFF70h
     cf: mov     esi,0FFFFFFD0h
     d4: call    ryo_h_MovW128
     d9: mov     byte ptr [rbp-80h],0
     dd: mov     rax,[rbp+28h]
     e1: mov     [rbp-78h],rax
     e5: lea     rdi,[sym3]
     ec: lea     rsi,[site4]
     f3: mov     edx,0FFFFFF90h
     f8: call    ryo_h_CallExt
     fd: test    rax,rax
    100: je      10Dh
    102: call    rax
    104: nop     [rcx-10h]
    10b: jmp     11Dh
    10d: mov     rdi,rbp
    110: lea     rsi,[ro+4]
    117: call    qword ptr [sym5]
    11d: call    ryo_h_Unreachable
    122: ud2
    124: nop     [rax+rax]
    12d: nop     [rax]
    130: test    byte ptr [rbp+20h],0FFh
    134: je      14Ah
    136: jmp     145h
    138: nop     [rax+rax]
    140: jmp     50h
    145: jmp     40h
    14a: mov     rax,[rbp+10h]
    14e: mov     [rbp-28h],rax
    152: cmp     rax,0
    156: sete    [rbp-1Bh]
    15a: movzx   eax,byte ptr [rbp-1Bh]
    15e: xor     al,1
    161: mov     [rbp-19h],al
    164: test    byte ptr [rbp-19h],0FFh
    168: je      50h
    16e: jmp     40h
    173: test    byte ptr [rbp-1Ah],0FFh
    177: je      140h
    179: jmp     130h
    17b: nop     [rax+rax]
    180: lea     rdi,[sym6]
    187: lea     rsi,[site7]
    18e: mov     edx,0FFFFFF90h
    193: call    ryo_h_CallExt
    198: test    rax,rax
    19b: je      1A8h
    19d: call    rax
    19f: nop     [rcx-68h]
    1a6: jmp     1B8h
    1a8: mov     rdi,rbp
    1ab: lea     rsi,[ro+20]
    1b2: call    qword ptr [sym8]
    1b8: call    ryo_h_Unreachable
    1bd: ud2
    1bf: mov     rdi,rax
    1c2: mov     esi,0FFFFFFE8h
    1c7: call    ryo_h_Lpad
    1cc: jmp     180h

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

fn std::ptr::swap_nonoverlapping::<hashbrown::raw::RawTableInner>
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
     35: mov     qword ptr [rbp-70h],20h
     3d: mov     qword ptr [rbp-68h],8
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
     80: imul    rax,[rbp-20h],20h
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

fn std::str::<impl std::borrow::ToOwned for str>::to_owned
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     edi,0FFFFFFC0h
      d: mov     esi,10h
     12: call    ryo_h_MovW128
     17: mov     edi,0FFFFFFB0h
     1c: mov     esi,0FFFFFFC0h
     21: call    ryo_h_MovW128
     26: call    fn0
     2b: nop     [rcx-30h]
     32: mov     edi,0FFFFFFE8h
     37: mov     esi,0FFFFFFD0h
     3c: mov     edx,18h
     41: call    ryo_h_Copy
     46: mov     edi,0FFFFFFE8h
     4b: mov     esi,18h
     50: call    ryo_h_Ret
     55: leave
     56: ret

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

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::try_with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     byte ptr [rbp-21h],1
      c: mov     rax,[rbp+10h]
     10: mov     rax,[rax]
     13: mov     [rbp-58h],rax
     17: mov     qword ptr [rbp-70h],0
     1f: mov     edi,0FFFFFFA8h
     24: lea     rsi,[site0]
     2b: call    ryo_h_CallInd
     30: test    rax,rax
     33: je      40h
     35: call    rax
     37: nop     [rcx-50h]
     3e: jmp     50h
     40: mov     rdi,rbp
     43: lea     rsi,[ro+4]
     4a: call    qword ptr [sym1]
     50: mov     rax,[rbp-50h]
     54: mov     [rbp-60h],rax
     58: cmp     rax,0
     5c: sete    [rbp-51h]
     60: test    byte ptr [rbp-51h],0FFh
     64: je      103h
     6a: jmp     0D8h
     6c: nop     [rax]
     70: mov     edi,0FFFFFFF0h
     75: mov     esi,0FFFFFFC0h
     7a: call    ryo_h_MovW128
     7f: mov     qword ptr [rbp-18h],0
     87: nop     [rax+rax]
     90: mov     edi,0FFFFFFE8h
     95: mov     esi,18h
     9a: call    ryo_h_Ret
     9f: leave
     a0: ret
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: mov     edi,0FFFFFFD0h
     b5: call    ryo_h_Resume
     ba: ud2
     bc: nop     [rax]
     c0: jmp     0B0h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: test    byte ptr [rbp-21h],0FFh
     d4: je      0B0h
     d6: jmp     0C0h
     d8: mov     qword ptr [rbp-48h],0
     e0: mov     qword ptr [rbp-40h],0
     e8: mov     qword ptr [rbp-40h],1
     f0: cmp     qword ptr [rbp-40h],1
     f5: sete    [rbp-41h]
     f9: mov     qword ptr [rbp-18h],1
    101: jmp     90h
    103: mov     rax,[rbp-50h]
    107: mov     [rbp-60h],rax
    10b: mov     [rbp-48h],rax
    10f: mov     [rbp-50h],rax
    113: mov     [rbp-40h],rax
    117: mov     [rbp-48h],rax
    11b: mov     [rbp-38h],rax
    11f: mov     [rbp-20h],rax
    123: mov     byte ptr [rbp-21h],0
    127: mov     [rbp-48h],rax
    12b: mov     [rbp-70h],rax
    12f: call    fn2
    134: nop     [rcx-40h]
    13b: jmp     70h
    140: mov     rdi,rax
    143: mov     esi,0FFFFFFD0h
    148: call    ryo_h_Lpad
    14d: jmp     0D0h

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-40h],rax
     10: call    fn0
     15: nop     [rcx-30h]
     1c: mov     rax,[rbp-30h]
     20: mov     [rbp-18h],rax
     24: mov     edi,0FFFFFFE8h
     29: xor     esi,esi
     2b: mov     edx,2
     30: call    ryo_h_SwitchDenseW64
     35: lea     rcx,[48h]
     3c: movsxd  rax,[rcx+rax*4]
     40: add     rax,rcx
     43: jmp     rax
     45: int3
     46: int3
     47: int3
     48: .long   abh
     4c: .long   5bh
     50: .long   54h
     54: call    ryo_h_Unreachable
     59: ud2
     5b: mov     edi,0FFFFFFC0h
     60: lea     rsi,[k1]
     67: call    ryo_h_AddrAbs
     6c: lea     rdi,[sym2]
     73: lea     rsi,[site3]
     7a: mov     edx,0FFFFFFC8h
     7f: call    ryo_h_CallExt
     84: test    rax,rax
     87: je      94h
     89: call    rax
     8b: nop     [rcx-18h]
     92: jmp     0A4h
     94: mov     rdi,rbp
     97: lea     rsi,[ro+4]
     9e: call    qword ptr [sym4]
     a4: call    ryo_h_Unreachable
     a9: ud2
     ab: mov     edi,0FFFFFFF0h
     b0: mov     esi,0FFFFFFD8h
     b5: call    ryo_h_MovW128
     ba: mov     edi,0FFFFFFF0h
     bf: mov     esi,10h
     c4: call    ryo_h_Ret
     c9: leave
     ca: ret

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+10h]
     10: mov     [rbp-50h],rax
     14: mov     [rbp-48h],rax
     18: movzx   eax,byte ptr [rax]
     1b: mov     [rbp-39h],al
     1e: mov     edi,0FFFFFFE8h
     23: mov     esi,0FFFFFFC7h
     28: call    ryo_h_ZextW8W64
     2d: cmp     qword ptr [rbp-18h],1
     32: jne     4Ah
     34: mov     rax,[rbp+10h]
     38: mov     [rbp-30h],rax
     3c: mov     [rbp-48h],rax
     40: mov     rax,[rbp-30h]
     44: mov     [rbp-8],rax
     48: jmp     6Ah
     4a: mov     byte ptr [rbp-21h],0
     4e: mov     rax,[rbp+10h]
     52: mov     [rbp-60h],rax
     56: mov     rax,[rbp+18h]
     5a: mov     [rbp-58h],rax
     5e: call    fn0
     63: nop     [rcx-8]
     6a: mov     edi,0FFFFFFF8h
     6f: mov     esi,8
     74: call    ryo_h_Ret
     79: leave
     7a: ret
     7b: nop     [rax+rax]
     80: mov     edi,0FFFFFFC8h
     85: call    ryo_h_Resume
     8a: ud2
     8c: nop     [rax]
     90: jmp     80h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-21h],0FFh
     a4: je      80h
     a6: jmp     90h
     a8: mov     rdi,rax
     ab: mov     esi,0FFFFFFC8h
     b0: call    ryo_h_Lpad
     b5: jmp     0A0h

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init_slow::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,120h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+10h]
     13: mov     [rbp-88h],rax
     1a: mov     [rbp-80h],rax
     1e: movzx   eax,byte ptr [rax]
     21: mov     [rbp-71h],al
     24: mov     edi,0FFFFFFE8h
     29: mov     esi,0FFFFFF8Fh
     2e: call    ryo_h_ZextW8W64
     33: mov     edi,0FFFFFFE8h
     38: xor     esi,esi
     3a: mov     edx,3
     3f: call    ryo_h_SwitchDenseW64
     44: lea     rcx,[54h]
     4b: movsxd  rax,[rcx+rax*4]
     4f: add     rax,rcx
     52: jmp     rax
     54: .long   9dh
     58: .long   84h
     5c: .long   77h
     60: .long   70h
     64: nop     [rax+rax]
     6d: nop     [rax]
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     qword ptr [rbp-8],0
     7f: jmp     2B9h
     84: mov     rax,[rbp+10h]
     88: mov     [rbp-60h],rax
     8c: mov     [rbp-80h],rax
     90: mov     rax,[rbp-60h]
     94: mov     [rbp-8],rax
     98: jmp     2B9h
     9d: mov     edi,0FFFFFF0Ch
     a2: mov     esi,18h
     a7: xor     edx,edx
     a9: xor     ecx,ecx
     ab: xor     r8d,r8d
     ae: mov     r9d,1
     b4: call    ryo_h_DiscrNicheW64
     b9: mov     edi,0FFFFFF70h
     be: mov     esi,0FFFFFF0Ch
     c3: call    ryo_h_ZextW32W64
     c8: mov     edi,0FFFFFF70h
     cd: xor     esi,esi
     cf: mov     edx,2
     d4: call    ryo_h_SwitchDenseW64
     d9: lea     rcx,[0ECh]
     e0: movsxd  rax,[rcx+rax*4]
     e4: add     rax,rcx
     e7: jmp     rax
     e9: int3
     ea: int3
     eb: int3
     ec: .long   2cah
     f0: .long   2dah
     f4: .long   70h
     f8: lea     rax,[rbp-50h]
     fc: mov     [rbp-98h],rax
    103: mov     edi,0FFFFFF48h
    108: lea     rsi,[k0]
    10f: call    ryo_h_AddrAbs
    114: mov     qword ptr [rbp-0B0h],2Bh
    11f: mov     rax,[rbp-0B8h]
    126: mov     [rbp-0D8h],rax
    12d: mov     rax,[rbp-0B0h]
    134: mov     [rbp-0D0h],rax
    13b: mov     rax,[rbp-0D8h]
    142: mov     [rbp-0C8h],rax
    149: mov     [rbp-0C0h],rax
    150: mov     edi,0FFFFFF10h
    155: lea     rsi,[k1]
    15c: call    ryo_h_AddrAbs
    161: mov     qword ptr [rbp-0E8h],2Bh
    16c: mov     rax,[rbp-0E8h]
    173: mov     [rbp-0E0h],rax
    17a: shl     rax,1
    17e: mov     [rbp-0D8h],rax
    185: or      rax,1
    189: mov     [rbp-0D0h],rax
    190: mov     [rbp-0C8h],rax
    197: mov     rax,[rbp-0C0h]
    19e: mov     [rbp-0A8h],rax
    1a5: mov     rax,[rbp-0C8h]
    1ac: mov     [rbp-0A0h],rax
    1b3: mov     rax,[rbp-98h]
    1ba: mov     [rbp-120h],rax
    1c1: mov     edi,0FFFFFEE8h
    1c6: mov     esi,0FFFFFF58h
    1cb: call    ryo_h_MovW128
    1d0: call    fn2
    1d5: nop     [rcx-90h]
    1dc: jmp     23Dh
    1de: lea     rax,[rbp-80h]
    1e2: mov     [rbp-98h],rax
    1e9: mov     [rbp-90h],rax
    1f0: mov     [rbp-98h],rax
    1f7: mov     [rbp-120h],rax
    1fe: mov     edi,0FFFFFF08h
    203: lea     rsi,[sym3]
    20a: call    ryo_h_AddrSym
    20f: mov     rdi,rbp
    212: lea     rsi,[ro+4]
    219: call    qword ptr [sym4]
    21f: jmp     4E4h
    224: mov     rax,[rbp+10h]
    228: mov     [rbp-120h],rax
    22f: call    fn5
    234: nop     [rcx-38h]
    23b: jmp     2A0h
    23d: lea     rax,[rbp-90h]
    244: mov     [rbp-0F8h],rax
    24b: mov     [rbp-120h],rax
    252: call    fn6
    257: nop     [rcx-0F8h]
    25e: lea     rdi,[sym7]
    265: lea     rsi,[site8]
    26c: mov     edx,0FFFFFF08h
    271: call    ryo_h_CallExt
    276: test    rax,rax
    279: je      286h
    27b: call    rax
    27d: nop     [rcx-50h]
    284: jmp     296h
    286: mov     rdi,rbp
    289: lea     rsi,[ro+20]
    290: call    qword ptr [sym9]
    296: call    ryo_h_Unreachable
    29b: ud2
    29d: nop     [rax]
    2a0: mov     rax,[rbp+10h]
    2a4: mov     [rbp-70h],rax
    2a8: mov     [rbp-88h],rax
    2af: mov     rax,[rbp-70h]
    2b3: mov     [rbp-8],rax
    2b7: jmp     2B9h
    2b9: mov     edi,0FFFFFFF8h
    2be: mov     esi,8
    2c3: call    ryo_h_Ret
    2c8: leave
    2c9: ret
    2ca: mov     qword ptr [rbp-88h],0
    2d5: jmp     3B5h
    2da: mov     rax,[rbp+18h]
    2de: mov     [rbp-98h],rax
    2e5: mov     qword ptr [rbp-0B0h],0
    2f0: mov     edi,0FFFFFF78h
    2f5: mov     esi,0FFFFFF68h
    2fa: xor     edx,edx
    2fc: mov     ecx,18h
    301: call    ryo_h_LoadCopy
    306: mov     edi,0FFFFFF68h
    30b: xor     esi,esi
    30d: mov     edx,0FFFFFF50h
    312: mov     ecx,18h
    317: call    ryo_h_StoreCopy
    31c: mov     rax,[rbp-88h]
    323: mov     [rbp-90h],rax
    32a: mov     edi,0FFFFFF70h
    32f: xor     esi,esi
    331: mov     edx,2
    336: call    ryo_h_SwitchDenseW64
    33b: lea     rcx,[34Ch]
    342: movsxd  rax,[rcx+rax*4]
    346: add     rax,rcx
    349: jmp     rax
    34b: int3
    34c: .long   3b5h
    350: .long   3c3h
    354: .long   70h
    358: nop     [rax+rax]
    360: mov     rax,[rbp+10h]
    364: mov     [rbp-68h],rax
    368: mov     [rbp-88h],rax
    36f: mov     edi,0FFFFFF48h
    374: mov     esi,0FFFFFFD0h
    379: call    ryo_h_MovW128
    37e: mov     edi,0FFFFFF58h
    383: mov     esi,0FFFFFF48h
    388: call    ryo_h_MovW128
    38d: mov     edi,0FFFFFF68h
    392: mov     esi,0FFFFFF58h
    397: call    ryo_h_MovW128
    39c: mov     byte ptr [rbp-0F1h],1
    3a3: test    byte ptr [rbp-0F1h],0FFh
    3aa: je      499h
    3b0: jmp     458h
    3b5: call    fn10
    3ba: nop     [rcx-30h]
    3c1: jmp     3D4h
    3c3: mov     edi,0FFFFFFD0h
    3c8: mov     esi,0FFFFFF80h
    3cd: call    ryo_h_MovW128
    3d2: jmp     360h
    3d4: jmp     360h
    3d6: nop     [rax+rax]
    3df: nop
    3e0: mov     byte ptr [rbp-82h],1
    3e7: mov     rax,[rbp+10h]
    3eb: lea     rax,[rax+10h]
    3ef: mov     [rbp-98h],rax
    3f6: mov     [rbp-90h],rax
    3fd: movzx   eax,byte ptr [rax]
    400: mov     [rbp-81h],al
    406: mov     rax,[rbp-90h]
    40d: movzx   ecx,byte ptr [rbp-82h]
    414: mov     [rax],cl
    416: mov     edi,0FFFFFFB8h
    41b: mov     esi,0FFFFFF7Fh
    420: call    ryo_h_ZextW8W64
    425: mov     edi,0FFFFFFB8h
    42a: xor     esi,esi
    42c: mov     edx,3
    431: call    ryo_h_SwitchDenseW64
    436: lea     rcx,[448h]
    43d: movsxd  rax,[rcx+rax*4]
    441: add     rax,rcx
    444: jmp     rax
    446: int3
    447: int3
    448: .long   224h
    44c: .long   1deh
    450: .long   f8h
    454: .long   70h
    458: mov     rax,[rbp-68h]
    45c: mov     [rbp-0A0h],rax
    463: mov     [rbp-120h],rax
    46a: mov     qword ptr [rbp-118h],8
    475: mov     byte ptr [rbp-110h],0
    47c: mov     edi,0FFFFFEF8h
    481: lea     rsi,[k11]
    488: call    ryo_h_AddrAbs
    48d: call    fn12
    492: nop     [rcx-68h]
    499: mov     byte ptr [rbp-0F1h],0
    4a0: test    byte ptr [rbp-0F1h],0FFh
    4a7: je      4BDh
    4a9: mov     edi,0FFFFFF80h
    4ae: mov     esi,0FFFFFF68h
    4b3: call    ryo_h_MovW128
    4b8: jmp     3E0h
    4bd: mov     edi,0FFFFFF80h
    4c2: mov     esi,0FFFFFF78h
    4c7: xor     edx,edx
    4c9: call    ryo_h_LoadW128
    4ce: mov     edi,0FFFFFF78h
    4d3: xor     esi,esi
    4d5: mov     edx,0FFFFFF68h
    4da: call    ryo_h_StoreW128
    4df: jmp     3E0h
    4e4: jmp     2A0h

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

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
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

