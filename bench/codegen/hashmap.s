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
     10: mov     rax,[rbp-28h]
     14: mov     [rbp-60h],rax
     18: call    fn0
     1d: nop     [rcx-20h]
     24: mov     edi,0FFFFFFCCh
     29: mov     esi,0FFFFFFE0h
     2e: xor     edx,edx
     30: xor     ecx,ecx
     32: xor     r8d,r8d
     35: mov     r9d,1
     3b: call    ryo_h_DiscrNicheW64
     40: mov     edi,0FFFFFFF0h
     45: mov     esi,0FFFFFFCCh
     4a: call    ryo_h_ZextW32W64
     4f: mov     edi,0FFFFFFF0h
     54: xor     esi,esi
     56: mov     edx,2
     5b: call    ryo_h_SwitchDenseW64
     60: lea     rcx,[70h]
     67: movsxd  rax,[rcx+rax*4]
     6b: add     rax,rcx
     6e: jmp     rax
     70: .long   b0h
     74: .long   7ch
     78: .long   130h
     7c: mov     edi,0FFFFFFD0h
     81: mov     esi,0FFFFFFE0h
     86: call    ryo_h_MovW128
     8b: mov     rax,[rbp+10h]
     8f: mov     [rbp-60h],rax
     93: mov     edi,0FFFFFFA8h
     98: mov     esi,0FFFFFFD0h
     9d: call    ryo_h_MovW128
     a2: call    fn1
     a7: nop     [rcx-1]
     ae: jmp     11Fh
     b0: mov     rax,[rbp+10h]
     b4: mov     [rbp-20h],rax
     b8: mov     edi,0FFFFFFE8h
     bd: lea     rsi,[k2]
     c4: call    ryo_h_AddrAbs
     c9: mov     edi,0FFFFFFA0h
     ce: mov     esi,0FFFFFFE0h
     d3: call    ryo_h_MovW128
     d8: mov     edi,0FFFFFFB0h
     dd: mov     esi,18h
     e2: call    ryo_h_MovW128
     e7: lea     rdi,[sym3]
     ee: lea     rsi,[site4]
     f5: mov     edx,0FFFFFFC8h
     fa: call    ryo_h_CallExt
     ff: test    rax,rax
    102: je      10Fh
    104: call    rax
    106: nop     [rcx-1]
    10d: jmp     11Fh
    10f: mov     rdi,rbp
    112: lea     rsi,[ro+4]
    119: call    qword ptr [sym5]
    11f: mov     edi,0FFFFFFFFh
    124: mov     esi,1
    129: call    ryo_h_Ret
    12e: leave
    12f: ret
    130: call    ryo_h_Unreachable
    135: ud2

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
     2a: mov     rax,[rbp-50h]
     2e: mov     [rbp-48h],rax
     32: mov     rax,[rbp-48h]
     36: and     rax,0FFh
     3d: mov     [rbp-40h],rax
     41: mov     rax,[rbp-40h]
     45: shl     rax,38h
     49: mov     [rbp-38h],rax
     4d: mov     rax,[rbp+10h]
     51: mov     rax,[rax+38h]
     55: mov     [rbp-40h],rax
     59: mov     rax,[rbp-38h]
     5d: or      rax,[rbp-40h]
     61: mov     [rbp-30h],rax
     65: mov     rax,[rbp-10h]
     69: xor     rax,[rbp-30h]
     6d: mov     [rbp-10h],rax
     71: lea     rax,[rbp-28h]
     75: mov     [rbp-38h],rax
     79: mov     rax,[rbp-38h]
     7d: mov     [rbp-60h],rax
     81: call    fn0
     86: nop     [rcx-8]
     8d: mov     rax,[rbp-28h]
     91: xor     rax,[rbp-30h]
     95: mov     [rbp-28h],rax
     99: mov     rax,[rbp-20h]
     9d: xor     rax,0FFh
     a4: mov     [rbp-20h],rax
     a8: lea     rax,[rbp-28h]
     ac: mov     [rbp-38h],rax
     b0: mov     rax,[rbp-38h]
     b4: mov     [rbp-60h],rax
     b8: call    fn1
     bd: nop     [rcx-8]
     c4: mov     rax,[rbp-28h]
     c8: mov     [rbp-48h],rax
     cc: mov     rax,[rbp-18h]
     d0: mov     [rbp-50h],rax
     d4: mov     rax,[rbp-48h]
     d8: xor     rax,[rbp-50h]
     dc: mov     [rbp-40h],rax
     e0: mov     rax,[rbp-20h]
     e4: mov     [rbp-48h],rax
     e8: mov     rax,[rbp-40h]
     ec: xor     rax,[rbp-48h]
     f0: mov     [rbp-38h],rax
     f4: mov     rax,[rbp-10h]
     f8: mov     [rbp-40h],rax
     fc: mov     rax,[rbp-38h]
    100: xor     rax,[rbp-40h]
    104: mov     [rbp-8],rax
    108: mov     edi,0FFFFFFF8h
    10d: mov     esi,8
    112: call    ryo_h_Ret
    117: leave
    118: ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax+30h]
     1b: mov     [rbp-68h],rax
     1f: mov     rax,[rbp-68h]
     23: add     rax,[rbp-18h]
     27: mov     [rbp-70h],rax
     2b: mov     rax,[rbp+10h]
     2f: mov     rcx,[rbp-70h]
     33: mov     [rax+30h],rcx
     37: mov     qword ptr [rbp-8],0
     3f: mov     rax,[rbp+10h]
     43: mov     rax,[rax+40h]
     47: mov     [rbp-20h],rax
     4b: cmp     qword ptr [rbp-20h],0
     50: je      1D7h
     56: mov     rax,[rbp+10h]
     5a: mov     rax,[rax+40h]
     5e: mov     [rbp-20h],rax
     62: mov     qword ptr [rbp-68h],8
     6a: mov     rax,[rbp-68h]
     6e: sub     rax,[rbp-20h]
     72: mov     [rbp-8],rax
     76: mov     rax,[rbp-8]
     7a: mov     [rbp-38h],rax
     7e: mov     rax,[rbp-18h]
     82: mov     [rbp-0A0h],rax
     89: mov     rax,[rbp-38h]
     8d: mov     [rbp-98h],rax
     94: call    fn0
     99: nop     [rcx-30h]
     a0: jmp     307h
     a5: nop     [rax+rax]
     ae: xchg    ax,ax
     b0: mov     rax,[rbp+10h]
     b4: mov     rax,[rax+40h]
     b8: mov     [rbp-38h],rax
     bc: mov     qword ptr [rbp-68h],8
     c4: mov     rax,[rbp-68h]
     c8: imul    rax,[rbp-38h]
     cd: mov     [rbp-30h],rax
     d1: mov     edi,0FFFFFFE0h
     d6: mov     esi,0FFFFFFD8h
     db: mov     edx,0FFFFFFD0h
     e0: call    ryo_h_ShlW64
     e5: mov     rax,[rbp+10h]
     e9: mov     rax,[rax+38h]
     ed: mov     [rbp-68h],rax
     f1: mov     rax,[rbp-68h]
     f5: or      rax,[rbp-20h]
     f9: mov     [rbp-70h],rax
     fd: mov     rax,[rbp+10h]
    101: mov     rcx,[rbp-70h]
    105: mov     [rax+38h],rcx
    109: mov     rax,[rbp-8]
    10d: mov     [rbp-28h],rax
    111: mov     rax,[rbp-18h]
    115: cmp     rax,[rbp-28h]
    119: jae     144h
    11b: mov     rax,[rbp+10h]
    11f: mov     rax,[rax+40h]
    123: mov     [rbp-68h],rax
    127: mov     rax,[rbp-68h]
    12b: add     rax,[rbp-18h]
    12f: mov     [rbp-70h],rax
    133: mov     rax,[rbp+10h]
    137: mov     rcx,[rbp-70h]
    13b: mov     [rax+40h],rcx
    13f: jmp     2FCh
    144: mov     rax,[rbp+10h]
    148: mov     rax,[rax+38h]
    14c: mov     [rbp-28h],rax
    150: mov     rax,[rbp+10h]
    154: mov     rax,[rax+18h]
    158: mov     [rbp-68h],rax
    15c: mov     rax,[rbp-68h]
    160: xor     rax,[rbp-28h]
    164: mov     [rbp-70h],rax
    168: mov     rax,[rbp+10h]
    16c: mov     rcx,[rbp-70h]
    170: mov     [rax+18h],rcx
    174: mov     rax,[rbp+10h]
    178: mov     [rbp-28h],rax
    17c: mov     rax,[rbp-28h]
    180: mov     [rbp-0A0h],rax
    187: call    fn1
    18c: nop     [rcx-8]
    193: mov     rax,[rbp+10h]
    197: mov     rax,[rax+38h]
    19b: mov     [rbp-28h],rax
    19f: mov     rax,[rbp+10h]
    1a3: mov     rax,[rax]
    1a6: mov     [rbp-68h],rax
    1aa: mov     rax,[rbp-68h]
    1ae: xor     rax,[rbp-28h]
    1b2: mov     [rbp-70h],rax
    1b6: mov     rax,[rbp+10h]
    1ba: mov     rcx,[rbp-70h]
    1be: mov     [rax],rcx
    1c1: mov     qword ptr [rbp-70h],0
    1c9: mov     rax,[rbp+10h]
    1cd: mov     rcx,[rbp-70h]
    1d1: mov     [rax+40h],rcx
    1d5: jmp     1D7h
    1d7: mov     rax,[rbp-8]
    1db: mov     [rbp-28h],rax
    1df: mov     rax,[rbp-18h]
    1e3: sub     rax,[rbp-28h]
    1e7: mov     [rbp-20h],rax
    1eb: mov     rax,[rbp-20h]
    1ef: and     rax,7
    1f3: mov     [rbp-28h],rax
    1f7: nop     [rax+rax]
    200: mov     rax,[rbp-8]
    204: mov     [rbp-38h],rax
    208: mov     rax,[rbp-20h]
    20c: sub     rax,[rbp-28h]
    210: mov     [rbp-40h],rax
    214: mov     rax,[rbp-38h]
    218: cmp     rax,[rbp-40h]
    21c: jae     2B3h
    222: mov     qword ptr [rbp-38h],0
    22a: mov     rax,[rbp+18h]
    22e: mov     [rbp-58h],rax
    232: mov     rax,[rbp+20h]
    236: mov     [rbp-50h],rax
    23a: mov     rax,[rbp-58h]
    23e: mov     [rbp-48h],rax
    242: mov     rax,[rbp-8]
    246: mov     [rbp-50h],rax
    24a: mov     rax,[rbp-48h]
    24e: imul    rcx,[rbp-50h],1
    253: add     rax,rcx
    256: mov     [rbp-40h],rax
    25a: lea     rax,[rbp-38h]
    25e: mov     [rbp-50h],rax
    262: mov     rax,[rbp-50h]
    266: mov     [rbp-48h],rax
    26a: mov     byte ptr [rbp-61h],1
    26e: test    byte ptr [rbp-61h],0FFh
    272: je      39Eh
    278: jmp     33Dh
    27d: nop     [rax]
    280: mov     rax,[rbp+10h]
    284: mov     rax,[rax]
    287: mov     [rbp-68h],rax
    28b: mov     rax,[rbp-68h]
    28f: xor     rax,[rbp-10h]
    293: mov     [rbp-70h],rax
    297: mov     rax,[rbp+10h]
    29b: mov     rcx,[rbp-70h]
    29f: mov     [rax],rcx
    2a2: mov     rax,[rbp-8]
    2a6: add     rax,8
    2aa: mov     [rbp-8],rax
    2ae: jmp     200h
    2b3: mov     edi,0FFFFFF60h
    2b8: mov     esi,18h
    2bd: call    ryo_h_MovW128
    2c2: mov     rax,[rbp-8]
    2c6: mov     [rbp-90h],rax
    2cd: mov     rax,[rbp-28h]
    2d1: mov     [rbp-88h],rax
    2d8: call    fn2
    2dd: nop     [rcx-30h]
    2e4: mov     rax,[rbp+10h]
    2e8: mov     rcx,[rbp-30h]
    2ec: mov     [rax+38h],rcx
    2f0: mov     rax,[rbp+10h]
    2f4: mov     rcx,[rbp-28h]
    2f8: mov     [rax+40h],rcx
    2fc: xor     edi,edi
    2fe: xor     esi,esi
    300: call    ryo_h_Ret
    305: leave
    306: ret
    307: mov     edi,0FFFFFF60h
    30c: mov     esi,18h
    311: call    ryo_h_MovW128
    316: mov     qword ptr [rbp-90h],0
    321: mov     rax,[rbp-30h]
    325: mov     [rbp-88h],rax
    32c: call    fn3
    331: nop     [rcx-28h]
    338: jmp     0B0h
    33d: mov     rax,[rbp-40h]
    341: mov     [rbp-58h],rax
    345: mov     rax,[rbp-50h]
    349: mov     [rbp-60h],rax
    34d: mov     rax,[rbp-58h]
    351: mov     [rbp-0A0h],rax
    358: mov     rax,[rbp-60h]
    35c: mov     [rbp-98h],rax
    363: mov     qword ptr [rbp-90h],1
    36e: mov     qword ptr [rbp-88h],1
    379: mov     qword ptr [rbp-80h],8
    381: mov     edi,0FFFFFF88h
    386: lea     rsi,[k4]
    38d: call    ryo_h_AddrAbs
    392: call    fn5
    397: nop     [rcx-10h]
    39e: mov     qword ptr [rbp-68h],8
    3a6: imul    rax,[rbp-68h],1
    3ab: mov     [rbp-70h],rax
    3af: mov     edi,0FFFFFFB8h
    3b4: mov     esi,0FFFFFFC0h
    3b9: mov     edx,0FFFFFF90h
    3be: call    ryo_h_Memcpy
    3c3: mov     rax,[rbp-38h]
    3c7: mov     [rbp-10h],rax
    3cb: mov     rax,[rbp+10h]
    3cf: mov     rax,[rax+18h]
    3d3: mov     [rbp-68h],rax
    3d7: mov     rax,[rbp-68h]
    3db: xor     rax,[rbp-10h]
    3df: mov     [rbp-70h],rax
    3e3: mov     rax,[rbp+10h]
    3e7: mov     rcx,[rbp-70h]
    3eb: mov     [rax+18h],rcx
    3ef: mov     rax,[rbp+10h]
    3f3: mov     [rbp-38h],rax
    3f7: mov     rax,[rbp-38h]
    3fb: mov     [rbp-0A0h],rax
    402: call    fn6
    407: nop     [rcx-10h]
    40e: jmp     280h

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
     46: mov     rax,[rbp-18h]
     4a: mov     [rbp-10h],rax
     4e: mov     qword ptr [rbp-8],1
     56: mov     rax,[rbp+10h]
     5a: mov     [rbp-40h],rax
     5e: mov     edi,0FFFFFFC8h
     63: mov     esi,0FFFFFFF0h
     68: call    ryo_h_MovW128
     6d: call    fn1
     72: nop     [rcx]
     79: xor     edi,edi
     7b: xor     esi,esi
     7d: call    ryo_h_Ret
     82: leave
     83: ret

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
     b0: mov     rax,[rbp-20h]
     b4: xor     rax,[rbp-8]
     b8: mov     [rbp-30h],rax
     bc: mov     rax,[rbp+10h]
     c0: mov     rcx,[rbp-30h]
     c4: mov     [rax+10h],rcx
     c8: mov     rax,[rbp+10h]
     cc: mov     rax,[rax+18h]
     d0: mov     [rbp-10h],rax
     d4: mov     dword ptr [rbp-1Ch],10h
     db: mov     edi,0FFFFFFF8h
     e0: mov     esi,0FFFFFFF0h
     e5: mov     edx,0FFFFFFE4h
     ea: call    ryo_h_RotlW64
     ef: mov     rax,[rbp+10h]
     f3: mov     rcx,[rbp-8]
     f7: mov     [rax+18h],rcx
     fb: mov     rax,[rbp+10h]
     ff: mov     rax,[rax+8]
    103: mov     [rbp-8],rax
    107: mov     rax,[rbp+10h]
    10b: mov     rax,[rax+18h]
    10f: mov     [rbp-20h],rax
    113: mov     rax,[rbp-20h]
    117: xor     rax,[rbp-8]
    11b: mov     [rbp-30h],rax
    11f: mov     rax,[rbp+10h]
    123: mov     rcx,[rbp-30h]
    127: mov     [rax+18h],rcx
    12b: mov     rax,[rbp+10h]
    12f: mov     rax,[rax]
    132: mov     [rbp-10h],rax
    136: mov     dword ptr [rbp-1Ch],20h
    13d: mov     edi,0FFFFFFF8h
    142: mov     esi,0FFFFFFF0h
    147: mov     edx,0FFFFFFE4h
    14c: call    ryo_h_RotlW64
    151: mov     rax,[rbp+10h]
    155: mov     rcx,[rbp-8]
    159: mov     [rax],rcx
    15c: mov     rax,[rbp+10h]
    160: mov     rax,[rax+8]
    164: mov     [rbp-10h],rax
    168: mov     rax,[rbp+10h]
    16c: mov     rax,[rax+10h]
    170: mov     [rbp-18h],rax
    174: mov     rax,[rbp-10h]
    178: add     rax,[rbp-18h]
    17c: mov     [rbp-8],rax
    180: mov     rax,[rbp+10h]
    184: mov     rcx,[rbp-8]
    188: mov     [rax+8],rcx
    18c: mov     rax,[rbp+10h]
    190: mov     rax,[rax]
    193: mov     [rbp-10h],rax
    197: mov     rax,[rbp+10h]
    19b: mov     rax,[rax+18h]
    19f: mov     [rbp-18h],rax
    1a3: mov     rax,[rbp-10h]
    1a7: add     rax,[rbp-18h]
    1ab: mov     [rbp-8],rax
    1af: mov     rax,[rbp+10h]
    1b3: mov     rcx,[rbp-8]
    1b7: mov     [rax],rcx
    1ba: mov     rax,[rbp+10h]
    1be: mov     rax,[rax+10h]
    1c2: mov     [rbp-10h],rax
    1c6: mov     dword ptr [rbp-1Ch],11h
    1cd: mov     edi,0FFFFFFF8h
    1d2: mov     esi,0FFFFFFF0h
    1d7: mov     edx,0FFFFFFE4h
    1dc: call    ryo_h_RotlW64
    1e1: mov     rax,[rbp+10h]
    1e5: mov     rcx,[rbp-8]
    1e9: mov     [rax+10h],rcx
    1ed: mov     rax,[rbp+10h]
    1f1: mov     rax,[rax+8]
    1f5: mov     [rbp-8],rax
    1f9: mov     rax,[rbp+10h]
    1fd: mov     rax,[rax+10h]
    201: mov     [rbp-20h],rax
    205: mov     rax,[rbp-20h]
    209: xor     rax,[rbp-8]
    20d: mov     [rbp-30h],rax
    211: mov     rax,[rbp+10h]
    215: mov     rcx,[rbp-30h]
    219: mov     [rax+10h],rcx
    21d: mov     rax,[rbp+10h]
    221: mov     rax,[rax+18h]
    225: mov     [rbp-10h],rax
    229: mov     dword ptr [rbp-1Ch],15h
    230: mov     edi,0FFFFFFF8h
    235: mov     esi,0FFFFFFF0h
    23a: mov     edx,0FFFFFFE4h
    23f: call    ryo_h_RotlW64
    244: mov     rax,[rbp+10h]
    248: mov     rcx,[rbp-8]
    24c: mov     [rax+18h],rcx
    250: mov     rax,[rbp+10h]
    254: mov     rax,[rax]
    257: mov     [rbp-8],rax
    25b: mov     rax,[rbp+10h]
    25f: mov     rax,[rax+18h]
    263: mov     [rbp-20h],rax
    267: mov     rax,[rbp-20h]
    26b: xor     rax,[rbp-8]
    26f: mov     [rbp-30h],rax
    273: mov     rax,[rbp+10h]
    277: mov     rcx,[rbp-30h]
    27b: mov     [rax+18h],rcx
    27f: mov     rax,[rbp+10h]
    283: mov     rax,[rax+8]
    287: mov     [rbp-10h],rax
    28b: mov     dword ptr [rbp-1Ch],20h
    292: mov     edi,0FFFFFFF8h
    297: mov     esi,0FFFFFFF0h
    29c: mov     edx,0FFFFFFE4h
    2a1: call    ryo_h_RotlW64
    2a6: mov     rax,[rbp+10h]
    2aa: mov     rcx,[rbp-8]
    2ae: mov     [rax+8],rcx
    2b2: xor     edi,edi
    2b4: xor     esi,esi
    2b6: call    ryo_h_Ret
    2bb: leave
    2bc: ret

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
     b0: mov     rax,[rbp-20h]
     b4: xor     rax,[rbp-8]
     b8: mov     [rbp-30h],rax
     bc: mov     rax,[rbp+10h]
     c0: mov     rcx,[rbp-30h]
     c4: mov     [rax+10h],rcx
     c8: mov     rax,[rbp+10h]
     cc: mov     rax,[rax+18h]
     d0: mov     [rbp-10h],rax
     d4: mov     dword ptr [rbp-1Ch],10h
     db: mov     edi,0FFFFFFF8h
     e0: mov     esi,0FFFFFFF0h
     e5: mov     edx,0FFFFFFE4h
     ea: call    ryo_h_RotlW64
     ef: mov     rax,[rbp+10h]
     f3: mov     rcx,[rbp-8]
     f7: mov     [rax+18h],rcx
     fb: mov     rax,[rbp+10h]
     ff: mov     rax,[rax+8]
    103: mov     [rbp-8],rax
    107: mov     rax,[rbp+10h]
    10b: mov     rax,[rax+18h]
    10f: mov     [rbp-20h],rax
    113: mov     rax,[rbp-20h]
    117: xor     rax,[rbp-8]
    11b: mov     [rbp-30h],rax
    11f: mov     rax,[rbp+10h]
    123: mov     rcx,[rbp-30h]
    127: mov     [rax+18h],rcx
    12b: mov     rax,[rbp+10h]
    12f: mov     rax,[rax]
    132: mov     [rbp-10h],rax
    136: mov     dword ptr [rbp-1Ch],20h
    13d: mov     edi,0FFFFFFF8h
    142: mov     esi,0FFFFFFF0h
    147: mov     edx,0FFFFFFE4h
    14c: call    ryo_h_RotlW64
    151: mov     rax,[rbp+10h]
    155: mov     rcx,[rbp-8]
    159: mov     [rax],rcx
    15c: mov     rax,[rbp+10h]
    160: mov     rax,[rax+8]
    164: mov     [rbp-10h],rax
    168: mov     rax,[rbp+10h]
    16c: mov     rax,[rax+10h]
    170: mov     [rbp-18h],rax
    174: mov     rax,[rbp-10h]
    178: add     rax,[rbp-18h]
    17c: mov     [rbp-8],rax
    180: mov     rax,[rbp+10h]
    184: mov     rcx,[rbp-8]
    188: mov     [rax+8],rcx
    18c: mov     rax,[rbp+10h]
    190: mov     rax,[rax]
    193: mov     [rbp-10h],rax
    197: mov     rax,[rbp+10h]
    19b: mov     rax,[rax+18h]
    19f: mov     [rbp-18h],rax
    1a3: mov     rax,[rbp-10h]
    1a7: add     rax,[rbp-18h]
    1ab: mov     [rbp-8],rax
    1af: mov     rax,[rbp+10h]
    1b3: mov     rcx,[rbp-8]
    1b7: mov     [rax],rcx
    1ba: mov     rax,[rbp+10h]
    1be: mov     rax,[rax+10h]
    1c2: mov     [rbp-10h],rax
    1c6: mov     dword ptr [rbp-1Ch],11h
    1cd: mov     edi,0FFFFFFF8h
    1d2: mov     esi,0FFFFFFF0h
    1d7: mov     edx,0FFFFFFE4h
    1dc: call    ryo_h_RotlW64
    1e1: mov     rax,[rbp+10h]
    1e5: mov     rcx,[rbp-8]
    1e9: mov     [rax+10h],rcx
    1ed: mov     rax,[rbp+10h]
    1f1: mov     rax,[rax+8]
    1f5: mov     [rbp-8],rax
    1f9: mov     rax,[rbp+10h]
    1fd: mov     rax,[rax+10h]
    201: mov     [rbp-20h],rax
    205: mov     rax,[rbp-20h]
    209: xor     rax,[rbp-8]
    20d: mov     [rbp-30h],rax
    211: mov     rax,[rbp+10h]
    215: mov     rcx,[rbp-30h]
    219: mov     [rax+10h],rcx
    21d: mov     rax,[rbp+10h]
    221: mov     rax,[rax+18h]
    225: mov     [rbp-10h],rax
    229: mov     dword ptr [rbp-1Ch],15h
    230: mov     edi,0FFFFFFF8h
    235: mov     esi,0FFFFFFF0h
    23a: mov     edx,0FFFFFFE4h
    23f: call    ryo_h_RotlW64
    244: mov     rax,[rbp+10h]
    248: mov     rcx,[rbp-8]
    24c: mov     [rax+18h],rcx
    250: mov     rax,[rbp+10h]
    254: mov     rax,[rax]
    257: mov     [rbp-8],rax
    25b: mov     rax,[rbp+10h]
    25f: mov     rax,[rax+18h]
    263: mov     [rbp-20h],rax
    267: mov     rax,[rbp-20h]
    26b: xor     rax,[rbp-8]
    26f: mov     [rbp-30h],rax
    273: mov     rax,[rbp+10h]
    277: mov     rcx,[rbp-30h]
    27b: mov     [rax+18h],rcx
    27f: mov     rax,[rbp+10h]
    283: mov     rax,[rax+8]
    287: mov     [rbp-10h],rax
    28b: mov     dword ptr [rbp-1Ch],20h
    292: mov     edi,0FFFFFFF8h
    297: mov     esi,0FFFFFFF0h
    29c: mov     edx,0FFFFFFE4h
    2a1: call    ryo_h_RotlW64
    2a6: mov     rax,[rbp+10h]
    2aa: mov     rcx,[rbp-8]
    2ae: mov     [rax+8],rcx
    2b2: mov     rax,[rbp+10h]
    2b6: mov     rax,[rax]
    2b9: mov     [rbp-10h],rax
    2bd: mov     rax,[rbp+10h]
    2c1: mov     rax,[rax+10h]
    2c5: mov     [rbp-18h],rax
    2c9: mov     rax,[rbp-10h]
    2cd: add     rax,[rbp-18h]
    2d1: mov     [rbp-8],rax
    2d5: mov     rax,[rbp+10h]
    2d9: mov     rcx,[rbp-8]
    2dd: mov     [rax],rcx
    2e0: mov     rax,[rbp+10h]
    2e4: mov     rax,[rax+8]
    2e8: mov     [rbp-10h],rax
    2ec: mov     rax,[rbp+10h]
    2f0: mov     rax,[rax+18h]
    2f4: mov     [rbp-18h],rax
    2f8: mov     rax,[rbp-10h]
    2fc: add     rax,[rbp-18h]
    300: mov     [rbp-8],rax
    304: mov     rax,[rbp+10h]
    308: mov     rcx,[rbp-8]
    30c: mov     [rax+8],rcx
    310: mov     rax,[rbp+10h]
    314: mov     rax,[rax+10h]
    318: mov     [rbp-10h],rax
    31c: mov     dword ptr [rbp-1Ch],0Dh
    323: mov     edi,0FFFFFFF8h
    328: mov     esi,0FFFFFFF0h
    32d: mov     edx,0FFFFFFE4h
    332: call    ryo_h_RotlW64
    337: mov     rax,[rbp+10h]
    33b: mov     rcx,[rbp-8]
    33f: mov     [rax+10h],rcx
    343: mov     rax,[rbp+10h]
    347: mov     rax,[rax]
    34a: mov     [rbp-8],rax
    34e: mov     rax,[rbp+10h]
    352: mov     rax,[rax+10h]
    356: mov     [rbp-20h],rax
    35a: mov     rax,[rbp-20h]
    35e: xor     rax,[rbp-8]
    362: mov     [rbp-30h],rax
    366: mov     rax,[rbp+10h]
    36a: mov     rcx,[rbp-30h]
    36e: mov     [rax+10h],rcx
    372: mov     rax,[rbp+10h]
    376: mov     rax,[rax+18h]
    37a: mov     [rbp-10h],rax
    37e: mov     dword ptr [rbp-1Ch],10h
    385: mov     edi,0FFFFFFF8h
    38a: mov     esi,0FFFFFFF0h
    38f: mov     edx,0FFFFFFE4h
    394: call    ryo_h_RotlW64
    399: mov     rax,[rbp+10h]
    39d: mov     rcx,[rbp-8]
    3a1: mov     [rax+18h],rcx
    3a5: mov     rax,[rbp+10h]
    3a9: mov     rax,[rax+8]
    3ad: mov     [rbp-8],rax
    3b1: mov     rax,[rbp+10h]
    3b5: mov     rax,[rax+18h]
    3b9: mov     [rbp-20h],rax
    3bd: mov     rax,[rbp-20h]
    3c1: xor     rax,[rbp-8]
    3c5: mov     [rbp-30h],rax
    3c9: mov     rax,[rbp+10h]
    3cd: mov     rcx,[rbp-30h]
    3d1: mov     [rax+18h],rcx
    3d5: mov     rax,[rbp+10h]
    3d9: mov     rax,[rax]
    3dc: mov     [rbp-10h],rax
    3e0: mov     dword ptr [rbp-1Ch],20h
    3e7: mov     edi,0FFFFFFF8h
    3ec: mov     esi,0FFFFFFF0h
    3f1: mov     edx,0FFFFFFE4h
    3f6: call    ryo_h_RotlW64
    3fb: mov     rax,[rbp+10h]
    3ff: mov     rcx,[rbp-8]
    403: mov     [rax],rcx
    406: mov     rax,[rbp+10h]
    40a: mov     rax,[rax+8]
    40e: mov     [rbp-10h],rax
    412: mov     rax,[rbp+10h]
    416: mov     rax,[rax+10h]
    41a: mov     [rbp-18h],rax
    41e: mov     rax,[rbp-10h]
    422: add     rax,[rbp-18h]
    426: mov     [rbp-8],rax
    42a: mov     rax,[rbp+10h]
    42e: mov     rcx,[rbp-8]
    432: mov     [rax+8],rcx
    436: mov     rax,[rbp+10h]
    43a: mov     rax,[rax]
    43d: mov     [rbp-10h],rax
    441: mov     rax,[rbp+10h]
    445: mov     rax,[rax+18h]
    449: mov     [rbp-18h],rax
    44d: mov     rax,[rbp-10h]
    451: add     rax,[rbp-18h]
    455: mov     [rbp-8],rax
    459: mov     rax,[rbp+10h]
    45d: mov     rcx,[rbp-8]
    461: mov     [rax],rcx
    464: mov     rax,[rbp+10h]
    468: mov     rax,[rax+10h]
    46c: mov     [rbp-10h],rax
    470: mov     dword ptr [rbp-1Ch],11h
    477: mov     edi,0FFFFFFF8h
    47c: mov     esi,0FFFFFFF0h
    481: mov     edx,0FFFFFFE4h
    486: call    ryo_h_RotlW64
    48b: mov     rax,[rbp+10h]
    48f: mov     rcx,[rbp-8]
    493: mov     [rax+10h],rcx
    497: mov     rax,[rbp+10h]
    49b: mov     rax,[rax+8]
    49f: mov     [rbp-8],rax
    4a3: mov     rax,[rbp+10h]
    4a7: mov     rax,[rax+10h]
    4ab: mov     [rbp-20h],rax
    4af: mov     rax,[rbp-20h]
    4b3: xor     rax,[rbp-8]
    4b7: mov     [rbp-30h],rax
    4bb: mov     rax,[rbp+10h]
    4bf: mov     rcx,[rbp-30h]
    4c3: mov     [rax+10h],rcx
    4c7: mov     rax,[rbp+10h]
    4cb: mov     rax,[rax+18h]
    4cf: mov     [rbp-10h],rax
    4d3: mov     dword ptr [rbp-1Ch],15h
    4da: mov     edi,0FFFFFFF8h
    4df: mov     esi,0FFFFFFF0h
    4e4: mov     edx,0FFFFFFE4h
    4e9: call    ryo_h_RotlW64
    4ee: mov     rax,[rbp+10h]
    4f2: mov     rcx,[rbp-8]
    4f6: mov     [rax+18h],rcx
    4fa: mov     rax,[rbp+10h]
    4fe: mov     rax,[rax]
    501: mov     [rbp-8],rax
    505: mov     rax,[rbp+10h]
    509: mov     rax,[rax+18h]
    50d: mov     [rbp-20h],rax
    511: mov     rax,[rbp-20h]
    515: xor     rax,[rbp-8]
    519: mov     [rbp-30h],rax
    51d: mov     rax,[rbp+10h]
    521: mov     rcx,[rbp-30h]
    525: mov     [rax+18h],rcx
    529: mov     rax,[rbp+10h]
    52d: mov     rax,[rax+8]
    531: mov     [rbp-10h],rax
    535: mov     dword ptr [rbp-1Ch],20h
    53c: mov     edi,0FFFFFFF8h
    541: mov     esi,0FFFFFFF0h
    546: mov     edx,0FFFFFFE4h
    54b: call    ryo_h_RotlW64
    550: mov     rax,[rbp+10h]
    554: mov     rcx,[rbp-8]
    558: mov     [rax+8],rcx
    55c: mov     rax,[rbp+10h]
    560: mov     rax,[rax]
    563: mov     [rbp-10h],rax
    567: mov     rax,[rbp+10h]
    56b: mov     rax,[rax+10h]
    56f: mov     [rbp-18h],rax
    573: mov     rax,[rbp-10h]
    577: add     rax,[rbp-18h]
    57b: mov     [rbp-8],rax
    57f: mov     rax,[rbp+10h]
    583: mov     rcx,[rbp-8]
    587: mov     [rax],rcx
    58a: mov     rax,[rbp+10h]
    58e: mov     rax,[rax+8]
    592: mov     [rbp-10h],rax
    596: mov     rax,[rbp+10h]
    59a: mov     rax,[rax+18h]
    59e: mov     [rbp-18h],rax
    5a2: mov     rax,[rbp-10h]
    5a6: add     rax,[rbp-18h]
    5aa: mov     [rbp-8],rax
    5ae: mov     rax,[rbp+10h]
    5b2: mov     rcx,[rbp-8]
    5b6: mov     [rax+8],rcx
    5ba: mov     rax,[rbp+10h]
    5be: mov     rax,[rax+10h]
    5c2: mov     [rbp-10h],rax
    5c6: mov     dword ptr [rbp-1Ch],0Dh
    5cd: mov     edi,0FFFFFFF8h
    5d2: mov     esi,0FFFFFFF0h
    5d7: mov     edx,0FFFFFFE4h
    5dc: call    ryo_h_RotlW64
    5e1: mov     rax,[rbp+10h]
    5e5: mov     rcx,[rbp-8]
    5e9: mov     [rax+10h],rcx
    5ed: mov     rax,[rbp+10h]
    5f1: mov     rax,[rax]
    5f4: mov     [rbp-8],rax
    5f8: mov     rax,[rbp+10h]
    5fc: mov     rax,[rax+10h]
    600: mov     [rbp-20h],rax
    604: mov     rax,[rbp-20h]
    608: xor     rax,[rbp-8]
    60c: mov     [rbp-30h],rax
    610: mov     rax,[rbp+10h]
    614: mov     rcx,[rbp-30h]
    618: mov     [rax+10h],rcx
    61c: mov     rax,[rbp+10h]
    620: mov     rax,[rax+18h]
    624: mov     [rbp-10h],rax
    628: mov     dword ptr [rbp-1Ch],10h
    62f: mov     edi,0FFFFFFF8h
    634: mov     esi,0FFFFFFF0h
    639: mov     edx,0FFFFFFE4h
    63e: call    ryo_h_RotlW64
    643: mov     rax,[rbp+10h]
    647: mov     rcx,[rbp-8]
    64b: mov     [rax+18h],rcx
    64f: mov     rax,[rbp+10h]
    653: mov     rax,[rax+8]
    657: mov     [rbp-8],rax
    65b: mov     rax,[rbp+10h]
    65f: mov     rax,[rax+18h]
    663: mov     [rbp-20h],rax
    667: mov     rax,[rbp-20h]
    66b: xor     rax,[rbp-8]
    66f: mov     [rbp-30h],rax
    673: mov     rax,[rbp+10h]
    677: mov     rcx,[rbp-30h]
    67b: mov     [rax+18h],rcx
    67f: mov     rax,[rbp+10h]
    683: mov     rax,[rax]
    686: mov     [rbp-10h],rax
    68a: mov     dword ptr [rbp-1Ch],20h
    691: mov     edi,0FFFFFFF8h
    696: mov     esi,0FFFFFFF0h
    69b: mov     edx,0FFFFFFE4h
    6a0: call    ryo_h_RotlW64
    6a5: mov     rax,[rbp+10h]
    6a9: mov     rcx,[rbp-8]
    6ad: mov     [rax],rcx
    6b0: mov     rax,[rbp+10h]
    6b4: mov     rax,[rax+8]
    6b8: mov     [rbp-10h],rax
    6bc: mov     rax,[rbp+10h]
    6c0: mov     rax,[rax+10h]
    6c4: mov     [rbp-18h],rax
    6c8: mov     rax,[rbp-10h]
    6cc: add     rax,[rbp-18h]
    6d0: mov     [rbp-8],rax
    6d4: mov     rax,[rbp+10h]
    6d8: mov     rcx,[rbp-8]
    6dc: mov     [rax+8],rcx
    6e0: mov     rax,[rbp+10h]
    6e4: mov     rax,[rax]
    6e7: mov     [rbp-10h],rax
    6eb: mov     rax,[rbp+10h]
    6ef: mov     rax,[rax+18h]
    6f3: mov     [rbp-18h],rax
    6f7: mov     rax,[rbp-10h]
    6fb: add     rax,[rbp-18h]
    6ff: mov     [rbp-8],rax
    703: mov     rax,[rbp+10h]
    707: mov     rcx,[rbp-8]
    70b: mov     [rax],rcx
    70e: mov     rax,[rbp+10h]
    712: mov     rax,[rax+10h]
    716: mov     [rbp-10h],rax
    71a: mov     dword ptr [rbp-1Ch],11h
    721: mov     edi,0FFFFFFF8h
    726: mov     esi,0FFFFFFF0h
    72b: mov     edx,0FFFFFFE4h
    730: call    ryo_h_RotlW64
    735: mov     rax,[rbp+10h]
    739: mov     rcx,[rbp-8]
    73d: mov     [rax+10h],rcx
    741: mov     rax,[rbp+10h]
    745: mov     rax,[rax+8]
    749: mov     [rbp-8],rax
    74d: mov     rax,[rbp+10h]
    751: mov     rax,[rax+10h]
    755: mov     [rbp-20h],rax
    759: mov     rax,[rbp-20h]
    75d: xor     rax,[rbp-8]
    761: mov     [rbp-30h],rax
    765: mov     rax,[rbp+10h]
    769: mov     rcx,[rbp-30h]
    76d: mov     [rax+10h],rcx
    771: mov     rax,[rbp+10h]
    775: mov     rax,[rax+18h]
    779: mov     [rbp-10h],rax
    77d: mov     dword ptr [rbp-1Ch],15h
    784: mov     edi,0FFFFFFF8h
    789: mov     esi,0FFFFFFF0h
    78e: mov     edx,0FFFFFFE4h
    793: call    ryo_h_RotlW64
    798: mov     rax,[rbp+10h]
    79c: mov     rcx,[rbp-8]
    7a0: mov     [rax+18h],rcx
    7a4: mov     rax,[rbp+10h]
    7a8: mov     rax,[rax]
    7ab: mov     [rbp-8],rax
    7af: mov     rax,[rbp+10h]
    7b3: mov     rax,[rax+18h]
    7b7: mov     [rbp-20h],rax
    7bb: mov     rax,[rbp-20h]
    7bf: xor     rax,[rbp-8]
    7c3: mov     [rbp-30h],rax
    7c7: mov     rax,[rbp+10h]
    7cb: mov     rcx,[rbp-30h]
    7cf: mov     [rax+18h],rcx
    7d3: mov     rax,[rbp+10h]
    7d7: mov     rax,[rax+8]
    7db: mov     [rbp-10h],rax
    7df: mov     dword ptr [rbp-1Ch],20h
    7e6: mov     edi,0FFFFFFF8h
    7eb: mov     esi,0FFFFFFF0h
    7f0: mov     edx,0FFFFFFE4h
    7f5: call    ryo_h_RotlW64
    7fa: mov     rax,[rbp+10h]
    7fe: mov     rcx,[rbp-8]
    802: mov     [rax+8],rcx
    806: xor     edi,edi
    808: xor     esi,esi
    80a: call    ryo_h_Ret
    80f: leave
    810: ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-18h],rax
     13: mov     rax,[rbp-18h]
     17: mov     [rbp-30h],rax
     1b: call    fn0
     20: nop     [rcx-10h]
     27: lea     rax,[rbp-10h]
     2b: mov     [rbp-20h],rax
     2f: mov     rax,[rbp-20h]
     33: mov     [rbp-30h],rax
     37: call    fn1
     3c: nop     [rcx-20h]
     43: xor     edi,edi
     45: xor     esi,esi
     47: call    ryo_h_Ret
     4c: leave
     4d: ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     byte ptr [rbp-19h],1
      c: test    byte ptr [rbp-19h],0FFh
     10: je      3Fh
     12: mov     rax,[rbp+10h]
     16: mov     [rbp-18h],rax
     1a: mov     rax,[rbp-18h]
     1e: mov     [rbp-30h],rax
     22: mov     edi,0FFFFFFD8h
     27: lea     rsi,[k0]
     2e: call    ryo_h_AddrAbs
     33: call    fn1
     38: nop     [rcx-8]
     3f: mov     rax,[rbp+10h]
     43: mov     [rbp-10h],rax
     47: mov     rax,[rbp-10h]
     4b: mov     [rbp-8],rax
     4f: mov     edi,0FFFFFFF8h
     54: mov     esi,8
     59: call    ryo_h_Ret
     5e: leave
     5f: ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_char
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     edi,0FFFFFFBCh
     10: mov     esi,4
     15: call    ryo_h_Zero
     1a: lea     rax,[rbp-44h]
     1e: mov     [rbp-40h],rax
     22: mov     rax,[rbp-40h]
     26: mov     [rbp-38h],rax
     2a: mov     qword ptr [rbp-30h],4
     32: mov     eax,[rbp+18h]
     35: mov     [rbp-48h],eax
     38: mov     eax,[rbp-48h]
     3b: mov     [rbp-80h],eax
     3e: mov     edi,0FFFFFF88h
     43: mov     esi,0FFFFFFC8h
     48: call    ryo_h_MovW128
     4d: call    fn0
     52: nop     [rcx-58h]
     59: jmp     71h
     5b: nop     [rax+rax]
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
     94: .long   d1h
     98: .long   a7h
     9c: .long   a0h
     a0: call    ryo_h_Unreachable
     a5: ud2
     a7: mov     rax,[rbp-28h]
     ab: mov     [rbp-40h],rax
     af: mov     rax,[rbp+10h]
     b3: lea     rax,[rax+8]
     b7: mov     [rbp-48h],rax
     bb: mov     rax,[rbp-48h]
     bf: mov     [rbp-60h],rax
     c3: call    fn1
     c8: nop     [rcx-48h]
     cf: jmp     0D7h
     d1: mov     byte ptr [rbp-1],0
     d5: jmp     108h
     d7: mov     rax,[rbp+10h]
     db: mov     rcx,[rbp-28h]
     df: mov     [rax+8],rcx
     e3: mov     byte ptr [rbp-1],1
     e7: jmp     108h
     e9: nop     [rax]
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
     2f: mov     rax,[rbp-20h]
     33: mov     [rbp-18h],rax
     37: mov     edi,0FFFFFF80h
     3c: mov     esi,0FFFFFFC0h
     41: mov     edx,20h
     46: call    ryo_h_Copy
     4b: mov     rax,[rbp-48h]
     4f: mov     [rbp-60h],rax
     53: mov     rax,[rbp+38h]
     57: mov     [rbp-58h],rax
     5b: mov     rax,[rbp-18h]
     5f: mov     [rbp-50h],rax
     63: call    fn0
     68: nop     [rcx-8]
     6f: jmp     0ACh
     71: nop     [rax+rax]
     7a: nop     [rax+rax]
     80: mov     edi,0FFFFFFF8h
     85: mov     esi,8
     8a: call    ryo_h_Ret
     8f: leave
     90: ret
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: mov     edi,0FFFFFFF0h
     a5: call    ryo_h_Resume
     aa: ud2
     ac: jmp     80h
     ae: mov     rdi,rax
     b1: mov     esi,0FFFFFFF0h
     b6: call    ryo_h_Lpad
     bb: jmp     0A0h

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     byte ptr [rbp-51h],0
      f: test    byte ptr [rbp-51h],0FFh
     13: je      0CBh
     19: jmp     0BEh
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
     48: mov     rax,[rbp-30h]
     4c: mov     [rbp-20h],rax
     50: mov     rax,[rbp-30h]
     54: lea     rax,[rax+8]
     58: mov     [rbp-28h],rax
     5c: mov     rax,[rbp+10h]
     60: mov     rax,[rax]
     63: mov     [rbp-18h],rax
     67: mov     rax,[rbp-20h]
     6b: mov     [rbp-50h],rax
     6f: mov     rax,[rbp-28h]
     73: mov     [rbp-48h],rax
     77: mov     rax,[rbp+18h]
     7b: mov     [rbp-40h],rax
     7f: mov     edi,0FFFFFFC8h
     84: mov     esi,0FFFFFFB0h
     89: call    ryo_h_MovW128
     8e: mov     rax,[rbp-18h]
     92: mov     [rbp-80h],rax
     96: mov     rax,[rbp-40h]
     9a: mov     [rbp-78h],rax
     9e: mov     edi,0FFFFFF90h
     a3: mov     esi,0FFFFFFC8h
     a8: call    ryo_h_MovW128
     ad: call    fn0
     b2: nop     [rcx-8]
     b9: jmp     20h
     be: mov     qword ptr [rbp-20h],8
     c6: jmp     40h
     cb: mov     rax,[rbp+20h]
     cf: mov     [rbp-38h],rax
     d3: mov     rax,[rbp-38h]
     d7: mov     [rbp-28h],rax
     db: mov     byte ptr [rbp-51h],0
     df: test    byte ptr [rbp-51h],0FFh
     e3: je      0FFh
     e5: jmp     0F5h
     e7: nop     [rax+rax]
     f0: jmp     40h
     f5: mov     rax,[rbp-28h]
     f9: mov     [rbp-20h],rax
     fd: jmp     0F0h
     ff: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    107: mov     rax,[rbp-28h]
    10b: imul    rcx,[rbp-58h],10h
    110: add     rax,rcx
    113: mov     [rbp-20h],rax
    117: jmp     0F0h

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
     1c: mov     rax,[rbp-18h]
     20: mov     [rbp-10h],rax
     24: mov     rax,[rbp-8]
     28: mov     [rbp-30h],rax
     2c: mov     rax,[rbp-10h]
     30: mov     [rbp-28h],rax
     34: call    fn0
     39: nop     [rcx]
     40: xor     edi,edi
     42: xor     esi,esi
     44: call    ryo_h_Ret
     49: leave
     4a: ret

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp+10h]
     14: lea     rax,[rax+18h]
     18: mov     [rbp-18h],rax
     1c: mov     rax,[rbp-18h]
     20: mov     [rbp-10h],rax
     24: mov     rax,[rbp-8]
     28: mov     [rbp-30h],rax
     2c: mov     rax,[rbp-10h]
     30: mov     [rbp-28h],rax
     34: call    fn0
     39: nop     [rcx]
     40: xor     edi,edi
     42: xor     esi,esi
     44: call    ryo_h_Ret
     49: leave
     4a: ret

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
     10: cmp     qword ptr [rbp-20h],0
     15: je      80h
     17: mov     rax,[rbp+20h]
     1b: mov     [rbp-28h],rax
     1f: mov     rax,[rbp+18h]
     23: mov     [rbp-50h],rax
     27: mov     rax,[rbp-20h]
     2b: mov     [rbp-48h],rax
     2f: mov     rax,[rbp-28h]
     33: mov     [rbp-40h],rax
     37: lea     rdi,[sym0]
     3e: lea     rsi,[site1]
     45: mov     edx,0FFFFFFD0h
     4a: call    ryo_h_CallExt
     4f: test    rax,rax
     52: je      5Fh
     54: call    rax
     56: nop     [rcx]
     5d: jmp     6Fh
     5f: mov     rdi,rbp
     62: lea     rsi,[ro+4]
     69: call    qword ptr [sym2]
     6f: jmp     8Bh
     71: nop     [rax+rax]
     7a: nop     [rax+rax]
     80: xor     edi,edi
     82: xor     esi,esi
     84: call    ryo_h_Ret
     89: leave
     8a: ret
     8b: jmp     80h

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
     27: mov     rax,[rbp-20h]
     2b: mov     [rbp-18h],rax
     2f: mov     edi,0FFFFFF80h
     34: mov     esi,0FFFFFFB8h
     39: mov     edx,28h
     3e: call    ryo_h_Copy
     43: mov     rax,[rbp+38h]
     47: mov     [rbp-58h],rax
     4b: mov     rax,[rbp-18h]
     4f: mov     [rbp-50h],rax
     53: call    fn0
     58: nop     [rcx-8]
     5f: jmp     9Ch
     61: nop     [rax+rax]
     6a: nop     [rax+rax]
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
     10: mov     rax,[rbp-18h]
     14: mov     [rbp-20h],rax
     18: call    fn0
     1d: nop     [rcx-8]
     24: mov     edi,0FFFFFFF8h
     29: mov     esi,8
     2e: call    ryo_h_Ret
     33: leave
     34: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp-10h]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFD8h
     1d: mov     esi,18h
     22: call    ryo_h_MovW128
     27: call    fn0
     2c: nop     [rcx]
     33: xor     edi,edi
     35: xor     esi,esi
     37: call    ryo_h_Ret
     3c: leave
     3d: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     rax,[rbp-10h]
     14: mov     [rbp-30h],rax
     18: mov     edi,0FFFFFFD8h
     1d: mov     esi,18h
     22: call    ryo_h_MovW128
     27: call    fn0
     2c: nop     [rcx-8]
     33: xor     edi,edi
     35: xor     esi,esi
     37: call    ryo_h_Ret
     3c: leave
     3d: ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,40h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-20h],rax
     10: lea     rax,[rbp-20h]
     14: mov     [rbp-18h],rax
     18: mov     rax,[rbp-18h]
     1c: mov     [rbp-10h],rax
     20: mov     qword ptr [rbp-8],8
     28: mov     rax,[rbp+10h]
     2c: mov     [rbp-40h],rax
     30: mov     edi,0FFFFFFC8h
     35: mov     esi,0FFFFFFF0h
     3a: call    ryo_h_MovW128
     3f: call    fn0
     44: nop     [rcx]
     4b: xor     edi,edi
     4d: xor     esi,esi
     4f: call    ryo_h_Ret
     54: leave
     55: ret

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
     b3: mov     rax,[rbp-138h]
     ba: mov     [rbp-160h],rax
     c1: call    fn0
     c6: nop     [rcx-48h]
     cd: mov     edi,0FFFFFF18h
     d2: mov     esi,0FFFFFED0h
     d7: mov     edx,48h
     dc: call    ryo_h_Copy
     e1: mov     edi,0FFFFFF70h
     e6: mov     esi,0FFFFFF18h
     eb: mov     edx,48h
     f0: call    ryo_h_Copy
     f5: mov     edi,0FFFFFFB8h
     fa: mov     esi,0FFFFFF70h
     ff: mov     edx,48h
    104: call    ryo_h_Copy
    109: mov     edi,0FFFFFFB8h
    10e: mov     esi,48h
    113: call    ryo_h_Ret
    118: leave
    119: ret

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
     53: mov     rax,[rbp-60h]
     57: mov     [rbp-80h],rax
     5b: call    fn2
     60: nop     [rcx-8]
     67: mov     edi,0FFFFFFF8h
     6c: mov     esi,8
     71: call    ryo_h_Ret
     76: leave
     77: ret
     78: nop     [rax+rax]
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
     53: mov     rax,[rbp-60h]
     57: mov     [rbp-80h],rax
     5b: call    fn2
     60: nop     [rcx-8]
     67: mov     edi,0FFFFFFF8h
     6c: mov     esi,8
     71: call    ryo_h_Ret
     76: leave
     77: ret
     78: nop     [rax+rax]
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
     3c: je      79h
     3e: mov     rax,[rbp+10h]
     42: mov     eax,[rax]
     44: mov     [rbp-10h],eax
     47: mov     eax,[rbp-10h]
     4a: mov     [rbp-30h],eax
     4d: mov     qword ptr [rbp-28h],1
     55: call    fn1
     5a: nop     [rcx-14h]
     61: mov     rax,[rbp+10h]
     65: mov     ecx,[rbp-14h]
     68: mov     [rax],ecx
     6a: mov     eax,[rbp-10h]
     6d: mov     [rbp-4],eax
     70: mov     dword ptr [rbp-8],1
     77: jmp     80h
     79: mov     dword ptr [rbp-8],0
     80: mov     edi,0FFFFFFF8h
     85: mov     esi,8
     8a: call    ryo_h_Ret
     8f: leave
     90: ret

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
     14: mov     rax,[rbp-40h]
     18: mov     [rbp-38h],rax
     1c: mov     rax,[rbp+10h]
     20: mov     rax,[rax+10h]
     24: mov     [rbp-40h],rax
     28: mov     rax,[rbp-38h]
     2c: mov     [rbp-30h],rax
     30: mov     rax,[rbp-40h]
     34: mov     [rbp-28h],rax
     38: mov     rax,[rbp-30h]
     3c: mov     [rbp-20h],rax
     40: mov     rax,[rbp-28h]
     44: mov     [rbp-18h],rax
     48: mov     edi,0FFFFFFF0h
     4d: mov     esi,0FFFFFFE0h
     52: call    ryo_h_MovW128
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-60h],rax
     5f: mov     edi,0FFFFFFA8h
     64: mov     esi,0FFFFFFF0h
     69: call    ryo_h_MovW128
     6e: call    fn0
     73: nop     [rcx]
     7a: xor     edi,edi
     7c: xor     esi,esi
     7e: call    ryo_h_Ret
     83: leave
     84: ret

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
     27: cmp     qword ptr [rbp-50h],0
     2c: sete    [rbp-31h]
     30: test    byte ptr [rbp-31h],0FFh
     34: je      43h
     36: mov     qword ptr [rbp-8],0
     3e: jmp     175h
     43: mov     edi,0FFFFFFA8h
     48: mov     esi,18h
     4d: call    ryo_h_MovW128
     52: mov     rax,[rbp+10h]
     56: mov     [rbp-0C0h],rax
     5d: mov     edi,0FFFFFF48h
     62: mov     esi,0FFFFFFA8h
     67: call    ryo_h_MovW128
     6c: lea     rdi,[sym0]
     73: lea     rsi,[site1]
     7a: mov     edx,0FFFFFF68h
     7f: call    ryo_h_CallExt
     84: test    rax,rax
     87: je      94h
     89: call    rax
     8b: nop     [rcx-48h]
     92: jmp     0A4h
     94: mov     rdi,rbp
     97: lea     rsi,[ro+4]
     9e: call    qword ptr [sym2]
     a4: mov     rax,[rbp-48h]
     a8: mov     [rbp-10h],rax
     ac: mov     edi,0FFFFFFF0h
     b1: xor     esi,esi
     b3: mov     edx,2
     b8: call    ryo_h_SwitchDenseW64
     bd: lea     rcx,[0D0h]
     c4: movsxd  rax,[rcx+rax*4]
     c8: add     rax,rcx
     cb: jmp     rax
     cd: int3
     ce: int3
     cf: int3
     d0: .long   e7h
     d4: .long   f0h
     d8: .long   e0h
     dc: nop     [rax]
     e0: call    ryo_h_Unreachable
     e5: ud2
     e7: cmp     qword ptr [rbp-40h],0
     ec: je      134h
     ee: jmp     111h
     f0: lea     rax,[rbp-40h]
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp-50h]
     fc: mov     [rbp-0C0h],rax
    103: call    fn3
    108: nop     [rcx-32h]
    10f: jmp     147h
    111: mov     rax,[rbp-40h]
    115: mov     [rbp-50h],rax
    119: mov     rax,[rbp+20h]
    11d: mov     [rbp-58h],rax
    121: mov     rax,[rbp-58h]
    125: cmp     rax,[rbp-50h]
    129: jb      254h
    12f: jmp     2C5h
    134: mov     edi,0FFFFFFF8h
    139: lea     rsi,[k4]
    140: call    ryo_h_AddrAbs
    145: jmp     175h
    147: test    byte ptr [rbp-32h],0FFh
    14b: je      152h
    14d: jmp     1D0h
    152: mov     rax,[rbp-40h]
    156: mov     [rbp-50h],rax
    15a: mov     rax,[rbp-50h]
    15e: mov     [rbp-8],rax
    162: jmp     175h
    164: nop     [rax+rax]
    16d: nop     [rax]
    170: jmp     10h
    175: mov     edi,0FFFFFFF8h
    17a: mov     esi,8
    17f: call    ryo_h_Ret
    184: leave
    185: ret
    186: nop     [rax+rax]
    18f: nop
    190: mov     edi,0FFFFFFD0h
    195: call    ryo_h_Resume
    19a: ud2
    19c: lea     rax,[rbp-40h]
    1a0: mov     [rbp-98h],rax
    1a7: mov     rax,[rbp-98h]
    1ae: mov     [rbp-0C0h],rax
    1b5: call    fn5
    1ba: nop     [rcx-98h]
    1c1: jmp     170h
    1c3: nop     [rax+rax]
    1cc: nop     [rax]
    1d0: mov     rax,[rbp-48h]
    1d4: mov     [rbp-20h],rax
    1d8: mov     edi,0FFFFFFE0h
    1dd: xor     esi,esi
    1df: mov     edx,2
    1e4: call    ryo_h_SwitchDenseW64
    1e9: lea     rcx,[1FCh]
    1f0: movsxd  rax,[rcx+rax*4]
    1f4: add     rax,rcx
    1f7: jmp     rax
    1f9: int3
    1fa: int3
    1fb: int3
    1fc: .long   170h
    200: .long   19ch
    204: .long   e0h
    208: nop     [rax+rax]
    210: lea     rax,[rbp-40h]
    214: mov     [rbp-98h],rax
    21b: mov     rax,[rbp-98h]
    222: mov     [rbp-0C0h],rax
    229: call    fn6
    22e: nop     [rcx-98h]
    235: jmp     190h
    23a: nop     [rax+rax]
    240: mov     rax,[rbp-48h]
    244: mov     [rbp-28h],rax
    248: cmp     qword ptr [rbp-28h],1
    24d: je      210h
    24f: jmp     190h
    254: mov     rax,[rbp-50h]
    258: mov     [rbp-0C0h],rax
    25f: mov     rax,[rbp-58h]
    263: mov     [rbp-0B8h],rax
    26a: mov     rax,[rbp-58h]
    26e: mov     [rbp-0B0h],rax
    275: mov     edi,0FFFFFF58h
    27a: lea     rsi,[k7]
    281: call    ryo_h_AddrAbs
    286: lea     rdi,[sym8]
    28d: lea     rsi,[site9]
    294: mov     edx,0FFFFFF68h
    299: call    ryo_h_CallExt
    29e: test    rax,rax
    2a1: je      2AEh
    2a3: call    rax
    2a5: nop     [rcx-28h]
    2ac: jmp     2BEh
    2ae: mov     rdi,rbp
    2b1: lea     rsi,[ro+20]
    2b8: call    qword ptr [sym10]
    2be: call    ryo_h_Unreachable
    2c3: ud2
    2c5: mov     rax,[rbp-58h]
    2c9: sub     rax,[rbp-50h]
    2cd: mov     [rbp-60h],rax
    2d1: mov     rax,[rbp+18h]
    2d5: mov     [rbp-80h],rax
    2d9: mov     rax,[rbp+20h]
    2dd: mov     [rbp-78h],rax
    2e1: mov     rax,[rbp-80h]
    2e5: mov     [rbp-88h],rax
    2ec: mov     rax,[rbp-88h]
    2f3: imul    rcx,[rbp-50h],1
    2f8: add     rax,rcx
    2fb: mov     [rbp-90h],rax
    302: mov     rax,[rbp-90h]
    309: mov     [rbp-70h],rax
    30d: mov     rax,[rbp-60h]
    311: mov     [rbp-68h],rax
    315: mov     rax,[rbp-70h]
    319: mov     [rbp+18h],rax
    31d: mov     rax,[rbp-68h]
    321: mov     [rbp+20h],rax
    325: jmp     1D0h
    32a: nop     [rax+rax]
    330: lea     rdi,[sym11]
    337: lea     rsi,[site12]
    33e: mov     edx,0FFFFFF68h
    343: call    ryo_h_CallExt
    348: test    rax,rax
    34b: je      358h
    34d: call    rax
    34f: nop     [rcx-90h]
    356: jmp     368h
    358: mov     rdi,rbp
    35b: lea     rsi,[ro+36]
    362: call    qword ptr [sym13]
    368: call    ryo_h_Unreachable
    36d: ud2
    36f: mov     rdi,rax
    372: mov     esi,0FFFFFFD0h
    377: call    ryo_h_Lpad
    37c: jmp     240h
    381: mov     rdi,rax
    384: mov     esi,0FFFFFFD0h
    389: call    ryo_h_Lpad
    38e: jmp     330h

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_fmt
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: lea     rax,[rbp+18h]
      c: mov     [rbp-28h],rax
     10: mov     rax,[rbp-28h]
     14: mov     [rbp-60h],rax
     18: call    fn0
     1d: nop     [rcx-20h]
     24: mov     edi,0FFFFFFBCh
     29: mov     esi,0FFFFFFE0h
     2e: xor     edx,edx
     30: xor     ecx,ecx
     32: xor     r8d,r8d
     35: mov     r9d,1
     3b: call    ryo_h_DiscrNicheW64
     40: mov     edi,0FFFFFFF0h
     45: mov     esi,0FFFFFFBCh
     4a: call    ryo_h_ZextW32W64
     4f: mov     edi,0FFFFFFF0h
     54: xor     esi,esi
     56: mov     edx,2
     5b: call    ryo_h_SwitchDenseW64
     60: lea     rcx,[70h]
     67: movsxd  rax,[rcx+rax*4]
     6b: add     rax,rcx
     6e: jmp     rax
     70: .long   bfh
     74: .long   7ch
     78: .long   f3h
     7c: mov     edi,0FFFFFFD0h
     81: mov     esi,0FFFFFFE0h
     86: call    ryo_h_MovW128
     8b: mov     edi,0FFFFFFC0h
     90: mov     esi,0FFFFFFD0h
     95: call    ryo_h_MovW128
     9a: mov     rax,[rbp+10h]
     9e: mov     [rbp-60h],rax
     a2: mov     edi,0FFFFFFA8h
     a7: mov     esi,0FFFFFFC0h
     ac: call    ryo_h_MovW128
     b1: call    fn1
     b6: nop     [rcx-8]
     bd: jmp     0E2h
     bf: mov     rax,[rbp+10h]
     c3: mov     [rbp-60h],rax
     c7: mov     edi,0FFFFFFA8h
     cc: mov     esi,18h
     d1: call    ryo_h_MovW128
     d6: call    fn2
     db: nop     [rcx-8]
     e2: mov     edi,0FFFFFFF8h
     e7: mov     esi,8
     ec: call    ryo_h_Ret
     f1: leave
     f2: ret
     f3: call    ryo_h_Unreachable
     f8: ud2

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
     f6: mov     qword ptr [rbp-0B0h],1
    101: mov     qword ptr [rbp-0A8h],1
    10c: mov     rax,[rbp-58h]
    110: mov     [rbp-0A0h],rax
    117: mov     edi,0FFFFFF68h
    11c: lea     rsi,[k2]
    123: call    ryo_h_AddrAbs
    128: call    fn3
    12d: nop     [rcx-40h]
    134: imul    rax,[rbp-58h],1
    139: mov     [rbp-88h],rax
    140: mov     edi,0FFFFFF90h
    145: mov     esi,0FFFFFF98h
    14a: mov     edx,0FFFFFF78h
    14f: call    ryo_h_Memcpy
    154: mov     byte ptr [rbp-81h],1
    15b: test    byte ptr [rbp-81h],0FFh
    162: je      180h
    164: mov     qword ptr [rbp-88h],1
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: lea     rax,[rbp+10h]
     14: mov     [rbp-18h],rax
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
     45: nop     [rax+rax]
     4e: xchg    ax,ax
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
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-40h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-38h],rax
     30: mov     rax,[rbp-10h]
     34: mov     [rbp-30h],rax
     38: call    fn0
     3d: nop     [rcx-8]
     44: mov     edi,0FFFFFFF8h
     49: mov     esi,8
     4e: call    ryo_h_Ret
     53: leave
     54: ret
     55: nop     [rax+rax]
     5e: xchg    ax,ax
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
     18: mov     rax,[rbp-10h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp-8]
     24: mov     [rbp-28h],rax
     28: call    fn0
     2d: nop     [rcx]
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret
     3f: nop
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
     45: nop     [rax+rax]
     4e: xchg    ax,ax
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
     45: nop     [rax+rax]
     4e: xchg    ax,ax
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
     20: mov     rax,[rbp-20h]
     24: mov     [rbp-40h],rax
     28: mov     rax,[rbp-18h]
     2c: mov     [rbp-38h],rax
     30: mov     rax,[rbp-10h]
     34: mov     [rbp-30h],rax
     38: call    fn0
     3d: nop     [rcx-8]
     44: mov     edi,0FFFFFFF8h
     49: mov     esi,8
     4e: call    ryo_h_Ret
     53: leave
     54: ret
     55: nop     [rax+rax]
     5e: xchg    ax,ax
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
     18: mov     rax,[rbp-18h]
     1c: mov     [rbp-30h],rax
     20: mov     rax,[rbp-10h]
     24: mov     [rbp-28h],rax
     28: call    fn0
     2d: nop     [rcx-8]
     34: mov     edi,0FFFFFFF8h
     39: mov     esi,8
     3e: call    ryo_h_Ret
     43: leave
     44: ret
     45: nop     [rax+rax]
     4e: xchg    ax,ax
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

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
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

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp-8]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx]
     2f: xor     edi,edi
     31: xor     esi,esi
     33: call    ryo_h_Ret
     38: leave
     39: ret

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     rax,[rbp-8]
     17: mov     [rbp-20h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-18h],rax
     23: call    fn0
     28: nop     [rcx]
     2f: xor     edi,edi
     31: xor     esi,esi
     33: call    ryo_h_Ret
     38: leave
     39: ret

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
     28: mov     rax,[rbp-8]
     2c: mov     rcx,736F6D6570736575h
     36: xor     rax,rcx
     39: mov     [rbp-10h],rax
     3d: mov     rax,[rbp+10h]
     41: mov     rcx,[rbp-10h]
     45: mov     [rax],rcx
     48: mov     rax,[rbp+10h]
     4c: mov     rax,[rax+28h]
     50: mov     [rbp-8],rax
     54: mov     rax,[rbp-8]
     58: mov     rcx,646F72616E646F6Dh
     62: xor     rax,rcx
     65: mov     [rbp-10h],rax
     69: mov     rax,[rbp+10h]
     6d: mov     rcx,[rbp-10h]
     71: mov     [rax+10h],rcx
     75: mov     rax,[rbp+10h]
     79: mov     rax,[rax+20h]
     7d: mov     [rbp-8],rax
     81: mov     rax,[rbp-8]
     85: mov     rcx,6C7967656E657261h
     8f: xor     rax,rcx
     92: mov     [rbp-10h],rax
     96: mov     rax,[rbp+10h]
     9a: mov     rcx,[rbp-10h]
     9e: mov     [rax+8],rcx
     a2: mov     rax,[rbp+10h]
     a6: mov     rax,[rax+28h]
     aa: mov     [rbp-8],rax
     ae: mov     rax,[rbp-8]
     b2: mov     rcx,7465646279746573h
     bc: xor     rax,rcx
     bf: mov     [rbp-10h],rax
     c3: mov     rax,[rbp+10h]
     c7: mov     rcx,[rbp-10h]
     cb: mov     [rax+18h],rcx
     cf: mov     qword ptr [rbp-10h],0
     d7: mov     rax,[rbp+10h]
     db: mov     rcx,[rbp-10h]
     df: mov     [rax+40h],rcx
     e3: xor     edi,edi
     e5: xor     esi,esi
     e7: call    ryo_h_Ret
     ec: leave
     ed: ret

fn core::hash::sip::u8to64_le
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     qword ptr [rbp-38h],0
     13: mov     qword ptr [rbp-8],0
     1b: mov     rax,[rbp-38h]
     1f: mov     [rbp-50h],rax
     23: mov     rax,[rbp-50h]
     27: add     rax,3
     2b: mov     [rbp-48h],rax
     2f: mov     rax,[rbp-48h]
     33: cmp     rax,[rbp+28h]
     37: jae     0A0h
     39: mov     dword ptr [rbp-40h],0
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-60h],rax
     48: mov     rax,[rbp+18h]
     4c: mov     [rbp-58h],rax
     50: mov     rax,[rbp-60h]
     54: mov     [rbp-50h],rax
     58: mov     rax,[rbp-38h]
     5c: mov     [rbp-60h],rax
     60: mov     rax,[rbp+20h]
     64: add     rax,[rbp-60h]
     68: mov     [rbp-58h],rax
     6c: mov     rax,[rbp-50h]
     70: imul    rcx,[rbp-58h],1
     75: add     rax,rcx
     78: mov     [rbp-48h],rax
     7c: lea     rax,[rbp-40h]
     80: mov     [rbp-58h],rax
     84: mov     rax,[rbp-58h]
     88: mov     [rbp-50h],rax
     8c: mov     byte ptr [rbp-79h],1
     90: test    byte ptr [rbp-79h],0FFh
     94: je      1E5h
     9a: jmp     181h
     9f: nop
     a0: mov     rax,[rbp-38h]
     a4: mov     [rbp-50h],rax
     a8: mov     rax,[rbp-50h]
     ac: add     rax,1
     b0: mov     [rbp-48h],rax
     b4: mov     rax,[rbp-48h]
     b8: cmp     rax,[rbp+28h]
     bc: jae     130h
     be: mov     word ptr [rbp-3Ch],0
     c4: mov     rax,[rbp+10h]
     c8: mov     [rbp-70h],rax
     cc: mov     rax,[rbp+18h]
     d0: mov     [rbp-68h],rax
     d4: mov     rax,[rbp-70h]
     d8: mov     [rbp-60h],rax
     dc: mov     rax,[rbp-38h]
     e0: mov     [rbp-70h],rax
     e4: mov     rax,[rbp+20h]
     e8: add     rax,[rbp-70h]
     ec: mov     [rbp-68h],rax
     f0: mov     rax,[rbp-60h]
     f4: imul    rcx,[rbp-68h],1
     f9: add     rax,rcx
     fc: mov     [rbp-58h],rax
    100: lea     rax,[rbp-3Ch]
    104: mov     [rbp-68h],rax
    108: mov     rax,[rbp-68h]
    10c: mov     [rbp-60h],rax
    110: mov     byte ptr [rbp-79h],1
    114: test    byte ptr [rbp-79h],0FFh
    118: je      297h
    11e: jmp     233h
    123: nop     [rax+rax]
    12c: nop     [rax]
    130: mov     rax,[rbp-38h]
    134: mov     [rbp-48h],rax
    138: mov     rax,[rbp-48h]
    13c: cmp     rax,[rbp+28h]
    140: jae     170h
    142: mov     rax,[rbp-38h]
    146: mov     [rbp-60h],rax
    14a: mov     rax,[rbp+20h]
    14e: add     rax,[rbp-60h]
    152: mov     [rbp-58h],rax
    156: mov     byte ptr [rbp-79h],1
    15a: test    byte ptr [rbp-79h],0FFh
    15e: je      353h
    164: jmp     318h
    169: nop     [rax]
    170: mov     edi,0FFFFFFF8h
    175: mov     esi,8
    17a: call    ryo_h_Ret
    17f: leave
    180: ret
    181: mov     rax,[rbp-48h]
    185: mov     [rbp-60h],rax
    189: mov     rax,[rbp-58h]
    18d: mov     [rbp-68h],rax
    191: mov     rax,[rbp-60h]
    195: mov     [rbp-0C0h],rax
    19c: mov     rax,[rbp-68h]
    1a0: mov     [rbp-0B8h],rax
    1a7: mov     qword ptr [rbp-0B0h],1
    1b2: mov     qword ptr [rbp-0A8h],1
    1bd: mov     qword ptr [rbp-0A0h],4
    1c8: mov     edi,0FFFFFF68h
    1cd: lea     rsi,[k0]
    1d4: call    ryo_h_AddrAbs
    1d9: call    fn1
    1de: nop     [rcx-21h]
    1e5: mov     qword ptr [rbp-80h],4
    1ed: imul    rax,[rbp-80h],1
    1f2: mov     [rbp-88h],rax
    1f9: mov     edi,0FFFFFFB0h
    1fe: mov     esi,0FFFFFFB8h
    203: mov     edx,0FFFFFF78h
    208: call    ryo_h_Memcpy
    20d: mov     eax,[rbp-40h]
    210: mov     [rbp-0Ch],eax
    213: mov     edi,0FFFFFFF8h
    218: mov     esi,0FFFFFFF4h
    21d: call    ryo_h_ZextW32W64
    222: mov     rax,[rbp-38h]
    226: add     rax,4
    22a: mov     [rbp-38h],rax
    22e: jmp     0A0h
    233: mov     rax,[rbp-58h]
    237: mov     [rbp-70h],rax
    23b: mov     rax,[rbp-68h]
    23f: mov     [rbp-78h],rax
    243: mov     rax,[rbp-70h]
    247: mov     [rbp-0C0h],rax
    24e: mov     rax,[rbp-78h]
    252: mov     [rbp-0B8h],rax
    259: mov     qword ptr [rbp-0B0h],1
    264: mov     qword ptr [rbp-0A8h],1
    26f: mov     qword ptr [rbp-0A0h],2
    27a: mov     edi,0FFFFFF68h
    27f: lea     rsi,[k2]
    286: call    ryo_h_AddrAbs
    28b: call    fn3
    290: nop     [rcx-21h]
    297: mov     qword ptr [rbp-80h],2
    29f: imul    rax,[rbp-80h],1
    2a4: mov     [rbp-88h],rax
    2ab: mov     edi,0FFFFFFA0h
    2b0: mov     esi,0FFFFFFA8h
    2b5: mov     edx,0FFFFFF78h
    2ba: call    ryo_h_Memcpy
    2bf: movzx   eax,word ptr [rbp-3Ch]
    2c3: mov     [rbp-0Eh],ax
    2c7: mov     edi,0FFFFFFB0h
    2cc: mov     esi,0FFFFFFF2h
    2d1: call    ryo_h_ZextW16W64
    2d6: mov     rax,[rbp-38h]
    2da: mov     [rbp-60h],rax
    2de: imul    rax,[rbp-60h],8
    2e3: mov     [rbp-58h],rax
    2e7: mov     edi,0FFFFFFB8h
    2ec: mov     esi,0FFFFFFB0h
    2f1: mov     edx,0FFFFFFA8h
    2f6: call    ryo_h_ShlW64
    2fb: mov     rax,[rbp-8]
    2ff: or      rax,[rbp-48h]
    303: mov     [rbp-8],rax
    307: mov     rax,[rbp-38h]
    30b: add     rax,2
    30f: mov     [rbp-38h],rax
    313: jmp     130h
    318: mov     rax,[rbp+18h]
    31c: mov     [rbp-60h],rax
    320: mov     rax,[rbp-58h]
    324: mov     [rbp-0C0h],rax
    32b: mov     rax,[rbp-60h]
    32f: mov     [rbp-0B8h],rax
    336: mov     edi,0FFFFFF50h
    33b: lea     rsi,[k4]
    342: call    ryo_h_AddrAbs
    347: call    fn5
    34c: nop     [rcx-30h]
    353: mov     rax,[rbp+18h]
    357: mov     [rbp-60h],rax
    35b: mov     rax,[rbp-58h]
    35f: cmp     rax,[rbp-60h]
    363: setb    [rbp-3Bh]
    367: mov     rax,[rbp+10h]
    36b: imul    rcx,[rbp-58h],1
    370: add     rax,rcx
    373: mov     [rbp-80h],rax
    377: mov     rax,[rbp-80h]
    37b: mov     [rbp-30h],rax
    37f: mov     rax,[rbp-30h]
    383: movzx   eax,byte ptr [rax]
    386: mov     [rbp-3Ah],al
    389: mov     edi,0FFFFFFB0h
    38e: mov     esi,0FFFFFFC6h
    393: call    ryo_h_ZextW8W64
    398: mov     rax,[rbp-38h]
    39c: mov     [rbp-60h],rax
    3a0: imul    rax,[rbp-60h],8
    3a5: mov     [rbp-58h],rax
    3a9: mov     edi,0FFFFFFB8h
    3ae: mov     esi,0FFFFFFB0h
    3b3: mov     edx,0FFFFFFA8h
    3b8: call    ryo_h_ShlW64
    3bd: mov     rax,[rbp-8]
    3c1: or      rax,[rbp-48h]
    3c5: mov     [rbp-8],rax
    3c9: mov     rax,[rbp-38h]
    3cd: add     rax,1
    3d1: mov     [rbp-38h],rax
    3d5: jmp     170h

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
     1f: mov     rax,[rbp-78h]
     23: and     rax,3
     27: mov     [rbp-80h],rax
     2b: mov     edi,0FFFFFF80h
     30: xor     esi,esi
     32: mov     edx,4
     37: call    ryo_h_SwitchDenseW64
     3c: lea     rcx,[4Ch]
     43: movsxd  rax,[rcx+rax*4]
     47: add     rax,rcx
     4a: jmp     rax
     4c: .long   108h
     50: .long   cch
     54: .long   172h
     58: .long   13ah
     5c: .long   60h
     60: mov     edi,0FFFFFF40h
     65: lea     rsi,[k0]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-0B8h],28h
     7c: mov     edi,0FFFFFF50h
     81: lea     rsi,[k1]
     88: call    ryo_h_AddrAbs
     8d: lea     rdi,[sym2]
     94: lea     rsi,[site3]
     9b: mov     edx,0FFFFFF58h
     a0: call    ryo_h_CallExt
     a5: test    rax,rax
     a8: je      0B5h
     aa: call    rax
     ac: nop     [rcx-20h]
     b3: jmp     0C5h
     b5: mov     rdi,rbp
     b8: lea     rsi,[ro+4]
     bf: call    qword ptr [sym4]
     c5: call    ryo_h_Unreachable
     ca: ud2
     cc: mov     rax,[rbp+10h]
     d0: mov     [rbp-98h],rax
     d7: mov     rax,[rbp+10h]
     db: mov     [rbp-0A0h],rax
     e2: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     ed: mov     rax,[rbp-0A0h]
     f4: imul    rcx,[rbp-0A8h],1
     fc: add     rax,rcx
     ff: mov     [rbp-68h],rax
    103: jmp     2B3h
    108: mov     rax,[rbp+10h]
    10c: mov     [rbp-30h],rax
    110: mov     rax,[rbp+10h]
    114: mov     [rbp-90h],rax
    11b: mov     rax,[rbp-30h]
    11f: mov     [rbp-88h],rax
    126: mov     rax,[rbp-88h]
    12d: mov     [rbp-8],rax
    131: mov     byte ptr [rbp-10h],2
    135: jmp     310h
    13a: mov     rax,[rbp-78h]
    13e: shr     rax,20h
    142: mov     [rbp-90h],rax
    149: mov     edi,0FFFFFF7Ch
    14e: mov     esi,0FFFFFF70h
    153: call    ryo_h_TruncW64W32
    158: mov     eax,[rbp-84h]
    15e: mov     [rbp-0C0h],eax
    164: call    fn5
    169: nop     [rcx-86h]
    170: jmp     1B0h
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-98h],rax
    17d: mov     rax,[rbp-98h]
    184: sar     rax,20h
    188: mov     [rbp-90h],rax
    18f: mov     edi,0FFFFFF7Ch
    194: mov     esi,0FFFFFF70h
    199: call    ryo_h_TruncW64W32
    19e: mov     eax,[rbp-84h]
    1a4: mov     [rbp-0Ch],eax
    1a7: mov     byte ptr [rbp-10h],0
    1ab: jmp     310h
    1b0: mov     edi,0FFFFFF5Ch
    1b5: mov     esi,0FFFFFF7Ah
    1ba: mov     edx,0FFh
    1bf: xor     ecx,ecx
    1c1: xor     r8d,r8d
    1c4: mov     r9d,1
    1ca: call    ryo_h_DiscrNicheW8
    1cf: mov     edi,0FFFFFF70h
    1d4: mov     esi,0FFFFFF5Ch
    1d9: call    ryo_h_ZextW32W64
    1de: mov     edi,0FFFFFF70h
    1e3: xor     esi,esi
    1e5: mov     edx,2
    1ea: call    ryo_h_SwitchDenseW64
    1ef: lea     rcx,[200h]
    1f6: movsxd  rax,[rcx+rax*4]
    1fa: add     rax,rcx
    1fd: jmp     rax
    1ff: int3
    200: .long   277h
    204: .long   296h
    208: .long   270h
    20c: nop     [rax]
    210: mov     rax,[rbp-90h]
    217: mov     [rbp-8],rax
    21b: mov     byte ptr [rbp-10h],3
    21f: nop
    220: mov     edi,0FFFFFFF0h
    225: mov     esi,10h
    22a: call    ryo_h_Ret
    22f: leave
    230: ret
    231: nop     [rax+rax]
    23a: nop     [rax+rax]
    240: mov     edi,0FFFFFF90h
    245: call    ryo_h_Resume
    24a: ud2
    24c: nop     [rax]
    250: jmp     240h
    252: nop     [rax+rax]
    25b: nop     [rax+rax]
    260: test    byte ptr [rbp-21h],0FFh
    264: je      240h
    266: jmp     250h
    268: nop     [rax+rax]
    270: call    ryo_h_Unreachable
    275: ud2
    277: mov     edi,0FFFFFF40h
    27c: lea     rsi,[k6]
    283: call    ryo_h_AddrAbs
    288: call    fn7
    28d: nop     [rcx-58h]
    294: jmp     270h
    296: movzx   eax,byte ptr [rbp-86h]
    29d: mov     [rbp-85h],al
    2a3: movzx   eax,byte ptr [rbp-85h]
    2aa: mov     [rbp-0Fh],al
    2ad: mov     byte ptr [rbp-10h],1
    2b1: jmp     310h
    2b3: mov     rax,[rbp-68h]
    2b7: mov     [rbp-90h],rax
    2be: mov     rax,[rbp+10h]
    2c2: mov     [rbp-98h],rax
    2c9: mov     rax,[rbp-68h]
    2cd: mov     [rbp-0A0h],rax
    2d4: mov     rax,[rbp-68h]
    2d8: mov     [rbp-88h],rax
    2df: mov     byte ptr [rbp-21h],0
    2e3: mov     rax,[rbp-88h]
    2ea: mov     [rbp-98h],rax
    2f1: mov     rax,[rbp-98h]
    2f8: mov     [rbp-0C0h],rax
    2ff: call    fn8
    304: nop     [rcx-90h]
    30b: jmp     210h
    310: jmp     220h
    315: mov     rdi,rax
    318: mov     esi,0FFFFFF90h
    31d: call    ryo_h_Lpad
    322: jmp     260h

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-21h],1
      f: mov     rax,[rbp+10h]
     13: mov     [rbp-18h],rax
     17: mov     rax,[rbp+10h]
     1b: mov     [rbp-78h],rax
     1f: mov     rax,[rbp-78h]
     23: and     rax,3
     27: mov     [rbp-80h],rax
     2b: mov     edi,0FFFFFF80h
     30: xor     esi,esi
     32: mov     edx,4
     37: call    ryo_h_SwitchDenseW64
     3c: lea     rcx,[4Ch]
     43: movsxd  rax,[rcx+rax*4]
     47: add     rax,rcx
     4a: jmp     rax
     4c: .long   108h
     50: .long   cch
     54: .long   172h
     58: .long   13ah
     5c: .long   60h
     60: mov     edi,0FFFFFF40h
     65: lea     rsi,[k0]
     6c: call    ryo_h_AddrAbs
     71: mov     qword ptr [rbp-0B8h],28h
     7c: mov     edi,0FFFFFF50h
     81: lea     rsi,[k1]
     88: call    ryo_h_AddrAbs
     8d: lea     rdi,[sym2]
     94: lea     rsi,[site3]
     9b: mov     edx,0FFFFFF58h
     a0: call    ryo_h_CallExt
     a5: test    rax,rax
     a8: je      0B5h
     aa: call    rax
     ac: nop     [rcx-20h]
     b3: jmp     0C5h
     b5: mov     rdi,rbp
     b8: lea     rsi,[ro+4]
     bf: call    qword ptr [sym4]
     c5: call    ryo_h_Unreachable
     ca: ud2
     cc: mov     rax,[rbp+10h]
     d0: mov     [rbp-98h],rax
     d7: mov     rax,[rbp+10h]
     db: mov     [rbp-0A0h],rax
     e2: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     ed: mov     rax,[rbp-0A0h]
     f4: imul    rcx,[rbp-0A8h],1
     fc: add     rax,rcx
     ff: mov     [rbp-68h],rax
    103: jmp     2B3h
    108: mov     rax,[rbp+10h]
    10c: mov     [rbp-30h],rax
    110: mov     rax,[rbp+10h]
    114: mov     [rbp-90h],rax
    11b: mov     rax,[rbp-30h]
    11f: mov     [rbp-88h],rax
    126: mov     rax,[rbp-88h]
    12d: mov     [rbp-8],rax
    131: mov     byte ptr [rbp-10h],2
    135: jmp     310h
    13a: mov     rax,[rbp-78h]
    13e: shr     rax,20h
    142: mov     [rbp-90h],rax
    149: mov     edi,0FFFFFF7Ch
    14e: mov     esi,0FFFFFF70h
    153: call    ryo_h_TruncW64W32
    158: mov     eax,[rbp-84h]
    15e: mov     [rbp-0C0h],eax
    164: call    fn5
    169: nop     [rcx-86h]
    170: jmp     1B0h
    172: mov     rax,[rbp-78h]
    176: mov     [rbp-98h],rax
    17d: mov     rax,[rbp-98h]
    184: sar     rax,20h
    188: mov     [rbp-90h],rax
    18f: mov     edi,0FFFFFF7Ch
    194: mov     esi,0FFFFFF70h
    199: call    ryo_h_TruncW64W32
    19e: mov     eax,[rbp-84h]
    1a4: mov     [rbp-0Ch],eax
    1a7: mov     byte ptr [rbp-10h],0
    1ab: jmp     310h
    1b0: mov     edi,0FFFFFF5Ch
    1b5: mov     esi,0FFFFFF7Ah
    1ba: mov     edx,0FFh
    1bf: xor     ecx,ecx
    1c1: xor     r8d,r8d
    1c4: mov     r9d,1
    1ca: call    ryo_h_DiscrNicheW8
    1cf: mov     edi,0FFFFFF70h
    1d4: mov     esi,0FFFFFF5Ch
    1d9: call    ryo_h_ZextW32W64
    1de: mov     edi,0FFFFFF70h
    1e3: xor     esi,esi
    1e5: mov     edx,2
    1ea: call    ryo_h_SwitchDenseW64
    1ef: lea     rcx,[200h]
    1f6: movsxd  rax,[rcx+rax*4]
    1fa: add     rax,rcx
    1fd: jmp     rax
    1ff: int3
    200: .long   277h
    204: .long   296h
    208: .long   270h
    20c: nop     [rax]
    210: mov     rax,[rbp-90h]
    217: mov     [rbp-8],rax
    21b: mov     byte ptr [rbp-10h],3
    21f: nop
    220: mov     edi,0FFFFFFF0h
    225: mov     esi,10h
    22a: call    ryo_h_Ret
    22f: leave
    230: ret
    231: nop     [rax+rax]
    23a: nop     [rax+rax]
    240: mov     edi,0FFFFFF90h
    245: call    ryo_h_Resume
    24a: ud2
    24c: nop     [rax]
    250: jmp     240h
    252: nop     [rax+rax]
    25b: nop     [rax+rax]
    260: test    byte ptr [rbp-21h],0FFh
    264: je      240h
    266: jmp     250h
    268: nop     [rax+rax]
    270: call    ryo_h_Unreachable
    275: ud2
    277: mov     edi,0FFFFFF40h
    27c: lea     rsi,[k6]
    283: call    ryo_h_AddrAbs
    288: call    fn7
    28d: nop     [rcx-58h]
    294: jmp     270h
    296: movzx   eax,byte ptr [rbp-86h]
    29d: mov     [rbp-85h],al
    2a3: movzx   eax,byte ptr [rbp-85h]
    2aa: mov     [rbp-0Fh],al
    2ad: mov     byte ptr [rbp-10h],1
    2b1: jmp     310h
    2b3: mov     rax,[rbp-68h]
    2b7: mov     [rbp-90h],rax
    2be: mov     rax,[rbp+10h]
    2c2: mov     [rbp-98h],rax
    2c9: mov     rax,[rbp-68h]
    2cd: mov     [rbp-0A0h],rax
    2d4: mov     rax,[rbp-68h]
    2d8: mov     [rbp-88h],rax
    2df: mov     byte ptr [rbp-21h],0
    2e3: mov     rax,[rbp-88h]
    2ea: mov     [rbp-98h],rax
    2f1: mov     rax,[rbp-98h]
    2f8: mov     [rbp-0C0h],rax
    2ff: call    fn8
    304: nop     [rcx-90h]
    30b: jmp     210h
    310: jmp     220h
    315: mov     rdi,rax
    318: mov     esi,0FFFFFF90h
    31d: call    ryo_h_Lpad
    322: jmp     260h

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     qword ptr [rbp-28h],0
     1b: lea     rax,[rbp-30h]
     1f: mov     [rbp-50h],rax
     23: mov     rax,[rbp-50h]
     27: mov     [rbp-48h],rax
     2b: mov     edi,0FFFFFFC0h
     30: lea     rsi,[k0]
     37: call    ryo_h_AddrAbs
     3c: mov     edi,0FFFFFF40h
     41: mov     esi,0FFFFFFB8h
     46: call    ryo_h_MovW128
     4b: mov     edi,0FFFFFF50h
     50: mov     esi,18h
     55: call    ryo_h_MovW128
     5a: lea     rdi,[sym1]
     61: lea     rsi,[site2]
     68: mov     edx,0FFFFFF60h
     6d: call    ryo_h_CallExt
     72: test    rax,rax
     75: je      82h
     77: call    rax
     79: nop     [rcx-31h]
     80: jmp     92h
     82: mov     rdi,rbp
     85: lea     rsi,[ro+4]
     8c: call    qword ptr [sym3]
     92: mov     edi,0FFFFFFF0h
     97: mov     esi,0FFFFFFCFh
     9c: call    ryo_h_ZextW8W64
     a1: mov     edi,0FFFFFFF0h
     a6: xor     esi,esi
     a8: mov     edx,2
     ad: call    ryo_h_SwitchDenseW64
     b2: lea     rcx,[0C4h]
     b9: movsxd  rax,[rcx+rax*4]
     bd: add     rax,rcx
     c0: jmp     rax
     c2: int3
     c3: int3
     c4: .long   11dh
     c8: .long   d7h
     cc: .long   d0h
     d0: call    ryo_h_Unreachable
     d5: ud2
     d7: mov     edi,0FFFFFF64h
     dc: mov     esi,0FFFFFFD8h
     e1: xor     edx,edx
     e3: xor     ecx,ecx
     e5: xor     r8d,r8d
     e8: mov     r9d,1
     ee: call    ryo_h_DiscrNicheW64
     f3: mov     edi,0FFFFFFC0h
     f8: mov     esi,0FFFFFF64h
     fd: call    ryo_h_ZextW32W64
    102: cmp     qword ptr [rbp-40h],0
    107: sete    [rbp-33h]
    10b: movzx   eax,byte ptr [rbp-33h]
    10f: xor     al,1
    112: mov     [rbp-32h],al
    115: test    byte ptr [rbp-32h],0FFh
    119: je      15Ch
    11b: jmp     14Fh
    11d: mov     qword ptr [rbp-8],0
    125: lea     rax,[rbp-28h]
    129: mov     [rbp-0A0h],rax
    130: mov     rax,[rbp-0A0h]
    137: mov     [rbp-0C0h],rax
    13e: call    fn4
    143: nop     [rcx-0A0h]
    14a: jmp     251h
    14f: mov     rax,[rbp-28h]
    153: mov     [rbp-8],rax
    157: jmp     251h
    15c: mov     edi,0FFFFFFA0h
    161: lea     rsi,[k5]
    168: call    ryo_h_AddrAbs
    16d: mov     qword ptr [rbp-58h],56h
    175: mov     rax,[rbp-60h]
    179: mov     [rbp-80h],rax
    17d: mov     rax,[rbp-58h]
    181: mov     [rbp-78h],rax
    185: mov     rax,[rbp-80h]
    189: mov     [rbp-70h],rax
    18d: mov     rax,[rbp-70h]
    191: mov     [rbp-68h],rax
    195: mov     edi,0FFFFFF68h
    19a: lea     rsi,[k6]
    1a1: call    ryo_h_AddrAbs
    1a6: mov     qword ptr [rbp-90h],56h
    1b1: mov     rax,[rbp-90h]
    1b8: mov     [rbp-88h],rax
    1bf: mov     rax,[rbp-88h]
    1c6: shl     rax,1
    1ca: mov     [rbp-80h],rax
    1ce: mov     rax,[rbp-80h]
    1d2: or      rax,1
    1d6: mov     [rbp-78h],rax
    1da: mov     rax,[rbp-78h]
    1de: mov     [rbp-70h],rax
    1e2: mov     rax,[rbp-68h]
    1e6: mov     [rbp-48h],rax
    1ea: mov     rax,[rbp-70h]
    1ee: mov     [rbp-40h],rax
    1f2: mov     edi,0FFFFFF40h
    1f7: mov     esi,0FFFFFFB8h
    1fc: call    ryo_h_MovW128
    201: mov     edi,0FFFFFF50h
    206: lea     rsi,[k7]
    20d: call    ryo_h_AddrAbs
    212: lea     rdi,[sym8]
    219: lea     rsi,[site9]
    220: mov     edx,0FFFFFF60h
    225: call    ryo_h_CallExt
    22a: test    rax,rax
    22d: je      23Ah
    22f: call    rax
    231: nop     [rcx-18h]
    238: jmp     24Ah
    23a: mov     rdi,rbp
    23d: lea     rsi,[ro+20]
    244: call    qword ptr [sym10]
    24a: call    ryo_h_Unreachable
    24f: ud2
    251: mov     edi,0FFFFFFF8h
    256: mov     esi,8
    25b: call    ryo_h_Ret
    260: leave
    261: ret
    262: nop     [rax+rax]
    26b: nop     [rax+rax]
    270: lea     rax,[rbp-30h]
    274: mov     [rbp-0A0h],rax
    27b: mov     rax,[rbp-0A0h]
    282: mov     [rbp-0C0h],rax
    289: call    fn11
    28e: nop     [rcx-0A0h]
    295: mov     edi,0FFFFFFE0h
    29a: call    ryo_h_Resume
    29f: ud2
    2a1: nop     [rax+rax]
    2aa: nop     [rax+rax]
    2b0: lea     rdi,[sym12]
    2b7: lea     rsi,[site13]
    2be: mov     edx,0FFFFFF60h
    2c3: call    ryo_h_CallExt
    2c8: test    rax,rax
    2cb: je      2D8h
    2cd: call    rax
    2cf: nop     [rcx-98h]
    2d6: jmp     2E8h
    2d8: mov     rdi,rbp
    2db: lea     rsi,[ro+36]
    2e2: call    qword ptr [sym14]
    2e8: call    ryo_h_Unreachable
    2ed: ud2
    2ef: mov     rdi,rax
    2f2: mov     esi,0FFFFFFE0h
    2f7: call    ryo_h_Lpad
    2fc: jmp     270h
    301: mov     rdi,rax
    304: mov     esi,0FFFFFFE0h
    309: call    ryo_h_Lpad
    30e: jmp     2B0h

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
     2f: je      119h
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
     66: mov     rax,[rbp-38h]
     6a: mov     [rbp-30h],rax
     6e: mov     edi,0FFFFFFA0h
     73: lea     rsi,[k1]
     7a: call    ryo_h_AddrAbs
     7f: mov     qword ptr [rbp-58h],0B8h
     87: mov     rax,[rbp-58h]
     8b: mov     [rbp-50h],rax
     8f: mov     rax,[rbp-50h]
     93: shl     rax,1
     97: mov     [rbp-48h],rax
     9b: mov     rax,[rbp-48h]
     9f: or      rax,1
     a3: mov     [rbp-40h],rax
     a7: mov     rax,[rbp-40h]
     ab: mov     [rbp-38h],rax
     af: mov     rax,[rbp-30h]
     b3: mov     [rbp-28h],rax
     b7: mov     rax,[rbp-38h]
     bb: mov     [rbp-20h],rax
     bf: mov     edi,0FFFFFF70h
     c4: mov     esi,0FFFFFFD8h
     c9: call    ryo_h_MovW128
     ce: mov     byte ptr [rbp-80h],0
     d2: mov     rax,[rbp+18h]
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
     2f: je      119h
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
     66: mov     rax,[rbp-38h]
     6a: mov     [rbp-30h],rax
     6e: mov     edi,0FFFFFFA0h
     73: lea     rsi,[k1]
     7a: call    ryo_h_AddrAbs
     7f: mov     qword ptr [rbp-58h],0B8h
     87: mov     rax,[rbp-58h]
     8b: mov     [rbp-50h],rax
     8f: mov     rax,[rbp-50h]
     93: shl     rax,1
     97: mov     [rbp-48h],rax
     9b: mov     rax,[rbp-48h]
     9f: or      rax,1
     a3: mov     [rbp-40h],rax
     a7: mov     rax,[rbp-40h]
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
     17: cmp     qword ptr [rbp-30h],0
     1c: sete    [rbp-21h]
     20: test    byte ptr [rbp-21h],0FFh
     24: je      30h
     26: mov     qword ptr [rbp-8],0
     2e: jmp     70h
     30: mov     rax,[rbp+10h]
     34: lea     rax,[rax+20h]
     38: mov     [rbp-38h],rax
     3c: mov     rax,[rbp-38h]
     40: mov     [rbp-0A0h],rax
     47: mov     rax,[rbp+18h]
     4b: mov     [rbp-98h],rax
     52: call    fn0
     57: nop     [rcx-30h]
     5e: jmp     81h
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
    135: je      17Bh
    137: jmp     171h
    139: nop     [rax]
    140: mov     rax,[rbp-68h]
    144: mov     [rbp-60h],rax
    148: mov     rax,[rbp-60h]
    14c: mov     [rbp-38h],rax
    150: mov     rax,[rbp-38h]
    154: mov     [rbp-18h],rax
    158: mov     rax,[rbp-18h]
    15c: lea     rax,[rax+8]
    160: mov     [rbp-40h],rax
    164: mov     rax,[rbp-40h]
    168: mov     [rbp-8],rax
    16c: jmp     70h
    171: mov     qword ptr [rbp-68h],8
    179: jmp     140h
    17b: mov     rax,[rbp-78h]
    17f: mov     [rbp-70h],rax
    183: mov     byte ptr [rbp-79h],0
    187: test    byte ptr [rbp-79h],0FFh
    18b: je      19Ch
    18d: jmp     192h
    18f: nop
    190: jmp     140h
    192: mov     rax,[rbp-70h]
    196: mov     [rbp-68h],rax
    19a: jmp     190h
    19c: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    1a4: mov     rax,[rbp-70h]
    1a8: imul    rcx,[rbp-80h],10h
    1ad: add     rax,rcx
    1b0: mov     [rbp-68h],rax
    1b4: jmp     190h

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::iter
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-0A0h],rax
     19: mov     rax,[rbp-0A0h]
     20: mov     [rbp-70h],rax
     24: mov     byte ptr [rbp-0B1h],0
     2b: test    byte ptr [rbp-0B1h],0FFh
     32: je      0A0h
     34: jmp     93h
     36: nop     [rax+rax]
     3f: nop
     40: mov     rax,[rbp+10h]
     44: mov     rax,[rax+18h]
     48: mov     [rbp-90h],rax
     4f: mov     edi,0FFFFFFA0h
     54: mov     esi,0FFFFFF78h
     59: mov     edx,20h
     5e: call    ryo_h_Copy
     63: mov     rax,[rbp-90h]
     6a: mov     [rbp-40h],rax
     6e: mov     edi,0FFFFFFD8h
     73: mov     esi,0FFFFFFA0h
     78: mov     edx,28h
     7d: call    ryo_h_Copy
     82: mov     edi,0FFFFFFD8h
     87: mov     esi,28h
     8c: call    ryo_h_Ret
     91: leave
     92: ret
     93: mov     qword ptr [rbp-0A8h],1
     9e: jmp     0AEh
     a0: mov     rax,[rbp-0A0h]
     a7: mov     [rbp-0A8h],rax
     ae: mov     rax,[rbp-0A8h]
     b5: mov     [rbp-78h],rax
     b9: mov     rax,[rbp-78h]
     bd: mov     [rbp-68h],rax
     c1: mov     rax,[rbp+10h]
     c5: mov     rax,[rax]
     c8: mov     [rbp-98h],rax
     cf: mov     rax,[rbp-98h]
     d6: mov     [rbp-90h],rax
     dd: mov     rax,[rbp+10h]
     e1: mov     rax,[rax+8]
     e5: mov     [rbp-0B0h],rax
     ec: mov     rax,[rbp-0B0h]
     f3: add     rax,1
     f7: mov     [rbp-98h],rax
     fe: mov     rax,[rbp-90h]
    105: mov     [rbp-0C8h],rax
    10c: mov     rax,[rbp-68h]
    110: mov     [rbp-0D0h],rax
    117: mov     rax,[rbp-98h]
    11e: mov     [rbp-0C0h],rax
    125: call    fn0
    12a: nop     [rcx-88h]
    131: jmp     40h

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0F0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-0A0h],rax
     19: mov     rax,[rbp-0A0h]
     20: mov     [rbp-70h],rax
     24: mov     byte ptr [rbp-0C9h],0
     2b: test    byte ptr [rbp-0C9h],0FFh
     32: je      154h
     38: jmp     147h
     3d: nop     [rax]
     40: mov     rax,[rbp-68h]
     44: mov     [rbp-98h],rax
     4b: cmp     qword ptr [rbp-98h],0
     53: je      1EAh
     59: jmp     1FAh
     5e: xchg    ax,ax
     60: call    ryo_h_Unreachable
     65: ud2
     67: mov     rax,[rbp-90h]
     6e: mov     [rbp-98h],rax
     75: mov     byte ptr [rbp-0C9h],0
     7c: test    byte ptr [rbp-0C9h],0FFh
     83: je      330h
     89: jmp     320h
     8e: xchg    ax,ax
     90: jmp     0E3h
     92: nop     [rax+rax]
     9b: nop     [rax+rax]
     a0: test    byte ptr [rbp-0A9h],0FFh
     a7: je      0ABh
     a9: jmp     0DEh
     ab: mov     rax,[rbp+10h]
     af: mov     [rbp-0B8h],rax
     b6: mov     rax,[rbp-0B8h]
     bd: mov     [rbp-0F0h],rax
     c4: mov     rax,[rbp-98h]
     cb: mov     [rbp-0E8h],rax
     d2: call    fn0
     d7: nop     [rcx-48h]
     de: jmp     40h
     e3: xor     edi,edi
     e5: xor     esi,esi
     e7: call    ryo_h_Ret
     ec: leave
     ed: ret
     ee: xchg    ax,ax
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
    16d: mov     rax,[rbp-78h]
    171: mov     [rbp-68h],rax
    175: mov     rax,[rbp+10h]
    179: mov     rax,[rax]
    17c: mov     [rbp-98h],rax
    183: mov     rax,[rbp-98h]
    18a: mov     [rbp-90h],rax
    191: mov     rax,[rbp+10h]
    195: mov     rax,[rax+8]
    199: mov     [rbp-0B0h],rax
    1a0: mov     rax,[rbp-0B0h]
    1a7: add     rax,1
    1ab: mov     [rbp-98h],rax
    1b2: mov     rax,[rbp-90h]
    1b9: mov     [rbp-0E8h],rax
    1c0: mov     rax,[rbp-68h]
    1c4: mov     [rbp-0F0h],rax
    1cb: mov     rax,[rbp-98h]
    1d2: mov     [rbp-0E0h],rax
    1d9: call    fn1
    1de: nop     [rcx-88h]
    1e5: jmp     100h
    1ea: mov     qword ptr [rbp-90h],0
    1f5: jmp     90h
    1fa: lea     rax,[rbp-88h]
    201: mov     [rbp-98h],rax
    208: mov     rax,[rbp-98h]
    20f: mov     [rbp-0F0h],rax
    216: call    fn2
    21b: nop     [rcx-90h]
    222: mov     rax,[rbp-68h]
    226: sub     rax,1
    22a: mov     [rbp-68h],rax
    22e: mov     edi,0FFFFFF34h
    233: mov     esi,0FFFFFF70h
    238: xor     edx,edx
    23a: xor     ecx,ecx
    23c: xor     r8d,r8d
    23f: mov     r9d,1
    245: call    ryo_h_DiscrNicheW64
    24a: mov     edi,0FFFFFFC0h
    24f: mov     esi,0FFFFFF34h
    254: call    ryo_h_ZextW32W64
    259: mov     edi,0FFFFFFC0h
    25e: xor     esi,esi
    260: mov     edx,2
    265: call    ryo_h_SwitchDenseW64
    26a: lea     rcx,[27Ch]
    271: movsxd  rax,[rcx+rax*4]
    275: add     rax,rcx
    278: jmp     rax
    27a: int3
    27b: int3
    27c: .long   90h
    280: .long   67h
    284: .long   60h
    288: nop     [rax+rax]
    290: mov     rax,[rbp-0A0h]
    297: mov     [rbp-0B0h],rax
    29e: mov     rax,[rbp-0B0h]
    2a5: mov     [rbp-0A0h],rax
    2ac: mov     rax,[rbp-0B0h]
    2b3: lea     rax,[rax+8]
    2b7: mov     [rbp-0A8h],rax
    2be: lea     rax,[rbp+18h]
    2c2: mov     [rbp-0B8h],rax
    2c9: mov     rax,[rbp-0A0h]
    2d0: mov     [rbp-0C8h],rax
    2d7: mov     rax,[rbp-0A8h]
    2de: mov     [rbp-0C0h],rax
    2e5: mov     rax,[rbp-0B8h]
    2ec: mov     [rbp-0F0h],rax
    2f3: mov     rax,[rbp-0C8h]
    2fa: mov     [rbp-0E8h],rax
    301: mov     rax,[rbp-0C0h]
    308: mov     [rbp-0E0h],rax
    30f: call    fn3
    314: nop     [rcx-0A9h]
    31b: jmp     0A0h
    320: mov     qword ptr [rbp-0A0h],8
    32b: jmp     290h
    330: mov     rax,[rbp-98h]
    337: mov     [rbp-0B8h],rax
    33e: mov     rax,[rbp-0B8h]
    345: mov     [rbp-0A8h],rax
    34c: mov     byte ptr [rbp-0C9h],0
    353: test    byte ptr [rbp-0C9h],0FFh
    35a: je      375h
    35c: jmp     365h
    35e: xchg    ax,ax
    360: jmp     290h
    365: mov     rax,[rbp-0A8h]
    36c: mov     [rbp-0A0h],rax
    373: jmp     360h
    375: mov     qword ptr [rbp-0D0h],0FFFFFFFFFFFFFFFFh
    380: mov     rax,[rbp-0A8h]
    387: imul    rcx,[rbp-0D0h],10h
    38f: add     rax,rcx
    392: mov     [rbp-0A0h],rax
    399: jmp     360h
    39b: mov     rdi,rax
    39e: mov     esi,0FFFFFFA0h
    3a3: call    ryo_h_Lpad
    3a8: jmp     0F0h

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
     1f: movzx   eax,word ptr [rbp-0ACh]
     26: mov     [rbp-92h],ax
     2d: mov     edi,0FFFFFF50h
     32: mov     esi,0FFFFFF6Eh
     37: xor     edx,edx
     39: xor     ecx,ecx
     3b: xor     r8d,r8d
     3e: mov     r9d,1
     44: call    ryo_h_DiscrNicheW16
     49: mov     edi,0FFFFFF60h
     4e: mov     esi,0FFFFFF50h
     53: call    ryo_h_ZextW32W64
     58: mov     edi,0FFFFFF60h
     5d: xor     esi,esi
     5f: mov     edx,2
     64: call    ryo_h_SwitchDenseW64
     69: lea     rcx,[7Ch]
     70: movsxd  rax,[rcx+rax*4]
     74: add     rax,rcx
     77: jmp     rax
     79: int3
     7a: int3
     7b: int3
     7c: .long   cbh
     80: .long   8fh
     84: .long   88h
     88: call    ryo_h_Unreachable
     8d: ud2
     8f: movzx   eax,word ptr [rbp-92h]
     96: mov     [rbp-94h],ax
     9d: movzx   eax,word ptr [rbp-94h]
     a4: mov     [rbp-0AAh],ax
     ab: mov     edi,0FFFFFF50h
     b0: mov     esi,0FFFFFF56h
     b5: call    ryo_h_CttzW16
     ba: mov     eax,[rbp-0B0h]
     c0: mov     [rbp-98h],eax
     c6: jmp     1A8h
     cb: mov     edi,0FFFFFF70h
     d0: lea     rsi,[k0]
     d7: mov     edx,10h
     dc: call    ryo_h_Const
     e1: mov     qword ptr [rbp-88h],0
     ec: cmp     qword ptr [rbp-88h],0
     f4: sete    [rbp-89h]
     fb: mov     rax,[rbp+10h]
     ff: mov     rax,[rax]
    102: mov     [rbp-90h],rax
    109: mov     rax,[rbp-90h]
    110: mov     [rbp-88h],rax
    117: mov     qword ptr [rbp-0B8h],10h
    122: mov     rax,[rbp-88h]
    129: imul    rcx,[rbp-0B8h],1
    131: add     rax,rcx
    134: mov     [rbp-80h],rax
    138: mov     rax,[rbp-80h]
    13c: mov     [rbp-78h],rax
    140: mov     rax,[rbp+10h]
    144: mov     rcx,[rbp-78h]
    148: mov     [rax],rcx
    14b: mov     rax,[rbp+10h]
    14f: mov     rax,[rax]
    152: mov     [rbp-28h],rax
    156: mov     rax,[rbp-28h]
    15a: mov     [rbp-88h],rax
    161: mov     rax,[rbp-28h]
    165: mov     [rbp-80h],rax
    169: mov     rax,[rbp-28h]
    16d: mov     [rbp-88h],rax
    174: mov     rax,[rbp-88h]
    17b: mov     [rbp-0D0h],rax
    182: mov     edi,0FFFFFF48h
    187: lea     rsi,[sym1]
    18e: call    ryo_h_AddrSym
    193: mov     rdi,rbp
    196: lea     rsi,[ro+4]
    19d: call    qword ptr [sym2]
    1a3: jmp     290h
    1a8: mov     edi,0FFFFFF58h
    1ad: mov     esi,0FFFFFF68h
    1b2: call    ryo_h_ZextW32W64
    1b7: mov     rax,[rbp-0A8h]
    1be: mov     [rbp-88h],rax
    1c5: mov     qword ptr [rbp-90h],1
    1d0: mov     rax,[rbp-88h]
    1d7: mov     [rbp-40h],rax
    1db: mov     rax,[rbp+10h]
    1df: movzx   eax,word ptr [rax+18h]
    1e3: mov     [rbp-88h],ax
    1ea: movzx   eax,word ptr [rbp-88h]
    1f1: sub     eax,1
    1f4: mov     [rbp-86h],ax
    1fb: movzx   eax,word ptr [rbp-88h]
    202: and     ax,[rbp-86h]
    209: mov     [rbp-84h],ax
    210: movzx   eax,word ptr [rbp-84h]
    217: mov     [rbp-82h],ax
    21e: mov     rax,[rbp+10h]
    222: movzx   ecx,word ptr [rbp-82h]
    229: mov     [rax+18h],cx
    22d: mov     rax,[rbp-40h]
    231: mov     [rbp-78h],rax
    235: mov     qword ptr [rbp-80h],1
    23d: mov     rax,[rbp-78h]
    241: mov     [rbp-88h],rax
    248: mov     rax,[rbp+10h]
    24c: mov     rax,[rax+8]
    250: mov     [rbp-98h],rax
    257: mov     rax,[rbp-98h]
    25e: add     rax,[rbp-88h]
    265: mov     [rbp-90h],rax
    26c: mov     rax,[rbp-90h]
    273: mov     [rbp-8],rax
    277: mov     qword ptr [rbp-10h],1
    27f: mov     edi,0FFFFFFF0h
    284: mov     esi,10h
    289: call    ryo_h_Ret
    28e: leave
    28f: ret
    290: mov     edi,0FFFFFF30h
    295: mov     esi,0FFFFFF90h
    29a: call    ryo_h_MovW128
    29f: mov     edi,0FFFFFF48h
    2a4: lea     rsi,[sym3]
    2ab: call    ryo_h_AddrSym
    2b0: mov     rdi,rbp
    2b3: lea     rsi,[ro+20]
    2ba: call    qword ptr [sym4]
    2c0: mov     edi,0FFFFFF88h
    2c5: mov     esi,0FFFFFF84h
    2ca: call    ryo_h_TruncW32W16
    2cf: mov     edi,0FFFFFF8Ah
    2d4: mov     esi,0FFFFFF88h
    2d9: call    ryo_h_NotW16
    2de: movzx   eax,word ptr [rbp-76h]
    2e2: mov     [rbp-74h],ax
    2e6: movzx   eax,word ptr [rbp-74h]
    2ea: mov     [rbp-72h],ax
    2ee: mov     rax,[rbp+10h]
    2f2: movzx   ecx,word ptr [rbp-72h]
    2f6: mov     [rax+18h],cx
    2fa: mov     rax,[rbp+10h]
    2fe: mov     rax,[rax+8]
    302: mov     [rbp-0B8h],rax
    309: mov     rax,[rbp-0B8h]
    310: add     rax,10h
    314: mov     [rbp-0C0h],rax
    31b: mov     rax,[rbp+10h]
    31f: mov     rcx,[rbp-0C0h]
    326: mov     [rax+8],rcx
    32a: jmp     10h

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
     34: mov     rax,[rbp-0A8h]
     3b: mov     [rbp-0C0h],rax
     42: mov     edi,0FFFFFF50h
     47: lea     rsi,[sym0]
     4e: call    ryo_h_AddrSym
     53: mov     rdi,rbp
     56: lea     rsi,[ro+4]
     5d: call    qword ptr [sym1]
     63: mov     edi,0FFFFFF40h
     68: mov     esi,0FFFFFF70h
     6d: call    ryo_h_MovW128
     72: mov     edi,0FFFFFF50h
     77: lea     rsi,[sym2]
     7e: call    ryo_h_AddrSym
     83: mov     rdi,rbp
     86: lea     rsi,[ro+20]
     8d: call    qword ptr [sym3]
     93: mov     edi,0FFFFFF64h
     98: mov     esi,0FFFFFF60h
     9d: call    ryo_h_TruncW32W16
     a2: mov     edi,0FFFFFF66h
     a7: mov     esi,0FFFFFF64h
     ac: call    ryo_h_NotW16
     b1: movzx   eax,word ptr [rbp-9Ah]
     b8: mov     [rbp-4Ch],ax
     bc: mov     qword ptr [rbp-0B0h],10h
     c7: mov     rax,[rbp+18h]
     cb: imul    rcx,[rbp-0B0h],1
     d3: add     rax,rcx
     d6: mov     [rbp-60h],rax
     da: movzx   eax,word ptr [rbp-4Ch]
     de: mov     [rbp-9Ah],ax
     e5: movzx   eax,word ptr [rbp-9Ah]
     ec: mov     [rbp-8],ax
     f0: mov     rax,[rbp+10h]
     f4: mov     [rbp-20h],rax
     f8: mov     rax,[rbp-60h]
     fc: mov     [rbp-18h],rax
    100: mov     rax,[rbp-98h]
    107: mov     [rbp-10h],rax
    10b: mov     edi,0FFFFFFE0h
    110: mov     esi,20h
    115: call    ryo_h_Ret
    11a: leave
    11b: ret

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: movzx   eax,word ptr [rax+18h]
     18: mov     [rbp-0ACh],ax
     1f: movzx   eax,word ptr [rbp-0ACh]
     26: mov     [rbp-92h],ax
     2d: mov     edi,0FFFFFF44h
     32: mov     esi,0FFFFFF6Eh
     37: xor     edx,edx
     39: xor     ecx,ecx
     3b: xor     r8d,r8d
     3e: mov     r9d,1
     44: call    ryo_h_DiscrNicheW16
     49: mov     edi,0FFFFFF60h
     4e: mov     esi,0FFFFFF44h
     53: call    ryo_h_ZextW32W64
     58: mov     edi,0FFFFFF60h
     5d: xor     esi,esi
     5f: mov     edx,2
     64: call    ryo_h_SwitchDenseW64
     69: lea     rcx,[7Ch]
     70: movsxd  rax,[rcx+rax*4]
     74: add     rax,rcx
     77: jmp     rax
     79: int3
     7a: int3
     7b: int3
     7c: .long   181h
     80: .long   148h
     84: .long   141h
     88: nop     [rax+rax]
     90: mov     rax,[rbp+10h]
     94: mov     rax,[rax+8]
     98: mov     [rbp-80h],rax
     9c: mov     rax,[rbp+10h]
     a0: mov     rax,[rax+10h]
     a4: mov     [rbp-88h],rax
     ab: mov     rax,[rbp-80h]
     af: cmp     rax,[rbp-88h]
     b6: jb      0D0h
     b8: mov     qword ptr [rbp-8],0
     c0: jmp     130h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp+10h]
     d4: mov     rax,[rax+8]
     d8: mov     [rbp-28h],rax
     dc: mov     rax,[rbp-28h]
     e0: mov     [rbp-80h],rax
     e4: mov     rax,[rbp-28h]
     e8: mov     [rbp-88h],rax
     ef: mov     rax,[rbp-88h]
     f6: mov     [rbp-0D0h],rax
     fd: mov     edi,0FFFFFF40h
    102: lea     rsi,[sym0]
    109: call    ryo_h_AddrSym
    10e: mov     rdi,rbp
    111: lea     rsi,[ro+4]
    118: call    qword ptr [sym1]
    11e: jmp     38Bh
    123: nop     [rax+rax]
    12c: nop     [rax]
    130: mov     edi,0FFFFFFF8h
    135: mov     esi,8
    13a: call    ryo_h_Ret
    13f: leave
    140: ret
    141: call    ryo_h_Unreachable
    146: ud2
    148: movzx   eax,word ptr [rbp-92h]
    14f: mov     [rbp-94h],ax
    156: movzx   eax,word ptr [rbp-94h]
    15d: mov     [rbp-0AAh],ax
    164: mov     edi,0FFFFFF44h
    169: mov     esi,0FFFFFF56h
    16e: call    ryo_h_CttzW16
    173: mov     eax,[rbp-0BCh]
    179: mov     [rbp-98h],eax
    17f: jmp     1CAh
    181: mov     edi,0FFFFFF70h
    186: lea     rsi,[k2]
    18d: mov     edx,10h
    192: call    ryo_h_Const
    197: mov     qword ptr [rbp-88h],0
    1a2: cmp     qword ptr [rbp-88h],0
    1aa: sete    [rbp-89h]
    1b1: mov     byte ptr [rbp-0B9h],0
    1b8: test    byte ptr [rbp-0B9h],0FFh
    1bf: je      0D0h
    1c5: jmp     90h
    1ca: mov     edi,0FFFFFF58h
    1cf: mov     esi,0FFFFFF68h
    1d4: call    ryo_h_ZextW32W64
    1d9: mov     rax,[rbp-0A8h]
    1e0: mov     [rbp-88h],rax
    1e7: mov     qword ptr [rbp-90h],1
    1f2: mov     rax,[rbp-88h]
    1f9: mov     [rbp-48h],rax
    1fd: mov     rax,[rbp+10h]
    201: movzx   eax,word ptr [rax+18h]
    205: mov     [rbp-88h],ax
    20c: movzx   eax,word ptr [rbp-88h]
    213: sub     eax,1
    216: mov     [rbp-86h],ax
    21d: movzx   eax,word ptr [rbp-88h]
    224: and     ax,[rbp-86h]
    22b: mov     [rbp-84h],ax
    232: movzx   eax,word ptr [rbp-84h]
    239: mov     [rbp-82h],ax
    240: mov     rax,[rbp+10h]
    244: movzx   ecx,word ptr [rbp-82h]
    24b: mov     [rax+18h],cx
    24f: mov     rax,[rbp-48h]
    253: mov     [rbp-78h],rax
    257: mov     qword ptr [rbp-80h],1
    25f: mov     rax,[rbp-78h]
    263: mov     [rbp-88h],rax
    26a: mov     byte ptr [rbp-0B9h],0
    271: test    byte ptr [rbp-0B9h],0FFh
    278: je      2C9h
    27a: mov     rax,[rbp+10h]
    27e: mov     rax,[rax]
    281: mov     [rbp-0B8h],rax
    288: mov     rax,[rbp-0B8h]
    28f: mov     [rbp-0B0h],rax
    296: mov     rax,[rbp-0B0h]
    29d: mov     [rbp-0A8h],rax
    2a4: mov     rax,[rbp-0A8h]
    2ab: add     rax,[rbp-88h]
    2b2: mov     [rbp-0A0h],rax
    2b9: mov     rax,[rbp-0A0h]
    2c0: mov     [rbp-98h],rax
    2c7: jmp     300h
    2c9: mov     rax,[rbp+10h]
    2cd: mov     rax,[rax]
    2d0: mov     [rbp-0A8h],rax
    2d7: mov     rax,[rbp-0A8h]
    2de: mov     [rbp-0A0h],rax
    2e5: mov     byte ptr [rbp-0B9h],0
    2ec: test    byte ptr [rbp-0B9h],0FFh
    2f3: je      342h
    2f5: jmp     332h
    2f7: nop     [rax+rax]
    300: mov     rax,[rbp-98h]
    307: mov     [rbp-0A0h],rax
    30e: mov     rax,[rbp-0A0h]
    315: mov     [rbp-90h],rax
    31c: mov     rax,[rbp-90h]
    323: mov     [rbp-8],rax
    327: jmp     130h
    32c: nop     [rax]
    330: jmp     300h
    332: mov     rax,[rbp-0A0h]
    339: mov     [rbp-98h],rax
    340: jmp     330h
    342: mov     rax,[rbp-88h]
    349: mov     [rbp-0B0h],rax
    350: mov     qword ptr [rbp-0C0h],0
    35b: mov     rax,[rbp-0C0h]
    362: sub     rax,[rbp-0B0h]
    369: mov     [rbp-0A8h],rax
    370: mov     rax,[rbp-0A0h]
    377: imul    rcx,[rbp-0A8h],20h
    37f: add     rax,rcx
    382: mov     [rbp-98h],rax
    389: jmp     330h
    38b: mov     edi,0FFFFFF30h
    390: mov     esi,0FFFFFF90h
    395: call    ryo_h_MovW128
    39a: mov     edi,0FFFFFF40h
    39f: lea     rsi,[sym3]
    3a6: call    ryo_h_AddrSym
    3ab: mov     rdi,rbp
    3ae: lea     rsi,[ro+20]
    3b5: call    qword ptr [sym4]
    3bb: mov     edi,0FFFFFF88h
    3c0: mov     esi,0FFFFFF84h
    3c5: call    ryo_h_TruncW32W16
    3ca: mov     edi,0FFFFFF8Ah
    3cf: mov     esi,0FFFFFF88h
    3d4: call    ryo_h_NotW16
    3d9: movzx   eax,word ptr [rbp-76h]
    3dd: mov     [rbp-74h],ax
    3e1: movzx   eax,word ptr [rbp-74h]
    3e5: mov     [rbp-72h],ax
    3e9: mov     rax,[rbp+10h]
    3ed: movzx   ecx,word ptr [rbp-72h]
    3f1: mov     [rax+18h],cx
    3f5: mov     byte ptr [rbp-0B9h],0
    3fc: test    byte ptr [rbp-0B9h],0FFh
    403: je      44Eh
    405: mov     rax,[rbp+10h]
    409: mov     rax,[rax]
    40c: mov     [rbp-0A0h],rax
    413: mov     rax,[rbp-0A0h]
    41a: mov     [rbp-98h],rax
    421: mov     rax,[rbp-98h]
    428: mov     [rbp-90h],rax
    42f: mov     rax,[rbp-90h]
    436: add     rax,10h
    43a: mov     [rbp-88h],rax
    441: mov     rax,[rbp-88h]
    448: mov     [rbp-80h],rax
    44c: jmp     480h
    44e: mov     rax,[rbp+10h]
    452: mov     rax,[rax]
    455: mov     [rbp-90h],rax
    45c: mov     rax,[rbp-90h]
    463: mov     [rbp-88h],rax
    46a: mov     byte ptr [rbp-0B9h],0
    471: test    byte ptr [rbp-0B9h],0FFh
    478: je      4EFh
    47a: jmp     4E2h
    47c: nop     [rax]
    480: mov     rax,[rbp-80h]
    484: mov     [rbp-88h],rax
    48b: mov     rax,[rbp-88h]
    492: mov     [rbp-78h],rax
    496: mov     rax,[rbp+10h]
    49a: mov     rcx,[rbp-78h]
    49e: mov     [rax],rcx
    4a1: mov     rax,[rbp+10h]
    4a5: mov     rax,[rax+8]
    4a9: mov     [rbp-80h],rax
    4ad: mov     qword ptr [rbp-0C0h],10h
    4b8: mov     rax,[rbp-80h]
    4bc: imul    rcx,[rbp-0C0h],1
    4c4: add     rax,rcx
    4c7: mov     [rbp-78h],rax
    4cb: mov     rax,[rbp+10h]
    4cf: mov     rcx,[rbp-78h]
    4d3: mov     [rax+8],rcx
    4d7: jmp     10h
    4dc: nop     [rax]
    4e0: jmp     480h
    4e2: mov     rax,[rbp-88h]
    4e9: mov     [rbp-80h],rax
    4ed: jmp     4E0h
    4ef: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    4fa: mov     rax,[rbp-88h]
    501: imul    rcx,[rbp-0C0h],20h
    509: add     rax,rcx
    50c: mov     [rbp-80h],rax
    510: jmp     4E0h

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     byte ptr [rbp-31h],1
      f: nop
     10: movzx   eax,word ptr [rbp+28h]
     14: mov     [rbp-0B4h],ax
     1b: movzx   eax,word ptr [rbp-0B4h]
     22: mov     [rbp-9Ah],ax
     29: mov     edi,0FFFFFF3Ch
     2e: mov     esi,0FFFFFF66h
     33: xor     edx,edx
     35: xor     ecx,ecx
     37: xor     r8d,r8d
     3a: mov     r9d,1
     40: call    ryo_h_DiscrNicheW16
     45: mov     edi,0FFFFFF58h
     4a: mov     esi,0FFFFFF3Ch
     4f: call    ryo_h_ZextW32W64
     54: mov     edi,0FFFFFF58h
     59: xor     esi,esi
     5b: mov     edx,2
     60: call    ryo_h_SwitchDenseW64
     65: lea     rcx,[78h]
     6c: movsxd  rax,[rcx+rax*4]
     70: add     rax,rcx
     73: jmp     rax
     75: int3
     76: int3
     77: int3
     78: .long   19ah
     7c: .long   161h
     80: .long   15ah
     84: nop     [rax+rax]
     8d: nop     [rax]
     90: mov     byte ptr [rbp-31h],1
     94: mov     rax,[rbp-0A0h]
     9b: mov     [rbp+38h],rax
     9f: mov     rax,[rbp+30h]
     a3: sub     rax,1
     a7: mov     [rbp+30h],rax
     ab: jmp     10h
     b0: mov     byte ptr [rbp-31h],0
     b4: mov     rax,[rbp+38h]
     b8: mov     [rbp-8],rax
     bc: jmp     112h
     be: xchg    ax,ax
     c0: mov     rax,[rbp+18h]
     c4: mov     [rbp-28h],rax
     c8: mov     rax,[rbp-28h]
     cc: mov     [rbp-88h],rax
     d3: mov     rax,[rbp-28h]
     d7: mov     [rbp-90h],rax
     de: mov     rax,[rbp-90h]
     e5: mov     [rbp-0E0h],rax
     ec: mov     edi,0FFFFFF38h
     f1: lea     rsi,[sym0]
     f8: call    ryo_h_AddrSym
     fd: mov     rdi,rbp
    100: lea     rsi,[ro+4]
    107: call    qword ptr [sym1]
    10d: jmp     3FEh
    112: mov     edi,0FFFFFFF8h
    117: mov     esi,8
    11c: call    ryo_h_Ret
    121: leave
    122: ret
    123: nop     [rax+rax]
    12c: nop     [rax]
    130: jmp     152h
    132: nop     [rax+rax]
    13b: nop     [rax+rax]
    140: mov     edi,0FFFFFF88h
    145: call    ryo_h_Resume
    14a: ud2
    14c: nop     [rax]
    150: jmp     140h
    152: test    byte ptr [rbp-31h],0FFh
    156: je      140h
    158: jmp     150h
    15a: call    ryo_h_Unreachable
    15f: ud2
    161: movzx   eax,word ptr [rbp-9Ah]
    168: mov     [rbp-9Ch],ax
    16f: movzx   eax,word ptr [rbp-9Ch]
    176: mov     [rbp-0B2h],ax
    17d: mov     edi,0FFFFFF3Ch
    182: mov     esi,0FFFFFF4Eh
    187: call    ryo_h_CttzW16
    18c: mov     eax,[rbp-0C4h]
    192: mov     [rbp-0A0h],eax
    198: jmp     1E2h
    19a: mov     edi,0FFFFFF68h
    19f: lea     rsi,[k2]
    1a6: mov     edx,10h
    1ab: call    ryo_h_Const
    1b0: mov     qword ptr [rbp-90h],0
    1bb: cmp     qword ptr [rbp-90h],0
    1c3: sete    [rbp-91h]
    1ca: mov     rax,[rbp+30h]
    1ce: mov     [rbp-80h],rax
    1d2: cmp     qword ptr [rbp-80h],0
    1d7: je      0B0h
    1dd: jmp     0C0h
    1e2: mov     edi,0FFFFFF50h
    1e7: mov     esi,0FFFFFF60h
    1ec: call    ryo_h_ZextW32W64
    1f1: mov     rax,[rbp-0B0h]
    1f8: mov     [rbp-90h],rax
    1ff: mov     qword ptr [rbp-98h],1
    20a: mov     rax,[rbp-90h]
    211: mov     [rbp-48h],rax
    215: movzx   eax,word ptr [rbp+28h]
    219: mov     [rbp-90h],ax
    220: movzx   eax,word ptr [rbp-90h]
    227: sub     eax,1
    22a: mov     [rbp-8Eh],ax
    231: movzx   eax,word ptr [rbp-90h]
    238: and     ax,[rbp-8Eh]
    23f: mov     [rbp-8Ch],ax
    246: movzx   eax,word ptr [rbp-8Ch]
    24d: mov     [rbp-8Ah],ax
    254: movzx   eax,word ptr [rbp-8Ah]
    25b: mov     [rbp+28h],ax
    25f: mov     rax,[rbp-48h]
    263: mov     [rbp-80h],rax
    267: mov     qword ptr [rbp-88h],1
    272: mov     rax,[rbp-80h]
    276: mov     [rbp-90h],rax
    27d: mov     byte ptr [rbp-0C1h],0
    284: test    byte ptr [rbp-0C1h],0FFh
    28b: je      2D9h
    28d: mov     rax,[rbp+10h]
    291: mov     [rbp-0C0h],rax
    298: mov     rax,[rbp-0C0h]
    29f: mov     [rbp-0B8h],rax
    2a6: mov     rax,[rbp-0B8h]
    2ad: mov     [rbp-0B0h],rax
    2b4: mov     rax,[rbp-0B0h]
    2bb: add     rax,[rbp-90h]
    2c2: mov     [rbp-0A8h],rax
    2c9: mov     rax,[rbp-0A8h]
    2d0: mov     [rbp-0A0h],rax
    2d7: jmp     310h
    2d9: mov     rax,[rbp+10h]
    2dd: mov     [rbp-0B0h],rax
    2e4: mov     rax,[rbp-0B0h]
    2eb: mov     [rbp-0A8h],rax
    2f2: mov     byte ptr [rbp-0C1h],0
    2f9: test    byte ptr [rbp-0C1h],0FFh
    300: je      3B5h
    306: jmp     3A5h
    30b: nop     [rax+rax]
    310: mov     rax,[rbp-0A0h]
    317: mov     [rbp-0A8h],rax
    31e: mov     rax,[rbp-0A8h]
    325: mov     [rbp-98h],rax
    32c: lea     rax,[rbp+40h]
    330: mov     [rbp-0A8h],rax
    337: mov     byte ptr [rbp-31h],0
    33b: mov     rax,[rbp+38h]
    33f: mov     [rbp-0C0h],rax
    346: mov     rax,[rbp-0C0h]
    34d: mov     [rbp-0B8h],rax
    354: mov     rax,[rbp-98h]
    35b: mov     [rbp-0B0h],rax
    362: mov     rax,[rbp-0A8h]
    369: mov     [rbp-0E0h],rax
    370: mov     rax,[rbp-0B8h]
    377: mov     [rbp-0D8h],rax
    37e: mov     rax,[rbp-0B0h]
    385: mov     [rbp-0D0h],rax
    38c: call    fn3
    391: nop     [rcx-0A0h]
    398: jmp     90h
    39d: nop     [rax]
    3a0: jmp     310h
    3a5: mov     rax,[rbp-0A8h]
    3ac: mov     [rbp-0A0h],rax
    3b3: jmp     3A0h
    3b5: mov     rax,[rbp-90h]
    3bc: mov     [rbp-0B8h],rax
    3c3: mov     qword ptr [rbp-0C8h],0
    3ce: mov     rax,[rbp-0C8h]
    3d5: sub     rax,[rbp-0B8h]
    3dc: mov     [rbp-0B0h],rax
    3e3: mov     rax,[rbp-0A8h]
    3ea: imul    rcx,[rbp-0B0h],10h
    3f2: add     rax,rcx
    3f5: mov     [rbp-0A0h],rax
    3fc: jmp     3A0h
    3fe: mov     edi,0FFFFFF20h
    403: mov     esi,0FFFFFF90h
    408: call    ryo_h_MovW128
    40d: mov     edi,0FFFFFF38h
    412: lea     rsi,[sym4]
    419: call    ryo_h_AddrSym
    41e: mov     rdi,rbp
    421: lea     rsi,[ro+20]
    428: call    qword ptr [sym5]
    42e: mov     edi,0FFFFFF80h
    433: mov     esi,0FFFFFF7Ch
    438: call    ryo_h_TruncW32W16
    43d: mov     edi,0FFFFFF82h
    442: mov     esi,0FFFFFF80h
    447: call    ryo_h_NotW16
    44c: movzx   eax,word ptr [rbp-7Eh]
    450: mov     [rbp-7Ch],ax
    454: movzx   eax,word ptr [rbp-7Ch]
    458: mov     [rbp-7Ah],ax
    45c: movzx   eax,word ptr [rbp-7Ah]
    460: mov     [rbp+28h],ax
    464: mov     byte ptr [rbp-0C1h],0
    46b: test    byte ptr [rbp-0C1h],0FFh
    472: je      4BDh
    474: mov     rax,[rbp+10h]
    478: mov     [rbp-0A8h],rax
    47f: mov     rax,[rbp-0A8h]
    486: mov     [rbp-0A0h],rax
    48d: mov     rax,[rbp-0A0h]
    494: mov     [rbp-98h],rax
    49b: mov     rax,[rbp-98h]
    4a2: add     rax,10h
    4a6: mov     [rbp-90h],rax
    4ad: mov     rax,[rbp-90h]
    4b4: mov     [rbp-88h],rax
    4bb: jmp     4F0h
    4bd: mov     rax,[rbp+10h]
    4c1: mov     [rbp-98h],rax
    4c8: mov     rax,[rbp-98h]
    4cf: mov     [rbp-90h],rax
    4d6: mov     byte ptr [rbp-0C1h],0
    4dd: test    byte ptr [rbp-0C1h],0FFh
    4e4: je      562h
    4e6: jmp     552h
    4e8: nop     [rax+rax]
    4f0: mov     rax,[rbp-88h]
    4f7: mov     [rbp-90h],rax
    4fe: mov     rax,[rbp-90h]
    505: mov     [rbp-80h],rax
    509: mov     rax,[rbp-80h]
    50d: mov     [rbp+10h],rax
    511: mov     rax,[rbp+18h]
    515: mov     [rbp-88h],rax
    51c: mov     qword ptr [rbp-0C8h],10h
    527: mov     rax,[rbp-88h]
    52e: imul    rcx,[rbp-0C8h],1
    536: add     rax,rcx
    539: mov     [rbp-80h],rax
    53d: mov     rax,[rbp-80h]
    541: mov     [rbp+18h],rax
    545: jmp     10h
    54a: nop     [rax+rax]
    550: jmp     4F0h
    552: mov     rax,[rbp-90h]
    559: mov     [rbp-88h],rax
    560: jmp     550h
    562: mov     qword ptr [rbp-0C8h],0FFFFFFFFFFFFFFF0h
    56d: mov     rax,[rbp-90h]
    574: imul    rcx,[rbp-0C8h],10h
    57c: add     rax,rcx
    57f: mov     [rbp-88h],rax
    586: jmp     550h
    588: mov     rdi,rax
    58b: mov     esi,0FFFFFF88h
    590: call    ryo_h_Lpad
    595: jmp     130h

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
     34: mov     rax,[rbp-0A8h]
     3b: mov     [rbp-0C0h],rax
     42: mov     edi,0FFFFFF50h
     47: lea     rsi,[sym0]
     4e: call    ryo_h_AddrSym
     53: mov     rdi,rbp
     56: lea     rsi,[ro+4]
     5d: call    qword ptr [sym1]
     63: mov     edi,0FFFFFF40h
     68: mov     esi,0FFFFFF70h
     6d: call    ryo_h_MovW128
     72: mov     edi,0FFFFFF50h
     77: lea     rsi,[sym2]
     7e: call    ryo_h_AddrSym
     83: mov     rdi,rbp
     86: lea     rsi,[ro+20]
     8d: call    qword ptr [sym3]
     93: mov     edi,0FFFFFF64h
     98: mov     esi,0FFFFFF60h
     9d: call    ryo_h_TruncW32W16
     a2: mov     edi,0FFFFFF66h
     a7: mov     esi,0FFFFFF64h
     ac: call    ryo_h_NotW16
     b1: movzx   eax,word ptr [rbp-9Ah]
     b8: mov     [rbp-4Ch],ax
     bc: mov     qword ptr [rbp-0B0h],10h
     c7: mov     rax,[rbp+18h]
     cb: imul    rcx,[rbp-0B0h],1
     d3: add     rax,rcx
     d6: mov     [rbp-60h],rax
     da: movzx   eax,word ptr [rbp-4Ch]
     de: mov     [rbp-9Ah],ax
     e5: movzx   eax,word ptr [rbp-9Ah]
     ec: mov     [rbp-8],ax
     f0: mov     rax,[rbp+10h]
     f4: mov     [rbp-20h],rax
     f8: mov     rax,[rbp-60h]
     fc: mov     [rbp-18h],rax
    100: mov     rax,[rbp-98h]
    107: mov     [rbp-10h],rax
    10b: mov     edi,0FFFFFFE0h
    110: mov     esi,20h
    115: call    ryo_h_Ret
    11a: leave
    11b: ret

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: nop     [rax+rax]
     10: mov     rax,[rbp+10h]
     14: movzx   eax,word ptr [rax+18h]
     18: mov     [rbp-0ACh],ax
     1f: movzx   eax,word ptr [rbp-0ACh]
     26: mov     [rbp-92h],ax
     2d: mov     edi,0FFFFFF44h
     32: mov     esi,0FFFFFF6Eh
     37: xor     edx,edx
     39: xor     ecx,ecx
     3b: xor     r8d,r8d
     3e: mov     r9d,1
     44: call    ryo_h_DiscrNicheW16
     49: mov     edi,0FFFFFF60h
     4e: mov     esi,0FFFFFF44h
     53: call    ryo_h_ZextW32W64
     58: mov     edi,0FFFFFF60h
     5d: xor     esi,esi
     5f: mov     edx,2
     64: call    ryo_h_SwitchDenseW64
     69: lea     rcx,[7Ch]
     70: movsxd  rax,[rcx+rax*4]
     74: add     rax,rcx
     77: jmp     rax
     79: int3
     7a: int3
     7b: int3
     7c: .long   181h
     80: .long   148h
     84: .long   141h
     88: nop     [rax+rax]
     90: mov     rax,[rbp+10h]
     94: mov     rax,[rax+8]
     98: mov     [rbp-80h],rax
     9c: mov     rax,[rbp+10h]
     a0: mov     rax,[rax+10h]
     a4: mov     [rbp-88h],rax
     ab: mov     rax,[rbp-80h]
     af: cmp     rax,[rbp-88h]
     b6: jb      0D0h
     b8: mov     qword ptr [rbp-8],0
     c0: jmp     130h
     c2: nop     [rax+rax]
     cb: nop     [rax+rax]
     d0: mov     rax,[rbp+10h]
     d4: mov     rax,[rax+8]
     d8: mov     [rbp-28h],rax
     dc: mov     rax,[rbp-28h]
     e0: mov     [rbp-80h],rax
     e4: mov     rax,[rbp-28h]
     e8: mov     [rbp-88h],rax
     ef: mov     rax,[rbp-88h]
     f6: mov     [rbp-0D0h],rax
     fd: mov     edi,0FFFFFF40h
    102: lea     rsi,[sym0]
    109: call    ryo_h_AddrSym
    10e: mov     rdi,rbp
    111: lea     rsi,[ro+4]
    118: call    qword ptr [sym1]
    11e: jmp     38Bh
    123: nop     [rax+rax]
    12c: nop     [rax]
    130: mov     edi,0FFFFFFF8h
    135: mov     esi,8
    13a: call    ryo_h_Ret
    13f: leave
    140: ret
    141: call    ryo_h_Unreachable
    146: ud2
    148: movzx   eax,word ptr [rbp-92h]
    14f: mov     [rbp-94h],ax
    156: movzx   eax,word ptr [rbp-94h]
    15d: mov     [rbp-0AAh],ax
    164: mov     edi,0FFFFFF44h
    169: mov     esi,0FFFFFF56h
    16e: call    ryo_h_CttzW16
    173: mov     eax,[rbp-0BCh]
    179: mov     [rbp-98h],eax
    17f: jmp     1CAh
    181: mov     edi,0FFFFFF70h
    186: lea     rsi,[k2]
    18d: mov     edx,10h
    192: call    ryo_h_Const
    197: mov     qword ptr [rbp-88h],0
    1a2: cmp     qword ptr [rbp-88h],0
    1aa: sete    [rbp-89h]
    1b1: mov     byte ptr [rbp-0B9h],0
    1b8: test    byte ptr [rbp-0B9h],0FFh
    1bf: je      0D0h
    1c5: jmp     90h
    1ca: mov     edi,0FFFFFF58h
    1cf: mov     esi,0FFFFFF68h
    1d4: call    ryo_h_ZextW32W64
    1d9: mov     rax,[rbp-0A8h]
    1e0: mov     [rbp-88h],rax
    1e7: mov     qword ptr [rbp-90h],1
    1f2: mov     rax,[rbp-88h]
    1f9: mov     [rbp-48h],rax
    1fd: mov     rax,[rbp+10h]
    201: movzx   eax,word ptr [rax+18h]
    205: mov     [rbp-88h],ax
    20c: movzx   eax,word ptr [rbp-88h]
    213: sub     eax,1
    216: mov     [rbp-86h],ax
    21d: movzx   eax,word ptr [rbp-88h]
    224: and     ax,[rbp-86h]
    22b: mov     [rbp-84h],ax
    232: movzx   eax,word ptr [rbp-84h]
    239: mov     [rbp-82h],ax
    240: mov     rax,[rbp+10h]
    244: movzx   ecx,word ptr [rbp-82h]
    24b: mov     [rax+18h],cx
    24f: mov     rax,[rbp-48h]
    253: mov     [rbp-78h],rax
    257: mov     qword ptr [rbp-80h],1
    25f: mov     rax,[rbp-78h]
    263: mov     [rbp-88h],rax
    26a: mov     byte ptr [rbp-0B9h],0
    271: test    byte ptr [rbp-0B9h],0FFh
    278: je      2C9h
    27a: mov     rax,[rbp+10h]
    27e: mov     rax,[rax]
    281: mov     [rbp-0B8h],rax
    288: mov     rax,[rbp-0B8h]
    28f: mov     [rbp-0B0h],rax
    296: mov     rax,[rbp-0B0h]
    29d: mov     [rbp-0A8h],rax
    2a4: mov     rax,[rbp-0A8h]
    2ab: add     rax,[rbp-88h]
    2b2: mov     [rbp-0A0h],rax
    2b9: mov     rax,[rbp-0A0h]
    2c0: mov     [rbp-98h],rax
    2c7: jmp     300h
    2c9: mov     rax,[rbp+10h]
    2cd: mov     rax,[rax]
    2d0: mov     [rbp-0A8h],rax
    2d7: mov     rax,[rbp-0A8h]
    2de: mov     [rbp-0A0h],rax
    2e5: mov     byte ptr [rbp-0B9h],0
    2ec: test    byte ptr [rbp-0B9h],0FFh
    2f3: je      342h
    2f5: jmp     332h
    2f7: nop     [rax+rax]
    300: mov     rax,[rbp-98h]
    307: mov     [rbp-0A0h],rax
    30e: mov     rax,[rbp-0A0h]
    315: mov     [rbp-90h],rax
    31c: mov     rax,[rbp-90h]
    323: mov     [rbp-8],rax
    327: jmp     130h
    32c: nop     [rax]
    330: jmp     300h
    332: mov     rax,[rbp-0A0h]
    339: mov     [rbp-98h],rax
    340: jmp     330h
    342: mov     rax,[rbp-88h]
    349: mov     [rbp-0B0h],rax
    350: mov     qword ptr [rbp-0C0h],0
    35b: mov     rax,[rbp-0C0h]
    362: sub     rax,[rbp-0B0h]
    369: mov     [rbp-0A8h],rax
    370: mov     rax,[rbp-0A0h]
    377: imul    rcx,[rbp-0A8h],10h
    37f: add     rax,rcx
    382: mov     [rbp-98h],rax
    389: jmp     330h
    38b: mov     edi,0FFFFFF30h
    390: mov     esi,0FFFFFF90h
    395: call    ryo_h_MovW128
    39a: mov     edi,0FFFFFF40h
    39f: lea     rsi,[sym3]
    3a6: call    ryo_h_AddrSym
    3ab: mov     rdi,rbp
    3ae: lea     rsi,[ro+20]
    3b5: call    qword ptr [sym4]
    3bb: mov     edi,0FFFFFF88h
    3c0: mov     esi,0FFFFFF84h
    3c5: call    ryo_h_TruncW32W16
    3ca: mov     edi,0FFFFFF8Ah
    3cf: mov     esi,0FFFFFF88h
    3d4: call    ryo_h_NotW16
    3d9: movzx   eax,word ptr [rbp-76h]
    3dd: mov     [rbp-74h],ax
    3e1: movzx   eax,word ptr [rbp-74h]
    3e5: mov     [rbp-72h],ax
    3e9: mov     rax,[rbp+10h]
    3ed: movzx   ecx,word ptr [rbp-72h]
    3f1: mov     [rax+18h],cx
    3f5: mov     byte ptr [rbp-0B9h],0
    3fc: test    byte ptr [rbp-0B9h],0FFh
    403: je      44Eh
    405: mov     rax,[rbp+10h]
    409: mov     rax,[rax]
    40c: mov     [rbp-0A0h],rax
    413: mov     rax,[rbp-0A0h]
    41a: mov     [rbp-98h],rax
    421: mov     rax,[rbp-98h]
    428: mov     [rbp-90h],rax
    42f: mov     rax,[rbp-90h]
    436: add     rax,10h
    43a: mov     [rbp-88h],rax
    441: mov     rax,[rbp-88h]
    448: mov     [rbp-80h],rax
    44c: jmp     480h
    44e: mov     rax,[rbp+10h]
    452: mov     rax,[rax]
    455: mov     [rbp-90h],rax
    45c: mov     rax,[rbp-90h]
    463: mov     [rbp-88h],rax
    46a: mov     byte ptr [rbp-0B9h],0
    471: test    byte ptr [rbp-0B9h],0FFh
    478: je      4EFh
    47a: jmp     4E2h
    47c: nop     [rax]
    480: mov     rax,[rbp-80h]
    484: mov     [rbp-88h],rax
    48b: mov     rax,[rbp-88h]
    492: mov     [rbp-78h],rax
    496: mov     rax,[rbp+10h]
    49a: mov     rcx,[rbp-78h]
    49e: mov     [rax],rcx
    4a1: mov     rax,[rbp+10h]
    4a5: mov     rax,[rax+8]
    4a9: mov     [rbp-80h],rax
    4ad: mov     qword ptr [rbp-0C0h],10h
    4b8: mov     rax,[rbp-80h]
    4bc: imul    rcx,[rbp-0C0h],1
    4c4: add     rax,rcx
    4c7: mov     [rbp-78h],rax
    4cb: mov     rax,[rbp+10h]
    4cf: mov     rcx,[rbp-78h]
    4d3: mov     [rax+8],rcx
    4d7: jmp     10h
    4dc: nop     [rax]
    4e0: jmp     480h
    4e2: mov     rax,[rbp-88h]
    4e9: mov     [rbp-80h],rax
    4ed: jmp     4E0h
    4ef: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    4fa: mov     rax,[rbp-88h]
    501: imul    rcx,[rbp-0C0h],10h
    509: add     rax,rcx
    50c: mov     [rbp-80h],rax
    510: jmp     4E0h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp-80h]
     1f: mov     [rbp-78h],rax
     23: mov     rax,[rbp+10h]
     27: mov     [rbp-70h],rax
     2b: lea     rax,[rbp-78h]
     2f: mov     [rbp-68h],rax
     33: mov     rax,[rbp-68h]
     37: mov     [rbp-60h],rax
     3b: mov     edi,0FFFFFFA8h
     40: lea     rsi,[k0]
     47: call    ryo_h_AddrAbs
     4c: mov     rax,[rbp-50h]
     50: mov     [rbp-0B0h],rax
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-0A8h],rax
     62: mov     edi,0FFFFFF60h
     67: mov     esi,0FFFFFFA0h
     6c: call    ryo_h_MovW128
     71: call    fn1
     76: nop     [rcx-48h]
     7d: mov     rax,[rbp-48h]
     81: mov     [rbp-10h],rax
     85: mov     edi,0FFFFFFF0h
     8a: xor     esi,esi
     8c: mov     edx,2
     91: call    ryo_h_SwitchDenseW64
     96: lea     rcx,[0A8h]
     9d: movsxd  rax,[rcx+rax*4]
     a1: add     rax,rcx
     a4: jmp     rax
     a6: int3
     a7: int3
     a8: .long   bbh
     ac: .long   c5h
     b0: .long   b4h
     b4: call    ryo_h_Unreachable
     b9: ud2
     bb: mov     qword ptr [rbp-8],0
     c3: jmp     100h
     c5: mov     rax,[rbp-40h]
     c9: mov     [rbp-50h],rax
     cd: mov     rax,[rbp+10h]
     d1: mov     rax,[rax]
     d4: mov     [rbp-68h],rax
     d8: mov     rax,[rbp-68h]
     dc: mov     [rbp-60h],rax
     e0: mov     byte ptr [rbp-89h],0
     e7: test    byte ptr [rbp-89h],0FFh
     ee: je      142h
     f0: jmp     12Ch
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: mov     edi,0FFFFFFC8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: mov     rax,[rbp-50h]
    130: add     rax,1
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-70h],rax
    140: jmp     160h
    142: mov     rax,[rbp-68h]
    146: mov     [rbp-78h],rax
    14a: mov     byte ptr [rbp-89h],0
    151: test    byte ptr [rbp-89h],0FFh
    158: je      18Ch
    15a: jmp     182h
    15c: nop     [rax]
    160: mov     rax,[rbp-70h]
    164: mov     [rbp-78h],rax
    168: mov     rax,[rbp-78h]
    16c: mov     [rbp-58h],rax
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-8],rax
    178: jmp     100h
    17a: nop     [rax+rax]
    180: jmp     160h
    182: mov     rax,[rbp-78h]
    186: mov     [rbp-70h],rax
    18a: jmp     180h
    18c: mov     rax,[rbp-50h]
    190: mov     [rbp-88h],rax
    197: mov     qword ptr [rbp-90h],0
    1a2: mov     rax,[rbp-90h]
    1a9: sub     rax,[rbp-88h]
    1b0: mov     [rbp-80h],rax
    1b4: mov     rax,[rbp-78h]
    1b8: imul    rcx,[rbp-80h],20h
    1bd: add     rax,rcx
    1c0: mov     [rbp-70h],rax
    1c4: jmp     180h
    1c6: mov     rdi,rax
    1c9: mov     esi,0FFFFFFC8h
    1ce: call    ryo_h_Lpad
    1d3: jmp     120h

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
     22: mov     rax,[rbp-20h]
     26: mov     rax,[rax]
     29: mov     [rbp-68h],rax
     2d: mov     rax,[rbp-68h]
     31: mov     [rbp-60h],rax
     35: mov     byte ptr [rbp-89h],0
     3c: test    byte ptr [rbp-89h],0FFh
     43: je      77h
     45: jmp     61h
     47: nop     [rax+rax]
     50: mov     edi,0FFFFFFFFh
     55: mov     esi,1
     5a: call    ryo_h_Ret
     5f: leave
     60: ret
     61: mov     rax,[rbp+18h]
     65: add     rax,1
     69: mov     [rbp-78h],rax
     6d: mov     rax,[rbp-78h]
     71: mov     [rbp-70h],rax
     75: jmp     0A0h
     77: mov     rax,[rbp-68h]
     7b: mov     [rbp-78h],rax
     7f: mov     byte ptr [rbp-89h],0
     86: test    byte ptr [rbp-89h],0FFh
     8d: je      0DCh
     8f: jmp     0D2h
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: mov     rax,[rbp-70h]
     a4: mov     [rbp-48h],rax
     a8: mov     byte ptr [rbp-89h],0
     af: test    byte ptr [rbp-89h],0FFh
     b6: je      161h
     bc: jmp     157h
     c1: nop     [rax+rax]
     ca: nop     [rax+rax]
     d0: jmp     0A0h
     d2: mov     rax,[rbp-78h]
     d6: mov     [rbp-70h],rax
     da: jmp     0D0h
     dc: mov     rax,[rbp+18h]
     e0: mov     [rbp-88h],rax
     e7: mov     qword ptr [rbp-90h],0
     f2: mov     rax,[rbp-90h]
     f9: sub     rax,[rbp-88h]
    100: mov     [rbp-80h],rax
    104: mov     rax,[rbp-78h]
    108: imul    rcx,[rbp-80h],20h
    10d: add     rax,rcx
    110: mov     [rbp-70h],rax
    114: jmp     0D0h
    116: nop     [rax+rax]
    11f: nop
    120: mov     rax,[rbp-60h]
    124: mov     [rbp-58h],rax
    128: mov     rax,[rbp-58h]
    12c: mov     [rbp-50h],rax
    130: mov     rax,[rbp-18h]
    134: mov     [rbp-0A0h],rax
    13b: mov     rax,[rbp-50h]
    13f: mov     [rbp-98h],rax
    146: call    fn0
    14b: nop     [rcx-1]
    152: jmp     50h
    157: mov     qword ptr [rbp-60h],8
    15f: jmp     120h
    161: mov     rax,[rbp-48h]
    165: mov     [rbp-68h],rax
    169: mov     byte ptr [rbp-89h],0
    170: test    byte ptr [rbp-89h],0FFh
    177: je      18Ch
    179: jmp     182h
    17b: nop     [rax+rax]
    180: jmp     120h
    182: mov     rax,[rbp-68h]
    186: mov     [rbp-60h],rax
    18a: jmp     180h
    18c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    197: mov     rax,[rbp-68h]
    19b: imul    rcx,[rbp-90h],20h
    1a3: add     rax,rcx
    1a6: mov     [rbp-60h],rax
    1aa: jmp     180h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     rax,[rbp-68h]
     17: mov     [rbp-0B0h],rax
     1e: mov     rax,[rbp+18h]
     22: mov     [rbp-0A8h],rax
     29: call    fn0
     2e: nop     [rcx-28h]
     35: jmp     77h
     37: nop     [rax+rax]
     40: mov     edi,0FFFFFFA0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: lea     rax,[rbp+20h]
     54: mov     [rbp-98h],rax
     5b: mov     rax,[rbp-98h]
     62: mov     [rbp-0B0h],rax
     69: call    fn1
     6e: nop     [rcx-98h]
     75: jmp     40h
     77: mov     rax,[rbp+10h]
     7b: mov     rax,[rax]
     7e: mov     [rbp-80h],rax
     82: mov     rax,[rbp-80h]
     86: mov     [rbp-78h],rax
     8a: mov     rax,[rbp-78h]
     8e: imul    rcx,[rbp-28h],1
     93: add     rax,rcx
     96: mov     [rbp-70h],rax
     9a: mov     rax,[rbp-70h]
     9e: mov     [rbp-68h],rax
     a2: mov     rax,[rbp-68h]
     a6: movzx   eax,byte ptr [rax]
     a9: mov     [rbp-51h],al
     ac: mov     rax,[rbp+18h]
     b0: shr     rax,39h
     b4: mov     [rbp-70h],rax
     b8: mov     rax,[rbp-70h]
     bc: and     rax,7Fh
     c0: mov     [rbp-78h],rax
     c4: mov     edi,0FFFFFF9Eh
     c9: mov     esi,0FFFFFF88h
     ce: call    ryo_h_TruncW64W8
     d3: movzx   eax,byte ptr [rbp-62h]
     d7: mov     [rbp-61h],al
     da: mov     rax,[rbp-28h]
     de: sub     rax,10h
     e2: mov     [rbp-80h],rax
     e6: mov     rax,[rbp+10h]
     ea: mov     rax,[rax+8]
     ee: mov     [rbp-88h],rax
     f5: mov     rax,[rbp-80h]
     f9: and     rax,[rbp-88h]
    100: mov     [rbp-78h],rax
    104: mov     rax,[rbp-78h]
    108: add     rax,10h
    10c: mov     [rbp-70h],rax
    110: mov     rax,[rbp+10h]
    114: mov     rax,[rax]
    117: mov     [rbp-90h],rax
    11e: mov     rax,[rbp-90h]
    125: mov     [rbp-88h],rax
    12c: mov     rax,[rbp-88h]
    133: imul    rcx,[rbp-28h],1
    138: add     rax,rcx
    13b: mov     [rbp-80h],rax
    13f: mov     rax,[rbp-80h]
    143: mov     [rbp-78h],rax
    147: mov     rax,[rbp-78h]
    14b: movzx   ecx,byte ptr [rbp-61h]
    14f: mov     [rax],cl
    151: mov     rax,[rbp+10h]
    155: mov     rax,[rax]
    158: mov     [rbp-90h],rax
    15f: mov     rax,[rbp-90h]
    166: mov     [rbp-88h],rax
    16d: mov     rax,[rbp-88h]
    174: imul    rcx,[rbp-70h],1
    179: add     rax,rcx
    17c: mov     [rbp-80h],rax
    180: mov     rax,[rbp-80h]
    184: mov     [rbp-78h],rax
    188: mov     rax,[rbp-78h]
    18c: movzx   ecx,byte ptr [rbp-61h]
    190: mov     [rax],cl
    192: mov     rax,[rbp+10h]
    196: mov     rax,[rax]
    199: mov     [rbp-70h],rax
    19d: mov     rax,[rbp-70h]
    1a1: mov     [rbp-68h],rax
    1a5: mov     byte ptr [rbp-91h],0
    1ac: test    byte ptr [rbp-91h],0FFh
    1b3: je      1CBh
    1b5: mov     rax,[rbp-28h]
    1b9: add     rax,1
    1bd: mov     [rbp-80h],rax
    1c1: mov     rax,[rbp-80h]
    1c5: mov     [rbp-78h],rax
    1c9: jmp     1F0h
    1cb: mov     rax,[rbp-70h]
    1cf: mov     [rbp-80h],rax
    1d3: mov     byte ptr [rbp-91h],0
    1da: test    byte ptr [rbp-91h],0FFh
    1e1: je      28Fh
    1e7: jmp     285h
    1ec: nop     [rax]
    1f0: mov     rax,[rbp-78h]
    1f4: mov     [rbp-50h],rax
    1f8: mov     rax,[rbp-50h]
    1fc: mov     [rbp-8],rax
    200: movzx   eax,byte ptr [rbp-51h]
    204: and     al,1
    207: mov     [rbp-6Ah],al
    20a: cmp     byte ptr [rbp-6Ah],0
    20e: setne   [rbp-69h]
    212: mov     edi,0FFFFFF98h
    217: mov     esi,0FFFFFF97h
    21c: call    ryo_h_ZextW8W64
    221: mov     rax,[rbp+10h]
    225: mov     rax,[rax+10h]
    229: mov     [rbp-98h],rax
    230: mov     rax,[rbp-98h]
    237: sub     rax,[rbp-68h]
    23b: mov     [rbp-0A0h],rax
    242: mov     rax,[rbp+10h]
    246: mov     rcx,[rbp-0A0h]
    24d: mov     [rax+10h],rcx
    251: mov     edi,0FFFFFF80h
    256: mov     esi,20h
    25b: mov     edx,20h
    260: call    ryo_h_Copy
    265: mov     byte ptr [rbp-91h],0
    26c: test    byte ptr [rbp-91h],0FFh
    273: je      334h
    279: jmp     327h
    27e: xchg    ax,ax
    280: jmp     1F0h
    285: mov     rax,[rbp-80h]
    289: mov     [rbp-78h],rax
    28d: jmp     280h
    28f: mov     rax,[rbp-28h]
    293: mov     [rbp-90h],rax
    29a: mov     qword ptr [rbp-98h],0
    2a5: mov     rax,[rbp-98h]
    2ac: sub     rax,[rbp-90h]
    2b3: mov     [rbp-88h],rax
    2ba: mov     rax,[rbp-80h]
    2be: imul    rcx,[rbp-88h],20h
    2c6: add     rax,rcx
    2c9: mov     [rbp-78h],rax
    2cd: jmp     280h
    2cf: nop
    2d0: mov     edi,0FFFFFF78h
    2d5: xor     esi,esi
    2d7: mov     edx,0FFFFFF80h
    2dc: mov     ecx,20h
    2e1: call    ryo_h_StoreCopy
    2e6: mov     rax,[rbp+10h]
    2ea: mov     rax,[rax+18h]
    2ee: mov     [rbp-98h],rax
    2f5: mov     rax,[rbp-98h]
    2fc: add     rax,1
    300: mov     [rbp-0A0h],rax
    307: mov     rax,[rbp+10h]
    30b: mov     rcx,[rbp-0A0h]
    312: mov     [rax+18h],rcx
    316: mov     edi,0FFFFFFF8h
    31b: mov     esi,8
    320: call    ryo_h_Ret
    325: leave
    326: ret
    327: mov     qword ptr [rbp-88h],8
    332: jmp     2D0h
    334: mov     rax,[rbp-50h]
    338: mov     [rbp-90h],rax
    33f: mov     byte ptr [rbp-91h],0
    346: test    byte ptr [rbp-91h],0FFh
    34d: je      375h
    34f: jmp     365h
    351: nop     [rax+rax]
    35a: nop     [rax+rax]
    360: jmp     2D0h
    365: mov     rax,[rbp-90h]
    36c: mov     [rbp-88h],rax
    373: jmp     360h
    375: mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    380: mov     rax,[rbp-90h]
    387: imul    rcx,[rbp-98h],20h
    38f: add     rax,rcx
    392: mov     [rbp-88h],rax
    399: jmp     360h
    39b: nop     [rax+rax]
    3a0: lea     rdi,[sym2]
    3a7: lea     rsi,[site3]
    3ae: mov     edx,0FFFFFF68h
    3b3: call    ryo_h_CallExt
    3b8: test    rax,rax
    3bb: je      3C8h
    3bd: call    rax
    3bf: nop     [rcx-90h]
    3c6: jmp     3D8h
    3c8: mov     rdi,rbp
    3cb: lea     rsi,[ro+4]
    3d2: call    qword ptr [sym4]
    3d8: call    ryo_h_Unreachable
    3dd: ud2
    3df: mov     rdi,rax
    3e2: mov     esi,0FFFFFFA0h
    3e7: call    ryo_h_Lpad
    3ec: jmp     50h
    3f1: mov     rdi,rax
    3f4: mov     esi,0FFFFFFA0h
    3f9: call    ryo_h_Lpad
    3fe: jmp     3A0h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-38h],rax
     14: mov     rax,[rbp-38h]
     18: cmp     rax,[rbp+18h]
     1c: setb    [rbp-29h]
     20: test    byte ptr [rbp-29h],0FFh
     24: je      0E1h
     2a: jmp     0A8h
     2f: nop
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
     27: mov     rax,[rbp-50h]
     2b: mov     [rbp-48h],rax
     2f: lea     rax,[rbp-48h]
     33: mov     [rbp-40h],rax
     37: mov     rax,[rbp-40h]
     3b: mov     [rbp-38h],rax
     3f: mov     edi,0FFFFFFD0h
     44: lea     rsi,[k0]
     4b: call    ryo_h_AddrAbs
     50: mov     byte ptr [rbp-59h],1
     54: test    byte ptr [rbp-59h],0FFh
     58: je      75h
     5a: mov     edi,0FFFFFFA8h
     5f: lea     rsi,[sym1]
     66: call    ryo_h_AddrSym
     6b: mov     rax,[rbp-58h]
     6f: mov     [rbp-50h],rax
     73: jmp     7Dh
     75: mov     qword ptr [rbp-50h],0
     7d: mov     rax,[rbp-20h]
     81: mov     [rbp-0B0h],rax
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-0A8h],rax
     93: mov     rax,[rbp+20h]
     97: mov     [rbp-90h],rax
     9e: mov     edi,0FFFFFF60h
     a3: mov     esi,0FFFFFFC8h
     a8: call    ryo_h_MovW128
     ad: movzx   eax,byte ptr [rbp+28h]
     b1: mov     [rbp-78h],al
     b4: mov     edi,0FFFFFF78h
     b9: lea     rsi,[k2]
     c0: mov     edx,10h
     c5: call    ryo_h_Const
     ca: mov     rax,[rbp-50h]
     ce: mov     [rbp-70h],rax
     d2: call    fn3
     d7: nop     [rcx-10h]
     de: mov     edi,0FFFFFFF0h
     e3: mov     esi,10h
     e8: call    ryo_h_Ret
     ed: leave
     ee: ret
     ef: nop
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
     21: mov     rax,[rbp-60h]
     25: mov     [rbp-58h],rax
     29: mov     byte ptr [rbp-81h],0
     30: test    byte ptr [rbp-81h],0FFh
     37: je      67h
     39: jmp     51h
     3b: nop     [rax+rax]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+20h]
     55: add     rax,1
     59: mov     [rbp-70h],rax
     5d: mov     rax,[rbp-70h]
     61: mov     [rbp-68h],rax
     65: jmp     90h
     67: mov     rax,[rbp-60h]
     6b: mov     [rbp-70h],rax
     6f: mov     byte ptr [rbp-81h],0
     76: test    byte ptr [rbp-81h],0FFh
     7d: je      0BCh
     7f: jmp     0B2h
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     rax,[rbp-68h]
     94: mov     [rbp-40h],rax
     98: mov     byte ptr [rbp-81h],0
     9f: test    byte ptr [rbp-81h],0FFh
     a6: je      131h
     ac: jmp     127h
     ae: xchg    ax,ax
     b0: jmp     90h
     b2: mov     rax,[rbp-70h]
     b6: mov     [rbp-68h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+20h]
     c0: mov     [rbp-80h],rax
     c4: mov     qword ptr [rbp-88h],0
     cf: mov     rax,[rbp-88h]
     d6: sub     rax,[rbp-80h]
     da: mov     [rbp-78h],rax
     de: mov     rax,[rbp-70h]
     e2: imul    rcx,[rbp-78h],20h
     e7: add     rax,rcx
     ea: mov     [rbp-68h],rax
     ee: jmp     0B0h
     f0: mov     rax,[rbp-58h]
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp-50h]
     fc: mov     [rbp-48h],rax
    100: mov     rax,[rbp-18h]
    104: mov     [rbp-0A0h],rax
    10b: mov     rax,[rbp-48h]
    10f: mov     [rbp-98h],rax
    116: call    fn0
    11b: nop     [rcx-8]
    122: jmp     40h
    127: mov     qword ptr [rbp-58h],8
    12f: jmp     0F0h
    131: mov     rax,[rbp-40h]
    135: mov     [rbp-60h],rax
    139: mov     byte ptr [rbp-81h],0
    140: test    byte ptr [rbp-81h],0FFh
    147: je      15Ch
    149: jmp     152h
    14b: nop     [rax+rax]
    150: jmp     0F0h
    152: mov     rax,[rbp-60h]
    156: mov     [rbp-58h],rax
    15a: jmp     150h
    15c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    167: mov     rax,[rbp-60h]
    16b: imul    rcx,[rbp-88h],20h
    173: add     rax,rcx
    176: mov     [rbp-58h],rax
    17a: jmp     150h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: mov     rax,[rbp-10h]
     1c: mov     [rbp-20h],rax
     20: call    fn0
     25: nop     [rcx]
     2c: xor     edi,edi
     2e: xor     esi,esi
     30: call    ryo_h_Ret
     35: leave
     36: ret

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
     34: je      7Dh
     36: jmp     73h
     38: nop     [rax+rax]
     40: mov     rax,[rbp-10h]
     44: mov     [rbp-18h],rax
     48: mov     rax,[rbp-18h]
     4c: mov     [rbp-40h],rax
     50: mov     edi,0FFFFFFD8h
     55: lea     rsi,[sym1]
     5c: call    ryo_h_AddrSym
     61: mov     rdi,rbp
     64: lea     rsi,[ro+4]
     6b: call    qword ptr [sym2]
     71: jmp     0C6h
     73: mov     qword ptr [rbp-10h],8
     7b: jmp     40h
     7d: mov     rax,[rbp+18h]
     81: mov     [rbp-20h],rax
     85: mov     rax,[rbp-20h]
     89: mov     [rbp-18h],rax
     8d: mov     byte ptr [rbp-21h],0
     91: test    byte ptr [rbp-21h],0FFh
     95: je      0ACh
     97: jmp     0A2h
     99: nop     [rax]
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
     13: mov     rax,[rbp-18h]
     17: mov     [rbp-10h],rax
     1b: mov     byte ptr [rbp-33h],0
     1f: test    byte ptr [rbp-33h],0FFh
     23: je      8Fh
     25: jmp     66h
     27: nop     [rax+rax]
     30: xor     edi,edi
     32: xor     esi,esi
     34: call    ryo_h_Ret
     39: leave
     3a: ret
     3b: nop     [rax+rax]
     40: mov     rax,[rbp+10h]
     44: mov     [rbp-10h],rax
     48: mov     rax,[rbp-10h]
     4c: mov     [rbp-60h],rax
     50: mov     rax,[rbp-8]
     54: mov     [rbp-58h],rax
     58: call    fn0
     5d: nop     [rcx-8]
     64: jmp     30h
     66: mov     rax,[rbp+18h]
     6a: mov     rax,[rax]
     6d: mov     [rbp-30h],rax
     71: mov     rax,[rbp-30h]
     75: mov     [rbp-28h],rax
     79: mov     rax,[rbp-28h]
     7d: mov     [rbp-20h],rax
     81: mov     rax,[rbp-20h]
     85: sub     rax,1
     89: mov     [rbp-8],rax
     8d: jmp     40h
     8f: mov     rax,[rbp-18h]
     93: mov     [rbp-20h],rax
     97: mov     rax,[rbp+18h]
     9b: mov     rax,[rax]
     9e: mov     [rbp-30h],rax
     a2: mov     rax,[rbp-30h]
     a6: mov     [rbp-28h],rax
     aa: mov     qword ptr [rbp-40h],0
     b2: cmp     qword ptr [rbp-40h],10h
     b7: setb    [rbp-31h]
     bb: test    byte ptr [rbp-31h],0FFh
     bf: je      12Ah
     c1: jmp     0DDh
     c3: nop     [rax+rax]
     cc: nop     [rax]
     d0: mov     rax,[rbp-30h]
     d4: mov     [rbp-8],rax
     d8: jmp     40h
     dd: mov     qword ptr [rbp-40h],10h
     e5: mov     rax,[rbp-40h]
     e9: mov     rcx,7FFFFFFFFFFFFFFFh
     f3: cmp     rax,rcx
     f6: setbe   [rbp-32h]
     fa: test    byte ptr [rbp-32h],0FFh
     fe: je      12Ah
    100: mov     rax,[rbp-20h]
    104: sub     rax,[rbp-28h]
    108: mov     [rbp-30h],rax
    10c: mov     qword ptr [rbp-40h],10h
    114: mov     edi,0FFFFFFD0h
    119: mov     esi,0FFFFFFD0h
    11e: mov     edx,0FFFFFFC0h
    123: call    ryo_h_DivSW64
    128: jmp     0D0h
    12a: mov     edi,0FFFFFFA0h
    12f: lea     rsi,[k1]
    136: call    ryo_h_AddrAbs
    13b: mov     qword ptr [rbp-58h],49h
    143: mov     edi,0FFFFFFB0h
    148: lea     rsi,[k2]
    14f: call    ryo_h_AddrAbs
    154: lea     rdi,[sym3]
    15b: lea     rsi,[site4]
    162: mov     edx,0FFFFFFC0h
    167: call    ryo_h_CallExt
    16c: test    rax,rax
    16f: je      17Ch
    171: call    rax
    173: nop     [rcx-8]
    17a: jmp     18Ch
    17c: mov     rdi,rbp
    17f: lea     rsi,[ro+4]
    186: call    qword ptr [sym5]
    18c: call    ryo_h_Unreachable
    191: ud2

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp-80h]
     1f: mov     [rbp-78h],rax
     23: mov     rax,[rbp+10h]
     27: mov     [rbp-70h],rax
     2b: lea     rax,[rbp-78h]
     2f: mov     [rbp-68h],rax
     33: mov     rax,[rbp-68h]
     37: mov     [rbp-60h],rax
     3b: mov     edi,0FFFFFFA8h
     40: lea     rsi,[k0]
     47: call    ryo_h_AddrAbs
     4c: mov     rax,[rbp-50h]
     50: mov     [rbp-0B0h],rax
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-0A8h],rax
     62: mov     edi,0FFFFFF60h
     67: mov     esi,0FFFFFFA0h
     6c: call    ryo_h_MovW128
     71: call    fn1
     76: nop     [rcx-48h]
     7d: mov     rax,[rbp-48h]
     81: mov     [rbp-10h],rax
     85: mov     edi,0FFFFFFF0h
     8a: xor     esi,esi
     8c: mov     edx,2
     91: call    ryo_h_SwitchDenseW64
     96: lea     rcx,[0A8h]
     9d: movsxd  rax,[rcx+rax*4]
     a1: add     rax,rcx
     a4: jmp     rax
     a6: int3
     a7: int3
     a8: .long   bbh
     ac: .long   c5h
     b0: .long   b4h
     b4: call    ryo_h_Unreachable
     b9: ud2
     bb: mov     qword ptr [rbp-8],0
     c3: jmp     100h
     c5: mov     rax,[rbp-40h]
     c9: mov     [rbp-50h],rax
     cd: mov     rax,[rbp+10h]
     d1: mov     rax,[rax]
     d4: mov     [rbp-68h],rax
     d8: mov     rax,[rbp-68h]
     dc: mov     [rbp-60h],rax
     e0: mov     byte ptr [rbp-89h],0
     e7: test    byte ptr [rbp-89h],0FFh
     ee: je      142h
     f0: jmp     12Ch
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: mov     edi,0FFFFFFC8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: mov     rax,[rbp-50h]
    130: add     rax,1
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-70h],rax
    140: jmp     160h
    142: mov     rax,[rbp-68h]
    146: mov     [rbp-78h],rax
    14a: mov     byte ptr [rbp-89h],0
    151: test    byte ptr [rbp-89h],0FFh
    158: je      18Ch
    15a: jmp     182h
    15c: nop     [rax]
    160: mov     rax,[rbp-70h]
    164: mov     [rbp-78h],rax
    168: mov     rax,[rbp-78h]
    16c: mov     [rbp-58h],rax
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-8],rax
    178: jmp     100h
    17a: nop     [rax+rax]
    180: jmp     160h
    182: mov     rax,[rbp-78h]
    186: mov     [rbp-70h],rax
    18a: jmp     180h
    18c: mov     rax,[rbp-50h]
    190: mov     [rbp-88h],rax
    197: mov     qword ptr [rbp-90h],0
    1a2: mov     rax,[rbp-90h]
    1a9: sub     rax,[rbp-88h]
    1b0: mov     [rbp-80h],rax
    1b4: mov     rax,[rbp-78h]
    1b8: imul    rcx,[rbp-80h],10h
    1bd: add     rax,rcx
    1c0: mov     [rbp-70h],rax
    1c4: jmp     180h
    1c6: mov     rdi,rax
    1c9: mov     esi,0FFFFFFC8h
    1ce: call    ryo_h_Lpad
    1d3: jmp     120h

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
     22: mov     rax,[rbp-20h]
     26: mov     rax,[rax]
     29: mov     [rbp-68h],rax
     2d: mov     rax,[rbp-68h]
     31: mov     [rbp-60h],rax
     35: mov     byte ptr [rbp-89h],0
     3c: test    byte ptr [rbp-89h],0FFh
     43: je      77h
     45: jmp     61h
     47: nop     [rax+rax]
     50: mov     edi,0FFFFFFFFh
     55: mov     esi,1
     5a: call    ryo_h_Ret
     5f: leave
     60: ret
     61: mov     rax,[rbp+18h]
     65: add     rax,1
     69: mov     [rbp-78h],rax
     6d: mov     rax,[rbp-78h]
     71: mov     [rbp-70h],rax
     75: jmp     0A0h
     77: mov     rax,[rbp-68h]
     7b: mov     [rbp-78h],rax
     7f: mov     byte ptr [rbp-89h],0
     86: test    byte ptr [rbp-89h],0FFh
     8d: je      0DCh
     8f: jmp     0D2h
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: mov     rax,[rbp-70h]
     a4: mov     [rbp-48h],rax
     a8: mov     byte ptr [rbp-89h],0
     af: test    byte ptr [rbp-89h],0FFh
     b6: je      161h
     bc: jmp     157h
     c1: nop     [rax+rax]
     ca: nop     [rax+rax]
     d0: jmp     0A0h
     d2: mov     rax,[rbp-78h]
     d6: mov     [rbp-70h],rax
     da: jmp     0D0h
     dc: mov     rax,[rbp+18h]
     e0: mov     [rbp-88h],rax
     e7: mov     qword ptr [rbp-90h],0
     f2: mov     rax,[rbp-90h]
     f9: sub     rax,[rbp-88h]
    100: mov     [rbp-80h],rax
    104: mov     rax,[rbp-78h]
    108: imul    rcx,[rbp-80h],10h
    10d: add     rax,rcx
    110: mov     [rbp-70h],rax
    114: jmp     0D0h
    116: nop     [rax+rax]
    11f: nop
    120: mov     rax,[rbp-60h]
    124: mov     [rbp-58h],rax
    128: mov     rax,[rbp-58h]
    12c: mov     [rbp-50h],rax
    130: mov     rax,[rbp-18h]
    134: mov     [rbp-0A0h],rax
    13b: mov     rax,[rbp-50h]
    13f: mov     [rbp-98h],rax
    146: call    fn0
    14b: nop     [rcx-1]
    152: jmp     50h
    157: mov     qword ptr [rbp-60h],8
    15f: jmp     120h
    161: mov     rax,[rbp-48h]
    165: mov     [rbp-68h],rax
    169: mov     byte ptr [rbp-89h],0
    170: test    byte ptr [rbp-89h],0FFh
    177: je      18Ch
    179: jmp     182h
    17b: nop     [rax+rax]
    180: jmp     120h
    182: mov     rax,[rbp-68h]
    186: mov     [rbp-60h],rax
    18a: jmp     180h
    18c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    197: mov     rax,[rbp-68h]
    19b: imul    rcx,[rbp-90h],10h
    1a3: add     rax,rcx
    1a6: mov     [rbp-60h],rax
    1aa: jmp     180h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rax,[rbp+20h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp-80h]
     1f: mov     [rbp-78h],rax
     23: mov     rax,[rbp+10h]
     27: mov     [rbp-70h],rax
     2b: lea     rax,[rbp-78h]
     2f: mov     [rbp-68h],rax
     33: mov     rax,[rbp-68h]
     37: mov     [rbp-60h],rax
     3b: mov     edi,0FFFFFFA8h
     40: lea     rsi,[k0]
     47: call    ryo_h_AddrAbs
     4c: mov     rax,[rbp-50h]
     50: mov     [rbp-0B0h],rax
     57: mov     rax,[rbp+18h]
     5b: mov     [rbp-0A8h],rax
     62: mov     edi,0FFFFFF60h
     67: mov     esi,0FFFFFFA0h
     6c: call    ryo_h_MovW128
     71: call    fn1
     76: nop     [rcx-48h]
     7d: mov     rax,[rbp-48h]
     81: mov     [rbp-10h],rax
     85: mov     edi,0FFFFFFF0h
     8a: xor     esi,esi
     8c: mov     edx,2
     91: call    ryo_h_SwitchDenseW64
     96: lea     rcx,[0A8h]
     9d: movsxd  rax,[rcx+rax*4]
     a1: add     rax,rcx
     a4: jmp     rax
     a6: int3
     a7: int3
     a8: .long   bbh
     ac: .long   c5h
     b0: .long   b4h
     b4: call    ryo_h_Unreachable
     b9: ud2
     bb: mov     qword ptr [rbp-8],0
     c3: jmp     100h
     c5: mov     rax,[rbp-40h]
     c9: mov     [rbp-50h],rax
     cd: mov     rax,[rbp+10h]
     d1: mov     rax,[rax]
     d4: mov     [rbp-68h],rax
     d8: mov     rax,[rbp-68h]
     dc: mov     [rbp-60h],rax
     e0: mov     byte ptr [rbp-89h],0
     e7: test    byte ptr [rbp-89h],0FFh
     ee: je      142h
     f0: jmp     12Ch
     f2: nop     [rax+rax]
     fb: nop     [rax+rax]
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: mov     edi,0FFFFFFC8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: mov     rax,[rbp-50h]
    130: add     rax,1
    134: mov     [rbp-78h],rax
    138: mov     rax,[rbp-78h]
    13c: mov     [rbp-70h],rax
    140: jmp     160h
    142: mov     rax,[rbp-68h]
    146: mov     [rbp-78h],rax
    14a: mov     byte ptr [rbp-89h],0
    151: test    byte ptr [rbp-89h],0FFh
    158: je      18Ch
    15a: jmp     182h
    15c: nop     [rax]
    160: mov     rax,[rbp-70h]
    164: mov     [rbp-78h],rax
    168: mov     rax,[rbp-78h]
    16c: mov     [rbp-58h],rax
    170: mov     rax,[rbp-58h]
    174: mov     [rbp-8],rax
    178: jmp     100h
    17a: nop     [rax+rax]
    180: jmp     160h
    182: mov     rax,[rbp-78h]
    186: mov     [rbp-70h],rax
    18a: jmp     180h
    18c: mov     rax,[rbp-50h]
    190: mov     [rbp-88h],rax
    197: mov     qword ptr [rbp-90h],0
    1a2: mov     rax,[rbp-90h]
    1a9: sub     rax,[rbp-88h]
    1b0: mov     [rbp-80h],rax
    1b4: mov     rax,[rbp-78h]
    1b8: imul    rcx,[rbp-80h],10h
    1bd: add     rax,rcx
    1c0: mov     [rbp-70h],rax
    1c4: jmp     180h
    1c6: mov     rdi,rax
    1c9: mov     esi,0FFFFFFC8h
    1ce: call    ryo_h_Lpad
    1d3: jmp     120h

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
     22: mov     rax,[rbp-20h]
     26: mov     rax,[rax]
     29: mov     [rbp-68h],rax
     2d: mov     rax,[rbp-68h]
     31: mov     [rbp-60h],rax
     35: mov     byte ptr [rbp-89h],0
     3c: test    byte ptr [rbp-89h],0FFh
     43: je      77h
     45: jmp     61h
     47: nop     [rax+rax]
     50: mov     edi,0FFFFFFFFh
     55: mov     esi,1
     5a: call    ryo_h_Ret
     5f: leave
     60: ret
     61: mov     rax,[rbp+18h]
     65: add     rax,1
     69: mov     [rbp-78h],rax
     6d: mov     rax,[rbp-78h]
     71: mov     [rbp-70h],rax
     75: jmp     0A0h
     77: mov     rax,[rbp-68h]
     7b: mov     [rbp-78h],rax
     7f: mov     byte ptr [rbp-89h],0
     86: test    byte ptr [rbp-89h],0FFh
     8d: je      0DCh
     8f: jmp     0D2h
     91: nop     [rax+rax]
     9a: nop     [rax+rax]
     a0: mov     rax,[rbp-70h]
     a4: mov     [rbp-48h],rax
     a8: mov     byte ptr [rbp-89h],0
     af: test    byte ptr [rbp-89h],0FFh
     b6: je      161h
     bc: jmp     157h
     c1: nop     [rax+rax]
     ca: nop     [rax+rax]
     d0: jmp     0A0h
     d2: mov     rax,[rbp-78h]
     d6: mov     [rbp-70h],rax
     da: jmp     0D0h
     dc: mov     rax,[rbp+18h]
     e0: mov     [rbp-88h],rax
     e7: mov     qword ptr [rbp-90h],0
     f2: mov     rax,[rbp-90h]
     f9: sub     rax,[rbp-88h]
    100: mov     [rbp-80h],rax
    104: mov     rax,[rbp-78h]
    108: imul    rcx,[rbp-80h],10h
    10d: add     rax,rcx
    110: mov     [rbp-70h],rax
    114: jmp     0D0h
    116: nop     [rax+rax]
    11f: nop
    120: mov     rax,[rbp-60h]
    124: mov     [rbp-58h],rax
    128: mov     rax,[rbp-58h]
    12c: mov     [rbp-50h],rax
    130: mov     rax,[rbp-18h]
    134: mov     [rbp-0A0h],rax
    13b: mov     rax,[rbp-50h]
    13f: mov     [rbp-98h],rax
    146: call    fn0
    14b: nop     [rcx-1]
    152: jmp     50h
    157: mov     qword ptr [rbp-60h],8
    15f: jmp     120h
    161: mov     rax,[rbp-48h]
    165: mov     [rbp-68h],rax
    169: mov     byte ptr [rbp-89h],0
    170: test    byte ptr [rbp-89h],0FFh
    177: je      18Ch
    179: jmp     182h
    17b: nop     [rax+rax]
    180: jmp     120h
    182: mov     rax,[rbp-68h]
    186: mov     [rbp-60h],rax
    18a: jmp     180h
    18c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    197: mov     rax,[rbp-68h]
    19b: imul    rcx,[rbp-90h],10h
    1a3: add     rax,rcx
    1a6: mov     [rbp-60h],rax
    1aa: jmp     180h

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     rax,[rbp-68h]
     17: mov     [rbp-0B0h],rax
     1e: mov     rax,[rbp+18h]
     22: mov     [rbp-0A8h],rax
     29: call    fn0
     2e: nop     [rcx-28h]
     35: jmp     52h
     37: nop     [rax+rax]
     40: mov     edi,0FFFFFFA0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: nop     [rax]
     50: jmp     40h
     52: mov     rax,[rbp+10h]
     56: mov     rax,[rax]
     59: mov     [rbp-80h],rax
     5d: mov     rax,[rbp-80h]
     61: mov     [rbp-78h],rax
     65: mov     rax,[rbp-78h]
     69: imul    rcx,[rbp-28h],1
     6e: add     rax,rcx
     71: mov     [rbp-70h],rax
     75: mov     rax,[rbp-70h]
     79: mov     [rbp-68h],rax
     7d: mov     rax,[rbp-68h]
     81: movzx   eax,byte ptr [rax]
     84: mov     [rbp-51h],al
     87: mov     rax,[rbp+18h]
     8b: shr     rax,39h
     8f: mov     [rbp-70h],rax
     93: mov     rax,[rbp-70h]
     97: and     rax,7Fh
     9b: mov     [rbp-78h],rax
     9f: mov     edi,0FFFFFF9Eh
     a4: mov     esi,0FFFFFF88h
     a9: call    ryo_h_TruncW64W8
     ae: movzx   eax,byte ptr [rbp-62h]
     b2: mov     [rbp-61h],al
     b5: mov     rax,[rbp-28h]
     b9: sub     rax,10h
     bd: mov     [rbp-80h],rax
     c1: mov     rax,[rbp+10h]
     c5: mov     rax,[rax+8]
     c9: mov     [rbp-88h],rax
     d0: mov     rax,[rbp-80h]
     d4: and     rax,[rbp-88h]
     db: mov     [rbp-78h],rax
     df: mov     rax,[rbp-78h]
     e3: add     rax,10h
     e7: mov     [rbp-70h],rax
     eb: mov     rax,[rbp+10h]
     ef: mov     rax,[rax]
     f2: mov     [rbp-90h],rax
     f9: mov     rax,[rbp-90h]
    100: mov     [rbp-88h],rax
    107: mov     rax,[rbp-88h]
    10e: imul    rcx,[rbp-28h],1
    113: add     rax,rcx
    116: mov     [rbp-80h],rax
    11a: mov     rax,[rbp-80h]
    11e: mov     [rbp-78h],rax
    122: mov     rax,[rbp-78h]
    126: movzx   ecx,byte ptr [rbp-61h]
    12a: mov     [rax],cl
    12c: mov     rax,[rbp+10h]
    130: mov     rax,[rax]
    133: mov     [rbp-90h],rax
    13a: mov     rax,[rbp-90h]
    141: mov     [rbp-88h],rax
    148: mov     rax,[rbp-88h]
    14f: imul    rcx,[rbp-70h],1
    154: add     rax,rcx
    157: mov     [rbp-80h],rax
    15b: mov     rax,[rbp-80h]
    15f: mov     [rbp-78h],rax
    163: mov     rax,[rbp-78h]
    167: movzx   ecx,byte ptr [rbp-61h]
    16b: mov     [rax],cl
    16d: mov     rax,[rbp+10h]
    171: mov     rax,[rax]
    174: mov     [rbp-70h],rax
    178: mov     rax,[rbp-70h]
    17c: mov     [rbp-68h],rax
    180: mov     byte ptr [rbp-91h],0
    187: test    byte ptr [rbp-91h],0FFh
    18e: je      1A6h
    190: mov     rax,[rbp-28h]
    194: add     rax,1
    198: mov     [rbp-80h],rax
    19c: mov     rax,[rbp-80h]
    1a0: mov     [rbp-78h],rax
    1a4: jmp     1D0h
    1a6: mov     rax,[rbp-70h]
    1aa: mov     [rbp-80h],rax
    1ae: mov     byte ptr [rbp-91h],0
    1b5: test    byte ptr [rbp-91h],0FFh
    1bc: je      26Fh
    1c2: jmp     265h
    1c7: nop     [rax+rax]
    1d0: mov     rax,[rbp-78h]
    1d4: mov     [rbp-50h],rax
    1d8: mov     rax,[rbp-50h]
    1dc: mov     [rbp-8],rax
    1e0: movzx   eax,byte ptr [rbp-51h]
    1e4: and     al,1
    1e7: mov     [rbp-6Ah],al
    1ea: cmp     byte ptr [rbp-6Ah],0
    1ee: setne   [rbp-69h]
    1f2: mov     edi,0FFFFFF98h
    1f7: mov     esi,0FFFFFF97h
    1fc: call    ryo_h_ZextW8W64
    201: mov     rax,[rbp+10h]
    205: mov     rax,[rax+10h]
    209: mov     [rbp-98h],rax
    210: mov     rax,[rbp-98h]
    217: sub     rax,[rbp-68h]
    21b: mov     [rbp-0A0h],rax
    222: mov     rax,[rbp+10h]
    226: mov     rcx,[rbp-0A0h]
    22d: mov     [rax+10h],rcx
    231: mov     edi,0FFFFFF90h
    236: mov     esi,20h
    23b: call    ryo_h_MovW128
    240: mov     byte ptr [rbp-91h],0
    247: test    byte ptr [rbp-91h],0FFh
    24e: je      30Ch
    254: jmp     302h
    259: nop     [rax]
    260: jmp     1D0h
    265: mov     rax,[rbp-80h]
    269: mov     [rbp-78h],rax
    26d: jmp     260h
    26f: mov     rax,[rbp-28h]
    273: mov     [rbp-90h],rax
    27a: mov     qword ptr [rbp-98h],0
    285: mov     rax,[rbp-98h]
    28c: sub     rax,[rbp-90h]
    293: mov     [rbp-88h],rax
    29a: mov     rax,[rbp-80h]
    29e: imul    rcx,[rbp-88h],10h
    2a6: add     rax,rcx
    2a9: mov     [rbp-78h],rax
    2ad: jmp     260h
    2af: nop
    2b0: mov     edi,0FFFFFF88h
    2b5: xor     esi,esi
    2b7: mov     edx,0FFFFFF90h
    2bc: call    ryo_h_StoreW128
    2c1: mov     rax,[rbp+10h]
    2c5: mov     rax,[rax+18h]
    2c9: mov     [rbp-98h],rax
    2d0: mov     rax,[rbp-98h]
    2d7: add     rax,1
    2db: mov     [rbp-0A0h],rax
    2e2: mov     rax,[rbp+10h]
    2e6: mov     rcx,[rbp-0A0h]
    2ed: mov     [rax+18h],rcx
    2f1: mov     edi,0FFFFFFF8h
    2f6: mov     esi,8
    2fb: call    ryo_h_Ret
    300: leave
    301: ret
    302: mov     qword ptr [rbp-78h],8
    30a: jmp     2B0h
    30c: mov     rax,[rbp-50h]
    310: mov     [rbp-80h],rax
    314: mov     byte ptr [rbp-91h],0
    31b: test    byte ptr [rbp-91h],0FFh
    322: je      33Fh
    324: jmp     335h
    326: nop     [rax+rax]
    32f: nop
    330: jmp     2B0h
    335: mov     rax,[rbp-80h]
    339: mov     [rbp-78h],rax
    33d: jmp     330h
    33f: mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    34a: mov     rax,[rbp-80h]
    34e: imul    rcx,[rbp-98h],10h
    356: add     rax,rcx
    359: mov     [rbp-78h],rax
    35d: jmp     330h
    35f: mov     rdi,rax
    362: mov     esi,0FFFFFFA0h
    367: call    ryo_h_Lpad
    36c: jmp     50h

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-38h],rax
     14: mov     rax,[rbp-38h]
     18: cmp     rax,[rbp+18h]
     1c: setb    [rbp-29h]
     20: test    byte ptr [rbp-29h],0FFh
     24: je      0E1h
     2a: jmp     0A8h
     2f: nop
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
     27: mov     rax,[rbp-50h]
     2b: mov     [rbp-48h],rax
     2f: lea     rax,[rbp-48h]
     33: mov     [rbp-40h],rax
     37: mov     rax,[rbp-40h]
     3b: mov     [rbp-38h],rax
     3f: mov     edi,0FFFFFFD0h
     44: lea     rsi,[k0]
     4b: call    ryo_h_AddrAbs
     50: mov     byte ptr [rbp-59h],0
     54: test    byte ptr [rbp-59h],0FFh
     58: je      75h
     5a: mov     edi,0FFFFFFA8h
     5f: lea     rsi,[sym1]
     66: call    ryo_h_AddrSym
     6b: mov     rax,[rbp-58h]
     6f: mov     [rbp-50h],rax
     73: jmp     7Dh
     75: mov     qword ptr [rbp-50h],0
     7d: mov     rax,[rbp-20h]
     81: mov     [rbp-0B0h],rax
     88: mov     rax,[rbp-28h]
     8c: mov     [rbp-0A8h],rax
     93: mov     rax,[rbp+20h]
     97: mov     [rbp-90h],rax
     9e: mov     edi,0FFFFFF60h
     a3: mov     esi,0FFFFFFC8h
     a8: call    ryo_h_MovW128
     ad: movzx   eax,byte ptr [rbp+28h]
     b1: mov     [rbp-78h],al
     b4: mov     edi,0FFFFFF78h
     b9: lea     rsi,[k2]
     c0: mov     edx,10h
     c5: call    ryo_h_Const
     ca: mov     rax,[rbp-50h]
     ce: mov     [rbp-70h],rax
     d2: call    fn3
     d7: nop     [rcx-10h]
     de: mov     edi,0FFFFFFF0h
     e3: mov     esi,10h
     e8: call    ryo_h_Ret
     ed: leave
     ee: ret
     ef: nop
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
     21: mov     rax,[rbp-60h]
     25: mov     [rbp-58h],rax
     29: mov     byte ptr [rbp-81h],0
     30: test    byte ptr [rbp-81h],0FFh
     37: je      67h
     39: jmp     51h
     3b: nop     [rax+rax]
     40: mov     edi,0FFFFFFF8h
     45: mov     esi,8
     4a: call    ryo_h_Ret
     4f: leave
     50: ret
     51: mov     rax,[rbp+20h]
     55: add     rax,1
     59: mov     [rbp-70h],rax
     5d: mov     rax,[rbp-70h]
     61: mov     [rbp-68h],rax
     65: jmp     90h
     67: mov     rax,[rbp-60h]
     6b: mov     [rbp-70h],rax
     6f: mov     byte ptr [rbp-81h],0
     76: test    byte ptr [rbp-81h],0FFh
     7d: je      0BCh
     7f: jmp     0B2h
     81: nop     [rax+rax]
     8a: nop     [rax+rax]
     90: mov     rax,[rbp-68h]
     94: mov     [rbp-40h],rax
     98: mov     byte ptr [rbp-81h],0
     9f: test    byte ptr [rbp-81h],0FFh
     a6: je      131h
     ac: jmp     127h
     ae: xchg    ax,ax
     b0: jmp     90h
     b2: mov     rax,[rbp-70h]
     b6: mov     [rbp-68h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+20h]
     c0: mov     [rbp-80h],rax
     c4: mov     qword ptr [rbp-88h],0
     cf: mov     rax,[rbp-88h]
     d6: sub     rax,[rbp-80h]
     da: mov     [rbp-78h],rax
     de: mov     rax,[rbp-70h]
     e2: imul    rcx,[rbp-78h],10h
     e7: add     rax,rcx
     ea: mov     [rbp-68h],rax
     ee: jmp     0B0h
     f0: mov     rax,[rbp-58h]
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp-50h]
     fc: mov     [rbp-48h],rax
    100: mov     rax,[rbp-18h]
    104: mov     [rbp-0A0h],rax
    10b: mov     rax,[rbp-48h]
    10f: mov     [rbp-98h],rax
    116: call    fn0
    11b: nop     [rcx-8]
    122: jmp     40h
    127: mov     qword ptr [rbp-58h],8
    12f: jmp     0F0h
    131: mov     rax,[rbp-40h]
    135: mov     [rbp-60h],rax
    139: mov     byte ptr [rbp-81h],0
    140: test    byte ptr [rbp-81h],0FFh
    147: je      15Ch
    149: jmp     152h
    14b: nop     [rax+rax]
    150: jmp     0F0h
    152: mov     rax,[rbp-60h]
    156: mov     [rbp-58h],rax
    15a: jmp     150h
    15c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    167: mov     rax,[rbp-60h]
    16b: imul    rcx,[rbp-88h],10h
    173: add     rax,rcx
    176: mov     [rbp-58h],rax
    17a: jmp     150h

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],1
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0C2h
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+18h]
     27: mov     [rbp-50h],rax
     2b: cmp     qword ptr [rbp-50h],0
     30: je      0C2h
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax]
     3d: mov     [rbp-88h],rax
     44: mov     rax,[rbp-88h]
     4b: mov     [rbp-58h],rax
     4f: mov     byte ptr [rbp-99h],0
     56: test    byte ptr [rbp-99h],0FFh
     5d: je      11Eh
     63: jmp     111h
     68: nop     [rax+rax]
     70: mov     rax,[rbp-50h]
     74: mov     [rbp-80h],rax
     78: cmp     qword ptr [rbp-80h],0
     7d: je      1A2h
     83: jmp     1AFh
     88: nop     [rax+rax]
     90: call    ryo_h_Unreachable
     95: ud2
     97: mov     rax,[rbp-78h]
     9b: mov     [rbp-80h],rax
     9f: mov     byte ptr [rbp-99h],0
     a6: test    byte ptr [rbp-99h],0FFh
     ad: je      277h
     b3: jmp     26Ah
     b8: nop     [rax+rax]
     c0: jmp     0C2h
     c2: xor     edi,edi
     c4: xor     esi,esi
     c6: call    ryo_h_Ret
     cb: leave
     cc: ret
     cd: nop     [rax]
     d0: mov     rax,[rbp+10h]
     d4: mov     rax,[rax+18h]
     d8: mov     [rbp-78h],rax
     dc: mov     edi,0FFFFFFD8h
     e1: mov     esi,0FFFFFF90h
     e6: mov     edx,20h
     eb: call    ryo_h_Copy
     f0: mov     rax,[rbp-78h]
     f4: mov     [rbp-8],rax
     f8: mov     edi,0FFFFFF90h
     fd: mov     esi,0FFFFFFD8h
    102: mov     edx,28h
    107: call    ryo_h_Copy
    10c: jmp     70h
    111: mov     qword ptr [rbp-90h],1
    11c: jmp     12Ch
    11e: mov     rax,[rbp-88h]
    125: mov     [rbp-90h],rax
    12c: mov     rax,[rbp-90h]
    133: mov     [rbp-60h],rax
    137: mov     rax,[rbp-60h]
    13b: mov     [rbp-50h],rax
    13f: mov     rax,[rbp+10h]
    143: mov     rax,[rax]
    146: mov     [rbp-80h],rax
    14a: mov     rax,[rbp-80h]
    14e: mov     [rbp-78h],rax
    152: mov     rax,[rbp+10h]
    156: mov     rax,[rax+8]
    15a: mov     [rbp-98h],rax
    161: mov     rax,[rbp-98h]
    168: add     rax,1
    16c: mov     [rbp-80h],rax
    170: mov     rax,[rbp-78h]
    174: mov     [rbp-0B8h],rax
    17b: mov     rax,[rbp-50h]
    17f: mov     [rbp-0C0h],rax
    186: mov     rax,[rbp-80h]
    18a: mov     [rbp-0B0h],rax
    191: call    fn0
    196: nop     [rcx-70h]
    19d: jmp     0D0h
    1a2: mov     qword ptr [rbp-78h],0
    1aa: jmp     0C0h
    1af: lea     rax,[rbp-70h]
    1b3: mov     [rbp-80h],rax
    1b7: mov     rax,[rbp-80h]
    1bb: mov     [rbp-0C0h],rax
    1c2: call    fn1
    1c7: nop     [rcx-78h]
    1ce: mov     rax,[rbp-50h]
    1d2: sub     rax,1
    1d6: mov     [rbp-50h],rax
    1da: mov     edi,0FFFFFF64h
    1df: mov     esi,0FFFFFF88h
    1e4: xor     edx,edx
    1e6: xor     ecx,ecx
    1e8: xor     r8d,r8d
    1eb: mov     r9d,1
    1f1: call    ryo_h_DiscrNicheW64
    1f6: mov     edi,0FFFFFFC8h
    1fb: mov     esi,0FFFFFF64h
    200: call    ryo_h_ZextW32W64
    205: mov     edi,0FFFFFFC8h
    20a: xor     esi,esi
    20c: mov     edx,2
    211: call    ryo_h_SwitchDenseW64
    216: lea     rcx,[228h]
    21d: movsxd  rax,[rcx+rax*4]
    221: add     rax,rcx
    224: jmp     rax
    226: int3
    227: int3
    228: .long   c0h
    22c: .long   97h
    230: .long   90h
    234: nop     [rax+rax]
    23d: nop     [rax]
    240: mov     rax,[rbp-88h]
    247: mov     [rbp-90h],rax
    24e: mov     rax,[rbp-90h]
    255: mov     [rbp-0C0h],rax
    25c: call    fn2
    261: nop     [rcx-48h]
    268: jmp     2E8h
    26a: mov     qword ptr [rbp-88h],8
    275: jmp     240h
    277: mov     rax,[rbp-80h]
    27b: mov     [rbp-98h],rax
    282: mov     rax,[rbp-98h]
    289: mov     [rbp-90h],rax
    290: mov     byte ptr [rbp-99h],0
    297: test    byte ptr [rbp-99h],0FFh
    29e: je      2C2h
    2a0: jmp     2B2h
    2a2: nop     [rax+rax]
    2ab: nop     [rax+rax]
    2b0: jmp     240h
    2b2: mov     rax,[rbp-90h]
    2b9: mov     [rbp-88h],rax
    2c0: jmp     2B0h
    2c2: mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    2cd: mov     rax,[rbp-90h]
    2d4: imul    rcx,[rbp-0A0h],20h
    2dc: add     rax,rcx
    2df: mov     [rbp-88h],rax
    2e6: jmp     2B0h
    2e8: jmp     70h

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],0
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0C2h
     1f: mov     rax,[rbp+10h]
     23: mov     rax,[rax+18h]
     27: mov     [rbp-50h],rax
     2b: cmp     qword ptr [rbp-50h],0
     30: je      0C2h
     36: mov     rax,[rbp+10h]
     3a: mov     rax,[rax]
     3d: mov     [rbp-88h],rax
     44: mov     rax,[rbp-88h]
     4b: mov     [rbp-58h],rax
     4f: mov     byte ptr [rbp-99h],0
     56: test    byte ptr [rbp-99h],0FFh
     5d: je      11Eh
     63: jmp     111h
     68: nop     [rax+rax]
     70: mov     rax,[rbp-50h]
     74: mov     [rbp-80h],rax
     78: cmp     qword ptr [rbp-80h],0
     7d: je      1A2h
     83: jmp     1AFh
     88: nop     [rax+rax]
     90: call    ryo_h_Unreachable
     95: ud2
     97: mov     rax,[rbp-78h]
     9b: mov     [rbp-80h],rax
     9f: mov     byte ptr [rbp-99h],0
     a6: test    byte ptr [rbp-99h],0FFh
     ad: je      28Ch
     b3: jmp     27Fh
     b8: nop     [rax+rax]
     c0: jmp     0C2h
     c2: xor     edi,edi
     c4: xor     esi,esi
     c6: call    ryo_h_Ret
     cb: leave
     cc: ret
     cd: nop     [rax]
     d0: mov     rax,[rbp+10h]
     d4: mov     rax,[rax+18h]
     d8: mov     [rbp-78h],rax
     dc: mov     edi,0FFFFFFD8h
     e1: mov     esi,0FFFFFF90h
     e6: mov     edx,20h
     eb: call    ryo_h_Copy
     f0: mov     rax,[rbp-78h]
     f4: mov     [rbp-8],rax
     f8: mov     edi,0FFFFFF90h
     fd: mov     esi,0FFFFFFD8h
    102: mov     edx,28h
    107: call    ryo_h_Copy
    10c: jmp     70h
    111: mov     qword ptr [rbp-90h],1
    11c: jmp     12Ch
    11e: mov     rax,[rbp-88h]
    125: mov     [rbp-90h],rax
    12c: mov     rax,[rbp-90h]
    133: mov     [rbp-60h],rax
    137: mov     rax,[rbp-60h]
    13b: mov     [rbp-50h],rax
    13f: mov     rax,[rbp+10h]
    143: mov     rax,[rax]
    146: mov     [rbp-80h],rax
    14a: mov     rax,[rbp-80h]
    14e: mov     [rbp-78h],rax
    152: mov     rax,[rbp+10h]
    156: mov     rax,[rax+8]
    15a: mov     [rbp-98h],rax
    161: mov     rax,[rbp-98h]
    168: add     rax,1
    16c: mov     [rbp-80h],rax
    170: mov     rax,[rbp-78h]
    174: mov     [rbp-0B8h],rax
    17b: mov     rax,[rbp-50h]
    17f: mov     [rbp-0C0h],rax
    186: mov     rax,[rbp-80h]
    18a: mov     [rbp-0B0h],rax
    191: call    fn0
    196: nop     [rcx-70h]
    19d: jmp     0D0h
    1a2: mov     qword ptr [rbp-78h],0
    1aa: jmp     0C0h
    1af: lea     rax,[rbp-70h]
    1b3: mov     [rbp-80h],rax
    1b7: mov     rax,[rbp-80h]
    1bb: mov     [rbp-0C0h],rax
    1c2: call    fn1
    1c7: nop     [rcx-78h]
    1ce: mov     rax,[rbp-50h]
    1d2: sub     rax,1
    1d6: mov     [rbp-50h],rax
    1da: mov     edi,0FFFFFF64h
    1df: mov     esi,0FFFFFF88h
    1e4: xor     edx,edx
    1e6: xor     ecx,ecx
    1e8: xor     r8d,r8d
    1eb: mov     r9d,1
    1f1: call    ryo_h_DiscrNicheW64
    1f6: mov     edi,0FFFFFFC8h
    1fb: mov     esi,0FFFFFF64h
    200: call    ryo_h_ZextW32W64
    205: mov     edi,0FFFFFFC8h
    20a: xor     esi,esi
    20c: mov     edx,2
    211: call    ryo_h_SwitchDenseW64
    216: lea     rcx,[228h]
    21d: movsxd  rax,[rcx+rax*4]
    221: add     rax,rcx
    224: jmp     rax
    226: int3
    227: int3
    228: .long   c0h
    22c: .long   97h
    230: .long   90h
    234: nop     [rax+rax]
    23d: nop     [rax]
    240: mov     rax,[rbp-88h]
    247: mov     [rbp-90h],rax
    24e: mov     rax,[rbp-90h]
    255: mov     [rbp-0C0h],rax
    25c: mov     edi,0FFFFFF60h
    261: lea     rsi,[sym2]
    268: call    ryo_h_AddrSym
    26d: mov     rdi,rbp
    270: lea     rsi,[ro+4]
    277: call    qword ptr [sym3]
    27d: jmp     2FBh
    27f: mov     qword ptr [rbp-88h],8
    28a: jmp     240h
    28c: mov     rax,[rbp-80h]
    290: mov     [rbp-98h],rax
    297: mov     rax,[rbp-98h]
    29e: mov     [rbp-90h],rax
    2a5: mov     byte ptr [rbp-99h],0
    2ac: test    byte ptr [rbp-99h],0FFh
    2b3: je      2D5h
    2b5: jmp     2C5h
    2b7: nop     [rax+rax]
    2c0: jmp     240h
    2c5: mov     rax,[rbp-90h]
    2cc: mov     [rbp-88h],rax
    2d3: jmp     2C0h
    2d5: mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    2e0: mov     rax,[rbp-90h]
    2e7: imul    rcx,[rbp-0A0h],10h
    2ef: add     rax,rcx
    2f2: mov     [rbp-88h],rax
    2f9: jmp     2C0h
    2fb: jmp     70h

fn hashbrown::raw::RawTableInner::drop_inner_table::<(std::string::String, usize), std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-28h],rax
     17: cmp     qword ptr [rbp-28h],0
     1c: sete    [rbp-19h]
     20: test    byte ptr [rbp-19h],0FFh
     24: jne     80h
     26: mov     rax,[rbp+10h]
     2a: mov     [rbp-90h],rax
     31: call    fn0
     36: nop     [rcx]
     3d: mov     rax,[rbp+10h]
     41: mov     rax,[rax+8]
     45: mov     [rbp-50h],rax
     49: mov     rax,[rbp-50h]
     4d: add     rax,1
     51: mov     [rbp-40h],rax
     55: mov     edi,0FFFFFF70h
     5a: mov     esi,20h
     5f: call    ryo_h_MovW128
     64: mov     rax,[rbp-40h]
     68: mov     [rbp-80h],rax
     6c: call    fn1
     71: nop     [rcx-38h]
     78: jmp     92h
     7a: nop     [rax+rax]
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
     e8: mov     rax,[rbp-38h]
     ec: mov     [rbp-30h],rax
     f0: mov     rax,[rbp-68h]
     f4: mov     [rbp-40h],rax
     f8: mov     qword ptr [rbp-70h],0
    100: mov     rax,[rbp-70h]
    104: sub     rax,[rbp-40h]
    108: mov     [rbp-38h],rax
    10c: mov     rax,[rbp-30h]
    110: imul    rcx,[rbp-38h],1
    115: add     rax,rcx
    118: mov     [rbp-28h],rax
    11c: mov     rax,[rbp-28h]
    120: mov     [rbp-48h],rax
    124: mov     rax,[rbp+18h]
    128: mov     [rbp-90h],rax
    12f: mov     rax,[rbp-48h]
    133: mov     [rbp-88h],rax
    13a: mov     edi,0FFFFFF80h
    13f: mov     esi,0FFFFFFA0h
    144: call    ryo_h_MovW128
    149: call    fn2
    14e: nop     [rcx]
    155: jmp     90h

fn hashbrown::raw::RawTableInner::drop_inner_table::<(u64, u64), std::alloc::Global>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-28h],rax
     17: cmp     qword ptr [rbp-28h],0
     1c: sete    [rbp-19h]
     20: test    byte ptr [rbp-19h],0FFh
     24: jne     80h
     26: mov     rax,[rbp+10h]
     2a: mov     [rbp-90h],rax
     31: call    fn0
     36: nop     [rcx]
     3d: mov     rax,[rbp+10h]
     41: mov     rax,[rax+8]
     45: mov     [rbp-50h],rax
     49: mov     rax,[rbp-50h]
     4d: add     rax,1
     51: mov     [rbp-40h],rax
     55: mov     edi,0FFFFFF70h
     5a: mov     esi,20h
     5f: call    ryo_h_MovW128
     64: mov     rax,[rbp-40h]
     68: mov     [rbp-80h],rax
     6c: call    fn1
     71: nop     [rcx-38h]
     78: jmp     92h
     7a: nop     [rax+rax]
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
     e8: mov     rax,[rbp-38h]
     ec: mov     [rbp-30h],rax
     f0: mov     rax,[rbp-68h]
     f4: mov     [rbp-40h],rax
     f8: mov     qword ptr [rbp-70h],0
    100: mov     rax,[rbp-70h]
    104: sub     rax,[rbp-40h]
    108: mov     [rbp-38h],rax
    10c: mov     rax,[rbp-30h]
    110: imul    rcx,[rbp-38h],1
    115: add     rax,rcx
    118: mov     [rbp-28h],rax
    11c: mov     rax,[rbp-28h]
    120: mov     [rbp-48h],rax
    124: mov     rax,[rbp+18h]
    128: mov     [rbp-90h],rax
    12f: mov     rax,[rbp-48h]
    133: mov     [rbp-88h],rax
    13a: mov     edi,0FFFFFF80h
    13f: mov     esi,0FFFFFFA0h
    144: call    ryo_h_MovW128
    149: call    fn2
    14e: nop     [rcx]
    155: jmp     90h

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
     3a: mov     rax,[rbp-78h]
     3e: mov     [rbp-70h],rax
     42: mov     rax,[rbp-70h]
     46: imul    rcx,[rbp-60h],1
     4b: add     rax,rcx
     4e: mov     [rbp-20h],rax
     52: mov     rax,[rbp-20h]
     56: mov     [rbp-68h],rax
     5a: mov     rax,[rbp-20h]
     5e: mov     [rbp-70h],rax
     62: mov     rax,[rbp-70h]
     66: mov     [rbp-0C0h],rax
     6d: mov     edi,0FFFFFF70h
     72: lea     rsi,[sym0]
     79: call    ryo_h_AddrSym
     7e: mov     rdi,rbp
     81: lea     rsi,[ro+4]
     88: call    qword ptr [sym1]
     8e: jmp     1C5h
     93: nop     [rax+rax]
     9c: nop     [rax]
     a0: mov     byte ptr [rbp-11h],80h
     a4: jmp     0E4h
     a6: nop     [rax+rax]
     af: nop
     b0: mov     rax,[rbp+10h]
     b4: mov     rax,[rax+10h]
     b8: mov     [rbp-90h],rax
     bf: mov     rax,[rbp-90h]
     c6: add     rax,1
     ca: mov     [rbp-0A0h],rax
     d1: mov     rax,[rbp+10h]
     d5: mov     rcx,[rbp-0A0h]
     dc: mov     [rax+10h],rcx
     e0: mov     byte ptr [rbp-11h],0FFh
     e4: mov     rax,[rbp+18h]
     e8: sub     rax,10h
     ec: mov     [rbp-78h],rax
     f0: mov     rax,[rbp+10h]
     f4: mov     rax,[rax+8]
     f8: mov     [rbp-80h],rax
     fc: mov     rax,[rbp-78h]
    100: and     rax,[rbp-80h]
    104: mov     [rbp-70h],rax
    108: mov     rax,[rbp-70h]
    10c: add     rax,10h
    110: mov     [rbp-68h],rax
    114: mov     rax,[rbp+10h]
    118: mov     rax,[rax]
    11b: mov     [rbp-88h],rax
    122: mov     rax,[rbp-88h]
    129: mov     [rbp-80h],rax
    12d: mov     rax,[rbp-80h]
    131: imul    rcx,[rbp+18h],1
    136: add     rax,rcx
    139: mov     [rbp-78h],rax
    13d: mov     rax,[rbp-78h]
    141: mov     [rbp-70h],rax
    145: mov     rax,[rbp-70h]
    149: movzx   ecx,byte ptr [rbp-11h]
    14d: mov     [rax],cl
    14f: mov     rax,[rbp+10h]
    153: mov     rax,[rax]
    156: mov     [rbp-88h],rax
    15d: mov     rax,[rbp-88h]
    164: mov     [rbp-80h],rax
    168: mov     rax,[rbp-80h]
    16c: imul    rcx,[rbp-68h],1
    171: add     rax,rcx
    174: mov     [rbp-78h],rax
    178: mov     rax,[rbp-78h]
    17c: mov     [rbp-70h],rax
    180: mov     rax,[rbp-70h]
    184: movzx   ecx,byte ptr [rbp-11h]
    188: mov     [rax],cl
    18a: mov     rax,[rbp+10h]
    18e: mov     rax,[rax+18h]
    192: mov     [rbp-90h],rax
    199: mov     rax,[rbp-90h]
    1a0: sub     rax,1
    1a4: mov     [rbp-0A0h],rax
    1ab: mov     rax,[rbp+10h]
    1af: mov     rcx,[rbp-0A0h]
    1b6: mov     [rax+18h],rcx
    1ba: xor     edi,edi
    1bc: xor     esi,esi
    1be: call    ryo_h_Ret
    1c3: leave
    1c4: ret
    1c5: mov     byte ptr [rbp-0C0h],0FFh
    1cc: mov     edi,0FFFFFF70h
    1d1: lea     rsi,[sym2]
    1d8: call    ryo_h_AddrSym
    1dd: mov     rdi,rbp
    1e0: lea     rsi,[ro+20]
    1e7: call    qword ptr [sym3]
    1ed: mov     edi,0FFFFFF40h
    1f2: mov     esi,0FFFFFFD0h
    1f7: call    ryo_h_MovW128
    1fc: mov     edi,0FFFFFF50h
    201: mov     esi,0FFFFFF80h
    206: call    ryo_h_MovW128
    20b: mov     edi,0FFFFFF70h
    210: lea     rsi,[sym4]
    217: call    ryo_h_AddrSym
    21c: mov     rdi,rbp
    21f: lea     rsi,[ro+36]
    226: call    qword ptr [sym5]
    22c: mov     edi,0FFFFFF40h
    231: mov     esi,0FFFFFF90h
    236: call    ryo_h_MovW128
    23b: mov     edi,0FFFFFF70h
    240: lea     rsi,[sym6]
    247: call    ryo_h_AddrSym
    24c: mov     rdi,rbp
    24f: lea     rsi,[ro+52]
    256: call    qword ptr [sym7]
    25c: mov     edi,0FFFFFFCEh
    261: mov     esi,0FFFFFF8Ch
    266: call    ryo_h_TruncW32W16
    26b: mov     rax,[rbp+10h]
    26f: mov     rax,[rax]
    272: mov     [rbp-78h],rax
    276: mov     rax,[rbp-78h]
    27a: mov     [rbp-70h],rax
    27e: mov     rax,[rbp-70h]
    282: imul    rcx,[rbp+18h],1
    287: add     rax,rcx
    28a: mov     [rbp-40h],rax
    28e: mov     rax,[rbp-40h]
    292: mov     [rbp-68h],rax
    296: mov     rax,[rbp-40h]
    29a: mov     [rbp-70h],rax
    29e: mov     rax,[rbp-70h]
    2a2: mov     [rbp-0C0h],rax
    2a9: mov     edi,0FFFFFF70h
    2ae: lea     rsi,[sym8]
    2b5: call    ryo_h_AddrSym
    2ba: mov     rdi,rbp
    2bd: lea     rsi,[ro+68]
    2c4: call    qword ptr [sym9]
    2ca: mov     byte ptr [rbp-0C0h],0FFh
    2d1: mov     edi,0FFFFFF70h
    2d6: lea     rsi,[sym10]
    2dd: call    ryo_h_AddrSym
    2e2: mov     rdi,rbp
    2e5: lea     rsi,[ro+20]
    2ec: call    qword ptr [sym11]
    2f2: mov     edi,0FFFFFF40h
    2f7: mov     esi,0FFFFFFB0h
    2fc: call    ryo_h_MovW128
    301: mov     edi,0FFFFFF50h
    306: mov     esi,0FFFFFF80h
    30b: call    ryo_h_MovW128
    310: mov     edi,0FFFFFF70h
    315: lea     rsi,[sym12]
    31c: call    ryo_h_AddrSym
    321: mov     rdi,rbp
    324: lea     rsi,[ro+36]
    32b: call    qword ptr [sym13]
    331: mov     edi,0FFFFFF40h
    336: mov     esi,0FFFFFF90h
    33b: call    ryo_h_MovW128
    340: mov     edi,0FFFFFF70h
    345: lea     rsi,[sym14]
    34c: call    ryo_h_AddrSym
    351: mov     rdi,rbp
    354: lea     rsi,[ro+52]
    35b: call    qword ptr [sym15]
    361: mov     edi,0FFFFFFAEh
    366: mov     esi,0FFFFFF8Ch
    36b: call    ryo_h_TruncW32W16
    370: mov     edi,0FFFFFF74h
    375: mov     esi,0FFFFFFCEh
    37a: call    ryo_h_CtlzW16
    37f: mov     eax,[rbp-8Ch]
    385: mov     [rbp-74h],eax
    388: mov     edi,0FFFFFF90h
    38d: mov     esi,0FFFFFF8Ch
    392: call    ryo_h_ZextW32W64
    397: mov     edi,0FFFFFF74h
    39c: mov     esi,0FFFFFFAEh
    3a1: call    ryo_h_CttzW16
    3a6: mov     eax,[rbp-8Ch]
    3ac: mov     [rbp-7Ch],eax
    3af: mov     edi,0FFFFFF88h
    3b4: mov     esi,0FFFFFF84h
    3b9: call    ryo_h_ZextW32W64
    3be: mov     rax,[rbp-70h]
    3c2: add     rax,[rbp-78h]
    3c6: mov     [rbp-68h],rax
    3ca: cmp     qword ptr [rbp-68h],10h
    3cf: jae     0A0h
    3d5: jmp     0B0h

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
     88: .long   168h
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
     f0: .long   308h
     f4: .long   27fh
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
    163: jmp     1EFh
    168: mov     rax,[rbp-88h]
    16f: mov     [rbp-0A0h],rax
    176: mov     rax,[rbp-0A0h]
    17d: mov     [rbp-78h],rax
    181: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    189: mov     rax,[rbp-78h]
    18d: mov     [rbp-88h],rax
    194: mov     rax,[rbp-88h]
    19b: mov     [rbp-68h],rax
    19f: mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    1a7: mov     rax,[rbp-68h]
    1ab: mov     [rbp-30h],rax
    1af: mov     rax,[rbp+10h]
    1b3: mov     [rbp-100h],rax
    1ba: mov     edi,0FFFFFF08h
    1bf: mov     esi,18h
    1c4: call    ryo_h_MovW128
    1c9: mov     rax,[rbp-30h]
    1cd: mov     [rbp-0E8h],rax
    1d4: movzx   eax,byte ptr [rbp+30h]
    1d8: mov     [rbp-0E0h],al
    1de: call    fn5
    1e3: nop     [rcx-0A0h]
    1ea: jmp     0A0h
    1ef: mov     edi,0FFFFFF80h
    1f4: mov     esi,0FFFFFF58h
    1f9: call    ryo_h_MovW128
    1fe: mov     edi,0FFFFFF70h
    203: mov     esi,0FFFFFF80h
    208: call    ryo_h_MovW128
    20d: mov     edi,0FFFFFF60h
    212: mov     esi,0FFFFFF70h
    217: call    ryo_h_MovW128
    21c: mov     edi,0FFFFFF90h
    221: mov     esi,0FFFFFF60h
    226: call    ryo_h_MovW128
    22b: mov     edi,0FFFFFF80h
    230: mov     esi,0FFFFFF90h
    235: call    ryo_h_MovW128
    23a: mov     qword ptr [rbp-88h],1
    245: cmp     qword ptr [rbp-88h],1
    24d: sete    [rbp-99h]
    254: mov     edi,0FFFFFF68h
    259: mov     esi,0FFFFFF80h
    25e: call    ryo_h_MovW128
    263: mov     edi,0FFFFFFE8h
    268: mov     esi,0FFFFFF68h
    26d: call    ryo_h_MovW128
    272: mov     qword ptr [rbp-20h],0
    27a: jmp     110h
    27f: mov     edi,0FFFFFF48h
    284: mov     esi,0FFFFFF68h
    289: call    ryo_h_MovW128
    28e: mov     edi,0FFFFFF38h
    293: mov     esi,0FFFFFF48h
    298: call    ryo_h_MovW128
    29d: mov     edi,0FFFFFF88h
    2a2: mov     esi,0FFFFFF38h
    2a7: call    ryo_h_MovW128
    2ac: mov     qword ptr [rbp-80h],0
    2b4: mov     edi,0FFFFFF70h
    2b9: mov     esi,0FFFFFF88h
    2be: call    ryo_h_MovW128
    2c3: mov     qword ptr [rbp-98h],1
    2ce: cmp     qword ptr [rbp-98h],1
    2d6: sete    [rbp-0A9h]
    2dd: mov     edi,0FFFFFF58h
    2e2: mov     esi,0FFFFFF70h
    2e7: call    ryo_h_MovW128
    2ec: mov     edi,0FFFFFFE8h
    2f1: mov     esi,0FFFFFF58h
    2f6: call    ryo_h_MovW128
    2fb: mov     qword ptr [rbp-20h],0
    303: jmp     110h
    308: mov     edi,0FFFFFF38h
    30d: mov     esi,0FFFFFF60h
    312: mov     edx,20h
    317: call    ryo_h_Copy
    31c: mov     edi,0FFFFFF80h
    321: mov     esi,0FFFFFF38h
    326: mov     edx,20h
    32b: call    ryo_h_Copy
    330: mov     edi,0FFFFFFB0h
    335: mov     esi,0FFFFFF80h
    33a: mov     edx,20h
    33f: call    ryo_h_Copy
    344: mov     rax,[rbp-50h]
    348: mov     [rbp-80h],rax
    34c: mov     rax,[rbp-80h]
    350: mov     [rbp-78h],rax
    354: mov     rax,[rbp-48h]
    358: mov     [rbp-90h],rax
    35f: mov     rax,[rbp-90h]
    366: add     rax,1
    36a: mov     [rbp-88h],rax
    371: mov     rax,[rbp-88h]
    378: add     rax,10h
    37c: mov     [rbp-60h],rax
    380: mov     rax,[rbp-78h]
    384: mov     [rbp-90h],rax
    38b: mov     rax,[rbp-60h]
    38f: mov     [rbp-88h],rax
    396: mov     rax,[rbp-90h]
    39d: mov     [rbp-70h],rax
    3a1: mov     rax,[rbp-88h]
    3a8: mov     [rbp-68h],rax
    3ac: mov     rax,[rbp-70h]
    3b0: mov     [rbp-88h],rax
    3b7: mov     rax,[rbp-68h]
    3bb: mov     [rbp-80h],rax
    3bf: mov     rax,[rbp-88h]
    3c6: mov     [rbp-78h],rax
    3ca: mov     byte ptr [rbp-0C9h],0FFh
    3d1: imul    rax,[rbp-60h],1
    3d6: mov     [rbp-0D8h],rax
    3dd: mov     edi,0FFFFFF88h
    3e2: mov     esi,0FFFFFF37h
    3e7: mov     edx,0FFFFFF28h
    3ec: call    ryo_h_Memset
    3f1: mov     edi,0FFFFFFE0h
    3f6: mov     esi,0FFFFFFB0h
    3fb: mov     edx,20h
    400: call    ryo_h_Copy
    405: jmp     100h

fn hashbrown::raw::RawTableInner::find_inner
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: mov     rax,[rbp+18h]
      f: shr     rax,39h
     13: mov     [rbp-78h],rax
     17: mov     rax,[rbp-78h]
     1b: and     rax,7Fh
     1f: mov     [rbp-80h],rax
     23: mov     edi,0FFFFFFD7h
     28: mov     esi,0FFFFFF80h
     2d: call    ryo_h_TruncW64W8
     32: mov     rax,[rbp+18h]
     36: mov     [rbp-90h],rax
     3d: mov     rax,[rbp+10h]
     41: mov     rax,[rax+8]
     45: mov     [rbp-98h],rax
     4c: mov     rax,[rbp-90h]
     53: and     rax,[rbp-98h]
     5a: mov     [rbp-88h],rax
     61: mov     rax,[rbp-88h]
     68: mov     [rbp-80h],rax
     6c: mov     qword ptr [rbp-78h],0
     74: nop     [rax+rax]
     7d: nop     [rax]
     80: mov     rax,[rbp-80h]
     84: mov     [rbp-90h],rax
     8b: mov     rax,[rbp+10h]
     8f: mov     rax,[rax]
     92: mov     [rbp-0A0h],rax
     99: mov     rax,[rbp-0A0h]
     a0: mov     [rbp-98h],rax
     a7: mov     rax,[rbp-98h]
     ae: imul    rcx,[rbp-90h],1
     b6: add     rax,rcx
     b9: mov     [rbp-38h],rax
     bd: mov     rax,[rbp-38h]
     c1: mov     [rbp-88h],rax
     c8: mov     rax,[rbp-38h]
     cc: mov     [rbp-90h],rax
     d3: mov     rax,[rbp-90h]
     da: mov     [rbp-0E0h],rax
     e1: mov     edi,0FFFFFF40h
     e6: lea     rsi,[sym0]
     ed: call    ryo_h_AddrSym
     f2: mov     rdi,rbp
     f5: lea     rsi,[ro+4]
     fc: call    qword ptr [sym1]
    102: jmp     1B1h
    107: nop     [rax+rax]
    110: movzx   eax,word ptr [rbp-12h]
    114: mov     [rbp-0B6h],ax
    11b: movzx   eax,word ptr [rbp-0B6h]
    122: mov     [rbp-6Ch],ax
    126: mov     edi,0FFFFFF44h
    12b: mov     esi,0FFFFFF94h
    130: xor     edx,edx
    132: xor     ecx,ecx
    134: xor     r8d,r8d
    137: mov     r9d,1
    13d: call    ryo_h_DiscrNicheW16
    142: mov     edi,0FFFFFF58h
    147: mov     esi,0FFFFFF44h
    14c: call    ryo_h_ZextW32W64
    151: mov     edi,0FFFFFF58h
    156: xor     esi,esi
    158: mov     edx,2
    15d: call    ryo_h_SwitchDenseW64
    162: lea     rcx,[174h]
    169: movsxd  rax,[rcx+rax*4]
    16d: add     rax,rcx
    170: jmp     rax
    172: int3
    173: int3
    174: .long   2a3h
    178: .long   276h
    17c: .long   180h
    180: call    ryo_h_Unreachable
    185: ud2
    187: nop     [rax+rax]
    190: test    byte ptr [rbp-6Bh],0FFh
    194: je      4E4h
    19a: jmp     4CCh
    19f: nop
    1a0: mov     edi,0FFFFFFF0h
    1a5: mov     esi,10h
    1aa: call    ryo_h_Ret
    1af: leave
    1b0: ret
    1b1: movzx   eax,byte ptr [rbp-29h]
    1b5: mov     [rbp-6Dh],al
    1b8: movzx   eax,byte ptr [rbp-6Dh]
    1bc: mov     [rbp-0E0h],al
    1c2: mov     edi,0FFFFFF40h
    1c7: lea     rsi,[sym2]
    1ce: call    ryo_h_AddrSym
    1d3: mov     rdi,rbp
    1d6: lea     rsi,[ro+20]
    1dd: call    qword ptr [sym3]
    1e3: mov     edi,0FFFFFF20h
    1e8: mov     esi,0FFFFFFB0h
    1ed: call    ryo_h_MovW128
    1f2: mov     edi,0FFFFFF30h
    1f7: mov     esi,0FFFFFF60h
    1fc: call    ryo_h_MovW128
    201: mov     edi,0FFFFFF40h
    206: lea     rsi,[sym4]
    20d: call    ryo_h_AddrSym
    212: mov     rdi,rbp
    215: lea     rsi,[ro+36]
    21c: call    qword ptr [sym5]
    222: mov     edi,0FFFFFF20h
    227: mov     esi,0FFFFFF70h
    22c: call    ryo_h_MovW128
    231: mov     edi,0FFFFFF40h
    236: lea     rsi,[sym6]
    23d: call    ryo_h_AddrSym
    242: mov     rdi,rbp
    245: lea     rsi,[ro+52]
    24c: call    qword ptr [sym7]
    252: mov     edi,0FFFFFF92h
    257: mov     esi,0FFFFFF6Ch
    25c: call    ryo_h_TruncW32W16
    261: movzx   eax,word ptr [rbp-6Eh]
    265: mov     [rbp-6Ch],ax
    269: movzx   eax,word ptr [rbp-6Ch]
    26d: mov     [rbp-12h],ax
    271: jmp     110h
    276: movzx   eax,word ptr [rbp-6Ch]
    27a: mov     [rbp-6Eh],ax
    27e: movzx   eax,word ptr [rbp-6Eh]
    282: mov     [rbp-70h],ax
    286: mov     edi,0FFFFFF44h
    28b: mov     esi,0FFFFFF90h
    290: call    ryo_h_CttzW16
    295: mov     eax,[rbp-0BCh]
    29b: mov     [rbp-0B4h],eax
    2a1: jmp     2FDh
    2a3: mov     edi,0FFFFFF60h
    2a8: lea     rsi,[k8]
    2af: mov     edx,10h
    2b4: call    ryo_h_Const
    2b9: mov     qword ptr [rbp-98h],0
    2c4: cmp     qword ptr [rbp-98h],0
    2cc: sete    [rbp-6Bh]
    2d0: mov     byte ptr [rbp-0E0h],0FFh
    2d7: mov     edi,0FFFFFF40h
    2dc: lea     rsi,[sym9]
    2e3: call    ryo_h_AddrSym
    2e8: mov     rdi,rbp
    2eb: lea     rsi,[ro+20]
    2f2: call    qword ptr [sym10]
    2f8: jmp     43Ch
    2fd: mov     edi,0FFFFFF50h
    302: mov     esi,0FFFFFF4Ch
    307: call    ryo_h_ZextW32W64
    30c: mov     rax,[rbp-0B0h]
    313: mov     [rbp-98h],rax
    31a: mov     qword ptr [rbp-0A0h],1
    325: mov     rax,[rbp-98h]
    32c: mov     [rbp-68h],rax
    330: movzx   eax,word ptr [rbp-12h]
    334: mov     [rbp-92h],ax
    33b: movzx   eax,word ptr [rbp-92h]
    342: sub     eax,1
    345: mov     [rbp-70h],ax
    349: movzx   eax,word ptr [rbp-92h]
    350: and     ax,[rbp-70h]
    354: mov     [rbp-6Eh],ax
    358: movzx   eax,word ptr [rbp-6Eh]
    35c: mov     [rbp-6Ch],ax
    360: movzx   eax,word ptr [rbp-6Ch]
    364: mov     [rbp-12h],ax
    368: mov     rax,[rbp-68h]
    36c: mov     [rbp-88h],rax
    373: mov     qword ptr [rbp-90h],1
    37e: mov     rax,[rbp-88h]
    385: mov     [rbp-98h],rax
    38c: mov     rax,[rbp-80h]
    390: mov     [rbp-0B0h],rax
    397: mov     rax,[rbp-0B0h]
    39e: add     rax,[rbp-98h]
    3a5: mov     [rbp-0A8h],rax
    3ac: mov     rax,[rbp+10h]
    3b0: mov     rax,[rax+8]
    3b4: mov     [rbp-0B0h],rax
    3bb: mov     rax,[rbp-0A8h]
    3c2: and     rax,[rbp-0B0h]
    3c9: mov     [rbp-0A0h],rax
    3d0: mov     rax,[rbp-0A0h]
    3d7: mov     [rbp-0A8h],rax
    3de: mov     rax,[rbp+28h]
    3e2: mov     rax,[rax+20h]
    3e6: mov     [rbp-0C0h],rax
    3ed: mov     rax,[rbp+20h]
    3f1: mov     [rbp-0E0h],rax
    3f8: mov     rax,[rbp-0A8h]
    3ff: mov     [rbp-0D8h],rax
    406: mov     edi,0FFFFFF40h
    40b: lea     rsi,[site11]
    412: call    ryo_h_CallInd
    417: test    rax,rax
    41a: je      427h
    41c: call    rax
    41e: nop     [rcx-6Bh]
    425: jmp     437h
    427: mov     rdi,rbp
    42a: lea     rsi,[ro+68]
    431: call    qword ptr [sym12]
    437: jmp     190h
    43c: mov     edi,0FFFFFF20h
    441: mov     esi,0FFFFFFB0h
    446: call    ryo_h_MovW128
    44b: mov     edi,0FFFFFF30h
    450: mov     esi,0FFFFFF60h
    455: call    ryo_h_MovW128
    45a: mov     edi,0FFFFFF40h
    45f: lea     rsi,[sym13]
    466: call    ryo_h_AddrSym
    46b: mov     rdi,rbp
    46e: lea     rsi,[ro+36]
    475: call    qword ptr [sym14]
    47b: mov     edi,0FFFFFF20h
    480: mov     esi,0FFFFFF70h
    485: call    ryo_h_MovW128
    48a: mov     edi,0FFFFFF40h
    48f: lea     rsi,[sym15]
    496: call    ryo_h_AddrSym
    49b: mov     rdi,rbp
    49e: lea     rsi,[ro+84]
    4a5: call    qword ptr [sym16]
    4ab: mov     edi,0FFFFFF96h
    4b0: mov     esi,0FFFFFF90h
    4b5: call    ryo_h_TruncW32W16
    4ba: cmp     word ptr [rbp-6Ah],0
    4bf: setne   [rbp-6Bh]
    4c3: cmp     word ptr [rbp-6Ah],0
    4c8: je      504h
    4ca: jmp     4E9h
    4cc: mov     rax,[rbp-0A0h]
    4d3: mov     [rbp-8],rax
    4d7: mov     qword ptr [rbp-10h],1
    4df: jmp     1A0h
    4e4: jmp     110h
    4e9: mov     edi,0FFFFFFF0h
    4ee: lea     rsi,[k17]
    4f5: mov     edx,10h
    4fa: call    ryo_h_Const
    4ff: jmp     1A0h
    504: mov     rax,[rbp+10h]
    508: mov     rax,[rax+8]
    50c: mov     [rbp-88h],rax
    513: mov     rax,[rbp-78h]
    517: add     rax,10h
    51b: mov     [rbp-78h],rax
    51f: mov     rax,[rbp-78h]
    523: mov     [rbp-90h],rax
    52a: mov     rax,[rbp-80h]
    52e: add     rax,[rbp-90h]
    535: mov     [rbp-80h],rax
    539: mov     rax,[rbp-80h]
    53d: and     rax,[rbp-88h]
    544: mov     [rbp-80h],rax
    548: jmp     80h

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
     2b: mov     rax,[rbp-48h]
     2f: mov     [rbp-40h],rax
     33: mov     qword ptr [rbp-38h],0
     3b: nop     [rax+rax]
     40: mov     rax,[rbp-40h]
     44: mov     [rbp-60h],rax
     48: mov     rax,[rbp+10h]
     4c: mov     rax,[rax]
     4f: mov     [rbp-70h],rax
     53: mov     rax,[rbp-70h]
     57: mov     [rbp-68h],rax
     5b: mov     rax,[rbp-68h]
     5f: imul    rcx,[rbp-60h],1
     64: add     rax,rcx
     67: mov     [rbp-20h],rax
     6b: mov     rax,[rbp-20h]
     6f: mov     [rbp-58h],rax
     73: mov     rax,[rbp-20h]
     77: mov     [rbp-60h],rax
     7b: mov     rax,[rbp-60h]
     7f: mov     [rbp-90h],rax
     86: mov     edi,0FFFFFF88h
     8b: lea     rsi,[sym0]
     92: call    ryo_h_AddrSym
     97: mov     rdi,rbp
     9a: lea     rsi,[ro+4]
     a1: call    qword ptr [sym1]
     a7: jmp     0E1h
     a9: nop     [rax]
     b0: mov     rax,[rbp-60h]
     b4: mov     [rbp-28h],rax
     b8: cmp     qword ptr [rbp-28h],1
     bd: sete    [rbp-2Ah]
     c1: cmp     qword ptr [rbp-28h],1
     c6: je      12Ch
     c8: jmp     164h
     cd: nop     [rax]
     d0: mov     edi,0FFFFFFF8h
     d5: mov     esi,8
     da: call    ryo_h_Ret
     df: leave
     e0: ret
     e1: mov     edi,0FFFFFFB0h
     e6: mov     esi,0FFFFFF90h
     eb: call    ryo_h_MovW128
     f0: lea     rax,[rbp-50h]
     f4: mov     [rbp-68h],rax
     f8: lea     rax,[rbp-40h]
     fc: mov     [rbp-70h],rax
    100: mov     rax,[rbp+10h]
    104: mov     [rbp-90h],rax
    10b: mov     rax,[rbp-68h]
    10f: mov     [rbp-88h],rax
    116: mov     rax,[rbp-70h]
    11a: mov     [rbp-80h],rax
    11e: call    fn2
    123: nop     [rcx-60h]
    12a: jmp     0B0h
    12c: cmp     qword ptr [rbp-28h],1
    131: sete    [rbp-29h]
    135: mov     rax,[rbp-58h]
    139: mov     [rbp-68h],rax
    13d: mov     rax,[rbp+10h]
    141: mov     [rbp-90h],rax
    148: mov     rax,[rbp-68h]
    14c: mov     [rbp-88h],rax
    153: call    fn3
    158: nop     [rcx-8]
    15f: jmp     0D0h
    164: mov     rax,[rbp+10h]
    168: mov     rax,[rax+8]
    16c: mov     [rbp-68h],rax
    170: mov     rax,[rbp-38h]
    174: add     rax,10h
    178: mov     [rbp-38h],rax
    17c: mov     rax,[rbp-38h]
    180: mov     [rbp-70h],rax
    184: mov     rax,[rbp-40h]
    188: add     rax,[rbp-70h]
    18c: mov     [rbp-40h],rax
    190: mov     rax,[rbp-40h]
    194: and     rax,[rbp-68h]
    198: mov     [rbp-40h],rax
    19c: jmp     40h

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
     c4: .long   f7h
     c8: .long   d0h
     cc: .long   19fh
     d0: movzx   eax,word ptr [rbp-36h]
     d4: mov     [rbp-38h],ax
     d8: movzx   eax,word ptr [rbp-38h]
     dc: mov     [rbp-4Eh],ax
     e0: mov     edi,0FFFFFFA4h
     e5: mov     esi,0FFFFFFB2h
     ea: call    ryo_h_CttzW16
     ef: mov     eax,[rbp-5Ch]
     f2: mov     [rbp-4Ch],eax
     f5: jmp     123h
     f7: mov     edi,0FFFFFFE0h
     fc: lea     rsi,[k2]
    103: mov     edx,10h
    108: call    ryo_h_Const
    10d: mov     rax,[rbp-20h]
    111: mov     [rbp-40h],rax
    115: cmp     qword ptr [rbp-40h],1
    11a: sete    [rbp-35h]
    11e: jmp     1A6h
    123: mov     edi,0FFFFFFB8h
    128: mov     esi,0FFFFFFB4h
    12d: call    ryo_h_ZextW32W64
    132: mov     rax,[rbp-48h]
    136: mov     [rbp-18h],rax
    13a: mov     qword ptr [rbp-20h],1
    142: mov     rax,[rbp-20h]
    146: mov     [rbp-40h],rax
    14a: cmp     qword ptr [rbp-40h],1
    14f: sete    [rbp-35h]
    153: mov     rax,[rbp+20h]
    157: mov     rax,[rax]
    15a: mov     [rbp-50h],rax
    15e: mov     rax,[rbp-18h]
    162: mov     [rbp-58h],rax
    166: mov     rax,[rbp-50h]
    16a: add     rax,[rbp-58h]
    16e: mov     [rbp-48h],rax
    172: mov     rax,[rbp+10h]
    176: mov     rax,[rax+8]
    17a: mov     [rbp-50h],rax
    17e: mov     rax,[rbp-48h]
    182: and     rax,[rbp-50h]
    186: mov     [rbp-40h],rax
    18a: mov     rax,[rbp-40h]
    18e: mov     [rbp-8],rax
    192: mov     qword ptr [rbp-10h],1
    19a: jmp     50h
    19f: call    ryo_h_Unreachable
    1a4: ud2
    1a6: mov     edi,0FFFFFFF0h
    1ab: lea     rsi,[k3]
    1b2: mov     edx,10h
    1b7: call    ryo_h_Const
    1bc: jmp     50h

fn hashbrown::raw::RawTableInner::fix_insert_index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-58h],rax
     13: mov     rax,[rbp+10h]
     17: mov     rax,[rax]
     1a: mov     [rbp-78h],rax
     1e: mov     rax,[rbp-78h]
     22: mov     [rbp-70h],rax
     26: mov     rax,[rbp-70h]
     2a: imul    rcx,[rbp-58h],1
     2f: add     rax,rcx
     32: mov     [rbp-68h],rax
     36: mov     rax,[rbp-68h]
     3a: mov     [rbp-60h],rax
     3e: mov     rax,[rbp-60h]
     42: movzx   eax,byte ptr [rax]
     45: mov     [rbp-50h],al
     48: movzx   eax,byte ptr [rbp-50h]
     4c: and     al,80h
     4f: mov     [rbp-4Fh],al
     52: cmp     byte ptr [rbp-4Fh],0
     56: sete    [rbp-4Eh]
     5a: test    byte ptr [rbp-4Eh],0FFh
     5e: je      0D2h
     60: jmp     89h
     62: nop     [rax+rax]
     6b: nop     [rax+rax]
     70: mov     rax,[rbp+18h]
     74: mov     [rbp-8],rax
     78: mov     edi,0FFFFFFF8h
     7d: mov     esi,8
     82: call    ryo_h_Ret
     87: leave
     88: ret
     89: mov     rax,[rbp+10h]
     8d: mov     rax,[rax]
     90: mov     [rbp-10h],rax
     94: mov     rax,[rbp-10h]
     98: mov     [rbp-68h],rax
     9c: mov     rax,[rbp-10h]
     a0: mov     [rbp-70h],rax
     a4: mov     rax,[rbp-70h]
     a8: mov     [rbp-90h],rax
     af: mov     edi,0FFFFFF80h
     b4: lea     rsi,[sym0]
     bb: call    ryo_h_AddrSym
     c0: mov     rdi,rbp
     c3: lea     rsi,[ro+4]
     ca: call    qword ptr [sym1]
     d0: jmp     0D4h
     d2: jmp     70h
     d4: mov     edi,0FFFFFF70h
     d9: mov     esi,0FFFFFFC0h
     de: call    ryo_h_MovW128
     e3: mov     edi,0FFFFFF80h
     e8: lea     rsi,[sym2]
     ef: call    ryo_h_AddrSym
     f4: mov     rdi,rbp
     f7: lea     rsi,[ro+20]
     fe: call    qword ptr [sym3]
    104: mov     edi,0FFFFFFBEh
    109: mov     esi,0FFFFFF9Ch
    10e: call    ryo_h_TruncW32W16
    113: movzx   eax,word ptr [rbp-42h]
    117: mov     [rbp-50h],ax
    11b: mov     edi,0FFFFFF84h
    120: mov     esi,0FFFFFFB0h
    125: xor     edx,edx
    127: xor     ecx,ecx
    129: xor     r8d,r8d
    12c: mov     r9d,1
    132: call    ryo_h_DiscrNicheW16
    137: mov     edi,0FFFFFF98h
    13c: mov     esi,0FFFFFF84h
    141: call    ryo_h_ZextW32W64
    146: mov     edi,0FFFFFF98h
    14b: xor     esi,esi
    14d: mov     edx,2
    152: call    ryo_h_SwitchDenseW64
    157: lea     rcx,[168h]
    15e: movsxd  rax,[rcx+rax*4]
    162: add     rax,rcx
    165: jmp     rax
    167: int3
    168: .long   1c5h
    16c: .long   19eh
    170: .long   1feh
    174: nop     [rax+rax]
    17d: nop     [rax]
    180: mov     rax,[rbp-60h]
    184: mov     [rbp-68h],rax
    188: cmp     qword ptr [rbp-68h],1
    18d: sete    [rbp-4Dh]
    191: mov     rax,[rbp-58h]
    195: mov     [rbp+18h],rax
    199: jmp     70h
    19e: movzx   eax,word ptr [rbp-50h]
    1a2: mov     [rbp-6Ah],ax
    1a6: movzx   eax,word ptr [rbp-6Ah]
    1aa: mov     [rbp-6Ch],ax
    1ae: mov     edi,0FFFFFF84h
    1b3: mov     esi,0FFFFFF94h
    1b8: call    ryo_h_CttzW16
    1bd: mov     eax,[rbp-7Ch]
    1c0: mov     [rbp-70h],eax
    1c3: jmp     1DDh
    1c5: mov     edi,0FFFFFFA0h
    1ca: lea     rsi,[k4]
    1d1: mov     edx,10h
    1d6: call    ryo_h_Const
    1db: jmp     180h
    1dd: mov     edi,0FFFFFF88h
    1e2: mov     esi,0FFFFFF90h
    1e7: call    ryo_h_ZextW32W64
    1ec: mov     rax,[rbp-78h]
    1f0: mov     [rbp-58h],rax
    1f4: mov     qword ptr [rbp-60h],1
    1fc: jmp     180h
    1fe: call    ryo_h_Unreachable
    203: ud2

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
     67: jmp     310h
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
    104: jmp     321h
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
    197: cmp     qword ptr [rbp-0D0h],0
    19f: jne     43Ah
    1a5: mov     edi,0FFFFFEF0h
    1aa: lea     rsi,[k5]
    1b1: call    ryo_h_AddrAbs
    1b6: lea     rdi,[sym6]
    1bd: lea     rsi,[site7]
    1c4: mov     edx,0FFFFFF10h
    1c9: call    ryo_h_CallExt
    1ce: test    rax,rax
    1d1: je      1DEh
    1d3: call    rax
    1d5: nop     [rcx-0E8h]
    1dc: jmp     1EEh
    1de: mov     rdi,rbp
    1e1: lea     rsi,[ro+20]
    1e8: call    qword ptr [sym8]
    1ee: call    ryo_h_Unreachable
    1f3: ud2
    1f5: nop     [rax+rax]
    1fe: xchg    ax,ax
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
    26b: mov     rax,[rbp-0C0h]
    272: mov     [rbp-98h],rax
    279: mov     rax,[rbp-98h]
    280: mov     [rbp-0B0h],rax
    287: mov     rax,[rbp-0B0h]
    28e: imul    rcx,[rbp-78h],1
    293: add     rax,rcx
    296: mov     [rbp-0A8h],rax
    29d: mov     rax,[rbp-0A8h]
    2a4: mov     [rbp-0A0h],rax
    2ab: mov     rax,[rbp+28h]
    2af: mov     [rbp-0D0h],rax
    2b6: mov     rax,[rbp-0D0h]
    2bd: sub     rax,1
    2c1: mov     [rbp-0C8h],rax
    2c8: mov     rax,[rbp+28h]
    2cc: sub     rax,1
    2d0: mov     [rbp-60h],rax
    2d4: cmp     qword ptr [rbp-60h],8
    2d9: jb      4EDh
    2df: jmp     4EFh
    2e4: nop     [rax+rax]
    2ed: nop     [rax]
    2f0: mov     edi,0FFFFFFE8h
    2f5: mov     esi,0FFFFFF48h
    2fa: call    ryo_h_MovW128
    2ff: mov     qword ptr [rbp-20h],0
    307: nop     [rax+rax]
    310: mov     edi,0FFFFFFE0h
    315: mov     esi,20h
    31a: call    ryo_h_Ret
    31f: leave
    320: ret
    321: mov     edi,0FFFFFF14h
    326: mov     esi,0FFFFFF48h
    32b: xor     edx,edx
    32d: mov     ecx,1
    332: mov     r8d,1
    338: xor     r9d,r9d
    33b: call    ryo_h_DiscrNicheW64
    340: mov     edi,0FFFFFF40h
    345: mov     esi,0FFFFFF14h
    34a: call    ryo_h_ZextW32W64
    34f: mov     edi,0FFFFFF40h
    354: xor     esi,esi
    356: mov     edx,2
    35b: call    ryo_h_SwitchDenseW64
    360: lea     rcx,[370h]
    367: movsxd  rax,[rcx+rax*4]
    36b: add     rax,rcx
    36e: jmp     rax
    370: .long   3d2h
    374: .long   37ch
    378: .long   150h
    37c: movzx   eax,byte ptr [rbp+30h]
    380: mov     [rbp-110h],al
    386: mov     edi,0FFFFFEF8h
    38b: mov     esi,0FFFFFF70h
    390: call    ryo_h_MovW128
    395: lea     rdi,[sym9]
    39c: lea     rsi,[site10]
    3a3: mov     edx,0FFFFFF10h
    3a8: call    ryo_h_CallExt
    3ad: test    rax,rax
    3b0: je      3BDh
    3b2: call    rax
    3b4: nop     [rcx-0B8h]
    3bb: jmp     3CDh
    3bd: mov     rdi,rbp
    3c0: lea     rsi,[ro+36]
    3c7: call    qword ptr [sym11]
    3cd: jmp     2F0h
    3d2: mov     edi,0FFFFFF30h
    3d7: mov     esi,0FFFFFF48h
    3dc: call    ryo_h_MovW128
    3e1: mov     edi,0FFFFFF58h
    3e6: mov     esi,0FFFFFF30h
    3eb: call    ryo_h_MovW128
    3f0: mov     edi,0FFFFFF48h
    3f5: mov     esi,0FFFFFF58h
    3fa: call    ryo_h_MovW128
    3ff: mov     edi,0FFFFFF90h
    404: mov     esi,0FFFFFF48h
    409: call    ryo_h_MovW128
    40e: mov     rax,[rbp-68h]
    412: mov     [rbp-38h],rax
    416: mov     rax,[rbp-88h]
    41d: mov     [rbp-0C0h],rax
    424: mov     rax,[rbp-38h]
    428: cmp     rax,[rbp-0C0h]
    42f: jne     160h
    435: jmp     260h
    43a: mov     edi,0FFFFFF40h
    43f: mov     esi,0FFFFFF38h
    444: mov     edx,0FFFFFF30h
    449: call    ryo_h_DivUW64
    44e: mov     rax,[rbp-0C0h]
    455: mov     [rbp-0D8h],rax
    45c: mov     edi,0FFFFFF14h
    461: mov     esi,0FFFFFF28h
    466: call    ryo_h_CtlzW64
    46b: mov     eax,[rbp-0ECh]
    471: mov     [rbp-80h],eax
    474: mov     edi,0FFFFFF30h
    479: mov     esi,0FFFFFF80h
    47e: call    ryo_h_ZextW32W64
    483: mov     qword ptr [rbp-0F0h],3Fh
    48e: mov     rax,[rbp-0F0h]
    495: sub     rax,[rbp-0D0h]
    49c: mov     [rbp-0C8h],rax
    4a3: mov     qword ptr [rbp-0F0h],1
    4ae: mov     edi,28h
    4b3: mov     esi,0FFFFFF10h
    4b8: mov     edx,0FFFFFF38h
    4bd: call    ryo_h_ShlW64
    4c2: mov     edi,0FFFFFEF0h
    4c7: mov     esi,18h
    4cc: call    ryo_h_MovW128
    4d1: mov     rax,[rbp+28h]
    4d5: mov     [rbp-100h],rax
    4dc: call    fn12
    4e1: nop     [rcx-0D0h]
    4e8: jmp     200h
    4ed: jmp     529h
    4ef: mov     rax,[rbp-60h]
    4f3: add     rax,1
    4f7: mov     [rbp-0D8h],rax
    4fe: mov     qword ptr [rbp-0F0h],8
    509: mov     edi,0FFFFFF30h
    50e: mov     esi,0FFFFFF28h
    513: mov     edx,0FFFFFF10h
    518: call    ryo_h_DivUW64
    51d: imul    rax,[rbp-0D0h],7
    525: mov     [rbp-60h],rax
    529: mov     rax,[rbp-0C8h]
    530: mov     [rbp-0B8h],rax
    537: mov     rax,[rbp-0A0h]
    53e: mov     [rbp-0C0h],rax
    545: mov     rax,[rbp-60h]
    549: mov     [rbp-0B0h],rax
    550: mov     qword ptr [rbp-0A8h],0
    55b: mov     edi,0FFFFFFE0h
    560: mov     esi,0FFFFFF40h
    565: mov     edx,20h
    56a: call    ryo_h_Copy
    56f: jmp     310h

fn hashbrown::raw::RawTableInner::prepare_rehash_in_place
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,120h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-0A8h],rax
     1a: mov     rax,[rbp-0A8h]
     21: add     rax,1
     25: mov     [rbp-0A0h],rax
     2c: mov     qword ptr [rbp-98h],0
     37: mov     rax,[rbp-0A0h]
     3e: mov     [rbp-90h],rax
     45: mov     edi,0FFFFFEE0h
     4a: mov     esi,0FFFFFF68h
     4f: call    ryo_h_MovW128
     54: mov     qword ptr [rbp-110h],10h
     5f: call    fn0
     64: nop     [rcx-20h]
     6b: jmp     1CBh
     70: mov     rax,[rbp-10h]
     74: mov     [rbp-0C0h],rax
     7b: mov     rax,[rbp-0C0h]
     82: add     rax,1
     86: mov     [rbp-0B8h],rax
     8d: mov     rax,[rbp-0B8h]
     94: mov     [rbp-0C0h],rax
     9b: mov     edi,0FFFFFF0Ch
     a0: mov     esi,0FFFFFF40h
     a5: xor     edx,edx
     a7: xor     ecx,ecx
     a9: xor     r8d,r8d
     ac: mov     r9d,1
     b2: call    ryo_h_DiscrNicheW64
     b7: mov     edi,0FFFFFF38h
     bc: mov     esi,0FFFFFF0Ch
     c1: call    ryo_h_ZextW32W64
     c6: cmp     qword ptr [rbp-0C8h],1
     ce: sete    [rbp-81h]
     d5: mov     rax,[rbp-0C0h]
     dc: mov     [rbp-0B0h],rax
     e3: mov     rax,[rbp-0B0h]
     ea: mov     [rbp-0A8h],rax
     f1: mov     rax,[rbp-0A8h]
     f8: mov     [rbp-0A0h],rax
     ff: mov     rax,[rbp-18h]
    103: mov     [rbp-0A0h],rax
    10a: cmp     qword ptr [rbp-0A0h],0
    112: ja      1D0h
    118: jmp     2AAh
    11d: nop     [rax]
    120: mov     edi,0FFFFFF10h
    125: mov     esi,0FFFFFF40h
    12a: call    ryo_h_MovW128
    12f: mov     rax,[rbp+10h]
    133: mov     rax,[rax]
    136: mov     [rbp-0D8h],rax
    13d: mov     rax,[rbp-0D8h]
    144: mov     [rbp-0D0h],rax
    14b: mov     rax,[rbp-0D0h]
    152: imul    rcx,[rbp-0A0h],1
    15a: add     rax,rcx
    15d: mov     [rbp-58h],rax
    161: mov     rax,[rbp-58h]
    165: mov     [rbp-0C8h],rax
    16c: mov     rax,[rbp-58h]
    170: mov     [rbp-0D0h],rax
    177: mov     rax,[rbp-0D0h]
    17e: mov     [rbp-120h],rax
    185: mov     edi,0FFFFFEF0h
    18a: mov     esi,0FFFFFF10h
    18f: call    ryo_h_MovW128
    194: mov     edi,0FFFFFF08h
    199: lea     rsi,[sym1]
    1a0: call    ryo_h_AddrSym
    1a5: mov     rdi,rbp
    1a8: lea     rsi,[ro+4]
    1af: call    qword ptr [sym2]
    1b5: jmp     318h
    1ba: nop     [rax+rax]
    1c0: xor     edi,edi
    1c2: xor     esi,esi
    1c4: call    ryo_h_Ret
    1c9: leave
    1ca: ret
    1cb: jmp     70h
    1d0: mov     rax,[rbp-20h]
    1d4: mov     [rbp-0B0h],rax
    1db: mov     rax,[rbp-0B0h]
    1e2: add     rax,[rbp-0A8h]
    1e9: mov     [rbp-0B8h],rax
    1f0: mov     rax,[rbp-0B8h]
    1f7: mov     [rbp-20h],rax
    1fb: mov     rax,[rbp-0A0h]
    202: sub     rax,1
    206: mov     [rbp-18h],rax
    20a: mov     rax,[rbp-0B0h]
    211: mov     [rbp-90h],rax
    218: mov     qword ptr [rbp-98h],1
    223: mov     rax,[rbp-90h]
    22a: mov     [rbp-0A0h],rax
    231: mov     rax,[rbp+10h]
    235: mov     rax,[rax]
    238: mov     [rbp-0C8h],rax
    23f: mov     rax,[rbp-0C8h]
    246: mov     [rbp-0C0h],rax
    24d: mov     rax,[rbp-0C0h]
    254: imul    rcx,[rbp-0A0h],1
    25c: add     rax,rcx
    25f: mov     [rbp-38h],rax
    263: mov     rax,[rbp-38h]
    267: mov     [rbp-0B8h],rax
    26e: mov     rax,[rbp-38h]
    272: mov     [rbp-0C0h],rax
    279: mov     rax,[rbp-0C0h]
    280: mov     [rbp-120h],rax
    287: mov     edi,0FFFFFF08h
    28c: lea     rsi,[sym3]
    293: call    ryo_h_AddrSym
    298: mov     rdi,rbp
    29b: lea     rsi,[ro+20]
    2a2: call    qword ptr [sym4]
    2a8: jmp     2E9h
    2aa: mov     rax,[rbp+10h]
    2ae: mov     rax,[rax+8]
    2b2: mov     [rbp-98h],rax
    2b9: mov     rax,[rbp-98h]
    2c0: add     rax,1
    2c4: mov     [rbp-90h],rax
    2cb: cmp     qword ptr [rbp-90h],10h
    2d3: setb    [rbp-82h]
    2da: test    byte ptr [rbp-82h],0FFh
    2e1: je      3D5h
    2e7: jmp     31Dh
    2e9: mov     edi,0FFFFFF50h
    2ee: mov     esi,0FFFFFF30h
    2f3: call    ryo_h_MovW128
    2f8: mov     edi,0FFFFFEE0h
    2fd: mov     esi,0FFFFFF50h
    302: call    ryo_h_MovW128
    307: call    fn5
    30c: nop     [rcx-0C0h]
    313: jmp     120h
    318: jmp     70h
    31d: mov     rax,[rbp+10h]
    321: mov     rax,[rax]
    324: mov     [rbp-78h],rax
    328: mov     rax,[rbp-78h]
    32c: mov     [rbp-90h],rax
    333: mov     rax,[rbp+10h]
    337: mov     rax,[rax]
    33a: mov     [rbp-0B0h],rax
    341: mov     rax,[rbp-0B0h]
    348: mov     [rbp-0A8h],rax
    34f: mov     qword ptr [rbp-0F8h],10h
    35a: mov     rax,[rbp-0A8h]
    361: imul    rcx,[rbp-0F8h],1
    369: add     rax,rcx
    36c: mov     [rbp-0A0h],rax
    373: mov     rax,[rbp-0A0h]
    37a: mov     [rbp-98h],rax
    381: mov     rax,[rbp+10h]
    385: mov     rax,[rax+8]
    389: mov     [rbp-0A8h],rax
    390: mov     rax,[rbp-0A8h]
    397: add     rax,1
    39b: mov     [rbp-0A0h],rax
    3a2: mov     rax,[rbp-78h]
    3a6: mov     [rbp-0A8h],rax
    3ad: imul    rax,[rbp-0A0h],1
    3b5: mov     [rbp-0F8h],rax
    3bc: mov     edi,0FFFFFF68h
    3c1: mov     esi,0FFFFFF58h
    3c6: mov     edx,0FFFFFF08h
    3cb: call    ryo_h_Memmove
    3d0: jmp     48Ah
    3d5: mov     rax,[rbp+10h]
    3d9: mov     rax,[rax]
    3dc: mov     [rbp-80h],rax
    3e0: mov     rax,[rbp-80h]
    3e4: mov     [rbp-90h],rax
    3eb: mov     rax,[rbp+10h]
    3ef: mov     rax,[rax+8]
    3f3: mov     [rbp-0A8h],rax
    3fa: mov     rax,[rbp-0A8h]
    401: add     rax,1
    405: mov     [rbp-0A0h],rax
    40c: mov     rax,[rbp+10h]
    410: mov     rax,[rax]
    413: mov     [rbp-0B8h],rax
    41a: mov     rax,[rbp-0B8h]
    421: mov     [rbp-0B0h],rax
    428: mov     rax,[rbp-0B0h]
    42f: imul    rcx,[rbp-0A0h],1
    437: add     rax,rcx
    43a: mov     [rbp-0A8h],rax
    441: mov     rax,[rbp-0A8h]
    448: mov     [rbp-98h],rax
    44f: mov     rax,[rbp-80h]
    453: mov     [rbp-0A0h],rax
    45a: mov     qword ptr [rbp-0F8h],10h
    465: imul    rax,[rbp-0F8h],1
    46d: mov     [rbp-100h],rax
    474: mov     edi,0FFFFFF68h
    479: mov     esi,0FFFFFF60h
    47e: mov     edx,0FFFFFF00h
    483: call    ryo_h_Memmove
    488: jmp     48Fh
    48a: jmp     1C0h
    48f: jmp     1C0h

fn hashbrown::raw::RawTableInner::prepare_resize::<std::alloc::Global>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+18h]
      f: mov     rax,[rax+8]
     13: mov     [rbp-30h],rax
     17: cmp     qword ptr [rbp-30h],0
     1c: sete    [rbp-21h]
     20: test    byte ptr [rbp-21h],0FFh
     24: jne     90h
     26: mov     rax,[rbp+10h]
     2a: mov     rax,[rax]
     2d: mov     [rbp-8],rax
     31: mov     edi,0FFFFFFC8h
     36: mov     esi,10h
     3b: mov     edx,8
     40: call    ryo_h_LoadW128
     45: mov     rax,[rbp+18h]
     49: mov     rax,[rax+8]
     4d: mov     [rbp-68h],rax
     51: mov     rax,[rbp-68h]
     55: add     rax,1
     59: mov     [rbp-58h],rax
     5d: mov     edi,0FFFFFF50h
     62: mov     esi,0FFFFFFC8h
     67: call    ryo_h_MovW128
     6c: mov     rax,[rbp-58h]
     70: mov     [rbp-0A0h],rax
     77: call    fn0
     7c: nop     [rcx-50h]
     83: jmp     0A2h
     85: nop     [rax+rax]
     8e: xchg    ax,ax
     90: xor     edi,edi
     92: xor     esi,esi
     94: call    ryo_h_Ret
     99: leave
     9a: ret
     9b: nop     [rax+rax]
     a0: jmp     90h
     a2: mov     edi,0FFFFFF7Ch
     a7: mov     esi,0FFFFFFB0h
     ac: xor     edx,edx
     ae: xor     ecx,ecx
     b0: xor     r8d,r8d
     b3: mov     r9d,1
     b9: call    ryo_h_DiscrNicheW64
     be: mov     edi,0FFFFFFA8h
     c3: mov     esi,0FFFFFF7Ch
     c8: call    ryo_h_ZextW32W64
     cd: cmp     qword ptr [rbp-58h],1
     d2: sete    [rbp-22h]
     d6: mov     edi,0FFFFFF88h
     db: mov     esi,0FFFFFFB0h
     e0: call    ryo_h_MovW128
     e5: mov     rax,[rbp-40h]
     e9: mov     [rbp-80h],rax
     ed: mov     rax,[rbp+18h]
     f1: mov     rax,[rax]
     f4: mov     [rbp-50h],rax
     f8: mov     rax,[rbp-50h]
     fc: mov     [rbp-48h],rax
    100: mov     rax,[rbp-80h]
    104: mov     [rbp-58h],rax
    108: mov     qword ptr [rbp-88h],0
    113: mov     rax,[rbp-88h]
    11a: sub     rax,[rbp-58h]
    11e: mov     [rbp-50h],rax
    122: mov     rax,[rbp-48h]
    126: imul    rcx,[rbp-50h],1
    12b: add     rax,rcx
    12e: mov     [rbp-40h],rax
    132: mov     rax,[rbp-40h]
    136: mov     [rbp-60h],rax
    13a: mov     rax,[rbp-8]
    13e: mov     [rbp-0B0h],rax
    145: mov     rax,[rbp-60h]
    149: mov     [rbp-0A8h],rax
    150: mov     edi,0FFFFFF60h
    155: mov     esi,0FFFFFF88h
    15a: call    ryo_h_MovW128
    15f: call    fn1
    164: nop     [rcx-8]
    16b: jmp     0A0h

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
     52: mov     rax,[rbp-158h]
     59: mov     [rbp-0C8h],rax
     60: mov     rax,[rbp-0C8h]
     67: mov     rax,[rax+8]
     6b: mov     [rbp-168h],rax
     72: mov     rax,[rbp-168h]
     79: add     rax,1
     7d: mov     [rbp-160h],rax
     84: mov     qword ptr [rbp-10h],0
     8c: mov     rax,[rbp-160h]
     93: mov     [rbp-8],rax
     97: nop     [rax+rax]
     a0: mov     rax,[rbp-10h]
     a4: mov     [rbp-178h],rax
     ab: mov     rax,[rbp-8]
     af: mov     [rbp-180h],rax
     b6: mov     rax,[rbp-178h]
     bd: cmp     rax,[rbp-180h]
     c4: setb    [rbp-169h]
     cb: test    byte ptr [rbp-169h],0FFh
     d2: je      657h
     d8: jmp     57Ah
     dd: nop     [rax]
     e0: call    ryo_h_Unreachable
     e5: ud2
     e7: nop     [rax+rax]
     f0: jmp     530h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     rax,[rbp-158h]
    107: mov     [rbp-0D8h],rax
    10e: mov     rax,[rbp-0D8h]
    115: mov     rax,[rax]
    118: mov     [rbp-198h],rax
    11f: mov     rax,[rbp-198h]
    126: mov     [rbp-180h],rax
    12d: mov     rax,[rbp-170h]
    134: add     rax,1
    138: mov     [rbp-190h],rax
    13f: mov     rax,[rbp-190h]
    146: imul    rax,[rbp+28h]
    14b: mov     [rbp-188h],rax
    152: mov     rax,[rbp-188h]
    159: mov     [rbp-1A0h],rax
    160: mov     qword ptr [rbp-1D0h],0
    16b: mov     rax,[rbp-1D0h]
    172: sub     rax,[rbp-1A0h]
    179: mov     [rbp-190h],rax
    180: mov     rax,[rbp-180h]
    187: imul    rcx,[rbp-190h],1
    18f: add     rax,rcx
    192: mov     [rbp-178h],rax
    199: nop     [rax]
    1a0: mov     rax,[rbp-158h]
    1a7: mov     [rbp-0E0h],rax
    1ae: mov     rax,[rbp-0E0h]
    1b5: mov     [rbp-190h],rax
    1bc: mov     rax,[rbp-170h]
    1c3: mov     [rbp-188h],rax
    1ca: mov     rax,[rbp+20h]
    1ce: mov     rax,[rax+28h]
    1d2: mov     [rbp-1D0h],rax
    1d9: mov     rax,[rbp+18h]
    1dd: mov     [rbp-1F0h],rax
    1e4: mov     rax,[rbp-190h]
    1eb: mov     [rbp-1E8h],rax
    1f2: mov     rax,[rbp-188h]
    1f9: mov     [rbp-1E0h],rax
    200: mov     edi,0FFFFFE30h
    205: lea     rsi,[site1]
    20c: call    ryo_h_CallInd
    211: test    rax,rax
    214: je      221h
    216: call    rax
    218: nop     [rcx-180h]
    21f: jmp     231h
    221: mov     rdi,rbp
    224: lea     rsi,[ro+4]
    22b: call    qword ptr [sym2]
    231: mov     rax,[rbp-158h]
    238: mov     [rbp-0E8h],rax
    23f: mov     rax,[rbp-0E8h]
    246: mov     [rbp-190h],rax
    24d: mov     rax,[rbp-190h]
    254: mov     [rbp-1F0h],rax
    25b: mov     rax,[rbp-180h]
    262: mov     [rbp-1E8h],rax
    269: call    fn3
    26e: nop     [rcx-188h]
    275: mov     rax,[rbp-158h]
    27c: mov     [rbp-0F0h],rax
    283: mov     rax,[rbp-180h]
    28a: mov     [rbp-198h],rax
    291: mov     rax,[rbp-0F0h]
    298: mov     rax,[rax+8]
    29c: mov     [rbp-1A0h],rax
    2a3: mov     rax,[rbp-198h]
    2aa: and     rax,[rbp-1A0h]
    2b1: mov     [rbp-1A8h],rax
    2b8: mov     rax,[rbp-170h]
    2bf: sub     rax,[rbp-1A8h]
    2c6: mov     [rbp-1B0h],rax
    2cd: mov     rax,[rbp-0F0h]
    2d4: mov     rax,[rax+8]
    2d8: mov     [rbp-1B8h],rax
    2df: mov     rax,[rbp-1B0h]
    2e6: and     rax,[rbp-1B8h]
    2ed: mov     [rbp-1A0h],rax
    2f4: mov     qword ptr [rbp-1D0h],10h
    2ff: mov     edi,0FFFFFE68h
    304: mov     esi,0FFFFFE60h
    309: mov     edx,0FFFFFE30h
    30e: call    ryo_h_DivUW64
    313: mov     rax,[rbp-188h]
    31a: sub     rax,[rbp-1A8h]
    321: mov     [rbp-1B8h],rax
    328: mov     rax,[rbp-0F0h]
    32f: mov     rax,[rax+8]
    333: mov     [rbp-1C0h],rax
    33a: mov     rax,[rbp-1B8h]
    341: and     rax,[rbp-1C0h]
    348: mov     [rbp-1B0h],rax
    34f: mov     qword ptr [rbp-1D0h],10h
    35a: mov     edi,0FFFFFE60h
    35f: mov     esi,0FFFFFE50h
    364: mov     edx,0FFFFFE30h
    369: call    ryo_h_DivUW64
    36e: mov     rax,[rbp-198h]
    375: cmp     rax,[rbp-1A0h]
    37c: sete    [rbp-189h]
    383: test    byte ptr [rbp-189h],0FFh
    38a: je      7D4h
    390: jmp     68Ah
    395: nop     [rax+rax]
    39e: xchg    ax,ax
    3a0: mov     rax,[rbp-158h]
    3a7: mov     [rbp-110h],rax
    3ae: mov     rax,[rbp-170h]
    3b5: sub     rax,10h
    3b9: mov     [rbp-1B0h],rax
    3c0: mov     rax,[rbp-110h]
    3c7: mov     rax,[rax+8]
    3cb: mov     [rbp-1B8h],rax
    3d2: mov     rax,[rbp-1B0h]
    3d9: and     rax,[rbp-1B8h]
    3e0: mov     [rbp-1A8h],rax
    3e7: mov     rax,[rbp-1A8h]
    3ee: add     rax,10h
    3f2: mov     [rbp-1A0h],rax
    3f9: mov     rax,[rbp-110h]
    400: mov     rax,[rax]
    403: mov     [rbp-1C0h],rax
    40a: mov     rax,[rbp-1C0h]
    411: mov     [rbp-1B8h],rax
    418: mov     rax,[rbp-1B8h]
    41f: imul    rcx,[rbp-170h],1
    427: add     rax,rcx
    42a: mov     [rbp-1B0h],rax
    431: mov     rax,[rbp-1B0h]
    438: mov     [rbp-1A8h],rax
    43f: mov     byte ptr [rbp-1D0h],0FFh
    446: mov     rax,[rbp-1A8h]
    44d: movzx   ecx,byte ptr [rbp-1D0h]
    454: mov     [rax],cl
    456: mov     rax,[rbp-110h]
    45d: mov     rax,[rax]
    460: mov     [rbp-1C0h],rax
    467: mov     rax,[rbp-1C0h]
    46e: mov     [rbp-1B8h],rax
    475: mov     rax,[rbp-1B8h]
    47c: imul    rcx,[rbp-1A0h],1
    484: add     rax,rcx
    487: mov     [rbp-1B0h],rax
    48e: mov     rax,[rbp-1B0h]
    495: mov     [rbp-1A8h],rax
    49c: mov     byte ptr [rbp-1D0h],0FFh
    4a3: mov     rax,[rbp-1A8h]
    4aa: movzx   ecx,byte ptr [rbp-1D0h]
    4b1: mov     [rax],cl
    4b3: mov     rax,[rbp-178h]
    4ba: mov     [rbp-1A0h],rax
    4c1: imul    rax,[rbp+28h],1
    4c6: mov     [rbp-1D0h],rax
    4cd: mov     edi,0FFFFFE70h
    4d2: mov     esi,0FFFFFE60h
    4d7: mov     edx,0FFFFFE30h
    4dc: call    ryo_h_Memcpy
    4e1: jmp     530h
    4e3: nop     [rax+rax]
    4ec: nop     [rax]
    4f0: mov     rax,[rbp-178h]
    4f7: mov     [rbp-1A8h],rax
    4fe: mov     rax,[rbp+28h]
    502: mov     [rbp-1A0h],rax
    509: mov     edi,0FFFFFE40h
    50e: mov     esi,0FFFFFE58h
    513: call    ryo_h_MovW128
    518: imul    rax,[rbp-1B8h],1
    520: mov     [rbp-1B0h],rax
    527: jmp     0A80h
    52c: nop     [rax]
    530: jmp     0A0h
    535: nop     [rax+rax]
    53e: xchg    ax,ax
    540: mov     edi,0FFFFFEC0h
    545: call    ryo_h_Resume
    54a: ud2
    54c: nop     [rax]
    550: lea     rax,[rbp-158h]
    557: mov     [rbp-1D0h],rax
    55e: mov     rax,[rbp-1D0h]
    565: mov     [rbp-1F0h],rax
    56c: call    fn4
    571: nop     [rcx-1D0h]
    578: jmp     540h
    57a: mov     rax,[rbp-10h]
    57e: mov     [rbp-178h],rax
    585: mov     rax,[rbp-178h]
    58c: add     rax,1
    590: mov     [rbp-180h],rax
    597: mov     rax,[rbp-180h]
    59e: mov     [rbp-10h],rax
    5a2: mov     rax,[rbp-178h]
    5a9: mov     [rbp-160h],rax
    5b0: mov     qword ptr [rbp-168h],1
    5bb: mov     rax,[rbp-160h]
    5c2: mov     [rbp-170h],rax
    5c9: mov     rax,[rbp-158h]
    5d0: mov     [rbp-0D0h],rax
    5d7: mov     rax,[rbp-0D0h]
    5de: mov     rax,[rax]
    5e1: mov     [rbp-190h],rax
    5e8: mov     rax,[rbp-190h]
    5ef: mov     [rbp-188h],rax
    5f6: mov     rax,[rbp-188h]
    5fd: imul    rcx,[rbp-170h],1
    605: add     rax,rcx
    608: mov     [rbp-180h],rax
    60f: mov     rax,[rbp-180h]
    616: mov     [rbp-28h],rax
    61a: mov     rax,[rbp-28h]
    61e: movzx   eax,byte ptr [rax]
    621: mov     [rbp-173h],al
    627: cmp     byte ptr [rbp-173h],80h
    62e: sete    [rbp-172h]
    635: movzx   eax,byte ptr [rbp-172h]
    63c: xor     al,1
    63f: mov     [rbp-171h],al
    645: test    byte ptr [rbp-171h],0FFh
    64c: je      100h
    652: jmp     0F0h
    657: mov     rax,[rbp-158h]
    65e: mov     [rbp-118h],rax
    665: mov     rax,[rbp-118h]
    66c: mov     rax,[rax+8]
    670: mov     [rbp-0A8h],rax
    677: cmp     qword ptr [rbp-0A8h],8
    67f: jb      0AE8h
    685: jmp     0AEAh
    68a: mov     rax,[rbp-158h]
    691: mov     [rbp-0F8h],rax
    698: mov     rax,[rbp-180h]
    69f: shr     rax,39h
    6a3: mov     [rbp-198h],rax
    6aa: mov     rax,[rbp-198h]
    6b1: and     rax,7Fh
    6b5: mov     [rbp-1A0h],rax
    6bc: mov     edi,0FFFFFE76h
    6c1: mov     esi,0FFFFFE60h
    6c6: call    ryo_h_TruncW64W8
    6cb: movzx   eax,byte ptr [rbp-18Ah]
    6d2: mov     [rbp-189h],al
    6d8: mov     rax,[rbp-170h]
    6df: sub     rax,10h
    6e3: mov     [rbp-1A8h],rax
    6ea: mov     rax,[rbp-0F8h]
    6f1: mov     rax,[rax+8]
    6f5: mov     [rbp-1B0h],rax
    6fc: mov     rax,[rbp-1A8h]
    703: and     rax,[rbp-1B0h]
    70a: mov     [rbp-1A0h],rax
    711: mov     rax,[rbp-1A0h]
    718: add     rax,10h
    71c: mov     [rbp-198h],rax
    723: mov     rax,[rbp-0F8h]
    72a: mov     rax,[rax]
    72d: mov     [rbp-1B8h],rax
    734: mov     rax,[rbp-1B8h]
    73b: mov     [rbp-1B0h],rax
    742: mov     rax,[rbp-1B0h]
    749: imul    rcx,[rbp-170h],1
    751: add     rax,rcx
    754: mov     [rbp-1A8h],rax
    75b: mov     rax,[rbp-1A8h]
    762: mov     [rbp-1A0h],rax
    769: mov     rax,[rbp-1A0h]
    770: movzx   ecx,byte ptr [rbp-189h]
    777: mov     [rax],cl
    779: mov     rax,[rbp-0F8h]
    780: mov     rax,[rax]
    783: mov     [rbp-1B8h],rax
    78a: mov     rax,[rbp-1B8h]
    791: mov     [rbp-1B0h],rax
    798: mov     rax,[rbp-1B0h]
    79f: imul    rcx,[rbp-198h],1
    7a7: add     rax,rcx
    7aa: mov     [rbp-1A8h],rax
    7b1: mov     rax,[rbp-1A8h]
    7b8: mov     [rbp-1A0h],rax
    7bf: mov     rax,[rbp-1A0h]
    7c6: movzx   ecx,byte ptr [rbp-189h]
    7cd: mov     [rax],cl
    7cf: jmp     530h
    7d4: mov     rax,[rbp-158h]
    7db: mov     [rbp-100h],rax
    7e2: mov     rax,[rbp-100h]
    7e9: mov     rax,[rax]
    7ec: mov     [rbp-1B0h],rax
    7f3: mov     rax,[rbp-1B0h]
    7fa: mov     [rbp-198h],rax
    801: mov     rax,[rbp-188h]
    808: add     rax,1
    80c: mov     [rbp-1A8h],rax
    813: mov     rax,[rbp-1A8h]
    81a: imul    rax,[rbp+28h]
    81f: mov     [rbp-1A0h],rax
    826: mov     rax,[rbp-1A0h]
    82d: mov     [rbp-1B8h],rax
    834: mov     qword ptr [rbp-1D0h],0
    83f: mov     rax,[rbp-1D0h]
    846: sub     rax,[rbp-1B8h]
    84d: mov     [rbp-1A8h],rax
    854: mov     rax,[rbp-198h]
    85b: imul    rcx,[rbp-1A8h],1
    863: add     rax,rcx
    866: mov     [rbp-190h],rax
    86d: mov     rax,[rbp-158h]
    874: mov     [rbp-108h],rax
    87b: mov     rax,[rbp-108h]
    882: mov     rax,[rax]
    885: mov     [rbp-1B8h],rax
    88c: mov     rax,[rbp-1B8h]
    893: mov     [rbp-1B0h],rax
    89a: mov     rax,[rbp-1B0h]
    8a1: imul    rcx,[rbp-188h],1
    8a9: add     rax,rcx
    8ac: mov     [rbp-1A8h],rax
    8b3: mov     rax,[rbp-1A8h]
    8ba: mov     [rbp-1A0h],rax
    8c1: mov     rax,[rbp-1A0h]
    8c8: movzx   eax,byte ptr [rax]
    8cb: mov     [rbp-191h],al
    8d1: mov     rax,[rbp-180h]
    8d8: shr     rax,39h
    8dc: mov     [rbp-1A0h],rax
    8e3: mov     rax,[rbp-1A0h]
    8ea: and     rax,7Fh
    8ee: mov     [rbp-1A8h],rax
    8f5: mov     edi,0FFFFFE6Dh
    8fa: mov     esi,0FFFFFE58h
    8ff: call    ryo_h_TruncW64W8
    904: movzx   eax,byte ptr [rbp-193h]
    90b: mov     [rbp-192h],al
    911: mov     rax,[rbp-188h]
    918: sub     rax,10h
    91c: mov     [rbp-1B0h],rax
    923: mov     rax,[rbp-108h]
    92a: mov     rax,[rax+8]
    92e: mov     [rbp-1B8h],rax
    935: mov     rax,[rbp-1B0h]
    93c: and     rax,[rbp-1B8h]
    943: mov     [rbp-1A8h],rax
    94a: mov     rax,[rbp-1A8h]
    951: add     rax,10h
    955: mov     [rbp-1A0h],rax
    95c: mov     rax,[rbp-108h]
    963: mov     rax,[rax]
    966: mov     [rbp-1C0h],rax
    96d: mov     rax,[rbp-1C0h]
    974: mov     [rbp-1B8h],rax
    97b: mov     rax,[rbp-1B8h]
    982: imul    rcx,[rbp-188h],1
    98a: add     rax,rcx
    98d: mov     [rbp-1B0h],rax
    994: mov     rax,[rbp-1B0h]
    99b: mov     [rbp-1A8h],rax
    9a2: mov     rax,[rbp-1A8h]
    9a9: movzx   ecx,byte ptr [rbp-192h]
    9b0: mov     [rax],cl
    9b2: mov     rax,[rbp-108h]
    9b9: mov     rax,[rax]
    9bc: mov     [rbp-1C0h],rax
    9c3: mov     rax,[rbp-1C0h]
    9ca: mov     [rbp-1B8h],rax
    9d1: mov     rax,[rbp-1B8h]
    9d8: imul    rcx,[rbp-1A0h],1
    9e0: add     rax,rcx
    9e3: mov     [rbp-1B0h],rax
    9ea: mov     rax,[rbp-1B0h]
    9f1: mov     [rbp-1A8h],rax
    9f8: mov     rax,[rbp-1A8h]
    9ff: movzx   ecx,byte ptr [rbp-192h]
    a06: mov     [rax],cl
    a08: movzx   eax,byte ptr [rbp-191h]
    a0f: mov     [rbp-193h],al
    a15: cmp     byte ptr [rbp-193h],0FFh
    a1c: sete    [rbp-192h]
    a23: test    byte ptr [rbp-192h],0FFh
    a2a: je      4F0h
    a30: jmp     3A0h
    a35: mov     rax,[rbp-1B8h]
    a3c: mov     [rbp-1C0h],rax
    a43: mov     rax,[rbp-178h]
    a4a: mov     [rbp-1F0h],rax
    a51: mov     rax,[rbp-190h]
    a58: mov     [rbp-1E8h],rax
    a5f: mov     rax,[rbp-1C0h]
    a66: mov     [rbp-1E0h],rax
    a6d: call    fn5
    a72: nop     [rcx-138h]
    a79: jmp     0A7Bh
    a7b: jmp     1A0h
    a80: mov     rax,[rbp-1B0h]
    a87: mov     [rbp-1B8h],rax
    a8e: mov     edi,0FFFFFE34h
    a93: mov     esi,0FFFFFE48h
    a98: xor     edx,edx
    a9a: xor     ecx,ecx
    a9c: xor     r8d,r8d
    a9f: mov     r9d,1
    aa5: call    ryo_h_DiscrNicheW64
    aaa: mov     edi,0FFFFFE38h
    aaf: mov     esi,0FFFFFE34h
    ab4: call    ryo_h_ZextW32W64
    ab9: mov     edi,0FFFFFE38h
    abe: xor     esi,esi
    ac0: mov     edx,2
    ac5: call    ryo_h_SwitchDenseW64
    aca: lea     rcx,[0ADCh]
    ad1: movsxd  rax,[rcx+rax*4]
    ad5: add     rax,rcx
    ad8: jmp     rax
    ada: int3
    adb: int3
    adc: .long   a7bh
    ae0: .long   a35h
    ae4: .long   e0h
    ae8: jmp     0B2Ah
    aea: mov     rax,[rbp-0A8h]
    af1: add     rax,1
    af5: mov     [rbp-170h],rax
    afc: mov     qword ptr [rbp-1D0h],8
    b07: mov     edi,0FFFFFE98h
    b0c: mov     esi,0FFFFFE90h
    b11: mov     edx,0FFFFFE30h
    b16: call    ryo_h_DivUW64
    b1b: imul    rax,[rbp-168h],7
    b23: mov     [rbp-0A8h],rax
    b2a: mov     rax,[rbp-158h]
    b31: mov     [rbp-120h],rax
    b38: mov     rax,[rbp-120h]
    b3f: mov     rax,[rax+18h]
    b43: mov     [rbp-160h],rax
    b4a: mov     rax,[rbp-158h]
    b51: mov     [rbp-128h],rax
    b58: mov     rax,[rbp-0A8h]
    b5f: sub     rax,[rbp-160h]
    b66: mov     [rbp-1D0h],rax
    b6d: mov     rax,[rbp-128h]
    b74: mov     rcx,[rbp-1D0h]
    b7b: mov     [rax+10h],rcx
    b7f: mov     rax,[rbp-150h]
    b86: mov     [rbp-168h],rax
    b8d: mov     rax,[rbp-148h]
    b94: mov     [rbp-170h],rax
    b9b: mov     rax,[rbp-158h]
    ba2: mov     [rbp-160h],rax
    ba9: xor     edi,edi
    bab: xor     esi,esi
    bad: call    ryo_h_Ret
    bb2: leave
    bb3: ret
    bb4: nop     [rax+rax]
    bbd: nop     [rax]
    bc0: lea     rdi,[sym6]
    bc7: lea     rsi,[site7]
    bce: mov     edx,0FFFFFE30h
    bd3: call    ryo_h_CallExt
    bd8: test    rax,rax
    bdb: je      0BE8h
    bdd: call    rax
    bdf: nop     [rcx-1C8h]
    be6: jmp     0BF8h
    be8: mov     rdi,rbp
    beb: lea     rsi,[ro+20]
    bf2: call    qword ptr [sym8]
    bf8: call    ryo_h_Unreachable
    bfd: ud2
    bff: mov     rdi,rax
    c02: mov     esi,0FFFFFEC0h
    c07: call    ryo_h_Lpad
    c0c: jmp     550h
    c11: mov     rdi,rax
    c14: mov     esi,0FFFFFEC0h
    c19: call    ryo_h_Lpad
    c1e: jmp     0BC0h

fn hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,110h
      b: mov     rax,[rbp+18h]
      f: mov     rax,[rax]
     12: mov     [rbp-38h],rax
     16: mov     rax,[rbp-38h]
     1a: mov     rax,[rax+8]
     1e: mov     [rbp-98h],rax
     25: mov     rax,[rbp-98h]
     2c: add     rax,1
     30: mov     [rbp-90h],rax
     37: mov     qword ptr [rbp-10h],0
     3f: mov     rax,[rbp-90h]
     46: mov     [rbp-8],rax
     4a: nop     [rax+rax]
     50: mov     rax,[rbp-10h]
     54: mov     [rbp-0A8h],rax
     5b: mov     rax,[rbp-8]
     5f: mov     [rbp-0B0h],rax
     66: mov     rax,[rbp-0A8h]
     6d: cmp     rax,[rbp-0B0h]
     74: setb    [rbp-99h]
     7b: test    byte ptr [rbp-99h],0FFh
     82: je      41Ch
     88: jmp     355h
     8d: nop     [rax]
     90: call    ryo_h_Unreachable
     95: ud2
     97: nop     [rax+rax]
     a0: mov     rax,[rbp+18h]
     a4: mov     rax,[rax]
     a7: mov     [rbp-50h],rax
     ab: mov     rax,[rbp-0A0h]
     b2: sub     rax,10h
     b6: mov     [rbp-0C0h],rax
     bd: mov     rax,[rbp-50h]
     c1: mov     rax,[rax+8]
     c5: mov     [rbp-0C8h],rax
     cc: mov     rax,[rbp-0C0h]
     d3: and     rax,[rbp-0C8h]
     da: mov     [rbp-0B8h],rax
     e1: mov     rax,[rbp-0B8h]
     e8: add     rax,10h
     ec: mov     [rbp-0B0h],rax
     f3: mov     rax,[rbp-50h]
     f7: mov     rax,[rax]
     fa: mov     [rbp-0D0h],rax
    101: mov     rax,[rbp-0D0h]
    108: mov     [rbp-0C8h],rax
    10f: mov     rax,[rbp-0C8h]
    116: imul    rcx,[rbp-0A0h],1
    11e: add     rax,rcx
    121: mov     [rbp-0C0h],rax
    128: mov     rax,[rbp-0C0h]
    12f: mov     [rbp-0B8h],rax
    136: mov     byte ptr [rbp-0F0h],0FFh
    13d: mov     rax,[rbp-0B8h]
    144: movzx   ecx,byte ptr [rbp-0F0h]
    14b: mov     [rax],cl
    14d: mov     rax,[rbp-50h]
    151: mov     rax,[rax]
    154: mov     [rbp-0D0h],rax
    15b: mov     rax,[rbp-0D0h]
    162: mov     [rbp-0C8h],rax
    169: mov     rax,[rbp-0C8h]
    170: imul    rcx,[rbp-0B0h],1
    178: add     rax,rcx
    17b: mov     [rbp-0C0h],rax
    182: mov     rax,[rbp-0C0h]
    189: mov     [rbp-0B8h],rax
    190: mov     byte ptr [rbp-0F0h],0FFh
    197: mov     rax,[rbp-0B8h]
    19e: movzx   ecx,byte ptr [rbp-0F0h]
    1a5: mov     [rax],cl
    1a7: mov     rax,[rbp+10h]
    1ab: mov     rax,[rax]
    1ae: mov     [rbp-0F0h],rax
    1b5: mov     edi,0FFFFFF0Ch
    1ba: mov     esi,0FFFFFF10h
    1bf: xor     edx,edx
    1c1: xor     ecx,ecx
    1c3: xor     r8d,r8d
    1c6: mov     r9d,1
    1cc: call    ryo_h_DiscrNicheW64
    1d1: mov     edi,0FFFFFFD8h
    1d6: mov     esi,0FFFFFF0Ch
    1db: call    ryo_h_ZextW32W64
    1e0: mov     edi,0FFFFFFD8h
    1e5: xor     esi,esi
    1e7: mov     edx,2
    1ec: call    ryo_h_SwitchDenseW64
    1f1: lea     rcx,[204h]
    1f8: movsxd  rax,[rcx+rax*4]
    1fc: add     rax,rcx
    1ff: jmp     rax
    201: int3
    202: int3
    203: int3
    204: .long   302h
    208: .long   210h
    20c: .long   90h
    210: mov     rax,[rbp+10h]
    214: mov     rax,[rax]
    217: mov     [rbp-0B0h],rax
    21e: mov     rax,[rbp+18h]
    222: mov     rax,[rax]
    225: mov     [rbp-58h],rax
    229: mov     rax,[rbp+10h]
    22d: mov     rax,[rax+8]
    231: mov     [rbp-0C0h],rax
    238: mov     rax,[rbp-58h]
    23c: mov     rax,[rax]
    23f: mov     [rbp-0E0h],rax
    246: mov     rax,[rbp-0E0h]
    24d: mov     [rbp-0C8h],rax
    254: mov     rax,[rbp-0A0h]
    25b: add     rax,1
    25f: mov     [rbp-0D8h],rax
    266: mov     rax,[rbp-0D8h]
    26d: imul    rax,[rbp-0C0h]
    275: mov     [rbp-0D0h],rax
    27c: mov     rax,[rbp-0D0h]
    283: mov     [rbp-0E8h],rax
    28a: mov     qword ptr [rbp-0F0h],0
    295: mov     rax,[rbp-0F0h]
    29c: sub     rax,[rbp-0E8h]
    2a3: mov     [rbp-0D8h],rax
    2aa: mov     rax,[rbp-0C8h]
    2b1: imul    rcx,[rbp-0D8h],1
    2b9: add     rax,rcx
    2bc: mov     [rbp-0B8h],rax
    2c3: mov     rax,[rbp-0B8h]
    2ca: mov     [rbp-110h],rax
    2d1: mov     edi,0FFFFFF50h
    2d6: lea     rsi,[site0]
    2dd: call    ryo_h_CallInd
    2e2: test    rax,rax
    2e5: je      2F2h
    2e7: call    rax
    2e9: nop     [rcx-28h]
    2f0: jmp     302h
    2f2: mov     rdi,rbp
    2f5: lea     rsi,[ro+4]
    2fc: call    qword ptr [sym1]
    302: mov     rax,[rbp+18h]
    306: mov     rax,[rax]
    309: mov     [rbp-60h],rax
    30d: mov     rax,[rbp+18h]
    311: mov     rax,[rax]
    314: mov     [rbp-68h],rax
    318: mov     rax,[rbp-68h]
    31c: mov     rax,[rax+18h]
    320: mov     [rbp-0F0h],rax
    327: mov     rax,[rbp-0F0h]
    32e: sub     rax,1
    332: mov     [rbp-100h],rax
    339: mov     rax,[rbp-60h]
    33d: mov     rcx,[rbp-100h]
    344: mov     [rax+18h],rcx
    348: nop     [rax+rax]
    350: jmp     50h
    355: mov     rax,[rbp-10h]
    359: mov     [rbp-0A8h],rax
    360: mov     rax,[rbp-0A8h]
    367: add     rax,1
    36b: mov     [rbp-0B0h],rax
    372: mov     rax,[rbp-0B0h]
    379: mov     [rbp-10h],rax
    37d: mov     rax,[rbp-0A8h]
    384: mov     [rbp-90h],rax
    38b: mov     qword ptr [rbp-98h],1
    396: mov     rax,[rbp-90h]
    39d: mov     [rbp-0A0h],rax
    3a4: mov     rax,[rbp+18h]
    3a8: mov     rax,[rax]
    3ab: mov     [rbp-40h],rax
    3af: mov     rax,[rbp-40h]
    3b3: mov     rax,[rax]
    3b6: mov     [rbp-0C0h],rax
    3bd: mov     rax,[rbp-0C0h]
    3c4: mov     [rbp-0B8h],rax
    3cb: mov     rax,[rbp-0B8h]
    3d2: imul    rcx,[rbp-0A0h],1
    3da: add     rax,rcx
    3dd: mov     [rbp-0B0h],rax
    3e4: mov     rax,[rbp-0B0h]
    3eb: mov     [rbp-20h],rax
    3ef: mov     rax,[rbp-20h]
    3f3: movzx   eax,byte ptr [rax]
    3f6: mov     [rbp-0A2h],al
    3fc: cmp     byte ptr [rbp-0A2h],80h
    403: sete    [rbp-0A1h]
    40a: test    byte ptr [rbp-0A1h],0FFh
    411: je      350h
    417: jmp     0A0h
    41c: mov     rax,[rbp+18h]
    420: mov     rax,[rax]
    423: mov     [rbp-48h],rax
    427: mov     rax,[rbp-48h]
    42b: mov     rax,[rax+8]
    42f: mov     [rbp-30h],rax
    433: cmp     qword ptr [rbp-30h],8
    438: jae     43Ch
    43a: jmp     476h
    43c: mov     rax,[rbp-30h]
    440: add     rax,1
    444: mov     [rbp-0A0h],rax
    44b: mov     qword ptr [rbp-0F0h],8
    456: mov     edi,0FFFFFF68h
    45b: mov     esi,0FFFFFF60h
    460: mov     edx,0FFFFFF10h
    465: call    ryo_h_DivUW64
    46a: imul    rax,[rbp-98h],7
    472: mov     [rbp-30h],rax
    476: mov     rax,[rbp+18h]
    47a: mov     rax,[rax]
    47d: mov     [rbp-70h],rax
    481: mov     rax,[rbp-70h]
    485: mov     rax,[rax+18h]
    489: mov     [rbp-90h],rax
    490: mov     rax,[rbp+18h]
    494: mov     rax,[rax]
    497: mov     [rbp-78h],rax
    49b: mov     rax,[rbp-30h]
    49f: sub     rax,[rbp-90h]
    4a6: mov     [rbp-0F0h],rax
    4ad: mov     rax,[rbp-78h]
    4b1: mov     rcx,[rbp-0F0h]
    4b8: mov     [rax+10h],rcx
    4bc: xor     edi,edi
    4be: xor     esi,esi
    4c0: call    ryo_h_Ret
    4c5: leave
    4c6: ret

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
    1b1: mov     rax,[rbp-38h]
    1b5: mov     [rbp-28h],rax
    1b9: mov     qword ptr [rbp-30h],1
    1c1: mov     rax,[rbp-28h]
    1c5: mov     [rbp-20h],rax
    1c9: mov     rax,[rbp+10h]
    1cd: mov     rax,[rax+8]
    1d1: mov     [rbp-18h],rax
    1d5: cmp     qword ptr [rbp-18h],8
    1da: jae     1DEh
    1dc: jmp     20Fh
    1de: mov     rax,[rbp-18h]
    1e2: add     rax,1
    1e6: mov     [rbp-38h],rax
    1ea: mov     qword ptr [rbp-50h],8
    1f2: mov     edi,0FFFFFFD0h
    1f7: mov     esi,0FFFFFFC8h
    1fc: mov     edx,0FFFFFFB0h
    201: call    ryo_h_DivUW64
    206: imul    rax,[rbp-30h],7
    20b: mov     [rbp-18h],rax
    20f: mov     rax,[rbp-18h]
    213: mov     [rbp-38h],rax
    217: mov     qword ptr [rbp-50h],2
    21f: mov     edi,0FFFFFFD0h
    224: mov     esi,0FFFFFFC8h
    229: mov     edx,0FFFFFFB0h
    22e: call    ryo_h_DivUW64
    233: mov     rax,[rbp-30h]
    237: cmp     rax,[rbp-20h]
    23b: jae     70h
    241: jmp     0D0h

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
     46: jmp     274h
     4b: nop     [rax+rax]
     50: call    ryo_h_Unreachable
     55: ud2
     57: nop     [rax+rax]
     60: lea     rax,[rbp-110h]
     67: mov     [rbp-128h],rax
     6e: mov     rax,[rbp-128h]
     75: mov     rax,[rax+10h]
     79: mov     [rbp-130h],rax
     80: cmp     qword ptr [rbp-130h],0
     88: je      5F0h
     8e: jmp     60Bh
     93: mov     rax,[rbp-118h]
     9a: mov     [rbp-130h],rax
     a1: mov     rax,[rbp+10h]
     a5: mov     [rbp-148h],rax
     ac: mov     rax,[rbp-130h]
     b3: mov     [rbp-140h],rax
     ba: mov     rax,[rbp+28h]
     be: mov     rax,[rax+28h]
     c2: mov     [rbp-1F0h],rax
     c9: mov     rax,[rbp+20h]
     cd: mov     [rbp-240h],rax
     d4: mov     rax,[rbp-148h]
     db: mov     [rbp-238h],rax
     e2: mov     rax,[rbp-140h]
     e9: mov     [rbp-230h],rax
     f0: mov     edi,0FFFFFE10h
     f5: lea     rsi,[site1]
     fc: call    ryo_h_CallInd
    101: test    rax,rax
    104: je      111h
    106: call    rax
    108: nop     [rcx-138h]
    10f: jmp     121h
    111: mov     rdi,rbp
    114: lea     rsi,[ro+4]
    11b: call    qword ptr [sym2]
    121: jmp     1DAh
    126: nop     [rax+rax]
    12f: nop
    130: mov     rax,[rbp+10h]
    134: mov     rax,[rax+18h]
    138: mov     [rbp-0F8h],rax
    13f: mov     rax,[rbp-0C8h]
    146: sub     rax,[rbp-0F8h]
    14d: mov     [rbp-0C8h],rax
    154: mov     rax,[rbp+10h]
    158: mov     rax,[rax+18h]
    15c: mov     [rbp-0F8h],rax
    163: mov     rax,[rbp-0F8h]
    16a: mov     [rbp-0C0h],rax
    171: mov     rax,[rbp+10h]
    175: mov     [rbp-0F8h],rax
    17c: lea     rax,[rbp-0D8h]
    183: mov     [rbp-100h],rax
    18a: mov     qword ptr [rbp-218h],20h
    195: mov     edi,0FFFFFDF0h
    19a: mov     esi,0FFFFFF08h
    19f: xor     edx,edx
    1a1: mov     ecx,20h
    1a6: call    ryo_h_LoadCopy
    1ab: mov     edi,0FFFFFF08h
    1b0: mov     esi,0FFFFFF00h
    1b5: mov     edx,0FFFFFDE8h
    1ba: call    ryo_h_Memcpy
    1bf: mov     edi,0FFFFFF00h
    1c4: xor     esi,esi
    1c6: mov     edx,0FFFFFDF0h
    1cb: mov     ecx,20h
    1d0: call    ryo_h_StoreCopy
    1d5: jmp     95Fh
    1da: lea     rax,[rbp-0D8h]
    1e1: mov     [rbp-140h],rax
    1e8: mov     rax,[rbp-140h]
    1ef: mov     [rbp-240h],rax
    1f6: mov     rax,[rbp-138h]
    1fd: mov     [rbp-238h],rax
    204: call    fn3
    209: nop     [rcx-0B0h]
    210: jmp     694h
    215: nop     [rax+rax]
    21e: xchg    ax,ax
    220: mov     edi,0FFFFFFF0h
    225: mov     esi,10h
    22a: call    ryo_h_Ret
    22f: leave
    230: ret
    231: nop     [rax+rax]
    23a: nop     [rax+rax]
    240: lea     rax,[rbp-0F0h]
    247: mov     [rbp-1F0h],rax
    24e: mov     rax,[rbp-1F0h]
    255: mov     [rbp-240h],rax
    25c: call    fn4
    261: nop     [rcx-1F0h]
    268: mov     edi,0FFFFFF48h
    26d: call    ryo_h_Resume
    272: ud2
    274: mov     edi,0FFFFFE14h
    279: mov     esi,0FFFFFE60h
    27e: xor     edx,edx
    280: mov     ecx,1
    285: mov     r8d,1
    28b: xor     r9d,r9d
    28e: call    ryo_h_DiscrNicheW64
    293: mov     edi,0FFFFFE38h
    298: mov     esi,0FFFFFE14h
    29d: call    ryo_h_ZextW32W64
    2a2: mov     edi,0FFFFFE38h
    2a7: xor     esi,esi
    2a9: mov     edx,2
    2ae: call    ryo_h_SwitchDenseW64
    2b3: lea     rcx,[2C4h]
    2ba: movsxd  rax,[rcx+rax*4]
    2be: add     rax,rcx
    2c1: jmp     rax
    2c3: int3
    2c4: .long   3deh
    2c8: .long   2d0h
    2cc: .long   50h
    2d0: mov     edi,0FFFFFE28h
    2d5: mov     esi,0FFFFFE68h
    2da: call    ryo_h_MovW128
    2df: mov     edi,0FFFFFE18h
    2e4: mov     esi,0FFFFFE28h
    2e9: call    ryo_h_MovW128
    2ee: mov     edi,0FFFFFE88h
    2f3: mov     esi,0FFFFFE18h
    2f8: call    ryo_h_MovW128
    2fd: mov     qword ptr [rbp-180h],0
    308: mov     edi,0FFFFFE70h
    30d: mov     esi,0FFFFFE88h
    312: call    ryo_h_MovW128
    317: mov     qword ptr [rbp-198h],1
    322: cmp     qword ptr [rbp-198h],1
    32a: sete    [rbp-199h]
    331: mov     edi,0FFFFFE30h
    336: mov     esi,0FFFFFE70h
    33b: call    ryo_h_MovW128
    340: mov     edi,0FFFFFEA8h
    345: mov     esi,0FFFFFE30h
    34a: call    ryo_h_MovW128
    34f: mov     qword ptr [rbp-160h],0
    35a: mov     edi,0FFFFFE90h
    35f: mov     esi,0FFFFFEA8h
    364: call    ryo_h_MovW128
    369: mov     edi,0FFFFFE80h
    36e: mov     esi,0FFFFFE90h
    373: call    ryo_h_MovW128
    378: mov     edi,0FFFFFEE0h
    37d: mov     esi,0FFFFFE80h
    382: call    ryo_h_MovW128
    387: mov     qword ptr [rbp-128h],0
    392: mov     edi,0FFFFFEC8h
    397: mov     esi,0FFFFFEE0h
    39c: call    ryo_h_MovW128
    3a1: mov     qword ptr [rbp-140h],1
    3ac: cmp     qword ptr [rbp-140h],1
    3b4: sete    [rbp-151h]
    3bb: mov     edi,0FFFFFEB0h
    3c0: mov     esi,0FFFFFEC8h
    3c5: call    ryo_h_MovW128
    3ca: mov     edi,0FFFFFFF0h
    3cf: mov     esi,0FFFFFEB0h
    3d4: call    ryo_h_MovW128
    3d9: jmp     220h
    3de: mov     edi,0FFFFFE18h
    3e3: mov     esi,0FFFFFE60h
    3e8: mov     edx,20h
    3ed: call    ryo_h_Copy
    3f2: mov     edi,0FFFFFE80h
    3f7: mov     esi,0FFFFFE18h
    3fc: mov     edx,20h
    401: call    ryo_h_Copy
    406: mov     edi,0FFFFFE40h
    40b: mov     esi,0FFFFFE80h
    410: mov     edx,20h
    415: call    ryo_h_Copy
    41a: mov     rax,[rbp+18h]
    41e: mov     [rbp-1D8h],rax
    425: mov     edi,0FFFFFE30h
    42a: mov     esi,40h
    42f: call    ryo_h_MovW128
    434: mov     edi,0FFFFFE68h
    439: mov     esi,0FFFFFE28h
    43e: mov     edx,18h
    443: call    ryo_h_Copy
    448: mov     edi,0FFFFFE80h
    44d: mov     esi,0FFFFFE40h
    452: mov     edx,20h
    457: call    ryo_h_Copy
    45c: mov     edi,0FFFFFEA0h
    461: mov     esi,0FFFFFE68h
    466: mov     edx,38h
    46b: call    ryo_h_Copy
    470: mov     edi,0FFFFFE68h
    475: mov     esi,0FFFFFEA0h
    47a: mov     edx,38h
    47f: call    ryo_h_Copy
    484: mov     edi,0FFFFFED8h
    489: mov     esi,0FFFFFE68h
    48e: mov     edx,38h
    493: call    ryo_h_Copy
    498: mov     edi,0FFFFFEA0h
    49d: mov     esi,0FFFFFED8h
    4a2: mov     edx,38h
    4a7: call    ryo_h_Copy
    4ac: mov     edi,0FFFFFF10h
    4b1: mov     esi,0FFFFFEA0h
    4b6: mov     edx,38h
    4bb: call    ryo_h_Copy
    4c0: mov     rax,[rbp+10h]
    4c4: mov     rax,[rax]
    4c7: mov     [rbp-118h],rax
    4ce: mov     rax,[rbp-118h]
    4d5: mov     [rbp-110h],rax
    4dc: mov     rax,[rbp-118h]
    4e3: mov     [rbp-0F8h],rax
    4ea: mov     rax,[rbp-118h]
    4f1: mov     [rbp-108h],rax
    4f8: mov     rax,[rbp-118h]
    4ff: mov     [rbp-120h],rax
    506: mov     rax,[rbp-120h]
    50d: mov     [rbp-240h],rax
    514: mov     edi,0FFFFFE10h
    519: lea     rsi,[sym5]
    520: call    ryo_h_AddrSym
    525: mov     rdi,rbp
    528: lea     rsi,[ro+20]
    52f: call    qword ptr [sym6]
    535: mov     edi,0FFFFFDC0h
    53a: mov     esi,0FFFFFED0h
    53f: call    ryo_h_MovW128
    544: mov     edi,0FFFFFE10h
    549: lea     rsi,[sym7]
    550: call    ryo_h_AddrSym
    555: mov     rdi,rbp
    558: lea     rsi,[ro+36]
    55f: call    qword ptr [sym8]
    565: mov     edi,0FFFFFF00h
    56a: mov     esi,0FFFFFEFCh
    56f: call    ryo_h_TruncW32W16
    574: mov     edi,0FFFFFF02h
    579: mov     esi,0FFFFFF00h
    57e: call    ryo_h_NotW16
    583: movzx   eax,word ptr [rbp-0FEh]
    58a: mov     [rbp-0FCh],ax
    591: movzx   eax,word ptr [rbp-0FCh]
    598: mov     [rbp-0FAh],ax
    59f: mov     rax,[rbp+10h]
    5a3: mov     rax,[rax+18h]
    5a7: mov     [rbp-108h],rax
    5ae: movzx   eax,word ptr [rbp-0FAh]
    5b5: mov     [rbp-18h],ax
    5b9: mov     qword ptr [rbp-28h],0
    5c1: mov     rax,[rbp-118h]
    5c8: mov     [rbp-30h],rax
    5cc: mov     rax,[rbp-108h]
    5d3: mov     [rbp-20h],rax
    5d7: mov     edi,0FFFFFEF0h
    5dc: mov     esi,0FFFFFFD0h
    5e1: mov     edx,20h
    5e6: call    ryo_h_Copy
    5eb: jmp     60h
    5f0: mov     edi,0FFFFFEE0h
    5f5: lea     rsi,[k9]
    5fc: mov     edx,10h
    601: call    ryo_h_Const
    606: jmp     130h
    60b: mov     rax,[rbp-128h]
    612: mov     [rbp-240h],rax
    619: call    fn10
    61e: nop     [rcx-120h]
    625: mov     rax,[rbp-128h]
    62c: mov     rax,[rax+10h]
    630: mov     [rbp-1F0h],rax
    637: mov     rax,[rbp-1F0h]
    63e: sub     rax,1
    642: mov     [rbp-200h],rax
    649: mov     rax,[rbp-128h]
    650: mov     rcx,[rbp-200h]
    657: mov     [rax+10h],rcx
    65b: mov     rax,[rbp-120h]
    662: mov     [rbp-38h],rax
    666: mov     edi,0FFFFFFC8h
    66b: xor     esi,esi
    66d: mov     edx,2
    672: call    ryo_h_SwitchDenseW64
    677: lea     rcx,[688h]
    67e: movsxd  rax,[rcx+rax*4]
    682: add     rax,rcx
    685: jmp     rax
    687: int3
    688: .long   130h
    68c: .long   93h
    690: .long   50h
    694: mov     rax,[rbp-0D8h]
    69b: mov     [rbp-158h],rax
    6a2: mov     rax,[rbp-158h]
    6a9: mov     [rbp-150h],rax
    6b0: mov     rax,[rbp-150h]
    6b7: imul    rcx,[rbp-0B0h],1
    6bf: add     rax,rcx
    6c2: mov     [rbp-148h],rax
    6c9: mov     rax,[rbp-148h]
    6d0: mov     [rbp-140h],rax
    6d7: mov     rax,[rbp-140h]
    6de: movzx   eax,byte ptr [rax]
    6e1: mov     [rbp-169h],al
    6e7: mov     rax,[rbp-138h]
    6ee: shr     rax,39h
    6f2: mov     [rbp-148h],rax
    6f9: mov     rax,[rbp-148h]
    700: and     rax,7Fh
    704: mov     [rbp-150h],rax
    70b: mov     edi,0FFFFFEC6h
    710: mov     esi,0FFFFFEB0h
    715: call    ryo_h_TruncW64W8
    71a: movzx   eax,byte ptr [rbp-13Ah]
    721: mov     [rbp-139h],al
    727: mov     rax,[rbp-0B0h]
    72e: sub     rax,10h
    732: mov     [rbp-158h],rax
    739: mov     rax,[rbp-0D0h]
    740: mov     [rbp-160h],rax
    747: mov     rax,[rbp-158h]
    74e: and     rax,[rbp-160h]
    755: mov     [rbp-150h],rax
    75c: mov     rax,[rbp-150h]
    763: add     rax,10h
    767: mov     [rbp-148h],rax
    76e: mov     rax,[rbp-0D8h]
    775: mov     [rbp-168h],rax
    77c: mov     rax,[rbp-168h]
    783: mov     [rbp-160h],rax
    78a: mov     rax,[rbp-160h]
    791: imul    rcx,[rbp-0B0h],1
    799: add     rax,rcx
    79c: mov     [rbp-158h],rax
    7a3: mov     rax,[rbp-158h]
    7aa: mov     [rbp-150h],rax
    7b1: mov     rax,[rbp-150h]
    7b8: movzx   ecx,byte ptr [rbp-139h]
    7bf: mov     [rax],cl
    7c1: mov     rax,[rbp-0D8h]
    7c8: mov     [rbp-168h],rax
    7cf: mov     rax,[rbp-168h]
    7d6: mov     [rbp-160h],rax
    7dd: mov     rax,[rbp-160h]
    7e4: imul    rcx,[rbp-148h],1
    7ec: add     rax,rcx
    7ef: mov     [rbp-158h],rax
    7f6: mov     rax,[rbp-158h]
    7fd: mov     [rbp-150h],rax
    804: mov     rax,[rbp-150h]
    80b: movzx   ecx,byte ptr [rbp-139h]
    812: mov     [rax],cl
    814: mov     rax,[rbp+40h]
    818: mov     [rbp-50h],rax
    81c: mov     rax,[rbp+10h]
    820: mov     rax,[rax]
    823: mov     [rbp-168h],rax
    82a: mov     rax,[rbp-168h]
    831: mov     [rbp-150h],rax
    838: mov     rax,[rbp-130h]
    83f: add     rax,1
    843: mov     [rbp-160h],rax
    84a: mov     rax,[rbp-160h]
    851: imul    rax,[rbp-50h]
    856: mov     [rbp-158h],rax
    85d: mov     rax,[rbp-158h]
    864: mov     [rbp-170h],rax
    86b: mov     qword ptr [rbp-1F0h],0
    876: mov     rax,[rbp-1F0h]
    87d: sub     rax,[rbp-170h]
    884: mov     [rbp-160h],rax
    88b: mov     rax,[rbp-150h]
    892: imul    rcx,[rbp-160h],1
    89a: add     rax,rcx
    89d: mov     [rbp-148h],rax
    8a4: mov     rax,[rbp-148h]
    8ab: mov     [rbp-140h],rax
    8b2: mov     rax,[rbp-0D8h]
    8b9: mov     [rbp-168h],rax
    8c0: mov     rax,[rbp-168h]
    8c7: mov     [rbp-150h],rax
    8ce: mov     rax,[rbp-0B0h]
    8d5: add     rax,1
    8d9: mov     [rbp-160h],rax
    8e0: mov     rax,[rbp-160h]
    8e7: imul    rax,[rbp-50h]
    8ec: mov     [rbp-158h],rax
    8f3: mov     rax,[rbp-158h]
    8fa: mov     [rbp-170h],rax
    901: mov     qword ptr [rbp-1F0h],0
    90c: mov     rax,[rbp-1F0h]
    913: sub     rax,[rbp-170h]
    91a: mov     [rbp-160h],rax
    921: mov     rax,[rbp-150h]
    928: imul    rcx,[rbp-160h],1
    930: add     rax,rcx
    933: mov     [rbp-148h],rax
    93a: imul    rax,[rbp-50h],1
    93f: mov     [rbp-1F0h],rax
    946: mov     edi,0FFFFFEB8h
    94b: mov     esi,0FFFFFEC0h
    950: mov     edx,0FFFFFE10h
    955: call    ryo_h_Memcpy
    95a: jmp     60h
    95f: mov     edi,0FFFFFFF0h
    964: lea     rsi,[k11]
    96b: mov     edx,10h
    970: call    ryo_h_Const
    975: lea     rax,[rbp-0F0h]
    97c: mov     [rbp-1F0h],rax
    983: mov     rax,[rbp-1F0h]
    98a: mov     [rbp-240h],rax
    991: call    fn12
    996: nop     [rcx-1F0h]
    99d: jmp     220h
    9a2: nop     [rax+rax]
    9ab: nop     [rax+rax]
    9b0: lea     rdi,[sym13]
    9b7: lea     rsi,[site14]
    9be: mov     edx,0FFFFFE10h
    9c3: call    ryo_h_CallExt
    9c8: test    rax,rax
    9cb: je      9D8h
    9cd: call    rax
    9cf: nop     [rcx-1E8h]
    9d6: jmp     9E8h
    9d8: mov     rdi,rbp
    9db: lea     rsi,[ro+52]
    9e2: call    qword ptr [sym15]
    9e8: call    ryo_h_Unreachable
    9ed: ud2
    9ef: mov     rdi,rax
    9f2: mov     esi,0FFFFFF48h
    9f7: call    ryo_h_Lpad
    9fc: jmp     240h
    a01: mov     rdi,rax
    a04: mov     esi,0FFFFFF48h
    a09: call    ryo_h_Lpad
    a0e: jmp     9B0h

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
    164: mov     rax,[rbp-90h]
    16b: mov     [rbp-0A0h],rax
    172: mov     rax,[rbp-0A0h]
    179: mov     [rbp-80h],rax
    17d: mov     qword ptr [rbp-88h],0
    188: mov     rax,[rbp-80h]
    18c: mov     [rbp-28h],rax
    190: mov     rax,[rbp-50h]
    194: sub     rax,1
    198: mov     [rbp-30h],rax
    19c: mov     edi,0FFFFFF60h
    1a1: mov     esi,0FFFFFF68h
    1a6: mov     edx,0FFFFFFD8h
    1ab: mov     ecx,0FFFFFFD0h
    1b0: call    ryo_h_AddOvfUW64
    1b5: movzx   eax,byte ptr [rbp-98h]
    1bc: mov     [rbp-89h],al
    1c2: test    byte ptr [rbp-89h],0FFh
    1c9: je      1FFh
    1cb: mov     edi,0FFFFFF88h
    1d0: lea     rsi,[k1]
    1d7: mov     edx,10h
    1dc: call    ryo_h_Const
    1e1: mov     qword ptr [rbp-70h],0
    1e9: cmp     qword ptr [rbp-70h],0
    1ee: sete    [rbp-71h]
    1f2: mov     qword ptr [rbp-18h],0
    1fa: jmp     100h
    1ff: mov     rax,[rbp-28h]
    203: add     rax,[rbp-30h]
    207: mov     [rbp-90h],rax
    20e: mov     rax,[rbp-90h]
    215: mov     [rbp-70h],rax
    219: mov     qword ptr [rbp-78h],1
    221: mov     rax,[rbp-70h]
    225: mov     [rbp-90h],rax
    22c: mov     rax,[rbp-90h]
    233: mov     [rbp-60h],rax
    237: mov     qword ptr [rbp-68h],0
    23f: mov     rax,[rbp-60h]
    243: mov     [rbp-38h],rax
    247: mov     edi,0FFFFFF90h
    24c: mov     esi,0FFFFFFD0h
    251: call    ryo_h_NotW64
    256: mov     rax,[rbp-38h]
    25a: and     rax,[rbp-70h]
    25e: mov     [rbp-58h],rax
    262: mov     rax,[rbp+20h]
    266: add     rax,10h
    26a: mov     [rbp-80h],rax
    26e: mov     edi,0FFFFFF68h
    273: mov     esi,0FFFFFF70h
    278: mov     edx,0FFFFFFA8h
    27d: mov     ecx,0FFFFFF80h
    282: call    ryo_h_AddOvfUW64
    287: movzx   eax,byte ptr [rbp-90h]
    28e: mov     [rbp-81h],al
    294: test    byte ptr [rbp-81h],0FFh
    29b: je      2D1h
    29d: mov     edi,0FFFFFF88h
    2a2: lea     rsi,[k2]
    2a9: mov     edx,10h
    2ae: call    ryo_h_Const
    2b3: mov     qword ptr [rbp-70h],0
    2bb: cmp     qword ptr [rbp-70h],0
    2c0: sete    [rbp-71h]
    2c4: mov     qword ptr [rbp-18h],0
    2cc: jmp     0F0h
    2d1: mov     rax,[rbp-58h]
    2d5: add     rax,[rbp-80h]
    2d9: mov     [rbp-88h],rax
    2e0: mov     rax,[rbp-88h]
    2e7: mov     [rbp-70h],rax
    2eb: mov     qword ptr [rbp-78h],1
    2f3: mov     rax,[rbp-70h]
    2f7: mov     [rbp-80h],rax
    2fb: mov     rax,[rbp-80h]
    2ff: mov     [rbp-60h],rax
    303: mov     qword ptr [rbp-68h],0
    30b: mov     rax,[rbp-60h]
    30f: mov     [rbp-40h],rax
    313: mov     rax,7FFFFFFFFFFFFFFFh
    31d: mov     [rbp-0D0h],rax
    324: mov     rax,[rbp-0D0h]
    32b: sub     rax,[rbp-30h]
    32f: mov     [rbp-68h],rax
    333: mov     rax,[rbp-68h]
    337: cmp     rax,[rbp-40h]
    33b: jb      90h
    341: jmp     0A0h

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
    246: mov     rax,[rbp-70h]
    24a: mov     [rbp-80h],rax
    24e: mov     rax,[rbp-80h]
    252: mov     [rbp-60h],rax
    256: mov     qword ptr [rbp-68h],0
    25e: mov     rax,[rbp-60h]
    262: mov     [rbp-50h],rax
    266: mov     qword ptr [rbp-0A8h],7
    271: mov     edi,0FFFFFFA8h
    276: mov     esi,0FFFFFFB0h
    27b: mov     edx,0FFFFFF58h
    280: call    ryo_h_DivUW64
    285: cmp     qword ptr [rbp-58h],1
    28a: jbe     35Ah
    290: jmp     367h
    295: nop     [rax+rax]
    29e: xchg    ax,ax
    2a0: mov     rax,[rbp-78h]
    2a4: mov     [rbp-60h],rax
    2a8: mov     rax,[rbp+18h]
    2ac: mov     [rbp-98h],rax
    2b3: mov     rax,[rbp+20h]
    2b7: mov     [rbp-0A0h],rax
    2be: cmp     qword ptr [rbp-98h],0
    2c6: je      420h
    2cc: jmp     3C1h
    2d1: nop     [rax+rax]
    2da: nop     [rax+rax]
    2e0: mov     qword ptr [rbp-0A8h],1
    2eb: mov     edi,0FFFFFF88h
    2f0: mov     esi,0FFFFFF90h
    2f5: mov     edx,0FFFFFF98h
    2fa: mov     ecx,0FFFFFF58h
    2ff: call    ryo_h_AddOvfUW64
    304: test    byte ptr [rbp-70h],0FFh
    308: je      2A0h
    30a: mov     edi,0FFFFFF40h
    30f: lea     rsi,[k3]
    316: call    ryo_h_AddrAbs
    31b: lea     rdi,[sym4]
    322: lea     rsi,[site5]
    329: mov     edx,0FFFFFF58h
    32e: call    ryo_h_CallExt
    333: test    rax,rax
    336: je      343h
    338: call    rax
    33a: nop     [rcx-0A0h]
    341: jmp     353h
    343: mov     rdi,rbp
    346: lea     rsi,[ro+4]
    34d: call    qword ptr [sym6]
    353: call    ryo_h_Unreachable
    358: ud2
    35a: mov     qword ptr [rbp-68h],0
    362: jmp     2E0h
    367: mov     rax,[rbp-58h]
    36b: sub     rax,1
    36f: mov     [rbp-80h],rax
    373: mov     edi,0FFFFFF5Ch
    378: mov     esi,0FFFFFF80h
    37d: call    ryo_h_CtlzW64
    382: mov     eax,[rbp-0A4h]
    388: mov     [rbp-84h],eax
    38e: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    399: mov     edi,0FFFFFF50h
    39e: mov     esi,0FFFFFF7Ch
    3a3: call    ryo_h_ZextW32W64
    3a8: mov     edi,0FFFFFF98h
    3ad: mov     esi,0FFFFFF58h
    3b2: mov     edx,0FFFFFF50h
    3b7: call    ryo_h_ShrUW64
    3bc: jmp     2E0h
    3c1: mov     rax,[rbp-98h]
    3c8: mov     [rbp-68h],rax
    3cc: mov     rax,[rbp-60h]
    3d0: mov     [rbp-88h],rax
    3d7: mov     edi,0FFFFFF80h
    3dc: mov     esi,0FFFFFF88h
    3e1: mov     edx,0FFFFFF98h
    3e6: mov     ecx,0FFFFFF78h
    3eb: call    ryo_h_MulOvfUW64
    3f0: mov     rax,[rbp-80h]
    3f4: mov     [rbp-68h],rax
    3f8: movzx   eax,byte ptr [rbp-78h]
    3fc: mov     [rbp-69h],al
    3ff: mov     rax,[rbp-68h]
    403: mov     [rbp-90h],rax
    40a: test    byte ptr [rbp-69h],0FFh
    40e: je      442h
    410: jmp     435h
    412: nop     [rax+rax]
    41b: nop     [rax+rax]
    420: mov     rax,[rbp-60h]
    424: mov     [rbp-8],rax
    428: mov     qword ptr [rbp-10h],1
    430: jmp     170h
    435: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    440: jmp     420h
    442: jmp     420h

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
     41: jmp     1B1h
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
     9c: .long   106h
     a0: .long   a8h
     a4: .long   25ah
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
     ea: mov     rax,[rbp-90h]
     f1: mov     [rbp-0B0h],rax
     f8: call    fn1
     fd: nop     [rcx-90h]
    104: jmp     160h
    106: mov     rax,[rbp+10h]
    10a: mov     [rbp-48h],rax
    10e: mov     rax,[rbp+10h]
    112: lea     rax,[rax+20h]
    116: mov     [rbp-58h],rax
    11a: mov     rax,[rbp-58h]
    11e: mov     [rbp-50h],rax
    122: mov     rax,[rbp-48h]
    126: mov     [rbp-0B0h],rax
    12d: mov     qword ptr [rbp-0A8h],1
    138: mov     rax,[rbp-50h]
    13c: mov     [rbp-0A0h],rax
    143: call    fn2
    148: nop     [rcx-30h]
    14f: jmp     1FBh
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     edi,0FFFFFFD8h
    165: mov     esi,28h
    16a: call    ryo_h_Ret
    16f: leave
    170: ret
    171: nop     [rax+rax]
    17a: nop     [rax+rax]
    180: lea     rax,[rbp+18h]
    184: mov     [rbp-90h],rax
    18b: mov     rax,[rbp-90h]
    192: mov     [rbp-0B0h],rax
    199: call    fn3
    19e: nop     [rcx-90h]
    1a5: mov     edi,0FFFFFFC8h
    1aa: call    ryo_h_Resume
    1af: ud2
    1b1: mov     rax,[rbp+10h]
    1b5: mov     [rbp-50h],rax
    1b9: lea     rax,[rbp+18h]
    1bd: mov     [rbp-60h],rax
    1c1: mov     rax,[rbp-60h]
    1c5: mov     [rbp-58h],rax
    1c9: mov     rax,[rbp-50h]
    1cd: mov     [rbp-0B0h],rax
    1d4: mov     rax,[rbp-40h]
    1d8: mov     [rbp-0A8h],rax
    1df: mov     rax,[rbp-58h]
    1e3: mov     [rbp-0A0h],rax
    1ea: call    fn4
    1ef: nop     [rcx-48h]
    1f6: jmp     50h
    1fb: mov     edi,0FFFFFF80h
    200: mov     esi,18h
    205: mov     edx,18h
    20a: call    ryo_h_Copy
    20f: mov     rax,[rbp+10h]
    213: mov     [rbp-88h],rax
    21a: mov     rax,[rbp-40h]
    21e: mov     [rbp-48h],rax
    222: mov     edi,0FFFFFF98h
    227: mov     esi,0FFFFFF80h
    22c: mov     edx,18h
    231: call    ryo_h_Copy
    236: mov     rax,[rbp-88h]
    23d: mov     [rbp-50h],rax
    241: mov     edi,0FFFFFFD8h
    246: mov     esi,0FFFFFF98h
    24b: mov     edx,28h
    250: call    ryo_h_Copy
    255: jmp     160h
    25a: call    ryo_h_Unreachable
    25f: ud2
    261: nop     [rax+rax]
    26a: nop     [rax+rax]
    270: lea     rdi,[sym5]
    277: lea     rsi,[site6]
    27e: mov     edx,0FFFFFF70h
    283: call    ryo_h_CallExt
    288: test    rax,rax
    28b: je      298h
    28d: call    rax
    28f: nop     [rcx-88h]
    296: jmp     2A8h
    298: mov     rdi,rbp
    29b: lea     rsi,[ro+4]
    2a2: call    qword ptr [sym7]
    2a8: call    ryo_h_Unreachable
    2ad: ud2
    2af: mov     rdi,rax
    2b2: mov     esi,0FFFFFFC8h
    2b7: call    ryo_h_Lpad
    2bc: jmp     180h
    2c1: mov     rdi,rax
    2c4: mov     esi,0FFFFFFC8h
    2c9: call    ryo_h_Lpad
    2ce: jmp     270h

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
     3b: jmp     14Ch
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
     94: .long   1ceh
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
     cf: jmp     120h
     d1: mov     rax,[rbp+10h]
     d5: mov     [rbp-38h],rax
     d9: mov     rax,[rbp+10h]
     dd: lea     rax,[rax+20h]
     e1: mov     [rbp-48h],rax
     e5: mov     rax,[rbp-48h]
     e9: mov     [rbp-40h],rax
     ed: mov     rax,[rbp-38h]
     f1: mov     [rbp-80h],rax
     f5: mov     qword ptr [rbp-78h],1
     fd: mov     rax,[rbp-40h]
    101: mov     [rbp-70h],rax
    105: call    fn1
    10a: nop     [rcx-20h]
    111: jmp     18Dh
    113: nop     [rax+rax]
    11c: nop     [rax]
    120: mov     edi,0FFFFFFE8h
    125: mov     esi,18h
    12a: call    ryo_h_Ret
    12f: leave
    130: ret
    131: nop     [rax+rax]
    13a: nop     [rax+rax]
    140: mov     edi,0FFFFFFD8h
    145: call    ryo_h_Resume
    14a: ud2
    14c: mov     rax,[rbp+10h]
    150: mov     [rbp-40h],rax
    154: lea     rax,[rbp+18h]
    158: mov     [rbp-50h],rax
    15c: mov     rax,[rbp-50h]
    160: mov     [rbp-48h],rax
    164: mov     rax,[rbp-40h]
    168: mov     [rbp-80h],rax
    16c: mov     rax,[rbp-30h]
    170: mov     [rbp-78h],rax
    174: mov     rax,[rbp-48h]
    178: mov     [rbp-70h],rax
    17c: call    fn2
    181: nop     [rcx-38h]
    188: jmp     40h
    18d: mov     rax,[rbp+18h]
    191: mov     [rbp-50h],rax
    195: mov     rax,[rbp+10h]
    199: mov     [rbp-58h],rax
    19d: mov     rax,[rbp-30h]
    1a1: mov     [rbp-40h],rax
    1a5: mov     rax,[rbp-50h]
    1a9: mov     [rbp-38h],rax
    1ad: mov     rax,[rbp-58h]
    1b1: mov     [rbp-48h],rax
    1b5: mov     edi,0FFFFFFE8h
    1ba: mov     esi,0FFFFFFB8h
    1bf: mov     edx,18h
    1c4: call    ryo_h_Copy
    1c9: jmp     120h
    1ce: call    ryo_h_Unreachable
    1d3: ud2
    1d5: mov     rdi,rax
    1d8: mov     esi,0FFFFFFD8h
    1dd: call    ryo_h_Lpad
    1e2: jmp     140h

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
     7b: mov     rax,[rbp-88h]
     82: mov     [rbp-570h],rax
     89: call    fn3
     8e: nop     [rcx-80h]
     95: mov     rax,[rbp-80h]
     99: mov     [rbp-90h],rax
     a0: mov     edi,0FFFFFF70h
     a5: xor     esi,esi
     a7: mov     edx,2
     ac: call    ryo_h_SwitchDenseW64
     b1: lea     rcx,[0C4h]
     b8: movsxd  rax,[rcx+rax*4]
     bc: add     rax,rcx
     bf: jmp     rax
     c1: int3
     c2: int3
     c3: int3
     c4: .long   11dh
     c8: .long   d7h
     cc: .long   d0h
     d0: call    ryo_h_Unreachable
     d5: ud2
     d7: mov     rax,[rbp-78h]
     db: mov     [rbp-98h],rax
     e2: mov     rax,[rbp-40h]
     e6: mov     [rbp-0B0h],rax
     ed: mov     rax,[rbp-0B0h]
     f4: mov     [rbp-570h],rax
     fb: mov     rax,5851F42D4C957F2Dh
    105: mov     [rbp-568h],rax
    10c: call    fn4
    111: nop     [rcx-0A8h]
    118: jmp     1A6h
    11d: mov     qword ptr [rbp-108h],0
    128: mov     qword ptr [rbp-110h],0
    133: mov     dword ptr [rbp-534h],14h
    13d: mov     eax,[rbp-534h]
    143: mov     [rbp-16Ch],eax
    149: cmp     dword ptr [rbp-16Ch],40h
    150: jb      35Fh
    156: mov     edi,0FFFFFA90h
    15b: lea     rsi,[k5]
    162: call    ryo_h_AddrAbs
    167: lea     rdi,[sym6]
    16e: lea     rsi,[site7]
    175: mov     edx,0FFFFFAC8h
    17a: call    ryo_h_CallExt
    17f: test    rax,rax
    182: je      18Fh
    184: call    rax
    186: nop     [rcx-530h]
    18d: jmp     19Fh
    18f: mov     rdi,rbp
    192: lea     rsi,[ro+4]
    199: call    qword ptr [sym8]
    19f: call    ryo_h_Unreachable
    1a4: ud2
    1a6: mov     rax,[rbp-0A8h]
    1ad: mov     [rbp-570h],rax
    1b4: mov     rax,14057B7EF767814Fh
    1be: mov     [rbp-568h],rax
    1c5: call    fn9
    1ca: nop     [rcx-0A0h]
    1d1: mov     rax,[rbp-0A0h]
    1d8: mov     [rbp-40h],rax
    1dc: lea     rax,[rbp-38h]
    1e0: mov     [rbp-0D8h],rax
    1e7: mov     rax,[rbp-40h]
    1eb: mov     [rbp-0E8h],rax
    1f2: mov     dword ptr [rbp-534h],2Ch
    1fc: mov     eax,[rbp-534h]
    202: mov     [rbp-0ECh],eax
    208: cmp     dword ptr [rbp-0ECh],40h
    20f: jb      261h
    211: mov     edi,0FFFFFA90h
    216: lea     rsi,[k10]
    21d: call    ryo_h_AddrAbs
    222: lea     rdi,[sym11]
    229: lea     rsi,[site12]
    230: mov     edx,0FFFFFAC8h
    235: call    ryo_h_CallExt
    23a: test    rax,rax
    23d: je      24Ah
    23f: call    rax
    241: nop     [rcx-530h]
    248: jmp     25Ah
    24a: mov     rdi,rbp
    24d: lea     rsi,[ro+4]
    254: call    qword ptr [sym13]
    25a: call    ryo_h_Unreachable
    25f: ud2
    261: mov     rax,[rbp-0E8h]
    268: shr     rax,2Ch
    26c: mov     [rbp-0E0h],rax
    273: mov     rax,[rbp-0D8h]
    27a: mov     [rbp-570h],rax
    281: mov     rax,[rbp-0E0h]
    288: mov     [rbp-568h],rax
    28f: call    fn14
    294: nop     [rcx-0D0h]
    29b: mov     edi,0FFFFFA90h
    2a0: mov     esi,0FFFFFF30h
    2a5: mov     edx,18h
    2aa: call    ryo_h_Copy
    2af: mov     qword ptr [rbp-558h],0
    2ba: call    fn15
    2bf: nop     [rcx-0B8h]
    2c6: mov     rax,[rbp-0B8h]
    2cd: mov     rax,[rax]
    2d0: mov     [rbp-538h],rax
    2d7: mov     edi,0FFFFFF00h
    2dc: mov     esi,0FFFFFF08h
    2e1: mov     edx,0FFFFFAC8h
    2e6: mov     ecx,0FFFFFF68h
    2eb: call    ryo_h_AddOvfUW64
    2f0: test    byte ptr [rbp-0F8h],0FFh
    2f7: je      349h
    2f9: mov     edi,0FFFFFA90h
    2fe: lea     rsi,[k16]
    305: call    ryo_h_AddrAbs
    30a: lea     rdi,[sym17]
    311: lea     rsi,[site18]
    318: mov     edx,0FFFFFAC8h
    31d: call    ryo_h_CallExt
    322: test    rax,rax
    325: je      332h
    327: call    rax
    329: nop     [rcx-530h]
    330: jmp     342h
    332: mov     rdi,rbp
    335: lea     rsi,[ro+4]
    33c: call    qword ptr [sym19]
    342: call    ryo_h_Unreachable
    347: ud2
    349: mov     rax,[rbp-0B8h]
    350: mov     rcx,[rbp-100h]
    357: mov     [rax],rcx
    35a: jmp     70h
    35f: mov     qword ptr [rbp-538h],1
    36a: mov     rax,[rbp-538h]
    371: shl     rax,14h
    375: mov     [rbp-168h],rax
    37c: mov     qword ptr [rbp-160h],0
    387: mov     rax,[rbp-168h]
    38e: mov     [rbp-158h],rax
    395: mov     edi,0FFFFFA90h
    39a: mov     esi,0FFFFFEA0h
    39f: call    ryo_h_MovW128
    3a4: mov     qword ptr [rbp-560h],2
    3af: call    fn20
    3b4: nop     [rcx-150h]
    3bb: mov     edi,0FFFFFA90h
    3c0: mov     esi,0FFFFFEB0h
    3c5: mov     edx,20h
    3ca: call    ryo_h_Copy
    3cf: call    fn21
    3d4: nop     [rcx-130h]
    3db: mov     edi,0FFFFFE70h
    3e0: mov     esi,0FFFFFED0h
    3e5: mov     edx,20h
    3ea: call    ryo_h_Copy
    3ef: nop
    3f0: lea     rax,[rbp-190h]
    3f7: mov     [rbp-1A8h],rax
    3fe: mov     rax,[rbp-1A8h]
    405: mov     [rbp-570h],rax
    40c: call    fn22
    411: nop     [rcx-1A0h]
    418: mov     rax,[rbp-1A0h]
    41f: mov     [rbp-1B0h],rax
    426: mov     edi,0FFFFFE50h
    42b: xor     esi,esi
    42d: mov     edx,2
    432: call    ryo_h_SwitchDenseW64
    437: lea     rcx,[448h]
    43e: movsxd  rax,[rcx+rax*4]
    442: add     rax,rcx
    445: jmp     rax
    447: int3
    448: .long   4a5h
    44c: .long   454h
    450: .long   d0h
    454: mov     rax,[rbp-198h]
    45b: mov     [rbp-1B8h],rax
    462: lea     rax,[rbp-38h]
    466: mov     [rbp-1C8h],rax
    46d: lea     rax,[rbp-1B8h]
    474: mov     [rbp-1D0h],rax
    47b: mov     rax,[rbp-1C8h]
    482: mov     [rbp-570h],rax
    489: mov     rax,[rbp-1D0h]
    490: mov     [rbp-568h],rax
    497: call    fn23
    49c: nop     [rcx-1C0h]
    4a3: jmp     4CFh
    4a5: lea     rax,[rbp-38h]
    4a9: mov     [rbp-218h],rax
    4b0: mov     rax,[rbp-218h]
    4b7: mov     [rbp-570h],rax
    4be: call    fn24
    4c3: nop     [rcx-210h]
    4ca: jmp     61Bh
    4cf: mov     edi,0FFFFFACCh
    4d4: mov     esi,0FFFFFE40h
    4d9: xor     edx,edx
    4db: xor     ecx,ecx
    4dd: xor     r8d,r8d
    4e0: mov     r9d,1
    4e6: call    ryo_h_DiscrNicheW64
    4eb: mov     edi,0FFFFFE28h
    4f0: mov     esi,0FFFFFACCh
    4f5: call    ryo_h_ZextW32W64
    4fa: mov     edi,0FFFFFE28h
    4ff: xor     esi,esi
    501: mov     edx,2
    506: call    ryo_h_SwitchDenseW64
    50b: lea     rcx,[51Ch]
    512: movsxd  rax,[rcx+rax*4]
    516: add     rax,rcx
    519: jmp     rax
    51b: int3
    51c: .long   3f0h
    520: .long   528h
    524: .long   d0h
    528: mov     rax,[rbp-1C0h]
    52f: mov     [rbp-1E0h],rax
    536: mov     qword ptr [rbp-538h],1
    541: mov     edi,0FFFFFE10h
    546: mov     esi,0FFFFFE18h
    54b: mov     edx,0FFFFFEF8h
    550: mov     ecx,0FFFFFAC8h
    555: call    ryo_h_AddOvfUW64
    55a: test    byte ptr [rbp-1E8h],0FFh
    561: je      5B3h
    563: mov     edi,0FFFFFA90h
    568: lea     rsi,[k25]
    56f: call    ryo_h_AddrAbs
    574: lea     rdi,[sym26]
    57b: lea     rsi,[site27]
    582: mov     edx,0FFFFFAC8h
    587: call    ryo_h_CallExt
    58c: test    rax,rax
    58f: je      59Ch
    591: call    rax
    593: nop     [rcx-530h]
    59a: jmp     5ACh
    59c: mov     rdi,rbp
    59f: lea     rsi,[ro+4]
    5a6: call    qword ptr [sym28]
    5ac: call    ryo_h_Unreachable
    5b1: ud2
    5b3: mov     rax,[rbp-1F0h]
    5ba: mov     [rbp-108h],rax
    5c1: mov     rax,[rbp-110h]
    5c8: mov     [rbp-200h],rax
    5cf: mov     rax,[rbp-1E0h]
    5d6: mov     rax,[rax]
    5d9: mov     [rbp-208h],rax
    5e0: mov     rax,[rbp-200h]
    5e7: mov     [rbp-570h],rax
    5ee: mov     rax,[rbp-208h]
    5f5: mov     [rbp-568h],rax
    5fc: call    fn29
    601: nop     [rcx-1F8h]
    608: mov     rax,[rbp-1F8h]
    60f: mov     [rbp-110h],rax
    616: jmp     3F0h
    61b: lea     rax,[rbp-38h]
    61f: mov     [rbp-220h],rax
    626: mov     rax,[rbp-220h]
    62d: mov     [rbp-570h],rax
    634: call    fn30
    639: nop     [rcx-218h]
    640: lea     rax,[rbp-38h]
    644: mov     [rbp-258h],rax
    64b: mov     rax,[rbp-258h]
    652: mov     [rbp-570h],rax
    659: call    fn31
    65e: nop     [rcx-250h]
    665: mov     edi,0FFFFFA90h
    66a: mov     esi,0FFFFFDB0h
    66f: mov     edx,28h
    674: call    ryo_h_Copy
    679: mov     qword ptr [rbp-548h],0
    684: call    fn32
    689: nop     [rcx-228h]
    690: call    fn33
    695: nop     [rcx-288h]
    69c: mov     dword ptr [rbp-298h],0
    6a6: mov     dword ptr [rbp-294h],1FBD0h
    6b0: mov     rax,[rbp-298h]
    6b7: mov     [rbp-570h],rax
    6be: call    fn34
    6c3: nop     [rcx-290h]
    6ca: mov     rax,[rbp-290h]
    6d1: mov     [rbp-2A0h],rax
    6d8: nop     [rax+rax]
    6e0: lea     rax,[rbp-2A0h]
    6e7: mov     [rbp-2B0h],rax
    6ee: mov     rax,[rbp-2B0h]
    6f5: mov     [rbp-570h],rax
    6fc: call    fn35
    701: nop     [rcx-2A8h]
    708: mov     edi,0FFFFFD48h
    70d: mov     esi,0FFFFFD58h
    712: call    ryo_h_ZextW32W64
    717: mov     edi,0FFFFFD48h
    71c: xor     esi,esi
    71e: mov     edx,2
    723: call    ryo_h_SwitchDenseW64
    728: lea     rcx,[738h]
    72f: movsxd  rax,[rcx+rax*4]
    733: add     rax,rcx
    736: jmp     rax
    738: .long   7cfh
    73c: .long   744h
    740: .long   d0h
    744: mov     eax,[rbp-2A4h]
    74a: mov     [rbp-2BCh],eax
    750: lea     rax,[rbp-288h]
    757: mov     [rbp-2F8h],rax
    75e: mov     dword ptr [rbp-534h],138Bh
    768: cmp     dword ptr [rbp-534h],0
    76f: sete    [rbp-34Dh]
    776: test    byte ptr [rbp-34Dh],0FFh
    77d: je      7F9h
    77f: mov     edi,0FFFFFA90h
    784: lea     rsi,[k36]
    78b: call    ryo_h_AddrAbs
    790: lea     rdi,[sym37]
    797: lea     rsi,[site38]
    79e: mov     edx,0FFFFFAC8h
    7a3: call    ryo_h_CallExt
    7a8: test    rax,rax
    7ab: je      7B8h
    7ad: call    rax
    7af: nop     [rcx-530h]
    7b6: jmp     7C8h
    7b8: mov     rdi,rbp
    7bb: lea     rsi,[ro+4]
    7c2: call    qword ptr [sym39]
    7c8: call    ryo_h_Unreachable
    7cd: ud2
    7cf: lea     rax,[rbp-38h]
    7d3: mov     [rbp-3E8h],rax
    7da: mov     rax,[rbp-3E8h]
    7e1: mov     [rbp-570h],rax
    7e8: call    fn40
    7ed: nop     [rcx-3E0h]
    7f4: jmp     9DEh
    7f9: mov     dword ptr [rbp-534h],138Bh
    803: mov     edi,0FFFFFCB4h
    808: mov     esi,0FFFFFD44h
    80d: mov     edx,0FFFFFACCh
    812: call    ryo_h_RemUW32
    817: lea     rax,[rbp-34Ch]
    81e: mov     [rbp-348h],rax
    825: mov     rax,[rbp-348h]
    82c: mov     [rbp-340h],rax
    833: mov     rax,[rbp-340h]
    83a: mov     [rbp-4F8h],rax
    841: mov     rax,[rbp-4F8h]
    848: mov     [rbp-570h],rax
    84f: call    fn41
    854: nop     [rcx-370h]
    85b: mov     edi,0FFFFFCA0h
    860: mov     esi,0FFFFFC90h
    865: call    ryo_h_MovW128
    86a: mov     edi,0FFFFFC88h
    86f: lea     rsi,[k42]
    876: call    ryo_h_AddrAbs
    87b: lea     rax,[rbp-360h]
    882: mov     [rbp-380h],rax
    889: mov     rax,[rbp-378h]
    890: mov     [rbp-570h],rax
    897: mov     rax,[rbp-380h]
    89e: mov     [rbp-568h],rax
    8a5: call    fn43
    8aa: nop     [rcx-338h]
    8b1: mov     edi,0FFFFFA90h
    8b6: mov     esi,0FFFFFCC8h
    8bb: call    ryo_h_MovW128
    8c0: call    fn44
    8c5: nop     [rcx-328h]
    8cc: mov     edi,0FFFFFA90h
    8d1: mov     esi,0FFFFFCD8h
    8d6: mov     edx,18h
    8db: call    ryo_h_Copy
    8e0: call    fn45
    8e5: nop     [rcx-310h]
    8ec: mov     rax,[rbp-2F8h]
    8f3: mov     [rbp-570h],rax
    8fa: mov     edi,0FFFFFA98h
    8ff: mov     esi,0FFFFFCF0h
    904: mov     edx,18h
    909: call    ryo_h_Copy
    90e: call    fn46
    913: nop     [rcx-2F0h]
    91a: mov     edi,0FFFFFA90h
    91f: mov     esi,0FFFFFD10h
    924: mov     edx,28h
    929: call    ryo_h_Copy
    92e: call    fn47
    933: nop     [rcx-2C8h]
    93a: mov     rax,[rbp-2C8h]
    941: mov     rax,[rax]
    944: mov     [rbp-538h],rax
    94b: mov     qword ptr [rbp-540h],1
    956: mov     edi,0FFFFFC70h
    95b: mov     esi,0FFFFFC78h
    960: mov     edx,0FFFFFAC8h
    965: mov     ecx,0FFFFFAC0h
    96a: call    ryo_h_AddOvfUW64
    96f: test    byte ptr [rbp-388h],0FFh
    976: je      9C8h
    978: mov     edi,0FFFFFA90h
    97d: lea     rsi,[k48]
    984: call    ryo_h_AddrAbs
    989: lea     rdi,[sym49]
    990: lea     rsi,[site50]
    997: mov     edx,0FFFFFAC8h
    99c: call    ryo_h_CallExt
    9a1: test    rax,rax
    9a4: je      9B1h
    9a6: call    rax
    9a8: nop     [rcx-530h]
    9af: jmp     9C1h
    9b1: mov     rdi,rbp
    9b4: lea     rsi,[ro+4]
    9bb: call    qword ptr [sym51]
    9c1: call    ryo_h_Unreachable
    9c6: ud2
    9c8: mov     rax,[rbp-2C8h]
    9cf: mov     rcx,[rbp-390h]
    9d6: mov     [rax],rcx
    9d9: jmp     6E0h
    9de: lea     rax,[rbp-3E0h]
    9e5: mov     [rbp-3D8h],rax
    9ec: lea     rax,[rbp-288h]
    9f3: mov     [rbp-400h],rax
    9fa: mov     rax,[rbp-400h]
    a01: mov     [rbp-570h],rax
    a08: call    fn52
    a0d: nop     [rcx-3F8h]
    a14: lea     rax,[rbp-3F8h]
    a1b: mov     [rbp-3F0h],rax
    a22: lea     rax,[rbp-210h]
    a29: mov     [rbp-408h],rax
    a30: lea     rax,[rbp-108h]
    a37: mov     [rbp-410h],rax
    a3e: lea     rax,[rbp-110h]
    a45: mov     [rbp-418h],rax
    a4c: lea     rax,[rbp-228h]
    a53: mov     [rbp-420h],rax
    a5a: mov     rax,[rbp-3D8h]
    a61: mov     [rbp-3D0h],rax
    a68: mov     rax,[rbp-3F0h]
    a6f: mov     [rbp-3C8h],rax
    a76: mov     rax,[rbp-408h]
    a7d: mov     [rbp-3C0h],rax
    a84: mov     rax,[rbp-410h]
    a8b: mov     [rbp-3B8h],rax
    a92: mov     rax,[rbp-418h]
    a99: mov     [rbp-3B0h],rax
    aa0: mov     rax,[rbp-420h]
    aa7: mov     [rbp-3A8h],rax
    aae: mov     rax,[rbp-3C0h]
    ab5: mov     [rbp-500h],rax
    abc: mov     rax,[rbp-500h]
    ac3: mov     [rbp-570h],rax
    aca: call    fn53
    acf: nop     [rcx-490h]
    ad6: mov     rax,[rbp-3B8h]
    add: mov     [rbp-508h],rax
    ae4: mov     rax,[rbp-508h]
    aeb: mov     [rbp-570h],rax
    af2: call    fn54
    af7: nop     [rcx-4A0h]
    afe: mov     rax,[rbp-3B0h]
    b05: mov     [rbp-510h],rax
    b0c: mov     rax,[rbp-510h]
    b13: mov     [rbp-570h],rax
    b1a: call    fn55
    b1f: nop     [rcx-4B0h]
    b26: mov     rax,[rbp-3D0h]
    b2d: mov     [rbp-518h],rax
    b34: mov     rax,[rbp-518h]
    b3b: mov     [rbp-570h],rax
    b42: call    fn56
    b47: nop     [rcx-4C0h]
    b4e: mov     rax,[rbp-3A8h]
    b55: mov     [rbp-520h],rax
    b5c: mov     rax,[rbp-520h]
    b63: mov     [rbp-570h],rax
    b6a: call    fn57
    b6f: nop     [rcx-4D0h]
    b76: mov     rax,[rbp-3C8h]
    b7d: mov     [rbp-528h],rax
    b84: mov     rax,[rbp-528h]
    b8b: mov     [rbp-570h],rax
    b92: call    fn58
    b97: nop     [rcx-4E0h]
    b9e: mov     edi,0FFFFFB80h
    ba3: mov     esi,0FFFFFB70h
    ba8: call    ryo_h_MovW128
    bad: mov     edi,0FFFFFB90h
    bb2: mov     esi,0FFFFFB60h
    bb7: call    ryo_h_MovW128
    bbc: mov     edi,0FFFFFBA0h
    bc1: mov     esi,0FFFFFB50h
    bc6: call    ryo_h_MovW128
    bcb: mov     edi,0FFFFFBB0h
    bd0: mov     esi,0FFFFFB40h
    bd5: call    ryo_h_MovW128
    bda: mov     edi,0FFFFFBC0h
    bdf: mov     esi,0FFFFFB30h
    be4: call    ryo_h_MovW128
    be9: mov     edi,0FFFFFBD0h
    bee: mov     esi,0FFFFFB20h
    bf3: call    ryo_h_MovW128
    bf8: mov     edi,0FFFFFB18h
    bfd: lea     rsi,[k59]
    c04: call    ryo_h_AddrAbs
    c09: lea     rax,[rbp-480h]
    c10: mov     [rbp-4F0h],rax
    c17: mov     rax,[rbp-4E8h]
    c1e: mov     [rbp-570h],rax
    c25: mov     rax,[rbp-4F0h]
    c2c: mov     [rbp-568h],rax
    c33: call    fn60
    c38: nop     [rcx-3A0h]
    c3f: mov     edi,0FFFFFA90h
    c44: mov     esi,0FFFFFC60h
    c49: call    ryo_h_MovW128
    c4e: lea     rdi,[sym61]
    c55: lea     rsi,[site62]
    c5c: mov     edx,0FFFFFAC8h
    c61: call    ryo_h_CallExt
    c66: test    rax,rax
    c69: je      0C76h
    c6b: call    rax
    c6d: nop     [rcx-390h]
    c74: jmp     0C86h
    c76: mov     rdi,rbp
    c79: lea     rsi,[ro+20]
    c80: call    qword ptr [sym63]
    c86: lea     rax,[rbp-288h]
    c8d: mov     [rbp-538h],rax
    c94: mov     rax,[rbp-538h]
    c9b: mov     [rbp-570h],rax
    ca2: call    fn64
    ca7: nop     [rcx-538h]
    cae: lea     rax,[rbp-38h]
    cb2: mov     [rbp-538h],rax
    cb9: mov     rax,[rbp-538h]
    cc0: mov     [rbp-570h],rax
    cc7: call    fn65
    ccc: nop     [rcx-538h]
    cd3: xor     edi,edi
    cd5: xor     esi,esi
    cd7: call    ryo_h_Ret
    cdc: leave
    cdd: ret
    cde: xchg    ax,ax
    ce0: lea     rax,[rbp-288h]
    ce7: mov     [rbp-538h],rax
    cee: mov     rax,[rbp-538h]
    cf5: mov     [rbp-570h],rax
    cfc: call    fn66
    d01: nop     [rcx-538h]
    d08: nop     [rax+rax]
    d10: lea     rax,[rbp-38h]
    d14: mov     [rbp-538h],rax
    d1b: mov     rax,[rbp-538h]
    d22: mov     [rbp-570h],rax
    d29: call    fn67
    d2e: nop     [rcx-538h]
    d35: mov     edi,0FFFFFAD0h
    d3a: call    ryo_h_Resume
    d3f: ud2
    d41: nop     [rax+rax]
    d4a: nop     [rax+rax]
    d50: lea     rdi,[sym68]
    d57: lea     rsi,[site69]
    d5e: mov     edx,0FFFFFAC8h
    d63: call    ryo_h_CallExt
    d68: test    rax,rax
    d6b: je      0D78h
    d6d: call    rax
    d6f: nop     [rcx-530h]
    d76: jmp     0D88h
    d78: mov     rdi,rbp
    d7b: lea     rsi,[ro+4]
    d82: call    qword ptr [sym70]
    d88: call    ryo_h_Unreachable
    d8d: ud2
    d8f: mov     rdi,rax
    d92: mov     esi,0FFFFFAD0h
    d97: call    ryo_h_Lpad
    d9c: jmp     0D10h
    da1: mov     rdi,rax
    da4: mov     esi,0FFFFFAD0h
    da9: call    ryo_h_Lpad
    dae: jmp     0CE0h
    db3: mov     rdi,rax
    db6: mov     esi,0FFFFFAD0h
    dbb: call    ryo_h_Lpad
    dc0: jmp     0D50h

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
     13: cmp     qword ptr [rbp-60h],0
     18: je      26h
     1a: test    byte ptr [rbp+20h],0FFh
     1e: je      0ADh
     24: jmp     70h
     26: mov     rax,[rbp+10h]
     2a: mov     [rbp-38h],rax
     2e: mov     rax,[rbp-38h]
     32: mov     [rbp-78h],rax
     36: mov     rax,[rbp-38h]
     3a: mov     [rbp-90h],rax
     41: mov     rax,[rbp-90h]
     48: mov     [rbp-88h],rax
     4f: mov     qword ptr [rbp-80h],0
     57: mov     byte ptr [rbp-91h],1
     5e: test    byte ptr [rbp-91h],0FFh
     65: je      167h
     6b: jmp     131h
     70: lea     rdi,[sym0]
     77: lea     rsi,[site1]
     7e: mov     edx,0FFFFFF68h
     83: call    ryo_h_CallExt
     88: test    rax,rax
     8b: je      98h
     8d: call    rax
     8f: nop     [rcx-38h]
     96: jmp     0A8h
     98: mov     rdi,rbp
     9b: lea     rsi,[ro+4]
     a2: call    qword ptr [sym2]
     a8: jmp     187h
     ad: lea     rdi,[sym3]
     b4: lea     rsi,[site4]
     bb: mov     edx,0FFFFFF68h
     c0: call    ryo_h_CallExt
     c5: test    rax,rax
     c8: je      0D5h
     ca: call    rax
     cc: nop     [rcx-48h]
     d3: jmp     0E5h
     d5: mov     rdi,rbp
     d8: lea     rsi,[ro+20]
     df: call    qword ptr [sym5]
     e5: jmp     1E2h
     ea: nop     [rax+rax]
     f0: mov     rax,[rbp-28h]
     f4: mov     [rbp-88h],rax
     fb: cmp     qword ptr [rbp-88h],0
    103: sete    [rbp-79h]
    107: test    byte ptr [rbp-79h],0FFh
    10b: je      279h
    111: jmp     23Dh
    116: nop     [rax+rax]
    11f: nop
    120: mov     edi,0FFFFFFF0h
    125: mov     esi,10h
    12a: call    ryo_h_Ret
    12f: leave
    130: ret
    131: mov     rax,[rbp-38h]
    135: mov     [rbp-90h],rax
    13c: mov     rax,[rbp-90h]
    143: mov     [rbp-0B0h],rax
    14a: mov     edi,0FFFFFF58h
    14f: lea     rsi,[k6]
    156: call    ryo_h_AddrAbs
    15b: call    fn7
    160: nop     [rcx-38h]
    167: mov     edi,0FFFFFF90h
    16c: mov     esi,0FFFFFF78h
    171: call    ryo_h_MovW128
    176: mov     edi,0FFFFFFF0h
    17b: mov     esi,0FFFFFF90h
    180: call    ryo_h_MovW128
    185: jmp     120h
    187: mov     rax,[rbp+10h]
    18b: mov     [rbp-68h],rax
    18f: mov     rax,[rbp-60h]
    193: mov     [rbp-0B0h],rax
    19a: mov     rax,[rbp-68h]
    19e: mov     [rbp-0A8h],rax
    1a5: lea     rdi,[sym8]
    1ac: lea     rsi,[site9]
    1b3: mov     edx,0FFFFFF68h
    1b8: call    ryo_h_CallExt
    1bd: test    rax,rax
    1c0: je      1CDh
    1c2: call    rax
    1c4: nop     [rcx-28h]
    1cb: jmp     1DDh
    1cd: mov     rdi,rbp
    1d0: lea     rsi,[ro+36]
    1d7: call    qword ptr [sym10]
    1dd: jmp     0F0h
    1e2: mov     rax,[rbp+10h]
    1e6: mov     [rbp-68h],rax
    1ea: mov     rax,[rbp-60h]
    1ee: mov     [rbp-0B0h],rax
    1f5: mov     rax,[rbp-68h]
    1f9: mov     [rbp-0A8h],rax
    200: lea     rdi,[sym11]
    207: lea     rsi,[site12]
    20e: mov     edx,0FFFFFF68h
    213: call    ryo_h_CallExt
    218: test    rax,rax
    21b: je      228h
    21d: call    rax
    21f: nop     [rcx-28h]
    226: jmp     238h
    228: mov     rdi,rbp
    22b: lea     rsi,[ro+36]
    232: call    qword ptr [sym13]
    238: jmp     0F0h
    23d: mov     qword ptr [rbp-78h],0
    245: mov     qword ptr [rbp-70h],0
    24d: mov     qword ptr [rbp-70h],1
    255: cmp     qword ptr [rbp-70h],1
    25a: sete    [rbp-71h]
    25e: mov     edi,0FFFFFFF0h
    263: lea     rsi,[k14]
    26a: mov     edx,10h
    26f: call    ryo_h_Const
    274: jmp     120h
    279: mov     byte ptr [rbp-91h],1
    280: test    byte ptr [rbp-91h],0FFh
    287: je      2BFh
    289: mov     rax,[rbp-28h]
    28d: mov     [rbp-90h],rax
    294: mov     rax,[rbp-90h]
    29b: mov     [rbp-0B0h],rax
    2a2: mov     edi,0FFFFFF58h
    2a7: lea     rsi,[k15]
    2ae: call    ryo_h_AddrAbs
    2b3: call    fn16
    2b8: nop     [rcx-58h]
    2bf: mov     rax,[rbp-28h]
    2c3: mov     [rbp-88h],rax
    2ca: mov     rax,[rbp-88h]
    2d1: mov     [rbp-78h],rax
    2d5: mov     rax,[rbp-78h]
    2d9: mov     [rbp-80h],rax
    2dd: mov     rax,[rbp-80h]
    2e1: mov     [rbp-70h],rax
    2e5: mov     rax,[rbp-70h]
    2e9: mov     [rbp-78h],rax
    2ed: mov     rax,[rbp-78h]
    2f1: mov     [rbp-68h],rax
    2f5: mov     rax,[rbp-68h]
    2f9: mov     [rbp-30h],rax
    2fd: mov     rax,[rbp-30h]
    301: mov     [rbp-88h],rax
    308: mov     rax,[rbp-88h]
    30f: mov     [rbp-80h],rax
    313: mov     rax,[rbp-60h]
    317: mov     [rbp-78h],rax
    31b: mov     byte ptr [rbp-91h],1
    322: test    byte ptr [rbp-91h],0FFh
    329: je      361h
    32b: mov     rax,[rbp-30h]
    32f: mov     [rbp-88h],rax
    336: mov     rax,[rbp-88h]
    33d: mov     [rbp-0B0h],rax
    344: mov     edi,0FFFFFF58h
    349: lea     rsi,[k17]
    350: call    ryo_h_AddrAbs
    355: call    fn18
    35a: nop     [rcx-58h]
    361: mov     edi,0FFFFFF90h
    366: mov     esi,0FFFFFF80h
    36b: call    ryo_h_MovW128
    370: mov     edi,0FFFFFFF0h
    375: mov     esi,0FFFFFF90h
    37a: call    ryo_h_MovW128
    37f: jmp     120h

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
     b2: je      15Fh
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
    122: mov     rax,[rbp-40h]
    126: mov     [rbp-80h],rax
    12a: mov     qword ptr [rbp-78h],1
    132: mov     qword ptr [rbp-70h],1
    13a: mov     rax,[rbp-18h]
    13e: mov     [rbp-68h],rax
    142: mov     edi,0FFFFFFA0h
    147: lea     rsi,[k3]
    14e: call    ryo_h_AddrAbs
    153: call    fn4
    158: nop     [rcx-30h]
    15f: mov     rax,[rbp-38h]
    163: mov     [rbp-48h],rax
    167: mov     rax,[rbp-18h]
    16b: mov     [rbp-40h],rax
    16f: mov     rax,[rbp-48h]
    173: mov     [rbp-10h],rax
    177: mov     rax,[rbp-40h]
    17b: mov     [rbp-8],rax
    17f: mov     edi,0FFFFFFF0h
    184: mov     esi,10h
    189: call    ryo_h_Ret
    18e: leave
    18f: ret

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
     2e: mov     rax,[rbp-98h]
     35: mov     [rbp-80h],rax
     39: mov     edi,0FFFFFF70h
     3e: lea     rsi,[sym0]
     45: call    ryo_h_AddrSym
     4a: mov     rax,[rbp-90h]
     51: mov     [rbp-88h],rax
     58: mov     rax,[rbp-80h]
     5c: mov     [rbp-78h],rax
     60: mov     rax,[rbp-88h]
     67: mov     [rbp-70h],rax
     6b: mov     edi,0FFFFFF98h
     70: mov     esi,0FFFFFF88h
     75: call    ryo_h_MovW128
     7a: mov     rax,[rbp-10h]
     7e: mov     [rbp-0A8h],rax
     85: mov     rax,[rbp-0A8h]
     8c: mov     [rbp-90h],rax
     93: mov     edi,0FFFFFF60h
     98: lea     rsi,[sym1]
     9f: call    ryo_h_AddrSym
     a4: mov     rax,[rbp-0A0h]
     ab: mov     [rbp-98h],rax
     b2: mov     rax,[rbp-90h]
     b9: mov     [rbp-88h],rax
     c0: mov     rax,[rbp-98h]
     c7: mov     [rbp-80h],rax
     cb: mov     edi,0FFFFFF88h
     d0: mov     esi,0FFFFFF78h
     d5: call    ryo_h_MovW128
     da: mov     rax,[rbp-18h]
     de: mov     [rbp-0B8h],rax
     e5: mov     rax,[rbp-0B8h]
     ec: mov     [rbp-0A0h],rax
     f3: mov     edi,0FFFFFF50h
     f8: lea     rsi,[sym2]
     ff: call    ryo_h_AddrSym
    104: mov     rax,[rbp-0B0h]
    10b: mov     [rbp-0A8h],rax
    112: mov     rax,[rbp-0A0h]
    119: mov     [rbp-98h],rax
    120: mov     rax,[rbp-0A8h]
    127: mov     [rbp-90h],rax
    12e: mov     edi,0FFFFFF78h
    133: mov     esi,0FFFFFF68h
    138: call    ryo_h_MovW128
    13d: mov     edi,0FFFFFFA8h
    142: mov     esi,0FFFFFF98h
    147: call    ryo_h_MovW128
    14c: mov     edi,0FFFFFFB8h
    151: mov     esi,0FFFFFF88h
    156: call    ryo_h_MovW128
    15b: mov     edi,0FFFFFFC8h
    160: mov     esi,0FFFFFF78h
    165: call    ryo_h_MovW128
    16a: lea     rax,[rbp-58h]
    16e: mov     [rbp-60h],rax
    172: mov     edi,0FFFFFF98h
    177: lea     rsi,[k3]
    17e: call    ryo_h_AddrAbs
    183: mov     rax,[rbp-60h]
    187: mov     [rbp-70h],rax
    18b: mov     rax,[rbp-68h]
    18f: mov     [rbp-28h],rax
    193: mov     rax,[rbp-70h]
    197: mov     [rbp-20h],rax
    19b: mov     edi,0FFFFFF20h
    1a0: mov     esi,0FFFFFFD8h
    1a5: call    ryo_h_MovW128
    1aa: mov     rax,[rbp+28h]
    1ae: mov     [rbp-0D0h],rax
    1b5: lea     rdi,[sym4]
    1bc: lea     rsi,[site5]
    1c3: mov     edx,0FFFFFF40h
    1c8: call    ryo_h_CallExt
    1cd: test    rax,rax
    1d0: je      1DDh
    1d2: call    rax
    1d4: nop     [rcx]
    1db: jmp     1EDh
    1dd: mov     rdi,rbp
    1e0: lea     rsi,[ro+4]
    1e7: call    qword ptr [sym6]
    1ed: call    ryo_h_Unreachable
    1f2: ud2

fn std::char::encode_utf8_raw_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: cmp     dword ptr [rbp+10h],80h
      f: jb      17Bh
     15: jmp     14Bh
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
     4c: mov     rax,[rbp-18h]
     50: movzx   ecx,byte ptr [rbp-9]
     54: mov     [rax],cl
     56: jmp     140h
     5b: nop     [rax+rax]
     60: cmp     qword ptr [rbp-8],3
     65: jne     0C1h
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
     93: mov     rax,[rbp-18h]
     97: movzx   ecx,byte ptr [rbp-0Ah]
     9b: mov     [rax],cl
     9d: mov     qword ptr [rbp-20h],2
     a5: mov     rax,[rbp+18h]
     a9: imul    rcx,[rbp-20h],1
     ae: add     rax,rcx
     b1: mov     [rbp-18h],rax
     b5: mov     rax,[rbp-18h]
     b9: movzx   ecx,byte ptr [rbp-9]
     bd: mov     [rax],cl
     bf: jmp     140h
     c1: mov     rax,[rbp+18h]
     c5: movzx   ecx,byte ptr [rbp-0Ch]
     c9: mov     [rax],cl
     cb: mov     qword ptr [rbp-20h],1
     d3: mov     rax,[rbp+18h]
     d7: imul    rcx,[rbp-20h],1
     dc: add     rax,rcx
     df: mov     [rbp-18h],rax
     e3: mov     rax,[rbp-18h]
     e7: movzx   ecx,byte ptr [rbp-0Bh]
     eb: mov     [rax],cl
     ed: mov     qword ptr [rbp-20h],2
     f5: mov     rax,[rbp+18h]
     f9: imul    rcx,[rbp-20h],1
     fe: add     rax,rcx
    101: mov     [rbp-18h],rax
    105: mov     rax,[rbp-18h]
    109: movzx   ecx,byte ptr [rbp-0Ah]
    10d: mov     [rax],cl
    10f: mov     qword ptr [rbp-20h],3
    117: mov     rax,[rbp+18h]
    11b: imul    rcx,[rbp-20h],1
    120: add     rax,rcx
    123: mov     [rbp-18h],rax
    127: mov     rax,[rbp-18h]
    12b: movzx   ecx,byte ptr [rbp-9]
    12f: mov     [rax],cl
    131: jmp     140h
    133: nop     [rax+rax]
    13c: nop     [rax]
    140: xor     edi,edi
    142: xor     esi,esi
    144: call    ryo_h_Ret
    149: leave
    14a: ret
    14b: cmp     dword ptr [rbp+10h],800h
    152: jb      171h
    154: cmp     dword ptr [rbp+10h],10000h
    15b: jb      167h
    15d: mov     qword ptr [rbp-8],4
    165: jmp     19Eh
    167: mov     qword ptr [rbp-8],3
    16f: jmp     19Eh
    171: mov     qword ptr [rbp-8],2
    179: jmp     19Eh
    17b: mov     qword ptr [rbp-8],1
    183: mov     edi,0FFFFFFE0h
    188: mov     esi,10h
    18d: call    ryo_h_TruncW32W8
    192: mov     rax,[rbp+18h]
    196: movzx   ecx,byte ptr [rbp-20h]
    19a: mov     [rax],cl
    19c: jmp     140h
    19e: mov     eax,[rbp+10h]
    1a1: and     eax,3Fh
    1a4: mov     [rbp-10h],eax
    1a7: mov     edi,0FFFFFFF6h
    1ac: mov     esi,0FFFFFFF0h
    1b1: call    ryo_h_TruncW32W8
    1b6: movzx   eax,byte ptr [rbp-0Ah]
    1ba: or      al,80h
    1bd: mov     [rbp-9],al
    1c0: mov     eax,[rbp+10h]
    1c3: shr     eax,6
    1c6: mov     [rbp-14h],eax
    1c9: mov     eax,[rbp-14h]
    1cc: and     eax,3Fh
    1cf: mov     [rbp-10h],eax
    1d2: mov     edi,0FFFFFFF5h
    1d7: mov     esi,0FFFFFFF0h
    1dc: call    ryo_h_TruncW32W8
    1e1: movzx   eax,byte ptr [rbp-0Bh]
    1e5: or      al,80h
    1e8: mov     [rbp-0Ah],al
    1eb: mov     eax,[rbp+10h]
    1ee: shr     eax,0Ch
    1f1: mov     [rbp-14h],eax
    1f4: mov     eax,[rbp-14h]
    1f7: and     eax,3Fh
    1fa: mov     [rbp-10h],eax
    1fd: mov     edi,0FFFFFFF4h
    202: mov     esi,0FFFFFFF0h
    207: call    ryo_h_TruncW32W8
    20c: movzx   eax,byte ptr [rbp-0Ch]
    210: or      al,80h
    213: mov     [rbp-0Bh],al
    216: mov     eax,[rbp+10h]
    219: shr     eax,12h
    21c: mov     [rbp-18h],eax
    21f: mov     eax,[rbp-18h]
    222: and     eax,3Fh
    225: mov     [rbp-14h],eax
    228: mov     edi,0FFFFFFF3h
    22d: mov     esi,0FFFFFFECh
    232: call    ryo_h_TruncW32W8
    237: movzx   eax,byte ptr [rbp-0Dh]
    23b: or      al,0F0h
    23e: mov     [rbp-0Ch],al
    241: mov     rax,[rbp-8]
    245: mov     [rbp-18h],rax
    249: cmp     qword ptr [rbp-18h],2
    24e: je      20h
    254: jmp     60h

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
     13: mov     rax,[rbp-58h]
     17: mov     [rbp-0D0h],rax
     1e: mov     edi,0FFFFFF38h
     23: mov     esi,18h
     28: mov     edx,18h
     2d: call    ryo_h_Copy
     32: call    fn0
     37: nop     [rcx-50h]
     3e: mov     edi,0FFFFFF54h
     43: mov     esi,0FFFFFFB0h
     48: mov     rdx,0FFFFFFFFFFFFFFFFh
     4f: xor     ecx,ecx
     51: xor     r8d,r8d
     54: mov     r9d,1
     5a: call    ryo_h_DiscrNicheW64
     5f: mov     edi,0FFFFFFA8h
     64: mov     esi,0FFFFFF54h
     69: call    ryo_h_ZextW32W64
     6e: mov     edi,0FFFFFFA8h
     73: xor     esi,esi
     75: mov     edx,2
     7a: call    ryo_h_SwitchDenseW64
     7f: lea     rcx,[90h]
     86: movsxd  rax,[rcx+rax*4]
     8a: add     rax,rcx
     8d: jmp     rax
     8f: int3
     90: .long   f6h
     94: .long   b8h
     98: .long   b1h
     9c: nop     [rax]
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
     13: mov     rax,[rbp-38h]
     17: mov     [rbp-80h],rax
     1b: mov     rax,[rbp+18h]
     1f: mov     [rbp-78h],rax
     23: call    fn0
     28: nop     [rcx-30h]
     2f: mov     edi,0FFFFFF94h
     34: mov     esi,0FFFFFFD0h
     39: xor     edx,edx
     3b: xor     ecx,ecx
     3d: xor     r8d,r8d
     40: mov     r9d,1
     46: call    ryo_h_DiscrNicheW64
     4b: mov     edi,0FFFFFFC8h
     50: mov     esi,0FFFFFF94h
     55: call    ryo_h_ZextW32W64
     5a: mov     edi,0FFFFFFC8h
     5f: xor     esi,esi
     61: mov     edx,2
     66: call    ryo_h_SwitchDenseW64
     6b: lea     rcx,[7Ch]
     72: movsxd  rax,[rcx+rax*4]
     76: add     rax,rcx
     79: jmp     rax
     7b: int3
     7c: .long   e6h
     80: .long   a8h
     84: .long   a1h
     88: nop     [rax+rax]
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
     10: mov     rax,[rbp-10h]
     14: mov     [rbp-20h],rax
     18: mov     rax,[rbp+18h]
     1c: mov     [rbp-18h],rax
     20: call    fn0
     25: nop     [rcx-8]
     2c: mov     edi,0FFFFFFF8h
     31: mov     esi,8
     36: call    ryo_h_Ret
     3b: leave
     3c: ret

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
     10: mov     rax,[rbp-8]
     14: mov     [rbp-10h],rax
     18: call    fn0
     1d: nop     [rcx]
     24: xor     edi,edi
     26: xor     esi,esi
     28: call    ryo_h_Ret
     2d: leave
     2e: ret

fn std::collections::HashMap::<u64, u64>::values
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-80h],rax
     13: mov     rax,[rbp-80h]
     17: mov     [rbp-90h],rax
     1e: call    fn0
     23: nop     [rcx-78h]
     2a: mov     edi,0FFFFFFB0h
     2f: mov     esi,0FFFFFF88h
     34: mov     edx,28h
     39: call    ryo_h_Copy
     3e: mov     edi,0FFFFFFD8h
     43: mov     esi,0FFFFFFB0h
     48: mov     edx,28h
     4d: call    ryo_h_Copy
     52: mov     edi,0FFFFFFD8h
     57: mov     esi,28h
     5c: call    ryo_h_Ret
     61: leave
     62: ret

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
     c7: je      203h
     cd: jmp     1F9h
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
    15e: jmp     24Ch
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
    1ab: mov     rax,[rbp-0E0h]
    1b2: mov     [rbp-110h],rax
    1b9: call    fn2
    1be: nop     [rcx-0E0h]
    1c5: jmp     190h
    1c7: nop     [rax+rax]
    1d0: test    byte ptr [rbp-11h],0FFh
    1d4: je      190h
    1d6: jmp     1A0h
    1d8: nop     [rax+rax]
    1e0: mov     rax,[rbp-40h]
    1e4: mov     [rbp-38h],rax
    1e8: mov     rax,[rbp-38h]
    1ec: lea     rax,[rax+18h]
    1f0: mov     [rbp-8],rax
    1f4: jmp     170h
    1f9: mov     qword ptr [rbp-40h],8
    201: jmp     1E0h
    203: mov     rax,[rbp-58h]
    207: mov     [rbp-48h],rax
    20b: mov     byte ptr [rbp-0D9h],0
    212: test    byte ptr [rbp-0D9h],0FFh
    219: je      22Ch
    21b: jmp     222h
    21d: nop     [rax]
    220: jmp     1E0h
    222: mov     rax,[rbp-48h]
    226: mov     [rbp-40h],rax
    22a: jmp     220h
    22c: mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    237: mov     rax,[rbp-48h]
    23b: imul    rcx,[rbp-0E0h],20h
    243: add     rax,rcx
    246: mov     [rbp-40h],rax
    24a: jmp     220h
    24c: mov     byte ptr [rbp-0D9h],0
    253: test    byte ptr [rbp-0D9h],0FFh
    25a: je      28Fh
    25c: jmp     282h
    25e: xchg    ax,ax
    260: mov     rax,[rbp-0A0h]
    267: mov     [rbp-98h],rax
    26e: mov     rax,[rbp-98h]
    275: lea     rax,[rax+18h]
    279: mov     [rbp-8],rax
    27d: jmp     170h
    282: mov     qword ptr [rbp-0A0h],8
    28d: jmp     260h
    28f: mov     rax,[rbp-90h]
    296: mov     [rbp-0B0h],rax
    29d: mov     rax,[rbp-0B0h]
    2a4: mov     [rbp-0A8h],rax
    2ab: mov     byte ptr [rbp-0D9h],0
    2b2: test    byte ptr [rbp-0D9h],0FFh
    2b9: je      2D2h
    2bb: jmp     2C2h
    2bd: nop     [rax]
    2c0: jmp     260h
    2c2: mov     rax,[rbp-0A8h]
    2c9: mov     [rbp-0A0h],rax
    2d0: jmp     2C0h
    2d2: mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    2dd: mov     rax,[rbp-0A8h]
    2e4: imul    rcx,[rbp-0E0h],20h
    2ec: add     rax,rcx
    2ef: mov     [rbp-0A0h],rax
    2f6: jmp     2C0h
    2f8: nop     [rax+rax]
    300: lea     rdi,[sym3]
    307: lea     rsi,[site4]
    30e: mov     edx,0FFFFFF20h
    313: call    ryo_h_CallExt
    318: test    rax,rax
    31b: je      328h
    31d: call    rax
    31f: nop     [rcx-0D8h]
    326: jmp     338h
    328: mov     rdi,rbp
    32b: lea     rsi,[ro+4]
    332: call    qword ptr [sym5]
    338: call    ryo_h_Unreachable
    33d: ud2
    33f: mov     rdi,rax
    342: mov     esi,0FFFFFFD0h
    347: call    ryo_h_Lpad
    34c: jmp     1D0h
    351: mov     rdi,rax
    354: mov     esi,0FFFFFFD0h
    359: call    ryo_h_Lpad
    35e: jmp     300h

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
     ea: je      1F3h
     f0: jmp     1E9h
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
    150: je      180h
    152: jmp     176h
    154: nop     [rax+rax]
    15d: nop     [rax]
    160: mov     rax,[rbp-50h]
    164: mov     [rbp-48h],rax
    168: mov     rax,[rbp-48h]
    16c: lea     rax,[rax+8]
    170: mov     [rbp-8],rax
    174: jmp     100h
    176: mov     qword ptr [rbp-50h],8
    17e: jmp     160h
    180: mov     rax,[rbp-40h]
    184: mov     [rbp-60h],rax
    188: mov     rax,[rbp-60h]
    18c: mov     [rbp-58h],rax
    190: mov     byte ptr [rbp-79h],0
    194: test    byte ptr [rbp-79h],0FFh
    198: je      1ACh
    19a: jmp     1A2h
    19c: nop     [rax]
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
    1d8: mov     rax,[rbp-38h]
    1dc: lea     rax,[rax+8]
    1e0: mov     [rbp-8],rax
    1e4: jmp     100h
    1e9: mov     qword ptr [rbp-40h],8
    1f1: jmp     1D0h
    1f3: mov     rax,[rbp-58h]
    1f7: mov     [rbp-48h],rax
    1fb: mov     byte ptr [rbp-79h],0
    1ff: test    byte ptr [rbp-79h],0FFh
    203: je      21Ch
    205: jmp     212h
    207: nop     [rax+rax]
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
     17: mov     rax,[rbp-28h]
     1b: mov     [rbp-20h],rax
     1f: mov     rax,[rbp-20h]
     23: and     rax,1
     27: mov     [rbp-28h],rax
     2b: cmp     qword ptr [rbp-28h],1
     30: je      6Fh
     32: jmp     9Eh
     34: nop     [rax+rax]
     3d: nop     [rax]
     40: test    byte ptr [rbp-19h],0FFh
     44: je      48h
     46: jmp     5Eh
     48: mov     edi,0FFFFFFF0h
     4d: lea     rsi,[k0]
     54: mov     edx,10h
     59: call    ryo_h_Const
     5e: mov     edi,0FFFFFFF0h
     63: mov     esi,10h
     68: call    ryo_h_Ret
     6d: leave
     6e: ret
     6f: mov     rax,[rbp+10h]
     73: mov     rax,[rax]
     76: mov     [rbp-50h],rax
     7a: mov     rax,[rbp-50h]
     7e: mov     [rbp-28h],rax
     82: mov     rax,[rbp-20h]
     86: shr     rax,1
     8a: mov     [rbp-58h],rax
     8e: mov     byte ptr [rbp-69h],1
     92: test    byte ptr [rbp-69h],0FFh
     96: je      164h
     9c: jmp     113h
     9e: mov     edi,0FFFFFFF0h
     a3: lea     rsi,[k1]
     aa: mov     edx,10h
     af: call    ryo_h_Const
     b4: nop     [rax+rax]
     bd: nop     [rax]
     c0: mov     edi,0FFFFFF94h
     c5: mov     esi,0FFFFFFF0h
     ca: xor     edx,edx
     cc: xor     ecx,ecx
     ce: xor     r8d,r8d
     d1: mov     r9d,1
     d7: call    ryo_h_DiscrNicheW64
     dc: mov     edi,0FFFFFFD8h
     e1: mov     esi,0FFFFFF94h
     e6: call    ryo_h_ZextW32W64
     eb: cmp     qword ptr [rbp-28h],1
     f0: sete    [rbp-1Ah]
     f4: movzx   eax,byte ptr [rbp-1Ah]
     f8: mov     [rbp-0A0h],al
     fe: mov     rdi,rbp
    101: lea     rsi,[ro+4]
    108: call    qword ptr [sym2]
    10e: jmp     40h
    113: mov     rax,[rbp-50h]
    117: mov     [rbp-60h],rax
    11b: mov     rax,[rbp-60h]
    11f: mov     [rbp-0A0h],rax
    126: mov     qword ptr [rbp-98h],1
    131: mov     qword ptr [rbp-90h],1
    13c: mov     rax,[rbp-58h]
    140: mov     [rbp-88h],rax
    147: mov     edi,0FFFFFF80h
    14c: lea     rsi,[k3]
    153: call    ryo_h_AddrAbs
    158: call    fn4
    15d: nop     [rcx-18h]
    164: mov     rax,[rbp-28h]
    168: mov     [rbp-68h],rax
    16c: mov     rax,[rbp-58h]
    170: mov     [rbp-60h],rax
    174: mov     rax,[rbp-68h]
    178: mov     [rbp-48h],rax
    17c: mov     rax,[rbp-60h]
    180: mov     [rbp-40h],rax
    184: mov     edi,0FFFFFFC8h
    189: mov     esi,0FFFFFFB8h
    18e: call    ryo_h_MovW128
    193: mov     edi,0FFFFFFF0h
    198: mov     esi,0FFFFFFC8h
    19d: call    ryo_h_MovW128
    1a2: jmp     0C0h

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
     13: mov     rax,[rbp-40h]
     17: mov     [rbp-38h],rax
     1b: mov     rax,[rbp-38h]
     1f: and     rax,1
     23: mov     [rbp-40h],rax
     27: cmp     qword ptr [rbp-40h],1
     2c: je      41h
     2e: jmp     73h
     30: mov     edi,0FFFFFFE8h
     35: mov     esi,18h
     3a: call    ryo_h_Ret
     3f: leave
     40: ret
     41: mov     rax,[rbp+10h]
     45: mov     [rbp-68h],rax
     49: mov     rax,[rbp-68h]
     4d: mov     [rbp-40h],rax
     51: mov     rax,[rbp-38h]
     55: shr     rax,1
     59: mov     [rbp-70h],rax
     5d: mov     byte ptr [rbp-81h],1
     64: test    byte ptr [rbp-81h],0FFh
     6b: je      11Ch
     71: jmp     0CBh
     73: mov     edi,0FFFFFFD0h
     78: lea     rsi,[k0]
     7f: mov     edx,10h
     84: call    ryo_h_Const
     89: nop     [rax]
     90: lea     rax,[rbp+10h]
     94: mov     [rbp-40h],rax
     98: mov     rax,[rbp-40h]
     9c: mov     [rbp-38h],rax
     a0: mov     edi,0FFFFFF58h
     a5: mov     esi,0FFFFFFD0h
     aa: call    ryo_h_MovW128
     af: mov     rax,[rbp-38h]
     b3: mov     [rbp-0B0h],rax
     ba: call    fn1
     bf: nop     [rcx-18h]
     c6: jmp     30h
     cb: mov     rax,[rbp-68h]
     cf: mov     [rbp-78h],rax
     d3: mov     rax,[rbp-78h]
     d7: mov     [rbp-0B0h],rax
     de: mov     qword ptr [rbp-0A8h],1
     e9: mov     qword ptr [rbp-0A0h],1
     f4: mov     rax,[rbp-70h]
     f8: mov     [rbp-98h],rax
     ff: mov     edi,0FFFFFF70h
    104: lea     rsi,[k2]
    10b: call    ryo_h_AddrAbs
    110: call    fn3
    115: nop     [rcx-20h]
    11c: mov     rax,[rbp-40h]
    120: mov     [rbp-80h],rax
    124: mov     rax,[rbp-70h]
    128: mov     [rbp-78h],rax
    12c: mov     rax,[rbp-80h]
    130: mov     [rbp-60h],rax
    134: mov     rax,[rbp-78h]
    138: mov     [rbp-58h],rax
    13c: mov     edi,0FFFFFFB0h
    141: mov     esi,0FFFFFFA0h
    146: call    ryo_h_MovW128
    14b: mov     edi,0FFFFFFD0h
    150: mov     esi,0FFFFFFB0h
    155: call    ryo_h_MovW128
    15a: jmp     90h

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
     10: mov     rax,[rbp-30h]
     14: mov     [rbp-28h],rax
     18: mov     rax,[rbp-28h]
     1c: mov     rax,[rax]
     1f: mov     [rbp-18h],rax
     23: mov     rax,[rbp-28h]
     27: mov     rax,[rax+8]
     2b: mov     [rbp-20h],rax
     2f: mov     rax,[rbp-18h]
     33: add     rax,1
     37: mov     [rbp-38h],rax
     3b: mov     rax,[rbp-38h]
     3f: mov     [rbp-30h],rax
     43: mov     rax,[rbp-20h]
     47: mov     [rbp-28h],rax
     4b: mov     rax,[rbp+10h]
     4f: mov     [rbp-40h],rax
     53: mov     rax,[rbp-40h]
     57: mov     [rbp-38h],rax
     5b: mov     edi,0FFFFFFC8h
     60: xor     esi,esi
     62: mov     edx,0FFFFFFD0h
     67: call    ryo_h_StoreW128
     6c: mov     rax,[rbp-18h]
     70: mov     [rbp-10h],rax
     74: mov     rax,[rbp-20h]
     78: mov     [rbp-8],rax
     7c: mov     edi,0FFFFFFF0h
     81: mov     esi,10h
     86: call    ryo_h_Ret
     8b: leave
     8c: ret

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
     3c: mov     rax,[rbp-30h]
     40: mov     [rbp-28h],rax
     44: mov     edi,0FFFFFFA8h
     49: lea     rsi,[k1]
     50: call    ryo_h_AddrAbs
     55: mov     qword ptr [rbp-50h],0C7h
     5d: mov     rax,[rbp-50h]
     61: mov     [rbp-48h],rax
     65: mov     rax,[rbp-48h]
     69: shl     rax,1
     6d: mov     [rbp-40h],rax
     71: mov     rax,[rbp-40h]
     75: or      rax,1
     79: mov     [rbp-38h],rax
     7d: mov     rax,[rbp-38h]
     81: mov     [rbp-30h],rax
     85: mov     rax,[rbp-28h]
     89: mov     [rbp-20h],rax
     8d: mov     rax,[rbp-30h]
     91: mov     [rbp-18h],rax
     95: mov     edi,0FFFFFF80h
     9a: mov     esi,0FFFFFFE0h
     9f: call    ryo_h_MovW128
     a4: mov     byte ptr [rbp-70h],0
     a8: mov     rax,[rbp+10h]
     ac: mov     [rbp-68h],rax
     b0: lea     rdi,[sym2]
     b7: lea     rsi,[site3]
     be: mov     edx,0FFFFFFA0h
     c3: call    ryo_h_CallExt
     c8: test    rax,rax
     cb: je      0D8h
     cd: call    rax
     cf: nop     [rcx-10h]
     d6: jmp     0E8h
     d8: mov     rdi,rbp
     db: lea     rsi,[ro+4]
     e2: call    qword ptr [sym4]
     e8: call    ryo_h_Unreachable
     ed: ud2

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
     26: cmp     dword ptr [rbp-20h],0
     2a: jne     7Ch
     2c: mov     edi,0FFFFFFB0h
     31: lea     rsi,[k0]
     38: call    ryo_h_AddrAbs
     3d: lea     rdi,[sym1]
     44: lea     rsi,[site2]
     4b: mov     edx,0FFFFFFD0h
     50: call    ryo_h_CallExt
     55: test    rax,rax
     58: je      65h
     5a: call    rax
     5c: nop     [rcx-24h]
     63: jmp     75h
     65: mov     rdi,rbp
     68: lea     rsi,[ro+4]
     6f: call    qword ptr [sym3]
     75: call    ryo_h_Unreachable
     7a: ud2
     7c: mov     edi,0FFFFFFE4h
     81: mov     esi,18h
     86: mov     edx,0FFFFFFE0h
     8b: call    ryo_h_RemUW32
     90: mov     edi,0FFFFFFD0h
     95: mov     esi,0FFFFFFE4h
     9a: call    ryo_h_ZextW32W64
     9f: mov     qword ptr [rbp-38h],3Fh
     a7: mov     rax,[rbp-38h]
     ab: sub     rax,[rbp-30h]
     af: mov     [rbp-38h],rax
     b3: mov     edi,0FFFFFFC0h
     b8: mov     esi,10h
     bd: mov     edx,0FFFFFFD0h
     c2: call    ryo_h_ShlW64
     c7: mov     rax,[rbp+10h]
     cb: shr     rax,1
     cf: mov     [rbp-48h],rax
     d3: mov     edi,0FFFFFFB8h
     d8: mov     esi,0FFFFFFB8h
     dd: mov     edx,0FFFFFFC8h
     e2: call    ryo_h_ShrUW64
     e7: mov     rax,[rbp-40h]
     eb: or      rax,[rbp-48h]
     ef: mov     [rbp-8],rax
     f3: mov     edi,0FFFFFFF8h
     f8: mov     esi,8
     fd: call    ryo_h_Ret
    102: leave
    103: ret
    104: nop     [rax+rax]
    10d: nop     [rax]
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
     16: mov     rax,[rbp-58h]
     1a: mov     [rbp-80h],rax
     1e: call    fn0
     23: nop     [rcx-50h]
     2a: jmp     111h
     2f: nop
     30: call    ryo_h_Unreachable
     35: ud2
     37: mov     rax,[rbp-48h]
     3b: mov     [rbp-38h],rax
     3f: mov     rax,[rbp-38h]
     43: movzx   eax,byte ptr [rax+10h]
     47: mov     [rbp-69h],al
     4a: mov     edi,0FFFFFFA8h
     4f: mov     esi,0FFFFFF97h
     54: call    ryo_h_ZextW8W64
     59: cmp     qword ptr [rbp-58h],23h
     5e: sete    [rbp-1]
     62: jmp     100h
     67: movzx   eax,byte ptr [rbp-4Fh]
     6b: mov     [rbp-51h],al
     6e: mov     edi,0FFFFFFA0h
     73: mov     esi,0FFFFFFAFh
     78: call    ryo_h_ZextW8W64
     7d: cmp     qword ptr [rbp-60h],23h
     82: sete    [rbp-1]
     86: jmp     100h
     88: mov     rax,[rbp-48h]
     8c: mov     [rbp-20h],rax
     90: mov     rax,[rbp-20h]
     94: movzx   eax,byte ptr [rax+20h]
     98: mov     [rbp-69h],al
     9b: mov     edi,0FFFFFFA8h
     a0: mov     esi,0FFFFFF97h
     a5: call    ryo_h_ZextW8W64
     aa: cmp     qword ptr [rbp-58h],23h
     af: sete    [rbp-1]
     b3: jmp     100h
     b5: mov     eax,[rbp-4Ch]
     b8: mov     [rbp-54h],eax
     bb: lea     rdi,[sym1]
     c2: lea     rsi,[site2]
     c9: mov     edx,0FFFFFF90h
     ce: call    ryo_h_CallExt
     d3: test    rax,rax
     d6: je      0E3h
     d8: call    rax
     da: nop     [rcx-60h]
     e1: jmp     0F3h
     e3: mov     rdi,rbp
     e6: lea     rsi,[ro+4]
     ed: call    qword ptr [sym3]
     f3: jmp     158h
     f5: nop     [rax+rax]
     fe: xchg    ax,ax
    100: mov     edi,0FFFFFFFFh
    105: mov     esi,1
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: mov     edi,0FFFFFFE8h
    116: mov     esi,0FFFFFFB0h
    11b: call    ryo_h_ZextW8W64
    120: mov     edi,0FFFFFFE8h
    125: xor     esi,esi
    127: mov     edx,4
    12c: call    ryo_h_SwitchDenseW64
    131: lea     rcx,[144h]
    138: movsxd  rax,[rcx+rax*4]
    13c: add     rax,rcx
    13f: jmp     rax
    141: int3
    142: int3
    143: int3
    144: .long   b5h
    148: .long   67h
    14c: .long   37h
    150: .long   88h
    154: .long   30h
    158: mov     rax,[rbp-60h]
    15c: mov     rax,[rax+10h]
    160: mov     [rbp-68h],rax
    164: mov     eax,[rbp-54h]
    167: mov     [rbp-80h],eax
    16a: mov     edi,0FFFFFF98h
    16f: lea     rsi,[site4]
    176: call    ryo_h_CallInd
    17b: test    rax,rax
    17e: je      18Bh
    180: call    rax
    182: nop     [rcx-1]
    189: jmp     19Bh
    18b: mov     rdi,rbp
    18e: lea     rsi,[ro+20]
    195: call    qword ptr [sym5]
    19b: jmp     100h

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
     2b: je      4Ch
     2d: mov     rax,[rbp+10h]
     31: mov     [rbp-60h],rax
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-68h],rax
     3d: mov     rax,[rbp-68h]
     41: cmp     rax,[rbp-60h]
     45: jae     0BFh
     47: jmp     0D5h
     4c: mov     qword ptr [rbp-50h],0
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: cmp     qword ptr [rbp+20h],0
     65: sete    [rbp-59h]
     69: test    byte ptr [rbp-59h],0FFh
     6d: je      0DFh
     6f: mov     edi,0FFFFFF80h
     74: lea     rsi,[k0]
     7b: call    ryo_h_AddrAbs
     80: lea     rdi,[sym1]
     87: lea     rsi,[site2]
     8e: mov     edx,0FFFFFF88h
     93: call    ryo_h_CallExt
     98: test    rax,rax
     9b: je      0A8h
     9d: call    rax
     9f: nop     [rcx-70h]
     a6: jmp     0B8h
     a8: mov     rdi,rbp
     ab: lea     rsi,[ro+4]
     b2: call    qword ptr [sym3]
     b8: call    ryo_h_Unreachable
     bd: ud2
     bf: mov     rax,[rbp-68h]
     c3: sub     rax,[rbp-60h]
     c7: mov     [rbp-70h],rax
     cb: mov     rax,[rbp-70h]
     cf: mov     [rbp-50h],rax
     d3: jmp     0DDh
     d5: mov     qword ptr [rbp-50h],0
     dd: jmp     60h
     df: mov     edi,0FFFFFFA8h
     e4: mov     esi,0FFFFFFB0h
     e9: mov     edx,20h
     ee: call    ryo_h_DivUW64
     f3: test    byte ptr [rbp-59h],0FFh
     f7: je      149h
     f9: mov     edi,0FFFFFF80h
     fe: lea     rsi,[k4]
    105: call    ryo_h_AddrAbs
    10a: lea     rdi,[sym5]
    111: lea     rsi,[site6]
    118: mov     edx,0FFFFFF88h
    11d: call    ryo_h_CallExt
    122: test    rax,rax
    125: je      132h
    127: call    rax
    129: nop     [rcx-70h]
    130: jmp     142h
    132: mov     rdi,rbp
    135: lea     rsi,[ro+4]
    13c: call    qword ptr [sym7]
    142: call    ryo_h_Unreachable
    147: ud2
    149: mov     edi,0FFFFFF98h
    14e: mov     esi,0FFFFFFB0h
    153: mov     edx,20h
    158: call    ryo_h_RemUW64
    15d: cmp     qword ptr [rbp-68h],0
    162: jbe     172h
    164: mov     rax,[rbp-58h]
    168: add     rax,1
    16c: mov     [rbp-20h],rax
    170: jmp     17Ah
    172: mov     rax,[rbp-58h]
    176: mov     [rbp-20h],rax
    17a: mov     rax,[rbp-20h]
    17e: mov     [rbp+18h],rax
    182: mov     edi,0FFFFFFF0h
    187: mov     esi,10h
    18c: call    ryo_h_MovW128
    191: mov     edi,0FFFFFFF0h
    196: mov     esi,10h
    19b: call    ryo_h_Ret
    1a0: leave
    1a1: ret

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
     2b: je      4Ch
     2d: mov     rax,[rbp+10h]
     31: mov     [rbp-60h],rax
     35: mov     rax,[rbp+18h]
     39: mov     [rbp-68h],rax
     3d: mov     rax,[rbp-68h]
     41: cmp     rax,[rbp-60h]
     45: jae     0BFh
     47: jmp     0CDh
     4c: mov     qword ptr [rbp-50h],0
     54: nop     [rax+rax]
     5d: nop     [rax]
     60: cmp     qword ptr [rbp+20h],0
     65: sete    [rbp-59h]
     69: test    byte ptr [rbp-59h],0FFh
     6d: je      0D7h
     6f: mov     edi,0FFFFFF80h
     74: lea     rsi,[k0]
     7b: call    ryo_h_AddrAbs
     80: lea     rdi,[sym1]
     87: lea     rsi,[site2]
     8e: mov     edx,0FFFFFF90h
     93: call    ryo_h_CallExt
     98: test    rax,rax
     9b: je      0A8h
     9d: call    rax
     9f: nop     [rcx-68h]
     a6: jmp     0B8h
     a8: mov     rdi,rbp
     ab: lea     rsi,[ro+4]
     b2: call    qword ptr [sym3]
     b8: call    ryo_h_Unreachable
     bd: ud2
     bf: mov     rax,[rbp-68h]
     c3: sub     rax,[rbp-60h]
     c7: mov     [rbp-50h],rax
     cb: jmp     0D5h
     cd: mov     qword ptr [rbp-50h],0
     d5: jmp     60h
     d7: mov     edi,0FFFFFFA8h
     dc: mov     esi,0FFFFFFB0h
     e1: mov     edx,20h
     e6: call    ryo_h_DivUW64
     eb: test    byte ptr [rbp-59h],0FFh
     ef: je      141h
     f1: mov     edi,0FFFFFF80h
     f6: lea     rsi,[k4]
     fd: call    ryo_h_AddrAbs
    102: lea     rdi,[sym5]
    109: lea     rsi,[site6]
    110: mov     edx,0FFFFFF90h
    115: call    ryo_h_CallExt
    11a: test    rax,rax
    11d: je      12Ah
    11f: call    rax
    121: nop     [rcx-68h]
    128: jmp     13Ah
    12a: mov     rdi,rbp
    12d: lea     rsi,[ro+4]
    134: call    qword ptr [sym7]
    13a: call    ryo_h_Unreachable
    13f: ud2
    141: mov     edi,0FFFFFF98h
    146: mov     esi,0FFFFFFB0h
    14b: mov     edx,20h
    150: call    ryo_h_RemUW64
    155: cmp     qword ptr [rbp-68h],0
    15a: jbe     16Ah
    15c: mov     rax,[rbp-58h]
    160: add     rax,1
    164: mov     [rbp-20h],rax
    168: jmp     172h
    16a: mov     rax,[rbp-58h]
    16e: mov     [rbp-20h],rax
    172: mov     rax,[rbp-20h]
    176: mov     [rbp+18h],rax
    17a: mov     edi,0FFFFFFF0h
    17f: mov     esi,10h
    184: call    ryo_h_MovW128
    189: mov     edi,0FFFFFFF0h
    18e: mov     esi,10h
    193: call    ryo_h_Ret
    198: leave
    199: ret

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,70h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+10h]
     10: mov     [rbp-50h],rax
     14: mov     rax,[rbp-50h]
     18: add     rax,1
     1c: mov     [rbp-48h],rax
     20: mov     rax,[rbp-48h]
     24: mov     [rbp-50h],rax
     28: mov     edi,0FFFFFFA4h
     2d: mov     esi,0FFFFFFB0h
     32: xor     edx,edx
     34: xor     ecx,ecx
     36: xor     r8d,r8d
     39: mov     r9d,1
     3f: call    ryo_h_DiscrNicheW64
     44: mov     edi,0FFFFFFA8h
     49: mov     esi,0FFFFFFA4h
     4e: call    ryo_h_ZextW32W64
     53: mov     edi,0FFFFFFA8h
     58: xor     esi,esi
     5a: mov     edx,2
     5f: call    ryo_h_SwitchDenseW64
     64: lea     rcx,[74h]
     6b: movsxd  rax,[rcx+rax*4]
     6f: add     rax,rcx
     72: jmp     rax
     74: .long   107h
     78: .long   126h
     7c: .long   100h
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax]
     87: mov     [rbp-38h],rax
     8b: mov     rax,[rbp-38h]
     8f: add     rax,[rbp-20h]
     93: mov     [rbp-40h],rax
     97: mov     rax,[rbp+10h]
     9b: mov     rcx,[rbp-40h]
     9f: mov     [rax],rcx
     a2: mov     rax,[rbp-28h]
     a6: sub     rax,1
     aa: mov     [rbp-60h],rax
     ae: mov     rax,[rbp+10h]
     b2: mov     rcx,[rbp-60h]
     b6: mov     [rax+8],rcx
     ba: mov     rax,[rbp-38h]
     be: mov     [rbp-8],rax
     c2: mov     qword ptr [rbp-10h],1
     ca: jmp     0E6h
     cc: nop     [rax]
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
    12e: mov     rax,[rbp-40h]
    132: mov     [rbp-38h],rax
    136: mov     rax,[rbp-38h]
    13a: mov     [rbp-20h],rax
    13e: mov     rax,[rbp-20h]
    142: mov     [rbp-28h],rax
    146: mov     byte ptr [rbp-30h],0
    14a: mov     rax,[rbp+10h]
    14e: mov     rax,[rax+8]
    152: mov     [rbp-28h],rax
    156: cmp     qword ptr [rbp-28h],0
    15b: ja      80h
    161: jmp     0D0h

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
     3c: mov     rax,[rbp-30h]
     40: mov     [rbp-28h],rax
     44: mov     edi,0FFFFFFA8h
     49: lea     rsi,[k1]
     50: call    ryo_h_AddrAbs
     55: mov     qword ptr [rbp-50h],0D1h
     5d: mov     rax,[rbp-50h]
     61: mov     [rbp-48h],rax
     65: mov     rax,[rbp-48h]
     69: shl     rax,1
     6d: mov     [rbp-40h],rax
     71: mov     rax,[rbp-40h]
     75: or      rax,1
     79: mov     [rbp-38h],rax
     7d: mov     rax,[rbp-38h]
     81: mov     [rbp-30h],rax
     85: mov     rax,[rbp-28h]
     89: mov     [rbp-20h],rax
     8d: mov     rax,[rbp-30h]
     91: mov     [rbp-18h],rax
     95: mov     edi,0FFFFFF80h
     9a: mov     esi,0FFFFFFE0h
     9f: call    ryo_h_MovW128
     a4: mov     byte ptr [rbp-70h],0
     a8: mov     rax,[rbp+10h]
     ac: mov     [rbp-68h],rax
     b0: lea     rdi,[sym2]
     b7: lea     rsi,[site3]
     be: mov     edx,0FFFFFFA0h
     c3: call    ryo_h_CallExt
     c8: test    rax,rax
     cb: je      0D8h
     cd: call    rax
     cf: nop     [rcx-10h]
     d6: jmp     0E8h
     d8: mov     rdi,rbp
     db: lea     rsi,[ro+4]
     e2: call    qword ptr [sym4]
     e8: call    ryo_h_Unreachable
     ed: ud2

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
     60: .long   91h
     64: .long   68h
     68: call    ryo_h_Unreachable
     6d: ud2
     6f: mov     byte ptr [rbp-22h],0
     73: mov     rax,[rbp+10h]
     77: mov     [rbp-38h],rax
     7b: mov     rax,[rbp-38h]
     7f: mov     [rbp-70h],rax
     83: call    fn0
     88: nop     [rcx-18h]
     8f: jmp     0D0h
     91: mov     edi,0FFFFFFC0h
     96: mov     esi,18h
     9b: call    ryo_h_MovW128
     a0: mov     byte ptr [rbp-21h],0
     a4: mov     edi,0FFFFFFB0h
     a9: mov     esi,0FFFFFFC0h
     ae: call    ryo_h_MovW128
     b3: mov     edi,0FFFFFF90h
     b8: mov     esi,0FFFFFFB0h
     bd: call    ryo_h_MovW128
     c2: call    fn1
     c7: nop     [rcx-18h]
     ce: jmp     0D0h
     d0: mov     edi,0FFFFFFE8h
     d5: mov     esi,18h
     da: call    ryo_h_Ret
     df: leave
     e0: ret
     e1: nop     [rax+rax]
     ea: nop     [rax+rax]
     f0: test    byte ptr [rbp-22h],0FFh
     f4: jne     128h
     f6: nop     [rax+rax]
     ff: nop
    100: mov     edi,0FFFFFFD0h
    105: call    ryo_h_Resume
    10a: ud2
    10c: nop     [rax]
    110: jmp     0F0h
    112: nop     [rax+rax]
    11b: nop     [rax+rax]
    120: test    byte ptr [rbp-21h],0FFh
    124: je      0F0h
    126: jmp     110h
    128: jmp     100h
    12a: mov     rdi,rax
    12d: mov     esi,0FFFFFFD0h
    132: call    ryo_h_Lpad
    137: jmp     120h

fn std::ptr::NonNull::<T>::new_unchecked::precondition_check
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: cmp     qword ptr [rbp-20h],0
     18: sete    [rbp-11h]
     1c: test    byte ptr [rbp-11h],0FFh
     20: je      10Ah
     26: mov     edi,0FFFFFFF0h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: mov     qword ptr [rbp-8],0D2h
     3f: mov     rax,[rbp-10h]
     43: mov     [rbp-48h],rax
     47: mov     rax,[rbp-8]
     4b: mov     [rbp-40h],rax
     4f: mov     rax,[rbp-48h]
     53: mov     [rbp-38h],rax
     57: mov     rax,[rbp-38h]
     5b: mov     [rbp-30h],rax
     5f: mov     edi,0FFFFFFA0h
     64: lea     rsi,[k1]
     6b: call    ryo_h_AddrAbs
     70: mov     qword ptr [rbp-58h],0D2h
     78: mov     rax,[rbp-58h]
     7c: mov     [rbp-50h],rax
     80: mov     rax,[rbp-50h]
     84: shl     rax,1
     88: mov     [rbp-48h],rax
     8c: mov     rax,[rbp-48h]
     90: or      rax,1
     94: mov     [rbp-40h],rax
     98: mov     rax,[rbp-40h]
     9c: mov     [rbp-38h],rax
     a0: mov     rax,[rbp-30h]
     a4: mov     [rbp-28h],rax
     a8: mov     rax,[rbp-38h]
     ac: mov     [rbp-20h],rax
     b0: mov     edi,0FFFFFF70h
     b5: mov     esi,0FFFFFFD8h
     ba: call    ryo_h_MovW128
     bf: mov     byte ptr [rbp-80h],0
     c3: mov     rax,[rbp+18h]
     c7: mov     [rbp-78h],rax
     cb: lea     rdi,[sym2]
     d2: lea     rsi,[site3]
     d9: mov     edx,0FFFFFF98h
     de: call    ryo_h_CallExt
     e3: test    rax,rax
     e6: je      0F3h
     e8: call    rax
     ea: nop     [rcx-10h]
     f1: jmp     103h
     f3: mov     rdi,rbp
     f6: lea     rsi,[ro+4]
     fd: call    qword ptr [sym4]
    103: call    ryo_h_Unreachable
    108: ud2
    10a: xor     edi,edi
    10c: xor     esi,esi
    10e: call    ryo_h_Ret
    113: leave
    114: ret

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

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-20h],rax
     18: lea     rdi,[sym0]
     1f: lea     rsi,[site1]
     26: mov     edx,0FFFFFFF0h
     2b: call    ryo_h_CallExt
     30: test    rax,rax
     33: je      40h
     35: call    rax
     37: nop     [rcx-8]
     3e: jmp     50h
     40: mov     rdi,rbp
     43: lea     rsi,[ro+4]
     4a: call    qword ptr [sym2]
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret

fn std::ptr::drop_glue::<core::io::error::CustomOwner> - shim(Some(core::io::error::CustomOwner))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-20h],rax
     18: lea     rdi,[sym0]
     1f: lea     rsi,[site1]
     26: mov     edx,0FFFFFFF0h
     2b: call    ryo_h_CallExt
     30: test    rax,rax
     33: je      40h
     35: call    rax
     37: nop     [rcx-8]
     3e: jmp     50h
     40: mov     rdi,rbp
     43: lea     rsi,[ro+4]
     4a: call    qword ptr [sym2]
     50: xor     edi,edi
     52: xor     esi,esi
     54: call    ryo_h_Ret
     59: leave
     5a: ret

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
     77: mov     rax,[rbp-18h]
     7b: mov     [rbp-20h],rax
     7f: call    fn0
     84: nop     [rcx-18h]
     8b: jmp     60h

fn std::ptr::drop_glue::<core::io::error::repr::Repr> - shim(Some(core::io::error::repr::Repr))
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

fn std::ptr::drop_glue::<core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>> - shim(Some(core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     rax,[rbp-8]
     18: mov     [rbp-10h],rax
     1c: call    fn0
     21: nop     [rcx-8]
     28: xor     edi,edi
     2a: xor     esi,esi
     2c: call    ryo_h_Ret
     31: leave
     32: ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(std::string::String, usize)>> - shim(Some(hashbrown::raw::RawTable<(std::string::String, usize)>))
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

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(u64, u64)>> - shim(Some(hashbrown::raw::RawTable<(u64, u64)>))
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

fn std::ptr::drop_glue::<hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>> - shim(Some(hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>))
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

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>))
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

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize>> - shim(Some(std::collections::HashMap<std::string::String, usize>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64>> - shim(Some(std::collections::HashMap<u64, u64>))
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

fn std::ptr::drop_glue::<std::collections::hash_map::VacantEntry<'_, std::string::String, usize>> - shim(Some(std::collections::hash_map::VacantEntry<'_, std::string::String, usize>))
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

fn std::ptr::drop_glue::<std::io::Error> - shim(Some(std::io::Error))
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
     63: mov     rax,[rbp-18h]
     67: mov     [rbp-30h],rax
     6b: call    fn0
     70: nop     [rcx-18h]
     77: jmp     50h

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
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

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rax,[rbp-8]
     14: mov     [rbp-20h],rax
     18: lea     rdi,[sym0]
     1f: lea     rsi,[site1]
     26: mov     edx,0FFFFFFE8h
     2b: call    ryo_h_CallExt
     30: test    rax,rax
     33: je      40h
     35: call    rax
     37: nop     [rcx-8]
     3e: jmp     50h
     40: mov     rdi,rbp
     43: lea     rsi,[ro+4]
     4a: call    qword ptr [sym2]
     50: jmp     9Eh
     52: nop     [rax+rax]
     5b: nop     [rax+rax]
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
     80: mov     rax,[rbp+10h]
     84: mov     [rbp-18h],rax
     88: mov     rax,[rbp-18h]
     8c: mov     [rbp-20h],rax
     90: call    fn3
     95: nop     [rcx-18h]
     9c: jmp     70h
     9e: mov     rax,[rbp+10h]
     a2: mov     [rbp-18h],rax
     a6: mov     rax,[rbp-18h]
     aa: mov     [rbp-20h],rax
     ae: call    fn4
     b3: nop     [rcx-18h]
     ba: jmp     60h
     bc: nop     [rax]
     c0: lea     rdi,[sym5]
     c7: lea     rsi,[site6]
     ce: mov     edx,0FFFFFFE8h
     d3: call    ryo_h_CallExt
     d8: test    rax,rax
     db: je      0E8h
     dd: call    rax
     df: nop     [rcx-10h]
     e6: jmp     0F8h
     e8: mov     rdi,rbp
     eb: lea     rsi,[ro+20]
     f2: call    qword ptr [sym7]
     f8: call    ryo_h_Unreachable
     fd: ud2
     ff: mov     rdi,rax
    102: mov     esi,0FFFFFFF0h
    107: call    ryo_h_Lpad
    10c: jmp     80h
    111: mov     rdi,rax
    114: mov     esi,0FFFFFFF0h
    119: call    ryo_h_Lpad
    11e: jmp     0C0h

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
     2d: jmp     184h
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
     81: mov     rax,[rbp-40h]
     85: mov     [rbp-38h],rax
     89: mov     edi,0FFFFFF98h
     8e: lea     rsi,[k2]
     95: call    ryo_h_AddrAbs
     9a: mov     qword ptr [rbp-60h],0DDh
     a2: mov     rax,[rbp-60h]
     a6: mov     [rbp-58h],rax
     aa: mov     rax,[rbp-58h]
     ae: shl     rax,1
     b2: mov     [rbp-50h],rax
     b6: mov     rax,[rbp-50h]
     ba: or      rax,1
     be: mov     [rbp-48h],rax
     c2: mov     rax,[rbp-48h]
     c6: mov     [rbp-40h],rax
     ca: mov     rax,[rbp-38h]
     ce: mov     [rbp-30h],rax
     d2: mov     rax,[rbp-40h]
     d6: mov     [rbp-28h],rax
     da: mov     edi,0FFFFFF70h
     df: mov     esi,0FFFFFFD0h
     e4: call    ryo_h_MovW128
     e9: mov     byte ptr [rbp-80h],0
     ed: mov     rax,[rbp+28h]
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
    140: test    byte ptr [rbp+20h],0FFh
    144: je      15Ah
    146: jmp     155h
    148: nop     [rax+rax]
    150: jmp     50h
    155: jmp     40h
    15a: mov     rax,[rbp+10h]
    15e: mov     [rbp-28h],rax
    162: cmp     qword ptr [rbp-28h],0
    167: sete    [rbp-1Bh]
    16b: movzx   eax,byte ptr [rbp-1Bh]
    16f: xor     al,1
    172: mov     [rbp-19h],al
    175: test    byte ptr [rbp-19h],0FFh
    179: je      50h
    17f: jmp     40h
    184: test    byte ptr [rbp-1Ah],0FFh
    188: je      150h
    18a: jmp     140h
    18c: nop     [rax]
    190: lea     rdi,[sym6]
    197: lea     rsi,[site7]
    19e: mov     edx,0FFFFFF90h
    1a3: call    ryo_h_CallExt
    1a8: test    rax,rax
    1ab: je      1B8h
    1ad: call    rax
    1af: nop     [rcx-68h]
    1b6: jmp     1C8h
    1b8: mov     rdi,rbp
    1bb: lea     rsi,[ro+20]
    1c2: call    qword ptr [sym8]
    1c8: call    ryo_h_Unreachable
    1cd: ud2
    1cf: mov     rdi,rax
    1d2: mov     esi,0FFFFFFE8h
    1d7: call    ryo_h_Lpad
    1dc: jmp     190h

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
     58: cmp     qword ptr [rbp-60h],0
     5d: sete    [rbp-51h]
     61: test    byte ptr [rbp-51h],0FFh
     65: je      103h
     6b: jmp     0D8h
     6d: nop     [rax]
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
    10b: mov     rax,[rbp-60h]
    10f: mov     [rbp-48h],rax
    113: mov     rax,[rbp-48h]
    117: mov     [rbp-50h],rax
    11b: mov     rax,[rbp-50h]
    11f: mov     [rbp-40h],rax
    123: mov     rax,[rbp-40h]
    127: mov     [rbp-48h],rax
    12b: mov     rax,[rbp-48h]
    12f: mov     [rbp-38h],rax
    133: mov     rax,[rbp-38h]
    137: mov     [rbp-20h],rax
    13b: mov     byte ptr [rbp-21h],0
    13f: mov     rax,[rbp-20h]
    143: mov     [rbp-48h],rax
    147: mov     rax,[rbp-48h]
    14b: mov     [rbp-70h],rax
    14f: call    fn2
    154: nop     [rcx-40h]
    15b: jmp     70h
    160: mov     rdi,rax
    163: mov     esi,0FFFFFFD0h
    168: call    ryo_h_Lpad
    16d: jmp     0D0h

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
     14: mov     rax,[rbp-50h]
     18: mov     [rbp-48h],rax
     1c: mov     rax,[rbp-48h]
     20: movzx   eax,byte ptr [rax]
     23: mov     [rbp-39h],al
     26: mov     edi,0FFFFFFE8h
     2b: mov     esi,0FFFFFFC7h
     30: call    ryo_h_ZextW8W64
     35: cmp     qword ptr [rbp-18h],1
     3a: jne     56h
     3c: mov     rax,[rbp+10h]
     40: mov     [rbp-30h],rax
     44: mov     rax,[rbp-30h]
     48: mov     [rbp-48h],rax
     4c: mov     rax,[rbp-30h]
     50: mov     [rbp-8],rax
     54: jmp     76h
     56: mov     byte ptr [rbp-21h],0
     5a: mov     rax,[rbp+10h]
     5e: mov     [rbp-60h],rax
     62: mov     rax,[rbp+18h]
     66: mov     [rbp-58h],rax
     6a: call    fn0
     6f: nop     [rcx-8]
     76: mov     edi,0FFFFFFF8h
     7b: mov     esi,8
     80: call    ryo_h_Ret
     85: leave
     86: ret
     87: nop     [rax+rax]
     90: mov     edi,0FFFFFFC8h
     95: call    ryo_h_Resume
     9a: ud2
     9c: nop     [rax]
     a0: jmp     90h
     a2: nop     [rax+rax]
     ab: nop     [rax+rax]
     b0: test    byte ptr [rbp-21h],0FFh
     b4: je      90h
     b6: jmp     0A0h
     b8: mov     rdi,rax
     bb: mov     esi,0FFFFFFC8h
     c0: call    ryo_h_Lpad
     c5: jmp     0B0h

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init_slow::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,120h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+10h]
     13: mov     [rbp-88h],rax
     1a: mov     rax,[rbp-88h]
     21: mov     [rbp-80h],rax
     25: mov     rax,[rbp-80h]
     29: movzx   eax,byte ptr [rax]
     2c: mov     [rbp-71h],al
     2f: mov     edi,0FFFFFFE8h
     34: mov     esi,0FFFFFF8Fh
     39: call    ryo_h_ZextW8W64
     3e: mov     edi,0FFFFFFE8h
     43: xor     esi,esi
     45: mov     edx,3
     4a: call    ryo_h_SwitchDenseW64
     4f: lea     rcx,[60h]
     56: movsxd  rax,[rcx+rax*4]
     5a: add     rax,rcx
     5d: jmp     rax
     5f: int3
     60: .long   a1h
     64: .long   84h
     68: .long   77h
     6c: .long   70h
     70: call    ryo_h_Unreachable
     75: ud2
     77: mov     qword ptr [rbp-8],0
     7f: jmp     2FDh
     84: mov     rax,[rbp+10h]
     88: mov     [rbp-60h],rax
     8c: mov     rax,[rbp-60h]
     90: mov     [rbp-80h],rax
     94: mov     rax,[rbp-60h]
     98: mov     [rbp-8],rax
     9c: jmp     2FDh
     a1: mov     edi,0FFFFFF0Ch
     a6: mov     esi,18h
     ab: xor     edx,edx
     ad: xor     ecx,ecx
     af: xor     r8d,r8d
     b2: mov     r9d,1
     b8: call    ryo_h_DiscrNicheW64
     bd: mov     edi,0FFFFFF70h
     c2: mov     esi,0FFFFFF0Ch
     c7: call    ryo_h_ZextW32W64
     cc: mov     edi,0FFFFFF70h
     d1: xor     esi,esi
     d3: mov     edx,2
     d8: call    ryo_h_SwitchDenseW64
     dd: lea     rcx,[0F0h]
     e4: movsxd  rax,[rcx+rax*4]
     e8: add     rax,rcx
     eb: jmp     rax
     ed: int3
     ee: int3
     ef: int3
     f0: .long   30eh
     f4: .long   31eh
     f8: .long   70h
     fc: lea     rax,[rbp-50h]
    100: mov     [rbp-98h],rax
    107: mov     edi,0FFFFFF48h
    10c: lea     rsi,[k0]
    113: call    ryo_h_AddrAbs
    118: mov     qword ptr [rbp-0B0h],2Bh
    123: mov     rax,[rbp-0B8h]
    12a: mov     [rbp-0D8h],rax
    131: mov     rax,[rbp-0B0h]
    138: mov     [rbp-0D0h],rax
    13f: mov     rax,[rbp-0D8h]
    146: mov     [rbp-0C8h],rax
    14d: mov     rax,[rbp-0C8h]
    154: mov     [rbp-0C0h],rax
    15b: mov     edi,0FFFFFF10h
    160: lea     rsi,[k1]
    167: call    ryo_h_AddrAbs
    16c: mov     qword ptr [rbp-0E8h],2Bh
    177: mov     rax,[rbp-0E8h]
    17e: mov     [rbp-0E0h],rax
    185: mov     rax,[rbp-0E0h]
    18c: shl     rax,1
    190: mov     [rbp-0D8h],rax
    197: mov     rax,[rbp-0D8h]
    19e: or      rax,1
    1a2: mov     [rbp-0D0h],rax
    1a9: mov     rax,[rbp-0D0h]
    1b0: mov     [rbp-0C8h],rax
    1b7: mov     rax,[rbp-0C0h]
    1be: mov     [rbp-0A8h],rax
    1c5: mov     rax,[rbp-0C8h]
    1cc: mov     [rbp-0A0h],rax
    1d3: mov     rax,[rbp-98h]
    1da: mov     [rbp-120h],rax
    1e1: mov     edi,0FFFFFEE8h
    1e6: mov     esi,0FFFFFF58h
    1eb: call    ryo_h_MovW128
    1f0: call    fn2
    1f5: nop     [rcx-90h]
    1fc: jmp     272h
    1fe: lea     rax,[rbp-80h]
    202: mov     [rbp-98h],rax
    209: mov     rax,[rbp-98h]
    210: mov     [rbp-90h],rax
    217: mov     rax,[rbp-90h]
    21e: mov     [rbp-98h],rax
    225: mov     rax,[rbp-98h]
    22c: mov     [rbp-120h],rax
    233: mov     edi,0FFFFFF08h
    238: lea     rsi,[sym3]
    23f: call    ryo_h_AddrSym
    244: mov     rdi,rbp
    247: lea     rsi,[ro+4]
    24e: call    qword ptr [sym4]
    254: jmp     537h
    259: mov     rax,[rbp+10h]
    25d: mov     [rbp-120h],rax
    264: call    fn5
    269: nop     [rcx-38h]
    270: jmp     2E0h
    272: lea     rax,[rbp-90h]
    279: mov     [rbp-0F8h],rax
    280: mov     rax,[rbp-0F8h]
    287: mov     [rbp-120h],rax
    28e: call    fn6
    293: nop     [rcx-0F8h]
    29a: lea     rdi,[sym7]
    2a1: lea     rsi,[site8]
    2a8: mov     edx,0FFFFFF08h
    2ad: call    ryo_h_CallExt
    2b2: test    rax,rax
    2b5: je      2C2h
    2b7: call    rax
    2b9: nop     [rcx-50h]
    2c0: jmp     2D2h
    2c2: mov     rdi,rbp
    2c5: lea     rsi,[ro+20]
    2cc: call    qword ptr [sym9]
    2d2: call    ryo_h_Unreachable
    2d7: ud2
    2d9: nop     [rax]
    2e0: mov     rax,[rbp+10h]
    2e4: mov     [rbp-70h],rax
    2e8: mov     rax,[rbp-70h]
    2ec: mov     [rbp-88h],rax
    2f3: mov     rax,[rbp-70h]
    2f7: mov     [rbp-8],rax
    2fb: jmp     2FDh
    2fd: mov     edi,0FFFFFFF8h
    302: mov     esi,8
    307: call    ryo_h_Ret
    30c: leave
    30d: ret
    30e: mov     qword ptr [rbp-88h],0
    319: jmp     3F9h
    31e: mov     rax,[rbp+18h]
    322: mov     [rbp-98h],rax
    329: mov     qword ptr [rbp-0B0h],0
    334: mov     edi,0FFFFFF78h
    339: mov     esi,0FFFFFF68h
    33e: xor     edx,edx
    340: mov     ecx,18h
    345: call    ryo_h_LoadCopy
    34a: mov     edi,0FFFFFF68h
    34f: xor     esi,esi
    351: mov     edx,0FFFFFF50h
    356: mov     ecx,18h
    35b: call    ryo_h_StoreCopy
    360: mov     rax,[rbp-88h]
    367: mov     [rbp-90h],rax
    36e: mov     edi,0FFFFFF70h
    373: xor     esi,esi
    375: mov     edx,2
    37a: call    ryo_h_SwitchDenseW64
    37f: lea     rcx,[390h]
    386: movsxd  rax,[rcx+rax*4]
    38a: add     rax,rcx
    38d: jmp     rax
    38f: int3
    390: .long   3f9h
    394: .long   407h
    398: .long   70h
    39c: nop     [rax]
    3a0: mov     rax,[rbp+10h]
    3a4: mov     [rbp-68h],rax
    3a8: mov     rax,[rbp-68h]
    3ac: mov     [rbp-88h],rax
    3b3: mov     edi,0FFFFFF48h
    3b8: mov     esi,0FFFFFFD0h
    3bd: call    ryo_h_MovW128
    3c2: mov     edi,0FFFFFF58h
    3c7: mov     esi,0FFFFFF48h
    3cc: call    ryo_h_MovW128
    3d1: mov     edi,0FFFFFF68h
    3d6: mov     esi,0FFFFFF58h
    3db: call    ryo_h_MovW128
    3e0: mov     byte ptr [rbp-0F1h],1
    3e7: test    byte ptr [rbp-0F1h],0FFh
    3ee: je      4ECh
    3f4: jmp     4A4h
    3f9: call    fn10
    3fe: nop     [rcx-30h]
    405: jmp     418h
    407: mov     edi,0FFFFFFD0h
    40c: mov     esi,0FFFFFF80h
    411: call    ryo_h_MovW128
    416: jmp     3A0h
    418: jmp     3A0h
    41a: nop     [rax+rax]
    420: mov     byte ptr [rbp-82h],1
    427: mov     rax,[rbp+10h]
    42b: lea     rax,[rax+10h]
    42f: mov     [rbp-98h],rax
    436: mov     rax,[rbp-98h]
    43d: mov     [rbp-90h],rax
    444: mov     rax,[rbp-90h]
    44b: movzx   eax,byte ptr [rax]
    44e: mov     [rbp-81h],al
    454: mov     rax,[rbp-90h]
    45b: movzx   ecx,byte ptr [rbp-82h]
    462: mov     [rax],cl
    464: mov     edi,0FFFFFFB8h
    469: mov     esi,0FFFFFF7Fh
    46e: call    ryo_h_ZextW8W64
    473: mov     edi,0FFFFFFB8h
    478: xor     esi,esi
    47a: mov     edx,3
    47f: call    ryo_h_SwitchDenseW64
    484: lea     rcx,[494h]
    48b: movsxd  rax,[rcx+rax*4]
    48f: add     rax,rcx
    492: jmp     rax
    494: .long   259h
    498: .long   1feh
    49c: .long   fch
    4a0: .long   70h
    4a4: mov     rax,[rbp-68h]
    4a8: mov     [rbp-0A0h],rax
    4af: mov     rax,[rbp-0A0h]
    4b6: mov     [rbp-120h],rax
    4bd: mov     qword ptr [rbp-118h],8
    4c8: mov     byte ptr [rbp-110h],0
    4cf: mov     edi,0FFFFFEF8h
    4d4: lea     rsi,[k11]
    4db: call    ryo_h_AddrAbs
    4e0: call    fn12
    4e5: nop     [rcx-68h]
    4ec: mov     byte ptr [rbp-0F1h],0
    4f3: test    byte ptr [rbp-0F1h],0FFh
    4fa: je      510h
    4fc: mov     edi,0FFFFFF80h
    501: mov     esi,0FFFFFF68h
    506: call    ryo_h_MovW128
    50b: jmp     420h
    510: mov     edi,0FFFFFF80h
    515: mov     esi,0FFFFFF78h
    51a: xor     edx,edx
    51c: call    ryo_h_LoadW128
    521: mov     edi,0FFFFFF78h
    526: xor     esi,esi
    528: mov     edx,0FFFFFF68h
    52d: call    ryo_h_StoreW128
    532: jmp     420h
    537: jmp     2E0h

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

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
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

