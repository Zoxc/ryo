fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,18h
    movzx   eax,byte ptr [rsi]
    add     rsp,18h
    ret
  ; OSR entries
    lea     r11,[L0]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L0:
    .long   L1
L1:
    ret

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     [rsp+10h],rdx
    cmp     rdi,rsi
    jne     L0
    mov     r9,rdx
    jmp     L3
L0:
    lea     rcx,[k1]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    jmp     L4
L1:
    lea     r8,[rsp+10h]
    lea     r9,[rbx+r12]
    mov     rdi,r8
    mov     rsi,rax
    mov     rdx,r9
    call    fn0
    lea     r8,[k6]
    mov     r11,r12
    add     r11,1
    jb      L7
    add     r12,1
    cmp     r12,r13
    jne     L5
    mov     r9,rax
    jmp     L3
L2:
    mov     rax,r9
    mov     rbx,r14
    mov     r12,r15
    mov     r13,rbp
    jmp     L1
L3:
    mov     rax,r9
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L4:
    mov     rax,rdx
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
    jmp     L1
L5:
    mov     r9,rax
    mov     r14,rbx
    mov     r15,r12
    mov     rbp,r13
    jmp     L2
L6:
    lea     rdi,[image.k1032]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym14
    ud2
L7:
    lea     rdi,[image.k1233]
    mov     esi,175h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym14
    ud2
    jmp     L9
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L8
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
    .long   L19
L11:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-30h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    lea     rsp,[rsp+0C0h]
    jmp     L1
L12:
    ret
L13:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-30h],r11
    mov     r9,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+0C0h]
    jmp     L2
L14:
    ret
L15:
    ret
L16:
    ret
L17:
    ret
L18:
    ret
L19:
    ret

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    cmp     rsi,rcx
    jae     L0
    lea     rax,[rax+rsi]
    add     rsp,18h
    ret
L0:
    mov     rdi,rsi
    mov     rsi,rcx
    call    image.sym15
    ud2

fn core::num::<impl usize>::unchecked_add::precondition_check
    sub     rsp,18h
    mov     r11,rdi
    add     r11,rsi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rdi,[k0]
    mov     esi,175h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    sym2
    ud2

fn sieve
    sub     rsp,0B8h
    mov     [rsp+70h],rbx
    mov     [rsp+68h],r12
    mov     [rsp+60h],r13
    mov     [rsp+58h],r14
    mov     [rsp+50h],r15
    mov     [rsp+48h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdx,r12
    add     rdx,1
    jb      L10
    lea     rdi,[rsp+28h]
    mov     esi,1
    movzx   esi,sil
    call    qword ptr [image.fn10.slot]
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rcx
    mov     [rsp+88h],rsi
    lea     rdx,[k3]
    mov     r11d,0
    cmp     r11,rsi
    jae     L6
    mov     byte ptr [rcx],0
    lea     rax,[k5]
    mov     rcx,[rsp+80h]
    mov     rdi,[rsp+88h]
    mov     r11d,1
    cmp     r11,rdi
    jae     L7
    mov     byte ptr [rcx+1],0
    mov     ecx,2
L0:
    mov     rax,rcx
    mul     rcx
    mov     r8,rax
    jb      L11
    cmp     r12,r8
    jb      L5
    lea     r8,[k9]
    mov     r9,[rsp+80h]
    mov     r13,[rsp+88h]
    cmp     rcx,r13
    jae     L8
    lea     r9,[r9+rcx]
    movzx   r9d,byte ptr [r9]
    test    r9b,r9b
    jne     L2
    jmp     L1
L1:
    mov     r14,rcx
    mov     r15,rbx
    jmp     L4
L2:
    mov     rax,rcx
    mul     rcx
    mov     r9,rax
    jb      L12
    mov     r14,rcx
    mov     r15,rbx
L3:
    cmp     r12,r9
    jb      L4
    lea     r11,[k13]
    mov     [rsp+10h],r11
    mov     rbp,[rsp+80h]
    mov     r11,[rsp+88h]
    mov     [rsp+18h],r11
    cmp     r9,[rsp+18h]
    jae     L9
    lea     rbp,[rbp+r9]
    mov     byte ptr [rbp],0
    mov     rbp,r9
    add     rbp,r14
    jb      L13
    mov     r9,rbp
    jmp     L3
L4:
    add     r14,1
    jb      L14
    mov     rcx,r14
    mov     rbx,r15
    jmp     L0
L5:
    mov     r12,[rsp+78h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+88h]
    mov     [rbx],r12
    mov     [rbx+8],r14
    mov     [rbx+10h],r15
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+68h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+58h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+48h]
    add     rsp,0B8h
    ret
L6:
    mov     edi,0
    call    image.sym15
    ud2
L7:
    mov     rsi,rdi
    mov     edi,1
    mov     rdx,rax
    call    image.sym15
    ud2
L8:
    mov     rdi,rcx
    mov     rsi,r13
    mov     rdx,r8
    call    image.sym15
    ud2
L9:
    mov     rdi,r9
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    image.sym15
    ud2
L10:
    lea     rdi,[k0]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L11:
    lea     rdi,[k7]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L12:
    lea     rdi,[k11]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L13:
    lea     rdi,[k15]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
L14:
    lea     rdi,[k17]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
L15:
    lea     rdi,[rsp+78h]
    call    qword ptr [fn19.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
    call    sym20
    ud2
L16:
    jmp     L15
  ; OSR entries
    lea     r11,[L17]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L17:
    .long   L18
    .long   L19
    .long   L20
    .long   L21
L18:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-180h]
    mov     r11,[rdx-78h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-150h]
    mov     [rsp+10h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-48h],r12
    mov     [rdx-50h],r13
    mov     [rdx-58h],r14
    mov     [rdx-60h],r15
    mov     [rdx-68h],rbp
    mov     rcx,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    lea     rsp,[rsp+0D0h]
    jmp     L0
L19:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-180h]
    mov     r11,[rdx-0D0h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-78h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+18h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-48h],r12
    mov     [rdx-50h],r13
    mov     [rdx-58h],r14
    mov     [rdx-60h],r15
    mov     [rdx-68h],rbp
    mov     r9,[rsp]
    mov     r12,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+0D0h]
    jmp     L3
L20:
    ret
L21:
    ret

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    movzx   eax,byte ptr [rdi]
    ret

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    push    rbx
    sub     rsp,10h
    mov     rbx,rsi
    mov     rsi,rdx
    call    qword ptr [fn0.slot]
    mov     r11,rbx
    add     r11,rax
    mov     rax,r11
    jb      L0
    add     rsp,10h
    pop     rbx
    ret
L0:
    lea     rdi,[image.k472]
    call    image.sym9
    ud2
    mov     ecx,1
    jmp     L4
    mov     ecx,0
    jmp     L4
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L1
L3:
    test    cl,cl
    jne     L2
    jmp     L1
L4:
    jmp     L3
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
    .long   L7
    .long   L8
L6:
    ret
L7:
    ret
L8:
    ret

