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

fn fib
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: cmp     dword ptr [rbp+10h],2
      c: jae     22h
      e: mov     edi,0FFFFFFF8h
     13: mov     esi,10h
     18: call    ryo_h_ZextW32W64
     1d: jmp     1AFh
     22: mov     dword ptr [rbp-54h],1
     29: mov     edi,0FFFFFFDCh
     2e: mov     esi,0FFFFFFE0h
     33: mov     edx,10h
     38: mov     ecx,0FFFFFFACh
     3d: call    ryo_h_SubOvfUW32
     42: test    byte ptr [rbp-20h],0FFh
     46: je      98h
     48: mov     edi,0FFFFFFA0h
     4d: lea     rsi,[k0]
     54: call    ryo_h_AddrAbs
     59: lea     rdi,[sym1]
     60: lea     rsi,[site2]
     67: mov     edx,0FFFFFFA8h
     6c: call    ryo_h_CallExt
     71: test    rax,rax
     74: je      81h
     76: call    rax
     78: nop     [rcx-50h]
     7f: jmp     91h
     81: mov     rdi,rbp
     84: lea     rsi,[ro+4]
     8b: call    qword ptr [sym3]
     91: call    ryo_h_Unreachable
     96: ud2
     98: mov     eax,[rbp-24h]
     9b: mov     [rbp-1Ch],eax
     9e: mov     [rbp-60h],eax
     a1: call    fn4
     a6: nop     [rcx-18h]
     ad: mov     dword ptr [rbp-54h],2
     b4: mov     edi,0FFFFFFC4h
     b9: mov     esi,0FFFFFFC8h
     be: mov     edx,10h
     c3: mov     ecx,0FFFFFFACh
     c8: call    ryo_h_SubOvfUW32
     cd: test    byte ptr [rbp-38h],0FFh
     d1: je      123h
     d3: mov     edi,0FFFFFFA0h
     d8: lea     rsi,[k5]
     df: call    ryo_h_AddrAbs
     e4: lea     rdi,[sym6]
     eb: lea     rsi,[site7]
     f2: mov     edx,0FFFFFFA8h
     f7: call    ryo_h_CallExt
     fc: test    rax,rax
     ff: je      10Ch
    101: call    rax
    103: nop     [rcx-50h]
    10a: jmp     11Ch
    10c: mov     rdi,rbp
    10f: lea     rsi,[ro+4]
    116: call    qword ptr [sym8]
    11c: call    ryo_h_Unreachable
    121: ud2
    123: mov     eax,[rbp-3Ch]
    126: mov     [rbp-34h],eax
    129: mov     [rbp-60h],eax
    12c: call    fn9
    131: nop     [rcx-30h]
    138: mov     edi,0FFFFFFB0h
    13d: mov     esi,0FFFFFFB8h
    142: mov     edx,0FFFFFFE8h
    147: mov     ecx,0FFFFFFD0h
    14c: call    ryo_h_AddOvfUW64
    151: test    byte ptr [rbp-48h],0FFh
    155: je      1A7h
    157: mov     edi,0FFFFFFA0h
    15c: lea     rsi,[k10]
    163: call    ryo_h_AddrAbs
    168: lea     rdi,[sym11]
    16f: lea     rsi,[site12]
    176: mov     edx,0FFFFFFA8h
    17b: call    ryo_h_CallExt
    180: test    rax,rax
    183: je      190h
    185: call    rax
    187: nop     [rcx-50h]
    18e: jmp     1A0h
    190: mov     rdi,rbp
    193: lea     rsi,[ro+4]
    19a: call    qword ptr [sym13]
    1a0: call    ryo_h_Unreachable
    1a5: ud2
    1a7: mov     rax,[rbp-50h]
    1ab: mov     [rbp-8],rax
    1af: mov     edi,0FFFFFFF8h
    1b4: mov     esi,8
    1b9: call    ryo_h_Ret
    1be: leave
    1bf: ret

fn main
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,0C0h
      b: mov     dword ptr [rbp-0C0h],27h
     15: call    fn0
     1a: nop     [rcx-4]
     21: mov     eax,[rbp-4]
     24: mov     [rbp-0C0h],eax
     2a: call    fn1
     2f: nop     [rcx-38h]
     36: lea     rax,[rbp-38h]
     3a: mov     [rbp-30h],rax
     3e: lea     rax,[rbp-4]
     42: mov     [rbp-40h],rax
     46: mov     rax,[rbp-30h]
     4a: mov     [rbp-28h],rax
     4e: mov     rax,[rbp-40h]
     52: mov     [rbp-20h],rax
     56: mov     [rbp-98h],rax
     5d: mov     [rbp-0C0h],rax
     64: call    fn2
     69: nop     [rcx-70h]
     70: mov     rax,[rbp-28h]
     74: mov     [rbp-0A0h],rax
     7b: mov     [rbp-0C0h],rax
     82: call    fn3
     87: nop     [rcx-80h]
     8e: mov     edi,0FFFFFFA0h
     93: mov     esi,0FFFFFF90h
     98: call    ryo_h_MovW128
     9d: mov     edi,0FFFFFFB0h
     a2: mov     esi,0FFFFFF80h
     a7: call    ryo_h_MovW128
     ac: mov     edi,0FFFFFF78h
     b1: lea     rsi,[k4]
     b8: call    ryo_h_AddrAbs
     bd: lea     rax,[rbp-60h]
     c1: mov     [rbp-90h],rax
     c8: mov     rax,[rbp-88h]
     cf: mov     [rbp-0C0h],rax
     d6: mov     rax,[rbp-90h]
     dd: mov     [rbp-0B8h],rax
     e4: call    fn5
     e9: nop     [rcx-18h]
     f0: mov     edi,0FFFFFF40h
     f5: mov     esi,0FFFFFFE8h
     fa: call    ryo_h_MovW128
     ff: lea     rdi,[sym6]
    106: lea     rsi,[site7]
    10d: mov     edx,0FFFFFF58h
    112: call    ryo_h_CallExt
    117: test    rax,rax
    11a: je      127h
    11c: call    rax
    11e: nop     [rcx-4]
    125: jmp     137h
    127: mov     rdi,rbp
    12a: lea     rsi,[ro+4]
    131: call    qword ptr [sym8]
    137: xor     edi,edi
    139: xor     esi,esi
    13b: call    ryo_h_Ret
    140: leave
    141: ret

fn std::fmt::Arguments::<'_>::new::<15, 2>
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

fn std::hint::black_box::<u32>
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,10h
      8: mov     eax,[rbp+10h]
      b: mov     [rbp-4],eax
      e: mov     edi,0FFFFFFFCh
     13: mov     esi,4
     18: call    ryo_h_Ret
     1d: leave
     1e: ret

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

