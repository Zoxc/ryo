fn <&u64 as std::ops::Rem<u64>>::rem [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    cmp     qword ptr [rsp+28h],0
    jne     L1
    mov     rsi,[rsp+10h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+20h]
    xor     edx,edx
    div     qword ptr [rsp+28h]
    mov     [rsp+38h],rdx
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <() as std::process::Termination>::report [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+8]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+50h]
    mov     rsi,[rsi+10h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+50h]
    mov     rdi,[rdi+18h]
    mov     [rsp+48h],rdi
    mov     r8,[rsp+50h]
    mov     r8,[r8+30h]
    and     r8,0FFh
    shl     r8,38h
    mov     r9,[rsp+50h]
    mov     r9,[r9+38h]
    or      r8,r9
    mov     [rsp+28h],r8
    xor     rdi,r8
    mov     [rsp+48h],rdi
    lea     r10,[rsp+30h]
    mov     [rsp+20h],r10
    mov     rdi,[rsp+20h]
    call    fn0
    mov     rax,[rsp+30h]
    xor     rax,[rsp+28h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    xor     rdx,0FFh
    mov     [rsp+38h],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+20h]
    call    fn1
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+40h]
    xor     rax,rdx
    mov     rsi,[rsp+38h]
    xor     rax,rsi
    mov     rdi,[rsp+48h]
    xor     rax,rdi
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write [hint]
    inc     qword ptr [jit_record]
    jns     L17
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+30h]
    add     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rsi+30h],rcx
    mov     qword ptr [rsp+80h],0
    mov     r8,[rsp+98h]
    mov     r8,[r8+40h]
    mov     [rsp+68h],r8
    cmp     r8,0
    je      L4
    mov     r10,[rsp+98h]
    mov     r10,[r10+40h]
    mov     qword ptr [rsp+20h],8
    mov     rax,[rsp+20h]
    sub     rax,r10
    mov     [rsp+80h],rax
    mov     [rsp+50h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+50h]
    call    fn0
    mov     [rsp+58h],rax
    jmp     L11
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    mov     rax,[rsp+98h]
    mov     rax,[rax+40h]
    mov     qword ptr [rsp+20h],8
    mov     rsi,[rsp+20h]
    imul    rsi,rax
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+60h]
    mov     ecx,[rsp+58h]
    shl     rdi,cl
    mov     r8,[rsp+98h]
    mov     r8,[r8+38h]
    or      r8,rdi
    mov     [rsp+10h],r8
    mov     r9,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [r9+38h],rcx
    mov     r10,[rsp+80h]
    mov     [rsp+60h],r10
    mov     r11,[rsp+70h]
    cmp     r11,r10
    jae     L3
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+40h]
    add     rdx,r11
    mov     [rsp+10h],rdx
    mov     rax,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rax+40h],rcx
    jmp     L10
L3:
    mov     rax,[rsp+98h]
    mov     rax,[rax+38h]
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+18h]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rsi+18h],rcx
    mov     rdi,[rsp+98h]
    mov     [rsp+60h],rdi
    mov     rdi,[rsp+60h]
    call    fn1
    mov     rax,[rsp+98h]
    mov     rax,[rax+38h]
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rsi],rcx
    mov     qword ptr [rsp+20h],0
    mov     r8,[rsp+98h]
    mov     rcx,[rsp+20h]
    mov     [r8+40h],rcx
    jmp     L4
L4:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+70h]
    sub     rdx,rax
    mov     [rsp+68h],rdx
    and     rdx,7
    mov     [rsp+60h],rdx
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+68h]
    sub     rdx,[rsp+60h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jae     L9
    mov     qword ptr [rsp+50h],0
    mov     rdi,[rsp+88h]
    mov     r8,[rsp+90h]
    mov     r9,[rsp+80h]
    imul    rcx,r9,1
    add     rdi,rcx
    mov     [rsp+48h],rdi
    lea     r10,[rsp+50h]
    mov     [rsp+38h],r10
    mov     [rsp+40h],r10
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L8:
    mov     rax,[rsp+98h]
    mov     rax,[rax]
    xor     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rdx],rcx
    mov     rsi,[rsp+80h]
    add     rsi,8
    mov     [rsp+80h],rsi
    jmp     L5
L9:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+60h]
    call    fn2
    mov     [rsp+58h],rax
    mov     rax,[rsp+98h]
    mov     rcx,[rsp+58h]
    mov     [rax+38h],rcx
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+60h]
    mov     [rdx+40h],rcx
L10:
    add     rsp,0A8h
    ret
L11:
    mov     qword ptr [rsp+20h],0
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+58h]
    call    fn3
    mov     [rsp+60h],rax
    jmp     L1
L12:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],8
    lea     r9,[k4]
    mov     [rsp+8],r9
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn5
L13:
    mov     rax,[rsp+48h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+20h]
    mov     [rdx],rcx
    mov     rsi,[rsp+50h]
    mov     [rsp+78h],rsi
    mov     rdi,[rsp+98h]
    mov     rdi,[rdi+18h]
    xor     rdi,rsi
    mov     [rsp+10h],rdi
    mov     r8,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [r8+18h],rcx
    mov     r9,[rsp+98h]
    mov     [rsp+50h],r9
    mov     rdi,[rsp+50h]
    call    fn6
    jmp     L7
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L15:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L17:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    call    fn0
    mov     byte ptr [rsp+0Fh],0FFh
    lea     rdx,[rsp+0Fh]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+20h],1
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    call    fn1
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    add     rax,rdx
    mov     [rsp+20h],rax
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+8]
    mov     r8,[rsp+28h]
    mov     r8,[r8+18h]
    add     rdi,r8
    mov     [rsp+20h],rdi
    mov     r9,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r9+8],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    mov     [rsp+18h],r10
    shl     r10,0Dh
    mov     r11,[rsp+18h]
    shr     r11,33h
    or      r10,r11
    mov     [rsp+20h],r10
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+18h]
    mov     [rsp+18h],r8
    shl     r8,10h
    mov     r9,[rsp+18h]
    shr     r9,30h
    or      r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10+18h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+18h]
    xor     rax,r11
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi]
    mov     [rsp+18h],rsi
    shl     rsi,20h
    mov     rdi,[rsp+18h]
    shr     rdi,20h
    or      rsi,rdi
    mov     [rsp+20h],rsi
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    add     r9,r10
    mov     [rsp+20h],r9
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+18h]
    add     r11,rdx
    mov     [rsp+20h],r11
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+10h]
    mov     [rsp+18h],rdi
    shl     rdi,11h
    mov     r8,[rsp+18h]
    shr     r8,2Fh
    or      rdi,r8
    mov     [rsp+20h],rdi
    mov     r9,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r9+10h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+10h]
    xor     rax,r10
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdx+10h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+18h]
    mov     [rsp+18h],r11
    shl     r11,15h
    mov     rsi,[rsp+18h]
    shr     rsi,2Bh
    or      r11,rsi
    mov     [rsp+20h],r11
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    xor     r9,r8
    mov     [rsp],r9
    mov     rax,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rax+18h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+8]
    mov     [rsp+18h],r10
    shl     r10,20h
    mov     rdx,[rsp+18h]
    shr     rdx,20h
    or      r10,rdx
    mov     [rsp+20h],r10
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi+8],rcx
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    add     rax,rdx
    mov     [rsp+20h],rax
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+8]
    mov     r8,[rsp+28h]
    mov     r8,[r8+18h]
    add     rdi,r8
    mov     [rsp+20h],rdi
    mov     r9,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r9+8],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    mov     [rsp+18h],r10
    shl     r10,0Dh
    mov     r11,[rsp+18h]
    shr     r11,33h
    or      r10,r11
    mov     [rsp+20h],r10
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+18h]
    mov     [rsp+18h],r8
    shl     r8,10h
    mov     r9,[rsp+18h]
    shr     r9,30h
    or      r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10+18h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+18h]
    xor     rax,r11
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi]
    mov     [rsp+18h],rsi
    shl     rsi,20h
    mov     rdi,[rsp+18h]
    shr     rdi,20h
    or      rsi,rdi
    mov     [rsp+20h],rsi
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    add     r9,r10
    mov     [rsp+20h],r9
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+18h]
    add     r11,rdx
    mov     [rsp+20h],r11
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+10h]
    mov     [rsp+18h],rdi
    shl     rdi,11h
    mov     r8,[rsp+18h]
    shr     r8,2Fh
    or      rdi,r8
    mov     [rsp+20h],rdi
    mov     r9,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r9+10h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+10h]
    xor     rax,r10
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdx+10h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+18h]
    mov     [rsp+18h],r11
    shl     r11,15h
    mov     rsi,[rsp+18h]
    shr     rsi,2Bh
    or      r11,rsi
    mov     [rsp+20h],r11
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    xor     r9,r8
    mov     [rsp],r9
    mov     rax,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rax+18h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+8]
    mov     [rsp+18h],r10
    shl     r10,20h
    mov     rdx,[rsp+18h]
    shr     rdx,20h
    or      r10,rdx
    mov     [rsp+20h],r10
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi+8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+10h]
    add     r11,rdi
    mov     [rsp+20h],r11
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+18h]
    add     r9,rax
    mov     [rsp+20h],r9
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdx+8],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    mov     [rsp+18h],r10
    shl     r10,0Dh
    mov     rsi,[rsp+18h]
    shr     rsi,33h
    or      r10,rsi
    mov     [rsp+20h],r10
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+10h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     r8,[rsp+28h]
    mov     r8,[r8+10h]
    xor     r8,r11
    mov     [rsp],r8
    mov     rax,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rax+10h],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    mov     [rsp+18h],r9
    shl     r9,10h
    mov     rdx,[rsp+18h]
    shr     rdx,30h
    or      r9,rdx
    mov     [rsp+20h],r9
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi+18h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+8]
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+18h]
    xor     rdi,r10
    mov     [rsp],rdi
    mov     r8,[rsp+28h]
    mov     rcx,[rsp]
    mov     [r8+18h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     [rsp+18h],r11
    shl     r11,20h
    mov     rax,[rsp+18h]
    shr     rax,20h
    or      r11,rax
    mov     [rsp+20h],r11
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdx],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     r9,rsi
    mov     [rsp+20h],r9
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10]
    mov     r8,[rsp+28h]
    mov     r8,[r8+18h]
    add     r10,r8
    mov     [rsp+20h],r10
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    shl     r11,11h
    mov     rdx,[rsp+18h]
    shr     rdx,2Fh
    or      r11,rdx
    mov     [rsp+20h],r11
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi+10h],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+10h]
    xor     rdi,r9
    mov     [rsp],rdi
    mov     r8,[rsp+28h]
    mov     rcx,[rsp]
    mov     [r8+10h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+18h]
    mov     [rsp+18h],r10
    shl     r10,15h
    mov     rax,[rsp+18h]
    shr     rax,2Bh
    or      r10,rax
    mov     [rsp+20h],r10
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdx+18h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,r11
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     [rsp+18h],r9
    shl     r9,20h
    mov     r8,[rsp+18h]
    shr     r8,20h
    or      r9,r8
    mov     [rsp+20h],r9
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    add     r10,rdx
    mov     [rsp+20h],r10
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     rdi,[rsp+28h]
    mov     rdi,[rdi+18h]
    add     r11,rdi
    mov     [rsp+20h],r11
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8+8],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+10h]
    mov     [rsp+18h],r9
    shl     r9,0Dh
    mov     rax,[rsp+18h]
    shr     rax,33h
    or      r9,rax
    mov     [rsp+20h],r9
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdx+10h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    xor     rsi,r10
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+10h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+18h]
    mov     [rsp+18h],r11
    shl     r11,10h
    mov     r8,[rsp+18h]
    shr     r8,30h
    or      r11,r8
    mov     [rsp+20h],r11
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+18h]
    xor     rdx,r9
    mov     [rsp],rdx
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rsi+18h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10]
    mov     [rsp+18h],r10
    shl     r10,20h
    mov     rdi,[rsp+18h]
    shr     rdi,20h
    or      r10,rdi
    mov     [rsp+20h],r10
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     rax,[rsp+28h]
    mov     rax,[rax+10h]
    add     r11,rax
    mov     [rsp+20h],r11
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdx+8],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    add     r9,rsi
    mov     [rsp+20h],r9
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10+10h]
    mov     [rsp+18h],r10
    shl     r10,11h
    mov     r8,[rsp+18h]
    shr     r8,2Fh
    or      r10,r8
    mov     [rsp+20h],r10
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    xor     rdx,r11
    mov     [rsp],rdx
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rsi+10h],rcx
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    mov     [rsp+18h],r9
    shl     r9,15h
    mov     rdi,[rsp+18h]
    shr     rdi,2Bh
    or      r9,rdi
    mov     [rsp+20h],r9
    mov     r8,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r8+18h],rcx
    mov     r10,[rsp+28h]
    mov     r10,[r10]
    mov     rax,[rsp+28h]
    mov     rax,[rax+18h]
    xor     rax,r10
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+8]
    mov     [rsp+18h],r11
    shl     r11,20h
    mov     rsi,[rsp+18h]
    shr     rsi,20h
    or      r11,rsi
    mov     [rsp+20h],r11
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned} as std::ops::FnOnce<(&str,)>>::call_once - shim(for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned})
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0B8h
    mov     [rsp+28h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF78h
    xor     ecx,ecx
    mov     r8d,28h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+50h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+30h],r8
    lea     r9,[rsp+70h]
    mov     [rsp+60h],r9
    mov     rcx,[rsp+40h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rcx,[rsp+50h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+78h]
    mov     rcx,[rsp+60h]
    call    fn0
    mov     [rsp+0A8h],rax
    jmp     L5
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
L5:
    jmp     L1
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L3
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L4:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+8]
    mov     rsi,[rsp+60h]
    mov     rsi,[rsi]
    mov     [rsp+40h],rsi
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+58h]
    mov     [rsp+18h],rdi
    mov     rcx,[rsp+10h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+28h]
    call    fn0
    mov     [rsp+68h],rax
    jmp     L1
L5:
    ud2
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L8:
    jmp     L3
L9:
    ud2
L10:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L7
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L13:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::raw::RawTable<(std::string::String, usize)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+20h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+10h]
    call    fn1
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::raw::RawTable<(u64, u64)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+20h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+10h]
    call    fn1
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}> as std::ops::Drop>::drop [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    lea     rax,[rax+8]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    lea     rdx,[rdx+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::alloc::Global as std::alloc::Allocator>::allocate [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     byte ptr [rsp+7],0
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    movzx   edx,byte ptr [rsp+7]
    call    fn0
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::alloc::Global as std::alloc::Allocator>::deallocate [hint]
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rcx
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,0
    je      L1
    mov     rsi,[rsp+30h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym0]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L2:
    add     rsp,58h
    ret
L3:
    jmp     L1
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::collections::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>> as std::default::Default>::default [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+48h],rdi
    call    fn0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    mov     ecx,20h
    call    ryo_h_Const
    mov     rax,[rsp+8]
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+48h]
    add     rsp,78h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::collections::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>> as std::default::Default>::default [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+48h],rdi
    call    fn0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    mov     ecx,20h
    call    ryo_h_Const
    mov     rax,[rsp+8]
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+48h]
    add     rsp,78h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:28:43: 28:50}> [hint]
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0B8h
    mov     [rsp+30h],rdi
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    mov     r8d,28h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+50h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+58h],r8
    lea     r9,[rsp+78h]
    mov     [rsp+68h],r9
    mov     rcx,[rsp+40h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rcx,[rsp+50h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rsi
    mov     [rsp+28h],r8
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+68h]
    call    fn0
    mov     [rsp+0A8h],rax
    jmp     L5
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L5:
    jmp     L1
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L3
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rcx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn0
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::default::Default>::default
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,8
    add     rsp,8
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::build_hasher
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+8],rdi
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+18h]
    call    fn0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,0FFFFFFB8h
    mov     r8d,48h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::hash_one::<&std::string::String>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+70h]
    call    fn0
    lea     rax,[rsp+68h]
    mov     [rsp+10h],rax
    lea     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn1
    lea     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn2
    mov     [rsp+78h],rax
    mov     rax,[rsp+78h]
    add     rsp,88h
    ret
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::BuildHasherDefault<std::hash::DefaultHasher> as std::hash::BuildHasher>::hash_one::<&u64>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+70h]
    call    fn0
    lea     rax,[rsp+68h]
    mov     [rsp+10h],rax
    lea     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn1
    lea     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn2
    mov     [rsp+78h],rax
    mov     rax,[rsp+78h]
    add     rsp,88h
    ret
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::DefaultHasher as std::default::Default>::default [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,158h
    mov     [rsp+100h],rdi
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    mov     qword ptr [rsp+20h],0
    mov     qword ptr [rsp+48h],0
    mov     qword ptr [rsp+50h],0
    mov     qword ptr [rsp+58h],0
    mov     r11,[rsp+8]
    mov     [rsp+28h],r11
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+40h],rsi
    mov     qword ptr [rsp+60h],0
    mov     qword ptr [rsp+68h],0
    lea     r9,[rsp+28h]
    mov     [rsp+20h],r9
    mov     rdi,[rsp+20h]
    call    fn0
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFED8h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF20h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFB8h
    mov     r8d,48h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+100h]
    add     rsp,158h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::DefaultHasher as std::hash::Hasher>::write [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    call    fn0
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    call    fn0
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp],rax
    lea     rdx,[rsp]
    mov     [rsp+10h],rdx
    mov     qword ptr [rsp+18h],8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::IntoIterator>::into_iter [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+28h]
    mov     [rsp+48h],rdi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::Iterator>::next [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<u32> as std::iter::IntoIterator>::into_iter [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],edi
    mov     [rsp+4],esi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     eax,[rsp+8]
    mov     edx,[rsp+0Ch]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<u32> as std::iter::range::RangeIteratorImpl>::spec_next [hint]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+20h]
    lea     rdx,[rdx+4]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     rdx,[rsp+20h]
    mov     edx,[rdx]
    mov     [rsp+18h],edx
    mov     qword ptr [rsp],1
    mov     edi,[rsp+18h]
    mov     rsi,[rsp]
    call    fn1
    mov     [rsp+14h],eax
    mov     rax,[rsp+20h]
    mov     ecx,[rsp+14h]
    mov     [rax],ecx
    mov     edx,[rsp+18h]
    mov     [rsp+2Ch],edx
    mov     dword ptr [rsp+28h],1
    jmp     L2
L1:
    mov     dword ptr [rsp+28h],0
L2:
    mov     eax,[rsp+28h]
    mov     edx,[rsp+2Ch]
    add     rsp,38h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<u64> as std::iter::IntoIterator>::into_iter [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<u64> as std::iter::Iterator>::step_by [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    mov     [rsp+8],rcx
    lea     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+8]
    call    fn0
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<u64> as std::iter::range::RangeIteratorImpl>::spec_next [hint]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+8]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+27h],al
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+8],1
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    call    fn1
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+10h]
    mov     [rax],rcx
    mov     rdx,[rsp+18h]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+30h],1
    jmp     L2
L1:
    mov     qword ptr [rsp+30h],0
L2:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::string::String as std::cmp::PartialEq>::eq [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rsi
    mov     rax,[rsp+48h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+48h]
    mov     rdx,[rdx+10h]
    mov     [rsp+28h],rdx
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn0
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as std::iter::Step>::forward_unchecked [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,28h
    mov     [rsp+18h],edi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    mov     [rsp+0Ch],eax
    mov     byte ptr [rsp+0Bh],1
    test    byte ptr [rsp+0Bh],0FFh
    je      L1
    lea     rdi,[k0]
    mov     [rsp],rdi
    mov     edi,[rsp+18h]
    mov     esi,[rsp+0Ch]
    mov     rdx,[rsp]
    call    fn1
L1:
    mov     eax,[rsp+18h]
    add     eax,[rsp+0Ch]
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u64 as hashbrown::Equivalent<u64>>::equivalent
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+18h]
    call    fn0
    mov     [rsp],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp]
    call    fn1
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u64 as std::borrow::Borrow<u64>>::borrow
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u64 as std::iter::Step>::forward_unchecked [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L1
    lea     rdi,[k0]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn1
L1:
    mov     rax,[rsp+20h]
    add     rax,[rsp+10h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    imul    rax,[rsp+20h],1
    mov     [rsp+18h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+28h]
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    cmp     dword ptr [rsp+14h],0
    sete    [rsp+3Fh]
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u8 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global> [hint]
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,0B8h
    mov     [rsp+48h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+90h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    mov     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+70h],rdx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+0A0h]
    mov     [rsp+60h],rsi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF98h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+48h]
    add     rsp,0B8h
    ret
L5:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+0A8h],0
    cmp     qword ptr [rsp+40h],0
    ja      L1
    jmp     L3
L6:
    mov     rax,[rsp+68h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     r8,[k2]
    mov     [rsp],r8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+40h]
    mov     r9,[rsp]
    call    fn3
L7:
    imul    rax,[rsp+40h],1
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF60h
    call    ryo_h_Memcpy
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L8
    mov     qword ptr [rsp+10h],1
    cmp     qword ptr [rsp+10h],0
    je      L12
    jmp     L13
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L9:
    mov     rax,[rsp+40h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L11:
    lea     rax,[k4]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    call    fn5
    jmp     L8
L12:
    ud2
L13:
    mov     rax,[rsp+98h]
    mov     [rsp+30h],rax
    jmp     L10
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L15:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L16:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L17:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::cmp::Ord>::max [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+27h],1
    lea     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+17h],al
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     byte ptr [rsp+27h],0
    mov     rsi,[rsp+30h]
    mov     [rsp+38h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
L2:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L8:
    jmp     L5
L9:
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L7
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::cmp::Ord>::min [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+27h],1
    lea     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+17h],al
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+28h]
    mov     [rsp+38h],rdx
    jmp     L2
L1:
    mov     byte ptr [rsp+27h],0
    mov     rdx,[rsp+30h]
    mov     [rsp+38h],rdx
L2:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L8:
    jmp     L5
L9:
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L7
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::default::Default>::default [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     qword ptr [rsp+8],0
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jae     L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0D6h
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0D6h
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFF0h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    lea     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    lea     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    call    fn0
    add     rsp,28h
    ret
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFF0h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFF0h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    lea     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    lea     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn alloc::raw_vec::RawVecInner::with_capacity_in [hint]
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+0Fh],0
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+78h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+70h]
    call    qword ptr [sym0]
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym1]
    ud2
L2:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    cmp     rdx,0
    je      L5
    jmp     L6
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L4:
    mov     rax,[rsp+20h]
    sub     rax,0
    cmp     rax,[rsp+78h]
    setb    [rsp+36h]
    movzx   edx,byte ptr [rsp+36h]
    xor     dl,1
    mov     [rsp+37h],dl
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
L5:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    jmp     L3
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+20h],rax
    jmp     L3
L7:
    lea     rax,[k2]
    mov     [rsp+8],rax
    movzx   edi,byte ptr [rsp+37h]
    mov     rsi,[rsp+8]
    call    fn3
L8:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::core_arch::simd::Simd::<i8, 16>::splat [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+0Fh],sil
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFEFh
    call    ryo_h_VsplatI8x16
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD0h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<u32> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<u64> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<usize> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::hash::impls::<impl std::hash::Hash for u64>::hash::<std::hash::DefaultHasher> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rdx+30h],rcx
    mov     rsi,[rsp+18h]
    mov     rsi,[rsi+20h]
    mov     rcx,736F6D6570736575h
    xor     rsi,rcx
    mov     [rsp],rsi
    mov     rdi,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rdi],rcx
    mov     r8,[rsp+18h]
    mov     r8,[r8+28h]
    mov     rcx,646F72616E646F6Dh
    xor     r8,rcx
    mov     [rsp],r8
    mov     r9,[rsp+18h]
    mov     rcx,[rsp]
    mov     [r9+10h],rcx
    mov     r10,[rsp+18h]
    mov     r10,[r10+20h]
    mov     rcx,6C7967656E657261h
    xor     r10,rcx
    mov     [rsp],r10
    mov     r11,[rsp+18h]
    mov     rcx,[rsp]
    mov     [r11+8],rcx
    mov     rax,[rsp+18h]
    mov     rax,[rax+28h]
    mov     rcx,7465646279746573h
    xor     rax,rcx
    mov     [rsp],rax
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     qword ptr [rsp],0
    mov     rdi,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rdi+40h],rcx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::hash::sip::u8to64_le [hint]
    inc     qword ptr [jit_record]
    jns     L16
L0:
    sub     rsp,0C8h
    mov     [rsp+0A8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+98h],rcx
    mov     qword ptr [rsp+68h],0
    mov     qword ptr [rsp+0B8h],0
    mov     rsi,[rsp+68h]
    add     rsi,3
    mov     [rsp+58h],rsi
    cmp     rsi,[rsp+98h]
    jae     L1
    mov     dword ptr [rsp+60h],0
    mov     r8,[rsp+0A8h]
    mov     r9,[rsp+0B0h]
    mov     r10,[rsp+68h]
    mov     r11,[rsp+0A0h]
    add     r11,r10
    imul    rcx,r11,1
    add     r8,rcx
    mov     [rsp+58h],r8
    lea     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L8
    jmp     L7
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    mov     rax,[rsp+68h]
    add     rax,1
    mov     [rsp+58h],rax
    cmp     rax,[rsp+98h]
    jae     L3
    mov     word ptr [rsp+64h],0
    mov     rsi,[rsp+0A8h]
    mov     rdi,[rsp+0B0h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+0A0h]
    add     r9,r8
    imul    rcx,r9,1
    add     rsi,rcx
    mov     [rsp+48h],rsi
    lea     r10,[rsp+64h]
    mov     [rsp+38h],r10
    mov     [rsp+40h],r10
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+98h]
    jae     L5
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+0A0h]
    add     rsi,rdx
    mov     [rsp+48h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
L7:
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],4
    lea     r9,[k0]
    mov     [rsp+8],r9
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn1
L8:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+50h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     esi,[rsp+60h]
    mov     [rsp+0B8h],rsi
    mov     rdi,[rsp+68h]
    add     rdi,4
    mov     [rsp+68h],rdi
    jmp     L1
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],2
    lea     r9,[k2]
    mov     [rsp+8],r9
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn3
L10:
    mov     rax,[rsp+48h]
    movzx   eax,word ptr [rax]
    mov     [rsp+20h],ax
    mov     rdx,[rsp+40h]
    movzx   ecx,word ptr [rsp+20h]
    mov     [rdx],cx
    movzx   esi,word ptr [rsp+64h]
    mov     rdi,[rsp+68h]
    imul    r8,rdi,8
    mov     [rsp+48h],r8
    mov     ecx,[rsp+48h]
    shl     rsi,cl
    mov     r9,[rsp+0B8h]
    or      r9,rsi
    mov     [rsp+0B8h],r9
    mov     r10,[rsp+68h]
    add     r10,2
    mov     [rsp+68h],r10
    jmp     L3
L11:
    mov     rax,[rsp+0B0h]
    mov     [rsp+40h],rax
    lea     rdx,[k4]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+20h]
    call    fn5
L12:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+48h]
    cmp     rdx,rax
    setb    [rsp+65h]
    mov     rsi,[rsp+0A8h]
    imul    rcx,rdx,1
    add     rsi,rcx
    movzx   esi,byte ptr [rsi]
    mov     rdi,[rsp+68h]
    imul    r8,rdi,8
    mov     [rsp+48h],r8
    mov     ecx,[rsp+48h]
    shl     rsi,cl
    mov     r9,[rsp+0B8h]
    or      r9,rsi
    mov     [rsp+0B8h],r9
    mov     r10,[rsp+68h]
    add     r10,1
    mov     [rsp+68h],r10
    jmp     L5
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u32>::unchecked_add::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+7Ch],edi
    mov     [rsp+78h],esi
    mov     [rsp+10h],rdx
    mov     eax,[rsp+7Ch]
    add     eax,[rsp+78h]
    setb    cl
    mov     [rsp+60h],cl
    movzx   edx,byte ptr [rsp+60h]
    mov     [rsp+67h],dl
    test    byte ptr [rsp+67h],0FFh
    je      L1
    lea     rdi,[k0]
    mov     qword ptr [rsp+70h],0B8h
    mov     r9,[rsp+70h]
    lea     r10,[k1]
    mov     qword ptr [rsp+20h],0B8h
    mov     rsi,[rsp+20h]
    shl     rsi,1
    or      rsi,1
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u64>::unchecked_add::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    add     rax,[rsp+80h]
    setb    cl
    mov     [rsp+60h],cl
    movzx   edx,byte ptr [rsp+60h]
    mov     [rsp+6Fh],dl
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    lea     rdi,[k0]
    mov     qword ptr [rsp+78h],0B8h
    mov     r9,[rsp+78h]
    lea     r10,[k1]
    mov     qword ptr [rsp+28h],0B8h
    mov     rsi,[rsp+28h]
    shl     rsi,1
    or      rsi,1
    mov     [rsp+58h],rdi
    mov     [rsp+60h],rsi
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,98h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u64>::wrapping_add [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    add     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u64>::wrapping_mul [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    imul    rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl usize>::unchecked_add::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+80h]
    add     rax,rdx
    setb    cl
    mov     [rsp+60h],cl
    movzx   esi,byte ptr [rsp+60h]
    mov     [rsp+6Fh],sil
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    lea     r8,[k0]
    mov     qword ptr [rsp+78h],0BAh
    mov     r10,[rsp+78h]
    lea     r11,[k1]
    mov     qword ptr [rsp+28h],0BAh
    mov     rdi,[rsp+28h]
    shl     rdi,1
    or      rdi,1
    mov     [rsp+58h],r8
    mov     [rsp+60h],rdi
    mov     byte ptr [rsp+17h],0
    mov     r9,[rsp+18h]
    mov     [rsp+8],r9
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,98h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::ub_checks::maybe_is_nonoverlapping::runtime [hint]
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+80h],rdx
    mov     [rsp+78h],rcx
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+80h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+78h]
    mov     rax,[rsp+48h]
    mul     rdi
    mov     [rsp+28h],rax
    setb    cl
    mov     [rsp+30h],cl
    movzx   r8d,byte ptr [rsp+30h]
    mov     [rsp+63h],r8b
    mov     [rsp+18h],rax
    test    byte ptr [rsp+63h],0FFh
    je      L1
    lea     r10,[k0]
    mov     [rsp+8],r10
    mov     qword ptr [rsp+10h],3Dh
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     rax,[rsp+18h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+58h]
    cmp     rsi,[rsp+50h]
    jae     L2
    mov     rdi,[rsp+50h]
    sub     rdi,rsi
    mov     [rsp+70h],rdi
    jmp     L3
L2:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+50h]
    mov     [rsp+70h],rax
L3:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+70h]
    setbe   [rsp+9Fh]
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::control::group::sse2::Group::convert_special_to_empty_and_full_to_deleted [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0A8h
    mov     [rsp+78h],rdi
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF88h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+60h]
    call    fn0
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdx
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn1
    mov     byte ptr [rsp+27h],80h
    lea     rdi,[rsp+30h]
    movzx   esi,byte ptr [rsp+27h]
    call    fn2
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    lea     rdi,[rsp+40h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn3
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+78h]
    add     rsp,0A8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::get::<u64> [hint]
    inc     qword ptr [jit_record]
    jns     L17
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+78h],rsi
    mov     rax,[rsp+80h]
    mov     rax,[rax+18h]
    cmp     rax,0
    sete    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L1
    mov     qword ptr [rsp+88h],0
    jmp     L2
L1:
    mov     rax,[rsp+80h]
    lea     rax,[rax+20h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+78h]
    call    fn0
    mov     [rsp+50h],rax
    jmp     L4
    ud2
    nop     [rax+rax]
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L3:
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
L4:
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+38h]
    call    fn1
    mov     [rsp+30h],rax
    cmp     qword ptr [rsp+30h],0
    jne     L5
    mov     qword ptr [rsp+88h],0
    jmp     L2
L5:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L7:
    mov     rax,[rsp+18h]
    lea     rax,[rax+8]
    mov     [rsp+88h],rax
    jmp     L2
L8:
    ud2
L9:
    mov     rax,[rsp+8]
    mov     [rsp+10h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L11:
    jmp     L6
L12:
    ud2
L13:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+10h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+18h],rdx
    jmp     L10
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L15:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L16:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L11
L17:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::iter
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,0D8h
    mov     [rsp+88h],rdi
    mov     [rsp+0A0h],rsi
    mov     rax,[rsp+0A0h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L4
    jmp     L3
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+48h]
    mov     r8,[rsp+50h]
    mov     [rsp+0A8h],rdx
    mov     [rsp+0B0h],rsi
    mov     [rsp+0B8h],rdi
    mov     [rsp+0C0h],r8
    mov     [rsp+0C8h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+88h]
    add     rsp,0D8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+0A0h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+28h]
    call    fn0
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::retain::<{closure@bench/hashmap.rs:27:16: 27:22}>
    inc     qword ptr [jit_record]
    jns     L36
L0:
    sub     rsp,0E8h
    mov     [rsp+0D8h],rdi
    mov     rax,[rsp+0D8h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L18
    jmp     L19
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L4:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L23
    jmp     L22
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L6:
    jmp     L11
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L8:
    test    byte ptr [rsp+2Fh],0FFh
    je      L9
    jmp     L10
L9:
    mov     rax,[rsp+0D8h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+40h]
    call    fn0
L10:
    jmp     L1
L11:
    add     rsp,0E8h
    ret
    nop
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L13:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF98h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L15:
    mov     rax,[rsp+0D8h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     r8,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp+68h],r8
    mov     [rsp+70h],rax
    jmp     L1
L16:
    ud2
L17:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0D8h]
    mov     rdx,[rdx]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+0D8h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+40h]
    call    fn1
    jmp     L14
L18:
    mov     qword ptr [rsp+48h],0
    jmp     L5
L19:
    lea     rax,[rsp+50h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    call    fn2
    mov     [rsp+48h],rax
    mov     rax,[rsp+70h]
    sub     rax,1
    mov     [rsp+70h],rax
    cmp     qword ptr [rsp+48h],0
    je      L5
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L21:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+8]
    lea     rsi,[rsp+0D8h]
    mov     [rsp+20h],rsi
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn3
    mov     [rsp+2Fh],al
    jmp     L7
L22:
    ud2
L23:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L27
    jmp     L26
    xchg    ax,ax
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L25:
    jmp     L20
L26:
    ud2
L27:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L24
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L12
L28:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L29:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L30:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L31:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L32:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L33:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L34:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L21
L35:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L25
L36:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::make_hasher::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::FullBucketsIndices::next_impl [always]
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0C8h
    mov     [rsp+0A8h],rdi
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+0A8h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+2Eh],ax
    cmp     ax,0
    je      L4
    jmp     L3
    ud2
L3:
    movzx   eax,word ptr [rsp+2Eh]
    mov     [rsp+16h],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+10h],eax
    mov     edx,[rsp+10h]
    mov     [rsp+28h],edx
    jmp     L5
L4:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+38h],0
    cmp     qword ptr [rsp+38h],0
    sete    [rsp+37h]
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi]
    mov     qword ptr [rsp+8],10h
    imul    rcx,[rsp+8],1
    add     rsi,rcx
    mov     [rsp+48h],rsi
    mov     r8,[rsp+0A8h]
    mov     rcx,[rsp+48h]
    mov     [r8],rcx
    mov     r9,[rsp+0A8h]
    mov     r9,[r9]
    mov     [rsp+90h],r9
    mov     r10,[rsp+90h]
    mov     [rsp+40h],r10
    mov     r11,[rsp+90h]
    mov     [rsp+38h],r11
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+38h]
    call    fn1
    jmp     L6
L5:
    mov     eax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    mov     [rsp+78h],rax
    mov     rsi,[rsp+0A8h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rsp+38h],si
    sub     esi,1
    mov     [rsp+3Ah],si
    movzx   edi,word ptr [rsp+38h]
    and     di,[rsp+3Ah]
    mov     [rsp+3Ch],di
    movzx   r8d,word ptr [rsp+3Ch]
    mov     [rsp+3Eh],r8w
    mov     r9,[rsp+0A8h]
    movzx   ecx,word ptr [rsp+3Eh]
    mov     [r9+18h],cx
    mov     r10,[rsp+78h]
    mov     qword ptr [rsp+40h],1
    mov     rdx,[rsp+0A8h]
    mov     rdx,[rdx+8]
    add     rdx,r10
    mov     [rsp+0B8h],rdx
    mov     qword ptr [rsp+0B0h],1
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    add     rsp,0C8h
    ret
L6:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn2
    mov     [rsp+44h],eax
    mov     eax,[rsp+44h]
    mov     [rsp+48h],ax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF8Ah
    mov     edx,0FFFFFF88h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+4Ah]
    mov     [rsp+4Eh],ax
    mov     rdx,[rsp+0A8h]
    movzx   ecx,word ptr [rsp+4Eh]
    mov     [rdx+18h],cx
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi+8]
    add     rsi,10h
    mov     [rsp],rsi
    mov     rdi,[rsp+0A8h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    jmp     L1
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::new
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0D8h
    mov     [rsp+28h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+98h],rcx
    mov     rax,[rsp+0A8h]
    imul    rcx,[rsp+98h],1
    add     rax,rcx
    mov     [rsp+20h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn1
    mov     [rsp+18h],eax
    mov     eax,[rsp+18h]
    mov     [rsp+1Ch],ax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Eh
    mov     edx,0FFFFFF4Ch
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+1Eh]
    mov     qword ptr [rsp+8],10h
    mov     rsi,[rsp+0A8h]
    imul    rcx,[rsp+8],1
    add     rsi,rcx
    mov     [rsp+0C8h],ax
    mov     rdi,[rsp+0A0h]
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     r8,[rsp+20h]
    mov     [rsp+0C0h],r8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF58h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,0D8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    inc     qword ptr [jit_record]
    jns     L35
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    mov     rax,[rsp+0D0h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+3Eh],ax
    cmp     ax,0
    je      L10
    jmp     L9
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L4:
    ud2
    ud2
    ud2
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L6:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+0B0h],rax
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    call    fn0
    jmp     L19
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L8:
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
    ud2
L9:
    movzx   eax,word ptr [rsp+3Eh]
    mov     [rsp+26h],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+14h],eax
    mov     edx,[rsp+14h]
    mov     [rsp+38h],edx
    jmp     L11
L10:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+48h],0
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+47h]
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L5
    jmp     L3
L11:
    mov     eax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+90h],rax
    mov     rsi,[rsp+0D0h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rsp+48h],si
    sub     esi,1
    mov     [rsp+4Ah],si
    movzx   edi,word ptr [rsp+48h]
    and     di,[rsp+4Ah]
    mov     [rsp+4Ch],di
    movzx   r8d,word ptr [rsp+4Ch]
    mov     [rsp+4Eh],r8w
    mov     r9,[rsp+0D0h]
    movzx   ecx,word ptr [rsp+4Eh]
    mov     [r9+18h],cx
    mov     r10,[rsp+90h]
    mov     qword ptr [rsp+50h],1
    mov     [rsp+48h],r10
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L12
    ud2
L12:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L14:
    mov     rax,[rsp+38h]
    mov     [rsp+0D8h],rax
    jmp     L7
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L16:
    jmp     L13
L17:
    ud2
L18:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L15
L19:
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn2
    mov     [rsp+54h],eax
    mov     eax,[rsp+54h]
    mov     [rsp+58h],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF7Ah
    mov     edx,0FFFFFF78h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+5Ah]
    mov     [rsp+5Eh],ax
    mov     rdx,[rsp+0D0h]
    movzx   ecx,word ptr [rsp+5Eh]
    mov     [rdx+18h],cx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    ud2
L20:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
    xchg    ax,ax
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L22:
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0D0h]
    mov     rcx,[rsp+58h]
    mov     [rdx],rcx
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi+8]
    mov     qword ptr [rsp+10h],10h
    imul    rcx,[rsp+10h],1
    add     rsi,rcx
    mov     [rsp+58h],rsi
    mov     r8,[rsp+0D0h]
    mov     rcx,[rsp+58h]
    mov     [r8+8],rcx
    jmp     L1
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L24:
    jmp     L21
L25:
    ud2
L26:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+10h],20h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L23
L27:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L28:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L16
L33:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L34:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L24
L35:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:28:43: 28:50}>::{closure#0}}>::{closure#0}}, u64>
    inc     qword ptr [jit_record]
    jns     L46
L0:
    sub     rsp,128h
    mov     [rsp+18h],rdi
    mov     [rsp+0F0h],rsi
    mov     [rsp+0E8h],rdx
    mov     [rsp+0E0h],rcx
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFEF8h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     byte ptr [rsp+0B7h],1
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L2:
    movzx   eax,word ptr [rsp+110h]
    mov     [rsp+46h],ax
    cmp     ax,0
    je      L18
    jmp     L17
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L4:
    mov     byte ptr [rsp+0B7h],1
    mov     rdx,[rsp+40h]
    mov     [rsp+0E8h],rdx
    mov     rsi,[rsp+0F0h]
    sub     rsi,1
    mov     [rsp+0F0h],rsi
    jmp     L1
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L6:
    mov     byte ptr [rsp+0B7h],0
    mov     rdx,[rsp+0E8h]
    mov     [rsp+118h],rdx
    jmp     L9
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L8:
    mov     rax,[rsp+100h]
    mov     [rsp+0C0h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+70h]
    mov     rsi,[rsp+50h]
    call    fn0
    jmp     L27
L9:
    mov     rax,[rsp+118h]
    add     rsp,128h
    ret
    nop     [rax+rax]
    nop     [rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L11:
    jmp     L16
    nop
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L40
L13:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF48h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L41
L15:
    jmp     L12
L16:
    test    byte ptr [rsp+0B7h],0FFh
    je      L12
    jmp     L14
    ud2
L17:
    movzx   eax,word ptr [rsp+46h]
    mov     [rsp+2Eh],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+14h],eax
    mov     edx,[rsp+14h]
    mov     [rsp+40h],edx
    jmp     L19
L18:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF28h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+50h],0
    cmp     qword ptr [rsp+50h],0
    sete    [rsp+4Fh]
    mov     rsi,[rsp+0F0h]
    mov     [rsp+60h],rsi
    cmp     rsi,0
    je      L5
    jmp     L7
L19:
    mov     eax,[rsp+40h]
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],1
    movzx   esi,word ptr [rsp+110h]
    mov     [rsp+50h],si
    sub     esi,1
    mov     [rsp+52h],si
    movzx   edi,word ptr [rsp+50h]
    and     di,[rsp+52h]
    mov     [rsp+54h],di
    movzx   r8d,word ptr [rsp+54h]
    mov     [rsp+110h],r8w
    mov     qword ptr [rsp+58h],1
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    ud2
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L42
L22:
    mov     rax,[rsp+40h]
    lea     rdx,[rsp+0E0h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0B7h],0
    mov     rdi,[rsp+0E8h]
    mov     [rsp+28h],rdi
    mov     [rsp+30h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+30h]
    call    fn2
    mov     [rsp+40h],rax
    jmp     L3
    nop     [rax+rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L43
L24:
    jmp     L21
L25:
    ud2
L26:
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+38h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+40h],rdi
    jmp     L23
L27:
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn3
    mov     [rsp+5Ch],eax
    mov     eax,[rsp+5Ch]
    mov     [rsp+60h],ax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF42h
    mov     edx,0FFFFFF40h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+62h]
    mov     [rsp+110h],ax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L28
    ud2
L28:
    mov     rax,[rsp+0F8h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L34
    jmp     L33
L29:
    inc     qword ptr [jit_record.ctr_l]
    jns     L44
L30:
    mov     rax,[rsp+58h]
    mov     [rsp+0F8h],rax
    mov     rdx,[rsp+100h]
    mov     qword ptr [rsp+10h],10h
    imul    rcx,[rsp+10h],1
    add     rdx,rcx
    mov     [rsp+100h],rdx
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L31:
    inc     qword ptr [jit_record.ctr_l]
    jns     L45
L32:
    jmp     L29
L33:
    ud2
L34:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+10h],10h
    add     rdx,rcx
    mov     [rsp+58h],rdx
    jmp     L31
    lea     rdi,[rsp+120h]
    mov     rsi,rax
    mov     edx,0FFFFFF48h
    call    ryo_h_Lpad
    jmp     L10
L35:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L36:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L37:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L38:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L39:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L40:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L13
L41:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L15
L42:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L22
L43:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L24
L44:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L30
L45:
    lea     r11,[jit_record]
    mov     eax,0Ah
    call    qword ptr [r11+10h]
    jmp     L32
L46:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(u64, u64)>::new
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0D8h
    mov     [rsp+28h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+98h],rcx
    mov     rax,[rsp+0A8h]
    imul    rcx,[rsp+98h],1
    add     rax,rcx
    mov     [rsp+20h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn1
    mov     [rsp+18h],eax
    mov     eax,[rsp+18h]
    mov     [rsp+1Ch],ax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Eh
    mov     edx,0FFFFFF4Ch
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+1Eh]
    mov     qword ptr [rsp+8],10h
    mov     rsi,[rsp+0A8h]
    imul    rcx,[rsp+8],1
    add     rsi,rcx
    mov     [rsp+0C8h],ax
    mov     rdi,[rsp+0A0h]
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     r8,[rsp+20h]
    mov     [rsp+0C0h],r8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF58h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,0D8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    inc     qword ptr [jit_record]
    jns     L35
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    mov     rax,[rsp+0D0h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+3Eh],ax
    cmp     ax,0
    je      L10
    jmp     L9
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L4:
    ud2
    ud2
    ud2
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L6:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+0B0h],rax
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    call    fn0
    jmp     L19
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L8:
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
    ud2
L9:
    movzx   eax,word ptr [rsp+3Eh]
    mov     [rsp+26h],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+14h],eax
    mov     edx,[rsp+14h]
    mov     [rsp+38h],edx
    jmp     L11
L10:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+48h],0
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+47h]
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L5
    jmp     L3
L11:
    mov     eax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     [rsp+90h],rax
    mov     rsi,[rsp+0D0h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rsp+48h],si
    sub     esi,1
    mov     [rsp+4Ah],si
    movzx   edi,word ptr [rsp+48h]
    and     di,[rsp+4Ah]
    mov     [rsp+4Ch],di
    movzx   r8d,word ptr [rsp+4Ch]
    mov     [rsp+4Eh],r8w
    mov     r9,[rsp+0D0h]
    movzx   ecx,word ptr [rsp+4Eh]
    mov     [r9+18h],cx
    mov     r10,[rsp+90h]
    mov     qword ptr [rsp+50h],1
    mov     [rsp+48h],r10
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L12
    ud2
L12:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L14:
    mov     rax,[rsp+38h]
    mov     [rsp+0D8h],rax
    jmp     L7
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L16:
    jmp     L13
L17:
    ud2
L18:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L15
L19:
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn2
    mov     [rsp+54h],eax
    mov     eax,[rsp+54h]
    mov     [rsp+58h],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF7Ah
    mov     edx,0FFFFFF78h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+5Ah]
    mov     [rsp+5Eh],ax
    mov     rdx,[rsp+0D0h]
    movzx   ecx,word ptr [rsp+5Eh]
    mov     [rdx+18h],cx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    ud2
L20:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
    xchg    ax,ax
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L22:
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0D0h]
    mov     rcx,[rsp+58h]
    mov     [rdx],rcx
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi+8]
    mov     qword ptr [rsp+10h],10h
    imul    rcx,[rsp+10h],1
    add     rsi,rcx
    mov     [rsp+58h],rsi
    mov     r8,[rsp+0D0h]
    mov     rcx,[rsp+58h]
    mov     [r8+8],rcx
    jmp     L1
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L24:
    jmp     L21
L25:
    ud2
L26:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+10h],10h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L23
L27:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L28:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L16
L33:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L34:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L24
L35:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L19
L0:
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+0A0h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+90h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+20h]
    mov     [rsp+38h],rdi
    lea     r8,[k0]
    mov     [rsp+40h],r8
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    cmp     rax,0
    je      L1
    jmp     L2
    ud2
L1:
    mov     qword ptr [rsp+0A8h],0
    jmp     L3
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L7:
    ud2
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L11
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5
L15:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L16:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L17:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L19:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    jmp     L5
L9:
    ud2
L10:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L7
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L1
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    ud2
L18:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],20h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L15
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    inc     qword ptr [jit_record]
    jns     L30
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    mov     [rsp+0C8h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFF38h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+0D0h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+0C8h]
    call    fn0
    mov     [rsp+88h],rax
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L2:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L4:
    lea     rax,[rsp+0A8h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn1
    jmp     L1
L5:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    imul    rcx,[rsp+88h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+5Fh],al
    mov     rdx,[rsp+0C8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+4Eh],dl
    movzx   esi,byte ptr [rsp+4Eh]
    mov     [rsp+4Fh],sil
    mov     rdi,[rsp+88h]
    sub     rdi,10h
    mov     r8,[rsp+0D0h]
    mov     r8,[r8+8]
    and     rdi,r8
    add     rdi,10h
    mov     [rsp+40h],rdi
    mov     r9,[rsp+0D0h]
    mov     r9,[r9]
    imul    rcx,[rsp+88h],1
    add     r9,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r9],cl
    mov     r10,[rsp+0D0h]
    mov     r10,[r10]
    imul    rcx,[rsp+40h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r10],cl
    mov     r11,[rsp+0D0h]
    mov     r11,[r11]
    mov     [rsp+40h],r11
    mov     [rsp+48h],r11
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L6
    ud2
L6:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L8:
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+0D8h],rax
    movzx   edx,byte ptr [rsp+5Fh]
    and     dl,1
    mov     [rsp+46h],dl
    cmp     byte ptr [rsp+46h],0
    setne   [rsp+47h]
    movzx   edi,byte ptr [rsp+47h]
    mov     r8,[rsp+0D0h]
    mov     r8,[r8+10h]
    sub     r8,rdi
    mov     [rsp],r8
    mov     r9,[rsp+0D0h]
    mov     rcx,[rsp]
    mov     [r9+10h],rcx
    mov     r10,[rsp+0A8h]
    mov     [rsp+30h],r10
    mov     r11,[rsp+0B0h]
    mov     [rsp+38h],r11
    mov     rax,[rsp+0B8h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L10:
    jmp     L7
L11:
    ud2
L12:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L9
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L14:
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rax],rcx
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+38h]
    mov     [rdx+8],rcx
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+40h]
    mov     [rsi+10h],rcx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+48h]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+0D0h]
    mov     r8,[r8+18h]
    add     r8,1
    mov     [rsp],r8
    mov     r9,[rsp+0D0h]
    mov     rcx,[rsp]
    mov     [r9+18h],rcx
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
L15:
    ud2
L16:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    jmp     L19
    nop     [rax+rax]
    nop     [rax+rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L18:
    jmp     L13
L19:
    ud2
L20:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+20h]
    imul    rcx,[rsp+10h],20h
    add     rdx,rcx
    mov     [rsp+28h],rdx
    jmp     L17
    nop     [rax+rax]
    nop     [rax+rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L22:
    call    qword ptr [sym2]
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF70h
    call    ryo_h_Lpad
    jmp     L3
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF70h
    call    ryo_h_Lpad
    jmp     L21
L23:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L24:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L25:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L26:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L27:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L28:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L18
L29:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L30:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     [rsp+48h],rdx
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    cmp     rax,[rsp+50h]
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    cmp     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    setne   [rsp+7]
    movzx   edx,byte ptr [rsp+7]
    cmp     rdx,0
    sete    [rsp+2Fh]
    nop     [rax+rax]
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    add     rsp,68h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L8:
    jmp     L5
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L7
L11:
    mov     byte ptr [rsp+47h],0
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     byte ptr [rsp+7],1
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+8]
    movzx   ecx,byte ptr [rsp+7]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    jmp     L1
L12:
    jmp     L3
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L9
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L17:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}> [never, cold]
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+87h],cl
    mov     rax,[rsp+98h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+98h]
    lea     rdx,[rdx+20h]
    mov     [rsp+68h],rdx
    lea     rsi,[rsp+88h]
    mov     [rsp+48h],rsi
    lea     rdi,[rsp+48h]
    mov     [rsp+58h],rdi
    lea     r8,[k0]
    mov     [rsp+60h],r8
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L1
    mov     r11,[sym1]
    mov     [rsp+40h],r11
    jmp     L2
L1:
    ud2
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+28h]
    mov     [rsp],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+58h]
    mov     r8,[rsp+60h]
    movzx   r9d,byte ptr [rsp+87h]
    call    fn3
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rdx
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L3
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+80h],rdx
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+88h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    jmp     L5
L9:
    ud2
L10:
    mov     rax,[rsp+80h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L7
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+98h],rax
    jmp     L1
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    ud2
L18:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],20h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L15
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#1}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    lea     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+20h]
    call    fn0
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    jmp     L9
L3:
    ud2
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    jmp     L1
L7:
    ud2
L8:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L5
L9:
    add     rsp,48h
    ret
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+1Dh],0
    test    byte ptr [rsp+1Dh],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    add     rsp,68h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L4:
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    call    fn0
    jmp     L1
L5:
    ud2
L6:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],10h
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L10
    jmp     L9
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L8:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    jmp     L3
L9:
    mov     qword ptr [rsp+10h],10h
    mov     rdx,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rsp+1Eh]
    test    byte ptr [rsp+1Eh],0FFh
    je      L10
    mov     rdi,[rsp+30h]
    sub     rdi,[rsp+28h]
    sar     rdi,4
    mov     [rsp+20h],rdi
    jmp     L7
L10:
    lea     rax,[k1]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k2]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym3]
    ud2
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L13:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L19
L0:
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+0A0h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+90h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+20h]
    mov     [rsp+38h],rdi
    lea     r8,[k0]
    mov     [rsp+40h],r8
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    cmp     rax,0
    je      L1
    jmp     L2
    ud2
L1:
    mov     qword ptr [rsp+0A8h],0
    jmp     L3
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L7:
    ud2
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L11
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5
L15:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L16:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L17:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L19:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    jmp     L5
L9:
    ud2
L10:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L7
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L1
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    ud2
L18:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L15
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L19
L0:
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+0A0h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+90h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+20h]
    mov     [rsp+38h],rdi
    lea     r8,[k0]
    mov     [rsp+40h],r8
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    cmp     rax,0
    je      L1
    jmp     L2
    ud2
L1:
    mov     qword ptr [rsp+0A8h],0
    jmp     L3
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L7:
    ud2
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L11
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5
L15:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L16:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L17:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L19:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    jmp     L5
L9:
    ud2
L10:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L7
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L1
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    ud2
L18:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L15
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    inc     qword ptr [jit_record]
    jns     L27
L0:
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rcx
    mov     rax,[rsp+0B0h]
    mov     [rsp+38h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+0A8h]
    call    fn0
    mov     [rsp+78h],rax
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L2:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L4:
    jmp     L1
L5:
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    imul    rcx,[rsp+78h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+4Fh],al
    mov     rdx,[rsp+0A8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+3Eh],dl
    movzx   esi,byte ptr [rsp+3Eh]
    mov     [rsp+3Fh],sil
    mov     rdi,[rsp+78h]
    sub     rdi,10h
    mov     r8,[rsp+0B0h]
    mov     r8,[r8+8]
    and     rdi,r8
    add     rdi,10h
    mov     [rsp+30h],rdi
    mov     r9,[rsp+0B0h]
    mov     r9,[r9]
    imul    rcx,[rsp+78h],1
    add     r9,rcx
    movzx   ecx,byte ptr [rsp+3Fh]
    mov     [r9],cl
    mov     r10,[rsp+0B0h]
    mov     r10,[r10]
    imul    rcx,[rsp+30h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+3Fh]
    mov     [r10],cl
    mov     r11,[rsp+0B0h]
    mov     r11,[r11]
    mov     [rsp+30h],r11
    mov     [rsp+38h],r11
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L6
    ud2
L6:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L8:
    mov     rax,[rsp+28h]
    mov     [rsp+50h],rax
    mov     [rsp+0B8h],rax
    movzx   edx,byte ptr [rsp+4Fh]
    and     dl,1
    mov     [rsp+36h],dl
    cmp     byte ptr [rsp+36h],0
    setne   [rsp+37h]
    movzx   edi,byte ptr [rsp+37h]
    mov     r8,[rsp+0B0h]
    mov     r8,[r8+10h]
    sub     r8,rdi
    mov     [rsp],r8
    mov     r9,[rsp+0B0h]
    mov     rcx,[rsp]
    mov     [r9+10h],rcx
    mov     r10,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],r10
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L16
    jmp     L15
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L10:
    jmp     L7
L11:
    ud2
L12:
    mov     rax,[rsp+78h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L9
    nop     [rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L14:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    xor     edx,edx
    mov     ecx,0FFFFFF70h
    call    ryo_h_StoreW128
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+18h]
    add     rax,1
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
L15:
    ud2
L16:
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L20
    jmp     L19
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L18:
    jmp     L13
L19:
    ud2
L20:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+20h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+28h],rdx
    jmp     L17
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFF80h
    call    ryo_h_Lpad
    jmp     L3
L21:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L22:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L23:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L24:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L25:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L26:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L18
L27:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     [rsp+48h],rdx
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    cmp     rax,[rsp+50h]
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    cmp     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    setne   [rsp+7]
    movzx   edx,byte ptr [rsp+7]
    cmp     rdx,0
    sete    [rsp+2Fh]
    nop     [rax+rax]
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    add     rsp,68h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L8:
    jmp     L5
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L7
L11:
    mov     byte ptr [rsp+47h],0
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     byte ptr [rsp+7],1
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+8]
    movzx   ecx,byte ptr [rsp+7]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    jmp     L1
L12:
    jmp     L3
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L9
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L17:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}> [never, cold]
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+87h],cl
    mov     rax,[rsp+98h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+98h]
    lea     rdx,[rdx+20h]
    mov     [rsp+68h],rdx
    lea     rsi,[rsp+88h]
    mov     [rsp+48h],rsi
    lea     rdi,[rsp+48h]
    mov     [rsp+58h],rdi
    lea     r8,[k0]
    mov     [rsp+60h],r8
    mov     byte ptr [rsp+37h],0
    test    byte ptr [rsp+37h],0FFh
    je      L1
    ud2
L1:
    mov     qword ptr [rsp+40h],0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+28h]
    mov     [rsp],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+58h]
    mov     r8,[rsp+60h]
    movzx   r9d,byte ptr [rsp+87h]
    call    fn2
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rdx
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L3:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L2
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+80h],rdx
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+88h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L3:
    ud2
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    jmp     L5
L9:
    ud2
L10:
    mov     rax,[rsp+80h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L7
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+98h],rax
    jmp     L1
L13:
    ud2
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    ud2
L18:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L15
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    inc     qword ptr [jit_record]
    jns     L29
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi+18h]
    mov     [rsp+58h],rsi
    cmp     rsi,0
    je      L7
    mov     r8,[rsp+0A8h]
    mov     r8,[r8]
    mov     [rsp+20h],r8
    mov     [rsp+50h],r8
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L12
    jmp     L13
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L6:
    jmp     L7
L7:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L9:
    mov     rax,[rsp+0A8h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdi,[rsp+48h]
    mov     r8,[rsp+50h]
    mov     [rsp+38h],rdx
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdi
    mov     [rsp+50h],r8
    mov     [rsp+58h],rax
    jmp     L1
L10:
    ud2
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A8h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+28h]
    call    fn0
    jmp     L8
L12:
    mov     qword ptr [rsp+30h],0
    jmp     L5
L13:
    lea     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn1
    mov     [rsp+30h],rax
    mov     rax,[rsp+58h]
    sub     rax,1
    mov     [rsp+58h],rax
    cmp     qword ptr [rsp+30h],0
    je      L5
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L15:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn2
    jmp     L22
L16:
    ud2
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L19:
    jmp     L14
L20:
    ud2
L21:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],20h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L18
L22:
    jmp     L1
L23:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L24:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L25:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L26:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L27:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L15
L28:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L29:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L1
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
L1:
    add     rsp,0B8h
    ret
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_inner_table::<(std::string::String, usize), std::alloc::Global>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    mov     rax,[rsp+88h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    jne     L1
    mov     rdi,[rsp+88h]
    call    fn0
    mov     rax,[rsp+88h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rsp+30h],rax
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    mov     rcx,[rsp+30h]
    call    fn1
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    add     rsp,98h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    jmp     L1
L5:
    cmp     qword ptr [rsp+38h],0
    setne   [rsp+7]
    movzx   edx,byte ptr [rsp+7]
    cmp     rdx,1
    sete    [rsp+56h]
    mov     rdi,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+48h]
    mov     r9,[rsp+88h]
    mov     r9,[r9]
    mov     qword ptr [rsp],0
    mov     r11,[rsp]
    sub     r11,r8
    imul    rcx,r11,1
    add     r9,rcx
    mov     [rsp+28h],r9
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    call    fn2
    jmp     L3
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_inner_table::<(u64, u64), std::alloc::Global>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    mov     rax,[rsp+88h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    jne     L1
    mov     rdi,[rsp+88h]
    call    fn0
    mov     rax,[rsp+88h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rsp+30h],rax
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    mov     rcx,[rsp+30h]
    call    fn1
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    add     rsp,98h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    jmp     L1
L5:
    cmp     qword ptr [rsp+38h],0
    setne   [rsp+7]
    movzx   edx,byte ptr [rsp+7]
    cmp     rdx,1
    sete    [rsp+56h]
    mov     rdi,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+48h]
    mov     r9,[rsp+88h]
    mov     r9,[r9]
    mov     qword ptr [rsp],0
    mov     r11,[rsp]
    sub     r11,r8
    imul    rcx,r11,1
    add     r9,rcx
    mov     [rsp+28h],r9
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    call    fn2
    jmp     L3
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::erase [hint]
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     rax,[rsp+0B0h]
    sub     rax,10h
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi]
    imul    rcx,rax,1
    add     rsi,rcx
    mov     [rsp+90h],rsi
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+90h]
    mov     [rsp+40h],rdi
    lea     rdi,[rsp+80h]
    mov     rsi,[rsp+40h]
    call    fn0
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     byte ptr [rsp+9Fh],80h
    jmp     L5
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+10h]
    mov     [rdx+10h],rcx
    mov     byte ptr [rsp+9Fh],0FFh
L5:
    mov     rax,[rsp+0B0h]
    sub     rax,10h
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    add     rax,10h
    mov     [rsp+48h],rax
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi]
    imul    rcx,[rsp+0B0h],1
    add     rsi,rcx
    movzx   ecx,byte ptr [rsp+9Fh]
    mov     [rsi],cl
    mov     rdi,[rsp+0B8h]
    mov     rdi,[rdi]
    imul    rcx,[rsp+48h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+9Fh]
    mov     [rdi],cl
    mov     r8,[rsp+0B8h]
    mov     r8,[r8+18h]
    sub     r8,1
    mov     [rsp+10h],r8
    mov     r9,[rsp+0B8h]
    mov     rcx,[rsp+10h]
    mov     [r9+18h],rcx
    add     rsp,0C8h
    ret
L6:
    mov     byte ptr [rsp+27h],0FFh
    lea     rdi,[rsp+30h]
    movzx   esi,byte ptr [rsp+27h]
    call    fn1
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    lea     rdi,[rsp+40h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn2
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    fn3
    mov     [rsp+3Ch],eax
    mov     eax,[rsp+3Ch]
    mov     [rsp+7Eh],ax
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx]
    imul    rcx,[rsp+0B0h],1
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+40h]
    call    fn4
    mov     byte ptr [rsp+27h],0FFh
    lea     rdi,[rsp+30h]
    movzx   esi,byte ptr [rsp+27h]
    call    fn5
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    lea     rdi,[rsp+40h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn6
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    fn7
    mov     [rsp+3Ch],eax
    mov     eax,[rsp+3Ch]
    mov     [rsp+5Eh],ax
    movzx   edx,word ptr [rsp+7Eh]
    bsr     edx,edx
    mov     ecx,1Fh
    cmove   edx,ecx
    xor     edx,0Fh
    mov     [rsp+40h],rdx
    movzx   esi,word ptr [rsp+5Eh]
    or      esi,10000h
    bsf     esi,esi
    mov     [rsp+24h],esi
    mov     edi,[rsp+24h]
    mov     [rsp+34h],edi
    add     rdx,rdi
    mov     [rsp+48h],rdx
    cmp     rdx,10h
    jae     L1
    jmp     L3
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::fallible_with_capacity::<std::alloc::Global> [hint]
    inc     qword ptr [jit_record]
    jns     L16
L0:
    sub     rsp,118h
    mov     [rsp+80h],rdi
    mov     [rsp+0E8h],rsi
    mov     [rsp+0D8h],rdx
    mov     [rsp+0E0h],rcx
    mov     [rsp+0D0h],r8
    mov     [rsp+0CFh],r9b
    cmp     qword ptr [rsp+0D0h],0
    jne     L1
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    mov     ecx,20h
    call    ryo_h_Const
    jmp     L4
L1:
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     rdx,[rsp+0E0h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L8
    jmp     L9
    ud2
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L3:
    cmp     qword ptr [rsp+40h],0
    je      L11
    jmp     L12
    xchg    ax,ax
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L5:
    jmp     L6
    nop
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L7:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF70h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+80h]
    add     rsp,118h
    ret
L8:
    movzx   edi,byte ptr [rsp+0CFh]
    call    qword ptr [sym2]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    jmp     L10
L9:
    mov     rax,[rsp+58h]
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+60h],0FFFFFFFFFFFFFFFFh
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+70h],0FFFFFFFFFFFFFFFFh
    mov     [rsp+0B8h],rax
    lea     rdi,[rsp+40h]
    mov     rsi,[rsp+0E8h]
    mov     rdx,[rsp+0D8h]
    mov     rcx,[rsp+0E0h]
    mov     r8,[rsp+0B8h]
    movzx   r9d,byte ptr [rsp+0CFh]
    call    fn3
    jmp     L2
L10:
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+68h],rcx
    mov     rcx,[rsp+68h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+48h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     rcx,[rsp+78h]
    mov     [rsp+68h],rcx
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+58h],1
    cmp     qword ptr [rsp+58h],1
    sete    [rsp+47h]
    mov     rcx,[rsp+68h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+100h],rcx
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+0F0h],0
    jmp     L6
L11:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+20h]
    mov     [rsp+70h],rcx
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+60h],0
    mov     rcx,[rsp+70h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],1
    cmp     qword ptr [rsp+48h],1
    sete    [rsp+37h]
    mov     rcx,[rsp+58h]
    mov     [rsp+40h],rcx
    mov     rcx,[rsp+40h]
    mov     [rsp+100h],rcx
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+0F0h],0
    jmp     L6
L12:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdi,[rsp+58h]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],rdi
    add     rdx,1
    add     rdx,10h
    mov     [rsp+88h],rdx
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+17h],0FFh
    imul    r9,[rsp+88h],1
    mov     [rsp+8],r9
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF07h
    mov     ecx,0FFFFFEF8h
    call    ryo_h_Memset
    mov     rax,[rsp+98h]
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+0F8h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+100h],rsi
    mov     rdi,[rsp+0B0h]
    mov     [rsp+108h],rdi
    jmp     L4
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L16:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::find_inner [always]
    inc     qword ptr [jit_record]
    jns     L22
L0:
    sub     rsp,108h
    mov     [rsp+0E8h],rdi
    mov     [rsp+0E0h],rsi
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rcx
    mov     rax,[rsp+0E0h]
    shr     rax,39h
    and     rax,7Fh
    mov     [rsp+0B7h],al
    mov     rdx,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    mov     [rsp+60h],rdx
    mov     qword ptr [rsp+68h],0
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L2:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+0E8h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+90h]
    mov     rsi,[rsp+50h]
    call    fn0
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L4:
    movzx   eax,word ptr [rsp+0CEh]
    mov     [rsp+74h],ax
    cmp     ax,0
    je      L11
    jmp     L10
    ud2
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    test    byte ptr [rsp+75h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    mov     rax,[rsp+0F0h]
    mov     rdx,[rsp+0F8h]
    add     rsp,108h
    ret
L9:
    movzx   eax,byte ptr [rsp+0B7h]
    mov     [rsp+73h],al
    lea     rdi,[rsp+40h]
    movzx   esi,byte ptr [rsp+73h]
    call    fn1
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    lea     rdi,[rsp+50h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn2
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    fn3
    mov     [rsp+4Ch],eax
    mov     eax,[rsp+4Ch]
    mov     [rsp+72h],ax
    movzx   edx,word ptr [rsp+72h]
    mov     [rsp+0CEh],dx
    jmp     L3
L10:
    movzx   eax,word ptr [rsp+74h]
    mov     [rsp+70h],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+24h],eax
    mov     edx,[rsp+24h]
    mov     [rsp+2Ch],edx
    jmp     L12
L11:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+48h],0
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+75h]
    mov     byte ptr [rsp+29h],0FFh
    lea     rdi,[rsp+40h]
    movzx   esi,byte ptr [rsp+29h]
    call    fn5
    jmp     L13
L12:
    mov     eax,[rsp+2Ch]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    movzx   esi,word ptr [rsp+0CEh]
    mov     [rsp+4Eh],si
    sub     esi,1
    mov     [rsp+70h],si
    movzx   edi,word ptr [rsp+4Eh]
    and     di,[rsp+70h]
    mov     [rsp+72h],di
    movzx   r8d,word ptr [rsp+72h]
    mov     [rsp+0CEh],r8w
    mov     qword ptr [rsp+50h],1
    mov     r10,[rsp+60h]
    add     r10,rax
    mov     r11,[rsp+0E8h]
    mov     r11,[r11+8]
    and     r10,r11
    mov     [rsp+40h],r10
    mov     [rsp+38h],r10
    mov     rdx,[rsp+0D8h]
    mov     rdx,[rdx+20h]
    mov     [rsp+20h],rdx
    mov     rax,[rsp+20h]
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+38h]
    call    rax
    mov     [rsp+75h],al
    jmp     L5
L13:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    lea     rdi,[rsp+50h]
    lea     rsi,[rsp+10h]
    lea     rdx,[rsp]
    call    fn6
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    fn7
    mov     [rsp+70h],eax
    mov     eax,[rsp+70h]
    mov     [rsp+76h],ax
    cmp     word ptr [rsp+76h],0
    setne   [rsp+75h]
    cmp     word ptr [rsp+76h],0
    je      L17
    jmp     L16
L14:
    mov     rax,[rsp+40h]
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+0F0h],1
    jmp     L7
L15:
    jmp     L3
L16:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k8]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L7
L17:
    mov     rax,[rsp+0E8h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+68h]
    add     rdx,10h
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+60h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rsp+60h],rsi
    jmp     L1
L18:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L19:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L20:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    mov     rax,[rsp+68h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+38h],0
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp]
    mov     rsi,[rsp+10h]
    call    fn0
    jmp     L7
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    cmp     rax,1
    sete    [rsp+46h]
    cmp     rax,1
    je      L8
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     rax,[rsp+78h]
    add     rsp,88h
    ret
L7:
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    lea     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    jmp     L3
L8:
    cmp     qword ptr [rsp+48h],1
    sete    [rsp+47h]
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+8]
    call    fn2
    mov     [rsp+78h],rax
    jmp     L5
L9:
    mov     rax,[rsp+70h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+38h]
    add     rdx,10h
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+30h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rsp+30h],rsi
    jmp     L1
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index_in_group [hint]
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,88h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFE0h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn0
    mov     [rsp+30h],eax
    jmp     L3
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L3:
    mov     eax,[rsp+30h]
    mov     [rsp+3Eh],ax
    movzx   edx,word ptr [rsp+3Eh]
    mov     [rsp+32h],dx
    cmp     dx,0
    je      L4
    mov     [rsp+1Ah],dx
    or      edx,10000h
    bsf     edx,edx
    mov     [rsp+0Ch],edx
    mov     edi,[rsp+0Ch]
    mov     [rsp+1Ch],edi
    jmp     L5
L4:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    cmp     rax,1
    sete    [rsp+33h]
    jmp     L6
L5:
    mov     eax,[rsp+1Ch]
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],1
    mov     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    cmp     rsi,1
    sete    [rsp+33h]
    mov     r8,[rsp+58h]
    mov     r8,[r8]
    add     r8,rax
    mov     r9,[rsp+68h]
    mov     r9,[r9+8]
    and     r8,r9
    mov     [rsp+78h],r8
    mov     qword ptr [rsp+70h],1
    jmp     L1
    ud2
L6:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L1
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::fix_insert_index [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    movzx   edx,byte ptr [rdx]
    and     dl,80h
    mov     [rsp+41h],dl
    cmp     byte ptr [rsp+41h],0
    sete    [rsp+42h]
    test    byte ptr [rsp+42h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    mov     rax,[rsp+88h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L3:
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+80h],rax
    mov     [rsp+28h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+20h]
    call    fn0
    jmp     L5
L4:
    jmp     L1
L5:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    fn1
    mov     [rsp+2Ch],eax
    mov     eax,[rsp+2Ch]
    mov     [rsp+4Eh],ax
    movzx   edx,word ptr [rsp+4Eh]
    mov     [rsp+40h],dx
    cmp     dx,0
    je      L9
    jmp     L8
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L7:
    mov     rax,[rsp+30h]
    cmp     rax,1
    sete    [rsp+43h]
    mov     rsi,[rsp+38h]
    mov     [rsp+88h],rsi
    jmp     L1
L8:
    movzx   eax,word ptr [rsp+40h]
    mov     [rsp+24h],ax
    or      eax,10000h
    bsf     eax,eax
    mov     [rsp+14h],eax
    mov     edx,[rsp+14h]
    mov     [rsp+20h],edx
    jmp     L10
L9:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L6
L10:
    mov     eax,[rsp+20h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    jmp     L6
    ud2
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::new_uninitialized::<std::alloc::Global>
    inc     qword ptr [jit_record]
    jns     L27
L0:
    sub     rsp,138h
    mov     [rsp+80h],rdi
    mov     [rsp+108h],rsi
    mov     [rsp+0F8h],rdx
    mov     [rsp+100h],rcx
    mov     [rsp+0F0h],r8
    mov     [rsp+0EFh],r9b
    mov     rax,[rsp+0F0h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+58h]
    mov     rsi,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+78h]
    call    fn0
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L2:
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+120h],rcx
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+110h],0
    jmp     L13
L3:
    cmp     qword ptr [rsp+58h],0
    je      L4
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+90h],rsi
    mov     rdi,[rsp+108h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    call    fn1
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    jmp     L15
L4:
    movzx   edi,byte ptr [rsp+0EFh]
    call    qword ptr [sym2]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    jmp     L1
    ud2
    nop     [rax+rax]
    nop
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L6:
    mov     rax,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+0D0h]
    sub     rsi,10h
    mov     [rsp+30h],rsi
    add     rax,1
    mov     [rsp+28h],rax
    cmp     rax,0
    jne     L17
    lea     r8,[k3]
    mov     [rsp+8],r8
    mov     rdi,[rsp+8]
    call    qword ptr [sym4]
    ud2
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L8:
    cmp     qword ptr [rsp+28h],0
    setne   [rsp+0Fh]
    movzx   edx,byte ptr [rsp+0Fh]
    cmp     rdx,1
    sete    [rsp+8Fh]
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+38h]
    mov     [rsp+90h],r8
    jmp     L9
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L10:
    mov     rax,[rsp+98h]
    imul    rcx,[rsp+90h],1
    add     rax,rcx
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0F0h]
    sub     rdx,1
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+0F0h]
    sub     rsi,1
    mov     [rsp+0A8h],rsi
    cmp     rsi,8
    jb      L18
    jmp     L19
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L12:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+120h],rcx
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+110h],0
    nop     [rax+rax]
    nop     [rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L14:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF50h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+80h]
    add     rsp,138h
    ret
L15:
    cmp     qword ptr [rsp+48h],0
    jne     L16
    movzx   edi,byte ptr [rsp+0EFh]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    call    qword ptr [sym5]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    jmp     L11
L16:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+60h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+38h],rsi
    cmp     rdx,rsi
    jne     L5
    jmp     L9
L17:
    mov     rax,[rsp+30h]
    xor     edx,edx
    div     qword ptr [rsp+28h]
    mov     [rsp+20h],rax
    bsr     rax,rax
    mov     ecx,7Fh
    cmove   eax,ecx
    xor     eax,3Fh
    mov     [rsp+40h],eax
    mov     qword ptr [rsp+8],3Fh
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     [rsp+30h],rsi
    mov     qword ptr [rsp+8],1
    mov     r8,[rsp+8]
    mov     ecx,[rsp+30h]
    shl     r8,cl
    mov     [rsp+0F0h],r8
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+0F0h]
    call    fn6
    jmp     L7
L18:
    jmp     L20
L19:
    mov     rax,[rsp+0A8h]
    add     rax,1
    shr     rax,3
    imul    rdx,rax,7
    mov     [rsp+0A8h],rdx
L20:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+0A8h]
    mov     qword ptr [rsp+58h],0
    mov     [rsp+110h],rdx
    mov     [rsp+118h],rax
    mov     [rsp+120h],rsi
    mov     r8,[rsp+58h]
    mov     [rsp+128h],r8
    jmp     L13
L21:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L22:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L23:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L24:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L25:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L26:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L27:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::prepare_rehash_in_place [hint]
    inc     qword ptr [jit_record]
    jns     L19
L0:
    sub     rsp,108h
    mov     [rsp+0F8h],rdi
    mov     rax,[rsp+0F8h]
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rsp+60h],0
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+8],10h
    lea     rdi,[rsp+0D8h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    mov     rcx,[rsp+8]
    call    fn0
    jmp     L7
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L2:
    mov     rax,[rsp+0E8h]
    add     rax,1
    mov     [rsp+38h],rax
    cmp     rax,0
    setne   [rsp+0Fh]
    movzx   esi,byte ptr [rsp+0Fh]
    cmp     rsi,1
    sete    [rsp+77h]
    mov     [rsp+50h],rax
    mov     r8,[rsp+0E0h]
    mov     [rsp+58h],r8
    cmp     r8,0
    ja      L8
    jmp     L9
    nop     [rax+rax]
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L4:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0F8h]
    mov     rdx,[rdx]
    imul    rcx,[rsp+58h],1
    add     rdx,rcx
    mov     [rsp+0A0h],rdx
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+28h],rsi
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     rdi,[rsp+28h]
    lea     rsi,[rsp]
    call    fn1
    jmp     L11
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L6:
    add     rsp,108h
    ret
L7:
    jmp     L1
L8:
    mov     rax,[rsp+0D8h]
    mov     [rsp+48h],rax
    add     rax,[rsp+50h]
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+58h]
    sub     rdx,1
    mov     [rsp+0E0h],rdx
    mov     rsi,[rsp+48h]
    mov     qword ptr [rsp+60h],1
    mov     [rsp+58h],rsi
    mov     r8,[rsp+0F8h]
    mov     r8,[r8]
    imul    rcx,rsi,1
    add     r8,rcx
    mov     [rsp+0C0h],r8
    mov     [rsp+50h],r8
    mov     r9,[rsp+0C0h]
    mov     [rsp+28h],r9
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    call    fn2
    jmp     L10
L9:
    mov     rax,[rsp+0F8h]
    mov     rax,[rax+8]
    add     rax,1
    cmp     rax,10h
    setb    [rsp+76h]
    test    byte ptr [rsp+76h],0FFh
    je      L13
    jmp     L12
L10:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp]
    call    fn3
    jmp     L3
L11:
    jmp     L1
L12:
    mov     rax,[rsp+0F8h]
    mov     rax,[rax]
    mov     [rsp+80h],rax
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0F8h]
    mov     rdx,[rdx]
    mov     qword ptr [rsp+8],10h
    imul    rcx,[rsp+8],1
    add     rdx,rcx
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+0F8h]
    mov     rdi,[rdi+8]
    add     rdi,1
    mov     [rsp+58h],rdi
    mov     r8,[rsp+80h]
    mov     [rsp+50h],r8
    imul    r9,rdi,1
    mov     [rsp+8],r9
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF50h
    mov     ecx,0FFFFFF08h
    call    ryo_h_Memmove
    jmp     L14
L13:
    mov     rax,[rsp+0F8h]
    mov     rax,[rax]
    mov     [rsp+78h],rax
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0F8h]
    mov     rdx,[rdx+8]
    add     rdx,1
    mov     rsi,[rsp+0F8h]
    mov     rsi,[rsi]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+78h]
    mov     [rsp+58h],rdi
    mov     rdi,[rdi]
    mov     [rsp],rdi
    mov     r8,[rsp+58h]
    mov     r8,[r8+8]
    mov     [rsp+8],r8
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     r9,[rsp+60h]
    mov     rcx,[rsp+8]
    mov     [r9+8],rcx
    jmp     L15
L14:
    jmp     L5
L15:
    jmp     L5
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L19:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::prepare_resize::<std::alloc::Global>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    jne     L1
    mov     rdi,[rsp+98h]
    mov     rdi,[rdi]
    mov     [rsp+88h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFF8h
    mov     ecx,8
    call    ryo_h_LoadW128
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rsp+38h],rax
    lea     rdi,[rsp+40h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+38h]
    call    fn0
    jmp     L5
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    jmp     L1
L5:
    cmp     qword ptr [rsp+40h],0
    setne   [rsp+0Fh]
    movzx   edx,byte ptr [rsp+0Fh]
    cmp     rdx,1
    sete    [rsp+6Eh]
    mov     rdi,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rdi
    mov     r8,[rsp+50h]
    mov     r9,[rsp+90h]
    mov     r9,[r9]
    mov     qword ptr [rsp+8],0
    mov     r11,[rsp+8]
    sub     r11,r8
    imul    rcx,r11,1
    add     r9,rcx
    mov     [rsp+30h],r9
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+20h]
    call    fn1
    jmp     L3
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::rehash_in_place [hint]
    inc     qword ptr [jit_record]
    jns     L45
L0:
    sub     rsp,208h
    mov     [rsp+1F8h],rdi
    mov     [rsp+1E8h],rsi
    mov     [rsp+1F0h],rdx
    mov     [rsp+1E0h],rcx
    mov     [rsp+1D8h],r8
    mov     rdi,[rsp+1F8h]
    call    fn0
    mov     rax,[rsp+1D8h]
    mov     rdx,[rsp+1E0h]
    mov     [rsp+78h],rdx
    mov     rcx,[rsp+78h]
    mov     [rsp+90h],rcx
    mov     [rsp+88h],rax
    mov     rsi,[rsp+1F8h]
    mov     [rsp+80h],rsi
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     qword ptr [rsp+1C8h],0
    mov     [rsp+1D0h],rsi
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L2:
    mov     rax,[rsp+1C8h]
    mov     rdx,[rsp+1D0h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L20
    jmp     L19
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L4:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L6:
    mov     rax,[rsp+80h]
    mov     rax,[rax]
    mov     rdx,[rsp+68h]
    add     rdx,1
    imul    rdx,[rsp+1E0h]
    mov     qword ptr [rsp+8],0
    mov     rdi,[rsp+8]
    sub     rdi,rdx
    imul    rcx,rdi,1
    add     rax,rcx
    mov     [rsp+60h],rax
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L8:
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+1F0h]
    mov     rsi,[rsi+28h]
    mov     [rsp+8],rsi
    mov     rax,[rsp+8]
    mov     rdi,[rsp+1E8h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    call    rax
    mov     [rsp+58h],rax
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+58h]
    call    fn1
    mov     [rsp+50h],rax
    mov     rax,[rsp+80h]
    mov     [rsp+0E8h],rax
    mov     rdx,[rsp+58h]
    mov     rax,[rax+8]
    and     rdx,rax
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+68h]
    sub     rsi,rdx
    mov     rdi,[rsp+0E8h]
    mov     rdi,[rdi+8]
    and     rsi,rdi
    shr     rsi,4
    mov     r8,[rsp+50h]
    sub     r8,rdx
    mov     r9,[rsp+0E8h]
    mov     r9,[r9+8]
    and     r8,r9
    shr     r8,4
    cmp     rsi,r8
    sete    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L10:
    mov     rax,[rsp+80h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+68h]
    sub     rdx,10h
    mov     rax,[rax+8]
    and     rdx,rax
    add     rdx,10h
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+0C8h]
    mov     rsi,[rsi]
    imul    rcx,[rsp+68h],1
    add     rsi,rcx
    mov     byte ptr [rsp],0FFh
    movzx   ecx,byte ptr [rsp]
    mov     [rsi],cl
    mov     r8,[rsp+0C8h]
    mov     r8,[r8]
    imul    rcx,[rsp+38h],1
    add     r8,rcx
    mov     byte ptr [rsp],0FFh
    movzx   ecx,byte ptr [rsp]
    mov     [r8],cl
    mov     r10,[rsp+60h]
    mov     [rsp+38h],r10
    imul    r11,[rsp+1E0h],1
    mov     [rsp+8],r11
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE48h
    mov     edx,0FFFFFE38h
    mov     ecx,0FFFFFE08h
    call    ryo_h_Memcpy
    jmp     L13
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L12:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+1E0h]
    mov     [rsp+38h],rdx
    mov     rcx,[rsp+38h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    imul    rsi,[rsp+20h],1
    mov     [rsp+28h],rsi
    jmp     L27
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L14:
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L40
L16:
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE98h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L41
L18:
    lea     rax,[rsp+80h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L15
L19:
    mov     rax,[rsp+1C8h]
    mov     [rsp+60h],rax
    add     rax,1
    mov     [rsp+1C8h],rax
    mov     rdx,[rsp+60h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+80h]
    mov     rdi,[rdi]
    imul    rcx,rdx,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    cmp     dil,80h
    sete    [rsp+66h]
    movzx   r9d,byte ptr [rsp+66h]
    xor     r9b,1
    mov     [rsp+67h],r9b
    test    byte ptr [rsp+67h],0FFh
    je      L5
    jmp     L3
L20:
    mov     rax,[rsp+80h]
    mov     rax,[rax+8]
    mov     [rsp+130h],rax
    cmp     rax,8
    jb      L28
    jmp     L29
L21:
    mov     rax,[rsp+80h]
    mov     [rsp+0E0h],rax
    mov     rdx,[rsp+58h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+4Eh],dl
    movzx   esi,byte ptr [rsp+4Eh]
    mov     [rsp+4Fh],sil
    mov     rdi,[rsp+68h]
    sub     rdi,10h
    mov     rax,[rax+8]
    and     rdi,rax
    add     rdi,10h
    mov     [rsp+40h],rdi
    mov     r8,[rsp+0E0h]
    mov     r8,[r8]
    imul    rcx,[rsp+68h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r8],cl
    mov     r9,[rsp+0E0h]
    mov     r9,[r9]
    imul    rcx,[rsp+40h],1
    add     r9,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r9],cl
    jmp     L13
L22:
    mov     rax,[rsp+80h]
    mov     rax,[rax]
    mov     rdx,[rsp+50h]
    add     rdx,1
    imul    rdx,[rsp+1E0h]
    mov     qword ptr [rsp+8],0
    mov     rdi,[rsp+8]
    sub     rdi,rdx
    imul    rcx,rdi,1
    add     rax,rcx
    mov     [rsp+48h],rax
    mov     r8,[rsp+80h]
    mov     [rsp+0D0h],r8
    mov     r8,[r8]
    imul    rcx,[rsp+50h],1
    add     r8,rcx
    movzx   r8d,byte ptr [r8]
    mov     [rsp+47h],r8b
    mov     r9,[rsp+58h]
    shr     r9,39h
    and     r9,7Fh
    mov     [rsp+45h],r9b
    movzx   r10d,byte ptr [rsp+45h]
    mov     [rsp+46h],r10b
    mov     r11,[rsp+50h]
    sub     r11,10h
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi+8]
    and     r11,rsi
    add     r11,10h
    mov     [rsp+38h],r11
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx]
    imul    rcx,[rsp+50h],1
    add     rdx,rcx
    movzx   ecx,byte ptr [rsp+46h]
    mov     [rdx],cl
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    imul    rcx,[rsp+38h],1
    add     rax,rcx
    movzx   ecx,byte ptr [rsp+46h]
    mov     [rax],cl
    movzx   edi,byte ptr [rsp+47h]
    cmp     dil,0FFh
    sete    [rsp+46h]
    test    byte ptr [rsp+46h],0FFh
    je      L11
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L42
L24:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+18h]
    call    fn3
    jmp     L25
    nop     [rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L43
L26:
    jmp     L7
L27:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    cmp     rax,0
    je      L25
    jmp     L23
L28:
    jmp     L30
L29:
    mov     rax,[rsp+130h]
    add     rax,1
    shr     rax,3
    imul    rdx,rax,7
    mov     [rsp+130h],rdx
L30:
    mov     rax,[rsp+80h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+130h]
    sub     rsi,rax
    mov     [rsp],rsi
    mov     rcx,[rsp]
    mov     [rdx+10h],rcx
    mov     rdi,[rsp+88h]
    mov     [rsp+70h],rdi
    mov     r8,[rsp+90h]
    mov     [rsp+68h],r8
    mov     r9,[rsp+80h]
    mov     [rsp+78h],r9
    add     rsp,208h
    ret
    nop     [rax]
L31:
    inc     qword ptr [jit_record.ctr_l]
    jns     L44
L32:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+200h]
    mov     rsi,rax
    mov     edx,0FFFFFE98h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+200h]
    mov     rsi,rax
    mov     edx,0FFFFFE98h
    call    ryo_h_Lpad
    jmp     L31
L33:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L34:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L35:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L36:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L37:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L38:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L39:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L14
L40:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L16
L41:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L18
L42:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L24
L43:
    lea     r11,[jit_record]
    mov     eax,0Ah
    call    qword ptr [r11+10h]
    jmp     L26
L44:
    lea     r11,[jit_record]
    mov     eax,0Bh
    call    qword ptr [r11+10h]
    jmp     L32
L45:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,118h
    mov     [rsp+108h],rdi
    mov     [rsp+100h],rsi
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rsp+0F0h],0
    mov     [rsp+0F8h],rax
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L2:
    mov     rax,[rsp+0F0h]
    mov     rdx,[rsp+0F8h]
    cmp     rax,rdx
    setb    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L9
    jmp     L8
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L4:
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+60h]
    sub     rdx,10h
    mov     rax,[rax+8]
    and     rdx,rax
    add     rdx,10h
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+0B0h]
    mov     rsi,[rsi]
    imul    rcx,[rsp+60h],1
    add     rsi,rcx
    mov     byte ptr [rsp+10h],0FFh
    movzx   ecx,byte ptr [rsp+10h]
    mov     [rsi],cl
    mov     r8,[rsp+0B0h]
    mov     r8,[r8]
    imul    rcx,[rsp+50h],1
    add     r8,rcx
    mov     byte ptr [rsp+10h],0FFh
    movzx   ecx,byte ptr [rsp+10h]
    mov     [r8],cl
    mov     r10,[rsp+108h]
    mov     r10,[r10]
    mov     [rsp+10h],r10
    cmp     r10,0
    je      L5
    mov     rax,[rsp+108h]
    mov     rax,[rax]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+100h]
    mov     rdx,[rdx]
    mov     rdi,[rsp+108h]
    mov     rdi,[rdi+8]
    mov     rdx,[rdx]
    mov     rsi,[rsp+60h]
    add     rsi,1
    imul    rsi,rdi
    mov     qword ptr [rsp+10h],0
    mov     r8,[rsp+10h]
    sub     r8,rsi
    imul    rcx,r8,1
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     rax,[rsp+50h]
    mov     rdi,[rsp+48h]
    call    rax
L5:
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rdx,[rsp+100h]
    mov     rdx,[rdx]
    mov     rdx,[rdx+18h]
    sub     rdx,1
    mov     [rsp],rdx
    mov     rcx,[rsp]
    mov     [rax+18h],rcx
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L7:
    jmp     L1
L8:
    mov     rax,[rsp+0F0h]
    mov     [rsp+58h],rax
    add     rax,1
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+58h]
    mov     qword ptr [rsp+68h],1
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+100h]
    mov     rdi,[rdi]
    mov     rdi,[rdi]
    imul    rcx,rdx,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    cmp     dil,80h
    sete    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L6
    jmp     L3
L9:
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    mov     [rsp+0D0h],rax
    cmp     rax,8
    jae     L10
    jmp     L11
L10:
    mov     rax,[rsp+0D0h]
    add     rax,1
    shr     rax,3
    imul    rdx,rax,7
    mov     [rsp+0D0h],rdx
L11:
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+100h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+0D0h]
    sub     rsi,rax
    mov     [rsp+10h],rsi
    mov     rcx,[rsp+10h]
    mov     [rdx+10h],rcx
    add     rsp,118h
    ret
L12:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L13:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L14:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::reserve_rehash_inner::<std::alloc::Global> [always]
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,0A8h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+68h],rcx
    mov     [rsp+70h],r8
    mov     [rsp+67h],r9b
    mov     rax,[rsp+0B0h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+88h]
    mov     rdi,[rdi+18h]
    mov     [rsp+38h],rdi
    add     rdi,[rsp+78h]
    setb    cl
    mov     [rsp+18h],cl
    movzx   r8d,byte ptr [rsp+18h]
    mov     [rsp+27h],r8b
    test    byte ptr [rsp+27h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L2:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rax
    jmp     L7
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L4:
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+28h]
    mov     r8,[rsp+48h]
    call    fn0
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L7
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L6:
    mov     rax,[rsp+40h]
    add     rax,1
    mov     [rsp+20h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+20h]
    call    fn2
    mov     [rsp+28h],rax
    mov     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+70h]
    movzx   r9d,byte ptr [rsp+67h]
    call    fn3
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
L7:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
L8:
    movzx   edi,byte ptr [rsp+67h]
    call    qword ptr [sym4]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L1
L9:
    mov     rax,[rsp+38h]
    add     rax,[rsp+78h]
    mov     qword ptr [rsp+28h],1
    mov     [rsp+38h],rax
    mov     rsi,[rsp+88h]
    mov     rsi,[rsi+8]
    mov     [rsp+40h],rsi
    cmp     rsi,8
    jae     L10
    jmp     L11
L10:
    mov     rax,[rsp+40h]
    add     rax,1
    shr     rax,3
    imul    rdx,rax,7
    mov     [rsp+40h],rdx
L11:
    mov     rax,[rsp+40h]
    shr     rax,1
    mov     [rsp+28h],rax
    cmp     rax,[rsp+38h]
    jae     L3
    jmp     L5
L12:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L13:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L14:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global> [always]
    inc     qword ptr [jit_record]
    jns     L26
L0:
    sub     rsp,288h
    mov     [rsp+268h],rdi
    mov     [rsp+260h],rsi
    mov     [rsp+258h],rdx
    mov     [rsp+248h],rcx
    mov     [rsp+250h],r8
    mov     [rsp+247h],r9b
    mov     rax,[rsp+290h]
    mov     [rsp+230h],rax
    mov     rdx,[rsp+298h]
    mov     [rsp+238h],rdx
    lea     rdi,[rsp+0A0h]
    mov     rsi,[rsp+260h]
    mov     rdx,[rsp+230h]
    mov     rcx,[rsp+238h]
    mov     r8,[rsp+258h]
    movzx   r9d,byte ptr [rsp+247h]
    call    fn0
    jmp     L12
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L2:
    lea     rax,[rsp+130h]
    mov     [rsp+118h],rax
    mov     rax,[rax+10h]
    mov     [rsp+110h],rax
    cmp     rax,0
    je      L14
    jmp     L15
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L4:
    mov     rax,[rsp+128h]
    mov     [rsp+110h],rax
    mov     rdx,[rsp+268h]
    mov     [rsp+0F8h],rdx
    mov     [rsp+100h],rax
    mov     rsi,[rsp+250h]
    mov     rsi,[rsi+28h]
    mov     [rsp+50h],rsi
    mov     rax,[rsp+50h]
    mov     rdi,[rsp+248h]
    mov     rsi,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    call    rax
    mov     [rsp+108h],rax
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L6:
    mov     rax,[rsp+268h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+178h]
    sub     rdx,rax
    mov     [rsp+178h],rdx
    mov     rsi,[rsp+268h]
    mov     rsi,[rsi+18h]
    mov     [rsp+180h],rsi
    mov     rdi,[rsp+268h]
    mov     [rsp+148h],rdi
    lea     r8,[rsp+168h]
    mov     [rsp+140h],r8
    mov     rdi,[rdi]
    mov     [rsp+30h],rdi
    mov     r9,[rsp+148h]
    mov     r9,[r9+8]
    mov     [rsp+38h],r9
    mov     r10,[rsp+148h]
    mov     r10,[r10+10h]
    mov     [rsp+40h],r10
    mov     r11,[rsp+148h]
    mov     r11,[r11+18h]
    mov     [rsp+48h],r11
    mov     r8,[r8]
    mov     [rsp+10h],r8
    mov     rax,[rsp+140h]
    mov     rax,[rax+8]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+140h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+140h]
    mov     rsi,[rsi+18h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+148h]
    mov     [rsp+8],rdi
    mov     rcx,[rsp+10h]
    mov     [rdi],rcx
    mov     r9,[rsp+8]
    mov     rcx,[rsp+18h]
    mov     [r9+8],rcx
    mov     r10,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     [r10+10h],rcx
    mov     r11,[rsp+8]
    mov     rcx,[rsp+28h]
    mov     [r11+18h],rcx
    mov     r8,[rsp+140h]
    mov     [rsp],r8
    mov     rcx,[rsp+30h]
    mov     [r8],rcx
    mov     rax,[rsp]
    mov     rcx,[rsp+38h]
    mov     [rax+8],rcx
    mov     rdx,[rsp]
    mov     rcx,[rsp+40h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp]
    mov     rcx,[rsp+48h]
    mov     [rsi+18h],rcx
    jmp     L17
L7:
    lea     rax,[rsp+168h]
    mov     [rsp+100h],rax
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+108h]
    call    fn1
    mov     [rsp+190h],rax
    jmp     L16
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L9:
    mov     rax,[rsp+270h]
    mov     rdx,[rsp+278h]
    add     rsp,288h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L11:
    lea     rax,[rsp+150h]
    mov     [rsp+50h],rax
    mov     rdi,[rsp+50h]
    call    fn2
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFF08h
    call    ryo_h_Resume
    ud2
L12:
    cmp     qword ptr [rsp+0A0h],0
    jne     L13
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+0B0h]
    mov     [rsp+70h],rcx
    mov     rcx,[rsp+70h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+60h]
    mov     [rsp+0D0h],rcx
    mov     qword ptr [rsp+0C0h],0
    mov     rcx,[rsp+0D0h]
    mov     [rsp+0B8h],rcx
    mov     [rsp+0B0h],rdx
    mov     qword ptr [rsp+0A8h],1
    cmp     qword ptr [rsp+0A8h],1
    sete    [rsp+0A7h]
    mov     rcx,[rsp+0B8h]
    mov     [rsp+78h],rcx
    mov     rcx,[rsp+78h]
    mov     [rsp+0F0h],rcx
    mov     [rsp+0E8h],rdx
    mov     qword ptr [rsp+0E0h],0
    mov     rcx,[rsp+0F0h]
    mov     [rsp+0D8h],rcx
    mov     rcx,[rsp+0D8h]
    mov     [rsp+0C8h],rcx
    mov     rcx,[rsp+0C8h]
    mov     [rsp+128h],rcx
    mov     [rsp+120h],rdx
    mov     qword ptr [rsp+118h],0
    mov     rcx,[rsp+128h]
    mov     [rsp+110h],rcx
    mov     [rsp+108h],rdx
    mov     qword ptr [rsp+100h],1
    cmp     qword ptr [rsp+100h],1
    sete    [rsp+0EFh]
    mov     rcx,[rsp+110h]
    mov     [rsp+0F8h],rcx
    mov     rcx,[rsp+0F8h]
    mov     [rsp+278h],rcx
    mov     [rsp+270h],rdx
    jmp     L8
L13:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     rsi,[rsp+0B0h]
    mov     rdi,[rsp+0B8h]
    mov     r8,[rsp+260h]
    mov     r9,[rsp+230h]
    mov     rcx,[rsp+238h]
    mov     [rsp+78h],rcx
    mov     [rsp+0A8h],r8
    mov     [rsp+0B0h],r9
    mov     r10,[rsp+78h]
    mov     [rsp+0B8h],r10
    mov     [rsp+0C0h],rax
    mov     [rsp+0C8h],rdx
    mov     [rsp+0D0h],rsi
    mov     [rsp+0D8h],rdi
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rax,[rsp+268h]
    mov     rax,[rax]
    mov     [rsp+128h],rax
    mov     [rsp+130h],rax
    mov     rdx,[rsp+128h]
    mov     [rsp+148h],rdx
    mov     rsi,[rsp+128h]
    mov     [rsp+138h],rsi
    mov     rdi,[rsp+128h]
    mov     [rsp+120h],rdi
    lea     rdi,[rsp+110h]
    mov     rsi,[rsp+120h]
    call    fn3
    mov     rax,[rsp+110h]
    mov     rcx,[rsp+118h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+40h]
    call    fn4
    mov     [rsp+13Ch],eax
    mov     eax,[rsp+13Ch]
    mov     [rsp+140h],ax
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+142h]
    mov     rdx,[rsp+268h]
    mov     rdx,[rdx+18h]
    mov     [rsp+228h],ax
    mov     qword ptr [rsp+218h],0
    mov     rdi,[rsp+128h]
    mov     [rsp+130h],rdi
    mov     r8,[rsp+218h]
    mov     [rsp+138h],r8
    mov     [rsp+140h],rdx
    mov     r9,[rsp+228h]
    mov     [rsp+148h],r9
    jmp     L1
L14:
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L15:
    mov     rdi,[rsp+118h]
    call    fn6
    mov     [rsp+120h],rax
    mov     [rsp+128h],rdx
    mov     rax,[rsp+118h]
    mov     rax,[rax+10h]
    sub     rax,1
    mov     [rsp+40h],rax
    mov     rdx,[rsp+118h]
    mov     rcx,[rsp+40h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+120h]
    mov     [rsp+208h],rsi
    cmp     rsi,0
    je      L5
    jmp     L3
L16:
    mov     rax,[rsp+168h]
    imul    rcx,[rsp+190h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+0D7h],al
    mov     rdx,[rsp+108h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+106h],dl
    movzx   esi,byte ptr [rsp+106h]
    mov     [rsp+107h],sil
    mov     rdi,[rsp+190h]
    sub     rdi,10h
    mov     r8,[rsp+170h]
    and     rdi,r8
    add     rdi,10h
    mov     [rsp+0F8h],rdi
    mov     r9,[rsp+168h]
    imul    rcx,[rsp+190h],1
    add     r9,rcx
    movzx   ecx,byte ptr [rsp+107h]
    mov     [r9],cl
    mov     r10,[rsp+168h]
    imul    rcx,[rsp+0F8h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+107h]
    mov     [r10],cl
    mov     r11,[rsp+230h]
    mov     [rsp+1F0h],r11
    mov     rax,[rsp+268h]
    mov     rax,[rax]
    mov     rdx,[rsp+110h]
    add     rdx,1
    imul    rdx,r11
    mov     qword ptr [rsp+50h],0
    mov     r8,[rsp+50h]
    sub     r8,rdx
    imul    rcx,r8,1
    add     rax,rcx
    mov     [rsp+100h],rax
    mov     rdi,[rsp+168h]
    mov     r9,[rsp+190h]
    add     r9,1
    imul    r9,r11
    mov     qword ptr [rsp+50h],0
    mov     rsi,[rsp+50h]
    sub     rsi,r9
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+0F8h],rdi
    imul    rdx,r11,1
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFDD0h
    call    ryo_h_Memcpy
    jmp     L1
L17:
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+150h]
    mov     [rsp+50h],rax
    mov     rdi,[rsp+50h]
    call    fn8
    jmp     L8
    nop     [rax+rax]
    nop
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L19:
    call    qword ptr [sym9]
    ud2
    lea     rdi,[rsp+280h]
    mov     rsi,rax
    mov     edx,0FFFFFF08h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+280h]
    mov     rsi,rax
    mov     edx,0FFFFFF08h
    call    ryo_h_Lpad
    jmp     L18
L20:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L21:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L22:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L23:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L24:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L25:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L26:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::TableLayout::calculate_layout_for [hint]
    inc     qword ptr [jit_record]
    jns     L17
L0:
    sub     rsp,0F8h
    mov     [rsp+90h],rdi
    mov     [rsp+0C8h],rsi
    mov     [rsp+0D0h],rdx
    mov     [rsp+0C0h],rcx
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0D0h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+0C0h]
    mul     rsi
    mov     [rsp+18h],rax
    setb    cl
    mov     [rsp+20h],cl
    movzx   edi,byte ptr [rsp+20h]
    mov     [rsp+2Fh],dil
    mov     [rsp+8],rax
    test    byte ptr [rsp+2Fh],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    mov     qword ptr [rsp+0D8h],0
    jmp     L5
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+98h]
    mov     [rsp+58h],rdx
    mov     rcx,[rsp+58h]
    mov     [rsp+68h],rcx
    mov     rsi,[rsp+78h]
    mov     [rsp+0D8h],rax
    mov     rdi,[rsp+68h]
    mov     [rsp+0E0h],rdi
    mov     [rsp+0E8h],rsi
    jmp     L7
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    jmp     L7
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L8:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFA0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+90h]
    add     rsp,0F8h
    ret
L9:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+40h],0
    cmp     qword ptr [rsp+40h],0
    sete    [rsp+3Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L7
L10:
    mov     rax,[rsp+8]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],1
    mov     qword ptr [rsp+48h],0
    mov     [rsp+0B0h],rax
    mov     rdi,[rsp+80h]
    sub     rdi,1
    mov     [rsp+0A8h],rdi
    add     rax,rdi
    setb    cl
    mov     [rsp+38h],cl
    movzx   r8d,byte ptr [rsp+38h]
    mov     [rsp+47h],r8b
    test    byte ptr [rsp+47h],0FFh
    je      L11
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+60h],0
    cmp     qword ptr [rsp+60h],0
    sete    [rsp+5Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L7
L11:
    mov     rax,[rsp+0B0h]
    add     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+58h],1
    mov     qword ptr [rsp+68h],0
    mov     [rsp+0A0h],rax
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFB8h
    call    ryo_h_NotW64
    mov     rax,[rsp+0A0h]
    and     rax,[rsp+60h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0C0h]
    add     rdx,10h
    mov     [rsp+50h],rdx
    add     rax,rdx
    setb    cl
    mov     [rsp+40h],cl
    movzx   esi,byte ptr [rsp+40h]
    mov     [rsp+4Fh],sil
    test    byte ptr [rsp+4Fh],0FFh
    je      L12
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+60h],0
    cmp     qword ptr [rsp+60h],0
    sete    [rsp+5Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L5
L12:
    mov     rax,[rsp+78h]
    add     rax,[rsp+50h]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+58h],1
    mov     qword ptr [rsp+68h],0
    mov     [rsp+98h],rax
    mov     rdi,7FFFFFFFFFFFFFFFh
    sub     rdi,[rsp+0A8h]
    mov     [rsp+68h],rdi
    cmp     rdi,rax
    jb      L1
    jmp     L3
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L17:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::capacity_to_buckets [hint]
    inc     qword ptr [jit_record]
    jns     L42
L0:
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],rdx
    cmp     qword ptr [rsp+0B8h],0Fh
    jae     L13
    mov     rdx,[rsp+0A8h]
    mov     [rsp+80h],rdx
    mov     qword ptr [rsp+10h],0
    mov     rdi,[rsp+10h]
    cmp     rdi,rdx
    setbe   [rsp+7Dh]
    test    byte ptr [rsp+7Dh],0FFh
    je      L5
    jmp     L7
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L2:
    mov     qword ptr [rsp+88h],3
    jmp     L9
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L4:
    mov     qword ptr [rsp+88h],0Eh
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L6:
    mov     qword ptr [rsp+10h],2
    mov     rdx,[rsp+10h]
    cmp     rdx,[rsp+80h]
    setbe   [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    je      L1
    cmp     qword ptr [rsp+80h],3
    jbe     L8
    jmp     L1
L7:
    cmp     qword ptr [rsp+80h],1
    jbe     L3
    jmp     L5
L8:
    mov     qword ptr [rsp+88h],7
L9:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0B8h]
    call    fn0
    mov     [rsp+58h],rax
    cmp     qword ptr [rsp+58h],4
    jae     L10
    mov     qword ptr [rsp+70h],4
    jmp     L12
L10:
    cmp     qword ptr [rsp+58h],8
    jae     L11
    mov     qword ptr [rsp+70h],8
    jmp     L12
L11:
    mov     qword ptr [rsp+70h],10h
L12:
    mov     rax,[rsp+0B0h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    cmp     qword ptr [rsp+80h],0
    je      L17
    jmp     L16
L13:
    mov     rax,[rsp+0B8h]
    mov     qword ptr [rsp+10h],8
    mul     qword ptr [rsp+10h]
    mov     [rsp+20h],rax
    setb    cl
    mov     [rsp+28h],cl
    movzx   esi,byte ptr [rsp+28h]
    mov     [rsp+37h],sil
    mov     [rsp+18h],rax
    test    byte ptr [rsp+37h],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L15:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    add     rsp,0D8h
    ret
L16:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+50h]
    mul     rdx
    mov     [rsp+38h],rax
    setb    cl
    mov     [rsp+40h],cl
    movzx   esi,byte ptr [rsp+40h]
    mov     [rsp+66h],sil
    mov     [rsp+28h],rax
    test    byte ptr [rsp+66h],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L18:
    mov     rax,[rsp+70h]
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+0C0h],1
    jmp     L14
L19:
    mov     qword ptr [rsp+28h],0FFFFFFFFFFFFFFFFh
    jmp     L17
L20:
    jmp     L17
L21:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+48h],0
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+47h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L14
L22:
    mov     rax,[rsp+18h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    mov     qword ptr [rsp+50h],0
    mov     qword ptr [rsp+10h],7
    xor     edx,edx
    div     qword ptr [rsp+10h]
    mov     [rsp+60h],rax
    cmp     rax,1
    jbe     L27
    jmp     L28
    nop     [rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L24:
    mov     rax,[rsp+40h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+18h],rsi
    cmp     rdx,0
    je      L30
    jmp     L29
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L40
L26:
    mov     qword ptr [rsp+10h],1
    mov     rdx,[rsp+50h]
    add     rdx,[rsp+10h]
    mov     [rsp+40h],rdx
    setb    cl
    mov     [rsp+48h],cl
    test    byte ptr [rsp+48h],0FFh
    je      L23
    lea     rdi,[k3]
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+10h]
    call    qword ptr [sym4]
    ud2
L27:
    mov     qword ptr [rsp+50h],0
    jmp     L25
L28:
    mov     rax,[rsp+60h]
    sub     rax,1
    mov     [rsp+38h],rax
    bsr     rax,rax
    mov     ecx,7Fh
    cmove   eax,ecx
    xor     eax,3Fh
    mov     [rsp+34h],eax
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    mov     rsi,[rsp+10h]
    mov     ecx,[rsp+8]
    shr     rsi,cl
    mov     [rsp+50h],rsi
    jmp     L25
L29:
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+58h]
    mul     rdx
    mov     [rsp+38h],rax
    setb    cl
    mov     [rsp+40h],cl
    movzx   esi,byte ptr [rsp+40h]
    mov     [rsp+4Fh],sil
    mov     [rsp+28h],rax
    test    byte ptr [rsp+4Fh],0FFh
    je      L33
    jmp     L32
    nop     [rax]
L30:
    inc     qword ptr [jit_record.ctr_l]
    jns     L41
L31:
    mov     rax,[rsp+58h]
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+0C0h],1
    jmp     L14
L32:
    mov     qword ptr [rsp+28h],0FFFFFFFFFFFFFFFFh
    jmp     L30
L33:
    jmp     L30
L34:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L35:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L36:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L37:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L15
L38:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L18
L39:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L24
L40:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L26
L41:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L31
L42:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry
    inc     qword ptr [jit_record]
    jns     L16
L0:
    sub     rsp,0C8h
    mov     [rsp+60h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF48h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+90h]
    lea     rax,[rax+20h]
    mov     [rsp+50h],rax
    lea     rdx,[rsp+78h]
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    call    fn0
    mov     [rsp+58h],rax
    jmp     L8
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L2:
    cmp     qword ptr [rsp+50h],0
    je      L3
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     rcx,[rsp+40h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rdx
    mov     qword ptr [rsp+98h],0FFFFFFFFFFFFFFFFh
    lea     r8,[rsp+78h]
    mov     [rsp],r8
    mov     rdi,[rsp]
    call    fn1
    jmp     L4
L3:
    mov     rax,[rsp+90h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+90h]
    lea     rdx,[rdx+20h]
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+48h]
    call    fn2
    jmp     L9
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L5:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+60h]
    add     rsp,0C8h
    ret
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L7:
    lea     rax,[rsp+78h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn3
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA8h
    call    ryo_h_Resume
    ud2
L8:
    mov     rax,[rsp+90h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+78h]
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+40h]
    call    fn4
    mov     [rsp+50h],rax
    jmp     L1
L9:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+58h]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],r8
    jmp     L4
    ud2
    nop     [rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L11:
    call    qword ptr [sym5]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L6
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L10
L12:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L13:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L14:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L15:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L16:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+20h]
    mov     rdx,[rdx]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,88h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+60h]
    lea     rax,[rax+20h]
    mov     [rsp+30h],rax
    lea     rdx,[rsp+58h]
    mov     [rsp+28h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    call    fn0
    mov     [rsp+38h],rax
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    cmp     qword ptr [rsp+30h],0
    je      L3
    mov     rdx,[rsp+30h]
    mov     rsi,[rsp+60h]
    mov     [rsp+20h],rsi
    mov     rcx,[rsp+20h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdx
    mov     qword ptr [rsp+68h],0
    jmp     L4
L3:
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    lea     rdx,[rdx+20h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+8],1
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+28h]
    call    fn1
    jmp     L9
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L5:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+40h]
    add     rsp,88h
    ret
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L7:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L8:
    mov     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    call    fn2
    mov     [rsp+30h],rax
    jmp     L1
L9:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+38h]
    mov     [rsp+68h],rdx
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rax
    jmp     L4
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L6
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>>::rustc_entry::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+20h]
    mov     rdx,[rdx]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+2Fh],al
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main
    inc     qword ptr [jit_record]
    jns     L33
L0:
    sub     rsp,548h
    mov     qword ptr [rsp+28h],50910h
    mov     rdi,[rsp+28h]
    call    fn0
    mov     [rsp+538h],rax
    lea     rdi,[rsp+518h]
    call    fn1
    mov     qword ptr [rsp+510h],1
    mov     qword ptr [rsp+4F0h],0
    mov     rsi,[rsp+538h]
    mov     [rsp+4F8h],rsi
    mov     rdi,[rsp+4F0h]
    mov     rsi,[rsp+4F8h]
    call    fn2
    mov     [rsp+500h],rax
    mov     [rsp+508h],rdx
    mov     rax,[rsp+500h]
    mov     rcx,[rsp+508h]
    mov     [rsp+4E8h],rcx
    mov     [rsp+4E0h],rax
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    lea     rax,[rsp+4E0h]
    mov     [rsp+4C8h],rax
    mov     rdi,[rsp+4C8h]
    call    fn3
    mov     [rsp+4D0h],rax
    mov     [rsp+4D8h],rdx
    mov     rax,[rsp+4D0h]
    mov     [rsp+4C0h],rax
    cmp     rax,0
    je      L4
    jmp     L3
    ud2
L3:
    mov     rax,[rsp+4D8h]
    mov     [rsp+4B8h],rax
    mov     rdx,[rsp+510h]
    mov     [rsp+4A0h],rdx
    mov     rsi,5851F42D4C957F2Dh
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+4A0h]
    mov     rsi,[rsp+28h]
    call    fn4
    mov     [rsp+4A8h],rax
    jmp     L5
L4:
    mov     qword ptr [rsp+448h],0
    mov     qword ptr [rsp+440h],0
    mov     dword ptr [rsp+2Ch],14h
    mov     edi,[rsp+2Ch]
    mov     [rsp+3E4h],edi
    cmp     edi,40h
    jb      L8
    lea     r9,[k5]
    mov     [rsp+28h],r9
    mov     rdi,[rsp+28h]
    call    qword ptr [sym6]
    ud2
L5:
    mov     rax,14057B7EF767814Fh
    mov     [rsp+28h],rax
    mov     rdi,[rsp+4A8h]
    mov     rsi,[rsp+28h]
    call    fn7
    mov     [rsp+4B0h],rax
    mov     rax,[rsp+4B0h]
    mov     [rsp+510h],rax
    lea     rdx,[rsp+518h]
    mov     [rsp+478h],rdx
    mov     [rsp+468h],rax
    mov     dword ptr [rsp+2Ch],2Ch
    mov     edi,[rsp+2Ch]
    mov     [rsp+464h],edi
    cmp     edi,40h
    jb      L6
    lea     r9,[k8]
    mov     [rsp+28h],r9
    mov     rdi,[rsp+28h]
    call    qword ptr [sym9]
    ud2
L6:
    mov     rax,[rsp+468h]
    shr     rax,2Ch
    mov     [rsp+470h],rax
    lea     rdi,[rsp+480h]
    mov     rsi,[rsp+478h]
    mov     rdx,[rsp+470h]
    call    fn10
    mov     rax,[rsp+480h]
    mov     rcx,[rsp+488h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdx,[rsp+490h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],0
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn11
    mov     [rsp+498h],rax
    mov     rax,[rsp+498h]
    mov     rax,[rax]
    add     rax,[rsp+4B8h]
    mov     [rsp+450h],rax
    setb    cl
    mov     [rsp+458h],cl
    test    byte ptr [rsp+458h],0FFh
    je      L7
    lea     rsi,[k12]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+28h]
    call    qword ptr [sym13]
    ud2
L7:
    mov     rax,[rsp+498h]
    mov     rcx,[rsp+450h]
    mov     [rax],rcx
    jmp     L1
L8:
    mov     qword ptr [rsp+28h],1
    mov     rdx,[rsp+28h]
    shl     rdx,14h
    mov     qword ptr [rsp+3F0h],0
    mov     [rsp+3F8h],rdx
    mov     qword ptr [rsp+28h],2
    lea     rdi,[rsp+400h]
    mov     rsi,[rsp+3F0h]
    mov     rdx,[rsp+3F8h]
    mov     rcx,[rsp+28h]
    call    fn14
    mov     rax,[rsp+400h]
    mov     rcx,[rsp+408h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+410h]
    mov     rcx,[rsp+418h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+420h]
    lea     rsi,[rsp+10h]
    call    fn15
    mov     rax,[rsp+420h]
    mov     [rsp+3C0h],rax
    mov     rdx,[rsp+428h]
    mov     [rsp+3C8h],rdx
    mov     rsi,[rsp+430h]
    mov     [rsp+3D0h],rsi
    mov     rdi,[rsp+438h]
    mov     [rsp+3D8h],rdi
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L10:
    lea     rax,[rsp+3C0h]
    mov     [rsp+3A8h],rax
    mov     rdi,[rsp+3A8h]
    call    fn16
    mov     [rsp+3B0h],rax
    mov     [rsp+3B8h],rdx
    mov     rax,[rsp+3B0h]
    mov     [rsp+3A0h],rax
    cmp     rax,0
    je      L11
    mov     rsi,[rsp+3B8h]
    mov     [rsp+398h],rsi
    lea     rdi,[rsp+518h]
    mov     [rsp+388h],rdi
    lea     r8,[rsp+398h]
    mov     [rsp+380h],r8
    mov     rdi,[rsp+388h]
    mov     rsi,[rsp+380h]
    call    fn17
    mov     [rsp+390h],rax
    jmp     L12
L11:
    lea     rax,[rsp+518h]
    mov     [rsp+338h],rax
    mov     rdi,[rsp+338h]
    call    fn18
    mov     [rsp+340h],rax
    jmp     L14
L12:
    cmp     qword ptr [rsp+390h],0
    je      L9
    mov     rdx,[rsp+390h]
    mov     [rsp+370h],rdx
    mov     qword ptr [rsp+28h],1
    mov     rdi,[rsp+448h]
    add     rdi,[rsp+28h]
    mov     [rsp+360h],rdi
    setb    cl
    mov     [rsp+368h],cl
    test    byte ptr [rsp+368h],0FFh
    je      L13
    lea     r9,[k19]
    mov     [rsp+28h],r9
    mov     rdi,[rsp+28h]
    call    qword ptr [sym20]
    ud2
L13:
    mov     rax,[rsp+360h]
    mov     [rsp+448h],rax
    mov     rdx,[rsp+440h]
    mov     [rsp+350h],rdx
    mov     rsi,[rsp+370h]
    mov     rsi,[rsi]
    mov     [rsp+348h],rsi
    mov     rdi,[rsp+350h]
    mov     rsi,[rsp+348h]
    call    fn21
    mov     [rsp+358h],rax
    mov     rax,[rsp+358h]
    mov     [rsp+440h],rax
    jmp     L9
L14:
    lea     rax,[rsp+518h]
    mov     [rsp+330h],rax
    mov     rdi,[rsp+330h]
    call    fn22
    lea     rax,[rsp+518h]
    mov     [rsp+2F8h],rax
    lea     rdi,[rsp+300h]
    mov     rsi,[rsp+2F8h]
    call    fn23
    mov     rax,[rsp+300h]
    mov     rcx,[rsp+308h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+310h]
    mov     rcx,[rsp+318h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+320h]
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp],0
    lea     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn24
    mov     [rsp+328h],rax
    lea     rdi,[rsp+2D8h]
    call    fn25
    mov     dword ptr [rsp+2C8h],0
    mov     dword ptr [rsp+2CCh],1FBD0h
    mov     edi,[rsp+2C8h]
    mov     esi,[rsp+2CCh]
    call    fn26
    mov     [rsp+2D0h],eax
    mov     [rsp+2D4h],edx
    mov     rax,[rsp+2D0h]
    mov     [rsp+2C0h],rax
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L16:
    lea     rax,[rsp+2C0h]
    mov     [rsp+2B0h],rax
    mov     rdi,[rsp+2B0h]
    call    fn27
    mov     [rsp+2B8h],eax
    mov     [rsp+2BCh],edx
    mov     eax,[rsp+2B8h]
    mov     [rsp+2A8h],rax
    cmp     rax,0
    je      L17
    mov     esi,[rsp+2BCh]
    mov     [rsp+2A4h],esi
    lea     rdi,[rsp+2D8h]
    mov     [rsp+268h],rdi
    mov     dword ptr [rsp+2Ch],138Bh
    cmp     dword ptr [rsp+2Ch],0
    sete    [rsp+213h]
    test    byte ptr [rsp+213h],0FFh
    je      L18
    lea     r11,[k28]
    mov     [rsp+28h],r11
    mov     rdi,[rsp+28h]
    call    qword ptr [sym29]
    ud2
L17:
    lea     rax,[rsp+518h]
    mov     [rsp+178h],rax
    mov     rdi,[rsp+178h]
    call    fn30
    mov     [rsp+180h],rax
    jmp     L20
L18:
    mov     eax,[rsp+2A4h]
    mov     ecx,0D196E5F5h
    imul    rax,rcx
    shr     rax,2Ch
    mov     [rsp+24h],eax
    imul    edx,[rsp+24h],138Bh
    mov     esi,[rsp+2A4h]
    sub     esi,edx
    mov     [rsp+214h],esi
    lea     rdi,[rsp+214h]
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+1F0h]
    mov     rsi,[rsp+68h]
    call    fn31
    mov     rax,[rsp+1F0h]
    mov     rcx,[rsp+1F8h]
    mov     [rsp+208h],rcx
    mov     [rsp+200h],rax
    lea     rdx,[k32]
    mov     [rsp+1E8h],rdx
    lea     rsi,[rsp+200h]
    mov     [rsp+1E0h],rsi
    mov     rdi,[rsp+1E8h]
    mov     rsi,[rsp+1E0h]
    call    fn33
    mov     [rsp+228h],rax
    mov     [rsp+230h],rdx
    lea     rdi,[rsp+238h]
    mov     rsi,[rsp+228h]
    mov     rdx,[rsp+230h]
    call    fn34
    mov     rax,[rsp+238h]
    mov     rcx,[rsp+240h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdx,[rsp+248h]
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+250h]
    lea     rsi,[rsp+18h]
    call    fn35
    mov     rax,[rsp+250h]
    mov     rcx,[rsp+258h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdx,[rsp+260h]
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+270h]
    mov     rsi,[rsp+268h]
    lea     rdx,[rsp+18h]
    call    fn36
    mov     rax,[rsp+270h]
    mov     rcx,[rsp+278h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+280h]
    mov     rcx,[rsp+288h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+290h]
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+8]
    call    fn37
    mov     [rsp+298h],rax
    mov     rax,[rsp+298h]
    mov     rax,[rax]
    mov     qword ptr [rsp+20h],1
    add     rax,[rsp+20h]
    mov     [rsp+1D0h],rax
    setb    cl
    mov     [rsp+1D8h],cl
    test    byte ptr [rsp+1D8h],0FFh
    je      L19
    lea     rdi,[k38]
    mov     [rsp+28h],rdi
    mov     rdi,[rsp+28h]
    call    qword ptr [sym39]
    ud2
L19:
    mov     rax,[rsp+298h]
    mov     rcx,[rsp+1D0h]
    mov     [rax],rcx
    jmp     L15
L20:
    lea     rax,[rsp+180h]
    mov     [rsp+188h],rax
    lea     rdx,[rsp+2D8h]
    mov     [rsp+160h],rdx
    mov     rdi,[rsp+160h]
    call    fn40
    mov     [rsp+168h],rax
    lea     rax,[rsp+168h]
    lea     rdx,[rsp+340h]
    lea     rsi,[rsp+448h]
    lea     rdi,[rsp+440h]
    lea     r8,[rsp+328h]
    mov     r9,[rsp+188h]
    mov     [rsp+190h],r9
    mov     [rsp+198h],rax
    mov     [rsp+1A0h],rdx
    mov     [rsp+1A8h],rsi
    mov     [rsp+1B0h],rdi
    mov     [rsp+1B8h],r8
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0D0h]
    mov     rsi,[rsp+60h]
    call    fn41
    mov     rax,[rsp+1A8h]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+0C0h]
    mov     rsi,[rsp+58h]
    call    fn42
    mov     rax,[rsp+1B0h]
    mov     [rsp+50h],rax
    lea     rdi,[rsp+0B0h]
    mov     rsi,[rsp+50h]
    call    fn43
    mov     rax,[rsp+190h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0A0h]
    mov     rsi,[rsp+48h]
    call    fn44
    mov     rax,[rsp+1B8h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+90h]
    mov     rsi,[rsp+40h]
    call    fn45
    mov     rax,[rsp+198h]
    mov     [rsp+38h],rax
    lea     rdi,[rsp+80h]
    mov     rsi,[rsp+38h]
    call    fn46
    mov     rax,[rsp+0D0h]
    mov     rcx,[rsp+0D8h]
    mov     [rsp+0E8h],rcx
    mov     [rsp+0E0h],rax
    mov     rdx,[rsp+0C0h]
    mov     rcx,[rsp+0C8h]
    mov     [rsp+0F8h],rcx
    mov     [rsp+0F0h],rdx
    mov     rsi,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     [rsp+108h],rcx
    mov     [rsp+100h],rsi
    mov     rdi,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     [rsp+118h],rcx
    mov     [rsp+110h],rdi
    mov     r8,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+128h],rcx
    mov     [rsp+120h],r8
    mov     r9,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+138h],rcx
    mov     [rsp+130h],r9
    lea     r10,[k47]
    mov     [rsp+78h],r10
    lea     r11,[rsp+0E0h]
    mov     [rsp+70h],r11
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+70h]
    call    fn48
    mov     [rsp+1C0h],rax
    mov     [rsp+1C8h],rdx
    mov     rdi,[rsp+1C0h]
    mov     rsi,[rsp+1C8h]
    call    qword ptr [sym49]
    lea     rax,[rsp+2D8h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn50
    lea     rax,[rsp+518h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn51
    add     rsp,548h
    ret
    nop     [rax+rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L22:
    lea     rax,[rsp+2D8h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn52
    nop     [rax+rax]
    nop     [rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L24:
    lea     rax,[rsp+518h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn53
    lea     rdi,[rsp+540h]
    mov     esi,0FFFFFAF0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L26:
    call    qword ptr [sym54]
    ud2
    lea     rdi,[rsp+540h]
    mov     rsi,rax
    mov     edx,0FFFFFAF0h
    call    ryo_h_Lpad
    jmp     L23
    lea     rdi,[rsp+540h]
    mov     rsi,rax
    mov     edx,0FFFFFAF0h
    call    ryo_h_Lpad
    jmp     L21
    lea     rdi,[rsp+540h]
    mov     rsi,rax
    mov     edx,0FFFFFAF0h
    call    ryo_h_Lpad
    jmp     L25
L27:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L28:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L10
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L16
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L22
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L24
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L26
L33:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+10h],3
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn1
    mov     [rsp+18h],rax
    cmp     qword ptr [rsp+18h],0
    setne   [rsp+3Fh]
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#1}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::alloc::Global::alloc_impl_runtime [hint]
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,0B8h
    mov     [rsp+90h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+8Fh],dl
    mov     rax,[rsp+98h]
    mov     [rsp+38h],rax
    cmp     rax,0
    je      L1
    test    byte ptr [rsp+8Fh],0FFh
    je      L3
    jmp     L2
L1:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+10h],rdx
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
L2:
    call    qword ptr [sym0]
    jmp     L10
L3:
    call    qword ptr [sym1]
    jmp     L11
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L5:
    mov     rax,[rsp+70h]
    cmp     rax,0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L7:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    add     rsp,0B8h
    ret
L8:
    mov     rax,[rsp+60h]
    mov     [rsp+8],rax
    lea     rdx,[k2]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn3
L9:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    jmp     L6
L10:
    mov     rax,[rsp+90h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym4]
    mov     [rsp+70h],rax
    jmp     L4
L11:
    mov     rax,[rsp+90h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym5]
    mov     [rsp+70h],rax
    jmp     L4
L12:
    mov     qword ptr [rsp+20h],0
    mov     qword ptr [rsp+28h],0
    mov     qword ptr [rsp+28h],1
    cmp     qword ptr [rsp+28h],1
    sete    [rsp+27h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k6]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L6
L13:
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L14
    mov     rsi,[rsp+70h]
    mov     [rsp+8],rsi
    lea     rdi,[k7]
    mov     [rsp],rdi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn8
L14:
    mov     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     [rsp+68h],rax
    mov     [rsp+18h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L15
    mov     r8,[rsp+68h]
    mov     [rsp+10h],r8
    lea     r9,[k9]
    mov     [rsp],r9
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp]
    call    fn10
L15:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    jmp     L6
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::__m128i::as_i8x16 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD0h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_cmpeq_epi8 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,98h
    mov     [rsp+58h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF88h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp]
    call    fn0
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp]
    call    fn1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA0h
    mov     ecx,0FFFFFF90h
    call    ryo_h_VeqI8x16
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+58h]
    add     rsp,98h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_cmpgt_epi8 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,98h
    mov     [rsp+58h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF88h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp]
    call    fn0
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp]
    call    fn1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_VltSI8x16
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+58h]
    add     rsp,98h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_load_si128 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_loadu_si128 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    lea     rdx,[rsp+20h]
    mov     [rsp+10h],rdx
    call    fn1
    mov     [rsp+8],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn2
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+30h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_movemask_epi8 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp]
    call    fn0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_VltSI8x16
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFCAh
    mov     edx,0FFFFFFD0h
    call    ryo_h_VmsbI8x16
    movzx   eax,word ptr [rsp+2Ah]
    mov     [rsp+5Ch],eax
    mov     eax,[rsp+5Ch]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_or_si128 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+8],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_OrW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+18h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_set1_epi8 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+2Fh],sil
    lea     rdi,[rsp+10h]
    movzx   esi,byte ptr [rsp+2Fh]
    call    fn0
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    lea     rsi,[rsp]
    call    fn1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+20h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_setzero_si128 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+8],rdi
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::arch::x86_64::_mm_store_si128 [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+8],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD8h
    xor     ecx,ecx
    mov     r8d,10h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    call    ryo_h_StoreW128
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    sete    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    mov     eax,[rax]
    mov     rdx,[rsp+8]
    mov     edx,[rdx]
    cmp     eax,edx
    setb    [rsp+1Fh]
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::entry [hint]
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,0F8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+0C0h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF28h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+0C0h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+0B0h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+78h]
    mov     rsi,[rsp+70h]
    lea     rdx,[rsp]
    call    fn0
    cmp     qword ptr [rsp+78h],0FFFFFFFFFFFFFFFFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+0A0h]
    add     rsp,0F8h
    ret
    ud2
L3:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+98h]
    mov     [rsp+0C8h],rax
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rsi
    mov     [rsp+0E0h],rdi
    mov     [rsp+0E8h],r8
    jmp     L1
L4:
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+68h],rcx
    mov     rcx,[rsp+68h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+0D8h],rcx
    mov     [rsp+0D0h],rax
    mov     qword ptr [rsp+0C8h],0FFFFFFFFFFFFFFFFh
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::len
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     rax,[rax+18h]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::entry [hint]
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,88h
    mov     [rsp+50h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+58h]
    call    fn0
    cmp     qword ptr [rsp+38h],0
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,88h
    ret
    ud2
L3:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rsi
    jmp     L1
L4:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+28h],rcx
    mov     rcx,[rsp+28h]
    mov     [rsp+18h],rcx
    mov     rcx,[rsp+18h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+68h],0
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::get::<u64> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::len
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     rax,[rax+18h]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::retain::<{closure@bench/hashmap.rs:27:16: 27:22}> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>::values
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,98h
    mov     [rsp+58h],rdi
    mov     [rsp+60h],rsi
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    lea     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     rax,[rsp+8]
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rdi
    mov     [rsp+88h],r8
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+58h]
    add     rsp,98h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::hash_map::Entry::<'_, std::string::String, usize>::or_default [hint]
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,138h
    mov     [rsp+28h],rdi
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFEF8h
    xor     ecx,ecx
    mov     r8d,28h
    call    ryo_h_LoadCopy
    cmp     qword ptr [rsp+100h],0FFFFFFFFFFFFFFFFh
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+100h]
    mov     rdx,[rsp+108h]
    mov     rsi,[rsp+110h]
    mov     rdi,[rsp+118h]
    mov     r8,[rsp+120h]
    mov     byte ptr [rsp+0F7h],1
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     [rsp+98h],rsi
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],r8
    call    fn0
    mov     [rsp+80h],rax
    jmp     L3
L2:
    mov     rax,[rsp+108h]
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+110h]
    mov     [rsp+0B8h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L15
    jmp     L14
L3:
    mov     byte ptr [rsp+0F7h],0
    mov     rdx,[rsp+0A8h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+88h]
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+98h]
    mov     r9,[rsp+0A0h]
    mov     [rsp+30h],r9
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp+68h],r8
    mov     r10,[rsp+80h]
    mov     [rsp+70h],r10
    mov     rcx,[rsp+60h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rsi
    mov     rcx,[rsp+70h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+50h]
    lea     rdx,[rsp+8]
    call    fn1
    mov     [rsp+78h],rax
    jmp     L20
    nop     [rax+rax]
    xchg    ax,ax
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L5:
    mov     rax,[rsp+128h]
    add     rsp,138h
    ret
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L7:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFA8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L9:
    lea     rax,[rsp+88h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn2
    jmp     L6
    nop     [rax+rax]
    nop
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L11:
    test    byte ptr [rsp+0F7h],0FFh
    je      L6
    jmp     L8
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L13:
    mov     rax,[rsp+0C8h]
    lea     rax,[rax+18h]
    mov     [rsp+128h],rax
    jmp     L4
L14:
    ud2
L15:
    mov     rax,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L17:
    jmp     L12
L18:
    ud2
L19:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+20h],20h
    add     rdx,rcx
    mov     [rsp+0C8h],rdx
    jmp     L16
L20:
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L24
    jmp     L23
    nop     [rax+rax]
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L22:
    mov     rax,[rsp+68h]
    lea     rax,[rax+18h]
    mov     [rsp+128h],rax
    jmp     L4
L23:
    ud2
L24:
    mov     rax,[rsp+78h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L28
    jmp     L27
    nop     [rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L26:
    jmp     L21
L27:
    ud2
L28:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+20h],20h
    add     rdx,rcx
    mov     [rsp+68h],rdx
    jmp     L25
    nop
L29:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L30:
    call    qword ptr [sym3]
    ud2
    lea     rdi,[rsp+130h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+130h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L29
L31:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L32:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L33:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L34:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L35:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L36:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L37:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L38:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L26
L39:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L30
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert [hint]
    inc     qword ptr [jit_record]
    jns     L36
L0:
    sub     rsp,0B8h
    mov     [rsp+10h],rdi
    mov     [rsp+88h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF60h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    cmp     qword ptr [rsp+90h],0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+98h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0A0h]
    mov     rsi,[rsp+90h]
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+7Fh],0
    mov     r8,[rsp+88h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],r8
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    call    fn0
    mov     [rsp+50h],rax
    jmp     L11
L2:
    mov     rax,[rsp+98h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+40h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L23
    jmp     L22
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L8:
    jmp     L5
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L10:
    test    byte ptr [rsp+7Fh],0FFh
    je      L5
    jmp     L7
L11:
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L13:
    mov     rax,[rsp+40h]
    lea     rax,[rax+8]
    mov     [rsp+0A8h],rax
    jmp     L3
L14:
    ud2
L15:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L19
    jmp     L18
    nop     [rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L17:
    jmp     L12
L18:
    ud2
L19:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L16
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L21:
    mov     rax,[rsp+50h]
    lea     rax,[rax+8]
    mov     [rsp+0A8h],rax
    jmp     L3
L22:
    ud2
L23:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L27
    jmp     L26
    nop     [rax]
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L25:
    jmp     L20
L26:
    ud2
L27:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L24
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L9
L28:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L29:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L30:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L31:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L32:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L33:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L34:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L21
L35:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L25
L36:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::Arguments::<'_>::new::<4, 1> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::Arguments::<'_>::new::<59, 6> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::format [hint]
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,0B8h
    mov     [rsp+78h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    and     rax,1
    mov     [rsp+58h],rax
    cmp     rax,1
    je      L3
    jmp     L4
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+78h]
    add     rsp,0B8h
    ret
L3:
    mov     rax,[rsp+88h]
    mov     [rsp+30h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+60h]
    shr     rdx,1
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L8
    jmp     L7
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L6:
    lea     rax,[rsp+88h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+98h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+60h]
    call    fn1
    jmp     L1
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     rdi,[k2]
    mov     [rsp],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+28h]
    mov     r8,[rsp]
    call    fn3
L8:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+28h]
    mov     [rsp+40h],rdx
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+70h],rcx
    mov     [rsp+68h],rax
    jmp     L5
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::format::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+10h],rdi
    mov     [rsp+20h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD8h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::assert_unchecked::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+7Fh],dil
    mov     [rsp+18h],rsi
    test    byte ptr [rsp+7Fh],0FFh
    jne     L1
    lea     rdx,[k0]
    mov     qword ptr [rsp+70h],0DDh
    mov     rdi,[rsp+70h]
    lea     r8,[k1]
    mov     qword ptr [rsp+28h],0DDh
    mov     r10,[rsp+28h]
    shl     r10,1
    or      r10,1
    mov     [rsp+58h],rdx
    mov     [rsp+60h],r10
    mov     byte ptr [rsp+17h],0
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::black_box::<u64> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::must_use::<std::string::String> [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+10h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::cold_path [cold]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,8
    add     rsp,8
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::rotate_left::<u64>
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+3Ch],esi
    mov     qword ptr [rsp+18h],8
    mov     rdx,[rsp+18h]
    mov     [rsp+24h],edx
    imul    esi,[rsp+24h],8
    mov     [rsp+28h],esi
    cmp     esi,0
    jne     L1
    lea     r8,[k0]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     eax,[rsp+3Ch]
    xor     edx,edx
    div     dword ptr [rsp+28h]
    mov     [rsp+2Ch],edx
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+10h],3Fh
    mov     rdi,[rsp+10h]
    sub     rdi,rdx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+40h]
    mov     ecx,[rsp+18h]
    shl     r8,cl
    mov     r9,[rsp+40h]
    shr     r9,1
    mov     ecx,[rsp+10h]
    shr     r9,cl
    or      r8,r9
    mov     [rsp+48h],r8
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L3:
    call    qword ptr [sym2]
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L2
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::typed_swap_nonoverlapping::<hashbrown::raw::RawTableInner> [hint]
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    call    fn1
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    call    qword ptr [sym2]
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::StepBy::<std::ops::Range<u64>>::new [hint]
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,98h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+58h],rcx
    mov     byte ptr [rsp+57h],1
    cmp     qword ptr [rsp+58h],0
    je      L1
    mov     byte ptr [rsp+57h],0
    mov     rdi,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+58h]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L2
L1:
    lea     rax,[k1]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],1Bh
    lea     rsi,[k2]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym3]
    ud2
L2:
    mov     rax,[rsp+58h]
    sub     rax,1
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdx
    mov     [rsp+80h],rax
    mov     byte ptr [rsp+88h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+40h]
    add     rsp,98h
    ret
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L6:
    jmp     L3
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L8:
    test    byte ptr [rsp+57h],0FFh
    je      L3
    jmp     L5
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L7
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L11:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::StepBy::<std::ops::Range<usize>>::new [hint]
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,98h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+58h],rcx
    mov     byte ptr [rsp+57h],1
    cmp     qword ptr [rsp+58h],0
    je      L1
    mov     byte ptr [rsp+57h],0
    mov     rdi,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+58h]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L2
L1:
    lea     rax,[k1]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],1Bh
    lea     rsi,[k2]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym3]
    ud2
L2:
    mov     rax,[rsp+58h]
    sub     rax,1
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdx
    mov     [rsp+80h],rax
    mov     byte ptr [rsp+88h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+40h]
    add     rsp,98h
    ret
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L6:
    jmp     L3
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L8:
    test    byte ptr [rsp+57h],0FFh
    je      L3
    jmp     L5
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L7
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L11:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<u64>> for std::ops::Range<u64>>::setup [hint]
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,98h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+68h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+78h]
    mov     [rsp+10h],r8
    cmp     r8,rdi
    jae     L4
    jmp     L5
L1:
    mov     qword ptr [rsp+28h],0
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L3:
    cmp     qword ptr [rsp+68h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L7
    lea     rsi,[k0]
    mov     [rsp],rsi
    mov     rdi,[rsp]
    call    qword ptr [sym1]
    ud2
L4:
    mov     rax,[rsp+10h]
    sub     rax,[rsp+18h]
    mov     [rsp+28h],rax
    jmp     L6
L5:
    mov     qword ptr [rsp+28h],0
L6:
    jmp     L2
L7:
    mov     rax,[rsp+28h]
    xor     edx,edx
    div     qword ptr [rsp+68h]
    mov     [rsp+20h],rax
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    lea     rsi,[k2]
    mov     [rsp],rsi
    mov     rdi,[rsp]
    call    qword ptr [sym3]
    ud2
L8:
    mov     rax,[rsp+28h]
    xor     edx,edx
    div     qword ptr [rsp+68h]
    mov     [rsp+10h],rdx
    cmp     rdx,0
    jbe     L9
    mov     rdi,[rsp+20h]
    add     rdi,1
    mov     [rsp+58h],rdi
    jmp     L10
L9:
    mov     rax,[rsp+20h]
    mov     [rsp+58h],rax
L10:
    mov     rax,[rsp+58h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rdx
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<usize>> for std::ops::Range<usize>>::setup [hint]
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,98h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+68h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+78h]
    mov     [rsp+10h],r8
    cmp     r8,rdi
    jae     L4
    jmp     L5
L1:
    mov     qword ptr [rsp+28h],0
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L3:
    cmp     qword ptr [rsp+68h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L7
    lea     rsi,[k0]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    ud2
L4:
    mov     rax,[rsp+10h]
    sub     rax,[rsp+18h]
    mov     [rsp+28h],rax
    jmp     L6
L5:
    mov     qword ptr [rsp+28h],0
L6:
    jmp     L2
L7:
    mov     rax,[rsp+28h]
    xor     edx,edx
    div     qword ptr [rsp+68h]
    mov     [rsp+20h],rax
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    lea     rsi,[k2]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym3]
    ud2
L8:
    mov     rax,[rsp+28h]
    xor     edx,edx
    div     qword ptr [rsp+68h]
    mov     [rsp+10h],rdx
    cmp     rdx,0
    jbe     L9
    mov     rdi,[rsp+20h]
    add     rdi,1
    mov     [rsp+58h],rdi
    jmp     L10
L9:
    mov     rax,[rsp+20h]
    mov     [rsp+58h],rax
L10:
    mov     rax,[rsp+58h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rdx
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,78h
    mov     [rsp+58h],rdi
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rsp+18h],rax
    cmp     rax,0
    je      L8
    jmp     L9
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    add     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+28h]
    mov     [rdx],rcx
    mov     rsi,[rsp+40h]
    sub     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+58h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    mov     r8,[rsp+30h]
    mov     [rsp+68h],r8
    mov     qword ptr [rsp+60h],1
    jmp     L5
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L5:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L7:
    ud2
L8:
    lea     rax,[k1]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L6
L9:
    mov     rax,[rsp+18h]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+38h],0
    mov     rsi,[rsp+58h]
    mov     rsi,[rsi+8]
    mov     [rsp+40h],rsi
    cmp     rsi,0
    ja      L1
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u32>>::next [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rdi,[rsp]
    call    fn0
    mov     [rsp+8],eax
    mov     [rsp+0Ch],edx
    mov     eax,[rsp+8]
    mov     edx,[rsp+0Ch]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::mem::size_of::<std::arch::x86_64::__m128i> [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     qword ptr [rsp+8],10h
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::num::NonZero::<T>::new_unchecked::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+10h],rdi
    lea     rax,[k0]
    mov     qword ptr [rsp+68h],0D1h
    mov     rsi,[rsp+68h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+20h],0D1h
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    ud2
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}> [hint]
    inc     qword ptr [jit_record]
    jns     L17
L0:
    sub     rsp,78h
    mov     [rsp+20h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+40h],rcx
    mov     byte ptr [rsp+36h],1
    mov     byte ptr [rsp+37h],1
    cmp     qword ptr [rsp+48h],0
    je      L1
    jmp     L2
    ud2
L1:
    mov     byte ptr [rsp+36h],0
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+58h]
    mov     rsi,[rsp+18h]
    call    fn0
    jmp     L3
L2:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+18h],rcx
    mov     byte ptr [rsp+37h],0
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp+58h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn1
    jmp     L3
L3:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+20h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L5:
    test    byte ptr [rsp+36h],0FFh
    jne     L12
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L7:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L9:
    jmp     L4
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L11:
    test    byte ptr [rsp+37h],0FFh
    je      L4
    jmp     L8
L12:
    jmp     L6
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L10
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L16:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L17:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::NonNull::<T>::new_unchecked::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+78h]
    cmp     rax,0
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L1
    lea     rdi,[k0]
    mov     qword ptr [rsp+70h],0D2h
    mov     r9,[rsp+70h]
    lea     r10,[k1]
    mov     qword ptr [rsp+20h],0D2h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     rsi,[rsp+10h]
    mov     [rsp],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to [hint]
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF84h
    mov     edx,0FFFFFFE8h
    call    ryo_h_CtpopW64
    mov     eax,[rsp+4]
    mov     [rsp+60h],eax
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+68h]
    sub     rdx,1
    and     rax,rdx
    cmp     rax,0
    sete    [rsp+7Fh]
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    lea     rax,[k0]
    mov     qword ptr [rsp+48h],2Ah
    mov     rsi,[rsp+48h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+10h],2Ah
    mov     r9,[rsp+10h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    lea     r10,[k2]
    mov     [rsp],r10
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp]
    call    qword ptr [sym3]
    ud2
L5:
    cmp     dword ptr [rsp+60h],1
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L3
    jmp     L1
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::copy_nonoverlapping::<u8> [always]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rsi,[rsp+38h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+30h]
    mov     [rsp+18h],rdi
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     r10,[k0]
    mov     [rsp],r10
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+28h]
    mov     r9,[rsp]
    call    fn1
L1:
    imul    rax,[rsp+28h],1
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_Memcpy
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::copy_nonoverlapping::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+18h],r9
    cmp     qword ptr [rsp+98h],0
    jne     L1
    mov     byte ptr [rsp+97h],1
    jmp     L2
L1:
    cmp     qword ptr [rsp+0A8h],0
    sete    [rsp+97h]
L2:
    movzx   eax,byte ptr [rsp+97h]
    mov     [rsp+6Dh],al
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+6Ch],al
    jmp     L19
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+88h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+6Ch],al
    jmp     L26
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L6:
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+6Fh],al
    jmp     L27
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    jmp     L9
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L10:
    lea     rax,[k3]
    mov     qword ptr [rsp+80h],11Bh
    mov     rsi,[rsp+80h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+28h],11Bh
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym5]
    ud2
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L12:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L14:
    test    byte ptr [rsp+6Dh],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L16:
    jmp     L9
L17:
    jmp     L3
L18:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Eh],sil
    test    byte ptr [rsp+6Eh],0FFh
    je      L9
    jmp     L3
L19:
    test    byte ptr [rsp+6Ch],0FFh
    je      L15
    jmp     L13
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    test    byte ptr [rsp+97h],0FFh
    je      L25
    jmp     L24
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L23:
    jmp     L7
L24:
    jmp     L5
L25:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Dh],sil
    test    byte ptr [rsp+6Dh],0FFh
    je      L7
    jmp     L5
L26:
    test    byte ptr [rsp+6Ch],0FFh
    je      L22
    jmp     L20
L27:
    test    byte ptr [rsp+6Fh],0FFh
    je      L9
    jmp     L11
    nop
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L29:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L28
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L36:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L16
L37:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L38:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L39:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym0]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(std::string::String, usize)>> - shim(Some(hashbrown::raw::RawTable<(std::string::String, usize)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(u64, u64)>> - shim(Some(hashbrown::raw::RawTable<(u64, u64)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>> - shim(Some(hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>> - shim(Some(std::collections::HashMap<std::string::String, usize, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>> - shim(Some(std::collections::HashMap<u64, u64, std::hash::BuildHasherDefault<std::hash::DefaultHasher>>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::collections::hash_map::VacantEntry<'_, std::string::String, usize>> - shim(Some(std::collections::hash_map::VacantEntry<'_, std::string::String, usize>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    qword ptr [sym0]
    jmp     L7
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    jmp     L3
L7:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L9:
    call    qword ptr [sym3]
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L8
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<1> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    mov     rdx,[rsp+10h]
    movzx   edx,byte ptr [rdx]
    mov     [rsp+0Eh],dl
    mov     rsi,[rsp+18h]
    movzx   ecx,byte ptr [rsp+0Eh]
    mov     [rsi],cl
    mov     rdi,[rsp+10h]
    movzx   ecx,byte ptr [rsp+0Fh]
    mov     [rdi],cl
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<2> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    movzx   eax,word ptr [rax]
    mov     [rsp+0Eh],ax
    mov     rdx,[rsp+10h]
    movzx   edx,word ptr [rdx]
    mov     [rsp+0Ch],dx
    mov     rsi,[rsp+18h]
    movzx   ecx,word ptr [rsp+0Ch]
    mov     [rsi],cx
    mov     rdi,[rsp+10h]
    movzx   ecx,word ptr [rsp+0Eh]
    mov     [rdi],cx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<4> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     eax,[rax]
    mov     [rsp+0Ch],eax
    mov     rdx,[rsp+10h]
    mov     edx,[rdx]
    mov     [rsp+8],edx
    mov     rsi,[rsp+18h]
    mov     ecx,[rsp+8]
    mov     [rsi],ecx
    mov     rdi,[rsp+10h]
    mov     ecx,[rsp+0Ch]
    mov     [rdi],ecx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<8> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdx,[rsp+10h]
    mov     rdx,[rdx]
    mov     [rsp],rdx
    mov     rsi,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     [rdi],rcx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping::<hashbrown::raw::RawTableInner> [hint]
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+20h],rcx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     rsi,[rsp+78h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+70h]
    mov     [rsp+58h],rdi
    mov     qword ptr [rsp+18h],20h
    mov     qword ptr [rsp+10h],8
    mov     r10,[rsp+20h]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+8]
    call    fn0
L1:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+68h]
    mov     [rsp+60h],rdx
    mov     rcx,[rsp+60h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    imul    rsi,[rsp+48h],20h
    mov     [rsp+50h],rsi
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+40h]
    call    fn1
    jmp     L4
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    add     rsp,88h
    ret
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L4
    jmp     L2
    ud2
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+10h],r9
    cmp     qword ptr [rsp+0A8h],0
    jne     L1
    mov     byte ptr [rsp+97h],1
    jmp     L2
L1:
    cmp     qword ptr [rsp+98h],0
    sete    [rsp+97h]
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+88h],rax
    movzx   edx,byte ptr [rsp+97h]
    mov     [rsp+65h],dl
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+64h],al
    jmp     L19
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+80h],rax
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+64h],al
    jmp     L26
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L6:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+67h],al
    jmp     L27
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    jmp     L9
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L10:
    lea     rax,[k3]
    mov     qword ptr [rsp+78h],11Bh
    mov     rsi,[rsp+78h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+20h],11Bh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym5]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L12:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L14:
    test    byte ptr [rsp+65h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L16:
    jmp     L9
L17:
    jmp     L3
L18:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+66h],sil
    test    byte ptr [rsp+66h],0FFh
    je      L9
    jmp     L3
L19:
    test    byte ptr [rsp+64h],0FFh
    je      L15
    jmp     L13
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    test    byte ptr [rsp+97h],0FFh
    je      L25
    jmp     L24
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L23:
    jmp     L7
L24:
    jmp     L5
L25:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+65h],sil
    test    byte ptr [rsp+65h],0FFh
    je      L7
    jmp     L5
L26:
    test    byte ptr [rsp+64h],0FFh
    je      L22
    jmp     L20
L27:
    test    byte ptr [rsp+67h],0FFh
    je      L9
    jmp     L11
    nop
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L29:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L28
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L36:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L16
L37:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L38:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L39:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes [hint]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    shr     rax,3
    mov     [rsp+38h],rax
    mov     rdx,[rsp+40h]
    and     rdx,7
    mov     [rsp+30h],rdx
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L1
    mov     [rsp+20h],rax
    mov     rdi,[rsp+68h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+60h]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    call    fn0
    jmp     L1
L1:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L2
    mov     [rsp+20h],rax
    imul    rsi,[rsp+38h],8
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+60h]
    imul    rcx,rsi,1
    add     r8,rcx
    mov     [rsp+8],r8
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+20h]
    call    fn1
    jmp     L2
L2:
    add     rsp,78h
    ret
    ud2
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     rax,[rsp+78h]
    mov     qword ptr [rsp+68h],0
    mov     [rsp+70h],rax
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    cmp     rax,rdx
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L1
L5:
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
L6:
    add     rsp,98h
    ret
L7:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L8:
    mov     rax,[rsp+28h]
    add     rax,1
    mov     [rsp+68h],rax
    mov     rdx,[rsp+28h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rsp+18h],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn2
    jmp     L3
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short [hint]
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],0
    and     rax,4
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L1
    mov     rdi,[rsp+30h]
    mov     r8,[rsp+68h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rsp+28h],r8
    mov     r9,[rsp+30h]
    mov     r10,[rsp+60h]
    imul    rcx,r9,1
    add     r10,rcx
    mov     [rsp+18h],r10
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn0
    mov     rax,[rsp+30h]
    or      rax,4
    mov     [rsp+30h],rax
    jmp     L1
L1:
    mov     rax,[rsp+38h]
    and     rax,2
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rsp+30h]
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+30h]
    mov     r9,[rsp+60h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+18h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn1
    mov     rax,[rsp+30h]
    or      rax,2
    mov     [rsp+30h],rax
    jmp     L2
L2:
    mov     rax,[rsp+38h]
    and     rax,1
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L3
    mov     rsi,[rsp+30h]
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+30h]
    mov     r9,[rsp+60h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+18h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn2
    mov     rax,[rsp+30h]
    or      rax,1
    mov     [rsp+30h],rax
    jmp     L3
L3:
    add     rsp,78h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+2Fh],cl
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    lea     rsi,[k0]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    movzx   r8d,byte ptr [rsp+2Fh]
    call    qword ptr [sym1]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    call    fn1
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::from_raw_parts::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L26
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+80h],rcx
    mov     [rsp+10h],r8
    mov     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+88h]
    call    fn0
    mov     [rsp+66h],al
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    cmp     qword ptr [rsp+90h],0
    je      L14
    jmp     L15
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L4:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L6:
    jmp     L7
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L8:
    lea     rax,[k1]
    mov     qword ptr [rsp+78h],117h
    mov     rsi,[rsp+78h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+20h],117h
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L10:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L7
    jmp     L1
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L12:
    jmp     L7
L13:
    test    byte ptr [rsp+66h],0FFh
    je      L11
    jmp     L9
L14:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L16
L15:
    mov     rax,7FFFFFFFFFFFFFFFh
    xor     edx,edx
    div     qword ptr [rsp+90h]
    mov     [rsp+58h],rax
L16:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L18:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L17
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L24:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L25:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L18
L26:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::str::<impl std::borrow::ToOwned for str>::to_owned [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rdx
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn0
    mov     rax,[rsp+18h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+20h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+28h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+30h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()> [never]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<T, A>::set_len::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0C6h
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0C6h
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq [hint]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     rax,[rsp+60h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx+10h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+58h]
    mov     rsi,[rsi+8]
    mov     rdi,[rsp+58h]
    mov     rdi,[rdi+10h]
    mov     [rsp+28h],rdi
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdi
    mov     r8,[rsp+40h]
    cmp     r8,[rsp+28h]
    jne     L1
    mov     [rsp+18h],rax
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+6Fh],al
    jmp     L2
L1:
    mov     byte ptr [rsp+6Fh],0
L2:
    movzx   eax,byte ptr [rsp+6Fh]
    add     rsp,78h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

