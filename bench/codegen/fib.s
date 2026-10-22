fn <() as std::process::Termination>::report
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     byte ptr [rbp-1],0
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    push    rbp
    mov     rbp,rsp
    mov     edi,10h
    lea     rsi,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    lea     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn fib
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    cmp     dword ptr [rbp+10h],2
    jae     L0
    mov     edi,0FFFFFFF8h
    mov     esi,10h
    call    ryo_h_ZextW32W64
    jmp     L10
L0:
    mov     dword ptr [rbp-54h],1
    mov     edi,0FFFFFFDCh
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    mov     ecx,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rbp-20h],0FFh
    je      L3
    mov     edi,0FFFFFFA0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-50h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     eax,[rbp-24h]
    mov     [rbp-1Ch],eax
    mov     [rbp-60h],eax
    call    fn4
    nop     [rcx-18h]
    mov     dword ptr [rbp-54h],2
    mov     edi,0FFFFFFC4h
    mov     esi,0FFFFFFC8h
    mov     edx,10h
    mov     ecx,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rbp-38h],0FFh
    je      L6
    mov     edi,0FFFFFFA0h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-50h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     eax,[rbp-3Ch]
    mov     [rbp-34h],eax
    mov     [rbp-60h],eax
    call    fn9
    nop     [rcx-30h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-48h],0FFh
    je      L9
    mov     edi,0FFFFFFA0h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-50h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rbp-50h]
    mov     [rbp-8],rax
L10:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn main
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     dword ptr [rbp-0C0h],27h
    call    fn0
    nop     [rcx-4]
    mov     eax,[rbp-4]
    mov     [rbp-0C0h],eax
    call    fn1
    nop     [rcx-38h]
    lea     rax,[rbp-38h]
    lea     rdx,[rbp-4]
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     [rbp-98h],rdx
    mov     [rbp-0C0h],rdx
    call    fn2
    nop     [rcx-70h]
    mov     rax,[rbp-28h]
    mov     [rbp-0A0h],rax
    mov     [rbp-0C0h],rax
    call    fn3
    nop     [rcx-80h]
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF78h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rax,[rbp-60h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-0C0h],rdx
    mov     [rbp-0B8h],rax
    call    fn5
    nop     [rcx-18h]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-4]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::Arguments::<'_>::new::<15, 2>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::hint::black_box::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     eax,[rbp+10h]
    mov     [rbp-4],eax
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    lea     rdx,[rbp-28h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    movzx   esi,byte ptr [rbp+28h]
    mov     [rbp-40h],sil
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    call    fn1
    nop     [rcx-5]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-6],al
    mov     edi,0FFFFFFFCh
    mov     esi,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

