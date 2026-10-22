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

fn fib
      0: push    rbp
      1: mov     rbp,rsp
      4: sub     rsp,60h
      8: cmp     dword ptr [rbp+10h],2
      c: jae     22h
      e: mov     edi,0FFFFFFF8h
     13: mov     esi,10h
     18: call    ryo_h_ZextW32W64
     1d: jmp     1B5h
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
     9e: mov     eax,[rbp-1Ch]
     a1: mov     [rbp-60h],eax
     a4: call    fn4
     a9: nop     [rcx-18h]
     b0: mov     dword ptr [rbp-54h],2
     b7: mov     edi,0FFFFFFC4h
     bc: mov     esi,0FFFFFFC8h
     c1: mov     edx,10h
     c6: mov     ecx,0FFFFFFACh
     cb: call    ryo_h_SubOvfUW32
     d0: test    byte ptr [rbp-38h],0FFh
     d4: je      126h
     d6: mov     edi,0FFFFFFA0h
     db: lea     rsi,[k5]
     e2: call    ryo_h_AddrAbs
     e7: lea     rdi,[sym6]
     ee: lea     rsi,[site7]
     f5: mov     edx,0FFFFFFA8h
     fa: call    ryo_h_CallExt
     ff: test    rax,rax
    102: je      10Fh
    104: call    rax
    106: nop     [rcx-50h]
    10d: jmp     11Fh
    10f: mov     rdi,rbp
    112: lea     rsi,[ro+4]
    119: call    qword ptr [sym8]
    11f: call    ryo_h_Unreachable
    124: ud2
    126: mov     eax,[rbp-3Ch]
    129: mov     [rbp-34h],eax
    12c: mov     eax,[rbp-34h]
    12f: mov     [rbp-60h],eax
    132: call    fn9
    137: nop     [rcx-30h]
    13e: mov     edi,0FFFFFFB0h
    143: mov     esi,0FFFFFFB8h
    148: mov     edx,0FFFFFFE8h
    14d: mov     ecx,0FFFFFFD0h
    152: call    ryo_h_AddOvfUW64
    157: test    byte ptr [rbp-48h],0FFh
    15b: je      1ADh
    15d: mov     edi,0FFFFFFA0h
    162: lea     rsi,[k10]
    169: call    ryo_h_AddrAbs
    16e: lea     rdi,[sym11]
    175: lea     rsi,[site12]
    17c: mov     edx,0FFFFFFA8h
    181: call    ryo_h_CallExt
    186: test    rax,rax
    189: je      196h
    18b: call    rax
    18d: nop     [rcx-50h]
    194: jmp     1A6h
    196: mov     rdi,rbp
    199: lea     rsi,[ro+4]
    1a0: call    qword ptr [sym13]
    1a6: call    ryo_h_Unreachable
    1ab: ud2
    1ad: mov     rax,[rbp-50h]
    1b1: mov     [rbp-8],rax
    1b5: mov     edi,0FFFFFFF8h
    1ba: mov     esi,8
    1bf: call    ryo_h_Ret
    1c4: leave
    1c5: ret

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
     56: mov     rax,[rbp-20h]
     5a: mov     [rbp-98h],rax
     61: mov     rax,[rbp-98h]
     68: mov     [rbp-0C0h],rax
     6f: call    fn2
     74: nop     [rcx-70h]
     7b: mov     rax,[rbp-28h]
     7f: mov     [rbp-0A0h],rax
     86: mov     rax,[rbp-0A0h]
     8d: mov     [rbp-0C0h],rax
     94: call    fn3
     99: nop     [rcx-80h]
     a0: mov     edi,0FFFFFFA0h
     a5: mov     esi,0FFFFFF90h
     aa: call    ryo_h_MovW128
     af: mov     edi,0FFFFFFB0h
     b4: mov     esi,0FFFFFF80h
     b9: call    ryo_h_MovW128
     be: mov     edi,0FFFFFF78h
     c3: lea     rsi,[k4]
     ca: call    ryo_h_AddrAbs
     cf: lea     rax,[rbp-60h]
     d3: mov     [rbp-90h],rax
     da: mov     rax,[rbp-88h]
     e1: mov     [rbp-0C0h],rax
     e8: mov     rax,[rbp-90h]
     ef: mov     [rbp-0B8h],rax
     f6: call    fn5
     fb: nop     [rcx-18h]
    102: mov     edi,0FFFFFF40h
    107: mov     esi,0FFFFFFE8h
    10c: call    ryo_h_MovW128
    111: lea     rdi,[sym6]
    118: lea     rsi,[site7]
    11f: mov     edx,0FFFFFF58h
    124: call    ryo_h_CallExt
    129: test    rax,rax
    12c: je      139h
    12e: call    rax
    130: nop     [rcx-4]
    137: jmp     149h
    139: mov     rdi,rbp
    13c: lea     rsi,[ro+4]
    143: call    qword ptr [sym8]
    149: xor     edi,edi
    14b: xor     esi,esi
    14d: call    ryo_h_Ret
    152: leave
    153: ret

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

