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
    sete    al
    test    al,al
    je      L0
    mov     rax,[rsp+10h]
    mov     rdx,rax
    jmp     L4
L0:
    mov     rax,[rsp+10h]
    jmp     L6
L1:
    lea     rdx,[rsp+10h]
    lea     r8,[rbx+r12]
    mov     rdi,rdx
    mov     rsi,rcx
    mov     rdx,r8
    call    fn0
    mov     rcx,rax
    jmp     L7
L2:
    mov     rdx,rcx
    jmp     L4
L3:
    mov     rcx,rdx
    mov     rbx,r8
    mov     r12,r9
    mov     r13,r15
    mov     r14,rbp
    jmp     L1
L4:
    mov     rax,rdx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L5:
    mov     rcx,rax
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rdx
    mov     r14d,0
    jmp     L1
L6:
    lea     r8,[k1]
    cmp     rsi,rdi
    jb      L8
    mov     rdx,rsi
    sub     rdx,rdi
    jmp     L5
L7:
    lea     rax,[k6]
    mov     r11,r12
    add     r11,1
    jb      L9
    add     r12,1
    cmp     r12,r13
    je      L2
    mov     rdx,rcx
    mov     r8,rbx
    mov     r9,r12
    mov     r15,r13
    mov     rbp,r14
    jmp     L3
L8:
    lea     rcx,[image.k1032]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    qword ptr [image.sym14]
    ud2
L9:
    lea     rcx,[image.k1233]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym14]
    ud2
    mov     ecx,0
    jmp     L16
L10:
    jmp     L15
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
L12:
    jmp     L10
L13:
    test    cl,cl
    jne     L12
    jmp     L10
L14:
    jmp     L11
L15:
    test    r14b,r14b
    jne     L14
    jmp     L11
L16:
    jmp     L13
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
    .long   L22
    .long   L23
    .long   L24
    .long   L25
    .long   L26
L18:
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
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-70h],r11
    mov     rcx,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L1
L19:
    ret
L20:
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
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-70h],r11
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+80h]
    jmp     L3
L21:
    ret
L22:
    ret
L23:
    ret
L24:
    ret
L25:
    ret
L26:
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
    call    qword ptr [image.sym15]
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
    call    qword ptr [sym2]
    ud2

fn sieve
    sub     rsp,0D8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,r12
    add     rax,1
    jb      L12
    lea     rcx,[rsp+98h]
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    movzx   esi,sil
    call    qword ptr [fn2.slot]
    lea     rax,[k3]
    mov     rcx,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     r11d,0
    cmp     r11,rdx
    jae     L8
    mov     byte ptr [rcx],0
    lea     rcx,[k5]
    mov     rsi,[rsp+0A0h]
    mov     rdi,[rsp+0A8h]
    mov     r11d,1
    cmp     r11,rdi
    jae     L9
    lea     rsi,[rsi+1]
    mov     byte ptr [rsi],0
    mov     esi,2
L0:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rsi
    mul     rsi
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L13
    cmp     r12,r8
    jb      L7
    lea     r8,[k9]
    mov     r9,[rsp+0A0h]
    mov     r13,[rsp+0A8h]
    cmp     rsi,r13
    jae     L10
    lea     r9,[r9+rsi]
    movzx   r9d,byte ptr [r9]
    test    r9b,r9b
    jne     L2
    jmp     L1
L1:
    mov     r14,r12
    mov     r12,rsi
    mov     r15,rbx
    jmp     L6
L2:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rsi
    mul     rsi
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L15
    mov     r14,rsi
    mov     r15,rbx
L3:
    cmp     r12,r9
    jb      L4
    jmp     L5
L4:
    mov     r10,r12
    mov     r12,r14
    mov     r14,r10
    jmp     L6
L5:
    lea     r11,[k13]
    mov     [rsp+10h],r11
    mov     rbp,[rsp+0A0h]
    mov     r11,[rsp+0A8h]
    mov     [rsp+18h],r11
    cmp     r9,[rsp+18h]
    jae     L11
    lea     rbp,[rbp+r9]
    mov     byte ptr [rbp],0
    mov     rbp,r9
    add     rbp,r14
    jb      L17
    mov     r9,rbp
    jmp     L3
L6:
    add     r12,1
    jb      L19
    mov     rsi,r12
    mov     r12,r14
    mov     rbx,r15
    jmp     L0
L7:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFFC8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0
    mov     ecx,0FFFFFF58h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0D8h
    ret
L8:
    mov     edi,0
    mov     rsi,rdx
    mov     rdx,rax
    call    qword ptr [image.sym15]
    ud2
L9:
    mov     rsi,rdi
    mov     edi,1
    mov     rdx,rcx
    call    qword ptr [image.sym15]
    ud2
L10:
    mov     rdi,rsi
    mov     rsi,r13
    mov     rdx,r8
    call    qword ptr [image.sym15]
    ud2
L11:
    mov     rdi,r9
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    qword ptr [image.sym15]
    ud2
L12:
    lea     rax,[k0]
    mov     rdi,rax
    call    qword ptr [sym1]
    ud2
    mov     rbx,rax
    jmp     L24
    mov     rbx,rax
    jmp     L24
L13:
    lea     rax,[k7]
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L14
    mov     rbx,rax
    jmp     L24
L14:
    ud2
    mov     rbx,rax
    jmp     L24
L15:
    lea     rax,[k11]
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L16
    mov     rbx,rax
    jmp     L24
L16:
    ud2
    mov     rbx,rax
    jmp     L24
L17:
    lea     rax,[k15]
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L18
    mov     rbx,rax
    jmp     L24
L18:
    ud2
L19:
    lea     rax,[k17]
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L20
    mov     rbx,rax
    jmp     L24
L20:
    ud2
L21:
    lea     rax,[rsp+98h]
    mov     rdi,rax
    call    qword ptr [fn19.slot]
    jmp     L22
    jmp     L23
L22:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L23:
    call    qword ptr [sym20]
    ud2
L24:
    jmp     L21
  ; OSR entries
    lea     r11,[L25]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L25:
    .long   L26
    .long   L27
    .long   L28
    .long   L29
L26:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-190h]
    mov     r11,[rdx-78h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-150h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-8]
    mov     [rsp+28h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-98h],r11
    mov     rsi,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    lea     rsp,[rsp+0C0h]
    jmp     L0
L27:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-1A0h]
    mov     r11,[rdx-0D0h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-78h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-8]
    mov     [rsp+30h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-98h],r11
    mov     r9,[rsp]
    mov     r12,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+0D0h]
    jmp     L3
L28:
    ret
L29:
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
    call    qword ptr [image.sym9]
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

