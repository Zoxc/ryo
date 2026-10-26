fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,68h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     rax,[rbx+30h]
    add     rax,r13
    mov     [rbx+30h],rax
    mov     rax,[rbx+40h]
    test    rax,rax
    je      L0
    jmp     L1
L0:
    mov     r14d,0
    jmp     L14
L1:
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+60h],r14
    cmp     r14,r13
    jae     L2
    mov     rax,r14
    jmp     L3
L2:
    mov     rax,r13
L3:
    mov     r11d,3
    cmp     r11,rax
    jb      L5
    jmp     L4
L4:
    mov     edx,0
    mov     esi,0
    jmp     L8
L5:
    mov     dword ptr [rsp+40h],0
    lea     rdx,[rsp+40h]
    lea     r11,[image.k3192]
    mov     [rsp+28h],r11
    test    r12,r12
    je      L30
    test    rdx,rdx
    je      L30
    cmp     r12,rdx
    jae     L6
    mov     rsi,rdx
    sub     rsi,r12
    jmp     L7
L6:
    mov     r11,r12
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L7:
    cmp     rsi,4
    jb      L30
    mov     edx,[r12]
    mov     [rsp+40h],edx
    mov     rsi,rdx
    mov     edx,4
L8:
    lea     rdi,[rdx+1]
    cmp     rdi,rax
    jae     L11
    mov     word ptr [rsp+34h],0
    lea     rdi,[r12+rdx]
    lea     r8,[rsp+34h]
    lea     r11,[image.k3216]
    mov     [rsp+20h],r11
    test    rdi,rdi
    je      L31
    test    r8,r8
    je      L31
    cmp     rdi,r8
    jae     L9
    mov     r15,r8
    sub     r15,rdi
    jmp     L10
L9:
    mov     r11,rdi
    sub     r11,r8
    mov     r8,r11
    mov     r15,r8
L10:
    cmp     r15,2
    jb      L31
    movzx   edi,word ptr [rdi]
    mov     [rsp+34h],di
    mov     r8,rdx
    imul    r8,8
    mov     rcx,r8
    shl     rdi,cl
    or      rsi,rdi
    add     rdx,2
L11:
    cmp     rdx,rax
    jae     L12
    lea     r11,[image.k3320]
    mov     [rsp+18h],r11
    cmp     rdx,r13
    jae     L32
    mov     byte ptr [rsp+35h],1
    lea     rdi,[r12+rdx]
    movzx   edi,byte ptr [rdi]
    imul    rdx,8
    mov     rcx,rdx
    shl     rdi,cl
    or      rsi,rdi
L12:
    mov     rdx,[rbx+40h]
    mov     [rsp+60h],rdx
    imul    rdx,8
    mov     rcx,rdx
    shl     rsi,cl
    mov     rdx,[rbx+38h]
    or      rdx,rsi
    mov     [rbx+38h],rdx
    cmp     r13,r14
    jae     L13
    mov     rsi,[rbx+40h]
    add     rsi,r13
    mov     [rbx+40h],rsi
    jmp     L29
L13:
    mov     rsi,[rbx+18h]
    xor     rsi,rdx
    mov     [rbx+18h],rsi
    mov     rdi,rbx
    call    fn1
    mov     rdx,[rbx+38h]
    mov     rsi,[rbx]
    xor     rsi,rdx
    mov     [rbx],rsi
    mov     qword ptr [rbx+40h],0
L14:
    mov     rdx,r13
    sub     rdx,r14
    mov     rsi,rdx
    and     rsi,7
    mov     [rsp+10h],r13
    mov     r13,r12
    mov     r12,rsi
    mov     rbp,rbx
    mov     rbx,rdx
L15:
    mov     [rsp+60h],r14
    mov     rdx,rbx
    sub     rdx,r12
    cmp     r14,rdx
    jae     L19
    mov     qword ptr [rsp+60h],0
    lea     rdx,[r13+r14]
    lea     rsi,[rsp+60h]
    lea     rdi,[k4]
    test    rdx,rdx
    je      L33
    test    rsi,rsi
    je      L33
    cmp     rdx,rsi
    jae     L16
    mov     r8,rsi
    sub     r8,rdx
    jmp     L17
L16:
    mov     r11,rdx
    sub     r11,rsi
    mov     rsi,r11
    mov     r8,rsi
L17:
    cmp     r8,8
    jb      L33
    mov     r15,[rdx]
    mov     [rsp+60h],r15
    mov     rdx,[rbp+18h]
    xor     rdx,r15
    mov     [rbp+18h],rdx
    mov     [rsp+60h],rbp
    mov     rdi,rbp
    call    fn1
    mov     rdx,rbp
    mov     rsi,r14
    mov     r8,r12
    mov     rax,r13
    mov     r9,[rsp+10h]
L18:
    mov     rcx,[rdx]
    xor     rcx,r15
    mov     [rdx],rcx
    add     rsi,8
    mov     r14,rsi
    mov     r12,r8
    mov     r13,rax
    mov     [rsp+10h],r9
    mov     rbp,rdx
    jmp     L15
L19:
    mov     r11d,3
    cmp     r11,r12
    jb      L21
    jmp     L20
L20:
    mov     eax,0
    mov     edx,0
    jmp     L24
L21:
    mov     dword ptr [rsp+50h],0
    lea     rax,[r13+r14]
    lea     rdx,[rsp+50h]
    lea     rcx,[image.k3192]
    test    rax,rax
    je      L34
    test    rdx,rdx
    je      L34
    cmp     rax,rdx
    jae     L22
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L23
L22:
    mov     r11,rax
    sub     r11,rdx
    mov     rdx,r11
    mov     rsi,rdx
L23:
    cmp     rsi,4
    jb      L34
    mov     eax,[rax]
    mov     [rsp+50h],eax
    mov     rdx,rax
    mov     eax,4
L24:
    lea     rsi,[rax+1]
    cmp     rsi,r12
    jae     L27
    mov     word ptr [rsp+44h],0
    lea     rsi,[r14+rax]
    lea     rsi,[r13+rsi]
    lea     r8,[rsp+44h]
    lea     r9,[image.k3216]
    test    rsi,rsi
    je      L35
    test    r8,r8
    je      L35
    cmp     rsi,r8
    jae     L25
    mov     rbx,r8
    sub     rbx,rsi
    jmp     L26
L25:
    mov     r11,rsi
    sub     r11,r8
    mov     r8,r11
    mov     rbx,r8
L26:
    cmp     rbx,2
    jb      L35
    movzx   esi,word ptr [rsi]
    mov     [rsp+44h],si
    mov     r8,rax
    imul    r8,8
    mov     rcx,r8
    shl     rsi,cl
    or      rdx,rsi
    add     rax,2
L27:
    cmp     rax,r12
    jae     L28
    add     r14,rax
    lea     rsi,[image.k3320]
    cmp     r14,[rsp+10h]
    jae     L36
    mov     byte ptr [rsp+45h],1
    lea     r13,[r13+r14]
    movzx   r8d,byte ptr [r13]
    imul    rax,8
    mov     rcx,rax
    shl     r8,cl
    or      rdx,r8
L28:
    mov     [rbp+38h],rdx
    mov     [rbp+40h],r12
L29:
    add     rsp,68h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L30:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+28h]
    movzx   edx,dl
    call    image.sym63
    ud2
L31:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+20h]
    movzx   edx,dl
    call    image.sym63
    ud2
L32:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym63
    ud2
L33:
    lea     rax,[image.k4515]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L34:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L35:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym63
    ud2
L36:
    lea     rdi,[image.k6416]
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1ADh
    movzx   edx,dl
    call    image.sym63
    ud2
  ; OSR entries
    lea     r11,[L37]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L37:
    .long   L38
    .long   L39
    .long   L40
L38:
    ret
L39:
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
    mov     [rdx-80h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L15
L40:
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
    mov     r15,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     r9,[rsp+30h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L18

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

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    jmp     L2
L0:
    add     rsp,18h
    ret
L1:
    mov     rcx,[rdi]
    mov     r11,[rcx]
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

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     rdx,rax
    mov     r10,736F6D6570736575h
    xor     rdx,r10
    mov     rsi,rcx
    mov     r10,646F72616E646F6Dh
    xor     rsi,r10
    mov     r8,rax
    mov     r10,6C7967656E657261h
    xor     r8,r10
    mov     r9,rcx
    mov     r10,7465646279746573h
    xor     r9,r10
    mov     [rdi],rdx
    mov     [rdi+8],r8
    mov     [rdi+10h],rsi
    mov     [rdi+18h],r9
    mov     [rdi+20h],rax
    mov     [rdi+28h],rcx
    mov     qword ptr [rdi+30h],0
    mov     qword ptr [rdi+38h],0
    mov     qword ptr [rdi+40h],0
    mov     rax,rdi
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,98h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,rax
    mov     r10,736F6D6570736575h
    xor     rdx,r10
    mov     rdi,rcx
    mov     r10,646F72616E646F6Dh
    xor     rdi,r10
    mov     r8,rax
    mov     r10,6C7967656E657261h
    xor     r8,r10
    mov     r9,rcx
    mov     r10,7465646279746573h
    xor     r9,r10
    mov     [rsp+48h],rdx
    mov     [rsp+50h],r8
    mov     [rsp+58h],rdi
    mov     [rsp+60h],r9
    mov     [rsp+68h],rax
    mov     [rsp+70h],rcx
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
    jae     L6
    mov     qword ptr [rsp+10h],0
    lea     r15,[rbx+r14]
    mov     rdi,r15
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L3
    jmp     L7
L1:
    lea     rdi,[rsp+10h]
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L4
    jmp     L7
L2:
    lea     rsi,[rsp+10h]
    mov     rdi,r15
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    test    al,al
    je      L7
    mov     rbp,[r15]
    mov     [rsp+10h],rbp
    mov     rax,[rsp+60h]
    xor     rax,rbp
    mov     [rsp+60h],rax
    lea     rdi,[rsp+48h]
    mov     [rsp+10h],rdi
    call    image.fn208
    jmp     L5
L3:
    test    r15,r15
    je      L7
    jmp     L1
L4:
    lea     rax,[rsp+10h]
    test    rax,rax
    je      L7
    jmp     L2
L5:
    mov     rax,[rsp+48h]
    xor     rax,rbp
    mov     [rsp+48h],rax
    lea     rax,[r14+8]
    mov     r14,rax
    jmp     L0
L6:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r13
    call    image.fn158
    mov     [rsp+80h],rax
    mov     [rsp+88h],r13
    mov     byte ptr [rsp+1Fh],0FFh
    lea     rsi,[rsp+1Fh]
    lea     rdi,[rsp+48h]
    mov     edx,1
    call    image.fn197
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
    call    image.fn209
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+30h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rcx,[rsp+38h]
    xor     rax,rcx
    add     rsp,98h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
    jmp     L8
    jmp     L8
    jmp     L8
L7:
    lea     rdi,[image.k4515]
    lea     rcx,[image.k6632]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L8:
    call    image.sym30
    ud2
    jmp     L9
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
L11:
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    push    rbx
    push    r12
    push    r13
    sub     rsp,0A0h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,rax
    mov     r10,736F6D6570736575h
    xor     rdx,r10
    mov     rdi,rcx
    mov     r10,646F72616E646F6Dh
    xor     rdi,r10
    mov     r8,rax
    mov     r10,6C7967656E657261h
    xor     r8,r10
    mov     r9,rcx
    mov     r10,7465646279746573h
    xor     r9,r10
    mov     [rsp+58h],rdx
    mov     [rsp+60h],r8
    mov     [rsp+68h],rdi
    mov     [rsp+70h],r9
    mov     [rsp+78h],rax
    mov     [rsp+80h],rcx
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
    jae     L6
    mov     qword ptr [rsp+10h],0
    lea     rax,[rsp+20h]
    lea     r12,[rax+rbx]
    mov     rdi,r12
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L3
    jmp     L7
L1:
    lea     rdi,[rsp+10h]
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L4
    jmp     L7
L2:
    lea     rsi,[rsp+10h]
    mov     rdi,r12
    mov     edx,1
    mov     ecx,8
    call    qword ptr [image.fn171.slot]
    test    al,al
    je      L7
    mov     r13,[r12]
    mov     [rsp+10h],r13
    mov     rax,[rsp+70h]
    xor     rax,r13
    mov     [rsp+70h],rax
    lea     rdi,[rsp+58h]
    mov     [rsp+10h],rdi
    call    image.fn208
    jmp     L5
L3:
    test    r12,r12
    je      L7
    jmp     L1
L4:
    lea     rax,[rsp+10h]
    test    rax,rax
    je      L7
    jmp     L2
L5:
    mov     rax,[rsp+58h]
    xor     rax,r13
    mov     [rsp+58h],rax
    lea     rax,[rbx+8]
    mov     rbx,rax
    jmp     L0
L6:
    lea     rdi,[rsp+20h]
    mov     esi,8
    mov     rdx,rbx
    mov     ecx,0
    call    qword ptr [image.fn158.slot]
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
    call    qword ptr [image.fn209.slot]
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+40h]
    xor     rax,rcx
    mov     rcx,[rsp+38h]
    xor     rax,rcx
    mov     rcx,[rsp+48h]
    xor     rax,rcx
    add     rsp,0A0h
    pop     r13
    pop     r12
    pop     rbx
    ret
    jmp     L8
    jmp     L8
    jmp     L8
L7:
    lea     rdi,[image.k4515]
    lea     rcx,[image.k6632]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L8:
    call    image.sym30
    ud2
    jmp     L9
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
L11:
    ret

fn core::core_arch::simd::Simd::<i8, 16>::splat
    push    rbx
    sub     rsp,30h
    mov     rbx,rdi
    mov     [rsp+2Fh],sil
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     rax,rbx
    add     rsp,30h
    pop     rbx
    ret

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    ret

fn core::hash::sip::u8to64_le
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,28h
    mov     rax,rcx
    mov     r11d,3
    cmp     r11,rax
    jb      L1
    jmp     L0
L0:
    mov     r8d,0
    mov     r9d,0
    jmp     L4
L1:
    mov     dword ptr [rsp+20h],0
    lea     r8,[rdi+rdx]
    lea     r9,[rsp+20h]
    lea     rcx,[k0]
    test    r8,r8
    je      L9
    test    r9,r9
    je      L9
    cmp     r8,r9
    jae     L2
    mov     rbx,r9
    sub     rbx,r8
    jmp     L3
L2:
    mov     r11,r8
    sub     r11,r9
    mov     r9,r11
    mov     rbx,r9
L3:
    cmp     rbx,4
    jb      L9
    mov     r8d,[r8]
    mov     [rsp+20h],r8d
    mov     r9,r8
    mov     r8d,4
L4:
    lea     rbx,[r8+1]
    cmp     rbx,rax
    jae     L7
    mov     word ptr [rsp+14h],0
    lea     rbx,[rdx+r8]
    lea     rbx,[rdi+rbx]
    lea     r12,[rsp+14h]
    lea     r13,[k2]
    test    rbx,rbx
    je      L10
    test    r12,r12
    je      L10
    cmp     rbx,r12
    jae     L5
    mov     r14,r12
    sub     r14,rbx
    jmp     L6
L5:
    mov     r11,rbx
    sub     r11,r12
    mov     r12,r11
    mov     r14,r12
L6:
    cmp     r14,2
    jb      L10
    movzx   ebx,word ptr [rbx]
    mov     [rsp+14h],bx
    mov     r12,r8
    imul    r12,8
    mov     rcx,r12
    shl     rbx,cl
    or      r9,rbx
    add     r8,2
L7:
    cmp     r8,rax
    jae     L8
    add     rdx,r8
    lea     rax,[k4]
    cmp     rdx,rsi
    jae     L11
    mov     byte ptr [rsp+15h],1
    lea     rdi,[rdi+rdx]
    movzx   edx,byte ptr [rdi]
    imul    r8,8
    mov     rcx,r8
    shl     rdx,cl
    or      r9,rdx
L8:
    mov     rax,r9
    add     rsp,28h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L10:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym63
    ud2
L11:
    lea     rdi,[image.k6416]
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
  ; OSR entries
    lea     r11,[L12]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L12:
    .long   L13
    .long   L14
    .long   L15
L13:
    ret
L14:
    ret
L15:
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,108h
    mov     [rsp+68h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+58h],r13
    mov     [rsp+50h],r14
    mov     [rsp+48h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,[rbx]
    mov     [rsp+88h],r12
    mov     [rsp+80h],r12
    mov     [rsp+90h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    lea     rdi,[rsp+20h]
    mov     rsi,r13
    call    image.sym19
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    lea     rdi,[rsp+30h]
    call    image.sym20
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     qword ptr [rsp+38h],10h
    lea     r13,[r13+10h]
    mov     [rsp+70h],r12
    mov     [rsp+78h],r13
    mov     [rsp+80h],r14
    mov     [rsp+88h],ax
    mov     [rsp+8Ah],r10d
    mov     [rsp+8Eh],r10w
    jmp     L6
L0:
    mov     rax,[rsp+90h]
    test    rax,rax
    je      L2
    lea     rdi,[rsp+70h]
    call    fn2
    jmp     L7
L1:
    mov     rsi,rcx
    lea     rsi,[rsi-10h]
    jmp     L9
L2:
    mov     rbx,[rsp+68h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+58h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+48h]
    mov     rbp,[rsp+40h]
    add     rsp,108h
    ret
L3:
    test    cl,cl
    jne     L4
    jmp     L5
L4:
    mov     [rsp+10h],r15
    jmp     L0
L5:
    mov     rcx,[r15]
    sub     rcx,rbp
    mov     rsi,rcx
    sar     rsi,4
    mov     rdi,r15
    call    qword ptr [image.fn146.slot]
    mov     rdi,rbp
    lea     rdi,[rdi-10h]
    call    image.sym22
    mov     [rsp+10h],r15
    jmp     L0
L6:
    mov     rcx,[rbx+18h]
    mov     rdx,[rsp+88h]
    mov     [rsp+70h],r12
    mov     [rsp+78h],r13
    mov     [rsp+80h],r14
    mov     [rsp+88h],rdx
    mov     [rsp+90h],rcx
    mov     [rsp+10h],rbx
    jmp     L0
L7:
    mov     rcx,[rsp+90h]
    sub     rcx,1
    mov     [rsp+90h],rcx
    test    rax,rax
    je      L2
    mov     rcx,rax
    mov     rdx,[rsp+10h]
    jmp     L1
L8:
    mov     rax,[rax]
    mov     r11d,3
    mov     rax,rax
    xor     edx,edx
    div     r11
    test    rdx,rdx
    setne   al
    mov     rbp,rcx
    mov     rcx,rax
    mov     r15,rsi
    jmp     L3
L9:
    mov     rax,rsi
    mov     rsi,rdx
    jmp     L8
    jmp     L11
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L11
    mov     rcx,rax
    mov     rax,rcx
L11:
    jmp     L10
  ; OSR entries
    lea     r11,[L12]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L12:
    .long   L13
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
    .long   L19
    .long   L20
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-8]
    mov     [rsp],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     [rdx-0B8h],r15
    mov     [rdx-0C0h],rbp
    mov     r11,[rsp]
    mov     [rdx-0F0h],r11
    lea     rsp,[rsp+10h]
    jmp     L0
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-98h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     [rdx-98h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0A8h],r13
    mov     [rdx-0B0h],r14
    mov     [rdx-0B8h],r15
    mov     [rdx-0C0h],rbp
    mov     rcx,[rsp]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+10h]
    jmp     L1
L15:
    ret
L16:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0B8h],r15
    mov     [rdx-0C0h],rbp
    mov     rcx,[rsp]
    mov     rbp,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L3
L17:
    ret
L18:
    ret
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0B8h],r15
    mov     [rdx-0C0h],rbp
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L8
L20:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0B8h],r15
    mov     [rdx-0C0h],rbp
    mov     rsi,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L9

fn hashbrown::raw::FullBucketsIndices::next_impl
    sub     rsp,0A8h
    mov     [rsp+28h],rbx
    mov     [rsp+20h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    test    r12w,r12w
    je      L1
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    lea     ecx,[r12-1]
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     rcx,[rbx+8]
    lea     rdx,[rcx+rax]
    mov     eax,1
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rbx]
    mov     qword ptr [rsp+18h],10h
    mov     rsi,rax
    lea     rsi,[rsi+10h]
    mov     [rbx],rsi
    lea     rdi,[rsp+30h]
    call    sym1
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    lea     rdi,[rsp+10h]
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    mov     [rsp+18h],rax
    add     rax,10h
    mov     [rsp+10h],rax
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
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+10h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     r11,[rsp+8]
    mov     [rdx-90h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-88h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    sub     rsp,0B8h
    mov     [rsp+28h],rbx
    mov     [rsp+20h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    test    r12w,r12w
    je      L6
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    lea     ecx,[r12-1]
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    jmp     L8
L1:
    mov     rdx,[rax+8]
    mov     rsi,[rax+10h]
    cmp     rdx,rsi
    jb      L2
    jmp     L3
L2:
    mov     r12,rax
    jmp     L4
L3:
    mov     eax,0
    jmp     L5
L4:
    mov     rsi,[r12+8]
    lea     rdi,[rsp+30h]
    call    sym0
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+10h]
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r12+18h],ax
    mov     rax,[r12]
    lea     rax,[rax-200h]
    jmp     L10
L5:
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    add     rsp,0B8h
    ret
L6:
    mov     r12,rbx
    jmp     L4
L7:
    mov     rax,rcx
    jmp     L5
L8:
    jmp     L7
L9:
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L10:
    mov     rcx,r12
    jmp     L9
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
    .long   L19
L12:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L1
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L4
L15:
    ret
L16:
    ret
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L10

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,118h
    mov     [rsp+58h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+48h],r13
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+0D0h],rcx
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     r11,[rdi+10h]
    movzx   r8d,word ptr [rdi+18h]
    mov     r11d,[rdi+1Ah]
    movzx   r11d,word ptr [rdi+1Eh]
    mov     rbx,r8
    mov     r12,rsi
    mov     r13,rdx
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rax
L0:
    test    bx,bx
    je      L4
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    lea     ecx,[rbx-1]
    and     ebx,ecx
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,[rsp+18h]
    mov     rax,r11
    mov     rcx,rax
    mov     rdx,rbx
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    jmp     L6
L1:
    sub     rcx,1
    mov     rbx,rdx
    mov     r12,rcx
    mov     r13,rax
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdi
    jmp     L0
L2:
    mov     rax,r13
    mov     rbx,[rsp+58h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+48h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+38h]
    mov     rbp,[rsp+30h]
    add     rsp,118h
    ret
L3:
    lea     rdi,[rsp+60h]
    mov     rsi,rbx
    call    sym0
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    lea     rdi,[rsp+20h]
    call    sym3
    jmp     L7
L4:
    test    r12,r12
    je      L2
    mov     rbx,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r14,r12
    mov     r15,r13
    jmp     L3
L5:
    mov     r12,[rsp+0D0h]
    mov     r11,[r12]
    mov     rcx,[rcx-8]
    add     rdx,rcx
    mov     rax,rdx
    mov     rcx,rsi
    mov     rdx,rdi
    mov     rsi,r8
    mov     rdi,r9
    jmp     L1
L6:
    mov     r8,rsi
    mov     rsi,r12
    mov     r9,rdi
    mov     rdi,rdx
    mov     rdx,r13
    jmp     L5
L7:
    mov     rdi,rax
    call    ryo_hr_NotW16
    lea     rbp,[rbp-100h]
    jmp     L9
L8:
    lea     rcx,[rcx+10h]
    mov     rbx,rdx
    mov     r12,rsi
    mov     r13,rdi
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rax
    jmp     L0
L9:
    mov     rcx,rbx
    mov     rdx,rax
    mov     rax,rbp
    mov     rsi,r14
    mov     rdi,r15
    jmp     L8
    jmp     L13
L10:
    jmp     L12
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
L12:
    jmp     L11
    mov     rcx,rax
    mov     rax,rcx
L13:
    jmp     L10
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
    .long   L22
    .long   L23
    .long   L24
    .long   L25
L15:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+30h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F8h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L0
L16:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+30h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L1
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+28h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L3
L19:
    ret
L20:
    ret
L21:
    ret
L22:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+38h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E8h],r11
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L5
L23:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+38h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E8h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r12,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+50h]
    jmp     L6
L24:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+30h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L8
L25:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-160h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+30h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     rbp,[rsp]
    mov     rbx,[rsp+8]
    mov     rax,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L9

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,0B8h
    mov     [rsp+28h],rbx
    mov     [rsp+20h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    test    r12w,r12w
    je      L6
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    lea     ecx,[r12-1]
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    jmp     L8
L1:
    mov     rdx,[rax+8]
    mov     rsi,[rax+10h]
    cmp     rdx,rsi
    jb      L2
    jmp     L3
L2:
    mov     r12,rax
    jmp     L4
L3:
    mov     eax,0
    jmp     L5
L4:
    mov     rsi,[r12+8]
    lea     rdi,[rsp+30h]
    call    sym0
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+10h]
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r12+18h],ax
    mov     rax,[r12]
    lea     rax,[rax-100h]
    jmp     L10
L5:
    mov     rbx,[rsp+28h]
    mov     r12,[rsp+20h]
    add     rsp,0B8h
    ret
L6:
    mov     r12,rbx
    jmp     L4
L7:
    mov     rax,rcx
    jmp     L5
L8:
    jmp     L7
L9:
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L10:
    mov     rcx,r12
    jmp     L9
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
    .long   L19
L12:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L1
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L4
L15:
    ret
L16:
    ret
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,80h
    mov     rbx,rdi
    mov     [rsp+60h],rdx
    lea     rax,[rsp+60h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rbx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r12,rax
    mov     [rsp+20h],rsi
    mov     rax,[rbx+8]
    mov     [rsp+38h],rax
    and     rsi,rax
    mov     [rsp+28h],rsi
    mov     r13,rsi
    mov     r14d,0
L0:
    mov     [rsp+20h],r13
    mov     rax,[rbx]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rax
    lea     rsi,[rax+r13]
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+10h]
    call    image.sym59
    lea     rdi,[rsp+30h]
    mov     rsi,r12
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    mov     rax,[rsp+30h]
    mov     ecx,[rsp+38h]
    movzx   edx,word ptr [rsp+3Ch]
    movzx   esi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],ecx
    mov     [rsp+5Ch],dx
    mov     [rsp+5Eh],si
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    lea     rdi,[rsp+40h]
    call    image.sym20
    mov     [rsp+3Ch],eax
    mov     r15,rax
L1:
    test    r15w,r15w
    je      L3
    mov     rdi,r15
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    mov     [rsp+3Eh],r15w
    lea     ecx,[r15-1]
    and     r15d,ecx
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    mov     [rsp+38h],rax
    add     rax,r13
    mov     rcx,[rbx+8]
    mov     rsi,rax
    and     rsi,rcx
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+70h]
    call    qword ptr [image.fn82.slot]
    test    al,al
    je      L4
    mov     rax,[rsp+30h]
    mov     rcx,rax
    mov     eax,1
L2:
    test    rax,rax
    je      L7
    jmp     L6
L3:
    mov     qword ptr [rsp+30h],0
    mov     dword ptr [rsp+38h],0
    mov     word ptr [rsp+3Ch],0
    mov     word ptr [rsp+3Eh],0
    mov     qword ptr [rsp+38h],0
    lea     rdi,[rsp+30h]
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+30h]
    mov     edx,[rsp+38h]
    movzx   esi,word ptr [rsp+3Ch]
    movzx   edi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],edx
    mov     [rsp+5Ch],si
    mov     [rsp+5Eh],di
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+40h]
    call    image.sym20
    test    ax,ax
    je      L5
    mov     eax,0
    mov     ecx,0
    jmp     L2
L4:
    jmp     L1
L5:
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    add     r14,10h
    mov     [rsp+20h],r14
    add     r13,r14
    and     r13,rax
    jmp     L0
L6:
    mov     rax,[rbx]
    mov     [rsp+70h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+78h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,80h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+70h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    mov     edx,0
    sub     rdx,rsi
    mov     r11,rdx
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    jmp     L2
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,38h
    ret
L1:
    jmp     L6
L2:
    jmp     L1
L3:
    mov     rsi,[rax]
    mov     rdi,[rcx-18h]
    mov     r8,[rcx-10h]
    mov     r9,[rsi+8]
    mov     rsi,[rsi+10h]
    cmp     r8,rsi
    jne     L4
    mov     [rsp+18h],r8
    mov     [rsp+8],rdi
    mov     [rsp],r9
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym68]
    mov     esi,[rsp+24h]
    test    esi,esi
    sete    sil
    mov     rdx,rsi
    jmp     L5
L4:
    mov     edx,0
L5:
    jmp     L0
L6:
    jmp     L3
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    push    rbx
    push    r12
    push    r13
    sub     rsp,0A0h
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rsi,[rdx+10h]
    mov     rdx,[rdx+18h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rcx
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     [rsp+50h],r12
    mov     rax,[rbx+8]
    and     rax,r12
    mov     [rsp+58h],rax
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+48h],0
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rbx]
    mov     [rsp+60h],rcx
    mov     [rsp+68h],rcx
    lea     rsi,[rcx+rax]
    lea     rdi,[rsp+60h]
    call    image.sym59
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    lea     rdx,[rsp+50h]
    mov     [rsp+68h],rdx
    lea     rdx,[rsp+40h]
    mov     [rsp+60h],rdx
    mov     edx,[rsp+5Ch]
    mov     [rsp+10h],rax
    mov     [rsp+18h],ecx
    mov     [rsp+1Ch],edx
    lea     rdi,[rsp+10h]
    call    image.sym20
    test    ax,ax
    je      L3
    jmp     L2
L1:
    cmp     rcx,1
    je      L5
    jmp     L4
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF50h
    call    ryo_h_CttzW16
    mov     eax,[rsp+1Ch]
    mov     rcx,[rsp+40h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     rdx,rcx
    mov     ecx,1
    jmp     L1
L3:
    mov     ecx,0
    mov     edx,0
    jmp     L1
L4:
    mov     rax,[rbx+8]
    mov     [rsp+68h],rax
    mov     rcx,[rsp+48h]
    add     rcx,10h
    mov     [rsp+48h],rcx
    mov     [rsp+60h],rcx
    mov     rsi,[rsp+40h]
    add     rsi,rcx
    mov     [rsp+40h],rsi
    and     rsi,rax
    mov     [rsp+40h],rsi
    jmp     L0
L5:
    mov     [rsp+68h],rdx
    mov     rsi,[rbx]
    lea     rax,[rsi+rdx]
    movzx   eax,byte ptr [rax]
    and     eax,80h
    test    al,al
    jne     L7
    lea     rdi,[rsp+20h]
    call    image.sym19
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    lea     rdi,[rsp+30h]
    call    image.sym20
    mov     rdi,rax
    test    di,di
    je      L9
    jmp     L8
L6:
    mov     rcx,[rbx]
    lea     rcx,[rcx+rax]
    movzx   esi,byte ptr [rcx]
    mov     r8,r12
    shr     r8,39h
    and     r8,7Fh
    lea     r9,[rax-10h]
    mov     r13,[rbx+8]
    and     r9,r13
    add     r9,10h
    mov     [rcx],r8b
    mov     rcx,[rbx]
    lea     rcx,[rcx+r9]
    mov     [rcx],r8b
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rax,r11
    jmp     L11
L7:
    mov     rax,rdx
    jmp     L6
L8:
    call    ryo_hr_CttzW16
    mov     rcx,rax
    mov     ecx,ecx
    mov     rax,rcx
    jmp     L6
L9:
    mov     eax,0
    jmp     L6
L10:
    mov     rcx,rsi
    and     ecx,1
    test    cl,cl
    setne   cl
    movzx   ecx,cl
    mov     rdx,[rbx+10h]
    sub     rdx,rcx
    mov     [rbx+10h],rdx
    mov     rcx,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rdi,[rsp+88h]
    mov     r8,[rsp+90h]
    jmp     L13
L11:
    jmp     L10
L12:
    mov     [rax-20h],rcx
    mov     [rax-18h],rdx
    mov     [rax-10h],rdi
    mov     [rax-8],r8
    mov     rsi,[rbx+18h]
    add     rsi,1
    mov     [rbx+18h],rsi
    add     rsp,0A0h
    pop     r13
    pop     r12
    pop     rbx
    ret
L13:
    jmp     L12
    mov     rbx,rax
    jmp     L15
L14:
    mov     [rsp],rbx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
L15:
    lea     rdi,[rsp+78h]
    call    qword ptr [image.fn51.slot]
    jmp     L14
    call    sym2
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
    .long   L23
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jae     L0
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    jmp     L1
L0:
    add     rsp,18h
    ret
L1:
    jmp     L0
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
    jmp     L3
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
    push    rbx
    push    r12
    push    r13
    sub     rsp,80h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    jmp     L2
L0:
    mov     rax,rdx
    add     rsp,80h
    pop     r13
    pop     r12
    pop     rbx
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rsi,[rax]
    mov     rdi,[rsi]
    mov     rsi,[rsi+8]
    mov     r8,rdi
    mov     r10,736F6D6570736575h
    xor     r8,r10
    mov     r9,rsi
    mov     r10,646F72616E646F6Dh
    xor     r9,r10
    mov     rbx,rdi
    mov     r10,6C7967656E657261h
    xor     rbx,r10
    mov     r12,rsi
    mov     r10,7465646279746573h
    xor     r12,r10
    mov     [rsp+38h],r8
    mov     [rsp+40h],rbx
    mov     [rsp+48h],r9
    mov     [rsp+50h],r12
    mov     [rsp+58h],rdi
    mov     [rsp+60h],rsi
    mov     qword ptr [rsp+68h],0
    mov     qword ptr [rsp+70h],0
    mov     qword ptr [rsp+78h],0
    lea     rdi,[rsp+38h]
    mov     rsi,[rcx-18h]
    mov     r8,[rcx-10h]
    mov     rdx,r8
    call    image.fn197
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rsi,[rsp+0Fh]
    lea     rdi,[rsp+38h]
    mov     edx,1
    call    image.fn197
    mov     rsi,[rsp+38h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+40h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+48h]
    mov     [rsp+20h],r8
    mov     r9,[rsp+50h]
    mov     [rsp+28h],r9
    mov     rbx,[rsp+68h]
    and     rbx,0FFh
    shl     rbx,38h
    mov     r12,[rsp+70h]
    or      rbx,r12
    xor     r9,rbx
    mov     [rsp+28h],r9
    lea     r12,[rsp+10h]
    add     rsi,r8
    mov     [rsp+10h],rsi
    add     rdi,r9
    mov     [rsp+18h],rdi
    mov     r13,r8
    shl     r13,0Dh
    shr     r8,33h
    or      r13,r8
    mov     [rsp+20h],r13
    xor     r13,rsi
    mov     [rsp+20h],r13
    mov     r8,r9
    shl     r8,10h
    shr     r9,30h
    or      r8,r9
    mov     [rsp+28h],r8
    xor     r8,rdi
    mov     [rsp+28h],r8
    mov     r9,rsi
    shl     r9,20h
    shr     rsi,20h
    or      r9,rsi
    mov     [rsp+10h],r9
    add     rdi,r13
    mov     [rsp+18h],rdi
    add     r9,r8
    mov     [rsp+10h],r9
    mov     rsi,r13
    shl     rsi,11h
    shr     r13,2Fh
    or      rsi,r13
    mov     [rsp+20h],rsi
    xor     rsi,rdi
    mov     [rsp+20h],rsi
    mov     rsi,r8
    shl     rsi,15h
    shr     r8,2Bh
    or      rsi,r8
    mov     [rsp+28h],rsi
    xor     rsi,r9
    mov     [rsp+28h],rsi
    mov     rsi,rdi
    shl     rsi,20h
    shr     rdi,20h
    or      rsi,rdi
    mov     [rsp+18h],rsi
    xor     r9,rbx
    mov     [rsp+10h],r9
    xor     rsi,0FFh
    mov     [rsp+18h],rsi
    mov     rdi,r12
    call    image.fn209
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+20h]
    xor     rsi,rdi
    mov     rdi,[rsp+18h]
    xor     rsi,rdi
    mov     rdi,[rsp+28h]
    mov     rdx,rsi
    xor     rdx,rdi
    jmp     L0
L4:
    jmp     L3
    jmp     L5
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
    .long   L8
    .long   L9
    .long   L10
    .long   L11
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,80h
    mov     rbx,rdi
    mov     [rsp+60h],rdx
    lea     rax,[rsp+60h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rbx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r12,rax
    mov     [rsp+20h],rsi
    mov     rax,[rbx+8]
    mov     [rsp+38h],rax
    and     rsi,rax
    mov     [rsp+28h],rsi
    mov     r13,rsi
    mov     r14d,0
L0:
    mov     [rsp+20h],r13
    mov     rax,[rbx]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rax
    lea     rsi,[rax+r13]
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+10h]
    call    image.sym59
    lea     rdi,[rsp+30h]
    mov     rsi,r12
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    mov     rax,[rsp+30h]
    mov     ecx,[rsp+38h]
    movzx   edx,word ptr [rsp+3Ch]
    movzx   esi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],ecx
    mov     [rsp+5Ch],dx
    mov     [rsp+5Eh],si
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    lea     rdi,[rsp+40h]
    call    image.sym20
    mov     [rsp+3Ch],eax
    mov     r15,rax
L1:
    test    r15w,r15w
    je      L3
    mov     rdi,r15
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    mov     [rsp+3Eh],r15w
    lea     ecx,[r15-1]
    and     r15d,ecx
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    mov     [rsp+38h],rax
    add     rax,r13
    mov     rcx,[rbx+8]
    mov     rsi,rax
    and     rsi,rcx
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+70h]
    call    qword ptr [image.fn84.slot]
    test    al,al
    je      L4
    mov     rax,[rsp+30h]
    mov     rcx,rax
    mov     eax,1
L2:
    test    rax,rax
    je      L7
    jmp     L6
L3:
    mov     qword ptr [rsp+30h],0
    mov     dword ptr [rsp+38h],0
    mov     word ptr [rsp+3Ch],0
    mov     word ptr [rsp+3Eh],0
    mov     qword ptr [rsp+38h],0
    lea     rdi,[rsp+30h]
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+30h]
    mov     edx,[rsp+38h]
    movzx   esi,word ptr [rsp+3Ch]
    movzx   edi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],edx
    mov     [rsp+5Ch],si
    mov     [rsp+5Eh],di
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+40h]
    call    image.sym20
    test    ax,ax
    je      L5
    mov     eax,0
    mov     ecx,0
    jmp     L2
L4:
    jmp     L1
L5:
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    add     r14,10h
    mov     [rsp+20h],r14
    add     r13,r14
    and     r13,rax
    jmp     L0
L6:
    mov     rax,[rbx]
    mov     [rsp+70h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+78h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,80h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+70h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    mov     edx,0
    sub     rdx,rsi
    mov     r11,rdx
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    jmp     L2
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,18h
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rsi,[rax]
    mov     rsi,[rsi]
    mov     rdi,[rcx-10h]
    cmp     rsi,rdi
    sete    dl
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,80h
    mov     rbx,rdi
    mov     [rsp+60h],rdx
    lea     rax,[rsp+60h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rbx
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r12,rax
    mov     [rsp+20h],rsi
    mov     rax,[rbx+8]
    mov     [rsp+38h],rax
    and     rsi,rax
    mov     [rsp+28h],rsi
    mov     r13,rsi
    mov     r14d,0
L0:
    mov     [rsp+20h],r13
    mov     rax,[rbx]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rax
    lea     rsi,[rax+r13]
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+10h]
    call    image.sym59
    lea     rdi,[rsp+30h]
    mov     rsi,r12
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    mov     rax,[rsp+30h]
    mov     ecx,[rsp+38h]
    movzx   edx,word ptr [rsp+3Ch]
    movzx   esi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],ecx
    mov     [rsp+5Ch],dx
    mov     [rsp+5Eh],si
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    lea     rdi,[rsp+40h]
    call    image.sym20
    mov     [rsp+3Ch],eax
    mov     r15,rax
L1:
    test    r15w,r15w
    je      L3
    mov     rdi,r15
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    mov     [rsp+3Eh],r15w
    lea     ecx,[r15-1]
    and     r15d,ecx
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    mov     [rsp+38h],rax
    add     rax,r13
    mov     rcx,[rbx+8]
    mov     rsi,rax
    and     rsi,rcx
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+70h]
    call    qword ptr [image.fn85.slot]
    test    al,al
    je      L4
    mov     rax,[rsp+30h]
    mov     rcx,rax
    mov     eax,1
L2:
    test    rax,rax
    je      L7
    jmp     L6
L3:
    mov     qword ptr [rsp+30h],0
    mov     dword ptr [rsp+38h],0
    mov     word ptr [rsp+3Ch],0
    mov     word ptr [rsp+3Eh],0
    mov     qword ptr [rsp+38h],0
    lea     rdi,[rsp+30h]
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+30h]
    mov     edx,[rsp+38h]
    movzx   esi,word ptr [rsp+3Ch]
    movzx   edi,word ptr [rsp+3Eh]
    mov     [rsp+50h],rax
    mov     [rsp+58h],edx
    mov     [rsp+5Ch],si
    mov     [rsp+5Eh],di
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+40h]
    lea     rdx,[rsp+50h]
    call    image.sym60
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+40h]
    call    image.sym20
    test    ax,ax
    je      L5
    mov     eax,0
    mov     ecx,0
    jmp     L2
L4:
    jmp     L1
L5:
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    add     r14,10h
    mov     [rsp+20h],r14
    add     r13,r14
    and     r13,rax
    jmp     L0
L6:
    mov     rax,[rbx]
    mov     [rsp+70h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+78h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,80h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+70h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    mov     edx,0
    sub     rdx,rsi
    mov     r11,rdx
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    jmp     L2
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,18h
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rsi,[rax]
    mov     rdi,[rcx-10h]
    mov     rsi,[rsi]
    cmp     rdi,rsi
    sete    dl
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

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,0A8h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r11,r13
    shr     r11,20h
    mov     [rsp+30h],r11
    mov     rbp,r13
    shr     rbp,30h
    mov     r11,r13
    shr     r11,38h
    mov     [rsp+10h],r11
    mov     r11,r14
    shr     r11,20h
    mov     [rsp+18h],r11
    mov     r11,r14
    shr     r11,30h
    mov     [rsp+20h],r11
    mov     r11,r14
    shr     r11,38h
    mov     [rsp+28h],r11
    mov     [rsp+80h],r12
    mov     rax,[rbx+8]
    and     rax,r12
    mov     [rsp+88h],rax
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+78h],0
L0:
    mov     rax,[rsp+70h]
    mov     rcx,[rbx]
    mov     [rsp+90h],rcx
    mov     [rsp+98h],rcx
    lea     rsi,[rcx+rax]
    lea     rdi,[rsp+90h]
    call    image.sym59
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+80h],rax
    mov     [rsp+88h],rcx
    lea     rdx,[rsp+80h]
    mov     [rsp+98h],rdx
    lea     rdx,[rsp+70h]
    mov     [rsp+90h],rdx
    mov     edx,[rsp+8Ch]
    mov     [rsp+40h],rax
    mov     [rsp+48h],ecx
    mov     [rsp+4Ch],edx
    lea     rdi,[rsp+40h]
    call    image.sym20
    test    ax,ax
    je      L3
    jmp     L2
L1:
    cmp     rcx,1
    je      L5
    jmp     L4
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF7Ch
    mov     edx,0FFFFFF30h
    call    ryo_h_CttzW16
    mov     eax,[rsp+4Ch]
    mov     rcx,[rsp+70h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     rdx,rcx
    mov     ecx,1
    jmp     L1
L3:
    mov     ecx,0
    mov     edx,0
    jmp     L1
L4:
    mov     rax,[rbx+8]
    mov     [rsp+98h],rax
    mov     rcx,[rsp+78h]
    add     rcx,10h
    mov     [rsp+78h],rcx
    mov     [rsp+90h],rcx
    mov     rsi,[rsp+70h]
    add     rsi,rcx
    mov     [rsp+70h],rsi
    and     rsi,rax
    mov     [rsp+70h],rsi
    jmp     L0
L5:
    mov     [rsp+98h],rdx
    mov     rsi,[rbx]
    lea     rax,[rsi+rdx]
    movzx   eax,byte ptr [rax]
    and     eax,80h
    test    al,al
    jne     L7
    lea     rdi,[rsp+50h]
    call    image.sym19
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    lea     rdi,[rsp+60h]
    call    image.sym20
    mov     rdi,rax
    test    di,di
    je      L9
    jmp     L8
L6:
    mov     rcx,[rbx]
    lea     rcx,[rcx+rax]
    movzx   esi,byte ptr [rcx]
    mov     r8,r12
    shr     r8,39h
    and     r8,7Fh
    lea     r9,[rax-10h]
    mov     r15,[rbx+8]
    and     r9,r15
    add     r9,10h
    mov     [rcx],r8b
    mov     rcx,[rbx]
    lea     rcx,[rcx+r9]
    mov     [rcx],r8b
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rax,r11
    jmp     L11
L7:
    mov     rax,rdx
    jmp     L6
L8:
    call    ryo_hr_CttzW16
    mov     rcx,rax
    mov     ecx,ecx
    mov     rax,rcx
    jmp     L6
L9:
    mov     eax,0
    jmp     L6
L10:
    mov     rcx,rsi
    and     ecx,1
    test    cl,cl
    setne   cl
    movzx   ecx,cl
    mov     rdx,[rbx+10h]
    sub     rdx,rcx
    mov     [rbx+10h],rdx
    jmp     L13
L11:
    jmp     L10
L12:
    mov     [rax-10h],r13d
    mov     r10,[rsp+30h]
    mov     [rax-0Ch],r10w
    mov     [rax-0Ah],bpl
    mov     r10,[rsp+10h]
    mov     [rax-9],r10b
    mov     [rax-8],r14d
    mov     r10,[rsp+18h]
    mov     [rax-4],r10w
    mov     r10,[rsp+20h]
    mov     [rax-2],r10b
    mov     r10,[rsp+28h]
    mov     [rax-1],r10b
    mov     rcx,[rbx+18h]
    add     rcx,1
    mov     [rbx+18h],rcx
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L13:
    jmp     L12
    jmp     L15
L14:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L15:
    jmp     L14
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jae     L0
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    jmp     L1
L0:
    add     rsp,18h
    ret
L1:
    jmp     L0
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
    jmp     L3
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
    push    rbx
    push    r12
    push    r13
    sub     rsp,90h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    jmp     L2
L0:
    mov     rax,rdx
    add     rsp,90h
    pop     r13
    pop     r12
    pop     rbx
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rsi,[rax]
    mov     rdi,[rsi]
    mov     rsi,[rsi+8]
    mov     r8,rdi
    mov     r10,736F6D6570736575h
    xor     r8,r10
    mov     r9,rsi
    mov     r10,646F72616E646F6Dh
    xor     r9,r10
    mov     rbx,rdi
    mov     r10,6C7967656E657261h
    xor     rbx,r10
    mov     r12,rsi
    mov     r10,7465646279746573h
    xor     r12,r10
    mov     [rsp+48h],r8
    mov     [rsp+50h],rbx
    mov     [rsp+58h],r9
    mov     [rsp+60h],r12
    mov     [rsp+68h],rdi
    mov     [rsp+70h],rsi
    mov     qword ptr [rsp+78h],0
    mov     qword ptr [rsp+80h],0
    mov     qword ptr [rsp+88h],0
    lea     rdi,[rsp+48h]
    mov     rsi,[rcx-10h]
    mov     [rsp+10h],rsi
    lea     rsi,[rsp+10h]
    mov     edx,8
    call    qword ptr [image.fn197.slot]
    mov     rsi,[rsp+48h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+50h]
    mov     [rsp+28h],rdi
    mov     r8,[rsp+58h]
    mov     [rsp+30h],r8
    mov     r9,[rsp+60h]
    mov     [rsp+38h],r9
    mov     rbx,[rsp+78h]
    and     rbx,0FFh
    shl     rbx,38h
    mov     r12,[rsp+80h]
    or      rbx,r12
    xor     r9,rbx
    mov     [rsp+38h],r9
    lea     r12,[rsp+20h]
    add     rsi,r8
    mov     [rsp+20h],rsi
    add     rdi,r9
    mov     [rsp+28h],rdi
    mov     r13,r8
    shl     r13,0Dh
    shr     r8,33h
    or      r13,r8
    mov     [rsp+30h],r13
    xor     r13,rsi
    mov     [rsp+30h],r13
    mov     r8,r9
    shl     r8,10h
    shr     r9,30h
    or      r8,r9
    mov     [rsp+38h],r8
    xor     r8,rdi
    mov     [rsp+38h],r8
    mov     r9,rsi
    shl     r9,20h
    shr     rsi,20h
    or      r9,rsi
    mov     [rsp+20h],r9
    add     rdi,r13
    mov     [rsp+28h],rdi
    add     r9,r8
    mov     [rsp+20h],r9
    mov     rsi,r13
    shl     rsi,11h
    shr     r13,2Fh
    or      rsi,r13
    mov     [rsp+30h],rsi
    xor     rsi,rdi
    mov     [rsp+30h],rsi
    mov     rsi,r8
    shl     rsi,15h
    shr     r8,2Bh
    or      rsi,r8
    mov     [rsp+38h],rsi
    xor     rsi,r9
    mov     [rsp+38h],rsi
    mov     rsi,rdi
    shl     rsi,20h
    shr     rdi,20h
    or      rsi,rdi
    mov     [rsp+28h],rsi
    xor     r9,rbx
    mov     [rsp+20h],r9
    xor     rsi,0FFh
    mov     [rsp+28h],rsi
    mov     rdi,r12
    call    image.fn209
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+30h]
    xor     rsi,rdi
    mov     rdi,[rsp+28h]
    xor     rsi,rdi
    mov     rdi,[rsp+38h]
    mov     rdx,rsi
    xor     rdx,rdi
    jmp     L0
L4:
    jmp     L3
    jmp     L5
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
    .long   L8
    .long   L9
    .long   L10
    .long   L11
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

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    sub     rsp,0D8h
    mov     [rsp+50h],rbx
    mov     [rsp+48h],r12
    mov     [rsp+40h],r13
    mov     [rsp+38h],r14
    mov     rbx,rdi
    mov     rax,[rbx+18h]
    mov     [rsp+78h],rax
    test    rax,rax
    je      L2
    mov     r12,[rbx]
    mov     [rsp+70h],r12
    mov     [rsp+68h],r12
    mov     [rsp+78h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    lea     rdi,[rsp+10h]
    mov     rsi,r13
    call    image.sym19
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    lea     rdi,[rsp+20h]
    call    image.sym20
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     qword ptr [rsp+28h],10h
    lea     r13,[r13+10h]
    mov     [rsp+58h],r12
    mov     [rsp+60h],r13
    mov     [rsp+68h],r14
    mov     [rsp+70h],ax
    mov     [rsp+72h],r10d
    mov     [rsp+76h],r10w
    jmp     L3
L0:
    mov     rax,[rsp+78h]
    test    rax,rax
    je      L2
    lea     rdi,[rsp+58h]
    call    fn1
    mov     rcx,[rsp+78h]
    sub     rcx,1
    mov     [rsp+78h],rcx
    test    rax,rax
    je      L2
    jmp     L4
L1:
    lea     rcx,[rcx-20h]
    jmp     L6
L2:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+48h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+38h]
    add     rsp,0D8h
    ret
L3:
    mov     rcx,[rbx+18h]
    mov     rdx,[rsp+70h]
    mov     [rsp+58h],r12
    mov     [rsp+60h],r13
    mov     [rsp+68h],r14
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    jmp     L0
L4:
    mov     rcx,rax
    jmp     L1
L5:
    mov     rdi,rbx
    call    image.sym31
    mov     rdi,rbx
    call    image.sym32
    jmp     L0
L6:
    mov     rbx,rcx
    jmp     L5
    mov     r12,rax
    mov     rdi,rbx
    call    image.sym32
    mov     [rsp],r12
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
    call    image.sym21
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
    .long   L11
    .long   L12
    .long   L13
L8:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0D0h]
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    lea     rsp,[rsp]
    jmp     L0
L9:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-80h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rcx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L1
L10:
    ret
L11:
    ret
L12:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rbx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L5
L13:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     [rdx-88h],r12
    mov     [rdx-90h],r13
    mov     [rdx-98h],r14
    mov     rcx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L6

fn hashbrown::raw::RawTableInner::erase
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,78h
    mov     rbx,rdi
    mov     r12,rsi
    lea     rax,[r12-10h]
    mov     [rsp+38h],rax
    mov     rcx,[rbx+8]
    mov     [rsp+30h],rcx
    and     rax,rcx
    mov     rcx,[rbx]
    mov     [rsp+48h],rcx
    mov     [rsp+30h],rcx
    lea     rsi,[rcx+rax]
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+10h]
    call    sym0
    lea     rdi,[rsp+40h]
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    mov     eax,[rsp+40h]
    mov     ecx,[rsp+44h]
    mov     edx,[rsp+48h]
    mov     esi,[rsp+4Ch]
    mov     [rsp+60h],eax
    mov     [rsp+64h],ecx
    mov     [rsp+68h],edx
    mov     [rsp+6Ch],esi
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp+50h]
    lea     rdx,[rsp+60h]
    call    sym2
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    lea     rdi,[rsp+50h]
    call    sym3
    mov     [rsp+4Ch],eax
    mov     r13,rax
    mov     rax,[rbx]
    mov     [rsp+48h],rax
    mov     [rsp+30h],rax
    lea     rsi,[rax+r12]
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+20h]
    call    sym0
    lea     rdi,[rsp+40h]
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    mov     eax,[rsp+40h]
    mov     ecx,[rsp+44h]
    mov     edx,[rsp+48h]
    mov     esi,[rsp+4Ch]
    mov     [rsp+60h],eax
    mov     [rsp+64h],ecx
    mov     [rsp+68h],edx
    mov     [rsp+6Ch],esi
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp+50h]
    lea     rdx,[rsp+60h]
    call    sym2
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    lea     rdi,[rsp+50h]
    call    sym3
    mov     [rsp+4Ch],eax
    mov     r14,rax
    mov     rdi,r13
    call    ryo_hr_CtlzW16
    mov     [rsp+4Ch],eax
    mov     r13d,eax
    mov     [rsp+30h],r13
    mov     rdi,r14
    call    ryo_hr_CttzW16
    mov     [rsp+44h],eax
    mov     eax,eax
    mov     [rsp+48h],rax
    add     r13,rax
    mov     [rsp+38h],r13
    cmp     r13,10h
    jb      L0
    mov     eax,80h
    jmp     L1
L0:
    mov     rax,[rbx+10h]
    add     rax,1
    mov     [rsp+50h],rax
    mov     [rbx+10h],rax
    mov     eax,0FFh
L1:
    lea     rcx,[r12-10h]
    mov     [rsp+48h],rcx
    mov     rdx,[rbx+8]
    mov     [rsp+40h],rdx
    and     rcx,rdx
    mov     [rsp+30h],rcx
    add     rcx,10h
    mov     [rsp+38h],rcx
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    lea     rcx,[rcx+r12]
    mov     [rsp+48h],rcx
    mov     [rsp+30h],rcx
    mov     [rcx],al
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    mov     rdx,[rsp+38h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+48h],rcx
    mov     [rsp+30h],rcx
    mov     [rcx],al
    mov     rax,[rbx+18h]
    sub     rax,1
    mov     [rsp+50h],rax
    mov     [rbx+18h],rax
    add     rsp,78h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
    .long   L4
L3:
    ret
L4:
    ret

fn hashbrown::raw::RawTableInner::find_inner
    sub     rsp,118h
    mov     [rsp+98h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+88h],r13
    mov     [rsp+80h],r14
    mov     [rsp+78h],r15
    mov     [rsp+70h],rbp
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     [rsp+30h],rsi
    mov     r8,[rdi+8]
    mov     [rsp+48h],r8
    and     rsi,r8
    mov     [rsp+38h],rsi
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,rax
    mov     r14,rcx
    mov     r15,rdx
    mov     ebp,0
L0:
    mov     [rsp+30h],rbx
    mov     rax,[r12]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rax
    lea     rsi,[rax+rbx]
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+0A0h]
    call    sym0
    lea     rdi,[rsp+40h]
    mov     rsi,r13
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    mov     rax,[rsp+40h]
    mov     ecx,[rsp+48h]
    movzx   edx,word ptr [rsp+4Ch]
    movzx   esi,word ptr [rsp+4Eh]
    mov     [rsp+60h],rax
    mov     [rsp+68h],ecx
    mov     [rsp+6Ch],dx
    mov     [rsp+6Eh],si
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp+50h]
    lea     rdx,[rsp+60h]
    call    sym2
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    lea     rdi,[rsp+50h]
    call    sym3
    mov     [rsp+4Ch],eax
    mov     [rsp+20h],r14
    mov     [rsp+28h],r15
    mov     [rsp+18h],rbp
    mov     [rsp+10h],r13
    mov     r13,r12
    mov     r12,rbx
    mov     rbx,rax
L1:
    test    bx,bx
    je      L4
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+4Eh],bx
    lea     ecx,[rbx-1]
    and     ebx,ecx
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    mov     [rsp+48h],rax
    add     rax,r12
    mov     rcx,[r13+8]
    mov     rsi,rax
    and     rsi,rcx
    mov     [rsp+40h],rsi
    mov     r11,[rsp+20h]
    mov     rax,[r11+20h]
    mov     rdi,[rsp+28h]
    call    rax
    mov     rcx,r12
    mov     rdx,r13
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
L2:
    test    al,al
    je      L5
    mov     rax,[rsp+40h]
    mov     rbp,rax
    mov     eax,1
L3:
    mov     rdx,rbp
    mov     rbx,[rsp+98h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+88h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+78h]
    mov     rbp,[rsp+70h]
    add     rsp,118h
    ret
L4:
    mov     qword ptr [rsp+40h],0
    mov     dword ptr [rsp+48h],0
    mov     word ptr [rsp+4Ch],0
    mov     word ptr [rsp+4Eh],0
    mov     qword ptr [rsp+48h],0
    lea     rax,[rsp+40h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0A0h]
    mov     rbp,[rsp+0A8h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rbp
    mov     rax,[rsp+40h]
    mov     ebp,[rsp+48h]
    movzx   r14d,word ptr [rsp+4Ch]
    movzx   r15d,word ptr [rsp+4Eh]
    mov     [rsp+60h],rax
    mov     [rsp+68h],ebp
    mov     [rsp+6Ch],r14w
    mov     [rsp+6Eh],r15w
    lea     rax,[rsp+30h]
    lea     r14,[rsp+50h]
    lea     r15,[rsp+60h]
    mov     rdi,rax
    mov     rsi,r14
    mov     rdx,r15
    call    sym2
    mov     rax,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],r14
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    sym3
    test    ax,ax
    je      L6
    mov     eax,0
    mov     ebp,0
    jmp     L3
L5:
    mov     r12,rcx
    mov     r13,rdx
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdi
    mov     [rsp+18h],r8
    mov     [rsp+10h],r9
    jmp     L1
L6:
    mov     rax,[r13+8]
    mov     [rsp+38h],rax
    mov     rcx,[rsp+18h]
    add     rcx,10h
    mov     [rsp+30h],rcx
    add     r12,rcx
    and     r12,rax
    mov     rbx,r12
    mov     r12,r13
    mov     r13,[rsp+10h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,rcx
    jmp     L0
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
L8:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-100h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+68h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-0D8h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+70h]
    jmp     L0
L9:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-190h]
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
    mov     r11,[rdx-100h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+70h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-100h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+80h]
    jmp     L1
L10:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-190h]
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
    mov     r11,[rdx-100h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0F8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+78h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-88h],r13
    mov     [rdx-90h],r14
    mov     [rdx-98h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-0D8h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+38h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+80h]
    jmp     L2
L11:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,0C8h
    mov     [rsp+58h],rbx
    mov     [rsp+60h],rsi
    mov     rax,[rdi+8]
    and     rsi,rax
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rsi
    mov     qword ptr [rsp+78h],0
    mov     rbx,rdi
L0:
    mov     rax,[rsp+70h]
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rcx
    lea     rsi,[rcx+rax]
    lea     rdi,[rsp+40h]
    call    sym0
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    lea     rdx,[rsp+60h]
    mov     [rsp+48h],rdx
    lea     rdx,[rsp+70h]
    mov     [rsp+40h],rdx
    mov     edx,[rsp+6Ch]
    mov     [rsp+10h],rax
    mov     [rsp+18h],ecx
    mov     [rsp+1Ch],edx
    lea     rdi,[rsp+10h]
    call    image.sym20
    test    ax,ax
    je      L1
    mov     [rsp],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF5Ch
    mov     edx,0FFFFFF40h
    call    ryo_h_CttzW16
    mov     eax,[rsp+1Ch]
    mov     rcx,[rsp+70h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
    mov     ecx,0
L2:
    cmp     rax,1
    je      L4
    mov     rax,[rbx+8]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+78h]
    add     rdx,10h
    mov     [rsp+78h],rdx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+70h]
    add     rsi,rdx
    mov     [rsp+70h],rsi
    and     rsi,rax
    mov     [rsp+70h],rsi
    jmp     L0
L3:
    mov     rbx,[rsp+58h]
    add     rsp,0C8h
    ret
L4:
    mov     [rsp+48h],rcx
    mov     rsi,[rbx]
    lea     rdx,[rsi+rcx]
    movzx   edx,byte ptr [rdx]
    and     edx,80h
    test    dl,dl
    jne     L6
    lea     rdi,[rsp+20h]
    call    image.sym19
    mov     rdx,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+30h]
    call    image.sym20
    mov     rdx,rax
    mov     rdi,rdx
    test    di,di
    je      L8
    jmp     L7
L5:
    jmp     L3
L6:
    mov     rax,rcx
    jmp     L5
L7:
    call    ryo_hr_CttzW16
    mov     eax,eax
    jmp     L5
L8:
    mov     eax,0
    jmp     L5
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
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-68h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L11:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-70h]
    mov     [rsp],r11
    mov     r11,[rdx-68h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     [rdx-68h],rbx
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rbx,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L2
L12:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    push    rbx
    push    r12
    sub     rsp,28h
    mov     rbx,rdi
    mov     r12,rdx
    mov     rax,[rsi]
    mov     ecx,[rsi+8]
    mov     edx,[rsi+0Ch]
    mov     [rsp+10h],rax
    mov     [rsp+18h],ecx
    mov     [rsp+1Ch],edx
    lea     rdi,[rsp+10h]
    call    sym0
    test    ax,ax
    je      L2
    jmp     L1
L0:
    mov     rax,rcx
    add     rsp,28h
    pop     r12
    pop     rbx
    ret
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFECh
    mov     edx,0FFFFFFD0h
    call    ryo_h_CttzW16
    mov     eax,[rsp+1Ch]
    mov     rcx,[r12]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     rdx,rcx
    mov     ecx,1
    jmp     L0
L2:
    mov     ecx,0
    mov     edx,0
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
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+0B0h]
    cmp     r11,0
    je      L20
    jmp     L21
L0:
    lea     rcx,[rsp+1D0h]
    mov     [rsp+168h],rcx
    mov     rcx,[rsp+1E0h]
    mov     [rsp+160h],rcx
    test    rcx,rcx
    je      L14
L1:
    movzx   r14d,word ptr [rsp+1E8h]
    test    r14w,r14w
    je      L2
    mov     rdi,r14
    call    ryo_hr_CttzW16
    mov     rcx,rax
    mov     ecx,ecx
    lea     edx,[r14-1]
    and     r14d,edx
    mov     [rsp+1E8h],r14w
    mov     rdx,[rsp+1D8h]
    add     rdx,rcx
    mov     rcx,[rsp+168h]
    mov     rsi,[rcx+10h]
    sub     rsi,1
    mov     [rsp+190h],rsi
    mov     [rcx+10h],rsi
    mov     r11,[rsp+90h]
    mov     [rsp+98h],r11
    mov     [rsp+0A0h],r15
    mov     r14,r12
    mov     r12,r13
    mov     r13,rbx
    mov     rbx,[rsp+80h]
    mov     r15,[rsp+88h]
    jmp     L3
L2:
    mov     rcx,[rsp+1D0h]
    mov     qword ptr [rsp+0D8h],10h
    mov     rsi,rcx
    lea     rsi,[rsi+10h]
    mov     [rsp+1D0h],rsi
    lea     rdi,[rsp+0C0h]
    call    sym3
    mov     rcx,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     [rsp+0D0h],rcx
    mov     [rsp+0D8h],rdx
    lea     rdi,[rsp+0D0h]
    call    sym4
    mov     rcx,rax
    mov     rdi,rcx
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+1E8h],cx
    mov     rcx,[rsp+1D8h]
    mov     [rsp+0D8h],rcx
    add     rcx,10h
    mov     [rsp+0D0h],rcx
    mov     [rsp+1D8h],rcx
    jmp     L1
L3:
    mov     [rsp+160h],rdx
    mov     r11,[rsp+98h]
    mov     rcx,[r11+28h]
    mov     rdi,[rsp+0A0h]
    mov     rsi,rbx
    mov     rax,rcx
    call    rax
    mov     [rsp+0A8h],rax
    mov     r10,[rsp+0A8h]
    mov     [rsp+120h],r10
    mov     rcx,[rsp+210h]
    and     rcx,[rsp+0A8h]
    mov     [rsp+128h],rcx
    mov     [rsp+110h],rcx
    mov     qword ptr [rsp+118h],0
L4:
    mov     rcx,[rsp+110h]
    mov     rdx,[rsp+208h]
    mov     [rsp+130h],rdx
    mov     [rsp+138h],rdx
    lea     rsi,[rdx+rcx]
    lea     rdi,[rsp+130h]
    call    image.sym59
    mov     rcx,[rsp+130h]
    mov     rdx,[rsp+138h]
    mov     [rsp+120h],rcx
    mov     [rsp+128h],rdx
    lea     rsi,[rsp+120h]
    mov     [rsp+138h],rsi
    lea     rsi,[rsp+110h]
    mov     [rsp+130h],rsi
    mov     esi,[rsp+12Ch]
    mov     [rsp+0E0h],rcx
    mov     [rsp+0E8h],edx
    mov     [rsp+0ECh],esi
    lea     rdi,[rsp+0E0h]
    call    sym4
    mov     rcx,rax
    test    cx,cx
    je      L7
    jmp     L6
L5:
    cmp     rdx,1
    je      L9
    jmp     L8
L6:
    mov     [rsp],rcx
    lea     rdi,[rsp+320h]
    mov     esi,0FFFFFDCCh
    mov     edx,0FFFFFCE0h
    call    ryo_h_CttzW16
    mov     ecx,[rsp+0ECh]
    mov     rdx,[rsp+110h]
    add     rdx,rcx
    mov     rcx,[rsp+210h]
    and     rdx,rcx
    mov     rsi,rdx
    mov     edx,1
    jmp     L5
L7:
    mov     edx,0
    mov     esi,0
    jmp     L5
L8:
    mov     rcx,[rsp+210h]
    mov     [rsp+138h],rcx
    mov     rdx,[rsp+118h]
    add     rdx,10h
    mov     [rsp+118h],rdx
    mov     [rsp+130h],rdx
    mov     rdi,[rsp+110h]
    add     rdi,rdx
    mov     [rsp+110h],rdi
    and     rdi,rcx
    mov     [rsp+110h],rdi
    jmp     L4
L9:
    mov     [rsp+138h],rsi
    mov     rcx,[rsp+208h]
    lea     rdx,[rcx+rsi]
    movzx   edx,byte ptr [rdx]
    and     edx,80h
    test    dl,dl
    jne     L11
    lea     rdi,[rsp+0F0h]
    mov     rsi,rcx
    call    sym3
    mov     rcx,[rsp+0F0h]
    mov     rdx,[rsp+0F8h]
    mov     [rsp+100h],rcx
    mov     [rsp+108h],rdx
    lea     rdi,[rsp+100h]
    call    sym4
    mov     rcx,rax
    mov     rdi,rcx
    test    di,di
    je      L13
    jmp     L12
L10:
    mov     rdx,[rsp+208h]
    lea     rdx,[rdx+rcx]
    movzx   r11d,byte ptr [rdx]
    mov     r8,[rsp+0A8h]
    shr     r8,39h
    and     r8,7Fh
    lea     r9,[rcx-10h]
    mov     rax,[rsp+210h]
    and     r9,rax
    add     r9,10h
    mov     [rdx],r8b
    mov     rax,[rsp+208h]
    lea     rax,[rax+r9]
    mov     [rax],r8b
    movzx   eax,bp
    movzx   edx,r13w
    shl     rdx,10h
    or      rax,rdx
    movzx   edx,r14w
    shl     rdx,20h
    or      rax,rdx
    movzx   edx,r12b
    shl     rdx,30h
    or      rax,rdx
    movzx   edx,r15b
    shl     rdx,38h
    or      rdx,rax
    mov     rax,[rbx]
    mov     r8,[rsp+160h]
    add     r8,1
    imul    r8,rdx
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     rax,[rax+r8]
    mov     r8,[rsp+208h]
    add     rcx,1
    imul    rcx,rdx
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    lea     r8,[r8+rcx]
    mov     rdi,r8
    mov     rsi,rax
    call    ryo_hr_Memcpy
    mov     [rsp+80h],rbx
    mov     r11,[rsp+98h]
    mov     [rsp+90h],r11
    mov     rbx,r13
    mov     r13,r12
    mov     r12,r14
    mov     [rsp+88h],r15
    mov     r15,[rsp+0A0h]
    jmp     L0
L11:
    mov     rcx,rsi
    jmp     L10
L12:
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     rcx,rax
    jmp     L10
L13:
    mov     ecx,0
    jmp     L10
L14:
    mov     r11,[rsp+80h]
    mov     rax,[r11+18h]
    mov     [rsp+1E8h],rax
    mov     rcx,[rsp+218h]
    sub     rcx,rax
    mov     [rsp+218h],rcx
    mov     r11,[rsp+80h]
    mov     rax,[r11+18h]
    mov     [rsp+1E8h],rax
    mov     [rsp+220h],rax
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    lea     rdx,[rsp+208h]
    mov     [rsp+1E0h],rdx
    mov     r11,[rsp+80h]
    mov     rdx,[r11]
    mov     r11,[rsp+80h]
    mov     rsi,[r11+8]
    mov     r11,[rsp+80h]
    mov     rdi,[r11+10h]
    mov     [rsp+190h],rdi
    mov     r11,[rsp+80h]
    mov     rdi,[r11+18h]
    mov     [rsp+198h],rdi
    mov     rdi,[rsp+208h]
    mov     r8,[rsp+210h]
    mov     r11,[rsp+80h]
    mov     [r11],rdi
    mov     rdi,[rsp+1E8h]
    mov     [rdi+8],r8
    mov     rdi,[rsp+1E8h]
    mov     [rdi+10h],rcx
    mov     rcx,[rsp+1E8h]
    mov     [rcx+18h],rax
    mov     rax,[rsp+1E0h]
    mov     [rax],rdx
    mov     rax,[rsp+1E0h]
    mov     [rax+8],rsi
    mov     rax,[rsp+1E0h]
    mov     rcx,[rsp+190h]
    mov     [rax+10h],rcx
    mov     rax,[rsp+1E0h]
    mov     rcx,[rsp+198h]
    mov     [rax+18h],rcx
    mov     rax,[rsp+210h]
    test    rax,rax
    je      L15
    jmp     L16
L15:
    mov     eax,0FFFFh
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFh
    mov     edi,0FFh
    mov     r8d,0
    mov     r9d,0
    mov     ebx,0
    mov     r12d,0
    mov     r13d,0
    jmp     L19
L16:
    mov     r11,[rsp+1F0h]
    mov     rsi,[rsp+1F8h]
    mov     rdx,[rsp+200h]
    lea     rcx,[rax+1]
    lea     rdi,[rsp+140h]
    call    qword ptr [image.fn125.slot]
    mov     rdx,[rsp+140h]
    mov     rsi,[rsp+148h]
    mov     rax,[rsp+150h]
    mov     rcx,[rsp+208h]
    mov     [rsp+140h],rcx
    mov     [rsp+148h],rcx
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+140h],rax
    lea     rdi,[rcx+rax]
    mov     [rsp+150h],rdi
    test    rsi,rsi
    je      L17
    jmp     L18
L17:
    mov     eax,0FFFFh
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFh
    mov     edi,0FFh
    mov     r8d,0
    mov     r9d,0
    mov     ebx,0
    mov     r12d,0
    mov     r13d,0
    jmp     L19
L18:
    call    image.sym67
    mov     eax,0FFFFh
    mov     ecx,0FFFFh
    mov     edx,0FFFFh
    mov     esi,0FFh
    mov     edi,0FFh
    mov     r8d,0
    mov     r9d,0
    mov     ebx,0
    mov     r12d,0
    mov     r13d,0
L19:
    movzx   eax,ax
    movzx   ecx,cx
    shl     rcx,10h
    or      rax,rcx
    movzx   edx,dx
    shl     rdx,20h
    or      rax,rdx
    movzx   esi,sil
    shl     rsi,30h
    or      rax,rsi
    movzx   edi,dil
    shl     rdi,38h
    or      rax,rdi
    movzx   r8d,r8w
    movzx   r9d,r9w
    shl     r9,10h
    or      r8,r9
    movzx   ebx,bx
    shl     rbx,20h
    or      r8,rbx
    movzx   r12d,r12b
    shl     r12,30h
    or      r8,r12
    movzx   r13d,r13b
    shl     r13,38h
    mov     rdx,r8
    or      rdx,r13
    mov     rbx,[rsp+1C8h]
    mov     r12,[rsp+1C0h]
    mov     r13,[rsp+1B8h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A8h]
    mov     rbp,[rsp+1A0h]
    add     rsp,328h
    ret
L20:
    movzx   eax,word ptr [rsp+178h]
    movzx   ecx,word ptr [rsp+17Ah]
    movzx   edx,word ptr [rsp+17Ch]
    movzx   esi,byte ptr [rsp+17Eh]
    movzx   edi,byte ptr [rsp+17Fh]
    movzx   r8d,word ptr [rsp+180h]
    movzx   r9d,word ptr [rsp+182h]
    movzx   ebx,word ptr [rsp+184h]
    movzx   r12d,byte ptr [rsp+186h]
    movzx   r13d,byte ptr [rsp+187h]
    mov     [rsp+180h],ax
    mov     [rsp+182h],cx
    mov     [rsp+184h],dx
    mov     [rsp+186h],sil
    mov     [rsp+187h],dil
    mov     [rsp+188h],r8w
    mov     [rsp+18Ah],r9w
    mov     [rsp+18Ch],bx
    mov     [rsp+18Eh],r12b
    mov     [rsp+18Fh],r13b
    mov     qword ptr [rsp+178h],1
    mov     byte ptr [rsp+177h],1
    mov     qword ptr [rsp+168h],0
    mov     [rsp+160h],r8w
    mov     [rsp+162h],r9w
    mov     [rsp+164h],bx
    mov     [rsp+166h],r12b
    mov     [rsp+167h],r13b
    jmp     L19
L21:
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
    mov     [rsp+160h],rdx
    mov     r10,[rsp+78h]
    mov     [rsp+178h],r10
    mov     [rsp+180h],rsi
    mov     [rsp+188h],rdi
    mov     r10,[rsp+78h]
    mov     [rsp+168h],r10
    mov     r10,[rsp+0B0h]
    mov     [rsp+1D0h],r10
    mov     [rsp+1D8h],rax
    mov     [rsp+1E0h],rcx
    mov     [rsp+1E8h],rdx
    mov     [rsp+160h],rdx
    mov     r10,[rsp+78h]
    mov     [rsp+1F0h],r10
    mov     [rsp+1F8h],rsi
    mov     [rsp+200h],rdi
    mov     r10,[rsp+0B0h]
    mov     [rsp+208h],r10
    mov     [rsp+210h],rax
    mov     [rsp+218h],rcx
    mov     [rsp+220h],rdx
    mov     r11,[rsp+70h]
    mov     rbx,[r11]
    mov     [rsp+1D0h],rbx
    mov     [rsp+1E8h],rbx
    mov     [rsp+1D8h],rbx
    lea     rdi,[rsp+160h]
    mov     rsi,rbx
    call    sym3
    movzx   eax,word ptr [rsp+160h]
    movzx   ecx,word ptr [rsp+162h]
    movzx   edx,word ptr [rsp+164h]
    movzx   esi,byte ptr [rsp+166h]
    movzx   edi,byte ptr [rsp+167h]
    mov     r8d,[rsp+168h]
    movzx   r9d,word ptr [rsp+16Ch]
    movzx   r12d,byte ptr [rsp+16Eh]
    movzx   r13d,byte ptr [rsp+16Fh]
    mov     [rsp+190h],ax
    mov     [rsp+192h],cx
    mov     [rsp+194h],dx
    mov     [rsp+196h],sil
    mov     [rsp+197h],dil
    mov     [rsp+198h],r8d
    mov     [rsp+19Ch],r9w
    mov     [rsp+19Eh],r12b
    mov     [rsp+19Fh],r13b
    lea     rdi,[rsp+190h]
    call    sym4
    mov     [rsp+1DCh],eax
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
    mov     [rsp+158h],ax
    mov     [rsp+1D0h],rbx
    mov     qword ptr [rsp+1D8h],0
    mov     [rsp+1E0h],rcx
    mov     rax,[rsp+158h]
    mov     [rsp+1E8h],rax
    mov     r11,[rsp+70h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+18h]
    mov     [rsp+90h],r11
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+68h]
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+58h]
    mov     r13,[rsp+20h]
    mov     r11,[rsp+28h]
    mov     [rsp+88h],r11
    jmp     L0
    mov     rbx,rax
    jmp     L24
    mov     rbx,rax
    jmp     L24
L22:
    lea     rdi,[rsp+1F0h]
    lea     rsi,[rsp+208h]
    call    qword ptr [image.fn86.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+320h]
    mov     esi,0FFFFFCE0h
    call    ryo_h_Resume
    ud2
    jmp     L23
    mov     rbx,rax
    jmp     L24
    mov     rbx,rax
    jmp     L24
    mov     rbx,rax
    jmp     L24
L23:
    call    sym9
    ud2
L24:
    jmp     L22
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
    .long   L30
    .long   L31
L26:
    pop     rcx
    lea     rdx,[rsp+270h]
    lea     rsp,[rdx-3B0h]
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
    mov     r11,[rdx-170h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+80h],r11
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
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp]
    mov     [rdx-2A0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-290h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-298h],r11
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    lea     rsp,[rsp+90h]
    jmp     L0
L27:
    pop     rcx
    lea     rdx,[rsp+270h]
    lea     rsp,[rdx-3B0h]
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
    mov     r11,[rdx-170h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+88h],r11
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
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-280h],r11
    mov     rbx,[rsp+8]
    mov     rbp,[rsp+20h]
    mov     r13,[rsp+28h]
    mov     r14,[rsp+30h]
    mov     r12,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+90h]
    jmp     L3
L28:
    ret
L29:
    ret
L30:
    ret
L31:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
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
    jmp     L3
L0:
    test    r15,r15
    je      L1
    lea     rdi,[rsp+8]
    call    image.sym31
    lea     rdi,[rsp+8]
    call    image.sym32
    mov     rax,0FFFFFFFFFFFFFFFFh
    mov     rcx,r15
    mov     rdx,r12
    jmp     L2
L1:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    qword ptr [fn2.slot]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rsi,r12
    mov     rdi,r14
L2:
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     [rbx+18h],rsi
    mov     [rbx+20h],rdi
    mov     rax,rbx
    add     rsp,20h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L3:
    jmp     L0
    mov     rbx,rax
    lea     rdi,[rsp+8]
    call    image.sym32
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    call    sym5
    ud2
    mov     rbx,rax
    jmp     L6
    mov     rbx,rax
    jmp     L6
L4:
    lea     rdi,[rsp+8]
    call    qword ptr [image.fn51.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    jmp     L5
    mov     rbx,rax
    jmp     L6
L5:
    call    sym5
    ud2
L6:
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
L8:
    ret
L9:
    ret
L10:
    ret
L11:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
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
    jmp     L3
L0:
    test    rax,rax
    je      L1
    mov     ecx,0
    mov     rdx,rax
    mov     rsi,r12
    jmp     L2
L1:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    fn1
    mov     rcx,[rsp+8]
    mov     rdx,r14
    mov     rsi,rcx
    mov     rcx,r12
L2:
    mov     [rbx],rcx
    mov     [rbx+8],rdx
    mov     [rbx+10h],rsi
    mov     rax,rbx
    add     rsp,18h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L3:
    jmp     L0
    jmp     L5
    jmp     L5
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
L5:
    jmp     L4
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
    .long   L8
    .long   L9
L7:
    ret
L8:
    ret
L9:
    ret

fn main
    sub     rsp,6D8h
    mov     [rsp+170h],rbx
    mov     [rsp+168h],r12
    mov     [rsp+160h],r13
    mov     qword ptr [rsp+198h],50910h
    mov     edi,0
    call    qword ptr [image.fn232.slot]
    test    rax,rax
    jne     L1
    mov     ecx,1
L0:
    test    rcx,rcx
    je      L2
    jmp     L32
L1:
    mov     rcx,[rax]
    mov     rdi,[rax+8]
    lea     r8,[rcx+1]
    mov     [rax],r8
    mov     [rax+8],rdi
    mov     rdx,rcx
    mov     ecx,0
    mov     rsi,rdi
    jmp     L0
L2:
    lea     rax,[image.k624]
    mov     [rsp+698h],rax
    mov     qword ptr [rsp+6A0h],0
    mov     qword ptr [rsp+6A8h],0
    mov     qword ptr [rsp+6B0h],0
    mov     [rsp+6B8h],rdx
    mov     [rsp+6C0h],rsi
    mov     qword ptr [rsp+660h],0
    mov     qword ptr [rsp+668h],50910h
    mov     eax,1
L3:
    mov     rcx,[rsp+660h]
    mov     rdx,[rsp+668h]
    cmp     rcx,rdx
    jae     L4
    lea     rdx,[rcx+1]
    mov     [rsp+660h],rdx
    mov     rbx,rcx
    mov     ecx,1
    jmp     L5
L4:
    mov     ecx,0
L5:
    test    rcx,rcx
    je      L6
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+198h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rax,r10
    mov     r10,14057B7EF767814Fh
    mov     [rsp+198h],r10
    mov     r12,rax
    mov     r10,14057B7EF767814Fh
    add     r12,r10
    lea     rsi,[rsp+698h]
    mov     dword ptr [rsp+19Ch],2Ch
    mov     rdx,r12
    shr     rdx,2Ch
    lea     rdi,[rsp+38h]
    call    qword ptr [image.fn111.slot]
    jmp     L7
L6:
    mov     qword ptr [rsp+0C8h],0
    mov     qword ptr [rsp+0D0h],0
    mov     dword ptr [rsp+19Ch],14h
    mov     qword ptr [rsp+198h],1
    mov     qword ptr [rsp+198h],2
    lea     rdi,[rsp+10h]
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [image.fn117.slot]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     [rsp+580h],rax
    mov     [rsp+588h],rcx
    mov     [rsp+590h],rdx
    mov     [rsp+598h],rsi
    mov     [rsp+180h],rax
    mov     [rsp+188h],rcx
    mov     edi,[rsp+594h]
    mov     r8d,[rsp+59Ch]
    mov     [rsp+190h],edx
    mov     [rsp+194h],edi
    mov     [rsp+198h],esi
    mov     [rsp+19Ch],r8d
    mov     rdx,[rsp+190h]
    mov     rsi,[rsp+198h]
    mov     [rsp+5A0h],rax
    mov     [rsp+5A8h],rcx
    mov     [rsp+5B0h],rdx
    mov     [rsp+5B8h],rsi
    mov     [rsp+540h],rax
    mov     [rsp+548h],rcx
    mov     [rsp+550h],rdx
    mov     [rsp+558h],rsi
    jmp     L11
L7:
    mov     rax,[rsp+38h]
    test    rax,rax
    je      L9
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+48h]
L8:
    mov     [rsp+600h],rax
    mov     [rsp+608h],rcx
    mov     [rsp+610h],rdx
    mov     esi,[rsp+60Ch]
    mov     [rsp+188h],rax
    mov     [rsp+190h],ecx
    mov     [rsp+194h],esi
    mov     [rsp+198h],rdx
    mov     qword ptr [rsp+180h],0
    lea     rdi,[rsp+188h]
    mov     esi,0
    call    fn11
    jmp     L10
L9:
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     eax,0
    jmp     L8
L10:
    mov     rcx,[rax]
    mov     [rsp+198h],rcx
    add     rcx,rbx
    jb      L35
    mov     [rax],rcx
    mov     rax,r12
    jmp     L3
L11:
    mov     rax,[rsp+550h]
    add     rax,1
    test    rax,rax
    je      L33
    mov     rcx,[rsp+548h]
    test    rcx,rcx
    jbe     L12
    mov     rdx,[rsp+540h]
    add     rax,rdx
    mov     [rsp+540h],rax
    sub     rcx,1
    mov     [rsp+548h],rcx
    mov     eax,1
    jmp     L13
L12:
    mov     eax,0
    mov     edx,0
L13:
    test    rax,rax
    je      L18
    mov     [rsp+518h],rdx
    mov     rax,[rsp+6B0h]
    test    rax,rax
    jne     L14
    mov     ecx,0
    jmp     L15
L14:
    lea     rdi,[rsp+6B8h]
    lea     rsi,[rsp+518h]
    call    image.fn79
    lea     rdi,[rsp+698h]
    lea     rdx,[rsp+518h]
    mov     rsi,rax
    call    qword ptr [image.fn18.slot]
    test    rax,rax
    je      L16
    jmp     L17
L15:
    test    rcx,rcx
    je      L11
    jmp     L19
L16:
    mov     ecx,0
    jmp     L15
L17:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L15
L18:
    mov     rax,[rsp+6B0h]
    mov     [rsp+0E0h],rax
    lea     rdi,[rsp+698h]
    call    qword ptr [image.fn4.slot]
    lea     rsi,[rsp+698h]
    lea     rdi,[rsp+480h]
    call    qword ptr [fn23.slot]
    jmp     L20
L19:
    mov     qword ptr [rsp+198h],1
    mov     rax,[rsp+0C8h]
    add     rax,1
    jb      L36
    mov     [rsp+0C8h],rax
    mov     rax,[rsp+0D0h]
    mov     rcx,[rcx]
    add     rax,rcx
    mov     [rsp+0D0h],rax
    jmp     L11
L20:
    mov     rax,[rsp+480h]
    mov     rcx,[rsp+488h]
    mov     [rsp+178h],rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+490h]
    mov     ecx,[rsp+498h]
    mov     edx,[rsp+49Ch]
    mov     [rsp+188h],rax
    mov     [rsp+190h],ecx
    mov     [rsp+194h],edx
    mov     rax,[rsp+4A0h]
    mov     [rsp+198h],rax
    lea     rdi,[rsp+178h]
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+0E8h],rax
    lea     rdi,[rsp+448h]
    call    qword ptr [fn25.slot]
    mov     r10,1FBD000000000h
    mov     [rsp+430h],r10
L21:
    mov     eax,[rsp+430h]
    mov     ecx,[rsp+434h]
    cmp     eax,ecx
    jae     L22
    lea     ecx,[rax+1]
    mov     [rsp+430h],ecx
    mov     rcx,rax
    mov     eax,1
    jmp     L23
L22:
    mov     eax,0
L23:
    mov     eax,eax
    test    rax,rax
    je      L24
    mov     dword ptr [rsp+19Ch],138Bh
    mov     eax,ecx
    mov     [rsp+198h],rax
    mov     r10d,0D196E5F5h
    imul    rax,r10
    mov     [rsp+198h],rax
    shr     rax,2Ch
    mov     [rsp+198h],rax
    mov     [rsp+194h],eax
    imul    eax,138Bh
    mov     [rsp+194h],eax
    sub     ecx,eax
    mov     [rsp+384h],ecx
    lea     rax,[rsp+384h]
    mov     rcx,[image.sym2]
    mov     [rsp+360h],rax
    mov     [rsp+368h],rcx
    mov     [rsp+370h],rax
    mov     [rsp+378h],rcx
    lea     rax,[k32]
    lea     rcx,[rsp+370h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rcx
    mov     rdx,rcx
    and     rdx,1
    cmp     rdx,1
    je      L26
    jmp     L25
L24:
    mov     rdx,[rsp+6B0h]
    mov     [rsp+0F0h],rdx
    lea     rdx,[rsp+0F0h]
    mov     rsi,[rsp+460h]
    mov     [rsp+0F8h],rsi
    lea     rsi,[rsp+0F8h]
    lea     rdi,[rsp+0E0h]
    lea     r8,[rsp+0C8h]
    lea     r9,[rsp+0D0h]
    lea     rbx,[rsp+0E8h]
    mov     r12,[image.sym1]
    mov     r13,[image.sym3]
    mov     [rsp+100h],rdi
    mov     [rsp+108h],r12
    mov     [rsp+110h],r8
    mov     [rsp+118h],r13
    mov     [rsp+120h],r9
    mov     [rsp+128h],r13
    mov     [rsp+130h],rdx
    mov     [rsp+138h],r12
    mov     [rsp+140h],rbx
    mov     [rsp+148h],r13
    mov     [rsp+150h],rsi
    mov     [rsp+158h],r12
    lea     rdi,[k47]
    lea     rsi,[rsp+100h]
    call    sym49
    jmp     L31
L25:
    mov     eax,0
    mov     ecx,0
    jmp     L27
L26:
    shr     rcx,1
    lea     rdx,[image.k3032]
    test    rax,rax
    je      L34
L27:
    lea     rsi,[rsp+78h]
    lea     rdi,[rsp+58h]
    mov     rdx,rcx
    mov     rcx,rsi
    mov     rsi,rax
    call    qword ptr [image.fn0.slot]
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+3A8h],rax
    mov     [rsp+3B0h],rcx
    mov     [rsp+3B8h],rsi
    mov     edi,[rsp+3B4h]
    mov     [rsp+188h],rax
    mov     [rsp+190h],ecx
    mov     [rsp+194h],edi
    mov     [rsp+198h],rsi
    mov     rcx,[rsp+190h]
    mov     [rsp+3C0h],rax
    mov     [rsp+3C8h],rcx
    mov     [rsp+3D0h],rsi
    mov     edi,[rsp+3CCh]
    mov     [rsp+188h],rax
    mov     [rsp+190h],ecx
    mov     [rsp+194h],edi
    mov     [rsp+198h],rsi
    mov     rcx,[rsp+190h]
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rcx
    mov     [rsp+0C0h],rsi
    lea     rdi,[rsp+88h]
    lea     rax,[rsp+0B0h]
    lea     rsi,[rsp+448h]
    mov     rdx,rax
    call    qword ptr [image.fn110.slot]
    mov     rax,[rsp+88h]
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L29
    mov     rcx,[rsp+90h]
    mov     rsi,[rsp+98h]
    mov     rdi,[rsp+0A0h]
    mov     r8,[rsp+0A8h]
L28:
    mov     [rsp+3E0h],rax
    mov     [rsp+3E8h],rcx
    mov     [rsp+3F0h],rsi
    mov     [rsp+3F8h],rdi
    mov     [rsp+400h],r8
    mov     [rsp+178h],rax
    mov     [rsp+180h],rcx
    mov     eax,[rsp+3FCh]
    mov     [rsp+188h],rsi
    mov     [rsp+190h],edi
    mov     [rsp+194h],eax
    mov     [rsp+198h],r8
    lea     rdi,[rsp+178h]
    call    qword ptr [fn37.slot]
    jmp     L30
L29:
    mov     rcx,[rsp+90h]
    mov     rsi,[rsp+98h]
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L28
L30:
    mov     rcx,[rax]
    mov     [rsp+198h],rcx
    mov     qword ptr [rsp+190h],1
    add     rcx,1
    jb      L37
    mov     [rax],rcx
    jmp     L21
L31:
    lea     rdi,[rsp+448h]
    mov     [rsp+198h],rdi
    lea     rsi,[rsp+468h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn24.slot]
    lea     rdi,[rsp+698h]
    mov     [rsp+198h],rdi
    lea     rsi,[rsp+6B8h]
    mov     edx,10h
    mov     ecx,10h
    call    qword ptr [image.fn25.slot]
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+168h]
    mov     r13,[rsp+160h]
    add     rsp,6D8h
    ret
    mov     [rsp],rax
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFF930h
    call    ryo_h_Resume
    ud2
L32:
    lea     rdi,[image.k232]
    call    image.sym6
    ud2
L33:
    lea     rcx,[image.k6720]
    lea     rdi,[image.k4306]
    mov     esi,1A3h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L34:
    lea     rdi,[image.k5783]
    mov     esi,22Fh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
L35:
    lea     rdi,[k12]
    mov     [rsp+198h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
L36:
    lea     rdi,[k19]
    mov     [rsp+198h],rdi
    call    sym13
    ud2
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
    mov     r12,rax
    jmp     L39
    mov     rbx,rax
    jmp     L41
    mov     rbx,rax
    jmp     L41
    mov     rbx,rax
    jmp     L41
L37:
    lea     rdi,[k38]
    mov     [rsp+198h],rdi
    call    sym13
    ud2
    mov     rbx,rax
    jmp     L41
    mov     rbx,rax
    jmp     L41
    mov     r12,rax
    jmp     L39
L38:
    lea     rdi,[rsp+448h]
    mov     [rsp+198h],rdi
    lea     rsi,[rsp+468h]
    mov     edx,20h
    mov     ecx,10h
    call    qword ptr [image.fn24.slot]
    mov     r12,rbx
    jmp     L39
    jmp     L40
L39:
    lea     rdi,[rsp+698h]
    mov     [rsp+198h],rdi
    lea     rsi,[rsp+6B8h]
    mov     edx,10h
    mov     ecx,10h
    call    qword ptr [image.fn25.slot]
    mov     [rsp],r12
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFF930h
    call    ryo_h_Resume
    ud2
L40:
    call    sym54
    ud2
L41:
    jmp     L38
  ; OSR entries
    lea     r11,[L42]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L42:
    .long   L43
    .long   L44
    .long   L45
    .long   L46
    .long   L47
    .long   L48
L43:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-770h]
    mov     r11,[rdx-40h]
    mov     [rsp],r11
    mov     r11,[rdx-480h]
    mov     [rsp+8],r11
    mov     r11,[rdx-478h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-470h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+90h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-568h],r12
    mov     [rdx-570h],r13
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
    jmp     L3
L44:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-760h]
    mov     r11,[rdx-480h]
    mov     [rsp],r11
    mov     r11,[rdx-478h]
    mov     [rsp+8],r11
    mov     r11,[rdx-470h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+88h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-568h],r12
    mov     [rdx-570h],r13
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
    jmp     L11
L45:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-760h]
    mov     r11,[rdx-480h]
    mov     [rsp],r11
    mov     r11,[rdx-478h]
    mov     [rsp+8],r11
    mov     r11,[rdx-470h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+88h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-568h],r12
    mov     [rdx-570h],r13
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
    jmp     L21
L46:
    ret
L47:
    ret
L48:
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

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
    mov     rax,[rdi]
    mov     rcx,[rsi]
    cmp     rax,rcx
    sete    al
    movzx   eax,al
    ret

fn std::collections::HashMap::<u64, u64>::entry
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
    call    image.fn79
    mov     r14,rax
    lea     rdx,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    call    qword ptr [image.fn19.slot]
    jmp     L3
L0:
    mov     ecx,0
    mov     rdx,rax
    mov     rsi,r12
    jmp     L2
L1:
    mov     rdi,r12
    mov     esi,1
    mov     rdx,r13
    call    qword ptr [image.fn20.slot]
    mov     rcx,[rsp+8]
    mov     rdx,r14
    mov     rsi,rcx
    mov     rcx,r12
L2:
    test    rcx,rcx
    je      L5
    jmp     L4
L3:
    test    rax,rax
    je      L1
    jmp     L0
L4:
    mov     [rbx],rcx
    mov     [rbx+8],rdx
    mov     [rbx+10h],rsi
    mov     rax,rbx
    add     rsp,18h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L5:
    mov     ecx,0
    jmp     L4
    jmp     L6
    jmp     L6
L6:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
L8:
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
    jmp     L1
L0:
    mov     byte ptr [rsp+27h],0
    mov     byte ptr [rsp+27h],0
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L1:
    mov     byte ptr [rsp+27h],0
    mov     byte ptr [rsp+27h],0
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    jmp     L6
L2:
    mov     rax,rdx
    add     rsp,38h
    ret
L3:
    mov     rdx,rcx
    lea     rdx,[rdx-8]
    jmp     L2
L4:
    jmp     L3
L5:
    mov     rcx,rax
    lea     rcx,[rcx-8]
    mov     rdx,rcx
    jmp     L2
L6:
    jmp     L5
    jmp     L8
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L8:
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
L17:
    ret
L18:
    ret

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    test    rax,rax
    je      L0
    mov     rdi,rax
    mov     r10,rsi
    mov     rsi,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    lea     rax,[rax-10h]
    jmp     L3
L0:
    lea     rcx,[rcx-10h]
    jmp     L5
L1:
    mov     rax,rdx
    add     rsp,18h
    ret
L2:
    mov     rdx,rax
    lea     rdx,[rdx+8]
    jmp     L1
L3:
    jmp     L2
L4:
    mov     rax,rcx
    lea     rax,[rax+8]
    mov     rdx,rax
    jmp     L1
L5:
    jmp     L4
    jmp     L7
L6:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L7:
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
L16:
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

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    mov     eax,10h
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
    je      L7
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
    call    image.sym57
    mov     rax,[rsp+18h]
    test    rax,rax
    jne     L10
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
    lea     r9,[image.k2736]
    test    r8b,r8b
    jne     L9
    mov     r8,rax
    mov     r14,rdx
    shl     r14,20h
    or      r8,r14
    mov     r14,rsi
    shl     r14,30h
    or      r8,r14
    mov     r14,rdi
    shl     r14,38h
    or      r14,r8
    test    r13,r13
    ja      L2
    jmp     L5
L1:
    mov     r8,0FFFFFFFFFFFFFFFFh
    jmp     L0
L2:
    mov     qword ptr [rsp+30h],1
    lea     rax,[image.k1568]
    test    r14,r14
    je      L11
    cmp     r12,r14
    jae     L3
    mov     rdx,r14
    sub     rdx,r12
    jmp     L4
L3:
    mov     rdx,r12
    sub     rdx,r14
L4:
    cmp     r13,rdx
    ja      L11
    mov     [rsp+30h],r13
    mov     [rsp],r14
    mov     [rsp+8],r12
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFC0h
    call    ryo_h_Memcpy
    lea     rdx,[image.k1672]
    mov     [rsp+30h],rdx
    cmp     r15,r13
    jb      L12
    jmp     L6
L5:
    mov     rcx,r15
    mov     rsi,r14
    mov     edi,0
    jmp     L8
L6:
    mov     rcx,r15
    mov     rsi,r14
    mov     rdi,r13
    jmp     L8
L7:
    mov     rsi,[rcx]
    mov     rcx,[rcx+8]
    lea     rdi,[rsp+38h]
    mov     rdx,rcx
    call    image.sym42
    mov     rcx,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+48h]
L8:
    mov     [rbx],rcx
    mov     [rbx+8],rsi
    mov     [rbx+10h],rdi
    mov     rax,rbx
    add     rsp,50h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    lea     rdi,[image.k5302]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym63
    ud2
L10:
    mov     rdi,[rsp+20h]
    mov     ecx,[rsp+28h]
    movzx   esi,word ptr [rsp+2Ch]
    movzx   r8d,byte ptr [rsp+2Eh]
    movzx   r9d,byte ptr [rsp+2Fh]
    shl     rsi,20h
    or      rcx,rsi
    shl     r8,30h
    or      rcx,r8
    shl     r9,38h
    mov     rsi,rcx
    or      rsi,r9
    call    image.sym58
    ud2
L11:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L12:
    lea     rdi,[image.k4108]
    mov     esi,18Dh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
    mov     ecx,1
    jmp     L16
    mov     ecx,0
    jmp     L16
L13:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L14:
    jmp     L13
L15:
    test    cl,cl
    jne     L14
    jmp     L13
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
    ret
L19:
    ret
L20:
    ret
L21:
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

fn std::ptr::copy_nonoverlapping::<u8>
    sub     rsp,18h
    lea     rcx,[k0]
    test    rdx,rdx
    jne     L0
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    test    al,al
    je      L6
L2:
    test    al,al
    je      L7
L3:
    cmp     rdi,rsi
    jae     L4
    mov     r8,rsi
    sub     r8,rdi
    jmp     L5
L4:
    mov     r8,rdi
    sub     r8,rsi
L5:
    cmp     rdx,r8
    ja      L8
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    call    ryo_hr_Memcpy
    add     rsp,18h
    ret
L6:
    test    rdi,rdi
    je      L8
    jmp     L2
L7:
    test    rsi,rsi
    jne     L3
L8:
    lea     rdi,[image.k4515]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2

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
    jne     L8
    lea     rax,[r14-1]
    and     rax,rbx
    test    rax,rax
    je      L6
    jmp     L12
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    lea     rax,[r14-1]
    and     rax,r12
    test    rax,rax
    je      L7
    jmp     L13
L3:
    mov     rax,r13
    mul     r15
    jb      L10
    cmp     rbx,r12
    jae     L4
    mov     rcx,r12
    sub     rcx,rbx
    jmp     L5
L4:
    mov     rcx,rbx
    sub     rcx,r12
L5:
    cmp     rax,rcx
    ja      L11
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L6:
    test    bpl,bpl
    jne     L2
    test    rbx,rbx
    je      L11
    jmp     L2
L7:
    test    bpl,bpl
    jne     L3
    test    r12,r12
    je      L11
    jmp     L3
L8:
    lea     rdi,[image.k1979]
    lea     rdx,[image.k2104]
    mov     esi,55h
    call    image.sym39
    ud2
L9:
    lea     rdi,[image.k1979]
    lea     rdx,[image.k2104]
    mov     esi,55h
    call    image.sym39
    ud2
L10:
    lea     rdi,[image.k5722]
    mov     esi,3Dh
    call    image.sym64
    ud2
    jmp     L14
    jmp     L14
L11:
    lea     rdi,[k3]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    sym5
    ud2
L12:
    jmp     L11
L13:
    jmp     L11
L14:
    call    sym6
    ud2
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
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
    .long   L25
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
L24:
    ret
L25:
    ret

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    push    rbx
    sub     rsp,20h
    mov     rbx,rdi
    mov     rdi,rbx
    call    image.sym31
    mov     rdi,rbx
    call    image.sym32
    add     rsp,20h
    pop     rbx
    ret
    mov     [rsp+10h],rax
    mov     rdi,rbx
    call    image.sym32
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    call    image.sym21
    ud2

