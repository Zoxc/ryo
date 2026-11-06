fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    push    rbx
    sub     rsp,10h
    cmp     rdi,rsi
    jne     L0
    mov     rcx,rdx
    jmp     L2
L0:
    cmp     rsi,rdi
    jb      L5
    sub     rsi,rdi
    mov     eax,0
L1:
    movzx   ecx,byte ptr [rdi+rax]
    movzx   ecx,cl
    add     rdx,rcx
    jb      L6
    mov     r11,rax
    add     r11,1
    jb      L7
    add     rax,1
    cmp     rax,rsi
    jne     L4
    mov     rcx,rdx
L2:
    mov     rax,rcx
    add     rsp,10h
    pop     rbx
    ret
L3:
    mov     rdx,rcx
    mov     rdi,r8
    mov     rax,r9
    mov     rsi,rbx
    jmp     L1
L4:
    mov     rcx,rdx
    mov     r8,rdi
    mov     r9,rax
    mov     rbx,rsi
    jmp     L3
L5:
    lea     rdi,[image.k1017]
    lea     rcx,[k1]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym14
    ud2
L6:
    lea     rdi,[image.k376]
    call    image.sym9
    ud2
L7:
    lea     rdi,[image.k1218]
    lea     rcx,[k6]
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym14
    ud2
  ; OSR entries
    lea     r11,[L8]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L8:
    .long   L9
    .long   L10
    .long   L11
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
L9:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     [rdx],rbx
    mov     rdi,[rsp+8]
    mov     rax,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+0E0h]
    jmp     L1
L10:
    ret
L11:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     [rdx],rbx
    mov     rcx,[rsp]
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    lea     rsp,[rsp+0E0h]
    jmp     L3
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    ret
L16:
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
    sub     rsp,0A8h
    mov     [rsp+60h],rbx
    mov     [rsp+58h],r12
    mov     [rsp+50h],r13
    mov     [rsp+48h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,r12
    add     r13,1
    jb      L13
    mov     byte ptr [rsp+27h],1
    lea     rax,[rsp+27h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+3Fh],0
    lea     rdi,[rsp+8]
    mov     rsi,r13
    mov     edx,0
    mov     ecx,1
    mov     r8d,1
    movzx   edx,dl
    call    image.sym7
    mov     rax,[rsp+8]
    test    rax,rax
    jne     L6
    mov     rax,[rsp+10h]
    mov     ecx,[rsp+18h]
    movzx   edx,word ptr [rsp+1Ch]
    movzx   esi,byte ptr [rsp+1Eh]
    movzx   edi,byte ptr [rsp+1Fh]
    cmp     rax,r13
    setb    r8b
    test    r8b,r8b
    jne     L5
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
    mov     [rsp+28h],eax
    mov     [rsp+2Ch],dx
    mov     [rsp+2Eh],sil
    mov     [rsp+2Fh],dil
    mov     [rsp+30h],rcx
    mov     qword ptr [rsp+38h],0
    lea     rdi,[rsp+28h]
    movzx   edx,byte ptr [rsp+27h]
    mov     rsi,r13
    call    image.fn29
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rcx
    mov     [rsp+78h],rsi
    mov     r11d,0
    cmp     r11,rsi
    jae     L9
    mov     byte ptr [rcx],0
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     r11d,1
    cmp     r11,rcx
    jae     L10
    mov     byte ptr [rax+1],0
    mov     edi,2
L0:
    mov     rax,rdi
    mul     rdi
    jb      L14
    cmp     r12,rax
    jb      L4
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rdi,rdx
    jae     L11
    movzx   eax,byte ptr [rax+rdi]
    test    al,al
    jne     L1
    mov     r8,rdi
    mov     r9,rbx
    jmp     L3
L1:
    mov     rax,rdi
    mul     rdi
    jb      L15
    mov     r8,rdi
    mov     r9,rbx
L2:
    cmp     r12,rax
    jb      L3
    mov     r13,[rsp+70h]
    mov     r14,[rsp+78h]
    cmp     rax,r14
    jae     L12
    mov     byte ptr [r13+rax],0
    mov     r13,rax
    add     r13,r8
    jb      L16
    mov     rax,r13
    jmp     L2
L3:
    add     r8,1
    jb      L17
    mov     rdi,r8
    mov     rbx,r9
    jmp     L0
L4:
    mov     r8,[rsp+68h]
    mov     r9,[rsp+70h]
    mov     r12,[rsp+78h]
    mov     [rbx],r8
    mov     [rbx+8],r9
    mov     [rbx+10h],r12
    mov     rax,rbx
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+58h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+48h]
    add     rsp,0A8h
    ret
L5:
    lea     r8,[image.k1590]
    lea     r9,[image.k912]
    mov     rdi,r8
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym14
    ud2
L6:
    mov     r8,[rsp+10h]
    mov     r9d,[rsp+18h]
    movzx   ebx,word ptr [rsp+1Ch]
    movzx   r12d,byte ptr [rsp+1Eh]
    movzx   r13d,byte ptr [rsp+1Fh]
    shl     rbx,20h
    or      r9,rbx
    shl     r12,30h
    or      r9,r12
    shl     r13,38h
    or      r9,r13
    mov     rdi,r8
    mov     rsi,r9
    call    image.sym8
    ud2
L7:
    lea     r8,[rsp+28h]
    mov     rdi,r8
    call    qword ptr [fn19.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
    jmp     L8
    mov     rbx,rax
    jmp     L7
L8:
    call    sym20
    ud2
L9:
    lea     r8,[k3]
    mov     edi,0
    mov     rdx,r8
    call    image.sym15
    ud2
L10:
    lea     rsi,[k5]
    mov     edi,1
    mov     rdx,rsi
    mov     rsi,rcx
    call    image.sym15
    ud2
L11:
    lea     rcx,[k9]
    mov     rsi,rdx
    mov     rdx,rcx
    call    image.sym15
    ud2
L12:
    lea     rdx,[k13]
    mov     rdi,rax
    mov     rsi,r14
    call    image.sym15
    ud2
L13:
    lea     rdi,[k0]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L19
    mov     rbx,rax
    jmp     L19
L14:
    lea     rdi,[k7]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L19
    mov     rbx,rax
    jmp     L19
L15:
    lea     rdi,[k11]
    call    sym8
    ud2
    mov     rbx,rax
    jmp     L19
    mov     rbx,rax
    jmp     L19
L16:
    lea     rdi,[k15]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L19
L17:
    lea     rdi,[k17]
    call    sym1
    ud2
    mov     rbx,rax
    jmp     L19
L18:
    lea     rdi,[rsp+68h]
    call    qword ptr [fn19.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
    call    sym20
    ud2
L19:
    jmp     L18
  ; OSR entries
    lea     r11,[L20]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L20:
    .long   L21
    .long   L22
    .long   L23
    .long   L24
L21:
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
    mov     rdi,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    lea     rsp,[rsp+0E0h]
    jmp     L0
L22:
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
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    lea     rsp,[rsp+0E0h]
    jmp     L2
L23:
    ret
L24:
    ret

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    movzx   eax,byte ptr [rdi]
    ret

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    movzx   eax,byte ptr [rdx]
    mov     r11,rsi
    add     r11,rax
    mov     rax,r11
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rdi,[image.k376]
    call    image.sym9
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
    .long   L3
L2:
    ret
L3:
    ret

fn std::vec::Vec::<bool>::extend_with
    sub     rsp,48h
    mov     [rsp+20h],rbx
    mov     [rsp+18h],r12
    mov     [rsp+10h],r13
    mov     [rsp+8],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+2Fh],dl
    mov     rsi,[rbx+10h]
    mov     rax,[rbx]
    sub     rax,rsi
    cmp     rax,r12
    jae     L0
    mov     rdi,rbx
    mov     rdx,r12
    mov     ecx,1
    mov     r8d,1
    call    image.sym13
L0:
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    lea     rax,[rax+rcx]
    lea     rbx,[rbx+10h]
    mov     rdx,rax
    mov     eax,1
    mov     rsi,rcx
    mov     rcx,r12
L1:
    cmp     rax,r12
    jae     L6
    add     rax,1
    movzx   edi,byte ptr [rsp+2Fh]
    mov     r8,rax
    mov     rax,rdx
    mov     r9,rcx
    mov     r13,rsi
    mov     r14,rbx
L2:
    mov     [rax],dil
    lea     rax,[rax+1]
    add     r13,1
    mov     rcx,r9
    mov     rdx,rax
    mov     rax,r8
    mov     rsi,r13
    mov     rbx,r14
    jmp     L1
L3:
    movzx   eax,byte ptr [rsp+2Fh]
    mov     [rdx],al
    lea     rax,[rsi+1]
    mov     [rbx],rax
    jmp     L5
L4:
    mov     [rbx],rsi
L5:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+8]
    add     rsp,48h
    ret
L6:
    test    rcx,rcx
    ja      L3
    jmp     L4
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
    .long   L9
    .long   L10
    .long   L11
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
L8:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+28h],r11
    mov     [rdx-20h],rbx
    mov     [rdx-28h],r12
    mov     [rdx-30h],r13
    mov     [rdx-38h],r14
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rbx,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+90h]
    jmp     L1
L9:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-80h]
    mov     [rsp],r11
    movzx   r11d,byte ptr [rdx-81h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+30h],r11
    mov     [rdx-20h],rbx
    mov     [rdx-28h],r12
    mov     [rdx-30h],r13
    mov     [rdx-38h],r14
    mov     rax,[rsp]
    mov     rdi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     r13,[rsp+28h]
    mov     r14,[rsp+30h]
    lea     rsp,[rsp+0A0h]
    jmp     L2
L10:
    ret
L11:
    ret
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    ret
L16:
    ret

