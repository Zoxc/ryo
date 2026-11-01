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
    jmp     L2
L0:
    cmp     rsi,rdi
    jb      L5
    sub     rsi,rdi
    shr     rsi,2
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
L1:
    lea     rdi,[rsp+28h]
    lea     rsi,[rbx+r12*4]
    call    fn1
    mov     r11,r12
    add     r11,1
    jb      L6
    add     r12,1
    cmp     r12,r13
    jne     L4
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+28h]
    mov     [rcx],rax
L2:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+10h]
    add     rsp,58h
    ret
L3:
    mov     rbx,rax
    mov     r12,rcx
    mov     r13,rdx
    jmp     L1
L4:
    mov     rax,rbx
    mov     rcx,r12
    mov     rdx,r13
    jmp     L3
L5:
    lea     rdi,[image.k7575]
    lea     rcx,[k4]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L6:
    lea     rdi,[image.k7776]
    lea     rcx,[k9]
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
    mov     rbx,rax
    jmp     L9
L7:
    lea     rdi,[rsp+28h]
    call    qword ptr [fn0.slot]
    jmp     L10
    jmp     L11
L8:
    mov     [rsp],rbx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L7
L10:
    jmp     L8
L11:
    call    sym11
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
    .long   L23
L13:
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
L14:
    ret
L15:
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+90h]
    jmp     L3
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

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,58h
    mov     [rsp+20h],rbx
    mov     [rsp+18h],r12
    mov     [rsp+10h],r13
    mov     [rsp+28h],rcx
    cmp     rdi,rsi
    jne     L0
    jmp     L2
L0:
    cmp     rsi,rdi
    jb      L5
    sub     rsi,rdi
    shr     rsi,2
    mov     rbx,rdi
    mov     r12d,0
    mov     r13,rsi
L1:
    lea     rdi,[rsp+28h]
    lea     rax,[rbx+r12*4]
    mov     rsi,rdx
    mov     rdx,rax
    call    fn0
    mov     r11,r12
    add     r11,1
    jb      L6
    add     r12,1
    cmp     r12,r13
    jne     L4
    mov     rdx,rax
L2:
    mov     rax,rdx
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+10h]
    add     rsp,58h
    ret
L3:
    mov     rbx,rdx
    mov     rdx,rcx
    mov     r12,rsi
    mov     r13,rdi
    jmp     L1
L4:
    mov     rcx,rax
    mov     rdx,rbx
    mov     rsi,r12
    mov     rdi,r13
    jmp     L3
L5:
    lea     rdi,[image.k7575]
    lea     rcx,[k1]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L6:
    lea     rdi,[image.k7776]
    lea     rcx,[k6]
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
    jmp     L8
L7:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
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
    .long   L14
    .long   L15
    .long   L16
    .long   L17
    .long   L18
L10:
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
    mov     rbx,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+0B0h]
    jmp     L1
L11:
    ret
L12:
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
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+0B0h]
    jmp     L3
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
    sub     rsp,18h
    cmp     rdx,rcx
    jb      L2
    test    rsi,3
    jne     L0
    test    rsi,rsi
    je      L0
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rcx,r10
    ja      L0
    lea     rax,[rsi+rcx*4]
    sub     rdx,rcx
    test    rax,3
    jne     L1
    test    rax,rax
    je      L1
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rdx,r10
    ja      L1
    mov     [rdi],rsi
    mov     [rdi+8],rcx
    mov     [rdi+10h],rax
    mov     [rdi+18h],rdx
    mov     rax,rdi
    add     rsp,18h
    ret
L0:
    lea     rdi,[image.k9694]
    lea     rcx,[k0]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k9694]
    lea     rcx,[k0]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L2:
    lea     rdi,[k2]
    mov     esi,13h
    mov     rdx,r8
    call    sym4
    ud2

fn core::slice::<impl [u32]>::swap
    push    rbx
    sub     rsp,10h
    cmp     rdx,rsi
    jae     L3
    cmp     rcx,rsi
    jae     L4
    lea     rax,[rdi+rdx*4]
    lea     rdi,[rdi+rcx*4]
    test    rax,3
    jne     L0
    test    rax,rax
    je      L0
    mov     r9d,[rax]
    test    rdi,3
    jne     L1
    test    rdi,rdi
    je      L1
    test    rax,3
    jne     L1
    mov     ebx,[rdi]
    mov     [rax],ebx
    test    rdi,3
    jne     L2
    mov     [rdi],r9d
    add     rsp,10h
    pop     rbx
    ret
L0:
    lea     rdi,[image.k8346]
    lea     rax,[image.k496]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k8912]
    lea     rax,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym45
    ud2
L2:
    lea     rdi,[image.k8346]
    lea     rax,[image.k544]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym45
    ud2
L3:
    mov     rdi,rdx
    mov     rdx,r8
    call    sym0
    ud2
L4:
    mov     rdi,rcx
    mov     rdx,r8
    call    sym0
    ud2

fn core::slice::<impl [u32]>::swap_unchecked
    sub     rsp,18h
    cmp     rdx,rsi
    jae     L0
    cmp     rcx,rsi
    jae     L0
    lea     rax,[rdi+rdx*4]
    lea     rdi,[rdi+rcx*4]
    test    rax,3
    jne     L1
    test    rax,rax
    je      L1
    mov     ecx,[rax]
    test    rdi,3
    jne     L2
    test    rdi,rdi
    je      L2
    test    rax,3
    jne     L2
    mov     edx,[rdi]
    mov     [rax],edx
    test    rdi,3
    jne     L3
    mov     [rdi],ecx
    add     rsp,18h
    ret
L0:
    lea     rdi,[image.k7136]
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k496]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L2:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L3:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k544]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
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
    mov     [rsp+10h],rsi
    mov     [rsp+18h],rdx
    mov     r11,[rsp+10h]
    cmp     r11,8
    jb      L11
    mov     rax,[rsp+10h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    lea     r14,[rbx+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    lea     r15,[rbx+rcx*8]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L3
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
    cmp     rcx,rbx
    jb      L8
    sub     rcx,rbx
    shr     rcx,3
    jmp     L7
L3:
    mov     rbp,rax
    shr     rbp,3
    mov     r12,rbp
    imul    r12,4
    lea     rsi,[rbx+r12*8]
    mov     r13,rbp
    imul    r13,7
    lea     rdx,[rbx+r13*8]
    mov     rdi,rbx
    mov     rcx,rbp
    mov     r8,[rsp+18h]
    call    fn1
    mov     [rsp+20h],rax
    lea     rsi,[r14+r12*8]
    lea     rdx,[r14+r13*8]
    mov     rdi,r14
    mov     rcx,rbp
    mov     r8,[rsp+18h]
    call    fn1
    mov     r14,rax
    lea     rsi,[r15+r12*8]
    lea     rdx,[r15+r13*8]
    mov     rdi,r15
    mov     rcx,rbp
    mov     r8,[rsp+18h]
    call    fn1
    mov     r11,[rsp+20h]
    mov     ecx,[r11]
    mov     edx,[r14]
    cmp     ecx,edx
    setb    sil
    mov     edi,[rax]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L5
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L4
    jmp     L6
L4:
    mov     rax,r14
    jmp     L6
L5:
    mov     rax,[rsp+20h]
L6:
    cmp     rax,rbx
    jb      L9
    sub     rax,rbx
    shr     rax,3
    mov     rcx,rax
L7:
    cmp     rcx,[rsp+10h]
    jae     L10
    mov     rax,rcx
    add     rsp,28h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L8:
    lea     rdi,[image.k7575]
    lea     rcx,[k2]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L9:
    lea     rdi,[image.k7575]
    lea     rcx,[k7]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L10:
    lea     rdi,[image.k9133]
    lea     rcx,[k12]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L11:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
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
L13:
    ret
L14:
    ret
L15:
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
    sub     rsp,128h
    mov     [rsp+68h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+58h],r13
    mov     [rsp+50h],r14
    mov     [rsp+48h],r15
    mov     [rsp+40h],rbp
    mov     [rsp+80h],rdi
    mov     rax,rsi
    shr     rax,1
    test    rax,rax
    setne   cl
    mov     [rsp+87h],cl
    lea     rcx,[rdi+rax*4]
    lea     r8,[rax-1]
    mov     [rsp+80h],r8
    lea     r8,[rdi+r8*4]
    lea     r9,[rsi-1]
    lea     rbx,[rdi+r9*4]
    mov     [rsp+80h],rdx
    lea     r9,[rdx+r9*4]
    mov     r12,rsi
    mov     rsi,rdx
    mov     rdx,rcx
    mov     rcx,rax
    mov     eax,0
L0:
    mov     [rsp+78h],rax
    mov     [rsp+70h],rcx
    cmp     rax,rcx
    setb    r13b
    mov     [rsp+87h],r13b
    test    r13b,r13b
    je      L17
    mov     [rsp+78h],rax
    add     rax,1
    mov     [rsp+70h],rax
    mov     r13d,[rdx]
    mov     r14d,[rdi]
    cmp     r13d,r14d
    setb    r13b
    mov     r14,r13
    xor     r14d,1
    cmp     r13b,1
    je      L1
    mov     r15,rdi
    jmp     L2
L1:
    mov     r15,rdx
L2:
    test    r15,3
    jne     L18
    test    r15,r15
    je      L18
    test    rsi,3
    jne     L18
    test    rsi,rsi
    je      L18
    cmp     r15,rsi
    jae     L3
    mov     rbp,rsi
    sub     rbp,r15
    jmp     L4
L3:
    mov     rbp,r15
    sub     rbp,rsi
L4:
    cmp     rbp,4
    jb      L18
    mov     r15d,[r15]
    mov     [rsi],r15d
    movzx   r13d,r13b
    lea     r13,[rdx+r13*4]
    movzx   r14d,r14b
    lea     r14,[rdi+r14*4]
    mov     r15,rsi
    lea     r15,[r15+4]
    mov     [rsp+70h],r14
    mov     [rsp+78h],r13
    mov     [rsp+80h],r15
    mov     [rsp+10h],rax
    mov     rax,r8
    mov     [rsp+18h],rcx
    mov     rcx,rbx
    mov     [rsp+20h],r12
L5:
    mov     r11,[rsp+70h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+38h],r11
    mov     r15d,[rcx]
    mov     ebp,[rax]
    cmp     r15d,ebp
    setb    r15b
    mov     rbp,r15
    xor     ebp,1
    cmp     r15b,1
    je      L6
    mov     r13,rcx
    jmp     L7
L6:
    mov     r13,rax
L7:
    test    r13,3
    jne     L19
    test    r13,r13
    je      L19
    test    r9,3
    jne     L19
    test    r9,r9
    je      L19
    cmp     r13,r9
    jae     L8
    mov     r14,r9
    sub     r14,r13
    jmp     L9
L8:
    mov     r14,r13
    sub     r14,r9
L9:
    cmp     r14,4
    jb      L19
    mov     r13d,[r13]
    mov     [r9],r13d
    movzx   ebp,bpl
    mov     r13d,0
    sub     r13,rbp
    lea     rcx,[rcx+r13*4]
    movzx   r15d,r15b
    mov     r13d,0
    sub     r13,r15
    lea     rax,[rax+r13*4]
    lea     r9,[r9-4]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rcx
    mov     [rsp+80h],r9
    mov     r8,rax
    mov     rax,[rsp+10h]
    mov     rdi,[rsp+28h]
    mov     rdx,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rbx,rcx
    mov     rcx,[rsp+18h]
    mov     r12,[rsp+20h]
    jmp     L0
L10:
    mov     rcx,rdi
    mov     r9,rdx
    jmp     L16
L11:
    cmp     rdi,rax
    setb    cl
    mov     [rsp+76h],cl
    test    cl,cl
    je      L12
    mov     rcx,rdi
    jmp     L13
L12:
    mov     rcx,rdx
L13:
    test    rcx,3
    jne     L20
    test    rcx,rcx
    je      L20
    test    rsi,3
    jne     L20
    test    rsi,rsi
    je      L20
    cmp     rcx,rsi
    jae     L14
    mov     r9,rsi
    sub     r9,rcx
    jmp     L15
L14:
    mov     r9,rcx
    sub     r9,rsi
L15:
    cmp     r9,4
    jb      L20
    mov     ecx,[rcx]
    mov     [rsi],ecx
    movzx   ecx,byte ptr [rsp+76h]
    mov     r9,rcx
    lea     r9,[rdi+r9*4]
    xor     ecx,1
    mov     [rsp+75h],cl
    movzx   ecx,cl
    lea     rcx,[rdx+rcx*4]
    mov     r10,rcx
    mov     rcx,r9
    mov     r9,r10
L16:
    mov     r13,[rsp+80h]
    cmp     rcx,r13
    jne     L21
    mov     rcx,[rsp+78h]
    cmp     r9,rcx
    jne     L21
    mov     rbx,[rsp+68h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+58h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+48h]
    mov     rbp,[rsp+40h]
    add     rsp,128h
    ret
L17:
    mov     rax,r8
    lea     rax,[rax+4]
    mov     [rsp+80h],rax
    lea     rbx,[rbx+4]
    mov     [rsp+78h],rbx
    and     r12,1
    test    r12,r12
    sete    cl
    mov     [rsp+77h],cl
    test    cl,cl
    jne     L10
    jmp     L11
L18:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2712]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L19:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1680]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L20:
    lea     rdi,[image.k8346]
    lea     rcx,[k5]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L21:
    call    sym1
    ud2
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
L23:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-170h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+28h]
    mov     rbx,[rsp+30h]
    mov     r9,[rsp+38h]
    mov     r12,[rsp+40h]
    mov     rdx,[rsp+20h]
    lea     rsp,[rsp+50h]
    jmp     L0
L24:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-150h]
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
    mov     [rdx-110h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-100h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r9,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L5
L25:
    ret
L26:
    ret
L27:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,68h
    mov     [rsp+10h],rbx
    mov     [rsp+8],r12
    mov     rax,rsi
    lea     rax,[rax-4]
    mov     ecx,[rsi]
    mov     edx,[rsi-4]
    cmp     ecx,edx
    setb    cl
    mov     [rsp+1Fh],cl
    test    cl,cl
    je      L10
    mov     ecx,[rsi]
    mov     [rsp+1Ch],ecx
    lea     rcx,[rsp+1Ch]
L0:
    test    rax,3
    jne     L12
    test    rax,rax
    je      L12
    test    rsi,3
    jne     L12
    test    rsi,rsi
    je      L12
    cmp     rax,rsi
    jae     L1
    mov     rdx,rsi
    sub     rdx,rax
    jmp     L2
L1:
    mov     rdx,rax
    sub     rdx,rsi
L2:
    cmp     rdx,4
    jb      L12
    mov     edx,[rax]
    mov     [rsi],edx
    cmp     rax,rdi
    jne     L11
    mov     rdx,rcx
    mov     rsi,rax
    jmp     L7
L3:
    mov     r9,rdx
    lea     r9,[r9-4]
L4:
    mov     ebx,[rsp+1Ch]
    mov     r12d,[r9]
    cmp     ebx,r12d
    setb    bl
L5:
    test    bl,bl
    jne     L6
    mov     rsi,rdx
    mov     rdx,r8
    jmp     L7
L6:
    mov     rax,r9
    mov     rdi,rsi
    mov     rsi,rdx
    mov     rcx,r8
    jmp     L0
L7:
    test    rdx,3
    jne     L13
    test    rdx,rdx
    je      L13
    test    rsi,3
    jne     L13
    test    rsi,rsi
    je      L13
    cmp     rdx,rsi
    jae     L8
    mov     r8,rsi
    sub     r8,rdx
    jmp     L9
L8:
    mov     r8,rdx
    sub     r8,rsi
L9:
    mov     r11d,4
    cmp     r11,r8
    ja      L13
    mov     edx,[rdx]
    mov     [rsi],edx
L10:
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+8]
    add     rsp,68h
    ret
L11:
    mov     rdx,rax
    mov     rsi,rdi
    mov     r8,rcx
    jmp     L3
L12:
    lea     rdi,[image.k8346]
    lea     rcx,[k3]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L13:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k10504]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
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
L15:
    ret
L16:
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
    mov     rax,[rsp]
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rcx,[rsp+18h]
    lea     rsp,[rsp+60h]
    jmp     L0
L17:
    ret
L18:
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
    mov     rsi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+60h]
    jmp     L3
L19:
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
    mov     rbx,[rsp]
    mov     r9,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     r8,[rsp+20h]
    mov     rdx,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L5
L20:
    ret
L21:
    ret
L22:
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
    mov     r9,[rsp]
    mov     rsi,[rsp+8]
    mov     r8,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L4
L23:
    ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,18h
    test    rdx,rdx
    je      L9
    cmp     rsi,rdx
    jb      L9
    lea     rax,[rdi+rsi*4]
    lea     rcx,[rdi+rdx*4]
L0:
    cmp     rcx,rax
    je      L6
    mov     rdx,rcx
    lea     rdx,[rdx-4]
    mov     esi,[rcx]
    mov     r8d,[rcx-4]
    cmp     esi,r8d
    setb    sil
    mov     [rsp+0Fh],sil
    test    sil,sil
    je      L5
    mov     esi,[rcx]
    mov     [rsp+0Ch],esi
    mov     rsi,rcx
L1:
    test    rdx,3
    jne     L7
    test    rdx,rdx
    je      L7
    test    rsi,3
    jne     L7
    test    rsi,rsi
    je      L7
    cmp     rdx,rsi
    jae     L2
    mov     r8,rsi
    sub     r8,rdx
    jmp     L3
L2:
    mov     r8,rdx
    sub     r8,rsi
L3:
    cmp     r8,4
    jb      L7
    mov     r8d,[rdx]
    mov     [rsi],r8d
    cmp     rdx,rdi
    je      L4
    mov     rsi,rdx
    lea     rsi,[rsi-4]
    mov     r8d,[rsp+0Ch]
    mov     r9d,[rdx-4]
    cmp     r8d,r9d
    jae     L4
    mov     r10,rdx
    mov     rdx,rsi
    mov     rsi,r10
    jmp     L1
L4:
    test    rdx,3
    jne     L8
    mov     esi,[rsp+0Ch]
    mov     [rdx],esi
L5:
    lea     rcx,[rcx+4]
    jmp     L0
L6:
    add     rsp,18h
    ret
L7:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1728]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L8:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k10504]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L9:
    lea     rdi,[rsp+10h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L10]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L10:
    .long   L11
L11:
    pop     rcx
    lea     rdx,[rsp+60h]
    lea     rsp,[rdx-80h]
    mov     r11,[rdx-28h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     rcx,[rsp]
    mov     rax,[rsp+8]
    mov     rdi,[rsp+10h]
    lea     rsp,[rsp+70h]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    sub     rsp,10h
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
    test    r9,3
    jne     L4
    test    r9,r9
    je      L4
    test    rcx,3
    jne     L4
    test    rcx,rcx
    je      L4
    cmp     r9,rcx
    jae     L2
    mov     rbx,rcx
    sub     rbx,r9
    jmp     L3
L2:
    mov     rbx,r9
    sub     rbx,rcx
L3:
    cmp     rbx,4
    jb      L4
    mov     r9d,[r9]
    mov     [rcx],r9d
    movzx   r8d,r8b
    mov     r11d,0
    sub     r11,r8
    mov     r8,r11
    lea     rdx,[rdx+r8*4]
    movzx   eax,al
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    lea     rsi,[rsi+rax*4]
    lea     rcx,[rcx-4]
    mov     [rdi],rsi
    mov     [rdi+8],rdx
    mov     [rdi+10h],rcx
    mov     rax,rdi
    add     rsp,10h
    pop     rbx
    ret
L4:
    lea     rdi,[image.k8346]
    lea     rcx,[k1]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
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

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    sub     rsp,10h
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
    test    r9,3
    jne     L4
    test    r9,r9
    je      L4
    test    rcx,3
    jne     L4
    test    rcx,rcx
    je      L4
    cmp     r9,rcx
    jae     L2
    mov     rbx,rcx
    sub     rbx,r9
    jmp     L3
L2:
    mov     rbx,r9
    sub     rbx,rcx
L3:
    cmp     rbx,4
    jb      L4
    mov     r9d,[r9]
    mov     [rcx],r9d
    movzx   eax,al
    lea     rdx,[rdx+rax*4]
    movzx   r8d,r8b
    lea     rsi,[rsi+r8*4]
    lea     rcx,[rcx+4]
    mov     [rdi],rsi
    mov     [rdi+8],rdx
    mov     [rdi+10h],rcx
    mov     rax,rdi
    add     rsp,10h
    pop     rbx
    ret
L4:
    lea     rdi,[image.k8346]
    lea     rcx,[k1]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,438h
    mov     [rsp+318h],rbx
    mov     [rsp+310h],r12
    mov     [rsp+308h],r13
    mov     [rsp+300h],r14
    mov     [rsp+2F8h],r15
    mov     [rsp+2F0h],rbp
    mov     [rsp+48h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+30h],r8
    mov     r11,[rsp+38h]
    cmp     r11,2
    jb      L18
    mov     rax,[rsp+38h]
    add     rax,10h
    cmp     rcx,rax
    jb      L37
    mov     r11,[rsp+38h]
    shr     r11,1
    mov     [rsp+40h],r11
    mov     r11,[rsp+38h]
    cmp     r11,10h
    jb      L0
    mov     r11,[rsp+50h]
    mov     r10,[rsp+38h]
    lea     rdx,[r11+r10*8]
    mov     [rsp+2E0h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rcx,[rsp+30h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+48h]
    mov     r10,[rsp+40h]
    lea     rdi,[r11+r10*8]
    mov     [rsp+2E0h],rdi
    mov     r11,[rsp+50h]
    mov     r10,[rsp+40h]
    lea     rsi,[r11+r10*8]
    mov     [rsp+2D8h],rsi
    mov     rax,[rsp+38h]
    add     rax,8
    mov     [rsp+338h],rax
    mov     r11,[rsp+50h]
    lea     rdx,[r11+rax*8]
    mov     rcx,[rsp+30h]
    call    qword ptr [fn0.slot]
    mov     eax,8
    jmp     L14
L0:
    mov     r11,[rsp+38h]
    cmp     r11,8
    jb      L9
    mov     r10,[rsp+48h]
    mov     [rsp+2E0h],r10
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+30h]
    call    qword ptr [fn2.slot]
    mov     r11,[rsp+48h]
    mov     r10,[rsp+40h]
    lea     rax,[r11+r10*8]
    mov     [rsp+2D8h],rax
    mov     [rsp+2E0h],rax
    mov     r11,[rsp+50h]
    mov     r10,[rsp+40h]
    lea     rbp,[r11+r10*8]
    mov     [rsp+2D8h],rbp
    mov     ecx,[rax+8]
    mov     edx,[rax]
    cmp     ecx,edx
    setb    cl
    mov     edx,[rax+18h]
    mov     esi,[rax+10h]
    cmp     edx,esi
    setb    dl
    movzx   esi,cl
    lea     r14,[rax+rsi*8]
    xor     ecx,1
    movzx   ecx,cl
    lea     r12,[rax+rcx*8]
    movzx   ecx,dl
    add     rcx,2
    lea     r15,[rax+rcx*8]
    xor     edx,1
    movzx   edx,dl
    add     rdx,2
    lea     r11,[rax+rdx*8]
    mov     [rsp+58h],r11
    mov     eax,[r15]
    mov     ecx,[r14]
    cmp     eax,ecx
    setb    r13b
    mov     r11,[rsp+58h]
    mov     eax,[r11]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    bl
    mov     [rsp+0F0h],r15
    mov     [rsp+0E8h],r15
    mov     [rsp+0F0h],r14
    lea     rax,[rsp+0E8h]
    lea     rcx,[rsp+0F0h]
    mov     [rsp+0F8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym15]
    mov     [rsp+8],r13b
    lea     rax,[rsp+0F0h]
    mov     [rsp],rax
    lea     rax,[rsp+0E8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+0F8h]
    mov     [rsp+108h],rax
    mov     rax,[rsp+0E8h]
    mov     rcx,[rsp+0F0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+108h]
    mov     [rsp+60h],r11
    mov     [rsp+130h],r12
    mov     [rsp+128h],r12
    mov     r10,[rsp+58h]
    mov     [rsp+130h],r10
    lea     rax,[rsp+128h]
    lea     rcx,[rsp+130h]
    mov     [rsp+138h],rcx
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym15]
    mov     [rsp+8],bl
    lea     rax,[rsp+130h]
    mov     [rsp],rax
    lea     rax,[rsp+128h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+138h]
    mov     [rsp+148h],rax
    mov     rax,[rsp+128h]
    mov     rcx,[rsp+130h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym16]
    mov     r11,[rsp+148h]
    mov     [rsp+68h],r11
    mov     [rsp+170h],r15
    mov     [rsp+168h],r15
    mov     [rsp+170h],r12
    lea     rax,[rsp+168h]
    lea     rcx,[rsp+170h]
    mov     [rsp+178h],rcx
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym15]
    mov     [rsp+8],bl
    lea     rax,[rsp+170h]
    mov     [rsp],rax
    lea     rax,[rsp+168h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+178h]
    mov     [rsp+188h],rax
    mov     rax,[rsp+168h]
    mov     rcx,[rsp+170h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+188h]
    mov     [rsp+1B0h],r14
    mov     [rsp+1A8h],r14
    mov     [rsp+1B0h],rax
    lea     rax,[rsp+1A8h]
    lea     rcx,[rsp+1B0h]
    mov     [rsp+1B8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym15]
    mov     [rsp+8],r13b
    lea     rax,[rsp+1B0h]
    mov     [rsp],rax
    lea     rax,[rsp+1A8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+1B8h]
    mov     [rsp+1C8h],rax
    mov     rax,[rsp+1A8h]
    mov     rcx,[rsp+1B0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym16]
    mov     r14,[rsp+1C8h]
    mov     [rsp+1F0h],r12
    mov     [rsp+1E8h],r12
    mov     [rsp+1F0h],r15
    lea     rax,[rsp+1E8h]
    lea     rcx,[rsp+1F0h]
    mov     [rsp+1F8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym15]
    mov     [rsp+8],r13b
    lea     rax,[rsp+1F0h]
    mov     [rsp],rax
    lea     rax,[rsp+1E8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+1F8h]
    mov     [rsp+208h],rax
    mov     rax,[rsp+1E8h]
    mov     rcx,[rsp+1F0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+208h]
    mov     r10,[rsp+58h]
    mov     [rsp+230h],r10
    mov     r10,[rsp+58h]
    mov     [rsp+228h],r10
    mov     [rsp+230h],rax
    lea     rax,[rsp+228h]
    lea     rcx,[rsp+230h]
    mov     [rsp+238h],rcx
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym15]
    mov     [rsp+8],bl
    lea     rax,[rsp+230h]
    mov     [rsp],rax
    lea     rax,[rsp+228h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+238h]
    mov     [rsp+248h],rax
    mov     rax,[rsp+228h]
    mov     rcx,[rsp+230h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym16]
    mov     rbx,[rsp+248h]
    mov     eax,[rbx]
    mov     ecx,[r14]
    cmp     eax,ecx
    setb    r12b
    mov     [rsp+270h],rbx
    mov     [rsp+268h],rbx
    mov     [rsp+270h],r14
    lea     rax,[rsp+268h]
    lea     rcx,[rsp+270h]
    mov     [rsp+278h],rcx
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym15]
    mov     [rsp+8],r12b
    lea     rax,[rsp+270h]
    mov     [rsp],rax
    lea     rax,[rsp+268h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+278h]
    mov     [rsp+288h],rax
    mov     rax,[rsp+268h]
    mov     rcx,[rsp+270h]
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym16]
    mov     r13,[rsp+288h]
    mov     [rsp+2B0h],r14
    mov     [rsp+2A8h],r14
    mov     [rsp+2B0h],rbx
    lea     rax,[rsp+2A8h]
    lea     rcx,[rsp+2B0h]
    mov     [rsp+2B8h],rcx
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym15]
    mov     [rsp+8],r12b
    lea     rax,[rsp+2B0h]
    mov     [rsp],rax
    lea     rax,[rsp+2A8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym15]
    mov     rax,[rsp+2B8h]
    mov     [rsp+2C8h],rax
    mov     rax,[rsp+2A8h]
    mov     rcx,[rsp+2B0h]
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym17]
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym16]
    mov     rax,[rsp+2C8h]
    test    qword ptr [rsp+60h],3
    jne     L27
    mov     r11,[rsp+60h]
    cmp     r11,0
    je      L27
    test    rbp,3
    jne     L27
    test    rbp,rbp
    je      L27
    mov     r11,[rsp+60h]
    cmp     r11,rbp
    jae     L1
    mov     rcx,rbp
    sub     rcx,[rsp+60h]
    jmp     L2
L1:
    mov     rcx,[rsp+60h]
    sub     rcx,rbp
L2:
    cmp     rcx,8
    jb      L27
    mov     r11,[rsp+60h]
    mov     ecx,[r11]
    mov     r11,[rsp+60h]
    mov     edx,[r11+4]
    mov     [rbp],ecx
    mov     [rbp+4],edx
    mov     rcx,rbp
    lea     rcx,[rcx+8]
    test    r13,3
    jne     L28
    test    r13,r13
    je      L28
    test    rcx,3
    jne     L28
    test    rcx,rcx
    je      L28
    cmp     r13,rcx
    jae     L3
    mov     rdx,rcx
    sub     rdx,r13
    jmp     L4
L3:
    mov     r11,r13
    sub     r11,rcx
    mov     rcx,r11
    mov     rdx,rcx
L4:
    cmp     rdx,8
    jb      L28
    mov     ecx,[r13]
    mov     edx,[r13+4]
    mov     [rbp+8],ecx
    mov     [rbp+0Ch],edx
    mov     rcx,rbp
    lea     rcx,[rcx+10h]
    test    rax,3
    jne     L29
    test    rax,rax
    je      L29
    test    rcx,3
    jne     L29
    test    rcx,rcx
    je      L29
    cmp     rax,rcx
    jae     L5
    mov     rdx,rcx
    sub     rdx,rax
    jmp     L6
L5:
    mov     r11,rax
    sub     r11,rcx
    mov     rcx,r11
    mov     rdx,rcx
L6:
    cmp     rdx,8
    jb      L29
    mov     ecx,[rax]
    mov     eax,[rax+4]
    mov     [rbp+10h],ecx
    mov     [rbp+14h],eax
    mov     rax,rbp
    lea     rax,[rax+18h]
    test    qword ptr [rsp+68h],3
    jne     L30
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L30
    test    rax,3
    jne     L30
    test    rax,rax
    je      L30
    mov     r11,[rsp+68h]
    cmp     r11,rax
    jae     L7
    mov     rcx,rax
    sub     rcx,[rsp+68h]
    jmp     L8
L7:
    mov     r11,[rsp+68h]
    sub     r11,rax
    mov     rax,r11
    mov     rcx,rax
L8:
    cmp     rcx,8
    jb      L30
    mov     r11,[rsp+68h]
    mov     eax,[r11]
    mov     r11,[rsp+68h]
    mov     ecx,[r11+4]
    mov     [rbp+18h],eax
    mov     [rbp+1Ch],ecx
    mov     eax,4
    jmp     L14
L9:
    mov     r10,[rsp+48h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+2D8h],r10
    test    qword ptr [rsp+48h],3
    jne     L31
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L31
    test    qword ptr [rsp+50h],3
    jne     L31
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L31
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+50h]
    jae     L10
    mov     rax,[rsp+50h]
    sub     rax,[rsp+48h]
    jmp     L11
L10:
    mov     rax,[rsp+48h]
    sub     rax,[rsp+50h]
L11:
    cmp     rax,8
    jb      L31
    mov     rax,[rsp+2E0h]
    mov     ecx,[rax]
    mov     eax,[rax+4]
    mov     r11,[rsp+50h]
    mov     [r11],ecx
    mov     r11,[rsp+50h]
    mov     [r11+4],eax
    mov     r11,[rsp+48h]
    mov     r10,[rsp+40h]
    lea     rax,[r11+r10*8]
    mov     [rsp+2E0h],rax
    mov     r11,[rsp+50h]
    mov     r10,[rsp+40h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+2D8h],rcx
    mov     [rsp+338h],rcx
    test    rax,3
    jne     L32
    test    rax,rax
    je      L32
    test    rcx,3
    jne     L32
    test    rcx,rcx
    je      L32
    cmp     rax,rcx
    jae     L12
    mov     rdx,rcx
    sub     rdx,rax
    jmp     L13
L12:
    sub     rax,rcx
    mov     rdx,rax
L13:
    cmp     rdx,8
    jb      L32
    mov     rax,[rsp+2E0h]
    mov     ecx,[rax]
    mov     eax,[rax+4]
    mov     rdx,[rsp+2D8h]
    mov     [rdx],ecx
    mov     [rdx+4],eax
    mov     eax,1
L14:
    mov     qword ptr [rsp+330h],0
    mov     r10,[rsp+40h]
    mov     [rsp+338h],r10
    mov     qword ptr [rsp+320h],0
    mov     r10,[rsp+40h]
    mov     [rsp+328h],r10
    mov     qword ptr [rsp+2D8h],2
    mov     qword ptr [rsp+2E0h],0
    mov     r10,[rsp+40h]
    mov     [rsp+2E8h],r10
    mov     qword ptr [rsp+320h],0
    mov     qword ptr [rsp+328h],2
    mov     qword ptr [rsp+330h],0
    mov     r10,[rsp+40h]
    mov     [rsp+338h],r10
    mov     r11,[rsp+50h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+78h],r11
    mov     [rsp+80h],rax
    mov     r11,[rsp+30h]
    mov     [rsp+88h],r11
L15:
    mov     rax,[rsp+328h]
    mov     r15,[rsp+320h]
    sub     rax,r15
    test    rax,rax
    jbe     L16
    mov     r11,r15
    add     r11,1
    jb      L33
    lea     rax,[r15+1]
    mov     [rsp+320h],rax
    cmp     r15,2
    jae     L34
    lea     rdi,[rsp+430h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym43]
    lea     rax,[rsp+330h]
    mov     rax,[rax+r15*8]
    mov     [rsp+90h],rax
    mov     eax,1
    jmp     L17
L16:
    mov     eax,0
L17:
    test    rax,rax
    jne     L25
    mov     r10,[rsp+0A8h]
    mov     [rsp+2D8h],r10
    mov     r10,[rsp+98h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+0A0h]
    mov     [rsp+2E8h],r10
    mov     r10,[rsp+0A8h]
    mov     [rsp+330h],r10
    mov     r10,[rsp+0A0h]
    mov     [rsp+328h],r10
    mov     r10,[rsp+0A8h]
    mov     [rsp+320h],r10
    test    qword ptr [rsp+0A8h],3
    jne     L35
    mov     r11,[rsp+0A8h]
    cmp     r11,0
    je      L35
    mov     r11,[rsp+0A0h]
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L35
    mov     r10,[rsp+0A0h]
    mov     [rsp+320h],r10
    mov     r10,[rsp+0A8h]
    mov     [rsp+338h],r10
    mov     r10,[rsp+98h]
    mov     [rsp+330h],r10
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+88h]
    call    qword ptr [fn20.slot]
    mov     rax,[rsp+2E0h]
    mov     [rsp+338h],rax
    mov     rax,[rsp+2E8h]
    mov     [rsp+330h],rax
L18:
    mov     rbx,[rsp+318h]
    mov     r12,[rsp+310h]
    mov     r13,[rsp+308h]
    mov     r14,[rsp+300h]
    mov     r15,[rsp+2F8h]
    mov     rbp,[rsp+2F0h]
    add     rsp,438h
    ret
L19:
    lea     r14,[rdx+rax*8]
    lea     rcx,[rsi+rax*8]
    test    rax,rax
    je      L20
    mov     rax,r8
    sub     rax,rdi
    mov     [rsp+0B8h],r15
    mov     [rsp+0C0h],rdx
    mov     [rsp+0C8h],r8
    mov     [rsp+0D0h],rsi
    mov     rbx,rdi
    mov     [rsp+0B0h],r9
    mov     r15,r14
    mov     r14,rax
    mov     r12,rbp
    mov     rbp,rcx
    jmp     L21
L20:
    mov     [rsp+0B8h],r15
    mov     [rsp+0C0h],rdx
    mov     [rsp+0C8h],r8
    mov     [rsp+0D0h],rsi
    mov     rbx,rdi
    mov     [rsp+0B0h],r9
    mov     r15,r14
    mov     r14,rdi
    mov     r12,rbp
    mov     rbp,rcx
L21:
    cmp     r9,r14
    jae     L26
    lea     r13,[r9+1]
    lea     rax,[r15+r9*8]
    lea     rsi,[rbp+r9*8]
    test    rax,3
    jne     L36
    test    rax,rax
    je      L36
    test    rsi,3
    jne     L36
    test    rsi,rsi
    je      L36
    cmp     rax,rsi
    jae     L22
    mov     rcx,rsi
    sub     rcx,rax
    jmp     L23
L22:
    mov     rcx,rax
    sub     rcx,rsi
L23:
    cmp     rcx,8
    jb      L36
    mov     ecx,[rax]
    mov     eax,[rax+4]
    mov     [rsi],ecx
    mov     [rsi+4],eax
    mov     rdi,rbp
    mov     rdx,r12
    call    qword ptr [fn17.slot]
    mov     rax,[rsp+0B8h]
    mov     rcx,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     rsi,[rsp+0D0h]
    mov     rdi,rbx
    mov     r8,[rsp+0B0h]
    mov     r9,r12
L24:
    mov     [rsp+0B8h],rax
    mov     [rsp+0C0h],rcx
    mov     [rsp+0C8h],rdx
    mov     [rsp+0D0h],rsi
    mov     rbx,rdi
    mov     [rsp+0B0h],r8
    mov     r12,r9
    mov     r9,r13
    jmp     L21
L25:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    mov     rsi,[rsp+70h]
    mov     rdi,[rsp+78h]
    mov     r8,[rsp+0A0h]
    mov     r9,[rsp+80h]
    mov     r15,[rsp+0A8h]
    mov     rbp,[rsp+88h]
    jmp     L19
L26:
    mov     r11,[rsp+0B8h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+98h],r11
    mov     r11,[rsp+0C8h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+0D0h]
    mov     [rsp+70h],r11
    mov     [rsp+78h],rbx
    mov     r11,[rsp+0B0h]
    mov     [rsp+80h],r11
    mov     [rsp+88h],r12
    jmp     L15
L27:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1752]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L28:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1776]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L29:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1800]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L30:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1824]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L31:
    lea     rdi,[image.k8346]
    lea     rcx,[k9]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L32:
    lea     rdi,[image.k8346]
    lea     rcx,[k11]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L33:
    lea     rdi,[image.k7776]
    lea     rcx,[image.k6864]
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L34:
    lea     rdi,[image.k9977]
    lea     rcx,[image.k6976]
    mov     esi,1ADh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L35:
    lea     rdi,[image.k9415]
    lea     rcx,[k18]
    mov     esi,22Fh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L36:
    lea     rdi,[image.k8346]
    lea     rcx,[k15]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L37:
    lea     rdi,[rsp+430h]
    call    ryo_h_Abort
    ud2
L38:
    mov     rcx,rax
L39:
    mov     [rsp+20h],rcx
    lea     rdi,[rsp+430h]
    mov     esi,0FFFFFBF0h
    call    ryo_h_Resume
    ud2
L40:
    lea     rdi,[rsp+2D8h]
    call    qword ptr [image.fn228.slot]
    mov     rcx,rbx
    jmp     L39
    jmp     L41
    jmp     L38
    mov     rbx,rax
    jmp     L40
L41:
    call    sym21
    ud2
  ; OSR entries
    lea     r11,[L42]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L42:
    .long   L43
    .long   L44
    .long   L45
    .long   L46
    .long   L47
    .long   L48
    .long   L49
    .long   L50
    .long   L51
    .long   L52
    .long   L53
L43:
    ret
L44:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-480h]
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
    mov     [rdx-388h],r11
    mov     r11,[rsp+8]
    mov     [rdx-398h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-390h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-3C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-3B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-3B0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3A8h],r11
    lea     rsp,[rsp+50h]
    jmp     L15
L45:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-490h]
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
    mov     rax,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+38h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+60h]
    jmp     L19
L46:
    ret
L47:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-4A0h]
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
    mov     r11,[rsp+10h]
    mov     [rdx-378h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-370h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-368h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-360h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-380h],r11
    mov     r9,[rsp]
    mov     r14,[rsp+8]
    mov     rbx,[rsp+30h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+48h]
    mov     r12,[rsp+50h]
    lea     rsp,[rsp+70h]
    jmp     L21
L48:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-4A0h]
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
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rsi,[rsp+28h]
    mov     rdi,[rsp+30h]
    mov     r8,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+48h]
    mov     r9,[rsp+50h]
    mov     rdx,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L24
L49:
    ret
L50:
    ret
L51:
    ret
L52:
    ret
L53:
    ret

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
    push    r15
    push    rbp
    sub     rsp,338h
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,0Dh
    jb      L12
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
    mov     r13,rbx
    lea     r13,[r13+4]
    mov     r14,rbx
    lea     r14,[r14+8]
    mov     eax,[rbx+8]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+50h],r14
    mov     [rsp+48h],r14
    mov     [rsp+50h],r13
    lea     rax,[rsp+48h]
    lea     rcx,[rsp+50h]
    mov     [rsp+58h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+50h]
    mov     [rsp],rax
    lea     rax,[rsp+48h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+58h]
    mov     [rsp+68h],rax
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+68h]
    mov     [rsp+90h],r13
    mov     [rsp+88h],r13
    mov     [rsp+90h],r14
    lea     rax,[rsp+88h]
    lea     rcx,[rsp+90h]
    mov     [rsp+98h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+90h]
    mov     [rsp],rax
    lea     rax,[rsp+88h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+98h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+0A8h]
    mov     eax,[rax]
    test    rbp,3
    jne     L0
    test    rbp,rbp
    je      L0
    test    r13,3
    jne     L0
    test    r13,r13
    je      L0
    mov     ecx,[rbp]
    mov     [rbx+4],ecx
    test    r14,3
    jne     L1
    test    r14,r14
    je      L1
    mov     [rbx+8],eax
    mov     r13,rbx
    lea     r13,[r13+0Ch]
    mov     r11,rbx
    lea     r11,[r11+18h]
    mov     [rsp+30h],r11
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    r15b
    mov     r10,[rsp+30h]
    mov     [rsp+0D0h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+0C8h],r10
    mov     [rsp+0D0h],r13
    lea     rax,[rsp+0C8h]
    lea     rcx,[rsp+0D0h]
    mov     [rsp+0D8h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+0D0h]
    mov     [rsp],rax
    lea     rax,[rsp+0C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+0D8h]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0C8h]
    mov     rcx,[rsp+0D0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+0E8h]
    mov     [rsp+110h],r13
    mov     [rsp+108h],r13
    mov     r10,[rsp+30h]
    mov     [rsp+110h],r10
    lea     rax,[rsp+108h]
    lea     rcx,[rsp+110h]
    mov     [rsp+118h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+110h]
    mov     [rsp],rax
    lea     rax,[rsp+108h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+118h]
    mov     [rsp+128h],rax
    mov     rax,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+128h]
    mov     eax,[rax]
    test    rbp,3
    jne     L2
    test    rbp,rbp
    je      L2
    test    r13,3
    jne     L2
    test    r13,r13
    je      L2
    mov     ecx,[rbp]
    mov     [rbx+0Ch],ecx
    test    qword ptr [rsp+30h],3
    jne     L3
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L3
    mov     [rbx+18h],eax
    mov     r13,rbx
    lea     r13,[r13+1Ch]
    mov     r15,rbx
    lea     r15,[r15+20h]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+1Ch]
    cmp     eax,ecx
    setb    bpl
    mov     [rsp+150h],r15
    mov     [rsp+148h],r15
    mov     [rsp+150h],r13
    lea     rax,[rsp+148h]
    lea     rcx,[rsp+150h]
    mov     [rsp+158h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+150h]
    mov     [rsp],rax
    lea     rax,[rsp+148h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+158h]
    mov     [rsp+168h],rax
    mov     rax,[rsp+148h]
    mov     rcx,[rsp+150h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym13]
    mov     r14,[rsp+168h]
    mov     [rsp+190h],r13
    mov     [rsp+188h],r13
    mov     [rsp+190h],r15
    lea     rax,[rsp+188h]
    lea     rcx,[rsp+190h]
    mov     [rsp+198h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+190h]
    mov     [rsp],rax
    lea     rax,[rsp+188h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+198h]
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+188h]
    mov     rcx,[rsp+190h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+1A8h]
    mov     eax,[rax]
    test    r14,3
    jne     L4
    test    r14,r14
    je      L4
    test    r13,3
    jne     L4
    test    r13,r13
    je      L4
    mov     ecx,[r14]
    mov     [rbx+1Ch],ecx
    test    r15,3
    jne     L5
    test    r15,r15
    je      L5
    mov     [rbx+20h],eax
    mov     r13,rbx
    lea     r13,[r13+24h]
    mov     r14,rbx
    lea     r14,[r14+28h]
    mov     eax,[rbx+28h]
    mov     ecx,[rbx+24h]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+1D0h],r14
    mov     [rsp+1C8h],r14
    mov     [rsp+1D0h],r13
    lea     rax,[rsp+1C8h]
    lea     rcx,[rsp+1D0h]
    mov     [rsp+1D8h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+1D0h]
    mov     [rsp],rax
    lea     rax,[rsp+1C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+1D8h]
    mov     [rsp+1E8h],rax
    mov     rax,[rsp+1C8h]
    mov     rcx,[rsp+1D0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+1E8h]
    mov     [rsp+210h],r13
    mov     [rsp+208h],r13
    mov     [rsp+210h],r14
    lea     rax,[rsp+208h]
    lea     rcx,[rsp+210h]
    mov     [rsp+218h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+210h]
    mov     [rsp],rax
    lea     rax,[rsp+208h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+218h]
    mov     [rsp+228h],rax
    mov     rax,[rsp+208h]
    mov     rcx,[rsp+210h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+228h]
    mov     eax,[rax]
    test    rbp,3
    jne     L6
    test    rbp,rbp
    je      L6
    test    r13,3
    jne     L6
    test    r13,r13
    je      L6
    mov     ecx,[rbp]
    mov     [rbx+24h],ecx
    test    r14,3
    jne     L7
    test    r14,r14
    je      L7
    mov     [rbx+28h],eax
    mov     r13,rbx
    lea     r13,[r13+2Ch]
    mov     r14,rbx
    lea     r14,[r14+30h]
    mov     eax,[rbx+30h]
    mov     ecx,[rbx+2Ch]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+250h],r14
    mov     [rsp+248h],r14
    mov     [rsp+250h],r13
    lea     rax,[rsp+248h]
    lea     rcx,[rsp+250h]
    mov     [rsp+258h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+250h]
    mov     [rsp],rax
    lea     rax,[rsp+248h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+258h]
    mov     [rsp+268h],rax
    mov     rax,[rsp+248h]
    mov     rcx,[rsp+250h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+268h]
    mov     [rsp+290h],r13
    mov     [rsp+288h],r13
    mov     [rsp+290h],r14
    lea     rax,[rsp+288h]
    lea     rcx,[rsp+290h]
    mov     [rsp+298h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+290h]
    mov     [rsp],rax
    lea     rax,[rsp+288h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+298h]
    mov     [rsp+2A8h],rax
    mov     rax,[rsp+288h]
    mov     rcx,[rsp+290h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+2A8h]
    mov     eax,[rax]
    test    rbp,3
    jne     L8
    test    rbp,rbp
    je      L8
    test    r13,3
    jne     L8
    test    r13,r13
    je      L8
    mov     ecx,[rbp]
    mov     [rbx+2Ch],ecx
    test    r14,3
    jne     L9
    test    r14,r14
    je      L9
    mov     [rbx+30h],eax
    mov     r13,rbx
    lea     r13,[r13+10h]
    mov     eax,[rbx+18h]
    mov     ecx,[rbx+10h]
    cmp     eax,ecx
    setb    r14b
    mov     r10,[rsp+30h]
    mov     [rsp+2D0h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+2C8h],r10
    mov     [rsp+2D0h],r13
    lea     rax,[rsp+2C8h]
    lea     rcx,[rsp+2D0h]
    mov     [rsp+2D8h],rcx
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    lea     rax,[rsp+2D0h]
    mov     [rsp],rax
    lea     rax,[rsp+2C8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+2D8h]
    mov     [rsp+2E8h],rax
    mov     rax,[rsp+2C8h]
    mov     rcx,[rsp+2D0h]
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym13]
    mov     r15,[rsp+2E8h]
    mov     [rsp+310h],r13
    mov     [rsp+308h],r13
    mov     r10,[rsp+30h]
    mov     [rsp+310h],r10
    lea     rax,[rsp+308h]
    lea     rcx,[rsp+310h]
    mov     [rsp+318h],rcx
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+532]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r14b
    lea     rax,[rsp+310h]
    mov     [rsp],rax
    lea     rax,[rsp+308h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+544]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+318h]
    mov     [rsp+328h],rax
    mov     rax,[rsp+308h]
    mov     rcx,[rsp+310h]
    mov     [rsp+8],r14b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+556]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+360h]
    lea     rsi,[ro+568]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+328h]
    mov     eax,[rax]
    test    r15,3
    jne     L10
    test    r15,r15
    je      L10
    test    r13,3
    jne     L10
    test    r13,r13
    je      L10
    mov     ecx,[r15]
    mov     [rbx+10h],ecx
    test    qword ptr [rsp+30h],3
    jne     L11
    mov     [rbx+18h],eax
    mov     rdi,rbx
    mov     esi,5
    mov     edx,9
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,5
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,1
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,5
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,9
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,3
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,2
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,r12
    call    fn0
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
    add     rsp,338h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L0:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L2:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L3:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L4:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L5:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L6:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L7:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L8:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L9:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L10:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L11:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L12:
    lea     rdi,[rsp+360h]
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
    mov     rbx,rdi
    mov     [rsp+38h],rdx
    cmp     rsi,9
    jb      L14
    mov     rdi,rbx
    mov     esi,0
    mov     edx,3
    mov     rcx,[rsp+38h]
    call    fn0
    mov     r11,rbx
    lea     r11,[r11+4]
    mov     [rsp+30h],r11
    mov     r14,rbx
    lea     r14,[r14+1Ch]
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx+4]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+60h],r14
    mov     [rsp+58h],r14
    mov     r10,[rsp+30h]
    mov     [rsp+60h],r10
    lea     rax,[rsp+58h]
    lea     rcx,[rsp+60h]
    mov     [rsp+68h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+60h]
    mov     [rsp],rax
    lea     rax,[rsp+58h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+68h]
    mov     [rsp+78h],rax
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+78h]
    mov     r10,[rsp+30h]
    mov     [rsp+0A0h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+98h],r10
    mov     [rsp+0A0h],r14
    lea     rax,[rsp+98h]
    lea     rcx,[rsp+0A0h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r15b
    lea     rax,[rsp+0A0h]
    mov     [rsp],rax
    lea     rax,[rsp+98h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+0A8h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     [rsp+8],r15b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+0B8h]
    mov     eax,[rax]
    test    rbp,3
    jne     L0
    test    rbp,rbp
    je      L0
    test    qword ptr [rsp+30h],3
    jne     L0
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L0
    mov     ecx,[rbp]
    mov     [rbx+4],ecx
    test    r14,3
    jne     L1
    test    r14,r14
    je      L1
    mov     [rbx+1Ch],eax
    mov     r15,rbx
    lea     r15,[r15+8]
    mov     rbp,rbx
    lea     rbp,[rbp+14h]
    mov     eax,[rbx+14h]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+0E0h],rbp
    mov     [rsp+0D8h],rbp
    mov     [rsp+0E0h],r15
    lea     rax,[rsp+0D8h]
    lea     rcx,[rsp+0E0h]
    mov     [rsp+0E8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+100]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+0E0h]
    mov     [rsp],rax
    lea     rax,[rsp+0D8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+112]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+0E8h]
    mov     [rsp+0F8h],rax
    mov     rax,[rsp+0D8h]
    mov     rcx,[rsp+0E0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+124]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+136]
    call    qword ptr [image.sym13]
    mov     r12,[rsp+0F8h]
    mov     [rsp+120h],r15
    mov     [rsp+118h],r15
    mov     [rsp+120h],rbp
    lea     rax,[rsp+118h]
    lea     rcx,[rsp+120h]
    mov     [rsp+128h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+148]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+120h]
    mov     [rsp],rax
    lea     rax,[rsp+118h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+160]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+128h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+118h]
    mov     rcx,[rsp+120h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+172]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+184]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+138h]
    mov     eax,[rax]
    test    r12,3
    jne     L2
    test    r12,r12
    je      L2
    test    r15,3
    jne     L2
    test    r15,r15
    je      L2
    mov     ecx,[r12]
    mov     [rbx+8],ecx
    test    rbp,3
    jne     L3
    test    rbp,rbp
    je      L3
    mov     [rbx+14h],eax
    mov     r12,rbx
    lea     r12,[r12+10h]
    mov     r11,rbx
    lea     r11,[r11+20h]
    mov     [rsp+40h],r11
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+10h]
    cmp     eax,ecx
    setb    bpl
    mov     r10,[rsp+40h]
    mov     [rsp+160h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+158h],r10
    mov     [rsp+160h],r12
    lea     rax,[rsp+158h]
    lea     rcx,[rsp+160h]
    mov     [rsp+168h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+196]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+160h]
    mov     [rsp],rax
    lea     rax,[rsp+158h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+208]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+168h]
    mov     [rsp+178h],rax
    mov     rax,[rsp+158h]
    mov     rcx,[rsp+160h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+220]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+232]
    call    qword ptr [image.sym13]
    mov     r13,[rsp+178h]
    mov     [rsp+1A0h],r12
    mov     [rsp+198h],r12
    mov     r10,[rsp+40h]
    mov     [rsp+1A0h],r10
    lea     rax,[rsp+198h]
    lea     rcx,[rsp+1A0h]
    mov     [rsp+1A8h],rcx
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+244]
    call    qword ptr [image.sym12]
    mov     [rsp+8],bpl
    lea     rax,[rsp+1A0h]
    mov     [rsp],rax
    lea     rax,[rsp+198h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+256]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+1A8h]
    mov     [rsp+1B8h],rax
    mov     rax,[rsp+198h]
    mov     rcx,[rsp+1A0h]
    mov     [rsp+8],bpl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+268]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+280]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+1B8h]
    mov     eax,[rax]
    test    r13,3
    jne     L4
    test    r13,r13
    je      L4
    test    r12,3
    jne     L4
    test    r12,r12
    je      L4
    mov     ecx,[r13]
    mov     [rbx+10h],ecx
    test    qword ptr [rsp+40h],3
    jne     L5
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L5
    mov     [rbx+20h],eax
    mov     eax,[rbx+1Ch]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+1E0h],r14
    mov     [rsp+1D8h],r14
    mov     [rsp+1E0h],rbx
    lea     rax,[rsp+1D8h]
    lea     rcx,[rsp+1E0h]
    mov     [rsp+1E8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+292]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+1E0h]
    mov     [rsp],rax
    lea     rax,[rsp+1D8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+304]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+1E8h]
    mov     [rsp+1F8h],rax
    mov     rax,[rsp+1D8h]
    mov     rcx,[rsp+1E0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+316]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+328]
    call    qword ptr [image.sym13]
    mov     rbp,[rsp+1F8h]
    mov     [rsp+220h],rbx
    mov     [rsp+218h],rbx
    mov     [rsp+220h],r14
    lea     rax,[rsp+218h]
    lea     rcx,[rsp+220h]
    mov     [rsp+228h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+340]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+220h]
    mov     [rsp],rax
    lea     rax,[rsp+218h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+352]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+228h]
    mov     [rsp+238h],rax
    mov     rax,[rsp+218h]
    mov     rcx,[rsp+220h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+364]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+376]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+238h]
    mov     eax,[rax]
    test    rbp,3
    jne     L6
    test    rbp,rbp
    je      L6
    test    rbx,3
    jne     L6
    test    rbx,rbx
    je      L6
    mov     ecx,[rbp]
    mov     [rbx],ecx
    test    r14,3
    jne     L7
    mov     [rbx+1Ch],eax
    mov     eax,[rbx+10h]
    mov     ecx,[rbx+8]
    cmp     eax,ecx
    setb    r13b
    mov     [rsp+260h],r12
    mov     [rsp+258h],r12
    mov     [rsp+260h],r15
    lea     rax,[rsp+258h]
    lea     rcx,[rsp+260h]
    mov     [rsp+268h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+388]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+260h]
    mov     [rsp],rax
    lea     rax,[rsp+258h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+400]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+268h]
    mov     [rsp+278h],rax
    mov     rax,[rsp+258h]
    mov     rcx,[rsp+260h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+412]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+424]
    call    qword ptr [image.sym13]
    mov     r14,[rsp+278h]
    mov     [rsp+2A0h],r15
    mov     [rsp+298h],r15
    mov     [rsp+2A0h],r12
    lea     rax,[rsp+298h]
    lea     rcx,[rsp+2A0h]
    mov     [rsp+2A8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+436]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+2A0h]
    mov     [rsp],rax
    lea     rax,[rsp+298h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+448]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+2A8h]
    mov     [rsp+2B8h],rax
    mov     rax,[rsp+298h]
    mov     rcx,[rsp+2A0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+460]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+472]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+2B8h]
    mov     eax,[rax]
    test    r14,3
    jne     L8
    test    r14,r14
    je      L8
    test    r15,3
    jne     L8
    mov     ecx,[r14]
    mov     [rbx+8],ecx
    test    r12,3
    jne     L9
    mov     [rbx+10h],eax
    mov     r12,rbx
    lea     r12,[r12+0Ch]
    mov     eax,[rbx+20h]
    mov     ecx,[rbx+0Ch]
    cmp     eax,ecx
    setb    r13b
    mov     r10,[rsp+40h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+2D8h],r10
    mov     [rsp+2E0h],r12
    lea     rax,[rsp+2D8h]
    lea     rcx,[rsp+2E0h]
    mov     [rsp+2E8h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+484]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+2E0h]
    mov     [rsp],rax
    lea     rax,[rsp+2D8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+496]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+2E8h]
    mov     [rsp+2F8h],rax
    mov     rax,[rsp+2D8h]
    mov     rcx,[rsp+2E0h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+508]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+520]
    call    qword ptr [image.sym13]
    mov     r14,[rsp+2F8h]
    mov     [rsp+320h],r12
    mov     [rsp+318h],r12
    mov     r10,[rsp+40h]
    mov     [rsp+320h],r10
    lea     rax,[rsp+318h]
    lea     rcx,[rsp+320h]
    mov     [rsp+328h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+532]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+320h]
    mov     [rsp],rax
    lea     rax,[rsp+318h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+544]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+328h]
    mov     [rsp+338h],rax
    mov     rax,[rsp+318h]
    mov     rcx,[rsp+320h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+556]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+568]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+338h]
    mov     eax,[rax]
    test    r14,3
    jne     L10
    test    r14,r14
    je      L10
    test    r12,3
    jne     L10
    test    r12,r12
    je      L10
    mov     ecx,[r14]
    mov     [rbx+0Ch],ecx
    test    qword ptr [rsp+40h],3
    jne     L11
    mov     [rbx+20h],eax
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,2
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,4
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+38h]
    call    fn0
    mov     eax,[rbx+4]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    r12b
    mov     r10,[rsp+30h]
    mov     [rsp+360h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+358h],r10
    mov     [rsp+360h],rbx
    lea     rax,[rsp+358h]
    lea     rcx,[rsp+360h]
    mov     [rsp+368h],rcx
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+580]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    lea     rax,[rsp+360h]
    mov     [rsp],rax
    lea     rax,[rsp+358h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+592]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+368h]
    mov     [rsp+378h],rax
    mov     rax,[rsp+358h]
    mov     rcx,[rsp+360h]
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+604]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+616]
    call    qword ptr [image.sym13]
    mov     r13,[rsp+378h]
    mov     [rsp+3A0h],rbx
    mov     [rsp+398h],rbx
    mov     r10,[rsp+30h]
    mov     [rsp+3A0h],r10
    lea     rax,[rsp+398h]
    lea     rcx,[rsp+3A0h]
    mov     [rsp+3A8h],rcx
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+628]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r12b
    lea     rax,[rsp+3A0h]
    mov     [rsp],rax
    lea     rax,[rsp+398h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+640]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+3A8h]
    mov     [rsp+3B8h],rax
    mov     rax,[rsp+398h]
    mov     rcx,[rsp+3A0h]
    mov     [rsp+8],r12b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+652]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+3F0h]
    lea     rsi,[ro+664]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+3B8h]
    mov     eax,[rax]
    test    r13,3
    jne     L12
    test    r13,r13
    je      L12
    test    rbx,3
    jne     L12
    mov     ecx,[r13]
    mov     [rbx],ecx
    test    qword ptr [rsp+30h],3
    jne     L13
    mov     [rbx+4],eax
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,5
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+38h]
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+38h]
    call    fn0
    add     rsp,3C8h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L0:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L2:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L3:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L4:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L5:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L6:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L7:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L8:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L9:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L10:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L11:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L12:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k2088]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L13:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k2112]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L14:
    lea     rdi,[rsp+3F0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbx
    push    r12
    push    r13
    push    r14
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
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+16]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+48h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+28]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+40]
    call    qword ptr [image.sym13]
    mov     r14,[rsp+58h]
    mov     [rsp+80h],rbx
    mov     [rsp+78h],rbx
    mov     [rsp+80h],r12
    lea     rax,[rsp+78h]
    lea     rcx,[rsp+80h]
    mov     [rsp+88h],rcx
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+52]
    call    qword ptr [image.sym12]
    mov     [rsp+8],r13b
    lea     rax,[rsp+80h]
    mov     [rsp],rax
    lea     rax,[rsp+78h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+64]
    call    qword ptr [image.sym12]
    mov     rax,[rsp+88h]
    mov     [rsp+98h],rax
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+8],r13b
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+76]
    call    qword ptr [image.sym14]
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+88]
    call    qword ptr [image.sym13]
    mov     rax,[rsp+98h]
    mov     eax,[rax]
    test    r14,3
    jne     L0
    test    r14,r14
    je      L0
    test    rbx,3
    jne     L0
    test    rbx,rbx
    je      L0
    mov     ecx,[r14]
    mov     [rbx],ecx
    test    r12,3
    jne     L1
    test    r12,r12
    je      L1
    mov     [r12],eax
    add     rsp,0A8h
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L0:
    lea     rdi,[image.k8912]
    lea     rcx,[k3]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L1:
    lea     rdi,[image.k8346]
    lea     rcx,[k5]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    ret

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    sub     rsp,18h
    mov     rax,[rdi+18h]
    lea     rax,[rax-8]
    mov     [rdi+18h],rax
    test    sil,sil
    je      L0
    mov     rcx,[rdi]
    jmp     L1
L0:
    mov     rcx,rax
L1:
    mov     rax,[rdi+10h]
    lea     rax,[rcx+rax*8]
    mov     rcx,[rdi+8]
    test    rcx,3
    jne     L4
    test    rcx,rcx
    je      L4
    test    rax,3
    jne     L4
    test    rax,rax
    je      L4
    cmp     rcx,rax
    jae     L2
    mov     rdx,rax
    sub     rdx,rcx
    jmp     L3
L2:
    mov     rdx,rcx
    sub     rdx,rax
L3:
    cmp     rdx,8
    jb      L4
    mov     edx,[rcx]
    mov     ecx,[rcx+4]
    mov     [rax],edx
    mov     [rax+4],ecx
    movzx   esi,sil
    mov     rcx,[rdi+10h]
    add     rcx,rsi
    mov     [rdi+10h],rcx
    mov     rcx,[rdi+8]
    lea     rcx,[rcx+8]
    mov     [rdi+8],rcx
    add     rsp,18h
    ret
L4:
    lea     rdi,[image.k8346]
    lea     rcx,[k0]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
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
L6:
    ret
L7:
    ret
L8:
    ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,1F8h
    mov     [rsp+0F8h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E8h],r13
    mov     [rsp+0E0h],r14
    mov     [rsp+0D8h],r15
    mov     [rsp+0D0h],rbp
    mov     rax,[rsp+200h]
    mov     rbx,rdi
    mov     [rsp+48h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rcx
    mov     [rsp+40h],rax
    mov     rbp,r8
    mov     [rsp+20h],r9
L0:
    mov     [rsp+130h],rbx
    call    fn0
    cmp     rax,[rsp+48h]
    jb      L1
    mov     rdi,rbx
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r8,[rsp+40h]
    call    qword ptr [image.fn81.slot]
    jmp     L2
L1:
    test    ebp,ebp
    jne     L3
    mov     rdi,rbx
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r8d,1
    mov     r9,[rsp+40h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
L2:
    mov     rbx,[rsp+0F8h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E8h]
    mov     r14,[rsp+0E0h]
    mov     r15,[rsp+0D8h]
    mov     rbp,[rsp+0D0h]
    add     rsp,1F8h
    ret
L3:
    lea     r11d,[rbp-1]
    mov     [rsp+28h],r11
    mov     r10,[rsp+48h]
    mov     [rsp+130h],r10
    mov     r11,[rsp+48h]
    cmp     r11,8
    jb      L22
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
    jae     L7
    mov     ecx,[rbx]
    mov     edx,[rbp]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r13]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L5
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L4
    mov     rcx,r13
    jmp     L6
L4:
    mov     rcx,rbp
    jmp     L6
L5:
    mov     rcx,rbx
L6:
    cmp     rcx,rbx
    jb      L19
    sub     rcx,rbx
    shr     rcx,3
    jmp     L11
L7:
    mov     r14,rax
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    lea     rsi,[rbx+r15*8]
    mov     r12,r14
    imul    r12,7
    lea     rdx,[rbx+r12*8]
    mov     rdi,rbx
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     [rsp+50h],rax
    lea     rsi,[rbp+r15*8]
    lea     rdx,[rbp+r12*8]
    mov     rdi,rbp
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     rbp,rax
    lea     rsi,[r13+r15*8]
    lea     rdx,[r13+r12*8]
    mov     rdi,r13
    mov     rcx,r14
    mov     r8,[rsp+40h]
    call    image.fn58
    mov     r11,[rsp+50h]
    mov     ecx,[r11]
    mov     edx,[rbp]
    cmp     ecx,edx
    setb    sil
    mov     edi,[rax]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L9
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L8
    jmp     L10
L8:
    mov     rax,rbp
    jmp     L10
L9:
    mov     rax,[rsp+50h]
L10:
    cmp     rax,rbx
    jb      L20
    sub     rax,rbx
    shr     rax,3
    mov     rcx,rax
L11:
    cmp     rcx,[rsp+48h]
    jae     L21
    mov     rax,[rbx+rcx*8]
    mov     [rsp+130h],rax
    lea     rax,[rsp+130h]
    mov     [rsp+118h],rax
    mov     [rsp+60h],rbx
    mov     r11,[rsp+48h]
    mov     [rsp+68h],r11
    mov     [rsp+70h],rcx
    mov     r11,[rsp+40h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+88h],r11
    mov     r9,[rsp+28h]
    mov     [rsp+90h],rax
    mov     rax,[rsp+20h]
L12:
    test    rax,rax
    je      L18
    mov     r13,rax
    mov     r14,[rsp+60h]
    mov     r11,[rsp+68h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+98h],r11
    mov     r15,[rsp+78h]
    mov     rbx,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     rdx,r9
    mov     rsi,[rsp+90h]
L13:
    mov     r11,[rsp+98h]
    cmp     r11,[rsp+58h]
    jae     L26
    mov     r10,[rsp+98h]
    lea     rdi,[r14+r10*8]
    mov     [rsp+110h],rdi
    mov     [rsp+118h],r13
    mov     r8d,[r13]
    mov     edi,[rdi]
    cmp     r8d,edi
    setb    dil
    mov     r8,rdi
    xor     r8d,1
    cmp     dil,1
    je      L14
    mov     r11,[rsp+58h]
    mov     [rsp+0B8h],r11
    mov     r12,rbx
    mov     rbp,[rsp+98h]
    mov     ebx,0
    mov     [rsp+0C0h],rdx
    mov     [rsp+0C8h],r13
    mov     r13,rcx
    jmp     L16
L14:
    mov     r12,rcx
    mov     rbp,[rsp+98h]
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rsi
    mov     [rsp+0B0h],r13
    mov     r13,rbx
    mov     rbx,[rsp+58h]
    jmp     L15
L15:
    mov     [rsp],r15
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r13
    mov     rcx,r12
    mov     r8,rbp
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    mov     rcx,rax
    test    rcx,rcx
    sete    dl
    mov     r8,rdx
    mov     [rsp+0B8h],rbx
    mov     rbx,rcx
    mov     r11,[rsp+0A0h]
    mov     [rsp+0C0h],r11
    mov     rsi,[rsp+0A8h]
    mov     r11,[rsp+0B0h]
    mov     [rsp+0C8h],r11
    mov     r10,r12
    mov     r12,r13
    mov     r13,r10
L16:
    test    r8b,r8b
    je      L17
    mov     [rsp+118h],r14
    mov     [rsp+108h],r15
    lea     rcx,[rsp+108h]
    mov     [rsp+110h],rcx
    mov     [rsp],rcx
    mov     rdi,r14
    mov     rsi,[rsp+0B8h]
    mov     rdx,r12
    mov     rcx,r13
    mov     r8,rbp
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     rdi,rax
    mov     r11,[rsp+0B8h]
    cmp     r11,rdi
    jb      L27
    mov     rcx,[rsp+0B8h]
    sub     rcx,rdi
    mov     [rsp+118h],rcx
    mov     r10,[rsp+0B8h]
    mov     [rsp+100h],r10
    lea     rdx,[r14+rdi*8]
    mov     [rsp+108h],rdx
    mov     [rsp+110h],rcx
    mov     rbx,rdx
    mov     [rsp+48h],rcx
    mov     [rsp+30h],r12
    mov     [rsp+38h],r13
    mov     [rsp+40h],r15
    mov     rbp,[rsp+0C0h]
    mov     qword ptr [rsp+20h],0
    jmp     L0
L17:
    mov     r11,[rsp+0B8h]
    cmp     r11,rbx
    jb      L25
    test    r14,3
    jne     L23
    test    r14,r14
    je      L23
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     rbx,r10
    ja      L23
    lea     rcx,[r14+rbx*8]
    mov     rdx,[rsp+0B8h]
    sub     rdx,rbx
    test    rcx,3
    jne     L24
    test    rcx,rcx
    je      L24
    mov     r10,0FFFFFFFFFFFFFFFh
    cmp     rdx,r10
    ja      L24
    mov     [rsp+100h],r14
    mov     [rsp+108h],rbx
    mov     [rsp+110h],rcx
    mov     [rsp+118h],rdx
    mov     [rsp],r15
    mov     rdi,rcx
    mov     rcx,r13
    mov     r8,[rsp+0C0h]
    mov     r9,rsi
    mov     rsi,rdx
    mov     rdx,r12
    mov     r8d,r8d
    call    fn14
    mov     [rsp+48h],rbx
    mov     rbx,r14
    mov     [rsp+30h],r12
    mov     [rsp+38h],r13
    mov     [rsp+40h],r15
    mov     rbp,[rsp+0C0h]
    mov     r11,[rsp+0C8h]
    mov     [rsp+20h],r11
    jmp     L0
L18:
    mov     r14,[rsp+60h]
    mov     rbx,[rsp+68h]
    mov     r15,[rsp+78h]
    mov     r13,[rsp+80h]
    mov     r12,[rsp+88h]
    mov     rbp,[rsp+70h]
    mov     [rsp+0A0h],r9
    mov     r11,[rsp+90h]
    mov     [rsp+0A8h],r11
    mov     [rsp+0B0h],rax
    jmp     L15
L19:
    lea     rax,[image.k7575]
    lea     rcx,[image.k1248]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L20:
    lea     rax,[image.k7575]
    lea     rcx,[image.k1464]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L21:
    lea     rax,[image.k9133]
    lea     rcx,[image.k1512]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L22:
    lea     rdi,[rsp+1F0h]
    call    ryo_h_Abort
    ud2
L23:
    lea     rax,[image.k9694]
    lea     rcx,[image.k6272]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L24:
    lea     rax,[image.k9694]
    lea     rcx,[image.k6272]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L25:
    lea     rax,[image.k6296]
    lea     rdx,[k12]
    mov     rdi,rax
    mov     esi,13h
    call    image.sym6
    ud2
L26:
    lea     rdx,[k7]
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+58h]
    call    sym5
    ud2
L27:
    lea     rcx,[k15]
    mov     rsi,[rsp+0B8h]
    mov     rdx,[rsp+0B8h]
    call    sym16
    ud2
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
L29:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-230h]
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
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1D0h],r11
    mov     rbx,[rsp]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+40h]
    jmp     L0
L30:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-240h]
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
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-158h],r11
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+20h]
    mov     rbx,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+38h]
    lea     rsp,[rsp+50h]
    jmp     L13
L31:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-240h]
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
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-140h],r11
    mov     r14,[rsp]
    mov     rbx,[rsp+8]
    mov     r15,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L15
L32:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-240h]
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
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-190h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     rax,[rsp]
    mov     r9,[rsp+38h]
    lea     rsp,[rsp+50h]
    jmp     L12

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     eax,[rdx]
    mov     ecx,[rsi]
    cmp     eax,ecx
    setb    al
    xor     eax,1
    movzx   eax,al
    add     rsp,18h
    ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    sub     rsp,188h
    mov     [rsp+78h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+68h],r13
    mov     [rsp+60h],r14
    mov     [rsp+58h],r15
    mov     [rsp+50h],rbp
    cmp     rcx,rsi
    jb      L49
    cmp     rsi,r8
    jbe     L49
    lea     rax,[rdi+r8*8]
    lea     rcx,[rdx+rsi*8]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rdi
    mov     qword ptr [rsp+90h],0
    mov     [rsp+98h],rcx
    mov     rbx,r8
    mov     r12,rdi
    mov     r13,rax
    mov     r14,rsi
    mov     r15,r9
    mov     rbp,rdi
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rdx
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+180h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rax,[rsp+40h]
    lea     rax,[r12+rax*8]
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+28h]
L1:
    mov     rsi,[rsp+88h]
    cmp     rsi,rax
    jae     L18
    mov     edi,[r13]
    mov     esi,[rsi]
    cmp     edi,esi
    setb    sil
    mov     rdi,rsi
    xor     edi,1
    mov     r8,[rsp+98h]
    lea     r8,[r8-8]
    mov     [rsp+98h],r8
    test    sil,sil
    jne     L2
    mov     rsi,[rsp+80h]
    jmp     L3
L2:
    mov     rsi,r8
L3:
    mov     r8,[rsp+90h]
    lea     rsi,[rsi+r8*8]
    mov     r8,[rsp+88h]
    test    r8,3
    jne     L40
    test    r8,r8
    je      L40
    test    rsi,3
    jne     L40
    test    rsi,rsi
    je      L40
    cmp     r8,rsi
    jae     L4
    mov     r9,rsi
    sub     r9,r8
    jmp     L5
L4:
    mov     r9,r8
    sub     r9,rsi
L5:
    cmp     r9,8
    jb      L40
    mov     r9d,[r8]
    mov     r8d,[r8+4]
    mov     [rsi],r9d
    mov     [rsi+4],r8d
    movzx   edi,dil
    mov     rsi,[rsp+90h]
    add     rsi,rdi
    mov     [rsp+90h],rsi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     edi,[r13]
    mov     esi,[rsi+8]
    cmp     edi,esi
    setb    sil
    mov     rdi,rsi
    xor     edi,1
    mov     r8,[rsp+98h]
    lea     r8,[r8-8]
    mov     [rsp+98h],r8
    test    sil,sil
    jne     L6
    mov     rsi,[rsp+80h]
    jmp     L7
L6:
    mov     rsi,r8
L7:
    mov     r8,[rsp+90h]
    lea     rsi,[rsi+r8*8]
    mov     r8,[rsp+88h]
    test    r8,3
    jne     L41
    test    r8,r8
    je      L41
    test    rsi,3
    jne     L41
    test    rsi,rsi
    je      L41
    cmp     r8,rsi
    jae     L8
    mov     r9,rsi
    sub     r9,r8
    jmp     L9
L8:
    mov     r9,r8
    sub     r9,rsi
L9:
    cmp     r9,8
    jb      L41
    mov     r9d,[r8]
    mov     r8d,[r8+4]
    mov     [rsi],r9d
    mov     [rsi+4],r8d
    movzx   edi,dil
    mov     rsi,[rsp+90h]
    add     rsi,rdi
    mov     [rsp+90h],rsi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     edi,[r13]
    mov     esi,[rsi+8]
    cmp     edi,esi
    setb    sil
    mov     rdi,rsi
    xor     edi,1
    mov     r8,[rsp+98h]
    lea     r8,[r8-8]
    mov     [rsp+98h],r8
    test    sil,sil
    jne     L10
    mov     rsi,[rsp+80h]
    jmp     L11
L10:
    mov     rsi,r8
L11:
    mov     r8,[rsp+90h]
    lea     rsi,[rsi+r8*8]
    mov     r8,[rsp+88h]
    test    r8,3
    jne     L42
    test    r8,r8
    je      L42
    test    rsi,3
    jne     L42
    test    rsi,rsi
    je      L42
    cmp     r8,rsi
    jae     L12
    mov     r9,rsi
    sub     r9,r8
    jmp     L13
L12:
    mov     r9,r8
    sub     r9,rsi
L13:
    cmp     r9,8
    jb      L42
    mov     r9d,[r8]
    mov     r8d,[r8+4]
    mov     [rsi],r9d
    mov     [rsi+4],r8d
    movzx   edi,dil
    mov     rsi,[rsp+90h]
    add     rsi,rdi
    mov     [rsp+90h],rsi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     edi,[r13]
    mov     esi,[rsi+8]
    cmp     edi,esi
    setb    sil
    mov     rdi,rsi
    xor     edi,1
    mov     [rsp+46h],dil
    mov     r8,[rsp+98h]
    lea     r8,[r8-8]
    mov     [rsp+98h],r8
    test    sil,sil
    jne     L14
    mov     rsi,[rsp+80h]
    jmp     L15
L14:
    mov     rsi,r8
L15:
    mov     r8,[rsp+90h]
    lea     rsi,[rsi+r8*8]
    mov     r8,[rsp+88h]
    test    r8,3
    jne     L43
    test    r8,r8
    je      L43
    test    rsi,3
    jne     L43
    test    rsi,rsi
    je      L43
    cmp     r8,rsi
    jae     L16
    mov     r9,rsi
    sub     r9,r8
    jmp     L17
L16:
    mov     r9,r8
    sub     r9,rsi
L17:
    cmp     r9,8
    jb      L43
    mov     r9d,[r8]
    mov     r8d,[r8+4]
    mov     [rsi],r9d
    mov     [rsi+4],r8d
    movzx   edi,dil
    mov     rsi,[rsp+90h]
    add     rsi,rdi
    mov     [rsp+90h],rsi
    mov     rsi,[rsp+88h]
    lea     rsi,[rsi+8]
    mov     [rsp+88h],rsi
    jmp     L1
L18:
    mov     [rsp+40h],rbx
    lea     rax,[r12+rbx*8]
    mov     [rsp+30h],r12
    mov     r12,rdx
L19:
    mov     rdx,[rsp+88h]
    cmp     rdx,rax
    jae     L24
    mov     esi,[r13]
    mov     edx,[rdx]
    cmp     esi,edx
    setb    dl
    mov     rsi,rdx
    xor     esi,1
    mov     [rsp+46h],sil
    mov     rdi,[rsp+98h]
    lea     rdi,[rdi-8]
    mov     [rsp+98h],rdi
    test    dl,dl
    jne     L20
    mov     rdx,[rsp+80h]
    jmp     L21
L20:
    mov     rdx,rdi
L21:
    mov     rdi,[rsp+90h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+88h]
    test    rdi,3
    jne     L44
    test    rdi,rdi
    je      L44
    test    rdx,3
    jne     L44
    test    rdx,rdx
    je      L44
    cmp     rdi,rdx
    jae     L22
    mov     r8,rdx
    sub     r8,rdi
    jmp     L23
L22:
    mov     r8,rdi
    sub     r8,rdx
L23:
    cmp     r8,8
    jb      L44
    mov     r8d,[rdi]
    mov     edi,[rdi+4]
    mov     [rdx],r8d
    mov     [rdx+4],edi
    movzx   esi,sil
    mov     rdx,[rsp+90h]
    add     rdx,rsi
    mov     [rsp+90h],rdx
    mov     rdx,[rsp+88h]
    lea     rdx,[rdx+8]
    mov     [rsp+88h],rdx
    jmp     L19
L24:
    cmp     rbx,r14
    jne     L31
    mov     [rsp+40h],rcx
    mov     rsi,[rsp+90h]
    test    rsi,rsi
    jne     L25
    mov     eax,1
    jmp     L26
L25:
    mov     eax,0
L26:
    test    rcx,3
    jne     L46
    test    al,al
    jne     L27
    test    rcx,rcx
    je      L46
L27:
    test    rbp,3
    jne     L46
    test    al,al
    jne     L28
    test    rbp,rbp
    je      L46
L28:
    mov     eax,8
    mul     rsi
    jb      L45
    cmp     rcx,rbp
    jae     L29
    mov     rdx,rbp
    sub     rdx,rcx
    jmp     L30
L29:
    mov     rdx,rcx
    sub     rdx,rbp
L30:
    cmp     rax,rdx
    ja      L46
    imul    rsi,8
    mov     [rsp+10h],rbp
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFE90h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE98h
    call    ryo_h_Memcpy
    mov     rax,[rsp+90h]
    mov     r11,r14
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+40h],rax
    mov     rcx,rax
    mov     eax,0
    jmp     L36
L31:
    lea     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+98h]
    lea     rax,[rax-8]
    mov     [rsp+98h],rax
    test    r15b,r15b
    je      L32
    mov     rdx,[rsp+80h]
    jmp     L33
L32:
    mov     rdx,rax
L33:
    mov     rax,[rsp+90h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+88h]
    test    rax,3
    jne     L47
    test    rax,rax
    je      L47
    test    rdx,3
    jne     L47
    test    rdx,rdx
    je      L47
    cmp     rax,rdx
    jae     L34
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L35
L34:
    mov     rsi,rax
    sub     rsi,rdx
L35:
    cmp     rsi,8
    jb      L47
    mov     esi,[rax]
    mov     eax,[rax+4]
    mov     [rdx],esi
    mov     [rdx+4],eax
    movzx   eax,r15b
    mov     rdx,[rsp+90h]
    add     rdx,rax
    mov     [rsp+90h],rdx
    mov     rax,[rsp+88h]
    lea     rax,[rax+8]
    mov     [rsp+88h],rax
    mov     rbx,r14
    mov     [rsp+20h],rcx
    mov     [rsp+28h],r12
    mov     r12,[rsp+30h]
    jmp     L0
L36:
    cmp     rax,rcx
    jae     L39
    lea     rdx,[rax+1]
    mov     [rsp+40h],rax
    lea     rsi,[r14-1]
    sub     rsi,rax
    lea     rsi,[r12+rsi*8]
    mov     rdi,[rsp+90h]
    add     rdi,rax
    lea     rax,[rbp+rdi*8]
    test    rsi,3
    jne     L48
    test    rsi,rsi
    je      L48
    test    rax,3
    jne     L48
    test    rax,rax
    je      L48
    cmp     rsi,rax
    jae     L37
    mov     rdi,rax
    sub     rdi,rsi
    jmp     L38
L37:
    mov     rdi,rsi
    sub     rdi,rax
L38:
    cmp     rdi,8
    jb      L48
    mov     edi,[rsi]
    mov     esi,[rsi+4]
    mov     [rax],edi
    mov     [rax+4],esi
    mov     rax,rdx
    jmp     L36
L39:
    mov     rax,[rsp+90h]
    mov     rbx,[rsp+78h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+68h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+50h]
    add     rsp,188h
    ret
L40:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L41:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L42:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L43:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L44:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L45:
    lea     rdi,[image.k9354]
    mov     esi,3Dh
    call    image.sym46
    ud2
L46:
    lea     rdi,[image.k8346]
    lea     rcx,[k15]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L47:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L48:
    lea     rdi,[image.k8346]
    lea     rcx,[k19]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L49:
    lea     rdi,[rsp+180h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L50]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L50:
    .long   L51
    .long   L52
    .long   L53
    .long   L54
    .long   L55
    .long   L56
L51:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+50h],r11
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L52:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     rdx,[rsp+40h]
    lea     rsp,[rsp+60h]
    jmp     L1
L53:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r12,[rsp+40h]
    lea     rsp,[rsp+60h]
    jmp     L19
L54:
    ret
L55:
    ret
L56:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1C0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L36

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,188h
    mov     [rsp+78h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+68h],r13
    mov     [rsp+60h],r14
    mov     [rsp+58h],r15
    mov     [rsp+50h],rbp
    cmp     rcx,rsi
    jb      L49
    cmp     rsi,r8
    jbe     L49
    lea     rax,[rdi+r8*8]
    lea     rcx,[rdx+rsi*8]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rdi
    mov     qword ptr [rsp+90h],0
    mov     [rsp+98h],rcx
    mov     rbx,r8
    mov     r12,rdi
    mov     r13,rax
    mov     r14,rsi
    mov     r15,r9
    mov     rbp,rdi
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rdx
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+180h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rax,[rsp+40h]
    lea     rax,[r12+rax*8]
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+28h]
L1:
    mov     rsi,[rsp+88h]
    cmp     rsi,rax
    jae     L18
    mov     esi,[rsi]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    mov     rdi,[rsp+98h]
    lea     rdi,[rdi-8]
    mov     [rsp+98h],rdi
    test    sil,sil
    je      L2
    mov     r8,[rsp+80h]
    jmp     L3
L2:
    mov     r8,rdi
L3:
    mov     rdi,[rsp+90h]
    lea     r8,[r8+rdi*8]
    mov     rdi,[rsp+88h]
    test    rdi,3
    jne     L40
    test    rdi,rdi
    je      L40
    test    r8,3
    jne     L40
    test    r8,r8
    je      L40
    cmp     rdi,r8
    jae     L4
    mov     r9,r8
    sub     r9,rdi
    jmp     L5
L4:
    mov     r9,rdi
    sub     r9,r8
L5:
    cmp     r9,8
    jb      L40
    mov     r9d,[rdi]
    mov     edi,[rdi+4]
    mov     [r8],r9d
    mov     [r8+4],edi
    movzx   esi,sil
    mov     rdi,[rsp+90h]
    add     rdi,rsi
    mov     [rsp+90h],rdi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     esi,[rsi+8]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    mov     rdi,[rsp+98h]
    lea     rdi,[rdi-8]
    mov     [rsp+98h],rdi
    test    sil,sil
    je      L6
    mov     r8,[rsp+80h]
    jmp     L7
L6:
    mov     r8,rdi
L7:
    mov     rdi,[rsp+90h]
    lea     r8,[r8+rdi*8]
    mov     rdi,[rsp+88h]
    test    rdi,3
    jne     L41
    test    rdi,rdi
    je      L41
    test    r8,3
    jne     L41
    test    r8,r8
    je      L41
    cmp     rdi,r8
    jae     L8
    mov     r9,r8
    sub     r9,rdi
    jmp     L9
L8:
    mov     r9,rdi
    sub     r9,r8
L9:
    cmp     r9,8
    jb      L41
    mov     r9d,[rdi]
    mov     edi,[rdi+4]
    mov     [r8],r9d
    mov     [r8+4],edi
    movzx   esi,sil
    mov     rdi,[rsp+90h]
    add     rdi,rsi
    mov     [rsp+90h],rdi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     esi,[rsi+8]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    mov     rdi,[rsp+98h]
    lea     rdi,[rdi-8]
    mov     [rsp+98h],rdi
    test    sil,sil
    je      L10
    mov     r8,[rsp+80h]
    jmp     L11
L10:
    mov     r8,rdi
L11:
    mov     rdi,[rsp+90h]
    lea     r8,[r8+rdi*8]
    mov     rdi,[rsp+88h]
    test    rdi,3
    jne     L42
    test    rdi,rdi
    je      L42
    test    r8,3
    jne     L42
    test    r8,r8
    je      L42
    cmp     rdi,r8
    jae     L12
    mov     r9,r8
    sub     r9,rdi
    jmp     L13
L12:
    mov     r9,rdi
    sub     r9,r8
L13:
    cmp     r9,8
    jb      L42
    mov     r9d,[rdi]
    mov     edi,[rdi+4]
    mov     [r8],r9d
    mov     [r8+4],edi
    movzx   esi,sil
    mov     rdi,[rsp+90h]
    add     rdi,rsi
    mov     [rsp+90h],rdi
    mov     rsi,[rsp+88h]
    mov     rdi,rsi
    lea     rdi,[rdi+8]
    mov     [rsp+88h],rdi
    mov     esi,[rsi+8]
    mov     edi,[r13]
    cmp     esi,edi
    setb    sil
    mov     [rsp+46h],sil
    mov     rdi,[rsp+98h]
    lea     rdi,[rdi-8]
    mov     [rsp+98h],rdi
    test    sil,sil
    je      L14
    mov     r8,[rsp+80h]
    jmp     L15
L14:
    mov     r8,rdi
L15:
    mov     rdi,[rsp+90h]
    lea     r8,[r8+rdi*8]
    mov     rdi,[rsp+88h]
    test    rdi,3
    jne     L43
    test    rdi,rdi
    je      L43
    test    r8,3
    jne     L43
    test    r8,r8
    je      L43
    cmp     rdi,r8
    jae     L16
    mov     r9,r8
    sub     r9,rdi
    jmp     L17
L16:
    mov     r9,rdi
    sub     r9,r8
L17:
    cmp     r9,8
    jb      L43
    mov     r9d,[rdi]
    mov     edi,[rdi+4]
    mov     [r8],r9d
    mov     [r8+4],edi
    movzx   esi,sil
    mov     rdi,[rsp+90h]
    add     rdi,rsi
    mov     [rsp+90h],rdi
    mov     rsi,[rsp+88h]
    lea     rsi,[rsi+8]
    mov     [rsp+88h],rsi
    jmp     L1
L18:
    mov     [rsp+40h],rbx
    lea     rax,[r12+rbx*8]
    mov     [rsp+30h],r12
    mov     r12,rdx
L19:
    mov     rdx,[rsp+88h]
    cmp     rdx,rax
    jae     L24
    mov     edx,[rdx]
    mov     esi,[r13]
    cmp     edx,esi
    setb    dl
    mov     [rsp+46h],dl
    mov     rsi,[rsp+98h]
    lea     rsi,[rsi-8]
    mov     [rsp+98h],rsi
    test    dl,dl
    je      L20
    mov     rdi,[rsp+80h]
    jmp     L21
L20:
    mov     rdi,rsi
L21:
    mov     rsi,[rsp+90h]
    lea     rdi,[rdi+rsi*8]
    mov     rsi,[rsp+88h]
    test    rsi,3
    jne     L44
    test    rsi,rsi
    je      L44
    test    rdi,3
    jne     L44
    test    rdi,rdi
    je      L44
    cmp     rsi,rdi
    jae     L22
    mov     r8,rdi
    sub     r8,rsi
    jmp     L23
L22:
    mov     r8,rsi
    sub     r8,rdi
L23:
    cmp     r8,8
    jb      L44
    mov     r8d,[rsi]
    mov     esi,[rsi+4]
    mov     [rdi],r8d
    mov     [rdi+4],esi
    movzx   edx,dl
    mov     rsi,[rsp+90h]
    add     rsi,rdx
    mov     [rsp+90h],rsi
    mov     rdx,[rsp+88h]
    lea     rdx,[rdx+8]
    mov     [rsp+88h],rdx
    jmp     L19
L24:
    cmp     rbx,r14
    jne     L31
    mov     [rsp+40h],rcx
    mov     rsi,[rsp+90h]
    test    rsi,rsi
    jne     L25
    mov     eax,1
    jmp     L26
L25:
    mov     eax,0
L26:
    test    rcx,3
    jne     L46
    test    al,al
    jne     L27
    test    rcx,rcx
    je      L46
L27:
    test    rbp,3
    jne     L46
    test    al,al
    jne     L28
    test    rbp,rbp
    je      L46
L28:
    mov     eax,8
    mul     rsi
    jb      L45
    cmp     rcx,rbp
    jae     L29
    mov     rdx,rbp
    sub     rdx,rcx
    jmp     L30
L29:
    mov     rdx,rcx
    sub     rdx,rbp
L30:
    cmp     rax,rdx
    ja      L46
    imul    rsi,8
    mov     [rsp+10h],rbp
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+180h]
    mov     esi,0FFFFFE90h
    mov     edx,0FFFFFEC0h
    mov     ecx,0FFFFFE98h
    call    ryo_h_Memcpy
    mov     rax,[rsp+90h]
    mov     r11,r14
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+40h],rax
    mov     rcx,rax
    mov     eax,0
    jmp     L36
L31:
    lea     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+98h]
    lea     rax,[rax-8]
    mov     [rsp+98h],rax
    test    r15b,r15b
    je      L32
    mov     rdx,[rsp+80h]
    jmp     L33
L32:
    mov     rdx,rax
L33:
    mov     rax,[rsp+90h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+88h]
    test    rax,3
    jne     L47
    test    rax,rax
    je      L47
    test    rdx,3
    jne     L47
    test    rdx,rdx
    je      L47
    cmp     rax,rdx
    jae     L34
    mov     rsi,rdx
    sub     rsi,rax
    jmp     L35
L34:
    mov     rsi,rax
    sub     rsi,rdx
L35:
    cmp     rsi,8
    jb      L47
    mov     esi,[rax]
    mov     eax,[rax+4]
    mov     [rdx],esi
    mov     [rdx+4],eax
    movzx   eax,r15b
    mov     rdx,[rsp+90h]
    add     rdx,rax
    mov     [rsp+90h],rdx
    mov     rax,[rsp+88h]
    lea     rax,[rax+8]
    mov     [rsp+88h],rax
    mov     rbx,r14
    mov     [rsp+20h],rcx
    mov     [rsp+28h],r12
    mov     r12,[rsp+30h]
    jmp     L0
L36:
    cmp     rax,rcx
    jae     L39
    lea     rdx,[rax+1]
    mov     [rsp+40h],rax
    lea     rsi,[r14-1]
    sub     rsi,rax
    lea     rsi,[r12+rsi*8]
    mov     rdi,[rsp+90h]
    add     rdi,rax
    lea     rax,[rbp+rdi*8]
    test    rsi,3
    jne     L48
    test    rsi,rsi
    je      L48
    test    rax,3
    jne     L48
    test    rax,rax
    je      L48
    cmp     rsi,rax
    jae     L37
    mov     rdi,rax
    sub     rdi,rsi
    jmp     L38
L37:
    mov     rdi,rsi
    sub     rdi,rax
L38:
    cmp     rdi,8
    jb      L48
    mov     edi,[rsi]
    mov     esi,[rsi+4]
    mov     [rax],edi
    mov     [rax+4],esi
    mov     rax,rdx
    jmp     L36
L39:
    mov     rax,[rsp+90h]
    mov     rbx,[rsp+78h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+68h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+50h]
    add     rsp,188h
    ret
L40:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L41:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L42:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L43:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L44:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L45:
    lea     rdi,[image.k9354]
    mov     esi,3Dh
    call    image.sym46
    ud2
L46:
    lea     rdi,[image.k8346]
    lea     rcx,[k15]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L47:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k6640]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L48:
    lea     rdi,[image.k8346]
    lea     rcx,[k19]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L49:
    lea     rdi,[rsp+180h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L50]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L50:
    .long   L51
    .long   L52
    .long   L53
    .long   L54
    .long   L55
    .long   L56
L51:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-30h]
    mov     [rsp],r11
    mov     r11,[rdx-0D0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+50h],r11
    mov     [rdx-108h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-118h],r13
    mov     [rdx-120h],r14
    mov     [rdx-128h],r15
    mov     [rdx-130h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L52:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0D0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     rdx,[rsp+40h]
    lea     rsp,[rsp+60h]
    jmp     L1
L53:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1E0h]
    mov     r11,[rdx-108h]
    mov     [rsp],r11
    mov     r11,[rdx-0E0h]
    mov     [rsp+8],r11
    mov     r11,[rdx-30h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0C8h]
    mov     [rsp+18h],r11
    movzx   r11d,byte ptr [rdx-31h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-0D0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     rax,[rsp]
    mov     r13,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     r12,[rsp+40h]
    lea     rsp,[rsp+60h]
    jmp     L19
L54:
    ret
L55:
    ret
L56:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-1C0h]
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
    mov     [rdx-180h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L36

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0A8h
    mov     [rsp+48h],rdi
    test    rsi,rsi
    jne     L0
    mov     esi,0
    jmp     L12
L0:
    lea     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rdx
    mov     [rsp+40h],rax
    mov     [rsp+20h],rdi
    mov     eax,[rdi]
    mov     [rsp+28h],eax
    mov     [rsp+24h],eax
    mov     [rsp+2Ch],eax
    mov     rax,rdi
    lea     rax,[rax+4]
    lea     rcx,[rsp+2Ch]
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+20h],0
    mov     [rsp+8],rdi
    mov     [rsp+10h],rcx
    lea     rax,[rsi-1]
    lea     rdi,[rdi+rax*4]
L1:
    mov     rax,[rsp+18h]
    cmp     rax,rdi
    jae     L6
    mov     byte ptr [rsp+2Ah],1
    mov     rcx,[rsp+38h]
    mov     eax,[rax]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    al
    mov     rcx,[rsp+40h]
    mov     rcx,[rcx]
    mov     rdx,[rsp+20h]
    lea     rcx,[rcx+rdx*4]
    mov     rdx,[rsp+8]
    test    rcx,3
    jne     L14
    test    rcx,rcx
    je      L14
    test    rdx,3
    jne     L14
    test    rdx,rdx
    je      L14
    mov     r8d,[rcx]
    mov     [rdx],r8d
    mov     rdx,[rsp+18h]
    test    rdx,3
    jne     L15
    test    rdx,rdx
    je      L15
    test    rcx,3
    jne     L15
    cmp     rdx,rcx
    jae     L2
    mov     r8,rcx
    sub     r8,rdx
    jmp     L3
L2:
    mov     r8,rdx
    sub     r8,rcx
L3:
    cmp     r8,4
    jb      L15
    mov     edx,[rdx]
    mov     [rcx],edx
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    movzx   eax,al
    mov     rdx,[rsp+20h]
    add     rdx,rax
    mov     [rsp+20h],rdx
    mov     rax,rcx
    lea     rax,[rax+4]
    mov     [rsp+18h],rax
    mov     rax,[rsp+38h]
    mov     r8d,[rcx+4]
    mov     eax,[rax]
    cmp     r8d,eax
    setb    al
    mov     r8,[rsp+40h]
    mov     r8,[r8]
    lea     r8,[r8+rdx*4]
    test    r8,3
    jne     L16
    test    r8,r8
    je      L16
    test    rcx,3
    jne     L16
    test    rcx,rcx
    je      L16
    mov     edx,[r8]
    mov     [rcx],edx
    mov     rcx,[rsp+18h]
    test    rcx,3
    jne     L17
    test    rcx,rcx
    je      L17
    test    r8,3
    jne     L17
    cmp     rcx,r8
    jae     L4
    mov     rdx,r8
    sub     rdx,rcx
    jmp     L5
L4:
    mov     rdx,rcx
    sub     rdx,r8
L5:
    cmp     rdx,4
    jb      L17
    mov     ecx,[rcx]
    mov     [r8],ecx
    mov     rcx,[rsp+18h]
    mov     [rsp+8],rcx
    movzx   eax,al
    mov     rdx,[rsp+20h]
    add     rdx,rax
    mov     [rsp+20h],rdx
    lea     rcx,[rcx+4]
    mov     [rsp+18h],rcx
    jmp     L1
L6:
    mov     rax,[rsp+48h]
    lea     rax,[rax+rsi*4]
L7:
    mov     rcx,[rsp+18h]
    cmp     rcx,rax
    sete    dl
    mov     [rsp+2Bh],dl
    test    dl,dl
    je      L8
    mov     rdx,[rsp+10h]
    jmp     L9
L8:
    mov     rdx,rcx
L9:
    mov     [rsp+18h],rdx
    mov     rcx,[rsp+38h]
    mov     edx,[rdx]
    mov     ecx,[rcx]
    cmp     edx,ecx
    setb    cl
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+20h]
    lea     rdx,[rdx+rsi*4]
    mov     rsi,[rsp+8]
    test    rdx,3
    jne     L18
    test    rdx,rdx
    je      L18
    test    rsi,3
    jne     L18
    test    rsi,rsi
    je      L18
    mov     edi,[rdx]
    mov     [rsi],edi
    mov     rsi,[rsp+18h]
    test    rsi,3
    jne     L19
    test    rsi,rsi
    je      L19
    test    rdx,3
    jne     L19
    cmp     rsi,rdx
    jae     L10
    mov     rdi,rdx
    sub     rdi,rsi
    jmp     L11
L10:
    mov     rdi,rsi
    sub     rdi,rdx
L11:
    cmp     rdi,4
    jb      L19
    mov     esi,[rsi]
    mov     [rdx],esi
    mov     rdx,[rsp+18h]
    mov     [rsp+8],rdx
    movzx   ecx,cl
    mov     rsi,[rsp+20h]
    add     rsi,rcx
    mov     [rsp+20h],rsi
    lea     rdx,[rdx+4]
    mov     [rsp+18h],rdx
    movzx   ecx,byte ptr [rsp+2Bh]
    test    cl,cl
    je      L13
L12:
    mov     rax,rsi
    add     rsp,0A8h
    ret
L13:
    jmp     L7
L14:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L15:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L16:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L17:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L18:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L19:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
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
    .long   L24
    .long   L25
L21:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-0A0h]
    mov     [rsp],r11
    mov     r11,[rdx-50h]
    mov     [rsp+8],r11
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    lea     rsp,[rsp+40h]
    jmp     L1
L22:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-0A8h]
    mov     [rsp],r11
    mov     rax,[rsp]
    lea     rsp,[rsp+40h]
    jmp     L7
L23:
    ret
L24:
    ret
L25:
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,18h
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
    test    rcx,3
    jne     L2
    test    rcx,rcx
    je      L2
    test    rdx,3
    jne     L2
    test    rdx,rdx
    je      L2
    mov     edi,[rcx]
    mov     [rdx],edi
    mov     rdx,[rsi+10h]
    test    rdx,3
    jne     L3
    test    rdx,rdx
    je      L3
    test    rcx,3
    jne     L3
    cmp     rdx,rcx
    jae     L0
    mov     rdi,rcx
    sub     rdi,rdx
    jmp     L1
L0:
    mov     rdi,rdx
    sub     rdi,rcx
L1:
    cmp     rdi,4
    jb      L3
    mov     edx,[rdx]
    mov     [rcx],edx
    mov     rcx,[rsi+10h]
    mov     [rsi],rcx
    movzx   eax,al
    mov     rdx,[rsi+18h]
    add     rdx,rax
    mov     [rsi+18h],rdx
    lea     rcx,[rcx+4]
    mov     [rsi+10h],rcx
    add     rsp,18h
    ret
L2:
    lea     rdi,[image.k8912]
    lea     rcx,[k1]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L3:
    lea     rdi,[image.k8346]
    lea     rcx,[k3]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
  ; OSR entries
    lea     r11,[L4]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L4:
    .long   L5
L5:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,228h
    mov     [rsp+150h],rbx
    mov     [rsp+148h],r12
    mov     [rsp+140h],r13
    mov     [rsp+138h],r14
    mov     [rsp+130h],r15
    mov     [rsp+128h],rbp
    mov     rbx,rdi
    mov     [rsp+20h],rsi
    mov     [rsp+18h],r8
    mov     [rsp+10h],rdx
L0:
    mov     r11d,20h
    cmp     r11,[rsp+20h]
    jb      L15
    mov     r11,[rsp+20h]
    cmp     r11,2
    jb      L16
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
    je      L54
    cmp     r13,rax
    jb      L54
    lea     r13,[r14+r13*4]
    lea     rax,[r14+rax*4]
    mov     r12,rax
L7:
    cmp     r12,r13
    je      L13
    mov     rax,r12
    lea     rax,[rax-4]
    mov     edx,[r12]
    mov     esi,[r12-4]
    cmp     edx,esi
    setb    dl
    mov     [rsp+5Fh],dl
    test    dl,dl
    je      L12
    mov     edx,[r12]
    mov     [rsp+5Ch],edx
    mov     rbp,rax
    mov     rax,r12
L8:
    test    rbp,3
    jne     L51
    test    rbp,rbp
    je      L51
    test    rax,3
    jne     L51
    test    rax,rax
    je      L51
    cmp     rbp,rax
    jae     L9
    mov     rdx,rax
    sub     rdx,rbp
    jmp     L10
L9:
    mov     rdx,rbp
    sub     rdx,rax
L10:
    cmp     rdx,4
    jb      L51
    mov     edx,[rbp]
    mov     [rax],edx
    cmp     rbp,r14
    je      L11
    mov     rax,rbp
    lea     rax,[rax-4]
    mov     edx,[rsp+5Ch]
    mov     esi,[rbp-4]
    cmp     edx,esi
    jae     L11
    mov     r10,rbp
    mov     rbp,rax
    mov     rax,r10
    jmp     L8
L11:
    lea     rdi,[rsp+5Ch]
    mov     esi,4
    call    image.fn155
    test    al,al
    je      L52
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    test    al,al
    je      L52
    lea     rdi,[rsp+5Ch]
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L52
    mov     eax,[rsp+5Ch]
    mov     [rbp],eax
L12:
    lea     r12,[r12+4]
    jmp     L7
L13:
    cmp     byte ptr [rsp+28h],0
    jne     L16
    cmp     r14,rbx
    je      L14
    lea     r8,[image.k2208]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+20h]
    call    image.fn187
    lea     rdx,[rsp+68h]
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     rcx,[rsp+18h]
    call    qword ptr [image.fn78.slot]
    lea     r9,[image.k2232]
    lea     rdi,[rsp+68h]
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+20h]
    call    image.fn180
    mov     rdx,[rsp+20h]
    imul    rdx,4
    lea     rsi,[rsp+68h]
    mov     rdi,rbx
    call    ryo_hr_Memcpy
    jmp     L16
L14:
    lea     rax,[rbx+r15*4]
    mov     rdx,[rsp+20h]
    sub     rdx,r15
    test    rax,3
    jne     L55
    test    rax,rax
    je      L55
    mov     r14,rax
    mov     r13,rdx
    jmp     L3
L15:
    test    ecx,ecx
    jne     L17
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
L16:
    mov     rbx,[rsp+150h]
    mov     r12,[rsp+148h]
    mov     r13,[rsp+140h]
    mov     r14,[rsp+138h]
    mov     r15,[rsp+130h]
    mov     rbp,[rsp+128h]
    add     rsp,228h
    ret
L17:
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
    jae     L21
    mov     ecx,[rbx]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r14]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L19
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L18
    mov     rcx,r14
    jmp     L20
L18:
    mov     rcx,r13
    jmp     L20
L19:
    mov     rcx,rbx
L20:
    cmp     rcx,rbx
    jb      L56
    sub     rcx,rbx
    shr     rcx,2
    mov     [rsp+40h],rcx
    jmp     L25
L21:
    mov     r15,rax
    shr     r15,3
    mov     rbp,r15
    imul    rbp,4
    lea     rsi,[rbx+rbp*4]
    mov     r12,r15
    imul    r12,7
    lea     rdx,[rbx+r12*4]
    mov     rdi,rbx
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     [rsp+38h],rax
    lea     rsi,[r13+rbp*4]
    lea     rdx,[r13+r12*4]
    mov     rdi,r13
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r13,rax
    lea     rsi,[r14+rbp*4]
    lea     rdx,[r14+r12*4]
    mov     rdi,r14
    mov     rcx,r15
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r11,[rsp+38h]
    mov     ecx,[r11]
    mov     edx,[r13]
    cmp     ecx,edx
    setb    sil
    mov     edi,[rax]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L23
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L22
    jmp     L24
L22:
    mov     rax,r13
    jmp     L24
L23:
    mov     rax,[rsp+38h]
L24:
    cmp     rax,rbx
    jb      L57
    sub     rax,rbx
    shr     rax,2
    mov     [rsp+40h],rax
L25:
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+20h]
    jae     L58
    mov     r11,[rsp+10h]
    cmp     r11,0
    je      L38
    mov     r10,[rsp+40h]
    lea     rax,[rbx+r10*4]
    mov     r11,[rsp+10h]
    mov     edx,[r11]
    mov     esi,[rax]
    cmp     edx,esi
    jb      L38
    mov     r10,[rsp+18h]
    mov     [rsp+180h],r10
    test    rbx,3
    jne     L59
    test    rbx,rbx
    je      L59
    mov     edx,[rbx]
    test    rax,3
    jne     L60
    test    rax,rax
    je      L60
    test    rbx,3
    jne     L60
    mov     esi,[rax]
    mov     [rbx],esi
    test    rax,3
    jne     L61
    mov     [rax],edx
    test    rbx,3
    jne     L62
    mov     rax,rbx
    lea     rax,[rax+4]
    mov     rdx,[rsp+20h]
    sub     rdx,1
    test    rax,3
    jne     L63
    test    rax,rax
    je      L63
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rdx,r10
    ja      L63
    mov     [rsp+0E8h],rax
    lea     rsi,[rsp+0E8h]
    mov     [rsp+0F8h],rsi
    mov     esi,[rbx+4]
    mov     [rsp+0F8h],esi
    mov     [rsp+0FCh],esi
    mov     rsi,rbx
    lea     rsi,[rsi+8]
    lea     rdi,[rsp+0FCh]
    lea     r8,[rdx-1]
    lea     r8,[rax+r8*4]
    mov     r9d,0
    mov     r12,rax
    mov     eax,0
L26:
    cmp     rsi,r8
    jae     L31
    mov     byte ptr [rsp+0FAh],1
    mov     r13d,[rbx]
    mov     r14d,[rsi]
    cmp     r13d,r14d
    setb    r13b
    xor     r13d,1
    mov     r14,[rsp+0E8h]
    mov     r15d,eax
    mov     ebp,r9d
    mov     rcx,rbp
    shl     rcx,20h
    or      rcx,r15
    lea     r14,[r14+rcx*4]
    test    r14,3
    jne     L64
    test    r14,r14
    je      L64
    test    r12,3
    jne     L64
    test    r12,r12
    je      L64
    mov     ecx,[r14]
    mov     [r12],ecx
    test    rsi,3
    jne     L65
    test    rsi,rsi
    je      L65
    test    r14,3
    jne     L65
    cmp     rsi,r14
    jae     L27
    mov     rcx,r14
    sub     rcx,rsi
    jmp     L28
L27:
    mov     rcx,rsi
    sub     rcx,r14
L28:
    cmp     rcx,4
    jb      L65
    mov     ecx,[rsi]
    mov     [r14],ecx
    movzx   r13d,r13b
    shl     rbp,20h
    or      r15,rbp
    add     r15,r13
    mov     rcx,rsi
    lea     rcx,[rcx+4]
    mov     r13d,[rbx]
    mov     r14d,[rsi+4]
    cmp     r13d,r14d
    setb    r13b
    xor     r13d,1
    mov     r14,[rsp+0E8h]
    lea     r14,[r14+r15*4]
    test    r14,3
    jne     L66
    test    r14,r14
    je      L66
    test    rsi,3
    jne     L66
    mov     ebp,[r14]
    mov     [rsi],ebp
    test    rcx,3
    jne     L67
    test    rcx,rcx
    je      L67
    test    r14,3
    jne     L67
    cmp     rcx,r14
    jae     L29
    mov     rbp,r14
    sub     rbp,rcx
    jmp     L30
L29:
    mov     rbp,rcx
    sub     rbp,r14
L30:
    cmp     rbp,4
    jb      L67
    mov     ebp,[rsi+4]
    mov     [r14],ebp
    movzx   r13d,r13b
    add     r15,r13
    mov     r13,r15
    shr     r13,20h
    mov     r14,rsi
    lea     r14,[r14+8]
    mov     rsi,r14
    mov     rax,r15
    mov     r9,r13
    mov     r12,rcx
    jmp     L26
L31:
    mov     rcx,[rsp+0E8h]
    lea     rcx,[rcx+rdx*4]
L32:
    cmp     rsi,rcx
    sete    dl
    mov     [rsp+0FBh],dl
    test    dl,dl
    je      L33
    mov     rdx,rdi
    jmp     L34
L33:
    mov     rdx,rsi
L34:
    mov     esi,[rbx]
    mov     r8d,[rdx]
    cmp     esi,r8d
    setb    sil
    xor     esi,1
    mov     r8,[rsp+0E8h]
    mov     eax,eax
    mov     r9d,r9d
    mov     r13,r9
    shl     r13,20h
    or      r13,rax
    lea     r8,[r8+r13*4]
    test    r8,3
    jne     L68
    test    r8,r8
    je      L68
    test    r12,3
    jne     L68
    test    r12,r12
    je      L68
    mov     r13d,[r8]
    mov     [r12],r13d
    test    rdx,3
    jne     L69
    test    rdx,rdx
    je      L69
    test    r8,3
    jne     L69
    cmp     rdx,r8
    jae     L35
    mov     r12,r8
    sub     r12,rdx
    jmp     L36
L35:
    mov     r12,rdx
    sub     r12,r8
L36:
    cmp     r12,4
    jb      L69
    mov     r12d,[rdx]
    mov     [r8],r12d
    movzx   esi,sil
    shl     r9,20h
    or      rax,r9
    add     rax,rsi
    mov     rsi,rax
    shr     rsi,20h
    mov     r8,rdx
    lea     r8,[r8+4]
    movzx   r9d,byte ptr [rsp+0FBh]
    test    r9b,r9b
    jne     L37
    mov     r9,rsi
    mov     rsi,r8
    mov     r12,rdx
    jmp     L32
L37:
    cmp     rax,[rsp+20h]
    jae     L73
    lea     rcx,[rbx+rax*4]
    test    rbx,3
    jne     L70
    mov     edx,[rbx]
    test    rcx,3
    jne     L71
    test    rcx,rcx
    je      L71
    test    rbx,3
    jne     L71
    mov     esi,[rcx]
    mov     [rbx],esi
    test    rcx,3
    jne     L72
    mov     [rcx],edx
    lea     r11,[rax+1]
    mov     [rsp+48h],r11
    mov     r11,[rsp+20h]
    cmp     r11,[rsp+48h]
    jb      L94
    mov     rax,[rsp+20h]
    sub     rax,[rsp+48h]
    mov     [rsp+170h],rbx
    mov     r10,[rsp+20h]
    mov     [rsp+178h],r10
    mov     [rsp+168h],rbx
    mov     r10,[rsp+48h]
    lea     rcx,[rbx+r10*4]
    mov     [rsp+160h],rcx
    mov     [rsp+180h],rcx
    mov     rbx,rcx
    mov     [rsp+20h],rax
    mov     rcx,[rsp+30h]
    mov     qword ptr [rsp+10h],0
    jmp     L0
L38:
    mov     r10,[rsp+40h]
    lea     rax,[rbx+r10*4]
    test    rbx,3
    jne     L74
    test    rbx,rbx
    je      L74
    mov     ecx,[rbx]
    test    rax,3
    jne     L75
    test    rax,rax
    je      L75
    test    rbx,3
    jne     L75
    mov     edx,[rax]
    mov     [rbx],edx
    test    rax,3
    jne     L76
    mov     [rax],ecx
    test    rbx,3
    jne     L77
    mov     rax,rbx
    lea     rax,[rax+4]
    mov     rcx,[rsp+20h]
    sub     rcx,1
    test    rax,3
    jne     L78
    test    rax,rax
    je      L78
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rcx,r10
    ja      L78
    mov     [rsp+108h],rax
    lea     rdx,[rsp+108h]
    mov     [rsp+118h],rdx
    mov     edx,[rbx+4]
    mov     [rsp+118h],edx
    mov     [rsp+11Ch],edx
    mov     rdx,rbx
    lea     rdx,[rdx+8]
    lea     rsi,[rsp+11Ch]
    lea     r8,[rcx-1]
    lea     r8,[rax+r8*4]
    mov     r9d,0
    mov     r12,rax
    mov     eax,0
L39:
    cmp     rdx,r8
    jae     L44
    mov     byte ptr [rsp+11Ah],1
    mov     r13d,[rdx]
    mov     r14d,[rbx]
    cmp     r13d,r14d
    setb    r13b
    mov     r14,[rsp+108h]
    mov     r15d,eax
    mov     ebp,r9d
    mov     rdi,rbp
    shl     rdi,20h
    or      rdi,r15
    lea     r14,[r14+rdi*4]
    test    r14,3
    jne     L79
    test    r14,r14
    je      L79
    test    r12,3
    jne     L79
    test    r12,r12
    je      L79
    mov     edi,[r14]
    mov     [r12],edi
    test    rdx,3
    jne     L80
    test    rdx,rdx
    je      L80
    test    r14,3
    jne     L80
    cmp     rdx,r14
    jae     L40
    mov     rdi,r14
    sub     rdi,rdx
    jmp     L41
L40:
    mov     rdi,rdx
    sub     rdi,r14
L41:
    cmp     rdi,4
    jb      L80
    mov     edi,[rdx]
    mov     [r14],edi
    movzx   r13d,r13b
    shl     rbp,20h
    or      r15,rbp
    add     r15,r13
    mov     rdi,rdx
    lea     rdi,[rdi+4]
    mov     r13d,[rdx+4]
    mov     r14d,[rbx]
    cmp     r13d,r14d
    setb    r13b
    mov     r14,[rsp+108h]
    lea     r14,[r14+r15*4]
    test    r14,3
    jne     L81
    test    r14,r14
    je      L81
    test    rdx,3
    jne     L81
    mov     ebp,[r14]
    mov     [rdx],ebp
    test    rdi,3
    jne     L82
    test    rdi,rdi
    je      L82
    test    r14,3
    jne     L82
    cmp     rdi,r14
    jae     L42
    mov     rbp,r14
    sub     rbp,rdi
    jmp     L43
L42:
    mov     rbp,rdi
    sub     rbp,r14
L43:
    cmp     rbp,4
    jb      L82
    mov     ebp,[rdx+4]
    mov     [r14],ebp
    movzx   r13d,r13b
    add     r15,r13
    mov     r13,r15
    shr     r13,20h
    mov     r14,rdx
    lea     r14,[r14+8]
    mov     rdx,r14
    mov     rax,r15
    mov     r9,r13
    mov     r12,rdi
    jmp     L39
L44:
    mov     rdi,[rsp+108h]
    lea     rdi,[rdi+rcx*4]
L45:
    cmp     rdx,rdi
    sete    cl
    mov     [rsp+11Bh],cl
    test    cl,cl
    je      L46
    mov     rcx,rsi
    jmp     L47
L46:
    mov     rcx,rdx
L47:
    mov     edx,[rcx]
    mov     r8d,[rbx]
    cmp     edx,r8d
    setb    dl
    mov     r8,[rsp+108h]
    mov     eax,eax
    mov     r9d,r9d
    mov     r13,r9
    shl     r13,20h
    or      r13,rax
    lea     r8,[r8+r13*4]
    test    r8,3
    jne     L83
    test    r8,r8
    je      L83
    test    r12,3
    jne     L83
    test    r12,r12
    je      L83
    mov     r13d,[r8]
    mov     [r12],r13d
    test    rcx,3
    jne     L84
    test    rcx,rcx
    je      L84
    test    r8,3
    jne     L84
    cmp     rcx,r8
    jae     L48
    mov     r12,r8
    sub     r12,rcx
    jmp     L49
L48:
    mov     r12,rcx
    sub     r12,r8
L49:
    cmp     r12,4
    jb      L84
    mov     r12d,[rcx]
    mov     [r8],r12d
    movzx   edx,dl
    shl     r9,20h
    or      rax,r9
    add     rax,rdx
    mov     rdx,rax
    shr     rdx,20h
    mov     r8,rcx
    lea     r8,[r8+4]
    movzx   r9d,byte ptr [rsp+11Bh]
    test    r9b,r9b
    jne     L50
    mov     r9,rdx
    mov     rdx,r8
    mov     r12,rcx
    jmp     L45
L50:
    cmp     rax,[rsp+20h]
    jae     L88
    lea     rcx,[rbx+rax*4]
    test    rbx,3
    jne     L85
    mov     edx,[rbx]
    test    rcx,3
    jne     L86
    test    rcx,rcx
    je      L86
    test    rbx,3
    jne     L86
    mov     esi,[rcx]
    mov     [rbx],esi
    test    rcx,3
    jne     L87
    mov     [rcx],edx
    test    rbx,3
    jne     L89
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rax,r10
    ja      L89
    mov     rdx,[rsp+20h]
    sub     rdx,rax
    test    rcx,3
    jne     L90
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     rdx,r10
    ja      L90
    mov     [rsp+168h],rbx
    mov     [rsp+170h],rax
    mov     [rsp+178h],rcx
    mov     [rsp+180h],rdx
    cmp     rdx,1
    jb      L93
    test    rcx,3
    jne     L91
    mov     r12,rcx
    lea     r12,[r12+4]
    lea     r13,[rdx-1]
    test    r12,3
    jne     L92
    test    r12,r12
    je      L92
    mov     [rsp+158h],rcx
    mov     qword ptr [rsp+160h],1
    mov     [rsp+168h],r12
    mov     [rsp+170h],r13
    mov     [rsp+178h],rcx
    mov     qword ptr [rsp+180h],1
    mov     [rsp+170h],rcx
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+18h]
    call    fn15
    mov     rax,[rsp+170h]
    mov     rbx,r12
    mov     [rsp+20h],r13
    mov     rcx,[rsp+30h]
    mov     [rsp+10h],rax
    jmp     L0
L51:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k1728]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
    jmp     L53
    jmp     L53
    jmp     L53
L52:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k10504]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L53:
    call    image.sym10
    ud2
L54:
    lea     rdi,[rsp+220h]
    call    ryo_h_Abort
    ud2
L55:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k2184]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L56:
    lea     rdi,[image.k7575]
    lea     rcx,[image.k1536]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L57:
    lea     rdi,[image.k7575]
    lea     rcx,[image.k1584]
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L58:
    lea     rdi,[image.k9133]
    lea     rcx,[image.k1632]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L59:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k496]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L60:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L61:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k544]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L62:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L63:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L64:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5392]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L65:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5416]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L66:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5392]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L67:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5416]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L68:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5392]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L69:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5416]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L70:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k496]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L71:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L72:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k544]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L73:
    lea     rdi,[rsp+220h]
    call    ryo_h_Abort
    ud2
L74:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k496]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L75:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L76:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k544]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L77:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L78:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L79:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L80:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L81:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L82:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L83:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k5440]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L84:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k5464]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L85:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k496]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L86:
    lea     rdi,[image.k8912]
    lea     rcx,[image.k520]
    mov     esi,1BBh
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L87:
    lea     rdi,[image.k8346]
    lea     rcx,[image.k544]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L88:
    lea     rdi,[rsp+220h]
    call    ryo_h_Abort
    ud2
L89:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L90:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L91:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L92:
    lea     rdi,[image.k9694]
    lea     rcx,[image.k6360]
    mov     esi,237h
    mov     edx,0
    movzx   edx,dl
    call    image.sym45
    ud2
L93:
    lea     rdi,[image.k6296]
    lea     rdx,[k11]
    mov     esi,13h
    call    image.sym6
    ud2
L94:
    lea     rcx,[k16]
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+20h]
    call    sym17
    ud2
  ; OSR entries
    lea     r11,[L95]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L95:
    .long   L96
L96:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-250h]
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
    mov     [rdx-200h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-210h],r11
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
    sub     rsp,108h
    mov     [rsp+78h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+68h],r13
    mov     [rsp+60h],r14
    mov     [rsp+58h],r15
    mov     [rsp+50h],rbp
    mov     rbx,rdi
    mov     [rsp+20h],rsi
    mov     r13,rdx
    mov     r11,[rsp+20h]
    cmp     r11,10h
    ja      L4
    mov     qword ptr [rsp+80h],1
    mov     r10,[rsp+20h]
    mov     [rsp+88h],r10
    mov     rax,rbx
    mov     rcx,[rsp+20h]
L0:
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    cmp     rdx,rsi
    jae     L1
    lea     rsi,[rdx+1]
    mov     [rsp+80h],rsi
    mov     rsi,rdx
    mov     edx,1
    jmp     L2
L1:
    mov     edx,0
L2:
    test    rdx,rdx
    je      L24
L3:
    test    rsi,rsi
    jbe     L0
    lea     rdi,[rsi-1]
    cmp     rdi,rcx
    jae     L41
    mov     edx,[rax+rdi*4]
    cmp     rsi,rcx
    jae     L42
    lea     r8,[rax+rsi*4]
    mov     r9d,[r8]
    cmp     r9d,edx
    jae     L0
    lea     rdx,[rsi-1]
    cmp     rdx,rcx
    jae     L28
    lea     r14,[rax+rdx*4]
    test    r14,3
    jne     L25
    test    r14,r14
    je      L25
    mov     r15d,[r14]
    test    r8,3
    jne     L26
    test    r8,r8
    je      L26
    test    r14,3
    jne     L26
    mov     [r14],r9d
    test    r8,3
    jne     L27
    mov     [r8],r15d
    lea     r8,[rsi-1]
    mov     rsi,r8
    jmp     L3
L4:
    mov     r11,[rsp+20h]
    shr     r11,1
    mov     [rsp+28h],r11
    mov     r11,[rsp+20h]
    cmp     r11,[rsp+28h]
    jb      L29
    mov     rdi,rbx
    mov     rsi,[rsp+28h]
    mov     rdx,r13
    call    fn18
    mov     rax,[rsp+20h]
    sub     rax,[rsp+28h]
    mov     r10,[rsp+28h]
    lea     r8,[rbx+r10*4]
    mov     rdi,r8
    mov     rsi,rax
    mov     rdx,r13
    call    fn18
    mov     qword ptr [r13+10h],0
    mov     qword ptr [rsp+38h],0
    mov     r11,[rsp+28h]
    mov     [rsp+30h],r11
    mov     r15,[rsp+28h]
    mov     rbp,rbx
    mov     r11,[rsp+20h]
    mov     [rsp+40h],r11
    mov     r14,r13
L5:
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+30h]
    jae     L9
    cmp     r15,[rsp+40h]
    jae     L9
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+40h]
    jae     L43
    mov     r10,[rsp+38h]
    mov     r13d,[rbp+r10*4]
    mov     ebx,[rbp+r15*4]
    cmp     ebx,r13d
    jb      L7
    mov     r12,[r14+10h]
    mov     rax,[r14]
    cmp     r12,rax
    jne     L6
    mov     rdi,r14
    call    qword ptr [image.fn160.slot]
L6:
    mov     rax,[r14+8]
    lea     rax,[rax+r12*4]
    mov     [rax],r13d
    add     r12,1
    mov     [r14+10h],r12
    mov     [rsp+8],rax
    mov     rax,[rsp+38h]
    add     rax,1
    mov     [rsp+38h],rax
    jmp     L5
L7:
    mov     r12,[r14+10h]
    mov     rax,[r14]
    cmp     r12,rax
    jne     L8
    mov     rdi,r14
    call    qword ptr [image.fn160.slot]
L8:
    mov     rax,[r14+8]
    lea     rax,[rax+r12*4]
    mov     [rax],ebx
    add     r12,1
    mov     [r14+10h],r12
    mov     [rsp+8],rax
    lea     rax,[r15+1]
    mov     r15,rax
    jmp     L5
L9:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+38h]
    jb      L30
    mov     rax,[rsp+30h]
    sub     rax,[rsp+38h]
    mov     r11,[rsp+40h]
    cmp     r11,[rsp+30h]
    jb      L30
    mov     r10,[rsp+38h]
    lea     rbx,[rbp+r10*4]
    lea     rax,[rbx+rax*4]
    cmp     rax,rbx
    jb      L31
    sub     rax,rbx
    mov     r12,rax
    shr     r12,2
    test    rbx,3
    jne     L32
    test    rbx,rbx
    je      L32
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L32
    mov     rax,[r14+10h]
    mov     r8,[r14]
    sub     r8,rax
    cmp     r8,r12
    jae     L10
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r12
    mov     ecx,4
    mov     r8d,4
    call    image.sym44
L10:
    mov     rax,[r14+10h]
    test    r12,r12
    jbe     L13
    mov     r8,[r14+8]
    lea     r8,[r8+rax*4]
    test    rbx,3
    jne     L33
    test    r8,3
    jne     L33
    test    r8,r8
    je      L33
    mov     rax,r12
    imul    rax,4
    cmp     rbx,r8
    jae     L11
    mov     r9,r8
    sub     r9,rbx
    jmp     L12
L11:
    mov     r9,rbx
    sub     r9,r8
L12:
    cmp     rax,r9
    ja      L33
    mov     rax,r12
    imul    rax,4
    mov     rdi,r8
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
L13:
    mov     rax,[r14+10h]
    add     rax,r12
    mov     [r14+10h],rax
    mov     r11,[rsp+40h]
    cmp     r11,r15
    jb      L34
    mov     r8,[rsp+40h]
    sub     r8,r15
    lea     rbx,[rbp+r15*4]
    lea     r8,[rbx+r8*4]
    cmp     r8,rbx
    jb      L35
    sub     r8,rbx
    mov     r12,r8
    shr     r12,2
    test    rbx,3
    jne     L36
    test    rbx,rbx
    je      L36
    mov     r10,1FFFFFFFFFFFFFFFh
    cmp     r12,r10
    ja      L36
    mov     r8,[r14]
    sub     r8,rax
    cmp     r8,r12
    jae     L14
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r12
    mov     ecx,4
    mov     r8d,4
    call    image.sym44
L14:
    mov     rax,[r14+10h]
    test    r12,r12
    jbe     L17
    mov     r8,[r14+8]
    lea     r8,[r8+rax*4]
    test    rbx,3
    jne     L37
    test    r8,3
    jne     L37
    test    r8,r8
    je      L37
    mov     rax,r12
    imul    rax,4
    cmp     rbx,r8
    jae     L15
    mov     r9,r8
    sub     r9,rbx
    jmp     L16
L15:
    mov     r9,rbx
    sub     r9,r8
L16:
    cmp     rax,r9
    ja      L37
    mov     rax,r12
    imul    rax,4
    mov     rdi,r8
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
L17:
    mov     rax,[r14+10h]
    add     rax,r12
    mov     [r14+10h],rax
    mov     r8,[r14+8]
    mov     r11,[rsp+40h]
    cmp     r11,rax
    jne     L40
    mov     r11,[rsp+40h]
    cmp     r11,0
    jne     L18
    mov     r9d,1
    jmp     L19
L18:
    mov     r9d,0
L19:
    test    r8,3
    jne     L39
    test    r9b,r9b
    jne     L20
    test    r8,r8
    je      L39
L20:
    test    rbp,3
    jne     L39
    test    r9b,r9b
    jne     L21
    test    rbp,rbp
    je      L39
L21:
    mov     eax,4
    mul     qword ptr [rsp+40h]
    mov     r9,rax
    jb      L38
    cmp     r8,rbp
    jae     L22
    mov     rbx,rbp
    sub     rbx,r8
    jmp     L23
L22:
    mov     rbx,r8
    sub     rbx,rbp
L23:
    cmp     r9,rbx
    ja      L39
    mov     r9,[rsp+40h]
    imul    r9,4
    mov     rdi,rbp
    mov     rsi,r8
    mov     rdx,r9
    call    ryo_hr_Memcpy
L24:
    mov     rbx,[rsp+78h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+68h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+58h]
    mov     rbp,[rsp+50h]
    add     rsp,108h
    ret
L25:
    lea     r8,[image.k8346]
    lea     r9,[image.k496]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym45
    ud2
L26:
    lea     r8,[image.k8912]
    lea     r9,[image.k520]
    mov     rdi,r8
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym45
    ud2
L27:
    lea     r8,[image.k8346]
    lea     r9,[image.k544]
    mov     rdi,r8
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym45
    ud2
L28:
    lea     r8,[k10]
    mov     rdi,rdx
    mov     rsi,rcx
    mov     rdx,r8
    call    sym5
    ud2
L29:
    lea     rdx,[k16]
    mov     edi,0
    mov     rsi,[rsp+28h]
    mov     rcx,rdx
    mov     rdx,[rsp+20h]
    call    image.sym28
    ud2
    mov     rdx,rax
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    call    ryo_h_Resume
    ud2
    mov     rdx,rax
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    call    ryo_h_Resume
    ud2
L30:
    lea     rdx,[k37]
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rcx,rdx
    mov     rdx,[rsp+40h]
    call    image.sym28
    ud2
L31:
    lea     rdx,[image.k7575]
    lea     r8,[image.k6664]
    mov     rdi,rdx
    mov     esi,193h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L32:
    lea     rdx,[image.k9415]
    lea     r8,[image.k6712]
    mov     rdi,rdx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L33:
    lea     rdx,[image.k8346]
    lea     r8,[image.k7112]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L34:
    lea     rdx,[k40]
    mov     rdi,r15
    mov     rsi,[rsp+40h]
    mov     rcx,rdx
    mov     rdx,[rsp+40h]
    call    image.sym28
    ud2
L35:
    lea     rdx,[image.k7575]
    lea     r8,[image.k6664]
    mov     rdi,rdx
    mov     esi,193h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L36:
    lea     rdx,[image.k9415]
    lea     r8,[image.k6712]
    mov     rdi,rdx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L37:
    lea     rdx,[image.k8346]
    lea     r8,[image.k7112]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L38:
    lea     rdx,[image.k9354]
    mov     rdi,rdx
    mov     esi,3Dh
    call    image.sym46
    ud2
L39:
    lea     rdx,[image.k8346]
    lea     r8,[image.k568]
    mov     rdi,rdx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym45
    ud2
L40:
    lea     rdx,[k44]
    mov     rdi,[rsp+40h]
    mov     rsi,rax
    call    image.sym21
    ud2
L41:
    lea     rdx,[k4]
    mov     rsi,rcx
    call    sym5
    ud2
L42:
    lea     rdx,[k6]
    mov     rdi,rsi
    mov     rsi,rcx
    call    sym5
    ud2
L43:
    lea     rdx,[k23]
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+40h]
    call    sym5
    ud2
  ; OSR entries
    lea     r11,[L44]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L44:
    .long   L45
    .long   L46
    .long   L47
L45:
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
    lea     rsp,[rsp+280h]
    jmp     L0
L46:
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
    lea     rsp,[rsp+290h]
    jmp     L3
L47:
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
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r14,[rsp+28h]
    lea     rsp,[rsp+2A0h]
    jmp     L5

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
    sub     rsp,60h
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
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     [rsp+8],bl
    lea     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+16]
    call    qword ptr [sym0]
    mov     rax,[rsp+48h]
    mov     [rsp+58h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+28]
    call    qword ptr [sym4]
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+40]
    call    qword ptr [sym2]
    mov     rax,[rsp+58h]
    add     rsp,60h
    pop     rbx
    ret
    call    sym5
    ud2
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
    mov     eax,eax
    mov     ecx,ecx
    shl     rcx,20h
    or      rax,rcx
    mov     [rdx+rsi*8],rax
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
    mov     [rax+rdx*4],ecx
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
    jne     L2
    lea     rax,[r13-1]
    and     rax,rbx
    test    rax,rax
    jne     L6
    test    r14b,r14b
    je      L1
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L3
    lea     rax,[r13-1]
    and     rax,r12
    test    rax,rax
    jne     L7
L0:
    add     rsp,10h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L1:
    test    rbx,rbx
    je      L5
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L4
    sub     r13,1
    mov     rax,r12
    and     rax,r13
    test    rax,rax
    jne     L7
    test    r12,r12
    je      L5
    jmp     L0
L2:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
L3:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
L4:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L8
L5:
    lea     rdi,[k1]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L6:
    jmp     L5
    jmp     L8
L7:
    jmp     L5
L8:
    call    sym6
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
    .long   L17
    .long   L18
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
L17:
    ret
L18:
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
    jne     L6
    lea     rax,[r14-1]
    and     rax,rbx
    test    rax,rax
    jne     L10
    test    bpl,bpl
    jne     L2
    test    rbx,rbx
    je      L9
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L7
    sub     r14,1
    mov     rax,r12
    and     rax,r14
    test    rax,rax
    jne     L11
    test    bpl,bpl
    jne     L3
    test    r12,r12
    je      L9
L3:
    mov     rax,r13
    mul     r15
    jb      L8
    cmp     rbx,r12
    jae     L4
    mov     rcx,r12
    sub     rcx,rbx
    jmp     L5
L4:
    sub     rbx,r12
    mov     rcx,rbx
L5:
    cmp     rax,rcx
    ja      L9
    add     rsp,18h
    pop     rbp
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L6:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
L7:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
L8:
    lea     rdi,[image.k9354]
    mov     esi,3Dh
    call    image.sym46
    ud2
    jmp     L12
    jmp     L12
L9:
    lea     rdi,[k3]
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    sym5
    ud2
L10:
    jmp     L9
L11:
    jmp     L9
L12:
    call    sym6
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
L22:
    ret
L23:
    ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    sub     rsp,18h
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
    jne     L3
    sub     r13,1
    mov     rax,rbx
    and     rax,r13
    test    rax,rax
    jne     L5
    test    rbx,rbx
    je      L4
    test    r12,r12
    je      L1
    mov     rax,7FFFFFFFFFFFFFFFh
    xor     edx,edx
    div     r12
    jmp     L2
L0:
    add     rsp,10h
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret
L1:
    mov     rax,0FFFFFFFFFFFFFFFFh
L2:
    cmp     r14,rax
    jbe     L0
    jmp     L4
L3:
    lea     rdi,[image.k6432]
    lea     rdx,[image.k6480]
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L6
L4:
    lea     rdi,[k1]
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    sym3
    ud2
L5:
    jmp     L4
L6:
    call    sym4
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
    .long   L11
    .long   L12
    .long   L13
    .long   L14
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
L13:
    ret
L14:
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

