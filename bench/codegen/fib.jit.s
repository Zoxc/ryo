fn fib
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     rbx,rdi
    cmp     ebx,2
    jae     L0
    mov     [rsp+8],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp]
    jmp     L4
L0:
    mov     [rsp+10h],rbx
    mov     qword ptr [rsp+18h],1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFD0h
    mov     r8d,0FFFFFFD8h
    call    ryo_h_SubOvfUW32
    mov     r12d,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rax,[rsp]
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     rdi,r12
    mov     edi,edi
    call    fn2
    mov     r12,rax
    mov     [rsp+10h],rbx
    mov     qword ptr [rsp+18h],2
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFD0h
    mov     r8d,0FFFFFFD8h
    call    ryo_h_SubOvfUW32
    mov     ebx,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L2
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rax,[rsp]
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rdi,rbx
    mov     edi,edi
    call    fn2
    mov     [rsp+10h],r12
    mov     [rsp+18h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFD0h
    mov     r8d,0FFFFFFD8h
    call    ryo_h_AddOvfUW64
    mov     rbx,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L3
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    mov     rax,[rsp]
    mov     rdi,rax
    call    qword ptr [sym7]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,rbx
L4:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    add     rsp,48h
    ret

