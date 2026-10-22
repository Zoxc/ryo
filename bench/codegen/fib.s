fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,8
    lea     rdi,[rsp]
    mov     esi,10h
    lea     rdx,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    add     rsp,8
    ret

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    sub     rsp,28h
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp],rax
    call    fn0
    mov     [rsp+0Ch],eax
    mov     eax,[rsp+0Ch]
    add     rsp,18h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret

fn fib
    sub     rsp,68h
    cmp     dword ptr [rsp+70h],2
    jae     L0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    mov     edx,10h
    call    ryo_h_ZextW32W64
    jmp     L10
L0:
    mov     dword ptr [rsp+0Ch],1
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFE0h
    mov     ecx,10h
    mov     r8d,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rsp+40h],0FFh
    je      L3
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+60h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    jmp     L2
L1:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     eax,[rsp+3Ch]
    mov     [rsp+44h],eax
    mov     [rsp],eax
    call    fn4
    mov     [rsp+48h],rax
    mov     dword ptr [rsp+0Ch],2
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC4h
    mov     edx,0FFFFFFC8h
    mov     ecx,10h
    mov     r8d,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rsp+28h],0FFh
    je      L6
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+60h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    jmp     L5
L4:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L5:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     eax,[rsp+24h]
    mov     [rsp+2Ch],eax
    mov     [rsp],eax
    call    fn9
    mov     [rsp+30h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFB8h
    mov     ecx,0FFFFFFE8h
    mov     r8d,0FFFFFFD0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+18h],0FFh
    je      L9
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+60h]
    lea     rsi,[sym11]
    lea     rdx,[site12]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    jmp     L8
L7:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L8:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rsp+10h]
    mov     [rsp+58h],rax
L10:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn main
    sub     rsp,0C8h
    mov     dword ptr [rsp],27h
    call    fn0
    mov     [rsp+0BCh],eax
    mov     eax,[rsp+0BCh]
    mov     [rsp],eax
    call    fn1
    mov     [rsp+88h],rax
    lea     rax,[rsp+88h]
    lea     rdx,[rsp+0BCh]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     [rsp+28h],rdx
    mov     [rsp],rdx
    call    fn2
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+98h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn3
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF80h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn5
    mov     [rsp+0A8h],rax
    mov     [rsp+0B0h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L1:
    add     rsp,0C8h
    ret

fn std::fmt::Arguments::<'_>::new::<15, 2>
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret

fn std::hint::black_box::<u32>
    sub     rsp,18h
    mov     eax,[rsp+20h]
    mov     [rsp+0Ch],eax
    mov     eax,[rsp+0Ch]
    add     rsp,18h
    ret

fn std::rt::lang_start::<()>
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+18h],rdx
    movzx   esi,byte ptr [rsp+88h]
    mov     [rsp+20h],sil
    lea     rdi,[rsp+60h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    mov     [rsp+58h],rax
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn std::rt::lang_start::<()>::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    call    fn1
    mov     [rsp+1Bh],al
    movzx   eax,byte ptr [rsp+1Bh]
    mov     [rsp+1Ah],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp],rax
    call    fn0
    add     rsp,18h
    ret

