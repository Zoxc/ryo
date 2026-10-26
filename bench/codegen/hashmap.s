fn <! as std::sys::thread_local::native::lazy::DestroyedState>::register_dtor::<std::cell::Cell<(u64, u64)>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <&mut core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write::write_fmt::SpecWriteFmt>::spec_write_fmt [hint]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    cmp     qword ptr [rsp+18h],0
    je      L1
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rdx
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+4Fh],al
    jmp     L2
L1:
    mov     rax,[rsp+40h]
    mov     [rsp+18h],rax
    lea     rdx,[k2]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    call    qword ptr [sym3]
    mov     [rsp+4Fh],al
L2:
    movzx   eax,byte ptr [rsp+4Fh]
    add     rsp,58h
    ret
    ud2
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

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
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFE8h
    call    ryo_h_RemUW64
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
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFFB8h
    call    ryo_h_ShlW64
    mov     rax,[rsp+98h]
    mov     rax,[rax+38h]
    or      rax,[rsp+68h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rdx+38h],rcx
    mov     rsi,[rsp+80h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+70h]
    cmp     rdi,rsi
    jae     L3
    mov     r8,[rsp+98h]
    mov     r8,[r8+40h]
    add     r8,rdi
    mov     [rsp+10h],r8
    mov     r9,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [r9+40h],rcx
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
    xchg    ax,ax
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

fn <core::io::error::repr::Repr as std::ops::Drop>::drop [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn0
    lea     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn1
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L1
    mov     rsi,[rsp+20h]
    mov     [rsp+10h],rsi
    lea     rdi,[k0]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn1
L1:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_char
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+6Ch],esi
    mov     dword ptr [rsp+2Ch],0
    lea     rdx,[rsp+2Ch]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+40h],4
    mov     edi,[rsp+6Ch]
    mov     [rsp+28h],edi
    mov     edi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    jmp     L3
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L2:
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
L3:
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     [rsp+10h],rdx
    mov     rcx,[rsp+10h]
    mov     [rsp+60h],rcx
    mov     [rsp+48h],rax
    mov     rsi,[rsp+60h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    call    fn1
    mov     [rsp+7Fh],al
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

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_fmt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_str
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdx
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn0
    mov     [rsp+20h],rax
    cmp     qword ptr [rsp+20h],0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+50h]
    lea     rdx,[rdx+8]
    mov     [rsp],rdx
    mov     rdi,[rsp]
    call    fn1
    jmp     L3
L2:
    mov     byte ptr [rsp+5Fh],0
    jmp     L6
L3:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     byte ptr [rsp+5Fh],1
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L5:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    movzx   eax,byte ptr [rsp+5Fh]
    add     rsp,68h
    ret
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L4
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn} as std::ops::FnOnce<()>>::call_once - shim(fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn})
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    call    fn0
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
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

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>
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

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
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
    mov     qword ptr [rsp+38h],8
    jmp     L3
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L8:
    jmp     L3
L9:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L7
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

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}> [hint]
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

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}
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

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,168h
    mov     [rsp+108h],rdi
    mov     [rsp+110h],rsi
    mov     rax,[rsp+110h]
    mov     rax,[rax]
    mov     rdx,[rsp+110h]
    mov     rdx,[rdx+8]
    mov     qword ptr [rsp],0
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+50h],0
    mov     r11,[rsp]
    mov     [rsp+20h],r11
    mov     rsi,[rsp+8]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+10h]
    mov     [rsp+30h],rdi
    mov     r8,[rsp+18h]
    mov     [rsp+38h],r8
    mov     qword ptr [rsp+58h],0
    mov     qword ptr [rsp+60h],0
    lea     r9,[rsp+20h]
    mov     [rsp+18h],r9
    mov     rdi,[rsp+18h]
    call    fn0
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFEC0h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF08h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF60h
    mov     ecx,48h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,0FFFFFFB8h
    mov     r8d,48h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+108h]
    add     rsp,168h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
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

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
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

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_all
    inc     qword ptr [jit_record]
    jns     L35
L0:
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rdx
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+58h],rcx
    mov     rdx,[rsp+58h]
    cmp     rdx,0
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L3
    mov     qword ptr [rsp+0A8h],0
    jmp     L12
L3:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    qword ptr [sym0]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    cmp     rax,0
    je      L4
    jmp     L5
    ud2
L4:
    cmp     qword ptr [rsp+58h],0
    je      L7
    jmp     L6
L5:
    lea     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    call    fn1
    mov     [rsp+66h],al
    jmp     L8
L6:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+40h],rdx
    cmp     rdx,rax
    jb      L23
    jmp     L24
L7:
    lea     rax,[k2]
    mov     [rsp+0A8h],rax
    jmp     L12
L8:
    test    byte ptr [rsp+66h],0FFh
    je      L9
    jmp     L17
L9:
    mov     rax,[rsp+58h]
    mov     [rsp+0A8h],rax
    jmp     L12
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L11:
    jmp     L1
L12:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L14:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L16:
    lea     rax,[rsp+58h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn3
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L18:
    mov     rax,[rsp+50h]
    mov     [rsp+78h],rax
    cmp     rax,0
    je      L10
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L19:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L20:
    lea     rax,[rsp+58h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn4
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L22:
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    cmp     rax,1
    je      L19
    jmp     L13
L23:
    lea     rax,[k5]
    mov     [rsp],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp]
    call    qword ptr [sym6]
    ud2
L24:
    mov     rax,[rsp+40h]
    sub     rax,[rsp+48h]
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+98h]
    imul    rcx,[rsp+48h],1
    add     rdx,rcx
    mov     [rsp+90h],rdx
    mov     [rsp+98h],rax
    jmp     L17
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L26:
    call    qword ptr [sym7]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L21
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
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
    jmp     L11
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L14
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L16
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L18
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L20
L33:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L34:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L26
L35:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_fmt
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdx
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn0
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    cmp     qword ptr [rsp+28h],0
    je      L1
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+20h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rdx
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+58h],rax
    jmp     L2
L1:
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn2
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
    ud2
L3:
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
    nop
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
    mov     qword ptr [rsp+30h],0FFFFFFFFFFFFFFFFh
    jmp     L10
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
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

fn <{closure@std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}} as std::ops::FnOnce<(std::option::Option<&mut std::option::Option<std::cell::Cell<(u64, u64)>>>,)>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    lea     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
    nop     [rax+rax]
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
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
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
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+68h]
    imul    r8,rdi,8
    mov     [rsp+48h],r8
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFF88h
    call    ryo_h_ShlW64
    mov     rax,[rsp+0B8h]
    or      rax,[rsp+58h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+68h]
    add     rdx,2
    mov     [rsp+68h],rdx
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
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+68h]
    imul    r8,rdi,8
    mov     [rsp+48h],r8
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFF88h
    call    ryo_h_ShlW64
    mov     rax,[rsp+0B8h]
    or      rax,[rsp+58h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+68h]
    add     rdx,1
    mov     [rsp+68h],rdx
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

fn core::io::error::repr::Repr::data::{closure#0}
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

fn core::io::error::repr::decode_repr::<&core::io::error::Custom, {closure@core::io::error::repr::Repr::data::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L30
L0:
    sub     rsp,0D8h
    mov     [rsp+50h],rdi
    mov     [rsp+0B8h],rsi
    mov     byte ptr [rsp+0A7h],1
    mov     rdx,[rsp+0B8h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+48h],rsi
    and     rsi,3
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF70h
    xor     edx,edx
    mov     ecx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L4
    .long   L3
    .long   L6
    .long   L5
    .long   L2
L2:
    lea     rax,[k0]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],28h
    lea     rsi,[k1]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L3:
    mov     rax,[rsp+0B8h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rsp+18h],1
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L22
L4:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B8h]
    mov     [rsp+30h],rdx
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],2
    jmp     L23
L5:
    mov     rax,[rsp+48h]
    shr     rax,20h
    mov     [rsp+3Ch],eax
    mov     edi,[rsp+3Ch]
    call    fn3
    mov     [rsp+3Ah],al
    jmp     L7
L6:
    mov     rax,[rsp+48h]
    sar     rax,20h
    mov     [rsp+3Ch],eax
    mov     edx,[rsp+3Ch]
    mov     [rsp+0C4h],edx
    mov     byte ptr [rsp+0C0h],0
    jmp     L23
L7:
    cmp     byte ptr [rsp+3Ah],0FFh
    je      L20
    jmp     L21
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L9:
    mov     rax,[rsp+30h]
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],3
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L11:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0D8h
    ret
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L13:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L15:
    jmp     L12
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L17:
    test    byte ptr [rsp+0A7h],0FFh
    je      L12
    jmp     L14
    nop     [rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L19:
    ud2
L20:
    lea     rax,[k4]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn5
    jmp     L18
L21:
    movzx   eax,byte ptr [rsp+3Ah]
    mov     [rsp+0C1h],al
    mov     byte ptr [rsp+0C0h],1
    jmp     L23
L22:
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+0B8h]
    mov     rsi,[rsp+60h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+60h]
    mov     byte ptr [rsp+0A7h],0
    mov     [rsp+28h],rdi
    mov     rdi,[rsp+28h]
    call    fn6
    mov     [rsp+30h],rax
    jmp     L8
L23:
    jmp     L10
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L16
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L9
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L11
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L13
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L15
L28:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L17
L29:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L30:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L30
L0:
    sub     rsp,0D8h
    mov     [rsp+50h],rdi
    mov     [rsp+0B8h],rsi
    mov     byte ptr [rsp+0A7h],1
    mov     rdx,[rsp+0B8h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+48h],rsi
    and     rsi,3
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF70h
    xor     edx,edx
    mov     ecx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L4
    .long   L3
    .long   L6
    .long   L5
    .long   L2
L2:
    lea     rax,[k0]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],28h
    lea     rsi,[k1]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L3:
    mov     rax,[rsp+0B8h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rsp+18h],1
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L22
L4:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B8h]
    mov     [rsp+30h],rdx
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],2
    jmp     L23
L5:
    mov     rax,[rsp+48h]
    shr     rax,20h
    mov     [rsp+3Ch],eax
    mov     edi,[rsp+3Ch]
    call    fn3
    mov     [rsp+3Ah],al
    jmp     L7
L6:
    mov     rax,[rsp+48h]
    sar     rax,20h
    mov     [rsp+3Ch],eax
    mov     edx,[rsp+3Ch]
    mov     [rsp+0C4h],edx
    mov     byte ptr [rsp+0C0h],0
    jmp     L23
L7:
    cmp     byte ptr [rsp+3Ah],0FFh
    je      L20
    jmp     L21
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L9:
    mov     rax,[rsp+30h]
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],3
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L11:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0D8h
    ret
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L13:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L15:
    jmp     L12
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L17:
    test    byte ptr [rsp+0A7h],0FFh
    je      L12
    jmp     L14
    nop     [rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L19:
    ud2
L20:
    lea     rax,[k4]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn5
    jmp     L18
L21:
    movzx   eax,byte ptr [rsp+3Ah]
    mov     [rsp+0C1h],al
    mov     byte ptr [rsp+0C0h],1
    jmp     L23
L22:
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+0B8h]
    mov     rsi,[rsp+60h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+60h]
    mov     byte ptr [rsp+0A7h],0
    mov     [rsp+28h],rdi
    mov     rdi,[rsp+28h]
    call    fn6
    mov     [rsp+30h],rax
    jmp     L8
L23:
    jmp     L10
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L16
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L9
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L11
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L13
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L15
L28:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L17
L29:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L30:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rdx
    mov     rax,[rsp+0B0h]
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+80h],0
    lea     rsi,[rsp+78h]
    mov     [rsp+60h],rsi
    lea     rdi,[k0]
    mov     [rsp+68h],rdi
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    call    qword ptr [sym1]
    mov     [rsp+77h],al
    movzx   eax,byte ptr [rsp+77h]
    mov     [rsp+98h],rax
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    cmp     qword ptr [rsp+80h],0
    setne   [rsp+0Fh]
    movzx   edx,byte ptr [rsp+0Fh]
    cmp     rdx,0
    sete    [rsp+75h]
    movzx   edi,byte ptr [rsp+75h]
    xor     dil,1
    mov     [rsp+76h],dil
    test    byte ptr [rsp+76h],0FFh
    je      L4
    jmp     L3
L2:
    mov     qword ptr [rsp+0B8h],0
    lea     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L5
L3:
    mov     rax,[rsp+80h]
    mov     [rsp+0B8h],rax
    jmp     L5
L4:
    lea     rax,[k3]
    mov     qword ptr [rsp+50h],56h
    mov     rsi,[rsp+50h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+18h],56h
    mov     r9,[rsp+18h]
    shl     r9,1
    or      r9,1
    mov     [rsp+60h],rax
    mov     [rsp+68h],r9
    lea     r10,[k5]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym6]
    ud2
L5:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
    nop
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L7:
    lea     rax,[rsp+78h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn7
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L9:
    call    qword ptr [sym8]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L6
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L8
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L7
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L9
L12:
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
    call    qword ptr [sym0]
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
    call    qword ptr [sym1]
    mov     byte ptr [rsp+27h],80h
    lea     rdi,[rsp+30h]
    movzx   esi,byte ptr [rsp+27h]
    call    qword ptr [sym2]
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
    call    qword ptr [sym3]
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64> [hint]
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
    mov     qword ptr [rsp+18h],8
    jmp     L6
L9:
    mov     rax,[rsp+8]
    mov     [rsp+10h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L11:
    jmp     L6
L12:
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    jmp     L10
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::iter
    inc     qword ptr [jit_record]
    jns     L7
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
    jns     L6
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
    mov     qword ptr [rsp+18h],1
    jmp     L5
L4:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L5:
    mov     rax,[rsp+18h]
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
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    inc     qword ptr [jit_record]
    jns     L37
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
    jns     L29
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L19
    jmp     L20
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L4:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L24
    jmp     L23
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L6:
    jmp     L11
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
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
    jns     L33
L13:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF98h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
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
    mov     qword ptr [rsp+30h],1
    jmp     L18
L17:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
L18:
    mov     rax,[rsp+30h]
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
L19:
    mov     qword ptr [rsp+48h],0
    jmp     L5
L20:
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
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L22:
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
L23:
    mov     qword ptr [rsp+38h],8
    jmp     L21
L24:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L28
    jmp     L27
    nop     [rax+rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L26:
    jmp     L21
L27:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L25
L28:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L25
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L12
L29:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L30:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L31:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L32:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L34:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L35:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L36:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L26
L37:
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

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
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

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF56h
    call    ryo_h_CttzW16
    mov     eax,[rsp+10h]
    mov     [rsp+28h],eax
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
    call    qword ptr [sym1]
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
    call    qword ptr [sym2]
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
    call    qword ptr [sym0]
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym1]
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
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jb      L5
    mov     qword ptr [rsp+0D8h],0
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
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
    call    qword ptr [sym0]
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
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF46h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+38h],eax
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
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rsp+38h],rsi
    jmp     L13
L12:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
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
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L15
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
    call    qword ptr [sym2]
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
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rsp+50h],r8
    jmp     L21
L20:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
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
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L23
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

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
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
    call    qword ptr [sym0]
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
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEF4h
    mov     edx,0FFFFFF0Eh
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+40h],eax
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
    mov     rdx,[rsp+0F8h]
    add     rdx,rax
    mov     [rsp+40h],rdx
    jmp     L21
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
    nop
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
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L23
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
    call    qword ptr [sym3]
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
    mov     rdi,[rsp+0F8h]
    add     rdi,10h
    mov     [rsp+58h],rdi
    jmp     L29
L28:
    mov     rax,[rsp+0F8h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L34
    jmp     L33
    nop     [rax]
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
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    jmp     L31
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
    call    qword ptr [sym0]
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym1]
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
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jb      L5
    mov     qword ptr [rsp+0D8h],0
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
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
    call    qword ptr [sym0]
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
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF46h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+38h],eax
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
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rsp+38h],rsi
    jmp     L13
L12:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
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
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L15
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
    call    qword ptr [sym2]
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
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rsp+50h],r8
    jmp     L21
L20:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L26
    jmp     L25
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
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L23
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}> [hint]
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
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L11
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
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
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L7
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
    xchg    ax,ax
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
    mov     qword ptr [rsp+30h],8
    jmp     L11
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    xchg    ax,ax
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L15
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
    mov     rsi,[rsp+88h]
    add     rsi,1
    mov     [rsp+38h],rsi
    jmp     L7
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
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L9
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
    nop     [rax+rax]
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
    mov     qword ptr [rsp+28h],8
    jmp     L13
L16:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    jmp     L19
    xchg    ax,ax
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L18:
    jmp     L13
L19:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L17
L20:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+20h]
    imul    rcx,[rsp+10h],20h
    add     rdx,rcx
    mov     [rsp+28h],rdx
    jmp     L17
    nop     [rax]
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}> [never, cold]
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
    mov     qword ptr [rsp+40h],0
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
    nop     [rax+rax]
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
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
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L7
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
    xchg    ax,ax
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
    mov     qword ptr [rsp+30h],8
    jmp     L11
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L15
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}
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
    mov     qword ptr [rsp+20h],8
    jmp     L1
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    sub     rax,1
    mov     [rsp+48h],rax
    jmp     L3
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
    nop
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
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L11
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
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L7
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
    xchg    ax,ax
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
    mov     qword ptr [rsp+30h],8
    jmp     L11
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    xchg    ax,ax
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L15
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}> [hint]
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
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L12:
    jmp     L9
L13:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L11
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
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
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L7
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
    xchg    ax,ax
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
    mov     qword ptr [rsp+30h],8
    jmp     L11
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    xchg    ax,ax
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L15
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
    mov     rsi,[rsp+78h]
    add     rsi,1
    mov     [rsp+28h],rsi
    jmp     L7
L6:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
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
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
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
    nop     [rax+rax]
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
    mov     qword ptr [rsp+28h],8
    jmp     L13
L16:
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L18:
    jmp     L13
L19:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L17
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}> [never, cold]
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
    mov     byte ptr [rsp+37h],0
    test    byte ptr [rsp+37h],0FFh
    je      L1
    mov     r11,[sym1]
    mov     [rsp+40h],r11
    jmp     L2
L1:
    mov     qword ptr [rsp+40h],0
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
    nop     [rax+rax]
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
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
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L5
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
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L7
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
    xchg    ax,ax
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
    mov     qword ptr [rsp+30h],8
    jmp     L11
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L16:
    jmp     L11
L17:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L15
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
    jns     L30
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
    jns     L24
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L13
    jmp     L14
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L6:
    jmp     L7
L7:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
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
    mov     qword ptr [rsp+18h],1
    jmp     L12
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L12:
    mov     rax,[rsp+18h]
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
L13:
    mov     qword ptr [rsp+30h],0
    jmp     L5
L14:
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
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L16:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn2
    jmp     L23
L17:
    mov     qword ptr [rsp+20h],8
    jmp     L15
L18:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
    nop
L19:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L20:
    jmp     L15
L21:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L19
L22:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],20h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L19
L23:
    jmp     L1
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L28:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L29:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L20
L30:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
    inc     qword ptr [jit_record]
    jns     L30
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+0Fh],0
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
    jns     L24
L2:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L13
    jmp     L14
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L6:
    jmp     L7
L7:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
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
    mov     qword ptr [rsp+18h],1
    jmp     L12
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L12:
    mov     rax,[rsp+18h]
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
L13:
    mov     qword ptr [rsp+30h],0
    jmp     L5
L14:
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
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L16:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    qword ptr [sym2]
    jmp     L23
L17:
    mov     qword ptr [rsp+20h],8
    jmp     L15
L18:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
L19:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L20:
    jmp     L15
L21:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L19
L22:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L19
L23:
    jmp     L1
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L28:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L29:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L20
L30:
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
    call    qword ptr [sym0]
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
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
    call    qword ptr [sym1]
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
    call    qword ptr [sym2]
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    qword ptr [sym3]
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
    call    qword ptr [sym4]
    mov     byte ptr [rsp+27h],0FFh
    lea     rdi,[rsp+30h]
    movzx   esi,byte ptr [rsp+27h]
    call    qword ptr [sym5]
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
    call    qword ptr [sym6]
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    qword ptr [sym7]
    mov     [rsp+3Ch],eax
    mov     eax,[rsp+3Ch]
    mov     [rsp+5Eh],ax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF64h
    mov     edx,0FFFFFFBEh
    call    ryo_h_CtlzW16
    mov     eax,[rsp+24h]
    mov     [rsp+3Ch],eax
    mov     [rsp+40h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF64h
    mov     edx,0FFFFFF9Eh
    call    ryo_h_CttzW16
    mov     eax,[rsp+24h]
    mov     [rsp+34h],eax
    mov     rdx,[rsp+40h]
    add     rdx,rax
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
    call    qword ptr [sym0]
    jmp     L9
    nop     [rax+rax]
    nop
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
    call    qword ptr [sym1]
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
    call    qword ptr [sym2]
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    qword ptr [sym3]
    mov     [rsp+4Ch],eax
    mov     eax,[rsp+4Ch]
    mov     [rsp+72h],ax
    movzx   edx,word ptr [rsp+72h]
    mov     [rsp+0CEh],dx
    jmp     L3
L10:
    movzx   eax,word ptr [rsp+74h]
    mov     [rsp+70h],ax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF24h
    mov     edx,0FFFFFF70h
    call    ryo_h_CttzW16
    mov     eax,[rsp+24h]
    mov     [rsp+2Ch],eax
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
    call    qword ptr [sym5]
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
    call    qword ptr [sym6]
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+10h]
    call    qword ptr [sym7]
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
    call    qword ptr [sym0]
    jmp     L7
    nop     [rax+rax]
    nop
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
    call    qword ptr [sym0]
    mov     [rsp+30h],eax
    jmp     L3
    nop
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
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFF9Ah
    call    ryo_h_CttzW16
    mov     eax,[rsp+0Ch]
    mov     [rsp+1Ch],eax
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
    call    qword ptr [sym0]
    jmp     L5
L4:
    jmp     L1
L5:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym1]
    mov     [rsp+2Ch],eax
    mov     eax,[rsp+2Ch]
    mov     [rsp+4Eh],ax
    movzx   edx,word ptr [rsp+4Eh]
    mov     [rsp+40h],dx
    cmp     dx,0
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
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
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFF84h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+20h],eax
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
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF00h
    mov     ecx,0FFFFFEF8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+38h]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEDCh
    mov     edx,0FFFFFEF0h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+0Ch]
    mov     [rsp+40h],eax
    mov     qword ptr [rsp+8],3Fh
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     [rsp+30h],rsi
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFED8h
    mov     ecx,0FFFFFF00h
    call    ryo_h_ShlW64
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
    call    qword ptr [sym1]
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
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
    call    qword ptr [sym2]
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
    sub     rsp,278h
    mov     [rsp+258h],rdi
    mov     [rsp+250h],rsi
    mov     [rsp+248h],rdx
    mov     [rsp+238h],rcx
    mov     [rsp+240h],r8
    mov     [rsp+237h],r9b
    mov     rax,[rsp+280h]
    mov     [rsp+220h],rax
    mov     rdx,[rsp+288h]
    mov     [rsp+228h],rdx
    lea     rdi,[rsp+90h]
    mov     rsi,[rsp+250h]
    mov     rdx,[rsp+220h]
    mov     rcx,[rsp+228h]
    mov     r8,[rsp+248h]
    movzx   r9d,byte ptr [rsp+237h]
    call    fn0
    jmp     L12
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L2:
    lea     rax,[rsp+120h]
    mov     [rsp+108h],rax
    mov     rax,[rax+10h]
    mov     [rsp+100h],rax
    cmp     rax,0
    je      L14
    jmp     L15
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L4:
    mov     rax,[rsp+118h]
    mov     [rsp+100h],rax
    mov     rdx,[rsp+258h]
    mov     [rsp+0E8h],rdx
    mov     [rsp+0F0h],rax
    mov     rsi,[rsp+240h]
    mov     rsi,[rsi+28h]
    mov     [rsp+40h],rsi
    mov     rax,[rsp+40h]
    mov     rdi,[rsp+238h]
    mov     rsi,[rsp+0E8h]
    mov     rdx,[rsp+0F0h]
    call    rax
    mov     [rsp+0F8h],rax
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L6:
    mov     rax,[rsp+258h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+168h]
    sub     rdx,rax
    mov     [rsp+168h],rdx
    mov     rsi,[rsp+258h]
    mov     rsi,[rsi+18h]
    mov     [rsp+170h],rsi
    mov     rdi,[rsp+258h]
    mov     [rsp+138h],rdi
    lea     r8,[rsp+158h]
    mov     [rsp+130h],r8
    mov     rdi,[rdi]
    mov     [rsp+20h],rdi
    mov     r9,[rsp+138h]
    mov     r9,[r9+8]
    mov     [rsp+28h],r9
    mov     r10,[rsp+138h]
    mov     r10,[r10+10h]
    mov     [rsp+30h],r10
    mov     r11,[rsp+138h]
    mov     r11,[r11+18h]
    mov     [rsp+38h],r11
    mov     r8,[r8]
    mov     [rsp],r8
    mov     rax,[rsp+130h]
    mov     rax,[rax+8]
    mov     [rsp+8],rax
    mov     rdx,[rsp+130h]
    mov     rdx,[rdx+10h]
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+130h]
    mov     rsi,[rsi+18h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+138h]
    mov     rcx,[rsp]
    mov     [rdi],rcx
    mov     r9,[rsp+138h]
    mov     rcx,[rsp+8]
    mov     [r9+8],rcx
    mov     r10,[rsp+138h]
    mov     rcx,[rsp+10h]
    mov     [r10+10h],rcx
    mov     r11,[rsp+138h]
    mov     rcx,[rsp+18h]
    mov     [r11+18h],rcx
    mov     r8,[rsp+130h]
    mov     rcx,[rsp+20h]
    mov     [r8],rcx
    mov     rax,[rsp+130h]
    mov     rcx,[rsp+28h]
    mov     [rax+8],rcx
    mov     rdx,[rsp+130h]
    mov     rcx,[rsp+30h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+130h]
    mov     rcx,[rsp+38h]
    mov     [rsi+18h],rcx
    jmp     L17
L7:
    lea     rax,[rsp+158h]
    mov     [rsp+0F0h],rax
    mov     rdi,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    call    fn1
    mov     [rsp+180h],rax
    jmp     L16
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L9:
    mov     rax,[rsp+260h]
    mov     rdx,[rsp+268h]
    add     rsp,278h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L11:
    lea     rax,[rsp+140h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    call    fn2
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFF08h
    call    ryo_h_Resume
    ud2
L12:
    cmp     qword ptr [rsp+90h],0
    jne     L13
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+60h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+0C0h],rcx
    mov     qword ptr [rsp+0B0h],0
    mov     rcx,[rsp+0C0h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rdx
    mov     qword ptr [rsp+98h],1
    cmp     qword ptr [rsp+98h],1
    sete    [rsp+97h]
    mov     rcx,[rsp+0A8h]
    mov     [rsp+68h],rcx
    mov     rcx,[rsp+68h]
    mov     [rsp+0E0h],rcx
    mov     [rsp+0D8h],rdx
    mov     qword ptr [rsp+0D0h],0
    mov     rcx,[rsp+0E0h]
    mov     [rsp+0C8h],rcx
    mov     rcx,[rsp+0C8h]
    mov     [rsp+0B8h],rcx
    mov     rcx,[rsp+0B8h]
    mov     [rsp+118h],rcx
    mov     [rsp+110h],rdx
    mov     qword ptr [rsp+108h],0
    mov     rcx,[rsp+118h]
    mov     [rsp+100h],rcx
    mov     [rsp+0F8h],rdx
    mov     qword ptr [rsp+0F0h],1
    cmp     qword ptr [rsp+0F0h],1
    sete    [rsp+0DFh]
    mov     rcx,[rsp+100h]
    mov     [rsp+0E8h],rcx
    mov     rcx,[rsp+0E8h]
    mov     [rsp+268h],rcx
    mov     [rsp+260h],rdx
    jmp     L8
L13:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    mov     rsi,[rsp+0A0h]
    mov     rdi,[rsp+0A8h]
    mov     r8,[rsp+250h]
    mov     r9,[rsp+220h]
    mov     rcx,[rsp+228h]
    mov     [rsp+68h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+0A0h],r9
    mov     r10,[rsp+68h]
    mov     [rsp+0A8h],r10
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rdx
    mov     [rsp+0C0h],rsi
    mov     [rsp+0C8h],rdi
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rax,[rsp+258h]
    mov     rax,[rax]
    mov     [rsp+118h],rax
    mov     [rsp+120h],rax
    mov     rdx,[rsp+118h]
    mov     [rsp+138h],rdx
    mov     rsi,[rsp+118h]
    mov     [rsp+128h],rsi
    mov     rdi,[rsp+118h]
    mov     [rsp+110h],rdi
    lea     rdi,[rsp+100h]
    mov     rsi,[rsp+110h]
    call    qword ptr [sym3]
    mov     rax,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    lea     rdi,[rsp+30h]
    call    qword ptr [sym4]
    mov     [rsp+12Ch],eax
    mov     eax,[rsp+12Ch]
    mov     [rsp+130h],ax
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+132h]
    mov     rdx,[rsp+258h]
    mov     rdx,[rdx+18h]
    mov     [rsp+218h],ax
    mov     qword ptr [rsp+208h],0
    mov     rdi,[rsp+118h]
    mov     [rsp+120h],rdi
    mov     r8,[rsp+208h]
    mov     [rsp+128h],r8
    mov     [rsp+130h],rdx
    mov     r9,[rsp+218h]
    mov     [rsp+138h],r9
    jmp     L1
L14:
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L15:
    mov     rdi,[rsp+108h]
    call    fn6
    mov     [rsp+110h],rax
    mov     [rsp+118h],rdx
    mov     rax,[rsp+108h]
    mov     rax,[rax+10h]
    sub     rax,1
    mov     [rsp+30h],rax
    mov     rdx,[rsp+108h]
    mov     rcx,[rsp+30h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+110h]
    mov     [rsp+1F8h],rsi
    cmp     rsi,0
    je      L5
    jmp     L3
L16:
    mov     rax,[rsp+158h]
    imul    rcx,[rsp+180h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+0C7h],al
    mov     rdx,[rsp+0F8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+0F6h],dl
    movzx   esi,byte ptr [rsp+0F6h]
    mov     [rsp+0F7h],sil
    mov     rdi,[rsp+180h]
    sub     rdi,10h
    mov     r8,[rsp+160h]
    and     rdi,r8
    add     rdi,10h
    mov     [rsp+0E8h],rdi
    mov     r9,[rsp+158h]
    imul    rcx,[rsp+180h],1
    add     r9,rcx
    movzx   ecx,byte ptr [rsp+0F7h]
    mov     [r9],cl
    mov     r10,[rsp+158h]
    imul    rcx,[rsp+0E8h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+0F7h]
    mov     [r10],cl
    mov     r11,[rsp+220h]
    mov     [rsp+1E0h],r11
    mov     rax,[rsp+258h]
    mov     rax,[rax]
    mov     rdx,[rsp+100h]
    add     rdx,1
    imul    rdx,r11
    mov     qword ptr [rsp+40h],0
    mov     r8,[rsp+40h]
    sub     r8,rdx
    imul    rcx,r8,1
    add     rax,rcx
    mov     [rsp+0F0h],rax
    mov     rdi,[rsp+158h]
    mov     r9,[rsp+180h]
    add     r9,1
    imul    r9,r11
    mov     qword ptr [rsp+40h],0
    mov     rsi,[rsp+40h]
    sub     rsi,r9
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+0E8h],rdi
    imul    rdx,r11,1
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFDD0h
    call    ryo_h_Memcpy
    jmp     L1
L17:
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+140h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    call    fn8
    jmp     L8
    nop     [rax+rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L19:
    call    qword ptr [sym9]
    ud2
    lea     rdi,[rsp+270h]
    mov     rsi,rax
    mov     edx,0FFFFFF08h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+270h]
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
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+10h],7
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF40h
    call    ryo_h_DivUW64
    cmp     qword ptr [rsp+60h],1
    jbe     L27
    jmp     L28
    nop     [rax+rax]
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
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF44h
    mov     edx,0FFFFFF68h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+14h]
    mov     [rsp+34h],eax
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF40h
    mov     ecx,0FFFFFF38h
    call    ryo_h_ShrUW64
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
    nop     [rax+rax]
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

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
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

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
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

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
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

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
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
    sub     rsp,568h
    mov     qword ptr [rsp+28h],50910h
    mov     rdi,[rsp+28h]
    call    fn0
    mov     [rsp+558h],rax
    lea     rdi,[rsp+528h]
    call    fn1
    mov     qword ptr [rsp+520h],1
    mov     qword ptr [rsp+500h],0
    mov     rsi,[rsp+558h]
    mov     [rsp+508h],rsi
    mov     rdi,[rsp+500h]
    mov     rsi,[rsp+508h]
    call    fn2
    mov     [rsp+510h],rax
    mov     [rsp+518h],rdx
    mov     rax,[rsp+510h]
    mov     rcx,[rsp+518h]
    mov     [rsp+4F8h],rcx
    mov     [rsp+4F0h],rax
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    lea     rax,[rsp+4F0h]
    mov     [rsp+4D8h],rax
    mov     rdi,[rsp+4D8h]
    call    fn3
    mov     [rsp+4E0h],rax
    mov     [rsp+4E8h],rdx
    mov     rax,[rsp+4E0h]
    mov     [rsp+4D0h],rax
    cmp     rax,0
    je      L4
    jmp     L3
    ud2
L3:
    mov     rax,[rsp+4E8h]
    mov     [rsp+4C8h],rax
    mov     rdx,[rsp+520h]
    mov     [rsp+4B0h],rdx
    mov     rsi,5851F42D4C957F2Dh
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+4B0h]
    mov     rsi,[rsp+28h]
    call    fn4
    mov     [rsp+4B8h],rax
    jmp     L5
L4:
    mov     qword ptr [rsp+458h],0
    mov     qword ptr [rsp+450h],0
    mov     dword ptr [rsp+2Ch],14h
    mov     edi,[rsp+2Ch]
    mov     [rsp+3F4h],edi
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
    mov     rdi,[rsp+4B8h]
    mov     rsi,[rsp+28h]
    call    fn7
    mov     [rsp+4C0h],rax
    mov     rax,[rsp+4C0h]
    mov     [rsp+520h],rax
    lea     rdx,[rsp+528h]
    mov     [rsp+488h],rdx
    mov     [rsp+478h],rax
    mov     dword ptr [rsp+2Ch],2Ch
    mov     edi,[rsp+2Ch]
    mov     [rsp+474h],edi
    cmp     edi,40h
    jb      L6
    lea     r9,[k8]
    mov     [rsp+28h],r9
    mov     rdi,[rsp+28h]
    call    qword ptr [sym9]
    ud2
L6:
    mov     rax,[rsp+478h]
    shr     rax,2Ch
    mov     [rsp+480h],rax
    lea     rdi,[rsp+490h]
    mov     rsi,[rsp+488h]
    mov     rdx,[rsp+480h]
    call    fn10
    mov     rax,[rsp+490h]
    mov     rcx,[rsp+498h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdx,[rsp+4A0h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],0
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn11
    mov     [rsp+4A8h],rax
    mov     rax,[rsp+4A8h]
    mov     rax,[rax]
    add     rax,[rsp+4C8h]
    mov     [rsp+460h],rax
    setb    cl
    mov     [rsp+468h],cl
    test    byte ptr [rsp+468h],0FFh
    je      L7
    lea     rsi,[k12]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+28h]
    call    qword ptr [sym13]
    ud2
L7:
    mov     rax,[rsp+4A8h]
    mov     rcx,[rsp+460h]
    mov     [rax],rcx
    jmp     L1
L8:
    mov     qword ptr [rsp+28h],1
    mov     rdx,[rsp+28h]
    shl     rdx,14h
    mov     qword ptr [rsp+400h],0
    mov     [rsp+408h],rdx
    mov     qword ptr [rsp+28h],2
    lea     rdi,[rsp+410h]
    mov     rsi,[rsp+400h]
    mov     rdx,[rsp+408h]
    mov     rcx,[rsp+28h]
    call    fn14
    mov     rax,[rsp+410h]
    mov     rcx,[rsp+418h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rdx,[rsp+420h]
    mov     rcx,[rsp+428h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+430h]
    lea     rsi,[rsp+10h]
    call    fn15
    mov     rax,[rsp+430h]
    mov     [rsp+3D0h],rax
    mov     rdx,[rsp+438h]
    mov     [rsp+3D8h],rdx
    mov     rsi,[rsp+440h]
    mov     [rsp+3E0h],rsi
    mov     rdi,[rsp+448h]
    mov     [rsp+3E8h],rdi
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L10:
    lea     rax,[rsp+3D0h]
    mov     [rsp+3B8h],rax
    mov     rdi,[rsp+3B8h]
    call    fn16
    mov     [rsp+3C0h],rax
    mov     [rsp+3C8h],rdx
    mov     rax,[rsp+3C0h]
    mov     [rsp+3B0h],rax
    cmp     rax,0
    je      L11
    mov     rsi,[rsp+3C8h]
    mov     [rsp+3A8h],rsi
    lea     rdi,[rsp+528h]
    mov     [rsp+398h],rdi
    lea     r8,[rsp+3A8h]
    mov     [rsp+390h],r8
    mov     rdi,[rsp+398h]
    mov     rsi,[rsp+390h]
    call    fn17
    mov     [rsp+3A0h],rax
    jmp     L12
L11:
    lea     rax,[rsp+528h]
    mov     [rsp+348h],rax
    mov     rdi,[rsp+348h]
    call    fn18
    mov     [rsp+350h],rax
    jmp     L14
L12:
    cmp     qword ptr [rsp+3A0h],0
    je      L9
    mov     rdx,[rsp+3A0h]
    mov     [rsp+380h],rdx
    mov     qword ptr [rsp+28h],1
    mov     rdi,[rsp+458h]
    add     rdi,[rsp+28h]
    mov     [rsp+370h],rdi
    setb    cl
    mov     [rsp+378h],cl
    test    byte ptr [rsp+378h],0FFh
    je      L13
    lea     r9,[k19]
    mov     [rsp+28h],r9
    mov     rdi,[rsp+28h]
    call    qword ptr [sym20]
    ud2
L13:
    mov     rax,[rsp+370h]
    mov     [rsp+458h],rax
    mov     rdx,[rsp+450h]
    mov     [rsp+360h],rdx
    mov     rsi,[rsp+380h]
    mov     rsi,[rsi]
    mov     [rsp+358h],rsi
    mov     rdi,[rsp+360h]
    mov     rsi,[rsp+358h]
    call    fn21
    mov     [rsp+368h],rax
    mov     rax,[rsp+368h]
    mov     [rsp+450h],rax
    jmp     L9
L14:
    lea     rax,[rsp+528h]
    mov     [rsp+340h],rax
    mov     rdi,[rsp+340h]
    call    fn22
    lea     rax,[rsp+528h]
    mov     [rsp+308h],rax
    lea     rdi,[rsp+310h]
    mov     rsi,[rsp+308h]
    call    fn23
    mov     rax,[rsp+310h]
    mov     rcx,[rsp+318h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+320h]
    mov     rcx,[rsp+328h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+330h]
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp],0
    lea     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn24
    mov     [rsp+338h],rax
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
    lea     rax,[rsp+528h]
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
    lea     rdx,[rsp+350h]
    lea     rsi,[rsp+458h]
    lea     rdi,[rsp+450h]
    lea     r8,[rsp+338h]
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
    lea     rax,[rsp+528h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn51
    add     rsp,568h
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
    lea     rax,[rsp+528h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn53
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L26:
    call    qword ptr [sym54]
    ud2
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L23
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L21
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
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

fn std::char::encode_utf8_raw [hint]
    inc     qword ptr [jit_record]
    jns     L16
L0:
    sub     rsp,88h
    mov     [rsp+6Ch],edi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    cmp     dword ptr [rsp+6Ch],80h
    jb      L10
    jmp     L7
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    lea     rax,[k0]
    mov     [rsp+18h],rax
    mov     edi,[rsp+6Ch]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp+18h]
    call    fn1
    ud2
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     [rsp+30h],rax
    mov     edi,[rsp+6Ch]
    mov     rsi,[rsp+30h]
    call    fn2
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+40h],rdx
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    cmp     rax,rdx
    jb      L1
    jmp     L3
L7:
    cmp     dword ptr [rsp+6Ch],800h
    jb      L9
    cmp     dword ptr [rsp+6Ch],10000h
    jb      L8
    mov     qword ptr [rsp+50h],4
    jmp     L5
L8:
    mov     qword ptr [rsp+50h],3
    jmp     L5
L9:
    mov     qword ptr [rsp+50h],2
    jmp     L5
L10:
    mov     qword ptr [rsp+50h],1
    jmp     L5
L11:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],1
    lea     rdi,[k3]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+50h]
    mov     r8,[rsp+8]
    call    fn4
L12:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+50h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
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

fn std::char::encode_utf8_raw::do_panic::runtime [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0E8h
    mov     [rsp+0DCh],edi
    mov     [rsp+0D0h],rsi
    mov     [rsp+0C8h],rdx
    mov     [rsp+8],rcx
    lea     rax,[rsp+0D0h]
    lea     rdx,[rsp+0DCh]
    lea     rsi,[rsp+0C8h]
    mov     rdi,[sym0]
    mov     [rsp+58h],rdi
    mov     rcx,[rsp+58h]
    mov     [rsp+68h],rcx
    mov     r8,[sym1]
    mov     [rsp+48h],r8
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     r9,[sym2]
    mov     [rsp+38h],r9
    mov     rcx,[rsp+38h]
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+68h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     rcx,[rsp+58h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rdx
    mov     rcx,[rsp+48h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rsi
    lea     r10,[rsp+70h]
    lea     r11,[k3]
    mov     [rsp+0A0h],r11
    mov     [rsp+0A8h],r10
    mov     rdi,[rsp+8]
    mov     [rsp],rdi
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    ud2
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::char::encode_utf8_raw_unchecked [hint]
    inc     qword ptr [jit_record]
    jns     L16
L0:
    sub     rsp,38h
    mov     [rsp+2Ch],edi
    mov     [rsp+20h],rsi
    cmp     dword ptr [rsp+2Ch],80h
    jb      L11
    jmp     L8
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    movzx   eax,byte ptr [rsp+16h]
    or      al,0C0h
    mov     [rsp],al
    mov     rdx,[rsp+20h]
    movzx   ecx,byte ptr [rsp]
    mov     [rdx],cl
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+20h]
    imul    rcx,[rsp],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+17h]
    mov     [rdi],cl
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    cmp     qword ptr [rsp+18h],3
    jne     L5
    movzx   edx,byte ptr [rsp+15h]
    or      dl,0E0h
    mov     [rsp],dl
    mov     rsi,[rsp+20h]
    movzx   ecx,byte ptr [rsp]
    mov     [rsi],cl
    mov     qword ptr [rsp],1
    mov     r8,[rsp+20h]
    imul    rcx,[rsp],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+16h]
    mov     [r8],cl
    mov     qword ptr [rsp],2
    mov     r10,[rsp+20h]
    imul    rcx,[rsp],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+17h]
    mov     [r10],cl
    jmp     L6
L5:
    mov     rax,[rsp+20h]
    movzx   ecx,byte ptr [rsp+14h]
    mov     [rax],cl
    mov     qword ptr [rsp],1
    mov     rsi,[rsp+20h]
    imul    rcx,[rsp],1
    add     rsi,rcx
    movzx   ecx,byte ptr [rsp+15h]
    mov     [rsi],cl
    mov     qword ptr [rsp],2
    mov     r8,[rsp+20h]
    imul    rcx,[rsp],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+16h]
    mov     [r8],cl
    mov     qword ptr [rsp],3
    mov     r10,[rsp+20h]
    imul    rcx,[rsp],1
    add     r10,rcx
    movzx   ecx,byte ptr [rsp+17h]
    mov     [r10],cl
    jmp     L6
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L7:
    add     rsp,38h
    ret
L8:
    cmp     dword ptr [rsp+2Ch],800h
    jb      L10
    cmp     dword ptr [rsp+2Ch],10000h
    jb      L9
    mov     qword ptr [rsp+18h],4
    jmp     L12
L9:
    mov     qword ptr [rsp+18h],3
    jmp     L12
L10:
    mov     qword ptr [rsp+18h],2
    jmp     L12
L11:
    mov     qword ptr [rsp+18h],1
    mov     edx,[rsp+2Ch]
    mov     [rsp],dl
    mov     rsi,[rsp+20h]
    movzx   ecx,byte ptr [rsp]
    mov     [rsi],cl
    jmp     L6
L12:
    mov     eax,[rsp+2Ch]
    and     eax,3Fh
    mov     [rsp+16h],al
    movzx   edx,byte ptr [rsp+16h]
    or      dl,80h
    mov     [rsp+17h],dl
    mov     esi,[rsp+2Ch]
    shr     esi,6
    and     esi,3Fh
    mov     [rsp+15h],sil
    movzx   edi,byte ptr [rsp+15h]
    or      dil,80h
    mov     [rsp+16h],dil
    mov     r8d,[rsp+2Ch]
    shr     r8d,0Ch
    and     r8d,3Fh
    mov     [rsp+14h],r8b
    movzx   r9d,byte ptr [rsp+14h]
    or      r9b,80h
    mov     [rsp+15h],r9b
    mov     r10d,[rsp+2Ch]
    shr     r10d,12h
    and     r10d,3Fh
    mov     [rsp+13h],r10b
    movzx   r11d,byte ptr [rsp+13h]
    or      r11b,0F0h
    mov     [rsp+14h],r11b
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    cmp     rax,2
    je      L1
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
    jmp     L7
L16:
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

fn std::collections::HashMap::<std::string::String, usize>::entry [hint]
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

fn std::collections::HashMap::<std::string::String, usize>::len
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

fn std::collections::HashMap::<std::string::String, usize>::new [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0A8h
    mov     [rsp+68h],rdi
    lea     rax,[k0]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    mov     ecx,20h
    call    ryo_h_Const
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+50h],rcx
    mov     rdx,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rdi
    mov     [rsp+88h],r8
    mov     [rsp+90h],rax
    mov     r9,[rsp+50h]
    mov     [rsp+98h],r9
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD0h
    mov     r8d,30h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+68h]
    add     rsp,0A8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64>::entry [hint]
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

fn std::collections::HashMap::<u64, u64>::get::<u64> [hint]
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

fn std::collections::HashMap::<u64, u64>::len
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

fn std::collections::HashMap::<u64, u64>::new [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0A8h
    mov     [rsp+68h],rdi
    lea     rax,[k0]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    mov     ecx,20h
    call    ryo_h_Const
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+50h],rcx
    mov     rdx,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rdi
    mov     [rsp+88h],r8
    mov     [rsp+90h],rax
    mov     r9,[rsp+50h]
    mov     [rsp+98h],r9
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD0h
    mov     r8d,30h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+68h]
    add     rsp,0A8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::collections::HashMap::<u64, u64>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}> [hint]
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

fn std::collections::HashMap::<u64, u64>::values
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
    mov     qword ptr [rsp+0C8h],8
    jmp     L12
L15:
    mov     rax,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L17:
    jmp     L12
L18:
    mov     rax,[rsp+0C0h]
    mov     [rsp+0C8h],rax
    jmp     L16
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
    mov     qword ptr [rsp+68h],8
    jmp     L21
L24:
    mov     rax,[rsp+78h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L28
    jmp     L27
    nop     [rax+rax]
    nop
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L26:
    jmp     L21
L27:
    mov     rax,[rsp+60h]
    mov     [rsp+68h],rax
    jmp     L25
L28:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+20h],20h
    add     rdx,rcx
    mov     [rsp+68h],rdx
    jmp     L25
    nop     [rax]
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
    mov     qword ptr [rsp+40h],8
    jmp     L12
L15:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L17:
    jmp     L12
L18:
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L16
L19:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L16
    nop     [rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L21:
    mov     rax,[rsp+50h]
    lea     rax,[rax+8]
    mov     [rsp+0A8h],rax
    jmp     L3
L22:
    mov     qword ptr [rsp+50h],8
    jmp     L20
L23:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L27
    jmp     L26
    nop     [rax+rax]
    nop
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L25:
    jmp     L20
L26:
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L24
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

fn std::fmt::Arguments::<'_>::as_statically_known_str [hint]
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     rax,[rsp+78h]
    mov     rax,[rax+8]
    mov     [rsp+68h],rax
    and     rax,1
    mov     [rsp+60h],rax
    cmp     rax,1
    je      L5
    jmp     L6
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    test    byte ptr [rsp+6Fh],0FFh
    je      L3
    jmp     L4
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L4:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L5:
    mov     rax,[rsp+78h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+68h]
    shr     rdx,1
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L10
    jmp     L9
L6:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L8:
    cmp     qword ptr [rsp+80h],0
    setne   [rsp+1Fh]
    movzx   edx,byte ptr [rsp+1Fh]
    cmp     rdx,1
    sete    [rsp+6Eh]
    movzx   edi,byte ptr [rsp+6Eh]
    mov     [rsp],dil
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L1
L9:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],1
    lea     rdi,[k3]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+8]
    call    fn4
L10:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+30h]
    mov     [rsp+48h],rdx
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
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
    jmp     L8
L13:
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

fn std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    call    qword ptr [sym0]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    mov     rcx,[rsp+8]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    call    qword ptr [sym0]
    mov     [rsp],rax
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn1
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hash::RandomState::new::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+38h],rdi
    mov     rax,[rsp+38h]
    mov     [rsp+20h],rax
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+20h]
    mov     rdx,[rdx+8]
    mov     [rsp+28h],rdx
    add     rax,1
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFC8h
    call    ryo_h_StoreW128
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+28h]
    mov     [rsp+48h],rdx
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
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

fn std::hint::unreachable_unchecked::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+10h],rdi
    lea     rax,[k0]
    mov     qword ptr [rsp+68h],0C7h
    mov     rsi,[rsp+68h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+20h],0C7h
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

fn std::intrinsics::is_val_statically_known::<bool>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+0Eh],dil
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
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
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFECh
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW32
    mov     eax,[rsp+2Ch]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],3Fh
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFF0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_ShlW64
    mov     rax,[rsp+40h]
    shr     rax,1
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFFC0h
    call    ryo_h_ShrUW64
    mov     rax,[rsp+8]
    or      rax,[rsp]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
    nop     [rax+rax]
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

fn std::io::Error::is_interrupted [hint]
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn0
    jmp     L9
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L2:
    ud2
L3:
    mov     rax,[rsp+30h]
    movzx   eax,byte ptr [rax+10h]
    cmp     rax,23h
    sete    [rsp+7Fh]
    jmp     L7
L4:
    movzx   eax,byte ptr [rsp+29h]
    cmp     rax,23h
    sete    [rsp+7Fh]
    jmp     L7
L5:
    mov     rax,[rsp+30h]
    movzx   eax,byte ptr [rax+20h]
    cmp     rax,23h
    sete    [rsp+7Fh]
    jmp     L7
L6:
    mov     eax,[rsp+2Ch]
    mov     [rsp+24h],eax
    call    qword ptr [sym1]
    mov     [rsp+18h],rax
    jmp     L11
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L8:
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
L9:
    movzx   eax,byte ptr [rsp+28h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L10]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L10:
    .long   L6
    .long   L4
    .long   L3
    .long   L5
    .long   L1
L11:
    mov     rax,[rsp+18h]
    mov     rax,[rax+10h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     edi,[rsp+24h]
    call    rax
    mov     [rsp+7Fh],al
    jmp     L7
L12:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L13:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::io::ErrorKind::from_prim [hint]
    inc     qword ptr [jit_record]
    jns     L46
L0:
    sub     rsp,178h
    mov     [rsp+168h],edi
    cmp     dword ptr [rsp+168h],0
    jne     L1
    mov     byte ptr [rsp+16Fh],0
    jmp     L45
L1:
    cmp     dword ptr [rsp+168h],1
    jne     L2
    mov     byte ptr [rsp+16Fh],1
    jmp     L45
L2:
    cmp     dword ptr [rsp+168h],2
    jne     L3
    mov     byte ptr [rsp+16Fh],2
    jmp     L45
L3:
    cmp     dword ptr [rsp+168h],3
    jne     L4
    mov     byte ptr [rsp+16Fh],3
    jmp     L45
L4:
    cmp     dword ptr [rsp+168h],4
    jne     L5
    mov     byte ptr [rsp+16Fh],4
    jmp     L45
L5:
    cmp     dword ptr [rsp+168h],5
    jne     L6
    mov     byte ptr [rsp+16Fh],5
    jmp     L45
L6:
    cmp     dword ptr [rsp+168h],6
    jne     L7
    mov     byte ptr [rsp+16Fh],6
    jmp     L45
L7:
    cmp     dword ptr [rsp+168h],7
    jne     L8
    mov     byte ptr [rsp+16Fh],7
    jmp     L45
L8:
    cmp     dword ptr [rsp+168h],8
    jne     L9
    mov     byte ptr [rsp+16Fh],8
    jmp     L45
L9:
    cmp     dword ptr [rsp+168h],9
    jne     L10
    mov     byte ptr [rsp+16Fh],9
    jmp     L45
L10:
    cmp     dword ptr [rsp+168h],0Ah
    jne     L11
    mov     byte ptr [rsp+16Fh],0Ah
    jmp     L45
L11:
    cmp     dword ptr [rsp+168h],0Bh
    jne     L12
    mov     byte ptr [rsp+16Fh],0Bh
    jmp     L45
L12:
    cmp     dword ptr [rsp+168h],0Ch
    jne     L13
    mov     byte ptr [rsp+16Fh],0Ch
    jmp     L45
L13:
    cmp     dword ptr [rsp+168h],0Dh
    jne     L14
    mov     byte ptr [rsp+16Fh],0Dh
    jmp     L45
L14:
    cmp     dword ptr [rsp+168h],0Eh
    jne     L15
    mov     byte ptr [rsp+16Fh],0Eh
    jmp     L45
L15:
    cmp     dword ptr [rsp+168h],0Fh
    jne     L16
    mov     byte ptr [rsp+16Fh],0Fh
    jmp     L45
L16:
    cmp     dword ptr [rsp+168h],10h
    jne     L17
    mov     byte ptr [rsp+16Fh],10h
    jmp     L45
L17:
    cmp     dword ptr [rsp+168h],11h
    jne     L18
    mov     byte ptr [rsp+16Fh],11h
    jmp     L45
L18:
    cmp     dword ptr [rsp+168h],12h
    jne     L19
    mov     byte ptr [rsp+16Fh],12h
    jmp     L45
L19:
    cmp     dword ptr [rsp+168h],13h
    jne     L20
    mov     byte ptr [rsp+16Fh],13h
    jmp     L45
L20:
    cmp     dword ptr [rsp+168h],14h
    jne     L21
    mov     byte ptr [rsp+16Fh],14h
    jmp     L45
L21:
    cmp     dword ptr [rsp+168h],15h
    jne     L22
    mov     byte ptr [rsp+16Fh],15h
    jmp     L45
L22:
    cmp     dword ptr [rsp+168h],16h
    jne     L23
    mov     byte ptr [rsp+16Fh],16h
    jmp     L45
L23:
    cmp     dword ptr [rsp+168h],17h
    jne     L24
    mov     byte ptr [rsp+16Fh],17h
    jmp     L45
L24:
    cmp     dword ptr [rsp+168h],18h
    jne     L25
    mov     byte ptr [rsp+16Fh],18h
    jmp     L45
L25:
    cmp     dword ptr [rsp+168h],19h
    jne     L26
    mov     byte ptr [rsp+16Fh],19h
    jmp     L45
L26:
    cmp     dword ptr [rsp+168h],1Ah
    jne     L27
    mov     byte ptr [rsp+16Fh],1Ah
    jmp     L45
L27:
    cmp     dword ptr [rsp+168h],1Bh
    jne     L28
    mov     byte ptr [rsp+16Fh],1Bh
    jmp     L45
L28:
    cmp     dword ptr [rsp+168h],1Ch
    jne     L29
    mov     byte ptr [rsp+16Fh],1Ch
    jmp     L45
L29:
    cmp     dword ptr [rsp+168h],1Dh
    jne     L30
    mov     byte ptr [rsp+16Fh],1Dh
    jmp     L45
L30:
    cmp     dword ptr [rsp+168h],1Eh
    jne     L31
    mov     byte ptr [rsp+16Fh],1Eh
    jmp     L45
L31:
    cmp     dword ptr [rsp+168h],1Fh
    jne     L32
    mov     byte ptr [rsp+16Fh],1Fh
    jmp     L45
L32:
    cmp     dword ptr [rsp+168h],20h
    jne     L33
    mov     byte ptr [rsp+16Fh],20h
    jmp     L45
L33:
    cmp     dword ptr [rsp+168h],21h
    jne     L34
    mov     byte ptr [rsp+16Fh],21h
    jmp     L45
L34:
    cmp     dword ptr [rsp+168h],22h
    jne     L35
    mov     byte ptr [rsp+16Fh],22h
    jmp     L45
L35:
    cmp     dword ptr [rsp+168h],23h
    jne     L36
    mov     byte ptr [rsp+16Fh],23h
    jmp     L45
L36:
    cmp     dword ptr [rsp+168h],2Ah
    jne     L37
    mov     byte ptr [rsp+16Fh],2Ah
    jmp     L45
L37:
    cmp     dword ptr [rsp+168h],25h
    jne     L38
    mov     byte ptr [rsp+16Fh],25h
    jmp     L45
L38:
    cmp     dword ptr [rsp+168h],24h
    jne     L39
    mov     byte ptr [rsp+16Fh],24h
    jmp     L45
L39:
    cmp     dword ptr [rsp+168h],26h
    jne     L40
    mov     byte ptr [rsp+16Fh],26h
    jmp     L45
L40:
    cmp     dword ptr [rsp+168h],27h
    jne     L41
    mov     byte ptr [rsp+16Fh],27h
    jmp     L45
L41:
    cmp     dword ptr [rsp+168h],28h
    jne     L42
    mov     byte ptr [rsp+16Fh],28h
    jmp     L45
L42:
    cmp     dword ptr [rsp+168h],29h
    jne     L43
    mov     byte ptr [rsp+16Fh],29h
    jmp     L45
L43:
    cmp     dword ptr [rsp+168h],2Bh
    jne     L44
    mov     byte ptr [rsp+16Fh],2Bh
    jmp     L45
L44:
    mov     byte ptr [rsp+16Fh],0FFh
L45:
    movzx   eax,byte ptr [rsp+16Fh]
    add     rsp,178h
    ret
L46:
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
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    lea     rdx,[k2]
    mov     [rsp],rdx
    mov     rdi,[rsp]
    call    qword ptr [sym3]
    ud2
L8:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+10h],0
    jbe     L9
    mov     rdx,[rsp+20h]
    add     rdx,1
    mov     [rsp+58h],rdx
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
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    lea     rdx,[k2]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+8]
    call    qword ptr [sym3]
    ud2
L8:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+10h],0
    jbe     L9
    mov     rdx,[rsp+20h]
    add     rdx,1
    mov     [rsp+58h],rdx
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

fn std::ptr::drop_glue::<core::io::error::CustomOwner> - shim(Some(core::io::error::CustomOwner))
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

fn std::ptr::drop_glue::<core::io::error::ErrorData<core::io::error::CustomOwner>> - shim(Some(core::io::error::ErrorData<core::io::error::CustomOwner>))
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L1:
    .long   L2
    .long   L2
    .long   L2
    .long   L4
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L3:
    add     rsp,28h
    ret
L4:
    mov     rax,[rsp+18h]
    lea     rax,[rax+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    jmp     L2
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<core::io::error::repr::Repr> - shim(Some(core::io::error::repr::Repr))
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

fn std::ptr::drop_glue::<core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>> - shim(Some(core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    lea     rax,[rax+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::RandomState>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize>> - shim(Some(std::collections::HashMap<std::string::String, usize>))
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

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64>> - shim(Some(std::collections::HashMap<u64, u64>))
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

fn std::ptr::drop_glue::<std::io::Error> - shim(Some(std::io::Error))
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

fn std::ptr::drop_glue::<std::result::Result<(), std::io::Error>> - shim(Some(std::result::Result<(), std::io::Error>))
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp],rax
    cmp     rax,0
    jne     L3
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L2:
    add     rsp,28h
    ret
L3:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
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

fn std::ptr::replace::precondition_check [hint]
    inc     qword ptr [jit_record]
    jns     L19
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+8Fh],dl
    mov     [rsp+18h],rcx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+90h]
    call    fn0
    mov     [rsp+6Eh],al
    jmp     L11
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    lea     rax,[k1]
    mov     qword ptr [rsp+80h],0DDh
    mov     rsi,[rsp+80h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+28h],0DDh
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
    call    qword ptr [sym3]
    ud2
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L6:
    test    byte ptr [rsp+8Fh],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L8:
    jmp     L3
L9:
    jmp     L1
L10:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+6Dh]
    movzx   esi,byte ptr [rsp+6Dh]
    xor     sil,1
    mov     [rsp+6Fh],sil
    test    byte ptr [rsp+6Fh],0FFh
    je      L3
    jmp     L1
L11:
    test    byte ptr [rsp+6Eh],0FFh
    je      L7
    jmp     L5
    nop
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L13:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L12
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
    jmp     L6
L17:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L18:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L19:
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
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L16:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
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

fn std::slice::from_raw_parts_mut::precondition_check [hint]
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
    mov     qword ptr [rsp+78h],11Bh
    mov     rsi,[rsp+78h]
    lea     rdi,[k2]
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
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L16:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
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

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::try_with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState> [hint]
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,88h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     byte ptr [rsp+57h],1
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+8],0
    mov     rax,[rsp+18h]
    mov     rdi,[rsp+8]
    call    rax
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    cmp     rax,0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+68h],0
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
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
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
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
    test    byte ptr [rsp+57h],0FFh
    je      L5
    jmp     L7
L11:
    mov     qword ptr [rsp+28h],0
    mov     qword ptr [rsp+30h],0
    mov     qword ptr [rsp+30h],1
    cmp     qword ptr [rsp+30h],1
    sete    [rsp+2Fh]
    mov     qword ptr [rsp+68h],1
    jmp     L3
L12:
    mov     rax,[rsp+20h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+57h],0
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L1
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
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

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+28h]
    call    fn0
    mov     rax,[rsp+8]
    mov     [rsp+20h],rax
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    lea     rax,[k1]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym2]
    ud2
L2:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}> [hint]
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     rax,[rsp+50h]
    lea     rax,[rax+10h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+38h],rax
    cmp     rax,1
    jne     L1
    mov     rsi,[rsp+50h]
    mov     [rsp+20h],rsi
    mov     [rsp+8],rsi
    mov     rdi,[rsp+20h]
    mov     [rsp+58h],rdi
    jmp     L2
L1:
    mov     byte ptr [rsp+2Fh],0
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    call    fn0
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L4:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
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
    test    byte ptr [rsp+2Fh],0FFh
    je      L3
    jmp     L5
    lea     rdi,[rsp+60h]
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

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init_slow::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}> [cold]
    inc     qword ptr [jit_record]
    jns     L32
L0:
    sub     rsp,128h
    mov     [rsp+110h],rdi
    mov     [rsp+108h],rsi
    mov     rax,[rsp+110h]
    lea     rax,[rax+10h]
    mov     [rsp+90h],rax
    movzx   eax,byte ptr [rax]
    mov     [rsp+0F8h],rax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L6
    .long   L5
    .long   L4
    .long   L2
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L3:
    ud2
L4:
    mov     qword ptr [rsp+118h],0
    jmp     L13
L5:
    mov     rax,[rsp+110h]
    mov     [rsp+0B0h],rax
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+118h],rdx
    jmp     L13
L6:
    cmp     qword ptr [rsp+108h],0
    je      L14
    jmp     L15
L7:
    lea     rax,[rsp+0C0h]
    mov     [rsp+78h],rax
    lea     rdx,[k0]
    mov     qword ptr [rsp+60h],2Bh
    mov     rdi,[rsp+60h]
    lea     r8,[k1]
    mov     qword ptr [rsp+28h],2Bh
    mov     r10,[rsp+28h]
    shl     r10,1
    or      r10,1
    mov     [rsp+68h],rdx
    mov     [rsp+70h],r10
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    call    fn2
    mov     [rsp+80h],rax
    jmp     L10
L8:
    lea     rax,[rsp+90h]
    mov     [rsp+78h],rax
    mov     rdi,[rsp+78h]
    call    qword ptr [sym3]
    jmp     L27
L9:
    mov     rdi,[rsp+110h]
    call    fn4
    jmp     L11
L10:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn5
    call    qword ptr [sym6]
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L12:
    mov     rax,[rsp+110h]
    mov     [rsp+0A0h],rax
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+118h],rdx
    jmp     L13
L13:
    mov     rax,[rsp+118h]
    add     rsp,128h
    ret
L14:
    mov     qword ptr [rsp+88h],0
    jmp     L18
L15:
    mov     rax,[rsp+108h]
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+60h],0
    mov     rax,[rax]
    mov     [rsp+88h],rax
    mov     rsi,[rsp+78h]
    mov     rsi,[rsi+8]
    mov     [rsp+90h],rsi
    mov     rdi,[rsp+78h]
    mov     rdi,[rdi+10h]
    mov     [rsp+98h],rdi
    mov     r8,[rsp+78h]
    mov     rcx,[rsp+60h]
    mov     [r8],rcx
    mov     r9,[rsp+78h]
    mov     rcx,[rsp+68h]
    mov     [r9+8],rcx
    mov     r10,[rsp+78h]
    mov     rcx,[rsp+70h]
    mov     [r10+10h],rcx
    mov     r11,[rsp+88h]
    mov     [rsp+80h],r11
    cmp     r11,0
    je      L18
    jmp     L19
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L17:
    mov     rax,[rsp+110h]
    mov     [rsp+0A8h],rax
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0E0h]
    mov     rcx,[rsp+0E8h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+60h]
    mov     [rsp+70h],rcx
    mov     rcx,[rsp+70h]
    mov     [rsp+80h],rcx
    mov     [rsp+78h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L25
    jmp     L24
L18:
    call    fn7
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rdx
    jmp     L20
L19:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+0E8h],rcx
    mov     [rsp+0E0h],rax
    jmp     L16
L20:
    jmp     L16
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L22:
    mov     byte ptr [rsp+8Eh],1
    mov     rdx,[rsp+110h]
    lea     rdx,[rdx+10h]
    mov     [rsp+80h],rdx
    movzx   edx,byte ptr [rdx]
    mov     [rsp+8Fh],dl
    mov     rsi,[rsp+80h]
    movzx   ecx,byte ptr [rsp+8Eh]
    mov     [rsi],cl
    movzx   edi,byte ptr [rsp+8Fh]
    mov     [rsp+0C8h],rdi
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L23]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L23:
    .long   L9
    .long   L8
    .long   L7
    .long   L2
L24:
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+18h],8
    mov     byte ptr [rsp+17h],0
    lea     rdi,[k8]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+18h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    fn9
L25:
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L26
    mov     rsi,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rsi
    jmp     L21
L26:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF68h
    xor     ecx,ecx
    call    ryo_h_LoadW128
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF68h
    xor     edx,edx
    mov     ecx,0FFFFFF58h
    call    ryo_h_StoreW128
    jmp     L21
L27:
    jmp     L11
L28:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L29:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L12
L30:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L17
L31:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L22
L32:
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

