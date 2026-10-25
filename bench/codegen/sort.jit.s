fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
    sub     rsp,18h
    mov     eax,20h
    add     rsp,18h
    ret

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
    sub     rsp,18h
    mov     eax,1
    movzx   eax,al
    add     rsp,18h
    ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,[rdi]
    mov     r12,[rdi+8]
    mov     r13,[rdi+10h]
    lea     r14,[k0]
    cmp     r13,0
    jne     L0
    mov     r15d,1
    jmp     L1
L0:
    mov     r15d,0
L1:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L17
L4:
    jmp     L13
L5:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L18
L8:
    jmp     L15
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r13
    mov     rdx,r10
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
    cmp     rax,rsi
    setbe   al
    jmp     L16
L12:
    test    r15b,r15b
    jne     L5
    cmp     rbx,0
    je      L20
    jmp     L5
L13:
    test    cl,cl
    jne     L12
    jmp     L20
L14:
    test    r15b,r15b
    jne     L9
    cmp     r12,0
    je      L20
    jmp     L9
L15:
    test    dl,dl
    jne     L14
    jmp     L20
L16:
    test    al,al
    je      L20
    imul    r13,4
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
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L19:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L21
    jmp     L21
L20:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L21:
    call    qword ptr [image.sym10]
    ud2

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    sub     rsp,18h
    mov     eax,[rsi]
    mov     ecx,[rdx]
    cmp     eax,ecx
    setb    al
    movzx   eax,al
    add     rsp,18h
    ret

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     ecx,[rdx]
    imul    rsi,1Fh
    mov     ecx,ecx
    xor     rcx,rax
    add     rsi,rcx
    mov     rax,[rdi]
    add     rax,1
    jb      L0
    mov     [rdi],rax
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    lea     rax,[k1]
    mov     rdi,rax
    call    qword ptr [sym2]
    jmp     L1
    jmp     L2
L1:
    ud2
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,58h
    mov     [rsp+10h],rbx
    mov     [rsp+40h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L1
    mov     rax,[rsp+40h]
    lea     rcx,[image.k10584]
    mov     r11,rax
    add     r11,1
    jb      L6
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+40h],rdx
    mov     rbx,rax
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
L3:
    .long   L5
    .long   L4
    .long   L11
L4:
    lea     rax,[rsp+20h]
    mov     rdi,rax
    mov     rsi,rbx
    call    fn1
    jmp     L0
L5:
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     [rdx],rax
    mov     rbx,[rsp+10h]
    add     rsp,58h
    ret
L6:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    mov     rbx,rax
    mov     eax,0
    jmp     L13
L7:
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    mov     rax,rbx
    jmp     L8
    jmp     L12
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L7
L10:
    test    al,al
    jne     L9
    jmp     L7
L11:
    ud2
L12:
    call    qword ptr [sym4]
    ud2
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
L15:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-80h]
    mov     [rdx-40h],rbx
    lea     rsp,[rsp+30h]
    jmp     L0
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

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,98h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF70h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    cmp     rbx,r12
    sete    al
    test    al,al
    je      L5
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+68h]
    mov     [rcx],rax
    jmp     L3
L0:
    lea     rax,[rsp+68h]
    lea     rcx,[r13+r14*4]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    jmp     L6
L1:
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+68h]
    mov     [rcx],rax
    jmp     L3
L2:
    mov     r13,rax
    mov     r14,rcx
    mov     r15,rdx
    mov     rbp,rsi
    jmp     L0
L3:
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,98h
    ret
L4:
    mov     r13,rbx
    mov     r14d,0
    mov     r15,rax
    mov     ebp,0
    jmp     L0
L5:
    lea     rcx,[k4]
    cmp     r12,rbx
    jb      L7
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    jmp     L4
L6:
    lea     rax,[k9]
    mov     r11,r14
    add     r11,1
    jb      L8
    add     r14,1
    cmp     r14,r15
    je      L1
    mov     rax,r13
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,rbp
    jmp     L2
L7:
    lea     rdx,[image.k7567]
    mov     rdi,rdx
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L8:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    mov     ecx,0
    mov     rbx,rax
    jmp     L16
L9:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     rdx,rbp
    mov     rax,rbx
    jmp     L14
    jmp     L15
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
L11:
    jmp     L9
L12:
    test    cl,cl
    jne     L11
    jmp     L9
L13:
    jmp     L10
L14:
    test    dl,dl
    jne     L13
    jmp     L10
L15:
    call    qword ptr [sym11]
    ud2
L16:
    jmp     L12
  ; OSR entries
    lea     r11,[L17]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L17:
    .long   L18
    .long   L19
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
    .long   L25
    .long   L26
    .long   L27
    .long   L28
L18:
    pop     rcx
    lea     rdx,[rsp+0C0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-48h]
    mov     [rsp+10h],r11
    movzx   r11d,byte ptr [rdx-52h]
    mov     [rsp+18h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+50h]
    jmp     L0
L19:
    ret
L20:
    pop     rcx
    lea     rdx,[rsp+0C0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-48h]
    mov     [rsp+10h],r11
    movzx   r11d,byte ptr [rdx-52h]
    mov     [rsp+18h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L2
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

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,98h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rdx
    mov     [rsp+68h],rcx
    cmp     rbx,rsi
    sete    al
    test    al,al
    je      L5
    mov     rcx,r12
    jmp     L3
L0:
    lea     rcx,[rsp+68h]
    lea     rdx,[r13+r14*4]
    mov     rdi,rcx
    mov     rsi,rax
    call    fn0
    jmp     L6
L1:
    mov     rcx,rax
    jmp     L3
L2:
    mov     rax,rcx
    mov     r13,rdx
    mov     r14,rdi
    mov     r15,r8
    mov     rbp,r9
    jmp     L0
L3:
    mov     rax,rcx
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,98h
    ret
L4:
    mov     rax,r12
    mov     r13,rbx
    mov     r14d,0
    mov     r15,rcx
    mov     ebp,0
    jmp     L0
L5:
    lea     rdx,[k1]
    cmp     rsi,rbx
    jb      L7
    sub     rsi,rbx
    mov     rdi,rsi
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L4
L6:
    lea     rcx,[k6]
    mov     r11,r14
    add     r11,1
    jb      L8
    add     r14,1
    cmp     r14,r15
    je      L1
    mov     rcx,rax
    mov     rdx,r13
    mov     rdi,r14
    mov     r8,r15
    mov     r9,rbp
    jmp     L2
L7:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L8:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    mov     ecx,0
    jmp     L15
L9:
    jmp     L14
L10:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
L11:
    jmp     L9
L12:
    test    cl,cl
    jne     L11
    jmp     L9
L13:
    jmp     L10
L14:
    test    bpl,bpl
    jne     L13
    jmp     L10
L15:
    jmp     L12
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
    .long   L23
    .long   L24
    .long   L25
L17:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-52h]
    mov     [rsp+20h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L0
L18:
    ret
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-52h]
    mov     [rsp+20h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     rcx,[rsp]
    mov     rdi,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+80h]
    jmp     L2
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

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
    sub     rsp,18h
    mov     eax,20h
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

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     rbx,rdi
    mov     [rsp+70h],rdx
    cmp     rdx,rcx
    jb      L0
    lea     rax,[k0]
    lea     rdi,[rsp+58h]
    mov     r8,rax
    call    qword ptr [fn1.slot]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFC8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF80h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    add     rsp,98h
    ret
L0:
    lea     rax,[k2]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+68h],9
    mov     [rsp+58h],rax
    mov     [rsp+70h],rax
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,r8
    call    qword ptr [sym4]
    ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    cmp     r13,r14
    jb      L12
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L13
L2:
    jmp     L4
L3:
    cmp     r12,0
    je      L14
    jmp     L5
L4:
    test    cl,cl
    jne     L3
    jmp     L14
L5:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L14
    lea     rbp,[r12+r14*8]
    sub     r13,r14
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L16
L8:
    jmp     L10
L9:
    cmp     rbp,0
    je      L17
    jmp     L11
L10:
    test    cl,cl
    jne     L9
    jmp     L17
L11:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r13,rax
    ja      L17
    mov     [rsp+10h],r12
    mov     [rsp+18h],r14
    mov     [rsp+20h],rbp
    mov     [rsp+28h],r13
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF80h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L12:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L13:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L15
L14:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L15:
    call    qword ptr [image.sym10]
    ud2
L16:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L18
L17:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L18:
    call    qword ptr [image.sym10]
    ud2

fn core::slice::<impl [T]>::split_at_mut_unchecked::precondition_check
    sub     rsp,18h
    cmp     rsi,rdi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,1BBh
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn core::slice::<impl [u32]>::split_at_mut
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     rbx,rdi
    mov     [rsp+70h],rdx
    cmp     rdx,rcx
    jb      L0
    lea     rax,[k0]
    lea     rdi,[rsp+58h]
    mov     r8,rax
    call    qword ptr [fn1.slot]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFC8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA0h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF80h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    add     rsp,98h
    ret
L0:
    lea     rax,[k2]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+68h],9
    mov     [rsp+58h],rax
    mov     [rsp+70h],rax
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,r8
    call    qword ptr [sym4]
    ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    cmp     r13,r14
    jb      L12
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L13
L2:
    jmp     L4
L3:
    cmp     r12,0
    je      L14
    jmp     L5
L4:
    test    cl,cl
    jne     L3
    jmp     L14
L5:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L14
    lea     rbp,[r12+r14*4]
    sub     r13,r14
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L16
L8:
    jmp     L10
L9:
    cmp     rbp,0
    je      L17
    jmp     L11
L10:
    test    cl,cl
    jne     L9
    jmp     L17
L11:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r13,rax
    ja      L17
    mov     [rsp+10h],r12
    mov     [rsp+18h],r14
    mov     [rsp+20h],rbp
    mov     [rsp+28h],r13
    mov     [rsp],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF80h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L12:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L13:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L15
L14:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L15:
    call    qword ptr [image.sym10]
    ud2
L16:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L18
L17:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L18:
    call    qword ptr [image.sym10]
    ud2

fn core::slice::<impl [u32]>::swap
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     [rsp+10h],r8
    cmp     rdx,rsi
    jae     L65
    cmp     rcx,rsi
    jae     L66
    cmp     rdx,rsi
    jae     L49
    cmp     rcx,rsi
    jae     L49
    lea     rbx,[rdi+rdx*4]
    lea     r12,[rdi+rcx*4]
    lea     r13,[rsp+1Ch]
    lea     r14,[image.k488]
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rdi,rbx
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L50
L2:
    jmp     L11
L3:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L5
L4:
    mov     r9,r13
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L6
L5:
    cmp     eax,1
    je      L4
    jmp     L51
L6:
    jmp     L13
L7:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L52
    cmp     rbx,r13
    jae     L8
    mov     rbp,r13
    sub     rbp,rbx
    jmp     L9
L8:
    mov     rbp,rbx
    sub     rbp,r13
L9:
    cmp     rax,rbp
    setbe   al
    jmp     L14
L10:
    test    r15b,r15b
    jne     L3
    cmp     rbx,0
    je      L53
    jmp     L3
L11:
    test    dil,dil
    jne     L10
    jmp     L53
L12:
    test    r15b,r15b
    jne     L7
    cmp     r13,0
    je      L53
    jmp     L7
L13:
    test    r9b,r9b
    jne     L12
    jmp     L53
L14:
    test    al,al
    je      L53
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r15d,0
    jmp     L16
L15:
    lea     r13,[rsp+1Ch]
    jmp     L33
L16:
    lea     rbp,[image.k512]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L18
L17:
    mov     rdi,r12
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L19
L18:
    cmp     eax,1
    je      L17
    jmp     L55
L19:
    jmp     L25
L20:
    test    r15b,r15b
    je      L24
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L22
L21:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L23
L22:
    cmp     eax,1
    je      L21
    jmp     L56
L23:
    jmp     L27
L24:
    cmp     r12,0
    je      L58
    jmp     L28
L25:
    test    dil,dil
    jne     L20
    jmp     L58
L26:
    cmp     rbx,0
    je      L58
    jmp     L32
L27:
    test    r9b,r9b
    jne     L32
    jmp     L58
L28:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L30
L29:
    mov     rdi,rbx
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L31
L30:
    cmp     eax,1
    je      L29
    jmp     L57
L31:
    test    dil,dil
    jne     L26
    jmp     L58
L32:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L15
L33:
    lea     rbx,[image.k536]
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L35
L34:
    mov     rdi,r13
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L36
L35:
    cmp     eax,1
    je      L34
    jmp     L60
L36:
    jmp     L45
L37:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L39
L38:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L40
L39:
    cmp     eax,1
    je      L38
    jmp     L61
L40:
    jmp     L47
L41:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L62
    cmp     r13,r12
    jae     L42
    mov     r8,r12
    sub     r8,r13
    jmp     L43
L42:
    mov     r8,r13
    sub     r8,r12
L43:
    cmp     rax,r8
    setbe   al
    jmp     L48
L44:
    test    r15b,r15b
    jne     L37
    cmp     r13,0
    je      L63
    jmp     L37
L45:
    test    dil,dil
    jne     L44
    jmp     L63
L46:
    test    r15b,r15b
    jne     L41
    cmp     r12,0
    je      L63
    jmp     L41
L47:
    test    r9b,r9b
    jne     L46
    jmp     L63
L48:
    test    al,al
    je      L63
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L49:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L51:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L52:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L54
    jmp     L54
L53:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L54:
    call    qword ptr [image.sym10]
    ud2
L55:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L56:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L57:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
    jmp     L59
L58:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L59
L59:
    call    qword ptr [image.sym10]
    ud2
L60:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L61:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    qword ptr [image.sym6]
    ud2
L62:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L64
    jmp     L64
L63:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L64:
    call    qword ptr [image.sym10]
    ud2
L65:
    mov     rdi,rdx
    mov     rdx,[rsp+10h]
    call    qword ptr [sym0]
    ud2
L66:
    mov     rdi,rcx
    mov     rdx,[rsp+10h]
    call    qword ptr [sym0]
    ud2

fn core::slice::<impl [u32]>::swap_unchecked
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    cmp     rdx,rsi
    jae     L49
    cmp     rcx,rsi
    jae     L49
    lea     rbx,[rdi+rdx*4]
    lea     r12,[rdi+rcx*4]
    lea     r13,[rsp+0Ch]
    lea     r14,[image.k488]
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L50
L2:
    jmp     L11
L3:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L5
L4:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L6
L5:
    cmp     eax,1
    je      L4
    jmp     L51
L6:
    jmp     L13
L7:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L52
    cmp     rbx,r13
    jae     L8
    mov     rsi,r13
    sub     rsi,rbx
    jmp     L9
L8:
    mov     rsi,rbx
    sub     rsi,r13
L9:
    cmp     rax,rsi
    setbe   al
    jmp     L14
L10:
    test    r15b,r15b
    jne     L3
    cmp     rbx,0
    je      L53
    jmp     L3
L11:
    test    cl,cl
    jne     L10
    jmp     L53
L12:
    test    r15b,r15b
    jne     L7
    cmp     r13,0
    je      L53
    jmp     L7
L13:
    test    dl,dl
    jne     L12
    jmp     L53
L14:
    test    al,al
    je      L53
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r15d,0
    jmp     L16
L15:
    lea     r13,[rsp+0Ch]
    jmp     L33
L16:
    lea     rbp,[image.k512]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L18
L17:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L19
L18:
    cmp     eax,1
    je      L17
    jmp     L55
L19:
    jmp     L25
L20:
    test    r15b,r15b
    je      L24
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L22
L21:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L23
L22:
    cmp     eax,1
    je      L21
    jmp     L56
L23:
    jmp     L27
L24:
    cmp     r12,0
    je      L58
    jmp     L28
L25:
    test    cl,cl
    jne     L20
    jmp     L58
L26:
    cmp     rbx,0
    je      L58
    jmp     L32
L27:
    test    dl,dl
    jne     L32
    jmp     L58
L28:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L30
L29:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L31
L30:
    cmp     eax,1
    je      L29
    jmp     L57
L31:
    test    cl,cl
    jne     L26
    jmp     L58
L32:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L15
L33:
    lea     rbx,[image.k536]
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L35
L34:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L36
L35:
    cmp     eax,1
    je      L34
    jmp     L60
L36:
    jmp     L45
L37:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L39
L38:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L40
L39:
    cmp     eax,1
    je      L38
    jmp     L61
L40:
    jmp     L47
L41:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L62
    cmp     r13,r12
    jae     L42
    mov     rsi,r12
    sub     rsi,r13
    jmp     L43
L42:
    mov     rsi,r13
    sub     rsi,r12
L43:
    cmp     rax,rsi
    setbe   al
    jmp     L48
L44:
    test    r15b,r15b
    jne     L37
    cmp     r13,0
    je      L63
    jmp     L37
L45:
    test    cl,cl
    jne     L44
    jmp     L63
L46:
    test    r15b,r15b
    jne     L41
    cmp     r12,0
    je      L63
    jmp     L41
L47:
    test    dl,dl
    jne     L46
    jmp     L63
L48:
    test    al,al
    je      L63
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L49:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L51:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L52:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L54
    jmp     L54
L53:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L54:
    call    qword ptr [image.sym10]
    ud2
L55:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L56:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L57:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L59
L58:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L59
L59:
    call    qword ptr [image.sym10]
    ud2
L60:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L61:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L62:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L64
    jmp     L64
L63:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L64:
    call    qword ptr [image.sym10]
    ud2

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+20h],rdx
    mov     r11,[rsp+10h]
    cmp     r11,8
    jb      L19
    mov     rdi,[rsp+10h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+18h]
    lea     r14,[r11+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+18h]
    lea     r15,[r11+rcx*8]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L3
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     r11,[rsp+18h]
    mov     ecx,[r11]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     edx,[r14]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     r11,[rsp+18h]
    mov     edx,[r11]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    cmp     cl,dl
    jne     L1
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     edx,[r14]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    xor     edx,ecx
    test    dl,dl
    je      L0
    mov     rcx,r15
    jmp     L2
L0:
    mov     rcx,r14
    jmp     L2
L1:
    mov     rcx,[rsp+18h]
L2:
    jmp     L12
L3:
    mov     rdx,rax
    imul    rdx,8
    cmp     rdx,40h
    jb      L4
    jmp     L5
L4:
    mov     r13,[rsp+18h]
    jmp     L6
L5:
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rbp,rax
    mov     r12,rbp
    imul    r12,4
    mov     r11,[rsp+18h]
    lea     rax,[r11+r12*8]
    mov     rbx,rbp
    imul    rbx,7
    mov     r11,[rsp+18h]
    lea     rdx,[r11+rbx*8]
    mov     rdi,[rsp+18h]
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r13,rax
    lea     rax,[r14+r12*8]
    lea     rdx,[r14+rbx*8]
    mov     rdi,r14
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r14,rax
    lea     rax,[r15+r12*8]
    lea     rdx,[r15+rbx*8]
    mov     rdi,r15
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r15,rax
L6:
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     eax,[r13]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     edx,[r14]
    cmp     eax,edx
    setb    al
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     edx,[r13]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    cmp     al,dl
    jne     L8
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     edx,[r14]
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    xor     edx,eax
    test    dl,dl
    je      L7
    jmp     L9
L7:
    mov     r15,r14
    jmp     L9
L8:
    mov     r15,r13
L9:
    jmp     L14
L10:
    cmp     rax,[rsp+10h]
    setb    dl
    jmp     L15
L11:
    mov     rax,rsi
    jmp     L10
L12:
    lea     rdi,[k2]
    cmp     rcx,[rsp+18h]
    jb      L16
    sub     rcx,[rsp+18h]
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rsi,rax
    jmp     L11
L13:
    mov     rax,rcx
    jmp     L10
L14:
    lea     rsi,[k7]
    cmp     r15,[rsp+18h]
    jb      L17
    sub     r15,[rsp+18h]
    mov     rdi,r15
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L13
L15:
    lea     rcx,[k12]
    test    dl,dl
    je      L18
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L16:
    lea     rax,[image.k7567]
    mov     esi,193h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L17:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L18:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L19:
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L20]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L20:
    .long   L21
    .long   L22
    .long   L23
L21:
    ret
L22:
    ret
L23:
    ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,18h
    mov     eax,[rdi]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    al
    mov     ecx,[rdi]
    mov     r8d,[rdx]
    cmp     ecx,r8d
    setb    cl
    cmp     al,cl
    jne     L1
    mov     ecx,[rsi]
    mov     r8d,[rdx]
    cmp     ecx,r8d
    setb    cl
    xor     ecx,eax
    test    cl,cl
    je      L0
    jmp     L2
L0:
    mov     rdx,rsi
    jmp     L2
L1:
    mov     rdx,rdi
L2:
    mov     rax,rdx
    add     rsp,18h
    ret

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
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
    mov     [rsp+10h],r8
    mov     rax,rcx
    imul    rax,8
    cmp     rax,40h
    jb      L0
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r15,rax
    mov     rbp,r15
    imul    rbp,4
    lea     rax,[rbx+rbp*8]
    mov     r14,r15
    imul    r14,7
    lea     rcx,[rbx+r14*8]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     rbx,rax
    lea     rax,[r12+rbp*8]
    lea     rcx,[r12+r14*8]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     r12,rax
    lea     rax,[r13+rbp*8]
    lea     rcx,[r13+r14*8]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     r13,rax
L0:
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     ecx,[rbx]
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    cl
    cmp     al,cl
    jne     L2
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     ecx,[r12]
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    cl
    xor     ecx,eax
    test    cl,cl
    je      L1
    jmp     L3
L1:
    mov     r13,r12
    jmp     L3
L2:
    mov     r13,rbx
L3:
    mov     rax,r13
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
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
    mov     r14,r8
    mov     rax,rcx
    imul    rax,8
    cmp     rax,40h
    jb      L0
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     [rsp+10h],rax
    mov     rbp,[rsp+10h]
    imul    rbp,4
    lea     rax,[rbx+rbp*4]
    mov     r15,[rsp+10h]
    imul    r15,7
    lea     rcx,[rbx+r15*4]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,[rsp+10h]
    mov     r8,r14
    call    fn0
    mov     rbx,rax
    lea     rax,[r12+rbp*4]
    lea     rcx,[r12+r15*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,[rsp+10h]
    mov     r8,r14
    call    fn0
    mov     r12,rax
    lea     rax,[r13+rbp*4]
    lea     rcx,[r13+r15*4]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,[rsp+10h]
    mov     r8,r14
    call    fn0
    mov     r13,rax
L0:
    mov     eax,[rbx]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     ecx,[rbx]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    cl
    cmp     al,cl
    jne     L2
    mov     ecx,[r12]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    cl
    xor     ecx,eax
    test    cl,cl
    je      L1
    jmp     L3
L1:
    mov     r13,r12
    jmp     L3
L2:
    mov     r13,rbx
L3:
    mov     rax,r13
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,178h
    mov     [rsp+0B0h],rbx
    mov     [rsp+0A0h],r12
    mov     [rsp+90h],r13
    mov     [rsp+80h],r14
    mov     [rsp+70h],r15
    mov     [rsp+60h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     [rsp+0D0h],rbx
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    cmp     rax,0
    setne   cl
    mov     [rsp+0D7h],cl
    lea     rcx,[rbx+rax*4]
    mov     rdx,rax
    sub     rdx,1
    mov     [rsp+0D0h],rdx
    lea     rdx,[rbx+rdx*4]
    mov     rsi,r12
    sub     rsi,1
    lea     rdi,[rbx+rsi*4]
    mov     [rsp+0D0h],r13
    lea     rsi,[r13+rsi*4]
    mov     [rsp+50h],rax
    mov     eax,0
    mov     [rsp+48h],rdx
    mov     [rsp+18h],rbx
    mov     [rsp+10h],rcx
    mov     [rsp+20h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],r12
L0:
    mov     [rsp+0C8h],rax
    mov     r10,[rsp+50h]
    mov     [rsp+0C0h],r10
    cmp     rax,[rsp+50h]
    setb    cl
    mov     [rsp+0D7h],cl
    test    cl,cl
    jne     L7
    jmp     L8
L1:
    mov     r12,[rsp+0C0h]
    mov     rbx,[rsp+0C8h]
    mov     r11,[rsp+0D0h]
    mov     [rsp+58h],r11
    lea     rdi,[rsp+0C0h]
    mov     r8,r15
    mov     r10,rsi
    mov     rsi,rcx
    mov     rcx,r10
    call    fn0
    mov     rcx,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     rsi,[rsp+0D0h]
    mov     rax,r14
    mov     [rsp+50h],r13
    mov     [rsp+48h],rcx
    mov     [rsp+18h],r12
    mov     [rsp+10h],rbx
    mov     r11,[rsp+58h]
    mov     [rsp+20h],r11
    mov     [rsp+40h],r15
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rbp
    jmp     L0
L2:
    mov     rcx,[rsp+18h]
    mov     rdx,[rsp+10h]
    jmp     L6
L3:
    mov     rcx,[rsp+0D0h]
    mov     r11,[rsp+18h]
    cmp     r11,rcx
    setb    cl
    mov     [rsp+0C6h],cl
    test    cl,cl
    je      L4
    mov     rbx,[rsp+18h]
    jmp     L5
L4:
    mov     rbx,[rsp+10h]
L5:
    jmp     L11
L6:
    mov     rsi,[rsp+0D0h]
    cmp     rcx,rsi
    jne     L33
    mov     rcx,[rsp+0C8h]
    cmp     rdx,rcx
    jne     L33
    mov     rbx,[rsp+0B0h]
    mov     r12,[rsp+0A0h]
    mov     r13,[rsp+90h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+70h]
    mov     rbp,[rsp+60h]
    add     rsp,178h
    ret
L7:
    mov     [rsp+0C8h],rax
    jmp     L9
L8:
    mov     rax,[rsp+48h]
    lea     rax,[rax+4]
    mov     [rsp+0D0h],rax
    jmp     L10
L9:
    lea     rax,[k2]
    mov     rcx,[rsp+0C8h]
    mov     r11,rcx
    add     r11,1
    jb      L27
    mov     rcx,[rsp+0C8h]
    mov     r12,rcx
    add     r12,1
    mov     [rsp+0C0h],r12
    lea     rcx,[rsp+0C0h]
    mov     rdi,rcx
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn4
    mov     rcx,[rsp+48h]
    mov     rdx,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r14,r12
    mov     r13,[rsp+50h]
    mov     rbp,[rsp+28h]
    jmp     L1
L10:
    mov     rcx,[rsp+30h]
    lea     rcx,[rcx+4]
    mov     [rsp+0C8h],rcx
    mov     rdi,[rsp+28h]
    mov     esi,2
    call    ryo_hr_RemUW64
    mov     rcx,rax
    cmp     rcx,0
    sete    cl
    mov     [rsp+0C7h],cl
    test    cl,cl
    jne     L2
    jmp     L3
L11:
    lea     r12,[k5]
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L13
L12:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L14
L13:
    cmp     ecx,1
    je      L12
    jmp     L28
L14:
    jmp     L23
L15:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L17
L16:
    mov     rsi,[rsp+20h]
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L18
L17:
    cmp     ecx,1
    je      L16
    jmp     L29
L18:
    jmp     L25
L19:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L30
    cmp     rbx,[rsp+20h]
    jae     L20
    mov     rdi,[rsp+20h]
    sub     rdi,rbx
    jmp     L21
L20:
    mov     rdi,rbx
    sub     rdi,[rsp+20h]
L21:
    cmp     rcx,rdi
    setbe   cl
    jmp     L26
L22:
    test    r13b,r13b
    jne     L15
    cmp     rbx,0
    je      L31
    jmp     L15
L23:
    test    dl,dl
    jne     L22
    jmp     L31
L24:
    test    r13b,r13b
    jne     L19
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L31
    jmp     L19
L25:
    test    sil,sil
    jne     L24
    jmp     L31
L26:
    test    cl,cl
    je      L31
    mov     rdi,[rsp+20h]
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   ecx,byte ptr [rsp+0C6h]
    movzx   edx,cl
    mov     r11,[rsp+18h]
    lea     rdx,[r11+rdx*4]
    xor     ecx,1
    mov     [rsp+0C5h],cl
    movzx   ecx,cl
    mov     r11,[rsp+10h]
    lea     rcx,[r11+rcx*4]
    mov     r10,rcx
    mov     rcx,rdx
    mov     rdx,r10
    jmp     L6
L27:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L28:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L29:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L30:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L32
    jmp     L32
L31:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L32:
    call    qword ptr [image.sym10]
    ud2
L33:
    call    qword ptr [sym1]
    ud2
  ; OSR entries
    lea     r11,[L34]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L34:
    .long   L35
    .long   L36
    .long   L37
    .long   L38
    .long   L39
L35:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-38h]
    mov     [rsp],r11
    mov     r11,[rdx-30h]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-68h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+48h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     r11,[rsp+8]
    mov     [rdx-120h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-148h],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+50h]
    jmp     L0
L36:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1B0h]
    mov     r11,[rdx-58h]
    mov     [rsp],r11
    mov     r11,[rdx-60h]
    mov     [rsp+8],r11
    mov     r11,[rdx-68h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+30h],r11
    mov     [rdx-0C0h],rbx
    mov     [rdx-0D0h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0F0h],r14
    mov     [rdx-100h],r15
    mov     [rdx-110h],rbp
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     r14,[rsp+20h]
    mov     r13,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L1
L37:
    ret
L38:
    ret
L39:
    ret

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     [rsp+20h],rcx
    mov     eax,[r13]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     rbp,r15
    xor     ebp,1
    cmp     r15b,1
    je      L0
    mov     rbx,r13
    jmp     L1
L0:
    mov     rbx,r12
L1:
    lea     r11,[k1]
    mov     [rsp+18h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L19
L4:
    jmp     L13
L5:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,[rsp+20h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L20
L8:
    jmp     L15
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L21
    cmp     rbx,[rsp+20h]
    jae     L10
    mov     rsi,[rsp+20h]
    sub     rsi,rbx
    jmp     L11
L10:
    mov     rsi,rbx
    sub     rsi,[rsp+20h]
L11:
    cmp     rax,rsi
    setbe   al
    jmp     L16
L12:
    test    r14b,r14b
    jne     L5
    cmp     rbx,0
    je      L22
    jmp     L5
L13:
    test    cl,cl
    jne     L12
    jmp     L22
L14:
    test    r14b,r14b
    jne     L9
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L22
    jmp     L9
L15:
    test    dl,dl
    jne     L14
    jmp     L22
L16:
    test    al,al
    je      L22
    mov     rdi,[rsp+20h]
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   ebp,bpl
    mov     eax,0
    sub     rax,rbp
    lea     r13,[r13+rax*4]
    movzx   r15d,r15b
    mov     eax,0
    sub     rax,r15
    lea     r12,[r12+rax*4]
    jmp     L18
L17:
    mov     [rsp+28h],r12
    mov     [rsp+30h],r13
    mov     [rsp+38h],rax
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0A8h
    ret
L18:
    mov     rax,[rsp+20h]
    lea     rax,[rax-4]
    jmp     L17
L19:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L20:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L21:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L23
    jmp     L23
L22:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L23:
    call    qword ptr [image.sym10]
    ud2
  ; OSR entries
    lea     r11,[L24]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L24:
    .long   L25
L25:
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     [rsp+20h],rcx
    mov     eax,[r13]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     rbp,r15
    xor     ebp,1
    cmp     r15b,1
    je      L0
    mov     rbx,r12
    jmp     L1
L0:
    mov     rbx,r13
L1:
    lea     r11,[k1]
    mov     [rsp+18h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L17
L4:
    jmp     L13
L5:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,[rsp+20h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L18
L8:
    jmp     L15
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L19
    cmp     rbx,[rsp+20h]
    jae     L10
    mov     rsi,[rsp+20h]
    sub     rsi,rbx
    jmp     L11
L10:
    mov     rsi,rbx
    sub     rsi,[rsp+20h]
L11:
    cmp     rax,rsi
    setbe   al
    jmp     L16
L12:
    test    r14b,r14b
    jne     L5
    cmp     rbx,0
    je      L20
    jmp     L5
L13:
    test    cl,cl
    jne     L12
    jmp     L20
L14:
    test    r14b,r14b
    jne     L9
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L20
    jmp     L9
L15:
    test    dl,dl
    jne     L14
    jmp     L20
L16:
    test    al,al
    je      L20
    mov     rdi,[rsp+20h]
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   r15d,r15b
    lea     r13,[r13+r15*4]
    movzx   ebp,bpl
    lea     r12,[r12+rbp*4]
    mov     rax,[rsp+20h]
    lea     rax,[rax+4]
    mov     [rsp+28h],r12
    mov     [rsp+30h],r13
    mov     [rsp+38h],rax
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0A8h
    ret
L17:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L19:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L21
    jmp     L21
L20:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L21:
    call    qword ptr [image.sym10]
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,728h
    mov     [rsp+600h],rbx
    mov     [rsp+5F0h],r12
    mov     [rsp+5E0h],r13
    mov     [rsp+5D0h],r14
    mov     [rsp+5C0h],r15
    mov     [rsp+5B0h],rbp
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+40h],rdx
    mov     [rsp+38h],r8
    mov     r11,[rsp+48h]
    cmp     r11,2
    jb      L170
    mov     rax,[rsp+48h]
    add     rax,10h
    cmp     rcx,rax
    jb      L348
    mov     rdi,[rsp+48h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+30h],rax
    mov     r11,[rsp+48h]
    cmp     r11,10h
    jb      L0
    mov     r11,[rsp+40h]
    mov     r10,[rsp+48h]
    lea     rax,[r11+r10*8]
    mov     [rsp+540h],rax
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,rax
    mov     rcx,[rsp+38h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*8]
    mov     [rsp+540h],rax
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+538h],rcx
    mov     rdx,[rsp+48h]
    add     rdx,8
    mov     [rsp+628h],rdx
    mov     r11,[rsp+40h]
    lea     rdx,[r11+rdx*8]
    mov     [rsp+530h],rdx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+38h]
    call    qword ptr [fn0.slot]
    mov     ebx,8
    jmp     L158
L0:
    mov     r11,[rsp+48h]
    cmp     r11,8
    jb      L157
    mov     r10,[rsp+50h]
    mov     [rsp+540h],r10
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     eax,[r11+8]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     ecx,[r11+18h]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     edx,[r11+10h]
    cmp     ecx,edx
    setb    cl
    movzx   edx,al
    mov     r11,[rsp+50h]
    lea     rbp,[r11+rdx*8]
    xor     eax,1
    movzx   eax,al
    mov     r11,[rsp+50h]
    lea     r15,[r11+rax*8]
    movzx   eax,cl
    add     rax,2
    mov     r11,[rsp+50h]
    lea     r14,[r11+rax*8]
    xor     ecx,1
    movzx   ecx,cl
    add     rcx,2
    mov     r11,[rsp+50h]
    lea     r11,[r11+rcx*8]
    mov     [rsp+70h],r11
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     eax,[r14]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    al
    mov     r12,rax
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+70h]
    mov     eax,[r11]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    al
    mov     [rsp+68h],rax
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,rbp
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+58h],rax
    mov     rdi,[rsp+68h]
    mov     rsi,r15
    mov     rdx,[rsp+70h]
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+60h],rax
    mov     [rsp+220h],r14
    mov     [rsp+218h],r14
    mov     [rsp+220h],r15
    lea     rbx,[rsp+218h]
    lea     r13,[rsp+220h]
    mov     [rsp+228h],r13
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rbx
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],r13
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+228h]
    mov     [rsp+0B0h],r11
    mov     rax,[rsp+208h]
    mov     [rsp+238h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L2
L1:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym18]
    jmp     L3
L2:
    mov     r10,[rsp+0B0h]
    mov     [rsp+238h],r10
    mov     rax,[rsp+218h]
    mov     rcx,[rsp+220h]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym19]
    jmp     L1
L3:
    mov     rax,[rsp+238h]
    mov     rdi,r12
    mov     rsi,rbp
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r13,rax
    mov     [rsp+260h],r15
    mov     [rsp+258h],r15
    mov     [rsp+260h],r14
    lea     r14,[rsp+258h]
    lea     r15,[rsp+260h]
    mov     [rsp+268h],r15
    mov     [rsp+8],r12b
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r12b
    mov     [rsp],r15
    mov     [rsp+10h],r14
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+268h]
    mov     [rsp+270h],rax
    mov     rax,[rsp+248h]
    mov     [rsp+278h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L5
L4:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym18]
    jmp     L6
L5:
    mov     rax,[rsp+270h]
    mov     [rsp+278h],rax
    mov     rax,[rsp+258h]
    mov     rcx,[rsp+260h]
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym19]
    jmp     L4
L6:
    mov     rax,[rsp+278h]
    mov     r10,[rsp+70h]
    mov     [rsp+2A0h],r10
    mov     r10,[rsp+70h]
    mov     [rsp+298h],r10
    mov     [rsp+2A0h],rax
    lea     r12,[rsp+298h]
    lea     r14,[rsp+2A0h]
    mov     [rsp+2A8h],r14
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],r12
    mov     [rsp+10h],r14
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],r14
    mov     [rsp+10h],r12
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+2A8h]
    mov     [rsp+78h],r11
    mov     rax,[rsp+288h]
    mov     [rsp+2B8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L8
L7:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym18]
    jmp     L9
L8:
    mov     r10,[rsp+78h]
    mov     [rsp+2B8h],r10
    mov     rax,[rsp+298h]
    mov     rcx,[rsp+2A0h]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym19]
    jmp     L7
L9:
    mov     rax,[rsp+2B8h]
    mov     r14,rax
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     eax,[r14]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     [rsp+2E0h],r14
    mov     [rsp+2D8h],r14
    mov     [rsp+2E0h],r13
    lea     rbp,[rsp+2D8h]
    lea     r12,[rsp+2E0h]
    mov     [rsp+2E8h],r12
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r12
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+2E8h]
    mov     [rsp+0A8h],r11
    mov     rax,[rsp+2C8h]
    mov     [rsp+2F8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L11
L10:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym18]
    jmp     L12
L11:
    mov     r10,[rsp+0A8h]
    mov     [rsp+2F8h],r10
    mov     rax,[rsp+2D8h]
    mov     rcx,[rsp+2E0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym19]
    jmp     L10
L12:
    mov     rax,[rsp+2F8h]
    mov     rbp,rax
    mov     [rsp+320h],r13
    mov     [rsp+318h],r13
    mov     [rsp+320h],r14
    lea     r13,[rsp+318h]
    lea     r14,[rsp+320h]
    mov     [rsp+328h],r14
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],r14
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r15b
    mov     [rsp],r14
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+328h]
    mov     [rsp+90h],r11
    mov     rax,[rsp+308h]
    mov     [rsp+338h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L14
L13:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym18]
    jmp     L15
L14:
    mov     r10,[rsp+90h]
    mov     [rsp+338h],r10
    mov     rax,[rsp+318h]
    mov     rcx,[rsp+320h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym19]
    jmp     L13
L15:
    mov     rax,[rsp+338h]
    mov     r14,rax
    lea     r11,[image.k1752]
    mov     [rsp+80h],r11
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L17
L16:
    mov     rcx,[rsp+58h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L18
L17:
    cmp     eax,1
    je      L16
    jmp     L266
L18:
    jmp     L27
L19:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L21
L20:
    mov     rdx,[rsp+40h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L22
L21:
    cmp     eax,1
    je      L20
    jmp     L267
L22:
    jmp     L29
L23:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L268
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+40h]
    jae     L24
    mov     rsi,[rsp+40h]
    sub     rsi,[rsp+58h]
    jmp     L25
L24:
    mov     rsi,[rsp+58h]
    sub     rsi,[rsp+40h]
L25:
    cmp     rax,rsi
    setbe   al
    jmp     L30
L26:
    test    r15b,r15b
    jne     L19
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L269
    jmp     L19
L27:
    test    cl,cl
    jne     L26
    jmp     L269
L28:
    test    r15b,r15b
    jne     L23
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L269
    jmp     L23
L29:
    test    dl,dl
    jne     L28
    jmp     L269
L30:
    test    al,al
    je      L269
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+58h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r15,[rsp+40h]
    lea     r15,[r15+8]
    lea     r11,[image.k1776]
    mov     [rsp+88h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L271
L33:
    jmp     L42
L34:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L36
L35:
    mov     rdx,r15
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L37
L36:
    cmp     eax,1
    je      L35
    jmp     L272
L37:
    jmp     L44
L38:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L273
    cmp     rbp,r15
    jae     L39
    mov     rsi,r15
    sub     rsi,rbp
    jmp     L40
L39:
    mov     rsi,rbp
    sub     rsi,r15
L40:
    cmp     rax,rsi
    setbe   al
    jmp     L45
L41:
    test    r13b,r13b
    jne     L34
    cmp     rbp,0
    je      L274
    jmp     L34
L42:
    test    cl,cl
    jne     L41
    jmp     L274
L43:
    test    r13b,r13b
    jne     L38
    cmp     r15,0
    je      L274
    jmp     L38
L44:
    test    dl,dl
    jne     L43
    jmp     L274
L45:
    test    al,al
    je      L274
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+40h]
    lea     r13,[r13+10h]
    lea     r11,[image.k1800]
    mov     [rsp+0A0h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L47
L46:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L48
L47:
    cmp     eax,1
    je      L46
    jmp     L276
L48:
    jmp     L57
L49:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L51
L50:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L52
L51:
    cmp     eax,1
    je      L50
    jmp     L277
L52:
    jmp     L59
L53:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L278
    cmp     r14,r13
    jae     L54
    mov     rsi,r13
    sub     rsi,r14
    jmp     L55
L54:
    mov     rsi,r14
    sub     rsi,r13
L55:
    cmp     rax,rsi
    setbe   al
    jmp     L60
L56:
    test    bpl,bpl
    jne     L49
    cmp     r14,0
    je      L279
    jmp     L49
L57:
    test    cl,cl
    jne     L56
    jmp     L279
L58:
    test    bpl,bpl
    jne     L53
    cmp     r13,0
    je      L279
    jmp     L53
L59:
    test    dl,dl
    jne     L58
    jmp     L279
L60:
    test    al,al
    je      L279
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+40h]
    lea     r13,[r13+18h]
    lea     r11,[image.k1824]
    mov     [rsp+98h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L62
L61:
    mov     rcx,[rsp+60h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L63
L62:
    cmp     eax,1
    je      L61
    jmp     L281
L63:
    jmp     L72
L64:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L66
L65:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L67
L66:
    cmp     eax,1
    je      L65
    jmp     L282
L67:
    jmp     L74
L68:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L283
    mov     r11,[rsp+60h]
    cmp     r11,r13
    jae     L69
    mov     rsi,r13
    sub     rsi,[rsp+60h]
    jmp     L70
L69:
    mov     rsi,[rsp+60h]
    sub     rsi,r13
L70:
    cmp     rax,rsi
    setbe   al
    jmp     L75
L71:
    test    bpl,bpl
    jne     L64
    mov     r11,[rsp+60h]
    cmp     r11,0
    je      L284
    jmp     L64
L72:
    test    cl,cl
    jne     L71
    jmp     L284
L73:
    test    bpl,bpl
    jne     L68
    cmp     r13,0
    je      L284
    jmp     L68
L74:
    test    dl,dl
    jne     L73
    jmp     L284
L75:
    test    al,al
    je      L284
    mov     rdi,r13
    mov     rsi,[rsp+60h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*8]
    mov     [rsp+538h],rax
    mov     [rsp+540h],rax
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     r11,[r11+r10*8]
    mov     [rsp+0B8h],r11
    mov     r10,[rsp+0B8h]
    mov     [rsp+538h],r10
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[rax+8]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     edx,[rax]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     edx,[rax+18h]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     esi,[rax+10h]
    cmp     edx,esi
    setb    dl
    movzx   esi,cl
    lea     rbp,[rax+rsi*8]
    xor     ecx,1
    movzx   ecx,cl
    lea     r14,[rax+rcx*8]
    movzx   ecx,dl
    add     rcx,2
    lea     r15,[rax+rcx*8]
    xor     edx,1
    movzx   edx,dl
    add     rdx,2
    lea     r11,[rax+rdx*8]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     eax,[r15]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     r11,[rsp+0D0h]
    mov     eax,[r11]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[r14]
    cmp     eax,ecx
    setb    al
    mov     [rsp+0C8h],rax
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rbp
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+0C0h],rax
    mov     [rsp+360h],r14
    mov     [rsp+358h],r14
    mov     r10,[rsp+0D0h]
    mov     [rsp+360h],r10
    lea     r13,[rsp+358h]
    lea     r12,[rsp+360h]
    mov     [rsp+368h],r12
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],r13
    mov     [rsp+10h],r12
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],r12
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+368h]
    mov     [rsp+0D8h],r11
    mov     rax,[rsp+348h]
    mov     [rsp+378h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L77
L76:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym18]
    jmp     L78
L77:
    mov     r10,[rsp+0D8h]
    mov     [rsp+378h],r10
    mov     rax,[rsp+358h]
    mov     rcx,[rsp+360h]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym19]
    jmp     L76
L78:
    mov     rax,[rsp+378h]
    mov     [rsp+0E0h],rax
    mov     [rsp+3A0h],r15
    mov     [rsp+398h],r15
    mov     [rsp+3A0h],r14
    lea     r12,[rsp+398h]
    lea     r13,[rsp+3A0h]
    mov     [rsp+3A8h],r13
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],r12
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],r13
    mov     [rsp+10h],r12
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+3A8h]
    mov     [rsp+110h],r11
    mov     rax,[rsp+388h]
    mov     [rsp+3B8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L80
L79:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym18]
    jmp     L81
L80:
    mov     r10,[rsp+110h]
    mov     [rsp+3B8h],r10
    mov     rax,[rsp+398h]
    mov     rcx,[rsp+3A0h]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym19]
    jmp     L79
L81:
    mov     rax,[rsp+3B8h]
    mov     [rsp+3E0h],rbp
    mov     [rsp+3D8h],rbp
    mov     [rsp+3E0h],rax
    lea     r13,[rsp+3D8h]
    lea     rbp,[rsp+3E0h]
    mov     [rsp+3E8h],rbp
    mov     [rsp+8],bl
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym16]
    mov     [rsp+8],bl
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+3E8h]
    mov     [rsp+0E8h],r11
    mov     rax,[rsp+3C8h]
    mov     [rsp+3F8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L83
L82:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym18]
    jmp     L84
L83:
    mov     r10,[rsp+0E8h]
    mov     [rsp+3F8h],r10
    mov     rax,[rsp+3D8h]
    mov     rcx,[rsp+3E0h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym19]
    jmp     L82
L84:
    mov     rax,[rsp+3F8h]
    mov     rbp,rax
    mov     [rsp+420h],r14
    mov     [rsp+418h],r14
    mov     [rsp+420h],r15
    lea     r14,[rsp+418h]
    lea     r15,[rsp+420h]
    mov     [rsp+428h],r15
    mov     [rsp+8],bl
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym16]
    mov     [rsp+8],bl
    mov     [rsp],r15
    mov     [rsp+10h],r14
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+428h]
    mov     [rsp+430h],rax
    mov     rax,[rsp+408h]
    mov     [rsp+438h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L86
L85:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym18]
    jmp     L87
L86:
    mov     rax,[rsp+430h]
    mov     [rsp+438h],rax
    mov     rax,[rsp+418h]
    mov     rcx,[rsp+420h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym19]
    jmp     L85
L87:
    mov     rax,[rsp+438h]
    mov     r10,[rsp+0D0h]
    mov     [rsp+460h],r10
    mov     r10,[rsp+0D0h]
    mov     [rsp+458h],r10
    mov     [rsp+460h],rax
    lea     rbx,[rsp+458h]
    lea     r14,[rsp+460h]
    mov     [rsp+468h],r14
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],rbx
    mov     [rsp+10h],r14
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],r14
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+468h]
    mov     [rsp+470h],rax
    mov     rax,[rsp+448h]
    mov     [rsp+478h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L89
L88:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym18]
    jmp     L90
L89:
    mov     rax,[rsp+470h]
    mov     [rsp+478h],rax
    mov     rax,[rsp+458h]
    mov     rcx,[rsp+460h]
    mov     r10,[rsp+0C8h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym19]
    jmp     L88
L90:
    mov     rax,[rsp+478h]
    mov     rbx,rax
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     [rsp+4A0h],rbx
    mov     [rsp+498h],rbx
    mov     [rsp+4A0h],rbp
    lea     r15,[rsp+498h]
    lea     r13,[rsp+4A0h]
    mov     [rsp+4A8h],r13
    mov     [rsp+8],r14b
    mov     [rsp],r15
    mov     [rsp+10h],r13
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r14b
    mov     [rsp],r13
    mov     [rsp+10h],r15
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+4A8h]
    mov     [rsp+4B0h],rax
    mov     rax,[rsp+488h]
    mov     [rsp+4B8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L92
L91:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym18]
    jmp     L93
L92:
    mov     rax,[rsp+4B0h]
    mov     [rsp+4B8h],rax
    mov     rax,[rsp+498h]
    mov     rcx,[rsp+4A0h]
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym19]
    jmp     L91
L93:
    mov     rax,[rsp+4B8h]
    mov     r13,rax
    mov     [rsp+4E0h],rbp
    mov     [rsp+4D8h],rbp
    mov     [rsp+4E0h],rbx
    lea     rbx,[rsp+4D8h]
    lea     r15,[rsp+4E0h]
    mov     [rsp+4E8h],r15
    mov     [rsp+8],r14b
    mov     [rsp],rbx
    mov     [rsp+10h],r15
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+532]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r14b
    mov     [rsp],r15
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+544]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+4E8h]
    mov     [rsp+4F0h],rax
    mov     rax,[rsp+4C8h]
    mov     [rsp+4F8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym17]
    jmp     L95
L94:
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+556]
    call    qword ptr [image.sym18]
    jmp     L96
L95:
    mov     rax,[rsp+4F0h]
    mov     [rsp+4F8h],rax
    mov     rax,[rsp+4D8h]
    mov     rcx,[rsp+4E0h]
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+568]
    call    qword ptr [image.sym19]
    jmp     L94
L96:
    mov     rax,[rsp+4F8h]
    mov     rbx,rax
    lea     r11,[image.k1752]
    mov     [rsp+108h],r11
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L98
L97:
    mov     rcx,[rsp+0C0h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L99
L98:
    cmp     eax,1
    je      L97
    jmp     L300
L99:
    jmp     L108
L100:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L102
L101:
    mov     rdx,[rsp+0B8h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L103
L102:
    cmp     eax,1
    je      L101
    jmp     L301
L103:
    jmp     L110
L104:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L302
    mov     r11,[rsp+0C0h]
    cmp     r11,[rsp+0B8h]
    jae     L105
    mov     rsi,[rsp+0B8h]
    sub     rsi,[rsp+0C0h]
    jmp     L106
L105:
    mov     rsi,[rsp+0C0h]
    sub     rsi,[rsp+0B8h]
L106:
    cmp     rax,rsi
    setbe   al
    jmp     L111
L107:
    test    r15b,r15b
    jne     L100
    mov     r11,[rsp+0C0h]
    cmp     r11,0
    je      L303
    jmp     L100
L108:
    test    cl,cl
    jne     L107
    jmp     L303
L109:
    test    r15b,r15b
    jne     L104
    mov     r11,[rsp+0B8h]
    cmp     r11,0
    je      L303
    jmp     L104
L110:
    test    dl,dl
    jne     L109
    jmp     L303
L111:
    test    al,al
    je      L303
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0C0h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r15,[rsp+0B8h]
    lea     r15,[r15+8]
    lea     r11,[image.k1776]
    mov     [rsp+0F0h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L113
L112:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L114
L113:
    cmp     eax,1
    je      L112
    jmp     L305
L114:
    jmp     L123
L115:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L117
L116:
    mov     rdx,r15
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L118
L117:
    cmp     eax,1
    je      L116
    jmp     L306
L118:
    jmp     L125
L119:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L307
    cmp     r13,r15
    jae     L120
    mov     rsi,r15
    sub     rsi,r13
    jmp     L121
L120:
    mov     rsi,r13
    sub     rsi,r15
L121:
    cmp     rax,rsi
    setbe   al
    jmp     L126
L122:
    test    bpl,bpl
    jne     L115
    cmp     r13,0
    je      L308
    jmp     L115
L123:
    test    cl,cl
    jne     L122
    jmp     L308
L124:
    test    bpl,bpl
    jne     L119
    cmp     r15,0
    je      L308
    jmp     L119
L125:
    test    dl,dl
    jne     L124
    jmp     L308
L126:
    test    al,al
    je      L308
    mov     rdi,r15
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+0B8h]
    lea     r13,[r13+10h]
    lea     r11,[image.k1800]
    mov     [rsp+100h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L128
L127:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L129
L128:
    cmp     eax,1
    je      L127
    jmp     L310
L129:
    jmp     L138
L130:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L132
L131:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L133
L132:
    cmp     eax,1
    je      L131
    jmp     L311
L133:
    jmp     L140
L134:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L312
    cmp     rbx,r13
    jae     L135
    mov     rsi,r13
    sub     rsi,rbx
    jmp     L136
L135:
    mov     rsi,rbx
    sub     rsi,r13
L136:
    cmp     rax,rsi
    setbe   al
    jmp     L141
L137:
    test    bpl,bpl
    jne     L130
    cmp     rbx,0
    je      L313
    jmp     L130
L138:
    test    cl,cl
    jne     L137
    jmp     L313
L139:
    test    bpl,bpl
    jne     L134
    cmp     r13,0
    je      L313
    jmp     L134
L140:
    test    dl,dl
    jne     L139
    jmp     L313
L141:
    test    al,al
    je      L313
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+0B8h]
    lea     rbx,[rbx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+0F8h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L143
L142:
    mov     rcx,[rsp+0E0h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L144
L143:
    cmp     eax,1
    je      L142
    jmp     L315
L144:
    jmp     L153
L145:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L147
L146:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L148
L147:
    cmp     eax,1
    je      L146
    jmp     L316
L148:
    jmp     L155
L149:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L317
    mov     r11,[rsp+0E0h]
    cmp     r11,rbx
    jae     L150
    mov     rsi,rbx
    sub     rsi,[rsp+0E0h]
    jmp     L151
L150:
    mov     rsi,[rsp+0E0h]
    sub     rsi,rbx
L151:
    cmp     rax,rsi
    setbe   al
    jmp     L156
L152:
    test    bpl,bpl
    jne     L145
    mov     r11,[rsp+0E0h]
    cmp     r11,0
    je      L318
    jmp     L145
L153:
    test    cl,cl
    jne     L152
    jmp     L318
L154:
    test    bpl,bpl
    jne     L149
    cmp     rbx,0
    je      L318
    jmp     L149
L155:
    test    dl,dl
    jne     L154
    jmp     L318
L156:
    test    al,al
    je      L318
    mov     rdi,rbx
    mov     rsi,[rsp+0E0h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     ebx,4
    jmp     L158
L157:
    mov     r10,[rsp+50h]
    mov     [rsp+540h],r10
    jmp     L171
L158:
    mov     qword ptr [rsp+620h],0
    mov     r10,[rsp+30h]
    mov     [rsp+628h],r10
    mov     qword ptr [rsp+610h],0
    mov     r10,[rsp+30h]
    mov     [rsp+618h],r10
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFE30h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+560h],0
    mov     r10,[rsp+30h]
    mov     [rsp+568h],r10
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFE30h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFE70h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFE50h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFE10h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rbp,[rsp+50h]
    mov     r13,[rsp+48h]
    mov     r11,[rsp+40h]
    mov     [rsp+198h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+180h],r11
    mov     [rsp+120h],rbx
    mov     rbx,[rsp+40h]
    mov     r11,[rsp+38h]
    mov     [rsp+118h],r11
L159:
    lea     rax,[rsp+610h]
    mov     [rsp+588h],rax
    mov     [rsp+550h],rax
    mov     qword ptr [rsp+558h],2
    mov     rax,[rsp+618h]
    mov     rcx,[rsp+610h]
    sub     rax,rcx
    cmp     rax,0
    jbe     L160
    mov     rax,[rsp+610h]
    jmp     L161
L160:
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFDE0h
    lea     rdx,[image.k6840]
    mov     ecx,10h
    call    ryo_h_Const
    mov     eax,0
    jmp     L162
L161:
    lea     r11,[image.k6944]
    mov     [rsp+168h],r11
    mov     r11,rax
    add     r11,1
    jb      L320
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+610h],rdx
    mov     [rsp+508h],rax
    mov     qword ptr [rsp+500h],1
    lea     rdx,[rsp+620h]
    lea     r11,[image.k7064]
    mov     [rsp+160h],r11
    cmp     rax,2
    jae     L321
    lea     r12,[rdx+rax*8]
    lea     rdi,[rsp+720h]
    lea     rsi,[ro+580]
    call    qword ptr [image.sym46]
    mov     rax,[r12]
    mov     rdx,rax
    mov     eax,1
L162:
    mov     [rsp+560h],rax
    mov     [rsp+568h],rdx
    jmp     L202
L163:
    mov     rax,[rsp+568h]
    mov     [rsp+558h],rax
    lea     rdx,[rbp+rax*8]
    mov     [rsp+550h],rdx
    mov     r11,[rsp+198h]
    lea     rdx,[r11+rax*8]
    mov     [rsp+588h],rdx
    cmp     rax,0
    jne     L164
    mov     rax,[rsp+180h]
    jmp     L165
L164:
    mov     rax,r13
    sub     rax,[rsp+180h]
L165:
    mov     r10,[rsp+120h]
    mov     [rsp+580h],r10
    mov     r11,[rsp+120h]
    mov     [rsp+178h],r11
    mov     [rsp+170h],rax
    mov     [rsp+128h],rbx
    mov     [rsp+130h],rbp
    mov     [rsp+138h],r13
    mov     r11,[rsp+198h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+180h]
    mov     [rsp+148h],r11
    mov     r11,[rsp+120h]
    mov     [rsp+150h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+158h],r11
L166:
    mov     r10,[rsp+178h]
    mov     [rsp+5A8h],r10
    mov     r10,[rsp+170h]
    mov     [rsp+5A0h],r10
    mov     r11,[rsp+178h]
    cmp     r11,[rsp+170h]
    setb    dl
    mov     [rsp+577h],dl
    test    dl,dl
    jne     L204
    jmp     L205
L167:
    mov     [rsp+178h],rdx
    mov     [rsp+170h],rdi
    mov     [rsp+128h],r8
    mov     [rsp+130h],r9
    mov     [rsp+138h],rsi
    mov     [rsp+140h],rcx
    mov     [rsp+148h],r12
    mov     [rsp+150h],rax
    mov     [rsp+158h],r14
    jmp     L166
L168:
    mov     [rsp+530h],rbx
    mov     [rsp+538h],rbx
    mov     [rsp+540h],rbp
    mov     [rsp+548h],r13
    mov     [rsp+620h],rbx
    mov     [rsp+618h],r13
    jmp     L222
L169:
    mov     rax,[rsp+538h]
    mov     [rsp+530h],rax
    mov     rax,[rsp+540h]
    mov     [rsp+628h],rax
    mov     rax,[rsp+548h]
    mov     [rsp+620h],rax
L170:
    mov     rbx,[rsp+600h]
    mov     r12,[rsp+5F0h]
    mov     r13,[rsp+5E0h]
    mov     r14,[rsp+5D0h]
    mov     r15,[rsp+5C0h]
    mov     rbp,[rsp+5B0h]
    add     rsp,728h
    ret
L171:
    mov     r10,[rsp+50h]
    mov     [rsp+538h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+530h],r10
    lea     r11,[k9]
    mov     [rsp+188h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L173
L172:
    mov     rcx,[rsp+50h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L174
L173:
    cmp     eax,1
    je      L172
    jmp     L322
L174:
    jmp     L183
L175:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L177
L176:
    mov     rdx,[rsp+40h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L178
L177:
    cmp     eax,1
    je      L176
    jmp     L323
L178:
    jmp     L185
L179:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L324
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+40h]
    jae     L180
    mov     rsi,[rsp+40h]
    sub     rsi,[rsp+50h]
    jmp     L181
L180:
    mov     rsi,[rsp+50h]
    sub     rsi,[rsp+40h]
L181:
    cmp     rax,rsi
    setbe   al
    jmp     L186
L182:
    test    r14b,r14b
    jne     L175
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L325
    jmp     L175
L183:
    test    cl,cl
    jne     L182
    jmp     L325
L184:
    test    r14b,r14b
    jne     L179
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L325
    jmp     L179
L185:
    test    dl,dl
    jne     L184
    jmp     L325
L186:
    test    al,al
    je      L325
    mov     r11,[rsp+40h]
    mov     [rsp+20h],r11
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFF908h
    call    ryo_h_Memcpy
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     r14,[r11+r10*8]
    mov     [rsp+540h],r14
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*8]
    mov     [rsp+538h],rax
    mov     [rsp+530h],r14
    mov     r12,[rsp+538h]
    mov     [rsp+628h],r12
    lea     r11,[k11]
    mov     [rsp+190h],r11
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L188
L187:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L189
L188:
    cmp     eax,1
    je      L187
    jmp     L327
L189:
    jmp     L198
L190:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L192
L191:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L193
L192:
    cmp     eax,1
    je      L191
    jmp     L328
L193:
    jmp     L200
L194:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L329
    cmp     r14,r12
    jae     L195
    mov     rsi,r12
    sub     rsi,r14
    jmp     L196
L195:
    mov     rsi,r14
    sub     rsi,r12
L196:
    cmp     rax,rsi
    setbe   al
    jmp     L201
L197:
    test    r15b,r15b
    jne     L190
    cmp     r14,0
    je      L330
    jmp     L190
L198:
    test    cl,cl
    jne     L197
    jmp     L330
L199:
    test    r15b,r15b
    jne     L194
    cmp     r12,0
    je      L330
    jmp     L194
L200:
    test    dl,dl
    jne     L199
    jmp     L330
L201:
    test    al,al
    je      L330
    mov     qword ptr [rsp+20h],8
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFFE18h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFF900h
    call    ryo_h_Memcpy
    mov     ebx,1
    jmp     L158
L202:
    mov     rax,[rsp+560h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L203]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L203:
    .long   L168
    .long   L163
    .long   L349
L204:
    mov     r10,[rsp+178h]
    mov     [rsp+5A8h],r10
    jmp     L206
L205:
    mov     rbx,[rsp+128h]
    mov     rbp,[rsp+130h]
    mov     r13,[rsp+138h]
    mov     r11,[rsp+140h]
    mov     [rsp+198h],r11
    mov     r11,[rsp+148h]
    mov     [rsp+180h],r11
    mov     r11,[rsp+150h]
    mov     [rsp+120h],r11
    mov     r11,[rsp+158h]
    mov     [rsp+118h],r11
    jmp     L159
L206:
    lea     rax,[k13]
    mov     rcx,[rsp+5A8h]
    mov     r11,rcx
    add     r11,1
    jb      L332
    mov     rcx,[rsp+5A8h]
    mov     rbx,rcx
    add     rbx,1
    mov     [rsp+5A0h],rbx
    mov     [rsp+580h],rcx
    mov     qword ptr [rsp+578h],1
    mov     [rsp+570h],rcx
    mov     rdx,[rsp+550h]
    lea     r12,[rdx+rcx*8]
    mov     [rsp+5A8h],r12
    mov     rdx,[rsp+588h]
    lea     r13,[rdx+rcx*8]
    mov     [rsp+5A0h],r12
    mov     [rsp+598h],r13
    lea     r11,[k15]
    mov     [rsp+1A8h],r11
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L208
L207:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L209
L208:
    cmp     ecx,1
    je      L207
    jmp     L333
L209:
    jmp     L218
L210:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L212
L211:
    mov     rsi,r13
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L213
L212:
    cmp     ecx,1
    je      L211
    jmp     L334
L213:
    jmp     L220
L214:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L335
    cmp     r12,r13
    jae     L215
    mov     rdi,r13
    sub     rdi,r12
    jmp     L216
L215:
    mov     rdi,r12
    sub     rdi,r13
L216:
    cmp     rcx,rdi
    setbe   cl
    jmp     L221
L217:
    test    r15b,r15b
    jne     L210
    cmp     r12,0
    je      L336
    jmp     L210
L218:
    test    dl,dl
    jne     L217
    jmp     L336
L219:
    test    r15b,r15b
    jne     L214
    cmp     r13,0
    je      L336
    jmp     L214
L220:
    test    sil,sil
    jne     L219
    jmp     L336
L221:
    test    cl,cl
    je      L336
    mov     [rsp+20h],r13
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    mov     edx,0FFFFFE88h
    mov     ecx,0FFFFF908h
    call    ryo_h_Memcpy
    mov     rcx,[rsp+588h]
    mov     rdi,rcx
    mov     rsi,r13
    mov     rdx,[rsp+158h]
    call    qword ptr [fn17.slot]
    mov     rdx,rbx
    mov     rdi,[rsp+170h]
    mov     r8,[rsp+128h]
    mov     r9,[rsp+130h]
    mov     rsi,[rsp+138h]
    mov     rcx,[rsp+140h]
    mov     r12,[rsp+148h]
    mov     rax,[rsp+150h]
    mov     r14,[rsp+158h]
    jmp     L167
L222:
    mov     rbx,[rsp+620h]
    mov     [rsp+610h],rbx
    lea     r11,[k18]
    mov     [rsp+1A0h],r11
    mov     r13,[rsp+618h]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L224
L223:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L225
L224:
    cmp     ecx,1
    je      L223
    jmp     L338
L225:
    jmp     L227
L226:
    cmp     rbx,0
    je      L339
    jmp     L228
L227:
    test    dl,dl
    jne     L226
    jmp     L339
L228:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    cmp     r13,rcx
    ja      L339
    mov     rbx,[rsp+620h]
    mov     [rsp+568h],rbx
    mov     r13,[rsp+618h]
    mov     [rsp+610h],r13
    mov     [rsp+628h],rbx
    mov     [rsp+530h],r13
    mov     r15,[rsp+540h]
    mov     [rsp+620h],r15
    mov     [rsp+520h],rbx
    mov     rdi,r13
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     rcx,rax
    cmp     rcx,0
    setne   dl
    mov     [rsp+527h],dl
    lea     rdx,[rbx+rcx*8]
    mov     rsi,rcx
    sub     rsi,1
    mov     [rsp+520h],rsi
    lea     rsi,[rbx+rsi*8]
    mov     rdi,r13
    sub     rdi,1
    lea     r8,[rbx+rdi*8]
    mov     [rsp+520h],r15
    lea     rdi,[r15+rdi*8]
    mov     [rsp+1F0h],rcx
    mov     ecx,0
    mov     [rsp+1E8h],rsi
    mov     [rsp+1B8h],rbx
    mov     [rsp+1B0h],rdx
    mov     [rsp+1C0h],r15
    mov     r11,[rsp+118h]
    mov     [rsp+1E0h],r11
    mov     [rsp+1D0h],r8
    mov     [rsp+1D8h],rdi
    mov     [rsp+1C8h],r13
L229:
    mov     [rsp+518h],rcx
    mov     r10,[rsp+1F0h]
    mov     [rsp+510h],r10
    cmp     rcx,[rsp+1F0h]
    setb    dl
    mov     [rsp+527h],dl
    test    dl,dl
    jne     L236
    jmp     L237
L230:
    mov     r13,[rsp+510h]
    mov     rbx,[rsp+518h]
    mov     r11,[rsp+520h]
    mov     [rsp+1F8h],r11
    lea     r8,[rsp+510h]
    mov     rcx,rdi
    mov     rdi,r8
    mov     r8,r12
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [image.fn64.slot]
    mov     rdx,[rsp+510h]
    mov     rsi,[rsp+518h]
    mov     rdi,[rsp+520h]
    mov     rcx,rbp
    mov     [rsp+1F0h],r15
    mov     [rsp+1E8h],rdx
    mov     [rsp+1B8h],r13
    mov     [rsp+1B0h],rbx
    mov     r11,[rsp+1F8h]
    mov     [rsp+1C0h],r11
    mov     [rsp+1E0h],r12
    mov     [rsp+1D0h],rsi
    mov     [rsp+1D8h],rdi
    mov     [rsp+1C8h],r14
    jmp     L229
L231:
    mov     rdx,[rsp+1B8h]
    mov     rsi,[rsp+1B0h]
    jmp     L235
L232:
    mov     rdx,[rsp+520h]
    mov     r11,[rsp+1B8h]
    cmp     r11,rdx
    setb    dl
    mov     [rsp+516h],dl
    test    dl,dl
    je      L233
    mov     rbx,[rsp+1B8h]
    jmp     L234
L233:
    mov     rbx,[rsp+1B0h]
L234:
    jmp     L240
L235:
    mov     rdi,[rsp+520h]
    cmp     rdx,rdi
    jne     L347
    mov     rdx,[rsp+518h]
    cmp     rsi,rdx
    je      L169
    jmp     L347
L236:
    mov     [rsp+518h],rcx
    jmp     L238
L237:
    mov     rcx,[rsp+1E8h]
    lea     rcx,[rcx+8]
    mov     [rsp+520h],rcx
    jmp     L239
L238:
    lea     rcx,[image.k2336]
    mov     rdx,[rsp+518h]
    mov     r11,rdx
    add     r11,1
    jb      L341
    mov     rdx,[rsp+518h]
    mov     r12,rdx
    add     r12,1
    mov     [rsp+510h],r12
    lea     rdx,[rsp+510h]
    mov     rdi,rdx
    mov     rsi,[rsp+1B8h]
    mov     rdx,[rsp+1B0h]
    mov     rcx,[rsp+1C0h]
    mov     r8,[rsp+1E0h]
    call    qword ptr [image.fn83.slot]
    mov     rdx,[rsp+1E8h]
    mov     rsi,[rsp+1D0h]
    mov     rdi,[rsp+1D8h]
    mov     rbp,r12
    mov     r12,[rsp+1E0h]
    mov     r15,[rsp+1F0h]
    mov     r14,[rsp+1C8h]
    jmp     L230
L239:
    mov     rdx,[rsp+1D0h]
    lea     rdx,[rdx+8]
    mov     [rsp+518h],rdx
    mov     rdi,[rsp+1C8h]
    mov     esi,2
    call    ryo_hr_RemUW64
    mov     rdx,rax
    cmp     rdx,0
    sete    dl
    mov     [rsp+517h],dl
    test    dl,dl
    jne     L231
    jmp     L232
L240:
    lea     r12,[image.k2360]
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L242
L241:
    mov     rsi,rbx
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L243
L242:
    cmp     edx,1
    je      L241
    jmp     L342
L243:
    jmp     L252
L244:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L246
L245:
    mov     rdi,[rsp+1C0h]
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L247
L246:
    cmp     edx,1
    je      L245
    jmp     L343
L247:
    jmp     L254
L248:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L344
    cmp     rbx,[rsp+1C0h]
    jae     L249
    mov     r8,[rsp+1C0h]
    sub     r8,rbx
    jmp     L250
L249:
    mov     r8,rbx
    sub     r8,[rsp+1C0h]
L250:
    cmp     rdx,r8
    setbe   dl
    jmp     L255
L251:
    test    r13b,r13b
    jne     L244
    cmp     rbx,0
    je      L345
    jmp     L244
L252:
    test    sil,sil
    jne     L251
    jmp     L345
L253:
    test    r13b,r13b
    jne     L248
    mov     r11,[rsp+1C0h]
    cmp     r11,0
    je      L345
    jmp     L248
L254:
    test    dil,dil
    jne     L253
    jmp     L345
L255:
    test    dl,dl
    je      L345
    mov     rdi,[rsp+1C0h]
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   edx,byte ptr [rsp+516h]
    movzx   esi,dl
    mov     r11,[rsp+1B8h]
    lea     rsi,[r11+rsi*8]
    xor     edx,1
    mov     [rsp+515h],dl
    movzx   edx,dl
    mov     r11,[rsp+1B0h]
    lea     rdx,[r11+rdx*8]
    mov     r10,rdx
    mov     rdx,rsi
    mov     rsi,r10
    jmp     L235
    mov     rbx,rax
    jmp     L257
L256:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L257:
    mov     rdi,[rsp+0B0h]
    call    qword ptr [image.sym17]
    jmp     L256
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L259
L258:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L259:
    lea     rdx,[rsp+270h]
    mov     rdi,rdx
    call    qword ptr [image.fn37.slot]
    jmp     L258
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L261
L260:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L261:
    mov     rdi,[rsp+78h]
    call    qword ptr [image.sym17]
    jmp     L260
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L263
L262:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L263:
    mov     rdi,[rsp+0A8h]
    call    qword ptr [image.sym17]
    jmp     L262
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L265
L264:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L265:
    mov     rdi,[rsp+90h]
    call    qword ptr [image.sym17]
    jmp     L264
    call    qword ptr [sym21]
    ud2
L266:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L267:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L268:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L270
    jmp     L270
L269:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L270:
    call    qword ptr [image.sym10]
    ud2
L271:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L272:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L273:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L275
    jmp     L275
L274:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L275:
    call    qword ptr [image.sym10]
    ud2
L276:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L277:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L278:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L280
    jmp     L280
L279:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L280:
    call    qword ptr [image.sym10]
    ud2
L281:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L282:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L283:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L285
    jmp     L285
L284:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L285:
    call    qword ptr [image.sym10]
    ud2
    mov     rbx,rax
    jmp     L287
L286:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L287:
    mov     rdi,[rsp+0D8h]
    call    qword ptr [image.sym17]
    jmp     L286
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L289
L288:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L289:
    mov     rdi,[rsp+110h]
    call    qword ptr [image.sym17]
    jmp     L288
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L291
L290:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L291:
    mov     rdi,[rsp+0E8h]
    call    qword ptr [image.sym17]
    jmp     L290
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L293
L292:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L293:
    lea     rdx,[rsp+430h]
    mov     rdi,rdx
    call    qword ptr [image.fn37.slot]
    jmp     L292
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L295
L294:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L295:
    lea     rdx,[rsp+470h]
    mov     rdi,rdx
    call    qword ptr [image.fn37.slot]
    jmp     L294
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L297
L296:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L297:
    lea     rdx,[rsp+4B0h]
    mov     rdi,rdx
    call    qword ptr [image.fn200.slot]
    jmp     L296
    call    qword ptr [sym21]
    ud2
    mov     rbx,rax
    jmp     L299
L298:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L299:
    lea     rdx,[rsp+4F0h]
    mov     rdi,rdx
    call    qword ptr [image.fn37.slot]
    jmp     L298
    call    qword ptr [sym21]
    ud2
L300:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L301:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L302:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L304
    jmp     L304
L303:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+108h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L304:
    call    qword ptr [image.sym10]
    ud2
L305:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L306:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L307:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L309
    jmp     L309
L308:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L309:
    call    qword ptr [image.sym10]
    ud2
L310:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L311:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L312:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L314
    jmp     L314
L313:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L314:
    call    qword ptr [image.sym10]
    ud2
L315:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L316:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L317:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L319
    jmp     L319
L318:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L319:
    call    qword ptr [image.sym10]
    ud2
L320:
    lea     rdx,[image.k7768]
    mov     rdi,rdx
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+168h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L321:
    lea     rdx,[image.k9969]
    mov     rdi,rdx
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+160h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L322:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L323:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L324:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L326
    jmp     L326
L325:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+188h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L326:
    call    qword ptr [image.sym10]
    ud2
L327:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L328:
    lea     rdx,[image.k6432]
    lea     rsi,[image.k6560]
    mov     rdi,rdx
    mov     rdx,rsi
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L329:
    lea     rdx,[image.k9346]
    mov     rdi,rdx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L331
    jmp     L331
L330:
    lea     rdx,[image.k8338]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+190h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L331:
    call    qword ptr [image.sym10]
    ud2
L332:
    lea     rdx,[image.k7768]
    mov     rdi,rdx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L333:
    lea     rax,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L334:
    lea     rax,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L335:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L337
    jmp     L337
L336:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+1A8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L337:
    call    qword ptr [image.sym10]
    ud2
L338:
    lea     rax,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
    jmp     L340
L339:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+1A0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L340:
    call    qword ptr [image.sym10]
    ud2
L341:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L342:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L343:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L344:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L346
    jmp     L346
L345:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L346:
    call    qword ptr [image.sym10]
    ud2
L347:
    call    qword ptr [image.sym30]
    ud2
L348:
    lea     rdi,[rsp+720h]
    call    ryo_h_Abort
    ud2
L349:
    ud2
L350:
    lea     rax,[rsp+610h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L351
    jmp     L353
L351:
    mov     [rsp+20h],rax
    lea     rdi,[rsp+720h]
    mov     esi,0FFFFF900h
    call    ryo_h_Resume
    ud2
L352:
    lea     rax,[rsp+538h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    mov     rax,r12
    jmp     L351
    jmp     L353
    mov     rbx,rax
    jmp     L354
    mov     r12,rax
    jmp     L352
L353:
    call    qword ptr [sym21]
    ud2
L354:
    jmp     L350
  ; OSR entries
    lea     r11,[L355]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L355:
    .long   L356
    .long   L357
    .long   L358
    .long   L359
    .long   L360
    .long   L361
    .long   L362
    .long   L363
    .long   L364
    .long   L365
L356:
    ret
L357:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-7E0h]
    mov     r11,[rdx-98h]
    mov     [rsp],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-160h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-148h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-140h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-138h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+0B0h],r11
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-588h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5A0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-608h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+0C0h]
    jmp     L159
L358:
    ret
L359:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-7F0h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-58h]
    mov     [rsp+8],r11
    mov     r11,[rdx-98h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-160h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-148h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-140h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-138h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+0B0h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+0B8h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+0C0h],r11
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp]
    mov     [rdx-5A8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5B0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5F8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-5F0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-5D0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-5C8h],r11
    lea     rsp,[rsp+0D0h]
    jmp     L166
L360:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-7F0h]
    mov     r11,[rdx-60h]
    mov     [rsp],r11
    mov     r11,[rdx-58h]
    mov     [rsp+8],r11
    mov     r11,[rdx-98h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-160h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-158h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-150h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-148h]
    mov     [rsp+70h],r11
    mov     r11,[rdx-140h]
    mov     [rsp+78h],r11
    mov     r11,[rdx-138h]
    mov     [rsp+80h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+88h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+90h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+98h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+0A0h],r11
    mov     r11,[rdx-0F0h]
    mov     [rsp+0A8h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+0B0h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+0B8h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+0C0h],r11
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+78h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+80h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+88h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+90h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+98h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+0A0h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+0A8h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+0B0h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+0B8h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+0C0h]
    mov     [rdx-1D8h],r11
    mov     rdi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     r12,[rsp+30h]
    mov     rax,[rsp+38h]
    mov     r14,[rsp+40h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+0D0h]
    jmp     L167
L361:
    ret
L362:
    ret
L363:
    ret
L364:
    ret
L365:
    ret

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,288h
    mov     [rsp+270h],rbx
    mov     [rsp+260h],r12
    mov     [rsp+250h],r13
    mov     [rsp+240h],r14
    mov     [rsp+230h],r15
    mov     [rsp+220h],rbp
    mov     [rsp+68h],rdi
    mov     [rsp+40h],rdx
    cmp     rsi,9
    jb      L621
    mov     r13,[rsp+68h]
    lea     r13,[r13+0Ch]
    mov     r11,[rsp+68h]
    mov     eax,[r11+0Ch]
    mov     r11,[rsp+68h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,[rsp+68h]
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,[rsp+68h]
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+110h],eax
    mov     ebp,0
    jmp     L1
L0:
    lea     r14,[rsp+110h]
    jmp     L18
L1:
    lea     r11,[image.k2088]
    mov     [rsp+30h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L479
L4:
    jmp     L10
L5:
    test    bpl,bpl
    je      L9
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,[rsp+68h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L480
L8:
    jmp     L12
L9:
    cmp     r15,0
    je      L482
    jmp     L13
L10:
    test    cl,cl
    jne     L5
    jmp     L482
L11:
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L482
    jmp     L17
L12:
    test    dl,dl
    jne     L17
    jmp     L482
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L15
L14:
    mov     rcx,[rsp+68h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L16
L15:
    cmp     eax,1
    je      L14
    jmp     L481
L16:
    test    cl,cl
    jne     L11
    jmp     L482
L17:
    mov     rdi,[rsp+68h]
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L18:
    lea     r11,[image.k2112]
    mov     [rsp+38h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L20
L19:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L21
L20:
    cmp     eax,1
    je      L19
    jmp     L484
L21:
    jmp     L30
L22:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L24
L23:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L25
L24:
    cmp     eax,1
    je      L23
    jmp     L485
L25:
    jmp     L32
L26:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L486
    cmp     r14,r13
    jae     L27
    mov     rsi,r13
    sub     rsi,r14
    jmp     L28
L27:
    mov     rsi,r14
    sub     rsi,r13
L28:
    cmp     rax,rsi
    setbe   al
    jmp     L33
L29:
    test    bpl,bpl
    jne     L22
    cmp     r14,0
    je      L487
    jmp     L22
L30:
    test    cl,cl
    jne     L29
    jmp     L487
L31:
    test    bpl,bpl
    jne     L26
    cmp     r13,0
    je      L487
    jmp     L26
L32:
    test    dl,dl
    jne     L31
    jmp     L487
L33:
    test    al,al
    je      L487
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+68h]
    lea     r13,[r13+4]
    mov     r14,[rsp+68h]
    lea     r14,[r14+1Ch]
    mov     r11,[rsp+68h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    al
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+120h],eax
    mov     r12d,0
    jmp     L35
L34:
    lea     rbp,[rsp+120h]
    jmp     L52
L35:
    lea     r11,[image.k2088]
    mov     [rsp+48h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L37
L36:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L38
L37:
    cmp     eax,1
    je      L36
    jmp     L489
L38:
    jmp     L44
L39:
    test    r12b,r12b
    je      L43
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L41
L40:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L42
L41:
    cmp     eax,1
    je      L40
    jmp     L490
L42:
    jmp     L46
L43:
    cmp     r15,0
    je      L492
    jmp     L47
L44:
    test    cl,cl
    jne     L39
    jmp     L492
L45:
    cmp     r13,0
    je      L492
    jmp     L51
L46:
    test    dl,dl
    jne     L51
    jmp     L492
L47:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L49
L48:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L50
L49:
    cmp     eax,1
    je      L48
    jmp     L491
L50:
    test    cl,cl
    jne     L45
    jmp     L492
L51:
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L34
L52:
    lea     r11,[image.k2112]
    mov     [rsp+50h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L54
L53:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L55
L54:
    cmp     eax,1
    je      L53
    jmp     L494
L55:
    jmp     L64
L56:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L58
L57:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L59
L58:
    cmp     eax,1
    je      L57
    jmp     L495
L59:
    jmp     L66
L60:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L496
    cmp     rbp,r14
    jae     L61
    mov     rsi,r14
    sub     rsi,rbp
    jmp     L62
L61:
    mov     rsi,rbp
    sub     rsi,r14
L62:
    cmp     rax,rsi
    setbe   al
    jmp     L67
L63:
    test    r13b,r13b
    jne     L56
    cmp     rbp,0
    je      L497
    jmp     L56
L64:
    test    cl,cl
    jne     L63
    jmp     L497
L65:
    test    r13b,r13b
    jne     L60
    cmp     r14,0
    je      L497
    jmp     L60
L66:
    test    dl,dl
    jne     L65
    jmp     L497
L67:
    test    al,al
    je      L497
    mov     rdi,r14
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+68h]
    lea     r13,[r13+8]
    mov     r14,[rsp+68h]
    lea     r14,[r14+14h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+14h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+8]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+130h],eax
    mov     r12d,0
    jmp     L69
L68:
    lea     r15,[rsp+130h]
    jmp     L86
L69:
    lea     r11,[image.k2088]
    mov     [rsp+58h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L71
L70:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L72
L71:
    cmp     eax,1
    je      L70
    jmp     L499
L72:
    jmp     L78
L73:
    test    r12b,r12b
    je      L77
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L75
L74:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L76
L75:
    cmp     eax,1
    je      L74
    jmp     L500
L76:
    jmp     L80
L77:
    cmp     rbp,0
    je      L502
    jmp     L81
L78:
    test    cl,cl
    jne     L73
    jmp     L502
L79:
    cmp     r13,0
    je      L502
    jmp     L85
L80:
    test    dl,dl
    jne     L85
    jmp     L502
L81:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L83
L82:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L84
L83:
    cmp     eax,1
    je      L82
    jmp     L501
L84:
    test    cl,cl
    jne     L79
    jmp     L502
L85:
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L68
L86:
    lea     r11,[image.k2112]
    mov     [rsp+60h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L88
L87:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L89
L88:
    cmp     eax,1
    je      L87
    jmp     L504
L89:
    jmp     L98
L90:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L92
L91:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L93
L92:
    cmp     eax,1
    je      L91
    jmp     L505
L93:
    jmp     L100
L94:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L506
    cmp     r15,r14
    jae     L95
    mov     rsi,r14
    sub     rsi,r15
    jmp     L96
L95:
    mov     rsi,r15
    sub     rsi,r14
L96:
    cmp     rax,rsi
    setbe   al
    jmp     L101
L97:
    test    r13b,r13b
    jne     L90
    cmp     r15,0
    je      L507
    jmp     L90
L98:
    test    cl,cl
    jne     L97
    jmp     L507
L99:
    test    r13b,r13b
    jne     L94
    cmp     r14,0
    je      L507
    jmp     L94
L100:
    test    dl,dl
    jne     L99
    jmp     L507
L101:
    test    al,al
    je      L507
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+68h]
    lea     r13,[r13+10h]
    mov     r14,[rsp+68h]
    lea     r14,[r14+20h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+10h]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     [rsp+150h],r13
    mov     [rsp+148h],r13
    mov     [rsp+150h],r14
    lea     r12,[rsp+148h]
    lea     rbx,[rsp+150h]
    mov     [rsp+158h],rbx
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+280h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],rbx
    mov     [rsp+10h],r12
    lea     rdi,[rsp+280h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+158h]
    mov     [rsp+160h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+168h],rax
    mov     rdi,rax
    call    qword ptr [image.sym13]
    jmp     L103
L102:
    lea     rdi,[rsp+280h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym14]
    jmp     L104
L103:
    mov     rax,[rsp+160h]
    mov     [rsp+168h],rax
    mov     rax,[rsp+148h]
    mov     rcx,[rsp+150h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+280h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym15]
    jmp     L102
L104:
    mov     rax,[rsp+168h]
    mov     eax,[rax]
    mov     [rsp+170h],eax
    mov     r12d,0
    jmp     L106
L105:
    lea     rbx,[rsp+170h]
    jmp     L123
L106:
    lea     r15,[image.k2088]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L108
L107:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L109
L108:
    cmp     eax,1
    je      L107
    jmp     L511
L109:
    jmp     L115
L110:
    test    r12b,r12b
    je      L114
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L112
L111:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L113
L112:
    cmp     eax,1
    je      L111
    jmp     L512
L113:
    jmp     L117
L114:
    cmp     rbp,0
    je      L514
    jmp     L118
L115:
    test    cl,cl
    jne     L110
    jmp     L514
L116:
    cmp     r13,0
    je      L514
    jmp     L122
L117:
    test    dl,dl
    jne     L122
    jmp     L514
L118:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L120
L119:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L121
L120:
    cmp     eax,1
    je      L119
    jmp     L513
L121:
    test    cl,cl
    jne     L116
    jmp     L514
L122:
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L105
L123:
    lea     r11,[image.k2112]
    mov     [rsp+80h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L125
L124:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L126
L125:
    cmp     eax,1
    je      L124
    jmp     L516
L126:
    jmp     L135
L127:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L129
L128:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L130
L129:
    cmp     eax,1
    je      L128
    jmp     L517
L130:
    jmp     L137
L131:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L518
    cmp     rbx,r14
    jae     L132
    mov     rsi,r14
    sub     rsi,rbx
    jmp     L133
L132:
    mov     rsi,rbx
    sub     rsi,r14
L133:
    cmp     rax,rsi
    setbe   al
    jmp     L138
L134:
    test    r13b,r13b
    jne     L127
    cmp     rbx,0
    je      L519
    jmp     L127
L135:
    test    cl,cl
    jne     L134
    jmp     L519
L136:
    test    r13b,r13b
    jne     L131
    cmp     r14,0
    je      L519
    jmp     L131
L137:
    test    dl,dl
    jne     L136
    jmp     L519
L138:
    test    al,al
    je      L519
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+68h]
    lea     rbx,[rbx+1Ch]
    mov     r11,[rsp+68h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+68h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,[rsp+68h]
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,[rsp+68h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+180h],eax
    mov     ebp,0
    jmp     L140
L139:
    lea     r13,[rsp+180h]
    jmp     L157
L140:
    lea     r11,[image.k2088]
    mov     [rsp+70h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L142
L141:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L143
L142:
    cmp     eax,1
    je      L141
    jmp     L521
L143:
    jmp     L149
L144:
    test    bpl,bpl
    je      L148
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L146
L145:
    mov     rdx,[rsp+68h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L147
L146:
    cmp     eax,1
    je      L145
    jmp     L522
L147:
    jmp     L151
L148:
    cmp     r14,0
    je      L524
    jmp     L152
L149:
    test    cl,cl
    jne     L144
    jmp     L524
L150:
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L524
    jmp     L156
L151:
    test    dl,dl
    jne     L156
    jmp     L524
L152:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L154
L153:
    mov     rcx,[rsp+68h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L155
L154:
    cmp     eax,1
    je      L153
    jmp     L523
L155:
    test    cl,cl
    jne     L150
    jmp     L524
L156:
    mov     rdi,[rsp+68h]
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L139
L157:
    lea     r11,[image.k2112]
    mov     [rsp+78h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L159
L158:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L160
L159:
    cmp     eax,1
    je      L158
    jmp     L526
L160:
    jmp     L169
L161:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L163
L162:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L164
L163:
    cmp     eax,1
    je      L162
    jmp     L527
L164:
    jmp     L171
L165:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L528
    cmp     r13,rbx
    jae     L166
    mov     rsi,rbx
    sub     rsi,r13
    jmp     L167
L166:
    mov     rsi,r13
    sub     rsi,rbx
L167:
    cmp     rax,rsi
    setbe   al
    jmp     L172
L168:
    test    bpl,bpl
    jne     L161
    cmp     r13,0
    je      L529
    jmp     L161
L169:
    test    cl,cl
    jne     L168
    jmp     L529
L170:
    test    bpl,bpl
    jne     L165
    cmp     rbx,0
    je      L529
    jmp     L165
L171:
    test    dl,dl
    jne     L170
    jmp     L529
L172:
    test    al,al
    je      L529
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+68h]
    lea     rbx,[rbx+8]
    mov     r13,[rsp+68h]
    lea     r13,[r13+10h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+10h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+8]
    cmp     eax,ecx
    setb    al
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+190h],eax
    mov     r12d,0
    jmp     L174
L173:
    lea     rbp,[rsp+190h]
    jmp     L191
L174:
    lea     r11,[image.k2088]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L176
L175:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L177
L176:
    cmp     eax,1
    je      L175
    jmp     L531
L177:
    jmp     L183
L178:
    test    r12b,r12b
    je      L182
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L180
L179:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L181
L180:
    cmp     eax,1
    je      L179
    jmp     L532
L181:
    jmp     L185
L182:
    cmp     r14,0
    je      L534
    jmp     L186
L183:
    test    cl,cl
    jne     L178
    jmp     L534
L184:
    cmp     rbx,0
    je      L534
    jmp     L190
L185:
    test    dl,dl
    jne     L190
    jmp     L534
L186:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L188
L187:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L189
L188:
    cmp     eax,1
    je      L187
    jmp     L533
L189:
    test    cl,cl
    jne     L184
    jmp     L534
L190:
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L173
L191:
    lea     r11,[image.k2112]
    mov     [rsp+90h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L193
L192:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L194
L193:
    cmp     eax,1
    je      L192
    jmp     L536
L194:
    jmp     L203
L195:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L197
L196:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L198
L197:
    cmp     eax,1
    je      L196
    jmp     L537
L198:
    jmp     L205
L199:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L538
    cmp     rbp,r13
    jae     L200
    mov     rsi,r13
    sub     rsi,rbp
    jmp     L201
L200:
    mov     rsi,rbp
    sub     rsi,r13
L201:
    cmp     rax,rsi
    setbe   al
    jmp     L206
L202:
    test    r12b,r12b
    jne     L195
    cmp     rbp,0
    je      L539
    jmp     L195
L203:
    test    cl,cl
    jne     L202
    jmp     L539
L204:
    test    r12b,r12b
    jne     L199
    cmp     r13,0
    je      L539
    jmp     L199
L205:
    test    dl,dl
    jne     L204
    jmp     L539
L206:
    test    al,al
    je      L539
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+0Ch]
    mov     r13,[rsp+68h]
    lea     r13,[r13+20h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1A0h],eax
    mov     ebx,0
    jmp     L208
L207:
    lea     r14,[rsp+1A0h]
    jmp     L225
L208:
    lea     r11,[image.k2088]
    mov     [rsp+98h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L210
L209:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L211
L210:
    cmp     eax,1
    je      L209
    jmp     L541
L211:
    jmp     L217
L212:
    test    bl,bl
    je      L216
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L214
L213:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L215
L214:
    cmp     eax,1
    je      L213
    jmp     L542
L215:
    jmp     L219
L216:
    cmp     rbp,0
    je      L544
    jmp     L220
L217:
    test    cl,cl
    jne     L212
    jmp     L544
L218:
    cmp     r12,0
    je      L544
    jmp     L224
L219:
    test    dl,dl
    jne     L224
    jmp     L544
L220:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L222
L221:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L223
L222:
    cmp     eax,1
    je      L221
    jmp     L543
L223:
    test    cl,cl
    jne     L218
    jmp     L544
L224:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L207
L225:
    lea     r11,[image.k2112]
    mov     [rsp+0A0h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L227
L226:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L228
L227:
    cmp     eax,1
    je      L226
    jmp     L546
L228:
    jmp     L237
L229:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L231
L230:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L232
L231:
    cmp     eax,1
    je      L230
    jmp     L547
L232:
    jmp     L239
L233:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L548
    cmp     r14,r13
    jae     L234
    mov     rsi,r13
    sub     rsi,r14
    jmp     L235
L234:
    mov     rsi,r14
    sub     rsi,r13
L235:
    cmp     rax,rsi
    setbe   al
    jmp     L240
L236:
    test    r12b,r12b
    jne     L229
    cmp     r14,0
    je      L549
    jmp     L229
L237:
    test    cl,cl
    jne     L236
    jmp     L549
L238:
    test    r12b,r12b
    jne     L233
    cmp     r13,0
    je      L549
    jmp     L233
L239:
    test    dl,dl
    jne     L238
    jmp     L549
L240:
    test    al,al
    je      L549
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+14h]
    mov     r13,[rsp+68h]
    lea     r13,[r13+18h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+18h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+14h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1B0h],eax
    mov     ebx,0
    jmp     L242
L241:
    lea     r14,[rsp+1B0h]
    jmp     L259
L242:
    lea     r11,[image.k2088]
    mov     [rsp+0A8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L244
L243:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L245
L244:
    cmp     eax,1
    je      L243
    jmp     L551
L245:
    jmp     L251
L246:
    test    bl,bl
    je      L250
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L248
L247:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L249
L248:
    cmp     eax,1
    je      L247
    jmp     L552
L249:
    jmp     L253
L250:
    cmp     rbp,0
    je      L554
    jmp     L254
L251:
    test    cl,cl
    jne     L246
    jmp     L554
L252:
    cmp     r12,0
    je      L554
    jmp     L258
L253:
    test    dl,dl
    jne     L258
    jmp     L554
L254:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L256
L255:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L257
L256:
    cmp     eax,1
    je      L255
    jmp     L553
L257:
    test    cl,cl
    jne     L252
    jmp     L554
L258:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L241
L259:
    lea     r11,[image.k2112]
    mov     [rsp+0C0h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L261
L260:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L262
L261:
    cmp     eax,1
    je      L260
    jmp     L556
L262:
    jmp     L271
L263:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L265
L264:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L266
L265:
    cmp     eax,1
    je      L264
    jmp     L557
L266:
    jmp     L273
L267:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L558
    cmp     r14,r13
    jae     L268
    mov     rsi,r13
    sub     rsi,r14
    jmp     L269
L268:
    mov     rsi,r14
    sub     rsi,r13
L269:
    cmp     rax,rsi
    setbe   al
    jmp     L274
L270:
    test    r12b,r12b
    jne     L263
    cmp     r14,0
    je      L559
    jmp     L263
L271:
    test    cl,cl
    jne     L270
    jmp     L559
L272:
    test    r12b,r12b
    jne     L267
    cmp     r13,0
    je      L559
    jmp     L267
L273:
    test    dl,dl
    jne     L272
    jmp     L559
L274:
    test    al,al
    je      L559
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+8]
    mov     r11,[rsp+68h]
    mov     eax,[r11+8]
    mov     r11,[rsp+68h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,[rsp+68h]
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,[rsp+68h]
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1C0h],eax
    mov     ebp,0
    jmp     L276
L275:
    lea     r13,[rsp+1C0h]
    jmp     L293
L276:
    lea     r11,[image.k2088]
    mov     [rsp+0B0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L278
L277:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L279
L278:
    cmp     eax,1
    je      L277
    jmp     L561
L279:
    jmp     L285
L280:
    test    bpl,bpl
    je      L284
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L282
L281:
    mov     rdx,[rsp+68h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L283
L282:
    cmp     eax,1
    je      L281
    jmp     L562
L283:
    jmp     L287
L284:
    cmp     r14,0
    je      L564
    jmp     L288
L285:
    test    cl,cl
    jne     L280
    jmp     L564
L286:
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L564
    jmp     L292
L287:
    test    dl,dl
    jne     L292
    jmp     L564
L288:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L290
L289:
    mov     rcx,[rsp+68h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L291
L290:
    cmp     eax,1
    je      L289
    jmp     L563
L291:
    test    cl,cl
    jne     L286
    jmp     L564
L292:
    mov     rdi,[rsp+68h]
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L275
L293:
    lea     r11,[image.k2112]
    mov     [rsp+0B8h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L295
L294:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L296
L295:
    cmp     eax,1
    je      L294
    jmp     L566
L296:
    jmp     L305
L297:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L299
L298:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L300
L299:
    cmp     eax,1
    je      L298
    jmp     L567
L300:
    jmp     L307
L301:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L568
    cmp     r13,r12
    jae     L302
    mov     rsi,r12
    sub     rsi,r13
    jmp     L303
L302:
    mov     rsi,r13
    sub     rsi,r12
L303:
    cmp     rax,rsi
    setbe   al
    jmp     L308
L304:
    test    bpl,bpl
    jne     L297
    cmp     r13,0
    je      L569
    jmp     L297
L305:
    test    cl,cl
    jne     L304
    jmp     L569
L306:
    test    bpl,bpl
    jne     L301
    cmp     r12,0
    je      L569
    jmp     L301
L307:
    test    dl,dl
    jne     L306
    jmp     L569
L308:
    test    al,al
    je      L569
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+4]
    mov     r13,[rsp+68h]
    lea     r13,[r13+0Ch]
    mov     r11,[rsp+68h]
    mov     eax,[r11+0Ch]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    al
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1D0h],eax
    mov     ebx,0
    jmp     L310
L309:
    lea     rbp,[rsp+1D0h]
    jmp     L327
L310:
    lea     r11,[image.k2088]
    mov     [rsp+0C8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L312
L311:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L313
L312:
    cmp     eax,1
    je      L311
    jmp     L571
L313:
    jmp     L319
L314:
    test    bl,bl
    je      L318
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L316
L315:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L317
L316:
    cmp     eax,1
    je      L315
    jmp     L572
L317:
    jmp     L321
L318:
    cmp     r14,0
    je      L574
    jmp     L322
L319:
    test    cl,cl
    jne     L314
    jmp     L574
L320:
    cmp     r12,0
    je      L574
    jmp     L326
L321:
    test    dl,dl
    jne     L326
    jmp     L574
L322:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L324
L323:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L325
L324:
    cmp     eax,1
    je      L323
    jmp     L573
L325:
    test    cl,cl
    jne     L320
    jmp     L574
L326:
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L309
L327:
    lea     r11,[image.k2112]
    mov     [rsp+0D0h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L329
L328:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L330
L329:
    cmp     eax,1
    je      L328
    jmp     L576
L330:
    jmp     L339
L331:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L333
L332:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L334
L333:
    cmp     eax,1
    je      L332
    jmp     L577
L334:
    jmp     L341
L335:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L578
    cmp     rbp,r13
    jae     L336
    mov     rsi,r13
    sub     rsi,rbp
    jmp     L337
L336:
    mov     rsi,rbp
    sub     rsi,r13
L337:
    cmp     rax,rsi
    setbe   al
    jmp     L342
L338:
    test    r12b,r12b
    jne     L331
    cmp     rbp,0
    je      L579
    jmp     L331
L339:
    test    cl,cl
    jne     L338
    jmp     L579
L340:
    test    r12b,r12b
    jne     L335
    cmp     r13,0
    je      L579
    jmp     L335
L341:
    test    dl,dl
    jne     L340
    jmp     L579
L342:
    test    al,al
    je      L579
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+10h]
    mov     r13,[rsp+68h]
    lea     r13,[r13+14h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+14h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+10h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1E0h],eax
    mov     ebx,0
    jmp     L344
L343:
    lea     r14,[rsp+1E0h]
    jmp     L361
L344:
    lea     r11,[image.k2088]
    mov     [rsp+0D8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L346
L345:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L347
L346:
    cmp     eax,1
    je      L345
    jmp     L581
L347:
    jmp     L353
L348:
    test    bl,bl
    je      L352
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L350
L349:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L351
L350:
    cmp     eax,1
    je      L349
    jmp     L582
L351:
    jmp     L355
L352:
    cmp     rbp,0
    je      L584
    jmp     L356
L353:
    test    cl,cl
    jne     L348
    jmp     L584
L354:
    cmp     r12,0
    je      L584
    jmp     L360
L355:
    test    dl,dl
    jne     L360
    jmp     L584
L356:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L358
L357:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L359
L358:
    cmp     eax,1
    je      L357
    jmp     L583
L359:
    test    cl,cl
    jne     L354
    jmp     L584
L360:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L343
L361:
    lea     r11,[image.k2112]
    mov     [rsp+0E0h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L363
L362:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L364
L363:
    cmp     eax,1
    je      L362
    jmp     L586
L364:
    jmp     L373
L365:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L367
L366:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L368
L367:
    cmp     eax,1
    je      L366
    jmp     L587
L368:
    jmp     L375
L369:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L588
    cmp     r14,r13
    jae     L370
    mov     rsi,r13
    sub     rsi,r14
    jmp     L371
L370:
    mov     rsi,r14
    sub     rsi,r13
L371:
    cmp     rax,rsi
    setbe   al
    jmp     L376
L372:
    test    r12b,r12b
    jne     L365
    cmp     r14,0
    je      L589
    jmp     L365
L373:
    test    cl,cl
    jne     L372
    jmp     L589
L374:
    test    r12b,r12b
    jne     L369
    cmp     r13,0
    je      L589
    jmp     L369
L375:
    test    dl,dl
    jne     L374
    jmp     L589
L376:
    test    al,al
    je      L589
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+1Ch]
    mov     r13,[rsp+68h]
    lea     r13,[r13+20h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+1Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+1F0h],eax
    mov     ebx,0
    jmp     L378
L377:
    lea     r14,[rsp+1F0h]
    jmp     L395
L378:
    lea     r11,[image.k2088]
    mov     [rsp+0E8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L380
L379:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L381
L380:
    cmp     eax,1
    je      L379
    jmp     L591
L381:
    jmp     L387
L382:
    test    bl,bl
    je      L386
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L384
L383:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L385
L384:
    cmp     eax,1
    je      L383
    jmp     L592
L385:
    jmp     L389
L386:
    cmp     rbp,0
    je      L594
    jmp     L390
L387:
    test    cl,cl
    jne     L382
    jmp     L594
L388:
    cmp     r12,0
    je      L594
    jmp     L394
L389:
    test    dl,dl
    jne     L394
    jmp     L594
L390:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L392
L391:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L393
L392:
    cmp     eax,1
    je      L391
    jmp     L593
L393:
    test    cl,cl
    jne     L388
    jmp     L594
L394:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L377
L395:
    lea     r11,[image.k2112]
    mov     [rsp+0F0h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L397
L396:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L398
L397:
    cmp     eax,1
    je      L396
    jmp     L596
L398:
    jmp     L407
L399:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L401
L400:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L402
L401:
    cmp     eax,1
    je      L400
    jmp     L597
L402:
    jmp     L409
L403:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L598
    cmp     r14,r13
    jae     L404
    mov     rsi,r13
    sub     rsi,r14
    jmp     L405
L404:
    mov     rsi,r14
    sub     rsi,r13
L405:
    cmp     rax,rsi
    setbe   al
    jmp     L410
L406:
    test    r12b,r12b
    jne     L399
    cmp     r14,0
    je      L599
    jmp     L399
L407:
    test    cl,cl
    jne     L406
    jmp     L599
L408:
    test    r12b,r12b
    jne     L403
    cmp     r13,0
    je      L599
    jmp     L403
L409:
    test    dl,dl
    jne     L408
    jmp     L599
L410:
    test    al,al
    je      L599
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+4]
    mov     r13,[rsp+68h]
    lea     r13,[r13+10h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+10h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+200h],eax
    mov     ebx,0
    jmp     L412
L411:
    lea     r14,[rsp+200h]
    jmp     L429
L412:
    lea     r11,[image.k2088]
    mov     [rsp+0F8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L414
L413:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L415
L414:
    cmp     eax,1
    je      L413
    jmp     L601
L415:
    jmp     L421
L416:
    test    bl,bl
    je      L420
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L418
L417:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L419
L418:
    cmp     eax,1
    je      L417
    jmp     L602
L419:
    jmp     L423
L420:
    cmp     rbp,0
    je      L604
    jmp     L424
L421:
    test    cl,cl
    jne     L416
    jmp     L604
L422:
    cmp     r12,0
    je      L604
    jmp     L428
L423:
    test    dl,dl
    jne     L428
    jmp     L604
L424:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L426
L425:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L427
L426:
    cmp     eax,1
    je      L425
    jmp     L603
L427:
    test    cl,cl
    jne     L422
    jmp     L604
L428:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L411
L429:
    lea     r11,[image.k2112]
    mov     [rsp+100h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L431
L430:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L432
L431:
    cmp     eax,1
    je      L430
    jmp     L606
L432:
    jmp     L441
L433:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L435
L434:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L436
L435:
    cmp     eax,1
    je      L434
    jmp     L607
L436:
    jmp     L443
L437:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L608
    cmp     r14,r13
    jae     L438
    mov     rsi,r13
    sub     rsi,r14
    jmp     L439
L438:
    mov     rsi,r14
    sub     rsi,r13
L439:
    cmp     rax,rsi
    setbe   al
    jmp     L444
L440:
    test    r12b,r12b
    jne     L433
    cmp     r14,0
    je      L609
    jmp     L433
L441:
    test    cl,cl
    jne     L440
    jmp     L609
L442:
    test    r12b,r12b
    jne     L437
    cmp     r13,0
    je      L609
    jmp     L437
L443:
    test    dl,dl
    jne     L442
    jmp     L609
L444:
    test    al,al
    je      L609
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+68h]
    lea     r12,[r12+0Ch]
    mov     r13,[rsp+68h]
    lea     r13,[r13+18h]
    mov     r11,[rsp+68h]
    mov     eax,[r11+18h]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+210h],eax
    mov     ebx,0
    jmp     L446
L445:
    lea     r14,[rsp+210h]
    jmp     L463
L446:
    lea     r11,[image.k2088]
    mov     [rsp+108h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L448
L447:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L449
L448:
    cmp     eax,1
    je      L447
    jmp     L611
L449:
    jmp     L455
L450:
    test    bl,bl
    je      L454
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L452
L451:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L453
L452:
    cmp     eax,1
    je      L451
    jmp     L612
L453:
    jmp     L457
L454:
    cmp     rbp,0
    je      L614
    jmp     L458
L455:
    test    cl,cl
    jne     L450
    jmp     L614
L456:
    cmp     r12,0
    je      L614
    jmp     L462
L457:
    test    dl,dl
    jne     L462
    jmp     L614
L458:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L460
L459:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L461
L460:
    cmp     eax,1
    je      L459
    jmp     L613
L461:
    test    cl,cl
    jne     L456
    jmp     L614
L462:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L445
L463:
    lea     rbx,[image.k2112]
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L465
L464:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L466
L465:
    cmp     eax,1
    je      L464
    jmp     L616
L466:
    jmp     L475
L467:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L469
L468:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L470
L469:
    cmp     eax,1
    je      L468
    jmp     L617
L470:
    jmp     L477
L471:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L618
    cmp     r14,r13
    jae     L472
    mov     rsi,r13
    sub     rsi,r14
    jmp     L473
L472:
    mov     rsi,r14
    sub     rsi,r13
L473:
    cmp     rax,rsi
    setbe   al
    jmp     L478
L474:
    test    r12b,r12b
    jne     L467
    cmp     r14,0
    je      L619
    jmp     L467
L475:
    test    cl,cl
    jne     L474
    jmp     L619
L476:
    test    r12b,r12b
    jne     L471
    cmp     r13,0
    je      L619
    jmp     L471
L477:
    test    dl,dl
    jne     L476
    jmp     L619
L478:
    test    al,al
    je      L619
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rdi,[rsp+68h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,3
    mov     edx,5
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+68h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rbx,[rsp+270h]
    mov     r12,[rsp+260h]
    mov     r13,[rsp+250h]
    mov     r14,[rsp+240h]
    mov     r15,[rsp+230h]
    mov     rbp,[rsp+220h]
    add     rsp,288h
    ret
L479:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L480:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L481:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L483
L482:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L483
L483:
    call    qword ptr [image.sym10]
    ud2
L484:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L485:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L486:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L488
    jmp     L488
L487:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L488:
    call    qword ptr [image.sym10]
    ud2
L489:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L490:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L491:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L493
L492:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L493
L493:
    call    qword ptr [image.sym10]
    ud2
L494:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L495:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L496:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L498
    jmp     L498
L497:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L498:
    call    qword ptr [image.sym10]
    ud2
L499:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L500:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L501:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L503
L502:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L503
L503:
    call    qword ptr [image.sym10]
    ud2
L504:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L505:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L506:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L508
    jmp     L508
L507:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L508:
    call    qword ptr [image.sym10]
    ud2
    mov     r12,rax
    jmp     L510
L509:
    mov     [rsp+20h],r12
    lea     rdi,[rsp+280h]
    mov     esi,0FFFFFDA0h
    call    ryo_h_Resume
    ud2
L510:
    lea     rax,[rsp+160h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    jmp     L509
    call    qword ptr [image.sym11]
    ud2
L511:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L512:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L513:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L515
L514:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L515
L515:
    call    qword ptr [image.sym10]
    ud2
L516:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L517:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L518:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L520
    jmp     L520
L519:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L520:
    call    qword ptr [image.sym10]
    ud2
L521:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L522:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L523:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L525
L524:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L525
L525:
    call    qword ptr [image.sym10]
    ud2
L526:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L527:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L528:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L530
    jmp     L530
L529:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L530:
    call    qword ptr [image.sym10]
    ud2
L531:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L532:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L533:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L535
L534:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L535
L535:
    call    qword ptr [image.sym10]
    ud2
L536:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L537:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L538:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L540
    jmp     L540
L539:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L540:
    call    qword ptr [image.sym10]
    ud2
L541:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L542:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L543:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L545
L544:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L545
L545:
    call    qword ptr [image.sym10]
    ud2
L546:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L547:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L548:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L550
    jmp     L550
L549:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L550:
    call    qword ptr [image.sym10]
    ud2
L551:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L552:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L553:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L555
L554:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L555
L555:
    call    qword ptr [image.sym10]
    ud2
L556:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L557:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L558:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L560
    jmp     L560
L559:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L560:
    call    qword ptr [image.sym10]
    ud2
L561:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L562:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L563:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L565
L564:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L565
L565:
    call    qword ptr [image.sym10]
    ud2
L566:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L567:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L568:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L570
    jmp     L570
L569:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L570:
    call    qword ptr [image.sym10]
    ud2
L571:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L572:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L573:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L575
L574:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L575
L575:
    call    qword ptr [image.sym10]
    ud2
L576:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L577:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L578:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L580
    jmp     L580
L579:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L580:
    call    qword ptr [image.sym10]
    ud2
L581:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L582:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L583:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L585
L584:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L585
L585:
    call    qword ptr [image.sym10]
    ud2
L586:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L587:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L588:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L590
    jmp     L590
L589:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L590:
    call    qword ptr [image.sym10]
    ud2
L591:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L592:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L593:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L595
L594:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L595
L595:
    call    qword ptr [image.sym10]
    ud2
L596:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L597:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L598:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L600
    jmp     L600
L599:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L600:
    call    qword ptr [image.sym10]
    ud2
L601:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L602:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L603:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L605
L604:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L605
L605:
    call    qword ptr [image.sym10]
    ud2
L606:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L607:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L608:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L610
    jmp     L610
L609:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L610:
    call    qword ptr [image.sym10]
    ud2
L611:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L612:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L613:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L615
L614:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+108h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L615
L615:
    call    qword ptr [image.sym10]
    ud2
L616:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L617:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L618:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L620
    jmp     L620
L619:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L620:
    call    qword ptr [image.sym10]
    ud2
L621:
    lea     rdi,[rsp+280h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,138h
    mov     [rsp+120h],rbx
    mov     [rsp+110h],r12
    mov     [rsp+100h],r13
    mov     [rsp+0F0h],r14
    mov     [rsp+0E0h],r15
    mov     [rsp+0D0h],rbp
    lea     rbx,[rdi+rsi*4]
    lea     r12,[rdi+rdx*4]
    mov     eax,[r12]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     [rsp+60h],r12
    mov     [rsp+58h],r12
    mov     [rsp+60h],rbx
    lea     r14,[rsp+58h]
    lea     r15,[rsp+60h]
    mov     [rsp+68h],r15
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],r15
    mov     [rsp+10h],r14
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+68h]
    mov     [rsp+30h],r11
    mov     rax,[rsp+48h]
    mov     [rsp+78h],rax
    mov     rdi,rax
    call    qword ptr [image.sym13]
    jmp     L1
L0:
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym14]
    jmp     L2
L1:
    mov     r10,[rsp+30h]
    mov     [rsp+78h],r10
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym15]
    jmp     L0
L2:
    mov     rax,[rsp+78h]
    mov     r15,rax
    mov     [rsp+0A0h],rbx
    mov     [rsp+98h],rbx
    mov     [rsp+0A0h],r12
    lea     rbp,[rsp+98h]
    lea     r14,[rsp+0A0h]
    mov     [rsp+0A8h],r14
    mov     [rsp+8],r13b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     r14,[rsp+0A8h]
    mov     rax,[rsp+88h]
    mov     [rsp+0B8h],rax
    mov     rdi,rax
    call    qword ptr [image.sym13]
    jmp     L4
L3:
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym14]
    jmp     L5
L4:
    mov     [rsp+0B8h],r14
    mov     rax,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+130h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym15]
    jmp     L3
L5:
    mov     rax,[rsp+0B8h]
    mov     eax,[rax]
    mov     [rsp+0C0h],eax
    mov     ebp,0
    jmp     L7
L6:
    lea     r13,[rsp+0C0h]
    jmp     L24
L7:
    lea     r11,[k3]
    mov     [rsp+38h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L9
L8:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L10
L9:
    cmp     eax,1
    je      L8
    jmp     L44
L10:
    jmp     L16
L11:
    test    bpl,bpl
    je      L15
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L13
L12:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L14
L13:
    cmp     eax,1
    je      L12
    jmp     L45
L14:
    jmp     L18
L15:
    cmp     r15,0
    je      L47
    jmp     L19
L16:
    test    cl,cl
    jne     L11
    jmp     L47
L17:
    cmp     rbx,0
    je      L47
    jmp     L23
L18:
    test    dl,dl
    jne     L23
    jmp     L47
L19:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L21
L20:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L22
L21:
    cmp     eax,1
    je      L20
    jmp     L46
L22:
    test    cl,cl
    jne     L17
    jmp     L47
L23:
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L6
L24:
    lea     rbx,[k5]
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L26
L25:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L27
L26:
    cmp     eax,1
    je      L25
    jmp     L49
L27:
    jmp     L36
L28:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L30
L29:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L31
L30:
    cmp     eax,1
    je      L29
    jmp     L50
L31:
    jmp     L38
L32:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L51
    cmp     r13,r12
    jae     L33
    mov     rsi,r12
    sub     rsi,r13
    jmp     L34
L33:
    mov     rsi,r13
    sub     rsi,r12
L34:
    cmp     rax,rsi
    setbe   al
    jmp     L39
L35:
    test    r15b,r15b
    jne     L28
    cmp     r13,0
    je      L52
    jmp     L28
L36:
    test    cl,cl
    jne     L35
    jmp     L52
L37:
    test    r15b,r15b
    jne     L32
    cmp     r12,0
    je      L52
    jmp     L32
L38:
    test    dl,dl
    jne     L37
    jmp     L52
L39:
    test    al,al
    je      L52
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+120h]
    mov     r12,[rsp+110h]
    mov     r13,[rsp+100h]
    mov     r14,[rsp+0F0h]
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+0D0h]
    add     rsp,138h
    ret
    mov     r12,rax
    jmp     L41
L40:
    mov     [rsp+20h],r12
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
L41:
    mov     rdi,[rsp+30h]
    call    qword ptr [image.sym13]
    jmp     L40
    call    qword ptr [image.sym11]
    ud2
    mov     r12,rax
    jmp     L43
L42:
    mov     [rsp+20h],r12
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF0h
    call    ryo_h_Resume
    ud2
L43:
    mov     rdi,r14
    call    qword ptr [image.sym13]
    jmp     L42
    call    qword ptr [image.sym11]
    ud2
L44:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L45:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L46:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L48
L47:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L48
L48:
    call    qword ptr [image.sym10]
    ud2
L49:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L51:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L53
    jmp     L53
L52:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L53:
    call    qword ptr [image.sym10]
    ud2
  ; OSR entries
    lea     r11,[L54]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L54:
    .long   L55
L55:
    ret

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx+18h]
    jmp     L4
L0:
    mov     rcx,[rbx]
    jmp     L2
L1:
    mov     rcx,[rbx+18h]
L2:
    mov     rdx,[rbx+10h]
    lea     r13,[rcx+rdx*8]
    mov     r14,[rbx+8]
    jmp     L5
L3:
    mov     [rbx+18h],rcx
    test    r12b,r12b
    jne     L0
    jmp     L1
L4:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L3
L5:
    lea     r15,[k0]
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L21
L8:
    jmp     L17
L9:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L11
L10:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L12
L11:
    cmp     eax,1
    je      L10
    jmp     L22
L12:
    jmp     L19
L13:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L23
    cmp     r14,r13
    jae     L14
    mov     rsi,r13
    sub     rsi,r14
    jmp     L15
L14:
    mov     rsi,r14
    sub     rsi,r13
L15:
    cmp     rax,rsi
    setbe   al
    jmp     L20
L16:
    test    bpl,bpl
    jne     L9
    cmp     r14,0
    je      L24
    jmp     L9
L17:
    test    cl,cl
    jne     L16
    jmp     L24
L18:
    test    bpl,bpl
    jne     L13
    cmp     r13,0
    je      L24
    jmp     L13
L19:
    test    dl,dl
    jne     L18
    jmp     L24
L20:
    test    al,al
    je      L24
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   r12d,r12b
    mov     rax,[rbx+10h]
    add     rax,r12
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    lea     rax,[rax+8]
    mov     [rbx+8],rax
    mov     rax,r13
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L21:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L22:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L23:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L25
    jmp     L25
L24:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L25:
    call    qword ptr [image.sym10]
    ud2
  ; OSR entries
    lea     r11,[L26]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L26:
    .long   L27
    .long   L28
    .long   L29
L27:
    ret
L28:
    ret
L29:
    ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,638h
    mov     [rsp+530h],rbx
    mov     [rsp+520h],r12
    mov     [rsp+510h],r13
    mov     [rsp+500h],r14
    mov     [rsp+4F0h],r15
    mov     [rsp+4E0h],rbp
    mov     rax,[rsp+640h]
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rax
    mov     [rsp+188h],r8
    mov     [rsp+30h],r9
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
L0:
    mov     r10,[rsp+28h]
    mov     [rsp+570h],r10
    mov     eax,20h
    cmp     rax,[rsp+20h]
    jb      L1
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+50h]
    mov     r8,[rsp+48h]
    call    qword ptr [image.fn81.slot]
    jmp     L43
L1:
    mov     r11,[rsp+188h]
    cmp     r11d,0
    jne     L22
    mov     r11,[rsp+20h]
    cmp     r11,2
    jb      L43
    mov     r11,[rsp+20h]
    cmp     r11,0
    sete    al
    mov     [rsp+497h],al
    test    al,al
    jne     L54
    jmp     L16
L2:
    mov     r11,[rsp+20h]
    mov     [rsp+10h],r11
    mov     qword ptr [rsp+18h],2
    lea     rdi,[rsp+630h]
    mov     esi,0FFFFFE58h
    mov     edx,0FFFFF9E0h
    mov     ecx,0FFFFF9E8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+488h]
    mov     r11,[rsp+20h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+490h],rax
    cmp     rax,40h
    seta    cl
    test    cl,cl
    je      L3
    mov     r15d,40h
    jmp     L5
L3:
    mov     r15,rax
    jmp     L5
L4:
    mov     rdi,[rsp+20h]
    call    qword ptr [image.sym32]
    mov     r15,rax
L5:
    lea     rdi,[rsp+630h]
    mov     esi,0FFFFFC58h
    lea     rdx,[image.k2976]
    mov     ecx,210h
    call    ryo_h_Const
    lea     r14,[rsp+288h]
    mov     [rsp+4D8h],r14
    lea     rdi,[rsp+630h]
    mov     esi,0FFFFFE6Eh
    lea     rdx,[image.k3504]
    mov     ecx,42h
    call    ryo_h_Const
    lea     rax,[rsp+49Eh]
    mov     qword ptr [rsp+40h],0
    mov     r11,[rsp+20h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+1D0h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+1C8h],r11
    mov     [rsp+1C0h],r15
    mov     r11,[rsp+48h]
    mov     [rsp+1B8h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+1B0h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+60h],r11
    mov     qword ptr [rsp+68h],1
    mov     qword ptr [rsp+70h],1
    mov     r11,[rsp+1D8h]
    mov     [rsp+78h],r11
    mov     qword ptr [rsp+80h],0
    mov     [rsp+88h],rax
    mov     [rsp+90h],r14
L6:
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+38h]
    jae     L8
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+40h]
    jb      L56
    jmp     L19
L7:
    mov     rax,[rsp+0A0h]
    shr     rax,1
    mov     r11,[rsp+98h]
    sub     r11,rax
    mov     rax,r11
    mov     rcx,[rsp+0A8h]
    shr     rcx,1
    add     rcx,[rsp+98h]
    add     rax,[rsp+98h]
    add     rcx,[rsp+98h]
    imul    rax,[rsp+0B0h]
    imul    rcx,[rsp+0B0h]
    xor     rax,rcx
    mov     rdi,rax
    call    ryo_hr_CtlzW64
    mov     [rsp+1A8h],rax
    jmp     L20
L8:
    mov     r11,[rsp+80h]
    mov     [rsp+110h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+118h],r11
    mov     qword ptr [rsp+120h],0
    mov     r11,[rsp+90h]
    mov     [rsp+128h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+198h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+130h],r11
    mov     r11,[rsp+1D0h]
    mov     [rsp+138h],r11
    mov     r11,[rsp+1C8h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+148h],r11
    mov     qword ptr [rsp+150h],1
    mov     r11,[rsp+1B0h]
    mov     [rsp+158h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+160h],r11
    mov     r11,[rsp+1B8h]
    mov     [rsp+168h],r11
    mov     r11,[rsp+1C0h]
    mov     [rsp+170h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+178h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+180h],r11
L9:
    mov     r11,[rsp+110h]
    cmp     r11,1
    jbe     L11
    mov     rdx,[rsp+110h]
    sub     rdx,1
    mov     r11,[rsp+118h]
    lea     rdx,[r11+rdx]
    movzx   edx,byte ptr [rdx]
    cmp     dl,[rsp+120h]
    jb      L11
    mov     rdx,[rsp+110h]
    sub     rdx,1
    mov     r11,[rsp+128h]
    lea     rdx,[r11+rdx*8]
    mov     r11,[rdx]
    mov     [rsp+190h],r11
    mov     rsi,[rsp+190h]
    shr     rsi,1
    mov     rdi,[rsp+198h]
    shr     rdi,1
    add     rsi,rdi
    mov     r11,[rsp+130h]
    sub     r11,rsi
    mov     [rsp+1A0h],r11
    jmp     L21
L10:
    sub     rdi,1
    mov     [rsp+110h],rdi
    mov     [rsp+118h],r9
    mov     [rsp+120h],r8
    mov     [rsp+128h],rdx
    mov     [rsp+198h],rcx
    mov     [rsp+130h],rsi
    mov     [rsp+138h],rax
    mov     [rsp+140h],rbx
    mov     [rsp+148h],r12
    mov     [rsp+150h],r13
    mov     [rsp+158h],r14
    mov     [rsp+160h],r15
    mov     [rsp+168h],rbp
    mov     r11,[rsp+1E0h]
    mov     [rsp+170h],r11
    mov     r11,[rsp+1E8h]
    mov     [rsp+178h],r11
    mov     r11,[rsp+1F0h]
    mov     [rsp+180h],r11
    jmp     L9
L11:
    mov     r11,[rsp+128h]
    mov     r10,[rsp+110h]
    lea     rax,[r11+r10*8]
    mov     r10,[rsp+198h]
    mov     [rax],r10
    mov     r11,[rsp+118h]
    mov     r10,[rsp+110h]
    lea     rax,[r11+r10]
    mov     r10,[rsp+120h]
    mov     [rax],r10b
    mov     rax,[rsp+110h]
    add     rax,1
    mov     r11,[rsp+130h]
    cmp     r11,[rsp+148h]
    jb      L12
    mov     rcx,[rsp+198h]
    and     rcx,1
    cmp     rcx,1
    je      L43
    jmp     L13
L12:
    mov     rcx,[rsp+150h]
    shr     rcx,1
    add     rcx,[rsp+130h]
    mov     [rsp+40h],rcx
    mov     r11,[rsp+148h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+138h]
    mov     [rsp+1D0h],r11
    mov     r11,[rsp+140h]
    mov     [rsp+1C8h],r11
    mov     r11,[rsp+170h]
    mov     [rsp+1C0h],r11
    mov     r11,[rsp+168h]
    mov     [rsp+1B8h],r11
    mov     r11,[rsp+158h]
    mov     [rsp+1B0h],r11
    mov     r11,[rsp+160h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+178h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+150h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+180h]
    mov     [rsp+78h],r11
    mov     [rsp+80h],rax
    mov     r11,[rsp+118h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+128h]
    mov     [rsp+90h],r11
    jmp     L6
L13:
    mov     rbx,[rsp+140h]
    or      rbx,1
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
    lea     r11,[L14]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L14:
    .long   L52
    .long   L15
    .long   L51
L15:
    mov     rdi,rbx
    call    ryo_hr_CtlzW64
    mov     r11d,3Fh
    sub     r11d,eax
    mov     rax,r11
    imul    eax,2
    mov     r10,[rsp+168h]
    mov     [rsp],r10
    mov     rdi,[rsp+138h]
    mov     rsi,[rsp+140h]
    mov     rdx,[rsp+158h]
    mov     rcx,[rsp+160h]
    mov     r8,rax
    mov     r9d,0
    mov     r8d,r8d
    call    fn14
    jmp     L43
L16:
    mov     rdi,4000000000000000h
    mov     rsi,[rsp+20h]
    call    ryo_hr_DivUW64
    mov     rbx,rax
    movzx   eax,byte ptr [rsp+497h]
    test    al,al
    jne     L55
    mov     r11,4000000000000000h
    mov     [rsp+10h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+18h],r11
    lea     rdi,[rsp+630h]
    mov     esi,0FFFFFE58h
    mov     edx,0FFFFF9E0h
    mov     ecx,0FFFFF9E8h
    call    ryo_h_RemUW64
    mov     rax,[rsp+488h]
    cmp     rax,0
    jbe     L17
    mov     rax,rbx
    add     rax,1
    mov     [rsp+1D8h],rax
    jmp     L18
L17:
    mov     [rsp+1D8h],rbx
L18:
    mov     r11,[rsp+20h]
    cmp     r11,1000h
    ja      L4
    jmp     L2
L19:
    mov     rax,[rsp+38h]
    sub     rax,[rsp+40h]
    mov     r11,[rsp+1D0h]
    mov     r10,[rsp+40h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+1B8h]
    mov     [rsp],r10
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,[rsp+1B0h]
    mov     rcx,[rsp+60h]
    mov     r8,[rsp+1C0h]
    mov     r9,[rsp+68h]
    movzx   r9d,r9b
    call    qword ptr [image.fn85.slot]
    mov     r11,[rsp+40h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+0A0h],r11
    mov     [rsp+0A8h],rax
    mov     r11,[rsp+78h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+90h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+1D0h]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+1C8h]
    mov     [rsp+0D8h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+0E0h],r11
    mov     r11,[rsp+1B0h]
    mov     [rsp+0E8h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0F0h],r11
    mov     r11,[rsp+1B8h]
    mov     [rsp+0F8h],r11
    mov     r11,[rsp+1C0h]
    mov     [rsp+100h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+108h],r11
    jmp     L7
L20:
    mov     rax,[rsp+1A8h]
    mov     r11,[rsp+0B8h]
    mov     [rsp+110h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+118h],r11
    mov     [rsp+120h],rax
    mov     r11,[rsp+0C8h]
    mov     [rsp+128h],r11
    mov     r11,[rsp+0A0h]
    mov     [rsp+198h],r11
    mov     r11,[rsp+98h]
    mov     [rsp+130h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+138h],r11
    mov     r11,[rsp+0D8h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+0E0h]
    mov     [rsp+148h],r11
    mov     r11,[rsp+0A8h]
    mov     [rsp+150h],r11
    mov     r11,[rsp+0E8h]
    mov     [rsp+158h],r11
    mov     r11,[rsp+0F0h]
    mov     [rsp+160h],r11
    mov     r11,[rsp+0F8h]
    mov     [rsp+168h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+170h],r11
    mov     r11,[rsp+108h]
    mov     [rsp+178h],r11
    mov     r11,[rsp+0B0h]
    mov     [rsp+180h],r11
    jmp     L9
L21:
    lea     rax,[image.k3624]
    mov     r11,[rsp+130h]
    cmp     r11,[rsp+1A0h]
    jb      L53
    mov     r11,[rsp+148h]
    cmp     r11,[rsp+130h]
    jb      L53
    mov     rcx,[rsp+130h]
    sub     rcx,[rsp+1A0h]
    mov     r11,[rsp+138h]
    mov     r10,[rsp+1A0h]
    lea     rdx,[r11+r10*8]
    mov     r10,[rsp+168h]
    mov     [rsp],r10
    mov     rdi,rdx
    mov     rsi,rcx
    mov     rdx,[rsp+158h]
    mov     rcx,[rsp+160h]
    mov     r8,[rsp+190h]
    mov     r9,[rsp+198h]
    call    qword ptr [image.fn86.slot]
    mov     rcx,rax
    mov     rdi,[rsp+110h]
    mov     r9,[rsp+118h]
    mov     r8,[rsp+120h]
    mov     rdx,[rsp+128h]
    mov     rsi,[rsp+130h]
    mov     rax,[rsp+138h]
    mov     rbx,[rsp+140h]
    mov     r12,[rsp+148h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+158h]
    mov     r15,[rsp+160h]
    mov     rbp,[rsp+168h]
    mov     r11,[rsp+170h]
    mov     [rsp+1E0h],r11
    mov     r11,[rsp+178h]
    mov     [rsp+1E8h],r11
    mov     r11,[rsp+180h]
    mov     [rsp+1F0h],r11
    jmp     L10
L22:
    mov     r11,[rsp+188h]
    sub     r11d,1
    mov     [rsp+1F8h],r11
    mov     r10,[rsp+28h]
    mov     [rsp+568h],r10
    mov     r10,[rsp+20h]
    mov     [rsp+570h],r10
    mov     r11,[rsp+20h]
    cmp     r11,8
    jb      L60
    mov     rdi,[rsp+20h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rdx,rcx
    imul    rdx,4
    mov     r11,[rsp+28h]
    lea     r12,[r11+rdx*8]
    mov     rdx,rcx
    imul    rdx,7
    mov     r11,[rsp+28h]
    lea     r13,[r11+rdx*8]
    mov     r11,[rsp+20h]
    cmp     r11,40h
    jae     L26
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     r11,[rsp+28h]
    mov     edx,[r11]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     esi,[r12]
    cmp     edx,esi
    setb    dl
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     r11,[rsp+28h]
    mov     esi,[r11]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    cmp     dl,sil
    jne     L24
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     esi,[r12]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    xor     esi,edx
    test    sil,sil
    je      L23
    mov     rdx,r13
    jmp     L25
L23:
    mov     rdx,r12
    jmp     L25
L24:
    mov     rdx,[rsp+28h]
L25:
    jmp     L34
L26:
    mov     rsi,rcx
    imul    rsi,8
    cmp     rsi,40h
    jb      L27
    jmp     L28
L27:
    mov     rbx,[rsp+28h]
    jmp     L29
L28:
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r14,rax
    mov     r15,r14
    imul    r15,4
    mov     r11,[rsp+28h]
    lea     rcx,[r11+r15*8]
    mov     rbp,r14
    imul    rbp,7
    mov     r11,[rsp+28h]
    lea     rsi,[r11+rbp*8]
    mov     rdi,[rsp+28h]
    mov     rdx,rsi
    mov     rsi,rcx
    mov     rcx,r14
    mov     r8,[rsp+48h]
    call    image.fn58
    mov     rbx,rax
    lea     rcx,[r12+r15*8]
    lea     rsi,[r12+rbp*8]
    mov     rdi,r12
    mov     rdx,rsi
    mov     rsi,rcx
    mov     rcx,r14
    mov     r8,[rsp+48h]
    call    image.fn58
    mov     r12,rax
    lea     rcx,[r13+r15*8]
    lea     rsi,[r13+rbp*8]
    mov     rdi,r13
    mov     rdx,rsi
    mov     rsi,rcx
    mov     rcx,r14
    mov     r8,[rsp+48h]
    call    image.fn58
    mov     rcx,rax
    mov     r13,rcx
L29:
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     ecx,[rbx]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     esi,[r12]
    cmp     ecx,esi
    setb    cl
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     esi,[rbx]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    cmp     cl,sil
    jne     L31
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     esi,[r12]
    mov     r11,[rsp+48h]
    mov     r11,[r11]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    xor     esi,ecx
    test    sil,sil
    je      L30
    jmp     L32
L30:
    mov     r13,r12
    jmp     L32
L31:
    mov     r13,rbx
L32:
    jmp     L35
L33:
    cmp     rcx,[rsp+20h]
    setb    sil
    jmp     L36
L34:
    lea     rdi,[image.k1336]
    cmp     rdx,[rsp+28h]
    jb      L57
    sub     rdx,[rsp+28h]
    mov     rdi,rdx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rdx,rax
    mov     rcx,rdx
    jmp     L33
L35:
    lea     rdx,[image.k1464]
    cmp     r13,[rsp+28h]
    jb      L58
    sub     r13,[rsp+28h]
    mov     rdi,r13
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r8,rax
    mov     rcx,r8
    jmp     L33
L36:
    lea     r8,[image.k1512]
    test    sil,sil
    je      L59
    mov     [rsp+218h],rcx
    mov     r11,[rsp+218h]
    cmp     r11,[rsp+20h]
    jae     L61
    mov     r11,[rsp+28h]
    mov     r10,[rsp+218h]
    lea     rsi,[r11+r10*8]
    mov     [rsp+560h],rsi
    mov     [rsp+568h],rsi
    mov     rsi,[rsi]
    mov     [rsp+570h],rsi
    mov     esi,1
    jmp     L44
L37:
    mov     r10,[rsp+248h]
    mov     [rsp+568h],r10
    mov     r11,[rsp+200h]
    cmp     r11,[rsp+210h]
    jae     L62
    mov     r11,[rsp+208h]
    mov     r10,[rsp+200h]
    lea     r9,[r11+r10*8]
    mov     [rsp+550h],r9
    mov     rcx,[rsp+568h]
    mov     [rsp+558h],rcx
    mov     [rsp+560h],r9
    mov     r11,[rsp+240h]
    mov     r11,[r11]
    mov     ecx,[rcx]
    mov     r11,[rsp+240h]
    mov     r11,[r11]
    mov     r9d,[r9]
    cmp     ecx,r9d
    setb    cl
    mov     r9,rcx
    xor     r9d,1
    cmp     cl,1
    jne     L38
    jmp     L39
L38:
    mov     r11,[rsp+240h]
    mov     [rsp+280h],r11
    mov     r11,[rsp+238h]
    mov     [rsp+278h],r11
    mov     r11,[rsp+230h]
    mov     [rsp+270h],r11
    mov     r14,[rsp+200h]
    mov     ecx,0
    mov     r11,[rsp+228h]
    mov     [rsp+268h],r11
    mov     rbx,[rsp+220h]
    mov     r13,[rsp+248h]
    mov     r15,[rsp+208h]
    mov     rbp,[rsp+210h]
    jmp     L41
L39:
    mov     r12,[rsp+240h]
    mov     rbp,[rsp+238h]
    mov     r15,[rsp+230h]
    mov     r14,[rsp+200h]
    mov     r13,[rsp+228h]
    mov     rbx,[rsp+220h]
    mov     r11,[rsp+248h]
    mov     [rsp+250h],r11
    mov     r11,[rsp+208h]
    mov     [rsp+258h],r11
    mov     r11,[rsp+210h]
    mov     [rsp+260h],r11
    jmp     L40
L40:
    mov     r10,[rsp+258h]
    mov     [rsp+560h],r10
    mov     r10,[rsp+260h]
    mov     [rsp+568h],r10
    mov     [rsp],r12
    mov     rdi,[rsp+258h]
    mov     rsi,[rsp+260h]
    mov     rdx,rbp
    mov     rcx,r15
    mov     r8,r14
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    mov     rcx,rax
    mov     [rsp+568h],rcx
    cmp     rcx,0
    sete    r9b
    mov     [rsp+280h],r12
    mov     [rsp+278h],rbp
    mov     [rsp+270h],r15
    mov     [rsp+268h],r13
    mov     r13,[rsp+250h]
    mov     r15,[rsp+258h]
    mov     rbp,[rsp+260h]
L41:
    test    r9b,r9b
    je      L42
    mov     [rsp+558h],r15
    mov     [rsp+560h],rbp
    mov     r10,[rsp+280h]
    mov     [rsp+548h],r10
    lea     r9,[rsp+548h]
    mov     [rsp+550h],r9
    mov     [rsp],r9
    mov     rdi,r15
    mov     rsi,rbp
    mov     rdx,[rsp+278h]
    mov     rcx,[rsp+270h]
    mov     r8,r14
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     r9,rax
    mov     [rsp+568h],r9
    mov     [rsp+560h],rbp
    cmp     rbp,r9
    jb      L63
    jmp     L49
L42:
    lea     r9,[k12]
    lea     r14,[rsp+540h]
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    mov     r8,r9
    call    qword ptr [fn13.slot]
    mov     r14,[rsp+540h]
    mov     r12,[rsp+548h]
    mov     rcx,[rsp+550h]
    mov     [rsp+560h],rcx
    mov     r9,[rsp+558h]
    mov     [rsp+568h],r9
    mov     r10,[rsp+280h]
    mov     [rsp],r10
    mov     rdi,rcx
    mov     rsi,r9
    mov     rdx,[rsp+278h]
    mov     rcx,[rsp+270h]
    mov     r8,[rsp+268h]
    mov     r9,rbx
    mov     r8d,r8d
    call    fn14
    mov     r11,[rsp+278h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+270h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+280h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+268h]
    mov     [rsp+188h],r11
    mov     [rsp+30h],r13
    mov     [rsp+28h],r14
    mov     [rsp+20h],r12
    jmp     L0
L43:
    mov     rbx,[rsp+530h]
    mov     r12,[rsp+520h]
    mov     r13,[rsp+510h]
    mov     r14,[rsp+500h]
    mov     r15,[rsp+4F0h]
    mov     rbp,[rsp+4E0h]
    add     rsp,638h
    ret
L44:
    lea     rcx,[rsp+570h]
    mov     [rsp+558h],rcx
    mov     [rsp+560h],rcx
    mov     [rsp+568h],rcx
    test    sil,sil
    jne     L47
    jmp     L48
L45:
    mov     rdi,[rsp+248h]
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rcx,rax
    mov     ecx,ecx
    mov     rdi,rcx
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     rcx,rax
    mov     r10,rcx
    lea     r11,[L46]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L46:
    .long   L50
    .long   L37
    .long   L64
L47:
    mov     rcx,[rsp+568h]
    mov     r11,[rsp+30h]
    mov     [rsp+248h],r11
    mov     r11,[rsp+218h]
    mov     [rsp+200h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+240h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+238h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+230h],r11
    mov     r11,[rsp+1F8h]
    mov     [rsp+228h],r11
    mov     [rsp+220h],rcx
    mov     r11,[rsp+28h]
    mov     [rsp+208h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+210h],r11
    jmp     L45
L48:
    mov     r11,[rsp+30h]
    mov     [rsp+248h],r11
    mov     r11,[rsp+218h]
    mov     [rsp+200h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+240h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+238h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+230h],r11
    mov     r11,[rsp+1F8h]
    mov     [rsp+228h],r11
    mov     qword ptr [rsp+220h],0
    mov     r11,[rsp+28h]
    mov     [rsp+208h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+210h],r11
    jmp     L45
L49:
    mov     rcx,[rsp+560h]
    mov     rsi,[rsp+568h]
    sub     rcx,rsi
    mov     [rsp+558h],rcx
    mov     [rsp+540h],rbp
    lea     r15,[r15+rsi*8]
    mov     [rsp+548h],r15
    mov     [rsp+550h],rcx
    mov     r11,[rsp+278h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+270h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+280h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+268h]
    mov     [rsp+188h],r11
    mov     qword ptr [rsp+30h],0
    mov     [rsp+28h],r15
    mov     [rsp+20h],rcx
    jmp     L0
L50:
    mov     r12,[rsp+240h]
    mov     rbp,[rsp+238h]
    mov     r15,[rsp+230h]
    mov     r14,[rsp+200h]
    mov     r13,[rsp+228h]
    mov     rbx,[rsp+220h]
    mov     r11,[rsp+248h]
    mov     [rsp+250h],r11
    mov     r11,[rsp+208h]
    mov     [rsp+258h],r11
    mov     r11,[rsp+210h]
    mov     [rsp+260h],r11
    jmp     L40
L51:
    ud2
L52:
    lea     rcx,[image.k2928]
    mov     rdi,rcx
    call    qword ptr [image.sym28]
    ud2
L53:
    lea     rcx,[image.k10183]
    mov     rdi,rcx
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L54:
    lea     rax,[image.k2952]
    mov     rdi,rax
    call    qword ptr [image.sym27]
    ud2
L55:
    lea     rax,[image.k3576]
    mov     rdi,rax
    call    qword ptr [image.sym33]
    ud2
L56:
    lea     rax,[image.k3600]
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+38h]
    mov     rcx,rax
    call    qword ptr [sym16]
    ud2
L57:
    lea     rax,[image.k7567]
    mov     esi,193h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L58:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L59:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L60:
    lea     rdi,[rsp+630h]
    call    ryo_h_Abort
    ud2
L61:
    lea     rax,[k4]
    mov     rdi,[rsp+218h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L62:
    lea     rax,[k7]
    mov     rdi,[rsp+200h]
    mov     rsi,[rsp+210h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L63:
    lea     rax,[k15]
    mov     rcx,[rsp+568h]
    mov     rdx,[rsp+560h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rcx,rax
    call    qword ptr [sym16]
    ud2
L64:
    ud2
  ; OSR entries
    lea     r11,[L65]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L65:
    .long   L66
    .long   L67
    .long   L68
L66:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-670h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-8]
    mov     [rsp+30h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+38h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-630h],r11
    mov     r11,[rsp]
    mov     [rdx-5D8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-5E0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-5E8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-4A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-600h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-608h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-610h],r11
    lea     rsp,[rsp+40h]
    jmp     L0
L67:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-680h]
    mov     r11,[rdx-38h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-18h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+18h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-8]
    mov     [rsp+40h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+48h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-630h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-3D8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-3D0h],r11
    mov     r12,[rsp]
    mov     rbp,[rsp+8]
    mov     r15,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     rbx,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L40
L68:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-680h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-8]
    mov     [rsp+40h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+48h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-630h],r11
    mov     r11,[rsp]
    mov     [rdx-3E8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-430h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-3F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-3F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-400h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-408h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-410h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-428h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-420h],r11
    lea     rsp,[rsp+50h]
    jmp     L45

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     r11,[rax]
    mov     ecx,[rdx]
    mov     r11,[rax]
    mov     eax,[rsi]
    cmp     ecx,eax
    setb    al
    xor     eax,1
    movzx   eax,al
    add     rsp,18h
    ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    sub     rsp,2F8h
    mov     [rsp+1E0h],rbx
    mov     [rsp+1D0h],r12
    mov     [rsp+1C0h],r13
    mov     [rsp+1B0h],r14
    mov     [rsp+1A0h],r15
    mov     [rsp+190h],rbp
    mov     [rsp+0F0h],rdx
    mov     [rsp+0D0h],r8
    mov     [rsp+0A0h],r9
    mov     r11,[rsp+300h]
    mov     [rsp+98h],r11
    cmp     rcx,rsi
    jb      L237
    cmp     rsi,[rsp+0D0h]
    jbe     L237
    jmp     L137
L0:
    mov     r10,[rsp+68h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+2F0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L138
L1:
    mov     rcx,[rsp+1F8h]
    cmp     rcx,rbp
    jb      L3
    jmp     L2
L2:
    mov     rax,[rsp+0B8h]
    mov     rcx,[rsp+0B0h]
    mov     r8,[rsp+0C8h]
    mov     r9,[rsp+0A8h]
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+78h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+88h]
    mov     rbp,[rsp+90h]
    jmp     L88
L3:
    mov     rcx,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     rax,[r11]
    mov     r11,[rax]
    mov     r9d,[r15]
    mov     r11,[rax]
    mov     eax,[rcx]
    cmp     r9d,eax
    setb    al
    xor     eax,1
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L8
L4:
    mov     rcx,[rsp+1F0h]
    jmp     L6
L5:
    mov     rcx,[rsp+208h]
L6:
    mov     r9,[rsp+200h]
    lea     r12,[rcx+r9*8]
    mov     r13,[rsp+1F8h]
    jmp     L9
L7:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L4
    jmp     L5
L8:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L7
L9:
    lea     r11,[image.k6632]
    mov     [rsp+0C0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L11
L10:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L12
L11:
    cmp     eax,1
    je      L10
    jmp     L191
L12:
    jmp     L21
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L15
L14:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L16
L15:
    cmp     eax,1
    je      L14
    jmp     L192
L16:
    jmp     L23
L17:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L193
    cmp     r13,r12
    jae     L18
    mov     r8,r12
    sub     r8,r13
    jmp     L19
L18:
    mov     r8,r13
    sub     r8,r12
L19:
    cmp     rax,r8
    setbe   al
    jmp     L24
L20:
    test    r14b,r14b
    jne     L13
    cmp     r13,0
    je      L194
    jmp     L13
L21:
    test    cl,cl
    jne     L20
    jmp     L194
L22:
    test    r14b,r14b
    jne     L17
    cmp     r12,0
    je      L194
    jmp     L17
L23:
    test    r9b,r9b
    jne     L22
    jmp     L194
L24:
    test    al,al
    je      L194
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     r8d,[r15]
    mov     r11,[rcx]
    mov     eax,[rax]
    cmp     r8d,eax
    setb    al
    xor     eax,1
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L29
L25:
    mov     rcx,[rsp+1F0h]
    jmp     L27
L26:
    mov     rcx,[rsp+208h]
L27:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L30
L28:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L25
    jmp     L26
L29:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L28
L30:
    lea     r11,[image.k6632]
    mov     [rsp+0D8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L196
L33:
    jmp     L42
L34:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L36
L35:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L37
L36:
    cmp     eax,1
    je      L35
    jmp     L197
L37:
    jmp     L44
L38:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L198
    cmp     r13,r12
    jae     L39
    mov     r9,r12
    sub     r9,r13
    jmp     L40
L39:
    mov     r9,r13
    sub     r9,r12
L40:
    cmp     rax,r9
    setbe   al
    jmp     L45
L41:
    test    r14b,r14b
    jne     L34
    cmp     r13,0
    je      L199
    jmp     L34
L42:
    test    cl,cl
    jne     L41
    jmp     L199
L43:
    test    r14b,r14b
    jne     L38
    cmp     r12,0
    je      L199
    jmp     L38
L44:
    test    r8b,r8b
    jne     L43
    jmp     L199
L45:
    test    al,al
    je      L199
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     r8d,[r15]
    mov     r11,[rcx]
    mov     eax,[rax]
    cmp     r8d,eax
    setb    al
    xor     eax,1
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L50
L46:
    mov     rcx,[rsp+1F0h]
    jmp     L48
L47:
    mov     rcx,[rsp+208h]
L48:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L51
L49:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L46
    jmp     L47
L50:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L49
L51:
    lea     r11,[image.k6632]
    mov     [rsp+0E0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L53
L52:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L54
L53:
    cmp     eax,1
    je      L52
    jmp     L201
L54:
    jmp     L63
L55:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L57
L56:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L58
L57:
    cmp     eax,1
    je      L56
    jmp     L202
L58:
    jmp     L65
L59:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L203
    cmp     r13,r12
    jae     L60
    mov     r9,r12
    sub     r9,r13
    jmp     L61
L60:
    mov     r9,r13
    sub     r9,r12
L61:
    cmp     rax,r9
    setbe   al
    jmp     L66
L62:
    test    r14b,r14b
    jne     L55
    cmp     r13,0
    je      L204
    jmp     L55
L63:
    test    cl,cl
    jne     L62
    jmp     L204
L64:
    test    r14b,r14b
    jne     L59
    cmp     r12,0
    je      L204
    jmp     L59
L65:
    test    r8b,r8b
    jne     L64
    jmp     L204
L66:
    test    al,al
    je      L204
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     r8d,[r15]
    mov     r11,[rcx]
    mov     eax,[rax]
    cmp     r8d,eax
    setb    al
    xor     eax,1
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L71
L67:
    mov     rcx,[rsp+1F0h]
    jmp     L69
L68:
    mov     rcx,[rsp+208h]
L69:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L72
L70:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L67
    jmp     L68
L71:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L70
L72:
    lea     r11,[image.k6632]
    mov     [rsp+0E8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L74
L73:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L75
L74:
    cmp     eax,1
    je      L73
    jmp     L206
L75:
    jmp     L84
L76:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L78
L77:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L79
L78:
    cmp     eax,1
    je      L77
    jmp     L207
L79:
    jmp     L86
L80:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L208
    cmp     r13,r12
    jae     L81
    mov     r9,r12
    sub     r9,r13
    jmp     L82
L81:
    mov     r9,r13
    sub     r9,r12
L82:
    cmp     rax,r9
    setbe   al
    jmp     L87
L83:
    test    r14b,r14b
    jne     L76
    cmp     r13,0
    je      L209
    jmp     L76
L84:
    test    cl,cl
    jne     L83
    jmp     L209
L85:
    test    r14b,r14b
    jne     L80
    cmp     r12,0
    je      L209
    jmp     L80
L86:
    test    r8b,r8b
    jne     L85
    jmp     L209
L87:
    test    al,al
    je      L209
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    jmp     L1
L88:
    mov     [rsp+180h],rax
    lea     rdx,[rcx+rax*8]
    mov     [rsp+120h],r15
    mov     [rsp+140h],r8
    mov     [rsp+0F8h],r9
    mov     [rsp+130h],rbx
    mov     rbx,rdx
    mov     [rsp+128h],rcx
    mov     [rsp+100h],r12
    mov     [rsp+108h],r13
    mov     r13,rax
    mov     [rsp+110h],r14
    mov     [rsp+118h],rbp
L89:
    mov     rax,[rsp+1F8h]
    cmp     rax,rbx
    jae     L111
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+140h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     r11,[rsp+120h]
    mov     edx,[r11]
    mov     r11,[rcx]
    mov     eax,[rax]
    cmp     edx,eax
    setb    al
    xor     eax,1
    mov     r15,rax
    mov     [rsp+186h],r15b
    mov     rax,[rsp+208h]
    jmp     L94
L90:
    mov     rcx,[rsp+1F0h]
    jmp     L92
L91:
    mov     rcx,[rsp+208h]
L92:
    mov     rdx,[rsp+200h]
    lea     r14,[rcx+rdx*8]
    mov     rbp,[rsp+1F8h]
    jmp     L95
L93:
    mov     [rsp+208h],rcx
    test    r15b,r15b
    jne     L90
    jmp     L91
L94:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L93
L95:
    lea     r11,[image.k6632]
    mov     [rsp+138h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L97
L96:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L98
L97:
    cmp     eax,1
    je      L96
    jmp     L211
L98:
    jmp     L107
L99:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L101
L100:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L102
L101:
    cmp     eax,1
    je      L100
    jmp     L212
L102:
    jmp     L109
L103:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L213
    cmp     rbp,r14
    jae     L104
    mov     r8,r14
    sub     r8,rbp
    jmp     L105
L104:
    mov     r8,rbp
    sub     r8,r14
L105:
    cmp     rax,r8
    setbe   al
    jmp     L110
L106:
    test    r12b,r12b
    jne     L99
    cmp     rbp,0
    je      L214
    jmp     L99
L107:
    test    cl,cl
    jne     L106
    jmp     L214
L108:
    test    r12b,r12b
    jne     L103
    cmp     r14,0
    je      L214
    jmp     L103
L109:
    test    dl,dl
    jne     L108
    jmp     L214
L110:
    test    al,al
    je      L214
    mov     rdi,r14
    mov     rsi,rbp
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   r15d,r15b
    mov     rax,[rsp+200h]
    add     rax,r15
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    jmp     L89
L111:
    cmp     r13,[rsp+0F8h]
    jne     L112
    mov     eax,1
    jmp     L139
L112:
    lea     rcx,[rsp+1F0h]
    mov     [rsp+180h],rcx
    mov     rcx,[rsp+208h]
    jmp     L117
L113:
    mov     rdx,[rsp+1F0h]
    jmp     L115
L114:
    mov     rdx,[rsp+208h]
L115:
    mov     r8,[rsp+200h]
    lea     rbx,[rdx+r8*8]
    mov     r12,[rsp+1F8h]
    jmp     L118
L116:
    mov     [rsp+208h],rdx
    cmp     byte ptr [rsp+130h],0
    jne     L113
    jmp     L114
L117:
    lea     rcx,[rcx-8]
    mov     rdx,rcx
    jmp     L116
L118:
    lea     r11,[image.k6632]
    mov     [rsp+150h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L120
L119:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L121
L120:
    cmp     ecx,1
    je      L119
    jmp     L216
L121:
    jmp     L130
L122:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L124
L123:
    mov     r8,rbx
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L125
L124:
    cmp     ecx,1
    je      L123
    jmp     L217
L125:
    jmp     L132
L126:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L218
    cmp     r12,rbx
    jae     L127
    mov     r9,rbx
    sub     r9,r12
    jmp     L128
L127:
    mov     r9,r12
    sub     r9,rbx
L128:
    cmp     rcx,r9
    setbe   cl
    jmp     L133
L129:
    test    r14b,r14b
    jne     L122
    cmp     r12,0
    je      L219
    jmp     L122
L130:
    test    dl,dl
    jne     L129
    jmp     L219
L131:
    test    r14b,r14b
    jne     L126
    cmp     rbx,0
    je      L219
    jmp     L126
L132:
    test    r8b,r8b
    jne     L131
    jmp     L219
L133:
    test    cl,cl
    je      L219
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ecx,byte ptr [rsp+130h]
    mov     rdx,[rsp+200h]
    add     rdx,rcx
    mov     [rsp+200h],rdx
    mov     rcx,[rsp+1F8h]
    lea     rcx,[rcx+8]
    mov     [rsp+1F8h],rcx
    mov     r11,[rsp+0F8h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+128h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+120h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+140h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+0F8h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+130h]
    mov     [rsp+40h],r11
    mov     [rsp+20h],rbx
    mov     r11,[rsp+108h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+110h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+38h],r11
    jmp     L0
L134:
    jmp     L140
L135:
    mov     r10,[rsp+110h]
    mov     [rsp+180h],r10
    mov     rbx,[rsp+200h]
    jmp     L156
L136:
    cmp     rcx,r12
    jb      L175
    jmp     L174
L137:
    mov     r10,[rsp+0D0h]
    lea     rdx,[rdi+r10*8]
    mov     r11,[rsp+0F0h]
    lea     r8,[r11+rsi*8]
    mov     r10,[rsp+0F0h]
    mov     [rsp+1F0h],r10
    mov     [rsp+1F8h],rdi
    mov     qword ptr [rsp+200h],0
    mov     [rsp+208h],r8
    mov     r11,[rsp+0D0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rdx
    mov     r11,[rsp+98h]
    mov     [rsp+50h],r11
    mov     [rsp+48h],rsi
    mov     r11,[rsp+0A0h]
    mov     [rsp+40h],r11
    mov     qword ptr [rsp+20h],0
    mov     [rsp+28h],rdi
    mov     r11,[rsp+0F0h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0F0h]
    mov     [rsp+38h],r11
    jmp     L0
L138:
    mov     rdx,[rsp+180h]
    mov     r11,[rsp+60h]
    lea     rdx,[r11+rdx*8]
    mov     rbp,rdx
    mov     r15,[rsp+58h]
    mov     r11,[rsp+50h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+90h],r11
    jmp     L1
L139:
    cmp     al,1
    jne     L134
    jmp     L135
L140:
    mov     r10,[rsp+120h]
    mov     [rsp+180h],r10
    lea     r11,[k13]
    mov     [rsp+148h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L142
L141:
    mov     rdx,[rsp+120h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L143
L142:
    cmp     eax,1
    je      L141
    jmp     L221
L143:
    jmp     L152
L144:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L146
L145:
    mov     rsi,[rsp+100h]
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L147
L146:
    cmp     eax,1
    je      L145
    jmp     L222
L147:
    jmp     L154
L148:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L223
    mov     r11,[rsp+120h]
    cmp     r11,[rsp+100h]
    jae     L149
    mov     rdi,[rsp+100h]
    sub     rdi,[rsp+120h]
    jmp     L150
L149:
    mov     rdi,[rsp+120h]
    sub     rdi,[rsp+100h]
L150:
    cmp     rax,rdi
    setbe   al
    jmp     L155
L151:
    test    r13b,r13b
    jne     L144
    mov     r11,[rsp+120h]
    cmp     r11,0
    je      L224
    jmp     L144
L152:
    test    dl,dl
    jne     L151
    jmp     L224
L153:
    test    r13b,r13b
    jne     L148
    mov     r11,[rsp+100h]
    cmp     r11,0
    je      L224
    jmp     L148
L154:
    test    sil,sil
    jne     L153
    jmp     L224
L155:
    test    al,al
    je      L224
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+120h]
    mov     edx,8
    call    ryo_hr_Memcpy
    jmp     L135
L156:
    lea     r11,[k15]
    mov     [rsp+158h],r11
    cmp     rbx,0
    jne     L157
    mov     r13d,1
    jmp     L158
L157:
    mov     r13d,0
L158:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L160
L159:
    mov     rdx,[rsp+110h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L161
L160:
    cmp     eax,1
    je      L159
    jmp     L226
L161:
    jmp     L170
L162:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L164
L163:
    mov     rsi,[rsp+108h]
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L165
L164:
    cmp     eax,1
    je      L163
    jmp     L227
L165:
    jmp     L172
L166:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     rbx
    mov     rdx,r10
    jb      L228
    mov     r11,[rsp+110h]
    cmp     r11,[rsp+108h]
    jae     L167
    mov     rdi,[rsp+108h]
    sub     rdi,[rsp+110h]
    jmp     L168
L167:
    mov     rdi,[rsp+110h]
    sub     rdi,[rsp+108h]
L168:
    cmp     rax,rdi
    setbe   al
    jmp     L173
L169:
    test    r13b,r13b
    jne     L162
    mov     r11,[rsp+110h]
    cmp     r11,0
    je      L229
    jmp     L162
L170:
    test    dl,dl
    jne     L169
    jmp     L229
L171:
    test    r13b,r13b
    jne     L166
    mov     r11,[rsp+108h]
    cmp     r11,0
    je      L229
    jmp     L166
L172:
    test    sil,sil
    jne     L171
    jmp     L229
L173:
    test    al,al
    je      L229
    imul    rbx,8
    mov     r11,[rsp+108h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rbx
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFD20h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFD28h
    call    ryo_h_Memcpy
    mov     rax,[rsp+200h]
    mov     r11,[rsp+0F8h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+180h],rax
    mov     ecx,0
    mov     r12,rax
    mov     r14,[rsp+0F8h]
    mov     r15,[rsp+118h]
    mov     r11,[rsp+108h]
    mov     [rsp+170h],r11
    jmp     L136
L174:
    mov     rax,[rsp+200h]
    mov     rbx,[rsp+1E0h]
    mov     r12,[rsp+1D0h]
    mov     r13,[rsp+1C0h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A0h]
    mov     rbp,[rsp+190h]
    add     rsp,2F8h
    ret
L175:
    lea     rax,[k17]
    mov     r11,rcx
    add     r11,1
    jb      L231
    mov     r11,rcx
    add     r11,1
    mov     [rsp+160h],r11
    mov     [rsp+180h],rcx
    mov     rdx,r14
    sub     rdx,1
    sub     rdx,rcx
    lea     r13,[r15+rdx*8]
    mov     rdx,[rsp+200h]
    add     rdx,rcx
    mov     r11,[rsp+170h]
    lea     rbx,[r11+rdx*8]
    lea     r11,[k19]
    mov     [rsp+168h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L177
L176:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L178
L177:
    cmp     ecx,1
    je      L176
    jmp     L232
L178:
    jmp     L187
L179:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L181
L180:
    mov     rsi,rbx
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L182
L181:
    cmp     ecx,1
    je      L180
    jmp     L233
L182:
    jmp     L189
L183:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L234
    cmp     r13,rbx
    jae     L184
    mov     rdi,rbx
    sub     rdi,r13
    jmp     L185
L184:
    mov     rdi,r13
    sub     rdi,rbx
L185:
    cmp     rcx,rdi
    setbe   cl
    jmp     L190
L186:
    test    bpl,bpl
    jne     L179
    cmp     r13,0
    je      L235
    jmp     L179
L187:
    test    dl,dl
    jne     L186
    jmp     L235
L188:
    test    bpl,bpl
    jne     L183
    cmp     rbx,0
    je      L235
    jmp     L183
L189:
    test    sil,sil
    jne     L188
    jmp     L235
L190:
    test    cl,cl
    je      L235
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rcx,[rsp+160h]
    jmp     L136
L191:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L192:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L193:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L195
    jmp     L195
L194:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L195:
    call    qword ptr [image.sym10]
    ud2
L196:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L197:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L198:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L200
    jmp     L200
L199:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L200:
    call    qword ptr [image.sym10]
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L205
    jmp     L205
L204:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L205:
    call    qword ptr [image.sym10]
    ud2
L206:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L207:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L208:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L210
    jmp     L210
L209:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L210:
    call    qword ptr [image.sym10]
    ud2
L211:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L212:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L213:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L215
    jmp     L215
L214:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+138h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L215:
    call    qword ptr [image.sym10]
    ud2
L216:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L217:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L218:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L220
    jmp     L220
L219:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+150h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L220:
    call    qword ptr [image.sym10]
    ud2
L221:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L222:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L223:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L225
    jmp     L225
L224:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+148h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L225:
    call    qword ptr [image.sym10]
    ud2
L226:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L227:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L228:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L230
    jmp     L230
L229:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+158h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L230:
    call    qword ptr [image.sym10]
    ud2
L231:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L232:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L233:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L234:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L236
    jmp     L236
L235:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+168h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L236:
    call    qword ptr [image.sym10]
    ud2
L237:
    lea     rdi,[rsp+2F0h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L238]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L238:
    .long   L239
    .long   L240
    .long   L241
    .long   L242
    .long   L243
    .long   L244
L239:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+20h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+60h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-288h],r11
    mov     r11,[rsp+8]
    mov     [rdx-290h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-298h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-2A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-2A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-2B0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2D0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-2C8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-2C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-2B8h],r11
    lea     rsp,[rsp+70h]
    jmp     L0
L240:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+28h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+68h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-280h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-278h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-260h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    lea     rsp,[rsp+70h]
    jmp     L1
L241:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+20h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+68h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1D8h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L89
L242:
    ret
L243:
    ret
L244:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-330h]
    mov     r11,[rdx-58h]
    mov     [rsp],r11
    mov     r11,[rdx-50h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+38h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-180h],r11
    mov     rcx,[rsp]
    mov     r12,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L136

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,2F8h
    mov     [rsp+1E0h],rbx
    mov     [rsp+1D0h],r12
    mov     [rsp+1C0h],r13
    mov     [rsp+1B0h],r14
    mov     [rsp+1A0h],r15
    mov     [rsp+190h],rbp
    mov     [rsp+0F0h],rdx
    mov     [rsp+0D0h],r8
    mov     [rsp+0A8h],r9
    mov     r11,[rsp+300h]
    mov     [rsp+98h],r11
    cmp     rcx,rsi
    jb      L237
    cmp     rsi,[rsp+0D0h]
    jbe     L237
    jmp     L137
L0:
    mov     r10,[rsp+68h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+2F0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L138
L1:
    mov     rcx,[rsp+1F8h]
    cmp     rcx,rbp
    jb      L3
    jmp     L2
L2:
    mov     rax,[rsp+0B8h]
    mov     rcx,[rsp+0B0h]
    mov     r8,[rsp+0C8h]
    mov     r9,[rsp+0A0h]
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+78h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+88h]
    mov     rbp,[rsp+90h]
    jmp     L88
L3:
    mov     rcx,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     ecx,[rcx]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     eax,[r15]
    cmp     ecx,eax
    setb    al
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L8
L4:
    mov     rcx,[rsp+1F0h]
    jmp     L6
L5:
    mov     rcx,[rsp+208h]
L6:
    mov     r9,[rsp+200h]
    lea     r12,[rcx+r9*8]
    mov     r13,[rsp+1F8h]
    jmp     L9
L7:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L4
    jmp     L5
L8:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L7
L9:
    lea     r11,[image.k6632]
    mov     [rsp+0C0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L11
L10:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L12
L11:
    cmp     eax,1
    je      L10
    jmp     L191
L12:
    jmp     L21
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L15
L14:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L16
L15:
    cmp     eax,1
    je      L14
    jmp     L192
L16:
    jmp     L23
L17:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L193
    cmp     r13,r12
    jae     L18
    mov     r8,r12
    sub     r8,r13
    jmp     L19
L18:
    mov     r8,r13
    sub     r8,r12
L19:
    cmp     rax,r8
    setbe   al
    jmp     L24
L20:
    test    r14b,r14b
    jne     L13
    cmp     r13,0
    je      L194
    jmp     L13
L21:
    test    cl,cl
    jne     L20
    jmp     L194
L22:
    test    r14b,r14b
    jne     L17
    cmp     r12,0
    je      L194
    jmp     L17
L23:
    test    r9b,r9b
    jne     L22
    jmp     L194
L24:
    test    al,al
    je      L194
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     eax,[rax]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L29
L25:
    mov     rcx,[rsp+1F0h]
    jmp     L27
L26:
    mov     rcx,[rsp+208h]
L27:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L30
L28:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L25
    jmp     L26
L29:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L28
L30:
    lea     r11,[image.k6632]
    mov     [rsp+0D8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L196
L33:
    jmp     L42
L34:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L36
L35:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L37
L36:
    cmp     eax,1
    je      L35
    jmp     L197
L37:
    jmp     L44
L38:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L198
    cmp     r13,r12
    jae     L39
    mov     r9,r12
    sub     r9,r13
    jmp     L40
L39:
    mov     r9,r13
    sub     r9,r12
L40:
    cmp     rax,r9
    setbe   al
    jmp     L45
L41:
    test    r14b,r14b
    jne     L34
    cmp     r13,0
    je      L199
    jmp     L34
L42:
    test    cl,cl
    jne     L41
    jmp     L199
L43:
    test    r14b,r14b
    jne     L38
    cmp     r12,0
    je      L199
    jmp     L38
L44:
    test    r8b,r8b
    jne     L43
    jmp     L199
L45:
    test    al,al
    je      L199
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     eax,[rax]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L50
L46:
    mov     rcx,[rsp+1F0h]
    jmp     L48
L47:
    mov     rcx,[rsp+208h]
L48:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L51
L49:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L46
    jmp     L47
L50:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L49
L51:
    lea     r11,[image.k6632]
    mov     [rsp+0E0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L53
L52:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L54
L53:
    cmp     eax,1
    je      L52
    jmp     L201
L54:
    jmp     L63
L55:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L57
L56:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L58
L57:
    cmp     eax,1
    je      L56
    jmp     L202
L58:
    jmp     L65
L59:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L203
    cmp     r13,r12
    jae     L60
    mov     r9,r12
    sub     r9,r13
    jmp     L61
L60:
    mov     r9,r13
    sub     r9,r12
L61:
    cmp     rax,r9
    setbe   al
    jmp     L66
L62:
    test    r14b,r14b
    jne     L55
    cmp     r13,0
    je      L204
    jmp     L55
L63:
    test    cl,cl
    jne     L62
    jmp     L204
L64:
    test    r14b,r14b
    jne     L59
    cmp     r12,0
    je      L204
    jmp     L59
L65:
    test    r8b,r8b
    jne     L64
    jmp     L204
L66:
    test    al,al
    je      L204
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     eax,[rax]
    mov     r11,[rsp+0C8h]
    mov     r11,[r11]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     [rsp+186h],bl
    mov     rax,[rsp+208h]
    jmp     L71
L67:
    mov     rcx,[rsp+1F0h]
    jmp     L69
L68:
    mov     rcx,[rsp+208h]
L69:
    mov     r8,[rsp+200h]
    lea     r12,[rcx+r8*8]
    mov     r13,[rsp+1F8h]
    jmp     L72
L70:
    mov     [rsp+208h],rcx
    test    bl,bl
    jne     L67
    jmp     L68
L71:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L70
L72:
    lea     r11,[image.k6632]
    mov     [rsp+0E8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L74
L73:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L75
L74:
    cmp     eax,1
    je      L73
    jmp     L206
L75:
    jmp     L84
L76:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L78
L77:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L79
L78:
    cmp     eax,1
    je      L77
    jmp     L207
L79:
    jmp     L86
L80:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L208
    cmp     r13,r12
    jae     L81
    mov     r9,r12
    sub     r9,r13
    jmp     L82
L81:
    mov     r9,r13
    sub     r9,r12
L82:
    cmp     rax,r9
    setbe   al
    jmp     L87
L83:
    test    r14b,r14b
    jne     L76
    cmp     r13,0
    je      L209
    jmp     L76
L84:
    test    cl,cl
    jne     L83
    jmp     L209
L85:
    test    r14b,r14b
    jne     L80
    cmp     r12,0
    je      L209
    jmp     L80
L86:
    test    r8b,r8b
    jne     L85
    jmp     L209
L87:
    test    al,al
    je      L209
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ebx,bl
    mov     rax,[rsp+200h]
    add     rax,rbx
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    jmp     L1
L88:
    mov     [rsp+180h],rax
    lea     rdx,[rcx+rax*8]
    mov     [rsp+120h],r15
    mov     [rsp+140h],r8
    mov     [rsp+0F8h],r9
    mov     [rsp+130h],rbx
    mov     rbx,rdx
    mov     [rsp+128h],rcx
    mov     [rsp+100h],r12
    mov     [rsp+108h],r13
    mov     r13,rax
    mov     [rsp+110h],r14
    mov     [rsp+118h],rbp
L89:
    mov     rax,[rsp+1F8h]
    cmp     rax,rbx
    jae     L111
    mov     rax,[rsp+1F8h]
    mov     r11,[rsp+140h]
    mov     r11,[r11]
    mov     eax,[rax]
    mov     r11,[rsp+140h]
    mov     r11,[r11]
    mov     r11,[rsp+120h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r15,rax
    mov     [rsp+186h],r15b
    mov     rax,[rsp+208h]
    jmp     L94
L90:
    mov     rcx,[rsp+1F0h]
    jmp     L92
L91:
    mov     rcx,[rsp+208h]
L92:
    mov     rdx,[rsp+200h]
    lea     r14,[rcx+rdx*8]
    mov     rbp,[rsp+1F8h]
    jmp     L95
L93:
    mov     [rsp+208h],rcx
    test    r15b,r15b
    jne     L90
    jmp     L91
L94:
    lea     rax,[rax-8]
    mov     rcx,rax
    jmp     L93
L95:
    lea     r11,[image.k6632]
    mov     [rsp+138h],r11
    mov     r12d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L97
L96:
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L98
L97:
    cmp     eax,1
    je      L96
    jmp     L211
L98:
    jmp     L107
L99:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L101
L100:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L102
L101:
    cmp     eax,1
    je      L100
    jmp     L212
L102:
    jmp     L109
L103:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L213
    cmp     rbp,r14
    jae     L104
    mov     r8,r14
    sub     r8,rbp
    jmp     L105
L104:
    mov     r8,rbp
    sub     r8,r14
L105:
    cmp     rax,r8
    setbe   al
    jmp     L110
L106:
    test    r12b,r12b
    jne     L99
    cmp     rbp,0
    je      L214
    jmp     L99
L107:
    test    cl,cl
    jne     L106
    jmp     L214
L108:
    test    r12b,r12b
    jne     L103
    cmp     r14,0
    je      L214
    jmp     L103
L109:
    test    dl,dl
    jne     L108
    jmp     L214
L110:
    test    al,al
    je      L214
    mov     rdi,r14
    mov     rsi,rbp
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   r15d,r15b
    mov     rax,[rsp+200h]
    add     rax,r15
    mov     [rsp+200h],rax
    mov     rax,[rsp+1F8h]
    lea     rax,[rax+8]
    mov     [rsp+1F8h],rax
    jmp     L89
L111:
    cmp     r13,[rsp+0F8h]
    jne     L112
    mov     eax,1
    jmp     L139
L112:
    lea     rcx,[rsp+1F0h]
    mov     [rsp+180h],rcx
    mov     rcx,[rsp+208h]
    jmp     L117
L113:
    mov     rdx,[rsp+1F0h]
    jmp     L115
L114:
    mov     rdx,[rsp+208h]
L115:
    mov     r8,[rsp+200h]
    lea     rbx,[rdx+r8*8]
    mov     r12,[rsp+1F8h]
    jmp     L118
L116:
    mov     [rsp+208h],rdx
    cmp     byte ptr [rsp+130h],0
    jne     L113
    jmp     L114
L117:
    lea     rcx,[rcx-8]
    mov     rdx,rcx
    jmp     L116
L118:
    lea     r11,[image.k6632]
    mov     [rsp+150h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L120
L119:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L121
L120:
    cmp     ecx,1
    je      L119
    jmp     L216
L121:
    jmp     L130
L122:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L124
L123:
    mov     r8,rbx
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L125
L124:
    cmp     ecx,1
    je      L123
    jmp     L217
L125:
    jmp     L132
L126:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L218
    cmp     r12,rbx
    jae     L127
    mov     r9,rbx
    sub     r9,r12
    jmp     L128
L127:
    mov     r9,r12
    sub     r9,rbx
L128:
    cmp     rcx,r9
    setbe   cl
    jmp     L133
L129:
    test    r14b,r14b
    jne     L122
    cmp     r12,0
    je      L219
    jmp     L122
L130:
    test    dl,dl
    jne     L129
    jmp     L219
L131:
    test    r14b,r14b
    jne     L126
    cmp     rbx,0
    je      L219
    jmp     L126
L132:
    test    r8b,r8b
    jne     L131
    jmp     L219
L133:
    test    cl,cl
    je      L219
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ecx,byte ptr [rsp+130h]
    mov     rdx,[rsp+200h]
    add     rdx,rcx
    mov     [rsp+200h],rdx
    mov     rcx,[rsp+1F8h]
    lea     rcx,[rcx+8]
    mov     [rsp+1F8h],rcx
    mov     r11,[rsp+0F8h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+128h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+120h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+140h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+0F8h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+130h]
    mov     [rsp+40h],r11
    mov     [rsp+20h],rbx
    mov     r11,[rsp+108h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+110h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+38h],r11
    jmp     L0
L134:
    jmp     L140
L135:
    mov     r10,[rsp+110h]
    mov     [rsp+180h],r10
    mov     rbx,[rsp+200h]
    jmp     L156
L136:
    cmp     rcx,r12
    jb      L175
    jmp     L174
L137:
    mov     r10,[rsp+0D0h]
    lea     rdx,[rdi+r10*8]
    mov     r11,[rsp+0F0h]
    lea     r8,[r11+rsi*8]
    mov     r10,[rsp+0F0h]
    mov     [rsp+1F0h],r10
    mov     [rsp+1F8h],rdi
    mov     qword ptr [rsp+200h],0
    mov     [rsp+208h],r8
    mov     r11,[rsp+0D0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rdx
    mov     r11,[rsp+98h]
    mov     [rsp+50h],r11
    mov     [rsp+48h],rsi
    mov     r11,[rsp+0A8h]
    mov     [rsp+40h],r11
    mov     qword ptr [rsp+20h],0
    mov     [rsp+28h],rdi
    mov     r11,[rsp+0F0h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0F0h]
    mov     [rsp+38h],r11
    jmp     L0
L138:
    mov     rdx,[rsp+180h]
    mov     r11,[rsp+60h]
    lea     rdx,[r11+rdx*8]
    mov     rbp,rdx
    mov     r15,[rsp+58h]
    mov     r11,[rsp+50h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+90h],r11
    jmp     L1
L139:
    cmp     al,1
    jne     L134
    jmp     L135
L140:
    mov     r10,[rsp+120h]
    mov     [rsp+180h],r10
    lea     r11,[k13]
    mov     [rsp+148h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L142
L141:
    mov     rdx,[rsp+120h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L143
L142:
    cmp     eax,1
    je      L141
    jmp     L221
L143:
    jmp     L152
L144:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L146
L145:
    mov     rsi,[rsp+100h]
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L147
L146:
    cmp     eax,1
    je      L145
    jmp     L222
L147:
    jmp     L154
L148:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L223
    mov     r11,[rsp+120h]
    cmp     r11,[rsp+100h]
    jae     L149
    mov     rdi,[rsp+100h]
    sub     rdi,[rsp+120h]
    jmp     L150
L149:
    mov     rdi,[rsp+120h]
    sub     rdi,[rsp+100h]
L150:
    cmp     rax,rdi
    setbe   al
    jmp     L155
L151:
    test    r13b,r13b
    jne     L144
    mov     r11,[rsp+120h]
    cmp     r11,0
    je      L224
    jmp     L144
L152:
    test    dl,dl
    jne     L151
    jmp     L224
L153:
    test    r13b,r13b
    jne     L148
    mov     r11,[rsp+100h]
    cmp     r11,0
    je      L224
    jmp     L148
L154:
    test    sil,sil
    jne     L153
    jmp     L224
L155:
    test    al,al
    je      L224
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+120h]
    mov     edx,8
    call    ryo_hr_Memcpy
    jmp     L135
L156:
    lea     r11,[k15]
    mov     [rsp+158h],r11
    cmp     rbx,0
    jne     L157
    mov     r13d,1
    jmp     L158
L157:
    mov     r13d,0
L158:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L160
L159:
    mov     rdx,[rsp+110h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L161
L160:
    cmp     eax,1
    je      L159
    jmp     L226
L161:
    jmp     L170
L162:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L164
L163:
    mov     rsi,[rsp+108h]
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L165
L164:
    cmp     eax,1
    je      L163
    jmp     L227
L165:
    jmp     L172
L166:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     rbx
    mov     rdx,r10
    jb      L228
    mov     r11,[rsp+110h]
    cmp     r11,[rsp+108h]
    jae     L167
    mov     rdi,[rsp+108h]
    sub     rdi,[rsp+110h]
    jmp     L168
L167:
    mov     rdi,[rsp+110h]
    sub     rdi,[rsp+108h]
L168:
    cmp     rax,rdi
    setbe   al
    jmp     L173
L169:
    test    r13b,r13b
    jne     L162
    mov     r11,[rsp+110h]
    cmp     r11,0
    je      L229
    jmp     L162
L170:
    test    dl,dl
    jne     L169
    jmp     L229
L171:
    test    r13b,r13b
    jne     L166
    mov     r11,[rsp+108h]
    cmp     r11,0
    je      L229
    jmp     L166
L172:
    test    sil,sil
    jne     L171
    jmp     L229
L173:
    test    al,al
    je      L229
    imul    rbx,8
    mov     r11,[rsp+108h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rbx
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFD20h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFD28h
    call    ryo_h_Memcpy
    mov     rax,[rsp+200h]
    mov     r11,[rsp+0F8h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+180h],rax
    mov     ecx,0
    mov     r12,rax
    mov     r14,[rsp+0F8h]
    mov     r15,[rsp+118h]
    mov     r11,[rsp+108h]
    mov     [rsp+170h],r11
    jmp     L136
L174:
    mov     rax,[rsp+200h]
    mov     rbx,[rsp+1E0h]
    mov     r12,[rsp+1D0h]
    mov     r13,[rsp+1C0h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A0h]
    mov     rbp,[rsp+190h]
    add     rsp,2F8h
    ret
L175:
    lea     rax,[k17]
    mov     r11,rcx
    add     r11,1
    jb      L231
    mov     r11,rcx
    add     r11,1
    mov     [rsp+160h],r11
    mov     [rsp+180h],rcx
    mov     rdx,r14
    sub     rdx,1
    sub     rdx,rcx
    lea     r13,[r15+rdx*8]
    mov     rdx,[rsp+200h]
    add     rdx,rcx
    mov     r11,[rsp+170h]
    lea     rbx,[r11+rdx*8]
    lea     r11,[k19]
    mov     [rsp+168h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L177
L176:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L178
L177:
    cmp     ecx,1
    je      L176
    jmp     L232
L178:
    jmp     L187
L179:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L181
L180:
    mov     rsi,rbx
    and     rsi,3
    cmp     rsi,0
    sete    sil
    jmp     L182
L181:
    cmp     ecx,1
    je      L180
    jmp     L233
L182:
    jmp     L189
L183:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rcx,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L234
    cmp     r13,rbx
    jae     L184
    mov     rdi,rbx
    sub     rdi,r13
    jmp     L185
L184:
    mov     rdi,r13
    sub     rdi,rbx
L185:
    cmp     rcx,rdi
    setbe   cl
    jmp     L190
L186:
    test    bpl,bpl
    jne     L179
    cmp     r13,0
    je      L235
    jmp     L179
L187:
    test    dl,dl
    jne     L186
    jmp     L235
L188:
    test    bpl,bpl
    jne     L183
    cmp     rbx,0
    je      L235
    jmp     L183
L189:
    test    sil,sil
    jne     L188
    jmp     L235
L190:
    test    cl,cl
    je      L235
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rcx,[rsp+160h]
    jmp     L136
L191:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L192:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L193:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L195
    jmp     L195
L194:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L195:
    call    qword ptr [image.sym10]
    ud2
L196:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L197:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L198:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L200
    jmp     L200
L199:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L200:
    call    qword ptr [image.sym10]
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L205
    jmp     L205
L204:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L205:
    call    qword ptr [image.sym10]
    ud2
L206:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L207:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L208:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L210
    jmp     L210
L209:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L210:
    call    qword ptr [image.sym10]
    ud2
L211:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L212:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L213:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L215
    jmp     L215
L214:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+138h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L215:
    call    qword ptr [image.sym10]
    ud2
L216:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L217:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L218:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L220
    jmp     L220
L219:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+150h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L220:
    call    qword ptr [image.sym10]
    ud2
L221:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L222:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L223:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L225
    jmp     L225
L224:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+148h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L225:
    call    qword ptr [image.sym10]
    ud2
L226:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L227:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L228:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L230
    jmp     L230
L229:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+158h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L230:
    call    qword ptr [image.sym10]
    ud2
L231:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L232:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L233:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L234:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L236
    jmp     L236
L235:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+168h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L236:
    call    qword ptr [image.sym10]
    ud2
L237:
    lea     rdi,[rsp+2F0h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L238]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L238:
    .long   L239
    .long   L240
    .long   L241
    .long   L242
    .long   L243
    .long   L244
L239:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+20h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+60h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-288h],r11
    mov     r11,[rsp+8]
    mov     [rdx-290h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-298h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-2A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-2A8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-2B0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2D0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-2C8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-2C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-2B8h],r11
    lea     rsp,[rsp+70h]
    jmp     L0
L240:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+28h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+68h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-280h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-278h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-260h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    lea     rsp,[rsp+70h]
    jmp     L1
L241:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-360h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+20h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+68h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1D8h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L89
L242:
    ret
L243:
    ret
L244:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-330h]
    mov     r11,[rdx-58h]
    mov     [rsp],r11
    mov     r11,[rdx-50h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-108h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+38h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-2F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-2E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-180h],r11
    mov     rcx,[rsp]
    mov     r12,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L136

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rsi
    mov     r11,[rdi]
    mov     rax,[rbx+10h]
    mov     rcx,[rdi+8]
    mov     eax,[rax]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    al
    mov     r12,rax
    mov     rax,[rdi+10h]
    mov     rax,[rax]
    mov     rcx,[rbx+18h]
    lea     r13,[rax+rcx*4]
    mov     r14,[rbx]
    mov     ebp,0
    jmp     L1
L0:
    mov     r15,[rbx+10h]
    jmp     L18
L1:
    lea     r11,[k1]
    mov     [rsp+10h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L34
L4:
    jmp     L10
L5:
    test    bpl,bpl
    je      L9
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L35
L8:
    jmp     L12
L9:
    cmp     r13,0
    je      L37
    jmp     L13
L10:
    test    cl,cl
    jne     L5
    jmp     L37
L11:
    cmp     r14,0
    je      L37
    jmp     L17
L12:
    test    dl,dl
    jne     L17
    jmp     L37
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L15
L14:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L16
L15:
    cmp     eax,1
    je      L14
    jmp     L36
L16:
    test    cl,cl
    jne     L11
    jmp     L37
L17:
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L18:
    lea     r14,[k3]
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L20
L19:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L21
L20:
    cmp     eax,1
    je      L19
    jmp     L39
L21:
    jmp     L30
L22:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L24
L23:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L25
L24:
    cmp     eax,1
    je      L23
    jmp     L40
L25:
    jmp     L32
L26:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L41
    cmp     r15,r13
    jae     L27
    mov     rsi,r13
    sub     rsi,r15
    jmp     L28
L27:
    mov     rsi,r15
    sub     rsi,r13
L28:
    cmp     rax,rsi
    setbe   al
    jmp     L33
L29:
    test    bpl,bpl
    jne     L22
    cmp     r15,0
    je      L42
    jmp     L22
L30:
    test    cl,cl
    jne     L29
    jmp     L42
L31:
    test    bpl,bpl
    jne     L26
    cmp     r13,0
    je      L42
    jmp     L26
L32:
    test    dl,dl
    jne     L31
    jmp     L42
L33:
    test    al,al
    je      L42
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rax,[rbx+10h]
    mov     [rbx],rax
    movzx   r12d,r12b
    mov     rcx,[rbx+18h]
    add     rcx,r12
    mov     [rbx+18h],rcx
    lea     rax,[rax+4]
    mov     [rbx+10h],rax
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L34:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L35:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L36:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L38
L37:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L38
L38:
    call    qword ptr [image.sym10]
    ud2
L39:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L40:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L41:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L43
    jmp     L43
L42:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L43:
    call    qword ptr [image.sym10]
    ud2
  ; OSR entries
    lea     r11,[L44]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L44:
    .long   L45
L45:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,3C8h
    mov     [rsp+2F0h],rbx
    mov     [rsp+2E0h],r12
    mov     [rsp+2D0h],r13
    mov     [rsp+2C0h],r14
    mov     [rsp+2B0h],r15
    mov     [rsp+2A0h],rbp
    mov     [rsp+18h],r8
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
L0:
    mov     eax,20h
    cmp     rax,[rsp+10h]
    jb      L59
    mov     r11,[rsp+10h]
    cmp     r11,2
    jb      L278
    mov     r11,[rsp+10h]
    cmp     r11,20h
    ja      L294
    mov     rdi,[rsp+10h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+70h],rax
    mov     r11,[rsp+10h]
    cmp     r11,12h
    setb    [rsp+68h]
    cmp     byte ptr [rsp+68h],0
    je      L1
    mov     r11,[rsp+10h]
    mov     [rsp+60h],r11
    jmp     L2
L1:
    mov     r11,[rsp+70h]
    mov     [rsp+60h],r11
L2:
    jmp     L49
L3:
    mov     r10,[rsp+90h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+90h]
    mov     [rsp+218h],r10
    mov     r11,[rsp+90h]
    cmp     r11,0Dh
    jb      L24
    mov     r10,[rsp+78h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+90h]
    mov     [rsp+218h],r10
    mov     r11,[rsp+90h]
    cmp     r11,0Dh
    jb      L284
    mov     rdi,[rsp+78h]
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,2
    mov     edx,9
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,3
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,1
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,7
    mov     edx,9
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0Bh
    mov     edx,0Ch
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,4
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,5
    mov     edx,9
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,4
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,2
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,6
    mov     edx,9
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     rdi,[rsp+78h]
    mov     esi,8
    mov     edx,9
    mov     rcx,[rsp+48h]
    call    image.fn72
    mov     r13,[rsp+78h]
    lea     r13,[r13+0Ch]
    mov     r14,[rsp+78h]
    lea     r14,[r14+10h]
    mov     rdi,[rsp+48h]
    mov     rsi,r14
    mov     rdx,r13
    call    fn6
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+150h],eax
    mov     eax,0
    jmp     L5
L4:
    lea     rbp,[rsp+150h]
    jmp     L6
L5:
    lea     rdx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r13
    mov     rcx,rax
    mov     r8,rdx
    mov     edx,4
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L4
L6:
    lea     rax,[image.k2112]
    mov     rdi,rbp
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+78h]
    lea     r13,[r13+14h]
    mov     r14,[rsp+78h]
    lea     r14,[r14+18h]
    mov     rdi,r14
    mov     rsi,r13
    call    qword ptr [image.fn206.slot]
    mov     r15,rax
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+160h],eax
    mov     ebx,0
    jmp     L8
L7:
    lea     r15,[rsp+160h]
    jmp     L16
L8:
    lea     r11,[image.k2088]
    mov     [rsp+80h],r11
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    jmp     L11
L9:
    test    bl,bl
    je      L10
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L13
L10:
    cmp     rbp,0
    je      L280
    jmp     L14
L11:
    test    al,al
    jne     L9
    jmp     L280
L12:
    cmp     r13,0
    je      L280
    jmp     L15
L13:
    test    dl,dl
    jne     L15
    jmp     L280
L14:
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L12
    jmp     L280
L15:
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L7
L16:
    lea     r11,[image.k2112]
    mov     [rsp+88h],r11
    mov     r13d,0
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    jmp     L20
L17:
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L22
L18:
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    mov     rsi,rax
    jmp     L23
L19:
    test    r13b,r13b
    jne     L17
    cmp     r15,0
    je      L282
    jmp     L17
L20:
    test    al,al
    jne     L19
    jmp     L282
L21:
    test    r13b,r13b
    jne     L18
    cmp     r14,0
    je      L282
    jmp     L18
L22:
    test    dl,dl
    jne     L21
    jmp     L282
L23:
    test    sil,sil
    je      L282
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,0Dh
    jmp     L26
L24:
    mov     r10,[rsp+90h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+90h]
    mov     [rsp+218h],r10
    mov     r11,[rsp+90h]
    cmp     r11,9
    jb      L25
    mov     r10,[rsp+78h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+90h]
    mov     [rsp+218h],r10
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+48h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L26
L25:
    mov     eax,1
L26:
    mov     r10,[rsp+78h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+90h]
    mov     [rsp+218h],r10
    cmp     rax,0
    je      L290
    mov     r11,[rsp+90h]
    cmp     r11,rax
    jb      L290
    mov     r11,[rsp+78h]
    mov     r10,[rsp+90h]
    lea     rdx,[r11+r10*4]
    mov     r11,[rsp+78h]
    lea     rax,[r11+rax*4]
    mov     r13,rax
    mov     r14,rdx
    mov     r11,[rsp+78h]
    mov     [rsp+98h],r11
L27:
    cmp     r13,r14
    je      L46
    jmp     L34
L28:
    movzx   eax,byte ptr [rsp+16Fh]
    test    al,al
    je      L45
    mov     [rsp+180h],r13
    mov     eax,[r13]
    mov     [rsp+184h],eax
    mov     [rsp+16Ch],eax
    lea     rax,[rsp+16Ch]
    mov     [rsp+170h],rax
    mov     [rsp+178h],r13
    mov     qword ptr [rsp+180h],1
    mov     rbx,rbp
    mov     r12,[rsp+98h]
L29:
    mov     r15,[rsp+178h]
    jmp     L35
L30:
    jmp     L44
L31:
    test    sil,sil
    je      L32
    mov     rbx,rdi
    mov     r12,r8
    jmp     L29
L32:
    lea     rsi,[rsp+170h]
    mov     rdi,rsi
    call    qword ptr [image.fn229.slot]
    jmp     L45
L33:
    mov     [rsp+170h],r13
    mov     [rsp+178h],r13
    mov     [rsp+180h],rbp
    mov     rdi,r13
    mov     rsi,rbp
    call    qword ptr [image.fn206.slot]
    mov     rsi,rax
    mov     [rsp+16Fh],sil
    jmp     L28
L34:
    mov     rsi,r13
    lea     rsi,[rsi-4]
    mov     rbp,rsi
    jmp     L33
L35:
    lea     r11,[image.k1728]
    mov     [rsp+0A0h],r11
    mov     ebp,0
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    jmp     L39
L36:
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    mov     rdi,rax
    jmp     L41
L37:
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    mov     r8,rax
    jmp     L42
L38:
    test    bpl,bpl
    jne     L36
    cmp     rbx,0
    je      L285
    jmp     L36
L39:
    test    sil,sil
    jne     L38
    jmp     L285
L40:
    test    bpl,bpl
    jne     L37
    cmp     r15,0
    je      L285
    jmp     L37
L41:
    test    dil,dil
    jne     L40
    jmp     L285
L42:
    test    r8b,r8b
    je      L285
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     [rsp+178h],rbx
    cmp     rbx,r12
    je      L32
    mov     rax,rbx
    mov     rdx,r12
    jmp     L30
L43:
    lea     rsi,[rsp+16Ch]
    mov     rdi,rsi
    mov     rsi,rbx
    call    qword ptr [image.fn206.slot]
    mov     rsi,rax
    mov     rdi,rbx
    mov     r8,r12
    jmp     L31
L44:
    lea     rax,[rax-4]
    mov     rbx,rax
    mov     r12,rdx
    jmp     L43
L45:
    lea     r13,[r13+4]
    jmp     L27
L46:
    cmp     byte ptr [rsp+58h],0
    jne     L278
    mov     r10,[rsp+90h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+78h]
    mov     [rsp+218h],r10
    mov     r10,[rsp+38h]
    mov     [rsp+210h],r10
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+38h]
    je      L47
    lea     rbx,[rsp+188h]
    jmp     L57
L47:
    mov     r11,[rsp+30h]
    mov     r10,[rsp+50h]
    lea     rax,[r11+r10*4]
    mov     [rsp+218h],rax
    mov     rax,[rsp+40h]
    sub     rax,[rsp+50h]
    mov     [rsp+210h],rax
    jmp     L50
L48:
    mov     [rsp+218h],rbx
    jmp     L58
L49:
    mov     r10,[rsp+20h]
    mov     [rsp+218h],r10
    lea     rax,[image.k2160]
    mov     rdi,[rsp+20h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+60h]
    mov     r8,rax
    call    image.fn187
    mov     r10,[rsp+20h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+218h],r10
    mov     r11,[rsp+18h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+90h],r11
    jmp     L3
L50:
    mov     r12,[rsp+218h]
    lea     r11,[image.k2184]
    mov     [rsp+0A8h],r11
    mov     r14,[rsp+210h]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L52
L51:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L53
L52:
    cmp     eax,1
    je      L51
    jmp     L291
L53:
    jmp     L55
L54:
    cmp     r12,0
    je      L292
    jmp     L56
L55:
    test    dl,dl
    jne     L54
    jmp     L292
L56:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L292
    mov     rax,[rsp+218h]
    mov     rdx,[rsp+210h]
    mov     [rsp+78h],rax
    mov     [rsp+90h],rdx
    jmp     L3
L57:
    lea     rax,[image.k2208]
    mov     rdi,[rsp+38h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+40h]
    mov     r8,rax
    call    image.fn187
    mov     r10,[rsp+30h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+218h],r10
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+40h]
    mov     rdx,rbx
    mov     rcx,[rsp+48h]
    call    qword ptr [image.fn78.slot]
    jmp     L48
L58:
    mov     [rsp+210h],rbx
    lea     rax,[image.k2232]
    mov     rdi,rbx
    mov     rsi,[rsp+38h]
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+40h]
    mov     r9,rax
    call    image.fn180
    mov     rax,[rsp+40h]
    imul    rax,4
    mov     r11,[rsp+30h]
    mov     [rsp],r11
    mov     [rsp+8],rax
    lea     rdi,[rsp+3C0h]
    mov     esi,0FFFFFC40h
    mov     edx,0FFFFFE58h
    mov     ecx,0FFFFFC48h
    call    ryo_h_Memcpy
    jmp     L278
L59:
    cmp     ecx,0
    jne     L60
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
    jmp     L278
L60:
    mov     r11,rcx
    sub     r11d,1
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+10h]
    cmp     r11,8
    jb      L298
    mov     rdi,[rsp+10h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+20h]
    lea     r12,[r11+rcx*4]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+20h]
    lea     r14,[r11+rcx*4]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L64
    mov     r11,[rsp+20h]
    mov     ecx,[r11]
    mov     edx,[r12]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+20h]
    mov     edx,[r11]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    cmp     cl,dl
    jne     L62
    mov     edx,[r12]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    xor     edx,ecx
    test    dl,dl
    je      L61
    mov     rcx,r14
    jmp     L63
L61:
    mov     rcx,r12
    jmp     L63
L62:
    mov     rcx,[rsp+20h]
L63:
    jmp     L72
L64:
    mov     rdx,rax
    imul    rdx,8
    cmp     rdx,40h
    jb      L65
    jmp     L66
L65:
    mov     rbx,[rsp+20h]
    jmp     L67
L66:
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r15,rax
    mov     rbp,r15
    imul    rbp,4
    mov     r11,[rsp+20h]
    lea     rax,[r11+rbp*4]
    mov     r13,r15
    imul    r13,7
    mov     r11,[rsp+20h]
    lea     rdx,[r11+r13*4]
    mov     rdi,[rsp+20h]
    mov     rsi,rax
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     rbx,rax
    lea     rax,[r12+rbp*4]
    lea     rdx,[r12+r13*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r12,rax
    lea     rax,[r14+rbp*4]
    lea     rdx,[r14+r13*4]
    mov     rdi,r14
    mov     rsi,rax
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r14,rax
L67:
    mov     eax,[rbx]
    mov     edx,[r12]
    cmp     eax,edx
    setb    al
    mov     edx,[rbx]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    cmp     al,dl
    jne     L69
    mov     edx,[r12]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    xor     edx,eax
    test    dl,dl
    je      L68
    jmp     L70
L68:
    mov     r14,r12
    jmp     L70
L69:
    mov     r14,rbx
L70:
    jmp     L73
L71:
    cmp     rax,[rsp+10h]
    setb    dl
    jmp     L74
L72:
    lea     rsi,[image.k1536]
    cmp     rcx,[rsp+20h]
    jb      L295
    sub     rcx,[rsp+20h]
    mov     rdi,rcx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rax,rcx
    jmp     L71
L73:
    lea     rcx,[image.k1584]
    cmp     r14,[rsp+20h]
    jb      L296
    sub     r14,[rsp+20h]
    mov     rdi,r14
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    mov     rax,rdi
    jmp     L71
L74:
    lea     rdi,[image.k1632]
    test    dl,dl
    je      L297
    mov     [rsp+0B8h],rax
    mov     rdi,[rsp+28h]
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
    lea     r11,[L75]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L75:
    .long   L177
    .long   L76
    .long   L372
L76:
    mov     r11,[rsp+0B8h]
    cmp     r11,[rsp+10h]
    jae     L369
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0B8h]
    lea     rax,[r11+r10*4]
    mov     r11,[rsp+28h]
    mov     edx,[r11]
    mov     eax,[rax]
    cmp     edx,eax
    setb    al
    test    al,al
    jne     L177
    mov     r10,[rsp+18h]
    mov     [rsp+320h],r10
    lea     r12,[rsp+320h]
    mov     r11,[rsp+10h]
    cmp     r11,0
    jne     L77
    mov     ebx,0
    jmp     L176
L77:
    mov     r11,[rsp+0B8h]
    cmp     r11,[rsp+10h]
    jae     L331
    lea     rax,[image.k4408]
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L299
    mov     r11,[rsp+0B8h]
    cmp     r11,[rsp+10h]
    jae     L299
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0B8h]
    lea     r13,[r11+r10*4]
    lea     r14,[rsp+22Ch]
    lea     r15,[image.k488]
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L79
L78:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L80
L79:
    cmp     edx,1
    je      L78
    jmp     L300
L80:
    jmp     L89
L81:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L83
L82:
    mov     r9,r14
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L84
L83:
    cmp     edx,1
    je      L82
    jmp     L301
L84:
    jmp     L91
L85:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L302
    mov     r11,[rsp+20h]
    cmp     r11,r14
    jae     L86
    mov     rbx,r14
    sub     rbx,[rsp+20h]
    jmp     L87
L86:
    mov     rbx,[rsp+20h]
    sub     rbx,r14
L87:
    cmp     rdx,rbx
    setbe   dl
    jmp     L92
L88:
    test    bpl,bpl
    jne     L81
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L303
    jmp     L81
L89:
    test    r8b,r8b
    jne     L88
    jmp     L303
L90:
    test    bpl,bpl
    jne     L85
    cmp     r14,0
    je      L303
    jmp     L85
L91:
    test    r9b,r9b
    jne     L90
    jmp     L303
L92:
    test    dl,dl
    je      L303
    mov     rdi,r14
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L94
L93:
    lea     rbx,[rsp+22Ch]
    jmp     L111
L94:
    lea     r11,[image.k512]
    mov     [rsp+0C8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L96
L95:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L97
L96:
    cmp     edx,1
    je      L95
    jmp     L305
L97:
    jmp     L103
L98:
    test    r14b,r14b
    je      L102
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L100
L99:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L101
L100:
    cmp     edx,1
    je      L99
    jmp     L306
L101:
    jmp     L105
L102:
    cmp     r13,0
    je      L308
    jmp     L106
L103:
    test    r8b,r8b
    jne     L98
    jmp     L308
L104:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L308
    jmp     L110
L105:
    test    r9b,r9b
    jne     L110
    jmp     L308
L106:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L108
L107:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L109
L108:
    cmp     edx,1
    je      L107
    jmp     L307
L109:
    test    r8b,r8b
    jne     L104
    jmp     L308
L110:
    mov     rdi,[rsp+20h]
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L93
L111:
    lea     r11,[image.k536]
    mov     [rsp+0C0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L113
L112:
    mov     r8,rbx
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L114
L113:
    cmp     edx,1
    je      L112
    jmp     L310
L114:
    jmp     L123
L115:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L117
L116:
    mov     r9,r13
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L118
L117:
    cmp     edx,1
    je      L116
    jmp     L311
L118:
    jmp     L125
L119:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L312
    cmp     rbx,r13
    jae     L120
    mov     rbp,r13
    sub     rbp,rbx
    jmp     L121
L120:
    mov     rbp,rbx
    sub     rbp,r13
L121:
    cmp     rdx,rbp
    setbe   dl
    jmp     L126
L122:
    test    r14b,r14b
    jne     L115
    cmp     rbx,0
    je      L313
    jmp     L115
L123:
    test    r8b,r8b
    jne     L122
    jmp     L313
L124:
    test    r14b,r14b
    jne     L119
    cmp     r13,0
    je      L313
    jmp     L119
L125:
    test    r9b,r9b
    jne     L124
    jmp     L313
L126:
    test    dl,dl
    je      L313
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     rdx,[image.k4432]
    lea     r8,[rsp+240h]
    mov     rdi,r8
    mov     rsi,[rsp+20h]
    mov     ecx,1
    mov     r8,rdx
    mov     rdx,[rsp+10h]
    call    fn10
    mov     rdx,[rsp+240h]
    mov     r11,[rsp+248h]
    mov     [rsp+0D0h],r11
    mov     r9,[rsp+250h]
    mov     rbx,[rsp+258h]
    mov     r11,[rsp+0D0h]
    cmp     r11,0
    jbe     L332
    mov     [rsp+258h],rdx
    mov     [rsp+250h],rdx
    mov     r13,[image.sym36]
    mov     rdi,r9
    mov     rsi,rbx
    mov     rcx,r12
    mov     rax,r13
    call    rax
    mov     rbx,rax
    cmp     rbx,[rsp+10h]
    jae     L333
    lea     r11,[image.k4480]
    mov     [rsp+0E0h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L315
    cmp     rbx,[rsp+10h]
    jae     L315
    mov     r11,[rsp+20h]
    lea     r12,[r11+rbx*4]
    lea     r13,[rsp+23Ch]
    lea     r11,[image.k488]
    mov     [rsp+0D8h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L128
L127:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L129
L128:
    cmp     r9d,1
    je      L127
    jmp     L316
L129:
    jmp     L138
L130:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L132
L131:
    mov     r14,r13
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L133
L132:
    cmp     r9d,1
    je      L131
    jmp     L317
L133:
    jmp     L140
L134:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L318
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L135
    mov     rdx,r13
    sub     rdx,[rsp+20h]
    jmp     L136
L135:
    mov     rdx,[rsp+20h]
    sub     rdx,r13
L136:
    cmp     r9,rdx
    setbe   dl
    jmp     L141
L137:
    test    bpl,bpl
    jne     L130
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L319
    jmp     L130
L138:
    test    r8b,r8b
    jne     L137
    jmp     L319
L139:
    test    bpl,bpl
    jne     L134
    cmp     r13,0
    je      L319
    jmp     L134
L140:
    test    r14b,r14b
    jne     L139
    jmp     L319
L141:
    test    dl,dl
    je      L319
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L143
L142:
    lea     r13,[rsp+23Ch]
    jmp     L160
L143:
    lea     r11,[image.k512]
    mov     [rsp+0F0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L145
L144:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L146
L145:
    cmp     edx,1
    je      L144
    jmp     L321
L146:
    jmp     L152
L147:
    test    r14b,r14b
    je      L151
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L149
L148:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L150
L149:
    cmp     edx,1
    je      L148
    jmp     L322
L150:
    jmp     L154
L151:
    cmp     r12,0
    je      L324
    jmp     L155
L152:
    test    r8b,r8b
    jne     L147
    jmp     L324
L153:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L324
    jmp     L159
L154:
    test    r9b,r9b
    jne     L159
    jmp     L324
L155:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L157
L156:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L158
L157:
    cmp     edx,1
    je      L156
    jmp     L323
L158:
    test    r8b,r8b
    jne     L153
    jmp     L324
L159:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L142
L160:
    lea     r11,[image.k536]
    mov     [rsp+0E8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L162
L161:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L163
L162:
    cmp     edx,1
    je      L161
    jmp     L326
L163:
    jmp     L172
L164:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L166
L165:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L167
L166:
    cmp     edx,1
    je      L165
    jmp     L327
L167:
    jmp     L174
L168:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L328
    cmp     r13,r12
    jae     L169
    mov     rbp,r12
    sub     rbp,r13
    jmp     L170
L169:
    mov     rbp,r13
    sub     rbp,r12
L170:
    cmp     rdx,rbp
    setbe   dl
    jmp     L175
L171:
    test    r14b,r14b
    jne     L164
    cmp     r13,0
    je      L329
    jmp     L164
L172:
    test    r8b,r8b
    jne     L171
    jmp     L329
L173:
    test    r14b,r14b
    jne     L168
    cmp     r12,0
    je      L329
    jmp     L168
L174:
    test    r9b,r9b
    jne     L173
    jmp     L329
L175:
    test    dl,dl
    je      L329
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
L176:
    mov     r11,rbx
    add     r11,1
    mov     [rsp+0F8h],r11
    mov     r11,[rsp+10h]
    cmp     r11,[rsp+0F8h]
    jb      L371
    jmp     L279
L177:
    mov     r11,[rsp+10h]
    cmp     r11,0
    jne     L178
    mov     ebx,0
    jmp     L277
L178:
    mov     r11,[rsp+0B8h]
    cmp     r11,[rsp+10h]
    jae     L366
    lea     r11,[image.k4504]
    mov     [rsp+130h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L334
    mov     r11,[rsp+0B8h]
    cmp     r11,[rsp+10h]
    jae     L334
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0B8h]
    lea     r12,[r11+r10*4]
    lea     r13,[rsp+26Ch]
    lea     r11,[image.k488]
    mov     [rsp+100h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L180
L179:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L181
L180:
    cmp     r8d,1
    je      L179
    jmp     L335
L181:
    jmp     L190
L182:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L184
L183:
    mov     rbx,r13
    and     rbx,3
    cmp     rbx,0
    sete    bl
    jmp     L185
L184:
    cmp     r8d,1
    je      L183
    jmp     L336
L185:
    jmp     L192
L186:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L337
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L187
    mov     r14,r13
    sub     r14,[rsp+20h]
    jmp     L188
L187:
    mov     r14,[rsp+20h]
    sub     r14,r13
L188:
    cmp     r8,r14
    setbe   r8b
    jmp     L193
L189:
    test    bpl,bpl
    jne     L182
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L338
    jmp     L182
L190:
    test    r9b,r9b
    jne     L189
    jmp     L338
L191:
    test    bpl,bpl
    jne     L186
    cmp     r13,0
    je      L338
    jmp     L186
L192:
    test    bl,bl
    jne     L191
    jmp     L338
L193:
    test    r8b,r8b
    je      L338
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13d,0
    jmp     L195
L194:
    lea     rbx,[rsp+26Ch]
    jmp     L212
L195:
    lea     r11,[image.k512]
    mov     [rsp+110h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L197
L196:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L198
L197:
    cmp     r8d,1
    je      L196
    jmp     L340
L198:
    jmp     L204
L199:
    test    r13b,r13b
    je      L203
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L201
L200:
    mov     rbp,[rsp+20h]
    and     rbp,3
    cmp     rbp,0
    sete    bpl
    jmp     L202
L201:
    cmp     r8d,1
    je      L200
    jmp     L341
L202:
    jmp     L206
L203:
    cmp     r12,0
    je      L343
    jmp     L207
L204:
    test    r9b,r9b
    jne     L199
    jmp     L343
L205:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L343
    jmp     L211
L206:
    test    bpl,bpl
    jne     L211
    jmp     L343
L207:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L209
L208:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L210
L209:
    cmp     r8d,1
    je      L208
    jmp     L342
L210:
    test    r9b,r9b
    jne     L205
    jmp     L343
L211:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L194
L212:
    lea     r11,[image.k536]
    mov     [rsp+108h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L214
L213:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L215
L214:
    cmp     r8d,1
    je      L213
    jmp     L345
L215:
    jmp     L224
L216:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L218
L217:
    mov     r13,r12
    and     r13,3
    cmp     r13,0
    sete    r13b
    jmp     L219
L218:
    cmp     r8d,1
    je      L217
    jmp     L346
L219:
    jmp     L226
L220:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L347
    cmp     rbx,r12
    jae     L221
    mov     r14,r12
    sub     r14,rbx
    jmp     L222
L221:
    mov     r14,rbx
    sub     r14,r12
L222:
    cmp     r8,r14
    setbe   r8b
    jmp     L227
L223:
    test    bpl,bpl
    jne     L216
    cmp     rbx,0
    je      L348
    jmp     L216
L224:
    test    r9b,r9b
    jne     L223
    jmp     L348
L225:
    test    bpl,bpl
    jne     L220
    cmp     r12,0
    je      L348
    jmp     L220
L226:
    test    r13b,r13b
    jne     L225
    jmp     L348
L227:
    test    r8b,r8b
    je      L348
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r8,[image.k4528]
    lea     r9,[rsp+280h]
    mov     rdi,r9
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     ecx,1
    call    fn10
    mov     r8,[rsp+280h]
    mov     r11,[rsp+288h]
    mov     [rsp+118h],r11
    mov     rbx,[rsp+290h]
    mov     r12,[rsp+298h]
    mov     r11,[rsp+118h]
    cmp     r11,0
    jbe     L367
    mov     [rsp+298h],r8
    mov     [rsp+290h],r8
    mov     r13,[image.sym37]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r8
    mov     rcx,[rsp+18h]
    mov     rax,r13
    call    rax
    mov     rbx,rax
    cmp     rbx,[rsp+10h]
    jae     L368
    lea     r11,[image.k4576]
    mov     [rsp+128h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L350
    cmp     rbx,[rsp+10h]
    jae     L350
    mov     r11,[rsp+20h]
    lea     r12,[r11+rbx*4]
    lea     r13,[rsp+27Ch]
    lea     r11,[image.k488]
    mov     [rsp+120h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L229
L228:
    mov     r14,[rsp+20h]
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L230
L229:
    cmp     r9d,1
    je      L228
    jmp     L351
L230:
    jmp     L239
L231:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L233
L232:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L234
L233:
    cmp     r9d,1
    je      L232
    jmp     L352
L234:
    jmp     L241
L235:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L353
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L236
    mov     rdx,r13
    sub     rdx,[rsp+20h]
    jmp     L237
L236:
    mov     rdx,[rsp+20h]
    sub     rdx,r13
L237:
    cmp     r9,rdx
    setbe   dl
    jmp     L242
L238:
    test    bpl,bpl
    jne     L231
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L354
    jmp     L231
L239:
    test    r14b,r14b
    jne     L238
    jmp     L354
L240:
    test    bpl,bpl
    jne     L235
    cmp     r13,0
    je      L354
    jmp     L235
L241:
    test    r8b,r8b
    jne     L240
    jmp     L354
L242:
    test    dl,dl
    je      L354
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L244
L243:
    lea     r13,[rsp+27Ch]
    jmp     L261
L244:
    lea     r11,[image.k512]
    mov     [rsp+140h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L246
L245:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L247
L246:
    cmp     edx,1
    je      L245
    jmp     L356
L247:
    jmp     L253
L248:
    test    r14b,r14b
    je      L252
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L250
L249:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L251
L250:
    cmp     edx,1
    je      L249
    jmp     L357
L251:
    jmp     L255
L252:
    cmp     r12,0
    je      L359
    jmp     L256
L253:
    test    r8b,r8b
    jne     L248
    jmp     L359
L254:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L359
    jmp     L260
L255:
    test    r9b,r9b
    jne     L260
    jmp     L359
L256:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L258
L257:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L259
L258:
    cmp     edx,1
    je      L257
    jmp     L358
L259:
    test    r8b,r8b
    jne     L254
    jmp     L359
L260:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L243
L261:
    lea     r11,[image.k536]
    mov     [rsp+138h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L263
L262:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L264
L263:
    cmp     edx,1
    je      L262
    jmp     L361
L264:
    jmp     L273
L265:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L267
L266:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L268
L267:
    cmp     edx,1
    je      L266
    jmp     L362
L268:
    jmp     L275
L269:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L363
    cmp     r13,r12
    jae     L270
    mov     rbp,r12
    sub     rbp,r13
    jmp     L271
L270:
    mov     rbp,r13
    sub     rbp,r12
L271:
    cmp     rdx,rbp
    setbe   dl
    jmp     L276
L272:
    test    r14b,r14b
    jne     L265
    cmp     r13,0
    je      L364
    jmp     L265
L273:
    test    r8b,r8b
    jne     L272
    jmp     L364
L274:
    test    r14b,r14b
    jne     L269
    cmp     r12,0
    je      L364
    jmp     L269
L275:
    test    r9b,r9b
    jne     L274
    jmp     L364
L276:
    test    dl,dl
    je      L364
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
L277:
    lea     rdx,[k9]
    lea     r8,[rsp+308h]
    mov     rdi,r8
    mov     rsi,[rsp+20h]
    mov     rcx,rbx
    mov     r8,rdx
    mov     rdx,[rsp+10h]
    call    fn10
    mov     rbx,[rsp+308h]
    mov     r12,[rsp+310h]
    mov     rdx,[rsp+318h]
    mov     r8,[rsp+320h]
    lea     r9,[k11]
    lea     r13,[rsp+2F8h]
    mov     rdi,r13
    mov     rsi,rdx
    mov     rdx,r8
    mov     ecx,1
    mov     r8,r9
    call    fn10
    mov     rdx,[rsp+2F8h]
    mov     [rsp+318h],rdx
    mov     rdx,[rsp+300h]
    mov     [rsp+320h],rdx
    mov     r13,[rsp+308h]
    mov     r14,[rsp+310h]
    cmp     rdx,0
    jbe     L370
    mov     r8,[rsp+318h]
    mov     [rsp+310h],r8
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+0B0h]
    mov     r8,[rsp+18h]
    mov     ecx,ecx
    call    fn15
    mov     r8,[rsp+310h]
    mov     rcx,[rsp+0B0h]
    mov     [rsp+28h],r8
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    jmp     L0
L278:
    mov     rbx,[rsp+2F0h]
    mov     r12,[rsp+2E0h]
    mov     r13,[rsp+2D0h]
    mov     r14,[rsp+2C0h]
    mov     r15,[rsp+2B0h]
    mov     rbp,[rsp+2A0h]
    add     rsp,3C8h
    ret
L279:
    mov     r8,[rsp+10h]
    sub     r8,[rsp+0F8h]
    mov     r10,[rsp+20h]
    mov     [rsp+310h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+318h],r10
    mov     r10,[rsp+20h]
    mov     [rsp+308h],r10
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0F8h]
    lea     r9,[r11+r10*4]
    mov     [rsp+300h],r9
    mov     [rsp+320h],r9
    mov     rcx,[rsp+0B0h]
    mov     qword ptr [rsp+28h],0
    mov     [rsp+20h],r9
    mov     [rsp+10h],r8
    jmp     L0
    jmp     L281
L280:
    lea     r8,[image.k8904]
    mov     rdi,r8
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L281
L281:
    call    qword ptr [image.sym10]
    ud2
    jmp     L283
    jmp     L283
    jmp     L283
L282:
    lea     r8,[image.k8338]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L283:
    call    qword ptr [image.sym10]
    ud2
L284:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
    jmp     L286
    jmp     L286
    jmp     L286
L285:
    lea     r8,[image.k8338]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L286:
    call    qword ptr [image.sym10]
    ud2
L287:
    lea     r8,[rsp+170h]
    mov     rdi,r8
    call    image.fn33
    jmp     L288
    jmp     L289
L288:
    mov     [rsp],rbx
    lea     rdi,[rsp+3C0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L287
L289:
    call    qword ptr [image.sym11]
    ud2
L290:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L291:
    lea     r8,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,r8
    mov     esi,55h
    mov     rdx,r9
    call    qword ptr [image.sym6]
    ud2
    jmp     L293
L292:
    lea     r8,[image.k9686]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L293:
    call    qword ptr [image.sym10]
    ud2
L294:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L295:
    lea     r8,[image.k7567]
    mov     rdi,r8
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L296:
    lea     rsi,[image.k7567]
    mov     rdi,rsi
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L297:
    lea     rcx,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     r10,rdi
    mov     rdi,rcx
    mov     rcx,r10
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L298:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L299:
    lea     rcx,[image.k7128]
    mov     rdi,rcx
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L300:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L301:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L302:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L304
    jmp     L304
L303:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L304:
    call    qword ptr [image.sym10]
    ud2
L305:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L306:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L307:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L309
L308:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L309
L309:
    call    qword ptr [image.sym10]
    ud2
L310:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L311:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L312:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L314
    jmp     L314
L313:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L314:
    call    qword ptr [image.sym10]
    ud2
L315:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L316:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L317:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L318:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L320
    jmp     L320
L319:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L320:
    call    qword ptr [image.sym10]
    ud2
L321:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L322:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L323:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L325
L324:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L325
L325:
    call    qword ptr [image.sym10]
    ud2
L326:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L327:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L328:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L330
    jmp     L330
L329:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L330:
    call    qword ptr [image.sym10]
    ud2
L331:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L332:
    lea     rax,[image.k4456]
    mov     edi,0
    mov     rsi,[rsp+0D0h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L333:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L334:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+130h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L335:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L336:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L337:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L339
    jmp     L339
L338:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L339:
    call    qword ptr [image.sym10]
    ud2
L340:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L341:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L342:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L344
L343:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+110h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L344
L344:
    call    qword ptr [image.sym10]
    ud2
L345:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L346:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L347:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L349
    jmp     L349
L348:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+108h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L349:
    call    qword ptr [image.sym10]
    ud2
L350:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+128h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L351:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L352:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L353:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L355
    jmp     L355
L354:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+120h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L355:
    call    qword ptr [image.sym10]
    ud2
L356:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L357:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L358:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L360
L359:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+140h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L360
L360:
    call    qword ptr [image.sym10]
    ud2
L361:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L362:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L363:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L365
    jmp     L365
L364:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+138h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L365:
    call    qword ptr [image.sym10]
    ud2
L366:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L367:
    lea     rax,[image.k4552]
    mov     edi,0
    mov     rsi,[rsp+118h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L368:
    lea     rdi,[rsp+3C0h]
    call    ryo_h_Abort
    ud2
L369:
    lea     rax,[k4]
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L370:
    lea     rax,[k13]
    mov     edi,0
    mov     rsi,rdx
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L371:
    lea     rax,[k16]
    mov     rdi,[rsp+0F8h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    call    qword ptr [sym17]
    ud2
L372:
    ud2
  ; OSR entries
    lea     r11,[L373]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L373:
    .long   L374
L374:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-3F0h]
    mov     r11,[rdx-28h]
    mov     [rsp],r11
    mov     r11d,[rdx-1Ch]
    mov     [rsp+8],r11
    mov     r11,[rdx-18h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-8]
    mov     [rsp+20h],r11
    mov     [rdx-0D0h],rbx
    mov     [rdx-0E0h],r12
    mov     [rdx-0F0h],r13
    mov     [rdx-100h],r14
    mov     [rdx-110h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp]
    mov     [rdx-3A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-398h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-3A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-3B0h],r11
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L0

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

fn main::{closure#2}
    sub     rsp,18h
    mov     eax,[rsi]
    mov     eax,eax
    add     rsp,18h
    ret

fn merge_sort
    sub     rsp,238h
    mov     [rsp+1A0h],rbx
    mov     [rsp+190h],r12
    mov     [rsp+180h],r13
    mov     [rsp+170h],r14
    mov     [rsp+160h],r15
    mov     [rsp+150h],rbp
    mov     rbx,rdi
    mov     [rsp+30h],rsi
    mov     [rsp+40h],rdx
    mov     r11,[rsp+30h]
    cmp     r11,10h
    ja      L59
    mov     eax,1
    mov     rcx,[rsp+30h]
    mov     [rsp+1B0h],rax
    mov     [rsp+1B8h],rcx
    mov     r14,rbx
    mov     r15,[rsp+30h]
L0:
    mov     rax,[rsp+1B0h]
    mov     rcx,[rsp+1B8h]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L1
    mov     rax,[rsp+1B0h]
    lea     rcx,[image.k10584]
    mov     r11,rax
    add     r11,1
    jb      L171
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+1B0h],rdx
    mov     rbp,rax
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
L3:
    .long   L170
    .long   L4
    .long   L222
L4:
    mov     [rsp+28h],rbp
    mov     [rsp+20h],r15
L5:
    mov     r11,[rsp+28h]
    cmp     r11,0
    ja      L7
    jmp     L6
L6:
    mov     r15,[rsp+20h]
    jmp     L0
L7:
    mov     r11,[rsp+28h]
    sub     r11,1
    mov     [rsp+48h],r11
    jb      L223
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+20h]
    jae     L224
    mov     r10,[rsp+48h]
    lea     rdx,[r14+r10*4]
    mov     edx,[rdx]
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L225
    mov     r10,[rsp+28h]
    lea     rsi,[r14+r10*4]
    mov     esi,[rsi]
    cmp     esi,edx
    jb      L9
    jmp     L8
L8:
    mov     r15,[rsp+20h]
    jmp     L0
L9:
    mov     rdx,[rsp+28h]
    sub     rdx,1
    jb      L226
    lea     rsi,[k10]
    cmp     rdx,[rsp+20h]
    jae     L188
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L189
    cmp     rdx,[rsp+20h]
    jae     L172
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L172
    lea     r15,[r14+rdx*4]
    mov     r10,[rsp+28h]
    lea     rbp,[r14+r10*4]
    lea     r12,[rsp+10Ch]
    lea     r11,[image.k488]
    mov     [rsp+38h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L11
L10:
    mov     r8,r15
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L12
L11:
    cmp     edi,1
    je      L10
    jmp     L173
L12:
    jmp     L21
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L15
L14:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L16
L15:
    cmp     edi,1
    je      L14
    jmp     L174
L16:
    jmp     L23
L17:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L175
    cmp     r15,r12
    jae     L18
    mov     rax,r12
    sub     rax,r15
    jmp     L19
L18:
    mov     rax,r15
    sub     rax,r12
L19:
    cmp     rdi,rax
    setbe   al
    jmp     L24
L20:
    test    r13b,r13b
    jne     L13
    cmp     r15,0
    je      L176
    jmp     L13
L21:
    test    r8b,r8b
    jne     L20
    jmp     L176
L22:
    test    r13b,r13b
    jne     L17
    cmp     r12,0
    je      L176
    jmp     L17
L23:
    test    r9b,r9b
    jne     L22
    jmp     L176
L24:
    test    al,al
    je      L176
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13d,0
    jmp     L26
L25:
    lea     r12,[rsp+10Ch]
    jmp     L43
L26:
    lea     r11,[image.k512]
    mov     [rsp+50h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L28
L27:
    mov     rdi,rbp
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L29
L28:
    cmp     eax,1
    je      L27
    jmp     L178
L29:
    jmp     L35
L30:
    test    r13b,r13b
    je      L34
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     r8,r15
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L179
L33:
    jmp     L37
L34:
    cmp     rbp,0
    je      L181
    jmp     L38
L35:
    test    dil,dil
    jne     L30
    jmp     L181
L36:
    cmp     r15,0
    je      L181
    jmp     L42
L37:
    test    r8b,r8b
    jne     L42
    jmp     L181
L38:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L40
L39:
    mov     rdi,r15
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L41
L40:
    cmp     eax,1
    je      L39
    jmp     L180
L41:
    test    dil,dil
    jne     L36
    jmp     L181
L42:
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L25
L43:
    lea     r11,[image.k536]
    mov     [rsp+0A0h],r11
    mov     r15d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L45
L44:
    mov     rdi,r12
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L46
L45:
    cmp     eax,1
    je      L44
    jmp     L183
L46:
    jmp     L55
L47:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L49
L48:
    mov     r8,rbp
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L50
L49:
    cmp     eax,1
    je      L48
    jmp     L184
L50:
    jmp     L57
L51:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L185
    cmp     r12,rbp
    jae     L52
    mov     r9,rbp
    sub     r9,r12
    jmp     L53
L52:
    mov     r9,r12
    sub     r9,rbp
L53:
    cmp     rax,r9
    setbe   al
    jmp     L58
L54:
    test    r15b,r15b
    jne     L47
    cmp     r12,0
    je      L186
    jmp     L47
L55:
    test    dil,dil
    jne     L54
    jmp     L186
L56:
    test    r15b,r15b
    jne     L51
    cmp     rbp,0
    je      L186
    jmp     L51
L57:
    test    r8b,r8b
    jne     L56
    jmp     L186
L58:
    test    al,al
    je      L186
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rax,[rsp+28h]
    sub     rax,1
    jb      L227
    mov     [rsp+28h],rax
    jmp     L5
L59:
    mov     rdi,[rsp+30h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+78h],rax
    lea     r11,[k16]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+78h]
    cmp     r11,0
    jb      L190
    jmp     L61
L60:
    mov     rdi,rbx
    mov     r8,[rsp+78h]
    jmp     L62
L61:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+78h]
    jb      L190
    jmp     L60
L62:
    mov     rsi,r8
    mov     rdx,[rsp+40h]
    call    fn18
    lea     r11,[k19]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+78h]
    jb      L191
    mov     r8,[rsp+30h]
    sub     r8,[rsp+78h]
    mov     r10,[rsp+78h]
    lea     r9,[rbx+r10*4]
    mov     rdi,r9
    mov     rsi,r8
    mov     rdx,[rsp+40h]
    call    fn18
    mov     r11,[rsp+40h]
    mov     r8,[r11+8]
    mov     r11,[rsp+40h]
    mov     r9,[r11+10h]
    mov     r11,[rsp+40h]
    mov     qword ptr [r11+10h],0
    mov     rdi,r8
    mov     rsi,r9
    call    qword ptr [image.sym48]
    mov     qword ptr [rsp+68h],0
    mov     r11,[rsp+78h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+60h],r11
    mov     rbp,rbx
    mov     r11,[rsp+30h]
    mov     [rsp+58h],r11
    mov     r15,[rsp+40h]
L63:
    mov     r11,[rsp+68h]
    cmp     r11,[rsp+70h]
    jae     L77
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L77
    mov     r11,[rsp+68h]
    cmp     r11,[rsp+58h]
    jae     L228
    mov     r10,[rsp+68h]
    lea     r8,[rbp+r10*4]
    mov     r8d,[r8]
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L229
    mov     r10,[rsp+60h]
    lea     r9,[rbp+r10*4]
    mov     r9d,[r9]
    cmp     r9d,r8d
    jb      L70
    mov     r11,[rsp+68h]
    cmp     r11,[rsp+58h]
    jae     L230
    mov     r10,[rsp+68h]
    lea     r8,[rbp+r10*4]
    mov     ebx,[r8]
    mov     r14,[r15+10h]
    jmp     L68
L64:
    mov     r12,[r15]
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFEF0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+120h]
    mov     r9,[rsp+128h]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,1
    mov     rcx,r8
    mov     r8,r9
    call    qword ptr [image.sym43]
    mov     r8,rax
    mov     r9,rdx
    mov     [rsp+110h],r8
    mov     [rsp+118h],r9
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFDE0h
    mov     edx,0FFFFFEE0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     r8d,[rsp+10h]
    mov     r8d,r8d
    mov     rdi,r8
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r8,rax
    mov     r10,r8
    lea     r11,[L65]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L65:
    .long   L66
    .long   L192
    .long   L193
L66:
    mov     r8,[r15+8]
    lea     r8,[r8+r14*4]
    mov     [r8],ebx
    mov     r9,r14
    add     r9,1
    mov     [r15+10h],r9
    jmp     L69
L67:
    cmp     r14,r8
    je      L64
    jmp     L66
L68:
    mov     r8,[r15]
    jmp     L67
L69:
    mov     [rsp+8],r8
    mov     r8,[rsp+68h]
    add     r8,1
    jb      L231
    mov     [rsp+68h],r8
    jmp     L63
L70:
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L232
    mov     r10,[rsp+60h]
    lea     r8,[rbp+r10*4]
    mov     ebx,[r8]
    mov     r12,[r15+10h]
    jmp     L75
L71:
    mov     r14,[r15]
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFF10h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+140h]
    mov     r9,[rsp+148h]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,1
    mov     rcx,r8
    mov     r8,r9
    call    qword ptr [image.sym43]
    mov     r8,rax
    mov     r9,rdx
    mov     [rsp+130h],r8
    mov     [rsp+138h],r9
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFDE0h
    mov     edx,0FFFFFF00h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     r8d,[rsp+10h]
    mov     r8d,r8d
    mov     rdi,r8
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r8,rax
    mov     r10,r8
    lea     r11,[L72]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L72:
    .long   L73
    .long   L194
    .long   L195
L73:
    mov     r8,[r15+8]
    lea     r8,[r8+r12*4]
    mov     [r8],ebx
    mov     r9,r12
    add     r9,1
    mov     [r15+10h],r9
    jmp     L76
L74:
    cmp     r12,r8
    je      L71
    jmp     L73
L75:
    mov     r8,[r15]
    jmp     L74
L76:
    mov     [rsp+8],r8
    mov     r8,[rsp+60h]
    add     r8,1
    jb      L233
    mov     [rsp+60h],r8
    jmp     L63
L77:
    lea     r11,[k37]
    mov     [rsp+90h],r11
    mov     r11,[rsp+70h]
    cmp     r11,[rsp+68h]
    jb      L196
    jmp     L79
L78:
    mov     r10,[rsp+68h]
    lea     rbx,[rbp+r10*4]
    jmp     L80
L79:
    mov     r9,[rsp+70h]
    sub     r9,[rsp+68h]
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+70h]
    jb      L196
    jmp     L78
L80:
    lea     r9,[rbx+r9*4]
    jmp     L82
L81:
    jmp     L83
L82:
    lea     r11,[image.k6656]
    mov     [rsp+88h],r11
    cmp     r9,rbx
    jb      L197
    sub     r9,rbx
    mov     rdi,r9
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r9,rax
    mov     r12,r9
    jmp     L81
L83:
    lea     r11,[image.k6704]
    mov     [rsp+80h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L85
L84:
    mov     r14,rbx
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L86
L85:
    cmp     r9d,1
    je      L84
    jmp     L198
L86:
    jmp     L89
L87:
    jmp     L91
L88:
    cmp     rbx,0
    je      L199
    jmp     L90
L89:
    test    r14b,r14b
    jne     L88
    jmp     L199
L90:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r9,rax
    cmp     r12,r9
    jbe     L87
    jmp     L199
L91:
    mov     r14,[r15+10h]
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r9,[rsp+0F8h]
    cmp     r9,0
    je      L94
    jmp     L95
L92:
    mov     r9,[rsp+0F0h]
    mov     r8,[rsp+0F8h]
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r12
    mov     rcx,r9
    call    qword ptr [image.sym47]
    jmp     L96
L93:
    sub     r8,r14
    cmp     r8,r12
    jb      L92
    jmp     L96
L94:
    mov     r8,0FFFFFFFFFFFFFFFFh
    jmp     L93
L95:
    mov     r8,[r15]
    jmp     L93
L96:
    mov     r8,[r15+10h]
    cmp     r12,0
    jbe     L97
    mov     r9,[r15+8]
    lea     r14,[r9+r8*4]
    jmp     L98
L97:
    mov     r8,[r15+10h]
    add     r8,r12
    mov     [r15+10h],r8
    jmp     L116
L98:
    lea     r11,[image.k7104]
    mov     [rsp+98h],r11
    cmp     r12,0
    jne     L99
    mov     r13d,1
    jmp     L100
L99:
    mov     r13d,0
L100:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L102
L101:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L103
L102:
    cmp     r8d,1
    je      L101
    jmp     L201
L103:
    jmp     L112
L104:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L106
L105:
    mov     rdi,r14
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L107
L106:
    cmp     r8d,1
    je      L105
    jmp     L202
L107:
    jmp     L114
L108:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r12
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L203
    cmp     rbx,r14
    jae     L109
    mov     rax,r14
    sub     rax,rbx
    jmp     L110
L109:
    mov     rax,rbx
    sub     rax,r14
L110:
    cmp     r8,rax
    setbe   al
    jmp     L115
L111:
    test    r13b,r13b
    jne     L104
    cmp     rbx,0
    je      L204
    jmp     L104
L112:
    test    r9b,r9b
    jne     L111
    jmp     L204
L113:
    test    r13b,r13b
    jne     L108
    cmp     r14,0
    je      L204
    jmp     L108
L114:
    test    dil,dil
    jne     L113
    jmp     L204
L115:
    test    al,al
    je      L204
    mov     rax,r12
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L97
L116:
    lea     r11,[k40]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+60h]
    jb      L206
    mov     rdi,[rsp+58h]
    sub     rdi,[rsp+60h]
    mov     r10,[rsp+60h]
    lea     r8,[rbp+r10*4]
    mov     rbx,r8
    lea     rdi,[rbx+rdi*4]
    jmp     L118
L117:
    jmp     L119
L118:
    lea     r11,[image.k6656]
    mov     [rsp+0C8h],r11
    cmp     rdi,rbx
    jb      L207
    sub     rdi,rbx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    mov     r12,rdi
    jmp     L117
L119:
    lea     r11,[image.k6704]
    mov     [rsp+0C0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L121
L120:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L122
L121:
    cmp     edi,1
    je      L120
    jmp     L208
L122:
    jmp     L125
L123:
    jmp     L127
L124:
    cmp     rbx,0
    je      L209
    jmp     L126
L125:
    test    r9b,r9b
    jne     L124
    jmp     L209
L126:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    cmp     r12,rdi
    jbe     L123
    jmp     L209
L127:
    mov     r14,[r15+10h]
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFEB0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+0E8h]
    cmp     rdi,0
    je      L130
    jmp     L131
L128:
    mov     rdi,[rsp+0E0h]
    mov     r9,[rsp+0E8h]
    mov     rsi,r14
    mov     rdx,r12
    mov     rcx,rdi
    mov     rdi,r15
    mov     r8,r9
    call    qword ptr [image.sym47]
    jmp     L132
L129:
    sub     rdi,r14
    cmp     rdi,r12
    jb      L128
    jmp     L132
L130:
    mov     rdi,0FFFFFFFFFFFFFFFFh
    jmp     L129
L131:
    mov     rdi,[r15]
    jmp     L129
L132:
    mov     rdi,[r15+10h]
    cmp     r12,0
    jbe     L133
    mov     r9,[r15+8]
    lea     r14,[r9+rdi*4]
    jmp     L134
L133:
    mov     rdi,[r15+10h]
    add     rdi,r12
    mov     [r15+10h],rdi
    jmp     L152
L134:
    lea     r11,[image.k7104]
    mov     [rsp+0B8h],r11
    cmp     r12,0
    jne     L135
    mov     r13d,1
    jmp     L136
L135:
    mov     r13d,0
L136:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L138
L137:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L139
L138:
    cmp     edi,1
    je      L137
    jmp     L211
L139:
    jmp     L148
L140:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L142
L141:
    mov     r8,r14
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L143
L142:
    cmp     edi,1
    je      L141
    jmp     L212
L143:
    jmp     L150
L144:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r12
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L213
    cmp     rbx,r14
    jae     L145
    mov     rax,r14
    sub     rax,rbx
    jmp     L146
L145:
    mov     rax,rbx
    sub     rax,r14
L146:
    cmp     rdi,rax
    setbe   al
    jmp     L151
L147:
    test    r13b,r13b
    jne     L140
    cmp     rbx,0
    je      L214
    jmp     L140
L148:
    test    r9b,r9b
    jne     L147
    jmp     L214
L149:
    test    r13b,r13b
    jne     L144
    cmp     r14,0
    je      L214
    jmp     L144
L150:
    test    r8b,r8b
    jne     L149
    jmp     L214
L151:
    test    al,al
    je      L214
    mov     rax,r12
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L133
L152:
    mov     rax,[r15+8]
    mov     rdi,[r15+10h]
    mov     rbx,rax
    lea     rax,[k44]
    mov     r11,[rsp+58h]
    cmp     r11,rdi
    jne     L221
    lea     r12,[image.k560]
    mov     r11,[rsp+58h]
    cmp     r11,0
    jne     L153
    mov     r13d,1
    jmp     L154
L153:
    mov     r13d,0
L154:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L156
L155:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L157
L156:
    cmp     r8d,1
    je      L155
    jmp     L216
L157:
    jmp     L166
L158:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L160
L159:
    mov     r14,rbp
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L161
L160:
    cmp     r8d,1
    je      L159
    jmp     L217
L161:
    jmp     L168
L162:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     qword ptr [rsp+58h]
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L218
    cmp     rbx,rbp
    jae     L163
    mov     r15,rbp
    sub     r15,rbx
    jmp     L164
L163:
    mov     r15,rbx
    sub     r15,rbp
L164:
    cmp     r8,r15
    setbe   r8b
    jmp     L169
L165:
    test    r13b,r13b
    jne     L158
    cmp     rbx,0
    je      L219
    jmp     L158
L166:
    test    r9b,r9b
    jne     L165
    jmp     L219
L167:
    test    r13b,r13b
    jne     L162
    cmp     rbp,0
    je      L219
    jmp     L162
L168:
    test    r14b,r14b
    jne     L167
    jmp     L219
L169:
    test    r8b,r8b
    je      L219
    mov     r8,[rsp+58h]
    imul    r8,4
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r8
    call    ryo_hr_Memcpy
L170:
    mov     rbx,[rsp+1A0h]
    mov     r12,[rsp+190h]
    mov     r13,[rsp+180h]
    mov     r14,[rsp+170h]
    mov     r15,[rsp+160h]
    mov     rbp,[rsp+150h]
    add     rsp,238h
    ret
L171:
    lea     r8,[image.k7768]
    mov     rdi,r8
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L172:
    lea     rcx,[image.k7128]
    mov     rdi,rcx
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1B5h
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L173:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L174:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L175:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L177
    jmp     L177
L176:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L177:
    call    qword ptr [image.sym10]
    ud2
L178:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L179:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L180:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
    jmp     L182
L181:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
    jmp     L182
L182:
    call    qword ptr [image.sym10]
    ud2
L183:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L184:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    qword ptr [image.sym6]
    ud2
L185:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L187
    jmp     L187
L186:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L187:
    call    qword ptr [image.sym10]
    ud2
L188:
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,[rsp+20h]
    call    qword ptr [sym5]
    ud2
L189:
    mov     rdi,[rsp+28h]
    mov     rdx,rsi
    mov     rsi,[rsp+20h]
    call    qword ptr [sym5]
    ud2
L190:
    mov     edi,0
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+0B0h]
    call    qword ptr [image.sym31]
    ud2
L191:
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+0A8h]
    call    qword ptr [image.sym31]
    ud2
L192:
    mov     rcx,[rsp+110h]
    mov     rdx,[rsp+118h]
    mov     rdi,rcx
    mov     rsi,rdx
    call    qword ptr [image.sym44]
    ud2
L193:
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFDE0h
    call    ryo_h_Resume
    ud2
L194:
    mov     rcx,[rsp+130h]
    mov     rdx,[rsp+138h]
    mov     rdi,rcx
    mov     rsi,rdx
    call    qword ptr [image.sym44]
    ud2
L195:
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFDE0h
    call    ryo_h_Resume
    ud2
L196:
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+90h]
    call    qword ptr [image.sym31]
    ud2
L197:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L198:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
    jmp     L200
L199:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L200:
    call    qword ptr [image.sym10]
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L205
    jmp     L205
L204:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L205:
    call    qword ptr [image.sym10]
    ud2
L206:
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+0D0h]
    call    qword ptr [image.sym31]
    ud2
L207:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L208:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
    jmp     L210
L209:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L210:
    call    qword ptr [image.sym10]
    ud2
L211:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L212:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L213:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L215
    jmp     L215
L214:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L215:
    call    qword ptr [image.sym10]
    ud2
L216:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L217:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    qword ptr [image.sym6]
    ud2
L218:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L220
    jmp     L220
L219:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L220:
    call    qword ptr [image.sym10]
    ud2
L221:
    mov     rsi,rdi
    mov     rdi,[rsp+58h]
    mov     rdx,rax
    call    qword ptr [image.sym24]
    ud2
L222:
    ud2
L223:
    lea     rax,[k2]
    mov     rdi,rax
    call    qword ptr [sym3]
    ud2
L224:
    lea     rax,[k4]
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L225:
    lea     rax,[k6]
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L226:
    lea     rax,[k8]
    mov     rdi,rax
    call    qword ptr [sym3]
    ud2
L227:
    lea     rax,[k12]
    mov     rdi,rax
    call    qword ptr [sym3]
    ud2
L228:
    lea     rax,[k23]
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L229:
    lea     rax,[k25]
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L230:
    lea     rax,[k27]
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L231:
    lea     rax,[k30]
    mov     rdi,rax
    call    qword ptr [sym31]
    ud2
L232:
    lea     rax,[k32]
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L233:
    lea     rax,[k35]
    mov     rdi,rax
    call    qword ptr [sym31]
    ud2
  ; OSR entries
    lea     r11,[L234]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L234:
    .long   L235
    .long   L236
    .long   L237
L235:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-380h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r14,[rsp]
    mov     r15,[rsp+8]
    lea     rsp,[rsp+150h]
    jmp     L0
L236:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-390h]
    mov     r11,[rdx-0B0h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp]
    mov     [rdx-208h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-210h],r11
    mov     r14,[rsp+8]
    lea     rsp,[rsp+160h]
    jmp     L5
L237:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-3A0h]
    mov     r11,[rdx-1C8h]
    mov     [rsp],r11
    mov     r11,[rdx-170h]
    mov     [rsp+8],r11
    mov     r11,[rdx-1D0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-8]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1D8h],r11
    mov     rbp,[rsp+18h]
    mov     r15,[rsp+28h]
    lea     rsp,[rsp+170h]
    jmp     L63

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    sub     rsp,18h
    mov     eax,[rdi]
    mov     ecx,[rsi]
    cmp     eax,ecx
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

fn std::hint::assert_unchecked::precondition_check
    sub     rsp,18h
    test    dil,dil
    je      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn std::hint::select_unpredictable::<*mut u32>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     rbx,rdi
    mov     [rsp+40h],rsi
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rdx
    lea     r12,[rsp+38h]
    lea     r13,[rsp+40h]
    mov     [rsp+48h],r13
    mov     [rsp+8],bl
    mov     [rsp],r12
    mov     [rsp+10h],r13
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     [rsp+8],bl
    mov     [rsp],r13
    mov     [rsp+10h],r12
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym0]
    mov     r12,[rsp+48h]
    mov     rax,[rsp+28h]
    mov     [rsp+58h],rax
    mov     rdi,rax
    call    qword ptr [sym2]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L2
L1:
    mov     [rsp+58h],r12
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+40]
    call    qword ptr [sym5]
    jmp     L0
L2:
    mov     rax,[rsp+58h]
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    add     rsp,98h
    ret
    mov     rbx,rax
    jmp     L4
L3:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L4:
    mov     rdi,r12
    call    qword ptr [sym2]
    jmp     L3
    call    qword ptr [sym6]
    ud2
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
L6:
    ret
L7:
    ret
L8:
    ret
L9:
    ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     rbx,rdi
    mov     r12d,[rsi]
    mov     rdi,r12
    mov     esi,3E8h
    call    ryo_hr_RemUW32
    mov     [rsp+48h],eax
    mov     [rsp+4Ch],r12d
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     ecx,[rsp+44h]
    mov     [rsp+20h],eax
    mov     [rsp+24h],ecx
    mov     rax,[rsp+20h]
    mov     [rsp+30h],rax
    mov     ecx,[rsp+34h]
    mov     [rsp+10h],eax
    mov     [rsp+14h],ecx
    mov     rax,[rbx+10h]
    mov     rcx,[rbx+8]
    lea     rax,[rax+rcx*8]
    mov     rcx,[rsp+10h]
    mov     [rax],rcx
    mov     rax,[rbx+8]
    add     rax,1
    mov     [rbx+8],rax
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    add     rsp,78h
    ret
  ; OSR entries
    lea     r11,[L0]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L0:
    .long   L1
    .long   L2
    .long   L3
L1:
    ret
L2:
    ret
L3:
    ret

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi+18h]
    mov     rcx,[rax]
    shl     rcx,0Dh
    mov     rdx,[rax]
    xor     rdx,rcx
    mov     [rax],rdx
    shr     rdx,7
    mov     rcx,[rax]
    xor     rcx,rdx
    mov     [rax],rcx
    shl     rcx,11h
    mov     rdx,[rax]
    xor     rdx,rcx
    mov     [rax],rdx
    mov     rax,[rdi+10h]
    mov     rcx,[rdi+8]
    lea     rax,[rax+rcx*4]
    mov     [rax],edx
    mov     rax,[rdi+8]
    add     rax,1
    mov     [rdi+8],rax
    add     rsp,18h
    ret
  ; OSR entries
    lea     r11,[L0]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L0:
    .long   L1
    .long   L2
    .long   L3
L1:
    ret
L2:
    ret
L3:
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L0
    mov     rax,[rdi]
    lea     rcx,[image.k10584]
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
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2

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

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    sub     rsp,18h
    cmp     rdi,rsi
    jb      L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn std::ptr::copy::precondition_check
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,r13
    sub     rcx,1
    and     rcx,rbx
    cmp     rcx,0
    sete    cl
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L17
L2:
    jmp     L9
L3:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L4:
    test    r14b,r14b
    je      L8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    jmp     L6
L5:
    mov     rdx,r13
    sub     rdx,1
    and     rdx,r12
    cmp     rdx,0
    sete    dl
    jmp     L7
L6:
    cmp     eax,1
    je      L5
    jmp     L18
L7:
    jmp     L12
L8:
    cmp     rbx,0
    je      L20
    jmp     L13
L9:
    test    cl,cl
    jne     L4
    jmp     L21
L10:
    jmp     L3
L11:
    cmp     r12,0
    je      L20
    jmp     L3
L12:
    test    dl,dl
    jne     L10
    jmp     L22
L13:
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    jmp     L15
L14:
    mov     rcx,r13
    sub     rcx,1
    and     rcx,r12
    cmp     rcx,0
    sete    cl
    jmp     L16
L15:
    cmp     eax,1
    je      L14
    jmp     L19
L16:
    test    cl,cl
    jne     L11
    jmp     L22
L17:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L19:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L23
L20:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [sym3]
    ud2
L21:
    jmp     L20
    jmp     L23
L22:
    jmp     L20
L23:
    call    qword ptr [sym6]
    ud2
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
L33:
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
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L19:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L20:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
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

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,[rdi]
    mov     r12,[rdi+8]
    mov     r13,[rdi+10h]
    lea     r14,[image.k10520]
    cmp     r13,0
    jne     L0
    mov     r15d,1
    jmp     L1
L0:
    mov     r15d,0
L1:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L4
L3:
    cmp     eax,1
    je      L2
    jmp     L17
L4:
    jmp     L13
L5:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L8
L7:
    cmp     eax,1
    je      L6
    jmp     L18
L8:
    jmp     L15
L9:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r13
    mov     rdx,r10
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
    cmp     rax,rsi
    setbe   al
    jmp     L16
L12:
    test    r15b,r15b
    jne     L5
    cmp     rbx,0
    je      L20
    jmp     L5
L13:
    test    cl,cl
    jne     L12
    jmp     L20
L14:
    test    r15b,r15b
    jne     L9
    cmp     r12,0
    je      L20
    jmp     L9
L15:
    test    dl,dl
    jne     L14
    jmp     L20
L16:
    test    al,al
    je      L20
    imul    r13,4
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
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
L19:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [image.sym50]
    ud2
    jmp     L21
    jmp     L21
L20:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [image.sym49]
    ud2
L21:
    call    qword ptr [image.sym10]
    ud2

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    sub     rsp,18h
    mov     r11,[rdi]
    mov     eax,[rsi]
    mov     r11,[rdi]
    mov     ecx,[rdx]
    cmp     eax,ecx
    setb    al
    movzx   eax,al
    add     rsp,18h
    ret
  ; OSR entries
    lea     r11,[L0]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L0:
    .long   L1
L1:
    ret

fn std::slice::from_raw_parts_mut::precondition_check
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    jmp     L1
L0:
    mov     rcx,r13
    sub     rcx,1
    and     rcx,rbx
    cmp     rcx,0
    sete    cl
    jmp     L2
L1:
    cmp     eax,1
    je      L0
    jmp     L10
L2:
    jmp     L6
L3:
    cmp     r12,0
    je      L7
    jmp     L8
L4:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L5:
    cmp     rbx,0
    je      L11
    jmp     L3
L6:
    test    cl,cl
    jne     L5
    jmp     L12
L7:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L9
L8:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
L9:
    cmp     r14,rax
    jbe     L4
    jmp     L11
L10:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    qword ptr [image.sym6]
    ud2
    jmp     L13
L11:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [sym3]
    ud2
L12:
    jmp     L11
L13:
    call    qword ptr [sym4]
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

fn std::vec::Vec::<u32>::push
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    jmp     L4
L0:
    mov     r14,[rbx]
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,1
    mov     r8,rcx
    mov     rcx,rax
    call    qword ptr [image.sym43]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFA0h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    mov     r8d,0
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    mov     eax,[rsp+10h]
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
    .long   L2
    .long   L6
    .long   L7
L2:
    mov     rax,[rbx+8]
    lea     rax,[rax+r13*4]
    mov     [rax],r12d
    mov     rcx,r13
    add     rcx,1
    mov     [rbx+10h],rcx
    jmp     L5
L3:
    cmp     r13,rax
    je      L0
    jmp     L2
L4:
    mov     rax,[rbx]
    jmp     L3
L5:
    mov     [rsp+8],rax
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    add     rsp,88h
    ret
L6:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [image.sym44]
    ud2
L7:
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2

