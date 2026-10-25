fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+18h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rsi
    mov     r8,[rdi+30h]
    and     r8,0FFh
    shl     r8,38h
    mov     rdi,[rdi+38h]
    mov     rbx,r8
    or      rbx,rdi
    mov     r12,rsi
    xor     r12,rbx
    mov     [rsp+28h],r12
    lea     r13,[rsp+10h]
    mov     r14,rax
    add     r14,rdx
    mov     [rsp+10h],r14
    mov     r15,rcx
    add     r15,r12
    mov     [rsp+18h],r15
    mov     rdi,rdx
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rsp+20h],rax
    mov     rbp,rax
    xor     rbp,r14
    mov     [rsp+20h],rbp
    mov     rdi,r12
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rsp+28h],rax
    mov     r12,rax
    xor     r12,r15
    mov     [rsp+28h],r12
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rsp+10h],rax
    add     r15,rbp
    mov     [rsp+18h],r15
    mov     r14,rax
    add     r14,r12
    mov     [rsp+10h],r14
    mov     rdi,rbp
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rsp+20h],rax
    xor     rax,r15
    mov     [rsp+20h],rax
    mov     rdi,r12
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rsp+28h],rax
    xor     rax,r14
    mov     [rsp+28h],rax
    mov     rdi,r15
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rsp+18h],rax
    xor     r14,rbx
    mov     [rsp+10h],r14
    xor     rax,0FFh
    mov     [rsp+18h],rax
    mov     rdi,r13
    call    qword ptr [fn1.slot]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+20h]
    xor     rax,rcx
    mov     rcx,[rsp+18h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    sub     rsp,118h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+18h],rdx
    mov     r11,[rsp+28h]
    mov     rax,[r11+30h]
    add     rax,[rsp+18h]
    mov     r11,[rsp+28h]
    mov     [r11+30h],rax
    mov     r11,[rsp+28h]
    mov     rax,[r11+40h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     r14d,0
    jmp     L14
L1:
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+0A0h],r14
    cmp     r14,[rsp+18h]
    jae     L2
    mov     r15,r14
    jmp     L3
L2:
    mov     r15,[rsp+18h]
L3:
    mov     r11d,3
    cmp     r11,r15
    jb      L5
    jmp     L4
L4:
    mov     ebp,0
    mov     r13d,0
    jmp     L8
L5:
    mov     dword ptr [rsp+80h],0
    lea     rbp,[rsp+80h]
    lea     r11,[image.k3192]
    mov     [rsp+10h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L30
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L32
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L31
    cmp     rbp,0
    je      L32
    mov     r11,[rsp+20h]
    cmp     r11,rbp
    jae     L6
    mov     rax,rbp
    sub     rax,[rsp+20h]
    jmp     L7
L6:
    mov     rax,[rsp+20h]
    sub     rax,rbp
L7:
    cmp     rax,4
    jb      L32
    mov     rdi,rbp
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,[rsp+80h]
    mov     eax,eax
    mov     ebp,4
    mov     r13,rax
L8:
    mov     rax,rbp
    add     rax,1
    cmp     rax,r15
    jae     L11
    mov     word ptr [rsp+74h],0
    mov     r11,[rsp+20h]
    lea     r12,[r11+rbp]
    lea     rbx,[rsp+74h]
    lea     r11,[image.k3216]
    mov     [rsp+30h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L34
    cmp     r12,0
    je      L36
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L35
    cmp     rbx,0
    je      L36
    cmp     r12,rbx
    jae     L9
    mov     rax,rbx
    sub     rax,r12
    jmp     L10
L9:
    mov     rax,r12
    sub     rax,rbx
L10:
    cmp     rax,2
    jb      L36
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   eax,word ptr [rsp+74h]
    movzx   eax,ax
    mov     rcx,rbp
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      r13,rax
    add     rbp,2
L11:
    cmp     rbp,r15
    jae     L12
    lea     rax,[image.k3320]
    cmp     rbp,[rsp+18h]
    jae     L38
    mov     byte ptr [rsp+75h],1
    mov     r11,[rsp+20h]
    lea     rcx,[r11+rbp]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    rbp,8
    mov     rdi,rcx
    mov     rsi,rbp
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r13,rcx
L12:
    mov     r11,[rsp+28h]
    mov     rcx,[r11+40h]
    mov     [rsp+0A0h],rcx
    imul    rcx,8
    mov     rdi,r13
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    mov     r11,[rsp+28h]
    mov     rdx,[r11+38h]
    or      rdx,rcx
    mov     r11,[rsp+28h]
    mov     [r11+38h],rdx
    mov     r11,[rsp+18h]
    cmp     r11,r14
    jae     L13
    mov     r11,[rsp+28h]
    mov     rcx,[r11+40h]
    add     rcx,[rsp+18h]
    mov     r11,[rsp+28h]
    mov     [r11+40h],rcx
    jmp     L29
L13:
    mov     r11,[rsp+28h]
    mov     rcx,[r11+18h]
    xor     rcx,rdx
    mov     r11,[rsp+28h]
    mov     [r11+18h],rcx
    mov     rdi,[rsp+28h]
    call    fn1
    mov     r11,[rsp+28h]
    mov     rcx,[r11+38h]
    mov     r11,[rsp+28h]
    mov     rdx,[r11]
    xor     rdx,rcx
    mov     r11,[rsp+28h]
    mov     [r11],rdx
    mov     r11,[rsp+28h]
    mov     qword ptr [r11+40h],0
L14:
    mov     rcx,[rsp+18h]
    sub     rcx,r14
    mov     rdx,rcx
    and     rdx,7
    mov     rbx,rcx
    mov     [rsp+40h],rdx
    mov     r11,[rsp+20h]
    mov     [rsp+58h],r11
    mov     r15,[rsp+18h]
    mov     r11,[rsp+28h]
    mov     [rsp+38h],r11
L15:
    mov     [rsp+0A0h],r14
    mov     rcx,rbx
    sub     rcx,[rsp+40h]
    cmp     r14,rcx
    jae     L19
    mov     qword ptr [rsp+0A0h],0
    mov     r11,[rsp+58h]
    lea     rbp,[r11+r14]
    lea     r12,[rsp+0A0h]
    lea     r11,[k4]
    mov     [rsp+48h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L39
    cmp     rbp,0
    je      L41
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L40
    cmp     r12,0
    je      L41
    cmp     rbp,r12
    jae     L16
    mov     rcx,r12
    sub     rcx,rbp
    jmp     L17
L16:
    mov     rcx,rbp
    sub     rcx,r12
L17:
    cmp     rcx,8
    jb      L41
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+0A0h]
    mov     r11,[rsp+38h]
    mov     rcx,[r11+18h]
    xor     rcx,r12
    mov     r11,[rsp+38h]
    mov     [r11+18h],rcx
    mov     r10,[rsp+38h]
    mov     [rsp+0A0h],r10
    mov     rdi,[rsp+38h]
    call    fn1
    mov     rcx,[rsp+38h]
    mov     rdx,r14
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+58h]
    mov     r8,r15
L18:
    mov     r9,[rcx]
    xor     r9,r12
    mov     [rcx],r9
    add     rdx,8
    mov     r14,rdx
    mov     [rsp+40h],rsi
    mov     [rsp+58h],rdi
    mov     r15,r8
    mov     [rsp+38h],rcx
    jmp     L15
L19:
    mov     r11d,3
    cmp     r11,[rsp+40h]
    jb      L21
    jmp     L20
L20:
    mov     ebx,0
    mov     r12d,0
    jmp     L24
L21:
    mov     dword ptr [rsp+90h],0
    mov     r11,[rsp+58h]
    lea     rbx,[r11+r14]
    lea     r12,[rsp+90h]
    lea     r11,[image.k3192]
    mov     [rsp+50h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L43
    cmp     rbx,0
    je      L45
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L44
    cmp     r12,0
    je      L45
    cmp     rbx,r12
    jae     L22
    mov     rcx,r12
    sub     rcx,rbx
    jmp     L23
L22:
    mov     rcx,rbx
    sub     rcx,r12
L23:
    cmp     rcx,4
    jb      L45
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+90h]
    mov     ecx,ecx
    mov     ebx,4
    mov     r12,rcx
L24:
    mov     rcx,rbx
    add     rcx,1
    cmp     rcx,[rsp+40h]
    jae     L27
    mov     word ptr [rsp+84h],0
    mov     rcx,r14
    add     rcx,rbx
    mov     r11,[rsp+58h]
    lea     rbp,[r11+rcx]
    lea     r13,[rsp+84h]
    lea     r11,[image.k3216]
    mov     [rsp+60h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L47
    cmp     rbp,0
    je      L49
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L48
    cmp     r13,0
    je      L49
    cmp     rbp,r13
    jae     L25
    mov     rcx,r13
    sub     rcx,rbp
    jmp     L26
L25:
    mov     rcx,rbp
    sub     rcx,r13
L26:
    cmp     rcx,2
    jb      L49
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+84h]
    movzx   ecx,cx
    mov     rdx,rbx
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r12,rcx
    add     rbx,2
L27:
    cmp     rbx,[rsp+40h]
    jae     L28
    add     r14,rbx
    lea     rcx,[image.k3320]
    cmp     r14,r15
    jae     L51
    mov     byte ptr [rsp+85h],1
    mov     r11,[rsp+58h]
    lea     rdx,[r11+r14]
    movzx   edx,byte ptr [rdx]
    movzx   edx,dl
    imul    rbx,8
    mov     rdi,rdx
    mov     rsi,rbx
    call    ryo_hr_ShlW64
    mov     rdx,rax
    or      r12,rdx
L28:
    mov     r11,[rsp+38h]
    mov     [r11+38h],r12
    mov     r11,[rsp+38h]
    mov     r10,[rsp+40h]
    mov     [r11+40h],r10
L29:
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,118h
    ret
L30:
    lea     rdx,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    image.sym39
    ud2
L31:
    lea     rdx,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L33
    jmp     L33
L32:
    lea     rdx,[image.k4515]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym63
    ud2
L33:
    call    image.sym30
    ud2
L34:
    lea     rdx,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    image.sym39
    ud2
L35:
    lea     rdx,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L37
    jmp     L37
L36:
    lea     rdx,[image.k4515]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    image.sym63
    ud2
L37:
    call    image.sym30
    ud2
L38:
    lea     rdx,[image.k6416]
    mov     rdi,rdx
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L39:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
L40:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L42
    jmp     L42
L41:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym63
    ud2
L42:
    call    image.sym30
    ud2
L43:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
L44:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L46
    jmp     L46
L45:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym63
    ud2
L46:
    call    image.sym30
    ud2
L47:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
L48:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L50
    jmp     L50
L49:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym63
    ud2
L50:
    call    image.sym30
    ud2
L51:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym63
    ud2
  ; OSR entries
    lea     r11,[L52]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L52:
    .long   L53
    .long   L54
    .long   L55
L53:
    ret
L54:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-150h]
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
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-70h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0D8h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L15
L55:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-150h]
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
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-70h],r11
    mov     rcx,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L18

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    mov     r12,rax
    add     r12,rcx
    mov     [rbx],r12
    mov     rax,[rbx+8]
    mov     r13,[rbx+18h]
    mov     r14,rax
    add     r14,r13
    mov     [rbx+8],r14
    mov     rdi,rcx
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r12
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r14
    mov     [rbx+18h],r13
    mov     rdi,r12
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    add     r14,r15
    mov     [rbx+8],r14
    mov     r12,rax
    add     r12,r13
    mov     [rbx],r12
    mov     rdi,r15
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    xor     rax,r14
    mov     [rbx+10h],rax
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    xor     rax,r12
    mov     [rbx+18h],rax
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    mov     r12,rax
    add     r12,rcx
    mov     [rbx],r12
    mov     rax,[rbx+8]
    mov     r13,[rbx+18h]
    mov     r14,rax
    add     r14,r13
    mov     [rbx+8],r14
    mov     rdi,rcx
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r12
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r14
    mov     [rbx+18h],r13
    mov     rdi,r12
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    add     r14,r15
    mov     [rbx+8],r14
    mov     r12,rax
    add     r12,r13
    mov     [rbx],r12
    mov     rdi,r15
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r14
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r12
    mov     [rbx+18h],r13
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    add     r12,r15
    mov     [rbx],r12
    mov     r14,rax
    add     r14,r13
    mov     [rbx+8],r14
    mov     rdi,r15
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r12
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r14
    mov     [rbx+18h],r13
    mov     rdi,r12
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    add     r14,r15
    mov     [rbx+8],r14
    mov     r12,rax
    add     r12,r13
    mov     [rbx],r12
    mov     rdi,r15
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r14
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r12
    mov     [rbx+18h],r13
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    add     r12,r15
    mov     [rbx],r12
    mov     r14,rax
    add     r14,r13
    mov     [rbx+8],r14
    mov     rdi,r15
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     r15,rax
    xor     r15,r12
    mov     [rbx+10h],r15
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     r13,rax
    xor     r13,r14
    mov     [rbx+18h],r13
    mov     rdi,r12
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    add     r14,r15
    mov     [rbx+8],r14
    mov     r12,rax
    add     r12,r13
    mov     [rbx],r12
    mov     rdi,r15
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    xor     rax,r14
    mov     [rbx+10h],rax
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    xor     rax,r12
    mov     [rbx+18h],rax
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
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
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+18h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rsi
    mov     r8,[rdi+30h]
    and     r8,0FFh
    shl     r8,38h
    mov     rdi,[rdi+38h]
    mov     rbx,r8
    or      rbx,rdi
    mov     r12,rsi
    xor     r12,rbx
    mov     [rsp+28h],r12
    lea     r13,[rsp+10h]
    mov     r14,rax
    add     r14,rdx
    mov     [rsp+10h],r14
    mov     r15,rcx
    add     r15,r12
    mov     [rsp+18h],r15
    mov     rdi,rdx
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rsp+20h],rax
    mov     rbp,rax
    xor     rbp,r14
    mov     [rsp+20h],rbp
    mov     rdi,r12
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rsp+28h],rax
    mov     r12,rax
    xor     r12,r15
    mov     [rsp+28h],r12
    mov     rdi,r14
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rsp+10h],rax
    add     r15,rbp
    mov     [rsp+18h],r15
    mov     r14,rax
    add     r14,r12
    mov     [rsp+10h],r14
    mov     rdi,rbp
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rsp+20h],rax
    xor     rax,r15
    mov     [rsp+20h],rax
    mov     rdi,r12
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rsp+28h],rax
    xor     rax,r14
    mov     [rsp+28h],rax
    mov     rdi,r15
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rsp+18h],rax
    xor     r14,rbx
    mov     [rsp+10h],r14
    xor     rax,0FFh
    mov     [rsp+18h],rax
    mov     rdi,r13
    call    image.fn209
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+20h]
    xor     rax,rcx
    mov     rcx,[rsp+18h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    sub     rsp,148h
    mov     [rsp+130h],rbx
    mov     rbx,rdi
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     [rsp+100h],rax
    mov     [rsp+108h],rcx
    mov     qword ptr [rsp+110h],0
    mov     qword ptr [rsp+0E0h],0
    mov     qword ptr [rsp+0E8h],0
    mov     qword ptr [rsp+0F0h],0
    mov     qword ptr [rsp+0F8h],0
    mov     qword ptr [rsp+118h],0
    mov     qword ptr [rsp+120h],0
    mov     qword ptr [rsp+110h],0
    mov     rdx,rax
    mov     r10,736F6D6570736575h
    xor     rdx,r10
    mov     [rsp+0E0h],rdx
    mov     rdx,rcx
    mov     r10,646F72616E646F6Dh
    xor     rdx,r10
    mov     [rsp+0F0h],rdx
    mov     r10,6C7967656E657261h
    xor     rax,r10
    mov     [rsp+0E8h],rax
    mov     r10,7465646279746573h
    xor     rcx,r10
    mov     [rsp+0F8h],rcx
    mov     qword ptr [rsp+120h],0
    lea     rdi,[rsp+140h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFFA0h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+140h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFF58h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+140h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFF10h
    mov     ecx,48h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+140h]
    mov     esi,0FFFFFEC0h
    mov     edx,0
    mov     ecx,0FFFFFEC8h
    mov     r8d,48h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+130h]
    add     rsp,148h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
    sub     rsp,118h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rbx,rsi
    lea     rax,[rsp+68h]
    mov     rsi,rdi
    mov     rdi,rax
    call    fn0
    lea     r11,[rsp+68h]
    mov     [rsp+10h],r11
    mov     r13,[rbx+8]
    mov     rbx,[rbx+10h]
    mov     rax,[rsp+98h]
    add     rax,rbx
    mov     [rsp+98h],rax
    mov     rax,[rsp+0A8h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     r14d,0
    jmp     L3
L1:
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+40h],r14
    mov     rdi,rbx
    mov     rsi,r14
    call    qword ptr [image.fn239.slot]
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,0
    mov     rcx,rax
    call    image.fn158
    mov     r15,[rsp+0A8h]
    mov     [rsp+40h],r15
    mov     rcx,r15
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,[rsp+0A0h]
    or      rcx,rax
    mov     [rsp+0A0h],rcx
    cmp     rbx,r14
    jae     L2
    add     r15,rbx
    mov     [rsp+0A8h],r15
    jmp     L11
L2:
    mov     rax,[rsp+80h]
    xor     rax,rcx
    mov     [rsp+80h],rax
    mov     rdi,[rsp+10h]
    call    image.fn208
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+68h]
    xor     rcx,rax
    mov     [rsp+68h],rcx
    mov     qword ptr [rsp+0A8h],0
L3:
    mov     r15,rbx
    sub     r15,r14
    mov     r11,r15
    and     r11,7
    mov     [rsp+18h],r11
    mov     [rsp+28h],r14
L4:
    mov     r10,[rsp+28h]
    mov     [rsp+40h],r10
    mov     rax,r15
    sub     rax,[rsp+18h]
    mov     r11,[rsp+28h]
    cmp     r11,rax
    jae     L10
    mov     qword ptr [rsp+40h],0
    mov     r10,[rsp+28h]
    lea     r12,[r13+r10]
    lea     rbp,[rsp+40h]
    lea     r11,[image.k6632]
    mov     [rsp+20h],r11
    mov     rdi,r12
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L7
    jmp     L24
L5:
    mov     rdi,rbp
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L8
    jmp     L24
L6:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    test    al,al
    je      L24
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r14,[rsp+40h]
    mov     rax,[rsp+80h]
    xor     rax,r14
    mov     [rsp+80h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+40h],r10
    mov     rdi,[rsp+10h]
    call    image.fn208
    jmp     L9
L7:
    cmp     r12,0
    je      L24
    jmp     L5
L8:
    cmp     rbp,0
    je      L24
    jmp     L6
L9:
    mov     rax,[rsp+68h]
    xor     rax,r14
    mov     [rsp+68h],rax
    mov     rax,[rsp+28h]
    add     rax,8
    mov     [rsp+28h],rax
    jmp     L4
L10:
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+18h]
    call    image.fn158
    mov     [rsp+0A0h],rax
    mov     r10,[rsp+18h]
    mov     [rsp+0A8h],r10
L11:
    mov     byte ptr [rsp+5Fh],0FFh
    lea     rbx,[rsp+5Fh]
    mov     rax,[rsp+98h]
    add     rax,1
    mov     [rsp+98h],rax
    mov     rax,[rsp+0A8h]
    cmp     rax,0
    je      L12
    jmp     L13
L12:
    mov     r12d,0
    jmp     L15
L13:
    mov     r12d,8
    sub     r12,rax
    mov     [rsp+50h],r12
    mov     edi,1
    mov     rsi,r12
    call    qword ptr [image.fn239.slot]
    mov     rdi,rbx
    mov     esi,1
    mov     edx,0
    mov     rcx,rax
    call    image.fn158
    mov     r13,[rsp+0A8h]
    mov     [rsp+50h],r13
    mov     rcx,r13
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,[rsp+0A0h]
    or      rcx,rax
    mov     [rsp+0A0h],rcx
    mov     r11d,1
    cmp     r11,r12
    jae     L14
    add     r13,1
    mov     [rsp+0A8h],r13
    jmp     L23
L14:
    mov     rax,[rsp+80h]
    xor     rax,rcx
    mov     [rsp+80h],rax
    mov     rdi,[rsp+10h]
    call    image.fn208
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+68h]
    xor     rcx,rax
    mov     [rsp+68h],rcx
    mov     qword ptr [rsp+0A8h],0
L15:
    mov     r13d,1
    sub     r13,r12
    mov     r11,r13
    and     r11,7
    mov     [rsp+38h],r11
L16:
    mov     [rsp+50h],r12
    mov     rax,r13
    sub     rax,[rsp+38h]
    cmp     r12,rax
    jae     L22
    mov     qword ptr [rsp+50h],0
    lea     r15,[rbx+r12]
    lea     rbp,[rsp+50h]
    lea     r11,[image.k6632]
    mov     [rsp+30h],r11
    mov     rdi,r15
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L19
    jmp     L26
L17:
    mov     rdi,rbp
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L20
    jmp     L26
L18:
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    test    al,al
    je      L26
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r14,[rsp+50h]
    mov     rax,[rsp+80h]
    xor     rax,r14
    mov     [rsp+80h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+50h],r10
    mov     rdi,[rsp+10h]
    call    image.fn208
    jmp     L21
L19:
    cmp     r15,0
    je      L26
    jmp     L17
L20:
    cmp     rbp,0
    je      L26
    jmp     L18
L21:
    mov     rax,[rsp+68h]
    xor     rax,r14
    mov     [rsp+68h],rax
    mov     rax,r12
    add     rax,8
    mov     r12,rax
    jmp     L16
L22:
    mov     rdi,rbx
    mov     esi,1
    mov     rdx,r12
    mov     rcx,[rsp+38h]
    call    image.fn158
    mov     [rsp+0A0h],rax
    mov     r10,[rsp+38h]
    mov     [rsp+0A8h],r10
L23:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    image.fn198
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,118h
    ret
    jmp     L25
    jmp     L25
    jmp     L25
L24:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+20h]
    movzx   edx,dl
    call    image.sym63
    ud2
L25:
    call    image.sym30
    ud2
    jmp     L27
    jmp     L27
    jmp     L27
L26:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    image.sym63
    ud2
L27:
    call    image.sym30
    ud2
    jmp     L28
    jmp     L28
L28:
    mov     [rsp],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L29]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L29:
    .long   L30
L30:
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    sub     rsp,118h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rbx,rsi
    lea     rax,[rsp+68h]
    mov     rsi,rdi
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    lea     r11,[rsp+68h]
    mov     [rsp+18h],r11
    mov     rax,[rbx]
    mov     [rsp+60h],rax
    lea     r11,[rsp+60h]
    mov     [rsp+10h],r11
    mov     rax,[rsp+98h]
    add     rax,8
    mov     [rsp+98h],rax
    mov     rax,[rsp+0A8h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     r13d,0
    jmp     L8
L1:
    mov     r13d,8
    sub     r13,rax
    mov     [rsp+50h],r13
    mov     edi,8
    mov     rsi,r13
    call    qword ptr [image.fn239.slot]
    mov     r14,rax
    mov     r11d,3
    cmp     r11,r14
    jb      L3
    jmp     L2
L2:
    mov     r15d,0
    mov     ebp,0
    jmp     L4
L3:
    mov     dword ptr [rsp+40h],0
    lea     r15,[rsp+40h]
    lea     rax,[image.k3192]
    mov     rdi,[rsp+10h]
    mov     rsi,r15
    mov     edx,1
    mov     ecx,1
    mov     r8d,4
    mov     r9,rax
    call    image.fn165
    mov     rdi,r15
    mov     rsi,[rsp+10h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,[rsp+40h]
    mov     eax,eax
    mov     r15d,4
    mov     rbp,rax
L4:
    mov     rax,r15
    add     rax,1
    cmp     rax,r14
    jae     L5
    mov     word ptr [rsp+34h],0
    mov     r11,[rsp+10h]
    lea     rbx,[r11+r15]
    lea     r12,[rsp+34h]
    lea     rax,[image.k3216]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,1
    mov     ecx,1
    mov     r8d,2
    mov     r9,rax
    call    image.fn165
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   eax,word ptr [rsp+34h]
    movzx   eax,ax
    mov     rcx,r15
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      rbp,rax
    add     r15,2
L5:
    cmp     r15,r14
    jae     L6
    lea     rax,[image.k3320]
    mov     rdi,r15
    mov     esi,8
    mov     rdx,rax
    call    qword ptr [image.fn176.slot]
    cmp     r15,8
    setb    al
    mov     [rsp+35h],al
    mov     r11,[rsp+10h]
    lea     rax,[r11+r15]
    movzx   eax,byte ptr [rax]
    movzx   eax,al
    imul    r15,8
    mov     rdi,rax
    mov     rsi,r15
    call    ryo_hr_ShlW64
    or      rbp,rax
L6:
    mov     rbx,[rsp+0A8h]
    mov     [rsp+50h],rbx
    mov     rax,rbx
    imul    rax,8
    mov     rdi,rbp
    mov     rsi,rax
    call    ryo_hr_ShlW64
    mov     rcx,[rsp+0A0h]
    or      rcx,rax
    mov     [rsp+0A0h],rcx
    mov     r11d,8
    cmp     r11,r13
    jae     L7
    add     rbx,8
    mov     [rsp+0A8h],rbx
    jmp     L16
L7:
    mov     rax,[rsp+80h]
    xor     rax,rcx
    mov     [rsp+80h],rax
    mov     rdi,[rsp+18h]
    call    image.fn208
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+68h]
    xor     rcx,rax
    mov     [rsp+68h],rcx
    mov     qword ptr [rsp+0A8h],0
L8:
    mov     ebx,8
    sub     rbx,r13
    mov     r12,rbx
    and     r12,7
L9:
    mov     [rsp+50h],r13
    mov     rax,rbx
    sub     rax,r12
    cmp     r13,rax
    jae     L15
    mov     qword ptr [rsp+50h],0
    mov     r11,[rsp+10h]
    lea     r14,[r11+r13]
    lea     r15,[rsp+50h]
    lea     r11,[image.k6632]
    mov     [rsp+20h],r11
    mov     rdi,r14
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L12
    jmp     L17
L10:
    mov     rdi,r15
    mov     esi,1
    call    image.fn112
    test    al,al
    jne     L13
    jmp     L17
L11:
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,1
    mov     ecx,8
    call    qword ptr [image.fn171.slot]
    test    al,al
    je      L17
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbp,[rsp+50h]
    mov     rax,[rsp+80h]
    xor     rax,rbp
    mov     [rsp+80h],rax
    mov     r10,[rsp+18h]
    mov     [rsp+50h],r10
    mov     rdi,[rsp+18h]
    call    image.fn208
    jmp     L14
L12:
    cmp     r14,0
    je      L17
    jmp     L10
L13:
    cmp     r15,0
    je      L17
    jmp     L11
L14:
    mov     rax,[rsp+68h]
    xor     rax,rbp
    mov     [rsp+68h],rax
    mov     rax,r13
    add     rax,8
    mov     r13,rax
    jmp     L9
L15:
    mov     rdi,[rsp+10h]
    mov     esi,8
    mov     rdx,r13
    mov     rcx,r12
    call    qword ptr [image.fn158.slot]
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],r12
L16:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [image.fn198.slot]
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,118h
    ret
    jmp     L18
    jmp     L18
    jmp     L18
L17:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+20h]
    movzx   edx,dl
    call    image.sym63
    ud2
L18:
    call    image.sym30
    ud2
    jmp     L19
    jmp     L19
L19:
    mov     [rsp],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L20]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L20:
    .long   L21
L21:
    ret

fn <usize as std::cmp::Ord>::min
    sub     rsp,18h
    cmp     rsi,rdi
    jae     L0
    jmp     L1
L0:
    mov     rsi,rdi
L1:
    mov     rax,rsi
    add     rsp,18h
    ret
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
    .long   L4
    .long   L5
L3:
    ret
L4:
    ret
L5:
    ret

fn core::core_arch::simd::Simd::<i8, 16>::splat
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+2Fh],sil
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
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

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     rsp,18h
    mov     rax,[sym0]
    mov     [rdi],rsi
    mov     [rdi+8],rax
    mov     rax,rdi
    add     rsp,18h
    ret

fn core::hash::sip::u8to64_le
    sub     rsp,0B8h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r11d,3
    cmp     r11,r14
    jb      L1
    jmp     L0
L0:
    mov     r15d,0
    mov     ebp,0
    jmp     L4
L1:
    mov     dword ptr [rsp+40h],0
    mov     r11,[rsp+18h]
    lea     r15,[r11+r13]
    lea     rbp,[rsp+40h]
    lea     r11,[k0]
    mov     [rsp+10h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    cmp     r15,0
    je      L11
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L10
    cmp     rbp,0
    je      L11
    cmp     r15,rbp
    jae     L2
    mov     rax,rbp
    sub     rax,r15
    jmp     L3
L2:
    mov     rax,r15
    sub     rax,rbp
L3:
    cmp     rax,4
    jb      L11
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,[rsp+40h]
    mov     eax,eax
    mov     r15d,4
    mov     rbp,rax
L4:
    mov     rax,r15
    add     rax,1
    cmp     rax,r14
    jae     L7
    mov     word ptr [rsp+34h],0
    mov     rax,r13
    add     rax,r15
    mov     r11,[rsp+18h]
    lea     rbx,[r11+rax]
    lea     r12,[rsp+34h]
    lea     r11,[k2]
    mov     [rsp+28h],r11
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L13
    cmp     rbx,0
    je      L15
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L14
    cmp     r12,0
    je      L15
    cmp     rbx,r12
    jae     L5
    mov     rax,r12
    sub     rax,rbx
    jmp     L6
L5:
    mov     rax,rbx
    sub     rax,r12
L6:
    cmp     rax,2
    jb      L15
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   eax,word ptr [rsp+34h]
    movzx   eax,ax
    mov     rcx,r15
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      rbp,rax
    add     r15,2
L7:
    cmp     r15,r14
    jae     L8
    add     r13,r15
    lea     rax,[k4]
    cmp     r13,[rsp+20h]
    jae     L17
    mov     byte ptr [rsp+35h],1
    mov     r11,[rsp+18h]
    lea     rcx,[r11+r13]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    r15,8
    mov     rdi,rcx
    mov     rsi,r15
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rbp,rcx
L8:
    mov     rax,rbp
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,0B8h
    ret
L9:
    lea     rcx,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym39
    ud2
L10:
    lea     rcx,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L12
    jmp     L12
L11:
    lea     rcx,[image.k4515]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym63
    ud2
L12:
    call    image.sym30
    ud2
L13:
    lea     rcx,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym39
    ud2
L14:
    lea     rcx,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym39
    ud2
    jmp     L16
    jmp     L16
L15:
    lea     rcx,[image.k4515]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+28h]
    movzx   edx,dl
    call    image.sym63
    ud2
L16:
    call    image.sym30
    ud2
L17:
    lea     rcx,[image.k6416]
    mov     rdi,rcx
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
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
L19:
    ret
L20:
    ret
L21:
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
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rdx
    mul     rcx
    mov     rdx,rax
    mov     rax,r11
    jb      L2
    cmp     rdi,rsi
    jae     L0
    mov     rax,rsi
    sub     rax,rdi
    jmp     L1
L0:
    sub     rdi,rsi
    mov     rax,rdi
L1:
    cmp     rdx,rax
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
    sub     rsp,0E8h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     [rsp+68h],rax
    mov     [rsp+60h],rax
    mov     [rsp+70h],rax
    mov     rcx,[rbx]
    mov     rdx,[rbx+8]
    add     rdx,1
    lea     rsi,[rsp+50h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rdx
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L7
L0:
    mov     rax,[rsp+70h]
    cmp     rax,0
    je      L2
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    fn2
    jmp     L8
L1:
    mov     rsi,rcx
    lea     rsi,[rsi-10h]
    jmp     L10
L2:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,0E8h
    ret
L3:
    test    cl,cl
    jne     L4
    jmp     L5
L4:
    mov     r12,r14
    jmp     L0
L5:
    mov     rcx,[r14]
    sub     rcx,r13
    mov     rdi,rcx
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     rcx,rax
    mov     rdi,r14
    mov     rsi,rcx
    call    image.fn146
    lea     r13,[r13-10h]
    mov     rdi,r13
    call    image.sym22
    mov     r12,r14
    jmp     L0
L6:
    mov     rcx,[rbx+18h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     r8,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp+68h],r8
    mov     [rsp+70h],rcx
    mov     r12,rbx
    jmp     L0
L7:
    jmp     L6
L8:
    mov     rcx,[rsp+70h]
    sub     rcx,1
    mov     [rsp+70h],rcx
    cmp     rax,0
    je      L2
    mov     rcx,rax
    mov     rdx,r12
    jmp     L1
L9:
    mov     rax,[rax]
    mov     rdi,rax
    mov     esi,3
    call    ryo_hr_RemUW64
    cmp     rax,0
    setne   al
    mov     rcx,rax
    mov     r13,rbx
    mov     r14,r12
    jmp     L3
L10:
    mov     rax,rsi
    mov     rbx,rcx
    mov     r12,rdx
    jmp     L9
    jmp     L12
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L12
    mov     rcx,rax
    mov     rax,rcx
L12:
    jmp     L11
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
L14:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-8]
    mov     [rsp],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r12,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L15:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-98h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     rcx,[rsp]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+10h]
    jmp     L1
L16:
    ret
L17:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    movzx   r11d,byte ptr [rdx-0B1h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L3
L18:
    ret
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
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L9
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
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     rsi,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L10

fn hashbrown::raw::FullBucketsIndices::next_impl
    sub     rsp,0C8h
    mov     [rsp+40h],rbx
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,0C8h
    ret
L1:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rbx]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+28h],10h
    lea     rax,[rax+10h]
    mov     [rbx],rax
    mov     [rsp+18h],rax
    lea     rcx,[rsp+50h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym1
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
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
    mov     [rdx-80h],rbx
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
    lea     rsp,[rsp+30h]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    sub     rsp,0D8h
    mov     [rsp+40h],rbx
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
    lea     rdx,[rsp+50h]
    mov     rdi,rdx
    mov     rsi,rax
    call    sym0
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,0D8h
    ret
L6:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L10

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,168h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    mov     [rsp+120h],rcx
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
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,168h
    ret
L3:
    mov     [rsp+30h],rbx
    lea     rax,[rsp+0B0h]
    mov     rdi,rax
    mov     rsi,rbx
    call    sym0
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    sym3
    jmp     L7
L4:
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC8h
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
    mov     r12,[rsp+120h]
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
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
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
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L0
L16:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L1
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-190h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+28h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-148h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+8]
    lea     rsp,[rsp+30h]
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
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+38h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-130h],r11
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L5
L23:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+38h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-130h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L6
L24:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L8
L25:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1A0h]
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
    mov     r11,[rdx-0D8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     rbp,[rsp]
    mov     rbx,[rsp+8]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L9

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,0D8h
    mov     [rsp+40h],rbx
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
    lea     rdx,[rsp+50h]
    mov     rdi,rdx
    mov     rsi,rax
    call    sym0
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,0D8h
    ret
L6:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
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
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B8h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     rax,[rsp+20h]
    lea     rcx,[k0]
    mov     rdi,rbx
    mov     rdx,rax
    call    fn1
    mov     r12,rdx
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L0:
    .long   L1
    .long   L2
    .long   L6
L1:
    mov     eax,0
    jmp     L3
L2:
    mov     rax,[rbx]
    mov     [rsp+20h],rax
    mov     ecx,0
    sub     rcx,r12
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+28h],rax
    jmp     L5
L3:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    jmp     L3
L5:
    jmp     L4
    jmp     L7
L6:
    ud2
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L10:
    ret
L11:
    ret
L12:
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
    sub     rsp,118h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     esi,[rdx+10h]
    movzx   edi,word ptr [rdx+14h]
    movzx   r8d,byte ptr [rdx+16h]
    movzx   r9d,byte ptr [rdx+17h]
    mov     r13d,[rdx+18h]
    movzx   r14d,word ptr [rdx+1Ch]
    movzx   r15d,byte ptr [rdx+1Eh]
    movzx   edx,byte ptr [rdx+1Fh]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rcx
    mov     [rsp+98h],esi
    mov     [rsp+9Ch],di
    mov     [rsp+9Eh],r8b
    mov     [rsp+9Fh],r9b
    mov     [rsp+0A0h],r13d
    mov     [rsp+0A4h],r14w
    mov     [rsp+0A6h],r15b
    mov     [rsp+0A7h],dl
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
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF3Ch
    mov     edx,0FFFFFEF0h
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
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF18h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+28h]
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
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
    mov     edi,[rsp+98h]
    movzx   r8d,word ptr [rsp+9Ch]
    movzx   r9d,byte ptr [rsp+9Eh]
    movzx   r12d,byte ptr [rsp+9Fh]
    mov     r13d,[rsp+0A0h]
    movzx   r14d,word ptr [rsp+0A4h]
    movzx   r15d,byte ptr [rsp+0A6h]
    movzx   ebp,byte ptr [rsp+0A7h]
    jmp     L9
L7:
    jmp     L6
L8:
    mov     [rcx-20h],rax
    mov     [rcx-18h],rsi
    mov     [rcx-10h],edi
    mov     [rcx-0Ch],r8w
    mov     [rcx-0Ah],r9b
    mov     [rcx-9],r12b
    mov     [rcx-8],r13d
    mov     [rcx-4],r14w
    mov     [rcx-2],r15b
    mov     [rcx-1],bpl
    mov     rdx,[rbx+18h]
    add     rdx,1
    mov     [rbx+18h],rdx
    mov     rax,rcx
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,118h
    ret
L9:
    jmp     L8
    mov     rbx,rax
    jmp     L11
L10:
    mov     [rsp],rbx
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
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
    sub     rsp,0F8h
    mov     [rsp+0E0h],rbx
    mov     [rsp+0D0h],r12
    mov     [rsp+0C0h],r13
    mov     [rsp+0B0h],r14
    mov     [rsp+0A0h],r15
    mov     [rsp+90h],rbp
    mov     rax,[rdi]
    mov     rcx,[rsi]
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,20h
    add     r11,rcx
    mov     [rsp+10h],r11
    jmp     L2
L0:
    mov     rax,rcx
    mov     rbx,[rsp+0E0h]
    mov     r12,[rsp+0D0h]
    mov     r13,[rsp+0C0h]
    mov     r14,[rsp+0B0h]
    mov     r15,[rsp+0A0h]
    mov     rbp,[rsp+90h]
    add     rsp,0F8h
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rdx,[rax]
    lea     rsi,[rsp+48h]
    mov     rdi,rsi
    mov     rsi,rdx
    call    image.fn215
    lea     r12,[rsp+48h]
    mov     r11,[rsp+10h]
    mov     rdx,[r11-18h]
    mov     r11,[rsp+10h]
    mov     rsi,[r11-10h]
    mov     rdi,r12
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    image.fn197
    mov     byte ptr [rsp+1Fh],0FFh
    lea     rdx,[rsp+1Fh]
    mov     rdi,r12
    mov     rsi,rdx
    mov     edx,1
    call    image.fn197
    mov     rdx,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdi,[rsp+58h]
    mov     r8,[rsp+60h]
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdi
    mov     [rsp+38h],r8
    mov     r9,[rsp+78h]
    and     r9,0FFh
    shl     r9,38h
    mov     r12,[rsp+80h]
    or      r12,r9
    mov     r13,r8
    xor     r13,r12
    mov     [rsp+38h],r13
    lea     r14,[rsp+20h]
    mov     r15,rdx
    add     r15,rdi
    mov     [rsp+20h],r15
    mov     rbp,rsi
    add     rbp,r13
    mov     [rsp+28h],rbp
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+30h],rdx
    mov     rbx,rdx
    xor     rbx,r15
    mov     [rsp+30h],rbx
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+38h],rdx
    mov     r13,rdx
    xor     r13,rbp
    mov     [rsp+38h],r13
    mov     rdi,r15
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+20h],rdx
    add     rbp,rbx
    mov     [rsp+28h],rbp
    mov     r15,rdx
    add     r15,r13
    mov     [rsp+20h],r15
    mov     rdi,rbx
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+30h],rdx
    xor     rdx,rbp
    mov     [rsp+30h],rdx
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+38h],rdx
    xor     rdx,r15
    mov     [rsp+38h],rdx
    mov     rdi,rbp
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+28h],rdx
    xor     r15,r12
    mov     [rsp+20h],r15
    xor     rdx,0FFh
    mov     [rsp+28h],rdx
    mov     rdi,r14
    call    image.fn209
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
    jmp     L5
    jmp     L5
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF10h
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx]
    sub     rax,r12
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [image.fn146.slot]
    lea     r12,[r12-10h]
    jmp     L1
L0:
    mov     rdi,r12
    call    sym1
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     rax,[rsp+20h]
    lea     rcx,[k0]
    mov     rdi,rbx
    mov     rdx,rax
    call    fn1
    mov     r12,rdx
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L0:
    .long   L1
    .long   L2
    .long   L6
L1:
    mov     eax,0
    jmp     L3
L2:
    mov     rax,[rbx]
    mov     [rsp+20h],rax
    mov     ecx,0
    sub     rcx,r12
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+28h],rax
    jmp     L5
L3:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    jmp     L3
L5:
    jmp     L4
    jmp     L7
L6:
    ud2
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L10:
    ret
L11:
    ret
L12:
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     rax,[rsp+20h]
    lea     rcx,[k0]
    mov     rdi,rbx
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    mov     r12,rdx
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L0:
    .long   L1
    .long   L2
    .long   L6
L1:
    mov     eax,0
    jmp     L3
L2:
    mov     rax,[rbx]
    mov     [rsp+20h],rax
    mov     ecx,0
    sub     rcx,r12
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+28h],rax
    jmp     L5
L3:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    jmp     L3
L5:
    jmp     L4
    jmp     L7
L6:
    ud2
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L10:
    ret
L11:
    ret
L12:
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
    sub     rsp,108h
    mov     [rsp+0F0h],rbx
    mov     [rsp+0E0h],r12
    mov     [rsp+0D0h],r13
    mov     [rsp+0C0h],r14
    mov     [rsp+0B0h],r15
    mov     [rsp+0A0h],rbp
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
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF00h
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
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF48h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+48h]
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF30h
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
    mov     rbx,[rsp+0F0h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D0h]
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0B0h]
    mov     rbp,[rsp+0A0h]
    add     rsp,108h
    ret
L9:
    jmp     L8
    jmp     L11
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
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
    sub     rsp,108h
    mov     [rsp+0F0h],rbx
    mov     [rsp+0E0h],r12
    mov     [rsp+0D0h],r13
    mov     [rsp+0C0h],r14
    mov     [rsp+0B0h],r15
    mov     [rsp+0A0h],rbp
    mov     rax,[rdi]
    mov     rcx,[rsi]
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,10h
    add     r11,rcx
    mov     [rsp+10h],r11
    jmp     L2
L0:
    mov     rax,rcx
    mov     rbx,[rsp+0F0h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D0h]
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0B0h]
    mov     rbp,[rsp+0A0h]
    add     rsp,108h
    ret
L1:
    jmp     L4
L2:
    jmp     L1
L3:
    mov     rdx,[rax]
    lea     rsi,[rsp+58h]
    mov     rdi,rsi
    mov     rsi,rdx
    call    image.fn215
    lea     rdx,[rsp+58h]
    mov     r11,[rsp+10h]
    mov     rsi,[r11-10h]
    mov     [rsp+20h],rsi
    lea     rsi,[rsp+20h]
    mov     rdi,rdx
    mov     edx,8
    call    qword ptr [image.fn197.slot]
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdi,[rsp+68h]
    mov     r8,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rdi
    mov     [rsp+48h],r8
    mov     r9,[rsp+88h]
    and     r9,0FFh
    shl     r9,38h
    mov     r12,[rsp+90h]
    or      r12,r9
    mov     r13,r8
    xor     r13,r12
    mov     [rsp+48h],r13
    lea     r14,[rsp+30h]
    mov     r15,rdx
    add     r15,rdi
    mov     [rsp+30h],r15
    mov     rbp,rsi
    add     rbp,r13
    mov     [rsp+38h],rbp
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+40h],rdx
    mov     rbx,rdx
    xor     rbx,r15
    mov     [rsp+40h],rbx
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+48h],rdx
    mov     r13,rdx
    xor     r13,rbp
    mov     [rsp+48h],r13
    mov     rdi,r15
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+30h],rdx
    add     rbp,rbx
    mov     [rsp+38h],rbp
    mov     r15,rdx
    add     r15,r13
    mov     [rsp+30h],r15
    mov     rdi,rbx
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+40h],rdx
    xor     rdx,rbp
    mov     [rsp+40h],rdx
    mov     rdi,r13
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+48h],rdx
    xor     rdx,r15
    mov     [rsp+48h],rdx
    mov     rdi,rbp
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     rdx,rax
    mov     [rsp+38h],rdx
    xor     r15,r12
    mov     [rsp+30h],r15
    xor     rdx,0FFh
    mov     [rsp+38h],rdx
    mov     rdi,r14
    call    image.fn209
    mov     rdx,[rsp+30h]
    mov     rsi,[rsp+40h]
    xor     rdx,rsi
    mov     rsi,[rsp+38h]
    xor     rdx,rsi
    mov     rsi,[rsp+48h]
    mov     rcx,rdx
    xor     rcx,rsi
    jmp     L0
L4:
    jmp     L3
    jmp     L5
    jmp     L5
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
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
    sub     rsp,0A8h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rax,[rbx+18h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L2
    mov     rax,[rbx]
    mov     [rsp+40h],rax
    mov     [rsp+38h],rax
    mov     [rsp+48h],rax
    mov     rcx,[rbx]
    mov     rdx,[rbx+8]
    add     rdx,1
    lea     rsi,[rsp+28h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rdx
    mov     rdx,rax
    call    qword ptr [fn0.slot]
    jmp     L3
L0:
    mov     rax,[rsp+48h]
    cmp     rax,0
    je      L2
    lea     rax,[rsp+28h]
    mov     rdi,rax
    call    fn1
    mov     rcx,[rsp+48h]
    sub     rcx,1
    mov     [rsp+48h],rcx
    cmp     rax,0
    je      L2
    jmp     L4
L1:
    lea     rcx,[rcx-20h]
    jmp     L6
L2:
    mov     rbx,[rsp+20h]
    add     rsp,0A8h
    ret
L3:
    mov     rcx,[rbx+18h]
    mov     rdx,[rsp+28h]
    mov     rsi,[rsp+30h]
    mov     rdi,[rsp+38h]
    mov     r8,[rsp+40h]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdi
    mov     [rsp+40h],r8
    mov     [rsp+48h],rcx
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
    mov     [rsp+10h],rax
    mov     rdi,rbx
    call    image.sym32
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
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
    lea     rsp,[rdx-0B0h]
    mov     [rdx-80h],rbx
    lea     rsp,[rsp+10h]
    jmp     L0
L9:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-80h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     rcx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L1
L10:
    ret
L11:
    ret
L12:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L5
L13:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     [rdx-80h],rbx
    mov     rcx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L6

fn hashbrown::raw::RawTableInner::erase
    sub     rsp,0E8h
    mov     [rsp+0D0h],rbx
    mov     [rsp+0C0h],r12
    mov     [rsp+0B0h],r13
    mov     [rsp+0A0h],r14
    mov     [rsp+90h],r15
    mov     [rsp+80h],rbp
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
    mov     rbx,[rsp+0D0h]
    mov     r12,[rsp+0C0h]
    mov     r13,[rsp+0B0h]
    mov     r14,[rsp+0A0h]
    mov     r15,[rsp+90h]
    mov     rbp,[rsp+80h]
    add     rsp,0E8h
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
    sub     rsp,168h
    mov     [rsp+0E0h],rbx
    mov     [rsp+0D0h],r12
    mov     [rsp+0C0h],r13
    mov     [rsp+0B0h],r14
    mov     [rsp+0A0h],r15
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
    lea     rcx,[rsp+0F0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    sym0
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     rsi,r13
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0F0h]
    mov     rcx,[rsp+0F8h]
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
    mov     rbx,[rsp+0E0h]
    mov     r12,[rsp+0D0h]
    mov     r13,[rsp+0C0h]
    mov     r14,[rsp+0B0h]
    mov     r15,[rsp+0A0h]
    mov     rbp,[rsp+90h]
    add     rsp,168h
    ret
L4:
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+68h],0
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    sym1
    mov     rax,[rsp+0F0h]
    mov     r15,[rsp+0F8h]
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
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEE0h
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
    lea     rsp,[rdx-1D0h]
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
    mov     r11,[rdx-0C0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-8]
    mov     [rsp+68h],r11
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     [rdx-0C0h],r15
    mov     [rdx-0D0h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-110h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-118h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L0
L9:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-1E0h]
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
    mov     r11,[rdx-0C0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-8]
    mov     [rsp+70h],r11
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     [rdx-0C0h],r15
    mov     [rdx-0D0h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-110h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-118h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-148h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+80h]
    jmp     L1
L10:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-1E0h]
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
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     [rdx-0C0h],r15
    mov     [rdx-0D0h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-110h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-118h],r11
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
    sub     rsp,108h
    mov     [rsp+90h],rbx
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
    mov     rbx,[rsp+90h]
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
    mov     [rdx-70h],rbx
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
    mov     [rdx-70h],rbx
    mov     rcx,[rsp]
    mov     rbx,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+20h]
    jmp     L4
L15:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
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
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    add     rsp,78h
    ret
L1:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFF90h
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
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+28h]
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
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
    sub     rsp,3B8h
    mov     [rsp+250h],rbx
    mov     [rsp+240h],r12
    mov     [rsp+230h],r13
    mov     [rsp+220h],r14
    mov     [rsp+210h],r15
    mov     [rsp+200h],rbp
    mov     [rsp+48h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+40h],rcx
    mov     [rsp+38h],r8
    mov     r11,[rsp+3C8h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+3C0h]
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
    mov     r11,[rsp+78h]
    shr     r11,10h
    mov     [rsp+70h],r11
    mov     r11,[rsp+78h]
    shr     r11,20h
    mov     [rsp+68h],r11
    mov     r11,[rsp+78h]
    shr     r11,30h
    mov     [rsp+60h],r11
    mov     r11,[rsp+78h]
    shr     r11,38h
    mov     [rsp+58h],r11
    lea     rax,[rsp+1D0h]
    mov     rdi,rax
    mov     rsi,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8,rdx
    mov     rdx,[rsp+30h]
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+1D0h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+98h]
    cmp     r11,0
    je      L18
    jmp     L19
L0:
    lea     rcx,[rsp+260h]
    mov     [rsp+1C8h],rcx
    mov     rcx,[rsp+270h]
    mov     [rsp+1C0h],rcx
    cmp     rcx,0
    je      L20
L1:
    movzx   r12d,word ptr [rsp+278h]
    cmp     r12w,0
    je      L3
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     rcx,rax
    mov     ecx,ecx
    mov     rdx,r12
    sub     edx,1
    and     r12d,edx
    mov     [rsp+278h],r12w
    mov     [rsp+0D8h],rcx
    mov     rdx,[rsp+268h]
    mov     r12,rdx
    add     r12,rcx
    mov     [rsp+0D0h],r12
    mov     qword ptr [rsp+1B0h],1
    mov     [rsp+1B8h],r12
    mov     rcx,[rsp+1C8h]
    mov     rdx,[rcx+10h]
    sub     rdx,1
    mov     [rsp+1F0h],rdx
    mov     [rcx+10h],rdx
    mov     edi,1
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     rcx,rax
    mov     r10,rcx
    lea     r11,[L2]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L2:
    .long   L16
    .long   L4
    .long   L21
L3:
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFD20h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rcx,[rsp+260h]
    mov     [rsp+0D0h],rcx
    mov     qword ptr [rsp+0E8h],10h
    lea     rcx,[rcx+10h]
    mov     [rsp+260h],rcx
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
    mov     [rsp+278h],cx
    mov     rcx,[rsp+268h]
    mov     [rsp+0E8h],rcx
    add     rcx,10h
    mov     [rsp+0E0h],rcx
    mov     [rsp+268h],rcx
    jmp     L1
L4:
    mov     [rsp+1C0h],r12
    mov     rcx,[rbx+28h]
    mov     rdi,r13
    mov     rsi,[rsp+50h]
    mov     rdx,r12
    mov     rax,rcx
    call    rax
    mov     r12,rax
    mov     [rsp+170h],r12
    mov     rcx,[rsp+2A0h]
    and     rcx,r12
    mov     [rsp+178h],rcx
    mov     [rsp+160h],rcx
    mov     qword ptr [rsp+168h],0
L5:
    mov     rcx,[rsp+160h]
    mov     rdx,[rsp+298h]
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
    je      L8
    jmp     L7
L6:
    mov     rdx,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    cmp     rdx,1
    je      L10
    jmp     L9
L7:
    mov     [rsp],rcx
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFD7Ch
    mov     edx,0FFFFFC50h
    call    ryo_h_CttzW16
    mov     ecx,[rsp+12Ch]
    mov     ecx,ecx
    mov     [rsp+110h],rcx
    mov     qword ptr [rsp+108h],1
    mov     rdx,[rsp+160h]
    add     rdx,rcx
    mov     rcx,[rsp+2A0h]
    and     rdx,rcx
    mov     [rsp+0F8h],rdx
    mov     qword ptr [rsp+0F0h],1
    jmp     L6
L8:
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFD58h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r11,[rsp+108h]
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFD40h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L6
L9:
    mov     rcx,[rsp+2A0h]
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
    jmp     L5
L10:
    mov     [rsp+188h],rsi
    mov     [rsp+148h],rsi
    mov     rcx,[rsp+298h]
    lea     rdx,[rcx+rsi]
    mov     [rsp+140h],rdx
    movzx   edx,byte ptr [rdx]
    and     edx,80h
    cmp     dl,0
    jne     L12
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
    je      L15
    jmp     L13
L11:
    mov     rdi,[rsp+298h]
    lea     rdi,[rdi+rdx]
    movzx   r11d,byte ptr [rdi]
    mov     r8,r12
    shr     r8,39h
    and     r8,7Fh
    mov     r9,rdx
    sub     r9,10h
    mov     rax,[rsp+2A0h]
    and     r9,rax
    add     r9,10h
    mov     [rdi],r8b
    mov     rax,[rsp+298h]
    lea     rax,[rax+r9]
    mov     [rax],r8b
    movzx   eax,r14w
    movzx   edi,bp
    shl     rdi,10h
    or      rax,rdi
    movzx   edi,r15w
    shl     rdi,20h
    or      rax,rdi
    movzx   edi,byte ptr [rsp+90h]
    shl     rdi,30h
    or      rax,rdi
    movzx   edi,byte ptr [rsp+88h]
    shl     rdi,38h
    or      rax,rdi
    mov     r11,[rsp+50h]
    mov     rdi,[r11]
    mov     r8,[rsp+1C0h]
    add     r8,1
    imul    r8,rax
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     rdi,[rdi+r8]
    mov     r8,[rsp+298h]
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
    jmp     L0
L12:
    mov     rdx,rsi
    jmp     L11
L13:
    mov     rdi,rcx
    call    ryo_hr_CttzW16
    mov     eax,eax
    mov     [rsp+148h],rax
    mov     qword ptr [rsp+140h],1
L14:
    mov     r11,[rsp+140h]
    mov     rax,[rsp+148h]
    mov     rdx,rax
    jmp     L11
L15:
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFD90h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L14
L16:
    mov     r11,[rsp+50h]
    mov     rax,[r11+18h]
    mov     [rsp+278h],rax
    mov     rcx,[rsp+2A8h]
    sub     rcx,rax
    mov     [rsp+2A8h],rcx
    mov     r11,[rsp+50h]
    mov     rax,[r11+18h]
    mov     [rsp+278h],rax
    mov     [rsp+2B0h],rax
    mov     r10,[rsp+50h]
    mov     [rsp+278h],r10
    lea     rax,[rsp+298h]
    mov     [rsp+270h],rax
    mov     r11,[rsp+50h]
    mov     rbx,[r11]
    mov     r11,[rsp+50h]
    mov     r12,[r11+8]
    mov     r11,[rsp+50h]
    movzx   eax,word ptr [r11+10h]
    mov     r11,[rsp+50h]
    movzx   ecx,word ptr [r11+12h]
    mov     r11,[rsp+50h]
    movzx   edx,word ptr [r11+14h]
    mov     r11,[rsp+50h]
    movzx   esi,byte ptr [r11+16h]
    mov     r11,[rsp+50h]
    movzx   edi,byte ptr [r11+17h]
    mov     r11,[rsp+50h]
    movzx   r8d,word ptr [r11+18h]
    mov     r11,[rsp+50h]
    movzx   r9d,word ptr [r11+1Ah]
    mov     r11,[rsp+50h]
    movzx   r13d,word ptr [r11+1Ch]
    mov     r11,[rsp+50h]
    movzx   r14d,byte ptr [r11+1Eh]
    mov     r11,[rsp+50h]
    movzx   r15d,byte ptr [r11+1Fh]
    mov     [rsp+1F0h],ax
    mov     [rsp+1F2h],cx
    mov     [rsp+1F4h],dx
    mov     [rsp+1F6h],sil
    mov     [rsp+1F7h],dil
    mov     [rsp+1F8h],r8w
    mov     [rsp+1FAh],r9w
    mov     [rsp+1FCh],r13w
    mov     [rsp+1FEh],r14b
    mov     [rsp+1FFh],r15b
    mov     qword ptr [rsp],20h
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFC50h
    call    ryo_h_Memcpy
    mov     rax,[rsp+270h]
    movzx   ecx,word ptr [rsp+1F0h]
    movzx   edx,word ptr [rsp+1F2h]
    movzx   esi,word ptr [rsp+1F4h]
    movzx   edi,byte ptr [rsp+1F6h]
    movzx   r8d,byte ptr [rsp+1F7h]
    movzx   r9d,word ptr [rsp+1F8h]
    movzx   r13d,word ptr [rsp+1FAh]
    movzx   r14d,word ptr [rsp+1FCh]
    movzx   r15d,byte ptr [rsp+1FEh]
    movzx   ebp,byte ptr [rsp+1FFh]
    mov     [rax],rbx
    mov     [rax+8],r12
    mov     [rax+10h],cx
    mov     [rax+12h],dx
    mov     [rax+14h],si
    mov     [rax+16h],dil
    mov     [rax+17h],r8b
    mov     [rax+18h],r9w
    mov     [rax+1Ah],r13w
    mov     [rax+1Ch],r14w
    mov     [rax+1Eh],r15b
    mov     [rax+1Fh],bpl
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFDE0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+2A0h]
    cmp     rax,0
    je      L17
    mov     r11,[rsp+280h]
    mov     rcx,[rsp+288h]
    mov     rdx,[rsp+290h]
    add     rax,1
    lea     rsi,[rsp+0A0h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rax
    call    qword ptr [image.fn125.slot]
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+298h]
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rsi
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+0A0h],rdx
    lea     rsi,[rsi+rdx]
    mov     [rsp+0B0h],rsi
    cmp     rcx,0
    je      L17
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rdx,rax
    call    image.sym67
L17:
    mov     rax,[rsp+190h]
    mov     rcx,[rsp+198h]
    mov     rdx,rcx
    mov     rbx,[rsp+250h]
    mov     r12,[rsp+240h]
    mov     r13,[rsp+230h]
    mov     r14,[rsp+220h]
    mov     r15,[rsp+210h]
    mov     rbp,[rsp+200h]
    add     rsp,3B8h
    ret
L18:
    movzx   eax,word ptr [rsp+1D8h]
    movzx   ecx,word ptr [rsp+1DAh]
    movzx   edx,word ptr [rsp+1DCh]
    movzx   esi,byte ptr [rsp+1DEh]
    movzx   edi,byte ptr [rsp+1DFh]
    movzx   r8d,word ptr [rsp+1E0h]
    movzx   r9d,word ptr [rsp+1E2h]
    movzx   ebx,word ptr [rsp+1E4h]
    movzx   r12d,byte ptr [rsp+1E6h]
    movzx   r13d,byte ptr [rsp+1E7h]
    mov     [rsp+1E0h],ax
    mov     [rsp+1E2h],cx
    mov     [rsp+1E4h],dx
    mov     [rsp+1E6h],sil
    mov     [rsp+1E7h],dil
    mov     [rsp+1E8h],r8w
    mov     [rsp+1EAh],r9w
    mov     [rsp+1ECh],bx
    mov     [rsp+1EEh],r12b
    mov     [rsp+1EFh],r13b
    mov     qword ptr [rsp+1D8h],1
    mov     byte ptr [rsp+1D7h],1
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
    mov     qword ptr [rsp+1C8h],0
    mov     [rsp+1C0h],r8w
    mov     [rsp+1C2h],r9w
    mov     [rsp+1C4h],bx
    mov     [rsp+1C6h],r12b
    mov     [rsp+1C7h],r13b
    mov     [rsp+190h],ax
    mov     [rsp+192h],cx
    mov     [rsp+194h],dx
    mov     [rsp+196h],sil
    mov     [rsp+197h],dil
    mov     [rsp+198h],r8w
    mov     [rsp+19Ah],r9w
    mov     [rsp+19Ch],bx
    mov     [rsp+19Eh],r12b
    mov     [rsp+19Fh],r13b
    jmp     L17
L19:
    mov     rax,[rsp+1D8h]
    mov     rcx,[rsp+1E0h]
    mov     rdx,[rsp+1E8h]
    mov     rsi,[rsp+80h]
    shr     rsi,10h
    mov     rdi,[rsp+80h]
    shr     rdi,20h
    mov     r8,[rsp+80h]
    shr     r8,30h
    mov     r9,[rsp+80h]
    shr     r9,38h
    mov     r10,[rsp+80h]
    mov     [rsp+1D8h],r10w
    mov     [rsp+1DAh],si
    mov     [rsp+1DCh],di
    mov     [rsp+1DEh],r8b
    mov     [rsp+1DFh],r9b
    mov     r10,[rsp+30h]
    mov     [rsp+1E0h],r10w
    mov     r10,[rsp+10h]
    mov     [rsp+1E2h],r10w
    mov     r10,[rsp+18h]
    mov     [rsp+1E4h],r10w
    mov     r10,[rsp+20h]
    mov     [rsp+1E6h],r10b
    mov     r10,[rsp+28h]
    mov     [rsp+1E7h],r10b
    mov     r10,[rsp+78h]
    mov     [rsp+1E8h],r10w
    mov     r10,[rsp+70h]
    mov     [rsp+1EAh],r10w
    mov     r10,[rsp+68h]
    mov     [rsp+1ECh],r10w
    mov     r10,[rsp+60h]
    mov     [rsp+1EEh],r10b
    mov     r10,[rsp+58h]
    mov     [rsp+1EFh],r10b
    mov     rsi,[rsp+1D8h]
    mov     rdi,[rsp+1E0h]
    mov     r8,[rsp+1E8h]
    mov     [rsp+1C0h],rdx
    mov     [rsp+1D8h],rsi
    mov     [rsp+1E0h],rdi
    mov     [rsp+1E8h],r8
    mov     [rsp+1C8h],rsi
    mov     r10,[rsp+98h]
    mov     [rsp+260h],r10
    mov     [rsp+268h],rax
    mov     [rsp+270h],rcx
    mov     [rsp+278h],rdx
    mov     [rsp+1C0h],rdx
    mov     [rsp+280h],rsi
    mov     [rsp+288h],rdi
    mov     [rsp+290h],r8
    mov     r10,[rsp+98h]
    mov     [rsp+298h],r10
    mov     [rsp+2A0h],rax
    mov     [rsp+2A8h],rcx
    mov     [rsp+2B0h],rdx
    mov     r11,[rsp+48h]
    mov     rbx,[r11]
    mov     [rsp+1B8h],rbx
    mov     [rsp+260h],rbx
    mov     [rsp+278h],rbx
    mov     [rsp+268h],rbx
    mov     [rsp+1B0h],rbx
    lea     rax,[rsp+1C0h]
    mov     rdi,rax
    mov     rsi,rbx
    call    sym3
    movzx   eax,word ptr [rsp+1C0h]
    movzx   ecx,word ptr [rsp+1C2h]
    movzx   edx,word ptr [rsp+1C4h]
    movzx   esi,byte ptr [rsp+1C6h]
    movzx   edi,byte ptr [rsp+1C7h]
    movzx   r8d,word ptr [rsp+1C8h]
    movzx   r9d,word ptr [rsp+1CAh]
    movzx   r12d,word ptr [rsp+1CCh]
    movzx   r13d,byte ptr [rsp+1CEh]
    movzx   r14d,byte ptr [rsp+1CFh]
    mov     [rsp+1F0h],ax
    mov     [rsp+1F2h],cx
    mov     [rsp+1F4h],dx
    mov     [rsp+1F6h],sil
    mov     [rsp+1F7h],dil
    mov     [rsp+1F8h],r8w
    mov     [rsp+1FAh],r9w
    mov     [rsp+1FCh],r12w
    mov     [rsp+1FEh],r13b
    mov     [rsp+1FFh],r14b
    lea     rax,[rsp+1F0h]
    mov     rdi,rax
    call    sym4
    mov     [rsp+26Ch],eax
    mov     [rsp+270h],ax
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+272h]
    mov     [rsp+274h],ax
    mov     [rsp+276h],ax
    mov     r11,[rsp+48h]
    mov     rcx,[r11+18h]
    mov     [rsp+268h],rcx
    mov     [rsp+1A8h],ax
    mov     rax,[rsp+1A8h]
    mov     [rsp+260h],rbx
    mov     qword ptr [rsp+268h],0
    mov     [rsp+270h],rcx
    mov     [rsp+278h],rax
    mov     r11,[rsp+48h]
    mov     [rsp+50h],r11
    mov     rbx,[rsp+38h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     rbp,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     r11,[rsp+20h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+88h],r11
    jmp     L0
L20:
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFE00h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L16
L21:
    ud2
    mov     rbx,rax
    jmp     L24
    mov     rbx,rax
    jmp     L24
L22:
    lea     rax,[rsp+280h]
    lea     rcx,[rsp+298h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.fn86.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+3B0h]
    mov     esi,0FFFFFC50h
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
    ret
L27:
    pop     rcx
    lea     rdx,[rsp+260h]
    lea     rsp,[rdx-440h]
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
    mov     r11,[rdx-170h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-160h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-8]
    mov     [rsp+80h],r11
    mov     [rdx-160h],rbx
    mov     [rdx-170h],r12
    mov     [rdx-180h],r13
    mov     [rdx-190h],r14
    mov     [rdx-1A0h],r15
    mov     [rdx-1B0h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-218h],r11
    mov     r11,[rsp]
    mov     [rdx-360h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-320h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-328h],r11
    mov     rbx,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     rbp,[rsp+20h]
    mov     r15,[rsp+28h]
    lea     rsp,[rsp+90h]
    jmp     L0
L28:
    ret
L29:
    ret
L30:
    ret
L31:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
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
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L3:
    jmp     L0
    mov     rbx,rax
    mov     rdi,rbp
    call    image.sym32
    mov     [rsp],rbx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
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
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
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
    call    qword ptr [fn2.slot]
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
    call    qword ptr [fn1.slot]
    mov     rcx,[rsp+8]
    mov     rdx,r14
    mov     rsi,rcx
    mov     rcx,r12
L2:
    mov     [rbx],rcx
    mov     [rbx+8],rdx
    mov     [rbx+10h],rsi
    mov     rax,rbx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L3:
    jmp     L0
    jmp     L5
    jmp     L5
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
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
    sub     rsp,738h
    mov     [rsp+1D0h],rbx
    mov     [rsp+1C0h],r12
    mov     [rsp+1B0h],r13
    mov     [rsp+1A0h],r14
    mov     [rsp+190h],r15
    mov     [rsp+180h],rbp
    mov     qword ptr [rsp+1F8h],50910h
    lea     rax,[rsp+6F8h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     qword ptr [rsp+6C0h],0
    mov     qword ptr [rsp+6C8h],50910h
    mov     ebx,1
L0:
    mov     rax,[rsp+6C0h]
    mov     rcx,[rsp+6C8h]
    cmp     rax,rcx
    jae     L1
    mov     rcx,rax
    add     rcx,1
    mov     [rsp+6C0h],rcx
    mov     r12,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
L2:
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L3]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L3:
    .long   L5
    .long   L4
    .long   L31
L4:
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+1F8h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rbx,r10
    mov     r10,14057B7EF767814Fh
    mov     [rsp+1F8h],r10
    mov     r10,14057B7EF767814Fh
    add     rbx,r10
    lea     rax,[rsp+6F8h]
    mov     dword ptr [rsp+1FCh],2Ch
    mov     rcx,rbx
    shr     rcx,2Ch
    lea     rdx,[rsp+660h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn10
    jmp     L6
L5:
    mov     qword ptr [rsp+88h],0
    mov     qword ptr [rsp+90h],0
    mov     dword ptr [rsp+1FCh],14h
    mov     qword ptr [rsp+1F8h],1
    mov     qword ptr [rsp+1F8h],2
    lea     rax,[rsp+5E0h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [fn14.slot]
    jmp     L7
L6:
    mov     rax,[rsp+660h]
    mov     rcx,[rsp+668h]
    mov     edx,[rsp+670h]
    mov     esi,[rsp+674h]
    mov     [rsp+1E8h],rax
    mov     [rsp+1F0h],rcx
    mov     [rsp+1F8h],edx
    mov     [rsp+1FCh],esi
    mov     qword ptr [rsp+1E0h],0
    lea     rax,[rsp+1E8h]
    mov     rdi,rax
    mov     esi,0
    call    fn11
    mov     rcx,[rax]
    mov     [rsp+1F8h],rcx
    add     rcx,r12
    jb      L32
    mov     [rax],rcx
    jmp     L0
L7:
    mov     rax,[rsp+5E0h]
    mov     rcx,[rsp+5E8h]
    mov     rdx,[rsp+5F0h]
    mov     esi,[rsp+5F8h]
    mov     edi,[rsp+5FCh]
    mov     [rsp+1E0h],rax
    mov     [rsp+1E8h],rcx
    mov     [rsp+1F0h],rdx
    mov     [rsp+1F8h],esi
    mov     [rsp+1FCh],edi
    lea     rax,[rsp+600h]
    lea     rcx,[rsp+1E0h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn15.slot]
    mov     rax,[rsp+600h]
    mov     rcx,[rsp+608h]
    mov     rdx,[rsp+610h]
    mov     rsi,[rsp+618h]
    mov     [rsp+5A0h],rax
    mov     [rsp+5A8h],rcx
    mov     [rsp+5B0h],rdx
    mov     [rsp+5B8h],rsi
L8:
    mov     rax,[rsp+5B0h]
    add     rax,1
    cmp     rax,0
    je      L30
    mov     rcx,[rsp+5A8h]
    cmp     rcx,0
    jbe     L9
    mov     rdx,[rsp+5A0h]
    add     rax,rdx
    mov     [rsp+5A0h],rax
    sub     rcx,1
    mov     [rsp+5A8h],rcx
    mov     [rsp+78h],rdx
    mov     qword ptr [rsp+70h],1
    jmp     L10
L9:
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFF940h
    lea     rdx,[image.k6704]
    mov     ecx,10h
    call    ryo_h_Const
L10:
    mov     rax,[rsp+70h]
    mov     rbx,[rsp+78h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L11]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L11:
    .long   L17
    .long   L12
    .long   L31
L12:
    mov     [rsp+578h],rbx
    lea     rbx,[rsp+6F8h]
    lea     r12,[rsp+578h]
    mov     rax,[rsp+710h]
    cmp     rax,0
    jne     L13
    mov     ecx,0
    jmp     L14
L13:
    lea     rax,[rsp+718h]
    mov     rdi,rax
    mov     rsi,r12
    call    image.fn79
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,r12
    call    qword ptr [image.fn18.slot]
    cmp     rax,0
    je      L15
    jmp     L16
L14:
    cmp     rcx,0
    je      L8
    jmp     L18
L15:
    mov     ecx,0
    jmp     L14
L16:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L14
L17:
    mov     rax,[rsp+710h]
    mov     [rsp+0A0h],rax
    lea     rax,[rsp+6F8h]
    mov     rdi,rax
    call    qword ptr [image.fn4.slot]
    lea     rax,[rsp+6F8h]
    lea     rdx,[rsp+4E0h]
    mov     rdi,rdx
    mov     rsi,rax
    call    qword ptr [fn23.slot]
    jmp     L19
L18:
    mov     qword ptr [rsp+1F8h],1
    mov     rax,[rsp+88h]
    add     rax,1
    jb      L33
    mov     [rsp+88h],rax
    mov     rax,[rsp+90h]
    mov     rcx,[rcx]
    add     rax,rcx
    mov     [rsp+90h],rax
    jmp     L8
L19:
    mov     rax,[rsp+4E0h]
    mov     rcx,[rsp+4E8h]
    mov     rdx,[rsp+4F0h]
    mov     rsi,[rsp+4F8h]
    mov     edi,[rsp+500h]
    mov     r8d,[rsp+504h]
    mov     [rsp+1D8h],rax
    mov     [rsp+1E0h],rcx
    mov     [rsp+1E8h],rdx
    mov     [rsp+1F0h],rsi
    mov     [rsp+1F8h],edi
    mov     [rsp+1FCh],r8d
    lea     rax,[rsp+1D8h]
    mov     rdi,rax
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+0A8h],rax
    lea     rax,[rsp+4A8h]
    mov     rdi,rax
    call    qword ptr [fn25.slot]
    mov     r10,1FBD000000000h
    mov     [rsp+490h],r10
L20:
    mov     eax,[rsp+490h]
    mov     ecx,[rsp+494h]
    cmp     eax,ecx
    jae     L21
    mov     rcx,rax
    add     ecx,1
    mov     [rsp+490h],ecx
    mov     rbx,rax
    mov     eax,1
    jmp     L22
L21:
    mov     eax,0
L22:
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L23]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L23:
    .long   L25
    .long   L24
    .long   L31
L24:
    lea     r12,[rsp+4A8h]
    mov     dword ptr [rsp+1FCh],138Bh
    mov     dword ptr [rsp+1FCh],138Bh
    mov     [rsp],rbx
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFF8D0h
    mov     ecx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rsp+3E4h]
    lea     rcx,[rsp+3C0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn31.slot]
    jmp     L26
L25:
    mov     rax,[rsp+710h]
    mov     [rsp+0B0h],rax
    lea     rbx,[rsp+0B0h]
    mov     rax,[rsp+4C0h]
    mov     [rsp+0B8h],rax
    lea     r13,[rsp+0B8h]
    lea     rax,[rsp+0A0h]
    lea     r14,[rsp+88h]
    lea     r15,[rsp+90h]
    lea     rbp,[rsp+0A8h]
    lea     rcx,[rsp+120h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn41.slot]
    jmp     L27
L26:
    mov     rax,[rsp+3C0h]
    mov     rcx,[rsp+3C8h]
    mov     [rsp+3D0h],rax
    mov     [rsp+3D8h],rcx
    lea     rax,[k32]
    lea     rcx,[rsp+3D0h]
    lea     rdx,[rsp+408h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [fn34.slot]
    mov     rax,[rsp+408h]
    mov     rcx,[rsp+410h]
    mov     edx,[rsp+418h]
    mov     esi,[rsp+41Ch]
    mov     [rsp+1E8h],rax
    mov     [rsp+1F0h],rcx
    mov     [rsp+1F8h],edx
    mov     [rsp+1FCh],esi
    lea     rax,[rsp+420h]
    lea     rcx,[rsp+1E8h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn35.slot]
    mov     rax,[rsp+420h]
    mov     rcx,[rsp+428h]
    mov     edx,[rsp+430h]
    mov     esi,[rsp+434h]
    mov     [rsp+1E8h],rax
    mov     [rsp+1F0h],rcx
    mov     [rsp+1F8h],edx
    mov     [rsp+1FCh],esi
    lea     rax,[rsp+440h]
    lea     rcx,[rsp+1E8h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,rcx
    call    qword ptr [fn36.slot]
    mov     rax,[rsp+440h]
    mov     rcx,[rsp+448h]
    mov     rdx,[rsp+450h]
    mov     rsi,[rsp+458h]
    mov     edi,[rsp+460h]
    mov     r8d,[rsp+464h]
    mov     [rsp+1D8h],rax
    mov     [rsp+1E0h],rcx
    mov     [rsp+1E8h],rdx
    mov     [rsp+1F0h],rsi
    mov     [rsp+1F8h],edi
    mov     [rsp+1FCh],r8d
    lea     rax,[rsp+1D8h]
    mov     rdi,rax
    call    qword ptr [fn37.slot]
    mov     rcx,[rax]
    mov     [rsp+1F8h],rcx
    mov     qword ptr [rsp+1F0h],1
    add     rcx,1
    jb      L34
    mov     [rax],rcx
    jmp     L20
L27:
    lea     rax,[rsp+130h]
    mov     rdi,rax
    mov     rsi,r14
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+140h]
    mov     rdi,rax
    mov     rsi,r15
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+150h]
    mov     rdi,rax
    mov     rsi,rbx
    call    qword ptr [fn41.slot]
    lea     rax,[rsp+160h]
    mov     rdi,rax
    mov     rsi,rbp
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+170h]
    mov     rdi,rax
    mov     rsi,r13
    call    qword ptr [fn41.slot]
    mov     rax,[rsp+120h]
    mov     rcx,[rsp+128h]
    mov     [rsp+0C0h],rax
    mov     [rsp+0C8h],rcx
    mov     rax,[rsp+130h]
    mov     rcx,[rsp+138h]
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],rcx
    mov     rax,[rsp+140h]
    mov     rcx,[rsp+148h]
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rcx
    mov     rax,[rsp+150h]
    mov     rcx,[rsp+158h]
    mov     [rsp+0F0h],rax
    mov     [rsp+0F8h],rcx
    mov     rax,[rsp+160h]
    mov     rcx,[rsp+168h]
    mov     [rsp+100h],rax
    mov     [rsp+108h],rcx
    mov     rax,[rsp+170h]
    mov     rcx,[rsp+178h]
    mov     [rsp+110h],rax
    mov     [rsp+118h],rcx
    lea     rax,[k47]
    lea     rcx,[rsp+0C0h]
    mov     rdi,rax
    mov     rsi,rcx
    call    sym49
    lea     rbx,[rsp+4A8h]
    mov     [rsp+1F8h],rbx
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFF928h
    lea     rdx,[image.k304]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r12,[rsp+58h]
    mov     r13,[rsp+60h]
    mov     rax,[rsp+4B0h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L28
    mov     rdi,rbx
    call    qword ptr [image.fn22.slot]
    mov     rax,[rsp+4B0h]
    add     rax,1
    lea     rcx,[rsp+38h]
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    qword ptr [image.fn125.slot]
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     rsi,[rsp+4A8h]
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rsi
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+38h],rdx
    lea     rsi,[rsi+rdx]
    mov     [rsp+48h],rsi
    cmp     rcx,0
    je      L28
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rdx,rax
    call    image.sym67
L28:
    lea     rbx,[rsp+6F8h]
    mov     [rsp+1F8h],rbx
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFF8F8h
    lea     rdx,[image.k408]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     rax,[rsp+700h]
    mov     [rsp+18h],rax
    cmp     rax,0
    je      L29
    mov     rdi,rbx
    call    qword ptr [image.fn23.slot]
    mov     rax,[rsp+700h]
    add     rax,1
    lea     rcx,[rsp+8]
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    qword ptr [image.fn125.slot]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rsi,[rsp+6F8h]
    mov     [rsp+8],rsi
    mov     [rsp+10h],rsi
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+8],rdx
    lea     rsi,[rsi+rdx]
    mov     [rsp+18h],rsi
    cmp     rcx,0
    je      L29
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rdx,rax
    call    image.sym67
L29:
    mov     rbx,[rsp+1D0h]
    mov     r12,[rsp+1C0h]
    mov     r13,[rsp+1B0h]
    mov     r14,[rsp+1A0h]
    mov     r15,[rsp+190h]
    mov     rbp,[rsp+180h]
    add     rsp,738h
    ret
L30:
    lea     rax,[image.k6720]
    lea     rcx,[image.k4306]
    mov     rdi,rcx
    mov     esi,1A3h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym63
    ud2
L31:
    ud2
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
L32:
    lea     rax,[k12]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
L33:
    lea     rax,[k19]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     r12,rax
    jmp     L36
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
L34:
    lea     rax,[k38]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    sym13
    ud2
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     rbx,rax
    jmp     L38
    mov     r12,rax
    jmp     L36
L35:
    lea     rax,[rsp+4A8h]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn218.slot]
    mov     r12,rbx
    jmp     L36
    jmp     L37
L36:
    lea     rax,[rsp+6F8h]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    qword ptr [image.fn219.slot]
    mov     [rsp],r12
    lea     rdi,[rsp+730h]
    mov     esi,0FFFFF8D0h
    call    ryo_h_Resume
    ud2
L37:
    call    sym54
    ud2
L38:
    jmp     L35
  ; OSR entries
    lea     r11,[L39]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L39:
    .long   L40
    .long   L41
    .long   L42
    .long   L43
    .long   L44
    .long   L45
    .long   L46
L40:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-830h]
    mov     r11,[rdx-40h]
    mov     [rsp],r11
    mov     r11,[rdx-4E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-4D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-4D0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-4C8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-4C0h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-4B8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-4B0h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-4A8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-4A0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-498h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-490h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-488h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-480h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-478h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-470h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+0B0h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+0B8h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+0C0h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+0C8h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+0D0h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+0D8h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+0E0h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+0E8h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+0F0h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-570h],r12
    mov     [rdx-580h],r13
    mov     [rdx-590h],r14
    mov     [rdx-5A0h],r15
    mov     [rdx-5B0h],rbp
    mov     r11,[rsp+8]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-670h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-678h],r11
    mov     r11,[rsp+0D0h]
    mov     [rdx-680h],r11
    mov     r11,[rsp+0D8h]
    mov     [rdx-688h],r11
    mov     r11,[rsp+0E0h]
    mov     [rdx-690h],r11
    mov     r11,[rsp+0E8h]
    mov     [rdx-6A0h],r11
    mov     r11,[rsp+0F0h]
    mov     [rdx-6A8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+100h]
    jmp     L0
L41:
    ret
L42:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-820h]
    mov     r11,[rdx-4E0h]
    mov     [rsp],r11
    mov     r11,[rdx-4D8h]
    mov     [rsp+8],r11
    mov     r11,[rdx-4D0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-4C8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-4C0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-4B8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-4B0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-4A8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-4A0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-498h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-490h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-488h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-480h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-478h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-470h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+0B0h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+0B8h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+0C0h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+0C8h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+0D0h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+0D8h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+0E0h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+0E8h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-570h],r12
    mov     [rdx-580h],r13
    mov     [rdx-590h],r14
    mov     [rdx-5A0h],r15
    mov     [rdx-5B0h],rbp
    mov     r11,[rsp]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-670h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-678h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-680h],r11
    mov     r11,[rsp+0D0h]
    mov     [rdx-688h],r11
    mov     r11,[rsp+0D8h]
    mov     [rdx-690h],r11
    mov     r11,[rsp+0E0h]
    mov     [rdx-6A0h],r11
    mov     r11,[rsp+0E8h]
    mov     [rdx-6A8h],r11
    lea     rsp,[rsp+0F0h]
    jmp     L8
L43:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-820h]
    mov     r11,[rdx-4E0h]
    mov     [rsp],r11
    mov     r11,[rdx-4D8h]
    mov     [rsp+8],r11
    mov     r11,[rdx-4D0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-4C8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-4C0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-4B8h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-4B0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-4A8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-4A0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-498h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-490h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-488h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-480h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-478h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-470h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-468h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-460h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-458h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-450h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-448h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-440h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-438h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-430h]
    mov     [rsp+0B0h],r11
    mov     r11,[rdx-428h]
    mov     [rsp+0B8h],r11
    mov     r11,[rdx-3F8h]
    mov     [rsp+0C0h],r11
    mov     r11,[rdx-3E0h]
    mov     [rsp+0C8h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+0D0h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+0D8h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+0E0h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+0E8h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-570h],r12
    mov     [rdx-580h],r13
    mov     [rdx-590h],r14
    mov     [rdx-5A0h],r15
    mov     [rdx-5B0h],rbp
    mov     r11,[rsp]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-670h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-678h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-680h],r11
    mov     r11,[rsp+0D0h]
    mov     [rdx-688h],r11
    mov     r11,[rsp+0D8h]
    mov     [rdx-690h],r11
    mov     r11,[rsp+0E0h]
    mov     [rdx-6A0h],r11
    mov     r11,[rsp+0E8h]
    mov     [rdx-6A8h],r11
    lea     rsp,[rsp+0F0h]
    jmp     L20
L44:
    ret
L45:
    ret
L46:
    ret

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rsi]
    mov     rdi,rax
    mov     esi,3
    call    ryo_hr_RemUW64
    cmp     rax,0
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    cmp     rax,rcx
    setb    al
    movzx   eax,al
    add     rsp,18h
    ret

fn std::collections::HashMap::<std::string::String, usize>::entry
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     rbx,rdi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rcx
    mov     [rsp+40h],rdx
    lea     rax,[rsp+8]
    lea     rcx,[rsp+30h]
    mov     rdi,rax
    mov     rdx,rcx
    call    qword ptr [fn0.slot]
    mov     rax,[rsp+8]
    cmp     rax,0FFFFFFFFFFFFFFFFh
    je      L1
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
L0:
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     [rbx+18h],rsi
    mov     [rbx+20h],rdi
    mov     rax,rbx
    mov     rbx,[rsp+50h]
    add     rsp,68h
    ret
L1:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,rcx
    mov     rcx,rax
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    ret

fn std::collections::HashMap::<u64, u64>::entry
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     rax,[rsp+8]
    cmp     rax,0
    je      L1
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
L0:
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     rax,rbx
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
L1:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,rcx
    mov     rcx,rax
    mov     eax,0
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
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

fn std::fmt::format
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+28h],r12
    mov     [rsp+30h],rdx
    mov     rax,rdx
    and     rax,1
    cmp     rax,1
    je      L1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L0:
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rsi
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    add     rsp,98h
    ret
L1:
    mov     r13,rdx
    shr     r13,1
    lea     r14,[k2]
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L3
    cmp     r12,0
    je      L4
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,1
    call    ryo_hr_DivUW64
    cmp     r13,rax
    ja      L4
    mov     [rsp+38h],r12
    mov     [rsp+40h],r13
L2:
    lea     rax,[rsp+28h]
    lea     rcx,[rsp+8]
    mov     rdx,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdi,rcx
    mov     rcx,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [fn1.slot]
    jmp     L0
L3:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym39
    ud2
    jmp     L5
L4:
    lea     rax,[image.k5783]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym63
    ud2
L5:
    call    image.sym30
    ud2
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
    .long   L8
L7:
    ret
L8:
    ret

fn std::fmt::format::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    lea     rdx,[rsp+8]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    sym0
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     rax,rbx
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret

fn std::hint::must_use::<std::string::String>
    sub     rsp,18h
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     rdx,[rsi+10h]
    mov     [rdi],rax
    mov     [rdi+8],rcx
    mov     [rdi+10h],rdx
    mov     rax,rdi
    add     rsp,18h
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    cmp     rsi,0
    je      L0
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L1
L0:
    lea     rax,[rsp+8]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    jmp     L1
L1:
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     rax,rbx
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
    mov     ecx,1
    jmp     L5
    mov     ecx,0
    jmp     L5
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
L4:
    test    cl,cl
    jne     L3
    jmp     L2
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
    .long   L10
L7:
    ret
L8:
    ret
L9:
    ret
L10:
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
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
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
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
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    lea     r14,[k0]
    cmp     r13,0
    jne     L0
    mov     r15d,1
    jmp     L1
L0:
    mov     r15d,0
L1:
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L8
    test    r15b,r15b
    je      L6
L2:
    mov     edi,1
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    test    r15b,r15b
    je      L7
L3:
    cmp     rbx,r12
    jae     L4
    mov     rax,r12
    sub     rax,rbx
    jmp     L5
L4:
    mov     rax,rbx
    sub     rax,r12
L5:
    cmp     r13,rax
    ja      L10
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,r13
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L6:
    cmp     rbx,0
    je      L10
    jmp     L2
L7:
    cmp     r12,0
    je      L10
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
    jmp     L11
    jmp     L11
L10:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym63
    ud2
L11:
    call    image.sym30
    ud2

fn std::ptr::copy_nonoverlapping::precondition_check
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
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
    mov     r11,rax
    mov     r10,rdx
    mov     rax,r13
    mul     r15
    mov     rdx,r10
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
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rdi,rbx
    call    image.sym31
    mov     rdi,rbx
    call    image.sym32
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
    mov     [rsp+10h],rax
    mov     rdi,rbx
    call    image.sym32
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    call    image.sym21
    ud2

