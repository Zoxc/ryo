fn <&u64 as std::ops::Rem<u64>>::rem
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rsi
    mov     r12,[rdi]
    cmp     rbx,0
    jne     L0
    mov     rdi,rdx
    call    qword ptr [sym0]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rdi,r12
    mov     rsi,rbx
    call    ryo_hr_RemUW64
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp],rbx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
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
    lea     rax,[rsp+10h]
    mov     rdi,rax
    call    fn0
    mov     rax,[rsp+10h]
    xor     rax,rbx
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    xor     rax,0FFh
    mov     [rsp+18h],rax
    lea     rax,[rsp+10h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+20h]
    xor     rax,rcx
    mov     rcx,[rsp+18h]
    xor     rax,rcx
    mov     rcx,[rsp+28h]
    xor     rax,rcx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     [rsp+70h],rbp
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
    mov     eax,0
    jmp     L4
L1:
    mov     rax,[rbx+40h]
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+60h],r14
    mov     rax,[rsp+60h]
    mov     rdi,r13
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r15,rax
    jmp     L10
L2:
    mov     rax,[rbx+40h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+60h]
    imul    rax,8
    mov     rdi,[rsp+50h]
    mov     rsi,rax
    call    ryo_hr_ShlW64
    mov     rcx,[rbx+38h]
    or      rcx,rax
    mov     [rbx+38h],rcx
    cmp     r13,r14
    jae     L3
    mov     rax,[rbx+40h]
    add     rax,r13
    mov     [rbx+40h],rax
    jmp     L9
L3:
    mov     rax,[rbx+38h]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rdi,rbx
    call    fn1
    mov     rax,[rbx+38h]
    mov     rcx,[rbx]
    xor     rcx,rax
    mov     [rbx],rcx
    mov     qword ptr [rbx+40h],0
    mov     rax,r14
L4:
    mov     rcx,r13
    sub     rcx,rax
    mov     rdx,rcx
    and     rdx,7
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
    mov     [rsp+20h],rdx
    mov     [rsp+28h],r12
    mov     [rsp+30h],r13
    mov     [rsp+38h],rbx
L5:
    mov     r10,[rsp+10h]
    mov     [rsp+60h],r10
    mov     rax,[rsp+18h]
    sub     rax,[rsp+20h]
    mov     rcx,[rsp+60h]
    cmp     rcx,rax
    jae     L8
    mov     qword ptr [rsp+60h],0
    mov     r11,[rsp+28h]
    mov     r10,[rsp+10h]
    lea     r11,[r11+r10]
    mov     [rsp+40h],r11
    lea     r11,[rsp+60h]
    mov     [rsp+48h],r11
    jmp     L6
L6:
    jmp     L11
L7:
    mov     rbp,[rax]
    xor     rbp,rcx
    mov     [rax],rbp
    add     rdx,8
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdi
    mov     [rsp+28h],r8
    mov     [rsp+30h],r9
    mov     [rsp+38h],rax
    jmp     L5
L8:
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+20h]
    call    qword ptr [fn2.slot]
    mov     r11,[rsp+38h]
    mov     [r11+38h],rax
    mov     r11,[rsp+38h]
    mov     r10,[rsp+20h]
    mov     [r11+40h],r10
L9:
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,0D8h
    ret
L10:
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,0
    mov     rcx,r15
    call    qword ptr [fn2.slot]
    mov     [rsp+50h],rax
    jmp     L2
L11:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     edx,1
    mov     ecx,1
    mov     r8d,8
    mov     r9,rax
    call    fn5
    mov     eax,8
    imul    rax,1
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+60h]
    mov     r11,[rsp+38h]
    mov     rax,[r11+18h]
    xor     rax,rbx
    mov     r11,[rsp+38h]
    mov     [r11+18h],rax
    mov     r10,[rsp+38h]
    mov     [rsp+60h],r10
    mov     rax,[rsp+60h]
    mov     rdi,rax
    call    fn1
    mov     rax,[rsp+38h]
    mov     rcx,rbx
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     r9,[rsp+30h]
    jmp     L7
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
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-110h]
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
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-98h],r11
    lea     rsp,[rsp+40h]
    jmp     L5
L15:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-110h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     r9,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L7

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn0
    mov     byte ptr [rsp+2Fh],0FFh
    lea     rax,[rsp+2Fh]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+20h],1
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn0
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::c_rounds
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx+8]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn <core::hash::sip::Sip13Rounds as core::hash::sip::Sip>::d_rounds
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx+8]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx+8]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,0Dh
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    add     rax,rcx
    mov     [rbx+8],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    add     rax,rcx
    mov     [rbx],rax
    mov     rax,[rbx+10h]
    mov     rdi,rax
    mov     esi,11h
    call    ryo_hr_RotlW64
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rbx+10h]
    xor     rcx,rax
    mov     [rbx+10h],rcx
    mov     rax,[rbx+18h]
    mov     rdi,rax
    mov     esi,15h
    call    ryo_hr_RotlW64
    mov     [rbx+18h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+18h]
    xor     rcx,rax
    mov     [rbx+18h],rcx
    mov     rax,[rbx+8]
    mov     rdi,rax
    mov     esi,20h
    call    ryo_hr_RotlW64
    mov     [rbx+8],rax
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn <hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    jmp     L3
    jmp     L2
L0:
    mov     rax,r14
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    add     rsp,88h
    ret
L1:
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+18h]
    lea     rcx,[rcx+8]
    mov     rdx,[rbx]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rcx
    mov     rax,[rsp+28h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rdx
    mov     rsi,r12
    mov     rdx,rax
    call    qword ptr [fn0.slot]
    mov     r14,rax
    jmp     L0
L2:
    mov     eax,8
    jmp     L1
L3:
    mov     [rsp+10h],r13
    mov     rax,[rsp+10h]
    jmp     L6
    jmp     L5
L4:
    mov     rax,rcx
    jmp     L1
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
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
L8:
    ret
L9:
    ret
L10:
    ret

fn <std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold::<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    mov     rdx,rcx
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::finish
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write
    sub     rsp,18h
    call    fn0
    add     rsp,18h
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_str
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <std::hash::DefaultHasher as std::hash::Hasher>::write_u64
    sub     rsp,28h
    mov     [rsp+10h],rsi
    lea     rax,[rsp+10h]
    mov     rsi,rax
    mov     edx,8
    call    qword ptr [fn0.slot]
    add     rsp,28h
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
    mov     rax,[rsp+148h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
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
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+8],rsi
    lea     rax,[rsp+18h]
    mov     rsi,rdi
    mov     rdi,rax
    call    fn0
    jmp     L0
    mov     rbx,rax
    jmp     L4
L0:
    lea     rax,[rsp+8]
    lea     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn1.slot]
    jmp     L1
    jmp     L5
L1:
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    fn2
    jmp     L2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L5
L2:
    mov     rbx,[rsp+60h]
    add     rsp,78h
    ret
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L4:
    mov     rax,rbx
    jmp     L3
L5:
    jmp     L3
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
L7:
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+8],rsi
    lea     rax,[rsp+18h]
    mov     rsi,rdi
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L0
    mov     rbx,rax
    jmp     L4
L0:
    lea     rax,[rsp+8]
    lea     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn1.slot]
    jmp     L1
    jmp     L5
L1:
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L5
L2:
    mov     rbx,[rsp+60h]
    add     rsp,78h
    ret
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L4:
    mov     rax,rbx
    jmp     L3
L5:
    jmp     L3
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
L7:
    ret

fn <std::iter::StepBy<std::ops::Range<u64>> as std::iter::Iterator>::next
    sub     rsp,18h
    call    fn0
    add     rsp,18h
    ret

fn <std::ops::Range<u32> as std::iter::range::RangeIteratorImpl>::spec_next
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+4]
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    test    al,al
    je      L0
    mov     r12d,[rbx]
    mov     rdi,r12
    mov     esi,1
    mov     edi,edi
    call    qword ptr [fn1.slot]
    mov     [rbx],eax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    mov     rdx,r12
    mov     eax,eax
    mov     edx,edx
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <std::ops::Range<u64> as std::iter::range::RangeIteratorImpl>::spec_next
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+8]
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    test    al,al
    je      L0
    mov     r12,[rbx]
    mov     rdi,r12
    mov     esi,1
    call    qword ptr [fn1.slot]
    mov     [rbx],rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    mov     rdx,r12
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <std::string::String as std::cmp::PartialEq>::eq
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret

fn <std::string::String as std::hash::Hash>::hash::<std::hash::DefaultHasher>
    sub     rsp,38h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rsi
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [fn0.slot]
    add     rsp,38h
    ret

fn <u32 as std::iter::Step>::forward_unchecked
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     rdi,rsi
    call    ryo_hr_TruncW64W32
    mov     r12,rax
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    mov     edi,edi
    mov     esi,esi
    call    qword ptr [fn1.slot]
    add     ebx,r12d
    mov     rax,rbx
    mov     eax,eax
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <u64 as hashbrown::Equivalent<u64>>::equivalent
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rdi,rsi
    call    qword ptr [fn0.slot]
    mov     rdi,rbx
    mov     rsi,rax
    call    fn1
    movzx   eax,al
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn <u64 as std::borrow::Borrow<u64>>::borrow
    sub     rsp,18h
    mov     rax,rdi
    add     rsp,18h
    ret

fn <u64 as std::iter::Step>::forward_unchecked
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    add     rbx,r12
    mov     rax,rbx
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <u8 as core::slice::cmp::SlicePartialEq<u8>>::equal_same_length
    sub     rsp,38h
    imul    rdx,1
    mov     [rsp+18h],rdx
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     eax,[rsp+24h]
    cmp     eax,0
    sete    al
    movzx   eax,al
    add     rsp,38h
    ret

fn <usize as std::cmp::Ord>::min
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    lea     rax,[rsp+18h]
    lea     rcx,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L0
    mov     rbx,rax
    jmp     L8
L0:
    test    al,al
    je      L1
    mov     rax,[rsp+18h]
    jmp     L2
L1:
    mov     rax,[rsp+10h]
L2:
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
L3:
    jmp     L6
L4:
    mov     [rsp],rbx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L5:
    jmp     L4
L6:
    jmp     L7
L7:
    jmp     L5
L8:
    jmp     L3
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
    ret
L11:
    ret
L12:
    ret

fn <usize as std::default::Default>::default
    sub     rsp,18h
    mov     eax,0
    add     rsp,18h
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    cmp     rdi,rsi
    jae     L0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0D6h
    shl     rax,1
    or      rax,1
    mov     rdi,r12
    mov     rsi,rax
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [sym2]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
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
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     rbx,rdi
    mov     r12,rsi
    lea     rdi,[sym0]
    call    ryo_hr_AddrSym
    mov     [rsp+28h],r12
    mov     [rsp+30h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     [rsp],rbx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0
    mov     ecx,0FFFFFFB0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    add     rsp,68h
    ret

fn core::hash::impls::<impl std::hash::Hash for &std::string::String>::hash::<std::hash::DefaultHasher>
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::hash::impls::<impl std::hash::Hash for &u64>::hash::<std::hash::DefaultHasher>
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::hash::impls::<impl std::hash::Hash for u64>::hash::<std::hash::DefaultHasher>
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::hash::sip::Hasher::<core::hash::sip::Sip13Rounds>::reset
    sub     rsp,18h
    mov     qword ptr [rdi+30h],0
    mov     rax,[rdi+20h]
    mov     r10,736F6D6570736575h
    xor     rax,r10
    mov     [rdi],rax
    mov     rax,[rdi+28h]
    mov     r10,646F72616E646F6Dh
    xor     rax,r10
    mov     [rdi+10h],rax
    mov     rax,[rdi+20h]
    mov     r10,6C7967656E657261h
    xor     rax,r10
    mov     [rdi+8],rax
    mov     rax,[rdi+28h]
    mov     r10,7465646279746573h
    xor     rax,r10
    mov     [rdi+18h],rax
    mov     qword ptr [rdi+40h],0
    add     rsp,18h
    ret

fn core::hash::sip::u8to64_le
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     [rsp+70h],rbp
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rcx
    mov     eax,0
    add     rax,3
    cmp     rax,[rsp+20h]
    jb      L1
    jmp     L0
L0:
    mov     ebx,0
    mov     r12d,0
    jmp     L3
L1:
    mov     dword ptr [rsp+60h],0
    mov     rax,[rsp+28h]
    add     rax,0
    mov     r11,[rsp+10h]
    lea     r15,[r11+rax]
    lea     rbp,[rsp+60h]
    jmp     L2
L2:
    jmp     L12
L3:
    mov     rax,rbx
    add     rax,1
    cmp     rax,[rsp+20h]
    jb      L5
    jmp     L4
L4:
    mov     [rsp+30h],rbx
    mov     [rsp+38h],r12
    jmp     L7
L5:
    mov     word ptr [rsp+54h],0
    mov     rax,[rsp+28h]
    add     rax,rbx
    mov     r11,[rsp+10h]
    lea     r14,[r11+rax]
    lea     r13,[rsp+54h]
    jmp     L6
L6:
    jmp     L13
L7:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+20h]
    jb      L9
    jmp     L8
L8:
    mov     rax,[rsp+38h]
    jmp     L11
L9:
    mov     r11,[rsp+28h]
    add     r11,[rsp+30h]
    mov     [rsp+40h],r11
    jmp     L10
L10:
    jmp     L14
L11:
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,0D8h
    ret
L12:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,1
    mov     ecx,1
    mov     r8d,4
    mov     r9,rax
    call    fn1
    mov     eax,4
    imul    rax,1
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     eax,[rsp+60h]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     ecx,0
    add     rcx,4
    mov     rbx,rcx
    mov     r12,rax
    jmp     L3
L13:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,1
    mov     ecx,1
    mov     r8d,2
    mov     r9,rax
    call    fn1
    mov     eax,2
    imul    rax,1
    mov     rdi,r13
    mov     rsi,r14
    mov     rdx,rax
    call    ryo_hr_Memcpy
    movzx   eax,word ptr [rsp+54h]
    mov     rdi,rax
    call    ryo_hr_ZextW16W64
    mov     rcx,rbx
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      r12,rax
    add     rbx,2
    mov     [rsp+30h],rbx
    mov     [rsp+38h],r12
    jmp     L7
L14:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+18h]
    mov     rdx,rax
    call    qword ptr [fn5.slot]
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+18h]
    setb    al
    mov     [rsp+55h],al
    mov     r11,[rsp+10h]
    mov     r10,[rsp+40h]
    lea     rax,[r11+r10]
    movzx   eax,byte ptr [rax]
    mov     rdi,rax
    call    ryo_hr_ZextW8W64
    mov     rcx,[rsp+30h]
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      rax,[rsp+38h]
    jmp     L11
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
    ret
L17:
    ret
L18:
    ret

fn core::num::<impl u32>::unchecked_add::precondition_check
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    call    ryo_hr_AddOvfUW32
    test    dl,dl
    je      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0B8h
    shl     rax,1
    or      rax,1
    mov     rdi,r12
    mov     rsi,rax
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [sym2]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn core::num::<impl u64>::unchecked_add::precondition_check
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    call    ryo_hr_AddOvfUW64
    test    dl,dl
    je      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0B8h
    shl     rax,1
    or      rax,1
    mov     rdi,r12
    mov     rsi,rax
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [sym2]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,rdx
    mov     rsi,rcx
    call    ryo_hr_MulOvfUW64
    mov     r13,rax
    test    dl,dl
    je      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    cmp     rbx,r12
    jae     L1
    mov     rax,r12
    sub     rax,rbx
    jmp     L2
L1:
    sub     rbx,r12
    mov     rax,rbx
L2:
    cmp     r13,rax
    setbe   al
    movzx   eax,al
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64>
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx+18h]
    cmp     rax,0
    jne     L0
    mov     eax,0
    jmp     L2
L0:
    mov     rax,rbx
    lea     rax,[rax+20h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn0
    mov     r13,rax
    jmp     L3
L1:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L3:
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r12
    call    qword ptr [fn1.slot]
    mov     rbx,rax
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L4]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L4:
    .long   L5
    .long   L6
    .long   L1
L5:
    mov     eax,0
    jmp     L2
L6:
    jmp     L9
    jmp     L8
L7:
    lea     rax,[rax+8]
    jmp     L2
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,rbx
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,rbx
    mov     rbx,r11
    mov     rax,rbx
    jmp     L10
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,118h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     rbx,[rax]
    mov     [rsp+98h],rbx
    jmp     L11
    jmp     L10
L0:
    mov     rax,[rsp+0A0h]
    cmp     rax,0
    je      L13
    jmp     L14
L1:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
L2:
    jmp     L20
    jmp     L19
L3:
    jmp     L7
L4:
    test    al,al
    je      L5
    jmp     L6
L5:
    mov     rax,[rsp+8]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L6
    mov     r13,rax
    jmp     L24
L6:
    jmp     L0
L7:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    add     rsp,118h
    ret
L8:
    mov     [rsp],r13
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
L9:
    mov     rax,[rsp+8]
    mov     r14,[rax+18h]
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFF70h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+30h],r14
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF00h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L10:
    mov     ebx,1
    jmp     L11
L11:
    mov     [rsp+90h],rbx
    mov     rax,[rsp+90h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+8]
    mov     rax,[rax]
    mov     rcx,[rsp+8]
    mov     rcx,[rcx+8]
    add     rcx,1
    lea     rdx,[rsp+80h]
    mov     rsi,[rsp+0A0h]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,rax
    call    qword ptr [fn1.slot]
    jmp     L12
    mov     r13,rax
    jmp     L24
L12:
    jmp     L9
L13:
    jmp     L3
L14:
    lea     rax,[rsp+80h]
    mov     rdi,rax
    call    fn2
    mov     r12,rax
    jmp     L15
    mov     r13,rax
    jmp     L24
L15:
    mov     rax,[rsp+0A0h]
    sub     rax,1
    mov     [rsp+0A0h],rax
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L16]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L16:
    .long   L3
    .long   L2
    .long   L1
L17:
    mov     rcx,rax
    lea     rcx,[rcx+8]
    lea     rdx,[rsp+8]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn3
    jmp     L18
    mov     rcx,rax
    mov     r13,rcx
    jmp     L24
L18:
    mov     rcx,rbx
    jmp     L4
L19:
    mov     eax,8
    mov     rbx,r12
    jmp     L17
L20:
    jmp     L23
    jmp     L22
L21:
    mov     rbx,rcx
    jmp     L17
L22:
    mov     rax,r12
    mov     rcx,r12
    jmp     L21
L23:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,r12
    mov     rax,r11
    mov     rcx,r12
    jmp     L21
L24:
    jmp     L8
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
L26:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-140h]
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
    mov     r11,[rdx-8]
    mov     [rsp+28h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp]
    mov     [rdx-100h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-108h],r11
    lea     rsp,[rsp+30h]
    jmp     L0
L27:
    ret
L28:
    ret
L29:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    movzx   r11d,byte ptr [rdx-0B1h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-8]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+10h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L4
L30:
    ret
L31:
    ret
L32:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-8]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+10h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L17
L33:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-8]
    mov     [rsp+38h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     [rdx-0C0h],r13
    mov     [rdx-0D0h],r14
    mov     r11,[rsp+10h]
    mov     [rdx-100h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-108h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L21

fn hashbrown::map::equivalent_key::<u64, u64, u64>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret

fn hashbrown::map::make_hasher::<std::string::String, usize, std::hash::RandomState>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    fn0
    add     rsp,18h
    ret

fn hashbrown::map::make_hasher::<u64, u64, std::hash::RandomState>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    fn0
    add     rsp,18h
    ret

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
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L4
    .long   L3
    .long   L2
L2:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     r12,rax
    jmp     L5
L4:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     rax,[rsp+18h]
    cmp     rax,0
    sete    al
    mov     [rsp+17h],al
    mov     rax,[rbx]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+28h],10h
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+28h]
    lea     rax,[rax+rcx]
    mov     [rbx],rax
    mov     rax,[rbx]
    mov     [rsp+18h],rax
    mov     [rsp+18h],rax
    lea     rax,[rsp+50h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym1]
    jmp     L6
L5:
    mov     rdi,r12
    call    ryo_hr_ZextW32W64
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    mov     rax,[rsp+18h]
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    movzx   ecx,word ptr [rsp+18h]
    sub     ecx,1
    mov     [rsp+1Ah],cx
    movzx   ecx,word ptr [rsp+18h]
    movzx   edx,word ptr [rsp+1Ah]
    and     ecx,edx
    mov     [rsp+1Ch],cx
    movzx   ecx,word ptr [rsp+1Ch]
    mov     [rsp+1Eh],cx
    movzx   ecx,word ptr [rsp+1Eh]
    mov     [rbx+18h],cx
    mov     [rsp+18h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rsp+18h]
    add     rax,rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,rax
    mov     eax,1
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,0C8h
    ret
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rbx+18h],ax
    mov     rax,[rbx+8]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rax,10h
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rbx+8],rax
    jmp     L0
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
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L9
    .long   L8
    .long   L7
L2:
    mov     rcx,[rax+8]
    mov     rdx,[rax+10h]
    mov     [rsp+18h],rdx
    mov     rdx,[rsp+18h]
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
    lea     rax,[rsp+60h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L17
L6:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,0E8h
    ret
L7:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     r12,rax
    jmp     L11
L9:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     rax,[rsp+18h]
    cmp     rax,0
    sete    al
    mov     [rsp+17h],al
    jmp     L10
L10:
    mov     r13,rbx
    jmp     L5
    mov     rax,rbx
    jmp     L2
L11:
    mov     rdi,r12
    call    ryo_hr_ZextW32W64
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    mov     rax,[rsp+18h]
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    movzx   ecx,word ptr [rsp+18h]
    sub     ecx,1
    mov     [rsp+1Ah],cx
    movzx   ecx,word ptr [rsp+18h]
    movzx   edx,word ptr [rsp+1Ah]
    and     ecx,edx
    mov     [rsp+1Ch],cx
    movzx   ecx,word ptr [rsp+1Ch]
    mov     [rsp+1Eh],cx
    movzx   ecx,word ptr [rsp+1Eh]
    mov     [rbx+18h],cx
    mov     [rsp+18h],rax
    jmp     L12
    mov     rax,[rbx]
    mov     rcx,[rsp+18h]
    add     rax,rcx
    mov     rcx,rax
    jmp     L13
L12:
    mov     rax,[rbx]
    jmp     L16
    jmp     L15
L13:
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+10h]
    mov     rax,rcx
    jmp     L6
L14:
    jmp     L13
L15:
    mov     rcx,rax
    jmp     L14
L16:
    mov     rcx,[rsp+18h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L14
L17:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r13+18h],ax
    jmp     L18
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    add     rax,10h
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     rcx,r13
    jmp     L19
L18:
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    jmp     L22
    jmp     L21
L19:
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     [rcx],rax
    mov     rax,[rcx+8]
    mov     r10d,10h
    lea     rax,[rax+r10]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L20:
    jmp     L19
L21:
    mov     rax,[rsp+18h]
    mov     rcx,r13
    jmp     L20
L22:
    mov     rax,[rsp+18h]
    mov     r11,0FFFFFFFFFFFFFFF0h
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,r13
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
    .long   L30
    .long   L31
L24:
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
L25:
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
L26:
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
L27:
    ret
L28:
    ret
L29:
    ret
L30:
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
    jmp     L19
L31:
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
    jmp     L20

fn hashbrown::raw::RawIterRange::<(u64, u64)>::fold_impl::<{closure@<hashbrown::map::Iter<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@<std::collections::hash_map::Values<'_, u64, u64> as std::iter::Iterator>::fold<u64, {closure@bench/hashmap.rs:24:43: 24:50}>::{closure#0}}>::{closure#0}}, u64>
    sub     rsp,188h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     [rsp+70h],rbp
    mov     rbx,rsi
    mov     r12,rdx
    mov     [rsp+140h],rcx
    mov     [rsp],rdi
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFEA8h
    mov     edx,0FFFFFE80h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     r13d,1
L0:
    movzx   r14d,word ptr [rsp+40h]
    mov     rdi,r14
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L13
    .long   L12
    .long   L11
L2:
    sub     rcx,1
    mov     rbx,rcx
    mov     r12,rax
    mov     r13d,1
    jmp     L0
L3:
    jmp     L6
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+50h],rax
    lea     rax,[rsp+0D0h]
    mov     rcx,[rsp+50h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L5
    mov     r11,[rsp+10h]
    mov     [rsp+18h],r11
    mov     [rsp+20h],rax
    jmp     L28
L5:
    jmp     L21
L6:
    mov     rax,r12
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,188h
    ret
L7:
    jmp     L10
L8:
    mov     r11,[rsp+20h]
    mov     [rsp],r11
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFE80h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L8
L10:
    cmp     byte ptr [rsp+18h],0
    je      L8
    jmp     L9
L11:
    lea     rdi,[rsp+180h]
    call    ryo_h_Unreachable
    ud2
L12:
    mov     rdi,r14
    call    ryo_hr_CttzW16
    mov     r14,rax
    jmp     L14
L13:
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFEC8h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+50h],0
    mov     rax,[rsp+50h]
    cmp     rax,0
    sete    al
    mov     [rsp+4Fh],al
    cmp     rbx,0
    je      L3
    mov     r15,rbx
    mov     rbp,r12
    mov     [rsp+10h],r13
    jmp     L4
L14:
    mov     rdi,r14
    call    ryo_hr_ZextW32W64
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],1
    mov     rax,[rsp+50h]
    movzx   ecx,word ptr [rsp+40h]
    mov     [rsp+50h],cx
    movzx   ecx,word ptr [rsp+50h]
    sub     ecx,1
    mov     [rsp+52h],cx
    movzx   ecx,word ptr [rsp+50h]
    movzx   edx,word ptr [rsp+52h]
    and     ecx,edx
    mov     [rsp+54h],cx
    movzx   ecx,word ptr [rsp+54h]
    mov     [rsp+56h],cx
    movzx   ecx,word ptr [rsp+56h]
    mov     [rsp+40h],cx
    mov     [rsp+50h],rax
    jmp     L15
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+50h]
    add     rax,rcx
    mov     rcx,r12
    mov     r14,rbx
    jmp     L16
L15:
    mov     r13,[rsp+28h]
    jmp     L20
    jmp     L19
L16:
    mov     [rsp+48h],rax
    lea     rax,[rsp+140h]
    mov     rdx,[rsp+48h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn2
    jmp     L17
    mov     rcx,rax
    mov     qword ptr [rsp+18h],0
    mov     [rsp+20h],rcx
    jmp     L28
L17:
    mov     rcx,r14
    jmp     L2
L18:
    mov     r14,rdx
    jmp     L16
L19:
    mov     rax,r13
    mov     rcx,r12
    mov     rdx,rbx
    jmp     L18
L20:
    mov     rax,[rsp+50h]
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    mov     rcx,r12
    mov     rdx,rbx
    jmp     L18
L21:
    mov     rax,[rsp+0D0h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+0D8h]
    mov     [rsp+68h],rax
    lea     rax,[rsp+60h]
    mov     rdi,rax
    call    qword ptr [sym3]
    jmp     L22
    mov     rcx,rax
    mov     r11,[rsp+10h]
    mov     [rsp+18h],r11
    mov     [rsp+20h],rcx
    jmp     L28
L22:
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [rsp+40h],ax
    jmp     L23
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rax,10h
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     rcx,r15
    mov     rdx,rbp
    mov     rsi,[rsp+10h]
    jmp     L24
L23:
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
    jmp     L27
    jmp     L26
L24:
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+30h]
    mov     r10d,10h
    lea     rax,[rax+r10]
    mov     [rsp+30h],rax
    mov     rbx,rcx
    mov     r12,rdx
    mov     r13,rsi
    jmp     L0
L25:
    jmp     L24
L26:
    mov     rax,[rsp+50h]
    mov     rcx,r15
    mov     rdx,rbp
    mov     rsi,[rsp+10h]
    jmp     L25
L27:
    mov     rax,[rsp+50h]
    mov     r11,0FFFFFFFFFFFFFFF0h
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,r15
    mov     rdx,rbp
    mov     rsi,[rsp+10h]
    jmp     L25
L28:
    jmp     L7
  ; OSR entries
    lea     r11,[L29]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L29:
    .long   L30
    .long   L31
    .long   L32
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
    .long   L38
    .long   L39
    .long   L40
L30:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
L31:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1C0h]
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
L32:
    ret
L33:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
    mov     [rdx-170h],r11
    mov     r15,[rsp]
    mov     rbp,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L4
L34:
    ret
L35:
    ret
L36:
    ret
L37:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L16
L38:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L18
L39:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
    jmp     L24
L40:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-1D0h]
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
    jmp     L25

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
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L9
    .long   L8
    .long   L7
L2:
    mov     rcx,[rax+8]
    mov     rdx,[rax+10h]
    mov     [rsp+18h],rdx
    mov     rdx,[rsp+18h]
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
    lea     rax,[rsp+60h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L17
L6:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,0E8h
    ret
L7:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rdi,r12
    call    ryo_hr_CttzW16
    mov     r12,rax
    jmp     L11
L9:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+18h],0
    mov     rax,[rsp+18h]
    cmp     rax,0
    sete    al
    mov     [rsp+17h],al
    jmp     L10
L10:
    mov     r13,rbx
    jmp     L5
    mov     rax,rbx
    jmp     L2
L11:
    mov     rdi,r12
    call    ryo_hr_ZextW32W64
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    mov     rax,[rsp+18h]
    movzx   ecx,word ptr [rbx+18h]
    mov     [rsp+18h],cx
    movzx   ecx,word ptr [rsp+18h]
    sub     ecx,1
    mov     [rsp+1Ah],cx
    movzx   ecx,word ptr [rsp+18h]
    movzx   edx,word ptr [rsp+1Ah]
    and     ecx,edx
    mov     [rsp+1Ch],cx
    movzx   ecx,word ptr [rsp+1Ch]
    mov     [rsp+1Eh],cx
    movzx   ecx,word ptr [rsp+1Eh]
    mov     [rbx+18h],cx
    mov     [rsp+18h],rax
    jmp     L12
    mov     rax,[rbx]
    mov     rcx,[rsp+18h]
    add     rax,rcx
    mov     rcx,rax
    jmp     L13
L12:
    mov     rax,[rbx]
    jmp     L16
    jmp     L15
L13:
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+10h]
    mov     rax,rcx
    jmp     L6
L14:
    jmp     L13
L15:
    mov     rcx,rax
    jmp     L14
L16:
    mov     rcx,[rsp+18h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L14
L17:
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [sym2]
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     rdi,rax
    call    ryo_hr_NotW16
    mov     [r13+18h],ax
    jmp     L18
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    add     rax,10h
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     rcx,r13
    jmp     L19
L18:
    mov     rax,[r13]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    jmp     L22
    jmp     L21
L19:
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     [rcx],rax
    mov     rax,[rcx+8]
    mov     r10d,10h
    lea     rax,[rax+r10]
    mov     [rcx+8],rax
    mov     rbx,rcx
    jmp     L0
L20:
    jmp     L19
L21:
    mov     rax,[rsp+18h]
    mov     rcx,r13
    jmp     L20
L22:
    mov     rax,[rsp+18h]
    mov     r11,0FFFFFFFFFFFFFFF0h
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,r13
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
    .long   L30
    .long   L31
L24:
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
L25:
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
L26:
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
L27:
    ret
L28:
    ret
L29:
    ret
L30:
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
    jmp     L19
L31:
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
    jmp     L20

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     r13,[rsp+20h]
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    fn1
    mov     r12,rdx
    jmp     L0
    mov     r13,rax
    jmp     L13
L0:
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
    .long   L3
    .long   L4
    .long   L2
L2:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     eax,0
    jmp     L5
L4:
    mov     rbx,[rbx]
    jmp     L8
    jmp     L7
L5:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,68h
    ret
L6:
    mov     [rsp],r13
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L7:
    mov     rax,r12
    add     rax,1
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     [rsp+20h],rbx
    jmp     L12
    jmp     L11
L9:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    jmp     L5
L10:
    jmp     L9
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L10
L12:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L10
L13:
    jmp     L6
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     rax,[rdi+8]
    mov     rax,[rax]
    jmp     L2
    jmp     L1
L0:
    mov     rax,r12
    movzx   eax,al
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rcx,rsi
    add     rcx,1
    mov     r13,rcx
    jmp     L3
L2:
    jmp     L6
    jmp     L5
L3:
    jmp     L9
    jmp     L8
L4:
    mov     r13,rcx
    jmp     L3
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     ecx,0
    sub     rcx,rsi
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L4
L7:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r12,rax
    jmp     L0
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,r13
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,20h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L10
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF60h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     [rsp+48h],rbx
    mov     rax,[rsp+48h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn0
    mov     r13,rax
    jmp     L0
    mov     r14,rax
    jmp     L17
L0:
    jmp     L4
L1:
    mov     [rsp],r14
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
L2:
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L3
    jmp     L18
L3:
    jmp     L1
L4:
    mov     rax,[rbx]
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    lea     rax,[rax+r13]
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    movzx   r15d,byte ptr [rax]
    shr     r12,39h
    mov     [rsp+40h],r12
    mov     rax,[rsp+40h]
    and     rax,7Fh
    mov     [rsp+38h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFAEh
    mov     edx,0FFFFFF98h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+4Eh]
    mov     [rsp+4Fh],al
    mov     rax,r13
    sub     rax,10h
    mov     [rsp+30h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rsp+30h]
    and     rcx,rax
    mov     [rsp+38h],rcx
    mov     rax,[rsp+38h]
    add     rax,10h
    mov     [rsp+40h],rax
    mov     rax,[rbx]
    lea     rax,[rax+r13]
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [rax],cl
    mov     rax,[rbx]
    mov     rcx,[rsp+40h]
    lea     rax,[rax+rcx]
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    movzx   ecx,byte ptr [rsp+4Fh]
    mov     [rax],cl
    mov     rax,[rbx]
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+48h],rax
    jmp     L5
    mov     rax,r13
    add     rax,1
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L6
L5:
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    jmp     L9
    jmp     L8
L6:
    mov     r12,[rsp+38h]
    mov     rax,r15
    and     eax,1
    mov     [rsp+46h],al
    movzx   eax,byte ptr [rsp+46h]
    cmp     al,0
    setne   al
    mov     [rsp+47h],al
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFA7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbx+10h]
    mov     rcx,[rsp+48h]
    sub     rax,rcx
    mov     [rbx+10h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF68h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L12
    jmp     L11
L7:
    jmp     L6
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L7
L9:
    mov     eax,0
    sub     rax,r13
    mov     rcx,[rsp+30h]
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+38h],rcx
    jmp     L7
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF90h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,r12
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    add     rsp,0A8h
    ret
L11:
    mov     eax,8
    jmp     L10
L12:
    jmp     L15
    jmp     L14
L13:
    jmp     L10
L14:
    mov     rax,r12
    jmp     L13
L15:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,20h
    add     r11,r12
    mov     rax,r11
    jmp     L13
L16:
    call    qword ptr [sym2]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L17:
    jmp     L2
L18:
    jmp     L16
  ; OSR entries
    lea     r11,[L19]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L19:
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
    .long   L25
    .long   L26
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
L26:
    ret

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     rax,[rbx+10h]
    cmp     rax,r12
    jae     L7
    jmp     L5
L0:
    mov     rdi,r14
    mov     rsi,0FFFFFFFFFFFFFFFFh
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
L1:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L2:
    mov     [rsp],r15
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
L4:
    jmp     L2
    jmp     L3
L5:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    mov     r14,rax
    jmp     L6
    mov     r15,rax
    jmp     L8
L6:
    jmp     L0
L7:
    jmp     L1
L8:
    jmp     L4
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<std::string::String, usize, std::hash::RandomState>::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     rax,[rsi]
    jmp     L2
    jmp     L1
L0:
    mov     rax,r12
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rcx,rdx
    add     rcx,1
    mov     r13,rcx
    jmp     L3
L2:
    jmp     L6
    jmp     L5
L3:
    jmp     L9
    jmp     L8
L4:
    mov     r13,rcx
    jmp     L3
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L4
L7:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r12,rax
    jmp     L0
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,r13
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,20h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L10
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

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    sub     rsp,28h
    mov     [rsp+10h],rsi
    lea     rax,[rsp+10h]
    mov     rsi,rax
    call    fn0
    jmp     L2
    jmp     L1
L0:
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L6
L1:
    mov     eax,8
    jmp     L0
L2:
    mov     rax,[rsp+10h]
    jmp     L5
    jmp     L4
L3:
    mov     rax,rcx
    jmp     L0
L4:
    mov     rcx,rax
    jmp     L3
L5:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L3
L6:
    add     rsp,28h
    ret
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
    .long   L9
L8:
    ret
L9:
    ret

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx]
    jmp     L3
    jmp     L2
L0:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    jmp     L0
L2:
    mov     rax,[r12]
    sub     rax,1
    jmp     L1
L3:
    mov     rax,[r12]
    mov     r11d,0
    cmp     r11,10h
    jae     L6
    jmp     L5
L4:
    mov     rax,r12
    jmp     L1
L5:
    mov     r11d,10h
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L6
    sub     r13,rax
    mov     rdi,r13
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     r12,rax
    jmp     L4
L6:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rbx,rax
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     r13,[rsp+20h]
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    fn1
    mov     r12,rdx
    jmp     L0
    mov     r13,rax
    jmp     L13
L0:
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
    .long   L3
    .long   L4
    .long   L2
L2:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     eax,0
    jmp     L5
L4:
    mov     rbx,[rbx]
    jmp     L8
    jmp     L7
L5:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,68h
    ret
L6:
    mov     [rsp],r13
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L7:
    mov     rax,r12
    add     rax,1
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     [rsp+20h],rbx
    jmp     L12
    jmp     L11
L9:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    jmp     L5
L10:
    jmp     L9
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L10
L12:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L10
L13:
    jmp     L6
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::map::equivalent_key<u64, u64, u64>::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     rax,[rdi+8]
    mov     rax,[rax]
    jmp     L2
    jmp     L1
L0:
    mov     rax,r12
    movzx   eax,al
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rcx,rsi
    add     rcx,1
    mov     r13,rcx
    jmp     L3
L2:
    jmp     L6
    jmp     L5
L3:
    jmp     L9
    jmp     L8
L4:
    mov     r13,rcx
    jmp     L3
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     ecx,0
    sub     rcx,rsi
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L4
L7:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r12,rax
    jmp     L0
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,r13
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L10
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rbx
    lea     r13,[rsp+20h]
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    fn1
    mov     r12,rdx
    jmp     L0
    mov     r13,rax
    jmp     L13
L0:
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
    .long   L3
    .long   L4
    .long   L2
L2:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     eax,0
    jmp     L5
L4:
    mov     rbx,[rbx]
    jmp     L8
    jmp     L7
L5:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,68h
    ret
L6:
    mov     [rsp],r13
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L7:
    mov     rax,r12
    add     rax,1
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L9
L8:
    mov     [rsp+20h],rbx
    jmp     L12
    jmp     L11
L9:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    jmp     L5
L10:
    jmp     L9
L11:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L10
L12:
    mov     eax,0
    sub     rax,r12
    mov     rcx,[rsp+20h]
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+28h],rcx
    jmp     L10
L13:
    jmp     L6
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

fn hashbrown::raw::RawTable::<(u64, u64)>::find::<{closure@hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     rax,[rdi+8]
    mov     rax,[rax]
    jmp     L2
    jmp     L1
L0:
    mov     rax,r12
    movzx   eax,al
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rcx,rsi
    add     rcx,1
    mov     r13,rcx
    jmp     L3
L2:
    jmp     L6
    jmp     L5
L3:
    jmp     L9
    jmp     L8
L4:
    mov     r13,rcx
    jmp     L3
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     ecx,0
    sub     rcx,rsi
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L4
L7:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r12,rax
    jmp     L0
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,r13
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L10
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

fn hashbrown::raw::RawTable::<(u64, u64)>::insert_no_grow
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rcx
    mov     [rsp+28h],rbx
    mov     rax,[rsp+28h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn0
    mov     r13,rax
    jmp     L0
    mov     r14,rax
    jmp     L15
L0:
    jmp     L3
L1:
    mov     [rsp],r14
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L1
L3:
    mov     rax,[rbx]
    lea     rax,[rax+r13]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    movzx   r15d,byte ptr [rax]
    shr     r12,39h
    mov     [rsp+20h],r12
    mov     rax,[rsp+20h]
    and     rax,7Fh
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF9Eh
    mov     edx,0FFFFFF70h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+2Eh]
    mov     [rsp+2Fh],al
    mov     rax,r13
    sub     rax,10h
    mov     rcx,[rbx+8]
    and     rax,rcx
    add     rax,10h
    mov     [rsp+20h],rax
    mov     rax,[rbx]
    lea     rax,[rax+r13]
    movzx   ecx,byte ptr [rsp+2Fh]
    mov     [rax],cl
    mov     rax,[rbx]
    mov     rcx,[rsp+20h]
    lea     rax,[rax+rcx]
    movzx   ecx,byte ptr [rsp+2Fh]
    mov     [rax],cl
    mov     rax,[rbx]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    jmp     L4
    mov     rax,r13
    add     rax,1
    mov     rbp,rax
    jmp     L5
L4:
    mov     r12,[rsp+20h]
    jmp     L8
    jmp     L7
L5:
    mov     rax,r15
    and     eax,1
    mov     [rsp+26h],al
    movzx   eax,byte ptr [rsp+26h]
    cmp     al,0
    setne   al
    mov     [rsp+27h],al
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF97h
    call    ryo_h_ZextW8W64
    mov     rax,[rbx+10h]
    mov     rcx,[rsp+28h]
    sub     rax,rcx
    mov     [rbx+10h],rax
    mov     rax,[rsp+8]
    mov     [rsp+20h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+28h],rax
    jmp     L11
    jmp     L10
L6:
    mov     rbp,rax
    jmp     L5
L7:
    mov     rax,r12
    jmp     L6
L8:
    mov     eax,0
    sub     rax,r13
    mov     r11,rax
    imul    r11,10h
    add     r11,r12
    mov     r12,r11
    mov     rax,r12
    jmp     L6
L9:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF90h
    call    ryo_h_StoreW128
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,rbp
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L10:
    mov     eax,8
    jmp     L9
L11:
    jmp     L14
    jmp     L13
L12:
    jmp     L9
L13:
    mov     rax,rbp
    jmp     L12
L14:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,rbp
    mov     rax,r11
    jmp     L12
L15:
    jmp     L2
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
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     rax,[rbx+10h]
    cmp     rax,r12
    jae     L7
    jmp     L5
L0:
    mov     rdi,r14
    mov     rsi,0FFFFFFFFFFFFFFFFh
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
L1:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L2:
    mov     [rsp],r15
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
L4:
    jmp     L2
    jmp     L3
L5:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     ecx,1
    movzx   ecx,cl
    call    qword ptr [fn0.slot]
    mov     r14,rax
    jmp     L6
    mov     r15,rax
    jmp     L8
L6:
    jmp     L0
L7:
    jmp     L1
L8:
    jmp     L4
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

fn hashbrown::raw::RawTable::<(u64, u64)>::reserve_rehash::<{closure@hashbrown::map::make_hasher<u64, u64, std::hash::RandomState>::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     rax,[rsi]
    jmp     L2
    jmp     L1
L0:
    mov     rax,r12
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L1:
    mov     rcx,rdx
    add     rcx,1
    mov     r13,rcx
    jmp     L3
L2:
    jmp     L6
    jmp     L5
L3:
    jmp     L9
    jmp     L8
L4:
    mov     r13,rcx
    jmp     L3
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     ecx,0
    sub     rcx,rdx
    mov     r11,rcx
    imul    r11,10h
    add     r11,rax
    mov     rax,r11
    mov     rcx,rax
    jmp     L4
L7:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    mov     r12,rax
    jmp     L0
L8:
    mov     eax,8
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    jmp     L7
L11:
    mov     rax,r13
    jmp     L10
L12:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L10
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

fn hashbrown::raw::RawTableInner::drop_elements::<(std::string::String, usize)>
    sub     rsp,0F8h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     rbx,rdi
    jmp     L0
L0:
    mov     rax,[rbx+18h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+98h]
    cmp     rax,0
    je      L4
    mov     r12,[rbx]
    mov     [rsp+90h],r12
    jmp     L7
    jmp     L6
L1:
    mov     rax,[rsp+98h]
    cmp     rax,0
    je      L8
    jmp     L9
L2:
    lea     rdi,[rsp+0F0h]
    call    ryo_h_Unreachable
    ud2
L3:
    jmp     L13
    jmp     L12
L4:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    add     rsp,0F8h
    ret
L5:
    mov     r14,[rbx+18h]
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+30h],r14
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF20h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L1
L6:
    mov     r12d,1
    jmp     L7
L7:
    mov     [rsp+88h],r12
    mov     rax,[rsp+88h]
    mov     [rsp+98h],rax
    mov     rax,[rbx]
    mov     rcx,[rbx+8]
    add     rcx,1
    lea     rdx,[rsp+78h]
    mov     rsi,[rsp+98h]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    jmp     L5
L8:
    jmp     L4
L9:
    lea     rax,[rsp+78h]
    mov     rdi,rax
    call    fn1
    mov     r13,rax
    mov     rax,[rsp+98h]
    sub     rax,1
    mov     [rsp+98h],rax
    mov     rdi,r13
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L10]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L10:
    .long   L4
    .long   L3
    .long   L2
L11:
    mov     rdi,rax
    call    fn2
    jmp     L17
L12:
    mov     eax,8
    jmp     L11
L13:
    jmp     L16
    jmp     L15
L14:
    jmp     L11
L15:
    mov     rax,r13
    jmp     L14
L16:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,20h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L14
L17:
    jmp     L1
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
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     r11,[rsp]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    lea     rsp,[rsp+30h]
    jmp     L1
L20:
    ret
L21:
    ret
L22:
    ret
L23:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     r11,[rsp+8]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C0h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L11
L24:
    pop     rcx
    lea     rdx,[rsp+0B0h]
    lea     rsp,[rdx-120h]
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
    mov     [rdx-0A0h],r13
    mov     [rdx-0B0h],r14
    mov     r11,[rsp+8]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C0h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L14

fn hashbrown::raw::RawTableInner::erase
    sub     rsp,0B8h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,r12
    sub     rax,10h
    mov     [rsp+38h],rax
    mov     rax,[rbx+8]
    mov     [rsp+30h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+30h]
    and     rax,rcx
    mov     rcx,[rbx]
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    lea     rcx,[rcx+rax]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rcx
    lea     rax,[rsp+10h]
    mov     rcx,[rsp+30h]
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
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     [rbx+10h],rax
    mov     eax,0FFh
L2:
    mov     rcx,r12
    sub     rcx,10h
    mov     [rsp+48h],rcx
    mov     rcx,[rbx+8]
    mov     [rsp+40h],rcx
    mov     rcx,[rsp+48h]
    mov     rdx,[rsp+40h]
    and     rcx,rdx
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    add     rcx,10h
    mov     [rsp+38h],rcx
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    mov     rcx,[rsp+40h]
    lea     rcx,[rcx+r12]
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rcx],al
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    mov     rcx,[rsp+40h]
    mov     rdx,[rsp+38h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rcx],al
    mov     rax,[rbx+18h]
    sub     rax,1
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     [rbx+18h],rax
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    add     rsp,0B8h
    ret
L3:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+10h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+68h],rax
    lea     rax,[rsp+30h]
    lea     rcx,[rsp+50h]
    lea     rdx,[rsp+60h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym2]
    mov     rax,[rsp+30h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [sym3]
    mov     [rsp+4Ch],eax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_TruncW32W16
    movzx   r13d,word ptr [rsp]
    mov     rax,[rbx]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+30h]
    lea     rax,[rax+r12]
    mov     [rsp+38h],rax
    mov     [rsp+30h],rax
    lea     rax,[rsp+20h]
    mov     rcx,[rsp+30h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    lea     rax,[rsp+40h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+20h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+68h],rax
    lea     rax,[rsp+30h]
    lea     rcx,[rsp+50h]
    lea     rdx,[rsp+60h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym2]
    mov     rax,[rsp+30h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [sym3]
    mov     [rsp+4Ch],eax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_TruncW32W16
    movzx   r14d,word ptr [rsp]
    mov     rdi,r13
    call    ryo_hr_CtlzW16
    mov     [rsp+4Ch],eax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF9Ch
    call    ryo_h_ZextW32W64
    mov     rdi,r14
    call    ryo_hr_CttzW16
    mov     [rsp+44h],eax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF94h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+48h]
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    cmp     rax,10h
    jae     L0
    jmp     L1
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
    sub     rsp,1A8h
    mov     [rsp+120h],rbx
    mov     [rsp+110h],r12
    mov     [rsp+100h],r13
    mov     [rsp+0F0h],r14
    mov     [rsp+0E0h],r15
    mov     [rsp+0D0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     rax,r12
    shr     rax,39h
    and     rax,7Fh
    mov     rdi,rax
    call    ryo_hr_TruncW64W8
    mov     [rsp+90h],r12
    mov     rcx,[rbx+8]
    mov     [rsp+0A8h],rcx
    mov     rcx,[rsp+90h]
    mov     rdx,[rsp+0A8h]
    and     rcx,rdx
    mov     [rsp+98h],rcx
    mov     rcx,[rsp+98h]
    mov     r12,rbx
    mov     rbx,rcx
    mov     r15,r13
    mov     r13,rax
    mov     ebp,0
L0:
    mov     [rsp+90h],rbx
    mov     rax,[r12]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    mov     rcx,[rsp+90h]
    lea     rax,[rax+rcx]
    mov     [rsp+98h],rax
    mov     [rsp+90h],rax
    lea     rax,[rsp+130h]
    mov     rcx,[rsp+90h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L6
L1:
    mov     rdi,[rsp+10h]
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
L2:
    .long   L8
    .long   L7
    .long   L3
L3:
    lea     rdi,[rsp+1A0h]
    call    ryo_h_Unreachable
    ud2
L4:
    test    al,al
    je      L12
    jmp     L11
L5:
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     rdx,rcx
    mov     rbx,[rsp+120h]
    mov     r12,[rsp+110h]
    mov     r13,[rsp+100h]
    mov     r14,[rsp+0F0h]
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+0D0h]
    add     rsp,1A8h
    ret
L6:
    lea     rax,[rsp+0A0h]
    mov     rdi,rax
    mov     rsi,r13
    movzx   esi,sil
    call    qword ptr [sym1]
    mov     rax,[rsp+130h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+0C8h],rax
    lea     rax,[rsp+90h]
    lea     rcx,[rsp+0B0h]
    lea     rdx,[rsp+0C0h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym2]
    mov     rax,[rsp+90h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+98h]
    mov     [rsp+0B8h],rax
    lea     rax,[rsp+0B0h]
    mov     rdi,rax
    call    qword ptr [sym3]
    mov     [rsp+0ACh],eax
    lea     rdi,[rsp+1A0h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFF0Ch
    call    ryo_h_TruncW32W16
    movzx   eax,word ptr [rsp]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+28h],r14
    mov     [rsp+30h],r15
    mov     [rsp+38h],rbp
    mov     [rsp+40h],r13
    jmp     L1
L7:
    mov     rdi,[rsp+10h]
    call    ryo_hr_CttzW16
    mov     rbx,rax
    jmp     L9
L8:
    lea     rdi,[rsp+1A0h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+0A8h],0
    mov     rax,[rsp+0A8h]
    lea     rax,[rsp+0A0h]
    mov     rdi,rax
    mov     esi,0FFh
    movzx   esi,sil
    call    qword ptr [sym1]
    jmp     L10
L9:
    mov     rdi,rbx
    call    ryo_hr_ZextW32W64
    mov     [rsp+0A8h],rax
    mov     qword ptr [rsp+0A0h],1
    mov     rax,[rsp+0A8h]
    mov     r10,[rsp+10h]
    mov     [rsp+0AEh],r10w
    movzx   ecx,word ptr [rsp+0AEh]
    sub     ecx,1
    movzx   edx,word ptr [rsp+0AEh]
    mov     rbx,rdx
    and     ebx,ecx
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+90h],1
    mov     rax,[rsp+98h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    add     rax,[rsp+18h]
    mov     r11,[rsp+20h]
    mov     rcx,[r11+8]
    and     rax,rcx
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0A0h]
    mov     r11,[rsp+28h]
    mov     rcx,[r11+20h]
    mov     rdi,[rsp+30h]
    mov     rsi,rax
    mov     rax,rcx
    call    rax
    mov     [rsp+48h],rbx
    mov     r11,[rsp+18h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+78h],r11
    jmp     L4
L10:
    mov     rax,[rsp+130h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+0C8h],rax
    lea     rax,[rsp+90h]
    lea     rcx,[rsp+0B0h]
    lea     rdx,[rsp+0C0h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym2]
    mov     rax,[rsp+90h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+98h]
    mov     [rsp+0B8h],rax
    lea     rax,[rsp+0B0h]
    mov     rdi,rax
    call    qword ptr [sym3]
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    cmp     ax,0
    je      L14
    jmp     L13
L11:
    mov     rax,[rsp+0A0h]
    mov     [rsp+88h],rax
    mov     qword ptr [rsp+80h],1
    jmp     L5
L12:
    mov     r11,[rsp+48h]
    mov     [rsp+10h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+18h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+40h],r11
    jmp     L1
L13:
    lea     rdi,[rsp+1A0h]
    mov     esi,0FFFFFEE0h
    lea     rdx,[k8]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L14:
    mov     r11,[rsp+20h]
    mov     rax,[r11+8]
    mov     [rsp+98h],rax
    mov     rax,[rsp+38h]
    add     rax,10h
    mov     [rsp+90h],rax
    mov     rcx,[rsp+90h]
    add     rcx,[rsp+18h]
    mov     rdx,[rsp+98h]
    and     rcx,rdx
    mov     rbx,rcx
    mov     r12,[rsp+20h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     rbp,rax
    jmp     L0
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
    lea     rsp,[rdx-210h]
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
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+70h]
    jmp     L0
L17:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-220h]
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
    mov     [rdx-190h],r11
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-160h],r11
    lea     rsp,[rsp+80h]
    jmp     L1
L18:
    pop     rcx
    lea     rdx,[rsp+100h]
    lea     rsp,[rdx-220h]
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
    mov     r11,[rsp+8]
    mov     [rdx-158h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-128h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+80h]
    jmp     L4
L19:
    ret

fn hashbrown::raw::RawTableInner::find_insert_index
    sub     rsp,0D8h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+70h],rsi
    mov     rax,[rdi+8]
    mov     rcx,[rsp+70h]
    and     rcx,rax
    mov     [rsp+78h],rcx
    mov     rax,[rsp+78h]
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+88h],0
    mov     rbx,rdi
L0:
    mov     rax,[rsp+80h]
    mov     rcx,[rbx]
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+10h]
    mov     [rsp+18h],rcx
    mov     rcx,[rsp+18h]
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L3
L1:
    cmp     r12,1
    je      L4
    jmp     L5
L2:
    mov     rax,r15
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    add     rsp,0D8h
    ret
L3:
    mov     rax,[rsp+10h]
    mov     [rsp+70h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+78h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+18h],rax
    lea     rax,[rsp+80h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [fn1.slot]
    mov     r12,rax
    mov     r13,rdx
    mov     r14,rbx
    jmp     L1
L4:
    mov     [rsp+18h],r13
    mov     rax,[rsp+18h]
    mov     rdi,r14
    mov     rsi,rax
    call    qword ptr [fn2.slot]
    mov     r15,rax
    jmp     L2
L5:
    mov     rax,[r14+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+88h]
    add     rax,10h
    mov     [rsp+88h],rax
    mov     rax,[rsp+88h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+10h]
    add     rax,rcx
    mov     [rsp+80h],rax
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+18h]
    and     rax,rcx
    mov     [rsp+80h],rax
    mov     rbx,r14
    jmp     L0
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
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-80h]
    mov     [rsp+8],r11
    mov     r11,[rdx-78h]
    mov     [rsp+10h],r11
    mov     [rdx-70h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-90h],r13
    mov     [rdx-0A0h],r14
    mov     [rdx-0B0h],r15
    mov     r11,[rsp+8]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0B8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L0
L8:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-70h]
    mov     [rsp],r11
    mov     r11,[rdx-68h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-80h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+20h],r11
    mov     [rdx-70h],rbx
    mov     [rdx-80h],r12
    mov     [rdx-90h],r13
    mov     [rdx-0A0h],r14
    mov     [rdx-0B0h],r15
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     r12,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L1
L9:
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
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     r13,rax
    mov     [rsp],r13
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFCCh
    mov     edx,0FFFFFF70h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW16
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFCCh
    call    ryo_h_ZextW32W64
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
    .long   L6
L3:
    mov     [rsp],r13
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFCCh
    mov     edx,0FFFFFF70h
    call    ryo_h_CttzW16
    mov     r13d,[rsp+5Ch]
    jmp     L5
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    jmp     L7
L5:
    mov     [rsp],r13
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF70h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+28h],1
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    mov     rax,[r12]
    mov     rcx,[rsp+30h]
    add     rax,rcx
    mov     [rsp+40h],rax
    mov     rax,[rbx+8]
    mov     rcx,[rsp+40h]
    and     rcx,rax
    mov     [rsp+48h],rcx
    mov     rax,[rsp+48h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    jmp     L0
L6:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L0
  ; OSR entries
    lea     r11,[L8]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L8:
    .long   L9
L9:
    ret

fn hashbrown::raw::RawTableInner::fix_insert_index
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     rbx,rsi
    mov     [rsp+28h],rbx
    mov     rax,[rdi]
    mov     rcx,[rsp+28h]
    lea     rax,[rax+rcx]
    mov     [rsp+20h],rax
    mov     rax,[rsp+20h]
    movzx   eax,byte ptr [rax]
    and     eax,80h
    cmp     al,0
    jne     L2
    jmp     L1
L0:
    mov     rbx,[rsp+40h]
    add     rsp,58h
    ret
L1:
    mov     rax,[rdi]
    lea     rcx,[rsp+10h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [sym0]
    jmp     L3
L2:
    mov     rax,rbx
    jmp     L0
L3:
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [sym1]
    mov     rdi,rax
    call    ryo_hr_TruncW32W16
    mov     rbx,rax
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW16
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L4]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L4:
    .long   L7
    .long   L6
    .long   L9
L5:
    mov     rax,[rsp+20h]
    mov     rax,[rsp+28h]
    jmp     L0
L6:
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    mov     rbx,rax
    jmp     L8
L7:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L8:
    mov     rdi,rbx
    call    ryo_hr_ZextW32W64
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    jmp     L5
L9:
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
    .long   L12
L11:
    ret
L12:
    ret

fn hashbrown::raw::RawTableInner::resize_inner::<std::alloc::Global>
    sub     rsp,378h
    mov     [rsp+110h],rbx
    mov     [rsp+100h],r12
    mov     [rsp+0F0h],r13
    mov     [rsp+0E0h],r14
    mov     [rsp+0D0h],r15
    mov     [rsp+0C0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rax,[rsp+388h]
    mov     rcx,[rsp+380h]
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rax
    lea     rax,[rsp+190h]
    mov     rcx,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdi,rax
    mov     r8,rdx
    mov     rdx,rcx
    mov     rcx,rsi
    mov     rsi,r12
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    jmp     L10
L0:
    lea     rdi,[rsp+370h]
    call    ryo_h_Unreachable
    ud2
L1:
    lea     rax,[rsp+220h]
    mov     [rsp+208h],rax
    mov     rax,[rsp+208h]
    mov     rax,[rax+10h]
    mov     [rsp+200h],rax
    mov     rax,[rsp+200h]
    cmp     rax,0
    je      L16
    jmp     L17
L2:
    mov     rax,[rsp+218h]
    mov     [rsp+200h],rax
    mov     [rsp+1E8h],r15
    mov     rax,[rsp+200h]
    mov     [rsp+1F0h],rax
    mov     r11,[rsp+18h]
    mov     rax,[r11+28h]
    mov     rcx,[rsp+1E8h]
    mov     rdx,[rsp+1F0h]
    mov     rdi,[rsp+10h]
    mov     rsi,rcx
    call    rax
    mov     [rsp+1F8h],rax
    jmp     L3
    mov     [rsp+20h],rax
    jmp     L23
L3:
    jmp     L5
L4:
    mov     rax,[r15+18h]
    mov     [rsp+238h],rax
    mov     rax,[rsp+268h]
    mov     rcx,[rsp+238h]
    sub     rax,rcx
    mov     [rsp+268h],rax
    mov     rax,[r15+18h]
    mov     [rsp+238h],rax
    mov     rax,[rsp+238h]
    mov     [rsp+270h],rax
    mov     [rsp+238h],r15
    lea     rax,[rsp+258h]
    mov     [rsp+230h],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFDB0h
    mov     edx,0FFFFFEC8h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     qword ptr [rsp],20h
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFC90h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEC0h
    mov     edx,0
    mov     ecx,0FFFFFDB0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    jmp     L21
L5:
    lea     rax,[rsp+258h]
    mov     [rsp+1F0h],rax
    mov     rax,[rsp+1F0h]
    mov     rcx,[rsp+1F8h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    mov     rbp,rax
    jmp     L6
    mov     [rsp+20h],rax
    jmp     L23
L6:
    jmp     L20
L7:
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     rdx,rcx
    mov     rbx,[rsp+110h]
    mov     r12,[rsp+100h]
    mov     r13,[rsp+0F0h]
    mov     r14,[rsp+0E0h]
    mov     r15,[rsp+0D0h]
    mov     rbp,[rsp+0C0h]
    add     rsp,378h
    ret
L8:
    lea     rax,[rsp+240h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L9
    jmp     L24
L9:
    mov     r11,[rsp+20h]
    mov     [rsp],r11
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFC90h
    call    ryo_h_Resume
    ud2
L10:
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFC90h
    mov     edx,0FFFFFE20h
    mov     ecx,0
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     [rsp],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFD48h
    mov     edx,0FFFFFC90h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFD48h
    mov     edx,0
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L11]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L11:
    .long   L13
    .long   L12
    .long   L0
L12:
    mov     rax,[rsp+198h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+1A0h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+98h]
    mov     [rsp+1B8h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+1C0h],rax
    mov     qword ptr [rsp+1B0h],0
    mov     rax,[rsp+1B8h]
    mov     [rsp+1A0h],rax
    mov     rax,[rsp+1C0h]
    mov     [rsp+1A8h],rax
    mov     qword ptr [rsp+198h],1
    mov     rax,[rsp+198h]
    cmp     rax,1
    sete    al
    mov     [rsp+197h],al
    mov     rax,[rsp+1A0h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+1A8h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+1E0h],rax
    mov     qword ptr [rsp+1D0h],0
    mov     rax,[rsp+1D8h]
    mov     [rsp+1C0h],rax
    mov     rax,[rsp+1E0h]
    mov     [rsp+1C8h],rax
    mov     rax,[rsp+1C0h]
    mov     [rsp+1B0h],rax
    mov     rax,[rsp+1C8h]
    mov     [rsp+1B8h],rax
    mov     rax,[rsp+1B0h]
    mov     [rsp+210h],rax
    mov     rax,[rsp+1B8h]
    mov     [rsp+218h],rax
    mov     qword ptr [rsp+208h],0
    mov     rax,[rsp+210h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+218h]
    mov     [rsp+200h],rax
    mov     qword ptr [rsp+1F0h],1
    mov     rax,[rsp+1F0h]
    cmp     rax,1
    sete    al
    mov     [rsp+1DFh],al
    mov     rax,[rsp+1F8h]
    mov     [rsp+1E0h],rax
    mov     rax,[rsp+200h]
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+1E0h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+1E8h]
    mov     [rsp+38h],rax
    jmp     L7
L13:
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFD28h
    mov     edx,0FFFFFE20h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD28h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFD00h
    mov     edx,0FFFFFE40h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+0A8h],r12
    mov     rax,[rsp+40h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+0B8h],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFD38h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD00h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rax,[rbx]
    mov     [rsp+218h],rax
    mov     rax,[rsp+218h]
    mov     [rsp+220h],rax
    mov     rax,[rsp+218h]
    mov     [rsp+238h],rax
    mov     rax,[rsp+218h]
    mov     [rsp+228h],rax
    mov     rax,[rsp+218h]
    mov     [rsp+210h],rax
    lea     rax,[rsp+200h]
    mov     rcx,[rsp+210h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym3]
    jmp     L14
    mov     [rsp+20h],rax
    jmp     L23
L14:
    mov     rax,[rsp+200h]
    mov     [rsp+130h],rax
    mov     rax,[rsp+208h]
    mov     [rsp+138h],rax
    lea     rax,[rsp+130h]
    mov     rdi,rax
    call    qword ptr [sym4]
    mov     [rsp+22Ch],eax
    jmp     L15
    mov     [rsp+20h],rax
    jmp     L23
L15:
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEC0h
    mov     edx,0FFFFFEBCh
    call    ryo_h_TruncW32W16
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   eax,word ptr [rsp+232h]
    mov     [rsp+234h],ax
    movzx   eax,word ptr [rsp+234h]
    mov     [rsp+236h],ax
    mov     rax,[rbx+18h]
    mov     [rsp+228h],rax
    movzx   eax,word ptr [rsp+236h]
    mov     [rsp+68h],ax
    mov     qword ptr [rsp+58h],0
    mov     rax,[rsp+218h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+228h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFCE0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     r15,rbx
    mov     [rsp+18h],r14
    mov     [rsp+10h],r13
    jmp     L1
L16:
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L4
L17:
    mov     rax,[rsp+208h]
    mov     rdi,rax
    call    fn6
    mov     [rsp+210h],rax
    mov     [rsp+218h],rdx
    jmp     L18
    mov     [rsp+20h],rax
    jmp     L23
L18:
    mov     rax,[rsp+208h]
    mov     rax,[rax+10h]
    sub     rax,1
    mov     [rsp+130h],rax
    mov     rax,[rsp+208h]
    mov     rcx,[rsp+130h]
    mov     [rax+10h],rcx
    mov     rax,[rsp+210h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L19]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L19:
    .long   L4
    .long   L2
    .long   L0
L20:
    mov     rax,[rsp+258h]
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+1D8h]
    mov     [rsp+1E0h],rax
    mov     rax,[rsp+1E0h]
    lea     rax,[rax+rbp]
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+1E8h]
    mov     [rsp+1F0h],rax
    mov     rax,[rsp+1F0h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+1C7h],al
    mov     rax,[rsp+1F8h]
    shr     rax,39h
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+1E8h]
    and     rax,7Fh
    mov     [rsp+1E0h],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE86h
    mov     edx,0FFFFFE70h
    call    ryo_h_TruncW64W8
    movzx   eax,byte ptr [rsp+1F6h]
    mov     [rsp+1F7h],al
    mov     rax,rbp
    sub     rax,10h
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+260h]
    mov     [rsp+1D0h],rax
    mov     rax,[rsp+1D8h]
    mov     rcx,[rsp+1D0h]
    and     rax,rcx
    mov     [rsp+1E0h],rax
    mov     rax,[rsp+1E0h]
    add     rax,10h
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+258h]
    mov     [rsp+1C8h],rax
    mov     rax,[rsp+1C8h]
    mov     [rsp+1D0h],rax
    mov     rax,[rsp+1D0h]
    lea     rax,[rax+rbp]
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+1D8h]
    mov     [rsp+1E0h],rax
    mov     rax,[rsp+1E0h]
    movzx   ecx,byte ptr [rsp+1F7h]
    mov     [rax],cl
    mov     rax,[rsp+258h]
    mov     [rsp+1C8h],rax
    mov     rax,[rsp+1C8h]
    mov     [rsp+1D0h],rax
    mov     rax,[rsp+1D0h]
    mov     rcx,[rsp+1E8h]
    lea     rax,[rax+rcx]
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+1D8h]
    mov     [rsp+1E0h],rax
    mov     rax,[rsp+1E0h]
    movzx   ecx,byte ptr [rsp+1F7h]
    mov     [rax],cl
    mov     rax,[rsp+40h]
    mov     rcx,[r15]
    mov     [rsp+1C8h],rcx
    mov     rcx,[rsp+1C8h]
    mov     [rsp+1E0h],rcx
    mov     rcx,[rsp+200h]
    add     rcx,1
    mov     [rsp+1D0h],rcx
    mov     rcx,[rsp+1D0h]
    imul    rcx,rax
    mov     [rsp+1D8h],rcx
    mov     rcx,[rsp+1D8h]
    mov     [rsp+1C0h],rcx
    mov     rcx,[rsp+1C0h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     [rsp+1D0h],rcx
    mov     rcx,[rsp+1E0h]
    mov     rdx,[rsp+1D0h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+1E8h],rcx
    mov     rcx,[rsp+1E8h]
    mov     [rsp+1F0h],rcx
    mov     rcx,[rsp+258h]
    mov     [rsp+1C8h],rcx
    mov     rcx,[rsp+1C8h]
    mov     [rsp+1E0h],rcx
    add     rbp,1
    mov     [rsp+1D0h],rbp
    mov     rcx,[rsp+1D0h]
    imul    rcx,rax
    mov     [rsp+1D8h],rcx
    mov     rcx,[rsp+1D8h]
    mov     [rsp+1C0h],rcx
    mov     rcx,[rsp+1C0h]
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    mov     [rsp+1D0h],rcx
    mov     rcx,[rsp+1E0h]
    mov     rdx,[rsp+1D0h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+1E8h],rcx
    imul    rax,1
    mov     [rsp],rax
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFC90h
    call    ryo_h_Memcpy
    jmp     L1
L21:
    lea     rdi,[rsp+370h]
    mov     esi,0FFFFFCC0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+240h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L7
L22:
    call    qword ptr [sym9]
    lea     rdi,[rsp+370h]
    call    ryo_h_Unreachable
    ud2
L23:
    jmp     L8
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
    lea     rsp,[rdx-410h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-228h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-220h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-218h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-210h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-208h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-200h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-1F8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-1F0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-1E8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-68h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-8]
    mov     [rsp+98h],r11
    mov     [rdx-260h],rbx
    mov     [rdx-270h],r12
    mov     [rdx-280h],r13
    mov     [rdx-290h],r14
    mov     [rdx-2A0h],r15
    mov     [rdx-2B0h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-2D8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-2D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-2C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-2B8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-300h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-2F8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-320h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-318h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-310h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-308h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-330h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-328h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-340h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-338h],r11
    mov     r11,[rsp+8]
    mov     [rdx-358h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-360h],r11
    mov     r15,[rsp]
    lea     rsp,[rsp+0A0h]
    jmp     L1
L28:
    ret
L29:
    ret
L30:
    ret
L31:
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
    lea     rax,[rsp+38h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+68h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    mov     r13,rax
    jmp     L0
    mov     r14,rax
    jmp     L14
L0:
    jmp     L9
L1:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFFA0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L4
    .long   L3
    .long   L12
L3:
    mov     rax,[rsp+70h]
    mov     [rsp+68h],rax
    mov     [rsp+50h],r12
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+60h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L6
L4:
    mov     [rsp+70h],r12
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+60h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+68h]
    mov     rdi,rax
    mov     esi,1
    mov     rdx,rcx
    call    qword ptr [fn2.slot]
    jmp     L5
    mov     r14,rax
    jmp     L14
L5:
    jmp     L11
L6:
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
L7:
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L8
    jmp     L15
L8:
    mov     [rsp],r14
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L9:
    mov     [rsp+68h],r12
    lea     rax,[rsp+38h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+68h]
    mov     rcx,[rsp+60h]
    mov     rdi,rax
    mov     rsi,r13
    mov     rdx,rcx
    call    qword ptr [fn4.slot]
    mov     [rsp+70h],rax
    jmp     L10
    mov     r14,rax
    jmp     L14
L10:
    jmp     L1
L11:
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
    jmp     L6
L12:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L13:
    call    qword ptr [sym5]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L14:
    jmp     L7
L15:
    jmp     L13
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
L17:
    ret
L18:
    ret
L19:
    ret
L20:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+28h],rdx
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+50h],rax
    lea     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+48h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    mov     r13,rax
    jmp     L0
    mov     r14,rax
    jmp     L12
L0:
    jmp     L8
L1:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFB0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
L2:
    .long   L4
    .long   L3
    .long   L11
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],r12
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+8],0
    jmp     L6
L4:
    mov     [rsp+50h],r12
    mov     rax,r12
    lea     rax,[rax+20h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+48h]
    mov     rdi,rax
    mov     esi,1
    mov     rdx,rcx
    call    qword ptr [fn1.slot]
    jmp     L5
    mov     r14,rax
    jmp     L12
L5:
    jmp     L10
L6:
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF68h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    add     rsp,0A8h
    ret
L7:
    mov     [rsp],r14
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
L8:
    mov     [rsp+48h],r12
    lea     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+40h]
    mov     rdi,rax
    mov     rsi,r13
    mov     rdx,rcx
    call    qword ptr [fn2.slot]
    mov     [rsp+50h],rax
    jmp     L9
    mov     r14,rax
    jmp     L12
L9:
    jmp     L1
L10:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     [rsp+48h],r13
    mov     rax,[rsp+38h]
    mov     [rsp+50h],rax
    mov     [rsp+40h],r12
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFA0h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L6
L11:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L12:
    jmp     L7
  ; OSR entries
    lea     r11,[L13]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L13:
    .long   L14
    .long   L15
    .long   L16
L14:
    ret
L15:
    ret
L16:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<u64, u64, std::hash::RandomState>>::rustc_entry::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rsi
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret

fn main
    sub     rsp,6E8h
    mov     [rsp+180h],rbx
    mov     [rsp+170h],r12
    mov     [rsp+160h],r13
    mov     [rsp+150h],r14
    mov     [rsp+140h],r15
    mov     qword ptr [rsp+1A8h],50910h
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     rbx,rax
    lea     rax,[rsp+6A8h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     edi,0
    mov     rsi,rbx
    call    qword ptr [fn2.slot]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    jmp     L0
    jmp     L70
L0:
    mov     rax,[rsp+20h]
    mov     [rsp+670h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+678h],rax
    mov     ebx,1
L1:
    lea     rax,[rsp+670h]
    mov     rdi,rax
    call    fn3
    mov     r12,rdx
    jmp     L2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L70
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
L3:
    .long   L7
    .long   L5
    .long   L4
L4:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+1A8h],r10
    mov     rax,[rsp+1A8h]
    mov     rdi,rbx
    mov     rsi,rax
    call    fn4
    mov     rbx,rax
    jmp     L6
    jmp     L70
L6:
    jmp     L9
L7:
    mov     qword ptr [rsp+38h],0
    mov     qword ptr [rsp+40h],0
    mov     dword ptr [rsp+1ACh],14h
    mov     eax,[rsp+1ACh]
    cmp     eax,40h
    jb      L17
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym6]
    jmp     L8
    jmp     L70
L8:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     r10,14057B7EF767814Fh
    mov     [rsp+1A8h],r10
    mov     rax,[rsp+1A8h]
    mov     rdi,rbx
    mov     rsi,rax
    call    fn7
    mov     rbx,rax
    jmp     L10
    jmp     L70
L10:
    lea     r13,[rsp+6A8h]
    mov     dword ptr [rsp+1ACh],2Ch
    mov     eax,[rsp+1ACh]
    cmp     eax,40h
    jb      L12
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym9]
    jmp     L11
    jmp     L70
L11:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L12:
    mov     rax,rbx
    shr     rax,2Ch
    lea     rcx,[rsp+610h]
    mov     rdi,rcx
    mov     rsi,r13
    mov     rdx,rax
    call    fn10
    jmp     L13
    jmp     L70
L13:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFF30h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     qword ptr [rsp+190h],0
    lea     rax,[rsp+198h]
    mov     rcx,[rsp+190h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn11
    mov     r13,rax
    jmp     L14
    jmp     L70
L14:
    mov     rax,[r13]
    mov     [rsp+1A8h],rax
    mov     [rsp+10h],r12
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFF920h
    mov     edx,0FFFFF928h
    mov     ecx,0FFFFFAC8h
    mov     r8d,0FFFFF930h
    call    ryo_h_AddOvfUW64
    mov     r12,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L16
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L15
    jmp     L70
L15:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L16:
    mov     [r13],r12
    jmp     L1
L17:
    mov     qword ptr [rsp+1A8h],1
    mov     rax,[rsp+1A8h]
    shl     rax,14h
    mov     qword ptr [rsp+1A8h],2
    lea     rcx,[rsp+590h]
    mov     rdx,[rsp+1A8h]
    mov     rdi,rcx
    mov     esi,0
    mov     rcx,rdx
    mov     rdx,rax
    call    qword ptr [fn14.slot]
    jmp     L18
    jmp     L70
L18:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAB0h
    mov     edx,0FFFFFEB0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rax,[rsp+5B0h]
    lea     rcx,[rsp+190h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn15.slot]
    jmp     L19
    jmp     L70
L19:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFED0h
    mov     ecx,20h
    call    ryo_h_Copy
L20:
    lea     rax,[rsp+550h]
    mov     rdi,rax
    call    qword ptr [fn16.slot]
    mov     rbx,rdx
    jmp     L21
    mov     rcx,rax
    mov     rax,rcx
    jmp     L70
L21:
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L22]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L22:
    .long   L25
    .long   L23
    .long   L4
L23:
    mov     [rsp+528h],rbx
    lea     rax,[rsp+6A8h]
    lea     rcx,[rsp+528h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn17.slot]
    mov     rbx,rax
    jmp     L24
    jmp     L70
L24:
    jmp     L27
L25:
    lea     rax,[rsp+6A8h]
    mov     rdi,rax
    call    qword ptr [fn18.slot]
    mov     [rsp+50h],rax
    jmp     L26
    jmp     L70
L26:
    jmp     L33
L27:
    mov     [rsp],rbx
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFACCh
    mov     edx,0FFFFF920h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFF920h
    mov     edx,0FFFFFACCh
    call    ryo_h_ZextW32W64
    mov     rax,[rsp]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L28]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L28:
    .long   L20
    .long   L29
    .long   L4
L29:
    mov     qword ptr [rsp+1A8h],1
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFF920h
    mov     edx,0FFFFF928h
    mov     ecx,0FFFFF958h
    mov     r8d,0FFFFFAC8h
    call    ryo_h_AddOvfUW64
    mov     r12,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L31
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L30
    jmp     L70
L30:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L31:
    mov     [rsp+38h],r12
    mov     rax,[rsp+40h]
    mov     rcx,[rbx]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn7
    jmp     L32
    mov     rcx,rax
    mov     rax,rcx
    jmp     L70
L32:
    mov     [rsp+40h],rax
    jmp     L20
L33:
    lea     rax,[rsp+6A8h]
    mov     rdi,rax
    call    qword ptr [fn22.slot]
    jmp     L34
    jmp     L70
L34:
    lea     rax,[rsp+6A8h]
    lea     rcx,[rsp+490h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn23.slot]
    jmp     L35
    jmp     L70
L35:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFDB0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+188h]
    mov     rdi,rax
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+58h],rax
    jmp     L36
    jmp     L70
L36:
    lea     rax,[rsp+458h]
    mov     rdi,rax
    call    qword ptr [fn25.slot]
    jmp     L37
    jmp     L70
L37:
    mov     edi,0
    mov     esi,1FBD0h
    mov     edi,edi
    mov     esi,esi
    call    qword ptr [fn26.slot]
    mov     [rsp+60h],eax
    mov     [rsp+64h],edx
    jmp     L38
    mov     rbx,rax
    jmp     L71
L38:
    mov     rax,[rsp+60h]
    mov     [rsp+440h],rax
L39:
    lea     rax,[rsp+440h]
    mov     rdi,rax
    call    qword ptr [fn27.slot]
    mov     rbx,rdx
    jmp     L40
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L71
L40:
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L41]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L41:
    .long   L44
    .long   L42
    .long   L4
L42:
    lea     r12,[rsp+458h]
    mov     dword ptr [rsp+1ACh],138Bh
    mov     eax,[rsp+1ACh]
    cmp     eax,0
    jne     L46
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k28]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym29]
    jmp     L43
    mov     rbx,rax
    jmp     L71
L43:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L44:
    lea     rax,[rsp+6A8h]
    mov     rdi,rax
    call    qword ptr [fn18.slot]
    mov     [rsp+70h],rax
    jmp     L45
    mov     rbx,rax
    jmp     L71
L45:
    jmp     L55
L46:
    mov     dword ptr [rsp+1ACh],138Bh
    mov     [rsp],rbx
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFF920h
    mov     ecx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rsp+394h]
    lea     rcx,[rsp+370h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn31.slot]
    jmp     L47
    mov     rbx,rax
    jmp     L71
L47:
    mov     rax,[rsp+370h]
    mov     [rsp+380h],rax
    mov     rax,[rsp+378h]
    mov     [rsp+388h],rax
    lea     rdi,[k32]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+380h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn33.slot]
    jmp     L48
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L71
L48:
    lea     rcx,[rsp+3B8h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn34.slot]
    jmp     L49
    mov     rbx,rax
    jmp     L71
L49:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCD8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+3D0h]
    lea     rcx,[rsp+198h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn35.slot]
    jmp     L50
    mov     rbx,rax
    jmp     L71
L50:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCF0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+3F0h]
    lea     rcx,[rsp+198h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,rcx
    call    qword ptr [fn36.slot]
    jmp     L51
    mov     rbx,rax
    jmp     L71
L51:
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFD10h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+188h]
    mov     rdi,rax
    call    qword ptr [fn37.slot]
    mov     rbx,rax
    jmp     L52
    mov     rbx,rax
    jmp     L71
L52:
    mov     rax,[rbx]
    mov     [rsp+1A8h],rax
    mov     qword ptr [rsp+1A0h],1
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFF920h
    mov     edx,0FFFFF928h
    mov     ecx,0FFFFFAC8h
    mov     r8d,0FFFFFAC0h
    call    ryo_h_AddOvfUW64
    mov     r12,[rsp]
    movzx   eax,byte ptr [rsp+8]
    test    al,al
    je      L54
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFFAC8h
    lea     rdx,[k38]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L53
    mov     rbx,rax
    jmp     L71
L53:
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L54:
    mov     [rbx],r12
    jmp     L39
L55:
    lea     rbx,[rsp+70h]
    lea     rax,[rsp+458h]
    mov     rdi,rax
    call    qword ptr [fn40.slot]
    mov     [rsp+78h],rax
    jmp     L56
    mov     rbx,rax
    jmp     L71
L56:
    lea     r12,[rsp+78h]
    lea     rax,[rsp+50h]
    lea     r13,[rsp+38h]
    lea     r14,[rsp+40h]
    lea     r15,[rsp+58h]
    lea     rcx,[rsp+0E0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn41.slot]
    jmp     L57
    mov     rbx,rax
    jmp     L71
L57:
    lea     rax,[rsp+0F0h]
    mov     rdi,rax
    mov     rsi,r13
    call    qword ptr [fn42.slot]
    jmp     L58
    mov     rbx,rax
    jmp     L71
L58:
    lea     rax,[rsp+100h]
    mov     rdi,rax
    mov     rsi,r14
    call    qword ptr [fn42.slot]
    jmp     L59
    mov     rbx,rax
    jmp     L71
L59:
    lea     rax,[rsp+110h]
    mov     rdi,rax
    mov     rsi,rbx
    call    qword ptr [fn41.slot]
    jmp     L60
    mov     rbx,rax
    jmp     L71
L60:
    lea     rax,[rsp+120h]
    mov     rdi,rax
    mov     rsi,r15
    call    qword ptr [fn42.slot]
    jmp     L61
    mov     rbx,rax
    jmp     L71
L61:
    lea     rax,[rsp+130h]
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn41.slot]
    jmp     L62
    mov     rbx,rax
    jmp     L71
L62:
    mov     rax,[rsp+0E0h]
    mov     [rsp+80h],rax
    mov     rax,[rsp+0E8h]
    mov     [rsp+88h],rax
    mov     rax,[rsp+0F0h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+0F8h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+100h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+108h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+110h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+118h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+120h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+128h]
    mov     [rsp+0C8h],rax
    mov     rax,[rsp+130h]
    mov     [rsp+0D0h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+0D8h],rax
    lea     rdi,[k47]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+80h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn48.slot]
    jmp     L63
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L71
L63:
    mov     rdi,rax
    mov     rsi,rdx
    call    qword ptr [sym49]
    jmp     L64
    mov     rbx,rax
    jmp     L71
L64:
    lea     rax,[rsp+458h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn50.slot]
    jmp     L65
    jmp     L70
L65:
    lea     rax,[rsp+6A8h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn51.slot]
    mov     rbx,[rsp+180h]
    mov     r12,[rsp+170h]
    mov     r13,[rsp+160h]
    mov     r14,[rsp+150h]
    mov     r15,[rsp+140h]
    add     rsp,6E8h
    ret
L66:
    lea     rax,[rsp+458h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn50.slot]
    mov     r12,rbx
    jmp     L67
    jmp     L72
L67:
    lea     rax,[rsp+6A8h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+1A8h]
    mov     rdi,rax
    call    qword ptr [fn51.slot]
    jmp     L68
    jmp     L72
L68:
    mov     [rsp],r12
    lea     rdi,[rsp+6E0h]
    mov     esi,0FFFFF920h
    call    ryo_h_Resume
    ud2
L69:
    call    qword ptr [sym54]
    lea     rdi,[rsp+6E0h]
    call    ryo_h_Unreachable
    ud2
L70:
    mov     r12,rax
    jmp     L67
L71:
    jmp     L66
L72:
    jmp     L69
  ; OSR entries
    lea     r11,[L73]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L73:
    .long   L74
    .long   L75
    .long   L76
    .long   L77
    .long   L78
    .long   L79
    .long   L80
L74:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7F0h]
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
    mov     r11,[rdx-50h]
    mov     [rsp+100h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+108h],r11
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
    mov     r11,[rsp+100h]
    mov     [rdx-6C0h],r11
    mov     r11,[rsp+108h]
    mov     [rdx-6B8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+110h]
    jmp     L1
L75:
    ret
L76:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7F0h]
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
    mov     r11,[rdx-50h]
    mov     [rsp+0F8h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+100h],r11
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
    mov     r11,[rsp+0F8h]
    mov     [rdx-6C0h],r11
    mov     r11,[rsp+100h]
    mov     [rdx-6B8h],r11
    lea     rsp,[rsp+110h]
    jmp     L20
L77:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7F0h]
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
    mov     r11,[rdx-50h]
    mov     [rsp+0F8h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+100h],r11
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
    mov     r11,[rsp+0F8h]
    mov     [rdx-6C0h],r11
    mov     r11,[rsp+100h]
    mov     [rdx-6B8h],r11
    lea     rsp,[rsp+110h]
    jmp     L39
L78:
    ret
L79:
    ret
L80:
    ret

fn main::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rsi
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,3
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    cmp     rax,0
    setne   al
    movzx   eax,al
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn main::{closure#1}
    sub     rsp,18h
    mov     rax,[rdx]
    mov     rdi,rsi
    mov     rsi,rax
    call    fn0
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

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    sub     rsp,18h
    mov     eax,[rdi]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    al
    movzx   eax,al
    add     rsp,18h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for u64>::lt
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    cmp     rax,rcx
    setb    al
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
    call    fn0
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFFD4h
    mov     edx,0FFFFFF38h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+120h]
    mov     esi,0FFFFFEE0h
    mov     edx,0FFFFFFD4h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp]
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
    .long   L4
    .long   L3
    .long   L2
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
    call    ryo_h_Unreachable
    ud2
L3:
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
L4:
    mov     rax,[rsp+60h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+90h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+98h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    jmp     L1
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
    call    fn0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA8h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L4
    .long   L3
    .long   L2
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
    call    ryo_h_Unreachable
    ud2
L3:
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
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+8],0
    jmp     L1
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
    ret

fn std::collections::HashMap::<u64, u64>::get::<u64>
    sub     rsp,18h
    call    fn0
    add     rsp,18h
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
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFFC4h
    call    ryo_h_ZextW32W64
    mov     rax,[rsp]
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
    .long   L4
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
L2:
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
    call    qword ptr [fn0.slot]
    mov     rbx,rax
    jmp     L3
    mov     r13d,1
    mov     r12,rax
    jmp     L26
L3:
    jmp     L5
L4:
    mov     rax,[rsp+18h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+0F7h],0
    movzx   eax,byte ptr [rsp+0F7h]
    test    al,al
    je      L14
    jmp     L13
L5:
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
    call    fn1
    mov     rbx,rax
    jmp     L6
    mov     r13d,0
    mov     r12,rax
    jmp     L26
L6:
    jmp     L18
L7:
    mov     rbx,[rsp+120h]
    mov     r12,[rsp+110h]
    mov     r13,[rsp+100h]
    add     rsp,138h
    ret
L8:
    mov     [rsp],r12
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED0h
    call    ryo_h_Resume
    ud2
L9:
    lea     rax,[rsp+68h]
    mov     [rsp+0F0h],rax
    mov     rax,[rsp+0F0h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L10
    jmp     L27
L10:
    jmp     L8
L11:
    test    r13b,r13b
    je      L8
    jmp     L9
L12:
    mov     rax,[rsp+58h]
    mov     [rsp+60h],rax
    mov     rax,[rsp+60h]
    lea     rax,[rax+18h]
    jmp     L7
L13:
    mov     qword ptr [rsp+58h],8
    jmp     L12
L14:
    mov     rax,[rsp+40h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+0F7h],0
    movzx   eax,byte ptr [rsp+0F7h]
    test    al,al
    je      L17
    jmp     L16
L15:
    jmp     L12
L16:
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    jmp     L15
L17:
    mov     qword ptr [rsp+0F0h],0FFFFFFFFFFFFFFFFh
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+0F0h]
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+58h],rax
    jmp     L15
L18:
    mov     byte ptr [rsp+0F7h],0
    movzx   eax,byte ptr [rsp+0F7h]
    test    al,al
    je      L21
    jmp     L20
L19:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+0B0h]
    lea     rax,[rax+18h]
    jmp     L7
L20:
    mov     qword ptr [rsp+0A8h],8
    jmp     L19
L21:
    mov     [rsp+98h],rbx
    mov     rax,[rsp+98h]
    mov     [rsp+0A0h],rax
    mov     byte ptr [rsp+0F7h],0
    movzx   eax,byte ptr [rsp+0F7h]
    test    al,al
    je      L24
    jmp     L23
L22:
    jmp     L19
L23:
    mov     rax,[rsp+0A0h]
    mov     [rsp+0A8h],rax
    jmp     L22
L24:
    mov     qword ptr [rsp+0F0h],0FFFFFFFFFFFFFFFFh
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0F0h]
    mov     r11,rcx
    imul    r11,20h
    add     r11,rax
    mov     rax,r11
    mov     [rsp+0A8h],rax
    jmp     L22
L25:
    call    qword ptr [sym3]
    lea     rdi,[rsp+130h]
    call    ryo_h_Unreachable
    ud2
L26:
    jmp     L11
L27:
    jmp     L25
  ; OSR entries
    lea     r11,[L28]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L28:
    .long   L29
    .long   L30
    .long   L31
    .long   L32
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
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
L36:
    ret
L37:
    ret

fn std::collections::hash_map::Entry::<'_, u64, u64>::or_insert
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     rbx,rsi
    mov     [rsp],rdi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA0h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L4
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,rbx
    call    fn0
    mov     rbx,rax
    jmp     L3
    mov     r12,rax
    jmp     L22
L3:
    jmp     L9
L4:
    mov     r13,[rsp+18h]
    mov     r11,[rsp+20h]
    jmp     L18
    jmp     L17
L5:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    add     rsp,68h
    ret
L6:
    mov     [rsp],r12
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L7:
    jmp     L6
L8:
    jmp     L6
    jmp     L7
L9:
    jmp     L12
    jmp     L11
L10:
    lea     rax,[rax+8]
    jmp     L5
L11:
    mov     eax,8
    jmp     L10
L12:
    jmp     L15
    jmp     L14
L13:
    jmp     L10
L14:
    mov     rax,rbx
    jmp     L13
L15:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,rbx
    mov     rbx,r11
    mov     rax,rbx
    jmp     L13
L16:
    lea     rax,[rax+8]
    jmp     L5
L17:
    mov     eax,8
    jmp     L16
L18:
    jmp     L21
    jmp     L20
L19:
    jmp     L16
L20:
    mov     rax,r13
    jmp     L19
L21:
    mov     r11,0FFFFFFFFFFFFFFFFh
    imul    r11,10h
    add     r11,r13
    mov     r13,r11
    mov     rax,r13
    jmp     L19
L22:
    jmp     L8
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
    .long   L31
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
L31:
    ret

fn std::fmt::Arguments::<'_>::new::<4, 1>
    sub     rsp,18h
    mov     rax,rdi
    mov     rdx,rsi
    add     rsp,18h
    ret

fn std::fmt::format
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     rbx,rdi
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    mov     r12,[rsp+30h]
    mov     rax,r12
    and     rax,1
    cmp     rax,1
    je      L1
    jmp     L3
L0:
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF68h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    add     rsp,0A8h
    ret
L1:
    mov     r13,[rsp+28h]
    shr     r12,1
    jmp     L2
L2:
    jmp     L5
L3:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L4:
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
L5:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     esi,1
    mov     edx,1
    mov     rcx,r12
    mov     r8,rax
    call    qword ptr [fn3.slot]
    mov     [rsp+58h],r13
    mov     [rsp+60h],r12
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+40h],rax
    jmp     L4
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

fn std::iter::adapters::step_by::step_by_spec::<impl std::iter::adapters::step_by::StepByImpl<std::ops::Range<u64>> for std::iter::StepBy<std::ops::Range<u64>>>::spec_next
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     rbx,rdi
    mov     rax,[rbx+10h]
    mov     r12,rax
    add     r12,1
    mov     rdi,r12
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L5
    .long   L6
    .long   L4
L1:
    mov     rax,[rbx]
    mov     rcx,rax
    add     rcx,r12
    mov     [rbx],rcx
    mov     rcx,r13
    sub     rcx,1
    mov     [rbx+8],rcx
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+10h],1
    jmp     L3
L2:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L3:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    add     rsp,58h
    ret
L4:
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
L5:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L4
L6:
    mov     r13,[rbx+8]
    cmp     r13,0
    ja      L1
    jmp     L2
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

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u32>>::next
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    mov     eax,eax
    mov     edx,edx
    add     rsp,18h
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<u64>>::next
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn std::mem::size_of::<std::arch::x86_64::__m128i>
    sub     rsp,18h
    mov     eax,10h
    add     rsp,18h
    ret

fn std::option::Option::<&str>::map_or_else::<std::string::String, {closure@std::fmt::format::{closure#0}}, for<'a> fn(&'a str) -> <str as std::borrow::ToOwned>::Owned {<str as std::borrow::ToOwned>::to_owned}>
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     rbx,rdi
    mov     r12,rcx
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA8h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp]
    mov     rdi,rax
    call    ryo_hr_ZextW32W64
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
    .long   L4
    .long   L1
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     [rsp+48h],r12
    lea     rax,[rsp+8]
    mov     rcx,[rsp+48h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    jmp     L3
    mov     ebx,0
    mov     r12,rax
    mov     eax,1
    jmp     L11
L3:
    jmp     L5
L4:
    mov     rax,[rsp+28h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+40h]
    mov     [rsp+50h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+58h],rax
    lea     rax,[rsp+8]
    mov     rcx,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn1.slot]
    jmp     L5
    mov     ebx,1
    mov     r12,rax
    mov     eax,0
    jmp     L11
L5:
    mov     [rsp],rbx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    add     rsp,88h
    ret
L6:
    test    bl,bl
    jne     L10
L7:
    mov     [rsp],r12
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
L8:
    jmp     L6
L9:
    test    al,al
    je      L6
    jmp     L8
L10:
    jmp     L7
L11:
    jmp     L9
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
L13:
    ret
L14:
    ret
L15:
    ret
L16:
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    mov     r13,rax
    jmp     L2
L0:
    mov     rax,r12
    sub     rax,1
    and     rax,rbx
    cmp     rax,0
    sete    al
    movzx   eax,al
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L1:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r14,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,2Ah
    shl     rax,1
    mov     r15,rax
    or      r15,1
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L2:
    cmp     r13d,1
    jne     L1
    jmp     L0
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
L4:
    ret
L5:
    ret

fn std::ptr::copy_nonoverlapping::<u8>
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,1
    mov     ecx,1
    mov     r8,r13
    mov     r9,rax
    call    fn1
    imul    r13,1
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,r13
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

fn std::ptr::copy_nonoverlapping::precondition_check
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+30h],rdx
    mov     r14,rcx
    mov     [rsp+20h],r8
    mov     [rsp+10h],r9
    mov     r11,[rsp+20h]
    cmp     r11,0
    jne     L0
    mov     qword ptr [rsp+18h],1
    jmp     L1
L0:
    mov     r11,[rsp+30h]
    cmp     r11,0
    sete    al
    mov     [rsp+18h],rax
L1:
    mov     rdi,rbx
    mov     rsi,r14
    call    fn0
    mov     rbp,rax
    jmp     L2
    jmp     L21
L2:
    jmp     L13
L3:
    mov     rdi,r12
    mov     rsi,r14
    call    fn0
    mov     r15,rax
    jmp     L4
    jmp     L21
L4:
    jmp     L18
L5:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+20h]
    call    qword ptr [fn2.slot]
    mov     [rsp+28h],rax
    jmp     L6
    jmp     L21
L6:
    jmp     L19
L7:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     r13,rax
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     eax,11Bh
    shl     rax,1
    or      rax,1
    mov     rdi,r13
    mov     rsi,rax
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [sym5]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0A8h
    ret
L9:
    cmp     byte ptr [rsp+18h],0
    je      L12
    jmp     L11
L10:
    jmp     L7
L11:
    jmp     L3
L12:
    cmp     rbx,0
    sete    al
    xor     eax,1
    test    al,al
    je      L7
    jmp     L3
L13:
    test    bpl,bpl
    je      L10
    jmp     L9
L14:
    cmp     byte ptr [rsp+18h],0
    je      L17
    jmp     L16
L15:
    jmp     L7
L16:
    jmp     L5
L17:
    cmp     r12,0
    sete    al
    xor     eax,1
    test    al,al
    je      L7
    jmp     L5
L18:
    test    r15b,r15b
    je      L15
    jmp     L14
L19:
    cmp     byte ptr [rsp+28h],0
    je      L7
    jmp     L8
L20:
    call    qword ptr [sym6]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
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
    .long   L29
    .long   L30
    .long   L31
    .long   L32
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
L30:
    ret
L31:
    ret
L32:
    ret

fn std::ptr::drop_glue::<(std::string::String, usize)> - shim(Some((std::string::String, usize)))
    sub     rsp,18h
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u8>> - shim(Some(alloc::raw_vec::RawVec<u8>))
    sub     rsp,18h
    call    qword ptr [sym0]
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::string::String> - shim(Some(std::string::String))
    sub     rsp,18h
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::vec::Vec<u8>> - shim(Some(std::vec::Vec<u8>))
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     rdi,rbx
    call    qword ptr [sym0]
    jmp     L0
    mov     r12,rax
    jmp     L7
L0:
    jmp     L5
L1:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L2:
    mov     [rsp],r12
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L3:
    mov     rdi,rbx
    call    qword ptr [fn1.slot]
    jmp     L4
    jmp     L8
L4:
    jmp     L2
L5:
    mov     rdi,rbx
    call    qword ptr [fn1.slot]
    jmp     L1
L6:
    call    qword ptr [sym3]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L7:
    jmp     L3
L8:
    jmp     L6
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

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u8>>::eq
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     rdx,[rsi+8]
    mov     rsi,[rsi+10h]
    cmp     rcx,rsi
    jne     L0
    mov     rdi,rax
    mov     rsi,rdx
    mov     rdx,rcx
    call    qword ptr [fn0.slot]
    jmp     L1
L0:
    mov     eax,0
L1:
    movzx   eax,al
    add     rsp,18h
    ret

