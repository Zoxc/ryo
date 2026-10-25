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
    cmp     eax,1
    jne     L8
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L6
    jmp     L11
L2:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L11
L3:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r13
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
    mov     rax,r13
    imul    rax,4
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L6:
    test    r15b,r15b
    jne     L2
    cmp     rbx,0
    je      L11
    jmp     L2
L7:
    test    r15b,r15b
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
    jmp     L12
    jmp     L12
L11:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L12:
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
    mov     [rsp+10h],rbx
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
    int3
L3:
    .long   L5
    .long   L4
    .long   L10
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
    jmp     L9
L7:
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L8
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
    ud2
L11:
    call    sym4
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
L13:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-80h]
    mov     [rdx-40h],rbx
    lea     rsp,[rsp+30h]
    jmp     L0
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
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+48h]
    mov     [rcx],rax
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
    jb      L5
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L6
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L7
L0:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L7
    lea     rbp,[r12+r14*8]
    mov     r15,r13
    sub     r15,r14
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L2
    jmp     L9
L1:
    cmp     r12,0
    je      L7
    jmp     L0
L2:
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L4
    jmp     L10
L3:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    cmp     r15,rax
    ja      L10
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
L4:
    cmp     rbp,0
    je      L10
    jmp     L3
L5:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L8
L7:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L8:
    call    image.sym10
    ud2
L9:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L11
L10:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L11:
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
    jb      L5
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L6
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L7
L0:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r14,rax
    ja      L7
    lea     rbp,[r12+r14*4]
    mov     r15,r13
    sub     r15,r14
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L2
    jmp     L9
L1:
    cmp     r12,0
    je      L7
    jmp     L0
L2:
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L4
    jmp     L10
L3:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r15,rax
    ja      L10
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
L4:
    cmp     rbp,0
    je      L10
    jmp     L3
L5:
    lea     rax,[image.k7346]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L6:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L8
L7:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L8:
    call    image.sym10
    ud2
L9:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L11
L10:
    lea     rax,[image.k9686]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L11:
    call    image.sym10
    ud2

fn core::slice::<impl [u32]>::swap
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    cmp     rdx,rsi
    jae     L26
    cmp     rcx,rsi
    jae     L27
    lea     rbx,[rdi+rdx*4]
    lea     r12,[rdi+rcx*4]
    lea     r13,[rsp+0Ch]
    lea     r14,[image.k488]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L14
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L4
    jmp     L16
L0:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L15
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L5
    jmp     L16
L1:
    cmp     rbx,r13
    jae     L2
    mov     rax,r13
    sub     rax,rbx
    jmp     L3
L2:
    mov     rax,rbx
    sub     rax,r13
L3:
    cmp     rax,4
    jb      L16
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r15,[image.k512]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L6
    jmp     L18
L4:
    cmp     rbx,0
    je      L16
    jmp     L0
L5:
    cmp     r13,0
    je      L16
    jmp     L1
L6:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L8
    jmp     L20
L7:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+0Ch]
    lea     rbp,[image.k536]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L9
    jmp     L22
L8:
    cmp     r12,0
    je      L20
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L19
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L20
L9:
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L13
    jmp     L24
L10:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L23
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    jne     L24
    cmp     r13,r12
    jae     L11
    mov     rax,r12
    sub     rax,r13
    jmp     L12
L11:
    mov     rax,r13
    sub     rax,r12
L12:
    cmp     rax,4
    jb      L24
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
L13:
    cmp     r13,0
    je      L24
    jmp     L10
L14:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L15:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
    jmp     L17
    jmp     L17
L16:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L17:
    call    image.sym10
    ud2
L18:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L19:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
    jmp     L21
L20:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L21:
    call    image.sym10
    ud2
L22:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
L23:
    lea     rax,[image.k6432]
    lea     rdi,[image.k6560]
    mov     esi,55h
    mov     rdx,rdi
    mov     rdi,rax
    call    image.sym6
    ud2
    jmp     L25
    jmp     L25
L24:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    call    image.sym10
    ud2
L26:
    mov     rdi,rdx
    mov     rdx,r8
    call    sym0
    ud2
L27:
    mov     rdi,rcx
    mov     rdx,r8
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
    jae     L14
    cmp     rcx,rsi
    jae     L14
    lea     rbx,[rdi+rdx*4]
    lea     r12,[rdi+rcx*4]
    lea     r13,[rsp+0Ch]
    lea     r14,[image.k488]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L15
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L4
    jmp     L17
L0:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L16
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L5
    jmp     L17
L1:
    cmp     rbx,r13
    jae     L2
    mov     rax,r13
    sub     rax,rbx
    jmp     L3
L2:
    mov     rax,rbx
    sub     rax,r13
L3:
    cmp     rax,4
    jb      L17
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r15,[image.k512]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L6
    jmp     L19
L4:
    cmp     rbx,0
    je      L17
    jmp     L0
L5:
    cmp     r13,0
    je      L17
    jmp     L1
L6:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L8
    jmp     L21
L7:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+0Ch]
    lea     rbp,[image.k536]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L9
    jmp     L23
L8:
    cmp     r12,0
    je      L21
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L20
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L21
L9:
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L13
    jmp     L25
L10:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L24
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    jne     L25
    cmp     r13,r12
    jae     L11
    mov     rax,r12
    sub     rax,r13
    jmp     L12
L11:
    mov     rax,r13
    sub     rax,r12
L12:
    cmp     rax,4
    jb      L25
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
L13:
    cmp     r13,0
    je      L25
    jmp     L10
L14:
    lea     rax,[image.k7128]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    mov     rcx,r8
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
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
    jmp     L18
L17:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L18:
    call    image.sym10
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
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L22
L21:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L22:
    call    image.sym10
    ud2
L23:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L24:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L26
    jmp     L26
L25:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L26:
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
    jb      L16
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
    mov     edx,[r14]
    cmp     ecx,edx
    setb    dl
    mov     esi,[r15]
    cmp     ecx,esi
    setb    cl
    cmp     dl,cl
    jne     L1
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     ecx,[r14]
    mov     esi,[r15]
    cmp     ecx,esi
    setb    cl
    xor     ecx,edx
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
    jb      L13
    sub     rcx,[rsp+18h]
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L11
L3:
    mov     rsi,rax
    imul    rsi,8
    cmp     rsi,40h
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
    lea     rsi,[r11+rbx*8]
    mov     rdi,[rsp+18h]
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r13,rax
    lea     rax,[r14+r12*8]
    lea     rsi,[r14+rbx*8]
    mov     rdi,r14
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r14,rax
    lea     rax,[r15+r12*8]
    lea     rsi,[r15+rbx*8]
    mov     rdi,r15
    mov     rdx,rsi
    mov     rsi,rax
    mov     rcx,rbp
    mov     r8,[rsp+20h]
    call    fn1
    mov     r15,rax
L6:
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     eax,[r13]
    mov     esi,[r14]
    cmp     eax,esi
    setb    sil
    mov     edi,[r15]
    cmp     eax,edi
    setb    al
    cmp     sil,al
    jne     L8
    mov     r11,[rsp+20h]
    mov     r11,[r11]
    mov     eax,[r14]
    mov     edi,[r15]
    cmp     eax,edi
    setb    al
    xor     eax,esi
    test    al,al
    je      L7
    jmp     L9
L7:
    mov     r15,r14
    jmp     L9
L8:
    mov     r15,r13
L9:
    lea     rax,[k7]
    cmp     r15,[rsp+18h]
    jb      L14
    sub     r15,[rsp+18h]
    mov     rdi,r15
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rsi,rax
    jmp     L12
L10:
    cmp     rdi,[rsp+10h]
    setb    r8b
    lea     r9,[k12]
    test    r8b,r8b
    je      L15
    mov     rax,rdi
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L11:
    mov     rdi,rcx
    jmp     L10
L12:
    mov     rdi,rsi
    jmp     L10
L13:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L15:
    lea     rax,[image.k9125]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r9
    movzx   edx,dl
    call    image.sym49
    ud2
L16:
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L17]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L17:
    .long   L18
    .long   L19
    .long   L20
L18:
    ret
L19:
    ret
L20:
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
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    cl
    mov     edx,[r13]
    cmp     eax,edx
    setb    al
    cmp     cl,al
    jne     L2
    mov     r11,[rsp+10h]
    mov     r11,[r11]
    mov     eax,[r12]
    mov     edx,[r13]
    cmp     eax,edx
    setb    al
    xor     eax,ecx
    test    al,al
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
    sub     rsp,168h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     [rsp+0C0h],rbx
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    cmp     rax,0
    setne   cl
    mov     [rsp+0C7h],cl
    lea     rcx,[rbx+rax*4]
    mov     rdx,rax
    sub     rdx,1
    mov     [rsp+0C0h],rdx
    lea     rdx,[rbx+rdx*4]
    mov     rsi,r12
    sub     rsi,1
    lea     rdi,[rbx+rsi*4]
    mov     [rsp+0C0h],r13
    lea     rsi,[r13+rsi*4]
    mov     [rsp+38h],rdx
    mov     [rsp+20h],rbx
    mov     rbx,rax
    mov     eax,0
    mov     [rsp+18h],rcx
    mov     [rsp+10h],r13
    mov     rbp,r14
    mov     [rsp+30h],rdi
    mov     r14,rsi
    mov     [rsp+28h],r12
L0:
    mov     [rsp+0B8h],rax
    mov     [rsp+0B0h],rbx
    cmp     rax,rbx
    setb    cl
    mov     [rsp+0C7h],cl
    test    cl,cl
    je      L13
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0B8h]
    mov     r13,rax
    add     r13,1
    mov     [rsp+0B0h],r13
    lea     rax,[rsp+0B0h]
    mov     rdi,rax
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,rbp
    call    fn4
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+30h]
    mov     r15,[rsp+28h]
L1:
    mov     r12,[rsp+0B0h]
    mov     r11,[rsp+0B8h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+0C0h]
    mov     [rsp+48h],r11
    lea     rdx,[rsp+0B0h]
    mov     rdi,rdx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r14
    mov     r8,rbp
    call    fn0
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     rdx,[rsp+0C0h]
    mov     [rsp+38h],rax
    mov     rax,r13
    mov     [rsp+20h],r12
    mov     r11,[rsp+40h]
    mov     [rsp+18h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+10h],r11
    mov     [rsp+30h],rcx
    mov     r14,rdx
    mov     [rsp+28h],r15
    jmp     L0
L2:
    mov     rcx,[rsp+20h]
    mov     rax,[rsp+18h]
    jmp     L12
L3:
    mov     rax,[rsp+0C0h]
    mov     r11,[rsp+20h]
    cmp     r11,rax
    setb    al
    mov     [rsp+0B6h],al
    test    al,al
    je      L4
    mov     rbx,[rsp+20h]
    jmp     L5
L4:
    mov     rbx,[rsp+18h]
L5:
    lea     r12,[k5]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L14
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L10
    jmp     L16
L6:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L15
    mov     rax,[rsp+10h]
    and     rax,3
    cmp     rax,0
    je      L11
    jmp     L16
L7:
    cmp     rbx,[rsp+10h]
    jae     L8
    mov     rax,[rsp+10h]
    sub     rax,rbx
    jmp     L9
L8:
    mov     rax,rbx
    sub     rax,[rsp+10h]
L9:
    cmp     rax,4
    jb      L16
    mov     rdi,[rsp+10h]
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   eax,byte ptr [rsp+0B6h]
    movzx   ecx,al
    mov     r11,[rsp+20h]
    lea     rcx,[r11+rcx*4]
    xor     eax,1
    mov     [rsp+0B5h],al
    movzx   eax,al
    mov     r11,[rsp+18h]
    lea     rax,[r11+rax*4]
    jmp     L12
L10:
    cmp     rbx,0
    je      L16
    jmp     L6
L11:
    mov     r11,[rsp+10h]
    cmp     r11,0
    je      L16
    jmp     L7
L12:
    mov     rdx,[rsp+0C0h]
    cmp     rcx,rdx
    jne     L18
    mov     rcx,[rsp+0B8h]
    cmp     rax,rcx
    jne     L18
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,168h
    ret
L13:
    mov     rax,[rsp+38h]
    lea     rax,[rax+4]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+30h]
    lea     rax,[rax+4]
    mov     [rsp+0B8h],rax
    mov     rdi,[rsp+28h]
    mov     esi,2
    call    ryo_hr_RemUW64
    cmp     rax,0
    sete    al
    mov     [rsp+0B7h],al
    test    al,al
    jne     L2
    jmp     L3
L14:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L15:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L17
    jmp     L17
L16:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r12
    movzx   edx,dl
    call    image.sym49
    ud2
L17:
    call    image.sym10
    ud2
L18:
    call    sym1
    ud2
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
L20:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1B0h]
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
    mov     [rdx-128h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-138h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     rbp,[rsp+30h]
    mov     r14,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L0
L21:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1A0h]
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
    mov     r14,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     rbx,[rsp+28h]
    mov     r15,[rsp+30h]
    lea     rsp,[rsp+40h]
    jmp     L1
L22:
    ret
L23:
    ret
L24:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0C8h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rax,rsi
    lea     rax,[rax-4]
    jmp     L21
L0:
    movzx   ecx,byte ptr [rsp+7Fh]
    test    cl,cl
    je      L20
    mov     ecx,[rsi]
    mov     [rsp+7Ch],ecx
    lea     rcx,[rsp+7Ch]
    mov     rbx,rax
    mov     r12,rdi
    mov     r13,rsi
    mov     r14,rcx
L1:
    lea     r15,[k3]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L24
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    je      L6
    jmp     L26
L2:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L25
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L7
    jmp     L26
L3:
    cmp     rbx,r13
    jae     L4
    mov     rcx,r13
    sub     rcx,rbx
    jmp     L5
L4:
    mov     rcx,rbx
    sub     rcx,r13
L5:
    cmp     rcx,4
    jb      L26
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    cmp     rbx,r12
    je      L8
    jmp     L22
L6:
    cmp     rbx,0
    je      L26
    jmp     L2
L7:
    cmp     r13,0
    je      L26
    jmp     L3
L8:
    mov     r13,r14
    mov     rbp,rbx
    jmp     L13
L9:
    mov     r9,rcx
    lea     r9,[r9-4]
    jmp     L23
L10:
    test    cl,cl
    jne     L12
    jmp     L11
L11:
    mov     rbp,r9
    jmp     L13
L12:
    mov     rbx,rdx
    mov     r12,r8
    mov     r14,r13
    mov     r13,r9
    jmp     L1
L13:
    lea     r11,[image.k10520]
    mov     [rsp+10h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L28
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L18
    jmp     L30
L14:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L29
    mov     rcx,rbp
    and     rcx,3
    cmp     rcx,0
    je      L19
    jmp     L30
L15:
    cmp     r13,rbp
    jae     L16
    mov     rcx,rbp
    sub     rcx,r13
    jmp     L17
L16:
    mov     rcx,r13
    sub     rcx,rbp
L17:
    mov     r11d,4
    cmp     r11,rcx
    ja      L30
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    jmp     L20
L18:
    cmp     r13,0
    je      L30
    jmp     L14
L19:
    cmp     rbp,0
    je      L30
    jmp     L15
L20:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,0C8h
    ret
L21:
    mov     ecx,[rsi]
    mov     edx,[rsi-4]
    cmp     ecx,edx
    setb    cl
    mov     [rsp+7Fh],cl
    jmp     L0
L22:
    mov     rcx,rbx
    mov     rdx,r12
    mov     r8,r14
    jmp     L9
L23:
    mov     eax,[rsp+7Ch]
    mov     esi,[r9]
    cmp     eax,esi
    setb    al
    mov     r13,r8
    mov     r8,rdx
    mov     rdx,r9
    mov     r9,rcx
    mov     rcx,rax
    jmp     L10
L24:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L25:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L27
    jmp     L27
L26:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L27:
    call    image.sym10
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
    jmp     L31
    jmp     L31
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
    call    image.sym10
    ud2
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
    .long   L40
    .long   L41
L33:
    ret
L34:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+20h]
    jmp     L1
L35:
    ret
L36:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     rcx,[rsp]
    mov     r8,[rsp+10h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+20h]
    jmp     L9
L37:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0F0h]
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
    mov     rcx,[rsp]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+30h]
    jmp     L10
L38:
    ret
L39:
    ret
L40:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-0E0h]
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
    mov     r9,[rsp]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+20h]
    jmp     L23
L41:
    ret

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     eax,[r13]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    r15b
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
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L6
    jmp     L11
L2:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L10
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L11
L3:
    cmp     rbx,r14
    jae     L4
    mov     rax,r14
    sub     rax,rbx
    jmp     L5
L4:
    mov     rax,rbx
    sub     rax,r14
L5:
    cmp     rax,4
    jb      L11
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   eax,bpl
    mov     r11d,0
    sub     r11,rax
    mov     rax,r11
    lea     rax,[r13+rax*4]
    movzx   ecx,r15b
    mov     r11d,0
    sub     r11,rcx
    mov     rcx,r11
    lea     rcx,[r12+rcx*4]
    mov     rdx,r14
    lea     rdx,[rdx-4]
    jmp     L8
L6:
    cmp     rbx,0
    je      L11
    jmp     L2
L7:
    cmp     r14,0
    je      L11
    jmp     L3
L8:
    mov     r11,[rsp+10h]
    mov     [r11],rcx
    mov     r11,[rsp+10h]
    mov     [r11+8],rax
    mov     r11,[rsp+10h]
    mov     [r11+10h],rdx
    mov     rax,[rsp+10h]
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L9:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L10:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L12
    jmp     L12
L11:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym49
    ud2
L12:
    call    image.sym10
    ud2
  ; OSR entries
    lea     r11,[L13]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L13:
    .long   L14
L14:
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
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
    mov     eax,[r13]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    r15b
    mov     rbp,r15
    xor     ebp,1
    cmp     r15b,1
    je      L0
    mov     [rsp+10h],r12
    jmp     L1
L0:
    mov     [rsp+10h],r13
L1:
    lea     r11,[k1]
    mov     [rsp+18h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L8
    mov     rax,[rsp+10h]
    and     rax,3
    cmp     rax,0
    je      L6
    jmp     L10
L2:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L10
L3:
    mov     r11,[rsp+10h]
    cmp     r11,r14
    jae     L4
    mov     rax,r14
    sub     rax,[rsp+10h]
    jmp     L5
L4:
    mov     rax,[rsp+10h]
    sub     rax,r14
L5:
    cmp     rax,4
    jb      L10
    mov     rdi,r14
    mov     rsi,[rsp+10h]
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   eax,r15b
    lea     rax,[r13+rax*4]
    movzx   ecx,bpl
    lea     rcx,[r12+rcx*4]
    mov     rdx,r14
    lea     rdx,[rdx+4]
    mov     [rbx],rcx
    mov     [rbx+8],rax
    mov     [rbx+10h],rdx
    mov     rax,rbx
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L6:
    mov     r11,[rsp+10h]
    cmp     r11,0
    je      L10
    jmp     L2
L7:
    cmp     r14,0
    je      L10
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
    jmp     L11
    jmp     L11
L10:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+18h]
    movzx   edx,dl
    call    image.sym49
    ud2
L11:
    call    image.sym10
    ud2

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,298h
    mov     [rsp+170h],rbx
    mov     [rsp+160h],r12
    mov     [rsp+150h],r13
    mov     [rsp+140h],r14
    mov     [rsp+130h],r15
    mov     [rsp+120h],rbp
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+18h],r8
    mov     r11,[rsp+28h]
    cmp     r11,2
    jb      L61
    mov     rax,[rsp+28h]
    add     rax,10h
    cmp     rcx,rax
    jb      L98
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
    mov     [rsp+100h],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+100h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+0F8h],rcx
    mov     rdx,[rsp+28h]
    add     rdx,8
    mov     [rsp+198h],rdx
    mov     r11,[rsp+20h]
    lea     rdx,[r11+rdx*8]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+18h]
    call    qword ptr [fn0.slot]
    mov     r13d,8
    jmp     L42
L0:
    mov     r11,[rsp+28h]
    cmp     r11,8
    jb      L28
    mov     r10,[rsp+30h]
    mov     [rsp+100h],r10
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
    mov     rbx,rax
    lea     r11,[image.k1752]
    mov     [rsp+70h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L65
    mov     rax,[rsp+38h]
    and     rax,3
    cmp     rax,0
    je      L5
    jmp     L67
L1:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L66
    mov     rax,[rsp+20h]
    and     rax,3
    cmp     rax,0
    je      L6
    jmp     L67
L2:
    mov     r11,[rsp+38h]
    cmp     r11,[rsp+20h]
    jae     L3
    mov     rax,[rsp+20h]
    sub     rax,[rsp+38h]
    jmp     L4
L3:
    mov     rax,[rsp+38h]
    sub     rax,[rsp+20h]
L4:
    cmp     rax,8
    jb      L67
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+38h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r14,[rsp+20h]
    lea     r14,[r14+8]
    lea     r11,[image.k1776]
    mov     [rsp+68h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L7
    jmp     L69
L5:
    mov     r11,[rsp+38h]
    cmp     r11,0
    je      L67
    jmp     L1
L6:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L67
    jmp     L2
L7:
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L12
    jmp     L71
L8:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L70
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L13
    jmp     L71
L9:
    cmp     r13,r14
    jae     L10
    mov     rax,r14
    sub     rax,r13
    jmp     L11
L10:
    mov     rax,r13
    sub     rax,r14
L11:
    cmp     rax,8
    jb      L71
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rbp,[rsp+20h]
    lea     rbp,[rbp+10h]
    lea     r11,[image.k1800]
    mov     [rsp+48h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L14
    jmp     L73
L12:
    cmp     r13,0
    je      L71
    jmp     L8
L13:
    cmp     r14,0
    je      L71
    jmp     L9
L14:
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L19
    jmp     L75
L15:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L74
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L20
    jmp     L75
L16:
    cmp     rbx,rbp
    jae     L17
    mov     rax,rbp
    sub     rax,rbx
    jmp     L18
L17:
    mov     rax,rbx
    sub     rax,rbp
L18:
    cmp     rax,8
    jb      L75
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r13,[rsp+20h]
    lea     r13,[r13+18h]
    lea     r11,[image.k1824]
    mov     [rsp+60h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L21
    jmp     L77
L19:
    cmp     rbx,0
    je      L75
    jmp     L15
L20:
    cmp     rbp,0
    je      L75
    jmp     L16
L21:
    mov     rax,[rsp+40h]
    and     rax,3
    cmp     rax,0
    je      L26
    jmp     L79
L22:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L78
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L27
    jmp     L79
L23:
    mov     r11,[rsp+40h]
    cmp     r11,r13
    jae     L24
    mov     rax,r13
    sub     rax,[rsp+40h]
    jmp     L25
L24:
    mov     rax,[rsp+40h]
    sub     rax,r13
L25:
    cmp     rax,8
    jb      L79
    mov     rdi,r13
    mov     rsi,[rsp+40h]
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     rax,[r11+r10*8]
    mov     [rsp+0F8h],rax
    mov     [rsp+100h],rax
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rcx,[r11+r10*8]
    mov     [rsp+0F8h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
    mov     r13d,4
    jmp     L42
L26:
    mov     r11,[rsp+40h]
    cmp     r11,0
    je      L79
    jmp     L22
L27:
    cmp     r13,0
    je      L79
    jmp     L23
L28:
    mov     r10,[rsp+30h]
    mov     [rsp+100h],r10
    mov     r10,[rsp+30h]
    mov     [rsp+0F8h],r10
    lea     r11,[k9]
    mov     [rsp+58h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L81
    mov     rax,[rsp+30h]
    and     rax,3
    cmp     rax,0
    je      L33
    jmp     L83
L29:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L82
    mov     rax,[rsp+20h]
    and     rax,3
    cmp     rax,0
    je      L34
    jmp     L83
L30:
    mov     r11,[rsp+30h]
    cmp     r11,[rsp+20h]
    jae     L31
    mov     rax,[rsp+20h]
    sub     rax,[rsp+30h]
    jmp     L32
L31:
    mov     rax,[rsp+30h]
    sub     rax,[rsp+20h]
L32:
    cmp     rax,8
    jb      L83
    mov     r11,[rsp+20h]
    mov     [rsp],r11
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    mov     edx,0FFFFFE70h
    mov     ecx,0FFFFFD78h
    call    ryo_h_Memcpy
    mov     r11,[rsp+30h]
    mov     r10,[rsp+10h]
    lea     r13,[r11+r10*8]
    mov     [rsp+100h],r13
    mov     r11,[rsp+20h]
    mov     r10,[rsp+10h]
    lea     rbp,[r11+r10*8]
    mov     [rsp+0F8h],rbp
    mov     [rsp+198h],rbp
    lea     r11,[k11]
    mov     [rsp+50h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L35
    jmp     L85
L33:
    mov     r11,[rsp+30h]
    cmp     r11,0
    je      L83
    jmp     L29
L34:
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L83
    jmp     L30
L35:
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L40
    jmp     L87
L36:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L86
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L41
    jmp     L87
L37:
    cmp     r13,rbp
    jae     L38
    mov     rax,rbp
    sub     rax,r13
    jmp     L39
L38:
    mov     rax,r13
    sub     rax,rbp
L39:
    cmp     rax,8
    jb      L87
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE68h
    mov     edx,0FFFFFE70h
    mov     ecx,0FFFFFD70h
    call    ryo_h_Memcpy
    mov     r13d,1
    jmp     L42
L40:
    cmp     r13,0
    je      L87
    jmp     L36
L41:
    cmp     rbp,0
    je      L87
    jmp     L37
L42:
    mov     qword ptr [rsp+190h],0
    mov     r10,[rsp+10h]
    mov     [rsp+198h],r10
    movzx   ebp,word ptr [rsp+194h]
    movzx   ebx,byte ptr [rsp+196h]
    movzx   r14d,byte ptr [rsp+197h]
    mov     dword ptr [rsp+180h],0
    mov     [rsp+184h],bp
    mov     [rsp+186h],bl
    mov     [rsp+187h],r14b
    mov     r10,[rsp+10h]
    mov     [rsp+188h],r10
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE80h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     eax,[rsp+110h]
    movzx   ecx,word ptr [rsp+114h]
    movzx   edx,byte ptr [rsp+116h]
    movzx   esi,byte ptr [rsp+117h]
    mov     rdi,[rsp+118h]
    mov     [rsp+0F8h],rdi
    mov     dword ptr [rsp+100h],0
    mov     [rsp+104h],bp
    mov     [rsp+106h],bl
    mov     [rsp+107h],r14b
    mov     r10,[rsp+10h]
    mov     [rsp+108h],r10
    mov     [rsp+180h],eax
    mov     [rsp+184h],cx
    mov     [rsp+186h],dl
    mov     [rsp+187h],sil
    mov     [rsp+188h],rdi
    mov     dword ptr [rsp+190h],0
    mov     [rsp+194h],bp
    mov     [rsp+196h],bl
    mov     [rsp+197h],r14b
    mov     r10,[rsp+10h]
    mov     [rsp+198h],r10
    mov     rbx,[rsp+20h]
    mov     r14,[rsp+28h]
    mov     rbp,[rsp+20h]
    mov     r15,[rsp+10h]
    mov     [rsp+80h],r13
    mov     r13,[rsp+30h]
    mov     r11,[rsp+18h]
    mov     [rsp+78h],r11
L43:
    lea     rax,[rsp+180h]
    mov     [rsp+110h],rax
    mov     qword ptr [rsp+118h],2
    mov     rax,[rsp+188h]
    mov     rcx,[rsp+180h]
    sub     rax,rcx
    cmp     rax,0
    jbe     L44
    mov     rax,[rsp+180h]
    lea     r11,[image.k6944]
    mov     [rsp+0D0h],r11
    mov     r11,rax
    add     r11,1
    jb      L89
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+180h],rdx
    mov     [rsp+0E8h],rax
    mov     qword ptr [rsp+0E0h],1
    lea     rdx,[rsp+190h]
    lea     r11,[image.k7064]
    mov     [rsp+0C8h],r11
    cmp     rax,2
    jae     L90
    lea     r12,[rdx+rax*8]
    lea     rdi,[rsp+290h]
    lea     rsi,[ro+4]
    call    qword ptr [image.sym46]
    mov     rax,[r12]
    mov     r12,rax
    mov     eax,1
    jmp     L45
L44:
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE50h
    lea     rdx,[image.k6840]
    mov     ecx,10h
    call    ryo_h_Const
    mov     eax,0
L45:
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L46]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L46:
    .long   L48
    .long   L47
    .long   L99
L47:
    mov     [rsp+118h],r12
    lea     rax,[r13+r12*8]
    mov     [rsp+110h],rax
    lea     rax,[rbp+r12*8]
    cmp     r12,0
    je      L51
    mov     rdx,r14
    sub     rdx,r15
    mov     [rsp+0D8h],r14
    mov     r14,r13
    mov     r13,rbx
    mov     rbx,rdx
    mov     [rsp+0B8h],rbp
    mov     [rsp+0B0h],r15
    mov     r11,[rsp+80h]
    mov     [rsp+90h],r11
    mov     [rsp+98h],rax
    mov     rax,[rsp+80h]
    mov     r11,[rsp+78h]
    mov     [rsp+0A0h],r11
    jmp     L52
L48:
    mov     [rsp+0F8h],rbx
    mov     [rsp+100h],r13
    mov     [rsp+108h],r14
    mov     [rsp+190h],rbx
    mov     [rsp+188h],r14
    mov     [rsp+180h],rbx
    lea     r11,[k18]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdx,rax
    cmp     edx,1
    jne     L91
    mov     rdx,rbx
    and     rdx,3
    cmp     rdx,0
    je      L50
    jmp     L92
L49:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rdx,rax
    cmp     r14,rdx
    ja      L92
    mov     rdx,[rsp+190h]
    mov     rdi,[rsp+188h]
    mov     [rsp+180h],rdi
    mov     [rsp+198h],rdx
    mov     r8,[rsp+100h]
    mov     [rsp+190h],r8
    mov     rsi,rdi
    mov     rdi,rdx
    mov     rdx,r8
    mov     rcx,[rsp+78h]
    call    qword ptr [fn20.slot]
    jmp     L64
L50:
    cmp     rbx,0
    je      L92
    jmp     L49
L51:
    mov     [rsp+0D8h],r14
    mov     r14,r13
    mov     r13,rbx
    mov     rbx,r15
    mov     [rsp+0B8h],rbp
    mov     [rsp+0B0h],r15
    mov     r11,[rsp+80h]
    mov     [rsp+90h],r11
    mov     [rsp+98h],rax
    mov     rax,[rsp+80h]
    mov     r11,[rsp+78h]
    mov     [rsp+0A0h],r11
L52:
    cmp     rax,rbx
    jae     L62
    mov     r11,rax
    add     r11,1
    mov     [rsp+0A8h],r11
    mov     rdx,[rsp+110h]
    lea     r12,[rdx+rax*8]
    mov     r11,[rsp+98h]
    lea     rbp,[r11+rax*8]
    lea     r11,[k15]
    mov     [rsp+0C0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L94
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L57
    jmp     L96
L53:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L95
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L58
    jmp     L96
L54:
    cmp     r12,rbp
    jae     L55
    mov     rax,rbp
    sub     rax,r12
    jmp     L56
L55:
    mov     rax,r12
    sub     rax,rbp
L56:
    cmp     rax,8
    jb      L96
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rdi,[rsp+98h]
    mov     rsi,rbp
    mov     rdx,[rsp+0A0h]
    call    qword ptr [fn17.slot]
    jmp     L63
L57:
    cmp     r12,0
    je      L96
    jmp     L53
L58:
    cmp     rbp,0
    je      L96
    jmp     L54
L59:
    mov     rbx,rdx
    mov     r13,rdi
    mov     r14,r8
    mov     [rsp+0D8h],r9
    mov     [rsp+0B8h],r12
    mov     [rsp+0B0h],rbp
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rcx
    mov     [rsp+0A0h],r15
    jmp     L52
L60:
    mov     r11,[rsp+0F8h]
    mov     rax,[rsp+100h]
    mov     [rsp+198h],rax
    mov     rax,[rsp+108h]
    mov     [rsp+190h],rax
L61:
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+160h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+140h]
    mov     r15,[rsp+130h]
    mov     rbp,[rsp+120h]
    add     rsp,298h
    ret
L62:
    mov     rbx,r13
    mov     r13,r14
    mov     r14,[rsp+0D8h]
    mov     rbp,[rsp+0B8h]
    mov     r15,[rsp+0B0h]
    mov     r11,[rsp+90h]
    mov     [rsp+80h],r11
    mov     r11,[rsp+0A0h]
    mov     [rsp+78h],r11
    jmp     L43
L63:
    mov     rax,[rsp+0A8h]
    mov     rdx,rbx
    mov     rdi,r13
    mov     r8,r14
    mov     r9,[rsp+0D8h]
    mov     r12,[rsp+0B8h]
    mov     rbp,[rsp+0B0h]
    mov     rsi,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     r15,[rsp+0A0h]
    jmp     L59
L64:
    jmp     L60
L65:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L66:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L68
    jmp     L68
L67:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L68:
    call    image.sym10
    ud2
L69:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L70:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L72
    jmp     L72
L71:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L72:
    call    image.sym10
    ud2
L73:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L74:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L76
    jmp     L76
L75:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L76:
    call    image.sym10
    ud2
L77:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L78:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L80
    jmp     L80
L79:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    call    image.sym10
    ud2
L81:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L82:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L84
    jmp     L84
L83:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L84:
    call    image.sym10
    ud2
L85:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L86:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L88
    jmp     L88
L87:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L88:
    call    image.sym10
    ud2
L89:
    lea     rax,[image.k7768]
    mov     rdi,rax
    mov     esi,175h
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L90:
    lea     rax,[image.k9969]
    mov     rdi,rax
    mov     esi,1ADh
    mov     edx,0
    mov     rcx,[rsp+0C8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L91:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L93
L92:
    lea     rax,[image.k9407]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L93:
    call    image.sym10
    ud2
L94:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L95:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L97
    jmp     L97
L96:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    call    image.sym10
    ud2
L98:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L99:
    ud2
L100:
    lea     rax,[rsp+180h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L101
    jmp     L103
L101:
    mov     [rsp],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    call    ryo_h_Resume
    ud2
L102:
    lea     rax,[rsp+0F8h]
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
L105:
    ret
L106:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-2F0h]
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
    mov     r11,[rsp+28h]
    mov     [rdx-210h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-218h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     rbp,[rsp+18h]
    mov     r15,[rsp+20h]
    lea     rsp,[rsp+60h]
    jmp     L43
L107:
    ret
L108:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-310h]
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
    mov     r11,[rsp+20h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1F0h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+80h]
    jmp     L52
L109:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-310h]
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
    mov     rdi,[rsp+10h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     rbp,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     r15,[rsp+48h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+80h]
    jmp     L59
L110:
    ret
L111:
    ret
L112:
    ret
L113:
    ret
L114:
    ret

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,198h
    mov     [rsp+180h],rbx
    mov     [rsp+170h],r12
    mov     [rsp+160h],r13
    mov     [rsp+150h],r14
    mov     [rsp+140h],r15
    mov     [rsp+130h],rbp
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rdx
    cmp     rsi,9
    jb      L131
    mov     rdi,[rsp+20h]
    mov     esi,0
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    fn0
    mov     r13,[rsp+20h]
    lea     r13,[r13+4]
    mov     r14,[rsp+20h]
    lea     r14,[r14+1Ch]
    mov     r11,[rsp+20h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    r15b
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
    lea     rax,[image.k2088]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+70h]
    lea     r11,[image.k2112]
    mov     [rsp+10h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L83
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L4
    jmp     L85
L0:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L84
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L5
    jmp     L85
L1:
    cmp     r13,r14
    jae     L2
    mov     rax,r14
    sub     rax,r13
    jmp     L3
L2:
    mov     rax,r13
    sub     rax,r14
L3:
    cmp     rax,4
    jb      L85
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbp,[rsp+20h]
    lea     rbp,[rbp+8]
    mov     r15,[rsp+20h]
    lea     r15,[r15+14h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+14h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+8]
    cmp     eax,ecx
    setb    r12b
    mov     rdi,r12
    mov     rsi,r15
    mov     rdx,rbp
    movzx   edi,dil
    call    image.fn46
    mov     rbx,rax
    mov     rdi,r12
    mov     rsi,rbp
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+80h],eax
    lea     rax,[image.k2088]
    mov     rdi,rbx
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+80h]
    lea     r11,[image.k2112]
    mov     [rsp+28h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L6
    jmp     L87
L4:
    cmp     r13,0
    je      L85
    jmp     L0
L5:
    cmp     r14,0
    je      L85
    jmp     L1
L6:
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L11
    jmp     L89
L7:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L88
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L12
    jmp     L89
L8:
    cmp     rbx,r15
    jae     L9
    mov     rax,r15
    sub     rax,rbx
    jmp     L10
L9:
    mov     rax,rbx
    sub     rax,r15
L10:
    cmp     rax,4
    jb      L89
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+20h]
    lea     r13,[r13+10h]
    mov     r14,[rsp+20h]
    lea     r14,[r14+20h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+10h]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r12,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+90h],eax
    lea     rax,[image.k2088]
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+90h]
    lea     r11,[image.k2112]
    mov     [rsp+38h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L13
    jmp     L91
L11:
    cmp     rbx,0
    je      L89
    jmp     L7
L12:
    cmp     r15,0
    je      L89
    jmp     L8
L13:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L18
    jmp     L93
L14:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L92
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L19
    jmp     L93
L15:
    cmp     r12,r14
    jae     L16
    mov     rax,r14
    sub     rax,r12
    jmp     L17
L16:
    mov     rax,r12
    sub     rax,r14
L17:
    cmp     rax,4
    jb      L93
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+1Ch]
    mov     r11,[rsp+20h]
    mov     eax,[r11+1Ch]
    mov     r11,[rsp+20h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    r15b
    mov     rdi,r15
    mov     rsi,rbx
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,[rsp+20h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0A0h],eax
    lea     rax,[image.k2088]
    mov     rdi,rbp
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,[rsp+20h]
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r15,[rsp+0A0h]
    lea     r11,[image.k2112]
    mov     [rsp+30h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L20
    jmp     L95
L18:
    cmp     r12,0
    je      L93
    jmp     L14
L19:
    cmp     r14,0
    je      L93
    jmp     L15
L20:
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L25
    jmp     L97
L21:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L96
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L26
    jmp     L97
L22:
    cmp     r15,rbx
    jae     L23
    mov     rax,rbx
    sub     rax,r15
    jmp     L24
L23:
    mov     rax,r15
    sub     rax,rbx
L24:
    cmp     rax,4
    jb      L97
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+8]
    mov     r14,[rsp+20h]
    lea     r14,[r14+10h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+10h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+8]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0B0h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+0B0h]
    lea     r11,[image.k2112]
    mov     [rsp+40h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L27
    jmp     L99
L25:
    cmp     r15,0
    je      L97
    jmp     L21
L26:
    cmp     rbx,0
    je      L97
    jmp     L22
L27:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L32
    jmp     L101
L28:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L100
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L33
    jmp     L101
L29:
    cmp     r12,r14
    jae     L30
    mov     rax,r14
    sub     rax,r12
    jmp     L31
L30:
    mov     rax,r12
    sub     rax,r14
L31:
    cmp     rax,4
    jb      L101
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+0Ch]
    mov     r15,[rsp+20h]
    lea     r15,[r15+20h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+0Ch]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0C0h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+0C0h]
    lea     r11,[image.k2112]
    mov     [rsp+48h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L34
    jmp     L103
L32:
    cmp     r12,0
    je      L101
    jmp     L28
L33:
    cmp     r14,0
    je      L101
    jmp     L29
L34:
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L39
    jmp     L105
L35:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L104
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L40
    jmp     L105
L36:
    cmp     rbx,r15
    jae     L37
    mov     rax,r15
    sub     rax,rbx
    jmp     L38
L37:
    mov     rax,rbx
    sub     rax,r15
L38:
    cmp     rax,4
    jb      L105
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+14h]
    mov     r14,[rsp+20h]
    lea     r14,[r14+18h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+18h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+14h]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0D0h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+0D0h]
    lea     r11,[image.k2112]
    mov     [rsp+58h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L41
    jmp     L107
L39:
    cmp     rbx,0
    je      L105
    jmp     L35
L40:
    cmp     r15,0
    je      L105
    jmp     L36
L41:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L46
    jmp     L109
L42:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L108
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L47
    jmp     L109
L43:
    cmp     r12,r14
    jae     L44
    mov     rax,r14
    sub     rax,r12
    jmp     L45
L44:
    mov     rax,r12
    sub     rax,r14
L45:
    cmp     rax,4
    jb      L109
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+8]
    mov     r11,[rsp+20h]
    mov     eax,[r11+8]
    mov     r11,[rsp+20h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    r15b
    mov     rdi,r15
    mov     rsi,rbx
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,[rsp+20h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0E0h],eax
    lea     rax,[image.k2088]
    mov     rdi,rbp
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,[rsp+20h]
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r15,[rsp+0E0h]
    lea     r11,[image.k2112]
    mov     [rsp+50h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L48
    jmp     L111
L46:
    cmp     r12,0
    je      L109
    jmp     L42
L47:
    cmp     r14,0
    je      L109
    jmp     L43
L48:
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L53
    jmp     L113
L49:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L112
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L54
    jmp     L113
L50:
    cmp     r15,rbx
    jae     L51
    mov     rax,rbx
    sub     rax,r15
    jmp     L52
L51:
    mov     rax,r15
    sub     rax,rbx
L52:
    cmp     rax,4
    jb      L113
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+4]
    mov     r14,[rsp+20h]
    lea     r14,[r14+0Ch]
    mov     r11,[rsp+20h]
    mov     eax,[r11+0Ch]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+4]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+0F0h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+0F0h]
    lea     r11,[image.k2112]
    mov     [rsp+60h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L55
    jmp     L115
L53:
    cmp     r15,0
    je      L113
    jmp     L49
L54:
    cmp     rbx,0
    je      L113
    jmp     L50
L55:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L60
    jmp     L117
L56:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L116
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L61
    jmp     L117
L57:
    cmp     r12,r14
    jae     L58
    mov     rax,r14
    sub     rax,r12
    jmp     L59
L58:
    mov     rax,r12
    sub     rax,r14
L59:
    cmp     rax,4
    jb      L117
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+10h]
    mov     r15,[rsp+20h]
    lea     r15,[r15+14h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+14h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+10h]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+100h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+100h]
    lea     r11,[image.k2112]
    mov     [rsp+68h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L62
    jmp     L119
L60:
    cmp     r12,0
    je      L117
    jmp     L56
L61:
    cmp     r14,0
    je      L117
    jmp     L57
L62:
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L67
    jmp     L121
L63:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L120
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L68
    jmp     L121
L64:
    cmp     rbx,r15
    jae     L65
    mov     rax,r15
    sub     rax,rbx
    jmp     L66
L65:
    mov     rax,rbx
    sub     rax,r15
L66:
    cmp     rax,4
    jb      L121
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+20h]
    lea     r12,[r12+1Ch]
    mov     r14,[rsp+20h]
    lea     r14,[r14+20h]
    mov     r11,[rsp+20h]
    mov     eax,[r11+20h]
    mov     r11,[rsp+20h]
    mov     ecx,[r11+1Ch]
    cmp     eax,ecx
    setb    bpl
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,rbp
    mov     rsi,r12
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+110h],eax
    lea     rax,[image.k2088]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+110h]
    lea     r13,[image.k2112]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L69
    jmp     L123
L67:
    cmp     rbx,0
    je      L121
    jmp     L63
L68:
    cmp     r15,0
    je      L121
    jmp     L64
L69:
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L74
    jmp     L125
L70:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L124
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L75
    jmp     L125
L71:
    cmp     r12,r14
    jae     L72
    mov     rax,r14
    sub     rax,r12
    jmp     L73
L72:
    mov     rax,r12
    sub     rax,r14
L73:
    cmp     rax,4
    jb      L125
    mov     rdi,r14
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
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
    mov     rbx,[rsp+20h]
    lea     rbx,[rbx+4]
    mov     r11,[rsp+20h]
    mov     eax,[r11+4]
    mov     r11,[rsp+20h]
    mov     ecx,[r11]
    cmp     eax,ecx
    setb    r15b
    mov     rdi,r15
    mov     rsi,rbx
    mov     rdx,[rsp+20h]
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,[rsp+20h]
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+120h],eax
    lea     rax,[image.k2088]
    mov     rdi,rbp
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,0
    mov     r8,rax
    movzx   ecx,cl
    call    image.fn183
    mov     rdi,[rsp+20h]
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r15,[rsp+120h]
    lea     rbp,[image.k2112]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L76
    jmp     L127
L74:
    cmp     r12,0
    je      L125
    jmp     L70
L75:
    cmp     r14,0
    je      L125
    jmp     L71
L76:
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L81
    jmp     L129
L77:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L128
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L82
    jmp     L129
L78:
    cmp     r15,rbx
    jae     L79
    mov     rax,rbx
    sub     rax,r15
    jmp     L80
L79:
    mov     rax,r15
    sub     rax,rbx
L80:
    cmp     rax,4
    jb      L129
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
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
    mov     rbx,[rsp+180h]
    mov     r12,[rsp+170h]
    mov     r13,[rsp+160h]
    mov     r14,[rsp+150h]
    mov     r15,[rsp+140h]
    mov     rbp,[rsp+130h]
    add     rsp,198h
    ret
L81:
    cmp     r15,0
    je      L129
    jmp     L77
L82:
    cmp     rbx,0
    je      L129
    jmp     L78
L83:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L84:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L86
    jmp     L86
L85:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    image.sym49
    ud2
L86:
    call    image.sym10
    ud2
L87:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L88:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L90
    jmp     L90
L89:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+28h]
    movzx   edx,dl
    call    image.sym49
    ud2
L90:
    call    image.sym10
    ud2
L91:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L92:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L94
    jmp     L94
L93:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L94:
    call    image.sym10
    ud2
L95:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L96:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L98
    jmp     L98
L97:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+30h]
    movzx   edx,dl
    call    image.sym49
    ud2
L98:
    call    image.sym10
    ud2
L99:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L100:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L102
    jmp     L102
L101:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    call    image.sym10
    ud2
L103:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L104:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L106
    jmp     L106
L105:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L106:
    call    image.sym10
    ud2
L107:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L108:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L110
    jmp     L110
L109:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+58h]
    movzx   edx,dl
    call    image.sym49
    ud2
L110:
    call    image.sym10
    ud2
L111:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L112:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L114
    jmp     L114
L113:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+50h]
    movzx   edx,dl
    call    image.sym49
    ud2
L114:
    call    image.sym10
    ud2
L115:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L116:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L118
    jmp     L118
L117:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L118:
    call    image.sym10
    ud2
L119:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L120:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L122
    jmp     L122
L121:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L122:
    call    image.sym10
    ud2
L123:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L124:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L126
    jmp     L126
L125:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L126:
    call    image.sym10
    ud2
L127:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L128:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L130
    jmp     L130
L129:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L130:
    call    image.sym10
    ud2
L131:
    lea     rdi,[rsp+190h]
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
    lea     r13,[k3]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L9
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L11
L0:
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L2
L1:
    cmp     r14,0
    je      L11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L10
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    jne     L11
    cmp     rbx,0
    je      L11
    jmp     L0
L2:
    lea     rbx,[rsp+10h]
    lea     r14,[k5]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L13
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L7
    jmp     L15
L3:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L14
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L8
    jmp     L15
L4:
    cmp     rbx,r12
    jae     L5
    mov     rax,r12
    sub     rax,rbx
    jmp     L6
L5:
    mov     rax,rbx
    sub     rax,r12
L6:
    cmp     rax,4
    jb      L15
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    add     rsp,68h
    ret
L7:
    cmp     rbx,0
    je      L15
    jmp     L3
L8:
    cmp     r12,0
    je      L15
    jmp     L4
L9:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L10:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L12
L11:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L12:
    call    image.sym10
    ud2
L13:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L14:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L16
    jmp     L16
L15:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L16:
    call    image.sym10
    ud2
  ; OSR entries
    lea     r11,[L17]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L17:
    .long   L18
L18:
    ret

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx+18h]
    lea     rax,[rax-8]
    jmp     L9
L0:
    mov     rcx,[rbx]
    jmp     L2
L1:
    mov     rcx,[rbx+18h]
L2:
    mov     rdx,[rbx+10h]
    lea     r13,[rcx+rdx*8]
    mov     r14,[rbx+8]
    lea     r15,[k0]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L10
    mov     rcx,r14
    and     rcx,3
    cmp     rcx,0
    je      L7
    jmp     L12
L3:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L11
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L8
    jmp     L12
L4:
    cmp     r14,r13
    jae     L5
    mov     rcx,r13
    sub     rcx,r14
    jmp     L6
L5:
    mov     rcx,r14
    sub     rcx,r13
L6:
    cmp     rcx,8
    jb      L12
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   ecx,r12b
    mov     rdx,[rbx+10h]
    add     rdx,rcx
    mov     [rbx+10h],rdx
    mov     rcx,[rbx+8]
    lea     rcx,[rcx+8]
    mov     [rbx+8],rcx
    mov     rax,r13
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L7:
    cmp     r14,0
    je      L12
    jmp     L3
L8:
    cmp     r13,0
    je      L12
    jmp     L4
L9:
    mov     [rbx+18h],rax
    test    r12b,r12b
    jne     L0
    jmp     L1
L10:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L11:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L13
    jmp     L13
L12:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L13:
    call    image.sym10
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

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,1F8h
    mov     [rsp+0F0h],rbx
    mov     [rsp+0E0h],r12
    mov     [rsp+0D0h],r13
    mov     [rsp+0C0h],r14
    mov     [rsp+0B0h],r15
    mov     [rsp+0A0h],rbp
    mov     rax,[rsp+200h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     [rsp+28h],r9
L0:
    mov     r10,[rsp+50h]
    mov     [rsp+130h],r10
    mov     r11d,20h
    cmp     r11,[rsp+48h]
    jb      L1
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+38h]
    mov     r8,[rsp+30h]
    call    qword ptr [image.fn81.slot]
    jmp     L20
L1:
    cmp     r8d,0
    jne     L2
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+38h]
    mov     r8d,1
    mov     r9,[rsp+30h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
    jmp     L20
L2:
    mov     r11,r8
    sub     r11d,1
    mov     [rsp+20h],r11
    mov     r10,[rsp+48h]
    mov     [rsp+130h],r10
    mov     rdi,[rsp+48h]
    mov     esi,8
    call    ryo_hr_DivUW64
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
    setb    dl
    mov     esi,[r15]
    cmp     ecx,esi
    setb    cl
    cmp     dl,cl
    jne     L4
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     ecx,[rbp]
    mov     esi,[r15]
    cmp     ecx,esi
    setb    cl
    xor     ecx,edx
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
    jb      L23
    sub     rcx,[rsp+50h]
    mov     rdi,rcx
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L13
L6:
    mov     rcx,rax
    imul    rcx,8
    cmp     rcx,40h
    jb      L7
    jmp     L8
L7:
    mov     rbx,[rsp+50h]
    jmp     L9
L8:
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r14,rax
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
    mov     r15,rax
L9:
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     eax,[rbx]
    mov     ecx,[rbp]
    cmp     eax,ecx
    setb    cl
    mov     esi,[r15]
    cmp     eax,esi
    setb    al
    cmp     cl,al
    jne     L11
    mov     r11,[rsp+30h]
    mov     r11,[r11]
    mov     eax,[rbp]
    mov     esi,[r15]
    cmp     eax,esi
    setb    al
    xor     eax,ecx
    test    al,al
    je      L10
    jmp     L12
L10:
    mov     r15,rbp
    jmp     L12
L11:
    mov     r15,rbx
L12:
    lea     rax,[image.k1464]
    cmp     r15,[rsp+50h]
    jb      L24
    sub     r15,[rsp+50h]
    mov     rdi,r15
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
L13:
    cmp     rcx,[rsp+48h]
    setb    sil
    lea     rdi,[image.k1512]
    test    sil,sil
    je      L25
    mov     r11,[rsp+50h]
    lea     rsi,[r11+rcx*8]
    mov     rsi,[rsi]
    mov     [rsp+130h],rsi
    lea     rsi,[rsp+130h]
    mov     [rsp+118h],rsi
    mov     r9,[rsp+50h]
    mov     rbx,[rsp+48h]
    mov     r12,rcx
    mov     r13,[rsp+30h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+38h]
    mov     rbp,[rsp+20h]
    mov     rcx,rsi
    mov     rsi,[rsp+28h]
    jmp     L21
L14:
    mov     r11,[rsp+58h]
    cmp     r11,r8
    jae     L26
    mov     r10,[rsp+58h]
    lea     rbp,[rsi+r10*8]
    mov     [rsp+110h],rbp
    mov     [rsp+118h],rcx
    mov     r11,[rbx]
    mov     r9d,[rcx]
    mov     ebp,[rbp]
    cmp     r9d,ebp
    setb    r9b
    mov     rbp,r9
    xor     ebp,1
    cmp     r9b,1
    jne     L15
    jmp     L16
L15:
    mov     [rsp+78h],r8
    mov     [rsp+80h],r14
    mov     r14,r12
    mov     r12,r15
    mov     r15,r13
    mov     r13,rbx
    mov     rbx,rsi
    mov     esi,0
    mov     [rsp+88h],rcx
    mov     rcx,[rsp+58h]
    jmp     L18
L16:
    mov     rbp,[rsp+58h]
    mov     [rsp+60h],r14
    mov     r14,r12
    mov     r12,r8
    mov     [rsp+68h],r15
    mov     r15,r13
    mov     r13,rbx
    mov     rbx,rsi
    mov     [rsp+70h],rcx
    jmp     L17
L17:
    mov     [rsp],r13
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,rbp
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    mov     rcx,rax
    cmp     rcx,0
    sete    sil
    mov     [rsp+78h],r12
    mov     r11,[rsp+60h]
    mov     [rsp+80h],r11
    mov     r12,[rsp+68h]
    mov     r11,[rsp+70h]
    mov     [rsp+88h],r11
    mov     r10,rbp
    mov     rbp,rsi
    mov     rsi,rcx
    mov     rcx,r10
L18:
    test    bpl,bpl
    je      L19
    mov     [rsp+118h],rbx
    mov     [rsp+108h],r13
    lea     r9,[rsp+108h]
    mov     [rsp+110h],r9
    mov     [rsp],r9
    mov     rdi,rbx
    mov     rsi,[rsp+78h]
    mov     rdx,r14
    mov     r8,rcx
    mov     rcx,r15
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     [rsp+90h],rax
    mov     r11,[rsp+78h]
    cmp     r11,[rsp+90h]
    jb      L27
    mov     r9,[rsp+78h]
    sub     r9,[rsp+90h]
    mov     [rsp+118h],r9
    mov     r10,[rsp+78h]
    mov     [rsp+100h],r10
    mov     r10,[rsp+90h]
    lea     rbp,[rbx+r10*8]
    mov     [rsp+108h],rbp
    mov     [rsp+110h],r9
    mov     [rsp+50h],rbp
    mov     [rsp+48h],r9
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],r13
    mov     r8,[rsp+80h]
    mov     qword ptr [rsp+28h],0
    jmp     L0
L19:
    lea     r9,[k12]
    lea     rbp,[rsp+100h]
    mov     rdi,rbp
    mov     rdx,[rsp+78h]
    mov     rcx,rsi
    mov     rsi,rbx
    mov     r8,r9
    call    qword ptr [fn13.slot]
    mov     rbx,[rsp+100h]
    mov     rbp,[rsp+108h]
    mov     rsi,[rsp+110h]
    mov     r9,[rsp+118h]
    mov     [rsp],r13
    mov     rdi,rsi
    mov     rsi,r9
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,[rsp+80h]
    mov     r9,r12
    mov     r8d,r8d
    call    fn14
    mov     [rsp+50h],rbx
    mov     [rsp+48h],rbp
    mov     [rsp+40h],r14
    mov     [rsp+38h],r15
    mov     [rsp+30h],r13
    mov     r8,[rsp+80h]
    mov     r11,[rsp+88h]
    mov     [rsp+28h],r11
    jmp     L0
L20:
    mov     rbx,[rsp+0F0h]
    mov     r12,[rsp+0E0h]
    mov     r13,[rsp+0D0h]
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0B0h]
    mov     rbp,[rsp+0A0h]
    add     rsp,1F8h
    ret
L21:
    cmp     rsi,0
    je      L22
    mov     r8,rbx
    mov     [rsp+58h],r12
    mov     rbx,r13
    mov     r12,r14
    mov     r13,r15
    mov     r14,rbp
    mov     r15,rcx
    mov     rcx,rsi
    mov     rsi,r9
    jmp     L14
L22:
    mov     [rsp+60h],rbp
    mov     rbp,r12
    mov     r12,rbx
    mov     rbx,r9
    mov     [rsp+68h],rcx
    mov     [rsp+70h],rsi
    jmp     L17
L23:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L24:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L25:
    lea     rax,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L26:
    lea     rax,[k7]
    mov     rdi,[rsp+58h]
    mov     rsi,r8
    mov     rdx,rax
    call    sym5
    ud2
L27:
    lea     rax,[k15]
    mov     rdi,[rsp+90h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+78h]
    mov     rcx,rax
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1C8h],r11
    mov     r8,[rsp+28h]
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-198h],r11
    mov     rcx,[rsp]
    mov     rsi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L14
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-188h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-180h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L17
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
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+48h]
    mov     [rdx-1F0h],r11
    mov     rsi,[rsp]
    mov     r9,[rsp+8]
    mov     rbx,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+38h]
    mov     rcx,[rsp+40h]
    lea     rsp,[rsp+50h]
    jmp     L21

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
    sub     rsp,278h
    mov     [rsp+160h],rbx
    mov     [rsp+150h],r12
    mov     [rsp+140h],r13
    mov     [rsp+130h],r14
    mov     [rsp+120h],r15
    mov     [rsp+110h],rbp
    mov     r11,[rsp+280h]
    mov     [rsp+58h],r11
    cmp     rcx,rsi
    jb      L107
    cmp     rsi,r8
    jbe     L107
    jmp     L72
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+270h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rcx,[rsp+100h]
    lea     rcx,[r12+rcx*8]
    mov     [rsp+80h],r14
    mov     [rsp+70h],rbx
    mov     rbx,rcx
    mov     [rsp+68h],r12
    mov     [rsp+60h],r15
    mov     [rsp+38h],rbp
    mov     r11,[rsp+20h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+50h],r11
L1:
    mov     rcx,[rsp+178h]
    cmp     rcx,rbx
    jae     L37
    mov     rcx,[rsp+178h]
    mov     r11,[rsp+80h]
    mov     rax,[r11]
    mov     r11,[rax]
    mov     eax,[r13]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    al
    mov     rbp,rax
    xor     ebp,1
    mov     [rsp+106h],bpl
    mov     rcx,[rsp+188h]
    lea     rcx,[rcx-8]
    mov     [rsp+188h],rcx
    test    al,al
    jne     L2
    mov     rax,[rsp+170h]
    jmp     L3
L2:
    mov     rax,[rsp+188h]
L3:
    mov     rcx,[rsp+180h]
    lea     r15,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+78h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L74
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L8
    jmp     L76
L4:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L75
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L9
    jmp     L76
L5:
    cmp     r12,r15
    jae     L6
    mov     rax,r15
    sub     rax,r12
    jmp     L7
L6:
    mov     rax,r12
    sub     rax,r15
L7:
    cmp     rax,8
    jb      L76
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,bpl
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     ecx,[r13]
    mov     eax,[rax+8]
    cmp     ecx,eax
    setb    al
    mov     r14,rax
    xor     r14d,1
    mov     [rsp+106h],r14b
    mov     rcx,[rsp+188h]
    lea     rcx,[rcx-8]
    mov     [rsp+188h],rcx
    test    al,al
    jne     L11
    jmp     L10
L8:
    cmp     r12,0
    je      L76
    jmp     L4
L9:
    cmp     r15,0
    je      L76
    jmp     L5
L10:
    mov     rax,[rsp+170h]
    jmp     L12
L11:
    mov     rax,[rsp+188h]
L12:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r15,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L78
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L17
    jmp     L80
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L79
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L18
    jmp     L80
L14:
    cmp     r15,r12
    jae     L15
    mov     rax,r12
    sub     rax,r15
    jmp     L16
L15:
    mov     rax,r15
    sub     rax,r12
L16:
    cmp     rax,8
    jb      L80
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r14b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     ecx,[r13]
    mov     eax,[rax+8]
    cmp     ecx,eax
    setb    al
    mov     rbp,rax
    xor     ebp,1
    mov     [rsp+106h],bpl
    mov     rcx,[rsp+188h]
    lea     rcx,[rcx-8]
    mov     [rsp+188h],rcx
    test    al,al
    jne     L20
    jmp     L19
L17:
    cmp     r15,0
    je      L80
    jmp     L13
L18:
    cmp     r12,0
    je      L80
    jmp     L14
L19:
    mov     rax,[rsp+170h]
    jmp     L21
L20:
    mov     rax,[rsp+188h]
L21:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r14,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L82
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L26
    jmp     L84
L22:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L83
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L27
    jmp     L84
L23:
    cmp     r14,r12
    jae     L24
    mov     rax,r12
    sub     rax,r14
    jmp     L25
L24:
    mov     rax,r14
    sub     rax,r12
L25:
    cmp     rax,8
    jb      L84
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,bpl
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     ecx,[r13]
    mov     eax,[rax+8]
    cmp     ecx,eax
    setb    al
    mov     r15,rax
    xor     r15d,1
    mov     [rsp+106h],r15b
    mov     rcx,[rsp+188h]
    lea     rcx,[rcx-8]
    mov     [rsp+188h],rcx
    test    al,al
    jne     L29
    jmp     L28
L26:
    cmp     r14,0
    je      L84
    jmp     L22
L27:
    cmp     r12,0
    je      L84
    jmp     L23
L28:
    mov     rax,[rsp+170h]
    jmp     L30
L29:
    mov     rax,[rsp+188h]
L30:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r14,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+98h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L86
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L35
    jmp     L88
L31:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L87
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L36
    jmp     L88
L32:
    cmp     r14,r12
    jae     L33
    mov     rax,r12
    sub     rax,r14
    jmp     L34
L33:
    mov     rax,r14
    sub     rax,r12
L34:
    cmp     rax,8
    jb      L88
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r15b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    jmp     L1
L35:
    cmp     r14,0
    je      L88
    jmp     L31
L36:
    cmp     r12,0
    je      L88
    jmp     L32
L37:
    mov     r10,[rsp+70h]
    mov     [rsp+100h],r10
    mov     r11,[rsp+68h]
    mov     r10,[rsp+70h]
    lea     rax,[r11+r10*8]
    mov     rbx,rax
    mov     r11,[rsp+80h]
    mov     [rsp+0D0h],r11
    mov     r14,[rsp+70h]
    mov     r11,[rsp+60h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+0B8h],r11
L38:
    mov     rax,[rsp+178h]
    cmp     rax,rbx
    jae     L47
    mov     rax,[rsp+178h]
    mov     r11,[rsp+0D0h]
    mov     rcx,[r11]
    mov     r11,[rcx]
    mov     ecx,[r13]
    mov     eax,[rax]
    cmp     ecx,eax
    setb    al
    mov     r15,rax
    xor     r15d,1
    mov     [rsp+106h],r15b
    mov     rcx,[rsp+188h]
    lea     rcx,[rcx-8]
    mov     [rsp+188h],rcx
    test    al,al
    jne     L39
    mov     rax,[rsp+170h]
    jmp     L40
L39:
    mov     rax,[rsp+188h]
L40:
    mov     rcx,[rsp+180h]
    lea     rbp,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+0D8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L90
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L45
    jmp     L92
L41:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L91
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L46
    jmp     L92
L42:
    cmp     r12,rbp
    jae     L43
    mov     rax,rbp
    sub     rax,r12
    jmp     L44
L43:
    mov     rax,r12
    sub     rax,rbp
L44:
    cmp     rax,8
    jb      L92
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r15b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    jmp     L38
L45:
    cmp     r12,0
    je      L92
    jmp     L41
L46:
    cmp     rbp,0
    je      L92
    jmp     L42
L47:
    cmp     r14,[rsp+0A0h]
    je      L56
    lea     rax,[rsp+170h]
    mov     [rsp+100h],rax
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    cmp     byte ptr [rsp+0C8h],0
    je      L48
    mov     rax,[rsp+170h]
    jmp     L49
L48:
    mov     rax,[rsp+188h]
L49:
    mov     rcx,[rsp+180h]
    lea     rbx,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+0E8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L94
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L54
    jmp     L96
L50:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L95
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L55
    jmp     L96
L51:
    cmp     r12,rbx
    jae     L52
    mov     rax,rbx
    sub     rax,r12
    jmp     L53
L52:
    mov     rax,r12
    sub     rax,rbx
L53:
    cmp     rax,8
    jb      L96
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,byte ptr [rsp+0C8h]
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+0C0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0A0h]
    mov     rbp,[rsp+0C8h]
    mov     r11,[rsp+0A8h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+0B0h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+0B8h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    cmp     r12,0
    je      L96
    jmp     L50
L55:
    cmp     rbx,0
    je      L96
    jmp     L51
L56:
    mov     r10,[rsp+0B0h]
    mov     [rsp+100h],r10
    mov     rbx,[rsp+180h]
    lea     r11,[k15]
    mov     [rsp+0E0h],r11
    cmp     rbx,0
    jne     L57
    mov     r13d,1
    jmp     L58
L57:
    mov     r13d,0
L58:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L98
    mov     rax,[rsp+0B0h]
    and     rax,3
    cmp     rax,0
    je      L63
    jmp     L101
L59:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L99
    mov     rax,[rsp+0A8h]
    and     rax,3
    cmp     rax,0
    je      L64
    jmp     L101
L60:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     rbx
    mov     rdx,r10
    jb      L100
    mov     r11,[rsp+0B0h]
    cmp     r11,[rsp+0A8h]
    jae     L61
    mov     rcx,[rsp+0A8h]
    sub     rcx,[rsp+0B0h]
    jmp     L62
L61:
    mov     rcx,[rsp+0B0h]
    sub     rcx,[rsp+0A8h]
L62:
    cmp     rax,rcx
    ja      L101
    mov     rax,rbx
    imul    rax,8
    mov     r11,[rsp+0A8h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rax
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFDA0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+180h]
    mov     r11,[rsp+0A0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+100h],rax
    mov     rbx,rax
    mov     eax,0
    mov     r13,[rsp+0A0h]
    mov     r15,[rsp+0B8h]
    mov     rbp,[rsp+0A8h]
    jmp     L65
L63:
    test    r13b,r13b
    jne     L59
    mov     r11,[rsp+0B0h]
    cmp     r11,0
    je      L101
    jmp     L59
L64:
    test    r13b,r13b
    jne     L60
    mov     r11,[rsp+0A8h]
    cmp     r11,0
    je      L101
    jmp     L60
L65:
    cmp     rax,rbx
    jae     L73
    mov     r12,rax
    add     r12,1
    mov     [rsp+100h],rax
    mov     rcx,r13
    sub     rcx,1
    sub     rcx,rax
    lea     r14,[r15+rcx*8]
    mov     rcx,[rsp+180h]
    add     rcx,rax
    lea     r11,[rbp+rcx*8]
    mov     [rsp+0F0h],r11
    lea     r11,[k19]
    mov     [rsp+0F8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L103
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L70
    jmp     L105
L66:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L104
    mov     rax,[rsp+0F0h]
    and     rax,3
    cmp     rax,0
    je      L71
    jmp     L105
L67:
    cmp     r14,[rsp+0F0h]
    jae     L68
    mov     rax,[rsp+0F0h]
    sub     rax,r14
    jmp     L69
L68:
    mov     rax,r14
    sub     rax,[rsp+0F0h]
L69:
    cmp     rax,8
    jb      L105
    mov     rdi,[rsp+0F0h]
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rax,r12
    jmp     L65
L70:
    cmp     r14,0
    je      L105
    jmp     L66
L71:
    mov     r11,[rsp+0F0h]
    cmp     r11,0
    je      L105
    jmp     L67
L72:
    lea     rax,[rdi+r8*8]
    lea     rcx,[rdx+rsi*8]
    mov     [rsp+170h],rdx
    mov     [rsp+178h],rdi
    mov     qword ptr [rsp+180h],0
    mov     [rsp+188h],rcx
    mov     rbx,r8
    mov     r12,rdi
    mov     r13,rax
    mov     r14,[rsp+58h]
    mov     r15,rsi
    mov     rbp,r9
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    jmp     L0
L73:
    mov     rax,[rsp+180h]
    mov     rbx,[rsp+160h]
    mov     r12,[rsp+150h]
    mov     r13,[rsp+140h]
    mov     r14,[rsp+130h]
    mov     r15,[rsp+120h]
    mov     rbp,[rsp+110h]
    add     rsp,278h
    ret
L74:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L75:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L77
    jmp     L77
L76:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L77:
    call    image.sym10
    ud2
L78:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L79:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L81
    jmp     L81
L80:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L81:
    call    image.sym10
    ud2
L82:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L83:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L85
    jmp     L85
L84:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L85:
    call    image.sym10
    ud2
L86:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L87:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L89
    jmp     L89
L88:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L89:
    call    image.sym10
    ud2
L90:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L91:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L93
    jmp     L93
L92:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L93:
    call    image.sym10
    ud2
L94:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L95:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L97
    jmp     L97
L96:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    call    image.sym10
    ud2
L98:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L99:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L100:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L102
    jmp     L102
L101:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    call    image.sym10
    ud2
L103:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L104:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L106
    jmp     L106
L105:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L106:
    call    image.sym10
    ud2
L107:
    lea     rdi,[rsp+270h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L108]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L108:
    .long   L109
    .long   L110
    .long   L111
    .long   L112
    .long   L113
    .long   L114
L109:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2D0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-240h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L110:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-210h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-220h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    lea     rsp,[rsp+70h]
    jmp     L1
L111:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1B8h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L38
L112:
    ret
L113:
    ret
L114:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2B0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,278h
    mov     [rsp+160h],rbx
    mov     [rsp+150h],r12
    mov     [rsp+140h],r13
    mov     [rsp+130h],r14
    mov     [rsp+120h],r15
    mov     [rsp+110h],rbp
    mov     r11,[rsp+280h]
    mov     [rsp+58h],r11
    cmp     rcx,rsi
    jb      L107
    cmp     rsi,r8
    jbe     L107
    jmp     L72
L0:
    mov     [rsp],rbx
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+270h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    mov     rcx,[rsp+100h]
    lea     rcx,[r12+rcx*8]
    mov     [rsp+80h],r14
    mov     [rsp+70h],rbx
    mov     rbx,rcx
    mov     [rsp+68h],r12
    mov     [rsp+60h],r15
    mov     [rsp+38h],rbp
    mov     r11,[rsp+20h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+50h],r11
L1:
    mov     rcx,[rsp+178h]
    cmp     rcx,rbx
    jae     L37
    mov     rcx,[rsp+178h]
    mov     r11,[rsp+80h]
    mov     r11,[r11]
    mov     ecx,[rcx]
    mov     eax,[r13]
    cmp     ecx,eax
    setb    bpl
    mov     [rsp+106h],bpl
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    test    bpl,bpl
    je      L2
    mov     rax,[rsp+170h]
    jmp     L3
L2:
    mov     rax,[rsp+188h]
L3:
    mov     rcx,[rsp+180h]
    lea     r15,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+78h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L74
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L8
    jmp     L76
L4:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L75
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L9
    jmp     L76
L5:
    cmp     r12,r15
    jae     L6
    mov     rax,r15
    sub     rax,r12
    jmp     L7
L6:
    mov     rax,r12
    sub     rax,r15
L7:
    cmp     rax,8
    jb      L76
    mov     rdi,r15
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,bpl
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     r11,[r11]
    mov     eax,[rax+8]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    r14b
    mov     [rsp+106h],r14b
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    test    r14b,r14b
    jne     L10
    jmp     L11
L8:
    cmp     r12,0
    je      L76
    jmp     L4
L9:
    cmp     r15,0
    je      L76
    jmp     L5
L10:
    mov     rax,[rsp+170h]
    jmp     L12
L11:
    mov     rax,[rsp+188h]
L12:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r15,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L78
    mov     rax,r15
    and     rax,3
    cmp     rax,0
    je      L17
    jmp     L80
L13:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L79
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L18
    jmp     L80
L14:
    cmp     r15,r12
    jae     L15
    mov     rax,r12
    sub     rax,r15
    jmp     L16
L15:
    mov     rax,r15
    sub     rax,r12
L16:
    cmp     rax,8
    jb      L80
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r14b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     r11,[r11]
    mov     eax,[rax+8]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    bpl
    mov     [rsp+106h],bpl
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    test    bpl,bpl
    jne     L19
    jmp     L20
L17:
    cmp     r15,0
    je      L80
    jmp     L13
L18:
    cmp     r12,0
    je      L80
    jmp     L14
L19:
    mov     rax,[rsp+170h]
    jmp     L21
L20:
    mov     rax,[rsp+188h]
L21:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r14,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+90h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L82
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L26
    jmp     L84
L22:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L83
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L27
    jmp     L84
L23:
    cmp     r14,r12
    jae     L24
    mov     rax,r12
    sub     rax,r14
    jmp     L25
L24:
    mov     rax,r14
    sub     rax,r12
L25:
    cmp     rax,8
    jb      L84
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,bpl
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    mov     rcx,rax
    lea     rcx,[rcx+8]
    mov     [rsp+178h],rcx
    mov     r11,[rsp+80h]
    mov     r11,[r11]
    mov     eax,[rax+8]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+106h],r15b
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    test    r15b,r15b
    jne     L28
    jmp     L29
L26:
    cmp     r14,0
    je      L84
    jmp     L22
L27:
    cmp     r12,0
    je      L84
    jmp     L23
L28:
    mov     rax,[rsp+170h]
    jmp     L30
L29:
    mov     rax,[rsp+188h]
L30:
    mov     rcx,[rsp+180h]
    lea     r12,[rax+rcx*8]
    mov     r14,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+98h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L86
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L35
    jmp     L88
L31:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L87
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L36
    jmp     L88
L32:
    cmp     r14,r12
    jae     L33
    mov     rax,r12
    sub     rax,r14
    jmp     L34
L33:
    mov     rax,r14
    sub     rax,r12
L34:
    cmp     rax,8
    jb      L88
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r15b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    jmp     L1
L35:
    cmp     r14,0
    je      L88
    jmp     L31
L36:
    cmp     r12,0
    je      L88
    jmp     L32
L37:
    mov     r10,[rsp+70h]
    mov     [rsp+100h],r10
    mov     r11,[rsp+68h]
    mov     r10,[rsp+70h]
    lea     rax,[r11+r10*8]
    mov     rbx,rax
    mov     r11,[rsp+80h]
    mov     [rsp+0D0h],r11
    mov     r14,[rsp+70h]
    mov     r11,[rsp+60h]
    mov     [rsp+0A0h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+40h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+0B8h],r11
L38:
    mov     rax,[rsp+178h]
    cmp     rax,rbx
    jae     L47
    mov     rax,[rsp+178h]
    mov     r11,[rsp+0D0h]
    mov     r11,[r11]
    mov     eax,[rax]
    mov     ecx,[r13]
    cmp     eax,ecx
    setb    r15b
    mov     [rsp+106h],r15b
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    test    r15b,r15b
    je      L39
    mov     rax,[rsp+170h]
    jmp     L40
L39:
    mov     rax,[rsp+188h]
L40:
    mov     rcx,[rsp+180h]
    lea     rbp,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+0D8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L90
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L45
    jmp     L92
L41:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L91
    mov     rax,rbp
    and     rax,3
    cmp     rax,0
    je      L46
    jmp     L92
L42:
    cmp     r12,rbp
    jae     L43
    mov     rax,rbp
    sub     rax,r12
    jmp     L44
L43:
    mov     rax,r12
    sub     rax,rbp
L44:
    cmp     rax,8
    jb      L92
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,r15b
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    jmp     L38
L45:
    cmp     r12,0
    je      L92
    jmp     L41
L46:
    cmp     rbp,0
    je      L92
    jmp     L42
L47:
    cmp     r14,[rsp+0A0h]
    je      L56
    lea     rax,[rsp+170h]
    mov     [rsp+100h],rax
    mov     rax,[rsp+188h]
    lea     rax,[rax-8]
    mov     [rsp+188h],rax
    cmp     byte ptr [rsp+0C8h],0
    je      L48
    mov     rax,[rsp+170h]
    jmp     L49
L48:
    mov     rax,[rsp+188h]
L49:
    mov     rcx,[rsp+180h]
    lea     rbx,[rax+rcx*8]
    mov     r12,[rsp+178h]
    lea     r11,[image.k6632]
    mov     [rsp+0E8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L94
    mov     rax,r12
    and     rax,3
    cmp     rax,0
    je      L54
    jmp     L96
L50:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L95
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L55
    jmp     L96
L51:
    cmp     r12,rbx
    jae     L52
    mov     rax,rbx
    sub     rax,r12
    jmp     L53
L52:
    mov     rax,r12
    sub     rax,rbx
L53:
    cmp     rax,8
    jb      L96
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    call    ryo_hr_Memcpy
    movzx   eax,byte ptr [rsp+0C8h]
    mov     rcx,[rsp+180h]
    add     rcx,rax
    mov     [rsp+180h],rcx
    mov     rax,[rsp+178h]
    lea     rax,[rax+8]
    mov     [rsp+178h],rax
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+0C0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0A0h]
    mov     rbp,[rsp+0C8h]
    mov     r11,[rsp+0A8h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+0B0h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+0B8h]
    mov     [rsp+30h],r11
    jmp     L0
L54:
    cmp     r12,0
    je      L96
    jmp     L50
L55:
    cmp     rbx,0
    je      L96
    jmp     L51
L56:
    mov     r10,[rsp+0B0h]
    mov     [rsp+100h],r10
    mov     rbx,[rsp+180h]
    lea     r11,[k15]
    mov     [rsp+0E0h],r11
    cmp     rbx,0
    jne     L57
    mov     r13d,1
    jmp     L58
L57:
    mov     r13d,0
L58:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L98
    mov     rax,[rsp+0B0h]
    and     rax,3
    cmp     rax,0
    je      L63
    jmp     L101
L59:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L99
    mov     rax,[rsp+0A8h]
    and     rax,3
    cmp     rax,0
    je      L64
    jmp     L101
L60:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,8
    mul     rbx
    mov     rdx,r10
    jb      L100
    mov     r11,[rsp+0B0h]
    cmp     r11,[rsp+0A8h]
    jae     L61
    mov     rcx,[rsp+0A8h]
    sub     rcx,[rsp+0B0h]
    jmp     L62
L61:
    mov     rcx,[rsp+0B0h]
    sub     rcx,[rsp+0A8h]
L62:
    cmp     rax,rcx
    ja      L101
    mov     rax,rbx
    imul    rax,8
    mov     r11,[rsp+0A8h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rax
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFDA0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+180h]
    mov     r11,[rsp+0A0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+100h],rax
    mov     rbx,rax
    mov     eax,0
    mov     r13,[rsp+0A0h]
    mov     r15,[rsp+0B8h]
    mov     rbp,[rsp+0A8h]
    jmp     L65
L63:
    test    r13b,r13b
    jne     L59
    mov     r11,[rsp+0B0h]
    cmp     r11,0
    je      L101
    jmp     L59
L64:
    test    r13b,r13b
    jne     L60
    mov     r11,[rsp+0A8h]
    cmp     r11,0
    je      L101
    jmp     L60
L65:
    cmp     rax,rbx
    jae     L73
    mov     r12,rax
    add     r12,1
    mov     [rsp+100h],rax
    mov     rcx,r13
    sub     rcx,1
    sub     rcx,rax
    lea     r14,[r15+rcx*8]
    mov     rcx,[rsp+180h]
    add     rcx,rax
    lea     r11,[rbp+rcx*8]
    mov     [rsp+0F0h],r11
    lea     r11,[k19]
    mov     [rsp+0F8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L103
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L70
    jmp     L105
L66:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L104
    mov     rax,[rsp+0F0h]
    and     rax,3
    cmp     rax,0
    je      L71
    jmp     L105
L67:
    cmp     r14,[rsp+0F0h]
    jae     L68
    mov     rax,[rsp+0F0h]
    sub     rax,r14
    jmp     L69
L68:
    mov     rax,r14
    sub     rax,[rsp+0F0h]
L69:
    cmp     rax,8
    jb      L105
    mov     rdi,[rsp+0F0h]
    mov     rsi,r14
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     rax,r12
    jmp     L65
L70:
    cmp     r14,0
    je      L105
    jmp     L66
L71:
    mov     r11,[rsp+0F0h]
    cmp     r11,0
    je      L105
    jmp     L67
L72:
    lea     rax,[rdi+r8*8]
    lea     rcx,[rdx+rsi*8]
    mov     [rsp+170h],rdx
    mov     [rsp+178h],rdi
    mov     qword ptr [rsp+180h],0
    mov     [rsp+188h],rcx
    mov     rbx,r8
    mov     r12,rdi
    mov     r13,rax
    mov     r14,[rsp+58h]
    mov     r15,rsi
    mov     rbp,r9
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    jmp     L0
L73:
    mov     rax,[rsp+180h]
    mov     rbx,[rsp+160h]
    mov     r12,[rsp+150h]
    mov     r13,[rsp+140h]
    mov     r14,[rsp+130h]
    mov     r15,[rsp+120h]
    mov     rbp,[rsp+110h]
    add     rsp,278h
    ret
L74:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L75:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L77
    jmp     L77
L76:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L77:
    call    image.sym10
    ud2
L78:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L79:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L81
    jmp     L81
L80:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L81:
    call    image.sym10
    ud2
L82:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L83:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L85
    jmp     L85
L84:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L85:
    call    image.sym10
    ud2
L86:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L87:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L89
    jmp     L89
L88:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L89:
    call    image.sym10
    ud2
L90:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L91:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L93
    jmp     L93
L92:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L93:
    call    image.sym10
    ud2
L94:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L95:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L97
    jmp     L97
L96:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L97:
    call    image.sym10
    ud2
L98:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L99:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L100:
    lea     rax,[image.k9346]
    mov     rdi,rax
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L102
    jmp     L102
L101:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L102:
    call    image.sym10
    ud2
L103:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L104:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L106
    jmp     L106
L105:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L106:
    call    image.sym10
    ud2
L107:
    lea     rdi,[rsp+270h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L108]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L108:
    .long   L109
    .long   L110
    .long   L111
    .long   L112
    .long   L113
    .long   L114
L109:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2D0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-240h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+60h]
    jmp     L0
L110:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-208h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-210h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-220h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    lea     rsp,[rsp+70h]
    jmp     L1
L111:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1B8h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L38
L112:
    ret
L113:
    ret
L114:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2B0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     rax,[rsp]
    mov     rbx,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L65

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rsi
    mov     r11,[rdi]
    mov     rax,[rbx+10h]
    mov     rcx,[rdi+8]
    mov     eax,[rax]
    mov     ecx,[rcx]
    cmp     eax,ecx
    setb    r12b
    mov     rax,[rdi+10h]
    mov     rax,[rax]
    mov     rcx,[rbx+18h]
    lea     r13,[rax+rcx*4]
    mov     r14,[rbx]
    lea     r15,[k1]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L7
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    je      L1
    jmp     L9
L0:
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L2
L1:
    cmp     r13,0
    je      L9
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L8
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    jne     L9
    cmp     r14,0
    je      L9
    jmp     L0
L2:
    mov     r14,[rbx+10h]
    lea     rbp,[k3]
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L11
    mov     rax,r14
    and     rax,3
    cmp     rax,0
    je      L6
    jmp     L13
L3:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L12
    mov     rax,r13
    and     rax,3
    cmp     rax,0
    jne     L13
    cmp     r14,r13
    jae     L4
    mov     rax,r13
    sub     rax,r14
    jmp     L5
L4:
    mov     rax,r14
    sub     rax,r13
L5:
    cmp     rax,4
    jb      L13
    mov     rdi,r13
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rax,[rbx+10h]
    mov     [rbx],rax
    movzx   ecx,r12b
    mov     rdx,[rbx+18h]
    add     rdx,rcx
    mov     [rbx+18h],rdx
    lea     rax,[rax+4]
    mov     [rbx+10h],rax
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L6:
    cmp     r14,0
    je      L13
    jmp     L3
L7:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L8:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L10
L9:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L10:
    call    image.sym10
    ud2
L11:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L12:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L14
    jmp     L14
L13:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,rbp
    movzx   edx,dl
    call    image.sym49
    ud2
L14:
    call    image.sym10
    ud2
  ; OSR entries
    lea     r11,[L15]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L15:
    .long   L16
L16:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,388h
    mov     [rsp+2B0h],rbx
    mov     [rsp+2A0h],r12
    mov     [rsp+290h],r13
    mov     [rsp+280h],r14
    mov     [rsp+270h],r15
    mov     [rsp+260h],rbp
    mov     [rsp+28h],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+18h],r8
    mov     [rsp+20h],rdx
L0:
    mov     r11d,20h
    cmp     r11,[rsp+10h]
    jb      L60
    mov     r11,[rsp+10h]
    cmp     r11,2
    jb      L130
    mov     rdi,[rsp+10h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+38h],rax
    mov     r11,[rsp+10h]
    cmp     r11,12h
    setb    [rsp+30h]
    cmp     byte ptr [rsp+30h],0
    je      L1
    mov     r12,[rsp+10h]
    jmp     L2
L1:
    mov     r12,[rsp+38h]
L2:
    lea     rax,[image.k2160]
    mov     rdi,[rsp+28h]
    mov     esi,4
    mov     edx,4
    mov     rcx,r12
    mov     r8,rax
    call    image.fn187
    mov     r11,[rsp+28h]
    mov     [rsp+50h],r11
    mov     [rsp+58h],r12
L3:
    mov     r11,[rsp+58h]
    cmp     r11,0Dh
    jb      L43
    mov     rdi,[rsp+50h]
    mov     esi,0
    mov     edx,0Ch
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,1
    mov     edx,0Ah
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,2
    mov     edx,9
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,3
    mov     edx,7
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,5
    mov     edx,0Bh
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,1
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,4
    mov     edx,0Bh
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,7
    mov     edx,9
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,8
    mov     edx,0Ah
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,3
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0Bh
    mov     edx,0Ch
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,4
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,5
    mov     edx,9
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,8
    mov     edx,0Bh
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0Ah
    mov     edx,0Ch
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0
    mov     edx,5
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,3
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,4
    mov     edx,7
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,6
    mov     edx,0Bh
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0
    mov     edx,1
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,2
    mov     edx,5
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,6
    mov     edx,9
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,7
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,0Ah
    mov     edx,0Bh
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,1
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,2
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,5
    mov     edx,6
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,9
    mov     edx,0Ah
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,1
    mov     edx,2
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,3
    mov     edx,4
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,5
    mov     edx,7
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,6
    mov     edx,8
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,2
    mov     edx,3
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     rdi,[rsp+50h]
    mov     esi,4
    mov     edx,5
    mov     rcx,[rsp+18h]
    call    image.fn72
    mov     r14,[rsp+50h]
    lea     r14,[r14+18h]
    mov     rbx,[rsp+50h]
    lea     rbx,[rbx+1Ch]
    mov     rdi,rbx
    mov     rsi,r14
    call    qword ptr [image.fn206.slot]
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,rbx
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     r15,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,rbx
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+110h],eax
    lea     r11,[image.k2088]
    mov     [rsp+40h],r11
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L5
    jmp     L131
L4:
    mov     rdi,r14
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbp,[rsp+110h]
    lea     r11,[image.k2112]
    mov     [rsp+48h],r11
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    jmp     L8
L5:
    cmp     r15,0
    je      L131
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L7
L6:
    cmp     r14,0
    je      L131
    jmp     L4
L7:
    test    dl,dl
    jne     L6
    jmp     L131
L8:
    test    al,al
    jne     L11
    jmp     L133
L9:
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L12
    jmp     L133
L10:
    mov     rdi,rbp
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L133
    mov     rdi,rbx
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r14,[rsp+50h]
    lea     r14,[r14+20h]
    mov     r15,[rsp+50h]
    lea     r15,[r15+24h]
    mov     rdi,r15
    mov     rsi,r14
    call    qword ptr [image.fn206.slot]
    mov     r12,rax
    mov     rdi,r12
    mov     rsi,r15
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     r13,rax
    mov     rdi,r12
    mov     rsi,r14
    mov     rdx,r15
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+120h],eax
    lea     r11,[image.k2088]
    mov     [rsp+68h],r11
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    jmp     L13
L11:
    cmp     rbp,0
    je      L133
    jmp     L9
L12:
    cmp     rbx,0
    je      L133
    jmp     L10
L13:
    test    al,al
    jne     L15
    jmp     L135
L14:
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+120h]
    lea     r11,[image.k2112]
    mov     [rsp+60h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L18
L15:
    cmp     r13,0
    je      L135
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L17
L16:
    cmp     r14,0
    je      L135
    jmp     L14
L17:
    test    dl,dl
    jne     L16
    jmp     L135
L18:
    test    al,al
    jne     L21
    jmp     L137
L19:
    mov     rdi,r15
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L22
    jmp     L137
L20:
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L137
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r13,[rsp+50h]
    lea     r13,[r13+0Ch]
    mov     r14,[rsp+50h]
    lea     r14,[r14+10h]
    mov     rdi,r14
    mov     rsi,r13
    call    qword ptr [image.fn206.slot]
    mov     rbp,rax
    mov     rdi,rbp
    mov     rsi,r14
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     r12,rax
    mov     rdi,rbp
    mov     rsi,r13
    mov     rdx,r14
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+130h],eax
    lea     r11,[image.k2088]
    mov     [rsp+78h],r11
    mov     rdi,r12
    mov     esi,4
    call    image.fn155
    jmp     L23
L21:
    cmp     rbx,0
    je      L137
    jmp     L19
L22:
    cmp     r15,0
    je      L137
    jmp     L20
L23:
    test    al,al
    jne     L25
    jmp     L139
L24:
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+130h]
    lea     r11,[image.k2112]
    mov     [rsp+70h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L28
L25:
    cmp     r12,0
    je      L139
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L27
L26:
    cmp     r13,0
    je      L139
    jmp     L24
L27:
    test    dl,dl
    jne     L26
    jmp     L139
L28:
    test    al,al
    jne     L31
    jmp     L141
L29:
    mov     rdi,r14
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L32
    jmp     L141
L30:
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L141
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     r12,[rsp+50h]
    lea     r12,[r12+14h]
    mov     r13,[rsp+50h]
    lea     r13,[r13+18h]
    mov     rdi,r13
    mov     rsi,r12
    call    qword ptr [image.fn206.slot]
    mov     r15,rax
    mov     rdi,r15
    mov     rsi,r13
    mov     rdx,r12
    movzx   edi,dil
    call    image.fn46
    mov     rbp,rax
    mov     rdi,r15
    mov     rsi,r12
    mov     rdx,r13
    movzx   edi,dil
    call    image.fn46
    mov     eax,[rax]
    mov     [rsp+140h],eax
    lea     r11,[image.k2088]
    mov     [rsp+98h],r11
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    jmp     L33
L31:
    cmp     rbx,0
    je      L141
    jmp     L29
L32:
    cmp     r14,0
    je      L141
    jmp     L30
L33:
    test    al,al
    jne     L35
    jmp     L143
L34:
    mov     rdi,r12
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+140h]
    lea     r11,[image.k2112]
    mov     [rsp+90h],r11
    mov     rdi,rbx
    mov     esi,4
    call    image.fn155
    jmp     L38
L35:
    cmp     rbp,0
    je      L143
    mov     rdi,r12
    mov     esi,4
    call    image.fn155
    mov     rdx,rax
    jmp     L37
L36:
    cmp     r12,0
    je      L143
    jmp     L34
L37:
    test    dl,dl
    jne     L36
    jmp     L143
L38:
    test    al,al
    jne     L41
    jmp     L145
L39:
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L42
    jmp     L145
L40:
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L145
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,0Dh
    jmp     L45
L41:
    cmp     rbx,0
    je      L145
    jmp     L39
L42:
    cmp     r13,0
    je      L145
    jmp     L40
L43:
    mov     r11,[rsp+58h]
    cmp     r11,9
    jb      L44
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+18h]
    call    qword ptr [image.fn73.slot]
    mov     eax,9
    jmp     L45
L44:
    mov     eax,1
L45:
    cmp     rax,0
    je      L151
    mov     r11,[rsp+58h]
    cmp     r11,rax
    jb      L151
    mov     r11,[rsp+50h]
    mov     r10,[rsp+58h]
    lea     rbx,[r11+r10*4]
    mov     r11,[rsp+50h]
    lea     rax,[r11+rax*4]
    mov     r12,rax
L46:
    cmp     r12,rbx
    je      L56
    mov     r13,r12
    lea     r13,[r13-4]
    mov     [rsp+150h],r12
    mov     [rsp+158h],r12
    mov     [rsp+160h],r13
    mov     rdi,r12
    mov     rsi,r13
    call    qword ptr [image.fn206.slot]
    mov     [rsp+14Fh],al
    movzx   eax,byte ptr [rsp+14Fh]
    test    al,al
    je      L54
    mov     [rsp+160h],r12
    mov     eax,[r12]
    mov     [rsp+164h],eax
    mov     [rsp+14Ch],eax
    lea     rax,[rsp+14Ch]
    mov     [rsp+150h],rax
    mov     [rsp+158h],r12
    mov     qword ptr [rsp+160h],1
L47:
    mov     rbp,[rsp+158h]
    lea     r11,[image.k1728]
    mov     [rsp+80h],r11
    mov     rdi,r13
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L50
    jmp     L147
L48:
    mov     rdi,rbp
    mov     esi,4
    call    image.fn155
    test    al,al
    jne     L51
    jmp     L147
L49:
    mov     rdi,r13
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,1
    call    qword ptr [image.fn185.slot]
    test    al,al
    je      L147
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     [rsp+158h],r13
    cmp     r13,[rsp+50h]
    je      L53
    jmp     L55
L50:
    cmp     r13,0
    je      L147
    jmp     L48
L51:
    cmp     rbp,0
    je      L147
    jmp     L49
L52:
    mov     r13,rbp
    jmp     L47
L53:
    lea     rax,[rsp+150h]
    mov     rdi,rax
    call    qword ptr [image.fn229.slot]
L54:
    mov     rax,r12
    lea     rax,[rax+4]
    mov     r12,rax
    jmp     L46
L55:
    mov     rbp,r13
    lea     rbp,[rbp-4]
    lea     rax,[rsp+14Ch]
    mov     rdi,rax
    mov     rsi,rbp
    call    qword ptr [image.fn206.slot]
    test    al,al
    jne     L52
    jmp     L53
L56:
    cmp     byte ptr [rsp+30h],0
    jne     L130
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+28h]
    je      L57
    lea     rbx,[rsp+168h]
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
    mov     rcx,[rsp+18h]
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
    jmp     L130
L57:
    mov     r11,[rsp+28h]
    mov     r10,[rsp+38h]
    lea     rbx,[r11+r10*4]
    mov     r12,[rsp+10h]
    sub     r12,[rsp+38h]
    lea     r11,[image.k2184]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    jne     L152
    mov     rax,rbx
    and     rax,3
    cmp     rax,0
    je      L59
    jmp     L153
L58:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    cmp     r12,rax
    ja      L153
    mov     [rsp+50h],rbx
    mov     [rsp+58h],r12
    jmp     L3
L59:
    cmp     rbx,0
    je      L153
    jmp     L58
L60:
    cmp     ecx,0
    jne     L61
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn2.slot]
    jmp     L130
L61:
    mov     r11,rcx
    sub     r11d,1
    mov     [rsp+0A0h],r11
    mov     rdi,[rsp+10h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    mov     r11,[rsp+28h]
    lea     r12,[r11+rcx*4]
    mov     rcx,rax
    imul    rcx,7
    mov     r11,[rsp+28h]
    lea     rbp,[r11+rcx*4]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L65
    mov     r11,[rsp+28h]
    mov     ecx,[r11]
    mov     edx,[r12]
    cmp     ecx,edx
    setb    cl
    mov     r11,[rsp+28h]
    mov     edx,[r11]
    mov     esi,[rbp]
    cmp     edx,esi
    setb    dl
    cmp     cl,dl
    jne     L63
    mov     edx,[r12]
    mov     esi,[rbp]
    cmp     edx,esi
    setb    dl
    xor     edx,ecx
    test    dl,dl
    je      L62
    mov     rcx,rbp
    jmp     L64
L62:
    mov     rcx,r12
    jmp     L64
L63:
    mov     rcx,[rsp+28h]
L64:
    lea     rdx,[image.k1536]
    cmp     rcx,[rsp+28h]
    jb      L155
    sub     rcx,[rsp+28h]
    mov     rdi,rcx
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L72
L65:
    mov     rcx,rax
    imul    rcx,8
    cmp     rcx,40h
    jb      L66
    jmp     L67
L66:
    mov     rbx,[rsp+28h]
    jmp     L68
L67:
    mov     rdi,rax
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r13,rax
    mov     r14,r13
    imul    r14,4
    mov     r11,[rsp+28h]
    lea     rax,[r11+r14*4]
    mov     r15,r13
    imul    r15,7
    mov     r11,[rsp+28h]
    lea     rcx,[r11+r15*4]
    mov     rdi,[rsp+28h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     rbx,rax
    lea     rax,[r12+r14*4]
    lea     rcx,[r12+r15*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     r12,rax
    lea     rax,[rbp+r14*4]
    lea     rcx,[rbp+r15*4]
    mov     rdi,rbp
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r13
    mov     r8,[rsp+18h]
    call    image.fn59
    mov     rbp,rax
L68:
    mov     eax,[rbx]
    mov     ecx,[r12]
    cmp     eax,ecx
    setb    al
    mov     ecx,[rbx]
    mov     esi,[rbp]
    cmp     ecx,esi
    setb    cl
    cmp     al,cl
    jne     L70
    mov     ecx,[r12]
    mov     esi,[rbp]
    cmp     ecx,esi
    setb    cl
    xor     ecx,eax
    test    cl,cl
    je      L69
    jmp     L71
L69:
    mov     rbp,r12
    jmp     L71
L70:
    mov     rbp,rbx
L71:
    lea     rax,[image.k1584]
    cmp     rbp,[rsp+28h]
    jb      L156
    sub     rbp,[rsp+28h]
    mov     rdi,rbp
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
L72:
    cmp     rcx,[rsp+10h]
    setb    sil
    lea     rdi,[image.k1632]
    test    sil,sil
    je      L157
    mov     r11,[rsp+20h]
    cmp     r11,0
    je      L101
    mov     r11,[rsp+28h]
    lea     rsi,[r11+rcx*4]
    mov     r11,[rsp+20h]
    mov     r8d,[r11]
    mov     esi,[rsi]
    cmp     r8d,esi
    jb      L101
    mov     r10,[rsp+18h]
    mov     [rsp+2E0h],r10
    lea     rbx,[rsp+2E0h]
    mov     r11,[rsp+28h]
    lea     r12,[r11+rcx*4]
    lea     r13,[rsp+1ECh]
    lea     r14,[image.k488]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L158
    mov     rsi,[rsp+28h]
    and     rsi,3
    cmp     rsi,0
    je      L77
    jmp     L160
L73:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L159
    mov     rsi,r13
    and     rsi,3
    cmp     rsi,0
    je      L78
    jmp     L160
L74:
    mov     r11,[rsp+28h]
    cmp     r11,r13
    jae     L75
    mov     rsi,r13
    sub     rsi,[rsp+28h]
    jmp     L76
L75:
    mov     rsi,[rsp+28h]
    sub     rsi,r13
L76:
    cmp     rsi,4
    jb      L160
    mov     rdi,r13
    mov     rsi,[rsp+28h]
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r15,[image.k512]
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    je      L79
    jmp     L162
L77:
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L160
    jmp     L73
L78:
    cmp     r13,0
    je      L160
    jmp     L74
L79:
    mov     rsi,r12
    and     rsi,3
    cmp     rsi,0
    je      L81
    jmp     L164
L80:
    mov     rdi,[rsp+28h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+1ECh]
    lea     r11,[image.k536]
    mov     [rsp+100h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    je      L82
    jmp     L166
L81:
    cmp     r12,0
    je      L164
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L163
    mov     rsi,[rsp+28h]
    and     rsi,3
    cmp     rsi,0
    je      L80
    jmp     L164
L82:
    mov     rsi,r13
    and     rsi,3
    cmp     rsi,0
    je      L86
    jmp     L168
L83:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L167
    mov     rsi,r12
    and     rsi,3
    cmp     rsi,0
    jne     L168
    cmp     r13,r12
    jae     L84
    mov     rsi,r12
    sub     rsi,r13
    jmp     L85
L84:
    mov     rsi,r13
    sub     rsi,r12
L85:
    cmp     rsi,4
    jb      L168
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     rsi,[image.k4432]
    lea     r8,[rsp+200h]
    mov     rdi,r8
    mov     rdx,[rsp+10h]
    mov     ecx,1
    mov     r8,rsi
    mov     rsi,[rsp+28h]
    call    fn10
    mov     rsi,[rsp+200h]
    mov     r11,[rsp+208h]
    mov     [rsp+0A8h],r11
    mov     r9,[rsp+210h]
    mov     r8,[rsp+218h]
    mov     r11,[rsp+0A8h]
    cmp     r11,0
    ja      L87
    jmp     L182
L86:
    cmp     r13,0
    je      L168
    jmp     L83
L87:
    mov     [rsp+218h],rsi
    mov     [rsp+210h],rsi
    mov     r12,[image.sym36]
    mov     rdi,r9
    mov     rdx,rsi
    mov     rsi,r8
    mov     rcx,rbx
    mov     rax,r12
    call    rax
    mov     rbx,rax
    cmp     rbx,[rsp+10h]
    jae     L183
    mov     r11,[rsp+28h]
    lea     r12,[r11+rbx*4]
    lea     r13,[rsp+1FCh]
    lea     r11,[image.k488]
    mov     [rsp+0B0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L170
    mov     rsi,[rsp+28h]
    and     rsi,3
    cmp     rsi,0
    jne     L172
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L171
    mov     rsi,r13
    and     rsi,3
    cmp     rsi,0
    je      L91
    jmp     L172
L88:
    mov     r11,[rsp+28h]
    cmp     r11,r13
    jae     L89
    mov     rsi,r13
    sub     rsi,[rsp+28h]
    jmp     L90
L89:
    mov     rsi,[rsp+28h]
    sub     rsi,r13
L90:
    cmp     rsi,4
    jb      L172
    mov     rdi,r13
    mov     rsi,[rsp+28h]
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r11,[image.k512]
    mov     [rsp+0B8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    je      L92
    jmp     L174
L91:
    cmp     r13,0
    je      L172
    jmp     L88
L92:
    mov     rsi,r12
    and     rsi,3
    cmp     rsi,0
    je      L94
    jmp     L176
L93:
    mov     rdi,[rsp+28h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+1FCh]
    lea     r11,[image.k536]
    mov     [rsp+0C0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    je      L95
    jmp     L178
L94:
    cmp     r12,0
    je      L176
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L175
    mov     rsi,[rsp+28h]
    and     rsi,3
    cmp     rsi,0
    je      L93
    jmp     L176
L95:
    mov     rsi,r13
    and     rsi,3
    cmp     rsi,0
    je      L99
    jmp     L180
L96:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rsi,rax
    cmp     esi,1
    jne     L179
    mov     rsi,r12
    and     rsi,3
    cmp     rsi,0
    jne     L180
    cmp     r13,r12
    jae     L97
    mov     rsi,r12
    sub     rsi,r13
    jmp     L98
L97:
    mov     rsi,r13
    sub     rsi,r12
L98:
    cmp     rsi,4
    jb      L180
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    jmp     L100
L99:
    cmp     r13,0
    je      L180
    jmp     L96
L100:
    mov     r11,rbx
    add     r11,1
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+10h]
    cmp     r11,[rsp+0C8h]
    jb      L211
    mov     rsi,[rsp+10h]
    sub     rsi,[rsp+0C8h]
    mov     r10,[rsp+28h]
    mov     [rsp+2D0h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+2D8h],r10
    mov     r10,[rsp+28h]
    mov     [rsp+2C8h],r10
    mov     r11,[rsp+28h]
    mov     r10,[rsp+0C8h]
    lea     r8,[r11+r10*4]
    mov     [rsp+2C0h],r8
    mov     [rsp+2E0h],r8
    mov     [rsp+28h],r8
    mov     [rsp+10h],rsi
    mov     rcx,[rsp+0A0h]
    mov     qword ptr [rsp+20h],0
    jmp     L0
L101:
    mov     r11,[rsp+28h]
    lea     r12,[r11+rcx*4]
    lea     r13,[rsp+22Ch]
    lea     r11,[image.k488]
    mov     [rsp+0E0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L184
    mov     rcx,[rsp+28h]
    and     rcx,3
    cmp     rcx,0
    je      L106
    jmp     L186
L102:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L185
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L107
    jmp     L186
L103:
    mov     r11,[rsp+28h]
    cmp     r11,r13
    jae     L104
    mov     rcx,r13
    sub     rcx,[rsp+28h]
    jmp     L105
L104:
    mov     rcx,[rsp+28h]
    sub     rcx,r13
L105:
    cmp     rcx,4
    jb      L186
    mov     rdi,r13
    mov     rsi,[rsp+28h]
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r11,[image.k512]
    mov     [rsp+0D0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    je      L108
    jmp     L188
L106:
    mov     r11,[rsp+28h]
    cmp     r11,0
    je      L186
    jmp     L102
L107:
    cmp     r13,0
    je      L186
    jmp     L103
L108:
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    je      L110
    jmp     L190
L109:
    mov     rdi,[rsp+28h]
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r13,[rsp+22Ch]
    lea     r11,[image.k536]
    mov     [rsp+0D8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    je      L111
    jmp     L192
L110:
    cmp     r12,0
    je      L190
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L189
    mov     rcx,[rsp+28h]
    and     rcx,3
    cmp     rcx,0
    je      L109
    jmp     L190
L111:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L115
    jmp     L194
L112:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L193
    mov     rcx,r12
    and     rcx,3
    cmp     rcx,0
    jne     L194
    cmp     r13,r12
    jae     L113
    mov     rcx,r12
    sub     rcx,r13
    jmp     L114
L113:
    mov     rcx,r13
    sub     rcx,r12
L114:
    cmp     rcx,4
    jb      L194
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     rcx,[image.k4528]
    lea     rsi,[rsp+240h]
    mov     rdi,rsi
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     r8,rcx
    mov     ecx,1
    call    fn10
    mov     rcx,[rsp+240h]
    mov     rsi,[rsp+248h]
    mov     r8,[rsp+250h]
    mov     r9,[rsp+258h]
    cmp     rsi,0
    ja      L116
    jmp     L208
L115:
    cmp     r13,0
    je      L194
    jmp     L112
L116:
    mov     [rsp+258h],rcx
    mov     [rsp+250h],rcx
    mov     r12,[image.sym37]
    mov     rdi,r8
    mov     rsi,r9
    mov     rdx,rcx
    mov     rcx,[rsp+18h]
    mov     rax,r12
    call    rax
    mov     r12,rax
    cmp     r12,[rsp+10h]
    jae     L209
    mov     r11,[rsp+28h]
    lea     r13,[r11+r12*4]
    lea     rbx,[rsp+23Ch]
    lea     r11,[image.k488]
    mov     [rsp+0E8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L196
    mov     rcx,[rsp+28h]
    and     rcx,3
    cmp     rcx,0
    jne     L198
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L197
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    je      L120
    jmp     L198
L117:
    mov     r11,[rsp+28h]
    cmp     r11,rbx
    jae     L118
    mov     rcx,rbx
    sub     rcx,[rsp+28h]
    jmp     L119
L118:
    mov     rcx,[rsp+28h]
    sub     rcx,rbx
L119:
    cmp     rcx,4
    jb      L198
    mov     rdi,rbx
    mov     rsi,[rsp+28h]
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r11,[image.k512]
    mov     [rsp+0F0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    je      L121
    jmp     L200
L120:
    cmp     rbx,0
    je      L198
    jmp     L117
L121:
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    je      L123
    jmp     L202
L122:
    mov     rdi,[rsp+28h]
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memmove
    lea     rbx,[rsp+23Ch]
    lea     r11,[image.k536]
    mov     [rsp+0F8h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    je      L124
    jmp     L204
L123:
    cmp     r13,0
    je      L202
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L201
    mov     rcx,[rsp+28h]
    and     rcx,3
    cmp     rcx,0
    je      L122
    jmp     L202
L124:
    mov     rcx,rbx
    and     rcx,3
    cmp     rcx,0
    je      L128
    jmp     L206
L125:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rcx,rax
    cmp     ecx,1
    jne     L205
    mov     rcx,r13
    and     rcx,3
    cmp     rcx,0
    jne     L206
    cmp     rbx,r13
    jae     L126
    mov     rcx,r13
    sub     rcx,rbx
    jmp     L127
L126:
    mov     rcx,rbx
    sub     rcx,r13
L127:
    cmp     rcx,4
    jb      L206
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    jmp     L129
L128:
    cmp     rbx,0
    je      L206
    jmp     L125
L129:
    lea     rcx,[k9]
    lea     r8,[rsp+2C8h]
    mov     rdi,r8
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     r8,rcx
    mov     rcx,r12
    call    fn10
    mov     rbx,[rsp+2C8h]
    mov     r12,[rsp+2D0h]
    mov     rcx,[rsp+2D8h]
    mov     r8,[rsp+2E0h]
    lea     r9,[k11]
    lea     r13,[rsp+2B8h]
    mov     rdi,r13
    mov     rsi,rcx
    mov     rdx,r8
    mov     ecx,1
    mov     r8,r9
    call    fn10
    mov     rcx,[rsp+2B8h]
    mov     r8,[rsp+2C0h]
    mov     [rsp+2D8h],rcx
    mov     [rsp+2E0h],r8
    mov     r13,[rsp+2C8h]
    mov     rbp,[rsp+2D0h]
    cmp     r8,0
    jbe     L210
    mov     rcx,[rsp+2D8h]
    mov     [rsp+2D0h],rcx
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+18h]
    mov     ecx,ecx
    call    fn15
    mov     rcx,[rsp+2D0h]
    mov     [rsp+28h],r13
    mov     [rsp+10h],rbp
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+0A0h]
    jmp     L0
L130:
    mov     rbx,[rsp+2B0h]
    mov     r12,[rsp+2A0h]
    mov     r13,[rsp+290h]
    mov     r14,[rsp+280h]
    mov     r15,[rsp+270h]
    mov     rbp,[rsp+260h]
    add     rsp,388h
    ret
    jmp     L132
L131:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L132:
    call    image.sym10
    ud2
    jmp     L134
    jmp     L134
    jmp     L134
L133:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L134:
    call    image.sym10
    ud2
    jmp     L136
L135:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+68h]
    movzx   edx,dl
    call    image.sym49
    ud2
L136:
    call    image.sym10
    ud2
    jmp     L138
    jmp     L138
    jmp     L138
L137:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+60h]
    movzx   edx,dl
    call    image.sym49
    ud2
L138:
    call    image.sym10
    ud2
    jmp     L140
L139:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+78h]
    movzx   edx,dl
    call    image.sym49
    ud2
L140:
    call    image.sym10
    ud2
    jmp     L142
    jmp     L142
    jmp     L142
L141:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+70h]
    movzx   edx,dl
    call    image.sym49
    ud2
L142:
    call    image.sym10
    ud2
    jmp     L144
L143:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+98h]
    movzx   edx,dl
    call    image.sym49
    ud2
L144:
    call    image.sym10
    ud2
    jmp     L146
    jmp     L146
    jmp     L146
L145:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+90h]
    movzx   edx,dl
    call    image.sym49
    ud2
L146:
    call    image.sym10
    ud2
    jmp     L148
    jmp     L148
    jmp     L148
L147:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L148:
    call    image.sym10
    ud2
L149:
    lea     rcx,[rsp+150h]
    mov     rdi,rcx
    call    qword ptr [image.fn229.slot]
    mov     [rsp],rbx
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    call    ryo_h_Resume
    ud2
    jmp     L150
    mov     rbx,rax
    jmp     L149
L150:
    call    image.sym11
    ud2
L151:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L152:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
    jmp     L154
L153:
    lea     rcx,[image.k9686]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L154:
    call    image.sym10
    ud2
L155:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     rcx,rdx
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L156:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L157:
    lea     rax,[image.k9125]
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,rdi
    mov     rdi,rax
    movzx   edx,dl
    call    image.sym49
    ud2
L158:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L159:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L161
    jmp     L161
L160:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    image.sym49
    ud2
L161:
    call    image.sym10
    ud2
L162:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L163:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L165
L164:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    image.sym49
    ud2
L165:
    call    image.sym10
    ud2
L166:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L167:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L169
    jmp     L169
L168:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+100h]
    movzx   edx,dl
    call    image.sym49
    ud2
L169:
    call    image.sym10
    ud2
L170:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L171:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L173
    jmp     L173
L172:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L173:
    call    image.sym10
    ud2
L174:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L175:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L177
L176:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L177:
    call    image.sym10
    ud2
L178:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L179:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L181
    jmp     L181
L180:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L181:
    call    image.sym10
    ud2
L182:
    lea     rax,[image.k4456]
    mov     edi,0
    mov     rsi,[rsp+0A8h]
    mov     rdx,rax
    call    sym5
    ud2
L183:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L184:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L185:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L187
    jmp     L187
L186:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L187:
    call    image.sym10
    ud2
L188:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L189:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L191
L190:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0D0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L191:
    call    image.sym10
    ud2
L192:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L193:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L195
    jmp     L195
L194:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0D8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L195:
    call    image.sym10
    ud2
L196:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L197:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L199
    jmp     L199
L198:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0E8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L199:
    call    image.sym10
    ud2
L200:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L201:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L203
L202:
    lea     rax,[image.k8904]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+0F0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L203:
    call    image.sym10
    ud2
L204:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
L205:
    lea     rax,[image.k6432]
    lea     rcx,[image.k6560]
    mov     rdi,rax
    mov     esi,55h
    mov     rdx,rcx
    call    image.sym6
    ud2
    jmp     L207
    jmp     L207
L206:
    lea     rax,[image.k8338]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0F8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L207:
    call    image.sym10
    ud2
L208:
    lea     rax,[image.k4552]
    mov     edi,0
    mov     rdx,rax
    call    sym5
    ud2
L209:
    lea     rdi,[rsp+380h]
    call    ryo_h_Abort
    ud2
L210:
    lea     rax,[k13]
    mov     edi,0
    mov     rsi,r8
    mov     rdx,rax
    call    sym5
    ud2
L211:
    lea     rax,[k16]
    mov     rdi,[rsp+0C8h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+10h]
    mov     rcx,rax
    call    sym17
    ud2
  ; OSR entries
    lea     r11,[L212]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L212:
    .long   L213
L213:
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
    mov     [rdx-0E0h],r12
    mov     [rdx-0F0h],r13
    mov     [rdx-100h],r14
    mov     [rdx-110h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp]
    mov     [rdx-358h],r11
    mov     r11,[rsp+8]
    mov     [rdx-370h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-368h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-360h],r11
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
    mov     [rsp+30h],rsi
    mov     r13,rdx
    mov     r11,[rsp+30h]
    cmp     r11,10h
    ja      L24
    mov     qword ptr [rsp+160h],1
    mov     r10,[rsp+30h]
    mov     [rsp+168h],r10
    mov     r14,rbx
    mov     r15,[rsp+30h]
L0:
    mov     rax,[rsp+160h]
    mov     rcx,[rsp+168h]
    cmp     rax,rcx
    jae     L1
    mov     rax,[rsp+160h]
    lea     rcx,[image.k10584]
    mov     r11,rax
    add     r11,1
    jb      L59
    mov     rdx,rax
    add     rdx,1
    mov     [rsp+160h],rdx
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
    .long   L58
    .long   L4
    .long   L102
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
    mov     [rsp+70h],r11
    mov     r11,[rsp+70h]
    cmp     r11,[rsp+20h]
    jae     L103
    mov     r10,[rsp+70h]
    lea     rdx,[r14+r10*4]
    mov     edx,[rdx]
    mov     r11,[rsp+28h]
    cmp     r11,[rsp+20h]
    jae     L104
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
    lea     rsi,[k10]
    cmp     rdx,[rsp+20h]
    jae     L72
    lea     r15,[r14+rdx*4]
    mov     r10,[rsp+28h]
    lea     rbp,[r14+r10*4]
    lea     r12,[rsp+0DCh]
    lea     r11,[image.k488]
    mov     [rsp+38h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    jne     L60
    mov     rdi,r15
    and     rdi,3
    cmp     rdi,0
    je      L14
    jmp     L62
L10:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    jne     L61
    mov     rdi,r12
    and     rdi,3
    cmp     rdi,0
    je      L15
    jmp     L62
L11:
    cmp     r15,r12
    jae     L12
    mov     rdi,r12
    sub     rdi,r15
    jmp     L13
L12:
    mov     rdi,r15
    sub     rdi,r12
L13:
    cmp     rdi,4
    jb      L62
    mov     rdi,r12
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    lea     r11,[image.k512]
    mov     [rsp+40h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    je      L16
    jmp     L64
L14:
    cmp     r15,0
    je      L62
    jmp     L10
L15:
    cmp     r12,0
    je      L62
    jmp     L11
L16:
    mov     rdi,rbp
    and     rdi,3
    cmp     rdi,0
    je      L18
    jmp     L66
L17:
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,4
    call    ryo_hr_Memmove
    lea     r12,[rsp+0DCh]
    lea     r11,[image.k536]
    mov     [rsp+48h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    je      L19
    jmp     L68
L18:
    cmp     rbp,0
    je      L66
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    jne     L65
    mov     rdi,r15
    and     rdi,3
    cmp     rdi,0
    je      L17
    jmp     L66
L19:
    mov     rdi,r12
    and     rdi,3
    cmp     rdi,0
    je      L23
    jmp     L70
L20:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rdi,rax
    cmp     edi,1
    jne     L69
    mov     rdi,rbp
    and     rdi,3
    cmp     rdi,0
    jne     L70
    cmp     r12,rbp
    jae     L21
    mov     rdi,rbp
    sub     rdi,r12
    jmp     L22
L21:
    mov     rdi,r12
    sub     rdi,rbp
L22:
    cmp     rdi,4
    jb      L70
    mov     rdi,rbp
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rdi,[rsp+28h]
    sub     rdi,1
    mov     [rsp+28h],rdi
    jmp     L5
L23:
    cmp     r12,0
    je      L70
    jmp     L20
L24:
    mov     rdi,[rsp+30h]
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     r12,rax
    lea     rdi,[k16]
    mov     r11,[rsp+30h]
    cmp     r11,r12
    jb      L73
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    call    fn18
    mov     r8,[rsp+30h]
    sub     r8,r12
    lea     r9,[rbx+r12*4]
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
    mov     qword ptr [rsp+58h],0
    mov     [rsp+68h],r12
    mov     [rsp+60h],r12
    mov     r15,rbx
    mov     r11,[rsp+30h]
    mov     [rsp+50h],r11
    mov     rbp,r13
L25:
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+68h]
    jae     L29
    mov     r11,[rsp+60h]
    cmp     r11,[rsp+50h]
    jae     L29
    mov     r11,[rsp+58h]
    cmp     r11,[rsp+50h]
    jae     L105
    mov     r10,[rsp+58h]
    lea     r8,[r15+r10*4]
    mov     r8d,[r8]
    mov     r10,[rsp+60h]
    lea     r9,[r15+r10*4]
    mov     r9d,[r9]
    cmp     r9d,r8d
    jb      L27
    mov     r10,[rsp+58h]
    lea     r8,[r15+r10*4]
    mov     ebx,[r8]
    mov     r14,[rbp+10h]
    mov     r8,[rbp]
    cmp     r14,r8
    jne     L26
    mov     r13,[rbp]
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFF00h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     r8,[rsp+0E0h]
    mov     r9,[rsp+0E8h]
    mov     rdi,rbp
    mov     rsi,r13
    mov     edx,1
    mov     rcx,r8
    mov     r8,r9
    call    image.sym43
    mov     r8,rax
    mov     [rsp+78h],rdx
    cmp     r8,0FFFFFFFFFFFFFFFFh
    jne     L74
L26:
    mov     r13,[rbp+8]
    lea     r13,[r13+r14*4]
    mov     [r13],ebx
    add     r14,1
    mov     [rbp+10h],r14
    mov     [rsp+8],r13
    mov     rbx,[rsp+58h]
    add     rbx,1
    mov     [rsp+58h],rbx
    jmp     L25
L27:
    mov     r10,[rsp+60h]
    lea     rbx,[r15+r10*4]
    mov     ebx,[rbx]
    mov     r13,[rbp+10h]
    mov     r14,[rbp]
    cmp     r13,r14
    jne     L28
    mov     r14,[rbp]
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFF10h
    lea     rdx,[image.k5328]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+0F0h]
    mov     r9,[rsp+0F8h]
    mov     rdi,rbp
    mov     rsi,r14
    mov     edx,1
    mov     rcx,rax
    mov     r8,r9
    call    image.sym43
    mov     [rsp+0A8h],rax
    mov     [rsp+98h],rdx
    mov     r11,[rsp+0A8h]
    cmp     r11,0FFFFFFFFFFFFFFFFh
    jne     L75
L28:
    mov     r14,[rbp+8]
    lea     r14,[r14+r13*4]
    mov     [r14],ebx
    add     r13,1
    mov     [rbp+10h],r13
    mov     [rsp+8],r14
    mov     rbx,[rsp+60h]
    add     rbx,1
    mov     [rsp+60h],rbx
    jmp     L25
L29:
    lea     r11,[k37]
    mov     [rsp+90h],r11
    mov     r11,[rsp+68h]
    cmp     r11,[rsp+58h]
    jb      L76
    mov     r13,[rsp+68h]
    sub     r13,[rsp+58h]
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+68h]
    jb      L76
    mov     r10,[rsp+58h]
    lea     r14,[r15+r10*4]
    lea     r13,[r14+r13*4]
    lea     r11,[image.k6656]
    mov     [rsp+80h],r11
    cmp     r13,r14
    jb      L77
    sub     r13,r14
    mov     rdi,r13
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r13,rax
    lea     r11,[image.k6704]
    mov     [rsp+88h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rbx,rax
    cmp     ebx,1
    jne     L78
    mov     rbx,r14
    and     rbx,3
    cmp     rbx,0
    je      L31
    jmp     L79
L30:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rbx,rax
    cmp     r13,rbx
    ja      L79
    mov     rdi,rbp
    mov     rsi,r13
    call    qword ptr [image.fn171.slot]
    mov     rbx,[rbp+10h]
    cmp     r13,0
    ja      L32
    jmp     L39
L31:
    cmp     r14,0
    je      L79
    jmp     L30
L32:
    mov     r9,[rbp+8]
    lea     rbx,[r9+rbx*4]
    lea     r11,[image.k7104]
    mov     [rsp+0A0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    cmp     r9d,1
    jne     L81
    mov     r9,r14
    and     r9,3
    cmp     r9,0
    je      L37
    jmp     L84
L33:
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    je      L38
    jmp     L84
L34:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r13
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L83
    cmp     r14,rbx
    jae     L35
    mov     rax,rbx
    sub     rax,r14
    jmp     L36
L35:
    mov     rax,r14
    sub     rax,rbx
L36:
    cmp     r9,rax
    ja      L84
    mov     rax,r13
    imul    rax,4
    mov     rdi,rbx
    mov     rsi,r14
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L39
L37:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L33
    jmp     L82
L38:
    cmp     rbx,0
    je      L84
    jmp     L34
L39:
    mov     rax,[rbp+10h]
    add     rax,r13
    mov     [rbp+10h],rax
    lea     r11,[k40]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+50h]
    cmp     r11,[rsp+60h]
    jb      L86
    mov     r9,[rsp+50h]
    sub     r9,[rsp+60h]
    mov     r10,[rsp+60h]
    lea     rbx,[r15+r10*4]
    lea     r9,[rbx+r9*4]
    lea     r11,[image.k6656]
    mov     [rsp+0B8h],r11
    cmp     r9,rbx
    jb      L87
    sub     r9,rbx
    mov     rdi,r9
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r14,rax
    lea     r11,[image.k6704]
    mov     [rsp+0B0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    cmp     r9d,1
    jne     L88
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    je      L41
    jmp     L89
L40:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r9,rax
    cmp     r14,r9
    ja      L89
    mov     rdi,rbp
    mov     rsi,r14
    call    qword ptr [image.fn171.slot]
    mov     r9,[rbp+10h]
    cmp     r14,0
    ja      L42
    jmp     L49
L41:
    cmp     rbx,0
    je      L89
    jmp     L40
L42:
    mov     r13,[rbp+8]
    lea     r13,[r13+r9*4]
    lea     r11,[image.k7104]
    mov     [rsp+0C0h],r11
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     r9,rax
    cmp     r9d,1
    jne     L91
    mov     r9,rbx
    and     r9,3
    cmp     r9,0
    je      L47
    jmp     L94
L43:
    mov     r9,r13
    and     r9,3
    cmp     r9,0
    je      L48
    jmp     L94
L44:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     r14
    mov     r9,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L93
    cmp     rbx,r13
    jae     L45
    mov     rax,r13
    sub     rax,rbx
    jmp     L46
L45:
    mov     rax,rbx
    sub     rax,r13
L46:
    cmp     r9,rax
    ja      L94
    mov     rax,r14
    imul    rax,4
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L49
L47:
    mov     edi,4
    call    ryo_hr_CtpopW64
    cmp     eax,1
    je      L43
    jmp     L92
L48:
    cmp     r13,0
    je      L94
    jmp     L44
L49:
    mov     rax,[rbp+10h]
    add     rax,r14
    mov     [rbp+10h],rax
    mov     rbx,[rbp+8]
    lea     r11,[k44]
    mov     [rsp+0D0h],r11
    mov     r11,[rsp+50h]
    cmp     r11,rax
    jne     L101
    lea     r13,[image.k560]
    mov     r11,[rsp+50h]
    cmp     r11,0
    jne     L50
    mov     r14d,1
    jmp     L51
L50:
    mov     r14d,0
L51:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rbp,rax
    cmp     ebp,1
    jne     L96
    mov     rbp,rbx
    and     rbp,3
    cmp     rbp,0
    je      L56
    jmp     L99
L52:
    mov     edi,4
    call    ryo_hr_CtpopW64
    mov     rbp,rax
    cmp     ebp,1
    jne     L97
    mov     rbp,r15
    and     rbp,3
    cmp     rbp,0
    je      L57
    jmp     L99
L53:
    mov     r11,rax
    mov     r10,rdx
    mov     eax,4
    mul     qword ptr [rsp+50h]
    mov     rbp,rax
    mov     rax,r11
    mov     rdx,r10
    jb      L98
    cmp     rbx,r15
    jae     L54
    mov     r9,r15
    sub     r9,rbx
    jmp     L55
L54:
    mov     r9,rbx
    sub     r9,r15
L55:
    cmp     rbp,r9
    ja      L99
    mov     r9,[rsp+50h]
    imul    r9,4
    mov     rdi,r15
    mov     rsi,rbx
    mov     rdx,r9
    call    ryo_hr_Memcpy
    jmp     L58
L56:
    test    r14b,r14b
    jne     L52
    cmp     rbx,0
    je      L99
    jmp     L52
L57:
    test    r14b,r14b
    jne     L53
    cmp     r15,0
    je      L99
    jmp     L53
L58:
    mov     rbx,[rsp+150h]
    mov     r12,[rsp+140h]
    mov     r13,[rsp+130h]
    mov     r14,[rsp+120h]
    mov     r15,[rsp+110h]
    mov     rbp,[rsp+100h]
    add     rsp,1E8h
    ret
L59:
    lea     r9,[image.k7768]
    mov     rdi,r9
    mov     esi,175h
    mov     edx,0
    movzx   edx,dl
    call    image.sym49
    ud2
L60:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
L61:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
    jmp     L63
    jmp     L63
L62:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+38h]
    movzx   edx,dl
    call    image.sym49
    ud2
L63:
    call    image.sym10
    ud2
L64:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
L65:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
    jmp     L67
L66:
    lea     rcx,[image.k8904]
    mov     rdi,rcx
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,[rsp+40h]
    movzx   edx,dl
    call    image.sym49
    ud2
L67:
    call    image.sym10
    ud2
L68:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
L69:
    lea     rcx,[image.k6432]
    lea     r9,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    mov     rdx,r9
    call    image.sym6
    ud2
    jmp     L71
    jmp     L71
L70:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+48h]
    movzx   edx,dl
    call    image.sym49
    ud2
L71:
    call    image.sym10
    ud2
L72:
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,[rsp+20h]
    call    sym5
    ud2
L73:
    mov     rsi,r12
    mov     rdx,[rsp+30h]
    mov     rcx,rdi
    mov     edi,0
    call    image.sym31
    ud2
L74:
    mov     rdi,r8
    mov     rsi,[rsp+78h]
    call    image.sym44
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFE30h
    call    ryo_h_Resume
    ud2
L75:
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+98h]
    call    image.sym44
    ud2
    mov     rcx,rax
    mov     [rsp+10h],rcx
    lea     rdi,[rsp+1E0h]
    mov     esi,0FFFFFE30h
    call    ryo_h_Resume
    ud2
L76:
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+90h]
    call    image.sym31
    ud2
L77:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+80h]
    movzx   edx,dl
    call    image.sym49
    ud2
L78:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L80
L79:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+88h]
    movzx   edx,dl
    call    image.sym49
    ud2
L80:
    call    image.sym10
    ud2
L81:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L82:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L83:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L85
    jmp     L85
L84:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0A0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L85:
    call    image.sym10
    ud2
L86:
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+0C8h]
    call    image.sym31
    ud2
L87:
    lea     rcx,[image.k7567]
    mov     rdi,rcx
    mov     esi,193h
    mov     edx,0
    mov     rcx,[rsp+0B8h]
    movzx   edx,dl
    call    image.sym49
    ud2
L88:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
    jmp     L90
L89:
    lea     rcx,[image.k9407]
    mov     rdi,rcx
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,[rsp+0B0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L90:
    call    image.sym10
    ud2
L91:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L92:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L93:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L95
    jmp     L95
L94:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,[rsp+0C0h]
    movzx   edx,dl
    call    image.sym49
    ud2
L95:
    call    image.sym10
    ud2
L96:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L97:
    lea     rcx,[image.k6432]
    lea     rdx,[image.k6560]
    mov     rdi,rcx
    mov     esi,55h
    call    image.sym6
    ud2
L98:
    lea     rcx,[image.k9346]
    mov     rdi,rcx
    mov     esi,3Dh
    call    image.sym50
    ud2
    jmp     L100
    jmp     L100
L99:
    lea     rcx,[image.k8338]
    mov     rdi,rcx
    mov     esi,237h
    mov     edx,0
    mov     rcx,r13
    movzx   edx,dl
    call    image.sym49
    ud2
L100:
    call    image.sym10
    ud2
L101:
    mov     rdi,[rsp+50h]
    mov     rsi,rax
    mov     rdx,[rsp+0D0h]
    call    image.sym24
    ud2
L102:
    ud2
L103:
    lea     rax,[k4]
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L104:
    lea     rax,[k6]
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,rax
    call    sym5
    ud2
L105:
    lea     rax,[k23]
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+50h]
    mov     rdx,rax
    call    sym5
    ud2
  ; OSR entries
    lea     r11,[L106]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L106:
    .long   L107
    .long   L108
    .long   L109
L107:
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
    lea     rsp,[rsp+1A0h]
    jmp     L0
L108:
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
    mov     r14,[rsp+8]
    lea     rsp,[rsp+1B0h]
    jmp     L5
L109:
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
    mov     [rdx-188h],r11
    mov     r11,[rsp+8]
    mov     [rdx-178h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-190h],r11
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+1C0h]
    jmp     L25

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
    mov     rax,[rbx]
    cmp     r13,rax
    jne     L0
    mov     r14,[rbx]
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

