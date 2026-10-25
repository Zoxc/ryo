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
    call    image.sym6
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L19:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L21:
    call    image.sym10
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
    call    sym2
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
    call    image.sym49
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
    call    sym4
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
    call    image.sym49
    ud2
L8:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
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
    call    sym11
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
    call    image.sym49
    ud2
L8:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
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
    call    sym2
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
    call    sym2
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
    call    sym4
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
    call    image.sym49
    ud2
L13:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L15
L14:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    call    image.sym10
    ud2
L16:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L18
L17:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L18:
    call    image.sym10
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
    call    sym2
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
    call    sym4
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
    call    image.sym49
    ud2
L13:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L15
L14:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    call    image.sym10
    ud2
L16:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L18
L17:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L18:
    call    image.sym10
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
    call    image.sym49
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L51:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L52:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L54:
    call    image.sym10
    ud2
L55:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L56:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L57:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
    jmp     L59
L58:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L59
L59:
    call    image.sym10
    ud2
L60:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L61:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L62:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L64:
    call    image.sym10
    ud2
L65:
    mov     rdi,rdx
    mov     rdx,[rsp+10h]
    call    sym0
    ud2
L66:
    mov     rdi,rcx
    mov     rdx,[rsp+10h]
    call    sym0
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
    call    image.sym49
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L51:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L52:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L54:
    call    image.sym10
    ud2
L55:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L56:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L57:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L59
L58:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L59
L59:
    call    image.sym10
    ud2
L60:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L61:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L62:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L64:
    call    image.sym10
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
    call    image.sym49
    ud2
L17:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L18:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
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
    call    image.sym49
    ud2
L28:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L29:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L30:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L32:
    call    image.sym10
    ud2
L33:
    call    sym1
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

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0F8h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    jmp     L25
L0:
    movzx   ecx,byte ptr [rsp+0AFh]
    test    cl,cl
    je      L23
    mov     [rsp+40h],rsi
    mov     ecx,[rsi]
    mov     [rsp+44h],ecx
    mov     [rsp+0ACh],ecx
    lea     rcx,[rsp+0ACh]
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rsi
    mov     qword ptr [rsp+40h],1
    mov     rbx,rax
    mov     [rsp+18h],rdi
L1:
    mov     r13,[rsp+38h]
    jmp     L26
L2:
    jmp     L5
L3:
    jmp     L43
L4:
    test    r8b,r8b
    je      L5
    mov     rbx,r9
    mov     [rsp+18h],r14
    jmp     L1
L5:
    mov     r14,[rsp+30h]
    mov     r15,[rsp+38h]
    mov     rbp,[rsp+40h]
    lea     r11,[image.k10520]
    mov     [rsp+10h],r11
    cmp     rbp,0
    jne     L6
    mov     r12d,1
    jmp     L7
L6:
    mov     r12d,0
L7:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L9
L8:
    mov     r9,r14
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L10
L9:
    cmp     r8d,1
    je      L8
    jmp     L44
L10:
    jmp     L19
L11:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L13
L12:
    mov     rdx,r15
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L14
L13:
    cmp     r8d,1
    je      L12
    jmp     L45
L14:
    jmp     L21
L15:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     rbp
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L46
    cmp     r14,r15
    jae     L16
    mov     rcx,r15
    sub     rcx,r14
    jmp     L17
L16:
    mov     rcx,r14
    sub     rcx,r15
L17:
    cmp     r8,rcx
    setbe   cl
    jmp     L22
L18:
    test    r12b,r12b
    jne     L11
    cmp     r14,0
    je      L47
    jmp     L11
L19:
    test    r9b,r9b
    jne     L18
    jmp     L47
L20:
    test    r12b,r12b
    jne     L15
    cmp     r15,0
    je      L47
    jmp     L15
L21:
    test    dl,dl
    jne     L20
    jmp     L47
L22:
    test    cl,cl
    je      L47
    imul    rbp,4
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,rbp
    call    ryo_hr_Memcpy
L23:
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,0F8h
    ret
L24:
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rax
    mov     ecx,[rsi]
    mov     edx,[rax]
    cmp     ecx,edx
    setb    cl
    mov     [rsp+0AFh],cl
    jmp     L0
L25:
    mov     rax,rsi
    lea     rax,[rax-4]
    jmp     L24
L26:
    lea     r12,[k3]
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L28
L27:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L29
L28:
    cmp     eax,1
    je      L27
    jmp     L49
L29:
    jmp     L38
L30:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L50
L33:
    jmp     L40
L34:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L51
    cmp     rbx,r13
    jae     L35
    mov     rsi,r13
    sub     rsi,rbx
    jmp     L36
L35:
    mov     rsi,rbx
    sub     rsi,r13
L36:
    cmp     rax,rsi
    setbe   al
    jmp     L41
L37:
    test    r14b,r14b
    jne     L30
    cmp     rbx,0
    je      L52
    jmp     L30
L38:
    test    cl,cl
    jne     L37
    jmp     L52
L39:
    test    r14b,r14b
    jne     L34
    cmp     r13,0
    je      L52
    jmp     L34
L40:
    test    dl,dl
    jne     L39
    jmp     L52
L41:
    test    al,al
    je      L52
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     [rsp+38h],rbx
    cmp     rbx,[rsp+18h]
    je      L2
    mov     [rsp+28h],rbx
    mov     r11,[rsp+18h]
    mov     [rsp+20h],r11
    jmp     L3
L42:
    mov     edx,[rsp+0ACh]
    mov     esi,[rax]
    cmp     edx,esi
    setb    dl
    mov     r8,rdx
    mov     r9,rax
    mov     r14,rcx
    jmp     L4
L43:
    mov     rax,[rsp+28h]
    lea     rax,[rax-4]
    mov     rcx,[rsp+20h]
    jmp     L42
L44:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L45:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L46:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L48
    jmp     L48
L47:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L48:
    call    image.sym10
    ud2
L49:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L50:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L51:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L53
    jmp     L53
L52:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L53:
    call    image.sym10
    ud2
  ; OSR entries
    lea     r11,[L54]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L54:
    .long   L55
    .long   L56
    .long   L57
    .long   L58
    .long   L59
    .long   L60
    .long   L61
    .long   L62
    .long   L63
L55:
    ret
L56:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-120h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-60h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+20h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0D8h],r11
    mov     rbx,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L1
L57:
    ret
L58:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-120h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-60h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+20h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     r11,[rsp]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0D0h],r11
    lea     rsp,[rsp+30h]
    jmp     L3
L59:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-120h]
    movzx   r11d,byte ptr [rdx-45h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+28h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B0h],r11
    mov     r8,[rsp]
    mov     r9,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L4
L60:
    ret
L61:
    ret
L62:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-120h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-60h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+20h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L42
L63:
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
    call    image.sym6
    ud2
L20:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L21:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L23:
    call    image.sym10
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
    call    image.sym6
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L19:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L21:
    call    image.sym10
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,2F8h
    mov     [rsp+1D0h],rbx
    mov     [rsp+1C0h],r12
    mov     [rsp+1B0h],r13
    mov     [rsp+1A0h],r14
    mov     [rsp+190h],r15
    mov     [rsp+180h],rbp
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+18h],r8
    mov     r11,[rsp+28h]
    cmp     r11,2
    jb      L74
    mov     rax,[rsp+28h]
    add     rax,10h
    cmp     rcx,rax
    jb      L114
    mov     rdi,[rsp+28h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+10h],rax
    mov     r11,[rsp+28h]
    cmp     r11,10h
    jb      L0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+28h]
    lea     rax,[r11+r10*8]
    mov     [rsp+110h],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+110h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+108h],rcx
    mov     rdx,[rsp+28h]
    add     rdx,8
    mov     [rsp+1F8h],rdx
    mov     r11,[rsp+20h]
    lea     rdx,[r11+rdx*8]
    mov     [rsp+100h],rdx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     ebx,8
    jmp     L62
L0:
    mov     r11,[rsp+28h]
    cmp     r11,8
    jb      L61
    mov     r10,[rsp+30h]
    mov     [rsp+110h],r10
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     eax,[r11+8]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     ecx,[r11+18h]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     edx,[r11+10h]
    cmp     ecx,edx
    setb    cl
    movzx   edx,al
    mov     r11,[rsp+30h]
    lea     rbp,[r11+rdx*8]
    xor     eax,1
    movzx   eax,al
    mov     r11,[rsp+30h]
    lea     r15,[r11+rax*8]
    movzx   eax,cl
    add     rax,2
    mov     r11,[rsp+30h]
    lea     r14,[r11+rax*8]
    xor     ecx,1
    movzx   ecx,cl
    add     rcx,2
    mov     r11,[rsp+30h]
    lea     r13,[r11+rcx*8]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[r14]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    al
    mov     r12,rax
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[r13]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,rbp
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+38h],rax
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,r13
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+40h],rax
    mov     rdi,rbx
    mov     rsi,r14
    mov     rdx,r15
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,r12
    mov     rsi,rbp
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbp,rax
    mov     rdi,r12
    mov     rsi,r15
    mov     rdx,r14
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbx,rax
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    al
    mov     r12,rax
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rbp
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r13,rax
    mov     rdi,r12
    mov     rsi,rbp
    mov     rdx,rbx
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbx,rax
    lea     rax,[image.k1752]
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+20h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+38h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+8]
    lea     rax,[image.k1776]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+10h]
    lea     rax,[image.k1800]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+18h]
    lea     rax,[image.k1824]
    mov     rdi,[rsp+40h]
    mov     rsi,rbx
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     rdi,rbx
    mov     rsi,[rsp+40h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+108h],rax
    mov     [rsp+110h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     r11,[r11+r10*8]
    mov     [rsp+48h],r11
    mov     r10,[rsp+48h]
    mov     [rsp+108h],r10
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[rax+8]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     edx,[rax]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     edx,[rax+18h]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     esi,[rax+10h]
    cmp     edx,esi
    setb    dl
    movzx   esi,cl
    lea     r12,[rax+rsi*8]
    xor     ecx,1
    movzx   ecx,cl
    lea     r13,[rax+rcx*8]
    movzx   ecx,dl
    add     rcx,2
    lea     r14,[rax+rcx*8]
    xor     edx,1
    movzx   edx,dl
    add     rdx,2
    lea     r15,[rax+rdx*8]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[r14]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     rbp,rax
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[r15]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+50h],rax
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r15
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+58h],rax
    mov     rdi,rbx
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r12,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbx,rax
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbx,rax
    lea     r11,[image.k1752]
    mov     [rsp+78h],r11
    mov     r13d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L2
L1:
    mov     rcx,[rsp+50h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L3
L2:
    cmp     eax,1
    je      L1
    jmp     L88
L3:
    jmp     L12
L4:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L6
L5:
    mov     rdx,[rsp+48h]
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L7
L6:
    cmp     eax,1
    je      L5
    jmp     L89
L7:
    jmp     L14
L8:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L90
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+48h]
    jae     L9
    mov     rsi,[rsp+48h]
    sub     rsi,[rsp+50h]
    jmp     L10
L9:
    mov     rsi,[rsp+50h]
    sub     rsi,[rsp+48h]
L10:
    cmp     rax,rsi
    setbe   al
    jmp     L15
L11:
    test    r13b,r13b
    jne     L4
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L91
    jmp     L4
L12:
    test    cl,cl
    jne     L11
    jmp     L91
L13:
    test    r13b,r13b
    jne     L8
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L91
    jmp     L8
L14:
    test    dl,dl
    jne     L13
    jmp     L91
L15:
    test    al,al
    je      L91
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+48h]
    lea     r13,[r13+8]
    lea     r11,[image.k1776]
    mov     [rsp+70h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L17
L16:
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L18
L17:
    cmp     eax,1
    je      L16
    jmp     L93
L18:
    jmp     L27
L19:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L21
L20:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L22
L21:
    cmp     eax,1
    je      L20
    jmp     L94
L22:
    jmp     L29
L23:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L95
    cmp     r14,r13
    jae     L24
    mov     rsi,r13
    sub     rsi,r14
    jmp     L25
L24:
    mov     rsi,r14
    sub     rsi,r13
L25:
    cmp     rax,rsi
    setbe   al
    jmp     L30
L26:
    test    bpl,bpl
    jne     L19
    cmp     r14,0
    je      L96
    jmp     L19
L27:
    test    cl,cl
    jne     L26
    jmp     L96
L28:
    test    bpl,bpl
    jne     L23
    cmp     r13,0
    je      L96
    jmp     L23
L29:
    test    dl,dl
    jne     L28
    jmp     L96
L30:
    test    al,al
    je      L96
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+48h]
    lea     r13,[r13+10h]
    lea     r11,[image.k1800]
    mov     [rsp+68h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L98
L33:
    jmp     L42
L34:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L36
L35:
    mov     rdx,r13
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L37
L36:
    cmp     eax,1
    je      L35
    jmp     L99
L37:
    jmp     L44
L38:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L100
    cmp     rbx,r13
    jae     L39
    mov     rsi,r13
    sub     rsi,rbx
    jmp     L40
L39:
    mov     rsi,rbx
    sub     rsi,r13
L40:
    cmp     rax,rsi
    setbe   al
    jmp     L45
L41:
    test    bpl,bpl
    jne     L34
    cmp     rbx,0
    je      L101
    jmp     L34
L42:
    test    cl,cl
    jne     L41
    jmp     L101
L43:
    test    bpl,bpl
    jne     L38
    cmp     r13,0
    je      L101
    jmp     L38
L44:
    test    dl,dl
    jne     L43
    jmp     L101
L45:
    test    al,al
    je      L101
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+48h]
    lea     rbx,[rbx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+60h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L47
L46:
    mov     rcx,[rsp+58h]
    and     rcx,3
    cmp     rcx,0
    sete    cl
    jmp     L48
L47:
    cmp     eax,1
    je      L46
    jmp     L103
L48:
    jmp     L57
L49:
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L51
L50:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L52
L51:
    cmp     eax,1
    je      L50
    jmp     L104
L52:
    jmp     L59
L53:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L105
    mov     r11,[rsp+58h]
    cmp     r11,rbx
    jae     L54
    mov     rsi,rbx
    sub     rsi,[rsp+58h]
    jmp     L55
L54:
    mov     rsi,[rsp+58h]
    sub     rsi,rbx
L55:
    cmp     rax,rsi
    setbe   al
    jmp     L60
L56:
    test    bpl,bpl
    jne     L49
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L106
    jmp     L49
L57:
    test    cl,cl
    jne     L56
    jmp     L106
L58:
    test    bpl,bpl
    jne     L53
    cmp     rbx,0
    je      L106
    jmp     L53
L59:
    test    dl,dl
    jne     L58
    jmp     L106
L60:
    test    al,al
    je      L106
    mov     rdi,rbx
    mov     rsi,[rsp+58h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     ebx,4
    jmp     L62
L61:
    mov     r10,[rsp+30h]
    mov     [rsp+110h],r10
    jmp     L75
L62:
    mov     qword ptr [rsp+1F0h],0
    mov     r10,[rsp+10h]
    mov     [rsp+1F8h],r10
    mov     qword ptr [rsp+1E0h],0
    mov     r10,[rsp+10h]
    mov     [rsp+1E8h],r10
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE30h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+130h],0
    mov     r10,[rsp+10h]
    mov     [rsp+138h],r10
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFE30h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFE70h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFE50h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFE10h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     rbp,[rsp+30h]
    mov     r13,[rsp+28h]
    mov     r14,[rsp+20h]
    mov     r11,[rsp+10h]
    mov     [rsp+0E8h],r11
    mov     [rsp+88h],rbx
    mov     rbx,[rsp+20h]
    mov     r11,[rsp+18h]
    mov     [rsp+80h],r11
L63:
    lea     rax,[rsp+1E0h]
    mov     [rsp+158h],rax
    mov     [rsp+120h],rax
    mov     qword ptr [rsp+128h],2
    mov     rax,[rsp+1E8h]
    mov     rcx,[rsp+1E0h]
    sub     rax,rcx
    cmp     rax,0
    jbe     L64
    mov     rax,[rsp+1E0h]
    jmp     L65
L64:
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE00h
    lea     rdx,[image.k6840]
    mov     ecx,10h
    call    ryo_h_Const
    mov     eax,0
    jmp     L66
L65:
    lea     r11,[image.k6944]
    mov     [rsp+0D0h],r11
    mov     r11,rax
    add     r11,1
    jb      L108
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+1E0h],rdx
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+0F0h],1
    lea     rdx,[rsp+1F0h]
    lea     r11,[image.k7064]
    mov     [rsp+0C8h],r11
    cmp     rax,2
    jae     L109
    lea     r12,[rdx+rax*8]
    lea     rdi,[rsp+2F0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym46]
    mov     rax,[r12]
    mov     rdx,rax
    mov     eax,1
L66:
    mov     [rsp+130h],rax
    mov     [rsp+138h],rdx
    jmp     L76
L67:
    mov     rax,[rsp+138h]
    mov     [rsp+128h],rax
    lea     rdx,[rbp+rax*8]
    mov     [rsp+120h],rdx
    lea     rdx,[r14+rax*8]
    mov     [rsp+158h],rdx
    cmp     rax,0
    jne     L68
    mov     rax,[rsp+0E8h]
    jmp     L69
L68:
    mov     rax,r13
    sub     rax,[rsp+0E8h]
L69:
    mov     r10,[rsp+88h]
    mov     [rsp+150h],r10
    mov     r11,[rsp+88h]
    mov     [rsp+0E0h],r11
    mov     [rsp+0D8h],rax
    mov     [rsp+90h],rbx
    mov     [rsp+98h],rbp
    mov     [rsp+0A0h],r13
    mov     [rsp+0A8h],r14
    mov     r11,[rsp+0E8h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+0C0h],r11
L70:
    mov     r10,[rsp+0E0h]
    mov     [rsp+178h],r10
    mov     r10,[rsp+0D8h]
    mov     [rsp+170h],r10
    mov     r11,[rsp+0E0h]
    cmp     r11,[rsp+0D8h]
    setb    dl
    mov     [rsp+147h],dl
    test    dl,dl
    jne     L78
    jmp     L79
L71:
    mov     [rsp+0E0h],rdx
    mov     [rsp+0D8h],rdi
    mov     [rsp+90h],r8
    mov     [rsp+98h],r9
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rcx
    mov     [rsp+0B0h],r12
    mov     [rsp+0B8h],rax
    mov     [rsp+0C0h],r15
    jmp     L70
L72:
    mov     [rsp+100h],rbx
    mov     [rsp+108h],rbx
    mov     [rsp+110h],rbp
    mov     [rsp+118h],r13
    mov     [rsp+1F0h],rbx
    mov     [rsp+1E8h],r13
    jmp     L81
L73:
    mov     rax,[rsp+108h]
    mov     [rsp+100h],rax
    mov     rax,[rsp+110h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+118h]
    mov     [rsp+1F0h],rax
L74:
    mov     rbx,[rsp+1D0h]
    mov     r12,[rsp+1C0h]
    mov     r13,[rsp+1B0h]
    mov     r14,[rsp+1A0h]
    mov     r15,[rsp+190h]
    mov     rbp,[rsp+180h]
    add     rsp,2F8h
    ret
L75:
    mov     r10,[rsp+30h]
    mov     [rsp+108h],r10
    mov     r10,[rsp+20h]
    mov     [rsp+100h],r10
    lea     rax,[k9]
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     r11,[rsp+20h]
    mov     [rsp],r11
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFD10h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFFD18h
    call    ryo_h_Memcpy
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+110h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+108h],rcx
    mov     [rsp+100h],rax
    mov     rcx,[rsp+108h]
    mov     [rsp+1F8h],rcx
    lea     rdx,[k11]
    mov     rdi,rax
    mov     rsi,rcx
    mov     ecx,4
    mov     r8d,1
    mov     r9,rdx
    mov     edx,8
    call    fn10
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFE18h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFFD10h
    call    ryo_h_Memcpy
    mov     ebx,1
    jmp     L62
L76:
    mov     rax,[rsp+130h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L77]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L77:
    .long   L72
    .long   L67
    .long   L115
L78:
    mov     r10,[rsp+0E0h]
    mov     [rsp+178h],r10
    jmp     L80
L79:
    mov     rbx,[rsp+90h]
    mov     rbp,[rsp+98h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+0A8h]
    mov     r11,[rsp+0B0h]
    mov     [rsp+0E8h],r11
    mov     r11,[rsp+0B8h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+80h],r11
    jmp     L63
L80:
    lea     rax,[k13]
    mov     rcx,[rsp+178h]
    mov     r11,rcx
    add     r11,1
    jb      L110
    mov     rcx,[rsp+178h]
    mov     rbx,rcx
    add     rbx,1
    mov     [rsp+170h],rbx
    mov     [rsp+150h],rcx
    mov     qword ptr [rsp+148h],1
    mov     [rsp+140h],rcx
    mov     rdx,[rsp+120h]
    lea     rdx,[rdx+rcx*8]
    mov     [rsp+178h],rdx
    mov     rsi,[rsp+158h]
    lea     r12,[rsi+rcx*8]
    mov     [rsp+170h],rdx
    mov     [rsp+168h],r12
    lea     rcx,[k15]
    mov     rdi,rdx
    mov     rsi,r12
    mov     edx,8
    mov     r8d,1
    mov     r9,rcx
    mov     ecx,4
    call    fn10
    mov     [rsp],r12
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFD10h
    mov     edx,0FFFFFE88h
    mov     ecx,0FFFFFD18h
    call    ryo_h_Memcpy
    mov     rcx,[rsp+158h]
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,[rsp+0C0h]
    call    qword ptr [fn17.slot]
    mov     rdx,rbx
    mov     rdi,[rsp+0D8h]
    mov     r8,[rsp+90h]
    mov     r9,[rsp+98h]
    mov     rsi,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     r12,[rsp+0B0h]
    mov     rax,[rsp+0B8h]
    mov     r15,[rsp+0C0h]
    jmp     L71
L81:
    mov     rbx,[rsp+1F0h]
    mov     [rsp+1E0h],rbx
    lea     r12,[k18]
    mov     r13,[rsp+1E8h]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    jmp     L83
L82:
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L84
L83:
    cmp     ecx,1
    je      L82
    jmp     L111
L84:
    jmp     L86
L85:
    cmp     rbx,0
    je      L112
    jmp     L87
L86:
    test    dl,dl
    jne     L85
    jmp     L112
L87:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    cmp     r13,rcx
    ja      L112
    mov     rcx,[rsp+1F0h]
    mov     [rsp+138h],rcx
    mov     rdx,[rsp+1E8h]
    mov     [rsp+1E0h],rdx
    mov     [rsp+1F8h],rcx
    mov     [rsp+100h],rdx
    mov     rsi,[rsp+110h]
    mov     [rsp+1F0h],rsi
    mov     rdi,rcx
    mov     rcx,[rsp+80h]
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [fn20.slot]
    jmp     L73
L88:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L89:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L90:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L92
    jmp     L92
L91:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L92:
    call    image.sym10
    ud2
L93:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L94:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L95:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L97
    jmp     L97
L96:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    call    image.sym10
    ud2
L98:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L99:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L100:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L102
    jmp     L102
L101:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    call    image.sym10
    ud2
L103:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L104:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L105:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L107
    jmp     L107
L106:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L107:
    call    image.sym10
    ud2
L108:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L109:
    lea     rcx,[image.k9969]
    mov     rdi,rcx
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L110:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L111:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L113
L112:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L113:
    call    image.sym10
    ud2
L114:
    lea     rdi,[rsp+2F0h]
    call    ryo_h_Abort
    ud2
L115:
    ud2
L116:
    lea     rax,[rsp+1E0h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L117
    jmp     L119
L117:
    mov     [rsp],rax
    lea     rdi,[rsp+2F0h]
    mov     esi,0FFFFFD10h
    call    ryo_h_Resume
    ud2
L118:
    lea     rax,[rsp+108h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    mov     rax,r12
    jmp     L117
    jmp     L119
    mov     rbx,rax
    jmp     L120
    mov     r12,rax
    jmp     L118
L119:
    call    sym21
    ud2
L120:
    jmp     L116
  ; OSR entries
    lea     r11,[L121]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L121:
    .long   L122
    .long   L123
    .long   L124
    .long   L125
    .long   L126
    .long   L127
    .long   L128
    .long   L129
    .long   L130
    .long   L131
L122:
    ret
L123:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-3B0h]
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
    mov     r11,[rsp+20h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-270h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+0C0h]
    jmp     L63
L124:
    ret
L125:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-3C0h]
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
    mov     [rdx-210h],r11
    mov     r11,[rsp+8]
    mov     [rdx-218h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-260h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-258h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-230h],r11
    lea     rsp,[rsp+0D0h]
    jmp     L70
L126:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-3C0h]
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
    mov     r15,[rsp+40h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+0D0h]
    jmp     L71
L127:
    ret
L128:
    ret
L129:
    ret
L130:
    ret
L131:
    ret

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,1C8h
    mov     [rsp+1B0h],rbx
    mov     [rsp+1A0h],r12
    mov     [rsp+190h],r13
    mov     [rsp+180h],r14
    mov     [rsp+170h],r15
    mov     [rsp+160h],rbp
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,0Dh
    jb      L63
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,9
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,9
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,2
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0Bh
    mov     edx,0Ch
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     r14,rbx
    lea     r14,[r14+24h]
    mov     eax,[rbx+24h]
    mov     ecx,[rbx+14h]
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
    mov     [rsp+10h],eax
    mov     eax,0
    jmp     L1
L0:
    lea     r15,[rsp+10h]
    jmp     L2
L1:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L2:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     r14,rbx
    lea     r14,[r14+2Ch]
    mov     eax,[rbx+2Ch]
    mov     ecx,[rbx+20h]
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
    mov     [rsp+20h],eax
    mov     eax,0
    jmp     L4
L3:
    lea     r15,[rsp+20h]
    jmp     L5
L4:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L3
L5:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+28h]
    mov     r14,rbx
    lea     r14,[r14+30h]
    mov     eax,[rbx+30h]
    mov     ecx,[rbx+28h]
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
    mov     [rsp+30h],eax
    mov     eax,0
    jmp     L7
L6:
    lea     r15,[rsp+30h]
    jmp     L8
L7:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L6
L8:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+40h],eax
    mov     eax,0
    jmp     L10
L9:
    lea     r14,[rsp+40h]
    jmp     L11
L10:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L9
L11:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     r14,rbx
    lea     r14,[r14+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+0Ch]
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
    mov     [rsp+50h],eax
    mov     eax,0
    jmp     L13
L12:
    lea     r15,[rsp+50h]
    jmp     L14
L13:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L12
L14:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     r14,rbx
    lea     r14,[r14+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+10h]
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
    mov     [rsp+60h],eax
    mov     eax,0
    jmp     L16
L15:
    lea     r15,[rsp+60h]
    jmp     L17
L16:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L15
L17:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     r14,rbx
    lea     r14,[r14+2Ch]
    mov     eax,[rbx+2Ch]
    mov     ecx,[rbx+18h]
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
    mov     [rsp+70h],eax
    mov     eax,0
    jmp     L19
L18:
    lea     r15,[rsp+70h]
    jmp     L20
L19:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L18
L20:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+24h]
    mov     r14,rbx
    lea     r14,[r14+28h]
    mov     eax,[rbx+28h]
    mov     ecx,[rbx+24h]
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
    mov     [rsp+80h],eax
    mov     eax,0
    jmp     L22
L21:
    lea     r15,[rsp+80h]
    jmp     L23
L22:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L21
L23:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+4]
    mov     eax,[rbx+4]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+90h],eax
    mov     eax,0
    jmp     L25
L24:
    lea     r14,[rsp+90h]
    jmp     L26
L25:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L24
L26:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+8]
    mov     r14,rbx
    lea     r14,[r14+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+8]
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
    mov     [rsp+0A0h],eax
    mov     eax,0
    jmp     L28
L27:
    lea     r15,[rsp+0A0h]
    jmp     L29
L28:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L27
L29:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     r14,rbx
    lea     r14,[r14+24h]
    mov     eax,[rbx+24h]
    mov     ecx,[rbx+18h]
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
    mov     [rsp+0B0h],eax
    mov     eax,0
    jmp     L31
L30:
    lea     r15,[rsp+0B0h]
    jmp     L32
L31:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L30
L32:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     r14,rbx
    lea     r14,[r14+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+1Ch]
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
    mov     [rsp+0C0h],eax
    mov     eax,0
    jmp     L34
L33:
    lea     r15,[rsp+0C0h]
    jmp     L35
L34:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L33
L35:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+28h]
    mov     r14,rbx
    lea     r14,[r14+2Ch]
    mov     eax,[rbx+2Ch]
    mov     ecx,[rbx+28h]
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
    mov     [rsp+0D0h],eax
    mov     eax,0
    jmp     L37
L36:
    lea     r15,[rsp+0D0h]
    jmp     L38
L37:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L36
L38:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+4]
    mov     r14,rbx
    lea     r14,[r14+0Ch]
    mov     eax,[rbx+0Ch]
    mov     ecx,[rbx+4]
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
    mov     [rsp+0E0h],eax
    mov     eax,0
    jmp     L40
L39:
    lea     r15,[rsp+0E0h]
    jmp     L41
L40:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L39
L41:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+8]
    mov     r14,rbx
    lea     r14,[r14+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+8]
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
    mov     [rsp+0F0h],eax
    mov     eax,0
    jmp     L43
L42:
    lea     r15,[rsp+0F0h]
    jmp     L44
L43:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L42
L44:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     r14,rbx
    lea     r14,[r14+18h]
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+14h]
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
    mov     [rsp+100h],eax
    mov     eax,0
    jmp     L46
L45:
    lea     r15,[rsp+100h]
    jmp     L47
L46:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L45
L47:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+24h]
    mov     r14,rbx
    lea     r14,[r14+28h]
    mov     eax,[rbx+28h]
    mov     ecx,[rbx+24h]
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
    mov     [rsp+110h],eax
    mov     eax,0
    jmp     L49
L48:
    lea     r15,[rsp+110h]
    jmp     L50
L49:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L48
L50:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+4]
    mov     r14,rbx
    lea     r14,[r14+8]
    mov     eax,[rbx+8]
    mov     ecx,[rbx+4]
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
    mov     [rsp+120h],eax
    mov     eax,0
    jmp     L52
L51:
    lea     r15,[rsp+120h]
    jmp     L53
L52:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L51
L53:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     r14,rbx
    lea     r14,[r14+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+0Ch]
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
    mov     eax,0
    jmp     L55
L54:
    lea     r15,[rsp+130h]
    jmp     L56
L55:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L54
L56:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     r14,rbx
    lea     r14,[r14+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+14h]
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
    mov     [rsp+140h],eax
    mov     eax,0
    jmp     L58
L57:
    lea     r15,[rsp+140h]
    jmp     L59
L58:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L57
L59:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     r14,rbx
    lea     r14,[r14+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+18h]
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
    mov     [rsp+150h],eax
    mov     eax,0
    jmp     L61
L60:
    lea     r15,[rsp+150h]
    jmp     L62
L61:
    lea     rcx,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L60
L62:
    lea     rax,[image.k2112]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,9
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rbx,[rsp+1B0h]
    mov     r12,[rsp+1A0h]
    mov     r13,[rsp+190h]
    mov     r14,[rsp+180h]
    mov     r15,[rsp+170h]
    mov     rbp,[rsp+160h]
    add     rsp,1C8h
    ret
L63:
    lea     rdi,[rsp+1C0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,1F8h
    mov     [rsp+1E0h],rbx
    mov     [rsp+1D0h],r12
    mov     [rsp+1C0h],r13
    mov     [rsp+1B0h],r14
    mov     [rsp+1A0h],r15
    mov     rbx,rdi
    cmp     rsi,9
    jb      L75
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     eax,[rbx+0Ch]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     eax,0
    jmp     L1
L0:
    lea     r13,[rsp+10h]
    jmp     L2
L1:
    lea     rcx,[image.k2088]
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L2:
    lea     rax,[image.k2112]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+4]
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     eax,0
    jmp     L4
L3:
    lea     r14,[rsp+20h]
    jmp     L5
L4:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L3
L5:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+8]
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+30h],eax
    mov     eax,0
    jmp     L7
L6:
    lea     r14,[rsp+30h]
    jmp     L8
L7:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L6
L8:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+10h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+40h],eax
    mov     eax,0
    jmp     L10
L9:
    lea     r14,[rsp+40h]
    jmp     L11
L10:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L9
L11:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+50h],eax
    mov     eax,0
    jmp     L13
L12:
    lea     r13,[rsp+50h]
    jmp     L14
L13:
    lea     rcx,[image.k2088]
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L12
L14:
    lea     rax,[image.k2112]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+8]
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+60h],eax
    mov     eax,0
    jmp     L16
L15:
    lea     r14,[rsp+60h]
    jmp     L17
L16:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L15
L17:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+70h],eax
    mov     eax,0
    jmp     L19
L18:
    lea     r14,[rsp+70h]
    jmp     L20
L19:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L18
L20:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+14h]
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+14h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+80h],eax
    mov     eax,0
    jmp     L22
L21:
    lea     r14,[rsp+80h]
    jmp     L23
L22:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L21
L23:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+8]
    mov     eax,[rbx+8]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+90h],eax
    mov     eax,0
    jmp     L25
L24:
    lea     r13,[rsp+90h]
    jmp     L26
L25:
    lea     rcx,[image.k2088]
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L24
L26:
    lea     rax,[image.k2112]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+4]
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     eax,[rbx+0Ch]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0A0h],eax
    mov     eax,0
    jmp     L28
L27:
    lea     r14,[rsp+0A0h]
    jmp     L29
L28:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L27
L29:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+10h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0B0h],eax
    mov     eax,0
    jmp     L31
L30:
    lea     r14,[rsp+0B0h]
    jmp     L32
L31:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L30
L32:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+1Ch]
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+1Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0C0h],eax
    mov     eax,0
    jmp     L34
L33:
    lea     r14,[rsp+0C0h]
    jmp     L35
L34:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L33
L35:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+4]
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0D0h],eax
    mov     eax,0
    jmp     L37
L36:
    lea     r14,[rsp+0D0h]
    jmp     L38
L37:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L36
L38:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0E0h],eax
    mov     eax,0
    jmp     L40
L39:
    lea     r14,[rsp+0E0h]
    jmp     L41
L40:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L39
L41:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+14h]
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+14h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0F0h],eax
    mov     eax,0
    jmp     L43
L42:
    lea     r14,[rsp+0F0h]
    jmp     L44
L43:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L42
L44:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+4]
    mov     eax,[rbx+4]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+100h],eax
    mov     eax,0
    jmp     L46
L45:
    lea     r13,[rsp+100h]
    jmp     L47
L46:
    lea     rcx,[image.k2088]
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L45
L47:
    lea     rax,[image.k2112]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+8]
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+110h],eax
    mov     eax,0
    jmp     L49
L48:
    lea     r14,[rsp+110h]
    jmp     L50
L49:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L48
L50:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+120h],eax
    mov     eax,0
    jmp     L52
L51:
    lea     r14,[rsp+120h]
    jmp     L53
L52:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L51
L53:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+18h]
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+18h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+130h],eax
    mov     eax,0
    jmp     L55
L54:
    lea     r14,[rsp+130h]
    jmp     L56
L55:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L54
L56:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+8]
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     eax,[rbx+0Ch]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+140h],eax
    mov     eax,0
    jmp     L58
L57:
    lea     r14,[rsp+140h]
    jmp     L59
L58:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L57
L59:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r13,rbx
    lea     r13,[r13+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+10h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+150h],eax
    mov     eax,0
    jmp     L61
L60:
    lea     r14,[rsp+150h]
    jmp     L62
L61:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L60
L62:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+18h]
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+18h]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+160h],eax
    mov     eax,0
    jmp     L64
L63:
    lea     r14,[rsp+160h]
    jmp     L65
L64:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L63
L65:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+4]
    mov     r13,rbx
    lea     r13,[r13+8]
    mov     eax,[rbx+8]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+170h],eax
    mov     eax,0
    jmp     L67
L66:
    lea     r14,[rsp+170h]
    jmp     L68
L67:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L66
L68:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    al
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+180h],eax
    mov     eax,0
    jmp     L70
L69:
    lea     r14,[rsp+180h]
    jmp     L71
L70:
    lea     rcx,[image.k2088]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L69
L71:
    lea     rax,[image.k2112]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,rbx
    lea     r12,[r12+14h]
    mov     r13,rbx
    lea     r13,[r13+18h]
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+14h]
    cmp     eax,ecx
    setb    al
    mov     rbx,rax
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+190h],eax
    mov     eax,0
    jmp     L73
L72:
    lea     rbx,[rsp+190h]
    jmp     L74
L73:
    lea     rcx,[image.k2088]
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L72
L74:
    lea     rax,[image.k2112]
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    image.fn180
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+1E0h]
    mov     r12,[rsp+1D0h]
    mov     r13,[rsp+1C0h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A0h]
    add     rsp,1F8h
    ret
L75:
    lea     rdi,[rsp+1F0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    lea     rbx,[rdi+rsi*4]
    lea     r12,[rdi+rdx*4]
    mov     eax,[r12]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    al
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rbx
    movzx   edi,dil
    call    fn1
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r12
    movzx   edi,dil
    call    fn1
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     r15d,0
    jmp     L1
L0:
    lea     r13,[rsp+10h]
    jmp     L18
L1:
    lea     rbp,[k3]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L3
L2:
    mov     rcx,r14
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
    test    r15b,r15b
    je      L9
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L7
L6:
    mov     rdx,rbx
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
    cmp     r14,0
    je      L37
    jmp     L13
L10:
    test    cl,cl
    jne     L5
    jmp     L37
L11:
    cmp     rbx,0
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
    mov     rcx,rbx
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
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L18:
    lea     rbx,[k5]
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L20
L19:
    mov     rcx,r13
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
    mov     rdx,r12
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
    cmp     r13,r12
    jae     L27
    mov     rsi,r12
    sub     rsi,r13
    jmp     L28
L27:
    mov     rsi,r13
    sub     rsi,r12
L28:
    cmp     rax,rsi
    setbe   al
    jmp     L33
L29:
    test    r14b,r14b
    jne     L22
    cmp     r13,0
    je      L42
    jmp     L22
L30:
    test    cl,cl
    jne     L29
    jmp     L42
L31:
    test    r14b,r14b
    jne     L26
    cmp     r12,0
    je      L42
    jmp     L26
L32:
    test    dl,dl
    jne     L31
    jmp     L42
L33:
    test    al,al
    je      L42
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
L34:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L35:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L36:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L38
L37:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L38
L38:
    call    image.sym10
    ud2
L39:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L40:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L41:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L43
    jmp     L43
L42:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L43:
    call    image.sym10
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
    call    image.sym6
    ud2
L22:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L23:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L25:
    call    image.sym10
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
    sub     rsp,238h
    mov     [rsp+130h],rbx
    mov     [rsp+120h],r12
    mov     [rsp+110h],r13
    mov     [rsp+100h],r14
    mov     [rsp+0F0h],r15
    mov     [rsp+0E0h],rbp
    mov     rax,[rsp+240h]
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     [rsp+38h],r9
    mov     [rsp+30h],rdi
    mov     [rsp+20h],rsi
L0:
    mov     r10,[rsp+30h]
    mov     [rsp+170h],r10
    mov     eax,20h
    cmp     rax,[rsp+20h]
    jb      L1
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+48h]
    mov     r8,[rsp+40h]
    call    qword ptr [image.fn81.slot]
    jmp     L23
L1:
    cmp     r8d,0
    jne     L2
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+48h]
    mov     r8d,1
    mov     r9,[rsp+40h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
    jmp     L23
L2:
    mov     r11,r8
    sub     r11d,1
    mov     [rsp+28h],r11
    mov     r10,[rsp+30h]
    mov     [rsp+168h],r10
    mov     r10,[rsp+20h]
    mov     [rsp+170h],r10
    mov     r11,[rsp+20h]
    cmp     r11,8
    jb      L34
    mov     rdi,[rsp+20h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+30h]
    lea     rbp,[r11+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+30h]
    lea     r15,[r11+rcx*8]
    mov     r11,[rsp+20h]
    cmp     r11,40h
    jae     L6
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     ecx,[r11]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     edx,[rbp]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     edx,[r11]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    cmp     cl,dl
    jne     L4
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     edx,[rbp]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    xor     edx,ecx
    test    dl,dl
    je      L3
    mov     rcx,r15
    jmp     L5
L3:
    mov     rcx,rbp
    jmp     L5
L4:
    mov     rcx,[rsp+30h]
L5:
    jmp     L14
L6:
    mov     rdx,rax
    imul    rdx,8
    cmp     rdx,40h
    jb      L7
    jmp     L8
L7:
    mov     rbx,[rsp+30h]
    jmp     L9
L8:
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r14,rax
    mov     r13,r14
    imul    r13,4
    mov     r11,[rsp+30h]
    lea     rax,[r11+r13*8]
    mov     r12,r14
    imul    r12,7
    mov     r11,[rsp+30h]
    lea     rdx,[r11+r12*8]
    mov     rdi,[rsp+30h]
    mov     rsi,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     rbx,rax
    lea     rax,[rbp+r13*8]
    lea     rdx,[rbp+r12*8]
    mov     rdi,rbp
    mov     rsi,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     rbp,rax
    lea     rax,[r15+r13*8]
    lea     rdx,[r15+r12*8]
    mov     rdi,r15
    mov     rsi,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     r15,rax
L9:
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     edx,[rbp]
    cmp     eax,edx
    setb    al
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     edx,[rbx]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    cmp     al,dl
    jne     L11
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     edx,[rbp]
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     esi,[r15]
    cmp     edx,esi
    setb    dl
    xor     edx,eax
    test    dl,dl
    je      L10
    jmp     L12
L10:
    mov     r15,rbp
    jmp     L12
L11:
    mov     r15,rbx
L12:
    jmp     L15
L13:
    cmp     rax,[rsp+20h]
    setb    dl
    jmp     L16
L14:
    lea     rsi,[image.k1336]
    cmp     rcx,[rsp+30h]
    jb      L31
    sub     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rax,rcx
    jmp     L13
L15:
    lea     rcx,[image.k1464]
    cmp     r15,[rsp+30h]
    jb      L32
    sub     r15,[rsp+30h]
    mov     rdi,r15
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rdi,rax
    mov     rax,rdi
    jmp     L13
L16:
    lea     rdi,[image.k1512]
    test    dl,dl
    je      L33
    cmp     rax,[rsp+20h]
    jae     L35
    mov     r11,[rsp+30h]
    lea     rdx,[r11+rax*8]
    mov     [rsp+160h],rdx
    mov     [rsp+168h],rdx
    mov     rdx,[rdx]
    mov     [rsp+170h],rdx
    mov     edx,1
    jmp     L24
L17:
    mov     r10,[rsp+98h]
    mov     [rsp+168h],r10
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+68h]
    jae     L36
    mov     r11,[rsp+60h]
    mov     r10,[rsp+58h]
    lea     r8,[r11+r10*8]
    mov     [rsp+150h],r8
    mov     r9,[rsp+168h]
    mov     [rsp+158h],r9
    mov     [rsp+160h],r8
    mov     r11,[rsp+90h]
    mov     r11,[r11]
    mov     r9d,[r9]
    mov     r11,[rsp+90h]
    mov     r11,[r11]
    mov     r8d,[r8]
    cmp     r9d,r8d
    setb    r8b
    mov     r9,r8
    xor     r9d,1
    cmp     r8b,1
    jne     L18
    jmp     L19
L18:
    mov     r11,[rsp+90h]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+88h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+0C0h],r11
    mov     r14,[rsp+58h]
    mov     r8d,0
    mov     r11,[rsp+78h]
    mov     [rsp+0B8h],r11
    mov     rbx,[rsp+70h]
    mov     r13,[rsp+98h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+68h]
    jmp     L21
L19:
    mov     r12,[rsp+90h]
    mov     rbp,[rsp+88h]
    mov     r15,[rsp+80h]
    mov     r14,[rsp+58h]
    mov     r13,[rsp+78h]
    mov     rbx,[rsp+70h]
    mov     r11,[rsp+98h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0B0h],r11
    jmp     L20
L20:
    mov     r10,[rsp+0A8h]
    mov     [rsp+160h],r10
    mov     r10,[rsp+0B0h]
    mov     [rsp+168h],r10
    mov     [rsp],r12
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+0B0h]
    mov     rdx,rbp
    mov     rcx,r15
    mov     r8,r14
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    mov     r8,rax
    mov     [rsp+168h],r8
    cmp     r8,0
    sete    r9b
    mov     [rsp+0D0h],r12
    mov     [rsp+0C8h],rbp
    mov     [rsp+0C0h],r15
    mov     [rsp+0B8h],r13
    mov     r13,[rsp+0A0h]
    mov     r15,[rsp+0A8h]
    mov     rbp,[rsp+0B0h]
L21:
    test    r9b,r9b
    je      L22
    mov     [rsp+158h],r15
    mov     [rsp+160h],rbp
    mov     r10,[rsp+0D0h]
    mov     [rsp+148h],r10
    lea     r9,[rsp+148h]
    mov     [rsp+150h],r9
    mov     [rsp],r9
    mov     rdi,r15
    mov     rsi,rbp
    mov     rdx,[rsp+0C8h]
    mov     rcx,[rsp+0C0h]
    mov     r8,r14
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     r9,rax
    mov     [rsp+168h],r9
    mov     [rsp+160h],rbp
    cmp     rbp,r9
    jb      L37
    jmp     L29
L22:
    lea     r9,[k12]
    lea     r14,[rsp+140h]
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,r8
    mov     r8,r9
    call    qword ptr [fn13.slot]
    mov     r14,[rsp+140h]
    mov     r12,[rsp+148h]
    mov     r8,[rsp+150h]
    mov     [rsp+160h],r8
    mov     r9,[rsp+158h]
    mov     [rsp+168h],r9
    mov     r10,[rsp+0D0h]
    mov     [rsp],r10
    mov     rdi,r8
    mov     rsi,r9
    mov     rdx,[rsp+0C8h]
    mov     rcx,[rsp+0C0h]
    mov     r8,[rsp+0B8h]
    mov     r9,rbx
    mov     r8d,r8d
    call    fn14
    mov     r11,[rsp+0C8h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+40h],r11
    mov     r8,[rsp+0B8h]
    mov     [rsp+38h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r12
    jmp     L0
L23:
    mov     rbx,[rsp+130h]
    mov     r12,[rsp+120h]
    mov     r13,[rsp+110h]
    mov     r14,[rsp+100h]
    mov     r15,[rsp+0F0h]
    mov     rbp,[rsp+0E0h]
    add     rsp,238h
    ret
L24:
    lea     r8,[rsp+170h]
    mov     [rsp+158h],r8
    mov     [rsp+160h],r8
    mov     [rsp+168h],r8
    test    dl,dl
    jne     L27
    jmp     L28
L25:
    mov     rdi,[rsp+98h]
    mov     esi,0
    mov     edx,0
    mov     rcx,100000000h
    call    ryo_hr_DiscrNicheW64
    mov     rdx,rax
    mov     edx,edx
    mov     rdi,rdx
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     rdx,rax
    mov     r10,rdx
    lea     r11,[L26]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L26:
    .long   L30
    .long   L17
    .long   L38
L27:
    mov     rdx,[rsp+168h]
    mov     r11,[rsp+38h]
    mov     [rsp+98h],r11
    mov     [rsp+58h],rax
    mov     r11,[rsp+40h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+78h],r11
    mov     [rsp+70h],rdx
    mov     r11,[rsp+30h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+68h],r11
    jmp     L25
L28:
    mov     r11,[rsp+38h]
    mov     [rsp+98h],r11
    mov     [rsp+58h],rax
    mov     r11,[rsp+40h]
    mov     [rsp+90h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+78h],r11
    mov     qword ptr [rsp+70h],0
    mov     r11,[rsp+30h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+68h],r11
    jmp     L25
L29:
    mov     rdx,[rsp+160h]
    mov     r8,[rsp+168h]
    sub     rdx,r8
    mov     [rsp+158h],rdx
    mov     [rsp+140h],rbp
    lea     r15,[r15+r8*8]
    mov     [rsp+148h],r15
    mov     [rsp+150h],rdx
    mov     r11,[rsp+0C8h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+40h],r11
    mov     r8,[rsp+0B8h]
    mov     qword ptr [rsp+38h],0
    mov     [rsp+30h],r15
    mov     [rsp+20h],rdx
    jmp     L0
L30:
    mov     r12,[rsp+90h]
    mov     rbp,[rsp+88h]
    mov     r15,[rsp+80h]
    mov     r14,[rsp+58h]
    mov     r13,[rsp+78h]
    mov     rbx,[rsp+70h]
    mov     r11,[rsp+98h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0B0h],r11
    jmp     L20
L31:
    lea     rdx,[image.k7567]
    mov     rdi,rdx
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L32:
    lea     rdx,[image.k7567]
    mov     rdi,rdx
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L33:
    lea     rcx,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     r10,rdi
    mov     rdi,rcx
    mov     rcx,r10
    movzx   edx,dl
    call    image.sym49
    ud2
L34:
    lea     rdi,[rsp+230h]
    call    ryo_h_Abort
    ud2
L35:
    lea     rcx,[k4]
    mov     rdi,rax
    mov     rsi,[rsp+20h]
    mov     rdx,rcx
    call    sym5
    ud2
L36:
    lea     rax,[k7]
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+68h]
    mov     rdx,rax
    call    sym5
    ud2
L37:
    lea     rax,[k15]
    mov     rcx,[rsp+168h]
    mov     rdx,[rsp+160h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rcx,rax
    call    sym16
    ud2
L38:
    ud2
  ; OSR entries
    lea     r11,[L39]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L39:
    .long   L40
    .long   L41
    .long   L42
L40:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-270h]
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
    mov     [rdx-230h],r11
    mov     r11,[rsp]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-210h],r11
    mov     r8,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L0
L41:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-280h]
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
    mov     [rdx-230h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-180h],r11
    mov     r12,[rsp]
    mov     rbp,[rsp+8]
    mov     r15,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     rbx,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L20
L42:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-280h]
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
    mov     [rdx-230h],r11
    mov     r11,[rsp]
    mov     [rdx-198h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1C8h],r11
    lea     rsp,[rsp+50h]
    jmp     L25

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
    call    image.sym6
    ud2
L192:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L193:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L195:
    call    image.sym10
    ud2
L196:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L197:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L198:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L200:
    call    image.sym10
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L205:
    call    image.sym10
    ud2
L206:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L207:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L208:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L210:
    call    image.sym10
    ud2
L211:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L212:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L213:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L215:
    call    image.sym10
    ud2
L216:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L217:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L218:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L220:
    call    image.sym10
    ud2
L221:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L222:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L223:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L225:
    call    image.sym10
    ud2
L226:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L227:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L228:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L230:
    call    image.sym10
    ud2
L231:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L232:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L233:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L234:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L236:
    call    image.sym10
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
    call    image.sym6
    ud2
L192:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L193:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L195:
    call    image.sym10
    ud2
L196:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L197:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L198:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L200:
    call    image.sym10
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L205:
    call    image.sym10
    ud2
L206:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L207:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L208:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L210:
    call    image.sym10
    ud2
L211:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L212:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L213:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L215:
    call    image.sym10
    ud2
L216:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L217:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L218:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L220:
    call    image.sym10
    ud2
L221:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L222:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L223:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L225:
    call    image.sym10
    ud2
L226:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L227:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L228:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L230:
    call    image.sym10
    ud2
L231:
    lea     rcx,[image.k7768]
    mov     rdi,rcx
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L232:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L233:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L234:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L236:
    call    image.sym10
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
    call    image.sym6
    ud2
L35:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L36:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L38
L37:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L38
L38:
    call    image.sym10
    ud2
L39:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L40:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L41:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    image.sym49
    ud2
L43:
    call    image.sym10
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
    sub     rsp,398h
    mov     [rsp+2C0h],rbx
    mov     [rsp+2B0h],r12
    mov     [rsp+2A0h],r13
    mov     [rsp+290h],r14
    mov     [rsp+280h],r15
    mov     [rsp+270h],rbp
    mov     [rsp+18h],r8
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rdi
    mov     [rsp+10h],rsi
L0:
    mov     eax,20h
    cmp     rax,[rsp+10h]
    jb      L39
    mov     r11,[rsp+10h]
    cmp     r11,2
    jb      L258
    mov     r11,[rsp+10h]
    cmp     r11,20h
    ja      L269
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
    jmp     L29
L3:
    mov     r10,[rsp+80h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    mov     r11,[rsp+80h]
    cmp     r11,0Dh
    jb      L4
    mov     r10,[rsp+78h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+48h]
    call    qword ptr [image.fn74.slot]
    mov     eax,0Dh
    jmp     L6
L4:
    mov     r10,[rsp+80h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    mov     r11,[rsp+80h]
    cmp     r11,9
    jb      L5
    mov     r10,[rsp+78h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+48h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L6
L5:
    mov     eax,1
L6:
    mov     r10,[rsp+78h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+80h]
    mov     [rsp+1E8h],r10
    cmp     rax,0
    je      L265
    mov     r11,[rsp+80h]
    cmp     r11,rax
    jb      L265
    mov     r11,[rsp+78h]
    mov     r10,[rsp+80h]
    lea     rdx,[r11+r10*4]
    mov     r11,[rsp+78h]
    lea     rax,[r11+rax*4]
    mov     r13,rax
    mov     r14,rdx
    mov     r11,[rsp+78h]
    mov     [rsp+88h],r11
L7:
    cmp     r13,r14
    je      L26
    jmp     L14
L8:
    movzx   eax,byte ptr [rsp+13Fh]
    test    al,al
    je      L25
    mov     [rsp+150h],r13
    mov     eax,[r13]
    mov     [rsp+154h],eax
    mov     [rsp+13Ch],eax
    lea     rax,[rsp+13Ch]
    mov     [rsp+140h],rax
    mov     [rsp+148h],r13
    mov     qword ptr [rsp+150h],1
    mov     rbx,r15
    mov     r12,[rsp+88h]
L9:
    mov     rbp,[rsp+148h]
    jmp     L15
L10:
    jmp     L24
L11:
    test    sil,sil
    je      L12
    mov     rbx,rdi
    mov     r12,r8
    jmp     L9
L12:
    lea     rsi,[rsp+140h]
    mov     rdi,rsi
    call    qword ptr [image.fn229.slot]
    jmp     L25
L13:
    mov     [rsp+140h],r13
    mov     [rsp+148h],r13
    mov     [rsp+150h],r15
    mov     rdi,r13
    mov     rsi,r15
    call    qword ptr [image.fn206.slot]
    mov     rsi,rax
    mov     [rsp+13Fh],sil
    jmp     L8
L14:
    mov     rsi,r13
    lea     rsi,[rsi-4]
    mov     r15,rsi
    jmp     L13
L15:
    lea     r11,[image.k1728]
    mov     [rsp+90h],r11
    mov     r15d,0
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    jmp     L19
L16:
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    mov     rdi,rax
    jmp     L21
L17:
    mov     rdi,rbx
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    mov     r8,rax
    jmp     L22
L18:
    test    r15b,r15b
    jne     L16
    cmp     rbx,0
    je      L260
    jmp     L16
L19:
    test    sil,sil
    jne     L18
    jmp     L260
L20:
    test    r15b,r15b
    jne     L17
    cmp     rbp,0
    je      L260
    jmp     L17
L21:
    test    dil,dil
    jne     L20
    jmp     L260
L22:
    test    r8b,r8b
    je      L260
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     [rsp+148h],rbx
    cmp     rbx,r12
    je      L12
    mov     rax,rbx
    mov     rdx,r12
    jmp     L10
L23:
    lea     rsi,[rsp+13Ch]
    mov     rdi,rsi
    mov     rsi,rbx
    call    qword ptr [image.fn206.slot]
    mov     rsi,rax
    mov     rdi,rbx
    mov     r8,r12
    jmp     L11
L24:
    lea     rax,[rax-4]
    mov     rbx,rax
    mov     r12,rdx
    jmp     L23
L25:
    lea     r13,[r13+4]
    jmp     L7
L26:
    cmp     byte ptr [rsp+58h],0
    jne     L258
    mov     r10,[rsp+80h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+78h]
    mov     [rsp+1E8h],r10
    mov     r10,[rsp+38h]
    mov     [rsp+1E0h],r10
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+38h]
    je      L27
    lea     rbx,[rsp+158h]
    jmp     L37
L27:
    mov     r11,[rsp+30h]
    mov     r10,[rsp+50h]
    lea     rax,[r11+r10*4]
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+40h]
    sub     rax,[rsp+50h]
    mov     [rsp+1E0h],rax
    jmp     L30
L28:
    mov     [rsp+1E8h],rbx
    jmp     L38
L29:
    mov     r10,[rsp+20h]
    mov     [rsp+1E8h],r10
    lea     rax,[image.k2160]
    mov     rdi,[rsp+20h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+60h]
    mov     r8,rax
    call    image.fn187
    mov     r10,[rsp+20h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+1E8h],r10
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
    mov     [rsp+80h],r11
    jmp     L3
L30:
    mov     r12,[rsp+1E8h]
    lea     r11,[image.k2184]
    mov     [rsp+98h],r11
    mov     r14,[rsp+1E0h]
    mov     edi,4
    call    ryo_hr_CtpopW64
    jmp     L32
L31:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    sete    dl
    jmp     L33
L32:
    cmp     eax,1
    je      L31
    jmp     L266
L33:
    jmp     L35
L34:
    cmp     r12,0
    je      L267
    jmp     L36
L35:
    test    dl,dl
    jne     L34
    jmp     L267
L36:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L267
    mov     rax,[rsp+1E8h]
    mov     rdx,[rsp+1E0h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    jmp     L3
L37:
    lea     rax,[image.k2208]
    mov     rdi,[rsp+38h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+40h]
    mov     r8,rax
    call    image.fn187
    mov     r10,[rsp+30h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+1E8h],r10
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+40h]
    mov     rdx,rbx
    mov     rcx,[rsp+48h]
    call    qword ptr [image.fn78.slot]
    jmp     L28
L38:
    mov     [rsp+1E0h],rbx
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
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    mov     edx,0FFFFFE58h
    mov     ecx,0FFFFFC78h
    call    ryo_h_Memcpy
    jmp     L258
L39:
    cmp     ecx,0
    jne     L40
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
    jmp     L258
L40:
    mov     r11,rcx
    sub     r11d,1
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+10h]
    cmp     r11,8
    jb      L273
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
    jae     L44
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
    jne     L42
    mov     edx,[r12]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    xor     edx,ecx
    test    dl,dl
    je      L41
    mov     rcx,r14
    jmp     L43
L41:
    mov     rcx,r12
    jmp     L43
L42:
    mov     rcx,[rsp+20h]
L43:
    jmp     L52
L44:
    mov     rdx,rax
    imul    rdx,8
    cmp     rdx,40h
    jb      L45
    jmp     L46
L45:
    mov     rbx,[rsp+20h]
    jmp     L47
L46:
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
L47:
    mov     eax,[rbx]
    mov     edx,[r12]
    cmp     eax,edx
    setb    al
    mov     edx,[rbx]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    cmp     al,dl
    jne     L49
    mov     edx,[r12]
    mov     esi,[r14]
    cmp     edx,esi
    setb    dl
    xor     edx,eax
    test    dl,dl
    je      L48
    jmp     L50
L48:
    mov     r14,r12
    jmp     L50
L49:
    mov     r14,rbx
L50:
    jmp     L53
L51:
    cmp     rax,[rsp+10h]
    setb    dl
    jmp     L54
L52:
    lea     rsi,[image.k1536]
    cmp     rcx,[rsp+20h]
    jb      L270
    sub     rcx,[rsp+20h]
    mov     rdi,rcx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rax,rcx
    jmp     L51
L53:
    lea     rcx,[image.k1584]
    cmp     r14,[rsp+20h]
    jb      L271
    sub     r14,[rsp+20h]
    mov     rdi,r14
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    mov     rax,rdi
    jmp     L51
L54:
    lea     rdi,[image.k1632]
    test    dl,dl
    je      L272
    mov     [rsp+0A8h],rax
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
    lea     r11,[L55]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
L55:
    .long   L157
    .long   L56
    .long   L347
L56:
    mov     r11,[rsp+0A8h]
    cmp     r11,[rsp+10h]
    jae     L344
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0A8h]
    lea     rax,[r11+r10*4]
    mov     r11,[rsp+28h]
    mov     edx,[r11]
    mov     eax,[rax]
    cmp     edx,eax
    setb    al
    test    al,al
    jne     L157
    mov     r10,[rsp+18h]
    mov     [rsp+2F0h],r10
    lea     r12,[rsp+2F0h]
    mov     r11,[rsp+10h]
    cmp     r11,0
    jne     L57
    mov     ebx,0
    jmp     L156
L57:
    mov     r11,[rsp+0A8h]
    cmp     r11,[rsp+10h]
    jae     L306
    lea     rax,[image.k4408]
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L274
    mov     r11,[rsp+0A8h]
    cmp     r11,[rsp+10h]
    jae     L274
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0A8h]
    lea     r13,[r11+r10*4]
    lea     r14,[rsp+1FCh]
    lea     r15,[image.k488]
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L59
L58:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L60
L59:
    cmp     edx,1
    je      L58
    jmp     L275
L60:
    jmp     L69
L61:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L63
L62:
    mov     r9,r14
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L64
L63:
    cmp     edx,1
    je      L62
    jmp     L276
L64:
    jmp     L71
L65:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L277
    mov     r11,[rsp+20h]
    cmp     r11,r14
    jae     L66
    mov     rbx,r14
    sub     rbx,[rsp+20h]
    jmp     L67
L66:
    mov     rbx,[rsp+20h]
    sub     rbx,r14
L67:
    cmp     rdx,rbx
    setbe   dl
    jmp     L72
L68:
    test    bpl,bpl
    jne     L61
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L278
    jmp     L61
L69:
    test    r8b,r8b
    jne     L68
    jmp     L278
L70:
    test    bpl,bpl
    jne     L65
    cmp     r14,0
    je      L278
    jmp     L65
L71:
    test    r9b,r9b
    jne     L70
    jmp     L278
L72:
    test    dl,dl
    je      L278
    mov     rdi,r14
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L74
L73:
    lea     rbx,[rsp+1FCh]
    jmp     L91
L74:
    lea     r11,[image.k512]
    mov     [rsp+0B8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L76
L75:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L77
L76:
    cmp     edx,1
    je      L75
    jmp     L280
L77:
    jmp     L83
L78:
    test    r14b,r14b
    je      L82
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L80
L79:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L81
L80:
    cmp     edx,1
    je      L79
    jmp     L281
L81:
    jmp     L85
L82:
    cmp     r13,0
    je      L283
    jmp     L86
L83:
    test    r8b,r8b
    jne     L78
    jmp     L283
L84:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L283
    jmp     L90
L85:
    test    r9b,r9b
    jne     L90
    jmp     L283
L86:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L88
L87:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L89
L88:
    cmp     edx,1
    je      L87
    jmp     L282
L89:
    test    r8b,r8b
    jne     L84
    jmp     L283
L90:
    mov     rdi,[rsp+20h]
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L73
L91:
    lea     r11,[image.k536]
    mov     [rsp+0B0h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L93
L92:
    mov     r8,rbx
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L94
L93:
    cmp     edx,1
    je      L92
    jmp     L285
L94:
    jmp     L103
L95:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L97
L96:
    mov     r9,r13
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L98
L97:
    cmp     edx,1
    je      L96
    jmp     L286
L98:
    jmp     L105
L99:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L287
    cmp     rbx,r13
    jae     L100
    mov     rbp,r13
    sub     rbp,rbx
    jmp     L101
L100:
    mov     rbp,rbx
    sub     rbp,r13
L101:
    cmp     rdx,rbp
    setbe   dl
    jmp     L106
L102:
    test    r14b,r14b
    jne     L95
    cmp     rbx,0
    je      L288
    jmp     L95
L103:
    test    r8b,r8b
    jne     L102
    jmp     L288
L104:
    test    r14b,r14b
    jne     L99
    cmp     r13,0
    je      L288
    jmp     L99
L105:
    test    r9b,r9b
    jne     L104
    jmp     L288
L106:
    test    dl,dl
    je      L288
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     rdx,[image.k4432]
    lea     r8,[rsp+210h]
    mov     rdi,r8
    mov     rsi,[rsp+20h]
    mov     ecx,1
    mov     r8,rdx
    mov     rdx,[rsp+10h]
    call    fn10
    mov     rdx,[rsp+210h]
    mov     r11,[rsp+218h]
    mov     [rsp+0C0h],r11
    mov     r9,[rsp+220h]
    mov     rbx,[rsp+228h]
    mov     r11,[rsp+0C0h]
    cmp     r11,0
    jbe     L307
    mov     [rsp+228h],rdx
    mov     [rsp+220h],rdx
    mov     r13,[image.sym36]
    mov     rdi,r9
    mov     rsi,rbx
    mov     rcx,r12
    mov     rax,r13
    call    rax
    mov     rbx,rax
    cmp     rbx,[rsp+10h]
    jae     L308
    lea     r11,[image.k4480]
    mov     [rsp+0D0h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L290
    cmp     rbx,[rsp+10h]
    jae     L290
    mov     r11,[rsp+20h]
    lea     r12,[r11+rbx*4]
    lea     r13,[rsp+20Ch]
    lea     r11,[image.k488]
    mov     [rsp+0C8h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L108
L107:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L109
L108:
    cmp     r9d,1
    je      L107
    jmp     L291
L109:
    jmp     L118
L110:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L112
L111:
    mov     r14,r13
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L113
L112:
    cmp     r9d,1
    je      L111
    jmp     L292
L113:
    jmp     L120
L114:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L293
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L115
    mov     rdx,r13
    sub     rdx,[rsp+20h]
    jmp     L116
L115:
    mov     rdx,[rsp+20h]
    sub     rdx,r13
L116:
    cmp     r9,rdx
    setbe   dl
    jmp     L121
L117:
    test    bpl,bpl
    jne     L110
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L294
    jmp     L110
L118:
    test    r8b,r8b
    jne     L117
    jmp     L294
L119:
    test    bpl,bpl
    jne     L114
    cmp     r13,0
    je      L294
    jmp     L114
L120:
    test    r14b,r14b
    jne     L119
    jmp     L294
L121:
    test    dl,dl
    je      L294
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L123
L122:
    lea     r13,[rsp+20Ch]
    jmp     L140
L123:
    lea     r11,[image.k512]
    mov     [rsp+0E0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L125
L124:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L126
L125:
    cmp     edx,1
    je      L124
    jmp     L296
L126:
    jmp     L132
L127:
    test    r14b,r14b
    je      L131
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L129
L128:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L130
L129:
    cmp     edx,1
    je      L128
    jmp     L297
L130:
    jmp     L134
L131:
    cmp     r12,0
    je      L299
    jmp     L135
L132:
    test    r8b,r8b
    jne     L127
    jmp     L299
L133:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L299
    jmp     L139
L134:
    test    r9b,r9b
    jne     L139
    jmp     L299
L135:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L137
L136:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L138
L137:
    cmp     edx,1
    je      L136
    jmp     L298
L138:
    test    r8b,r8b
    jne     L133
    jmp     L299
L139:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L122
L140:
    lea     r11,[image.k536]
    mov     [rsp+0D8h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L142
L141:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L143
L142:
    cmp     edx,1
    je      L141
    jmp     L301
L143:
    jmp     L152
L144:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L146
L145:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L147
L146:
    cmp     edx,1
    je      L145
    jmp     L302
L147:
    jmp     L154
L148:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L303
    cmp     r13,r12
    jae     L149
    mov     rbp,r12
    sub     rbp,r13
    jmp     L150
L149:
    mov     rbp,r13
    sub     rbp,r12
L150:
    cmp     rdx,rbp
    setbe   dl
    jmp     L155
L151:
    test    r14b,r14b
    jne     L144
    cmp     r13,0
    je      L304
    jmp     L144
L152:
    test    r8b,r8b
    jne     L151
    jmp     L304
L153:
    test    r14b,r14b
    jne     L148
    cmp     r12,0
    je      L304
    jmp     L148
L154:
    test    r9b,r9b
    jne     L153
    jmp     L304
L155:
    test    dl,dl
    je      L304
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
L156:
    mov     r11,rbx
    add     r11,1
    mov     [rsp+0E8h],r11
    mov     r11,[rsp+10h]
    cmp     r11,[rsp+0E8h]
    jb      L346
    jmp     L259
L157:
    mov     r11,[rsp+10h]
    cmp     r11,0
    jne     L158
    mov     ebx,0
    jmp     L257
L158:
    mov     r11,[rsp+0A8h]
    cmp     r11,[rsp+10h]
    jae     L341
    lea     r11,[image.k4504]
    mov     [rsp+120h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L309
    mov     r11,[rsp+0A8h]
    cmp     r11,[rsp+10h]
    jae     L309
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0A8h]
    lea     r12,[r11+r10*4]
    lea     r13,[rsp+23Ch]
    lea     r11,[image.k488]
    mov     [rsp+0F0h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L160
L159:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L161
L160:
    cmp     r8d,1
    je      L159
    jmp     L310
L161:
    jmp     L170
L162:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L164
L163:
    mov     rbx,r13
    and     rbx,3
    cmp     rbx,0
    sete    bl
    jmp     L165
L164:
    cmp     r8d,1
    je      L163
    jmp     L311
L165:
    jmp     L172
L166:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L312
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L167
    mov     r14,r13
    sub     r14,[rsp+20h]
    jmp     L168
L167:
    mov     r14,[rsp+20h]
    sub     r14,r13
L168:
    cmp     r8,r14
    setbe   r8b
    jmp     L173
L169:
    test    bpl,bpl
    jne     L162
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L313
    jmp     L162
L170:
    test    r9b,r9b
    jne     L169
    jmp     L313
L171:
    test    bpl,bpl
    jne     L166
    cmp     r13,0
    je      L313
    jmp     L166
L172:
    test    bl,bl
    jne     L171
    jmp     L313
L173:
    test    r8b,r8b
    je      L313
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13d,0
    jmp     L175
L174:
    lea     rbx,[rsp+23Ch]
    jmp     L192
L175:
    lea     r11,[image.k512]
    mov     [rsp+100h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L177
L176:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L178
L177:
    cmp     r8d,1
    je      L176
    jmp     L315
L178:
    jmp     L184
L179:
    test    r13b,r13b
    je      L183
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L181
L180:
    mov     rbp,[rsp+20h]
    and     rbp,3
    cmp     rbp,0
    sete    bpl
    jmp     L182
L181:
    cmp     r8d,1
    je      L180
    jmp     L316
L182:
    jmp     L186
L183:
    cmp     r12,0
    je      L318
    jmp     L187
L184:
    test    r9b,r9b
    jne     L179
    jmp     L318
L185:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L318
    jmp     L191
L186:
    test    bpl,bpl
    jne     L191
    jmp     L318
L187:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L189
L188:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L190
L189:
    cmp     r8d,1
    je      L188
    jmp     L317
L190:
    test    r9b,r9b
    jne     L185
    jmp     L318
L191:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L174
L192:
    lea     r11,[image.k536]
    mov     [rsp+0F8h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L194
L193:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L195
L194:
    cmp     r8d,1
    je      L193
    jmp     L320
L195:
    jmp     L204
L196:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L198
L197:
    mov     r13,r12
    and     r13,3
    cmp     r13,0
    sete    r13b
    jmp     L199
L198:
    cmp     r8d,1
    je      L197
    jmp     L321
L199:
    jmp     L206
L200:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L322
    cmp     rbx,r12
    jae     L201
    mov     r14,r12
    sub     r14,rbx
    jmp     L202
L201:
    mov     r14,rbx
    sub     r14,r12
L202:
    cmp     r8,r14
    setbe   r8b
    jmp     L207
L203:
    test    bpl,bpl
    jne     L196
    cmp     rbx,0
    je      L323
    jmp     L196
L204:
    test    r9b,r9b
    jne     L203
    jmp     L323
L205:
    test    bpl,bpl
    jne     L200
    cmp     r12,0
    je      L323
    jmp     L200
L206:
    test    r13b,r13b
    jne     L205
    jmp     L323
L207:
    test    r8b,r8b
    je      L323
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r8,[image.k4528]
    lea     r9,[rsp+250h]
    mov     rdi,r9
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     ecx,1
    call    fn10
    mov     r8,[rsp+250h]
    mov     r11,[rsp+258h]
    mov     [rsp+108h],r11
    mov     rbx,[rsp+260h]
    mov     r12,[rsp+268h]
    mov     r11,[rsp+108h]
    cmp     r11,0
    jbe     L342
    mov     [rsp+268h],r8
    mov     [rsp+260h],r8
    mov     r13,[image.sym37]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r8
    mov     rcx,[rsp+18h]
    mov     rax,r13
    call    rax
    mov     rbx,rax
    cmp     rbx,[rsp+10h]
    jae     L343
    lea     r11,[image.k4576]
    mov     [rsp+118h],r11
    mov     r11d,0
    cmp     r11,[rsp+10h]
    jae     L325
    cmp     rbx,[rsp+10h]
    jae     L325
    mov     r11,[rsp+20h]
    lea     r12,[r11+rbx*4]
    lea     r13,[rsp+24Ch]
    lea     r11,[image.k488]
    mov     [rsp+110h],r11
    mov     ebp,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L209
L208:
    mov     r14,[rsp+20h]
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L210
L209:
    cmp     r9d,1
    je      L208
    jmp     L326
L210:
    jmp     L219
L211:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L213
L212:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L214
L213:
    cmp     r9d,1
    je      L212
    jmp     L327
L214:
    jmp     L221
L215:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L328
    mov     r11,[rsp+20h]
    cmp     r11,r13
    jae     L216
    mov     rdx,r13
    sub     rdx,[rsp+20h]
    jmp     L217
L216:
    mov     rdx,[rsp+20h]
    sub     rdx,r13
L217:
    cmp     r9,rdx
    setbe   dl
    jmp     L222
L218:
    test    bpl,bpl
    jne     L211
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L329
    jmp     L211
L219:
    test    r14b,r14b
    jne     L218
    jmp     L329
L220:
    test    bpl,bpl
    jne     L215
    cmp     r13,0
    je      L329
    jmp     L215
L221:
    test    r8b,r8b
    jne     L220
    jmp     L329
L222:
    test    dl,dl
    je      L329
    mov     rdi,r13
    mov     rsi,[rsp+20h]
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14d,0
    jmp     L224
L223:
    lea     r13,[rsp+24Ch]
    jmp     L241
L224:
    lea     r11,[image.k512]
    mov     [rsp+130h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L226
L225:
    mov     r8,r12
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L227
L226:
    cmp     edx,1
    je      L225
    jmp     L331
L227:
    jmp     L233
L228:
    test    r14b,r14b
    je      L232
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L230
L229:
    mov     r9,[rsp+20h]
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L231
L230:
    cmp     edx,1
    je      L229
    jmp     L332
L231:
    jmp     L235
L232:
    cmp     r12,0
    je      L334
    jmp     L236
L233:
    test    r8b,r8b
    jne     L228
    jmp     L334
L234:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L334
    jmp     L240
L235:
    test    r9b,r9b
    jne     L240
    jmp     L334
L236:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L238
L237:
    mov     r8,[rsp+20h]
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L239
L238:
    cmp     edx,1
    je      L237
    jmp     L333
L239:
    test    r8b,r8b
    jne     L234
    jmp     L334
L240:
    mov     rdi,[rsp+20h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L223
L241:
    lea     r11,[image.k536]
    mov     [rsp+128h],r11
    mov     r14d,0
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L243
L242:
    mov     r8,r13
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L244
L243:
    cmp     edx,1
    je      L242
    jmp     L336
L244:
    jmp     L253
L245:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    jmp     L247
L246:
    mov     r9,r12
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L248
L247:
    cmp     edx,1
    je      L246
    jmp     L337
L248:
    jmp     L255
L249:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,rax
    mov     rax,r11
    jb      L338
    cmp     r13,r12
    jae     L250
    mov     rbp,r12
    sub     rbp,r13
    jmp     L251
L250:
    mov     rbp,r13
    sub     rbp,r12
L251:
    cmp     rdx,rbp
    setbe   dl
    jmp     L256
L252:
    test    r14b,r14b
    jne     L245
    cmp     r13,0
    je      L339
    jmp     L245
L253:
    test    r8b,r8b
    jne     L252
    jmp     L339
L254:
    test    r14b,r14b
    jne     L249
    cmp     r12,0
    je      L339
    jmp     L249
L255:
    test    r9b,r9b
    jne     L254
    jmp     L339
L256:
    test    dl,dl
    je      L339
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
L257:
    lea     rdx,[k9]
    lea     r8,[rsp+2D8h]
    mov     rdi,r8
    mov     rsi,[rsp+20h]
    mov     rcx,rbx
    mov     r8,rdx
    mov     rdx,[rsp+10h]
    call    fn10
    mov     rbx,[rsp+2D8h]
    mov     r12,[rsp+2E0h]
    mov     rdx,[rsp+2E8h]
    mov     r8,[rsp+2F0h]
    lea     r9,[k11]
    lea     r13,[rsp+2C8h]
    mov     rdi,r13
    mov     rsi,rdx
    mov     rdx,r8
    mov     ecx,1
    mov     r8,r9
    call    fn10
    mov     rdx,[rsp+2C8h]
    mov     [rsp+2E8h],rdx
    mov     rdx,[rsp+2D0h]
    mov     [rsp+2F0h],rdx
    mov     r13,[rsp+2D8h]
    mov     r14,[rsp+2E0h]
    cmp     rdx,0
    jbe     L345
    mov     r8,[rsp+2E8h]
    mov     [rsp+2E0h],r8
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+18h]
    mov     ecx,ecx
    call    fn15
    mov     r8,[rsp+2E0h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+28h],r8
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    jmp     L0
L258:
    mov     rbx,[rsp+2C0h]
    mov     r12,[rsp+2B0h]
    mov     r13,[rsp+2A0h]
    mov     r14,[rsp+290h]
    mov     r15,[rsp+280h]
    mov     rbp,[rsp+270h]
    add     rsp,398h
    ret
L259:
    mov     r8,[rsp+10h]
    sub     r8,[rsp+0E8h]
    mov     r10,[rsp+20h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+2E8h],r10
    mov     r10,[rsp+20h]
    mov     [rsp+2D8h],r10
    mov     r11,[rsp+20h]
    mov     r10,[rsp+0E8h]
    lea     r9,[r11+r10*4]
    mov     [rsp+2D0h],r9
    mov     [rsp+2F0h],r9
    mov     rcx,[rsp+0A0h]
    mov     qword ptr [rsp+28h],0
    mov     [rsp+20h],r9
    mov     [rsp+10h],r8
    jmp     L0
    jmp     L261
    jmp     L261
    jmp     L261
L260:
    lea     r8,[image.k8338]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L261:
    call    image.sym10
    ud2
L262:
    lea     r8,[rsp+140h]
    mov     rdi,r8
    call    qword ptr [image.fn33.slot]
    jmp     L263
    jmp     L264
L263:
    mov     [rsp],rbx
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L262
L264:
    call    image.sym11
    ud2
L265:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L266:
    lea     r8,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,r8
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
    jmp     L268
L267:
    lea     r8,[image.k9686]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L268:
    call    image.sym10
    ud2
L269:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L270:
    lea     r8,[image.k7567]
    mov     rdi,r8
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L271:
    lea     rsi,[image.k7567]
    mov     rdi,rsi
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L272:
    lea     rcx,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     r10,rdi
    mov     rdi,rcx
    mov     rcx,r10
    movzx   edx,dl
    call    image.sym49
    ud2
L273:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L274:
    lea     rcx,[image.k7128]
    mov     rdi,rcx
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L275:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L276:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L277:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L279
    jmp     L279
L278:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L279:
    call    image.sym10
    ud2
L280:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L281:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L282:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L284
L283:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L284
L284:
    call    image.sym10
    ud2
L285:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L286:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L287:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L289
    jmp     L289
L288:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L289:
    call    image.sym10
    ud2
L290:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L291:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L292:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L293:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L295
    jmp     L295
L294:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L295:
    call    image.sym10
    ud2
L296:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L297:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L298:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L300
L299:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L300
L300:
    call    image.sym10
    ud2
L301:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L302:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L303:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L305
    jmp     L305
L304:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L305:
    call    image.sym10
    ud2
L306:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L307:
    lea     rax,[image.k4456]
    mov     edi,0
    mov     rsi,[rsp+0C0h]
    mov     rdx,rax
    call    sym5
    ud2
L308:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L309:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+120h]
    movzx   edx,dl
    call    image.sym49
    ud2
L310:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L311:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L312:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L314
    jmp     L314
L313:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L314:
    call    image.sym10
    ud2
L315:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L316:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L317:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L319
L318:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L319
L319:
    call    image.sym10
    ud2
L320:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L321:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L322:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L324
    jmp     L324
L323:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L324:
    call    image.sym10
    ud2
L325:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,[rsp+118h]
    movzx   edx,dl
    call    image.sym49
    ud2
L326:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L327:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L328:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L330
    jmp     L330
L329:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+110h]
    movzx   edx,dl
    call    image.sym49
    ud2
L330:
    call    image.sym10
    ud2
L331:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L332:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L333:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L335
L334:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+130h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L335
L335:
    call    image.sym10
    ud2
L336:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L337:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L338:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L340
    jmp     L340
L339:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+128h]
    movzx   edx,dl
    call    image.sym49
    ud2
L340:
    call    image.sym10
    ud2
L341:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L342:
    lea     rax,[image.k4552]
    mov     edi,0
    mov     rsi,[rsp+108h]
    mov     rdx,rax
    call    sym5
    ud2
L343:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L344:
    lea     rax,[k4]
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    sym5
    ud2
L345:
    lea     rax,[k13]
    mov     edi,0
    mov     rsi,rdx
    mov     rdx,rax
    call    sym5
    ud2
L346:
    lea     rax,[k16]
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    call    sym17
    ud2
L347:
    ud2
  ; OSR entries
    lea     r11,[L348]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L348:
    .long   L349
L349:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-3C0h]
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
    mov     [rdx-378h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-368h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-370h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-380h],r11
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
    call    sym1
    ud2

fn main::{closure#2}
    sub     rsp,18h
    mov     eax,[rsi]
    mov     eax,eax
    add     rsp,18h
    ret

fn merge_sort
    sub     rsp,208h
    mov     [rsp+170h],rbx
    mov     [rsp+160h],r12
    mov     [rsp+150h],r13
    mov     [rsp+140h],r14
    mov     [rsp+130h],r15
    mov     [rsp+120h],rbp
    mov     rbx,rdi
    mov     [rsp+30h],rsi
    mov     [rsp+40h],rdx
    mov     r11,[rsp+30h]
    cmp     r11,10h
    ja      L59
    mov     eax,1
    mov     rcx,[rsp+30h]
    mov     [rsp+180h],rax
    mov     [rsp+188h],rcx
    mov     r14,rbx
    mov     r15,[rsp+30h]
L0:
    mov     rax,[rsp+180h]
    mov     rcx,[rsp+188h]
    cmp     rax,rcx
    setb    al
    test    al,al
    je      L1
    mov     rax,[rsp+180h]
    lea     rcx,[image.k10584]
    mov     r11,rax
    add     r11,1
    jb      L161
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+180h],rdx
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
    .long   L160
    .long   L4
    .long   L212
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
    jb      L213
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+20h]
    jae     L214
    mov     r10,[rsp+48h]
    lea     rdx,[r14+r10*4]
    mov     edx,[rdx]
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L215
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
    jb      L216
    lea     rsi,[k10]
    cmp     rdx,[rsp+20h]
    jae     L178
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L179
    cmp     rdx,[rsp+20h]
    jae     L162
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L162
    lea     r15,[r14+rdx*4]
    mov     r10,[rsp+28h]
    lea     rbp,[r14+r10*4]
    lea     r12,[rsp+0DCh]
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
    jmp     L163
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
    jmp     L164
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
    jb      L165
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
    je      L166
    jmp     L13
L21:
    test    r8b,r8b
    jne     L20
    jmp     L166
L22:
    test    r13b,r13b
    jne     L17
    cmp     r12,0
    je      L166
    jmp     L17
L23:
    test    r9b,r9b
    jne     L22
    jmp     L166
L24:
    test    al,al
    je      L166
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13d,0
    jmp     L26
L25:
    lea     r12,[rsp+0DCh]
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
    jmp     L168
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
    jmp     L169
L33:
    jmp     L37
L34:
    cmp     rbp,0
    je      L171
    jmp     L38
L35:
    test    dil,dil
    jne     L30
    jmp     L171
L36:
    cmp     r15,0
    je      L171
    jmp     L42
L37:
    test    r8b,r8b
    jne     L42
    jmp     L171
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
    jmp     L170
L41:
    test    dil,dil
    jne     L36
    jmp     L171
L42:
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L25
L43:
    lea     r11,[image.k536]
    mov     [rsp+98h],r11
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
    jmp     L173
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
    jmp     L174
L50:
    jmp     L57
L51:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mov     edx,1
    mul     rdx
    mov     rdx,r10
    jb      L175
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
    je      L176
    jmp     L47
L55:
    test    dil,dil
    jne     L54
    jmp     L176
L56:
    test    r15b,r15b
    jne     L51
    cmp     rbp,0
    je      L176
    jmp     L51
L57:
    test    r8b,r8b
    jne     L56
    jmp     L176
L58:
    test    al,al
    je      L176
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rax,[rsp+28h]
    sub     rax,1
    jb      L217
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
    jb      L180
    jmp     L61
L60:
    mov     rdi,rbx
    mov     r8,[rsp+78h]
    jmp     L62
L61:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+78h]
    jb      L180
    jmp     L60
L62:
    mov     rsi,r8
    mov     rdx,[rsp+40h]
    call    fn18
    lea     r11,[k19]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+78h]
    jb      L181
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
    call    image.sym48
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
    jae     L218
    mov     r10,[rsp+68h]
    lea     r8,[rbp+r10*4]
    mov     r8d,[r8]
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L219
    mov     r10,[rsp+60h]
    lea     r9,[rbp+r10*4]
    mov     r9d,[r9]
    cmp     r9d,r8d
    jb      L70
    mov     r11,[rsp+68h]
    cmp     r11,[rsp+58h]
    jae     L220
    mov     r10,[rsp+68h]
    lea     r8,[rbp+r10*4]
    mov     ebx,[r8]
    mov     r14,[r15+10h]
    jmp     L68
L64:
    mov     r12,[r15]
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFEF0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+0F0h]
    mov     r9,[rsp+0F8h]
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,1
    mov     rcx,r8
    mov     r8,r9
    call    image.sym43
    mov     r8,rax
    mov     r9,rdx
    mov     [rsp+0E0h],r8
    mov     [rsp+0E8h],r9
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
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
    int3
    int3
L65:
    .long   L66
    .long   L182
    .long   L183
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
    jb      L221
    mov     [rsp+68h],r8
    jmp     L63
L70:
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jae     L222
    mov     r10,[rsp+60h]
    lea     r8,[rbp+r10*4]
    mov     ebx,[r8]
    mov     r12,[r15+10h]
    jmp     L75
L71:
    mov     r14,[r15]
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFF10h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+110h]
    mov     r9,[rsp+118h]
    mov     rdi,r15
    mov     rsi,r14
    mov     edx,1
    mov     rcx,r8
    mov     r8,r9
    call    image.sym43
    mov     r8,rax
    mov     r9,rdx
    mov     [rsp+100h],r8
    mov     [rsp+108h],r9
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
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
L72:
    .long   L73
    .long   L184
    .long   L185
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
    jb      L223
    mov     [rsp+60h],r8
    jmp     L63
L77:
    lea     r11,[k37]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+70h]
    cmp     r11,[rsp+68h]
    jb      L186
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
    jb      L186
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
    jb      L187
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
    jmp     L188
L86:
    jmp     L89
L87:
    jmp     L91
L88:
    cmp     rbx,0
    je      L189
    jmp     L90
L89:
    test    r14b,r14b
    jne     L88
    jmp     L189
L90:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r9,rax
    cmp     r12,r9
    jbe     L87
    jmp     L189
L91:
    mov     rdi,r15
    mov     rsi,r12
    call    qword ptr [image.fn171.slot]
    mov     r9,[r15+10h]
    cmp     r12,0
    jbe     L92
    mov     r14,[r15+8]
    lea     r14,[r14+r9*4]
    jmp     L93
L92:
    mov     r9,[r15+10h]
    add     r9,r12
    mov     [r15+10h],r9
    jmp     L111
L93:
    lea     r11,[image.k7104]
    mov     [rsp+90h],r11
    cmp     r12,0
    jne     L94
    mov     r13d,1
    jmp     L95
L94:
    mov     r13d,0
L95:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L97
L96:
    mov     r8,rbx
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L98
L97:
    cmp     r9d,1
    je      L96
    jmp     L191
L98:
    jmp     L107
L99:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    jmp     L101
L100:
    mov     rdi,r14
    and     rdi,3
    cmp     rdi,0
    sete    dil
    jmp     L102
L101:
    cmp     r9d,1
    je      L100
    jmp     L192
L102:
    jmp     L109
L103:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r12
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L193
    cmp     rbx,r14
    jae     L104
    mov     rax,r14
    sub     rax,rbx
    jmp     L105
L104:
    mov     rax,rbx
    sub     rax,r14
L105:
    cmp     r9,rax
    setbe   al
    jmp     L110
L106:
    test    r13b,r13b
    jne     L99
    cmp     rbx,0
    je      L194
    jmp     L99
L107:
    test    r8b,r8b
    jne     L106
    jmp     L194
L108:
    test    r13b,r13b
    jne     L103
    cmp     r14,0
    je      L194
    jmp     L103
L109:
    test    dil,dil
    jne     L108
    jmp     L194
L110:
    test    al,al
    je      L194
    mov     rax,r12
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L92
L111:
    lea     r11,[k40]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+60h]
    jb      L196
    mov     rdi,[rsp+58h]
    sub     rdi,[rsp+60h]
    mov     r10,[rsp+60h]
    lea     r8,[rbp+r10*4]
    mov     rbx,r8
    lea     rdi,[rbx+rdi*4]
    jmp     L113
L112:
    jmp     L114
L113:
    lea     r11,[image.k6656]
    mov     [rsp+0C8h],r11
    cmp     rdi,rbx
    jb      L197
    sub     rdi,rbx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    mov     r12,rdi
    jmp     L112
L114:
    lea     r11,[image.k6704]
    mov     [rsp+0C0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L116
L115:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L117
L116:
    cmp     edi,1
    je      L115
    jmp     L198
L117:
    jmp     L120
L118:
    jmp     L122
L119:
    cmp     rbx,0
    je      L199
    jmp     L121
L120:
    test    r9b,r9b
    jne     L119
    jmp     L199
L121:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rdi,rax
    cmp     r12,rdi
    jbe     L118
    jmp     L199
L122:
    mov     rdi,r15
    mov     rsi,r12
    call    qword ptr [image.fn171.slot]
    mov     rdi,[r15+10h]
    cmp     r12,0
    jbe     L123
    mov     r9,[r15+8]
    lea     r14,[r9+rdi*4]
    jmp     L124
L123:
    mov     rdi,[r15+10h]
    add     rdi,r12
    mov     [r15+10h],rdi
    jmp     L142
L124:
    lea     r11,[image.k7104]
    mov     [rsp+0B8h],r11
    cmp     r12,0
    jne     L125
    mov     r13d,1
    jmp     L126
L125:
    mov     r13d,0
L126:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L128
L127:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L129
L128:
    cmp     edi,1
    je      L127
    jmp     L201
L129:
    jmp     L138
L130:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    jmp     L132
L131:
    mov     r8,r14
    and     r8,3
    cmp     r8,0
    sete    r8b
    jmp     L133
L132:
    cmp     edi,1
    je      L131
    jmp     L202
L133:
    jmp     L140
L134:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r12
    mov     rdi,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L203
    cmp     rbx,r14
    jae     L135
    mov     rax,r14
    sub     rax,rbx
    jmp     L136
L135:
    mov     rax,rbx
    sub     rax,r14
L136:
    cmp     rdi,rax
    setbe   al
    jmp     L141
L137:
    test    r13b,r13b
    jne     L130
    cmp     rbx,0
    je      L204
    jmp     L130
L138:
    test    r9b,r9b
    jne     L137
    jmp     L204
L139:
    test    r13b,r13b
    jne     L134
    cmp     r14,0
    je      L204
    jmp     L134
L140:
    test    r8b,r8b
    jne     L139
    jmp     L204
L141:
    test    al,al
    je      L204
    mov     rax,r12
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L123
L142:
    mov     rax,[r15+8]
    mov     rdi,[r15+10h]
    mov     rbx,rax
    lea     rax,[k44]
    mov     r11,[rsp+58h]
    cmp     r11,rdi
    jne     L211
    lea     r12,[image.k560]
    mov     r11,[rsp+58h]
    cmp     r11,0
    jne     L143
    mov     r13d,1
    jmp     L144
L143:
    mov     r13d,0
L144:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L146
L145:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    sete    r9b
    jmp     L147
L146:
    cmp     r8d,1
    je      L145
    jmp     L206
L147:
    jmp     L156
L148:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r8,rax
    jmp     L150
L149:
    mov     r14,rbp
    and     r14,3
    cmp     r14,0
    sete    r14b
    jmp     L151
L150:
    cmp     r8d,1
    je      L149
    jmp     L207
L151:
    jmp     L158
L152:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     qword ptr [rsp+58h]
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L208
    cmp     rbx,rbp
    jae     L153
    mov     r15,rbp
    sub     r15,rbx
    jmp     L154
L153:
    mov     r15,rbx
    sub     r15,rbp
L154:
    cmp     r8,r15
    setbe   r8b
    jmp     L159
L155:
    test    r13b,r13b
    jne     L148
    cmp     rbx,0
    je      L209
    jmp     L148
L156:
    test    r9b,r9b
    jne     L155
    jmp     L209
L157:
    test    r13b,r13b
    jne     L152
    cmp     rbp,0
    je      L209
    jmp     L152
L158:
    test    r14b,r14b
    jne     L157
    jmp     L209
L159:
    test    r8b,r8b
    je      L209
    mov     r8,[rsp+58h]
    imul    r8,4
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r8
    call    ryo_hr_Memcpy
L160:
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+160h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+140h]
    mov     r15,[rsp+130h]
    mov     rbp,[rsp+120h]
    add     rsp,208h
    ret
L161:
    lea     r8,[image.k7768]
    mov     rdi,r8
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L162:
    lea     rcx,[image.k7128]
    mov     rdi,rcx
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1B5h
    movzx   edx,dl
    call    image.sym49
    ud2
L163:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L164:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L165:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L167
    jmp     L167
L166:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L167:
    call    image.sym10
    ud2
L168:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L169:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L170:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
    jmp     L172
L171:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L172
L172:
    call    image.sym10
    ud2
L173:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L174:
    lea     rcx,[image.k6432]
    lea     r8,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r8
    call    image.sym6
    ud2
L175:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L177
    jmp     L177
L176:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L177:
    call    image.sym10
    ud2
L178:
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,[rsp+20h]
    call    sym5
    ud2
L179:
    mov     rdi,[rsp+28h]
    mov     rdx,rsi
    mov     rsi,[rsp+20h]
    call    sym5
    ud2
L180:
    mov     edi,0
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+0B0h]
    call    image.sym31
    ud2
L181:
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+0A8h]
    call    image.sym31
    ud2
L182:
    mov     rcx,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     rdi,rcx
    mov     rsi,rdx
    call    image.sym44
    ud2
L183:
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    call    ryo_h_Resume
    ud2
L184:
    mov     rcx,[rsp+100h]
    mov     rdx,[rsp+108h]
    mov     rdi,rcx
    mov     rsi,rdx
    call    image.sym44
    ud2
L185:
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    call    ryo_h_Resume
    ud2
L186:
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+0A0h]
    call    image.sym31
    ud2
L187:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L188:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L190
L189:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L190:
    call    image.sym10
    ud2
L191:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L192:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L193:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L195
    jmp     L195
L194:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L195:
    call    image.sym10
    ud2
L196:
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+0D0h]
    call    image.sym31
    ud2
L197:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L198:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L200
L199:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L200:
    call    image.sym10
    ud2
L201:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L202:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L203:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L205
    jmp     L205
L204:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L205:
    call    image.sym10
    ud2
L206:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L207:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L208:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L210
    jmp     L210
L209:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L210:
    call    image.sym10
    ud2
L211:
    mov     rsi,rdi
    mov     rdi,[rsp+58h]
    mov     rdx,rax
    call    image.sym24
    ud2
L212:
    ud2
L213:
    lea     rax,[k2]
    mov     rdi,rax
    call    sym3
    ud2
L214:
    lea     rax,[k4]
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L215:
    lea     rax,[k6]
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L216:
    lea     rax,[k8]
    mov     rdi,rax
    call    sym3
    ud2
L217:
    lea     rax,[k12]
    mov     rdi,rax
    call    sym3
    ud2
L218:
    lea     rax,[k23]
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    sym5
    ud2
L219:
    lea     rax,[k25]
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    sym5
    ud2
L220:
    lea     rax,[k27]
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    sym5
    ud2
L221:
    lea     rax,[k30]
    mov     rdi,rax
    call    sym31
    ud2
L222:
    lea     rax,[k32]
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,rax
    call    sym5
    ud2
L223:
    lea     rax,[k35]
    mov     rdi,rax
    call    sym31
    ud2
  ; OSR entries
    lea     r11,[L224]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L224:
    .long   L225
    .long   L226
    .long   L227
L225:
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
    lea     rsp,[rsp+180h]
    jmp     L0
L226:
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
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1E0h],r11
    mov     r14,[rsp+8]
    lea     rsp,[rsp+190h]
    jmp     L5
L227:
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
    mov     [rdx-198h],r11
    mov     r11,[rsp+8]
    mov     [rdx-190h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1A8h],r11
    mov     rbp,[rsp+18h]
    mov     r15,[rsp+28h]
    lea     rsp,[rsp+1A0h]
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
    call    sym2
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
    call    sym2
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
    call    sym2
    jmp     L3
    call    sym6
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
    call    image.sym49
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
    call    sym3
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
    call    sym2
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
    call    image.sym6
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L19:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L23
L20:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L21:
    jmp     L20
    jmp     L23
L22:
    jmp     L20
L23:
    call    sym6
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
    call    image.sym6
    ud2
L19:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L20:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
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
    call    sym5
    ud2
L22:
    jmp     L21
L23:
    jmp     L21
L24:
    call    sym6
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
    call    image.sym6
    ud2
    jmp     L13
L11:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L12:
    jmp     L11
L13:
    call    sym4
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
    call    image.sym43
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
    int3
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
    call    image.sym44
    ud2
L7:
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2

fn std::vec::Vec::<u32>::reserve
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+18h]
    cmp     rax,0
    je      L3
    jmp     L4
L0:
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r12
    mov     r8,rcx
    mov     rcx,rax
    call    sym1
L1:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    add     rsp,58h
    ret
L2:
    sub     rax,r13
    cmp     rax,r12
    jb      L0
    jmp     L1
L3:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L2
L4:
    mov     rax,[rbx]
    jmp     L2
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

