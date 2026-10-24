fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     [rsp+8],rsi
    lea     rax,[rsp+8]
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    jmp     L0
    mov     rbx,rax
    jmp     L2
L0:
    mov     rdi,rax
    call    ryo_hr_ZextW8W64
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L1:
    mov     [rsp],rbx
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
L2:
    jmp     L1
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    sub     rsp,0B8h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+40h],rdx
    jmp     L0
    cmp     r12,0
    sete    al
    jmp     L1
L0:
    cmp     rbx,r12
    sete    al
L1:
    test    al,al
    je      L2
    mov     rax,[rsp+40h]
    jmp     L10
L2:
    mov     r13,[rsp+40h]
    jmp     L3
    mov     rax,r13
    mov     r14,rbx
    mov     r15d,0
    mov     [rsp+38h],r12
    mov     qword ptr [rsp+10h],0
    jmp     L5
L3:
    jmp     L4
L4:
    jmp     L18
L5:
    lea     rcx,[rsp+40h]
    lea     rdx,[r14+r15]
    mov     rdi,rcx
    mov     rsi,rax
    call    fn0
    mov     [rsp+18h],rax
    jmp     L6
    mov     qword ptr [rsp+30h],0
    mov     r11,[rsp+10h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],rax
    jmp     L22
L6:
    jmp     L7
L7:
    jmp     L21
L8:
    mov     rax,[rsp+18h]
    jmp     L10
L9:
    mov     r14,rcx
    mov     r15,rdx
    mov     [rsp+38h],rsi
    mov     [rsp+10h],rdi
    jmp     L5
L10:
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,0B8h
    ret
L11:
    jmp     L16
L12:
    mov     r11,[rsp+28h]
    mov     [rsp],r11
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
L13:
    jmp     L11
L14:
    cmp     byte ptr [rsp+30h],0
    je      L11
    jmp     L13
L15:
    jmp     L12
L16:
    cmp     byte ptr [rsp+20h],0
    je      L12
    jmp     L15
L17:
    mov     rax,r13
    mov     r14,rbx
    mov     r15d,0
    mov     [rsp+38h],rbp
    mov     qword ptr [rsp+10h],0
    jmp     L5
L18:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rax
    call    qword ptr [fn2.slot]
    mov     r11d,0
    cmp     r11,1
    jae     L19
    mov     r11d,1
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L19
    mov     rbp,r12
    sub     rbp,rbx
    jmp     L17
L19:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rbx,rax
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym5]
    jmp     L20
    mov     qword ptr [rsp+30h],1
    mov     qword ptr [rsp+20h],0
    mov     [rsp+28h],rax
    jmp     L22
L20:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L21:
    lea     rdi,[k6]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     esi,1
    mov     rdx,rax
    call    fn7
    add     r15,1
    cmp     r15,[rsp+38h]
    je      L8
    mov     rax,[rsp+18h]
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,[rsp+38h]
    mov     rdi,[rsp+10h]
    jmp     L9
L22:
    jmp     L14
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
    .long   L32
L24:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-70h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-78h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A0h],r11
    mov     rax,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L5
L25:
    ret
L26:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-4Ah]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-70h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L9
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     rdi,rsi
    mov     rsi,rax
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     rdi,rsi
    mov     rsi,rax
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rdi,rsi
    mov     rsi,rdx
    call    ryo_hr_AddOvfUW64
    mov     rbx,rax
    test    dl,dl
    je      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,rbx
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    cmp     rbx,rdx
    jb      L0
    mov     rdi,rbx
    mov     rsi,rdx
    mov     rdx,rcx
    call    qword ptr [sym0]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    lea     r12,[r12+rbx]
    mov     rax,r12
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    cmp     rbx,rdx
    jb      L0
    mov     rdi,rbx
    mov     rsi,rdx
    mov     rdx,rcx
    call    qword ptr [sym0]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    lea     r12,[r12+rbx]
    mov     rax,r12
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
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
    mov     eax,0BAh
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

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rsi]
    movzx   eax,byte ptr [rax]
    movzx   eax,al
    add     rsp,18h
    ret

fn sieve
    sub     rsp,0B8h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    mov     esi,1
    call    ryo_hr_AddOvfUW64
    mov     r13,rax
    test    dl,dl
    je      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L0:
    lea     rax,[rsp+78h]
    mov     rdi,rax
    mov     esi,1
    mov     rdx,r13
    movzx   esi,sil
    call    qword ptr [fn2.slot]
    lea     r13,[rsp+78h]
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     esi,0
    mov     rdx,rax
    call    fn4
    jmp     L1
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L24
L1:
    mov     byte ptr [rax],0
    lea     r13,[rsp+78h]
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     esi,1
    mov     rdx,rax
    call    fn4
    jmp     L2
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L24
L2:
    mov     byte ptr [rax],0
    mov     r13,rbx
    mov     ebx,2
L3:
    mov     rdi,rbx
    mov     rsi,rbx
    call    ryo_hr_MulOvfUW64
    mov     r14,rax
    test    dl,dl
    je      L5
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L4
    mov     rbx,rax
    jmp     L24
L4:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L5:
    cmp     r12,r14
    jb      L20
    lea     r14,[rsp+78h]
    lea     rdi,[k9]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    qword ptr [fn10.slot]
    jmp     L6
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L24
L6:
    movzx   eax,byte ptr [rax]
    test    al,al
    jne     L8
    jmp     L7
L7:
    mov     r14,r13
    jmp     L17
L8:
    mov     rdi,rbx
    mov     rsi,rbx
    call    ryo_hr_MulOvfUW64
    mov     r14,rax
    test    dl,dl
    je      L10
    lea     rdi,[k11]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L9
    mov     rbx,rax
    jmp     L24
L9:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     r15,r13
L11:
    cmp     r12,r14
    jb      L12
    jmp     L13
L12:
    mov     r14,r15
    jmp     L17
L13:
    lea     rbp,[rsp+78h]
    lea     rdi,[k13]
    call    ryo_hr_AddrAbs
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,rax
    call    fn4
    jmp     L14
    mov     rcx,rax
    mov     rbx,rcx
    jmp     L24
L14:
    mov     byte ptr [rax],0
    mov     rdi,r14
    mov     rsi,rbx
    call    ryo_hr_AddOvfUW64
    mov     r14,rax
    test    dl,dl
    je      L16
    lea     rdi,[k15]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L15
    mov     rbx,rax
    jmp     L24
L15:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L16:
    jmp     L11
L17:
    mov     rdi,rbx
    mov     esi,1
    call    ryo_hr_AddOvfUW64
    mov     rbx,rax
    test    dl,dl
    je      L19
    lea     rdi,[k17]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L18
    mov     rbx,rax
    jmp     L24
L18:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L19:
    mov     r13,r14
    jmp     L3
L20:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFFC8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp],r13
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0
    mov     ecx,0FFFFFF58h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,r13
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,0B8h
    ret
L21:
    lea     rax,[rsp+78h]
    mov     rdi,rax
    call    qword ptr [fn19.slot]
    jmp     L22
    jmp     L25
L22:
    mov     [rsp],rbx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
L23:
    call    qword ptr [sym20]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L24:
    jmp     L21
L25:
    jmp     L23
  ; OSR entries
    lea     r11,[L26]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L26:
    .long   L27
    .long   L28
    .long   L29
    .long   L30
L27:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-190h]
    mov     r11,[rdx-78h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-150h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-8]
    mov     [rsp+28h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-98h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+0E0h]
    jmp     L3
L28:
    pop     rcx
    lea     rdx,[rsp+160h]
    lea     rsp,[rdx-1A0h]
    mov     r11,[rdx-0D0h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-78h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-8]
    mov     [rsp+30h],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     [rdx-70h],r14
    mov     [rdx-80h],r15
    mov     [rdx-90h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-0A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0A0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-98h],r11
    mov     r14,[rsp]
    mov     r12,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+0F0h]
    jmp     L11
L29:
    ret
L30:
    ret

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    sub     rsp,18h
    movzx   eax,byte ptr [rdi]
    movzx   eax,al
    add     rsp,18h
    ret

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,rbx
    mov     rsi,rdx
    call    qword ptr [fn0.slot]
    jmp     L0
    mov     rcx,rax
    mov     eax,1
    mov     rbx,rcx
    jmp     L5
L0:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    jmp     L1
    mov     rcx,rax
    mov     eax,0
    mov     rbx,rcx
    jmp     L5
L1:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L2:
    mov     [rsp],rbx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
L4:
    test    al,al
    je      L2
    jmp     L3
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

fn std::vec::Vec::<bool>::extend_with
    sub     rsp,0A8h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+8Fh],dl
    mov     rdi,rbx
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    jmp     L0
    mov     rcx,rax
    mov     eax,1
    jmp     L21
L0:
    mov     rax,[rbx+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+20h],rax
    mov     rax,[rbx+10h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+18h]
    lea     rax,[rax+rcx]
    mov     rcx,rbx
    lea     rcx,[rcx+10h]
    mov     rdx,[rbx+10h]
    mov     [rsp+18h],rcx
    mov     [rsp+20h],rdx
    mov     ebx,1
    mov     r13,r12
    mov     r14,rax
    mov     r15d,1
L1:
    cmp     rbx,r12
    jae     L16
    jmp     L14
L2:
    mov     [rax],cl
    mov     r10d,1
    lea     rdx,[rdx+r10]
    mov     rax,[rsp+20h]
    add     rax,1
    mov     [rsp+20h],rax
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,r8
    mov     r14,rdx
    mov     r15,r9
    jmp     L1
L3:
    movzx   eax,byte ptr [rsp+8Fh]
    mov     [r14],al
    mov     rax,[rsp+20h]
    add     rax,1
    mov     [rsp+20h],rax
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L4
    mov     rcx,rax
    mov     eax,0
    jmp     L21
L4:
    jmp     L19
L5:
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L6
    mov     rcx,rax
    mov     rax,r15
    jmp     L21
L6:
    test    r15b,r15b
    jne     L11
L7:
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,0A8h
    ret
L8:
    lea     rax,[rsp+18h]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L9
    jmp     L22
L9:
    mov     rax,r15
    mov     rbp,[rsp+10h]
    jmp     L13
L10:
    mov     [rsp],rbp
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
L11:
    jmp     L7
L12:
    jmp     L10
L13:
    test    al,al
    je      L10
    jmp     L12
L14:
    jmp     L15
L15:
    jmp     L17
L16:
    cmp     r13,0
    ja      L3
    jmp     L5
L17:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,1
    mov     rdx,rax
    call    fn5
    add     rbx,1
    lea     rax,[rsp+8Fh]
    mov     rdi,rax
    call    fn6
    jmp     L18
    mov     [rsp+10h],rax
    jmp     L23
L18:
    mov     rcx,rax
    mov     rax,r14
    mov     rdx,r14
    mov     rsi,rbx
    mov     rdi,r12
    mov     r8,r13
    mov     r9,r15
    jmp     L2
L19:
    jmp     L7
L20:
    call    qword ptr [sym7]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L21:
    mov     rbp,rcx
    jmp     L13
L22:
    jmp     L20
L23:
    jmp     L8
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
L25:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-28h]
    mov     [rsp+8],r11
    mov     r11,[rdx-10h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+30h],r11
    mov     [rdx-20h],rbx
    mov     [rdx-30h],r12
    mov     [rdx-40h],r13
    mov     [rdx-50h],r14
    mov     [rdx-60h],r15
    mov     [rdx-70h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-88h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-80h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L1
L26:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-80h]
    mov     [rsp],r11
    movzx   r11d,byte ptr [rdx-81h]
    mov     [rsp+8],r11
    mov     r11,[rdx-20h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    movzx   r11d,byte ptr [rdx-49h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-70h]
    mov     [rsp+40h],r11
    mov     [rdx-20h],rbx
    mov     [rdx-30h],r12
    mov     [rdx-40h],r13
    mov     [rdx-50h],r14
    mov     [rdx-60h],r15
    mov     [rdx-70h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-88h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-80h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     r9,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L2
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

