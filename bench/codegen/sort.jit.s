fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
    mov     eax,20h
    ret

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
    mov     eax,1
    movzx   eax,al
    ret

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    mov     eax,[rsi]
    mov     ecx,[rdx]
    cmp     eax,ecx
    setb    al
    movzx   eax,al
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
    lea     rdi,[k1]
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
    mov     rsi,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
L2:
    test    rax,rax
    je      L3
    lea     rdi,[rsp+20h]
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
    lea     rdi,[rsp+20h]
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
    lea     rcx,[k4]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    shr     rsi,2
    jmp     L4
L1:
    lea     rax,[rsp+28h]
    lea     rdx,[rbx+r12*4]
    mov     rdi,rax
    mov     rsi,rdx
    call    fn1
    lea     rax,[k9]
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
    lea     rdi,[image.k7567]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L7:
    lea     rdi,[image.k7768]
    mov     esi,175h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    jmp     L10
L8:
    lea     rdi,[rsp+28h]
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
    lea     rcx,[k1]
    cmp     rsi,rdi
    jb      L6
    sub     rsi,rdi
    shr     rsi,2
    jmp     L4
L1:
    lea     r8,[rsp+38h]
    lea     r9,[rbx+r12*4]
    mov     rdi,r8
    mov     rsi,rax
    mov     rdx,r9
    call    fn0
    lea     r8,[k6]
    mov     r11,r12
    add     r11,1
    jb      L7
    add     r12,1
    cmp     r12,r13
    jne     L5
    mov     r9,rax
    jmp     L3
L2:
    mov     rax,r9
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
    mov     rax,rdx
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
    jmp     L1
L5:
    mov     r9,rax
    mov     r14,rbx
    mov     r15,r12
    mov     rbp,r13
    jmp     L2
L6:
    lea     rdi,[image.k7567]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L7:
    lea     rdi,[image.k7768]
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
    mov     rax,[rsp]
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
    mov     eax,20h
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    sub     rsp,18h
    cmp     rdi,rsi
    jae     L0
    add     rsp,18h
    ret
L0:
    lea     rdi,[k0]
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
    lea     rdi,[k0]
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
    lea     rdi,[k0]
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
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L5:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rdi,[k2]
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
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    lea     rdi,[image.k8338]
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
    lea     rdi,[image.k7128]
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    lea     rdi,[image.k8904]
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    lea     rdi,[image.k8338]
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
    mov     rbx,rdi
    mov     [rsp+18h],rsi
    mov     [rsp+10h],rdx
    mov     r11,[rsp+18h]
    cmp     r11,8
    jb      L13
    mov     rax,[rsp+18h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    lea     r14,[rbx+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    lea     r15,[rbx+rcx*8]
    mov     r11,[rsp+18h]
    cmp     r11,40h
    jae     L3
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     ecx,[rbx]
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
    mov     rcx,rbx
L2:
    lea     rdx,[k2]
    cmp     rcx,rbx
    jb      L10
    sub     rcx,rbx
    shr     rcx,3
    jmp     L8
L3:
    mov     rbp,rax
    shr     rbp,3
    mov     r13,rbp
    imul    r13,4
    lea     rsi,[rbx+r13*8]
    mov     r12,rbp
    imul    r12,7
    lea     rax,[rbx+r12*8]
    mov     rdi,rbx
    mov     rdx,rax
    mov     rcx,rbp
    mov     r8,[rsp+10h]
    call    fn1
    mov     [rsp+20h],rax
    lea     rsi,[r14+r13*8]
    lea     rax,[r14+r12*8]
    mov     rdi,r14
    mov     rdx,rax
    mov     rcx,rbp
    mov     r8,[rsp+10h]
    call    fn1
    mov     r14,rax
    lea     rsi,[r15+r13*8]
    lea     rax,[r15+r12*8]
    mov     rdi,r15
    mov     rdx,rax
    mov     rcx,rbp
    mov     r8,[rsp+10h]
    call    fn1
    mov     r11,[rsp+10h]
    mov     r11,[r11]
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
    cmp     rax,rbx
    jb      L11
    sub     rax,rbx
    shr     rax,3
    jmp     L9
L7:
    cmp     rdi,[rsp+18h]
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
    lea     rdi,[image.k7567]
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L11:
    lea     rdi,[image.k7567]
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L12:
    lea     rdi,[image.k9125]
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
    mov     r13,r8
    mov     rax,rcx
    imul    rax,8
    cmp     rax,40h
    jb      L0
    mov     r14,rcx
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    lea     rsi,[rdi+r15*8]
    mov     rbp,r14
    imul    rbp,7
    lea     rdx,[rdi+rbp*8]
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     [rsp+10h],rax
    lea     rsi,[rbx+r15*8]
    lea     rdx,[rbx+rbp*8]
    mov     rdi,rbx
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     rbx,rax
    lea     rsi,[r12+r15*8]
    lea     rdx,[r12+rbp*8]
    mov     rdi,r12
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     rdi,[rsp+10h]
    mov     r12,rax
L0:
    mov     r11,[r13]
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
    lea     rsi,[rdi+r15*4]
    mov     rbp,r14
    imul    rbp,7
    lea     rdx,[rdi+rbp*4]
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     [rsp+10h],rax
    lea     rsi,[rbx+r15*4]
    lea     rdx,[rbx+rbp*4]
    mov     rdi,rbx
    mov     rcx,r14
    mov     r8,r13
    call    fn0
    mov     rbx,rax
    lea     rsi,[r12+r15*4]
    lea     rdx,[r12+rbp*4]
    mov     rdi,r12
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
    sub     rsp,158h
    mov     [rsp+98h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+88h],r13
    mov     [rsp+80h],r14
    mov     [rsp+78h],r15
    mov     [rsp+70h],rbp
    mov     [rsp+0B0h],rdi
    mov     rax,rsi
    shr     rax,1
    test    rax,rax
    setne   cl
    mov     [rsp+0B7h],cl
    lea     rcx,[rdi+rax*4]
    lea     r8,[rax-1]
    mov     [rsp+0B0h],r8
    lea     r8,[rdi+r8*4]
    lea     r9,[rsi-1]
    lea     rbx,[rdi+r9*4]
    mov     [rsp+0B0h],rdx
    lea     r9,[rdx+r9*4]
    mov     [rsp+28h],r8
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rcx
    mov     rcx,rax
    mov     eax,0
    mov     [rsp+20h],rbx
    mov     [rsp+18h],rsi
    mov     rsi,rdx
L0:
    mov     [rsp+0A8h],rax
    mov     [rsp+0A0h],rcx
    cmp     rax,rcx
    setb    r13b
    mov     [rsp+0B7h],r13b
    test    r13b,r13b
    je      L29
    mov     [rsp+0A8h],rax
    add     rax,1
    mov     [rsp+0A0h],rax
    mov     r11,[rsp+38h]
    mov     r13d,[r11]
    mov     r11,[rsp+40h]
    mov     r14d,[r11]
    cmp     r13d,r14d
    setb    r13b
    mov     r14,r13
    xor     r14d,1
    cmp     r13b,1
    je      L1
    mov     r15,[rsp+40h]
    jmp     L2
L1:
    mov     r15,[rsp+38h]
L2:
    lea     r11,[image.k2712]
    mov     [rsp+10h],r11
    mov     rbp,r15
    and     rbp,3
    test    rbp,rbp
    je      L7
    jmp     L30
L3:
    mov     rbp,rsi
    and     rbp,3
    test    rbp,rbp
    je      L8
    jmp     L30
L4:
    cmp     r15,rsi
    jae     L5
    mov     rbp,rsi
    sub     rbp,r15
    jmp     L6
L5:
    mov     rbp,r15
    sub     rbp,rsi
L6:
    cmp     rbp,4
    jb      L30
    mov     ebp,[r15]
    mov     [rsi],ebp
    movzx   ebp,r13b
    mov     r11,[rsp+38h]
    lea     rbp,[r11+rbp*4]
    movzx   r12d,r14b
    mov     r11,[rsp+40h]
    lea     r12,[r11+r12*4]
    mov     rbx,rsi
    lea     rbx,[rbx+4]
    mov     [rsp+0A0h],r12
    mov     [rsp+0A8h],rbp
    mov     [rsp+0B0h],rbx
    mov     [rsp+58h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+20h]
    mov     r11,[rsp+18h]
    mov     [rsp+68h],r11
    jmp     L9
L7:
    test    r15,r15
    je      L30
    jmp     L3
L8:
    test    rsi,rsi
    je      L30
    jmp     L4
L9:
    mov     r14,[rsp+0A0h]
    mov     r15,[rsp+0A8h]
    mov     rbp,[rsp+0B0h]
    mov     r11d,[rcx]
    mov     [rsp+30h],r11
    mov     r8d,[rax]
    mov     r11,[rsp+30h]
    cmp     r11d,r8d
    setb    r8b
    mov     rdx,r8
    xor     edx,1
    cmp     r8b,1
    je      L10
    mov     rdi,rcx
    jmp     L11
L10:
    mov     rdi,rax
L11:
    lea     r11,[image.k1680]
    mov     [rsp+48h],r11
    mov     r11,rdi
    and     r11,3
    mov     [rsp+50h],r11
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L16
    jmp     L31
L12:
    mov     rbx,r9
    and     rbx,3
    test    rbx,rbx
    je      L17
    jmp     L31
L13:
    cmp     rdi,r9
    jae     L14
    mov     rbx,r9
    sub     rbx,rdi
    jmp     L15
L14:
    mov     rbx,rdi
    sub     rbx,r9
L15:
    cmp     rbx,4
    jb      L31
    mov     ebx,[rdi]
    mov     [r9],ebx
    movzx   ebx,dl
    mov     r11d,0
    sub     r11,rbx
    mov     rbx,r11
    lea     rbx,[rcx+rbx*4]
    movzx   r12d,r8b
    mov     r11d,0
    sub     r11,r12
    mov     r12,r11
    lea     r12,[rax+r12*4]
    mov     r13,r9
    lea     r13,[r13-4]
    mov     [rsp+0A0h],r12
    mov     [rsp+0A8h],rbx
    mov     [rsp+0B0h],r13
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+28h],r12
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     rsi,rbp
    mov     [rsp+20h],rbx
    mov     r9,r13
    mov     r11,[rsp+68h]
    mov     [rsp+18h],r11
    jmp     L0
L16:
    test    rdi,rdi
    je      L31
    jmp     L12
L17:
    test    r9,r9
    je      L31
    jmp     L13
L18:
    mov     r8,[rsp+40h]
    mov     rdi,[rsp+38h]
    jmp     L28
L19:
    mov     r11,[rsp+40h]
    cmp     r11,rax
    setb    cl
    mov     [rsp+0A6h],cl
    test    cl,cl
    je      L20
    mov     rcx,[rsp+40h]
    jmp     L21
L20:
    mov     rcx,[rsp+38h]
L21:
    lea     rdx,[k5]
    mov     rdi,rcx
    and     rdi,3
    test    rdi,rdi
    je      L26
    jmp     L32
L22:
    mov     rdi,rsi
    and     rdi,3
    test    rdi,rdi
    je      L27
    jmp     L32
L23:
    cmp     rcx,rsi
    jae     L24
    mov     rdi,rsi
    sub     rdi,rcx
    jmp     L25
L24:
    mov     rdi,rcx
    sub     rdi,rsi
L25:
    cmp     rdi,4
    jb      L32
    mov     edi,[rcx]
    mov     [rsi],edi
    movzx   edi,byte ptr [rsp+0A6h]
    mov     r8,rdi
    mov     r11,[rsp+40h]
    lea     r8,[r11+r8*4]
    xor     edi,1
    mov     [rsp+0A5h],dil
    movzx   edi,dil
    mov     r11,[rsp+38h]
    lea     rdi,[r11+rdi*4]
    jmp     L28
L26:
    test    rcx,rcx
    je      L32
    jmp     L22
L27:
    test    rsi,rsi
    je      L32
    jmp     L23
L28:
    mov     rcx,[rsp+0B0h]
    cmp     r8,rcx
    jne     L33
    mov     rcx,[rsp+0A8h]
    cmp     rdi,rcx
    jne     L33
    mov     rbx,[rsp+98h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+88h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+78h]
    mov     rbp,[rsp+70h]
    add     rsp,158h
    ret
L29:
    mov     rax,[rsp+28h]
    lea     rax,[rax+4]
    mov     [rsp+0B0h],rax
    mov     rcx,[rsp+20h]
    lea     rcx,[rcx+4]
    mov     [rsp+0A8h],rcx
    mov     rcx,[rsp+18h]
    and     rcx,1
    test    rcx,rcx
    sete    cl
    mov     [rsp+0A7h],cl
    test    cl,cl
    jne     L18
    jmp     L19
L30:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L31:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L32:
    lea     rdi,[image.k8338]
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
    lea     rsp,[rdx-1A0h]
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
    mov     [rdx-128h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-110h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-118h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-138h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+28h]
    mov     r9,[rsp+38h]
    lea     rsp,[rsp+50h]
    jmp     L0
L36:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-180h]
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
    mov     r11,[rsp+18h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0E8h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r9,[rsp+10h]
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
    lea     r14,[image.k10496]
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
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    lea     rdi,[image.k8338]
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

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    sub     rsp,10h
    test    rdx,rdx
    je      L19
    cmp     rsi,rdx
    jb      L19
    lea     rax,[rdi+rsi*4]
    lea     rcx,[rdi+rdx*4]
L0:
    cmp     rcx,rax
    je      L16
    mov     rdx,rcx
    lea     rdx,[rdx-4]
    mov     esi,[rcx]
    mov     r8d,[rcx-4]
    cmp     esi,r8d
    setb    sil
    mov     [rsp+0Fh],sil
    test    sil,sil
    je      L14
    mov     esi,[rcx]
    mov     [rsp+0Ch],esi
    lea     rsi,[rsp+0Ch]
    mov     r8,rcx
L1:
    lea     r9,[image.k1728]
    mov     rbx,rdx
    and     rbx,3
    test    rbx,rbx
    je      L6
    jmp     L17
L2:
    mov     rbx,r8
    and     rbx,3
    test    rbx,rbx
    je      L7
    jmp     L17
L3:
    cmp     rdx,r8
    jae     L4
    mov     rbx,r8
    sub     rbx,rdx
    jmp     L5
L4:
    mov     rbx,rdx
    sub     rbx,r8
L5:
    cmp     rbx,4
    jb      L17
    mov     ebx,[rdx]
    mov     [r8],ebx
    cmp     rdx,rdi
    je      L9
    jmp     L15
L6:
    test    rdx,rdx
    je      L17
    jmp     L2
L7:
    test    r8,r8
    je      L17
    jmp     L3
L8:
    mov     r10,rdx
    mov     rdx,r8
    mov     r8,r10
    jmp     L1
L9:
    lea     rbx,[image.k10496]
    mov     r12,rsi
    and     r12,3
    test    r12,r12
    je      L13
    jmp     L18
L10:
    mov     r12,rdx
    and     r12,3
    test    r12,r12
    jne     L18
    cmp     rsi,rdx
    jae     L11
    mov     r12,rdx
    sub     r12,rsi
    jmp     L12
L11:
    mov     r12,rsi
    sub     r12,rdx
L12:
    mov     r11d,4
    cmp     r11,r12
    ja      L18
    mov     r12d,[rsp+0Ch]
    mov     [rdx],r12d
    jmp     L14
L13:
    test    rsi,rsi
    je      L18
    jmp     L10
L14:
    mov     r12,rcx
    lea     r12,[r12+4]
    mov     rcx,r12
    jmp     L0
L15:
    mov     r8,rdx
    lea     r8,[r8-4]
    mov     r12d,[rsp+0Ch]
    mov     r13d,[rdx-4]
    cmp     r12d,r13d
    jb      L8
    jmp     L9
L16:
    add     rsp,10h
    pop     r13
    pop     r12
    pop     rbx
    ret
L17:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L18:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L19:
    lea     rdi,[rsp+20h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L20]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L20:
    .long   L21
L21:
    pop     rcx
    lea     rdx,[rsp+60h]
    lea     rsp,[rdx-80h]
    mov     r11,[rdx-28h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     [rdx],rbx
    mov     [rdx-8],r12
    mov     [rdx-10h],r13
    mov     rcx,[rsp]
    mov     rax,[rsp+8]
    mov     rdi,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L0

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
    lea     rdi,[image.k8338]
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
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,4D8h
    mov     [rsp+3B8h],rbx
    mov     [rsp+3B0h],r12
    mov     [rsp+3A8h],r13
    mov     [rsp+3A0h],r14
    mov     [rsp+398h],r15
    mov     [rsp+390h],rbp
    mov     rbx,rdi
    mov     [rsp+38h],rsi
    mov     r13,rdx
    mov     [rsp+30h],r8
    mov     r11,[rsp+38h]
    cmp     r11,2
    jb      L56
    mov     rax,[rsp+38h]
    add     rax,10h
    cmp     rcx,rax
    jb      L71
    mov     r11,[rsp+38h]
    shr     r11,1
    mov     [rsp+88h],r11
    mov     r11,[rsp+38h]
    cmp     r11,10h
    jb      L0
    mov     r10,[rsp+38h]
    lea     rdx,[r13+r10*8]
    mov     [rsp+380h],rdx
    mov     rdi,rbx
    mov     rsi,r13
    mov     rcx,[rsp+30h]
    call    qword ptr [fn0.slot]
    mov     r10,[rsp+88h]
    lea     rdi,[rbx+r10*8]
    mov     [rsp+380h],rdi
    mov     r10,[rsp+88h]
    lea     rsi,[r13+r10*8]
    mov     [rsp+378h],rsi
    mov     rax,[rsp+38h]
    add     rax,8
    mov     [rsp+3D8h],rax
    lea     rdx,[r13+rax*8]
    mov     rcx,[rsp+30h]
    call    qword ptr [fn0.slot]
    mov     edx,8
    jmp     L38
L0:
    mov     r11,[rsp+38h]
    cmp     r11,8
    jb      L25
    mov     [rsp+380h],rbx
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,[rsp+30h]
    call    qword ptr [fn2.slot]
    mov     r10,[rsp+88h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+378h],rax
    mov     [rsp+380h],rax
    mov     r10,[rsp+88h]
    lea     rbp,[r13+r10*8]
    mov     [rsp+378h],rbp
    mov     r11,[rsp+30h]
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
    lea     r11,[rax+rsi*8]
    mov     [rsp+40h],r11
    xor     ecx,1
    movzx   ecx,cl
    lea     r11,[rax+rcx*8]
    mov     [rsp+60h],r11
    movzx   ecx,dl
    add     rcx,2
    lea     r11,[rax+rcx*8]
    mov     [rsp+50h],r11
    xor     edx,1
    movzx   edx,dl
    add     rdx,2
    lea     r11,[rax+rdx*8]
    mov     [rsp+48h],r11
    mov     r11,[rsp+50h]
    mov     eax,[r11]
    mov     r11,[rsp+40h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    [rsp+68h]
    mov     r11,[rsp+48h]
    mov     eax,[r11]
    mov     r11,[rsp+60h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    [rsp+58h]
    mov     r10,[rsp+50h]
    mov     [rsp+190h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+188h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+190h],r10
    lea     rax,[rsp+188h]
    lea     rcx,[rsp+190h]
    mov     [rsp+198h],rcx
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+190h]
    mov     [rsp],rax
    lea     rax,[rsp+188h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+198h]
    mov     [rsp+1A0h],rax
    mov     rdi,[rsp+178h]
    mov     [rsp+1A8h],rdi
    call    image.sym17
    mov     rax,[rsp+1A0h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+188h]
    mov     rcx,[rsp+190h]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym18]
    mov     r12,[rsp+1A8h]
    mov     r10,[rsp+60h]
    mov     [rsp+1D0h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+1C8h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+1D0h],r10
    lea     rax,[rsp+1C8h]
    lea     rcx,[rsp+1D0h]
    mov     [rsp+1D8h],rcx
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+1D0h]
    mov     [rsp],rax
    lea     rax,[rsp+1C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+1D8h]
    mov     [rsp+1E0h],rax
    mov     rdi,[rsp+1B8h]
    mov     [rsp+1E8h],rdi
    call    image.sym17
    mov     rax,[rsp+1E0h]
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+1C8h]
    mov     rcx,[rsp+1D0h]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym18]
    mov     r14,[rsp+1E8h]
    mov     r10,[rsp+50h]
    mov     [rsp+210h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+208h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+210h],r10
    lea     rax,[rsp+208h]
    lea     rcx,[rsp+210h]
    mov     [rsp+218h],rcx
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+210h]
    mov     [rsp],rax
    lea     rax,[rsp+208h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+218h]
    mov     [rsp+220h],rax
    mov     rdi,[rsp+1F8h]
    mov     [rsp+228h],rdi
    call    image.sym17
    mov     rax,[rsp+220h]
    mov     [rsp+228h],rax
    mov     rax,[rsp+208h]
    mov     rcx,[rsp+210h]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+228h]
    mov     r10,[rsp+40h]
    mov     [rsp+250h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+248h],r10
    mov     [rsp+250h],rax
    lea     rax,[rsp+248h]
    lea     rcx,[rsp+250h]
    mov     [rsp+258h],rcx
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+250h]
    mov     [rsp],rax
    lea     rax,[rsp+248h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+258h]
    mov     [rsp+260h],rax
    mov     rdi,[rsp+238h]
    mov     [rsp+268h],rdi
    call    image.sym17
    mov     rax,[rsp+260h]
    mov     [rsp+268h],rax
    mov     rax,[rsp+248h]
    mov     rcx,[rsp+250h]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym18]
    mov     r11,[rsp+268h]
    mov     [rsp+70h],r11
    mov     r10,[rsp+60h]
    mov     [rsp+290h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+288h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+290h],r10
    lea     rax,[rsp+288h]
    lea     rcx,[rsp+290h]
    mov     [rsp+298h],rcx
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+290h]
    mov     [rsp],rax
    lea     rax,[rsp+288h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+298h]
    mov     [rsp+2A0h],rax
    mov     rdi,[rsp+278h]
    mov     [rsp+2A8h],rdi
    call    image.sym17
    mov     rax,[rsp+2A0h]
    mov     [rsp+2A8h],rax
    mov     rax,[rsp+288h]
    mov     rcx,[rsp+290h]
    mov     r10,[rsp+68h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+2A8h]
    mov     r10,[rsp+48h]
    mov     [rsp+2D0h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+2C8h],r10
    mov     [rsp+2D0h],rax
    lea     rax,[rsp+2C8h]
    lea     rcx,[rsp+2D0h]
    mov     [rsp+2D8h],rcx
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+2D0h]
    mov     [rsp],rax
    lea     rax,[rsp+2C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+2D8h]
    mov     [rsp+2E0h],rax
    mov     rdi,[rsp+2B8h]
    mov     [rsp+2E8h],rdi
    call    image.sym17
    mov     rax,[rsp+2E0h]
    mov     [rsp+2E8h],rax
    mov     rax,[rsp+2C8h]
    mov     rcx,[rsp+2D0h]
    mov     r10,[rsp+58h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym18]
    mov     r11,[rsp+2E8h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     r11,[rsp+78h]
    mov     eax,[r11]
    mov     r11,[rsp+70h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    [rsp+80h]
    mov     r10,[rsp+78h]
    mov     [rsp+310h],r10
    mov     r10,[rsp+78h]
    mov     [rsp+308h],r10
    mov     r10,[rsp+70h]
    mov     [rsp+310h],r10
    lea     rax,[rsp+308h]
    lea     rcx,[rsp+310h]
    mov     [rsp+318h],rcx
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+310h]
    mov     [rsp],rax
    lea     rax,[rsp+308h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+318h]
    mov     [rsp+320h],rax
    mov     rdi,[rsp+2F8h]
    mov     [rsp+328h],rdi
    call    image.sym17
    mov     rax,[rsp+320h]
    mov     [rsp+328h],rax
    mov     rax,[rsp+308h]
    mov     rcx,[rsp+310h]
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym18]
    mov     r15,[rsp+328h]
    mov     r10,[rsp+70h]
    mov     [rsp+350h],r10
    mov     r10,[rsp+70h]
    mov     [rsp+348h],r10
    mov     r10,[rsp+78h]
    mov     [rsp+350h],r10
    lea     rax,[rsp+348h]
    lea     rcx,[rsp+350h]
    mov     [rsp+358h],rcx
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym16]
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    lea     rax,[rsp+350h]
    mov     [rsp],rax
    lea     rax,[rsp+348h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+358h]
    mov     [rsp+360h],rax
    mov     rdi,[rsp+338h]
    mov     [rsp+368h],rdi
    call    image.sym17
    mov     rax,[rsp+360h]
    mov     [rsp+368h],rax
    mov     rax,[rsp+348h]
    mov     rcx,[rsp+350h]
    mov     r10,[rsp+80h]
    mov     [rsp+8],r10b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym19]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym18]
    mov     rax,[rsp+368h]
    lea     r11,[image.k1752]
    mov     [rsp+0A8h],r11
    mov     rdx,r12
    and     rdx,3
    test    rdx,rdx
    je      L5
    jmp     L61
L1:
    mov     rdx,rbp
    and     rdx,3
    test    rdx,rdx
    je      L6
    jmp     L61
L2:
    cmp     r12,rbp
    jae     L3
    mov     rdx,rbp
    sub     rdx,r12
    jmp     L4
L3:
    mov     rdx,r12
    sub     rdx,rbp
L4:
    cmp     rdx,8
    jb      L61
    mov     edx,[r12]
    mov     esi,[r12+4]
    mov     [rbp],edx
    mov     [rbp+4],esi
    mov     rdx,rbp
    lea     rdx,[rdx+8]
    lea     r11,[image.k1776]
    mov     [rsp+0C8h],r11
    mov     rdi,r15
    and     rdi,3
    test    rdi,rdi
    je      L11
    jmp     L62
L5:
    test    r12,r12
    je      L61
    jmp     L1
L6:
    test    rbp,rbp
    je      L61
    jmp     L2
L7:
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L12
    jmp     L62
L8:
    cmp     r15,rdx
    jae     L9
    mov     rdi,rdx
    sub     rdi,r15
    jmp     L10
L9:
    mov     rdi,r15
    sub     rdi,rdx
L10:
    cmp     rdi,8
    jb      L62
    mov     edi,[r15]
    mov     r8d,[r15+4]
    mov     [rbp+8],edi
    mov     [rbp+0Ch],r8d
    mov     rdi,rbp
    lea     rdi,[rdi+10h]
    lea     r11,[image.k1800]
    mov     [rsp+0D0h],r11
    mov     r9,rax
    and     r9,3
    test    r9,r9
    je      L17
    jmp     L63
L11:
    test    r15,r15
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
    mov     [rbp+10h],edx
    mov     [rbp+14h],r9d
    mov     rdx,rbp
    lea     rdx,[rdx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+0D8h],r11
    mov     r12,r14
    and     r12,3
    test    r12,r12
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
    cmp     r14,rdx
    jae     L21
    mov     rax,rdx
    sub     rax,r14
    jmp     L22
L21:
    mov     rax,r14
    sub     rax,rdx
L22:
    cmp     rax,8
    jb      L64
    mov     eax,[r14]
    mov     edi,[r14+4]
    mov     [rbp+18h],eax
    mov     [rbp+1Ch],edi
    mov     edx,4
    jmp     L38
L23:
    test    r14,r14
    je      L64
    jmp     L19
L24:
    test    rdx,rdx
    je      L64
    jmp     L20
L25:
    mov     [rsp+380h],rbx
    mov     [rsp+378h],rbx
    lea     r11,[k9]
    mov     [rsp+0A0h],r11
    mov     rdx,rbx
    and     rdx,3
    test    rdx,rdx
    je      L30
    jmp     L65
L26:
    mov     rdx,r13
    and     rdx,3
    test    rdx,rdx
    je      L31
    jmp     L65
L27:
    cmp     rbx,r13
    jae     L28
    mov     rdx,r13
    sub     rdx,rbx
    jmp     L29
L28:
    mov     rdx,rbx
    sub     rdx,r13
L29:
    cmp     rdx,8
    jb      L65
    mov     rdx,[rsp+380h]
    mov     edi,[rdx]
    mov     edx,[rdx+4]
    mov     [r13],edi
    mov     [r13+4],edx
    mov     r10,[rsp+88h]
    lea     rdx,[rbx+r10*8]
    mov     [rsp+380h],rdx
    mov     r10,[rsp+88h]
    lea     rdi,[r13+r10*8]
    mov     [rsp+378h],rdi
    mov     [rsp+3D8h],rdi
    lea     r11,[k11]
    mov     [rsp+90h],r11
    mov     r14,rdx
    and     r14,3
    test    r14,r14
    je      L36
    jmp     L66
L30:
    test    rbx,rbx
    je      L65
    jmp     L26
L31:
    test    r13,r13
    je      L65
    jmp     L27
L32:
    mov     r14,rdi
    and     r14,3
    test    r14,r14
    je      L37
    jmp     L66
L33:
    cmp     rdx,rdi
    jae     L34
    mov     r14,rdi
    sub     r14,rdx
    jmp     L35
L34:
    mov     r14,rdx
    sub     r14,rdi
L35:
    cmp     r14,8
    jb      L66
    mov     r14,[rsp+380h]
    mov     r15d,[r14]
    mov     r14d,[r14+4]
    mov     rbp,[rsp+378h]
    mov     [rbp],r15d
    mov     r15,[rsp+378h]
    mov     [r15+4],r14d
    mov     edx,1
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
    mov     qword ptr [rsp+3D0h],0
    mov     r10,[rsp+88h]
    mov     [rsp+3D8h],r10
    mov     qword ptr [rsp+3C0h],0
    mov     r10,[rsp+88h]
    mov     [rsp+3C8h],r10
    mov     qword ptr [rsp+378h],2
    mov     qword ptr [rsp+380h],0
    mov     r10,[rsp+88h]
    mov     [rsp+388h],r10
    mov     qword ptr [rsp+3C0h],0
    mov     qword ptr [rsp+3C8h],2
    mov     qword ptr [rsp+3D0h],0
    mov     r10,[rsp+88h]
    mov     [rsp+3D8h],r10
    mov     [rsp+170h],r13
    mov     [rsp+108h],rbx
    mov     r11,[rsp+38h]
    mov     [rsp+168h],r11
    mov     [rsp+98h],r13
    mov     r11,[rsp+88h]
    mov     [rsp+0B0h],r11
    mov     [rsp+0E0h],rdx
    mov     r11,[rsp+30h]
    mov     [rsp+100h],r11
L39:
    mov     rdx,[rsp+3C8h]
    mov     rdi,[rsp+3C0h]
    sub     rdx,rdi
    test    rdx,rdx
    jbe     L40
    lea     r11,[image.k6944]
    mov     [rsp+0C0h],r11
    mov     r11,rdi
    add     r11,1
    jb      L67
    lea     rax,[rdi+1]
    mov     [rsp+3C0h],rax
    lea     rax,[rsp+3D0h]
    lea     r11,[image.k7064]
    mov     [rsp+0B8h],r11
    cmp     rdi,2
    jae     L68
    lea     rbp,[rax+rdi*8]
    lea     rdi,[rsp+4D0h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym46]
    mov     rax,[rbp]
    mov     [rsp+150h],rax
    mov     eax,1
    jmp     L41
L40:
    mov     eax,0
L41:
    test    rax,rax
    je      L43
    jmp     L57
L42:
    lea     r9,[rbp+rax*8]
    lea     r12,[rcx+rax*8]
    test    rax,rax
    je      L46
    mov     rax,rsi
    sub     rax,rdx
    mov     [rsp+130h],rax
    mov     r11,[rsp+0E8h]
    mov     [rsp+138h],r11
    mov     [rsp+158h],rbp
    mov     [rsp+160h],rsi
    mov     [rsp+110h],rcx
    mov     [rsp+118h],rdx
    mov     [rsp+120h],r8
    mov     [rsp+128h],r9
    mov     rbp,[rsp+0F0h]
    jmp     L47
L43:
    mov     r10,[rsp+170h]
    mov     [rsp+378h],r10
    mov     r10,[rsp+108h]
    mov     [rsp+380h],r10
    mov     r10,[rsp+168h]
    mov     [rsp+388h],r10
    mov     r10,[rsp+170h]
    mov     [rsp+3D0h],r10
    mov     r10,[rsp+168h]
    mov     [rsp+3C8h],r10
    mov     r10,[rsp+170h]
    mov     [rsp+3C0h],r10
    lea     r11,[k18]
    mov     [rsp+0F8h],r11
    mov     rax,[rsp+170h]
    and     rax,3
    test    rax,rax
    je      L45
    jmp     L69
L44:
    mov     r11,[rsp+168h]
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L69
    mov     r10,[rsp+168h]
    mov     [rsp+3C0h],r10
    mov     r10,[rsp+170h]
    mov     [rsp+3D8h],r10
    mov     r10,[rsp+108h]
    mov     [rsp+3D0h],r10
    mov     rdi,[rsp+170h]
    mov     rsi,[rsp+168h]
    mov     rdx,[rsp+108h]
    mov     rcx,[rsp+100h]
    call    qword ptr [fn20.slot]
    jmp     L60
L45:
    mov     r11,[rsp+170h]
    cmp     r11,0
    je      L69
    jmp     L44
L46:
    mov     [rsp+130h],rdx
    mov     r11,[rsp+0E8h]
    mov     [rsp+138h],r11
    mov     [rsp+158h],rbp
    mov     [rsp+160h],rsi
    mov     [rsp+110h],rcx
    mov     [rsp+118h],rdx
    mov     [rsp+120h],r8
    mov     [rsp+128h],r9
    mov     rbp,[rsp+0F0h]
L47:
    cmp     r8,[rsp+130h]
    jae     L58
    lea     r11,[r8+1]
    mov     [rsp+140h],r11
    mov     r11,[rsp+128h]
    lea     rax,[r11+r8*8]
    lea     rsi,[r12+r8*8]
    lea     r11,[k15]
    mov     [rsp+148h],r11
    mov     rdx,rax
    and     rdx,3
    test    rdx,rdx
    je      L52
    jmp     L70
L48:
    mov     rdx,rsi
    and     rdx,3
    test    rdx,rdx
    je      L53
    jmp     L70
L49:
    cmp     rax,rsi
    jae     L50
    mov     rdx,rsi
    sub     rdx,rax
    jmp     L51
L50:
    mov     rdx,rax
    sub     rdx,rsi
L51:
    cmp     rdx,8
    jb      L70
    mov     edx,[rax]
    mov     r8d,[rax+4]
    mov     [rsi],edx
    mov     [rsi+4],r8d
    mov     rdi,r12
    mov     rdx,rbp
    call    qword ptr [fn17.slot]
    jmp     L59
L52:
    test    rax,rax
    je      L70
    jmp     L48
L53:
    test    rsi,rsi
    je      L70
    jmp     L49
L54:
    mov     [rsp+130h],rdx
    mov     [rsp+138h],rsi
    mov     [rsp+158h],r8
    mov     r8,rax
    mov     [rsp+160h],r9
    mov     [rsp+110h],rcx
    mov     [rsp+118h],rdi
    mov     [rsp+120h],r15
    mov     [rsp+128h],rbx
    mov     r12,r14
    mov     rbp,r13
    jmp     L47
L55:
    mov     r11,[rsp+378h]
    mov     rax,[rsp+380h]
    mov     [rsp+3D8h],rax
    mov     rax,[rsp+388h]
    mov     [rsp+3D0h],rax
L56:
    mov     rbx,[rsp+3B8h]
    mov     r12,[rsp+3B0h]
    mov     r13,[rsp+3A8h]
    mov     r14,[rsp+3A0h]
    mov     r15,[rsp+398h]
    mov     rbp,[rsp+390h]
    add     rsp,4D8h
    ret
L57:
    mov     rax,[rsp+150h]
    mov     rbp,[rsp+108h]
    mov     rcx,[rsp+98h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+168h]
    mov     r8,[rsp+0E0h]
    mov     r11,[rsp+170h]
    mov     [rsp+0E8h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+0F0h],r11
    jmp     L42
L58:
    mov     r11,[rsp+138h]
    mov     [rsp+170h],r11
    mov     r11,[rsp+158h]
    mov     [rsp+108h],r11
    mov     r11,[rsp+160h]
    mov     [rsp+168h],r11
    mov     r11,[rsp+110h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+120h]
    mov     [rsp+0E0h],r11
    mov     [rsp+100h],rbp
    jmp     L39
L59:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+130h]
    mov     rsi,[rsp+138h]
    mov     r8,[rsp+158h]
    mov     r9,[rsp+160h]
    mov     rcx,[rsp+110h]
    mov     rdi,[rsp+118h]
    mov     r15,[rsp+120h]
    mov     rbx,[rsp+128h]
    mov     r14,r12
    mov     r13,rbp
    jmp     L54
L60:
    jmp     L55
    mov     rbx,rax
    lea     rdi,[rsp+1A0h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+1E0h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+220h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+260h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+2A0h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+2E0h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+320h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+360h]
    call    qword ptr [image.fn37.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
    call    sym21
    ud2
L61:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L64:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L65:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L66:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L67:
    lea     rdi,[image.k7768]
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L68:
    lea     rdi,[image.k9969]
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L69:
    lea     rdi,[image.k9407]
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L70:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+148h]
    movzx   edx,dl
    call    image.sym49
    ud2
L71:
    lea     rdi,[rsp+4D0h]
    call    ryo_h_Abort
    ud2
L72:
    lea     rdi,[rsp+3C0h]
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L73
    jmp     L75
L73:
    mov     [rsp+20h],rax
    lea     rdi,[rsp+4D0h]
    mov     esi,0FFFFFB50h
    call    ryo_h_Resume
    ud2
L74:
    lea     rdi,[rsp+378h]
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
    mov     r11,[rdx-0E8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+48h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-148h],r11
    mov     r11,[rsp]
    mov     [rdx-360h],r11
    mov     r11,[rsp+8]
    mov     [rdx-3C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-368h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-438h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-420h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-3F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3D0h],r11
    lea     rsp,[rsp+50h]
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
    mov     r11,[rdx-0E8h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+50h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-3E0h],r11
    mov     rax,[rsp]
    mov     rbp,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+60h]
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
    mov     r11,[rdx-130h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-138h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+68h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+8]
    mov     [rdx-3A0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-398h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-378h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-370h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-3C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3B8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-3B0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-3A8h],r11
    mov     r8,[rsp]
    mov     r12,[rsp+48h]
    mov     rbp,[rsp+50h]
    lea     rsp,[rsp+70h]
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
    mov     r11,[rdx-130h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-138h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-28h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0E8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+68h],r11
    mov     [rdx-118h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-128h],r13
    mov     [rdx-130h],r14
    mov     [rdx-138h],r15
    mov     [rdx-140h],rbp
    mov     r11,[rsp+58h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-148h],r11
    mov     rax,[rsp]
    mov     rsi,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     rdi,[rsp+30h]
    mov     r15,[rsp+38h]
    mov     rbx,[rsp+40h]
    mov     r14,[rsp+48h]
    mov     r13,[rsp+50h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+70h]
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
    mov     rbx,rdi
    mov     [rsp+30h],rdx
    cmp     rsi,0Dh
    jb      L63
    mov     rdi,rbx
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,6
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     r13,rbx
    lea     r13,[r13+4]
    mov     r14,rbx
    lea     r14,[r14+8]
    mov     eax,[rbx+8]
    mov     ecx,[rbx+4]
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
    lea     rax,[rsp+78h]
    lea     rcx,[rsp+80h]
    mov     [rsp+88h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+80h]
    mov     [rsp],rax
    lea     rax,[rsp+78h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+88h]
    mov     [rsp+90h],rax
    mov     rdi,[rsp+68h]
    mov     [rsp+98h],rdi
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
    lea     r11,[image.k2088]
    mov     [rsp+50h],r11
    mov     rax,rbp
    and     rax,3
    test    rax,rax
    je      L1
    jmp     L51
L0:
    mov     eax,[rbp]
    mov     [rbx+4],eax
    lea     rax,[rsp+0A0h]
    lea     rdx,[image.k2112]
    mov     rsi,rax
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
    cmp     rax,r14
    jae     L4
    mov     rsi,r14
    sub     rsi,rax
    jmp     L5
L4:
    mov     rsi,rax
    sub     rsi,r14
L5:
    cmp     rsi,4
    jb      L52
    mov     esi,[rsp+0A0h]
    mov     [rbx+8],esi
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     r15,rbx
    lea     r15,[r15+18h]
    mov     esi,[rbx+18h]
    mov     edi,[rbx+0Ch]
    cmp     esi,edi
    setb    bpl
    mov     [rsp+0C0h],r15
    mov     [rsp+0B8h],r15
    mov     [rsp+0C0h],r13
    lea     rsi,[rsp+0B8h]
    lea     rdi,[rsp+0C0h]
    mov     [rsp+0C8h],rdi
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rsi,[rsp+0C0h]
    mov     [rsp],rsi
    lea     rsi,[rsp+0B8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rsi,[rsp+0C8h]
    mov     [rsp+0D0h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+0D8h],rdi
    call    image.sym13
    jmp     L8
L6:
    test    rax,rax
    je      L52
    jmp     L2
L7:
    test    r14,r14
    je      L52
    jmp     L3
L8:
    mov     rax,[rsp+0D0h]
    mov     [rsp+0D8h],rax
    mov     rax,[rsp+0B8h]
    mov     rsi,[rsp+0C0h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+0D8h]
    mov     [rsp+100h],r13
    mov     [rsp+0F8h],r13
    mov     [rsp+100h],r15
    lea     rax,[rsp+0F8h]
    lea     rsi,[rsp+100h]
    mov     [rsp+108h],rsi
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+100h]
    mov     [rsp],rax
    lea     rax,[rsp+0F8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+108h]
    mov     [rsp+110h],rax
    mov     rdi,[rsp+0E8h]
    mov     [rsp+118h],rdi
    call    image.sym13
    mov     rax,[rsp+110h]
    mov     [rsp+118h],rax
    mov     rax,[rsp+0F8h]
    mov     rsi,[rsp+100h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+118h]
    mov     eax,[rax]
    mov     [rsp+120h],eax
    lea     r11,[image.k2088]
    mov     [rsp+40h],r11
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L10
    jmp     L53
L9:
    mov     esi,[r14]
    mov     [rbx+0Ch],esi
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
    mov     r8,r13
    and     r8,3
    test    r8,r8
    jne     L53
    test    r13,r13
    je      L53
    jmp     L9
L11:
    mov     r8,r15
    and     r8,3
    test    r8,r8
    je      L16
    jmp     L54
L12:
    cmp     rsi,r15
    jae     L13
    mov     r8,r15
    sub     r8,rsi
    jmp     L14
L13:
    mov     r8,rsi
    sub     r8,r15
L14:
    cmp     r8,4
    jb      L54
    mov     r8d,[rsp+120h]
    mov     [rbx+18h],r8d
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     r14,rbx
    lea     r14,[r14+20h]
    mov     r8d,[rbx+20h]
    mov     r9d,[rbx+1Ch]
    cmp     r8d,r9d
    setb    bpl
    mov     [rsp+140h],r14
    mov     [rsp+138h],r14
    mov     [rsp+140h],r13
    lea     r8,[rsp+138h]
    lea     r9,[rsp+140h]
    mov     [rsp+148h],r9
    mov     [rsp+8],bpl
    mov     [rsp],r8
    mov     [rsp+10h],r9
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     r8,[rsp+140h]
    mov     [rsp],r8
    lea     r8,[rsp+138h]
    mov     [rsp+10h],r8
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
    test    r15,r15
    je      L54
    jmp     L12
L17:
    mov     rsi,[rsp+150h]
    mov     [rsp+158h],rsi
    mov     rsi,[rsp+138h]
    mov     r8,[rsp+140h]
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+158h]
    mov     [rsp+180h],r13
    mov     [rsp+178h],r13
    mov     [rsp+180h],r14
    lea     rsi,[rsp+178h]
    lea     r8,[rsp+180h]
    mov     [rsp+188h],r8
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rsi,[rsp+180h]
    mov     [rsp],rsi
    lea     rsi,[rsp+178h]
    mov     [rsp+10h],rsi
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
    mov     [rsp+8],bpl
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
    lea     r11,[image.k2088]
    mov     [rsp+38h],r11
    mov     r8,r12
    and     r8,3
    test    r8,r8
    je      L19
    jmp     L55
L18:
    mov     r8d,[r12]
    mov     [rbx+1Ch],r8d
    lea     r8,[rsp+1A0h]
    lea     r9,[image.k2112]
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    je      L24
    jmp     L56
L19:
    test    r12,r12
    je      L55
    mov     rbp,r13
    and     rbp,3
    test    rbp,rbp
    jne     L55
    test    r13,r13
    je      L55
    jmp     L18
L20:
    mov     r12,r14
    and     r12,3
    test    r12,r12
    je      L25
    jmp     L56
L21:
    cmp     r8,r14
    jae     L22
    mov     r12,r14
    sub     r12,r8
    jmp     L23
L22:
    mov     r12,r8
    sub     r12,r14
L23:
    cmp     r12,4
    jb      L56
    mov     r12d,[rsp+1A0h]
    mov     [rbx+20h],r12d
    mov     r12,rbx
    lea     r12,[r12+24h]
    mov     r13,rbx
    lea     r13,[r13+28h]
    mov     ebp,[rbx+28h]
    mov     esi,[rbx+24h]
    cmp     ebp,esi
    setb    bpl
    mov     [rsp+1C0h],r13
    mov     [rsp+1B8h],r13
    mov     [rsp+1C0h],r12
    lea     rsi,[rsp+1B8h]
    lea     rax,[rsp+1C0h]
    mov     [rsp+1C8h],rax
    mov     [rsp+8],bpl
    mov     [rsp],rsi
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+1C0h]
    mov     [rsp],rax
    lea     rax,[rsp+1B8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+1C8h]
    mov     [rsp+1D0h],rax
    mov     rax,[rsp+1A8h]
    mov     [rsp+1D8h],rax
    mov     rdi,rax
    call    image.sym13
    jmp     L26
L24:
    test    r8,r8
    je      L56
    jmp     L20
L25:
    test    r14,r14
    je      L56
    jmp     L21
L26:
    mov     rax,[rsp+1D0h]
    mov     [rsp+1D8h],rax
    mov     rax,[rsp+1B8h]
    mov     rsi,[rsp+1C0h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+1D8h]
    mov     [rsp+200h],r12
    mov     [rsp+1F8h],r12
    mov     [rsp+200h],r13
    lea     rax,[rsp+1F8h]
    lea     rsi,[rsp+200h]
    mov     [rsp+208h],rsi
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+200h]
    mov     [rsp],rax
    lea     rax,[rsp+1F8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+208h]
    mov     [rsp+210h],rax
    mov     rax,[rsp+1E8h]
    mov     [rsp+218h],rax
    mov     rdi,rax
    call    image.sym13
    mov     rax,[rsp+210h]
    mov     [rsp+218h],rax
    mov     rax,[rsp+1F8h]
    mov     rsi,[rsp+200h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+218h]
    mov     eax,[rax]
    mov     [rsp+220h],eax
    lea     r11,[image.k2088]
    mov     [rsp+48h],r11
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L28
    jmp     L57
L27:
    mov     esi,[r14]
    mov     [rbx+24h],esi
    lea     rsi,[rsp+220h]
    lea     r8,[image.k2112]
    mov     rbp,rsi
    and     rbp,3
    test    rbp,rbp
    je      L33
    jmp     L58
L28:
    test    r14,r14
    je      L57
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    jne     L57
    test    r12,r12
    je      L57
    jmp     L27
L29:
    mov     r12,r13
    and     r12,3
    test    r12,r12
    je      L34
    jmp     L58
L30:
    cmp     rsi,r13
    jae     L31
    mov     r12,r13
    sub     r12,rsi
    jmp     L32
L31:
    mov     r12,rsi
    sub     r12,r13
L32:
    cmp     r12,4
    jb      L58
    mov     r12d,[rsp+220h]
    mov     [rbx+28h],r12d
    mov     r12,rbx
    lea     r12,[r12+2Ch]
    mov     r14,rbx
    lea     r14,[r14+30h]
    mov     ebp,[rbx+30h]
    mov     eax,[rbx+2Ch]
    cmp     ebp,eax
    setb    bpl
    mov     [rsp+240h],r14
    mov     [rsp+238h],r14
    mov     [rsp+240h],r12
    lea     rax,[rsp+238h]
    lea     rcx,[rsp+240h]
    mov     [rsp+248h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+240h]
    mov     [rsp],rax
    lea     rax,[rsp+238h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+248h]
    mov     [rsp+250h],rax
    mov     rax,[rsp+228h]
    mov     [rsp+258h],rax
    mov     rdi,rax
    call    image.sym13
    jmp     L35
L33:
    test    rsi,rsi
    je      L58
    jmp     L29
L34:
    test    r13,r13
    je      L58
    jmp     L30
L35:
    mov     rax,[rsp+250h]
    mov     [rsp+258h],rax
    mov     rax,[rsp+238h]
    mov     rcx,[rsp+240h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym14]
    mov     r13,[rsp+258h]
    mov     [rsp+280h],r12
    mov     [rsp+278h],r12
    mov     [rsp+280h],r14
    lea     rax,[rsp+278h]
    lea     rcx,[rsp+280h]
    mov     [rsp+288h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+280h]
    mov     [rsp],rax
    lea     rax,[rsp+278h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+288h]
    mov     [rsp+290h],rax
    mov     rax,[rsp+268h]
    mov     [rsp+298h],rax
    mov     rdi,rax
    call    image.sym13
    mov     rax,[rsp+290h]
    mov     [rsp+298h],rax
    mov     rax,[rsp+278h]
    mov     rcx,[rsp+280h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+298h]
    mov     eax,[rax]
    mov     [rsp+2A0h],eax
    lea     r11,[image.k2088]
    mov     [rsp+58h],r11
    mov     rax,r13
    and     rax,3
    test    rax,rax
    je      L37
    jmp     L59
L36:
    mov     eax,[r13]
    mov     [rbx+2Ch],eax
    lea     rax,[rsp+2A0h]
    lea     rsi,[image.k2112]
    mov     rbp,rax
    and     rbp,3
    test    rbp,rbp
    je      L42
    jmp     L60
L37:
    test    r13,r13
    je      L59
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    jne     L59
    test    r12,r12
    je      L59
    jmp     L36
L38:
    mov     r12,r14
    and     r12,3
    test    r12,r12
    je      L43
    jmp     L60
L39:
    cmp     rax,r14
    jae     L40
    mov     r12,r14
    sub     r12,rax
    jmp     L41
L40:
    mov     r12,rax
    sub     r12,r14
L41:
    cmp     r12,4
    jb      L60
    mov     r12d,[rsp+2A0h]
    mov     [rbx+30h],r12d
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r13d,[rbx+18h]
    mov     ebp,[rbx+10h]
    cmp     r13d,ebp
    setb    r13b
    mov     [rsp+2C0h],r15
    mov     [rsp+2B8h],r15
    mov     [rsp+2C0h],r12
    lea     rbp,[rsp+2B8h]
    lea     rcx,[rsp+2C0h]
    mov     [rsp+2C8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rbp
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rcx,[rsp+2C0h]
    mov     [rsp],rcx
    lea     rcx,[rsp+2B8h]
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     rcx,[rsp+2C8h]
    mov     [rsp+2D0h],rcx
    mov     rcx,[rsp+2A8h]
    mov     [rsp+2D8h],rcx
    mov     rdi,rcx
    call    image.sym13
    jmp     L44
L42:
    test    rax,rax
    je      L60
    jmp     L38
L43:
    test    r14,r14
    je      L60
    jmp     L39
L44:
    mov     rax,[rsp+2D0h]
    mov     [rsp+2D8h],rax
    mov     rax,[rsp+2B8h]
    mov     rcx,[rsp+2C0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+2D8h]
    mov     [rsp+300h],r12
    mov     [rsp+2F8h],r12
    mov     [rsp+300h],r15
    lea     rax,[rsp+2F8h]
    lea     rcx,[rsp+300h]
    mov     [rsp+308h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+300h]
    mov     [rsp],rax
    lea     rax,[rsp+2F8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+308h]
    mov     [rsp+310h],rax
    mov     rax,[rsp+2E8h]
    mov     [rsp+318h],rax
    mov     rdi,rax
    call    image.sym13
    mov     rax,[rsp+310h]
    mov     [rsp+318h],rax
    mov     rax,[rsp+2F8h]
    mov     rcx,[rsp+300h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+350h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+318h]
    mov     eax,[rax]
    mov     [rsp+320h],eax
    lea     rcx,[image.k2088]
    mov     rax,r14
    and     rax,3
    test    rax,rax
    je      L46
    jmp     L61
L45:
    mov     eax,[r14]
    mov     [rbx+10h],eax
    lea     rax,[rsp+320h]
    lea     r13,[image.k2112]
    mov     rbp,rax
    and     rbp,3
    test    rbp,rbp
    je      L50
    jmp     L62
L46:
    test    r14,r14
    je      L61
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    jne     L61
    test    r12,r12
    je      L61
    jmp     L45
L47:
    mov     r12,r15
    and     r12,3
    test    r12,r12
    jne     L62
    cmp     rax,r15
    jae     L48
    mov     r12,r15
    sub     r12,rax
    jmp     L49
L48:
    mov     r12,rax
    sub     r12,r15
L49:
    cmp     r12,4
    jb      L62
    mov     r12d,[rsp+320h]
    mov     [rbx+18h],r12d
    mov     rdi,rbx
    mov     esi,5
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,9
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+30h]
    call    fn0
    mov     rdi,rbx
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
    test    rax,rax
    je      L62
    jmp     L47
    mov     rbx,rax
    lea     rax,[rsp+90h]
    mov     rdi,rax
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L51:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+50h]
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
    mov     rcx,[rsp+40h]
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
    lea     rdi,[rsp+150h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+190h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L55:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L56:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+1D0h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+210h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L57:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+250h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+290h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L59:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    lea     rdi,[image.k8338]
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+2D0h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rdi,[rsp+310h]
    call    qword ptr [image.fn36.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+350h]
    mov     esi,0FFFFFCD0h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L61:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
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
    sub     rsp,3B8h
    mov     rbx,rdi
    mov     [rsp+48h],rdx
    cmp     rsi,9
    jb      L59
    mov     rdi,rbx
    mov     esi,0
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    fn0
    mov     r11,rbx
    lea     r11,[r11+4]
    mov     [rsp+38h],r11
    mov     r14,rbx
    lea     r14,[r14+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+0D0h],r14
    mov     [rsp+0C8h],r14
    mov     r10,[rsp+38h]
    mov     [rsp+0D0h],r10
    lea     rax,[rsp+0C8h]
    lea     rcx,[rsp+0D0h]
    mov     [rsp+0D8h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+0D0h]
    mov     [rsp],rax
    lea     rax,[rsp+0C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+0D8h]
    mov     [rsp+30h],r11
    mov     rdi,[rsp+0B8h]
    mov     [rsp+0E8h],rdi
    call    image.sym13
    mov     r10,[rsp+30h]
    mov     [rsp+0E8h],r10
    mov     rax,[rsp+0C8h]
    mov     rcx,[rsp+0D0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym14]
    mov     rbp,[rsp+0E8h]
    mov     r10,[rsp+38h]
    mov     [rsp+110h],r10
    mov     r10,[rsp+38h]
    mov     [rsp+108h],r10
    mov     [rsp+110h],r14
    lea     rax,[rsp+108h]
    lea     rcx,[rsp+110h]
    mov     [rsp+118h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+110h]
    mov     [rsp],rax
    lea     rax,[rsp+108h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+118h]
    mov     [rsp+120h],rax
    mov     rdi,[rsp+0F8h]
    mov     [rsp+128h],rdi
    call    image.sym13
    mov     rax,[rsp+120h]
    mov     [rsp+128h],rax
    mov     rax,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+128h]
    mov     eax,[rax]
    mov     [rsp+130h],eax
    lea     rcx,[image.k2088]
    mov     rax,rbp
    and     rax,3
    test    rax,rax
    je      L1
    jmp     L47
L0:
    mov     eax,[rbp]
    mov     [rbx+4],eax
    lea     rax,[rsp+130h]
    lea     rdx,[image.k2112]
    mov     rsi,rax
    and     rsi,3
    test    rsi,rsi
    je      L6
    jmp     L48
L1:
    test    rbp,rbp
    je      L47
    mov     rsi,[rsp+38h]
    and     rsi,3
    test    rsi,rsi
    jne     L47
    mov     r11,[rsp+38h]
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
    cmp     rax,r14
    jae     L4
    mov     rsi,r14
    sub     rsi,rax
    jmp     L5
L4:
    mov     rsi,rax
    sub     rsi,r14
L5:
    cmp     rsi,4
    jb      L48
    mov     esi,[rsp+130h]
    mov     [rbx+1Ch],esi
    mov     r11,rbx
    lea     r11,[r11+8]
    mov     [rsp+58h],r11
    mov     rbp,rbx
    lea     rbp,[rbp+14h]
    mov     esi,[rbx+14h]
    mov     edi,[rbx+8]
    cmp     esi,edi
    setb    r13b
    mov     [rsp+150h],rbp
    mov     [rsp+148h],rbp
    mov     r10,[rsp+58h]
    mov     [rsp+150h],r10
    lea     rsi,[rsp+148h]
    lea     rdi,[rsp+150h]
    mov     [rsp+158h],rdi
    mov     [rsp+8],r13b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rsi,[rsp+150h]
    mov     [rsp],rsi
    lea     rsi,[rsp+148h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+158h]
    mov     [rsp+40h],r11
    mov     rdi,[rsp+138h]
    mov     [rsp+168h],rdi
    call    image.sym13
    jmp     L8
L6:
    test    rax,rax
    je      L48
    jmp     L2
L7:
    test    r14,r14
    je      L48
    jmp     L3
L8:
    mov     r10,[rsp+40h]
    mov     [rsp+168h],r10
    mov     rax,[rsp+148h]
    mov     rsi,[rsp+150h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+168h]
    mov     r10,[rsp+58h]
    mov     [rsp+190h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+188h],r10
    mov     [rsp+190h],rbp
    lea     rax,[rsp+188h]
    lea     rsi,[rsp+190h]
    mov     [rsp+198h],rsi
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+190h]
    mov     [rsp],rax
    lea     rax,[rsp+188h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+198h]
    mov     [rsp+50h],r11
    mov     rdi,[rsp+178h]
    mov     [rsp+1A8h],rdi
    call    image.sym13
    mov     r10,[rsp+50h]
    mov     [rsp+1A8h],r10
    mov     rax,[rsp+188h]
    mov     rsi,[rsp+190h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+1A8h]
    mov     eax,[rax]
    mov     [rsp+1B0h],eax
    lea     r11,[image.k2088]
    mov     [rsp+88h],r11
    mov     rsi,r12
    and     rsi,3
    test    rsi,rsi
    je      L10
    jmp     L49
L9:
    mov     esi,[r12]
    mov     [rbx+8],esi
    lea     rsi,[rsp+1B0h]
    lea     rdi,[image.k2112]
    mov     r8,rsi
    and     r8,3
    test    r8,r8
    je      L15
    jmp     L50
L10:
    test    r12,r12
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
    mov     r8,rbp
    and     r8,3
    test    r8,r8
    je      L16
    jmp     L50
L12:
    cmp     rsi,rbp
    jae     L13
    mov     r8,rbp
    sub     r8,rsi
    jmp     L14
L13:
    mov     r8,rsi
    sub     r8,rbp
L14:
    cmp     r8,4
    jb      L50
    mov     r8d,[rsp+1B0h]
    mov     [rbx+14h],r8d
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r13,rbx
    lea     r13,[r13+20h]
    mov     r8d,[rbx+20h]
    mov     r9d,[rbx+10h]
    cmp     r8d,r9d
    setb    r15b
    mov     [rsp+1D0h],r13
    mov     [rsp+1C8h],r13
    mov     [rsp+1D0h],r12
    lea     r8,[rsp+1C8h]
    lea     r9,[rsp+1D0h]
    mov     [rsp+1D8h],r9
    mov     [rsp+8],r15b
    mov     [rsp],r8
    mov     [rsp+10h],r9
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     r8,[rsp+1D0h]
    mov     [rsp],r8
    lea     r8,[rsp+1C8h]
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+1D8h]
    mov     [rsp+60h],r11
    mov     r8,[rsp+1B8h]
    mov     [rsp+1E8h],r8
    mov     rdi,r8
    call    image.sym13
    jmp     L17
L15:
    test    rsi,rsi
    je      L50
    jmp     L11
L16:
    test    rbp,rbp
    je      L50
    jmp     L12
L17:
    mov     r10,[rsp+60h]
    mov     [rsp+1E8h],r10
    mov     rsi,[rsp+1C8h]
    mov     r8,[rsp+1D0h]
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym14]
    mov     rbp,[rsp+1E8h]
    mov     [rsp+210h],r12
    mov     [rsp+208h],r12
    mov     [rsp+210h],r13
    lea     rsi,[rsp+208h]
    lea     r8,[rsp+210h]
    mov     [rsp+218h],r8
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rsi,[rsp+210h]
    mov     [rsp],rsi
    lea     rsi,[rsp+208h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+218h]
    mov     [rsp+68h],r11
    mov     rsi,[rsp+1F8h]
    mov     [rsp+228h],rsi
    mov     rdi,rsi
    call    image.sym13
    mov     r10,[rsp+68h]
    mov     [rsp+228h],r10
    mov     rsi,[rsp+208h]
    mov     r8,[rsp+210h]
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym14]
    mov     rsi,[rsp+228h]
    mov     esi,[rsi]
    mov     [rsp+230h],esi
    lea     r11,[image.k2088]
    mov     [rsp+70h],r11
    mov     r8,rbp
    and     r8,3
    test    r8,r8
    je      L19
    jmp     L51
L18:
    mov     r8d,[rbp]
    mov     [rbx+10h],r8d
    lea     r8,[rsp+230h]
    lea     r9,[image.k2112]
    mov     r15,r8
    and     r15,3
    test    r15,r15
    je      L24
    jmp     L52
L19:
    test    rbp,rbp
    je      L51
    mov     r15,r12
    and     r15,3
    test    r15,r15
    jne     L51
    test    r12,r12
    je      L51
    jmp     L18
L20:
    mov     r15,r13
    and     r15,3
    test    r15,r15
    je      L25
    jmp     L52
L21:
    cmp     r8,r13
    jae     L22
    mov     r15,r13
    sub     r15,r8
    jmp     L23
L22:
    mov     r15,r8
    sub     r15,r13
L23:
    cmp     r15,4
    jb      L52
    mov     r15d,[rsp+230h]
    mov     [rbx+20h],r15d
    mov     r15d,[rbx+1Ch]
    mov     ebp,[rbx]
    cmp     r15d,ebp
    setb    r15b
    mov     [rsp+250h],r14
    mov     [rsp+248h],r14
    mov     [rsp+250h],rbx
    lea     rbp,[rsp+248h]
    lea     rsi,[rsp+250h]
    mov     [rsp+258h],rsi
    mov     [rsp+8],r15b
    mov     [rsp],rbp
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rsi,[rsp+250h]
    mov     [rsp],rsi
    lea     rsi,[rsp+248h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     rbp,[rsp+258h]
    mov     rsi,[rsp+238h]
    mov     [rsp+268h],rsi
    mov     rdi,rsi
    call    image.sym13
    jmp     L26
L24:
    test    r8,r8
    je      L52
    jmp     L20
L25:
    test    r13,r13
    je      L52
    jmp     L21
L26:
    mov     [rsp+268h],rbp
    mov     rsi,[rsp+248h]
    mov     r8,[rsp+250h]
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym14]
    mov     r13,[rsp+268h]
    mov     [rsp+290h],rbx
    mov     [rsp+288h],rbx
    mov     [rsp+290h],r14
    lea     rsi,[rsp+288h]
    lea     r8,[rsp+290h]
    mov     [rsp+298h],r8
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rsi,[rsp+290h]
    mov     [rsp],rsi
    lea     rsi,[rsp+288h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+298h]
    mov     [rsp+78h],r11
    mov     rsi,[rsp+278h]
    mov     [rsp+2A8h],rsi
    mov     rdi,rsi
    call    image.sym13
    mov     r10,[rsp+78h]
    mov     [rsp+2A8h],r10
    mov     rsi,[rsp+288h]
    mov     r8,[rsp+290h]
    mov     [rsp+8],r15b
    mov     [rsp],rsi
    mov     [rsp+10h],r8
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym14]
    mov     rsi,[rsp+2A8h]
    mov     esi,[rsi]
    mov     [rsp+2B0h],esi
    lea     r11,[image.k2088]
    mov     [rsp+80h],r11
    mov     r8,r13
    and     r8,3
    test    r8,r8
    je      L28
    jmp     L53
L27:
    mov     r8d,[r13]
    mov     [rbx],r8d
    lea     r8,[rsp+2B0h]
    lea     r11,[image.k2112]
    mov     [rsp+90h],r11
    mov     rsi,r8
    and     rsi,3
    test    rsi,rsi
    je      L32
    jmp     L54
L28:
    test    r13,r13
    je      L53
    mov     rsi,rbx
    and     rsi,3
    test    rsi,rsi
    jne     L53
    test    rbx,rbx
    je      L53
    jmp     L27
L29:
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    jne     L54
    cmp     r8,r14
    jae     L30
    mov     rsi,r14
    sub     rsi,r8
    jmp     L31
L30:
    mov     rsi,r8
    sub     rsi,r14
L31:
    cmp     rsi,4
    jb      L54
    mov     esi,[rsp+2B0h]
    mov     [rbx+1Ch],esi
    mov     esi,[rbx+10h]
    mov     r13d,[rbx+8]
    cmp     esi,r13d
    setb    r13b
    mov     [rsp+2D0h],r12
    mov     [rsp+2C8h],r12
    mov     r10,[rsp+58h]
    mov     [rsp+2D0h],r10
    lea     rsi,[rsp+2C8h]
    lea     rax,[rsp+2D0h]
    mov     [rsp+2D8h],rax
    mov     [rsp+8],r13b
    mov     [rsp],rsi
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+2D0h]
    mov     [rsp],rax
    lea     rax,[rsp+2C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     r15,[rsp+2D8h]
    mov     rax,[rsp+2B8h]
    mov     [rsp+2E8h],rax
    mov     rdi,rax
    call    image.sym13
    jmp     L33
L32:
    test    r8,r8
    je      L54
    jmp     L29
L33:
    mov     [rsp+2E8h],r15
    mov     rax,[rsp+2C8h]
    mov     rsi,[rsp+2D0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym14]
    mov     r14,[rsp+2E8h]
    mov     r10,[rsp+58h]
    mov     [rsp+310h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+308h],r10
    mov     [rsp+310h],r12
    lea     rax,[rsp+308h]
    lea     rsi,[rsp+310h]
    mov     [rsp+318h],rsi
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+310h]
    mov     [rsp],rax
    lea     rax,[rsp+308h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+318h]
    mov     [rsp+98h],r11
    mov     rax,[rsp+2F8h]
    mov     [rsp+328h],rax
    mov     rdi,rax
    call    image.sym13
    mov     r10,[rsp+98h]
    mov     [rsp+328h],r10
    mov     rax,[rsp+308h]
    mov     rsi,[rsp+310h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+328h]
    mov     eax,[rax]
    mov     [rsp+330h],eax
    lea     r11,[image.k2088]
    mov     [rsp+0A0h],r11
    mov     rsi,r14
    and     rsi,3
    test    rsi,rsi
    je      L35
    jmp     L55
L34:
    mov     esi,[r14]
    mov     [rbx+8],esi
    lea     rsi,[rsp+330h]
    lea     r8,[image.k2112]
    mov     r13,rsi
    and     r13,3
    test    r13,r13
    je      L39
    jmp     L56
L35:
    test    r14,r14
    je      L55
    mov     r13,[rsp+58h]
    and     r13,3
    test    r13,r13
    je      L34
    jmp     L55
L36:
    mov     r13,r12
    and     r13,3
    test    r13,r13
    jne     L56
    cmp     rsi,r12
    jae     L37
    mov     r13,r12
    sub     r13,rsi
    jmp     L38
L37:
    mov     r13,rsi
    sub     r13,r12
L38:
    cmp     r13,4
    jb      L56
    mov     r13d,[rsp+330h]
    mov     [rbx+10h],r13d
    mov     rdi,rbx
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,2
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    fn0
    mov     r13d,[rbx+4]
    mov     r14d,[rbx]
    cmp     r13d,r14d
    setb    r13b
    mov     r10,[rsp+38h]
    mov     [rsp+350h],r10
    mov     r10,[rsp+38h]
    mov     [rsp+348h],r10
    mov     [rsp+350h],rbx
    lea     r14,[rsp+348h]
    lea     rax,[rsp+350h]
    mov     [rsp+358h],rax
    mov     [rsp+8],r13b
    mov     [rsp],r14
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+350h]
    mov     [rsp],rax
    lea     rax,[rsp+348h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     r14,[rsp+358h]
    mov     rax,[rsp+338h]
    mov     [rsp+368h],rax
    mov     rdi,rax
    call    image.sym13
    jmp     L40
L39:
    test    rsi,rsi
    je      L56
    jmp     L36
L40:
    mov     [rsp+368h],r14
    mov     rax,[rsp+348h]
    mov     rsi,[rsp+350h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym14]
    mov     r12,[rsp+368h]
    mov     [rsp+390h],rbx
    mov     [rsp+388h],rbx
    mov     r10,[rsp+38h]
    mov     [rsp+390h],r10
    lea     rax,[rsp+388h]
    lea     rsi,[rsp+390h]
    mov     [rsp+398h],rsi
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+532]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+390h]
    mov     [rsp],rax
    lea     rax,[rsp+388h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+544]
    call    qword ptr [image.sym12]
    mov     r11,[rsp+398h]
    mov     [rsp+0A8h],r11
    mov     rax,[rsp+378h]
    mov     [rsp+3A8h],rax
    mov     rdi,rax
    call    image.sym13
    mov     r10,[rsp+0A8h]
    mov     [rsp+3A8h],r10
    mov     rax,[rsp+388h]
    mov     rsi,[rsp+390h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+556]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+3E0h]
    lea     rsi,[ro+568]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+3A8h]
    mov     eax,[rax]
    mov     [rsp+3B0h],eax
    lea     r11,[image.k2088]
    mov     [rsp+0B0h],r11
    mov     rsi,r12
    and     rsi,3
    test    rsi,rsi
    je      L42
    jmp     L57
L41:
    mov     esi,[r12]
    mov     [rbx],esi
    lea     rsi,[rsp+3B0h]
    lea     r13,[image.k2112]
    mov     rax,rsi
    and     rax,3
    test    rax,rax
    je      L46
    jmp     L58
L42:
    test    r12,r12
    je      L57
    mov     rax,rbx
    and     rax,3
    test    rax,rax
    je      L41
    jmp     L57
L43:
    mov     rax,[rsp+38h]
    and     rax,3
    test    rax,rax
    jne     L58
    cmp     rsi,[rsp+38h]
    jae     L44
    mov     rax,[rsp+38h]
    sub     rax,rsi
    jmp     L45
L44:
    mov     rax,rsi
    sub     rax,[rsp+38h]
L45:
    cmp     rax,4
    jb      L58
    mov     eax,[rsp+3B0h]
    mov     [rbx+4],eax
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+48h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+48h]
    call    fn0
    add     rsp,3B8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L46:
    test    rsi,rsi
    je      L58
    jmp     L43
    mov     rbx,rax
    mov     rdi,[rsp+30h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    lea     rax,[rsp+120h]
    mov     rdi,rax
    call    qword ptr [image.fn199.slot]
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L47:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
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
    mov     rbx,rax
    mov     rdi,[rsp+40h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+50h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L49:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+88h]
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
    mov     rbx,rax
    mov     rdi,[rsp+60h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+68h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L51:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,rbp
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+78h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L53:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L54:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,r15
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+98h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L55:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L56:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    mov     rdi,r14
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,[rsp+0A8h]
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+3E0h]
    mov     esi,0FFFFFC40h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L57:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L59:
    lea     rdi,[rsp+3E0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,0A8h
    lea     rbx,[rdi+rsi*4]
    lea     r12,[rdi+rdx*4]
    mov     eax,[r12]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+40h],r12
    mov     [rsp+38h],r12
    mov     [rsp+40h],rbx
    lea     rax,[rsp+38h]
    lea     rcx,[rsp+40h]
    mov     [rsp+48h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     r14,[rsp+48h]
    mov     rdi,[rsp+28h]
    mov     [rsp+58h],rdi
    call    image.sym13
    mov     [rsp+58h],r14
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym14]
    mov     r15,[rsp+58h]
    mov     [rsp+80h],rbx
    mov     [rsp+78h],rbx
    mov     [rsp+80h],r12
    lea     rax,[rsp+78h]
    lea     rcx,[rsp+80h]
    mov     [rsp+88h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+80h]
    mov     [rsp],rax
    lea     rax,[rsp+78h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rbp,[rsp+88h]
    mov     rdi,[rsp+68h]
    mov     [rsp+98h],rdi
    call    image.sym13
    mov     [rsp+98h],rbp
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym15]
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym14]
    mov     rax,[rsp+98h]
    mov     eax,[rax]
    mov     [rsp+0A0h],eax
    lea     rcx,[k3]
    mov     rax,r15
    and     rax,3
    test    rax,rax
    je      L1
    jmp     L9
L0:
    mov     eax,[r15]
    mov     [rbx],eax
    jmp     L2
L1:
    test    r15,r15
    je      L9
    mov     rax,rbx
    and     rax,3
    test    rax,rax
    jne     L9
    test    rbx,rbx
    je      L9
    jmp     L0
L2:
    lea     rax,[rsp+0A0h]
    lea     rdx,[k5]
    mov     rsi,rax
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
    cmp     rax,r12
    jae     L5
    mov     rsi,r12
    sub     rsi,rax
    jmp     L6
L5:
    mov     rsi,rax
    sub     rsi,r12
L6:
    cmp     rsi,4
    jb      L10
    mov     esi,[rsp+0A0h]
    mov     [r12],esi
    add     rsp,0A8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L7:
    test    rax,rax
    je      L10
    jmp     L3
L8:
    test    r12,r12
    je      L10
    jmp     L4
    mov     rbx,rax
    mov     rdi,r14
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
    mov     rbx,rax
    mov     rdi,rbp
    call    image.sym13
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
    call    image.sym11
    ud2
L9:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L10:
    lea     rdi,[image.k8338]
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
    lea     rdi,[image.k8338]
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
    mov     rbx,rdi
    mov     [rsp+48h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rcx
    mov     [rsp+40h],rax
    mov     rbp,r8
    mov     [rsp+20h],r9
L0:
    mov     [rsp+110h],rbx
    call    fn0
    cmp     rax,[rsp+48h]
    jb      L1
    mov     rdi,rbx
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r8,[rsp+40h]
    call    qword ptr [image.fn81.slot]
    jmp     L21
L1:
    test    ebp,ebp
    jne     L2
    mov     rdi,rbx
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r8d,1
    mov     r9,[rsp+40h]
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
    lea     rbp,[rbx+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    lea     r13,[rbx+rcx*8]
    mov     r11,[rsp+48h]
    cmp     r11,40h
    jae     L6
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     ecx,[rbx]
    mov     edx,[rbp]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r13]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L4
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L3
    mov     rcx,r13
    jmp     L5
L3:
    mov     rcx,rbp
    jmp     L5
L4:
    mov     rcx,rbx
L5:
    lea     r11,[image.k1336]
    mov     [rsp+58h],r11
    cmp     rcx,rbx
    jb      L24
    sub     rcx,rbx
    shr     rcx,3
    mov     rax,rcx
    jmp     L10
L6:
    mov     r14,rax
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    lea     rsi,[rbx+r15*8]
    mov     r12,r14
    imul    r12,7
    lea     rax,[rbx+r12*8]
    mov     rdi,rbx
    mov     rdx,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     [rsp+50h],rax
    lea     rsi,[rbp+r15*8]
    lea     rax,[rbp+r12*8]
    mov     rdi,rbp
    mov     rdx,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     rbp,rax
    lea     rsi,[r13+r15*8]
    lea     rax,[r13+r12*8]
    mov     rdi,r13
    mov     rdx,rax
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     r11,[rsp+40h]
    mov     r11,[r11]
    mov     r11,[rsp+50h]
    mov     ecx,[r11]
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
    mov     rax,[rsp+50h]
L9:
    lea     r11,[image.k1464]
    mov     [rsp+98h],r11
    cmp     rax,rbx
    jb      L25
    sub     rax,rbx
    shr     rax,3
L10:
    cmp     rax,[rsp+48h]
    setb    sil
    lea     r11,[image.k1512]
    mov     [rsp+90h],r11
    test    sil,sil
    je      L26
    lea     rsi,[rbx+rax*8]
    mov     rsi,[rsi]
    mov     [rsp+110h],rsi
    lea     rsi,[rsp+110h]
    mov     [rsp+0F8h],rsi
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+48h]
    mov     rdi,rax
    mov     r8,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+38h]
    mov     r14,[rsp+28h]
    mov     r15,rsi
    jmp     L22
L11:
    cmp     r9,[rsp+0A0h]
    jae     L31
    lea     rbp,[rsi+r9*8]
    mov     [rsp+0F0h],rbp
    mov     [rsp+0F8h],rax
    mov     r11,[rbx]
    mov     edx,[rax]
    mov     ebp,[rbp]
    cmp     edx,ebp
    setb    dl
    mov     rbp,rdx
    xor     ebp,1
    cmp     dl,1
    jne     L12
    jmp     L13
L12:
    mov     r11,[rsp+0A0h]
    mov     [rsp+78h],r11
    mov     [rsp+80h],r14
    mov     r14,r12
    mov     r12d,0
    mov     rdx,r15
    mov     r15,r13
    mov     r13,rbx
    mov     rbx,rsi
    mov     [rsp+88h],rax
    mov     rax,r9
    jmp     L15
L13:
    mov     rbp,r9
    mov     [rsp+60h],r14
    mov     r14,r12
    mov     r12,[rsp+0A0h]
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
    sete    dl
    mov     [rsp+78h],r12
    mov     r12,rax
    mov     rax,rbp
    mov     rbp,rdx
    mov     r11,[rsp+60h]
    mov     [rsp+80h],r11
    mov     rdx,[rsp+68h]
    mov     r11,[rsp+70h]
    mov     [rsp+88h],r11
L15:
    test    bpl,bpl
    je      L16
    mov     [rsp+0F8h],rbx
    mov     [rsp+0E8h],r13
    lea     rsi,[rsp+0E8h]
    mov     [rsp+0F0h],rsi
    mov     [rsp],rsi
    mov     rdi,rbx
    mov     rsi,[rsp+78h]
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,rax
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     r11,[rsp+78h]
    cmp     r11,rax
    jb      L32
    mov     rsi,[rsp+78h]
    sub     rsi,rax
    mov     [rsp+0F8h],rsi
    mov     r10,[rsp+78h]
    mov     [rsp+0E0h],r10
    lea     rbp,[rbx+rax*8]
    mov     [rsp+0E8h],rbp
    mov     [rsp+0F0h],rsi
    mov     rbx,rbp
    mov     [rsp+48h],rsi
    mov     [rsp+30h],r14
    mov     [rsp+38h],r15
    mov     [rsp+40h],r13
    mov     rbp,[rsp+80h]
    mov     qword ptr [rsp+20h],0
    jmp     L0
L16:
    lea     rsi,[k12]
    mov     r11,[rsp+78h]
    cmp     r11,r12
    jb      L30
    lea     rbp,[image.k6272]
    mov     rdi,rbx
    and     rdi,3
    test    rdi,rdi
    je      L18
    jmp     L28
L17:
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L28
    lea     rdi,[rbx+r12*8]
    mov     rcx,[rsp+78h]
    sub     rcx,r12
    mov     r8,rdi
    and     r8,3
    test    r8,r8
    je      L20
    jmp     L29
L18:
    test    rbx,rbx
    je      L28
    jmp     L17
L19:
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     rcx,r10
    ja      L29
    mov     [rsp+0E0h],rbx
    mov     [rsp+0E8h],r12
    mov     [rsp+0F0h],rdi
    mov     [rsp+0F8h],rcx
    mov     [rsp],r13
    mov     rsi,rcx
    mov     rcx,r15
    mov     r8,[rsp+80h]
    mov     r9,rdx
    mov     rdx,r14
    mov     r8d,r8d
    call    fn14
    mov     [rsp+48h],r12
    mov     [rsp+30h],r14
    mov     [rsp+38h],r15
    mov     [rsp+40h],r13
    mov     rbp,[rsp+80h]
    mov     r11,[rsp+88h]
    mov     [rsp+20h],r11
    jmp     L0
L20:
    test    rdi,rdi
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
    test    rcx,rcx
    je      L23
    mov     rax,rcx
    mov     rsi,rbx
    mov     [rsp+0A0h],rdx
    mov     r9,rdi
    mov     rbx,r8
    jmp     L11
L23:
    mov     rbp,rdi
    mov     [rsp+60h],r14
    mov     r14,r12
    mov     r12,rdx
    mov     [rsp+68h],r15
    mov     r15,r13
    mov     r13,r8
    mov     [rsp+70h],rcx
    jmp     L14
L24:
    lea     rdi,[image.k7567]
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    lea     rdi,[image.k7567]
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L26:
    lea     rdi,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L27:
    lea     rdi,[rsp+1D0h]
    call    ryo_h_Abort
    ud2
L28:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L29:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L30:
    lea     rdi,[image.k6296]
    mov     rdx,rsi
    mov     esi,13h
    call    image.sym6
    ud2
L31:
    lea     rdx,[k7]
    mov     rdi,r9
    mov     rsi,[rsp+0A0h]
    call    sym5
    ud2
L32:
    lea     rcx,[k15]
    mov     rdi,rax
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+78h]
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
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B0h],r11
    mov     rbx,[rsp]
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
    mov     [rdx-130h],r11
    mov     rax,[rsp]
    mov     rsi,[rsp+8]
    mov     r9,[rsp+18h]
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
    mov     rcx,[rsp]
    mov     rbx,[rsp+8]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp+10h]
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
    mov     [rsp+58h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+50h],r8
    mov     [rsp+38h],r9
    mov     r11,[rsp+210h]
    mov     [rsp+40h],r11
    cmp     rcx,[rsp+48h]
    jb      L83
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+50h]
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
    mov     [rsp+70h],r15
    mov     [rsp+78h],rbp
    mov     r11,[rsp+20h]
    mov     [rsp+80h],r11
    mov     rax,[rsp+28h]
    mov     rsi,[rsp+30h]
L1:
    mov     r8,[rsp+108h]
    cmp     r8,rcx
    jae     L37
    mov     rdi,[r14]
    mov     r11,[rdi]
    mov     edi,[r13]
    mov     r8d,[r8]
    cmp     edi,r8d
    setb    dil
    mov     r8,rdi
    xor     r8d,1
    mov     rdx,[rsp+118h]
    lea     rdx,[rdx-8]
    mov     [rsp+118h],rdx
    test    dil,dil
    jne     L2
    mov     rdi,[rsp+100h]
    jmp     L3
L2:
    mov     rdi,rdx
L3:
    mov     rdx,[rsp+110h]
    lea     rdi,[rdi+rdx*8]
    mov     rdx,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r15,rdx
    and     r15,3
    test    r15,r15
    je      L8
    jmp     L74
L4:
    mov     r15,rdi
    and     r15,3
    test    r15,r15
    je      L9
    jmp     L74
L5:
    cmp     rdx,rdi
    jae     L6
    mov     r15,rdi
    sub     r15,rdx
    jmp     L7
L6:
    mov     r15,rdx
    sub     r15,rdi
L7:
    cmp     r15,8
    jb      L74
    mov     r15d,[rdx]
    mov     ebp,[rdx+4]
    mov     [rdi],r15d
    mov     [rdi+4],ebp
    movzx   r15d,r8b
    mov     rbp,[rsp+110h]
    add     rbp,r15
    mov     [rsp+110h],rbp
    mov     r15,[rsp+108h]
    mov     rbp,r15
    lea     rbp,[rbp+8]
    mov     [rsp+108h],rbp
    mov     rbp,[r14]
    mov     r11,[rbp]
    mov     ebp,[r13]
    mov     r15d,[r15+8]
    cmp     ebp,r15d
    setb    r15b
    mov     rbp,r15
    xor     ebp,1
    mov     r9,[rsp+118h]
    lea     r9,[r9-8]
    mov     [rsp+118h],r9
    test    r15b,r15b
    jne     L11
    jmp     L10
L8:
    test    rdx,rdx
    je      L74
    jmp     L4
L9:
    test    rdi,rdi
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+100h]
    jmp     L12
L11:
    mov     rdx,r9
L12:
    mov     rdi,[rsp+110h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     r9,rdi
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
    cmp     rdi,rdx
    jae     L15
    mov     r9,rdx
    sub     r9,rdi
    jmp     L16
L15:
    mov     r9,rdi
    sub     r9,rdx
L16:
    cmp     r9,8
    jb      L75
    mov     r9d,[rdi]
    mov     r15d,[rdi+4]
    mov     [rdx],r9d
    mov     [rdx+4],r15d
    movzx   r9d,bpl
    mov     r15,[rsp+110h]
    add     r15,r9
    mov     [rsp+110h],r15
    mov     r9,[rsp+108h]
    mov     r15,r9
    lea     r15,[r15+8]
    mov     [rsp+108h],r15
    mov     r15,[r14]
    mov     r11,[r15]
    mov     r15d,[r13]
    mov     r9d,[r9+8]
    cmp     r15d,r9d
    setb    r9b
    mov     r15,r9
    xor     r15d,1
    mov     r8,[rsp+118h]
    lea     r8,[r8-8]
    mov     [rsp+118h],r8
    test    r9b,r9b
    jne     L20
    jmp     L19
L17:
    test    rdi,rdi
    je      L75
    jmp     L13
L18:
    test    rdx,rdx
    je      L75
    jmp     L14
L19:
    mov     rdx,[rsp+100h]
    jmp     L21
L20:
    mov     rdx,r8
L21:
    mov     rdi,[rsp+110h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     r9,rdi
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
    cmp     rdi,rdx
    jae     L24
    mov     r9,rdx
    sub     r9,rdi
    jmp     L25
L24:
    mov     r9,rdi
    sub     r9,rdx
L25:
    cmp     r9,8
    jb      L76
    mov     r9d,[rdi]
    mov     ebp,[rdi+4]
    mov     [rdx],r9d
    mov     [rdx+4],ebp
    movzx   r9d,r15b
    mov     rbp,[rsp+110h]
    add     rbp,r9
    mov     [rsp+110h],rbp
    mov     r9,[rsp+108h]
    mov     rbp,r9
    lea     rbp,[rbp+8]
    mov     [rsp+108h],rbp
    mov     rbp,[r14]
    mov     r11,[rbp]
    mov     ebp,[r13]
    mov     r9d,[r9+8]
    cmp     ebp,r9d
    setb    r9b
    mov     rbp,r9
    xor     ebp,1
    mov     [rsp+0C6h],bpl
    mov     r8,[rsp+118h]
    lea     r8,[r8-8]
    mov     [rsp+118h],r8
    test    r9b,r9b
    jne     L29
    jmp     L28
L26:
    test    rdi,rdi
    je      L76
    jmp     L22
L27:
    test    rdx,rdx
    je      L76
    jmp     L23
L28:
    mov     rdx,[rsp+100h]
    jmp     L30
L29:
    mov     rdx,r8
L30:
    mov     rdi,[rsp+110h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+98h],r11
    mov     r9,rdi
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
    cmp     rdi,rdx
    jae     L33
    mov     r9,rdx
    sub     r9,rdi
    jmp     L34
L33:
    mov     r9,rdi
    sub     r9,rdx
L34:
    cmp     r9,8
    jb      L77
    mov     r9d,[rdi]
    mov     r15d,[rdi+4]
    mov     [rdx],r9d
    mov     [rdx+4],r15d
    movzx   r9d,bpl
    mov     r15,[rsp+110h]
    add     r15,r9
    mov     [rsp+110h],r15
    mov     r9,[rsp+108h]
    lea     r9,[r9+8]
    mov     [rsp+108h],r9
    jmp     L1
L35:
    test    rdi,rdi
    je      L77
    jmp     L31
L36:
    test    rdx,rdx
    je      L77
    jmp     L32
L37:
    mov     [rsp+0C0h],rbx
    lea     rcx,[r12+rbx*8]
    mov     [rsp+0A8h],rbx
    mov     [rsp+0B0h],r12
    mov     r12,[rsp+70h]
    mov     r15,[rsp+80h]
    mov     rbp,rsi
    mov     rsi,rax
    mov     rax,[rsp+78h]
L38:
    mov     rdi,[rsp+108h]
    cmp     rdi,rcx
    jae     L47
    mov     r9,[r14]
    mov     r11,[r9]
    mov     r9d,[r13]
    mov     edi,[rdi]
    cmp     r9d,edi
    setb    dil
    mov     r9,rdi
    xor     r9d,1
    mov     [rsp+0C6h],r9b
    mov     r8,[rsp+118h]
    lea     r8,[r8-8]
    mov     [rsp+118h],r8
    test    dil,dil
    jne     L39
    mov     rdi,[rsp+100h]
    jmp     L40
L39:
    mov     rdi,r8
L40:
    mov     r8,[rsp+110h]
    lea     rdi,[rdi+r8*8]
    mov     r8,[rsp+108h]
    lea     r11,[image.k6632]
    mov     [rsp+0A0h],r11
    mov     rbx,r8
    and     rbx,3
    test    rbx,rbx
    je      L45
    jmp     L78
L41:
    mov     rbx,rdi
    and     rbx,3
    test    rbx,rbx
    je      L46
    jmp     L78
L42:
    cmp     r8,rdi
    jae     L43
    mov     rbx,rdi
    sub     rbx,r8
    jmp     L44
L43:
    mov     rbx,r8
    sub     rbx,rdi
L44:
    cmp     rbx,8
    jb      L78
    mov     ebx,[r8]
    mov     edx,[r8+4]
    mov     [rdi],ebx
    mov     [rdi+4],edx
    movzx   edx,r9b
    mov     rbx,[rsp+110h]
    add     rbx,rdx
    mov     [rsp+110h],rbx
    mov     rdx,[rsp+108h]
    lea     rdx,[rdx+8]
    mov     [rsp+108h],rdx
    jmp     L38
L45:
    test    r8,r8
    je      L78
    jmp     L41
L46:
    test    rdi,rdi
    je      L78
    jmp     L42
L47:
    mov     r11,[rsp+0A8h]
    cmp     r11,r12
    je      L56
    lea     rcx,[rsp+100h]
    mov     [rsp+0C0h],rcx
    mov     rcx,[rsp+118h]
    lea     rcx,[rcx-8]
    mov     [rsp+118h],rcx
    test    al,al
    je      L48
    mov     rdx,[rsp+100h]
    jmp     L49
L48:
    mov     rdx,rcx
L49:
    mov     rcx,[rsp+110h]
    lea     rdx,[rdx+rcx*8]
    mov     rcx,[rsp+108h]
    lea     rdi,[image.k6632]
    mov     r8,rcx
    and     r8,3
    test    r8,r8
    je      L54
    jmp     L79
L50:
    mov     r8,rdx
    and     r8,3
    test    r8,r8
    je      L55
    jmp     L79
L51:
    cmp     rcx,rdx
    jae     L52
    mov     r8,rdx
    sub     r8,rcx
    jmp     L53
L52:
    mov     r8,rcx
    sub     r8,rdx
L53:
    cmp     r8,8
    jb      L79
    mov     r8d,[rcx]
    mov     r9d,[rcx+4]
    mov     [rdx],r8d
    mov     [rdx+4],r9d
    movzx   r8d,al
    mov     r9,[rsp+110h]
    add     r9,r8
    mov     [rsp+110h],r9
    mov     r8,[rsp+108h]
    lea     r8,[r8+8]
    mov     [rsp+108h],r8
    mov     rbx,r12
    mov     [rsp+20h],r15
    mov     r15,r12
    mov     r12,[rsp+0B0h]
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rbp
    mov     rbp,rax
    jmp     L0
L54:
    test    rcx,rcx
    je      L79
    jmp     L50
L55:
    test    rdx,rdx
    je      L79
    jmp     L51
L56:
    mov     [rsp+0C0h],rsi
    mov     rcx,[rsp+110h]
    lea     r8,[k15]
    test    rcx,rcx
    jne     L57
    mov     eax,1
    jmp     L58
L57:
    mov     eax,0
L58:
    mov     rdx,rsi
    and     rdx,3
    test    rdx,rdx
    je      L63
    jmp     L81
L59:
    mov     rdx,r15
    and     rdx,3
    test    rdx,rdx
    je      L64
    jmp     L81
L60:
    mov     eax,8
    mul     rcx
    mov     rdx,rax
    jb      L80
    cmp     rsi,r15
    jae     L61
    mov     r9,r15
    sub     r9,rsi
    jmp     L62
L61:
    mov     r9,rsi
    sub     r9,r15
L62:
    cmp     rdx,r9
    ja      L81
    mov     rdx,rcx
    imul    rdx,8
    mov     [rsp+10h],r15
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+200h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE18h
    call    ryo_h_Memcpy
    mov     rdx,[rsp+110h]
    mov     r11,r12
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+0C0h],rdx
    mov     eax,0
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
    test    r15,r15
    je      L81
    jmp     L60
L65:
    cmp     rax,rdx
    jae     L73
    lea     rcx,[rax+1]
    mov     [rsp+0C0h],rax
    lea     rsi,[r12-1]
    sub     rsi,rax
    lea     rsi,[rbp+rsi*8]
    mov     r9,[rsp+110h]
    add     r9,rax
    lea     rax,[r15+r9*8]
    lea     r9,[k19]
    mov     rbx,rsi
    and     rbx,3
    test    rbx,rbx
    je      L70
    jmp     L82
L66:
    mov     rbx,rax
    and     rbx,3
    test    rbx,rbx
    je      L71
    jmp     L82
L67:
    cmp     rsi,rax
    jae     L68
    mov     rbx,rax
    sub     rbx,rsi
    jmp     L69
L68:
    mov     rbx,rsi
    sub     rbx,rax
L69:
    cmp     rbx,8
    jb      L82
    mov     ebx,[rsi]
    mov     r13d,[rsi+4]
    mov     [rax],ebx
    mov     [rax+4],r13d
    mov     rax,rcx
    jmp     L65
L70:
    test    rsi,rsi
    je      L82
    jmp     L66
L71:
    test    rax,rax
    je      L82
    jmp     L67
L72:
    mov     r11,[rsp+58h]
    mov     r10,[rsp+50h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+60h]
    mov     r10,[rsp+48h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+60h]
    mov     [rsp+100h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+108h],r10
    mov     qword ptr [rsp+110h],0
    mov     [rsp+118h],rcx
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+58h]
    mov     r13,rax
    mov     r14,[rsp+40h]
    mov     r15,[rsp+48h]
    mov     rbp,[rsp+38h]
    mov     r11,[rsp+58h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+60h]
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
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L78:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L79:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    lea     rdi,[image.k9346]
    mov     esi,3Dh
    call    image.sym50
    ud2
L81:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L82:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
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
    mov     r11,[rsp+28h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-180h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     rax,[rsp+40h]
    mov     rsi,[rsp+48h]
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
    mov     r11,[rsp+18h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r12,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     r15,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rbp,[rsp+48h]
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
    mov     r12,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r15,[rsp+20h]
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
    mov     [rsp+58h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+50h],r8
    mov     [rsp+38h],r9
    mov     r11,[rsp+200h]
    mov     [rsp+40h],r11
    cmp     rcx,[rsp+48h]
    jb      L83
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+50h]
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
    mov     [rsp+70h],r15
    mov     [rsp+78h],rbp
    mov     r9,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     rsi,[rsp+30h]
L1:
    mov     r8,[rsp+0F8h]
    cmp     r8,rcx
    jae     L37
    mov     r11,[r14]
    mov     r8d,[r8]
    mov     edi,[r13]
    cmp     r8d,edi
    setb    dil
    mov     r8,[rsp+108h]
    lea     r8,[r8-8]
    mov     [rsp+108h],r8
    test    dil,dil
    je      L2
    mov     rdx,[rsp+0F0h]
    jmp     L3
L2:
    mov     rdx,r8
L3:
    mov     r8,[rsp+100h]
    lea     rdx,[rdx+r8*8]
    mov     r8,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r15,r8
    and     r15,3
    test    r15,r15
    je      L8
    jmp     L74
L4:
    mov     r15,rdx
    and     r15,3
    test    r15,r15
    je      L9
    jmp     L74
L5:
    cmp     r8,rdx
    jae     L6
    mov     r15,rdx
    sub     r15,r8
    jmp     L7
L6:
    mov     r15,r8
    sub     r15,rdx
L7:
    cmp     r15,8
    jb      L74
    mov     r15d,[r8]
    mov     ebp,[r8+4]
    mov     [rdx],r15d
    mov     [rdx+4],ebp
    movzx   r15d,dil
    mov     rbp,[rsp+100h]
    add     rbp,r15
    mov     [rsp+100h],rbp
    mov     r15,[rsp+0F8h]
    mov     rbp,r15
    lea     rbp,[rbp+8]
    mov     [rsp+0F8h],rbp
    mov     r11,[r14]
    mov     r15d,[r15+8]
    mov     ebp,[r13]
    cmp     r15d,ebp
    setb    r15b
    mov     rbp,[rsp+108h]
    lea     rbp,[rbp-8]
    mov     [rsp+108h],rbp
    test    r15b,r15b
    jne     L10
    jmp     L11
L8:
    test    r8,r8
    je      L74
    jmp     L4
L9:
    test    rdx,rdx
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+0F0h]
    jmp     L12
L11:
    mov     rdx,rbp
L12:
    mov     rdi,[rsp+100h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+80h],r11
    mov     rbp,rdi
    and     rbp,3
    test    rbp,rbp
    je      L17
    jmp     L75
L13:
    mov     rbp,rdx
    and     rbp,3
    test    rbp,rbp
    je      L18
    jmp     L75
L14:
    cmp     rdi,rdx
    jae     L15
    mov     rbp,rdx
    sub     rbp,rdi
    jmp     L16
L15:
    mov     rbp,rdi
    sub     rbp,rdx
L16:
    cmp     rbp,8
    jb      L75
    mov     ebp,[rdi]
    mov     r8d,[rdi+4]
    mov     [rdx],ebp
    mov     [rdx+4],r8d
    movzx   r8d,r15b
    mov     rbp,[rsp+100h]
    add     rbp,r8
    mov     [rsp+100h],rbp
    mov     r8,[rsp+0F8h]
    mov     rbp,r8
    lea     rbp,[rbp+8]
    mov     [rsp+0F8h],rbp
    mov     r11,[r14]
    mov     r8d,[r8+8]
    mov     ebp,[r13]
    cmp     r8d,ebp
    setb    r8b
    mov     rbp,[rsp+108h]
    lea     rbp,[rbp-8]
    mov     [rsp+108h],rbp
    test    r8b,r8b
    jne     L19
    jmp     L20
L17:
    test    rdi,rdi
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
    mov     rdx,rbp
L21:
    mov     rdi,[rsp+100h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     rbp,rdi
    and     rbp,3
    test    rbp,rbp
    je      L26
    jmp     L76
L22:
    mov     rbp,rdx
    and     rbp,3
    test    rbp,rbp
    je      L27
    jmp     L76
L23:
    cmp     rdi,rdx
    jae     L24
    mov     rbp,rdx
    sub     rbp,rdi
    jmp     L25
L24:
    mov     rbp,rdi
    sub     rbp,rdx
L25:
    cmp     rbp,8
    jb      L76
    mov     ebp,[rdi]
    mov     r15d,[rdi+4]
    mov     [rdx],ebp
    mov     [rdx+4],r15d
    movzx   r15d,r8b
    mov     rbp,[rsp+100h]
    add     rbp,r15
    mov     [rsp+100h],rbp
    mov     r15,[rsp+0F8h]
    mov     rbp,r15
    lea     rbp,[rbp+8]
    mov     [rsp+0F8h],rbp
    mov     r11,[r14]
    mov     r15d,[r15+8]
    mov     ebp,[r13]
    cmp     r15d,ebp
    setb    r15b
    mov     [rsp+0B6h],r15b
    mov     rbp,[rsp+108h]
    lea     rbp,[rbp-8]
    mov     [rsp+108h],rbp
    test    r15b,r15b
    jne     L28
    jmp     L29
L26:
    test    rdi,rdi
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
    mov     rdx,rbp
L30:
    mov     rdi,[rsp+100h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     rbp,rdi
    and     rbp,3
    test    rbp,rbp
    je      L35
    jmp     L77
L31:
    mov     rbp,rdx
    and     rbp,3
    test    rbp,rbp
    je      L36
    jmp     L77
L32:
    cmp     rdi,rdx
    jae     L33
    mov     rbp,rdx
    sub     rbp,rdi
    jmp     L34
L33:
    mov     rbp,rdi
    sub     rbp,rdx
L34:
    cmp     rbp,8
    jb      L77
    mov     ebp,[rdi]
    mov     r8d,[rdi+4]
    mov     [rdx],ebp
    mov     [rdx+4],r8d
    movzx   r8d,r15b
    mov     rbp,[rsp+100h]
    add     rbp,r8
    mov     [rsp+100h],rbp
    mov     r8,[rsp+0F8h]
    lea     r8,[r8+8]
    mov     [rsp+0F8h],r8
    jmp     L1
L35:
    test    rdi,rdi
    je      L77
    jmp     L31
L36:
    test    rdx,rdx
    je      L77
    jmp     L32
L37:
    mov     [rsp+0B0h],rbx
    lea     rcx,[r12+rbx*8]
    mov     [rsp+0A8h],rbx
    mov     [rsp+0A0h],r12
    mov     r12,[rsp+70h]
    mov     r15,r9
    mov     rbp,rsi
    mov     rsi,rax
    mov     rax,[rsp+78h]
L38:
    mov     rdi,[rsp+0F8h]
    cmp     rdi,rcx
    jae     L47
    mov     r11,[r14]
    mov     edi,[rdi]
    mov     r8d,[r13]
    cmp     edi,r8d
    setb    dil
    mov     [rsp+0B6h],dil
    mov     r8,[rsp+108h]
    lea     r8,[r8-8]
    mov     [rsp+108h],r8
    test    dil,dil
    je      L39
    mov     r9,[rsp+0F0h]
    jmp     L40
L39:
    mov     r9,r8
L40:
    mov     r8,[rsp+100h]
    lea     r9,[r9+r8*8]
    mov     r8,[rsp+0F8h]
    lea     r11,[image.k6632]
    mov     [rsp+98h],r11
    mov     rdx,r8
    and     rdx,3
    test    rdx,rdx
    je      L45
    jmp     L78
L41:
    mov     rdx,r9
    and     rdx,3
    test    rdx,rdx
    je      L46
    jmp     L78
L42:
    cmp     r8,r9
    jae     L43
    mov     rdx,r9
    sub     rdx,r8
    jmp     L44
L43:
    mov     rdx,r8
    sub     rdx,r9
L44:
    cmp     rdx,8
    jb      L78
    mov     edx,[r8]
    mov     ebx,[r8+4]
    mov     [r9],edx
    mov     [r9+4],ebx
    movzx   edx,dil
    mov     rbx,[rsp+100h]
    add     rbx,rdx
    mov     [rsp+100h],rbx
    mov     rdx,[rsp+0F8h]
    lea     rdx,[rdx+8]
    mov     [rsp+0F8h],rdx
    jmp     L38
L45:
    test    r8,r8
    je      L78
    jmp     L41
L46:
    test    r9,r9
    je      L78
    jmp     L42
L47:
    mov     r11,[rsp+0A8h]
    cmp     r11,r12
    je      L56
    lea     rcx,[rsp+0F0h]
    mov     [rsp+0B0h],rcx
    mov     rcx,[rsp+108h]
    lea     rcx,[rcx-8]
    mov     [rsp+108h],rcx
    test    al,al
    je      L48
    mov     rdx,[rsp+0F0h]
    jmp     L49
L48:
    mov     rdx,rcx
L49:
    mov     rcx,[rsp+100h]
    lea     rdx,[rdx+rcx*8]
    mov     rcx,[rsp+0F8h]
    lea     rdi,[image.k6632]
    mov     r8,rcx
    and     r8,3
    test    r8,r8
    je      L54
    jmp     L79
L50:
    mov     r8,rdx
    and     r8,3
    test    r8,r8
    je      L55
    jmp     L79
L51:
    cmp     rcx,rdx
    jae     L52
    mov     r8,rdx
    sub     r8,rcx
    jmp     L53
L52:
    mov     r8,rcx
    sub     r8,rdx
L53:
    cmp     r8,8
    jb      L79
    mov     r8d,[rcx]
    mov     r9d,[rcx+4]
    mov     [rdx],r8d
    mov     [rdx+4],r9d
    movzx   r8d,al
    mov     r9,[rsp+100h]
    add     r9,r8
    mov     [rsp+100h],r9
    mov     r8,[rsp+0F8h]
    lea     r8,[r8+8]
    mov     [rsp+0F8h],r8
    mov     rbx,r12
    mov     [rsp+20h],r15
    mov     r15,r12
    mov     r12,[rsp+0A0h]
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rbp
    mov     rbp,rax
    jmp     L0
L54:
    test    rcx,rcx
    je      L79
    jmp     L50
L55:
    test    rdx,rdx
    je      L79
    jmp     L51
L56:
    mov     [rsp+0B0h],rsi
    mov     rcx,[rsp+100h]
    lea     r8,[k15]
    test    rcx,rcx
    jne     L57
    mov     eax,1
    jmp     L58
L57:
    mov     eax,0
L58:
    mov     rdx,rsi
    and     rdx,3
    test    rdx,rdx
    je      L63
    jmp     L81
L59:
    mov     rdx,r15
    and     rdx,3
    test    rdx,rdx
    je      L64
    jmp     L81
L60:
    mov     eax,8
    mul     rcx
    mov     rdx,rax
    jb      L80
    cmp     rsi,r15
    jae     L61
    mov     r9,r15
    sub     r9,rsi
    jmp     L62
L61:
    mov     r9,rsi
    sub     r9,r15
L62:
    cmp     rdx,r9
    ja      L81
    mov     rdx,rcx
    imul    rdx,8
    mov     [rsp+10h],r15
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+1F0h]
    mov     esi,0FFFFFE20h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE28h
    call    ryo_h_Memcpy
    mov     rdx,[rsp+100h]
    mov     r11,r12
    sub     r11,rdx
    mov     rdx,r11
    mov     [rsp+0B0h],rdx
    mov     eax,0
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
    test    r15,r15
    je      L81
    jmp     L60
L65:
    cmp     rax,rdx
    jae     L73
    lea     rcx,[rax+1]
    mov     [rsp+0B0h],rax
    lea     rsi,[r12-1]
    sub     rsi,rax
    lea     rsi,[rbp+rsi*8]
    mov     r9,[rsp+100h]
    add     r9,rax
    lea     rax,[r15+r9*8]
    lea     r9,[k19]
    mov     rbx,rsi
    and     rbx,3
    test    rbx,rbx
    je      L70
    jmp     L82
L66:
    mov     rbx,rax
    and     rbx,3
    test    rbx,rbx
    je      L71
    jmp     L82
L67:
    cmp     rsi,rax
    jae     L68
    mov     rbx,rax
    sub     rbx,rsi
    jmp     L69
L68:
    mov     rbx,rsi
    sub     rbx,rax
L69:
    cmp     rbx,8
    jb      L82
    mov     ebx,[rsi]
    mov     r13d,[rsi+4]
    mov     [rax],ebx
    mov     [rax+4],r13d
    mov     rax,rcx
    jmp     L65
L70:
    test    rsi,rsi
    je      L82
    jmp     L66
L71:
    test    rax,rax
    je      L82
    jmp     L67
L72:
    mov     r11,[rsp+58h]
    mov     r10,[rsp+50h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+60h]
    mov     r10,[rsp+48h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+60h]
    mov     [rsp+0F0h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+0F8h],r10
    mov     qword ptr [rsp+100h],0
    mov     [rsp+108h],rcx
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+58h]
    mov     r13,rax
    mov     r14,[rsp+40h]
    mov     r15,[rsp+48h]
    mov     rbp,[rsp+38h]
    mov     r11,[rsp+58h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+60h]
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
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L79:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    lea     rdi,[image.k9346]
    mov     esi,3Dh
    call    image.sym50
    ud2
L81:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L82:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
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
    mov     r11,[rsp+28h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-178h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     r9,[rsp+38h]
    mov     rax,[rsp+40h]
    mov     rsi,[rsp+48h]
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
    mov     r11,[rsp+18h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r12,[rsp+20h]
    mov     rax,[rsp+28h]
    mov     r15,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rbp,[rsp+48h]
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
    mov     r12,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0D8h
    mov     [rsp+30h],rbx
    mov     [rsp+28h],r12
    mov     [rsp+20h],r13
    mov     [rsp+18h],r14
    mov     [rsp+10h],r15
    mov     [rsp+8],rbp
    mov     [rsp+78h],rdi
    test    rsi,rsi
    jne     L0
    mov     ebp,0
    jmp     L26
L0:
    lea     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rcx
    mov     [rsp+68h],rdx
    mov     [rsp+70h],rax
    mov     [rsp+50h],rdi
    mov     eax,[rdi]
    mov     [rsp+58h],eax
    mov     [rsp+54h],eax
    mov     [rsp+5Ch],eax
    mov     rax,rdi
    lea     rax,[rax+4]
    lea     rcx,[rsp+5Ch]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+50h],0
    mov     [rsp+38h],rdi
    mov     [rsp+40h],rcx
    lea     rax,[rsi-1]
    lea     rdi,[rdi+rax*4]
L1:
    mov     rax,[rsp+48h]
    cmp     rax,rdi
    jae     L14
    mov     byte ptr [rsp+5Ah],1
    mov     r11,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     eax,[rax]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    al
    mov     rcx,[rsp+70h]
    mov     rcx,[rcx]
    mov     rdx,[rsp+50h]
    lea     rcx,[rcx+rdx*4]
    mov     rdx,[rsp+38h]
    lea     r8,[image.k5440]
    mov     r9,rcx
    and     r9,3
    test    r9,r9
    je      L3
    jmp     L27
L2:
    mov     r9d,[rcx]
    mov     [rdx],r9d
    mov     r9,[rsp+48h]
    lea     rbx,[image.k5464]
    mov     r12,r9
    and     r12,3
    test    r12,r12
    je      L7
    jmp     L28
L3:
    test    rcx,rcx
    je      L27
    mov     r12,rdx
    and     r12,3
    test    r12,r12
    jne     L27
    test    rdx,rdx
    je      L27
    jmp     L2
L4:
    mov     rdx,rcx
    and     rdx,3
    test    rdx,rdx
    jne     L28
    cmp     r9,rcx
    jae     L5
    mov     rdx,rcx
    sub     rdx,r9
    jmp     L6
L5:
    mov     rdx,r9
    sub     rdx,rcx
L6:
    cmp     rdx,4
    jb      L28
    mov     edx,[r9]
    mov     [rcx],edx
    mov     rdx,[rsp+48h]
    mov     [rsp+38h],rdx
    movzx   r12d,al
    mov     r13,[rsp+50h]
    add     r13,r12
    mov     [rsp+50h],r13
    mov     r12,rdx
    lea     r12,[r12+4]
    mov     [rsp+48h],r12
    mov     r11,[rsp+60h]
    mov     r12,[rsp+68h]
    mov     r14d,[rdx+4]
    mov     r12d,[r12]
    cmp     r14d,r12d
    setb    r12b
    mov     r14,[rsp+70h]
    mov     r14,[r14]
    lea     r14,[r14+r13*4]
    lea     r13,[image.k5440]
    mov     r15,r14
    and     r15,3
    test    r15,r15
    je      L9
    jmp     L29
L7:
    test    r9,r9
    je      L28
    jmp     L4
L8:
    mov     eax,[r14]
    mov     [rdx],eax
    mov     rax,[rsp+48h]
    lea     rcx,[image.k5464]
    mov     r9,rax
    and     r9,3
    test    r9,r9
    je      L13
    jmp     L30
L9:
    test    r14,r14
    je      L29
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    jne     L29
    test    rdx,rdx
    je      L29
    jmp     L8
L10:
    mov     rdx,r14
    and     rdx,3
    test    rdx,rdx
    jne     L30
    cmp     rax,r14
    jae     L11
    mov     rdx,r14
    sub     rdx,rax
    jmp     L12
L11:
    mov     rdx,rax
    sub     rdx,r14
L12:
    cmp     rdx,4
    jb      L30
    mov     edx,[rax]
    mov     [r14],edx
    mov     rdx,[rsp+48h]
    mov     [rsp+38h],rdx
    movzx   r9d,r12b
    mov     r15,[rsp+50h]
    add     r15,r9
    mov     [rsp+50h],r15
    lea     rdx,[rdx+4]
    mov     [rsp+48h],rdx
    jmp     L1
L13:
    test    rax,rax
    je      L30
    jmp     L10
L14:
    mov     rax,[rsp+78h]
    lea     rax,[rax+rsi*4]
L15:
    mov     rdx,[rsp+48h]
    cmp     rdx,rax
    sete    sil
    mov     [rsp+5Bh],sil
    test    sil,sil
    je      L16
    mov     rsi,[rsp+40h]
    jmp     L17
L16:
    mov     rsi,rdx
L17:
    mov     [rsp+48h],rsi
    mov     r11,[rsp+60h]
    mov     rdx,[rsp+68h]
    mov     esi,[rsi]
    mov     edx,[rdx]
    cmp     esi,edx
    setb    dl
    mov     rsi,[rsp+70h]
    mov     rsi,[rsi]
    mov     rdi,[rsp+50h]
    lea     rsi,[rsi+rdi*4]
    mov     rdi,[rsp+38h]
    lea     r9,[image.k5440]
    mov     r12,rsi
    and     r12,3
    test    r12,r12
    je      L19
    jmp     L31
L18:
    mov     r12d,[rsi]
    mov     [rdi],r12d
    mov     r12,[rsp+48h]
    lea     r14,[image.k5464]
    mov     r15,r12
    and     r15,3
    test    r15,r15
    je      L23
    jmp     L32
L19:
    test    rsi,rsi
    je      L31
    mov     r15,rdi
    and     r15,3
    test    r15,r15
    jne     L31
    test    rdi,rdi
    je      L31
    jmp     L18
L20:
    mov     rdi,rsi
    and     rdi,3
    test    rdi,rdi
    jne     L32
    cmp     r12,rsi
    jae     L21
    mov     rdi,rsi
    sub     rdi,r12
    jmp     L22
L21:
    mov     rdi,r12
    sub     rdi,rsi
L22:
    cmp     rdi,4
    jb      L32
    mov     edi,[r12]
    mov     [rsi],edi
    mov     rdi,[rsp+48h]
    mov     [rsp+38h],rdi
    movzx   r15d,dl
    mov     rbp,[rsp+50h]
    add     rbp,r15
    mov     [rsp+50h],rbp
    lea     rdi,[rdi+4]
    mov     [rsp+48h],rdi
    movzx   edi,byte ptr [rsp+5Bh]
    test    dil,dil
    jne     L24
    jmp     L25
L23:
    test    r12,r12
    je      L32
    jmp     L20
L24:
    mov     r11,[rsp+40h]
    jmp     L26
L25:
    jmp     L15
L26:
    mov     rax,rbp
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+8]
    add     rsp,0D8h
    ret
L27:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L28:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L29:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L30:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L31:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L32:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
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
    .long   L38
L34:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-0A0h]
    mov     [rsp],r11
    mov     r11,[rdx-50h]
    mov     [rsp+8],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0A8h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0B8h],r14
    mov     [rdx-0C0h],r15
    mov     [rdx-0C8h],rbp
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    lea     rsp,[rsp+10h]
    jmp     L1
L35:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0A8h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0B8h],r14
    mov     [rdx-0C0h],r15
    mov     [rdx-0C8h],rbp
    mov     rax,[rsp]
    lea     rsp,[rsp+10h]
    jmp     L15
L36:
    ret
L37:
    ret
L38:
    ret

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
    lea     rdi,[image.k8338]
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
    sub     rsp,388h
    mov     [rsp+2B0h],rbx
    mov     [rsp+2A8h],r12
    mov     [rsp+2A0h],r13
    mov     [rsp+298h],r14
    mov     [rsp+290h],r15
    mov     [rsp+288h],rbp
    mov     rbx,rdi
    mov     [rsp+20h],rsi
    mov     [rsp+18h],r8
    mov     [rsp+10h],rdx
L0:
    mov     r11d,20h
    cmp     r11,[rsp+20h]
    jb      L25
    mov     r11,[rsp+20h]
    cmp     r11,2
    jb      L138
    mov     r15,[rsp+20h]
    shr     r15,1
    mov     r11,[rsp+20h]
    cmp     r11,12h
    setb    [rsp+28h]
    cmp     byte ptr [rsp+28h],0
    je      L1
    mov     r14,[rsp+20h]
    jmp     L2
L1:
    mov     r14,r15
L2:
    lea     r8,[image.k2160]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,r14
    call    image.fn187
    mov     r13,r14
    mov     r14,rbx
L3:
    cmp     r13,0Dh
    jb      L4
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,[rsp+18h]
    call    qword ptr [image.fn74.slot]
    mov     eax,0Dh
    jmp     L6
L4:
    cmp     r13,9
    jb      L5
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,[rsp+18h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L6
L5:
    mov     eax,1
L6:
    test    rax,rax
    je      L142
    cmp     r13,rax
    jb      L142
    lea     r13,[r14+r13*4]
    lea     rax,[r14+rax*4]
    mov     r12,rax
L7:
    cmp     r12,r13
    je      L21
    mov     rax,r12
    lea     rax,[rax-4]
    mov     edx,[r12]
    mov     esi,[r12-4]
    cmp     edx,esi
    setb    dl
    mov     [rsp+17Fh],dl
    test    dl,dl
    je      L19
    mov     edx,[r12]
    mov     [rsp+17Ch],edx
    mov     rbp,rax
    mov     rax,r12
L8:
    lea     r11,[image.k1728]
    mov     [rsp+80h],r11
    mov     rsi,rbp
    and     rsi,3
    test    rsi,rsi
    je      L13
    jmp     L139
L9:
    mov     rsi,rax
    and     rsi,3
    test    rsi,rsi
    je      L14
    jmp     L139
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
    jb      L139
    mov     esi,[rbp]
    mov     [rax],esi
    cmp     rbp,r14
    je      L16
    jmp     L20
L13:
    test    rbp,rbp
    je      L139
    jmp     L9
L14:
    test    rax,rax
    je      L139
    jmp     L10
L15:
    mov     r10,rbp
    mov     rbp,rax
    mov     rax,r10
    jmp     L8
L16:
    lea     rdi,[rsp+17Ch]
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    test    sil,sil
    jne     L18
    jmp     L140
L17:
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    mov     rsi,rax
    test    sil,sil
    je      L140
    lea     rdi,[rsp+17Ch]
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    mov     rsi,rax
    test    sil,sil
    je      L140
    mov     esi,[rsp+17Ch]
    mov     [rbp],esi
    jmp     L19
L18:
    lea     rsi,[rsp+17Ch]
    test    rsi,rsi
    je      L140
    jmp     L17
L19:
    mov     rsi,r12
    lea     rsi,[rsi+4]
    mov     r12,rsi
    jmp     L7
L20:
    mov     rax,rbp
    lea     rax,[rax-4]
    mov     esi,[rsp+17Ch]
    mov     edi,[rbp-4]
    cmp     esi,edi
    jb      L15
    jmp     L16
L21:
    cmp     byte ptr [rsp+28h],0
    jne     L138
    cmp     r14,rbx
    je      L22
    lea     r8,[image.k2208]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+20h]
    call    image.fn187
    lea     rax,[rsp+188h]
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    mov     rcx,[rsp+18h]
    call    qword ptr [image.fn78.slot]
    lea     r9,[image.k2232]
    lea     rdi,[rsp+188h]
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+20h]
    call    image.fn180
    mov     rax,[rsp+20h]
    imul    rax,4
    lea     rsi,[rsp+188h]
    mov     rdi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L138
L22:
    lea     rax,[rbx+r15*4]
    mov     rsi,[rsp+20h]
    sub     rsi,r15
    lea     r11,[image.k2184]
    mov     [rsp+60h],r11
    mov     r8,rax
    and     r8,3
    test    r8,r8
    je      L24
    jmp     L143
L23:
    mov     r14,rax
    mov     r13,rsi
    jmp     L3
L24:
    test    rax,rax
    je      L143
    jmp     L23
L25:
    test    ecx,ecx
    jne     L26
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
    jmp     L138
L26:
    lea     r11d,[rcx-1]
    mov     [rsp+30h],r11
    mov     rax,[rsp+20h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    lea     r13,[rbx+rcx*4]
    mov     rcx,rax
    imul    rcx,7
    lea     r14,[rbx+rcx*4]
    mov     r11,[rsp+20h]
    cmp     r11,40h
    jae     L30
    mov     ecx,[rbx]
    mov     esi,[r13]
    cmp     ecx,esi
    setb    r8b
    mov     r9d,[r14]
    cmp     ecx,r9d
    setb    cl
    cmp     r8b,cl
    jne     L28
    cmp     esi,r9d
    setb    cl
    xor     ecx,r8d
    test    cl,cl
    je      L27
    mov     rcx,r14
    jmp     L29
L27:
    mov     rcx,r13
    jmp     L29
L28:
    mov     rcx,rbx
L29:
    lea     r11,[image.k1536]
    mov     [rsp+58h],r11
    cmp     rcx,rbx
    jb      L144
    sub     rcx,rbx
    shr     rcx,2
    mov     [rsp+78h],rcx
    jmp     L34
L30:
    mov     r15,rax
    shr     r15,3
    mov     rbp,r15
    imul    rbp,4
    lea     rax,[rbx+rbp*4]
    mov     r12,r15
    imul    r12,7
    lea     rcx,[rbx+r12*4]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     [rsp+38h],rax
    lea     rax,[r13+rbp*4]
    lea     rcx,[r13+r12*4]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r13,rax
    lea     rax,[r14+rbp*4]
    lea     rcx,[r14+r12*4]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r11,[rsp+38h]
    mov     ecx,[r11]
    mov     r8d,[r13]
    cmp     ecx,r8d
    setb    r9b
    mov     r12d,[rax]
    cmp     ecx,r12d
    setb    cl
    cmp     r9b,cl
    jne     L32
    cmp     r8d,r12d
    setb    cl
    xor     ecx,r9d
    test    cl,cl
    je      L31
    jmp     L33
L31:
    mov     rax,r13
    jmp     L33
L32:
    mov     rax,[rsp+38h]
L33:
    lea     r11,[image.k1584]
    mov     [rsp+50h],r11
    cmp     rax,rbx
    jb      L145
    sub     rax,rbx
    shr     rax,2
    mov     [rsp+78h],rax
L34:
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+20h]
    setb    r8b
    lea     r11,[image.k1632]
    mov     [rsp+48h],r11
    test    r8b,r8b
    je      L146
    mov     r11,[rsp+10h]
    cmp     r11,0
    je      L85
    mov     r10,[rsp+78h]
    lea     r8,[rbx+r10*4]
    mov     r11,[rsp+10h]
    mov     r12d,[r11]
    mov     r13d,[r8]
    cmp     r12d,r13d
    jb      L85
    mov     r10,[rsp+18h]
    mov     [rsp+2E0h],r10
    lea     r12,[rsp+20Ch]
    lea     r11,[image.k488]
    mov     [rsp+40h],r11
    mov     r14,rbx
    and     r14,3
    test    r14,r14
    je      L39
    jmp     L147
L35:
    mov     r14,r12
    and     r14,3
    test    r14,r14
    je      L40
    jmp     L147
L36:
    cmp     rbx,r12
    jae     L37
    mov     r14,r12
    sub     r14,rbx
    jmp     L38
L37:
    mov     r14,rbx
    sub     r14,r12
L38:
    cmp     r14,4
    jb      L147
    mov     r14d,[rbx]
    mov     [rsp+20Ch],r14d
    lea     r11,[image.k512]
    mov     [rsp+88h],r11
    mov     r15,r8
    and     r15,3
    test    r15,r15
    je      L42
    jmp     L148
L39:
    test    rbx,rbx
    je      L147
    jmp     L35
L40:
    test    r12,r12
    je      L147
    jmp     L36
L41:
    mov     r12d,[r8]
    mov     [rbx],r12d
    lea     r12,[rsp+20Ch]
    lea     r11,[image.k536]
    mov     [rsp+70h],r11
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    je      L46
    jmp     L149
L42:
    test    r8,r8
    je      L148
    mov     rbp,rbx
    and     rbp,3
    test    rbp,rbp
    je      L41
    jmp     L148
L43:
    mov     rbp,r8
    and     rbp,3
    test    rbp,rbp
    jne     L149
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
    jb      L149
    mov     ebp,[rsp+20Ch]
    mov     [r8],ebp
    lea     r11,[image.k6360]
    mov     [rsp+68h],r11
    mov     r13,rbx
    and     r13,3
    test    r13,r13
    je      L47
    jmp     L150
L46:
    test    r12,r12
    je      L149
    jmp     L43
L47:
    mov     r8,rbx
    lea     r8,[r8+4]
    mov     r11,[rsp+20h]
    sub     r11,1
    mov     [rsp+0A8h],r11
    mov     r13,r8
    and     r13,3
    test    r13,r13
    je      L49
    jmp     L151
L48:
    mov     r11,[rsp+0A8h]
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L151
    mov     [rsp+218h],r8
    lea     r13,[rsp+218h]
    mov     [rsp+228h],r13
    mov     r13d,[rbx+4]
    mov     [rsp+228h],r13d
    mov     [rsp+22Ch],r13d
    mov     r13,rbx
    lea     r13,[r13+8]
    lea     r11,[rsp+22Ch]
    mov     [rsp+98h],r11
    mov     rcx,[rsp+0A8h]
    sub     rcx,1
    lea     r11,[r8+rcx*4]
    mov     [rsp+0B0h],r11
    mov     qword ptr [rsp+0C0h],0
    mov     esi,0
    mov     rdi,r8
    jmp     L50
L49:
    test    r8,r8
    je      L151
    jmp     L48
L50:
    cmp     r13,[rsp+0B0h]
    jae     L63
    mov     byte ptr [rsp+22Ah],1
    mov     r11,[rsp+2E0h]
    mov     ebp,[rbx]
    mov     r15d,[r13]
    cmp     ebp,r15d
    setb    r15b
    xor     r15d,1
    mov     rbp,[rsp+218h]
    mov     eax,[rsp+0C0h]
    mov     edx,esi
    mov     r14,rdx
    shl     r14,20h
    or      r14,rax
    lea     rbp,[rbp+r14*4]
    lea     r11,[image.k5392]
    mov     [rsp+90h],r11
    mov     r14,rbp
    and     r14,3
    test    r14,r14
    je      L52
    jmp     L152
L51:
    mov     r14d,[rbp]
    mov     [rdi],r14d
    lea     r11,[image.k5416]
    mov     [rsp+0A0h],r11
    mov     r9,r13
    and     r9,3
    test    r9,r9
    je      L56
    jmp     L153
L52:
    test    rbp,rbp
    je      L152
    mov     r9,rdi
    and     r9,3
    test    r9,r9
    jne     L152
    test    rdi,rdi
    je      L152
    jmp     L51
L53:
    mov     r9,rbp
    and     r9,3
    test    r9,r9
    jne     L153
    cmp     r13,rbp
    jae     L54
    mov     r9,rbp
    sub     r9,r13
    jmp     L55
L54:
    mov     r9,r13
    sub     r9,rbp
L55:
    cmp     r9,4
    jb      L153
    mov     r9d,[r13]
    mov     [rbp],r9d
    movzx   r9d,r15b
    mov     r14,rdx
    shl     r14,20h
    or      r14,rax
    add     r14,r9
    mov     r9,r13
    lea     r9,[r9+4]
    mov     r11,[rsp+2E0h]
    mov     r12d,[rbx]
    mov     ecx,[r13+4]
    cmp     r12d,ecx
    setb    cl
    xor     ecx,1
    mov     r12,[rsp+218h]
    lea     r12,[r12+r14*4]
    lea     r11,[image.k5392]
    mov     [rsp+0B8h],r11
    mov     r8,r12
    and     r8,3
    test    r8,r8
    je      L58
    jmp     L154
L56:
    test    r13,r13
    je      L153
    jmp     L53
L57:
    mov     eax,[r12]
    mov     [r13],eax
    lea     r11,[image.k5416]
    mov     [rsp+110h],r11
    mov     rdx,r9
    and     rdx,3
    test    rdx,rdx
    je      L62
    jmp     L155
L58:
    test    r12,r12
    je      L154
    mov     rdx,r13
    and     rdx,3
    test    rdx,rdx
    je      L57
    jmp     L154
L59:
    mov     rdx,r12
    and     rdx,3
    test    rdx,rdx
    jne     L155
    cmp     r9,r12
    jae     L60
    mov     rdx,r12
    sub     rdx,r9
    jmp     L61
L60:
    mov     rdx,r9
    sub     rdx,r12
L61:
    cmp     rdx,4
    jb      L155
    mov     edx,[r13+4]
    mov     [r12],edx
    movzx   edx,cl
    add     rdx,r14
    mov     r8,rdx
    shr     r8,20h
    mov     r15,r13
    lea     r15,[r15+8]
    mov     r13,r15
    mov     [rsp+0C0h],rdx
    mov     rsi,r8
    mov     rdi,r9
    jmp     L50
L62:
    test    r9,r9
    je      L155
    jmp     L59
L63:
    mov     rcx,[rsp+218h]
    mov     r10,[rsp+0A8h]
    lea     rcx,[rcx+r10*4]
    mov     rdx,[rsp+0C0h]
L64:
    cmp     r13,rcx
    sete    r8b
    mov     [rsp+22Bh],r8b
    test    r8b,r8b
    je      L65
    mov     r13,[rsp+98h]
    jmp     L65
L65:
    mov     r11,[rsp+2E0h]
    mov     r8d,[rbx]
    mov     r9d,[r13]
    cmp     r8d,r9d
    setb    r8b
    xor     r8d,1
    mov     r9,[rsp+218h]
    mov     edx,edx
    mov     esi,esi
    mov     r12,rsi
    shl     r12,20h
    or      r12,rdx
    lea     r9,[r9+r12*4]
    lea     r11,[image.k5392]
    mov     [rsp+0C8h],r11
    mov     r14,r9
    and     r14,3
    test    r14,r14
    je      L67
    jmp     L156
L66:
    mov     r14d,[r9]
    mov     [rdi],r14d
    lea     r11,[image.k5416]
    mov     [rsp+118h],r11
    mov     r15,r13
    and     r15,3
    test    r15,r15
    je      L72
    jmp     L157
L67:
    test    r9,r9
    je      L156
    mov     r15,rdi
    and     r15,3
    test    r15,r15
    jne     L156
    test    rdi,rdi
    je      L156
    jmp     L66
L68:
    mov     rdi,r9
    and     rdi,3
    test    rdi,rdi
    jne     L157
    cmp     r13,r9
    jae     L69
    mov     rdi,r9
    sub     rdi,r13
    jmp     L70
L69:
    mov     rdi,r13
    sub     rdi,r9
L70:
    cmp     rdi,4
    jb      L157
    mov     edi,[r13]
    mov     [r9],edi
    movzx   edi,r8b
    mov     r15,rsi
    shl     r15,20h
    or      r15,rdx
    add     r15,rdi
    mov     rdi,r15
    shr     rdi,20h
    mov     rbp,r13
    lea     rbp,[rbp+4]
    movzx   r12d,byte ptr [rsp+22Bh]
    test    r12b,r12b
    jne     L73
    jmp     L71
L71:
    mov     rdx,r15
    mov     rsi,rdi
    mov     rdi,r13
    mov     r13,rbp
    jmp     L64
L72:
    test    r13,r13
    je      L157
    jmp     L68
L73:
    cmp     r15,[rsp+20h]
    jae     L161
    lea     rcx,[rbx+r15*4]
    lea     rdx,[rsp+23Ch]
    lea     r11,[image.k488]
    mov     [rsp+0D8h],r11
    mov     rdi,rbx
    and     rdi,3
    test    rdi,rdi
    jne     L158
    mov     rdi,rdx
    and     rdi,3
    test    rdi,rdi
    je      L77
    jmp     L158
L74:
    cmp     rbx,rdx
    jae     L75
    mov     rdi,rdx
    sub     rdi,rbx
    jmp     L76
L75:
    mov     rdi,rbx
    sub     rdi,rdx
L76:
    cmp     rdi,4
    jb      L158
    mov     edi,[rbx]
    mov     [rsp+23Ch],edi
    lea     r11,[image.k512]
    mov     [rsp+0E8h],r11
    mov     r8,rcx
    and     r8,3
    test    r8,r8
    je      L79
    jmp     L159
L77:
    test    rdx,rdx
    je      L158
    jmp     L74
L78:
    mov     edx,[rcx]
    mov     [rbx],edx
    lea     rdx,[rsp+23Ch]
    lea     r11,[image.k536]
    mov     [rsp+0E0h],r11
    mov     r9,rdx
    and     r9,3
    test    r9,r9
    je      L83
    jmp     L160
L79:
    test    rcx,rcx
    je      L159
    mov     r9,rbx
    and     r9,3
    test    r9,r9
    je      L78
    jmp     L159
L80:
    mov     r9,rcx
    and     r9,3
    test    r9,r9
    jne     L160
    cmp     rdx,rcx
    jae     L81
    mov     r9,rcx
    sub     r9,rdx
    jmp     L82
L81:
    mov     r9,rdx
    sub     r9,rcx
L82:
    cmp     r9,4
    jb      L160
    mov     r9d,[rsp+23Ch]
    mov     [rcx],r9d
    lea     r11,[r15+1]
    mov     [rsp+100h],r11
    mov     r11,[rsp+20h]
    cmp     r11,[rsp+100h]
    jb      L182
    jmp     L84
L83:
    test    rdx,rdx
    je      L160
    jmp     L80
L84:
    mov     rcx,[rsp+20h]
    sub     rcx,[rsp+100h]
    mov     [rsp+2D0h],rbx
    mov     r10,[rsp+20h]
    mov     [rsp+2D8h],r10
    mov     [rsp+2C8h],rbx
    mov     r10,[rsp+100h]
    lea     rdx,[rbx+r10*4]
    mov     [rsp+2C0h],rdx
    mov     [rsp+2E0h],rdx
    mov     rbx,rdx
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+30h]
    mov     qword ptr [rsp+10h],0
    jmp     L0
L85:
    mov     r10,[rsp+78h]
    lea     rcx,[rbx+r10*4]
    lea     rdx,[rsp+24Ch]
    lea     r11,[image.k488]
    mov     [rsp+0D0h],r11
    mov     r13,rbx
    and     r13,3
    test    r13,r13
    je      L90
    jmp     L162
L86:
    mov     r13,rdx
    and     r13,3
    test    r13,r13
    je      L91
    jmp     L162
L87:
    cmp     rbx,rdx
    jae     L88
    mov     r13,rdx
    sub     r13,rbx
    jmp     L89
L88:
    mov     r13,rbx
    sub     r13,rdx
L89:
    cmp     r13,4
    jb      L162
    mov     r13d,[rbx]
    mov     [rsp+24Ch],r13d
    lea     r11,[image.k512]
    mov     [rsp+128h],r11
    mov     r15,rcx
    and     r15,3
    test    r15,r15
    je      L93
    jmp     L163
L90:
    test    rbx,rbx
    je      L162
    jmp     L86
L91:
    test    rdx,rdx
    je      L162
    jmp     L87
L92:
    mov     edx,[rcx]
    mov     [rbx],edx
    lea     rdx,[rsp+24Ch]
    lea     r11,[image.k536]
    mov     [rsp+0F0h],r11
    mov     rbp,rdx
    and     rbp,3
    test    rbp,rbp
    je      L97
    jmp     L164
L93:
    test    rcx,rcx
    je      L163
    mov     rbp,rbx
    and     rbp,3
    test    rbp,rbp
    je      L92
    jmp     L163
L94:
    mov     rbp,rcx
    and     rbp,3
    test    rbp,rbp
    jne     L164
    cmp     rdx,rcx
    jae     L95
    mov     rbp,rcx
    sub     rbp,rdx
    jmp     L96
L95:
    mov     rbp,rdx
    sub     rbp,rcx
L96:
    cmp     rbp,4
    jb      L164
    mov     ebp,[rsp+24Ch]
    mov     [rcx],ebp
    lea     r11,[image.k6360]
    mov     [rsp+0F8h],r11
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    je      L98
    jmp     L165
L97:
    test    rdx,rdx
    je      L164
    jmp     L94
L98:
    mov     rcx,rbx
    lea     rcx,[rcx+4]
    mov     r11,[rsp+20h]
    sub     r11,1
    mov     [rsp+130h],r11
    mov     r12,rcx
    and     r12,3
    test    r12,r12
    je      L100
    jmp     L166
L99:
    mov     r11,[rsp+130h]
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L166
    mov     [rsp+258h],rcx
    lea     r12,[rsp+258h]
    mov     [rsp+268h],r12
    mov     r12d,[rbx+4]
    mov     [rsp+268h],r12d
    mov     [rsp+26Ch],r12d
    mov     r12,rbx
    lea     r12,[r12+8]
    lea     r11,[rsp+26Ch]
    mov     [rsp+108h],r11
    mov     r8,[rsp+130h]
    sub     r8,1
    lea     r11,[rcx+r8*4]
    mov     [rsp+138h],r11
    mov     qword ptr [rsp+140h],0
    mov     qword ptr [rsp+148h],0
    mov     r15,rcx
    jmp     L101
L100:
    test    rcx,rcx
    je      L166
    jmp     L99
L101:
    cmp     r12,[rsp+138h]
    jae     L114
    mov     byte ptr [rsp+26Ah],1
    mov     ebp,[r12]
    mov     r9d,[rbx]
    cmp     ebp,r9d
    setb    r9b
    mov     rbp,[rsp+258h]
    mov     esi,[rsp+140h]
    mov     eax,[rsp+148h]
    mov     r14,rax
    shl     r14,20h
    or      r14,rsi
    lea     rbp,[rbp+r14*4]
    lea     r11,[image.k5440]
    mov     [rsp+120h],r11
    mov     r14,rbp
    and     r14,3
    test    r14,r14
    je      L103
    jmp     L167
L102:
    mov     r14d,[rbp]
    mov     [r15],r14d
    lea     r11,[image.k5464]
    mov     [rsp+150h],r11
    mov     r13,r12
    and     r13,3
    test    r13,r13
    je      L107
    jmp     L168
L103:
    test    rbp,rbp
    je      L167
    mov     r13,r15
    and     r13,3
    test    r13,r13
    jne     L167
    test    r15,r15
    je      L167
    jmp     L102
L104:
    mov     r13,rbp
    and     r13,3
    test    r13,r13
    jne     L168
    cmp     r12,rbp
    jae     L105
    mov     r13,rbp
    sub     r13,r12
    jmp     L106
L105:
    mov     r13,r12
    sub     r13,rbp
L106:
    cmp     r13,4
    jb      L168
    mov     r13d,[r12]
    mov     [rbp],r13d
    movzx   r13d,r9b
    mov     rdx,rax
    shl     rdx,20h
    or      rdx,rsi
    add     rdx,r13
    mov     r13,r12
    lea     r13,[r13+4]
    mov     r8d,[r12+4]
    mov     ecx,[rbx]
    cmp     r8d,ecx
    setb    cl
    mov     r8,[rsp+258h]
    lea     r8,[r8+rdx*4]
    lea     rdi,[image.k5440]
    mov     r14,r8
    and     r14,3
    test    r14,r14
    je      L109
    jmp     L169
L107:
    test    r12,r12
    je      L168
    jmp     L104
L108:
    mov     eax,[r8]
    mov     [r12],eax
    lea     rax,[image.k5464]
    mov     rsi,r13
    and     rsi,3
    test    rsi,rsi
    je      L113
    jmp     L170
L109:
    test    r8,r8
    je      L169
    mov     rsi,r12
    and     rsi,3
    test    rsi,rsi
    je      L108
    jmp     L169
L110:
    mov     rsi,r8
    and     rsi,3
    test    rsi,rsi
    jne     L170
    cmp     r13,r8
    jae     L111
    mov     rsi,r8
    sub     rsi,r13
    jmp     L112
L111:
    mov     rsi,r13
    sub     rsi,r8
L112:
    cmp     rsi,4
    jb      L170
    mov     esi,[r12+4]
    mov     [r8],esi
    movzx   esi,cl
    add     rsi,rdx
    mov     r9,rsi
    shr     r9,20h
    mov     r14,r12
    lea     r14,[r14+8]
    mov     r12,r14
    mov     [rsp+140h],rsi
    mov     [rsp+148h],r9
    mov     r15,r13
    jmp     L101
L113:
    test    r13,r13
    je      L170
    jmp     L110
L114:
    mov     rcx,[rsp+258h]
    mov     r10,[rsp+130h]
    lea     r11,[rcx+r10*4]
    mov     [rsp+160h],r11
    mov     rdx,[rsp+140h]
    mov     rsi,[rsp+148h]
L115:
    cmp     r12,[rsp+160h]
    sete    r8b
    mov     [rsp+26Bh],r8b
    test    r8b,r8b
    je      L116
    mov     r12,[rsp+108h]
    jmp     L116
L116:
    mov     r8d,[r12]
    mov     r9d,[rbx]
    cmp     r8d,r9d
    setb    r8b
    mov     r9,[rsp+258h]
    mov     edx,edx
    mov     esi,esi
    mov     r13,rsi
    shl     r13,20h
    or      r13,rdx
    lea     r9,[r9+r13*4]
    lea     r11,[image.k5440]
    mov     [rsp+158h],r11
    mov     r14,r9
    and     r14,3
    test    r14,r14
    je      L118
    jmp     L171
L117:
    mov     r14d,[r9]
    mov     [r15],r14d
    lea     r14,[image.k5464]
    mov     rbp,r12
    and     rbp,3
    test    rbp,rbp
    je      L123
    jmp     L172
L118:
    test    r9,r9
    je      L171
    mov     rbp,r15
    and     rbp,3
    test    rbp,rbp
    jne     L171
    test    r15,r15
    je      L171
    jmp     L117
L119:
    mov     r15,r9
    and     r15,3
    test    r15,r15
    jne     L172
    cmp     r12,r9
    jae     L120
    mov     r15,r9
    sub     r15,r12
    jmp     L121
L120:
    mov     r15,r12
    sub     r15,r9
L121:
    cmp     r15,4
    jb      L172
    mov     r15d,[r12]
    mov     [r9],r15d
    movzx   r15d,r8b
    mov     rbp,rsi
    shl     rbp,20h
    or      rbp,rdx
    add     rbp,r15
    mov     r15,rbp
    shr     r15,20h
    mov     r13,r12
    lea     r13,[r13+4]
    movzx   ecx,byte ptr [rsp+26Bh]
    test    cl,cl
    jne     L124
    jmp     L122
L122:
    mov     rdx,rbp
    mov     rsi,r15
    mov     r15,r12
    mov     r12,r13
    jmp     L115
L123:
    test    r12,r12
    je      L172
    jmp     L119
L124:
    cmp     rbp,[rsp+20h]
    jae     L176
    lea     rcx,[rbx+rbp*4]
    lea     rdx,[rsp+27Ch]
    lea     r11,[image.k488]
    mov     [rsp+168h],r11
    mov     r8,rbx
    and     r8,3
    test    r8,r8
    jne     L173
    mov     r8,rdx
    and     r8,3
    test    r8,r8
    je      L128
    jmp     L173
L125:
    cmp     rbx,rdx
    jae     L126
    mov     r8,rdx
    sub     r8,rbx
    jmp     L127
L126:
    mov     r8,rbx
    sub     r8,rdx
L127:
    cmp     r8,4
    jb      L173
    mov     r8d,[rbx]
    mov     [rsp+27Ch],r8d
    lea     r8,[image.k512]
    mov     r9,rcx
    and     r9,3
    test    r9,r9
    je      L130
    jmp     L174
L128:
    test    rdx,rdx
    je      L173
    jmp     L125
L129:
    mov     edx,[rcx]
    mov     [rbx],edx
    lea     rdx,[rsp+27Ch]
    lea     r9,[image.k536]
    mov     r12,rdx
    and     r12,3
    test    r12,r12
    je      L134
    jmp     L175
L130:
    test    rcx,rcx
    je      L174
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    je      L129
    jmp     L174
L131:
    mov     r12,rcx
    and     r12,3
    test    r12,r12
    jne     L175
    cmp     rdx,rcx
    jae     L132
    mov     r12,rcx
    sub     r12,rdx
    jmp     L133
L132:
    mov     r12,rdx
    sub     r12,rcx
L133:
    cmp     r12,4
    jb      L175
    mov     r12d,[rsp+27Ch]
    mov     [rcx],r12d
    jmp     L135
L134:
    test    rdx,rdx
    je      L175
    jmp     L131
L135:
    lea     rdx,[image.k6360]
    mov     r12,rbx
    and     r12,3
    test    r12,r12
    jne     L177
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rbp,r10
    ja      L177
    mov     r12,[rsp+20h]
    sub     r12,rbp
    mov     r13,rcx
    and     r13,3
    test    r13,r13
    jne     L178
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L178
    mov     [rsp+2C8h],rbx
    mov     [rsp+2D0h],rbp
    mov     [rsp+2D8h],rcx
    mov     [rsp+2E0h],r12
    lea     r11,[k11]
    mov     [rsp+170h],r11
    cmp     r12,1
    jb      L181
    lea     r15,[image.k6360]
    mov     rsi,rcx
    and     rsi,3
    test    rsi,rsi
    jne     L179
    mov     r13,rcx
    lea     r13,[r13+4]
    sub     r12,1
    mov     rsi,r13
    and     rsi,3
    test    rsi,rsi
    je      L137
    jmp     L180
L136:
    mov     [rsp+2B8h],rcx
    mov     qword ptr [rsp+2C0h],1
    mov     [rsp+2C8h],r13
    mov     [rsp+2D0h],r12
    mov     [rsp+2D8h],rcx
    mov     qword ptr [rsp+2E0h],1
    mov     [rsp+2D0h],rcx
    mov     rdi,rbx
    mov     rsi,rbp
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+18h]
    call    fn15
    mov     rsi,[rsp+2D0h]
    mov     rbx,r13
    mov     [rsp+20h],r12
    mov     rcx,[rsp+30h]
    mov     [rsp+10h],rsi
    jmp     L0
L137:
    test    r13,r13
    je      L180
    jmp     L136
L138:
    mov     rbx,[rsp+2B0h]
    mov     r12,[rsp+2A8h]
    mov     r13,[rsp+2A0h]
    mov     r14,[rsp+298h]
    mov     r15,[rsp+290h]
    mov     rbp,[rsp+288h]
    add     rsp,388h
    ret
L139:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L141
    jmp     L141
    jmp     L141
L140:
    lea     rcx,[image.k8338]
    lea     rsi,[image.k10496]
    mov     rdi,rcx
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym49
    ud2
L141:
    call    image.sym10
    ud2
L142:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L143:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L144:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L145:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L146:
    lea     rcx,[image.k9125]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L147:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L148:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L149:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L150:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L151:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L152:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L153:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L154:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L155:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+110h]
    movzx   edx,dl
    call    image.sym49
    ud2
L156:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L157:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+118h]
    movzx   edx,dl
    call    image.sym49
    ud2
L158:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L159:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L160:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L161:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L162:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L163:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+128h]
    movzx   edx,dl
    call    image.sym49
    ud2
L164:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L165:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L166:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L167:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+120h]
    movzx   edx,dl
    call    image.sym49
    ud2
L168:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+150h]
    movzx   edx,dl
    call    image.sym49
    ud2
L169:
    lea     rcx,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     r10,rdi
    mov     rdi,rcx
    mov     rcx,r10
    movzx   edx,dl
    call    image.sym49
    ud2
L170:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L171:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+158h]
    movzx   edx,dl
    call    image.sym49
    ud2
L172:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L173:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+168h]
    movzx   edx,dl
    call    image.sym49
    ud2
L174:
    lea     rdi,[image.k8904]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L175:
    lea     rdi,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L176:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L177:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L178:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L179:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L180:
    lea     rdi,[image.k9686]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L181:
    lea     rdi,[image.k6296]
    mov     esi,13h
    mov     rdx,[rsp+170h]
    call    image.sym6
    ud2
L182:
    lea     rcx,[k16]
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+20h]
    call    sym17
    ud2
  ; OSR entries
    lea     r11,[L183]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L183:
    .long   L184
L184:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-3B0h]
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
    mov     r11,[rsp+8]
    mov     [rdx-360h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-368h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-370h],r11
    mov     rbx,[rsp]
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
    lea     rdi,[k0]
    mov     esi,3Dh
    call    sym1
    ud2

fn main::{closure#2}
    mov     eax,[rsi]
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
    mov     [rsp+20h],rsi
    mov     r13,rdx
    mov     r11,[rsp+20h]
    cmp     r11,10h
    ja      L16
    mov     qword ptr [rsp+0F0h],1
    mov     r10,[rsp+20h]
    mov     [rsp+0F8h],r10
    mov     rax,rbx
    mov     rcx,[rsp+20h]
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
    je      L48
L3:
    test    rsi,rsi
    jbe     L0
    lea     rdi,[rsi-1]
    cmp     rdi,rcx
    jae     L65
    lea     rdx,[rax+rdi*4]
    mov     edx,[rdx]
    cmp     rsi,rcx
    jae     L66
    lea     r8,[rax+rsi*4]
    mov     r9d,[r8]
    cmp     r9d,edx
    jae     L0
    lea     rdx,[rsi-1]
    lea     r11,[k10]
    mov     [rsp+28h],r11
    cmp     rdx,rcx
    jae     L52
    lea     r14,[rax+rdx*4]
    lea     r15,[rsp+0BCh]
    lea     r11,[image.k488]
    mov     [rsp+30h],r11
    mov     r12,r14
    and     r12,3
    test    r12,r12
    je      L8
    jmp     L49
L4:
    mov     r12,r15
    and     r12,3
    test    r12,r12
    je      L9
    jmp     L49
L5:
    cmp     r14,r15
    jae     L6
    mov     r12,r15
    sub     r12,r14
    jmp     L7
L6:
    mov     r12,r14
    sub     r12,r15
L7:
    cmp     r12,4
    jb      L49
    mov     r12d,[r14]
    mov     [rsp+0BCh],r12d
    lea     r12,[image.k512]
    mov     r9,r8
    and     r9,3
    test    r9,r9
    je      L11
    jmp     L50
L8:
    test    r14,r14
    je      L49
    jmp     L4
L9:
    test    r15,r15
    je      L49
    jmp     L5
L10:
    mov     r9d,[r8]
    mov     [r14],r9d
    lea     r9,[rsp+0BCh]
    lea     r11,[image.k536]
    mov     [rsp+58h],r11
    mov     rbp,r9
    and     rbp,3
    test    rbp,rbp
    je      L15
    jmp     L51
L11:
    test    r8,r8
    je      L50
    mov     rbp,r14
    and     rbp,3
    test    rbp,rbp
    je      L10
    jmp     L50
L12:
    mov     r14,r8
    and     r14,3
    test    r14,r14
    jne     L51
    cmp     r9,r8
    jae     L13
    mov     r14,r8
    sub     r14,r9
    jmp     L14
L13:
    mov     r14,r9
    sub     r14,r8
L14:
    cmp     r14,4
    jb      L51
    mov     r14d,[rsp+0BCh]
    mov     [r8],r14d
    lea     r14,[rsi-1]
    mov     rsi,r14
    jmp     L3
L15:
    test    r9,r9
    je      L51
    jmp     L12
L16:
    mov     r11,[rsp+20h]
    shr     r11,1
    mov     [rsp+38h],r11
    lea     r11,[k16]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+20h]
    cmp     r11,[rsp+38h]
    jb      L53
    mov     rdi,rbx
    mov     rsi,[rsp+38h]
    mov     rdx,r13
    call    fn18
    mov     r8,[rsp+20h]
    sub     r8,[rsp+38h]
    mov     r10,[rsp+38h]
    lea     r9,[rbx+r10*4]
    mov     rdi,r9
    mov     rsi,r8
    mov     rdx,r13
    call    fn18
    mov     r8,[r13+8]
    mov     r9,[r13+10h]
    mov     qword ptr [r13+10h],0
    mov     rdi,r8
    mov     rsi,r9
    call    image.sym48
    mov     qword ptr [rsp+50h],0
    mov     r11,[rsp+38h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+48h],r11
    mov     r14,rbx
    mov     r11,[rsp+20h]
    mov     [rsp+60h],r11
    mov     rbp,r13
L17:
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+40h]
    jae     L21
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+60h]
    jae     L21
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+60h]
    jae     L67
    mov     r10,[rsp+50h]
    lea     r8,[r14+r10*4]
    mov     ebx,[r8]
    mov     r10,[rsp+48h]
    lea     r8,[r14+r10*4]
    mov     r15d,[r8]
    cmp     r15d,ebx
    jb      L19
    mov     r13,[rbp+10h]
    mov     r8,[rbp]
    cmp     r13,r8
    jne     L18
    mov     rdi,rbp
    call    qword ptr [image.fn160.slot]
L18:
    mov     r8,[rbp+8]
    lea     r8,[r8+r13*4]
    mov     [r8],ebx
    add     r13,1
    mov     [rbp+10h],r13
    mov     [rsp+8],r8
    mov     r8,[rsp+50h]
    add     r8,1
    mov     [rsp+50h],r8
    jmp     L17
L19:
    mov     rbx,[rbp+10h]
    mov     r8,[rbp]
    cmp     rbx,r8
    jne     L20
    mov     rdi,rbp
    call    qword ptr [image.fn160.slot]
L20:
    mov     r8,[rbp+8]
    lea     r8,[r8+rbx*4]
    mov     [r8],r15d
    add     rbx,1
    mov     [rbp+10h],rbx
    mov     [rsp+8],r8
    mov     r8,[rsp+48h]
    add     r8,1
    mov     [rsp+48h],r8
    jmp     L17
L21:
    lea     r11,[k37]
    mov     [rsp+80h],r11
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+50h]
    jb      L54
    mov     r9,[rsp+40h]
    sub     r9,[rsp+50h]
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+40h]
    jb      L54
    mov     r10,[rsp+50h]
    lea     rbx,[r14+r10*4]
    lea     r9,[rbx+r9*4]
    lea     r11,[image.k6656]
    mov     [rsp+70h],r11
    cmp     r9,rbx
    jb      L55
    sub     r9,rbx
    mov     r15,r9
    shr     r15,2
    lea     r11,[image.k6704]
    mov     [rsp+68h],r11
    mov     r9,rbx
    and     r9,3
    test    r9,r9
    je      L23
    jmp     L56
L22:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r15,r10
    ja      L56
    mov     r9,[rbp+10h]
    mov     r13,[rbp]
    sub     r13,r9
    cmp     r13,r15
    jb      L24
    jmp     L25
L23:
    test    rbx,rbx
    je      L56
    jmp     L22
L24:
    mov     rdi,rbp
    mov     rsi,r9
    mov     rdx,r15
    mov     ecx,4
    mov     r8d,4
    call    image.sym47
L25:
    mov     r9,[rbp+10h]
    test    r15,r15
    jbe     L30
    mov     r13,[rbp+8]
    lea     r13,[r13+r9*4]
    lea     r11,[image.k7104]
    mov     [rsp+78h],r11
    mov     r9,rbx
    and     r9,3
    test    r9,r9
    je      L29
    jmp     L57
L26:
    mov     r9,r15
    imul    r9,4
    cmp     rbx,r13
    jae     L27
    mov     r8,r13
    sub     r8,rbx
    jmp     L28
L27:
    mov     r8,rbx
    sub     r8,r13
L28:
    cmp     r9,r8
    ja      L57
    mov     r8,r15
    imul    r8,4
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r8
    call    ryo_hr_Memcpy
    jmp     L30
L29:
    mov     r8,r13
    and     r8,3
    test    r8,r8
    jne     L57
    test    r13,r13
    je      L57
    jmp     L26
L30:
    mov     r8,[rbp+10h]
    add     r8,r15
    mov     [rbp+10h],r8
    lea     r11,[k40]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+48h]
    jb      L58
    mov     rbx,[rsp+60h]
    sub     rbx,[rsp+48h]
    mov     r10,[rsp+48h]
    lea     r13,[r14+r10*4]
    lea     rbx,[r13+rbx*4]
    lea     r11,[image.k6656]
    mov     [rsp+90h],r11
    cmp     rbx,r13
    jb      L59
    sub     rbx,r13
    shr     rbx,2
    lea     r11,[image.k6704]
    mov     [rsp+88h],r11
    mov     r15,r13
    and     r15,3
    test    r15,r15
    je      L32
    jmp     L60
L31:
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rbx,r10
    ja      L60
    mov     r15,[rbp]
    sub     r15,r8
    cmp     r15,rbx
    jb      L33
    jmp     L34
L32:
    test    r13,r13
    je      L60
    jmp     L31
L33:
    mov     rdi,rbp
    mov     rsi,r8
    mov     rdx,rbx
    mov     ecx,4
    mov     r8d,4
    call    image.sym47
L34:
    mov     r8,[rbp+10h]
    test    rbx,rbx
    jbe     L39
    mov     r15,[rbp+8]
    lea     r15,[r15+r8*4]
    lea     r11,[image.k7104]
    mov     [rsp+98h],r11
    mov     r8,r13
    and     r8,3
    test    r8,r8
    je      L38
    jmp     L61
L35:
    mov     r8,rbx
    imul    r8,4
    cmp     r13,r15
    jae     L36
    mov     r9,r15
    sub     r9,r13
    jmp     L37
L36:
    mov     r9,r13
    sub     r9,r15
L37:
    cmp     r8,r9
    ja      L61
    mov     r8,rbx
    imul    r8,4
    mov     rdi,r15
    mov     rsi,r13
    mov     rdx,r8
    call    ryo_hr_Memcpy
    jmp     L39
L38:
    mov     r8,r15
    and     r8,3
    test    r8,r8
    jne     L61
    test    r15,r15
    je      L61
    jmp     L35
L39:
    mov     r8,[rbp+10h]
    add     r8,rbx
    mov     [rbp+10h],r8
    mov     r9,[rbp+8]
    lea     rbx,[k44]
    mov     r11,[rsp+60h]
    cmp     r11,r8
    jne     L64
    lea     r13,[image.k560]
    mov     r11,[rsp+60h]
    cmp     r11,0
    jne     L40
    mov     r15d,1
    jmp     L41
L40:
    mov     r15d,0
L41:
    mov     rbp,r9
    and     rbp,3
    test    rbp,rbp
    je      L46
    jmp     L63
L42:
    mov     rbp,r14
    and     rbp,3
    test    rbp,rbp
    je      L47
    jmp     L63
L43:
    mov     eax,4
    mul     qword ptr [rsp+60h]
    mov     rbp,rax
    jb      L62
    cmp     r9,r14
    jae     L44
    mov     rax,r14
    sub     rax,r9
    jmp     L45
L44:
    mov     rax,r9
    sub     rax,r14
L45:
    cmp     rbp,rax
    ja      L63
    mov     rax,[rsp+60h]
    imul    rax,4
    mov     rdi,r14
    mov     rsi,r9
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L48
L46:
    test    r15b,r15b
    jne     L42
    test    r9,r9
    je      L63
    jmp     L42
L47:
    test    r15b,r15b
    jne     L43
    test    r14,r14
    je      L63
    jmp     L43
L48:
    mov     rbx,[rsp+0E8h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D8h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C8h]
    mov     rbp,[rsp+0C0h]
    add     rsp,178h
    ret
L49:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    image.sym49
    ud2
L50:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L51:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    mov     rdi,rdx
    mov     rsi,rcx
    mov     rdx,[rsp+28h]
    call    sym5
    ud2
L53:
    mov     edi,0
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+0A8h]
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
L54:
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+80h]
    call    image.sym31
    ud2
L55:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L56:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L57:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L58:
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+0A0h]
    call    image.sym31
    ud2
L59:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L61:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L62:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L63:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L64:
    mov     rdi,[rsp+60h]
    mov     rsi,r8
    mov     rdx,rbx
    call    image.sym24
    ud2
L65:
    lea     rdx,[k4]
    mov     rsi,rcx
    call    sym5
    ud2
L66:
    lea     rdx,[k6]
    mov     rdi,rsi
    mov     rsi,rcx
    call    sym5
    ud2
L67:
    lea     rdx,[k23]
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+60h]
    call    sym5
    ud2
  ; OSR entries
    lea     r11,[L68]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L68:
    .long   L69
    .long   L70
    .long   L71
L69:
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
L70:
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
    mov     rsi,[rsp]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    lea     rsp,[rsp+220h]
    jmp     L3
L71:
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
    mov     [rdx-120h],r11
    mov     r11,[rsp+8]
    mov     [rdx-130h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-110h],r11
    mov     r14,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+230h]
    jmp     L17

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    mov     eax,[rdi]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    al
    movzx   eax,al
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    mov     rax,[rdi]
    mov     rcx,[rsi]
    cmp     rax,rcx
    setb    al
    movzx   eax,al
    ret

fn std::hint::assert_unchecked::precondition_check
    sub     rsp,18h
    test    dil,dil
    je      L0
    add     rsp,18h
    ret
L0:
    lea     rdi,[k0]
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    sym2
    ud2

fn std::hint::select_unpredictable::<*mut u32>
    push    rbx
    push    r12
    sub     rsp,68h
    mov     rbx,rdi
    mov     [rsp+40h],rsi
    mov     [rsp+38h],rsi
    mov     [rsp+40h],rdx
    lea     rax,[rsp+38h]
    lea     rcx,[rsp+40h]
    mov     [rsp+48h],rcx
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     [rsp+8],bl
    lea     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+16]
    call    qword ptr [sym0]
    mov     r12,[rsp+48h]
    mov     rdi,[rsp+28h]
    mov     [rsp+58h],rdi
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
    add     rsp,68h
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
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    cmp     rax,rcx
    jae     L0
    lea     rcx,[rax+1]
    mov     [rdi],rcx
    mov     rdx,rax
    mov     eax,1
    jmp     L1
L0:
    mov     eax,0
L1:
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
    lea     rdi,[k0]
    lea     rdx,[k2]
    mov     esi,55h
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
    lea     rdi,[k0]
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
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
L6:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
L7:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L11
L8:
    lea     rdi,[k1]
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
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
L9:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
L10:
    lea     rdi,[image.k9346]
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L14
    jmp     L14
L11:
    lea     rdi,[k3]
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
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6560]
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L8
L6:
    lea     rdi,[k1]
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

