fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    sub     rsp,28h
    mov     [rsp+10h],rdi
    lea     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn fib
    sub     rsp,68h
    mov     [rsp+54h],edi
    cmp     dword ptr [rsp+54h],2
    jae     L0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFF4h
    call    ryo_h_ZextW32W64
    jmp     L4
L0:
    mov     dword ptr [rsp+0Ch],1
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFF4h
    mov     r8d,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rsp+40h],0FFh
    je      L1
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     eax,[rsp+3Ch]
    mov     [rsp+44h],eax
    mov     edi,[rsp+44h]
    call    fn2
    mov     [rsp+48h],rax
    mov     dword ptr [rsp+0Ch],2
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC4h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFF4h
    mov     r8d,0FFFFFFACh
    call    ryo_h_SubOvfUW32
    test    byte ptr [rsp+28h],0FFh
    je      L2
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym4]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     eax,[rsp+24h]
    mov     [rsp+2Ch],eax
    mov     edi,[rsp+2Ch]
    call    fn5
    mov     [rsp+30h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFB8h
    mov     ecx,0FFFFFFE8h
    mov     r8d,0FFFFFFD0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+18h],0FFh
    je      L3
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym7]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+10h]
    mov     [rsp+58h],rax
L4:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn main
    sub     rsp,0B8h
    mov     dword ptr [rsp+0Ch],27h
    mov     edi,[rsp+0Ch]
    call    fn0
    mov     [rsp+0ACh],eax
    mov     edi,[rsp+0ACh]
    call    fn1
    mov     [rsp+78h],rax
    lea     rax,[rsp+78h]
    lea     rdx,[rsp+0ACh]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+40h]
    mov     rsi,[rsp+18h]
    call    fn2
    mov     rax,[rsp+88h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    call    fn3
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF80h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn5
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+0A0h]
    call    qword ptr [sym6]
    add     rsp,0B8h
    ret

fn std::fmt::Arguments::<'_>::new::<15, 2>
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn std::hint::black_box::<u32>
    sub     rsp,18h
    mov     [rsp+8],edi
    mov     eax,[rsp+8]
    mov     [rsp+0Ch],eax
    mov     eax,[rsp+0Ch]
    add     rsp,18h
    ret

fn std::rt::lang_start::<()>
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+2Fh],cl
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdx,[rsp+8]
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    movzx   r8d,byte ptr [rsp+2Fh]
    call    qword ptr [sym1]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret

fn std::rt::lang_start::<()>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    call    fn1
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    mov     [rsp+0Eh],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFEEh
    call    ryo_h_ZextW8W32
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret

