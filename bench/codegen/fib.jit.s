fn fib
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    cmp     ebx,2
    jae     L0
    mov     eax,ebx
    jmp     L1
L0:
    mov     rax,rbx
    sub     eax,1
    mov     rdi,rax
    mov     edi,edi
    call    fn2
    mov     r12,rax
    sub     ebx,2
    mov     rdi,rbx
    mov     edi,edi
    call    fn2
    add     r12,rax
    jb      L2
    mov     rax,r12
L1:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L2:
    lea     rax,[k6]
    mov     rdi,rax
    call    sym7
    ud2

