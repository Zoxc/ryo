fn fib
    push    rbx
    push    r12
    sub     rsp,8
    mov     rbx,rdi
    cmp     ebx,2
    jae     L0
    mov     eax,ebx
    jmp     L1
L0:
    mov     rax,rbx
    sub     eax,1
    mov     rdi,rax
    call    fn2
    mov     r12,rax
    sub     ebx,2
    mov     rdi,rbx
    call    fn2
    add     r12,rax
    jb      L2
    mov     rax,r12
L1:
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L2:
    lea     rax,[k6]
    mov     rdi,rax
    call    sym7
    ud2

