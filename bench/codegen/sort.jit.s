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
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rcx,[rdi+8]
    mov     rdx,[rdi+10h]
    lea     rsi,[k0]
    cmp     rdx,0
    jne     L0
    mov     edi,1
    jmp     L1
L0:
    mov     edi,0
L1:
    mov     r8,rax
    and     r8,3
    cmp     r8,0
    je      L6
    jmp     L9
L2:
    mov     r8,rcx
    and     r8,3
    cmp     r8,0
    je      L7
    jmp     L9
L3:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     rdx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L8
    cmp     rax,rcx
    jae     L4
    mov     r9,rcx
    sub     r9,rax
    jmp     L5
L4:
    mov     r9,rax
    sub     r9,rcx
L5:
    cmp     r8,r9
    ja      L9
    mov     r8,rdx
    imul    r8,4
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,r8
    call    ryo_hr_Memcpy
    add     rsp,18h
    ret
L6:
    test    dil,dil
    jne     L2
    cmp     rax,0
    je      L9
    jmp     L2
L7:
    test    dil,dil
    jne     L3
    cmp     rcx,0
    je      L9
    jmp     L3
L8:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L9:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym49
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
    mov     rcx,rax
    add     rcx,1
    mov     [rsp+40h],rcx
    mov     rcx,rax
    mov     eax,1
    jmp     L2
L1:
    mov     eax,0
L2:
    cmp     rax,0
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
    sub     rsp,78h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     rax,[rdx]
    mov     rcx,[rdx+8]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rcx
    mov     [rsp+58h],rdx
    cmp     rbx,rsi
    jne     L0
    mov     [rax],rcx
    jmp     L3
L0:
    lea     rax,[k4]
    cmp     rsi,rbx
    jb      L6
    sub     rsi,rbx
    mov     rdi,rsi
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L4
L1:
    lea     rdx,[rsp+48h]
    lea     rsi,[r12+r13*4]
    mov     rdi,rdx
    call    fn1
    lea     rdx,[k9]
    mov     r11,r13
    add     r11,1
    jb      L7
    add     r13,1
    cmp     r13,r14
    jne     L5
    mov     rsi,[rsp+50h]
    mov     rdi,[rsp+48h]
    mov     [rdi],rsi
    jmp     L3
L2:
    mov     r12,rsi
    mov     r13,rdi
    mov     r14,r8
    jmp     L1
L3:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,78h
    ret
L4:
    mov     r12,rbx
    mov     r13d,0
    mov     r14,rcx
    jmp     L1
L5:
    mov     rsi,r12
    mov     rdi,r13
    mov     r8,r14
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
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
    mov     rbx,rax
    jmp     L10
L8:
    lea     rax,[rsp+48h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L11
    jmp     L12
L9:
    mov     [rsp],rbx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
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
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     r12,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+70h]
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
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     rsi,[rsp]
    mov     rdi,[rsp+8]
    mov     r8,[rsp+10h]
    lea     rsp,[rsp+70h]
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
    jne     L0
    mov     rdi,r12
    jmp     L3
L0:
    lea     rax,[k1]
    cmp     rsi,rbx
    jb      L6
    sub     rsi,rbx
    mov     rdi,rsi
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L4
L1:
    lea     rsi,[rsp+68h]
    lea     rdi,[r13+r14*4]
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    fn0
    mov     rdx,rax
    lea     rsi,[k6]
    mov     r11,r14
    add     r11,1
    jb      L7
    add     r14,1
    cmp     r14,r15
    jne     L5
    mov     rdi,rdx
    jmp     L3
L2:
    mov     rdx,rdi
    mov     r13,r8
    mov     r14,r9
    mov     r15,rbp
    jmp     L1
L3:
    mov     rax,rdi
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,98h
    ret
L4:
    mov     rdx,r12
    mov     r13,rbx
    mov     r14d,0
    mov     r15,rcx
    jmp     L1
L5:
    mov     rdi,rdx
    mov     r8,r13
    mov     r9,r14
    mov     rbp,r15
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
    mov     edx,0
    mov     rcx,rsi
    mov     esi,175h
    movzx   edx,dl
    call    image.sym49
    ud2
    jmp     L9
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
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
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+70h]
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
    mov     [rdx-40h],r12
    mov     [rdx-50h],r13
    mov     [rdx-60h],r14
    mov     [rdx-70h],r15
    mov     [rdx-80h],rbp
    mov     rdi,[rsp]
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+70h]
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

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+20h],rdx
    cmp     rdx,rcx
    jb      L0
    lea     rax,[k0]
    lea     rdi,[rsp+8]
    mov     r8,rax
    call    qword ptr [fn1.slot]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     [rbx+18h],rsi
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret
L0:
    lea     rax,[k2]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],9
    mov     [rsp+8],rax
    mov     [rsp+20h],rax
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,r8
    call    sym4
    ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
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
    mov     [rsp+10h],r8
    cmp     r13,r14
    jb      L4
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L5
L0:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L5
    lea     rbp,[r12+r14*8]
    mov     r15,r13
    sub     r15,r14
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L3
    jmp     L6
L1:
    cmp     r12,0
    je      L5
    jmp     L0
L2:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r15,rax
    ja      L6
    mov     [rbx],r12
    mov     [rbx+8],r14
    mov     [rbx+10h],rbp
    mov     [rbx+18h],r15
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L3:
    cmp     rbp,0
    je      L6
    jmp     L2
L4:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L5:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     [rsp+20h],rdx
    cmp     rdx,rcx
    jb      L0
    lea     rax,[k0]
    lea     rdi,[rsp+8]
    mov     r8,rax
    call    qword ptr [fn1.slot]
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     [rbx],rax
    mov     [rbx+8],rcx
    mov     [rbx+10h],rdx
    mov     [rbx+18h],rsi
    mov     rax,rbx
    mov     rbx,[rsp+30h]
    add     rsp,48h
    ret
L0:
    lea     rax,[k2]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],9
    mov     [rsp+8],rax
    mov     [rsp+20h],rax
    mov     rdi,rax
    mov     esi,13h
    mov     rdx,r8
    call    sym4
    ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
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
    mov     [rsp+10h],r8
    cmp     r13,r14
    jb      L4
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L5
L0:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L5
    lea     rbp,[r12+r14*4]
    mov     r15,r13
    sub     r15,r14
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L3
    jmp     L6
L1:
    cmp     r12,0
    je      L5
    jmp     L0
L2:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r15,rax
    ja      L6
    mov     [rbx],r12
    mov     [rbx+8],r14
    mov     [rbx+10h],rbp
    mov     [rbx+18h],r15
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L3:
    cmp     rbp,0
    je      L6
    jmp     L2
L4:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L5:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2

fn core::slice::<impl [u32]>::swap
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
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
    cmp     r12,0
    je      L4
    jmp     L12
L0:
    mov     r12,r9
    and     r12,3
    cmp     r12,0
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
    cmp     r13,0
    je      L7
    jmp     L13
L4:
    cmp     rax,0
    je      L12
    jmp     L0
L5:
    cmp     r9,0
    je      L12
    jmp     L1
L6:
    mov     r9d,[rdi]
    mov     [rax],r9d
    lea     r9,[rsp+0Ch]
    lea     r13,[image.k536]
    mov     r14,r9
    and     r14,3
    cmp     r14,0
    je      L11
    jmp     L14
L7:
    cmp     rdi,0
    je      L13
    mov     r14,rax
    and     r14,3
    cmp     r14,0
    je      L6
    jmp     L13
L8:
    mov     rax,rdi
    and     rax,3
    cmp     rax,0
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L11:
    cmp     r9,0
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
    sub     rsp,28h
    mov     [rsp+10h],rbx
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
    cmp     rsi,0
    je      L4
    jmp     L13
L0:
    mov     rsi,rcx
    and     rsi,3
    cmp     rsi,0
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
    cmp     r9,0
    je      L7
    jmp     L14
L4:
    cmp     rax,0
    je      L13
    jmp     L0
L5:
    cmp     rcx,0
    je      L13
    jmp     L1
L6:
    mov     ecx,[rdi]
    mov     [rax],ecx
    lea     rcx,[rsp+0Ch]
    lea     r9,[image.k536]
    mov     rbx,rcx
    and     rbx,3
    cmp     rbx,0
    je      L11
    jmp     L15
L7:
    cmp     rdi,0
    je      L14
    mov     rbx,rax
    and     rbx,3
    cmp     rbx,0
    je      L6
    jmp     L14
L8:
    mov     rax,rdi
    and     rax,3
    cmp     rax,0
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
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L11:
    cmp     rcx,0
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
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
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
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
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
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    jmp     L9
L7:
    cmp     rdi,[rsp+10h]
    setb    r8b
    lea     r9,[k12]
    test    r8b,r8b
    je      L12
    mov     rax,rdi
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
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
    lea     rdi,[rsp+90h]
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
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
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
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,158h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     [rsp+0B0h],rdi
    mov     rax,rsi
    shr     rax,1
    cmp     rax,0
    setne   r8b
    mov     [rsp+0B7h],r8b
    lea     r8,[rdi+rax*4]
    mov     r9,rax
    sub     r9,1
    mov     [rsp+0B0h],r9
    lea     r9,[rdi+r9*4]
    mov     rbx,rsi
    sub     rbx,1
    lea     r12,[rdi+rbx*4]
    mov     [rsp+0B0h],rdx
    lea     rbx,[rdx+rbx*4]
    mov     [rsp+20h],r9
    mov     r13,rcx
    mov     [rsp+18h],r12
    mov     r15,rbx
    mov     rbx,rax
    mov     eax,0
    mov     [rsp+10h],rsi
L0:
    mov     [rsp+0A8h],rax
    mov     [rsp+0A0h],rbx
    cmp     rax,rbx
    setb    cl
    mov     [rsp+0B7h],cl
    test    cl,cl
    je      L13
    mov     [rsp+0A8h],rax
    mov     rbp,rax
    add     rbp,1
    mov     [rsp+0A0h],rbp
    lea     rax,[rsp+0A0h]
    mov     rsi,rdi
    mov     rdi,rax
    mov     rcx,rdx
    mov     rdx,r8
    mov     r8,r13
    call    fn4
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r14,[rsp+10h]
L1:
    mov     r12,[rsp+0A0h]
    mov     r11,[rsp+0A8h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+0B0h]
    mov     [rsp+30h],r11
    lea     rsi,[rsp+0A0h]
    mov     rdi,rsi
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,r13
    call    fn0
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     rsi,[rsp+0B0h]
    mov     [rsp+20h],rax
    mov     rax,rbp
    mov     rdi,r12
    mov     r8,[rsp+28h]
    mov     rdx,[rsp+30h]
    mov     [rsp+18h],rcx
    mov     r15,rsi
    mov     [rsp+10h],r14
    jmp     L0
L2:
    mov     rcx,rdi
    mov     r9,r8
    jmp     L12
L3:
    cmp     rdi,rax
    setb    cl
    mov     [rsp+0A6h],cl
    test    cl,cl
    je      L4
    mov     rcx,rdi
    jmp     L5
L4:
    mov     rcx,r8
L5:
    lea     rsi,[k5]
    mov     r9,rcx
    and     r9,3
    cmp     r9,0
    je      L10
    jmp     L14
L6:
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
    je      L11
    jmp     L14
L7:
    cmp     rcx,rdx
    jae     L8
    mov     r9,rdx
    sub     r9,rcx
    jmp     L9
L8:
    mov     r9,rcx
    sub     r9,rdx
L9:
    cmp     r9,4
    jb      L14
    mov     r9d,[rcx]
    mov     [rdx],r9d
    movzx   r9d,byte ptr [rsp+0A6h]
    movzx   ebx,r9b
    lea     rbx,[rdi+rbx*4]
    xor     r9d,1
    mov     [rsp+0A5h],r9b
    movzx   r9d,r9b
    lea     r9,[r8+r9*4]
    mov     rcx,rbx
    jmp     L12
L10:
    cmp     rcx,0
    je      L14
    jmp     L6
L11:
    cmp     rdx,0
    je      L14
    jmp     L7
L12:
    mov     rbx,[rsp+0B0h]
    cmp     rcx,rbx
    jne     L15
    mov     rcx,[rsp+0A8h]
    cmp     r9,rcx
    jne     L15
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,158h
    ret
L13:
    mov     rax,[rsp+20h]
    lea     rax,[rax+4]
    mov     [rsp+0B0h],rax
    mov     rcx,[rsp+18h]
    lea     rcx,[rcx+4]
    mov     [rsp+0A8h],rcx
    mov     rcx,[rsp+10h]
    and     rcx,1
    cmp     rcx,0
    sete    cl
    mov     [rsp+0A7h],cl
    test    cl,cl
    jne     L2
    jmp     L3
L14:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,237h
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    call    sym1
    ud2
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
L17:
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
    mov     r11,[rsp+10h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-140h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r13,[rsp+30h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L0
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-190h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     r15,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+20h]
    mov     rbx,[rsp+28h]
    mov     r14,[rsp+30h]
    lea     rsp,[rsp+40h]
    jmp     L1
L19:
    ret
L20:
    ret
L21:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0B8h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rax,rsi
    lea     rax,[rax-4]
    jmp     L21
L0:
    test    cl,cl
    je      L20
    mov     edx,[rsi]
    mov     [rsp+6Ch],edx
    lea     rdx,[rsp+6Ch]
    mov     r8,rdi
    mov     r9,rsi
    mov     rbx,rdx
    mov     rdx,rax
L1:
    lea     r12,[k3]
    mov     r13,rdx
    and     r13,3
    cmp     r13,0
    je      L6
    jmp     L24
L2:
    mov     r13,r9
    and     r13,3
    cmp     r13,0
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
    cmp     rdx,0
    je      L24
    jmp     L2
L7:
    cmp     r9,0
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
    cmp     r15,0
    je      L18
    jmp     L25
L14:
    mov     r15,r13
    and     r15,3
    cmp     r15,0
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
    cmp     r9,0
    je      L25
    jmp     L14
L19:
    cmp     r13,0
    je      L25
    jmp     L15
L20:
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,0B8h
    ret
L21:
    mov     r9d,[rsi]
    mov     r13d,[rsi-4]
    cmp     r9d,r13d
    setb    cl
    mov     [rsp+6Fh],cl
    jmp     L0
L22:
    mov     r9,rdx
    mov     r13,r8
    mov     r14,rbx
    jmp     L9
L23:
    mov     ecx,[rsp+6Ch]
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
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+18h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r8,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     rdx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L1
L29:
    ret
L30:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-60h]
    mov     [rsp+10h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r9,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    lea     rsp,[rsp+20h]
    jmp     L9
L31:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r9,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+30h]
    jmp     L10
L32:
    ret
L33:
    ret
L34:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0D0h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+18h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r15,[rsp]
    mov     r13,[rsp+8]
    mov     r9,[rsp+10h]
    mov     rax,[rsp+18h]
    lea     rsp,[rsp+20h]
    jmp     L23
L35:
    ret

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
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
    cmp     r12,0
    je      L6
    jmp     L9
L2:
    mov     r12,rcx
    and     r12,3
    cmp     r12,0
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
    cmp     r9,0
    je      L9
    jmp     L2
L7:
    cmp     rcx,0
    je      L9
    jmp     L3
L8:
    mov     [rdi],r13
    mov     [rdi+8],r12
    mov     [rdi+10h],r14
    mov     rax,rdi
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
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
    cmp     r12,0
    je      L6
    jmp     L8
L2:
    mov     r12,rcx
    and     r12,3
    cmp     r12,0
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L6:
    cmp     r9,0
    je      L8
    jmp     L2
L7:
    cmp     rcx,0
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
    sub     rsp,308h
    mov     [rsp+1E0h],rbx
    mov     [rsp+1D0h],r12
    mov     [rsp+1C0h],r13
    mov     [rsp+1B0h],r14
    mov     [rsp+1A0h],r15
    mov     [rsp+190h],rbp
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+18h],r8
    mov     r11,[rsp+28h]
    cmp     r11,2
    jb      L80
    mov     rax,[rsp+28h]
    add     rax,10h
    cmp     rcx,rax
    jb      L99
    mov     r11,[rsp+28h]
    shr     r11,1
    mov     [rsp+10h],r11
    mov     r11,[rsp+28h]
    cmp     r11,10h
    jb      L0
    mov     r11,[rsp+20h]
    mov     r10,[rsp+28h]
    lea     rax,[r11+r10*8]
    mov     [rsp+170h],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+170h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+168h],rcx
    mov     rdx,[rsp+28h]
    add     rdx,8
    mov     [rsp+208h],rdx
    mov     r11,[rsp+20h]
    lea     rdx,[r11+rdx*8]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     r12d,8
    jmp     L62
L0:
    mov     r11,[rsp+28h]
    cmp     r11,8
    jb      L49
    mov     r10,[rsp+30h]
    mov     [rsp+170h],r10
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     r11,[rsp+30h]
    mov     eax,[r11+8]
    mov     r11,[rsp+30h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    al
    mov     r11,[rsp+30h]
    mov     ecx,[r11+18h]
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
    mov     eax,[r14]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    r12b
    mov     eax,[r13]
    mov     ecx,[r15]
    cmp     eax,ecx
    setb    bl
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
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    r12b
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
    lea     r11,[image.k1752]
    mov     [rsp+0C8h],r11
    mov     rdx,[rsp+38h]
    and     rdx,3
    cmp     rdx,0
    je      L5
    jmp     L85
L1:
    mov     rdx,[rsp+20h]
    and     rdx,3
    cmp     rdx,0
    je      L6
    jmp     L85
L2:
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+20h]
    jae     L3
    mov     rdx,[rsp+20h]
    sub     rdx,[rsp+38h]
    jmp     L4
L3:
    mov     rdx,[rsp+38h]
    sub     rdx,[rsp+20h]
L4:
    cmp     rdx,8
    jb      L85
    mov     r11,[rsp+38h]
    mov     rdx,[r11]
    mov     r11,[rsp+20h]
    mov     [r11],rdx
    mov     rdx,[rsp+20h]
    lea     rdx,[rdx+8]
    lea     r11,[image.k1776]
    mov     [rsp+0C0h],r11
    mov     rdi,r13
    and     rdi,3
    cmp     rdi,0
    je      L11
    jmp     L86
L5:
    mov     r11,[rsp+38h]
    cmp     r11,0
    je      L85
    jmp     L1
L6:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L85
    jmp     L2
L7:
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
    je      L12
    jmp     L86
L8:
    cmp     r13,rdx
    jae     L9
    mov     rdi,rdx
    sub     rdi,r13
    jmp     L10
L9:
    mov     rdi,r13
    sub     rdi,rdx
L10:
    cmp     rdi,8
    jb      L86
    mov     rdi,[r13]
    mov     r11,[rsp+20h]
    mov     [r11+8],rdi
    mov     rdi,[rsp+20h]
    lea     rdi,[rdi+10h]
    lea     r11,[image.k1800]
    mov     [rsp+0B8h],r11
    mov     r9,rax
    and     r9,3
    cmp     r9,0
    je      L17
    jmp     L87
L11:
    cmp     r13,0
    je      L86
    jmp     L7
L12:
    cmp     rdx,0
    je      L86
    jmp     L8
L13:
    mov     rdx,rdi
    and     rdx,3
    cmp     rdx,0
    je      L18
    jmp     L87
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
    jb      L87
    mov     rdx,[rax]
    mov     r11,[rsp+20h]
    mov     [r11+10h],rdx
    mov     rdx,[rsp+20h]
    lea     rdx,[rdx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+0B0h],r11
    mov     rbx,[rsp+40h]
    and     rbx,3
    cmp     rbx,0
    je      L23
    jmp     L88
L17:
    cmp     rax,0
    je      L87
    jmp     L13
L18:
    cmp     rdi,0
    je      L87
    jmp     L14
L19:
    mov     rax,rdx
    and     rax,3
    cmp     rax,0
    je      L24
    jmp     L88
L20:
    mov     r11,[rsp+40h]
    cmp     r11,rdx
    jae     L21
    mov     rax,rdx
    sub     rax,[rsp+40h]
    jmp     L22
L21:
    mov     rax,[rsp+40h]
    sub     rax,rdx
L22:
    cmp     rax,8
    jb      L88
    mov     r11,[rsp+40h]
    mov     rax,[r11]
    mov     r11,[rsp+20h]
    mov     [r11+18h],rax
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+168h],rax
    mov     [rsp+170h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     r11,[r11+r10*8]
    mov     [rsp+48h],r11
    mov     r10,[rsp+48h]
    mov     [rsp+168h],r10
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     edi,[rax+8]
    mov     r12d,[rax]
    cmp     edi,r12d
    setb    dil
    mov     r12d,[rax+18h]
    mov     r13d,[rax+10h]
    cmp     r12d,r13d
    setb    r12b
    movzx   r13d,dil
    lea     r13,[rax+r13*8]
    xor     edi,1
    movzx   edi,dil
    lea     r14,[rax+rdi*8]
    movzx   edi,r12b
    add     rdi,2
    lea     r15,[rax+rdi*8]
    xor     r12d,1
    movzx   r12d,r12b
    add     r12,2
    lea     r12,[rax+r12*8]
    mov     eax,[r15]
    mov     edi,[r13]
    cmp     eax,edi
    setb    bpl
    mov     eax,[r12]
    mov     edi,[r14]
    cmp     eax,edi
    setb    bl
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,r13
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+50h],rax
    mov     rdi,rbx
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     [rsp+58h],rax
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,r14
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r15
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     rbx,rax
    mov     r11,[rsp+18h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     edi,[r13]
    cmp     eax,edi
    setb    r12b
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,r13
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    mov     r14,rax
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rbx
    movzx   edi,dil
    call    qword ptr [image.fn47.slot]
    lea     r11,[image.k1752]
    mov     [rsp+0A8h],r11
    mov     rbx,[rsp+50h]
    and     rbx,3
    cmp     rbx,0
    je      L29
    jmp     L89
L23:
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L88
    jmp     L19
L24:
    cmp     rdx,0
    je      L88
    jmp     L20
L25:
    mov     rdx,[rsp+48h]
    and     rdx,3
    cmp     rdx,0
    je      L30
    jmp     L89
L26:
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+48h]
    jae     L27
    mov     rdx,[rsp+48h]
    sub     rdx,[rsp+50h]
    jmp     L28
L27:
    mov     rdx,[rsp+50h]
    sub     rdx,[rsp+48h]
L28:
    cmp     rdx,8
    jb      L89
    mov     r11,[rsp+50h]
    mov     rdx,[r11]
    mov     r11,[rsp+48h]
    mov     [r11],rdx
    mov     rdx,[rsp+48h]
    lea     rdx,[rdx+8]
    lea     r11,[image.k1776]
    mov     [rsp+78h],r11
    mov     r12,r14
    and     r12,3
    cmp     r12,0
    je      L35
    jmp     L90
L29:
    mov     r11,[rsp+50h]
    cmp     r11,0
    je      L89
    jmp     L25
L30:
    mov     r11,[rsp+48h]
    cmp     r11,0
    je      L89
    jmp     L26
L31:
    mov     r12,rdx
    and     r12,3
    cmp     r12,0
    je      L36
    jmp     L90
L32:
    cmp     r14,rdx
    jae     L33
    mov     r12,rdx
    sub     r12,r14
    jmp     L34
L33:
    mov     r12,r14
    sub     r12,rdx
L34:
    cmp     r12,8
    jb      L90
    mov     r12,[r14]
    mov     r11,[rsp+48h]
    mov     [r11+8],r12
    mov     r12,[rsp+48h]
    lea     r12,[r12+10h]
    lea     r11,[image.k1800]
    mov     [rsp+70h],r11
    mov     r15,rax
    and     r15,3
    cmp     r15,0
    je      L41
    jmp     L91
L35:
    cmp     r14,0
    je      L90
    jmp     L31
L36:
    cmp     rdx,0
    je      L90
    jmp     L32
L37:
    mov     rdx,r12
    and     rdx,3
    cmp     rdx,0
    je      L42
    jmp     L91
L38:
    cmp     rax,r12
    jae     L39
    mov     rdx,r12
    sub     rdx,rax
    jmp     L40
L39:
    mov     rdx,rax
    sub     rdx,r12
L40:
    cmp     rdx,8
    jb      L91
    mov     rdx,[rax]
    mov     r11,[rsp+48h]
    mov     [r11+10h],rdx
    mov     rdx,[rsp+48h]
    lea     rdx,[rdx+18h]
    lea     r11,[image.k1824]
    mov     [rsp+68h],r11
    mov     r15,[rsp+58h]
    and     r15,3
    cmp     r15,0
    je      L47
    jmp     L92
L41:
    cmp     rax,0
    je      L91
    jmp     L37
L42:
    cmp     r12,0
    je      L91
    jmp     L38
L43:
    mov     rax,rdx
    and     rax,3
    cmp     rax,0
    je      L48
    jmp     L92
L44:
    mov     r11,[rsp+58h]
    cmp     r11,rdx
    jae     L45
    mov     rax,rdx
    sub     rax,[rsp+58h]
    jmp     L46
L45:
    mov     rax,[rsp+58h]
    sub     rax,rdx
L46:
    cmp     rax,8
    jb      L92
    mov     r11,[rsp+58h]
    mov     rax,[r11]
    mov     r11,[rsp+48h]
    mov     [r11+18h],rax
    mov     r12d,4
    jmp     L62
L47:
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L92
    jmp     L43
L48:
    cmp     rdx,0
    je      L92
    jmp     L44
L49:
    mov     r10,[rsp+30h]
    mov     [rsp+170h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+168h],r10
    lea     r11,[k9]
    mov     [rsp+88h],r11
    mov     rdx,[rsp+30h]
    and     rdx,3
    cmp     rdx,0
    je      L54
    jmp     L93
L50:
    mov     rdx,[rsp+20h]
    and     rdx,3
    cmp     rdx,0
    je      L55
    jmp     L93
L51:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+20h]
    jae     L52
    mov     rdx,[rsp+20h]
    sub     rdx,[rsp+30h]
    jmp     L53
L52:
    mov     rdx,[rsp+30h]
    sub     rdx,[rsp+20h]
L53:
    cmp     rdx,8
    jb      L93
    mov     r11,[rsp+20h]
    mov     [rsp],r11
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+300h]
    mov     esi,0FFFFFD00h
    mov     edx,0FFFFFE70h
    mov     ecx,0FFFFFD08h
    call    ryo_h_Memcpy
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rdx,[r11+r10*8]
    mov     [rsp+170h],rdx
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     r12,[r11+r10*8]
    mov     [rsp+168h],r12
    mov     [rsp+208h],r12
    lea     r11,[k11]
    mov     [rsp+60h],r11
    mov     rbp,rdx
    and     rbp,3
    cmp     rbp,0
    je      L60
    jmp     L94
L54:
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L93
    jmp     L50
L55:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L93
    jmp     L51
L56:
    mov     rbp,r12
    and     rbp,3
    cmp     rbp,0
    je      L61
    jmp     L94
L57:
    cmp     rdx,r12
    jae     L58
    mov     rbp,r12
    sub     rbp,rdx
    jmp     L59
L58:
    mov     rbp,rdx
    sub     rbp,r12
L59:
    cmp     rbp,8
    jb      L94
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+300h]
    mov     esi,0FFFFFE68h
    mov     edx,0FFFFFE70h
    mov     ecx,0FFFFFD00h
    call    ryo_h_Memcpy
    mov     r12d,1
    jmp     L62
L60:
    cmp     rdx,0
    je      L94
    jmp     L56
L61:
    cmp     r12,0
    je      L94
    jmp     L57
L62:
    mov     qword ptr [rsp+200h],0
    mov     r10,[rsp+10h]
    mov     [rsp+208h],r10
    mov     qword ptr [rsp+1F0h],0
    mov     r10,[rsp+10h]
    mov     [rsp+1F8h],r10
    lea     rdi,[rsp+300h]
    mov     esi,0FFFFFE80h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdx,[rsp+180h]
    mov     rbp,[rsp+188h]
    mov     [rsp+168h],rbp
    mov     qword ptr [rsp+170h],0
    mov     r10,[rsp+10h]
    mov     [rsp+178h],r10
    mov     [rsp+1F0h],rdx
    mov     [rsp+1F8h],rbp
    mov     qword ptr [rsp+200h],0
    mov     r10,[rsp+10h]
    mov     [rsp+208h],r10
    mov     rbp,[rsp+30h]
    mov     r15,[rsp+28h]
    mov     r11,[rsp+20h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+0D8h],r11
    mov     [rsp+0A0h],r12
    mov     r12,[rsp+20h]
    mov     r11,[rsp+18h]
    mov     [rsp+80h],r11
L63:
    lea     rdx,[rsp+1F0h]
    mov     [rsp+180h],rdx
    mov     qword ptr [rsp+188h],2
    mov     rdx,[rsp+1F8h]
    mov     rax,[rsp+1F0h]
    sub     rdx,rax
    cmp     rdx,0
    jbe     L64
    lea     r11,[image.k6944]
    mov     [rsp+90h],r11
    mov     r11,rax
    add     r11,1
    jb      L95
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+1F0h],rdx
    mov     [rsp+158h],rax
    mov     qword ptr [rsp+150h],1
    lea     rdx,[rsp+200h]
    lea     r11,[image.k7064]
    mov     [rsp+98h],r11
    cmp     rax,2
    jae     L96
    lea     rbx,[rdx+rax*8]
    lea     rdi,[rsp+300h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym46]
    mov     rax,[rbx]
    mov     [rsp+0D0h],rax
    mov     eax,1
    jmp     L65
L64:
    lea     rdi,[rsp+300h]
    mov     esi,0FFFFFE50h
    lea     rdx,[image.k6840]
    mov     ecx,10h
    call    ryo_h_Const
    mov     eax,0
L65:
    cmp     rax,0
    je      L67
    jmp     L81
L66:
    mov     [rsp+188h],rax
    lea     r13,[rbx+rax*8]
    mov     [rsp+180h],r13
    lea     r13,[rdi+rax*8]
    cmp     rax,0
    je      L70
    mov     rax,r8
    sub     rax,r9
    mov     [rsp+138h],rax
    mov     [rsp+130h],rcx
    mov     [rsp+0E8h],rbx
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],rdi
    mov     [rsp+100h],r9
    mov     [rsp+108h],rsi
    mov     [rsp+110h],r13
    mov     [rsp+118h],rdx
    jmp     L71
L67:
    mov     [rsp+168h],r12
    mov     [rsp+170h],rbp
    mov     [rsp+178h],r15
    mov     [rsp+200h],r12
    mov     [rsp+1F8h],r15
    mov     [rsp+1F0h],r12
    lea     r11,[k18]
    mov     [rsp+0E0h],r11
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L69
    jmp     L97
L68:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r15,rax
    ja      L97
    mov     [rsp+1F0h],r15
    mov     [rsp+208h],r12
    mov     [rsp+200h],rbp
    mov     rdi,r12
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,[rsp+80h]
    call    qword ptr [fn20.slot]
    jmp     L84
L69:
    cmp     r12,0
    je      L97
    jmp     L68
L70:
    mov     [rsp+138h],r9
    mov     [rsp+130h],rcx
    mov     [rsp+0E8h],rbx
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],rdi
    mov     [rsp+100h],r9
    mov     [rsp+108h],rsi
    mov     [rsp+110h],r13
    mov     [rsp+118h],rdx
L71:
    cmp     rsi,[rsp+138h]
    jae     L82
    mov     r11,rsi
    add     r11,1
    mov     [rsp+120h],r11
    mov     rax,[rsp+180h]
    lea     rax,[rax+rsi*8]
    mov     r11,[rsp+110h]
    lea     rcx,[r11+rsi*8]
    lea     r11,[k15]
    mov     [rsp+128h],r11
    mov     rsi,rax
    and     rsi,3
    cmp     rsi,0
    je      L76
    jmp     L98
L72:
    mov     rsi,rcx
    and     rsi,3
    cmp     rsi,0
    je      L77
    jmp     L98
L73:
    cmp     rax,rcx
    jae     L74
    mov     rsi,rcx
    sub     rsi,rax
    jmp     L75
L74:
    mov     rsi,rax
    sub     rsi,rcx
L75:
    cmp     rsi,8
    jb      L98
    mov     rsi,[rax]
    mov     [rcx],rsi
    mov     rdi,[rsp+110h]
    mov     rsi,rcx
    mov     rdx,[rsp+118h]
    call    qword ptr [fn17.slot]
    jmp     L83
L76:
    cmp     rax,0
    je      L98
    jmp     L72
L77:
    cmp     rcx,0
    je      L98
    jmp     L73
L78:
    mov     [rsp+138h],rcx
    mov     [rsp+130h],rsi
    mov     rsi,rax
    mov     [rsp+0E8h],rdi
    mov     [rsp+0F0h],r8
    mov     [rsp+0F8h],r9
    mov     [rsp+100h],rdx
    mov     [rsp+108h],r13
    mov     [rsp+110h],rbx
    mov     [rsp+118h],r14
    jmp     L71
L79:
    mov     r11,[rsp+168h]
    mov     rax,[rsp+170h]
    mov     [rsp+208h],rax
    mov     rax,[rsp+178h]
    mov     [rsp+200h],rax
L80:
    mov     rbx,[rsp+1E0h]
    mov     r12,[rsp+1D0h]
    mov     r13,[rsp+1C0h]
    mov     r14,[rsp+1B0h]
    mov     r15,[rsp+1A0h]
    mov     rbp,[rsp+190h]
    add     rsp,308h
    ret
L81:
    mov     rax,[rsp+0D0h]
    mov     rbx,rbp
    mov     rdi,[rsp+140h]
    mov     r9,[rsp+0D8h]
    mov     r8,r15
    mov     rsi,[rsp+0A0h]
    mov     rcx,r12
    mov     rdx,[rsp+80h]
    jmp     L66
L82:
    mov     r12,[rsp+130h]
    mov     rbp,[rsp+0E8h]
    mov     r15,[rsp+0F0h]
    mov     r11,[rsp+0F8h]
    mov     [rsp+140h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+0D8h],r11
    mov     r11,[rsp+108h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+118h]
    mov     [rsp+80h],r11
    jmp     L63
L83:
    mov     rax,[rsp+120h]
    mov     rcx,[rsp+138h]
    mov     rsi,[rsp+130h]
    mov     rdi,[rsp+0E8h]
    mov     r8,[rsp+0F0h]
    mov     r9,[rsp+0F8h]
    mov     rdx,[rsp+100h]
    mov     r13,[rsp+108h]
    mov     rbx,[rsp+110h]
    mov     r14,[rsp+118h]
    jmp     L78
L84:
    jmp     L79
L85:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L86:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L87:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L88:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L89:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L90:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L91:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L92:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L93:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L94:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L95:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L96:
    lea     rax,[image.k9969]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L98:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+128h]
    movzx   edx,dl
    call    image.sym49
    ud2
L99:
    lea     rdi,[rsp+300h]
    call    ryo_h_Abort
    ud2
L100:
    lea     rax,[rsp+1F0h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L101
    jmp     L103
L101:
    mov     [rsp],rax
    lea     rdi,[rsp+300h]
    mov     esi,0FFFFFD00h
    call    ryo_h_Resume
    ud2
L102:
    lea     rax,[rsp+168h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    mov     rax,r12
    jmp     L101
    jmp     L103
    mov     rbx,rax
    jmp     L100
    mov     r12,rax
    jmp     L102
L103:
    call    sym21
    ud2
  ; OSR entries
    lea     r11,[L104]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L104:
    .long   L105
    .long   L106
    .long   L107
    .long   L108
    .long   L109
    .long   L110
    .long   L111
    .long   L112
    .long   L113
    .long   L114
    .long   L115
L105:
    ret
L106:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-360h]
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
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-260h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-280h],r11
    mov     r12,[rsp]
    mov     rbp,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+60h]
    jmp     L63
L107:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-370h]
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
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+40h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-188h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     rdi,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     rdx,[rsp+38h]
    lea     rsp,[rsp+70h]
    jmp     L66
L108:
    ret
L109:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-380h]
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
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-210h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1E8h],r11
    mov     rsi,[rsp]
    lea     rsp,[rsp+80h]
    jmp     L71
L110:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-380h]
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
    mov     [rdx-120h],rbx
    mov     [rdx-130h],r12
    mov     [rdx-140h],r13
    mov     [rdx-150h],r14
    mov     [rdx-160h],r15
    mov     [rdx-170h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-178h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-188h],r11
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     r13,[rsp+38h]
    mov     rbx,[rsp+40h]
    mov     r14,[rsp+48h]
    mov     rdx,[rsp+30h]
    lea     rsp,[rsp+80h]
    jmp     L78
L111:
    ret
L112:
    ret
L113:
    ret
L114:
    ret
L115:
    ret

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,1D8h
    mov     [rsp+1C0h],rbx
    mov     [rsp+1B0h],r12
    mov     [rsp+1A0h],r13
    mov     [rsp+190h],r14
    mov     [rsp+180h],r15
    mov     [rsp+170h],rbp
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rdx
    cmp     rsi,9
    jb      L104
    mov     rdi,[rsp+20h]
    mov     esi,0
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    fn0
    mov     r11,[rsp+20h]
    lea     r11,[r11+4]
    mov     [rsp+10h],r11
    mov     r11,[rsp+20h]
    lea     r11,[r11+1Ch]
    mov     [rsp+58h],r11
    mov     r11,[rsp+20h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    r15b
    mov     rdi,r15
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+10h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+58h]
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0B0h],eax
    lea     rax,[image.k2088]
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    je      L1
    jmp     L80
L0:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11+4],ecx
    lea     rcx,[rsp+0B0h]
    lea     rdx,[image.k2112]
    mov     rsi,rcx
    and     rsi,3
    cmp     rsi,0
    je      L6
    jmp     L81
L1:
    cmp     rbp,0
    je      L80
    mov     rsi,[rsp+10h]
    and     rsi,3
    cmp     rsi,0
    jne     L80
    mov     r11,[rsp+10h]
    cmp     r11,0
    je      L80
    jmp     L0
L2:
    mov     rsi,[rsp+58h]
    and     rsi,3
    cmp     rsi,0
    je      L7
    jmp     L81
L3:
    cmp     rcx,[rsp+58h]
    jae     L4
    mov     rsi,[rsp+58h]
    sub     rsi,rcx
    jmp     L5
L4:
    mov     rsi,rcx
    sub     rsi,[rsp+58h]
L5:
    cmp     rsi,4
    jb      L81
    mov     esi,[rsp+0B0h]
    mov     r11,[rsp+20h]
    mov     [r11+1Ch],esi
    mov     r15,[rsp+20h]
    lea     r15,[r15+8]
    mov     r11,[rsp+20h]
    lea     r11,[r11+14h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+20h]
    mov     esi,[r11+14h]
    mov     r11,[rsp+20h]
    mov     edi,[r11+8]
    cmp     esi,edi
    setb    r13b
    mov     rdi,r13
    mov     rsi,[rsp+70h]
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     r12,rax
    mov     rdi,r13
    mov     rsi,r15
    mov     rdx,[rsp+70h]
    movzx   edi,dil
    call    image.fn46
    mov     rsi,rax
    mov     esi,[rsi]
    mov     [rsp+0C0h],esi
    lea     rsi,[image.k2088]
    mov     rdi,r12
    and     rdi,3
    cmp     rdi,0
    je      L9
    jmp     L82
L6:
    cmp     rcx,0
    je      L81
    jmp     L2
L7:
    mov     r11,[rsp+58h]
    cmp     r11,0
    je      L81
    jmp     L3
L8:
    mov     ecx,[r12]
    mov     r11,[rsp+20h]
    mov     [r11+8],ecx
    lea     rcx,[rsp+0C0h]
    lea     rdi,[image.k2112]
    mov     r8,rcx
    and     r8,3
    cmp     r8,0
    je      L14
    jmp     L83
L9:
    cmp     r12,0
    je      L82
    mov     r8,r15
    and     r8,3
    cmp     r8,0
    jne     L82
    cmp     r15,0
    je      L82
    jmp     L8
L10:
    mov     r8,[rsp+70h]
    and     r8,3
    cmp     r8,0
    je      L15
    jmp     L83
L11:
    cmp     rcx,[rsp+70h]
    jae     L12
    mov     r8,[rsp+70h]
    sub     r8,rcx
    jmp     L13
L12:
    mov     r8,rcx
    sub     r8,[rsp+70h]
L13:
    cmp     r8,4
    jb      L83
    mov     r8d,[rsp+0C0h]
    mov     r11,[rsp+20h]
    mov     [r11+14h],r8d
    mov     r12,[rsp+20h]
    lea     r12,[r12+10h]
    mov     r11,[rsp+20h]
    lea     r11,[r11+20h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+20h]
    mov     r8d,[r11+20h]
    mov     r11,[rsp+20h]
    mov     r9d,[r11+10h]
    cmp     r8d,r9d
    setb    bl
    mov     rdi,rbx
    mov     rsi,[rsp+28h]
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+28h]
    movzx   edi,dil
    call    image.fn46
    mov     r8,rax
    mov     r8d,[r8]
    mov     [rsp+0D0h],r8d
    lea     r8,[image.k2088]
    mov     r9,r13
    and     r9,3
    cmp     r9,0
    je      L17
    jmp     L84
L14:
    cmp     rcx,0
    je      L83
    jmp     L10
L15:
    mov     r11,[rsp+70h]
    cmp     r11,0
    je      L83
    jmp     L11
L16:
    mov     ecx,[r13]
    mov     r11,[rsp+20h]
    mov     [r11+10h],ecx
    lea     rcx,[rsp+0D0h]
    lea     r11,[image.k2112]
    mov     [rsp+50h],r11
    mov     rbx,rcx
    and     rbx,3
    cmp     rbx,0
    je      L22
    jmp     L85
L17:
    cmp     r13,0
    je      L84
    mov     rbx,r12
    and     rbx,3
    cmp     rbx,0
    jne     L84
    cmp     r12,0
    je      L84
    jmp     L16
L18:
    mov     rbx,[rsp+28h]
    and     rbx,3
    cmp     rbx,0
    je      L23
    jmp     L85
L19:
    cmp     rcx,[rsp+28h]
    jae     L20
    mov     rbx,[rsp+28h]
    sub     rbx,rcx
    jmp     L21
L20:
    mov     rbx,rcx
    sub     rbx,[rsp+28h]
L21:
    cmp     rbx,4
    jb      L85
    mov     ebx,[rsp+0D0h]
    mov     r11,[rsp+20h]
    mov     [r11+20h],ebx
    mov     r11,[rsp+20h]
    mov     ebx,[r11+1Ch]
    mov     r11,[rsp+20h]
    mov     r13d,[r11]
    cmp     ebx,r13d
    setb    bl
    mov     rdi,rbx
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+58h]
    movzx   edi,dil
    call    image.fn46
    mov     rbx,rax
    mov     ebx,[rbx]
    mov     [rsp+0E0h],ebx
    lea     r11,[image.k2088]
    mov     [rsp+30h],r11
    mov     rbx,r13
    and     rbx,3
    cmp     rbx,0
    je      L25
    jmp     L86
L22:
    cmp     rcx,0
    je      L85
    jmp     L18
L23:
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L85
    jmp     L19
L24:
    mov     ecx,[r13]
    mov     r11,[rsp+20h]
    mov     [r11],ecx
    lea     rcx,[rsp+0E0h]
    lea     r11,[image.k2112]
    mov     [rsp+38h],r11
    mov     rbx,rcx
    and     rbx,3
    cmp     rbx,0
    je      L29
    jmp     L87
L25:
    cmp     r13,0
    je      L86
    mov     rbx,[rsp+20h]
    and     rbx,3
    cmp     rbx,0
    jne     L86
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L86
    jmp     L24
L26:
    mov     rbx,[rsp+58h]
    and     rbx,3
    cmp     rbx,0
    jne     L87
    cmp     rcx,[rsp+58h]
    jae     L27
    mov     rbx,[rsp+58h]
    sub     rbx,rcx
    jmp     L28
L27:
    mov     rbx,rcx
    sub     rbx,[rsp+58h]
L28:
    cmp     rbx,4
    jb      L87
    mov     ebx,[rsp+0E0h]
    mov     r11,[rsp+20h]
    mov     [r11+1Ch],ebx
    mov     r11,[rsp+20h]
    mov     ebx,[r11+10h]
    mov     r11,[rsp+20h]
    mov     r13d,[r11+8]
    cmp     ebx,r13d
    setb    bl
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbx,rax
    mov     ebx,[rbx]
    mov     [rsp+0F0h],ebx
    lea     r11,[image.k2088]
    mov     [rsp+40h],r11
    mov     rbx,r13
    and     rbx,3
    cmp     rbx,0
    je      L31
    jmp     L88
L29:
    cmp     rcx,0
    je      L87
    jmp     L26
L30:
    mov     ecx,[r13]
    mov     r11,[rsp+20h]
    mov     [r11+8],ecx
    lea     rcx,[rsp+0F0h]
    lea     r11,[image.k2112]
    mov     [rsp+48h],r11
    mov     rbx,rcx
    and     rbx,3
    cmp     rbx,0
    je      L35
    jmp     L89
L31:
    cmp     r13,0
    je      L88
    mov     rbx,r15
    and     rbx,3
    cmp     rbx,0
    je      L30
    jmp     L88
L32:
    mov     rbx,r12
    and     rbx,3
    cmp     rbx,0
    jne     L89
    cmp     rcx,r12
    jae     L33
    mov     rbx,r12
    sub     rbx,rcx
    jmp     L34
L33:
    mov     rbx,rcx
    sub     rbx,r12
L34:
    cmp     rbx,4
    jb      L89
    mov     ebx,[rsp+0F0h]
    mov     r11,[rsp+20h]
    mov     [r11+10h],ebx
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+0Ch]
    mov     r11,[rsp+20h]
    mov     r13d,[r11+20h]
    mov     r11,[rsp+20h]
    mov     r9d,[r11+0Ch]
    cmp     r13d,r9d
    setb    r13b
    mov     rdi,r13
    mov     rsi,[rsp+28h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,[rsp+28h]
    movzx   edi,dil
    call    image.fn46
    mov     r9,rax
    mov     r9d,[r9]
    mov     [rsp+100h],r9d
    lea     r11,[image.k2088]
    mov     [rsp+68h],r11
    mov     r13,r14
    and     r13,3
    cmp     r13,0
    je      L37
    jmp     L90
L35:
    cmp     rcx,0
    je      L89
    jmp     L32
L36:
    mov     ecx,[r14]
    mov     r11,[rsp+20h]
    mov     [r11+0Ch],ecx
    lea     rcx,[rsp+100h]
    lea     r11,[image.k2112]
    mov     [rsp+60h],r11
    mov     r13,rcx
    and     r13,3
    cmp     r13,0
    je      L41
    jmp     L91
L37:
    cmp     r14,0
    je      L90
    mov     r13,rbx
    and     r13,3
    cmp     r13,0
    jne     L90
    cmp     rbx,0
    je      L90
    jmp     L36
L38:
    mov     r13,[rsp+28h]
    and     r13,3
    cmp     r13,0
    jne     L91
    cmp     rcx,[rsp+28h]
    jae     L39
    mov     r13,[rsp+28h]
    sub     r13,rcx
    jmp     L40
L39:
    mov     r13,rcx
    sub     r13,[rsp+28h]
L40:
    cmp     r13,4
    jb      L91
    mov     r13d,[rsp+100h]
    mov     r11,[rsp+20h]
    mov     [r11+20h],r13d
    mov     r13,[rsp+20h]
    lea     r13,[r13+18h]
    mov     r11,[rsp+20h]
    mov     r14d,[r11+18h]
    mov     r11,[rsp+20h]
    mov     r9d,[r11+14h]
    cmp     r14d,r9d
    setb    r14b
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,[rsp+70h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,[rsp+70h]
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r9,rax
    mov     r9d,[r9]
    mov     [rsp+110h],r9d
    lea     r9,[image.k2088]
    mov     r14,rbp
    and     r14,3
    cmp     r14,0
    je      L43
    jmp     L92
L41:
    cmp     rcx,0
    je      L91
    jmp     L38
L42:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11+14h],ecx
    lea     rcx,[rsp+110h]
    lea     r11,[image.k2112]
    mov     [rsp+78h],r11
    mov     r14,rcx
    and     r14,3
    cmp     r14,0
    je      L48
    jmp     L93
L43:
    cmp     rbp,0
    je      L92
    mov     r14,[rsp+70h]
    and     r14,3
    cmp     r14,0
    je      L42
    jmp     L92
L44:
    mov     r14,r13
    and     r14,3
    cmp     r14,0
    je      L49
    jmp     L93
L45:
    cmp     rcx,r13
    jae     L46
    mov     r14,r13
    sub     r14,rcx
    jmp     L47
L46:
    mov     r14,rcx
    sub     r14,r13
L47:
    cmp     r14,4
    jb      L93
    mov     r14d,[rsp+110h]
    mov     r11,[rsp+20h]
    mov     [r11+18h],r14d
    mov     r11,[rsp+20h]
    mov     r14d,[r11+8]
    mov     r11,[rsp+20h]
    mov     ebp,[r11]
    cmp     r14d,ebp
    setb    r14b
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,[rsp+20h]
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     r14d,[r14]
    mov     [rsp+120h],r14d
    lea     r11,[image.k2088]
    mov     [rsp+80h],r11
    mov     r14,rbp
    and     r14,3
    cmp     r14,0
    je      L51
    jmp     L94
L48:
    cmp     rcx,0
    je      L93
    jmp     L44
L49:
    cmp     r13,0
    je      L93
    jmp     L45
L50:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11],ecx
    lea     rcx,[rsp+120h]
    lea     r13,[image.k2112]
    mov     r14,rcx
    and     r14,3
    cmp     r14,0
    je      L55
    jmp     L95
L51:
    cmp     rbp,0
    je      L94
    mov     r14,[rsp+20h]
    and     r14,3
    cmp     r14,0
    je      L50
    jmp     L94
L52:
    mov     r14,r15
    and     r14,3
    cmp     r14,0
    jne     L95
    cmp     rcx,r15
    jae     L53
    mov     r14,r15
    sub     r14,rcx
    jmp     L54
L53:
    mov     r14,rcx
    sub     r14,r15
L54:
    cmp     r14,4
    jb      L95
    mov     r14d,[rsp+120h]
    mov     r11,[rsp+20h]
    mov     [r11+8],r14d
    mov     r11,[rsp+20h]
    mov     r14d,[r11+0Ch]
    mov     r11,[rsp+20h]
    mov     ebp,[r11+4]
    cmp     r14d,ebp
    setb    r14b
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,[rsp+10h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r14
    mov     rsi,[rsp+10h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     r14d,[r14]
    mov     [rsp+130h],r14d
    lea     r11,[image.k2088]
    mov     [rsp+88h],r11
    mov     r14,rbp
    and     r14,3
    cmp     r14,0
    je      L57
    jmp     L96
L55:
    cmp     rcx,0
    je      L95
    jmp     L52
L56:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11+4],ecx
    lea     rcx,[rsp+130h]
    lea     r14,[image.k2112]
    mov     r15,rcx
    and     r15,3
    cmp     r15,0
    je      L61
    jmp     L97
L57:
    cmp     rbp,0
    je      L96
    mov     r15,[rsp+10h]
    and     r15,3
    cmp     r15,0
    je      L56
    jmp     L96
L58:
    mov     r15,rbx
    and     r15,3
    cmp     r15,0
    jne     L97
    cmp     rcx,rbx
    jae     L59
    mov     r15,rbx
    sub     r15,rcx
    jmp     L60
L59:
    mov     r15,rcx
    sub     r15,rbx
L60:
    cmp     r15,4
    jb      L97
    mov     r15d,[rsp+130h]
    mov     r11,[rsp+20h]
    mov     [r11+0Ch],r15d
    mov     r11,[rsp+20h]
    mov     r15d,[r11+14h]
    mov     r11,[rsp+20h]
    mov     ebp,[r11+10h]
    cmp     r15d,ebp
    setb    r15b
    mov     rdi,r15
    mov     rsi,[rsp+70h]
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,r12
    mov     rdx,[rsp+70h]
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     r15d,[r15]
    mov     [rsp+140h],r15d
    lea     r11,[image.k2088]
    mov     [rsp+90h],r11
    mov     r15,rbp
    and     r15,3
    cmp     r15,0
    je      L63
    jmp     L98
L61:
    cmp     rcx,0
    je      L97
    jmp     L58
L62:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11+10h],ecx
    lea     rcx,[rsp+140h]
    lea     rbx,[image.k2112]
    mov     r15,rcx
    and     r15,3
    cmp     r15,0
    je      L67
    jmp     L99
L63:
    cmp     rbp,0
    je      L98
    and     r12,3
    cmp     r12,0
    je      L62
    jmp     L98
L64:
    mov     r12,[rsp+70h]
    and     r12,3
    cmp     r12,0
    jne     L99
    cmp     rcx,[rsp+70h]
    jae     L65
    mov     r12,[rsp+70h]
    sub     r12,rcx
    jmp     L66
L65:
    mov     r12,rcx
    sub     r12,[rsp+70h]
L66:
    cmp     r12,4
    jb      L99
    mov     r12d,[rsp+140h]
    mov     r11,[rsp+20h]
    mov     [r11+14h],r12d
    mov     r11,[rsp+20h]
    mov     r12d,[r11+20h]
    mov     r11,[rsp+20h]
    mov     r15d,[r11+1Ch]
    cmp     r12d,r15d
    setb    r12b
    mov     rdi,r12
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+58h]
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,r12
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+28h]
    movzx   edi,dil
    call    image.fn46
    mov     r12,rax
    mov     r12d,[r12]
    mov     [rsp+150h],r12d
    lea     r12,[image.k2088]
    mov     rbp,r15
    and     rbp,3
    cmp     rbp,0
    je      L69
    jmp     L100
L67:
    cmp     rcx,0
    je      L99
    jmp     L64
L68:
    mov     ecx,[r15]
    mov     r11,[rsp+20h]
    mov     [r11+1Ch],ecx
    lea     rcx,[rsp+150h]
    lea     r11,[image.k2112]
    mov     [rsp+98h],r11
    mov     rbp,rcx
    and     rbp,3
    cmp     rbp,0
    je      L73
    jmp     L101
L69:
    cmp     r15,0
    je      L100
    mov     rbp,[rsp+58h]
    and     rbp,3
    cmp     rbp,0
    je      L68
    jmp     L100
L70:
    mov     r15,[rsp+28h]
    and     r15,3
    cmp     r15,0
    jne     L101
    cmp     rcx,[rsp+28h]
    jae     L71
    mov     r15,[rsp+28h]
    sub     r15,rcx
    jmp     L72
L71:
    mov     r15,rcx
    sub     r15,[rsp+28h]
L72:
    cmp     r15,4
    jb      L101
    mov     r15d,[rsp+150h]
    mov     r11,[rsp+20h]
    mov     [r11+20h],r15d
    mov     rdi,[rsp+20h]
    mov     esi,1
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+18h]
    call    fn0
    mov     r11,[rsp+20h]
    mov     r15d,[r11+4]
    mov     r11,[rsp+20h]
    mov     ebp,[r11]
    cmp     r15d,ebp
    setb    r15b
    mov     rdi,r15
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     r15d,[r15]
    mov     [rsp+160h],r15d
    lea     r11,[image.k2088]
    mov     [rsp+0A0h],r11
    mov     r15,rbp
    and     r15,3
    cmp     r15,0
    je      L75
    jmp     L102
L73:
    cmp     rcx,0
    je      L101
    jmp     L70
L74:
    mov     ecx,[rbp]
    mov     r11,[rsp+20h]
    mov     [r11],ecx
    lea     rcx,[rsp+160h]
    lea     r11,[image.k2112]
    mov     [rsp+0A8h],r11
    mov     r15,rcx
    and     r15,3
    cmp     r15,0
    je      L79
    jmp     L103
L75:
    cmp     rbp,0
    je      L102
    mov     r15,[rsp+20h]
    and     r15,3
    cmp     r15,0
    je      L74
    jmp     L102
L76:
    mov     r15,[rsp+10h]
    and     r15,3
    cmp     r15,0
    jne     L103
    cmp     rcx,[rsp+10h]
    jae     L77
    mov     r15,[rsp+10h]
    sub     r15,rcx
    jmp     L78
L77:
    mov     r15,rcx
    sub     r15,[rsp+10h]
L78:
    cmp     r15,4
    jb      L103
    mov     r15d,[rsp+160h]
    mov     r11,[rsp+20h]
    mov     [r11+4],r15d
    mov     rdi,[rsp+20h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,3
    mov     edx,5
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,6
    mov     edx,7
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rdi,[rsp+20h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    fn0
    mov     rbx,[rsp+1C0h]
    mov     r12,[rsp+1B0h]
    mov     r13,[rsp+1A0h]
    mov     r14,[rsp+190h]
    mov     r15,[rsp+180h]
    mov     rbp,[rsp+170h]
    add     rsp,1D8h
    ret
L79:
    cmp     rcx,0
    je      L103
    jmp     L76
L80:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L81:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L82:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,1BBh
    movzx   edx,dl
    call    image.sym49
    ud2
L83:
    lea     rax,[image.k8338]
    mov     esi,237h
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L84:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L85:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L86:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    image.sym49
    ud2
L87:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L88:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L89:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L90:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L91:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L92:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L93:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L94:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L95:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L96:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L98:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L99:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbx
    movzx   edx,dl
    call    image.sym49
    ud2
L100:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L101:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L103:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L104:
    lea     rdi,[rsp+1D0h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    lea     rbx,[rdi+rsi*4]
    lea     r12,[rdi+rdx*4]
    mov     eax,[r12]
    mov     ecx,[rbx]
    cmp     eax,ecx
    setb    r13b
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
    lea     rax,[k3]
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    je      L1
    jmp     L9
L0:
    mov     ecx,[r14]
    mov     [rbx],ecx
    jmp     L2
L1:
    cmp     r14,0
    je      L9
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    jne     L9
    cmp     rbx,0
    je      L9
    jmp     L0
L2:
    lea     rcx,[rsp+10h]
    lea     rdx,[k5]
    mov     rsi,rcx
    and     rsi,3
    cmp     rsi,0
    je      L7
    jmp     L10
L3:
    mov     rsi,r12
    and     rsi,3
    cmp     rsi,0
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
    mov     esi,[rsp+10h]
    mov     [r12],esi
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    add     rsp,68h
    ret
L7:
    cmp     rcx,0
    je      L10
    jmp     L3
L8:
    cmp     r12,0
    je      L10
    jmp     L4
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
    sub     rsp,28h
    mov     [rsp+10h],rbx
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
    cmp     r9,0
    je      L7
    jmp     L10
L3:
    mov     r9,rcx
    and     r9,3
    cmp     r9,0
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
    mov     r9,[rdx]
    mov     [rcx],r9
    movzx   r9d,sil
    mov     rbx,[rdi+10h]
    add     rbx,r9
    mov     [rdi+10h],rbx
    mov     r9,[rdi+8]
    lea     r9,[r9+8]
    mov     [rdi+8],r9
    mov     rax,rcx
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L7:
    cmp     rdx,0
    je      L10
    jmp     L3
L8:
    cmp     rcx,0
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
    sub     rsp,478h
    mov     [rsp+370h],rbx
    mov     [rsp+360h],r12
    mov     [rsp+350h],r13
    mov     [rsp+340h],r14
    mov     [rsp+330h],r15
    mov     [rsp+320h],rbp
    mov     rax,[rsp+480h]
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+38h],rdx
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rax
    mov     [rsp+20h],r9
L0:
    mov     r10,[rsp+48h]
    mov     [rsp+3B0h],r10
    mov     r11d,20h
    cmp     r11,[rsp+40h]
    jb      L1
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+28h]
    call    qword ptr [image.fn81.slot]
    jmp     L30
L1:
    cmp     r8d,0
    jne     L15
    mov     byte ptr [rsp+2D7h],0
    mov     rdi,4000000000000000h
    mov     rsi,[rsp+40h]
    call    ryo_hr_DivUW64
    mov     [rsp+58h],rax
    mov     r11,4000000000000000h
    mov     [rsp+10h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+18h],r11
    lea     rdi,[rsp+470h]
    mov     esi,0FFFFFE58h
    mov     edx,0FFFFFBA0h
    mov     ecx,0FFFFFBA8h
    call    ryo_h_RemUW64
    mov     rax,[rsp+2C8h]
    cmp     rax,0
    ja      L12
    jmp     L13
L2:
    mov     rax,[rsp+40h]
    shr     rax,1
    mov     [rsp+2C8h],rax
    mov     r11,[rsp+40h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+2D0h],rax
    cmp     rax,40h
    jbe     L3
    mov     r14d,40h
    jmp     L5
L3:
    mov     r14,rax
    jmp     L5
L4:
    mov     rdi,[rsp+40h]
    call    image.sym32
    mov     r14,rax
L5:
    lea     rdi,[rsp+470h]
    mov     esi,0FFFFFC58h
    lea     rdx,[image.k2976]
    mov     ecx,210h
    call    ryo_h_Const
    lea     r13,[rsp+0C8h]
    mov     [rsp+318h],r13
    lea     rdi,[rsp+470h]
    mov     esi,0FFFFFE6Eh
    lea     rdx,[image.k3504]
    mov     ecx,42h
    call    ryo_h_Const
    lea     r11,[rsp+2DEh]
    mov     [rsp+60h],r11
    mov     ebx,0
    mov     r15d,1
    mov     ebp,0
L6:
    cmp     rbx,[rsp+40h]
    jae     L7
    mov     rax,[rsp+40h]
    sub     rax,rbx
    mov     r11,[rsp+48h]
    lea     rcx,[r11+rbx*8]
    mov     r10,[rsp+28h]
    mov     [rsp],r10
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    mov     r8,r14
    mov     r9d,1
    movzx   r9d,r9b
    call    qword ptr [image.fn85.slot]
    mov     r12,rax
    mov     rax,r15
    shr     rax,1
    mov     r11,rbx
    sub     r11,rax
    mov     rax,r11
    mov     rcx,r12
    shr     rcx,1
    add     rcx,rbx
    add     rax,rbx
    add     rcx,rbx
    imul    rax,[rsp+50h]
    imul    rcx,[rsp+50h]
    xor     rax,rcx
    mov     rdi,rax
    call    ryo_hr_CtlzW64
    mov     [rsp+68h],r12
    mov     r12,rax
    jmp     L8
L7:
    mov     r12d,0
    mov     qword ptr [rsp+68h],1
L8:
    cmp     rbp,1
    jbe     L9
    mov     rax,rbp
    sub     rax,1
    mov     r11,[rsp+60h]
    lea     rax,[r11+rax]
    movzx   eax,byte ptr [rax]
    cmp     al,r12b
    jb      L9
    mov     rax,rbp
    sub     rax,1
    lea     rax,[r13+rax*8]
    mov     rax,[rax]
    mov     rcx,rax
    shr     rcx,1
    mov     rdx,r15
    shr     rdx,1
    add     rcx,rdx
    mov     r11,rbx
    sub     r11,rcx
    mov     rcx,r11
    lea     rdx,[image.k3624]
    cmp     rbx,rcx
    jb      L33
    mov     r11,[rsp+40h]
    cmp     r11,rbx
    jb      L33
    mov     rsi,rbx
    sub     rsi,rcx
    mov     r11,[rsp+48h]
    lea     rcx,[r11+rcx*8]
    mov     r10,[rsp+28h]
    mov     [rsp],r10
    mov     rdi,rcx
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    mov     r8,rax
    mov     r9,r15
    call    qword ptr [image.fn86.slot]
    mov     rcx,rbp
    sub     rcx,1
    mov     rbp,rcx
    mov     r15,rax
    jmp     L8
L9:
    lea     rax,[r13+rbp*8]
    mov     [rax],r15
    mov     r11,[rsp+60h]
    lea     rax,[r11+rbp]
    mov     [rax],r12b
    add     rbp,1
    cmp     rbx,[rsp+40h]
    jb      L10
    and     r15,1
    cmp     r15,1
    je      L30
    jmp     L11
L10:
    mov     rax,[rsp+68h]
    shr     rax,1
    add     rbx,rax
    mov     r15,[rsp+68h]
    jmp     L6
L11:
    mov     rax,[rsp+40h]
    or      rax,1
    cmp     rax,0
    je      L34
    mov     rdi,rax
    call    ryo_hr_CtlzW64
    mov     r11d,3Fh
    sub     r11d,eax
    mov     rax,r11
    imul    eax,2
    mov     r10,[rsp+28h]
    mov     [rsp],r10
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    mov     r8,rax
    mov     r9d,0
    mov     r8d,r8d
    call    fn14
    jmp     L30
L12:
    mov     rax,[rsp+58h]
    add     rax,1
    mov     [rsp+50h],rax
    jmp     L14
L13:
    mov     r11,[rsp+58h]
    mov     [rsp+50h],r11
L14:
    mov     r11,[rsp+40h]
    cmp     r11,1000h
    ja      L4
    jmp     L2
L15:
    mov     r11,r8
    sub     r11d,1
    mov     [rsp+70h],r11
    mov     r10,[rsp+40h]
    mov     [rsp+3B0h],r10
    mov     rax,[rsp+40h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+48h]
    lea     r12,[r11+rcx*8]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+48h]
    lea     r13,[r11+rcx*8]
    mov     r11,[rsp+40h]
    cmp     r11,40h
    jae     L19
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     r11,[rsp+48h]
    mov     ecx,[r11]
    mov     esi,[r12]
    cmp     ecx,esi
    setb    dil
    mov     r8d,[r13]
    cmp     ecx,r8d
    setb    cl
    cmp     dil,cl
    jne     L17
    cmp     esi,r8d
    setb    cl
    xor     ecx,edi
    test    cl,cl
    je      L16
    mov     rcx,r13
    jmp     L18
L16:
    mov     rcx,r12
    jmp     L18
L17:
    mov     rcx,[rsp+48h]
L18:
    lea     rsi,[image.k1336]
    cmp     rcx,[rsp+48h]
    jb      L35
    sub     rcx,[rsp+48h]
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rax,rcx
    jmp     L23
L19:
    mov     r14,rax
    shr     r14,3
    mov     r15,r14
    imul    r15,4
    mov     r11,[rsp+48h]
    lea     rax,[r11+r15*8]
    mov     rbp,r14
    imul    rbp,7
    mov     r11,[rsp+48h]
    lea     rcx,[r11+rbp*8]
    mov     rdi,[rsp+48h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+28h]
    call    image.fn58
    mov     rbx,rax
    lea     rax,[r12+r15*8]
    lea     rcx,[r12+rbp*8]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+28h]
    call    image.fn58
    mov     r12,rax
    lea     rax,[r13+r15*8]
    lea     rcx,[r13+rbp*8]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,[rsp+28h]
    call    image.fn58
    mov     r11,[rsp+28h]
    mov     r11,[r11]
    mov     ecx,[rbx]
    mov     edi,[r12]
    cmp     ecx,edi
    setb    r8b
    mov     r9d,[rax]
    cmp     ecx,r9d
    setb    cl
    cmp     r8b,cl
    jne     L21
    cmp     edi,r9d
    setb    cl
    xor     ecx,r8d
    test    cl,cl
    je      L20
    jmp     L22
L20:
    mov     rax,r12
    jmp     L22
L21:
    mov     rax,rbx
L22:
    lea     rcx,[image.k1464]
    cmp     rax,[rsp+48h]
    jb      L36
    sub     rax,[rsp+48h]
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
L23:
    cmp     rax,[rsp+40h]
    setb    dil
    lea     r8,[image.k1512]
    test    dil,dil
    je      L37
    mov     r11,[rsp+48h]
    lea     rdi,[r11+rax*8]
    mov     rdi,[rdi]
    mov     [rsp+3B0h],rdi
    lea     rdi,[rsp+3B0h]
    mov     [rsp+398h],rdi
    mov     r9,[rsp+48h]
    mov     rbx,[rsp+40h]
    mov     r12,rax
    mov     r13,[rsp+28h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+70h]
    mov     rax,rdi
    mov     rdi,[rsp+20h]
    jmp     L31
L24:
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+80h]
    jae     L38
    mov     r10,[rsp+78h]
    lea     rbx,[rdi+r10*8]
    mov     [rsp+390h],rbx
    mov     [rsp+398h],rax
    mov     r11,[r12]
    mov     r9d,[rax]
    mov     ebx,[rbx]
    cmp     r9d,ebx
    setb    r9b
    mov     rbx,r9
    xor     ebx,1
    cmp     r9b,1
    jne     L25
    jmp     L26
L25:
    mov     r11,[rsp+80h]
    mov     [rsp+0A0h],r11
    mov     [rsp+0A8h],r15
    mov     r15,r13
    mov     r13,rbp
    mov     rbp,r14
    mov     r14,r12
    mov     r12,rdi
    mov     edi,0
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+78h]
    jmp     L28
L26:
    mov     rbx,rdi
    mov     [rsp+88h],r15
    mov     r15,r14
    mov     r14,r13
    mov     r13,r12
    mov     r12,[rsp+80h]
    mov     [rsp+90h],rbp
    mov     rbp,[rsp+78h]
    mov     [rsp+98h],rax
    jmp     L27
L27:
    mov     [rsp],r13
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,rbp
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    cmp     rax,0
    sete    dil
    mov     [rsp+0A0h],r12
    mov     r12,rbx
    mov     rbx,rdi
    mov     rdi,rax
    mov     rax,rbp
    mov     rbp,r15
    mov     r15,r14
    mov     r14,r13
    mov     r11,[rsp+88h]
    mov     [rsp+0A8h],r11
    mov     r13,[rsp+90h]
    mov     r11,[rsp+98h]
    mov     [rsp+0B0h],r11
L28:
    test    bl,bl
    je      L29
    mov     [rsp+398h],r12
    mov     [rsp+388h],r14
    lea     r9,[rsp+388h]
    mov     [rsp+390h],r9
    mov     [rsp],r9
    mov     rdi,r12
    mov     rsi,[rsp+0A0h]
    mov     rdx,r15
    mov     rcx,rbp
    mov     r8,rax
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     [rsp+0B8h],rax
    mov     r11,[rsp+0A0h]
    cmp     r11,[rsp+0B8h]
    jb      L39
    mov     r9,[rsp+0A0h]
    sub     r9,[rsp+0B8h]
    mov     [rsp+398h],r9
    mov     r10,[rsp+0A0h]
    mov     [rsp+380h],r10
    mov     r10,[rsp+0B8h]
    lea     rbx,[r12+r10*8]
    mov     [rsp+388h],rbx
    mov     [rsp+390h],r9
    mov     [rsp+48h],rbx
    mov     [rsp+40h],r9
    mov     [rsp+38h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+28h],r14
    mov     r8,[rsp+0A8h]
    mov     qword ptr [rsp+20h],0
    jmp     L0
L29:
    lea     r9,[k12]
    lea     rbx,[rsp+380h]
    mov     rsi,r12
    mov     rdx,[rsp+0A0h]
    mov     rcx,rdi
    mov     rdi,rbx
    mov     r8,r9
    call    qword ptr [fn13.slot]
    mov     rbx,[rsp+380h]
    mov     r12,[rsp+388h]
    mov     rdi,[rsp+390h]
    mov     r9,[rsp+398h]
    mov     [rsp],r14
    mov     rsi,r9
    mov     rdx,r15
    mov     rcx,rbp
    mov     r8,[rsp+0A8h]
    mov     r9,r13
    mov     r8d,r8d
    call    fn14
    mov     [rsp+48h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+38h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+28h],r14
    mov     r8,[rsp+0A8h]
    mov     r11,[rsp+0B0h]
    mov     [rsp+20h],r11
    jmp     L0
L30:
    mov     rbx,[rsp+370h]
    mov     r12,[rsp+360h]
    mov     r13,[rsp+350h]
    mov     r14,[rsp+340h]
    mov     r15,[rsp+330h]
    mov     rbp,[rsp+320h]
    add     rsp,478h
    ret
L31:
    cmp     rdi,0
    je      L32
    mov     [rsp+80h],rbx
    mov     [rsp+78h],r12
    mov     r12,r13
    mov     r13,r14
    mov     r14,r15
    mov     r15,rbp
    mov     rbp,rax
    mov     rax,rdi
    mov     rdi,r9
    jmp     L24
L32:
    mov     [rsp+88h],rbp
    mov     rbp,r12
    mov     r12,rbx
    mov     rbx,r9
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdi
    jmp     L27
L33:
    lea     rax,[image.k10183]
    mov     rdi,rax
    mov     esi,1B5h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L34:
    lea     rax,[image.k2928]
    mov     rdi,rax
    call    image.sym28
    ud2
L35:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     edx,0
    mov     rcx,rsi
    mov     esi,193h
    movzx   edx,dl
    call    image.sym49
    ud2
L36:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L37:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L38:
    lea     rax,[k7]
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,rax
    call    sym5
    ud2
L39:
    lea     rax,[k15]
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+0A0h]
    mov     rcx,rax
    call    sym16
    ud2
  ; OSR entries
    lea     r11,[L40]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L40:
    .long   L41
    .long   L42
    .long   L43
    .long   L44
L41:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-4B0h]
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-470h],r11
    mov     r11,[rsp]
    mov     [rdx-428h],r11
    mov     r11,[rsp+8]
    mov     [rdx-430h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-438h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-440h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-448h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-450h],r11
    mov     r8,[rsp+28h]
    lea     rsp,[rsp+40h]
    jmp     L0
L42:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-4C0h]
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-470h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-3F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-3F8h],r11
    mov     rax,[rsp]
    mov     rdi,[rsp+8]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+28h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+38h]
    mov     rbp,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L24
L43:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-4C0h]
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-470h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-3E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-3E0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-3D8h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L27
L44:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-4C0h]
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-470h],r11
    mov     rdi,[rsp]
    mov     r9,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+38h]
    mov     rax,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L31

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
    sub     rsp,238h
    mov     [rsp+120h],rbx
    mov     [rsp+110h],r12
    mov     [rsp+100h],r13
    mov     [rsp+0F0h],r14
    mov     [rsp+0E0h],r15
    mov     [rsp+0D0h],rbp
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],r8
    mov     [rsp+40h],r9
    mov     r11,[rsp+240h]
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
    lea     rdi,[rsp+230h]
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
    mov     rdx,[rsp+138h]
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
    mov     rdi,[rsp+148h]
    lea     rdi,[rdi-8]
    mov     [rsp+148h],rdi
    test    dl,dl
    jne     L2
    mov     rdx,[rsp+130h]
    jmp     L3
L2:
    mov     rdx,rdi
L3:
    mov     rdi,[rsp+140h]
    lea     rdx,[rdx+rdi*8]
    mov     rdi,[rsp+138h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r8,rdi
    and     r8,3
    cmp     r8,0
    je      L8
    jmp     L74
L4:
    mov     r8,rdx
    and     r8,3
    cmp     r8,0
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
    mov     r8,[rdi]
    mov     [rdx],r8
    movzx   r8d,sil
    mov     r9,[rsp+140h]
    add     r9,r8
    mov     [rsp+140h],r9
    mov     r8,[rsp+138h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+138h],r9
    mov     r9,[r14]
    mov     r11,[r9]
    mov     r9d,[r13]
    mov     r8d,[r8+8]
    cmp     r9d,r8d
    setb    r8b
    mov     r9,r8
    xor     r9d,1
    mov     rax,[rsp+148h]
    lea     rax,[rax-8]
    mov     [rsp+148h],rax
    test    r8b,r8b
    jne     L11
    jmp     L10
L8:
    cmp     rdi,0
    je      L74
    jmp     L4
L9:
    cmp     rdx,0
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+130h]
    jmp     L12
L11:
    mov     rdx,rax
L12:
    mov     rax,[rsp+140h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+138h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     rdi,rax
    and     rdi,3
    cmp     rdi,0
    je      L17
    jmp     L75
L13:
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
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
    mov     rdi,[rax]
    mov     [rdx],rdi
    movzx   edi,r9b
    mov     r8,[rsp+140h]
    add     r8,rdi
    mov     [rsp+140h],r8
    mov     rdi,[rsp+138h]
    mov     r8,rdi
    lea     r8,[r8+8]
    mov     [rsp+138h],r8
    mov     r8,[r14]
    mov     r11,[r8]
    mov     r8d,[r13]
    mov     edi,[rdi+8]
    cmp     r8d,edi
    setb    dil
    mov     r8,rdi
    xor     r8d,1
    mov     rsi,[rsp+148h]
    lea     rsi,[rsi-8]
    mov     [rsp+148h],rsi
    test    dil,dil
    jne     L20
    jmp     L19
L17:
    cmp     rax,0
    je      L75
    jmp     L13
L18:
    cmp     rdx,0
    je      L75
    jmp     L14
L19:
    mov     rax,[rsp+130h]
    jmp     L21
L20:
    mov     rax,rsi
L21:
    mov     rdx,[rsp+140h]
    lea     rax,[rax+rdx*8]
    mov     rdx,[rsp+138h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
    je      L26
    jmp     L76
L22:
    mov     rdi,rax
    and     rdi,3
    cmp     rdi,0
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
    mov     rdi,[rdx]
    mov     [rax],rdi
    movzx   edi,r8b
    mov     r9,[rsp+140h]
    add     r9,rdi
    mov     [rsp+140h],r9
    mov     rdi,[rsp+138h]
    mov     r9,rdi
    lea     r9,[r9+8]
    mov     [rsp+138h],r9
    mov     r9,[r14]
    mov     r11,[r9]
    mov     r9d,[r13]
    mov     edi,[rdi+8]
    cmp     r9d,edi
    setb    dil
    mov     r9,rdi
    xor     r9d,1
    mov     [rsp+0C6h],r9b
    mov     rsi,[rsp+148h]
    lea     rsi,[rsi-8]
    mov     [rsp+148h],rsi
    test    dil,dil
    jne     L29
    jmp     L28
L26:
    cmp     rdx,0
    je      L76
    jmp     L22
L27:
    cmp     rax,0
    je      L76
    jmp     L23
L28:
    mov     rax,[rsp+130h]
    jmp     L30
L29:
    mov     rax,rsi
L30:
    mov     rdx,[rsp+140h]
    lea     rax,[rax+rdx*8]
    mov     rdx,[rsp+138h]
    lea     r11,[image.k6632]
    mov     [rsp+0B0h],r11
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
    je      L35
    jmp     L77
L31:
    mov     rdi,rax
    and     rdi,3
    cmp     rdi,0
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
    mov     rdi,[rdx]
    mov     [rax],rdi
    movzx   edi,r9b
    mov     r8,[rsp+140h]
    add     r8,rdi
    mov     [rsp+140h],r8
    mov     rdi,[rsp+138h]
    lea     rdi,[rdi+8]
    mov     [rsp+138h],rdi
    jmp     L1
L35:
    cmp     rdx,0
    je      L77
    jmp     L31
L36:
    cmp     rax,0
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
    mov     rdx,[rsp+138h]
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
    mov     r8,[rsp+148h]
    lea     r8,[r8-8]
    mov     [rsp+148h],r8
    test    dl,dl
    jne     L39
    mov     rdx,[rsp+130h]
    jmp     L40
L39:
    mov     rdx,r8
L40:
    mov     r8,[rsp+140h]
    lea     rdx,[rdx+r8*8]
    mov     r8,[rsp+138h]
    lea     r11,[image.k6632]
    mov     [rsp+0A8h],r11
    mov     r9,r8
    and     r9,3
    cmp     r9,0
    je      L45
    jmp     L78
L41:
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
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
    mov     r9,[r8]
    mov     [rdx],r9
    movzx   r9d,dil
    mov     rsi,[rsp+140h]
    add     rsi,r9
    mov     [rsp+140h],rsi
    mov     rsi,[rsp+138h]
    lea     rsi,[rsi+8]
    mov     [rsp+138h],rsi
    jmp     L38
L45:
    cmp     r8,0
    je      L78
    jmp     L41
L46:
    cmp     rdx,0
    je      L78
    jmp     L42
L47:
    cmp     rbx,r15
    je      L56
    lea     rax,[rsp+130h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+148h]
    lea     rax,[rax-8]
    mov     [rsp+148h],rax
    test    bpl,bpl
    je      L48
    mov     rdx,[rsp+130h]
    jmp     L49
L48:
    mov     rdx,rax
L49:
    mov     rax,[rsp+140h]
    lea     rdx,[rdx+rax*8]
    mov     rax,[rsp+138h]
    lea     rsi,[image.k6632]
    mov     rdi,rax
    and     rdi,3
    cmp     rdi,0
    je      L54
    jmp     L79
L50:
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
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
    mov     rdi,[rax]
    mov     [rdx],rdi
    movzx   edi,bpl
    mov     r8,[rsp+140h]
    add     r8,rdi
    mov     [rsp+140h],r8
    mov     rdi,[rsp+138h]
    lea     rdi,[rdi+8]
    mov     [rsp+138h],rdi
    mov     rbx,r15
    mov     r11,[rsp+98h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],rcx
    mov     r11,[rsp+0A0h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    cmp     rax,0
    je      L79
    jmp     L50
L55:
    cmp     rdx,0
    je      L79
    jmp     L51
L56:
    mov     [rsp+0C0h],rcx
    mov     rax,[rsp+140h]
    lea     rdx,[k15]
    cmp     rax,0
    jne     L57
    mov     edi,1
    jmp     L58
L57:
    mov     edi,0
L58:
    mov     r8,rcx
    and     r8,3
    cmp     r8,0
    je      L63
    jmp     L81
L59:
    mov     r8,[rsp+98h]
    and     r8,3
    cmp     r8,0
    je      L64
    jmp     L81
L60:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     r11
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
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
    cmp     r8,r9
    ja      L81
    mov     r8,rax
    imul    r8,8
    mov     r11,[rsp+98h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],r8
    lea     rdi,[rsp+230h]
    mov     esi,0FFFFFDE0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDE8h
    call    ryo_h_Memcpy
    mov     r8,[rsp+140h]
    mov     r11,r15
    sub     r11,r8
    mov     r8,r11
    mov     [rsp+0C0h],r8
    mov     eax,0
    mov     rcx,[rsp+0A0h]
    mov     rdi,[rsp+98h]
    jmp     L65
L63:
    test    dil,dil
    jne     L59
    cmp     rcx,0
    je      L81
    jmp     L59
L64:
    test    dil,dil
    jne     L60
    mov     r11,[rsp+98h]
    cmp     r11,0
    je      L81
    jmp     L60
L65:
    cmp     rax,r8
    jae     L73
    mov     r9,rax
    add     r9,1
    mov     [rsp+0C0h],rax
    mov     rbx,r15
    sub     rbx,1
    sub     rbx,rax
    lea     rbx,[rcx+rbx*8]
    mov     r12,[rsp+140h]
    add     r12,rax
    lea     rax,[rdi+r12*8]
    lea     r12,[k19]
    mov     r13,rbx
    and     r13,3
    cmp     r13,0
    je      L70
    jmp     L82
L66:
    mov     r13,rax
    and     r13,3
    cmp     r13,0
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
    mov     r13,[rbx]
    mov     [rax],r13
    mov     rax,r9
    jmp     L65
L70:
    cmp     rbx,0
    je      L82
    jmp     L66
L71:
    cmp     rax,0
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
    mov     [rsp+130h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+138h],r10
    mov     qword ptr [rsp+140h],0
    mov     [rsp+148h],rcx
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
    mov     rax,[rsp+140h]
    mov     rbx,[rsp+120h]
    mov     r12,[rsp+110h]
    mov     r13,[rsp+100h]
    mov     r14,[rsp+0F0h]
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+0D0h]
    add     rsp,238h
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
    mov     rcx,rdx
    mov     edx,0
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
    lea     rdi,[rsp+230h]
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
    lea     rsp,[rdx-290h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-210h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-200h],r11
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
    lea     rsp,[rdx-2A0h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1C0h],r11
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
    lea     rsp,[rdx-2A0h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-190h],r11
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
    lea     rsp,[rdx-270h]
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
    mov     [rdx-230h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     rax,[rsp]
    mov     r8,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,228h
    mov     [rsp+110h],rbx
    mov     [rsp+100h],r12
    mov     [rsp+0F0h],r13
    mov     [rsp+0E0h],r14
    mov     [rsp+0D0h],r15
    mov     [rsp+0C0h],rbp
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],r8
    mov     [rsp+40h],r9
    mov     r11,[rsp+230h]
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
    lea     rdi,[rsp+220h]
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
    mov     rdx,[rsp+128h]
    cmp     rdx,rcx
    jae     L37
    mov     r11,[r14]
    mov     edx,[rdx]
    mov     esi,[r13]
    cmp     edx,esi
    setb    dl
    mov     rsi,[rsp+138h]
    lea     rsi,[rsi-8]
    mov     [rsp+138h],rsi
    test    dl,dl
    je      L2
    mov     rdi,[rsp+120h]
    jmp     L3
L2:
    mov     rdi,rsi
L3:
    mov     rsi,[rsp+130h]
    lea     rdi,[rdi+rsi*8]
    mov     rsi,[rsp+128h]
    lea     r11,[image.k6632]
    mov     [rsp+68h],r11
    mov     r8,rsi
    and     r8,3
    cmp     r8,0
    je      L8
    jmp     L74
L4:
    mov     r8,rdi
    and     r8,3
    cmp     r8,0
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
    mov     r8,[rsi]
    mov     [rdi],r8
    movzx   r8d,dl
    mov     r9,[rsp+130h]
    add     r9,r8
    mov     [rsp+130h],r9
    mov     r8,[rsp+128h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+128h],r9
    mov     r11,[r14]
    mov     r8d,[r8+8]
    mov     r9d,[r13]
    cmp     r8d,r9d
    setb    r8b
    mov     r9,[rsp+138h]
    lea     r9,[r9-8]
    mov     [rsp+138h],r9
    test    r8b,r8b
    jne     L10
    jmp     L11
L8:
    cmp     rsi,0
    je      L74
    jmp     L4
L9:
    cmp     rdi,0
    je      L74
    jmp     L5
L10:
    mov     rdx,[rsp+120h]
    jmp     L12
L11:
    mov     rdx,r9
L12:
    mov     rsi,[rsp+130h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+128h]
    lea     r11,[image.k6632]
    mov     [rsp+80h],r11
    mov     r9,rsi
    and     r9,3
    cmp     r9,0
    je      L17
    jmp     L75
L13:
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
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
    mov     r9,[rsi]
    mov     [rdx],r9
    movzx   r9d,r8b
    mov     rdi,[rsp+130h]
    add     rdi,r9
    mov     [rsp+130h],rdi
    mov     rdi,[rsp+128h]
    mov     r9,rdi
    lea     r9,[r9+8]
    mov     [rsp+128h],r9
    mov     r11,[r14]
    mov     edi,[rdi+8]
    mov     r9d,[r13]
    cmp     edi,r9d
    setb    dil
    mov     r9,[rsp+138h]
    lea     r9,[r9-8]
    mov     [rsp+138h],r9
    test    dil,dil
    jne     L19
    jmp     L20
L17:
    cmp     rsi,0
    je      L75
    jmp     L13
L18:
    cmp     rdx,0
    je      L75
    jmp     L14
L19:
    mov     rdx,[rsp+120h]
    jmp     L21
L20:
    mov     rdx,r9
L21:
    mov     rsi,[rsp+130h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+128h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     r9,rsi
    and     r9,3
    cmp     r9,0
    je      L26
    jmp     L76
L22:
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
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
    mov     r9,[rsi]
    mov     [rdx],r9
    movzx   r9d,dil
    mov     r8,[rsp+130h]
    add     r8,r9
    mov     [rsp+130h],r8
    mov     r8,[rsp+128h]
    mov     r9,r8
    lea     r9,[r9+8]
    mov     [rsp+128h],r9
    mov     r11,[r14]
    mov     r8d,[r8+8]
    mov     r9d,[r13]
    cmp     r8d,r9d
    setb    r8b
    mov     [rsp+0B6h],r8b
    mov     r9,[rsp+138h]
    lea     r9,[r9-8]
    mov     [rsp+138h],r9
    test    r8b,r8b
    jne     L28
    jmp     L29
L26:
    cmp     rsi,0
    je      L76
    jmp     L22
L27:
    cmp     rdx,0
    je      L76
    jmp     L23
L28:
    mov     rdx,[rsp+120h]
    jmp     L30
L29:
    mov     rdx,r9
L30:
    mov     rsi,[rsp+130h]
    lea     rdx,[rdx+rsi*8]
    mov     rsi,[rsp+128h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     r9,rsi
    and     r9,3
    cmp     r9,0
    je      L35
    jmp     L77
L31:
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
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
    mov     r9,[rsi]
    mov     [rdx],r9
    movzx   r9d,r8b
    mov     rdi,[rsp+130h]
    add     rdi,r9
    mov     [rsp+130h],rdi
    mov     rdi,[rsp+128h]
    lea     rdi,[rdi+8]
    mov     [rsp+128h],rdi
    jmp     L1
L35:
    cmp     rsi,0
    je      L77
    jmp     L31
L36:
    cmp     rdx,0
    je      L77
    jmp     L32
L37:
    mov     [rsp+0B0h],rbx
    lea     rcx,[r12+rbx*8]
    mov     [rsp+98h],rax
    mov     rax,[rsp+78h]
    mov     r11,[rsp+70h]
    mov     [rsp+0A0h],r11
L38:
    mov     rdx,[rsp+128h]
    cmp     rdx,rcx
    jae     L47
    mov     r11,[r14]
    mov     edx,[rdx]
    mov     esi,[r13]
    cmp     edx,esi
    setb    dl
    mov     [rsp+0B6h],dl
    mov     rsi,[rsp+138h]
    lea     rsi,[rsi-8]
    mov     [rsp+138h],rsi
    test    dl,dl
    je      L39
    mov     rdi,[rsp+120h]
    jmp     L40
L39:
    mov     rdi,rsi
L40:
    mov     rsi,[rsp+130h]
    lea     rdi,[rdi+rsi*8]
    mov     rsi,[rsp+128h]
    lea     r11,[image.k6632]
    mov     [rsp+0A8h],r11
    mov     r9,rsi
    and     r9,3
    cmp     r9,0
    je      L45
    jmp     L78
L41:
    mov     r9,rdi
    and     r9,3
    cmp     r9,0
    je      L46
    jmp     L78
L42:
    cmp     rsi,rdi
    jae     L43
    mov     r9,rdi
    sub     r9,rsi
    jmp     L44
L43:
    mov     r9,rsi
    sub     r9,rdi
L44:
    cmp     r9,8
    jb      L78
    mov     r9,[rsi]
    mov     [rdi],r9
    movzx   r9d,dl
    mov     r8,[rsp+130h]
    add     r8,r9
    mov     [rsp+130h],r8
    mov     r8,[rsp+128h]
    lea     r8,[r8+8]
    mov     [rsp+128h],r8
    jmp     L38
L45:
    cmp     rsi,0
    je      L78
    jmp     L41
L46:
    cmp     rdi,0
    je      L78
    jmp     L42
L47:
    cmp     rbx,r15
    je      L56
    lea     rcx,[rsp+120h]
    mov     [rsp+0B0h],rcx
    mov     rcx,[rsp+138h]
    lea     rcx,[rcx-8]
    mov     [rsp+138h],rcx
    test    bpl,bpl
    je      L48
    mov     rdx,[rsp+120h]
    jmp     L49
L48:
    mov     rdx,rcx
L49:
    mov     rcx,[rsp+130h]
    lea     rdx,[rdx+rcx*8]
    mov     rcx,[rsp+128h]
    lea     rsi,[image.k6632]
    mov     rdi,rcx
    and     rdi,3
    cmp     rdi,0
    je      L54
    jmp     L79
L50:
    mov     rdi,rdx
    and     rdi,3
    cmp     rdi,0
    je      L55
    jmp     L79
L51:
    cmp     rcx,rdx
    jae     L52
    mov     rdi,rdx
    sub     rdi,rcx
    jmp     L53
L52:
    mov     rdi,rcx
    sub     rdi,rdx
L53:
    cmp     rdi,8
    jb      L79
    mov     rdi,[rcx]
    mov     [rdx],rdi
    movzx   edi,bpl
    mov     r8,[rsp+130h]
    add     r8,rdi
    mov     [rsp+130h],r8
    mov     rdi,[rsp+128h]
    lea     rdi,[rdi+8]
    mov     [rsp+128h],rdi
    mov     rbx,r15
    mov     r11,[rsp+98h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],rax
    mov     r11,[rsp+0A0h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    cmp     rcx,0
    je      L79
    jmp     L50
L55:
    cmp     rdx,0
    je      L79
    jmp     L51
L56:
    mov     [rsp+0B0h],rax
    mov     rcx,[rsp+130h]
    lea     rdx,[k15]
    cmp     rcx,0
    jne     L57
    mov     edi,1
    jmp     L58
L57:
    mov     edi,0
L58:
    mov     r8,rax
    and     r8,3
    cmp     r8,0
    je      L63
    jmp     L81
L59:
    mov     r8,[rsp+98h]
    and     r8,3
    cmp     r8,0
    je      L64
    jmp     L81
L60:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     rcx
    mov     r8,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L80
    cmp     rax,[rsp+98h]
    jae     L61
    mov     r9,[rsp+98h]
    sub     r9,rax
    jmp     L62
L61:
    mov     r9,rax
    sub     r9,[rsp+98h]
L62:
    cmp     r8,r9
    ja      L81
    mov     r8,rcx
    imul    r8,8
    mov     r11,[rsp+98h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],r8
    lea     rdi,[rsp+220h]
    mov     esi,0FFFFFDF0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDF8h
    call    ryo_h_Memcpy
    mov     r8,[rsp+130h]
    mov     r11,r15
    sub     r11,r8
    mov     r8,r11
    mov     [rsp+0B0h],r8
    mov     eax,0
    mov     rcx,[rsp+0A0h]
    mov     rdi,[rsp+98h]
    jmp     L65
L63:
    test    dil,dil
    jne     L59
    cmp     rax,0
    je      L81
    jmp     L59
L64:
    test    dil,dil
    jne     L60
    mov     r11,[rsp+98h]
    cmp     r11,0
    je      L81
    jmp     L60
L65:
    cmp     rax,r8
    jae     L73
    mov     r9,rax
    add     r9,1
    mov     [rsp+0B0h],rax
    mov     rbx,r15
    sub     rbx,1
    sub     rbx,rax
    lea     rbx,[rcx+rbx*8]
    mov     r12,[rsp+130h]
    add     r12,rax
    lea     rax,[rdi+r12*8]
    lea     r12,[k19]
    mov     r13,rbx
    and     r13,3
    cmp     r13,0
    je      L70
    jmp     L82
L66:
    mov     r13,rax
    and     r13,3
    cmp     r13,0
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
    mov     r13,[rbx]
    mov     [rax],r13
    mov     rax,r9
    jmp     L65
L70:
    cmp     rbx,0
    je      L82
    jmp     L66
L71:
    cmp     rax,0
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
    mov     [rsp+120h],r10
    mov     r10,[rsp+60h]
    mov     [rsp+128h],r10
    mov     qword ptr [rsp+130h],0
    mov     [rsp+138h],rcx
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
    mov     rax,[rsp+130h]
    mov     rbx,[rsp+110h]
    mov     r12,[rsp+100h]
    mov     r13,[rsp+0F0h]
    mov     r14,[rsp+0E0h]
    mov     r15,[rsp+0D0h]
    mov     rbp,[rsp+0C0h]
    add     rsp,228h
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
    mov     rcx,rdx
    mov     edx,0
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
    lea     rdi,[rsp+220h]
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
    lea     rsp,[rdx-280h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1F0h],r11
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
    lea     rsp,[rdx-290h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1B0h],r11
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
    lea     rsp,[rdx-290h]
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
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+50h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-180h],r11
    mov     rcx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbx,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    mov     rax,[rsp+40h]
    lea     rsp,[rsp+70h]
    jmp     L38
L88:
    ret
L89:
    ret
L90:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-260h]
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
    mov     [rdx-220h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     rax,[rsp]
    mov     r8,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
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
    cmp     r8,0
    je      L1
    jmp     L7
L0:
    mov     r8d,[rcx]
    mov     [rdx],r8d
    jmp     L2
L1:
    cmp     rcx,0
    je      L7
    mov     r8,rdx
    and     r8,3
    cmp     r8,0
    jne     L7
    cmp     rdx,0
    je      L7
    jmp     L0
L2:
    mov     rdx,[rsi+10h]
    lea     r8,[k3]
    mov     r9,rdx
    and     r9,3
    cmp     r9,0
    je      L6
    jmp     L8
L3:
    mov     r9,rcx
    and     r9,3
    cmp     r9,0
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
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L6:
    cmp     rdx,0
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
    sub     rsp,398h
    mov     [rsp+2C0h],rbx
    mov     [rsp+2B0h],r12
    mov     [rsp+2A0h],r13
    mov     [rsp+290h],r14
    mov     [rsp+280h],r15
    mov     [rsp+270h],rbp
    mov     [rsp+30h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+20h],r8
    mov     [rsp+28h],rdx
L0:
    mov     r11d,20h
    cmp     r11,[rsp+10h]
    jb      L60
    mov     r11,[rsp+10h]
    cmp     r11,2
    jb      L119
    mov     r11,[rsp+10h]
    shr     r11,1
    mov     [rsp+40h],r11
    mov     r11,[rsp+10h]
    cmp     r11,12h
    setb    [rsp+38h]
    cmp     byte ptr [rsp+38h],0
    je      L1
    mov     r12,[rsp+10h]
    jmp     L2
L1:
    mov     r12,[rsp+40h]
L2:
    lea     r11,[image.k2160]
    mov     [rsp+18h],r11
    mov     rdi,[rsp+30h]
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L4
    jmp     L120
L3:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r12,rax
    ja      L120
    mov     r11,[rsp+30h]
    mov     [rsp+58h],r11
    mov     [rsp+60h],r12
    jmp     L5
L4:
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L120
    jmp     L3
L5:
    mov     r11,[rsp+60h]
    cmp     r11,0Dh
    jb      L43
    mov     rdi,[rsp+58h]
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,2
    mov     edx,9
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,3
    mov     edx,7
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,1
    mov     edx,6
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,7
    mov     edx,9
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0
    mov     edx,4
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0Bh
    mov     edx,0Ch
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,4
    mov     edx,6
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,5
    mov     edx,9
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0
    mov     edx,5
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,4
    mov     edx,7
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,2
    mov     edx,5
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,6
    mov     edx,9
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     rdi,[rsp+58h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+20h]
    call    image.fn72
    mov     r11,[rsp+58h]
    lea     r11,[r11+18h]
    mov     [rsp+68h],r11
    mov     rbx,[rsp+58h]
    lea     rbx,[rbx+1Ch]
    mov     rdi,rbx
    mov     rsi,[rsp+68h]
    call    qword ptr [image.fn206.slot]
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,[rsp+68h]
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,rbp
    mov     rsi,[rsp+68h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+120h],eax
    lea     r11,[image.k2088]
    mov     [rsp+48h],r11
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L7
    jmp     L122
L6:
    mov     eax,[r15]
    mov     r11,[rsp+58h]
    mov     [r11+18h],eax
    lea     rbp,[rsp+120h]
    lea     r11,[image.k2112]
    mov     [rsp+50h],r11
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    jmp     L10
L7:
    cmp     r15,0
    je      L122
    mov     rdi,[rsp+68h]
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L9
L8:
    mov     r11,[rsp+68h]
    cmp     r11,0
    je      L122
    jmp     L6
L9:
    test    dl,dl
    jne     L8
    jmp     L122
L10:
    test    al,al
    jne     L13
    jmp     L124
L11:
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L14
    jmp     L124
L12:
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L124
    mov     eax,[rsp+120h]
    mov     r11,[rsp+58h]
    mov     [r11+1Ch],eax
    mov     r15,[rsp+58h]
    lea     r15,[r15+20h]
    mov     r12,[rsp+58h]
    lea     r12,[r12+24h]
    mov     rdi,r12
    mov     rsi,r15
    call    qword ptr [image.fn206.slot]
    mov     r13,rax
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     r14,rax
    mov     rdi,r13
    mov     rsi,r15
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+130h],eax
    lea     r11,[image.k2088]
    mov     [rsp+78h],r11
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    jmp     L15
L13:
    cmp     rbp,0
    je      L124
    jmp     L11
L14:
    cmp     rbx,0
    je      L124
    jmp     L12
L15:
    test    al,al
    jne     L17
    jmp     L126
L16:
    mov     eax,[r14]
    mov     r11,[rsp+58h]
    mov     [r11+20h],eax
    lea     rbx,[rsp+130h]
    lea     r11,[image.k2112]
    mov     [rsp+70h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L20
L17:
    cmp     r14,0
    je      L126
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L19
L18:
    cmp     r15,0
    je      L126
    jmp     L16
L19:
    test    dl,dl
    jne     L18
    jmp     L126
L20:
    test    al,al
    jne     L23
    jmp     L128
L21:
    mov     rdi,r12
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L24
    jmp     L128
L22:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L128
    mov     eax,[rsp+130h]
    mov     r11,[rsp+58h]
    mov     [r11+24h],eax
    mov     r14,[rsp+58h]
    lea     r14,[r14+0Ch]
    mov     r15,[rsp+58h]
    lea     r15,[r15+10h]
    mov     rdi,r15
    mov     rsi,r14
    call    qword ptr [image.fn206.slot]
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+140h],eax
    lea     r11,[image.k2088]
    mov     [rsp+0A8h],r11
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    jmp     L25
L23:
    cmp     rbx,0
    je      L128
    jmp     L21
L24:
    cmp     r12,0
    je      L128
    jmp     L22
L25:
    test    al,al
    jne     L27
    jmp     L130
L26:
    mov     eax,[r13]
    mov     r11,[rsp+58h]
    mov     [r11+0Ch],eax
    lea     rbx,[rsp+140h]
    lea     r11,[image.k2112]
    mov     [rsp+80h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L30
L27:
    cmp     r13,0
    je      L130
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L29
L28:
    cmp     r14,0
    je      L130
    jmp     L26
L29:
    test    dl,dl
    jne     L28
    jmp     L130
L30:
    test    al,al
    jne     L33
    jmp     L132
L31:
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L34
    jmp     L132
L32:
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L132
    mov     eax,[rsp+140h]
    mov     r11,[rsp+58h]
    mov     [r11+10h],eax
    mov     r13,[rsp+58h]
    lea     r13,[r13+14h]
    mov     rdi,[rsp+68h]
    mov     rsi,r13
    call    qword ptr [image.fn206.slot]
    mov     r14,rax
    mov     rdi,r14
    mov     rsi,[rsp+68h]
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r12,rax
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,[rsp+68h]
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+150h],eax
    lea     r11,[image.k2088]
    mov     [rsp+0A0h],r11
    mov     rdi,r12
    mov     esi,4
    call    image.fn155
    jmp     L35
L33:
    cmp     rbx,0
    je      L132
    jmp     L31
L34:
    cmp     r15,0
    je      L132
    jmp     L32
L35:
    test    al,al
    jne     L37
    jmp     L134
L36:
    mov     eax,[r12]
    mov     r11,[rsp+58h]
    mov     [r11+14h],eax
    lea     rbx,[rsp+150h]
    lea     r11,[image.k2112]
    mov     [rsp+88h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L40
L37:
    cmp     r12,0
    je      L134
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L39
L38:
    cmp     r13,0
    je      L134
    jmp     L36
L39:
    test    dl,dl
    jne     L38
    jmp     L134
L40:
    test    al,al
    jne     L42
    jmp     L136
L41:
    mov     rdi,[rsp+68h]
    mov     esi,4
    call    image.fn155
    test    al,al
    je      L136
    mov     rdi,rbx
    mov     rsi,[rsp+68h]
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L136
    mov     eax,[rsp+150h]
    mov     r11,[rsp+58h]
    mov     [r11+18h],eax
    mov     eax,0Dh
    jmp     L45
L42:
    cmp     rbx,0
    je      L136
    jmp     L41
L43:
    mov     r11,[rsp+60h]
    cmp     r11,9
    jb      L44
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+20h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L45
L44:
    mov     eax,1
L45:
    cmp     rax,0
    je      L142
    mov     r11,[rsp+60h]
    cmp     r11,rax
    jb      L142
    mov     r11,[rsp+58h]
    mov     r10,[rsp+60h]
    lea     rbx,[r11+r10*4]
    mov     r11,[rsp+58h]
    lea     rax,[r11+rax*4]
    mov     r12,rax
L46:
    cmp     r12,rbx
    je      L56
    mov     r13,r12
    lea     r13,[r13-4]
    mov     [rsp+160h],r12
    mov     [rsp+168h],r12
    mov     [rsp+170h],r13
    mov     rdi,r12
    mov     rsi,r13
    call    qword ptr [image.fn206.slot]
    mov     [rsp+15Fh],al
    test    al,al
    je      L54
    mov     [rsp+170h],r12
    mov     eax,[r12]
    mov     [rsp+174h],eax
    mov     [rsp+15Ch],eax
    lea     rax,[rsp+15Ch]
    mov     [rsp+160h],rax
    mov     [rsp+168h],r12
    mov     qword ptr [rsp+170h],1
L47:
    mov     r15,[rsp+168h]
    lea     r11,[image.k1728]
    mov     [rsp+90h],r11
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L50
    jmp     L138
L48:
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L51
    jmp     L138
L49:
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L138
    mov     eax,[r13]
    mov     [r15],eax
    mov     [rsp+168h],r13
    cmp     r13,[rsp+58h]
    je      L53
    jmp     L55
L50:
    cmp     r13,0
    je      L138
    jmp     L48
L51:
    cmp     r15,0
    je      L138
    jmp     L49
L52:
    mov     r13,r15
    jmp     L47
L53:
    lea     rax,[rsp+160h]
    mov     rdi,rax
    call    qword ptr [image.fn229.slot]
L54:
    mov     rax,r12
    lea     rax,[rax+4]
    mov     r12,rax
    jmp     L46
L55:
    mov     r15,r13
    lea     r15,[r15-4]
    lea     rax,[rsp+15Ch]
    mov     rdi,rax
    mov     rsi,r15
    call    qword ptr [image.fn206.slot]
    test    al,al
    jne     L52
    jmp     L53
L56:
    cmp     byte ptr [rsp+38h],0
    jne     L119
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+30h]
    je      L57
    lea     rbx,[rsp+178h]
    lea     rax,[image.k2208]
    mov     rdi,[rsp+30h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+10h]
    mov     r8,rax
    call    image.fn187
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    mov     rdx,rbx
    mov     rcx,[rsp+20h]
    call    qword ptr [image.fn78.slot]
    lea     rax,[image.k2232]
    mov     rdi,rbx
    mov     rsi,[rsp+30h]
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+10h]
    mov     r9,rax
    call    image.fn180
    mov     rax,[rsp+10h]
    imul    rax,4
    mov     rdi,[rsp+30h]
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L119
L57:
    mov     r11,[rsp+30h]
    mov     r10,[rsp+40h]
    lea     rbx,[r11+r10*4]
    mov     r12,[rsp+10h]
    sub     r12,[rsp+40h]
    lea     r11,[image.k2184]
    mov     [rsp+98h],r11
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L59
    jmp     L143
L58:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r12,rax
    ja      L143
    mov     [rsp+58h],rbx
    mov     [rsp+60h],r12
    jmp     L5
L59:
    cmp     rbx,0
    je      L143
    jmp     L58
L60:
    cmp     ecx,0
    jne     L61
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    call    qword ptr [fn2.slot]
    jmp     L119
L61:
    mov     r11,rcx
    sub     r11d,1
    mov     [rsp+0B0h],r11
    mov     rax,[rsp+10h]
    shr     rax,3
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+30h]
    lea     r12,[r11+rcx*4]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+30h]
    lea     r15,[r11+rcx*4]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L65
    mov     r11,[rsp+30h]
    mov     ecx,[r11]
    mov     edx,[r12]
    cmp     ecx,edx
    setb    sil
    mov     edi,[r15]
    cmp     ecx,edi
    setb    cl
    cmp     sil,cl
    jne     L63
    cmp     edx,edi
    setb    cl
    xor     ecx,esi
    test    cl,cl
    je      L62
    mov     rcx,r15
    jmp     L64
L62:
    mov     rcx,r12
    jmp     L64
L63:
    mov     rcx,[rsp+30h]
L64:
    lea     rdx,[image.k1536]
    cmp     rcx,[rsp+30h]
    jb      L144
    sub     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    mov     rax,rcx
    jmp     L69
L65:
    mov     r13,rax
    shr     r13,3
    mov     r14,r13
    imul    r14,4
    mov     r11,[rsp+30h]
    lea     rax,[r11+r14*4]
    mov     rbp,r13
    imul    rbp,7
    mov     r11,[rsp+30h]
    lea     rcx,[r11+rbp*4]
    mov     rdi,[rsp+30h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     rbx,rax
    lea     rax,[r12+r14*4]
    lea     rcx,[r12+rbp*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     r12,rax
    lea     rax,[r15+r14*4]
    lea     rcx,[r15+rbp*4]
    mov     rdi,r15
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+20h]
    call    image.fn59
    mov     ecx,[rbx]
    mov     esi,[r12]
    cmp     ecx,esi
    setb    dil
    mov     r8d,[rax]
    cmp     ecx,r8d
    setb    cl
    cmp     dil,cl
    jne     L67
    cmp     esi,r8d
    setb    cl
    xor     ecx,edi
    test    cl,cl
    je      L66
    jmp     L68
L66:
    mov     rax,r12
    jmp     L68
L67:
    mov     rax,rbx
L68:
    lea     rcx,[image.k1584]
    cmp     rax,[rsp+30h]
    jb      L145
    sub     rax,[rsp+30h]
    mov     rdi,rax
    mov     esi,4
    call    ryo_hr_DivUW64
L69:
    cmp     rax,[rsp+10h]
    setb    sil
    lea     rdi,[image.k1632]
    test    sil,sil
    je      L146
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L94
    mov     r11,[rsp+30h]
    lea     rsi,[r11+rax*4]
    mov     r11,[rsp+28h]
    mov     r8d,[r11]
    mov     r9d,[rsi]
    cmp     r8d,r9d
    jb      L94
    mov     r10,[rsp+20h]
    mov     [rsp+2F0h],r10
    lea     rbx,[rsp+2F0h]
    lea     r8,[rsp+1FCh]
    lea     r9,[image.k488]
    mov     r12,[rsp+30h]
    and     r12,3
    cmp     r12,0
    je      L74
    jmp     L147
L70:
    mov     r12,r8
    and     r12,3
    cmp     r12,0
    je      L75
    jmp     L147
L71:
    mov     r11,[rsp+30h]
    cmp     r11,r8
    jae     L72
    mov     r12,r8
    sub     r12,[rsp+30h]
    jmp     L73
L72:
    mov     r12,[rsp+30h]
    sub     r12,r8
L73:
    cmp     r12,4
    jb      L147
    mov     r11,[rsp+30h]
    mov     r12d,[r11]
    mov     [rsp+1FCh],r12d
    lea     r12,[image.k512]
    mov     r13,rsi
    and     r13,3
    cmp     r13,0
    je      L77
    jmp     L148
L74:
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L147
    jmp     L70
L75:
    cmp     r8,0
    je      L147
    jmp     L71
L76:
    mov     r8d,[rsi]
    mov     r11,[rsp+30h]
    mov     [r11],r8d
    lea     r8,[rsp+1FCh]
    lea     r13,[image.k536]
    mov     r14,r8
    and     r14,3
    cmp     r14,0
    je      L81
    jmp     L149
L77:
    cmp     rsi,0
    je      L148
    mov     r14,[rsp+30h]
    and     r14,3
    cmp     r14,0
    je      L76
    jmp     L148
L78:
    mov     r14,rsi
    and     r14,3
    cmp     r14,0
    jne     L149
    cmp     r8,rsi
    jae     L79
    mov     r14,rsi
    sub     r14,r8
    jmp     L80
L79:
    mov     r14,r8
    sub     r14,rsi
L80:
    cmp     r14,4
    jb      L149
    mov     r14d,[rsp+1FCh]
    mov     [rsi],r14d
    lea     r14,[image.k4432]
    lea     r15,[rsp+210h]
    mov     rdi,r15
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    mov     ecx,1
    mov     r8,r14
    call    fn10
    mov     r14,[rsp+210h]
    mov     r11,[rsp+218h]
    mov     [rsp+0B8h],r11
    mov     rbp,[rsp+220h]
    mov     r15,[rsp+228h]
    mov     r11,[rsp+0B8h]
    cmp     r11,0
    ja      L82
    jmp     L153
L81:
    cmp     r8,0
    je      L149
    jmp     L78
L82:
    mov     [rsp+228h],r14
    mov     [rsp+220h],r14
    mov     rsi,[image.sym36]
    mov     rdi,rbp
    mov     rdx,r14
    mov     rcx,rbx
    mov     rax,rsi
    mov     rsi,r15
    call    rax
    mov     rsi,rax
    cmp     rsi,[rsp+10h]
    jae     L154
    mov     r11,[rsp+30h]
    lea     r8,[r11+rsi*4]
    lea     rbx,[rsp+20Ch]
    lea     r11,[image.k488]
    mov     [rsp+110h],r11
    mov     r15,[rsp+30h]
    and     r15,3
    cmp     r15,0
    jne     L150
    mov     r15,rbx
    and     r15,3
    cmp     r15,0
    je      L86
    jmp     L150
L83:
    mov     r11,[rsp+30h]
    cmp     r11,rbx
    jae     L84
    mov     r15,rbx
    sub     r15,[rsp+30h]
    jmp     L85
L84:
    mov     r15,[rsp+30h]
    sub     r15,rbx
L85:
    cmp     r15,4
    jb      L150
    mov     r11,[rsp+30h]
    mov     r15d,[r11]
    mov     [rsp+20Ch],r15d
    lea     r11,[image.k512]
    mov     [rsp+108h],r11
    mov     rbp,r8
    and     rbp,3
    cmp     rbp,0
    je      L88
    jmp     L151
L86:
    cmp     rbx,0
    je      L150
    jmp     L83
L87:
    mov     ebx,[r8]
    mov     r11,[rsp+30h]
    mov     [r11],ebx
    lea     rbx,[rsp+20Ch]
    lea     r11,[image.k536]
    mov     [rsp+0C0h],r11
    mov     rbp,rbx
    and     rbp,3
    cmp     rbp,0
    je      L92
    jmp     L152
L88:
    cmp     r8,0
    je      L151
    mov     rbp,[rsp+30h]
    and     rbp,3
    cmp     rbp,0
    je      L87
    jmp     L151
L89:
    mov     rbp,r8
    and     rbp,3
    cmp     rbp,0
    jne     L152
    cmp     rbx,r8
    jae     L90
    mov     rbp,r8
    sub     rbp,rbx
    jmp     L91
L90:
    mov     rbp,rbx
    sub     rbp,r8
L91:
    cmp     rbp,4
    jb      L152
    mov     ebp,[rsp+20Ch]
    mov     [r8],ebp
    jmp     L93
L92:
    cmp     rbx,0
    je      L152
    jmp     L89
L93:
    mov     r11,rsi
    add     r11,1
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+10h]
    cmp     r11,[rsp+0C8h]
    jb      L164
    mov     r8,[rsp+10h]
    sub     r8,[rsp+0C8h]
    mov     r10,[rsp+30h]
    mov     [rsp+2E0h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+2E8h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+2D8h],r10
    mov     r11,[rsp+30h]
    mov     r10,[rsp+0C8h]
    lea     rbx,[r11+r10*4]
    mov     [rsp+2D0h],rbx
    mov     [rsp+2F0h],rbx
    mov     [rsp+30h],rbx
    mov     [rsp+10h],r8
    mov     rcx,[rsp+0B0h]
    mov     qword ptr [rsp+28h],0
    jmp     L0
L94:
    mov     r11,[rsp+30h]
    lea     rax,[r11+rax*4]
    lea     r8,[rsp+23Ch]
    lea     r11,[image.k488]
    mov     [rsp+0E8h],r11
    mov     rbp,[rsp+30h]
    and     rbp,3
    cmp     rbp,0
    je      L99
    jmp     L155
L95:
    mov     rbp,r8
    and     rbp,3
    cmp     rbp,0
    je      L100
    jmp     L155
L96:
    mov     r11,[rsp+30h]
    cmp     r11,r8
    jae     L97
    mov     rbp,r8
    sub     rbp,[rsp+30h]
    jmp     L98
L97:
    mov     rbp,[rsp+30h]
    sub     rbp,r8
L98:
    cmp     rbp,4
    jb      L155
    mov     r11,[rsp+30h]
    mov     ebp,[r11]
    mov     [rsp+23Ch],ebp
    lea     r11,[image.k512]
    mov     [rsp+0D8h],r11
    mov     rsi,rax
    and     rsi,3
    cmp     rsi,0
    je      L102
    jmp     L156
L99:
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L155
    jmp     L95
L100:
    cmp     r8,0
    je      L155
    jmp     L96
L101:
    mov     esi,[rax]
    mov     r11,[rsp+30h]
    mov     [r11],esi
    lea     rsi,[rsp+23Ch]
    lea     r11,[image.k536]
    mov     [rsp+0D0h],r11
    mov     r8,rsi
    and     r8,3
    cmp     r8,0
    je      L106
    jmp     L157
L102:
    cmp     rax,0
    je      L156
    mov     r8,[rsp+30h]
    and     r8,3
    cmp     r8,0
    je      L101
    jmp     L156
L103:
    mov     r8,rax
    and     r8,3
    cmp     r8,0
    jne     L157
    cmp     rsi,rax
    jae     L104
    mov     r8,rax
    sub     r8,rsi
    jmp     L105
L104:
    mov     r8,rsi
    sub     r8,rax
L105:
    cmp     r8,4
    jb      L157
    mov     r8d,[rsp+23Ch]
    mov     [rax],r8d
    lea     r8,[image.k4528]
    lea     rbp,[rsp+250h]
    mov     rdi,rbp
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    mov     ecx,1
    call    fn10
    mov     r8,[rsp+250h]
    mov     r11,[rsp+258h]
    mov     [rsp+0E0h],r11
    mov     rbp,[rsp+260h]
    mov     rbx,[rsp+268h]
    mov     r11,[rsp+0E0h]
    cmp     r11,0
    ja      L107
    jmp     L161
L106:
    cmp     rsi,0
    je      L157
    jmp     L103
L107:
    mov     [rsp+268h],r8
    mov     [rsp+260h],r8
    mov     rax,[image.sym37]
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r8
    mov     rcx,[rsp+20h]
    call    rax
    cmp     rax,[rsp+10h]
    jae     L162
    mov     r11,[rsp+30h]
    lea     rsi,[r11+rax*4]
    lea     r8,[rsp+24Ch]
    lea     r11,[image.k488]
    mov     [rsp+100h],r11
    mov     rbp,[rsp+30h]
    and     rbp,3
    cmp     rbp,0
    jne     L158
    mov     rbp,r8
    and     rbp,3
    cmp     rbp,0
    je      L111
    jmp     L158
L108:
    mov     r11,[rsp+30h]
    cmp     r11,r8
    jae     L109
    mov     rbp,r8
    sub     rbp,[rsp+30h]
    jmp     L110
L109:
    mov     rbp,[rsp+30h]
    sub     rbp,r8
L110:
    cmp     rbp,4
    jb      L158
    mov     r11,[rsp+30h]
    mov     ebp,[r11]
    mov     [rsp+24Ch],ebp
    lea     r11,[image.k512]
    mov     [rsp+0F0h],r11
    mov     rbp,rsi
    and     rbp,3
    cmp     rbp,0
    je      L113
    jmp     L159
L111:
    cmp     r8,0
    je      L158
    jmp     L108
L112:
    mov     r8d,[rsi]
    mov     r11,[rsp+30h]
    mov     [r11],r8d
    lea     r8,[rsp+24Ch]
    lea     r11,[image.k536]
    mov     [rsp+0F8h],r11
    mov     rbp,r8
    and     rbp,3
    cmp     rbp,0
    je      L117
    jmp     L160
L113:
    cmp     rsi,0
    je      L159
    mov     rbp,[rsp+30h]
    and     rbp,3
    cmp     rbp,0
    je      L112
    jmp     L159
L114:
    mov     rbp,rsi
    and     rbp,3
    cmp     rbp,0
    jne     L160
    cmp     r8,rsi
    jae     L115
    mov     rbp,rsi
    sub     rbp,r8
    jmp     L116
L115:
    mov     rbp,r8
    sub     rbp,rsi
L116:
    cmp     rbp,4
    jb      L160
    mov     ebp,[rsp+24Ch]
    mov     [rsi],ebp
    jmp     L118
L117:
    cmp     r8,0
    je      L160
    jmp     L114
L118:
    lea     rsi,[k9]
    lea     r8,[rsp+2D8h]
    mov     rdi,r8
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    mov     r8,rsi
    mov     rsi,[rsp+30h]
    call    fn10
    mov     rbp,[rsp+2D8h]
    mov     rbx,[rsp+2E0h]
    mov     rax,[rsp+2E8h]
    mov     rsi,[rsp+2F0h]
    lea     r8,[k11]
    lea     r15,[rsp+2C8h]
    mov     rdi,r15
    mov     rdx,rsi
    mov     rsi,rax
    mov     ecx,1
    call    fn10
    mov     rax,[rsp+2C8h]
    mov     rsi,[rsp+2D0h]
    mov     [rsp+2E8h],rax
    mov     [rsp+2F0h],rsi
    mov     r15,[rsp+2D8h]
    mov     r14,[rsp+2E0h]
    cmp     rsi,0
    jbe     L163
    mov     [rsp+2E0h],rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+0B0h]
    mov     r8,[rsp+20h]
    mov     ecx,ecx
    call    fn15
    mov     rax,[rsp+2E0h]
    mov     [rsp+30h],r15
    mov     [rsp+10h],r14
    mov     rcx,[rsp+0B0h]
    mov     [rsp+28h],rax
    jmp     L0
L119:
    mov     rbx,[rsp+2C0h]
    mov     r12,[rsp+2B0h]
    mov     r13,[rsp+2A0h]
    mov     r14,[rsp+290h]
    mov     r15,[rsp+280h]
    mov     rbp,[rsp+270h]
    add     rsp,398h
    ret
    jmp     L121
L120:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym49
    ud2
L121:
    call    image.sym10
    ud2
    jmp     L123
L122:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L123:
    call    image.sym10
    ud2
    jmp     L125
    jmp     L125
    jmp     L125
L124:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L125:
    call    image.sym10
    ud2
    jmp     L127
L126:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L127:
    call    image.sym10
    ud2
    jmp     L129
    jmp     L129
    jmp     L129
L128:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L129:
    call    image.sym10
    ud2
    jmp     L131
L130:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L131:
    call    image.sym10
    ud2
    jmp     L133
    jmp     L133
    jmp     L133
L132:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L133:
    call    image.sym10
    ud2
    jmp     L135
L134:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L135:
    call    image.sym10
    ud2
    jmp     L137
    jmp     L137
    jmp     L137
L136:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L137:
    call    image.sym10
    ud2
    jmp     L139
    jmp     L139
    jmp     L139
L138:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L139:
    call    image.sym10
    ud2
L140:
    lea     rax,[rsp+160h]
    mov     rdi,rax
    call    qword ptr [image.fn229.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    call    ryo_h_Resume
    ud2
    jmp     L141
    mov     rbx,rax
    jmp     L140
L141:
    call    image.sym11
    ud2
L142:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L143:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L144:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L145:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L146:
    lea     rax,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L147:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L148:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L149:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L150:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+110h]
    movzx   edx,dl
    call    image.sym49
    ud2
L151:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+108h]
    movzx   edx,dl
    call    image.sym49
    ud2
L152:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L153:
    lea     rax,[image.k4456]
    mov     edi,0
    mov     rsi,[rsp+0B8h]
    mov     rdx,rax
    call    sym5
    ud2
L154:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L155:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L156:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L157:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L158:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    image.sym49
    ud2
L159:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L160:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L161:
    lea     rax,[image.k4552]
    mov     edi,0
    mov     rsi,[rsp+0E0h]
    mov     rdx,rax
    call    sym5
    ud2
L162:
    lea     rdi,[rsp+390h]
    call    ryo_h_Abort
    ud2
L163:
    lea     rax,[k13]
    mov     edi,0
    mov     rdx,rax
    call    sym5
    ud2
L164:
    lea     rax,[k16]
    mov     rdi,[rsp+0C8h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    call    sym17
    ud2
  ; OSR entries
    lea     r11,[L165]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L165:
    .long   L166
L166:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-3C0h]
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
    mov     [rdx-0E0h],r12
    mov     [rdx-0F0h],r13
    mov     [rdx-100h],r14
    mov     [rdx-110h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp]
    mov     [rdx-360h],r11
    mov     r11,[rsp+8]
    mov     [rdx-380h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-370h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-368h],r11
    mov     rcx,[rsp+18h]
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
    sub     rsp,1E8h
    mov     [rsp+150h],rbx
    mov     [rsp+140h],r12
    mov     [rsp+130h],r13
    mov     [rsp+120h],r14
    mov     [rsp+110h],r15
    mov     [rsp+100h],rbp
    mov     rbx,rdi
    mov     [rsp+60h],rsi
    mov     r13,rdx
    mov     r11,[rsp+60h]
    cmp     r11,10h
    ja      L20
    mov     qword ptr [rsp+160h],1
    mov     r10,[rsp+60h]
    mov     [rsp+168h],r10
    mov     rax,rbx
    mov     rcx,[rsp+60h]
L0:
    mov     rdx,[rsp+160h]
    mov     rsi,[rsp+168h]
    cmp     rdx,rsi
    jae     L1
    mov     rsi,rdx
    add     rsi,1
    mov     [rsp+160h],rsi
    mov     rsi,rdx
    mov     edx,1
    jmp     L2
L1:
    mov     edx,0
L2:
    cmp     rdx,0
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
    jae     L71
    mov     r10,[rsp+30h]
    lea     rdi,[rax+r10*4]
    mov     edi,[rdi]
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L72
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
    lea     r15,[rsp+0DCh]
    lea     r11,[image.k488]
    mov     [rsp+70h],r11
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    je      L12
    jmp     L51
L8:
    mov     rcx,r15
    and     rcx,3
    cmp     rcx,0
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
    mov     [rsp+0DCh],ecx
    lea     rcx,[image.k512]
    mov     rsi,r8
    and     rsi,3
    cmp     rsi,0
    je      L15
    jmp     L52
L12:
    cmp     r14,0
    je      L51
    jmp     L8
L13:
    cmp     r15,0
    je      L51
    jmp     L9
L14:
    mov     esi,[r8]
    mov     [r14],esi
    lea     rsi,[rsp+0DCh]
    lea     r11,[image.k536]
    mov     [rsp+68h],r11
    mov     rdx,rsi
    and     rdx,3
    cmp     rdx,0
    je      L19
    jmp     L53
L15:
    cmp     r8,0
    je      L52
    mov     rdx,r14
    and     rdx,3
    cmp     rdx,0
    je      L14
    jmp     L52
L16:
    mov     rdx,r8
    and     rdx,3
    cmp     rdx,0
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
    mov     edx,[rsp+0DCh]
    mov     [r8],edx
    mov     rdx,[rsp+28h]
    sub     rdx,1
    mov     [rsp+28h],rdx
    jmp     L3
L19:
    cmp     rsi,0
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
    jae     L73
    mov     r10,[rsp+38h]
    lea     rdx,[rbx+r10*4]
    mov     r14d,[rdx]
    mov     r10,[rsp+40h]
    lea     rdx,[rbx+r10*4]
    mov     r12d,[rdx]
    cmp     r12d,r14d
    jb      L23
    mov     r15,[r13+10h]
    mov     rbp,[r13]
    cmp     r15,rbp
    jne     L22
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFF00h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdx,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    mov     rdi,r13
    mov     rcx,rdx
    mov     edx,1
    mov     r8,rsi
    mov     rsi,rbp
    call    image.sym43
    mov     rsi,rdx
    mov     rdx,rax
    cmp     rdx,0FFFFFFFFFFFFFFFFh
    jne     L56
L22:
    mov     r8,[r13+8]
    lea     r8,[r8+r15*4]
    mov     [r8],r14d
    add     r15,1
    mov     [r13+10h],r15
    mov     [rsp+8],r8
    mov     r8,[rsp+38h]
    add     r8,1
    mov     [rsp+38h],r8
    jmp     L21
L23:
    mov     r14,[r13+10h]
    mov     r15,[r13]
    cmp     r14,r15
    jne     L24
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFF10h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+0F0h]
    mov     rbp,[rsp+0F8h]
    mov     rdi,r13
    mov     rsi,r15
    mov     edx,1
    mov     rcx,r8
    mov     r8,rbp
    call    image.sym43
    mov     [rsp+0A0h],rax
    mov     [rsp+90h],rdx
    mov     r11,[rsp+0A0h]
    cmp     r11,0FFFFFFFFFFFFFFFFh
    jne     L57
L24:
    mov     rbp,[r13+8]
    lea     rbp,[rbp+r14*4]
    mov     [rbp],r12d
    add     r14,1
    mov     [r13+10h],r14
    mov     [rsp+8],rbp
    mov     r12,[rsp+40h]
    add     r12,1
    mov     [rsp+40h],r12
    jmp     L21
L25:
    lea     r11,[k37]
    mov     [rsp+88h],r11
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+38h]
    jb      L58
    mov     r14,[rsp+50h]
    sub     r14,[rsp+38h]
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+50h]
    jb      L58
    mov     r10,[rsp+38h]
    lea     rbp,[rbx+r10*4]
    lea     r14,[rbp+r14*4]
    lea     r11,[image.k6656]
    mov     [rsp+78h],r11
    cmp     r14,rbp
    jb      L59
    sub     r14,rbp
    mov     rdi,r14
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r14,rax
    lea     r11,[image.k6704]
    mov     [rsp+80h],r11
    mov     r12,rbp
    and     r12,3
    cmp     r12,0
    je      L27
    jmp     L60
L26:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r12,rax
    cmp     r14,r12
    ja      L60
    mov     rdi,r13
    mov     rsi,r14
    call    qword ptr [image.fn171.slot]
    mov     r12,[r13+10h]
    cmp     r14,0
    ja      L28
    jmp     L33
L27:
    cmp     rbp,0
    je      L60
    jmp     L26
L28:
    mov     r15,[r13+8]
    lea     r15,[r15+r12*4]
    lea     r11,[image.k7104]
    mov     [rsp+98h],r11
    mov     r12,rbp
    and     r12,3
    cmp     r12,0
    je      L32
    jmp     L62
L29:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r14
    mov     r12,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L61
    cmp     rbp,r15
    jae     L30
    mov     r8,r15
    sub     r8,rbp
    jmp     L31
L30:
    mov     r8,rbp
    sub     r8,r15
L31:
    cmp     r12,r8
    ja      L62
    mov     r8,r14
    imul    r8,4
    mov     rdi,r15
    mov     rsi,rbp
    mov     rdx,r8
    call    ryo_hr_Memcpy
    jmp     L33
L32:
    mov     r8,r15
    and     r8,3
    cmp     r8,0
    jne     L62
    cmp     r15,0
    je      L62
    jmp     L29
L33:
    mov     r8,[r13+10h]
    add     r8,r14
    mov     [r13+10h],r8
    lea     r11,[k40]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+48h]
    cmp     r11,[rsp+40h]
    jb      L63
    mov     r12,[rsp+48h]
    sub     r12,[rsp+40h]
    mov     r10,[rsp+40h]
    lea     r14,[rbx+r10*4]
    lea     r12,[r14+r12*4]
    lea     r11,[image.k6656]
    mov     [rsp+0B0h],r11
    cmp     r12,r14
    jb      L64
    sub     r12,r14
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r12,rax
    lea     r11,[image.k6704]
    mov     [rsp+0A8h],r11
    mov     rbp,r14
    and     rbp,3
    cmp     rbp,0
    je      L35
    jmp     L65
L34:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rbp,rax
    cmp     r12,rbp
    ja      L65
    mov     rdi,r13
    mov     rsi,r12
    call    qword ptr [image.fn171.slot]
    mov     rbp,[r13+10h]
    cmp     r12,0
    ja      L36
    jmp     L41
L35:
    cmp     r14,0
    je      L65
    jmp     L34
L36:
    mov     r15,[r13+8]
    lea     r15,[r15+rbp*4]
    lea     r11,[image.k7104]
    mov     [rsp+0B8h],r11
    mov     rbp,r14
    and     rbp,3
    cmp     rbp,0
    je      L40
    jmp     L67
L37:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r12
    mov     rbp,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L66
    cmp     r14,r15
    jae     L38
    mov     r8,r15
    sub     r8,r14
    jmp     L39
L38:
    mov     r8,r14
    sub     r8,r15
L39:
    cmp     rbp,r8
    ja      L67
    mov     r8,r12
    imul    r8,4
    mov     rdi,r15
    mov     rsi,r14
    mov     rdx,r8
    call    ryo_hr_Memcpy
    jmp     L41
L40:
    mov     r8,r15
    and     r8,3
    cmp     r8,0
    jne     L67
    cmp     r15,0
    je      L67
    jmp     L37
L41:
    mov     r8,[r13+10h]
    add     r8,r12
    mov     [r13+10h],r8
    mov     r12,[r13+8]
    lea     r11,[k44]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+48h]
    cmp     r11,r8
    jne     L70
    lea     r14,[image.k560]
    mov     r11,[rsp+48h]
    cmp     r11,0
    jne     L42
    mov     r15d,1
    jmp     L43
L42:
    mov     r15d,0
L43:
    mov     rbp,r12
    and     rbp,3
    cmp     rbp,0
    je      L48
    jmp     L69
L44:
    mov     rbp,rbx
    and     rbp,3
    cmp     rbp,0
    je      L49
    jmp     L69
L45:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     qword ptr [rsp+48h]
    mov     rbp,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L68
    cmp     r12,rbx
    jae     L46
    mov     r13,rbx
    sub     r13,r12
    jmp     L47
L46:
    mov     r13,r12
    sub     r13,rbx
L47:
    cmp     rbp,r13
    ja      L69
    mov     r13,[rsp+48h]
    imul    r13,4
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    call    ryo_hr_Memcpy
    jmp     L50
L48:
    test    r15b,r15b
    jne     L44
    cmp     r12,0
    je      L69
    jmp     L44
L49:
    test    r15b,r15b
    jne     L45
    cmp     rbx,0
    je      L69
    jmp     L45
L50:
    mov     rbx,[rsp+150h]
    mov     r12,[rsp+140h]
    mov     r13,[rsp+130h]
    mov     r14,[rsp+120h]
    mov     r15,[rsp+110h]
    mov     rbp,[rsp+100h]
    add     rsp,1E8h
    ret
L51:
    lea     rbx,[image.k8338]
    mov     rdi,rbx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L52:
    lea     rbx,[image.k8904]
    mov     rdi,rbx
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
L56:
    mov     rdi,rdx
    call    image.sym44
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFE30h
    call    ryo_h_Resume
    ud2
L57:
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+90h]
    call    image.sym44
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFE30h
    call    ryo_h_Resume
    ud2
L58:
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp+88h]
    call    image.sym31
    ud2
L59:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L61:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L62:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp+0C0h]
    call    image.sym31
    ud2
L64:
    lea     rax,[image.k7567]
    mov     rdi,rax
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L65:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0A8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L66:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L67:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L68:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
L69:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L70:
    mov     rdi,[rsp+48h]
    mov     rsi,r8
    mov     rdx,[rsp+0C8h]
    call    image.sym24
    ud2
L71:
    lea     rax,[k4]
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L72:
    lea     rax,[k6]
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L73:
    lea     rax,[k23]
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+48h]
    mov     rdx,rax
    call    sym5
    ud2
  ; OSR entries
    lea     r11,[L74]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L74:
    .long   L75
    .long   L76
    .long   L77
L75:
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    lea     rsp,[rsp+1A0h]
    jmp     L0
L76:
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
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1C0h],r11
    mov     rax,[rsp+8]
    lea     rsp,[rsp+1B0h]
    jmp     L3
L77:
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
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-190h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-198h],r11
    mov     rbx,[rsp+18h]
    mov     r13,[rsp+28h]
    lea     rsp,[rsp+1C0h]
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
    mov     [rsp+58h],r12
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+8],bl
    mov     [rsp],rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym5]
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+40]
    call    qword ptr [sym3]
    mov     rax,[rsp+58h]
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    add     rsp,98h
    ret
    mov     rbx,rax
    jmp     L1
L0:
    mov     [rsp+20h],rbx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12d,[rsi]
    mov     rdi,r12
    mov     esi,3E8h
    call    ryo_hr_RemUW32
    mov     eax,eax
    mov     r12d,r12d
    shl     r12,20h
    or      rax,r12
    mov     rcx,rax
    shr     rcx,20h
    mov     eax,eax
    mov     ecx,ecx
    shl     rcx,20h
    or      rax,rcx
    mov     rcx,rax
    shr     rcx,20h
    mov     rdx,[rbx+10h]
    mov     rsi,[rbx+8]
    lea     rdx,[rdx+rsi*8]
    mov     eax,eax
    mov     ecx,ecx
    shl     rcx,20h
    or      rax,rcx
    mov     [rdx],rax
    mov     rax,[rbx+8]
    add     rax,1
    mov     [rbx+8],rax
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
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
    mov     rcx,rax
    add     rcx,1
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L0
    sub     r12,1
    and     rbx,r12
    cmp     rbx,0
    sete    al
    movzx   eax,al
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
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
    cmp     eax,1
    jne     L5
    mov     rax,r13
    sub     rax,1
    and     rax,rbx
    cmp     rax,0
    je      L1
    jmp     L9
L0:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L1:
    test    r14b,r14b
    je      L2
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L6
    mov     rax,r13
    sub     rax,1
    and     rax,r12
    cmp     rax,0
    je      L3
    jmp     L10
L2:
    cmp     rbx,0
    je      L8
    mov     rdi,r13
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L7
    sub     r13,1
    mov     rax,r12
    and     rax,r13
    cmp     rax,0
    je      L4
    jmp     L10
L3:
    jmp     L0
L4:
    cmp     r12,0
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
    cmp     eax,1
    jne     L8
    mov     rax,r14
    sub     rax,1
    and     rax,rbx
    cmp     rax,0
    je      L6
    jmp     L12
L2:
    mov     rdi,r14
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,r14
    sub     rax,1
    and     rax,r12
    cmp     rax,0
    je      L7
    jmp     L13
L3:
    mov     r11,rax
    mov     r10,rdx
    mov     rax,r13
    mul     r15
    mov     rdx,r10
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
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L6:
    test    bpl,bpl
    jne     L2
    cmp     rbx,0
    je      L11
    jmp     L2
L7:
    test    bpl,bpl
    jne     L3
    cmp     r12,0
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
    cmp     eax,1
    jne     L5
    sub     r13,1
    mov     rax,rbx
    and     rax,r13
    cmp     rax,0
    je      L2
    jmp     L7
L0:
    cmp     r12,0
    je      L3
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
    jmp     L4
L1:
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L2:
    cmp     rbx,0
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
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    mov     r14,[rbx]
    cmp     r13,r14
    jne     L0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,1
    mov     r8,rcx
    mov     rcx,rax
    call    image.sym43
    cmp     rax,0FFFFFFFFFFFFFFFFh
    jne     L1
L0:
    mov     rcx,[rbx+8]
    lea     rcx,[rcx+r13*4]
    mov     [rcx],r12d
    add     r13,1
    mov     [rbx+10h],r13
    mov     [rsp+8],rcx
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    add     rsp,78h
    ret
L1:
    mov     rdi,rax
    mov     rsi,rdx
    call    image.sym44
    ud2
    mov     [rsp+10h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
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

