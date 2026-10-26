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
    cmp     rax,0
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
    mov     edi,0
    jmp     L8
L5:
    mov     dword ptr [rsp+40h],0
    lea     rdx,[rsp+40h]
    lea     rsi,[image.k3192]
    cmp     r12,0
    je      L30
    cmp     rdx,0
    je      L30
    cmp     r12,rdx
    jae     L6
    mov     rdi,rdx
    sub     rdi,r12
    jmp     L7
L6:
    mov     r11,r12
    sub     r11,rdx
    mov     rdx,r11
    mov     rdi,rdx
L7:
    cmp     rdi,4
    jb      L30
    mov     edx,[r12]
    mov     [rsp+40h],edx
    mov     edx,edx
    mov     rdi,rdx
    mov     edx,4
L8:
    mov     r8,rdx
    add     r8,1
    cmp     r8,rax
    jae     L11
    mov     word ptr [rsp+34h],0
    lea     r8,[r12+rdx]
    lea     r9,[rsp+34h]
    lea     r11,[image.k3216]
    mov     [rsp+28h],r11
    cmp     r8,0
    je      L31
    cmp     r9,0
    je      L31
    cmp     r8,r9
    jae     L9
    mov     r15,r9
    sub     r15,r8
    jmp     L10
L9:
    mov     r11,r8
    sub     r11,r9
    mov     r9,r11
    mov     r15,r9
L10:
    cmp     r15,2
    jb      L31
    movzx   r8d,word ptr [r8]
    mov     [rsp+34h],r8w
    movzx   r8d,r8w
    mov     r9,rdx
    imul    r9,8
    mov     rcx,r9
    shl     r8,cl
    or      rdi,r8
    add     rdx,2
L11:
    cmp     rdx,rax
    jae     L12
    lea     r11,[image.k3320]
    mov     [rsp+20h],r11
    cmp     rdx,r13
    jae     L32
    mov     byte ptr [rsp+35h],1
    lea     r8,[r12+rdx]
    movzx   r8d,byte ptr [r8]
    movzx   r8d,r8b
    imul    rdx,8
    mov     rcx,rdx
    shl     r8,cl
    or      rdi,r8
L12:
    mov     rdx,[rbx+40h]
    mov     [rsp+60h],rdx
    imul    rdx,8
    mov     rcx,rdx
    shl     rdi,cl
    mov     rdx,[rbx+38h]
    or      rdx,rdi
    mov     [rbx+38h],rdx
    cmp     r13,r14
    jae     L13
    mov     rdi,[rbx+40h]
    add     rdi,r13
    mov     [rbx+40h],rdi
    jmp     L29
L13:
    mov     rdi,[rbx+18h]
    xor     rdi,rdx
    mov     [rbx+18h],rdi
    mov     rdi,rbx
    call    fn1
    mov     rdx,[rbx+38h]
    mov     rdi,[rbx]
    xor     rdi,rdx
    mov     [rbx],rdi
    mov     qword ptr [rbx+40h],0
L14:
    mov     rdx,r13
    sub     rdx,r14
    mov     rdi,rdx
    and     rdi,7
    mov     r15,r13
    mov     r13,r12
    mov     r12,rdi
    mov     [rsp+10h],rbx
    mov     rbx,rdx
L15:
    mov     [rsp+60h],r14
    mov     rdx,rbx
    sub     rdx,r12
    cmp     r14,rdx
    jae     L19
    mov     qword ptr [rsp+60h],0
    lea     rdx,[r13+r14]
    lea     rdi,[rsp+60h]
    lea     r11,[k4]
    mov     [rsp+18h],r11
    cmp     rdx,0
    je      L33
    cmp     rdi,0
    je      L33
    cmp     rdx,rdi
    jae     L16
    mov     r9,rdi
    sub     r9,rdx
    jmp     L17
L16:
    mov     r11,rdx
    sub     r11,rdi
    mov     rdi,r11
    mov     r9,rdi
L17:
    cmp     r9,8
    jb      L33
    mov     rbp,[rdx]
    mov     [rsp+60h],rbp
    mov     r11,[rsp+10h]
    mov     rdx,[r11+18h]
    xor     rdx,rbp
    mov     r11,[rsp+10h]
    mov     [r11+18h],rdx
    mov     r10,[rsp+10h]
    mov     [rsp+60h],r10
    mov     rdi,[rsp+10h]
    call    fn1
    mov     rdx,[rsp+10h]
    mov     rdi,r14
    mov     r9,r12
    mov     r8,r13
    mov     rax,r15
L18:
    mov     rcx,[rdx]
    xor     rcx,rbp
    mov     [rdx],rcx
    add     rdi,8
    mov     r14,rdi
    mov     r12,r9
    mov     r13,r8
    mov     r15,rax
    mov     [rsp+10h],rdx
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
    lea     rdi,[image.k3192]
    cmp     rax,0
    je      L34
    cmp     rdx,0
    je      L34
    cmp     rax,rdx
    jae     L22
    mov     r8,rdx
    sub     r8,rax
    jmp     L23
L22:
    mov     r11,rax
    sub     r11,rdx
    mov     rdx,r11
    mov     r8,rdx
L23:
    cmp     r8,4
    jb      L34
    mov     eax,[rax]
    mov     [rsp+50h],eax
    mov     eax,eax
    mov     rdx,rax
    mov     eax,4
L24:
    mov     r8,rax
    add     r8,1
    cmp     r8,r12
    jae     L27
    mov     word ptr [rsp+44h],0
    mov     r8,r14
    add     r8,rax
    lea     r8,[r13+r8]
    lea     r9,[rsp+44h]
    lea     rcx,[image.k3216]
    cmp     r8,0
    je      L35
    cmp     r9,0
    je      L35
    cmp     r8,r9
    jae     L25
    mov     rbx,r9
    sub     rbx,r8
    jmp     L26
L25:
    mov     r11,r8
    sub     r11,r9
    mov     r9,r11
    mov     rbx,r9
L26:
    cmp     rbx,2
    jb      L35
    movzx   r8d,word ptr [r8]
    mov     [rsp+44h],r8w
    movzx   r8d,r8w
    mov     r9,rax
    imul    r9,8
    mov     rcx,r9
    shl     r8,cl
    or      rdx,r8
    add     rax,2
L27:
    cmp     rax,r12
    jae     L28
    add     r14,rax
    lea     r8,[image.k3320]
    cmp     r14,r15
    jae     L36
    mov     byte ptr [rsp+45h],1
    lea     r13,[r13+r14]
    movzx   r9d,byte ptr [r13]
    movzx   r9d,r9b
    imul    rax,8
    mov     rcx,rax
    shl     r9,cl
    or      rdx,r9
L28:
    mov     r11,[rsp+10h]
    mov     [r11+38h],rdx
    mov     r11,[rsp+10h]
    mov     [r11+40h],r12
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
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym63
    ud2
L31:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+28h]
    movzx   edx,dl
    call    image.sym63
    ud2
L32:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+20h]
    movzx   edx,dl
    call    image.sym63
    ud2
L33:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym63
    ud2
L34:
    lea     rax,[image.k4515]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L35:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L36:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,r8
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
    mov     r11,[rsp+28h]
    mov     [rdx-80h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r15,[rsp+20h]
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
    mov     rbp,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     rax,[rsp+30h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L18

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
    sub     rsp,18h
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
    add     rsp,18h
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
    sub     rsp,18h
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
    add     rsp,18h
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
    mov     rax,rsi
    add     rax,rcx
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
    sub     rsp,18h
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
    xor     rdx,rax
    mov     rax,rdx
    add     rsp,18h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    sub     rsp,18h
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
    add     rsp,18h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,0B8h
    mov     rax,[rdi]
    mov     rdx,[rdi+8]
    mov     rdi,rax
    mov     r10,736F6D6570736575h
    xor     rdi,r10
    mov     r8,rdx
    mov     r10,646F72616E646F6Dh
    xor     r8,r10
    mov     r9,rax
    mov     r10,6C7967656E657261h
    xor     r9,r10
    mov     rcx,rdx
    mov     r10,7465646279746573h
    xor     rcx,r10
    mov     [rsp+68h],rdi
    mov     [rsp+70h],r9
    mov     [rsp+78h],r8
    mov     [rsp+80h],rcx
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     qword ptr [rsp+98h],0
    mov     qword ptr [rsp+0A0h],0
    mov     qword ptr [rsp+0A8h],0
    lea     r11,[rsp+68h]
    mov     [rsp+10h],r11
    mov     r12,[rsi+8]
    mov     r13,[rsi+10h]
    mov     [rsp+98h],r13
    mov     r11,r13
    and     r11,7
    mov     [rsp+20h],r11
    mov     r15d,0
L0:
    mov     [rsp+30h],r15
    mov     rax,r13
    sub     rax,[rsp+20h]
    cmp     r15,rax
    jae     L6
    mov     qword ptr [rsp+30h],0
    lea     rbp,[r12+r15]
    lea     rbx,[rsp+30h]
    lea     r11,[image.k6632]
    mov     [rsp+18h],r11
    mov     rdi,rbp
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L3
    jmp     L7
L1:
    mov     rdi,rbx
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L4
    jmp     L7
L2:
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    test    al,al
    je      L7
    mov     r14,[rbp]
    mov     [rsp+30h],r14
    mov     rax,[rsp+80h]
    xor     rax,r14
    mov     [rsp+80h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+30h],r10
    mov     rdi,[rsp+10h]
    call    image.fn208
    jmp     L5
L3:
    cmp     rbp,0
    je      L7
    jmp     L1
L4:
    cmp     rbx,0
    je      L7
    jmp     L2
L5:
    mov     rax,[rsp+68h]
    xor     rax,r14
    mov     [rsp+68h],rax
    mov     rax,r15
    add     rax,8
    mov     r15,rax
    jmp     L0
L6:
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,r15
    mov     rcx,[rsp+20h]
    call    image.fn158
    mov     [rsp+0A0h],rax
    mov     r10,[rsp+20h]
    mov     [rsp+0A8h],r10
    mov     byte ptr [rsp+3Fh],0FFh
    lea     rax,[rsp+3Fh]
    mov     rdi,[rsp+10h]
    mov     rsi,rax
    mov     edx,1
    call    image.fn197
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+58h],rdi
    mov     r8,[rsp+98h]
    and     r8,0FFh
    shl     r8,38h
    mov     r9,[rsp+0A0h]
    or      r8,r9
    xor     rdi,r8
    mov     [rsp+58h],rdi
    lea     r9,[rsp+40h]
    add     rax,rsi
    mov     [rsp+40h],rax
    add     rdx,rdi
    mov     [rsp+48h],rdx
    mov     rcx,rsi
    shl     rcx,0Dh
    shr     rsi,33h
    or      rcx,rsi
    mov     [rsp+50h],rcx
    xor     rcx,rax
    mov     [rsp+50h],rcx
    mov     rsi,rdi
    shl     rsi,10h
    shr     rdi,30h
    or      rsi,rdi
    mov     [rsp+58h],rsi
    xor     rsi,rdx
    mov     [rsp+58h],rsi
    mov     rdi,rax
    shl     rdi,20h
    shr     rax,20h
    or      rdi,rax
    mov     [rsp+40h],rdi
    add     rdx,rcx
    mov     [rsp+48h],rdx
    add     rdi,rsi
    mov     [rsp+40h],rdi
    mov     rax,rcx
    shl     rax,11h
    shr     rcx,2Fh
    or      rax,rcx
    mov     [rsp+50h],rax
    xor     rax,rdx
    mov     [rsp+50h],rax
    mov     rax,rsi
    shl     rax,15h
    shr     rsi,2Bh
    or      rax,rsi
    mov     [rsp+58h],rax
    xor     rax,rdi
    mov     [rsp+58h],rax
    mov     rax,rdx
    shl     rax,20h
    shr     rdx,20h
    or      rax,rdx
    mov     [rsp+48h],rax
    xor     rdi,r8
    mov     [rsp+40h],rdi
    xor     rax,0FFh
    mov     [rsp+48h],rax
    mov     rdi,r9
    call    image.fn209
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+50h]
    xor     rax,rdx
    mov     rdx,[rsp+48h]
    xor     rax,rdx
    mov     rdx,[rsp+58h]
    xor     rax,rdx
    add     rsp,0B8h
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
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym63
    ud2
L8:
    call    image.sym30
    ud2
    jmp     L9
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
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
    push    r14
    push    r15
    push    rbp
    sub     rsp,0B8h
    mov     rax,[rdi]
    mov     rdx,[rdi+8]
    mov     rdi,rax
    mov     r10,736F6D6570736575h
    xor     rdi,r10
    mov     r8,rdx
    mov     r10,646F72616E646F6Dh
    xor     r8,r10
    mov     r9,rax
    mov     r10,6C7967656E657261h
    xor     r9,r10
    mov     rcx,rdx
    mov     r10,7465646279746573h
    xor     rcx,r10
    mov     [rsp+68h],rdi
    mov     [rsp+70h],r9
    mov     [rsp+78h],r8
    mov     [rsp+80h],rcx
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     qword ptr [rsp+98h],0
    mov     qword ptr [rsp+0A0h],0
    mov     qword ptr [rsp+0A8h],0
    lea     rbx,[rsp+68h]
    mov     rax,[rsi]
    mov     [rsp+30h],rax
    lea     r12,[rsp+30h]
    mov     qword ptr [rsp+98h],8
    mov     r13d,0
L0:
    mov     [rsp+20h],r13
    cmp     r13,8
    jae     L6
    mov     qword ptr [rsp+20h],0
    lea     r14,[r12+r13]
    lea     r15,[rsp+20h]
    lea     r11,[image.k6632]
    mov     [rsp+10h],r11
    mov     rdi,r14
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L3
    jmp     L7
L1:
    mov     rdi,r15
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L4
    jmp     L7
L2:
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,1
    mov     ecx,8
    call    qword ptr [image.fn171.slot]
    test    al,al
    je      L7
    mov     rbp,[r14]
    mov     [rsp+20h],rbp
    mov     rax,[rsp+80h]
    xor     rax,rbp
    mov     [rsp+80h],rax
    mov     [rsp+20h],rbx
    mov     rdi,rbx
    call    image.fn208
    jmp     L5
L3:
    cmp     r14,0
    je      L7
    jmp     L1
L4:
    cmp     r15,0
    je      L7
    jmp     L2
L5:
    mov     rax,[rsp+68h]
    xor     rax,rbp
    mov     [rsp+68h],rax
    mov     rax,r13
    add     rax,8
    mov     r13,rax
    jmp     L0
L6:
    mov     rdi,r12
    mov     esi,8
    mov     rdx,r13
    mov     ecx,0
    call    qword ptr [image.fn158.slot]
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+0A8h],0
    mov     rdx,[rsp+68h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+78h]
    mov     [rsp+50h],rdi
    mov     r8,[rsp+80h]
    mov     [rsp+58h],r8
    mov     r9,[rsp+98h]
    and     r9,0FFh
    shl     r9,38h
    or      r9,rax
    xor     r8,r9
    mov     [rsp+58h],r8
    lea     rax,[rsp+40h]
    add     rdx,rdi
    mov     [rsp+40h],rdx
    add     rsi,r8
    mov     [rsp+48h],rsi
    mov     rcx,rdi
    shl     rcx,0Dh
    shr     rdi,33h
    or      rcx,rdi
    mov     [rsp+50h],rcx
    xor     rcx,rdx
    mov     [rsp+50h],rcx
    mov     rdi,r8
    shl     rdi,10h
    shr     r8,30h
    or      rdi,r8
    mov     [rsp+58h],rdi
    xor     rdi,rsi
    mov     [rsp+58h],rdi
    mov     r8,rdx
    shl     r8,20h
    shr     rdx,20h
    or      r8,rdx
    mov     [rsp+40h],r8
    add     rsi,rcx
    mov     [rsp+48h],rsi
    add     r8,rdi
    mov     [rsp+40h],r8
    mov     rdx,rcx
    shl     rdx,11h
    shr     rcx,2Fh
    or      rdx,rcx
    mov     [rsp+50h],rdx
    xor     rdx,rsi
    mov     [rsp+50h],rdx
    mov     rdx,rdi
    shl     rdx,15h
    shr     rdi,2Bh
    or      rdx,rdi
    mov     [rsp+58h],rdx
    xor     rdx,r8
    mov     [rsp+58h],rdx
    mov     rdx,rsi
    shl     rdx,20h
    shr     rsi,20h
    or      rdx,rsi
    mov     [rsp+48h],rdx
    xor     r8,r9
    mov     [rsp+40h],r8
    xor     rdx,0FFh
    mov     [rsp+48h],rdx
    mov     rdi,rax
    call    qword ptr [image.fn209.slot]
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+50h]
    xor     rax,rdx
    mov     rdx,[rsp+48h]
    xor     rax,rdx
    mov     rdx,[rsp+58h]
    xor     rax,rdx
    add     rsp,0B8h
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
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym63
    ud2
L8:
    call    image.sym30
    ud2
    jmp     L9
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
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
    sub     rsp,18h
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    add     rsp,18h
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
    cmp     r8,0
    je      L9
    cmp     r9,0
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
    mov     r8d,r8d
    mov     r9,r8
    mov     r8d,4
L4:
    mov     rbx,r8
    add     rbx,1
    cmp     rbx,rax
    jae     L7
    mov     word ptr [rsp+14h],0
    mov     rbx,rdx
    add     rbx,r8
    lea     rbx,[rdi+rbx]
    lea     r12,[rsp+14h]
    lea     r13,[k2]
    cmp     rbx,0
    je      L10
    cmp     r12,0
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
    movzx   ebx,bx
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
    movzx   edx,dl
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
    lea     rdx,[image.k4515]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
L10:
    lea     rdx,[image.k4515]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym63
    ud2
L11:
    lea     rdx,[image.k6416]
    mov     rdi,rdx
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
    sub     rsp,18h
    add     rdi,rsi
    mov     rax,rdi
    add     rsp,18h
    ret

fn core::num::<impl u64>::wrapping_mul
    sub     rsp,18h
    imul    rdi,rsi
    mov     rax,rdi
    add     rsp,18h
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
    lea     rax,[k0]
    mov     rdi,rax
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
    lea     rax,[rsp+20h]
    mov     rdi,rax
    mov     rsi,r13
    call    image.sym19
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    lea     rax,[rsp+30h]
    mov     rdi,rax
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
    cmp     rax,0
    je      L2
    lea     rax,[rsp+70h]
    mov     rdi,rax
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
    sar     rcx,4
    mov     rdi,r15
    mov     rsi,rcx
    call    image.fn146
    lea     rbp,[rbp-10h]
    mov     rdi,rbp
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
    cmp     rax,0
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
    cmp     rdx,0
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
    sub     rsp,0B8h
    mov     [rsp+38h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    cmp     r12w,0
    je      L1
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     rcx,r12
    sub     ecx,1
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     [rsp+18h],rax
    mov     rcx,[rbx+8]
    add     rcx,rax
    mov     [rsp+10h],rcx
    mov     eax,1
    mov     rdx,rcx
    mov     rbx,[rsp+38h]
    mov     r12,[rsp+30h]
    add     rsp,0B8h
    ret
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rbx]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+28h],10h
    lea     rax,[rax+10h]
    mov     [rbx],rax
    mov     [rsp+18h],rax
    lea     rcx,[rsp+40h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym1
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    add     rax,10h
    mov     [rsp+20h],rax
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
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-90h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+20h],r11
    mov     [rdx-78h],rbx
    mov     [rdx-80h],r12
    mov     r11,[rsp+8]
    mov     [rdx-90h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-88h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-98h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    sub     rsp,0C8h
    mov     [rsp+38h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    cmp     r12w,0
    je      L6
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     qword ptr [rsp+10h],1
    mov     rcx,r12
    sub     ecx,1
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     [rsp+18h],rax
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
    mov     [rsp+18h],rsi
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
    mov     rax,[r12+8]
    mov     [rsp+18h],rax
    lea     rdx,[rsp+40h]
    mov     rdi,rdx
    mov     rsi,rax
    call    sym0
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r12+18h],ax
    mov     rax,[r12]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rax
    lea     rax,[rax-200h]
    jmp     L10
L5:
    mov     rbx,[rsp+38h]
    mov     r12,[rsp+30h]
    add     rsp,0C8h
    ret
L6:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+17h],1
    mov     r12,rbx
    jmp     L4
L7:
    mov     [rsp+10h],rcx
    mov     rax,rcx
    jmp     L5
L8:
    jmp     L7
L9:
    mov     [rsp+18h],rax
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
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L1
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
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
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L10

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,138h
    mov     [rsp+78h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+68h],r13
    mov     [rsp+60h],r14
    mov     [rsp+58h],r15
    mov     [rsp+50h],rbp
    mov     [rsp+0F0h],rcx
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     r11,[rdi+10h]
    movzx   r8d,word ptr [rdi+18h]
    mov     r11d,[rdi+1Ah]
    movzx   r11d,word ptr [rdi+1Eh]
    mov     rbx,r8
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,rax
L0:
    cmp     bx,0
    je      L4
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     qword ptr [rsp+28h],1
    mov     rcx,rbx
    sub     ecx,1
    and     ebx,ecx
    mov     [rsp+30h],rax
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,r15
    mov     rax,r11
    mov     rcx,rax
    mov     rdx,rbx
    jmp     L6
L1:
    sub     rcx,1
    mov     rbx,rdx
    mov     r12,rcx
    mov     r13,rax
    mov     r14,rsi
    mov     r15,rdi
    jmp     L0
L2:
    mov     rax,r13
    mov     rbx,[rsp+78h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+68h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+50h]
    add     rsp,138h
    ret
L3:
    mov     [rsp+30h],rbx
    lea     rax,[rsp+80h]
    mov     rdi,rax
    mov     rsi,rbx
    call    sym0
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    sym3
    jmp     L7
L4:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+30h],0
    mov     byte ptr [rsp+2Fh],1
    cmp     r12,0
    je      L2
    mov     rbx,r14
    mov     rbp,r15
    mov     [rsp+10h],r12
    mov     [rsp+18h],r13
    jmp     L3
L5:
    mov     [rsp+28h],rcx
    mov     r12,[rsp+0F0h]
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
    mov     rsi,r12
    mov     rdi,rdx
    mov     rdx,r13
    mov     r8,r14
    mov     r9,r15
    jmp     L5
L7:
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rsp+28h],rbp
    mov     [rsp+30h],rbp
    lea     rbp,[rbp-100h]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    jmp     L9
L8:
    mov     [rsp+30h],rax
    lea     rcx,[rcx+10h]
    mov     rbx,rdx
    mov     r12,rsi
    mov     r13,rdi
    mov     r14,rcx
    mov     r15,rax
    jmp     L0
L9:
    mov     rsi,rcx
    mov     rcx,rbx
    mov     rdi,rdx
    mov     rdx,rax
    mov     rax,rbp
    jmp     L8
    jmp     L13
L10:
    jmp     L12
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED0h
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
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+40h],r11
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
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-100h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L0
L16:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+40h],r11
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
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-100h],r11
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
    lea     rsp,[rdx-170h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+38h],r11
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
    mov     r11,[rsp+30h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-118h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+8]
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
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+48h],r11
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
    mov     r11,[rsp+40h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-100h],r11
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
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+48h],r11
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
    mov     r11,[rsp+40h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-100h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+50h]
    jmp     L6
L24:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+40h],r11
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
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-100h],r11
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
    lea     rsp,[rdx-180h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+40h],r11
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
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-100h],r11
    mov     rbp,[rsp]
    mov     rbx,[rsp+8]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L9

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,0C8h
    mov     [rsp+38h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    cmp     r12w,0
    je      L6
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     qword ptr [rsp+10h],1
    mov     rcx,r12
    sub     ecx,1
    and     r12d,ecx
    mov     [rbx+18h],r12w
    mov     [rsp+18h],rax
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
    mov     [rsp+18h],rsi
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
    mov     rax,[r12+8]
    mov     [rsp+18h],rax
    lea     rdx,[rsp+40h]
    mov     rdi,rdx
    mov     rsi,rax
    call    sym0
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    sym2
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r12+18h],ax
    mov     rax,[r12]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rax
    lea     rax,[rax-100h]
    jmp     L10
L5:
    mov     rbx,[rsp+38h]
    mov     r12,[rsp+30h]
    add     rsp,0C8h
    ret
L6:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+17h],1
    mov     r12,rbx
    jmp     L4
L7:
    mov     [rsp+10h],rcx
    mov     rax,rcx
    jmp     L5
L8:
    jmp     L7
L9:
    mov     [rsp+18h],rax
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
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L1
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+20h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
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
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+28h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
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
    push    rbp
    sub     rsp,0A8h
    mov     [rsp+10h],rdi
    mov     [rsp+80h],rdx
    lea     rax,[rsp+80h]
    mov     [rsp+90h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+98h],r10
    lea     r12,[rsp+90h]
    lea     r13,[k0]
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r11,rax
    mov     [rsp+18h],r11
    mov     [rsp+40h],rsi
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+58h],rax
    and     rsi,rax
    mov     [rsp+48h],rsi
    mov     r15,rsi
    mov     ebp,0
L0:
    mov     [rsp+40h],r15
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rax
    lea     rax,[rax+r15]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rax
    call    image.sym59
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     rsi,[rsp+18h]
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rax,[rsp+50h]
    mov     ecx,[rsp+58h]
    movzx   edx,word ptr [rsp+5Ch]
    movzx   esi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],ecx
    mov     [rsp+7Ch],dx
    mov     [rsp+7Eh],si
    lea     rax,[rsp+40h]
    lea     rbx,[rsp+60h]
    lea     rcx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rdi,rbx
    call    image.sym20
    mov     [rsp+5Ch],eax
    mov     rbx,rax
L1:
    cmp     bx,0
    je      L3
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+50h],1
    mov     [rsp+5Eh],bx
    mov     rcx,rbx
    sub     ecx,1
    and     ebx,ecx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+58h],rax
    add     rax,r15
    mov     r11,[rsp+10h]
    mov     rcx,[r11+8]
    and     rax,rcx
    mov     [rsp+50h],rax
    mov     rcx,[r13+20h]
    mov     rdi,r12
    mov     rsi,rax
    mov     rax,rcx
    call    rax
    test    al,al
    je      L4
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
L2:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    cmp     rax,0
    je      L7
    jmp     L6
L3:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+58h],0
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rax,[rsp+50h]
    mov     edx,[rsp+58h]
    movzx   esi,word ptr [rsp+5Ch]
    movzx   edi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],edx
    mov     [rsp+7Ch],si
    mov     [rsp+7Eh],di
    lea     rax,[rsp+40h]
    lea     r14,[rsp+60h]
    lea     rdx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,r14
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,r14
    call    image.sym20
    cmp     ax,0
    je      L5
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[image.k2864]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L4:
    jmp     L1
L5:
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+48h],rax
    add     rbp,10h
    mov     [rsp+40h],rbp
    add     r15,rbp
    and     r15,rax
    jmp     L0
L6:
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+90h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+98h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+90h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
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
    cmp     esi,0
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
    sub     rsp,0A8h
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rsi,[rdx+10h]
    mov     rdx,[rdx+18h]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rcx
    mov     [rsp+98h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+60h],r12
    mov     rax,[rbx+8]
    and     rax,r12
    mov     [rsp+68h],rax
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+58h],0
L0:
    mov     rax,[rsp+50h]
    mov     rcx,[rbx]
    mov     [rsp+70h],rcx
    mov     [rsp+78h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+70h]
    mov     rdi,rax
    mov     rsi,rcx
    call    image.sym59
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    lea     rdx,[rsp+60h]
    mov     [rsp+78h],rdx
    lea     rdx,[rsp+50h]
    mov     [rsp+70h],rdx
    mov     edx,[rsp+6Ch]
    mov     [rsp+40h],rax
    mov     [rsp+48h],ecx
    mov     [rsp+4Ch],edx
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    image.sym20
    cmp     ax,0
    je      L3
    jmp     L2
L1:
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    cmp     rcx,1
    je      L5
    jmp     L4
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFF50h
    call    ryo_h_CttzW16
    mov     eax,[rsp+4Ch]
    mov     eax,eax
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+28h],1
    mov     rcx,[rsp+50h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+10h],1
    jmp     L1
L3:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+28h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L1
L4:
    mov     rax,[rbx+8]
    mov     [rsp+78h],rax
    mov     rcx,[rsp+58h]
    add     rcx,10h
    mov     [rsp+58h],rcx
    mov     [rsp+70h],rcx
    mov     rsi,[rsp+50h]
    add     rsi,rcx
    mov     [rsp+50h],rsi
    and     rsi,rax
    mov     [rsp+50h],rsi
    jmp     L0
L5:
    mov     [rsp+78h],rdx
    mov     rdi,rbx
    mov     rsi,rdx
    call    image.fn142
    mov     rcx,[rbx]
    lea     rcx,[rcx+rax]
    movzx   edx,byte ptr [rcx]
    shr     r12,39h
    and     r12,7Fh
    mov     rsi,rax
    sub     rsi,10h
    mov     rdi,[rbx+8]
    and     rsi,rdi
    add     rsi,10h
    mov     [rcx],r12b
    mov     rcx,[rbx]
    lea     rcx,[rcx+rsi]
    mov     [rcx],r12b
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    jmp     L7
L6:
    mov     rax,rdx
    and     eax,1
    cmp     al,0
    setne   al
    movzx   eax,al
    mov     rsi,[rbx+10h]
    sub     rsi,rax
    mov     [rbx+10h],rsi
    mov     rax,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+98h]
    mov     r8,[rsp+0A0h]
    jmp     L9
L7:
    jmp     L6
L8:
    mov     [rcx-20h],rax
    mov     [rcx-18h],rsi
    mov     [rcx-10h],rdi
    mov     [rcx-8],r8
    mov     rdx,[rbx+18h]
    add     rdx,1
    mov     [rbx+18h],rdx
    mov     rax,rcx
    add     rsp,0A8h
    pop     r12
    pop     rbx
    ret
L9:
    jmp     L8
    mov     rbx,rax
    jmp     L11
L10:
    mov     [rsp],rbx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
L11:
    lea     rax,[rsp+88h]
    mov     rdi,rax
    call    qword ptr [image.fn51.slot]
    jmp     L10
    call    sym2
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
    .long   L16
    .long   L17
    .long   L18
    .long   L19
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
L19:
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
    lea     rbx,[rsp+38h]
    mov     rsi,[rcx-18h]
    mov     rdi,[rcx-10h]
    mov     rdx,rdi
    mov     rdi,rbx
    call    image.fn197
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rsi,[rsp+0Fh]
    mov     rdi,rbx
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

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    push    rbx
    sub     rsp,10h
    mov     rbx,rsi
    mov     rax,[rdi]
    sub     rax,rbx
    sar     rax,4
    mov     rsi,rax
    call    qword ptr [image.fn146.slot]
    lea     rbx,[rbx-10h]
    jmp     L1
L0:
    mov     rdi,rbx
    call    sym1
    add     rsp,10h
    pop     rbx
    ret
L1:
    jmp     L0
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,0A8h
    mov     [rsp+10h],rdi
    mov     [rsp+80h],rdx
    lea     rax,[rsp+80h]
    mov     [rsp+90h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+98h],r10
    lea     r12,[rsp+90h]
    lea     r13,[k0]
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r11,rax
    mov     [rsp+18h],r11
    mov     [rsp+40h],rsi
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+58h],rax
    and     rsi,rax
    mov     [rsp+48h],rsi
    mov     r15,rsi
    mov     ebp,0
L0:
    mov     [rsp+40h],r15
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rax
    lea     rax,[rax+r15]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rax
    call    image.sym59
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     rsi,[rsp+18h]
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rax,[rsp+50h]
    mov     ecx,[rsp+58h]
    movzx   edx,word ptr [rsp+5Ch]
    movzx   esi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],ecx
    mov     [rsp+7Ch],dx
    mov     [rsp+7Eh],si
    lea     rax,[rsp+40h]
    lea     rbx,[rsp+60h]
    lea     rcx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rdi,rbx
    call    image.sym20
    mov     [rsp+5Ch],eax
    mov     rbx,rax
L1:
    cmp     bx,0
    je      L3
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+50h],1
    mov     [rsp+5Eh],bx
    mov     rcx,rbx
    sub     ecx,1
    and     ebx,ecx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+58h],rax
    add     rax,r15
    mov     r11,[rsp+10h]
    mov     rcx,[r11+8]
    and     rax,rcx
    mov     [rsp+50h],rax
    mov     rcx,[r13+20h]
    mov     rdi,r12
    mov     rsi,rax
    mov     rax,rcx
    call    rax
    test    al,al
    je      L4
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
L2:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    cmp     rax,0
    je      L7
    jmp     L6
L3:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+58h],0
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rax,[rsp+50h]
    mov     edx,[rsp+58h]
    movzx   esi,word ptr [rsp+5Ch]
    movzx   edi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],edx
    mov     [rsp+7Ch],si
    mov     [rsp+7Eh],di
    lea     rax,[rsp+40h]
    lea     r14,[rsp+60h]
    lea     rdx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,r14
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,r14
    call    image.sym20
    cmp     ax,0
    je      L5
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[image.k2864]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L4:
    jmp     L1
L5:
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+48h],rax
    add     rbp,10h
    mov     [rsp+40h],rbp
    add     r15,rbp
    and     r15,rax
    jmp     L0
L6:
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+90h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+98h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+90h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
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
    push    rbp
    sub     rsp,0A8h
    mov     [rsp+10h],rdi
    mov     [rsp+80h],rdx
    lea     rax,[rsp+80h]
    mov     [rsp+90h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+98h],r10
    lea     r12,[rsp+90h]
    lea     r13,[k0]
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     r11,rax
    mov     [rsp+18h],r11
    mov     [rsp+40h],rsi
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+58h],rax
    and     rsi,rax
    mov     [rsp+48h],rsi
    mov     r15,rsi
    mov     ebp,0
L0:
    mov     [rsp+40h],r15
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rax
    lea     rax,[rax+r15]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rax
    call    image.sym59
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     rsi,[rsp+18h]
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rax,[rsp+50h]
    mov     ecx,[rsp+58h]
    movzx   edx,word ptr [rsp+5Ch]
    movzx   esi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],ecx
    mov     [rsp+7Ch],dx
    mov     [rsp+7Eh],si
    lea     rax,[rsp+40h]
    lea     rbx,[rsp+60h]
    lea     rcx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rdi,rbx
    call    image.sym20
    mov     [rsp+5Ch],eax
    mov     rbx,rax
L1:
    cmp     bx,0
    je      L3
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+50h],1
    mov     [rsp+5Eh],bx
    mov     rcx,rbx
    sub     ecx,1
    and     ebx,ecx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+58h],rax
    add     rax,r15
    mov     r11,[rsp+10h]
    mov     rcx,[r11+8]
    and     rax,rcx
    mov     [rsp+50h],rax
    mov     rcx,[r13+20h]
    mov     rdi,r12
    mov     rsi,rax
    mov     rax,rcx
    call    rax
    test    al,al
    je      L4
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
L2:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    cmp     rax,0
    je      L7
    jmp     L6
L3:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+58h],0
    lea     rax,[rsp+50h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    image.sym49
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rax,[rsp+50h]
    mov     edx,[rsp+58h]
    movzx   esi,word ptr [rsp+5Ch]
    movzx   edi,word ptr [rsp+5Eh]
    mov     [rsp+70h],rax
    mov     [rsp+78h],edx
    mov     [rsp+7Ch],si
    mov     [rsp+7Eh],di
    lea     rax,[rsp+40h]
    lea     r14,[rsp+60h]
    lea     rdx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,r14
    call    image.sym60
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,r14
    call    image.sym20
    cmp     ax,0
    je      L5
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[image.k2864]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L4:
    jmp     L1
L5:
    mov     r11,[rsp+10h]
    mov     rax,[r11+8]
    mov     [rsp+48h],rax
    add     rbp,10h
    mov     [rsp+40h],rbp
    add     r15,rbp
    and     r15,rax
    jmp     L0
L6:
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+90h],rax
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+98h],rax
    jmp     L10
L7:
    mov     ecx,0
L8:
    mov     rax,rcx
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    mov     [rsp+90h],rax
    mov     rcx,rax
    jmp     L8
L10:
    jmp     L9
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
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
    mov     r15,r13
    shr     r15,20h
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
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+90h]
    mov     rdi,rax
    mov     rsi,rcx
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
    mov     [rsp+60h],rax
    mov     [rsp+68h],ecx
    mov     [rsp+6Ch],edx
    lea     rax,[rsp+60h]
    mov     rdi,rax
    call    image.sym20
    cmp     ax,0
    je      L3
    jmp     L2
L1:
    mov     rcx,[rsp+30h]
    mov     rdx,[rsp+38h]
    cmp     rcx,1
    je      L5
    jmp     L4
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFF30h
    call    ryo_h_CttzW16
    mov     eax,[rsp+6Ch]
    mov     eax,eax
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],1
    mov     rcx,[rsp+70h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     [rsp+38h],rcx
    mov     qword ptr [rsp+30h],1
    jmp     L1
L3:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+48h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
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
    mov     rdi,rbx
    mov     rsi,rdx
    call    qword ptr [image.fn142.slot]
    mov     rcx,[rbx]
    lea     rcx,[rcx+rax]
    movzx   edx,byte ptr [rcx]
    shr     r12,39h
    and     r12,7Fh
    mov     rsi,rax
    sub     rsi,10h
    mov     rdi,[rbx+8]
    and     rsi,rdi
    add     rsi,10h
    mov     [rcx],r12b
    mov     rcx,[rbx]
    lea     rcx,[rcx+rsi]
    mov     [rcx],r12b
    mov     rcx,[rbx]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    jmp     L7
L6:
    mov     rax,rdx
    and     eax,1
    cmp     al,0
    setne   al
    movzx   eax,al
    mov     rsi,[rbx+10h]
    sub     rsi,rax
    mov     [rbx+10h],rsi
    jmp     L9
L7:
    jmp     L6
L8:
    mov     [rcx-10h],r13d
    mov     [rcx-0Ch],r15w
    mov     [rcx-0Ah],bpl
    mov     r10,[rsp+10h]
    mov     [rcx-9],r10b
    mov     [rcx-8],r14d
    mov     r10,[rsp+18h]
    mov     [rcx-4],r10w
    mov     r10,[rsp+20h]
    mov     [rcx-2],r10b
    mov     r10,[rsp+28h]
    mov     [rcx-1],r10b
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,rcx
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    jmp     L8
    jmp     L11
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
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
    lea     rsi,[rsp+48h]
    mov     rdi,[rcx-10h]
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+10h]
    mov     edx,8
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
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
    cmp     rax,0
    je      L2
    mov     r12,[rbx]
    mov     [rsp+70h],r12
    mov     [rsp+68h],r12
    mov     [rsp+78h],r12
    mov     r13,[rbx]
    mov     rax,[rbx+8]
    add     rax,1
    lea     r14,[r13+rax]
    lea     rax,[rsp+10h]
    mov     rdi,rax
    mov     rsi,r13
    call    image.sym19
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    lea     rax,[rsp+20h]
    mov     rdi,rax
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
    cmp     rax,0
    je      L2
    lea     rax,[rsp+58h]
    mov     rdi,rax
    call    fn1
    mov     rcx,[rsp+78h]
    sub     rcx,1
    mov     [rsp+78h],rcx
    cmp     rax,0
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
    push    r15
    push    rbp
    sub     rsp,88h
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     rax,r12
    sub     rax,10h
    mov     [rsp+48h],rax
    mov     r11,[rsp+10h]
    mov     rcx,[r11+8]
    mov     [rsp+40h],rcx
    and     rax,rcx
    mov     r11,[rsp+10h]
    mov     rcx,[r11]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    lea     rcx,[rcx+rax]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rcx
    lea     rax,[rsp+20h]
    mov     rdi,rax
    mov     rsi,rcx
    call    sym0
    lea     r13,[rsp+50h]
    mov     rdi,r13
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     eax,[rsp+50h]
    mov     ecx,[rsp+54h]
    mov     edx,[rsp+58h]
    mov     esi,[rsp+5Ch]
    mov     [rsp+70h],eax
    mov     [rsp+74h],ecx
    mov     [rsp+78h],edx
    mov     [rsp+7Ch],esi
    lea     r14,[rsp+40h]
    lea     r15,[rsp+60h]
    lea     rbp,[rsp+70h]
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    call    sym2
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rdi,r15
    call    sym3
    mov     [rsp+5Ch],eax
    mov     rbx,rax
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+58h],rax
    mov     [rsp+40h],rax
    lea     rax,[rax+r12]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym0
    mov     rdi,r13
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     eax,[rsp+50h]
    mov     ecx,[rsp+54h]
    mov     edx,[rsp+58h]
    mov     esi,[rsp+5Ch]
    mov     [rsp+70h],eax
    mov     [rsp+74h],ecx
    mov     [rsp+78h],edx
    mov     [rsp+7Ch],esi
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    call    sym2
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rcx
    mov     rdi,r15
    call    sym3
    mov     [rsp+5Ch],eax
    mov     r13,rax
    mov     rdi,rbx
    call    ryo_hr_CtlzW16
    mov     [rsp+5Ch],eax
    mov     ebx,eax
    mov     [rsp+40h],rbx
    mov     rdi,r13
    call    ryo_hr_CttzW16
    mov     [rsp+54h],eax
    mov     eax,eax
    mov     [rsp+58h],rax
    add     rbx,rax
    mov     [rsp+48h],rbx
    cmp     rbx,10h
    jb      L0
    mov     eax,80h
    jmp     L1
L0:
    mov     r11,[rsp+10h]
    mov     rax,[r11+10h]
    add     rax,1
    mov     [rsp+60h],rax
    mov     r11,[rsp+10h]
    mov     [r11+10h],rax
    mov     eax,0FFh
L1:
    mov     rcx,r12
    sub     rcx,10h
    mov     [rsp+58h],rcx
    mov     r11,[rsp+10h]
    mov     rdx,[r11+8]
    mov     [rsp+50h],rdx
    and     rcx,rdx
    mov     [rsp+40h],rcx
    add     rcx,10h
    mov     [rsp+48h],rcx
    mov     r11,[rsp+10h]
    mov     rcx,[r11]
    mov     [rsp+50h],rcx
    lea     rcx,[rcx+r12]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    mov     [rcx],al
    mov     r11,[rsp+10h]
    mov     rcx,[r11]
    mov     [rsp+50h],rcx
    mov     rdx,[rsp+48h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    mov     [rcx],al
    mov     r11,[rsp+10h]
    mov     rax,[r11+18h]
    sub     rax,1
    mov     [rsp+60h],rax
    mov     r11,[rsp+10h]
    mov     [r11+18h],rax
    add     rsp,88h
    pop     rbp
    pop     r15
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
    sub     rsp,138h
    mov     [rsp+0B8h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A8h],r13
    mov     [rsp+0A0h],r14
    mov     [rsp+98h],r15
    mov     [rsp+90h],rbp
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     [rsp+50h],rsi
    mov     r8,[rdi+8]
    mov     [rsp+68h],r8
    and     rsi,r8
    mov     [rsp+58h],rsi
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,rax
    mov     r14,rcx
    mov     r15,rdx
    mov     qword ptr [rsp+10h],0
L0:
    mov     [rsp+50h],rbx
    mov     rax,[r12]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rax
    lea     rax,[rax+rbx]
    mov     [rsp+58h],rax
    mov     [rsp+50h],rax
    lea     rcx,[rsp+0C0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym0
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     rsi,r13
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0C0h]
    mov     rcx,[rsp+0C8h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rcx
    mov     rax,[rsp+60h]
    mov     ecx,[rsp+68h]
    movzx   edx,word ptr [rsp+6Ch]
    movzx   esi,word ptr [rsp+6Eh]
    mov     [rsp+80h],rax
    mov     [rsp+88h],ecx
    mov     [rsp+8Ch],dx
    mov     [rsp+8Eh],si
    lea     rax,[rsp+50h]
    lea     rbp,[rsp+70h]
    lea     rcx,[rsp+80h]
    mov     rdi,rax
    mov     rsi,rbp
    mov     rdx,rcx
    call    sym2
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rcx
    mov     rdi,rbp
    call    sym3
    mov     [rsp+6Ch],eax
    mov     [rsp+30h],r12
    mov     r12,rbx
    mov     rbx,rax
    mov     [rsp+28h],r14
    mov     [rsp+20h],r15
    mov     rbp,[rsp+10h]
    mov     [rsp+18h],r13
L1:
    cmp     bx,0
    je      L4
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+60h],1
    mov     [rsp+6Eh],bx
    mov     rcx,rbx
    sub     ecx,1
    and     ebx,ecx
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+50h],1
    mov     [rsp+68h],rax
    add     rax,r12
    mov     r11,[rsp+30h]
    mov     rcx,[r11+8]
    and     rax,rcx
    mov     [rsp+60h],rax
    mov     r11,[rsp+28h]
    mov     rcx,[r11+20h]
    mov     rdi,[rsp+20h]
    mov     rsi,rax
    mov     rax,rcx
    call    rax
    mov     rcx,r12
    mov     rdx,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdi,[rsp+20h]
    mov     r8,rbp
    mov     r9,[rsp+18h]
L2:
    test    al,al
    je      L5
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
L3:
    mov     rax,[rsp+40h]
    mov     r15,[rsp+48h]
    mov     rdx,r15
    mov     rbx,[rsp+0B8h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A8h]
    mov     r14,[rsp+0A0h]
    mov     r15,[rsp+98h]
    mov     rbp,[rsp+90h]
    add     rsp,138h
    ret
L4:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+68h],0
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0C0h]
    mov     r15,[rsp+0C8h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],r15
    mov     rax,[rsp+60h]
    mov     r15d,[rsp+68h]
    movzx   r14d,word ptr [rsp+6Ch]
    movzx   r13d,word ptr [rsp+6Eh]
    mov     [rsp+80h],rax
    mov     [rsp+88h],r15d
    mov     [rsp+8Ch],r14w
    mov     [rsp+8Eh],r13w
    lea     rax,[rsp+50h]
    lea     r13,[rsp+70h]
    lea     r14,[rsp+80h]
    mov     rdi,rax
    mov     rsi,r13
    mov     rdx,r14
    call    sym2
    mov     rax,[rsp+50h]
    mov     r14,[rsp+58h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],r14
    mov     rdi,r13
    call    sym3
    cmp     ax,0
    je      L6
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF10h
    lea     rdx,[k8]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L3
L5:
    mov     r12,rcx
    mov     [rsp+30h],rdx
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdi
    mov     rbp,r8
    mov     [rsp+18h],r9
    jmp     L1
L6:
    mov     r11,[rsp+30h]
    mov     rax,[r11+8]
    mov     [rsp+58h],rax
    add     rbp,10h
    mov     [rsp+50h],rbp
    add     r12,rbp
    and     r12,rax
    mov     rbx,r12
    mov     r12,[rsp+30h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+28h]
    mov     r15,[rsp+20h]
    mov     [rsp+10h],rbp
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
    lea     rsp,[rdx-1B0h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-8]
    mov     [rsp+78h],r11
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
    mov     r11,[rsp+70h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-120h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L0
L9:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-1C0h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-8]
    mov     [rsp+80h],r11
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
    mov     r11,[rsp+78h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-110h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-118h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+90h]
    jmp     L1
L10:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-1C0h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-8]
    mov     [rsp+88h],r11
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
    mov     r11,[rsp+80h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+38h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+90h]
    jmp     L2
L11:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,108h
    mov     [rsp+98h],rbx
    mov     [rsp+0A0h],rsi
    mov     rax,[rdi+8]
    and     rsi,rax
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],rsi
    mov     qword ptr [rsp+0B8h],0
    mov     rbx,rdi
L0:
    mov     rax,[rsp+0B0h]
    mov     rcx,[rbx]
    mov     [rsp+80h],rcx
    mov     [rsp+88h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+80h]
    mov     rdi,rax
    mov     rsi,rcx
    call    sym0
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rcx
    lea     rdx,[rsp+0A0h]
    mov     [rsp+88h],rdx
    lea     rdx,[rsp+0B0h]
    mov     [rsp+80h],rdx
    mov     edx,[rsp+0ACh]
    mov     [rsp+40h],rax
    mov     [rsp+48h],ecx
    mov     [rsp+4Ch],edx
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    image.sym20
    cmp     ax,0
    je      L3
    jmp     L2
L1:
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    jmp     L4
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFF00h
    call    ryo_h_CttzW16
    mov     eax,[rsp+4Ch]
    mov     eax,eax
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+28h],1
    mov     rcx,[rsp+0B0h]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+10h],1
    jmp     L1
L3:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF28h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+28h]
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L1
L4:
    cmp     rcx,1
    je      L6
    mov     rax,[rbx+8]
    mov     [rsp+88h],rax
    mov     rcx,[rsp+0B8h]
    add     rcx,10h
    mov     [rsp+0B8h],rcx
    mov     [rsp+80h],rcx
    mov     rsi,[rsp+0B0h]
    add     rsi,rcx
    mov     [rsp+0B0h],rsi
    and     rsi,rax
    mov     [rsp+0B0h],rsi
    jmp     L0
L5:
    mov     rbx,[rsp+98h]
    add     rsp,108h
    ret
L6:
    mov     [rsp+88h],rdx
    mov     [rsp+68h],rdx
    mov     rcx,[rbx]
    lea     rsi,[rcx+rdx]
    mov     [rsp+60h],rsi
    movzx   esi,byte ptr [rsi]
    and     esi,80h
    cmp     sil,0
    jne     L8
    lea     rsi,[rsp+50h]
    mov     rdi,rsi
    mov     rsi,rcx
    call    image.sym19
    mov     rcx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     [rsp+70h],rcx
    mov     [rsp+78h],rsi
    lea     rcx,[rsp+70h]
    mov     rdi,rcx
    call    image.sym20
    mov     rcx,rax
    cmp     cx,0
    je      L11
    jmp     L9
L7:
    jmp     L5
L8:
    mov     rax,rdx
    jmp     L7
L9:
    mov     rdi,rcx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+60h],1
L10:
    mov     r11,[rsp+60h]
    mov     rax,[rsp+68h]
    jmp     L7
L11:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF60h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
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
L13:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-68h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L14:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-120h]
    mov     r11,[rdx-70h]
    mov     [rsp],r11
    mov     r11,[rdx-68h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     [rdx-68h],rbx
    mov     rcx,[rsp]
    mov     rbx,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+20h]
    jmp     L4
L15:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    push    rbx
    push    r12
    sub     rsp,58h
    mov     rbx,rdi
    mov     r12,rdx
    mov     rax,[rsi]
    mov     ecx,[rsi+8]
    mov     edx,[rsi+0Ch]
    mov     [rsp+40h],rax
    mov     [rsp+48h],ecx
    mov     [rsp+4Ch],edx
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    sym0
    cmp     ax,0
    je      L2
    jmp     L1
L0:
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rax,rcx
    add     rsp,58h
    pop     r12
    pop     rbx
    ret
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFECh
    mov     edx,0FFFFFFA0h
    call    ryo_h_CttzW16
    mov     eax,[rsp+4Ch]
    mov     eax,eax
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+28h],1
    mov     rcx,[r12]
    add     rcx,rax
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+10h],1
    jmp     L0
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+28h]
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
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

fn hashbrown::raw::RawTableInner::fix_insert_index
    sub     rsp,48h
    mov     [rsp+28h],rsi
    mov     rax,[rdi]
    lea     rcx,[rax+rsi]
    mov     [rsp+20h],rcx
    movzx   ecx,byte ptr [rcx]
    and     ecx,80h
    cmp     cl,0
    jne     L1
    lea     rcx,[rsp+10h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym0
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    sym1
    cmp     ax,0
    je      L4
    jmp     L2
L0:
    mov     rax,rcx
    add     rsp,48h
    ret
L1:
    mov     rcx,rsi
    jmp     L0
L2:
    mov     rdi,rax
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
L3:
    mov     r11,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     rcx,rax
    jmp     L0
L4:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L3
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
    .long   L7
L6:
    ret
L7:
    ret

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    sub     rsp,3A8h
    mov     [rsp+248h],rbx
    mov     [rsp+240h],r12
    mov     [rsp+238h],r13
    mov     [rsp+230h],r14
    mov     [rsp+228h],r15
    mov     [rsp+220h],rbp
    mov     [rsp+48h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+40h],rcx
    mov     [rsp+38h],r8
    mov     r11,[rsp+3B8h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+3B0h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+30h]
    shr     r11,10h
    mov     [rsp+10h],r11
    mov     r11,[rsp+30h]
    shr     r11,20h
    mov     [rsp+18h],r11
    mov     r11,[rsp+30h]
    shr     r11,30h
    mov     [rsp+20h],r11
    mov     r11,[rsp+30h]
    shr     r11,38h
    mov     [rsp+28h],r11
    mov     r11,[rsp+80h]
    shr     r11,10h
    mov     [rsp+78h],r11
    mov     r11,[rsp+80h]
    shr     r11,20h
    mov     [rsp+70h],r11
    mov     r11,[rsp+80h]
    shr     r11,30h
    mov     [rsp+68h],r11
    mov     r11,[rsp+80h]
    shr     r11,38h
    mov     [rsp+60h],r11
    lea     rax,[rsp+1F0h]
    mov     rdi,rax
    mov     rsi,[rsp+58h]
    mov     rcx,[rsp+80h]
    mov     r8,rdx
    mov     rdx,[rsp+30h]
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+1F0h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+0B0h]
    cmp     r11,0
    je      L17
    jmp     L18
L0:
    lea     rcx,[rsp+250h]
    mov     [rsp+1E8h],rcx
    mov     rcx,[rsp+260h]
    mov     [rsp+1E0h],rcx
    cmp     rcx,0
    je      L19
L1:
    movzx   r15d,word ptr [rsp+268h]
    cmp     r15w,0
    je      L2
    mov     rdi,r15
    call    ryo_hr_CttzW16
    mov     rcx,rax
    mov     ecx,ecx
    mov     rdx,r15
    sub     edx,1
    and     r15d,edx
    mov     [rsp+268h],r15w
    mov     [rsp+0D8h],rcx
    mov     rdx,[rsp+258h]
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     qword ptr [rsp+1D0h],1
    mov     [rsp+1D8h],rdx
    mov     rcx,[rsp+1E8h]
    mov     rdx,[rcx+10h]
    sub     rdx,1
    mov     [rsp+210h],rdx
    mov     [rcx+10h],rdx
    mov     r15,r14
    mov     r14,r13
    mov     r13,rbx
    mov     rbx,[rsp+50h]
    mov     r11,[rsp+90h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+0A0h],r11
    jmp     L3
L2:
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFD30h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rcx,[rsp+250h]
    mov     [rsp+0D0h],rcx
    mov     qword ptr [rsp+0E8h],10h
    lea     rcx,[rcx+10h]
    mov     [rsp+250h],rcx
    mov     [rsp+0D8h],rcx
    lea     rdx,[rsp+0C0h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    sym3
    mov     rcx,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     [rsp+0E0h],rcx
    mov     [rsp+0E8h],rdx
    lea     rcx,[rsp+0E0h]
    mov     rdi,rcx
    call    sym4
    mov     rcx,rax
    mov     rdi,rcx
    call    ryo_hr_NotW16
    mov     rcx,rax
    mov     [rsp+268h],cx
    mov     rcx,[rsp+258h]
    mov     [rsp+0E8h],rcx
    add     rcx,10h
    mov     [rsp+0E0h],rcx
    mov     [rsp+258h],rcx
    jmp     L1
L3:
    mov     rcx,[rsp+1D8h]
    mov     [rsp+1E0h],rcx
    mov     rdx,[r12+28h]
    mov     rdi,r13
    mov     rsi,rbx
    mov     rax,rdx
    mov     rdx,rcx
    call    rax
    mov     [rsp+0A8h],rax
    mov     r10,[rsp+0A8h]
    mov     [rsp+170h],r10
    mov     rcx,[rsp+290h]
    and     rcx,[rsp+0A8h]
    mov     [rsp+178h],rcx
    mov     [rsp+160h],rcx
    mov     qword ptr [rsp+168h],0
L4:
    mov     rcx,[rsp+160h]
    mov     rdx,[rsp+288h]
    mov     [rsp+180h],rdx
    mov     [rsp+188h],rdx
    lea     rdx,[rdx+rcx]
    lea     rcx,[rsp+180h]
    mov     rdi,rcx
    mov     rsi,rdx
    call    image.sym59
    mov     rcx,[rsp+180h]
    mov     rdx,[rsp+188h]
    mov     [rsp+170h],rcx
    mov     [rsp+178h],rdx
    lea     rsi,[rsp+170h]
    mov     [rsp+188h],rsi
    lea     rsi,[rsp+160h]
    mov     [rsp+180h],rsi
    mov     esi,[rsp+17Ch]
    mov     [rsp+120h],rcx
    mov     [rsp+128h],edx
    mov     [rsp+12Ch],esi
    lea     rcx,[rsp+120h]
    mov     rdi,rcx
    call    sym4
    mov     rcx,rax
    cmp     cx,0
    je      L7
    jmp     L6
L5:
    mov     rdx,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    cmp     rdx,1
    je      L9
    jmp     L8
L6:
    mov     [rsp],rcx
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFD8Ch
    mov     edx,0FFFFFC60h
    call    ryo_h_CttzW16
    mov     ecx,[rsp+12Ch]
    mov     ecx,ecx
    mov     [rsp+110h],rcx
    mov     qword ptr [rsp+108h],1
    mov     rdx,[rsp+160h]
    add     rdx,rcx
    mov     rcx,[rsp+290h]
    and     rdx,rcx
    mov     [rsp+0F8h],rdx
    mov     qword ptr [rsp+0F0h],1
    jmp     L5
L7:
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFD68h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+108h]
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFD50h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L8:
    mov     rcx,[rsp+290h]
    mov     [rsp+188h],rcx
    mov     rdx,[rsp+168h]
    add     rdx,10h
    mov     [rsp+168h],rdx
    mov     [rsp+180h],rdx
    mov     rdi,[rsp+160h]
    add     rdi,rdx
    mov     [rsp+160h],rdi
    and     rdi,rcx
    mov     [rsp+160h],rdi
    jmp     L4
L9:
    mov     [rsp+188h],rsi
    mov     [rsp+148h],rsi
    mov     rcx,[rsp+288h]
    lea     rdx,[rcx+rsi]
    mov     [rsp+140h],rdx
    movzx   edx,byte ptr [rdx]
    and     edx,80h
    cmp     dl,0
    jne     L11
    lea     rdx,[rsp+130h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    sym3
    mov     rcx,[rsp+130h]
    mov     rdx,[rsp+138h]
    mov     [rsp+150h],rcx
    mov     [rsp+158h],rdx
    lea     rcx,[rsp+150h]
    mov     rdi,rcx
    call    sym4
    mov     rcx,rax
    cmp     cx,0
    je      L14
    jmp     L12
L10:
    mov     rdi,[rsp+288h]
    lea     rdi,[rdi+rdx]
    movzx   r11d,byte ptr [rdi]
    mov     r8,[rsp+0A8h]
    shr     r8,39h
    and     r8,7Fh
    mov     r9,rdx
    sub     r9,10h
    mov     rax,[rsp+290h]
    and     r9,rax
    add     r9,10h
    mov     [rdi],r8b
    mov     rax,[rsp+288h]
    lea     rax,[rax+r9]
    mov     [rax],r8b
    movzx   eax,r14w
    movzx   edi,r15w
    shl     rdi,10h
    or      rax,rdi
    movzx   edi,bp
    shl     rdi,20h
    or      rax,rdi
    movzx   edi,byte ptr [rsp+98h]
    shl     rdi,30h
    or      rax,rdi
    movzx   edi,byte ptr [rsp+0A0h]
    shl     rdi,38h
    or      rax,rdi
    mov     rdi,[rbx]
    mov     r8,[rsp+1E0h]
    add     r8,1
    imul    r8,rax
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     rdi,[rdi+r8]
    mov     r8,[rsp+288h]
    add     rdx,1
    imul    rdx,rax
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    lea     r8,[r8+rdx]
    mov     rsi,rdi
    mov     rdi,r8
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     [rsp+50h],rbx
    mov     rbx,r13
    mov     r13,r14
    mov     r14,r15
    mov     r11,[rsp+98h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+0A0h]
    mov     [rsp+88h],r11
    jmp     L0
L11:
    mov     rdx,rsi
    jmp     L10
L12:
    mov     rdi,rcx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+148h],rax
    mov     qword ptr [rsp+140h],1
L13:
    mov     r11,[rsp+140h]
    mov     rax,[rsp+148h]
    mov     rdx,rax
    jmp     L10
L14:
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFDA0h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L13
L15:
    mov     r11,[rsp+50h]
    mov     rax,[r11+18h]
    mov     [rsp+268h],rax
    mov     rcx,[rsp+298h]
    sub     rcx,rax
    mov     [rsp+298h],rcx
    mov     r11,[rsp+50h]
    mov     rax,[r11+18h]
    mov     [rsp+268h],rax
    mov     [rsp+2A0h],rax
    mov     r10,[rsp+50h]
    mov     [rsp+268h],r10
    lea     rdx,[rsp+288h]
    mov     [rsp+260h],rdx
    mov     r11,[rsp+50h]
    mov     rdx,[r11]
    mov     r11,[rsp+50h]
    mov     rsi,[r11+8]
    mov     r11,[rsp+50h]
    mov     rdi,[r11+10h]
    mov     [rsp+210h],rdi
    mov     r11,[rsp+50h]
    mov     rdi,[r11+18h]
    mov     [rsp+218h],rdi
    mov     rdi,[rsp+288h]
    mov     r8,[rsp+290h]
    mov     r11,[rsp+50h]
    mov     [r11],rdi
    mov     rdi,[rsp+268h]
    mov     [rdi+8],r8
    mov     rdi,[rsp+268h]
    mov     [rdi+10h],rcx
    mov     rcx,[rsp+268h]
    mov     [rcx+18h],rax
    mov     rax,[rsp+260h]
    mov     [rax],rdx
    mov     rax,[rsp+260h]
    mov     [rax+8],rsi
    mov     rax,[rsp+260h]
    mov     rcx,[rsp+210h]
    mov     [rax+10h],rcx
    mov     rax,[rsp+260h]
    mov     rcx,[rsp+218h]
    mov     [rax+18h],rcx
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFE10h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+290h]
    cmp     rax,0
    je      L16
    mov     r11,[rsp+270h]
    mov     rcx,[rsp+278h]
    mov     rdx,[rsp+280h]
    add     rax,1
    lea     rsi,[rsp+190h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rax
    call    qword ptr [image.fn125.slot]
    mov     rax,[rsp+190h]
    mov     rcx,[rsp+198h]
    mov     rdx,[rsp+1A0h]
    mov     rsi,[rsp+288h]
    mov     [rsp+190h],rsi
    mov     [rsp+198h],rsi
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+190h],rdx
    lea     rsi,[rsi+rdx]
    mov     [rsp+1A0h],rsi
    cmp     rcx,0
    je      L16
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rdx,rax
    call    image.sym67
L16:
    mov     rax,[rsp+1B0h]
    mov     rcx,[rsp+1B8h]
    mov     rdx,rcx
    mov     rbx,[rsp+248h]
    mov     r12,[rsp+240h]
    mov     r13,[rsp+238h]
    mov     r14,[rsp+230h]
    mov     r15,[rsp+228h]
    mov     rbp,[rsp+220h]
    add     rsp,3A8h
    ret
L17:
    movzx   eax,word ptr [rsp+1F8h]
    movzx   ecx,word ptr [rsp+1FAh]
    movzx   edx,word ptr [rsp+1FCh]
    movzx   esi,byte ptr [rsp+1FEh]
    movzx   edi,byte ptr [rsp+1FFh]
    movzx   r8d,word ptr [rsp+200h]
    movzx   r9d,word ptr [rsp+202h]
    movzx   ebx,word ptr [rsp+204h]
    movzx   r12d,byte ptr [rsp+206h]
    movzx   r13d,byte ptr [rsp+207h]
    mov     [rsp+200h],ax
    mov     [rsp+202h],cx
    mov     [rsp+204h],dx
    mov     [rsp+206h],sil
    mov     [rsp+207h],dil
    mov     [rsp+208h],r8w
    mov     [rsp+20Ah],r9w
    mov     [rsp+20Ch],bx
    mov     [rsp+20Eh],r12b
    mov     [rsp+20Fh],r13b
    mov     qword ptr [rsp+1F8h],1
    mov     byte ptr [rsp+1F7h],1
    mov     [rsp+1D0h],ax
    mov     [rsp+1D2h],cx
    mov     [rsp+1D4h],dx
    mov     [rsp+1D6h],sil
    mov     [rsp+1D7h],dil
    mov     [rsp+1D8h],r8w
    mov     [rsp+1DAh],r9w
    mov     [rsp+1DCh],bx
    mov     [rsp+1DEh],r12b
    mov     [rsp+1DFh],r13b
    mov     qword ptr [rsp+1E8h],0
    mov     [rsp+1E0h],r8w
    mov     [rsp+1E2h],r9w
    mov     [rsp+1E4h],bx
    mov     [rsp+1E6h],r12b
    mov     [rsp+1E7h],r13b
    mov     [rsp+1B0h],ax
    mov     [rsp+1B2h],cx
    mov     [rsp+1B4h],dx
    mov     [rsp+1B6h],sil
    mov     [rsp+1B7h],dil
    mov     [rsp+1B8h],r8w
    mov     [rsp+1BAh],r9w
    mov     [rsp+1BCh],bx
    mov     [rsp+1BEh],r12b
    mov     [rsp+1BFh],r13b
    jmp     L16
L18:
    mov     rax,[rsp+1F8h]
    mov     rcx,[rsp+200h]
    mov     rdx,[rsp+208h]
    mov     r10,[rsp+58h]
    mov     [rsp+1F8h],r10
    movzx   esi,word ptr [rsp+30h]
    movzx   edi,word ptr [rsp+10h]
    shl     rdi,10h
    or      rsi,rdi
    movzx   edi,word ptr [rsp+18h]
    shl     rdi,20h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+20h]
    shl     rdi,30h
    or      rsi,rdi
    movzx   edi,byte ptr [rsp+28h]
    shl     rdi,38h
    or      rsi,rdi
    mov     [rsp+200h],rsi
    movzx   edi,word ptr [rsp+80h]
    movzx   r8d,word ptr [rsp+78h]
    shl     r8,10h
    or      rdi,r8
    movzx   r8d,word ptr [rsp+70h]
    shl     r8,20h
    or      rdi,r8
    movzx   r8d,byte ptr [rsp+68h]
    shl     r8,30h
    or      rdi,r8
    movzx   r8d,byte ptr [rsp+60h]
    shl     r8,38h
    or      rdi,r8
    mov     [rsp+208h],rdi
    mov     [rsp+1E0h],rdx
    mov     r10,[rsp+58h]
    mov     [rsp+1F8h],r10
    mov     [rsp+200h],rsi
    mov     [rsp+208h],rdi
    mov     r10,[rsp+58h]
    mov     [rsp+1E8h],r10
    mov     r10,[rsp+0B0h]
    mov     [rsp+250h],r10
    mov     [rsp+258h],rax
    mov     [rsp+260h],rcx
    mov     [rsp+268h],rdx
    mov     [rsp+1E0h],rdx
    mov     r10,[rsp+58h]
    mov     [rsp+270h],r10
    mov     [rsp+278h],rsi
    mov     [rsp+280h],rdi
    mov     r10,[rsp+0B0h]
    mov     [rsp+288h],r10
    mov     [rsp+290h],rax
    mov     [rsp+298h],rcx
    mov     [rsp+2A0h],rdx
    mov     r11,[rsp+48h]
    mov     rbx,[r11]
    mov     [rsp+1D8h],rbx
    mov     [rsp+250h],rbx
    mov     [rsp+268h],rbx
    mov     [rsp+258h],rbx
    mov     [rsp+1D0h],rbx
    lea     rax,[rsp+1E0h]
    mov     rdi,rax
    mov     rsi,rbx
    call    sym3
    movzx   eax,word ptr [rsp+1E0h]
    movzx   ecx,word ptr [rsp+1E2h]
    movzx   edx,word ptr [rsp+1E4h]
    movzx   esi,byte ptr [rsp+1E6h]
    movzx   edi,byte ptr [rsp+1E7h]
    mov     r8d,[rsp+1E8h]
    movzx   r9d,word ptr [rsp+1ECh]
    movzx   r12d,byte ptr [rsp+1EEh]
    movzx   r13d,byte ptr [rsp+1EFh]
    mov     [rsp+210h],ax
    mov     [rsp+212h],cx
    mov     [rsp+214h],dx
    mov     [rsp+216h],sil
    mov     [rsp+217h],dil
    mov     [rsp+218h],r8d
    mov     [rsp+21Ch],r9w
    mov     [rsp+21Eh],r12b
    mov     [rsp+21Fh],r13b
    lea     rax,[rsp+210h]
    mov     rdi,rax
    call    sym4
    mov     [rsp+25Ch],eax
    mov     [rsp+260h],ax
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+262h]
    mov     [rsp+264h],ax
    mov     [rsp+266h],ax
    mov     r11,[rsp+48h]
    mov     rcx,[r11+18h]
    mov     [rsp+258h],rcx
    mov     [rsp+1C8h],ax
    mov     [rsp+250h],rbx
    mov     qword ptr [rsp+258h],0
    mov     [rsp+260h],rcx
    mov     rax,[rsp+1C8h]
    mov     [rsp+268h],rax
    mov     r11,[rsp+48h]
    mov     [rsp+50h],r11
    mov     r12,[rsp+38h]
    mov     rbx,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r11,[rsp+20h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+88h],r11
    jmp     L0
L19:
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFE30h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L15
    mov     rbx,rax
    jmp     L22
    mov     rbx,rax
    jmp     L22
L20:
    lea     rax,[rsp+270h]
    lea     rcx,[rsp+288h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.fn86.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+3A0h]
    mov     esi,0FFFFFC60h
    call    ryo_h_Resume
    ud2
    jmp     L21
    mov     rbx,rax
    jmp     L22
    mov     rbx,rax
    jmp     L22
    mov     rbx,rax
    jmp     L22
L21:
    call    sym9
    ud2
L22:
    jmp     L20
  ; OSR entries
    lea     r11,[L23]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L23:
    .long   L24
    .long   L25
    .long   L26
    .long   L27
    .long   L28
    .long   L29
L24:
    pop     rcx
    lea     rdx,[rsp+270h]
    lea     rsp,[rdx-450h]
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
    mov     r11,[rdx-160h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-8]
    mov     [rsp+0A0h],r11
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
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp]
    mov     [rdx-350h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-310h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-318h],r11
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r14,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+0B0h]
    jmp     L0
L25:
    pop     rcx
    lea     rdx,[rsp+270h]
    lea     rsp,[rdx-450h]
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
    mov     r11,[rdx-160h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-8]
    mov     [rsp+0A0h],r11
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
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-308h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-300h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+0B0h]
    jmp     L3
L26:
    ret
L27:
    ret
L28:
    ret
L29:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,28h
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
    lea     rax,[rsp+8]
    mov     rdi,r13
    mov     rsi,rax
    call    fn0
    mov     r14,rax
    lea     rax,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,rax
    call    qword ptr [fn4.slot]
    mov     r15,rax
    jmp     L3
L0:
    cmp     r15,0
    je      L1
    lea     rbp,[rsp+8]
    mov     rdi,rbp
    call    image.sym31
    mov     rdi,rbp
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
    add     rsp,28h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L3:
    jmp     L0
    mov     rbx,rax
    mov     rdi,rbp
    call    image.sym32
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
    call    sym5
    ud2
    mov     rbx,rax
    jmp     L6
    mov     rbx,rax
    jmp     L6
L4:
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [image.fn51.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
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
    lea     rax,[rsp+8]
    mov     rdi,r13
    mov     rsi,rax
    call    fn0
    mov     r14,rax
    lea     rax,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,rax
    call    fn2
    jmp     L3
L0:
    cmp     rax,0
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
    sub     rsp,708h
    mov     [rsp+1A0h],rbx
    mov     [rsp+198h],r12
    mov     [rsp+190h],r13
    mov     [rsp+188h],r14
    mov     qword ptr [rsp+1C8h],50910h
    lea     rax,[rsp+6C8h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     qword ptr [rsp+690h],0
    mov     qword ptr [rsp+698h],50910h
    mov     eax,1
L0:
    mov     rcx,[rsp+690h]
    mov     rdx,[rsp+698h]
    cmp     rcx,rdx
    jae     L1
    mov     rdx,rcx
    add     rdx,1
    mov     [rsp+690h],rdx
    mov     rbx,rcx
    mov     ecx,1
    jmp     L2
L1:
    mov     ecx,0
L2:
    cmp     rcx,0
    je      L3
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+1C8h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rax,r10
    mov     r10,14057B7EF767814Fh
    mov     [rsp+1C8h],r10
    mov     r12,rax
    mov     r10,14057B7EF767814Fh
    add     r12,r10
    lea     rax,[rsp+6C8h]
    mov     dword ptr [rsp+1CCh],2Ch
    mov     rcx,r12
    shr     rcx,2Ch
    lea     rdx,[rsp+38h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [image.fn111.slot]
    jmp     L4
L3:
    mov     qword ptr [rsp+0E8h],0
    mov     qword ptr [rsp+0F0h],0
    mov     dword ptr [rsp+1CCh],14h
    mov     qword ptr [rsp+1C8h],1
    mov     qword ptr [rsp+1C8h],2
    lea     rax,[rsp+10h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [image.fn117.slot]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     [rsp+5B0h],rax
    mov     [rsp+5B8h],rcx
    mov     [rsp+5C0h],rdx
    mov     [rsp+5C8h],rsi
    mov     [rsp+1B0h],rax
    mov     [rsp+1B8h],rcx
    mov     edi,[rsp+5C4h]
    mov     r8d,[rsp+5CCh]
    mov     [rsp+1C0h],edx
    mov     [rsp+1C4h],edi
    mov     [rsp+1C8h],esi
    mov     [rsp+1CCh],r8d
    mov     rdx,[rsp+1C0h]
    mov     rsi,[rsp+1C8h]
    mov     [rsp+5D0h],rax
    mov     [rsp+5D8h],rcx
    mov     [rsp+5E0h],rdx
    mov     [rsp+5E8h],rsi
    mov     [rsp+570h],rax
    mov     [rsp+578h],rcx
    mov     [rsp+580h],rdx
    mov     [rsp+588h],rsi
    jmp     L8
L4:
    mov     rax,[rsp+38h]
    cmp     rax,0
    je      L6
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+48h]
L5:
    mov     [rsp+630h],rax
    mov     [rsp+638h],rcx
    mov     [rsp+640h],rdx
    mov     esi,[rsp+63Ch]
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],ecx
    mov     [rsp+1C4h],esi
    mov     [rsp+1C8h],rdx
    mov     qword ptr [rsp+1B0h],0
    lea     rax,[rsp+1B8h]
    mov     rdi,rax
    mov     esi,0
    call    fn11
    jmp     L7
L6:
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     eax,0
    jmp     L5
L7:
    mov     rcx,[rax]
    mov     [rsp+1C8h],rcx
    add     rcx,rbx
    jb      L31
    mov     [rax],rcx
    mov     rax,r12
    jmp     L0
L8:
    mov     rax,[rsp+580h]
    add     rax,1
    cmp     rax,0
    je      L29
    mov     rcx,[rsp+578h]
    cmp     rcx,0
    jbe     L9
    mov     rdx,[rsp+570h]
    add     rax,rdx
    mov     [rsp+570h],rax
    sub     rcx,1
    mov     [rsp+578h],rcx
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+50h],1
    jmp     L10
L9:
    lea     rdi,[rsp+700h]
    mov     esi,0FFFFF950h
    lea     rdx,[image.k6704]
    mov     ecx,10h
    call    ryo_h_Const
L10:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    cmp     rax,0
    je      L15
    mov     [rsp+548h],rcx
    lea     rbx,[rsp+6C8h]
    lea     r12,[rsp+548h]
    mov     rax,[rsp+6E0h]
    cmp     rax,0
    jne     L11
    mov     ecx,0
    jmp     L12
L11:
    lea     rax,[rsp+6E8h]
    mov     rdi,rax
    mov     rsi,r12
    call    image.fn79
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,r12
    call    qword ptr [image.fn18.slot]
    cmp     rax,0
    je      L13
    jmp     L14
L12:
    cmp     rcx,0
    je      L8
    jmp     L16
L13:
    mov     ecx,0
    jmp     L12
L14:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L12
L15:
    mov     rax,[rsp+6E0h]
    mov     [rsp+100h],rax
    lea     rax,[rsp+6C8h]
    mov     rdi,rax
    call    qword ptr [image.fn4.slot]
    lea     rax,[rsp+6C8h]
    lea     rdx,[rsp+4B0h]
    mov     rdi,rdx
    mov     rsi,rax
    call    qword ptr [fn23.slot]
    jmp     L17
L16:
    mov     qword ptr [rsp+1C8h],1
    mov     rax,[rsp+0E8h]
    add     rax,1
    jb      L32
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0F0h]
    mov     rcx,[rcx]
    add     rax,rcx
    mov     [rsp+0F0h],rax
    jmp     L8
L17:
    mov     rax,[rsp+4B0h]
    mov     rcx,[rsp+4B8h]
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],rcx
    mov     rax,[rsp+4C0h]
    mov     ecx,[rsp+4C8h]
    mov     edx,[rsp+4CCh]
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],ecx
    mov     [rsp+1C4h],edx
    mov     rax,[rsp+4D0h]
    mov     [rsp+1C8h],rax
    lea     rax,[rsp+1A8h]
    mov     rdi,rax
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+108h],rax
    lea     rax,[rsp+478h]
    mov     rdi,rax
    call    qword ptr [fn25.slot]
    mov     r10,1FBD000000000h
    mov     [rsp+460h],r10
L18:
    mov     eax,[rsp+460h]
    mov     ecx,[rsp+464h]
    cmp     eax,ecx
    jae     L19
    mov     rcx,rax
    add     ecx,1
    mov     [rsp+460h],ecx
    mov     rcx,rax
    mov     eax,1
    jmp     L20
L19:
    mov     eax,0
L20:
    mov     eax,eax
    cmp     rax,0
    je      L21
    lea     rbx,[rsp+478h]
    mov     dword ptr [rsp+1CCh],138Bh
    mov     eax,ecx
    mov     [rsp+1C8h],rax
    mov     r10d,0D196E5F5h
    imul    rax,r10
    mov     [rsp+1C8h],rax
    shr     rax,2Ch
    mov     [rsp+1C8h],rax
    mov     [rsp+1C4h],eax
    imul    eax,138Bh
    mov     [rsp+1C4h],eax
    sub     ecx,eax
    mov     [rsp+3B4h],ecx
    lea     rax,[rsp+3B4h]
    mov     rcx,[image.sym2]
    mov     [rsp+390h],rax
    mov     [rsp+398h],rcx
    mov     [rsp+3A0h],rax
    mov     [rsp+3A8h],rcx
    lea     rax,[k32]
    lea     rcx,[rsp+3A0h]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rcx
    mov     rdx,rcx
    and     rdx,1
    cmp     rdx,1
    je      L23
    jmp     L22
L21:
    mov     rdx,[rsp+6E0h]
    mov     [rsp+110h],rdx
    lea     rdx,[rsp+110h]
    mov     rsi,[rsp+490h]
    mov     [rsp+118h],rsi
    lea     rsi,[rsp+118h]
    lea     rdi,[rsp+100h]
    lea     r8,[rsp+0E8h]
    lea     r9,[rsp+0F0h]
    lea     r12,[rsp+108h]
    mov     r13,[image.sym1]
    mov     r14,[image.sym3]
    mov     [rsp+120h],rdi
    mov     [rsp+128h],r13
    mov     [rsp+130h],r8
    mov     [rsp+138h],r14
    mov     [rsp+140h],r9
    mov     [rsp+148h],r14
    mov     [rsp+150h],rdx
    mov     [rsp+158h],r13
    mov     [rsp+160h],r12
    mov     [rsp+168h],r14
    mov     [rsp+170h],rsi
    mov     [rsp+178h],r13
    lea     rdx,[k47]
    lea     rsi,[rsp+120h]
    mov     rdi,rdx
    call    sym49
    jmp     L28
L22:
    lea     rdi,[rsp+700h]
    mov     esi,0FFFFF998h
    lea     rdx,[image.k3016]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L24
L23:
    shr     rcx,1
    lea     rdx,[image.k3032]
    cmp     rax,0
    je      L30
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rcx
L24:
    lea     rax,[rsp+88h]
    lea     rcx,[rsp+68h]
    mov     rsi,[rsp+98h]
    mov     rdi,[rsp+0A0h]
    mov     rdx,rdi
    mov     rdi,rcx
    mov     rcx,rax
    call    qword ptr [image.fn0.slot]
    mov     rax,[rsp+68h]
    mov     rcx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+3D8h],rax
    mov     [rsp+3E0h],rcx
    mov     [rsp+3E8h],rsi
    mov     edi,[rsp+3E4h]
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],ecx
    mov     [rsp+1C4h],edi
    mov     [rsp+1C8h],rsi
    mov     rcx,[rsp+1C0h]
    mov     [rsp+3F0h],rax
    mov     [rsp+3F8h],rcx
    mov     [rsp+400h],rsi
    mov     edi,[rsp+3FCh]
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],ecx
    mov     [rsp+1C4h],edi
    mov     [rsp+1C8h],rsi
    mov     rcx,[rsp+1C0h]
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],rcx
    mov     [rsp+0E0h],rsi
    lea     rax,[rsp+0A8h]
    lea     rcx,[rsp+0D0h]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    qword ptr [image.fn110.slot]
    mov     rax,[rsp+0A8h]
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L26
    mov     rcx,[rsp+0B0h]
    mov     rsi,[rsp+0B8h]
    mov     rdi,[rsp+0C0h]
    mov     r8,[rsp+0C8h]
L25:
    mov     [rsp+410h],rax
    mov     [rsp+418h],rcx
    mov     [rsp+420h],rsi
    mov     [rsp+428h],rdi
    mov     [rsp+430h],r8
    mov     [rsp+1A8h],rax
    mov     [rsp+1B0h],rcx
    mov     eax,[rsp+42Ch]
    mov     [rsp+1B8h],rsi
    mov     [rsp+1C0h],edi
    mov     [rsp+1C4h],eax
    mov     [rsp+1C8h],r8
    lea     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn37.slot]
    jmp     L27
L26:
    mov     rcx,[rsp+0B0h]
    mov     rsi,[rsp+0B8h]
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L25
L27:
    mov     rcx,[rax]
    mov     [rsp+1C8h],rcx
    mov     qword ptr [rsp+1C0h],1
    add     rcx,1
    jb      L33
    mov     [rax],rcx
    jmp     L18
L28:
    lea     rax,[rsp+478h]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn218.slot]
    lea     rax,[rsp+6C8h]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn219.slot]
    mov     rbx,[rsp+1A0h]
    mov     r12,[rsp+198h]
    mov     r13,[rsp+190h]
    mov     r14,[rsp+188h]
    add     rsp,708h
    ret
L29:
    lea     rax,[image.k6720]
    lea     rcx,[image.k4306]
    mov     rdi,rcx
    mov     esi,1A3h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L30:
    lea     rax,[image.k5783]
    mov     rdi,rax
    mov     esi,22Fh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
L31:
    lea     rax,[k12]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
L32:
    lea     rax,[k19]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
    mov     r12,rax
    jmp     L35
    mov     rbx,rax
    jmp     L37
    mov     rbx,rax
    jmp     L37
    mov     rbx,rax
    jmp     L37
L33:
    lea     rax,[k38]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     rbx,rax
    jmp     L37
    mov     rbx,rax
    jmp     L37
    mov     r12,rax
    jmp     L35
L34:
    lea     rax,[rsp+478h]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn218.slot]
    mov     r12,rbx
    jmp     L35
    jmp     L36
L35:
    lea     rax,[rsp+6C8h]
    mov     [rsp+1C8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn219.slot]
    mov     [rsp],r12
    lea     rdi,[rsp+700h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L36:
    call    sym54
    ud2
L37:
    jmp     L34
  ; OSR entries
    lea     r11,[L38]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L38:
    .long   L39
    .long   L40
    .long   L41
    .long   L42
    .long   L43
    .long   L44
L39:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7A0h]
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
    mov     [rdx-578h],r14
    mov     r11,[rsp+8]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-618h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+0A0h]
    jmp     L0
L40:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-790h]
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
    mov     [rdx-578h],r14
    mov     r11,[rsp]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-618h],r11
    lea     rsp,[rsp+90h]
    jmp     L8
L41:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-790h]
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
    mov     [rdx-578h],r14
    mov     r11,[rsp]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-598h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-590h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-618h],r11
    lea     rsp,[rsp+90h]
    jmp     L18
L42:
    ret
L43:
    ret
L44:
    ret

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rsi]
    mov     r11d,3
    mov     rax,rax
    xor     edx,edx
    div     r11
    cmp     rdx,0
    setne   al
    movzx   eax,al
    add     rsp,18h
    ret

fn std::arch::x86_64::__m128i::as_i8x16
    sub     rsp,18h
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     rax,rdi
    add     rsp,18h
    ret

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    cmp     rax,rcx
    sete    al
    movzx   eax,al
    add     rsp,18h
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
    lea     rax,[rsp+8]
    mov     rdi,r13
    mov     rsi,rax
    call    image.fn79
    mov     r14,rax
    lea     rax,[rsp+8]
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,rax
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
    cmp     rcx,0
    je      L5
    jmp     L4
L3:
    cmp     rax,0
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
    lea     rax,[rsp+8]
    mov     rdx,rax
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
    cmp     rax,0
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
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    cmp     rax,rcx
    jae     L0
    mov     rcx,rax
    add     rcx,1
    mov     [rdi],rcx
    mov     rcx,rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    mov     rdx,rcx
    add     rsp,18h
    ret

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    sub     rsp,18h
    mov     eax,10h
    add     rsp,18h
    ret

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,60h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,0
    je      L7
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[image.k1552]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+38h]
    mov     r14,[rsp+40h]
    lea     rdx,[rsp+18h]
    mov     rdi,rdx
    mov     rsi,r13
    mov     edx,0
    mov     rcx,rax
    mov     r8,r14
    movzx   edx,dl
    call    image.sym57
    mov     rax,[rsp+18h]
    cmp     rax,0
    jne     L10
    mov     r15,[rsp+20h]
    mov     eax,[rsp+28h]
    movzx   edx,word ptr [rsp+2Ch]
    movzx   esi,byte ptr [rsp+2Eh]
    movzx   edi,byte ptr [rsp+2Fh]
    cmp     r14,0
    je      L1
    mov     r8,r15
L0:
    cmp     r8,r13
    setb    r8b
    lea     r9,[image.k2736]
    test    r8b,r8b
    jne     L9
    mov     r8d,eax
    movzx   r14d,dx
    shl     r14,20h
    or      r8,r14
    movzx   r14d,sil
    shl     r14,30h
    or      r8,r14
    movzx   r14d,dil
    shl     r14,38h
    or      r14,r8
    cmp     r13,0
    ja      L2
    jmp     L5
L1:
    mov     r8,0FFFFFFFFFFFFFFFFh
    jmp     L0
L2:
    mov     qword ptr [rsp+40h],1
    mov     qword ptr [rsp+38h],1
    lea     rax,[image.k1568]
    cmp     r14,0
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
    mov     [rsp+40h],r13
    mov     [rsp],r14
    mov     [rsp+8],r12
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF88h
    mov     ecx,0FFFFFFC0h
    call    ryo_h_Memcpy
    lea     rdx,[image.k1672]
    mov     [rsp+40h],rdx
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
    lea     rdi,[rsp+48h]
    mov     rdx,rcx
    call    image.sym42
    mov     rcx,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdi,[rsp+58h]
L8:
    mov     [rbx],rcx
    mov     [rbx+8],rsi
    mov     [rbx+10h],rdi
    mov     rax,rbx
    add     rsp,60h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    lea     rcx,[image.k5302]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym63
    ud2
L10:
    mov     rcx,[rsp+20h]
    mov     esi,[rsp+28h]
    movzx   edi,word ptr [rsp+2Ch]
    movzx   r8d,byte ptr [rsp+2Eh]
    movzx   r9d,byte ptr [rsp+2Fh]
    mov     esi,esi
    movzx   edi,di
    shl     rdi,20h
    or      rsi,rdi
    movzx   r8d,r8b
    shl     r8,30h
    or      rsi,r8
    movzx   r9d,r9b
    shl     r9,38h
    or      rsi,r9
    mov     rdi,rcx
    call    image.sym58
    ud2
L11:
    lea     rcx,[image.k4515]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L12:
    lea     rax,[image.k4108]
    mov     rdi,rax
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
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
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
    cmp     rbx,0
    sete    al
    movzx   eax,al
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L0:
    lea     rax,[k0]
    lea     rcx,[k2]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
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
    lea     rax,[k0]
    cmp     rdx,0
    jne     L0
    mov     ecx,1
    jmp     L1
L0:
    mov     ecx,0
L1:
    test    cl,cl
    je      L6
L2:
    test    cl,cl
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
    cmp     rdi,0
    je      L8
    jmp     L2
L7:
    cmp     rsi,0
    jne     L3
L8:
    lea     rcx,[image.k4515]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
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
    cmp     r15,0
    jne     L0
    mov     ebp,1
    jmp     L1
L0:
    cmp     r13,0
    sete    al
    mov     rbp,rax
L1:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L8
    mov     rax,r14
    sub     rax,1
    and     rax,rbx
    cmp     rax,0
    je      L6
    jmp     L12
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,r14
    sub     rax,1
    and     rax,r12
    cmp     rax,0
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
    cmp     rbx,0
    je      L11
    jmp     L2
L7:
    test    bpl,bpl
    jne     L3
    cmp     r12,0
    je      L11
    jmp     L3
L8:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym39
    ud2
L9:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym39
    ud2
L10:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym64
    ud2
    jmp     L14
    jmp     L14
L11:
    lea     rax,[k3]
    mov     rdi,rax
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

