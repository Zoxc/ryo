fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,18h
    mov     [rsp+8],rsi
    lea     rax,[rsp+8]
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L0]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L0:
    .long   L1
L1:
    ret

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+20h],rdx
    cmp     rbx,r12
    sete    al
    test    al,al
    je      L0
    mov     rax,[rsp+20h]
    jmp     L4
L0:
    mov     r13,[rsp+20h]
    jmp     L6
L1:
    lea     rcx,[rsp+20h]
    lea     rdx,[r14+r15]
    mov     rdi,rcx
    mov     rsi,rax
    call    fn0
    mov     [rsp+18h],rax
    jmp     L7
L2:
    mov     rax,[rsp+18h]
    jmp     L4
L3:
    mov     r14,rcx
    mov     r15,rdx
    mov     rbp,rsi
    mov     [rsp+10h],rdi
    jmp     L1
L4:
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L5:
    mov     r14,rbx
    mov     r15d,0
    mov     rbp,rax
    mov     rax,r13
    mov     qword ptr [rsp+10h],0
    jmp     L1
L6:
    lea     rcx,[k1]
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rcx
    call    qword ptr [fn2.slot]
    mov     rax,r12
    sub     rax,rbx
    jmp     L5
L7:
    lea     rax,[k6]
    mov     rdi,r15
    mov     esi,1
    mov     rdx,rax
    call    fn7
    add     r15,1
    cmp     r15,rbp
    je      L2
    mov     rax,[rsp+18h]
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,rbp
    mov     rdi,[rsp+10h]
    jmp     L3
    mov     edx,0
    mov     rcx,rax
    mov     rax,[rsp+10h]
    jmp     L14
L8:
    jmp     L13
L9:
    mov     [rsp],rcx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
L10:
    jmp     L8
L11:
    test    dl,dl
    jne     L10
    jmp     L8
L12:
    jmp     L9
L13:
    test    al,al
    jne     L12
    jmp     L9
L14:
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
    .long   L19
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
L16:
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
    mov     r11,[rsp+20h]
    mov     [rdx-80h],r11
    mov     rax,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L1
L17:
    ret
L18:
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
    lea     rsp,[rsp+70h]
    jmp     L3
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
    sub     rsp,18h
    add     rsi,rdx
    jb      L0
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    call    qword ptr [sym1]
    ud2

fn <usize as std::slice::SliceIndex<[bool]>>::index
    sub     rsp,18h
    cmp     rdi,rdx
    jae     L0
    lea     rsi,[rsi+rdi]
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    mov     rsi,rdx
    mov     rdx,rcx
    call    qword ptr [sym0]
    ud2

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
    sub     rsp,18h
    cmp     rdi,rdx
    jae     L0
    lea     rsi,[rsi+rdi]
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    mov     rsi,rdx
    mov     rdx,rcx
    call    qword ptr [sym0]
    ud2

fn core::num::<impl usize>::unchecked_add::precondition_check
    sub     rsp,18h
    mov     r11,rdi
    add     r11,rsi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,175h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rsi]
    movzx   eax,byte ptr [rax]
    movzx   eax,al
    add     rsp,18h
    ret

fn sieve
    sub     rsp,0A8h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,r12
    add     rax,1
    jb      L8
    lea     r13,[rsp+68h]
    mov     rdi,r13
    mov     esi,1
    mov     rdx,rax
    movzx   esi,sil
    call    qword ptr [fn2.slot]
    lea     rax,[k3]
    mov     rdi,r13
    mov     esi,0
    mov     rdx,rax
    call    fn4
    mov     byte ptr [rax],0
    lea     rax,[rsp+68h]
    lea     rcx,[k5]
    mov     rdi,rax
    mov     esi,1
    mov     rdx,rcx
    call    fn4
    mov     byte ptr [rax],0
    mov     r13,rbx
    mov     ebx,2
L0:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rbx
    mul     rbx
    mov     rdx,r10
    jb      L9
    cmp     r12,rax
    jb      L7
    lea     rax,[rsp+68h]
    lea     rcx,[k9]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    qword ptr [fn10.slot]
    movzx   eax,byte ptr [rax]
    test    al,al
    jne     L2
    jmp     L1
L1:
    mov     rax,r13
    jmp     L6
L2:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rbx
    mul     rbx
    mov     rdx,r10
    jb      L11
    mov     r14,rbx
    mov     rbx,rax
    mov     r15,r13
L3:
    cmp     r12,rbx
    jb      L4
    jmp     L5
L4:
    mov     rbx,r14
    mov     rax,r15
    jmp     L6
L5:
    lea     rax,[rsp+68h]
    lea     rcx,[k13]
    mov     rdi,rax
    mov     rsi,rbx
    mov     rdx,rcx
    call    fn4
    mov     byte ptr [rax],0
    add     rbx,r14
    jb      L13
    jmp     L3
L6:
    add     rbx,1
    jb      L15
    mov     r13,rax
    jmp     L0
L7:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFC8h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     [rsp],r13
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF68h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,r13
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    add     rsp,0A8h
    ret
L8:
    lea     rax,[k0]
    mov     rdi,rax
    call    qword ptr [sym1]
    ud2
    mov     rbx,rax
    jmp     L20
    mov     rbx,rax
    jmp     L20
L9:
    lea     rax,[k7]
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L10
    mov     rbx,rax
    jmp     L20
L10:
    ud2
    mov     rbx,rax
    jmp     L20
L11:
    lea     rax,[k11]
    mov     rdi,rax
    call    qword ptr [sym8]
    jmp     L12
    mov     rbx,rax
    jmp     L20
L12:
    ud2
    mov     rbx,rax
    jmp     L20
L13:
    lea     rax,[k15]
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L14
    mov     rbx,rax
    jmp     L20
L14:
    ud2
L15:
    lea     rax,[k17]
    mov     rdi,rax
    call    qword ptr [sym1]
    jmp     L16
    mov     rbx,rax
    jmp     L20
L16:
    ud2
L17:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [fn19.slot]
    jmp     L18
    jmp     L19
L18:
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
L19:
    call    qword ptr [sym20]
    ud2
L20:
    jmp     L17
  ; OSR entries
    lea     r11,[L21]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L21:
    .long   L22
    .long   L23
    .long   L24
    .long   L25
L22:
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
    mov     r11,[rsp+18h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-90h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-88h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+0F0h]
    jmp     L0
L23:
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
    mov     r11,[rsp+20h]
    mov     [rdx-98h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-90h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-88h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+100h]
    jmp     L3
L24:
    ret
L25:
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
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    call    qword ptr [fn1.slot]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
    mov     ecx,1
    jmp     L3
    mov     ecx,0
    jmp     L3
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
L1:
    jmp     L0
L2:
    test    cl,cl
    jne     L1
    jmp     L0
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

fn std::vec::Vec::<bool>::extend_with
    sub     rsp,88h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+6Fh],dl
    mov     rdi,rbx
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    mov     rax,[rbx+8]
    mov     [rsp+8],rax
    mov     [rsp+10h],rax
    mov     rcx,[rbx+10h]
    mov     [rsp+8],rcx
    lea     rax,[rax+rcx]
    mov     rcx,rbx
    lea     rcx,[rcx+10h]
    mov     rdx,[rbx+10h]
    mov     [rsp+8],rcx
    mov     [rsp+10h],rdx
    mov     ebx,1
    mov     r13,r12
    mov     r14,rax
    mov     r15d,1
L0:
    cmp     rbx,r12
    jb      L6
    jmp     L5
L1:
    mov     [rax],cl
    lea     rdx,[rdx+1]
    mov     rax,[rsp+10h]
    add     rax,1
    mov     [rsp+10h],rax
    mov     rbx,rsi
    mov     r12,rdi
    mov     r13,r8
    mov     r14,rdx
    mov     r15,r9
    jmp     L0
L2:
    movzx   eax,byte ptr [rsp+6Fh]
    mov     [r14],al
    mov     rax,[rsp+10h]
    add     rax,1
    mov     [rsp+10h],rax
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    jmp     L4
L3:
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
L4:
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    add     rsp,88h
    ret
L5:
    cmp     r13,0
    ja      L2
    jmp     L3
L6:
    lea     rax,[k4]
    mov     rdi,rbx
    mov     esi,1
    mov     rdx,rax
    call    fn5
    add     rbx,1
    lea     rax,[rsp+6Fh]
    mov     rdi,rax
    call    fn6
    mov     rcx,rax
    mov     rax,r14
    mov     rdx,r14
    mov     rsi,rbx
    mov     rdi,r12
    mov     r8,r13
    mov     r9,r15
    jmp     L1
    mov     ecx,1
    jmp     L10
    mov     ecx,0
    jmp     L10
    mov     rcx,r15
    jmp     L10
L7:
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    qword ptr [fn1.slot]
    mov     rcx,r15
    mov     rax,rbx
    jmp     L10
    jmp     L11
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L8
L10:
    test    cl,cl
    jne     L9
    jmp     L8
    mov     rbx,rax
    jmp     L7
L11:
    call    qword ptr [sym7]
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
    .long   L20
    .long   L21
    .long   L22
L13:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
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
    mov     [rdx-20h],rbx
    mov     [rdx-30h],r12
    mov     [rdx-40h],r13
    mov     [rdx-50h],r14
    mov     [rdx-60h],r15
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L0
L14:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     [rdx-20h],rbx
    mov     [rdx-30h],r12
    mov     [rdx-40h],r13
    mov     [rdx-50h],r14
    mov     [rdx-60h],r15
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     r9,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L1
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

