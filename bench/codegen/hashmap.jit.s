fn <&u64 as std::ops::Rem<u64>>::rem
    sub     rsp,18h
    mov     rax,[rdi]
    cmp     rsi,0
    je      L0
    mov     rdi,rax
    call    ryo_hr_RemUW64
    add     rsp,18h
    ret
L0:
    mov     rdi,rdx
    call    qword ptr [sym0]
    ud2

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::finish
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
    call    fn0
    mov     rax,[rsp+10h]
    xor     rax,rbx
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    xor     rax,0FFh
    mov     [rsp+18h],rax
    mov     rdi,r12
    call    qword ptr [fn1.slot]
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
    mov     edx,0
    jmp     L4
L1:
    mov     rax,[rbx+40h]
    mov     r14d,8
    sub     r14,rax
    mov     [rsp+60h],r14
    mov     rdi,r13
    mov     rsi,r14
    call    qword ptr [fn0.slot]
    jmp     L9
L2:
    mov     rdx,[rbx+40h]
    mov     [rsp+60h],rdx
    imul    rdx,8
    mov     rdi,[rsp+50h]
    mov     rsi,rdx
    call    ryo_hr_ShlW64
    mov     rdx,rax
    mov     rsi,[rbx+38h]
    or      rsi,rdx
    mov     [rbx+38h],rsi
    cmp     r13,r14
    jae     L3
    mov     rdx,[rbx+40h]
    add     rdx,r13
    mov     [rbx+40h],rdx
    jmp     L8
L3:
    mov     rdx,[rbx+38h]
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
    mov     rdx,r14
L4:
    mov     rsi,r13
    sub     rsi,rdx
    mov     rdi,rsi
    and     rdi,7
    mov     [rsp+38h],rdx
    mov     [rsp+30h],rsi
    mov     [rsp+10h],rdi
    mov     [rsp+18h],r12
    mov     [rsp+20h],r13
    mov     [rsp+28h],rbx
L5:
    mov     r10,[rsp+38h]
    mov     [rsp+60h],r10
    mov     rdx,[rsp+30h]
    sub     rdx,[rsp+10h]
    mov     r11,[rsp+38h]
    cmp     r11,rdx
    jae     L7
    mov     qword ptr [rsp+60h],0
    mov     r11,[rsp+18h]
    mov     r10,[rsp+38h]
    lea     r11,[r11+r10]
    mov     [rsp+48h],r11
    lea     r11,[rsp+60h]
    mov     [rsp+40h],r11
    jmp     L10
L6:
    mov     rcx,[rdx]
    xor     rcx,rsi
    mov     [rdx],rcx
    add     rdi,8
    mov     [rsp+38h],rdi
    mov     [rsp+30h],r8
    mov     [rsp+10h],r9
    mov     [rsp+18h],r15
    mov     [rsp+20h],rbp
    mov     [rsp+28h],rdx
    jmp     L5
L7:
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+10h]
    call    qword ptr [fn2.slot]
    mov     rcx,rax
    mov     r11,[rsp+28h]
    mov     [r11+38h],rcx
    mov     r11,[rsp+28h]
    mov     r10,[rsp+10h]
    mov     [r11+40h],r10
L8:
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,0D8h
    ret
L9:
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,0
    mov     rcx,rax
    call    qword ptr [fn2.slot]
    mov     [rsp+50h],rax
    jmp     L2
L10:
    lea     rax,[k4]
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     edx,1
    mov     ecx,1
    mov     r8d,8
    mov     r9,rax
    call    fn5
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+60h]
    mov     r11,[rsp+28h]
    mov     rax,[r11+18h]
    xor     rax,rbx
    mov     r11,[rsp+28h]
    mov     [r11+18h],rax
    mov     r10,[rsp+28h]
    mov     [rsp+60h],r10
    mov     rdi,[rsp+28h]
    call    fn1
    mov     rdx,[rsp+28h]
    mov     rsi,rbx
    mov     rdi,[rsp+38h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    jmp     L6
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
    mov     [rdx-98h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A8h],r11
    lea     rsp,[rsp+40h]
    jmp     L5
L14:
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
    mov     rsi,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L6

fn <core::hash::sip::Hasher<core::hash::sip::Sip13Rounds> as std::hash::Hasher>::write_str
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     rdi,rbx
    call    fn0
    mov     byte ptr [rsp+2Fh],0FFh
    lea     rax,[rsp+2Fh]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+20h],1
    mov     rdi,rbx
    mov     rsi,rax
    mov     edx,1
    call    fn0
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret

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
    sub     rsp,48h
    jmp     L2
L0:
    add     rsp,48h
    ret
L1:
    mov     [rsp+18h],rcx
    mov     r8,rcx
    lea     r8,[r8+8]
    mov     r9,[rdi]
    mov     [rsp+28h],rcx
    mov     [rsp+30h],r8
    mov     [rsp+10h],rcx
    mov     [rsp+18h],r8
    mov     rdi,r9
    mov     rdx,rcx
    mov     rcx,r8
    call    qword ptr [fn0.slot]
    jmp     L0
L2:
    mov     [rsp+10h],rdx
    jmp     L4
L3:
    mov     rcx,rax
    jmp     L1
L4:
    lea     rdx,[rdx-10h]
    mov     rax,rdx
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
L6:
    ret
L7:
    ret
L8:
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
    sub     rsp,68h
    mov     [rsp+8],rsi
    lea     rax,[rsp+18h]
    mov     rsi,rdi
    mov     rdi,rax
    call    fn0
    lea     rax,[rsp+8]
    lea     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn1.slot]
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    fn2
    add     rsp,68h
    ret
    jmp     L0
    jmp     L0
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
L2:
    ret

fn <std::hash::RandomState as std::hash::BuildHasher>::hash_one::<&u64>
    sub     rsp,68h
    mov     [rsp+8],rsi
    lea     rax,[rsp+18h]
    mov     rsi,rdi
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    lea     rax,[rsp+8]
    lea     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn1.slot]
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    add     rsp,68h
    ret
    jmp     L0
    jmp     L0
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
L2:
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
    mov     [rsp+10h],rax
    mov     [rsp+18h],rcx
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
    mov     r12,rsi
    lea     rax,[k0]
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
    lea     rax,[k0]
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
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    lea     rax,[rsp+18h]
    lea     rcx,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    test    al,al
    je      L0
    mov     rax,[rsp+18h]
    jmp     L1
L0:
    mov     rax,[rsp+10h]
L1:
    add     rsp,28h
    ret
    jmp     L3
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
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
L5:
    ret
L6:
    ret
L7:
    ret

fn <usize as std::default::Default>::default
    sub     rsp,18h
    mov     eax,0
    add     rsp,18h
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     rbx,rdi
    mov     rax,[sym0]
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rax
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rax
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0
    mov     ecx,0FFFFFFC0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+40h]
    add     rsp,58h
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
    mov     rcx,rax
    mov     r10,736F6D6570736575h
    xor     rcx,r10
    mov     [rdi],rcx
    mov     rcx,[rdi+28h]
    mov     rdx,rcx
    mov     r10,646F72616E646F6Dh
    xor     rdx,r10
    mov     [rdi+10h],rdx
    mov     r10,6C7967656E657261h
    xor     rax,r10
    mov     [rdi+8],rax
    mov     r10,7465646279746573h
    xor     rcx,r10
    mov     [rdi+18h],rcx
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
    mov     r11d,3
    cmp     r11,[rsp+20h]
    jb      L1
    jmp     L0
L0:
    mov     ebx,0
    mov     r12d,0
    jmp     L2
L1:
    mov     dword ptr [rsp+60h],0
    mov     r11,[rsp+10h]
    mov     r10,[rsp+28h]
    lea     r15,[r11+r10]
    lea     rbp,[rsp+60h]
    jmp     L9
L2:
    mov     rax,rbx
    add     rax,1
    cmp     rax,[rsp+20h]
    jb      L4
    jmp     L3
L3:
    mov     [rsp+30h],rbx
    mov     [rsp+38h],r12
    jmp     L5
L4:
    mov     word ptr [rsp+54h],0
    mov     rax,[rsp+28h]
    add     rax,rbx
    mov     r11,[rsp+10h]
    lea     r14,[r11+rax]
    lea     r13,[rsp+54h]
    jmp     L10
L5:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+20h]
    jb      L7
    jmp     L6
L6:
    mov     rax,[rsp+38h]
    jmp     L8
L7:
    mov     r11,[rsp+28h]
    add     r11,[rsp+30h]
    mov     [rsp+40h],r11
    jmp     L11
L8:
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,0D8h
    ret
L9:
    lea     rax,[k0]
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,1
    mov     ecx,1
    mov     r8d,4
    mov     r9,rax
    call    fn1
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,[rsp+60h]
    mov     eax,eax
    mov     ebx,4
    mov     r12,rax
    jmp     L2
L10:
    lea     rax,[k2]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,1
    mov     ecx,1
    mov     r8d,2
    mov     r9,rax
    call    fn1
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,2
    call    ryo_hr_Memcpy
    movzx   eax,word ptr [rsp+54h]
    movzx   eax,ax
    mov     rcx,rbx
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      r12,rax
    add     rbx,2
    mov     [rsp+30h],rbx
    mov     [rsp+38h],r12
    jmp     L5
L11:
    lea     rax,[k4]
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
    movzx   eax,al
    mov     rcx,[rsp+30h]
    imul    rcx,8
    mov     rdi,rax
    mov     rsi,rcx
    call    ryo_hr_ShlW64
    or      rax,[rsp+38h]
    jmp     L8
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

fn core::num::<impl u32>::unchecked_add::precondition_check
    sub     rsp,18h
    mov     r11,rdi
    add     r11d,esi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,171h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn core::num::<impl u64>::unchecked_add::precondition_check
    sub     rsp,18h
    mov     r11,rdi
    add     r11,rsi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,171h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::get::<u64>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx+18h]
    cmp     rax,0
    jne     L0
    mov     ecx,0
    jmp     L1
L0:
    mov     rax,rbx
    lea     rax,[rax+20h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn0
    jmp     L2
L1:
    mov     rax,rcx
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L2:
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,r12
    call    qword ptr [fn1.slot]
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
    lea     r11,[L3]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L3:
    .long   L4
    .long   L7
    .long   L8
L4:
    mov     ecx,0
    jmp     L1
L5:
    lea     rax,[rax+8]
    mov     rcx,rax
    jmp     L1
L6:
    jmp     L5
L7:
    lea     rbx,[rbx-10h]
    mov     rax,rbx
    jmp     L6
L8:
    ud2
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

fn hashbrown::map::HashMap::<u64, u64, std::hash::RandomState>::retain::<{closure@bench/hashmap.rs:23:16: 23:22}>
    sub     rsp,0F8h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+8],rdi
    mov     rax,[rdi]
    mov     [rsp+78h],rax
    jmp     L5
L0:
    mov     rax,[rsp+80h]
    cmp     rax,0
    jne     L6
L1:
    jmp     L3
L2:
    test    al,al
    jne     L0
    mov     rax,[rsp+8]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L0
L3:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    add     rsp,0F8h
    ret
L4:
    mov     rax,[rsp+8]
    mov     rbx,[rax+18h]
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFF70h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+30h],rbx
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFF20h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L0
L5:
    mov     [rsp+70h],rax
    mov     [rsp+80h],rax
    mov     rcx,[rsp+8]
    mov     rdx,[rcx]
    mov     rcx,[rcx+8]
    add     rcx,1
    lea     rsi,[rsp+60h]
    mov     rdi,rsi
    mov     rsi,rdx
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L4
L6:
    lea     rax,[rsp+60h]
    mov     rdi,rax
    call    fn2
    mov     rbx,rax
    mov     rax,[rsp+80h]
    sub     rax,1
    mov     [rsp+80h],rax
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
    lea     r11,[L7]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L7:
    .long   L1
    .long   L10
    .long   L11
L8:
    mov     rcx,rax
    lea     rcx,[rcx+8]
    lea     rdx,[rsp+8]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn3
    mov     rcx,r12
    jmp     L2
L9:
    mov     r12,rcx
    jmp     L8
L10:
    mov     rax,rbx
    lea     rax,[rax-10h]
    mov     rcx,rbx
    jmp     L9
L11:
    ud2
    jmp     L13
L12:
    mov     [rsp],rax
    lea     rdi,[rsp+0F0h]
    mov     esi,0FFFFFF10h
    call    ryo_h_Resume
    ud2
    mov     rcx,rax
    mov     rax,rcx
    jmp     L13
    mov     rcx,rax
    mov     rax,rcx
    jmp     L13
    mov     rcx,rax
    mov     rax,rcx
L13:
    jmp     L12
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
L15:
    pop     rcx
    lea     rdx,[rsp+0E0h]
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
    mov     r11,[rdx-8]
    mov     [rsp+28h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
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
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    lea     rsp,[rsp+30h]
    jmp     L0
L16:
    ret
L17:
    ret
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-130h]
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
    mov     r11,[rsp+10h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L2
L19:
    ret
L20:
    ret
L21:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-130h]
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
    mov     r11,[rsp+10h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L8
L22:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-130h]
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
    mov     r11,[rsp+10h]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L9

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
    .long   L20
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
    jmp     L12
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
    jmp     L11
L9:
    mov     [rsp+38h],rcx
    lea     rsi,[rsp+130h]
    mov     rdi,rsi
    mov     rsi,rdx
    mov     rdx,rcx
    call    fn2
    mov     rcx,rax
    mov     rax,rcx
    mov     rcx,r13
    jmp     L2
L10:
    mov     r13,rsi
    jmp     L9
L11:
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
    jmp     L10
L12:
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
    jmp     L15
L13:
    mov     [rsp+40h],rax
    mov     [rsp+18h],rax
    mov     rax,[rsp+20h]
    lea     rax,[rax+10h]
    mov     [rsp+20h],rax
    mov     rbx,rcx
    mov     r12,rdx
    mov     r13,rsi
    jmp     L0
L14:
    jmp     L13
L15:
    mov     rax,[rsp+40h]
    lea     rax,[rax-100h]
    mov     rcx,r15
    mov     rdx,rbp
    mov     rsi,[rsp+10h]
    jmp     L14
    mov     rcx,rax
    mov     rax,[rsp+10h]
    jmp     L21
L16:
    jmp     L19
L17:
    mov     [rsp],rcx
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    call    ryo_h_Resume
    ud2
L18:
    jmp     L17
L19:
    test    al,al
    jne     L18
    jmp     L17
L20:
    ud2
    mov     rdx,rax
    mov     eax,0
    mov     rcx,rdx
    jmp     L21
    mov     rdx,rax
    mov     rax,[rsp+10h]
    mov     rcx,rdx
L21:
    jmp     L16
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
    .long   L33
L23:
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
L24:
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
L25:
    ret
L26:
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
L27:
    ret
L28:
    ret
L29:
    ret
L30:
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
    mov     r13,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+50h]
    jmp     L9
L31:
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
    jmp     L10
L32:
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
    jmp     L13
L33:
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
    jmp     L14

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
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     r8,rcx
    jmp     L2
L4:
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    mov     rdx,rax
    jmp     L0
L5:
    jmp     L4
L6:
    lea     rdi,[rdi-20h]
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

fn hashbrown::raw::RawTable::<(std::string::String, usize)>::insert_no_grow
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF90h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     [rsp+48h],rbx
    mov     rdi,rbx
    mov     rsi,r12
    call    fn0
    mov     rcx,[rbx]
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rcx
    lea     rcx,[rcx+rax]
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rcx
    movzx   edx,byte ptr [rcx]
    shr     r12,39h
    mov     [rsp+40h],r12
    and     r12,7Fh
    mov     [rsp+38h],r12
    mov     [rsp+4Eh],r12b
    mov     [rsp+4Fh],r12b
    mov     rsi,rax
    sub     rsi,10h
    mov     [rsp+30h],rsi
    mov     rdi,[rbx+8]
    and     rsi,rdi
    mov     [rsp+38h],rsi
    add     rsi,10h
    mov     [rsp+40h],rsi
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rcx
    mov     [rcx],r12b
    mov     rcx,[rbx]
    lea     rcx,[rcx+rsi]
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rcx
    mov     [rcx],r12b
    mov     rcx,[rbx]
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rcx
    mov     rcx,[rsp+40h]
    mov     [rsp+30h],rcx
    jmp     L2
L0:
    mov     r12,[rsp+38h]
    mov     rcx,rdx
    and     ecx,1
    mov     [rsp+46h],cl
    cmp     cl,0
    setne   cl
    mov     [rsp+47h],cl
    movzx   ecx,cl
    mov     [rsp+48h],rcx
    mov     rsi,[rbx+10h]
    sub     rsi,rcx
    mov     [rbx+10h],rsi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    mov     ecx,20h
    call    ryo_h_Copy
    jmp     L5
L1:
    jmp     L0
L2:
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+30h]
    mov     r11,rax
    imul    r11,20h
    add     r11,rcx
    mov     rcx,r11
    mov     [rsp+38h],rcx
    jmp     L1
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0
    mov     ecx,0FFFFFFC0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,r12
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    add     rsp,78h
    ret
L4:
    jmp     L3
L5:
    mov     rax,r12
    lea     rax,[rax-20h]
    jmp     L4
    mov     rbx,rax
    jmp     L7
L6:
    mov     [rsp],rbx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L7:
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L6
    call    qword ptr [sym2]
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
    .long   L15
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
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    jmp     L3
L0:
    mov     rax,rsi
    add     rsp,18h
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
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    mov     rsi,rax
    jmp     L0
L5:
    jmp     L4
L6:
    lea     rdi,[rdi-20h]
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

fn hashbrown::raw::RawTable::<(u64, u64)>::erase
    sub     rsp,28h
    mov     [rsp+10h],rsi
    lea     rax,[rsp+10h]
    mov     rsi,rax
    call    fn0
    jmp     L1
L0:
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L4
L1:
    mov     rax,[rsp+10h]
    jmp     L3
L2:
    mov     rax,rcx
    jmp     L0
L3:
    lea     rax,[rax-10h]
    mov     rcx,rax
    jmp     L2
L4:
    add     rsp,28h
    ret
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

fn hashbrown::raw::RawTable::<(u64, u64)>::erase_no_drop
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rax,[rbx]
    jmp     L2
L0:
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L1:
    mov     rdi,rbx
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    jmp     L0
L2:
    mov     rcx,[rsi]
    jmp     L4
L3:
    mov     rcx,rdx
    jmp     L1
L4:
    sub     rax,rcx
    mov     rdi,rax
    mov     esi,10h
    call    ryo_hr_DivSW64
    mov     rdx,rax
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
L6:
    ret
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
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    mov     rdx,rax
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
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    mov     rdx,rax
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rcx
    mov     [rsp+28h],rbx
    mov     rdi,rbx
    mov     rsi,r12
    call    fn0
    mov     rcx,[rbx]
    lea     rcx,[rcx+rax]
    mov     [rsp+20h],rcx
    mov     [rsp+28h],rcx
    movzx   edx,byte ptr [rcx]
    shr     r12,39h
    mov     [rsp+20h],r12
    and     r12,7Fh
    mov     [rsp+2Eh],r12b
    mov     [rsp+2Fh],r12b
    mov     rsi,rax
    sub     rsi,10h
    mov     rdi,[rbx+8]
    and     rsi,rdi
    add     rsi,10h
    mov     [rsp+20h],rsi
    mov     [rcx],r12b
    mov     rcx,[rbx]
    lea     rcx,[rcx+rsi]
    mov     [rcx],r12b
    mov     rcx,[rbx]
    mov     [rsp+20h],rcx
    mov     [rsp+28h],rcx
    mov     rcx,[rsp+20h]
    jmp     L2
L0:
    mov     rsi,rdx
    and     esi,1
    mov     [rsp+26h],sil
    cmp     sil,0
    setne   sil
    mov     [rsp+27h],sil
    movzx   esi,sil
    mov     [rsp+28h],rsi
    mov     rdi,[rbx+10h]
    sub     rdi,rsi
    mov     [rbx+10h],rdi
    mov     rsi,[rsp+8]
    mov     [rsp+20h],rsi
    mov     rsi,[rsp+10h]
    mov     [rsp+28h],rsi
    jmp     L5
L1:
    mov     r12,rsi
    jmp     L0
L2:
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     r11,rax
    imul    r11,10h
    add     r11,rcx
    mov     rcx,r11
    mov     rsi,rcx
    jmp     L1
L3:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0
    mov     ecx,0FFFFFFD0h
    call    ryo_h_StoreW128
    mov     rax,[rbx+18h]
    add     rax,1
    mov     [rbx+18h],rax
    mov     rax,r12
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    add     rsp,58h
    ret
L4:
    jmp     L3
L5:
    mov     rax,r12
    lea     rax,[rax-10h]
    jmp     L4
    jmp     L7
L6:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
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
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rsi]
    jmp     L3
L0:
    mov     rax,rsi
    add     rsp,18h
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
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn0.slot]
    mov     rsi,rax
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
    .long   L9
L6:
    mov     rdi,rax
    call    fn2
    jmp     L0
L7:
    jmp     L6
L8:
    lea     rbx,[rbx-20h]
    mov     rax,rbx
    jmp     L7
L9:
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
L12:
    ret
L13:
    ret
L14:
    ret
L15:
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
    jmp     L6
L16:
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
    sub     rsp,98h
    mov     [rsp+20h],rbx
    mov     [rsp+30h],rsi
    mov     rax,[rdi+8]
    and     rsi,rax
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rsi
    mov     qword ptr [rsp+48h],0
    mov     rbx,rdi
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rbx]
    mov     [rsp+10h],rcx
    mov     [rsp+18h],rcx
    lea     rcx,[rcx+rax]
    lea     rax,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    jmp     L3
L1:
    cmp     rax,1
    je      L4
    jmp     L5
L2:
    mov     rbx,[rsp+20h]
    add     rsp,98h
    ret
L3:
    mov     rsi,[rsp+10h]
    mov     [rsp+30h],rsi
    mov     rsi,[rsp+18h]
    mov     [rsp+38h],rsi
    lea     rsi,[rsp+30h]
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+40h]
    mov     [rsp+10h],rdi
    mov     rdx,rdi
    mov     rdi,rbx
    call    qword ptr [fn1.slot]
    mov     rsi,rax
    mov     rdi,rdx
    mov     rax,rsi
    mov     rcx,rdi
    mov     rdx,rbx
    jmp     L1
L4:
    mov     [rsp+18h],rcx
    mov     rdi,rdx
    mov     rsi,rcx
    call    qword ptr [fn2.slot]
    jmp     L2
L5:
    mov     rax,[rdx+8]
    mov     [rsp+18h],rax
    mov     rcx,[rsp+48h]
    add     rcx,10h
    mov     [rsp+48h],rcx
    mov     [rsp+10h],rcx
    mov     rsi,[rsp+40h]
    add     rsi,rcx
    mov     [rsp+40h],rsi
    and     rsi,rax
    mov     [rsp+40h],rsi
    mov     rbx,rdx
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
    lea     rsp,[rdx-0A0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     [rdx-70h],rbx
    mov     rbx,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L0
L8:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-0B0h]
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

fn hashbrown::raw::RawTableInner::fix_insert_index
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+28h],rsi
    mov     rax,[rdi]
    lea     rax,[rax+rsi]
    mov     [rsp+20h],rax
    movzx   eax,byte ptr [rax]
    and     eax,80h
    cmp     al,0
    je      L1
    jmp     L2
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
    mov     rax,rsi
    jmp     L0
L3:
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [sym1]
    mov     rbx,rax
    mov     rdi,rbx
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
    lea     r11,[L4]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L4:
    .long   L7
    .long   L6
    .long   L9
L5:
    mov     r11,[rsp+20h]
    mov     rax,[rsp+28h]
    jmp     L0
L6:
    mov     rdi,rbx
    call    ryo_hr_CttzW16
    jmp     L8
L7:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L5
L8:
    mov     eax,eax
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    jmp     L5
L9:
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
    sub     rsp,368h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rax,[rsp+378h]
    mov     rcx,[rsp+370h]
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rax
    lea     rsi,[rsp+180h]
    mov     rdi,rsi
    mov     rsi,r12
    mov     r8,rdx
    mov     rdx,rcx
    mov     rcx,rax
    movzx   r9d,r9b
    call    qword ptr [fn0.slot]
    jmp     L5
L0:
    lea     rax,[rsp+210h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+220h]
    mov     [rsp+1F0h],rax
    cmp     rax,0
    je      L9
    jmp     L10
L1:
    mov     rax,[rsp+208h]
    mov     [rsp+1F0h],rax
    mov     [rsp+1D8h],r15
    mov     [rsp+1E0h],rax
    mov     rcx,[rbp+28h]
    mov     rdi,[rsp+10h]
    mov     rsi,r15
    mov     rdx,rax
    mov     rax,rcx
    call    rax
    mov     [rsp+1E8h],rax
    jmp     L3
L2:
    mov     rax,[r15+18h]
    mov     [rsp+228h],rax
    mov     rcx,[rsp+258h]
    sub     rcx,rax
    mov     [rsp+258h],rcx
    mov     rax,[r15+18h]
    mov     [rsp+228h],rax
    mov     [rsp+260h],rax
    mov     [rsp+228h],r15
    lea     rax,[rsp+248h]
    mov     [rsp+220h],rax
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFDB0h
    mov     edx,0FFFFFEC8h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     qword ptr [rsp],20h
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFCA0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFEC0h
    mov     edx,0
    mov     ecx,0FFFFFDB0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    jmp     L13
L3:
    lea     rax,[rsp+248h]
    mov     [rsp+1E0h],rax
    mov     rcx,[rsp+1E8h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    jmp     L12
L4:
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rax,rcx
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,368h
    ret
L5:
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFCA0h
    mov     edx,0FFFFFE20h
    mov     ecx,0
    mov     r8d,1
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     ecx,[rsp]
    mov     ecx,ecx
    mov     [rsp+0A8h],rcx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFD48h
    mov     edx,0
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    mov     rcx,rax
    mov     r10,rcx
    lea     r11,[L6]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L6:
    .long   L8
    .long   L7
    .long   L14
L7:
    mov     rcx,[rsp+188h]
    mov     [rsp+98h],rcx
    mov     rdx,[rsp+190h]
    mov     [rsp+0A0h],rdx
    mov     [rsp+88h],rcx
    mov     [rsp+90h],rdx
    mov     [rsp+1A8h],rcx
    mov     [rsp+1B0h],rdx
    mov     qword ptr [rsp+1A0h],0
    mov     [rsp+190h],rcx
    mov     [rsp+198h],rdx
    mov     qword ptr [rsp+188h],1
    mov     byte ptr [rsp+187h],1
    mov     [rsp+0A0h],rcx
    mov     [rsp+0A8h],rdx
    mov     [rsp+1C8h],rcx
    mov     [rsp+1D0h],rdx
    mov     qword ptr [rsp+1C0h],0
    mov     [rsp+1B0h],rcx
    mov     [rsp+1B8h],rdx
    mov     [rsp+1A0h],rcx
    mov     [rsp+1A8h],rdx
    mov     [rsp+200h],rcx
    mov     [rsp+208h],rdx
    mov     qword ptr [rsp+1F8h],0
    mov     [rsp+1E8h],rcx
    mov     [rsp+1F0h],rdx
    mov     qword ptr [rsp+1E0h],1
    mov     byte ptr [rsp+1CFh],1
    mov     [rsp+1D0h],rcx
    mov     [rsp+1D8h],rdx
    mov     [rsp+20h],rcx
    mov     [rsp+28h],rdx
    jmp     L4
L8:
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFD28h
    mov     edx,0FFFFFE20h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD28h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFD00h
    mov     edx,0FFFFFE40h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+98h],r12
    mov     rcx,[rsp+30h]
    mov     [rsp+0A0h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+0A8h],rcx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFD38h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE40h
    mov     edx,0FFFFFD00h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE28h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE98h
    mov     edx,0FFFFFE28h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE60h
    mov     edx,0FFFFFE98h
    mov     ecx,38h
    call    ryo_h_Copy
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFE60h
    mov     ecx,38h
    call    ryo_h_Copy
    mov     rcx,[rbx]
    mov     [rsp+208h],rcx
    mov     [rsp+210h],rcx
    mov     [rsp+228h],rcx
    mov     [rsp+218h],rcx
    mov     [rsp+200h],rcx
    lea     rdx,[rsp+1F0h]
    mov     rdi,rdx
    mov     rsi,rcx
    call    qword ptr [sym3]
    mov     rcx,[rsp+1F0h]
    mov     [rsp+120h],rcx
    mov     rcx,[rsp+1F8h]
    mov     [rsp+128h],rcx
    lea     rcx,[rsp+120h]
    mov     rdi,rcx
    call    qword ptr [sym4]
    mov     rcx,rax
    mov     [rsp+21Ch],ecx
    mov     ecx,[rsp+21Ch]
    mov     [rsp+220h],cx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFEC2h
    mov     edx,0FFFFFEC0h
    call    ryo_h_NotW16
    movzx   ecx,word ptr [rsp+222h]
    mov     [rsp+224h],cx
    mov     [rsp+226h],cx
    mov     rdx,[rbx+18h]
    mov     [rsp+218h],rdx
    mov     [rsp+58h],cx
    mov     qword ptr [rsp+48h],0
    mov     rcx,[rsp+208h]
    mov     [rsp+40h],rcx
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFCE0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     r15,rbx
    mov     rbp,r14
    mov     [rsp+10h],r13
    jmp     L0
L9:
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    jmp     L2
L10:
    mov     rcx,[rsp+1F8h]
    mov     rdi,rcx
    call    fn6
    mov     rcx,rax
    mov     [rsp+200h],rcx
    mov     [rsp+208h],rdx
    mov     rcx,[rsp+1F8h]
    mov     rdx,[rcx+10h]
    sub     rdx,1
    mov     [rsp+120h],rdx
    mov     [rcx+10h],rdx
    mov     rcx,[rsp+200h]
    mov     rdi,rcx
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     rcx,rax
    mov     r10,rcx
    lea     r11,[L11]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L11:
    .long   L2
    .long   L1
    .long   L14
L12:
    mov     rcx,[rsp+248h]
    mov     [rsp+1C8h],rcx
    mov     [rsp+1D0h],rcx
    lea     rdx,[rcx+rax]
    mov     [rsp+1D8h],rdx
    mov     [rsp+1E0h],rdx
    movzx   esi,byte ptr [rdx]
    mov     [rsp+1B7h],sil
    mov     rsi,[rsp+1E8h]
    shr     rsi,39h
    mov     [rsp+1D8h],rsi
    and     rsi,7Fh
    mov     [rsp+1D0h],rsi
    mov     [rsp+1E6h],sil
    mov     [rsp+1E7h],sil
    mov     rdi,rax
    sub     rdi,10h
    mov     [rsp+1C8h],rdi
    mov     r8,[rsp+250h]
    mov     [rsp+1C0h],r8
    and     rdi,r8
    mov     [rsp+1D0h],rdi
    add     rdi,10h
    mov     [rsp+1D8h],rdi
    mov     [rsp+1B8h],rcx
    mov     [rsp+1C0h],rcx
    mov     [rsp+1C8h],rdx
    mov     [rsp+1D0h],rdx
    mov     [rdx],sil
    mov     rcx,[rsp+248h]
    mov     [rsp+1B8h],rcx
    mov     [rsp+1C0h],rcx
    mov     rdx,[rsp+1D8h]
    lea     rcx,[rcx+rdx]
    mov     [rsp+1C8h],rcx
    mov     [rsp+1D0h],rcx
    movzx   edx,byte ptr [rsp+1E7h]
    mov     [rcx],dl
    mov     rcx,[rsp+30h]
    mov     rdx,[r15]
    mov     [rsp+1B8h],rdx
    mov     [rsp+1D0h],rdx
    mov     rsi,[rsp+1F0h]
    add     rsi,1
    mov     [rsp+1C0h],rsi
    imul    rsi,rcx
    mov     [rsp+1C8h],rsi
    mov     [rsp+1B0h],rsi
    mov     r11d,0
    sub     r11,rsi
    mov     rsi,r11
    mov     [rsp+1C0h],rsi
    lea     rdx,[rdx+rsi]
    mov     [rsp+1D8h],rdx
    mov     [rsp+1E0h],rdx
    mov     rdx,[rsp+248h]
    mov     [rsp+1B8h],rdx
    mov     [rsp+1D0h],rdx
    add     rax,1
    mov     [rsp+1C0h],rax
    imul    rax,rcx
    mov     [rsp+1C8h],rax
    mov     [rsp+1B0h],rax
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+1C0h],rax
    lea     rdx,[rdx+rax]
    mov     [rsp+1D8h],rdx
    mov     [rsp],rcx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFE78h
    mov     edx,0FFFFFE80h
    mov     ecx,0FFFFFCA0h
    call    ryo_h_Memcpy
    jmp     L0
L13:
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFCC0h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rax,[rsp+230h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L4
L14:
    ud2
    mov     rbx,rax
    jmp     L18
    mov     rbx,rax
    jmp     L18
L15:
    lea     rax,[rsp+230h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L16
    jmp     L17
L16:
    mov     [rsp],rbx
    lea     rdi,[rsp+360h]
    mov     esi,0FFFFFCA0h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L18
    mov     rbx,rax
    jmp     L18
    mov     rbx,rax
    jmp     L18
L17:
    call    qword ptr [sym9]
    ud2
L18:
    jmp     L15
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
L20:
    ret
L21:
    pop     rcx
    lea     rdx,[rsp+260h]
    lea     rsp,[rdx-400h]
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
    mov     r11,[rsp+10h]
    mov     [rdx-350h],r11
    mov     r15,[rsp]
    mov     rbp,[rsp+8]
    lea     rsp,[rsp+0A0h]
    jmp     L0
L22:
    ret
L23:
    ret
L24:
    ret
L25:
    ret

fn hashbrown::rustc_entry::<impl hashbrown::map::HashMap<std::string::String, usize, std::hash::RandomState>>::rustc_entry
    sub     rsp,0C8h
    mov     [rsp+0B0h],rbx
    mov     [rsp+0A0h],r12
    mov     [rsp+90h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF40h
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFFB0h
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
    .long   L9
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+68h],rax
    mov     [rsp+50h],r12
    mov     [rsp+58h],rax
    mov     [rsp+60h],r12
    mov     [rsp+10h],rax
    mov     [rsp+18h],r12
    mov     qword ptr [rsp+8],0FFFFFFFFFFFFFFFFh
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,0
    mov     ecx,0FFFFFF48h
    mov     r8d,28h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+0B0h]
    mov     r12,[rsp+0A0h]
    mov     r13,[rsp+90h]
    add     rsp,0C8h
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
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF78h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp+70h],r13
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp+68h],r12
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFF90h
    mov     ecx,28h
    call    ryo_h_Copy
    jmp     L4
    mov     rbx,rax
    jmp     L11
    mov     rbx,rax
    jmp     L11
L7:
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L8
    jmp     L10
L8:
    mov     [rsp],rbx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L11
L9:
    ud2
L10:
    call    qword ptr [sym5]
    ud2
L11:
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
    .long   L16
L13:
    ret
L14:
    ret
L15:
    ret
L16:
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
    sub     rsp,6D8h
    mov     [rsp+170h],rbx
    mov     [rsp+160h],r12
    mov     [rsp+150h],r13
    mov     [rsp+140h],r14
    mov     [rsp+130h],r15
    mov     qword ptr [rsp+198h],50910h
    mov     edi,50910h
    call    qword ptr [fn0.slot]
    mov     rbx,rax
    lea     rax,[rsp+698h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     edi,0
    mov     rsi,rbx
    call    qword ptr [fn2.slot]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     [rsp+660h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+668h],rax
    mov     ebx,1
L0:
    lea     rax,[rsp+660h]
    mov     rdi,rax
    call    fn3
    mov     r12,rdx
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
    .long   L2
    .long   L20
L2:
    mov     r10,5851F42D4C957F2Dh
    mov     [rsp+198h],r10
    mov     rdi,rbx
    mov     rsi,5851F42D4C957F2Dh
    call    fn4
    jmp     L4
L3:
    mov     qword ptr [rsp+28h],0
    mov     qword ptr [rsp+30h],0
    mov     dword ptr [rsp+19Ch],14h
    jmp     L5
L4:
    mov     r10,14057B7EF767814Fh
    mov     [rsp+198h],r10
    mov     rdi,rax
    mov     rsi,14057B7EF767814Fh
    call    fn7
    mov     rbx,rax
    lea     rax,[rsp+698h]
    mov     dword ptr [rsp+19Ch],2Ch
    mov     rcx,rbx
    shr     rcx,2Ch
    lea     rdx,[rsp+600h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn10
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFF30h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     qword ptr [rsp+180h],0
    lea     rax,[rsp+188h]
    mov     rdi,rax
    mov     esi,0
    call    fn11
    mov     rcx,[rax]
    mov     [rsp+198h],rcx
    add     rcx,r12
    jb      L21
    mov     [rax],rcx
    jmp     L0
L5:
    mov     qword ptr [rsp+198h],1
    mov     qword ptr [rsp+198h],2
    lea     rax,[rsp+580h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,100000h
    mov     ecx,2
    call    qword ptr [fn14.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAB0h
    mov     edx,0FFFFFEB0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rax,[rsp+5A0h]
    lea     rcx,[rsp+180h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn15.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFED0h
    mov     ecx,20h
    call    ryo_h_Copy
L6:
    lea     rax,[rsp+540h]
    mov     rdi,rax
    call    qword ptr [fn16.slot]
    mov     rbx,rdx
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L7]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L7:
    .long   L9
    .long   L8
    .long   L20
L8:
    mov     [rsp+518h],rbx
    lea     rax,[rsp+698h]
    lea     rcx,[rsp+518h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn17.slot]
    mov     rbx,rax
    jmp     L10
L9:
    lea     rax,[rsp+698h]
    mov     rdi,rax
    call    qword ptr [fn18.slot]
    mov     [rsp+40h],rax
    jmp     L13
L10:
    mov     [rsp],rbx
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFACCh
    mov     edx,0FFFFF930h
    mov     ecx,0
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp+19Ch]
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L11]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L11:
    .long   L6
    .long   L12
    .long   L20
L12:
    mov     qword ptr [rsp+198h],1
    mov     rax,[rsp+28h]
    add     rax,1
    jb      L23
    mov     [rsp+28h],rax
    mov     rax,[rsp+30h]
    mov     rcx,[rbx]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn7
    mov     [rsp+30h],rax
    jmp     L6
L13:
    lea     rax,[rsp+698h]
    mov     rdi,rax
    call    qword ptr [fn22.slot]
    lea     rax,[rsp+698h]
    lea     rcx,[rsp+480h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn23.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFDB0h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+178h]
    mov     rdi,rax
    mov     esi,0
    call    qword ptr [fn24.slot]
    mov     [rsp+48h],rax
    lea     rax,[rsp+448h]
    mov     rdi,rax
    call    qword ptr [fn25.slot]
    mov     edi,0
    mov     esi,1FBD0h
    mov     edi,edi
    mov     esi,esi
    call    qword ptr [fn26.slot]
    mov     [rsp+50h],eax
    mov     [rsp+54h],edx
    mov     rax,[rsp+50h]
    mov     [rsp+430h],rax
L14:
    lea     rax,[rsp+430h]
    mov     rdi,rax
    call    qword ptr [fn27.slot]
    mov     rbx,rdx
    mov     eax,eax
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L15]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L15:
    .long   L17
    .long   L16
    .long   L20
L16:
    lea     r12,[rsp+448h]
    mov     dword ptr [rsp+19Ch],138Bh
    jmp     L18
L17:
    lea     rax,[rsp+698h]
    mov     rdi,rax
    call    qword ptr [fn18.slot]
    mov     [rsp+60h],rax
    jmp     L19
L18:
    mov     dword ptr [rsp+19Ch],138Bh
    mov     [rsp],rbx
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFF930h
    mov     ecx,0FFFFFACCh
    call    ryo_h_RemUW32
    lea     rax,[rsp+384h]
    lea     rcx,[rsp+360h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn31.slot]
    mov     rax,[rsp+360h]
    mov     [rsp+370h],rax
    mov     rax,[rsp+368h]
    mov     [rsp+378h],rax
    lea     rax,[k32]
    lea     rcx,[rsp+370h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn33.slot]
    lea     rcx,[rsp+3A8h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn34.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCD8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+3C0h]
    lea     rcx,[rsp+188h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn35.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAB8h
    mov     edx,0FFFFFCF0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+3E0h]
    lea     rcx,[rsp+188h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,rcx
    call    qword ptr [fn36.slot]
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFFAA8h
    mov     edx,0FFFFFD10h
    mov     ecx,28h
    call    ryo_h_Copy
    lea     rax,[rsp+178h]
    mov     rdi,rax
    call    qword ptr [fn37.slot]
    mov     rcx,[rax]
    mov     [rsp+198h],rcx
    mov     qword ptr [rsp+190h],1
    add     rcx,1
    jb      L25
    mov     [rax],rcx
    jmp     L14
L19:
    lea     rbx,[rsp+60h]
    lea     rax,[rsp+448h]
    mov     rdi,rax
    call    qword ptr [fn40.slot]
    mov     [rsp+68h],rax
    lea     r12,[rsp+68h]
    lea     rax,[rsp+40h]
    lea     r13,[rsp+28h]
    lea     r14,[rsp+30h]
    lea     r15,[rsp+48h]
    lea     rcx,[rsp+0D0h]
    mov     rdi,rcx
    mov     rsi,rax
    call    qword ptr [fn41.slot]
    lea     rax,[rsp+0E0h]
    mov     rdi,rax
    mov     rsi,r13
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+0F0h]
    mov     rdi,rax
    mov     rsi,r14
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+100h]
    mov     rdi,rax
    mov     rsi,rbx
    call    qword ptr [fn41.slot]
    lea     rax,[rsp+110h]
    mov     rdi,rax
    mov     rsi,r15
    call    qword ptr [fn42.slot]
    lea     rax,[rsp+120h]
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn41.slot]
    mov     rax,[rsp+0D0h]
    mov     [rsp+70h],rax
    mov     rax,[rsp+0D8h]
    mov     [rsp+78h],rax
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
    lea     rax,[k47]
    lea     rcx,[rsp+70h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn48.slot]
    mov     rdi,rax
    mov     rsi,rdx
    call    qword ptr [sym49]
    lea     rax,[rsp+448h]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [fn50.slot]
    lea     rax,[rsp+698h]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [fn51.slot]
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+160h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+140h]
    mov     r15,[rsp+130h]
    add     rsp,6D8h
    ret
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
L20:
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
L21:
    lea     rax,[k12]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L22
    mov     r12,rax
    jmp     L28
L22:
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
L23:
    lea     rax,[k19]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L24
    mov     r12,rax
    jmp     L28
L24:
    ud2
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     r12,rax
    jmp     L28
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
L25:
    lea     rax,[k38]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [sym13]
    jmp     L26
    mov     rbx,rax
    jmp     L31
L26:
    ud2
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     rbx,rax
    jmp     L31
    mov     r12,rax
    jmp     L28
L27:
    lea     rax,[rsp+448h]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [fn50.slot]
    mov     r12,rbx
    jmp     L28
    jmp     L30
L28:
    lea     rax,[rsp+698h]
    mov     [rsp+198h],rax
    mov     rdi,rax
    call    qword ptr [fn51.slot]
    jmp     L29
    jmp     L30
L29:
    mov     [rsp],r12
    lea     rdi,[rsp+6D0h]
    mov     esi,0FFFFF930h
    call    ryo_h_Resume
    ud2
L30:
    call    qword ptr [sym54]
    ud2
L31:
    jmp     L27
  ; OSR entries
    lea     r11,[L32]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L32:
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
    .long   L38
    .long   L39
L33:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7E0h]
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
    jmp     L0
L34:
    ret
L35:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7E0h]
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
    jmp     L6
L36:
    pop     rcx
    lea     rdx,[rsp+560h]
    lea     rsp,[rdx-7E0h]
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
    jmp     L14
L37:
    ret
L38:
    ret
L39:
    ret

fn main::{closure#0}
    sub     rsp,18h
    lea     rax,[k0]
    mov     rdi,rsi
    mov     esi,3
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    cmp     rax,0
    setne   al
    movzx   eax,al
    add     rsp,18h
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
    call    fn0
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
    int3
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
    call    qword ptr [fn0.slot]
    mov     rbx,rax
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
    call    fn1
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
    mov     eax,1
    jmp     L19
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
    call    qword ptr [fn2.slot]
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
    call    fn0
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
    mov     rax,rdx
    and     rax,1
    cmp     rax,1
    je      L1
    jmp     L2
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
    mov     r12,[rsp+28h]
    mov     r13,rdx
    shr     r13,1
    jmp     L4
L2:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF98h
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
    lea     rax,[k2]
    mov     rdi,r12
    mov     esi,1
    mov     edx,1
    mov     rcx,r13
    mov     r8,rax
    call    qword ptr [fn3.slot]
    mov     [rsp+58h],r12
    mov     [rsp+60h],r13
    mov     [rsp+48h],r12
    mov     [rsp+50h],r13
    mov     [rsp+38h],r12
    mov     [rsp+40h],r13
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     rbx,rdi
    mov     rax,[rbx+10h]
    mov     r12,rax
    add     r12,1
    mov     rdi,r12
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
    lea     r11,[L0]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L0:
    .long   L6
    .long   L4
    .long   L5
L1:
    mov     rcx,[rbx]
    mov     rdx,rcx
    add     rdx,r12
    mov     [rbx],rdx
    mov     rdx,rax
    sub     rdx,1
    mov     [rbx+8],rdx
    mov     [rsp+18h],rcx
    mov     qword ptr [rsp+10h],1
    jmp     L3
L2:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L3:
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rax,rcx
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    add     rsp,48h
    ret
L4:
    mov     rax,[rbx+8]
    cmp     rax,0
    ja      L1
    jmp     L2
L5:
    ud2
L6:
    lea     rax,[k1]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
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
    .long   L1
    .long   L2
    .long   L4
L1:
    mov     [rsp+48h],r12
    lea     rax,[rsp+8]
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+40h],rax
    mov     rcx,[rsp+30h]
    mov     [rsp+48h],rcx
    mov     [rsp+50h],rax
    mov     [rsp+58h],rcx
    lea     rdx,[rsp+8]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [fn1.slot]
L3:
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
L4:
    ud2
    mov     ecx,1
    jmp     L8
    mov     ecx,0
    jmp     L8
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    lea     rax,[k0]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,1
    mov     ecx,1
    mov     r8,r13
    mov     r9,rax
    call    fn1
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
    mov     rdi,rbx
    mov     rsi,r14
    call    fn0
    jmp     L6
L2:
    mov     rdi,r12
    mov     rsi,r14
    call    fn0
    mov     rcx,rax
    jmp     L8
L3:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,r15
    call    qword ptr [fn2.slot]
    mov     rdx,rax
    jmp     L9
L4:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L5:
    test    bpl,bpl
    jne     L2
    cmp     rbx,0
    je      L10
    jmp     L2
L6:
    test    al,al
    jne     L5
    jmp     L11
L7:
    test    bpl,bpl
    jne     L3
    cmp     r12,0
    je      L10
    jmp     L3
L8:
    test    cl,cl
    jne     L7
    jmp     L12
L9:
    test    dl,dl
    jne     L4
    jmp     L10
    jmp     L13
    jmp     L13
    jmp     L13
L10:
    lea     rax,[k3]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [sym5]
    ud2
L11:
    jmp     L10
L12:
    jmp     L10
L13:
    call    qword ptr [sym6]
    ud2
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
L24:
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
    mov     rbx,rdi
    mov     rdi,rbx
    call    qword ptr [sym0]
    jmp     L1
L0:
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
L1:
    mov     rdi,rbx
    call    qword ptr [fn1.slot]
    jmp     L0
    mov     [rsp+10h],rax
    jmp     L3
L2:
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L3:
    mov     rdi,rbx
    call    qword ptr [fn1.slot]
    jmp     L2
    call    qword ptr [sym3]
    ud2
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
L5:
    ret
L6:
    ret
L7:
    ret
L8:
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

