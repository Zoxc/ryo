fn <() as std::process::Termination>::report
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    sub     qword ptr [jit_record.ctr],10h
    js      L4
L0:
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
    nop     [rax]
L1:
    sub     qword ptr [jit_record.ctr],1
    js      L3
L2:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn fib
    sub     qword ptr [jit_record.ctr],10h
    js      L6
L0:
    sub     rsp,68h
    mov     [rsp+54h],edi
    cmp     dword ptr [rsp+54h],2
    jae     L1
    mov     edx,[rsp+54h]
    mov     [rsp+58h],rdx
    jmp     L5
L1:
    mov     dword ptr [rsp+0Ch],1
    mov     edx,[rsp+54h]
    sub     edx,[rsp+0Ch]
    setb    cl
    mov     [rsp+40h],cl
    mov     [rsp+3Ch],edx
    test    byte ptr [rsp+40h],0FFh
    je      L2
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    ud2
L2:
    mov     eax,[rsp+3Ch]
    mov     [rsp+44h],eax
    mov     edi,[rsp+44h]
    call    fn2
    mov     [rsp+48h],rax
    mov     dword ptr [rsp+0Ch],2
    mov     edx,[rsp+54h]
    sub     edx,[rsp+0Ch]
    setb    cl
    mov     [rsp+28h],cl
    mov     [rsp+24h],edx
    test    byte ptr [rsp+28h],0FFh
    je      L3
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym4]
    ud2
L3:
    mov     eax,[rsp+24h]
    mov     [rsp+2Ch],eax
    mov     edi,[rsp+2Ch]
    call    fn5
    mov     [rsp+30h],rax
    mov     rax,[rsp+48h]
    add     rax,[rsp+30h]
    setb    cl
    mov     [rsp+18h],cl
    mov     [rsp+10h],rax
    test    byte ptr [rsp+18h],0FFh
    je      L4
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym7]
    ud2
L4:
    mov     rax,[rsp+10h]
    mov     [rsp+58h],rax
L5:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rax
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+68h],rcx
    mov     [rsp+60h],rdx
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::Arguments::<'_>::new::<15, 2>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::black_box::<u32>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
    sub     rsp,18h
    mov     [rsp+8],edi
    mov     eax,[rsp+8]
    mov     [rsp+0Ch],eax
    mov     eax,[rsp+0Ch]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>::{closure#0}
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
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
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     qword ptr [jit_record.ctr],10h
    js      L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

