fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    sub     rsp,158h
    mov     [rsp+140h],rbx
    mov     [rsp+130h],r12
    mov     [rsp+120h],r13
    mov     [rsp+110h],r14
    mov     [rsp+100h],r15
    mov     [rsp+0F0h],rbp
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+60h],rdx
    mov     r11,[rsp+70h]
    mov     rax,[r11+30h]
    add     rax,[rsp+60h]
    mov     r11,[rsp+70h]
    mov     [r11+30h],rax
    mov     r11,[rsp+70h]
    mov     rax,[r11+40h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     ecx,0
    jmp     L6
L1:
    mov     r11,[rsp+70h]
    mov     rax,[r11+40h]
    mov     r11d,8
    sub     r11,rax
    mov     [rsp+58h],r11
    mov     r10,[rsp+58h]
    mov     [rsp+0E0h],r10
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+60h]
    setb    al
    test    al,al
    je      L2
    mov     r11,[rsp+58h]
    mov     [rsp+78h],r11
    jmp     L3
L2:
    mov     r11,[rsp+60h]
    mov     [rsp+78h],r11
L3:
    jmp     L54
L4:
    mov     r11,[rsp+70h]
    mov     rcx,[r11+40h]
    mov     [rsp+0E0h],rcx
    imul    rcx,8
    mov     rdi,[rsp+50h]
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    mov     r11,[rsp+70h]
    mov     rdx,[r11+38h]
    or      rdx,rcx
    mov     r11,[rsp+70h]
    mov     [r11+38h],rdx
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L5
    mov     r11,[rsp+70h]
    mov     rcx,[r11+40h]
    add     rcx,[rsp+60h]
    mov     r11,[rsp+70h]
    mov     [r11+40h],rcx
    jmp     L53
L5:
    mov     r11,[rsp+70h]
    mov     rcx,[r11+38h]
    mov     r11,[rsp+70h]
    mov     rdx,[r11+18h]
    xor     rdx,rcx
    mov     r11,[rsp+70h]
    mov     [r11+18h],rdx
    mov     rdi,[rsp+70h]
    call    fn1
    mov     r11,[rsp+70h]
    mov     rcx,[r11+38h]
    mov     r11,[rsp+70h]
    mov     rdx,[r11]
    xor     rdx,rcx
    mov     r11,[rsp+70h]
    mov     [r11],rdx
    mov     r11,[rsp+70h]
    mov     qword ptr [r11+40h],0
    mov     rcx,[rsp+58h]
L6:
    mov     rdx,[rsp+60h]
    sub     rdx,rcx
    mov     rsi,rdx
    and     rsi,7
    mov     [rsp+38h],rcx
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rsi
    mov     r11,[rsp+68h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+30h],r11
L7:
    mov     r10,[rsp+38h]
    mov     [rsp+0E0h],r10
    mov     rcx,[rsp+10h]
    sub     rcx,[rsp+18h]
    mov     r11,[rsp+38h]
    cmp     r11,rcx
    jae     L9
    mov     qword ptr [rsp+0E0h],0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+38h]
    lea     r11,[r11+r10]
    mov     [rsp+48h],r11
    lea     r11,[rsp+0E0h]
    mov     [rsp+40h],r11
    jmp     L97
L8:
    mov     rax,[rcx]
    xor     rax,rdx
    mov     [rcx],rax
    add     rsi,8
    mov     [rsp+38h],rsi
    mov     [rsp+10h],rdi
    mov     [rsp+18h],r8
    mov     [rsp+20h],r9
    mov     [rsp+28h],rbp
    mov     [rsp+30h],rcx
    jmp     L7
L9:
    mov     r11d,3
    cmp     r11,[rsp+18h]
    jb      L11
    jmp     L10
L10:
    mov     qword ptr [rsp+90h],0
    mov     r12d,0
    jmp     L12
L11:
    mov     dword ptr [rsp+0C0h],0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+38h]
    lea     rbp,[r11+r10]
    lea     r14,[rsp+0C0h]
    jmp     L19
L12:
    mov     rax,[rsp+90h]
    add     rax,1
    cmp     rax,[rsp+18h]
    jb      L14
    jmp     L13
L13:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],r12
    jmp     L15
L14:
    mov     word ptr [rsp+0B4h],0
    mov     rax,[rsp+38h]
    add     rax,[rsp+90h]
    mov     r11,[rsp+20h]
    lea     rbx,[r11+rax]
    lea     r15,[rsp+0B4h]
    jmp     L35
L15:
    cmp     rax,[rsp+18h]
    jb      L17
    jmp     L16
L16:
    mov     rdx,[rsp+80h]
    jmp     L18
L17:
    mov     rcx,[rsp+38h]
    add     rcx,rax
    jmp     L51
L18:
    mov     rax,rdx
    jmp     L52
L19:
    lea     r11,[image.k3192]
    mov     [rsp+88h],r11
    mov     r13d,0
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L21
L20:
    mov     edx,1
    jmp     L22
L21:
    cmp     edx,1
    je      L20
    jmp     L113
L22:
    jmp     L31
L23:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    jmp     L25
L24:
    mov     esi,1
    jmp     L26
L25:
    cmp     esi,1
    je      L24
    jmp     L114
L26:
    jmp     L33
L27:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mov     edx,4
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L115
    cmp     rbp,r14
    jae     L28
    mov     r8,r14
    sub     r8,rbp
    jmp     L29
L28:
    mov     r8,rbp
    sub     r8,r14
L29:
    cmp     rdi,r8
    setbe   dil
    jmp     L34
L30:
    test    r13b,r13b
    jne     L23
    cmp     rbp,0
    je      L116
    jmp     L23
L31:
    test    dl,dl
    jne     L30
    jmp     L116
L32:
    test    r13b,r13b
    jne     L27
    cmp     r14,0
    je      L116
    jmp     L27
L33:
    test    sil,sil
    jne     L32
    jmp     L116
L34:
    test    dil,dil
    je      L116
    mov     rdi,r14
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     edx,[rsp+0C0h]
    mov     edx,edx
    mov     qword ptr [rsp+90h],4
    mov     r12,rdx
    jmp     L12
L35:
    lea     r11,[image.k3216]
    mov     [rsp+98h],r11
    mov     r14d,0
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L37
L36:
    mov     edx,1
    jmp     L38
L37:
    cmp     edx,1
    je      L36
    jmp     L118
L38:
    jmp     L47
L39:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    jmp     L41
L40:
    mov     esi,1
    jmp     L42
L41:
    cmp     esi,1
    je      L40
    jmp     L119
L42:
    jmp     L49
L43:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mov     edx,2
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L120
    cmp     rbx,r15
    jae     L44
    mov     r8,r15
    sub     r8,rbx
    jmp     L45
L44:
    mov     r8,rbx
    sub     r8,r15
L45:
    cmp     rdi,r8
    setbe   dil
    jmp     L50
L46:
    test    r14b,r14b
    jne     L39
    cmp     rbx,0
    je      L121
    jmp     L39
L47:
    test    dl,dl
    jne     L46
    jmp     L121
L48:
    test    r14b,r14b
    jne     L43
    cmp     r15,0
    je      L121
    jmp     L43
L49:
    test    sil,sil
    jne     L48
    jmp     L121
L50:
    test    dil,dil
    je      L121
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   edx,word ptr [rsp+0B4h]
    movzx   edx,dx
    mov     rsi,[rsp+90h]
    imul    rsi,8
    mov     rdi,rdx
    call    ryo_hr_ShlW64
    mov     rdx,rax
    or      r12,rdx
    mov     rdx,[rsp+90h]
    add     rdx,2
    mov     rax,rdx
    mov     [rsp+80h],r12
    jmp     L15
L51:
    lea     rdx,[image.k3320]
    cmp     rcx,[rsp+28h]
    jae     L123
    cmp     rcx,[rsp+28h]
    setb    sil
    mov     [rsp+0B5h],sil
    mov     r11,[rsp+20h]
    lea     rcx,[r11+rcx]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    rax,8
    mov     rdi,rcx
    mov     rsi,rax
    call    ryo_hr_ShlW64
    or      rax,[rsp+80h]
L52:
    mov     r11,[rsp+30h]
    mov     [r11+38h],rax
    mov     r11,[rsp+30h]
    mov     r10,[rsp+18h]
    mov     [r11+40h],r10
L53:
    mov     rbx,[rsp+140h]
    mov     r12,[rsp+130h]
    mov     r13,[rsp+120h]
    mov     r14,[rsp+110h]
    mov     r15,[rsp+100h]
    mov     rbp,[rsp+0F0h]
    add     rsp,158h
    ret
L54:
    mov     r11d,3
    cmp     r11,[rsp+78h]
    jb      L56
    jmp     L55
L55:
    mov     r12d,0
    mov     r14d,0
    jmp     L57
L56:
    mov     dword ptr [rsp+0D0h],0
    lea     rbx,[rsp+0D0h]
    jmp     L63
L57:
    mov     rax,r12
    add     rax,1
    cmp     rax,[rsp+78h]
    jb      L59
    jmp     L58
L58:
    mov     rax,r12
    mov     [rsp+0A8h],r14
    jmp     L60
L59:
    mov     word ptr [rsp+0C4h],0
    mov     r11,[rsp+68h]
    lea     r15,[r11+r12]
    lea     rbp,[rsp+0C4h]
    jmp     L79
L60:
    cmp     rax,[rsp+78h]
    jb      L95
    jmp     L61
L61:
    mov     rcx,[rsp+0A8h]
    jmp     L62
L62:
    mov     [rsp+50h],rcx
    jmp     L96
L63:
    lea     r11,[image.k3192]
    mov     [rsp+0A0h],r11
    mov     r13d,0
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L65
L64:
    mov     ecx,1
    jmp     L66
L65:
    cmp     ecx,1
    je      L64
    jmp     L124
L66:
    jmp     L75
L67:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    jmp     L69
L68:
    mov     esi,1
    jmp     L70
L69:
    cmp     esi,1
    je      L68
    jmp     L125
L70:
    jmp     L77
L71:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mov     edx,4
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L126
    mov     r11,[rsp+68h]
    cmp     r11,rbx
    jae     L72
    mov     r8,rbx
    sub     r8,[rsp+68h]
    jmp     L73
L72:
    mov     r8,[rsp+68h]
    sub     r8,rbx
L73:
    cmp     rdi,r8
    setbe   dil
    jmp     L78
L74:
    test    r13b,r13b
    jne     L67
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L127
    jmp     L67
L75:
    test    cl,cl
    jne     L74
    jmp     L127
L76:
    test    r13b,r13b
    jne     L71
    cmp     rbx,0
    je      L127
    jmp     L71
L77:
    test    sil,sil
    jne     L76
    jmp     L127
L78:
    test    dil,dil
    je      L127
    mov     rdi,rbx
    mov     rsi,[rsp+68h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+0D0h]
    mov     ecx,ecx
    mov     r12d,4
    mov     r14,rcx
    jmp     L57
L79:
    lea     rbx,[image.k3216]
    mov     r13d,0
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L81
L80:
    mov     ecx,1
    jmp     L82
L81:
    cmp     ecx,1
    je      L80
    jmp     L129
L82:
    jmp     L91
L83:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    jmp     L85
L84:
    mov     esi,1
    jmp     L86
L85:
    cmp     esi,1
    je      L84
    jmp     L130
L86:
    jmp     L93
L87:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mov     edx,2
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L131
    cmp     r15,rbp
    jae     L88
    mov     r8,rbp
    sub     r8,r15
    jmp     L89
L88:
    mov     r8,r15
    sub     r8,rbp
L89:
    cmp     rdi,r8
    setbe   dil
    jmp     L94
L90:
    test    r13b,r13b
    jne     L83
    cmp     r15,0
    je      L132
    jmp     L83
L91:
    test    cl,cl
    jne     L90
    jmp     L132
L92:
    test    r13b,r13b
    jne     L87
    cmp     rbp,0
    je      L132
    jmp     L87
L93:
    test    sil,sil
    jne     L92
    jmp     L132
L94:
    test    dil,dil
    je      L132
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+0C4h]
    movzx   ecx,cx
    mov     rsi,r12
    imul    rsi,8
    mov     rdi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r14,rcx
    add     r12,2
    mov     rax,r12
    mov     [rsp+0A8h],r14
    jmp     L60
L95:
    lea     rcx,[image.k3320]
    cmp     rax,[rsp+60h]
    jae     L134
    cmp     rax,[rsp+60h]
    setb    sil
    mov     [rsp+0C5h],sil
    mov     r11,[rsp+68h]
    lea     rsi,[r11+rax]
    movzx   esi,byte ptr [rsi]
    movzx   esi,sil
    imul    rax,8
    mov     rdi,rsi
    mov     rsi,rax
    call    ryo_hr_ShlW64
    or      rax,[rsp+0A8h]
    mov     [rsp+50h],rax
L96:
    jmp     L4
L97:
    lea     r12,[k4]
    mov     r13d,0
    mov     edi,1
    call    ryo_hr_CtpopW64
    jmp     L99
L98:
    mov     eax,1
    jmp     L100
L99:
    cmp     eax,1
    je      L98
    jmp     L135
L100:
    jmp     L109
L101:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    jmp     L103
L102:
    mov     esi,1
    jmp     L104
L103:
    cmp     esi,1
    je      L102
    jmp     L136
L104:
    jmp     L111
L105:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mov     edx,8
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L137
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+40h]
    jae     L106
    mov     r8,[rsp+40h]
    sub     r8,[rsp+48h]
    jmp     L107
L106:
    mov     r8,[rsp+48h]
    sub     r8,[rsp+40h]
L107:
    cmp     rdi,r8
    setbe   dil
    jmp     L112
L108:
    test    r13b,r13b
    jne     L101
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L138
    jmp     L101
L109:
    test    al,al
    jne     L108
    jmp     L138
L110:
    test    r13b,r13b
    jne     L105
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L138
    jmp     L105
L111:
    test    sil,sil
    jne     L110
    jmp     L138
L112:
    test    dil,dil
    je      L138
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+0E0h]
    mov     r11,[rsp+30h]
    mov     rax,[r11+18h]
    xor     rax,r13
    mov     r11,[rsp+30h]
    mov     [r11+18h],rax
    mov     r10,[rsp+30h]
    mov     [rsp+0E0h],r10
    mov     rdi,[rsp+30h]
    call    fn1
    mov     rcx,[rsp+30h]
    mov     rdx,r13
    mov     rsi,[rsp+38h]
    mov     rdi,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     rbp,[rsp+28h]
    jmp     L8
L113:
    lea     rax,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rax
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L114:
    lea     rax,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rax
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L115:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L117
    jmp     L117
L116:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L117:
    call    qword ptr [image.sym30]
    ud2
L118:
    lea     rax,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rax
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L119:
    lea     rax,[image.k1979]
    lea     rsi,[image.k2104]
    mov     rdi,rax
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L120:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L122
    jmp     L122
L121:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L122:
    call    qword ptr [image.sym30]
    ud2
L123:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L124:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L125:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L126:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L128
    jmp     L128
L127:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L128:
    call    qword ptr [image.sym30]
    ud2
L129:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L130:
    lea     rax,[image.k1979]
    lea     rdx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym39]
    ud2
L131:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L133
    jmp     L133
L132:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L133:
    call    qword ptr [image.sym30]
    ud2
L134:
    lea     rax,[image.k6416]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L135:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L136:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L137:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L139
    jmp     L139
L138:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L139:
    call    qword ptr [image.sym30]
    ud2
  ; OSR entries
    lea     r11,[L140]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L140:
    .long   L141
    .long   L142
    .long   L143
L141:
    ret
L142:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-190h]
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
    mov     r11,[rsp]
    mov     [rdx-118h],r11
    mov     r11,[rsp+8]
    mov     [rdx-140h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-120h],r11
    lea     rsp,[rsp+40h]
    jmp     L7
L143:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-190h]
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
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L8

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
    jmp     L3
L0:
    add     rsp,18h
    ret
L1:
    mov     r8,[rdi]
    mov     r11,[r8]
    mov     rcx,[rcx+8]
    add     rcx,rsi
    mov     rax,rcx
    jmp     L0
L2:
    mov     rcx,rax
    jmp     L1
L3:
    lea     rdx,[rdx-10h]
    mov     rax,rdx
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

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rbx+30h]
    and     rax,0FFh
    shl     rax,38h
    mov     rcx,[rbx+38h]
    mov     rbx,rax
    or      rbx,rcx
    mov     rax,[rsp+28h]
    xor     rax,rbx
    mov     [rsp+28h],rax
    lea     r12,[rsp+10h]
    mov     rdi,r12
    call    image.fn208
    mov     rax,[rsp+10h]
    xor     rax,rbx
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    xor     rax,0FFh
    mov     [rsp+18h],rax
    mov     rdi,r12
    call    image.fn209
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+20h]
    xor     rax,rcx
    mov     rcx,[rsp+18h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    sub     rsp,168h
    mov     [rsp+150h],rbx
    mov     rbx,rdi
    mov     rax,[rsi]
    mov     rcx,[rsi+8]
    mov     qword ptr [rsp+130h],0
    mov     qword ptr [rsp+138h],0
    mov     qword ptr [rsp+140h],0
    mov     qword ptr [rsp+148h],0
    mov     [rsp+100h],rax
    mov     [rsp+108h],rcx
    mov     qword ptr [rsp+110h],0
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFD0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     qword ptr [rsp+118h],0
    mov     qword ptr [rsp+120h],0
    lea     rax,[rsp+0E0h]
    mov     [rsp+148h],rax
    mov     qword ptr [rsp+110h],0
    mov     rax,[rsp+100h]
    mov     rcx,rax
    mov     r10,736F6D6570736575h
    xor     rcx,r10
    mov     [rsp+0E0h],rcx
    mov     rcx,[rsp+108h]
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
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF80h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF38h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    mov     edx,0FFFFFEF0h
    mov     ecx,48h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    mov     edx,0
    mov     ecx,0FFFFFEA8h
    mov     r8d,48h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+150h]
    add     rsp,168h
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
    sub     rsp,278h
    mov     [rsp+260h],rbx
    mov     [rsp+250h],r12
    mov     [rsp+240h],r13
    mov     [rsp+230h],r14
    mov     [rsp+220h],r15
    mov     [rsp+210h],rbp
    mov     rbx,rsi
    lea     rax,[rsp+1C8h]
    mov     rsi,rdi
    mov     rdi,rax
    call    fn0
    lea     r11,[rsp+1C8h]
    mov     [rsp+10h],r11
    mov     r11,[rbx+8]
    mov     [rsp+68h],r11
    mov     r11,[rbx+10h]
    mov     [rsp+60h],r11
    mov     rax,[rsp+1F8h]
    add     rax,[rsp+60h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+208h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     ecx,0
    jmp     L4
L1:
    mov     rax,[rsp+208h]
    mov     r11d,8
    sub     r11,rax
    mov     [rsp+58h],r11
    mov     r10,[rsp+58h]
    mov     [rsp+150h],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    call    qword ptr [image.fn239.slot]
    mov     [rsp+70h],rax
    jmp     L21
L2:
    mov     rcx,[rsp+208h]
    mov     [rsp+150h],rcx
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    mov     rdx,[rsp+200h]
    or      rdx,rcx
    mov     [rsp+200h],rdx
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L3
    mov     rcx,[rsp+208h]
    add     rcx,[rsp+60h]
    mov     [rsp+208h],rcx
    jmp     L42
L3:
    mov     rcx,[rsp+200h]
    mov     rdx,[rsp+1E0h]
    xor     rdx,rcx
    mov     [rsp+1E0h],rdx
    mov     rdi,[rsp+10h]
    call    image.fn208
    mov     rcx,[rsp+200h]
    mov     rdx,[rsp+1C8h]
    xor     rdx,rcx
    mov     [rsp+1C8h],rdx
    mov     qword ptr [rsp+208h],0
    mov     rcx,[rsp+58h]
L4:
    mov     rdx,[rsp+60h]
    sub     rdx,rcx
    mov     rsi,rdx
    and     rsi,7
    mov     [rsp+40h],rcx
    mov     [rsp+38h],rdx
    mov     [rsp+18h],rsi
    mov     r11,[rsp+68h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+30h],r11
L5:
    mov     r10,[rsp+40h]
    mov     [rsp+150h],r10
    mov     rcx,[rsp+38h]
    sub     rcx,[rsp+18h]
    mov     r11,[rsp+40h]
    cmp     r11,rcx
    jae     L7
    mov     qword ptr [rsp+150h],0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+40h]
    lea     r11,[r11+r10]
    mov     [rsp+50h],r11
    lea     r11,[rsp+150h]
    mov     [rsp+48h],r11
    jmp     L34
L6:
    mov     r12,[rcx]
    xor     r12,rdx
    mov     [rcx],r12
    add     rsi,8
    mov     [rsp+40h],rsi
    mov     [rsp+38h],rdi
    mov     [rsp+18h],r8
    mov     [rsp+20h],r9
    mov     [rsp+28h],rbp
    mov     [rsp+30h],rcx
    jmp     L5
L7:
    mov     r11d,3
    cmp     r11,[rsp+18h]
    jb      L9
    jmp     L8
L8:
    mov     r14d,0
    mov     ebx,0
    jmp     L10
L9:
    mov     dword ptr [rsp+130h],0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+40h]
    lea     r12,[r11+r10]
    lea     rbp,[rsp+130h]
    jmp     L17
L10:
    mov     rcx,r14
    add     rcx,1
    cmp     rcx,[rsp+18h]
    jb      L12
    jmp     L11
L11:
    mov     [rsp+78h],r14
    mov     [rsp+80h],rbx
    jmp     L13
L12:
    mov     word ptr [rsp+124h],0
    mov     rcx,[rsp+40h]
    add     rcx,r14
    mov     r11,[rsp+20h]
    lea     r13,[r11+rcx]
    lea     r15,[rsp+124h]
    jmp     L18
L13:
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+18h]
    jb      L15
    jmp     L14
L14:
    mov     rcx,[rsp+80h]
    jmp     L16
L15:
    mov     r11,[rsp+40h]
    add     r11,[rsp+78h]
    mov     [rsp+88h],r11
    jmp     L19
L16:
    jmp     L20
L17:
    lea     rcx,[image.k3192]
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+130h]
    mov     ecx,ecx
    mov     r14d,4
    mov     rbx,rcx
    jmp     L10
L18:
    lea     rcx,[image.k3216]
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r15
    mov     rsi,r13
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+124h]
    movzx   ecx,cx
    mov     rdx,r14
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rbx,rcx
    add     r14,2
    mov     [rsp+78h],r14
    mov     [rsp+80h],rbx
    jmp     L13
L19:
    lea     rcx,[image.k3320]
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+28h]
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    mov     r11,[rsp+88h]
    cmp     r11,[rsp+28h]
    setb    cl
    mov     [rsp+125h],cl
    mov     r11,[rsp+20h]
    mov     r10,[rsp+88h]
    lea     rcx,[r11+r10]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    mov     rdx,[rsp+78h]
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+80h]
L20:
    mov     r11,[rsp+30h]
    mov     [r11+38h],rcx
    mov     r11,[rsp+30h]
    mov     r10,[rsp+18h]
    mov     [r11+40h],r10
    jmp     L42
L21:
    mov     r11d,3
    cmp     r11,[rsp+70h]
    jb      L23
    jmp     L22
L22:
    mov     r12d,0
    mov     r13d,0
    jmp     L24
L23:
    mov     dword ptr [rsp+140h],0
    lea     rbx,[rsp+140h]
    jmp     L30
L24:
    mov     rcx,r12
    add     rcx,1
    cmp     rcx,[rsp+70h]
    jb      L26
    jmp     L25
L25:
    mov     rbp,r12
    mov     [rsp+90h],r13
    jmp     L27
L26:
    mov     word ptr [rsp+134h],0
    mov     r11,[rsp+68h]
    lea     r14,[r11+r12]
    lea     r15,[rsp+134h]
    jmp     L31
L27:
    cmp     rbp,[rsp+70h]
    jb      L32
    jmp     L28
L28:
    mov     rcx,[rsp+90h]
    jmp     L29
L29:
    mov     rax,rcx
    jmp     L33
L30:
    lea     rcx,[image.k3192]
    mov     rdi,[rsp+68h]
    mov     rsi,rbx
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbx
    mov     rsi,[rsp+68h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+140h]
    mov     ecx,ecx
    mov     r12d,4
    mov     r13,rcx
    jmp     L24
L31:
    lea     rcx,[image.k3216]
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+134h]
    movzx   ecx,cx
    mov     rdx,r12
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r13,rcx
    add     r12,2
    mov     rbp,r12
    mov     [rsp+90h],r13
    jmp     L27
L32:
    lea     rcx,[image.k3320]
    mov     rdi,rbp
    mov     rsi,[rsp+60h]
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    cmp     rbp,[rsp+60h]
    setb    cl
    mov     [rsp+135h],cl
    mov     r11,[rsp+68h]
    lea     rcx,[r11+rbp]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    rbp,8
    mov     rdi,rcx
    mov     rsi,rbp
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+90h]
    mov     rax,rcx
L33:
    jmp     L2
L34:
    lea     r11,[image.k6632]
    mov     [rsp+98h],r11
    mov     r12d,0
    mov     rdi,[rsp+50h]
    mov     esi,1
    call    image.fn112
    jmp     L38
L35:
    mov     rdi,[rsp+48h]
    mov     esi,1
    call    image.fn112
    mov     rcx,rax
    jmp     L40
L36:
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    mov     rdx,rax
    jmp     L41
L37:
    test    r12b,r12b
    jne     L35
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L86
    jmp     L35
L38:
    test    al,al
    jne     L37
    jmp     L86
L39:
    test    r12b,r12b
    jne     L36
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L86
    jmp     L36
L40:
    test    cl,cl
    jne     L39
    jmp     L86
L41:
    test    dl,dl
    je      L86
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+150h]
    mov     r11,[rsp+30h]
    mov     rax,[r11+18h]
    xor     rax,r12
    mov     r11,[rsp+30h]
    mov     [r11+18h],rax
    mov     r10,[rsp+30h]
    mov     [rsp+150h],r10
    mov     rdi,[rsp+30h]
    call    image.fn208
    mov     rcx,[rsp+30h]
    mov     rdx,r12
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+38h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     rbp,[rsp+28h]
    jmp     L6
L42:
    mov     byte ptr [rsp+19Fh],0FFh
    lea     r11,[rsp+19Fh]
    mov     [rsp+0E8h],r11
    mov     rax,[rsp+1F8h]
    add     rax,1
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+208h]
    cmp     rax,0
    je      L43
    jmp     L44
L43:
    mov     ecx,0
    jmp     L47
L44:
    mov     rax,[rsp+208h]
    mov     r11d,8
    sub     r11,rax
    mov     [rsp+0E0h],r11
    mov     r10,[rsp+0E0h]
    mov     [rsp+190h],r10
    mov     edi,1
    mov     rsi,[rsp+0E0h]
    call    qword ptr [image.fn239.slot]
    mov     [rsp+0F0h],rax
    jmp     L64
L45:
    mov     rcx,[rsp+208h]
    mov     [rsp+190h],rcx
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    mov     rdx,[rsp+200h]
    or      rdx,rcx
    mov     [rsp+200h],rdx
    mov     r11d,1
    cmp     r11,[rsp+0E0h]
    jae     L46
    mov     rcx,[rsp+208h]
    add     rcx,1
    mov     [rsp+208h],rcx
    jmp     L85
L46:
    mov     rcx,[rsp+200h]
    mov     rdx,[rsp+1E0h]
    xor     rdx,rcx
    mov     [rsp+1E0h],rdx
    mov     rdi,[rsp+10h]
    call    image.fn208
    mov     rcx,[rsp+200h]
    mov     rdx,[rsp+1C8h]
    xor     rdx,rcx
    mov     [rsp+1C8h],rdx
    mov     qword ptr [rsp+208h],0
    mov     rcx,[rsp+0E0h]
L47:
    mov     edx,1
    sub     rdx,rcx
    mov     rsi,rdx
    and     rsi,7
    mov     [rsp+0C8h],rcx
    mov     [rsp+0C0h],rdx
    mov     [rsp+0B8h],rsi
    mov     r11,[rsp+0E8h]
    mov     [rsp+0A0h],r11
    mov     qword ptr [rsp+0A8h],1
    mov     r11,[rsp+10h]
    mov     [rsp+0B0h],r11
L48:
    mov     r10,[rsp+0C8h]
    mov     [rsp+190h],r10
    mov     rcx,[rsp+0C0h]
    sub     rcx,[rsp+0B8h]
    mov     r11,[rsp+0C8h]
    cmp     r11,rcx
    jae     L50
    mov     qword ptr [rsp+190h],0
    mov     r11,[rsp+0A0h]
    mov     r10,[rsp+0C8h]
    lea     r11,[r11+r10]
    mov     [rsp+0D8h],r11
    lea     r11,[rsp+190h]
    mov     [rsp+0D0h],r11
    jmp     L77
L49:
    mov     rbp,[rcx]
    xor     rbp,rdx
    mov     [rcx],rbp
    add     rsi,8
    mov     [rsp+0C8h],rsi
    mov     [rsp+0C0h],rdi
    mov     [rsp+0B8h],r8
    mov     [rsp+0A0h],r9
    mov     [rsp+0A8h],r15
    mov     [rsp+0B0h],rcx
    jmp     L48
L50:
    mov     r11d,3
    cmp     r11,[rsp+0B8h]
    jb      L52
    jmp     L51
L51:
    mov     ebx,0
    mov     r13d,0
    jmp     L53
L52:
    mov     dword ptr [rsp+170h],0
    mov     r11,[rsp+0A0h]
    mov     r10,[rsp+0C8h]
    lea     r15,[r11+r10]
    lea     rbp,[rsp+170h]
    jmp     L60
L53:
    mov     rcx,rbx
    add     rcx,1
    cmp     rcx,[rsp+0B8h]
    jb      L55
    jmp     L54
L54:
    mov     [rsp+0F8h],rbx
    mov     [rsp+100h],r13
    jmp     L56
L55:
    mov     word ptr [rsp+164h],0
    mov     rcx,[rsp+0C8h]
    add     rcx,rbx
    mov     r11,[rsp+0A0h]
    lea     r12,[r11+rcx]
    lea     r14,[rsp+164h]
    jmp     L61
L56:
    mov     r11,[rsp+0F8h]
    cmp     r11,[rsp+0B8h]
    jb      L58
    jmp     L57
L57:
    mov     rcx,[rsp+100h]
    jmp     L59
L58:
    mov     r11,[rsp+0C8h]
    add     r11,[rsp+0F8h]
    mov     [rsp+108h],r11
    jmp     L62
L59:
    jmp     L63
L60:
    lea     rcx,[image.k3192]
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+170h]
    mov     ecx,ecx
    mov     ebx,4
    mov     r13,rcx
    jmp     L53
L61:
    lea     rcx,[image.k3216]
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+164h]
    movzx   ecx,cx
    mov     rdx,rbx
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r13,rcx
    add     rbx,2
    mov     [rsp+0F8h],rbx
    mov     [rsp+100h],r13
    jmp     L56
L62:
    lea     rcx,[image.k3320]
    mov     rdi,[rsp+108h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    mov     r11,[rsp+108h]
    cmp     r11,[rsp+0A8h]
    setb    cl
    mov     [rsp+165h],cl
    mov     r11,[rsp+0A0h]
    mov     r10,[rsp+108h]
    lea     rcx,[r11+r10]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    mov     rdx,[rsp+0F8h]
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+100h]
L63:
    mov     r11,[rsp+0B0h]
    mov     [r11+38h],rcx
    mov     r11,[rsp+0B0h]
    mov     r10,[rsp+0B8h]
    mov     [r11+40h],r10
    jmp     L85
L64:
    mov     r11d,3
    cmp     r11,[rsp+0F0h]
    jb      L66
    jmp     L65
L65:
    mov     r12d,0
    mov     r13d,0
    jmp     L67
L66:
    mov     dword ptr [rsp+180h],0
    lea     rbx,[rsp+180h]
    jmp     L73
L67:
    mov     rcx,r12
    add     rcx,1
    cmp     rcx,[rsp+0F0h]
    jb      L69
    jmp     L68
L68:
    mov     rbp,r12
    mov     [rsp+110h],r13
    jmp     L70
L69:
    mov     word ptr [rsp+174h],0
    mov     r11,[rsp+0E8h]
    lea     r14,[r11+r12]
    lea     r15,[rsp+174h]
    jmp     L74
L70:
    cmp     rbp,[rsp+0F0h]
    jb      L75
    jmp     L71
L71:
    mov     rcx,[rsp+110h]
    jmp     L72
L72:
    mov     rax,rcx
    jmp     L76
L73:
    lea     rcx,[image.k3192]
    mov     rdi,[rsp+0E8h]
    mov     rsi,rbx
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbx
    mov     rsi,[rsp+0E8h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+180h]
    mov     ecx,ecx
    mov     r12d,4
    mov     r13,rcx
    jmp     L67
L74:
    lea     rcx,[image.k3216]
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+174h]
    movzx   ecx,cx
    mov     rdx,r12
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r13,rcx
    add     r12,2
    mov     rbp,r12
    mov     [rsp+110h],r13
    jmp     L70
L75:
    lea     rcx,[image.k3320]
    mov     rdi,rbp
    mov     esi,1
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    cmp     rbp,1
    setb    cl
    mov     [rsp+175h],cl
    mov     r11,[rsp+0E8h]
    lea     rcx,[r11+rbp]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    rbp,8
    mov     rdi,rcx
    mov     rsi,rbp
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+110h]
    mov     rax,rcx
L76:
    jmp     L45
L77:
    lea     rbx,[image.k6632]
    mov     r12d,0
    mov     rdi,[rsp+0D8h]
    mov     esi,1
    call    image.fn112
    jmp     L81
L78:
    mov     rdi,[rsp+0D0h]
    mov     esi,1
    call    image.fn112
    mov     rcx,rax
    jmp     L83
L79:
    mov     rdi,[rsp+0D8h]
    mov     rsi,[rsp+0D0h]
    mov     edx,1
    mov     ecx,8
    call    image.fn171
    mov     rdx,rax
    jmp     L84
L80:
    test    r12b,r12b
    jne     L78
    mov     r11,[rsp+0D8h]
    cmp     r11,0
    je      L88
    jmp     L78
L81:
    test    al,al
    jne     L80
    jmp     L88
L82:
    test    r12b,r12b
    jne     L79
    mov     r11,[rsp+0D0h]
    cmp     r11,0
    je      L88
    jmp     L79
L83:
    test    cl,cl
    jne     L82
    jmp     L88
L84:
    test    dl,dl
    je      L88
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+190h]
    mov     r11,[rsp+0B0h]
    mov     rax,[r11+18h]
    xor     rax,r12
    mov     r11,[rsp+0B0h]
    mov     [r11+18h],rax
    mov     r10,[rsp+0B0h]
    mov     [rsp+190h],r10
    mov     rdi,[rsp+0B0h]
    call    image.fn208
    mov     rcx,[rsp+0B0h]
    mov     rdx,r12
    mov     rsi,[rsp+0C8h]
    mov     rdi,[rsp+0C0h]
    mov     r8,[rsp+0B8h]
    mov     r9,[rsp+0A0h]
    mov     r15,[rsp+0A8h]
    jmp     L49
L85:
    lea     rax,[rsp+1C8h]
    mov     [rsp],rax
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFD90h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+1F8h]
    and     rax,0FFh
    shl     rax,38h
    mov     rcx,[rsp+200h]
    mov     r12,rax
    or      r12,rcx
    mov     rax,[rsp+1B8h]
    xor     rax,r12
    mov     [rsp+1B8h],rax
    lea     r13,[rsp+1A0h]
    mov     rdi,r13
    call    image.fn208
    mov     rax,[rsp+1A0h]
    xor     rax,r12
    mov     [rsp+1A0h],rax
    mov     rax,[rsp+1A8h]
    xor     rax,0FFh
    mov     [rsp+1A8h],rax
    mov     rdi,r13
    call    image.fn209
    mov     rax,[rsp+1A0h]
    mov     rcx,[rsp+1B0h]
    xor     rax,rcx
    mov     rcx,[rsp+1A8h]
    xor     rax,rcx
    mov     rcx,[rsp+1B8h]
    xor     rax,rcx
    mov     rbx,[rsp+260h]
    mov     r12,[rsp+250h]
    mov     r13,[rsp+240h]
    mov     r14,[rsp+230h]
    mov     r15,[rsp+220h]
    mov     rbp,[rsp+210h]
    add     rsp,278h
    ret
    jmp     L87
    jmp     L87
    jmp     L87
L86:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L87:
    call    qword ptr [image.sym30]
    ud2
    jmp     L89
    jmp     L89
    jmp     L89
L88:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L89:
    call    qword ptr [image.sym30]
    ud2
    jmp     L90
    jmp     L90
L90:
    mov     [rsp],rax
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFD90h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L91]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L91:
    .long   L92
L92:
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    sub     rsp,1B8h
    mov     [rsp+1A0h],rbx
    mov     [rsp+190h],r12
    mov     [rsp+180h],r13
    mov     [rsp+170h],r14
    mov     [rsp+160h],r15
    mov     [rsp+150h],rbp
    mov     rbx,rsi
    lea     rax,[rsp+108h]
    mov     rsi,rdi
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    lea     r11,[rsp+108h]
    mov     [rsp+60h],r11
    mov     rax,[rbx]
    mov     [rsp+0D0h],rax
    lea     r11,[rsp+0D0h]
    mov     [rsp+58h],r11
    mov     rax,[rsp+138h]
    add     rax,8
    mov     [rsp+138h],rax
    mov     rax,[rsp+148h]
    cmp     rax,0
    je      L0
    jmp     L1
L0:
    mov     ecx,0
    jmp     L4
L1:
    mov     rax,[rsp+148h]
    mov     r11d,8
    sub     r11,rax
    mov     [rsp+50h],r11
    mov     r10,[rsp+50h]
    mov     [rsp+0C0h],r10
    mov     edi,8
    mov     rsi,[rsp+50h]
    call    qword ptr [image.fn239.slot]
    mov     [rsp+68h],rax
    jmp     L21
L2:
    mov     rcx,[rsp+148h]
    mov     [rsp+0C0h],rcx
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    mov     rdx,[rsp+140h]
    or      rdx,rcx
    mov     [rsp+140h],rdx
    mov     r11d,8
    cmp     r11,[rsp+50h]
    jae     L3
    mov     rcx,[rsp+148h]
    add     rcx,8
    mov     [rsp+148h],rcx
    jmp     L42
L3:
    mov     rcx,[rsp+140h]
    mov     rdx,[rsp+120h]
    xor     rdx,rcx
    mov     [rsp+120h],rdx
    mov     rdi,[rsp+60h]
    call    image.fn208
    mov     rcx,[rsp+140h]
    mov     rdx,[rsp+108h]
    xor     rdx,rcx
    mov     [rsp+108h],rdx
    mov     qword ptr [rsp+148h],0
    mov     rcx,[rsp+50h]
L4:
    mov     edx,8
    sub     rdx,rcx
    mov     rsi,rdx
    and     rsi,7
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rdx
    mov     [rsp+10h],rsi
    mov     r11,[rsp+58h]
    mov     [rsp+18h],r11
    mov     qword ptr [rsp+20h],8
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
L5:
    mov     r10,[rsp+38h]
    mov     [rsp+0C0h],r10
    mov     rcx,[rsp+30h]
    sub     rcx,[rsp+10h]
    mov     r11,[rsp+38h]
    cmp     r11,rcx
    jae     L7
    mov     qword ptr [rsp+0C0h],0
    mov     r11,[rsp+18h]
    mov     r10,[rsp+38h]
    lea     r11,[r11+r10]
    mov     [rsp+48h],r11
    lea     r11,[rsp+0C0h]
    mov     [rsp+40h],r11
    jmp     L34
L6:
    mov     rbp,[rcx]
    xor     rbp,rdx
    mov     [rcx],rbp
    add     rsi,8
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdi
    mov     [rsp+10h],r8
    mov     [rsp+18h],r9
    mov     [rsp+20h],r15
    mov     [rsp+28h],rcx
    jmp     L5
L7:
    mov     r11d,3
    cmp     r11,[rsp+10h]
    jb      L9
    jmp     L8
L8:
    mov     r13d,0
    mov     ebx,0
    jmp     L10
L9:
    mov     dword ptr [rsp+0A0h],0
    mov     r11,[rsp+18h]
    mov     r10,[rsp+38h]
    lea     r15,[r11+r10]
    lea     rbp,[rsp+0A0h]
    jmp     L17
L10:
    mov     rcx,r13
    add     rcx,1
    cmp     rcx,[rsp+10h]
    jb      L12
    jmp     L11
L11:
    mov     [rsp+70h],r13
    mov     [rsp+78h],rbx
    jmp     L13
L12:
    mov     word ptr [rsp+94h],0
    mov     rcx,[rsp+38h]
    add     rcx,r13
    mov     r11,[rsp+18h]
    lea     r12,[r11+rcx]
    lea     r14,[rsp+94h]
    jmp     L18
L13:
    mov     r11,[rsp+70h]
    cmp     r11,[rsp+10h]
    jb      L15
    jmp     L14
L14:
    mov     rcx,[rsp+78h]
    jmp     L16
L15:
    mov     r11,[rsp+38h]
    add     r11,[rsp+70h]
    mov     [rsp+80h],r11
    jmp     L19
L16:
    jmp     L20
L17:
    lea     rcx,[image.k3192]
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+0A0h]
    mov     ecx,ecx
    mov     r13d,4
    mov     rbx,rcx
    jmp     L10
L18:
    lea     rcx,[image.k3216]
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+94h]
    movzx   ecx,cx
    mov     rdx,r13
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rbx,rcx
    add     r13,2
    mov     [rsp+70h],r13
    mov     [rsp+78h],rbx
    jmp     L13
L19:
    lea     rcx,[image.k3320]
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+20h]
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    mov     r11,[rsp+80h]
    cmp     r11,[rsp+20h]
    setb    cl
    mov     [rsp+95h],cl
    mov     r11,[rsp+18h]
    mov     r10,[rsp+80h]
    lea     rcx,[r11+r10]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    mov     rdx,[rsp+70h]
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+78h]
L20:
    mov     r11,[rsp+28h]
    mov     [r11+38h],rcx
    mov     r11,[rsp+28h]
    mov     r10,[rsp+10h]
    mov     [r11+40h],r10
    jmp     L42
L21:
    mov     r11d,3
    cmp     r11,[rsp+68h]
    jb      L23
    jmp     L22
L22:
    mov     r12d,0
    mov     r13d,0
    jmp     L24
L23:
    mov     dword ptr [rsp+0B0h],0
    lea     rbx,[rsp+0B0h]
    jmp     L30
L24:
    mov     rcx,r12
    add     rcx,1
    cmp     rcx,[rsp+68h]
    jb      L26
    jmp     L25
L25:
    mov     rbp,r12
    mov     [rsp+88h],r13
    jmp     L27
L26:
    mov     word ptr [rsp+0A4h],0
    mov     r11,[rsp+58h]
    lea     r14,[r11+r12]
    lea     r15,[rsp+0A4h]
    jmp     L31
L27:
    cmp     rbp,[rsp+68h]
    jb      L32
    jmp     L28
L28:
    mov     rcx,[rsp+88h]
    jmp     L29
L29:
    mov     rax,rcx
    jmp     L33
L30:
    lea     rcx,[image.k3192]
    mov     rdi,[rsp+58h]
    mov     rsi,rbx
    mov     edx,1
    mov     r8d,4
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,rbx
    mov     rsi,[rsp+58h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     ecx,[rsp+0B0h]
    mov     ecx,ecx
    mov     r12d,4
    mov     r13,rcx
    jmp     L24
L31:
    lea     rcx,[image.k3216]
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,1
    mov     r8d,2
    mov     r9,rcx
    mov     ecx,1
    call    image.fn165
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   ecx,word ptr [rsp+0A4h]
    movzx   ecx,cx
    mov     rdx,r12
    imul    rdx,8
    mov     rdi,rcx
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      r13,rcx
    add     r12,2
    mov     rbp,r12
    mov     [rsp+88h],r13
    jmp     L27
L32:
    lea     rcx,[image.k3320]
    mov     rdi,rbp
    mov     esi,8
    mov     rdx,rcx
    call    qword ptr [image.fn176.slot]
    cmp     rbp,8
    setb    cl
    mov     [rsp+0A5h],cl
    mov     r11,[rsp+58h]
    lea     rcx,[r11+rbp]
    movzx   ecx,byte ptr [rcx]
    movzx   ecx,cl
    imul    rbp,8
    mov     rdi,rcx
    mov     rsi,rbp
    call    ryo_hr_ShlW64
    mov     rcx,rax
    or      rcx,[rsp+88h]
    mov     rax,rcx
L33:
    jmp     L2
L34:
    lea     rbx,[image.k6632]
    mov     r12d,0
    mov     rdi,[rsp+48h]
    mov     esi,1
    call    image.fn112
    jmp     L38
L35:
    mov     rdi,[rsp+40h]
    mov     esi,1
    call    image.fn112
    mov     rcx,rax
    jmp     L40
L36:
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     edx,1
    mov     ecx,8
    call    qword ptr [image.fn171.slot]
    mov     rdx,rax
    jmp     L41
L37:
    test    r12b,r12b
    jne     L35
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L43
    jmp     L35
L38:
    test    al,al
    jne     L37
    jmp     L43
L39:
    test    r12b,r12b
    jne     L36
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L43
    jmp     L36
L40:
    test    cl,cl
    jne     L39
    jmp     L43
L41:
    test    dl,dl
    je      L43
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+0C0h]
    mov     r11,[rsp+28h]
    mov     rax,[r11+18h]
    xor     rax,r12
    mov     r11,[rsp+28h]
    mov     [r11+18h],rax
    mov     r10,[rsp+28h]
    mov     [rsp+0C0h],r10
    mov     rdi,[rsp+28h]
    call    image.fn208
    mov     rcx,[rsp+28h]
    mov     rdx,r12
    mov     rsi,[rsp+38h]
    mov     rdi,[rsp+30h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     r15,[rsp+20h]
    jmp     L6
L42:
    lea     rax,[rsp+108h]
    mov     [rsp],rax
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFE50h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+138h]
    and     rax,0FFh
    shl     rax,38h
    mov     rcx,[rsp+140h]
    mov     r12,rax
    or      r12,rcx
    mov     rax,[rsp+0F8h]
    xor     rax,r12
    mov     [rsp+0F8h],rax
    lea     r13,[rsp+0E0h]
    mov     rdi,r13
    call    image.fn208
    mov     rax,[rsp+0E0h]
    xor     rax,r12
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+0E8h]
    xor     rax,0FFh
    mov     [rsp+0E8h],rax
    mov     rdi,r13
    call    qword ptr [image.fn209.slot]
    mov     rax,[rsp+0E0h]
    mov     rcx,[rsp+0F0h]
    xor     rax,rcx
    mov     rcx,[rsp+0E8h]
    xor     rax,rcx
    mov     rcx,[rsp+0F8h]
    xor     rax,rcx
    mov     rbx,[rsp+1A0h]
    mov     r12,[rsp+190h]
    mov     r13,[rsp+180h]
    mov     r14,[rsp+170h]
    mov     r15,[rsp+160h]
    mov     rbp,[rsp+150h]
    add     rsp,1B8h
    ret
    jmp     L44
    jmp     L44
    jmp     L44
L43:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L44:
    call    qword ptr [image.sym30]
    ud2
    jmp     L45
    jmp     L45
L45:
    mov     [rsp],rax
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L46]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L46:
    .long   L47
L47:
    ret

fn <usize as std::cmp::Ord>::min
    sub     rsp,18h
    cmp     rsi,rdi
    setb    al
    test    al,al
    je      L0
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

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    sub     rsp,18h
    cmp     rdi,rsi
    jae     L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,1ADh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn core::core_arch::simd::Simd::<i8, 16>::splat
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+2Fh],sil
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0
    mov     ecx,0FFFFFFD0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0
    mov     ecx,0FFFFFFD0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rax,[sym0]
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rax
    mov     [rsp],rbx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,0
    mov     ecx,0FFFFFFE0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+20h]
    add     rsp,38h
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
    call    qword ptr [sym1]
    ud2

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,118h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     [rsp+98h],rax
    jmp     L11
L0:
    mov     rax,[rsp+0A0h]
    cmp     rax,0
    jne     L12
L1:
    jmp     L9
L2:
    test    al,al
    jne     L3
    jmp     L4
L3:
    mov     r12,r14
    jmp     L0
L4:
    mov     rax,[r14]
    jmp     L6
L5:
    mov     rdi,r14
    mov     rsi,rcx
    call    image.fn146
    jmp     L8
L6:
    sub     rax,r13
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     rcx,rax
    jmp     L5
L7:
    mov     rdi,rax
    call    qword ptr [image.sym22]
    mov     r12,r14
    jmp     L0
L8:
    lea     r13,[r13-10h]
    mov     rax,r13
    jmp     L7
L9:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    add     rsp,118h
    ret
L10:
    mov     r13,[rbx+18h]
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFF70h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+30h],r13
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF00h
    mov     ecx,28h
    call    ryo_h_Copy
    mov     r12,rbx
    jmp     L0
L11:
    mov     [rsp+90h],rax
    mov     [rsp+0A0h],rax
    mov     rcx,[rbx]
    mov     rdx,[rbx+8]
    add     rdx,1
    lea     rsi,[rsp+80h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rdx
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L10
L12:
    lea     rax,[rsp+80h]
    mov     rdi,rax
    call    fn2
    mov     rbx,rax
    mov     rax,[rsp+0A0h]
    sub     rax,1
    mov     [rsp+0A0h],rax
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L13]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L13:
    .long   L1
    .long   L16
    .long   L17
L14:
    mov     rax,[rax]
    mov     rdi,rax
    mov     esi,3
    call    ryo_hr_RemUW64
    cmp     rax,0
    setne   al
    jmp     L2
L15:
    mov     r13,rcx
    mov     r14,rdx
    jmp     L14
L16:
    mov     rax,rbx
    lea     rax,[rax-10h]
    mov     rcx,rbx
    mov     rdx,r12
    jmp     L15
L17:
    ud2
    jmp     L19
L18:
    mov     [rsp],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L19
    mov     rcx,rax
    mov     rax,rcx
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
    .long   L25
    .long   L26
    .long   L27
    .long   L28
L21:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-140h]
    mov     r11,[rdx-8]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-28h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+8]
    mov     [rdx-100h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E0h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L0
L22:
    ret
L23:
    ret
L24:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    movzx   r11d,byte ptr [rdx-0B1h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+18h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E0h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L2
L25:
    ret
L26:
    ret
L27:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+18h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E0h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L14
L28:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+18h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E0h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L15

fn hashbrown::raw::FullBucketsIndices::next_impl
    sub     rsp,0C8h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L1:
    .long   L3
    .long   L2
    .long   L6
L2:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    jmp     L4
L3:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+17h],1
    mov     rcx,[rbx]
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+28h],10h
    lea     rcx,[rcx+10h]
    mov     [rbx],rcx
    mov     [rsp+18h],rcx
    mov     [rsp+18h],rcx
    lea     rdx,[rsp+50h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    qword ptr [sym1]
    jmp     L5
L4:
    mov     eax,eax
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    mov     rdx,rcx
    sub     edx,1
    mov     [rsp+1Ah],dx
    and     ecx,edx
    mov     [rsp+1Ch],cx
    mov     [rsp+1Eh],cx
    mov     [rbx+18h],cx
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
L5:
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    add     rax,10h
    mov     [rsp+20h],rax
    mov     [rbx+8],rax
    jmp     L0
L6:
    ud2
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
L8:
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
    sub     rsp,0E8h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L1:
    .long   L8
    .long   L7
    .long   L17
L2:
    mov     rcx,[rax+8]
    mov     rdx,[rax+10h]
    mov     [rsp+18h],rdx
    cmp     rcx,rdx
    jb      L3
    jmp     L4
L3:
    mov     r13,rax
    jmp     L5
L4:
    mov     eax,0
    jmp     L6
L5:
    mov     rax,[r13+8]
    mov     [rsp+18h],rax
    lea     rcx,[rsp+60h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    jmp     L13
L6:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,0E8h
    ret
L7:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    jmp     L9
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+17h],1
    mov     r13,rbx
    jmp     L5
L9:
    mov     eax,eax
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    mov     rdx,rcx
    sub     edx,1
    mov     [rsp+1Ah],dx
    and     ecx,edx
    mov     [rsp+1Ch],cx
    mov     [rsp+1Eh],cx
    mov     [rbx+18h],cx
    mov     [rsp+18h],rax
    mov     rax,[rbx]
    jmp     L12
L10:
    mov     [rsp+10h],rcx
    mov     rax,rcx
    jmp     L6
L11:
    jmp     L10
L12:
    mov     rcx,[rsp+18h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L11
L13:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r13+18h],ax
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rax
    jmp     L16
L14:
    mov     [rsp+18h],rax
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L15:
    jmp     L14
L16:
    mov     rax,[rsp+18h]
    lea     rax,[rax-200h]
    mov     rcx,r13
    jmp     L15
L17:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L0
L20:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L2
L21:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     r13,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L5
L22:
    ret
L23:
    ret
L24:
    ret
L25:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L14
L26:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L15

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,178h
    mov     [rsp+0B0h],rbx
    mov     [rsp+0A0h],r12
    mov     [rsp+90h],r13
    mov     [rsp+80h],r14
    mov     [rsp+70h],r15
    mov     [rsp+60h],rbp
    mov     rbx,rsi
    mov     r12,rdx
    mov     [rsp+130h],rcx
    mov     [rsp],rdi
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA8h
    mov     edx,0FFFFFE90h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     r13d,1
L0:
    movzx   r14d,word ptr [rsp+30h]
    mov     rdi,r14
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L1:
    .long   L7
    .long   L6
    .long   L22
L2:
    sub     rcx,1
    mov     rbx,rcx
    mov     r12,rax
    mov     r13d,1
    jmp     L0
L3:
    jmp     L5
L4:
    mov     rax,[rsp+20h]
    mov     [rsp+40h],rax
    lea     rcx,[rsp+0C0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    jmp     L14
L5:
    mov     rax,r12
    mov     rbx,[rsp+0B0h]
    mov     r12,[rsp+0A0h]
    mov     r13,[rsp+90h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+70h]
    mov     rbp,[rsp+60h]
    add     rsp,178h
    ret
L6:
    mov     rdi,r14
    call    ryo_hr_CttzW16
    jmp     L8
L7:
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEC8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+40h],0
    mov     byte ptr [rsp+3Fh],1
    cmp     rbx,0
    je      L3
    mov     r15,rbx
    mov     rbp,r12
    mov     [rsp+10h],r13
    jmp     L4
L8:
    mov     eax,eax
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],1
    movzx   ecx,word ptr [rsp+30h]
    mov     [rsp+40h],cx
    mov     rdx,rcx
    sub     edx,1
    mov     [rsp+42h],dx
    and     ecx,edx
    mov     [rsp+44h],cx
    mov     [rsp+46h],cx
    mov     [rsp+30h],cx
    mov     [rsp+40h],rax
    mov     rax,[rsp+18h]
    jmp     L13
L9:
    mov     [rsp+38h],rcx
    jmp     L11
L10:
    mov     r8,[rsp+130h]
    mov     r11,[r8]
    mov     rdi,[rdi+8]
    add     rdi,rdx
    mov     rax,rdi
    mov     rcx,rsi
    jmp     L2
L11:
    lea     rcx,[rcx-10h]
    mov     rdi,rcx
    jmp     L10
L12:
    jmp     L9
L13:
    mov     rcx,[rsp+40h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    mov     rdx,r12
    mov     rsi,rbx
    jmp     L12
L14:
    mov     rax,[rsp+0C0h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+0C8h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [sym3]
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rsp+30h],ax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rax
    jmp     L17
L15:
    mov     [rsp+40h],rax
    mov     [rsp+18h],rax
    mov     rax,[rsp+20h]
    lea     rax,[rax+10h]
    mov     [rsp+20h],rax
    mov     rbx,rcx
    mov     r12,rdx
    mov     r13,rsi
    jmp     L0
L16:
    jmp     L15
L17:
    mov     rax,[rsp+40h]
    lea     rax,[rax-100h]
    mov     rcx,r15
    mov     rdx,rbp
    mov     rsi,[rsp+10h]
    jmp     L16
    mov     rcx,rax
    mov     rax,[rsp+10h]
    jmp     L23
L18:
    jmp     L21
L19:
    mov     [rsp],rcx
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    call    ryo_h_Resume
    ud2
L20:
    jmp     L19
L21:
    test    al,al
    jne     L20
    jmp     L19
L22:
    ud2
    mov     rdx,rax
    mov     rax,[rsp+10h]
    mov     rcx,rdx
L23:
    jmp     L18
  ; OSR entries
    lea     r11,[L24]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L24:
    .long   L25
    .long   L26
    .long   L27
    .long   L28
    .long   L29
    .long   L30
    .long   L31
    .long   L32
    .long   L33
    .long   L34
    .long   L35
L25:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    movzx   r11d,byte ptr [rdx-69h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-140h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L0
L26:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1B0h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L2
L27:
    ret
L28:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    movzx   r11d,byte ptr [rdx-69h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-160h],r11
    mov     r15,[rsp]
    mov     rbp,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L4
L29:
    ret
L30:
    ret
L31:
    ret
L32:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-140h],r11
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L33:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-0E0h]
    mov     [rsp],r11
    mov     r11,[rdx-38h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-140h],r11
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L12
L34:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-0C8h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    movzx   r11d,byte ptr [rdx-69h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
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
    mov     r11,[rsp+30h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L15
L35:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-0C8h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    movzx   r11d,byte ptr [rdx-69h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
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
    mov     r11,[rsp+30h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L16

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,0E8h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rdi
L0:
    movzx   r12d,word ptr [rbx+18h]
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L1:
    .long   L8
    .long   L7
    .long   L17
L2:
    mov     rcx,[rax+8]
    mov     rdx,[rax+10h]
    mov     [rsp+18h],rdx
    cmp     rcx,rdx
    jb      L3
    jmp     L4
L3:
    mov     r13,rax
    jmp     L5
L4:
    mov     eax,0
    jmp     L6
L5:
    mov     rax,[r13+8]
    mov     [rsp+18h],rax
    lea     rcx,[rsp+60h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    jmp     L13
L6:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,0E8h
    ret
L7:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    jmp     L9
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+17h],1
    mov     r13,rbx
    jmp     L5
L9:
    mov     eax,eax
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    mov     rdx,rcx
    sub     edx,1
    mov     [rsp+1Ah],dx
    and     ecx,edx
    mov     [rsp+1Ch],cx
    mov     [rsp+1Eh],cx
    mov     [rbx+18h],cx
    mov     [rsp+18h],rax
    mov     rax,[rbx]
    jmp     L12
L10:
    mov     [rsp+10h],rcx
    mov     rax,rcx
    jmp     L6
L11:
    jmp     L10
L12:
    mov     rcx,[rsp+18h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L11
L13:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r13+18h],ax
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rax
    jmp     L16
L14:
    mov     [rsp+18h],rax
    mov     [rcx],rax
    mov     rax,[rcx+8]
    lea     rax,[rax+10h]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L15:
    jmp     L14
L16:
    mov     rax,[rsp+18h]
    lea     rax,[rax-100h]
    mov     rcx,r13
    jmp     L15
L17:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L0
L20:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L2
L21:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     r13,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L5
L22:
    ret
L23:
    ret
L24:
    ret
L25:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L14
L26:
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
    mov     [rdx-0B0h],r13
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L15

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
    .long   L8
L1:
    mov     ecx,0
    jmp     L3
L2:
    mov     rax,[rbx]
    jmp     L4
L3:
    mov     rax,rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     [rsp+20h],rax
    jmp     L7
L5:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rcx,rax
    jmp     L3
L6:
    jmp     L5
L7:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L6
    jmp     L9
L8:
    ud2
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L12:
    ret
L13:
    ret
L14:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    jmp     L3
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,38h
    ret
L1:
    jmp     L8
L2:
    mov     rdi,r8
    jmp     L1
L3:
    mov     r11d,0
    sub     r11,rsi
    mov     rsi,r11
    mov     r11,rsi
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rsi,[rax]
    mov     r8,[rcx+8]
    mov     rcx,[rcx+10h]
    mov     r9,[rsi+8]
    mov     rsi,[rsi+10h]
    cmp     rcx,rsi
    jne     L5
    mov     [rsp+18h],rcx
    mov     [rsp+8],r8
    mov     [rsp],r9
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym68]
    mov     ecx,[rsp+24h]
    cmp     ecx,0
    sete    cl
    mov     rdx,rcx
    jmp     L6
L5:
    mov     edx,0
L6:
    jmp     L0
L7:
    jmp     L4
L8:
    lea     rdi,[rdi-20h]
    mov     rcx,rdi
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    sub     rsp,0F8h
    mov     [rsp+0E0h],rbx
    mov     [rsp+0D0h],r12
    mov     [rsp+0C0h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF10h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     [rsp+0B8h],rbx
    mov     [rsp+50h],r12
    mov     rax,[rbx+8]
    and     rax,r12
    mov     [rsp+58h],rax
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+48h],0
    mov     r13,rbx
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[r13]
    mov     [rsp+60h],rcx
    mov     [rsp+68h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.sym59]
    jmp     L2
L1:
    cmp     rax,1
    je      L3
    jmp     L12
L2:
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     [rsp+68h],rax
    lea     rsi,[rsp+40h]
    mov     [rsp+60h],rsi
    mov     rdi,r13
    mov     rdx,rsi
    mov     rsi,rax
    call    image.fn145
    mov     rsi,rdx
    mov     rcx,rsi
    mov     rdx,r13
    jmp     L1
L3:
    mov     [rsp+68h],rcx
    mov     [rsp+28h],rcx
    mov     rax,[rdx]
    lea     rax,[rax+rcx]
    mov     [rsp+20h],rax
    movzx   eax,byte ptr [rax]
    and     eax,80h
    cmp     al,0
    jne     L4
    mov     rax,[rdx]
    lea     rsi,[rsp+10h]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [image.sym19]
    jmp     L5
L4:
    jmp     L11
L5:
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [image.sym20]
    mov     r13,rax
    mov     rdi,r13
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L6]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L6:
    .long   L9
    .long   L8
    .long   L20
L7:
    mov     r11,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     rcx,rax
    jmp     L11
L8:
    mov     rdi,r13
    call    ryo_hr_CttzW16
    jmp     L10
L9:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L7
L10:
    mov     eax,eax
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    jmp     L7
L11:
    jmp     L13
L12:
    mov     rax,[rdx+8]
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
    mov     r13,rdx
    jmp     L0
L13:
    mov     rax,[rbx]
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rax
    lea     rax,[rax+rcx]
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rax
    movzx   edx,byte ptr [rax]
    shr     r12,39h
    mov     [rsp+0B0h],r12
    and     r12,7Fh
    mov     [rsp+0A8h],r12
    mov     [rsp+0BEh],r12b
    mov     [rsp+0BFh],r12b
    mov     rsi,rcx
    sub     rsi,10h
    mov     [rsp+0A0h],rsi
    mov     rdi,[rbx+8]
    and     rsi,rdi
    mov     [rsp+0A8h],rsi
    add     rsi,10h
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rax
    mov     [rax],r12b
    mov     rax,[rbx]
    lea     rax,[rax+rsi]
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rax
    mov     [rax],r12b
    mov     rax,[rbx]
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+0A0h],rax
    jmp     L16
L14:
    mov     r12,[rsp+0A8h]
    mov     rax,rdx
    and     eax,1
    mov     [rsp+0B6h],al
    cmp     al,0
    setne   al
    mov     [rsp+0B7h],al
    movzx   eax,al
    mov     [rsp+0B8h],rax
    mov     rsi,[rbx+10h]
    sub     rsi,rax
    mov     [rbx+10h],rsi
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L19
L15:
    jmp     L14
L16:
    mov     eax,0
    sub     rax,rcx
    mov     rcx,[rsp+0A0h]
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+0A8h],rcx
    jmp     L15
L17:
    mov     [rsp],rax
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF10h
    mov     edx,0
    mov     ecx,0FFFFFFB0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,r12
    mov     rbx,[rsp+0E0h]
    mov     r12,[rsp+0D0h]
    mov     r13,[rsp+0C0h]
    add     rsp,0F8h
    ret
L18:
    jmp     L17
L19:
    mov     rax,r12
    lea     rax,[rax-20h]
    jmp     L18
L20:
    ud2
    mov     rbx,rax
    jmp     L22
L21:
    mov     [rsp],rbx
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF10h
    call    ryo_h_Resume
    ud2
L22:
    lea     rax,[rsp+78h]
    mov     rdi,rax
    call    qword ptr [image.fn51.slot]
    jmp     L21
    call    qword ptr [sym2]
    ud2
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
    .long   L30
L24:
    ret
L25:
    ret
L26:
    ret
L27:
    ret
L28:
    ret
L29:
    ret
L30:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jb      L2
    jmp     L1
L0:
    mov     rdi,rax
    mov     rsi,0FFFFFFFFFFFFFFFFh
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
L1:
    add     rsp,18h
    ret
L2:
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    jmp     L0
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L4:
    jmp     L3
    jmp     L4
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     rax,[rdi]
    mov     rcx,[rsi]
    jmp     L3
L0:
    mov     rax,rsi
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    add     rsp,0A8h
    ret
L1:
    jmp     L6
L2:
    mov     rdi,r8
    jmp     L1
L3:
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rcx,[rax]
    lea     rdx,[rsp+38h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    image.fn215
    lea     r12,[rsp+38h]
    mov     rcx,[rbx+8]
    mov     rdx,[rbx+10h]
    mov     rdi,r12
    mov     rsi,rcx
    call    image.fn197
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rcx,[rsp+0Fh]
    mov     rdi,r12
    mov     rsi,rcx
    mov     edx,1
    call    image.fn197
    lea     rcx,[rsp+38h]
    mov     [rsp],rcx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF60h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rcx,[rsp+68h]
    and     rcx,0FFh
    shl     rcx,38h
    mov     rdx,[rsp+70h]
    mov     rbx,rcx
    or      rbx,rdx
    mov     rcx,[rsp+28h]
    xor     rcx,rbx
    mov     [rsp+28h],rcx
    lea     r12,[rsp+10h]
    mov     rdi,r12
    call    image.fn208
    mov     rcx,[rsp+10h]
    xor     rcx,rbx
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+18h]
    xor     rcx,0FFh
    mov     [rsp+18h],rcx
    mov     rdi,r12
    call    image.fn209
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+20h]
    xor     rcx,rdx
    mov     rdx,[rsp+18h]
    xor     rcx,rdx
    mov     rdx,[rsp+28h]
    xor     rcx,rdx
    mov     rsi,rcx
    jmp     L0
L5:
    mov     rbx,rcx
    jmp     L4
L6:
    lea     rdi,[rdi-20h]
    mov     rcx,rdi
    jmp     L5
    jmp     L7
    jmp     L7
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
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
    .long   L13
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

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx]
    jmp     L1
L0:
    mov     rdi,rbx
    mov     rsi,rcx
    call    qword ptr [image.fn146.slot]
    jmp     L4
L1:
    sub     rax,r12
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     rcx,rax
    jmp     L0
L2:
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L5
L3:
    jmp     L2
L4:
    lea     r12,[r12-10h]
    mov     rax,r12
    jmp     L3
L5:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
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
    .long   L8
L1:
    mov     ecx,0
    jmp     L3
L2:
    mov     rax,[rbx]
    jmp     L4
L3:
    mov     rax,rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     [rsp+20h],rax
    jmp     L7
L5:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rcx,rax
    jmp     L3
L6:
    jmp     L5
L7:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L6
    jmp     L9
L8:
    ud2
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L12:
    ret
L13:
    ret
L14:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    jmp     L3
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,18h
    ret
L1:
    jmp     L6
L2:
    mov     rdi,r8
    jmp     L1
L3:
    mov     r11d,0
    sub     r11,rsi
    mov     rsi,r11
    mov     r11,rsi
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rsi,[rax]
    mov     rsi,[rsi]
    mov     rcx,[rcx]
    cmp     rsi,rcx
    sete    cl
    mov     rdx,rcx
    jmp     L0
L5:
    jmp     L4
L6:
    lea     rdi,[rdi-10h]
    mov     rcx,rdi
    jmp     L5
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
    .long   L8
L1:
    mov     ecx,0
    jmp     L3
L2:
    mov     rax,[rbx]
    jmp     L4
L3:
    mov     rax,rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    mov     [rsp+20h],rax
    jmp     L7
L5:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rcx,rax
    jmp     L3
L6:
    jmp     L5
L7:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L6
    jmp     L9
L8:
    ud2
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
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
    ret
L12:
    ret
L13:
    ret
L14:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rcx,[rcx]
    jmp     L3
L0:
    mov     rax,rdx
    movzx   eax,al
    add     rsp,18h
    ret
L1:
    jmp     L6
L2:
    mov     rdi,r8
    jmp     L1
L3:
    mov     r11d,0
    sub     r11,rsi
    mov     rsi,r11
    mov     r11,rsi
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rsi,[rax]
    mov     rcx,[rcx]
    mov     rsi,[rsi]
    cmp     rcx,rsi
    sete    cl
    mov     rdx,rcx
    jmp     L0
L5:
    jmp     L4
L6:
    lea     rdi,[rdi-10h]
    mov     rcx,rdi
    jmp     L5
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

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     [rsp+78h],rbx
    mov     [rsp+50h],r12
    mov     rax,[rbx+8]
    and     rax,r12
    mov     [rsp+58h],rax
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+48h],0
    mov     r15,rbx
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[r15]
    mov     [rsp+60h],rcx
    mov     [rsp+68h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+60h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.sym59]
    jmp     L2
L1:
    cmp     rax,1
    je      L3
    jmp     L11
L2:
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     [rsp+68h],rax
    lea     rsi,[rsp+40h]
    mov     [rsp+60h],rsi
    mov     rdi,r15
    mov     rdx,rsi
    mov     rsi,rax
    call    image.fn145
    mov     rsi,rdx
    mov     rcx,rsi
    mov     rdx,r15
    jmp     L1
L3:
    mov     [rsp+68h],rcx
    mov     [rsp+28h],rcx
    mov     rax,[rdx]
    lea     rax,[rax+rcx]
    mov     [rsp+20h],rax
    movzx   eax,byte ptr [rax]
    and     eax,80h
    cmp     al,0
    jne     L4
    mov     rax,[rdx]
    lea     rsi,[rsp+10h]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [image.sym19]
    jmp     L5
L4:
    jmp     L12
L5:
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [image.sym20]
    mov     r15,rax
    mov     rdi,r15
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L6]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L6:
    .long   L9
    .long   L8
    .long   L19
L7:
    mov     r11,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     rcx,rax
    jmp     L12
L8:
    mov     rdi,r15
    call    ryo_hr_CttzW16
    jmp     L10
L9:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L7
L10:
    mov     eax,eax
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    jmp     L7
L11:
    mov     rax,[rdx+8]
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
    mov     r15,rdx
    jmp     L0
L12:
    mov     rax,[rbx]
    lea     rax,[rax+rcx]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rax
    movzx   edx,byte ptr [rax]
    shr     r12,39h
    mov     [rsp+70h],r12
    and     r12,7Fh
    mov     [rsp+7Eh],r12b
    mov     [rsp+7Fh],r12b
    mov     rsi,rcx
    sub     rsi,10h
    mov     rdi,[rbx+8]
    and     rsi,rdi
    add     rsi,10h
    mov     [rsp+70h],rsi
    mov     [rax],r12b
    mov     rax,[rbx]
    lea     rax,[rax+rsi]
    mov     [rax],r12b
    mov     rax,[rbx]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rax
    mov     rax,[rsp+70h]
    jmp     L15
L13:
    mov     rsi,rdx
    and     esi,1
    mov     [rsp+76h],sil
    cmp     sil,0
    setne   sil
    mov     [rsp+77h],sil
    movzx   esi,sil
    mov     [rsp+78h],rsi
    mov     rdi,[rbx+10h]
    sub     rdi,rsi
    mov     [rbx+10h],rdi
    mov     [rsp+70h],r13
    mov     [rsp+78h],r14
    jmp     L18
L14:
    mov     r12,rsi
    jmp     L13
L15:
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rsi,rax
    jmp     L14
L16:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0
    mov     ecx,0FFFFFFA0h
    call    ryo_h_StoreW128
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,r12
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    add     rsp,0D8h
    ret
L17:
    jmp     L16
L18:
    mov     rax,r12
    lea     rax,[rax-10h]
    jmp     L17
L19:
    ud2
    jmp     L21
L20:
    mov     [rsp],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
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
    .long   L27
    .long   L28
L23:
    ret
L24:
    ret
L25:
    ret
L26:
    ret
L27:
    ret
L28:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
    sub     rsp,18h
    mov     rax,[rdi+10h]
    cmp     rax,rsi
    jb      L2
    jmp     L1
L0:
    mov     rdi,rax
    mov     rsi,0FFFFFFFFFFFFFFFFh
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
L1:
    add     rsp,18h
    ret
L2:
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    jmp     L0
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L4:
    jmp     L3
    jmp     L4
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
    sub     rsp,0B8h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     rax,[rdi]
    mov     rcx,[rsi]
    jmp     L3
L0:
    mov     rax,rsi
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    add     rsp,0B8h
    ret
L1:
    jmp     L6
L2:
    mov     rdi,r8
    jmp     L1
L3:
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     r11,rdx
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rcx,[rax]
    lea     rdx,[rsp+48h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    image.fn215
    lea     rcx,[rsp+48h]
    mov     rdx,[rbx]
    mov     [rsp+10h],rdx
    lea     rdx,[rsp+10h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     edx,8
    call    qword ptr [image.fn197.slot]
    lea     rcx,[rsp+48h]
    mov     [rsp],rcx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF50h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rcx,[rsp+78h]
    and     rcx,0FFh
    shl     rcx,38h
    mov     rdx,[rsp+80h]
    mov     rbx,rcx
    or      rbx,rdx
    mov     rcx,[rsp+38h]
    xor     rcx,rbx
    mov     [rsp+38h],rcx
    lea     r12,[rsp+20h]
    mov     rdi,r12
    call    image.fn208
    mov     rcx,[rsp+20h]
    xor     rcx,rbx
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+28h]
    xor     rcx,0FFh
    mov     [rsp+28h],rcx
    mov     rdi,r12
    call    image.fn209
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+30h]
    xor     rcx,rdx
    mov     rdx,[rsp+28h]
    xor     rcx,rdx
    mov     rdx,[rsp+38h]
    xor     rcx,rdx
    mov     rsi,rcx
    jmp     L0
L5:
    mov     rbx,rcx
    jmp     L4
L6:
    lea     rdi,[rdi-10h]
    mov     rcx,rdi
    jmp     L5
    jmp     L7
    jmp     L7
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
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
    .long   L13
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

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    sub     rsp,0D8h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     rbx,rdi
    mov     rax,[rbx+18h]
    mov     [rsp+78h],rax
    cmp     rax,0
    je      L1
    mov     rax,[rbx]
    mov     [rsp+70h],rax
    jmp     L3
L0:
    mov     rax,[rsp+78h]
    cmp     rax,0
    jne     L4
L1:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    add     rsp,0D8h
    ret
L2:
    mov     r12,[rbx+18h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+30h],r12
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF40h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L3:
    mov     [rsp+68h],rax
    mov     [rsp+78h],rax
    mov     rcx,[rbx]
    mov     rdx,[rbx+8]
    add     rdx,1
    lea     rsi,[rsp+58h]
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rcx,rdx
    mov     rdx,rax
    call    qword ptr [fn0.slot]
    jmp     L2
L4:
    lea     rax,[rsp+58h]
    mov     rdi,rax
    call    fn1
    mov     rbx,rax
    mov     rax,[rsp+78h]
    sub     rax,1
    mov     [rsp+78h],rax
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L5]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L5:
    .long   L1
    .long   L8
    .long   L11
L6:
    mov     rdi,r12
    call    qword ptr [image.sym31]
    mov     rdi,r12
    call    qword ptr [image.sym32]
    jmp     L0
L7:
    mov     r12,rax
    jmp     L6
L8:
    lea     rbx,[rbx-20h]
    mov     rax,rbx
    jmp     L7
    mov     rbx,rax
    jmp     L10
L9:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L10:
    mov     rdi,r12
    call    qword ptr [image.sym32]
    jmp     L9
    call    qword ptr [image.sym21]
    ud2
L11:
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
L13:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-20h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+20h],r11
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A0h],r11
    lea     rsp,[rsp+30h]
    jmp     L0
L14:
    ret
L15:
    ret
L16:
    ret
L17:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-28h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A0h],r11
    mov     r12,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L6
L18:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-90h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-28h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     [rdx-80h],rbx
    mov     [rdx-90h],r12
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A0h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L7

fn hashbrown::raw::RawTableInner::erase
    sub     rsp,0E8h
    mov     [rsp+0D0h],rbx
    mov     [rsp+0C0h],r12
    mov     [rsp+0B0h],r13
    mov     [rsp+0A0h],r14
    mov     [rsp+90h],r15
    mov     [rsp+80h],rbp
    mov     rbx,rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    sub     rax,10h
    mov     [rsp+48h],rax
    mov     rcx,[rbx+8]
    mov     [rsp+40h],rcx
    and     rax,rcx
    mov     rcx,[rbx]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    lea     rcx,[rcx+rax]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rcx
    lea     rax,[rsp+20h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L3
L0:
    mov     eax,80h
    jmp     L2
L1:
    mov     rax,[rbx+10h]
    add     rax,1
    mov     [rsp+60h],rax
    mov     [rbx+10h],rax
    mov     eax,0FFh
L2:
    mov     rcx,[rsp+10h]
    sub     rcx,10h
    mov     [rsp+58h],rcx
    mov     rdx,[rbx+8]
    mov     [rsp+50h],rdx
    and     rcx,rdx
    mov     [rsp+40h],rcx
    add     rcx,10h
    mov     [rsp+48h],rcx
    mov     rcx,[rbx]
    mov     [rsp+50h],rcx
    mov     r10,[rsp+10h]
    lea     rcx,[rcx+r10]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    mov     [rcx],al
    mov     rcx,[rbx]
    mov     [rsp+50h],rcx
    mov     rdx,[rsp+48h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+58h],rcx
    mov     [rsp+40h],rcx
    mov     [rcx],al
    mov     rax,[rbx+18h]
    sub     rax,1
    mov     [rsp+60h],rax
    mov     [rbx+18h],rax
    mov     rbx,[rsp+0D0h]
    mov     r12,[rsp+0C0h]
    mov     r13,[rsp+0B0h]
    mov     r14,[rsp+0A0h]
    mov     r15,[rsp+90h]
    mov     rbp,[rsp+80h]
    add     rsp,0E8h
    ret
L3:
    lea     r13,[rsp+50h]
    mov     rdi,r13
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+20h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+78h],rax
    lea     r14,[rsp+40h]
    lea     r15,[rsp+60h]
    lea     rbp,[rsp+70h]
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    call    qword ptr [sym2]
    mov     rax,[rsp+40h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+68h],rax
    mov     rdi,r15
    call    qword ptr [sym3]
    mov     [rsp+5Ch],eax
    mov     r12,rax
    mov     rax,[rbx]
    mov     [rsp+58h],rax
    mov     [rsp+40h],rax
    mov     r10,[rsp+10h]
    lea     rax,[rax+r10]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    mov     rdi,r13
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+30h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+78h],rax
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    call    qword ptr [sym2]
    mov     rax,[rsp+40h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+68h],rax
    mov     rdi,r15
    call    qword ptr [sym3]
    mov     [rsp+5Ch],eax
    mov     r13,rax
    mov     rdi,r12
    call    ryo_hr_CtlzW16
    mov     [rsp+5Ch],eax
    mov     r12d,eax
    mov     [rsp+40h],r12
    mov     rdi,r13
    call    ryo_hr_CttzW16
    mov     [rsp+54h],eax
    mov     eax,eax
    mov     [rsp+58h],rax
    add     r12,rax
    mov     [rsp+48h],r12
    cmp     r12,10h
    jb      L1
    jmp     L0
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

fn hashbrown::raw::RawTableInner::find_inner
    sub     rsp,188h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rax,rsi
    shr     rax,39h
    and     rax,7Fh
    mov     [rsp+70h],rsi
    mov     r8,[rdi+8]
    mov     [rsp+88h],r8
    and     rsi,r8
    mov     [rsp+78h],rsi
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,rax
    mov     r14,rcx
    mov     r15,rdx
    mov     qword ptr [rsp+58h],0
L0:
    mov     [rsp+70h],rbx
    mov     rax,[r12]
    mov     [rsp+80h],rax
    mov     [rsp+88h],rax
    lea     rax,[rax+rbx]
    mov     [rsp+78h],rax
    mov     [rsp+70h],rax
    lea     rcx,[rsp+110h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    jmp     L5
L1:
    mov     rdi,[rsp+10h]
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L2]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L2:
    .long   L7
    .long   L6
    .long   L14
L3:
    test    al,al
    jne     L10
    jmp     L11
L4:
    mov     rax,[rsp+60h]
    mov     r9,[rsp+68h]
    mov     rdx,r9
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,188h
    ret
L5:
    lea     rax,[rsp+80h]
    mov     rdi,rax
    mov     rsi,r13
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+110h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+118h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+80h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+88h]
    mov     [rsp+0A8h],rax
    lea     rax,[rsp+70h]
    lea     rbp,[rsp+90h]
    lea     r9,[rsp+0A0h]
    mov     rdi,rax
    mov     rsi,rbp
    mov     rdx,r9
    call    qword ptr [sym2]
    mov     rax,[rsp+70h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+78h]
    mov     [rsp+98h],rax
    mov     rdi,rbp
    call    qword ptr [sym3]
    mov     [rsp+8Ch],eax
    mov     [rsp+10h],rax
    mov     [rsp+18h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+28h],r14
    mov     [rsp+30h],r15
    mov     r11,[rsp+58h]
    mov     [rsp+38h],r11
    mov     [rsp+40h],r13
    jmp     L1
L6:
    mov     rdi,[rsp+10h]
    call    ryo_hr_CttzW16
    jmp     L8
L7:
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+88h],0
    lea     r9,[rsp+80h]
    mov     rdi,r9
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    jmp     L9
L8:
    mov     eax,eax
    mov     [rsp+88h],rax
    mov     qword ptr [rsp+80h],1
    mov     r10,[rsp+10h]
    mov     [rsp+8Eh],r10w
    mov     r9,[rsp+10h]
    sub     r9d,1
    mov     rbx,[rsp+10h]
    and     ebx,r9d
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+70h],1
    mov     [rsp+88h],rax
    add     rax,[rsp+18h]
    mov     r11,[rsp+20h]
    mov     r9,[r11+8]
    and     rax,r9
    mov     [rsp+80h],rax
    mov     r11,[rsp+28h]
    mov     r9,[r11+20h]
    mov     rdi,[rsp+30h]
    mov     rsi,rax
    mov     rax,r9
    call    rax
    mov     rcx,rbx
    mov     rdx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     r8,[rsp+30h]
    mov     r11,[rsp+38h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+48h],r11
    jmp     L3
L9:
    mov     rax,[rsp+110h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+118h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+80h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+88h]
    mov     [rsp+0A8h],rax
    lea     rax,[rsp+70h]
    lea     rbx,[rsp+90h]
    lea     r9,[rsp+0A0h]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,r9
    call    qword ptr [sym2]
    mov     rax,[rsp+70h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+78h]
    mov     [rsp+98h],rax
    mov     rdi,rbx
    call    qword ptr [sym3]
    cmp     ax,0
    je      L13
    jmp     L12
L10:
    mov     rax,[rsp+80h]
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+60h],1
    jmp     L4
L11:
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdi
    mov     [rsp+30h],r8
    mov     r11,[rsp+50h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+40h],r11
    jmp     L1
L12:
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFEE0h
    lea     rdx,[k8]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L4
L13:
    mov     r11,[rsp+20h]
    mov     rax,[r11+8]
    mov     [rsp+78h],rax
    mov     rcx,[rsp+38h]
    add     rcx,10h
    mov     [rsp+70h],rcx
    mov     rdx,[rsp+18h]
    add     rdx,rcx
    and     rdx,rax
    mov     rbx,rdx
    mov     r12,[rsp+20h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     [rsp+58h],rcx
    jmp     L0
L14:
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
L16:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-1F0h]
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
    mov     [rdx-128h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L0
L17:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-200h]
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
    mov     r11,[rsp]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-168h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-140h],r11
    lea     rsp,[rsp+80h]
    jmp     L1
L18:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-200h]
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
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-138h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+80h]
    jmp     L3
L19:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,0C8h
    mov     [rsp+50h],rbx
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
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+40h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L3
L1:
    cmp     rax,1
    je      L4
    jmp     L13
L2:
    mov     rbx,[rsp+50h]
    add     rsp,0C8h
    ret
L3:
    mov     rsi,[rsp+40h]
    mov     [rsp+60h],rsi
    mov     rsi,[rsp+48h]
    mov     [rsp+68h],rsi
    lea     rsi,[rsp+60h]
    mov     [rsp+48h],rsi
    lea     rdi,[rsp+70h]
    mov     [rsp+40h],rdi
    mov     rdx,rdi
    mov     rdi,rbx
    call    fn1
    mov     rsi,rax
    mov     rdi,rdx
    mov     rax,rsi
    mov     rcx,rdi
    mov     rdx,rbx
    jmp     L1
L4:
    mov     [rsp+48h],rcx
    mov     [rsp+28h],rcx
    mov     rsi,[rdx]
    lea     rsi,[rsi+rcx]
    mov     [rsp+20h],rsi
    movzx   esi,byte ptr [rsi]
    and     esi,80h
    cmp     sil,0
    jne     L5
    mov     rsi,[rdx]
    lea     rdi,[rsp+10h]
    call    qword ptr [image.sym19]
    jmp     L6
L5:
    mov     rax,rcx
    jmp     L12
L6:
    mov     rcx,[rsp+10h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+18h]
    mov     [rsp+38h],rcx
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    call    qword ptr [image.sym20]
    mov     rcx,rax
    mov     rbx,rcx
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     rcx,rax
    mov     ecx,ecx
    mov     rdi,rcx
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     rcx,rax
    mov     r10,rcx
    lea     r11,[L7]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L7:
    .long   L10
    .long   L9
    .long   L14
L8:
    mov     r11,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     rax,rcx
    jmp     L12
L9:
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     rcx,rax
    jmp     L11
L10:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L8
L11:
    mov     ecx,ecx
    mov     [rsp+28h],rcx
    mov     qword ptr [rsp+20h],1
    jmp     L8
L12:
    jmp     L2
L13:
    mov     rax,[rdx+8]
    mov     [rsp+48h],rax
    mov     rcx,[rsp+78h]
    add     rcx,10h
    mov     [rsp+78h],rcx
    mov     [rsp+40h],rcx
    mov     rsi,[rsp+70h]
    add     rsi,rcx
    mov     [rsp+70h],rsi
    and     rsi,rax
    mov     [rsp+70h],rsi
    mov     rbx,rdx
    jmp     L0
L14:
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
L16:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-70h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L17:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-70h]
    mov     [rsp],r11
    mov     r11,[rdx-68h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     [rdx-70h],rbx
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L1
L18:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     rbx,rdi
    mov     r12,rdx
    mov     [rsp],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF70h
    mov     ecx,0
    call    ryo_h_LoadW128
    mov     rax,[rsp+40h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [sym0]
    jmp     L1
L0:
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rax,rcx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    add     rsp,98h
    ret
L1:
    mov     r13,rax
    mov     [rsp],r13
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFCCh
    mov     edx,0FFFFFF70h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    mov     eax,[rsp+5Ch]
    mov     eax,eax
    mov     [rsp+48h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    mov     edx,0
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L2]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L2:
    .long   L4
    .long   L3
    .long   L7
L3:
    mov     [rsp],r13
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFCCh
    mov     edx,0FFFFFF70h
    call    ryo_h_CttzW16
    mov     eax,[rsp+5Ch]
    jmp     L5
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rcx,[rsp+28h]
    mov     [rsp+48h],rcx
    jmp     L6
L5:
    mov     eax,eax
    mov     [rsp+40h],rax
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+28h],1
    mov     qword ptr [rsp+48h],1
    mov     rcx,[r12]
    add     rcx,rax
    mov     [rsp+40h],rcx
    mov     rax,[rbx+8]
    and     rcx,rax
    mov     [rsp+48h],rcx
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+10h],1
    jmp     L0
L6:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L0
L7:
    ud2
  ; OSR entries
    lea     r11,[L8]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L8:
    .long   L9
L9:
    ret

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    sub     rsp,498h
    mov     [rsp+230h],rbx
    mov     [rsp+220h],r12
    mov     [rsp+210h],r13
    mov     [rsp+200h],r14
    mov     [rsp+1F0h],r15
    mov     [rsp+1E0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     [rsp+38h],r8
    mov     r15,[rsp+4A8h]
    mov     r11,[rsp+4A0h]
    mov     [rsp+30h],r11
    lea     rax,[rsp+2B0h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rcx,r15
    mov     r8,rdx
    mov     rdx,[rsp+30h]
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    jmp     L25
L0:
    lea     rax,[rsp+340h]
    mov     [rsp+328h],rax
    mov     rax,[rsp+350h]
    mov     [rsp+320h],rax
    cmp     rax,0
    je      L29
    jmp     L30
L1:
    mov     rax,[rsp+338h]
    mov     [rsp+320h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+308h],r10
    mov     [rsp+310h],rax
    mov     r11,[rsp+18h]
    mov     rcx,[r11+28h]
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    mov     rax,rcx
    call    rax
    mov     [rsp+318h],rax
    jmp     L3
L2:
    mov     r11,[rsp+10h]
    mov     rax,[r11+18h]
    mov     [rsp+358h],rax
    mov     rcx,[rsp+388h]
    sub     rcx,rax
    mov     [rsp+388h],rcx
    mov     r11,[rsp+10h]
    mov     rax,[r11+18h]
    mov     [rsp+358h],rax
    mov     [rsp+390h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+358h],r10
    lea     rax,[rsp+378h]
    mov     [rsp+350h],rax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFDB0h
    mov     edx,0FFFFFEC8h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     qword ptr [rsp],20h
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFB70h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFEC0h
    mov     edx,0
    mov     ecx,0FFFFFDB0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    jmp     L40
L3:
    lea     rax,[rsp+378h]
    mov     [rsp+310h],rax
    mov     rcx,[rsp+318h]
    mov     [rsp+110h],rcx
    mov     rdx,[rsp+380h]
    and     rcx,rdx
    mov     [rsp+118h],rcx
    mov     [rsp+100h],rcx
    mov     qword ptr [rsp+108h],0
    mov     rbp,rax
L4:
    mov     rax,[rsp+100h]
    mov     rcx,[rbp]
    mov     [rsp+120h],rcx
    mov     [rsp+128h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+120h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.sym59]
    jmp     L6
L5:
    cmp     rax,1
    je      L14
    jmp     L22
L6:
    mov     rax,[rsp+120h]
    mov     [rsp+110h],rax
    mov     rax,[rsp+128h]
    mov     [rsp+118h],rax
    lea     rax,[rsp+110h]
    mov     [rsp+128h],rax
    lea     rsi,[rsp+100h]
    mov     [rsp+120h],rsi
    mov     [rsp],rax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC20h
    mov     edx,0FFFFFB70h
    mov     ecx,0
    call    ryo_h_LoadW128
    mov     rax,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+0C8h],rax
    lea     rax,[rsp+0C0h]
    mov     rdi,rax
    call    qword ptr [sym4]
    jmp     L8
L7:
    mov     rsi,[rsp+80h]
    mov     rdi,[rsp+88h]
    mov     rax,rsi
    mov     rcx,rdi
    mov     rdx,rbp
    jmp     L5
L8:
    mov     r14,rax
    mov     [rsp],r14
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC3Ch
    mov     edx,0FFFFFB70h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    mov     eax,[rsp+0CCh]
    mov     eax,eax
    mov     [rsp+0B8h],rax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC28h
    mov     edx,0
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L9]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L9:
    .long   L11
    .long   L10
    .long   L41
L10:
    mov     [rsp],r14
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC3Ch
    mov     edx,0FFFFFB70h
    call    ryo_h_CttzW16
    mov     eax,[rsp+0CCh]
    jmp     L12
L11:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC08h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rsi,[rsp+98h]
    mov     [rsp+0B8h],rsi
    jmp     L13
L12:
    mov     eax,eax
    mov     [rsp+0B0h],rax
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+98h],1
    mov     qword ptr [rsp+0B8h],1
    mov     rsi,[rsp+100h]
    add     rsi,rax
    mov     [rsp+0B0h],rsi
    mov     rax,[rbp+8]
    and     rsi,rax
    mov     [rsp+0B8h],rsi
    mov     [rsp+88h],rsi
    mov     qword ptr [rsp+80h],1
    jmp     L7
L13:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFBF0h
    lea     rdx,[image.k2880]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L7
L14:
    mov     [rsp+128h],rcx
    mov     [rsp+0E8h],rcx
    mov     rax,[rdx]
    lea     rax,[rax+rcx]
    mov     [rsp+0E0h],rax
    movzx   eax,byte ptr [rax]
    and     eax,80h
    cmp     al,0
    jne     L15
    mov     rax,[rdx]
    lea     rsi,[rsp+0D0h]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [sym3]
    jmp     L16
L15:
    jmp     L23
L16:
    mov     rax,[rsp+0D0h]
    mov     [rsp+0F0h],rax
    mov     rax,[rsp+0D8h]
    mov     [rsp+0F8h],rax
    lea     rax,[rsp+0F0h]
    mov     rdi,rax
    call    qword ptr [sym4]
    mov     r14,rax
    mov     rdi,r14
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L17]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L17:
    .long   L20
    .long   L19
    .long   L42
L18:
    mov     r11,[rsp+0E0h]
    mov     rax,[rsp+0E8h]
    mov     rcx,rax
    jmp     L23
L19:
    mov     rdi,r14
    call    ryo_hr_CttzW16
    jmp     L21
L20:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFC50h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L18
L21:
    mov     eax,eax
    mov     [rsp+0E8h],rax
    mov     qword ptr [rsp+0E0h],1
    jmp     L18
L22:
    mov     rax,[rdx+8]
    mov     [rsp+128h],rax
    mov     rcx,[rsp+108h]
    add     rcx,10h
    mov     [rsp+108h],rcx
    mov     [rsp+120h],rcx
    mov     rsi,[rsp+100h]
    add     rsi,rcx
    mov     [rsp+100h],rsi
    and     rsi,rax
    mov     [rsp+100h],rsi
    mov     rbp,rdx
    jmp     L4
L23:
    jmp     L39
L24:
    mov     rax,[rsp+160h]
    mov     rdx,[rsp+168h]
    mov     rbx,[rsp+230h]
    mov     r12,[rsp+220h]
    mov     r13,[rsp+210h]
    mov     r14,[rsp+200h]
    mov     r15,[rsp+1F0h]
    mov     rbp,[rsp+1E0h]
    add     rsp,498h
    ret
L25:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFB70h
    mov     edx,0FFFFFE20h
    mov     ecx,0
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
    mov     [rsp+1D8h],rax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFD48h
    mov     edx,0
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L26]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L26:
    .long   L28
    .long   L27
    .long   L44
L27:
    mov     rax,[rsp+2B8h]
    mov     [rsp+1C8h],rax
    mov     rdx,[rsp+2C0h]
    mov     [rsp+1D0h],rdx
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],rdx
    mov     [rsp+2D8h],rax
    mov     [rsp+2E0h],rdx
    mov     qword ptr [rsp+2D0h],0
    mov     [rsp+2C0h],rax
    mov     [rsp+2C8h],rdx
    mov     qword ptr [rsp+2B8h],1
    mov     byte ptr [rsp+2B7h],1
    mov     [rsp+1D0h],rax
    mov     [rsp+1D8h],rdx
    mov     [rsp+2F8h],rax
    mov     [rsp+300h],rdx
    mov     qword ptr [rsp+2F0h],0
    mov     [rsp+2E0h],rax
    mov     [rsp+2E8h],rdx
    mov     [rsp+2D0h],rax
    mov     [rsp+2D8h],rdx
    mov     [rsp+330h],rax
    mov     [rsp+338h],rdx
    mov     qword ptr [rsp+328h],0
    mov     [rsp+318h],rax
    mov     [rsp+320h],rdx
    mov     qword ptr [rsp+310h],1
    mov     byte ptr [rsp+2FFh],1
    mov     [rsp+300h],rax
    mov     [rsp+308h],rdx
    mov     [rsp+160h],rax
    mov     [rsp+168h],rdx
    jmp     L24
L28:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFD28h
    mov     edx,0FFFFFE20h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD28h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFD00h
    mov     edx,0FFFFFE40h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+1C8h],r12
    mov     r10,[rsp+30h]
    mov     [rsp+1D0h],r10
    mov     [rsp+1D8h],r15
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFD38h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD00h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rax,[rbx]
    mov     [rsp+338h],rax
    mov     [rsp+340h],rax
    mov     [rsp+358h],rax
    mov     [rsp+348h],rax
    mov     [rsp+330h],rax
    lea     rdx,[rsp+320h]
    mov     rdi,rdx
    mov     rsi,rax
    call    qword ptr [sym3]
    mov     rax,[rsp+320h]
    mov     [rsp+250h],rax
    mov     rax,[rsp+328h]
    mov     [rsp+258h],rax
    lea     rax,[rsp+250h]
    mov     rdi,rax
    call    qword ptr [sym4]
    mov     [rsp+34Ch],eax
    mov     eax,[rsp+34Ch]
    mov     [rsp+350h],ax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+352h]
    mov     [rsp+354h],ax
    mov     [rsp+356h],ax
    mov     rdx,[rbx+18h]
    mov     [rsp+348h],rdx
    mov     [rsp+188h],ax
    mov     qword ptr [rsp+178h],0
    mov     rax,[rsp+338h]
    mov     [rsp+170h],rax
    mov     [rsp+180h],rdx
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFCE0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+10h],rbx
    mov     r11,[rsp+38h]
    mov     [rsp+18h],r11
    mov     [rsp+20h],r13
    mov     r11,[rsp+30h]
    mov     [rsp+28h],r11
    jmp     L0
L29:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L30:
    mov     rax,[rsp+328h]
    mov     rbx,rax
L31:
    movzx   r12d,word ptr [rbx+18h]
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L32]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L32:
    .long   L34
    .long   L33
    .long   L43
L33:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    jmp     L35
L34:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFCB0h
    lea     rdx,[image.k672]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+148h],0
    mov     byte ptr [rsp+147h],1
    mov     rdx,[rbx]
    mov     [rsp+140h],rdx
    mov     [rsp+148h],rdx
    mov     qword ptr [rsp+158h],10h
    lea     rdx,[rdx+10h]
    mov     [rbx],rdx
    mov     [rsp+148h],rdx
    mov     [rsp+148h],rdx
    lea     rsi,[rsp+130h]
    mov     rdi,rsi
    mov     rsi,rdx
    call    qword ptr [sym3]
    jmp     L36
L35:
    mov     eax,eax
    mov     [rsp+148h],rax
    mov     qword ptr [rsp+140h],1
    movzx   edx,word ptr [rbx+18h]
    mov     [rsp+148h],dx
    mov     rsi,rdx
    sub     esi,1
    mov     [rsp+14Ah],si
    and     edx,esi
    mov     [rsp+14Ch],dx
    mov     [rsp+14Eh],dx
    mov     [rbx+18h],dx
    mov     [rsp+148h],rax
    mov     rdx,[rbx+8]
    add     rdx,rax
    mov     [rsp+140h],rdx
    mov     eax,1
    jmp     L37
L36:
    mov     rax,[rsp+130h]
    mov     [rsp+150h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+158h],rax
    lea     rax,[rsp+150h]
    mov     rdi,rax
    call    qword ptr [sym4]
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    mov     [rsp+158h],rax
    add     rax,10h
    mov     [rsp+150h],rax
    mov     [rbx+8],rax
    jmp     L31
L37:
    mov     [rsp+330h],rax
    mov     [rsp+338h],rdx
    mov     rax,[rsp+328h]
    mov     rdx,[rax+10h]
    sub     rdx,1
    mov     [rsp+250h],rdx
    mov     [rax+10h],rdx
    mov     rax,[rsp+330h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L38]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L38:
    .long   L2
    .long   L1
    .long   L44
L39:
    mov     rax,[rsp+378h]
    mov     [rsp+2F8h],rax
    mov     [rsp+300h],rax
    lea     rdx,[rax+rcx]
    mov     [rsp+308h],rdx
    mov     [rsp+310h],rdx
    movzx   esi,byte ptr [rdx]
    mov     [rsp+2E7h],sil
    mov     rsi,[rsp+318h]
    shr     rsi,39h
    mov     [rsp+308h],rsi
    and     rsi,7Fh
    mov     [rsp+300h],rsi
    mov     [rsp+316h],sil
    mov     [rsp+317h],sil
    mov     rdi,rcx
    sub     rdi,10h
    mov     [rsp+2F8h],rdi
    mov     r8,[rsp+380h]
    mov     [rsp+2F0h],r8
    and     rdi,r8
    mov     [rsp+300h],rdi
    add     rdi,10h
    mov     [rsp+308h],rdi
    mov     [rsp+2E8h],rax
    mov     [rsp+2F0h],rax
    mov     [rsp+2F8h],rdx
    mov     [rsp+300h],rdx
    mov     [rdx],sil
    mov     rax,[rsp+378h]
    mov     [rsp+2E8h],rax
    mov     [rsp+2F0h],rax
    mov     rdx,[rsp+308h]
    lea     rax,[rax+rdx]
    mov     [rsp+2F8h],rax
    mov     [rsp+300h],rax
    movzx   edx,byte ptr [rsp+317h]
    mov     [rax],dl
    mov     r11,[rsp+10h]
    mov     rax,[r11]
    mov     [rsp+2E8h],rax
    mov     [rsp+300h],rax
    mov     rdx,[rsp+320h]
    add     rdx,1
    mov     [rsp+2F0h],rdx
    imul    rdx,[rsp+28h]
    mov     [rsp+2F8h],rdx
    mov     [rsp+2E0h],rdx
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+2F0h],rdx
    lea     rax,[rax+rdx]
    mov     [rsp+308h],rax
    mov     [rsp+310h],rax
    mov     rax,[rsp+378h]
    mov     [rsp+2E8h],rax
    mov     [rsp+300h],rax
    add     rcx,1
    mov     [rsp+2F0h],rcx
    imul    rcx,[rsp+28h]
    mov     [rsp+2F8h],rcx
    mov     [rsp+2E0h],rcx
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     [rsp+2F0h],rcx
    lea     rax,[rax+rcx]
    mov     [rsp+308h],rax
    mov     r11,[rsp+28h]
    mov     [rsp],r11
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFB70h
    call    ryo_h_Memcpy
    jmp     L0
L40:
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFCD0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+360h]
    mov     rcx,[rsp+380h]
    mov     [rsp+50h],rcx
    cmp     rcx,0
    je      L24
    mov     r11,[rsp+360h]
    mov     [rsp],rax
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFBB8h
    mov     edx,0FFFFFB70h
    mov     ecx,8
    call    ryo_h_LoadW128
    mov     rax,[rsp+380h]
    add     rax,1
    lea     rcx,[rsp+60h]
    mov     rdx,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdi,rcx
    mov     rcx,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [image.fn125.slot]
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFB70h
    mov     edx,0FFFFFBD0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+378h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rsi
    mov     r11d,0
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+60h],rdx
    lea     rsi,[rsi+rdx]
    mov     [rsp+70h],rsi
    cmp     rcx,0
    je      L24
    mov     rdi,rsi
    mov     rsi,rcx
    mov     rdx,rax
    call    qword ptr [image.sym67]
    jmp     L24
L41:
    ud2
L42:
    ud2
L43:
    ud2
L44:
    ud2
    mov     rbx,rax
    jmp     L48
    mov     rbx,rax
    jmp     L48
L45:
    lea     rax,[rsp+360h]
    lea     rcx,[rsp+378h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.fn86.slot]
    jmp     L46
    jmp     L47
L46:
    mov     [rsp],rbx
    lea     rdi,[rsp+490h]
    mov     esi,0FFFFFB70h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L48
    mov     rbx,rax
    jmp     L48
    mov     rbx,rax
    jmp     L48
L47:
    call    qword ptr [sym9]
    ud2
L48:
    jmp     L45
  ; OSR entries
    lea     r11,[L49]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L49:
    .long   L50
    .long   L51
    .long   L52
    .long   L53
    .long   L54
    .long   L55
L50:
    ret
L51:
    pop     rcx
    lea     rdx,[rsp+260h]
    lea     rsp,[rdx-530h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-220h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-218h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-208h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-200h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-1F8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-1F0h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-1E8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-68h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-8]
    mov     [rsp+90h],r11
    mov     [rdx-260h],rbx
    mov     [rdx-270h],r12
    mov     [rdx-280h],r13
    mov     [rdx-290h],r14
    mov     [rdx-2A0h],r15
    mov     [rdx-2B0h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-2D8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-2D0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2C8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-2C0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-2B8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-300h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-2F8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-320h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-318h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-310h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-308h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-330h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-328h],r11
    mov     r11,[rsp]
    mov     [rdx-480h],r11
    mov     r11,[rsp+8]
    mov     [rdx-478h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-470h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-468h],r11
    lea     rsp,[rsp+0A0h]
    jmp     L0
L52:
    ret
L53:
    ret
L54:
    ret
L55:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF30h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+70h],rax
    lea     rcx,[rsp+38h]
    mov     [rsp+68h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    mov     r13,rax
    jmp     L5
L0:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFFA0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L1:
    .long   L3
    .long   L2
    .long   L11
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+68h],rax
    mov     [rsp+50h],r12
    mov     [rsp+58h],rax
    mov     [rsp+60h],r12
    mov     [rsp+10h],rax
    mov     [rsp+18h],r12
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    lea     r14,[rsp+38h]
    mov     rdi,r14
    call    qword ptr [image.sym31]
    mov     rdi,r14
    call    qword ptr [image.sym32]
    jmp     L4
L3:
    mov     [rsp+70h],r12
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rax
    mov     rdi,r12
    mov     esi,1
    mov     rdx,rax
    call    qword ptr [fn2.slot]
    jmp     L6
L4:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0
    mov     ecx,0FFFFFF38h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    add     rsp,0D8h
    ret
L5:
    mov     [rsp+68h],r12
    lea     rax,[rsp+38h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rax
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    qword ptr [fn4.slot]
    mov     [rsp+70h],rax
    jmp     L0
L6:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF68h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp+70h],r13
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp+68h],r12
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF80h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L4
    mov     rbx,rax
    jmp     L8
L7:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L8:
    mov     rdi,r14
    call    qword ptr [image.sym32]
    jmp     L7
    call    qword ptr [sym5]
    ud2
    mov     rbx,rax
    jmp     L13
    mov     rbx,rax
    jmp     L13
L9:
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [image.fn51.slot]
    jmp     L10
    jmp     L12
L10:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L13
L11:
    ud2
L12:
    call    qword ptr [sym5]
    ud2
L13:
    jmp     L9
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
L15:
    ret
L16:
    ret
L17:
    ret
L18:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+28h],rdx
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+50h],rax
    lea     rcx,[rsp+28h]
    mov     [rsp+48h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    mov     r13,rax
    jmp     L5
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFC0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L1]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    mov     [rsp+38h],rax
    mov     [rsp+40h],r12
    mov     [rsp+10h],rax
    mov     [rsp+18h],r12
    mov     qword ptr [rsp+8],0
    jmp     L4
L3:
    mov     [rsp+50h],r12
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rax
    mov     rdi,r12
    mov     esi,1
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L6
L4:
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF78h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    add     rsp,98h
    ret
L5:
    mov     [rsp+48h],r12
    lea     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rax
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    qword ptr [fn2.slot]
    mov     [rsp+50h],rax
    jmp     L0
L6:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     [rsp+48h],r13
    mov     [rsp+50h],rax
    mov     [rsp+40h],r12
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFFB0h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L4
    jmp     L9
    jmp     L9
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L9
L8:
    ud2
L9:
    jmp     L7
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
    .long   L12
    .long   L13
L11:
    ret
L12:
    ret
L13:
    ret

fn main
    sub     rsp,768h
    mov     [rsp+200h],rbx
    mov     [rsp+1F0h],r12
    mov     [rsp+1E0h],r13
    mov     [rsp+1D0h],r14
    mov     [rsp+1C0h],r15
    mov     qword ptr [rsp+228h],50910h
    mov     ebx,50910h
    lea     rax,[rsp+728h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     eax,0
    mov     [rsp+6F0h],rax
    mov     [rsp+6F8h],rbx
    mov     ebx,1
L0:
    mov     rax,[rsp+6F0h]
    mov     rcx,[rsp+6F8h]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L1
    mov     rax,[rsp+6F0h]
    lea     rcx,[image.k6816]
    mov     r11,rax
    add     r11,1
    jb      L38
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+6F0h],rdx
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
    int3
L3:
    .long   L5
    .long   L4
    .long   L43
L4:
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+228h],r10
    mov     r10,5851F42D4C957F2Dh
    imul    rbx,r10
    jmp     L6
L5:
    mov     qword ptr [rsp+0B8h],0
    mov     qword ptr [rsp+0C0h],0
    mov     dword ptr [rsp+22Ch],14h
    jmp     L7
L6:
    mov     r10,14057B7EF767814Fh
    mov     [rsp+228h],r10
    mov     r10,14057B7EF767814Fh
    add     rbx,r10
    lea     rax,[rsp+728h]
    mov     dword ptr [rsp+22Ch],2Ch
    mov     rdx,rbx
    shr     rdx,2Ch
    lea     rsi,[rsp+690h]
    mov     rdi,rsi
    mov     rsi,rax
    call    fn10
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFF30h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     qword ptr [rsp+210h],0
    lea     rax,[rsp+218h]
    mov     rdi,rax
    mov     esi,0
    call    fn11
    mov     rdx,[rax]
    mov     [rsp+228h],rdx
    add     rdx,r12
    jb      L44
    mov     [rax],rdx
    jmp     L0
L7:
    mov     qword ptr [rsp+228h],1
    mov     qword ptr [rsp+228h],2
    lea     rax,[rsp+610h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [fn14.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAB0h
    mov     edx,0FFFFFEB0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rax,[rsp+630h]
    lea     rdx,[rsp+210h]
    mov     rdi,rax
    mov     rsi,rdx
    call    qword ptr [fn15.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFED0h
    mov     ecx,20h
    call    ryo_h_Copy
L8:
    mov     rax,[rsp+5E0h]
    mov     rbx,rax
    add     rbx,1
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L9]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L9:
    .long   L40
    .long   L13
    .long   L39
L10:
    mov     rdx,[rsp+5D0h]
    mov     rsi,rdx
    add     rsi,rbx
    mov     [rsp+5D0h],rsi
    mov     rsi,rax
    sub     rsi,1
    mov     [rsp+5D8h],rsi
    mov     [rsp+0A8h],rdx
    mov     qword ptr [rsp+0A0h],1
    jmp     L12
L11:
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF940h
    lea     rdx,[image.k6704]
    mov     ecx,10h
    call    ryo_h_Const
L12:
    mov     rdx,[rsp+0A0h]
    mov     rsi,[rsp+0A8h]
    mov     rbx,rsi
    jmp     L14
L13:
    mov     rax,[rsp+5D8h]
    cmp     rax,0
    ja      L10
    jmp     L11
L14:
    mov     rdi,rdx
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L15]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L15:
    .long   L23
    .long   L16
    .long   L43
L16:
    mov     [rsp+5A8h],rbx
    lea     rbx,[rsp+728h]
    lea     r12,[rsp+5A8h]
    mov     rax,[rsp+740h]
    cmp     rax,0
    jne     L17
    mov     ebx,0
    jmp     L22
L17:
    lea     rax,[rsp+748h]
    mov     rdi,rax
    mov     rsi,r12
    call    image.fn79
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,r12
    call    qword ptr [image.fn18.slot]
    mov     rbx,rax
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L18]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L18:
    .long   L19
    .long   L21
    .long   L41
L19:
    mov     ebx,0
    jmp     L22
L20:
    lea     rax,[rax+8]
    mov     rbx,rax
    jmp     L22
L21:
    lea     rbx,[rbx-10h]
    mov     rax,rbx
    jmp     L20
L22:
    jmp     L24
L23:
    mov     rax,[rsp+740h]
    mov     [rsp+0D0h],rax
    jmp     L27
L24:
    mov     [rsp],rbx
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFACCh
    mov     edx,0FFFFF8A0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp+22Ch]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L25]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L25:
    .long   L8
    .long   L26
    .long   L43
L26:
    mov     qword ptr [rsp+228h],1
    mov     rax,[rsp+0B8h]
    add     rax,1
    jb      L46
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0C0h]
    mov     rdx,[rbx]
    add     rax,rdx
    mov     [rsp+0C0h],rax
    jmp     L8
L27:
    lea     rax,[rsp+728h]
    mov     rdi,rax
    call    qword ptr [image.fn4.slot]
    lea     rax,[rsp+728h]
    lea     rdx,[rsp+510h]
    mov     rdi,rdx
    mov     rsi,rax
    call    qword ptr [fn23.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFDB0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+208h]
    mov     rdi,rax
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+0D8h],rax
    lea     rax,[rsp+4D8h]
    mov     rdi,rax
    call    qword ptr [fn25.slot]
    mov     dword ptr [rsp+30h],0
    mov     dword ptr [rsp+34h],1FBD0h
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     edx,[rsp+2Ch]
    mov     [rsp+0E0h],eax
    mov     [rsp+0E4h],edx
    mov     rax,[rsp+0E0h]
    mov     [rsp+4C0h],rax
L28:
    mov     eax,[rsp+4C0h]
    mov     edx,[rsp+4C4h]
    cmp     eax,edx
    setb    al
    test    al,al
    je      L29
    mov     eax,[rsp+4C0h]
    lea     rdx,[image.k6792]
    mov     r11,rax
    add     r11d,1
    jb      L42
    mov     rsi,rax
    add     esi,1
    mov     [rsp+4C0h],esi
    mov     rbx,rax
    mov     eax,1
    jmp     L30
L29:
    mov     eax,0
L30:
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L31]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L31:
    .long   L33
    .long   L32
    .long   L43
L32:
    lea     r12,[rsp+4D8h]
    mov     dword ptr [rsp+22Ch],138Bh
    jmp     L34
L33:
    mov     rax,[rsp+740h]
    mov     [rsp+0F0h],rax
    jmp     L35
L34:
    mov     dword ptr [rsp+22Ch],138Bh
    mov     [rsp],rbx
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFF8A0h
    mov     ecx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rsp+414h]
    lea     rsi,[rsp+3F0h]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [fn31.slot]
    mov     rax,[rsp+3F0h]
    mov     [rsp+400h],rax
    mov     rax,[rsp+3F8h]
    mov     [rsp+408h],rax
    lea     rax,[k32]
    lea     rsi,[rsp+400h]
    lea     rdi,[rsp+438h]
    mov     rdx,rsi
    mov     rsi,rax
    call    qword ptr [fn34.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCD8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+450h]
    lea     rsi,[rsp+218h]
    mov     rdi,rax
    call    qword ptr [fn35.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCF0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+470h]
    lea     rsi,[rsp+218h]
    mov     rdi,rax
    mov     rdx,rsi
    mov     rsi,r12
    call    qword ptr [fn36.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFD10h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+208h]
    mov     rdi,rax
    call    qword ptr [fn37.slot]
    mov     rsi,[rax]
    mov     [rsp+228h],rsi
    mov     qword ptr [rsp+220h],1
    add     rsi,1
    jb      L48
    mov     [rax],rsi
    jmp     L28
L35:
    lea     rbx,[rsp+0F0h]
    mov     rax,[rsp+4F0h]
    mov     [rsp+0F8h],rax
    lea     r12,[rsp+0F8h]
    lea     rax,[rsp+0D0h]
    lea     r13,[rsp+0B8h]
    lea     r14,[rsp+0C0h]
    lea     r15,[rsp+0D8h]
    lea     rsi,[rsp+160h]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [fn41.slot]
    lea     rax,[rsp+170h]
    mov     rdi,rax
    mov     rsi,r13
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+180h]
    mov     rdi,rax
    mov     rsi,r14
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+190h]
    mov     rdi,rax
    mov     rsi,rbx
    call    qword ptr [fn41.slot]
    lea     rax,[rsp+1A0h]
    mov     rdi,rax
    mov     rsi,r15
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+1B0h]
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn41.slot]
    mov     rax,[rsp+160h]
    mov     [rsp+100h],rax
    mov     rax,[rsp+168h]
    mov     [rsp+108h],rax
    mov     rax,[rsp+170h]
    mov     [rsp+110h],rax
    mov     rax,[rsp+178h]
    mov     [rsp+118h],rax
    mov     rax,[rsp+180h]
    mov     [rsp+120h],rax
    mov     rax,[rsp+188h]
    mov     [rsp+128h],rax
    mov     rax,[rsp+190h]
    mov     [rsp+130h],rax
    mov     rax,[rsp+198h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+1A0h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+1A8h]
    mov     [rsp+148h],rax
    mov     rax,[rsp+1B0h]
    mov     [rsp+150h],rax
    mov     rax,[rsp+1B8h]
    mov     [rsp+158h],rax
    lea     rax,[k47]
    lea     rsi,[rsp+100h]
    mov     rdi,rax
    call    qword ptr [sym49]
    lea     rbx,[rsp+4D8h]
    mov     [rsp+228h],rbx
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8F8h
    lea     rdx,[image.k304]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r12,[rsp+58h]
    mov     r13,[rsp+60h]
    mov     rax,[rsp+4E0h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L36
    mov     rdi,rbx
    call    qword ptr [image.fn22.slot]
    mov     rax,[rsp+4E0h]
    add     rax,1
    lea     rsi,[rsp+38h]
    mov     rdi,rsi
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    qword ptr [image.fn125.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8A0h
    mov     edx,0FFFFF8D8h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     rax,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+48h]
    mov     r8,[rsp+4D8h]
    mov     [rsp+38h],r8
    mov     [rsp+40h],r8
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     [rsp+38h],rdi
    lea     r8,[r8+rdi]
    mov     [rsp+48h],r8
    cmp     rsi,0
    je      L36
    mov     rdi,r8
    mov     rdx,rax
    call    qword ptr [image.sym67]
L36:
    lea     rax,[rsp+728h]
    mov     [rsp+228h],rax
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF928h
    lea     rdx,[image.k408]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+730h]
    mov     [rsp+78h],rdi
    cmp     rdi,0
    je      L37
    mov     rdi,[rsp+730h]
    add     rdi,1
    lea     r8,[rsp+68h]
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rdi
    mov     rdi,r8
    call    qword ptr [image.fn125.slot]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8A0h
    mov     edx,0FFFFF908h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     rax,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdi,[rsp+78h]
    mov     r8,[rsp+728h]
    mov     [rsp+68h],r8
    mov     [rsp+70h],r8
    mov     r11d,0
    sub     r11,rdi
    mov     rdi,r11
    mov     [rsp+68h],rdi
    lea     r8,[r8+rdi]
    mov     [rsp+78h],r8
    cmp     rsi,0
    je      L37
    mov     rdi,r8
    mov     rdx,rax
    call    qword ptr [image.sym67]
L37:
    mov     rbx,[rsp+200h]
    mov     r12,[rsp+1F0h]
    mov     r13,[rsp+1E0h]
    mov     r14,[rsp+1D0h]
    mov     r15,[rsp+1C0h]
    add     rsp,768h
    ret
L38:
    lea     rax,[image.k3738]
    mov     rdi,rax
    mov     esi,171h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L39:
    ud2
L40:
    lea     rax,[image.k6720]
    lea     rcx,[image.k4306]
    mov     rdi,rcx
    mov     esi,1A3h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L41:
    ud2
L42:
    lea     rax,[image.k3554]
    mov     rdi,rax
    mov     esi,171h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L43:
    ud2
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
L44:
    lea     rax,[k12]
    mov     [rsp+228h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L45
    mov     r12,rax
    jmp     L51
L45:
    ud2
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
L46:
    lea     rax,[k19]
    mov     [rsp+228h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L47
    mov     r12,rax
    jmp     L51
L47:
    ud2
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
    mov     r12,rax
    jmp     L51
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
L48:
    lea     rax,[k38]
    mov     [rsp+228h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L49
    mov     rbx,rax
    jmp     L54
L49:
    ud2
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     rbx,rax
    jmp     L54
    mov     r12,rax
    jmp     L51
L50:
    lea     r12,[rsp+4D8h]
    mov     [rsp+228h],r12
    lea     r13,[rsp+4F8h]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8A8h
    lea     rdx,[image.k304]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    qword ptr [image.fn24.slot]
    mov     r12,rbx
    jmp     L51
    jmp     L53
L51:
    lea     r13,[rsp+728h]
    mov     [rsp+228h],r13
    lea     r14,[rsp+748h]
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8B8h
    lea     rdx,[image.k408]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rdi,r13
    mov     rsi,r14
    mov     rdx,rax
    call    qword ptr [image.fn25.slot]
    jmp     L52
    jmp     L53
L52:
    mov     [rsp],r12
    lea     rdi,[rsp+760h]
    mov     esi,0FFFFF8A0h
    call    ryo_h_Resume
    ud2
L53:
    call    qword ptr [sym54]
    ud2
L54:
    jmp     L50
  ; OSR entries
    lea     r11,[L55]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L55:
    .long   L56
    .long   L57
    .long   L58
    .long   L59
    .long   L60
    .long   L61
    .long   L62
L56:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-860h]
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
    mov     r11,[rdx-290h]
    mov     [rsp+0D8h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+0E0h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+0E8h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+0F0h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+0F8h],r11
    mov     [rdx-560h],rbx
    mov     [rdx-570h],r12
    mov     [rdx-580h],r13
    mov     [rdx-590h],r14
    mov     [rdx-5A0h],r15
    mov     r11,[rsp+8]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+0D0h]
    mov     [rdx-670h],r11
    mov     r11,[rsp+0D8h]
    mov     [rdx-680h],r11
    mov     r11,[rsp+0E0h]
    mov     [rdx-688h],r11
    mov     r11,[rsp+0E8h]
    mov     [rdx-690h],r11
    mov     r11,[rsp+0F0h]
    mov     [rdx-6A0h],r11
    mov     r11,[rsp+0F8h]
    mov     [rdx-6A8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+100h]
    jmp     L0
L57:
    ret
L58:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-860h]
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
    mov     r11,[rdx-290h]
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
    mov     r11,[rsp]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-670h],r11
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
    lea     rsp,[rsp+100h]
    jmp     L8
L59:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-860h]
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
    mov     r11,[rdx-290h]
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
    mov     r11,[rsp]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-660h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-658h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-650h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-648h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-640h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-638h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-628h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-620h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-618h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-610h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-668h],r11
    mov     r11,[rsp+0C8h]
    mov     [rdx-670h],r11
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
    lea     rsp,[rsp+100h]
    jmp     L28
L60:
    ret
L61:
    ret
L62:
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0
    mov     ecx,0FFFFFFD0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
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
    sub     rsp,128h
    mov     [rsp+110h],rbx
    mov     [rsp+100h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFEE0h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF18h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+58h]
    lea     rcx,[rsp+0E0h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,rcx
    call    qword ptr [fn0.slot]
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD4h
    mov     edx,0FFFFFF38h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp+0F4h]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L0:
    .long   L3
    .long   L2
    .long   L4
L1:
    mov     [rsp],rbx
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEE0h
    mov     edx,0
    mov     ecx,0FFFFFEE8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+110h]
    mov     r12,[rsp+100h]
    add     rsp,128h
    ret
L2:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF38h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF68h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEE8h
    mov     edx,0FFFFFF90h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L1
L3:
    mov     rax,[rsp+60h]
    mov     [rsp+0A0h],rax
    mov     rcx,[rsp+68h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+90h],rax
    mov     [rsp+98h],rcx
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    jmp     L1
L4:
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

fn std::collections::HashMap::<u64, u64>::entry
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     rbx,rdi
    lea     rax,[rsp+28h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA8h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L0:
    .long   L3
    .long   L2
    .long   L4
L1:
    mov     [rsp],rbx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    add     rsp,88h
    ret
L2:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFC0h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L1
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+60h],rax
    mov     rcx,[rsp+38h]
    mov     [rsp+68h],rcx
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+8],0
    jmp     L1
L4:
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
    sub     rsp,138h
    mov     [rsp+120h],rbx
    mov     [rsp+110h],r12
    mov     [rsp+100h],r13
    mov     [rsp],rdi
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEE0h
    mov     edx,0FFFFFED0h
    mov     ecx,0
    mov     r8d,28h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFC4h
    mov     edx,0FFFFFEE0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp+0F4h]
    mov     eax,eax
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
    .long   L2
    .long   L1
    .long   L14
L1:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFEE0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF10h
    mov     ecx,28h
    call    ryo_h_Copy
    mov     ebx,0
    jmp     L3
L2:
    mov     rax,[rsp+18h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+0F7h],0
    jmp     L6
L3:
    mov     r12,[rsp+88h]
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF38h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     r13,[rsp+80h]
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF88h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp+0B0h],rbx
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF68h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rax,[rsp+0D8h]
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L9
L4:
    mov     rax,rcx
    mov     rbx,[rsp+120h]
    mov     r12,[rsp+110h]
    mov     r13,[rsp+100h]
    add     rsp,138h
    ret
L5:
    mov     rcx,[rsp+58h]
    mov     [rsp+60h],rcx
    lea     rcx,[rcx+18h]
    jmp     L4
L6:
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     byte ptr [rsp+0F7h],0
    jmp     L8
L7:
    jmp     L5
L8:
    mov     qword ptr [rsp+0F0h],0FFFFFFFFFFFFFFFFh
    mov     rcx,[rsp+50h]
    lea     rcx,[rcx-20h]
    mov     [rsp+58h],rcx
    jmp     L7
L9:
    mov     byte ptr [rsp+0F7h],0
    jmp     L11
L10:
    mov     rcx,[rsp+0A8h]
    mov     [rsp+0B0h],rcx
    lea     rcx,[rcx+18h]
    jmp     L4
L11:
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rax
    mov     byte ptr [rsp+0F7h],0
    jmp     L13
L12:
    jmp     L10
L13:
    mov     qword ptr [rsp+0F0h],0FFFFFFFFFFFFFFFFh
    mov     rax,[rsp+0A0h]
    lea     rax,[rax-20h]
    mov     [rsp+0A8h],rax
    jmp     L12
L14:
    ud2
    mov     rbx,rax
    mov     eax,0
    jmp     L19
L15:
    mov     [rsp],rbx
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED0h
    call    ryo_h_Resume
    ud2
L16:
    lea     rax,[rsp+68h]
    mov     [rsp+0F0h],rax
    mov     rdi,rax
    call    qword ptr [image.fn51.slot]
    jmp     L15
    jmp     L18
L17:
    test    al,al
    jne     L16
    jmp     L15
L18:
    call    qword ptr [sym3]
    ud2
L19:
    jmp     L17
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
    .long   L25
    .long   L26
    .long   L27
    .long   L28
    .long   L29
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
L27:
    ret
L28:
    ret
L29:
    ret

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rsi
    mov     [rsp],rdi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
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
L0:
    .long   L2
    .long   L1
    .long   L10
L1:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,rbx
    call    qword ptr [fn0.slot]
    jmp     L6
L2:
    mov     rcx,[rsp+18h]
    mov     r11,[rsp+20h]
    jmp     L9
L3:
    mov     rax,rdx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret
L4:
    lea     rdx,[rdx+8]
    jmp     L3
L5:
    jmp     L4
L6:
    lea     rax,[rax-10h]
    mov     rdx,rax
    jmp     L5
L7:
    lea     rax,[rax+8]
    mov     rdx,rax
    jmp     L3
L8:
    jmp     L7
L9:
    lea     rcx,[rcx-10h]
    mov     rax,rcx
    jmp     L8
L10:
    ud2
    jmp     L12
L11:
    mov     [rsp],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
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

fn std::fmt::format
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     rbx,rdi
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    mov     rax,rdx
    and     rax,1
    cmp     rax,1
    je      L1
    jmp     L2
L0:
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF78h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    add     rsp,98h
    ret
L1:
    mov     r12,[rsp+28h]
    mov     r13,rdx
    shr     r13,1
    jmp     L4
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L3:
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
L4:
    lea     r14,[k2]
    mov     edi,1
    call    ryo_hr_CtpopW64
    jmp     L6
L5:
    mov     eax,1
    jmp     L7
L6:
    cmp     eax,1
    je      L5
    jmp     L11
L7:
    jmp     L9
L8:
    cmp     r12,0
    je      L12
    jmp     L10
L9:
    test    al,al
    jne     L8
    jmp     L12
L10:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,1
    call    ryo_hr_DivUW64
    cmp     r13,rax
    ja      L12
    mov     [rsp+38h],r12
    mov     [rsp+40h],r13
    jmp     L3
L11:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
    jmp     L13
L12:
    lea     rax,[image.k5783]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L13:
    call    qword ptr [image.sym30]
    ud2
  ; OSR entries
    lea     r11,[L14]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L14:
    .long   L15
    .long   L16
L15:
    ret
L16:
    ret

fn std::fmt::format::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0
    call    ryo_h_LoadW128
    lea     rax,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0
    mov     ecx,0FFFFFFC8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

fn std::hint::must_use::<std::string::String>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     rbx,rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0
    mov     ecx,0FFFFFFB8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+40h]
    add     rsp,58h
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L0
    mov     rax,[rdi]
    lea     rcx,[image.k6816]
    mov     r11,rax
    add     r11,1
    jb      L2
    mov     rdx,rax
    add     rdx,1
    mov     [rdi],rdx
    mov     rdx,rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    add     rsp,18h
    ret
L2:
    lea     rax,[image.k3738]
    mov     rdi,rax
    mov     esi,171h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    sub     rsp,18h
    mov     eax,10h
    add     rsp,18h
    ret

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     rbx,rdi
    mov     r12,rcx
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     eax,eax
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
    .long   L4
L1:
    lea     rax,[rsp+8]
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    lea     rdx,[rsp+8]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [fn1.slot]
L3:
    mov     [rsp],rbx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0
    mov     ecx,0FFFFFFA8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    add     rsp,68h
    ret
L4:
    ud2
    mov     ecx,1
    jmp     L8
    mov     ecx,0
    jmp     L8
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L6:
    jmp     L5
L7:
    test    cl,cl
    jne     L6
    jmp     L5
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
L10:
    ret
L11:
    ret
L12:
    ret
L13:
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,r12
    sub     rcx,1
    and     rcx,rbx
    cmp     rcx,0
    sete    cl
    mov     rax,rcx
    movzx   eax,al
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L1:
    cmp     eax,1
    je      L0
    lea     rax,[k0]
    lea     rcx,[k2]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [sym3]
    ud2
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
    jmp     L3
L2:
    mov     eax,1
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L17
L4:
    jmp     L13
L5:
    mov     edi,1
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L7
L6:
    mov     ecx,1
    jmp     L8
L7:
    cmp     ecx,1
    je      L6
    jmp     L18
L8:
    jmp     L15
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,1
    mul     r13
    mov     rdx,rax
    mov     rax,r11
    jb      L19
    cmp     rbx,r12
    jae     L10
    mov     rsi,r12
    sub     rsi,rbx
    jmp     L11
L10:
    mov     rsi,rbx
    sub     rsi,r12
L11:
    cmp     rdx,rsi
    setbe   dl
    jmp     L16
L12:
    test    r15b,r15b
    jne     L5
    cmp     rbx,0
    je      L20
    jmp     L5
L13:
    test    al,al
    jne     L12
    jmp     L20
L14:
    test    r15b,r15b
    jne     L9
    cmp     r12,0
    je      L20
    jmp     L9
L15:
    test    cl,cl
    jne     L14
    jmp     L20
L16:
    test    dl,dl
    je      L20
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
L17:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L18:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L19:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L21
    jmp     L21
L20:
    lea     rax,[image.k4515]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym63]
    ud2
L21:
    call    qword ptr [image.sym30]
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
    jmp     L3
L2:
    mov     rcx,r14
    sub     rcx,1
    and     rcx,rbx
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L18
L4:
    jmp     L14
L5:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,r14
    sub     rdx,1
    and     rdx,r12
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L19
L8:
    jmp     L16
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,r13
    mul     r15
    mov     rdx,r10
    jb      L20
    cmp     rbx,r12
    jae     L10
    mov     rsi,r12
    sub     rsi,rbx
    jmp     L11
L10:
    mov     rsi,rbx
    sub     rsi,r12
L11:
    cmp     rax,rsi
    setbe   al
    jmp     L17
L12:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L13:
    test    bpl,bpl
    jne     L5
    cmp     rbx,0
    je      L21
    jmp     L5
L14:
    test    cl,cl
    jne     L13
    jmp     L22
L15:
    test    bpl,bpl
    jne     L9
    cmp     r12,0
    je      L21
    jmp     L9
L16:
    test    dl,dl
    jne     L15
    jmp     L23
L17:
    test    al,al
    jne     L12
    jmp     L21
L18:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L19:
    lea     rax,[image.k1979]
    lea     rcx,[image.k2104]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym39]
    ud2
L20:
    lea     rax,[image.k5722]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym64]
    ud2
    jmp     L24
    jmp     L24
L21:
    lea     rax,[k3]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [sym5]
    ud2
L22:
    jmp     L21
L23:
    jmp     L21
L24:
    call    qword ptr [sym6]
    ud2
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
    .long   L32
    .long   L33
    .long   L34
    .long   L35
L26:
    ret
L27:
    ret
L28:
    ret
L29:
    ret
L30:
    ret
L31:
    ret
L32:
    ret
L33:
    ret
L34:
    ret
L35:
    ret

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rdi,rbx
    call    qword ptr [image.sym31]
    mov     rdi,rbx
    call    qword ptr [image.sym32]
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
    mov     [rsp+10h],rax
    jmp     L1
L0:
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L1:
    mov     rdi,rbx
    call    qword ptr [image.sym32]
    jmp     L0
    call    qword ptr [image.sym21]
    ud2

