fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,58h
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
    jmp     L12
L0:
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+50h],r14
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
    jmp     L6
L3:
    mov     dword ptr [rsp+30h],0
    lea     rdx,[rsp+30h]
    test    r12,r12
    je      L27
    test    rdx,rdx
    je      L27
    cmp     r12,rdx
    jae     L4
    mov     rsi,rdx
    sub     rsi,r12
    jmp     L5
L4:
    mov     r11,r12
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L5:
    cmp     rsi,4
    jb      L27
    mov     edx,[r12]
    mov     [rsp+30h],edx
    mov     rsi,rdx
    mov     edx,4
L6:
    lea     rdi,[rdx+1]
    cmp     rdi,rax
    jae     L9
    mov     word ptr [rsp+24h],0
    lea     rdi,[r12+rdx]
    lea     r8,[rsp+24h]
    test    rdi,rdi
    je      L28
    test    r8,r8
    je      L28
    cmp     rdi,r8
    jae     L7
    mov     r9,r8
    sub     r9,rdi
    jmp     L8
L7:
    mov     r11,rdi
    sub     r11,r8
    mov     r8,r11
    mov     r9,r8
L8:
    cmp     r9,2
    jb      L28
    movzx   edi,word ptr [rdi]
    mov     [rsp+24h],di
    mov     rcx,rdx
    imul    rcx,8
    shl     rdi,cl
    or      rsi,rdi
    add     rdx,2
L9:
    cmp     rdx,rax
    jae     L10
    cmp     rdx,r13
    jae     L29
    mov     byte ptr [rsp+25h],1
    movzx   eax,byte ptr [r12+rdx]
    movzx   eax,al
    mov     rcx,rdx
    imul    rcx,8
    shl     rax,cl
    or      rsi,rax
L10:
    mov     rax,[rbx+40h]
    mov     [rsp+50h],rax
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    mov     rax,[rbx+38h]
    or      rax,rsi
    mov     [rbx+38h],rax
    cmp     r13,r14
    jae     L11
    mov     rdx,[rbx+40h]
    add     rdx,r13
    mov     [rbx+40h],rdx
    jmp     L26
L11:
    mov     rdx,[rbx+18h]
    xor     rdx,rax
    mov     [rbx+18h],rdx
    mov     rdi,rbx
    call    fn1
    mov     rax,[rbx+38h]
    mov     rdx,[rbx]
    xor     rdx,rax
    mov     [rbx],rdx
    mov     qword ptr [rbx+40h],0
L12:
    mov     rax,r13
    sub     rax,r14
    mov     rdx,rax
    and     rdx,7
    mov     [rsp+10h],r13
    mov     r13,r12
    mov     r12,rdx
    mov     rbp,rbx
    mov     rbx,rax
L13:
    mov     [rsp+50h],r14
    mov     rax,rbx
    sub     rax,r12
    cmp     r14,rax
    jae     L17
    mov     qword ptr [rsp+50h],0
    lea     rax,[r13+r14]
    lea     rdx,[rsp+50h]
    test    rax,rax
    je      L30
    test    rdx,rdx
    je      L30
    cmp     rax,rdx
    jae     L14
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L15
L14:
    mov     r11,rax
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L15:
    cmp     rsi,8
    jb      L30
    mov     r15,[rax]
    mov     [rsp+50h],r15
    mov     rax,[rbp+18h]
    xor     rax,r15
    mov     [rbp+18h],rax
    mov     [rsp+50h],rbp
    mov     rdi,rbp
    call    fn1
    mov     rax,rbp
    mov     rdx,r14
    mov     rsi,r12
    mov     rdi,r13
    mov     r8,[rsp+10h]
L16:
    mov     r9,[rax]
    xor     r9,r15
    mov     [rax],r9
    add     rdx,8
    mov     r14,rdx
    mov     r12,rsi
    mov     r13,rdi
    mov     [rsp+10h],r8
    mov     rbp,rax
    jmp     L13
L17:
    mov     r11d,3
    cmp     r11,r12
    jb      L18
    mov     eax,0
    mov     edx,0
    jmp     L21
L18:
    mov     dword ptr [rsp+40h],0
    lea     rax,[r13+r14]
    lea     rdx,[rsp+40h]
    test    rax,rax
    je      L31
    test    rdx,rdx
    je      L31
    cmp     rax,rdx
    jae     L19
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L20
L19:
    mov     r11,rax
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L20:
    cmp     rsi,4
    jb      L31
    mov     eax,[rax]
    mov     [rsp+40h],eax
    mov     rdx,rax
    mov     eax,4
L21:
    lea     rsi,[rax+1]
    cmp     rsi,r12
    jae     L24
    mov     word ptr [rsp+34h],0
    lea     rsi,[r14+rax]
    lea     rsi,[r13+rsi]
    lea     rdi,[rsp+34h]
    test    rsi,rsi
    je      L32
    test    rdi,rdi
    je      L32
    cmp     rsi,rdi
    jae     L22
    mov     r8,rdi
    sub     r8,rsi
    jmp     L23
L22:
    mov     r11,rsi
    sub     r11,rdi
    mov     rdi,r11
    mov     r8,rdi
L23:
    cmp     r8,2
    jb      L32
    movzx   esi,word ptr [rsi]
    mov     [rsp+34h],si
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
    add     rax,2
L24:
    cmp     rax,r12
    jae     L25
    add     r14,rax
    cmp     r14,[rsp+10h]
    jae     L33
    mov     byte ptr [rsp+35h],1
    movzx   esi,byte ptr [r13+r14]
    movzx   esi,sil
    mov     rcx,rax
    imul    rcx,8
    shl     rsi,cl
    or      rdx,rsi
L25:
    mov     [rbp+38h],rdx
    mov     [rbp+40h],r12
L26:
    add     rsp,58h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L27:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L28:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L29:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L30:
    lea     rdi,[image.k3619]
    lea     rcx,[k4]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L31:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2240]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L32:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k2264]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L33:
    lea     rdi,[image.k4746]
    lea     rcx,[image.k2288]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L34]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L34:
    .long   L35
    .long   L36
    .long   L37
L35:
    ret
L36:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     r11,[rdx-50h]
    mov     [rsp+30h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-30h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-70h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L13
L37:
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
    mov     r11,[rdx-50h]
    mov     [rsp+38h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     [rdx-18h],r14
    mov     [rdx-20h],r15
    mov     [rdx-28h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-30h],r11
    mov     rax,[rsp]
    mov     r15,[rsp+8]
    mov     rbx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L16

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
    sub     rsp,90h
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
    mov     rbx,[rsi+8]
    mov     r12,[rsi+10h]
    mov     [rsp+78h],r12
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
    je      L2
    test    r15,r15
    je      L2
    lea     rdi,[rsp+10h]
    mov     esi,1
    call    image.fn93
    test    al,al
    je      L2
    lea     rax,[rsp+10h]
    test    rax,rax
    je      L2
    lea     rsi,[rsp+10h]
    mov     rdi,r15
    mov     edx,1
    mov     ecx,8
    call    image.fn152
    test    al,al
    je      L2
    mov     r15,[r15]
    mov     [rsp+10h],r15
    mov     rax,[rsp+60h]
    xor     rax,r15
    mov     [rsp+60h],rax
    lea     rdi,[rsp+48h]
    mov     [rsp+10h],rdi
    call    image.fn187
    mov     rax,[rsp+48h]
    xor     rax,r15
    mov     [rsp+48h],rax
    lea     rax,[r14+8]
    mov     r14,rax
    jmp     L0
L1:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r13
    call    image.fn132
    mov     [rsp+80h],rax
    mov     [rsp+88h],r13
    mov     byte ptr [rsp+1Fh],0FFh
    lea     rsi,[rsp+1Fh]
    lea     rdi,[rsp+48h]
    mov     edx,1
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
    xor     rax,rcx
    add     rsp,90h
    pop     r15
    pop     r14
    pop     r13
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
    jmp     L4
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
    ret

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
    lea     rax,[rsp+10h]
    test    rax,rax
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
    jmp     L4
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
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

fn core::hash::sip::u8to64_le
    push    rbx
    push    r12
    sub     rsp,28h
    mov     rax,rcx
    mov     r11d,3
    cmp     r11,rax
    jb      L0
    mov     r8d,0
    mov     r9d,0
    jmp     L3
L0:
    mov     dword ptr [rsp+20h],0
    lea     r8,[rdi+rdx]
    lea     r9,[rsp+20h]
    test    r8,r8
    je      L8
    test    r9,r9
    je      L8
    cmp     r8,r9
    jae     L1
    mov     rcx,r9
    sub     rcx,r8
    jmp     L2
L1:
    mov     r11,r8
    sub     r11,r9
    mov     r9,r11
    mov     rcx,r9
L2:
    cmp     rcx,4
    jb      L8
    mov     r8d,[r8]
    mov     [rsp+20h],r8d
    mov     r9,r8
    mov     r8d,4
L3:
    lea     rcx,[r8+1]
    cmp     rcx,rax
    jae     L6
    mov     word ptr [rsp+14h],0
    lea     rcx,[rdx+r8]
    lea     rcx,[rdi+rcx]
    lea     rbx,[rsp+14h]
    test    rcx,rcx
    je      L9
    test    rbx,rbx
    je      L9
    cmp     rcx,rbx
    jae     L4
    mov     r12,rbx
    sub     r12,rcx
    jmp     L5
L4:
    mov     r11,rcx
    sub     r11,rbx
    mov     rbx,r11
    mov     r12,rbx
L5:
    cmp     r12,2
    jb      L9
    movzx   ecx,word ptr [rcx]
    mov     [rsp+14h],cx
    mov     rbx,r8
    imul    rbx,8
    mov     r11,rcx
    mov     rcx,rbx
    shl     r11,cl
    mov     rbx,r11
    or      r9,rbx
    add     r8,2
L6:
    cmp     r8,rax
    jae     L7
    add     rdx,r8
    cmp     rdx,rsi
    jae     L10
    mov     byte ptr [rsp+15h],1
    movzx   eax,byte ptr [rdi+rdx]
    movzx   eax,al
    mov     rcx,r8
    imul    rcx,8
    shl     rax,cl
    or      r9,rax
L7:
    mov     rax,r9
    add     rsp,28h
    pop     r12
    pop     rbx
    ret
L8:
    lea     rdi,[image.k3619]
    lea     rcx,[k0]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L9:
    lea     rdi,[image.k3619]
    lea     rcx,[k2]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L10:
    lea     rdi,[image.k4746]
    lea     rcx,[k4]
    mov     esi,1ADh
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
L12:
    ret
L13:
    ret
L14:
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
    sub     rsp,0E8h
    mov     [rsp+48h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+38h],r13
    mov     [rsp+30h],r14
    mov     rbx,rdi
    mov     r12,[rbx]
    mov     [rsp+68h],r12
    mov     [rsp+60h],r12
    mov     [rsp+70h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    movdqu  xmm0,[r13]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    lea     r13,[r13+10h]
    mov     [rsp+50h],r12
    mov     [rsp+58h],r13
    mov     [rsp+60h],r14
    mov     [rsp+68h],ax
    mov     [rsp+6Ah],r10d
    mov     [rsp+6Eh],r10w
    mov     rax,[rbx+18h]
    mov     rcx,[rsp+68h]
    mov     [rsp+50h],r12
    mov     [rsp+58h],r13
    mov     [rsp+60h],r14
    mov     [rsp+68h],rcx
    mov     [rsp+70h],rax
L0:
    mov     rax,[rsp+70h]
    test    rax,rax
    je      L2
L1:
    movzx   eax,word ptr [rsp+68h]
    test    ax,ax
    je      L3
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rsp+68h],ax
    mov     rax,[rsp+50h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+70h]
    sub     rcx,1
    mov     [rsp+70h],rcx
    test    rax,rax
    jne     L15
L2:
    mov     rbx,[rsp+48h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+38h]
    mov     r14,[rsp+30h]
    add     rsp,0E8h
    ret
L3:
    mov     r12,[rsp+58h]
    movdqu  xmm0,[r12]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+68h],cx
    mov     rcx,[rsp+50h]
    lea     rcx,[rcx-100h]
    mov     [rsp+50h],rcx
    lea     r12,[r12+10h]
    mov     [rsp+58h],r12
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
    lea     rdx,[rdx+rsi]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rsi,[rsp+10h]
    test    rdx,rdx
    je      L16
    test    rsi,rsi
    je      L16
    cmp     rdx,rsi
    jae     L9
    mov     r8,rsi
    sub     r8,rdx
    jmp     L10
L9:
    mov     r11,rdx
    sub     r11,rsi
    mov     rsi,r11
    mov     r8,rsi
L10:
    cmp     r8,10h
    jb      L16
    movdqu  xmm0,[rdx]
    movq    rdx,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rsi,xmm15
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rsi
    pcmpeqb xmm1,xmm1
    pcmpeqb xmm0,xmm1
    pmovmskb edx,xmm0
    mov     rsi,[rdi]
    lea     rsi,[rsi+rcx]
    mov     qword ptr [rsp+20h],0
    mov     qword ptr [rsp+28h],0
    lea     r8,[rsp+20h]
    test    rsi,rsi
    je      L17
    test    r8,r8
    je      L17
    cmp     rsi,r8
    jae     L11
    mov     r9,r8
    sub     r9,rsi
    jmp     L12
L11:
    mov     r11,rsi
    sub     r11,r8
    mov     r8,r11
    mov     r9,r8
L12:
    cmp     r9,10h
    jb      L17
    movdqu  xmm0,[rsi]
    movq    rsi,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    r8,xmm15
    mov     [rsp+20h],rsi
    mov     [rsp+28h],r8
    pcmpeqb xmm0,xmm1
    pmovmskb esi,xmm0
    movzx   edx,dx
    bsr     edx,edx
    mov     r10d,1Fh
    cmove   edx,r10d
    xor     edx,0Fh
    movzx   esi,si
    or      esi,10000h
    bsf     esi,esi
    add     rdx,rsi
    cmp     rdx,10h
    jb      L13
    mov     edx,80h
    jmp     L14
L13:
    mov     rdx,[rdi+10h]
    add     rdx,1
    mov     [rdi+10h],rdx
    mov     edx,0FFh
L14:
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
L15:
    mov     rcx,rax
    mov     rdx,rbx
    jmp     L4
L16:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L17:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
  ; OSR entries
    lea     r11,[L18]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L18:
    .long   L19
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
    .long   L25
    .long   L26
L19:
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
    lea     rsp,[rsp+10h]
    jmp     L0
L20:
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
    lea     rsp,[rsp+10h]
    jmp     L4
L21:
    ret
L22:
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
    lea     rsp,[rsp+20h]
    jmp     L7
L23:
    ret
L24:
    ret
L25:
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
    lea     rsp,[rsp+20h]
    jmp     L6
L26:
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
    lea     rsp,[rsp+20h]
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
    je      L6
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
    mov     r9,rsi
    mov     rbx,rdi
    mov     rdi,rdx
    mov     r12,rcx
    mov     r13,rax
L1:
    mov     r8,[r8-8]
    add     rdi,r8
L2:
    sub     r9,1
    mov     rsi,r9
    mov     rdx,rdi
    mov     rdi,rbx
    mov     rcx,r12
    mov     rax,r13
    jmp     L0
L3:
    mov     rax,rdx
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+10h]
    add     rsp,0E8h
    ret
L4:
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
L5:
    lea     rbx,[rbx+10h]
    mov     rsi,r13
    mov     rdx,r14
    mov     rcx,rbx
    mov     rax,r12
    jmp     L0
L6:
    test    rsi,rsi
    je      L3
    mov     rbx,rcx
    mov     r12,rax
    mov     r13,rsi
    mov     r14,rdx
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
    .long   L17
    .long   L18
L8:
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
L9:
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
    mov     r9,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L2
L10:
    ret
L11:
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
    jmp     L4
L12:
    ret
L13:
    ret
L14:
    ret
L15:
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
    mov     rdi,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+28h]
    lea     rsp,[rsp+70h]
    jmp     L1
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
    mov     r8,[rsp]
    mov     rdi,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+28h]
    lea     rsp,[rsp+70h]
    jmp     L1
L17:
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
    jmp     L5
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
    mov     r12,[rsp]
    mov     rbx,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L5

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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,80h
    mov     rbx,rdi
    mov     [rsp+70h],rdx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[rbx+8]
    and     rsi,rcx
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm14,r11d
    pshufd  xmm14,xmm14,0
    movdqu  [rsp+20h],xmm14
    mov     r12,rsi
    mov     r13d,0
L0:
    mov     rax,[rbx]
    lea     rax,[rax+r12]
    mov     qword ptr [rsp+60h],0
    mov     qword ptr [rsp+68h],0
    lea     rcx,[rsp+60h]
    test    rax,rax
    je      L12
    test    rcx,rcx
    je      L12
    cmp     rax,rcx
    jae     L1
    mov     rdx,rcx
    sub     rdx,rax
    jmp     L2
L1:
    mov     r11,rax
    sub     r11,rcx
    mov     rcx,r11
    mov     rdx,rcx
L2:
    cmp     rdx,10h
    jb      L12
    movdqu  xmm14,[rax]
    movdqu  [rsp+30h],xmm14
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    movdqu  xmm0,[rsp+30h]
    movdqu  xmm15,[rsp+20h]
    pcmpeqb xmm0,xmm15
    pmovmskb eax,xmm0
L3:
    test    ax,ax
    je      L7
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    mov     r14,rax
    and     r14d,edx
    lea     rax,[r12+rcx]
    mov     rcx,[rbx+8]
    mov     r15,rax
    and     r15,rcx
    mov     rax,[rbx]
    mov     ecx,0
    sub     rcx,r15
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+70h]
    mov     rdx,[rax-18h]
    mov     rax,[rax-10h]
    mov     rsi,[rcx+8]
    mov     rcx,[rcx+10h]
    cmp     rax,rcx
    jne     L4
    mov     [rsp+48h],rax
    mov     [rsp+58h],rdx
    mov     [rsp],rsi
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym41]
    mov     eax,[rsp+54h]
    test    eax,eax
    sete    al
    jmp     L5
L4:
    mov     eax,0
L5:
    test    al,al
    je      L8
    mov     eax,1
L6:
    test    rax,rax
    je      L10
    mov     rax,[rbx]
    mov     ecx,0
    sub     rcx,r15
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    jmp     L11
L7:
    pcmpeqb xmm0,xmm0
    movdqu  xmm15,[rsp+30h]
    pcmpeqb xmm0,xmm15
    pmovmskb eax,xmm0
    test    ax,ax
    je      L9
    mov     eax,0
    mov     r15d,0
    jmp     L6
L8:
    mov     rax,r14
    jmp     L3
L9:
    mov     rax,[rbx+8]
    add     r13,10h
    add     r12,r13
    and     r12,rax
    jmp     L0
L10:
    mov     eax,0
L11:
    add     rsp,80h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L12:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
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
L14:
    ret
L15:
    ret
L16:
    ret
L17:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,58h
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     r8,[rdx+10h]
    mov     rdx,[rdx+18h]
    mov     [rsp+40h],rsi
    mov     r9,[rdi+8]
    and     r9,rsi
    mov     [rsp+48h],r9
    mov     [rsp+30h],r9
    mov     qword ptr [rsp+38h],0
L0:
    mov     r9,[rsp+30h]
    mov     rbx,[rdi]
    lea     rbx,[rbx+r9]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     r9,[rsp+10h]
    test    rbx,rbx
    je      L9
    test    r9,r9
    je      L9
    cmp     rbx,r9
    jae     L1
    mov     r12,r9
    sub     r12,rbx
    jmp     L2
L1:
    mov     r11,rbx
    sub     r11,r9
    mov     r9,r11
    mov     r12,r9
L2:
    cmp     r12,10h
    jb      L9
    mov     r9,[rbx]
    mov     rbx,[rbx+8]
    mov     [rsp+10h],r9
    mov     [rsp+18h],rbx
    mov     [rsp+40h],r9
    mov     [rsp+48h],rbx
    mov     r12d,[rsp+4Ch]
    mov     [rsp+20h],r9
    mov     [rsp+28h],ebx
    mov     [rsp+2Ch],r12d
    movdqu  xmm0,[rsp+20h]
    pmovmskb r9d,xmm0
    test    r9w,r9w
    je      L4
    movzx   r9d,r9w
    or      r9d,10000h
    bsf     r9d,r9d
    mov     [rsp+2Ch],r9d
    mov     rbx,[rsp+30h]
    add     rbx,r9
    mov     r9,[rdi+8]
    and     rbx,r9
    mov     r9d,1
L3:
    cmp     r9,1
    je      L5
    mov     r9,[rdi+8]
    mov     r12,[rsp+38h]
    add     r12,10h
    mov     [rsp+38h],r12
    mov     r13,[rsp+30h]
    add     r13,r12
    mov     [rsp+30h],r13
    and     r13,r9
    mov     [rsp+30h],r13
    jmp     L0
L4:
    mov     r9d,0
    mov     ebx,0
    jmp     L3
L5:
    mov     r9,[rdi]
    movzx   r12d,byte ptr [r9+rbx]
    test    r12b,80h
    jne     L7
    movdqu  xmm0,[r9]
    pmovmskb r9d,xmm0
    test    r9w,r9w
    je      L8
    movzx   r9d,r9w
    or      r9d,10000h
    bsf     r9d,r9d
L6:
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
    add     rsp,58h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L7:
    mov     r9,rbx
    jmp     L6
L8:
    mov     r9d,0
    jmp     L6
L9:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
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
L17:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jae     L0
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
L0:
    add     rsp,18h
    ret
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L1
    jmp     L2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
    .long   L6
    .long   L7
    .long   L8
L4:
    ret
L5:
    ret
L6:
    ret
L7:
    ret
L8:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    sub     rsp,88h
    mov     rax,[rsi]
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
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
    lea     rdi,[rsp+38h]
    mov     rsi,[rax-18h]
    mov     rdx,[rax-10h]
    call    image.fn176
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rsi,[rsp+0Fh]
    lea     rdi,[rsp+38h]
    mov     edx,1
    call    image.fn176
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],rcx
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+68h]
    and     rdi,0FFh
    shl     rdi,38h
    mov     r8,[rsp+70h]
    or      rdi,r8
    xor     rsi,rdi
    mov     [rsp+28h],rsi
    lea     r8,[rsp+10h]
    add     rax,rdx
    mov     [rsp+10h],rax
    add     rcx,rsi
    mov     [rsp+18h],rcx
    mov     r9,rdx
    shl     r9,0Dh
    shr     rdx,33h
    or      r9,rdx
    mov     [rsp+20h],r9
    xor     r9,rax
    mov     [rsp+20h],r9
    mov     rdx,rsi
    shl     rdx,10h
    shr     rsi,30h
    or      rdx,rsi
    mov     [rsp+28h],rdx
    xor     rdx,rcx
    mov     [rsp+28h],rdx
    mov     rsi,rax
    shl     rsi,20h
    shr     rax,20h
    or      rsi,rax
    mov     [rsp+10h],rsi
    add     rcx,r9
    mov     [rsp+18h],rcx
    add     rsi,rdx
    mov     [rsp+10h],rsi
    mov     rax,r9
    shl     rax,11h
    shr     r9,2Fh
    or      rax,r9
    mov     [rsp+20h],rax
    xor     rax,rcx
    mov     [rsp+20h],rax
    mov     rax,rdx
    shl     rax,15h
    shr     rdx,2Bh
    or      rax,rdx
    mov     [rsp+28h],rax
    xor     rax,rsi
    mov     [rsp+28h],rax
    mov     rax,rcx
    shl     rax,20h
    shr     rcx,20h
    or      rax,rcx
    mov     [rsp+18h],rax
    xor     rsi,rdi
    mov     [rsp+10h],rsi
    xor     rax,0FFh
    mov     [rsp+18h],rax
    mov     rdi,r8
    call    image.fn188
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+20h]
    xor     rax,rcx
    mov     rcx,[rsp+18h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    add     rsp,88h
    ret
    jmp     L0
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
    .long   L3
    .long   L4
    .long   L5
    .long   L6
L2:
    ret
L3:
    ret
L4:
    ret
L5:
    ret
L6:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    sub     rsp,38h
    mov     rax,[rdi]
    mov     rcx,rax
    sub     rcx,rsi
    sar     rcx,4
    lea     rdx,[rcx-10h]
    mov     rsi,[rdi+8]
    and     rdx,rsi
    lea     rax,[rax+rdx]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rdx,[rsp+10h]
    test    rax,rax
    je      L6
    test    rdx,rdx
    je      L6
    cmp     rax,rdx
    jae     L0
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L1
L0:
    mov     r11,rax
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L1:
    cmp     rsi,10h
    jb      L6
    movdqu  xmm0,[rax]
    movq    rax,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rdx,xmm15
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    pcmpeqb xmm1,xmm1
    pcmpeqb xmm0,xmm1
    pmovmskb eax,xmm0
    mov     rdx,[rdi]
    lea     rdx,[rdx+rcx]
    mov     qword ptr [rsp+20h],0
    mov     qword ptr [rsp+28h],0
    lea     rsi,[rsp+20h]
    test    rdx,rdx
    je      L7
    test    rsi,rsi
    je      L7
    cmp     rdx,rsi
    jae     L2
    mov     r8,rsi
    sub     r8,rdx
    jmp     L3
L2:
    mov     r11,rdx
    sub     r11,rsi
    mov     rsi,r11
    mov     r8,rsi
L3:
    cmp     r8,10h
    jb      L7
    movdqu  xmm0,[rdx]
    movq    rdx,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rsi,xmm15
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rsi
    pcmpeqb xmm0,xmm1
    pmovmskb edx,xmm0
    movzx   eax,ax
    bsr     eax,eax
    mov     r10d,1Fh
    cmove   eax,r10d
    xor     eax,0Fh
    movzx   edx,dx
    or      edx,10000h
    bsf     edx,edx
    add     rax,rdx
    cmp     rax,10h
    jb      L4
    mov     eax,80h
    jmp     L5
L4:
    mov     rax,[rdi+10h]
    add     rax,1
    mov     [rdi+10h],rax
    mov     eax,0FFh
L5:
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
    add     rsp,38h
    ret
L6:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
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
L9:
    ret
L10:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
    sub     rsp,38h
    mov     [rsp+20h],rdx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[rdi+8]
    and     rsi,rcx
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    mov     eax,0
L0:
    mov     rcx,[rdi]
    lea     rcx,[rcx+rsi]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rdx,[rsp+10h]
    test    rcx,rcx
    je      L10
    test    rdx,rdx
    je      L10
    cmp     rcx,rdx
    jae     L1
    mov     r8,rdx
    sub     r8,rcx
    jmp     L2
L1:
    mov     r11,rcx
    sub     r11,rdx
    mov     rdx,r11
    mov     r8,rdx
L2:
    cmp     r8,10h
    jb      L10
    movdqu  xmm1,[rcx]
    movq    rcx,xmm1
    pshufd  xmm15,xmm1,0EEh
    movq    rdx,xmm15
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    movdqa  xmm2,xmm1
    pcmpeqb xmm2,xmm0
    pmovmskb ecx,xmm2
L3:
    test    cx,cx
    je      L5
    movzx   edx,cx
    or      edx,10000h
    bsf     edx,edx
    lea     r8d,[rcx-1]
    and     ecx,r8d
    add     rdx,rsi
    mov     r8,[rdi+8]
    and     rdx,r8
    mov     r8,[rdi]
    mov     r9d,0
    sub     r9,rdx
    mov     r11,r9
    imul    r11,10h
    add     r11,r8
    mov     r8,r11
    mov     r9,[rsp+20h]
    mov     r9,[r9]
    mov     r8,[r8-10h]
    cmp     r9,r8
    jne     L6
    mov     r8,rdx
    mov     edx,1
L4:
    test    rdx,rdx
    je      L8
    mov     rdx,[rdi]
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    mov     r11,r8
    imul    r11,10h
    add     r11,rdx
    mov     rdx,r11
    jmp     L9
L5:
    pcmpeqb xmm2,xmm2
    pcmpeqb xmm2,xmm1
    pmovmskb edx,xmm2
    test    dx,dx
    je      L7
    mov     edx,0
    mov     r8d,0
    jmp     L4
L6:
    jmp     L3
L7:
    mov     rcx,[rdi+8]
    add     rax,10h
    add     rsi,rax
    and     rsi,rcx
    jmp     L0
L8:
    mov     edx,0
L9:
    mov     rax,rdx
    add     rsp,38h
    ret
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
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>
    sub     rsp,38h
    mov     [rsp+20h],rdx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     rcx,[rdi+8]
    and     rsi,rcx
    movzx   r11d,al
    imul    r11d,1010101h
    movd    xmm0,r11d
    pshufd  xmm0,xmm0,0
    mov     eax,0
L0:
    mov     rcx,[rdi]
    lea     rcx,[rcx+rsi]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rdx,[rsp+10h]
    test    rcx,rcx
    je      L10
    test    rdx,rdx
    je      L10
    cmp     rcx,rdx
    jae     L1
    mov     r8,rdx
    sub     r8,rcx
    jmp     L2
L1:
    mov     r11,rcx
    sub     r11,rdx
    mov     rdx,r11
    mov     r8,rdx
L2:
    cmp     r8,10h
    jb      L10
    movdqu  xmm1,[rcx]
    movq    rcx,xmm1
    pshufd  xmm15,xmm1,0EEh
    movq    rdx,xmm15
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    movdqa  xmm2,xmm1
    pcmpeqb xmm2,xmm0
    pmovmskb ecx,xmm2
L3:
    test    cx,cx
    je      L5
    movzx   edx,cx
    or      edx,10000h
    bsf     edx,edx
    lea     r8d,[rcx-1]
    and     ecx,r8d
    add     rdx,rsi
    mov     r8,[rdi+8]
    and     rdx,r8
    mov     r8,[rdi]
    mov     r9d,0
    sub     r9,rdx
    mov     r11,r9
    imul    r11,10h
    add     r11,r8
    mov     r8,r11
    mov     r9,[rsp+20h]
    mov     r8,[r8-10h]
    mov     r9,[r9]
    cmp     r8,r9
    jne     L6
    mov     r8,rdx
    mov     edx,1
L4:
    test    rdx,rdx
    je      L8
    mov     rdx,[rdi]
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    mov     r11,r8
    imul    r11,10h
    add     r11,rdx
    mov     rdx,r11
    jmp     L9
L5:
    pcmpeqb xmm2,xmm2
    pcmpeqb xmm2,xmm1
    pmovmskb edx,xmm2
    test    dx,dx
    je      L7
    mov     edx,0
    mov     r8d,0
    jmp     L4
L6:
    jmp     L3
L7:
    mov     rcx,[rdi+8]
    add     rax,10h
    add     rsi,rax
    and     rsi,rcx
    jmp     L0
L8:
    mov     edx,0
L9:
    mov     rax,rdx
    add     rsp,38h
    ret
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
L12:
    ret
L13:
    ret
L14:
    ret
L15:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,78h
    mov     r11,rdx
    shr     r11,20h
    mov     [rsp+10h],r11
    mov     r11,rdx
    shr     r11,30h
    mov     [rsp+18h],r11
    mov     r11,rdx
    shr     r11,38h
    mov     [rsp+20h],r11
    mov     r11,rcx
    shr     r11,20h
    mov     [rsp+28h],r11
    mov     r12,rcx
    shr     r12,30h
    mov     r13,rcx
    shr     r13,38h
    mov     [rsp+60h],rsi
    mov     r14,[rdi+8]
    and     r14,rsi
    mov     [rsp+68h],r14
    mov     [rsp+50h],r14
    mov     qword ptr [rsp+58h],0
L0:
    mov     r14,[rsp+50h]
    mov     r15,[rdi]
    lea     r15,[r15+r14]
    mov     qword ptr [rsp+30h],0
    mov     qword ptr [rsp+38h],0
    lea     r14,[rsp+30h]
    test    r15,r15
    je      L9
    test    r14,r14
    je      L9
    cmp     r15,r14
    jae     L1
    mov     rbp,r14
    sub     rbp,r15
    jmp     L2
L1:
    mov     r11,r15
    sub     r11,r14
    mov     r14,r11
    mov     rbp,r14
L2:
    cmp     rbp,10h
    jb      L9
    mov     r14,[r15]
    mov     r15,[r15+8]
    mov     [rsp+30h],r14
    mov     [rsp+38h],r15
    mov     [rsp+60h],r14
    mov     [rsp+68h],r15
    mov     ebp,[rsp+6Ch]
    mov     [rsp+40h],r14
    mov     [rsp+48h],r15d
    mov     [rsp+4Ch],ebp
    movdqu  xmm0,[rsp+40h]
    pmovmskb r14d,xmm0
    test    r14w,r14w
    je      L4
    movzx   r14d,r14w
    or      r14d,10000h
    bsf     r14d,r14d
    mov     [rsp+4Ch],r14d
    mov     r15,[rsp+50h]
    add     r15,r14
    mov     r14,[rdi+8]
    and     r15,r14
    mov     r14d,1
L3:
    cmp     r14,1
    je      L5
    mov     r14,[rdi+8]
    mov     rbp,[rsp+58h]
    add     rbp,10h
    mov     [rsp+58h],rbp
    mov     rax,[rsp+50h]
    add     rax,rbp
    mov     [rsp+50h],rax
    and     rax,r14
    mov     [rsp+50h],rax
    jmp     L0
L4:
    mov     r14d,0
    mov     r15d,0
    jmp     L3
L5:
    mov     rax,[rdi]
    movzx   r14d,byte ptr [rax+r15]
    test    r14b,80h
    jne     L7
    movdqu  xmm0,[rax]
    pmovmskb eax,xmm0
    test    ax,ax
    je      L8
    movzx   eax,ax
    or      eax,10000h
    bsf     eax,eax
L6:
    mov     r14,[rdi]
    movzx   ebp,byte ptr [r14+rax]
    mov     r8,rsi
    shr     r8,39h
    and     r8,7Fh
    lea     r9,[rax-10h]
    mov     rbx,[rdi+8]
    and     r9,rbx
    add     r9,10h
    mov     [r14+rax],r8b
    mov     rbx,[rdi]
    mov     [rbx+r9],r8b
    mov     r8,[rdi]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,r8
    mov     rax,r11
    and     ebp,1
    test    bpl,bpl
    setne   r8b
    movzx   r8d,r8b
    mov     r9,[rdi+10h]
    sub     r9,r8
    mov     [rdi+10h],r9
    mov     [rax-10h],edx
    mov     r10,[rsp+10h]
    mov     [rax-0Ch],r10w
    mov     r10,[rsp+18h]
    mov     [rax-0Ah],r10b
    mov     r10,[rsp+20h]
    mov     [rax-9],r10b
    mov     [rax-8],ecx
    mov     r10,[rsp+28h]
    mov     [rax-4],r10w
    mov     [rax-2],r12b
    mov     [rax-1],r13b
    mov     r8,[rdi+18h]
    add     r8,1
    mov     [rdi+18h],r8
    add     rsp,78h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L7:
    mov     rax,r15
    jmp     L6
L8:
    mov     eax,0
    jmp     L6
L9:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jae     L0
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
L0:
    add     rsp,18h
    ret
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L1
    jmp     L2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
    .long   L6
    .long   L7
    .long   L8
L4:
    ret
L5:
    ret
L6:
    ret
L7:
    ret
L8:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    sub     rsp,98h
    mov     rax,[rsi]
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
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
    lea     rdi,[rsp+48h]
    mov     rax,[rax-10h]
    mov     [rsp+10h],rax
    lea     rsi,[rsp+10h]
    mov     edx,8
    call    qword ptr [image.fn176.slot]
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
    xor     rax,rcx
    add     rsp,98h
    ret
    jmp     L0
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
    .long   L3
    .long   L4
    .long   L5
    .long   L6
L2:
    ret
L3:
    ret
L4:
    ret
L5:
    ret
L6:
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
    sub     rsp,0D8h
    mov     [rsp+58h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+48h],r13
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],rbp
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r8,[rdi+8]
    and     rsi,r8
    mov     r8d,0
L0:
    mov     r9,[rdi]
    lea     r9,[r9+rsi]
    mov     qword ptr [rsp+20h],0
    mov     qword ptr [rsp+28h],0
    lea     rbx,[rsp+20h]
    test    r9,r9
    je      L9
    test    rbx,rbx
    je      L9
    cmp     r9,rbx
    jae     L1
    mov     r12,rbx
    sub     r12,r9
    jmp     L2
L1:
    mov     r11,r9
    sub     r11,rbx
    mov     rbx,r11
    mov     r12,rbx
L2:
    cmp     r12,10h
    jb      L9
    movdqu  xmm0,[r9]
    movq    r9,xmm0
    pshufd  xmm15,xmm0,0EEh
    movq    rbx,xmm15
    mov     [rsp+20h],r9
    mov     [rsp+28h],rbx
    mov     [rsp+60h],r9
    mov     [rsp+68h],rbx
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
L3:
    test    r9w,r9w
    je      L6
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
L4:
    test    al,al
    je      L7
    mov     eax,1
L5:
    mov     rdx,r15
    mov     rbx,[rsp+58h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+48h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+38h]
    mov     rbp,[rsp+30h]
    add     rsp,0D8h
    ret
L6:
    pcmpeqb xmm0,xmm0
    mov     rax,[rsp+60h]
    mov     r15,[rsp+68h]
    movq    xmm1,rax
    movq    xmm15,r15
    punpcklqdq xmm1,xmm15
    pcmpeqb xmm1,xmm0
    pmovmskb eax,xmm1
    test    ax,ax
    je      L8
    mov     eax,0
    mov     r15d,0
    jmp     L5
L7:
    mov     rbx,rcx
    mov     r12,rdx
    mov     r13,rsi
    mov     r14,rdi
    mov     [rsp+18h],r8
    mov     [rsp+10h],r9
    mov     r9,rbp
    jmp     L3
L8:
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
L9:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
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
L11:
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
    lea     rsp,[rsp+60h]
    jmp     L0
L12:
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
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0C0h],r11
    mov     r9,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L3
L13:
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
    lea     rsp,[rsp+80h]
    jmp     L4
L14:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,98h
    mov     [rsp+30h],rsi
    mov     rax,[rdi+8]
    and     rsi,rax
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rsi
    mov     qword ptr [rsp+48h],0
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rdi]
    lea     rcx,[rcx+rax]
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rax,[rsp+10h]
    test    rcx,rcx
    je      L10
    test    rax,rax
    je      L10
    cmp     rcx,rax
    jae     L1
    mov     rdx,rax
    sub     rdx,rcx
    jmp     L2
L1:
    mov     r11,rcx
    sub     r11,rax
    mov     rax,r11
    mov     rdx,rax
L2:
    cmp     rdx,10h
    jb      L10
    mov     rax,[rcx]
    mov     rcx,[rcx+8]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    mov     edx,[rsp+3Ch]
    mov     [rsp+20h],rax
    mov     [rsp+28h],ecx
    mov     [rsp+2Ch],edx
    movdqu  xmm0,[rsp+20h]
    pmovmskb eax,xmm0
    test    ax,ax
    je      L3
    movzx   eax,ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+2Ch],eax
    mov     rcx,[rsp+40h]
    add     rcx,rax
    mov     rax,[rdi+8]
    and     rcx,rax
    mov     eax,1
    jmp     L4
L3:
    mov     eax,0
    mov     ecx,0
L4:
    cmp     rax,1
    je      L6
    mov     rax,[rdi+8]
    mov     rdx,[rsp+48h]
    add     rdx,10h
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+40h]
    add     rsi,rdx
    mov     [rsp+40h],rsi
    and     rsi,rax
    mov     [rsp+40h],rsi
    jmp     L0
L5:
    add     rsp,98h
    ret
L6:
    mov     rdx,[rdi]
    movzx   esi,byte ptr [rdx+rcx]
    test    sil,80h
    jne     L8
    movdqu  xmm0,[rdx]
    pmovmskb edx,xmm0
    test    dx,dx
    je      L9
    movzx   edx,dx
    or      edx,10000h
    bsf     edx,edx
    mov     rax,rdx
L7:
    jmp     L5
L8:
    mov     rax,rcx
    jmp     L7
L9:
    mov     eax,0
    jmp     L7
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
L12:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0A0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     rdi,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L13:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0B0h]
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
    jmp     L4
L14:
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
    sub     rsp,328h
    mov     [rsp+1C8h],rbx
    mov     [rsp+1C0h],r12
    mov     [rsp+1B8h],r13
    mov     [rsp+1B0h],r14
    mov     [rsp+1A8h],r15
    mov     [rsp+1A0h],rbp
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+10h],rcx
    mov     [rsp+18h],r8
    mov     r11,[rsp+338h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+330h]
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
    lea     rdi,[rsp+170h]
    mov     rsi,[rsp+78h]
    mov     rcx,[rsp+60h]
    mov     r8,rdx
    mov     rdx,[rsp+68h]
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+170h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+90h]
    cmp     r11,0
    jne     L16
    movzx   ecx,word ptr [rsp+178h]
    movzx   edx,word ptr [rsp+17Ah]
    movzx   esi,word ptr [rsp+17Ch]
    movzx   edi,byte ptr [rsp+17Eh]
    movzx   r8d,byte ptr [rsp+17Fh]
    movzx   r9d,word ptr [rsp+180h]
    movzx   r13d,word ptr [rsp+182h]
    movzx   r14d,word ptr [rsp+184h]
    movzx   r15d,byte ptr [rsp+186h]
    movzx   ebp,byte ptr [rsp+187h]
    mov     [rsp+180h],cx
    mov     [rsp+182h],dx
    mov     [rsp+184h],si
    mov     [rsp+186h],dil
    mov     [rsp+187h],r8b
    mov     [rsp+188h],r9w
    mov     [rsp+18Ah],r13w
    mov     [rsp+18Ch],r14w
    mov     [rsp+18Eh],r15b
    mov     [rsp+18Fh],bpl
    mov     qword ptr [rsp+178h],1
    mov     byte ptr [rsp+177h],1
    mov     rax,r13
    jmp     L3
L0:
    mov     rcx,[rsp+1E0h]
    test    rcx,rcx
    jne     L4
    mov     rcx,[r13+18h]
    mov     [rsp+1E8h],rcx
    mov     rdx,[rsp+218h]
    sub     rdx,rcx
    mov     [rsp+218h],rdx
    mov     rcx,[r13+18h]
    mov     [rsp+1E8h],rcx
    mov     [rsp+220h],rcx
    mov     [rsp+1E8h],r13
    lea     rsi,[rsp+208h]
    mov     [rsp+1E0h],rsi
    mov     rsi,[r13]
    mov     rdi,[r13+8]
    mov     r8,[r13+10h]
    mov     [rsp+190h],r8
    mov     r8,[r13+18h]
    mov     [rsp+198h],r8
    mov     r8,[rsp+208h]
    mov     r9,[rsp+210h]
    mov     [r13],r8
    mov     [r13+8],r9
    mov     [r13+10h],rdx
    mov     [r13+18h],rcx
    mov     [rsp+208h],rsi
    mov     [rsp+210h],rdi
    mov     rcx,[rsp+190h]
    mov     [rsp+218h],rcx
    mov     rcx,[rsp+198h]
    mov     [rsp+220h],rcx
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
    mov     rsi,[rsp+1F8h]
    mov     rdx,[rsp+200h]
    lea     rcx,[rdi+1]
    lea     rdi,[rsp+100h]
    call    qword ptr [image.fn104.slot]
    mov     rdx,[rsp+100h]
    mov     rsi,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     rdi,[rsp+208h]
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
    mov     rbx,[rsp+1C8h]
    mov     r12,[rsp+1C0h]
    mov     r13,[rsp+1B8h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A8h]
    mov     rbp,[rsp+1A0h]
    add     rsp,328h
    ret
L4:
    movzx   eax,word ptr [rsp+1E8h]
    test    ax,ax
    je      L6
    movzx   ecx,ax
    or      ecx,10000h
    bsf     ecx,ecx
    lea     edx,[rax-1]
    and     eax,edx
    mov     [rsp+1E8h],ax
    mov     rax,[rsp+1D8h]
    add     rax,rcx
    mov     rcx,[rsp+1E0h]
    sub     rcx,1
    mov     [rsp+190h],rcx
    mov     [rsp+1E0h],rcx
    mov     r14,rax
    mov     r15,r13
    mov     rbp,[rsp+98h]
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+0A8h]
    mov     r11,[rsp+0B0h]
    mov     [rsp+0C0h],r11
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
    mov     [rsp+150h],rax
    mov     rcx,[rsp+210h]
    and     rcx,rax
    mov     [rsp+158h],rcx
    mov     [rsp+140h],rcx
    mov     qword ptr [rsp+148h],0
    jmp     L7
L6:
    mov     rcx,[rsp+1D0h]
    mov     rdx,rcx
    lea     rdx,[rdx+10h]
    mov     [rsp+1D0h],rdx
    movdqu  xmm0,[rcx+10h]
    pmovmskb edi,xmm0
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+1E8h],cx
    mov     rcx,[rsp+1D8h]
    add     rcx,10h
    mov     [rsp+1D8h],rcx
    jmp     L4
L7:
    mov     rcx,[rsp+140h]
    mov     rdx,[rsp+208h]
    lea     rdx,[rdx+rcx]
    mov     qword ptr [rsp+120h],0
    mov     qword ptr [rsp+128h],0
    lea     rcx,[rsp+120h]
    test    rdx,rdx
    je      L17
    test    rcx,rcx
    je      L17
    cmp     rdx,rcx
    jae     L8
    mov     rsi,rcx
    sub     rsi,rdx
    jmp     L9
L8:
    mov     r11,rdx
    sub     r11,rcx
    mov     rcx,r11
    mov     rsi,rcx
L9:
    cmp     rsi,10h
    jb      L17
    mov     rcx,[rdx]
    mov     rdx,[rdx+8]
    mov     [rsp+120h],rcx
    mov     [rsp+128h],rdx
    mov     [rsp+150h],rcx
    mov     [rsp+158h],rdx
    mov     esi,[rsp+15Ch]
    mov     [rsp+130h],rcx
    mov     [rsp+138h],edx
    mov     [rsp+13Ch],esi
    movdqu  xmm0,[rsp+130h]
    pmovmskb ecx,xmm0
    test    cx,cx
    je      L11
    movzx   ecx,cx
    or      ecx,10000h
    bsf     ecx,ecx
    mov     [rsp+13Ch],ecx
    mov     rdx,[rsp+140h]
    add     rdx,rcx
    mov     rcx,[rsp+210h]
    and     rdx,rcx
    mov     ecx,1
L10:
    cmp     rcx,1
    je      L12
    mov     rcx,[rsp+210h]
    mov     rsi,[rsp+148h]
    add     rsi,10h
    mov     [rsp+148h],rsi
    mov     rdi,[rsp+140h]
    add     rdi,rsi
    mov     [rsp+140h],rdi
    and     rdi,rcx
    mov     [rsp+140h],rdi
    jmp     L7
L11:
    mov     ecx,0
    mov     edx,0
    jmp     L10
L12:
    mov     rcx,[rsp+208h]
    movzx   esi,byte ptr [rcx+rdx]
    test    sil,80h
    jne     L14
    movdqu  xmm0,[rcx]
    pmovmskb ecx,xmm0
    test    cx,cx
    je      L15
    movzx   ecx,cx
    or      ecx,10000h
    bsf     ecx,ecx
L13:
    mov     rsi,[rsp+208h]
    mov     rdi,rax
    shr     rdi,39h
    and     rdi,7Fh
    lea     r8,[rcx-10h]
    mov     r9,[rsp+210h]
    and     r8,r9
    add     r8,10h
    mov     [rsi+rcx],dil
    mov     rsi,[rsp+208h]
    mov     [rsi+r8],dil
    movzx   esi,r12w
    movzx   edi,word ptr [rsp+0C0h]
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
    mov     r8,[rsp+208h]
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
    mov     r13,r15
    mov     [rsp+98h],rbp
    mov     [rsp+0A0h],rbx
    mov     [rsp+0A8h],r12
    mov     r11,[rsp+0C0h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+0C8h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+0D8h]
    mov     [rsp+88h],r11
    jmp     L0
L14:
    mov     rcx,rdx
    jmp     L13
L15:
    mov     ecx,0
    jmp     L13
L16:
    mov     rax,[rsp+178h]
    mov     rcx,[rsp+180h]
    mov     rdx,[rsp+188h]
    mov     r10,[rsp+78h]
    mov     [rsp+178h],r10
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
    mov     [rsp+180h],rsi
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
    mov     [rsp+188h],rdi
    mov     r10,[rsp+78h]
    mov     [rsp+178h],r10
    mov     [rsp+180h],rsi
    mov     [rsp+188h],rdi
    mov     r10,[rsp+90h]
    mov     [rsp+1D0h],r10
    mov     [rsp+1D8h],rax
    mov     [rsp+1E0h],rcx
    mov     [rsp+1E8h],rdx
    mov     r10,[rsp+78h]
    mov     [rsp+1F0h],r10
    mov     [rsp+1F8h],rsi
    mov     [rsp+200h],rdi
    mov     r10,[rsp+90h]
    mov     [rsp+208h],r10
    mov     [rsp+210h],rax
    mov     [rsp+218h],rcx
    mov     [rsp+220h],rdx
    mov     r11,[rsp+70h]
    mov     rbx,[r11]
    mov     [rsp+1D0h],rbx
    mov     [rsp+1E8h],rbx
    mov     [rsp+1D8h],rbx
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
    mov     [rsp+190h],ax
    mov     [rsp+192h],dx
    mov     [rsp+194h],si
    mov     [rsp+196h],dil
    mov     [rsp+197h],r8b
    mov     [rsp+198h],ecx
    mov     [rsp+19Ch],r9w
    mov     [rsp+19Eh],r12b
    mov     [rsp+19Fh],r13b
    movdqu  xmm0,[rsp+190h]
    pmovmskb eax,xmm0
    mov     rcx,rax
    mov     [rsp+1DCh],ecx
    mov     [rsp+1E0h],ax
    lea     rdi,[rsp+320h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+1E2h]
    mov     [rsp+1E4h],ax
    mov     [rsp+1E6h],ax
    mov     r11,[rsp+70h]
    mov     rcx,[r11+18h]
    mov     [rsp+1D8h],rcx
    mov     [rsp+168h],ax
    mov     [rsp+1D0h],rbx
    mov     qword ptr [rsp+1D8h],0
    mov     [rsp+1E0h],rcx
    mov     rax,[rsp+168h]
    mov     [rsp+1E8h],rax
    mov     r13,[rsp+70h]
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
L17:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k616]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+1F0h]
    lea     rsi,[rsp+208h]
    call    qword ptr [image.fn71.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+320h]
    mov     esi,0FFFFFCE0h
    call    ryo_h_Resume
    ud2
    call    sym9
    ud2
  ; OSR entries
    lea     r11,[L18]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L18:
    .long   L19
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
L19:
    pop     rcx
    lea     rdx,[rsp+280h]
    lea     rsp,[rdx-3A0h]
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
    mov     r11,[rsp+8]
    mov     [rdx-288h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-280h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-278h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2A0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-298h],r11
    mov     r13,[rsp]
    lea     rsp,[rsp+80h]
    jmp     L0
L20:
    pop     rcx
    lea     rdx,[rsp+280h]
    lea     rsp,[rdx-3A0h]
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
    mov     r11,[rsp+28h]
    mov     [rdx-260h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-258h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-248h],r11
    mov     r14,[rsp]
    mov     r15,[rsp+8]
    mov     rbp,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L5
L21:
    ret
L22:
    ret
L23:
    ret
L24:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,20h
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rdx,[rdx+10h]
    mov     [rsp+8],rax
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    mov     r13,r12
    lea     r13,[r13+20h]
    lea     rsi,[rsp+8]
    mov     rdi,r13
    call    fn0
    mov     r14,rax
    lea     rdx,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    call    qword ptr [fn4.slot]
    mov     r15,rax
    test    r15,r15
    je      L0
    lea     rdi,[rsp+8]
    call    image.sym24
    lea     rdi,[rsp+8]
    call    image.sym25
    mov     rax,0FFFFFFFFFFFFFFFFh
    mov     rcx,r15
    mov     rdx,r12
    jmp     L1
L0:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    qword ptr [fn2.slot]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
L1:
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     [rbx+18h],r12
    mov     [rbx+20h],r14
    mov     rax,rbx
    add     rsp,20h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
    mov     rbx,rax
    lea     rdi,[rsp+8]
    call    image.sym25
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    call    sym5
    ud2
    mov     rbx,rax
    jmp     L4
    mov     rbx,rax
    jmp     L4
L2:
    lea     rdi,[rsp+8]
    call    qword ptr [image.fn45.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    jmp     L3
    mov     rbx,rax
    jmp     L4
L3:
    call    sym5
    ud2
L4:
    jmp     L2
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
L6:
    ret
L7:
    ret
L8:
    ret
L9:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+8],rdx
    mov     r13,r12
    lea     r13,[r13+20h]
    lea     rsi,[rsp+8]
    mov     rdi,r13
    call    fn0
    mov     r14,rax
    lea     rdx,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    call    fn2
    test    rax,rax
    je      L0
    mov     rcx,r12
    mov     r12d,0
    jmp     L1
L0:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    fn1
    mov     rax,[rsp+8]
    mov     rcx,rax
    mov     rax,r14
L1:
    mov     [rbx],r12
    mov     [rbx+8],rax
    mov     [rbx+10h],rcx
    mov     rax,rbx
    add     rsp,18h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
    jmp     L3
    jmp     L3
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
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
L5:
    ret
L6:
    ret
L7:
    ret

fn main
    sub     rsp,6D8h
    mov     [rsp+190h],rbx
    mov     [rsp+188h],r12
    mov     qword ptr [rsp+1B8h],50910h
    lea     rax,[image.k400]
    mov     [rsp+6A8h],rax
    mov     qword ptr [rsp+6B0h],0
    mov     qword ptr [rsp+6B8h],0
    mov     qword ptr [rsp+6C0h],0
    mov     qword ptr [rsp+670h],0
    mov     qword ptr [rsp+678h],50910h
    mov     eax,1
L0:
    mov     rcx,[rsp+670h]
    mov     rdx,[rsp+678h]
    cmp     rcx,rdx
    jae     L1
    lea     rdx,[rcx+1]
    mov     [rsp+670h],rdx
    mov     rbx,rcx
    mov     ecx,1
    jmp     L2
L1:
    mov     ecx,0
L2:
    test    rcx,rcx
    je      L5
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+1B8h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rax,r10
    mov     r10,14057B7EF767814Fh
    mov     [rsp+1B8h],r10
    mov     r12,rax
    mov     r10,14057B7EF767814Fh
    add     r12,r10
    lea     rsi,[rsp+6A8h]
    mov     dword ptr [rsp+1BCh],2Ch
    mov     rdx,r12
    shr     rdx,2Ch
    lea     rdi,[rsp+58h]
    call    qword ptr [image.fn92.slot]
    mov     rax,[rsp+58h]
    test    rax,rax
    je      L4
    mov     rcx,[rsp+60h]
    mov     rdx,[rsp+68h]
L3:
    mov     [rsp+610h],rax
    mov     [rsp+618h],rcx
    mov     [rsp+620h],rdx
    mov     esi,[rsp+61Ch]
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],ecx
    mov     [rsp+1B4h],esi
    mov     [rsp+1B8h],rdx
    mov     qword ptr [rsp+1A0h],0
    lea     rdi,[rsp+1A8h]
    mov     esi,0
    call    fn11
    mov     rcx,[rax]
    mov     [rsp+1B8h],rcx
    add     rcx,rbx
    jb      L24
    mov     [rax],rcx
    mov     rax,r12
    jmp     L0
L4:
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     rdx,rcx
    mov     rcx,rax
    mov     eax,0
    jmp     L3
L5:
    mov     qword ptr [rsp+0E8h],0
    mov     qword ptr [rsp+0F0h],0
    mov     dword ptr [rsp+1BCh],14h
    mov     qword ptr [rsp+1B8h],1
    mov     qword ptr [rsp+1B8h],2
    lea     rdi,[rsp+10h]
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [image.fn96.slot]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     [rsp+590h],rax
    mov     [rsp+598h],rcx
    mov     [rsp+5A0h],rdx
    mov     [rsp+5A8h],rsi
    mov     [rsp+1A0h],rax
    mov     [rsp+1A8h],rcx
    mov     edi,[rsp+5A4h]
    mov     r8d,[rsp+5ACh]
    mov     [rsp+1B0h],edx
    mov     [rsp+1B4h],edi
    mov     [rsp+1B8h],esi
    mov     [rsp+1BCh],r8d
    mov     rdx,[rsp+1B0h]
    mov     rsi,[rsp+1B8h]
    mov     [rsp+5B0h],rax
    mov     [rsp+5B8h],rcx
    mov     [rsp+5C0h],rdx
    mov     [rsp+5C8h],rsi
    mov     [rsp+550h],rax
    mov     [rsp+558h],rcx
    mov     [rsp+560h],rdx
    mov     [rsp+568h],rsi
L6:
    mov     rax,[rsp+560h]
    add     rax,1
    test    rax,rax
    je      L22
    mov     rcx,[rsp+558h]
    test    rcx,rcx
    jbe     L7
    mov     rdx,[rsp+550h]
    add     rax,rdx
    mov     [rsp+550h],rax
    sub     rcx,1
    mov     [rsp+558h],rcx
    mov     eax,1
    jmp     L8
L7:
    mov     eax,0
    mov     edx,0
L8:
    test    rax,rax
    je      L12
    mov     [rsp+528h],rdx
    mov     rax,[rsp+6C0h]
    test    rax,rax
    jne     L9
    mov     ecx,0
    jmp     L10
L9:
    lea     rdi,[rsp+6C8h]
    lea     rsi,[rsp+528h]
    call    image.fn64
    lea     rdi,[rsp+6A8h]
    lea     rdx,[rsp+528h]
    mov     rsi,rax
    call    qword ptr [image.fn14.slot]
    test    rax,rax
    jne     L11
    mov     ecx,0
L10:
    test    rcx,rcx
    je      L6
    mov     qword ptr [rsp+1B8h],1
    mov     rdx,[rsp+0E8h]
    add     rdx,1
    jb      L25
    mov     [rsp+0E8h],rdx
    mov     rdx,[rsp+0F0h]
    mov     rcx,[rcx]
    add     rdx,rcx
    mov     [rsp+0F0h],rdx
    jmp     L6
L11:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L10
L12:
    mov     rax,[rsp+6C0h]
    mov     [rsp+100h],rax
    lea     rdi,[rsp+6A8h]
    call    qword ptr [image.fn4.slot]
    lea     rsi,[rsp+6A8h]
    lea     rdi,[rsp+490h]
    call    qword ptr [fn23.slot]
    mov     rax,[rsp+490h]
    mov     rcx,[rsp+498h]
    mov     [rsp+198h],rax
    mov     [rsp+1A0h],rcx
    mov     rax,[rsp+4A0h]
    mov     ecx,[rsp+4A8h]
    mov     edx,[rsp+4ACh]
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],ecx
    mov     [rsp+1B4h],edx
    mov     rax,[rsp+4B0h]
    mov     [rsp+1B8h],rax
    lea     rdi,[rsp+198h]
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+108h],rax
    lea     rax,[image.k400]
    mov     [rsp+468h],rax
    mov     qword ptr [rsp+470h],0
    mov     qword ptr [rsp+478h],0
    mov     qword ptr [rsp+480h],0
    mov     r10,1FBD000000000h
    mov     [rsp+450h],r10
L13:
    mov     eax,[rsp+450h]
    mov     ecx,[rsp+454h]
    cmp     eax,ecx
    jae     L14
    lea     ecx,[rax+1]
    mov     [rsp+450h],ecx
    mov     rcx,rax
    mov     eax,1
    jmp     L15
L14:
    mov     eax,0
L15:
    mov     eax,eax
    test    rax,rax
    je      L20
    mov     dword ptr [rsp+1BCh],138Bh
    mov     eax,ecx
    mov     [rsp+1B8h],rax
    mov     r10d,0D196E5F5h
    imul    rax,r10
    mov     [rsp+1B8h],rax
    shr     rax,2Ch
    mov     [rsp+1B8h],rax
    mov     [rsp+1B4h],eax
    imul    eax,138Bh
    mov     [rsp+1B4h],eax
    sub     ecx,eax
    mov     [rsp+3A4h],ecx
    lea     rax,[rsp+3A4h]
    mov     rcx,[image.sym2]
    mov     [rsp+380h],rax
    mov     [rsp+388h],rcx
    mov     [rsp+390h],rax
    mov     [rsp+398h],rcx
    lea     rax,[k32]
    lea     rcx,[rsp+390h]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rcx
    mov     rdx,rcx
    and     rdx,1
    cmp     rdx,1
    je      L16
    mov     eax,0
    mov     ecx,0
    jmp     L17
L16:
    shr     rcx,1
    test    rax,rax
    je      L23
L17:
    lea     rdx,[rsp+98h]
    lea     rdi,[rsp+78h]
    mov     rsi,rax
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [image.fn0.slot]
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     rdx,[rsp+88h]
    mov     [rsp+3C8h],rax
    mov     [rsp+3D0h],rcx
    mov     [rsp+3D8h],rdx
    mov     esi,[rsp+3D4h]
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],ecx
    mov     [rsp+1B4h],esi
    mov     [rsp+1B8h],rdx
    mov     rcx,[rsp+1B0h]
    mov     [rsp+3E0h],rax
    mov     [rsp+3E8h],rcx
    mov     [rsp+3F0h],rdx
    mov     esi,[rsp+3ECh]
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],ecx
    mov     [rsp+1B4h],esi
    mov     [rsp+1B8h],rdx
    mov     rcx,[rsp+1B0h]
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],rcx
    mov     [rsp+0E0h],rdx
    lea     rdi,[rsp+0A8h]
    lea     rdx,[rsp+0D0h]
    lea     rsi,[rsp+468h]
    call    qword ptr [image.fn91.slot]
    mov     rax,[rsp+0A8h]
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L19
    mov     rcx,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    mov     rsi,[rsp+0C0h]
    mov     rdi,[rsp+0C8h]
L18:
    mov     [rsp+400h],rax
    mov     [rsp+408h],rcx
    mov     [rsp+410h],rdx
    mov     [rsp+418h],rsi
    mov     [rsp+420h],rdi
    mov     [rsp+198h],rax
    mov     [rsp+1A0h],rcx
    mov     eax,[rsp+41Ch]
    mov     [rsp+1A8h],rdx
    mov     [rsp+1B0h],esi
    mov     [rsp+1B4h],eax
    mov     [rsp+1B8h],rdi
    lea     rdi,[rsp+198h]
    call    qword ptr [fn37.slot]
    mov     rcx,[rax]
    mov     [rsp+1B8h],rcx
    mov     qword ptr [rsp+1B0h],1
    add     rcx,1
    jb      L26
    mov     [rax],rcx
    jmp     L13
L19:
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     rdx,rcx
    mov     rcx,rax
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L18
L20:
    mov     rax,[rsp+6C0h]
    mov     [rsp+110h],rax
    lea     rax,[rsp+110h]
    mov     rcx,[rsp+480h]
    mov     [rsp+118h],rcx
    lea     rcx,[rsp+118h]
    lea     rdx,[rsp+100h]
    lea     rsi,[rsp+0E8h]
    lea     rdi,[rsp+0F0h]
    lea     r8,[rsp+108h]
    mov     r9,[image.sym1]
    mov     rbx,[image.sym3]
    mov     [rsp+120h],rdx
    mov     [rsp+128h],r9
    mov     [rsp+130h],rsi
    mov     [rsp+138h],rbx
    mov     [rsp+140h],rdi
    mov     [rsp+148h],rbx
    mov     [rsp+150h],rax
    mov     [rsp+158h],r9
    mov     [rsp+160h],r8
    mov     [rsp+168h],rbx
    mov     [rsp+170h],rcx
    mov     [rsp+178h],r9
    lea     rdi,[k47]
    lea     rsi,[rsp+120h]
    call    sym49
    lea     rdi,[rsp+468h]
    mov     [rsp+1B8h],rdi
    lea     rsi,[rsp+488h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn20.slot]
    lea     rax,[rsp+6A8h]
    mov     [rsp+1B8h],rax
    mov     rax,[rsp+6B0h]
    mov     [rsp+48h],rax
    test    rax,rax
    je      L21
    lea     rcx,[rax+1]
    lea     rdi,[rsp+38h]
    mov     esi,10h
    mov     edx,10h
    call    qword ptr [image.fn104.slot]
    mov     rdx,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+6A8h]
    mov     [rsp+38h],rcx
    mov     [rsp+40h],rcx
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+38h],rax
    lea     rdi,[rcx+rax]
    mov     [rsp+48h],rdi
    test    rsi,rsi
    je      L21
    call    image.sym40
L21:
    mov     rbx,[rsp+190h]
    mov     r12,[rsp+188h]
    add     rsp,6D8h
    ret
L22:
    lea     rcx,[image.k5048]
    lea     rdi,[image.k3410]
    mov     esi,1A3h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L23:
    lea     rdi,[image.k4467]
    lea     rcx,[image.k2136]
    mov     esi,22Fh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
L24:
    lea     rdi,[k12]
    mov     [rsp+1B8h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
L25:
    lea     rdi,[k19]
    mov     [rsp+1B8h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     rbx,rax
    jmp     L30
    mov     rbx,rax
    jmp     L30
    mov     rbx,rax
    jmp     L30
L26:
    lea     rdi,[k38]
    mov     [rsp+1B8h],rdi
    call    sym13
    ud2
    mov     rbx,rax
    jmp     L30
    mov     rbx,rax
    jmp     L30
    mov     r12,rax
    jmp     L28
L27:
    lea     rdi,[rsp+468h]
    mov     [rsp+1B8h],rdi
    lea     rsi,[rsp+488h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn20.slot]
    mov     r12,rbx
    jmp     L28
    jmp     L29
L28:
    lea     rdi,[rsp+6A8h]
    mov     [rsp+1B8h],rdi
    lea     rsi,[rsp+6C8h]
    mov     edx,10h
    mov     ecx,10h
    call    qword ptr [image.fn21.slot]
    mov     [rsp],r12
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFF930h
    call    ryo_h_Resume
    ud2
L29:
    call    sym54
    ud2
L30:
    jmp     L27
  ; OSR entries
    lea     r11,[L31]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L31:
    .long   L32
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
L32:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-770h]
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
    mov     r11,[rsp+8]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-570h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-568h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-560h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-558h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-5E8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+0A0h]
    jmp     L0
L33:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-760h]
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
    mov     r11,[rsp]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-570h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-568h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-560h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-558h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-5E8h],r11
    lea     rsp,[rsp+90h]
    jmp     L6
L34:
    pop     rcx
    lea     rdx,[rsp+540h]
    lea     rsp,[rdx-760h]
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
    mov     r11,[rsp]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-580h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-578h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-570h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-568h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-560h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-558h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-5E8h],r11
    lea     rsp,[rsp+90h]
    jmp     L13
L35:
    ret
L36:
    ret
L37:
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
    sub     rsp,28h
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    lea     rax,[rsp+10h]
    test    rsi,rsi
    je      L2
    test    rax,rax
    je      L2
    cmp     rsi,rax
    jae     L0
    mov     rcx,rax
    sub     rcx,rsi
    jmp     L1
L0:
    mov     r11,rsi
    sub     r11,rax
    mov     rax,r11
    mov     rcx,rax
L1:
    cmp     rcx,10h
    jb      L2
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    add     rsp,28h
    ret
L2:
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

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::entry
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+8],rdx
    mov     r13,r12
    lea     r13,[r13+20h]
    lea     rsi,[rsp+8]
    mov     rdi,r13
    call    image.fn64
    mov     r14,rax
    lea     rdx,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    call    qword ptr [image.fn15.slot]
    test    rax,rax
    je      L0
    mov     rcx,r12
    mov     r12d,0
    jmp     L1
L0:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    qword ptr [image.fn16.slot]
    mov     rax,[rsp+8]
    mov     rcx,rax
    mov     rax,r14
L1:
    test    r12,r12
    je      L3
L2:
    mov     [rbx],r12
    mov     [rbx+8],rax
    mov     [rbx+10h],rcx
    mov     rax,rbx
    add     rsp,18h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L3:
    mov     r12d,0
    jmp     L2
    jmp     L4
    jmp     L4
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
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
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    test    rax,rax
    je      L2
    mov     rdi,rax
    mov     r10,rsi
    mov     rsi,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    lea     rax,[rax-8]
L0:
    add     rsp,18h
    ret
L1:
    mov     rax,rcx
    lea     rax,[rax-8]
    jmp     L0
L2:
    jmp     L1
    jmp     L4
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
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
    .long   L11
    .long   L12
    .long   L13
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

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,50h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    test    r12,r12
    je      L5
    mov     dword ptr [rsp+30h],1
    mov     word ptr [rsp+34h],0
    mov     byte ptr [rsp+36h],0
    mov     byte ptr [rsp+37h],0
    mov     r14,[rsp+30h]
    lea     rdi,[rsp+18h]
    mov     rsi,r13
    mov     edx,0
    mov     ecx,1
    mov     r8,r14
    movzx   edx,dl
    call    image.sym36
    mov     rax,[rsp+18h]
    test    rax,rax
    jne     L8
    mov     r15,[rsp+20h]
    mov     eax,[rsp+28h]
    movzx   edx,word ptr [rsp+2Ch]
    movzx   esi,byte ptr [rsp+2Eh]
    movzx   edi,byte ptr [rsp+2Fh]
    test    r14,r14
    je      L1
    mov     r8,r15
L0:
    cmp     r8,r13
    setb    r8b
    test    r8b,r8b
    jne     L7
    mov     r8,rax
    mov     r9,rdx
    shl     r9,20h
    or      r8,r9
    mov     r9,rsi
    shl     r9,30h
    or      r8,r9
    mov     r9,rdi
    shl     r9,38h
    mov     r14,r8
    or      r14,r9
    test    r13,r13
    jbe     L4
    mov     qword ptr [rsp+30h],1
    test    r14,r14
    je      L9
    cmp     r12,r14
    jae     L2
    mov     r8,r14
    sub     r8,r12
    jmp     L3
L1:
    mov     r8,0FFFFFFFFFFFFFFFFh
    jmp     L0
L2:
    mov     rax,r12
    sub     rax,r14
    mov     r8,rax
L3:
    cmp     r13,r8
    ja      L9
    mov     [rsp+30h],r13
    mov     [rsp],r14
    mov     [rsp+8],r12
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFC0h
    call    ryo_h_Memcpy
    lea     rax,[image.k864]
    mov     [rsp+30h],rax
    cmp     r15,r13
    jb      L10
    mov     rcx,r15
    mov     rdx,r14
    mov     rsi,r13
    jmp     L6
L4:
    mov     rcx,r15
    mov     rdx,r14
    mov     esi,0
    jmp     L6
L5:
    mov     rsi,[rcx]
    mov     rdx,[rcx+8]
    lea     rdi,[rsp+38h]
    call    image.sym26
    mov     rcx,[rsp+38h]
    mov     rdx,[rsp+40h]
    mov     rsi,[rsp+48h]
L6:
    mov     [rbx],rcx
    mov     [rbx+8],rdx
    mov     [rbx+10h],rsi
    mov     rax,rbx
    add     rsp,50h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L7:
    lea     rdi,[image.k4185]
    lea     rcx,[image.k1760]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L8:
    mov     rdi,[rsp+20h]
    mov     ecx,[rsp+28h]
    movzx   edx,word ptr [rsp+2Ch]
    movzx   esi,byte ptr [rsp+2Eh]
    movzx   r8d,byte ptr [rsp+2Fh]
    shl     rdx,20h
    or      rcx,rdx
    shl     rsi,30h
    or      rcx,rsi
    shl     r8,38h
    mov     rsi,rcx
    or      rsi,r8
    call    image.sym37
    ud2
L9:
    lea     rdi,[image.k3619]
    lea     rcx,[image.k840]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym38
    ud2
L10:
    lea     rdi,[image.k3212]
    mov     esi,18Dh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym38
    ud2
    mov     ecx,1
    jmp     L14
    mov     ecx,0
    jmp     L14
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L12:
    jmp     L11
L13:
    test    cl,cl
    jne     L12
    jmp     L11
L14:
    jmp     L13
  ; OSR entries
    lea     r11,[L15]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L15:
    .long   L16
    .long   L17
    .long   L18
    .long   L19
L16:
    ret
L17:
    ret
L18:
    ret
L19:
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

