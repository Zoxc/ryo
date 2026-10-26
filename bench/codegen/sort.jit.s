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
    xor     rcx,rax
    add     rsi,rcx
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
    ud2
    mov     [rsp],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
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

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+48h],rsi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rsi,[rdx+10h]
    mov     rdx,[rdx+18h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rcx
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
L0:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    cmp     rax,rcx
    jae     L1
    lea     rcx,[rax+1]
    mov     [rsp+40h],rcx
    mov     rcx,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
L2:
    test    rax,rax
    je      L3
    lea     rax,[rsp+20h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    jmp     L0
L3:
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     [rcx],rax
    add     rsp,58h
    ret
    mov     [rsp+10h],rax
    jmp     L6
L4:
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L5
    jmp     L7
L5:
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L6:
    jmp     L4
L7:
    call    sym4
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
L9:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-80h]
    lea     rsp,[rsp+30h]
    jmp     L0
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

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,58h
    mov     [rsp+20h],rbx
    mov     [rsp+18h],r12
    mov     [rsp+10h],r13
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rdx,[rdx+10h]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rdx
    cmp     rdi,rsi
    jne     L0
    mov     [rax],rcx
    jmp     L3
L0:
    lea     rax,[k4]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    shr     rsi,2
    jmp     L4
L1:
    lea     rcx,[rsp+28h]
    lea     rdx,[rbx+r12*4]
    mov     rdi,rcx
    mov     rsi,rdx
    call    fn1
    lea     rcx,[k9]
    mov     r11,r12
    add     r11,1
    jb      L7
    add     r12,1
    cmp     r12,r13
    jne     L5
    mov     rdx,[rsp+30h]
    mov     r8,[rsp+28h]
    mov     [r8],rdx
    jmp     L3
L2:
    mov     rbx,rdx
    mov     r12,r8
    mov     r13,r9
    jmp     L1
L3:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+10h]
    add     rsp,58h
    ret
L4:
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
    jmp     L1
L5:
    mov     rdx,rbx
    mov     r8,r12
    mov     r9,r13
    jmp     L2
L6:
    lea     rdx,[image.k7567]
    mov     rdi,rdx
    mov     esi,193h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L7:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    jmp     L10
L8:
    lea     rax,[rsp+28h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L11
    jmp     L12
L9:
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L10:
    jmp     L8
L11:
    jmp     L9
L12:
    call    sym11
    ud2
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
    .long   L22
    .long   L23
    .long   L24
L14:
    pop     rcx
    lea     rdx,[rsp+0C0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-48h]
    mov     [rsp+10h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-38h],r12
    mov     [rdx-40h],r13
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+90h]
    jmp     L1
L15:
    ret
L16:
    pop     rcx
    lea     rdx,[rsp+0C0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-48h]
    mov     [rsp+10h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-38h],r12
    mov     [rdx-40h],r13
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+90h]
    jmp     L2
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

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+30h],rbx
    mov     [rsp+28h],r12
    mov     [rsp+20h],r13
    mov     [rsp+18h],r14
    mov     [rsp+10h],r15
    mov     [rsp+8],rbp
    mov     [rsp+38h],rcx
    cmp     rdi,rsi
    jne     L0
    mov     r9,rdx
    jmp     L3
L0:
    lea     rax,[k1]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    shr     rsi,2
    jmp     L4
L1:
    lea     r8,[rsp+38h]
    lea     r9,[rbx+r12*4]
    mov     rdi,r8
    mov     rsi,rcx
    mov     rdx,r9
    call    fn0
    mov     rcx,rax
    lea     r8,[k6]
    mov     r11,r12
    add     r11,1
    jb      L7
    add     r12,1
    cmp     r12,r13
    jne     L5
    mov     r9,rcx
    jmp     L3
L2:
    mov     rcx,r9
    mov     rbx,r14
    mov     r12,r15
    mov     r13,rbp
    jmp     L1
L3:
    mov     rax,r9
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+8]
    add     rsp,68h
    ret
L4:
    mov     rcx,rdx
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
    jmp     L1
L5:
    mov     r9,rcx
    mov     r14,rbx
    mov     r15,r12
    mov     rbp,r13
    jmp     L2
L6:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L7:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L9
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L8
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
    .long   L17
    .long   L18
    .long   L19
L11:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-38h],r12
    mov     [rdx-40h],r13
    mov     [rdx-48h],r14
    mov     [rdx-50h],r15
    mov     [rdx-58h],rbp
    mov     rcx,[rsp]
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    lea     rsp,[rsp+0A0h]
    jmp     L1
L12:
    ret
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-100h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
    mov     [rsp+8],r11
    mov     r11,[rdx-40h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    mov     [rdx-30h],rbx
    mov     [rdx-38h],r12
    mov     [rdx-40h],r13
    mov     [rdx-48h],r14
    mov     [rdx-50h],r15
    mov     [rdx-58h],rbp
    mov     r9,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+0A0h]
    jmp     L2
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
    push    rbx
    push    r12
    sub     rsp,8
    cmp     rdx,rcx
    jb      L6
    lea     rax,[k0]
    mov     r9,rsi
    and     r9,3
    test    r9,r9
    je      L1
    jmp     L4
L0:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rcx,r10
    ja      L4
    lea     r9,[rsi+rcx*4]
    mov     rbx,rdx
    sub     rbx,rcx
    mov     r12,r9
    and     r12,3
    test    r12,r12
    je      L3
    jmp     L5
L1:
    test    rsi,rsi
    je      L4
    jmp     L0
L2:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rbx,r10
    ja      L5
    mov     [rdi],rsi
    mov     [rdi+8],rcx
    mov     [rdi+10h],r9
    mov     [rdi+18h],rbx
    mov     rax,rdi
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L3:
    test    r9,r9
    je      L5
    jmp     L2
L4:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L5:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rax,[k2]
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,r8
    call    sym4
    ud2

fn core::slice::<impl [u32]>::swap
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,18h
    cmp     rdx,rsi
    jae     L15
    cmp     rcx,rsi
    jae     L16
    lea     rax,[rdi+rdx*4]
    lea     rdi,[rdi+rcx*4]
    lea     r9,[rsp+0Ch]
    lea     rbx,[image.k488]
    mov     r12,rax
    and     r12,3
    test    r12,r12
    je      L4
    jmp     L12
L0:
    mov     r12,r9
    and     r12,3
    test    r12,r12
    je      L5
    jmp     L12
L1:
    cmp     rax,r9
    jae     L2
    mov     r12,r9
    sub     r12,rax
    jmp     L3
L2:
    mov     r12,rax
    sub     r12,r9
L3:
    cmp     r12,4
    jb      L12
    mov     r12d,[rax]
    mov     [rsp+0Ch],r12d
    lea     r12,[image.k512]
    mov     r13,rdi
    and     r13,3
    test    r13,r13
    je      L7
    jmp     L13
L4:
    test    rax,rax
    je      L12
    jmp     L0
L5:
    test    r9,r9
    je      L12
    jmp     L1
L6:
    mov     r9d,[rdi]
    mov     [rax],r9d
    lea     r9,[rsp+0Ch]
    lea     r13,[image.k536]
    mov     r14,r9
    and     r14,3
    test    r14,r14
    je      L11
    jmp     L14
L7:
    test    rdi,rdi
    je      L13
    mov     r14,rax
    and     r14,3
    test    r14,r14
    je      L6
    jmp     L13
L8:
    mov     rax,rdi
    and     rax,3
    test    rax,rax
    jne     L14
    cmp     r9,rdi
    jae     L9
    mov     rax,rdi
    sub     rax,r9
    jmp     L10
L9:
    mov     rax,r9
    sub     rax,rdi
L10:
    cmp     rax,4
    jb      L14
    mov     eax,[rsp+0Ch]
    mov     [rdi],eax
    add     rsp,18h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L11:
    test    r9,r9
    je      L14
    jmp     L8
L12:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    mov     rdi,rdx
    mov     rdx,r8
    call    sym0
    ud2
L16:
    mov     rdi,rcx
    mov     rdx,r8
    call    sym0
    ud2

fn core::slice::<impl [u32]>::swap_unchecked
    push    rbx
    sub     rsp,10h
    cmp     rdx,rsi
    jae     L12
    cmp     rcx,rsi
    jae     L12
    lea     rax,[rdi+rdx*4]
    lea     rdi,[rdi+rcx*4]
    lea     rcx,[rsp+0Ch]
    lea     rdx,[image.k488]
    mov     rsi,rax
    and     rsi,3
    test    rsi,rsi
    je      L4
    jmp     L13
L0:
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L5
    jmp     L13
L1:
    cmp     rax,rcx
    jae     L2
    mov     rsi,rcx
    sub     rsi,rax
    jmp     L3
L2:
    mov     rsi,rax
    sub     rsi,rcx
L3:
    cmp     rsi,4
    jb      L13
    mov     esi,[rax]
    mov     [rsp+0Ch],esi
    lea     rsi,[image.k512]
    mov     r9,rdi
    and     r9,3
    test    r9,r9
    je      L7
    jmp     L14
L4:
    test    rax,rax
    je      L13
    jmp     L0
L5:
    test    rcx,rcx
    je      L13
    jmp     L1
L6:
    mov     ecx,[rdi]
    mov     [rax],ecx
    lea     rcx,[rsp+0Ch]
    lea     r9,[image.k536]
    mov     rbx,rcx
    and     rbx,3
    test    rbx,rbx
    je      L11
    jmp     L15
L7:
    test    rdi,rdi
    je      L14
    mov     rbx,rax
    and     rbx,3
    test    rbx,rbx
    je      L6
    jmp     L14
L8:
    mov     rax,rdi
    and     rax,3
    test    rax,rax
    jne     L15
    cmp     rcx,rdi
    jae     L9
    mov     rax,rdi
    sub     rax,rcx
    jmp     L10
L9:
    mov     rax,rcx
    sub     rax,rdi
L10:
    cmp     rax,4
    jb      L15
    mov     eax,[rsp+0Ch]
    mov     [rdi],eax
    add     rsp,10h
    pop     rbx
    ret
L11:
    test    rcx,rcx
    je      L15
    jmp     L8
L12:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     r13,rdx
    mov     r11,[rsp+10h]
    cmp     r11,8
    jb      L13
    mov     rax,[rsp+10h]
    shr     rax,3
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
    mov     r11,[r13]
    mov     r11,[rsp+18h]
    mov     ecx,[r11]
    mov     edx,[r14]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r15]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L1
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L0
    mov     rcx,r15
    jmp     L2
L0:
    mov     rcx,r14
    jmp     L2
L1:
    mov     rcx,[rsp+18h]
L2:
    lea     rdx,[k2]
    cmp     rcx,[rsp+18h]
    jb      L10
    sub     rcx,[rsp+18h]
    shr     rcx,3
    jmp     L8
L3:
    mov     rbp,rax
    shr     rbp,3
    mov     r12,rbp
    imul    r12,4
    mov     r11,[rsp+18h]
    lea     rax,[r11+r12*8]
    mov     rbx,rbp
    imul    rbx,7
    mov     r11,[rsp+18h]
    lea     rsi,[r11+rbx*8]
    mov     rdi,[rsp+18h]
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,r13
    call    fn1
    mov     [rsp+20h],rax
    lea     rax,[r14+r12*8]
    lea     rsi,[r14+rbx*8]
    mov     rdi,r14
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,r13
    call    fn1
    mov     r14,rax
    lea     rax,[r15+r12*8]
    lea     rsi,[r15+rbx*8]
    mov     rdi,r15
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,r13
    call    fn1
    mov     r11,[r13]
    mov     r11,[rsp+20h]
    mov     esi,[r11]
    mov     edi,[r14]
    cmp     esi,edi
    setb    r8b
    mov     r9d,[rax]
    cmp     esi,r9d
    setb    sil
    cmp     r8b,sil
    jne     L5
    cmp     edi,r9d
    setb    sil
    xor     esi,r8d
    test    sil,sil
    je      L4
    jmp     L6
L4:
    mov     rax,r14
    jmp     L6
L5:
    mov     rax,[rsp+20h]
L6:
    lea     rsi,[k7]
    cmp     rax,[rsp+18h]
    jb      L11
    sub     rax,[rsp+18h]
    shr     rax,3
    jmp     L9
L7:
    cmp     rdi,[rsp+10h]
    setb    r8b
    lea     r9,[k12]
    test    r8b,r8b
    je      L12
    mov     rax,rdi
    add     rsp,28h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L8:
    mov     rdi,rcx
    jmp     L7
L9:
    mov     rdi,rax
    jmp     L7
L10:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L11:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L12:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
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
L15:
    ret
L16:
    ret
L17:
    ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,18h
    mov     eax,[rdi]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    r8b
    mov     r9d,[rdx]
    cmp     eax,r9d
    setb    al
    cmp     r8b,al
    jne     L1
    cmp     ecx,r9d
    setb    al
    xor     eax,r8d
    test    al,al
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
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rsi
    mov     r12,rdx
    mov     [rsp+10h],r8
    mov     rax,rcx
    imul    rax,8
    cmp     rax,40h
    jb      L0
    mov     r14,rcx
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    lea     rax,[rdi+r15*8]
    mov     rbp,r14
    imul    rbp,7
    lea     rcx,[rdi+rbp*8]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+10h]
    call    fn0
    mov     r13,rax
    lea     rax,[rbx+r15*8]
    lea     rcx,[rbx+rbp*8]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+10h]
    call    fn0
    mov     rbx,rax
    lea     rax,[r12+r15*8]
    lea     rcx,[r12+rbp*8]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+10h]
    call    fn0
    mov     rdi,r13
    mov     r12,rax
L0:
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     eax,[rdi]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    dl
    mov     esi,[r12]
    cmp     eax,esi
    setb    al
    cmp     dl,al
    jne     L2
    cmp     ecx,esi
    setb    al
    xor     eax,edx
    test    al,al
    je      L1
    jmp     L3
L1:
    mov     r12,rbx
    jmp     L3
L2:
    mov     r12,rdi
L3:
    mov     rax,r12
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rsi
    mov     r12,rdx
    mov     r13,r8
    mov     rax,rcx
    imul    rax,8
    cmp     rax,40h
    jb      L0
    mov     r14,rcx
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    lea     rax,[rdi+r15*4]
    mov     rbp,r14
    imul    rbp,7
    lea     rcx,[rdi+rbp*4]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     [rsp+10h],rax
    lea     rax,[rbx+r15*4]
    lea     rcx,[rbx+rbp*4]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     rbx,rax
    lea     rax,[r12+r15*4]
    lea     rcx,[r12+rbp*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     rdi,[rsp+10h]
    mov     r12,rax
L0:
    mov     eax,[rdi]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    dl
    mov     esi,[r12]
    cmp     eax,esi
    setb    al
    cmp     dl,al
    jne     L2
    cmp     ecx,esi
    setb    al
    xor     eax,edx
    test    al,al
    je      L1
    jmp     L3
L1:
    mov     r12,rbx
    jmp     L3
L2:
    mov     r12,rdi
L3:
    mov     rax,r12
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,148h
    mov     [rsp+88h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+78h],r13
    mov     [rsp+70h],r14
    mov     [rsp+68h],r15
    mov     [rsp+60h],rbp
    mov     [rsp+0A0h],rdi
    mov     rax,rsi
    shr     rax,1
    test    rax,rax
    setne   cl
    mov     [rsp+0A7h],cl
    lea     rcx,[rdi+rax*4]
    lea     r8,[rax-1]
    mov     [rsp+0A0h],r8
    lea     r8,[rdi+r8*4]
    lea     r9,[rsi-1]
    lea     rbx,[rdi+r9*4]
    mov     [rsp+0A0h],rdx
    lea     r9,[rdx+r9*4]
    mov     [rsp+48h],r8
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rcx
    mov     rcx,rax
    mov     eax,0
    mov     [rsp+18h],rdx
    mov     [rsp+38h],rbx
    mov     [rsp+30h],rsi
L0:
    mov     [rsp+98h],rax
    mov     [rsp+90h],rcx
    cmp     rax,rcx
    setb    r13b
    mov     [rsp+0A7h],r13b
    test    r13b,r13b
    je      L29
    mov     [rsp+98h],rax
    add     rax,1
    mov     [rsp+90h],rax
    mov     r11,[rsp+20h]
    mov     r13d,[r11]
    mov     r11,[rsp+28h]
    mov     r14d,[r11]
    cmp     r13d,r14d
    setb    r13b
    mov     r14,r13
    xor     r14d,1
    cmp     r13b,1
    je      L1
    mov     r15,[rsp+28h]
    jmp     L2
L1:
    mov     r15,[rsp+20h]
L2:
    lea     r11,[image.k2712]
    mov     [rsp+10h],r11
    mov     rbp,r15
    and     rbp,3
    test    rbp,rbp
    je      L7
    jmp     L30
L3:
    mov     rbp,[rsp+18h]
    and     rbp,3
    test    rbp,rbp
    je      L8
    jmp     L30
L4:
    cmp     r15,[rsp+18h]
    jae     L5
    mov     rbp,[rsp+18h]
    sub     rbp,r15
    jmp     L6
L5:
    mov     rbp,r15
    sub     rbp,[rsp+18h]
L6:
    cmp     rbp,4
    jb      L30
    mov     ebp,[r15]
    mov     r11,[rsp+18h]
    mov     [r11],ebp
    movzx   ebp,r13b
    mov     r11,[rsp+20h]
    lea     rbp,[r11+rbp*4]
    movzx   esi,r14b
    mov     r11,[rsp+28h]
    lea     rsi,[r11+rsi*4]
    mov     rdx,[rsp+18h]
    lea     rdx,[rdx+4]
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rbp
    mov     [rsp+0A0h],rdx
    mov     rdx,rax
    mov     rax,[rsp+48h]
    mov     rsi,rcx
    mov     rcx,[rsp+38h]
    mov     r13,[rsp+30h]
    jmp     L9
L7:
    test    r15,r15
    je      L30
    jmp     L3
L8:
    mov     r11,[rsp+18h]
    cmp     r11,0
    je      L30
    jmp     L4
L9:
    mov     r14,[rsp+90h]
    mov     r15,[rsp+98h]
    mov     rbp,[rsp+0A0h]
    mov     edi,[rcx]
    mov     r12d,[rax]
    cmp     edi,r12d
    setb    dil
    mov     r11,rdi
    xor     r11d,1
    mov     [rsp+58h],r11
    cmp     dil,1
    je      L10
    mov     [rsp+50h],rcx
    jmp     L11
L10:
    mov     [rsp+50h],rax
L11:
    lea     r11,[image.k1680]
    mov     [rsp+40h],r11
    mov     r8,[rsp+50h]
    and     r8,3
    test    r8,r8
    je      L16
    jmp     L31
L12:
    mov     r8,r9
    and     r8,3
    test    r8,r8
    je      L17
    jmp     L31
L13:
    mov     r11,[rsp+50h]
    cmp     r11,r9
    jae     L14
    mov     r8,r9
    sub     r8,[rsp+50h]
    jmp     L15
L14:
    mov     r8,[rsp+50h]
    sub     r8,r9
L15:
    cmp     r8,4
    jb      L31
    mov     r11,[rsp+50h]
    mov     r8d,[r11]
    mov     [r9],r8d
    movzx   r8d,byte ptr [rsp+58h]
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     r8,[rcx+r8*4]
    movzx   ebx,dil
    mov     r11d,0
    sub     r11,rbx
    mov     rbx,r11
    lea     rbx,[rax+rbx*4]
    mov     r12,r9
    lea     r12,[r12-4]
    mov     [rsp+90h],rbx
    mov     [rsp+98h],r8
    mov     [rsp+0A0h],r12
    mov     rax,rdx
    mov     rcx,rsi
    mov     [rsp+48h],rbx
    mov     [rsp+28h],r14
    mov     [rsp+20h],r15
    mov     [rsp+18h],rbp
    mov     [rsp+38h],r8
    mov     r9,r12
    mov     [rsp+30h],r13
    jmp     L0
L16:
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L31
    jmp     L12
L17:
    test    r9,r9
    je      L31
    jmp     L13
L18:
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    jmp     L28
L19:
    mov     r11,[rsp+28h]
    cmp     r11,rax
    setb    cl
    mov     [rsp+96h],cl
    test    cl,cl
    je      L20
    mov     rcx,[rsp+28h]
    jmp     L21
L20:
    mov     rcx,[rsp+20h]
L21:
    lea     rdx,[k5]
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L26
    jmp     L32
L22:
    mov     rsi,[rsp+18h]
    and     rsi,3
    test    rsi,rsi
    je      L27
    jmp     L32
L23:
    cmp     rcx,[rsp+18h]
    jae     L24
    mov     rsi,[rsp+18h]
    sub     rsi,rcx
    jmp     L25
L24:
    mov     rsi,rcx
    sub     rsi,[rsp+18h]
L25:
    cmp     rsi,4
    jb      L32
    mov     esi,[rcx]
    mov     r11,[rsp+18h]
    mov     [r11],esi
    movzx   esi,byte ptr [rsp+96h]
    mov     rdi,rsi
    mov     r11,[rsp+28h]
    lea     rdi,[r11+rdi*4]
    xor     esi,1
    mov     [rsp+95h],sil
    movzx   esi,sil
    mov     r11,[rsp+20h]
    lea     rsi,[r11+rsi*4]
    jmp     L28
L26:
    test    rcx,rcx
    je      L32
    jmp     L22
L27:
    mov     r11,[rsp+18h]
    cmp     r11,0
    je      L32
    jmp     L23
L28:
    mov     rcx,[rsp+0A0h]
    cmp     rdi,rcx
    jne     L33
    mov     rcx,[rsp+98h]
    cmp     rsi,rcx
    jne     L33
    mov     rbx,[rsp+88h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+78h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+68h]
    mov     rbp,[rsp+60h]
    add     rsp,148h
    ret
L29:
    mov     rax,[rsp+48h]
    lea     rax,[rax+4]
    mov     [rsp+0A0h],rax
    mov     rcx,[rsp+38h]
    lea     rcx,[rcx+4]
    mov     [rsp+98h],rcx
    mov     rcx,[rsp+30h]
    and     rcx,1
    test    rcx,rcx
    sete    cl
    mov     [rsp+97h],cl
    test    cl,cl
    jne     L18
    jmp     L19
L30:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L31:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L32:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
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
    lea     rsp,[rdx-190h]
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
    mov     r11,[rdx-60h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-68h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+40h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-118h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-110h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r9,[rsp+38h]
    lea     rsp,[rsp+50h]
    jmp     L0
L36:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-170h]
    mov     r11,[rdx-58h]
    mov     [rsp],r11
    mov     r11,[rdx-60h]
    mov     [rsp+8],r11
    mov     r11,[rdx-68h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+28h],r11
    mov     [rdx-0B8h],rbx
    mov     [rdx-0C0h],r12
    mov     [rdx-0C8h],r13
    mov     [rdx-0D0h],r14
    mov     [rdx-0D8h],r15
    mov     [rdx-0E0h],rbp
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     r13,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+30h]
    jmp     L9
L37:
    ret
L38:
    ret
L39:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     [rsp+30h],rbx
    mov     [rsp+28h],r12
    mov     [rsp+20h],r13
    mov     [rsp+18h],r14
    mov     [rsp+10h],r15
    mov     [rsp+8],rbp
    mov     rax,rsi
    lea     rax,[rax-4]
    jmp     L21
L0:
    test    cl,cl
    je      L20
    mov     edx,[rsi]
    mov     [rsp+3Ch],edx
    lea     rdx,[rsp+3Ch]
    mov     r8,rdi
    mov     r9,rsi
    mov     rbx,rdx
    mov     rdx,rax
L1:
    lea     r12,[k3]
    mov     r13,rdx
    and     r13,3
    test    r13,r13
    je      L6
    jmp     L24
L2:
    mov     r13,r9
    and     r13,3
    test    r13,r13
    je      L7
    jmp     L24
L3:
    cmp     rdx,r9
    jae     L4
    mov     r13,r9
    sub     r13,rdx
    jmp     L5
L4:
    mov     r13,rdx
    sub     r13,r9
L5:
    cmp     r13,4
    jb      L24
    mov     r13d,[rdx]
    mov     [r9],r13d
    cmp     rdx,r8
    je      L8
    jmp     L22
L6:
    test    rdx,rdx
    je      L24
    jmp     L2
L7:
    test    r9,r9
    je      L24
    jmp     L3
L8:
    mov     r9,rbx
    mov     r13,rdx
    jmp     L13
L9:
    mov     r15,r9
    lea     r15,[r15-4]
    mov     rax,r14
    jmp     L23
L10:
    test    r9b,r9b
    jne     L12
    jmp     L11
L11:
    mov     r9,rbp
    mov     r13,r15
    jmp     L13
L12:
    mov     rdx,r13
    mov     r8,r14
    mov     r9,r15
    mov     rbx,rbp
    jmp     L1
L13:
    lea     r14,[image.k10520]
    mov     r15,r9
    and     r15,3
    test    r15,r15
    je      L18
    jmp     L25
L14:
    mov     r15,r13
    and     r15,3
    test    r15,r15
    je      L19
    jmp     L25
L15:
    cmp     r9,r13
    jae     L16
    mov     r15,r13
    sub     r15,r9
    jmp     L17
L16:
    mov     r15,r9
    sub     r15,r13
L17:
    mov     r11d,4
    cmp     r11,r15
    ja      L25
    mov     r15d,[r9]
    mov     [r13],r15d
    jmp     L20
L18:
    test    r9,r9
    je      L25
    jmp     L14
L19:
    test    r13,r13
    je      L25
    jmp     L15
L20:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+8]
    add     rsp,88h
    ret
L21:
    mov     r9d,[rsi]
    mov     r13d,[rsi-4]
    cmp     r9d,r13d
    setb    cl
    mov     [rsp+3Fh],cl
    jmp     L0
L22:
    mov     r9,rdx
    mov     r13,r8
    mov     r14,rbx
    jmp     L9
L23:
    mov     ecx,[rsp+3Ch]
    mov     edx,[r15]
    cmp     ecx,edx
    setb    cl
    mov     r14,r13
    mov     r13,r15
    mov     r15,r9
    mov     r9,rcx
    mov     rbp,rax
    jmp     L10
L24:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
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
    .long   L30
    .long   L31
    .long   L32
    .long   L33
    .long   L34
    .long   L35
L27:
    ret
L28:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+18h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-58h],r12
    mov     [rdx-60h],r13
    mov     [rdx-68h],r14
    mov     [rdx-70h],r15
    mov     [rdx-78h],rbp
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L1
L29:
    ret
L30:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-60h]
    mov     [rsp+10h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-58h],r12
    mov     [rdx-60h],r13
    mov     [rdx-68h],r14
    mov     [rdx-70h],r15
    mov     [rdx-78h],rbp
    mov     r9,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L9
L31:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
    movzx   r11d,byte ptr [rdx-45h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+20h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-58h],r12
    mov     [rdx-60h],r13
    mov     [rdx-68h],r14
    mov     [rdx-70h],r15
    mov     [rdx-78h],rbp
    mov     r9,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L10
L32:
    ret
L33:
    ret
L34:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0C0h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+18h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-58h],r12
    mov     [rdx-60h],r13
    mov     [rdx-68h],r14
    mov     [rdx-70h],r15
    mov     [rdx-78h],rbp
    mov     r15,[rsp]
    mov     r13,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rax,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L23
L35:
    ret

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,8
    mov     eax,[rdx]
    mov     r8d,[rsi]
    cmp     eax,r8d
    setb    al
    mov     r8,rax
    xor     r8d,1
    cmp     al,1
    je      L0
    mov     r9,rdx
    jmp     L1
L0:
    mov     r9,rsi
L1:
    lea     rbx,[k1]
    mov     r12,r9
    and     r12,3
    test    r12,r12
    je      L6
    jmp     L9
L2:
    mov     r12,rcx
    and     r12,3
    test    r12,r12
    je      L7
    jmp     L9
L3:
    cmp     r9,rcx
    jae     L4
    mov     r12,rcx
    sub     r12,r9
    jmp     L5
L4:
    mov     r12,r9
    sub     r12,rcx
L5:
    cmp     r12,4
    jb      L9
    mov     r12d,[r9]
    mov     [rcx],r12d
    movzx   r12d,r8b
    mov     r11d,0
    sub     r11,r12
    mov     r12,r11
    lea     r12,[rdx+r12*4]
    movzx   r13d,al
    mov     r11d,0
    sub     r11,r13
    mov     r13,r11
    lea     r13,[rsi+r13*4]
    mov     r14,rcx
    lea     r14,[r14-4]
    jmp     L8
L6:
    test    r9,r9
    je      L9
    jmp     L2
L7:
    test    rcx,rcx
    je      L9
    jmp     L3
L8:
    mov     [rdi],r13
    mov     [rdi+8],r12
    mov     [rdi+10h],r14
    mov     rax,rdi
    add     rsp,8
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L9:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
L11:
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    sub     rsp,8
    mov     eax,[rdx]
    mov     r8d,[rsi]
    cmp     eax,r8d
    setb    al
    mov     r8,rax
    xor     r8d,1
    cmp     al,1
    je      L0
    mov     r9,rsi
    jmp     L1
L0:
    mov     r9,rdx
L1:
    lea     rbx,[k1]
    mov     r12,r9
    and     r12,3
    test    r12,r12
    je      L6
    jmp     L8
L2:
    mov     r12,rcx
    and     r12,3
    test    r12,r12
    je      L7
    jmp     L8
L3:
    cmp     r9,rcx
    jae     L4
    mov     r12,rcx
    sub     r12,r9
    jmp     L5
L4:
    mov     r12,r9
    sub     r12,rcx
L5:
    cmp     r12,4
    jb      L8
    mov     r12d,[r9]
    mov     [rcx],r12d
    movzx   r12d,al
    lea     r12,[rdx+r12*4]
    movzx   r13d,r8b
    lea     r13,[rsi+r13*4]
    mov     r14,rcx
    lea     r14,[r14+4]
    mov     [rdi],r13
    mov     [rdi+8],r12
    mov     [rdi+10h],r14
    mov     rax,rdi
    add     rsp,8
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L6:
    test    r9,r9
    je      L8
    jmp     L2
L7:
    test    rcx,rcx
    jne     L3
L8:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,4C8h
    mov     [rsp+3A8h],rbx
    mov     [rsp+3A0h],r12
    mov     [rsp+398h],r13
    mov     [rsp+390h],r14
    mov     [rsp+388h],r15
    mov     [rsp+380h],rbp
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+40h],rdx
    mov     [rsp+38h],r8
    mov     r11,[rsp+48h]
    cmp     r11,2
    jb      L56
    mov     rax,[rsp+48h]
    add     rax,10h
    cmp     rcx,rax
    jb      L71
    mov     r11,[rsp+48h]
    shr     r11,1
    mov     [rsp+30h],r11
    mov     r11,[rsp+48h]
    cmp     r11,10h
    jb      L0
    mov     r11,[rsp+40h]
    mov     r10,[rsp+48h]
    lea     rax,[r11+r10*8]
    mov     [rsp+360h],rax
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,rax
    mov     rcx,[rsp+38h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*8]
    mov     [rsp+360h],rax
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+358h],rcx
    mov     rdx,[rsp+48h]
    add     rdx,8
    mov     [rsp+3C8h],rdx
    mov     r11,[rsp+40h]
    lea     rdx,[r11+rdx*8]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+38h]
    call    qword ptr [fn0.slot]
    mov     r12d,8
    jmp     L38
L0:
    mov     r11,[rsp+48h]
    cmp     r11,8
    jb      L25
    mov     r10,[rsp+50h]
    mov     [rsp+360h],r10
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+38h]
    call    qword ptr [fn2.slot]
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*8]
    mov     [rsp+358h],rax
    mov     [rsp+360h],rax
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     r11,[r11+r10*8]
    mov     [rsp+58h],r11
    mov     r10,[rsp+58h]
    mov     [rsp+358h],r10
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     ecx,[rax+8]
    mov     edx,[rax]
    cmp     ecx,edx
    setb    cl
    mov     edx,[rax+18h]
    mov     esi,[rax+10h]
    cmp     edx,esi
    setb    dl
    movzx   esi,cl
    lea     r15,[rax+rsi*8]
    xor     ecx,1
    movzx   ecx,cl
    lea     r14,[rax+rcx*8]
    movzx   ecx,dl
    add     rcx,2
    lea     r13,[rax+rcx*8]
    xor     edx,1
    movzx   edx,dl
    add     rdx,2
    lea     r11,[rax+rdx*8]
    mov     [rsp+68h],r11
    mov     eax,[r13]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    bl
    mov     r11,[rsp+68h]
    mov     eax,[r11]
    mov     ecx,[r14]
    cmp     eax,ecx
    setb    [rsp+60h]
    mov     [rsp+160h],r13
    mov     [rsp+158h],r13
    mov     [rsp+160h],r15
    lea     rbp,[rsp+158h]
    lea     r12,[rsp+160h]
    mov     [rsp+168h],r12
    mov     [rsp+8],bl
    mov     [rsp],rbp
    mov     [rsp+10h],r12
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym16]
    mov     [rsp+8],bl
    mov     [rsp],r12
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+168h]
    mov     [rsp+170h],rax
    mov     rax,[rsp+148h]
    mov     [rsp+178h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+170h]
    mov     [rsp+178h],rax
    mov     rax,[rsp+158h]
    mov     rcx,[rsp+160h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym18]
    mov     r11,[rsp+178h]
    mov     [rsp+70h],r11
    mov     [rsp+1A0h],r14
    mov     [rsp+198h],r14
    mov     r10,[rsp+68h]
    mov     [rsp+1A0h],r10
    lea     rbp,[rsp+198h]
    lea     r12,[rsp+1A0h]
    mov     [rsp+1A8h],r12
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rbp
    mov     [rsp+10h],r12
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],r12
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+1A8h]
    mov     [rsp+1B0h],rax
    mov     rax,[rsp+188h]
    mov     [rsp+1B8h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+1B0h]
    mov     [rsp+1B8h],rax
    mov     rax,[rsp+198h]
    mov     rcx,[rsp+1A0h]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym18]
    mov     r11,[rsp+1B8h]
    mov     [rsp+78h],r11
    mov     [rsp+1E0h],r13
    mov     [rsp+1D8h],r13
    mov     [rsp+1E0h],r14
    lea     rbp,[rsp+1D8h]
    lea     r12,[rsp+1E0h]
    mov     [rsp+1E8h],r12
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rbp
    mov     [rsp+10h],r12
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],r12
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+1E8h]
    mov     [rsp+1F0h],rax
    mov     rax,[rsp+1C8h]
    mov     [rsp+1F8h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+1F0h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1D8h]
    mov     rcx,[rsp+1E0h]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+1F8h]
    mov     [rsp+220h],r15
    mov     [rsp+218h],r15
    mov     [rsp+220h],rax
    lea     r12,[rsp+218h]
    lea     r15,[rsp+220h]
    mov     [rsp+228h],r15
    mov     [rsp+8],bl
    mov     [rsp],r12
    mov     [rsp+10h],r15
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym16]
    mov     [rsp+8],bl
    mov     [rsp],r15
    mov     [rsp+10h],r12
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+228h]
    mov     [rsp+230h],rax
    mov     rax,[rsp+208h]
    mov     [rsp+238h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+230h]
    mov     [rsp+238h],rax
    mov     rax,[rsp+218h]
    mov     rcx,[rsp+220h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym18]
    mov     r12,[rsp+238h]
    mov     [rsp+260h],r14
    mov     [rsp+258h],r14
    mov     [rsp+260h],r13
    lea     r13,[rsp+258h]
    lea     r14,[rsp+260h]
    mov     [rsp+268h],r14
    mov     [rsp+8],bl
    mov     [rsp],r13
    mov     [rsp+10h],r14
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym16]
    mov     [rsp+8],bl
    mov     [rsp],r14
    mov     [rsp+10h],r13
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+268h]
    mov     [rsp+270h],rax
    mov     rax,[rsp+248h]
    mov     [rsp+278h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+270h]
    mov     [rsp+278h],rax
    mov     rax,[rsp+258h]
    mov     rcx,[rsp+260h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+278h]
    mov     r10,[rsp+68h]
    mov     [rsp+2A0h],r10
    mov     r10,[rsp+68h]
    mov     [rsp+298h],r10
    mov     [rsp+2A0h],rax
    lea     rbx,[rsp+298h]
    lea     r13,[rsp+2A0h]
    mov     [rsp+2A8h],r13
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rbx
    mov     [rsp+10h],r13
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],r13
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+2A8h]
    mov     [rsp+2B0h],rax
    mov     rax,[rsp+288h]
    mov     [rsp+2B8h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+2B0h]
    mov     [rsp+2B8h],rax
    mov     rax,[rsp+298h]
    mov     rcx,[rsp+2A0h]
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym18]
    mov     rbx,[rsp+2B8h]
    mov     r11,[rsp+38h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+2E0h],rbx
    mov     [rsp+2D8h],rbx
    mov     [rsp+2E0h],r12
    lea     r14,[rsp+2D8h]
    lea     r15,[rsp+2E0h]
    mov     [rsp+2E8h],r15
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r13b
    mov     [rsp],r15
    mov     [rsp+10h],r14
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+2E8h]
    mov     [rsp+2F0h],rax
    mov     rax,[rsp+2C8h]
    mov     [rsp+2F8h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+2F0h]
    mov     [rsp+2F8h],rax
    mov     rax,[rsp+2D8h]
    mov     rcx,[rsp+2E0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym18]
    mov     r14,[rsp+2F8h]
    mov     [rsp+320h],r12
    mov     [rsp+318h],r12
    mov     [rsp+320h],rbx
    lea     rbx,[rsp+318h]
    lea     r12,[rsp+320h]
    mov     [rsp+328h],r12
    mov     [rsp+8],r13b
    mov     [rsp],rbx
    mov     [rsp+10h],r12
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym16]
    mov     [rsp+8],r13b
    mov     [rsp],r12
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+328h]
    mov     [rsp+330h],rax
    mov     rax,[rsp+308h]
    mov     [rsp+338h],rax
    mov     rdi,rax
    call    image.sym17
    mov     rax,[rsp+330h]
    mov     [rsp+338h],rax
    mov     rax,[rsp+318h]
    mov     rcx,[rsp+320h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+338h]
    lea     r11,[image.k1752]
    mov     [rsp+0C8h],r11
    mov     rdx,[rsp+70h]
    and     rdx,3
    test    rdx,rdx
    je      L5
    jmp     L61
L1:
    mov     rdx,[rsp+58h]
    and     rdx,3
    test    rdx,rdx
    je      L6
    jmp     L61
L2:
    mov     r11,[rsp+70h]
    cmp     r11,[rsp+58h]
    jae     L3
    mov     rdx,[rsp+58h]
    sub     rdx,[rsp+70h]
    jmp     L4
L3:
    mov     rdx,[rsp+70h]
    sub     rdx,[rsp+58h]
L4:
    cmp     rdx,8
    jb      L61
    mov     r11,[rsp+70h]
    mov     edx,[r11]
    mov     r11,[rsp+70h]
    mov     esi,[r11+4]
    mov     r11,[rsp+58h]
    mov     [r11],edx
    mov     r11,[rsp+58h]
    mov     [r11+4],esi
    mov     rdx,[rsp+58h]
    lea     rdx,[rdx+8]
    lea     r11,[image.k1776]
    mov     [rsp+0C0h],r11
    mov     rdi,r14
    and     rdi,3
    test    rdi,rdi
    je      L11
    jmp     L62
L5:
    mov     r11,[rsp+70h]
    cmp     r11,0
    je      L61
    jmp     L1
L6:
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L61
    jmp     L2
L7:
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L12
    jmp     L62
L8:
    cmp     r14,rdx
    jae     L9
    mov     rdi,rdx
    sub     rdi,r14
    jmp     L10
L9:
    mov     rdi,r14
    sub     rdi,rdx
L10:
    cmp     rdi,8
    jb      L62
    mov     edi,[r14]
    mov     r8d,[r14+4]
    mov     r11,[rsp+58h]
    mov     [r11+8],edi
    mov     r11,[rsp+58h]
    mov     [r11+0Ch],r8d
    mov     rdi,[rsp+58h]
    lea     rdi,[rdi+10h]
    lea     r11,[image.k1800]
    mov     [rsp+0B8h],r11
    mov     r9,rax
    and     r9,3
    test    r9,r9
    je      L17
    jmp     L63
L11:
    test    r14,r14
    je      L62
    jmp     L7
L12:
    test    rdx,rdx
    je      L62
    jmp     L8
L13:
    mov     rdx,rdi
    and     rdx,3
    test    rdx,rdx
    je      L18
    jmp     L63
L14:
    cmp     rax,rdi
    jae     L15
    mov     rdx,rdi
    sub     rdx,rax
    jmp     L16
L15:
    mov     rdx,rax
    sub     rdx,rdi
L16:
    cmp     rdx,8
    jb      L63
    mov     edx,[rax]
    mov     r9d,[rax+4]
    mov     r11,[rsp+58h]
    mov     [r11+10h],edx
    mov     r11,[rsp+58h]
    mov     [r11+14h],r9d
    mov     rdx,[rsp+58h]
    lea     rdx,[rdx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+0B0h],r11
    mov     rbx,[rsp+78h]
    and     rbx,3
    test    rbx,rbx
    je      L23
    jmp     L64
L17:
    test    rax,rax
    je      L63
    jmp     L13
L18:
    test    rdi,rdi
    je      L63
    jmp     L14
L19:
    mov     rax,rdx
    and     rax,3
    test    rax,rax
    je      L24
    jmp     L64
L20:
    mov     r11,[rsp+78h]
    cmp     r11,rdx
    jae     L21
    mov     rax,rdx
    sub     rax,[rsp+78h]
    jmp     L22
L21:
    mov     rax,[rsp+78h]
    sub     rax,rdx
L22:
    cmp     rax,8
    jb      L64
    mov     r11,[rsp+78h]
    mov     eax,[r11]
    mov     r11,[rsp+78h]
    mov     edi,[r11+4]
    mov     r11,[rsp+58h]
    mov     [r11+18h],eax
    mov     r11,[rsp+58h]
    mov     [r11+1Ch],edi
    mov     r12d,4
    jmp     L38
L23:
    mov     r11,[rsp+78h]
    cmp     r11,0
    je      L64
    jmp     L19
L24:
    test    rdx,rdx
    je      L64
    jmp     L20
L25:
    mov     r10,[rsp+50h]
    mov     [rsp+360h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+358h],r10
    lea     r11,[k9]
    mov     [rsp+0A8h],r11
    mov     rdx,[rsp+50h]
    and     rdx,3
    test    rdx,rdx
    je      L30
    jmp     L65
L26:
    mov     rdx,[rsp+40h]
    and     rdx,3
    test    rdx,rdx
    je      L31
    jmp     L65
L27:
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+40h]
    jae     L28
    mov     rdx,[rsp+40h]
    sub     rdx,[rsp+50h]
    jmp     L29
L28:
    mov     rdx,[rsp+50h]
    sub     rdx,[rsp+40h]
L29:
    cmp     rdx,8
    jb      L65
    mov     rdx,[rsp+360h]
    mov     edi,[rdx]
    mov     edx,[rdx+4]
    mov     r11,[rsp+40h]
    mov     [r11],edi
    mov     r11,[rsp+40h]
    mov     [r11+4],edx
    mov     r11,[rsp+50h]
    mov     r10,[rsp+30h]
    lea     rdx,[r11+r10*8]
    mov     [rsp+360h],rdx
    mov     r11,[rsp+40h]
    mov     r10,[rsp+30h]
    lea     rdi,[r11+r10*8]
    mov     [rsp+358h],rdi
    mov     [rsp+3C8h],rdi
    lea     r11,[k11]
    mov     [rsp+80h],r11
    mov     r12,rdx
    and     r12,3
    test    r12,r12
    je      L36
    jmp     L66
L30:
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L65
    jmp     L26
L31:
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L65
    jmp     L27
L32:
    mov     r12,rdi
    and     r12,3
    test    r12,r12
    je      L37
    jmp     L66
L33:
    cmp     rdx,rdi
    jae     L34
    mov     r12,rdi
    sub     r12,rdx
    jmp     L35
L34:
    mov     r12,rdx
    sub     r12,rdi
L35:
    cmp     r12,8
    jb      L66
    mov     r12,[rsp+360h]
    mov     r13d,[r12]
    mov     r12d,[r12+4]
    mov     r14,[rsp+358h]
    mov     [r14],r13d
    mov     r13,[rsp+358h]
    mov     [r13+4],r12d
    mov     r12d,1
    jmp     L38
L36:
    test    rdx,rdx
    je      L66
    jmp     L32
L37:
    test    rdi,rdi
    je      L66
    jmp     L33
L38:
    mov     qword ptr [rsp+3C0h],0
    mov     r10,[rsp+30h]
    mov     [rsp+3C8h],r10
    mov     qword ptr [rsp+3B0h],0
    mov     r10,[rsp+30h]
    mov     [rsp+3B8h],r10
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFEB0h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdx,[rsp+370h]
    mov     rdi,[rsp+378h]
    mov     [rsp+358h],rdi
    mov     qword ptr [rsp+360h],0
    mov     r10,[rsp+30h]
    mov     [rsp+368h],r10
    mov     [rsp+3B0h],rdx
    mov     [rsp+3B8h],rdi
    mov     qword ptr [rsp+3C0h],0
    mov     r10,[rsp+30h]
    mov     [rsp+3C8h],r10
    mov     r13,[rsp+50h]
    mov     r14,[rsp+48h]
    mov     r11,[rsp+40h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+0D8h],r11
    mov     [rsp+0A0h],r12
    mov     r12,[rsp+40h]
    mov     r11,[rsp+38h]
    mov     [rsp+88h],r11
L39:
    lea     rdx,[rsp+3B0h]
    mov     [rsp+370h],rdx
    mov     qword ptr [rsp+378h],2
    mov     rdx,[rsp+3B8h]
    mov     rdi,[rsp+3B0h]
    sub     rdx,rdi
    test    rdx,rdx
    jbe     L40
    lea     r11,[image.k6944]
    mov     [rsp+90h],r11
    mov     r11,rdi
    add     r11,1
    jb      L67
    lea     rdx,[rdi+1]
    mov     [rsp+3B0h],rdx
    mov     [rsp+348h],rdi
    mov     qword ptr [rsp+340h],1
    lea     rdx,[rsp+3C0h]
    lea     r11,[image.k7064]
    mov     [rsp+98h],r11
    cmp     rdi,2
    jae     L68
    lea     rbx,[rdx+rdi*8]
    lea     rdi,[rsp+4C0h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym46]
    mov     rdx,[rbx]
    mov     [rsp+0D0h],rdx
    mov     edx,1
    jmp     L41
L40:
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFE80h
    lea     rdx,[image.k6840]
    mov     ecx,10h
    call    ryo_h_Const
    mov     edx,0
L41:
    test    rdx,rdx
    je      L43
    jmp     L57
L42:
    mov     [rsp+378h],rdx
    lea     rbp,[rbx+rdx*8]
    mov     [rsp+370h],rbp
    lea     rbp,[rax+rdx*8]
    test    rdx,rdx
    je      L46
    mov     rdx,r8
    sub     rdx,r9
    mov     [rsp+138h],rdx
    mov     [rsp+130h],rcx
    mov     [rsp+0E8h],rbx
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],rax
    mov     [rsp+100h],r9
    mov     [rsp+108h],rsi
    mov     [rsp+110h],rbp
    mov     [rsp+118h],rdi
    jmp     L47
L43:
    mov     [rsp+358h],r12
    mov     [rsp+360h],r13
    mov     [rsp+368h],r14
    mov     [rsp+3C0h],r12
    mov     [rsp+3B8h],r14
    mov     [rsp+3B0h],r12
    lea     r11,[k18]
    mov     [rsp+0E0h],r11
    mov     rdx,r12
    and     rdx,3
    test    rdx,rdx
    je      L45
    jmp     L69
L44:
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r14,r10
    ja      L69
    mov     [rsp+3B0h],r14
    mov     [rsp+3C8h],r12
    mov     [rsp+3C0h],r13
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,r13
    mov     rcx,[rsp+88h]
    call    qword ptr [fn20.slot]
    jmp     L60
L45:
    test    r12,r12
    je      L69
    jmp     L44
L46:
    mov     [rsp+138h],r9
    mov     [rsp+130h],rcx
    mov     [rsp+0E8h],rbx
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],rax
    mov     [rsp+100h],r9
    mov     [rsp+108h],rsi
    mov     [rsp+110h],rbp
    mov     [rsp+118h],rdi
L47:
    cmp     rsi,[rsp+138h]
    jae     L58
    lea     r11,[rsi+1]
    mov     [rsp+120h],r11
    mov     rax,[rsp+370h]
    lea     rax,[rax+rsi*8]
    mov     r11,[rsp+110h]
    lea     rcx,[r11+rsi*8]
    lea     r11,[k15]
    mov     [rsp+128h],r11
    mov     rsi,rax
    and     rsi,3
    test    rsi,rsi
    je      L52
    jmp     L70
L48:
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L53
    jmp     L70
L49:
    cmp     rax,rcx
    jae     L50
    mov     rsi,rcx
    sub     rsi,rax
    jmp     L51
L50:
    mov     rsi,rax
    sub     rsi,rcx
L51:
    cmp     rsi,8
    jb      L70
    mov     esi,[rax]
    mov     edi,[rax+4]
    mov     [rcx],esi
    mov     [rcx+4],edi
    mov     rdi,[rsp+110h]
    mov     rsi,rcx
    mov     rdx,[rsp+118h]
    call    qword ptr [fn17.slot]
    jmp     L59
L52:
    test    rax,rax
    je      L70
    jmp     L48
L53:
    test    rcx,rcx
    je      L70
    jmp     L49
L54:
    mov     [rsp+138h],rcx
    mov     [rsp+130h],rsi
    mov     rsi,rax
    mov     [rsp+0E8h],rdi
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],r9
    mov     [rsp+100h],rdx
    mov     [rsp+108h],rbp
    mov     [rsp+110h],rbx
    mov     [rsp+118h],r15
    jmp     L47
L55:
    mov     r11,[rsp+358h]
    mov     rax,[rsp+360h]
    mov     [rsp+3C8h],rax
    mov     rax,[rsp+368h]
    mov     [rsp+3C0h],rax
L56:
    mov     rbx,[rsp+3A8h]
    mov     r12,[rsp+3A0h]
    mov     r13,[rsp+398h]
    mov     r14,[rsp+390h]
    mov     r15,[rsp+388h]
    mov     rbp,[rsp+380h]
    add     rsp,4C8h
    ret
L57:
    mov     rdx,[rsp+0D0h]
    mov     rbx,r13
    mov     rax,[rsp+140h]
    mov     r9,[rsp+0D8h]
    mov     r8,r14
    mov     rsi,[rsp+0A0h]
    mov     rcx,r12
    mov     rdi,[rsp+88h]
    jmp     L42
L58:
    mov     r12,[rsp+130h]
    mov     r13,[rsp+0E8h]
    mov     r14,[rsp+0F0h]
    mov     r11,[rsp+0F8h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+0D8h],r11
    mov     r11,[rsp+108h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+88h],r11
    jmp     L39
L59:
    mov     rax,[rsp+120h]
    mov     rcx,[rsp+138h]
    mov     rsi,[rsp+130h]
    mov     rdi,[rsp+0E8h]
    mov     r8,[rsp+0F0h]
    mov     r9,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    mov     rbp,[rsp+108h]
    mov     rbx,[rsp+110h]
    mov     r15,[rsp+118h]
    jmp     L54
L60:
    jmp     L55
    mov     rbx,rax
    lea     rax,[rsp+170h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+1B0h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+1F0h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+230h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+270h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+2B0h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+2F0h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rax,[rsp+330h]
    mov     rdi,rax
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
L61:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L64:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L65:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L66:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L67:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L68:
    lea     rax,[image.k9969]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L69:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L70:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+128h]
    movzx   edx,dl
    call    image.sym49
    ud2
L71:
    lea     rdi,[rsp+4C0h]
    call    ryo_h_Abort
    ud2
L72:
    lea     rax,[rsp+3B0h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L73
    jmp     L75
L73:
    mov     [rsp+20h],rax
    lea     rdi,[rsp+4C0h]
    mov     esi,0FFFFFB60h
    call    ryo_h_Resume
    ud2
L74:
    lea     rax,[rsp+358h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    mov     rax,r12
    jmp     L73
    jmp     L75
    mov     rbx,rax
    jmp     L72
    mov     r12,rax
    jmp     L74
L75:
    call    sym21
    ud2
  ; OSR entries
    lea     r11,[L76]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L76:
    .long   L77
    .long   L78
    .long   L79
    .long   L80
    .long   L81
    .long   L82
    .long   L83
    .long   L84
    .long   L85
    .long   L86
    .long   L87
L77:
    ret
L78:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-520h]
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
    mov     r11,[rdx-130h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+58h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-380h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-3E8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-420h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-438h],r11
    mov     r12,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L39
L79:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-530h]
    mov     r11,[rdx-118h]
    mov     [rsp],r11
    mov     r11,[rdx-0C0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+60h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-158h],r11
    mov     rbx,[rsp+8]
    mov     rax,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     rdi,[rsp+38h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+70h]
    jmp     L42
L80:
    ret
L81:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-540h]
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
    mov     r11,[rdx-138h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+70h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+8]
    mov     [rdx-388h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-390h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-3D8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-3D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-3C8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3C0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-3B8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-3B0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-3A8h],r11
    mov     rsi,[rsp]
    lea     rsp,[rsp+80h]
    jmp     L47
L82:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-540h]
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
    mov     r11,[rdx-138h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-130h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-128h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+70h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-158h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     rbp,[rsp+38h]
    mov     rbx,[rsp+40h]
    mov     r15,[rsp+48h]
    mov     rdx,[rsp+30h]
    lea     rsp,[rsp+80h]
    jmp     L54
L83:
    ret
L84:
    ret
L85:
    ret
L86:
    ret
L87:
    ret

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,328h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rdx
    cmp     rsi,0Dh
    jb      L63
    mov     rdi,[rsp+38h]
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,2
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,3
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,1
    mov     edx,6
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,7
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,0
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     r13,[rsp+38h]
    lea     r13,[r13+4]
    mov     r14,[rsp+38h]
    lea     r14,[r14+8]
    mov     r11,[rsp+38h]
    mov     eax,[r11+8]
    mov     r11,[rsp+38h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    r15b
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     [rsp+80h],r13
    mov     [rsp+78h],r13
    mov     [rsp+80h],r14
    lea     r12,[rsp+78h]
    lea     rbx,[rsp+80h]
    mov     [rsp+88h],rbx
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],rbx
    mov     [rsp+10h],r12
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+88h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+98h],rax
    mov     rdi,rax
    call    image.sym13
    mov     rax,[rsp+90h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+98h]
    mov     eax,[rax]
    mov     [rsp+0A0h],eax
    lea     rax,[image.k2088]
    mov     rcx,rbp
    and     rcx,3
    test    rcx,rcx
    je      L1
    jmp     L51
L0:
    mov     ecx,[rbp]
    mov     r11,[rsp+38h]
    mov     [r11+4],ecx
    lea     rcx,[rsp+0A0h]
    lea     rdx,[image.k2112]
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L6
    jmp     L52
L1:
    test    rbp,rbp
    je      L51
    mov     rsi,r13
    and     rsi,3
    test    rsi,rsi
    jne     L51
    test    r13,r13
    je      L51
    jmp     L0
L2:
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L7
    jmp     L52
L3:
    cmp     rcx,r14
    jae     L4
    mov     rsi,r14
    sub     rsi,rcx
    jmp     L5
L4:
    mov     rsi,rcx
    sub     rsi,r14
L5:
    cmp     rsi,4
    jb      L52
    mov     esi,[rsp+0A0h]
    mov     r11,[rsp+38h]
    mov     [r11+8],esi
    mov     rbx,[rsp+38h]
    lea     rbx,[rbx+0Ch]
    mov     r11,[rsp+38h]
    lea     r11,[r11+18h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+38h]
    mov     esi,[r11+18h]
    mov     r11,[rsp+38h]
    mov     edi,[r11+0Ch]
    cmp     esi,edi
    setb    r13b
    mov     r10,[rsp+40h]
    mov     [rsp+0C0h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+0B8h],r10
    mov     [rsp+0C0h],rbx
    lea     r15,[rsp+0B8h]
    lea     rbp,[rsp+0C0h]
    mov     [rsp+0C8h],rbp
    mov     [rsp+8],r13b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rsi,[rsp+0C8h]
    mov     [rsp+0D0h],rsi
    mov     rsi,[rsp+0A8h]
    mov     [rsp+0D8h],rsi
    mov     rdi,rsi
    call    image.sym13
    jmp     L8
L6:
    test    rcx,rcx
    je      L52
    jmp     L2
L7:
    test    r14,r14
    je      L52
    jmp     L3
L8:
    mov     rcx,[rsp+0D0h]
    mov     [rsp+0D8h],rcx
    mov     rcx,[rsp+0B8h]
    mov     rsi,[rsp+0C0h]
    mov     [rsp+8],r13b
    mov     [rsp],rcx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+0D8h]
    mov     [rsp+100h],rbx
    mov     [rsp+0F8h],rbx
    mov     r10,[rsp+40h]
    mov     [rsp+100h],r10
    lea     r15,[rsp+0F8h]
    lea     rbp,[rsp+100h]
    mov     [rsp+108h],rbp
    mov     [rsp+8],r13b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     rcx,[rsp+108h]
    mov     [rsp+110h],rcx
    mov     rcx,[rsp+0E8h]
    mov     [rsp+118h],rcx
    mov     rdi,rcx
    call    image.sym13
    mov     rcx,[rsp+110h]
    mov     [rsp+118h],rcx
    mov     rcx,[rsp+0F8h]
    mov     rsi,[rsp+100h]
    mov     [rsp+8],r13b
    mov     [rsp],rcx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym14]
    mov     rcx,[rsp+118h]
    mov     ecx,[rcx]
    mov     [rsp+120h],ecx
    lea     rcx,[image.k2088]
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L10
    jmp     L53
L9:
    mov     esi,[r14]
    mov     r11,[rsp+38h]
    mov     [r11+0Ch],esi
    lea     rsi,[rsp+120h]
    lea     rdi,[image.k2112]
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    je      L15
    jmp     L54
L10:
    test    r14,r14
    je      L53
    mov     r8,rbx
    and     r8,3
    test    r8,r8
    jne     L53
    test    rbx,rbx
    je      L53
    jmp     L9
L11:
    mov     r8,[rsp+40h]
    and     r8,3
    test    r8,r8
    je      L16
    jmp     L54
L12:
    cmp     rsi,[rsp+40h]
    jae     L13
    mov     r8,[rsp+40h]
    sub     r8,rsi
    jmp     L14
L13:
    mov     r8,rsi
    sub     r8,[rsp+40h]
L14:
    cmp     r8,4
    jb      L54
    mov     r8d,[rsp+120h]
    mov     r11,[rsp+38h]
    mov     [r11+18h],r8d
    mov     rbx,[rsp+38h]
    lea     rbx,[rbx+1Ch]
    mov     r13,[rsp+38h]
    lea     r13,[r13+20h]
    mov     r11,[rsp+38h]
    mov     r8d,[r11+20h]
    mov     r11,[rsp+38h]
    mov     r9d,[r11+1Ch]
    cmp     r8d,r9d
    setb    r14b
    mov     [rsp+140h],r13
    mov     [rsp+138h],r13
    mov     [rsp+140h],rbx
    lea     r15,[rsp+138h]
    lea     rbp,[rsp+140h]
    mov     [rsp+148h],rbp
    mov     [rsp+8],r14b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym12]
    mov     r8,[rsp+148h]
    mov     [rsp+150h],r8
    mov     r8,[rsp+128h]
    mov     [rsp+158h],r8
    mov     rdi,r8
    call    image.sym13
    jmp     L17
L15:
    test    rsi,rsi
    je      L54
    jmp     L11
L16:
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L54
    jmp     L12
L17:
    mov     rsi,[rsp+150h]
    mov     [rsp+158h],rsi
    mov     rsi,[rsp+138h]
    mov     r8,[rsp+140h]
    mov     [rsp+8],r14b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym14]
    mov     r15,[rsp+158h]
    mov     [rsp+180h],rbx
    mov     [rsp+178h],rbx
    mov     [rsp+180h],r13
    lea     rbp,[rsp+178h]
    lea     r12,[rsp+180h]
    mov     [rsp+188h],r12
    mov     [rsp+8],r14b
    mov     [rsp],rbp
    mov     [rsp+10h],r12
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    mov     [rsp],r12
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym12]
    mov     rsi,[rsp+188h]
    mov     [rsp+190h],rsi
    mov     rsi,[rsp+168h]
    mov     [rsp+198h],rsi
    mov     rdi,rsi
    call    image.sym13
    mov     rsi,[rsp+190h]
    mov     [rsp+198h],rsi
    mov     rsi,[rsp+178h]
    mov     r8,[rsp+180h]
    mov     [rsp+8],r14b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym14]
    mov     rsi,[rsp+198h]
    mov     esi,[rsi]
    mov     [rsp+1A0h],esi
    lea     rsi,[image.k2088]
    mov     r8,r15
    and     r8,3
    test    r8,r8
    je      L19
    jmp     L55
L18:
    mov     r8d,[r15]
    mov     r11,[rsp+38h]
    mov     [r11+1Ch],r8d
    lea     r8,[rsp+1A0h]
    lea     r9,[image.k2112]
    mov     r12,r8
    and     r12,3
    test    r12,r12
    je      L24
    jmp     L56
L19:
    test    r15,r15
    je      L55
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    jne     L55
    test    rbx,rbx
    je      L55
    jmp     L18
L20:
    mov     rbx,r13
    and     rbx,3
    test    rbx,rbx
    je      L25
    jmp     L56
L21:
    cmp     r8,r13
    jae     L22
    mov     rbx,r13
    sub     rbx,r8
    jmp     L23
L22:
    mov     rbx,r8
    sub     rbx,r13
L23:
    cmp     rbx,4
    jb      L56
    mov     ebx,[rsp+1A0h]
    mov     r11,[rsp+38h]
    mov     [r11+20h],ebx
    mov     rbx,[rsp+38h]
    lea     rbx,[rbx+24h]
    mov     r12,[rsp+38h]
    lea     r12,[r12+28h]
    mov     r11,[rsp+38h]
    mov     r14d,[r11+28h]
    mov     r11,[rsp+38h]
    mov     r15d,[r11+24h]
    cmp     r14d,r15d
    setb    r14b
    mov     [rsp+1C0h],r12
    mov     [rsp+1B8h],r12
    mov     [rsp+1C0h],rbx
    lea     r15,[rsp+1B8h]
    lea     rbp,[rsp+1C0h]
    mov     [rsp+1C8h],rbp
    mov     [rsp+8],r14b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     r15,[rsp+1C8h]
    mov     [rsp+1D0h],r15
    mov     r15,[rsp+1A8h]
    mov     [rsp+1D8h],r15
    mov     rdi,r15
    call    image.sym13
    jmp     L26
L24:
    test    r8,r8
    je      L56
    jmp     L20
L25:
    test    r13,r13
    je      L56
    jmp     L21
L26:
    mov     r8,[rsp+1D0h]
    mov     [rsp+1D8h],r8
    mov     r8,[rsp+1B8h]
    mov     r13,[rsp+1C0h]
    mov     [rsp+8],r14b
    mov     [rsp],r8
    mov     [rsp+10h],r13
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym14]
    mov     r13,[rsp+1D8h]
    mov     [rsp+200h],rbx
    mov     [rsp+1F8h],rbx
    mov     [rsp+200h],r12
    lea     r15,[rsp+1F8h]
    lea     rbp,[rsp+200h]
    mov     [rsp+208h],rbp
    mov     [rsp+8],r14b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     r8,[rsp+208h]
    mov     [rsp+210h],r8
    mov     r8,[rsp+1E8h]
    mov     [rsp+218h],r8
    mov     rdi,r8
    call    image.sym13
    mov     r8,[rsp+210h]
    mov     [rsp+218h],r8
    mov     r8,[rsp+1F8h]
    mov     r15,[rsp+200h]
    mov     [rsp+8],r14b
    mov     [rsp],r8
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym14]
    mov     r8,[rsp+218h]
    mov     r8d,[r8]
    mov     [rsp+220h],r8d
    lea     r8,[image.k2088]
    mov     r14,r13
    and     r14,3
    test    r14,r14
    je      L28
    jmp     L57
L27:
    mov     r14d,[r13]
    mov     r11,[rsp+38h]
    mov     [r11+24h],r14d
    lea     r14,[rsp+220h]
    lea     r11,[image.k2112]
    mov     [rsp+48h],r11
    mov     rbp,r14
    and     rbp,3
    test    rbp,rbp
    je      L33
    jmp     L58
L28:
    test    r13,r13
    je      L57
    mov     rbp,rbx
    and     rbp,3
    test    rbp,rbp
    jne     L57
    test    rbx,rbx
    je      L57
    jmp     L27
L29:
    mov     rbx,r12
    and     rbx,3
    test    rbx,rbx
    je      L34
    jmp     L58
L30:
    cmp     r14,r12
    jae     L31
    mov     rbx,r12
    sub     rbx,r14
    jmp     L32
L31:
    mov     rbx,r14
    sub     rbx,r12
L32:
    cmp     rbx,4
    jb      L58
    mov     ebx,[rsp+220h]
    mov     r11,[rsp+38h]
    mov     [r11+28h],ebx
    mov     rbx,[rsp+38h]
    lea     rbx,[rbx+2Ch]
    mov     r11,[rsp+38h]
    lea     r11,[r11+30h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+38h]
    mov     ebp,[r11+30h]
    mov     r11,[rsp+38h]
    mov     r15d,[r11+2Ch]
    cmp     ebp,r15d
    setb    r15b
    mov     r10,[rsp+50h]
    mov     [rsp+240h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+238h],r10
    mov     [rsp+240h],rbx
    lea     rbp,[rsp+238h]
    lea     r13,[rsp+240h]
    mov     [rsp+248h],r13
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     r13,[rsp+248h]
    mov     [rsp+250h],r13
    mov     r13,[rsp+228h]
    mov     [rsp+258h],r13
    mov     rdi,r13
    call    image.sym13
    jmp     L35
L33:
    test    r14,r14
    je      L58
    jmp     L29
L34:
    test    r12,r12
    je      L58
    jmp     L30
L35:
    mov     r12,[rsp+250h]
    mov     [rsp+258h],r12
    mov     r12,[rsp+238h]
    mov     r13,[rsp+240h]
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],r13
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+258h]
    mov     [rsp+280h],rbx
    mov     [rsp+278h],rbx
    mov     r10,[rsp+50h]
    mov     [rsp+280h],r10
    lea     r13,[rsp+278h]
    lea     r14,[rsp+280h]
    mov     [rsp+288h],r14
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],r14
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r14
    mov     [rsp+10h],r13
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     r13,[rsp+288h]
    mov     [rsp+290h],r13
    mov     r13,[rsp+268h]
    mov     [rsp+298h],r13
    mov     rdi,r13
    call    image.sym13
    mov     r13,[rsp+290h]
    mov     [rsp+298h],r13
    mov     r13,[rsp+278h]
    mov     r14,[rsp+280h]
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],r14
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym14]
    mov     r13,[rsp+298h]
    mov     r13d,[r13]
    mov     [rsp+2A0h],r13d
    lea     r13,[image.k2088]
    mov     r14,r12
    and     r14,3
    test    r14,r14
    je      L37
    jmp     L59
L36:
    mov     r14d,[r12]
    mov     r11,[rsp+38h]
    mov     [r11+2Ch],r14d
    lea     r14,[rsp+2A0h]
    lea     r11,[image.k2112]
    mov     [rsp+58h],r11
    mov     rbp,r14
    and     rbp,3
    test    rbp,rbp
    je      L42
    jmp     L60
L37:
    test    r12,r12
    je      L59
    mov     rbp,rbx
    and     rbp,3
    test    rbp,rbp
    jne     L59
    test    rbx,rbx
    je      L59
    jmp     L36
L38:
    mov     rbx,[rsp+50h]
    and     rbx,3
    test    rbx,rbx
    je      L43
    jmp     L60
L39:
    cmp     r14,[rsp+50h]
    jae     L40
    mov     rbx,[rsp+50h]
    sub     rbx,r14
    jmp     L41
L40:
    mov     rbx,r14
    sub     rbx,[rsp+50h]
L41:
    cmp     rbx,4
    jb      L60
    mov     ebx,[rsp+2A0h]
    mov     r11,[rsp+38h]
    mov     [r11+30h],ebx
    mov     rbx,[rsp+38h]
    lea     rbx,[rbx+10h]
    mov     r11,[rsp+38h]
    mov     r12d,[r11+18h]
    mov     r11,[rsp+38h]
    mov     ebp,[r11+10h]
    cmp     r12d,ebp
    setb    r12b
    mov     r10,[rsp+40h]
    mov     [rsp+2C0h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+2B8h],r10
    mov     [rsp+2C0h],rbx
    lea     rbp,[rsp+2B8h]
    lea     r15,[rsp+2C0h]
    mov     [rsp+2C8h],r15
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     r15,[rsp+2C8h]
    mov     [rsp+2D0h],r15
    mov     r15,[rsp+2A8h]
    mov     [rsp+2D8h],r15
    mov     rdi,r15
    call    image.sym13
    jmp     L44
L42:
    test    r14,r14
    je      L60
    jmp     L38
L43:
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L60
    jmp     L39
L44:
    mov     r14,[rsp+2D0h]
    mov     [rsp+2D8h],r14
    mov     r14,[rsp+2B8h]
    mov     r15,[rsp+2C0h]
    mov     [rsp+8],r12b
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+2D8h]
    mov     [rsp+300h],rbx
    mov     [rsp+2F8h],rbx
    mov     r10,[rsp+40h]
    mov     [rsp+300h],r10
    lea     r15,[rsp+2F8h]
    lea     rbp,[rsp+300h]
    mov     [rsp+308h],rbp
    mov     [rsp+8],r12b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r15
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     r15,[rsp+308h]
    mov     [rsp+310h],r15
    mov     r15,[rsp+2E8h]
    mov     [rsp+318h],r15
    mov     rdi,r15
    call    image.sym13
    mov     r15,[rsp+310h]
    mov     [rsp+318h],r15
    mov     r15,[rsp+2F8h]
    mov     rbp,[rsp+300h]
    mov     [rsp+8],r12b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+318h]
    mov     r12d,[r12]
    mov     [rsp+320h],r12d
    lea     r12,[image.k2088]
    mov     r15,r14
    and     r15,3
    test    r15,r15
    je      L46
    jmp     L61
L45:
    mov     r15d,[r14]
    mov     r11,[rsp+38h]
    mov     [r11+10h],r15d
    lea     r15,[rsp+320h]
    lea     r11,[image.k2112]
    mov     [rsp+60h],r11
    mov     rbp,r15
    and     rbp,3
    test    rbp,rbp
    je      L50
    jmp     L62
L46:
    test    r14,r14
    je      L61
    mov     rbp,rbx
    and     rbp,3
    test    rbp,rbp
    jne     L61
    test    rbx,rbx
    je      L61
    jmp     L45
L47:
    mov     rbx,[rsp+40h]
    and     rbx,3
    test    rbx,rbx
    jne     L62
    cmp     r15,[rsp+40h]
    jae     L48
    mov     rbx,[rsp+40h]
    sub     rbx,r15
    jmp     L49
L48:
    mov     rbx,r15
    sub     rbx,[rsp+40h]
L49:
    cmp     rbx,4
    jb      L62
    mov     ebx,[rsp+320h]
    mov     r11,[rsp+38h]
    mov     [r11+18h],ebx
    mov     rdi,[rsp+38h]
    mov     esi,5
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,0
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,4
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,2
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,6
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,8
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,[rsp+38h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+30h]
    call    fn0
    add     rsp,328h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L50:
    test    r15,r15
    je      L62
    jmp     L47
    mov     rbx,rax
    lea     r14,[rsp+90h]
    mov     rdi,r14
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L51:
    lea     rbx,[image.k8904]
    mov     rdi,rbx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rax,[rsp+0D0h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+110h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L53:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L54:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rax,[rsp+150h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+190h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L55:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    image.sym49
    ud2
L56:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rax,[rsp+1D0h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+210h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L57:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rax,[rsp+250h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+290h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L59:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rax,[rsp+2D0h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+310h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L61:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    lea     rdi,[rsp+350h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,3C8h
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rdx
    cmp     rsi,9
    jb      L59
    mov     rdi,[rsp+48h]
    mov     esi,0
    mov     edx,3
    mov     rcx,[rsp+40h]
    call    fn0
    mov     r11,[rsp+48h]
    lea     r11,[r11+4]
    mov     [rsp+30h],r11
    mov     r14,[rsp+48h]
    lea     r14,[r14+1Ch]
    mov     r11,[rsp+48h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+48h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+0E0h],r14
    mov     [rsp+0D8h],r14
    mov     r10,[rsp+30h]
    mov     [rsp+0E0h],r10
    lea     rbp,[rsp+0D8h]
    lea     r13,[rsp+0E0h]
    mov     [rsp+0E8h],r13
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+0E8h]
    mov     [rsp+38h],r11
    mov     rax,[rsp+0C8h]
    mov     [rsp+0F8h],rax
    mov     rdi,rax
    call    image.sym13
    mov     r10,[rsp+38h]
    mov     [rsp+0F8h],r10
    mov     rax,[rsp+0D8h]
    mov     rcx,[rsp+0E0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym14]
    mov     rbp,[rsp+0F8h]
    mov     r10,[rsp+30h]
    mov     [rsp+120h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+118h],r10
    mov     [rsp+120h],r14
    lea     r13,[rsp+118h]
    lea     r12,[rsp+120h]
    mov     [rsp+128h],r12
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],r12
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+128h]
    mov     [rsp+130h],rax
    mov     rax,[rsp+108h]
    mov     [rsp+138h],rax
    mov     rdi,rax
    call    image.sym13
    mov     rax,[rsp+130h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+118h]
    mov     rcx,[rsp+120h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+138h]
    mov     eax,[rax]
    mov     [rsp+140h],eax
    lea     rax,[image.k2088]
    mov     rcx,rbp
    and     rcx,3
    test    rcx,rcx
    je      L1
    jmp     L47
L0:
    mov     ecx,[rbp]
    mov     r11,[rsp+48h]
    mov     [r11+4],ecx
    lea     rcx,[rsp+140h]
    lea     rdx,[image.k2112]
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L6
    jmp     L48
L1:
    test    rbp,rbp
    je      L47
    mov     rsi,[rsp+30h]
    and     rsi,3
    test    rsi,rsi
    jne     L47
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L47
    jmp     L0
L2:
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L7
    jmp     L48
L3:
    cmp     rcx,r14
    jae     L4
    mov     rsi,r14
    sub     rsi,rcx
    jmp     L5
L4:
    mov     rsi,rcx
    sub     rsi,r14
L5:
    cmp     rsi,4
    jb      L48
    mov     esi,[rsp+140h]
    mov     r11,[rsp+48h]
    mov     [r11+1Ch],esi
    mov     r11,[rsp+48h]
    lea     r11,[r11+8]
    mov     [rsp+58h],r11
    mov     r13,[rsp+48h]
    lea     r13,[r13+14h]
    mov     r11,[rsp+48h]
    mov     esi,[r11+14h]
    mov     r11,[rsp+48h]
    mov     edi,[r11+8]
    cmp     esi,edi
    setb    r15b
    mov     [rsp+160h],r13
    mov     [rsp+158h],r13
    mov     r10,[rsp+58h]
    mov     [rsp+160h],r10
    lea     rbp,[rsp+158h]
    lea     rbx,[rsp+160h]
    mov     [rsp+168h],rbx
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],rbx
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+168h]
    mov     [rsp+50h],r11
    mov     rsi,[rsp+148h]
    mov     [rsp+178h],rsi
    mov     rdi,rsi
    call    image.sym13
    jmp     L8
L6:
    test    rcx,rcx
    je      L48
    jmp     L2
L7:
    test    r14,r14
    je      L48
    jmp     L3
L8:
    mov     r10,[rsp+50h]
    mov     [rsp+178h],r10
    mov     rcx,[rsp+158h]
    mov     rsi,[rsp+160h]
    mov     [rsp+8],r15b
    mov     [rsp],rcx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym14]
    mov     rbp,[rsp+178h]
    mov     r10,[rsp+58h]
    mov     [rsp+1A0h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+198h],r10
    mov     [rsp+1A0h],r13
    lea     rbx,[rsp+198h]
    lea     r12,[rsp+1A0h]
    mov     [rsp+1A8h],r12
    mov     [rsp+8],r15b
    mov     [rsp],rbx
    mov     [rsp+10h],r12
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+1A8h]
    mov     [rsp+60h],r11
    mov     rcx,[rsp+188h]
    mov     [rsp+1B8h],rcx
    mov     rdi,rcx
    call    image.sym13
    mov     r10,[rsp+60h]
    mov     [rsp+1B8h],r10
    mov     rcx,[rsp+198h]
    mov     rsi,[rsp+1A0h]
    mov     [rsp+8],r15b
    mov     [rsp],rcx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym14]
    mov     rcx,[rsp+1B8h]
    mov     ecx,[rcx]
    mov     [rsp+1C0h],ecx
    lea     rcx,[image.k2088]
    mov     rsi,rbp
    and     rsi,3
    test    rsi,rsi
    je      L10
    jmp     L49
L9:
    mov     esi,[rbp]
    mov     r11,[rsp+48h]
    mov     [r11+8],esi
    lea     rsi,[rsp+1C0h]
    lea     rdi,[image.k2112]
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    je      L15
    jmp     L50
L10:
    test    rbp,rbp
    je      L49
    mov     r8,[rsp+58h]
    and     r8,3
    test    r8,r8
    jne     L49
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L49
    jmp     L9
L11:
    mov     r8,r13
    and     r8,3
    test    r8,r8
    je      L16
    jmp     L50
L12:
    cmp     rsi,r13
    jae     L13
    mov     r8,r13
    sub     r8,rsi
    jmp     L14
L13:
    mov     r8,rsi
    sub     r8,r13
L14:
    cmp     r8,4
    jb      L50
    mov     r8d,[rsp+1C0h]
    mov     r11,[rsp+48h]
    mov     [r11+14h],r8d
    mov     r11,[rsp+48h]
    lea     r11,[r11+10h]
    mov     [rsp+68h],r11
    mov     r15,[rsp+48h]
    lea     r15,[r15+20h]
    mov     r11,[rsp+48h]
    mov     r8d,[r11+20h]
    mov     r11,[rsp+48h]
    mov     r9d,[r11+10h]
    cmp     r8d,r9d
    setb    bpl
    mov     [rsp+1E0h],r15
    mov     [rsp+1D8h],r15
    mov     r10,[rsp+68h]
    mov     [rsp+1E0h],r10
    lea     rbx,[rsp+1D8h]
    lea     r12,[rsp+1E0h]
    mov     [rsp+1E8h],r12
    mov     [rsp+8],bpl
    mov     [rsp],rbx
    mov     [rsp+10h],r12
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    mov     [rsp],r12
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+1E8h]
    mov     [rsp+70h],r11
    mov     r8,[rsp+1C8h]
    mov     [rsp+1F8h],r8
    mov     rdi,r8
    call    image.sym13
    jmp     L17
L15:
    test    rsi,rsi
    je      L50
    jmp     L11
L16:
    test    r13,r13
    je      L50
    jmp     L12
L17:
    mov     r10,[rsp+70h]
    mov     [rsp+1F8h],r10
    mov     rsi,[rsp+1D8h]
    mov     r8,[rsp+1E0h]
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+1F8h]
    mov     r10,[rsp+68h]
    mov     [rsp+220h],r10
    mov     r10,[rsp+68h]
    mov     [rsp+218h],r10
    mov     [rsp+220h],r15
    lea     r13,[rsp+218h]
    lea     rbx,[rsp+220h]
    mov     [rsp+228h],rbx
    mov     [rsp+8],bpl
    mov     [rsp],r13
    mov     [rsp+10h],rbx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    mov     [rsp],rbx
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     rbx,[rsp+228h]
    mov     rsi,[rsp+208h]
    mov     [rsp+238h],rsi
    mov     rdi,rsi
    call    image.sym13
    mov     [rsp+238h],rbx
    mov     rsi,[rsp+218h]
    mov     r8,[rsp+220h]
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym14]
    mov     rsi,[rsp+238h]
    mov     esi,[rsi]
    mov     [rsp+240h],esi
    lea     rsi,[image.k2088]
    mov     r8,r12
    and     r8,3
    test    r8,r8
    je      L19
    jmp     L51
L18:
    mov     r8d,[r12]
    mov     r11,[rsp+48h]
    mov     [r11+10h],r8d
    lea     r8,[rsp+240h]
    lea     r9,[image.k2112]
    mov     r13,r8
    and     r13,3
    test    r13,r13
    je      L24
    jmp     L52
L19:
    test    r12,r12
    je      L51
    mov     r13,[rsp+68h]
    and     r13,3
    test    r13,r13
    jne     L51
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L51
    jmp     L18
L20:
    mov     r12,r15
    and     r12,3
    test    r12,r12
    je      L25
    jmp     L52
L21:
    cmp     r8,r15
    jae     L22
    mov     r12,r15
    sub     r12,r8
    jmp     L23
L22:
    mov     r12,r8
    sub     r12,r15
L23:
    cmp     r12,4
    jb      L52
    mov     r12d,[rsp+240h]
    mov     r11,[rsp+48h]
    mov     [r11+20h],r12d
    mov     r11,[rsp+48h]
    mov     r12d,[r11+1Ch]
    mov     r11,[rsp+48h]
    mov     r13d,[r11]
    cmp     r12d,r13d
    setb    r12b
    mov     [rsp+260h],r14
    mov     [rsp+258h],r14
    mov     r10,[rsp+48h]
    mov     [rsp+260h],r10
    lea     r13,[rsp+258h]
    lea     rbp,[rsp+260h]
    mov     [rsp+268h],rbp
    mov     [rsp+8],r12b
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+268h]
    mov     [rsp+78h],r11
    mov     rbp,[rsp+248h]
    mov     [rsp+278h],rbp
    mov     rdi,rbp
    call    image.sym13
    jmp     L26
L24:
    test    r8,r8
    je      L52
    jmp     L20
L25:
    test    r15,r15
    je      L52
    jmp     L21
L26:
    mov     r10,[rsp+78h]
    mov     [rsp+278h],r10
    mov     r8,[rsp+258h]
    mov     r15,[rsp+260h]
    mov     [rsp+8],r12b
    mov     [rsp],r8
    mov     [rsp+10h],r15
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym14]
    mov     r15,[rsp+278h]
    mov     r10,[rsp+48h]
    mov     [rsp+2A0h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+298h],r10
    mov     [rsp+2A0h],r14
    lea     rbp,[rsp+298h]
    lea     r13,[rsp+2A0h]
    mov     [rsp+2A8h],r13
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+2A8h]
    mov     [rsp+88h],r11
    mov     r8,[rsp+288h]
    mov     [rsp+2B8h],r8
    mov     rdi,r8
    call    image.sym13
    mov     r10,[rsp+88h]
    mov     [rsp+2B8h],r10
    mov     r8,[rsp+298h]
    mov     rbp,[rsp+2A0h]
    mov     [rsp+8],r12b
    mov     [rsp],r8
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym14]
    mov     r8,[rsp+2B8h]
    mov     r8d,[r8]
    mov     [rsp+2C0h],r8d
    lea     r8,[image.k2088]
    mov     r12,r15
    and     r12,3
    test    r12,r12
    je      L28
    jmp     L53
L27:
    mov     r12d,[r15]
    mov     r11,[rsp+48h]
    mov     [r11],r12d
    lea     r12,[rsp+2C0h]
    lea     r11,[image.k2112]
    mov     [rsp+80h],r11
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    je      L32
    jmp     L54
L28:
    test    r15,r15
    je      L53
    mov     rbp,[rsp+48h]
    and     rbp,3
    test    rbp,rbp
    jne     L53
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L53
    jmp     L27
L29:
    mov     r15,r14
    and     r15,3
    test    r15,r15
    jne     L54
    cmp     r12,r14
    jae     L30
    mov     r15,r14
    sub     r15,r12
    jmp     L31
L30:
    mov     r15,r12
    sub     r15,r14
L31:
    cmp     r15,4
    jb      L54
    mov     r15d,[rsp+2C0h]
    mov     r11,[rsp+48h]
    mov     [r11+1Ch],r15d
    mov     r11,[rsp+48h]
    mov     r15d,[r11+10h]
    mov     r11,[rsp+48h]
    mov     ebp,[r11+8]
    cmp     r15d,ebp
    setb    r15b
    mov     r10,[rsp+68h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+68h]
    mov     [rsp+2D8h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+2E0h],r10
    lea     rbp,[rsp+2D8h]
    lea     r13,[rsp+2E0h]
    mov     [rsp+2E8h],r13
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r13
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],r13
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     r13,[rsp+2E8h]
    mov     rbp,[rsp+2C8h]
    mov     [rsp+2F8h],rbp
    mov     rdi,rbp
    call    image.sym13
    jmp     L33
L32:
    test    r12,r12
    je      L54
    jmp     L29
L33:
    mov     [rsp+2F8h],r13
    mov     r12,[rsp+2D8h]
    mov     r14,[rsp+2E0h]
    mov     [rsp+8],r15b
    mov     [rsp],r12
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+2F8h]
    mov     r10,[rsp+58h]
    mov     [rsp+320h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+318h],r10
    mov     r10,[rsp+68h]
    mov     [rsp+320h],r10
    lea     r14,[rsp+318h]
    lea     rbp,[rsp+320h]
    mov     [rsp+328h],rbp
    mov     [rsp+8],r15b
    mov     [rsp],r14
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+328h]
    mov     [rsp+90h],r11
    mov     rbp,[rsp+308h]
    mov     [rsp+338h],rbp
    mov     rdi,rbp
    call    image.sym13
    mov     r10,[rsp+90h]
    mov     [rsp+338h],r10
    mov     rbp,[rsp+318h]
    mov     r14,[rsp+320h]
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+338h]
    mov     r14d,[r14]
    mov     [rsp+340h],r14d
    lea     r11,[image.k2088]
    mov     [rsp+0A0h],r11
    mov     r15,r12
    and     r15,3
    test    r15,r15
    je      L35
    jmp     L55
L34:
    mov     r15d,[r12]
    mov     r11,[rsp+48h]
    mov     [r11+8],r15d
    lea     r15,[rsp+340h]
    lea     r11,[image.k2112]
    mov     [rsp+98h],r11
    mov     rbp,r15
    and     rbp,3
    test    rbp,rbp
    je      L39
    jmp     L56
L35:
    test    r12,r12
    je      L55
    mov     rbp,[rsp+58h]
    and     rbp,3
    test    rbp,rbp
    je      L34
    jmp     L55
L36:
    mov     r12,[rsp+68h]
    and     r12,3
    test    r12,r12
    jne     L56
    cmp     r15,[rsp+68h]
    jae     L37
    mov     r12,[rsp+68h]
    sub     r12,r15
    jmp     L38
L37:
    mov     r12,r15
    sub     r12,[rsp+68h]
L38:
    cmp     r12,4
    jb      L56
    mov     r12d,[rsp+340h]
    mov     r11,[rsp+48h]
    mov     [r11+10h],r12d
    mov     rdi,[rsp+48h]
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,0
    mov     edx,2
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,1
    mov     edx,4
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+40h]
    call    fn0
    mov     r11,[rsp+48h]
    mov     r12d,[r11+4]
    mov     r11,[rsp+48h]
    mov     ebp,[r11]
    cmp     r12d,ebp
    setb    r12b
    mov     r10,[rsp+30h]
    mov     [rsp+360h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+358h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+360h],r10
    lea     rbp,[rsp+358h]
    lea     r14,[rsp+360h]
    mov     [rsp+368h],r14
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],r14
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+368h]
    mov     [rsp+0A8h],r11
    mov     rbp,[rsp+348h]
    mov     [rsp+378h],rbp
    mov     rdi,rbp
    call    image.sym13
    jmp     L40
L39:
    test    r15,r15
    je      L56
    jmp     L36
L40:
    mov     r10,[rsp+0A8h]
    mov     [rsp+378h],r10
    mov     r15,[rsp+358h]
    mov     rbp,[rsp+360h]
    mov     [rsp+8],r12b
    mov     [rsp],r15
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym14]
    mov     r15,[rsp+378h]
    mov     r10,[rsp+48h]
    mov     [rsp+3A0h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+398h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+3A0h],r10
    lea     rbp,[rsp+398h]
    lea     r14,[rsp+3A0h]
    mov     [rsp+3A8h],r14
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+532]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    mov     [rsp],r14
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+544]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+3A8h]
    mov     [rsp+0B0h],r11
    mov     rbp,[rsp+388h]
    mov     [rsp+3B8h],rbp
    mov     rdi,rbp
    call    image.sym13
    mov     r10,[rsp+0B0h]
    mov     [rsp+3B8h],r10
    mov     rbp,[rsp+398h]
    mov     r14,[rsp+3A0h]
    mov     [rsp+8],r12b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+556]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+568]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+3B8h]
    mov     r12d,[r12]
    mov     [rsp+3C0h],r12d
    lea     r12,[image.k2088]
    mov     r14,r15
    and     r14,3
    test    r14,r14
    je      L42
    jmp     L57
L41:
    mov     r14d,[r15]
    mov     r11,[rsp+48h]
    mov     [r11],r14d
    lea     r14,[rsp+3C0h]
    lea     r11,[image.k2112]
    mov     [rsp+0B8h],r11
    mov     rbp,r14
    and     rbp,3
    test    rbp,rbp
    je      L46
    jmp     L58
L42:
    test    r15,r15
    je      L57
    mov     rbp,[rsp+48h]
    and     rbp,3
    test    rbp,rbp
    je      L41
    jmp     L57
L43:
    mov     r15,[rsp+30h]
    and     r15,3
    test    r15,r15
    jne     L58
    cmp     r14,[rsp+30h]
    jae     L44
    mov     r15,[rsp+30h]
    sub     r15,r14
    jmp     L45
L44:
    mov     r15,r14
    sub     r15,[rsp+30h]
L45:
    cmp     r15,4
    jb      L58
    mov     r15d,[rsp+3C0h]
    mov     r11,[rsp+48h]
    mov     [r11+4],r15d
    mov     rdi,[rsp+48h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,3
    mov     edx,5
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+40h]
    call    fn0
    mov     rdi,[rsp+48h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+40h]
    call    fn0
    add     rsp,3C8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L46:
    test    r14,r14
    je      L58
    jmp     L43
    mov     r14,rax
    mov     rdi,[rsp+38h]
    call    image.sym13
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     r14,rax
    lea     r15,[rsp+130h]
    mov     rdi,r15
    call    qword ptr [image.fn199.slot]
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L47:
    lea     r14,[image.k8904]
    mov     rdi,r14
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L48:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     r14,rax
    mov     rdi,[rsp+50h]
    call    image.sym13
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     r14,rax
    mov     rdi,[rsp+60h]
    call    image.sym13
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L49:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L50:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     r14,rax
    mov     rdi,[rsp+70h]
    call    image.sym13
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     r14,rax
    mov     rdi,rbx
    call    image.sym13
    mov     [rsp+20h],r14
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L51:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+78h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+88h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L53:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L54:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,r13
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+90h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L55:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L56:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+0A8h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+0B0h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3F0h]
    mov     esi,0FFFFFC30h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L57:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L59:
    lea     rdi,[rsp+3F0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,0B8h
    lea     rbx,[rdi+rsi*4]
    lea     r12,[rdi+rdx*4]
    mov     eax,[r12]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+50h],r12
    mov     [rsp+48h],r12
    mov     [rsp+50h],rbx
    lea     r14,[rsp+48h]
    lea     r15,[rsp+50h]
    mov     [rsp+58h],r15
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],r15
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],r15
    mov     [rsp+10h],r14
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+58h]
    mov     [rsp+30h],r11
    mov     rax,[rsp+38h]
    mov     [rsp+68h],rax
    mov     rdi,rax
    call    image.sym13
    mov     r10,[rsp+30h]
    mov     [rsp+68h],r10
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym14]
    mov     r15,[rsp+68h]
    mov     [rsp+90h],rbx
    mov     [rsp+88h],rbx
    mov     [rsp+90h],r12
    lea     rbp,[rsp+88h]
    lea     r14,[rsp+90h]
    mov     [rsp+98h],r14
    mov     [rsp+8],r13b
    mov     [rsp],rbp
    mov     [rsp+10h],r14
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],rbp
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     r14,[rsp+98h]
    mov     rax,[rsp+78h]
    mov     [rsp+0A8h],rax
    mov     rdi,rax
    call    image.sym13
    mov     [rsp+0A8h],r14
    mov     rax,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+0A8h]
    mov     eax,[rax]
    mov     [rsp+0B0h],eax
    lea     rax,[k3]
    mov     rcx,r15
    and     rcx,3
    test    rcx,rcx
    je      L1
    jmp     L9
L0:
    mov     ecx,[r15]
    mov     [rbx],ecx
    jmp     L2
L1:
    test    r15,r15
    je      L9
    mov     rcx,rbx
    and     rcx,3
    test    rcx,rcx
    jne     L9
    test    rbx,rbx
    je      L9
    jmp     L0
L2:
    lea     rcx,[rsp+0B0h]
    lea     rdx,[k5]
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    je      L7
    jmp     L10
L3:
    mov     rsi,r12
    and     rsi,3
    test    rsi,rsi
    je      L8
    jmp     L10
L4:
    cmp     rcx,r12
    jae     L5
    mov     rsi,r12
    sub     rsi,rcx
    jmp     L6
L5:
    mov     rsi,rcx
    sub     rsi,r12
L6:
    cmp     rsi,4
    jb      L10
    mov     esi,[rsp+0B0h]
    mov     [r12],esi
    add     rsp,0B8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L7:
    test    rcx,rcx
    je      L10
    jmp     L3
L8:
    test    r12,r12
    je      L10
    jmp     L4
    mov     rbx,rax
    mov     rdi,[rsp+30h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,r14
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L9:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L10:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
  ; OSR entries
    lea     r11,[L11]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L11:
    .long   L12
L12:
    ret

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    push    rbx
    sub     rsp,10h
    mov     rax,[rdi+18h]
    lea     rax,[rax-8]
    jmp     L9
L0:
    mov     rcx,[rdi]
    jmp     L2
L1:
    mov     rcx,rax
L2:
    mov     rdx,[rdi+10h]
    lea     rcx,[rcx+rdx*8]
    mov     rdx,[rdi+8]
    lea     r8,[k0]
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L7
    jmp     L10
L3:
    mov     r9,rcx
    and     r9,3
    test    r9,r9
    je      L8
    jmp     L10
L4:
    cmp     rdx,rcx
    jae     L5
    mov     r9,rcx
    sub     r9,rdx
    jmp     L6
L5:
    mov     r9,rdx
    sub     r9,rcx
L6:
    cmp     r9,8
    jb      L10
    mov     r9d,[rdx]
    mov     ebx,[rdx+4]
    mov     [rcx],r9d
    mov     [rcx+4],ebx
    movzx   r9d,sil
    mov     rbx,[rdi+10h]
    add     rbx,r9
    mov     [rdi+10h],rbx
    mov     r9,[rdi+8]
    lea     r9,[r9+8]
    mov     [rdi+8],r9
    mov     rax,rcx
    add     rsp,10h
    pop     rbx
    ret
L7:
    test    rdx,rdx
    je      L10
    jmp     L3
L8:
    test    rcx,rcx
    je      L10
    jmp     L4
L9:
    mov     [rdi+18h],rax
    test    sil,sil
    jne     L0
    jmp     L1
L10:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
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
    ret
L14:
    ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,1D8h
    mov     [rsp+0D8h],rbx
    mov     [rsp+0D0h],r12
    mov     [rsp+0C8h],r13
    mov     [rsp+0C0h],r14
    mov     [rsp+0B8h],r15
    mov     [rsp+0B0h],rbp
    mov     rax,[rsp+1E0h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rbp,r8
    mov     [rsp+20h],r9
L0:
    mov     r10,[rsp+50h]
    mov     [rsp+110h],r10
    call    fn0
    cmp     rax,[rsp+48h]
    jb      L1
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+38h]
    mov     r8,[rsp+30h]
    call    qword ptr [image.fn81.slot]
    jmp     L21
L1:
    test    ebp,ebp
    jne     L2
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+38h]
    mov     r8d,1
    mov     r9,[rsp+30h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
    jmp     L21
L2:
    lea     r11d,[rbp-1]
    mov     [rsp+28h],r11
    mov     r10,[rsp+48h]
    mov     [rsp+110h],r10
    mov     r11,[rsp+48h]
    cmp     r11,8
    jb      L27
    mov     rax,[rsp+48h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+50h]
    lea     rbp,[r11+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+50h]
    lea     r15,[r11+rcx*8]
    mov     r11,[rsp+48h]
    cmp     r11,40h
    jae     L6
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     ecx,[r11]
    mov     edx,[rbp]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r15]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L4
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L3
    mov     rcx,r15
    jmp     L5
L3:
    mov     rcx,rbp
    jmp     L5
L4:
    mov     rcx,[rsp+50h]
L5:
    lea     rdx,[image.k1336]
    cmp     rcx,[rsp+50h]
    jb      L24
    sub     rcx,[rsp+50h]
    shr     rcx,3
    mov     rax,rcx
    jmp     L10
L6:
    mov     r14,rax
    shr     r14,3
    mov     r13,r14
    imul    r13,4
    mov     r11,[rsp+50h]
    lea     rax,[r11+r13*8]
    mov     r12,r14
    imul    r12,7
    mov     r11,[rsp+50h]
    lea     rcx,[r11+r12*8]
    mov     rdi,[rsp+50h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+30h]
    call    image.fn58
    mov     rbx,rax
    lea     rax,[rbp+r13*8]
    lea     rcx,[rbp+r12*8]
    mov     rdi,rbp
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+30h]
    call    image.fn58
    mov     rbp,rax
    lea     rax,[r15+r13*8]
    lea     rcx,[r15+r12*8]
    mov     rdi,r15
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+30h]
    call    image.fn58
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     ecx,[rbx]
    mov     esi,[rbp]
    cmp     ecx,esi
    setb    dil
    mov     r8d,[rax]
    cmp     ecx,r8d
    setb    cl
    cmp     dil,cl
    jne     L8
    cmp     esi,r8d
    setb    cl
    xor     ecx,edi
    test    cl,cl
    je      L7
    jmp     L9
L7:
    mov     rax,rbp
    jmp     L9
L8:
    mov     rax,rbx
L9:
    lea     rcx,[image.k1464]
    cmp     rax,[rsp+50h]
    jb      L25
    sub     rax,[rsp+50h]
    shr     rax,3
L10:
    cmp     rax,[rsp+48h]
    setb    sil
    lea     rdi,[image.k1512]
    test    sil,sil
    je      L26
    mov     r11,[rsp+50h]
    lea     rsi,[r11+rax*8]
    mov     rsi,[rsi]
    mov     [rsp+110h],rsi
    lea     rsi,[rsp+110h]
    mov     [rsp+0F8h],rsi
    mov     r8,[rsp+48h]
    mov     r9,rax
    mov     rax,[rsp+20h]
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+38h]
    mov     r14,[rsp+28h]
    mov     r15,rsi
    mov     rsi,[rsp+50h]
    jmp     L22
L11:
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+98h]
    jae     L31
    mov     r10,[rsp+58h]
    lea     rbp,[rsi+r10*8]
    mov     [rsp+0F0h],rbp
    mov     [rsp+0F8h],rax
    mov     r11,[rbx]
    mov     r9d,[rax]
    mov     ebp,[rbp]
    cmp     r9d,ebp
    setb    r9b
    mov     rbp,r9
    xor     ebp,1
    cmp     r9b,1
    jne     L12
    jmp     L13
L12:
    mov     r11,[rsp+98h]
    mov     [rsp+78h],r11
    mov     [rsp+80h],r14
    mov     r14,r12
    mov     r12d,0
    mov     [rsp+88h],rax
    mov     rax,[rsp+58h]
    mov     r10,rbx
    mov     rbx,rsi
    mov     rsi,r15
    mov     r15,r13
    mov     r13,r10
    jmp     L15
L13:
    mov     rbp,[rsp+58h]
    mov     [rsp+60h],r14
    mov     r14,r12
    mov     r12,[rsp+98h]
    mov     [rsp+68h],r15
    mov     r15,r13
    mov     r13,rbx
    mov     rbx,rsi
    mov     [rsp+70h],rax
    jmp     L14
L14:
    mov     [rsp],r13
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,rbp
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    test    rax,rax
    sete    sil
    mov     [rsp+78h],r12
    mov     r12,rax
    mov     rax,rbp
    mov     rbp,rsi
    mov     r11,[rsp+60h]
    mov     [rsp+80h],r11
    mov     rsi,[rsp+68h]
    mov     r11,[rsp+70h]
    mov     [rsp+88h],r11
L15:
    test    bpl,bpl
    je      L16
    mov     [rsp+0F8h],rbx
    mov     [rsp+0E8h],r13
    lea     r9,[rsp+0E8h]
    mov     [rsp+0F0h],r9
    mov     [rsp],r9
    mov     rdi,rbx
    mov     rsi,[rsp+78h]
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,rax
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     [rsp+90h],rax
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+90h]
    jb      L32
    mov     r9,[rsp+78h]
    sub     r9,[rsp+90h]
    mov     [rsp+0F8h],r9
    mov     r10,[rsp+78h]
    mov     [rsp+0E0h],r10
    mov     r10,[rsp+90h]
    lea     rbp,[rbx+r10*8]
    mov     [rsp+0E8h],rbp
    mov     [rsp+0F0h],r9
    mov     [rsp+50h],rbp
    mov     [rsp+48h],r9
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],r13
    mov     rbp,[rsp+80h]
    mov     qword ptr [rsp+20h],0
    jmp     L0
L16:
    lea     r11,[k12]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+78h]
    cmp     r11,r12
    jb      L30
    lea     rbp,[image.k6272]
    mov     rax,rbx
    and     rax,3
    test    rax,rax
    je      L18
    jmp     L28
L17:
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L28
    lea     rax,[rbx+r12*8]
    mov     r8,[rsp+78h]
    sub     r8,r12
    mov     r9,rax
    and     r9,3
    test    r9,r9
    je      L20
    jmp     L29
L18:
    test    rbx,rbx
    je      L28
    jmp     L17
L19:
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r8,r10
    ja      L29
    mov     [rsp+0E0h],rbx
    mov     [rsp+0E8h],r12
    mov     [rsp+0F0h],rax
    mov     [rsp+0F8h],r8
    mov     [rsp],r13
    mov     rdi,rax
    mov     rdx,r14
    mov     rcx,r15
    mov     r9,rsi
    mov     rsi,r8
    mov     r8,[rsp+80h]
    mov     r8d,r8d
    call    fn14
    mov     [rsp+50h],rbx
    mov     [rsp+48h],r12
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],r13
    mov     rbp,[rsp+80h]
    mov     r11,[rsp+88h]
    mov     [rsp+20h],r11
    jmp     L0
L20:
    test    rax,rax
    je      L29
    jmp     L19
L21:
    mov     rbx,[rsp+0D8h]
    mov     r12,[rsp+0D0h]
    mov     r13,[rsp+0C8h]
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0B8h]
    mov     rbp,[rsp+0B0h]
    add     rsp,1D8h
    ret
L22:
    test    rax,rax
    je      L23
    mov     [rsp+98h],r8
    mov     [rsp+58h],r9
    jmp     L11
L23:
    mov     rbp,r9
    mov     [rsp+60h],r14
    mov     r14,r12
    mov     r12,r8
    mov     [rsp+68h],r15
    mov     r15,r13
    mov     r13,rbx
    mov     rbx,rsi
    mov     [rsp+70h],rax
    jmp     L14
L24:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L26:
    lea     rax,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L27:
    lea     rdi,[rsp+1D0h]
    call    ryo_h_Abort
    ud2
L28:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L29:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L30:
    lea     rax,[image.k6296]
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,[rsp+0A0h]
    call    image.sym6
    ud2
L31:
    lea     rax,[k7]
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+98h]
    mov     rdx,rax
    call    sym5
    ud2
L32:
    lea     rax,[k15]
    mov     rdi,[rsp+90h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+78h]
    mov     rcx,rax
    call    sym16
    ud2
  ; OSR entries
    lea     r11,[L33]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L33:
    .long   L34
    .long   L35
    .long   L36
    .long   L37
L34:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-210h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-20h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+38h],r11
    mov     [rdx-0F8h],rbx
    mov     [rdx-100h],r12
    mov     [rdx-108h],r13
    mov     [rdx-110h],r14
    mov     [rdx-118h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp]
    mov     [rdx-180h],r11
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B0h],r11
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+40h]
    jmp     L0
L35:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-220h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+48h],r11
    mov     [rdx-0F8h],rbx
    mov     [rdx-100h],r12
    mov     [rdx-108h],r13
    mov     [rdx-110h],r14
    mov     [rdx-118h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-178h],r11
    mov     rax,[rsp]
    mov     rsi,[rsp+8]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L11
L36:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-220h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+28h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+48h],r11
    mov     [rdx-0F8h],rbx
    mov     [rdx-100h],r12
    mov     [rdx-108h],r13
    mov     [rdx-110h],r14
    mov     [rdx-118h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L14
L37:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-220h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0B8h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11d,[rdx-24h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+48h],r11
    mov     [rdx-0F8h],rbx
    mov     [rdx-100h],r12
    mov     [rdx-108h],r13
    mov     [rdx-110h],r14
    mov     [rdx-118h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1D0h],r11
    mov     rax,[rsp]
    mov     rsi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L22

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     r11,[rax]
    mov     eax,[rdx]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    al
    xor     eax,1
    movzx   eax,al
    add     rsp,18h
    ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    sub     rsp,208h
    mov     [rsp+0F8h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E8h],r13
    mov     [rsp+0E0h],r14
    mov     [rsp+0D8h],r15
    mov     [rsp+0D0h],rbp
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],r8
    mov     [rsp+40h],r9
    mov     r11,[rsp+210h]
    mov     [rsp+38h],r11
    cmp     rcx,[rsp+58h]
    jb      L83
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+48h]
    jbe     L83
    jmp     L72
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+200h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rcx,[rsp+0C0h]
    lea     rcx,[r12+rcx*8]
    mov     r11,[rsp+20h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+70h],r11
L1:
    mov     rdx,[rsp+108h]
    cmp     rdx,rcx
    jae     L37
    mov     rsi,[r14]
    mov     r11,[rsi]
    mov     esi,[r13]
    mov     edx,[rdx]
    cmp     esi,edx
    setb    dl
    mov     rsi,rdx
    xor     esi,1
    mov     rdi,[rsp+118h]
    lea     rdi,[rdi-8]
    mov     [rsp+118h],rdi
    test    dl,dl
    jne     L2
    mov     rdx,[rsp+100h]
    jmp     L3
L2:
    mov     rdx,rdi
L3:
    mov     rdi,[rsp+110h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r8,rdi
    and     r8,3
    test    r8,r8
    je      L8
    jmp     L74
L4:
    mov     r8,rdx
    and     r8,3
    test    r8,r8
    je      L9
    jmp     L74
L5:
    cmp     rdi,rdx
    jae     L6
    mov     r8,rdx
    sub     r8,rdi
    jmp     L7
L6:
    mov     r8,rdi
    sub     r8,rdx
L7:
    cmp     r8,8
    jb      L74
    mov     r8d,[rdi]
    mov     r9d,[rdi+4]
    mov     [rdx],r8d
    mov     [rdx+4],r9d
    movzx   r8d,sil
    mov     r9,[rsp+110h]
    add     r9,r8
    mov     [rsp+110h],r9
    mov     r8,[rsp+108h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+108h],r9
    mov     r9,[r14]
    mov     r11,[r9]
    mov     r9d,[r13]
    mov     r8d,[r8+8]
    cmp     r9d,r8d
    setb    r8b
    mov     r9,r8
    xor     r9d,1
    mov     rax,[rsp+118h]
    lea     rax,[rax-8]
    mov     [rsp+118h],rax
    test    r8b,r8b
    jne     L11
    jmp     L10
L8:
    test    rdi,rdi
    je      L74
    jmp     L4
L9:
    test    rdx,rdx
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+100h]
    jmp     L12
L11:
    mov     rdx,rax
L12:
    mov     rax,[rsp+110h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     rdi,rax
    and     rdi,3
    test    rdi,rdi
    je      L17
    jmp     L75
L13:
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L18
    jmp     L75
L14:
    cmp     rax,rdx
    jae     L15
    mov     rdi,rdx
    sub     rdi,rax
    jmp     L16
L15:
    mov     rdi,rax
    sub     rdi,rdx
L16:
    cmp     rdi,8
    jb      L75
    mov     edi,[rax]
    mov     r8d,[rax+4]
    mov     [rdx],edi
    mov     [rdx+4],r8d
    movzx   edi,r9b
    mov     r8,[rsp+110h]
    add     r8,rdi
    mov     [rsp+110h],r8
    mov     rdi,[rsp+108h]
    mov     r8,rdi
    lea     r8,[r8+8]
    mov     [rsp+108h],r8
    mov     r8,[r14]
    mov     r11,[r8]
    mov     r8d,[r13]
    mov     edi,[rdi+8]
    cmp     r8d,edi
    setb    dil
    mov     r8,rdi
    xor     r8d,1
    mov     rsi,[rsp+118h]
    lea     rsi,[rsi-8]
    mov     [rsp+118h],rsi
    test    dil,dil
    jne     L20
    jmp     L19
L17:
    test    rax,rax
    je      L75
    jmp     L13
L18:
    test    rdx,rdx
    je      L75
    jmp     L14
L19:
    mov     rax,[rsp+100h]
    jmp     L21
L20:
    mov     rax,rsi
L21:
    mov     rdx,[rsp+110h]
    lea     rax,[rax+rdx*8]
    mov     rdx,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L26
    jmp     L76
L22:
    mov     rdi,rax
    and     rdi,3
    test    rdi,rdi
    je      L27
    jmp     L76
L23:
    cmp     rdx,rax
    jae     L24
    mov     rdi,rax
    sub     rdi,rdx
    jmp     L25
L24:
    mov     rdi,rdx
    sub     rdi,rax
L25:
    cmp     rdi,8
    jb      L76
    mov     edi,[rdx]
    mov     r9d,[rdx+4]
    mov     [rax],edi
    mov     [rax+4],r9d
    movzx   edi,r8b
    mov     r9,[rsp+110h]
    add     r9,rdi
    mov     [rsp+110h],r9
    mov     rdi,[rsp+108h]
    mov     r9,rdi
    lea     r9,[r9+8]
    mov     [rsp+108h],r9
    mov     r9,[r14]
    mov     r11,[r9]
    mov     r9d,[r13]
    mov     edi,[rdi+8]
    cmp     r9d,edi
    setb    dil
    mov     r9,rdi
    xor     r9d,1
    mov     [rsp+0C6h],r9b
    mov     rsi,[rsp+118h]
    lea     rsi,[rsi-8]
    mov     [rsp+118h],rsi
    test    dil,dil
    jne     L29
    jmp     L28
L26:
    test    rdx,rdx
    je      L76
    jmp     L22
L27:
    test    rax,rax
    je      L76
    jmp     L23
L28:
    mov     rax,[rsp+100h]
    jmp     L30
L29:
    mov     rax,rsi
L30:
    mov     rdx,[rsp+110h]
    lea     rax,[rax+rdx*8]
    mov     rdx,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+0B0h],r11
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L35
    jmp     L77
L31:
    mov     rdi,rax
    and     rdi,3
    test    rdi,rdi
    je      L36
    jmp     L77
L32:
    cmp     rdx,rax
    jae     L33
    mov     rdi,rax
    sub     rdi,rdx
    jmp     L34
L33:
    mov     rdi,rdx
    sub     rdi,rax
L34:
    cmp     rdi,8
    jb      L77
    mov     edi,[rdx]
    mov     r8d,[rdx+4]
    mov     [rax],edi
    mov     [rax+4],r8d
    movzx   edi,r9b
    mov     r8,[rsp+110h]
    add     r8,rdi
    mov     [rsp+110h],r8
    mov     rdi,[rsp+108h]
    lea     rdi,[rdi+8]
    mov     [rsp+108h],rdi
    jmp     L1
L35:
    test    rdx,rdx
    je      L77
    jmp     L31
L36:
    test    rax,rax
    je      L77
    jmp     L32
L37:
    mov     [rsp+0C0h],rbx
    lea     rax,[r12+rbx*8]
    mov     r11,[rsp+80h]
    mov     [rsp+98h],r11
    mov     rcx,[rsp+78h]
    mov     r11,[rsp+70h]
    mov     [rsp+0A0h],r11
L38:
    mov     rdx,[rsp+108h]
    cmp     rdx,rax
    jae     L47
    mov     rdi,[r14]
    mov     r11,[rdi]
    mov     edi,[r13]
    mov     edx,[rdx]
    cmp     edi,edx
    setb    dl
    mov     rdi,rdx
    xor     edi,1
    mov     [rsp+0C6h],dil
    mov     r8,[rsp+118h]
    lea     r8,[r8-8]
    mov     [rsp+118h],r8
    test    dl,dl
    jne     L39
    mov     rdx,[rsp+100h]
    jmp     L40
L39:
    mov     rdx,r8
L40:
    mov     r8,[rsp+110h]
    lea     rdx,[rdx+r8*8]
    mov     r8,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+0A8h],r11
    mov     r9,r8
    and     r9,3
    test    r9,r9
    je      L45
    jmp     L78
L41:
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L46
    jmp     L78
L42:
    cmp     r8,rdx
    jae     L43
    mov     r9,rdx
    sub     r9,r8
    jmp     L44
L43:
    mov     r9,r8
    sub     r9,rdx
L44:
    cmp     r9,8
    jb      L78
    mov     r9d,[r8]
    mov     esi,[r8+4]
    mov     [rdx],r9d
    mov     [rdx+4],esi
    movzx   esi,dil
    mov     r9,[rsp+110h]
    add     r9,rsi
    mov     [rsp+110h],r9
    mov     rsi,[rsp+108h]
    lea     rsi,[rsi+8]
    mov     [rsp+108h],rsi
    jmp     L38
L45:
    test    r8,r8
    je      L78
    jmp     L41
L46:
    test    rdx,rdx
    je      L78
    jmp     L42
L47:
    cmp     rbx,r15
    je      L56
    lea     rax,[rsp+100h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+118h]
    lea     rax,[rax-8]
    mov     [rsp+118h],rax
    test    bpl,bpl
    je      L48
    mov     rdx,[rsp+100h]
    jmp     L49
L48:
    mov     rdx,rax
L49:
    mov     rax,[rsp+110h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+108h]
    lea     rsi,[image.k6632]
    mov     rdi,rax
    and     rdi,3
    test    rdi,rdi
    je      L54
    jmp     L79
L50:
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L55
    jmp     L79
L51:
    cmp     rax,rdx
    jae     L52
    mov     rdi,rdx
    sub     rdi,rax
    jmp     L53
L52:
    mov     rdi,rax
    sub     rdi,rdx
L53:
    cmp     rdi,8
    jb      L79
    mov     edi,[rax]
    mov     r8d,[rax+4]
    mov     [rdx],edi
    mov     [rdx+4],r8d
    movzx   edi,bpl
    mov     r8,[rsp+110h]
    add     r8,rdi
    mov     [rsp+110h],r8
    mov     rdi,[rsp+108h]
    lea     rdi,[rdi+8]
    mov     [rsp+108h],rdi
    mov     rbx,r15
    mov     r11,[rsp+98h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],rcx
    mov     r11,[rsp+0A0h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    test    rax,rax
    je      L79
    jmp     L50
L55:
    test    rdx,rdx
    je      L79
    jmp     L51
L56:
    mov     [rsp+0C0h],rcx
    mov     rdi,[rsp+110h]
    lea     r8,[k15]
    test    rdi,rdi
    jne     L57
    mov     eax,1
    jmp     L58
L57:
    mov     eax,0
L58:
    mov     rdx,rcx
    and     rdx,3
    test    rdx,rdx
    je      L63
    jmp     L81
L59:
    mov     rdx,[rsp+98h]
    and     rdx,3
    test    rdx,rdx
    je      L64
    jmp     L81
L60:
    mov     eax,8
    mul     rdi
    mov     rdx,rax
    jb      L80
    cmp     rcx,[rsp+98h]
    jae     L61
    mov     r9,[rsp+98h]
    sub     r9,rcx
    jmp     L62
L61:
    mov     r9,rcx
    sub     r9,[rsp+98h]
L62:
    cmp     rdx,r9
    ja      L81
    mov     rdx,rdi
    imul    rdx,8
    mov     r11,[rsp+98h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE18h
    call    ryo_h_Memcpy
    mov     rdx,[rsp+110h]
    mov     r11,r15
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+0C0h],rdx
    mov     eax,0
    mov     rcx,[rsp+0A0h]
    mov     rdi,[rsp+98h]
    jmp     L65
L63:
    test    al,al
    jne     L59
    test    rcx,rcx
    je      L81
    jmp     L59
L64:
    test    al,al
    jne     L60
    mov     r11,[rsp+98h]
    cmp     r11,0
    je      L81
    jmp     L60
L65:
    cmp     rax,rdx
    jae     L73
    lea     r9,[rax+1]
    mov     [rsp+0C0h],rax
    lea     rbx,[r15-1]
    sub     rbx,rax
    lea     rbx,[rcx+rbx*8]
    mov     r12,[rsp+110h]
    add     r12,rax
    lea     rax,[rdi+r12*8]
    lea     r12,[k19]
    mov     r13,rbx
    and     r13,3
    test    r13,r13
    je      L70
    jmp     L82
L66:
    mov     r13,rax
    and     r13,3
    test    r13,r13
    je      L71
    jmp     L82
L67:
    cmp     rbx,rax
    jae     L68
    mov     r13,rax
    sub     r13,rbx
    jmp     L69
L68:
    mov     r13,rbx
    sub     r13,rax
L69:
    cmp     r13,8
    jb      L82
    mov     r13d,[rbx]
    mov     r14d,[rbx+4]
    mov     [rax],r13d
    mov     [rax+4],r14d
    mov     rax,r9
    jmp     L65
L70:
    test    rbx,rbx
    je      L82
    jmp     L66
L71:
    test    rax,rax
    je      L82
    jmp     L67
L72:
    mov     r11,[rsp+60h]
    mov     r10,[rsp+48h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+50h]
    mov     r10,[rsp+58h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+50h]
    mov     [rsp+100h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+108h],r10
    mov     qword ptr [rsp+110h],0
    mov     [rsp+118h],rcx
    mov     rbx,[rsp+48h]
    mov     r12,[rsp+60h]
    mov     r13,rax
    mov     r14,[rsp+38h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+40h]
    mov     r11,[rsp+60h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+30h],r11
    jmp     L0
L73:
    mov     rax,[rsp+110h]
    mov     rbx,[rsp+0F8h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E8h]
    mov     r14,[rsp+0E0h]
    mov     r15,[rsp+0D8h]
    mov     rbp,[rsp+0D0h]
    add     rsp,208h
    ret
L74:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L75:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L76:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L77:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L78:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L79:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L81:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L82:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L83:
    lea     rdi,[rsp+200h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L84]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L84:
    .long   L85
    .long   L86
    .long   L87
    .long   L88
    .long   L89
    .long   L90
L85:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-260h]
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
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+58h],r11
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1D0h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L86:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-270h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-190h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+30h]
    lea     rsp,[rsp+70h]
    jmp     L1
L87:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-270h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-160h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    mov     rcx,[rsp+40h]
    lea     rsp,[rsp+70h]
    jmp     L38
L88:
    ret
L89:
    ret
L90:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-240h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     r15,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,1F8h
    mov     [rsp+0E8h],rbx
    mov     [rsp+0E0h],r12
    mov     [rsp+0D8h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C8h],r15
    mov     [rsp+0C0h],rbp
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],r8
    mov     [rsp+40h],r9
    mov     r11,[rsp+200h]
    mov     [rsp+38h],r11
    cmp     rcx,[rsp+58h]
    jb      L83
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+48h]
    jbe     L83
    jmp     L72
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+1F0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rcx,[rsp+0B0h]
    lea     rcx,[r12+rcx*8]
    mov     rax,[rsp+20h]
    mov     r11,[rsp+28h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+70h],r11
L1:
    mov     rdx,[rsp+0F8h]
    cmp     rdx,rcx
    jae     L37
    mov     r11,[r14]
    mov     edx,[rdx]
    mov     esi,[r13]
    cmp     edx,esi
    setb    dl
    mov     rsi,[rsp+108h]
    lea     rsi,[rsi-8]
    mov     [rsp+108h],rsi
    test    dl,dl
    je      L2
    mov     rdi,[rsp+0F0h]
    jmp     L3
L2:
    mov     rdi,rsi
L3:
    mov     rsi,[rsp+100h]
    lea     rdi,[rdi+rsi*8]
    mov     rsi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    je      L8
    jmp     L74
L4:
    mov     r8,rdi
    and     r8,3
    test    r8,r8
    je      L9
    jmp     L74
L5:
    cmp     rsi,rdi
    jae     L6
    mov     r8,rdi
    sub     r8,rsi
    jmp     L7
L6:
    mov     r8,rsi
    sub     r8,rdi
L7:
    cmp     r8,8
    jb      L74
    mov     r8d,[rsi]
    mov     r9d,[rsi+4]
    mov     [rdi],r8d
    mov     [rdi+4],r9d
    movzx   r8d,dl
    mov     r9,[rsp+100h]
    add     r9,r8
    mov     [rsp+100h],r9
    mov     r8,[rsp+0F8h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+0F8h],r9
    mov     r11,[r14]
    mov     r8d,[r8+8]
    mov     r9d,[r13]
    cmp     r8d,r9d
    setb    r8b
    mov     r9,[rsp+108h]
    lea     r9,[r9-8]
    mov     [rsp+108h],r9
    test    r8b,r8b
    jne     L10
    jmp     L11
L8:
    test    rsi,rsi
    je      L74
    jmp     L4
L9:
    test    rdi,rdi
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+0F0h]
    jmp     L12
L11:
    mov     rdx,r9
L12:
    mov     rsi,[rsp+100h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+80h],r11
    mov     r9,rsi
    and     r9,3
    test    r9,r9
    je      L17
    jmp     L75
L13:
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L18
    jmp     L75
L14:
    cmp     rsi,rdx
    jae     L15
    mov     r9,rdx
    sub     r9,rsi
    jmp     L16
L15:
    mov     r9,rsi
    sub     r9,rdx
L16:
    cmp     r9,8
    jb      L75
    mov     r9d,[rsi]
    mov     edi,[rsi+4]
    mov     [rdx],r9d
    mov     [rdx+4],edi
    movzx   edi,r8b
    mov     r9,[rsp+100h]
    add     r9,rdi
    mov     [rsp+100h],r9
    mov     rdi,[rsp+0F8h]
    mov     r9,rdi
    lea     r9,[r9+8]
    mov     [rsp+0F8h],r9
    mov     r11,[r14]
    mov     edi,[rdi+8]
    mov     r9d,[r13]
    cmp     edi,r9d
    setb    dil
    mov     r9,[rsp+108h]
    lea     r9,[r9-8]
    mov     [rsp+108h],r9
    test    dil,dil
    jne     L19
    jmp     L20
L17:
    test    rsi,rsi
    je      L75
    jmp     L13
L18:
    test    rdx,rdx
    je      L75
    jmp     L14
L19:
    mov     rdx,[rsp+0F0h]
    jmp     L21
L20:
    mov     rdx,r9
L21:
    mov     rsi,[rsp+100h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     r9,rsi
    and     r9,3
    test    r9,r9
    je      L26
    jmp     L76
L22:
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L27
    jmp     L76
L23:
    cmp     rsi,rdx
    jae     L24
    mov     r9,rdx
    sub     r9,rsi
    jmp     L25
L24:
    mov     r9,rsi
    sub     r9,rdx
L25:
    cmp     r9,8
    jb      L76
    mov     r9d,[rsi]
    mov     r8d,[rsi+4]
    mov     [rdx],r9d
    mov     [rdx+4],r8d
    movzx   r8d,dil
    mov     r9,[rsp+100h]
    add     r9,r8
    mov     [rsp+100h],r9
    mov     r8,[rsp+0F8h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+0F8h],r9
    mov     r11,[r14]
    mov     r8d,[r8+8]
    mov     r9d,[r13]
    cmp     r8d,r9d
    setb    r8b
    mov     [rsp+0B6h],r8b
    mov     r9,[rsp+108h]
    lea     r9,[r9-8]
    mov     [rsp+108h],r9
    test    r8b,r8b
    jne     L28
    jmp     L29
L26:
    test    rsi,rsi
    je      L76
    jmp     L22
L27:
    test    rdx,rdx
    je      L76
    jmp     L23
L28:
    mov     rdx,[rsp+0F0h]
    jmp     L30
L29:
    mov     rdx,r9
L30:
    mov     rsi,[rsp+100h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     r9,rsi
    and     r9,3
    test    r9,r9
    je      L35
    jmp     L77
L31:
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L36
    jmp     L77
L32:
    cmp     rsi,rdx
    jae     L33
    mov     r9,rdx
    sub     r9,rsi
    jmp     L34
L33:
    mov     r9,rsi
    sub     r9,rdx
L34:
    cmp     r9,8
    jb      L77
    mov     r9d,[rsi]
    mov     edi,[rsi+4]
    mov     [rdx],r9d
    mov     [rdx+4],edi
    movzx   edi,r8b
    mov     r9,[rsp+100h]
    add     r9,rdi
    mov     [rsp+100h],r9
    mov     rdi,[rsp+0F8h]
    lea     rdi,[rdi+8]
    mov     [rsp+0F8h],rdi
    jmp     L1
L35:
    test    rsi,rsi
    je      L77
    jmp     L31
L36:
    test    rdx,rdx
    je      L77
    jmp     L32
L37:
    mov     [rsp+0B0h],rbx
    lea     rcx,[r12+rbx*8]
    mov     [rsp+98h],rax
    mov     rsi,[rsp+78h]
    mov     r11,[rsp+70h]
    mov     [rsp+0A0h],r11
L38:
    mov     rax,[rsp+0F8h]
    cmp     rax,rcx
    jae     L47
    mov     r11,[r14]
    mov     eax,[rax]
    mov     edx,[r13]
    cmp     eax,edx
    setb    al
    mov     [rsp+0B6h],al
    mov     rdx,[rsp+108h]
    lea     rdx,[rdx-8]
    mov     [rsp+108h],rdx
    test    al,al
    je      L39
    mov     rdi,[rsp+0F0h]
    jmp     L40
L39:
    mov     rdi,rdx
L40:
    mov     rdx,[rsp+100h]
    lea     rdi,[rdi+rdx*8]
    mov     rdx,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+0A8h],r11
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L45
    jmp     L78
L41:
    mov     r9,rdi
    and     r9,3
    test    r9,r9
    je      L46
    jmp     L78
L42:
    cmp     rdx,rdi
    jae     L43
    mov     r9,rdi
    sub     r9,rdx
    jmp     L44
L43:
    mov     r9,rdx
    sub     r9,rdi
L44:
    cmp     r9,8
    jb      L78
    mov     r9d,[rdx]
    mov     r8d,[rdx+4]
    mov     [rdi],r9d
    mov     [rdi+4],r8d
    movzx   r8d,al
    mov     r9,[rsp+100h]
    add     r9,r8
    mov     [rsp+100h],r9
    mov     r8,[rsp+0F8h]
    lea     r8,[r8+8]
    mov     [rsp+0F8h],r8
    jmp     L38
L45:
    test    rdx,rdx
    je      L78
    jmp     L41
L46:
    test    rdi,rdi
    je      L78
    jmp     L42
L47:
    cmp     rbx,r15
    je      L56
    lea     rax,[rsp+0F0h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+108h]
    lea     rax,[rax-8]
    mov     [rsp+108h],rax
    test    bpl,bpl
    je      L48
    mov     rcx,[rsp+0F0h]
    jmp     L49
L48:
    mov     rcx,rax
L49:
    mov     rax,[rsp+100h]
    lea     rcx,[rcx+rax*8]
    mov     rax,[rsp+0F8h]
    lea     rdx,[image.k6632]
    mov     rdi,rax
    and     rdi,3
    test    rdi,rdi
    je      L54
    jmp     L79
L50:
    mov     rdi,rcx
    and     rdi,3
    test    rdi,rdi
    je      L55
    jmp     L79
L51:
    cmp     rax,rcx
    jae     L52
    mov     rdi,rcx
    sub     rdi,rax
    jmp     L53
L52:
    mov     rdi,rax
    sub     rdi,rcx
L53:
    cmp     rdi,8
    jb      L79
    mov     edi,[rax]
    mov     r8d,[rax+4]
    mov     [rcx],edi
    mov     [rcx+4],r8d
    movzx   edi,bpl
    mov     r8,[rsp+100h]
    add     r8,rdi
    mov     [rsp+100h],r8
    mov     rdi,[rsp+0F8h]
    lea     rdi,[rdi+8]
    mov     [rsp+0F8h],rdi
    mov     rbx,r15
    mov     r11,[rsp+98h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],rsi
    mov     r11,[rsp+0A0h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    test    rax,rax
    je      L79
    jmp     L50
L55:
    test    rcx,rcx
    je      L79
    jmp     L51
L56:
    mov     [rsp+0B0h],rsi
    mov     rcx,[rsp+100h]
    lea     rdi,[k15]
    test    rcx,rcx
    jne     L57
    mov     eax,1
    jmp     L58
L57:
    mov     eax,0
L58:
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    je      L63
    jmp     L81
L59:
    mov     r8,[rsp+98h]
    and     r8,3
    test    r8,r8
    je      L64
    jmp     L81
L60:
    mov     eax,8
    mul     rcx
    mov     r8,rax
    jb      L80
    cmp     rsi,[rsp+98h]
    jae     L61
    mov     r9,[rsp+98h]
    sub     r9,rsi
    jmp     L62
L61:
    mov     r9,rsi
    sub     r9,[rsp+98h]
L62:
    cmp     r8,r9
    ja      L81
    mov     r8,rcx
    imul    r8,8
    mov     r11,[rsp+98h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],r8
    lea     rdi,[rsp+1F0h]
    mov     esi,0FFFFFE20h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE28h
    call    ryo_h_Memcpy
    mov     r8,[rsp+100h]
    mov     r11,r15
    sub     r11,r8
    mov     r8,r11
    mov     [rsp+0B0h],r8
    mov     eax,0
    mov     rcx,[rsp+0A0h]
    mov     rsi,[rsp+98h]
    jmp     L65
L63:
    test    al,al
    jne     L59
    test    rsi,rsi
    je      L81
    jmp     L59
L64:
    test    al,al
    jne     L60
    mov     r11,[rsp+98h]
    cmp     r11,0
    je      L81
    jmp     L60
L65:
    cmp     rax,r8
    jae     L73
    lea     r9,[rax+1]
    mov     [rsp+0B0h],rax
    lea     rbx,[r15-1]
    sub     rbx,rax
    lea     rbx,[rcx+rbx*8]
    mov     r12,[rsp+100h]
    add     r12,rax
    lea     rax,[rsi+r12*8]
    lea     r12,[k19]
    mov     r13,rbx
    and     r13,3
    test    r13,r13
    je      L70
    jmp     L82
L66:
    mov     r13,rax
    and     r13,3
    test    r13,r13
    je      L71
    jmp     L82
L67:
    cmp     rbx,rax
    jae     L68
    mov     r13,rax
    sub     r13,rbx
    jmp     L69
L68:
    mov     r13,rbx
    sub     r13,rax
L69:
    cmp     r13,8
    jb      L82
    mov     r13d,[rbx]
    mov     r14d,[rbx+4]
    mov     [rax],r13d
    mov     [rax+4],r14d
    mov     rax,r9
    jmp     L65
L70:
    test    rbx,rbx
    je      L82
    jmp     L66
L71:
    test    rax,rax
    je      L82
    jmp     L67
L72:
    mov     r11,[rsp+60h]
    mov     r10,[rsp+48h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+50h]
    mov     r10,[rsp+58h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+50h]
    mov     [rsp+0F0h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+0F8h],r10
    mov     qword ptr [rsp+100h],0
    mov     [rsp+108h],rcx
    mov     rbx,[rsp+48h]
    mov     r12,[rsp+60h]
    mov     r13,rax
    mov     r14,[rsp+38h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+40h]
    mov     r11,[rsp+60h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+30h],r11
    jmp     L0
L73:
    mov     rax,[rsp+100h]
    mov     rbx,[rsp+0E8h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D8h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C8h]
    mov     rbp,[rsp+0C0h]
    add     rsp,1F8h
    ret
L74:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L75:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L76:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L77:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L78:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L79:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L81:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L82:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L83:
    lea     rdi,[rsp+1F0h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L84]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L84:
    .long   L85
    .long   L86
    .long   L87
    .long   L88
    .long   L89
    .long   L90
L85:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-250h]
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
    mov     r11,[rdx-18h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+58h],r11
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1C0h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L86:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-260h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-180h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rax,[rsp+38h]
    lea     rsp,[rsp+70h]
    jmp     L1
L87:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-260h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-150h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    mov     rsi,[rsp+40h]
    lea     rsp,[rsp+70h]
    jmp     L38
L88:
    ret
L89:
    ret
L90:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-230h]
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
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     r8,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rsi,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    push    rbx
    push    r12
    sub     rsp,8
    mov     r11,[rdi]
    mov     rax,[rsi+10h]
    mov     rcx,[rdi+8]
    mov     eax,[rax]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    al
    mov     rcx,[rdi+10h]
    mov     rcx,[rcx]
    mov     rdx,[rsi+18h]
    lea     rcx,[rcx+rdx*4]
    mov     rdx,[rsi]
    lea     rdi,[k1]
    mov     r8,rcx
    and     r8,3
    test    r8,r8
    je      L1
    jmp     L7
L0:
    mov     r8d,[rcx]
    mov     [rdx],r8d
    jmp     L2
L1:
    test    rcx,rcx
    je      L7
    mov     r8,rdx
    and     r8,3
    test    r8,r8
    jne     L7
    test    rdx,rdx
    je      L7
    jmp     L0
L2:
    mov     rdx,[rsi+10h]
    lea     r8,[k3]
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L6
    jmp     L8
L3:
    mov     r9,rcx
    and     r9,3
    test    r9,r9
    jne     L8
    cmp     rdx,rcx
    jae     L4
    mov     r9,rcx
    sub     r9,rdx
    jmp     L5
L4:
    mov     r9,rdx
    sub     r9,rcx
L5:
    cmp     r9,4
    jb      L8
    mov     r9d,[rdx]
    mov     [rcx],r9d
    mov     r9,[rsi+10h]
    mov     [rsi],r9
    movzx   ebx,al
    mov     r12,[rsi+18h]
    add     r12,rbx
    mov     [rsi+18h],r12
    lea     r9,[r9+4]
    mov     [rsi+10h],r9
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L6:
    test    rdx,rdx
    je      L8
    jmp     L3
L7:
    lea     rax,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L8:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
  ; OSR entries
    lea     r11,[L9]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L9:
    .long   L10
L10:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,298h
    mov     [rsp+1C0h],rbx
    mov     [rsp+1B8h],r12
    mov     [rsp+1B0h],r13
    mov     [rsp+1A8h],r14
    mov     [rsp+1A0h],r15
    mov     [rsp+198h],rbp
    mov     [rsp+28h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+20h],r8
    mov     [rsp+18h],rdx
L0:
    mov     r11d,20h
    cmp     r11,[rsp+10h]
    jb      L25
    mov     r11,[rsp+10h]
    cmp     r11,2
    jb      L92
    mov     r15,[rsp+10h]
    shr     r15,1
    mov     r11,[rsp+10h]
    cmp     r11,12h
    setb    [rsp+30h]
    cmp     byte ptr [rsp+30h],0
    je      L1
    mov     r12,[rsp+10h]
    jmp     L2
L1:
    mov     r12,r15
L2:
    lea     rax,[image.k2160]
    mov     rdi,[rsp+28h]
    mov     esi,4
    mov     edx,4
    mov     rcx,r12
    mov     r8,rax
    call    image.fn187
    mov     r14,r12
    mov     r12,[rsp+28h]
L3:
    cmp     r14,0Dh
    jb      L4
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,[rsp+20h]
    call    qword ptr [image.fn74.slot]
    mov     eax,0Dh
    jmp     L6
L4:
    cmp     r14,9
    jb      L5
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,[rsp+20h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L6
L5:
    mov     eax,1
L6:
    test    rax,rax
    je      L96
    cmp     r14,rax
    jb      L96
    lea     r14,[r12+r14*4]
    lea     rax,[r12+rax*4]
    mov     r13,rax
L7:
    cmp     r13,r14
    je      L21
    mov     rax,r13
    lea     rax,[rax-4]
    mov     edx,[r13]
    mov     esi,[r13-4]
    cmp     edx,esi
    setb    dl
    mov     [rsp+0CFh],dl
    test    dl,dl
    je      L19
    mov     edx,[r13]
    mov     [rsp+0CCh],edx
    lea     rbx,[rsp+0CCh]
    mov     rbp,rax
    mov     rax,r13
L8:
    lea     rdx,[image.k1728]
    mov     rsi,rbp
    and     rsi,3
    test    rsi,rsi
    je      L13
    jmp     L93
L9:
    mov     rsi,rax
    and     rsi,3
    test    rsi,rsi
    je      L14
    jmp     L93
L10:
    cmp     rbp,rax
    jae     L11
    mov     rsi,rax
    sub     rsi,rbp
    jmp     L12
L11:
    mov     rsi,rbp
    sub     rsi,rax
L12:
    cmp     rsi,4
    jb      L93
    mov     esi,[rbp]
    mov     [rax],esi
    cmp     rbp,r12
    je      L16
    jmp     L20
L13:
    test    rbp,rbp
    je      L93
    jmp     L9
L14:
    test    rax,rax
    je      L93
    jmp     L10
L15:
    mov     r10,rbp
    mov     rbp,rax
    mov     rax,r10
    jmp     L8
L16:
    lea     r11,[image.k10520]
    mov     [rsp+38h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    test    sil,sil
    jne     L18
    jmp     L94
L17:
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    test    sil,sil
    je      L94
    mov     rdi,rbx
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    mov     rsi,rax
    test    sil,sil
    je      L94
    mov     esi,[rsp+0CCh]
    mov     [rbp],esi
    jmp     L19
L18:
    test    rbx,rbx
    je      L94
    jmp     L17
L19:
    mov     rsi,r13
    lea     rsi,[rsi+4]
    mov     r13,rsi
    jmp     L7
L20:
    mov     rax,rbp
    lea     rax,[rax-4]
    mov     esi,[rsp+0CCh]
    mov     edi,[rbp-4]
    cmp     esi,edi
    jb      L15
    jmp     L16
L21:
    cmp     byte ptr [rsp+30h],0
    jne     L92
    cmp     r12,[rsp+28h]
    je      L22
    lea     rbx,[rsp+0D8h]
    lea     rax,[image.k2208]
    mov     rdi,[rsp+28h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+10h]
    mov     r8,rax
    call    image.fn187
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,rbx
    mov     rcx,[rsp+20h]
    call    qword ptr [image.fn78.slot]
    lea     rax,[image.k2232]
    mov     rdi,rbx
    mov     rsi,[rsp+28h]
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+10h]
    mov     r9,rax
    call    image.fn180
    mov     rax,[rsp+10h]
    imul    rax,4
    mov     rdi,[rsp+28h]
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L92
L22:
    mov     r11,[rsp+28h]
    lea     rax,[r11+r15*4]
    mov     rsi,[rsp+10h]
    sub     rsi,r15
    lea     rdi,[image.k2184]
    mov     r8,rax
    and     r8,3
    test    r8,r8
    je      L24
    jmp     L97
L23:
    mov     r12,rax
    mov     r14,rsi
    jmp     L3
L24:
    test    rax,rax
    je      L97
    jmp     L23
L25:
    test    ecx,ecx
    jne     L26
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    call    qword ptr [fn2.slot]
    jmp     L92
L26:
    lea     r11d,[rcx-1]
    mov     [rsp+40h],r11
    mov     rax,[rsp+10h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+28h]
    lea     r12,[r11+rcx*4]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+28h]
    lea     r13,[r11+rcx*4]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L30
    mov     r11,[rsp+28h]
    mov     ecx,[r11]
    mov     esi,[r12]
    cmp     ecx,esi
    setb    r8b
    mov     r9d,[r13]
    cmp     ecx,r9d
    setb    cl
    cmp     r8b,cl
    jne     L28
    cmp     esi,r9d
    setb    cl
    xor     ecx,r8d
    test    cl,cl
    je      L27
    mov     rcx,r13
    jmp     L29
L27:
    mov     rcx,r12
    jmp     L29
L28:
    mov     rcx,[rsp+28h]
L29:
    lea     rsi,[image.k1536]
    cmp     rcx,[rsp+28h]
    jb      L98
    sub     rcx,[rsp+28h]
    shr     rcx,2
    mov     rax,rcx
    jmp     L34
L30:
    mov     r14,rax
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    mov     r11,[rsp+28h]
    lea     rax,[r11+r15*4]
    mov     rbp,r14
    imul    rbp,7
    mov     r11,[rsp+28h]
    lea     rcx,[r11+rbp*4]
    mov     rdi,[rsp+28h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     rbx,rax
    lea     rax,[r12+r15*4]
    lea     rcx,[r12+rbp*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     r12,rax
    lea     rax,[r13+r15*4]
    lea     rcx,[r13+rbp*4]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     ecx,[rbx]
    mov     r8d,[r12]
    cmp     ecx,r8d
    setb    r9b
    mov     r13d,[rax]
    cmp     ecx,r13d
    setb    cl
    cmp     r9b,cl
    jne     L32
    cmp     r8d,r13d
    setb    cl
    xor     ecx,r9d
    test    cl,cl
    je      L31
    jmp     L33
L31:
    mov     rax,r12
    jmp     L33
L32:
    mov     rax,rbx
L33:
    lea     rcx,[image.k1584]
    cmp     rax,[rsp+28h]
    jb      L99
    sub     rax,[rsp+28h]
    shr     rax,2
L34:
    cmp     rax,[rsp+10h]
    setb    r8b
    lea     r9,[image.k1632]
    test    r8b,r8b
    je      L100
    mov     r11,[rsp+18h]
    cmp     r11,0
    je      L62
    mov     r11,[rsp+28h]
    lea     r8,[r11+rax*4]
    mov     r11,[rsp+18h]
    mov     ebx,[r11]
    mov     r12d,[r8]
    cmp     ebx,r12d
    jb      L62
    mov     r10,[rsp+20h]
    mov     [rsp+1F0h],r10
    lea     rbx,[rsp+1F0h]
    lea     r12,[rsp+15Ch]
    lea     r13,[image.k488]
    mov     r14,[rsp+28h]
    and     r14,3
    test    r14,r14
    je      L39
    jmp     L101
L35:
    mov     r14,r12
    and     r14,3
    test    r14,r14
    je      L40
    jmp     L101
L36:
    mov     r11,[rsp+28h]
    cmp     r11,r12
    jae     L37
    mov     r14,r12
    sub     r14,[rsp+28h]
    jmp     L38
L37:
    mov     r14,[rsp+28h]
    sub     r14,r12
L38:
    cmp     r14,4
    jb      L101
    mov     r11,[rsp+28h]
    mov     r14d,[r11]
    mov     [rsp+15Ch],r14d
    lea     r14,[image.k512]
    mov     r15,r8
    and     r15,3
    test    r15,r15
    je      L42
    jmp     L102
L39:
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L101
    jmp     L35
L40:
    test    r12,r12
    je      L101
    jmp     L36
L41:
    mov     r12d,[r8]
    mov     r11,[rsp+28h]
    mov     [r11],r12d
    lea     r12,[rsp+15Ch]
    lea     r15,[image.k536]
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    je      L46
    jmp     L103
L42:
    test    r8,r8
    je      L102
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    je      L41
    jmp     L102
L43:
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    jne     L103
    cmp     r12,r8
    jae     L44
    mov     rbp,r8
    sub     rbp,r12
    jmp     L45
L44:
    mov     rbp,r12
    sub     rbp,r8
L45:
    cmp     rbp,4
    jb      L103
    mov     ebp,[rsp+15Ch]
    mov     [r8],ebp
    lea     r11,[image.k6360]
    mov     [rsp+48h],r11
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    je      L47
    jmp     L104
L46:
    test    r12,r12
    je      L103
    jmp     L43
L47:
    mov     r8,[rsp+28h]
    lea     r8,[r8+4]
    mov     r12,[rsp+10h]
    sub     r12,1
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    je      L49
    jmp     L105
L48:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L105
    mov     rbp,[image.sym36]
    mov     rdi,r8
    mov     rsi,r12
    mov     rdx,[rsp+28h]
    mov     rcx,rbx
    mov     rax,rbp
    call    rax
    mov     rbp,rax
    cmp     rbp,[rsp+10h]
    jb      L50
    jmp     L109
L49:
    test    r8,r8
    je      L105
    jmp     L48
L50:
    mov     r11,[rsp+28h]
    lea     r8,[r11+rbp*4]
    lea     rbx,[rsp+16Ch]
    lea     r11,[image.k488]
    mov     [rsp+50h],r11
    mov     r12,[rsp+28h]
    and     r12,3
    test    r12,r12
    jne     L106
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    je      L54
    jmp     L106
L51:
    mov     r11,[rsp+28h]
    cmp     r11,rbx
    jae     L52
    mov     r12,rbx
    sub     r12,[rsp+28h]
    jmp     L53
L52:
    mov     r12,[rsp+28h]
    sub     r12,rbx
L53:
    cmp     r12,4
    jb      L106
    mov     r11,[rsp+28h]
    mov     r12d,[r11]
    mov     [rsp+16Ch],r12d
    lea     r11,[image.k512]
    mov     [rsp+58h],r11
    mov     r12,r8
    and     r12,3
    test    r12,r12
    je      L56
    jmp     L107
L54:
    test    rbx,rbx
    je      L106
    jmp     L51
L55:
    mov     ebx,[r8]
    mov     r11,[rsp+28h]
    mov     [r11],ebx
    lea     rbx,[rsp+16Ch]
    lea     r11,[image.k536]
    mov     [rsp+60h],r11
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    je      L60
    jmp     L108
L56:
    test    r8,r8
    je      L107
    mov     r12,[rsp+28h]
    and     r12,3
    test    r12,r12
    je      L55
    jmp     L107
L57:
    mov     r12,r8
    and     r12,3
    test    r12,r12
    jne     L108
    cmp     rbx,r8
    jae     L58
    mov     r12,r8
    sub     r12,rbx
    jmp     L59
L58:
    mov     r12,rbx
    sub     r12,r8
L59:
    cmp     r12,4
    jb      L108
    mov     r12d,[rsp+16Ch]
    mov     [r8],r12d
    lea     r11,[rbp+1]
    mov     [rsp+68h],r11
    mov     r11,[rsp+10h]
    cmp     r11,[rsp+68h]
    jb      L124
    jmp     L61
L60:
    test    rbx,rbx
    je      L108
    jmp     L57
L61:
    mov     r8,[rsp+10h]
    sub     r8,[rsp+68h]
    mov     r10,[rsp+28h]
    mov     [rsp+1E0h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+1E8h],r10
    mov     r10,[rsp+28h]
    mov     [rsp+1D8h],r10
    mov     r11,[rsp+28h]
    mov     r10,[rsp+68h]
    lea     rbx,[r11+r10*4]
    mov     [rsp+1D0h],rbx
    mov     [rsp+1F0h],rbx
    mov     [rsp+28h],rbx
    mov     [rsp+10h],r8
    mov     rcx,[rsp+40h]
    mov     qword ptr [rsp+18h],0
    jmp     L0
L62:
    mov     r11,[rsp+28h]
    lea     rax,[r11+rax*4]
    lea     r8,[rsp+17Ch]
    lea     r11,[image.k488]
    mov     [rsp+0B8h],r11
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    je      L67
    jmp     L110
L63:
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    je      L68
    jmp     L110
L64:
    mov     r11,[rsp+28h]
    cmp     r11,r8
    jae     L65
    mov     rbp,r8
    sub     rbp,[rsp+28h]
    jmp     L66
L65:
    mov     rbp,[rsp+28h]
    sub     rbp,r8
L66:
    cmp     rbp,4
    jb      L110
    mov     r11,[rsp+28h]
    mov     ebp,[r11]
    mov     [rsp+17Ch],ebp
    lea     r11,[image.k512]
    mov     [rsp+88h],r11
    mov     r12,rax
    and     r12,3
    test    r12,r12
    je      L70
    jmp     L111
L67:
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L110
    jmp     L63
L68:
    test    r8,r8
    je      L110
    jmp     L64
L69:
    mov     r8d,[rax]
    mov     r11,[rsp+28h]
    mov     [r11],r8d
    lea     r8,[rsp+17Ch]
    lea     r11,[image.k536]
    mov     [rsp+70h],r11
    mov     r12,r8
    and     r12,3
    test    r12,r12
    je      L74
    jmp     L112
L70:
    test    rax,rax
    je      L111
    mov     r12,[rsp+28h]
    and     r12,3
    test    r12,r12
    je      L69
    jmp     L111
L71:
    mov     r12,rax
    and     r12,3
    test    r12,r12
    jne     L112
    cmp     r8,rax
    jae     L72
    mov     r12,rax
    sub     r12,r8
    jmp     L73
L72:
    mov     r12,r8
    sub     r12,rax
L73:
    cmp     r12,4
    jb      L112
    mov     r12d,[rsp+17Ch]
    mov     [rax],r12d
    lea     r11,[image.k6360]
    mov     [rsp+78h],r11
    mov     r12,[rsp+28h]
    and     r12,3
    test    r12,r12
    je      L75
    jmp     L113
L74:
    test    r8,r8
    je      L112
    jmp     L71
L75:
    mov     rax,[rsp+28h]
    lea     rax,[rax+4]
    mov     r8,[rsp+10h]
    sub     r8,1
    mov     r12,rax
    and     r12,3
    test    r12,r12
    je      L77
    jmp     L114
L76:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r8,r10
    ja      L114
    mov     r12,[image.sym37]
    mov     rdi,rax
    mov     rsi,r8
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     rax,r12
    call    rax
    mov     r12,rax
    cmp     r12,[rsp+10h]
    jb      L78
    jmp     L118
L77:
    test    rax,rax
    je      L114
    jmp     L76
L78:
    mov     r11,[rsp+28h]
    lea     rax,[r11+r12*4]
    lea     r8,[rsp+18Ch]
    lea     r11,[image.k488]
    mov     [rsp+80h],r11
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    jne     L115
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    je      L82
    jmp     L115
L79:
    mov     r11,[rsp+28h]
    cmp     r11,r8
    jae     L80
    mov     rbp,r8
    sub     rbp,[rsp+28h]
    jmp     L81
L80:
    mov     rbp,[rsp+28h]
    sub     rbp,r8
L81:
    cmp     rbp,4
    jb      L115
    mov     r11,[rsp+28h]
    mov     ebp,[r11]
    mov     [rsp+18Ch],ebp
    lea     r11,[image.k512]
    mov     [rsp+90h],r11
    mov     rbp,rax
    and     rbp,3
    test    rbp,rbp
    je      L84
    jmp     L116
L82:
    test    r8,r8
    je      L115
    jmp     L79
L83:
    mov     r8d,[rax]
    mov     r11,[rsp+28h]
    mov     [r11],r8d
    lea     r8,[rsp+18Ch]
    lea     r11,[image.k536]
    mov     [rsp+98h],r11
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    je      L88
    jmp     L117
L84:
    test    rax,rax
    je      L116
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    je      L83
    jmp     L116
L85:
    mov     rbp,rax
    and     rbp,3
    test    rbp,rbp
    jne     L117
    cmp     r8,rax
    jae     L86
    mov     rbp,rax
    sub     rbp,r8
    jmp     L87
L86:
    mov     rbp,r8
    sub     rbp,rax
L87:
    cmp     rbp,4
    jb      L117
    mov     ebp,[rsp+18Ch]
    mov     [rax],ebp
    jmp     L89
L88:
    test    r8,r8
    je      L117
    jmp     L85
L89:
    lea     r11,[image.k6360]
    mov     [rsp+0A0h],r11
    mov     rbp,[rsp+28h]
    and     rbp,3
    test    rbp,rbp
    jne     L119
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L119
    mov     rbp,[rsp+10h]
    sub     rbp,r12
    mov     r8,rax
    and     r8,3
    test    r8,r8
    jne     L120
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rbp,r10
    ja      L120
    mov     r10,[rsp+28h]
    mov     [rsp+1D8h],r10
    mov     [rsp+1E0h],r12
    mov     [rsp+1E8h],rax
    mov     [rsp+1F0h],rbp
    lea     r11,[k11]
    mov     [rsp+0A8h],r11
    cmp     rbp,1
    jb      L123
    lea     r11,[image.k6360]
    mov     [rsp+0B0h],r11
    mov     r8,rax
    and     r8,3
    test    r8,r8
    jne     L121
    mov     rbx,rax
    lea     rbx,[rbx+4]
    sub     rbp,1
    mov     r8,rbx
    and     r8,3
    test    r8,r8
    je      L91
    jmp     L122
L90:
    mov     [rsp+1C8h],rax
    mov     qword ptr [rsp+1D0h],1
    mov     [rsp+1D8h],rbx
    mov     [rsp+1E0h],rbp
    mov     [rsp+1E8h],rax
    mov     qword ptr [rsp+1F0h],1
    mov     [rsp+1E0h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,r12
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+40h]
    mov     r8,[rsp+20h]
    call    fn15
    mov     r8,[rsp+1E0h]
    mov     [rsp+28h],rbx
    mov     [rsp+10h],rbp
    mov     rcx,[rsp+40h]
    mov     [rsp+18h],r8
    jmp     L0
L91:
    test    rbx,rbx
    je      L122
    jmp     L90
L92:
    mov     rbx,[rsp+1C0h]
    mov     r12,[rsp+1B8h]
    mov     r13,[rsp+1B0h]
    mov     r14,[rsp+1A8h]
    mov     r15,[rsp+1A0h]
    mov     rbp,[rsp+198h]
    add     rsp,298h
    ret
L93:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L95
    jmp     L95
    jmp     L95
L94:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L95:
    call    image.sym10
    ud2
L96:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L97:
    lea     rax,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L98:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L99:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L100:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L101:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L103:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L104:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L105:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L106:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L107:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L108:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L109:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L110:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L111:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L112:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L113:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L114:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L115:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L116:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L117:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L118:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L119:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L120:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L121:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L122:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L123:
    lea     rax,[image.k6296]
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,[rsp+0A8h]
    call    image.sym6
    ud2
L124:
    lea     rax,[k16]
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    call    sym17
    ud2
  ; OSR entries
    lea     r11,[L125]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L125:
    .long   L126
L126:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-2C0h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-28h]
    mov     [rsp+10h],r11
    mov     r11d,[rdx-1Ch]
    mov     [rsp+18h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+20h],r11
    mov     [rdx-0D0h],rbx
    mov     [rdx-0D8h],r12
    mov     [rdx-0E0h],r13
    mov     [rdx-0E8h],r14
    mov     [rdx-0F0h],r15
    mov     [rdx-0F8h],rbp
    mov     r11,[rsp]
    mov     [rdx-268h],r11
    mov     r11,[rsp+8]
    mov     [rdx-280h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-278h],r11
    mov     rcx,[rsp+18h]
    lea     rsp,[rsp+30h]
    jmp     L0

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    sub     rsp,18h
    mov     rax,rdx
    mul     rcx
    jb      L2
    cmp     rdi,rsi
    jae     L0
    mov     rcx,rsi
    sub     rcx,rdi
    jmp     L1
L0:
    sub     rdi,rsi
    mov     rcx,rdi
L1:
    cmp     rax,rcx
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
    add     rsp,18h
    ret

fn merge_sort
    sub     rsp,178h
    mov     [rsp+0E8h],rbx
    mov     [rsp+0E0h],r12
    mov     [rsp+0D8h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C8h],r15
    mov     [rsp+0C0h],rbp
    mov     rbx,rdi
    mov     [rsp+60h],rsi
    mov     r13,rdx
    mov     r11,[rsp+60h]
    cmp     r11,10h
    ja      L20
    mov     qword ptr [rsp+0F0h],1
    mov     r10,[rsp+60h]
    mov     [rsp+0F8h],r10
    mov     rax,rbx
    mov     rcx,[rsp+60h]
L0:
    mov     rdx,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    cmp     rdx,rsi
    jae     L1
    lea     rsi,[rdx+1]
    mov     [rsp+0F0h],rsi
    mov     rsi,rdx
    mov     edx,1
    jmp     L2
L1:
    mov     edx,0
L2:
    test    rdx,rdx
    je      L50
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rcx
L3:
    mov     r11,[rsp+28h]
    cmp     r11,0
    ja      L5
    jmp     L4
L4:
    mov     rcx,[rsp+20h]
    jmp     L0
L5:
    mov     r11,[rsp+28h]
    sub     r11,1
    mov     [rsp+30h],r11
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+20h]
    jae     L67
    mov     r10,[rsp+30h]
    lea     rdi,[rax+r10*4]
    mov     edi,[rdi]
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L68
    mov     r10,[rsp+28h]
    lea     r8,[rax+r10*4]
    mov     r9d,[r8]
    cmp     r9d,edi
    jb      L7
    jmp     L6
L6:
    mov     rcx,[rsp+20h]
    jmp     L0
L7:
    mov     rdi,[rsp+28h]
    sub     rdi,1
    lea     r9,[k10]
    cmp     rdi,[rsp+20h]
    jae     L54
    lea     r14,[rax+rdi*4]
    lea     r15,[rsp+0BCh]
    lea     rbp,[image.k488]
    mov     rcx,r14
    and     rcx,3
    test    rcx,rcx
    je      L12
    jmp     L51
L8:
    mov     rcx,r15
    and     rcx,3
    test    rcx,rcx
    je      L13
    jmp     L51
L9:
    cmp     r14,r15
    jae     L10
    mov     rcx,r15
    sub     rcx,r14
    jmp     L11
L10:
    mov     rcx,r14
    sub     rcx,r15
L11:
    cmp     rcx,4
    jb      L51
    mov     ecx,[r14]
    mov     [rsp+0BCh],ecx
    lea     rcx,[image.k512]
    mov     rsi,r8
    and     rsi,3
    test    rsi,rsi
    je      L15
    jmp     L52
L12:
    test    r14,r14
    je      L51
    jmp     L8
L13:
    test    r15,r15
    je      L51
    jmp     L9
L14:
    mov     esi,[r8]
    mov     [r14],esi
    lea     rsi,[rsp+0BCh]
    lea     r11,[image.k536]
    mov     [rsp+68h],r11
    mov     rdx,rsi
    and     rdx,3
    test    rdx,rdx
    je      L19
    jmp     L53
L15:
    test    r8,r8
    je      L52
    mov     rdx,r14
    and     rdx,3
    test    rdx,rdx
    je      L14
    jmp     L52
L16:
    mov     rdx,r8
    and     rdx,3
    test    rdx,rdx
    jne     L53
    cmp     rsi,r8
    jae     L17
    mov     rdx,r8
    sub     rdx,rsi
    jmp     L18
L17:
    mov     rdx,rsi
    sub     rdx,r8
L18:
    cmp     rdx,4
    jb      L53
    mov     edx,[rsp+0BCh]
    mov     [r8],edx
    mov     rdx,[rsp+28h]
    sub     rdx,1
    mov     [rsp+28h],rdx
    jmp     L3
L19:
    test    rsi,rsi
    je      L53
    jmp     L16
L20:
    mov     r11,[rsp+60h]
    shr     r11,1
    mov     [rsp+58h],r11
    lea     rax,[k16]
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+58h]
    jb      L55
    mov     rdi,rbx
    mov     rsi,[rsp+58h]
    mov     rdx,r13
    call    fn18
    mov     rdx,[rsp+60h]
    sub     rdx,[rsp+58h]
    mov     r10,[rsp+58h]
    lea     rsi,[rbx+r10*4]
    mov     rdi,rsi
    mov     rsi,rdx
    mov     rdx,r13
    call    fn18
    mov     rdx,[r13+8]
    mov     rsi,[r13+10h]
    mov     qword ptr [r13+10h],0
    mov     rdi,rdx
    call    image.sym48
    mov     qword ptr [rsp+38h],0
    mov     r11,[rsp+58h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+48h],r11
L21:
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+50h]
    jae     L25
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+48h]
    jae     L25
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+48h]
    jae     L69
    mov     r10,[rsp+38h]
    lea     rdx,[rbx+r10*4]
    mov     r14d,[rdx]
    mov     r10,[rsp+40h]
    lea     rdx,[rbx+r10*4]
    mov     r12d,[rdx]
    cmp     r12d,r14d
    jb      L23
    mov     r15,[r13+10h]
    mov     rdx,[r13]
    cmp     r15,rdx
    jne     L22
    mov     rdi,r13
    call    qword ptr [image.fn160.slot]
L22:
    mov     rdx,[r13+8]
    lea     rdx,[rdx+r15*4]
    mov     [rdx],r14d
    add     r15,1
    mov     [r13+10h],r15
    mov     [rsp+8],rdx
    mov     rdx,[rsp+38h]
    add     rdx,1
    mov     [rsp+38h],rdx
    jmp     L21
L23:
    mov     r14,[r13+10h]
    mov     rdx,[r13]
    cmp     r14,rdx
    jne     L24
    mov     rdi,r13
    call    qword ptr [image.fn160.slot]
L24:
    mov     rdx,[r13+8]
    lea     rdx,[rdx+r14*4]
    mov     [rdx],r12d
    add     r14,1
    mov     [r13+10h],r14
    mov     [rsp+8],rdx
    mov     rdx,[rsp+40h]
    add     rdx,1
    mov     [rsp+40h],rdx
    jmp     L21
L25:
    lea     rdx,[k37]
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+38h]
    jb      L56
    mov     rsi,[rsp+50h]
    sub     rsi,[rsp+38h]
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+50h]
    jb      L56
    mov     r10,[rsp+38h]
    lea     r12,[rbx+r10*4]
    lea     rsi,[r12+rsi*4]
    lea     r11,[image.k6656]
    mov     [rsp+80h],r11
    cmp     rsi,r12
    jb      L57
    sub     rsi,r12
    mov     r14,rsi
    shr     r14,2
    lea     r11,[image.k6704]
    mov     [rsp+70h],r11
    mov     r15,r12
    and     r15,3
    test    r15,r15
    je      L27
    jmp     L58
L26:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r14,r10
    ja      L58
    mov     rdi,r13
    mov     rsi,r14
    call    qword ptr [image.fn171.slot]
    mov     r15,[r13+10h]
    test    r14,r14
    ja      L28
    jmp     L33
L27:
    test    r12,r12
    je      L58
    jmp     L26
L28:
    mov     rsi,[r13+8]
    lea     rsi,[rsi+r15*4]
    lea     r11,[image.k7104]
    mov     [rsp+78h],r11
    mov     r15,r12
    and     r15,3
    test    r15,r15
    je      L32
    jmp     L59
L29:
    mov     r15,r14
    imul    r15,4
    cmp     r12,rsi
    jae     L30
    mov     r8,rsi
    sub     r8,r12
    jmp     L31
L30:
    mov     r8,r12
    sub     r8,rsi
L31:
    cmp     r15,r8
    ja      L59
    mov     r8,r14
    imul    r8,4
    mov     rdi,rsi
    mov     rsi,r12
    mov     rdx,r8
    call    ryo_hr_Memcpy
    jmp     L33
L32:
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    jne     L59
    test    rsi,rsi
    je      L59
    jmp     L29
L33:
    mov     rsi,[r13+10h]
    add     rsi,r14
    mov     [r13+10h],rsi
    lea     r11,[k40]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+40h]
    jb      L60
    mov     r8,[rsp+48h]
    sub     r8,[rsp+40h]
    mov     r10,[rsp+40h]
    lea     r12,[rbx+r10*4]
    lea     r8,[r12+r8*4]
    lea     r11,[image.k6656]
    mov     [rsp+90h],r11
    cmp     r8,r12
    jb      L61
    sub     r8,r12
    mov     r15,r8
    shr     r15,2
    lea     r11,[image.k6704]
    mov     [rsp+88h],r11
    mov     r8,r12
    and     r8,3
    test    r8,r8
    je      L35
    jmp     L62
L34:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r15,r10
    ja      L62
    mov     rdi,r13
    mov     rsi,r15
    call    qword ptr [image.fn171.slot]
    mov     r8,[r13+10h]
    test    r15,r15
    ja      L36
    jmp     L41
L35:
    test    r12,r12
    je      L62
    jmp     L34
L36:
    mov     r14,[r13+8]
    lea     r14,[r14+r8*4]
    lea     r11,[image.k7104]
    mov     [rsp+98h],r11
    mov     r8,r12
    and     r8,3
    test    r8,r8
    je      L40
    jmp     L63
L37:
    mov     r8,r15
    imul    r8,4
    cmp     r12,r14
    jae     L38
    mov     rsi,r14
    sub     rsi,r12
    jmp     L39
L38:
    mov     rsi,r12
    sub     rsi,r14
L39:
    cmp     r8,rsi
    ja      L63
    mov     rsi,r15
    imul    rsi,4
    mov     rdi,r14
    mov     rdx,rsi
    mov     rsi,r12
    call    ryo_hr_Memcpy
    jmp     L41
L40:
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    jne     L63
    test    r14,r14
    je      L63
    jmp     L37
L41:
    mov     rsi,[r13+10h]
    add     rsi,r15
    mov     [r13+10h],rsi
    mov     r8,[r13+8]
    lea     r11,[k44]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+48h]
    cmp     r11,rsi
    jne     L66
    lea     r13,[image.k560]
    mov     r11,[rsp+48h]
    cmp     r11,0
    jne     L42
    mov     r14d,1
    jmp     L43
L42:
    mov     r14d,0
L43:
    mov     r15,r8
    and     r15,3
    test    r15,r15
    je      L48
    jmp     L65
L44:
    mov     r15,rbx
    and     r15,3
    test    r15,r15
    je      L49
    jmp     L65
L45:
    mov     eax,4
    mul     qword ptr [rsp+48h]
    mov     r15,rax
    jb      L64
    cmp     r8,rbx
    jae     L46
    mov     r12,rbx
    sub     r12,r8
    jmp     L47
L46:
    mov     r12,r8
    sub     r12,rbx
L47:
    cmp     r15,r12
    ja      L65
    mov     r12,[rsp+48h]
    imul    r12,4
    mov     rdi,rbx
    mov     rsi,r8
    mov     rdx,r12
    call    ryo_hr_Memcpy
    jmp     L50
L48:
    test    r14b,r14b
    jne     L44
    test    r8,r8
    je      L65
    jmp     L44
L49:
    test    r14b,r14b
    jne     L45
    test    rbx,rbx
    je      L65
    jmp     L45
L50:
    mov     rbx,[rsp+0E8h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D8h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C8h]
    mov     rbp,[rsp+0C0h]
    add     rsp,178h
    ret
L51:
    lea     r8,[image.k8338]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    lea     r8,[image.k8904]
    mov     rdi,r8
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L53:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L54:
    mov     rsi,[rsp+20h]
    mov     rdx,r9
    call    sym5
    ud2
L55:
    mov     edi,0
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rcx,rax
    call    image.sym31
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    call    ryo_h_Resume
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    call    ryo_h_Resume
    ud2
L56:
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+50h]
    mov     rcx,rdx
    mov     rdx,[rsp+48h]
    call    image.sym31
    ud2
L57:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L59:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp+0A0h]
    call    image.sym31
    ud2
L61:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L64:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L65:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L66:
    mov     rdi,[rsp+48h]
    mov     rdx,[rsp+0A8h]
    call    image.sym24
    ud2
L67:
    lea     rax,[k4]
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L68:
    lea     rax,[k6]
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L69:
    lea     rax,[k23]
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+48h]
    mov     rdx,rax
    call    sym5
    ud2
  ; OSR entries
    lea     r11,[L70]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L70:
    .long   L71
    .long   L72
    .long   L73
L71:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-380h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-98h],r13
    mov     [rdx-0A0h],r14
    mov     [rdx-0A8h],r15
    mov     [rdx-0B0h],rbp
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+210h]
    jmp     L0
L72:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-390h]
    mov     r11,[rdx-0B0h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-98h],r13
    mov     [rdx-0A0h],r14
    mov     [rdx-0A8h],r15
    mov     [rdx-0B0h],rbp
    mov     r11,[rsp]
    mov     [rdx-148h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-150h],r11
    mov     rax,[rsp+8]
    lea     rsp,[rsp+220h]
    jmp     L3
L73:
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
    mov     [rdx-88h],rbx
    mov     [rdx-90h],r12
    mov     [rdx-98h],r13
    mov     [rdx-0A0h],r14
    mov     [rdx-0A8h],r15
    mov     [rdx-0B0h],rbp
    mov     r11,[rsp]
    mov     [rdx-138h],r11
    mov     r11,[rsp+8]
    mov     [rdx-120h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-128h],r11
    mov     rbx,[rsp+18h]
    mov     r13,[rsp+28h]
    lea     rsp,[rsp+230h]
    jmp     L21

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
    push    rbx
    push    r12
    push    r13
    sub     rsp,60h
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
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     [rsp+8],bl
    mov     [rsp],r13
    mov     [rsp+10h],r12
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+16]
    call    qword ptr [sym0]
    mov     r12,[rsp+48h]
    mov     rax,[rsp+28h]
    mov     [rsp+58h],rax
    mov     rdi,rax
    call    sym2
    mov     [rsp+58h],r12
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+28]
    call    qword ptr [sym5]
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+40]
    call    qword ptr [sym3]
    mov     rax,[rsp+58h]
    add     rsp,60h
    pop     r13
    pop     r12
    pop     rbx
    ret
    mov     rbx,rax
    jmp     L1
L0:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L1:
    mov     rdi,r12
    call    sym2
    jmp     L0
    call    sym6
    ud2
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
    .long   L4
    .long   L5
    .long   L6
L3:
    ret
L4:
    ret
L5:
    ret
L6:
    ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     eax,[rsi]
    mov     rcx,rax
    mov     rdx,rcx
    imul    rdx,10624DD3h
    shr     rdx,26h
    imul    edx,3E8h
    sub     eax,edx
    shl     rcx,20h
    or      rax,rcx
    mov     rcx,rax
    shr     rcx,20h
    mov     eax,eax
    mov     ecx,ecx
    shl     rcx,20h
    or      rax,rcx
    mov     rcx,rax
    shr     rcx,20h
    mov     rdx,[rdi+10h]
    mov     rsi,[rdi+8]
    lea     rdx,[rdx+rsi*8]
    mov     eax,eax
    mov     ecx,ecx
    shl     rcx,20h
    or      rax,rcx
    mov     [rdx],rax
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

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi+18h]
    mov     rcx,[rax]
    mov     rdx,rcx
    shl     rdx,0Dh
    xor     rcx,rdx
    mov     [rax],rcx
    mov     rdx,rcx
    shr     rdx,7
    xor     rcx,rdx
    mov     [rax],rcx
    mov     rdx,rcx
    shl     rdx,11h
    xor     rcx,rdx
    mov     [rax],rcx
    mov     rax,[rdi+10h]
    mov     rdx,[rdi+8]
    lea     rax,[rax+rdx*4]
    mov     [rax],ecx
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
    jae     L0
    lea     rcx,[rax+1]
    mov     [rdi],rcx
    mov     rcx,rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
    mov     rdx,rcx
    add     rsp,18h
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    push    rbx
    push    r12
    sub     rsp,8
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L0
    sub     r12,1
    and     rbx,r12
    test    rbx,rbx
    sete    al
    movzx   eax,al
    add     rsp,8
    pop     r12
    pop     rbx
    ret
L0:
    lea     rax,[k0]
    lea     rcx,[k2]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    sym3
    ud2
  ; OSR entries
    lea     r11,[L1]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L1:
    .long   L2
    .long   L3
L2:
    ret
L3:
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
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,10h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L5
    lea     rax,[r13-1]
    and     rax,rbx
    test    rax,rax
    je      L1
    jmp     L9
L0:
    add     rsp,10h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L1:
    test    r14b,r14b
    je      L2
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L6
    lea     rax,[r13-1]
    and     rax,r12
    test    rax,rax
    je      L3
    jmp     L10
L2:
    test    rbx,rbx
    je      L8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L7
    sub     r13,1
    mov     rax,r12
    and     rax,r13
    test    rax,rax
    je      L4
    jmp     L10
L3:
    jmp     L0
L4:
    test    r12,r12
    je      L8
    jmp     L0
L5:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L6:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L7:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L11
L8:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L9:
    jmp     L8
    jmp     L11
L10:
    jmp     L8
L11:
    call    sym6
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
L13:
    ret
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

fn std::ptr::copy_nonoverlapping::precondition_check
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,18h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     [rsp+10h],r9
    test    r15,r15
    jne     L0
    mov     ebp,1
    jmp     L1
L0:
    test    r13,r13
    sete    al
    mov     rbp,rax
L1:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L8
    lea     rax,[r14-1]
    and     rax,rbx
    test    rax,rax
    je      L6
    jmp     L12
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    lea     rax,[r14-1]
    and     rax,r12
    test    rax,rax
    je      L7
    jmp     L13
L3:
    mov     rax,r13
    mul     r15
    jb      L10
    cmp     rbx,r12
    jae     L4
    mov     rcx,r12
    sub     rcx,rbx
    jmp     L5
L4:
    mov     rcx,rbx
    sub     rcx,r12
L5:
    cmp     rax,rcx
    ja      L11
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L6:
    test    bpl,bpl
    jne     L2
    test    rbx,rbx
    je      L11
    jmp     L2
L7:
    test    bpl,bpl
    jne     L3
    test    r12,r12
    je      L11
    jmp     L3
L8:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L9:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L10:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L14
    jmp     L14
L11:
    lea     rax,[k3]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    sym5
    ud2
L12:
    jmp     L11
L13:
    jmp     L11
L14:
    call    sym6
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
    .long   L20
    .long   L21
    .long   L22
    .long   L23
    .long   L24
    .long   L25
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
L25:
    ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    sub     rsp,18h
    mov     r11,[rdi]
    mov     eax,[rsi]
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
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    sub     rsp,10h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L5
    sub     r13,1
    mov     rax,rbx
    and     rax,r13
    test    rax,rax
    je      L2
    jmp     L7
L0:
    test    r12,r12
    je      L3
    mov     rax,7FFFFFFFFFFFFFFFh
    xor     edx,edx
    div     r12
    jmp     L4
L1:
    add     rsp,10h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L2:
    test    rbx,rbx
    je      L6
    jmp     L0
L3:
    mov     rax,0FFFFFFFFFFFFFFFFh
L4:
    cmp     r14,rax
    jbe     L1
    jmp     L6
L5:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L8
L6:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L7:
    jmp     L6
L8:
    call    sym4
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
    .long   L14
    .long   L15
    .long   L16
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
L16:
    ret

fn std::vec::Vec::<u32>::push
    push    rbx
    push    r12
    push    r13
    sub     rsp,20h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    mov     rax,[rbx]
    cmp     r13,rax
    jne     L0
    mov     rdi,rbx
    call    qword ptr [image.fn160.slot]
L0:
    mov     rax,[rbx+8]
    lea     rax,[rax+r13*4]
    mov     [rax],r12d
    add     r13,1
    mov     [rbx+10h],r13
    mov     [rsp+8],rax
    add     rsp,20h
    pop     r13
    pop     r12
    pop     rbx
    ret
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2

fn std::vec::Vec::<u32>::reserve
    push    rbx
    push    r12
    push    r13
    sub     rsp,20h
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+18h]
    test    rax,rax
    je      L3
    mov     rax,[rbx]
    jmp     L2
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
    add     rsp,20h
    pop     r13
    pop     r12
    pop     rbx
    ret
L2:
    sub     rax,r13
    cmp     rax,r12
    jb      L0
    jmp     L1
L3:
    mov     rax,0FFFFFFFFFFFFFFFFh
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

