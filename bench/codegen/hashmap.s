fn <! as std::sys::thread_local::native::lazy::DestroyedState>::register_dtor::<std::cell::Cell<(u64, u64)>>
    sub     rsp,18h
    mov     [rsp+8],rdi
    add     rsp,18h
    ret

fn <&mut core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write::write_fmt::SpecWriteFmt>::spec_write_fmt
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
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB4h
    mov     edx,0FFFFFFC8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFB4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L1
    .long   L4
L1:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+4Fh],al
    jmp     L3
L2:
    mov     rax,[rsp+40h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    call    qword ptr [sym3]
    mov     [rsp+4Fh],al
L3:
    movzx   eax,byte ptr [rsp+4Fh]
    add     rsp,58h
    ret
L4:
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2

fn <&u64 as std::ops::Rem<u64>>::rem
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    cmp     qword ptr [rsp+28h],0
    jne     L0
    mov     rsi,[rsp+10h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFE8h
    call    ryo_h_RemUW64
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
    sub     rsp,68h
    mov     [rsp+50h],rdi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFF0h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+50h]
    mov     rax,[rax+30h]
    and     rax,0FFh
    shl     rax,38h
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+38h]
    or      rax,rdx
    mov     [rsp+28h],rax
    mov     rsi,[rsp+48h]
    xor     rsi,rax
    mov     [rsp+48h],rsi
    lea     rdi,[rsp+30h]
    mov     [rsp+20h],rdi
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

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
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
    je      L2
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
    jmp     L7
    nop     [rax+rax]
L0:
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
    jae     L1
    mov     r8,[rsp+98h]
    mov     r8,[r8+40h]
    add     r8,rdi
    mov     [rsp+10h],r8
    mov     r9,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [r9+40h],rcx
    jmp     L6
L1:
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
    jmp     L2
L2:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+70h]
    sub     rdx,rax
    mov     [rsp+68h],rdx
    and     rdx,7
    mov     [rsp+60h],rdx
    nop     [rax+rax]
L3:
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+68h]
    sub     rdx,[rsp+60h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jae     L5
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
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop
L4:
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
    jmp     L3
L5:
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
L6:
    add     rsp,0A8h
    ret
L7:
    mov     qword ptr [rsp+20h],0
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+58h]
    call    fn3
    mov     [rsp+60h],rax
    jmp     L0
L8:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],8
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn5
L9:
    mov     qword ptr [rsp+20h],8
    imul    rdx,[rsp+20h],1
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFA8h
    mov     ecx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     rax,[rsp+50h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+18h]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+10h]
    mov     [rsi+18h],rcx
    mov     rdi,[rsp+98h]
    mov     [rsp+50h],rdi
    mov     rdi,[rsp+50h]
    call    fn6
    jmp     L4

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str
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

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
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
    mov     dword ptr [rsp+0Ch],0Dh
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
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
    mov     dword ptr [rsp+0Ch],10h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],11h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
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
    mov     dword ptr [rsp+0Ch],15h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    add     rsp,38h
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
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
    mov     dword ptr [rsp+0Ch],0Dh
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
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
    mov     dword ptr [rsp+0Ch],10h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],11h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
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
    mov     dword ptr [rsp+0Ch],15h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10+8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],0Dh
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
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
    mov     dword ptr [rsp+0Ch],10h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],11h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
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
    mov     dword ptr [rsp+0Ch],15h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10+8],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],0Dh
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
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
    mov     dword ptr [rsp+0Ch],10h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rdi+8],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8]
    mov     r9,[rsp+28h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rsp+20h],r8
    mov     r10,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [r10],rcx
    mov     r11,[rsp+28h]
    mov     r11,[r11+10h]
    mov     [rsp+18h],r11
    mov     dword ptr [rsp+0Ch],11h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+10h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+8]
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
    mov     dword ptr [rsp+0Ch],15h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+18h],rcx
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+28h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+18h],rcx
    mov     r8,[rsp+28h]
    mov     r8,[r8+8]
    mov     [rsp+18h],r8
    mov     dword ptr [rsp+0Ch],20h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFDCh
    call    ryo_h_RotlW64
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    add     rsp,38h
    ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop
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

fn <core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L0
    mov     rsi,[rsp+20h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn1
L0:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_char
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+6Ch],esi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFACh
    mov     edx,4
    call    ryo_h_Zero
    lea     rax,[rsp+2Ch]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+40h],4
    mov     esi,[rsp+6Ch]
    mov     [rsp+28h],esi
    mov     edi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
L1:
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
    jmp     L0

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_fmt
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

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_str
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
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA4h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+50h]
    lea     rdx,[rdx+8]
    mov     [rsp],rdx
    mov     rdi,[rsp]
    call    fn1
    jmp     L4
L3:
    mov     byte ptr [rsp+5Fh],0
    jmp     L6
L4:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+20h]
    mov     [rax+8],rcx
    mov     byte ptr [rsp+5Fh],1
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
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
    jmp     L5

fn <fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn} as std::ops::FnOnce<()>>::call_once - shim(fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn})
    sub     rsp,18h
    call    fn0
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret

fn <for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned} as std::ops::FnOnce<(&str,)>>::call_once - shim(for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned})
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

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>
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
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+0A0h]
    mov     [rsp+30h],rax
    lea     rdx,[rsp+70h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+78h]
    mov     rcx,[rsp+60h]
    call    fn0
    mov     [rsp+0A8h],rax
    jmp     L2
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L0
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L1

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L1:
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
    jmp     L0
L2:
    mov     qword ptr [rsp+38h],8
    jmp     L1
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    jmp     L1
L5:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L4
L6:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L4

fn <hashbrown::raw::RawTable<(std::string::String, usize)> as std::ops::Drop>::drop
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

fn <hashbrown::raw::RawTable<(u64, u64)> as std::ops::Drop>::drop
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

fn <hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}> as std::ops::Drop>::drop
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

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop
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

fn <std::alloc::Global as std::alloc::Allocator>::allocate
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

fn <std::alloc::Global as std::alloc::Allocator>::deallocate
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rcx
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,0
    je      L0
    mov     rsi,[rsp+30h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym0]
    jmp     L1
    nop     [rax]
L0:
    add     rsp,58h
    ret
L1:
    jmp     L0

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>
    sub     rsp,0B8h
    mov     [rsp+30h],rdi
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    mov     r8d,28h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+78h]
    mov     [rsp+68h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF88h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+68h]
    call    fn0
    mov     [rsp+0A8h],rax
    jmp     L2
L0:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L0
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L1

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}
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

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
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

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
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

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str
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

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64
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

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    sub     rsp,168h
    mov     [rsp+108h],rdi
    mov     [rsp+110h],rsi
    mov     rax,[rsp+110h]
    mov     rax,[rax]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+110h]
    mov     rdx,[rdx+8]
    mov     [rsp+0B0h],rdx
    mov     qword ptr [rsp],0
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],0
    mov     qword ptr [rsp+18h],0
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+50h],0
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC0h
    mov     edx,0FFFFFEA0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     qword ptr [rsp+58h],0
    mov     qword ptr [rsp+60h],0
    lea     rsi,[rsp+20h]
    mov     [rsp+18h],rsi
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

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
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
    nop     [rax]
L0:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
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
    nop     [rax]
L0:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::IntoIterator>::into_iter
    sub     rsp,58h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,58h
    ret

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::Iterator>::next
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

fn <std::ops::Range<u32> as std::iter::IntoIterator>::into_iter
    sub     rsp,18h
    mov     [rsp],edi
    mov     [rsp+4],esi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     eax,[rsp+8]
    mov     edx,[rsp+0Ch]
    add     rsp,18h
    ret

fn <std::ops::Range<u32> as std::iter::range::RangeIteratorImpl>::spec_next
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
    je      L0
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
    jmp     L1
L0:
    mov     dword ptr [rsp+28h],0
L1:
    mov     eax,[rsp+28h]
    mov     edx,[rsp+2Ch]
    add     rsp,38h
    ret

fn <std::ops::Range<u64> as std::iter::IntoIterator>::into_iter
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

fn <std::ops::Range<u64> as std::iter::Iterator>::step_by
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

fn <std::ops::Range<u64> as std::iter::range::RangeIteratorImpl>::spec_next
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
    je      L0
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
    jmp     L1
L0:
    mov     qword ptr [rsp+30h],0
L1:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret

fn <std::string::String as std::cmp::PartialEq>::eq
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

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher>
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

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_all
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rdx
    nop
L0:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+58h],rcx
    mov     rdx,[rsp+58h]
    cmp     rdx,0
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L1
    mov     qword ptr [rsp+0A8h],0
    jmp     L11
L1:
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
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L4
    .long   L5
    .long   L3
    nop     [rax]
L3:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
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
    jb      L18
    jmp     L19
L7:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    jmp     L11
L8:
    test    byte ptr [rsp+66h],0FFh
    je      L9
    jmp     L14
L9:
    mov     rax,[rsp+58h]
    mov     [rsp+0A8h],rax
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L0
L11:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L12:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
L13:
    lea     rax,[rsp+58h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn3
    jmp     L10
    nop     [rax+rax]
L14:
    mov     rax,[rsp+50h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L15]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L15:
    .long   L10
    .long   L13
    .long   L3
L16:
    lea     rax,[rsp+58h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn4
    jmp     L12
    nop     [rax+rax]
L17:
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    cmp     rax,1
    je      L16
    jmp     L12
L18:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp]
    call    qword ptr [sym6]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L19:
    mov     rax,[rsp+40h]
    sub     rax,[rsp+48h]
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+98h]
    imul    rcx,[rsp+48h],1
    add     rdx,rcx
    mov     [rsp+90h],rdx
    mov     [rsp+98h],rax
    jmp     L14
    xchg    ax,ax
L20:
    call    qword ptr [sym7]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L20

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_fmt
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
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA4h
    mov     edx,0FFFFFFC8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L1
    .long   L4
L1:
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+20h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+58h],rax
    jmp     L3
L2:
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn2
    mov     [rsp+58h],rax
L3:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L4:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2

fn <u32 as std::iter::Step>::forward_unchecked
    sub     rsp,28h
    mov     [rsp+18h],edi
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFECh
    mov     edx,0FFFFFFF0h
    call    ryo_h_TruncW64W32
    mov     byte ptr [rsp+0Bh],1
    test    byte ptr [rsp+0Bh],0FFh
    je      L0
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     edi,[rsp+18h]
    mov     esi,[rsp+0Ch]
    mov     rdx,[rsp]
    call    fn1
L0:
    mov     eax,[rsp+18h]
    add     eax,[rsp+0Ch]
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn <u64 as hashbrown::Equivalent<u64>>::equivalent
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

fn <u64 as std::borrow::Borrow<u64>>::borrow
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn <u64 as std::iter::Step>::forward_unchecked
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn1
L0:
    mov     rax,[rsp+20h]
    add     rax,[rsp+10h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length
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

fn <u8 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
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
    jmp     L2
    nop     [rax+rax]
L0:
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
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF98h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+48h]
    add     rsp,0B8h
    ret
L2:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+0A8h],0
    cmp     qword ptr [rsp+40h],0
    ja      L0
    jmp     L1
L3:
    mov     rax,[rsp+68h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+40h]
    mov     r9,[rsp]
    call    fn3
L4:
    imul    rax,[rsp+40h],1
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF60h
    call    ryo_h_Memcpy
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L5
    mov     qword ptr [rsp+10h],1
    cmp     qword ptr [rsp+10h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     rax,[rsp+40h]
    mov     [rsp+0A8h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    call    fn5
    jmp     L5
L7:
    mov     qword ptr [rsp+30h],0FFFFFFFFFFFFFFFFh
    jmp     L6
L8:
    mov     rax,[rsp+98h]
    mov     [rsp+30h],rax
    jmp     L6

fn <usize as std::cmp::Ord>::max
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
    je      L0
    mov     byte ptr [rsp+27h],0
    mov     rsi,[rsp+30h]
    mov     [rsp+38h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
L1:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rsp+27h],0FFh
    je      L3
    jmp     L4
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::cmp::Ord>::min
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
    je      L0
    mov     rdx,[rsp+28h]
    mov     [rsp+38h],rdx
    jmp     L1
L0:
    mov     byte ptr [rsp+27h],0
    mov     rdx,[rsp+30h]
    mov     [rsp+38h],rdx
L1:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rsp+27h],0FFh
    je      L3
    jmp     L4
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::default::Default>::default
    sub     rsp,18h
    mov     qword ptr [rsp+8],0
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jae     L0
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0D6h
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0D6h
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
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
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
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
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
    sub     rsp,28h
    mov     [rsp+18h],rdi
    lea     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    call    fn0
    add     rsp,28h
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
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
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
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
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
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

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
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
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
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

fn <{closure@std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}} as std::ops::FnOnce<(std::option::Option<&mut std::option::Option<std::cell::Cell<(u64, u64)>>>,)>>::call_once - shim
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
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
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
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
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

fn alloc::raw_vec::RawVecInner::with_capacity_in
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
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym1]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    cmp     rdx,0
    je      L5
    jmp     L6
    nop     [rax+rax]
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
    jmp     L4
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+20h],rax
    jmp     L4
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    movzx   edi,byte ptr [rsp+37h]
    mov     rsi,[rsp+8]
    call    fn3
L8:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret

fn core::core_arch::simd::Simd::<i8, 16>::splat
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

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i
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

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
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

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher>
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

fn core::hash::impls::<impl std::hash::Hash for u64>::hash::<std::hash::DefaultHasher>
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

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset
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

fn core::hash::sip::u8to64_le
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
    jae     L0
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
    je      L4
    jmp     L3
    nop     [rax]
L0:
    mov     rax,[rsp+68h]
    add     rax,1
    mov     [rsp+58h],rax
    cmp     rax,[rsp+98h]
    jae     L1
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
    je      L6
    jmp     L5
    nop
L1:
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+98h]
    jae     L2
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+0A0h]
    add     rsi,rdx
    mov     [rsp+48h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L8
    jmp     L7
    xchg    ax,ax
L2:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],4
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn1
L4:
    mov     qword ptr [rsp+20h],4
    imul    rdx,[rsp+20h],1
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_Memcpy
    mov     eax,[rsp+60h]
    mov     [rsp+94h],eax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFD4h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+68h]
    add     rax,4
    mov     [rsp+68h],rax
    jmp     L0
L5:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],1
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],2
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn3
L6:
    mov     qword ptr [rsp+20h],2
    imul    rdx,[rsp+20h],1
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF88h
    mov     ecx,0FFFFFF58h
    call    ryo_h_Memcpy
    movzx   eax,word ptr [rsp+64h]
    mov     [rsp+92h],ax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFD2h
    call    ryo_h_ZextW16W64
    mov     rax,[rsp+68h]
    imul    rdx,rax,8
    mov     [rsp+48h],rdx
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
    jmp     L1
L7:
    mov     rax,[rsp+0B0h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+20h]
    call    fn5
L8:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+48h]
    cmp     rdx,rax
    setb    [rsp+65h]
    mov     rsi,[rsp+0A8h]
    imul    rcx,rdx,1
    add     rsi,rcx
    movzx   esi,byte ptr [rsi]
    mov     [rsp+66h],sil
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFA6h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+68h]
    imul    rdx,rax,8
    mov     [rsp+48h],rdx
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
    jmp     L2

fn core::io::error::repr::Repr::data::{closure#0}
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn core::io::error::repr::decode_repr::<&core::io::error::Custom, {closure@core::io::error::repr::Repr::data::{closure#0}}>
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
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L3
    .long   L2
    .long   L5
    .long   L4
    .long   L1
L1:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+18h],28h
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rsp+18h],1
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L16
L3:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B8h]
    mov     [rsp+30h],rdx
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],2
    jmp     L17
L4:
    mov     rax,[rsp+48h]
    shr     rax,20h
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF60h
    call    ryo_h_TruncW64W32
    mov     edi,[rsp+3Ch]
    call    fn3
    mov     [rsp+3Ah],al
    jmp     L6
L5:
    mov     rax,[rsp+48h]
    sar     rax,20h
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF60h
    call    ryo_h_TruncW64W32
    mov     eax,[rsp+3Ch]
    mov     [rsp+0C4h],eax
    mov     byte ptr [rsp+0C0h],0
    jmp     L17
L6:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFF6Ah
    mov     ecx,0FFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF4Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L7]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L7:
    .long   L14
    .long   L15
    .long   L13
    nop     [rax+rax]
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],3
    nop     [rax+rax]
    xchg    ax,ax
L9:
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
L10:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    jmp     L10
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    test    byte ptr [rsp+0A7h],0FFh
    je      L10
    jmp     L11
    nop     [rax]
L13:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L14:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    call    fn5
    jmp     L13
L15:
    movzx   eax,byte ptr [rsp+3Ah]
    mov     [rsp+0C1h],al
    mov     byte ptr [rsp+0C0h],1
    jmp     L17
L16:
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
L17:
    jmp     L9
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L12

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}>
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
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L3
    .long   L2
    .long   L5
    .long   L4
    .long   L1
L1:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+18h],28h
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rsp+18h],1
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L16
L3:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B8h]
    mov     [rsp+30h],rdx
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],2
    jmp     L17
L4:
    mov     rax,[rsp+48h]
    shr     rax,20h
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF60h
    call    ryo_h_TruncW64W32
    mov     edi,[rsp+3Ch]
    call    fn3
    mov     [rsp+3Ah],al
    jmp     L6
L5:
    mov     rax,[rsp+48h]
    sar     rax,20h
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFF60h
    call    ryo_h_TruncW64W32
    mov     eax,[rsp+3Ch]
    mov     [rsp+0C4h],eax
    mov     byte ptr [rsp+0C0h],0
    jmp     L17
L6:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFF6Ah
    mov     ecx,0FFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF4Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L7]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L7:
    .long   L14
    .long   L15
    .long   L13
    nop     [rax+rax]
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+0C8h],rax
    mov     byte ptr [rsp+0C0h],3
    nop     [rax+rax]
    xchg    ax,ax
L9:
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
L10:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    jmp     L10
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    test    byte ptr [rsp+0A7h],0FFh
    je      L10
    jmp     L11
    nop     [rax]
L13:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L14:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    call    fn5
    jmp     L13
L15:
    movzx   eax,byte ptr [rsp+3Ah]
    mov     [rsp+0C1h],al
    mov     byte ptr [rsp+0C0h],1
    jmp     L17
L16:
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
L17:
    jmp     L9
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L12

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rdx
    mov     rax,[rsp+0B0h]
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+80h],0
    lea     rsi,[rsp+78h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rsi
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    call    qword ptr [sym1]
    mov     [rsp+77h],al
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFB7h
    call    ryo_h_ZextW8W64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF4Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+68h],0
    sete    [rsp+75h]
    movzx   edx,byte ptr [rsp+75h]
    xor     dl,1
    mov     [rsp+76h],dl
    test    byte ptr [rsp+76h],0FFh
    je      L5
    jmp     L4
L3:
    mov     qword ptr [rsp+0B8h],0
    lea     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L6
L4:
    mov     rax,[rsp+80h]
    mov     [rsp+0B8h],rax
    jmp     L6
L5:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+50h],56h
    mov     rdx,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+18h],56h
    mov     rdx,[rsp+18h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+40h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym6]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
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
L8:
    call    qword ptr [sym8]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L7
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L8

fn core::num::<impl u32>::unchecked_add::precondition_check
    sub     rsp,88h
    mov     [rsp+7Ch],edi
    mov     [rsp+78h],esi
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFFCh
    mov     r8d,0FFFFFFF8h
    call    ryo_h_AddOvfUW32
    movzx   eax,byte ptr [rsp+60h]
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+70h],0B8h
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],0B8h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,88h
    ret

fn core::num::<impl u64>::unchecked_add::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFF8h
    mov     r8d,0FFFFFFF0h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+60h]
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0B8h
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0B8h
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,98h
    ret

fn core::num::<impl u64>::wrapping_add
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    add     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret

fn core::num::<impl u64>::wrapping_mul
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    imul    rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC0h
    mov     r8d,0FFFFFFB8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+60h]
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0BAh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0BAh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,98h
    ret

fn core::ub_checks::maybe_is_nonoverlapping::runtime
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
    mov     [rsp+20h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFFA8h
    mov     r8d,0FFFFFF80h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+28h]
    movzx   edx,byte ptr [rsp+30h]
    mov     [rsp+63h],dl
    mov     [rsp+18h],rax
    test    byte ptr [rsp+63h],0FFh
    je      L0
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],3Dh
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym1]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,[rsp+18h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+58h]
    cmp     rsi,[rsp+50h]
    jae     L1
    mov     rdi,[rsp+50h]
    sub     rdi,rsi
    mov     [rsp+70h],rdi
    jmp     L2
L1:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+50h]
    mov     [rsp+70h],rax
L2:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+70h]
    setbe   [rsp+9Fh]
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret

fn hashbrown::control::group::sse2::Group::convert_special_to_empty_and_full_to_deleted
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64>
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+78h],rsi
    mov     rax,[rsp+80h]
    mov     rax,[rax+18h]
    cmp     rax,0
    sete    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L0
    mov     qword ptr [rsp+88h],0
    jmp     L2
L0:
    mov     rax,[rsp+80h]
    lea     rax,[rax+20h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+78h]
    call    fn0
    mov     [rsp+50h],rax
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    nop
L2:
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
L3:
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+38h]
    call    fn1
    mov     [rsp+30h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFFA0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF74h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L4:
    .long   L5
    .long   L6
    .long   L1
L5:
    mov     qword ptr [rsp+88h],0
    jmp     L2
L6:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax]
L7:
    mov     rax,[rsp+18h]
    lea     rax,[rax+8]
    mov     [rsp+88h],rax
    jmp     L2
L8:
    mov     qword ptr [rsp+18h],8
    jmp     L7
L9:
    mov     rax,[rsp+8]
    mov     [rsp+10h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+10h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+18h],rdx
    jmp     L10

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::iter
    sub     rsp,0D8h
    mov     [rsp+88h],rdi
    mov     [rsp+0A0h],rsi
    mov     rax,[rsp+0A0h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+18h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF68h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+30h]
    mov     [rsp+80h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF90h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+88h]
    add     rsp,0D8h
    ret
L1:
    mov     qword ptr [rsp+18h],1
    jmp     L3
L2:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L3:
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
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,0E8h
    mov     [rsp+0D8h],rdi
    mov     rax,[rsp+0D8h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L0:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L13
    jmp     L14
    nop     [rax]
L1:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L18
    jmp     L17
    xchg    ax,ax
L3:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+2Fh],0FFh
    je      L5
    jmp     L6
L5:
    mov     rax,[rsp+0D8h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+40h]
    call    fn0
L6:
    jmp     L0
L7:
    add     rsp,0E8h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF98h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L9:
    mov     rax,[rsp+0D8h]
    mov     rax,[rax+18h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF70h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+48h]
    mov     [rsp+0D0h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD0h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L10:
    mov     qword ptr [rsp+30h],1
    jmp     L12
L11:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
L12:
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
    jmp     L9
L13:
    mov     qword ptr [rsp+48h],0
    jmp     L3
L14:
    lea     rax,[rsp+50h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    call    fn2
    mov     [rsp+48h],rax
    mov     rax,[rsp+70h]
    sub     rax,1
    mov     [rsp+70h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF2Ch
    mov     edx,0FFFFFF68h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF2Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L15]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L15:
    .long   L3
    .long   L2
    .long   L1
    nop     [rax+rax]
    nop     [rax]
L16:
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
    jmp     L4
L17:
    mov     qword ptr [rsp+38h],8
    jmp     L16
L18:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
L19:
    jmp     L16
L20:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L19
L21:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L19
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L8

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
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

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
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

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
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

fn hashbrown::raw::FullBucketsIndices::next_impl
    sub     rsp,0C8h
    mov     [rsp+0A8h],rdi
    nop
L0:
    mov     rax,[rsp+0A8h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+2Eh],ax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF6Eh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF50h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L4
    .long   L3
    .long   L2
L2:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF68h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+18h]
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF84h
    call    ryo_h_TruncW32W16
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
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::new
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
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFF48h
    call    ryo_h_TruncW32W16
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

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    nop
L0:
    mov     rax,[rsp+0D0h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+3Eh],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF5Eh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF34h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF50h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L7
    .long   L6
    .long   L5
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jb      L3
    mov     qword ptr [rsp+0D8h],0
    jmp     L4
    nop     [rax+rax]
    xchg    ax,ax
L3:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+0B0h],rax
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    call    qword ptr [sym0]
    jmp     L14
    nop     [rax+rax]
L4:
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
L5:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L6:
    movzx   eax,word ptr [rsp+3Eh]
    mov     [rsp+26h],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF46h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+38h],eax
    jmp     L8
L7:
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
    je      L3
    jmp     L2
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFF58h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+28h]
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
    je      L9
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rsp+38h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L13
    jmp     L12
    xchg    ax,ax
L10:
    mov     rax,[rsp+38h]
    mov     [rsp+0D8h],rax
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    jmp     L10
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L11
L13:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L11
L14:
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym2]
    mov     [rsp+54h],eax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF74h
    call    ryo_h_TruncW32W16
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
    je      L15
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rsp+50h],r8
    jmp     L16
L15:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L16:
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
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L17:
    jmp     L16
L18:
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L17
L19:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+10h],20h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L17

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
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
L0:
    movzx   eax,word ptr [rsp+110h]
    mov     [rsp+46h],ax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEF4h
    mov     edx,0FFFFFF26h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFEF4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF18h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L12
    .long   L11
    .long   L10
L2:
    mov     byte ptr [rsp+0B7h],1
    mov     rdx,[rsp+40h]
    mov     [rsp+0E8h],rdx
    mov     rsi,[rsp+0F0h]
    sub     rsi,1
    mov     [rsp+0F0h],rsi
    jmp     L0
    xchg    ax,ax
L3:
    mov     byte ptr [rsp+0B7h],0
    mov     rdx,[rsp+0E8h]
    mov     [rsp+118h],rdx
    jmp     L5
    nop     [rax+rax]
L4:
    mov     rax,[rsp+100h]
    mov     [rsp+0C0h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+70h]
    mov     rsi,[rsp+50h]
    call    qword ptr [sym0]
    jmp     L19
L5:
    mov     rax,[rsp+118h]
    add     rsp,128h
    ret
    nop     [rax+rax]
L6:
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF48h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L8:
    jmp     L7
L9:
    test    byte ptr [rsp+0B7h],0FFh
    je      L7
    jmp     L8
L10:
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L11:
    movzx   eax,word ptr [rsp+46h]
    mov     [rsp+2Eh],ax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEF4h
    mov     edx,0FFFFFF0Eh
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+40h],eax
    jmp     L13
L12:
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
    je      L3
    jmp     L4
L13:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFF20h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+30h]
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
    je      L14
    mov     rdx,[rsp+0F8h]
    add     rdx,rax
    mov     [rsp+40h],rdx
    jmp     L15
L14:
    mov     rax,[rsp+0F8h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
L15:
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
    jmp     L2
    nop     [rax+rax]
L16:
    jmp     L15
L17:
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L16
L18:
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+38h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+40h],rdi
    jmp     L16
L19:
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym3]
    mov     [rsp+5Ch],eax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF3Ch
    call    ryo_h_TruncW32W16
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF42h
    mov     edx,0FFFFFF40h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+62h]
    mov     [rsp+110h],ax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L20
    mov     rdi,[rsp+0F8h]
    add     rdi,10h
    mov     [rsp+58h],rdi
    jmp     L21
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L24
    jmp     L23
    nop     [rax]
L21:
    mov     rax,[rsp+58h]
    mov     [rsp+0F8h],rax
    mov     rdx,[rsp+100h]
    mov     qword ptr [rsp+10h],10h
    imul    rcx,[rsp+10h],1
    add     rdx,rcx
    mov     [rsp+100h],rdx
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L22:
    jmp     L21
L23:
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    jmp     L22
L24:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+10h],10h
    add     rdx,rcx
    mov     [rsp+58h],rdx
    jmp     L22
    lea     rdi,[rsp+120h]
    mov     rsi,rax
    mov     edx,0FFFFFF48h
    call    ryo_h_Lpad
    jmp     L6

fn hashbrown::raw::RawIterRange::<(u64, u64)>::new
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
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF4Ch
    mov     edx,0FFFFFF48h
    call    ryo_h_TruncW32W16
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

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    nop
L0:
    mov     rax,[rsp+0D0h]
    movzx   eax,word ptr [rax+18h]
    mov     [rsp+3Eh],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF5Eh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF34h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF50h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L7
    .long   L6
    .long   L5
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    jb      L3
    mov     qword ptr [rsp+0D8h],0
    jmp     L4
    nop     [rax+rax]
    xchg    ax,ax
L3:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     [rsp+0B0h],rax
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    call    qword ptr [sym0]
    jmp     L14
    nop     [rax+rax]
L4:
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
L5:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L6:
    movzx   eax,word ptr [rsp+3Eh]
    mov     [rsp+26h],ax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF34h
    mov     edx,0FFFFFF46h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+38h],eax
    jmp     L8
L7:
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
    je      L3
    jmp     L2
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFF58h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+28h]
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
    je      L9
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rsp+38h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L13
    jmp     L12
    xchg    ax,ax
L10:
    mov     rax,[rsp+38h]
    mov     [rsp+0D8h],rax
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    jmp     L10
L12:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L11
L13:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L11
L14:
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym2]
    mov     [rsp+54h],eax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF74h
    call    ryo_h_TruncW32W16
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
    je      L15
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rsp+50h],r8
    jmp     L16
L15:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L16:
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
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L17:
    jmp     L16
L18:
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L17
L19:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+10h],10h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L17

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
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
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L3
    .long   L1
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+0A8h],0
    jmp     L4
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L8
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L8:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L4
    nop
L9:
    jmp     L8
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L11:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L9
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
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
    je      L2
    jmp     L1
    xchg    ax,ax
L0:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L4
L6:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L4
    nop     [rax+rax]
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L0
L8:
    mov     qword ptr [rsp+30h],8
    jmp     L7
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],20h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
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
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rax,[rsp+0A8h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn1
    jmp     L0
L2:
    mov     rax,[rsp+0D0h]
    mov     rax,[rax]
    imul    rcx,[rsp+88h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+5Fh],al
    mov     rdx,[rsp+0C8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF6Eh
    mov     edx,0FFFFFF58h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+4Eh]
    mov     [rsp+4Fh],al
    mov     rdx,[rsp+88h]
    sub     rdx,10h
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+0D0h]
    mov     rdi,[rdi]
    imul    rcx,[rsp+88h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [rdi],cl
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    imul    rcx,[rsp+40h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r8],cl
    mov     r9,[rsp+0D0h]
    mov     r9,[r9]
    mov     [rsp+40h],r9
    mov     [rsp+48h],r9
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L3
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+38h],rax
    jmp     L4
L3:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
    nop     [rax]
L4:
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    mov     [rsp+0D8h],rax
    movzx   edx,byte ptr [rsp+5Fh]
    and     dl,1
    mov     [rsp+46h],dl
    cmp     byte ptr [rsp+46h],0
    setne   [rsp+47h]
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF67h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+10h]
    sub     rax,[rsp+48h]
    mov     [rsp],rax
    mov     rdx,[rsp+0D0h]
    mov     rcx,[rsp]
    mov     [rdx+10h],rcx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFFC8h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L5:
    jmp     L4
L6:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L5
L7:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+30h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+38h],rdi
    jmp     L5
    nop     [rax]
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    xor     edx,edx
    mov     ecx,0FFFFFF50h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+18h]
    add     rax,1
    mov     [rsp],rax
    mov     rdx,[rsp+0D0h]
    mov     rcx,[rsp]
    mov     [rdx+18h],rcx
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
L9:
    mov     qword ptr [rsp+28h],8
    jmp     L8
L10:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop
L11:
    jmp     L8
L12:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L11
L13:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+20h]
    imul    rcx,[rsp+10h],20h
    add     rdx,rcx
    mov     [rsp+28h],rdx
    jmp     L11
    nop
L14:
    call    qword ptr [sym2]
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF70h
    call    ryo_h_Lpad
    jmp     L1
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF70h
    call    ryo_h_Lpad
    jmp     L14

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     [rsp+48h],rdx
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    cmp     rax,[rsp+50h]
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop
L0:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA4h
    mov     edx,0FFFFFFB0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+8],0
    sete    [rsp+2Fh]
    nop     [rax+rax]
L1:
    add     rsp,68h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+47h],0FFh
    je      L2
    jmp     L3
L5:
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
    jmp     L0
L6:
    jmp     L1
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L4

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
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
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L1
L0:
    mov     qword ptr [rsp+40h],0
L1:
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
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L2

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
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
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L4
L6:
    mov     rax,[rsp+80h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L4
    nop     [rax+rax]
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+98h],rax
    jmp     L0
L8:
    mov     qword ptr [rsp+30h],8
    jmp     L7
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],20h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,28h
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
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
    je      L2
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    jmp     L6
L1:
    mov     qword ptr [rsp+20h],8
    jmp     L0
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
L3:
    jmp     L0
L4:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L3
L5:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L3
L6:
    add     rsp,48h
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+1Dh],0
    test    byte ptr [rsp+1Dh],0FFh
    je      L3
    jmp     L2
    xchg    ax,ax
L0:
    add     rsp,68h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    call    fn0
    jmp     L0
L2:
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    sub     rax,1
    mov     [rsp+48h],rax
    jmp     L1
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],10h
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    jmp     L1
L5:
    mov     qword ptr [rsp+10h],10h
    mov     rdx,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rsp+1Eh]
    test    byte ptr [rsp+1Eh],0FFh
    je      L6
    mov     rdi,[rsp+30h]
    sub     rdi,[rsp+28h]
    mov     [rsp+20h],rdi
    mov     qword ptr [rsp+10h],10h
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFFB0h
    call    ryo_h_DivSW64
    jmp     L4
L6:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],49h
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym3]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
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
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L3
    .long   L1
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+0A8h],0
    jmp     L4
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L8
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L8:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L4
    nop
L9:
    jmp     L8
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L11:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L9
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
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
    je      L2
    jmp     L1
    xchg    ax,ax
L0:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L4
L6:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L4
    nop     [rax+rax]
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L0
L8:
    mov     qword ptr [rsp+30h],8
    jmp     L7
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
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
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L3
    .long   L1
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+0A8h],0
    jmp     L4
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L8
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L8:
    mov     rax,[rsp+28h]
    mov     [rsp+0A8h],rax
    jmp     L4
    nop
L9:
    jmp     L8
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L11:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L9
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
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
    je      L2
    jmp     L1
    xchg    ax,ax
L0:
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L4
L6:
    mov     rax,[rsp+88h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L4
    nop     [rax+rax]
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+9Fh],al
    jmp     L0
L8:
    mov     qword ptr [rsp+30h],8
    jmp     L7
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
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
    jmp     L2
    nop     [rax]
L0:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L1:
    jmp     L0
L2:
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    imul    rcx,[rsp+78h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+4Fh],al
    mov     rdx,[rsp+0A8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF7Eh
    mov     edx,0FFFFFF68h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+3Eh]
    mov     [rsp+3Fh],al
    mov     rdx,[rsp+78h]
    sub     rdx,10h
    mov     rsi,[rsp+0B0h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rdi,[rdi]
    imul    rcx,[rsp+78h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+3Fh]
    mov     [rdi],cl
    mov     r8,[rsp+0B0h]
    mov     r8,[r8]
    imul    rcx,[rsp+30h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+3Fh]
    mov     [r8],cl
    mov     r9,[rsp+0B0h]
    mov     r9,[r9]
    mov     [rsp+30h],r9
    mov     [rsp+38h],r9
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L3
    mov     rax,[rsp+78h]
    add     rax,1
    mov     [rsp+28h],rax
    jmp     L4
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+50h],rax
    mov     [rsp+0B8h],rax
    movzx   edx,byte ptr [rsp+4Fh]
    and     dl,1
    mov     [rsp+36h],dl
    cmp     byte ptr [rsp+36h],0
    setne   [rsp+37h]
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF77h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+10h]
    sub     rax,[rsp+38h]
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L5:
    jmp     L4
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L5
L7:
    mov     rax,[rsp+78h]
    mov     qword ptr [rsp+8],0
    mov     rsi,[rsp+8]
    sub     rsi,rax
    mov     rdi,[rsp+20h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L5
    nop     [rax+rax]
L8:
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
L9:
    mov     qword ptr [rsp+28h],8
    jmp     L8
L10:
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L13
    jmp     L12
L11:
    jmp     L8
L12:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L11
L13:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+20h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+28h],rdx
    jmp     L11
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFF80h
    call    ryo_h_Lpad
    jmp     L1

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     [rsp+50h],rsi
    mov     [rsp+48h],rdx
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    cmp     rax,[rsp+50h]
    setb    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop
L0:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA4h
    mov     edx,0FFFFFFB0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+8],0
    sete    [rsp+2Fh]
    nop     [rax+rax]
L1:
    add     rsp,68h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+47h],0FFh
    je      L2
    jmp     L3
L5:
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
    jmp     L0
L6:
    jmp     L1
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L4

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
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
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     byte ptr [rsp+37h],0
    test    byte ptr [rsp+37h],0FFh
    je      L0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L1
L0:
    mov     qword ptr [rsp+40h],0
L1:
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
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L2

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
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
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+20h],rax
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L4
L6:
    mov     rax,[rsp+80h]
    mov     qword ptr [rsp],0
    mov     rsi,[rsp]
    sub     rsi,rax
    mov     rdi,[rsp+18h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rsp+20h],rdi
    jmp     L4
    nop     [rax+rax]
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    call    fn0
    mov     [rsp+98h],rax
    jmp     L0
L8:
    mov     qword ptr [rsp+30h],8
    jmp     L7
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L10:
    jmp     L7
L11:
    mov     rax,[rsp+28h]
    mov     [rsp+30h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+28h]
    imul    rcx,[rsp],10h
    add     rdx,rcx
    mov     [rsp+30h],rdx
    jmp     L10

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L4
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi+18h]
    mov     [rsp+58h],rsi
    cmp     rsi,0
    je      L4
    mov     r8,[rsp+0A8h]
    mov     r8,[r8]
    mov     [rsp+20h],r8
    mov     [rsp+50h],r8
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop     [rax]
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    xchg    ax,ax
L3:
    jmp     L4
L4:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L5:
    mov     rax,[rsp+0A8h]
    mov     rax,[rax+18h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+30h]
    mov     [rsp+0A0h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L6:
    mov     qword ptr [rsp+18h],1
    jmp     L8
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L8:
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
    jmp     L5
L9:
    mov     qword ptr [rsp+30h],0
    jmp     L3
L10:
    lea     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn1
    mov     [rsp+30h],rax
    mov     rax,[rsp+58h]
    sub     rax,1
    mov     [rsp+58h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF5Ch
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L11]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L11:
    .long   L3
    .long   L2
    .long   L1
    nop     [rax+rax]
    nop     [rax]
L12:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn2
    jmp     L18
L13:
    mov     qword ptr [rsp+20h],8
    jmp     L12
L14:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L15:
    jmp     L12
L16:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L15
L17:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],20h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L15
L18:
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L4
    mov     rsi,[rsp+0A8h]
    mov     rsi,[rsi+18h]
    mov     [rsp+58h],rsi
    cmp     rsi,0
    je      L4
    mov     r8,[rsp+0A8h]
    mov     r8,[r8]
    mov     [rsp+20h],r8
    mov     [rsp+50h],r8
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop     [rax]
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    xchg    ax,ax
L3:
    jmp     L4
L4:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
L5:
    mov     rax,[rsp+0A8h]
    mov     rax,[rax+18h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+30h]
    mov     [rsp+0A0h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L6:
    mov     qword ptr [rsp+18h],1
    jmp     L8
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
L8:
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
    jmp     L5
L9:
    mov     qword ptr [rsp+30h],0
    jmp     L3
L10:
    lea     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn1
    mov     [rsp+30h],rax
    mov     rax,[rsp+58h]
    sub     rax,1
    mov     [rsp+58h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF5Ch
    mov     edx,0FFFFFF80h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L11]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L11:
    .long   L3
    .long   L2
    .long   L1
    nop     [rax+rax]
    nop     [rax]
L12:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    qword ptr [sym2]
    jmp     L18
L13:
    mov     qword ptr [rsp+20h],8
    jmp     L12
L14:
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L15:
    jmp     L12
L16:
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    jmp     L15
L17:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+18h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+20h],rdx
    jmp     L15
L18:
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_inner_table::<(std::string::String, usize), std::alloc::Global>
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
    jne     L0
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
    jmp     L2
    nop     [rax+rax]
L0:
    add     rsp,98h
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF74h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+30h],1
    sete    [rsp+56h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+48h]
    mov     rdi,[rsp+88h]
    mov     rdi,[rdi]
    mov     qword ptr [rsp],0
    mov     r9,[rsp]
    sub     r9,rsi
    imul    rcx,r9,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    call    fn2
    jmp     L1

fn hashbrown::raw::RawTableInner::drop_inner_table::<(u64, u64), std::alloc::Global>
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
    jne     L0
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
    jmp     L2
    nop     [rax+rax]
L0:
    add     rsp,98h
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF74h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+30h],1
    sete    [rsp+56h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+48h]
    mov     rdi,[rsp+88h]
    mov     rdi,[rdi]
    mov     qword ptr [rsp],0
    mov     r9,[rsp]
    sub     r9,rsi
    imul    rcx,r9,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    call    fn2
    jmp     L1

fn hashbrown::raw::RawTableInner::erase
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
    jmp     L3
    nop     [rax+rax]
    nop
L0:
    mov     byte ptr [rsp+9Fh],80h
    jmp     L2
    nop     [rax+rax]
L1:
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+10h]
    mov     [rdx+10h],rcx
    mov     byte ptr [rsp+9Fh],0FFh
L2:
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
L3:
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFBEh
    mov     edx,0FFFFFF7Ch
    call    ryo_h_TruncW32W16
    mov     rax,[rsp+0B8h]
    mov     rax,[rax]
    imul    rcx,[rsp+0B0h],1
    add     rax,rcx
    mov     [rsp+70h],rax
    mov     [rsp+48h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+40h],rdx
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF9Eh
    mov     edx,0FFFFFF7Ch
    call    ryo_h_TruncW32W16
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF64h
    mov     edx,0FFFFFFBEh
    call    ryo_h_CtlzW16
    mov     eax,[rsp+24h]
    mov     [rsp+3Ch],eax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF7Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF64h
    mov     edx,0FFFFFF9Eh
    call    ryo_h_CttzW16
    mov     eax,[rsp+24h]
    mov     [rsp+34h],eax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF74h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+40h]
    add     rax,[rsp+38h]
    mov     [rsp+48h],rax
    cmp     rax,10h
    jae     L0
    jmp     L1

fn hashbrown::raw::RawTableInner::fallible_with_capacity::<std::alloc::Global>
    sub     rsp,118h
    mov     [rsp+80h],rdi
    mov     [rsp+0E8h],rsi
    mov     [rsp+0D8h],rdx
    mov     [rsp+0E0h],rcx
    mov     [rsp+0D0h],r8
    mov     [rsp+0CFh],r9b
    cmp     qword ptr [rsp+0D0h],0
    jne     L0
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    mov     ecx,20h
    call    ryo_h_Const
    jmp     L5
L0:
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     rdx,[rsp+0E0h]
    call    fn1
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF38h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L7
    .long   L8
    .long   L2
    nop     [rax]
L2:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
    nop
L3:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF04h
    mov     edx,0FFFFFF30h
    xor     ecx,ecx
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFF04h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF28h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L4:
    .long   L11
    .long   L10
    .long   L2
    nop     [rax+rax]
    nop     [rax]
L5:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF70h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+80h]
    add     rsp,118h
    ret
L7:
    movzx   edi,byte ptr [rsp+0CFh]
    call    qword ptr [sym2]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    jmp     L9
L8:
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
    jmp     L3
L9:
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
L10:
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
L11:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF30h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF08h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF50h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0A0h]
    add     rdx,1
    add     rdx,10h
    mov     [rsp+88h],rdx
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+17h],0FFh
    imul    rdi,[rsp+88h],1
    mov     [rsp+8],rdi
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF07h
    mov     ecx,0FFFFFEF8h
    call    ryo_h_Memset
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L5

fn hashbrown::raw::RawTableInner::find_inner
    sub     rsp,108h
    mov     [rsp+0E8h],rdi
    mov     [rsp+0E0h],rsi
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rcx
    mov     rax,[rsp+0E0h]
    shr     rax,39h
    and     rax,7Fh
    mov     [rsp+60h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFB7h
    mov     edx,0FFFFFF60h
    call    ryo_h_TruncW64W8
    mov     rax,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+68h],0
    nop     [rax+rax]
L0:
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
    jmp     L6
    nop     [rax]
L1:
    movzx   eax,word ptr [rsp+0CEh]
    mov     [rsp+74h],ax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF24h
    mov     edx,0FFFFFF74h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF24h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF38h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L2:
    .long   L8
    .long   L7
    .long   L3
L3:
    lea     rdi,[rsp+100h]
    call    ryo_h_Unreachable
    ud2
    nop
L4:
    test    byte ptr [rsp+75h],0FFh
    je      L12
    jmp     L11
L5:
    mov     rax,[rsp+0F0h]
    mov     rdx,[rsp+0F8h]
    add     rsp,108h
    ret
L6:
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
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF72h
    mov     edx,0FFFFFF4Ch
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rsp+72h]
    mov     [rsp+0CEh],ax
    jmp     L1
L7:
    movzx   eax,word ptr [rsp+74h]
    mov     [rsp+70h],ax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF24h
    mov     edx,0FFFFFF70h
    call    ryo_h_CttzW16
    mov     eax,[rsp+24h]
    mov     [rsp+2Ch],eax
    jmp     L9
L8:
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
    jmp     L10
L9:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF2Ch
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+30h]
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
    jmp     L4
L10:
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
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF76h
    mov     edx,0FFFFFF70h
    call    ryo_h_TruncW32W16
    cmp     word ptr [rsp+76h],0
    setne   [rsp+75h]
    cmp     word ptr [rsp+76h],0
    je      L14
    jmp     L13
L11:
    mov     rax,[rsp+40h]
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+0F0h],1
    jmp     L5
L12:
    jmp     L1
L13:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k8]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L14:
    mov     rax,[rsp+0E8h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+68h]
    add     rdx,10h
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+60h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rsp+60h],rsi
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index
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
    xchg    ax,ax
L0:
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
    jmp     L3
    nop     [rax]
L1:
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    cmp     rax,1
    sete    [rsp+46h]
    cmp     rax,1
    je      L4
    jmp     L5
    xchg    ax,ax
L2:
    mov     rax,[rsp+78h]
    add     rsp,88h
    ret
L3:
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
    jmp     L1
L4:
    cmp     qword ptr [rsp+48h],1
    sete    [rsp+47h]
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+8]
    call    fn2
    mov     [rsp+78h],rax
    jmp     L2
L5:
    mov     rax,[rsp+70h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+38h]
    add     rdx,10h
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+30h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rsp+30h],rsi
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
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
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L1:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFBEh
    mov     edx,0FFFFFFB0h
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rsp+3Eh]
    mov     [rsp+32h],ax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFFB2h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L4
    .long   L3
    .long   L6
L3:
    movzx   eax,word ptr [rsp+32h]
    mov     [rsp+1Ah],ax
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
    jmp     L7
L5:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+20h]
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
    jmp     L0
L6:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L7:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L0

fn hashbrown::raw::RawTableInner::fix_insert_index
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
    je      L2
    jmp     L1
    xchg    ax,ax
L0:
    mov     rax,[rsp+88h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+98h]
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+80h],rax
    mov     [rsp+28h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+20h]
    call    qword ptr [sym0]
    jmp     L3
L2:
    jmp     L0
L3:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    lea     rdi,[rsp]
    call    qword ptr [sym1]
    mov     [rsp+2Ch],eax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFAEh
    mov     edx,0FFFFFF8Ch
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rsp+4Eh]
    mov     [rsp+40h],ax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFFA0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF74h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L4:
    .long   L7
    .long   L6
    .long   L9
L5:
    mov     rax,[rsp+30h]
    cmp     rax,1
    sete    [rsp+43h]
    mov     rsi,[rsp+38h]
    mov     [rsp+88h],rsi
    jmp     L0
L6:
    movzx   eax,word ptr [rsp+40h]
    mov     [rsp+24h],ax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF74h
    mov     edx,0FFFFFF84h
    call    ryo_h_CttzW16
    mov     eax,[rsp+14h]
    mov     [rsp+20h],eax
    jmp     L8
L7:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L8:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF80h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    jmp     L5
L9:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2

fn hashbrown::raw::RawTableInner::new_uninitialized::<std::alloc::Global>
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
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+120h],rcx
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+110h],0
    jmp     L10
L1:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEDCh
    mov     edx,0FFFFFF28h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFEDCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L4
    .long   L3
    .long   L5
L3:
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+90h],rdx
    mov     rdi,[rsp+108h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    call    fn1
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    jmp     L11
L4:
    movzx   edi,byte ptr [rsp+0EFh]
    call    qword ptr [sym2]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L5:
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
    nop
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
    jne     L15
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym4]
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L7:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEDCh
    mov     edx,0FFFFFEF8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFEDCh
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+20h],1
    sete    [rsp+8Fh]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp+90h],rsi
    jmp     L8
    xchg    ax,ax
L8:
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
    jb      L16
    jmp     L17
    nop     [rax]
L9:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+120h],rcx
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+110h],0
    nop     [rax+rax]
    nop
L10:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF50h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+80h]
    add     rsp,138h
    ret
L11:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEDCh
    mov     edx,0FFFFFF18h
    xor     ecx,ecx
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFEDCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF10h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L12]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L12:
    .long   L14
    .long   L13
    .long   L5
L13:
    movzx   edi,byte ptr [rsp+0EFh]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+78h]
    call    qword ptr [sym5]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    jmp     L9
L14:
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
    jne     L6
    jmp     L8
L15:
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
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFF10h
    call    ryo_h_ZextW32W64
    mov     qword ptr [rsp+8],3Fh
    mov     rdx,[rsp+8]
    sub     rdx,[rsp+28h]
    mov     [rsp+30h],rdx
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
L16:
    jmp     L18
L17:
    mov     rax,[rsp+0A8h]
    add     rax,1
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFEF0h
    mov     ecx,0FFFFFED8h
    call    ryo_h_DivUW64
    imul    rax,[rsp+28h],7
    mov     [rsp+0A8h],rax
L18:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+50h],rsi
    mov     qword ptr [rsp+58h],0
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF10h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L10

fn hashbrown::raw::RawTableInner::prepare_rehash_in_place
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
    jmp     L3
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0E8h]
    add     rax,1
    mov     [rsp+38h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF0Ch
    mov     edx,0FFFFFF38h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF0Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+30h],1
    sete    [rsp+77h]
    mov     rdx,[rsp+38h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+0E0h]
    mov     [rsp+58h],rsi
    cmp     rsi,0
    ja      L4
    jmp     L5
    nop
L1:
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
    jmp     L7
    nop     [rax+rax]
    nop     [rax]
L2:
    add     rsp,108h
    ret
L3:
    jmp     L0
L4:
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
    jmp     L6
L5:
    mov     rax,[rsp+0F8h]
    mov     rax,[rax+8]
    add     rax,1
    cmp     rax,10h
    setb    [rsp+76h]
    test    byte ptr [rsp+76h],0FFh
    je      L9
    jmp     L8
L6:
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
    jmp     L1
L7:
    jmp     L0
L8:
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
    jmp     L10
L9:
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
    mov     qword ptr [rsp+8],10h
    imul    r9,[rsp+8],1
    mov     [rsp],r9
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF58h
    mov     ecx,0FFFFFF00h
    call    ryo_h_Memmove
    jmp     L11
L10:
    jmp     L2
L11:
    jmp     L2

fn hashbrown::raw::RawTableInner::prepare_resize::<std::alloc::Global>::{closure#0}
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    jne     L0
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
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF6Ch
    mov     edx,0FFFFFFA0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF6Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+38h],1
    sete    [rsp+6Eh]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+50h]
    mov     rdi,[rsp+90h]
    mov     rdi,[rdi]
    mov     qword ptr [rsp+8],0
    mov     r9,[rsp+8]
    sub     r9,rsi
    imul    rcx,r9,1
    add     rdi,rcx
    mov     [rsp+30h],rdi
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+20h]
    call    fn1
    jmp     L1

fn hashbrown::raw::RawTableInner::rehash_in_place
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
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+1C8h]
    mov     rdx,[rsp+1D0h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+200h]
    call    ryo_h_Unreachable
    ud2
    nop
L2:
    jmp     L7
    nop     [rax+rax]
    xchg    ax,ax
L3:
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
L4:
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
    mov     [rsp+38h],rsi
    mov     qword ptr [rsp+8],10h
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFE38h
    mov     ecx,0FFFFFE08h
    call    ryo_h_DivUW64
    mov     rax,[rsp+50h]
    sub     rax,[rsp+30h]
    mov     rdx,[rsp+0E8h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+8],10h
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE38h
    mov     edx,0FFFFFE28h
    mov     ecx,0FFFFFE08h
    call    ryo_h_DivUW64
    mov     rax,[rsp+40h]
    cmp     rax,[rsp+38h]
    sete    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L5:
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
    jmp     L7
    nop     [rax]
L6:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+1E0h]
    mov     [rsp+38h],rdx
    mov     rcx,[rsp+38h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    imul    rsi,[rsp+20h],1
    mov     [rsp+28h],rsi
    jmp     L16
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    jmp     L0
    nop     [rax+rax]
    xchg    ax,ax
L8:
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE98h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L9:
    lea     rax,[rsp+80h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L8
L10:
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
    je      L3
    jmp     L2
L11:
    mov     rax,[rsp+80h]
    mov     rax,[rax+8]
    mov     [rsp+130h],rax
    cmp     rax,8
    jb      L18
    jmp     L19
L12:
    mov     rax,[rsp+80h]
    mov     [rsp+0E0h],rax
    mov     rdx,[rsp+58h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE4Eh
    mov     edx,0FFFFFE38h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+4Eh]
    mov     [rsp+4Fh],al
    mov     rdx,[rsp+68h]
    sub     rdx,10h
    mov     rsi,[rsp+0E0h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+0E0h]
    mov     rdi,[rdi]
    imul    rcx,[rsp+68h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [rdi],cl
    mov     r8,[rsp+0E0h]
    mov     r8,[r8]
    imul    rcx,[rsp+40h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [r8],cl
    jmp     L7
L13:
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
    mov     [rsp+30h],r9
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE45h
    mov     edx,0FFFFFE30h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+45h]
    mov     [rsp+46h],al
    mov     rdx,[rsp+50h]
    sub     rdx,10h
    mov     rsi,[rsp+0D0h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+0D0h]
    mov     rdi,[rdi]
    imul    rcx,[rsp+50h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+46h]
    mov     [rdi],cl
    mov     r8,[rsp+0D0h]
    mov     r8,[r8]
    imul    rcx,[rsp+38h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+46h]
    mov     [r8],cl
    movzx   r9d,byte ptr [rsp+47h]
    cmp     r9b,0FFh
    sete    [rsp+46h]
    test    byte ptr [rsp+46h],0FFh
    je      L6
    jmp     L5
L14:
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+18h]
    call    fn3
    jmp     L15
L15:
    jmp     L4
L16:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE0Ch
    mov     edx,0FFFFFE20h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFE0Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L17]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L17:
    .long   L15
    .long   L14
    .long   L1
L18:
    jmp     L20
L19:
    mov     rax,[rsp+130h]
    add     rax,1
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFE68h
    mov     ecx,0FFFFFE08h
    call    ryo_h_DivUW64
    imul    rax,[rsp+70h],7
    mov     [rsp+130h],rax
L20:
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
L21:
    call    qword ptr [sym4]
    lea     rdi,[rsp+200h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+200h]
    mov     rsi,rax
    mov     edx,0FFFFFE98h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+200h]
    mov     rsi,rax
    mov     edx,0FFFFFE98h
    call    ryo_h_Lpad
    jmp     L21

fn hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}
    sub     rsp,118h
    mov     [rsp+108h],rdi
    mov     [rsp+100h],rsi
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rsp+0F0h],0
    mov     [rsp+0F8h],rax
    xchg    ax,ax
L0:
    mov     rax,[rsp+0F0h]
    mov     rdx,[rsp+0F8h]
    cmp     rax,rdx
    setb    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
    nop
L2:
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
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEFCh
    mov     edx,0FFFFFF00h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFEFCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L3:
    .long   L5
    .long   L4
    .long   L1
L4:
    mov     rax,[rsp+108h]
    mov     rax,[rax]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+100h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+108h]
    mov     rsi,[rsi+8]
    mov     rdx,[rdx]
    mov     rdi,[rsp+60h]
    add     rdi,1
    imul    rdi,rsi
    mov     qword ptr [rsp+10h],0
    mov     r9,[rsp+10h]
    sub     r9,rdi
    imul    rcx,r9,1
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
    jmp     L0
L7:
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
    jmp     L2
L8:
    mov     rax,[rsp+100h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    mov     [rsp+0D0h],rax
    cmp     rax,8
    jae     L9
    jmp     L10
L9:
    mov     rax,[rsp+0D0h]
    add     rax,1
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+10h],8
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF50h
    mov     ecx,0FFFFFF00h
    call    ryo_h_DivUW64
    imul    rax,[rsp+68h],7
    mov     [rsp+0D0h],rax
L10:
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

fn hashbrown::raw::RawTableInner::reserve_rehash_inner::<std::alloc::Global>
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+80h],r8
    mov     [rsp+77h],r9b
    mov     rax,[rsp+0C0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+98h]
    mov     rdi,[rdi+18h]
    mov     [rsp+48h],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF78h
    mov     ecx,0FFFFFF98h
    mov     r8d,0FFFFFFD8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+28h]
    mov     [rsp+37h],al
    test    byte ptr [rsp+37h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    jmp     L3
    nop
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+38h],rax
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+38h]
    mov     r8,[rsp+58h]
    call    fn0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L3
    xchg    ax,ax
L2:
    mov     rax,[rsp+50h]
    add     rax,1
    mov     [rsp+30h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+30h]
    call    fn2
    mov     [rsp+38h],rax
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+78h]
    mov     r8,[rsp+80h]
    movzx   r9d,byte ptr [rsp+77h]
    call    fn3
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rdx
L3:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    add     rsp,0B8h
    ret
L4:
    movzx   edi,byte ptr [rsp+77h]
    call    qword ptr [sym4]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    jmp     L0
L5:
    mov     rax,[rsp+48h]
    add     rax,[rsp+88h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+98h]
    mov     rsi,[rsi+8]
    mov     [rsp+50h],rsi
    cmp     rsi,8
    jae     L6
    jmp     L7
L6:
    mov     rax,[rsp+50h]
    add     rax,1
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF68h
    call    ryo_h_DivUW64
    imul    rax,[rsp+38h],7
    mov     [rsp+50h],rax
L7:
    mov     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+18h],2
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF68h
    call    ryo_h_DivUW64
    mov     rax,[rsp+38h]
    cmp     rax,[rsp+48h]
    jae     L1
    jmp     L2

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    sub     rsp,268h
    mov     [rsp+248h],rdi
    mov     [rsp+240h],rsi
    mov     [rsp+238h],rdx
    mov     [rsp+228h],rcx
    mov     [rsp+230h],r8
    mov     [rsp+227h],r9b
    mov     rax,[rsp+270h]
    mov     [rsp+210h],rax
    mov     rdx,[rsp+278h]
    mov     [rsp+218h],rdx
    lea     rdi,[rsp+80h]
    mov     rsi,[rsp+240h]
    mov     rdx,[rsp+210h]
    mov     rcx,[rsp+218h]
    mov     r8,[rsp+238h]
    movzx   r9d,byte ptr [rsp+227h]
    call    fn0
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+260h]
    call    ryo_h_Unreachable
    ud2
    nop
L1:
    lea     rax,[rsp+110h]
    mov     [rsp+0F8h],rax
    mov     rax,[rax+10h]
    mov     [rsp+0F0h],rax
    cmp     rax,0
    je      L11
    jmp     L12
L2:
    mov     rax,[rsp+108h]
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+248h]
    mov     [rsp+0D8h],rdx
    mov     [rsp+0E0h],rax
    mov     rsi,[rsp+230h]
    mov     rsi,[rsi+28h]
    mov     [rsp+30h],rsi
    mov     rax,[rsp+30h]
    mov     rdi,[rsp+228h]
    mov     rsi,[rsp+0D8h]
    mov     rdx,[rsp+0E0h]
    call    rax
    mov     [rsp+0E8h],rax
    jmp     L4
L3:
    mov     rax,[rsp+248h]
    mov     rax,[rax+18h]
    mov     rdx,[rsp+158h]
    sub     rdx,rax
    mov     [rsp+158h],rdx
    mov     rsi,[rsp+248h]
    mov     rsi,[rsi+18h]
    mov     [rsp+160h],rsi
    mov     rdi,[rsp+248h]
    mov     [rsp+128h],rdi
    lea     r8,[rsp+148h]
    mov     [rsp+120h],r8
    mov     qword ptr [rsp+8],20h
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFDB0h
    mov     edx,0FFFFFEC8h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFDA8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEC0h
    xor     edx,edx
    mov     ecx,0FFFFFDB0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    jmp     L15
L4:
    lea     rax,[rsp+148h]
    mov     [rsp+0E0h],rax
    mov     rdi,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    call    fn1
    mov     [rsp+170h],rax
    jmp     L14
    nop     [rax]
L5:
    mov     rax,[rsp+250h]
    mov     rdx,[rsp+258h]
    add     rsp,268h
    ret
    nop     [rax+rax]
L6:
    lea     rax,[rsp+130h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+30h]
    call    fn2
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFF08h
    call    ryo_h_Resume
    ud2
L7:
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFDD4h
    mov     edx,0FFFFFE20h
    xor     ecx,ecx
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFDF8h
    mov     edx,0FFFFFDD4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFDF8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L8]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L8:
    .long   L10
    .long   L9
    .long   L0
L9:
    mov     rax,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+40h],rcx
    mov     rcx,[rsp+40h]
    mov     [rsp+0B0h],rcx
    mov     qword ptr [rsp+0A0h],0
    mov     rcx,[rsp+0B0h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rax
    mov     qword ptr [rsp+88h],1
    cmp     qword ptr [rsp+88h],1
    sete    [rsp+87h]
    mov     rcx,[rsp+98h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+0D0h],rcx
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+0C0h],0
    mov     rcx,[rsp+0D0h]
    mov     [rsp+0B8h],rcx
    mov     rcx,[rsp+0B8h]
    mov     [rsp+0A8h],rcx
    mov     rcx,[rsp+0A8h]
    mov     [rsp+108h],rcx
    mov     [rsp+100h],rax
    mov     qword ptr [rsp+0F8h],0
    mov     rcx,[rsp+108h]
    mov     [rsp+0F0h],rcx
    mov     [rsp+0E8h],rax
    mov     qword ptr [rsp+0E0h],1
    cmp     qword ptr [rsp+0E0h],1
    sete    [rsp+0CFh]
    mov     rcx,[rsp+0F0h]
    mov     [rsp+0D8h],rcx
    mov     rcx,[rsp+0D8h]
    mov     [rsp+258h],rcx
    mov     [rsp+250h],rax
    jmp     L5
L10:
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFDD8h
    mov     edx,0FFFFFE20h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFDD8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE00h
    mov     edx,0FFFFFE40h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rax,[rsp+240h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+210h]
    mov     rcx,[rsp+218h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFDE8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFE00h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rax,[rsp+248h]
    mov     rax,[rax]
    mov     [rsp+108h],rax
    mov     [rsp+110h],rax
    mov     rdx,[rsp+108h]
    mov     [rsp+128h],rdx
    mov     rsi,[rsp+108h]
    mov     [rsp+118h],rsi
    mov     rdi,[rsp+108h]
    mov     [rsp+100h],rdi
    lea     rdi,[rsp+0F0h]
    mov     rsi,[rsp+100h]
    call    qword ptr [sym3]
    mov     rax,[rsp+0F0h]
    mov     rcx,[rsp+0F8h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+20h]
    call    qword ptr [sym4]
    mov     [rsp+11Ch],eax
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEC0h
    mov     edx,0FFFFFEBCh
    call    ryo_h_TruncW32W16
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+122h]
    mov     rdx,[rsp+248h]
    mov     rdx,[rdx+18h]
    mov     [rsp+208h],ax
    mov     qword ptr [rsp+1F8h],0
    mov     rdi,[rsp+108h]
    mov     [rsp+1F0h],rdi
    mov     [rsp+200h],rdx
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFF90h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L1
L11:
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L3
L12:
    mov     rdi,[rsp+0F8h]
    call    fn6
    mov     [rsp+100h],rax
    mov     [rsp+108h],rdx
    mov     rax,[rsp+0F8h]
    mov     rax,[rax+10h]
    sub     rax,1
    mov     [rsp+20h],rax
    mov     rdx,[rsp+0F8h]
    mov     rcx,[rsp+20h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+100h]
    mov     [rsp+1E8h],rsi
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFF88h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L13]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L13:
    .long   L3
    .long   L2
    .long   L0
L14:
    mov     rax,[rsp+148h]
    imul    rcx,[rsp+170h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rsp+0B7h],al
    mov     rdx,[rsp+0E8h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rsp+0D0h],rdx
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE86h
    mov     edx,0FFFFFE70h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+0E6h]
    mov     [rsp+0E7h],al
    mov     rdx,[rsp+170h]
    sub     rdx,10h
    mov     rsi,[rsp+150h]
    and     rdx,rsi
    add     rdx,10h
    mov     [rsp+0D8h],rdx
    mov     rdi,[rsp+148h]
    imul    rcx,[rsp+170h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rsp+0E7h]
    mov     [rdi],cl
    mov     r8,[rsp+148h]
    imul    rcx,[rsp+0D8h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+0E7h]
    mov     [r8],cl
    mov     r9,[rsp+210h]
    mov     [rsp+1D0h],r9
    mov     r10,[rsp+248h]
    mov     r10,[r10]
    mov     r11,[rsp+0F0h]
    add     r11,1
    imul    r11,r9
    mov     qword ptr [rsp+30h],0
    mov     rsi,[rsp+30h]
    sub     rsi,r11
    imul    rcx,rsi,1
    add     r10,rcx
    mov     [rsp+0E0h],r10
    mov     rdx,[rsp+148h]
    mov     rdi,[rsp+170h]
    add     rdi,1
    imul    rdi,r9
    mov     qword ptr [rsp+30h],0
    mov     rax,[rsp+30h]
    sub     rax,rdi
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rsp+0D8h],rdx
    imul    r11,r9,1
    mov     [rsp+30h],r11
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFDD0h
    call    ryo_h_Memcpy
    jmp     L1
L15:
    lea     rdi,[rsp+260h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+130h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+30h]
    call    fn8
    jmp     L5
    nop     [rax+rax]
L16:
    call    qword ptr [sym9]
    lea     rdi,[rsp+260h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+260h]
    mov     rsi,rax
    mov     edx,0FFFFFF08h
    call    ryo_h_Lpad
    jmp     L6
    lea     rdi,[rsp+260h]
    mov     rsi,rax
    mov     edx,0FFFFFF08h
    call    ryo_h_Lpad
    jmp     L16

fn hashbrown::raw::TableLayout::calculate_layout_for
    sub     rsp,0F8h
    mov     [rsp+90h],rdi
    mov     [rsp+0C8h],rsi
    mov     [rsp+0D0h],rdx
    mov     [rsp+0C0h],rcx
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0D0h]
    mov     [rsp+80h],rdx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+0C0h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFF30h
    mov     ecx,0FFFFFF40h
    mov     r8d,0FFFFFF20h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+18h]
    movzx   edx,byte ptr [rsp+20h]
    mov     [rsp+2Fh],dl
    mov     [rsp+8],rax
    test    byte ptr [rsp+2Fh],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
    nop
L0:
    mov     qword ptr [rsp+0D8h],0
    jmp     L2
    xchg    ax,ax
L1:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+98h]
    mov     [rsp+58h],rdx
    mov     rcx,[rsp+58h]
    mov     [rsp+68h],rcx
    mov     [rsp+60h],rax
    mov     rsi,[rsp+78h]
    mov     [rsp+70h],rsi
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFF70h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L3
    nop     [rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFA0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+90h]
    add     rsp,0F8h
    ret
L4:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+40h],0
    cmp     qword ptr [rsp+40h],0
    sete    [rsp+3Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L3
L5:
    mov     rax,[rsp+8]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],1
    mov     qword ptr [rsp+48h],0
    mov     [rsp+0B0h],rax
    mov     rdi,[rsp+80h]
    sub     rdi,1
    mov     [rsp+0A8h],rdi
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF48h
    mov     ecx,0FFFFFFC0h
    mov     r8d,0FFFFFFB8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+38h]
    mov     [rsp+47h],al
    test    byte ptr [rsp+47h],0FFh
    je      L6
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+60h],0
    cmp     qword ptr [rsp+60h],0
    sete    [rsp+5Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L3
L6:
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
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFF50h
    mov     ecx,0FFFFFF88h
    mov     r8d,0FFFFFF60h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+40h]
    mov     [rsp+4Fh],al
    test    byte ptr [rsp+4Fh],0FFh
    je      L7
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+60h],0
    cmp     qword ptr [rsp+60h],0
    sete    [rsp+5Fh]
    mov     qword ptr [rsp+0D8h],0
    jmp     L2
L7:
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
    jb      L0
    jmp     L1

fn hashbrown::raw::capacity_to_buckets
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],rdx
    cmp     qword ptr [rsp+0B8h],0Fh
    jae     L9
    mov     rdx,[rsp+0A8h]
    mov     [rsp+80h],rdx
    mov     qword ptr [rsp+10h],0
    mov     rdi,[rsp+10h]
    cmp     rdi,rdx
    setbe   [rsp+7Dh]
    test    byte ptr [rsp+7Dh],0FFh
    je      L2
    jmp     L3
    nop     [rax]
L0:
    mov     qword ptr [rsp+88h],3
    jmp     L5
    xchg    ax,ax
L1:
    mov     qword ptr [rsp+88h],0Eh
    jmp     L5
    xchg    ax,ax
L2:
    mov     qword ptr [rsp+10h],2
    mov     rdx,[rsp+10h]
    cmp     rdx,[rsp+80h]
    setbe   [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    je      L0
    cmp     qword ptr [rsp+80h],3
    jbe     L4
    jmp     L0
L3:
    cmp     qword ptr [rsp+80h],1
    jbe     L1
    jmp     L2
L4:
    mov     qword ptr [rsp+88h],7
L5:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0B8h]
    call    fn0
    mov     [rsp+58h],rax
    cmp     qword ptr [rsp+58h],4
    jae     L6
    mov     qword ptr [rsp+70h],4
    jmp     L8
L6:
    cmp     qword ptr [rsp+58h],8
    jae     L7
    mov     qword ptr [rsp+70h],8
    jmp     L8
L7:
    mov     qword ptr [rsp+70h],10h
L8:
    mov     rax,[rsp+0B0h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    cmp     qword ptr [rsp+80h],0
    je      L12
    jmp     L11
L9:
    mov     rax,[rsp+0B8h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+10h],8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF58h
    mov     ecx,0FFFFFF68h
    mov     r8d,0FFFFFF40h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+20h]
    movzx   edx,byte ptr [rsp+28h]
    mov     [rsp+37h],dl
    mov     [rsp+18h],rax
    test    byte ptr [rsp+37h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L10:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    add     rsp,0D8h
    ret
L11:
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF70h
    mov     ecx,0FFFFFF78h
    mov     r8d,0FFFFFF60h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+38h]
    movzx   edx,byte ptr [rsp+40h]
    mov     [rsp+66h],dl
    mov     [rsp+28h],rax
    test    byte ptr [rsp+66h],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L12:
    mov     rax,[rsp+70h]
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+0C0h],1
    jmp     L10
L13:
    mov     qword ptr [rsp+28h],0FFFFFFFFFFFFFFFFh
    jmp     L12
L14:
    jmp     L12
L15:
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
    jmp     L10
L16:
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
    jbe     L19
    jmp     L20
    nop     [rax+rax]
L17:
    mov     rax,[rsp+40h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+18h],rsi
    cmp     rdx,0
    je      L22
    jmp     L21
    nop     [rax+rax]
    nop     [rax]
L18:
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF78h
    mov     ecx,0FFFFFF80h
    mov     r8d,0FFFFFF40h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+48h],0FFh
    je      L17
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    call    qword ptr [sym4]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L19:
    mov     qword ptr [rsp+50h],0
    jmp     L18
L20:
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
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF64h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF40h
    mov     ecx,0FFFFFF38h
    call    ryo_h_ShrUW64
    jmp     L18
L21:
    mov     rax,[rsp+20h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF70h
    mov     ecx,0FFFFFF80h
    mov     r8d,0FFFFFF60h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+38h]
    movzx   edx,byte ptr [rsp+40h]
    mov     [rsp+4Fh],dl
    mov     [rsp+28h],rax
    test    byte ptr [rsp+4Fh],0FFh
    je      L24
    jmp     L23
L22:
    mov     rax,[rsp+58h]
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+0C0h],1
    jmp     L10
L23:
    mov     qword ptr [rsp+28h],0FFFFFFFFFFFFFFFFh
    jmp     L22
L24:
    jmp     L22

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
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
    jmp     L6
    nop     [rax]
L0:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF44h
    mov     edx,0FFFFFF90h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF44h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     rcx,[rsp+40h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+98h],0FFFFFFFFFFFFFFFFh
    lea     rdi,[rsp+78h]
    mov     [rsp],rdi
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
    jmp     L7
    nop     [rax]
L4:
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
L5:
    lea     rax,[rsp+78h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn3
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rsp+90h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+78h]
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+40h]
    call    fn4
    mov     [rsp+50h],rax
    jmp     L0
L7:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+90h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF58h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF70h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L4
L8:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax]
L9:
    call    qword ptr [sym5]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L9

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
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

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
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
    jmp     L6
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFFB0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+60h]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
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
    jmp     L7
    nop     [rax+rax]
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
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    call    fn2
    mov     [rsp+30h],rax
    jmp     L0
L7:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+38h]
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rax
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA0h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L4
L8:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
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

fn main
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
L0:
    lea     rax,[rsp+4F0h]
    mov     [rsp+4D8h],rax
    mov     rdi,[rsp+4D8h]
    call    fn3
    mov     [rsp+4E0h],rax
    mov     [rsp+4E8h],rdx
    mov     rax,[rsp+4E0h]
    mov     [rsp+4D0h],rax
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFF70h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L1:
    .long   L4
    .long   L3
    .long   L2
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
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
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym6]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
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
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym9]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+478h]
    shr     rax,2Ch
    mov     [rsp+480h],rax
    lea     rdi,[rsp+490h]
    mov     rsi,[rsp+488h]
    mov     rdx,[rsp+480h]
    call    fn10
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFF30h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     qword ptr [rsp+10h],0
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn11
    mov     [rsp+4A8h],rax
    mov     rax,[rsp+4A8h]
    mov     rax,[rax]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFF08h
    mov     ecx,0FFFFFAC8h
    mov     r8d,0FFFFFF68h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+468h],0FFh
    je      L7
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym13]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+4A8h]
    mov     rcx,[rsp+460h]
    mov     [rax],rcx
    jmp     L0
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
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAB0h
    mov     edx,0FFFFFEB0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+430h]
    lea     rsi,[rsp+10h]
    call    fn15
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFED0h
    mov     ecx,20h
    call    ryo_h_Copy
    nop     [rax]
L9:
    lea     rax,[rsp+3D0h]
    mov     [rsp+3B8h],rax
    mov     rdi,[rsp+3B8h]
    call    fn16
    mov     [rsp+3C0h],rax
    mov     [rsp+3C8h],rdx
    mov     rax,[rsp+3C0h]
    mov     [rsp+3B0h],rax
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFE50h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L10]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L10:
    .long   L12
    .long   L11
    .long   L2
L11:
    mov     rax,[rsp+3C8h]
    mov     [rsp+3A8h],rax
    lea     rdx,[rsp+528h]
    mov     [rsp+398h],rdx
    lea     rsi,[rsp+3A8h]
    mov     [rsp+390h],rsi
    mov     rdi,[rsp+398h]
    mov     rsi,[rsp+390h]
    call    fn17
    mov     [rsp+3A0h],rax
    jmp     L13
L12:
    lea     rax,[rsp+528h]
    mov     [rsp+348h],rax
    mov     rdi,[rsp+348h]
    call    fn18
    mov     [rsp+350h],rax
    jmp     L17
L13:
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFACCh
    mov     edx,0FFFFFE40h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFACCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFE28h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L14]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L14:
    .long   L9
    .long   L15
    .long   L2
L15:
    mov     rax,[rsp+3A0h]
    mov     [rsp+380h],rax
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFE18h
    mov     ecx,0FFFFFEF8h
    mov     r8d,0FFFFFAC8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+378h],0FFh
    je      L16
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym20]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
L16:
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
L17:
    lea     rax,[rsp+528h]
    mov     [rsp+340h],rax
    mov     rdi,[rsp+340h]
    call    fn22
    lea     rax,[rsp+528h]
    mov     [rsp+308h],rax
    lea     rdi,[rsp+310h]
    mov     rsi,[rsp+308h]
    call    fn23
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFDB0h
    mov     ecx,28h
    call    ryo_h_Copy
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
L18:
    lea     rax,[rsp+2C0h]
    mov     [rsp+2B0h],rax
    mov     rdi,[rsp+2B0h]
    call    fn27
    mov     [rsp+2B8h],eax
    mov     [rsp+2BCh],edx
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFD48h
    mov     edx,0FFFFFD58h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFD48h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L19]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L19:
    .long   L21
    .long   L20
    .long   L2
L20:
    mov     eax,[rsp+2BCh]
    mov     [rsp+2A4h],eax
    lea     rdx,[rsp+2D8h]
    mov     [rsp+268h],rdx
    mov     dword ptr [rsp+2Ch],138Bh
    cmp     dword ptr [rsp+2Ch],0
    sete    [rsp+213h]
    test    byte ptr [rsp+213h],0FFh
    je      L22
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k28]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym29]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
L21:
    lea     rax,[rsp+528h]
    mov     [rsp+178h],rax
    mov     rdi,[rsp+178h]
    call    fn30
    mov     [rsp+180h],rax
    jmp     L24
L22:
    mov     dword ptr [rsp+2Ch],138Bh
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFFD44h
    mov     ecx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rsp+214h]
    mov     [rsp+68h],rax
    lea     rdi,[rsp+1F0h]
    mov     rsi,[rsp+68h]
    call    fn31
    mov     rax,[rsp+1F0h]
    mov     rcx,[rsp+1F8h]
    mov     [rsp+208h],rcx
    mov     [rsp+200h],rax
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFC88h
    lea     rdx,[k32]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+200h]
    mov     [rsp+1E0h],rax
    mov     rdi,[rsp+1E8h]
    mov     rsi,[rsp+1E0h]
    call    fn33
    mov     [rsp+228h],rax
    mov     [rsp+230h],rdx
    lea     rdi,[rsp+238h]
    mov     rsi,[rsp+228h]
    mov     rdx,[rsp+230h]
    call    fn34
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCD8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+250h]
    lea     rsi,[rsp+18h]
    call    fn35
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCF0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+270h]
    mov     rsi,[rsp+268h]
    lea     rdx,[rsp+18h]
    call    fn36
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFD10h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+8]
    call    fn37
    mov     [rsp+298h],rax
    mov     rax,[rsp+298h]
    mov     rax,[rax]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFC70h
    mov     edx,0FFFFFC78h
    mov     ecx,0FFFFFAC8h
    mov     r8d,0FFFFFAC0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+1D8h],0FFh
    je      L23
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k38]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    call    qword ptr [sym39]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
L23:
    mov     rax,[rsp+298h]
    mov     rcx,[rsp+1D0h]
    mov     [rax],rcx
    jmp     L18
L24:
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
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFB18h
    lea     rdx,[k47]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+0E0h]
    mov     [rsp+70h],rax
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
L25:
    lea     rax,[rsp+2D8h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn52
    nop     [rax+rax]
L26:
    lea     rax,[rsp+528h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn53
    lea     rdi,[rsp+560h]
    mov     esi,0FFFFFAD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L27:
    call    qword ptr [sym54]
    lea     rdi,[rsp+560h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L26
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L25
    lea     rdi,[rsp+560h]
    mov     rsi,rax
    mov     edx,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L27

fn main::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+10h],3
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
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

fn main::{closure#1}
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

fn std::alloc::Global::alloc_impl_runtime
    sub     rsp,0B8h
    mov     [rsp+90h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+8Fh],dl
    mov     rax,[rsp+98h]
    mov     [rsp+38h],rax
    cmp     rax,0
    je      L0
    test    byte ptr [rsp+8Fh],0FFh
    je      L2
    jmp     L1
L0:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+10h],rdx
    mov     qword ptr [rsp+18h],0
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L6
    jmp     L5
L1:
    call    qword ptr [sym0]
    jmp     L7
L2:
    call    qword ptr [sym1]
    jmp     L8
    nop     [rax+rax]
L3:
    mov     rax,[rsp+70h]
    cmp     rax,0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L10
    jmp     L9
    xchg    ax,ax
L4:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    add     rsp,0B8h
    ret
L5:
    mov     rax,[rsp+60h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn3
L6:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    jmp     L4
L7:
    mov     rax,[rsp+90h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym4]
    mov     [rsp+70h],rax
    jmp     L3
L8:
    mov     rax,[rsp+90h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym5]
    mov     [rsp+70h],rax
    jmp     L3
L9:
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
    jmp     L4
L10:
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L11
    mov     rsi,[rsp+70h]
    mov     [rsp+8],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn8
L11:
    mov     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     [rsp+68h],rax
    mov     [rsp+18h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L12
    mov     r8,[rsp+68h]
    mov     [rsp+10h],r8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp]
    call    fn10
L12:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    jmp     L4

fn std::arch::x86_64::__m128i::as_i8x16
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

fn std::char::encode_utf8_raw
    sub     rsp,88h
    mov     [rsp+6Ch],edi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    cmp     dword ptr [rsp+6Ch],80h
    jb      L6
    jmp     L3
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     edi,[rsp+6Ch]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp+18h]
    call    fn1
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L1:
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
    je      L8
    jmp     L7
    nop     [rax+rax]
L2:
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    cmp     rax,rdx
    jb      L0
    jmp     L1
L3:
    cmp     dword ptr [rsp+6Ch],800h
    jb      L5
    cmp     dword ptr [rsp+6Ch],10000h
    jb      L4
    mov     qword ptr [rsp+50h],4
    jmp     L2
L4:
    mov     qword ptr [rsp+50h],3
    jmp     L2
L5:
    mov     qword ptr [rsp+50h],2
    jmp     L2
L6:
    mov     qword ptr [rsp+50h],1
    jmp     L2
L7:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+50h]
    mov     r8,[rsp+8]
    call    fn4
L8:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+50h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret

fn std::char::encode_utf8_raw::do_panic::runtime
    sub     rsp,0E8h
    mov     [rsp+0DCh],edi
    mov     [rsp+0D0h],rsi
    mov     [rsp+0C8h],rdx
    mov     [rsp+8],rcx
    lea     rax,[rsp+0D0h]
    lea     rdx,[rsp+0DCh]
    mov     [rsp+0B8h],rdx
    lea     rsi,[rsp+0C8h]
    mov     [rsp+0B0h],rsi
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+48h]
    mov     [rsp+58h],rax
    mov     rcx,[rsp+58h]
    mov     [rsp+68h],rcx
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+38h]
    mov     [rsp+48h],rax
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF38h
    lea     rdx,[sym2]
    call    ryo_h_AddrSym
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+28h]
    mov     [rsp+38h],rax
    mov     rcx,[rsp+38h]
    mov     [rsp+48h],rcx
    mov     rsi,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rsi
    mov     rdi,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rdi
    mov     rcx,[rsp+48h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rdx
    lea     r8,[rsp+70h]
    mov     [rsp+68h],r8
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+60h]
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rax
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2

fn std::char::encode_utf8_raw_unchecked
    sub     rsp,38h
    mov     [rsp+2Ch],edi
    mov     [rsp+20h],rsi
    cmp     dword ptr [rsp+2Ch],80h
    jb      L7
    jmp     L4
L0:
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
    jmp     L3
    nop     [rax+rax]
L1:
    cmp     qword ptr [rsp+18h],3
    jne     L2
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
    jmp     L3
L2:
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
    jmp     L3
    xchg    ax,ax
L3:
    add     rsp,38h
    ret
L4:
    cmp     dword ptr [rsp+2Ch],800h
    jb      L6
    cmp     dword ptr [rsp+2Ch],10000h
    jb      L5
    mov     qword ptr [rsp+18h],4
    jmp     L8
L5:
    mov     qword ptr [rsp+18h],3
    jmp     L8
L6:
    mov     qword ptr [rsp+18h],2
    jmp     L8
L7:
    mov     qword ptr [rsp+18h],1
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFFCh
    call    ryo_h_TruncW32W8
    mov     rax,[rsp+20h]
    movzx   ecx,byte ptr [rsp]
    mov     [rax],cl
    jmp     L3
L8:
    mov     eax,[rsp+2Ch]
    and     eax,3Fh
    mov     [rsp+10h],eax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE6h
    mov     edx,0FFFFFFE0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rsp+16h]
    or      al,80h
    mov     [rsp+17h],al
    mov     edx,[rsp+2Ch]
    shr     edx,6
    and     edx,3Fh
    mov     [rsp+10h],edx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE5h
    mov     edx,0FFFFFFE0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rsp+15h]
    or      al,80h
    mov     [rsp+16h],al
    mov     edx,[rsp+2Ch]
    shr     edx,0Ch
    and     edx,3Fh
    mov     [rsp+10h],edx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE4h
    mov     edx,0FFFFFFE0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rsp+14h]
    or      al,80h
    mov     [rsp+15h],al
    mov     edx,[rsp+2Ch]
    shr     edx,12h
    and     edx,3Fh
    mov     [rsp+0Ch],edx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE3h
    mov     edx,0FFFFFFDCh
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rsp+13h]
    or      al,0F0h
    mov     [rsp+14h],al
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    cmp     rdx,2
    je      L0
    jmp     L1

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
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

fn std::collections::HashMap::<std::string::String, usize>::entry
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
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+78h]
    mov     rsi,[rsp+70h]
    lea     rdx,[rsp]
    call    fn0
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF24h
    mov     edx,0FFFFFF88h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF24h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF80h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L4
    .long   L3
    .long   L2
L1:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+0A0h]
    add     rsp,0F8h
    ret
L2:
    lea     rdi,[rsp+0F0h]
    call    ryo_h_Unreachable
    ud2
L3:
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF88h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF58h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF30h
    mov     ecx,28h
    call    ryo_h_Copy
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

fn std::collections::HashMap::<std::string::String, usize>::len
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     rax,[rax+18h]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::collections::HashMap::<std::string::String, usize>::new
    sub     rsp,0A8h
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
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
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF68h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    mov     ecx,30h
    call    ryo_h_Copy
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD0h
    mov     r8d,30h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+68h]
    add     rsp,0A8h
    ret

fn std::collections::HashMap::<u64, u64>::entry
    sub     rsp,98h
    mov     [rsp+60h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+68h]
    call    fn0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF7Ch
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF7Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L4
    .long   L3
    .long   L2
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+60h]
    add     rsp,98h
    ret
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF98h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFF80h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L1
L4:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+28h],rcx
    mov     rcx,[rsp+28h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+78h],0
    jmp     L1

fn std::collections::HashMap::<u64, u64>::get::<u64>
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

fn std::collections::HashMap::<u64, u64>::len
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     rax,[rax+18h]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::collections::HashMap::<u64, u64>::new
    sub     rsp,0A8h
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
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
    mov     [rsp+48h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF68h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    mov     ecx,30h
    call    ryo_h_Copy
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD0h
    mov     r8d,30h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+68h]
    add     rsp,0A8h
    ret

fn std::collections::HashMap::<u64, u64>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::collections::HashMap::<u64, u64>::values
    sub     rsp,98h
    mov     [rsp+58h],rdi
    mov     [rsp+60h],rsi
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    lea     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF78h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFD8h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+58h]
    add     rsp,98h
    ret

fn std::collections::hash_map::Entry::<'_, std::string::String, usize>::or_default
    sub     rsp,138h
    mov     [rsp+28h],rdi
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFEF8h
    xor     ecx,ecx
    mov     r8d,28h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF4h
    mov     edx,0FFFFFFD0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFEF4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFD0h
    mov     ecx,28h
    call    ryo_h_Copy
    mov     byte ptr [rsp+0F7h],1
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF80h
    mov     ecx,28h
    call    ryo_h_Copy
    call    fn0
    mov     [rsp+80h],rax
    jmp     L4
L3:
    mov     rax,[rsp+108h]
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+110h]
    mov     [rsp+0B8h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L11
    jmp     L10
L4:
    mov     byte ptr [rsp+0F7h],0
    mov     rdx,[rsp+0A8h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF58h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+0A0h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFF08h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+80h]
    mov     [rsp+70h],rax
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED8h
    mov     edx,0FFFFFF28h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+50h]
    lea     rdx,[rsp+8]
    call    fn1
    mov     [rsp+78h],rax
    jmp     L15
    nop     [rax+rax]
L5:
    mov     rax,[rsp+128h]
    add     rsp,138h
    ret
L6:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFA8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L7:
    lea     rax,[rsp+88h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn2
    jmp     L6
    nop     [rax]
L8:
    test    byte ptr [rsp+0F7h],0FFh
    je      L6
    jmp     L7
    nop     [rax]
L9:
    mov     rax,[rsp+0C8h]
    lea     rax,[rax+18h]
    mov     [rsp+128h],rax
    jmp     L5
L10:
    mov     qword ptr [rsp+0C8h],8
    jmp     L9
L11:
    mov     rax,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    jmp     L9
L13:
    mov     rax,[rsp+0C0h]
    mov     [rsp+0C8h],rax
    jmp     L12
L14:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+20h],20h
    add     rdx,rcx
    mov     [rsp+0C8h],rdx
    jmp     L12
L15:
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L16:
    mov     rax,[rsp+68h]
    lea     rax,[rax+18h]
    mov     [rsp+128h],rax
    jmp     L5
L17:
    mov     qword ptr [rsp+68h],8
    jmp     L16
L18:
    mov     rax,[rsp+78h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L19:
    jmp     L16
L20:
    mov     rax,[rsp+60h]
    mov     [rsp+68h],rax
    jmp     L19
L21:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+20h],20h
    add     rdx,rcx
    mov     [rsp+68h],rdx
    jmp     L19
    nop     [rax]
L22:
    call    qword ptr [sym3]
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+130h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L8
    lea     rdi,[rsp+130h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L22

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    sub     rsp,0B8h
    mov     [rsp+10h],rdi
    mov     [rsp+88h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF60h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF5Ch
    mov     edx,0FFFFFFE0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L2:
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
    jmp     L8
L3:
    mov     rax,[rsp+98h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+40h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L17
    jmp     L16
    nop
L4:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+7Fh],0FFh
    je      L5
    jmp     L6
L8:
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
L9:
    mov     rax,[rsp+40h]
    lea     rax,[rax+8]
    mov     [rsp+0A8h],rax
    jmp     L4
L10:
    mov     qword ptr [rsp+40h],8
    jmp     L9
L11:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
    nop
L12:
    jmp     L9
L13:
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    jmp     L12
L14:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L12
    nop     [rax]
L15:
    mov     rax,[rsp+50h]
    lea     rax,[rax+8]
    mov     [rsp+0A8h],rax
    jmp     L4
L16:
    mov     qword ptr [rsp+50h],8
    jmp     L15
L17:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L18:
    jmp     L15
L19:
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L18
L20:
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+8],10h
    add     rdx,rcx
    mov     [rsp+50h],rdx
    jmp     L18
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L7

fn std::fmt::Arguments::<'_>::as_statically_known_str
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     rax,[rsp+78h]
    mov     rax,[rax+8]
    mov     [rsp+68h],rax
    and     rax,1
    mov     [rsp+60h],rax
    cmp     rax,1
    je      L3
    jmp     L4
    nop     [rax+rax]
L0:
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L2:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L3:
    mov     rax,[rsp+78h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+68h]
    shr     rdx,1
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L7
    jmp     L6
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFFF0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+60h],1
    sete    [rsp+6Eh]
    movzx   edx,byte ptr [rsp+6Eh]
    mov     [rsp],dl
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L0
L6:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],1
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+8]
    call    fn4
L7:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+30h]
    mov     [rsp+48h],rdx
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    jmp     L5

fn std::fmt::Arguments::<'_>::new::<4, 1>
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

fn std::fmt::Arguments::<'_>::new::<59, 6>
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

fn std::fmt::format
    sub     rsp,0B8h
    mov     [rsp+78h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    and     rax,1
    mov     [rsp+58h],rax
    cmp     rax,1
    je      L1
    jmp     L2
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+78h]
    add     rsp,0B8h
    ret
L1:
    mov     rax,[rsp+88h]
    mov     [rsp+30h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+60h]
    shr     rdx,1
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L5
    jmp     L4
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    nop     [rax]
L3:
    lea     rax,[rsp+88h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+98h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+60h]
    call    fn1
    jmp     L0
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+28h]
    mov     r8,[rsp]
    call    fn3
L5:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+28h]
    mov     [rsp+40h],rdx
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+70h],rcx
    mov     [rsp+68h],rax
    jmp     L3

fn std::fmt::format::{closure#0}
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

fn std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn
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

fn std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}
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

fn std::hash::RandomState::new::{closure#0}
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

fn std::hint::assert_unchecked::precondition_check
    sub     rsp,88h
    mov     [rsp+7Fh],dil
    mov     [rsp+18h],rsi
    test    byte ptr [rsp+7Fh],0FFh
    jne     L0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+70h],0DDh
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0DDh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,88h
    ret

fn std::hint::black_box::<u64>
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::hint::must_use::<std::string::String>
    sub     rsp,48h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,48h
    ret

fn std::hint::unreachable_unchecked::precondition_check
    sub     rsp,78h
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],0C7h
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],0C7h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2

fn std::intrinsics::cold_path
    sub     rsp,8
    add     rsp,8
    ret

fn std::intrinsics::is_val_statically_known::<bool>
    sub     rsp,18h
    mov     [rsp+0Eh],dil
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn std::intrinsics::rotate_left::<u64>
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+3Ch],esi
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD4h
    mov     edx,0FFFFFFC8h
    call    ryo_h_TruncW64W32
    imul    eax,[rsp+24h],8
    mov     [rsp+28h],eax
    cmp     eax,0
    jne     L0
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
L0:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFECh
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW32
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFDCh
    call    ryo_h_ZextW32W64
    mov     qword ptr [rsp+10h],3Fh
    mov     rdx,[rsp+10h]
    sub     rdx,[rsp+18h]
    mov     [rsp+10h],rdx
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
L1:
    call    qword ptr [sym2]
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1

fn std::intrinsics::typed_swap_nonoverlapping::<hashbrown::raw::RawTableInner>
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    call    fn1
    add     rsp,38h
    ret
    nop     [rax+rax]
L0:
    call    qword ptr [sym2]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn std::io::Error::is_interrupted
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn0
    jmp     L6
    nop     [rax]
L0:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    movzx   eax,byte ptr [rax+10h]
    mov     [rsp+0Fh],al
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF8Fh
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rsp+20h],23h
    sete    [rsp+7Fh]
    jmp     L5
L2:
    movzx   eax,byte ptr [rsp+29h]
    mov     [rsp+27h],al
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFFA7h
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rsp+18h],23h
    sete    [rsp+7Fh]
    jmp     L5
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+58h],rax
    movzx   eax,byte ptr [rax+20h]
    mov     [rsp+0Fh],al
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF8Fh
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rsp+20h],23h
    sete    [rsp+7Fh]
    jmp     L5
L4:
    mov     eax,[rsp+2Ch]
    mov     [rsp+24h],eax
    call    qword ptr [sym1]
    mov     [rsp+18h],rax
    jmp     L8
    nop     [rax]
L5:
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
L6:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_ZextW8W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L7]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L7:
    .long   L4
    .long   L2
    .long   L1
    .long   L3
    .long   L0
L8:
    mov     rax,[rsp+18h]
    mov     rax,[rax+10h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     edi,[rsp+24h]
    call    rax
    mov     [rsp+7Fh],al
    jmp     L5

fn std::io::ErrorKind::from_prim
    sub     rsp,178h
    mov     [rsp+168h],edi
    cmp     dword ptr [rsp+168h],0
    jne     L0
    mov     byte ptr [rsp+16Fh],0
    jmp     L44
L0:
    cmp     dword ptr [rsp+168h],1
    jne     L1
    mov     byte ptr [rsp+16Fh],1
    jmp     L44
L1:
    cmp     dword ptr [rsp+168h],2
    jne     L2
    mov     byte ptr [rsp+16Fh],2
    jmp     L44
L2:
    cmp     dword ptr [rsp+168h],3
    jne     L3
    mov     byte ptr [rsp+16Fh],3
    jmp     L44
L3:
    cmp     dword ptr [rsp+168h],4
    jne     L4
    mov     byte ptr [rsp+16Fh],4
    jmp     L44
L4:
    cmp     dword ptr [rsp+168h],5
    jne     L5
    mov     byte ptr [rsp+16Fh],5
    jmp     L44
L5:
    cmp     dword ptr [rsp+168h],6
    jne     L6
    mov     byte ptr [rsp+16Fh],6
    jmp     L44
L6:
    cmp     dword ptr [rsp+168h],7
    jne     L7
    mov     byte ptr [rsp+16Fh],7
    jmp     L44
L7:
    cmp     dword ptr [rsp+168h],8
    jne     L8
    mov     byte ptr [rsp+16Fh],8
    jmp     L44
L8:
    cmp     dword ptr [rsp+168h],9
    jne     L9
    mov     byte ptr [rsp+16Fh],9
    jmp     L44
L9:
    cmp     dword ptr [rsp+168h],0Ah
    jne     L10
    mov     byte ptr [rsp+16Fh],0Ah
    jmp     L44
L10:
    cmp     dword ptr [rsp+168h],0Bh
    jne     L11
    mov     byte ptr [rsp+16Fh],0Bh
    jmp     L44
L11:
    cmp     dword ptr [rsp+168h],0Ch
    jne     L12
    mov     byte ptr [rsp+16Fh],0Ch
    jmp     L44
L12:
    cmp     dword ptr [rsp+168h],0Dh
    jne     L13
    mov     byte ptr [rsp+16Fh],0Dh
    jmp     L44
L13:
    cmp     dword ptr [rsp+168h],0Eh
    jne     L14
    mov     byte ptr [rsp+16Fh],0Eh
    jmp     L44
L14:
    cmp     dword ptr [rsp+168h],0Fh
    jne     L15
    mov     byte ptr [rsp+16Fh],0Fh
    jmp     L44
L15:
    cmp     dword ptr [rsp+168h],10h
    jne     L16
    mov     byte ptr [rsp+16Fh],10h
    jmp     L44
L16:
    cmp     dword ptr [rsp+168h],11h
    jne     L17
    mov     byte ptr [rsp+16Fh],11h
    jmp     L44
L17:
    cmp     dword ptr [rsp+168h],12h
    jne     L18
    mov     byte ptr [rsp+16Fh],12h
    jmp     L44
L18:
    cmp     dword ptr [rsp+168h],13h
    jne     L19
    mov     byte ptr [rsp+16Fh],13h
    jmp     L44
L19:
    cmp     dword ptr [rsp+168h],14h
    jne     L20
    mov     byte ptr [rsp+16Fh],14h
    jmp     L44
L20:
    cmp     dword ptr [rsp+168h],15h
    jne     L21
    mov     byte ptr [rsp+16Fh],15h
    jmp     L44
L21:
    cmp     dword ptr [rsp+168h],16h
    jne     L22
    mov     byte ptr [rsp+16Fh],16h
    jmp     L44
L22:
    cmp     dword ptr [rsp+168h],17h
    jne     L23
    mov     byte ptr [rsp+16Fh],17h
    jmp     L44
L23:
    cmp     dword ptr [rsp+168h],18h
    jne     L24
    mov     byte ptr [rsp+16Fh],18h
    jmp     L44
L24:
    cmp     dword ptr [rsp+168h],19h
    jne     L25
    mov     byte ptr [rsp+16Fh],19h
    jmp     L44
L25:
    cmp     dword ptr [rsp+168h],1Ah
    jne     L26
    mov     byte ptr [rsp+16Fh],1Ah
    jmp     L44
L26:
    cmp     dword ptr [rsp+168h],1Bh
    jne     L27
    mov     byte ptr [rsp+16Fh],1Bh
    jmp     L44
L27:
    cmp     dword ptr [rsp+168h],1Ch
    jne     L28
    mov     byte ptr [rsp+16Fh],1Ch
    jmp     L44
L28:
    cmp     dword ptr [rsp+168h],1Dh
    jne     L29
    mov     byte ptr [rsp+16Fh],1Dh
    jmp     L44
L29:
    cmp     dword ptr [rsp+168h],1Eh
    jne     L30
    mov     byte ptr [rsp+16Fh],1Eh
    jmp     L44
L30:
    cmp     dword ptr [rsp+168h],1Fh
    jne     L31
    mov     byte ptr [rsp+16Fh],1Fh
    jmp     L44
L31:
    cmp     dword ptr [rsp+168h],20h
    jne     L32
    mov     byte ptr [rsp+16Fh],20h
    jmp     L44
L32:
    cmp     dword ptr [rsp+168h],21h
    jne     L33
    mov     byte ptr [rsp+16Fh],21h
    jmp     L44
L33:
    cmp     dword ptr [rsp+168h],22h
    jne     L34
    mov     byte ptr [rsp+16Fh],22h
    jmp     L44
L34:
    cmp     dword ptr [rsp+168h],23h
    jne     L35
    mov     byte ptr [rsp+16Fh],23h
    jmp     L44
L35:
    cmp     dword ptr [rsp+168h],2Ah
    jne     L36
    mov     byte ptr [rsp+16Fh],2Ah
    jmp     L44
L36:
    cmp     dword ptr [rsp+168h],25h
    jne     L37
    mov     byte ptr [rsp+16Fh],25h
    jmp     L44
L37:
    cmp     dword ptr [rsp+168h],24h
    jne     L38
    mov     byte ptr [rsp+16Fh],24h
    jmp     L44
L38:
    cmp     dword ptr [rsp+168h],26h
    jne     L39
    mov     byte ptr [rsp+16Fh],26h
    jmp     L44
L39:
    cmp     dword ptr [rsp+168h],27h
    jne     L40
    mov     byte ptr [rsp+16Fh],27h
    jmp     L44
L40:
    cmp     dword ptr [rsp+168h],28h
    jne     L41
    mov     byte ptr [rsp+16Fh],28h
    jmp     L44
L41:
    cmp     dword ptr [rsp+168h],29h
    jne     L42
    mov     byte ptr [rsp+16Fh],29h
    jmp     L44
L42:
    cmp     dword ptr [rsp+168h],2Bh
    jne     L43
    mov     byte ptr [rsp+16Fh],2Bh
    jmp     L44
L43:
    mov     byte ptr [rsp+16Fh],0FFh
L44:
    movzx   eax,byte ptr [rsp+16Fh]
    add     rsp,178h
    ret

fn std::iter::StepBy::<std::ops::Range<u64>>::new
    sub     rsp,98h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+58h],rcx
    mov     byte ptr [rsp+57h],1
    cmp     qword ptr [rsp+58h],0
    je      L0
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
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+18h],1Bh
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym3]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L1:
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
    nop     [rax]
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+57h],0FFh
    je      L2
    jmp     L3
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L4

fn std::iter::StepBy::<std::ops::Range<usize>>::new
    sub     rsp,98h
    mov     [rsp+40h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+58h],rcx
    mov     byte ptr [rsp+57h],1
    cmp     qword ptr [rsp+58h],0
    je      L0
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
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+18h],1Bh
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym3]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L1:
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
    nop     [rax]
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+57h],0FFh
    je      L2
    jmp     L3
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L4

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<u64>> for std::ops::Range<u64>>::setup
    sub     rsp,98h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+68h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+78h]
    mov     [rsp+10h],r8
    cmp     r8,rdi
    jae     L2
    jmp     L3
L0:
    mov     qword ptr [rsp+28h],0
    nop     [rax+rax]
    nop     [rax]
L1:
    cmp     qword ptr [rsp+68h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L5
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp]
    call    qword ptr [sym1]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+10h]
    sub     rax,[rsp+18h]
    mov     [rsp+28h],rax
    jmp     L4
L3:
    mov     qword ptr [rsp+28h],0
L4:
    jmp     L1
L5:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp]
    call    qword ptr [sym3]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L6:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+10h],0
    jbe     L7
    mov     rdx,[rsp+20h]
    add     rdx,1
    mov     [rsp+58h],rdx
    jmp     L8
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+58h],rax
L8:
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

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<usize>> for std::ops::Range<usize>>::setup
    sub     rsp,98h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+68h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+78h]
    mov     [rsp+10h],r8
    cmp     r8,rdi
    jae     L2
    jmp     L3
L0:
    mov     qword ptr [rsp+28h],0
    nop     [rax+rax]
    nop     [rax]
L1:
    cmp     qword ptr [rsp+68h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L5
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+10h]
    sub     rax,[rsp+18h]
    mov     [rsp+28h],rax
    jmp     L4
L3:
    mov     qword ptr [rsp+28h],0
L4:
    jmp     L1
L5:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym3]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L6:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFFD8h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+10h],0
    jbe     L7
    mov     rdx,[rsp+20h]
    add     rdx,1
    mov     [rsp+58h],rdx
    jmp     L8
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+58h],rax
L8:
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

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next
    sub     rsp,78h
    mov     [rsp+58h],rdi
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rsp+18h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L5
    .long   L6
    .long   L4
    nop     [rax+rax]
    nop     [rax]
L1:
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
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L3:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L4:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L5:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    fn2
    jmp     L4
L6:
    mov     rax,[rsp+18h]
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+38h],0
    mov     rsi,[rsp+58h]
    mov     rsi,[rsi+8]
    mov     [rsp+40h],rsi
    cmp     rsi,0
    ja      L1
    jmp     L2

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u32>>::next
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

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
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

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    sub     rsp,18h
    mov     qword ptr [rsp+8],10h
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::num::NonZero::<T>::new_unchecked::precondition_check
    sub     rsp,78h
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],0D1h
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],0D1h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    sub     rsp,88h
    mov     [rsp+30h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+50h],rcx
    mov     byte ptr [rsp+46h],1
    mov     byte ptr [rsp+47h],1
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFFD8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L2
    .long   L3
    .long   L1
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     byte ptr [rsp+46h],0
    mov     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+68h]
    mov     rsi,[rsp+28h]
    call    fn0
    jmp     L4
L3:
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+28h],rcx
    mov     byte ptr [rsp+47h],0
    mov     rcx,[rsp+28h]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    lea     rdi,[rsp+68h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn1
    jmp     L4
L4:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+30h]
    add     rsp,88h
    ret
    nop     [rax]
L5:
    test    byte ptr [rsp+46h],0FFh
    jne     L9
    nop     [rax+rax]
L6:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L7:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L7
L9:
    jmp     L6
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L8

fn std::ptr::NonNull::<T>::new_unchecked::precondition_check
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+78h]
    cmp     rax,0
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+70h],0D2h
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],0D2h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,88h
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF84h
    mov     edx,0FFFFFFE8h
    call    ryo_h_CtpopW64
    mov     eax,[rsp+4]
    mov     [rsp+60h],eax
    jmp     L2
    nop     [rax+rax]
    xchg    ax,ax
L0:
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
L1:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+48h],2Ah
    mov     rdx,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],2Ah
    mov     rdx,[rsp+10h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+38h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp]
    call    qword ptr [sym3]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    cmp     dword ptr [rsp+60h],1
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L1
    jmp     L0

fn std::ptr::copy_nonoverlapping::<u8>
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L0
    mov     rsi,[rsp+38h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+30h]
    mov     [rsp+18h],rdi
    mov     qword ptr [rsp+10h],1
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+28h]
    mov     r9,[rsp]
    call    fn1
L0:
    imul    rax,[rsp+28h],1
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_Memcpy
    add     rsp,48h
    ret

fn std::ptr::copy_nonoverlapping::precondition_check
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+18h],r9
    cmp     qword ptr [rsp+98h],0
    jne     L0
    mov     byte ptr [rsp+97h],1
    jmp     L1
L0:
    cmp     qword ptr [rsp+0A8h],0
    sete    [rsp+97h]
L1:
    movzx   eax,byte ptr [rsp+97h]
    mov     [rsp+6Dh],al
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+6Ch],al
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+0B0h]
    mov     [rsp+88h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+6Ch],al
    jmp     L16
    xchg    ax,ax
L3:
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+6Fh],al
    jmp     L17
    xchg    ax,ax
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+80h],11Bh
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],11Bh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym5]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L6:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+6Dh],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L8:
    jmp     L5
L9:
    jmp     L2
L10:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Eh],sil
    test    byte ptr [rsp+6Eh],0FFh
    je      L5
    jmp     L2
L11:
    test    byte ptr [rsp+6Ch],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    test    byte ptr [rsp+97h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L13:
    jmp     L4
L14:
    jmp     L3
L15:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Dh],sil
    test    byte ptr [rsp+6Dh],0FFh
    je      L4
    jmp     L3
L16:
    test    byte ptr [rsp+6Ch],0FFh
    je      L13
    jmp     L12
L17:
    test    byte ptr [rsp+6Fh],0FFh
    je      L5
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    call    qword ptr [sym6]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L18

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym0]
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::io::error::CustomOwner> - shim(Some(core::io::error::CustomOwner))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym0]
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::io::error::ErrorData<core::io::error::CustomOwner>> - shim(Some(core::io::error::ErrorData<core::io::error::CustomOwner>))
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+7],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L1
    .long   L1
    .long   L1
    .long   L2
L1:
    add     rsp,28h
    ret
L2:
    mov     rax,[rsp+18h]
    lea     rax,[rax+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    jmp     L1

fn std::ptr::drop_glue::<core::io::error::repr::Repr> - shim(Some(core::io::error::repr::Repr))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>> - shim(Some(core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    lea     rax,[rax+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::RandomState>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(std::string::String, usize)>> - shim(Some(hashbrown::raw::RawTable<(std::string::String, usize)>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(u64, u64)>> - shim(Some(hashbrown::raw::RawTable<(u64, u64)>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>> - shim(Some(hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize>> - shim(Some(std::collections::HashMap<std::string::String, usize>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64>> - shim(Some(std::collections::HashMap<u64, u64>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::collections::hash_map::VacantEntry<'_, std::string::String, usize>> - shim(Some(std::collections::hash_map::VacantEntry<'_, std::string::String, usize>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::io::Error> - shim(Some(std::io::Error))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::result::Result<(), std::io::Error>> - shim(Some(std::result::Result<(), std::io::Error>))
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFDCh
    mov     edx,0FFFFFFE0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFDCh
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rsp+20h],0
    jne     L1
    nop     [rax+rax]
    xchg    ax,ax
L0:
    add     rsp,38h
    ret
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L0

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    qword ptr [sym0]
    jmp     L3
L0:
    add     rsp,28h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    jmp     L1
L3:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    jmp     L0
    nop     [rax+rax]
L4:
    call    qword ptr [sym3]
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::replace::precondition_check
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+8Fh],dl
    mov     [rsp+18h],rcx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+90h]
    call    fn0
    mov     [rsp+6Eh],al
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+80h],0DDh
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0DDh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym3]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L2:
    test    byte ptr [rsp+8Fh],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    jmp     L1
L4:
    jmp     L0
L5:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+6Dh]
    movzx   esi,byte ptr [rsp+6Dh]
    xor     sil,1
    mov     [rsp+6Fh],sil
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    jmp     L0
L6:
    test    byte ptr [rsp+6Eh],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    call    qword ptr [sym4]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L7

fn std::ptr::swap_chunk::<1>
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

fn std::ptr::swap_chunk::<2>
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

fn std::ptr::swap_chunk::<4>
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

fn std::ptr::swap_chunk::<8>
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

fn std::ptr::swap_nonoverlapping::<hashbrown::raw::RawTableInner>
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+20h],rcx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L0
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
L0:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+68h]
    mov     [rsp+60h],rdx
    mov     rcx,[rsp+60h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    imul    rsi,[rsp+48h],20h
    mov     [rsp+50h],rsi
    jmp     L3
L1:
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
    jmp     L2
L2:
    add     rsp,88h
    ret
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFFC8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::precondition_check
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+10h],r9
    cmp     qword ptr [rsp+0A8h],0
    jne     L0
    mov     byte ptr [rsp+97h],1
    jmp     L1
L0:
    cmp     qword ptr [rsp+98h],0
    sete    [rsp+97h]
L1:
    mov     rax,[rsp+0B8h]
    mov     [rsp+88h],rax
    movzx   edx,byte ptr [rsp+97h]
    mov     [rsp+65h],dl
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+64h],al
    jmp     L11
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+0B0h]
    mov     [rsp+80h],rax
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+64h],al
    jmp     L16
    xchg    ax,ax
L3:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+67h],al
    jmp     L17
    xchg    ax,ax
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],11Bh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],11Bh
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym5]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L6:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+65h],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L8:
    jmp     L5
L9:
    jmp     L2
L10:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+66h],sil
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L2
L11:
    test    byte ptr [rsp+64h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    test    byte ptr [rsp+97h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L13:
    jmp     L4
L14:
    jmp     L3
L15:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+65h],sil
    test    byte ptr [rsp+65h],0FFh
    je      L4
    jmp     L3
L16:
    test    byte ptr [rsp+64h],0FFh
    je      L13
    jmp     L12
L17:
    test    byte ptr [rsp+67h],0FFh
    je      L5
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    call    qword ptr [sym6]
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L18

fn std::ptr::swap_nonoverlapping_bytes
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFF90h
    call    ryo_h_DivUW64
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFF90h
    call    ryo_h_RemUW64
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF94h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF94h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L2
    .long   L1
    .long   L6
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    call    fn0
    jmp     L2
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF94h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF94h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L3:
    .long   L5
    .long   L4
    .long   L6
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    imul    rdx,[rsp+38h],8
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+68h]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+60h]
    imul    rcx,rdx,1
    add     rdi,rcx
    mov     [rsp+8],rdi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+20h]
    call    fn1
    jmp     L5
L5:
    add     rsp,78h
    ret
L6:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     rax,[rsp+78h]
    mov     qword ptr [rsp+68h],0
    mov     [rsp+70h],rax
    nop
L0:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    cmp     rax,rdx
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L5
    jmp     L4
L3:
    add     rsp,98h
    ret
L4:
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L5:
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
    jmp     L1

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
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
    je      L0
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
    jmp     L0
L0:
    mov     rax,[rsp+38h]
    and     rax,2
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L1
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
    jmp     L1
L1:
    mov     rax,[rsp+38h]
    and     rax,1
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
    call    fn2
    mov     rax,[rsp+30h]
    or      rax,1
    mov     [rsp+30h],rax
    jmp     L2
L2:
    add     rsp,78h
    ret

fn std::rt::lang_start::<()>
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+2Fh],cl
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdx,[rsp+8]
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
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

fn std::rt::lang_start::<()>::{closure#0}
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
    mov     [rsp+0Eh],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFEEh
    call    ryo_h_ZextW8W32
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn std::slice::from_raw_parts::precondition_check
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
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L0:
    cmp     qword ptr [rsp+90h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L1:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],117h
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],117h
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L4:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L3
    jmp     L0
    nop
L5:
    jmp     L3
L6:
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L4
L7:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L9
L8:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L9:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L10:
    call    qword ptr [sym4]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L10

fn std::slice::from_raw_parts_mut::precondition_check
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
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L0:
    cmp     qword ptr [rsp+90h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L1:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],11Bh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+20h],11Bh
    mov     rdx,[rsp+20h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+48h]
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+0Fh],0
    mov     r8,[rsp+10h]
    mov     [rsp],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L4:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L3
    jmp     L0
    nop
L5:
    jmp     L3
L6:
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L4
L7:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L9
L8:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L9:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L10:
    call    qword ptr [sym4]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L10

fn std::str::<impl std::borrow::ToOwned for str>::to_owned
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
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+30h]
    add     rsp,68h
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::try_with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
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
    je      L6
    jmp     L5
    nop     [rax+rax]
L0:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+68h],0
    nop     [rax]
L1:
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
L2:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+57h],0FFh
    je      L2
    jmp     L3
L5:
    mov     qword ptr [rsp+28h],0
    mov     qword ptr [rsp+30h],0
    mov     qword ptr [rsp+30h],1
    cmp     qword ptr [rsp+30h],1
    sete    [rsp+2Fh]
    mov     qword ptr [rsp+68h],1
    jmp     L1
L6:
    mov     rax,[rsp+20h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+57h],0
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L0
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L4

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
    sub     rsp,48h
    mov     [rsp+28h],rdi
    lea     rdi,[rsp+8]
    mov     rsi,[rsp+28h]
    call    fn0
    mov     rax,[rsp+8]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp]
    call    qword ptr [sym2]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     rax,[rsp+50h]
    lea     rax,[rax+10h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+17h],al
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFB7h
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rsp+38h],1
    jne     L0
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     [rsp+8],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+58h],rsi
    jmp     L1
L0:
    mov     byte ptr [rsp+2Fh],0
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    call    fn0
    mov     [rsp+58h],rax
L1:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
    nop     [rax+rax]
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+2Fh],0FFh
    je      L2
    jmp     L3
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L4

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init_slow::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
    sub     rsp,128h
    mov     [rsp+110h],rdi
    mov     [rsp+108h],rsi
    mov     rax,[rsp+110h]
    lea     rax,[rax+10h]
    mov     [rsp+90h],rax
    movzx   eax,byte ptr [rax]
    mov     [rsp+9Fh],al
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF7Fh
    call    ryo_h_ZextW8W64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L4
    .long   L3
    .long   L2
    .long   L1
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+118h],0
    jmp     L11
L3:
    mov     rax,[rsp+110h]
    mov     [rsp+0B0h],rax
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+118h],rdx
    jmp     L11
L4:
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEFCh
    mov     edx,0FFFFFFE8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFEFCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L5]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L5:
    .long   L12
    .long   L13
    .long   L1
L6:
    lea     rax,[rsp+0C0h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF38h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+60h],2Bh
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],2Bh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    call    fn2
    mov     [rsp+80h],rax
    jmp     L9
L7:
    lea     rax,[rsp+90h]
    mov     [rsp+78h],rax
    mov     rdi,[rsp+78h]
    call    qword ptr [sym3]
    jmp     L24
L8:
    mov     rdi,[rsp+110h]
    call    fn4
    jmp     L10
L9:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn5
    call    qword ptr [sym6]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    mov     rax,[rsp+110h]
    mov     [rsp+0A0h],rax
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+118h],rdx
    jmp     L11
L11:
    mov     rax,[rsp+118h]
    add     rsp,128h
    ret
L12:
    mov     qword ptr [rsp+88h],0
    jmp     L16
L13:
    mov     rax,[rsp+108h]
    mov     [rsp+78h],rax
    mov     qword ptr [rsp+60h],0
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF58h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF58h
    xor     edx,edx
    mov     ecx,0FFFFFF40h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+88h]
    mov     [rsp+80h],rax
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L14]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L14:
    .long   L16
    .long   L17
    .long   L1
    nop     [rax+rax]
    nop     [rax]
L15:
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
    je      L22
    jmp     L21
L16:
    call    fn7
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rdx
    jmp     L18
L17:
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+0E8h],rcx
    mov     [rsp+0E0h],rax
    jmp     L15
L18:
    jmp     L15
    nop
L19:
    mov     byte ptr [rsp+8Eh],1
    mov     rdx,[rsp+110h]
    lea     rdx,[rdx+10h]
    mov     [rsp+80h],rdx
    movzx   edx,byte ptr [rdx]
    mov     [rsp+8Fh],dl
    mov     rsi,[rsp+80h]
    movzx   ecx,byte ptr [rsp+8Eh]
    mov     [rsi],cl
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF6Fh
    call    ryo_h_ZextW8W64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L20]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L20:
    .long   L8
    .long   L7
    .long   L6
    .long   L1
L21:
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     qword ptr [rsp+18h],8
    mov     byte ptr [rsp+17h],0
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEE8h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+18h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    fn9
L22:
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L23
    mov     rsi,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rsi
    jmp     L19
L23:
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
    jmp     L19
L24:
    jmp     L10

fn std::vec::Vec::<T, A>::set_len::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L0
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0C6h
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0C6h
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
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
    jne     L0
    mov     [rsp+18h],rax
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+6Fh],al
    jmp     L1
L0:
    mov     byte ptr [rsp+6Fh],0
L1:
    movzx   eax,byte ptr [rsp+6Fh]
    add     rsp,78h
    ret

