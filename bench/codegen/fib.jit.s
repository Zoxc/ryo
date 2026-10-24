fn fib
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    cmp     ebx,2
    jae     L0
    mov     rdi,rbx
    call    ryo_hr_ZextW32W64
    jmp     L4
L0:
    mov     rdi,rbx
    mov     esi,1
    call    ryo_hr_SubOvfUW32
    mov     r12,rax
    test    dl,dl
    je      L1
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     rdi,r12
    mov     edi,edi
    call    fn2
    mov     r12,rax
    mov     rdi,rbx
    mov     esi,2
    call    ryo_hr_SubOvfUW32
    mov     rbx,rax
    test    dl,dl
    je      L2
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rdi,rbx
    mov     edi,edi
    call    fn2
    mov     rdi,r12
    mov     rsi,rax
    call    ryo_hr_AddOvfUW64
    mov     rbx,rax
    test    dl,dl
    je      L3
    lea     rdi,[k6]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym7]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,rbx
L4:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

