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
    sub     rsp,0D8h
    mov     [rsp+90h],rbx
    mov     [rsp+88h],r12
    mov     [rsp+80h],r13
    mov     [rsp+78h],r14
    mov     [rsp+70h],r15
    mov     [rsp+68h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,r12
    add     r13,1
    jb      L15
    mov     byte ptr [rsp+47h],1
    lea     rax,[rsp+47h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+5Fh],0
    lea     rdi,[rsp+28h]
    mov     rsi,r13
    mov     edx,0
    mov     ecx,1
    mov     r8d,1
    movzx   edx,dl
    call    image.sym7
    mov     rax,[rsp+28h]
    test    rax,rax
    jne     L7
    mov     rax,[rsp+30h]
    mov     ecx,[rsp+38h]
    movzx   edx,word ptr [rsp+3Ch]
    movzx   esi,byte ptr [rsp+3Eh]
    movzx   edi,byte ptr [rsp+3Fh]
    cmp     rax,r13
    setb    r8b
    lea     r11,[image.k1008]
    mov     [rsp+20h],r11
    test    r8b,r8b
    jne     L6
    shl     rdx,20h
    or      rcx,rdx
    shl     rsi,30h
    or      rcx,rsi
    shl     rdi,38h
    or      rcx,rdi
    mov     rdx,rax
    shr     rdx,20h
    mov     rsi,rax
    shr     rsi,30h
    mov     rdi,rax
    shr     rdi,38h
    mov     [rsp+48h],eax
    mov     [rsp+4Ch],dx
    mov     [rsp+4Eh],sil
    mov     [rsp+4Fh],dil
    mov     [rsp+50h],rcx
    mov     qword ptr [rsp+58h],0
    lea     rdi,[rsp+48h]
    movzx   edx,byte ptr [rsp+47h]
    mov     rsi,r13
    call    qword ptr [image.fn29.slot]
    mov     rax,[rsp+48h]
    mov     rcx,rax
    shr     rcx,20h
    mov     rdx,rax
    shr     rdx,30h
    mov     rsi,rax
    shr     rsi,38h
    mov     rdi,[rsp+50h]
    mov     r8,[rsp+58h]
    mov     eax,eax
    movzx   ecx,cx
    shl     rcx,20h
    or      rax,rcx
    movzx   edx,dl
    shl     rdx,30h
    or      rax,rdx
    movzx   esi,sil
    shl     rsi,38h
    or      rax,rsi
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],r8
    lea     r11,[k3]
    mov     [rsp+18h],r11
    mov     r11d,0
    cmp     r11,r8
    jae     L11
    mov     byte ptr [rdi],0
    lea     r11,[k5]
    mov     [rsp+10h],r11
    mov     rcx,[rsp+0A0h]
    mov     rsi,[rsp+0A8h]
    mov     r11d,1
    cmp     r11,rsi
    jae     L12
    mov     byte ptr [rcx+1],0
    mov     edi,2
L0:
    mov     rax,rdi
    mul     rdi
    mov     rcx,rax
    jb      L16
    cmp     r12,rcx
    jb      L5
    lea     rcx,[k9]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+0A8h]
    cmp     rdi,r14
    jae     L13
    lea     r13,[r13+rdi]
    movzx   r13d,byte ptr [r13]
    test    r13b,r13b
    jne     L2
    jmp     L1
L1:
    mov     r15,rdi
    mov     rbp,rbx
    jmp     L4
L2:
    mov     rax,rdi
    mul     rdi
    mov     r13,rax
    jb      L17
    mov     r15,rdi
    mov     rbp,rbx
L3:
    cmp     r12,r13
    jb      L4
    lea     rax,[k13]
    mov     rdx,[rsp+0A0h]
    mov     r9,[rsp+0A8h]
    cmp     r13,r9
    jae     L14
    lea     rdx,[rdx+r13]
    mov     byte ptr [rdx],0
    mov     rdx,r13
    add     rdx,r15
    jb      L18
    mov     r13,rdx
    jmp     L3
L4:
    add     r15,1
    jb      L19
    mov     rdi,r15
    mov     rbx,rbp
    jmp     L0
L5:
    mov     rdx,[rsp+98h]
    mov     r12,[rsp+0A0h]
    mov     r15,[rsp+0A8h]
    mov     [rbx],rdx
    mov     [rbx+8],r12
    mov     [rbx+10h],r15
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+88h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+78h]
    mov     r15,[rsp+70h]
    mov     rbp,[rsp+68h]
    add     rsp,0D8h
    ret
L6:
    lea     rdx,[image.k1605]
    mov     rdi,rdx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+20h]
    movzx   edx,dl
    call    image.sym14
    ud2
L7:
    mov     rdx,[rsp+30h]
    mov     ebx,[rsp+38h]
    movzx   r12d,word ptr [rsp+3Ch]
    movzx   r15d,byte ptr [rsp+3Eh]
    movzx   ebp,byte ptr [rsp+3Fh]
    shl     r12,20h
    or      rbx,r12
    shl     r15,30h
    or      rbx,r15
    shl     rbp,38h
    or      rbx,rbp
    mov     rdi,rdx
    mov     rsi,rbx
    call    image.sym8
    ud2
    mov     rdx,rax
    jmp     L9
L8:
    lea     rdx,[rsp+48h]
    mov     rdi,rdx
    call    qword ptr [fn19.slot]
    mov     rdx,rbx
    jmp     L9
    jmp     L10
L9:
    mov     [rsp],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L8
L10:
    call    sym20
    ud2
L11:
    mov     edi,0
    mov     rsi,r8
    mov     rdx,[rsp+18h]
    call    image.sym15
    ud2
L12:
    mov     edi,1
    mov     rdx,[rsp+10h]
    call    image.sym15
    ud2
L13:
    mov     rsi,r14
    mov     rdx,rcx
    call    image.sym15
    ud2
L14:
    mov     rdi,r13
    mov     rsi,r9
    mov     rdx,rax
    call    image.sym15
    ud2
L15:
    lea     rdi,[k0]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L21
    mov     rbx,rax
    jmp     L21
L16:
    lea     rdi,[k7]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L21
    mov     rbx,rax
    jmp     L21
L17:
    lea     rdi,[k11]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L21
    mov     rbx,rax
    jmp     L21
L18:
    lea     rdi,[k15]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L21
L19:
    lea     rdi,[k17]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L21
L20:
    lea     rdi,[rsp+98h]
    call    qword ptr [fn19.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
    call    sym20
    ud2
L21:
    jmp     L20
  ; OSR entries
    lea     r11,[L22]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L22:
    .long   L23
    .long   L24
    .long   L25
    .long   L26
L23:
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
    mov     rdi,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    lea     rsp,[rsp+0B0h]
    jmp     L0
L24:
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
    mov     r13,[rsp]
    mov     r12,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+0B0h]
    jmp     L3
L25:
    ret
L26:
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

