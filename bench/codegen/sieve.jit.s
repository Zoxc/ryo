fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,18h
    movzx   eax,byte ptr [rsi]
    movzx   eax,al
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
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     [rsp+10h],rdx
    cmp     rdi,rsi
    jne     L0
    mov     rax,[rsp+10h]
    mov     r9,rax
    jmp     L3
L0:
    mov     rax,[rsp+10h]
    lea     rcx,[k1]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    jmp     L4
L1:
    lea     r8,[rsp+10h]
    lea     r9,[rbx+r12]
    mov     rdi,r8
    mov     rsi,rdx
    mov     rdx,r9
    call    fn0
    mov     rdx,rax
    lea     r8,[k6]
    mov     r11,r12
    add     r11,1
    jb      L7
    add     r12,1
    cmp     r12,r13
    jne     L5
    mov     r9,rdx
    jmp     L3
L2:
    mov     rdx,r9
    mov     rbx,r14
    mov     r12,r15
    mov     r13,rbp
    jmp     L1
L3:
    mov     rax,r9
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L4:
    mov     rdx,rax
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
    jmp     L1
L5:
    mov     r9,rdx
    mov     r14,rbx
    mov     r15,r12
    mov     rbp,r13
    jmp     L2
L6:
    lea     rax,[image.k1032]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym14
    ud2
L7:
    lea     rax,[image.k1233]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym14
    ud2
    jmp     L9
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
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
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-70h],r11
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+80h]
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
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-70h],r11
    mov     r9,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+80h]
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
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,175h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    sym2
    ud2

fn sieve
    sub     rsp,0B8h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,r12
    add     rax,1
    jb      L10
    lea     rcx,[rsp+78h]
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    movzx   esi,sil
    call    qword ptr [fn2.slot]
    lea     rax,[k3]
    mov     rcx,[rsp+80h]
    mov     rdx,[rsp+88h]
    mov     r11d,0
    cmp     r11,rdx
    jae     L6
    mov     byte ptr [rcx],0
    lea     rcx,[k5]
    mov     rsi,[rsp+80h]
    mov     rdi,[rsp+88h]
    mov     r11d,1
    cmp     r11,rdi
    jae     L7
    mov     byte ptr [rsi+1],0
    mov     esi,2
L0:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rsi
    mul     rsi
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L11
    cmp     r12,r8
    jb      L5
    lea     r8,[k9]
    mov     r9,[rsp+80h]
    mov     r13,[rsp+88h]
    cmp     rsi,r13
    jae     L8
    lea     r9,[r9+rsi]
    movzx   r9d,byte ptr [r9]
    test    r9b,r9b
    jne     L2
    jmp     L1
L1:
    mov     r14,rsi
    mov     r15,rbx
    jmp     L4
L2:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rsi
    mul     rsi
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L12
    mov     r14,rsi
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
    mov     rsi,r14
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
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,0B8h
    ret
L6:
    mov     edi,0
    mov     rsi,rdx
    mov     rdx,rax
    call    image.sym15
    ud2
L7:
    mov     rsi,rdi
    mov     edi,1
    mov     rdx,rcx
    call    image.sym15
    ud2
L8:
    mov     rdi,rsi
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
    lea     rax,[k0]
    mov     rdi,rax
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L11:
    lea     rax,[k7]
    mov     rdi,rax
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L12:
    lea     rax,[k11]
    mov     rdi,rax
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L16
    mov     rbx,rax
    jmp     L16
L13:
    lea     rax,[k15]
    mov     rdi,rax
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
L14:
    lea     rax,[k17]
    mov     rdi,rax
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L16
L15:
    lea     rax,[rsp+78h]
    mov     rdi,rax
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
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
    mov     rsi,[rsp]
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
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
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
    sub     rsp,18h
    movzx   eax,byte ptr [rdi]
    movzx   eax,al
    add     rsp,18h
    ret

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rsi
    mov     rsi,rdx
    call    qword ptr [fn0.slot]
    add     rbx,rax
    jb      L0
    mov     rax,rbx
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L0:
    lea     rax,[image.k472]
    mov     rdi,rax
    call    image.sym9
    ud2
    mov     ecx,1
    jmp     L4
    mov     ecx,0
    jmp     L4
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
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

