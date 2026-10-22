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
     1a: mov     rsi,[rbp+20h]
     1e: mov     [rbp-30h],rsi
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
     41: mov     rdx,[rbp+10h]
     45: mov     rdx,[rdx+38h]
     49: mov     [rbp-40h],rdx
     4d: or      rax,rdx
     50: mov     [rbp-30h],rax
     54: mov     rsi,[rbp-10h]
     58: xor     rsi,rax
     5b: mov     [rbp-10h],rsi
     5f: lea     rdi,[rbp-28h]
     63: mov     [rbp-38h],rdi
     67: mov     [rbp-60h],rdi
     6b: call    fn0
     70: nop     [rcx-8]
     77: mov     rax,[rbp-28h]
     7b: xor     rax,[rbp-30h]
     7f: mov     [rbp-28h],rax
     83: mov     rdx,[rbp-20h]
     87: xor     rdx,0FFh
     8e: mov     [rbp-20h],rdx
     92: lea     rsi,[rbp-28h]
     96: mov     [rbp-38h],rsi
     9a: mov     [rbp-60h],rsi
     9e: call    fn1
     a3: nop     [rcx-8]
     aa: mov     rax,[rbp-28h]
     ae: mov     [rbp-48h],rax
     b2: mov     rdx,[rbp-18h]
     b6: mov     [rbp-50h],rdx
     ba: xor     rax,rdx
     bd: mov     [rbp-40h],rax
     c1: mov     rsi,[rbp-20h]
     c5: mov     [rbp-48h],rsi
     c9: xor     rax,rsi
     cc: mov     [rbp-38h],rax
     d0: mov     rdi,[rbp-10h]
     d4: mov     [rbp-40h],rdi
     d8: xor     rax,rdi
     db: mov     [rbp-8],rax
     df: mov     edi,0FFFFFFF8h
     e4: mov     esi,8
     e9: call    ryo_h_Ret
     ee: leave
     ef: ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+20h]
      f: mov     [rbp-18h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+30h]
     1b: mov     [rbp-68h],rdx
     1f: add     rdx,rax
     22: mov     [rbp-70h],rdx
     26: mov     rsi,[rbp+10h]
     2a: mov     rcx,[rbp-70h]
     2e: mov     [rsi+30h],rcx
     32: mov     qword ptr [rbp-8],0
     3a: mov     r8,[rbp+10h]
     3e: mov     r8,[r8+40h]
     42: mov     [rbp-20h],r8
     46: cmp     r8,0
     4a: je      1AEh
     50: mov     r10,[rbp+10h]
     54: mov     r10,[r10+40h]
     58: mov     [rbp-20h],r10
     5c: mov     qword ptr [rbp-68h],8
     64: mov     rax,[rbp-68h]
     68: sub     rax,r10
     6b: mov     [rbp-8],rax
     6f: mov     [rbp-38h],rax
     73: mov     rdx,[rbp-18h]
     77: mov     [rbp-0A0h],rdx
     7e: mov     [rbp-98h],rax
     85: call    fn0
     8a: nop     [rcx-30h]
     91: jmp     2C3h
     96: nop     [rax+rax]
     9f: nop
     a0: mov     rax,[rbp+10h]
     a4: mov     rax,[rax+40h]
     a8: mov     [rbp-38h],rax
     ac: mov     qword ptr [rbp-68h],8
     b4: mov     rsi,[rbp-68h]
     b8: imul    rsi,rax
     bc: mov     [rbp-30h],rsi
     c0: mov     edi,0FFFFFFE0h
     c5: mov     esi,0FFFFFFD8h
     ca: mov     edx,0FFFFFFD0h
     cf: call    ryo_h_ShlW64
     d4: mov     rax,[rbp+10h]
     d8: mov     rax,[rax+38h]
     dc: mov     [rbp-68h],rax
     e0: or      rax,[rbp-20h]
     e4: mov     [rbp-70h],rax
     e8: mov     rdx,[rbp+10h]
     ec: mov     rcx,[rbp-70h]
     f0: mov     [rdx+38h],rcx
     f4: mov     rsi,[rbp-8]
     f8: mov     [rbp-28h],rsi
     fc: mov     rdi,[rbp-18h]
    100: cmp     rdi,rsi
    103: jae     129h
    105: mov     r8,[rbp+10h]
    109: mov     r8,[r8+40h]
    10d: mov     [rbp-68h],r8
    111: add     r8,rdi
    114: mov     [rbp-70h],r8
    118: mov     r9,[rbp+10h]
    11c: mov     rcx,[rbp-70h]
    120: mov     [r9+40h],rcx
    124: jmp     2B8h
    129: mov     rax,[rbp+10h]
    12d: mov     rax,[rax+38h]
    131: mov     [rbp-28h],rax
    135: mov     rdx,[rbp+10h]
    139: mov     rdx,[rdx+18h]
    13d: mov     [rbp-68h],rdx
    141: xor     rdx,rax
    144: mov     [rbp-70h],rdx
    148: mov     rsi,[rbp+10h]
    14c: mov     rcx,[rbp-70h]
    150: mov     [rsi+18h],rcx
    154: mov     rdi,[rbp+10h]
    158: mov     [rbp-28h],rdi
    15c: mov     [rbp-0A0h],rdi
    163: call    fn1
    168: nop     [rcx-8]
    16f: mov     rax,[rbp+10h]
    173: mov     rax,[rax+38h]
    177: mov     [rbp-28h],rax
    17b: mov     rdx,[rbp+10h]
    17f: mov     rdx,[rdx]
    182: mov     [rbp-68h],rdx
    186: xor     rdx,rax
    189: mov     [rbp-70h],rdx
    18d: mov     rsi,[rbp+10h]
    191: mov     rcx,[rbp-70h]
    195: mov     [rsi],rcx
    198: mov     qword ptr [rbp-70h],0
    1a0: mov     r8,[rbp+10h]
    1a4: mov     rcx,[rbp-70h]
    1a8: mov     [r8+40h],rcx
    1ac: jmp     1AEh
    1ae: mov     rax,[rbp-8]
    1b2: mov     [rbp-28h],rax
    1b6: mov     rdx,[rbp-18h]
    1ba: sub     rdx,rax
    1bd: mov     [rbp-20h],rdx
    1c1: and     rdx,7
    1c5: mov     [rbp-28h],rdx
    1c9: nop     [rax]
    1d0: mov     rax,[rbp-8]
    1d4: mov     [rbp-38h],rax
    1d8: mov     rdx,[rbp-20h]
    1dc: sub     rdx,[rbp-28h]
    1e0: mov     [rbp-40h],rdx
    1e4: cmp     rax,rdx
    1e7: jae     26Fh
    1ed: mov     qword ptr [rbp-38h],0
    1f5: mov     rdi,[rbp+18h]
    1f9: mov     [rbp-58h],rdi
    1fd: mov     r8,[rbp+20h]
    201: mov     [rbp-50h],r8
    205: mov     [rbp-48h],rdi
    209: mov     r9,[rbp-8]
    20d: mov     [rbp-50h],r9
    211: imul    rcx,r9,1
    215: add     rdi,rcx
    218: mov     [rbp-40h],rdi
    21c: lea     r10,[rbp-38h]
    220: mov     [rbp-50h],r10
    224: mov     [rbp-48h],r10
    228: mov     byte ptr [rbp-61h],1
    22c: test    byte ptr [rbp-61h],0FFh
    230: je      352h
    236: jmp     2F9h
    23b: nop     [rax+rax]
    240: mov     rax,[rbp+10h]
    244: mov     rax,[rax]
    247: mov     [rbp-68h],rax
    24b: xor     rax,[rbp-10h]
    24f: mov     [rbp-70h],rax
    253: mov     rdx,[rbp+10h]
    257: mov     rcx,[rbp-70h]
    25b: mov     [rdx],rcx
    25e: mov     rsi,[rbp-8]
    262: add     rsi,8
    266: mov     [rbp-8],rsi
    26a: jmp     1D0h
    26f: mov     edi,0FFFFFF60h
    274: mov     esi,18h
    279: call    ryo_h_MovW128
    27e: mov     rax,[rbp-8]
    282: mov     [rbp-90h],rax
    289: mov     rdx,[rbp-28h]
    28d: mov     [rbp-88h],rdx
    294: call    fn2
    299: nop     [rcx-30h]
    2a0: mov     rax,[rbp+10h]
    2a4: mov     rcx,[rbp-30h]
    2a8: mov     [rax+38h],rcx
    2ac: mov     rdx,[rbp+10h]
    2b0: mov     rcx,[rbp-28h]
    2b4: mov     [rdx+40h],rcx
    2b8: xor     edi,edi
    2ba: xor     esi,esi
    2bc: call    ryo_h_Ret
    2c1: leave
    2c2: ret
    2c3: mov     edi,0FFFFFF60h
    2c8: mov     esi,18h
    2cd: call    ryo_h_MovW128
    2d2: mov     qword ptr [rbp-90h],0
    2dd: mov     rdx,[rbp-30h]
    2e1: mov     [rbp-88h],rdx
    2e8: call    fn3
    2ed: nop     [rcx-28h]
    2f4: jmp     0A0h
    2f9: mov     rax,[rbp-40h]
    2fd: mov     [rbp-58h],rax
    301: mov     rdx,[rbp-50h]
    305: mov     [rbp-60h],rdx
    309: mov     [rbp-0A0h],rax
    310: mov     [rbp-98h],rdx
    317: mov     qword ptr [rbp-90h],1
    322: mov     qword ptr [rbp-88h],1
    32d: mov     qword ptr [rbp-80h],8
    335: mov     edi,0FFFFFF88h
    33a: lea     rsi,[k4]
    341: call    ryo_h_AddrAbs
    346: call    fn5
    34b: nop     [rcx-10h]
    352: mov     qword ptr [rbp-68h],8
    35a: imul    rdx,[rbp-68h],1
    35f: mov     [rbp-70h],rdx
    363: mov     edi,0FFFFFFB8h
    368: mov     esi,0FFFFFFC0h
    36d: mov     edx,0FFFFFF90h
    372: call    ryo_h_Memcpy
    377: mov     rax,[rbp-38h]
    37b: mov     [rbp-10h],rax
    37f: mov     rdx,[rbp+10h]
    383: mov     rdx,[rdx+18h]
    387: mov     [rbp-68h],rdx
    38b: xor     rdx,rax
    38e: mov     [rbp-70h],rdx
    392: mov     rsi,[rbp+10h]
    396: mov     rcx,[rbp-70h]
    39a: mov     [rsi+18h],rcx
    39e: mov     rdi,[rbp+10h]
    3a2: mov     [rbp-38h],rdi
    3a6: mov     [rbp-0A0h],rdi
    3ad: call    fn6
    3b2: nop     [rcx-10h]
    3b9: jmp     240h

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
     3e: lea     rdx,[rbp-19h]
     42: mov     [rbp-18h],rdx
     46: mov     [rbp-10h],rdx
     4a: mov     qword ptr [rbp-8],1
     52: mov     rdi,[rbp+10h]
     56: mov     [rbp-40h],rdi
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
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+10h]
     1b: mov     [rbp-18h],rdx
     1f: add     rax,rdx
     22: mov     [rbp-8],rax
     26: mov     rsi,[rbp+10h]
     2a: mov     rcx,[rbp-8]
     2e: mov     [rsi],rcx
     31: mov     rdi,[rbp+10h]
     35: mov     rdi,[rdi+8]
     39: mov     [rbp-10h],rdi
     3d: mov     r8,[rbp+10h]
     41: mov     r8,[r8+18h]
     45: mov     [rbp-18h],r8
     49: add     rdi,r8
     4c: mov     [rbp-8],rdi
     50: mov     r9,[rbp+10h]
     54: mov     rcx,[rbp-8]
     58: mov     [r9+8],rcx
     5c: mov     r10,[rbp+10h]
     60: mov     r10,[r10+10h]
     64: mov     [rbp-10h],r10
     68: mov     dword ptr [rbp-1Ch],0Dh
     6f: mov     edi,0FFFFFFF8h
     74: mov     esi,0FFFFFFF0h
     79: mov     edx,0FFFFFFE4h
     7e: call    ryo_h_RotlW64
     83: mov     rax,[rbp+10h]
     87: mov     rcx,[rbp-8]
     8b: mov     [rax+10h],rcx
     8f: mov     rdx,[rbp+10h]
     93: mov     rdx,[rdx]
     96: mov     [rbp-8],rdx
     9a: mov     rsi,[rbp+10h]
     9e: mov     rsi,[rsi+10h]
     a2: mov     [rbp-20h],rsi
     a6: xor     rsi,rdx
     a9: mov     [rbp-30h],rsi
     ad: mov     rdi,[rbp+10h]
     b1: mov     rcx,[rbp-30h]
     b5: mov     [rdi+10h],rcx
     b9: mov     r8,[rbp+10h]
     bd: mov     r8,[r8+18h]
     c1: mov     [rbp-10h],r8
     c5: mov     dword ptr [rbp-1Ch],10h
     cc: mov     edi,0FFFFFFF8h
     d1: mov     esi,0FFFFFFF0h
     d6: mov     edx,0FFFFFFE4h
     db: call    ryo_h_RotlW64
     e0: mov     rax,[rbp+10h]
     e4: mov     rcx,[rbp-8]
     e8: mov     [rax+18h],rcx
     ec: mov     rdx,[rbp+10h]
     f0: mov     rdx,[rdx+8]
     f4: mov     [rbp-8],rdx
     f8: mov     rsi,[rbp+10h]
     fc: mov     rsi,[rsi+18h]
    100: mov     [rbp-20h],rsi
    104: xor     rsi,rdx
    107: mov     [rbp-30h],rsi
    10b: mov     rdi,[rbp+10h]
    10f: mov     rcx,[rbp-30h]
    113: mov     [rdi+18h],rcx
    117: mov     r8,[rbp+10h]
    11b: mov     r8,[r8]
    11e: mov     [rbp-10h],r8
    122: mov     dword ptr [rbp-1Ch],20h
    129: mov     edi,0FFFFFFF8h
    12e: mov     esi,0FFFFFFF0h
    133: mov     edx,0FFFFFFE4h
    138: call    ryo_h_RotlW64
    13d: mov     rax,[rbp+10h]
    141: mov     rcx,[rbp-8]
    145: mov     [rax],rcx
    148: mov     rdx,[rbp+10h]
    14c: mov     rdx,[rdx+8]
    150: mov     [rbp-10h],rdx
    154: mov     rsi,[rbp+10h]
    158: mov     rsi,[rsi+10h]
    15c: mov     [rbp-18h],rsi
    160: add     rdx,rsi
    163: mov     [rbp-8],rdx
    167: mov     rdi,[rbp+10h]
    16b: mov     rcx,[rbp-8]
    16f: mov     [rdi+8],rcx
    173: mov     r8,[rbp+10h]
    177: mov     r8,[r8]
    17a: mov     [rbp-10h],r8
    17e: mov     r9,[rbp+10h]
    182: mov     r9,[r9+18h]
    186: mov     [rbp-18h],r9
    18a: add     r8,r9
    18d: mov     [rbp-8],r8
    191: mov     r10,[rbp+10h]
    195: mov     rcx,[rbp-8]
    199: mov     [r10],rcx
    19c: mov     r11,[rbp+10h]
    1a0: mov     r11,[r11+10h]
    1a4: mov     [rbp-10h],r11
    1a8: mov     dword ptr [rbp-1Ch],11h
    1af: mov     edi,0FFFFFFF8h
    1b4: mov     esi,0FFFFFFF0h
    1b9: mov     edx,0FFFFFFE4h
    1be: call    ryo_h_RotlW64
    1c3: mov     rax,[rbp+10h]
    1c7: mov     rcx,[rbp-8]
    1cb: mov     [rax+10h],rcx
    1cf: mov     rdx,[rbp+10h]
    1d3: mov     rdx,[rdx+8]
    1d7: mov     [rbp-8],rdx
    1db: mov     rsi,[rbp+10h]
    1df: mov     rsi,[rsi+10h]
    1e3: mov     [rbp-20h],rsi
    1e7: xor     rsi,rdx
    1ea: mov     [rbp-30h],rsi
    1ee: mov     rdi,[rbp+10h]
    1f2: mov     rcx,[rbp-30h]
    1f6: mov     [rdi+10h],rcx
    1fa: mov     r8,[rbp+10h]
    1fe: mov     r8,[r8+18h]
    202: mov     [rbp-10h],r8
    206: mov     dword ptr [rbp-1Ch],15h
    20d: mov     edi,0FFFFFFF8h
    212: mov     esi,0FFFFFFF0h
    217: mov     edx,0FFFFFFE4h
    21c: call    ryo_h_RotlW64
    221: mov     rax,[rbp+10h]
    225: mov     rcx,[rbp-8]
    229: mov     [rax+18h],rcx
    22d: mov     rdx,[rbp+10h]
    231: mov     rdx,[rdx]
    234: mov     [rbp-8],rdx
    238: mov     rsi,[rbp+10h]
    23c: mov     rsi,[rsi+18h]
    240: mov     [rbp-20h],rsi
    244: xor     rsi,rdx
    247: mov     [rbp-30h],rsi
    24b: mov     rdi,[rbp+10h]
    24f: mov     rcx,[rbp-30h]
    253: mov     [rdi+18h],rcx
    257: mov     r8,[rbp+10h]
    25b: mov     r8,[r8+8]
    25f: mov     [rbp-10h],r8
    263: mov     dword ptr [rbp-1Ch],20h
    26a: mov     edi,0FFFFFFF8h
    26f: mov     esi,0FFFFFFF0h
    274: mov     edx,0FFFFFFE4h
    279: call    ryo_h_RotlW64
    27e: mov     rax,[rbp+10h]
    282: mov     rcx,[rbp-8]
    286: mov     [rax+8],rcx
    28a: xor     edi,edi
    28c: xor     esi,esi
    28e: call    ryo_h_Ret
    293: leave
    294: ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+10h]
     1b: mov     [rbp-18h],rdx
     1f: add     rax,rdx
     22: mov     [rbp-8],rax
     26: mov     rsi,[rbp+10h]
     2a: mov     rcx,[rbp-8]
     2e: mov     [rsi],rcx
     31: mov     rdi,[rbp+10h]
     35: mov     rdi,[rdi+8]
     39: mov     [rbp-10h],rdi
     3d: mov     r8,[rbp+10h]
     41: mov     r8,[r8+18h]
     45: mov     [rbp-18h],r8
     49: add     rdi,r8
     4c: mov     [rbp-8],rdi
     50: mov     r9,[rbp+10h]
     54: mov     rcx,[rbp-8]
     58: mov     [r9+8],rcx
     5c: mov     r10,[rbp+10h]
     60: mov     r10,[r10+10h]
     64: mov     [rbp-10h],r10
     68: mov     dword ptr [rbp-1Ch],0Dh
     6f: mov     edi,0FFFFFFF8h
     74: mov     esi,0FFFFFFF0h
     79: mov     edx,0FFFFFFE4h
     7e: call    ryo_h_RotlW64
     83: mov     rax,[rbp+10h]
     87: mov     rcx,[rbp-8]
     8b: mov     [rax+10h],rcx
     8f: mov     rdx,[rbp+10h]
     93: mov     rdx,[rdx]
     96: mov     [rbp-8],rdx
     9a: mov     rsi,[rbp+10h]
     9e: mov     rsi,[rsi+10h]
     a2: mov     [rbp-20h],rsi
     a6: xor     rsi,rdx
     a9: mov     [rbp-30h],rsi
     ad: mov     rdi,[rbp+10h]
     b1: mov     rcx,[rbp-30h]
     b5: mov     [rdi+10h],rcx
     b9: mov     r8,[rbp+10h]
     bd: mov     r8,[r8+18h]
     c1: mov     [rbp-10h],r8
     c5: mov     dword ptr [rbp-1Ch],10h
     cc: mov     edi,0FFFFFFF8h
     d1: mov     esi,0FFFFFFF0h
     d6: mov     edx,0FFFFFFE4h
     db: call    ryo_h_RotlW64
     e0: mov     rax,[rbp+10h]
     e4: mov     rcx,[rbp-8]
     e8: mov     [rax+18h],rcx
     ec: mov     rdx,[rbp+10h]
     f0: mov     rdx,[rdx+8]
     f4: mov     [rbp-8],rdx
     f8: mov     rsi,[rbp+10h]
     fc: mov     rsi,[rsi+18h]
    100: mov     [rbp-20h],rsi
    104: xor     rsi,rdx
    107: mov     [rbp-30h],rsi
    10b: mov     rdi,[rbp+10h]
    10f: mov     rcx,[rbp-30h]
    113: mov     [rdi+18h],rcx
    117: mov     r8,[rbp+10h]
    11b: mov     r8,[r8]
    11e: mov     [rbp-10h],r8
    122: mov     dword ptr [rbp-1Ch],20h
    129: mov     edi,0FFFFFFF8h
    12e: mov     esi,0FFFFFFF0h
    133: mov     edx,0FFFFFFE4h
    138: call    ryo_h_RotlW64
    13d: mov     rax,[rbp+10h]
    141: mov     rcx,[rbp-8]
    145: mov     [rax],rcx
    148: mov     rdx,[rbp+10h]
    14c: mov     rdx,[rdx+8]
    150: mov     [rbp-10h],rdx
    154: mov     rsi,[rbp+10h]
    158: mov     rsi,[rsi+10h]
    15c: mov     [rbp-18h],rsi
    160: add     rdx,rsi
    163: mov     [rbp-8],rdx
    167: mov     rdi,[rbp+10h]
    16b: mov     rcx,[rbp-8]
    16f: mov     [rdi+8],rcx
    173: mov     r8,[rbp+10h]
    177: mov     r8,[r8]
    17a: mov     [rbp-10h],r8
    17e: mov     r9,[rbp+10h]
    182: mov     r9,[r9+18h]
    186: mov     [rbp-18h],r9
    18a: add     r8,r9
    18d: mov     [rbp-8],r8
    191: mov     r10,[rbp+10h]
    195: mov     rcx,[rbp-8]
    199: mov     [r10],rcx
    19c: mov     r11,[rbp+10h]
    1a0: mov     r11,[r11+10h]
    1a4: mov     [rbp-10h],r11
    1a8: mov     dword ptr [rbp-1Ch],11h
    1af: mov     edi,0FFFFFFF8h
    1b4: mov     esi,0FFFFFFF0h
    1b9: mov     edx,0FFFFFFE4h
    1be: call    ryo_h_RotlW64
    1c3: mov     rax,[rbp+10h]
    1c7: mov     rcx,[rbp-8]
    1cb: mov     [rax+10h],rcx
    1cf: mov     rdx,[rbp+10h]
    1d3: mov     rdx,[rdx+8]
    1d7: mov     [rbp-8],rdx
    1db: mov     rsi,[rbp+10h]
    1df: mov     rsi,[rsi+10h]
    1e3: mov     [rbp-20h],rsi
    1e7: xor     rsi,rdx
    1ea: mov     [rbp-30h],rsi
    1ee: mov     rdi,[rbp+10h]
    1f2: mov     rcx,[rbp-30h]
    1f6: mov     [rdi+10h],rcx
    1fa: mov     r8,[rbp+10h]
    1fe: mov     r8,[r8+18h]
    202: mov     [rbp-10h],r8
    206: mov     dword ptr [rbp-1Ch],15h
    20d: mov     edi,0FFFFFFF8h
    212: mov     esi,0FFFFFFF0h
    217: mov     edx,0FFFFFFE4h
    21c: call    ryo_h_RotlW64
    221: mov     rax,[rbp+10h]
    225: mov     rcx,[rbp-8]
    229: mov     [rax+18h],rcx
    22d: mov     rdx,[rbp+10h]
    231: mov     rdx,[rdx]
    234: mov     [rbp-8],rdx
    238: mov     rsi,[rbp+10h]
    23c: mov     rsi,[rsi+18h]
    240: mov     [rbp-20h],rsi
    244: xor     rsi,rdx
    247: mov     [rbp-30h],rsi
    24b: mov     rdi,[rbp+10h]
    24f: mov     rcx,[rbp-30h]
    253: mov     [rdi+18h],rcx
    257: mov     r8,[rbp+10h]
    25b: mov     r8,[r8+8]
    25f: mov     [rbp-10h],r8
    263: mov     dword ptr [rbp-1Ch],20h
    26a: mov     edi,0FFFFFFF8h
    26f: mov     esi,0FFFFFFF0h
    274: mov     edx,0FFFFFFE4h
    279: call    ryo_h_RotlW64
    27e: mov     rax,[rbp+10h]
    282: mov     rcx,[rbp-8]
    286: mov     [rax+8],rcx
    28a: mov     rdx,[rbp+10h]
    28e: mov     rdx,[rdx]
    291: mov     [rbp-10h],rdx
    295: mov     rsi,[rbp+10h]
    299: mov     rsi,[rsi+10h]
    29d: mov     [rbp-18h],rsi
    2a1: add     rdx,rsi
    2a4: mov     [rbp-8],rdx
    2a8: mov     rdi,[rbp+10h]
    2ac: mov     rcx,[rbp-8]
    2b0: mov     [rdi],rcx
    2b3: mov     r8,[rbp+10h]
    2b7: mov     r8,[r8+8]
    2bb: mov     [rbp-10h],r8
    2bf: mov     r9,[rbp+10h]
    2c3: mov     r9,[r9+18h]
    2c7: mov     [rbp-18h],r9
    2cb: add     r8,r9
    2ce: mov     [rbp-8],r8
    2d2: mov     r10,[rbp+10h]
    2d6: mov     rcx,[rbp-8]
    2da: mov     [r10+8],rcx
    2de: mov     r11,[rbp+10h]
    2e2: mov     r11,[r11+10h]
    2e6: mov     [rbp-10h],r11
    2ea: mov     dword ptr [rbp-1Ch],0Dh
    2f1: mov     edi,0FFFFFFF8h
    2f6: mov     esi,0FFFFFFF0h
    2fb: mov     edx,0FFFFFFE4h
    300: call    ryo_h_RotlW64
    305: mov     rax,[rbp+10h]
    309: mov     rcx,[rbp-8]
    30d: mov     [rax+10h],rcx
    311: mov     rdx,[rbp+10h]
    315: mov     rdx,[rdx]
    318: mov     [rbp-8],rdx
    31c: mov     rsi,[rbp+10h]
    320: mov     rsi,[rsi+10h]
    324: mov     [rbp-20h],rsi
    328: xor     rsi,rdx
    32b: mov     [rbp-30h],rsi
    32f: mov     rdi,[rbp+10h]
    333: mov     rcx,[rbp-30h]
    337: mov     [rdi+10h],rcx
    33b: mov     r8,[rbp+10h]
    33f: mov     r8,[r8+18h]
    343: mov     [rbp-10h],r8
    347: mov     dword ptr [rbp-1Ch],10h
    34e: mov     edi,0FFFFFFF8h
    353: mov     esi,0FFFFFFF0h
    358: mov     edx,0FFFFFFE4h
    35d: call    ryo_h_RotlW64
    362: mov     rax,[rbp+10h]
    366: mov     rcx,[rbp-8]
    36a: mov     [rax+18h],rcx
    36e: mov     rdx,[rbp+10h]
    372: mov     rdx,[rdx+8]
    376: mov     [rbp-8],rdx
    37a: mov     rsi,[rbp+10h]
    37e: mov     rsi,[rsi+18h]
    382: mov     [rbp-20h],rsi
    386: xor     rsi,rdx
    389: mov     [rbp-30h],rsi
    38d: mov     rdi,[rbp+10h]
    391: mov     rcx,[rbp-30h]
    395: mov     [rdi+18h],rcx
    399: mov     r8,[rbp+10h]
    39d: mov     r8,[r8]
    3a0: mov     [rbp-10h],r8
    3a4: mov     dword ptr [rbp-1Ch],20h
    3ab: mov     edi,0FFFFFFF8h
    3b0: mov     esi,0FFFFFFF0h
    3b5: mov     edx,0FFFFFFE4h
    3ba: call    ryo_h_RotlW64
    3bf: mov     rax,[rbp+10h]
    3c3: mov     rcx,[rbp-8]
    3c7: mov     [rax],rcx
    3ca: mov     rdx,[rbp+10h]
    3ce: mov     rdx,[rdx+8]
    3d2: mov     [rbp-10h],rdx
    3d6: mov     rsi,[rbp+10h]
    3da: mov     rsi,[rsi+10h]
    3de: mov     [rbp-18h],rsi
    3e2: add     rdx,rsi
    3e5: mov     [rbp-8],rdx
    3e9: mov     rdi,[rbp+10h]
    3ed: mov     rcx,[rbp-8]
    3f1: mov     [rdi+8],rcx
    3f5: mov     r8,[rbp+10h]
    3f9: mov     r8,[r8]
    3fc: mov     [rbp-10h],r8
    400: mov     r9,[rbp+10h]
    404: mov     r9,[r9+18h]
    408: mov     [rbp-18h],r9
    40c: add     r8,r9
    40f: mov     [rbp-8],r8
    413: mov     r10,[rbp+10h]
    417: mov     rcx,[rbp-8]
    41b: mov     [r10],rcx
    41e: mov     r11,[rbp+10h]
    422: mov     r11,[r11+10h]
    426: mov     [rbp-10h],r11
    42a: mov     dword ptr [rbp-1Ch],11h
    431: mov     edi,0FFFFFFF8h
    436: mov     esi,0FFFFFFF0h
    43b: mov     edx,0FFFFFFE4h
    440: call    ryo_h_RotlW64
    445: mov     rax,[rbp+10h]
    449: mov     rcx,[rbp-8]
    44d: mov     [rax+10h],rcx
    451: mov     rdx,[rbp+10h]
    455: mov     rdx,[rdx+8]
    459: mov     [rbp-8],rdx
    45d: mov     rsi,[rbp+10h]
    461: mov     rsi,[rsi+10h]
    465: mov     [rbp-20h],rsi
    469: xor     rsi,rdx
    46c: mov     [rbp-30h],rsi
    470: mov     rdi,[rbp+10h]
    474: mov     rcx,[rbp-30h]
    478: mov     [rdi+10h],rcx
    47c: mov     r8,[rbp+10h]
    480: mov     r8,[r8+18h]
    484: mov     [rbp-10h],r8
    488: mov     dword ptr [rbp-1Ch],15h
    48f: mov     edi,0FFFFFFF8h
    494: mov     esi,0FFFFFFF0h
    499: mov     edx,0FFFFFFE4h
    49e: call    ryo_h_RotlW64
    4a3: mov     rax,[rbp+10h]
    4a7: mov     rcx,[rbp-8]
    4ab: mov     [rax+18h],rcx
    4af: mov     rdx,[rbp+10h]
    4b3: mov     rdx,[rdx]
    4b6: mov     [rbp-8],rdx
    4ba: mov     rsi,[rbp+10h]
    4be: mov     rsi,[rsi+18h]
    4c2: mov     [rbp-20h],rsi
    4c6: xor     rsi,rdx
    4c9: mov     [rbp-30h],rsi
    4cd: mov     rdi,[rbp+10h]
    4d1: mov     rcx,[rbp-30h]
    4d5: mov     [rdi+18h],rcx
    4d9: mov     r8,[rbp+10h]
    4dd: mov     r8,[r8+8]
    4e1: mov     [rbp-10h],r8
    4e5: mov     dword ptr [rbp-1Ch],20h
    4ec: mov     edi,0FFFFFFF8h
    4f1: mov     esi,0FFFFFFF0h
    4f6: mov     edx,0FFFFFFE4h
    4fb: call    ryo_h_RotlW64
    500: mov     rax,[rbp+10h]
    504: mov     rcx,[rbp-8]
    508: mov     [rax+8],rcx
    50c: mov     rdx,[rbp+10h]
    510: mov     rdx,[rdx]
    513: mov     [rbp-10h],rdx
    517: mov     rsi,[rbp+10h]
    51b: mov     rsi,[rsi+10h]
    51f: mov     [rbp-18h],rsi
    523: add     rdx,rsi
    526: mov     [rbp-8],rdx
    52a: mov     rdi,[rbp+10h]
    52e: mov     rcx,[rbp-8]
    532: mov     [rdi],rcx
    535: mov     r8,[rbp+10h]
    539: mov     r8,[r8+8]
    53d: mov     [rbp-10h],r8
    541: mov     r9,[rbp+10h]
    545: mov     r9,[r9+18h]
    549: mov     [rbp-18h],r9
    54d: add     r8,r9
    550: mov     [rbp-8],r8
    554: mov     r10,[rbp+10h]
    558: mov     rcx,[rbp-8]
    55c: mov     [r10+8],rcx
    560: mov     r11,[rbp+10h]
    564: mov     r11,[r11+10h]
    568: mov     [rbp-10h],r11
    56c: mov     dword ptr [rbp-1Ch],0Dh
    573: mov     edi,0FFFFFFF8h
    578: mov     esi,0FFFFFFF0h
    57d: mov     edx,0FFFFFFE4h
    582: call    ryo_h_RotlW64
    587: mov     rax,[rbp+10h]
    58b: mov     rcx,[rbp-8]
    58f: mov     [rax+10h],rcx
    593: mov     rdx,[rbp+10h]
    597: mov     rdx,[rdx]
    59a: mov     [rbp-8],rdx
    59e: mov     rsi,[rbp+10h]
    5a2: mov     rsi,[rsi+10h]
    5a6: mov     [rbp-20h],rsi
    5aa: xor     rsi,rdx
    5ad: mov     [rbp-30h],rsi
    5b1: mov     rdi,[rbp+10h]
    5b5: mov     rcx,[rbp-30h]
    5b9: mov     [rdi+10h],rcx
    5bd: mov     r8,[rbp+10h]
    5c1: mov     r8,[r8+18h]
    5c5: mov     [rbp-10h],r8
    5c9: mov     dword ptr [rbp-1Ch],10h
    5d0: mov     edi,0FFFFFFF8h
    5d5: mov     esi,0FFFFFFF0h
    5da: mov     edx,0FFFFFFE4h
    5df: call    ryo_h_RotlW64
    5e4: mov     rax,[rbp+10h]
    5e8: mov     rcx,[rbp-8]
    5ec: mov     [rax+18h],rcx
    5f0: mov     rdx,[rbp+10h]
    5f4: mov     rdx,[rdx+8]
    5f8: mov     [rbp-8],rdx
    5fc: mov     rsi,[rbp+10h]
    600: mov     rsi,[rsi+18h]
    604: mov     [rbp-20h],rsi
    608: xor     rsi,rdx
    60b: mov     [rbp-30h],rsi
    60f: mov     rdi,[rbp+10h]
    613: mov     rcx,[rbp-30h]
    617: mov     [rdi+18h],rcx
    61b: mov     r8,[rbp+10h]
    61f: mov     r8,[r8]
    622: mov     [rbp-10h],r8
    626: mov     dword ptr [rbp-1Ch],20h
    62d: mov     edi,0FFFFFFF8h
    632: mov     esi,0FFFFFFF0h
    637: mov     edx,0FFFFFFE4h
    63c: call    ryo_h_RotlW64
    641: mov     rax,[rbp+10h]
    645: mov     rcx,[rbp-8]
    649: mov     [rax],rcx
    64c: mov     rdx,[rbp+10h]
    650: mov     rdx,[rdx+8]
    654: mov     [rbp-10h],rdx
    658: mov     rsi,[rbp+10h]
    65c: mov     rsi,[rsi+10h]
    660: mov     [rbp-18h],rsi
    664: add     rdx,rsi
    667: mov     [rbp-8],rdx
    66b: mov     rdi,[rbp+10h]
    66f: mov     rcx,[rbp-8]
    673: mov     [rdi+8],rcx
    677: mov     r8,[rbp+10h]
    67b: mov     r8,[r8]
    67e: mov     [rbp-10h],r8
    682: mov     r9,[rbp+10h]
    686: mov     r9,[r9+18h]
    68a: mov     [rbp-18h],r9
    68e: add     r8,r9
    691: mov     [rbp-8],r8
    695: mov     r10,[rbp+10h]
    699: mov     rcx,[rbp-8]
    69d: mov     [r10],rcx
    6a0: mov     r11,[rbp+10h]
    6a4: mov     r11,[r11+10h]
    6a8: mov     [rbp-10h],r11
    6ac: mov     dword ptr [rbp-1Ch],11h
    6b3: mov     edi,0FFFFFFF8h
    6b8: mov     esi,0FFFFFFF0h
    6bd: mov     edx,0FFFFFFE4h
    6c2: call    ryo_h_RotlW64
    6c7: mov     rax,[rbp+10h]
    6cb: mov     rcx,[rbp-8]
    6cf: mov     [rax+10h],rcx
    6d3: mov     rdx,[rbp+10h]
    6d7: mov     rdx,[rdx+8]
    6db: mov     [rbp-8],rdx
    6df: mov     rsi,[rbp+10h]
    6e3: mov     rsi,[rsi+10h]
    6e7: mov     [rbp-20h],rsi
    6eb: xor     rsi,rdx
    6ee: mov     [rbp-30h],rsi
    6f2: mov     rdi,[rbp+10h]
    6f6: mov     rcx,[rbp-30h]
    6fa: mov     [rdi+10h],rcx
    6fe: mov     r8,[rbp+10h]
    702: mov     r8,[r8+18h]
    706: mov     [rbp-10h],r8
    70a: mov     dword ptr [rbp-1Ch],15h
    711: mov     edi,0FFFFFFF8h
    716: mov     esi,0FFFFFFF0h
    71b: mov     edx,0FFFFFFE4h
    720: call    ryo_h_RotlW64
    725: mov     rax,[rbp+10h]
    729: mov     rcx,[rbp-8]
    72d: mov     [rax+18h],rcx
    731: mov     rdx,[rbp+10h]
    735: mov     rdx,[rdx]
    738: mov     [rbp-8],rdx
    73c: mov     rsi,[rbp+10h]
    740: mov     rsi,[rsi+18h]
    744: mov     [rbp-20h],rsi
    748: xor     rsi,rdx
    74b: mov     [rbp-30h],rsi
    74f: mov     rdi,[rbp+10h]
    753: mov     rcx,[rbp-30h]
    757: mov     [rdi+18h],rcx
    75b: mov     r8,[rbp+10h]
    75f: mov     r8,[r8+8]
    763: mov     [rbp-10h],r8
    767: mov     dword ptr [rbp-1Ch],20h
    76e: mov     edi,0FFFFFFF8h
    773: mov     esi,0FFFFFFF0h
    778: mov     edx,0FFFFFFE4h
    77d: call    ryo_h_RotlW64
    782: mov     rax,[rbp+10h]
    786: mov     rcx,[rbp-8]
    78a: mov     [rax+8],rcx
    78e: xor     edi,edi
    790: xor     esi,esi
    792: call    ryo_h_Ret
    797: leave
    798: ret

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
     12: mov     rsi,[rbp+10h]
     16: mov     [rbp-18h],rsi
     1a: mov     [rbp-30h],rsi
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
     2e: mov     esi,[rbp+18h]
     31: mov     [rbp-48h],esi
     34: mov     [rbp-80h],esi
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
     79: mov     rdx,[rbp-50h]
     7d: mov     [rbp-60h],rdx
     81: mov     edi,0FFFFFFE8h
     86: mov     esi,0FFFFFF98h
     8b: call    ryo_h_MovW128
     90: mov     rax,[rbp-18h]
     94: mov     [rbp-28h],rax
     98: mov     rdx,[rbp-10h]
     9c: mov     [rbp-20h],rdx
     a0: mov     rsi,[rbp+10h]
     a4: mov     [rbp-80h],rsi
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
     af: mov     rdx,[rbp+10h]
     b3: lea     rdx,[rdx+8]
     b7: mov     [rbp-48h],rdx
     bb: mov     [rbp-60h],rdx
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
     27: lea     rdx,[rbp+40h]
     2b: mov     [rbp-20h],rdx
     2f: mov     [rbp-18h],rdx
     33: mov     edi,0FFFFFF80h
     38: mov     esi,0FFFFFFC0h
     3d: mov     edx,20h
     42: call    ryo_h_Copy
     47: mov     rax,[rbp-48h]
     4b: mov     [rbp-60h],rax
     4f: mov     rdx,[rbp+38h]
     53: mov     [rbp-58h],rdx
     57: mov     rsi,[rbp-18h]
     5b: mov     [rbp-50h],rsi
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
     13: je      0BCh
     19: jmp     0B2h
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
     4c: mov     rdx,[rbp-30h]
     50: lea     rdx,[rdx+8]
     54: mov     [rbp-28h],rdx
     58: mov     rsi,[rbp+10h]
     5c: mov     rsi,[rsi]
     5f: mov     [rbp-18h],rsi
     63: mov     [rbp-50h],rax
     67: mov     [rbp-48h],rdx
     6b: mov     rdi,[rbp+18h]
     6f: mov     [rbp-40h],rdi
     73: mov     edi,0FFFFFFC8h
     78: mov     esi,0FFFFFFB0h
     7d: call    ryo_h_MovW128
     82: mov     rax,[rbp-18h]
     86: mov     [rbp-80h],rax
     8a: mov     rdx,[rbp-40h]
     8e: mov     [rbp-78h],rdx
     92: mov     edi,0FFFFFF90h
     97: mov     esi,0FFFFFFC8h
     9c: call    ryo_h_MovW128
     a1: call    fn0
     a6: nop     [rcx-8]
     ad: jmp     20h
     b2: mov     qword ptr [rbp-20h],8
     ba: jmp     40h
     bc: mov     rax,[rbp+20h]
     c0: mov     [rbp-38h],rax
     c4: mov     [rbp-28h],rax
     c8: mov     byte ptr [rbp-51h],0
     cc: test    byte ptr [rbp-51h],0FFh
     d0: je      0EFh
     d2: jmp     0E5h
     d4: nop     [rax+rax]
     dd: nop     [rax]
     e0: jmp     40h
     e5: mov     rax,[rbp-28h]
     e9: mov     [rbp-20h],rax
     ed: jmp     0E0h
     ef: mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
     f7: mov     rdx,[rbp-28h]
     fb: imul    rcx,[rbp-58h],10h
    100: add     rdx,rcx
    103: mov     [rbp-20h],rdx
    107: jmp     0E0h

fn <hashbrown::raw::RawTable<(std::string::String, usize)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+20h]
     18: mov     [rbp-10h],rdx
     1c: mov     [rbp-30h],rax
     20: mov     [rbp-28h],rdx
     24: mov     edi,0FFFFFFE0h
     29: lea     rsi,[k0]
     30: mov     edx,10h
     35: call    ryo_h_Const
     3a: call    fn1
     3f: nop     [rcx]
     46: xor     edi,edi
     48: xor     esi,esi
     4a: call    ryo_h_Ret
     4f: leave
     50: ret

fn <hashbrown::raw::RawTable<(u64, u64)> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+20h]
     18: mov     [rbp-10h],rdx
     1c: mov     [rbp-30h],rax
     20: mov     [rbp-28h],rdx
     24: mov     edi,0FFFFFFE0h
     29: lea     rsi,[k0]
     30: mov     edx,10h
     35: call    ryo_h_Const
     3a: call    fn1
     3f: nop     [rcx]
     46: xor     edi,edi
     48: xor     esi,esi
     4a: call    ryo_h_Ret
     4f: leave
     50: ret

fn <hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: lea     rax,[rax+8]
     10: mov     [rbp-8],rax
     14: mov     rdx,[rbp+10h]
     18: mov     [rbp-18h],rdx
     1c: mov     [rbp-10h],rdx
     20: mov     [rbp-30h],rax
     24: mov     [rbp-28h],rdx
     28: call    fn0
     2d: nop     [rcx]
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+18h]
     18: mov     [rbp-18h],rdx
     1c: mov     [rbp-10h],rdx
     20: mov     [rbp-30h],rax
     24: mov     [rbp-28h],rdx
     28: call    fn0
     2d: nop     [rcx]
     34: xor     edi,edi
     36: xor     esi,esi
     38: call    ryo_h_Ret
     3d: leave
     3e: ret

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
     16: mov     rsi,[rbp+20h]
     1a: mov     [rbp-28h],rsi
     1e: mov     rdi,[rbp+18h]
     22: mov     [rbp-50h],rdi
     26: mov     [rbp-48h],rax
     2a: mov     [rbp-40h],rsi
     2e: lea     rdi,[sym0]
     35: lea     rsi,[site1]
     3c: mov     edx,0FFFFFFD0h
     41: call    ryo_h_CallExt
     46: test    rax,rax
     49: je      56h
     4b: call    rax
     4d: nop     [rcx]
     54: jmp     66h
     56: mov     rdi,rbp
     59: lea     rsi,[ro+4]
     60: call    qword ptr [sym2]
     66: jmp     7Bh
     68: nop     [rax+rax]
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
     47: mov     rdx,[rbp-18h]
     4b: mov     [rbp-50h],rdx
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
     10: mov     rdx,[rbp+10h]
     14: mov     rdx,[rdx]
     17: mov     [rbp-10h],rdx
     1b: mov     rsi,[rbp+18h]
     1f: mov     [rbp-28h],rsi
     23: mov     [rbp-20h],rax
     27: mov     [rbp-40h],rdx
     2b: mov     [rbp-38h],rsi
     2f: mov     [rbp-30h],rax
     33: call    fn0
     38: nop     [rcx-8]
     3f: mov     edi,0FFFFFFF8h
     44: mov     esi,8
     49: call    ryo_h_Ret
     4e: leave
     4f: ret

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
     10: lea     rdx,[rbp-20h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-10h],rdx
     1c: mov     qword ptr [rbp-8],8
     24: mov     rdi,[rbp+10h]
     28: mov     [rbp-40h],rdi
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
     19: mov     rdx,[rbp+10h]
     1d: mov     rdx,[rdx+8]
     21: mov     [rbp-0A0h],rdx
     28: mov     qword ptr [rbp-150h],0
     33: mov     qword ptr [rbp-148h],0
     3e: mov     qword ptr [rbp-140h],0
     49: mov     qword ptr [rbp-138h],0
     54: mov     [rbp-110h],rax
     5b: mov     [rbp-108h],rdx
     62: mov     qword ptr [rbp-100h],0
     6d: mov     edi,0FFFFFED0h
     72: mov     esi,0FFFFFEB0h
     77: mov     edx,20h
     7c: call    ryo_h_Copy
     81: mov     qword ptr [rbp-0F8h],0
     8c: mov     qword ptr [rbp-0F0h],0
     97: lea     rsi,[rbp-130h]
     9e: mov     [rbp-138h],rsi
     a5: mov     [rbp-160h],rsi
     ac: call    fn0
     b1: nop     [rcx-48h]
     b8: mov     edi,0FFFFFF18h
     bd: mov     esi,0FFFFFED0h
     c2: mov     edx,48h
     c7: call    ryo_h_Copy
     cc: mov     edi,0FFFFFF70h
     d1: mov     esi,0FFFFFF18h
     d6: mov     edx,48h
     db: call    ryo_h_Copy
     e0: mov     edi,0FFFFFFB8h
     e5: mov     esi,0FFFFFF70h
     ea: mov     edx,48h
     ef: call    ryo_h_Copy
     f4: mov     edi,0FFFFFFB8h
     f9: mov     esi,48h
     fe: call    ryo_h_Ret
    103: leave
    104: ret

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
     27: lea     rdx,[rbp-58h]
     2b: mov     [rbp-68h],rdx
     2f: mov     [rbp-80h],rax
     33: mov     [rbp-78h],rdx
     37: call    fn1
     3c: nop     [rcx-8]
     43: lea     rax,[rbp-58h]
     47: mov     [rbp-60h],rax
     4b: mov     [rbp-80h],rax
     4f: call    fn2
     54: nop     [rcx-8]
     5b: mov     edi,0FFFFFFF8h
     60: mov     esi,8
     65: call    ryo_h_Ret
     6a: leave
     6b: ret
     6c: nop     [rax]
     70: mov     edi,0FFFFFFF0h
     75: call    ryo_h_Resume
     7a: ud2
     7c: mov     rdi,rax
     7f: mov     esi,0FFFFFFF0h
     84: call    ryo_h_Lpad
     89: jmp     70h
     8b: mov     rdi,rax
     8e: mov     esi,0FFFFFFF0h
     93: call    ryo_h_Lpad
     98: jmp     70h

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
     27: lea     rdx,[rbp-58h]
     2b: mov     [rbp-68h],rdx
     2f: mov     [rbp-80h],rax
     33: mov     [rbp-78h],rdx
     37: call    fn1
     3c: nop     [rcx-8]
     43: lea     rax,[rbp-58h]
     47: mov     [rbp-60h],rax
     4b: mov     [rbp-80h],rax
     4f: call    fn2
     54: nop     [rcx-8]
     5b: mov     edi,0FFFFFFF8h
     60: mov     esi,8
     65: call    ryo_h_Ret
     6a: leave
     6b: ret
     6c: nop     [rax]
     70: mov     edi,0FFFFFFF0h
     75: call    ryo_h_Resume
     7a: ud2
     7c: mov     rdi,rax
     7f: mov     esi,0FFFFFFF0h
     84: call    ryo_h_Lpad
     89: jmp     70h
     8b: mov     rdi,rax
     8e: mov     esi,0FFFFFFF0h
     93: call    ryo_h_Lpad
     98: jmp     70h

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
     10: mov     rdx,[rbp+10h]
     14: lea     rdx,[rdx+4]
     18: mov     [rbp-20h],rdx
     1c: mov     [rbp-30h],rax
     20: mov     [rbp-28h],rdx
     24: call    fn0
     29: nop     [rcx-9]
     30: test    byte ptr [rbp-9],0FFh
     34: je      6Eh
     36: mov     rdx,[rbp+10h]
     3a: mov     edx,[rdx]
     3c: mov     [rbp-10h],edx
     3f: mov     [rbp-30h],edx
     42: mov     qword ptr [rbp-28h],1
     4a: call    fn1
     4f: nop     [rcx-14h]
     56: mov     rax,[rbp+10h]
     5a: mov     ecx,[rbp-14h]
     5d: mov     [rax],ecx
     5f: mov     edx,[rbp-10h]
     62: mov     [rbp-4],edx
     65: mov     dword ptr [rbp-8],1
     6c: jmp     75h
     6e: mov     dword ptr [rbp-8],0
     75: mov     edi,0FFFFFFF8h
     7a: mov     esi,8
     7f: call    ryo_h_Ret
     84: leave
     85: ret

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

fn <std::string::String as std::cmp::PartialEq>::eq
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: mov     rdx,[rbp+18h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-30h],rax
     1c: mov     [rbp-28h],rdx
     20: call    fn0
     25: nop     [rcx-1]
     2c: mov     edi,0FFFFFFFFh
     31: mov     esi,1
     36: call    ryo_h_Ret
     3b: leave
     3c: ret

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax+8]
     10: mov     [rbp-40h],rax
     14: mov     [rbp-38h],rax
     18: mov     rdx,[rbp+10h]
     1c: mov     rdx,[rdx+10h]
     20: mov     [rbp-40h],rdx
     24: mov     [rbp-30h],rax
     28: mov     [rbp-28h],rdx
     2c: mov     [rbp-20h],rax
     30: mov     [rbp-18h],rdx
     34: mov     edi,0FFFFFFF0h
     39: mov     esi,0FFFFFFE0h
     3e: call    ryo_h_MovW128
     43: mov     rax,[rbp+18h]
     47: mov     [rbp-60h],rax
     4b: mov     edi,0FFFFFFA8h
     50: mov     esi,0FFFFFFF0h
     55: call    ryo_h_MovW128
     5a: call    fn0
     5f: nop     [rcx]
     66: xor     edi,edi
     68: xor     esi,esi
     6a: call    ryo_h_Ret
     6f: leave
     70: ret

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
     ec: je      12Bh
     ee: jmp     10Dh
     f0: lea     rax,[rbp-40h]
     f4: mov     [rbp-50h],rax
     f8: mov     [rbp-0C0h],rax
     ff: call    fn3
    104: nop     [rcx-32h]
    10b: jmp     13Eh
    10d: mov     rax,[rbp-40h]
    111: mov     [rbp-50h],rax
    115: mov     rdx,[rbp+20h]
    119: mov     [rbp-58h],rdx
    11d: cmp     rdx,rax
    120: jb      233h
    126: jmp     2A4h
    12b: mov     edi,0FFFFFFF8h
    130: lea     rsi,[k4]
    137: call    ryo_h_AddrAbs
    13c: jmp     165h
    13e: test    byte ptr [rbp-32h],0FFh
    142: je      146h
    144: jmp     1B0h
    146: mov     rax,[rbp-40h]
    14a: mov     [rbp-50h],rax
    14e: mov     [rbp-8],rax
    152: jmp     165h
    154: nop     [rax+rax]
    15d: nop     [rax]
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
    23e: mov     rdx,[rbp-58h]
    242: mov     [rbp-0B8h],rdx
    249: mov     rsi,[rbp-58h]
    24d: mov     [rbp-0B0h],rsi
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
    2b0: mov     rdx,[rbp+18h]
    2b4: mov     [rbp-80h],rdx
    2b8: mov     rsi,[rbp+20h]
    2bc: mov     [rbp-78h],rsi
    2c0: mov     [rbp-88h],rdx
    2c7: imul    rcx,[rbp-50h],1
    2cc: add     rdx,rcx
    2cf: mov     [rbp-90h],rdx
    2d6: mov     [rbp-70h],rdx
    2da: mov     [rbp-68h],rax
    2de: mov     [rbp+18h],rdx
    2e2: mov     [rbp+20h],rax
    2e6: jmp     1B0h
    2eb: nop     [rax+rax]
    2f0: lea     rdi,[sym11]
    2f7: lea     rsi,[site12]
    2fe: mov     edx,0FFFFFF68h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-90h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+36]
    322: call    qword ptr [sym13]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rdi,rax
    332: mov     esi,0FFFFFFD0h
    337: call    ryo_h_Lpad
    33c: jmp     220h
    341: mov     rdi,rax
    344: mov     esi,0FFFFFFD0h
    349: call    ryo_h_Lpad
    34e: jmp     2F0h

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
     21: mov     esi,[rbp+10h]
     24: mov     [rbp-20h],esi
     27: mov     edi,[rbp-8]
     2a: mov     [rbp-1Ch],edi
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
     24: mov     rdx,[rbp-20h]
     28: mov     [rbp-28h],rdx
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
     18: je      43h
     1a: mov     rdi,[rbp+10h]
     1e: mov     [rbp-30h],rdi
     22: mov     [rbp-28h],rax
     26: mov     edi,0FFFFFFE0h
     2b: lea     rsi,[k0]
     32: call    ryo_h_AddrAbs
     37: call    fn1
     3c: nop     [rcx-8]
     43: mov     rax,[rbp+10h]
     47: add     rax,[rbp-10h]
     4b: mov     [rbp-8],rax
     4f: mov     edi,0FFFFFFF8h
     54: mov     esi,8
     59: call    ryo_h_Ret
     5e: leave
     5f: ret

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: imul    rax,[rbp+20h],1
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
     de: mov     qword ptr [rbp-0B0h],1
     e9: mov     qword ptr [rbp-0A8h],1
     f4: mov     r8,[rbp-58h]
     f8: mov     [rbp-0A0h],r8
     ff: mov     edi,0FFFFFF68h
    104: lea     rsi,[k2]
    10b: call    ryo_h_AddrAbs
    110: call    fn3
    115: nop     [rcx-40h]
    11c: imul    rax,[rbp-58h],1
    121: mov     [rbp-88h],rax
    128: mov     edi,0FFFFFF90h
    12d: mov     esi,0FFFFFF98h
    132: mov     edx,0FFFFFF78h
    137: call    ryo_h_Memcpy
    13c: mov     byte ptr [rbp-81h],1
    143: test    byte ptr [rbp-81h],0FFh
    14a: je      170h
    14c: mov     qword ptr [rbp-88h],1
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+20h]
      c: mov     [rbp-10h],rax
     10: lea     rdx,[rbp+10h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx-1]
     2c: mov     edi,0FFFFFFFFh
     31: mov     esi,1
     36: call    ryo_h_Ret
     3b: leave
     3c: ret
     3d: nop     [rax]
     40: mov     edi,0FFFFFFE0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE0h
     54: call    ryo_h_Lpad
     59: jmp     40h

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
     10: mov     rdx,[rbp+20h]
     14: mov     [rbp-10h],rdx
     18: lea     rsi,[rbp+10h]
     1c: mov     [rbp-20h],rsi
     20: mov     [rbp-40h],rsi
     24: mov     [rbp-38h],rax
     28: mov     [rbp-30h],rdx
     2c: call    fn0
     31: nop     [rcx-8]
     38: mov     edi,0FFFFFFF8h
     3d: mov     esi,8
     42: call    ryo_h_Ret
     47: leave
     48: ret
     49: nop     [rax]
     50: mov     edi,0FFFFFFD8h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFD8h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+20h]
     14: mov     [rbp-10h],rdx
     18: mov     rsi,[rbp+18h]
     1c: mov     rsi,[rsi]
     1f: mov     [rbp-30h],rsi
     23: mov     [rbp-28h],rax
     27: mov     [rbp-20h],rdx
     2b: call    fn0
     30: nop     [rcx-8]
     37: mov     edi,0FFFFFFF8h
     3c: mov     esi,8
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-8],rax
     10: lea     rdx,[rbp+10h]
     14: mov     [rbp-10h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx]
     2c: xor     edi,edi
     2e: xor     esi,esi
     30: call    ryo_h_Ret
     35: leave
     36: ret
     37: nop     [rax+rax]
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
     10: lea     rdx,[rbp+10h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx-1]
     2c: mov     edi,0FFFFFFFFh
     31: mov     esi,1
     36: call    ryo_h_Ret
     3b: leave
     3c: ret
     3d: nop     [rax]
     40: mov     edi,0FFFFFFE0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE0h
     54: call    ryo_h_Lpad
     59: jmp     40h

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
     10: lea     rdx,[rbp+10h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx-1]
     2c: mov     edi,0FFFFFFFFh
     31: mov     esi,1
     36: call    ryo_h_Ret
     3b: leave
     3c: ret
     3d: nop     [rax]
     40: mov     edi,0FFFFFFE0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE0h
     54: call    ryo_h_Lpad
     59: jmp     40h

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
     10: mov     rdx,[rbp+20h]
     14: mov     [rbp-10h],rdx
     18: lea     rsi,[rbp+10h]
     1c: mov     [rbp-20h],rsi
     20: mov     [rbp-40h],rsi
     24: mov     [rbp-38h],rax
     28: mov     [rbp-30h],rdx
     2c: call    fn0
     31: nop     [rcx-8]
     38: mov     edi,0FFFFFFF8h
     3d: mov     esi,8
     42: call    ryo_h_Ret
     47: leave
     48: ret
     49: nop     [rax]
     50: mov     edi,0FFFFFFD8h
     55: call    ryo_h_Resume
     5a: ud2
     5c: mov     rdi,rax
     5f: mov     esi,0FFFFFFD8h
     64: call    ryo_h_Lpad
     69: jmp     50h

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+20h]
     14: mov     [rbp-10h],rdx
     18: mov     rsi,[rbp+18h]
     1c: mov     rsi,[rsi]
     1f: mov     [rbp-30h],rsi
     23: mov     [rbp-28h],rax
     27: mov     [rbp-20h],rdx
     2b: call    fn0
     30: nop     [rcx-8]
     37: mov     edi,0FFFFFFF8h
     3c: mov     esi,8
     41: call    ryo_h_Ret
     46: leave
     47: ret

fn <{closure@std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}} as std::ops::FnOnce<(std::option::Option<&mut std::option::Option<std::cell::Cell<(u64, u64)>>>,)>>::call_once - shim
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     [rbp-10h],rax
     10: lea     rdx,[rbp+10h]
     14: mov     [rbp-18h],rdx
     18: mov     [rbp-30h],rdx
     1c: mov     [rbp-28h],rax
     20: call    fn0
     25: nop     [rcx-8]
     2c: mov     edi,0FFFFFFF8h
     31: mov     esi,8
     36: call    ryo_h_Ret
     3b: leave
     3c: ret
     3d: nop     [rax]
     40: mov     edi,0FFFFFFE0h
     45: call    ryo_h_Resume
     4a: ud2
     4c: mov     rdi,rax
     4f: mov     esi,0FFFFFFE0h
     54: call    ryo_h_Lpad
     59: jmp     40h

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

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-8],rax
     13: mov     [rbp-20h],rax
     17: mov     rdx,[rbp+18h]
     1b: mov     [rbp-18h],rdx
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
     17: mov     rdx,[rbp+18h]
     1b: mov     [rbp-18h],rdx
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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-20h],rdx
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx]
     2b: xor     edi,edi
     2d: xor     esi,esi
     2f: call    ryo_h_Ret
     34: leave
     35: ret

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     qword ptr [rbp-10h],0
     10: mov     rdx,[rbp+10h]
     14: mov     rcx,[rbp-10h]
     18: mov     [rdx+30h],rcx
     1c: mov     rsi,[rbp+10h]
     20: mov     rsi,[rsi+20h]
     24: mov     [rbp-8],rsi
     28: mov     rcx,736F6D6570736575h
     32: xor     rsi,rcx
     35: mov     [rbp-10h],rsi
     39: mov     rdi,[rbp+10h]
     3d: mov     rcx,[rbp-10h]
     41: mov     [rdi],rcx
     44: mov     r8,[rbp+10h]
     48: mov     r8,[r8+28h]
     4c: mov     [rbp-8],r8
     50: mov     rcx,646F72616E646F6Dh
     5a: xor     r8,rcx
     5d: mov     [rbp-10h],r8
     61: mov     r9,[rbp+10h]
     65: mov     rcx,[rbp-10h]
     69: mov     [r9+10h],rcx
     6d: mov     r10,[rbp+10h]
     71: mov     r10,[r10+20h]
     75: mov     [rbp-8],r10
     79: mov     rcx,6C7967656E657261h
     83: xor     r10,rcx
     86: mov     [rbp-10h],r10
     8a: mov     r11,[rbp+10h]
     8e: mov     rcx,[rbp-10h]
     92: mov     [r11+8],rcx
     96: mov     rax,[rbp+10h]
     9a: mov     rax,[rax+28h]
     9e: mov     [rbp-8],rax
     a2: mov     rcx,7465646279746573h
     ac: xor     rax,rcx
     af: mov     [rbp-10h],rax
     b3: mov     rdx,[rbp+10h]
     b7: mov     rcx,[rbp-10h]
     bb: mov     [rdx+18h],rcx
     bf: mov     qword ptr [rbp-10h],0
     c7: mov     rdi,[rbp+10h]
     cb: mov     rcx,[rbp-10h]
     cf: mov     [rdi+40h],rcx
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
     1b: mov     rsi,[rbp-38h]
     1f: mov     [rbp-50h],rsi
     23: add     rsi,3
     27: mov     [rbp-48h],rsi
     2b: cmp     rsi,[rbp+28h]
     2f: jae     90h
     31: mov     dword ptr [rbp-40h],0
     38: mov     r8,[rbp+10h]
     3c: mov     [rbp-60h],r8
     40: mov     r9,[rbp+18h]
     44: mov     [rbp-58h],r9
     48: mov     [rbp-50h],r8
     4c: mov     r10,[rbp-38h]
     50: mov     [rbp-60h],r10
     54: mov     r11,[rbp+20h]
     58: add     r11,r10
     5b: mov     [rbp-58h],r11
     5f: imul    rcx,r11,1
     63: add     r8,rcx
     66: mov     [rbp-48h],r8
     6a: lea     rax,[rbp-40h]
     6e: mov     [rbp-58h],rax
     72: mov     [rbp-50h],rax
     76: mov     byte ptr [rbp-79h],1
     7a: test    byte ptr [rbp-79h],0FFh
     7e: je      1ADh
     84: jmp     151h
     89: nop     [rax]
     90: mov     rax,[rbp-38h]
     94: mov     [rbp-50h],rax
     98: add     rax,1
     9c: mov     [rbp-48h],rax
     a0: cmp     rax,[rbp+28h]
     a4: jae     100h
     a6: mov     word ptr [rbp-3Ch],0
     ac: mov     rsi,[rbp+10h]
     b0: mov     [rbp-70h],rsi
     b4: mov     rdi,[rbp+18h]
     b8: mov     [rbp-68h],rdi
     bc: mov     [rbp-60h],rsi
     c0: mov     r8,[rbp-38h]
     c4: mov     [rbp-70h],r8
     c8: mov     r9,[rbp+20h]
     cc: add     r9,r8
     cf: mov     [rbp-68h],r9
     d3: imul    rcx,r9,1
     d7: add     rsi,rcx
     da: mov     [rbp-58h],rsi
     de: lea     r10,[rbp-3Ch]
     e2: mov     [rbp-68h],r10
     e6: mov     [rbp-60h],r10
     ea: mov     byte ptr [rbp-79h],1
     ee: test    byte ptr [rbp-79h],0FFh
     f2: je      257h
     f8: jmp     1FBh
     fd: nop     [rax]
    100: mov     rax,[rbp-38h]
    104: mov     [rbp-48h],rax
    108: cmp     rax,[rbp+28h]
    10c: jae     140h
    10e: mov     rdx,[rbp-38h]
    112: mov     [rbp-60h],rdx
    116: mov     rsi,[rbp+20h]
    11a: add     rsi,rdx
    11d: mov     [rbp-58h],rsi
    121: mov     byte ptr [rbp-79h],1
    125: test    byte ptr [rbp-79h],0FFh
    129: je      30Eh
    12f: jmp     2D7h
    134: nop     [rax+rax]
    13d: nop     [rax]
    140: mov     edi,0FFFFFFF8h
    145: mov     esi,8
    14a: call    ryo_h_Ret
    14f: leave
    150: ret
    151: mov     rax,[rbp-48h]
    155: mov     [rbp-60h],rax
    159: mov     rdx,[rbp-58h]
    15d: mov     [rbp-68h],rdx
    161: mov     [rbp-0C0h],rax
    168: mov     [rbp-0B8h],rdx
    16f: mov     qword ptr [rbp-0B0h],1
    17a: mov     qword ptr [rbp-0A8h],1
    185: mov     qword ptr [rbp-0A0h],4
    190: mov     edi,0FFFFFF68h
    195: lea     rsi,[k0]
    19c: call    ryo_h_AddrAbs
    1a1: call    fn1
    1a6: nop     [rcx-21h]
    1ad: mov     qword ptr [rbp-80h],4
    1b5: imul    rdx,[rbp-80h],1
    1ba: mov     [rbp-88h],rdx
    1c1: mov     edi,0FFFFFFB0h
    1c6: mov     esi,0FFFFFFB8h
    1cb: mov     edx,0FFFFFF78h
    1d0: call    ryo_h_Memcpy
    1d5: mov     eax,[rbp-40h]
    1d8: mov     [rbp-0Ch],eax
    1db: mov     edi,0FFFFFFF8h
    1e0: mov     esi,0FFFFFFF4h
    1e5: call    ryo_h_ZextW32W64
    1ea: mov     rax,[rbp-38h]
    1ee: add     rax,4
    1f2: mov     [rbp-38h],rax
    1f6: jmp     90h
    1fb: mov     rax,[rbp-58h]
    1ff: mov     [rbp-70h],rax
    203: mov     rdx,[rbp-68h]
    207: mov     [rbp-78h],rdx
    20b: mov     [rbp-0C0h],rax
    212: mov     [rbp-0B8h],rdx
    219: mov     qword ptr [rbp-0B0h],1
    224: mov     qword ptr [rbp-0A8h],1
    22f: mov     qword ptr [rbp-0A0h],2
    23a: mov     edi,0FFFFFF68h
    23f: lea     rsi,[k2]
    246: call    ryo_h_AddrAbs
    24b: call    fn3
    250: nop     [rcx-21h]
    257: mov     qword ptr [rbp-80h],2
    25f: imul    rdx,[rbp-80h],1
    264: mov     [rbp-88h],rdx
    26b: mov     edi,0FFFFFFA0h
    270: mov     esi,0FFFFFFA8h
    275: mov     edx,0FFFFFF78h
    27a: call    ryo_h_Memcpy
    27f: movzx   eax,word ptr [rbp-3Ch]
    283: mov     [rbp-0Eh],ax
    287: mov     edi,0FFFFFFB0h
    28c: mov     esi,0FFFFFFF2h
    291: call    ryo_h_ZextW16W64
    296: mov     rax,[rbp-38h]
    29a: mov     [rbp-60h],rax
    29e: imul    rdx,rax,8
    2a2: mov     [rbp-58h],rdx
    2a6: mov     edi,0FFFFFFB8h
    2ab: mov     esi,0FFFFFFB0h
    2b0: mov     edx,0FFFFFFA8h
    2b5: call    ryo_h_ShlW64
    2ba: mov     rax,[rbp-8]
    2be: or      rax,[rbp-48h]
    2c2: mov     [rbp-8],rax
    2c6: mov     rdx,[rbp-38h]
    2ca: add     rdx,2
    2ce: mov     [rbp-38h],rdx
    2d2: jmp     100h
    2d7: mov     rax,[rbp+18h]
    2db: mov     [rbp-60h],rax
    2df: mov     rdx,[rbp-58h]
    2e3: mov     [rbp-0C0h],rdx
    2ea: mov     [rbp-0B8h],rax
    2f1: mov     edi,0FFFFFF50h
    2f6: lea     rsi,[k4]
    2fd: call    ryo_h_AddrAbs
    302: call    fn5
    307: nop     [rcx-30h]
    30e: mov     rax,[rbp+18h]
    312: mov     [rbp-60h],rax
    316: mov     rdx,[rbp-58h]
    31a: cmp     rdx,rax
    31d: setb    [rbp-3Bh]
    321: mov     rsi,[rbp+10h]
    325: imul    rcx,rdx,1
    329: add     rsi,rcx
    32c: mov     [rbp-80h],rsi
    330: mov     [rbp-30h],rsi
    334: movzx   esi,byte ptr [rsi]
    337: mov     [rbp-3Ah],sil
    33b: mov     edi,0FFFFFFB0h
    340: mov     esi,0FFFFFFC6h
    345: call    ryo_h_ZextW8W64
    34a: mov     rax,[rbp-38h]
    34e: mov     [rbp-60h],rax
    352: imul    rdx,rax,8
    356: mov     [rbp-58h],rdx
    35a: mov     edi,0FFFFFFB8h
    35f: mov     esi,0FFFFFFB0h
    364: mov     edx,0FFFFFFA8h
    369: call    ryo_h_ShlW64
    36e: mov     rax,[rbp-8]
    372: or      rax,[rbp-48h]
    376: mov     [rbp-8],rax
    37a: mov     rdx,[rbp-38h]
    37e: add     rdx,1
    382: mov     [rbp-38h],rdx
    386: jmp     140h

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
      f: mov     rdx,[rbp+10h]
     13: mov     [rbp-18h],rdx
     17: mov     rsi,[rbp+10h]
     1b: mov     [rbp-78h],rsi
     1f: and     rsi,3
     23: mov     [rbp-80h],rsi
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
     50: .long   15ch
     54: .long   124h
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
     d3: mov     rdx,[rbp+10h]
     d7: mov     [rbp-0A0h],rdx
     de: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     e9: imul    rcx,[rbp-0A8h],1
     f1: add     rdx,rcx
     f4: mov     [rbp-68h],rdx
     f8: jmp     28Ch
     fd: mov     rax,[rbp+10h]
    101: mov     [rbp-30h],rax
    105: mov     rdx,[rbp+10h]
    109: mov     [rbp-90h],rdx
    110: mov     [rbp-88h],rax
    117: mov     [rbp-8],rax
    11b: mov     byte ptr [rbp-10h],2
    11f: jmp     2DBh
    124: mov     rax,[rbp-78h]
    128: shr     rax,20h
    12c: mov     [rbp-90h],rax
    133: mov     edi,0FFFFFF7Ch
    138: mov     esi,0FFFFFF70h
    13d: call    ryo_h_TruncW64W32
    142: mov     eax,[rbp-84h]
    148: mov     [rbp-0C0h],eax
    14e: call    fn5
    153: nop     [rcx-86h]
    15a: jmp     193h
    15c: mov     rax,[rbp-78h]
    160: mov     [rbp-98h],rax
    167: sar     rax,20h
    16b: mov     [rbp-90h],rax
    172: mov     edi,0FFFFFF7Ch
    177: mov     esi,0FFFFFF70h
    17c: call    ryo_h_TruncW64W32
    181: mov     eax,[rbp-84h]
    187: mov     [rbp-0Ch],eax
    18a: mov     byte ptr [rbp-10h],0
    18e: jmp     2DBh
    193: mov     edi,0FFFFFF5Ch
    198: mov     esi,0FFFFFF7Ah
    19d: mov     edx,0FFh
    1a2: xor     ecx,ecx
    1a4: xor     r8d,r8d
    1a7: mov     r9d,1
    1ad: call    ryo_h_DiscrNicheW8
    1b2: mov     edi,0FFFFFF70h
    1b7: mov     esi,0FFFFFF5Ch
    1bc: call    ryo_h_ZextW32W64
    1c1: mov     edi,0FFFFFF70h
    1c6: xor     esi,esi
    1c8: mov     edx,2
    1cd: call    ryo_h_SwitchDenseW64
    1d2: lea     rcx,[1E4h]
    1d9: movsxd  rax,[rcx+rax*4]
    1dd: add     rax,rcx
    1e0: jmp     rax
    1e2: int3
    1e3: int3
    1e4: .long   257h
    1e8: .long   276h
    1ec: .long   250h
    1f0: mov     rax,[rbp-90h]
    1f7: mov     [rbp-8],rax
    1fb: mov     byte ptr [rbp-10h],3
    1ff: nop
    200: mov     edi,0FFFFFFF0h
    205: mov     esi,10h
    20a: call    ryo_h_Ret
    20f: leave
    210: ret
    211: nop     [rax+rax]
    21a: nop     [rax+rax]
    220: mov     edi,0FFFFFF90h
    225: call    ryo_h_Resume
    22a: ud2
    22c: nop     [rax]
    230: jmp     220h
    232: nop     [rax+rax]
    23b: nop     [rax+rax]
    240: test    byte ptr [rbp-21h],0FFh
    244: je      220h
    246: jmp     230h
    248: nop     [rax+rax]
    250: call    ryo_h_Unreachable
    255: ud2
    257: mov     edi,0FFFFFF40h
    25c: lea     rsi,[k6]
    263: call    ryo_h_AddrAbs
    268: call    fn7
    26d: nop     [rcx-58h]
    274: jmp     250h
    276: movzx   eax,byte ptr [rbp-86h]
    27d: mov     [rbp-85h],al
    283: mov     [rbp-0Fh],al
    286: mov     byte ptr [rbp-10h],1
    28a: jmp     2DBh
    28c: mov     rax,[rbp-68h]
    290: mov     [rbp-90h],rax
    297: mov     rdx,[rbp+10h]
    29b: mov     [rbp-98h],rdx
    2a2: mov     rsi,[rbp-68h]
    2a6: mov     [rbp-0A0h],rsi
    2ad: mov     rdi,[rbp-68h]
    2b1: mov     [rbp-88h],rdi
    2b8: mov     byte ptr [rbp-21h],0
    2bc: mov     [rbp-98h],rdi
    2c3: mov     [rbp-0C0h],rdi
    2ca: call    fn8
    2cf: nop     [rcx-90h]
    2d6: jmp     1F0h
    2db: jmp     200h
    2e0: mov     rdi,rax
    2e3: mov     esi,0FFFFFF90h
    2e8: call    ryo_h_Lpad
    2ed: jmp     240h

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-21h],1
      f: mov     rdx,[rbp+10h]
     13: mov     [rbp-18h],rdx
     17: mov     rsi,[rbp+10h]
     1b: mov     [rbp-78h],rsi
     1f: and     rsi,3
     23: mov     [rbp-80h],rsi
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
     50: .long   15ch
     54: .long   124h
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
     d3: mov     rdx,[rbp+10h]
     d7: mov     [rbp-0A0h],rdx
     de: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
     e9: imul    rcx,[rbp-0A8h],1
     f1: add     rdx,rcx
     f4: mov     [rbp-68h],rdx
     f8: jmp     28Ch
     fd: mov     rax,[rbp+10h]
    101: mov     [rbp-30h],rax
    105: mov     rdx,[rbp+10h]
    109: mov     [rbp-90h],rdx
    110: mov     [rbp-88h],rax
    117: mov     [rbp-8],rax
    11b: mov     byte ptr [rbp-10h],2
    11f: jmp     2DBh
    124: mov     rax,[rbp-78h]
    128: shr     rax,20h
    12c: mov     [rbp-90h],rax
    133: mov     edi,0FFFFFF7Ch
    138: mov     esi,0FFFFFF70h
    13d: call    ryo_h_TruncW64W32
    142: mov     eax,[rbp-84h]
    148: mov     [rbp-0C0h],eax
    14e: call    fn5
    153: nop     [rcx-86h]
    15a: jmp     193h
    15c: mov     rax,[rbp-78h]
    160: mov     [rbp-98h],rax
    167: sar     rax,20h
    16b: mov     [rbp-90h],rax
    172: mov     edi,0FFFFFF7Ch
    177: mov     esi,0FFFFFF70h
    17c: call    ryo_h_TruncW64W32
    181: mov     eax,[rbp-84h]
    187: mov     [rbp-0Ch],eax
    18a: mov     byte ptr [rbp-10h],0
    18e: jmp     2DBh
    193: mov     edi,0FFFFFF5Ch
    198: mov     esi,0FFFFFF7Ah
    19d: mov     edx,0FFh
    1a2: xor     ecx,ecx
    1a4: xor     r8d,r8d
    1a7: mov     r9d,1
    1ad: call    ryo_h_DiscrNicheW8
    1b2: mov     edi,0FFFFFF70h
    1b7: mov     esi,0FFFFFF5Ch
    1bc: call    ryo_h_ZextW32W64
    1c1: mov     edi,0FFFFFF70h
    1c6: xor     esi,esi
    1c8: mov     edx,2
    1cd: call    ryo_h_SwitchDenseW64
    1d2: lea     rcx,[1E4h]
    1d9: movsxd  rax,[rcx+rax*4]
    1dd: add     rax,rcx
    1e0: jmp     rax
    1e2: int3
    1e3: int3
    1e4: .long   257h
    1e8: .long   276h
    1ec: .long   250h
    1f0: mov     rax,[rbp-90h]
    1f7: mov     [rbp-8],rax
    1fb: mov     byte ptr [rbp-10h],3
    1ff: nop
    200: mov     edi,0FFFFFFF0h
    205: mov     esi,10h
    20a: call    ryo_h_Ret
    20f: leave
    210: ret
    211: nop     [rax+rax]
    21a: nop     [rax+rax]
    220: mov     edi,0FFFFFF90h
    225: call    ryo_h_Resume
    22a: ud2
    22c: nop     [rax]
    230: jmp     220h
    232: nop     [rax+rax]
    23b: nop     [rax+rax]
    240: test    byte ptr [rbp-21h],0FFh
    244: je      220h
    246: jmp     230h
    248: nop     [rax+rax]
    250: call    ryo_h_Unreachable
    255: ud2
    257: mov     edi,0FFFFFF40h
    25c: lea     rsi,[k6]
    263: call    ryo_h_AddrAbs
    268: call    fn7
    26d: nop     [rcx-58h]
    274: jmp     250h
    276: movzx   eax,byte ptr [rbp-86h]
    27d: mov     [rbp-85h],al
    283: mov     [rbp-0Fh],al
    286: mov     byte ptr [rbp-10h],1
    28a: jmp     2DBh
    28c: mov     rax,[rbp-68h]
    290: mov     [rbp-90h],rax
    297: mov     rdx,[rbp+10h]
    29b: mov     [rbp-98h],rdx
    2a2: mov     rsi,[rbp-68h]
    2a6: mov     [rbp-0A0h],rsi
    2ad: mov     rdi,[rbp-68h]
    2b1: mov     [rbp-88h],rdi
    2b8: mov     byte ptr [rbp-21h],0
    2bc: mov     [rbp-98h],rdi
    2c3: mov     [rbp-0C0h],rdi
    2ca: call    fn8
    2cf: nop     [rcx-90h]
    2d6: jmp     1F0h
    2db: jmp     200h
    2e0: mov     rdi,rax
    2e3: mov     esi,0FFFFFF90h
    2e8: call    ryo_h_Lpad
    2ed: jmp     240h

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-30h],rax
     13: mov     qword ptr [rbp-28h],0
     1b: lea     rsi,[rbp-30h]
     1f: mov     [rbp-50h],rsi
     23: mov     [rbp-48h],rsi
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
    107: movzx   edx,byte ptr [rbp-33h]
    10b: xor     dl,1
    10e: mov     [rbp-32h],dl
    111: test    byte ptr [rbp-32h],0FFh
    115: je      151h
    117: jmp     144h
    119: mov     qword ptr [rbp-8],0
    121: lea     rdx,[rbp-28h]
    125: mov     [rbp-0A0h],rdx
    12c: mov     [rbp-0C0h],rdx
    133: call    fn4
    138: nop     [rcx-0A0h]
    13f: jmp     22Bh
    144: mov     rax,[rbp-28h]
    148: mov     [rbp-8],rax
    14c: jmp     22Bh
    151: mov     edi,0FFFFFFA0h
    156: lea     rsi,[k5]
    15d: call    ryo_h_AddrAbs
    162: mov     qword ptr [rbp-58h],56h
    16a: mov     rdx,[rbp-60h]
    16e: mov     [rbp-80h],rdx
    172: mov     rsi,[rbp-58h]
    176: mov     [rbp-78h],rsi
    17a: mov     [rbp-70h],rdx
    17e: mov     [rbp-68h],rdx
    182: mov     edi,0FFFFFF68h
    187: lea     rsi,[k6]
    18e: call    ryo_h_AddrAbs
    193: mov     qword ptr [rbp-90h],56h
    19e: mov     rdx,[rbp-90h]
    1a5: mov     [rbp-88h],rdx
    1ac: shl     rdx,1
    1b0: mov     [rbp-80h],rdx
    1b4: or      rdx,1
    1b8: mov     [rbp-78h],rdx
    1bc: mov     [rbp-70h],rdx
    1c0: mov     rsi,[rbp-68h]
    1c4: mov     [rbp-48h],rsi
    1c8: mov     [rbp-40h],rdx
    1cc: mov     edi,0FFFFFF40h
    1d1: mov     esi,0FFFFFFB8h
    1d6: call    ryo_h_MovW128
    1db: mov     edi,0FFFFFF50h
    1e0: lea     rsi,[k7]
    1e7: call    ryo_h_AddrAbs
    1ec: lea     rdi,[sym8]
    1f3: lea     rsi,[site9]
    1fa: mov     edx,0FFFFFF60h
    1ff: call    ryo_h_CallExt
    204: test    rax,rax
    207: je      214h
    209: call    rax
    20b: nop     [rcx-18h]
    212: jmp     224h
    214: mov     rdi,rbp
    217: lea     rsi,[ro+20]
    21e: call    qword ptr [sym10]
    224: call    ryo_h_Unreachable
    229: ud2
    22b: mov     edi,0FFFFFFF8h
    230: mov     esi,8
    235: call    ryo_h_Ret
    23a: leave
    23b: ret
    23c: nop     [rax]
    240: lea     rax,[rbp-30h]
    244: mov     [rbp-0A0h],rax
    24b: mov     [rbp-0C0h],rax
    252: call    fn11
    257: nop     [rcx-0A0h]
    25e: mov     edi,0FFFFFFE0h
    263: call    ryo_h_Resume
    268: ud2
    26a: nop     [rax+rax]
    270: lea     rdi,[sym12]
    277: lea     rsi,[site13]
    27e: mov     edx,0FFFFFF60h
    283: call    ryo_h_CallExt
    288: test    rax,rax
    28b: je      298h
    28d: call    rax
    28f: nop     [rcx-98h]
    296: jmp     2A8h
    298: mov     rdi,rbp
    29b: lea     rsi,[ro+36]
    2a2: call    qword ptr [sym14]
    2a8: call    ryo_h_Unreachable
    2ad: ud2
    2af: mov     rdi,rax
    2b2: mov     esi,0FFFFFFE0h
    2b7: call    ryo_h_Lpad
    2bc: jmp     240h
    2be: mov     rdi,rax
    2c1: mov     esi,0FFFFFFE0h
    2c6: call    ryo_h_Lpad
    2cb: jmp     270h

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
     2f: je      101h
     35: mov     edi,0FFFFFFF0h
     3a: lea     rsi,[k0]
     41: call    ryo_h_AddrAbs
     46: mov     qword ptr [rbp-8],0B8h
     4e: mov     rdx,[rbp-10h]
     52: mov     [rbp-48h],rdx
     56: mov     rsi,[rbp-8]
     5a: mov     [rbp-40h],rsi
     5e: mov     [rbp-38h],rdx
     62: mov     [rbp-30h],rdx
     66: mov     edi,0FFFFFFA0h
     6b: lea     rsi,[k1]
     72: call    ryo_h_AddrAbs
     77: mov     qword ptr [rbp-58h],0B8h
     7f: mov     rdx,[rbp-58h]
     83: mov     [rbp-50h],rdx
     87: shl     rdx,1
     8b: mov     [rbp-48h],rdx
     8f: or      rdx,1
     93: mov     [rbp-40h],rdx
     97: mov     [rbp-38h],rdx
     9b: mov     rsi,[rbp-30h]
     9f: mov     [rbp-28h],rsi
     a3: mov     [rbp-20h],rdx
     a7: mov     edi,0FFFFFF70h
     ac: mov     esi,0FFFFFFD8h
     b1: call    ryo_h_MovW128
     b6: mov     byte ptr [rbp-80h],0
     ba: mov     rdx,[rbp+18h]
     be: mov     [rbp-78h],rdx
     c2: lea     rdi,[sym2]
     c9: lea     rsi,[site3]
     d0: mov     edx,0FFFFFF98h
     d5: call    ryo_h_CallExt
     da: test    rax,rax
     dd: je      0EAh
     df: call    rax
     e1: nop     [rcx-10h]
     e8: jmp     0FAh
     ea: mov     rdi,rbp
     ed: lea     rsi,[ro+4]
     f4: call    qword ptr [sym4]
     fa: call    ryo_h_Unreachable
     ff: ud2
    101: xor     edi,edi
    103: xor     esi,esi
    105: call    ryo_h_Ret
    10a: leave
    10b: ret

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
     2f: je      101h
     35: mov     edi,0FFFFFFF0h
     3a: lea     rsi,[k0]
     41: call    ryo_h_AddrAbs
     46: mov     qword ptr [rbp-8],0B8h
     4e: mov     rdx,[rbp-10h]
     52: mov     [rbp-48h],rdx
     56: mov     rsi,[rbp-8]
     5a: mov     [rbp-40h],rsi
     5e: mov     [rbp-38h],rdx
     62: mov     [rbp-30h],rdx
     66: mov     edi,0FFFFFFA0h
     6b: lea     rsi,[k1]
     72: call    ryo_h_AddrAbs
     77: mov     qword ptr [rbp-58h],0B8h
     7f: mov     rdx,[rbp-58h]
     83: mov     [rbp-50h],rdx
     87: shl     rdx,1
     8b: mov     [rbp-48h],rdx
     8f: or      rdx,1
     93: mov     [rbp-40h],rdx
     97: mov     [rbp-38h],rdx
     9b: mov     rsi,[rbp-30h]
     9f: mov     [rbp-28h],rsi
     a3: mov     [rbp-20h],rdx
     a7: mov     edi,0FFFFFF70h
     ac: mov     esi,0FFFFFFD8h
     b1: call    ryo_h_MovW128
     b6: mov     byte ptr [rbp-80h],0
     ba: mov     rdx,[rbp+20h]
     be: mov     [rbp-78h],rdx
     c2: lea     rdi,[sym2]
     c9: lea     rsi,[site3]
     d0: mov     edx,0FFFFFF98h
     d5: call    ryo_h_CallExt
     da: test    rax,rax
     dd: je      0EAh
     df: call    rax
     e1: nop     [rcx-10h]
     e8: jmp     0FAh
     ea: mov     rdi,rbp
     ed: lea     rsi,[ro+4]
     f4: call    qword ptr [sym4]
     fa: call    ryo_h_Unreachable
     ff: ud2
    101: xor     edi,edi
    103: xor     esi,esi
    105: call    ryo_h_Ret
    10a: leave
    10b: ret

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
     42: mov     rdx,[rbp+18h]
     46: mov     [rbp-98h],rdx
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
     89: mov     rdx,[rbp+18h]
     8d: mov     [rbp-48h],rdx
     91: mov     [rbp-0A0h],rax
     98: mov     rsi,[rbp-30h]
     9c: mov     [rbp-98h],rsi
     a3: mov     [rbp-90h],rdx
     aa: call    fn1
     af: nop     [rcx-50h]
     b6: mov     edi,0FFFFFF84h
     bb: mov     esi,0FFFFFFB0h
     c0: xor     edx,edx
     c2: xor     ecx,ecx
     c4: xor     r8d,r8d
     c7: mov     r9d,1
     cd: call    ryo_h_DiscrNicheW64
     d2: mov     edi,0FFFFFFA8h
     d7: mov     esi,0FFFFFF84h
     dc: call    ryo_h_ZextW32W64
     e1: mov     edi,0FFFFFFA8h
     e6: xor     esi,esi
     e8: mov     edx,2
     ed: call    ryo_h_SwitchDenseW64
     f2: lea     rcx,[104h]
     f9: movsxd  rax,[rcx+rax*4]
     fd: add     rax,rcx
    100: jmp     rax
    102: int3
    103: int3
    104: .long   110h
    108: .long   11dh
    10c: .long   60h
    110: mov     qword ptr [rbp-8],0
    118: jmp     70h
    11d: mov     rax,[rbp-50h]
    121: mov     [rbp-78h],rax
    125: mov     byte ptr [rbp-79h],0
    129: test    byte ptr [rbp-79h],0FFh
    12d: je      16Bh
    12f: jmp     161h
    131: nop     [rax+rax]
    13a: nop     [rax+rax]
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
    194: mov     rdx,[rbp-70h]
    198: imul    rcx,[rbp-80h],10h
    19d: add     rdx,rcx
    1a0: mov     [rbp-68h],rdx
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
     ad: mov     rdx,[rbp+10h]
     b1: mov     rdx,[rdx]
     b4: mov     [rbp-98h],rdx
     bb: mov     [rbp-90h],rdx
     c2: mov     rsi,[rbp+10h]
     c6: mov     rsi,[rsi+8]
     ca: mov     [rbp-0B0h],rsi
     d1: add     rsi,1
     d5: mov     [rbp-98h],rsi
     dc: mov     [rbp-0C8h],rdx
     e3: mov     [rbp-0D0h],rax
     ea: mov     [rbp-0C0h],rsi
     f1: call    fn0
     f6: nop     [rcx-88h]
     fd: jmp     30h

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
     4f: je      1C6h
     55: jmp     1D6h
     5a: nop     [rax+rax]
     60: call    ryo_h_Unreachable
     65: ud2
     67: mov     rax,[rbp-90h]
     6e: mov     [rbp-98h],rax
     75: mov     byte ptr [rbp-0C9h],0
     7c: test    byte ptr [rbp-0C9h],0FFh
     83: je      2D3h
     89: jmp     2C6h
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
     bd: mov     rdx,[rbp-98h]
     c4: mov     [rbp-0E8h],rdx
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
    171: mov     rdx,[rbp+10h]
    175: mov     rdx,[rdx]
    178: mov     [rbp-98h],rdx
    17f: mov     [rbp-90h],rdx
    186: mov     rsi,[rbp+10h]
    18a: mov     rsi,[rsi+8]
    18e: mov     [rbp-0B0h],rsi
    195: add     rsi,1
    199: mov     [rbp-98h],rsi
    1a0: mov     [rbp-0E8h],rdx
    1a7: mov     [rbp-0F0h],rax
    1ae: mov     [rbp-0E0h],rsi
    1b5: call    fn1
    1ba: nop     [rcx-88h]
    1c1: jmp     100h
    1c6: mov     qword ptr [rbp-90h],0
    1d1: jmp     90h
    1d6: lea     rax,[rbp-88h]
    1dd: mov     [rbp-98h],rax
    1e4: mov     [rbp-0F0h],rax
    1eb: call    fn2
    1f0: nop     [rcx-90h]
    1f7: mov     rax,[rbp-68h]
    1fb: sub     rax,1
    1ff: mov     [rbp-68h],rax
    203: mov     edi,0FFFFFF34h
    208: mov     esi,0FFFFFF70h
    20d: xor     edx,edx
    20f: xor     ecx,ecx
    211: xor     r8d,r8d
    214: mov     r9d,1
    21a: call    ryo_h_DiscrNicheW64
    21f: mov     edi,0FFFFFFC0h
    224: mov     esi,0FFFFFF34h
    229: call    ryo_h_ZextW32W64
    22e: mov     edi,0FFFFFFC0h
    233: xor     esi,esi
    235: mov     edx,2
    23a: call    ryo_h_SwitchDenseW64
    23f: lea     rcx,[250h]
    246: movsxd  rax,[rcx+rax*4]
    24a: add     rax,rcx
    24d: jmp     rax
    24f: int3
    250: .long   90h
    254: .long   67h
    258: .long   60h
    25c: nop     [rax]
    260: mov     rax,[rbp-0A0h]
    267: mov     [rbp-0B0h],rax
    26e: mov     [rbp-0A0h],rax
    275: mov     rdx,[rbp-0B0h]
    27c: lea     rdx,[rdx+8]
    280: mov     [rbp-0A8h],rdx
    287: lea     rsi,[rbp+18h]
    28b: mov     [rbp-0B8h],rsi
    292: mov     [rbp-0C8h],rax
    299: mov     [rbp-0C0h],rdx
    2a0: mov     [rbp-0F0h],rsi
    2a7: mov     [rbp-0E8h],rax
    2ae: mov     [rbp-0E0h],rdx
    2b5: call    fn3
    2ba: nop     [rcx-0A9h]
    2c1: jmp     0A0h
    2c6: mov     qword ptr [rbp-0A0h],8
    2d1: jmp     260h
    2d3: mov     rax,[rbp-98h]
    2da: mov     [rbp-0B8h],rax
    2e1: mov     [rbp-0A8h],rax
    2e8: mov     byte ptr [rbp-0C9h],0
    2ef: test    byte ptr [rbp-0C9h],0FFh
    2f6: je      315h
    2f8: jmp     305h
    2fa: nop     [rax+rax]
    300: jmp     260h
    305: mov     rax,[rbp-0A8h]
    30c: mov     [rbp-0A0h],rax
    313: jmp     300h
    315: mov     qword ptr [rbp-0D0h],0FFFFFFFFFFFFFFFFh
    320: mov     rdx,[rbp-0A8h]
    327: imul    rcx,[rbp-0D0h],10h
    32f: add     rdx,rcx
    332: mov     [rbp-0A0h],rdx
    339: jmp     300h
    33b: mov     rdi,rax
    33e: mov     esi,0FFFFFFA0h
    343: call    ryo_h_Lpad
    348: jmp     0F0h

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-18h],rdx
     1b: mov     [rbp-30h],rax
     1f: mov     [rbp-28h],rdx
     23: call    fn0
     28: nop     [rcx-1]
     2f: mov     edi,0FFFFFFFFh
     34: mov     esi,1
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-18h],rdx
     1b: mov     [rbp-30h],rax
     1f: mov     [rbp-28h],rdx
     23: call    fn0
     28: nop     [rcx-8]
     2f: mov     edi,0FFFFFFF8h
     34: mov     esi,8
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+10h]
      c: mov     rax,[rax]
      f: mov     [rbp-10h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-18h],rdx
     1b: mov     [rbp-30h],rax
     1f: mov     [rbp-28h],rdx
     23: call    fn0
     28: nop     [rcx-8]
     2f: mov     edi,0FFFFFFF8h
     34: mov     esi,8
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

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
     ec: mov     rsi,[rbp+10h]
     f0: mov     rsi,[rsi]
     f3: mov     [rbp-90h],rsi
     fa: mov     [rbp-88h],rsi
    101: mov     qword ptr [rbp-0B8h],10h
    10c: imul    rcx,[rbp-0B8h],1
    114: add     rsi,rcx
    117: mov     [rbp-80h],rsi
    11b: mov     [rbp-78h],rsi
    11f: mov     r8,[rbp+10h]
    123: mov     rcx,[rbp-78h]
    127: mov     [r8],rcx
    12a: mov     r9,[rbp+10h]
    12e: mov     r9,[r9]
    131: mov     [rbp-28h],r9
    135: mov     [rbp-88h],r9
    13c: mov     r10,[rbp-28h]
    140: mov     [rbp-80h],r10
    144: mov     r11,[rbp-28h]
    148: mov     [rbp-88h],r11
    14f: mov     [rbp-0D0h],r11
    156: mov     edi,0FFFFFF48h
    15b: lea     rsi,[sym1]
    162: call    ryo_h_AddrSym
    167: mov     rdi,rbp
    16a: lea     rsi,[ro+4]
    171: call    qword ptr [sym2]
    177: jmp     243h
    17c: mov     edi,0FFFFFF58h
    181: mov     esi,0FFFFFF68h
    186: call    ryo_h_ZextW32W64
    18b: mov     rax,[rbp-0A8h]
    192: mov     [rbp-88h],rax
    199: mov     qword ptr [rbp-90h],1
    1a4: mov     [rbp-40h],rax
    1a8: mov     rsi,[rbp+10h]
    1ac: movzx   esi,word ptr [rsi+18h]
    1b0: mov     [rbp-88h],si
    1b7: sub     esi,1
    1ba: mov     [rbp-86h],si
    1c1: movzx   edi,word ptr [rbp-88h]
    1c8: and     di,[rbp-86h]
    1cf: mov     [rbp-84h],di
    1d6: movzx   r8d,word ptr [rbp-84h]
    1de: mov     [rbp-82h],r8w
    1e6: mov     r9,[rbp+10h]
    1ea: movzx   ecx,word ptr [rbp-82h]
    1f1: mov     [r9+18h],cx
    1f6: mov     r10,[rbp-40h]
    1fa: mov     [rbp-78h],r10
    1fe: mov     qword ptr [rbp-80h],1
    206: mov     [rbp-88h],r10
    20d: mov     rdx,[rbp+10h]
    211: mov     rdx,[rdx+8]
    215: mov     [rbp-98h],rdx
    21c: add     rdx,r10
    21f: mov     [rbp-90h],rdx
    226: mov     [rbp-8],rdx
    22a: mov     qword ptr [rbp-10h],1
    232: mov     edi,0FFFFFFF0h
    237: mov     esi,10h
    23c: call    ryo_h_Ret
    241: leave
    242: ret
    243: mov     edi,0FFFFFF30h
    248: mov     esi,0FFFFFF90h
    24d: call    ryo_h_MovW128
    252: mov     edi,0FFFFFF48h
    257: lea     rsi,[sym3]
    25e: call    ryo_h_AddrSym
    263: mov     rdi,rbp
    266: lea     rsi,[ro+20]
    26d: call    qword ptr [sym4]
    273: mov     edi,0FFFFFF88h
    278: mov     esi,0FFFFFF84h
    27d: call    ryo_h_TruncW32W16
    282: mov     edi,0FFFFFF8Ah
    287: mov     esi,0FFFFFF88h
    28c: call    ryo_h_NotW16
    291: movzx   eax,word ptr [rbp-76h]
    295: mov     [rbp-74h],ax
    299: mov     [rbp-72h],ax
    29d: mov     rdx,[rbp+10h]
    2a1: movzx   ecx,word ptr [rbp-72h]
    2a5: mov     [rdx+18h],cx
    2a9: mov     rsi,[rbp+10h]
    2ad: mov     rsi,[rsi+8]
    2b1: mov     [rbp-0B8h],rsi
    2b8: add     rsi,10h
    2bc: mov     [rbp-0C0h],rsi
    2c3: mov     rdi,[rbp+10h]
    2c7: mov     rcx,[rbp-0C0h]
    2ce: mov     [rdi+8],rcx
    2d2: jmp     10h

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: imul    rcx,[rbp+20h],1
     14: add     rax,rcx
     17: mov     [rbp-98h],rax
     1e: mov     rdx,[rbp+18h]
     22: mov     [rbp-0A0h],rdx
     29: mov     rsi,[rbp+18h]
     2d: mov     [rbp-0A8h],rsi
     34: mov     [rbp-0C0h],rsi
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
     c0: mov     rsi,[rbp+18h]
     c4: imul    rcx,[rbp-0B0h],1
     cc: add     rsi,rcx
     cf: mov     [rbp-60h],rsi
     d3: mov     [rbp-9Ah],ax
     da: mov     [rbp-8],ax
     de: mov     rdi,[rbp+10h]
     e2: mov     [rbp-20h],rdi
     e6: mov     [rbp-18h],rsi
     ea: mov     r8,[rbp-98h]
     f1: mov     [rbp-10h],r8
     f5: mov     edi,0FFFFFFE0h
     fa: mov     esi,20h
     ff: call    ryo_h_Ret
    104: leave
    105: ret

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
     74: .long   14ah
     78: .long   118h
     7c: .long   111h
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax+8]
     88: mov     [rbp-80h],rax
     8c: mov     rdx,[rbp+10h]
     90: mov     rdx,[rdx+10h]
     94: mov     [rbp-88h],rdx
     9b: cmp     rax,rdx
     9e: jb      0B0h
     a0: mov     qword ptr [rbp-8],0
     a8: jmp     100h
     aa: nop     [rax+rax]
     b0: mov     rax,[rbp+10h]
     b4: mov     rax,[rax+8]
     b8: mov     [rbp-28h],rax
     bc: mov     [rbp-80h],rax
     c0: mov     rdx,[rbp-28h]
     c4: mov     [rbp-88h],rdx
     cb: mov     [rbp-0D0h],rdx
     d2: mov     edi,0FFFFFF40h
     d7: lea     rsi,[sym0]
     de: call    ryo_h_AddrSym
     e3: mov     rdi,rbp
     e6: lea     rsi,[ro+4]
     ed: call    qword ptr [sym1]
     f3: jmp     303h
     f8: nop     [rax+rax]
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: call    ryo_h_Unreachable
    116: ud2
    118: movzx   eax,word ptr [rbp-92h]
    11f: mov     [rbp-94h],ax
    126: mov     [rbp-0AAh],ax
    12d: mov     edi,0FFFFFF44h
    132: mov     esi,0FFFFFF56h
    137: call    ryo_h_CttzW16
    13c: mov     eax,[rbp-0BCh]
    142: mov     [rbp-98h],eax
    148: jmp     193h
    14a: mov     edi,0FFFFFF70h
    14f: lea     rsi,[k2]
    156: mov     edx,10h
    15b: call    ryo_h_Const
    160: mov     qword ptr [rbp-88h],0
    16b: cmp     qword ptr [rbp-88h],0
    173: sete    [rbp-89h]
    17a: mov     byte ptr [rbp-0B9h],0
    181: test    byte ptr [rbp-0B9h],0FFh
    188: je      0B0h
    18e: jmp     80h
    193: mov     edi,0FFFFFF58h
    198: mov     esi,0FFFFFF68h
    19d: call    ryo_h_ZextW32W64
    1a2: mov     rax,[rbp-0A8h]
    1a9: mov     [rbp-88h],rax
    1b0: mov     qword ptr [rbp-90h],1
    1bb: mov     [rbp-48h],rax
    1bf: mov     rsi,[rbp+10h]
    1c3: movzx   esi,word ptr [rsi+18h]
    1c7: mov     [rbp-88h],si
    1ce: sub     esi,1
    1d1: mov     [rbp-86h],si
    1d8: movzx   edi,word ptr [rbp-88h]
    1df: and     di,[rbp-86h]
    1e6: mov     [rbp-84h],di
    1ed: movzx   r8d,word ptr [rbp-84h]
    1f5: mov     [rbp-82h],r8w
    1fd: mov     r9,[rbp+10h]
    201: movzx   ecx,word ptr [rbp-82h]
    208: mov     [r9+18h],cx
    20d: mov     r10,[rbp-48h]
    211: mov     [rbp-78h],r10
    215: mov     qword ptr [rbp-80h],1
    21d: mov     [rbp-88h],r10
    224: mov     byte ptr [rbp-0B9h],0
    22b: test    byte ptr [rbp-0B9h],0FFh
    232: je      263h
    234: mov     rsi,[rbp+10h]
    238: mov     rsi,[rsi]
    23b: mov     [rbp-0B8h],rsi
    242: mov     [rbp-0B0h],rsi
    249: mov     [rbp-0A8h],rsi
    250: add     rsi,r10
    253: mov     [rbp-0A0h],rsi
    25a: mov     [rbp-98h],rsi
    261: jmp     290h
    263: mov     rax,[rbp+10h]
    267: mov     rax,[rax]
    26a: mov     [rbp-0A8h],rax
    271: mov     [rbp-0A0h],rax
    278: mov     byte ptr [rbp-0B9h],0
    27f: test    byte ptr [rbp-0B9h],0FFh
    286: je      2C2h
    288: jmp     2B2h
    28a: nop     [rax+rax]
    290: mov     rax,[rbp-98h]
    297: mov     [rbp-0A0h],rax
    29e: mov     [rbp-90h],rax
    2a5: mov     [rbp-8],rax
    2a9: jmp     100h
    2ae: xchg    ax,ax
    2b0: jmp     290h
    2b2: mov     rax,[rbp-0A0h]
    2b9: mov     [rbp-98h],rax
    2c0: jmp     2B0h
    2c2: mov     rax,[rbp-88h]
    2c9: mov     [rbp-0B0h],rax
    2d0: mov     qword ptr [rbp-0C0h],0
    2db: mov     rsi,[rbp-0C0h]
    2e2: sub     rsi,rax
    2e5: mov     [rbp-0A8h],rsi
    2ec: mov     rdi,[rbp-0A0h]
    2f3: imul    rcx,rsi,20h
    2f7: add     rdi,rcx
    2fa: mov     [rbp-98h],rdi
    301: jmp     2B0h
    303: mov     edi,0FFFFFF30h
    308: mov     esi,0FFFFFF90h
    30d: call    ryo_h_MovW128
    312: mov     edi,0FFFFFF40h
    317: lea     rsi,[sym3]
    31e: call    ryo_h_AddrSym
    323: mov     rdi,rbp
    326: lea     rsi,[ro+20]
    32d: call    qword ptr [sym4]
    333: mov     edi,0FFFFFF88h
    338: mov     esi,0FFFFFF84h
    33d: call    ryo_h_TruncW32W16
    342: mov     edi,0FFFFFF8Ah
    347: mov     esi,0FFFFFF88h
    34c: call    ryo_h_NotW16
    351: movzx   eax,word ptr [rbp-76h]
    355: mov     [rbp-74h],ax
    359: mov     [rbp-72h],ax
    35d: mov     rdx,[rbp+10h]
    361: movzx   ecx,word ptr [rbp-72h]
    365: mov     [rdx+18h],cx
    369: mov     byte ptr [rbp-0B9h],0
    370: test    byte ptr [rbp-0B9h],0FFh
    377: je      3A6h
    379: mov     r8,[rbp+10h]
    37d: mov     r8,[r8]
    380: mov     [rbp-0A0h],r8
    387: mov     [rbp-98h],r8
    38e: mov     [rbp-90h],r8
    395: add     r8,10h
    399: mov     [rbp-88h],r8
    3a0: mov     [rbp-80h],r8
    3a4: jmp     3D0h
    3a6: mov     rax,[rbp+10h]
    3aa: mov     rax,[rax]
    3ad: mov     [rbp-90h],rax
    3b4: mov     [rbp-88h],rax
    3bb: mov     byte ptr [rbp-0B9h],0
    3c2: test    byte ptr [rbp-0B9h],0FFh
    3c9: je      43Fh
    3cb: jmp     432h
    3cd: nop     [rax]
    3d0: mov     rax,[rbp-80h]
    3d4: mov     [rbp-88h],rax
    3db: mov     [rbp-78h],rax
    3df: mov     rdx,[rbp+10h]
    3e3: mov     rcx,[rbp-78h]
    3e7: mov     [rdx],rcx
    3ea: mov     rsi,[rbp+10h]
    3ee: mov     rsi,[rsi+8]
    3f2: mov     [rbp-80h],rsi
    3f6: mov     qword ptr [rbp-0C0h],10h
    401: imul    rcx,[rbp-0C0h],1
    409: add     rsi,rcx
    40c: mov     [rbp-78h],rsi
    410: mov     r8,[rbp+10h]
    414: mov     rcx,[rbp-78h]
    418: mov     [r8+8],rcx
    41c: jmp     10h
    421: nop     [rax+rax]
    42a: nop     [rax+rax]
    430: jmp     3D0h
    432: mov     rax,[rbp-88h]
    439: mov     [rbp-80h],rax
    43d: jmp     430h
    43f: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    44a: mov     rdx,[rbp-88h]
    451: imul    rcx,[rbp-0C0h],20h
    459: add     rdx,rcx
    45c: mov     [rbp-80h],rdx
    460: jmp     430h

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
     84: mov     rdx,[rbp-0A0h]
     8b: mov     [rbp+38h],rdx
     8f: mov     rsi,[rbp+30h]
     93: sub     rsi,1
     97: mov     [rbp+30h],rsi
     9b: jmp     10h
     a0: mov     byte ptr [rbp-31h],0
     a4: mov     rdx,[rbp+38h]
     a8: mov     [rbp-8],rdx
     ac: jmp     0F7h
     ae: xchg    ax,ax
     b0: mov     rax,[rbp+18h]
     b4: mov     [rbp-28h],rax
     b8: mov     [rbp-88h],rax
     bf: mov     rdx,[rbp-28h]
     c3: mov     [rbp-90h],rdx
     ca: mov     [rbp-0E0h],rdx
     d1: mov     edi,0FFFFFF38h
     d6: lea     rsi,[sym0]
     dd: call    ryo_h_AddrSym
     e2: mov     rdi,rbp
     e5: lea     rsi,[ro+4]
     ec: call    qword ptr [sym1]
     f2: jmp     363h
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
    1a3: mov     rsi,[rbp+30h]
    1a7: mov     [rbp-80h],rsi
    1ab: cmp     rsi,0
    1af: je      0A0h
    1b5: jmp     0B0h
    1ba: mov     edi,0FFFFFF50h
    1bf: mov     esi,0FFFFFF60h
    1c4: call    ryo_h_ZextW32W64
    1c9: mov     rax,[rbp-0B0h]
    1d0: mov     [rbp-90h],rax
    1d7: mov     qword ptr [rbp-98h],1
    1e2: mov     [rbp-48h],rax
    1e6: movzx   esi,word ptr [rbp+28h]
    1ea: mov     [rbp-90h],si
    1f1: sub     esi,1
    1f4: mov     [rbp-8Eh],si
    1fb: movzx   edi,word ptr [rbp-90h]
    202: and     di,[rbp-8Eh]
    209: mov     [rbp-8Ch],di
    210: movzx   r8d,word ptr [rbp-8Ch]
    218: mov     [rbp-8Ah],r8w
    220: mov     [rbp+28h],r8w
    225: mov     [rbp-80h],rax
    229: mov     qword ptr [rbp-88h],1
    234: mov     [rbp-90h],rax
    23b: mov     byte ptr [rbp-0C1h],0
    242: test    byte ptr [rbp-0C1h],0FFh
    249: je      277h
    24b: mov     rdx,[rbp+10h]
    24f: mov     [rbp-0C0h],rdx
    256: mov     [rbp-0B8h],rdx
    25d: mov     [rbp-0B0h],rdx
    264: add     rdx,rax
    267: mov     [rbp-0A8h],rdx
    26e: mov     [rbp-0A0h],rdx
    275: jmp     2A0h
    277: mov     rax,[rbp+10h]
    27b: mov     [rbp-0B0h],rax
    282: mov     [rbp-0A8h],rax
    289: mov     byte ptr [rbp-0C1h],0
    290: test    byte ptr [rbp-0C1h],0FFh
    297: je      322h
    29d: jmp     312h
    29f: nop
    2a0: mov     rax,[rbp-0A0h]
    2a7: mov     [rbp-0A8h],rax
    2ae: mov     [rbp-98h],rax
    2b5: lea     rdx,[rbp+40h]
    2b9: mov     [rbp-0A8h],rdx
    2c0: mov     byte ptr [rbp-31h],0
    2c4: mov     rdi,[rbp+38h]
    2c8: mov     [rbp-0C0h],rdi
    2cf: mov     [rbp-0B8h],rdi
    2d6: mov     [rbp-0B0h],rax
    2dd: mov     [rbp-0E0h],rdx
    2e4: mov     [rbp-0D8h],rdi
    2eb: mov     [rbp-0D0h],rax
    2f2: call    fn3
    2f7: nop     [rcx-0A0h]
    2fe: jmp     80h
    303: nop     [rax+rax]
    30c: nop     [rax]
    310: jmp     2A0h
    312: mov     rax,[rbp-0A8h]
    319: mov     [rbp-0A0h],rax
    320: jmp     310h
    322: mov     rax,[rbp-90h]
    329: mov     [rbp-0B8h],rax
    330: mov     qword ptr [rbp-0C8h],0
    33b: mov     rsi,[rbp-0C8h]
    342: sub     rsi,rax
    345: mov     [rbp-0B0h],rsi
    34c: mov     rdi,[rbp-0A8h]
    353: imul    rcx,rsi,10h
    357: add     rdi,rcx
    35a: mov     [rbp-0A0h],rdi
    361: jmp     310h
    363: mov     edi,0FFFFFF20h
    368: mov     esi,0FFFFFF90h
    36d: call    ryo_h_MovW128
    372: mov     edi,0FFFFFF38h
    377: lea     rsi,[sym4]
    37e: call    ryo_h_AddrSym
    383: mov     rdi,rbp
    386: lea     rsi,[ro+20]
    38d: call    qword ptr [sym5]
    393: mov     edi,0FFFFFF80h
    398: mov     esi,0FFFFFF7Ch
    39d: call    ryo_h_TruncW32W16
    3a2: mov     edi,0FFFFFF82h
    3a7: mov     esi,0FFFFFF80h
    3ac: call    ryo_h_NotW16
    3b1: movzx   eax,word ptr [rbp-7Eh]
    3b5: mov     [rbp-7Ch],ax
    3b9: mov     [rbp-7Ah],ax
    3bd: mov     [rbp+28h],ax
    3c1: mov     byte ptr [rbp-0C1h],0
    3c8: test    byte ptr [rbp-0C1h],0FFh
    3cf: je      3FEh
    3d1: mov     rdi,[rbp+10h]
    3d5: mov     [rbp-0A8h],rdi
    3dc: mov     [rbp-0A0h],rdi
    3e3: mov     [rbp-98h],rdi
    3ea: add     rdi,10h
    3ee: mov     [rbp-90h],rdi
    3f5: mov     [rbp-88h],rdi
    3fc: jmp     430h
    3fe: mov     rax,[rbp+10h]
    402: mov     [rbp-98h],rax
    409: mov     [rbp-90h],rax
    410: mov     byte ptr [rbp-0C1h],0
    417: test    byte ptr [rbp-0C1h],0FFh
    41e: je      492h
    420: jmp     482h
    422: nop     [rax+rax]
    42b: nop     [rax+rax]
    430: mov     rax,[rbp-88h]
    437: mov     [rbp-90h],rax
    43e: mov     [rbp-80h],rax
    442: mov     [rbp+10h],rax
    446: mov     rdx,[rbp+18h]
    44a: mov     [rbp-88h],rdx
    451: mov     qword ptr [rbp-0C8h],10h
    45c: imul    rcx,[rbp-0C8h],1
    464: add     rdx,rcx
    467: mov     [rbp-80h],rdx
    46b: mov     [rbp+18h],rdx
    46f: jmp     10h
    474: nop     [rax+rax]
    47d: nop     [rax]
    480: jmp     430h
    482: mov     rax,[rbp-90h]
    489: mov     [rbp-88h],rax
    490: jmp     480h
    492: mov     qword ptr [rbp-0C8h],0FFFFFFFFFFFFFFF0h
    49d: mov     rdx,[rbp-90h]
    4a4: imul    rcx,[rbp-0C8h],10h
    4ac: add     rdx,rcx
    4af: mov     [rbp-88h],rdx
    4b6: jmp     480h
    4b8: mov     rdi,rax
    4bb: mov     esi,0FFFFFF88h
    4c0: call    ryo_h_Lpad
    4c5: jmp     110h

fn hashbrown::raw::RawIterRange::<(u64, u64)>::new
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: imul    rcx,[rbp+20h],1
     14: add     rax,rcx
     17: mov     [rbp-98h],rax
     1e: mov     rdx,[rbp+18h]
     22: mov     [rbp-0A0h],rdx
     29: mov     rsi,[rbp+18h]
     2d: mov     [rbp-0A8h],rsi
     34: mov     [rbp-0C0h],rsi
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
     c0: mov     rsi,[rbp+18h]
     c4: imul    rcx,[rbp-0B0h],1
     cc: add     rsi,rcx
     cf: mov     [rbp-60h],rsi
     d3: mov     [rbp-9Ah],ax
     da: mov     [rbp-8],ax
     de: mov     rdi,[rbp+10h]
     e2: mov     [rbp-20h],rdi
     e6: mov     [rbp-18h],rsi
     ea: mov     r8,[rbp-98h]
     f1: mov     [rbp-10h],r8
     f5: mov     edi,0FFFFFFE0h
     fa: mov     esi,20h
     ff: call    ryo_h_Ret
    104: leave
    105: ret

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
     74: .long   14ah
     78: .long   118h
     7c: .long   111h
     80: mov     rax,[rbp+10h]
     84: mov     rax,[rax+8]
     88: mov     [rbp-80h],rax
     8c: mov     rdx,[rbp+10h]
     90: mov     rdx,[rdx+10h]
     94: mov     [rbp-88h],rdx
     9b: cmp     rax,rdx
     9e: jb      0B0h
     a0: mov     qword ptr [rbp-8],0
     a8: jmp     100h
     aa: nop     [rax+rax]
     b0: mov     rax,[rbp+10h]
     b4: mov     rax,[rax+8]
     b8: mov     [rbp-28h],rax
     bc: mov     [rbp-80h],rax
     c0: mov     rdx,[rbp-28h]
     c4: mov     [rbp-88h],rdx
     cb: mov     [rbp-0D0h],rdx
     d2: mov     edi,0FFFFFF40h
     d7: lea     rsi,[sym0]
     de: call    ryo_h_AddrSym
     e3: mov     rdi,rbp
     e6: lea     rsi,[ro+4]
     ed: call    qword ptr [sym1]
     f3: jmp     303h
     f8: nop     [rax+rax]
    100: mov     edi,0FFFFFFF8h
    105: mov     esi,8
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: call    ryo_h_Unreachable
    116: ud2
    118: movzx   eax,word ptr [rbp-92h]
    11f: mov     [rbp-94h],ax
    126: mov     [rbp-0AAh],ax
    12d: mov     edi,0FFFFFF44h
    132: mov     esi,0FFFFFF56h
    137: call    ryo_h_CttzW16
    13c: mov     eax,[rbp-0BCh]
    142: mov     [rbp-98h],eax
    148: jmp     193h
    14a: mov     edi,0FFFFFF70h
    14f: lea     rsi,[k2]
    156: mov     edx,10h
    15b: call    ryo_h_Const
    160: mov     qword ptr [rbp-88h],0
    16b: cmp     qword ptr [rbp-88h],0
    173: sete    [rbp-89h]
    17a: mov     byte ptr [rbp-0B9h],0
    181: test    byte ptr [rbp-0B9h],0FFh
    188: je      0B0h
    18e: jmp     80h
    193: mov     edi,0FFFFFF58h
    198: mov     esi,0FFFFFF68h
    19d: call    ryo_h_ZextW32W64
    1a2: mov     rax,[rbp-0A8h]
    1a9: mov     [rbp-88h],rax
    1b0: mov     qword ptr [rbp-90h],1
    1bb: mov     [rbp-48h],rax
    1bf: mov     rsi,[rbp+10h]
    1c3: movzx   esi,word ptr [rsi+18h]
    1c7: mov     [rbp-88h],si
    1ce: sub     esi,1
    1d1: mov     [rbp-86h],si
    1d8: movzx   edi,word ptr [rbp-88h]
    1df: and     di,[rbp-86h]
    1e6: mov     [rbp-84h],di
    1ed: movzx   r8d,word ptr [rbp-84h]
    1f5: mov     [rbp-82h],r8w
    1fd: mov     r9,[rbp+10h]
    201: movzx   ecx,word ptr [rbp-82h]
    208: mov     [r9+18h],cx
    20d: mov     r10,[rbp-48h]
    211: mov     [rbp-78h],r10
    215: mov     qword ptr [rbp-80h],1
    21d: mov     [rbp-88h],r10
    224: mov     byte ptr [rbp-0B9h],0
    22b: test    byte ptr [rbp-0B9h],0FFh
    232: je      263h
    234: mov     rsi,[rbp+10h]
    238: mov     rsi,[rsi]
    23b: mov     [rbp-0B8h],rsi
    242: mov     [rbp-0B0h],rsi
    249: mov     [rbp-0A8h],rsi
    250: add     rsi,r10
    253: mov     [rbp-0A0h],rsi
    25a: mov     [rbp-98h],rsi
    261: jmp     290h
    263: mov     rax,[rbp+10h]
    267: mov     rax,[rax]
    26a: mov     [rbp-0A8h],rax
    271: mov     [rbp-0A0h],rax
    278: mov     byte ptr [rbp-0B9h],0
    27f: test    byte ptr [rbp-0B9h],0FFh
    286: je      2C2h
    288: jmp     2B2h
    28a: nop     [rax+rax]
    290: mov     rax,[rbp-98h]
    297: mov     [rbp-0A0h],rax
    29e: mov     [rbp-90h],rax
    2a5: mov     [rbp-8],rax
    2a9: jmp     100h
    2ae: xchg    ax,ax
    2b0: jmp     290h
    2b2: mov     rax,[rbp-0A0h]
    2b9: mov     [rbp-98h],rax
    2c0: jmp     2B0h
    2c2: mov     rax,[rbp-88h]
    2c9: mov     [rbp-0B0h],rax
    2d0: mov     qword ptr [rbp-0C0h],0
    2db: mov     rsi,[rbp-0C0h]
    2e2: sub     rsi,rax
    2e5: mov     [rbp-0A8h],rsi
    2ec: mov     rdi,[rbp-0A0h]
    2f3: imul    rcx,rsi,10h
    2f7: add     rdi,rcx
    2fa: mov     [rbp-98h],rdi
    301: jmp     2B0h
    303: mov     edi,0FFFFFF30h
    308: mov     esi,0FFFFFF90h
    30d: call    ryo_h_MovW128
    312: mov     edi,0FFFFFF40h
    317: lea     rsi,[sym3]
    31e: call    ryo_h_AddrSym
    323: mov     rdi,rbp
    326: lea     rsi,[ro+20]
    32d: call    qword ptr [sym4]
    333: mov     edi,0FFFFFF88h
    338: mov     esi,0FFFFFF84h
    33d: call    ryo_h_TruncW32W16
    342: mov     edi,0FFFFFF8Ah
    347: mov     esi,0FFFFFF88h
    34c: call    ryo_h_NotW16
    351: movzx   eax,word ptr [rbp-76h]
    355: mov     [rbp-74h],ax
    359: mov     [rbp-72h],ax
    35d: mov     rdx,[rbp+10h]
    361: movzx   ecx,word ptr [rbp-72h]
    365: mov     [rdx+18h],cx
    369: mov     byte ptr [rbp-0B9h],0
    370: test    byte ptr [rbp-0B9h],0FFh
    377: je      3A6h
    379: mov     r8,[rbp+10h]
    37d: mov     r8,[r8]
    380: mov     [rbp-0A0h],r8
    387: mov     [rbp-98h],r8
    38e: mov     [rbp-90h],r8
    395: add     r8,10h
    399: mov     [rbp-88h],r8
    3a0: mov     [rbp-80h],r8
    3a4: jmp     3D0h
    3a6: mov     rax,[rbp+10h]
    3aa: mov     rax,[rax]
    3ad: mov     [rbp-90h],rax
    3b4: mov     [rbp-88h],rax
    3bb: mov     byte ptr [rbp-0B9h],0
    3c2: test    byte ptr [rbp-0B9h],0FFh
    3c9: je      43Fh
    3cb: jmp     432h
    3cd: nop     [rax]
    3d0: mov     rax,[rbp-80h]
    3d4: mov     [rbp-88h],rax
    3db: mov     [rbp-78h],rax
    3df: mov     rdx,[rbp+10h]
    3e3: mov     rcx,[rbp-78h]
    3e7: mov     [rdx],rcx
    3ea: mov     rsi,[rbp+10h]
    3ee: mov     rsi,[rsi+8]
    3f2: mov     [rbp-80h],rsi
    3f6: mov     qword ptr [rbp-0C0h],10h
    401: imul    rcx,[rbp-0C0h],1
    409: add     rsi,rcx
    40c: mov     [rbp-78h],rsi
    410: mov     r8,[rbp+10h]
    414: mov     rcx,[rbp-78h]
    418: mov     [r8+8],rcx
    41c: jmp     10h
    421: nop     [rax+rax]
    42a: nop     [rax+rax]
    430: jmp     3D0h
    432: mov     rax,[rbp-88h]
    439: mov     [rbp-80h],rax
    43d: jmp     430h
    43f: mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    44a: mov     rdx,[rbp-88h]
    451: imul    rcx,[rbp-0C0h],10h
    459: add     rdx,rcx
    45c: mov     [rbp-80h],rdx
    460: jmp     430h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rdx,[rbp+20h]
     17: mov     [rbp-80h],rdx
     1b: mov     [rbp-78h],rdx
     1f: mov     rsi,[rbp+10h]
     23: mov     [rbp-70h],rsi
     27: lea     rdi,[rbp-78h]
     2b: mov     [rbp-68h],rdi
     2f: mov     [rbp-60h],rdi
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rdx,[rbp+18h]
     53: mov     [rbp-0A8h],rdx
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
     c5: mov     rdx,[rbp+10h]
     c9: mov     rdx,[rdx]
     cc: mov     [rbp-68h],rdx
     d0: mov     [rbp-60h],rdx
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
    192: mov     rsi,[rbp-90h]
    199: sub     rsi,rax
    19c: mov     [rbp-80h],rsi
    1a0: mov     rdi,[rbp-78h]
    1a4: imul    rcx,rsi,20h
    1a8: add     rdi,rcx
    1ab: mov     [rbp-70h],rdi
    1af: jmp     170h
    1b1: mov     rdi,rax
    1b4: mov     esi,0FFFFFFC8h
    1b9: call    ryo_h_Lpad
    1be: jmp     110h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rdx,[rbp+10h]
     1a: mov     rdx,[rdx+8]
     1e: mov     [rbp-20h],rdx
     22: mov     rdx,[rdx]
     25: mov     [rbp-68h],rdx
     29: mov     [rbp-60h],rdx
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
     96: je      139h
     9c: jmp     12Fh
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rsi,[rbp-90h]
     d9: sub     rsi,rax
     dc: mov     [rbp-80h],rsi
     e0: mov     rdi,[rbp-78h]
     e4: imul    rcx,rsi,20h
     e8: add     rdi,rcx
     eb: mov     [rbp-70h],rdi
     ef: jmp     0B0h
     f1: nop     [rax+rax]
     fa: nop     [rax+rax]
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rdx,[rbp-18h]
    110: mov     [rbp-0A0h],rdx
    117: mov     [rbp-98h],rax
    11e: call    fn0
    123: nop     [rcx-1]
    12a: jmp     40h
    12f: mov     qword ptr [rbp-60h],8
    137: jmp     100h
    139: mov     rax,[rbp-48h]
    13d: mov     [rbp-68h],rax
    141: mov     byte ptr [rbp-89h],0
    148: test    byte ptr [rbp-89h],0FFh
    14f: je      16Ch
    151: jmp     162h
    153: nop     [rax+rax]
    15c: nop     [rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rdx,[rbp-68h]
    17b: imul    rcx,[rbp-90h],20h
    183: add     rdx,rcx
    186: mov     [rbp-60h],rdx
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     [rbp-0B0h],rax
     1a: mov     rdx,[rbp+18h]
     1e: mov     [rbp-0A8h],rdx
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
     95: mov     rdx,[rbp+18h]
     99: shr     rdx,39h
     9d: mov     [rbp-70h],rdx
     a1: and     rdx,7Fh
     a5: mov     [rbp-78h],rdx
     a9: mov     edi,0FFFFFF9Eh
     ae: mov     esi,0FFFFFF88h
     b3: call    ryo_h_TruncW64W8
     b8: movzx   eax,byte ptr [rbp-62h]
     bc: mov     [rbp-61h],al
     bf: mov     rdx,[rbp-28h]
     c3: sub     rdx,10h
     c7: mov     [rbp-80h],rdx
     cb: mov     rsi,[rbp+10h]
     cf: mov     rsi,[rsi+8]
     d3: mov     [rbp-88h],rsi
     da: and     rdx,rsi
     dd: mov     [rbp-78h],rdx
     e1: add     rdx,10h
     e5: mov     [rbp-70h],rdx
     e9: mov     rdi,[rbp+10h]
     ed: mov     rdi,[rdi]
     f0: mov     [rbp-90h],rdi
     f7: mov     [rbp-88h],rdi
     fe: imul    rcx,[rbp-28h],1
    103: add     rdi,rcx
    106: mov     [rbp-80h],rdi
    10a: mov     [rbp-78h],rdi
    10e: movzx   ecx,byte ptr [rbp-61h]
    112: mov     [rdi],cl
    114: mov     r8,[rbp+10h]
    118: mov     r8,[r8]
    11b: mov     [rbp-90h],r8
    122: mov     [rbp-88h],r8
    129: imul    rcx,[rbp-70h],1
    12e: add     r8,rcx
    131: mov     [rbp-80h],r8
    135: mov     [rbp-78h],r8
    139: movzx   ecx,byte ptr [rbp-61h]
    13d: mov     [r8],cl
    140: mov     r9,[rbp+10h]
    144: mov     r9,[r9]
    147: mov     [rbp-70h],r9
    14b: mov     [rbp-68h],r9
    14f: mov     byte ptr [rbp-91h],0
    156: test    byte ptr [rbp-91h],0FFh
    15d: je      171h
    15f: mov     rax,[rbp-28h]
    163: add     rax,1
    167: mov     [rbp-80h],rax
    16b: mov     [rbp-78h],rax
    16f: jmp     1A0h
    171: mov     rax,[rbp-70h]
    175: mov     [rbp-80h],rax
    179: mov     byte ptr [rbp-91h],0
    180: test    byte ptr [rbp-91h],0FFh
    187: je      23Fh
    18d: jmp     235h
    192: nop     [rax+rax]
    19b: nop     [rax+rax]
    1a0: mov     rax,[rbp-78h]
    1a4: mov     [rbp-50h],rax
    1a8: mov     [rbp-8],rax
    1ac: movzx   edx,byte ptr [rbp-51h]
    1b0: and     dl,1
    1b3: mov     [rbp-6Ah],dl
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
    1e7: mov     rdx,[rbp+10h]
    1eb: mov     rcx,[rbp-0A0h]
    1f2: mov     [rdx+10h],rcx
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
    255: mov     rsi,[rbp-98h]
    25c: sub     rsi,rax
    25f: mov     [rbp-88h],rsi
    266: mov     rdi,[rbp-80h]
    26a: imul    rcx,rsi,20h
    26e: add     rdi,rcx
    271: mov     [rbp-78h],rdi
    275: jmp     230h
    277: nop     [rax+rax]
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
    2b0: mov     rdx,[rbp+10h]
    2b4: mov     rcx,[rbp-0A0h]
    2bb: mov     [rdx+18h],rcx
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
    320: mov     rdx,[rbp-90h]
    327: imul    rcx,[rbp-98h],20h
    32f: add     rdx,rcx
    332: mov     [rbp-88h],rdx
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
     20: je      0DDh
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
     ac: mov     rdx,[rbp+20h]
     b0: mov     [rbp-40h],rdx
     b4: mov     rsi,[rbp+10h]
     b8: mov     [rbp-70h],rsi
     bc: mov     rdi,[rbp+18h]
     c0: mov     [rbp-60h],rdi
     c4: mov     [rbp-68h],rdx
     c8: mov     byte ptr [rbp-58h],1
     cc: call    fn0
     d1: nop     [rcx-38h]
     d8: jmp     30h
     dd: jmp     70h
     df: mov     rdi,rax
     e2: mov     esi,0FFFFFFD8h
     e7: call    ryo_h_Lpad
     ec: jmp     0A0h

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: mov     rdx,[rbp+10h]
     17: lea     rdx,[rdx+20h]
     1b: mov     [rbp-28h],rdx
     1f: lea     rsi,[rbp+18h]
     23: mov     [rbp-50h],rsi
     27: mov     [rbp-48h],rsi
     2b: lea     rdi,[rbp-48h]
     2f: mov     [rbp-40h],rdi
     33: mov     [rbp-38h],rdi
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
     80: mov     rdx,[rbp-28h]
     84: mov     [rbp-0A8h],rdx
     8b: mov     rsi,[rbp+20h]
     8f: mov     [rbp-90h],rsi
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
     16: mov     rdx,[rbp+18h]
     1a: mov     rdx,[rdx]
     1d: mov     [rbp-60h],rdx
     21: mov     [rbp-58h],rdx
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
     96: je      119h
     9c: jmp     10Fh
     9e: xchg    ax,ax
     a0: jmp     80h
     a2: mov     rax,[rbp-70h]
     a6: mov     [rbp-68h],rax
     aa: jmp     0A0h
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-80h],rax
     b4: mov     qword ptr [rbp-88h],0
     bf: mov     rsi,[rbp-88h]
     c6: sub     rsi,rax
     c9: mov     [rbp-78h],rsi
     cd: mov     rdi,[rbp-70h]
     d1: imul    rcx,rsi,20h
     d5: add     rdi,rcx
     d8: mov     [rbp-68h],rdi
     dc: jmp     0A0h
     de: xchg    ax,ax
     e0: mov     rax,[rbp-58h]
     e4: mov     [rbp-50h],rax
     e8: mov     [rbp-48h],rax
     ec: mov     rdx,[rbp-18h]
     f0: mov     [rbp-0A0h],rdx
     f7: mov     [rbp-98h],rax
     fe: call    fn0
    103: nop     [rcx-8]
    10a: jmp     40h
    10f: mov     qword ptr [rbp-58h],8
    117: jmp     0E0h
    119: mov     rax,[rbp-40h]
    11d: mov     [rbp-60h],rax
    121: mov     byte ptr [rbp-81h],0
    128: test    byte ptr [rbp-81h],0FFh
    12f: je      14Ch
    131: jmp     142h
    133: nop     [rax+rax]
    13c: nop     [rax]
    140: jmp     0E0h
    142: mov     rax,[rbp-60h]
    146: mov     [rbp-58h],rax
    14a: jmp     140h
    14c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    157: mov     rdx,[rbp-60h]
    15b: imul    rcx,[rbp-88h],20h
    163: add     rdx,rcx
    166: mov     [rbp-58h],rdx
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
     10: mov     rdx,[rbp+10h]
     14: mov     [rbp-40h],rdx
     18: mov     [rbp-38h],rax
     1c: call    fn0
     21: nop     [rcx]
     28: mov     byte ptr [rbp-21h],0
     2c: test    byte ptr [rbp-21h],0FFh
     30: je      79h
     32: jmp     6Fh
     34: nop     [rax+rax]
     3d: nop     [rax]
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
     b4: mov     rdx,[rbp-18h]
     b8: imul    rcx,[rbp-28h],10h
     bd: add     rdx,rcx
     c0: mov     [rbp-10h],rdx
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
     4c: mov     rdx,[rbp-8]
     50: mov     [rbp-58h],rdx
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
     87: mov     rdx,[rbp+18h]
     8b: mov     rdx,[rdx]
     8e: mov     [rbp-30h],rdx
     92: mov     [rbp-28h],rdx
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
     c2: mov     rdx,[rbp-40h]
     c6: mov     rcx,7FFFFFFFFFFFFFFFh
     d0: cmp     rdx,rcx
     d3: setbe   [rbp-32h]
     d7: test    byte ptr [rbp-32h],0FFh
     db: je      107h
     dd: mov     rdi,[rbp-20h]
     e1: sub     rdi,[rbp-28h]
     e5: mov     [rbp-30h],rdi
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
     13: lea     rdx,[rbp+20h]
     17: mov     [rbp-80h],rdx
     1b: mov     [rbp-78h],rdx
     1f: mov     rsi,[rbp+10h]
     23: mov     [rbp-70h],rsi
     27: lea     rdi,[rbp-78h]
     2b: mov     [rbp-68h],rdi
     2f: mov     [rbp-60h],rdi
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rdx,[rbp+18h]
     53: mov     [rbp-0A8h],rdx
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
     c5: mov     rdx,[rbp+10h]
     c9: mov     rdx,[rdx]
     cc: mov     [rbp-68h],rdx
     d0: mov     [rbp-60h],rdx
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
    192: mov     rsi,[rbp-90h]
    199: sub     rsi,rax
    19c: mov     [rbp-80h],rsi
    1a0: mov     rdi,[rbp-78h]
    1a4: imul    rcx,rsi,10h
    1a8: add     rdi,rcx
    1ab: mov     [rbp-70h],rdi
    1af: jmp     170h
    1b1: mov     rdi,rax
    1b4: mov     esi,0FFFFFFC8h
    1b9: call    ryo_h_Lpad
    1be: jmp     110h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rdx,[rbp+10h]
     1a: mov     rdx,[rdx+8]
     1e: mov     [rbp-20h],rdx
     22: mov     rdx,[rdx]
     25: mov     [rbp-68h],rdx
     29: mov     [rbp-60h],rdx
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
     96: je      139h
     9c: jmp     12Fh
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rsi,[rbp-90h]
     d9: sub     rsi,rax
     dc: mov     [rbp-80h],rsi
     e0: mov     rdi,[rbp-78h]
     e4: imul    rcx,rsi,10h
     e8: add     rdi,rcx
     eb: mov     [rbp-70h],rdi
     ef: jmp     0B0h
     f1: nop     [rax+rax]
     fa: nop     [rax+rax]
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rdx,[rbp-18h]
    110: mov     [rbp-0A0h],rdx
    117: mov     [rbp-98h],rax
    11e: call    fn0
    123: nop     [rcx-1]
    12a: jmp     40h
    12f: mov     qword ptr [rbp-60h],8
    137: jmp     100h
    139: mov     rax,[rbp-48h]
    13d: mov     [rbp-68h],rax
    141: mov     byte ptr [rbp-89h],0
    148: test    byte ptr [rbp-89h],0FFh
    14f: je      16Ch
    151: jmp     162h
    153: nop     [rax+rax]
    15c: nop     [rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rdx,[rbp-68h]
    17b: imul    rcx,[rbp-90h],10h
    183: add     rdx,rcx
    186: mov     [rbp-60h],rdx
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-50h],rax
     13: lea     rdx,[rbp+20h]
     17: mov     [rbp-80h],rdx
     1b: mov     [rbp-78h],rdx
     1f: mov     rsi,[rbp+10h]
     23: mov     [rbp-70h],rsi
     27: lea     rdi,[rbp-78h]
     2b: mov     [rbp-68h],rdi
     2f: mov     [rbp-60h],rdi
     33: mov     edi,0FFFFFFA8h
     38: lea     rsi,[k0]
     3f: call    ryo_h_AddrAbs
     44: mov     rax,[rbp-50h]
     48: mov     [rbp-0B0h],rax
     4f: mov     rdx,[rbp+18h]
     53: mov     [rbp-0A8h],rdx
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
     c5: mov     rdx,[rbp+10h]
     c9: mov     rdx,[rdx]
     cc: mov     [rbp-68h],rdx
     d0: mov     [rbp-60h],rdx
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
    192: mov     rsi,[rbp-90h]
    199: sub     rsi,rax
    19c: mov     [rbp-80h],rsi
    1a0: mov     rdi,[rbp-78h]
    1a4: imul    rcx,rsi,10h
    1a8: add     rdi,rcx
    1ab: mov     [rbp-70h],rdi
    1af: jmp     170h
    1b1: mov     rdi,rax
    1b4: mov     esi,0FFFFFFC8h
    1b9: call    ryo_h_Lpad
    1be: jmp     110h

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0A0h
      b: mov     rax,[rbp+10h]
      f: mov     rax,[rax]
     12: mov     [rbp-18h],rax
     16: mov     rdx,[rbp+10h]
     1a: mov     rdx,[rdx+8]
     1e: mov     [rbp-20h],rdx
     22: mov     rdx,[rdx]
     25: mov     [rbp-68h],rdx
     29: mov     [rbp-60h],rdx
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
     96: je      139h
     9c: jmp     12Fh
     a1: nop     [rax+rax]
     aa: nop     [rax+rax]
     b0: jmp     80h
     b2: mov     rax,[rbp-78h]
     b6: mov     [rbp-70h],rax
     ba: jmp     0B0h
     bc: mov     rax,[rbp+18h]
     c0: mov     [rbp-88h],rax
     c7: mov     qword ptr [rbp-90h],0
     d2: mov     rsi,[rbp-90h]
     d9: sub     rsi,rax
     dc: mov     [rbp-80h],rsi
     e0: mov     rdi,[rbp-78h]
     e4: imul    rcx,rsi,10h
     e8: add     rdi,rcx
     eb: mov     [rbp-70h],rdi
     ef: jmp     0B0h
     f1: nop     [rax+rax]
     fa: nop     [rax+rax]
    100: mov     rax,[rbp-60h]
    104: mov     [rbp-58h],rax
    108: mov     [rbp-50h],rax
    10c: mov     rdx,[rbp-18h]
    110: mov     [rbp-0A0h],rdx
    117: mov     [rbp-98h],rax
    11e: call    fn0
    123: nop     [rcx-1]
    12a: jmp     40h
    12f: mov     qword ptr [rbp-60h],8
    137: jmp     100h
    139: mov     rax,[rbp-48h]
    13d: mov     [rbp-68h],rax
    141: mov     byte ptr [rbp-89h],0
    148: test    byte ptr [rbp-89h],0FFh
    14f: je      16Ch
    151: jmp     162h
    153: nop     [rax+rax]
    15c: nop     [rax]
    160: jmp     100h
    162: mov     rax,[rbp-68h]
    166: mov     [rbp-60h],rax
    16a: jmp     160h
    16c: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    177: mov     rdx,[rbp-68h]
    17b: imul    rcx,[rbp-90h],10h
    183: add     rdx,rcx
    186: mov     [rbp-60h],rdx
    18a: jmp     160h

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-68h],rax
     13: mov     [rbp-0B0h],rax
     1a: mov     rdx,[rbp+18h]
     1e: mov     [rbp-0A8h],rdx
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
     77: mov     rdx,[rbp+18h]
     7b: shr     rdx,39h
     7f: mov     [rbp-70h],rdx
     83: and     rdx,7Fh
     87: mov     [rbp-78h],rdx
     8b: mov     edi,0FFFFFF9Eh
     90: mov     esi,0FFFFFF88h
     95: call    ryo_h_TruncW64W8
     9a: movzx   eax,byte ptr [rbp-62h]
     9e: mov     [rbp-61h],al
     a1: mov     rdx,[rbp-28h]
     a5: sub     rdx,10h
     a9: mov     [rbp-80h],rdx
     ad: mov     rsi,[rbp+10h]
     b1: mov     rsi,[rsi+8]
     b5: mov     [rbp-88h],rsi
     bc: and     rdx,rsi
     bf: mov     [rbp-78h],rdx
     c3: add     rdx,10h
     c7: mov     [rbp-70h],rdx
     cb: mov     rdi,[rbp+10h]
     cf: mov     rdi,[rdi]
     d2: mov     [rbp-90h],rdi
     d9: mov     [rbp-88h],rdi
     e0: imul    rcx,[rbp-28h],1
     e5: add     rdi,rcx
     e8: mov     [rbp-80h],rdi
     ec: mov     [rbp-78h],rdi
     f0: movzx   ecx,byte ptr [rbp-61h]
     f4: mov     [rdi],cl
     f6: mov     r8,[rbp+10h]
     fa: mov     r8,[r8]
     fd: mov     [rbp-90h],r8
    104: mov     [rbp-88h],r8
    10b: imul    rcx,[rbp-70h],1
    110: add     r8,rcx
    113: mov     [rbp-80h],r8
    117: mov     [rbp-78h],r8
    11b: movzx   ecx,byte ptr [rbp-61h]
    11f: mov     [r8],cl
    122: mov     r9,[rbp+10h]
    126: mov     r9,[r9]
    129: mov     [rbp-70h],r9
    12d: mov     [rbp-68h],r9
    131: mov     byte ptr [rbp-91h],0
    138: test    byte ptr [rbp-91h],0FFh
    13f: je      153h
    141: mov     rax,[rbp-28h]
    145: add     rax,1
    149: mov     [rbp-80h],rax
    14d: mov     [rbp-78h],rax
    151: jmp     180h
    153: mov     rax,[rbp-70h]
    157: mov     [rbp-80h],rax
    15b: mov     byte ptr [rbp-91h],0
    162: test    byte ptr [rbp-91h],0FFh
    169: je      20Fh
    16f: jmp     205h
    174: nop     [rax+rax]
    17d: nop     [rax]
    180: mov     rax,[rbp-78h]
    184: mov     [rbp-50h],rax
    188: mov     [rbp-8],rax
    18c: movzx   edx,byte ptr [rbp-51h]
    190: and     dl,1
    193: mov     [rbp-6Ah],dl
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
    1c7: mov     rdx,[rbp+10h]
    1cb: mov     rcx,[rbp-0A0h]
    1d2: mov     [rdx+10h],rcx
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
    225: mov     rsi,[rbp-98h]
    22c: sub     rsi,rax
    22f: mov     [rbp-88h],rsi
    236: mov     rdi,[rbp-80h]
    23a: imul    rcx,rsi,10h
    23e: add     rdi,rcx
    241: mov     [rbp-78h],rdi
    245: jmp     200h
    247: nop     [rax+rax]
    250: mov     edi,0FFFFFF88h
    255: xor     esi,esi
    257: mov     edx,0FFFFFF90h
    25c: call    ryo_h_StoreW128
    261: mov     rax,[rbp+10h]
    265: mov     rax,[rax+18h]
    269: mov     [rbp-98h],rax
    270: add     rax,1
    274: mov     [rbp-0A0h],rax
    27b: mov     rdx,[rbp+10h]
    27f: mov     rcx,[rbp-0A0h]
    286: mov     [rdx+18h],rcx
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
    2d7: mov     rdx,[rbp-80h]
    2db: imul    rcx,[rbp-98h],10h
    2e3: add     rdx,rcx
    2e6: mov     [rbp-78h],rdx
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
     20: je      0DDh
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
     ac: mov     rdx,[rbp+20h]
     b0: mov     [rbp-40h],rdx
     b4: mov     rsi,[rbp+10h]
     b8: mov     [rbp-70h],rsi
     bc: mov     rdi,[rbp+18h]
     c0: mov     [rbp-60h],rdi
     c4: mov     [rbp-68h],rdx
     c8: mov     byte ptr [rbp-58h],1
     cc: call    fn0
     d1: nop     [rcx-38h]
     d8: jmp     30h
     dd: jmp     70h
     df: mov     rdi,rax
     e2: mov     esi,0FFFFFFD8h
     e7: call    ryo_h_Lpad
     ec: jmp     0A0h

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-20h],rax
     13: mov     rdx,[rbp+10h]
     17: lea     rdx,[rdx+20h]
     1b: mov     [rbp-28h],rdx
     1f: lea     rsi,[rbp+18h]
     23: mov     [rbp-50h],rsi
     27: mov     [rbp-48h],rsi
     2b: lea     rdi,[rbp-48h]
     2f: mov     [rbp-40h],rdi
     33: mov     [rbp-38h],rdi
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
     80: mov     rdx,[rbp-28h]
     84: mov     [rbp-0A8h],rdx
     8b: mov     rsi,[rbp+20h]
     8f: mov     [rbp-90h],rsi
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
     16: mov     rdx,[rbp+18h]
     1a: mov     rdx,[rdx]
     1d: mov     [rbp-60h],rdx
     21: mov     [rbp-58h],rdx
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
     96: je      119h
     9c: jmp     10Fh
     9e: xchg    ax,ax
     a0: jmp     80h
     a2: mov     rax,[rbp-70h]
     a6: mov     [rbp-68h],rax
     aa: jmp     0A0h
     ac: mov     rax,[rbp+20h]
     b0: mov     [rbp-80h],rax
     b4: mov     qword ptr [rbp-88h],0
     bf: mov     rsi,[rbp-88h]
     c6: sub     rsi,rax
     c9: mov     [rbp-78h],rsi
     cd: mov     rdi,[rbp-70h]
     d1: imul    rcx,rsi,10h
     d5: add     rdi,rcx
     d8: mov     [rbp-68h],rdi
     dc: jmp     0A0h
     de: xchg    ax,ax
     e0: mov     rax,[rbp-58h]
     e4: mov     [rbp-50h],rax
     e8: mov     [rbp-48h],rax
     ec: mov     rdx,[rbp-18h]
     f0: mov     [rbp-0A0h],rdx
     f7: mov     [rbp-98h],rax
     fe: call    fn0
    103: nop     [rcx-8]
    10a: jmp     40h
    10f: mov     qword ptr [rbp-58h],8
    117: jmp     0E0h
    119: mov     rax,[rbp-40h]
    11d: mov     [rbp-60h],rax
    121: mov     byte ptr [rbp-81h],0
    128: test    byte ptr [rbp-81h],0FFh
    12f: je      14Ch
    131: jmp     142h
    133: nop     [rax+rax]
    13c: nop     [rax]
    140: jmp     0E0h
    142: mov     rax,[rbp-60h]
    146: mov     [rbp-58h],rax
    14a: jmp     140h
    14c: mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    157: mov     rdx,[rbp-60h]
    15b: imul    rcx,[rbp-88h],10h
    163: add     rdx,rcx
    166: mov     [rbp-58h],rdx
    16a: jmp     140h

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],1
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0B2h
     1f: mov     rsi,[rbp+10h]
     23: mov     rsi,[rsi+18h]
     27: mov     [rbp-50h],rsi
     2b: cmp     rsi,0
     2f: je      0B2h
     35: mov     r8,[rbp+10h]
     39: mov     r8,[r8]
     3c: mov     [rbp-88h],r8
     43: mov     [rbp-58h],r8
     47: mov     byte ptr [rbp-99h],0
     4e: test    byte ptr [rbp-99h],0FFh
     55: je      10Eh
     5b: jmp     101h
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-80h],rax
     68: cmp     rax,0
     6c: je      177h
     72: jmp     184h
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
    12b: mov     rdx,[rbp+10h]
    12f: mov     rdx,[rdx]
    132: mov     [rbp-80h],rdx
    136: mov     [rbp-78h],rdx
    13a: mov     rsi,[rbp+10h]
    13e: mov     rsi,[rsi+8]
    142: mov     [rbp-98h],rsi
    149: add     rsi,1
    14d: mov     [rbp-80h],rsi
    151: mov     [rbp-0B8h],rdx
    158: mov     [rbp-0C0h],rax
    15f: mov     [rbp-0B0h],rsi
    166: call    fn0
    16b: nop     [rcx-70h]
    172: jmp     0C0h
    177: mov     qword ptr [rbp-78h],0
    17f: jmp     0B0h
    184: lea     rax,[rbp-70h]
    188: mov     [rbp-80h],rax
    18c: mov     [rbp-0C0h],rax
    193: call    fn1
    198: nop     [rcx-78h]
    19f: mov     rax,[rbp-50h]
    1a3: sub     rax,1
    1a7: mov     [rbp-50h],rax
    1ab: mov     edi,0FFFFFF64h
    1b0: mov     esi,0FFFFFF88h
    1b5: xor     edx,edx
    1b7: xor     ecx,ecx
    1b9: xor     r8d,r8d
    1bc: mov     r9d,1
    1c2: call    ryo_h_DiscrNicheW64
    1c7: mov     edi,0FFFFFFC8h
    1cc: mov     esi,0FFFFFF64h
    1d1: call    ryo_h_ZextW32W64
    1d6: mov     edi,0FFFFFFC8h
    1db: xor     esi,esi
    1dd: mov     edx,2
    1e2: call    ryo_h_SwitchDenseW64
    1e7: lea     rcx,[1F8h]
    1ee: movsxd  rax,[rcx+rax*4]
    1f2: add     rax,rcx
    1f5: jmp     rax
    1f7: int3
    1f8: .long   b0h
    1fc: .long   87h
    200: .long   80h
    204: nop     [rax+rax]
    20d: nop     [rax]
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
    28d: mov     rdx,[rbp-90h]
    294: imul    rcx,[rbp-0A0h],20h
    29c: add     rdx,rcx
    29f: mov     [rbp-88h],rdx
    2a6: jmp     270h
    2a8: jmp     60h

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     byte ptr [rbp-99h],0
     12: test    byte ptr [rbp-99h],0FFh
     19: je      0B2h
     1f: mov     rsi,[rbp+10h]
     23: mov     rsi,[rsi+18h]
     27: mov     [rbp-50h],rsi
     2b: cmp     rsi,0
     2f: je      0B2h
     35: mov     r8,[rbp+10h]
     39: mov     r8,[r8]
     3c: mov     [rbp-88h],r8
     43: mov     [rbp-58h],r8
     47: mov     byte ptr [rbp-99h],0
     4e: test    byte ptr [rbp-99h],0FFh
     55: je      10Eh
     5b: jmp     101h
     60: mov     rax,[rbp-50h]
     64: mov     [rbp-80h],rax
     68: cmp     rax,0
     6c: je      177h
     72: jmp     184h
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
    12b: mov     rdx,[rbp+10h]
    12f: mov     rdx,[rdx]
    132: mov     [rbp-80h],rdx
    136: mov     [rbp-78h],rdx
    13a: mov     rsi,[rbp+10h]
    13e: mov     rsi,[rsi+8]
    142: mov     [rbp-98h],rsi
    149: add     rsi,1
    14d: mov     [rbp-80h],rsi
    151: mov     [rbp-0B8h],rdx
    158: mov     [rbp-0C0h],rax
    15f: mov     [rbp-0B0h],rsi
    166: call    fn0
    16b: nop     [rcx-70h]
    172: jmp     0C0h
    177: mov     qword ptr [rbp-78h],0
    17f: jmp     0B0h
    184: lea     rax,[rbp-70h]
    188: mov     [rbp-80h],rax
    18c: mov     [rbp-0C0h],rax
    193: call    fn1
    198: nop     [rcx-78h]
    19f: mov     rax,[rbp-50h]
    1a3: sub     rax,1
    1a7: mov     [rbp-50h],rax
    1ab: mov     edi,0FFFFFF64h
    1b0: mov     esi,0FFFFFF88h
    1b5: xor     edx,edx
    1b7: xor     ecx,ecx
    1b9: xor     r8d,r8d
    1bc: mov     r9d,1
    1c2: call    ryo_h_DiscrNicheW64
    1c7: mov     edi,0FFFFFFC8h
    1cc: mov     esi,0FFFFFF64h
    1d1: call    ryo_h_ZextW32W64
    1d6: mov     edi,0FFFFFFC8h
    1db: xor     esi,esi
    1dd: mov     edx,2
    1e2: call    ryo_h_SwitchDenseW64
    1e7: lea     rcx,[1F8h]
    1ee: movsxd  rax,[rcx+rax*4]
    1f2: add     rax,rcx
    1f5: jmp     rax
    1f7: int3
    1f8: .long   b0h
    1fc: .long   87h
    200: .long   80h
    204: nop     [rax+rax]
    20d: nop     [rax]
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
    29d: mov     rdx,[rbp-90h]
    2a4: imul    rcx,[rbp-0A0h],10h
    2ac: add     rdx,rcx
    2af: mov     [rbp-88h],rdx
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
     25: mov     rdi,[rbp+10h]
     29: mov     [rbp-90h],rdi
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
     dd: mov     rdx,[rbp+10h]
     e1: mov     rdx,[rdx]
     e4: mov     [rbp-38h],rdx
     e8: mov     [rbp-30h],rdx
     ec: mov     [rbp-40h],rax
     f0: mov     qword ptr [rbp-70h],0
     f8: mov     rdi,[rbp-70h]
     fc: sub     rdi,rax
     ff: mov     [rbp-38h],rdi
    103: imul    rcx,rdi,1
    107: add     rdx,rcx
    10a: mov     [rbp-28h],rdx
    10e: mov     [rbp-48h],rdx
    112: mov     r8,[rbp+18h]
    116: mov     [rbp-90h],r8
    11d: mov     [rbp-88h],rdx
    124: mov     edi,0FFFFFF80h
    129: mov     esi,0FFFFFFA0h
    12e: call    ryo_h_MovW128
    133: call    fn2
    138: nop     [rcx]
    13f: jmp     90h

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
     25: mov     rdi,[rbp+10h]
     29: mov     [rbp-90h],rdi
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
     dd: mov     rdx,[rbp+10h]
     e1: mov     rdx,[rdx]
     e4: mov     [rbp-38h],rdx
     e8: mov     [rbp-30h],rdx
     ec: mov     [rbp-40h],rax
     f0: mov     qword ptr [rbp-70h],0
     f8: mov     rdi,[rbp-70h]
     fc: sub     rdi,rax
     ff: mov     [rbp-38h],rdi
    103: imul    rcx,rdi,1
    107: add     rdx,rcx
    10a: mov     [rbp-28h],rdx
    10e: mov     [rbp-48h],rdx
    112: mov     r8,[rbp+18h]
    116: mov     [rbp-90h],r8
    11d: mov     [rbp-88h],rdx
    124: mov     edi,0FFFFFF80h
    129: mov     esi,0FFFFFFA0h
    12e: call    ryo_h_MovW128
    133: call    fn2
    138: nop     [rcx]
    13f: jmp     90h

fn hashbrown::raw::RawTableInner::erase
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     rax,[rbp+18h]
      f: sub     rax,10h
     13: mov     [rbp-68h],rax
     17: mov     rdx,[rbp+10h]
     1b: mov     rdx,[rdx+8]
     1f: mov     [rbp-70h],rdx
     23: and     rax,rdx
     26: mov     [rbp-60h],rax
     2a: mov     rsi,[rbp+10h]
     2e: mov     rsi,[rsi]
     31: mov     [rbp-78h],rsi
     35: mov     [rbp-70h],rsi
     39: imul    rcx,rax,1
     3d: add     rsi,rcx
     40: mov     [rbp-20h],rsi
     44: mov     [rbp-68h],rsi
     48: mov     rdi,[rbp-20h]
     4c: mov     [rbp-70h],rdi
     50: mov     [rbp-0C0h],rdi
     57: mov     edi,0FFFFFF70h
     5c: lea     rsi,[sym0]
     63: call    ryo_h_AddrSym
     68: mov     rdi,rbp
     6b: lea     rsi,[ro+4]
     72: call    qword ptr [sym1]
     78: jmp     168h
     7d: nop     [rax]
     80: mov     byte ptr [rbp-11h],80h
     84: jmp     0BDh
     86: nop     [rax+rax]
     8f: nop
     90: mov     rax,[rbp+10h]
     94: mov     rax,[rax+10h]
     98: mov     [rbp-90h],rax
     9f: add     rax,1
     a3: mov     [rbp-0A0h],rax
     aa: mov     rdx,[rbp+10h]
     ae: mov     rcx,[rbp-0A0h]
     b5: mov     [rdx+10h],rcx
     b9: mov     byte ptr [rbp-11h],0FFh
     bd: mov     rax,[rbp+18h]
     c1: sub     rax,10h
     c5: mov     [rbp-78h],rax
     c9: mov     rdx,[rbp+10h]
     cd: mov     rdx,[rdx+8]
     d1: mov     [rbp-80h],rdx
     d5: and     rax,rdx
     d8: mov     [rbp-70h],rax
     dc: add     rax,10h
     e0: mov     [rbp-68h],rax
     e4: mov     rsi,[rbp+10h]
     e8: mov     rsi,[rsi]
     eb: mov     [rbp-88h],rsi
     f2: mov     [rbp-80h],rsi
     f6: imul    rcx,[rbp+18h],1
     fb: add     rsi,rcx
     fe: mov     [rbp-78h],rsi
    102: mov     [rbp-70h],rsi
    106: movzx   ecx,byte ptr [rbp-11h]
    10a: mov     [rsi],cl
    10c: mov     rdi,[rbp+10h]
    110: mov     rdi,[rdi]
    113: mov     [rbp-88h],rdi
    11a: mov     [rbp-80h],rdi
    11e: imul    rcx,[rbp-68h],1
    123: add     rdi,rcx
    126: mov     [rbp-78h],rdi
    12a: mov     [rbp-70h],rdi
    12e: movzx   ecx,byte ptr [rbp-11h]
    132: mov     [rdi],cl
    134: mov     r8,[rbp+10h]
    138: mov     r8,[r8+18h]
    13c: mov     [rbp-90h],r8
    143: sub     r8,1
    147: mov     [rbp-0A0h],r8
    14e: mov     r9,[rbp+10h]
    152: mov     rcx,[rbp-0A0h]
    159: mov     [r9+18h],rcx
    15d: xor     edi,edi
    15f: xor     esi,esi
    161: call    ryo_h_Ret
    166: leave
    167: ret
    168: mov     byte ptr [rbp-0C0h],0FFh
    16f: mov     edi,0FFFFFF70h
    174: lea     rsi,[sym2]
    17b: call    ryo_h_AddrSym
    180: mov     rdi,rbp
    183: lea     rsi,[ro+20]
    18a: call    qword ptr [sym3]
    190: mov     edi,0FFFFFF40h
    195: mov     esi,0FFFFFFD0h
    19a: call    ryo_h_MovW128
    19f: mov     edi,0FFFFFF50h
    1a4: mov     esi,0FFFFFF80h
    1a9: call    ryo_h_MovW128
    1ae: mov     edi,0FFFFFF70h
    1b3: lea     rsi,[sym4]
    1ba: call    ryo_h_AddrSym
    1bf: mov     rdi,rbp
    1c2: lea     rsi,[ro+36]
    1c9: call    qword ptr [sym5]
    1cf: mov     edi,0FFFFFF40h
    1d4: mov     esi,0FFFFFF90h
    1d9: call    ryo_h_MovW128
    1de: mov     edi,0FFFFFF70h
    1e3: lea     rsi,[sym6]
    1ea: call    ryo_h_AddrSym
    1ef: mov     rdi,rbp
    1f2: lea     rsi,[ro+52]
    1f9: call    qword ptr [sym7]
    1ff: mov     edi,0FFFFFFCEh
    204: mov     esi,0FFFFFF8Ch
    209: call    ryo_h_TruncW32W16
    20e: mov     rax,[rbp+10h]
    212: mov     rax,[rax]
    215: mov     [rbp-78h],rax
    219: mov     [rbp-70h],rax
    21d: imul    rcx,[rbp+18h],1
    222: add     rax,rcx
    225: mov     [rbp-40h],rax
    229: mov     [rbp-68h],rax
    22d: mov     rdx,[rbp-40h]
    231: mov     [rbp-70h],rdx
    235: mov     [rbp-0C0h],rdx
    23c: mov     edi,0FFFFFF70h
    241: lea     rsi,[sym8]
    248: call    ryo_h_AddrSym
    24d: mov     rdi,rbp
    250: lea     rsi,[ro+68]
    257: call    qword ptr [sym9]
    25d: mov     byte ptr [rbp-0C0h],0FFh
    264: mov     edi,0FFFFFF70h
    269: lea     rsi,[sym10]
    270: call    ryo_h_AddrSym
    275: mov     rdi,rbp
    278: lea     rsi,[ro+20]
    27f: call    qword ptr [sym11]
    285: mov     edi,0FFFFFF40h
    28a: mov     esi,0FFFFFFB0h
    28f: call    ryo_h_MovW128
    294: mov     edi,0FFFFFF50h
    299: mov     esi,0FFFFFF80h
    29e: call    ryo_h_MovW128
    2a3: mov     edi,0FFFFFF70h
    2a8: lea     rsi,[sym12]
    2af: call    ryo_h_AddrSym
    2b4: mov     rdi,rbp
    2b7: lea     rsi,[ro+36]
    2be: call    qword ptr [sym13]
    2c4: mov     edi,0FFFFFF40h
    2c9: mov     esi,0FFFFFF90h
    2ce: call    ryo_h_MovW128
    2d3: mov     edi,0FFFFFF70h
    2d8: lea     rsi,[sym14]
    2df: call    ryo_h_AddrSym
    2e4: mov     rdi,rbp
    2e7: lea     rsi,[ro+52]
    2ee: call    qword ptr [sym15]
    2f4: mov     edi,0FFFFFFAEh
    2f9: mov     esi,0FFFFFF8Ch
    2fe: call    ryo_h_TruncW32W16
    303: mov     edi,0FFFFFF74h
    308: mov     esi,0FFFFFFCEh
    30d: call    ryo_h_CtlzW16
    312: mov     eax,[rbp-8Ch]
    318: mov     [rbp-74h],eax
    31b: mov     edi,0FFFFFF90h
    320: mov     esi,0FFFFFF8Ch
    325: call    ryo_h_ZextW32W64
    32a: mov     edi,0FFFFFF74h
    32f: mov     esi,0FFFFFFAEh
    334: call    ryo_h_CttzW16
    339: mov     eax,[rbp-8Ch]
    33f: mov     [rbp-7Ch],eax
    342: mov     edi,0FFFFFF88h
    347: mov     esi,0FFFFFF84h
    34c: call    ryo_h_ZextW32W64
    351: mov     rax,[rbp-70h]
    355: add     rax,[rbp-78h]
    359: mov     [rbp-68h],rax
    35d: cmp     rax,10h
    361: jae     80h
    367: jmp     90h

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
    196: mov     rdi,[rbp+10h]
    19a: mov     [rbp-100h],rdi
    1a1: mov     edi,0FFFFFF08h
    1a6: mov     esi,18h
    1ab: call    ryo_h_MovW128
    1b0: mov     rax,[rbp-30h]
    1b4: mov     [rbp-0E8h],rax
    1bb: movzx   edx,byte ptr [rbp+30h]
    1bf: mov     [rbp-0E0h],dl
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
    337: mov     rdx,[rbp-48h]
    33b: mov     [rbp-90h],rdx
    342: add     rdx,1
    346: mov     [rbp-88h],rdx
    34d: add     rdx,10h
    351: mov     [rbp-60h],rdx
    355: mov     [rbp-90h],rax
    35c: mov     [rbp-88h],rdx
    363: mov     [rbp-70h],rax
    367: mov     [rbp-68h],rdx
    36b: mov     [rbp-88h],rax
    372: mov     [rbp-80h],rdx
    376: mov     [rbp-78h],rax
    37a: mov     byte ptr [rbp-0C9h],0FFh
    381: imul    rdi,[rbp-60h],1
    386: mov     [rbp-0D8h],rdi
    38d: mov     edi,0FFFFFF88h
    392: mov     esi,0FFFFFF37h
    397: mov     edx,0FFFFFF28h
    39c: call    ryo_h_Memset
    3a1: mov     edi,0FFFFFFE0h
    3a6: mov     esi,0FFFFFFB0h
    3ab: mov     edx,20h
    3b0: call    ryo_h_Copy
    3b5: jmp     100h

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
     39: mov     rdx,[rbp+10h]
     3d: mov     rdx,[rdx+8]
     41: mov     [rbp-98h],rdx
     48: and     rax,rdx
     4b: mov     [rbp-88h],rax
     52: mov     [rbp-80h],rax
     56: mov     qword ptr [rbp-78h],0
     5e: xchg    ax,ax
     60: mov     rax,[rbp-80h]
     64: mov     [rbp-90h],rax
     6b: mov     rdx,[rbp+10h]
     6f: mov     rdx,[rdx]
     72: mov     [rbp-0A0h],rdx
     79: mov     [rbp-98h],rdx
     80: imul    rcx,rax,1
     84: add     rdx,rcx
     87: mov     [rbp-38h],rdx
     8b: mov     [rbp-88h],rdx
     92: mov     rsi,[rbp-38h]
     96: mov     [rbp-90h],rsi
     9d: mov     [rbp-0E0h],rsi
     a4: mov     edi,0FFFFFF40h
     a9: lea     rsi,[sym0]
     b0: call    ryo_h_AddrSym
     b5: mov     rdi,rbp
     b8: lea     rsi,[ro+4]
     bf: call    qword ptr [sym1]
     c5: jmp     161h
     ca: nop     [rax+rax]
     d0: movzx   eax,word ptr [rbp-12h]
     d4: mov     [rbp-0B6h],ax
     db: mov     [rbp-6Ch],ax
     df: mov     edi,0FFFFFF44h
     e4: mov     esi,0FFFFFF94h
     e9: xor     edx,edx
     eb: xor     ecx,ecx
     ed: xor     r8d,r8d
     f0: mov     r9d,1
     f6: call    ryo_h_DiscrNicheW16
     fb: mov     edi,0FFFFFF58h
    100: mov     esi,0FFFFFF44h
    105: call    ryo_h_ZextW32W64
    10a: mov     edi,0FFFFFF58h
    10f: xor     esi,esi
    111: mov     edx,2
    116: call    ryo_h_SwitchDenseW64
    11b: lea     rcx,[12Ch]
    122: movsxd  rax,[rcx+rax*4]
    126: add     rax,rcx
    129: jmp     rax
    12b: int3
    12c: .long   247h
    130: .long   21eh
    134: .long   138h
    138: call    ryo_h_Unreachable
    13d: ud2
    13f: nop
    140: test    byte ptr [rbp-6Bh],0FFh
    144: je      44Ah
    14a: jmp     432h
    14f: nop
    150: mov     edi,0FFFFFFF0h
    155: mov     esi,10h
    15a: call    ryo_h_Ret
    15f: leave
    160: ret
    161: movzx   eax,byte ptr [rbp-29h]
    165: mov     [rbp-6Dh],al
    168: mov     [rbp-0E0h],al
    16e: mov     edi,0FFFFFF40h
    173: lea     rsi,[sym2]
    17a: call    ryo_h_AddrSym
    17f: mov     rdi,rbp
    182: lea     rsi,[ro+20]
    189: call    qword ptr [sym3]
    18f: mov     edi,0FFFFFF20h
    194: mov     esi,0FFFFFFB0h
    199: call    ryo_h_MovW128
    19e: mov     edi,0FFFFFF30h
    1a3: mov     esi,0FFFFFF60h
    1a8: call    ryo_h_MovW128
    1ad: mov     edi,0FFFFFF40h
    1b2: lea     rsi,[sym4]
    1b9: call    ryo_h_AddrSym
    1be: mov     rdi,rbp
    1c1: lea     rsi,[ro+36]
    1c8: call    qword ptr [sym5]
    1ce: mov     edi,0FFFFFF20h
    1d3: mov     esi,0FFFFFF70h
    1d8: call    ryo_h_MovW128
    1dd: mov     edi,0FFFFFF40h
    1e2: lea     rsi,[sym6]
    1e9: call    ryo_h_AddrSym
    1ee: mov     rdi,rbp
    1f1: lea     rsi,[ro+52]
    1f8: call    qword ptr [sym7]
    1fe: mov     edi,0FFFFFF92h
    203: mov     esi,0FFFFFF6Ch
    208: call    ryo_h_TruncW32W16
    20d: movzx   eax,word ptr [rbp-6Eh]
    211: mov     [rbp-6Ch],ax
    215: mov     [rbp-12h],ax
    219: jmp     0D0h
    21e: movzx   eax,word ptr [rbp-6Ch]
    222: mov     [rbp-6Eh],ax
    226: mov     [rbp-70h],ax
    22a: mov     edi,0FFFFFF44h
    22f: mov     esi,0FFFFFF90h
    234: call    ryo_h_CttzW16
    239: mov     eax,[rbp-0BCh]
    23f: mov     [rbp-0B4h],eax
    245: jmp     2A1h
    247: mov     edi,0FFFFFF60h
    24c: lea     rsi,[k8]
    253: mov     edx,10h
    258: call    ryo_h_Const
    25d: mov     qword ptr [rbp-98h],0
    268: cmp     qword ptr [rbp-98h],0
    270: sete    [rbp-6Bh]
    274: mov     byte ptr [rbp-0E0h],0FFh
    27b: mov     edi,0FFFFFF40h
    280: lea     rsi,[sym9]
    287: call    ryo_h_AddrSym
    28c: mov     rdi,rbp
    28f: lea     rsi,[ro+20]
    296: call    qword ptr [sym10]
    29c: jmp     3A2h
    2a1: mov     edi,0FFFFFF50h
    2a6: mov     esi,0FFFFFF4Ch
    2ab: call    ryo_h_ZextW32W64
    2b0: mov     rax,[rbp-0B0h]
    2b7: mov     [rbp-98h],rax
    2be: mov     qword ptr [rbp-0A0h],1
    2c9: mov     [rbp-68h],rax
    2cd: movzx   esi,word ptr [rbp-12h]
    2d1: mov     [rbp-92h],si
    2d8: sub     esi,1
    2db: mov     [rbp-70h],si
    2df: movzx   edi,word ptr [rbp-92h]
    2e6: and     di,[rbp-70h]
    2ea: mov     [rbp-6Eh],di
    2ee: movzx   r8d,word ptr [rbp-6Eh]
    2f3: mov     [rbp-6Ch],r8w
    2f8: mov     [rbp-12h],r8w
    2fd: mov     [rbp-88h],rax
    304: mov     qword ptr [rbp-90h],1
    30f: mov     [rbp-98h],rax
    316: mov     r10,[rbp-80h]
    31a: mov     [rbp-0B0h],r10
    321: add     r10,rax
    324: mov     [rbp-0A8h],r10
    32b: mov     r11,[rbp+10h]
    32f: mov     r11,[r11+8]
    333: mov     [rbp-0B0h],r11
    33a: and     r10,r11
    33d: mov     [rbp-0A0h],r10
    344: mov     [rbp-0A8h],r10
    34b: mov     rdx,[rbp+28h]
    34f: mov     rdx,[rdx+20h]
    353: mov     [rbp-0C0h],rdx
    35a: mov     rsi,[rbp+20h]
    35e: mov     [rbp-0E0h],rsi
    365: mov     [rbp-0D8h],r10
    36c: mov     edi,0FFFFFF40h
    371: lea     rsi,[site11]
    378: call    ryo_h_CallInd
    37d: test    rax,rax
    380: je      38Dh
    382: call    rax
    384: nop     [rcx-6Bh]
    38b: jmp     39Dh
    38d: mov     rdi,rbp
    390: lea     rsi,[ro+68]
    397: call    qword ptr [sym12]
    39d: jmp     140h
    3a2: mov     edi,0FFFFFF20h
    3a7: mov     esi,0FFFFFFB0h
    3ac: call    ryo_h_MovW128
    3b1: mov     edi,0FFFFFF30h
    3b6: mov     esi,0FFFFFF60h
    3bb: call    ryo_h_MovW128
    3c0: mov     edi,0FFFFFF40h
    3c5: lea     rsi,[sym13]
    3cc: call    ryo_h_AddrSym
    3d1: mov     rdi,rbp
    3d4: lea     rsi,[ro+36]
    3db: call    qword ptr [sym14]
    3e1: mov     edi,0FFFFFF20h
    3e6: mov     esi,0FFFFFF70h
    3eb: call    ryo_h_MovW128
    3f0: mov     edi,0FFFFFF40h
    3f5: lea     rsi,[sym15]
    3fc: call    ryo_h_AddrSym
    401: mov     rdi,rbp
    404: lea     rsi,[ro+84]
    40b: call    qword ptr [sym16]
    411: mov     edi,0FFFFFF96h
    416: mov     esi,0FFFFFF90h
    41b: call    ryo_h_TruncW32W16
    420: cmp     word ptr [rbp-6Ah],0
    425: setne   [rbp-6Bh]
    429: cmp     word ptr [rbp-6Ah],0
    42e: je      46Ah
    430: jmp     44Fh
    432: mov     rax,[rbp-0A0h]
    439: mov     [rbp-8],rax
    43d: mov     qword ptr [rbp-10h],1
    445: jmp     150h
    44a: jmp     0D0h
    44f: mov     edi,0FFFFFFF0h
    454: lea     rsi,[k17]
    45b: mov     edx,10h
    460: call    ryo_h_Const
    465: jmp     150h
    46a: mov     rax,[rbp+10h]
    46e: mov     rax,[rax+8]
    472: mov     [rbp-88h],rax
    479: mov     rdx,[rbp-78h]
    47d: add     rdx,10h
    481: mov     [rbp-78h],rdx
    485: mov     [rbp-90h],rdx
    48c: mov     rsi,[rbp-80h]
    490: add     rsi,rdx
    493: mov     [rbp-80h],rsi
    497: and     rsi,rax
    49a: mov     [rbp-80h],rsi
    49e: jmp     60h

fn hashbrown::raw::RawTableInner::find_insert_index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-50h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx+8]
     1b: mov     [rbp-58h],rdx
     1f: and     rax,rdx
     22: mov     [rbp-48h],rax
     26: mov     [rbp-40h],rax
     2a: mov     qword ptr [rbp-38h],0
     32: nop     [rax+rax]
     3b: nop     [rax+rax]
     40: mov     rax,[rbp-40h]
     44: mov     [rbp-60h],rax
     48: mov     rdx,[rbp+10h]
     4c: mov     rdx,[rdx]
     4f: mov     [rbp-70h],rdx
     53: mov     [rbp-68h],rdx
     57: imul    rcx,rax,1
     5b: add     rdx,rcx
     5e: mov     [rbp-20h],rdx
     62: mov     [rbp-58h],rdx
     66: mov     rsi,[rbp-20h]
     6a: mov     [rbp-60h],rsi
     6e: mov     [rbp-90h],rsi
     75: mov     edi,0FFFFFF88h
     7a: lea     rsi,[sym0]
     81: call    ryo_h_AddrSym
     86: mov     rdi,rbp
     89: lea     rsi,[ro+4]
     90: call    qword ptr [sym1]
     96: jmp     0D1h
     98: nop     [rax+rax]
     a0: mov     rax,[rbp-60h]
     a4: mov     [rbp-28h],rax
     a8: cmp     rax,1
     ac: sete    [rbp-2Ah]
     b0: cmp     rax,1
     b4: je      114h
     b6: jmp     148h
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
     e8: lea     rdx,[rbp-40h]
     ec: mov     [rbp-70h],rdx
     f0: mov     rsi,[rbp+10h]
     f4: mov     [rbp-90h],rsi
     fb: mov     [rbp-88h],rax
    102: mov     [rbp-80h],rdx
    106: call    fn2
    10b: nop     [rcx-60h]
    112: jmp     0A0h
    114: cmp     qword ptr [rbp-28h],1
    119: sete    [rbp-29h]
    11d: mov     rdx,[rbp-58h]
    121: mov     [rbp-68h],rdx
    125: mov     rsi,[rbp+10h]
    129: mov     [rbp-90h],rsi
    130: mov     [rbp-88h],rdx
    137: call    fn3
    13c: nop     [rcx-8]
    143: jmp     0C0h
    148: mov     rax,[rbp+10h]
    14c: mov     rax,[rax+8]
    150: mov     [rbp-68h],rax
    154: mov     rdx,[rbp-38h]
    158: add     rdx,10h
    15c: mov     [rbp-38h],rdx
    160: mov     [rbp-70h],rdx
    164: mov     rsi,[rbp-40h]
    168: add     rsi,rdx
    16b: mov     [rbp-40h],rsi
    16f: and     rsi,rax
    172: mov     [rbp-40h],rsi
    176: jmp     40h

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
     cc: .long   184h
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
    119: jmp     18Bh
    11b: mov     edi,0FFFFFFB8h
    120: mov     esi,0FFFFFFB4h
    125: call    ryo_h_ZextW32W64
    12a: mov     rax,[rbp-48h]
    12e: mov     [rbp-18h],rax
    132: mov     qword ptr [rbp-20h],1
    13a: mov     rsi,[rbp-20h]
    13e: mov     [rbp-40h],rsi
    142: cmp     rsi,1
    146: sete    [rbp-35h]
    14a: mov     r8,[rbp+20h]
    14e: mov     r8,[r8]
    151: mov     [rbp-50h],r8
    155: mov     [rbp-58h],rax
    159: add     r8,rax
    15c: mov     [rbp-48h],r8
    160: mov     r9,[rbp+10h]
    164: mov     r9,[r9+8]
    168: mov     [rbp-50h],r9
    16c: and     r8,r9
    16f: mov     [rbp-40h],r8
    173: mov     [rbp-8],r8
    177: mov     qword ptr [rbp-10h],1
    17f: jmp     50h
    184: call    ryo_h_Unreachable
    189: ud2
    18b: mov     edi,0FFFFFFF0h
    190: lea     rsi,[k3]
    197: mov     edx,10h
    19c: call    ryo_h_Const
    1a1: jmp     50h

fn hashbrown::raw::RawTableInner::fix_insert_index
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,90h
      b: mov     rax,[rbp+18h]
      f: mov     [rbp-58h],rax
     13: mov     rdx,[rbp+10h]
     17: mov     rdx,[rdx]
     1a: mov     [rbp-78h],rdx
     1e: mov     [rbp-70h],rdx
     22: imul    rcx,rax,1
     26: add     rdx,rcx
     29: mov     [rbp-68h],rdx
     2d: mov     [rbp-60h],rdx
     31: movzx   edx,byte ptr [rdx]
     34: mov     [rbp-50h],dl
     37: and     dl,80h
     3a: mov     [rbp-4Fh],dl
     3d: cmp     byte ptr [rbp-4Fh],0
     41: sete    [rbp-4Eh]
     45: test    byte ptr [rbp-4Eh],0FFh
     49: je      0AAh
     4b: jmp     69h
     4d: nop     [rax]
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
     78: mov     rdx,[rbp-10h]
     7c: mov     [rbp-70h],rdx
     80: mov     [rbp-90h],rdx
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
    160: mov     rsi,[rbp-58h]
    164: mov     [rbp+18h],rsi
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
     67: jmp     2D0h
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
     de: mov     rdx,[rbp+10h]
     e2: mov     [rbp-110h],rdx
     e9: mov     edi,0FFFFFEF8h
     ee: mov     esi,0FFFFFF70h
     f3: call    ryo_h_MovW128
     f8: call    fn1
     fd: nop     [rcx-0B8h]
    104: jmp     2E1h
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
    16b: mov     rdx,[rbp+20h]
    16f: mov     [rbp-0E8h],rdx
    176: mov     rsi,[rbp-38h]
    17a: sub     rsi,10h
    17e: mov     [rbp-0C8h],rsi
    185: add     rax,1
    189: mov     [rbp-0D0h],rax
    190: cmp     rax,0
    194: jne     3F2h
    19a: mov     edi,0FFFFFEF0h
    19f: lea     rsi,[k5]
    1a6: call    ryo_h_AddrAbs
    1ab: lea     rdi,[sym6]
    1b2: lea     rsi,[site7]
    1b9: mov     edx,0FFFFFF10h
    1be: call    ryo_h_CallExt
    1c3: test    rax,rax
    1c6: je      1D3h
    1c8: call    rax
    1ca: nop     [rcx-0E8h]
    1d1: jmp     1E3h
    1d3: mov     rdi,rbp
    1d6: lea     rsi,[ro+20]
    1dd: call    qword ptr [sym8]
    1e3: call    ryo_h_Unreachable
    1e8: ud2
    1ea: nop     [rax+rax]
    1f0: mov     edi,0FFFFFF14h
    1f5: mov     esi,0FFFFFF30h
    1fa: xor     edx,edx
    1fc: xor     ecx,ecx
    1fe: xor     r8d,r8d
    201: mov     r9d,1
    207: call    ryo_h_DiscrNicheW64
    20c: mov     edi,0FFFFFF28h
    211: mov     esi,0FFFFFF14h
    216: call    ryo_h_ZextW32W64
    21b: cmp     qword ptr [rbp-0D8h],1
    223: sete    [rbp-79h]
    227: mov     edi,0FFFFFF18h
    22c: mov     esi,0FFFFFF30h
    231: call    ryo_h_MovW128
    236: mov     rax,[rbp-0C0h]
    23d: mov     [rbp-78h],rax
    241: jmp     250h
    243: nop     [rax+rax]
    24c: nop     [rax]
    250: mov     rax,[rbp-70h]
    254: mov     [rbp-0C0h],rax
    25b: mov     [rbp-98h],rax
    262: mov     [rbp-0B0h],rax
    269: imul    rcx,[rbp-78h],1
    26e: add     rax,rcx
    271: mov     [rbp-0A8h],rax
    278: mov     [rbp-0A0h],rax
    27f: mov     rdx,[rbp+28h]
    283: mov     [rbp-0D0h],rdx
    28a: sub     rdx,1
    28e: mov     [rbp-0C8h],rdx
    295: mov     rsi,[rbp+28h]
    299: sub     rsi,1
    29d: mov     [rbp-60h],rsi
    2a1: cmp     rsi,8
    2a5: jb      4A5h
    2ab: jmp     4A7h
    2b0: mov     edi,0FFFFFFE8h
    2b5: mov     esi,0FFFFFF48h
    2ba: call    ryo_h_MovW128
    2bf: mov     qword ptr [rbp-20h],0
    2c7: nop     [rax+rax]
    2d0: mov     edi,0FFFFFFE0h
    2d5: mov     esi,20h
    2da: call    ryo_h_Ret
    2df: leave
    2e0: ret
    2e1: mov     edi,0FFFFFF14h
    2e6: mov     esi,0FFFFFF48h
    2eb: xor     edx,edx
    2ed: mov     ecx,1
    2f2: mov     r8d,1
    2f8: xor     r9d,r9d
    2fb: call    ryo_h_DiscrNicheW64
    300: mov     edi,0FFFFFF40h
    305: mov     esi,0FFFFFF14h
    30a: call    ryo_h_ZextW32W64
    30f: mov     edi,0FFFFFF40h
    314: xor     esi,esi
    316: mov     edx,2
    31b: call    ryo_h_SwitchDenseW64
    320: lea     rcx,[330h]
    327: movsxd  rax,[rcx+rax*4]
    32b: add     rax,rcx
    32e: jmp     rax
    330: .long   392h
    334: .long   33ch
    338: .long   150h
    33c: movzx   eax,byte ptr [rbp+30h]
    340: mov     [rbp-110h],al
    346: mov     edi,0FFFFFEF8h
    34b: mov     esi,0FFFFFF70h
    350: call    ryo_h_MovW128
    355: lea     rdi,[sym9]
    35c: lea     rsi,[site10]
    363: mov     edx,0FFFFFF10h
    368: call    ryo_h_CallExt
    36d: test    rax,rax
    370: je      37Dh
    372: call    rax
    374: nop     [rcx-0B8h]
    37b: jmp     38Dh
    37d: mov     rdi,rbp
    380: lea     rsi,[ro+36]
    387: call    qword ptr [sym11]
    38d: jmp     2B0h
    392: mov     edi,0FFFFFF30h
    397: mov     esi,0FFFFFF48h
    39c: call    ryo_h_MovW128
    3a1: mov     edi,0FFFFFF58h
    3a6: mov     esi,0FFFFFF30h
    3ab: call    ryo_h_MovW128
    3b0: mov     edi,0FFFFFF48h
    3b5: mov     esi,0FFFFFF58h
    3ba: call    ryo_h_MovW128
    3bf: mov     edi,0FFFFFF90h
    3c4: mov     esi,0FFFFFF48h
    3c9: call    ryo_h_MovW128
    3ce: mov     rax,[rbp-68h]
    3d2: mov     [rbp-38h],rax
    3d6: mov     rdx,[rbp-88h]
    3dd: mov     [rbp-0C0h],rdx
    3e4: cmp     rax,rdx
    3e7: jne     160h
    3ed: jmp     250h
    3f2: mov     edi,0FFFFFF40h
    3f7: mov     esi,0FFFFFF38h
    3fc: mov     edx,0FFFFFF30h
    401: call    ryo_h_DivUW64
    406: mov     rax,[rbp-0C0h]
    40d: mov     [rbp-0D8h],rax
    414: mov     edi,0FFFFFF14h
    419: mov     esi,0FFFFFF28h
    41e: call    ryo_h_CtlzW64
    423: mov     eax,[rbp-0ECh]
    429: mov     [rbp-80h],eax
    42c: mov     edi,0FFFFFF30h
    431: mov     esi,0FFFFFF80h
    436: call    ryo_h_ZextW32W64
    43b: mov     qword ptr [rbp-0F0h],3Fh
    446: mov     rdx,[rbp-0F0h]
    44d: sub     rdx,[rbp-0D0h]
    454: mov     [rbp-0C8h],rdx
    45b: mov     qword ptr [rbp-0F0h],1
    466: mov     edi,28h
    46b: mov     esi,0FFFFFF10h
    470: mov     edx,0FFFFFF38h
    475: call    ryo_h_ShlW64
    47a: mov     edi,0FFFFFEF0h
    47f: mov     esi,18h
    484: call    ryo_h_MovW128
    489: mov     rax,[rbp+28h]
    48d: mov     [rbp-100h],rax
    494: call    fn12
    499: nop     [rcx-0D0h]
    4a0: jmp     1F0h
    4a5: jmp     4E1h
    4a7: mov     rax,[rbp-60h]
    4ab: add     rax,1
    4af: mov     [rbp-0D8h],rax
    4b6: mov     qword ptr [rbp-0F0h],8
    4c1: mov     edi,0FFFFFF30h
    4c6: mov     esi,0FFFFFF28h
    4cb: mov     edx,0FFFFFF10h
    4d0: call    ryo_h_DivUW64
    4d5: imul    rax,[rbp-0D0h],7
    4dd: mov     [rbp-60h],rax
    4e1: mov     rax,[rbp-0C8h]
    4e8: mov     [rbp-0B8h],rax
    4ef: mov     rdx,[rbp-0A0h]
    4f6: mov     [rbp-0C0h],rdx
    4fd: mov     rsi,[rbp-60h]
    501: mov     [rbp-0B0h],rsi
    508: mov     qword ptr [rbp-0A8h],0
    513: mov     edi,0FFFFFFE0h
    518: mov     esi,0FFFFFF40h
    51d: mov     edx,20h
    522: call    ryo_h_Copy
    527: jmp     2D0h

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
     c7: mov     rdx,[rbp-0C0h]
     ce: mov     [rbp-0B0h],rdx
     d5: mov     [rbp-0A8h],rdx
     dc: mov     [rbp-0A0h],rdx
     e3: mov     rsi,[rbp-18h]
     e7: mov     [rbp-0A0h],rsi
     ee: cmp     rsi,0
     f2: ja      1A0h
     f8: jmp     248h
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
    13a: mov     rdx,[rbp-58h]
    13e: mov     [rbp-0D0h],rdx
    145: mov     [rbp-120h],rdx
    14c: mov     edi,0FFFFFEF0h
    151: mov     esi,0FFFFFF10h
    156: call    ryo_h_MovW128
    15b: mov     edi,0FFFFFF08h
    160: lea     rsi,[sym1]
    167: call    ryo_h_AddrSym
    16c: mov     rdi,rbp
    16f: lea     rsi,[ro+4]
    176: call    qword ptr [sym2]
    17c: jmp     2ABh
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
    1bd: mov     rdx,[rbp-0A0h]
    1c4: sub     rdx,1
    1c8: mov     [rbp-18h],rdx
    1cc: mov     rsi,[rbp-0B0h]
    1d3: mov     [rbp-90h],rsi
    1da: mov     qword ptr [rbp-98h],1
    1e5: mov     [rbp-0A0h],rsi
    1ec: mov     r8,[rbp+10h]
    1f0: mov     r8,[r8]
    1f3: mov     [rbp-0C8h],r8
    1fa: mov     [rbp-0C0h],r8
    201: imul    rcx,rsi,1
    205: add     r8,rcx
    208: mov     [rbp-38h],r8
    20c: mov     [rbp-0B8h],r8
    213: mov     r9,[rbp-38h]
    217: mov     [rbp-0C0h],r9
    21e: mov     [rbp-120h],r9
    225: mov     edi,0FFFFFF08h
    22a: lea     rsi,[sym3]
    231: call    ryo_h_AddrSym
    236: mov     rdi,rbp
    239: lea     rsi,[ro+20]
    240: call    qword ptr [sym4]
    246: jmp     27Ch
    248: mov     rax,[rbp+10h]
    24c: mov     rax,[rax+8]
    250: mov     [rbp-98h],rax
    257: add     rax,1
    25b: mov     [rbp-90h],rax
    262: cmp     rax,10h
    266: setb    [rbp-82h]
    26d: test    byte ptr [rbp-82h],0FFh
    274: je      344h
    27a: jmp     2B0h
    27c: mov     edi,0FFFFFF50h
    281: mov     esi,0FFFFFF30h
    286: call    ryo_h_MovW128
    28b: mov     edi,0FFFFFEE0h
    290: mov     esi,0FFFFFF50h
    295: call    ryo_h_MovW128
    29a: call    fn5
    29f: nop     [rcx-0C0h]
    2a6: jmp     100h
    2ab: jmp     70h
    2b0: mov     rax,[rbp+10h]
    2b4: mov     rax,[rax]
    2b7: mov     [rbp-78h],rax
    2bb: mov     [rbp-90h],rax
    2c2: mov     rdx,[rbp+10h]
    2c6: mov     rdx,[rdx]
    2c9: mov     [rbp-0B0h],rdx
    2d0: mov     [rbp-0A8h],rdx
    2d7: mov     qword ptr [rbp-0F8h],10h
    2e2: imul    rcx,[rbp-0F8h],1
    2ea: add     rdx,rcx
    2ed: mov     [rbp-0A0h],rdx
    2f4: mov     [rbp-98h],rdx
    2fb: mov     rdi,[rbp+10h]
    2ff: mov     rdi,[rdi+8]
    303: mov     [rbp-0A8h],rdi
    30a: add     rdi,1
    30e: mov     [rbp-0A0h],rdi
    315: mov     r8,[rbp-78h]
    319: mov     [rbp-0A8h],r8
    320: imul    r9,rdi,1
    324: mov     [rbp-0F8h],r9
    32b: mov     edi,0FFFFFF68h
    330: mov     esi,0FFFFFF58h
    335: mov     edx,0FFFFFF08h
    33a: call    ryo_h_Memmove
    33f: jmp     3D5h
    344: mov     rax,[rbp+10h]
    348: mov     rax,[rax]
    34b: mov     [rbp-80h],rax
    34f: mov     [rbp-90h],rax
    356: mov     rdx,[rbp+10h]
    35a: mov     rdx,[rdx+8]
    35e: mov     [rbp-0A8h],rdx
    365: add     rdx,1
    369: mov     [rbp-0A0h],rdx
    370: mov     rsi,[rbp+10h]
    374: mov     rsi,[rsi]
    377: mov     [rbp-0B8h],rsi
    37e: mov     [rbp-0B0h],rsi
    385: imul    rcx,rdx,1
    389: add     rsi,rcx
    38c: mov     [rbp-0A8h],rsi
    393: mov     [rbp-98h],rsi
    39a: mov     rdi,[rbp-80h]
    39e: mov     [rbp-0A0h],rdi
    3a5: mov     qword ptr [rbp-0F8h],10h
    3b0: imul    r9,[rbp-0F8h],1
    3b8: mov     [rbp-100h],r9
    3bf: mov     edi,0FFFFFF68h
    3c4: mov     esi,0FFFFFF60h
    3c9: mov     edx,0FFFFFF00h
    3ce: call    ryo_h_Memmove
    3d3: jmp     3DAh
    3d5: jmp     190h
    3da: jmp     190h

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
     25: mov     rdi,[rbp+10h]
     29: mov     rdi,[rdi]
     2c: mov     [rbp-8],rdi
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
     dd: mov     rdx,[rbp+18h]
     e1: mov     rdx,[rdx]
     e4: mov     [rbp-50h],rdx
     e8: mov     [rbp-48h],rdx
     ec: mov     [rbp-58h],rax
     f0: mov     qword ptr [rbp-88h],0
     fb: mov     rdi,[rbp-88h]
    102: sub     rdi,rax
    105: mov     [rbp-50h],rdi
    109: imul    rcx,rdi,1
    10d: add     rdx,rcx
    110: mov     [rbp-40h],rdx
    114: mov     [rbp-60h],rdx
    118: mov     r8,[rbp-8]
    11c: mov     [rbp-0B0h],r8
    123: mov     [rbp-0A8h],rdx
    12a: mov     edi,0FFFFFF60h
    12f: mov     esi,0FFFFFF88h
    134: call    ryo_h_MovW128
    139: call    fn1
    13e: nop     [rcx-8]
    145: jmp     90h

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
     2d: mov     rdx,[rbp+28h]
     31: mov     [rbp-160h],rdx
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
     8b: mov     rdx,[rbp-8]
     8f: mov     [rbp-180h],rdx
     96: cmp     rax,rdx
     99: setb    [rbp-169h]
     a0: test    byte ptr [rbp-169h],0FFh
     a7: je      528h
     ad: jmp     483h
     b2: nop     [rax+rax]
     bb: nop     [rax+rax]
     c0: call    ryo_h_Unreachable
     c5: ud2
     c7: nop     [rax+rax]
     d0: jmp     440h
     d5: nop     [rax+rax]
     de: xchg    ax,ax
     e0: mov     rax,[rbp-158h]
     e7: mov     [rbp-0D8h],rax
     ee: mov     rax,[rax]
     f1: mov     [rbp-198h],rax
     f8: mov     [rbp-180h],rax
     ff: mov     rdx,[rbp-170h]
    106: add     rdx,1
    10a: mov     [rbp-190h],rdx
    111: imul    rdx,[rbp+28h]
    116: mov     [rbp-188h],rdx
    11d: mov     [rbp-1A0h],rdx
    124: mov     qword ptr [rbp-1D0h],0
    12f: mov     rdi,[rbp-1D0h]
    136: sub     rdi,rdx
    139: mov     [rbp-190h],rdi
    140: imul    rcx,rdi,1
    144: add     rax,rcx
    147: mov     [rbp-178h],rax
    14e: xchg    ax,ax
    150: mov     rax,[rbp-158h]
    157: mov     [rbp-0E0h],rax
    15e: mov     [rbp-190h],rax
    165: mov     rdx,[rbp-170h]
    16c: mov     [rbp-188h],rdx
    173: mov     rsi,[rbp+20h]
    177: mov     rsi,[rsi+28h]
    17b: mov     [rbp-1D0h],rsi
    182: mov     rdi,[rbp+18h]
    186: mov     [rbp-1F0h],rdi
    18d: mov     [rbp-1E8h],rax
    194: mov     [rbp-1E0h],rdx
    19b: mov     edi,0FFFFFE30h
    1a0: lea     rsi,[site1]
    1a7: call    ryo_h_CallInd
    1ac: test    rax,rax
    1af: je      1BCh
    1b1: call    rax
    1b3: nop     [rcx-180h]
    1ba: jmp     1CCh
    1bc: mov     rdi,rbp
    1bf: lea     rsi,[ro+4]
    1c6: call    qword ptr [sym2]
    1cc: mov     rax,[rbp-158h]
    1d3: mov     [rbp-0E8h],rax
    1da: mov     [rbp-190h],rax
    1e1: mov     [rbp-1F0h],rax
    1e8: mov     rdx,[rbp-180h]
    1ef: mov     [rbp-1E8h],rdx
    1f6: call    fn3
    1fb: nop     [rcx-188h]
    202: mov     rax,[rbp-158h]
    209: mov     [rbp-0F0h],rax
    210: mov     rdx,[rbp-180h]
    217: mov     [rbp-198h],rdx
    21e: mov     rax,[rax+8]
    222: mov     [rbp-1A0h],rax
    229: and     rdx,rax
    22c: mov     [rbp-1A8h],rdx
    233: mov     rsi,[rbp-170h]
    23a: sub     rsi,rdx
    23d: mov     [rbp-1B0h],rsi
    244: mov     rdi,[rbp-0F0h]
    24b: mov     rdi,[rdi+8]
    24f: mov     [rbp-1B8h],rdi
    256: and     rsi,rdi
    259: mov     [rbp-1A0h],rsi
    260: mov     qword ptr [rbp-1D0h],10h
    26b: mov     edi,0FFFFFE68h
    270: mov     esi,0FFFFFE60h
    275: mov     edx,0FFFFFE30h
    27a: call    ryo_h_DivUW64
    27f: mov     rax,[rbp-188h]
    286: sub     rax,[rbp-1A8h]
    28d: mov     [rbp-1B8h],rax
    294: mov     rdx,[rbp-0F0h]
    29b: mov     rdx,[rdx+8]
    29f: mov     [rbp-1C0h],rdx
    2a6: and     rax,rdx
    2a9: mov     [rbp-1B0h],rax
    2b0: mov     qword ptr [rbp-1D0h],10h
    2bb: mov     edi,0FFFFFE60h
    2c0: mov     esi,0FFFFFE50h
    2c5: mov     edx,0FFFFFE30h
    2ca: call    ryo_h_DivUW64
    2cf: mov     rax,[rbp-198h]
    2d6: cmp     rax,[rbp-1A0h]
    2dd: sete    [rbp-189h]
    2e4: test    byte ptr [rbp-189h],0FFh
    2eb: je      64Ah
    2f1: jmp     550h
    2f6: nop     [rax+rax]
    2ff: nop
    300: mov     rax,[rbp-158h]
    307: mov     [rbp-110h],rax
    30e: mov     rdx,[rbp-170h]
    315: sub     rdx,10h
    319: mov     [rbp-1B0h],rdx
    320: mov     rax,[rax+8]
    324: mov     [rbp-1B8h],rax
    32b: and     rdx,rax
    32e: mov     [rbp-1A8h],rdx
    335: add     rdx,10h
    339: mov     [rbp-1A0h],rdx
    340: mov     rsi,[rbp-110h]
    347: mov     rsi,[rsi]
    34a: mov     [rbp-1C0h],rsi
    351: mov     [rbp-1B8h],rsi
    358: imul    rcx,[rbp-170h],1
    360: add     rsi,rcx
    363: mov     [rbp-1B0h],rsi
    36a: mov     [rbp-1A8h],rsi
    371: mov     byte ptr [rbp-1D0h],0FFh
    378: movzx   ecx,byte ptr [rbp-1D0h]
    37f: mov     [rsi],cl
    381: mov     r8,[rbp-110h]
    388: mov     r8,[r8]
    38b: mov     [rbp-1C0h],r8
    392: mov     [rbp-1B8h],r8
    399: imul    rcx,[rbp-1A0h],1
    3a1: add     r8,rcx
    3a4: mov     [rbp-1B0h],r8
    3ab: mov     [rbp-1A8h],r8
    3b2: mov     byte ptr [rbp-1D0h],0FFh
    3b9: movzx   ecx,byte ptr [rbp-1D0h]
    3c0: mov     [r8],cl
    3c3: mov     r10,[rbp-178h]
    3ca: mov     [rbp-1A0h],r10
    3d1: imul    r11,[rbp+28h],1
    3d6: mov     [rbp-1D0h],r11
    3dd: mov     edi,0FFFFFE70h
    3e2: mov     esi,0FFFFFE60h
    3e7: mov     edx,0FFFFFE30h
    3ec: call    ryo_h_Memcpy
    3f1: jmp     440h
    3f3: nop     [rax+rax]
    3fc: nop     [rax]
    400: mov     rax,[rbp-178h]
    407: mov     [rbp-1A8h],rax
    40e: mov     rdx,[rbp+28h]
    412: mov     [rbp-1A0h],rdx
    419: mov     edi,0FFFFFE40h
    41e: mov     esi,0FFFFFE58h
    423: call    ryo_h_MovW128
    428: imul    rax,[rbp-1B8h],1
    430: mov     [rbp-1B0h],rax
    437: jmp     852h
    43c: nop     [rax]
    440: jmp     80h
    445: nop     [rax+rax]
    44e: xchg    ax,ax
    450: mov     edi,0FFFFFEC0h
    455: call    ryo_h_Resume
    45a: ud2
    45c: nop     [rax]
    460: lea     rax,[rbp-158h]
    467: mov     [rbp-1D0h],rax
    46e: mov     [rbp-1F0h],rax
    475: call    fn4
    47a: nop     [rcx-1D0h]
    481: jmp     450h
    483: mov     rax,[rbp-10h]
    487: mov     [rbp-178h],rax
    48e: add     rax,1
    492: mov     [rbp-180h],rax
    499: mov     [rbp-10h],rax
    49d: mov     rdx,[rbp-178h]
    4a4: mov     [rbp-160h],rdx
    4ab: mov     qword ptr [rbp-168h],1
    4b6: mov     [rbp-170h],rdx
    4bd: mov     rdi,[rbp-158h]
    4c4: mov     [rbp-0D0h],rdi
    4cb: mov     rdi,[rdi]
    4ce: mov     [rbp-190h],rdi
    4d5: mov     [rbp-188h],rdi
    4dc: imul    rcx,rdx,1
    4e0: add     rdi,rcx
    4e3: mov     [rbp-180h],rdi
    4ea: mov     [rbp-28h],rdi
    4ee: movzx   edi,byte ptr [rdi]
    4f1: mov     [rbp-173h],dil
    4f8: cmp     dil,80h
    4fc: sete    [rbp-172h]
    503: movzx   r9d,byte ptr [rbp-172h]
    50b: xor     r9b,1
    50f: mov     [rbp-171h],r9b
    516: test    byte ptr [rbp-171h],0FFh
    51d: je      0E0h
    523: jmp     0D0h
    528: mov     rax,[rbp-158h]
    52f: mov     [rbp-118h],rax
    536: mov     rax,[rax+8]
    53a: mov     [rbp-0A8h],rax
    541: cmp     rax,8
    545: jb      8B8h
    54b: jmp     8BAh
    550: mov     rax,[rbp-158h]
    557: mov     [rbp-0F8h],rax
    55e: mov     rdx,[rbp-180h]
    565: shr     rdx,39h
    569: mov     [rbp-198h],rdx
    570: and     rdx,7Fh
    574: mov     [rbp-1A0h],rdx
    57b: mov     edi,0FFFFFE76h
    580: mov     esi,0FFFFFE60h
    585: call    ryo_h_TruncW64W8
    58a: movzx   eax,byte ptr [rbp-18Ah]
    591: mov     [rbp-189h],al
    597: mov     rdx,[rbp-170h]
    59e: sub     rdx,10h
    5a2: mov     [rbp-1A8h],rdx
    5a9: mov     rsi,[rbp-0F8h]
    5b0: mov     rsi,[rsi+8]
    5b4: mov     [rbp-1B0h],rsi
    5bb: and     rdx,rsi
    5be: mov     [rbp-1A0h],rdx
    5c5: add     rdx,10h
    5c9: mov     [rbp-198h],rdx
    5d0: mov     rdi,[rbp-0F8h]
    5d7: mov     rdi,[rdi]
    5da: mov     [rbp-1B8h],rdi
    5e1: mov     [rbp-1B0h],rdi
    5e8: imul    rcx,[rbp-170h],1
    5f0: add     rdi,rcx
    5f3: mov     [rbp-1A8h],rdi
    5fa: mov     [rbp-1A0h],rdi
    601: movzx   ecx,byte ptr [rbp-189h]
    608: mov     [rdi],cl
    60a: mov     r8,[rbp-0F8h]
    611: mov     r8,[r8]
    614: mov     [rbp-1B8h],r8
    61b: mov     [rbp-1B0h],r8
    622: imul    rcx,[rbp-198h],1
    62a: add     r8,rcx
    62d: mov     [rbp-1A8h],r8
    634: mov     [rbp-1A0h],r8
    63b: movzx   ecx,byte ptr [rbp-189h]
    642: mov     [r8],cl
    645: jmp     440h
    64a: mov     rax,[rbp-158h]
    651: mov     [rbp-100h],rax
    658: mov     rax,[rax]
    65b: mov     [rbp-1B0h],rax
    662: mov     [rbp-198h],rax
    669: mov     rdx,[rbp-188h]
    670: add     rdx,1
    674: mov     [rbp-1A8h],rdx
    67b: imul    rdx,[rbp+28h]
    680: mov     [rbp-1A0h],rdx
    687: mov     [rbp-1B8h],rdx
    68e: mov     qword ptr [rbp-1D0h],0
    699: mov     rdi,[rbp-1D0h]
    6a0: sub     rdi,rdx
    6a3: mov     [rbp-1A8h],rdi
    6aa: imul    rcx,rdi,1
    6ae: add     rax,rcx
    6b1: mov     [rbp-190h],rax
    6b8: mov     r8,[rbp-158h]
    6bf: mov     [rbp-108h],r8
    6c6: mov     r8,[r8]
    6c9: mov     [rbp-1B8h],r8
    6d0: mov     [rbp-1B0h],r8
    6d7: imul    rcx,[rbp-188h],1
    6df: add     r8,rcx
    6e2: mov     [rbp-1A8h],r8
    6e9: mov     [rbp-1A0h],r8
    6f0: movzx   r8d,byte ptr [r8]
    6f4: mov     [rbp-191h],r8b
    6fb: mov     r9,[rbp-180h]
    702: shr     r9,39h
    706: mov     [rbp-1A0h],r9
    70d: and     r9,7Fh
    711: mov     [rbp-1A8h],r9
    718: mov     edi,0FFFFFE6Dh
    71d: mov     esi,0FFFFFE58h
    722: call    ryo_h_TruncW64W8
    727: movzx   eax,byte ptr [rbp-193h]
    72e: mov     [rbp-192h],al
    734: mov     rdx,[rbp-188h]
    73b: sub     rdx,10h
    73f: mov     [rbp-1B0h],rdx
    746: mov     rsi,[rbp-108h]
    74d: mov     rsi,[rsi+8]
    751: mov     [rbp-1B8h],rsi
    758: and     rdx,rsi
    75b: mov     [rbp-1A8h],rdx
    762: add     rdx,10h
    766: mov     [rbp-1A0h],rdx
    76d: mov     rdi,[rbp-108h]
    774: mov     rdi,[rdi]
    777: mov     [rbp-1C0h],rdi
    77e: mov     [rbp-1B8h],rdi
    785: imul    rcx,[rbp-188h],1
    78d: add     rdi,rcx
    790: mov     [rbp-1B0h],rdi
    797: mov     [rbp-1A8h],rdi
    79e: movzx   ecx,byte ptr [rbp-192h]
    7a5: mov     [rdi],cl
    7a7: mov     r8,[rbp-108h]
    7ae: mov     r8,[r8]
    7b1: mov     [rbp-1C0h],r8
    7b8: mov     [rbp-1B8h],r8
    7bf: imul    rcx,[rbp-1A0h],1
    7c7: add     r8,rcx
    7ca: mov     [rbp-1B0h],r8
    7d1: mov     [rbp-1A8h],r8
    7d8: movzx   ecx,byte ptr [rbp-192h]
    7df: mov     [r8],cl
    7e2: movzx   r9d,byte ptr [rbp-191h]
    7ea: mov     [rbp-193h],r9b
    7f1: cmp     r9b,0FFh
    7f5: sete    [rbp-192h]
    7fc: test    byte ptr [rbp-192h],0FFh
    803: je      400h
    809: jmp     300h
    80e: mov     rax,[rbp-1B8h]
    815: mov     [rbp-1C0h],rax
    81c: mov     rdx,[rbp-178h]
    823: mov     [rbp-1F0h],rdx
    82a: mov     rsi,[rbp-190h]
    831: mov     [rbp-1E8h],rsi
    838: mov     [rbp-1E0h],rax
    83f: call    fn5
    844: nop     [rcx-138h]
    84b: jmp     84Dh
    84d: jmp     150h
    852: mov     rax,[rbp-1B0h]
    859: mov     [rbp-1B8h],rax
    860: mov     edi,0FFFFFE34h
    865: mov     esi,0FFFFFE48h
    86a: xor     edx,edx
    86c: xor     ecx,ecx
    86e: xor     r8d,r8d
    871: mov     r9d,1
    877: call    ryo_h_DiscrNicheW64
    87c: mov     edi,0FFFFFE38h
    881: mov     esi,0FFFFFE34h
    886: call    ryo_h_ZextW32W64
    88b: mov     edi,0FFFFFE38h
    890: xor     esi,esi
    892: mov     edx,2
    897: call    ryo_h_SwitchDenseW64
    89c: lea     rcx,[8ACh]
    8a3: movsxd  rax,[rcx+rax*4]
    8a7: add     rax,rcx
    8aa: jmp     rax
    8ac: .long   84dh
    8b0: .long   80eh
    8b4: .long   c0h
    8b8: jmp     8FAh
    8ba: mov     rax,[rbp-0A8h]
    8c1: add     rax,1
    8c5: mov     [rbp-170h],rax
    8cc: mov     qword ptr [rbp-1D0h],8
    8d7: mov     edi,0FFFFFE98h
    8dc: mov     esi,0FFFFFE90h
    8e1: mov     edx,0FFFFFE30h
    8e6: call    ryo_h_DivUW64
    8eb: imul    rax,[rbp-168h],7
    8f3: mov     [rbp-0A8h],rax
    8fa: mov     rax,[rbp-158h]
    901: mov     [rbp-120h],rax
    908: mov     rax,[rax+18h]
    90c: mov     [rbp-160h],rax
    913: mov     rdx,[rbp-158h]
    91a: mov     [rbp-128h],rdx
    921: mov     rsi,[rbp-0A8h]
    928: sub     rsi,rax
    92b: mov     [rbp-1D0h],rsi
    932: mov     rcx,[rbp-1D0h]
    939: mov     [rdx+10h],rcx
    93d: mov     rdi,[rbp-150h]
    944: mov     [rbp-168h],rdi
    94b: mov     r8,[rbp-148h]
    952: mov     [rbp-170h],r8
    959: mov     r9,[rbp-158h]
    960: mov     [rbp-160h],r9
    967: xor     edi,edi
    969: xor     esi,esi
    96b: call    ryo_h_Ret
    970: leave
    971: ret
    972: nop     [rax+rax]
    97b: nop     [rax+rax]
    980: lea     rdi,[sym6]
    987: lea     rsi,[site7]
    98e: mov     edx,0FFFFFE30h
    993: call    ryo_h_CallExt
    998: test    rax,rax
    99b: je      9A8h
    99d: call    rax
    99f: nop     [rcx-1C8h]
    9a6: jmp     9B8h
    9a8: mov     rdi,rbp
    9ab: lea     rsi,[ro+20]
    9b2: call    qword ptr [sym8]
    9b8: call    ryo_h_Unreachable
    9bd: ud2
    9bf: mov     rdi,rax
    9c2: mov     esi,0FFFFFEC0h
    9c7: call    ryo_h_Lpad
    9cc: jmp     460h
    9d1: mov     rdi,rax
    9d4: mov     esi,0FFFFFEC0h
    9d9: call    ryo_h_Lpad
    9de: jmp     980h

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
     4b: mov     rdx,[rbp-8]
     4f: mov     [rbp-0B0h],rdx
     56: cmp     rax,rdx
     59: setb    [rbp-99h]
     60: test    byte ptr [rbp-99h],0FFh
     67: je      344h
     6d: jmp     2B5h
     72: nop     [rax+rax]
     7b: nop     [rax+rax]
     80: call    ryo_h_Unreachable
     85: ud2
     87: nop     [rax+rax]
     90: mov     rax,[rbp+18h]
     94: mov     rax,[rax]
     97: mov     [rbp-50h],rax
     9b: mov     rdx,[rbp-0A0h]
     a2: sub     rdx,10h
     a6: mov     [rbp-0C0h],rdx
     ad: mov     rax,[rax+8]
     b1: mov     [rbp-0C8h],rax
     b8: and     rdx,rax
     bb: mov     [rbp-0B8h],rdx
     c2: add     rdx,10h
     c6: mov     [rbp-0B0h],rdx
     cd: mov     rsi,[rbp-50h]
     d1: mov     rsi,[rsi]
     d4: mov     [rbp-0D0h],rsi
     db: mov     [rbp-0C8h],rsi
     e2: imul    rcx,[rbp-0A0h],1
     ea: add     rsi,rcx
     ed: mov     [rbp-0C0h],rsi
     f4: mov     [rbp-0B8h],rsi
     fb: mov     byte ptr [rbp-0F0h],0FFh
    102: movzx   ecx,byte ptr [rbp-0F0h]
    109: mov     [rsi],cl
    10b: mov     r8,[rbp-50h]
    10f: mov     r8,[r8]
    112: mov     [rbp-0D0h],r8
    119: mov     [rbp-0C8h],r8
    120: imul    rcx,[rbp-0B0h],1
    128: add     r8,rcx
    12b: mov     [rbp-0C0h],r8
    132: mov     [rbp-0B8h],r8
    139: mov     byte ptr [rbp-0F0h],0FFh
    140: movzx   ecx,byte ptr [rbp-0F0h]
    147: mov     [r8],cl
    14a: mov     r10,[rbp+10h]
    14e: mov     r10,[r10]
    151: mov     [rbp-0F0h],r10
    158: mov     edi,0FFFFFF0Ch
    15d: mov     esi,0FFFFFF10h
    162: xor     edx,edx
    164: xor     ecx,ecx
    166: xor     r8d,r8d
    169: mov     r9d,1
    16f: call    ryo_h_DiscrNicheW64
    174: mov     edi,0FFFFFFD8h
    179: mov     esi,0FFFFFF0Ch
    17e: call    ryo_h_ZextW32W64
    183: mov     edi,0FFFFFFD8h
    188: xor     esi,esi
    18a: mov     edx,2
    18f: call    ryo_h_SwitchDenseW64
    194: lea     rcx,[1A4h]
    19b: movsxd  rax,[rcx+rax*4]
    19f: add     rax,rcx
    1a2: jmp     rax
    1a4: .long   26fh
    1a8: .long   1b0h
    1ac: .long   80h
    1b0: mov     rax,[rbp+10h]
    1b4: mov     rax,[rax]
    1b7: mov     [rbp-0B0h],rax
    1be: mov     rdx,[rbp+18h]
    1c2: mov     rdx,[rdx]
    1c5: mov     [rbp-58h],rdx
    1c9: mov     rsi,[rbp+10h]
    1cd: mov     rsi,[rsi+8]
    1d1: mov     [rbp-0C0h],rsi
    1d8: mov     rdx,[rdx]
    1db: mov     [rbp-0E0h],rdx
    1e2: mov     [rbp-0C8h],rdx
    1e9: mov     rdi,[rbp-0A0h]
    1f0: add     rdi,1
    1f4: mov     [rbp-0D8h],rdi
    1fb: imul    rdi,rsi
    1ff: mov     [rbp-0D0h],rdi
    206: mov     [rbp-0E8h],rdi
    20d: mov     qword ptr [rbp-0F0h],0
    218: mov     r9,[rbp-0F0h]
    21f: sub     r9,rdi
    222: mov     [rbp-0D8h],r9
    229: imul    rcx,r9,1
    22d: add     rdx,rcx
    230: mov     [rbp-0B8h],rdx
    237: mov     [rbp-110h],rdx
    23e: mov     edi,0FFFFFF50h
    243: lea     rsi,[site0]
    24a: call    ryo_h_CallInd
    24f: test    rax,rax
    252: je      25Fh
    254: call    rax
    256: nop     [rcx-28h]
    25d: jmp     26Fh
    25f: mov     rdi,rbp
    262: lea     rsi,[ro+4]
    269: call    qword ptr [sym1]
    26f: mov     rax,[rbp+18h]
    273: mov     rax,[rax]
    276: mov     [rbp-60h],rax
    27a: mov     rdx,[rbp+18h]
    27e: mov     rdx,[rdx]
    281: mov     [rbp-68h],rdx
    285: mov     rdx,[rdx+18h]
    289: mov     [rbp-0F0h],rdx
    290: sub     rdx,1
    294: mov     [rbp-100h],rdx
    29b: mov     rcx,[rbp-100h]
    2a2: mov     [rax+18h],rcx
    2a6: nop     [rax+rax]
    2af: nop
    2b0: jmp     40h
    2b5: mov     rax,[rbp-10h]
    2b9: mov     [rbp-0A8h],rax
    2c0: add     rax,1
    2c4: mov     [rbp-0B0h],rax
    2cb: mov     [rbp-10h],rax
    2cf: mov     rdx,[rbp-0A8h]
    2d6: mov     [rbp-90h],rdx
    2dd: mov     qword ptr [rbp-98h],1
    2e8: mov     [rbp-0A0h],rdx
    2ef: mov     rdi,[rbp+18h]
    2f3: mov     rdi,[rdi]
    2f6: mov     [rbp-40h],rdi
    2fa: mov     rdi,[rdi]
    2fd: mov     [rbp-0C0h],rdi
    304: mov     [rbp-0B8h],rdi
    30b: imul    rcx,rdx,1
    30f: add     rdi,rcx
    312: mov     [rbp-0B0h],rdi
    319: mov     [rbp-20h],rdi
    31d: movzx   edi,byte ptr [rdi]
    320: mov     [rbp-0A2h],dil
    327: cmp     dil,80h
    32b: sete    [rbp-0A1h]
    332: test    byte ptr [rbp-0A1h],0FFh
    339: je      2B0h
    33f: jmp     90h
    344: mov     rax,[rbp+18h]
    348: mov     rax,[rax]
    34b: mov     [rbp-48h],rax
    34f: mov     rax,[rax+8]
    353: mov     [rbp-30h],rax
    357: cmp     rax,8
    35b: jae     35Fh
    35d: jmp     399h
    35f: mov     rax,[rbp-30h]
    363: add     rax,1
    367: mov     [rbp-0A0h],rax
    36e: mov     qword ptr [rbp-0F0h],8
    379: mov     edi,0FFFFFF68h
    37e: mov     esi,0FFFFFF60h
    383: mov     edx,0FFFFFF10h
    388: call    ryo_h_DivUW64
    38d: imul    rax,[rbp-98h],7
    395: mov     [rbp-30h],rax
    399: mov     rax,[rbp+18h]
    39d: mov     rax,[rax]
    3a0: mov     [rbp-70h],rax
    3a4: mov     rax,[rax+18h]
    3a8: mov     [rbp-90h],rax
    3af: mov     rdx,[rbp+18h]
    3b3: mov     rdx,[rdx]
    3b6: mov     [rbp-78h],rdx
    3ba: mov     rsi,[rbp-30h]
    3be: sub     rsi,rax
    3c1: mov     [rbp-0F0h],rsi
    3c8: mov     rcx,[rbp-0F0h]
    3cf: mov     [rdx+10h],rcx
    3d3: xor     edi,edi
    3d5: xor     esi,esi
    3d7: call    ryo_h_Ret
    3dc: leave
    3dd: ret

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
     3b: je      1A1h
     41: jmp     15Ah
     46: nop     [rax+rax]
     4f: nop
     50: mov     edi,0FFFFFFF0h
     55: mov     esi,0FFFFFFD8h
     5a: call    ryo_h_MovW128
     5f: jmp     149h
     64: nop     [rax+rax]
     6d: nop     [rax]
     70: mov     rax,[rbp+38h]
     74: mov     [rbp-30h],rax
     78: mov     rdx,[rbp+10h]
     7c: mov     [rbp-90h],rdx
     83: mov     edi,0FFFFFF78h
     88: mov     esi,20h
     8d: call    ryo_h_MovW128
     92: mov     rax,[rbp-30h]
     96: mov     [rbp-78h],rax
     9a: mov     rdx,[rbp+50h]
     9e: mov     [rbp-70h],rdx
     a2: call    fn0
     a7: nop     [rcx-18h]
     ae: mov     edi,0FFFFFFF0h
     b3: lea     rsi,[k1]
     ba: mov     edx,10h
     bf: call    ryo_h_Const
     c4: jmp     149h
     c9: nop     [rax]
     d0: mov     rax,[rbp-18h]
     d4: add     rax,1
     d8: mov     [rbp-38h],rax
     dc: mov     rdx,[rbp-20h]
     e0: mov     [rbp-90h],rdx
     e7: mov     [rbp-88h],rax
     ee: call    fn2
     f3: nop     [rcx-30h]
     fa: mov     rax,[rbp+10h]
     fe: mov     [rbp-90h],rax
    105: mov     rdx,[rbp+18h]
    109: mov     [rbp-88h],rdx
    110: mov     rsi,[rbp-30h]
    114: mov     [rbp-70h],rsi
    118: mov     edi,0FFFFFF80h
    11d: mov     esi,20h
    122: call    ryo_h_MovW128
    127: movzx   eax,byte ptr [rbp+48h]
    12b: mov     [rbp-68h],al
    12e: mov     edi,0FFFFFFA0h
    133: mov     esi,38h
    138: call    ryo_h_MovW128
    13d: call    fn3
    142: nop     [rcx-10h]
    149: mov     edi,0FFFFFFF0h
    14e: mov     esi,10h
    153: call    ryo_h_Ret
    158: leave
    159: ret
    15a: movzx   eax,byte ptr [rbp+48h]
    15e: mov     [rbp-90h],al
    164: lea     rdi,[sym4]
    16b: lea     rsi,[site5]
    172: mov     edx,0FFFFFFB0h
    177: call    ryo_h_CallExt
    17c: test    rax,rax
    17f: je      18Ch
    181: call    rax
    183: nop     [rcx-28h]
    18a: jmp     19Ch
    18c: mov     rdi,rbp
    18f: lea     rsi,[ro+4]
    196: call    qword ptr [sym6]
    19c: jmp     50h
    1a1: mov     rax,[rbp-20h]
    1a5: add     rax,[rbp+30h]
    1a9: mov     [rbp-38h],rax
    1ad: mov     [rbp-28h],rax
    1b1: mov     qword ptr [rbp-30h],1
    1b9: mov     [rbp-20h],rax
    1bd: mov     rsi,[rbp+10h]
    1c1: mov     rsi,[rsi+8]
    1c5: mov     [rbp-18h],rsi
    1c9: cmp     rsi,8
    1cd: jae     1D1h
    1cf: jmp     202h
    1d1: mov     rax,[rbp-18h]
    1d5: add     rax,1
    1d9: mov     [rbp-38h],rax
    1dd: mov     qword ptr [rbp-50h],8
    1e5: mov     edi,0FFFFFFD0h
    1ea: mov     esi,0FFFFFFC8h
    1ef: mov     edx,0FFFFFFB0h
    1f4: call    ryo_h_DivUW64
    1f9: imul    rax,[rbp-30h],7
    1fe: mov     [rbp-18h],rax
    202: mov     rax,[rbp-18h]
    206: mov     [rbp-38h],rax
    20a: mov     qword ptr [rbp-50h],2
    212: mov     edi,0FFFFFFD0h
    217: mov     esi,0FFFFFFC8h
    21c: mov     edx,0FFFFFFB0h
    221: call    ryo_h_DivUW64
    226: mov     rax,[rbp-30h]
    22a: cmp     rax,[rbp-20h]
    22e: jae     70h
    234: jmp     0D0h

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
     30: movzx   edx,byte ptr [rbp+38h]
     34: mov     [rbp-220h],dl
     3a: call    fn0
     3f: nop     [rcx-1A0h]
     46: jmp     23Dh
     4b: nop     [rax+rax]
     50: call    ryo_h_Unreachable
     55: ud2
     57: nop     [rax+rax]
     60: lea     rax,[rbp-110h]
     67: mov     [rbp-128h],rax
     6e: mov     rax,[rax+10h]
     72: mov     [rbp-130h],rax
     79: cmp     rax,0
     7d: je      595h
     83: jmp     5B0h
     88: mov     rax,[rbp-118h]
     8f: mov     [rbp-130h],rax
     96: mov     rdx,[rbp+10h]
     9a: mov     [rbp-148h],rdx
     a1: mov     [rbp-140h],rax
     a8: mov     rsi,[rbp+28h]
     ac: mov     rsi,[rsi+28h]
     b0: mov     [rbp-1F0h],rsi
     b7: mov     rdi,[rbp+20h]
     bb: mov     [rbp-240h],rdi
     c2: mov     [rbp-238h],rdx
     c9: mov     [rbp-230h],rax
     d0: mov     edi,0FFFFFE10h
     d5: lea     rsi,[site1]
     dc: call    ryo_h_CallInd
     e1: test    rax,rax
     e4: je      0F1h
     e6: call    rax
     e8: nop     [rcx-138h]
     ef: jmp     101h
     f1: mov     rdi,rbp
     f4: lea     rsi,[ro+4]
     fb: call    qword ptr [sym2]
    101: jmp     1AFh
    106: nop     [rax+rax]
    10f: nop
    110: mov     rax,[rbp+10h]
    114: mov     rax,[rax+18h]
    118: mov     [rbp-0F8h],rax
    11f: mov     rdx,[rbp-0C8h]
    126: sub     rdx,rax
    129: mov     [rbp-0C8h],rdx
    130: mov     rsi,[rbp+10h]
    134: mov     rsi,[rsi+18h]
    138: mov     [rbp-0F8h],rsi
    13f: mov     [rbp-0C0h],rsi
    146: mov     rdi,[rbp+10h]
    14a: mov     [rbp-0F8h],rdi
    151: lea     r8,[rbp-0D8h]
    158: mov     [rbp-100h],r8
    15f: mov     qword ptr [rbp-218h],20h
    16a: mov     edi,0FFFFFDF0h
    16f: mov     esi,0FFFFFF08h
    174: xor     edx,edx
    176: mov     ecx,20h
    17b: call    ryo_h_LoadCopy
    180: mov     edi,0FFFFFF08h
    185: mov     esi,0FFFFFF00h
    18a: mov     edx,0FFFFFDE8h
    18f: call    ryo_h_Memcpy
    194: mov     edi,0FFFFFF00h
    199: xor     esi,esi
    19b: mov     edx,0FFFFFDF0h
    1a0: mov     ecx,20h
    1a5: call    ryo_h_StoreCopy
    1aa: jmp     841h
    1af: lea     rax,[rbp-0D8h]
    1b6: mov     [rbp-140h],rax
    1bd: mov     [rbp-240h],rax
    1c4: mov     rdx,[rbp-138h]
    1cb: mov     [rbp-238h],rdx
    1d2: call    fn3
    1d7: nop     [rcx-0B0h]
    1de: jmp     634h
    1e3: nop     [rax+rax]
    1ec: nop     [rax]
    1f0: mov     edi,0FFFFFFF0h
    1f5: mov     esi,10h
    1fa: call    ryo_h_Ret
    1ff: leave
    200: ret
    201: nop     [rax+rax]
    20a: nop     [rax+rax]
    210: lea     rax,[rbp-0F0h]
    217: mov     [rbp-1F0h],rax
    21e: mov     [rbp-240h],rax
    225: call    fn4
    22a: nop     [rcx-1F0h]
    231: mov     edi,0FFFFFF48h
    236: call    ryo_h_Resume
    23b: ud2
    23d: mov     edi,0FFFFFE14h
    242: mov     esi,0FFFFFE60h
    247: xor     edx,edx
    249: mov     ecx,1
    24e: mov     r8d,1
    254: xor     r9d,r9d
    257: call    ryo_h_DiscrNicheW64
    25c: mov     edi,0FFFFFE38h
    261: mov     esi,0FFFFFE14h
    266: call    ryo_h_ZextW32W64
    26b: mov     edi,0FFFFFE38h
    270: xor     esi,esi
    272: mov     edx,2
    277: call    ryo_h_SwitchDenseW64
    27c: lea     rcx,[28Ch]
    283: movsxd  rax,[rcx+rax*4]
    287: add     rax,rcx
    28a: jmp     rax
    28c: .long   3a6h
    290: .long   298h
    294: .long   50h
    298: mov     edi,0FFFFFE28h
    29d: mov     esi,0FFFFFE68h
    2a2: call    ryo_h_MovW128
    2a7: mov     edi,0FFFFFE18h
    2ac: mov     esi,0FFFFFE28h
    2b1: call    ryo_h_MovW128
    2b6: mov     edi,0FFFFFE88h
    2bb: mov     esi,0FFFFFE18h
    2c0: call    ryo_h_MovW128
    2c5: mov     qword ptr [rbp-180h],0
    2d0: mov     edi,0FFFFFE70h
    2d5: mov     esi,0FFFFFE88h
    2da: call    ryo_h_MovW128
    2df: mov     qword ptr [rbp-198h],1
    2ea: cmp     qword ptr [rbp-198h],1
    2f2: sete    [rbp-199h]
    2f9: mov     edi,0FFFFFE30h
    2fe: mov     esi,0FFFFFE70h
    303: call    ryo_h_MovW128
    308: mov     edi,0FFFFFEA8h
    30d: mov     esi,0FFFFFE30h
    312: call    ryo_h_MovW128
    317: mov     qword ptr [rbp-160h],0
    322: mov     edi,0FFFFFE90h
    327: mov     esi,0FFFFFEA8h
    32c: call    ryo_h_MovW128
    331: mov     edi,0FFFFFE80h
    336: mov     esi,0FFFFFE90h
    33b: call    ryo_h_MovW128
    340: mov     edi,0FFFFFEE0h
    345: mov     esi,0FFFFFE80h
    34a: call    ryo_h_MovW128
    34f: mov     qword ptr [rbp-128h],0
    35a: mov     edi,0FFFFFEC8h
    35f: mov     esi,0FFFFFEE0h
    364: call    ryo_h_MovW128
    369: mov     qword ptr [rbp-140h],1
    374: cmp     qword ptr [rbp-140h],1
    37c: sete    [rbp-151h]
    383: mov     edi,0FFFFFEB0h
    388: mov     esi,0FFFFFEC8h
    38d: call    ryo_h_MovW128
    392: mov     edi,0FFFFFFF0h
    397: mov     esi,0FFFFFEB0h
    39c: call    ryo_h_MovW128
    3a1: jmp     1F0h
    3a6: mov     edi,0FFFFFE18h
    3ab: mov     esi,0FFFFFE60h
    3b0: mov     edx,20h
    3b5: call    ryo_h_Copy
    3ba: mov     edi,0FFFFFE80h
    3bf: mov     esi,0FFFFFE18h
    3c4: mov     edx,20h
    3c9: call    ryo_h_Copy
    3ce: mov     edi,0FFFFFE40h
    3d3: mov     esi,0FFFFFE80h
    3d8: mov     edx,20h
    3dd: call    ryo_h_Copy
    3e2: mov     rax,[rbp+18h]
    3e6: mov     [rbp-1D8h],rax
    3ed: mov     edi,0FFFFFE30h
    3f2: mov     esi,40h
    3f7: call    ryo_h_MovW128
    3fc: mov     edi,0FFFFFE68h
    401: mov     esi,0FFFFFE28h
    406: mov     edx,18h
    40b: call    ryo_h_Copy
    410: mov     edi,0FFFFFE80h
    415: mov     esi,0FFFFFE40h
    41a: mov     edx,20h
    41f: call    ryo_h_Copy
    424: mov     edi,0FFFFFEA0h
    429: mov     esi,0FFFFFE68h
    42e: mov     edx,38h
    433: call    ryo_h_Copy
    438: mov     edi,0FFFFFE68h
    43d: mov     esi,0FFFFFEA0h
    442: mov     edx,38h
    447: call    ryo_h_Copy
    44c: mov     edi,0FFFFFED8h
    451: mov     esi,0FFFFFE68h
    456: mov     edx,38h
    45b: call    ryo_h_Copy
    460: mov     edi,0FFFFFEA0h
    465: mov     esi,0FFFFFED8h
    46a: mov     edx,38h
    46f: call    ryo_h_Copy
    474: mov     edi,0FFFFFF10h
    479: mov     esi,0FFFFFEA0h
    47e: mov     edx,38h
    483: call    ryo_h_Copy
    488: mov     rax,[rbp+10h]
    48c: mov     rax,[rax]
    48f: mov     [rbp-118h],rax
    496: mov     [rbp-110h],rax
    49d: mov     rdx,[rbp-118h]
    4a4: mov     [rbp-0F8h],rdx
    4ab: mov     rsi,[rbp-118h]
    4b2: mov     [rbp-108h],rsi
    4b9: mov     rdi,[rbp-118h]
    4c0: mov     [rbp-120h],rdi
    4c7: mov     [rbp-240h],rdi
    4ce: mov     edi,0FFFFFE10h
    4d3: lea     rsi,[sym5]
    4da: call    ryo_h_AddrSym
    4df: mov     rdi,rbp
    4e2: lea     rsi,[ro+20]
    4e9: call    qword ptr [sym6]
    4ef: mov     edi,0FFFFFDC0h
    4f4: mov     esi,0FFFFFED0h
    4f9: call    ryo_h_MovW128
    4fe: mov     edi,0FFFFFE10h
    503: lea     rsi,[sym7]
    50a: call    ryo_h_AddrSym
    50f: mov     rdi,rbp
    512: lea     rsi,[ro+36]
    519: call    qword ptr [sym8]
    51f: mov     edi,0FFFFFF00h
    524: mov     esi,0FFFFFEFCh
    529: call    ryo_h_TruncW32W16
    52e: mov     edi,0FFFFFF02h
    533: mov     esi,0FFFFFF00h
    538: call    ryo_h_NotW16
    53d: movzx   eax,word ptr [rbp-0FEh]
    544: mov     [rbp-0FCh],ax
    54b: mov     [rbp-0FAh],ax
    552: mov     rdx,[rbp+10h]
    556: mov     rdx,[rdx+18h]
    55a: mov     [rbp-108h],rdx
    561: mov     [rbp-18h],ax
    565: mov     qword ptr [rbp-28h],0
    56d: mov     rdi,[rbp-118h]
    574: mov     [rbp-30h],rdi
    578: mov     [rbp-20h],rdx
    57c: mov     edi,0FFFFFEF0h
    581: mov     esi,0FFFFFFD0h
    586: mov     edx,20h
    58b: call    ryo_h_Copy
    590: jmp     60h
    595: mov     edi,0FFFFFEE0h
    59a: lea     rsi,[k9]
    5a1: mov     edx,10h
    5a6: call    ryo_h_Const
    5ab: jmp     110h
    5b0: mov     rax,[rbp-128h]
    5b7: mov     [rbp-240h],rax
    5be: call    fn10
    5c3: nop     [rcx-120h]
    5ca: mov     rax,[rbp-128h]
    5d1: mov     rax,[rax+10h]
    5d5: mov     [rbp-1F0h],rax
    5dc: sub     rax,1
    5e0: mov     [rbp-200h],rax
    5e7: mov     rdx,[rbp-128h]
    5ee: mov     rcx,[rbp-200h]
    5f5: mov     [rdx+10h],rcx
    5f9: mov     rsi,[rbp-120h]
    600: mov     [rbp-38h],rsi
    604: mov     edi,0FFFFFFC8h
    609: xor     esi,esi
    60b: mov     edx,2
    610: call    ryo_h_SwitchDenseW64
    615: lea     rcx,[628h]
    61c: movsxd  rax,[rcx+rax*4]
    620: add     rax,rcx
    623: jmp     rax
    625: int3
    626: int3
    627: int3
    628: .long   110h
    62c: .long   88h
    630: .long   50h
    634: mov     rax,[rbp-0D8h]
    63b: mov     [rbp-158h],rax
    642: mov     [rbp-150h],rax
    649: imul    rcx,[rbp-0B0h],1
    651: add     rax,rcx
    654: mov     [rbp-148h],rax
    65b: mov     [rbp-140h],rax
    662: movzx   eax,byte ptr [rax]
    665: mov     [rbp-169h],al
    66b: mov     rdx,[rbp-138h]
    672: shr     rdx,39h
    676: mov     [rbp-148h],rdx
    67d: and     rdx,7Fh
    681: mov     [rbp-150h],rdx
    688: mov     edi,0FFFFFEC6h
    68d: mov     esi,0FFFFFEB0h
    692: call    ryo_h_TruncW64W8
    697: movzx   eax,byte ptr [rbp-13Ah]
    69e: mov     [rbp-139h],al
    6a4: mov     rdx,[rbp-0B0h]
    6ab: sub     rdx,10h
    6af: mov     [rbp-158h],rdx
    6b6: mov     rsi,[rbp-0D0h]
    6bd: mov     [rbp-160h],rsi
    6c4: and     rdx,rsi
    6c7: mov     [rbp-150h],rdx
    6ce: add     rdx,10h
    6d2: mov     [rbp-148h],rdx
    6d9: mov     rdi,[rbp-0D8h]
    6e0: mov     [rbp-168h],rdi
    6e7: mov     [rbp-160h],rdi
    6ee: imul    rcx,[rbp-0B0h],1
    6f6: add     rdi,rcx
    6f9: mov     [rbp-158h],rdi
    700: mov     [rbp-150h],rdi
    707: movzx   ecx,byte ptr [rbp-139h]
    70e: mov     [rdi],cl
    710: mov     r8,[rbp-0D8h]
    717: mov     [rbp-168h],r8
    71e: mov     [rbp-160h],r8
    725: imul    rcx,[rbp-148h],1
    72d: add     r8,rcx
    730: mov     [rbp-158h],r8
    737: mov     [rbp-150h],r8
    73e: movzx   ecx,byte ptr [rbp-139h]
    745: mov     [r8],cl
    748: mov     r9,[rbp+40h]
    74c: mov     [rbp-50h],r9
    750: mov     r10,[rbp+10h]
    754: mov     r10,[r10]
    757: mov     [rbp-168h],r10
    75e: mov     [rbp-150h],r10
    765: mov     r11,[rbp-130h]
    76c: add     r11,1
    770: mov     [rbp-160h],r11
    777: imul    r11,r9
    77b: mov     [rbp-158h],r11
    782: mov     [rbp-170h],r11
    789: mov     qword ptr [rbp-1F0h],0
    794: mov     rsi,[rbp-1F0h]
    79b: sub     rsi,r11
    79e: mov     [rbp-160h],rsi
    7a5: imul    rcx,rsi,1
    7a9: add     r10,rcx
    7ac: mov     [rbp-148h],r10
    7b3: mov     [rbp-140h],r10
    7ba: mov     rdx,[rbp-0D8h]
    7c1: mov     [rbp-168h],rdx
    7c8: mov     [rbp-150h],rdx
    7cf: mov     rdi,[rbp-0B0h]
    7d6: add     rdi,1
    7da: mov     [rbp-160h],rdi
    7e1: imul    rdi,r9
    7e5: mov     [rbp-158h],rdi
    7ec: mov     [rbp-170h],rdi
    7f3: mov     qword ptr [rbp-1F0h],0
    7fe: mov     rax,[rbp-1F0h]
    805: sub     rax,rdi
    808: mov     [rbp-160h],rax
    80f: imul    rcx,rax,1
    813: add     rdx,rcx
    816: mov     [rbp-148h],rdx
    81d: imul    r11,r9,1
    821: mov     [rbp-1F0h],r11
    828: mov     edi,0FFFFFEB8h
    82d: mov     esi,0FFFFFEC0h
    832: mov     edx,0FFFFFE10h
    837: call    ryo_h_Memcpy
    83c: jmp     60h
    841: mov     edi,0FFFFFFF0h
    846: lea     rsi,[k11]
    84d: mov     edx,10h
    852: call    ryo_h_Const
    857: lea     rax,[rbp-0F0h]
    85e: mov     [rbp-1F0h],rax
    865: mov     [rbp-240h],rax
    86c: call    fn12
    871: nop     [rcx-1F0h]
    878: jmp     1F0h
    87d: nop     [rax]
    880: lea     rdi,[sym13]
    887: lea     rsi,[site14]
    88e: mov     edx,0FFFFFE10h
    893: call    ryo_h_CallExt
    898: test    rax,rax
    89b: je      8A8h
    89d: call    rax
    89f: nop     [rcx-1E8h]
    8a6: jmp     8B8h
    8a8: mov     rdi,rbp
    8ab: lea     rsi,[ro+52]
    8b2: call    qword ptr [sym15]
    8b8: call    ryo_h_Unreachable
    8bd: ud2
    8bf: mov     rdi,rax
    8c2: mov     esi,0FFFFFF48h
    8c7: call    ryo_h_Lpad
    8cc: jmp     210h
    8d1: mov     rdi,rax
    8d4: mov     esi,0FFFFFF48h
    8d9: call    ryo_h_Lpad
    8de: jmp     880h

fn hashbrown::raw::TableLayout::calculate_layout_for
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0D0h
      b: mov     rax,[rbp+10h]
      f: mov     [rbp-48h],rax
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-50h],rdx
     1b: mov     [rbp-0A0h],rax
     22: mov     rsi,[rbp+20h]
     26: mov     [rbp-0C0h],rsi
     2d: mov     edi,0FFFFFF48h
     32: mov     esi,0FFFFFF50h
     37: mov     edx,0FFFFFF60h
     3c: mov     ecx,0FFFFFF40h
     41: call    ryo_h_MulOvfUW64
     46: mov     rax,[rbp-0B8h]
     4d: mov     [rbp-0A0h],rax
     54: movzx   edx,byte ptr [rbp-0B0h]
     5b: mov     [rbp-0A1h],dl
     61: mov     [rbp-0C8h],rax
     68: test    byte ptr [rbp-0A1h],0FFh
     6f: je      13Bh
     75: jmp     101h
     7a: nop     [rax+rax]
     80: mov     qword ptr [rbp-18h],0
     88: jmp     0E0h
     8a: nop     [rax+rax]
     90: mov     rax,[rbp-50h]
     94: mov     [rbp-88h],rax
     9b: mov     rdx,[rbp-40h]
     9f: mov     [rbp-78h],rdx
     a3: mov     [rbp-80h],rax
     a7: mov     edi,0FFFFFF90h
     ac: mov     esi,0FFFFFF80h
     b1: call    ryo_h_MovW128
     b6: mov     rax,[rbp-58h]
     ba: mov     [rbp-60h],rax
     be: mov     edi,0FFFFFFE8h
     c3: mov     esi,0FFFFFF90h
     c8: mov     edx,18h
     cd: call    ryo_h_Copy
     d2: jmp     0F0h
     d4: nop     [rax+rax]
     dd: nop     [rax]
     e0: jmp     0F0h
     e2: nop     [rax+rax]
     eb: nop     [rax+rax]
     f0: mov     edi,0FFFFFFE8h
     f5: mov     esi,18h
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: mov     edi,0FFFFFF68h
    106: lea     rsi,[k0]
    10d: mov     edx,10h
    112: call    ryo_h_Const
    117: mov     qword ptr [rbp-90h],0
    122: cmp     qword ptr [rbp-90h],0
    12a: sete    [rbp-91h]
    131: mov     qword ptr [rbp-18h],0
    139: jmp     0F0h
    13b: mov     rax,[rbp-0C8h]
    142: mov     [rbp-90h],rax
    149: mov     qword ptr [rbp-98h],1
    154: mov     [rbp-0A0h],rax
    15b: mov     [rbp-80h],rax
    15f: mov     qword ptr [rbp-88h],0
    16a: mov     [rbp-28h],rax
    16e: mov     rdi,[rbp-50h]
    172: sub     rdi,1
    176: mov     [rbp-30h],rdi
    17a: mov     edi,0FFFFFF60h
    17f: mov     esi,0FFFFFF68h
    184: mov     edx,0FFFFFFD8h
    189: mov     ecx,0FFFFFFD0h
    18e: call    ryo_h_AddOvfUW64
    193: movzx   eax,byte ptr [rbp-98h]
    19a: mov     [rbp-89h],al
    1a0: test    byte ptr [rbp-89h],0FFh
    1a7: je      1DDh
    1a9: mov     edi,0FFFFFF88h
    1ae: lea     rsi,[k1]
    1b5: mov     edx,10h
    1ba: call    ryo_h_Const
    1bf: mov     qword ptr [rbp-70h],0
    1c7: cmp     qword ptr [rbp-70h],0
    1cc: sete    [rbp-71h]
    1d0: mov     qword ptr [rbp-18h],0
    1d8: jmp     0F0h
    1dd: mov     rax,[rbp-28h]
    1e1: add     rax,[rbp-30h]
    1e5: mov     [rbp-90h],rax
    1ec: mov     [rbp-70h],rax
    1f0: mov     qword ptr [rbp-78h],1
    1f8: mov     [rbp-90h],rax
    1ff: mov     [rbp-60h],rax
    203: mov     qword ptr [rbp-68h],0
    20b: mov     [rbp-38h],rax
    20f: mov     edi,0FFFFFF90h
    214: mov     esi,0FFFFFFD0h
    219: call    ryo_h_NotW64
    21e: mov     rax,[rbp-38h]
    222: and     rax,[rbp-70h]
    226: mov     [rbp-58h],rax
    22a: mov     rdx,[rbp+20h]
    22e: add     rdx,10h
    232: mov     [rbp-80h],rdx
    236: mov     edi,0FFFFFF68h
    23b: mov     esi,0FFFFFF70h
    240: mov     edx,0FFFFFFA8h
    245: mov     ecx,0FFFFFF80h
    24a: call    ryo_h_AddOvfUW64
    24f: movzx   eax,byte ptr [rbp-90h]
    256: mov     [rbp-81h],al
    25c: test    byte ptr [rbp-81h],0FFh
    263: je      299h
    265: mov     edi,0FFFFFF88h
    26a: lea     rsi,[k2]
    271: mov     edx,10h
    276: call    ryo_h_Const
    27b: mov     qword ptr [rbp-70h],0
    283: cmp     qword ptr [rbp-70h],0
    288: sete    [rbp-71h]
    28c: mov     qword ptr [rbp-18h],0
    294: jmp     0E0h
    299: mov     rax,[rbp-58h]
    29d: add     rax,[rbp-80h]
    2a1: mov     [rbp-88h],rax
    2a8: mov     [rbp-70h],rax
    2ac: mov     qword ptr [rbp-78h],1
    2b4: mov     [rbp-80h],rax
    2b8: mov     [rbp-60h],rax
    2bc: mov     qword ptr [rbp-68h],0
    2c4: mov     [rbp-40h],rax
    2c8: mov     rdi,7FFFFFFFFFFFFFFFh
    2d2: mov     [rbp-0D0h],rdi
    2d9: sub     rdi,[rbp-30h]
    2dd: mov     [rbp-68h],rdi
    2e1: cmp     rdi,rax
    2e4: jb      80h
    2ea: jmp     90h

fn hashbrown::raw::capacity_to_buckets
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: cmp     qword ptr [rbp+10h],0Fh
     10: jae     106h
     16: mov     rdx,[rbp+18h]
     1a: mov     [rbp-38h],rdx
     1e: mov     qword ptr [rbp-0A8h],0
     29: mov     rdi,[rbp-0A8h]
     30: cmp     rdi,rdx
     33: setbe   [rbp-3Bh]
     37: test    byte ptr [rbp-3Bh],0FFh
     3b: je      60h
     3d: jmp     89h
     3f: nop
     40: mov     qword ptr [rbp-30h],3
     48: jmp     9Ah
     4a: nop     [rax+rax]
     50: mov     qword ptr [rbp-30h],0Eh
     58: jmp     9Ah
     5a: nop     [rax+rax]
     60: mov     qword ptr [rbp-0A8h],2
     6b: mov     rdx,[rbp-0A8h]
     72: cmp     rdx,[rbp-38h]
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
     a5: mov     rdx,[rbp+10h]
     a9: mov     [rbp-0B8h],rdx
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
     f1: mov     rdx,[rbp-48h]
     f5: mov     [rbp-68h],rdx
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
    13d: movzx   edx,byte ptr [rbp-90h]
    144: mov     [rbp-81h],dl
    14a: mov     [rbp-0A0h],rax
    151: test    byte ptr [rbp-81h],0FFh
    158: je      233h
    15e: jmp     1F1h
    163: nop     [rax+rax]
    16c: nop     [rax]
    170: mov     edi,0FFFFFFF0h
    175: mov     esi,10h
    17a: call    ryo_h_Ret
    17f: leave
    180: ret
    181: mov     rax,[rbp-38h]
    185: mov     [rbp-70h],rax
    189: mov     rdx,[rbp-68h]
    18d: mov     [rbp-88h],rdx
    194: mov     edi,0FFFFFF80h
    199: mov     esi,0FFFFFF88h
    19e: mov     edx,0FFFFFF90h
    1a3: mov     ecx,0FFFFFF78h
    1a8: call    ryo_h_MulOvfUW64
    1ad: mov     rax,[rbp-80h]
    1b1: mov     [rbp-70h],rax
    1b5: movzx   edx,byte ptr [rbp-78h]
    1b9: mov     [rbp-52h],dl
    1bc: mov     [rbp-90h],rax
    1c3: test    byte ptr [rbp-52h],0FFh
    1c7: je      1EFh
    1c9: jmp     1E2h
    1cb: nop     [rax+rax]
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
    27e: jbe     33Ah
    284: jmp     347h
    289: nop     [rax]
    290: mov     rax,[rbp-78h]
    294: mov     [rbp-60h],rax
    298: mov     rdx,[rbp+18h]
    29c: mov     [rbp-98h],rdx
    2a3: mov     rsi,[rbp+20h]
    2a7: mov     [rbp-0A0h],rsi
    2ae: cmp     rdx,0
    2b2: je      3F0h
    2b8: jmp     3A1h
    2bd: nop     [rax]
    2c0: mov     qword ptr [rbp-0A8h],1
    2cb: mov     edi,0FFFFFF88h
    2d0: mov     esi,0FFFFFF90h
    2d5: mov     edx,0FFFFFF98h
    2da: mov     ecx,0FFFFFF58h
    2df: call    ryo_h_AddOvfUW64
    2e4: test    byte ptr [rbp-70h],0FFh
    2e8: je      290h
    2ea: mov     edi,0FFFFFF40h
    2ef: lea     rsi,[k3]
    2f6: call    ryo_h_AddrAbs
    2fb: lea     rdi,[sym4]
    302: lea     rsi,[site5]
    309: mov     edx,0FFFFFF58h
    30e: call    ryo_h_CallExt
    313: test    rax,rax
    316: je      323h
    318: call    rax
    31a: nop     [rcx-0A0h]
    321: jmp     333h
    323: mov     rdi,rbp
    326: lea     rsi,[ro+4]
    32d: call    qword ptr [sym6]
    333: call    ryo_h_Unreachable
    338: ud2
    33a: mov     qword ptr [rbp-68h],0
    342: jmp     2C0h
    347: mov     rax,[rbp-58h]
    34b: sub     rax,1
    34f: mov     [rbp-80h],rax
    353: mov     edi,0FFFFFF5Ch
    358: mov     esi,0FFFFFF80h
    35d: call    ryo_h_CtlzW64
    362: mov     eax,[rbp-0A4h]
    368: mov     [rbp-84h],eax
    36e: mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    379: mov     edi,0FFFFFF50h
    37e: mov     esi,0FFFFFF7Ch
    383: call    ryo_h_ZextW32W64
    388: mov     edi,0FFFFFF98h
    38d: mov     esi,0FFFFFF58h
    392: mov     edx,0FFFFFF50h
    397: call    ryo_h_ShrUW64
    39c: jmp     2C0h
    3a1: mov     rax,[rbp-98h]
    3a8: mov     [rbp-68h],rax
    3ac: mov     rdx,[rbp-60h]
    3b0: mov     [rbp-88h],rdx
    3b7: mov     edi,0FFFFFF80h
    3bc: mov     esi,0FFFFFF88h
    3c1: mov     edx,0FFFFFF98h
    3c6: mov     ecx,0FFFFFF78h
    3cb: call    ryo_h_MulOvfUW64
    3d0: mov     rax,[rbp-80h]
    3d4: mov     [rbp-68h],rax
    3d8: movzx   edx,byte ptr [rbp-78h]
    3dc: mov     [rbp-69h],dl
    3df: mov     [rbp-90h],rax
    3e6: test    byte ptr [rbp-69h],0FFh
    3ea: je      412h
    3ec: jmp     405h
    3ee: xchg    ax,ax
    3f0: mov     rax,[rbp-60h]
    3f4: mov     [rbp-8],rax
    3f8: mov     qword ptr [rbp-10h],1
    400: jmp     170h
    405: mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    410: jmp     3F0h
    412: jmp     3F0h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0B0h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+20h]
     13: mov     [rbp-48h],rax
     17: lea     rdx,[rbp+18h]
     1b: mov     [rbp-50h],rdx
     1f: mov     [rbp-0B0h],rax
     26: mov     [rbp-0A8h],rdx
     2d: call    fn0
     32: nop     [rcx-40h]
     39: jmp     17Ah
     3e: xchg    ax,ax
     40: mov     edi,0FFFFFF74h
     45: mov     esi,0FFFFFFB8h
     4a: xor     edx,edx
     4c: xor     ecx,ecx
     4e: xor     r8d,r8d
     51: mov     r9d,1
     57: call    ryo_h_DiscrNicheW64
     5c: mov     edi,0FFFFFFD0h
     61: mov     esi,0FFFFFF74h
     66: call    ryo_h_ZextW32W64
     6b: mov     edi,0FFFFFFD0h
     70: xor     esi,esi
     72: mov     edx,2
     77: call    ryo_h_SwitchDenseW64
     7c: lea     rcx,[8Ch]
     83: movsxd  rax,[rcx+rax*4]
     87: add     rax,rcx
     8a: jmp     rax
     8c: .long   e7h
     90: .long   98h
     94: .long   217h
     98: mov     rax,[rbp-48h]
     9c: mov     [rbp-50h],rax
     a0: mov     rdx,[rbp+10h]
     a4: mov     [rbp-68h],rdx
     a8: mov     [rbp-60h],rax
     ac: mov     [rbp-58h],rdx
     b0: mov     edi,0FFFFFFE0h
     b5: mov     esi,0FFFFFFA0h
     ba: call    ryo_h_MovW128
     bf: mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
     c7: lea     rdx,[rbp+18h]
     cb: mov     [rbp-90h],rdx
     d2: mov     [rbp-0B0h],rdx
     d9: call    fn1
     de: nop     [rcx-90h]
     e5: jmp     130h
     e7: mov     rax,[rbp+10h]
     eb: mov     [rbp-48h],rax
     ef: mov     rdx,[rbp+10h]
     f3: lea     rdx,[rdx+20h]
     f7: mov     [rbp-58h],rdx
     fb: mov     [rbp-50h],rdx
     ff: mov     [rbp-0B0h],rax
    106: mov     qword ptr [rbp-0A8h],1
    111: mov     [rbp-0A0h],rdx
    118: call    fn2
    11d: nop     [rcx-30h]
    124: jmp     1B8h
    129: nop     [rax]
    130: mov     edi,0FFFFFFD8h
    135: mov     esi,28h
    13a: call    ryo_h_Ret
    13f: leave
    140: ret
    141: nop     [rax+rax]
    14a: nop     [rax+rax]
    150: lea     rax,[rbp+18h]
    154: mov     [rbp-90h],rax
    15b: mov     [rbp-0B0h],rax
    162: call    fn3
    167: nop     [rcx-90h]
    16e: mov     edi,0FFFFFFC8h
    173: call    ryo_h_Resume
    178: ud2
    17a: mov     rax,[rbp+10h]
    17e: mov     [rbp-50h],rax
    182: lea     rdx,[rbp+18h]
    186: mov     [rbp-60h],rdx
    18a: mov     [rbp-58h],rdx
    18e: mov     [rbp-0B0h],rax
    195: mov     rsi,[rbp-40h]
    199: mov     [rbp-0A8h],rsi
    1a0: mov     [rbp-0A0h],rdx
    1a7: call    fn4
    1ac: nop     [rcx-48h]
    1b3: jmp     40h
    1b8: mov     edi,0FFFFFF80h
    1bd: mov     esi,18h
    1c2: mov     edx,18h
    1c7: call    ryo_h_Copy
    1cc: mov     rax,[rbp+10h]
    1d0: mov     [rbp-88h],rax
    1d7: mov     rdx,[rbp-40h]
    1db: mov     [rbp-48h],rdx
    1df: mov     edi,0FFFFFF98h
    1e4: mov     esi,0FFFFFF80h
    1e9: mov     edx,18h
    1ee: call    ryo_h_Copy
    1f3: mov     rax,[rbp-88h]
    1fa: mov     [rbp-50h],rax
    1fe: mov     edi,0FFFFFFD8h
    203: mov     esi,0FFFFFF98h
    208: mov     edx,28h
    20d: call    ryo_h_Copy
    212: jmp     130h
    217: call    ryo_h_Unreachable
    21c: ud2
    21e: xchg    ax,ax
    220: lea     rdi,[sym5]
    227: lea     rsi,[site6]
    22e: mov     edx,0FFFFFF70h
    233: call    ryo_h_CallExt
    238: test    rax,rax
    23b: je      248h
    23d: call    rax
    23f: nop     [rcx-88h]
    246: jmp     258h
    248: mov     rdi,rbp
    24b: lea     rsi,[ro+4]
    252: call    qword ptr [sym7]
    258: call    ryo_h_Unreachable
    25d: ud2
    25f: mov     rdi,rax
    262: mov     esi,0FFFFFFC8h
    267: call    ryo_h_Lpad
    26c: jmp     150h
    271: mov     rdi,rax
    274: mov     esi,0FFFFFFC8h
    279: call    ryo_h_Lpad
    27e: jmp     220h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+10h]
     14: mov     rdx,[rdx]
     17: mov     [rbp-10h],rdx
     1b: mov     [rbp-30h],rax
     1f: mov     [rbp-28h],rdx
     23: call    fn0
     28: nop     [rcx-1]
     2f: mov     edi,0FFFFFFFFh
     34: mov     esi,1
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,80h
      b: mov     rax,[rbp+10h]
      f: lea     rax,[rax+20h]
     13: mov     [rbp-38h],rax
     17: lea     rdx,[rbp+18h]
     1b: mov     [rbp-40h],rdx
     1f: mov     [rbp-80h],rax
     23: mov     [rbp-78h],rdx
     27: call    fn0
     2c: nop     [rcx-30h]
     33: jmp     12Ch
     38: nop     [rax+rax]
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
     8c: .long   c9h
     90: .long   98h
     94: .long   19ah
     98: mov     rax,[rbp-38h]
     9c: mov     [rbp-40h],rax
     a0: mov     rdx,[rbp+10h]
     a4: mov     [rbp-58h],rdx
     a8: mov     [rbp-50h],rax
     ac: mov     [rbp-48h],rdx
     b0: mov     edi,0FFFFFFF0h
     b5: mov     esi,0FFFFFFB0h
     ba: call    ryo_h_MovW128
     bf: mov     qword ptr [rbp-18h],0
     c7: jmp     100h
     c9: mov     rax,[rbp+10h]
     cd: mov     [rbp-38h],rax
     d1: mov     rdx,[rbp+10h]
     d5: lea     rdx,[rdx+20h]
     d9: mov     [rbp-48h],rdx
     dd: mov     [rbp-40h],rdx
     e1: mov     [rbp-80h],rax
     e5: mov     qword ptr [rbp-78h],1
     ed: mov     [rbp-70h],rdx
     f1: call    fn1
     f6: nop     [rcx-20h]
     fd: jmp     161h
     ff: nop
    100: mov     edi,0FFFFFFE8h
    105: mov     esi,18h
    10a: call    ryo_h_Ret
    10f: leave
    110: ret
    111: nop     [rax+rax]
    11a: nop     [rax+rax]
    120: mov     edi,0FFFFFFD8h
    125: call    ryo_h_Resume
    12a: ud2
    12c: mov     rax,[rbp+10h]
    130: mov     [rbp-40h],rax
    134: lea     rdx,[rbp+18h]
    138: mov     [rbp-50h],rdx
    13c: mov     [rbp-48h],rdx
    140: mov     [rbp-80h],rax
    144: mov     rsi,[rbp-30h]
    148: mov     [rbp-78h],rsi
    14c: mov     [rbp-70h],rdx
    150: call    fn2
    155: nop     [rcx-38h]
    15c: jmp     40h
    161: mov     rax,[rbp+18h]
    165: mov     [rbp-50h],rax
    169: mov     rdx,[rbp+10h]
    16d: mov     [rbp-58h],rdx
    171: mov     rsi,[rbp-30h]
    175: mov     [rbp-40h],rsi
    179: mov     [rbp-38h],rax
    17d: mov     [rbp-48h],rdx
    181: mov     edi,0FFFFFFE8h
    186: mov     esi,0FFFFFFB8h
    18b: mov     edx,18h
    190: call    ryo_h_Copy
    195: jmp     100h
    19a: call    ryo_h_Unreachable
    19f: ud2
    1a1: mov     rdi,rax
    1a4: mov     esi,0FFFFFFD8h
    1a9: call    ryo_h_Lpad
    1ae: jmp     120h

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,30h
      8: mov     rax,[rbp+18h]
      c: mov     [rbp-18h],rax
     10: mov     rdx,[rbp+10h]
     14: mov     rdx,[rdx]
     17: mov     [rbp-10h],rdx
     1b: mov     [rbp-30h],rax
     1f: mov     [rbp-28h],rdx
     23: call    fn0
     28: nop     [rcx-1]
     2f: mov     edi,0FFFFFFFFh
     34: mov     esi,1
     39: call    ryo_h_Ret
     3e: leave
     3f: ret

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
     3e: mov     rsi,[rbp-8]
     42: mov     [rbp-58h],rsi
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
     e2: mov     rdx,[rbp-40h]
     e6: mov     [rbp-0B0h],rdx
     ed: mov     [rbp-570h],rdx
     f4: mov     rsi,5851F42D4C957F2Dh
     fe: mov     [rbp-568h],rsi
    105: call    fn4
    10a: nop     [rcx-0A8h]
    111: jmp     19Bh
    116: mov     qword ptr [rbp-108h],0
    121: mov     qword ptr [rbp-110h],0
    12c: mov     dword ptr [rbp-534h],14h
    136: mov     edi,[rbp-534h]
    13c: mov     [rbp-16Ch],edi
    142: cmp     edi,40h
    145: jb      345h
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
    1a9: mov     rdx,14057B7EF767814Fh
    1b3: mov     [rbp-568h],rdx
    1ba: call    fn9
    1bf: nop     [rcx-0A0h]
    1c6: mov     rax,[rbp-0A0h]
    1cd: mov     [rbp-40h],rax
    1d1: lea     rdx,[rbp-38h]
    1d5: mov     [rbp-0D8h],rdx
    1dc: mov     [rbp-0E8h],rax
    1e3: mov     dword ptr [rbp-534h],2Ch
    1ed: mov     edi,[rbp-534h]
    1f3: mov     [rbp-0ECh],edi
    1f9: cmp     edi,40h
    1fc: jb      24Eh
    1fe: mov     edi,0FFFFFA90h
    203: lea     rsi,[k10]
    20a: call    ryo_h_AddrAbs
    20f: lea     rdi,[sym11]
    216: lea     rsi,[site12]
    21d: mov     edx,0FFFFFAC8h
    222: call    ryo_h_CallExt
    227: test    rax,rax
    22a: je      237h
    22c: call    rax
    22e: nop     [rcx-530h]
    235: jmp     247h
    237: mov     rdi,rbp
    23a: lea     rsi,[ro+4]
    241: call    qword ptr [sym13]
    247: call    ryo_h_Unreachable
    24c: ud2
    24e: mov     rax,[rbp-0E8h]
    255: shr     rax,2Ch
    259: mov     [rbp-0E0h],rax
    260: mov     rdx,[rbp-0D8h]
    267: mov     [rbp-570h],rdx
    26e: mov     [rbp-568h],rax
    275: call    fn14
    27a: nop     [rcx-0D0h]
    281: mov     edi,0FFFFFA90h
    286: mov     esi,0FFFFFF30h
    28b: mov     edx,18h
    290: call    ryo_h_Copy
    295: mov     qword ptr [rbp-558h],0
    2a0: call    fn15
    2a5: nop     [rcx-0B8h]
    2ac: mov     rax,[rbp-0B8h]
    2b3: mov     rax,[rax]
    2b6: mov     [rbp-538h],rax
    2bd: mov     edi,0FFFFFF00h
    2c2: mov     esi,0FFFFFF08h
    2c7: mov     edx,0FFFFFAC8h
    2cc: mov     ecx,0FFFFFF68h
    2d1: call    ryo_h_AddOvfUW64
    2d6: test    byte ptr [rbp-0F8h],0FFh
    2dd: je      32Fh
    2df: mov     edi,0FFFFFA90h
    2e4: lea     rsi,[k16]
    2eb: call    ryo_h_AddrAbs
    2f0: lea     rdi,[sym17]
    2f7: lea     rsi,[site18]
    2fe: mov     edx,0FFFFFAC8h
    303: call    ryo_h_CallExt
    308: test    rax,rax
    30b: je      318h
    30d: call    rax
    30f: nop     [rcx-530h]
    316: jmp     328h
    318: mov     rdi,rbp
    31b: lea     rsi,[ro+4]
    322: call    qword ptr [sym19]
    328: call    ryo_h_Unreachable
    32d: ud2
    32f: mov     rax,[rbp-0B8h]
    336: mov     rcx,[rbp-100h]
    33d: mov     [rax],rcx
    340: jmp     70h
    345: mov     qword ptr [rbp-538h],1
    350: mov     rdx,[rbp-538h]
    357: shl     rdx,14h
    35b: mov     [rbp-168h],rdx
    362: mov     qword ptr [rbp-160h],0
    36d: mov     [rbp-158h],rdx
    374: mov     edi,0FFFFFA90h
    379: mov     esi,0FFFFFEA0h
    37e: call    ryo_h_MovW128
    383: mov     qword ptr [rbp-560h],2
    38e: call    fn20
    393: nop     [rcx-150h]
    39a: mov     edi,0FFFFFA90h
    39f: mov     esi,0FFFFFEB0h
    3a4: mov     edx,20h
    3a9: call    ryo_h_Copy
    3ae: call    fn21
    3b3: nop     [rcx-130h]
    3ba: mov     edi,0FFFFFE70h
    3bf: mov     esi,0FFFFFED0h
    3c4: mov     edx,20h
    3c9: call    ryo_h_Copy
    3ce: xchg    ax,ax
    3d0: lea     rax,[rbp-190h]
    3d7: mov     [rbp-1A8h],rax
    3de: mov     [rbp-570h],rax
    3e5: call    fn22
    3ea: nop     [rcx-1A0h]
    3f1: mov     rax,[rbp-1A0h]
    3f8: mov     [rbp-1B0h],rax
    3ff: mov     edi,0FFFFFE50h
    404: xor     esi,esi
    406: mov     edx,2
    40b: call    ryo_h_SwitchDenseW64
    410: lea     rcx,[420h]
    417: movsxd  rax,[rcx+rax*4]
    41b: add     rax,rcx
    41e: jmp     rax
    420: .long   46fh
    424: .long   42ch
    428: .long   d0h
    42c: mov     rax,[rbp-198h]
    433: mov     [rbp-1B8h],rax
    43a: lea     rdx,[rbp-38h]
    43e: mov     [rbp-1C8h],rdx
    445: lea     rsi,[rbp-1B8h]
    44c: mov     [rbp-1D0h],rsi
    453: mov     [rbp-570h],rdx
    45a: mov     [rbp-568h],rsi
    461: call    fn23
    466: nop     [rcx-1C0h]
    46d: jmp     492h
    46f: lea     rax,[rbp-38h]
    473: mov     [rbp-218h],rax
    47a: mov     [rbp-570h],rax
    481: call    fn24
    486: nop     [rcx-210h]
    48d: jmp     5D1h
    492: mov     edi,0FFFFFACCh
    497: mov     esi,0FFFFFE40h
    49c: xor     edx,edx
    49e: xor     ecx,ecx
    4a0: xor     r8d,r8d
    4a3: mov     r9d,1
    4a9: call    ryo_h_DiscrNicheW64
    4ae: mov     edi,0FFFFFE28h
    4b3: mov     esi,0FFFFFACCh
    4b8: call    ryo_h_ZextW32W64
    4bd: mov     edi,0FFFFFE28h
    4c2: xor     esi,esi
    4c4: mov     edx,2
    4c9: call    ryo_h_SwitchDenseW64
    4ce: lea     rcx,[4E0h]
    4d5: movsxd  rax,[rcx+rax*4]
    4d9: add     rax,rcx
    4dc: jmp     rax
    4de: int3
    4df: int3
    4e0: .long   3d0h
    4e4: .long   4ech
    4e8: .long   d0h
    4ec: mov     rax,[rbp-1C0h]
    4f3: mov     [rbp-1E0h],rax
    4fa: mov     qword ptr [rbp-538h],1
    505: mov     edi,0FFFFFE10h
    50a: mov     esi,0FFFFFE18h
    50f: mov     edx,0FFFFFEF8h
    514: mov     ecx,0FFFFFAC8h
    519: call    ryo_h_AddOvfUW64
    51e: test    byte ptr [rbp-1E8h],0FFh
    525: je      577h
    527: mov     edi,0FFFFFA90h
    52c: lea     rsi,[k25]
    533: call    ryo_h_AddrAbs
    538: lea     rdi,[sym26]
    53f: lea     rsi,[site27]
    546: mov     edx,0FFFFFAC8h
    54b: call    ryo_h_CallExt
    550: test    rax,rax
    553: je      560h
    555: call    rax
    557: nop     [rcx-530h]
    55e: jmp     570h
    560: mov     rdi,rbp
    563: lea     rsi,[ro+4]
    56a: call    qword ptr [sym28]
    570: call    ryo_h_Unreachable
    575: ud2
    577: mov     rax,[rbp-1F0h]
    57e: mov     [rbp-108h],rax
    585: mov     rdx,[rbp-110h]
    58c: mov     [rbp-200h],rdx
    593: mov     rsi,[rbp-1E0h]
    59a: mov     rsi,[rsi]
    59d: mov     [rbp-208h],rsi
    5a4: mov     [rbp-570h],rdx
    5ab: mov     [rbp-568h],rsi
    5b2: call    fn29
    5b7: nop     [rcx-1F8h]
    5be: mov     rax,[rbp-1F8h]
    5c5: mov     [rbp-110h],rax
    5cc: jmp     3D0h
    5d1: lea     rax,[rbp-38h]
    5d5: mov     [rbp-220h],rax
    5dc: mov     [rbp-570h],rax
    5e3: call    fn30
    5e8: nop     [rcx-218h]
    5ef: lea     rax,[rbp-38h]
    5f3: mov     [rbp-258h],rax
    5fa: mov     [rbp-570h],rax
    601: call    fn31
    606: nop     [rcx-250h]
    60d: mov     edi,0FFFFFA90h
    612: mov     esi,0FFFFFDB0h
    617: mov     edx,28h
    61c: call    ryo_h_Copy
    621: mov     qword ptr [rbp-548h],0
    62c: call    fn32
    631: nop     [rcx-228h]
    638: call    fn33
    63d: nop     [rcx-288h]
    644: mov     dword ptr [rbp-298h],0
    64e: mov     dword ptr [rbp-294h],1FBD0h
    658: mov     rsi,[rbp-298h]
    65f: mov     [rbp-570h],rsi
    666: call    fn34
    66b: nop     [rcx-290h]
    672: mov     rax,[rbp-290h]
    679: mov     [rbp-2A0h],rax
    680: lea     rax,[rbp-2A0h]
    687: mov     [rbp-2B0h],rax
    68e: mov     [rbp-570h],rax
    695: call    fn35
    69a: nop     [rcx-2A8h]
    6a1: mov     edi,0FFFFFD48h
    6a6: mov     esi,0FFFFFD58h
    6ab: call    ryo_h_ZextW32W64
    6b0: mov     edi,0FFFFFD48h
    6b5: xor     esi,esi
    6b7: mov     edx,2
    6bc: call    ryo_h_SwitchDenseW64
    6c1: lea     rcx,[6D4h]
    6c8: movsxd  rax,[rcx+rax*4]
    6cc: add     rax,rcx
    6cf: jmp     rax
    6d1: int3
    6d2: int3
    6d3: int3
    6d4: .long   76bh
    6d8: .long   6e0h
    6dc: .long   d0h
    6e0: mov     eax,[rbp-2A4h]
    6e6: mov     [rbp-2BCh],eax
    6ec: lea     rdx,[rbp-288h]
    6f3: mov     [rbp-2F8h],rdx
    6fa: mov     dword ptr [rbp-534h],138Bh
    704: cmp     dword ptr [rbp-534h],0
    70b: sete    [rbp-34Dh]
    712: test    byte ptr [rbp-34Dh],0FFh
    719: je      78Eh
    71b: mov     edi,0FFFFFA90h
    720: lea     rsi,[k36]
    727: call    ryo_h_AddrAbs
    72c: lea     rdi,[sym37]
    733: lea     rsi,[site38]
    73a: mov     edx,0FFFFFAC8h
    73f: call    ryo_h_CallExt
    744: test    rax,rax
    747: je      754h
    749: call    rax
    74b: nop     [rcx-530h]
    752: jmp     764h
    754: mov     rdi,rbp
    757: lea     rsi,[ro+4]
    75e: call    qword ptr [sym39]
    764: call    ryo_h_Unreachable
    769: ud2
    76b: lea     rax,[rbp-38h]
    76f: mov     [rbp-3E8h],rax
    776: mov     [rbp-570h],rax
    77d: call    fn40
    782: nop     [rcx-3E0h]
    789: jmp     957h
    78e: mov     dword ptr [rbp-534h],138Bh
    798: mov     edi,0FFFFFCB4h
    79d: mov     esi,0FFFFFD44h
    7a2: mov     edx,0FFFFFACCh
    7a7: call    ryo_h_RemUW32
    7ac: lea     rax,[rbp-34Ch]
    7b3: mov     [rbp-348h],rax
    7ba: mov     [rbp-340h],rax
    7c1: mov     [rbp-4F8h],rax
    7c8: mov     [rbp-570h],rax
    7cf: call    fn41
    7d4: nop     [rcx-370h]
    7db: mov     edi,0FFFFFCA0h
    7e0: mov     esi,0FFFFFC90h
    7e5: call    ryo_h_MovW128
    7ea: mov     edi,0FFFFFC88h
    7ef: lea     rsi,[k42]
    7f6: call    ryo_h_AddrAbs
    7fb: lea     rax,[rbp-360h]
    802: mov     [rbp-380h],rax
    809: mov     rdx,[rbp-378h]
    810: mov     [rbp-570h],rdx
    817: mov     [rbp-568h],rax
    81e: call    fn43
    823: nop     [rcx-338h]
    82a: mov     edi,0FFFFFA90h
    82f: mov     esi,0FFFFFCC8h
    834: call    ryo_h_MovW128
    839: call    fn44
    83e: nop     [rcx-328h]
    845: mov     edi,0FFFFFA90h
    84a: mov     esi,0FFFFFCD8h
    84f: mov     edx,18h
    854: call    ryo_h_Copy
    859: call    fn45
    85e: nop     [rcx-310h]
    865: mov     rax,[rbp-2F8h]
    86c: mov     [rbp-570h],rax
    873: mov     edi,0FFFFFA98h
    878: mov     esi,0FFFFFCF0h
    87d: mov     edx,18h
    882: call    ryo_h_Copy
    887: call    fn46
    88c: nop     [rcx-2F0h]
    893: mov     edi,0FFFFFA90h
    898: mov     esi,0FFFFFD10h
    89d: mov     edx,28h
    8a2: call    ryo_h_Copy
    8a7: call    fn47
    8ac: nop     [rcx-2C8h]
    8b3: mov     rax,[rbp-2C8h]
    8ba: mov     rax,[rax]
    8bd: mov     [rbp-538h],rax
    8c4: mov     qword ptr [rbp-540h],1
    8cf: mov     edi,0FFFFFC70h
    8d4: mov     esi,0FFFFFC78h
    8d9: mov     edx,0FFFFFAC8h
    8de: mov     ecx,0FFFFFAC0h
    8e3: call    ryo_h_AddOvfUW64
    8e8: test    byte ptr [rbp-388h],0FFh
    8ef: je      941h
    8f1: mov     edi,0FFFFFA90h
    8f6: lea     rsi,[k48]
    8fd: call    ryo_h_AddrAbs
    902: lea     rdi,[sym49]
    909: lea     rsi,[site50]
    910: mov     edx,0FFFFFAC8h
    915: call    ryo_h_CallExt
    91a: test    rax,rax
    91d: je      92Ah
    91f: call    rax
    921: nop     [rcx-530h]
    928: jmp     93Ah
    92a: mov     rdi,rbp
    92d: lea     rsi,[ro+4]
    934: call    qword ptr [sym51]
    93a: call    ryo_h_Unreachable
    93f: ud2
    941: mov     rax,[rbp-2C8h]
    948: mov     rcx,[rbp-390h]
    94f: mov     [rax],rcx
    952: jmp     680h
    957: lea     rax,[rbp-3E0h]
    95e: mov     [rbp-3D8h],rax
    965: lea     rdx,[rbp-288h]
    96c: mov     [rbp-400h],rdx
    973: mov     [rbp-570h],rdx
    97a: call    fn52
    97f: nop     [rcx-3F8h]
    986: lea     rax,[rbp-3F8h]
    98d: mov     [rbp-3F0h],rax
    994: lea     rdx,[rbp-210h]
    99b: mov     [rbp-408h],rdx
    9a2: lea     rsi,[rbp-108h]
    9a9: mov     [rbp-410h],rsi
    9b0: lea     rdi,[rbp-110h]
    9b7: mov     [rbp-418h],rdi
    9be: lea     r8,[rbp-228h]
    9c5: mov     [rbp-420h],r8
    9cc: mov     r9,[rbp-3D8h]
    9d3: mov     [rbp-3D0h],r9
    9da: mov     [rbp-3C8h],rax
    9e1: mov     [rbp-3C0h],rdx
    9e8: mov     [rbp-3B8h],rsi
    9ef: mov     [rbp-3B0h],rdi
    9f6: mov     [rbp-3A8h],r8
    9fd: mov     [rbp-500h],rdx
    a04: mov     [rbp-570h],rdx
    a0b: call    fn53
    a10: nop     [rcx-490h]
    a17: mov     rax,[rbp-3B8h]
    a1e: mov     [rbp-508h],rax
    a25: mov     [rbp-570h],rax
    a2c: call    fn54
    a31: nop     [rcx-4A0h]
    a38: mov     rax,[rbp-3B0h]
    a3f: mov     [rbp-510h],rax
    a46: mov     [rbp-570h],rax
    a4d: call    fn55
    a52: nop     [rcx-4B0h]
    a59: mov     rax,[rbp-3D0h]
    a60: mov     [rbp-518h],rax
    a67: mov     [rbp-570h],rax
    a6e: call    fn56
    a73: nop     [rcx-4C0h]
    a7a: mov     rax,[rbp-3A8h]
    a81: mov     [rbp-520h],rax
    a88: mov     [rbp-570h],rax
    a8f: call    fn57
    a94: nop     [rcx-4D0h]
    a9b: mov     rax,[rbp-3C8h]
    aa2: mov     [rbp-528h],rax
    aa9: mov     [rbp-570h],rax
    ab0: call    fn58
    ab5: nop     [rcx-4E0h]
    abc: mov     edi,0FFFFFB80h
    ac1: mov     esi,0FFFFFB70h
    ac6: call    ryo_h_MovW128
    acb: mov     edi,0FFFFFB90h
    ad0: mov     esi,0FFFFFB60h
    ad5: call    ryo_h_MovW128
    ada: mov     edi,0FFFFFBA0h
    adf: mov     esi,0FFFFFB50h
    ae4: call    ryo_h_MovW128
    ae9: mov     edi,0FFFFFBB0h
    aee: mov     esi,0FFFFFB40h
    af3: call    ryo_h_MovW128
    af8: mov     edi,0FFFFFBC0h
    afd: mov     esi,0FFFFFB30h
    b02: call    ryo_h_MovW128
    b07: mov     edi,0FFFFFBD0h
    b0c: mov     esi,0FFFFFB20h
    b11: call    ryo_h_MovW128
    b16: mov     edi,0FFFFFB18h
    b1b: lea     rsi,[k59]
    b22: call    ryo_h_AddrAbs
    b27: lea     rax,[rbp-480h]
    b2e: mov     [rbp-4F0h],rax
    b35: mov     rdx,[rbp-4E8h]
    b3c: mov     [rbp-570h],rdx
    b43: mov     [rbp-568h],rax
    b4a: call    fn60
    b4f: nop     [rcx-3A0h]
    b56: mov     edi,0FFFFFA90h
    b5b: mov     esi,0FFFFFC60h
    b60: call    ryo_h_MovW128
    b65: lea     rdi,[sym61]
    b6c: lea     rsi,[site62]
    b73: mov     edx,0FFFFFAC8h
    b78: call    ryo_h_CallExt
    b7d: test    rax,rax
    b80: je      0B8Dh
    b82: call    rax
    b84: nop     [rcx-390h]
    b8b: jmp     0B9Dh
    b8d: mov     rdi,rbp
    b90: lea     rsi,[ro+20]
    b97: call    qword ptr [sym63]
    b9d: lea     rax,[rbp-288h]
    ba4: mov     [rbp-538h],rax
    bab: mov     [rbp-570h],rax
    bb2: call    fn64
    bb7: nop     [rcx-538h]
    bbe: lea     rax,[rbp-38h]
    bc2: mov     [rbp-538h],rax
    bc9: mov     [rbp-570h],rax
    bd0: call    fn65
    bd5: nop     [rcx-538h]
    bdc: xor     edi,edi
    bde: xor     esi,esi
    be0: call    ryo_h_Ret
    be5: leave
    be6: ret
    be7: nop     [rax+rax]
    bf0: lea     rax,[rbp-288h]
    bf7: mov     [rbp-538h],rax
    bfe: mov     [rbp-570h],rax
    c05: call    fn66
    c0a: nop     [rcx-538h]
    c11: nop     [rax+rax]
    c1a: nop     [rax+rax]
    c20: lea     rax,[rbp-38h]
    c24: mov     [rbp-538h],rax
    c2b: mov     [rbp-570h],rax
    c32: call    fn67
    c37: nop     [rcx-538h]
    c3e: mov     edi,0FFFFFAD0h
    c43: call    ryo_h_Resume
    c48: ud2
    c4a: nop     [rax+rax]
    c50: lea     rdi,[sym68]
    c57: lea     rsi,[site69]
    c5e: mov     edx,0FFFFFAC8h
    c63: call    ryo_h_CallExt
    c68: test    rax,rax
    c6b: je      0C78h
    c6d: call    rax
    c6f: nop     [rcx-530h]
    c76: jmp     0C88h
    c78: mov     rdi,rbp
    c7b: lea     rsi,[ro+4]
    c82: call    qword ptr [sym70]
    c88: call    ryo_h_Unreachable
    c8d: ud2
    c8f: mov     rdi,rax
    c92: mov     esi,0FFFFFAD0h
    c97: call    ryo_h_Lpad
    c9c: jmp     0C20h
    c9e: mov     rdi,rax
    ca1: mov     esi,0FFFFFAD0h
    ca6: call    ryo_h_Lpad
    cab: jmp     0BF0h
    cb0: mov     rdi,rax
    cb3: mov     esi,0FFFFFAD0h
    cb8: call    ryo_h_Lpad
    cbd: jmp     0C50h

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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-20h],rdx
     1b: mov     [rbp-18h],rax
     1f: call    fn0
     24: nop     [rcx-8]
     2b: mov     edi,0FFFFFFF8h
     30: mov     esi,8
     35: call    ryo_h_Ret
     3a: leave
     3b: ret

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
     2d: mov     rdx,[rbp-38h]
     31: mov     [rbp-90h],rdx
     38: mov     [rbp-88h],rdx
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
     d5: jmp     1C7h
     da: nop     [rax+rax]
     e0: mov     rax,[rbp-28h]
     e4: mov     [rbp-88h],rax
     eb: cmp     rax,0
     ef: sete    [rbp-79h]
     f3: test    byte ptr [rbp-79h],0FFh
     f7: je      25Ah
     fd: jmp     21Eh
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
    178: mov     rdx,[rbp-60h]
    17c: mov     [rbp-0B0h],rdx
    183: mov     [rbp-0A8h],rax
    18a: lea     rdi,[sym8]
    191: lea     rsi,[site9]
    198: mov     edx,0FFFFFF68h
    19d: call    ryo_h_CallExt
    1a2: test    rax,rax
    1a5: je      1B2h
    1a7: call    rax
    1a9: nop     [rcx-28h]
    1b0: jmp     1C2h
    1b2: mov     rdi,rbp
    1b5: lea     rsi,[ro+36]
    1bc: call    qword ptr [sym10]
    1c2: jmp     0E0h
    1c7: mov     rax,[rbp+10h]
    1cb: mov     [rbp-68h],rax
    1cf: mov     rdx,[rbp-60h]
    1d3: mov     [rbp-0B0h],rdx
    1da: mov     [rbp-0A8h],rax
    1e1: lea     rdi,[sym11]
    1e8: lea     rsi,[site12]
    1ef: mov     edx,0FFFFFF68h
    1f4: call    ryo_h_CallExt
    1f9: test    rax,rax
    1fc: je      209h
    1fe: call    rax
    200: nop     [rcx-28h]
    207: jmp     219h
    209: mov     rdi,rbp
    20c: lea     rsi,[ro+36]
    213: call    qword ptr [sym13]
    219: jmp     0E0h
    21e: mov     qword ptr [rbp-78h],0
    226: mov     qword ptr [rbp-70h],0
    22e: mov     qword ptr [rbp-70h],1
    236: cmp     qword ptr [rbp-70h],1
    23b: sete    [rbp-71h]
    23f: mov     edi,0FFFFFFF0h
    244: lea     rsi,[k14]
    24b: mov     edx,10h
    250: call    ryo_h_Const
    255: jmp     110h
    25a: mov     byte ptr [rbp-91h],1
    261: test    byte ptr [rbp-91h],0FFh
    268: je      299h
    26a: mov     rsi,[rbp-28h]
    26e: mov     [rbp-90h],rsi
    275: mov     [rbp-0B0h],rsi
    27c: mov     edi,0FFFFFF58h
    281: lea     rsi,[k15]
    288: call    ryo_h_AddrAbs
    28d: call    fn16
    292: nop     [rcx-58h]
    299: mov     rax,[rbp-28h]
    29d: mov     [rbp-88h],rax
    2a4: mov     [rbp-78h],rax
    2a8: mov     [rbp-80h],rax
    2ac: mov     [rbp-70h],rax
    2b0: mov     [rbp-78h],rax
    2b4: mov     [rbp-68h],rax
    2b8: mov     [rbp-30h],rax
    2bc: mov     [rbp-88h],rax
    2c3: mov     [rbp-80h],rax
    2c7: mov     rdx,[rbp-60h]
    2cb: mov     [rbp-78h],rdx
    2cf: mov     byte ptr [rbp-91h],1
    2d6: test    byte ptr [rbp-91h],0FFh
    2dd: je      30Eh
    2df: mov     r8,[rbp-30h]
    2e3: mov     [rbp-88h],r8
    2ea: mov     [rbp-0B0h],r8
    2f1: mov     edi,0FFFFFF58h
    2f6: lea     rsi,[k17]
    2fd: call    ryo_h_AddrAbs
    302: call    fn18
    307: nop     [rcx-58h]
    30e: mov     edi,0FFFFFF90h
    313: mov     esi,0FFFFFF80h
    318: call    ryo_h_MovW128
    31d: mov     edi,0FFFFFFF0h
    322: mov     esi,0FFFFFF90h
    327: call    ryo_h_MovW128
    32c: jmp     110h

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
     12: jb      0FBh
     18: jmp     0CBh
     1d: nop     [rax]
     20: mov     eax,[rbp+10h]
     23: mov     [rbp-70h],eax
     26: mov     rdx,[rbp-18h]
     2a: mov     [rbp-80h],rdx
     2e: mov     rsi,[rbp-20h]
     32: mov     [rbp-78h],rsi
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
     68: mov     rdx,[rbp+20h]
     6c: mov     [rbp-40h],rdx
     70: mov     [rbp-38h],rax
     74: mov     esi,[rbp+10h]
     77: mov     [rbp-80h],esi
     7a: mov     [rbp-78h],rax
     7e: call    fn2
     83: nop     [rcx-20h]
     8a: mov     rax,[rbp+18h]
     8e: mov     [rbp-30h],rax
     92: mov     rdx,[rbp+20h]
     96: mov     [rbp-28h],rdx
     9a: mov     [rbp-38h],rax
     9e: mov     byte ptr [rbp-49h],1
     a2: test    byte ptr [rbp-49h],0FFh
     a6: je      146h
     ac: jmp     105h
     ae: xchg    ax,ax
     b0: mov     rax,[rbp+20h]
     b4: mov     [rbp-20h],rax
     b8: mov     rdx,[rbp-18h]
     bc: mov     [rbp-40h],rdx
     c0: cmp     rax,rdx
     c3: jb      20h
     c9: jmp     60h
     cb: cmp     dword ptr [rbp+10h],800h
     d2: jb      0F1h
     d4: cmp     dword ptr [rbp+10h],10000h
     db: jb      0E7h
     dd: mov     qword ptr [rbp-18h],4
     e5: jmp     0B0h
     e7: mov     qword ptr [rbp-18h],3
     ef: jmp     0B0h
     f1: mov     qword ptr [rbp-18h],2
     f9: jmp     0B0h
     fb: mov     qword ptr [rbp-18h],1
    103: jmp     0B0h
    105: mov     rax,[rbp-30h]
    109: mov     [rbp-40h],rax
    10d: mov     [rbp-80h],rax
    111: mov     qword ptr [rbp-78h],1
    119: mov     qword ptr [rbp-70h],1
    121: mov     rdi,[rbp-18h]
    125: mov     [rbp-68h],rdi
    129: mov     edi,0FFFFFFA0h
    12e: lea     rsi,[k3]
    135: call    ryo_h_AddrAbs
    13a: call    fn4
    13f: nop     [rcx-30h]
    146: mov     rax,[rbp-38h]
    14a: mov     [rbp-48h],rax
    14e: mov     rdx,[rbp-18h]
    152: mov     [rbp-40h],rdx
    156: mov     [rbp-10h],rax
    15a: mov     [rbp-8],rdx
    15e: mov     edi,0FFFFFFF0h
    163: mov     esi,10h
    168: call    ryo_h_Ret
    16d: leave
    16e: ret

fn std::char::encode_utf8_raw::do_panic::runtime
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0E0h
      b: lea     rax,[rbp+10h]
      f: mov     [rbp-8],rax
     13: lea     rdx,[rbp+20h]
     17: mov     [rbp-10h],rdx
     1b: lea     rsi,[rbp+18h]
     1f: mov     [rbp-18h],rsi
     23: mov     [rbp-98h],rax
     2a: mov     [rbp-80h],rax
     2e: mov     edi,0FFFFFF70h
     33: lea     rsi,[sym0]
     3a: call    ryo_h_AddrSym
     3f: mov     rax,[rbp-90h]
     46: mov     [rbp-88h],rax
     4d: mov     rdx,[rbp-80h]
     51: mov     [rbp-78h],rdx
     55: mov     [rbp-70h],rax
     59: mov     edi,0FFFFFF98h
     5e: mov     esi,0FFFFFF88h
     63: call    ryo_h_MovW128
     68: mov     rax,[rbp-10h]
     6c: mov     [rbp-0A8h],rax
     73: mov     [rbp-90h],rax
     7a: mov     edi,0FFFFFF60h
     7f: lea     rsi,[sym1]
     86: call    ryo_h_AddrSym
     8b: mov     rax,[rbp-0A0h]
     92: mov     [rbp-98h],rax
     99: mov     rdx,[rbp-90h]
     a0: mov     [rbp-88h],rdx
     a7: mov     [rbp-80h],rax
     ab: mov     edi,0FFFFFF88h
     b0: mov     esi,0FFFFFF78h
     b5: call    ryo_h_MovW128
     ba: mov     rax,[rbp-18h]
     be: mov     [rbp-0B8h],rax
     c5: mov     [rbp-0A0h],rax
     cc: mov     edi,0FFFFFF50h
     d1: lea     rsi,[sym2]
     d8: call    ryo_h_AddrSym
     dd: mov     rax,[rbp-0B0h]
     e4: mov     [rbp-0A8h],rax
     eb: mov     rdx,[rbp-0A0h]
     f2: mov     [rbp-98h],rdx
     f9: mov     [rbp-90h],rax
    100: mov     edi,0FFFFFF78h
    105: mov     esi,0FFFFFF68h
    10a: call    ryo_h_MovW128
    10f: mov     edi,0FFFFFFA8h
    114: mov     esi,0FFFFFF98h
    119: call    ryo_h_MovW128
    11e: mov     edi,0FFFFFFB8h
    123: mov     esi,0FFFFFF88h
    128: call    ryo_h_MovW128
    12d: mov     edi,0FFFFFFC8h
    132: mov     esi,0FFFFFF78h
    137: call    ryo_h_MovW128
    13c: lea     rax,[rbp-58h]
    140: mov     [rbp-60h],rax
    144: mov     edi,0FFFFFF98h
    149: lea     rsi,[k3]
    150: call    ryo_h_AddrAbs
    155: mov     rax,[rbp-60h]
    159: mov     [rbp-70h],rax
    15d: mov     rdx,[rbp-68h]
    161: mov     [rbp-28h],rdx
    165: mov     [rbp-20h],rax
    169: mov     edi,0FFFFFF20h
    16e: mov     esi,0FFFFFFD8h
    173: call    ryo_h_MovW128
    178: mov     rax,[rbp+28h]
    17c: mov     [rbp-0D0h],rax
    183: lea     rdi,[sym4]
    18a: lea     rsi,[site5]
    191: mov     edx,0FFFFFF40h
    196: call    ryo_h_CallExt
    19b: test    rax,rax
    19e: je      1ABh
    1a0: call    rax
    1a2: nop     [rcx]
    1a9: jmp     1BBh
    1ab: mov     rdi,rbp
    1ae: lea     rsi,[ro+4]
    1b5: call    qword ptr [sym6]
    1bb: call    ryo_h_Unreachable
    1c0: ud2

fn std::char::encode_utf8_raw_unchecked
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,20h
      8: cmp     dword ptr [rbp+10h],80h
      f: jb      16Bh
     15: jmp     13Bh
     1a: nop     [rax+rax]
     20: movzx   eax,byte ptr [rbp-0Ah]
     24: or      al,0C0h
     27: mov     [rbp-20h],al
     2a: mov     rdx,[rbp+18h]
     2e: movzx   ecx,byte ptr [rbp-20h]
     32: mov     [rdx],cl
     34: mov     qword ptr [rbp-20h],1
     3c: mov     rdi,[rbp+18h]
     40: imul    rcx,[rbp-20h],1
     45: add     rdi,rcx
     48: mov     [rbp-18h],rdi
     4c: movzx   ecx,byte ptr [rbp-9]
     50: mov     [rdi],cl
     52: jmp     130h
     57: nop     [rax+rax]
     60: cmp     qword ptr [rbp-8],3
     65: jne     0BBh
     67: movzx   edx,byte ptr [rbp-0Bh]
     6b: or      dl,0E0h
     6e: mov     [rbp-20h],dl
     71: mov     rsi,[rbp+18h]
     75: movzx   ecx,byte ptr [rbp-20h]
     79: mov     [rsi],cl
     7b: mov     qword ptr [rbp-20h],1
     83: mov     r8,[rbp+18h]
     87: imul    rcx,[rbp-20h],1
     8c: add     r8,rcx
     8f: mov     [rbp-18h],r8
     93: movzx   ecx,byte ptr [rbp-0Ah]
     97: mov     [r8],cl
     9a: mov     qword ptr [rbp-20h],2
     a2: mov     r10,[rbp+18h]
     a6: imul    rcx,[rbp-20h],1
     ab: add     r10,rcx
     ae: mov     [rbp-18h],r10
     b2: movzx   ecx,byte ptr [rbp-9]
     b6: mov     [r10],cl
     b9: jmp     130h
     bb: mov     rax,[rbp+18h]
     bf: movzx   ecx,byte ptr [rbp-0Ch]
     c3: mov     [rax],cl
     c5: mov     qword ptr [rbp-20h],1
     cd: mov     rsi,[rbp+18h]
     d1: imul    rcx,[rbp-20h],1
     d6: add     rsi,rcx
     d9: mov     [rbp-18h],rsi
     dd: movzx   ecx,byte ptr [rbp-0Bh]
     e1: mov     [rsi],cl
     e3: mov     qword ptr [rbp-20h],2
     eb: mov     r8,[rbp+18h]
     ef: imul    rcx,[rbp-20h],1
     f4: add     r8,rcx
     f7: mov     [rbp-18h],r8
     fb: movzx   ecx,byte ptr [rbp-0Ah]
     ff: mov     [r8],cl
    102: mov     qword ptr [rbp-20h],3
    10a: mov     r10,[rbp+18h]
    10e: imul    rcx,[rbp-20h],1
    113: add     r10,rcx
    116: mov     [rbp-18h],r10
    11a: movzx   ecx,byte ptr [rbp-9]
    11e: mov     [r10],cl
    121: jmp     130h
    123: nop     [rax+rax]
    12c: nop     [rax]
    130: xor     edi,edi
    132: xor     esi,esi
    134: call    ryo_h_Ret
    139: leave
    13a: ret
    13b: cmp     dword ptr [rbp+10h],800h
    142: jb      161h
    144: cmp     dword ptr [rbp+10h],10000h
    14b: jb      157h
    14d: mov     qword ptr [rbp-8],4
    155: jmp     18Eh
    157: mov     qword ptr [rbp-8],3
    15f: jmp     18Eh
    161: mov     qword ptr [rbp-8],2
    169: jmp     18Eh
    16b: mov     qword ptr [rbp-8],1
    173: mov     edi,0FFFFFFE0h
    178: mov     esi,10h
    17d: call    ryo_h_TruncW32W8
    182: mov     rax,[rbp+18h]
    186: movzx   ecx,byte ptr [rbp-20h]
    18a: mov     [rax],cl
    18c: jmp     130h
    18e: mov     eax,[rbp+10h]
    191: and     eax,3Fh
    194: mov     [rbp-10h],eax
    197: mov     edi,0FFFFFFF6h
    19c: mov     esi,0FFFFFFF0h
    1a1: call    ryo_h_TruncW32W8
    1a6: movzx   eax,byte ptr [rbp-0Ah]
    1aa: or      al,80h
    1ad: mov     [rbp-9],al
    1b0: mov     edx,[rbp+10h]
    1b3: shr     edx,6
    1b6: mov     [rbp-14h],edx
    1b9: and     edx,3Fh
    1bc: mov     [rbp-10h],edx
    1bf: mov     edi,0FFFFFFF5h
    1c4: mov     esi,0FFFFFFF0h
    1c9: call    ryo_h_TruncW32W8
    1ce: movzx   eax,byte ptr [rbp-0Bh]
    1d2: or      al,80h
    1d5: mov     [rbp-0Ah],al
    1d8: mov     edx,[rbp+10h]
    1db: shr     edx,0Ch
    1de: mov     [rbp-14h],edx
    1e1: and     edx,3Fh
    1e4: mov     [rbp-10h],edx
    1e7: mov     edi,0FFFFFFF4h
    1ec: mov     esi,0FFFFFFF0h
    1f1: call    ryo_h_TruncW32W8
    1f6: movzx   eax,byte ptr [rbp-0Ch]
    1fa: or      al,80h
    1fd: mov     [rbp-0Bh],al
    200: mov     edx,[rbp+10h]
    203: shr     edx,12h
    206: mov     [rbp-18h],edx
    209: and     edx,3Fh
    20c: mov     [rbp-14h],edx
    20f: mov     edi,0FFFFFFF3h
    214: mov     esi,0FFFFFFECh
    219: call    ryo_h_TruncW32W8
    21e: movzx   eax,byte ptr [rbp-0Dh]
    222: or      al,0F0h
    225: mov     [rbp-0Ch],al
    228: mov     rdx,[rbp-8]
    22c: mov     [rbp-18h],rdx
    230: cmp     rdx,2
    234: je      20h
    23a: jmp     60h

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt
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
     17: mov     rdx,[rbp+18h]
     1b: mov     [rbp-78h],rdx
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
     14: mov     rdx,[rbp+18h]
     18: mov     [rbp-18h],rdx
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
     b1: mov     rdx,[rbp+20h]
     b5: mov     [rbp-50h],rdx
     b9: mov     byte ptr [rbp-0D9h],0
     c0: test    byte ptr [rbp-0D9h],0FFh
     c7: je      1ECh
     cd: jmp     1E2h
     d2: mov     byte ptr [rbp-11h],0
     d6: mov     rdx,[rbp-60h]
     da: mov     [rbp-0B8h],rdx
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
    122: mov     rdx,[rbp-0D8h]
    129: mov     [rbp-110h],rdx
    130: mov     rsi,[rbp-0B8h]
    137: mov     [rbp-108h],rsi
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
    227: mov     rdx,[rbp-48h]
    22b: imul    rcx,[rbp-0E0h],20h
    233: add     rdx,rcx
    236: mov     [rbp-40h],rdx
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
    2bd: mov     rdx,[rbp-0A8h]
    2c4: imul    rcx,[rbp-0E0h],20h
    2cc: add     rdx,rcx
    2cf: mov     [rbp-0A0h],rdx
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
     58: .long   c2h
     5c: .long   6bh
     60: .long   64h
     64: call    ryo_h_Unreachable
     69: ud2
     6b: mov     rax,[rbp+18h]
     6f: mov     [rbp-68h],rax
     73: mov     rdx,[rbp+20h]
     77: mov     [rbp-70h],rdx
     7b: mov     rsi,[rbp+10h]
     7f: mov     [rbp-78h],rsi
     83: mov     byte ptr [rbp-11h],0
     87: mov     r8,[rbp+28h]
     8b: mov     [rbp-38h],r8
     8f: mov     [rbp-50h],rdx
     93: mov     [rbp-48h],r8
     97: mov     [rbp-0A0h],rsi
     9e: mov     [rbp-98h],rax
     a5: mov     edi,0FFFFFF70h
     aa: mov     esi,0FFFFFFB0h
     af: call    ryo_h_MovW128
     b4: call    fn0
     b9: nop     [rcx-40h]
     c0: jmp     138h
     c2: mov     rax,[rbp+18h]
     c6: mov     [rbp-58h],rax
     ca: mov     rdx,[rbp+20h]
     ce: mov     [rbp-50h],rdx
     d2: mov     byte ptr [rbp-79h],0
     d6: test    byte ptr [rbp-79h],0FFh
     da: je      1DFh
     e0: jmp     1D5h
     e5: nop     [rax+rax]
     ee: xchg    ax,ax
     f0: mov     edi,0FFFFFFF8h
     f5: mov     esi,8
     fa: call    ryo_h_Ret
     ff: leave
    100: ret
    101: nop     [rax+rax]
    10a: nop     [rax+rax]
    110: mov     edi,0FFFFFFD0h
    115: call    ryo_h_Resume
    11a: ud2
    11c: nop     [rax]
    120: jmp     110h
    122: nop     [rax+rax]
    12b: nop     [rax+rax]
    130: test    byte ptr [rbp-11h],0FFh
    134: je      110h
    136: jmp     120h
    138: mov     byte ptr [rbp-79h],0
    13c: test    byte ptr [rbp-79h],0FFh
    140: je      16Ch
    142: jmp     162h
    144: nop     [rax+rax]
    14d: nop     [rax]
    150: mov     rax,[rbp-50h]
    154: mov     [rbp-48h],rax
    158: lea     rax,[rax+8]
    15c: mov     [rbp-8],rax
    160: jmp     0F0h
    162: mov     qword ptr [rbp-50h],8
    16a: jmp     150h
    16c: mov     rax,[rbp-40h]
    170: mov     [rbp-60h],rax
    174: mov     [rbp-58h],rax
    178: mov     byte ptr [rbp-79h],0
    17c: test    byte ptr [rbp-79h],0FFh
    180: je      19Ch
    182: jmp     192h
    184: nop     [rax+rax]
    18d: nop     [rax]
    190: jmp     150h
    192: mov     rax,[rbp-58h]
    196: mov     [rbp-50h],rax
    19a: jmp     190h
    19c: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    1a4: mov     rdx,[rbp-58h]
    1a8: imul    rcx,[rbp-80h],10h
    1ad: add     rdx,rcx
    1b0: mov     [rbp-50h],rdx
    1b4: jmp     190h
    1b6: nop     [rax+rax]
    1bf: nop
    1c0: mov     rax,[rbp-40h]
    1c4: mov     [rbp-38h],rax
    1c8: lea     rax,[rax+8]
    1cc: mov     [rbp-8],rax
    1d0: jmp     0F0h
    1d5: mov     qword ptr [rbp-40h],8
    1dd: jmp     1C0h
    1df: mov     rax,[rbp-58h]
    1e3: mov     [rbp-48h],rax
    1e7: mov     byte ptr [rbp-79h],0
    1eb: test    byte ptr [rbp-79h],0FFh
    1ef: je      20Ch
    1f1: jmp     202h
    1f3: nop     [rax+rax]
    1fc: nop     [rax]
    200: jmp     1C0h
    202: mov     rax,[rbp-48h]
    206: mov     [rbp-40h],rax
    20a: jmp     200h
    20c: mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    214: mov     rdx,[rbp-48h]
    218: imul    rcx,[rbp-80h],10h
    21d: add     rdx,rcx
    220: mov     [rbp-40h],rdx
    224: jmp     200h
    226: mov     rdi,rax
    229: mov     esi,0FFFFFFD0h
    22e: call    ryo_h_Lpad
    233: jmp     130h

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
     6e: mov     rdx,[rbp-20h]
     72: shr     rdx,1
     76: mov     [rbp-58h],rdx
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
     d4: movzx   edx,byte ptr [rbp-1Ah]
     d8: mov     [rbp-0A0h],dl
     de: mov     rdi,rbp
     e1: lea     rsi,[ro+4]
     e8: call    qword ptr [sym2]
     ee: jmp     30h
     f3: mov     rax,[rbp-50h]
     f7: mov     [rbp-60h],rax
     fb: mov     [rbp-0A0h],rax
    102: mov     qword ptr [rbp-98h],1
    10d: mov     qword ptr [rbp-90h],1
    118: mov     rdi,[rbp-58h]
    11c: mov     [rbp-88h],rdi
    123: mov     edi,0FFFFFF80h
    128: lea     rsi,[k3]
    12f: call    ryo_h_AddrAbs
    134: call    fn4
    139: nop     [rcx-18h]
    140: mov     rax,[rbp-28h]
    144: mov     [rbp-68h],rax
    148: mov     rdx,[rbp-58h]
    14c: mov     [rbp-60h],rdx
    150: mov     [rbp-48h],rax
    154: mov     [rbp-40h],rdx
    158: mov     edi,0FFFFFFC8h
    15d: mov     esi,0FFFFFFB8h
    162: call    ryo_h_MovW128
    167: mov     edi,0FFFFFFF0h
    16c: mov     esi,0FFFFFFC8h
    171: call    ryo_h_MovW128
    176: jmp     0A0h

fn std::fmt::Arguments::<'_>::new::<4, 1>
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

fn std::fmt::Arguments::<'_>::new::<59, 6>
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
     4d: mov     rdx,[rbp-38h]
     51: shr     rdx,1
     55: mov     [rbp-70h],rdx
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
     ec: mov     rdi,[rbp-70h]
     f0: mov     [rbp-98h],rdi
     f7: mov     edi,0FFFFFF70h
     fc: lea     rsi,[k2]
    103: call    ryo_h_AddrAbs
    108: call    fn3
    10d: nop     [rcx-20h]
    114: mov     rax,[rbp-40h]
    118: mov     [rbp-80h],rax
    11c: mov     rdx,[rbp-70h]
    120: mov     [rbp-78h],rdx
    124: mov     [rbp-60h],rax
    128: mov     [rbp-58h],rdx
    12c: mov     edi,0FFFFFFB0h
    131: mov     esi,0FFFFFFA0h
    136: call    ryo_h_MovW128
    13b: mov     edi,0FFFFFFD0h
    140: mov     esi,0FFFFFFB0h
    145: call    ryo_h_MovW128
    14a: jmp     90h

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
     31: mov     rdx,[rbp+18h]
     35: mov     [rbp-28h],rdx
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
     1b: mov     rdx,[rbp-28h]
     1f: mov     rdx,[rdx+8]
     23: mov     [rbp-20h],rdx
     27: add     rax,1
     2b: mov     [rbp-38h],rax
     2f: mov     [rbp-30h],rax
     33: mov     [rbp-28h],rdx
     37: mov     rsi,[rbp+10h]
     3b: mov     [rbp-40h],rsi
     3f: mov     [rbp-38h],rsi
     43: mov     edi,0FFFFFFC8h
     48: xor     esi,esi
     4a: mov     edx,0FFFFFFD0h
     4f: call    ryo_h_StoreW128
     54: mov     rax,[rbp-18h]
     58: mov     [rbp-10h],rax
     5c: mov     rdx,[rbp-20h]
     60: mov     [rbp-8],rdx
     64: mov     edi,0FFFFFFF0h
     69: mov     esi,10h
     6e: call    ryo_h_Ret
     73: leave
     74: ret

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
     24: mov     rdx,[rbp-10h]
     28: mov     [rbp-40h],rdx
     2c: mov     rsi,[rbp-8]
     30: mov     [rbp-38h],rsi
     34: mov     [rbp-30h],rdx
     38: mov     [rbp-28h],rdx
     3c: mov     edi,0FFFFFFA8h
     41: lea     rsi,[k1]
     48: call    ryo_h_AddrAbs
     4d: mov     qword ptr [rbp-50h],0C7h
     55: mov     rdx,[rbp-50h]
     59: mov     [rbp-48h],rdx
     5d: shl     rdx,1
     61: mov     [rbp-40h],rdx
     65: or      rdx,1
     69: mov     [rbp-38h],rdx
     6d: mov     [rbp-30h],rdx
     71: mov     rsi,[rbp-28h]
     75: mov     [rbp-20h],rsi
     79: mov     [rbp-18h],rdx
     7d: mov     edi,0FFFFFF80h
     82: mov     esi,0FFFFFFE0h
     87: call    ryo_h_MovW128
     8c: mov     byte ptr [rbp-70h],0
     90: mov     rdx,[rbp+10h]
     94: mov     [rbp-68h],rdx
     98: lea     rdi,[sym2]
     9f: lea     rsi,[site3]
     a6: mov     edx,0FFFFFFA0h
     ab: call    ryo_h_CallExt
     b0: test    rax,rax
     b3: je      0C0h
     b5: call    rax
     b7: nop     [rcx-10h]
     be: jmp     0D0h
     c0: mov     rdi,rbp
     c3: lea     rsi,[ro+4]
     ca: call    qword ptr [sym4]
     d0: call    ryo_h_Unreachable
     d5: ud2

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
     a6: mov     rdx,[rbp-38h]
     aa: sub     rdx,[rbp-30h]
     ae: mov     [rbp-38h],rdx
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
    154: mov     edx,[rbp-54h]
    157: mov     [rbp-80h],edx
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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-68h],rdx
     1b: cmp     rax,rdx
     1e: setb    [rbp-51h]
     22: test    byte ptr [rbp-51h],0FFh
     26: je      42h
     28: mov     rdi,[rbp+10h]
     2c: mov     [rbp-60h],rdi
     30: mov     r8,[rbp+18h]
     34: mov     [rbp-68h],r8
     38: cmp     r8,rdi
     3b: jae     0AFh
     3d: jmp     0C1h
     42: mov     qword ptr [rbp-50h],0
     4a: nop     [rax+rax]
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
    150: mov     rdx,[rbp-58h]
    154: add     rdx,1
    158: mov     [rbp-20h],rdx
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
     13: mov     rdx,[rbp+18h]
     17: mov     [rbp-68h],rdx
     1b: cmp     rax,rdx
     1e: setb    [rbp-51h]
     22: test    byte ptr [rbp-51h],0FFh
     26: je      3Fh
     28: mov     rdi,[rbp+10h]
     2c: mov     [rbp-60h],rdi
     30: mov     r8,[rbp+18h]
     34: mov     [rbp-68h],r8
     38: cmp     r8,rdi
     3b: jae     0AFh
     3d: jmp     0BDh
     3f: mov     qword ptr [rbp-50h],0
     47: nop     [rax+rax]
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
    14c: mov     rdx,[rbp-58h]
    150: add     rdx,1
    154: mov     [rbp-20h],rdx
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
     93: mov     rdx,[rbp+10h]
     97: mov     rcx,[rbp-40h]
     9b: mov     [rdx],rcx
     9e: mov     rsi,[rbp-28h]
     a2: sub     rsi,1
     a6: mov     [rbp-60h],rsi
     aa: mov     rdi,[rbp+10h]
     ae: mov     rcx,[rbp-60h]
     b2: mov     [rdi+8],rcx
     b6: mov     r8,[rbp-38h]
     ba: mov     [rbp-8],r8
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
    13e: mov     rsi,[rbp+10h]
    142: mov     rsi,[rsi+8]
    146: mov     [rbp-28h],rsi
    14a: cmp     rsi,0
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
     24: mov     rdx,[rbp-10h]
     28: mov     [rbp-40h],rdx
     2c: mov     rsi,[rbp-8]
     30: mov     [rbp-38h],rsi
     34: mov     [rbp-30h],rdx
     38: mov     [rbp-28h],rdx
     3c: mov     edi,0FFFFFFA8h
     41: lea     rsi,[k1]
     48: call    ryo_h_AddrAbs
     4d: mov     qword ptr [rbp-50h],0D1h
     55: mov     rdx,[rbp-50h]
     59: mov     [rbp-48h],rdx
     5d: shl     rdx,1
     61: mov     [rbp-40h],rdx
     65: or      rdx,1
     69: mov     [rbp-38h],rdx
     6d: mov     [rbp-30h],rdx
     71: mov     rsi,[rbp-28h]
     75: mov     [rbp-20h],rsi
     79: mov     [rbp-18h],rdx
     7d: mov     edi,0FFFFFF80h
     82: mov     esi,0FFFFFFE0h
     87: call    ryo_h_MovW128
     8c: mov     byte ptr [rbp-70h],0
     90: mov     rdx,[rbp+10h]
     94: mov     [rbp-68h],rdx
     98: lea     rdi,[sym2]
     9f: lea     rsi,[site3]
     a6: mov     edx,0FFFFFFA0h
     ab: call    ryo_h_CallExt
     b0: test    rax,rax
     b3: je      0C0h
     b5: call    rax
     b7: nop     [rcx-10h]
     be: jmp     0D0h
     c0: mov     rdi,rbp
     c3: lea     rsi,[ro+4]
     ca: call    qword ptr [sym4]
     d0: call    ryo_h_Unreachable
     d5: ud2

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
     73: mov     rdx,[rbp+10h]
     77: mov     [rbp-38h],rdx
     7b: mov     [rbp-70h],rdx
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
     1f: je      0F1h
     25: mov     edi,0FFFFFFF0h
     2a: lea     rsi,[k0]
     31: call    ryo_h_AddrAbs
     36: mov     qword ptr [rbp-8],0D2h
     3e: mov     rdx,[rbp-10h]
     42: mov     [rbp-48h],rdx
     46: mov     rsi,[rbp-8]
     4a: mov     [rbp-40h],rsi
     4e: mov     [rbp-38h],rdx
     52: mov     [rbp-30h],rdx
     56: mov     edi,0FFFFFFA0h
     5b: lea     rsi,[k1]
     62: call    ryo_h_AddrAbs
     67: mov     qword ptr [rbp-58h],0D2h
     6f: mov     rdx,[rbp-58h]
     73: mov     [rbp-50h],rdx
     77: shl     rdx,1
     7b: mov     [rbp-48h],rdx
     7f: or      rdx,1
     83: mov     [rbp-40h],rdx
     87: mov     [rbp-38h],rdx
     8b: mov     rsi,[rbp-30h]
     8f: mov     [rbp-28h],rsi
     93: mov     [rbp-20h],rdx
     97: mov     edi,0FFFFFF70h
     9c: mov     esi,0FFFFFFD8h
     a1: call    ryo_h_MovW128
     a6: mov     byte ptr [rbp-80h],0
     aa: mov     rdx,[rbp+18h]
     ae: mov     [rbp-78h],rdx
     b2: lea     rdi,[sym2]
     b9: lea     rsi,[site3]
     c0: mov     edx,0FFFFFF98h
     c5: call    ryo_h_CallExt
     ca: test    rax,rax
     cd: je      0DAh
     cf: call    rax
     d1: nop     [rcx-10h]
     d8: jmp     0EAh
     da: mov     rdi,rbp
     dd: lea     rsi,[ro+4]
     e4: call    qword ptr [sym4]
     ea: call    ryo_h_Unreachable
     ef: ud2
     f1: xor     edi,edi
     f3: xor     esi,esi
     f5: call    ryo_h_Ret
     fa: leave
     fb: ret

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

fn std::ptr::copy_nonoverlapping::<u8>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,50h
      8: mov     byte ptr [rbp-11h],1
      c: test    byte ptr [rbp-11h],0FFh
     10: je      5Fh
     12: mov     rsi,[rbp+10h]
     16: mov     [rbp-8],rsi
     1a: mov     rdi,[rbp+18h]
     1e: mov     [rbp-10h],rdi
     22: mov     [rbp-50h],rsi
     26: mov     [rbp-48h],rdi
     2a: mov     qword ptr [rbp-40h],1
     32: mov     qword ptr [rbp-38h],1
     3a: mov     r10,[rbp+20h]
     3e: mov     [rbp-30h],r10
     42: mov     edi,0FFFFFFD8h
     47: lea     rsi,[k0]
     4e: call    ryo_h_AddrAbs
     53: call    fn1
     58: nop     [rcx]
     5f: imul    rax,[rbp+20h],1
     64: mov     [rbp-18h],rax
     68: mov     edi,18h
     6d: mov     esi,10h
     72: mov     edx,0FFFFFFE8h
     77: call    ryo_h_Memcpy
     7c: xor     edi,edi
     7e: xor     esi,esi
     80: call    ryo_h_Ret
     85: leave
     86: ret

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
     16: mov     rdx,[rbp+18h]
     1a: mov     [rbp-88h],rdx
     21: call    fn0
     26: nop     [rcx-1Ah]
     2d: jmp     165h
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
     69: mov     rdx,[rbp-10h]
     6d: mov     [rbp-50h],rdx
     71: mov     rsi,[rbp-8]
     75: mov     [rbp-48h],rsi
     79: mov     [rbp-40h],rdx
     7d: mov     [rbp-38h],rdx
     81: mov     edi,0FFFFFF98h
     86: lea     rsi,[k2]
     8d: call    ryo_h_AddrAbs
     92: mov     qword ptr [rbp-60h],0DDh
     9a: mov     rdx,[rbp-60h]
     9e: mov     [rbp-58h],rdx
     a2: shl     rdx,1
     a6: mov     [rbp-50h],rdx
     aa: or      rdx,1
     ae: mov     [rbp-48h],rdx
     b2: mov     [rbp-40h],rdx
     b6: mov     rsi,[rbp-38h]
     ba: mov     [rbp-30h],rsi
     be: mov     [rbp-28h],rdx
     c2: mov     edi,0FFFFFF70h
     c7: mov     esi,0FFFFFFD0h
     cc: call    ryo_h_MovW128
     d1: mov     byte ptr [rbp-80h],0
     d5: mov     rdx,[rbp+28h]
     d9: mov     [rbp-78h],rdx
     dd: lea     rdi,[sym3]
     e4: lea     rsi,[site4]
     eb: mov     edx,0FFFFFF90h
     f0: call    ryo_h_CallExt
     f5: test    rax,rax
     f8: je      105h
     fa: call    rax
     fc: nop     [rcx-10h]
    103: jmp     115h
    105: mov     rdi,rbp
    108: lea     rsi,[ro+4]
    10f: call    qword ptr [sym5]
    115: call    ryo_h_Unreachable
    11a: ud2
    11c: nop     [rax]
    120: test    byte ptr [rbp+20h],0FFh
    124: je      13Ah
    126: jmp     135h
    128: nop     [rax+rax]
    130: jmp     50h
    135: jmp     40h
    13a: mov     rax,[rbp+10h]
    13e: mov     [rbp-28h],rax
    142: cmp     rax,0
    146: sete    [rbp-1Bh]
    14a: movzx   esi,byte ptr [rbp-1Bh]
    14e: xor     sil,1
    152: mov     [rbp-19h],sil
    156: test    byte ptr [rbp-19h],0FFh
    15a: je      50h
    160: jmp     40h
    165: test    byte ptr [rbp-1Ah],0FFh
    169: je      130h
    16b: jmp     120h
    16d: nop     [rax]
    170: lea     rdi,[sym6]
    177: lea     rsi,[site7]
    17e: mov     edx,0FFFFFF90h
    183: call    ryo_h_CallExt
    188: test    rax,rax
    18b: je      198h
    18d: call    rax
    18f: nop     [rcx-68h]
    196: jmp     1A8h
    198: mov     rdi,rbp
    19b: lea     rsi,[ro+20]
    1a2: call    qword ptr [sym8]
    1a8: call    ryo_h_Unreachable
    1ad: ud2
    1af: mov     rdi,rax
    1b2: mov     esi,0FFFFFFE8h
    1b7: call    ryo_h_Lpad
    1bc: jmp     170h

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

fn std::ptr::swap_nonoverlapping::<hashbrown::raw::RawTableInner>
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
     2d: mov     qword ptr [rbp-70h],20h
     35: mov     qword ptr [rbp-68h],8
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
     78: imul    rax,[rbp-20h],20h
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
      c: mov     rdx,[rbp+10h]
     10: mov     rdx,[rdx]
     13: mov     [rbp-58h],rdx
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
     34: mov     rdx,[rbp+10h]
     38: mov     [rbp-30h],rdx
     3c: mov     [rbp-48h],rdx
     40: mov     rsi,[rbp-30h]
     44: mov     [rbp-8],rsi
     48: jmp     6Ah
     4a: mov     byte ptr [rbp-21h],0
     4e: mov     rdx,[rbp+10h]
     52: mov     [rbp-60h],rdx
     56: mov     rsi,[rbp+18h]
     5a: mov     [rbp-58h],rsi
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
     7f: jmp     2A9h
     84: mov     rax,[rbp+10h]
     88: mov     [rbp-60h],rax
     8c: mov     [rbp-80h],rax
     90: mov     rdx,[rbp-60h]
     94: mov     [rbp-8],rdx
     98: jmp     2A9h
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
     ec: .long   2bah
     f0: .long   2cah
     f4: .long   70h
     f8: lea     rax,[rbp-50h]
     fc: mov     [rbp-98h],rax
    103: mov     edi,0FFFFFF48h
    108: lea     rsi,[k0]
    10f: call    ryo_h_AddrAbs
    114: mov     qword ptr [rbp-0B0h],2Bh
    11f: mov     rdx,[rbp-0B8h]
    126: mov     [rbp-0D8h],rdx
    12d: mov     rsi,[rbp-0B0h]
    134: mov     [rbp-0D0h],rsi
    13b: mov     [rbp-0C8h],rdx
    142: mov     [rbp-0C0h],rdx
    149: mov     edi,0FFFFFF10h
    14e: lea     rsi,[k1]
    155: call    ryo_h_AddrAbs
    15a: mov     qword ptr [rbp-0E8h],2Bh
    165: mov     rdx,[rbp-0E8h]
    16c: mov     [rbp-0E0h],rdx
    173: shl     rdx,1
    177: mov     [rbp-0D8h],rdx
    17e: or      rdx,1
    182: mov     [rbp-0D0h],rdx
    189: mov     [rbp-0C8h],rdx
    190: mov     rsi,[rbp-0C0h]
    197: mov     [rbp-0A8h],rsi
    19e: mov     [rbp-0A0h],rdx
    1a5: mov     rdi,[rbp-98h]
    1ac: mov     [rbp-120h],rdi
    1b3: mov     edi,0FFFFFEE8h
    1b8: mov     esi,0FFFFFF58h
    1bd: call    ryo_h_MovW128
    1c2: call    fn2
    1c7: nop     [rcx-90h]
    1ce: jmp     22Fh
    1d0: lea     rax,[rbp-80h]
    1d4: mov     [rbp-98h],rax
    1db: mov     [rbp-90h],rax
    1e2: mov     [rbp-98h],rax
    1e9: mov     [rbp-120h],rax
    1f0: mov     edi,0FFFFFF08h
    1f5: lea     rsi,[sym3]
    1fc: call    ryo_h_AddrSym
    201: mov     rdi,rbp
    204: lea     rsi,[ro+4]
    20b: call    qword ptr [sym4]
    211: jmp     4D4h
    216: mov     rax,[rbp+10h]
    21a: mov     [rbp-120h],rax
    221: call    fn5
    226: nop     [rcx-38h]
    22d: jmp     290h
    22f: lea     rax,[rbp-90h]
    236: mov     [rbp-0F8h],rax
    23d: mov     [rbp-120h],rax
    244: call    fn6
    249: nop     [rcx-0F8h]
    250: lea     rdi,[sym7]
    257: lea     rsi,[site8]
    25e: mov     edx,0FFFFFF08h
    263: call    ryo_h_CallExt
    268: test    rax,rax
    26b: je      278h
    26d: call    rax
    26f: nop     [rcx-50h]
    276: jmp     288h
    278: mov     rdi,rbp
    27b: lea     rsi,[ro+20]
    282: call    qword ptr [sym9]
    288: call    ryo_h_Unreachable
    28d: ud2
    28f: nop
    290: mov     rax,[rbp+10h]
    294: mov     [rbp-70h],rax
    298: mov     [rbp-88h],rax
    29f: mov     rdx,[rbp-70h]
    2a3: mov     [rbp-8],rdx
    2a7: jmp     2A9h
    2a9: mov     edi,0FFFFFFF8h
    2ae: mov     esi,8
    2b3: call    ryo_h_Ret
    2b8: leave
    2b9: ret
    2ba: mov     qword ptr [rbp-88h],0
    2c5: jmp     3A5h
    2ca: mov     rax,[rbp+18h]
    2ce: mov     [rbp-98h],rax
    2d5: mov     qword ptr [rbp-0B0h],0
    2e0: mov     edi,0FFFFFF78h
    2e5: mov     esi,0FFFFFF68h
    2ea: xor     edx,edx
    2ec: mov     ecx,18h
    2f1: call    ryo_h_LoadCopy
    2f6: mov     edi,0FFFFFF68h
    2fb: xor     esi,esi
    2fd: mov     edx,0FFFFFF50h
    302: mov     ecx,18h
    307: call    ryo_h_StoreCopy
    30c: mov     rax,[rbp-88h]
    313: mov     [rbp-90h],rax
    31a: mov     edi,0FFFFFF70h
    31f: xor     esi,esi
    321: mov     edx,2
    326: call    ryo_h_SwitchDenseW64
    32b: lea     rcx,[33Ch]
    332: movsxd  rax,[rcx+rax*4]
    336: add     rax,rcx
    339: jmp     rax
    33b: int3
    33c: .long   3a5h
    340: .long   3b3h
    344: .long   70h
    348: nop     [rax+rax]
    350: mov     rax,[rbp+10h]
    354: mov     [rbp-68h],rax
    358: mov     [rbp-88h],rax
    35f: mov     edi,0FFFFFF48h
    364: mov     esi,0FFFFFFD0h
    369: call    ryo_h_MovW128
    36e: mov     edi,0FFFFFF58h
    373: mov     esi,0FFFFFF48h
    378: call    ryo_h_MovW128
    37d: mov     edi,0FFFFFF68h
    382: mov     esi,0FFFFFF58h
    387: call    ryo_h_MovW128
    38c: mov     byte ptr [rbp-0F1h],1
    393: test    byte ptr [rbp-0F1h],0FFh
    39a: je      489h
    3a0: jmp     448h
    3a5: call    fn10
    3aa: nop     [rcx-30h]
    3b1: jmp     3C4h
    3b3: mov     edi,0FFFFFFD0h
    3b8: mov     esi,0FFFFFF80h
    3bd: call    ryo_h_MovW128
    3c2: jmp     350h
    3c4: jmp     350h
    3c6: nop     [rax+rax]
    3cf: nop
    3d0: mov     byte ptr [rbp-82h],1
    3d7: mov     rdx,[rbp+10h]
    3db: lea     rdx,[rdx+10h]
    3df: mov     [rbp-98h],rdx
    3e6: mov     [rbp-90h],rdx
    3ed: movzx   edx,byte ptr [rdx]
    3f0: mov     [rbp-81h],dl
    3f6: mov     rsi,[rbp-90h]
    3fd: movzx   ecx,byte ptr [rbp-82h]
    404: mov     [rsi],cl
    406: mov     edi,0FFFFFFB8h
    40b: mov     esi,0FFFFFF7Fh
    410: call    ryo_h_ZextW8W64
    415: mov     edi,0FFFFFFB8h
    41a: xor     esi,esi
    41c: mov     edx,3
    421: call    ryo_h_SwitchDenseW64
    426: lea     rcx,[438h]
    42d: movsxd  rax,[rcx+rax*4]
    431: add     rax,rcx
    434: jmp     rax
    436: int3
    437: int3
    438: .long   216h
    43c: .long   1d0h
    440: .long   f8h
    444: .long   70h
    448: mov     rax,[rbp-68h]
    44c: mov     [rbp-0A0h],rax
    453: mov     [rbp-120h],rax
    45a: mov     qword ptr [rbp-118h],8
    465: mov     byte ptr [rbp-110h],0
    46c: mov     edi,0FFFFFEF8h
    471: lea     rsi,[k11]
    478: call    ryo_h_AddrAbs
    47d: call    fn12
    482: nop     [rcx-68h]
    489: mov     byte ptr [rbp-0F1h],0
    490: test    byte ptr [rbp-0F1h],0FFh
    497: je      4ADh
    499: mov     edi,0FFFFFF80h
    49e: mov     esi,0FFFFFF68h
    4a3: call    ryo_h_MovW128
    4a8: jmp     3D0h
    4ad: mov     edi,0FFFFFF80h
    4b2: mov     esi,0FFFFFF78h
    4b7: xor     edx,edx
    4b9: call    ryo_h_LoadW128
    4be: mov     edi,0FFFFFF78h
    4c3: xor     esi,esi
    4c5: mov     edx,0FFFFFF68h
    4ca: call    ryo_h_StoreW128
    4cf: jmp     3D0h
    4d4: jmp     290h

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

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
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

