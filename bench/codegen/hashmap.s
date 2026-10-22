fn <! as std::sys::thread_local::native::lazy::DestroyedState>::register_dtor::<std::cell::Cell<(u64, u64)>>
    push    rbp
    mov     rbp,rsp
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <&mut core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write::write_fmt::SpecWriteFmt>::spec_write_fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    lea     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-20h]
    mov     edi,0FFFFFFCCh
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFCCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L1
    .long   L5
L1:
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-1]
    jmp     L4
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,18h
    call    ryo_h_MovW128
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-1]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L5:
    call    ryo_h_Unreachable
    ud2

fn <&u64 as std::ops::Rem<u64>>::rem
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    cmp     qword ptr [rbp+18h],0
    jne     L2
    mov     rsi,[rbp+20h]
    mov     [rbp-30h],rsi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-11h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,18h
    call    ryo_h_RemUW64
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <() as std::process::Termination>::report
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     byte ptr [rbp-1],0
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     edi,0FFFFFFD8h
    mov     esi,10h
    xor     edx,edx
    mov     ecx,20h
    call    ryo_h_LoadCopy
    mov     rax,[rbp+10h]
    mov     rax,[rax+30h]
    and     rax,0FFh
    shl     rax,38h
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+38h]
    or      rax,rdx
    mov     [rbp-30h],rax
    mov     rsi,[rbp-10h]
    xor     rsi,rax
    mov     [rbp-10h],rsi
    lea     rdi,[rbp-28h]
    mov     [rbp-38h],rdi
    mov     [rbp-60h],rdi
    call    fn0
    nop     [rcx-8]
    mov     rax,[rbp-28h]
    xor     rax,[rbp-30h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-20h]
    xor     rdx,0FFh
    mov     [rbp-20h],rdx
    lea     rsi,[rbp-28h]
    mov     [rbp-38h],rsi
    mov     [rbp-60h],rsi
    call    fn1
    nop     [rcx-8]
    mov     rax,[rbp-28h]
    mov     rdx,[rbp-18h]
    xor     rax,rdx
    mov     rsi,[rbp-20h]
    xor     rax,rsi
    mov     rdi,[rbp-10h]
    xor     rax,rdi
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+30h]
    add     rdx,rax
    mov     [rbp-70h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rsi+30h],rcx
    mov     qword ptr [rbp-8],0
    mov     r8,[rbp+10h]
    mov     r8,[r8+40h]
    mov     [rbp-20h],r8
    cmp     r8,0
    je      L2
    mov     r10,[rbp+10h]
    mov     r10,[r10+40h]
    mov     qword ptr [rbp-68h],8
    mov     rax,[rbp-68h]
    sub     rax,r10
    mov     [rbp-8],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-30h]
    jmp     L7
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+40h]
    mov     qword ptr [rbp-68h],8
    mov     rsi,[rbp-68h]
    imul    rsi,rax
    mov     [rbp-30h],rsi
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFD0h
    call    ryo_h_ShlW64
    mov     rax,[rbp+10h]
    mov     rax,[rax+38h]
    or      rax,[rbp-20h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rdx+38h],rcx
    mov     rsi,[rbp-8]
    mov     [rbp-28h],rsi
    mov     rdi,[rbp-18h]
    cmp     rdi,rsi
    jae     L1
    mov     r8,[rbp+10h]
    mov     r8,[r8+40h]
    add     r8,rdi
    mov     [rbp-70h],r8
    mov     r9,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [r9+40h],rcx
    jmp     L6
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax+38h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+18h]
    xor     rdx,rax
    mov     [rbp-70h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rsi+18h],rcx
    mov     rdi,[rbp+10h]
    mov     [rbp-28h],rdi
    mov     [rbp-0A0h],rdi
    call    fn1
    nop     [rcx-8]
    mov     rax,[rbp+10h]
    mov     rax,[rax+38h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rbp-70h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rsi],rcx
    mov     qword ptr [rbp-70h],0
    mov     r8,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [r8+40h],rcx
    jmp     L2
L2:
    mov     rax,[rbp-8]
    mov     rdx,[rbp-18h]
    sub     rdx,rax
    mov     [rbp-20h],rdx
    and     rdx,7
    mov     [rbp-28h],rdx
    nop     [rax]
L3:
    mov     rax,[rbp-8]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-20h]
    sub     rdx,[rbp-28h]
    mov     [rbp-40h],rdx
    cmp     rax,rdx
    jae     L5
    mov     qword ptr [rbp-38h],0
    mov     rdi,[rbp+18h]
    mov     r8,[rbp+20h]
    mov     r9,[rbp-8]
    imul    rcx,r9,1
    add     rdi,rcx
    mov     [rbp-40h],rdi
    lea     r10,[rbp-38h]
    mov     [rbp-50h],r10
    mov     [rbp-48h],r10
    mov     byte ptr [rbp-61h],1
    test    byte ptr [rbp-61h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    xor     rax,[rbp-10h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rdx],rcx
    mov     rsi,[rbp-8]
    add     rsi,8
    mov     [rbp-8],rsi
    jmp     L3
L5:
    mov     edi,0FFFFFF60h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-8]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-88h],rdx
    call    fn2
    nop     [rcx-30h]
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rax+38h],rcx
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-28h]
    mov     [rdx+40h],rcx
L6:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L7:
    mov     edi,0FFFFFF60h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-90h],0
    mov     rdx,[rbp-30h]
    mov     [rbp-88h],rdx
    call    fn3
    nop     [rcx-28h]
    jmp     L0
L8:
    mov     rax,[rbp-40h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-60h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],1
    mov     qword ptr [rbp-88h],1
    mov     qword ptr [rbp-80h],8
    mov     edi,0FFFFFF88h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-10h]
L9:
    mov     qword ptr [rbp-68h],8
    imul    rdx,[rbp-68h],1
    mov     [rbp-70h],rdx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF90h
    call    ryo_h_Memcpy
    mov     rax,[rbp-38h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+18h]
    xor     rdx,rax
    mov     [rbp-70h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-70h]
    mov     [rsi+18h],rcx
    mov     rdi,[rbp+10h]
    mov     [rbp-38h],rdi
    mov     [rbp-0A0h],rdi
    call    fn6
    nop     [rcx-10h]
    jmp     L4

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFF0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    mov     byte ptr [rbp-19h],0FFh
    lea     rdx,[rbp-19h]
    mov     [rbp-10h],rdx
    mov     qword ptr [rbp-8],1
    mov     rdi,[rbp+10h]
    mov     [rbp-40h],rdi
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    add     rax,rdx
    mov     [rbp-8],rax
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rsi],rcx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi+8]
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    add     rdi,r8
    mov     [rbp-8],rdi
    mov     r9,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r9+8],rcx
    mov     r10,[rbp+10h]
    mov     r10,[r10+10h]
    mov     [rbp-10h],r10
    mov     dword ptr [rbp-1Ch],0Dh
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],10h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi+8],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],11h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],15h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+8],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    add     rax,rdx
    mov     [rbp-8],rax
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rsi],rcx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi+8]
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    add     rdi,r8
    mov     [rbp-8],rdi
    mov     r9,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r9+8],rcx
    mov     r10,[rbp+10h]
    mov     r10,[r10+10h]
    mov     [rbp-10h],r10
    mov     dword ptr [rbp-1Ch],0Dh
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],10h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi+8],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],11h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],15h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+8],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10+8],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],0Dh
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],10h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi+8],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],11h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],15h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+8],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10+8],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],0Dh
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],10h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    add     rdx,rsi
    mov     [rbp-8],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rdi+8],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     r9,[rbp+10h]
    mov     r9,[r9+18h]
    add     r8,r9
    mov     [rbp-8],r8
    mov     r10,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [r10],rcx
    mov     r11,[rbp+10h]
    mov     r11,[r11+10h]
    mov     [rbp-10h],r11
    mov     dword ptr [rbp-1Ch],11h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+10h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],15h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+18h],rcx
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    xor     rsi,rdx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+18h],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+8]
    mov     [rbp-10h],r8
    mov     dword ptr [rbp-1Ch],20h
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFE4h
    call    ryo_h_RotlW64
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-8]
    mov     [rax+8],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-10h]
    lea     rax,[rbp-10h]
    mov     [rbp-20h],rax
    mov     [rbp-30h],rax
    call    fn1
    nop     [rcx-20h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     byte ptr [rbp-19h],1
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-18h],rsi
    mov     [rbp-30h],rsi
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_char
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFBCh
    mov     esi,4
    call    ryo_h_Zero
    lea     rax,[rbp-44h]
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-30h],4
    mov     esi,[rbp+18h]
    mov     [rbp-48h],esi
    mov     [rbp-80h],esi
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-58h]
    jmp     L1
L0:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-58h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-80h],rsi
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-1]
    jmp     L0

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr> as std::fmt::Write>::write_str
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFC8h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-18h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-28h]
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-28h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-48h],rdx
    mov     [rbp-60h],rdx
    call    fn1
    nop     [rcx-48h]
    jmp     L4
L3:
    mov     byte ptr [rbp-1],0
    jmp     L6
L4:
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-28h]
    mov     [rax+8],rcx
    mov     byte ptr [rbp-1],1
    jmp     L6
    nop     [rax+rax]
    xchg    ax,ax
L5:
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-28h]
    mov     [rax+8],rcx
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
L6:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L5

fn <fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn} as std::ops::FnOnce<()>>::call_once - shim(fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn})
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    push    rbp
    mov     rbp,rsp
    mov     edi,10h
    lea     rsi,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned} as std::ops::FnOnce<(&str,)>>::call_once - shim(for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned})
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFD8h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp+30h]
    mov     [rbp-48h],rax
    lea     rdx,[rbp+40h]
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFC0h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-48h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+38h]
    mov     [rbp-58h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-50h],rsi
    call    fn0
    nop     [rcx-8]
    jmp     L2
    nop     [rax]
L0:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L1

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L3
    jmp     L2
    xchg    ax,ax
L0:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp-30h]
    lea     rdx,[rdx+8]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    mov     [rbp-18h],rsi
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    mov     rdi,[rbp+18h]
    mov     [rbp-40h],rdi
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp-18h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-8]
    jmp     L0
L2:
    mov     qword ptr [rbp-20h],8
    jmp     L1
L3:
    mov     rax,[rbp+20h]
    mov     [rbp-28h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L4:
    jmp     L1
L5:
    mov     rax,[rbp-28h]
    mov     [rbp-20h],rax
    jmp     L4
L6:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-28h]
    imul    rcx,[rbp-58h],10h
    add     rdx,rcx
    mov     [rbp-20h],rdx
    jmp     L4

fn <hashbrown::raw::RawTable<(std::string::String, usize)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <hashbrown::raw::RawTable<(u64, u64)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    lea     rax,[rax+8]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+18h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::alloc::Global as std::alloc::Allocator>::allocate
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFD0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-20h],0
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::alloc::Global as std::alloc::Allocator>::deallocate
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+28h]
    mov     [rbp-20h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rbp+20h]
    mov     [rbp-28h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-50h],rdi
    mov     [rbp-48h],rax
    mov     [rbp-40h],rsi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    jmp     L3
    nop     [rax+rax]
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    jmp     L2

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFB8h
    mov     esi,10h
    mov     edx,28h
    call    ryo_h_Copy
    lea     rax,[rbp+40h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFB8h
    mov     edx,28h
    call    ryo_h_Copy
    mov     rax,[rbp+38h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-50h],rdx
    call    fn0
    nop     [rcx-8]
    jmp     L2
    nop     [rax]
L0:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L1

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+28h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rax
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    lea     rdx,[rbp-20h]
    mov     [rbp-10h],rdx
    mov     qword ptr [rbp-8],8
    mov     rdi,[rbp+10h]
    mov     [rbp-40h],rdi
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::build_hasher
    push    rbp
    mov     rbp,rsp
    sub     rsp,160h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-0A0h],rdx
    mov     qword ptr [rbp-150h],0
    mov     qword ptr [rbp-148h],0
    mov     qword ptr [rbp-140h],0
    mov     qword ptr [rbp-138h],0
    mov     [rbp-110h],rax
    mov     [rbp-108h],rdx
    mov     qword ptr [rbp-100h],0
    mov     edi,0FFFFFED0h
    mov     esi,0FFFFFEB0h
    mov     edx,20h
    call    ryo_h_Copy
    mov     qword ptr [rbp-0F8h],0
    mov     qword ptr [rbp-0F0h],0
    lea     rsi,[rbp-130h]
    mov     [rbp-138h],rsi
    mov     [rbp-160h],rsi
    call    fn0
    nop     [rcx-48h]
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFED0h
    mov     edx,48h
    call    ryo_h_Copy
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF18h
    mov     edx,48h
    call    ryo_h_Copy
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFF70h
    mov     edx,48h
    call    ryo_h_Copy
    mov     edi,0FFFFFFB8h
    mov     esi,48h
    call    ryo_h_Ret
    leave
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&std::string::String>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     [rbp-80h],rax
    call    fn0
    nop     [rcx-58h]
    lea     rax,[rbp+18h]
    mov     [rbp-60h],rax
    lea     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    call    fn1
    nop     [rcx-8]
    lea     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     [rbp-80h],rax
    call    fn2
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     [rbp-80h],rax
    call    fn0
    nop     [rcx-58h]
    lea     rax,[rbp+18h]
    mov     [rbp-60h],rax
    lea     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    call    fn1
    nop     [rcx-8]
    lea     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     [rbp-80h],rax
    call    fn2
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE0h
    mov     esi,10h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::Iterator>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<u32> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<u32> as std::iter::range::RangeIteratorImpl>::spec_next
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+4]
    mov     [rbp-20h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-9]
    test    byte ptr [rbp-9],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     edx,[rdx]
    mov     [rbp-10h],edx
    mov     [rbp-30h],edx
    mov     qword ptr [rbp-28h],1
    call    fn1
    nop     [rcx-14h]
    mov     rax,[rbp+10h]
    mov     ecx,[rbp-14h]
    mov     [rax],ecx
    mov     edx,[rbp-10h]
    mov     [rbp-4],edx
    mov     dword ptr [rbp-8],1
    jmp     L1
L0:
    mov     dword ptr [rbp-8],0
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<u64> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<u64> as std::iter::Iterator>::step_by
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-20h]
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<u64> as std::iter::range::RangeIteratorImpl>::spec_next
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-28h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    call    fn0
    nop     [rcx-11h]
    test    byte ptr [rbp-11h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-20h],rdx
    mov     [rbp-40h],rdx
    mov     qword ptr [rbp-38h],1
    call    fn1
    nop     [rcx-28h]
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-28h]
    mov     [rax],rcx
    mov     rdx,[rbp-20h]
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-10h],1
    jmp     L1
L0:
    mov     qword ptr [rbp-10h],0
L1:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::string::String as std::cmp::PartialEq>::eq
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_all
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFB8h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-40h]
    cmp     rax,0
    sete    [rbp-31h]
    test    byte ptr [rbp-31h],0FFh
    je      L1
    mov     qword ptr [rbp-8],0
    jmp     L13
L1:
    mov     edi,0FFFFFFA8h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF48h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-48h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L4:
    .long   L6
    .long   L7
    .long   L5
    nop     [rax+rax]
    nop     [rax]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    cmp     qword ptr [rbp-40h],0
    je      L9
    jmp     L8
L7:
    lea     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     [rbp-0C0h],rax
    call    fn3
    nop     [rcx-32h]
    jmp     L10
L8:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-58h],rdx
    cmp     rdx,rax
    jb      L20
    jmp     L23
L9:
    mov     edi,0FFFFFFF8h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    jmp     L13
L10:
    test    byte ptr [rbp-32h],0FFh
    je      L11
    jmp     L16
L11:
    mov     rax,[rbp-40h]
    mov     [rbp-8],rax
    jmp     L13
L12:
    jmp     L0
L13:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop
L14:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L15:
    lea     rax,[rbp-40h]
    mov     [rbp-98h],rax
    mov     [rbp-0C0h],rax
    call    fn5
    nop     [rcx-98h]
    jmp     L12
    nop     [rax]
L16:
    mov     rax,[rbp-48h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L17]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L17:
    .long   L12
    .long   L15
    .long   L5
    nop     [rax+rax]
L18:
    lea     rax,[rbp-40h]
    mov     [rbp-98h],rax
    mov     [rbp-0C0h],rax
    call    fn6
    nop     [rcx-98h]
    jmp     L14
    nop     [rax+rax]
    nop     [rax]
L19:
    mov     rax,[rbp-48h]
    mov     [rbp-28h],rax
    cmp     rax,1
    je      L18
    jmp     L14
L20:
    mov     rax,[rbp-50h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-0B8h],rdx
    mov     rsi,[rbp-58h]
    mov     [rbp-0B0h],rsi
    mov     edi,0FFFFFF58h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-28h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    call    ryo_h_Unreachable
    ud2
L23:
    mov     rax,[rbp-58h]
    sub     rax,[rbp-50h]
    mov     rdx,[rbp+18h]
    mov     rsi,[rbp+20h]
    imul    rcx,[rbp-50h],1
    add     rdx,rcx
    mov     [rbp+18h],rdx
    mov     [rbp+20h],rax
    jmp     L16
    nop     [rax]
L24:
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L25
    call    rax
    nop     [rcx-90h]
    jmp     L26
L25:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym13]
L26:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L19
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L24

fn <std::sys::stdio::unix::Stderr as std::io::Write>::write_fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    lea     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-20h]
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L1
    .long   L4
L1:
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-8]
    jmp     L3
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFA8h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx-8]
L3:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L4:
    call    ryo_h_Unreachable
    ud2

fn <u32 as std::iter::Step>::forward_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFF8h
    mov     esi,18h
    call    ryo_h_TruncW64W32
    mov     byte ptr [rbp-9],1
    test    byte ptr [rbp-9],0FFh
    je      L0
    mov     esi,[rbp+10h]
    mov     [rbp-20h],esi
    mov     edi,[rbp-8]
    mov     [rbp-1Ch],edi
    mov     edi,0FFFFFFE8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-4]
L0:
    mov     eax,[rbp+10h]
    add     eax,[rbp-8]
    mov     [rbp-4],eax
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn <u64 as hashbrown::Equivalent<u64>>::equivalent
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-20h]
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-28h],rdx
    call    fn1
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <u64 as std::borrow::Borrow<u64>>::borrow
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <u64 as std::iter::Step>::forward_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-11h],1
    test    byte ptr [rbp-11h],0FFh
    je      L0
    mov     rdi,[rbp+10h]
    mov     [rbp-30h],rdi
    mov     [rbp-28h],rax
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
L0:
    mov     rax,[rbp+10h]
    add     rax,[rbp-10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    imul    rax,[rbp+20h],1
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-20h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    cmp     dword ptr [rbp-8],0
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <u8 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF48h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx-78h]
    jmp     L2
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    mov     [rbp-68h],rax
    mov     rsi,[rbp-10h]
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rsi
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L2:
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-8],0
    cmp     qword ptr [rbp-58h],0
    ja      L0
    jmp     L1
L3:
    mov     rax,[rbp-38h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-80h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    mov     qword ptr [rbp-0B0h],1
    mov     qword ptr [rbp-0A8h],1
    mov     r8,[rbp-58h]
    mov     [rbp-0A0h],r8
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-40h]
L4:
    imul    rax,[rbp-58h],1
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L5
    mov     qword ptr [rbp-88h],1
    cmp     qword ptr [rbp-88h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L5:
    mov     rax,[rbp-58h]
    mov     [rbp-8],rax
    jmp     L1
    nop     [rax]
L6:
    mov     rax,[rbp-58h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-68h]
    mov     [rbp-0B8h],rdx
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-40h]
    jmp     L5
L7:
    mov     qword ptr [rbp-68h],0FFFFFFFFFFFFFFFFh
    jmp     L6
L8:
    mov     rax,[rbp-18h]
    mov     [rbp-68h],rax
    jmp     L6

fn <usize as std::cmp::Ord>::max
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     byte ptr [rbp-9],1
    lea     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     byte ptr [rbp-9],0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rbp-9],0FFh
    je      L3
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::cmp::Ord>::min
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     byte ptr [rbp-9],1
    lea     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rdx,[rbp+18h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     byte ptr [rbp-9],0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rbp-9],0FFh
    je      L3
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::default::Default>::default
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     qword ptr [rbp-8],0
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    cmp     rax,[rbp+18h]
    jae     L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0D6h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0D6h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-10h],rax
    lea     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     rax,[rbp-10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <{closure@hashbrown::raw::RawTable<(std::string::String, usize)>::reserve_rehash<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}} as std::ops::FnOnce<(*mut u8,)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    lea     rdx,[rbp+10h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-10h],rax
    lea     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     rax,[rbp-10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-10h],rax
    lea     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::find<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(usize,)>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     rax,[rbp-10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@hashbrown::raw::RawTable<(u64, u64)>::reserve_rehash<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}} as std::ops::FnOnce<(&mut hashbrown::raw::RawTableInner, usize)>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <{closure@std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}} as std::ops::FnOnce<(std::option::Option<&mut std::option::Option<std::cell::Cell<(u64, u64)>>>,)>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    lea     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    lea     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn alloc::raw_vec::RawVecInner::with_capacity_in
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-88h],0
    mov     edi,0FFFFFF80h
    mov     esi,18h
    call    ryo_h_MovW128
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-40h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    mov     rax,[rbp-40h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L7
    .long   L4
    .long   L3
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-20h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-60h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop
L8:
    mov     rax,[rbp-58h]
    sub     rax,0
    cmp     rax,[rbp+10h]
    setb    [rbp-42h]
    movzx   edx,byte ptr [rbp-42h]
    xor     dl,1
    mov     [rbp-41h],dl
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L12
    jmp     L11
L9:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    jmp     L8
L10:
    mov     rax,[rbp-10h]
    mov     [rbp-58h],rax
    jmp     L8
L11:
    movzx   eax,byte ptr [rbp-41h]
    mov     [rbp-90h],al
    mov     edi,0FFFFFF78h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx-28h]
L12:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::core_arch::simd::Simd::<i8, 16>::splat
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::core_arch::x86::<impl core::core_arch::simd::Simd<i8, 16>>::as_m128i
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::hash::impls::<impl std::hash::Hash for u64>::hash::<std::hash::DefaultHasher>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     qword ptr [rbp-10h],0
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rdx+30h],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+20h]
    mov     rcx,736F6D6570736575h
    xor     rsi,rcx
    mov     [rbp-10h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rdi],rcx
    mov     r8,[rbp+10h]
    mov     r8,[r8+28h]
    mov     rcx,646F72616E646F6Dh
    xor     r8,rcx
    mov     [rbp-10h],r8
    mov     r9,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [r9+10h],rcx
    mov     r10,[rbp+10h]
    mov     r10,[r10+20h]
    mov     rcx,6C7967656E657261h
    xor     r10,rcx
    mov     [rbp-10h],r10
    mov     r11,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [r11+8],rcx
    mov     rax,[rbp+10h]
    mov     rax,[rax+28h]
    mov     rcx,7465646279746573h
    xor     rax,rcx
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rdx+18h],rcx
    mov     qword ptr [rbp-10h],0
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rdi+40h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::hash::sip::u8to64_le
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-8],0
    mov     rsi,[rbp-38h]
    add     rsi,3
    mov     [rbp-48h],rsi
    cmp     rsi,[rbp+28h]
    jae     L0
    mov     dword ptr [rbp-40h],0
    mov     r8,[rbp+10h]
    mov     r9,[rbp+18h]
    mov     r10,[rbp-38h]
    mov     r11,[rbp+20h]
    add     r11,r10
    imul    rcx,r11,1
    add     r8,rcx
    mov     [rbp-48h],r8
    lea     rax,[rbp-40h]
    mov     [rbp-58h],rax
    mov     [rbp-50h],rax
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rbp-38h]
    add     rax,1
    mov     [rbp-48h],rax
    cmp     rax,[rbp+28h]
    jae     L1
    mov     word ptr [rbp-3Ch],0
    mov     rsi,[rbp+10h]
    mov     rdi,[rbp+18h]
    mov     r8,[rbp-38h]
    mov     r9,[rbp+20h]
    add     r9,r8
    imul    rcx,r9,1
    add     rsi,rcx
    mov     [rbp-58h],rsi
    lea     r10,[rbp-3Ch]
    mov     [rbp-68h],r10
    mov     [rbp-60h],r10
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rbp-38h]
    mov     [rbp-48h],rax
    cmp     rax,[rbp+28h]
    jae     L2
    mov     rdx,[rbp-38h]
    mov     rsi,[rbp+20h]
    add     rsi,rdx
    mov     [rbp-58h],rsi
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L8
    jmp     L7
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp-48h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    mov     qword ptr [rbp-0B0h],1
    mov     qword ptr [rbp-0A8h],1
    mov     qword ptr [rbp-0A0h],4
    mov     edi,0FFFFFF68h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-21h]
L4:
    mov     qword ptr [rbp-80h],4
    imul    rdx,[rbp-80h],1
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     eax,[rbp-40h]
    mov     [rbp-0Ch],eax
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF4h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-38h]
    add     rax,4
    mov     [rbp-38h],rax
    jmp     L0
L5:
    mov     rax,[rbp-58h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-68h]
    mov     [rbp-78h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    mov     qword ptr [rbp-0B0h],1
    mov     qword ptr [rbp-0A8h],1
    mov     qword ptr [rbp-0A0h],2
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-21h]
L6:
    mov     qword ptr [rbp-80h],2
    imul    rdx,[rbp-80h],1
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    movzx   eax,word ptr [rbp-3Ch]
    mov     [rbp-0Eh],ax
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFF2h
    call    ryo_h_ZextW16W64
    mov     rax,[rbp-38h]
    imul    rdx,rax,8
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_ShlW64
    mov     rax,[rbp-8]
    or      rax,[rbp-48h]
    mov     [rbp-8],rax
    mov     rdx,[rbp-38h]
    add     rdx,2
    mov     [rbp-38h],rdx
    jmp     L1
L7:
    mov     rax,[rbp+18h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-0C0h],rdx
    mov     [rbp-0B8h],rax
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-30h]
L8:
    mov     rax,[rbp+18h]
    mov     rdx,[rbp-58h]
    cmp     rdx,rax
    setb    [rbp-3Bh]
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,1
    add     rsi,rcx
    movzx   esi,byte ptr [rsi]
    mov     [rbp-3Ah],sil
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC6h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-38h]
    imul    rdx,rax,8
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_ShlW64
    mov     rax,[rbp-8]
    or      rax,[rbp-48h]
    mov     [rbp-8],rax
    mov     rdx,[rbp-38h]
    add     rdx,1
    mov     [rbp-38h],rdx
    jmp     L2

fn core::io::error::repr::Repr::data::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::io::error::repr::decode_repr::<&core::io::error::Custom, {closure@core::io::error::repr::Repr::data::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-21h],1
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-78h],rsi
    and     rsi,3
    mov     [rbp-80h],rsi
    mov     edi,0FFFFFF80h
    xor     esi,esi
    mov     edx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L5
    .long   L4
    .long   L7
    .long   L6
    .long   L1
L1:
    mov     edi,0FFFFFF40h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B8h],28h
    mov     edi,0FFFFFF50h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp+10h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-0A0h],rdx
    mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rbp-0A8h],1
    add     rdx,rcx
    mov     [rbp-68h],rdx
    jmp     L18
L5:
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+10h]
    mov     [rbp-90h],rdx
    mov     [rbp-8],rax
    mov     byte ptr [rbp-10h],2
    jmp     L19
L6:
    mov     rax,[rbp-78h]
    shr     rax,20h
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF7Ch
    mov     esi,0FFFFFF70h
    call    ryo_h_TruncW64W32
    mov     eax,[rbp-84h]
    mov     [rbp-0C0h],eax
    call    fn5
    nop     [rcx-86h]
    jmp     L8
L7:
    mov     rax,[rbp-78h]
    sar     rax,20h
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF7Ch
    mov     esi,0FFFFFF70h
    call    ryo_h_TruncW64W32
    mov     eax,[rbp-84h]
    mov     [rbp-0Ch],eax
    mov     byte ptr [rbp-10h],0
    jmp     L19
L8:
    mov     edi,0FFFFFF5Ch
    mov     esi,0FFFFFF7Ah
    mov     edx,0FFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW8
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF70h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L9]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L9:
    .long   L16
    .long   L17
    .long   L15
    nop     [rax]
L10:
    mov     rax,[rbp-90h]
    mov     [rbp-8],rax
    mov     byte ptr [rbp-10h],3
    nop
L11:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    mov     edi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L13:
    jmp     L12
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    test    byte ptr [rbp-21h],0FFh
    je      L12
    jmp     L13
    nop     [rax+rax]
L15:
    call    ryo_h_Unreachable
    ud2
L16:
    mov     edi,0FFFFFF40h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx-58h]
    jmp     L15
L17:
    movzx   eax,byte ptr [rbp-86h]
    mov     [rbp-0Fh],al
    mov     byte ptr [rbp-10h],1
    jmp     L19
L18:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+10h]
    mov     rsi,[rbp-68h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp-68h]
    mov     byte ptr [rbp-21h],0
    mov     [rbp-98h],rdi
    mov     [rbp-0C0h],rdi
    call    fn8
    nop     [rcx-90h]
    jmp     L10
L19:
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFF90h
    call    ryo_h_Lpad
    jmp     L14

fn core::io::error::repr::decode_repr::<core::io::error::CustomOwner, {closure@<core::io::error::repr::Repr as std::ops::Drop>::drop::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-21h],1
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-78h],rsi
    and     rsi,3
    mov     [rbp-80h],rsi
    mov     edi,0FFFFFF80h
    xor     esi,esi
    mov     edx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L5
    .long   L4
    .long   L7
    .long   L6
    .long   L1
L1:
    mov     edi,0FFFFFF40h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B8h],28h
    mov     edi,0FFFFFF50h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp+10h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-0A0h],rdx
    mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    imul    rcx,[rbp-0A8h],1
    add     rdx,rcx
    mov     [rbp-68h],rdx
    jmp     L18
L5:
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+10h]
    mov     [rbp-90h],rdx
    mov     [rbp-8],rax
    mov     byte ptr [rbp-10h],2
    jmp     L19
L6:
    mov     rax,[rbp-78h]
    shr     rax,20h
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF7Ch
    mov     esi,0FFFFFF70h
    call    ryo_h_TruncW64W32
    mov     eax,[rbp-84h]
    mov     [rbp-0C0h],eax
    call    fn5
    nop     [rcx-86h]
    jmp     L8
L7:
    mov     rax,[rbp-78h]
    sar     rax,20h
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF7Ch
    mov     esi,0FFFFFF70h
    call    ryo_h_TruncW64W32
    mov     eax,[rbp-84h]
    mov     [rbp-0Ch],eax
    mov     byte ptr [rbp-10h],0
    jmp     L19
L8:
    mov     edi,0FFFFFF5Ch
    mov     esi,0FFFFFF7Ah
    mov     edx,0FFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW8
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF70h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L9]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L9:
    .long   L16
    .long   L17
    .long   L15
    nop     [rax]
L10:
    mov     rax,[rbp-90h]
    mov     [rbp-8],rax
    mov     byte ptr [rbp-10h],3
    nop
L11:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    mov     edi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L13:
    jmp     L12
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    test    byte ptr [rbp-21h],0FFh
    je      L12
    jmp     L13
    nop     [rax+rax]
L15:
    call    ryo_h_Unreachable
    ud2
L16:
    mov     edi,0FFFFFF40h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx-58h]
    jmp     L15
L17:
    movzx   eax,byte ptr [rbp-86h]
    mov     [rbp-0Fh],al
    mov     byte ptr [rbp-10h],1
    jmp     L19
L18:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+10h]
    mov     rsi,[rbp-68h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp-68h]
    mov     byte ptr [rbp-21h],0
    mov     [rbp-98h],rdi
    mov     [rbp-0C0h],rdi
    call    fn8
    nop     [rcx-90h]
    jmp     L10
L19:
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFF90h
    call    ryo_h_Lpad
    jmp     L14

fn core::io::write::default_write_fmt::<std::sys::stdio::unix::Stderr>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     qword ptr [rbp-28h],0
    lea     rsi,[rbp-30h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    mov     edi,0FFFFFFC0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,18h
    call    ryo_h_MovW128
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-31h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFCFh
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L2:
    .long   L5
    .long   L4
    .long   L3
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     edi,0FFFFFF64h
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF64h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-40h],0
    sete    [rbp-33h]
    movzx   edx,byte ptr [rbp-33h]
    xor     dl,1
    mov     [rbp-32h],dl
    test    byte ptr [rbp-32h],0FFh
    je      L7
    jmp     L6
L5:
    mov     qword ptr [rbp-8],0
    lea     rdx,[rbp-28h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-0C0h],rdx
    call    fn4
    nop     [rcx-0A0h]
    jmp     L10
L6:
    mov     rax,[rbp-28h]
    mov     [rbp-8],rax
    jmp     L10
L7:
    mov     edi,0FFFFFFA0h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],56h
    mov     rdx,[rbp-60h]
    mov     rsi,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFF68h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-90h],56h
    mov     rdx,[rbp-90h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-68h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-18h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L9:
    call    ryo_h_Unreachable
    ud2
L10:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L11:
    lea     rax,[rbp-30h]
    mov     [rbp-0A0h],rax
    mov     [rbp-0C0h],rax
    call    fn11
    nop     [rcx-0A0h]
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L12:
    lea     rdi,[sym12]
    lea     rsi,[site13]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-98h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L12

fn core::num::<impl u32>::unchecked_add::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     edi,0FFFFFFE4h
    mov     esi,0FFFFFFE8h
    mov     edx,10h
    mov     ecx,14h
    call    ryo_h_AddOvfUW32
    movzx   eax,byte ptr [rbp-18h]
    mov     [rbp-11h],al
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0B8h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0B8h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+18h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl u64>::unchecked_add::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-20h]
    mov     [rbp-11h],al
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0B8h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0B8h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl u64>::wrapping_add
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    add     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl u64>::wrapping_mul
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    imul    rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-20h]
    mov     [rbp-11h],al
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0BAh
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0BAh
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-38h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-60h],rdi
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-58h]
    movzx   edx,byte ptr [rbp-50h]
    mov     [rbp-1Dh],dl
    mov     [rbp-68h],rax
    test    byte ptr [rbp-1Dh],0FFh
    je      L2
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],3Dh
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-1]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-68h]
    mov     qword ptr [rbp-48h],1
    mov     [rbp-38h],rax
    mov     rsi,[rbp-28h]
    cmp     rsi,[rbp-30h]
    jae     L3
    mov     rdi,[rbp-30h]
    sub     rdi,rsi
    mov     [rbp-10h],rdi
    jmp     L4
L3:
    mov     rax,[rbp-28h]
    sub     rax,[rbp-30h]
    mov     [rbp-10h],rax
L4:
    mov     rax,[rbp-38h]
    cmp     rax,[rbp-10h]
    setbe   [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::control::group::sse2::Group::convert_special_to_empty_and_full_to_deleted
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     byte ptr [rbp-80h],80h
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym4]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym5]
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym6]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+52]
    call    qword ptr [sym7]
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    cmp     rax,0
    sete    [rbp-21h]
    test    byte ptr [rbp-21h],0FFh
    je      L0
    mov     qword ptr [rbp-8],0
    jmp     L2
L0:
    mov     rax,[rbp+10h]
    lea     rax,[rax+20h]
    mov     [rbp-38h],rax
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-98h],rdx
    call    fn0
    nop     [rcx-30h]
    jmp     L3
    nop     [rax+rax]
L1:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-48h],rdx
    mov     [rbp-0A0h],rax
    mov     rsi,[rbp-30h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rdx
    call    fn1
    nop     [rcx-50h]
    mov     edi,0FFFFFF84h
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF84h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFA8h
    xor     esi,esi
    mov     edx,2
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
    mov     qword ptr [rbp-8],0
    jmp     L2
L6:
    mov     rax,[rbp-50h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     rax,[rbp-68h]
    lea     rax,[rax+8]
    mov     [rbp-8],rax
    jmp     L2
L8:
    mov     qword ptr [rbp-68h],8
    jmp     L7
L9:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-70h]
    mov     [rbp-68h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-70h]
    imul    rcx,[rbp-80h],10h
    add     rdx,rcx
    mov     [rbp-68h],rdx
    jmp     L10

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-0A0h],rax
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-0B1h],0
    test    byte ptr [rbp-0B1h],0FFh
    je      L2
    jmp     L1
    nop
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFF78h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-90h]
    mov     [rbp-40h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFA0h
    mov     edx,28h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     qword ptr [rbp-0A8h],1
    jmp     L3
L2:
    mov     rax,[rbp-0A0h]
    mov     [rbp-0A8h],rax
L3:
    mov     rax,[rbp-0A8h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rbp-98h],rsi
    mov     [rbp-0C8h],rdx
    mov     [rbp-0D0h],rax
    mov     [rbp-0C0h],rsi
    call    fn0
    nop     [rcx-88h]
    jmp     L0

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0F0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-0A0h],rax
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-0C9h],0
    test    byte ptr [rbp-0C9h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp-68h]
    mov     [rbp-98h],rax
    cmp     rax,0
    je      L13
    jmp     L14
    nop     [rax+rax]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-90h]
    mov     [rbp-98h],rax
    mov     byte ptr [rbp-0C9h],0
    test    byte ptr [rbp-0C9h],0FFh
    je      L18
    jmp     L17
    xchg    ax,ax
L3:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rbp-0A9h],0FFh
    je      L5
    jmp     L6
L5:
    mov     rax,[rbp+10h]
    mov     [rbp-0B8h],rax
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-98h]
    mov     [rbp-0E8h],rdx
    call    fn0
    nop     [rcx-48h]
L6:
    jmp     L0
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L8:
    mov     edi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L9:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF78h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-90h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFFD8h
    mov     edx,28h
    call    ryo_h_Copy
    jmp     L0
L10:
    mov     qword ptr [rbp-0A8h],1
    jmp     L12
L11:
    mov     rax,[rbp-0A0h]
    mov     [rbp-0A8h],rax
L12:
    mov     rax,[rbp-0A8h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rbp-98h],rsi
    mov     [rbp-0E8h],rdx
    mov     [rbp-0F0h],rax
    mov     [rbp-0E0h],rsi
    call    fn1
    nop     [rcx-88h]
    jmp     L9
L13:
    mov     qword ptr [rbp-90h],0
    jmp     L3
L14:
    lea     rax,[rbp-88h]
    mov     [rbp-98h],rax
    mov     [rbp-0F0h],rax
    call    fn2
    nop     [rcx-90h]
    mov     rax,[rbp-68h]
    sub     rax,1
    mov     [rbp-68h],rax
    mov     edi,0FFFFFF34h
    mov     esi,0FFFFFF70h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF34h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L15]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L15:
    .long   L3
    .long   L2
    .long   L1
    nop     [rax]
L16:
    mov     rax,[rbp-0A0h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-0B0h]
    lea     rdx,[rdx+8]
    lea     rsi,[rbp+18h]
    mov     [rbp-0B8h],rsi
    mov     [rbp-0C8h],rax
    mov     [rbp-0C0h],rdx
    mov     [rbp-0F0h],rsi
    mov     [rbp-0E8h],rax
    mov     [rbp-0E0h],rdx
    call    fn3
    nop     [rcx-0A9h]
    jmp     L4
L17:
    mov     qword ptr [rbp-0A0h],8
    jmp     L16
L18:
    mov     rax,[rbp-98h]
    mov     [rbp-0A8h],rax
    mov     byte ptr [rbp-0C9h],0
    test    byte ptr [rbp-0C9h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    xchg    ax,ax
L19:
    jmp     L16
L20:
    mov     rax,[rbp-0A8h]
    mov     [rbp-0A0h],rax
    jmp     L19
L21:
    mov     qword ptr [rbp-0D0h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-0A8h]
    imul    rcx,[rbp-0D0h],10h
    add     rdx,rcx
    mov     [rbp-0A0h],rdx
    jmp     L19
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L8

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::FullBucketsIndices::next_impl
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    movzx   eax,word ptr [rax+18h]
    mov     [rbp-92h],ax
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF6Eh
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF50h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF60h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L3:
    movzx   eax,word ptr [rbp-92h]
    mov     [rbp-0AAh],ax
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF56h
    call    ryo_h_CttzW16
    mov     eax,[rbp-0B0h]
    mov     [rbp-98h],eax
    jmp     L5
L4:
    mov     edi,0FFFFFF70h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-88h],0
    cmp     qword ptr [rbp-88h],0
    sete    [rbp-89h]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    mov     qword ptr [rbp-0B8h],10h
    imul    rcx,[rbp-0B8h],1
    add     rsi,rcx
    mov     [rbp-78h],rsi
    mov     r8,[rbp+10h]
    mov     rcx,[rbp-78h]
    mov     [r8],rcx
    mov     r9,[rbp+10h]
    mov     r9,[r9]
    mov     [rbp-28h],r9
    mov     r10,[rbp-28h]
    mov     [rbp-80h],r10
    mov     r11,[rbp-28h]
    mov     [rbp-88h],r11
    mov     [rbp-0D0h],r11
    mov     edi,0FFFFFF48h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L6
L5:
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF68h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-0A8h]
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-90h],1
    mov     [rbp-40h],rax
    mov     rsi,[rbp+10h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rbp-88h],si
    sub     esi,1
    mov     [rbp-86h],si
    movzx   edi,word ptr [rbp-88h]
    and     di,[rbp-86h]
    mov     [rbp-84h],di
    movzx   r8d,word ptr [rbp-84h]
    mov     [rbp-82h],r8w
    mov     r9,[rbp+10h]
    movzx   ecx,word ptr [rbp-82h]
    mov     [r9+18h],cx
    mov     r10,[rbp-40h]
    mov     qword ptr [rbp-80h],1
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    add     rdx,r10
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-10h],1
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L6:
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF48h
    lea     rsi,[sym3]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym4]
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF84h
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF8Ah
    mov     esi,0FFFFFF88h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-76h]
    mov     [rbp-72h],ax
    mov     rdx,[rbp+10h]
    movzx   ecx,word ptr [rbp-72h]
    mov     [rdx+18h],cx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    add     rsi,10h
    mov     [rbp-0C0h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-0C0h]
    mov     [rdi+8],rcx
    jmp     L0

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    imul    rcx,[rbp+20h],1
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-0A8h],rsi
    mov     [rbp-0C0h],rsi
    mov     edi,0FFFFFF50h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     edi,0FFFFFF64h
    mov     esi,0FFFFFF60h
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF66h
    mov     esi,0FFFFFF64h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-9Ah]
    mov     qword ptr [rbp-0B0h],10h
    mov     rsi,[rbp+18h]
    imul    rcx,[rbp-0B0h],1
    add     rsi,rcx
    mov     [rbp-8],ax
    mov     rdi,[rbp+10h]
    mov     [rbp-20h],rdi
    mov     [rbp-18h],rsi
    mov     r8,[rbp-98h]
    mov     [rbp-10h],r8
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::RawIterRange::<(std::string::String, usize)>::next_impl::<false>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    movzx   eax,word ptr [rax+18h]
    mov     [rbp-92h],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF6Eh
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF44h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF60h
    xor     esi,esi
    mov     edx,2
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
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-88h],rdx
    cmp     rax,rdx
    jb      L3
    mov     qword ptr [rbp-8],0
    jmp     L4
    nop     [rax+rax]
L3:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-28h],rax
    mov     [rbp-80h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-88h],rdx
    mov     [rbp-0D0h],rdx
    mov     edi,0FFFFFF40h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L14
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    movzx   eax,word ptr [rbp-92h]
    mov     [rbp-0AAh],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF56h
    call    ryo_h_CttzW16
    mov     eax,[rbp-0BCh]
    mov     [rbp-98h],eax
    jmp     L8
L7:
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-88h],0
    cmp     qword ptr [rbp-88h],0
    sete    [rbp-89h]
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L3
    jmp     L2
L8:
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF68h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-0A8h]
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-90h],1
    mov     [rbp-48h],rax
    mov     rsi,[rbp+10h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rbp-88h],si
    sub     esi,1
    mov     [rbp-86h],si
    movzx   edi,word ptr [rbp-88h]
    and     di,[rbp-86h]
    mov     [rbp-84h],di
    movzx   r8d,word ptr [rbp-84h]
    mov     [rbp-82h],r8w
    mov     r9,[rbp+10h]
    movzx   ecx,word ptr [rbp-82h]
    mov     [r9+18h],cx
    mov     r10,[rbp-48h]
    mov     qword ptr [rbp-80h],1
    mov     [rbp-88h],r10
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L9
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rbp-98h],rsi
    jmp     L10
L9:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-0A0h],rax
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L10:
    mov     rax,[rbp-98h]
    mov     [rbp-8],rax
    jmp     L4
L11:
    jmp     L10
L12:
    mov     rax,[rbp-0A0h]
    mov     [rbp-98h],rax
    jmp     L11
L13:
    mov     rax,[rbp-88h]
    mov     qword ptr [rbp-0C0h],0
    mov     rsi,[rbp-0C0h]
    sub     rsi,rax
    mov     rdi,[rbp-0A0h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rbp-98h],rdi
    jmp     L11
L14:
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym3]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym4]
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF84h
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF8Ah
    mov     esi,0FFFFFF88h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-76h]
    mov     [rbp-72h],ax
    mov     rdx,[rbp+10h]
    movzx   ecx,word ptr [rbp-72h]
    mov     [rdx+18h],cx
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L15
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rbp-80h],r8
    jmp     L16
L15:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-88h],rax
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
L16:
    mov     rax,[rbp-80h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-78h]
    mov     [rdx],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     qword ptr [rbp-0C0h],10h
    imul    rcx,[rbp-0C0h],1
    add     rsi,rcx
    mov     [rbp-78h],rsi
    mov     r8,[rbp+10h]
    mov     rcx,[rbp-78h]
    mov     [r8+8],rcx
    jmp     L0
    nop     [rax+rax]
    nop
L17:
    jmp     L16
L18:
    mov     rax,[rbp-88h]
    mov     [rbp-80h],rax
    jmp     L17
L19:
    mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rbp-88h]
    imul    rcx,[rbp-0C0h],20h
    add     rdx,rcx
    mov     [rbp-80h],rdx
    jmp     L17

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     byte ptr [rbp-31h],1
    nop
L0:
    movzx   eax,word ptr [rbp+28h]
    mov     [rbp-9Ah],ax
    mov     edi,0FFFFFF3Ch
    mov     esi,0FFFFFF66h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF3Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF58h
    xor     esi,esi
    mov     edx,2
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
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     byte ptr [rbp-31h],1
    mov     rdx,[rbp-0A0h]
    mov     [rbp+38h],rdx
    mov     rsi,[rbp+30h]
    sub     rsi,1
    mov     [rbp+30h],rsi
    jmp     L0
L3:
    mov     byte ptr [rbp-31h],0
    mov     rdx,[rbp+38h]
    mov     [rbp-8],rdx
    jmp     L5
    xchg    ax,ax
L4:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     [rbp-88h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-90h],rdx
    mov     [rbp-0E0h],rdx
    mov     edi,0FFFFFF38h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L19
L5:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L6:
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     edi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L8:
    jmp     L7
L9:
    test    byte ptr [rbp-31h],0FFh
    je      L7
    jmp     L8
L10:
    call    ryo_h_Unreachable
    ud2
L11:
    movzx   eax,word ptr [rbp-9Ah]
    mov     [rbp-0B2h],ax
    mov     edi,0FFFFFF3Ch
    mov     esi,0FFFFFF4Eh
    call    ryo_h_CttzW16
    mov     eax,[rbp-0C4h]
    mov     [rbp-0A0h],eax
    jmp     L13
L12:
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-90h],0
    cmp     qword ptr [rbp-90h],0
    sete    [rbp-91h]
    mov     rsi,[rbp+30h]
    mov     [rbp-80h],rsi
    cmp     rsi,0
    je      L3
    jmp     L4
L13:
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF60h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-0B0h]
    mov     [rbp-90h],rax
    mov     qword ptr [rbp-98h],1
    movzx   esi,word ptr [rbp+28h]
    mov     [rbp-90h],si
    sub     esi,1
    mov     [rbp-8Eh],si
    movzx   edi,word ptr [rbp-90h]
    and     di,[rbp-8Eh]
    mov     [rbp-8Ch],di
    movzx   r8d,word ptr [rbp-8Ch]
    mov     [rbp+28h],r8w
    mov     qword ptr [rbp-88h],1
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-0C1h],0
    test    byte ptr [rbp-0C1h],0FFh
    je      L14
    mov     rdx,[rbp+10h]
    add     rdx,rax
    mov     [rbp-0A0h],rdx
    jmp     L15
L14:
    mov     rax,[rbp+10h]
    mov     [rbp-0A8h],rax
    mov     byte ptr [rbp-0C1h],0
    test    byte ptr [rbp-0C1h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    mov     rax,[rbp-0A0h]
    lea     rdx,[rbp+40h]
    mov     [rbp-0A8h],rdx
    mov     byte ptr [rbp-31h],0
    mov     rdi,[rbp+38h]
    mov     [rbp-0B8h],rdi
    mov     [rbp-0B0h],rax
    mov     [rbp-0E0h],rdx
    mov     [rbp-0D8h],rdi
    mov     [rbp-0D0h],rax
    call    fn3
    nop     [rcx-0A0h]
    jmp     L2
    xchg    ax,ax
L16:
    jmp     L15
L17:
    mov     rax,[rbp-0A8h]
    mov     [rbp-0A0h],rax
    jmp     L16
L18:
    mov     rax,[rbp-90h]
    mov     qword ptr [rbp-0C8h],0
    mov     rsi,[rbp-0C8h]
    sub     rsi,rax
    mov     rdi,[rbp-0A8h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-0A0h],rdi
    jmp     L16
L19:
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF38h
    lea     rsi,[sym4]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF7Ch
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF82h
    mov     esi,0FFFFFF80h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-7Eh]
    mov     [rbp+28h],ax
    mov     byte ptr [rbp-0C1h],0
    test    byte ptr [rbp-0C1h],0FFh
    je      L20
    mov     rdi,[rbp+10h]
    add     rdi,10h
    mov     [rbp-88h],rdi
    jmp     L21
L20:
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-0C1h],0
    test    byte ptr [rbp-0C1h],0FFh
    je      L24
    jmp     L23
    nop     [rax]
L21:
    mov     rax,[rbp-88h]
    mov     [rbp+10h],rax
    mov     rdx,[rbp+18h]
    mov     qword ptr [rbp-0C8h],10h
    imul    rcx,[rbp-0C8h],1
    add     rdx,rcx
    mov     [rbp+18h],rdx
    jmp     L0
    xchg    ax,ax
L22:
    jmp     L21
L23:
    mov     rax,[rbp-90h]
    mov     [rbp-88h],rax
    jmp     L22
L24:
    mov     qword ptr [rbp-0C8h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rbp-90h]
    imul    rcx,[rbp-0C8h],10h
    add     rdx,rcx
    mov     [rbp-88h],rdx
    jmp     L22
    mov     rdi,rax
    mov     esi,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L6

fn hashbrown::raw::RawIterRange::<(u64, u64)>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    imul    rcx,[rbp+20h],1
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-0A8h],rsi
    mov     [rbp-0C0h],rsi
    mov     edi,0FFFFFF50h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     edi,0FFFFFF64h
    mov     esi,0FFFFFF60h
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF66h
    mov     esi,0FFFFFF64h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-9Ah]
    mov     qword ptr [rbp-0B0h],10h
    mov     rsi,[rbp+18h]
    imul    rcx,[rbp-0B0h],1
    add     rsi,rcx
    mov     [rbp-8],ax
    mov     rdi,[rbp+10h]
    mov     [rbp-20h],rdi
    mov     [rbp-18h],rsi
    mov     r8,[rbp-98h]
    mov     [rbp-10h],r8
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::RawIterRange::<(u64, u64)>::next_impl::<false>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    movzx   eax,word ptr [rax+18h]
    mov     [rbp-92h],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF6Eh
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF44h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF60h
    xor     esi,esi
    mov     edx,2
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
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-88h],rdx
    cmp     rax,rdx
    jb      L3
    mov     qword ptr [rbp-8],0
    jmp     L4
    nop     [rax+rax]
L3:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-28h],rax
    mov     [rbp-80h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-88h],rdx
    mov     [rbp-0D0h],rdx
    mov     edi,0FFFFFF40h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L14
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    movzx   eax,word ptr [rbp-92h]
    mov     [rbp-0AAh],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF56h
    call    ryo_h_CttzW16
    mov     eax,[rbp-0BCh]
    mov     [rbp-98h],eax
    jmp     L8
L7:
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-88h],0
    cmp     qword ptr [rbp-88h],0
    sete    [rbp-89h]
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L3
    jmp     L2
L8:
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF68h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-0A8h]
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-90h],1
    mov     [rbp-48h],rax
    mov     rsi,[rbp+10h]
    movzx   esi,word ptr [rsi+18h]
    mov     [rbp-88h],si
    sub     esi,1
    mov     [rbp-86h],si
    movzx   edi,word ptr [rbp-88h]
    and     di,[rbp-86h]
    mov     [rbp-84h],di
    movzx   r8d,word ptr [rbp-84h]
    mov     [rbp-82h],r8w
    mov     r9,[rbp+10h]
    movzx   ecx,word ptr [rbp-82h]
    mov     [r9+18h],cx
    mov     r10,[rbp-48h]
    mov     qword ptr [rbp-80h],1
    mov     [rbp-88h],r10
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L9
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    add     rsi,r10
    mov     [rbp-98h],rsi
    jmp     L10
L9:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-0A0h],rax
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L10:
    mov     rax,[rbp-98h]
    mov     [rbp-8],rax
    jmp     L4
L11:
    jmp     L10
L12:
    mov     rax,[rbp-0A0h]
    mov     [rbp-98h],rax
    jmp     L11
L13:
    mov     rax,[rbp-88h]
    mov     qword ptr [rbp-0C0h],0
    mov     rsi,[rbp-0C0h]
    sub     rsi,rax
    mov     rdi,[rbp-0A0h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-98h],rdi
    jmp     L11
L14:
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym3]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym4]
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF84h
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF8Ah
    mov     esi,0FFFFFF88h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-76h]
    mov     [rbp-72h],ax
    mov     rdx,[rbp+10h]
    movzx   ecx,word ptr [rbp-72h]
    mov     [rdx+18h],cx
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L15
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    add     r8,10h
    mov     [rbp-80h],r8
    jmp     L16
L15:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-88h],rax
    mov     byte ptr [rbp-0B9h],0
    test    byte ptr [rbp-0B9h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
L16:
    mov     rax,[rbp-80h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-78h]
    mov     [rdx],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     qword ptr [rbp-0C0h],10h
    imul    rcx,[rbp-0C0h],1
    add     rsi,rcx
    mov     [rbp-78h],rsi
    mov     r8,[rbp+10h]
    mov     rcx,[rbp-78h]
    mov     [r8+8],rcx
    jmp     L0
    nop     [rax+rax]
    nop
L17:
    jmp     L16
L18:
    mov     rax,[rbp-88h]
    mov     [rbp-80h],rax
    jmp     L17
L19:
    mov     qword ptr [rbp-0C0h],0FFFFFFFFFFFFFFF0h
    mov     rdx,[rbp-88h]
    imul    rcx,[rbp-0C0h],10h
    add     rdx,rcx
    mov     [rbp-80h],rdx
    jmp     L17

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    lea     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    lea     rdi,[rbp-78h]
    mov     [rbp-68h],rdi
    mov     [rbp-60h],rdi
    mov     edi,0FFFFFFA8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-50h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-8],0
    jmp     L4
L3:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L8
L7:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L8:
    mov     rax,[rbp-70h]
    mov     [rbp-8],rax
    jmp     L4
    nop     [rax+rax]
L9:
    jmp     L8
L10:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L9
L11:
    mov     rax,[rbp-50h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+18h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L3
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L4
L6:
    mov     rax,[rbp+18h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L4
    nop     [rax+rax]
    nop
L7:
    mov     rax,[rbp-60h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-1]
    jmp     L0
L8:
    mov     qword ptr [rbp-60h],8
    jmp     L7
L9:
    mov     rax,[rbp-48h]
    mov     [rbp-68h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-68h]
    mov     [rbp-60h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-68h]
    imul    rcx,[rbp-90h],20h
    add     rdx,rcx
    mov     [rbp-60h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A8h],rdx
    call    fn0
    nop     [rcx-28h]
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     edi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L1:
    lea     rax,[rbp+20h]
    mov     [rbp-98h],rax
    mov     [rbp-0B0h],rax
    call    fn1
    nop     [rcx-98h]
    jmp     L0
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    imul    rcx,[rbp-28h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rbp-51h],al
    mov     rdx,[rbp+18h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF9Eh
    mov     esi,0FFFFFF88h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rbp-62h]
    mov     [rbp-61h],al
    mov     rdx,[rbp-28h]
    sub     rdx,10h
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rbp-70h],rdx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    imul    rcx,[rbp-28h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-61h]
    mov     [rdi],cl
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    imul    rcx,[rbp-70h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-61h]
    mov     [r8],cl
    mov     r9,[rbp+10h]
    mov     r9,[r9]
    mov     [rbp-70h],r9
    mov     [rbp-68h],r9
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L3
    mov     rax,[rbp-28h]
    add     rax,1
    mov     [rbp-78h],rax
    jmp     L4
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L7
    jmp     L6
    nop
L4:
    mov     rax,[rbp-78h]
    mov     [rbp-50h],rax
    mov     [rbp-8],rax
    movzx   edx,byte ptr [rbp-51h]
    and     dl,1
    mov     [rbp-6Ah],dl
    cmp     byte ptr [rbp-6Ah],0
    setne   [rbp-69h]
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF97h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    sub     rax,[rbp-68h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [rdx+10h],rcx
    mov     edi,0FFFFFF80h
    mov     esi,20h
    mov     edx,20h
    call    ryo_h_Copy
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L5:
    jmp     L4
L6:
    mov     rax,[rbp-80h]
    mov     [rbp-78h],rax
    jmp     L5
L7:
    mov     rax,[rbp-28h]
    mov     qword ptr [rbp-98h],0
    mov     rsi,[rbp-98h]
    sub     rsi,rax
    mov     rdi,[rbp-80h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rbp-78h],rdi
    jmp     L5
    nop     [rax]
L8:
    mov     edi,0FFFFFF78h
    xor     esi,esi
    mov     edx,0FFFFFF80h
    mov     ecx,20h
    call    ryo_h_StoreCopy
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    add     rax,1
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [rdx+18h],rcx
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L9:
    mov     qword ptr [rbp-88h],8
    jmp     L8
L10:
    mov     rax,[rbp-50h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L11:
    jmp     L8
L12:
    mov     rax,[rbp-90h]
    mov     [rbp-88h],rax
    jmp     L11
L13:
    mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-90h]
    imul    rcx,[rbp-98h],20h
    add     rdx,rcx
    mov     [rbp-88h],rdx
    jmp     L11
    nop     [rax+rax]
L14:
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx-90h]
    jmp     L16
L15:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L16:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L14

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    cmp     rax,[rbp+18h]
    setb    [rbp-29h]
    test    byte ptr [rbp-29h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFC8h
    mov     rdx,0FFFFFFFFFFFFFFFFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-40h],0
    sete    [rbp-19h]
    nop     [rax]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rbp-1],0FFh
    je      L2
    jmp     L3
L5:
    mov     byte ptr [rbp-1],0
    mov     rdx,[rbp+20h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-60h],rdi
    mov     [rbp-68h],rdx
    mov     byte ptr [rbp-58h],1
    call    fn0
    nop     [rcx-38h]
    jmp     L0
L6:
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L4

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    lea     rdi,[rbp-48h]
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdi
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L0
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rbp-58h]
    mov     [rbp-50h],rax
    jmp     L1
L0:
    mov     qword ptr [rbp-50h],0
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-90h],rsi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    movzx   eax,byte ptr [rbp+28h]
    mov     [rbp-78h],al
    mov     edi,0FFFFFF78h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp-50h]
    mov     [rbp-70h],rax
    call    fn3
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+20h]
    add     rax,1
    mov     [rbp-68h],rax
    jmp     L3
L2:
    mov     rax,[rbp-60h]
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L3:
    mov     rax,[rbp-68h]
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rbp-70h]
    mov     [rbp-68h],rax
    jmp     L4
L6:
    mov     rax,[rbp+20h]
    mov     qword ptr [rbp-88h],0
    mov     rsi,[rbp-88h]
    sub     rsi,rax
    mov     rdi,[rbp-70h]
    imul    rcx,rsi,20h
    add     rdi,rcx
    mov     [rbp-68h],rdi
    jmp     L4
    nop     [rax+rax]
    nop
L7:
    mov     rax,[rbp-58h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L0
L8:
    mov     qword ptr [rbp-58h],8
    jmp     L7
L9:
    mov     rax,[rbp-40h]
    mov     [rbp-60h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-60h]
    mov     [rbp-58h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-60h]
    imul    rcx,[rbp-88h],20h
    add     rdx,rcx
    mov     [rbp-58h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#1}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    lea     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rax
    call    fn0
    nop     [rcx]
    mov     byte ptr [rbp-21h],0
    test    byte ptr [rbp-21h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rbp-10h]
    mov     [rbp-18h],rax
    mov     [rbp-40h],rax
    mov     edi,0FFFFFFD8h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L6
L1:
    mov     qword ptr [rbp-10h],8
    jmp     L0
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     byte ptr [rbp-21h],0
    test    byte ptr [rbp-21h],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    jmp     L0
L4:
    mov     rax,[rbp-18h]
    mov     [rbp-10h],rax
    jmp     L3
L5:
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-18h]
    imul    rcx,[rbp-28h],10h
    add     rdx,rcx
    mov     [rbp-10h],rdx
    jmp     L3
L6:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-33h],0
    test    byte ptr [rbp-33h],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-60h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-58h],rdx
    call    fn0
    nop     [rcx-8]
    jmp     L0
L2:
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    sub     rax,1
    mov     [rbp-8],rax
    jmp     L1
L3:
    mov     rax,[rbp-18h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-28h],rdx
    mov     qword ptr [rbp-40h],0
    cmp     qword ptr [rbp-40h],10h
    setb    [rbp-31h]
    test    byte ptr [rbp-31h],0FFh
    je      L6
    jmp     L5
    nop
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-8],rax
    jmp     L1
L5:
    mov     qword ptr [rbp-40h],10h
    mov     rdx,[rbp-40h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rbp-32h]
    test    byte ptr [rbp-32h],0FFh
    je      L6
    mov     rdi,[rbp-20h]
    sub     rdi,[rbp-28h]
    mov     [rbp-30h],rdi
    mov     qword ptr [rbp-40h],10h
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    call    ryo_h_DivSW64
    jmp     L4
L6:
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],49h
    mov     edi,0FFFFFFB0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFC0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-8]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L8:
    call    ryo_h_Unreachable
    ud2

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    lea     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    lea     rdi,[rbp-78h]
    mov     [rbp-68h],rdi
    mov     [rbp-60h],rdi
    mov     edi,0FFFFFFA8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-50h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-8],0
    jmp     L4
L3:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L8
L7:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L8:
    mov     rax,[rbp-70h]
    mov     [rbp-8],rax
    jmp     L4
    nop     [rax+rax]
L9:
    jmp     L8
L10:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L9
L11:
    mov     rax,[rbp-50h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+18h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L3
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L4
L6:
    mov     rax,[rbp+18h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L4
    nop     [rax+rax]
    nop
L7:
    mov     rax,[rbp-60h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-1]
    jmp     L0
L8:
    mov     qword ptr [rbp-60h],8
    jmp     L7
L9:
    mov     rax,[rbp-48h]
    mov     [rbp-68h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-68h]
    mov     [rbp-60h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-68h]
    imul    rcx,[rbp-90h],10h
    add     rdx,rcx
    mov     [rbp-60h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    lea     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    lea     rdi,[rbp-78h]
    mov     [rbp-68h],rdi
    mov     [rbp-60h],rdi
    mov     edi,0FFFFFFA8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-50h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-8],0
    jmp     L4
L3:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L8
L7:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L8:
    mov     rax,[rbp-70h]
    mov     [rbp-8],rax
    jmp     L4
    nop     [rax+rax]
L9:
    jmp     L8
L10:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L9
L11:
    mov     rax,[rbp-50h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     rdx,[rdx]
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+18h]
    add     rax,1
    mov     [rbp-70h],rax
    jmp     L3
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rbp-78h]
    mov     [rbp-70h],rax
    jmp     L4
L6:
    mov     rax,[rbp+18h]
    mov     qword ptr [rbp-90h],0
    mov     rsi,[rbp-90h]
    sub     rsi,rax
    mov     rdi,[rbp-78h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-70h],rdi
    jmp     L4
    nop     [rax+rax]
    nop
L7:
    mov     rax,[rbp-60h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-1]
    jmp     L0
L8:
    mov     qword ptr [rbp-60h],8
    jmp     L7
L9:
    mov     rax,[rbp-48h]
    mov     [rbp-68h],rax
    mov     byte ptr [rbp-89h],0
    test    byte ptr [rbp-89h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-68h]
    mov     [rbp-60h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-68h]
    imul    rcx,[rbp-90h],10h
    add     rdx,rcx
    mov     [rbp-60h],rdx
    jmp     L10

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A8h],rdx
    call    fn0
    nop     [rcx-28h]
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     edi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L1:
    jmp     L0
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    imul    rcx,[rbp-28h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rbp-51h],al
    mov     rdx,[rbp+18h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF9Eh
    mov     esi,0FFFFFF88h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rbp-62h]
    mov     [rbp-61h],al
    mov     rdx,[rbp-28h]
    sub     rdx,10h
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rbp-70h],rdx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    imul    rcx,[rbp-28h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-61h]
    mov     [rdi],cl
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    imul    rcx,[rbp-70h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-61h]
    mov     [r8],cl
    mov     r9,[rbp+10h]
    mov     r9,[r9]
    mov     [rbp-70h],r9
    mov     [rbp-68h],r9
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L3
    mov     rax,[rbp-28h]
    add     rax,1
    mov     [rbp-78h],rax
    jmp     L4
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rbp-78h]
    mov     [rbp-50h],rax
    mov     [rbp-8],rax
    movzx   edx,byte ptr [rbp-51h]
    and     dl,1
    mov     [rbp-6Ah],dl
    cmp     byte ptr [rbp-6Ah],0
    setne   [rbp-69h]
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF97h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    sub     rax,[rbp-68h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [rdx+10h],rcx
    mov     edi,0FFFFFF90h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
L5:
    jmp     L4
L6:
    mov     rax,[rbp-80h]
    mov     [rbp-78h],rax
    jmp     L5
L7:
    mov     rax,[rbp-28h]
    mov     qword ptr [rbp-98h],0
    mov     rsi,[rbp-98h]
    sub     rsi,rax
    mov     rdi,[rbp-80h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-78h],rdi
    jmp     L5
    nop     [rax]
L8:
    mov     edi,0FFFFFF88h
    xor     esi,esi
    mov     edx,0FFFFFF90h
    call    ryo_h_StoreW128
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    add     rax,1
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [rdx+18h],rcx
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L9:
    mov     qword ptr [rbp-78h],8
    jmp     L8
L10:
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    mov     byte ptr [rbp-91h],0
    test    byte ptr [rbp-91h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L11:
    jmp     L8
L12:
    mov     rax,[rbp-80h]
    mov     [rbp-78h],rax
    jmp     L11
L13:
    mov     qword ptr [rbp-98h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-80h]
    imul    rcx,[rbp-98h],10h
    add     rdx,rcx
    mov     [rbp-78h],rdx
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L1

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    cmp     rax,[rbp+18h]
    setb    [rbp-29h]
    test    byte ptr [rbp-29h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFC8h
    mov     rdx,0FFFFFFFFFFFFFFFFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-40h],0
    sete    [rbp-19h]
    nop     [rax]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rbp-1],0FFh
    je      L2
    jmp     L3
L5:
    mov     byte ptr [rbp-1],0
    mov     rdx,[rbp+20h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-60h],rdi
    mov     [rbp-68h],rdx
    mov     byte ptr [rbp-58h],1
    call    fn0
    nop     [rcx-38h]
    jmp     L0
L6:
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L4

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    lea     rdi,[rbp-48h]
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdi
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L0
    mov     edi,0FFFFFFA8h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rbp-58h]
    mov     [rbp-50h],rax
    jmp     L1
L0:
    mov     qword ptr [rbp-50h],0
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-90h],rsi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    movzx   eax,byte ptr [rbp+28h]
    mov     [rbp-78h],al
    mov     edi,0FFFFFF78h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp-50h]
    mov     [rbp-70h],rax
    call    fn3
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+20h]
    add     rax,1
    mov     [rbp-68h],rax
    jmp     L3
L2:
    mov     rax,[rbp-60h]
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L3:
    mov     rax,[rbp-68h]
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    mov     rax,[rbp-70h]
    mov     [rbp-68h],rax
    jmp     L4
L6:
    mov     rax,[rbp+20h]
    mov     qword ptr [rbp-88h],0
    mov     rsi,[rbp-88h]
    sub     rsi,rax
    mov     rdi,[rbp-70h]
    imul    rcx,rsi,10h
    add     rdi,rcx
    mov     [rbp-68h],rdi
    jmp     L4
    nop     [rax+rax]
    nop
L7:
    mov     rax,[rbp-58h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L0
L8:
    mov     qword ptr [rbp-58h],8
    jmp     L7
L9:
    mov     rax,[rbp-40h]
    mov     [rbp-60h],rax
    mov     byte ptr [rbp-81h],0
    test    byte ptr [rbp-81h],0FFh
    je      L12
    jmp     L11
    nop
L10:
    jmp     L7
L11:
    mov     rax,[rbp-60h]
    mov     [rbp-58h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-88h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-60h]
    imul    rcx,[rbp-88h],10h
    add     rdx,rcx
    mov     [rbp-58h],rdx
    jmp     L10

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-99h],1
    test    byte ptr [rbp-99h],0FFh
    je      L4
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    mov     [rbp-50h],rsi
    cmp     rsi,0
    je      L4
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-88h],r8
    mov     [rbp-58h],r8
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L7
    jmp     L6
L0:
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop     [rax+rax]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-78h]
    mov     [rbp-80h],rax
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L3:
    jmp     L4
L4:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-78h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-78h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFD8h
    mov     edx,28h
    call    ryo_h_Copy
    jmp     L0
L6:
    mov     qword ptr [rbp-90h],1
    jmp     L8
L7:
    mov     rax,[rbp-88h]
    mov     [rbp-90h],rax
L8:
    mov     rax,[rbp-90h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-78h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rbp-80h],rsi
    mov     [rbp-0B8h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B0h],rsi
    call    fn0
    nop     [rcx-70h]
    jmp     L5
L9:
    mov     qword ptr [rbp-78h],0
    jmp     L3
L10:
    lea     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     [rbp-0C0h],rax
    call    fn1
    nop     [rcx-78h]
    mov     rax,[rbp-50h]
    sub     rax,1
    mov     [rbp-50h],rax
    mov     edi,0FFFFFF64h
    mov     esi,0FFFFFF88h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFF64h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
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
    mov     rax,[rbp-88h]
    mov     [rbp-90h],rax
    mov     [rbp-0C0h],rax
    call    fn2
    nop     [rcx-48h]
    jmp     L18
L13:
    mov     qword ptr [rbp-88h],8
    jmp     L12
L14:
    mov     rax,[rbp-80h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L15:
    jmp     L12
L16:
    mov     rax,[rbp-90h]
    mov     [rbp-88h],rax
    jmp     L15
L17:
    mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-90h]
    imul    rcx,[rbp-0A0h],20h
    add     rdx,rcx
    mov     [rbp-88h],rdx
    jmp     L15
L18:
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_elements::<(u64, u64)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L4
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    mov     [rbp-50h],rsi
    cmp     rsi,0
    je      L4
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-88h],r8
    mov     [rbp-58h],r8
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L7
    jmp     L6
L0:
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop     [rax+rax]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-78h]
    mov     [rbp-80h],rax
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L3:
    jmp     L4
L4:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-78h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-78h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFD8h
    mov     edx,28h
    call    ryo_h_Copy
    jmp     L0
L6:
    mov     qword ptr [rbp-90h],1
    jmp     L8
L7:
    mov     rax,[rbp-88h]
    mov     [rbp-90h],rax
L8:
    mov     rax,[rbp-90h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-78h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rbp-80h],rsi
    mov     [rbp-0B8h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B0h],rsi
    call    fn0
    nop     [rcx-70h]
    jmp     L5
L9:
    mov     qword ptr [rbp-78h],0
    jmp     L3
L10:
    lea     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     [rbp-0C0h],rax
    call    fn1
    nop     [rcx-78h]
    mov     rax,[rbp-50h]
    sub     rax,1
    mov     [rbp-50h],rax
    mov     edi,0FFFFFF64h
    mov     esi,0FFFFFF88h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFF64h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
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
    mov     rax,[rbp-88h]
    mov     [rbp-90h],rax
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF60h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
    jmp     L18
L13:
    mov     qword ptr [rbp-88h],8
    jmp     L12
L14:
    mov     rax,[rbp-80h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-99h],0
    test    byte ptr [rbp-99h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    jmp     L12
L16:
    mov     rax,[rbp-90h]
    mov     [rbp-88h],rax
    jmp     L15
L17:
    mov     qword ptr [rbp-0A0h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-90h]
    imul    rcx,[rbp-0A0h],10h
    add     rdx,rcx
    mov     [rbp-88h],rdx
    jmp     L15
L18:
    jmp     L0

fn hashbrown::raw::RawTableInner::drop_inner_table::<(std::string::String, usize), std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rbp-19h]
    test    byte ptr [rbp-19h],0FFh
    jne     L0
    mov     rdi,[rbp+10h]
    mov     [rbp-90h],rdi
    call    fn0
    nop     [rcx]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rbp-40h],rax
    mov     edi,0FFFFFF70h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-40h]
    mov     [rbp-80h],rax
    call    fn1
    nop     [rcx-38h]
    jmp     L2
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     edi,0FFFFFF94h
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF94h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-40h],1
    sete    [rbp-1Ah]
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp-28h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     qword ptr [rbp-70h],0
    mov     rdi,[rbp-70h]
    sub     rdi,rax
    imul    rcx,rdi,1
    add     rdx,rcx
    mov     [rbp-48h],rdx
    mov     r8,[rbp+18h]
    mov     [rbp-90h],r8
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx]
    jmp     L1

fn hashbrown::raw::RawTableInner::drop_inner_table::<(u64, u64), std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rbp-19h]
    test    byte ptr [rbp-19h],0FFh
    jne     L0
    mov     rdi,[rbp+10h]
    mov     [rbp-90h],rdi
    call    fn0
    nop     [rcx]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rbp-40h],rax
    mov     edi,0FFFFFF70h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-40h]
    mov     [rbp-80h],rax
    call    fn1
    nop     [rcx-38h]
    jmp     L2
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     edi,0FFFFFF94h
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF94h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-40h],1
    sete    [rbp-1Ah]
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp-28h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     qword ptr [rbp-70h],0
    mov     rdi,[rbp-70h]
    sub     rdi,rax
    imul    rcx,rdi,1
    add     rdx,rcx
    mov     [rbp-48h],rdx
    mov     r8,[rbp+18h]
    mov     [rbp-90h],r8
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx]
    jmp     L1

fn hashbrown::raw::RawTableInner::erase
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    sub     rax,10h
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    imul    rcx,rax,1
    add     rsi,rcx
    mov     [rbp-20h],rsi
    mov     [rbp-68h],rsi
    mov     rdi,[rbp-20h]
    mov     [rbp-70h],rdi
    mov     [rbp-0C0h],rdi
    mov     edi,0FFFFFF70h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L3
    nop     [rax]
L0:
    mov     byte ptr [rbp-11h],80h
    jmp     L2
    nop     [rax+rax]
    nop
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [rdx+10h],rcx
    mov     byte ptr [rbp-11h],0FFh
L2:
    mov     rax,[rbp+18h]
    sub     rax,10h
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    add     rax,10h
    mov     [rbp-68h],rax
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    imul    rcx,[rbp+18h],1
    add     rsi,rcx
    movzx   ecx,byte ptr [rbp-11h]
    mov     [rsi],cl
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    imul    rcx,[rbp-68h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-11h]
    mov     [rdi],cl
    mov     r8,[rbp+10h]
    mov     r8,[r8+18h]
    sub     r8,1
    mov     [rbp-0A0h],r8
    mov     r9,[rbp+10h]
    mov     rcx,[rbp-0A0h]
    mov     [r9+18h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     byte ptr [rbp-0C0h],0FFh
    mov     edi,0FFFFFF70h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    lea     rsi,[sym4]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym5]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    lea     rsi,[sym6]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+52]
    call    qword ptr [sym7]
    mov     edi,0FFFFFFCEh
    mov     esi,0FFFFFF8Ch
    call    ryo_h_TruncW32W16
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    imul    rcx,[rbp+18h],1
    add     rax,rcx
    mov     [rbp-40h],rax
    mov     [rbp-68h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-70h],rdx
    mov     [rbp-0C0h],rdx
    mov     edi,0FFFFFF70h
    lea     rsi,[sym8]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+68]
    call    qword ptr [sym9]
    mov     byte ptr [rbp-0C0h],0FFh
    mov     edi,0FFFFFF70h
    lea     rsi,[sym10]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym11]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    lea     rsi,[sym12]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym13]
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    lea     rsi,[sym14]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+52]
    call    qword ptr [sym15]
    mov     edi,0FFFFFFAEh
    mov     esi,0FFFFFF8Ch
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF74h
    mov     esi,0FFFFFFCEh
    call    ryo_h_CtlzW16
    mov     eax,[rbp-8Ch]
    mov     [rbp-74h],eax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF74h
    mov     esi,0FFFFFFAEh
    call    ryo_h_CttzW16
    mov     eax,[rbp-8Ch]
    mov     [rbp-7Ch],eax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF84h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-70h]
    add     rax,[rbp-78h]
    mov     [rbp-68h],rax
    cmp     rax,10h
    jae     L0
    jmp     L1

fn hashbrown::raw::RawTableInner::fallible_with_capacity::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,100h
    cmp     qword ptr [rbp+28h],0
    jne     L0
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    mov     edx,20h
    call    ryo_h_Const
    jmp     L5
L0:
    mov     rax,[rbp+28h]
    mov     [rbp-100h],rax
    mov     edi,0FFFFFF08h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-90h]
    mov     rax,[rbp-90h]
    mov     [rbp-98h],rax
    mov     edi,0FFFFFF68h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L1:
    .long   L7
    .long   L10
    .long   L2
L2:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFF34h
    mov     esi,0FFFFFF60h
    xor     edx,edx
    mov     ecx,1
    mov     r8d,1
    xor     r9d,r9d
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF34h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF58h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L4:
    .long   L13
    .long   L12
    .long   L2
    nop     [rax]
L5:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
L7:
    movzx   eax,byte ptr [rbp+30h]
    mov     [rbp-100h],al
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF30h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-0A8h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L9:
    jmp     L11
L10:
    mov     rax,[rbp-88h]
    mov     [rbp-78h],rax
    mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    mov     [rbp-68h],rax
    mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    mov     [rbp-30h],rax
    mov     rdi,[rbp+10h]
    mov     [rbp-100h],rdi
    mov     edi,0FFFFFF08h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-30h]
    mov     [rbp-0E8h],rax
    movzx   edx,byte ptr [rbp+30h]
    mov     [rbp-0E0h],dl
    call    fn5
    nop     [rcx-0A0h]
    jmp     L3
L11:
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF60h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-88h],1
    cmp     qword ptr [rbp-88h],1
    sete    [rbp-99h]
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-20h],0
    jmp     L6
L12:
    mov     edi,0FFFFFF48h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF38h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],0
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-98h],1
    cmp     qword ptr [rbp-98h],1
    sete    [rbp-0A9h]
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-20h],0
    jmp     L6
L13:
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFF60h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF38h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF80h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp-50h]
    mov     rdx,[rbp-48h]
    add     rdx,1
    add     rdx,10h
    mov     [rbp-60h],rdx
    mov     [rbp-78h],rax
    mov     byte ptr [rbp-0C9h],0FFh
    imul    rdi,[rbp-60h],1
    mov     [rbp-0D8h],rdi
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF37h
    mov     edx,0FFFFFF28h
    call    ryo_h_Memset
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFB0h
    mov     edx,20h
    call    ryo_h_Copy
    jmp     L5

fn hashbrown::raw::RawTableInner::find_inner
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     rax,[rbp+18h]
    shr     rax,39h
    and     rax,7Fh
    mov     [rbp-80h],rax
    mov     edi,0FFFFFFD7h
    mov     esi,0FFFFFF80h
    call    ryo_h_TruncW64W8
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-78h],0
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rbp-80h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rbp-38h],rdx
    mov     [rbp-88h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-90h],rsi
    mov     [rbp-0E0h],rsi
    mov     edi,0FFFFFF40h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L6
    nop     [rax+rax]
    xchg    ax,ax
L1:
    movzx   eax,word ptr [rbp-12h]
    mov     [rbp-6Ch],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF94h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF44h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF58h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L2:
    .long   L8
    .long   L7
    .long   L3
L3:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L4:
    test    byte ptr [rbp-6Bh],0FFh
    je      L14
    jmp     L13
    nop
L5:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L6:
    movzx   eax,byte ptr [rbp-29h]
    mov     [rbp-6Dh],al
    mov     [rbp-0E0h],al
    mov     edi,0FFFFFF40h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF60h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym4]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym5]
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym6]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+52]
    call    qword ptr [sym7]
    mov     edi,0FFFFFF92h
    mov     esi,0FFFFFF6Ch
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rbp-6Eh]
    mov     [rbp-12h],ax
    jmp     L1
L7:
    movzx   eax,word ptr [rbp-6Ch]
    mov     [rbp-70h],ax
    mov     edi,0FFFFFF44h
    mov     esi,0FFFFFF90h
    call    ryo_h_CttzW16
    mov     eax,[rbp-0BCh]
    mov     [rbp-0B4h],eax
    jmp     L9
L8:
    mov     edi,0FFFFFF60h
    lea     rsi,[k8]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-98h],0
    cmp     qword ptr [rbp-98h],0
    sete    [rbp-6Bh]
    mov     byte ptr [rbp-0E0h],0FFh
    mov     edi,0FFFFFF40h
    lea     rsi,[sym9]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
    jmp     L12
L9:
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF4Ch
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-0B0h]
    mov     [rbp-98h],rax
    mov     qword ptr [rbp-0A0h],1
    movzx   esi,word ptr [rbp-12h]
    mov     [rbp-92h],si
    sub     esi,1
    mov     [rbp-70h],si
    movzx   edi,word ptr [rbp-92h]
    and     di,[rbp-70h]
    mov     [rbp-6Eh],di
    movzx   r8d,word ptr [rbp-6Eh]
    mov     [rbp-12h],r8w
    mov     qword ptr [rbp-90h],1
    mov     r10,[rbp-80h]
    add     r10,rax
    mov     r11,[rbp+10h]
    mov     r11,[r11+8]
    and     r10,r11
    mov     [rbp-0A0h],r10
    mov     [rbp-0A8h],r10
    mov     rdx,[rbp+28h]
    mov     rdx,[rdx+20h]
    mov     [rbp-0C0h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0E0h],rsi
    mov     [rbp-0D8h],r10
    mov     edi,0FFFFFF40h
    lea     rsi,[site11]
    call    ryo_h_CallInd
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx-6Bh]
    jmp     L11
L10:
    mov     rdi,rbp
    lea     rsi,[ro+68]
    call    qword ptr [sym12]
L11:
    jmp     L4
L12:
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF60h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym13]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF40h
    lea     rsi,[sym15]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+84]
    call    qword ptr [sym16]
    mov     edi,0FFFFFF96h
    mov     esi,0FFFFFF90h
    call    ryo_h_TruncW32W16
    cmp     word ptr [rbp-6Ah],0
    setne   [rbp-6Bh]
    cmp     word ptr [rbp-6Ah],0
    je      L16
    jmp     L15
L13:
    mov     rax,[rbp-0A0h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L5
L14:
    jmp     L1
L15:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k17]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L5
L16:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp-78h]
    add     rdx,10h
    mov     [rbp-78h],rdx
    mov     rsi,[rbp-80h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rbp-80h],rsi
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    nop     [rax+rax]
L0:
    mov     rax,[rbp-40h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rbp-20h],rdx
    mov     [rbp-58h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-60h],rsi
    mov     [rbp-90h],rsi
    mov     edi,0FFFFFF88h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L3
    nop     [rax]
L1:
    mov     rax,[rbp-60h]
    mov     [rbp-28h],rax
    cmp     rax,1
    sete    [rbp-2Ah]
    cmp     rax,1
    je      L4
    jmp     L5
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rax,[rbp-50h]
    mov     [rbp-68h],rax
    lea     rdx,[rbp-40h]
    mov     [rbp-70h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rax
    mov     [rbp-80h],rdx
    call    fn2
    nop     [rcx-60h]
    jmp     L1
L4:
    cmp     qword ptr [rbp-28h],1
    sete    [rbp-29h]
    mov     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rdx
    call    fn3
    nop     [rcx-8]
    jmp     L2
L5:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp-38h]
    add     rdx,10h
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-40h]
    add     rsi,rdx
    and     rsi,rax
    mov     [rbp-40h],rsi
    jmp     L0

fn hashbrown::raw::RawTableInner::find_insert_index_in_group
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     edi,0FFFFFFB0h
    mov     esi,18h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L1
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     edi,0FFFFFFD6h
    mov     esi,0FFFFFFC8h
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rbp-2Ah]
    mov     [rbp-36h],ax
    mov     edi,0FFFFFFA4h
    mov     esi,0FFFFFFCAh
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L2:
    .long   L4
    .long   L3
    .long   L6
L3:
    movzx   eax,word ptr [rbp-36h]
    mov     [rbp-4Eh],ax
    mov     edi,0FFFFFFA4h
    mov     esi,0FFFFFFB2h
    call    ryo_h_CttzW16
    mov     eax,[rbp-5Ch]
    mov     [rbp-4Ch],eax
    jmp     L5
L4:
    mov     edi,0FFFFFFE0h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp-20h]
    mov     [rbp-40h],rax
    cmp     rax,1
    sete    [rbp-35h]
    jmp     L7
L5:
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFB4h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-48h]
    mov     [rbp-18h],rax
    mov     qword ptr [rbp-20h],1
    mov     rsi,[rbp-20h]
    mov     [rbp-40h],rsi
    cmp     rsi,1
    sete    [rbp-35h]
    mov     r8,[rbp+20h]
    mov     r8,[r8]
    add     r8,rax
    mov     r9,[rbp+10h]
    mov     r9,[r9+8]
    and     r8,r9
    mov     [rbp-8],r8
    mov     qword ptr [rbp-10h],1
    jmp     L0
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k3]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L0

fn hashbrown::raw::RawTableInner::fix_insert_index
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    imul    rcx,rax,1
    add     rdx,rcx
    movzx   edx,byte ptr [rdx]
    and     dl,80h
    mov     [rbp-4Fh],dl
    cmp     byte ptr [rbp-4Fh],0
    sete    [rbp-4Eh]
    test    byte ptr [rbp-4Eh],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-68h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-70h],rdx
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF80h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L3
L2:
    jmp     L0
L3:
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF80h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym3]
    mov     edi,0FFFFFFBEh
    mov     esi,0FFFFFF9Ch
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rbp-42h]
    mov     [rbp-50h],ax
    mov     edi,0FFFFFF84h
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW16
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF84h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF98h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L4:
    .long   L7
    .long   L6
    .long   L9
    nop     [rax]
L5:
    mov     rax,[rbp-60h]
    cmp     rax,1
    sete    [rbp-4Dh]
    mov     rsi,[rbp-58h]
    mov     [rbp+18h],rsi
    jmp     L0
L6:
    movzx   eax,word ptr [rbp-50h]
    mov     [rbp-6Ch],ax
    mov     edi,0FFFFFF84h
    mov     esi,0FFFFFF94h
    call    ryo_h_CttzW16
    mov     eax,[rbp-7Ch]
    mov     [rbp-70h],eax
    jmp     L8
L7:
    mov     edi,0FFFFFFA0h
    lea     rsi,[k4]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L5
L8:
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF90h
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-78h]
    mov     [rbp-58h],rax
    mov     qword ptr [rbp-60h],1
    jmp     L5
L9:
    call    ryo_h_Unreachable
    ud2

fn hashbrown::raw::RawTableInner::new_uninitialized::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,110h
    mov     rax,[rbp+28h]
    mov     [rbp-88h],rax
    mov     edi,0FFFFFEF0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-88h]
    mov     [rbp-100h],rax
    call    fn0
    nop     [rcx-0A8h]
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-20h],0
    jmp     L14
L1:
    mov     edi,0FFFFFF14h
    mov     esi,0FFFFFF58h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFF14h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L2:
    .long   L4
    .long   L3
    .long   L7
L3:
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     rax,[rbp-98h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-110h],rdx
    mov     edi,0FFFFFEF8h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-0B8h]
    jmp     L15
L4:
    movzx   eax,byte ptr [rbp+30h]
    mov     [rbp-110h],al
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF10h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-90h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L6:
    jmp     L0
L7:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L8:
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+20h]
    mov     [rbp-0E8h],rdx
    mov     rsi,[rbp-38h]
    sub     rsi,10h
    mov     [rbp-0C8h],rsi
    add     rax,1
    mov     [rbp-0D0h],rax
    cmp     rax,0
    jne     L21
    mov     edi,0FFFFFEF0h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF10h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx-0E8h]
    jmp     L10
L9:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L10:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    mov     edi,0FFFFFF14h
    mov     esi,0FFFFFF30h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFF28h
    mov     esi,0FFFFFF14h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-0D8h],1
    sete    [rbp-79h]
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    mov     rax,[rbp-0C0h]
    mov     [rbp-78h],rax
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L12:
    mov     rax,[rbp-70h]
    imul    rcx,[rbp-78h],1
    add     rax,rcx
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+28h]
    sub     rdx,1
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp+28h]
    sub     rsi,1
    mov     [rbp-60h],rsi
    cmp     rsi,8
    jb      L22
    jmp     L23
    nop     [rax]
L13:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-20h],0
    nop     [rax+rax]
L14:
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
L15:
    mov     edi,0FFFFFF14h
    mov     esi,0FFFFFF48h
    xor     edx,edx
    mov     ecx,1
    mov     r8d,1
    xor     r9d,r9d
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF14h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF40h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L16]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L16:
    .long   L20
    .long   L17
    .long   L7
L17:
    movzx   eax,byte ptr [rbp+30h]
    mov     [rbp-110h],al
    mov     edi,0FFFFFEF8h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    lea     rdi,[sym9]
    lea     rsi,[site10]
    mov     edx,0FFFFFF10h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx-0B8h]
    jmp     L19
L18:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym11]
L19:
    jmp     L13
L20:
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF48h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     rax,[rbp-68h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-0C0h],rdx
    cmp     rax,rdx
    jne     L8
    jmp     L12
L21:
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF30h
    call    ryo_h_DivUW64
    mov     rax,[rbp-0C0h]
    mov     [rbp-0D8h],rax
    mov     edi,0FFFFFF14h
    mov     esi,0FFFFFF28h
    call    ryo_h_CtlzW64
    mov     eax,[rbp-0ECh]
    mov     [rbp-80h],eax
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF80h
    call    ryo_h_ZextW32W64
    mov     qword ptr [rbp-0F0h],3Fh
    mov     rdx,[rbp-0F0h]
    sub     rdx,[rbp-0D0h]
    mov     [rbp-0C8h],rdx
    mov     qword ptr [rbp-0F0h],1
    mov     edi,28h
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFF38h
    call    ryo_h_ShlW64
    mov     edi,0FFFFFEF0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-100h],rax
    call    fn12
    nop     [rcx-0D0h]
    jmp     L11
L22:
    jmp     L24
L23:
    mov     rax,[rbp-60h]
    add     rax,1
    mov     [rbp-0D8h],rax
    mov     qword ptr [rbp-0F0h],8
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFF10h
    call    ryo_h_DivUW64
    imul    rax,[rbp-0D0h],7
    mov     [rbp-60h],rax
L24:
    mov     rax,[rbp-0C8h]
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-0A0h]
    mov     [rbp-0C0h],rdx
    mov     rsi,[rbp-60h]
    mov     [rbp-0B0h],rsi
    mov     qword ptr [rbp-0A8h],0
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFF40h
    mov     edx,20h
    call    ryo_h_Copy
    jmp     L14

fn hashbrown::raw::RawTableInner::prepare_rehash_in_place
    push    rbp
    mov     rbp,rsp
    sub     rsp,120h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rbp-98h],0
    mov     [rbp-90h],rax
    mov     edi,0FFFFFEE0h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-110h],10h
    call    fn0
    nop     [rcx-20h]
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rbp-10h]
    add     rax,1
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF0Ch
    mov     esi,0FFFFFF40h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFF0Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-0C8h],1
    sete    [rbp-81h]
    mov     rdx,[rbp-0C0h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-0A0h],rsi
    cmp     rsi,0
    ja      L4
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFF10h
    mov     esi,0FFFFFF40h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    imul    rcx,[rbp-0A0h],1
    add     rax,rcx
    mov     [rbp-58h],rax
    mov     [rbp-0C8h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-0D0h],rdx
    mov     [rbp-120h],rdx
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF08h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L7
    nop     [rax+rax]
    nop     [rax]
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    jmp     L0
L4:
    mov     rax,[rbp-20h]
    mov     [rbp-0B0h],rax
    add     rax,[rbp-0A8h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp-0A0h]
    sub     rdx,1
    mov     [rbp-18h],rdx
    mov     rsi,[rbp-0B0h]
    mov     qword ptr [rbp-98h],1
    mov     [rbp-0A0h],rsi
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    imul    rcx,rsi,1
    add     r8,rcx
    mov     [rbp-38h],r8
    mov     [rbp-0B8h],r8
    mov     r9,[rbp-38h]
    mov     [rbp-0C0h],r9
    mov     [rbp-120h],r9
    mov     edi,0FFFFFF08h
    lea     rsi,[sym3]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym4]
    jmp     L6
L5:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    add     rax,1
    cmp     rax,10h
    setb    [rbp-82h]
    test    byte ptr [rbp-82h],0FFh
    je      L9
    jmp     L8
L6:
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEE0h
    mov     esi,0FFFFFF50h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx-0C0h]
    jmp     L1
L7:
    jmp     L0
L8:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-78h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     qword ptr [rbp-0F8h],10h
    imul    rcx,[rbp-0F8h],1
    add     rdx,rcx
    mov     [rbp-98h],rdx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi+8]
    add     rdi,1
    mov     [rbp-0A0h],rdi
    mov     r8,[rbp-78h]
    mov     [rbp-0A8h],r8
    imul    r9,rdi,1
    mov     [rbp-0F8h],r9
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF08h
    call    ryo_h_Memmove
    jmp     L10
L9:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-80h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    add     rdx,1
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rbp-98h],rsi
    mov     rdi,[rbp-80h]
    mov     [rbp-0A0h],rdi
    mov     qword ptr [rbp-0F8h],10h
    imul    r9,[rbp-0F8h],1
    mov     [rbp-100h],r9
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF00h
    call    ryo_h_Memmove
    jmp     L11
L10:
    jmp     L2
L11:
    jmp     L2

fn hashbrown::raw::RawTableInner::prepare_resize::<std::alloc::Global>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     rax,[rax+8]
    cmp     rax,0
    sete    [rbp-21h]
    test    byte ptr [rbp-21h],0FFh
    jne     L0
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-8],rdi
    mov     edi,0FFFFFFC8h
    mov     esi,10h
    mov     edx,8
    call    ryo_h_LoadW128
    mov     rax,[rbp+18h]
    mov     rax,[rax+8]
    add     rax,1
    mov     [rbp-58h],rax
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp-58h]
    mov     [rbp-0A0h],rax
    call    fn0
    nop     [rcx-50h]
    jmp     L2
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     edi,0FFFFFF7Ch
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF7Ch
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-58h],1
    sete    [rbp-22h]
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp-40h]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     qword ptr [rbp-88h],0
    mov     rdi,[rbp-88h]
    sub     rdi,rax
    imul    rcx,rdi,1
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     r8,[rbp-8]
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-8]
    jmp     L1

fn hashbrown::raw::RawTableInner::rehash_in_place
    push    rbp
    mov     rbp,rsp
    sub     rsp,1F0h
    mov     rax,[rbp+10h]
    mov     [rbp-1F0h],rax
    call    fn0
    nop     [rcx]
    mov     rax,[rbp+30h]
    mov     [rbp-168h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-160h],rdx
    mov     edi,0FFFFFEB0h
    mov     esi,0FFFFFE98h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-158h],rax
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rbp-10h],0
    mov     [rbp-8],rax
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp-10h]
    mov     rdx,[rbp-8]
    cmp     rax,rdx
    setb    [rbp-169h]
    test    byte ptr [rbp-169h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L1:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L2:
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L3:
    mov     rax,[rbp-158h]
    mov     rax,[rax]
    mov     rdx,[rbp-170h]
    add     rdx,1
    imul    rdx,[rbp+28h]
    mov     qword ptr [rbp-1D0h],0
    mov     rdi,[rbp-1D0h]
    sub     rdi,rdx
    imul    rcx,rdi,1
    add     rax,rcx
    mov     [rbp-178h],rax
    nop     [rax]
L4:
    mov     rax,[rbp-158h]
    mov     [rbp-190h],rax
    mov     rdx,[rbp-170h]
    mov     [rbp-188h],rdx
    mov     rsi,[rbp+20h]
    mov     rsi,[rsi+28h]
    mov     [rbp-1D0h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-1F0h],rdi
    mov     [rbp-1E8h],rax
    mov     [rbp-1E0h],rdx
    mov     edi,0FFFFFE30h
    lea     rsi,[site1]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-180h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L6:
    mov     rax,[rbp-158h]
    mov     [rbp-190h],rax
    mov     [rbp-1F0h],rax
    mov     rdx,[rbp-180h]
    mov     [rbp-1E8h],rdx
    call    fn3
    nop     [rcx-188h]
    mov     rax,[rbp-158h]
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-180h]
    mov     rax,[rax+8]
    and     rdx,rax
    mov     [rbp-1A8h],rdx
    mov     rsi,[rbp-170h]
    sub     rsi,rdx
    mov     rdi,[rbp-0F0h]
    mov     rdi,[rdi+8]
    and     rsi,rdi
    mov     [rbp-1A0h],rsi
    mov     qword ptr [rbp-1D0h],10h
    mov     edi,0FFFFFE68h
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE30h
    call    ryo_h_DivUW64
    mov     rax,[rbp-188h]
    sub     rax,[rbp-1A8h]
    mov     rdx,[rbp-0F0h]
    mov     rdx,[rdx+8]
    and     rax,rdx
    mov     [rbp-1B0h],rax
    mov     qword ptr [rbp-1D0h],10h
    mov     edi,0FFFFFE60h
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFE30h
    call    ryo_h_DivUW64
    mov     rax,[rbp-198h]
    cmp     rax,[rbp-1A0h]
    sete    [rbp-189h]
    test    byte ptr [rbp-189h],0FFh
    je      L15
    jmp     L14
    xchg    ax,ax
L7:
    mov     rax,[rbp-158h]
    mov     [rbp-110h],rax
    mov     rdx,[rbp-170h]
    sub     rdx,10h
    mov     rax,[rax+8]
    and     rdx,rax
    add     rdx,10h
    mov     [rbp-1A0h],rdx
    mov     rsi,[rbp-110h]
    mov     rsi,[rsi]
    imul    rcx,[rbp-170h],1
    add     rsi,rcx
    mov     byte ptr [rbp-1D0h],0FFh
    movzx   ecx,byte ptr [rbp-1D0h]
    mov     [rsi],cl
    mov     r8,[rbp-110h]
    mov     r8,[r8]
    imul    rcx,[rbp-1A0h],1
    add     r8,rcx
    mov     byte ptr [rbp-1D0h],0FFh
    movzx   ecx,byte ptr [rbp-1D0h]
    mov     [r8],cl
    mov     r10,[rbp-178h]
    mov     [rbp-1A0h],r10
    imul    r11,[rbp+28h],1
    mov     [rbp-1D0h],r11
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE30h
    call    ryo_h_Memcpy
    jmp     L9
    nop     [rax+rax]
    nop
L8:
    mov     rax,[rbp-178h]
    mov     [rbp-1A8h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-1A0h],rdx
    mov     edi,0FFFFFE40h
    mov     esi,0FFFFFE58h
    call    ryo_h_MovW128
    imul    rax,[rbp-1B8h],1
    mov     [rbp-1B0h],rax
    jmp     L18
    nop     [rax]
L9:
    jmp     L0
    nop     [rax+rax]
    xchg    ax,ax
L10:
    mov     edi,0FFFFFEC0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L11:
    lea     rax,[rbp-158h]
    mov     [rbp-1D0h],rax
    mov     [rbp-1F0h],rax
    call    fn4
    nop     [rcx-1D0h]
    jmp     L10
L12:
    mov     rax,[rbp-10h]
    mov     [rbp-178h],rax
    add     rax,1
    mov     [rbp-10h],rax
    mov     rdx,[rbp-178h]
    mov     qword ptr [rbp-168h],1
    mov     [rbp-170h],rdx
    mov     rdi,[rbp-158h]
    mov     rdi,[rdi]
    imul    rcx,rdx,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    cmp     dil,80h
    sete    [rbp-172h]
    movzx   r9d,byte ptr [rbp-172h]
    xor     r9b,1
    mov     [rbp-171h],r9b
    test    byte ptr [rbp-171h],0FFh
    je      L3
    jmp     L2
L13:
    mov     rax,[rbp-158h]
    mov     rax,[rax+8]
    mov     [rbp-0A8h],rax
    cmp     rax,8
    jb      L20
    jmp     L21
L14:
    mov     rax,[rbp-158h]
    mov     [rbp-0F8h],rax
    mov     rdx,[rbp-180h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rbp-1A0h],rdx
    mov     edi,0FFFFFE76h
    mov     esi,0FFFFFE60h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rbp-18Ah]
    mov     [rbp-189h],al
    mov     rdx,[rbp-170h]
    sub     rdx,10h
    mov     rsi,[rbp-0F8h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rbp-198h],rdx
    mov     rdi,[rbp-0F8h]
    mov     rdi,[rdi]
    imul    rcx,[rbp-170h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-189h]
    mov     [rdi],cl
    mov     r8,[rbp-0F8h]
    mov     r8,[r8]
    imul    rcx,[rbp-198h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-189h]
    mov     [r8],cl
    jmp     L9
L15:
    mov     rax,[rbp-158h]
    mov     rax,[rax]
    mov     rdx,[rbp-188h]
    add     rdx,1
    imul    rdx,[rbp+28h]
    mov     qword ptr [rbp-1D0h],0
    mov     rdi,[rbp-1D0h]
    sub     rdi,rdx
    imul    rcx,rdi,1
    add     rax,rcx
    mov     [rbp-190h],rax
    mov     r8,[rbp-158h]
    mov     [rbp-108h],r8
    mov     r8,[r8]
    imul    rcx,[rbp-188h],1
    add     r8,rcx
    movzx   r8d,byte ptr [r8]
    mov     [rbp-191h],r8b
    mov     r9,[rbp-180h]
    shr     r9,39h
    and     r9,7Fh
    mov     [rbp-1A8h],r9
    mov     edi,0FFFFFE6Dh
    mov     esi,0FFFFFE58h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rbp-193h]
    mov     [rbp-192h],al
    mov     rdx,[rbp-188h]
    sub     rdx,10h
    mov     rsi,[rbp-108h]
    mov     rsi,[rsi+8]
    and     rdx,rsi
    add     rdx,10h
    mov     [rbp-1A0h],rdx
    mov     rdi,[rbp-108h]
    mov     rdi,[rdi]
    imul    rcx,[rbp-188h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-192h]
    mov     [rdi],cl
    mov     r8,[rbp-108h]
    mov     r8,[r8]
    imul    rcx,[rbp-1A0h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-192h]
    mov     [r8],cl
    movzx   r9d,byte ptr [rbp-191h]
    cmp     r9b,0FFh
    sete    [rbp-192h]
    test    byte ptr [rbp-192h],0FFh
    je      L8
    jmp     L7
L16:
    mov     rax,[rbp-1B8h]
    mov     [rbp-1C0h],rax
    mov     rdx,[rbp-178h]
    mov     [rbp-1F0h],rdx
    mov     rsi,[rbp-190h]
    mov     [rbp-1E8h],rsi
    mov     [rbp-1E0h],rax
    call    fn5
    nop     [rcx-138h]
    jmp     L17
L17:
    jmp     L4
L18:
    mov     rax,[rbp-1B0h]
    mov     [rbp-1B8h],rax
    mov     edi,0FFFFFE34h
    mov     esi,0FFFFFE48h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFE38h
    mov     esi,0FFFFFE34h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFE38h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L19]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L19:
    .long   L17
    .long   L16
    .long   L1
L20:
    jmp     L22
L21:
    mov     rax,[rbp-0A8h]
    add     rax,1
    mov     [rbp-170h],rax
    mov     qword ptr [rbp-1D0h],8
    mov     edi,0FFFFFE98h
    mov     esi,0FFFFFE90h
    mov     edx,0FFFFFE30h
    call    ryo_h_DivUW64
    imul    rax,[rbp-168h],7
    mov     [rbp-0A8h],rax
L22:
    mov     rax,[rbp-158h]
    mov     rax,[rax+18h]
    mov     rdx,[rbp-158h]
    mov     rsi,[rbp-0A8h]
    sub     rsi,rax
    mov     [rbp-1D0h],rsi
    mov     rcx,[rbp-1D0h]
    mov     [rdx+10h],rcx
    mov     rdi,[rbp-150h]
    mov     [rbp-168h],rdi
    mov     r8,[rbp-148h]
    mov     [rbp-170h],r8
    mov     r9,[rbp-158h]
    mov     [rbp-160h],r9
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L23:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFE30h
    call    ryo_h_CallExt
    test    rax,rax
    je      L24
    call    rax
    nop     [rcx-1C8h]
    jmp     L25
L24:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L25:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L23

fn hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,110h
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    add     rax,1
    mov     qword ptr [rbp-10h],0
    mov     [rbp-8],rax
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp-10h]
    mov     rdx,[rbp-8]
    cmp     rax,rdx
    setb    [rbp-99h]
    test    byte ptr [rbp-99h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L1:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L2:
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-0A0h]
    sub     rdx,10h
    mov     rax,[rax+8]
    and     rdx,rax
    add     rdx,10h
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-50h]
    mov     rsi,[rsi]
    imul    rcx,[rbp-0A0h],1
    add     rsi,rcx
    mov     byte ptr [rbp-0F0h],0FFh
    movzx   ecx,byte ptr [rbp-0F0h]
    mov     [rsi],cl
    mov     r8,[rbp-50h]
    mov     r8,[r8]
    imul    rcx,[rbp-0B0h],1
    add     r8,rcx
    mov     byte ptr [rbp-0F0h],0FFh
    movzx   ecx,byte ptr [rbp-0F0h]
    mov     [r8],cl
    mov     r10,[rbp+10h]
    mov     r10,[r10]
    mov     [rbp-0F0h],r10
    mov     edi,0FFFFFF0Ch
    mov     esi,0FFFFFF10h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF0Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L3:
    .long   L6
    .long   L4
    .long   L1
L4:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     rdx,[rdx]
    mov     rdi,[rbp-0A0h]
    add     rdi,1
    imul    rdi,rsi
    mov     qword ptr [rbp-0F0h],0
    mov     r9,[rbp-0F0h]
    sub     r9,rdi
    imul    rcx,r9,1
    add     rdx,rcx
    mov     [rbp-0B8h],rdx
    mov     [rbp-110h],rdx
    mov     edi,0FFFFFF50h
    lea     rsi,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-28h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L6:
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     rdx,[rdx+18h]
    sub     rdx,1
    mov     [rbp-100h],rdx
    mov     rcx,[rbp-100h]
    mov     [rax+18h],rcx
    nop     [rax+rax]
    nop
L7:
    jmp     L0
L8:
    mov     rax,[rbp-10h]
    mov     [rbp-0A8h],rax
    add     rax,1
    mov     [rbp-10h],rax
    mov     rdx,[rbp-0A8h]
    mov     qword ptr [rbp-98h],1
    mov     [rbp-0A0h],rdx
    mov     rdi,[rbp+18h]
    mov     rdi,[rdi]
    mov     rdi,[rdi]
    imul    rcx,rdx,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    cmp     dil,80h
    sete    [rbp-0A1h]
    test    byte ptr [rbp-0A1h],0FFh
    je      L7
    jmp     L2
L9:
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    cmp     rax,8
    jae     L10
    jmp     L11
L10:
    mov     rax,[rbp-30h]
    add     rax,1
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-0F0h],8
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF10h
    call    ryo_h_DivUW64
    imul    rax,[rbp-98h],7
    mov     [rbp-30h],rax
L11:
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     rax,[rax+18h]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     rsi,[rbp-30h]
    sub     rsi,rax
    mov     [rbp-0F0h],rsi
    mov     rcx,[rbp-0F0h]
    mov     [rdx+10h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::raw::RawTableInner::reserve_rehash_inner::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE0h
    mov     ecx,30h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-40h]
    mov     [rbp-31h],al
    test    byte ptr [rbp-31h],0FFh
    je      L7
    jmp     L4
    nop     [rax+rax]
    nop
L0:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L1:
    mov     rax,[rbp+38h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF78h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-30h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+50h]
    mov     [rbp-70h],rdx
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L3
    nop     [rax]
L2:
    mov     rax,[rbp-18h]
    add     rax,1
    mov     [rbp-38h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-90h],rdx
    mov     [rbp-88h],rax
    call    fn2
    nop     [rcx-30h]
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-88h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-70h],rsi
    mov     edi,0FFFFFF80h
    mov     esi,20h
    call    ryo_h_MovW128
    movzx   eax,byte ptr [rbp+48h]
    mov     [rbp-68h],al
    mov     edi,0FFFFFFA0h
    mov     esi,38h
    call    ryo_h_MovW128
    call    fn3
    nop     [rcx-10h]
L3:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L4:
    movzx   eax,byte ptr [rbp+48h]
    mov     [rbp-90h],al
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-28h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L6:
    jmp     L0
L7:
    mov     rax,[rbp-20h]
    add     rax,[rbp+30h]
    mov     qword ptr [rbp-30h],1
    mov     [rbp-20h],rax
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-18h],rsi
    cmp     rsi,8
    jae     L8
    jmp     L9
L8:
    mov     rax,[rbp-18h]
    add     rax,1
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-50h],8
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFB0h
    call    ryo_h_DivUW64
    imul    rax,[rbp-30h],7
    mov     [rbp-18h],rax
L9:
    mov     rax,[rbp-18h]
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-50h],2
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFB0h
    call    ryo_h_DivUW64
    mov     rax,[rbp-30h]
    cmp     rax,[rbp-20h]
    jae     L1
    jmp     L2

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,240h
    mov     rax,[rbp+18h]
    mov     [rbp-240h],rax
    mov     edi,0FFFFFDC8h
    mov     esi,40h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-228h],rax
    movzx   edx,byte ptr [rbp+38h]
    mov     [rbp-220h],dl
    call    fn0
    nop     [rcx-1A0h]
    jmp     L9
    nop     [rax+rax]
L0:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L1:
    lea     rax,[rbp-110h]
    mov     [rbp-128h],rax
    mov     rax,[rax+10h]
    mov     [rbp-130h],rax
    cmp     rax,0
    je      L13
    jmp     L14
L2:
    mov     rax,[rbp-118h]
    mov     [rbp-130h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rax
    mov     rsi,[rbp+28h]
    mov     rsi,[rsi+28h]
    mov     [rbp-1F0h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-240h],rdi
    mov     [rbp-238h],rdx
    mov     [rbp-230h],rax
    mov     edi,0FFFFFE10h
    lea     rsi,[site1]
    call    ryo_h_CallInd
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-138h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L4:
    jmp     L6
    nop     [rax+rax]
    nop
L5:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     rdx,[rbp-0C8h]
    sub     rdx,rax
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+18h]
    mov     [rbp-0C0h],rsi
    mov     rdi,[rbp+10h]
    mov     [rbp-0F8h],rdi
    lea     r8,[rbp-0D8h]
    mov     [rbp-100h],r8
    mov     qword ptr [rbp-218h],20h
    mov     edi,0FFFFFDF0h
    mov     esi,0FFFFFF08h
    xor     edx,edx
    mov     ecx,20h
    call    ryo_h_LoadCopy
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFDE8h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFF00h
    xor     esi,esi
    mov     edx,0FFFFFDF0h
    mov     ecx,20h
    call    ryo_h_StoreCopy
    jmp     L17
L6:
    lea     rax,[rbp-0D8h]
    mov     [rbp-140h],rax
    mov     [rbp-240h],rax
    mov     rdx,[rbp-138h]
    mov     [rbp-238h],rdx
    call    fn3
    nop     [rcx-0B0h]
    jmp     L16
    nop     [rax+rax]
    xchg    ax,ax
L7:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    lea     rax,[rbp-0F0h]
    mov     [rbp-1F0h],rax
    mov     [rbp-240h],rax
    call    fn4
    nop     [rcx-1F0h]
    mov     edi,0FFFFFF48h
    call    ryo_h_Resume
    ud2
L9:
    mov     edi,0FFFFFE14h
    mov     esi,0FFFFFE60h
    xor     edx,edx
    mov     ecx,1
    mov     r8d,1
    xor     r9d,r9d
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFE38h
    mov     esi,0FFFFFE14h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFE38h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L10]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L10:
    .long   L12
    .long   L11
    .long   L0
L11:
    mov     edi,0FFFFFE28h
    mov     esi,0FFFFFE68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE18h
    mov     esi,0FFFFFE28h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE88h
    mov     esi,0FFFFFE18h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-180h],0
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFE88h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-198h],1
    cmp     qword ptr [rbp-198h],1
    sete    [rbp-199h]
    mov     edi,0FFFFFE30h
    mov     esi,0FFFFFE70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEA8h
    mov     esi,0FFFFFE30h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-160h],0
    mov     edi,0FFFFFE90h
    mov     esi,0FFFFFEA8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE80h
    mov     esi,0FFFFFE90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEE0h
    mov     esi,0FFFFFE80h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-128h],0
    mov     edi,0FFFFFEC8h
    mov     esi,0FFFFFEE0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-140h],1
    cmp     qword ptr [rbp-140h],1
    sete    [rbp-151h]
    mov     edi,0FFFFFEB0h
    mov     esi,0FFFFFEC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFEB0h
    call    ryo_h_MovW128
    jmp     L7
L12:
    mov     edi,0FFFFFE18h
    mov     esi,0FFFFFE60h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFE80h
    mov     esi,0FFFFFE18h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFE40h
    mov     esi,0FFFFFE80h
    mov     edx,20h
    call    ryo_h_Copy
    mov     rax,[rbp+18h]
    mov     [rbp-1D8h],rax
    mov     edi,0FFFFFE30h
    mov     esi,40h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE68h
    mov     esi,0FFFFFE28h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFE80h
    mov     esi,0FFFFFE40h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFE68h
    mov     edx,38h
    call    ryo_h_Copy
    mov     edi,0FFFFFE68h
    mov     esi,0FFFFFEA0h
    mov     edx,38h
    call    ryo_h_Copy
    mov     edi,0FFFFFED8h
    mov     esi,0FFFFFE68h
    mov     edx,38h
    call    ryo_h_Copy
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFED8h
    mov     edx,38h
    call    ryo_h_Copy
    mov     edi,0FFFFFF10h
    mov     esi,0FFFFFEA0h
    mov     edx,38h
    call    ryo_h_Copy
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-118h],rax
    mov     [rbp-110h],rax
    mov     rdx,[rbp-118h]
    mov     [rbp-0F8h],rdx
    mov     rsi,[rbp-118h]
    mov     [rbp-108h],rsi
    mov     rdi,[rbp-118h]
    mov     [rbp-120h],rdi
    mov     [rbp-240h],rdi
    mov     edi,0FFFFFE10h
    lea     rsi,[sym5]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym6]
    mov     edi,0FFFFFDC0h
    mov     esi,0FFFFFED0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE10h
    lea     rsi,[sym7]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym8]
    mov     edi,0FFFFFF00h
    mov     esi,0FFFFFEFCh
    call    ryo_h_TruncW32W16
    mov     edi,0FFFFFF02h
    mov     esi,0FFFFFF00h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rbp-0FEh]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+18h]
    mov     [rbp-18h],ax
    mov     qword ptr [rbp-28h],0
    mov     rdi,[rbp-118h]
    mov     [rbp-30h],rdi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFFD0h
    mov     edx,20h
    call    ryo_h_Copy
    jmp     L1
L13:
    mov     edi,0FFFFFEE0h
    lea     rsi,[k9]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L5
L14:
    mov     rax,[rbp-128h]
    mov     [rbp-240h],rax
    call    fn10
    nop     [rcx-120h]
    mov     rax,[rbp-128h]
    mov     rax,[rax+10h]
    sub     rax,1
    mov     [rbp-200h],rax
    mov     rdx,[rbp-128h]
    mov     rcx,[rbp-200h]
    mov     [rdx+10h],rcx
    mov     rsi,[rbp-120h]
    mov     [rbp-38h],rsi
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L15]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L15:
    .long   L5
    .long   L2
    .long   L0
L16:
    mov     rax,[rbp-0D8h]
    imul    rcx,[rbp-0B0h],1
    add     rax,rcx
    movzx   eax,byte ptr [rax]
    mov     [rbp-169h],al
    mov     rdx,[rbp-138h]
    shr     rdx,39h
    and     rdx,7Fh
    mov     [rbp-150h],rdx
    mov     edi,0FFFFFEC6h
    mov     esi,0FFFFFEB0h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rbp-13Ah]
    mov     [rbp-139h],al
    mov     rdx,[rbp-0B0h]
    sub     rdx,10h
    mov     rsi,[rbp-0D0h]
    and     rdx,rsi
    add     rdx,10h
    mov     [rbp-148h],rdx
    mov     rdi,[rbp-0D8h]
    imul    rcx,[rbp-0B0h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-139h]
    mov     [rdi],cl
    mov     r8,[rbp-0D8h]
    imul    rcx,[rbp-148h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-139h]
    mov     [r8],cl
    mov     r9,[rbp+40h]
    mov     [rbp-50h],r9
    mov     r10,[rbp+10h]
    mov     r10,[r10]
    mov     r11,[rbp-130h]
    add     r11,1
    imul    r11,r9
    mov     qword ptr [rbp-1F0h],0
    mov     rsi,[rbp-1F0h]
    sub     rsi,r11
    imul    rcx,rsi,1
    add     r10,rcx
    mov     [rbp-140h],r10
    mov     rdx,[rbp-0D8h]
    mov     rdi,[rbp-0B0h]
    add     rdi,1
    imul    rdi,r9
    mov     qword ptr [rbp-1F0h],0
    mov     rax,[rbp-1F0h]
    sub     rax,rdi
    imul    rcx,rax,1
    add     rdx,rcx
    mov     [rbp-148h],rdx
    imul    r11,r9,1
    mov     [rbp-1F0h],r11
    mov     edi,0FFFFFEB8h
    mov     esi,0FFFFFEC0h
    mov     edx,0FFFFFE10h
    call    ryo_h_Memcpy
    jmp     L1
L17:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k11]
    mov     edx,10h
    call    ryo_h_Const
    lea     rax,[rbp-0F0h]
    mov     [rbp-1F0h],rax
    mov     [rbp-240h],rax
    call    fn12
    nop     [rcx-1F0h]
    jmp     L7
    nop     [rax+rax]
    nop
L18:
    lea     rdi,[sym13]
    lea     rsi,[site14]
    mov     edx,0FFFFFE10h
    call    ryo_h_CallExt
    test    rax,rax
    je      L19
    call    rax
    nop     [rcx-1E8h]
    jmp     L20
L19:
    mov     rdi,rbp
    lea     rsi,[ro+52]
    call    qword ptr [sym15]
L20:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFF48h
    call    ryo_h_Lpad
    jmp     L8
    mov     rdi,rax
    mov     esi,0FFFFFF48h
    call    ryo_h_Lpad
    jmp     L18

fn hashbrown::raw::TableLayout::calculate_layout_for
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-0C0h],rsi
    mov     edi,0FFFFFF48h
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF60h
    mov     ecx,0FFFFFF40h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-0B8h]
    movzx   edx,byte ptr [rbp-0B0h]
    mov     [rbp-0A1h],dl
    mov     [rbp-0C8h],rax
    test    byte ptr [rbp-0A1h],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L0:
    mov     qword ptr [rbp-18h],0
    jmp     L2
    nop     [rax+rax]
L1:
    mov     rax,[rbp-50h]
    mov     rdx,[rbp-40h]
    mov     [rbp-78h],rdx
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF90h
    mov     edx,18h
    call    ryo_h_Copy
    jmp     L3
    nop     [rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     edi,0FFFFFF68h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-90h],0
    cmp     qword ptr [rbp-90h],0
    sete    [rbp-91h]
    mov     qword ptr [rbp-18h],0
    jmp     L3
L5:
    mov     rax,[rbp-0C8h]
    mov     [rbp-90h],rax
    mov     qword ptr [rbp-98h],1
    mov     qword ptr [rbp-88h],0
    mov     [rbp-28h],rax
    mov     rdi,[rbp-50h]
    sub     rdi,1
    mov     [rbp-30h],rdi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-98h]
    mov     [rbp-89h],al
    test    byte ptr [rbp-89h],0FFh
    je      L6
    mov     edi,0FFFFFF88h
    lea     rsi,[k1]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-70h],0
    cmp     qword ptr [rbp-70h],0
    sete    [rbp-71h]
    mov     qword ptr [rbp-18h],0
    jmp     L3
L6:
    mov     rax,[rbp-28h]
    add     rax,[rbp-30h]
    mov     [rbp-70h],rax
    mov     qword ptr [rbp-78h],1
    mov     qword ptr [rbp-68h],0
    mov     [rbp-38h],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFD0h
    call    ryo_h_NotW64
    mov     rax,[rbp-38h]
    and     rax,[rbp-70h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+20h]
    add     rdx,10h
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFA8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-90h]
    mov     [rbp-81h],al
    test    byte ptr [rbp-81h],0FFh
    je      L7
    mov     edi,0FFFFFF88h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-70h],0
    cmp     qword ptr [rbp-70h],0
    sete    [rbp-71h]
    mov     qword ptr [rbp-18h],0
    jmp     L2
L7:
    mov     rax,[rbp-58h]
    add     rax,[rbp-80h]
    mov     [rbp-70h],rax
    mov     qword ptr [rbp-78h],1
    mov     qword ptr [rbp-68h],0
    mov     [rbp-40h],rax
    mov     rdi,7FFFFFFFFFFFFFFFh
    sub     rdi,[rbp-30h]
    mov     [rbp-68h],rdi
    cmp     rdi,rax
    jb      L0
    jmp     L1

fn hashbrown::raw::capacity_to_buckets
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    cmp     qword ptr [rbp+10h],0Fh
    jae     L9
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     qword ptr [rbp-0A8h],0
    mov     rdi,[rbp-0A8h]
    cmp     rdi,rdx
    setbe   [rbp-3Bh]
    test    byte ptr [rbp-3Bh],0FFh
    je      L2
    jmp     L3
    nop
L0:
    mov     qword ptr [rbp-30h],3
    jmp     L5
    nop     [rax+rax]
L1:
    mov     qword ptr [rbp-30h],0Eh
    jmp     L5
    nop     [rax+rax]
L2:
    mov     qword ptr [rbp-0A8h],2
    mov     rdx,[rbp-0A8h]
    cmp     rdx,[rbp-38h]
    setbe   [rbp-39h]
    test    byte ptr [rbp-39h],0FFh
    je      L0
    cmp     qword ptr [rbp-38h],3
    jbe     L4
    jmp     L0
L3:
    cmp     qword ptr [rbp-38h],1
    jbe     L1
    jmp     L2
L4:
    mov     qword ptr [rbp-30h],7
L5:
    mov     rax,[rbp-30h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-0B8h],rdx
    call    fn0
    nop     [rcx-60h]
    cmp     qword ptr [rbp-60h],4
    jae     L6
    mov     qword ptr [rbp-48h],4
    jmp     L8
L6:
    cmp     qword ptr [rbp-60h],8
    jae     L7
    mov     qword ptr [rbp-48h],8
    jmp     L8
L7:
    mov     qword ptr [rbp-48h],10h
L8:
    mov     rax,[rbp+20h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-68h],rdx
    cmp     qword ptr [rbp-38h],0
    je      L12
    jmp     L11
L9:
    mov     rax,[rbp+10h]
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-0A8h],8
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF58h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-98h]
    movzx   edx,byte ptr [rbp-90h]
    mov     [rbp-81h],dl
    mov     [rbp-0A0h],rax
    test    byte ptr [rbp-81h],0FFh
    je      L16
    jmp     L15
    nop
L10:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L11:
    mov     rax,[rbp-38h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-68h]
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFF78h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-80h]
    movzx   edx,byte ptr [rbp-78h]
    mov     [rbp-52h],dl
    mov     [rbp-90h],rax
    test    byte ptr [rbp-52h],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
L12:
    mov     rax,[rbp-48h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L10
L13:
    mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    jmp     L12
L14:
    jmp     L12
L15:
    mov     edi,0FFFFFF88h
    lea     rsi,[k1]
    mov     edx,10h
    call    ryo_h_Const
    mov     qword ptr [rbp-70h],0
    cmp     qword ptr [rbp-70h],0
    sete    [rbp-71h]
    mov     edi,0FFFFFFF0h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L10
L16:
    mov     rax,[rbp-0A0h]
    mov     [rbp-70h],rax
    mov     qword ptr [rbp-78h],1
    mov     qword ptr [rbp-68h],0
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-0A8h],7
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF58h
    call    ryo_h_DivUW64
    cmp     qword ptr [rbp-58h],1
    jbe     L21
    jmp     L22
    nop     [rax+rax]
    nop     [rax+rax]
L17:
    mov     rax,[rbp-78h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-98h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0A0h],rsi
    cmp     rdx,0
    je      L24
    jmp     L23
    nop     [rax]
L18:
    mov     qword ptr [rbp-0A8h],1
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-70h],0FFh
    je      L17
    mov     edi,0FFFFFF40h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L19
    call    rax
    nop     [rcx-0A0h]
    jmp     L20
L19:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L20:
    call    ryo_h_Unreachable
    ud2
L21:
    mov     qword ptr [rbp-68h],0
    jmp     L18
L22:
    mov     rax,[rbp-58h]
    sub     rax,1
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF5Ch
    mov     esi,0FFFFFF80h
    call    ryo_h_CtlzW64
    mov     eax,[rbp-0A4h]
    mov     [rbp-84h],eax
    mov     qword ptr [rbp-0A8h],0FFFFFFFFFFFFFFFFh
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF7Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF50h
    call    ryo_h_ShrUW64
    jmp     L18
L23:
    mov     rax,[rbp-98h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF78h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-80h]
    movzx   edx,byte ptr [rbp-78h]
    mov     [rbp-69h],dl
    mov     [rbp-90h],rax
    test    byte ptr [rbp-69h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
L24:
    mov     rax,[rbp-60h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L10
L25:
    mov     qword ptr [rbp-90h],0FFFFFFFFFFFFFFFFh
    jmp     L24
L26:
    jmp     L24

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+10h]
    lea     rax,[rax+20h]
    mov     [rbp-48h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-50h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    call    fn0
    nop     [rcx-40h]
    jmp     L6
    xchg    ax,ax
L0:
    mov     edi,0FFFFFF74h
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFF74h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rbp-48h]
    mov     rdx,[rbp+10h]
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    lea     rdx,[rbp+18h]
    mov     [rbp-90h],rdx
    mov     [rbp-0B0h],rdx
    call    fn1
    nop     [rcx-90h]
    jmp     L4
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-50h],rdx
    mov     [rbp-0B0h],rax
    mov     qword ptr [rbp-0A8h],1
    mov     [rbp-0A0h],rdx
    call    fn2
    nop     [rcx-30h]
    jmp     L7
    nop     [rax]
L4:
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rax,[rbp+18h]
    mov     [rbp-90h],rax
    mov     [rbp-0B0h],rax
    call    fn3
    nop     [rcx-90h]
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-0B0h],rax
    mov     rsi,[rbp-40h]
    mov     [rbp-0A8h],rsi
    mov     [rbp-0A0h],rdx
    call    fn4
    nop     [rcx-48h]
    jmp     L0
L7:
    mov     edi,0FFFFFF80h
    mov     esi,18h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp+10h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF80h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-88h]
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF98h
    mov     edx,28h
    call    ryo_h_Copy
    jmp     L4
L8:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L9:
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF70h
    call    ryo_h_CallExt
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx-88h]
    jmp     L11
L10:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L11:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L5
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L9

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    lea     rax,[rax+20h]
    mov     [rbp-38h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    call    fn0
    nop     [rcx-30h]
    jmp     L6
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFA4h
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rbp-38h]
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-18h],0
    jmp     L4
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+20h]
    mov     [rbp-40h],rdx
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-78h],1
    mov     [rbp-70h],rdx
    call    fn1
    nop     [rcx-20h]
    jmp     L7
    nop     [rax+rax]
    nop     [rax]
L4:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
L6:
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-48h],rdx
    mov     [rbp-80h],rax
    mov     rsi,[rbp-30h]
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    call    fn2
    nop     [rcx-38h]
    jmp     L0
L7:
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+10h]
    mov     rsi,[rbp-30h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFB8h
    mov     edx,18h
    call    ryo_h_Copy
    jmp     L4
L8:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn main
    push    rbp
    mov     rbp,rsp
    sub     rsp,570h
    mov     qword ptr [rbp-570h],50910h
    call    fn0
    nop     [rcx-8]
    call    fn1
    nop     [rcx-38h]
    mov     qword ptr [rbp-40h],1
    mov     qword ptr [rbp-60h],0
    mov     rsi,[rbp-8]
    mov     [rbp-58h],rsi
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx-50h]
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
L0:
    lea     rax,[rbp-70h]
    mov     [rbp-88h],rax
    mov     [rbp-570h],rax
    call    fn3
    nop     [rcx-80h]
    mov     rax,[rbp-80h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF70h
    xor     esi,esi
    mov     edx,2
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
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp-78h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-0B0h],rdx
    mov     [rbp-570h],rdx
    mov     rsi,5851F42D4C957F2Dh
    mov     [rbp-568h],rsi
    call    fn4
    nop     [rcx-0A8h]
    jmp     L7
L4:
    mov     qword ptr [rbp-108h],0
    mov     qword ptr [rbp-110h],0
    mov     dword ptr [rbp-534h],14h
    mov     edi,[rbp-534h]
    mov     [rbp-16Ch],edi
    cmp     edi,40h
    jb      L14
    mov     edi,0FFFFFA90h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-530h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rbp-0A8h]
    mov     [rbp-570h],rax
    mov     rdx,14057B7EF767814Fh
    mov     [rbp-568h],rdx
    call    fn9
    nop     [rcx-0A0h]
    mov     rax,[rbp-0A0h]
    mov     [rbp-40h],rax
    lea     rdx,[rbp-38h]
    mov     [rbp-0D8h],rdx
    mov     [rbp-0E8h],rax
    mov     dword ptr [rbp-534h],2Ch
    mov     edi,[rbp-534h]
    mov     [rbp-0ECh],edi
    cmp     edi,40h
    jb      L10
    mov     edi,0FFFFFA90h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-530h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L9:
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rax,[rbp-0E8h]
    shr     rax,2Ch
    mov     [rbp-0E0h],rax
    mov     rdx,[rbp-0D8h]
    mov     [rbp-570h],rdx
    mov     [rbp-568h],rax
    call    fn14
    nop     [rcx-0D0h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFF30h
    mov     edx,18h
    call    ryo_h_Copy
    mov     qword ptr [rbp-558h],0
    call    fn15
    nop     [rcx-0B8h]
    mov     rax,[rbp-0B8h]
    mov     rax,[rax]
    mov     [rbp-538h],rax
    mov     edi,0FFFFFF00h
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFAC8h
    mov     ecx,0FFFFFF68h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-0F8h],0FFh
    je      L13
    mov     edi,0FFFFFA90h
    lea     rsi,[k16]
    call    ryo_h_AddrAbs
    lea     rdi,[sym17]
    lea     rsi,[site18]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L11
    call    rax
    nop     [rcx-530h]
    jmp     L12
L11:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym19]
L12:
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rbp-0B8h]
    mov     rcx,[rbp-100h]
    mov     [rax],rcx
    jmp     L0
L14:
    mov     qword ptr [rbp-538h],1
    mov     rdx,[rbp-538h]
    shl     rdx,14h
    mov     qword ptr [rbp-160h],0
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFEA0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-560h],2
    call    fn20
    nop     [rcx-150h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFEB0h
    mov     edx,20h
    call    ryo_h_Copy
    call    fn21
    nop     [rcx-130h]
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFED0h
    mov     edx,20h
    call    ryo_h_Copy
    nop     [rax+rax]
L15:
    lea     rax,[rbp-190h]
    mov     [rbp-1A8h],rax
    mov     [rbp-570h],rax
    call    fn22
    nop     [rcx-1A0h]
    mov     rax,[rbp-1A0h]
    mov     [rbp-1B0h],rax
    mov     edi,0FFFFFE50h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L16]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L16:
    .long   L18
    .long   L17
    .long   L2
L17:
    mov     rax,[rbp-198h]
    mov     [rbp-1B8h],rax
    lea     rdx,[rbp-38h]
    mov     [rbp-1C8h],rdx
    lea     rsi,[rbp-1B8h]
    mov     [rbp-1D0h],rsi
    mov     [rbp-570h],rdx
    mov     [rbp-568h],rsi
    call    fn23
    nop     [rcx-1C0h]
    jmp     L19
L18:
    lea     rax,[rbp-38h]
    mov     [rbp-218h],rax
    mov     [rbp-570h],rax
    call    fn24
    nop     [rcx-210h]
    jmp     L25
L19:
    mov     edi,0FFFFFACCh
    mov     esi,0FFFFFE40h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFE28h
    mov     esi,0FFFFFACCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFE28h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L20]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L20:
    .long   L15
    .long   L21
    .long   L2
L21:
    mov     rax,[rbp-1C0h]
    mov     [rbp-1E0h],rax
    mov     qword ptr [rbp-538h],1
    mov     edi,0FFFFFE10h
    mov     esi,0FFFFFE18h
    mov     edx,0FFFFFEF8h
    mov     ecx,0FFFFFAC8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-1E8h],0FFh
    je      L24
    mov     edi,0FFFFFA90h
    lea     rsi,[k25]
    call    ryo_h_AddrAbs
    lea     rdi,[sym26]
    lea     rsi,[site27]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L22
    call    rax
    nop     [rcx-530h]
    jmp     L23
L22:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym28]
L23:
    call    ryo_h_Unreachable
    ud2
L24:
    mov     rax,[rbp-1F0h]
    mov     [rbp-108h],rax
    mov     rdx,[rbp-110h]
    mov     [rbp-200h],rdx
    mov     rsi,[rbp-1E0h]
    mov     rsi,[rsi]
    mov     [rbp-208h],rsi
    mov     [rbp-570h],rdx
    mov     [rbp-568h],rsi
    call    fn29
    nop     [rcx-1F8h]
    mov     rax,[rbp-1F8h]
    mov     [rbp-110h],rax
    jmp     L15
L25:
    lea     rax,[rbp-38h]
    mov     [rbp-220h],rax
    mov     [rbp-570h],rax
    call    fn30
    nop     [rcx-218h]
    lea     rax,[rbp-38h]
    mov     [rbp-258h],rax
    mov     [rbp-570h],rax
    call    fn31
    nop     [rcx-250h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFDB0h
    mov     edx,28h
    call    ryo_h_Copy
    mov     qword ptr [rbp-548h],0
    call    fn32
    nop     [rcx-228h]
    call    fn33
    nop     [rcx-288h]
    mov     dword ptr [rbp-298h],0
    mov     dword ptr [rbp-294h],1FBD0h
    mov     rsi,[rbp-298h]
    mov     [rbp-570h],rsi
    call    fn34
    nop     [rcx-290h]
    mov     rax,[rbp-290h]
    mov     [rbp-2A0h],rax
L26:
    lea     rax,[rbp-2A0h]
    mov     [rbp-2B0h],rax
    mov     [rbp-570h],rax
    call    fn35
    nop     [rcx-2A8h]
    mov     edi,0FFFFFD48h
    mov     esi,0FFFFFD58h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFD48h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L27]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L27:
    .long   L31
    .long   L28
    .long   L2
L28:
    mov     eax,[rbp-2A4h]
    mov     [rbp-2BCh],eax
    lea     rdx,[rbp-288h]
    mov     [rbp-2F8h],rdx
    mov     dword ptr [rbp-534h],138Bh
    cmp     dword ptr [rbp-534h],0
    sete    [rbp-34Dh]
    test    byte ptr [rbp-34Dh],0FFh
    je      L32
    mov     edi,0FFFFFA90h
    lea     rsi,[k36]
    call    ryo_h_AddrAbs
    lea     rdi,[sym37]
    lea     rsi,[site38]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L29
    call    rax
    nop     [rcx-530h]
    jmp     L30
L29:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym39]
L30:
    call    ryo_h_Unreachable
    ud2
L31:
    lea     rax,[rbp-38h]
    mov     [rbp-3E8h],rax
    mov     [rbp-570h],rax
    call    fn40
    nop     [rcx-3E0h]
    jmp     L36
L32:
    mov     dword ptr [rbp-534h],138Bh
    mov     edi,0FFFFFCB4h
    mov     esi,0FFFFFD44h
    mov     edx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rbp-34Ch]
    mov     [rbp-4F8h],rax
    mov     [rbp-570h],rax
    call    fn41
    nop     [rcx-370h]
    mov     edi,0FFFFFCA0h
    mov     esi,0FFFFFC90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC88h
    lea     rsi,[k42]
    call    ryo_h_AddrAbs
    lea     rax,[rbp-360h]
    mov     [rbp-380h],rax
    mov     rdx,[rbp-378h]
    mov     [rbp-570h],rdx
    mov     [rbp-568h],rax
    call    fn43
    nop     [rcx-338h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFCC8h
    call    ryo_h_MovW128
    call    fn44
    nop     [rcx-328h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFCD8h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn45
    nop     [rcx-310h]
    mov     rax,[rbp-2F8h]
    mov     [rbp-570h],rax
    mov     edi,0FFFFFA98h
    mov     esi,0FFFFFCF0h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn46
    nop     [rcx-2F0h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFD10h
    mov     edx,28h
    call    ryo_h_Copy
    call    fn47
    nop     [rcx-2C8h]
    mov     rax,[rbp-2C8h]
    mov     rax,[rax]
    mov     [rbp-538h],rax
    mov     qword ptr [rbp-540h],1
    mov     edi,0FFFFFC70h
    mov     esi,0FFFFFC78h
    mov     edx,0FFFFFAC8h
    mov     ecx,0FFFFFAC0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-388h],0FFh
    je      L35
    mov     edi,0FFFFFA90h
    lea     rsi,[k48]
    call    ryo_h_AddrAbs
    lea     rdi,[sym49]
    lea     rsi,[site50]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L33
    call    rax
    nop     [rcx-530h]
    jmp     L34
L33:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym51]
L34:
    call    ryo_h_Unreachable
    ud2
L35:
    mov     rax,[rbp-2C8h]
    mov     rcx,[rbp-390h]
    mov     [rax],rcx
    jmp     L26
L36:
    lea     rax,[rbp-3E0h]
    mov     [rbp-3D8h],rax
    lea     rdx,[rbp-288h]
    mov     [rbp-400h],rdx
    mov     [rbp-570h],rdx
    call    fn52
    nop     [rcx-3F8h]
    lea     rax,[rbp-3F8h]
    lea     rdx,[rbp-210h]
    lea     rsi,[rbp-108h]
    lea     rdi,[rbp-110h]
    lea     r8,[rbp-228h]
    mov     r9,[rbp-3D8h]
    mov     [rbp-3D0h],r9
    mov     [rbp-3C8h],rax
    mov     [rbp-3C0h],rdx
    mov     [rbp-3B8h],rsi
    mov     [rbp-3B0h],rdi
    mov     [rbp-3A8h],r8
    mov     [rbp-500h],rdx
    mov     [rbp-570h],rdx
    call    fn53
    nop     [rcx-490h]
    mov     rax,[rbp-3B8h]
    mov     [rbp-508h],rax
    mov     [rbp-570h],rax
    call    fn54
    nop     [rcx-4A0h]
    mov     rax,[rbp-3B0h]
    mov     [rbp-510h],rax
    mov     [rbp-570h],rax
    call    fn55
    nop     [rcx-4B0h]
    mov     rax,[rbp-3D0h]
    mov     [rbp-518h],rax
    mov     [rbp-570h],rax
    call    fn56
    nop     [rcx-4C0h]
    mov     rax,[rbp-3A8h]
    mov     [rbp-520h],rax
    mov     [rbp-570h],rax
    call    fn57
    nop     [rcx-4D0h]
    mov     rax,[rbp-3C8h]
    mov     [rbp-528h],rax
    mov     [rbp-570h],rax
    call    fn58
    nop     [rcx-4E0h]
    mov     edi,0FFFFFB80h
    mov     esi,0FFFFFB70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFB90h
    mov     esi,0FFFFFB60h
    call    ryo_h_MovW128
    mov     edi,0FFFFFBA0h
    mov     esi,0FFFFFB50h
    call    ryo_h_MovW128
    mov     edi,0FFFFFBB0h
    mov     esi,0FFFFFB40h
    call    ryo_h_MovW128
    mov     edi,0FFFFFBC0h
    mov     esi,0FFFFFB30h
    call    ryo_h_MovW128
    mov     edi,0FFFFFBD0h
    mov     esi,0FFFFFB20h
    call    ryo_h_MovW128
    mov     edi,0FFFFFB18h
    lea     rsi,[k59]
    call    ryo_h_AddrAbs
    lea     rax,[rbp-480h]
    mov     [rbp-4F0h],rax
    mov     rdx,[rbp-4E8h]
    mov     [rbp-570h],rdx
    mov     [rbp-568h],rax
    call    fn60
    nop     [rcx-3A0h]
    mov     edi,0FFFFFA90h
    mov     esi,0FFFFFC60h
    call    ryo_h_MovW128
    lea     rdi,[sym61]
    lea     rsi,[site62]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L37
    call    rax
    nop     [rcx-390h]
    jmp     L38
L37:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym63]
L38:
    lea     rax,[rbp-288h]
    mov     [rbp-538h],rax
    mov     [rbp-570h],rax
    call    fn64
    nop     [rcx-538h]
    lea     rax,[rbp-38h]
    mov     [rbp-538h],rax
    mov     [rbp-570h],rax
    call    fn65
    nop     [rcx-538h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop
L39:
    lea     rax,[rbp-288h]
    mov     [rbp-538h],rax
    mov     [rbp-570h],rax
    call    fn66
    nop     [rcx-538h]
    nop     [rax+rax]
    nop     [rax+rax]
L40:
    lea     rax,[rbp-38h]
    mov     [rbp-538h],rax
    mov     [rbp-570h],rax
    call    fn67
    nop     [rcx-538h]
    mov     edi,0FFFFFAD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L41:
    lea     rdi,[sym68]
    lea     rsi,[site69]
    mov     edx,0FFFFFAC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L42
    call    rax
    nop     [rcx-530h]
    jmp     L43
L42:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym70]
L43:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L40
    mov     rdi,rax
    mov     esi,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L39
    mov     rdi,rax
    mov     esi,0FFFFFAD0h
    call    ryo_h_Lpad
    jmp     L41

fn main::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     qword ptr [rbp-28h],3
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-10h]
    cmp     qword ptr [rbp-10h],0
    setne   [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn main::{closure#1}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+20h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::alloc::Global::alloc_impl_runtime
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-60h],rax
    cmp     rax,0
    je      L0
    test    byte ptr [rbp+20h],0FFh
    je      L4
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     [rbp-78h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],0
    mov     byte ptr [rbp-91h],1
    test    byte ptr [rbp-91h],0FFh
    je      L10
    jmp     L9
L1:
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-38h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    jmp     L11
L4:
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-48h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L6:
    jmp     L14
    nop     [rax+rax]
    nop     [rax]
L7:
    mov     rax,[rbp-28h]
    cmp     rax,0
    sete    [rbp-79h]
    test    byte ptr [rbp-79h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
L8:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L9:
    mov     rax,[rbp-38h]
    mov     [rbp-90h],rax
    mov     [rbp-0B0h],rax
    mov     edi,0FFFFFF58h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx-38h]
L10:
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    jmp     L8
L11:
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rax
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L12
    call    rax
    nop     [rcx-28h]
    jmp     L13
L12:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym10]
L13:
    jmp     L7
L14:
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rax
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFF68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx-28h]
    jmp     L16
L15:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym13]
L16:
    jmp     L7
L17:
    mov     qword ptr [rbp-78h],0
    mov     qword ptr [rbp-70h],0
    mov     qword ptr [rbp-70h],1
    cmp     qword ptr [rbp-70h],1
    sete    [rbp-71h]
    mov     edi,0FFFFFFF0h
    lea     rsi,[k14]
    mov     edx,10h
    call    ryo_h_Const
    jmp     L8
L18:
    mov     byte ptr [rbp-91h],1
    test    byte ptr [rbp-91h],0FFh
    je      L19
    mov     rsi,[rbp-28h]
    mov     [rbp-90h],rsi
    mov     [rbp-0B0h],rsi
    mov     edi,0FFFFFF58h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx-58h]
L19:
    mov     rax,[rbp-28h]
    mov     [rbp-70h],rax
    mov     [rbp-30h],rax
    mov     [rbp-80h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-78h],rdx
    mov     byte ptr [rbp-91h],1
    test    byte ptr [rbp-91h],0FFh
    je      L20
    mov     r8,[rbp-30h]
    mov     [rbp-88h],r8
    mov     [rbp-0B0h],r8
    mov     edi,0FFFFFF58h
    lea     rsi,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx-58h]
L20:
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    jmp     L8

fn std::arch::x86_64::__m128i::as_i8x16
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::char::encode_utf8_raw
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    cmp     dword ptr [rbp+10h],80h
    jb      L6
    jmp     L3
    nop     [rax]
L0:
    mov     eax,[rbp+10h]
    mov     [rbp-70h],eax
    mov     rdx,[rbp-18h]
    mov     [rbp-80h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-78h],rsi
    mov     edi,0FFFFFF98h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-20h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L1:
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+20h]
    mov     [rbp-38h],rax
    mov     esi,[rbp+10h]
    mov     [rbp-80h],esi
    mov     [rbp-78h],rax
    call    fn2
    nop     [rcx-20h]
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-28h],rdx
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-40h],rdx
    cmp     rax,rdx
    jb      L0
    jmp     L1
L3:
    cmp     dword ptr [rbp+10h],800h
    jb      L5
    cmp     dword ptr [rbp+10h],10000h
    jb      L4
    mov     qword ptr [rbp-18h],4
    jmp     L2
L4:
    mov     qword ptr [rbp-18h],3
    jmp     L2
L5:
    mov     qword ptr [rbp-18h],2
    jmp     L2
L6:
    mov     qword ptr [rbp-18h],1
    jmp     L2
L7:
    mov     rax,[rbp-30h]
    mov     [rbp-40h],rax
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-78h],1
    mov     qword ptr [rbp-70h],1
    mov     rdi,[rbp-18h]
    mov     [rbp-68h],rdi
    mov     edi,0FFFFFFA0h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-30h]
L8:
    mov     rax,[rbp-38h]
    mov     rdx,[rbp-18h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::char::encode_utf8_raw::do_panic::runtime
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    lea     rax,[rbp+10h]
    lea     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    lea     rsi,[rbp+18h]
    mov     [rbp-18h],rsi
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF70h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-90h]
    mov     rdx,[rbp-80h]
    mov     [rbp-78h],rdx
    mov     [rbp-70h],rax
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     rax,[rbp-10h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF60h
    lea     rsi,[sym1]
    call    ryo_h_AddrSym
    mov     rax,[rbp-0A0h]
    mov     rdx,[rbp-90h]
    mov     [rbp-88h],rdx
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     rax,[rbp-18h]
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFF50h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rax,[rbp-0B0h]
    mov     rdx,[rbp-0A0h]
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    lea     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     edi,0FFFFFF98h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-60h]
    mov     rdx,[rbp-68h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-0D0h],rax
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L1:
    call    ryo_h_Unreachable
    ud2

fn std::char::encode_utf8_raw_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    cmp     dword ptr [rbp+10h],80h
    jb      L7
    jmp     L4
    nop     [rax+rax]
L0:
    movzx   eax,byte ptr [rbp-0Ah]
    or      al,0C0h
    mov     [rbp-20h],al
    mov     rdx,[rbp+18h]
    movzx   ecx,byte ptr [rbp-20h]
    mov     [rdx],cl
    mov     qword ptr [rbp-20h],1
    mov     rdi,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     rdi,rcx
    movzx   ecx,byte ptr [rbp-9]
    mov     [rdi],cl
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L1:
    cmp     qword ptr [rbp-8],3
    jne     L2
    movzx   edx,byte ptr [rbp-0Bh]
    or      dl,0E0h
    mov     [rbp-20h],dl
    mov     rsi,[rbp+18h]
    movzx   ecx,byte ptr [rbp-20h]
    mov     [rsi],cl
    mov     qword ptr [rbp-20h],1
    mov     r8,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-0Ah]
    mov     [r8],cl
    mov     qword ptr [rbp-20h],2
    mov     r10,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rbp-9]
    mov     [r10],cl
    jmp     L3
L2:
    mov     rax,[rbp+18h]
    movzx   ecx,byte ptr [rbp-0Ch]
    mov     [rax],cl
    mov     qword ptr [rbp-20h],1
    mov     rsi,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     rsi,rcx
    movzx   ecx,byte ptr [rbp-0Bh]
    mov     [rsi],cl
    mov     qword ptr [rbp-20h],2
    mov     r8,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     r8,rcx
    movzx   ecx,byte ptr [rbp-0Ah]
    mov     [r8],cl
    mov     qword ptr [rbp-20h],3
    mov     r10,[rbp+18h]
    imul    rcx,[rbp-20h],1
    add     r10,rcx
    movzx   ecx,byte ptr [rbp-9]
    mov     [r10],cl
    jmp     L3
    nop
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L4:
    cmp     dword ptr [rbp+10h],800h
    jb      L6
    cmp     dword ptr [rbp+10h],10000h
    jb      L5
    mov     qword ptr [rbp-8],4
    jmp     L8
L5:
    mov     qword ptr [rbp-8],3
    jmp     L8
L6:
    mov     qword ptr [rbp-8],2
    jmp     L8
L7:
    mov     qword ptr [rbp-8],1
    mov     edi,0FFFFFFE0h
    mov     esi,10h
    call    ryo_h_TruncW32W8
    mov     rax,[rbp+18h]
    movzx   ecx,byte ptr [rbp-20h]
    mov     [rax],cl
    jmp     L3
L8:
    mov     eax,[rbp+10h]
    and     eax,3Fh
    mov     [rbp-10h],eax
    mov     edi,0FFFFFFF6h
    mov     esi,0FFFFFFF0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rbp-0Ah]
    or      al,80h
    mov     [rbp-9],al
    mov     edx,[rbp+10h]
    shr     edx,6
    and     edx,3Fh
    mov     [rbp-10h],edx
    mov     edi,0FFFFFFF5h
    mov     esi,0FFFFFFF0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rbp-0Bh]
    or      al,80h
    mov     [rbp-0Ah],al
    mov     edx,[rbp+10h]
    shr     edx,0Ch
    and     edx,3Fh
    mov     [rbp-10h],edx
    mov     edi,0FFFFFFF4h
    mov     esi,0FFFFFFF0h
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rbp-0Ch]
    or      al,80h
    mov     [rbp-0Bh],al
    mov     edx,[rbp+10h]
    shr     edx,12h
    and     edx,3Fh
    mov     [rbp-14h],edx
    mov     edi,0FFFFFFF3h
    mov     esi,0FFFFFFECh
    call    ryo_h_TruncW32W8
    movzx   eax,byte ptr [rbp-0Dh]
    or      al,0F0h
    mov     [rbp-0Ch],al
    mov     rdx,[rbp-8]
    mov     [rbp-18h],rdx
    cmp     rdx,2
    je      L0
    jmp     L1

fn std::cmp::impls::<impl std::cmp::PartialEq for u64>::eq
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     eax,[rax]
    mov     rdx,[rbp+18h]
    mov     edx,[rdx]
    cmp     eax,edx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<std::string::String, usize>::entry
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    mov     rax,[rbp+10h]
    mov     [rbp-58h],rax
    mov     [rbp-0D0h],rax
    mov     edi,0FFFFFF38h
    mov     esi,18h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx-50h]
    mov     edi,0FFFFFF54h
    mov     esi,0FFFFFFB0h
    mov     rdx,0FFFFFFFFFFFFFFFFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF54h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFA8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L4
    .long   L3
    .long   L2
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    call    ryo_h_Ret
    leave
    ret
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFB0h
    mov     edx,28h
    call    ryo_h_Copy
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF80h
    mov     edx,28h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF58h
    mov     edx,28h
    call    ryo_h_Copy
    jmp     L1
L4:
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    jmp     L1

fn std::collections::HashMap::<std::string::String, usize>::len
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<std::string::String, usize>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     edi,0FFFFFF60h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-40h]
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    mov     edx,20h
    call    ryo_h_Const
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF70h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFF90h
    mov     edx,30h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD0h
    mov     esi,30h
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<u64, u64>::entry
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     [rbp-80h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-78h],rdx
    call    fn0
    nop     [rcx-30h]
    mov     edi,0FFFFFF94h
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFF94h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L4
    .long   L3
    .long   L2
    nop     [rax+rax]
    nop     [rax]
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFD0h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFB0h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF98h
    mov     edx,18h
    call    ryo_h_Copy
    jmp     L1
L4:
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-18h],0
    jmp     L1

fn std::collections::HashMap::<u64, u64>::get::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<u64, u64>::len
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<u64, u64>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     edi,0FFFFFF60h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-40h]
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    mov     edx,20h
    call    ryo_h_Const
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF70h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFF90h
    mov     edx,30h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD0h
    mov     esi,30h
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<u64, u64>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::collections::HashMap::<u64, u64>::values
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-80h],rax
    mov     [rbp-90h],rax
    call    fn0
    nop     [rcx-78h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF88h
    mov     edx,28h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFB0h
    mov     edx,28h
    call    ryo_h_Copy
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    call    ryo_h_Ret
    leave
    ret

fn std::collections::hash_map::Entry::<'_, std::string::String, usize>::or_default
    push    rbp
    mov     rbp,rsp
    sub     rsp,110h
    mov     edi,0FFFFFF24h
    mov     esi,10h
    mov     rdx,0FFFFFFFFFFFFFFFFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF24h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
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
    call    ryo_h_Unreachable
    ud2
L2:
    mov     edi,0FFFFFFA8h
    mov     esi,10h
    mov     edx,28h
    call    ryo_h_Copy
    mov     byte ptr [rbp-11h],1
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFA8h
    mov     edx,28h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx-88h]
    jmp     L4
L3:
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-50h],rdx
    mov     byte ptr [rbp-0D9h],0
    test    byte ptr [rbp-0D9h],0FFh
    je      L11
    jmp     L10
L4:
    mov     byte ptr [rbp-11h],0
    mov     rdx,[rbp-60h]
    mov     [rbp-0B8h],rdx
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF80h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-68h]
    mov     [rbp-0D8h],rax
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF30h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-88h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp-0D8h]
    mov     [rbp-110h],rdx
    mov     rsi,[rbp-0B8h]
    mov     [rbp-108h],rsi
    mov     edi,0FFFFFF00h
    mov     esi,0FFFFFF50h
    mov     edx,20h
    call    ryo_h_Copy
    call    fn1
    nop     [rcx-90h]
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L5:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L7:
    lea     rax,[rbp-80h]
    mov     [rbp-0E0h],rax
    mov     [rbp-110h],rax
    call    fn2
    nop     [rcx-0E0h]
    jmp     L6
L8:
    test    byte ptr [rbp-11h],0FFh
    je      L6
    jmp     L7
    nop     [rax+rax]
L9:
    mov     rax,[rbp-40h]
    lea     rax,[rax+18h]
    mov     [rbp-8],rax
    jmp     L5
L10:
    mov     qword ptr [rbp-40h],8
    jmp     L9
L11:
    mov     rax,[rbp-58h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-0D9h],0
    test    byte ptr [rbp-0D9h],0FFh
    je      L14
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    jmp     L9
L13:
    mov     rax,[rbp-48h]
    mov     [rbp-40h],rax
    jmp     L12
L14:
    mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-48h]
    imul    rcx,[rbp-0E0h],20h
    add     rdx,rcx
    mov     [rbp-40h],rdx
    jmp     L12
L15:
    mov     byte ptr [rbp-0D9h],0
    test    byte ptr [rbp-0D9h],0FFh
    je      L18
    jmp     L17
    xchg    ax,ax
L16:
    mov     rax,[rbp-0A0h]
    lea     rax,[rax+18h]
    mov     [rbp-8],rax
    jmp     L5
L17:
    mov     qword ptr [rbp-0A0h],8
    jmp     L16
L18:
    mov     rax,[rbp-90h]
    mov     [rbp-0A8h],rax
    mov     byte ptr [rbp-0D9h],0
    test    byte ptr [rbp-0D9h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax+rax]
L19:
    jmp     L16
L20:
    mov     rax,[rbp-0A8h]
    mov     [rbp-0A0h],rax
    jmp     L19
L21:
    mov     qword ptr [rbp-0E0h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-0A8h]
    imul    rcx,[rbp-0E0h],20h
    add     rdx,rcx
    mov     [rbp-0A0h],rdx
    jmp     L19
    nop     [rax+rax]
L22:
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF20h
    call    ryo_h_CallExt
    test    rax,rax
    je      L23
    call    rax
    nop     [rcx-0D8h]
    jmp     L24
L23:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L24:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L8
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L22

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     edi,0FFFFFF84h
    mov     esi,10h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF84h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+20h]
    mov     rsi,[rbp+10h]
    mov     [rbp-78h],rsi
    mov     byte ptr [rbp-11h],0
    mov     r8,[rbp+28h]
    mov     [rbp-50h],rdx
    mov     [rbp-48h],r8
    mov     [rbp-0A0h],rsi
    mov     [rbp-98h],rax
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-40h]
    jmp     L8
L3:
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-50h],rdx
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rbp-11h],0FFh
    je      L5
    jmp     L6
L8:
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L9:
    mov     rax,[rbp-50h]
    lea     rax,[rax+8]
    mov     [rbp-8],rax
    jmp     L4
L10:
    mov     qword ptr [rbp-50h],8
    jmp     L9
L11:
    mov     rax,[rbp-40h]
    mov     [rbp-58h],rax
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L14
    jmp     L13
    nop     [rax]
L12:
    jmp     L9
L13:
    mov     rax,[rbp-58h]
    mov     [rbp-50h],rax
    jmp     L12
L14:
    mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-58h]
    imul    rcx,[rbp-80h],10h
    add     rdx,rcx
    mov     [rbp-50h],rdx
    jmp     L12
    nop     [rax+rax]
    nop
L15:
    mov     rax,[rbp-40h]
    lea     rax,[rax+8]
    mov     [rbp-8],rax
    jmp     L4
L16:
    mov     qword ptr [rbp-40h],8
    jmp     L15
L17:
    mov     rax,[rbp-58h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L20
    jmp     L19
    nop
L18:
    jmp     L15
L19:
    mov     rax,[rbp-48h]
    mov     [rbp-40h],rax
    jmp     L18
L20:
    mov     qword ptr [rbp-80h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-48h]
    imul    rcx,[rbp-80h],10h
    add     rdx,rcx
    mov     [rbp-40h],rdx
    jmp     L18
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L7

fn std::fmt::Arguments::<'_>::as_statically_known_str
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-20h],rax
    and     rax,1
    mov     [rbp-28h],rax
    cmp     rax,1
    je      L3
    jmp     L4
    nop     [rax+rax]
L0:
    test    byte ptr [rbp-19h],0FFh
    je      L1
    jmp     L2
L1:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
L2:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-50h],rax
    mov     [rbp-28h],rax
    mov     rdx,[rbp-20h]
    shr     rdx,1
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L7
    jmp     L6
L4:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    mov     edx,10h
    call    ryo_h_Const
L5:
    mov     edi,0FFFFFF94h
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF94h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-28h],1
    sete    [rbp-1Ah]
    movzx   edx,byte ptr [rbp-1Ah]
    mov     [rbp-0A0h],dl
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
    jmp     L0
L6:
    mov     rax,[rbp-50h]
    mov     [rbp-60h],rax
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],1
    mov     qword ptr [rbp-90h],1
    mov     rdi,[rbp-58h]
    mov     [rbp-88h],rdi
    mov     edi,0FFFFFF80h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-18h]
L7:
    mov     rax,[rbp-28h]
    mov     rdx,[rbp-58h]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    jmp     L5

fn std::fmt::Arguments::<'_>::new::<4, 1>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::Arguments::<'_>::new::<59, 6>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::format
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    and     rax,1
    mov     [rbp-40h],rax
    cmp     rax,1
    je      L1
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp-38h]
    shr     rdx,1
    mov     [rbp-70h],rdx
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L5
    jmp     L4
L2:
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    nop     [rax+rax]
    xchg    ax,ax
L3:
    lea     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     rax,[rbp-38h]
    mov     [rbp-0B0h],rax
    call    fn1
    nop     [rcx-18h]
    jmp     L0
L4:
    mov     rax,[rbp-68h]
    mov     [rbp-78h],rax
    mov     [rbp-0B0h],rax
    mov     qword ptr [rbp-0A8h],1
    mov     qword ptr [rbp-0A0h],1
    mov     rdi,[rbp-70h]
    mov     [rbp-98h],rdi
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-20h]
L5:
    mov     rax,[rbp-40h]
    mov     rdx,[rbp-70h]
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    jmp     L3

fn std::fmt::format::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-18h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-20h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::hash::RandomState::new::KEYS::{constant#0}::{closure#1}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFE8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    mov     rax,[rbp-10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    call    fn2
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::hash::RandomState::new::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     rdx,[rbp-28h]
    mov     rdx,[rdx+8]
    mov     [rbp-20h],rdx
    add     rax,1
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-38h],rsi
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,0FFFFFFD0h
    call    ryo_h_StoreW128
    mov     rax,[rbp-18h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::hint::assert_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    test    byte ptr [rbp+10h],0FFh
    jne     L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DDh
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-50h],0DDh
    mov     rdx,[rbp-50h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-28h]
    mov     [rbp-20h],rsi
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-70h],0
    mov     rdx,[rbp+18h]
    mov     [rbp-68h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::hint::black_box::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::hint::must_use::<std::string::String>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE8h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::hint::unreachable_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0C7h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-50h],0C7h
    mov     rdx,[rbp-50h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-28h]
    mov     [rbp-20h],rsi
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-70h],0
    mov     rdx,[rbp+10h]
    mov     [rbp-68h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2

fn std::intrinsics::cold_path
    push    rbp
    mov     rbp,rsp
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::is_val_statically_known::<bool>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     byte ptr [rbp-1],0
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::rotate_left::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     qword ptr [rbp-30h],8
    mov     edi,0FFFFFFDCh
    mov     esi,0FFFFFFD0h
    call    ryo_h_TruncW64W32
    imul    eax,[rbp-24h],8
    mov     [rbp-20h],eax
    cmp     eax,0
    jne     L2
    mov     edi,0FFFFFFB0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-24h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     edi,0FFFFFFE4h
    mov     esi,18h
    mov     edx,0FFFFFFE0h
    call    ryo_h_RemUW32
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE4h
    call    ryo_h_ZextW32W64
    mov     qword ptr [rbp-38h],3Fh
    mov     rdx,[rbp-38h]
    sub     rdx,[rbp-30h]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    mov     edx,0FFFFFFD0h
    call    ryo_h_ShlW64
    mov     rax,[rbp+10h]
    shr     rax,1
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFC8h
    call    ryo_h_ShrUW64
    mov     rax,[rbp-40h]
    or      rax,[rbp-48h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax]
L3:
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-24h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L5:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L3

fn std::intrinsics::typed_swap_nonoverlapping::<hashbrown::raw::RawTableInner>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     qword ptr [rbp-20h],1
    mov     edi,0FFFFFFE8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-8]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::io::Error::is_interrupted
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-58h],rax
    mov     [rbp-80h],rax
    call    fn0
    nop     [rcx-50h]
    jmp     L8
    nop     [rax+rax]
L0:
    call    ryo_h_Unreachable
    ud2
L1:
    mov     rax,[rbp-48h]
    mov     [rbp-38h],rax
    movzx   eax,byte ptr [rax+10h]
    mov     [rbp-69h],al
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF97h
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rbp-58h],23h
    sete    [rbp-1]
    jmp     L7
L2:
    movzx   eax,byte ptr [rbp-4Fh]
    mov     [rbp-51h],al
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFAFh
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rbp-60h],23h
    sete    [rbp-1]
    jmp     L7
L3:
    mov     rax,[rbp-48h]
    mov     [rbp-20h],rax
    movzx   eax,byte ptr [rax+20h]
    mov     [rbp-69h],al
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF97h
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rbp-58h],23h
    sete    [rbp-1]
    jmp     L7
L4:
    mov     eax,[rbp-4Ch]
    mov     [rbp-54h],eax
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-60h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L6:
    jmp     L10
    nop     [rax]
L7:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L8:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFB0h
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFE8h
    xor     esi,esi
    mov     edx,4
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L9]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L9:
    .long   L4
    .long   L2
    .long   L1
    .long   L3
    .long   L0
L10:
    mov     rax,[rbp-60h]
    mov     rax,[rax+10h]
    mov     [rbp-68h],rax
    mov     edx,[rbp-54h]
    mov     [rbp-80h],edx
    mov     edi,0FFFFFF98h
    lea     rsi,[site4]
    call    ryo_h_CallInd
    test    rax,rax
    je      L11
    call    rax
    nop     [rcx-1]
    jmp     L12
L11:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L12:
    jmp     L7

fn std::io::ErrorKind::from_prim
    push    rbp
    mov     rbp,rsp
    sub     rsp,170h
    cmp     dword ptr [rbp+10h],0
    jne     L0
    mov     byte ptr [rbp-1],0
    jmp     L44
L0:
    cmp     dword ptr [rbp+10h],1
    jne     L1
    mov     byte ptr [rbp-1],1
    jmp     L44
L1:
    cmp     dword ptr [rbp+10h],2
    jne     L2
    mov     byte ptr [rbp-1],2
    jmp     L44
L2:
    cmp     dword ptr [rbp+10h],3
    jne     L3
    mov     byte ptr [rbp-1],3
    jmp     L44
L3:
    cmp     dword ptr [rbp+10h],4
    jne     L4
    mov     byte ptr [rbp-1],4
    jmp     L44
L4:
    cmp     dword ptr [rbp+10h],5
    jne     L5
    mov     byte ptr [rbp-1],5
    jmp     L44
L5:
    cmp     dword ptr [rbp+10h],6
    jne     L6
    mov     byte ptr [rbp-1],6
    jmp     L44
L6:
    cmp     dword ptr [rbp+10h],7
    jne     L7
    mov     byte ptr [rbp-1],7
    jmp     L44
L7:
    cmp     dword ptr [rbp+10h],8
    jne     L8
    mov     byte ptr [rbp-1],8
    jmp     L44
L8:
    cmp     dword ptr [rbp+10h],9
    jne     L9
    mov     byte ptr [rbp-1],9
    jmp     L44
L9:
    cmp     dword ptr [rbp+10h],0Ah
    jne     L10
    mov     byte ptr [rbp-1],0Ah
    jmp     L44
L10:
    cmp     dword ptr [rbp+10h],0Bh
    jne     L11
    mov     byte ptr [rbp-1],0Bh
    jmp     L44
L11:
    cmp     dword ptr [rbp+10h],0Ch
    jne     L12
    mov     byte ptr [rbp-1],0Ch
    jmp     L44
L12:
    cmp     dword ptr [rbp+10h],0Dh
    jne     L13
    mov     byte ptr [rbp-1],0Dh
    jmp     L44
L13:
    cmp     dword ptr [rbp+10h],0Eh
    jne     L14
    mov     byte ptr [rbp-1],0Eh
    jmp     L44
L14:
    cmp     dword ptr [rbp+10h],0Fh
    jne     L15
    mov     byte ptr [rbp-1],0Fh
    jmp     L44
L15:
    cmp     dword ptr [rbp+10h],10h
    jne     L16
    mov     byte ptr [rbp-1],10h
    jmp     L44
L16:
    cmp     dword ptr [rbp+10h],11h
    jne     L17
    mov     byte ptr [rbp-1],11h
    jmp     L44
L17:
    cmp     dword ptr [rbp+10h],12h
    jne     L18
    mov     byte ptr [rbp-1],12h
    jmp     L44
L18:
    cmp     dword ptr [rbp+10h],13h
    jne     L19
    mov     byte ptr [rbp-1],13h
    jmp     L44
L19:
    cmp     dword ptr [rbp+10h],14h
    jne     L20
    mov     byte ptr [rbp-1],14h
    jmp     L44
L20:
    cmp     dword ptr [rbp+10h],15h
    jne     L21
    mov     byte ptr [rbp-1],15h
    jmp     L44
L21:
    cmp     dword ptr [rbp+10h],16h
    jne     L22
    mov     byte ptr [rbp-1],16h
    jmp     L44
L22:
    cmp     dword ptr [rbp+10h],17h
    jne     L23
    mov     byte ptr [rbp-1],17h
    jmp     L44
L23:
    cmp     dword ptr [rbp+10h],18h
    jne     L24
    mov     byte ptr [rbp-1],18h
    jmp     L44
L24:
    cmp     dword ptr [rbp+10h],19h
    jne     L25
    mov     byte ptr [rbp-1],19h
    jmp     L44
L25:
    cmp     dword ptr [rbp+10h],1Ah
    jne     L26
    mov     byte ptr [rbp-1],1Ah
    jmp     L44
L26:
    cmp     dword ptr [rbp+10h],1Bh
    jne     L27
    mov     byte ptr [rbp-1],1Bh
    jmp     L44
L27:
    cmp     dword ptr [rbp+10h],1Ch
    jne     L28
    mov     byte ptr [rbp-1],1Ch
    jmp     L44
L28:
    cmp     dword ptr [rbp+10h],1Dh
    jne     L29
    mov     byte ptr [rbp-1],1Dh
    jmp     L44
L29:
    cmp     dword ptr [rbp+10h],1Eh
    jne     L30
    mov     byte ptr [rbp-1],1Eh
    jmp     L44
L30:
    cmp     dword ptr [rbp+10h],1Fh
    jne     L31
    mov     byte ptr [rbp-1],1Fh
    jmp     L44
L31:
    cmp     dword ptr [rbp+10h],20h
    jne     L32
    mov     byte ptr [rbp-1],20h
    jmp     L44
L32:
    cmp     dword ptr [rbp+10h],21h
    jne     L33
    mov     byte ptr [rbp-1],21h
    jmp     L44
L33:
    cmp     dword ptr [rbp+10h],22h
    jne     L34
    mov     byte ptr [rbp-1],22h
    jmp     L44
L34:
    cmp     dword ptr [rbp+10h],23h
    jne     L35
    mov     byte ptr [rbp-1],23h
    jmp     L44
L35:
    cmp     dword ptr [rbp+10h],2Ah
    jne     L36
    mov     byte ptr [rbp-1],2Ah
    jmp     L44
L36:
    cmp     dword ptr [rbp+10h],25h
    jne     L37
    mov     byte ptr [rbp-1],25h
    jmp     L44
L37:
    cmp     dword ptr [rbp+10h],24h
    jne     L38
    mov     byte ptr [rbp-1],24h
    jmp     L44
L38:
    cmp     dword ptr [rbp+10h],26h
    jne     L39
    mov     byte ptr [rbp-1],26h
    jmp     L44
L39:
    cmp     dword ptr [rbp+10h],27h
    jne     L40
    mov     byte ptr [rbp-1],27h
    jmp     L44
L40:
    cmp     dword ptr [rbp+10h],28h
    jne     L41
    mov     byte ptr [rbp-1],28h
    jmp     L44
L41:
    cmp     dword ptr [rbp+10h],29h
    jne     L42
    mov     byte ptr [rbp-1],29h
    jmp     L44
L42:
    cmp     dword ptr [rbp+10h],2Bh
    jne     L43
    mov     byte ptr [rbp-1],2Bh
    jmp     L44
L43:
    mov     byte ptr [rbp-1],0FFh
L44:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::iter::StepBy::<std::ops::Range<u64>>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     byte ptr [rbp-21h],1
    cmp     qword ptr [rbp+20h],0
    je      L0
    mov     byte ptr [rbp-21h],0
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-40h]
    jmp     L3
L0:
    mov     edi,0FFFFFF90h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-68h],1Bh
    mov     edi,0FFFFFFA0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-20h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp+20h]
    sub     rax,1
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-8],1
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L4:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rbp-21h],0FFh
    je      L4
    jmp     L5
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn std::iter::StepBy::<std::ops::Range<usize>>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     byte ptr [rbp-21h],1
    cmp     qword ptr [rbp+20h],0
    je      L0
    mov     byte ptr [rbp-21h],0
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-40h]
    jmp     L3
L0:
    mov     edi,0FFFFFF90h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-68h],1Bh
    mov     edi,0FFFFFFA0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-20h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp+20h]
    sub     rax,1
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp-48h]
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-8],1
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L4:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rbp-21h],0FFh
    je      L4
    jmp     L5
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<u64>> for std::ops::Range<u64>>::setup
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    cmp     rax,rdx
    setb    [rbp-51h]
    test    byte ptr [rbp-51h],0FFh
    je      L0
    mov     rdi,[rbp+10h]
    mov     [rbp-60h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-68h],r8
    cmp     r8,rdi
    jae     L4
    jmp     L5
L0:
    mov     qword ptr [rbp-50h],0
    nop
L1:
    cmp     qword ptr [rbp+20h],0
    sete    [rbp-59h]
    test    byte ptr [rbp-59h],0FFh
    je      L7
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-70h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-68h]
    sub     rax,[rbp-60h]
    mov     [rbp-50h],rax
    jmp     L6
L5:
    mov     qword ptr [rbp-50h],0
L6:
    jmp     L1
L7:
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,20h
    call    ryo_h_DivUW64
    test    byte ptr [rbp-59h],0FFh
    je      L10
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-70h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L9:
    call    ryo_h_Unreachable
    ud2
L10:
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFB0h
    mov     edx,20h
    call    ryo_h_RemUW64
    cmp     qword ptr [rbp-68h],0
    jbe     L11
    mov     rdx,[rbp-58h]
    add     rdx,1
    mov     [rbp-20h],rdx
    jmp     L12
L11:
    mov     rax,[rbp-58h]
    mov     [rbp-20h],rax
L12:
    mov     rax,[rbp-20h]
    mov     [rbp+18h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::SpecRangeSetup<std::ops::Range<usize>> for std::ops::Range<usize>>::setup
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    cmp     rax,rdx
    setb    [rbp-51h]
    test    byte ptr [rbp-51h],0FFh
    je      L0
    mov     rdi,[rbp+10h]
    mov     [rbp-60h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-68h],r8
    cmp     r8,rdi
    jae     L4
    jmp     L5
L0:
    mov     qword ptr [rbp-50h],0
    nop
L1:
    cmp     qword ptr [rbp+20h],0
    sete    [rbp-59h]
    test    byte ptr [rbp-59h],0FFh
    je      L7
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-68h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-68h]
    sub     rax,[rbp-60h]
    mov     [rbp-50h],rax
    jmp     L6
L5:
    mov     qword ptr [rbp-50h],0
L6:
    jmp     L1
L7:
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,20h
    call    ryo_h_DivUW64
    test    byte ptr [rbp-59h],0FFh
    je      L10
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-68h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L9:
    call    ryo_h_Unreachable
    ud2
L10:
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFB0h
    mov     edx,20h
    call    ryo_h_RemUW64
    cmp     qword ptr [rbp-68h],0
    jbe     L11
    mov     rdx,[rbp-58h]
    add     rdx,1
    mov     [rbp-20h],rdx
    jmp     L12
L11:
    mov     rax,[rbp-58h]
    mov     [rbp-20h],rax
L12:
    mov     rax,[rbp-20h]
    mov     [rbp+18h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    add     rax,1
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFA4h
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFA4h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFA8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L5
    .long   L6
    .long   L4
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-38h],rax
    add     rax,[rbp-20h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-40h]
    mov     [rdx],rcx
    mov     rsi,[rbp-28h]
    sub     rsi,1
    mov     [rbp-60h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-60h]
    mov     [rdi+8],rcx
    mov     r8,[rbp-38h]
    mov     [rbp-8],r8
    mov     qword ptr [rbp-10h],1
    jmp     L3
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
L3:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     edi,0FFFFFF90h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-18h]
    jmp     L4
L6:
    mov     rax,[rbp-50h]
    mov     [rbp-20h],rax
    mov     [rbp-28h],rax
    mov     byte ptr [rbp-30h],0
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-28h],rsi
    cmp     rsi,0
    ja      L1
    jmp     L2

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u32>>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     qword ptr [rbp-8],10h
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::num::NonZero::<T>::new_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0D1h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-50h],0D1h
    mov     rdx,[rbp-50h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-28h]
    mov     [rbp-20h],rsi
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-70h],0
    mov     rdx,[rbp+10h]
    mov     [rbp-68h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     byte ptr [rbp-22h],1
    mov     byte ptr [rbp-21h],1
    mov     edi,0FFFFFFACh
    mov     esi,18h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFACh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L3
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     byte ptr [rbp-22h],0
    mov     rdx,[rbp+10h]
    mov     [rbp-38h],rdx
    mov     [rbp-70h],rdx
    call    fn0
    nop     [rcx-18h]
    jmp     L4
L3:
    mov     edi,0FFFFFFC0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-21h],0
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-18h]
    jmp     L4
L4:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    test    byte ptr [rbp-22h],0FFh
    jne     L9
    nop     [rax+rax]
    nop
L6:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L7:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    test    byte ptr [rbp-21h],0FFh
    je      L5
    jmp     L7
L9:
    jmp     L6
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L8

fn std::ptr::NonNull::<T>::new_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-11h]
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0D2h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0D2h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+18h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFF9Ch
    mov     esi,18h
    call    ryo_h_CtpopW64
    mov     eax,[rbp-64h]
    mov     [rbp-8],eax
    jmp     L4
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    sub     rdx,1
    and     rax,rdx
    cmp     rax,0
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-20h],2Ah
    mov     rdx,[rbp-28h]
    mov     rsi,[rbp-20h]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],2Ah
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-18h],rsi
    mov     [rbp-10h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-1]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     dword ptr [rbp-8],1
    sete    [rbp-2]
    test    byte ptr [rbp-2],0FFh
    je      L1
    jmp     L0

fn std::ptr::copy_nonoverlapping::<u8>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     byte ptr [rbp-11h],1
    test    byte ptr [rbp-11h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdi
    mov     qword ptr [rbp-40h],1
    mov     qword ptr [rbp-38h],1
    mov     r10,[rbp+20h]
    mov     [rbp-30h],r10
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
L0:
    imul    rax,[rbp+20h],1
    mov     [rbp-18h],rax
    mov     edi,18h
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::copy_nonoverlapping::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    cmp     qword ptr [rbp+30h],0
    jne     L0
    mov     byte ptr [rbp-1],1
    jmp     L1
L0:
    cmp     qword ptr [rbp+20h],0
    sete    [rbp-1]
L1:
    movzx   eax,byte ptr [rbp-1]
    mov     [rbp-2Bh],al
    mov     rdx,[rbp+10h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-98h],rsi
    call    fn0
    nop     [rcx-2Ch]
    jmp     L13
    nop
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-98h],rdx
    call    fn1
    nop     [rcx-2Ch]
    jmp     L18
    nop     [rax+rax]
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-98h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-90h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-88h],rdi
    call    fn2
    nop     [rcx-29h]
    jmp     L19
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFE0h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-18h],11Bh
    mov     rdx,[rbp-20h]
    mov     rsi,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFF88h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-70h],11Bh
    mov     rdx,[rbp-70h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-48h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-90h],0
    mov     rdx,[rbp+38h]
    mov     [rbp-88h],rdx
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-20h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop
L8:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-2Bh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-2Dh]
    movzx   esi,byte ptr [rbp-2Dh]
    xor     sil,1
    mov     [rbp-2Ah],sil
    test    byte ptr [rbp-2Ah],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rbp-2Ch],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L14:
    test    byte ptr [rbp-1],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rbp+18h]
    cmp     rax,0
    sete    [rbp-2Dh]
    movzx   esi,byte ptr [rbp-2Dh]
    xor     sil,1
    mov     [rbp-2Bh],sil
    test    byte ptr [rbp-2Bh],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rbp-2Ch],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rbp-29h],0FFh
    je      L5
    jmp     L8
    nop     [rax+rax]
L20:
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-78h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::io::error::CustomOwner> - shim(Some(core::io::error::CustomOwner))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::io::error::ErrorData<core::io::error::CustomOwner>> - shim(Some(core::io::error::ErrorData<core::io::error::CustomOwner>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-11h],al
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFEFh
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L1
    .long   L1
    .long   L1
    .long   L2
    nop     [rax+rax]
    nop     [rax]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L2:
    mov     rax,[rbp+10h]
    lea     rax,[rax+8]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-18h]
    jmp     L1

fn std::ptr::drop_glue::<core::io::error::repr::Repr> - shim(Some(core::io::error::repr::Repr))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>> - shim(Some(core::io::write::default_write_fmt::Adapter<'_, std::sys::stdio::unix::Stderr>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    lea     rax,[rax+8]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::map::HashMap<u64, u64, std::hash::RandomState>> - shim(Some(hashbrown::map::HashMap<u64, u64, std::hash::RandomState>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(std::string::String, usize)>> - shim(Some(hashbrown::raw::RawTable<(std::string::String, usize)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::raw::RawTable<(u64, u64)>> - shim(Some(hashbrown::raw::RawTable<(u64, u64)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>> - shim(Some(hashbrown::rustc_entry::RustcVacantEntry<'_, std::string::String, usize>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<&mut hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::rehash_in_place::{closure#0}}>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>> - shim(Some(hashbrown::scopeguard::ScopeGuard<hashbrown::raw::RawTableInner, {closure@hashbrown::raw::RawTableInner::prepare_resize<std::alloc::Global>::{closure#0}}>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::collections::HashMap<std::string::String, usize>> - shim(Some(std::collections::HashMap<std::string::String, usize>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::collections::HashMap<u64, u64>> - shim(Some(std::collections::HashMap<u64, u64>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::collections::hash_map::VacantEntry<'_, std::string::String, usize>> - shim(Some(std::collections::hash_map::VacantEntry<'_, std::string::String, usize>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::io::Error> - shim(Some(std::io::Error))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::result::Result<(), std::io::Error>> - shim(Some(std::result::Result<(), std::io::Error>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE4h
    mov     esi,0FFFFFFE8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFE4h
    call    ryo_h_ZextW32W64
    cmp     qword ptr [rbp-8],0
    jne     L1
    nop     [rax+rax]
    xchg    ax,ax
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-18h]
    jmp     L0

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    jmp     L5
    xchg    ax,ax
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn3
    nop     [rcx-18h]
    jmp     L3
L5:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn4
    nop     [rcx-18h]
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L6:
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-10h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym7]
L8:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L6

fn std::ptr::replace::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DDh
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],0DDh
    mov     rdx,[rbp-60h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+28h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-10h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    test    byte ptr [rbp+20h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
L5:
    jmp     L1
L6:
    jmp     L0
L7:
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L1
    jmp     L0
L8:
    test    byte ptr [rbp-1Ah],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L9:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx-68h]
    jmp     L11
L10:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L11:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9

fn std::ptr::swap_chunk::<1>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-1],al
    mov     rdx,[rbp+18h]
    movzx   edx,byte ptr [rdx]
    mov     [rbp-2],dl
    mov     rsi,[rbp+10h]
    movzx   ecx,byte ptr [rbp-2]
    mov     [rsi],cl
    mov     rdi,[rbp+18h]
    movzx   ecx,byte ptr [rbp-1]
    mov     [rdi],cl
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<2>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,word ptr [rax]
    mov     [rbp-2],ax
    mov     rdx,[rbp+18h]
    movzx   edx,word ptr [rdx]
    mov     [rbp-4],dx
    mov     rsi,[rbp+10h]
    movzx   ecx,word ptr [rbp-4]
    mov     [rsi],cx
    mov     rdi,[rbp+18h]
    movzx   ecx,word ptr [rbp-2]
    mov     [rdi],cx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<4>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     eax,[rax]
    mov     [rbp-4],eax
    mov     rdx,[rbp+18h]
    mov     edx,[rdx]
    mov     [rbp-8],edx
    mov     rsi,[rbp+10h]
    mov     ecx,[rbp-8]
    mov     [rsi],ecx
    mov     rdi,[rbp+18h]
    mov     ecx,[rbp-4]
    mov     [rdi],ecx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<8>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rsi],rcx
    mov     rdi,[rbp+18h]
    mov     rcx,[rbp-8]
    mov     [rdi],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_nonoverlapping::<hashbrown::raw::RawTableInner>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-41h],1
    test    byte ptr [rbp-41h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-80h],rsi
    mov     [rbp-78h],rdi
    mov     qword ptr [rbp-70h],20h
    mov     qword ptr [rbp-68h],8
    mov     r10,[rbp+20h]
    mov     [rbp-60h],r10
    mov     r11,[rbp+28h]
    mov     [rbp-58h],r11
    call    fn0
    nop     [rcx]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    imul    rax,[rbp-20h],20h
    mov     [rbp-18h],rax
    jmp     L3
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rax
    call    fn1
    nop     [rcx]
    jmp     L2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp-18h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    cmp     qword ptr [rbp+20h],0
    jne     L0
    mov     byte ptr [rbp-1],1
    jmp     L1
L0:
    cmp     qword ptr [rbp+30h],0
    sete    [rbp-1]
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-1]
    mov     [rbp-33h],dl
    mov     [rbp-0B0h],rax
    mov     rsi,[rbp+28h]
    mov     [rbp-0A8h],rsi
    call    fn0
    nop     [rcx-34h]
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-0A8h],rdx
    call    fn1
    nop     [rcx-34h]
    jmp     L18
    nop     [rax+rax]
L3:
    mov     rax,[rbp-10h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-98h],rdi
    call    fn2
    nop     [rcx-31h]
    jmp     L19
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFD8h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-20h],11Bh
    mov     rdx,[rbp-28h]
    mov     rsi,[rbp-20h]
    mov     [rbp-50h],rdx
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],11Bh
    mov     rdx,[rbp-78h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-50h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-0A0h],0
    mov     rdx,[rbp+38h]
    mov     [rbp-98h],rdx
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-28h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop
L8:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-33h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-35h]
    movzx   esi,byte ptr [rbp-35h]
    xor     sil,1
    mov     [rbp-32h],sil
    test    byte ptr [rbp-32h],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rbp-34h],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L14:
    test    byte ptr [rbp-1],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rbp+18h]
    cmp     rax,0
    sete    [rbp-35h]
    movzx   esi,byte ptr [rbp-35h]
    xor     sil,1
    mov     [rbp-33h],sil
    test    byte ptr [rbp-33h],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rbp-34h],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rbp-31h],0FFh
    je      L5
    jmp     L8
    nop     [rax+rax]
L20:
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-80h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::swap_nonoverlapping_bytes
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     qword ptr [rbp-58h],8
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_DivUW64
    mov     qword ptr [rbp-58h],8
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_RemUW64
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFACh
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFACh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L1
    .long   L6
L1:
    mov     rax,[rbp-30h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    mov     [rbp-70h],rdx
    mov     [rbp-68h],rsi
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L2
L2:
    mov     rax,[rbp-28h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFACh
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFACh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L3:
    .long   L5
    .long   L4
    .long   L6
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-38h],rax
    imul    rdx,[rbp-20h],8
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    imul    rcx,rdx,1
    add     rdi,rcx
    mov     [rbp-50h],rdi
    mov     [rbp-70h],rsi
    mov     [rbp-68h],rdi
    mov     [rbp-60h],rax
    call    fn1
    nop     [rcx-10h]
    jmp     L5
L5:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L6:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+20h]
    mov     qword ptr [rbp-10h],0
    mov     [rbp-8],rax
    nop     [rax+rax]
L0:
    mov     rax,[rbp-10h]
    mov     rdx,[rbp-8]
    cmp     rax,rdx
    setb    [rbp-41h]
    test    byte ptr [rbp-41h],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     rax,[rbp-10h]
    mov     [rbp-50h],rax
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L5
    jmp     L4
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-90h],rax
    mov     qword ptr [rbp-88h],1
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-28h]
L5:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-10h],rax
    mov     rdx,[rbp-50h]
    mov     qword ptr [rbp-40h],1
    mov     [rbp-48h],rdx
    mov     rdi,[rbp+10h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rbp-50h],rdi
    mov     r8,[rbp+18h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rbp-60h],r8
    mov     [rbp-90h],rdi
    mov     [rbp-88h],r8
    call    fn2
    nop     [rcx-18h]
    jmp     L1

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     qword ptr [rbp-28h],0
    and     rax,4
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L0
    mov     rdi,[rbp-28h]
    mov     r8,[rbp+10h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rbp-30h],r8
    mov     r9,[rbp-28h]
    mov     r10,[rbp+18h]
    imul    rcx,r9,1
    add     r10,rcx
    mov     [rbp-40h],r10
    mov     [rbp-70h],r8
    mov     [rbp-68h],r10
    call    fn0
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,4
    mov     [rbp-28h],rax
    jmp     L0
L0:
    mov     rax,[rbp-20h]
    and     rax,2
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L1
    mov     rsi,[rbp-28h]
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rbp-30h],rdi
    mov     r8,[rbp-28h]
    mov     r9,[rbp+18h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rbp-40h],r9
    mov     [rbp-70h],rdi
    mov     [rbp-68h],r9
    call    fn1
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,2
    mov     [rbp-28h],rax
    jmp     L1
L1:
    mov     rax,[rbp-20h]
    and     rax,1
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rbp-28h]
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rbp-30h],rdi
    mov     r8,[rbp-28h]
    mov     r9,[rbp+18h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rbp-40h],r9
    mov     [rbp-70h],rdi
    mov     [rbp-68h],r9
    call    fn2
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,1
    mov     [rbp-28h],rax
    jmp     L2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    lea     rdx,[rbp-28h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    movzx   esi,byte ptr [rbp+28h]
    mov     [rbp-40h],sil
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    call    fn1
    nop     [rcx-5]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-6],al
    mov     edi,0FFFFFFFCh
    mov     esi,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn std::slice::from_raw_parts::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rbp+18h],0
    je      L9
    jmp     L10
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],117h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],117h
    mov     rdx,[rbp-60h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-10h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L3
    jmp     L0
    nop     [rax+rax]
L7:
    jmp     L3
L8:
    test    byte ptr [rbp-1Ah],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rbp-70h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rbp+28h]
    cmp     rax,[rbp-28h]
    setbe   [rbp-1Ah]
    test    byte ptr [rbp-1Ah],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L12:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-68h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::slice::from_raw_parts_mut::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rbp+18h],0
    je      L9
    jmp     L10
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],11Bh
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],11Bh
    mov     rdx,[rbp-60h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-10h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp+10h]
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L3
    jmp     L0
    nop     [rax+rax]
L7:
    jmp     L3
L8:
    test    byte ptr [rbp-1Ah],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rbp-70h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rbp+28h]
    cmp     rax,[rbp-28h]
    setbe   [rbp-1Ah]
    test    byte ptr [rbp-1Ah],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L12:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-68h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::str::<impl std::borrow::ToOwned for str>::to_owned
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-30h]
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFD0h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::try_with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     byte ptr [rbp-21h],1
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-58h],rdx
    mov     qword ptr [rbp-70h],0
    mov     edi,0FFFFFFA8h
    lea     rsi,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-50h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    mov     rax,[rbp-50h]
    cmp     rax,0
    sete    [rbp-51h]
    test    byte ptr [rbp-51h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-18h],0
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rbp-21h],0FFh
    je      L4
    jmp     L5
L7:
    mov     qword ptr [rbp-48h],0
    mov     qword ptr [rbp-40h],0
    mov     qword ptr [rbp-40h],1
    cmp     qword ptr [rbp-40h],1
    sete    [rbp-41h]
    mov     qword ptr [rbp-18h],1
    jmp     L3
L8:
    mov     rax,[rbp-50h]
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-21h],0
    mov     [rbp-48h],rax
    mov     [rbp-70h],rax
    call    fn2
    nop     [rcx-40h]
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn std::thread::LocalKey::<std::cell::Cell<(u64, u64)>>::with::<{closure@std::hash::RandomState::new::{closure#0}}, std::hash::RandomState>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    call    fn0
    nop     [rcx-30h]
    mov     rax,[rbp-30h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L5
    .long   L2
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     edi,0FFFFFFC0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-18h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    lea     rax,[rax+10h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-39h],al
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFC7h
    call    ryo_h_ZextW8W64
    cmp     qword ptr [rbp-18h],1
    jne     L0
    mov     rdx,[rbp+10h]
    mov     [rbp-30h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-8],rsi
    jmp     L1
L0:
    mov     byte ptr [rbp-21h],0
    mov     rdx,[rbp+10h]
    mov     [rbp-60h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-58h],rsi
    call    fn0
    nop     [rcx-8]
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rbp-21h],0FFh
    je      L2
    jmp     L3
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L4

fn std::thread::local_impl::LazyStorage::<std::cell::Cell<(u64, u64)>, !>::get_or_init_slow::<fn() -> std::cell::Cell<(u64, u64)> {std::hash::RandomState::new::KEYS::__rust_std_internal_init_fn}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,120h
    mov     rax,[rbp+10h]
    lea     rax,[rax+10h]
    mov     [rbp-80h],rax
    movzx   eax,byte ptr [rax]
    mov     [rbp-71h],al
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF8Fh
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFE8h
    xor     esi,esi
    mov     edx,3
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
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-8],0
    jmp     L13
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     [rbp-80h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-8],rdx
    jmp     L13
L4:
    mov     edi,0FFFFFF0Ch
    mov     esi,18h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFF0Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFF70h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L5]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L5:
    .long   L14
    .long   L15
    .long   L1
L6:
    lea     rax,[rbp-50h]
    mov     [rbp-98h],rax
    mov     edi,0FFFFFF48h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B0h],2Bh
    mov     rdx,[rbp-0B8h]
    mov     rsi,[rbp-0B0h]
    mov     [rbp-0C0h],rdx
    mov     edi,0FFFFFF10h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0E8h],2Bh
    mov     rdx,[rbp-0E8h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-0C0h]
    mov     [rbp-0A8h],rsi
    mov     [rbp-0A0h],rdx
    mov     rdi,[rbp-98h]
    mov     [rbp-120h],rdi
    mov     edi,0FFFFFEE8h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx-90h]
    jmp     L9
L7:
    lea     rax,[rbp-80h]
    mov     [rbp-98h],rax
    mov     [rbp-120h],rax
    mov     edi,0FFFFFF08h
    lea     rsi,[sym3]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
    jmp     L26
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-120h],rax
    call    fn5
    nop     [rcx-38h]
    jmp     L12
L9:
    lea     rax,[rbp-90h]
    mov     [rbp-0F8h],rax
    mov     [rbp-120h],rax
    call    fn6
    nop     [rcx-0F8h]
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx-50h]
    jmp     L11
L10:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym9]
L11:
    call    ryo_h_Unreachable
    ud2
L12:
    mov     rax,[rbp+10h]
    mov     [rbp-70h],rax
    mov     [rbp-88h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-8],rdx
    jmp     L13
L13:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L14:
    mov     qword ptr [rbp-88h],0
    jmp     L18
L15:
    mov     rax,[rbp+18h]
    mov     [rbp-98h],rax
    mov     qword ptr [rbp-0B0h],0
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFF68h
    xor     edx,edx
    mov     ecx,18h
    call    ryo_h_LoadCopy
    mov     edi,0FFFFFF68h
    xor     esi,esi
    mov     edx,0FFFFFF50h
    mov     ecx,18h
    call    ryo_h_StoreCopy
    mov     rax,[rbp-88h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF70h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L16]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L16:
    .long   L18
    .long   L19
    .long   L1
    nop     [rax+rax]
L17:
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF48h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF58h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-0F1h],1
    test    byte ptr [rbp-0F1h],0FFh
    je      L24
    jmp     L23
L18:
    call    fn10
    nop     [rcx-30h]
    jmp     L20
L19:
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    jmp     L17
L20:
    jmp     L17
    nop     [rax+rax]
    nop
L21:
    mov     byte ptr [rbp-82h],1
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+10h]
    mov     [rbp-90h],rdx
    movzx   edx,byte ptr [rdx]
    mov     [rbp-81h],dl
    mov     rsi,[rbp-90h]
    movzx   ecx,byte ptr [rbp-82h]
    mov     [rsi],cl
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFF7Fh
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFB8h
    xor     esi,esi
    mov     edx,3
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L22]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L22:
    .long   L8
    .long   L7
    .long   L6
    .long   L1
L23:
    mov     rax,[rbp-68h]
    mov     [rbp-0A0h],rax
    mov     [rbp-120h],rax
    mov     qword ptr [rbp-118h],8
    mov     byte ptr [rbp-110h],0
    mov     edi,0FFFFFEF8h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-68h]
L24:
    mov     byte ptr [rbp-0F1h],0
    test    byte ptr [rbp-0F1h],0FFh
    je      L25
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    jmp     L21
L25:
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF78h
    xor     edx,edx
    call    ryo_h_LoadW128
    mov     edi,0FFFFFF78h
    xor     esi,esi
    mov     edx,0FFFFFF68h
    call    ryo_h_StoreW128
    jmp     L21
L26:
    jmp     L12

fn std::vec::Vec::<T, A>::set_len::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    cmp     rax,[rbp+10h]
    jb      L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0C6h
    mov     rdx,[rbp-10h]
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0C6h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi+8]
    mov     rdi,[rbp+18h]
    mov     rdi,[rdi+10h]
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdi
    mov     r8,[rbp-20h]
    cmp     r8,[rbp-38h]
    jne     L0
    mov     [rbp-48h],rax
    mov     [rbp-50h],rsi
    mov     [rbp-80h],rax
    mov     [rbp-78h],rsi
    mov     [rbp-70h],r8
    call    fn0
    nop     [rcx-1]
    jmp     L1
L0:
    mov     byte ptr [rbp-1],0
L1:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

