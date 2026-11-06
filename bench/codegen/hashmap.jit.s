fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+18h]
    mov     r8,[rdi+30h]
    and     r8,0FFh
    shl     r8,38h
    mov     rdi,[rdi+38h]
    or      r8,rdi
    xor     rsi,r8
    add     rax,rdx
    add     rcx,rsi
    mov     rdi,rdx
    shl     rdi,0Dh
    shr     rdx,33h
    or      rdi,rdx
    xor     rdi,rax
    mov     rdx,rsi
    shl     rdx,10h
    shr     rsi,30h
    or      rdx,rsi
    xor     rdx,rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    add     rcx,rdi
    add     rsi,rdx
    mov     rax,rdi
    shl     rax,11h
    shr     rdi,2Fh
    or      rax,rdi
    xor     rax,rcx
    mov     rdi,rdx
    shl     rdi,15h
    shr     rdx,2Bh
    or      rdi,rdx
    xor     rdi,rsi
    mov     rdx,rcx
    shl     rdx,20h
    shr     rcx,20h
    or      rdx,rcx
    xor     rsi,r8
    xor     rdx,0FFh
    add     rsi,rax
    add     rdx,rdi
    mov     rcx,rax
    shl     rcx,0Dh
    shr     rax,33h
    or      rcx,rax
    xor     rcx,rsi
    mov     rax,rdi
    shl     rax,10h
    shr     rdi,30h
    or      rax,rdi
    xor     rax,rdx
    mov     rdi,rsi
    shl     rdi,20h
    shr     rsi,20h
    or      rdi,rsi
    add     rdx,rcx
    add     rdi,rax
    mov     rsi,rcx
    shl     rsi,11h
    shr     rcx,2Fh
    or      rsi,rcx
    xor     rsi,rdx
    mov     rcx,rax
    shl     rcx,15h
    shr     rax,2Bh
    or      rcx,rax
    xor     rcx,rdi
    mov     rax,rdx
    shl     rax,20h
    shr     rdx,20h
    or      rax,rdx
    add     rdi,rsi
    add     rax,rcx
    mov     rdx,rsi
    shl     rdx,0Dh
    shr     rsi,33h
    or      rdx,rsi
    xor     rdx,rdi
    mov     rsi,rcx
    shl     rsi,10h
    shr     rcx,30h
    or      rsi,rcx
    xor     rsi,rax
    mov     rcx,rdi
    shl     rcx,20h
    shr     rdi,20h
    or      rcx,rdi
    add     rax,rdx
    add     rcx,rsi
    mov     rdi,rdx
    shl     rdi,11h
    shr     rdx,2Fh
    or      rdi,rdx
    xor     rdi,rax
    mov     rdx,rsi
    shl     rdx,15h
    shr     rsi,2Bh
    or      rdx,rsi
    xor     rdx,rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    add     rcx,rdi
    add     rsi,rdx
    mov     rax,rdi
    shl     rax,0Dh
    shr     rdi,33h
    or      rax,rdi
    xor     rax,rcx
    mov     rdi,rdx
    shl     rdi,10h
    shr     rdx,30h
    or      rdi,rdx
    xor     rdi,rsi
    mov     rdx,rcx
    shl     rdx,20h
    shr     rcx,20h
    or      rdx,rcx
    add     rsi,rax
    add     rdx,rdi
    mov     rcx,rax
    shl     rcx,11h
    shr     rax,2Fh
    or      rcx,rax
    xor     rcx,rsi
    mov     rax,rdi
    shl     rax,15h
    shr     rdi,2Bh
    or      rax,rdi
    xor     rax,rdx
    mov     rdi,rsi
    shl     rdi,20h
    shr     rsi,20h
    or      rdi,rsi
    xor     rdx,rcx
    xor     rdx,rdi
    xor     rax,rdx
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     rax,[rbx+30h]
    add     rax,r13
    mov     [rbx+30h],rax
    mov     rax,[rbx+40h]
    test    rax,rax
    jne     L0
    mov     r14d,0
    jmp     L8
L0:
    mov     r14d,8
    sub     r14,rax
    cmp     r14,r13
    jae     L1
    mov     rax,r14
    jmp     L2
L1:
    mov     rax,r13
L2:
    mov     r11d,3
    cmp     r11,rax
    jb      L3
    mov     edx,0
    mov     esi,0
    jmp     L4
L3:
    test    r12,r12
    je      L17
    mov     edx,[r12]
    mov     rsi,rdx
    mov     edx,4
L4:
    lea     rdi,[rdx+1]
    cmp     rdi,rax
    jae     L5
    lea     rdi,[r12+rdx]
    test    rdi,rdi
    je      L18
    movzx   edi,word ptr [rdi]
    mov     rcx,rdx
    imul    rcx,8
    shl     rdi,cl
    or      rsi,rdi
    add     rdx,2
L5:
    cmp     rdx,rax
    jae     L6
    cmp     rdx,r13
    jae     L19
    movzx   eax,byte ptr [r12+rdx]
    movzx   eax,al
    mov     rcx,rdx
    imul    rcx,8
    shl     rax,cl
    or      rsi,rax
L6:
    mov     rax,[rbx+40h]
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    mov     rdx,[rbx+38h]
    or      rdx,rsi
    mov     [rbx+38h],rdx
    cmp     r13,r14
    jae     L7
    add     rax,r13
    mov     [rbx+40h],rax
    jmp     L16
L7:
    mov     rax,[rbx+18h]
    xor     rax,rdx
    mov     [rbx+18h],rax
    mov     rdi,rbx
    call    fn1
    mov     rax,[rbx+38h]
    mov     rdx,[rbx]
    xor     rdx,rax
    mov     [rbx],rdx
    mov     qword ptr [rbx+40h],0
L8:
    mov     rax,r13
    sub     rax,r14
    mov     rdx,rax
    and     rdx,7
    mov     [rsp+10h],r13
    mov     r13,r12
    mov     r12,rdx
    mov     rbp,rbx
    mov     rbx,rax
L9:
    mov     rax,rbx
    sub     rax,r12
    cmp     r14,rax
    jae     L11
    lea     rax,[r13+r14]
    test    rax,rax
    je      L20
    mov     r15,[rax]
    mov     rax,[rbp+18h]
    xor     rax,r15
    mov     [rbp+18h],rax
    mov     rdi,rbp
    call    fn1
    mov     rax,rbp
    mov     rdx,r14
    mov     rsi,r12
    mov     rdi,r13
    mov     r8,[rsp+10h]
L10:
    mov     r9,[rax]
    xor     r9,r15
    mov     [rax],r9
    add     rdx,8
    mov     r14,rdx
    mov     r12,rsi
    mov     r13,rdi
    mov     [rsp+10h],r8
    mov     rbp,rax
    jmp     L9
L11:
    mov     r11d,3
    cmp     r11,r12
    jb      L12
    mov     eax,0
    mov     edx,0
    jmp     L13
L12:
    lea     rax,[r13+r14]
    test    rax,rax
    je      L21
    mov     eax,[rax]
    mov     rdx,rax
    mov     eax,4
L13:
    lea     rsi,[rax+1]
    cmp     rsi,r12
    jae     L14
    lea     rsi,[r14+rax]
    lea     rsi,[r13+rsi]
    test    rsi,rsi
    je      L22
    movzx   esi,word ptr [rsi]
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
    add     rax,2
L14:
    cmp     rax,r12
    jae     L15
    add     r14,rax
    cmp     r14,[rsp+10h]
    jae     L23
    movzx   esi,byte ptr [r13+r14]
    movzx   esi,sil
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
L15:
    mov     [rbp+38h],rdx
    mov     [rbp+40h],r12
L16:
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L17:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L18:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L19:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L20:
    lea     rdi,[image.k3619]
    lea     rcx,[k4]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L21:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L22:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L23:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L24]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L24:
    .long   L25
    .long   L26
    .long   L27
L25:
    ret
L26:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-8]
    mov     [rsp+28h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-30h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+90h]
    jmp     L9
L27:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-8]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-20h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+30h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     rax,[rsp]
    mov     r15,[rsp+8]
    mov     rbx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+0A0h]
    jmp     L10

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
    mov     rax,[rdi]
    mov     rcx,[rdi+10h]
    add     rax,rcx
    mov     [rdi],rax
    mov     rdx,[rdi+8]
    mov     rsi,[rdi+18h]
    add     rdx,rsi
    mov     [rdi+8],rdx
    mov     r8,rcx
    shl     r8,0Dh
    shr     rcx,33h
    or      r8,rcx
    mov     [rdi+10h],r8
    xor     r8,rax
    mov     [rdi+10h],r8
    mov     rcx,rsi
    shl     rcx,10h
    shr     rsi,30h
    or      rcx,rsi
    mov     [rdi+18h],rcx
    xor     rcx,rdx
    mov     [rdi+18h],rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    mov     [rdi],rsi
    add     rdx,r8
    mov     [rdi+8],rdx
    add     rsi,rcx
    mov     [rdi],rsi
    mov     rax,r8
    shl     rax,11h
    shr     r8,2Fh
    or      rax,r8
    mov     [rdi+10h],rax
    xor     rax,rdx
    mov     [rdi+10h],rax
    mov     rax,rcx
    shl     rax,15h
    shr     rcx,2Bh
    or      rax,rcx
    mov     [rdi+18h],rax
    xor     rax,rsi
    mov     [rdi+18h],rax
    mov     rax,rdx
    shl     rax,20h
    shr     rdx,20h
    or      rax,rdx
    mov     [rdi+8],rax
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
    mov     rax,[rdi]
    mov     rcx,[rdi+10h]
    add     rax,rcx
    mov     [rdi],rax
    mov     rdx,[rdi+8]
    mov     rsi,[rdi+18h]
    add     rdx,rsi
    mov     [rdi+8],rdx
    mov     r8,rcx
    shl     r8,0Dh
    shr     rcx,33h
    or      r8,rcx
    mov     [rdi+10h],r8
    xor     r8,rax
    mov     [rdi+10h],r8
    mov     rcx,rsi
    shl     rcx,10h
    shr     rsi,30h
    or      rcx,rsi
    mov     [rdi+18h],rcx
    xor     rcx,rdx
    mov     [rdi+18h],rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    mov     [rdi],rsi
    add     rdx,r8
    mov     [rdi+8],rdx
    add     rsi,rcx
    mov     [rdi],rsi
    mov     rax,r8
    shl     rax,11h
    shr     r8,2Fh
    or      rax,r8
    mov     [rdi+10h],rax
    xor     rax,rdx
    mov     [rdi+10h],rax
    mov     r8,rcx
    shl     r8,15h
    shr     rcx,2Bh
    or      r8,rcx
    mov     [rdi+18h],r8
    xor     r8,rsi
    mov     [rdi+18h],r8
    mov     rcx,rdx
    shl     rcx,20h
    shr     rdx,20h
    or      rcx,rdx
    mov     [rdi+8],rcx
    add     rsi,rax
    mov     [rdi],rsi
    add     rcx,r8
    mov     [rdi+8],rcx
    mov     rdx,rax
    shl     rdx,0Dh
    shr     rax,33h
    or      rdx,rax
    mov     [rdi+10h],rdx
    xor     rdx,rsi
    mov     [rdi+10h],rdx
    mov     rax,r8
    shl     rax,10h
    shr     r8,30h
    or      rax,r8
    mov     [rdi+18h],rax
    xor     rax,rcx
    mov     [rdi+18h],rax
    mov     r8,rsi
    shl     r8,20h
    shr     rsi,20h
    or      r8,rsi
    mov     [rdi],r8
    add     rcx,rdx
    mov     [rdi+8],rcx
    add     r8,rax
    mov     [rdi],r8
    mov     rsi,rdx
    shl     rsi,11h
    shr     rdx,2Fh
    or      rsi,rdx
    mov     [rdi+10h],rsi
    xor     rsi,rcx
    mov     [rdi+10h],rsi
    mov     rdx,rax
    shl     rdx,15h
    shr     rax,2Bh
    or      rdx,rax
    mov     [rdi+18h],rdx
    xor     rdx,r8
    mov     [rdi+18h],rdx
    mov     rax,rcx
    shl     rax,20h
    shr     rcx,20h
    or      rax,rcx
    mov     [rdi+8],rax
    add     r8,rsi
    mov     [rdi],r8
    add     rax,rdx
    mov     [rdi+8],rax
    mov     rcx,rsi
    shl     rcx,0Dh
    shr     rsi,33h
    or      rcx,rsi
    mov     [rdi+10h],rcx
    xor     rcx,r8
    mov     [rdi+10h],rcx
    mov     rsi,rdx
    shl     rsi,10h
    shr     rdx,30h
    or      rsi,rdx
    mov     [rdi+18h],rsi
    xor     rsi,rax
    mov     [rdi+18h],rsi
    mov     rdx,r8
    shl     rdx,20h
    shr     r8,20h
    or      rdx,r8
    mov     [rdi],rdx
    add     rax,rcx
    mov     [rdi+8],rax
    add     rdx,rsi
    mov     [rdi],rdx
    mov     r8,rcx
    shl     r8,11h
    shr     rcx,2Fh
    or      r8,rcx
    mov     [rdi+10h],r8
    xor     r8,rax
    mov     [rdi+10h],r8
    mov     rcx,rsi
    shl     rcx,15h
    shr     rsi,2Bh
    or      rcx,rsi
    mov     [rdi+18h],rcx
    xor     rcx,rdx
    mov     [rdi+18h],rcx
    mov     rcx,rax
    shl     rcx,20h
    shr     rax,20h
    or      rcx,rax
    mov     [rdi+8],rcx
    ret

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    jmp     L2
L0:
    add     rsp,18h
    ret
L1:
    mov     rcx,[rdx-8]
    lea     rax,[rsi+rcx]
    jmp     L0
L2:
    jmp     L1
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
    .long   L6
L4:
    ret
L5:
    ret
L6:
    ret

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::build_hasher
    mov     r10,736F6D6570736575h
    mov     [rdi],r10
    mov     r10,6C7967656E657261h
    mov     [rdi+8],r10
    mov     r10,646F72616E646F6Dh
    mov     [rdi+10h],r10
    mov     r10,7465646279746573h
    mov     [rdi+18h],r10
    mov     qword ptr [rdi+20h],0
    mov     qword ptr [rdi+28h],0
    mov     qword ptr [rdi+30h],0
    mov     qword ptr [rdi+38h],0
    mov     qword ptr [rdi+40h],0
    mov     rax,rdi
    ret

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::hash_one::<&std::string::String>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,80h
    mov     r10,736F6D6570736575h
    mov     [rsp+38h],r10
    mov     r10,6C7967656E657261h
    mov     [rsp+40h],r10
    mov     r10,646F72616E646F6Dh
    mov     [rsp+48h],r10
    mov     r10,7465646279746573h
    mov     [rsp+50h],r10
    mov     qword ptr [rsp+58h],0
    mov     qword ptr [rsp+60h],0
    mov     qword ptr [rsp+68h],0
    mov     qword ptr [rsp+70h],0
    mov     qword ptr [rsp+78h],0
    mov     rbx,[rsi+8]
    mov     r12,[rsi+10h]
    mov     [rsp+68h],r12
    mov     r13,r12
    and     r13,7
    mov     r14d,0
L0:
    mov     [rsp+10h],r14
    mov     rax,r12
    sub     rax,r13
    cmp     r14,rax
    jae     L1
    mov     qword ptr [rsp+10h],0
    lea     r15,[rbx+r14]
    mov     rdi,r15
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L8
    test    r15,r15
    je      L8
    lea     rdi,[rsp+10h]
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L8
    lea     rsi,[rsp+10h]
    mov     rdi,r15
    mov     edx,1
    mov     ecx,8
    call    image.fn152
    test    al,al
    je      L8
    mov     r15,[r15]
    mov     [rsp+10h],r15
    mov     rax,[rsp+50h]
    xor     rax,r15
    mov     [rsp+50h],rax
    lea     rdi,[rsp+38h]
    mov     [rsp+10h],rdi
    call    image.fn187
    mov     rax,[rsp+38h]
    xor     rax,r15
    mov     [rsp+38h],rax
    lea     rax,[r14+8]
    mov     r14,rax
    jmp     L0
L1:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r13
    call    image.fn132
    mov     [rsp+70h],rax
    mov     [rsp+78h],r13
    mov     byte ptr [rsp+2Fh],0FFh
    mov     rax,[rsp+68h]
    add     rax,1
    mov     [rsp+68h],rax
    test    r13,r13
    jne     L2
    mov     ebx,0
    jmp     L4
L2:
    mov     ebx,8
    sub     rbx,r13
    mov     [rsp+20h],rbx
    mov     ecx,1
    lea     rdi,[rsp+2Fh]
    mov     esi,1
    mov     edx,0
    call    image.fn132
    mov     rdx,[rsp+78h]
    mov     [rsp+20h],rdx
    mov     rcx,rdx
    imul    rcx,8
    shl     rax,cl
    mov     rsi,[rsp+70h]
    or      rsi,rax
    mov     [rsp+70h],rsi
    mov     r11d,1
    cmp     r11,rbx
    jae     L3
    add     rdx,1
    mov     [rsp+78h],rdx
    jmp     L7
L3:
    mov     rax,[rsp+50h]
    xor     rax,rsi
    mov     [rsp+50h],rax
    mov     rdx,[rsp+38h]
    mov     rdi,[rsp+48h]
    add     rdx,rdi
    mov     [rsp+38h],rdx
    mov     r8,[rsp+40h]
    add     r8,rax
    mov     [rsp+40h],r8
    mov     r9,rdi
    shl     r9,0Dh
    shr     rdi,33h
    or      r9,rdi
    mov     [rsp+48h],r9
    xor     r9,rdx
    mov     [rsp+48h],r9
    mov     rdi,rax
    shl     rdi,10h
    shr     rax,30h
    or      rdi,rax
    mov     [rsp+50h],rdi
    xor     rdi,r8
    mov     [rsp+50h],rdi
    mov     rax,rdx
    shl     rax,20h
    shr     rdx,20h
    or      rax,rdx
    mov     [rsp+38h],rax
    add     r8,r9
    mov     [rsp+40h],r8
    add     rax,rdi
    mov     [rsp+38h],rax
    mov     rdx,r9
    shl     rdx,11h
    shr     r9,2Fh
    or      rdx,r9
    mov     [rsp+48h],rdx
    xor     rdx,r8
    mov     [rsp+48h],rdx
    mov     rdx,rdi
    shl     rdx,15h
    shr     rdi,2Bh
    or      rdx,rdi
    mov     [rsp+50h],rdx
    xor     rdx,rax
    mov     [rsp+50h],rdx
    mov     rdx,r8
    shl     rdx,20h
    shr     r8,20h
    or      rdx,r8
    mov     [rsp+40h],rdx
    xor     rax,rsi
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+78h],0
L4:
    mov     r12d,1
    sub     r12,rbx
    mov     r13,r12
    and     r13,7
L5:
    mov     [rsp+20h],rbx
    mov     rax,r12
    sub     rax,r13
    cmp     rbx,rax
    jae     L6
    mov     qword ptr [rsp+20h],0
    lea     rax,[rsp+2Fh]
    lea     r14,[rax+rbx]
    mov     rdi,r14
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L10
    test    r14,r14
    je      L10
    lea     rdi,[rsp+20h]
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L10
    lea     rsi,[rsp+20h]
    mov     rdi,r14
    mov     edx,1
    mov     ecx,8
    call    image.fn152
    test    al,al
    je      L10
    mov     r14,[r14]
    mov     [rsp+20h],r14
    mov     rax,[rsp+50h]
    xor     rax,r14
    mov     [rsp+50h],rax
    lea     rdi,[rsp+38h]
    mov     [rsp+20h],rdi
    call    image.fn187
    mov     rax,[rsp+38h]
    xor     rax,r14
    mov     [rsp+38h],rax
    lea     rax,[rbx+8]
    mov     rbx,rax
    jmp     L5
L6:
    lea     rdi,[rsp+2Fh]
    mov     esi,1
    mov     rdx,rbx
    mov     rcx,r13
    call    image.fn132
    mov     [rsp+70h],rax
    mov     [rsp+78h],r13
L7:
    lea     rdi,[rsp+38h]
    call    image.fn177
    add     rsp,80h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
    jmp     L9
    jmp     L9
    jmp     L9
L8:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k4960]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L9:
    call    image.sym23
    ud2
    jmp     L11
    jmp     L11
    jmp     L11
L10:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k4960]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L11:
    call    image.sym23
    ud2

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::hash_one::<&u64>
    push    rbx
    push    r12
    sub     rsp,0A8h
    mov     r10,736F6D6570736575h
    mov     [rsp+58h],r10
    mov     r10,6C7967656E657261h
    mov     [rsp+60h],r10
    mov     r10,646F72616E646F6Dh
    mov     [rsp+68h],r10
    mov     r10,7465646279746573h
    mov     [rsp+70h],r10
    mov     qword ptr [rsp+78h],0
    mov     qword ptr [rsp+80h],0
    mov     qword ptr [rsp+88h],0
    mov     qword ptr [rsp+90h],0
    mov     qword ptr [rsp+98h],0
    mov     rax,[rsi]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+88h],8
    mov     ebx,0
L0:
    mov     [rsp+10h],rbx
    cmp     rbx,8
    jae     L1
    mov     qword ptr [rsp+10h],0
    lea     rax,[rsp+20h]
    lea     r12,[rax+rbx]
    mov     rdi,r12
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L2
    test    r12,r12
    je      L2
    lea     rdi,[rsp+10h]
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L2
    lea     rsi,[rsp+10h]
    mov     rdi,r12
    mov     edx,1
    mov     ecx,8
    call    qword ptr [image.fn152.slot]
    test    al,al
    je      L2
    mov     r12,[r12]
    mov     [rsp+10h],r12
    mov     rax,[rsp+70h]
    xor     rax,r12
    mov     [rsp+70h],rax
    lea     rdi,[rsp+58h]
    mov     [rsp+10h],rdi
    call    image.fn187
    mov     rax,[rsp+58h]
    xor     rax,r12
    mov     [rsp+58h],rax
    lea     rax,[rbx+8]
    mov     rbx,rax
    jmp     L0
L1:
    lea     rdi,[rsp+20h]
    mov     esi,8
    mov     rdx,rbx
    mov     ecx,0
    call    qword ptr [image.fn132.slot]
    mov     [rsp+90h],rax
    mov     qword ptr [rsp+98h],0
    mov     rcx,[rsp+58h]
    mov     [rsp+30h],rcx
    mov     rdx,[rsp+60h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+70h]
    mov     [rsp+48h],rdi
    mov     r8,[rsp+88h]
    and     r8,0FFh
    shl     r8,38h
    or      r8,rax
    xor     rdi,r8
    mov     [rsp+48h],rdi
    lea     rax,[rsp+30h]
    add     rcx,rsi
    mov     [rsp+30h],rcx
    add     rdx,rdi
    mov     [rsp+38h],rdx
    mov     r9,rsi
    shl     r9,0Dh
    shr     rsi,33h
    or      r9,rsi
    mov     [rsp+40h],r9
    xor     r9,rcx
    mov     [rsp+40h],r9
    mov     rsi,rdi
    shl     rsi,10h
    shr     rdi,30h
    or      rsi,rdi
    mov     [rsp+48h],rsi
    xor     rsi,rdx
    mov     [rsp+48h],rsi
    mov     rdi,rcx
    shl     rdi,20h
    shr     rcx,20h
    or      rdi,rcx
    mov     [rsp+30h],rdi
    add     rdx,r9
    mov     [rsp+38h],rdx
    add     rdi,rsi
    mov     [rsp+30h],rdi
    mov     rcx,r9
    shl     rcx,11h
    shr     r9,2Fh
    or      rcx,r9
    mov     [rsp+40h],rcx
    xor     rcx,rdx
    mov     [rsp+40h],rcx
    mov     rcx,rsi
    shl     rcx,15h
    shr     rsi,2Bh
    or      rcx,rsi
    mov     [rsp+48h],rcx
    xor     rcx,rdi
    mov     [rsp+48h],rcx
    mov     rcx,rdx
    shl     rcx,20h
    shr     rdx,20h
    or      rcx,rdx
    mov     [rsp+38h],rcx
    xor     rdi,r8
    mov     [rsp+30h],rdi
    xor     rcx,0FFh
    mov     [rsp+38h],rcx
    mov     rdi,rax
    call    qword ptr [image.fn188.slot]
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+40h]
    xor     rax,rcx
    mov     rcx,[rsp+38h]
    xor     rax,rcx
    mov     rcx,[rsp+48h]
    xor     rax,rcx
    add     rsp,0A8h
    pop     r12
    pop     rbx
    ret
    jmp     L3
    jmp     L3
    jmp     L3
L2:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k4960]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L3:
    call    image.sym23
    ud2

fn <std::hash::DefaultHasher as std::default::Default>::default
    mov     r10,736F6D6570736575h
    mov     [rdi],r10
    mov     r10,6C7967656E657261h
    mov     [rdi+8],r10
    mov     r10,646F72616E646F6Dh
    mov     [rdi+10h],r10
    mov     r10,7465646279746573h
    mov     [rdi+18h],r10
    mov     qword ptr [rdi+20h],0
    mov     qword ptr [rdi+28h],0
    mov     qword ptr [rdi+30h],0
    mov     qword ptr [rdi+38h],0
    mov     qword ptr [rdi+40h],0
    mov     rax,rdi
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+18h]
    mov     r8,[rdi+30h]
    and     r8,0FFh
    shl     r8,38h
    mov     rdi,[rdi+38h]
    or      r8,rdi
    xor     rsi,r8
    add     rax,rdx
    add     rcx,rsi
    mov     rdi,rdx
    shl     rdi,0Dh
    shr     rdx,33h
    or      rdi,rdx
    xor     rdi,rax
    mov     rdx,rsi
    shl     rdx,10h
    shr     rsi,30h
    or      rdx,rsi
    xor     rdx,rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    add     rcx,rdi
    add     rsi,rdx
    mov     rax,rdi
    shl     rax,11h
    shr     rdi,2Fh
    or      rax,rdi
    xor     rax,rcx
    mov     rdi,rdx
    shl     rdi,15h
    shr     rdx,2Bh
    or      rdi,rdx
    xor     rdi,rsi
    mov     rdx,rcx
    shl     rdx,20h
    shr     rcx,20h
    or      rdx,rcx
    xor     rsi,r8
    xor     rdx,0FFh
    add     rsi,rax
    add     rdx,rdi
    mov     rcx,rax
    shl     rcx,0Dh
    shr     rax,33h
    or      rcx,rax
    xor     rcx,rsi
    mov     rax,rdi
    shl     rax,10h
    shr     rdi,30h
    or      rax,rdi
    xor     rax,rdx
    mov     rdi,rsi
    shl     rdi,20h
    shr     rsi,20h
    or      rdi,rsi
    add     rdx,rcx
    add     rdi,rax
    mov     rsi,rcx
    shl     rsi,11h
    shr     rcx,2Fh
    or      rsi,rcx
    xor     rsi,rdx
    mov     rcx,rax
    shl     rcx,15h
    shr     rax,2Bh
    or      rcx,rax
    xor     rcx,rdi
    mov     rax,rdx
    shl     rax,20h
    shr     rdx,20h
    or      rax,rdx
    add     rdi,rsi
    add     rax,rcx
    mov     rdx,rsi
    shl     rdx,0Dh
    shr     rsi,33h
    or      rdx,rsi
    xor     rdx,rdi
    mov     rsi,rcx
    shl     rsi,10h
    shr     rcx,30h
    or      rsi,rcx
    xor     rsi,rax
    mov     rcx,rdi
    shl     rcx,20h
    shr     rdi,20h
    or      rcx,rdi
    add     rax,rdx
    add     rcx,rsi
    mov     rdi,rdx
    shl     rdi,11h
    shr     rdx,2Fh
    or      rdi,rdx
    xor     rdi,rax
    mov     rdx,rsi
    shl     rdx,15h
    shr     rsi,2Bh
    or      rdx,rsi
    xor     rdx,rcx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    add     rcx,rdi
    add     rsi,rdx
    mov     rax,rdi
    shl     rax,0Dh
    shr     rdi,33h
    or      rax,rdi
    xor     rax,rcx
    mov     rdi,rdx
    shl     rdi,10h
    shr     rdx,30h
    or      rdi,rdx
    xor     rdi,rsi
    mov     rdx,rcx
    shl     rdx,20h
    shr     rcx,20h
    or      rdx,rcx
    add     rsi,rax
    add     rdx,rdi
    mov     rcx,rax
    shl     rcx,11h
    shr     rax,2Fh
    or      rcx,rax
    xor     rcx,rsi
    mov     rax,rdi
    shl     rax,15h
    shr     rdi,2Bh
    or      rax,rdi
    xor     rax,rdx
    mov     rdi,rsi
    shl     rdi,20h
    shr     rsi,20h
    or      rdi,rsi
    xor     rdx,rcx
    xor     rdx,rdi
    xor     rax,rdx
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+10h],rdx
    mov     rax,[rbx+30h]
    add     rax,[rsp+10h]
    mov     [rbx+30h],rax
    mov     rax,[rbx+40h]
    test    rax,rax
    jne     L0
    mov     r14d,0
    jmp     L8
L0:
    mov     r14d,8
    sub     r14,rax
    cmp     r14,[rsp+10h]
    jae     L1
    mov     rax,r14
    jmp     L2
L1:
    mov     rax,[rsp+10h]
L2:
    mov     r11d,3
    cmp     r11,rax
    jb      L3
    mov     edx,0
    mov     esi,0
    jmp     L4
L3:
    test    r12,r12
    je      L16
    mov     edx,[r12]
    mov     rsi,rdx
    mov     edx,4
L4:
    lea     rdi,[rdx+1]
    cmp     rdi,rax
    jae     L5
    lea     rdi,[r12+rdx]
    test    rdi,rdi
    je      L17
    movzx   edi,word ptr [rdi]
    mov     rcx,rdx
    imul    rcx,8
    shl     rdi,cl
    or      rsi,rdi
    add     rdx,2
L5:
    cmp     rdx,rax
    jae     L6
    cmp     rdx,[rsp+10h]
    jae     L18
    movzx   eax,byte ptr [r12+rdx]
    movzx   eax,al
    mov     rcx,rdx
    imul    rcx,8
    shl     rax,cl
    or      rsi,rax
L6:
    mov     rax,[rbx+40h]
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    mov     rdx,[rbx+38h]
    or      rdx,rsi
    mov     [rbx+38h],rdx
    mov     r11,[rsp+10h]
    cmp     r11,r14
    jae     L7
    add     rax,[rsp+10h]
    mov     [rbx+40h],rax
    jmp     L15
L7:
    mov     rax,[rbx+18h]
    xor     rax,rdx
    mov     [rbx+18h],rax
    mov     rdi,rbx
    call    image.fn187
    mov     rax,[rbx+38h]
    mov     rdx,[rbx]
    xor     rdx,rax
    mov     [rbx],rdx
    mov     qword ptr [rbx+40h],0
L8:
    mov     r15,[rsp+10h]
    sub     r15,r14
    mov     rbp,r15
    and     rbp,7
L9:
    mov     rax,r15
    sub     rax,rbp
    cmp     r14,rax
    jae     L10
    lea     rax,[r12+r14]
    test    rax,rax
    je      L19
    mov     r13,[rax]
    mov     rax,[rbx+18h]
    xor     rax,r13
    mov     [rbx+18h],rax
    mov     rdi,rbx
    call    image.fn187
    mov     rax,[rbx]
    xor     rax,r13
    mov     [rbx],rax
    lea     rax,[r14+8]
    mov     r14,rax
    jmp     L9
L10:
    mov     r11d,3
    cmp     r11,rbp
    jb      L11
    mov     eax,0
    mov     edx,0
    jmp     L12
L11:
    lea     rax,[r12+r14]
    test    rax,rax
    je      L20
    mov     eax,[rax]
    mov     rdx,rax
    mov     eax,4
L12:
    lea     rsi,[rax+1]
    cmp     rsi,rbp
    jae     L13
    lea     rsi,[r14+rax]
    lea     rsi,[r12+rsi]
    test    rsi,rsi
    je      L21
    movzx   esi,word ptr [rsi]
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
    add     rax,2
L13:
    cmp     rax,rbp
    jae     L14
    add     r14,rax
    cmp     r14,[rsp+10h]
    jae     L22
    movzx   esi,byte ptr [r12+r14]
    movzx   esi,sil
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
L14:
    mov     [rbx+38h],rdx
    mov     [rbx+40h],rbp
L15:
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L16:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L17:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L18:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L19:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k4960]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L20:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L21:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L22:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2

fn core::hash::sip::u8to64_le
    push    rbx
    sub     rsp,10h
    mov     rax,rcx
    mov     r11d,3
    cmp     r11,rax
    jb      L0
    mov     r8d,0
    mov     r9d,0
    jmp     L1
L0:
    lea     r8,[rdi+rdx]
    test    r8,r8
    je      L4
    mov     r8d,[r8]
    mov     r9,r8
    mov     r8d,4
L1:
    lea     rcx,[r8+1]
    cmp     rcx,rax
    jae     L2
    lea     rcx,[rdx+r8]
    lea     rcx,[rdi+rcx]
    test    rcx,rcx
    je      L5
    movzx   ecx,word ptr [rcx]
    mov     rbx,r8
    imul    rbx,8
    mov     r11,rcx
    mov     rcx,rbx
    shl     r11,cl
    mov     rbx,r11
    or      r9,rbx
    add     r8,2
L2:
    cmp     r8,rax
    jae     L3
    add     rdx,r8
    cmp     rdx,rsi
    jae     L6
    movzx   eax,byte ptr [rdi+rdx]
    movzx   eax,al
    mov     rcx,r8
    imul    rcx,8
    shl     rax,cl
    or      r9,rax
L3:
    mov     rax,r9
    add     rsp,10h
    pop     rbx
    ret
L4:
    lea     rdi,[image.k3619]
    lea     rcx,[k0]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L5:
    lea     rdi,[image.k3619]
    lea     rcx,[k2]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L6:
    lea     rdi,[image.k4746]
    lea     rcx,[k4]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
    .long   L9
    .long   L10
L8:
    ret
L9:
    ret
L10:
    ret

fn core::num::<impl u64>::wrapping_add
    lea     rax,[rdi+rsi]
    ret

fn core::num::<impl u64>::wrapping_mul
    mov     rax,rdi
    imul    rax,rsi
    ret

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    sub     rsp,18h
    mov     rax,rdx
    mul     rcx
    jb      L2
    cmp     rdi,rsi
    jae     L0
    mov     rcx,rsi
    sub     rcx,rdi
    jmp     L1
L0:
    sub     rdi,rsi
    mov     rcx,rdi
L1:
    cmp     rax,rcx
    setbe   al
    movzx   eax,al
    add     rsp,18h
    ret
L2:
    lea     rdi,[k0]
    mov     esi,3Dh
    call    sym1
    ud2

fn hashbrown::map::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::retain::<{closure@bench/hashmap.rs:27:16: 27:22}>
    sub     rsp,0C8h
    mov     [rsp+28h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+18h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,[rbx]
    mov     [rsp+48h],r12
    mov     [rsp+40h],r12
    mov     [rsp+50h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    movdqu  xmm0,[r13]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    lea     r13,[r13+10h]
    mov     [rsp+30h],r12
    mov     [rsp+38h],r13
    mov     [rsp+40h],r14
    mov     [rsp+48h],ax
    mov     [rsp+4Ah],r10d
    mov     [rsp+4Eh],r10w
    mov     rax,[rbx+18h]
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],r12
    mov     [rsp+38h],r13
    mov     [rsp+40h],r14
    mov     [rsp+48h],rcx
    mov     [rsp+50h],rax
L0:
    mov     rax,[rsp+50h]
    test    rax,rax
    je      L2
L1:
    movzx   eax,word ptr [rsp+48h]
    test    ax,ax
    je      L3
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rsp+48h],ax
    mov     rax,[rsp+30h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+50h]
    sub     rcx,1
    mov     [rsp+50h],rcx
    test    rax,rax
    jne     L11
L2:
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+10h]
    add     rsp,0C8h
    ret
L3:
    mov     r12,[rsp+38h]
    movdqu  xmm0,[r12]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+48h],cx
    mov     rcx,[rsp+30h]
    lea     rcx,[rcx-100h]
    mov     [rsp+30h],rcx
    lea     r12,[r12+10h]
    mov     [rsp+38h],r12
    jmp     L1
L4:
    mov     rsi,rcx
    lea     rsi,[rsi-10h]
L5:
    mov     rdi,rdx
L6:
    mov     rdx,[rsi]
    mov     r11d,3
    mov     rax,rdx
    xor     edx,edx
    div     r11
    test    rdx,rdx
    setne   dl
L7:
    test    dl,dl
    je      L8
    mov     rbx,rdi
    jmp     L0
L8:
    mov     rdx,[rdi]
    mov     r11,rdx
    sub     r11,rcx
    mov     rcx,r11
    sar     rcx,4
    lea     rsi,[rcx-10h]
    mov     r8,[rdi+8]
    and     rsi,r8
    lea     rsi,[rdx+rsi]
    test    rsi,rsi
    je      L12
    movdqu  xmm0,[rsi]
    pcmpeqb xmm1,xmm1
    pcmpeqb xmm0,xmm1
    pmovmskb esi,xmm0
    lea     rdx,[rdx+rcx]
    test    rdx,rdx
    je      L13
    movdqu  xmm0,[rdx]
    pcmpeqb xmm0,xmm1
    pmovmskb edx,xmm0
    movzx   esi,si
    bsr     esi,esi
    mov     r10d,1Fh
    cmove   esi,r10d
    xor     esi,0Fh
    movzx   edx,dx
    or      edx,10000h
    bsf     edx,edx
    add     rsi,rdx
    cmp     rsi,10h
    jb      L9
    mov     edx,80h
    jmp     L10
L9:
    mov     rdx,[rdi+10h]
    add     rdx,1
    mov     [rdi+10h],rdx
    mov     edx,0FFh
L10:
    lea     rsi,[rcx-10h]
    mov     r8,[rdi+8]
    and     rsi,r8
    add     rsi,10h
    mov     r8,[rdi]
    mov     [r8+rcx],dl
    mov     rcx,[rdi]
    mov     [rcx+rsi],dl
    mov     rcx,[rdi+18h]
    sub     rcx,1
    mov     [rdi+18h],rcx
    mov     rbx,rdi
    jmp     L0
L11:
    mov     rcx,rax
    mov     rdx,rbx
    jmp     L4
L12:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L13:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L14]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L14:
    .long   L15
    .long   L16
    .long   L17
    .long   L18
    .long   L19
    .long   L20
    .long   L21
L15:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-8]
    mov     [rsp],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     rbx,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L0
L16:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-98h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     rcx,[rsp]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L4
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    movzx   r11d,byte ptr [rdx-0B1h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     rcx,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L7
L19:
    ret
L20:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     rsi,[rsp]
    mov     rcx,[rsp+8]
    mov     rdi,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L6
L21:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     rsi,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L5

fn hashbrown::raw::FullBucketsIndices::next_impl
    sub     rsp,88h
    mov     [rsp+8],rbx
    mov     rbx,rdi
L0:
    movzx   eax,word ptr [rbx+18h]
    test    ax,ax
    je      L1
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    lea     rdx,[rax+rcx]
    mov     eax,1
    mov     rbx,[rsp+8]
    add     rsp,88h
    ret
L1:
    mov     rax,[rbx]
    mov     rcx,rax
    lea     rcx,[rcx+10h]
    mov     [rbx],rcx
    movdqu  xmm0,[rax+10h]
    movq    rax,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rcx,xmm15
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    add     rax,10h
    mov     [rbx+8],rax
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    pop     rcx
    lea     rdx,[rsp+0C0h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     [rdx-78h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    sub     rsp,98h
    mov     [rsp+8],rbx
L0:
    movzx   eax,word ptr [rdi+18h]
    test    ax,ax
    je      L3
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rdi+18h],ax
    mov     rax,[rdi]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    jmp     L5
L1:
    mov     rcx,[rbx+8]
    movdqu  xmm0,[rcx]
    movq    rcx,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rdx,xmm15
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    pmovmskb ecx,xmm0
    mov     rdi,rcx
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rbx+18h],cx
    mov     rcx,[rbx]
    lea     rcx,[rcx-200h]
    jmp     L7
L2:
    mov     rbx,[rsp+8]
    add     rsp,98h
    ret
L3:
    mov     rbx,rdi
    jmp     L1
L4:
    jmp     L2
L5:
    jmp     L4
L6:
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rdi,rcx
    jmp     L0
L7:
    mov     rax,rcx
    mov     rcx,rbx
    jmp     L6
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
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-88h],rbx
    mov     rdi,[rsp]
    lea     rsp,[rsp+60h]
    jmp     L0
L10:
    ret
L11:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-88h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+60h]
    jmp     L1
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     [rdx-88h],rbx
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+60h]
    jmp     L6
L16:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     [rdx-88h],rbx
    mov     rcx,[rsp]
    mov     rbx,[rsp+8]
    lea     rsp,[rsp+60h]
    jmp     L7

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,0E8h
    mov     [rsp+28h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+18h],r13
    mov     [rsp+10h],r14
    mov     [rsp+0A0h],rcx
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    movzx   edi,word ptr [rdi+18h]
L0:
    test    di,di
    je      L4
    movzx   r8d,di
    or      r8d,10000h
    bsf     r8d,r8d
    lea     r9d,[rdi-1]
    and     edi,r9d
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    mov     r11,r8
    imul    r11,10h
    add     r11,rax
    mov     r8,r11
    jmp     L6
L1:
    sub     r8,1
    mov     rsi,r8
    mov     rdx,rdi
    mov     rdi,r9
    mov     rcx,rbx
    mov     rax,r12
    jmp     L0
L2:
    mov     rax,rdx
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+10h]
    add     rsp,0E8h
    ret
L3:
    movdqu  xmm0,[rbx]
    movq    rdi,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    r8,xmm15
    mov     [rsp+30h],rdi
    mov     [rsp+38h],r8
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rdi,rax
    lea     r12,[r12-100h]
    jmp     L8
L4:
    test    rsi,rsi
    je      L2
    mov     rbx,rcx
    mov     r12,rax
    mov     r13,rsi
    mov     r14,rdx
    jmp     L3
L5:
    mov     rax,[rax-8]
    add     rcx,rax
    mov     r9,rsi
    mov     rbx,rdi
    mov     rdi,rcx
    mov     r12,r8
    mov     r8,rdx
    jmp     L1
L6:
    mov     r10,rax
    mov     rax,r8
    mov     r8,r10
    mov     r10,rcx
    mov     rcx,rdx
    mov     rdx,rsi
    mov     rsi,rdi
    mov     rdi,r10
    jmp     L5
L7:
    lea     rcx,[rcx+10h]
    mov     r10,rdi
    mov     rdi,rdx
    mov     rdx,r10
    jmp     L0
L8:
    mov     rax,r12
    mov     rcx,rbx
    mov     rdx,rdi
    mov     rsi,r13
    mov     rdi,r14
    jmp     L7
  ; OSR entries
    lea     r11,[L9]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L9:
    .long   L10
    .long   L11
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
    .long   L19
L10:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    mov     rcx,[rsp+18h]
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+70h]
    jmp     L0
L11:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     rdi,[rsp]
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L1
L12:
    ret
L13:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-140h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+60h]
    jmp     L3
L14:
    ret
L15:
    ret
L16:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+70h]
    jmp     L5
L17:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     r8,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+70h]
    jmp     L6
L18:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0C8h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+70h]
    jmp     L7
L19:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0C8h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    movzx   r11d,word ptr [rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     r12,[rsp]
    mov     rbx,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L8

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,98h
    mov     [rsp+8],rbx
L0:
    movzx   eax,word ptr [rdi+18h]
    test    ax,ax
    je      L3
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rdi+18h],ax
    mov     rax,[rdi]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    jmp     L5
L1:
    mov     rcx,[rbx+8]
    movdqu  xmm0,[rcx]
    movq    rcx,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rdx,xmm15
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    pmovmskb ecx,xmm0
    mov     rdi,rcx
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rbx+18h],cx
    mov     rcx,[rbx]
    lea     rcx,[rcx-100h]
    jmp     L7
L2:
    mov     rbx,[rsp+8]
    add     rsp,98h
    ret
L3:
    mov     rbx,rdi
    jmp     L1
L4:
    jmp     L2
L5:
    jmp     L4
L6:
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rdi,rcx
    jmp     L0
L7:
    mov     rax,rcx
    mov     rcx,rbx
    jmp     L6
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
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-88h],rbx
    mov     rdi,[rsp]
    lea     rsp,[rsp+60h]
    jmp     L0
L10:
    ret
L11:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-88h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+60h]
    jmp     L1
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     [rdx-88h],rbx
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+60h]
    jmp     L6
L16:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     [rdx-88h],rbx
    mov     rcx,[rsp]
    mov     rbx,[rsp+8]
    lea     rsp,[rsp+60h]
    jmp     L7

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,48h
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     r8,[rdx+10h]
    mov     rdx,[rdx+18h]
    mov     [rsp+30h],rsi
    mov     r9,[rdi+8]
    and     r9,rsi
    mov     [rsp+38h],r9
    mov     [rsp+20h],r9
    mov     qword ptr [rsp+28h],0
L0:
    mov     r9,[rsp+20h]
    mov     rbx,[rdi]
    lea     rbx,[rbx+r9]
    test    rbx,rbx
    je      L7
    mov     r12,[rbx]
    mov     rbx,[rbx+8]
    mov     [rsp+30h],r12
    mov     [rsp+38h],rbx
    mov     r13d,[rsp+3Ch]
    mov     [rsp+10h],r12
    mov     [rsp+18h],ebx
    mov     [rsp+1Ch],r13d
    movdqu  xmm0,[rsp+10h]
    pmovmskb ebx,xmm0
    test    bx,bx
    je      L2
    movzx   ebx,bx
    or      ebx,10000h
    bsf     ebx,ebx
    mov     [rsp+1Ch],ebx
    add     r9,rbx
    mov     rbx,[rdi+8]
    and     r9,rbx
    mov     rbx,r9
    mov     r9d,1
L1:
    cmp     r9,1
    je      L3
    mov     r9,[rdi+8]
    mov     r12,[rsp+28h]
    add     r12,10h
    mov     [rsp+28h],r12
    mov     r13,[rsp+20h]
    add     r13,r12
    mov     [rsp+20h],r13
    and     r13,r9
    mov     [rsp+20h],r13
    jmp     L0
L2:
    mov     r9d,0
    mov     ebx,0
    jmp     L1
L3:
    mov     r9,[rdi]
    movzx   r12d,byte ptr [r9+rbx]
    test    r12b,80h
    jne     L5
    movdqu  xmm0,[r9]
    pmovmskb r9d,xmm0
    test    r9w,r9w
    je      L6
    movzx   r9d,r9w
    or      r9d,10000h
    bsf     r9d,r9d
L4:
    mov     r12,[rdi]
    movzx   r13d,byte ptr [r12+r9]
    mov     r14,rsi
    shr     r14,39h
    and     r14,7Fh
    lea     r15,[r9-10h]
    mov     rbp,[rdi+8]
    and     r15,rbp
    add     r15,10h
    mov     [r12+r9],r14b
    mov     r12,[rdi]
    mov     [r12+r15],r14b
    mov     r12,[rdi]
    mov     r11d,0
    sub     r11,r9
    mov     r9,r11
    mov     r11,r9
    imul    r11,20h
    add     r11,r12
    mov     r12,r11
    and     r13d,1
    test    r13b,r13b
    setne   r9b
    movzx   r9d,r9b
    mov     r13,[rdi+10h]
    sub     r13,r9
    mov     [rdi+10h],r13
    mov     [r12-20h],rax
    mov     [r12-18h],rcx
    mov     [r12-10h],r8
    mov     [r12-8],rdx
    mov     r9,[rdi+18h]
    add     r9,1
    mov     [rdi+18h],r9
    mov     rax,r12
    add     rsp,48h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L5:
    mov     r9,rbx
    jmp     L4
L6:
    mov     r9d,0
    jmp     L4
L7:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
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
L9:
    ret
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    push    rbx
    push    r12
    sub     rsp,88h
    mov     rax,[rsi]
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    jmp     L2
L0:
    mov     rax,rcx
    add     rsp,88h
    pop     r12
    pop     rbx
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    lea     rdi,[rsp+38h]
    mov     r10,736F6D6570736575h
    mov     [rsp+38h],r10
    mov     r10,6C7967656E657261h
    mov     [rsp+40h],r10
    mov     r10,646F72616E646F6Dh
    mov     [rsp+48h],r10
    mov     r10,7465646279746573h
    mov     [rsp+50h],r10
    mov     qword ptr [rsp+58h],0
    mov     qword ptr [rsp+60h],0
    mov     qword ptr [rsp+68h],0
    mov     qword ptr [rsp+70h],0
    mov     qword ptr [rsp+78h],0
    mov     rsi,[rax-18h]
    mov     rdx,[rax-10h]
    call    image.fn176
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rsi,[rsp+0Fh]
    lea     rdi,[rsp+38h]
    mov     edx,1
    call    image.fn176
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+20h],rdi
    mov     r8,[rsp+50h]
    mov     [rsp+28h],r8
    mov     r9,[rsp+68h]
    and     r9,0FFh
    shl     r9,38h
    mov     rbx,[rsp+70h]
    or      r9,rbx
    xor     r8,r9
    mov     [rsp+28h],r8
    lea     rbx,[rsp+10h]
    add     rdx,rdi
    mov     [rsp+10h],rdx
    add     rsi,r8
    mov     [rsp+18h],rsi
    mov     r12,rdi
    shl     r12,0Dh
    shr     rdi,33h
    or      r12,rdi
    mov     [rsp+20h],r12
    xor     r12,rdx
    mov     [rsp+20h],r12
    mov     rdi,r8
    shl     rdi,10h
    shr     r8,30h
    or      rdi,r8
    mov     [rsp+28h],rdi
    xor     rdi,rsi
    mov     [rsp+28h],rdi
    mov     r8,rdx
    shl     r8,20h
    shr     rdx,20h
    or      r8,rdx
    mov     [rsp+10h],r8
    add     rsi,r12
    mov     [rsp+18h],rsi
    add     r8,rdi
    mov     [rsp+10h],r8
    mov     rdx,r12
    shl     rdx,11h
    shr     r12,2Fh
    or      rdx,r12
    mov     [rsp+20h],rdx
    xor     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdx,rdi
    shl     rdx,15h
    shr     rdi,2Bh
    or      rdx,rdi
    mov     [rsp+28h],rdx
    xor     rdx,r8
    mov     [rsp+28h],rdx
    mov     rdx,rsi
    shl     rdx,20h
    shr     rsi,20h
    or      rdx,rsi
    mov     [rsp+18h],rdx
    xor     r8,r9
    mov     [rsp+10h],r8
    xor     rdx,0FFh
    mov     [rsp+18h],rdx
    mov     rdi,rbx
    call    image.fn188
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+20h]
    xor     rdx,rsi
    mov     rsi,[rsp+18h]
    xor     rdx,rsi
    mov     rsi,[rsp+28h]
    mov     rcx,rdx
    xor     rcx,rsi
    jmp     L0
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
    .long   L9
    .long   L10
L6:
    ret
L7:
    ret
L8:
    ret
L9:
    ret
L10:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,rax
    sub     rcx,rsi
    sar     rcx,4
    lea     rdx,[rcx-10h]
    mov     rsi,[rdi+8]
    and     rdx,rsi
    lea     rdx,[rax+rdx]
    test    rdx,rdx
    je      L2
    movdqu  xmm0,[rdx]
    pcmpeqb xmm1,xmm1
    pcmpeqb xmm0,xmm1
    pmovmskb edx,xmm0
    lea     rax,[rax+rcx]
    test    rax,rax
    je      L3
    movdqu  xmm0,[rax]
    pcmpeqb xmm0,xmm1
    pmovmskb eax,xmm0
    movzx   edx,dx
    bsr     edx,edx
    mov     r10d,1Fh
    cmove   edx,r10d
    xor     edx,0Fh
    movzx   eax,ax
    or      eax,10000h
    bsf     eax,eax
    add     rdx,rax
    cmp     rdx,10h
    jb      L0
    mov     eax,80h
    jmp     L1
L0:
    mov     rax,[rdi+10h]
    add     rax,1
    mov     [rdi+10h],rax
    mov     eax,0FFh
L1:
    lea     rdx,[rcx-10h]
    mov     rsi,[rdi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     rsi,[rdi]
    mov     [rsi+rcx],al
    mov     rcx,[rdi]
    mov     [rcx+rdx],al
    mov     rax,[rdi+18h]
    sub     rax,1
    mov     [rdi+18h],rax
    add     rsp,18h
    ret
L2:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L3:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L4]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L4:
    .long   L5
    .long   L6
L5:
    ret
L6:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    push    rbx
    push    r12
    sub     rsp,98h
    mov     rax,[rsi]
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    jmp     L2
L0:
    mov     rax,rcx
    add     rsp,98h
    pop     r12
    pop     rbx
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    lea     rdi,[rsp+48h]
    mov     r10,736F6D6570736575h
    mov     [rsp+48h],r10
    mov     r10,6C7967656E657261h
    mov     [rsp+50h],r10
    mov     r10,646F72616E646F6Dh
    mov     [rsp+58h],r10
    mov     r10,7465646279746573h
    mov     [rsp+60h],r10
    mov     qword ptr [rsp+68h],0
    mov     qword ptr [rsp+70h],0
    mov     qword ptr [rsp+78h],0
    mov     qword ptr [rsp+80h],0
    mov     qword ptr [rsp+88h],0
    mov     rdx,[rax-10h]
    mov     [rsp+10h],rdx
    lea     rsi,[rsp+10h]
    mov     edx,8
    call    qword ptr [image.fn176.slot]
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+58h]
    mov     [rsp+30h],rdi
    mov     r8,[rsp+60h]
    mov     [rsp+38h],r8
    mov     r9,[rsp+78h]
    and     r9,0FFh
    shl     r9,38h
    mov     rbx,[rsp+80h]
    or      r9,rbx
    xor     r8,r9
    mov     [rsp+38h],r8
    lea     rbx,[rsp+20h]
    add     rdx,rdi
    mov     [rsp+20h],rdx
    add     rsi,r8
    mov     [rsp+28h],rsi
    mov     r12,rdi
    shl     r12,0Dh
    shr     rdi,33h
    or      r12,rdi
    mov     [rsp+30h],r12
    xor     r12,rdx
    mov     [rsp+30h],r12
    mov     rdi,r8
    shl     rdi,10h
    shr     r8,30h
    or      rdi,r8
    mov     [rsp+38h],rdi
    xor     rdi,rsi
    mov     [rsp+38h],rdi
    mov     r8,rdx
    shl     r8,20h
    shr     rdx,20h
    or      r8,rdx
    mov     [rsp+20h],r8
    add     rsi,r12
    mov     [rsp+28h],rsi
    add     r8,rdi
    mov     [rsp+20h],r8
    mov     rdx,r12
    shl     rdx,11h
    shr     r12,2Fh
    or      rdx,r12
    mov     [rsp+30h],rdx
    xor     rdx,rsi
    mov     [rsp+30h],rdx
    mov     rdx,rdi
    shl     rdx,15h
    shr     rdi,2Bh
    or      rdx,rdi
    mov     [rsp+38h],rdx
    xor     rdx,r8
    mov     [rsp+38h],rdx
    mov     rdx,rsi
    shl     rdx,20h
    shr     rsi,20h
    or      rdx,rsi
    mov     [rsp+28h],rdx
    xor     r8,r9
    mov     [rsp+20h],r8
    xor     rdx,0FFh
    mov     [rsp+28h],rdx
    mov     rdi,rbx
    call    image.fn188
    mov     rdx,[rsp+20h]
    mov     rsi,[rsp+30h]
    xor     rdx,rsi
    mov     rsi,[rsp+28h]
    xor     rdx,rsi
    mov     rsi,[rsp+38h]
    mov     rcx,rdx
    xor     rcx,rsi
    jmp     L0
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
    .long   L9
    .long   L10
L6:
    ret
L7:
    ret
L8:
    ret
L9:
    ret
L10:
    ret

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    sub     rsp,0A8h
    mov     [rsp+20h],rbx
    mov     [rsp+18h],r12
    mov     [rsp+10h],r13
    mov     [rsp+8],r14
    mov     rbx,rdi
    mov     rax,[rbx+18h]
    mov     [rsp+48h],rax
    test    rax,rax
    je      L2
    mov     r12,[rbx]
    mov     [rsp+40h],r12
    mov     [rsp+38h],r12
    mov     [rsp+48h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    movdqu  xmm0,[r13]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    lea     r13,[r13+10h]
    mov     [rsp+28h],r12
    mov     [rsp+30h],r13
    mov     [rsp+38h],r14
    mov     [rsp+40h],ax
    mov     [rsp+42h],r10d
    mov     [rsp+46h],r10w
    mov     rax,[rbx+18h]
    mov     rcx,[rsp+40h]
    mov     [rsp+28h],r12
    mov     [rsp+30h],r13
    mov     [rsp+38h],r14
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rax
L0:
    mov     rax,[rsp+48h]
    test    rax,rax
    je      L2
L1:
    movzx   eax,word ptr [rsp+40h]
    test    ax,ax
    je      L3
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rsp+40h],ax
    mov     rax,[rsp+28h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+48h]
    sub     rcx,1
    mov     [rsp+48h],rcx
    test    rax,rax
    jne     L7
L2:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+8]
    add     rsp,0A8h
    ret
L3:
    mov     rbx,[rsp+30h]
    movdqu  xmm0,[rbx]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+40h],cx
    mov     rcx,[rsp+28h]
    lea     rcx,[rcx-200h]
    mov     [rsp+28h],rcx
    lea     rbx,[rbx+10h]
    mov     [rsp+30h],rbx
    jmp     L1
L4:
    lea     rcx,[rcx-20h]
L5:
    mov     rbx,rcx
L6:
    mov     rdi,rbx
    call    image.sym24
    mov     rdi,rbx
    call    image.sym25
    jmp     L0
L7:
    mov     rcx,rax
    jmp     L4
    mov     r12,rax
    mov     rdi,rbx
    call    image.sym25
    mov     [rsp],r12
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
    call    image.sym15
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
L9:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0B0h]
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    lea     rsp,[rsp+10h]
    jmp     L0
L10:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-80h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rcx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L4
L11:
    ret
L12:
    ret
L13:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rbx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L6
L14:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rcx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L5

fn hashbrown::raw::RawTableInner::find_inner
    sub     rsp,0C8h
    mov     [rsp+48h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+38h],r13
    mov     [rsp+30h],r14
    mov     [rsp+28h],r15
    mov     [rsp+20h],rbp
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r8,[rdi+8]
    and     rsi,r8
    mov     r8d,0
L0:
    mov     r9,[rdi]
    lea     r9,[r9+rsi]
    test    r9,r9
    je      L7
    movdqu  xmm0,[r9]
    movq    r9,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rbx,xmm15
    mov     [rsp+50h],r9
    mov     [rsp+58h],rbx
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm1,r11d
    pshufd  xmm1,xmm1,0
    pcmpeqb xmm0,xmm1
    pmovmskb r9d,xmm0
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,rcx
    mov     r14,rdx
    mov     [rsp+18h],r8
    mov     [rsp+10h],rax
L1:
    test    r9w,r9w
    je      L4
    movzx   eax,r9w
    or      eax,10000h
    bsf     eax,eax
    lea     ecx,[r9-1]
    mov     rbp,r9
    and     ebp,ecx
    add     rax,rbx
    mov     rcx,[r12+8]
    mov     r15,rax
    and     r15,rcx
    mov     rax,[r13+20h]
    mov     rdi,r14
    mov     rsi,r15
    call    rax
    mov     rcx,rbx
    mov     rdx,r12
    mov     rsi,r13
    mov     rdi,r14
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
L2:
    test    al,al
    je      L5
    mov     eax,1
L3:
    mov     rdx,r15
    mov     rbx,[rsp+48h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+38h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+20h]
    add     rsp,0C8h
    ret
L4:
    pcmpeqb xmm0,xmm0
    mov     rax,[rsp+50h]
    mov     r15,[rsp+58h]
    movq    xmm1,rax
    movq    xmm15,r15
    punpcklqdq xmm1,xmm15
    pcmpeqb xmm1,xmm0
    pmovmskb eax,xmm1
    test    ax,ax
    je      L6
    mov     eax,0
    mov     r15d,0
    jmp     L3
L5:
    mov     rbx,rcx
    mov     r12,rdx
    mov     r13,rsi
    mov     r14,rdi
    mov     [rsp+18h],r8
    mov     [rsp+10h],r9
    mov     r9,rbp
    jmp     L1
L6:
    mov     rax,[r12+8]
    mov     rcx,[rsp+18h]
    add     rcx,10h
    add     rbx,rcx
    and     rbx,rax
    mov     rsi,rbx
    mov     rdi,r12
    mov     rax,[rsp+10h]
    mov     rdx,r14
    mov     r8,rcx
    mov     rcx,r13
    jmp     L0
L7:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
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
L9:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-130h]
    mov     r11,[rdx-0A0h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     rsi,[rsp]
    mov     rdi,[rsp+8]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+28h]
    mov     rdx,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L0
L10:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-140h]
    movzx   r11d,word ptr [rdx-32h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-18h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+30h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0B0h],r11
    mov     r9,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L1
L11:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-150h]
    movzx   r11d,byte ptr [rdx-8Bh]
    mov     [rsp],r11
    movzx   r11d,word ptr [rdx-32h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+30h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+40h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     rax,[rsp]
    mov     rbp,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+90h]
    jmp     L2
L12:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,88h
    mov     [rsp+20h],rsi
    mov     rax,[rdi+8]
    and     rsi,rax
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rsi
    mov     qword ptr [rsp+38h],0
L0:
    mov     rax,[rsp+30h]
    mov     rcx,[rdi]
    lea     rcx,[rcx+rax]
    test    rcx,rcx
    je      L8
    mov     rdx,[rcx]
    mov     rcx,[rcx+8]
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rcx
    mov     esi,[rsp+2Ch]
    mov     [rsp+10h],rdx
    mov     [rsp+18h],ecx
    mov     [rsp+1Ch],esi
    movdqu  xmm0,[rsp+10h]
    pmovmskb ecx,xmm0
    test    cx,cx
    je      L1
    movzx   ecx,cx
    or      ecx,10000h
    bsf     ecx,ecx
    mov     [rsp+1Ch],ecx
    add     rax,rcx
    mov     rcx,[rdi+8]
    and     rax,rcx
    mov     rcx,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
    mov     ecx,0
L2:
    cmp     rax,1
    je      L4
    mov     rax,[rdi+8]
    mov     rdx,[rsp+38h]
    add     rdx,10h
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+30h]
    add     rsi,rdx
    mov     [rsp+30h],rsi
    and     rsi,rax
    mov     [rsp+30h],rsi
    jmp     L0
L3:
    add     rsp,88h
    ret
L4:
    mov     rdx,[rdi]
    movzx   esi,byte ptr [rdx+rcx]
    test    sil,80h
    jne     L6
    movdqu  xmm0,[rdx]
    pmovmskb edx,xmm0
    test    dx,dx
    je      L7
    movzx   edx,dx
    or      edx,10000h
    bsf     edx,edx
    mov     rax,rdx
L5:
    jmp     L3
L6:
    mov     rax,rcx
    jmp     L5
L7:
    mov     eax,0
    jmp     L5
L8:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L9]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L9:
    .long   L10
    .long   L11
    .long   L12
L10:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-90h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     rdi,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L11:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0A0h]
    mov     r11,[rdx-70h]
    mov     [rsp],r11
    mov     r11,[rdx-68h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdi,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L2
L12:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    sub     rsp,28h
    mov     rax,[rsi]
    mov     ecx,[rsi+8]
    mov     esi,[rsi+0Ch]
    mov     [rsp+10h],rax
    mov     [rsp+18h],ecx
    mov     [rsp+1Ch],esi
    movdqu  xmm0,[rsp+10h]
    pmovmskb eax,xmm0
    test    ax,ax
    je      L2
    jmp     L1
L0:
    mov     rax,rcx
    mov     rdx,rsi
    add     rsp,28h
    ret
L1:
    movzx   eax,ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+1Ch],eax
    mov     rcx,[rdx]
    add     rcx,rax
    mov     rax,[rdi+8]
    and     rcx,rax
    mov     rsi,rcx
    mov     ecx,1
    jmp     L0
L2:
    mov     ecx,0
    mov     esi,0
    jmp     L0
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    sub     rsp,318h
    mov     [rsp+1B8h],rbx
    mov     [rsp+1B0h],r12
    mov     [rsp+1A8h],r13
    mov     [rsp+1A0h],r14
    mov     [rsp+198h],r15
    mov     [rsp+190h],rbp
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+10h],rcx
    mov     [rsp+18h],r8
    mov     r11,[rsp+328h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+320h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+68h]
    shr     r11,10h
    mov     [rsp+50h],r11
    mov     r11,[rsp+68h]
    shr     r11,20h
    mov     [rsp+58h],r11
    mov     r11,[rsp+68h]
    shr     r11,30h
    mov     [rsp+20h],r11
    mov     r11,[rsp+68h]
    shr     r11,38h
    mov     [rsp+28h],r11
    mov     r11,[rsp+60h]
    shr     r11,10h
    mov     [rsp+30h],r11
    mov     r11,[rsp+60h]
    shr     r11,20h
    mov     [rsp+38h],r11
    mov     r11,[rsp+60h]
    shr     r11,30h
    mov     [rsp+40h],r11
    mov     r11,[rsp+60h]
    shr     r11,38h
    mov     [rsp+48h],r11
    lea     rdi,[rsp+160h]
    mov     rsi,[rsp+78h]
    mov     rcx,[rsp+60h]
    mov     r8,rdx
    mov     rdx,[rsp+68h]
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+160h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+90h]
    cmp     r11,0
    jne     L14
    movzx   ecx,word ptr [rsp+168h]
    movzx   edx,word ptr [rsp+16Ah]
    movzx   esi,word ptr [rsp+16Ch]
    movzx   edi,byte ptr [rsp+16Eh]
    movzx   r8d,byte ptr [rsp+16Fh]
    movzx   r9d,word ptr [rsp+170h]
    movzx   r13d,word ptr [rsp+172h]
    movzx   r14d,word ptr [rsp+174h]
    movzx   r15d,byte ptr [rsp+176h]
    movzx   ebp,byte ptr [rsp+177h]
    mov     [rsp+170h],cx
    mov     [rsp+172h],dx
    mov     [rsp+174h],si
    mov     [rsp+176h],dil
    mov     [rsp+177h],r8b
    mov     [rsp+178h],r9w
    mov     [rsp+17Ah],r13w
    mov     [rsp+17Ch],r14w
    mov     [rsp+17Eh],r15b
    mov     [rsp+17Fh],bpl
    mov     qword ptr [rsp+168h],1
    mov     byte ptr [rsp+167h],1
    mov     rax,r13
    jmp     L3
L0:
    mov     rcx,[rsp+1D0h]
    test    rcx,rcx
    jne     L4
    mov     r11,[rsp+0C0h]
    mov     rcx,[r11+18h]
    mov     [rsp+1D8h],rcx
    mov     rdx,[rsp+208h]
    sub     rdx,rcx
    mov     [rsp+208h],rdx
    mov     r11,[rsp+0C0h]
    mov     rcx,[r11+18h]
    mov     [rsp+1D8h],rcx
    mov     [rsp+210h],rcx
    mov     r10,[rsp+0C0h]
    mov     [rsp+1D8h],r10
    lea     rsi,[rsp+1F8h]
    mov     [rsp+1D0h],rsi
    mov     r11,[rsp+0C0h]
    mov     rsi,[r11]
    mov     r11,[rsp+0C0h]
    mov     rdi,[r11+8]
    mov     r11,[rsp+0C0h]
    mov     r8,[r11+10h]
    mov     [rsp+180h],r8
    mov     r11,[rsp+0C0h]
    mov     r8,[r11+18h]
    mov     [rsp+188h],r8
    mov     r8,[rsp+1F8h]
    mov     r9,[rsp+200h]
    mov     r11,[rsp+0C0h]
    mov     [r11],r8
    mov     r11,[rsp+0C0h]
    mov     [r11+8],r9
    mov     r11,[rsp+0C0h]
    mov     [r11+10h],rdx
    mov     r11,[rsp+0C0h]
    mov     [r11+18h],rcx
    mov     [rsp+1F8h],rsi
    mov     [rsp+200h],rdi
    mov     rcx,[rsp+180h]
    mov     [rsp+208h],rcx
    mov     rcx,[rsp+188h]
    mov     [rsp+210h],rcx
    test    rdi,rdi
    jne     L1
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFFFh
    mov     edi,0FFh
    mov     r8d,0FFh
    mov     r9d,0
    mov     eax,0
    mov     r14d,0
    mov     r15d,0
    mov     ebp,0
    jmp     L3
L1:
    mov     rsi,[rsp+1E8h]
    mov     rdx,[rsp+1F0h]
    lea     rcx,[rdi+1]
    lea     rdi,[rsp+100h]
    call    qword ptr [image.fn104.slot]
    mov     rdx,[rsp+100h]
    mov     rsi,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     rdi,[rsp+1F8h]
    mov     [rsp+100h],rdi
    mov     [rsp+108h],rdi
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     [rsp+100h],rcx
    lea     rdi,[rdi+rcx]
    mov     [rsp+110h],rdi
    test    rsi,rsi
    jne     L2
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFFFh
    mov     edi,0FFh
    mov     r8d,0FFh
    mov     r9d,0
    mov     eax,0
    mov     r14d,0
    mov     r15d,0
    mov     ebp,0
    jmp     L3
L2:
    call    image.sym40
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFFFh
    mov     edi,0FFh
    mov     r8d,0FFh
    mov     r9d,0
    mov     eax,0
    mov     r14d,0
    mov     r15d,0
    mov     ebp,0
L3:
    movzx   ecx,cx
    movzx   edx,dx
    shl     rdx,10h
    or      rcx,rdx
    movzx   esi,si
    shl     rsi,20h
    or      rcx,rsi
    movzx   edi,dil
    shl     rdi,30h
    or      rcx,rdi
    movzx   r8d,r8b
    shl     r8,38h
    or      rcx,r8
    movzx   r9d,r9w
    movzx   eax,ax
    shl     rax,10h
    or      r9,rax
    movzx   r14d,r14w
    shl     r14,20h
    or      r9,r14
    movzx   r15d,r15b
    shl     r15,30h
    or      r9,r15
    movzx   ebp,bpl
    shl     rbp,38h
    mov     rdx,r9
    or      rdx,rbp
    mov     rax,rcx
    mov     rbx,[rsp+1B8h]
    mov     r12,[rsp+1B0h]
    mov     r13,[rsp+1A8h]
    mov     r14,[rsp+1A0h]
    mov     r15,[rsp+198h]
    mov     rbp,[rsp+190h]
    add     rsp,318h
    ret
L4:
    movzx   eax,word ptr [rsp+1D8h]
    test    ax,ax
    je      L6
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rsp+1D8h],ax
    mov     rax,[rsp+1C8h]
    add     rax,rcx
    mov     rcx,[rsp+1D0h]
    sub     rcx,1
    mov     [rsp+180h],rcx
    mov     [rsp+1D0h],rcx
    mov     r14,rax
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+98h]
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+0A8h]
    mov     r13,[rsp+0B0h]
    mov     r11,[rsp+0B8h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+0D8h],r11
L5:
    mov     r11,r14
    shr     r11,10h
    mov     [rsp+0E0h],r11
    mov     r11,r14
    shr     r11,20h
    mov     [rsp+0E8h],r11
    mov     r11,r14
    shr     r11,30h
    mov     [rsp+0F0h],r11
    mov     r11,r14
    shr     r11,38h
    mov     [rsp+0F8h],r11
    mov     rax,[rbp+28h]
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,r14
    call    rax
    mov     [rsp+140h],rax
    mov     rcx,[rsp+200h]
    and     rcx,rax
    mov     [rsp+148h],rcx
    mov     [rsp+130h],rcx
    mov     qword ptr [rsp+138h],0
    jmp     L7
L6:
    mov     rcx,[rsp+1C0h]
    mov     rdx,rcx
    lea     rdx,[rdx+10h]
    mov     [rsp+1C0h],rdx
    movdqu  xmm0,[rcx+10h]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+1D8h],cx
    mov     rcx,[rsp+1C8h]
    add     rcx,10h
    mov     [rsp+1C8h],rcx
    jmp     L4
L7:
    mov     rcx,[rsp+130h]
    mov     rdx,[rsp+1F8h]
    lea     rdx,[rdx+rcx]
    test    rdx,rdx
    je      L15
    mov     rsi,[rdx]
    mov     rdx,[rdx+8]
    mov     [rsp+140h],rsi
    mov     [rsp+148h],rdx
    mov     edi,[rsp+14Ch]
    mov     [rsp+120h],rsi
    mov     [rsp+128h],edx
    mov     [rsp+12Ch],edi
    movdqu  xmm0,[rsp+120h]
    pmovmskb edx,xmm0
    test    dx,dx
    je      L9
    movzx   edx,dx
    or      edx,10000h
    bsf     edx,edx
    mov     [rsp+12Ch],edx
    add     rcx,rdx
    mov     rdx,[rsp+200h]
    and     rcx,rdx
    mov     rdx,rcx
    mov     ecx,1
L8:
    cmp     rcx,1
    je      L10
    mov     rcx,[rsp+200h]
    mov     rsi,[rsp+138h]
    add     rsi,10h
    mov     [rsp+138h],rsi
    mov     rdi,[rsp+130h]
    add     rdi,rsi
    mov     [rsp+130h],rdi
    and     rdi,rcx
    mov     [rsp+130h],rdi
    jmp     L7
L9:
    mov     ecx,0
    mov     edx,0
    jmp     L8
L10:
    mov     rcx,[rsp+1F8h]
    movzx   esi,byte ptr [rcx+rdx]
    test    sil,80h
    jne     L12
    movdqu  xmm0,[rcx]
    pmovmskb ecx,xmm0
    test    cx,cx
    je      L13
    movzx   ecx,cx
    or      ecx,10000h
    bsf     ecx,ecx
L11:
    mov     rsi,[rsp+1F8h]
    mov     rdi,rax
    shr     rdi,39h
    and     rdi,7Fh
    lea     r8,[rcx-10h]
    mov     r9,[rsp+200h]
    and     r8,r9
    add     r8,10h
    mov     [rsi+rcx],dil
    mov     rsi,[rsp+1F8h]
    mov     [rsi+r8],dil
    movzx   esi,r12w
    movzx   edi,r13w
    shl     rdi,10h
    or      rsi,rdi
    movzx   edi,word ptr [rsp+0C8h]
    shl     rdi,20h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+0D0h]
    shl     rdi,30h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+0D8h]
    shl     rdi,38h
    or      rsi,rdi
    mov     rdi,[r15]
    movzx   r8d,r14w
    movzx   r9d,word ptr [rsp+0E0h]
    shl     r9,10h
    or      r8,r9
    movzx   r9d,word ptr [rsp+0E8h]
    shl     r9,20h
    or      r8,r9
    movzx   r9d,byte ptr [rsp+0F0h]
    shl     r9,30h
    or      r8,r9
    movzx   r9d,byte ptr [rsp+0F8h]
    shl     r9,38h
    or      r8,r9
    add     r8,1
    imul    r8,rsi
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     rdi,[rdi+r8]
    mov     r8,[rsp+1F8h]
    add     rcx,1
    imul    rcx,rsi
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    lea     r8,[r8+rcx]
    mov     rdx,rsi
    mov     rsi,rdi
    mov     rdi,r8
    call    ryo_hr_Memcpy
    mov     [rsp+0C0h],r15
    mov     [rsp+98h],rbp
    mov     [rsp+0A0h],rbx
    mov     [rsp+0A8h],r12
    mov     [rsp+0B0h],r13
    mov     r11,[rsp+0C8h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+0D8h]
    mov     [rsp+88h],r11
    jmp     L0
L12:
    mov     rcx,rdx
    jmp     L11
L13:
    mov     ecx,0
    jmp     L11
L14:
    mov     rax,[rsp+168h]
    mov     rcx,[rsp+170h]
    mov     rdx,[rsp+178h]
    mov     r10,[rsp+78h]
    mov     [rsp+168h],r10
    movzx   esi,word ptr [rsp+68h]
    movzx   edi,word ptr [rsp+50h]
    shl     rdi,10h
    or      rsi,rdi
    movzx   edi,word ptr [rsp+58h]
    shl     rdi,20h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+20h]
    shl     rdi,30h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+28h]
    shl     rdi,38h
    or      rsi,rdi
    mov     [rsp+170h],rsi
    movzx   edi,word ptr [rsp+60h]
    movzx   r8d,word ptr [rsp+30h]
    shl     r8,10h
    or      rdi,r8
    movzx   r8d,word ptr [rsp+38h]
    shl     r8,20h
    or      rdi,r8
    movzx   r8d,byte ptr [rsp+40h]
    shl     r8,30h
    or      rdi,r8
    movzx   r8d,byte ptr [rsp+48h]
    shl     r8,38h
    or      rdi,r8
    mov     [rsp+178h],rdi
    mov     r10,[rsp+78h]
    mov     [rsp+168h],r10
    mov     [rsp+170h],rsi
    mov     [rsp+178h],rdi
    mov     r10,[rsp+90h]
    mov     [rsp+1C0h],r10
    mov     [rsp+1C8h],rax
    mov     [rsp+1D0h],rcx
    mov     [rsp+1D8h],rdx
    mov     r10,[rsp+78h]
    mov     [rsp+1E0h],r10
    mov     [rsp+1E8h],rsi
    mov     [rsp+1F0h],rdi
    mov     r10,[rsp+90h]
    mov     [rsp+1F8h],r10
    mov     [rsp+200h],rax
    mov     [rsp+208h],rcx
    mov     [rsp+210h],rdx
    mov     r11,[rsp+70h]
    mov     rbx,[r11]
    mov     [rsp+1C0h],rbx
    mov     [rsp+1D8h],rbx
    mov     [rsp+1C8h],rbx
    mov     rax,[rbx]
    mov     rcx,[rbx+8]
    mov     rdx,rax
    shr     rdx,10h
    mov     rsi,rax
    shr     rsi,20h
    mov     rdi,rax
    shr     rdi,30h
    mov     r8,rax
    shr     r8,38h
    mov     r9,rcx
    shr     r9,20h
    mov     r12,rcx
    shr     r12,30h
    mov     r13,rcx
    shr     r13,38h
    mov     [rsp+180h],ax
    mov     [rsp+182h],dx
    mov     [rsp+184h],si
    mov     [rsp+186h],dil
    mov     [rsp+187h],r8b
    mov     [rsp+188h],ecx
    mov     [rsp+18Ch],r9w
    mov     [rsp+18Eh],r12b
    mov     [rsp+18Fh],r13b
    movdqu  xmm0,[rsp+180h]
    pmovmskb eax,xmm0
    mov     rcx,rax
    mov     [rsp+1CCh],ecx
    mov     [rsp+1D0h],ax
    lea     rdi,[rsp+310h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+1D2h]
    mov     [rsp+1D4h],ax
    mov     [rsp+1D6h],ax
    mov     r11,[rsp+70h]
    mov     rcx,[r11+18h]
    mov     [rsp+1C8h],rcx
    mov     [rsp+158h],ax
    mov     [rsp+1C0h],rbx
    mov     qword ptr [rsp+1C8h],0
    mov     [rsp+1D0h],rcx
    mov     rax,[rsp+158h]
    mov     [rsp+1D8h],rax
    mov     r11,[rsp+70h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+88h],r11
    jmp     L0
L15:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+1E0h]
    lea     rsi,[rsp+1F8h]
    call    qword ptr [image.fn71.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+310h]
    mov     esi,0FFFFFCF0h
    call    ryo_h_Resume
    ud2
    call    sym9
    ud2
  ; OSR entries
    lea     r11,[L16]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L16:
    .long   L17
    .long   L18
    .long   L19
    .long   L20
    .long   L21
    .long   L22
L17:
    pop     rcx
    lea     rdx,[rsp+280h]
    lea     rsp,[rdx-390h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    movzx   r11d,word ptr [rdx-50h]
    mov     [rsp+18h],r11
    movzx   r11d,word ptr [rdx-4Eh]
    mov     [rsp+20h],r11
    movzx   r11d,word ptr [rdx-4Ch]
    mov     [rsp+28h],r11
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+30h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-240h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-238h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-1E0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-1D8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-1D0h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-1C8h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+70h],r11
    mov     [rdx-158h],rbx
    mov     [rdx-160h],r12
    mov     [rdx-168h],r13
    mov     [rdx-170h],r14
    mov     [rdx-178h],r15
    mov     [rdx-180h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp]
    mov     [rdx-250h],r11
    mov     r11,[rsp+8]
    mov     [rdx-278h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-260h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-258h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-290h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-288h],r11
    lea     rsp,[rsp+80h]
    jmp     L0
L18:
    pop     rcx
    lea     rdx,[rsp+280h]
    lea     rsp,[rdx-390h]
    mov     r11,[rdx-158h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    movzx   r11d,word ptr [rdx-50h]
    mov     [rsp+20h],r11
    movzx   r11d,word ptr [rdx-4Eh]
    mov     [rsp+28h],r11
    movzx   r11d,word ptr [rdx-4Ch]
    mov     [rsp+30h],r11
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+38h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-240h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-238h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-1E0h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-1D8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-1D0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-1C8h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+78h],r11
    mov     [rdx-158h],rbx
    mov     [rdx-160h],r12
    mov     [rdx-168h],r13
    mov     [rdx-170h],r14
    mov     [rdx-178h],r15
    mov     [rdx-180h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-238h],r11
    mov     r14,[rsp]
    mov     r15,[rsp+8]
    mov     rbp,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+28h]
    lea     rsp,[rsp+80h]
    jmp     L5
L19:
    ret
L20:
    ret
L21:
    ret
L22:
    ret

fn main
    sub     rsp,738h
    mov     [rsp+1F0h],rbx
    mov     [rsp+1E8h],r12
    mov     [rsp+1E0h],r13
    mov     [rsp+1D8h],r14
    mov     [rsp+1D0h],r15
    mov     [rsp+1C8h],rbp
    mov     qword ptr [rsp+218h],50910h
    lea     rax,[image.k400]
    mov     [rsp+708h],rax
    mov     qword ptr [rsp+710h],0
    mov     qword ptr [rsp+718h],0
    mov     qword ptr [rsp+720h],0
    mov     qword ptr [rsp+6D0h],0
    mov     qword ptr [rsp+6D8h],50910h
    mov     eax,1
L0:
    mov     rcx,[rsp+6D0h]
    mov     rdx,[rsp+6D8h]
    cmp     rcx,rdx
    jae     L1
    lea     rdx,[rcx+1]
    mov     [rsp+6D0h],rdx
    mov     [rsp+10h],rcx
    mov     ecx,1
    jmp     L2
L1:
    mov     ecx,0
L2:
    test    rcx,rcx
    je      L25
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+218h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rax,r10
    mov     r10,14057B7EF767814Fh
    mov     [rsp+218h],r10
    mov     r11,rax
    mov     r10,14057B7EF767814Fh
    add     r11,r10
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+21Ch],2Ch
    mov     rax,[rsp+18h]
    shr     rax,2Ch
    mov     [rsp+78h],rax
    lea     rsi,[rsp+728h]
    lea     rdi,[rsp+28h]
    call    image.fn167
    mov     rax,[rsp+78h]
    mov     [rsp+20h],rax
    lea     rsi,[rsp+20h]
    lea     rdi,[rsp+28h]
    mov     edx,8
    call    qword ptr [image.fn172.slot]
    lea     rdi,[rsp+28h]
    call    qword ptr [image.fn177.slot]
    mov     r13,rax
    lea     rax,[rsp+78h]
    mov     [rsp+70h],rax
    mov     rax,r13
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[rsp+710h]
    and     rcx,r13
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    mov     eax,0
L3:
    mov     rdx,[rsp+708h]
    lea     rdx,[rdx+rcx]
    test    rdx,rdx
    je      L45
    movdqu  xmm1,[rdx]
    movdqa  xmm2,xmm1
    pcmpeqb xmm2,xmm0
    pmovmskb edx,xmm2
L4:
    test    dx,dx
    je      L6
    movzx   esi,dx
    or      esi,10000h
    bsf     esi,esi
    lea     edi,[rdx-1]
    and     edx,edi
    add     rsi,rcx
    mov     rdi,[rsp+710h]
    and     rsi,rdi
    mov     rdi,[rsp+708h]
    mov     r8d,0
    sub     r8,rsi
    mov     r11,r8
    imul    r11,10h
    add     r11,rdi
    mov     rdi,r11
    mov     r8,[rsp+70h]
    mov     rdi,[rdi-10h]
    mov     r8,[r8]
    cmp     rdi,r8
    jne     L7
    mov     rdi,rsi
    mov     esi,1
L5:
    test    rsi,rsi
    je      L9
    mov     rsi,[rsp+708h]
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     r11,rdi
    imul    r11,10h
    add     r11,rsi
    mov     rsi,r11
    jmp     L10
L6:
    pcmpeqb xmm2,xmm2
    pcmpeqb xmm2,xmm1
    pmovmskb esi,xmm2
    test    si,si
    je      L8
    mov     esi,0
    mov     edi,0
    jmp     L5
L7:
    jmp     L4
L8:
    mov     rdx,[rsp+710h]
    add     rax,10h
    add     rcx,rax
    and     rcx,rdx
    jmp     L3
L9:
    mov     esi,0
L10:
    test    rsi,rsi
    je      L11
    lea     rax,[rsp+708h]
    mov     ecx,0
    jmp     L13
L11:
    mov     rax,[rsp+718h]
    cmp     rax,1
    jae     L12
    lea     rdi,[rsp+708h]
    lea     rdx,[rsp+728h]
    mov     esi,1
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [image.fn13.slot]
L12:
    mov     rax,[rsp+78h]
    lea     rcx,[rsp+708h]
    mov     rsi,r13
L13:
    test    rcx,rcx
    je      L15
L14:
    mov     [rsp+670h],rcx
    mov     [rsp+678h],rsi
    mov     [rsp+680h],rax
    mov     edx,[rsp+67Ch]
    mov     [rsp+208h],rcx
    mov     [rsp+210h],esi
    mov     [rsp+214h],edx
    mov     [rsp+218h],rax
    mov     qword ptr [rsp+200h],0
    mov     rdx,[rsp+210h]
    test    rcx,rcx
    je      L24
    mov     rdi,rax
    shr     rdi,20h
    mov     r8,rax
    shr     r8,30h
    mov     r9,rax
    shr     r9,38h
    mov     [rsp+0A0h],rdx
    mov     r13,[rcx+8]
    and     r13,rdx
    mov     [rsp+0A8h],r13
    mov     [rsp+90h],r13
    mov     qword ptr [rsp+98h],0
    jmp     L16
L15:
    mov     ecx,0
    jmp     L14
L16:
    mov     rsi,[rsp+90h]
    mov     r13,[rcx]
    lea     r13,[r13+rsi]
    test    r13,r13
    je      L46
    mov     r14,[r13]
    mov     r13,[r13+8]
    mov     [rsp+0A0h],r14
    mov     [rsp+0A8h],r13
    mov     r15d,[rsp+0ACh]
    mov     [rsp+80h],r14
    mov     [rsp+88h],r13d
    mov     [rsp+8Ch],r15d
    movdqu  xmm0,[rsp+80h]
    pmovmskb r13d,xmm0
    test    r13w,r13w
    je      L18
    movzx   r13d,r13w
    or      r13d,10000h
    bsf     r13d,r13d
    mov     [rsp+8Ch],r13d
    add     rsi,r13
    mov     r13,[rcx+8]
    and     rsi,r13
    mov     r13,rsi
    mov     esi,1
L17:
    cmp     rsi,1
    je      L19
    mov     rsi,[rcx+8]
    mov     r14,[rsp+98h]
    add     r14,10h
    mov     [rsp+98h],r14
    mov     r15,[rsp+90h]
    add     r15,r14
    mov     [rsp+90h],r15
    and     r15,rsi
    mov     [rsp+90h],r15
    jmp     L16
L18:
    mov     esi,0
    mov     r13d,0
    jmp     L17
L19:
    mov     rsi,[rcx]
    movzx   r14d,byte ptr [rsi+r13]
    test    r14b,80h
    jne     L21
    movdqu  xmm0,[rsi]
    pmovmskb esi,xmm0
    test    si,si
    je      L22
    movzx   esi,si
    or      esi,10000h
    bsf     esi,esi
L20:
    mov     r14,[rcx]
    movzx   r15d,byte ptr [r14+rsi]
    mov     rbp,rdx
    shr     rbp,39h
    and     rbp,7Fh
    lea     rbx,[rsi-10h]
    mov     r12,[rcx+8]
    and     rbx,r12
    add     rbx,10h
    mov     [r14+rsi],bpl
    mov     r12,[rcx]
    mov     [r12+rbx],bpl
    mov     rbx,[rcx]
    mov     r11d,0
    sub     r11,rsi
    mov     rsi,r11
    mov     r11,rsi
    imul    r11,10h
    add     r11,rbx
    mov     rbx,r11
    and     r15d,1
    test    r15b,r15b
    setne   sil
    movzx   esi,sil
    mov     r12,[rcx+10h]
    sub     r12,rsi
    mov     [rcx+10h],r12
    mov     [rbx-10h],eax
    mov     [rbx-0Ch],di
    mov     [rbx-0Ah],r8b
    mov     [rbx-9],r9b
    mov     dword ptr [rbx-8],0
    mov     word ptr [rbx-4],0
    mov     byte ptr [rbx-2],0
    mov     byte ptr [rbx-1],0
    mov     rsi,[rcx+18h]
    add     rsi,1
    mov     [rcx+18h],rsi
    lea     rbx,[rbx-8]
    jmp     L23
L21:
    mov     rsi,r13
    jmp     L20
L22:
    mov     esi,0
    jmp     L20
L23:
    mov     rax,[rbx]
    mov     [rsp+218h],rax
    add     rax,[rsp+10h]
    jb      L49
    mov     [rbx],rax
    mov     rax,[rsp+18h]
    jmp     L0
L24:
    lea     rdx,[rdx-8]
    mov     rbx,rdx
    jmp     L23
L25:
    mov     qword ptr [rsp+128h],0
    mov     qword ptr [rsp+130h],0
    mov     dword ptr [rsp+21Ch],14h
    mov     qword ptr [rsp+218h],1
    mov     qword ptr [rsp+218h],2
    lea     rdi,[rsp+5F0h]
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [fn14.slot]
    mov     rax,[rsp+5F0h]
    mov     rcx,[rsp+5F8h]
    mov     [rsp+200h],rax
    mov     [rsp+208h],rcx
    mov     edx,[rsp+600h]
    mov     esi,[rsp+604h]
    mov     edi,[rsp+608h]
    mov     r8d,[rsp+60Ch]
    mov     [rsp+210h],edx
    mov     [rsp+214h],esi
    mov     [rsp+218h],edi
    mov     [rsp+21Ch],r8d
    mov     rdx,[rsp+210h]
    mov     rsi,[rsp+218h]
    mov     [rsp+610h],rax
    mov     [rsp+618h],rcx
    mov     [rsp+620h],rdx
    mov     [rsp+628h],rsi
    mov     [rsp+5B0h],rax
    mov     [rsp+5B8h],rcx
    mov     [rsp+5C0h],rdx
    mov     [rsp+5C8h],rsi
L26:
    mov     rax,[rsp+5C0h]
    add     rax,1
    test    rax,rax
    je      L47
    mov     rcx,[rsp+5B8h]
    test    rcx,rcx
    jbe     L27
    mov     rdx,[rsp+5B0h]
    add     rax,rdx
    mov     [rsp+5B0h],rax
    sub     rcx,1
    mov     [rsp+5B8h],rcx
    mov     eax,1
    jmp     L28
L27:
    mov     eax,0
    mov     edx,0
L28:
    test    rax,rax
    je      L40
    mov     [rsp+588h],rdx
    mov     rax,[rsp+720h]
    test    rax,rax
    jne     L29
    mov     eax,0
    jmp     L38
L29:
    lea     rsi,[rsp+728h]
    lea     rdi,[rsp+0B8h]
    call    image.fn167
    mov     rax,[rsp+588h]
    mov     [rsp+0B0h],rax
    lea     rsi,[rsp+0B0h]
    lea     rdi,[rsp+0B8h]
    mov     edx,8
    call    qword ptr [image.fn172.slot]
    lea     rdi,[rsp+0B8h]
    call    qword ptr [image.fn177.slot]
    lea     rcx,[rsp+588h]
    mov     [rsp+100h],rcx
    mov     rcx,rax
    shr     rcx,39h
    and     rcx,7Fh
    mov     rdx,[rsp+710h]
    and     rax,rdx
    movzx   r11d,cl
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    mov     ecx,0
L30:
    mov     rdx,[rsp+708h]
    lea     rdx,[rdx+rax]
    test    rdx,rdx
    je      L48
    movdqu  xmm1,[rdx]
    movdqa  xmm2,xmm1
    pcmpeqb xmm2,xmm0
    pmovmskb edx,xmm2
L31:
    test    dx,dx
    je      L33
    movzx   esi,dx
    or      esi,10000h
    bsf     esi,esi
    lea     edi,[rdx-1]
    and     edx,edi
    add     rsi,rax
    mov     rdi,[rsp+710h]
    and     rsi,rdi
    mov     rdi,[rsp+708h]
    mov     r8d,0
    sub     r8,rsi
    mov     r11,r8
    imul    r11,10h
    add     r11,rdi
    mov     rdi,r11
    mov     r8,[rsp+100h]
    mov     r8,[r8]
    mov     rdi,[rdi-10h]
    cmp     r8,rdi
    jne     L34
    mov     rdi,rsi
    mov     esi,1
L32:
    test    rsi,rsi
    je      L36
    mov     rsi,[rsp+708h]
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     r11,rdi
    imul    r11,10h
    add     r11,rsi
    mov     rsi,r11
    jmp     L37
L33:
    pcmpeqb xmm2,xmm2
    pcmpeqb xmm2,xmm1
    pmovmskb esi,xmm2
    test    si,si
    je      L35
    mov     esi,0
    mov     edi,0
    jmp     L32
L34:
    jmp     L31
L35:
    mov     rdx,[rsp+710h]
    add     rcx,10h
    add     rax,rcx
    and     rax,rdx
    jmp     L30
L36:
    mov     esi,0
L37:
    test    rsi,rsi
    jne     L39
    mov     eax,0
L38:
    test    rax,rax
    je      L26
    mov     qword ptr [rsp+218h],1
    mov     rcx,[rsp+128h]
    add     rcx,1
    jb      L50
    mov     [rsp+128h],rcx
    mov     rcx,[rsp+130h]
    mov     rax,[rax]
    add     rcx,rax
    mov     [rsp+130h],rcx
    jmp     L26
L39:
    lea     rsi,[rsi-8]
    mov     rax,rsi
    jmp     L38
L40:
    lea     rdi,[rsp+708h]
    mov     rax,[rsp+720h]
    mov     [rsp+140h],rax
    call    qword ptr [image.fn4.slot]
    lea     rsi,[rsp+708h]
    lea     rdi,[rsp+4F0h]
    call    qword ptr [fn23.slot]
    mov     rax,[rsp+4F0h]
    mov     rcx,[rsp+4F8h]
    mov     [rsp+1F8h],rax
    mov     [rsp+200h],rcx
    mov     rax,[rsp+500h]
    mov     ecx,[rsp+508h]
    mov     edx,[rsp+50Ch]
    mov     [rsp+208h],rax
    mov     [rsp+210h],ecx
    mov     [rsp+214h],edx
    mov     rax,[rsp+510h]
    mov     [rsp+218h],rax
    lea     rdi,[rsp+1F8h]
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+148h],rax
    lea     rax,[image.k400]
    mov     [rsp+4C8h],rax
    mov     qword ptr [rsp+4D0h],0
    mov     qword ptr [rsp+4D8h],0
    mov     qword ptr [rsp+4E0h],0
    mov     r10,1FBD000000000h
    mov     [rsp+4B0h],r10
L41:
    mov     eax,[rsp+4B0h]
    mov     ecx,[rsp+4B4h]
    cmp     eax,ecx
    jae     L42
    lea     ecx,[rax+1]
    mov     [rsp+4B0h],ecx
    mov     rcx,rax
    mov     eax,1
    jmp     L43
L42:
    mov     eax,0
L43:
    mov     eax,eax
    test    rax,rax
    je      L44
    mov     dword ptr [rsp+21Ch],138Bh
    mov     eax,ecx
    mov     [rsp+218h],rax
    mov     r10d,0D196E5F5h
    imul    rax,r10
    mov     [rsp+218h],rax
    shr     rax,2Ch
    mov     [rsp+218h],rax
    mov     [rsp+214h],eax
    imul    eax,138Bh
    mov     [rsp+214h],eax
    sub     ecx,eax
    mov     [rsp+404h],ecx
    lea     rax,[rsp+404h]
    mov     rcx,[image.sym2]
    mov     [rsp+3E0h],rax
    mov     [rsp+3E8h],rcx
    mov     [rsp+3F0h],rax
    mov     [rsp+3F8h],rcx
    lea     rsi,[k32]
    lea     rdx,[rsp+3F0h]
    lea     rdi,[rsp+108h]
    call    image.sym26
    mov     rax,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     rdx,[rsp+118h]
    mov     [rsp+428h],rax
    mov     [rsp+430h],rcx
    mov     [rsp+438h],rdx
    mov     esi,[rsp+434h]
    mov     [rsp+208h],rax
    mov     [rsp+210h],ecx
    mov     [rsp+214h],esi
    mov     [rsp+218h],rdx
    lea     rcx,[rsp+208h]
    mov     rsi,[rsp+210h]
    mov     [rsp+440h],rax
    mov     [rsp+448h],rsi
    mov     [rsp+450h],rdx
    mov     edi,[rsp+44Ch]
    mov     [rsp+208h],rax
    mov     [rsp+210h],esi
    mov     [rsp+214h],edi
    mov     [rsp+218h],rdx
    lea     rdi,[rsp+460h]
    lea     rsi,[rsp+4C8h]
    mov     rdx,rcx
    call    qword ptr [fn36.slot]
    mov     rax,[rsp+460h]
    mov     rcx,[rsp+468h]
    mov     [rsp+1F8h],rax
    mov     [rsp+200h],rcx
    mov     rax,[rsp+470h]
    mov     ecx,[rsp+478h]
    mov     edx,[rsp+47Ch]
    mov     [rsp+208h],rax
    mov     [rsp+210h],ecx
    mov     [rsp+214h],edx
    mov     rax,[rsp+480h]
    mov     [rsp+218h],rax
    lea     rdi,[rsp+1F8h]
    call    qword ptr [fn37.slot]
    mov     rcx,[rax]
    mov     [rsp+218h],rcx
    mov     qword ptr [rsp+210h],1
    add     rcx,1
    jb      L51
    mov     [rax],rcx
    jmp     L41
L44:
    mov     rax,[rsp+720h]
    mov     [rsp+150h],rax
    lea     rax,[rsp+150h]
    mov     rcx,[rsp+4E0h]
    mov     [rsp+158h],rcx
    lea     rcx,[rsp+158h]
    lea     rdx,[rsp+140h]
    lea     rsi,[rsp+128h]
    lea     rdi,[rsp+130h]
    lea     r8,[rsp+148h]
    mov     r9,[image.sym1]
    mov     rbx,[image.sym3]
    mov     [rsp+160h],rdx
    mov     [rsp+168h],r9
    mov     [rsp+170h],rsi
    mov     [rsp+178h],rbx
    mov     [rsp+180h],rdi
    mov     [rsp+188h],rbx
    mov     [rsp+190h],rax
    mov     [rsp+198h],r9
    mov     [rsp+1A0h],r8
    mov     [rsp+1A8h],rbx
    mov     [rsp+1B0h],rcx
    mov     [rsp+1B8h],r9
    lea     rdi,[k47]
    lea     rsi,[rsp+160h]
    call    sym49
    lea     rdi,[rsp+4C8h]
    mov     [rsp+218h],rdi
    lea     rsi,[rsp+4E8h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn20.slot]
    lea     rdi,[rsp+708h]
    mov     [rsp+218h],rdi
    lea     rsi,[rsp+728h]
    mov     edx,10h
    mov     ecx,10h
    call    qword ptr [image.fn21.slot]
    mov     rbx,[rsp+1F0h]
    mov     r12,[rsp+1E8h]
    mov     r13,[rsp+1E0h]
    mov     r14,[rsp+1D8h]
    mov     r15,[rsp+1D0h]
    mov     rbp,[rsp+1C8h]
    add     rsp,738h
    ret
L45:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L46:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L47:
    lea     rcx,[image.k5048]
    lea     rdi,[image.k3410]
    mov     esi,1A3h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L48:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     r12,rax
    jmp     L53
L49:
    lea     rdi,[k12]
    mov     [rsp+218h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L53
    mov     r12,rax
    jmp     L53
    mov     r12,rax
    jmp     L53
L50:
    lea     rdi,[k19]
    mov     [rsp+218h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L53
    mov     r12,rax
    jmp     L53
    mov     r12,rax
    jmp     L53
    mov     r12,rax
    jmp     L53
    mov     rbx,rax
    jmp     L55
    mov     rbx,rax
    jmp     L55
    mov     rbx,rax
    jmp     L55
L51:
    lea     rdi,[k38]
    mov     [rsp+218h],rdi
    call    sym13
    ud2
    mov     rbx,rax
    jmp     L55
    mov     rbx,rax
    jmp     L55
    mov     r12,rax
    jmp     L53
L52:
    lea     rdi,[rsp+4C8h]
    mov     [rsp+218h],rdi
    lea     rsi,[rsp+4E8h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn20.slot]
    mov     r12,rbx
    jmp     L53
    jmp     L54
L53:
    lea     rdi,[rsp+708h]
    mov     [rsp+218h],rdi
    lea     rsi,[rsp+728h]
    mov     edx,10h
    mov     ecx,10h
    call    qword ptr [image.fn21.slot]
    mov     [rsp],r12
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFF8D0h
    call    ryo_h_Resume
    ud2
L54:
    call    sym54
    ud2
L55:
    jmp     L52
  ; OSR entries
    lea     r11,[L56]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L56:
    .long   L57
    .long   L58
    .long   L59
    .long   L60
    .long   L61
    .long   L62
L57:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-7D0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-460h]
    mov     [rsp+8],r11
    mov     r11,[rdx-458h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-420h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-418h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-410h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-408h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3D8h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-3C0h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-218h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-200h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-100h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+90h],r11
    mov     [rdx-540h],rbx
    mov     [rdx-548h],r12
    mov     [rdx-550h],r13
    mov     [rdx-558h],r14
    mov     [rdx-560h],r15
    mov     [rdx-568h],rbp
    mov     r11,[rsp+8]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-608h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+0A0h]
    jmp     L0
L58:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-7C0h]
    mov     r11,[rdx-460h]
    mov     [rsp],r11
    mov     r11,[rdx-458h]
    mov     [rsp+8],r11
    mov     r11,[rdx-450h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-420h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-418h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-410h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-408h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-3D8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3C0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-218h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-200h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-100h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+88h],r11
    mov     [rdx-540h],rbx
    mov     [rdx-548h],r12
    mov     [rdx-550h],r13
    mov     [rdx-558h],r14
    mov     [rdx-560h],r15
    mov     [rdx-568h],rbp
    mov     r11,[rsp]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-608h],r11
    lea     rsp,[rsp+90h]
    jmp     L26
L59:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-7C0h]
    mov     r11,[rdx-460h]
    mov     [rsp],r11
    mov     r11,[rdx-458h]
    mov     [rsp+8],r11
    mov     r11,[rdx-450h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-420h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-418h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-410h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-408h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-3D8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3C0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-218h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-200h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-100h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+88h],r11
    mov     [rdx-540h],rbx
    mov     [rdx-548h],r12
    mov     [rdx-550h],r13
    mov     [rdx-558h],r14
    mov     [rdx-560h],r15
    mov     [rdx-568h],rbp
    mov     r11,[rsp]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-608h],r11
    lea     rsp,[rsp+90h]
    jmp     L41
L60:
    ret
L61:
    ret
L62:
    ret

fn main::{closure#0}
    mov     rax,[rsi]
    mov     r11d,3
    mov     rax,rax
    xor     edx,edx
    div     r11
    test    rdx,rdx
    setne   al
    movzx   eax,al
    ret

fn std::arch::x86_64::__m128i::as_i8x16
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    ret

fn std::arch::x86_64::_mm_cmpeq_epi8
    movdqu  xmm0,[rsi]
    movdqu  xmm1,[rdx]
    pcmpeqb xmm0,xmm1
    movdqu  [rdi],xmm0
    mov     rax,rdi
    ret

fn std::arch::x86_64::_mm_loadu_si128
    sub     rsp,18h
    test    rsi,rsi
    je      L0
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    add     rsp,18h
    ret
L0:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2

fn std::arch::x86_64::_mm_movemask_epi8
    movdqu  xmm0,[rdi]
    pmovmskb eax,xmm0
    ret

fn std::arch::x86_64::_mm_set1_epi8
    movzx   r11d,sil
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    movq    rax,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rcx,xmm15
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    ret

fn std::collections::HashMap::<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::entry
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,168h
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rdx,[rdx+10h]
    mov     [rsp+148h],rax
    mov     [rsp+150h],rcx
    mov     [rsp+158h],rdx
    mov     r11,r12
    lea     r11,[r11+20h]
    mov     [rsp+40h],r11
    lea     rdi,[rsp+78h]
    call    qword ptr [image.fn168.slot]
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     rdx,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+98h]
    mov     r8,[rsp+0A0h]
    mov     r9,[rsp+0A8h]
    mov     r14,[rsp+0B0h]
    mov     r15,[rsp+0B8h]
    mov     [rsp+0F8h],rax
    mov     [rsp+100h],rcx
    mov     [rsp+108h],rdx
    mov     [rsp+110h],rsi
    mov     [rsp+118h],rdi
    mov     [rsp+120h],r8
    mov     [rsp+128h],r9
    mov     [rsp+130h],r14
    mov     [rsp+138h],r15
    mov     rsi,[rsp+150h]
    mov     rdx,[rsp+158h]
    lea     rdi,[rsp+0F8h]
    call    image.fn176
    mov     byte ptr [rsp+0CFh],0FFh
    lea     rsi,[rsp+0CFh]
    lea     rdi,[rsp+0F8h]
    mov     edx,1
    call    image.fn176
    mov     rax,[rsp+0F8h]
    mov     [rsp+0D0h],rax
    mov     rcx,[rsp+100h]
    mov     [rsp+0D8h],rcx
    mov     rdx,[rsp+108h]
    mov     [rsp+0E0h],rdx
    mov     rsi,[rsp+110h]
    mov     [rsp+0E8h],rsi
    mov     rdi,[rsp+128h]
    and     rdi,0FFh
    shl     rdi,38h
    mov     r8,[rsp+130h]
    or      rdi,r8
    xor     rsi,rdi
    mov     [rsp+0E8h],rsi
    lea     r8,[rsp+0D0h]
    add     rax,rdx
    mov     [rsp+0D0h],rax
    add     rcx,rsi
    mov     [rsp+0D8h],rcx
    mov     r9,rdx
    shl     r9,0Dh
    shr     rdx,33h
    or      r9,rdx
    mov     [rsp+0E0h],r9
    xor     r9,rax
    mov     [rsp+0E0h],r9
    mov     rdx,rsi
    shl     rdx,10h
    shr     rsi,30h
    or      rdx,rsi
    mov     [rsp+0E8h],rdx
    xor     rdx,rcx
    mov     [rsp+0E8h],rdx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    mov     [rsp+0D0h],rsi
    add     rcx,r9
    mov     [rsp+0D8h],rcx
    add     rsi,rdx
    mov     [rsp+0D0h],rsi
    mov     rax,r9
    shl     rax,11h
    shr     r9,2Fh
    or      rax,r9
    mov     [rsp+0E0h],rax
    xor     rax,rcx
    mov     [rsp+0E0h],rax
    mov     rax,rdx
    shl     rax,15h
    shr     rdx,2Bh
    or      rax,rdx
    mov     [rsp+0E8h],rax
    xor     rax,rsi
    mov     [rsp+0E8h],rax
    mov     rax,rcx
    shl     rax,20h
    shr     rcx,20h
    or      rax,rcx
    mov     [rsp+0D8h],rax
    xor     rsi,rdi
    mov     [rsp+0D0h],rsi
    xor     rax,0FFh
    mov     [rsp+0D8h],rax
    mov     rdi,r8
    call    image.fn188
    mov     rax,[rsp+0D0h]
    mov     rcx,[rsp+0E0h]
    xor     rax,rcx
    mov     rcx,[rsp+0D8h]
    xor     rax,rcx
    mov     rcx,[rsp+0E8h]
    mov     r11,rax
    xor     r11,rcx
    mov     [rsp+48h],r11
    lea     rax,[rsp+148h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+48h]
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[r12+8]
    and     rcx,[rsp+48h]
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm14,r11d
    pshufd  xmm14,xmm14,0
    movdqu  [rsp+20h],xmm14
    mov     r15,rcx
    mov     ebp,0
L0:
    mov     rax,[r12]
    lea     rax,[rax+r15]
    test    rax,rax
    je      L15
    movdqu  xmm14,[rax]
    movdqu  [rsp+30h],xmm14
    movdqu  xmm0,[rsp+30h]
    movdqu  xmm15,[rsp+20h]
    pcmpeqb xmm0,xmm15
    pmovmskb eax,xmm0
L1:
    test    ax,ax
    je      L5
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    mov     r13,rax
    and     r13d,edx
    lea     rax,[r15+rcx]
    mov     rcx,[r12+8]
    mov     r14,rax
    and     r14,rcx
    mov     rax,[r12]
    mov     ecx,0
    sub     rcx,r14
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+140h]
    mov     rdx,[rax-18h]
    mov     rax,[rax-10h]
    mov     rsi,[rcx+8]
    mov     rcx,[rcx+10h]
    cmp     rax,rcx
    jne     L2
    mov     [rsp+58h],rax
    mov     [rsp+68h],rdx
    mov     [rsp],rsi
    lea     rdi,[rsp+190h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym41]
    mov     eax,[rsp+64h]
    test    eax,eax
    sete    al
    jmp     L3
L2:
    mov     eax,0
L3:
    test    al,al
    je      L6
    mov     eax,1
L4:
    test    rax,rax
    je      L8
    mov     rax,[r12]
    mov     ecx,0
    sub     rcx,r14
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     r13,rax
    jmp     L9
L5:
    pcmpeqb xmm0,xmm0
    movdqu  xmm15,[rsp+30h]
    pcmpeqb xmm0,xmm15
    pmovmskb eax,xmm0
    test    ax,ax
    je      L7
    mov     eax,0
    mov     r14d,0
    jmp     L4
L6:
    mov     rax,r13
    jmp     L1
L7:
    mov     rax,[r12+8]
    add     rbp,10h
    add     r15,rbp
    and     r15,rax
    jmp     L0
L8:
    mov     r13d,0
L9:
    test    r13,r13
    je      L10
    lea     rdi,[rsp+148h]
    call    image.sym24
    lea     rdi,[rsp+148h]
    call    image.sym25
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L12
L10:
    mov     rax,[r12+10h]
    cmp     rax,1
    jae     L11
    mov     rdi,r12
    mov     esi,1
    mov     rdx,[rsp+40h]
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [image.fn10.slot]
L11:
    mov     rax,[rsp+148h]
    mov     rcx,[rsp+150h]
    mov     rdx,[rsp+158h]
    mov     r13,rcx
    mov     rcx,r12
    mov     r12,rdx
    mov     rdx,[rsp+48h]
L12:
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L14
L13:
    mov     [rbx],rax
    mov     [rbx+8],r13
    mov     [rbx+10h],r12
    mov     [rbx+18h],rcx
    mov     [rbx+20h],rdx
    mov     rax,rbx
    add     rsp,168h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L14:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L13
L15:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+148h]
    call    image.sym25
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE80h
    call    ryo_h_Resume
    ud2
    call    image.sym15
    ud2
    mov     rbx,rax
    jmp     L17
    mov     rbx,rax
    jmp     L17
L16:
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE80h
    call    ryo_h_Resume
    ud2
    call    image.sym15
    ud2
L17:
    lea     rdi,[rsp+148h]
    call    qword ptr [image.fn45.slot]
    jmp     L16
  ; OSR entries
    lea     r11,[L18]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L18:
    .long   L19
L19:
    ret

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::entry
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,0A8h
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+98h],rdx
    mov     r13,r12
    lea     r13,[r13+20h]
    lea     rdi,[rsp+48h]
    mov     rsi,r13
    call    qword ptr [image.fn167.slot]
    mov     rax,[rsp+98h]
    mov     [rsp+10h],rax
    lea     rsi,[rsp+10h]
    lea     rdi,[rsp+48h]
    mov     edx,8
    call    image.fn176
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    mov     rcx,[rsp+50h]
    mov     [rsp+28h],rcx
    mov     rdx,[rsp+58h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+78h]
    and     rdi,0FFh
    shl     rdi,38h
    mov     r8,[rsp+80h]
    or      rdi,r8
    xor     rsi,rdi
    mov     [rsp+38h],rsi
    lea     r8,[rsp+20h]
    add     rax,rdx
    mov     [rsp+20h],rax
    add     rcx,rsi
    mov     [rsp+28h],rcx
    mov     r9,rdx
    shl     r9,0Dh
    shr     rdx,33h
    or      r9,rdx
    mov     [rsp+30h],r9
    xor     r9,rax
    mov     [rsp+30h],r9
    mov     rdx,rsi
    shl     rdx,10h
    shr     rsi,30h
    or      rdx,rsi
    mov     [rsp+38h],rdx
    xor     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    mov     [rsp+20h],rsi
    add     rcx,r9
    mov     [rsp+28h],rcx
    add     rsi,rdx
    mov     [rsp+20h],rsi
    mov     rax,r9
    shl     rax,11h
    shr     r9,2Fh
    or      rax,r9
    mov     [rsp+30h],rax
    xor     rax,rcx
    mov     [rsp+30h],rax
    mov     rax,rdx
    shl     rax,15h
    shr     rdx,2Bh
    or      rax,rdx
    mov     [rsp+38h],rax
    xor     rax,rsi
    mov     [rsp+38h],rax
    mov     rax,rcx
    shl     rax,20h
    shr     rcx,20h
    or      rax,rcx
    mov     [rsp+28h],rax
    xor     rsi,rdi
    mov     [rsp+20h],rsi
    xor     rax,0FFh
    mov     [rsp+28h],rax
    mov     rdi,r8
    call    image.fn188
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+30h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rcx,[rsp+38h]
    mov     r14,rax
    xor     r14,rcx
    lea     rax,[rsp+98h]
    mov     [rsp+90h],rax
    mov     rax,r14
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[r12+8]
    and     rcx,r14
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    mov     eax,0
L0:
    mov     rdx,[r12]
    lea     rdx,[rdx+rcx]
    test    rdx,rdx
    je      L13
    movdqu  xmm1,[rdx]
    movdqa  xmm2,xmm1
    pcmpeqb xmm2,xmm0
    pmovmskb edx,xmm2
L1:
    test    dx,dx
    je      L3
    movzx   esi,dx
    or      esi,10000h
    bsf     esi,esi
    lea     edi,[rdx-1]
    and     edx,edi
    add     rsi,rcx
    mov     rdi,[r12+8]
    and     rsi,rdi
    mov     rdi,[r12]
    mov     r8d,0
    sub     r8,rsi
    mov     r11,r8
    imul    r11,10h
    add     r11,rdi
    mov     rdi,r11
    mov     r8,[rsp+90h]
    mov     rdi,[rdi-10h]
    mov     r8,[r8]
    cmp     rdi,r8
    jne     L4
    mov     rdi,rsi
    mov     esi,1
L2:
    test    rsi,rsi
    je      L6
    mov     rsi,[r12]
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     r11,rdi
    imul    r11,10h
    add     r11,rsi
    mov     rsi,r11
    jmp     L7
L3:
    pcmpeqb xmm2,xmm2
    pcmpeqb xmm2,xmm1
    pmovmskb esi,xmm2
    test    si,si
    je      L5
    mov     esi,0
    mov     edi,0
    jmp     L2
L4:
    jmp     L1
L5:
    mov     rdx,[r12+8]
    add     rax,10h
    add     rcx,rax
    and     rcx,rdx
    jmp     L0
L6:
    mov     esi,0
L7:
    test    rsi,rsi
    je      L8
    mov     rax,r12
    mov     r12d,0
    jmp     L10
L8:
    mov     rax,[r12+10h]
    cmp     rax,1
    jae     L9
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [image.fn13.slot]
L9:
    mov     rax,[rsp+98h]
    mov     rsi,r14
L10:
    test    r12,r12
    je      L12
L11:
    mov     [rbx],r12
    mov     [rbx+8],rsi
    mov     [rbx+10h],rax
    mov     rax,rbx
    add     rsp,0A8h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L12:
    mov     r12d,0
    jmp     L11
L13:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L14]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L14:
    .long   L15
L15:
    ret

fn std::collections::hash_map::Entry::<'_, std::string::String, usize>::or_default
    sub     rsp,38h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+18h]
    mov     rdi,[rdi+20h]
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L0
    mov     [rsp+8],rax
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    mov     dword ptr [rsp+20h],0
    mov     word ptr [rsp+24h],0
    mov     byte ptr [rsp+26h],0
    mov     byte ptr [rsp+27h],0
    lea     rdx,[rsp+8]
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    call    qword ptr [fn1.slot]
    mov     byte ptr [rsp+27h],0
    mov     byte ptr [rsp+27h],0
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L1
L0:
    mov     byte ptr [rsp+27h],0
    mov     byte ptr [rsp+27h],0
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    lea     rcx,[rcx-8]
L1:
    mov     rax,rcx
    add     rsp,38h
    ret
    jmp     L3
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
  ; OSR entries
    lea     r11,[L4]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L4:
    .long   L5
    .long   L6
    .long   L7
    .long   L8
    .long   L9
    .long   L10
    .long   L11
    .long   L12
    .long   L13
L5:
    ret
L6:
    ret
L7:
    ret
L8:
    ret
L9:
    ret
L10:
    ret
L11:
    ret
L12:
    ret
L13:
    ret

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,68h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    test    rax,rax
    je      L9
    mov     r11,rdx
    shr     r11,20h
    mov     [rsp+10h],r11
    mov     r11,rdx
    shr     r11,30h
    mov     [rsp+18h],r11
    mov     r11,rdx
    shr     r11,38h
    mov     [rsp+20h],r11
    mov     r11,rsi
    shr     r11,20h
    mov     [rsp+28h],r11
    mov     r12,rsi
    shr     r12,30h
    mov     r13,rsi
    shr     r13,38h
    mov     [rsp+50h],rcx
    mov     r14,[rax+8]
    and     r14,rcx
    mov     [rsp+58h],r14
    mov     [rsp+40h],r14
    mov     qword ptr [rsp+48h],0
L0:
    mov     r14,[rsp+40h]
    mov     r15,[rax]
    lea     r15,[r15+r14]
    test    r15,r15
    je      L10
    mov     rbp,[r15]
    mov     r15,[r15+8]
    mov     [rsp+50h],rbp
    mov     [rsp+58h],r15
    mov     edi,[rsp+5Ch]
    mov     [rsp+30h],rbp
    mov     [rsp+38h],r15d
    mov     [rsp+3Ch],edi
    movdqu  xmm0,[rsp+30h]
    pmovmskb edi,xmm0
    test    di,di
    je      L2
    movzx   edi,di
    or      edi,10000h
    bsf     edi,edi
    mov     [rsp+3Ch],edi
    add     r14,rdi
    mov     rdi,[rax+8]
    and     r14,rdi
    mov     edi,1
L1:
    cmp     rdi,1
    je      L3
    mov     rdi,[rax+8]
    mov     r15,[rsp+48h]
    add     r15,10h
    mov     [rsp+48h],r15
    mov     rbp,[rsp+40h]
    add     rbp,r15
    mov     [rsp+40h],rbp
    and     rbp,rdi
    mov     [rsp+40h],rbp
    jmp     L0
L2:
    mov     edi,0
    mov     r14d,0
    jmp     L1
L3:
    mov     rdi,[rax]
    movzx   r15d,byte ptr [rdi+r14]
    test    r15b,80h
    jne     L5
    movdqu  xmm0,[rdi]
    pmovmskb edi,xmm0
    test    di,di
    je      L6
    movzx   edi,di
    or      edi,10000h
    bsf     edi,edi
L4:
    mov     r15,[rax]
    movzx   ebp,byte ptr [r15+rdi]
    mov     r8,rcx
    shr     r8,39h
    and     r8,7Fh
    lea     r9,[rdi-10h]
    mov     rbx,[rax+8]
    and     r9,rbx
    add     r9,10h
    mov     [r15+rdi],r8b
    mov     rbx,[rax]
    mov     [rbx+r9],r8b
    mov     r8,[rax]
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     r11,rdi
    imul    r11,10h
    add     r11,r8
    mov     r8,r11
    and     ebp,1
    test    bpl,bpl
    setne   dil
    movzx   edi,dil
    mov     r9,[rax+10h]
    sub     r9,rdi
    mov     [rax+10h],r9
    mov     [r8-10h],edx
    mov     r10,[rsp+10h]
    mov     [r8-0Ch],r10w
    mov     r10,[rsp+18h]
    mov     [r8-0Ah],r10b
    mov     r10,[rsp+20h]
    mov     [r8-9],r10b
    mov     [r8-8],esi
    mov     r10,[rsp+28h]
    mov     [r8-4],r10w
    mov     [r8-2],r12b
    mov     [r8-1],r13b
    mov     rdi,[rax+18h]
    add     rdi,1
    mov     [rax+18h],rdi
    lea     r8,[r8-8]
    jmp     L7
L5:
    mov     rdi,r14
    jmp     L4
L6:
    mov     edi,0
    jmp     L4
L7:
    mov     rax,r8
    add     rsp,68h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L8:
    mov     rax,rcx
    lea     rax,[rax-8]
    mov     r8,rax
    jmp     L7
L9:
    jmp     L8
L10:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L11]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L11:
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
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
L17:
    ret
L18:
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    cmp     rax,rcx
    jae     L0
    lea     rcx,[rax+1]
    mov     [rdi],rcx
    mov     rdx,rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    push    rbx
    push    r12
    sub     rsp,8
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L0
    sub     r12,1
    and     rbx,r12
    test    rbx,rbx
    sete    al
    movzx   eax,al
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L0:
    lea     rdi,[k0]
    lea     rdx,[k2]
    mov     esi,55h
    call    sym3
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

fn std::ptr::copy_nonoverlapping::precondition_check
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     [rsp+10h],r9
    test    r15,r15
    jne     L0
    mov     ebp,1
    jmp     L1
L0:
    test    r13,r13
    sete    al
    mov     rbp,rax
L1:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L6
    lea     rax,[r14-1]
    and     rax,rbx
    test    rax,rax
    jne     L10
    test    bpl,bpl
    jne     L2
    test    rbx,rbx
    je      L9
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L7
    sub     r14,1
    mov     rax,r12
    and     rax,r14
    test    rax,rax
    jne     L11
    test    bpl,bpl
    jne     L3
    test    r12,r12
    je      L9
L3:
    mov     rax,r13
    mul     r15
    jb      L8
    cmp     rbx,r12
    jae     L4
    mov     rcx,r12
    sub     rcx,rbx
    jmp     L5
L4:
    sub     rbx,r12
    mov     rcx,rbx
L5:
    cmp     rax,rcx
    ja      L9
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L6:
    lea     rdi,[image.k1227]
    lea     rdx,[image.k1272]
    mov     esi,55h
    call    image.sym31
    ud2
L7:
    lea     rdi,[image.k1227]
    lea     rdx,[image.k1272]
    mov     esi,55h
    call    image.sym31
    ud2
L8:
    lea     rdi,[image.k4406]
    mov     esi,3Dh
    call    image.sym39
    ud2
    jmp     L12
    jmp     L12
L9:
    lea     rdi,[k3]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    sym5
    ud2
L10:
    jmp     L9
L11:
    jmp     L9
L12:
    call    sym6
    ud2
  ; OSR entries
    lea     r11,[L13]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L13:
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
    .long   L19
    .long   L20
    .long   L21
    .long   L22
    .long   L23
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
L20:
    ret
L21:
    ret
L22:
    ret
L23:
    ret

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    push    rbx
    sub     rsp,20h
    mov     rbx,rdi
    mov     rdi,rbx
    call    image.sym24
    mov     rdi,rbx
    call    image.sym25
    add     rsp,20h
    pop     rbx
    ret
    mov     [rsp+10h],rax
    mov     rdi,rbx
    call    image.sym25
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    call    image.sym15
    ud2

