fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,[rdi]
    mov     r12,[rdi+8]
    mov     r13,[rdi+10h]
    lea     rax,[k0]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8,r13
    mov     r9,rax
    call    fn1
    imul    r13,4
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,r13
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    sub     rsp,18h
    mov     rdi,rsi
    mov     rsi,rdx
    call    qword ptr [fn0.slot]
    movzx   eax,al
    add     rsp,18h
    ret

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+8]
    mov     rcx,[rbx]
    mov     [rsp+20h],rcx
    mov     [rsp+28h],rdx
    mov     [rsp+8],rcx
    mov     [rsp+10h],rdx
    mov     rdi,rax
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    mov     rcx,[rbx]
    add     rcx,1
    jb      L0
    mov     [rbx],rcx
    mov     rbx,[rsp+30h]
    add     rsp,48h
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
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
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

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     rax,rdi
    mov     rdx,rsi
    add     rsp,38h
    ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA0h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     ebx,1
L0:
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    fn0
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
    .long   L8
L2:
    lea     rax,[rsp+30h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn1
    mov     ebx,1
    jmp     L0
L3:
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,68h
    ret
    mov     r10,rax
    mov     rax,rbx
    mov     rbx,r10
    jmp     L10
    mov     rbx,rax
    mov     eax,0
    jmp     L10
    jmp     L5
L4:
    lea     rax,[rsp+30h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    mov     rax,rbx
    jmp     L5
    jmp     L9
L5:
    mov     [rsp],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
L6:
    jmp     L4
L7:
    test    al,al
    jne     L6
    jmp     L4
L8:
    ud2
L9:
    call    qword ptr [sym4]
    ud2
L10:
    jmp     L7
  ; OSR entries
    lea     r11,[L11]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L11:
    .long   L12
    .long   L13
    .long   L14
    .long   L15
    .long   L16
    .long   L17
L12:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-90h]
    movzx   r11d,byte ptr [rdx-39h]
    mov     [rsp],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     rbx,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L0
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

fn <std::ops::Range<usize> as std::iter::range::RangeIteratorImpl>::spec_next
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+8]
    mov     rdi,rbx
    mov     rsi,rax
    call    fn0
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

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
    sub     rsp,18h
    cmp     rsi,rdi
    jb      L2
    jmp     L1
L0:
    lea     r9,[rdx+rdi*4]
    mov     rdx,rax
    mov     rax,r9
    add     rsp,18h
    ret
L1:
    mov     rax,rsi
    sub     rax,rdi
    cmp     rcx,rsi
    jae     L0
L2:
    mov     rdx,rcx
    mov     rcx,r8
    call    qword ptr [sym0]
    ud2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
L4:
    ret
L5:
    ret

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,18h
    cmp     rsi,rdi
    jb      L2
    jmp     L1
L0:
    lea     r9,[rdx+rdi*4]
    mov     rdx,rax
    mov     rax,r9
    add     rsp,18h
    ret
L1:
    mov     rax,rsi
    sub     rax,rdi
    cmp     rcx,rsi
    jae     L0
L2:
    mov     rdx,rcx
    mov     rcx,r8
    call    qword ptr [sym0]
    ud2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
    .long   L5
L4:
    ret
L5:
    ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
    sub     rsp,18h
    cmp     rdx,rdi
    jb      L0
    mov     rax,rdx
    sub     rax,rdi
    lea     rsi,[rsi+rdi*4]
    mov     rdx,rax
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    mov     rsi,rdx
    call    qword ptr [sym0]
    ud2

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,18h
    cmp     rdx,rdi
    jb      L0
    mov     rax,rdx
    sub     rax,rdi
    lea     rsi,[rsi+rdi*4]
    mov     rdx,rax
    mov     rax,rsi
    add     rsp,18h
    ret
L0:
    mov     rsi,rdx
    call    qword ptr [sym0]
    ud2

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,18h
    mov     r8,rcx
    mov     rcx,rdx
    mov     rdx,rsi
    mov     rsi,rdi
    mov     edi,0
    call    fn0
    add     rsp,18h
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
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L3
L0:
    lea     rax,[rsp+68h]
    lea     rcx,[r13+r14*4]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    jmp     L6
L1:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
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
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rcx
    call    fn5
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    jmp     L4
L6:
    lea     rax,[k9]
    mov     rdi,r14
    mov     esi,1
    mov     rdx,rax
    call    fn10
    add     r14,1
    cmp     r14,r15
    je      L1
    mov     rax,r13
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,rbp
    jmp     L2
    mov     edx,0
    jmp     L12
    mov     ecx,0
    mov     rbx,rax
    jmp     L14
    mov     rdx,rbp
    jmp     L12
L7:
    lea     rax,[rsp+68h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     rdx,rbp
    mov     rax,rbx
    jmp     L12
    jmp     L13
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L7
L10:
    test    cl,cl
    jne     L9
    jmp     L7
L11:
    jmp     L8
L12:
    test    dl,dl
    jne     L11
    jmp     L8
L13:
    call    qword ptr [sym11]
    ud2
L14:
    jmp     L10
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
    .long   L26
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
L17:
    ret
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L2
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
L26:
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,0A8h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     [rsp+78h],rcx
    cmp     rbx,r12
    sete    al
    test    al,al
    je      L5
    mov     rax,r13
    jmp     L3
L0:
    lea     rcx,[rsp+78h]
    lea     rdx,[r14+r15*4]
    mov     rdi,rcx
    mov     rsi,rax
    call    fn0
    mov     [rsp+18h],rax
    jmp     L6
L1:
    mov     rax,[rsp+18h]
    jmp     L3
L2:
    mov     r14,rcx
    mov     r15,rdx
    mov     rbp,rsi
    mov     [rsp+10h],rdi
    jmp     L0
L3:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,0A8h
    ret
L4:
    mov     r14,rbx
    mov     r15d,0
    mov     rbp,rax
    mov     rax,r13
    mov     qword ptr [rsp+10h],0
    jmp     L0
L5:
    lea     rcx,[k1]
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rcx
    call    fn2
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    jmp     L4
L6:
    lea     rax,[k6]
    mov     rdi,r15
    mov     esi,1
    mov     rdx,rax
    call    fn7
    add     r15,1
    cmp     r15,rbp
    je      L1
    mov     rax,[rsp+18h]
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,rbp
    mov     rdi,[rsp+10h]
    jmp     L2
    mov     edx,0
    mov     rcx,rax
    mov     rax,[rsp+10h]
    jmp     L13
L7:
    jmp     L12
L8:
    mov     [rsp],rcx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L7
L10:
    test    dl,dl
    jne     L9
    jmp     L7
L11:
    jmp     L8
L12:
    test    al,al
    jne     L11
    jmp     L8
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
    .long   L21
    .long   L22
    .long   L23
L15:
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
    mov     r11,[rsp+20h]
    mov     [rdx-90h],r11
    mov     rax,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+70h]
    jmp     L0
L16:
    ret
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
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+70h]
    jmp     L2
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

fn <std::vec::Vec<u32> as std::ops::Deref>::deref
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     rdx,rcx
    add     rsp,18h
    ret

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    lea     rax,[rsp+8]
    mov     rdi,rax
    call    fn0
    jmp     L1
L0:
    mov     rbx,[rsp+20h]
    add     rsp,38h
    ret
L1:
    mov     rdi,rbx
    mov     rsi,rax
    call    qword ptr [fn1.slot]
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,18h
    call    fn0
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

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
    sub     rsp,18h
    mov     eax,20h
    add     rsp,18h
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,18h
    call    fn0
    add     rsp,18h
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn <usize as std::iter::Step>::forward_unchecked
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

fn Rng::next
    sub     rsp,18h
    mov     rax,[rdi]
    shl     rax,0Dh
    mov     rcx,[rdi]
    xor     rcx,rax
    mov     [rdi],rcx
    shr     rcx,7
    mov     rax,[rdi]
    xor     rax,rcx
    mov     [rdi],rax
    shl     rax,11h
    mov     rcx,[rdi]
    xor     rcx,rax
    mov     [rdi],rcx
    mov     rax,rcx
    add     rsp,18h
    ret

fn checksum::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    mov     r12d,[rcx]
    mov     rdi,rsi
    mov     esi,1Fh
    call    qword ptr [fn0.slot]
    mov     r12d,r12d
    xor     r12,rbx
    mov     rdi,rax
    mov     rsi,r12
    call    qword ptr [fn1.slot]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret

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
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r15
    call    fn0
    mov     [rsp+48h],r12
    mov     rdi,r12
    mov     esi,8
    mov     edx,4
    mov     rcx,r14
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r14
    mov     [rsp+30h],r12
    mov     [rsp+38h],r14
    lea     r12,[r12+r14*8]
    sub     r13,r14
    mov     rdi,r12
    mov     esi,8
    mov     edx,4
    mov     rcx,r13
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r13
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     [rsp+20h],r12
    mov     [rsp+28h],r13
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF70h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    add     rsp,0A8h
    ret

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

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
    sub     rsp,18h
    cmp     rsi,rdi
    jae     L0
    cmp     rdx,rdi
    jae     L0
    add     rsp,18h
    ret
L0:
    lea     rax,[k0]
    mov     rdi,rax
    mov     esi,1B5h
    mov     edx,0
    movzx   edx,dl
    call    qword ptr [sym2]
    ud2

fn core::slice::<impl [u32]>::copy_from_slice
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

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
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r15
    call    qword ptr [fn0.slot]
    mov     [rsp+48h],r12
    mov     rdi,r12
    mov     esi,4
    mov     edx,4
    mov     rcx,r14
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r14
    mov     [rsp+30h],r12
    mov     [rsp+38h],r14
    lea     r12,[r12+r14*4]
    sub     r13,r14
    mov     rdi,r12
    mov     esi,4
    mov     edx,4
    mov     rcx,r13
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r13
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     [rsp+20h],r12
    mov     [rsp+28h],r13
    mov     [rsp],rbx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0
    mov     ecx,0FFFFFF70h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    add     rsp,0A8h
    ret

fn core::slice::<impl [u32]>::swap
    sub     rsp,18h
    cmp     rdx,rsi
    jae     L0
    cmp     rcx,rsi
    jae     L1
    call    fn2
    add     rsp,18h
    ret
L0:
    mov     rdi,rdx
    mov     rdx,r8
    call    qword ptr [sym0]
    ud2
L1:
    mov     rdi,rcx
    mov     rdx,r8
    call    qword ptr [sym0]
    ud2

fn core::slice::<impl [u32]>::swap_unchecked
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rdx
    mov     r13,rcx
    mov     rdi,rsi
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,r8
    call    qword ptr [fn0.slot]
    lea     rax,[rbx+r12*4]
    lea     rbx,[rbx+r13*4]
    mov     rdi,rax
    mov     rsi,rbx
    call    fn1
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

fn core::slice::copy_from_slice_impl::<u32>
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,rcx
    jne     L0
    lea     rax,[k1]
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8,r12
    mov     r9,rax
    call    fn2
    mov     rax,r12
    imul    rax,4
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L0:
    mov     rdi,r12
    mov     rsi,rcx
    mov     rdx,r8
    call    qword ptr [sym0]
    ud2

fn core::slice::index::<impl std::ops::Index<std::ops::Range<usize>> for [u32]>::index
    sub     rsp,18h
    mov     r10,rdi
    mov     rdi,rdx
    mov     rdx,r10
    mov     r10,rsi
    mov     rsi,rcx
    mov     rcx,r10
    call    fn0
    add     rsp,18h
    ret

fn core::slice::index::<impl std::ops::Index<std::ops::RangeFrom<usize>> for [u32]>::index
    sub     rsp,18h
    mov     r10,rdi
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,r10
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeFrom<usize>> for [u32]>::index_mut
    sub     rsp,18h
    mov     r10,rdi
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,r10
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeTo<usize>> for [u32]>::index_mut
    sub     rsp,18h
    mov     r10,rdi
    mov     rdi,rdx
    mov     rdx,rsi
    mov     rsi,r10
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,8
    jb      L7
    mov     rdi,r12
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    lea     rcx,[rbx+rcx*8]
    mov     rdx,rax
    imul    rdx,7
    lea     rdx,[rbx+rdx*8]
    cmp     r12,40h
    jae     L0
    mov     rdi,rbx
    mov     rsi,rcx
    mov     rcx,r13
    call    fn0
    mov     r14,rax
    jmp     L3
L0:
    mov     rdi,rbx
    mov     rsi,rcx
    mov     rcx,rax
    mov     r8,r13
    call    fn1
    mov     r13,rax
    jmp     L5
L1:
    cmp     r15,r12
    setb    al
    jmp     L6
L2:
    mov     r15,rcx
    jmp     L1
L3:
    lea     rdx,[k2]
    mov     rdi,r14
    mov     rsi,rbx
    call    fn3
    sub     r14,rbx
    mov     rdi,r14
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L2
L4:
    mov     r15,rcx
    jmp     L1
L5:
    lea     rdx,[k7]
    mov     rdi,r13
    mov     rsi,rbx
    call    fn3
    sub     r13,rbx
    mov     rdi,r13
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L4
L6:
    lea     rcx,[k12]
    mov     rdi,rax
    mov     rsi,rcx
    movzx   edi,dil
    call    fn13
    mov     rax,r15
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L7:
    lea     rdi,[rsp+60h]
    call    ryo_h_Abort
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
L9:
    ret
L10:
    ret
L11:
    ret

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,8
    jb      L7
    mov     rdi,r12
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rcx,rax
    imul    rcx,4
    lea     rcx,[rbx+rcx*4]
    mov     rdx,rax
    imul    rdx,7
    lea     rdx,[rbx+rdx*4]
    cmp     r12,40h
    jae     L0
    mov     rdi,rbx
    mov     rsi,rcx
    mov     rcx,r13
    call    fn0
    mov     r14,rax
    jmp     L3
L0:
    mov     rdi,rbx
    mov     rsi,rcx
    mov     rcx,rax
    mov     r8,r13
    call    fn1
    mov     r13,rax
    jmp     L5
L1:
    cmp     r15,r12
    setb    al
    jmp     L6
L2:
    mov     r15,rcx
    jmp     L1
L3:
    lea     rdx,[k2]
    mov     rdi,r14
    mov     rsi,rbx
    call    qword ptr [fn3.slot]
    sub     r14,rbx
    mov     rdi,r14
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L2
L4:
    mov     r15,rcx
    jmp     L1
L5:
    lea     rdx,[k7]
    mov     rdi,r13
    mov     rsi,rbx
    call    qword ptr [fn3.slot]
    sub     r13,rbx
    mov     rdi,r13
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rcx,rax
    jmp     L4
L6:
    lea     rcx,[k12]
    mov     rdi,rax
    mov     rsi,rcx
    movzx   edi,dil
    call    qword ptr [fn13.slot]
    mov     rax,r15
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L7:
    lea     rdi,[rsp+60h]
    call    ryo_h_Abort
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
L9:
    ret
L10:
    ret
L11:
    ret

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
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
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r12
    call    fn0
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r13
    call    fn0
    cmp     r15b,al
    jne     L1
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    call    fn0
    xor     eax,r15d
    test    al,al
    je      L0
    jmp     L2
L0:
    mov     r13,r12
    jmp     L2
L1:
    mov     r13,rbx
L2:
    mov     rax,r13
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
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
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r12
    call    fn0
    mov     r15,rax
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,r13
    call    fn0
    cmp     r15b,al
    jne     L1
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    call    fn0
    xor     eax,r15d
    test    al,al
    je      L0
    jmp     L2
L0:
    mov     r13,r12
    jmp     L2
L1:
    mov     r13,rbx
L2:
    mov     rax,r13
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
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
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,[rsp+10h]
    call    qword ptr [fn3.slot]
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
    lea     rax,[rbx+rbp*4]
    mov     r14,r15
    imul    r14,7
    lea     rcx,[rbx+r14*4]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     rbx,rax
    lea     rax,[r12+rbp*4]
    lea     rcx,[r12+r14*4]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     r12,rax
    lea     rax,[r13+rbp*4]
    lea     rcx,[r13+r14*4]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    mov     rcx,r15
    mov     r8,[rsp+10h]
    call    fn0
    mov     r13,rax
L0:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,[rsp+10h]
    call    fn3
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
    jne     L12
    mov     rcx,[rsp+0C8h]
    cmp     rdx,rcx
    jne     L12
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
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    call    fn3
    mov     rax,[rsp+0C8h]
    mov     r12,rax
    add     r12,1
    mov     [rsp+0C0h],r12
    lea     rax,[rsp+0C0h]
    mov     rdi,rax
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
    mov     rax,[rsp+30h]
    lea     rax,[rax+4]
    mov     [rsp+0C8h],rax
    mov     rdi,[rsp+28h]
    mov     esi,2
    call    ryo_hr_RemUW64
    cmp     rax,0
    sete    al
    mov     [rsp+0C7h],al
    test    al,al
    jne     L2
    jmp     L3
L11:
    lea     rax,[k5]
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn6
    mov     rdi,[rsp+20h]
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   eax,byte ptr [rsp+0C6h]
    movzx   ecx,al
    mov     r11,[rsp+18h]
    lea     rcx,[r11+rcx*4]
    xor     eax,1
    mov     [rsp+0C5h],al
    movzx   eax,al
    mov     r11,[rsp+10h]
    lea     rax,[r11+rax*4]
    mov     rdx,rax
    jmp     L6
L12:
    call    qword ptr [sym1]
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
L14:
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
L15:
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
L16:
    ret
L17:
    ret
L18:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0E8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    jmp     L8
L0:
    movzx   eax,byte ptr [rsp+9Fh]
    test    al,al
    je      L6
    mov     [rsp+30h],r12
    mov     eax,[r12]
    mov     [rsp+34h],eax
    mov     [rsp+9Ch],eax
    lea     rax,[rsp+9Ch]
    mov     [rsp+20h],rax
    mov     [rsp+28h],r12
    mov     qword ptr [rsp+30h],1
    mov     r15,r14
    mov     [rsp+18h],rbx
    mov     [rsp+10h],r13
L1:
    mov     rbp,[rsp+28h]
    jmp     L9
L2:
    jmp     L5
L3:
    jmp     L11
L4:
    test    sil,sil
    je      L5
    mov     r15,rdi
    mov     [rsp+18h],r8
    mov     [rsp+10h],r9
    jmp     L1
L5:
    lea     rsi,[rsp+20h]
    mov     rdi,rsi
    call    qword ptr [fn0.slot]
L6:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0E8h
    ret
L7:
    mov     [rsp+20h],r12
    mov     [rsp+28h],r12
    mov     [rsp+30h],r14
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,r14
    call    fn2
    mov     rsi,rax
    mov     [rsp+9Fh],sil
    jmp     L0
L8:
    mov     rsi,r12
    lea     rsi,[rsi-4]
    mov     r14,rsi
    jmp     L7
L9:
    lea     rsi,[k3]
    mov     rdi,r15
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rsi
    mov     rsi,rbp
    call    fn4
    mov     rdi,rbp
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     [rsp+28h],r15
    cmp     r15,[rsp+18h]
    je      L2
    mov     rax,r15
    mov     rcx,[rsp+10h]
    mov     rdx,[rsp+18h]
    jmp     L3
L10:
    lea     rsi,[rsp+9Ch]
    mov     rdi,r12
    mov     rdx,rbx
    call    fn2
    mov     rsi,rax
    mov     rdi,rbx
    mov     r8,r13
    mov     r9,r12
    jmp     L4
L11:
    lea     rax,[rax-4]
    mov     rbx,rax
    mov     r12,rcx
    mov     r13,rdx
    jmp     L10
L12:
    lea     rax,[rsp+20h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L13
    jmp     L14
L13:
    mov     [rsp],rbx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
    call    ryo_h_Resume
    ud2
    mov     rbx,rax
    jmp     L12
L14:
    call    qword ptr [sym6]
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
L16:
    ret
L17:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-18h]
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
    mov     r11,[rsp+8]
    mov     [rdx-0C8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D0h],r11
    mov     r15,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L1
L18:
    ret
L19:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-20h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L3
L20:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-120h]
    movzx   r11d,byte ptr [rdx-45h]
    mov     [rsp],r11
    mov     r11,[rdx-20h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-18h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-60h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-58h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-50h]
    mov     [rsp+30h],r11
    mov     [rdx-50h],rbx
    mov     [rdx-60h],r12
    mov     [rdx-70h],r13
    mov     [rdx-80h],r14
    mov     [rdx-90h],r15
    mov     [rdx-0A0h],rbp
    mov     r11,[rsp+20h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-0B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-0B0h],r11
    mov     rsi,[rsp]
    mov     rdi,[rsp+8]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L4
L21:
    ret
L22:
    ret
L23:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-110h]
    mov     r11,[rdx-68h]
    mov     [rsp],r11
    mov     r11,[rdx-18h]
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
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L10
L24:
    ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    cmp     rdx,0
    je      L2
    cmp     rsi,rdx
    jb      L2
    lea     rax,[rdi+rsi*4]
    lea     rdx,[rdi+rdx*4]
    mov     rbx,rdx
    mov     r12,rax
    mov     r13,rdi
    mov     r14,rcx
L0:
    cmp     rbx,r12
    je      L1
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r14
    call    fn0
    lea     rbx,[rbx+4]
    jmp     L0
L1:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L2:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
    ud2
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    pop     rcx
    lea     rdx,[rsp+60h]
    lea     rsp,[rdx-80h]
    mov     r11,[rdx-28h]
    mov     [rsp],r11
    mov     r11,[rdx-40h]
    mov     [rsp+8],r11
    mov     r11,[rdx-38h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-20h]
    mov     [rsp+18h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+30h]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     rdi,r8
    mov     rsi,r13
    mov     rdx,r12
    call    fn0
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
    lea     rax,[k1]
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn2
    mov     rdi,r14
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
    jmp     L3
L2:
    mov     [rsp+18h],r12
    mov     [rsp+20h],r13
    mov     [rsp+28h],rax
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret
L3:
    lea     r14,[r14-4]
    mov     rax,r14
    jmp     L2
  ; OSR entries
    lea     r11,[L4]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L4:
    .long   L5
L5:
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     [rsp+10h],rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     rdi,r8
    mov     rsi,r13
    mov     rdx,r12
    call    fn0
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
    lea     rax,[k1]
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn2
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    movzx   r15d,r15b
    lea     r13,[r13+r15*4]
    movzx   ebp,bpl
    lea     r12,[r12+rbp*4]
    lea     r14,[r14+4]
    mov     [rsp+18h],r12
    mov     [rsp+20h],r13
    mov     [rsp+28h],r14
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0
    mov     ecx,0FFFFFF88h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,98h
    ret

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,298h
    mov     [rsp+170h],rbx
    mov     [rsp+160h],r12
    mov     [rsp+150h],r13
    mov     [rsp+140h],r14
    mov     [rsp+130h],r15
    mov     [rsp+120h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,r8
    cmp     r12,2
    jb      L13
    mov     rax,r12
    add     rax,10h
    cmp     rcx,rax
    jb      L21
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+90h],rax
    cmp     r12,10h
    jb      L0
    lea     rax,[r13+r12*8]
    mov     [rsp+0B0h],rax
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,rax
    mov     rcx,r14
    call    qword ptr [fn0.slot]
    mov     r10,[rsp+90h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+0B0h],rax
    mov     r10,[rsp+90h]
    lea     rcx,[r13+r10*8]
    mov     [rsp+0A8h],rcx
    mov     rdx,r12
    add     rdx,8
    mov     [rsp+198h],rdx
    lea     rdx,[r13+rdx*8]
    mov     [rsp+0A0h],rdx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,r14
    call    qword ptr [fn0.slot]
    mov     ebp,8
    jmp     L2
L0:
    cmp     r12,8
    jb      L1
    mov     [rsp+0B0h],rbx
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r14
    call    qword ptr [fn2.slot]
    mov     r10,[rsp+90h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+0A8h],rax
    mov     [rsp+0B0h],rax
    mov     r10,[rsp+90h]
    lea     rcx,[r13+r10*8]
    mov     [rsp+0A8h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r14
    call    qword ptr [fn2.slot]
    mov     ebp,4
    jmp     L2
L1:
    mov     [rsp+0B0h],rbx
    jmp     L14
L2:
    mov     qword ptr [rsp+190h],0
    mov     r10,[rsp+90h]
    mov     [rsp+198h],r10
    mov     qword ptr [rsp+180h],0
    mov     r10,[rsp+90h]
    mov     [rsp+188h],r10
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE30h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     qword ptr [rsp+0D0h],0
    mov     r10,[rsp+90h]
    mov     [rsp+0D8h],r10
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFE30h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFE70h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE10h
    mov     edx,0FFFFFE50h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFE10h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp+88h],r13
    mov     [rsp+10h],rbx
    mov     [rsp+18h],r12
    mov     [rsp+20h],r13
    mov     r11,[rsp+90h]
    mov     [rsp+28h],r11
    mov     [rsp+30h],rbp
    mov     [rsp+38h],r14
L3:
    lea     rax,[rsp+180h]
    mov     [rsp+0F8h],rax
    mov     [rsp+0C0h],rax
    mov     qword ptr [rsp+0C8h],2
    mov     rdi,rax
    mov     esi,2
    call    qword ptr [fn5.slot]
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],rdx
    jmp     L15
L4:
    mov     rax,[rsp+0D8h]
    mov     [rsp+0C8h],rax
    mov     r11,[rsp+10h]
    lea     rcx,[r11+rax*8]
    mov     [rsp+0C0h],rcx
    mov     r11,[rsp+20h]
    lea     rcx,[r11+rax*8]
    mov     [rsp+0F8h],rcx
    cmp     rax,0
    je      L6
    jmp     L7
L5:
    lea     rax,[rsp+180h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    jmp     L11
L6:
    mov     rax,[rsp+28h]
    jmp     L8
L7:
    mov     rax,[rsp+18h]
    sub     rax,[rsp+28h]
L8:
    mov     r10,[rsp+30h]
    mov     [rsp+0F0h],r10
    mov     r11,[rsp+30h]
    mov     [rsp+80h],r11
    mov     [rsp+40h],rax
    mov     r11,[rsp+88h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+18h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+78h],r11
L9:
    mov     r10,[rsp+80h]
    mov     [rsp+118h],r10
    mov     r10,[rsp+40h]
    mov     [rsp+110h],r10
    mov     r11,[rsp+80h]
    cmp     r11,[rsp+40h]
    setb    cl
    mov     [rsp+0E7h],cl
    test    cl,cl
    jne     L17
    jmp     L18
L10:
    mov     [rsp+80h],rcx
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdi
    mov     [rsp+58h],r8
    mov     [rsp+60h],r9
    mov     [rsp+68h],rax
    mov     [rsp+70h],rbp
    mov     [rsp+78h],r15
    jmp     L9
L11:
    mov     r10,[rsp+88h]
    mov     [rsp+0A0h],r10
    mov     r10,[rsp+88h]
    mov     [rsp+0A8h],r10
    mov     r10,[rsp+10h]
    mov     [rsp+0B0h],r10
    mov     r10,[rsp+18h]
    mov     [rsp+0B8h],r10
    mov     r10,[rsp+88h]
    mov     [rsp+190h],r10
    mov     r10,[rsp+18h]
    mov     [rsp+188h],r10
    jmp     L20
L12:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+198h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+190h],rax
L13:
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+160h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+140h]
    mov     r15,[rsp+130h]
    mov     rbp,[rsp+120h]
    add     rsp,298h
    ret
L14:
    mov     [rsp+0A8h],rbx
    mov     [rsp+0A0h],r13
    lea     rax,[k9]
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     [rsp],r13
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFFD78h
    call    ryo_h_Memcpy
    mov     r10,[rsp+90h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+0B0h],rax
    mov     r10,[rsp+90h]
    lea     rcx,[r13+r10*8]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rax
    mov     rcx,[rsp+0A8h]
    mov     [rsp+198h],rcx
    lea     rdx,[k11]
    mov     rdi,rax
    mov     rsi,rcx
    mov     ecx,4
    mov     r8d,1
    mov     r9,rdx
    mov     edx,8
    call    fn10
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE18h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFFD70h
    call    ryo_h_Memcpy
    mov     ebp,1
    jmp     L2
L15:
    mov     rax,[rsp+0D0h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L16]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L16:
    .long   L5
    .long   L4
    .long   L22
L17:
    mov     r10,[rsp+80h]
    mov     [rsp+118h],r10
    jmp     L19
L18:
    mov     r11,[rsp+48h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+10h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+18h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+38h],r11
    jmp     L3
L19:
    lea     rax,[k13]
    mov     rcx,[rsp+118h]
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    call    fn14
    mov     rax,[rsp+118h]
    mov     rbx,rax
    add     rbx,1
    mov     [rsp+110h],rbx
    mov     [rsp+0F0h],rax
    mov     qword ptr [rsp+0E8h],1
    mov     [rsp+0E0h],rax
    mov     rcx,[rsp+0C0h]
    lea     rcx,[rcx+rax*8]
    mov     [rsp+118h],rcx
    mov     rdx,[rsp+0F8h]
    lea     r12,[rdx+rax*8]
    mov     [rsp+110h],rcx
    mov     [rsp+108h],r12
    lea     rax,[k15]
    mov     rdi,rcx
    mov     rsi,r12
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     [rsp],r12
    mov     qword ptr [rsp+8],8
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    mov     edx,0FFFFFE88h
    mov     ecx,0FFFFFD78h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0F8h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,[rsp+78h]
    call    qword ptr [fn17.slot]
    mov     rcx,rbx
    mov     rdx,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdi,[rsp+50h]
    mov     r8,[rsp+58h]
    mov     r9,[rsp+60h]
    mov     rax,[rsp+68h]
    mov     rbp,[rsp+70h]
    mov     r15,[rsp+78h]
    jmp     L10
L20:
    mov     rax,[rsp+190h]
    mov     [rsp+180h],rax
    lea     rcx,[k18]
    mov     rdx,[rsp+188h]
    mov     rdi,rax
    mov     esi,8
    mov     r8,rcx
    mov     rcx,rdx
    mov     edx,4
    call    fn19
    mov     rax,[rsp+190h]
    mov     [rsp+0D8h],rax
    mov     rcx,[rsp+188h]
    mov     [rsp+180h],rcx
    mov     [rsp+198h],rax
    mov     [rsp+0A0h],rcx
    mov     rdx,[rsp+0B0h]
    mov     [rsp+190h],rdx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+38h]
    call    qword ptr [fn20.slot]
    jmp     L12
L21:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
    mov     rbx,rax
    jmp     L27
L22:
    ud2
L23:
    lea     rax,[rsp+180h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,rbx
    jmp     L24
    jmp     L26
L24:
    mov     [rsp],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    call    ryo_h_Resume
    ud2
L25:
    lea     rax,[rsp+0A8h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    mov     rax,r12
    jmp     L24
    jmp     L26
    mov     rbx,rax
    jmp     L27
    mov     r12,rax
    jmp     L25
L26:
    call    qword ptr [sym21]
    ud2
L27:
    jmp     L23
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
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
    .long   L38
L29:
    ret
L30:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-350h]
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
    mov     r11,[rsp]
    mov     [rdx-208h],r11
    mov     r11,[rsp+8]
    mov     [rdx-280h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-278h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-270h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-260h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-258h],r11
    lea     rsp,[rsp+0C0h]
    jmp     L3
L31:
    ret
L32:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-360h]
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
    mov     [rdx-250h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-218h],r11
    lea     rsp,[rsp+0D0h]
    jmp     L9
L33:
    pop     rcx
    lea     rdx,[rsp+190h]
    lea     rsp,[rdx-360h]
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
    mov     rcx,[rsp]
    mov     rsi,[rsp+10h]
    mov     rdi,[rsp+18h]
    mov     r8,[rsp+20h]
    mov     r9,[rsp+28h]
    mov     rax,[rsp+30h]
    mov     rbp,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp+8]
    lea     rsp,[rsp+0D0h]
    jmp     L10
L34:
    ret
L35:
    ret
L36:
    ret
L37:
    ret
L38:
    ret

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,158h
    mov     [rsp+140h],rbx
    mov     [rsp+130h],r12
    mov     [rsp+120h],r13
    mov     [rsp+110h],r14
    mov     [rsp+100h],r15
    mov     [rsp+0F0h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,2
    jb      L8
    cmp     r12,20h
    ja      L13
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     r14,rax
    cmp     r12,12h
    setb    r15b
    test    r15b,r15b
    je      L0
    mov     rbp,r12
    jmp     L1
L0:
    mov     rbp,r14
L1:
    jmp     L9
L2:
    mov     r11,[rsp+48h]
    mov     rax,[rsp+50h]
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rax
    cmp     rax,0Dh
    jb      L3
    mov     rax,[rsp+48h]
    mov     [rsp+0E0h],rax
    mov     rcx,[rsp+50h]
    mov     [rsp+0E8h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+10h]
    call    qword ptr [fn0.slot]
    mov     eax,0Dh
    jmp     L5
L3:
    mov     r11,[rsp+48h]
    mov     rax,[rsp+50h]
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rax
    cmp     rax,9
    jb      L4
    mov     rax,[rsp+48h]
    mov     [rsp+0E0h],rax
    mov     rcx,[rsp+50h]
    mov     [rsp+0E8h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+10h]
    call    qword ptr [fn1.slot]
    mov     eax,9
    jmp     L5
L4:
    mov     eax,1
L5:
    mov     rcx,[rsp+48h]
    mov     [rsp+0E0h],rcx
    mov     rdx,[rsp+50h]
    mov     [rsp+0E8h],rdx
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rdx,rax
    mov     rcx,[rsp+10h]
    call    fn2
    cmp     byte ptr [rsp+18h],0
    jne     L8
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+0E0h],rcx
    mov     [rsp+0E8h],rax
    mov     r10,[rsp+20h]
    mov     [rsp+0E0h],r10
    cmp     rax,[rsp+20h]
    je      L6
    lea     r11,[rsp+58h]
    mov     [rsp+40h],r11
    jmp     L11
L6:
    mov     r11,[rsp+28h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*4]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+38h]
    sub     rax,[rsp+30h]
    mov     [rsp+0E0h],rax
    jmp     L10
L7:
    mov     r10,[rsp+40h]
    mov     [rsp+0E8h],r10
    jmp     L12
L8:
    mov     rbx,[rsp+140h]
    mov     r12,[rsp+130h]
    mov     r13,[rsp+120h]
    mov     r14,[rsp+110h]
    mov     r15,[rsp+100h]
    mov     rbp,[rsp+0F0h]
    add     rsp,158h
    ret
L9:
    mov     [rsp+0E8h],rbx
    lea     rax,[k3]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,rbp
    mov     r8,rax
    call    fn4
    mov     [rsp+0E0h],rbx
    mov     [rsp+0E8h],rbp
    mov     [rsp+48h],rbx
    mov     [rsp+50h],rbp
    mov     [rsp+10h],r13
    mov     [rsp+18h],r15
    mov     [rsp+20h],rbx
    mov     [rsp+28h],rbx
    mov     [rsp+30h],r14
    mov     [rsp+38h],r12
    jmp     L2
L10:
    mov     rax,[rsp+0E8h]
    lea     rcx,[k5]
    mov     rdx,[rsp+0E0h]
    mov     rdi,rax
    mov     esi,4
    mov     r8,rcx
    mov     rcx,rdx
    mov     edx,4
    call    fn4
    mov     rax,[rsp+0E8h]
    mov     rcx,[rsp+0E0h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rcx
    jmp     L2
L11:
    lea     rax,[k7]
    mov     rdi,[rsp+20h]
    mov     esi,4
    mov     edx,4
    mov     rcx,[rsp+38h]
    mov     r8,rax
    call    fn4
    mov     r10,[rsp+28h]
    mov     [rsp+0E0h],r10
    mov     r10,[rsp+38h]
    mov     [rsp+0E8h],r10
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+10h]
    call    fn9
    jmp     L7
L12:
    mov     r10,[rsp+40h]
    mov     [rsp+0E0h],r10
    lea     rax,[k10]
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,4
    mov     r8,[rsp+38h]
    mov     r9,rax
    call    fn11
    mov     rax,[rsp+38h]
    imul    rax,4
    mov     r11,[rsp+28h]
    mov     [rsp],r11
    mov     [rsp+8],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFEB8h
    call    ryo_h_Memcpy
    jmp     L8
L13:
    lea     rdi,[rsp+150h]
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
    pop     rcx
    lea     rdx,[rsp+150h]
    lea     rsp,[rdx-1A0h]
    mov     r11,[rdx-18h]
    mov     [rsp],r11
    movzx   r11d,byte ptr [rdx-101h]
    mov     [rsp+8],r11
    mov     r11,[rdx-58h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-100h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-78h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-120h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-118h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-38h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-30h]
    mov     [rsp+48h],r11
    mov     [rdx-10h],rbx
    mov     [rdx-20h],r12
    mov     [rdx-30h],r13
    mov     [rdx-40h],r14
    mov     [rdx-50h],r15
    mov     [rdx-60h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-70h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-68h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-100h],r11
    mov     r11,[rsp]
    mov     [rdx-140h],r11
    mov     r11,[rsp+8]
    mov     [rdx-138h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-118h],r11
    lea     rsp,[rsp+50h]
    jmp     L2
L16:
    ret
L17:
    ret

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,0Dh
    jb      L0
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
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[rsp+30h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,9
    jb      L0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,3
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,5
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,2
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,3
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,4
    mov     edx,5
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,7
    mov     edx,8
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,1
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,5
    mov     edx,7
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,0
    mov     edx,1
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,2
    mov     edx,4
    mov     rcx,r12
    call    fn0
    mov     rdi,rbx
    mov     esi,3
    mov     edx,5
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
    mov     edx,6
    mov     rcx,r12
    call    fn0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[rsp+30h]
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
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,rbx
    call    fn0
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
    mov     eax,0
    jmp     L1
L0:
    lea     r13,[rsp+10h]
    jmp     L2
L1:
    lea     rcx,[k3]
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    fn4
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L2:
    lea     rax,[k5]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn6
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    add     rsp,68h
    ret
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
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
    lea     rax,[k0]
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
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
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
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

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,208h
    mov     [rsp+100h],rbx
    mov     [rsp+0F0h],r12
    mov     [rsp+0E0h],r13
    mov     [rsp+0D0h],r14
    mov     [rsp+0C0h],r15
    mov     [rsp+0B0h],rbp
    mov     rax,[rsp+210h]
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+80h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     r14,r8
    mov     [rsp+68h],r9
L0:
    mov     rax,[rsp+0A0h]
    mov     [rsp+140h],rax
    mov     rbp,[rsp+0A8h]
    call    fn0
    cmp     rax,rbp
    jb      L1
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8,[rsp+70h]
    call    qword ptr [fn1.slot]
    jmp     L9
L1:
    cmp     r14d,0
    jne     L2
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8d,1
    mov     r9,[rsp+70h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
    jmp     L9
L2:
    mov     r11,r14
    sub     r11d,1
    mov     [rsp+60h],r11
    mov     rax,[rsp+0A0h]
    mov     [rsp+138h],rax
    mov     rcx,[rsp+0A8h]
    mov     [rsp+140h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+70h]
    call    fn3
    mov     [rsp+20h],rax
    mov     r11,[rsp+0A0h]
    mov     rax,[rsp+0A8h]
    mov     r11,[rsp+20h]
    cmp     r11,rax
    jae     L17
    mov     rcx,[rsp+0A0h]
    mov     r10,[rsp+20h]
    lea     rcx,[rcx+r10*8]
    mov     [rsp+130h],rcx
    mov     [rsp+138h],rcx
    mov     rcx,[rcx]
    mov     [rsp+140h],rcx
    call    fn6
    mov     rcx,rax
    jmp     L10
L3:
    mov     r10,[rsp+58h]
    mov     [rsp+138h],r10
    mov     r11,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     r11,[rsp+28h]
    cmp     r11,rdx
    jae     L18
    mov     rsi,[rsp+0A0h]
    mov     r10,[rsp+28h]
    lea     rsi,[rsi+r10*8]
    mov     [rsp+120h],rsi
    mov     rdi,[rsp+138h]
    mov     [rsp+128h],rdi
    mov     [rsp+130h],rsi
    mov     rdx,rsi
    mov     rsi,rdi
    mov     rdi,[rsp+30h]
    call    fn9
    mov     rsi,rax
    mov     rdi,rsi
    xor     edi,1
    cmp     sil,1
    jne     L4
    jmp     L5
L4:
    mov     rbp,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r11,[rsp+40h]
    mov     [rsp+98h],r11
    mov     r13,[rsp+28h]
    mov     esi,0
    mov     r11,[rsp+48h]
    mov     [rsp+90h],r11
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+58h]
    jmp     L7
L5:
    mov     rbp,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r13,[rsp+28h]
    mov     r12,[rsp+48h]
    mov     rbx,[rsp+50h]
    mov     r11,[rsp+58h]
    mov     [rsp+88h],r11
    jmp     L6
L6:
    mov     rsi,[rsp+0A0h]
    mov     [rsp+130h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+138h],rdi
    mov     [rsp],rbp
    mov     rdx,r14
    mov     rcx,r15
    mov     r8,r13
    mov     r9d,0
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    movzx   r9d,r9b
    call    fn10
    mov     rsi,rax
    mov     [rsp+138h],rsi
    cmp     rsi,0
    sete    dil
    mov     [rsp+98h],r15
    mov     [rsp+90h],r12
    mov     r12,[rsp+88h]
L7:
    test    dil,dil
    je      L8
    mov     rdi,[rsp+0A0h]
    mov     [rsp+128h],rdi
    mov     r15,[rsp+0A8h]
    mov     [rsp+130h],r15
    mov     [rsp+118h],rbp
    lea     r8,[rsp+118h]
    mov     [rsp+120h],r8
    mov     [rsp],r8
    mov     rsi,r15
    mov     rdx,r14
    mov     rcx,[rsp+98h]
    mov     r8,r13
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     rdi,rax
    mov     [rsp+138h],rdi
    mov     [rsp+130h],r15
    cmp     r15,rdi
    jb      L19
    jmp     L15
L8:
    lea     rdi,[k12]
    lea     r8,[rsp+110h]
    mov     r9,[rsp+0A0h]
    mov     r13,[rsp+0A8h]
    mov     rdx,r13
    mov     rcx,rsi
    mov     rsi,r9
    mov     r10,rdi
    mov     rdi,r8
    mov     r8,r10
    call    qword ptr [fn13.slot]
    mov     rsi,[rsp+110h]
    mov     [rsp+0A0h],rsi
    mov     rsi,[rsp+118h]
    mov     [rsp+0A8h],rsi
    mov     rsi,[rsp+120h]
    mov     [rsp+130h],rsi
    mov     rdi,[rsp+128h]
    mov     [rsp+138h],rdi
    mov     [rsp],rbp
    mov     rdx,r14
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+90h]
    mov     r9,rbx
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    mov     r8d,r8d
    call    fn14
    mov     [rsp+80h],r14
    mov     r11,[rsp+98h]
    mov     [rsp+78h],r11
    mov     [rsp+70h],rbp
    mov     r14,[rsp+90h]
    mov     [rsp+68h],r12
    jmp     L0
L9:
    mov     rbx,[rsp+100h]
    mov     r12,[rsp+0F0h]
    mov     r13,[rsp+0E0h]
    mov     r14,[rsp+0D0h]
    mov     r15,[rsp+0C0h]
    mov     rbp,[rsp+0B0h]
    add     rsp,208h
    ret
L10:
    lea     rsi,[rsp+140h]
    mov     [rsp+128h],rsi
    mov     [rsp+130h],rsi
    mov     [rsp+138h],rsi
    test    cl,cl
    jne     L13
    jmp     L14
L11:
    mov     rdi,[rsp+58h]
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
    lea     r11,[L12]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L12:
    .long   L16
    .long   L3
    .long   L20
L13:
    mov     rcx,[rsp+138h]
    mov     r11,[rsp+68h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+48h],r11
    mov     [rsp+50h],rcx
    jmp     L11
L14:
    mov     r11,[rsp+68h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+48h],r11
    mov     qword ptr [rsp+50h],0
    jmp     L11
L15:
    mov     rcx,[rsp+130h]
    mov     rsi,[rsp+138h]
    sub     rcx,rsi
    mov     [rsp+128h],rcx
    mov     rdi,[rsp+0A0h]
    mov     r8,[rsp+0A8h]
    mov     [rsp+110h],r8
    lea     rdi,[rdi+rsi*8]
    mov     [rsp+118h],rdi
    mov     [rsp+120h],rcx
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],rcx
    mov     [rsp+80h],r14
    mov     r11,[rsp+98h]
    mov     [rsp+78h],r11
    mov     [rsp+70h],rbp
    mov     r14,[rsp+90h]
    mov     qword ptr [rsp+68h],0
    jmp     L0
L16:
    mov     rbp,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r13,[rsp+28h]
    mov     r12,[rsp+48h]
    mov     rbx,[rsp+50h]
    mov     r11,[rsp+58h]
    mov     [rsp+88h],r11
    jmp     L6
L17:
    lea     rcx,[k4]
    mov     rdi,[rsp+20h]
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [sym5]
    ud2
L18:
    lea     rax,[k7]
    mov     rdi,[rsp+28h]
    mov     rsi,rdx
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L19:
    lea     rax,[k15]
    mov     rcx,[rsp+138h]
    mov     rdx,[rsp+130h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rcx,rax
    call    qword ptr [sym16]
    ud2
L20:
    ud2
  ; OSR entries
    lea     r11,[L21]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L21:
    .long   L22
    .long   L23
    .long   L24
L22:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-240h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-8]
    mov     [rsp+38h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+28h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     r11,[rsp]
    mov     [rdx-180h],r11
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-198h],r11
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L0
L23:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-250h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-8]
    mov     [rsp+48h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-178h],r11
    mov     rbp,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    mov     rbx,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L6
L24:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-250h]
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
    mov     r11,[rdx-120h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+40h],r11
    mov     r11,[rdx-8]
    mov     [rsp+48h],r11
    mov     [rdx-100h],rbx
    mov     [rdx-110h],r12
    mov     [rdx-120h],r13
    mov     [rdx-130h],r14
    mov     [rdx-140h],r15
    mov     [rdx-150h],rbp
    mov     r11,[rsp+38h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-158h],r11
    mov     r11,[rsp]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B0h],r11
    lea     rsp,[rsp+50h]
    jmp     L11

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    fn0
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
    mov     [rsp+0B8h],rdx
    mov     [rsp+0B0h],r8
    mov     [rsp+0A8h],r9
    mov     r11,[rsp+280h]
    mov     [rsp+0A0h],r11
    cmp     rcx,rsi
    jb      L18
    cmp     rsi,[rsp+0B0h]
    jbe     L18
    jmp     L11
L0:
    mov     r10,[rsp+68h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+270h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
L1:
    mov     rcx,[rsp+178h]
    cmp     rcx,rbp
    jb      L3
    jmp     L2
L2:
    mov     rcx,[rsp+98h]
    mov     rbx,[rsp+70h]
    mov     rbp,[rsp+78h]
    mov     rax,[rsp+80h]
    mov     r9,[rsp+88h]
    mov     r8,[rsp+90h]
    jmp     L4
L3:
    lea     rbx,[rsp+170h]
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    jmp     L1
L4:
    mov     [rsp+100h],r13
    lea     rdx,[r12+r13*8]
    mov     [rsp+0E8h],r15
    mov     [rsp+0C0h],rcx
    mov     [rsp+0C8h],rbp
    mov     rbp,rbx
    mov     rbx,rdx
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],r9
    mov     [rsp+0E0h],r8
L5:
    mov     rax,[rsp+178h]
    cmp     rax,rbx
    jae     L6
    lea     r15,[rsp+170h]
    mov     rax,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,[rsp+0E8h]
    call    fn1
    mov     [rsp+106h],al
    mov     rdi,r15
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L5
L6:
    cmp     r13,[rsp+0C0h]
    jne     L7
    call    qword ptr [fn11.slot]
    jmp     L13
L7:
    lea     rcx,[rsp+170h]
    mov     [rsp+100h],rcx
    mov     rdi,rcx
    mov     rsi,rbp
    movzx   esi,sil
    call    fn2
    mov     rcx,rax
    mov     r11,[rsp+0C0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],r12
    mov     r11,[rsp+0E8h]
    mov     [rsp+58h],r11
    mov     [rsp+50h],r14
    mov     r11,[rsp+0C0h]
    mov     [rsp+48h],r11
    mov     [rsp+40h],rbp
    mov     [rsp+20h],rcx
    mov     r11,[rsp+0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+0D8h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0E0h]
    mov     [rsp+38h],r11
    jmp     L0
L8:
    jmp     L14
L9:
    mov     r10,[rsp+0D8h]
    mov     [rsp+100h],r10
    mov     rbx,[rsp+180h]
    jmp     L15
L10:
    cmp     r12,r13
    jb      L17
    jmp     L16
L11:
    mov     r10,[rsp+0B0h]
    lea     rcx,[rdi+r10*8]
    mov     r11,[rsp+0B8h]
    lea     rdx,[r11+rsi*8]
    mov     r10,[rsp+0B8h]
    mov     [rsp+170h],r10
    mov     [rsp+178h],rdi
    mov     qword ptr [rsp+180h],0
    mov     [rsp+188h],rdx
    mov     r11,[rsp+0B0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rcx
    mov     r11,[rsp+0A0h]
    mov     [rsp+50h],r11
    mov     [rsp+48h],rsi
    mov     r11,[rsp+0A8h]
    mov     [rsp+40h],r11
    mov     qword ptr [rsp+20h],0
    mov     [rsp+28h],rdi
    mov     r11,[rsp+0B8h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0B8h]
    mov     [rsp+38h],r11
    jmp     L0
L12:
    mov     rcx,[rsp+100h]
    mov     r11,[rsp+60h]
    lea     rcx,[r11+rcx*8]
    mov     rbp,rcx
    mov     r15,[rsp+58h]
    mov     r14,[rsp+50h]
    mov     r13,[rsp+68h]
    mov     r12,[rsp+60h]
    mov     r11,[rsp+48h]
    mov     [rsp+98h],r11
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
L13:
    cmp     al,1
    jne     L8
    jmp     L9
L14:
    mov     r10,[rsp+0E8h]
    mov     [rsp+100h],r10
    lea     rax,[k13]
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+0C8h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     rdi,[rsp+0C8h]
    mov     rsi,[rsp+0E8h]
    mov     edx,8
    call    ryo_hr_Memcpy
    jmp     L9
L15:
    lea     rax,[k15]
    mov     rdi,[rsp+0D8h]
    mov     rsi,[rsp+0D0h]
    mov     edx,8
    mov     ecx,4
    mov     r8,rbx
    mov     r9,rax
    call    fn14
    imul    rbx,8
    mov     r11,[rsp+0D0h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rbx
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFDA0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+180h]
    mov     r11,[rsp+0C0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+100h],rax
    mov     r12d,0
    mov     r13,rax
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+0D0h]
    jmp     L10
L16:
    mov     rax,[rsp+180h]
    mov     rbx,[rsp+160h]
    mov     r12,[rsp+150h]
    mov     r13,[rsp+140h]
    mov     r14,[rsp+130h]
    mov     r15,[rsp+120h]
    mov     rbp,[rsp+110h]
    add     rsp,278h
    ret
L17:
    lea     rax,[k17]
    mov     rdi,r12
    mov     esi,1
    mov     rdx,rax
    call    fn18
    mov     r11,r12
    add     r11,1
    mov     [rsp+0F0h],r11
    mov     [rsp+100h],r12
    mov     rax,r14
    sub     rax,1
    sub     rax,r12
    lea     rbx,[r15+rax*8]
    mov     rax,[rsp+180h]
    add     rax,r12
    lea     r12,[rbp+rax*8]
    lea     rax,[k19]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+0F0h]
    jmp     L10
L18:
    lea     rdi,[rsp+270h]
    call    ryo_h_Abort
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
    .long   L25
L20:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-208h],r11
    mov     r11,[rsp+8]
    mov     [rdx-210h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-238h],r11
    lea     rsp,[rsp+70h]
    jmp     L0
L21:
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1E0h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L1
L22:
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-190h],r11
    mov     rbx,[rsp]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    lea     rsp,[rsp+70h]
    jmp     L5
L23:
    ret
L24:
    ret
L25:
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
    mov     r12,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L10

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,278h
    mov     [rsp+160h],rbx
    mov     [rsp+150h],r12
    mov     [rsp+140h],r13
    mov     [rsp+130h],r14
    mov     [rsp+120h],r15
    mov     [rsp+110h],rbp
    mov     [rsp+0B8h],rdx
    mov     [rsp+0B0h],r8
    mov     [rsp+0A8h],r9
    mov     r11,[rsp+280h]
    mov     [rsp+0A0h],r11
    cmp     rcx,rsi
    jb      L18
    cmp     rsi,[rsp+0B0h]
    jbe     L18
    jmp     L11
L0:
    mov     r10,[rsp+68h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+270h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
L1:
    mov     rcx,[rsp+178h]
    cmp     rcx,rbp
    jb      L3
    jmp     L2
L2:
    mov     rcx,[rsp+98h]
    mov     rbx,[rsp+70h]
    mov     rbp,[rsp+78h]
    mov     rax,[rsp+80h]
    mov     r9,[rsp+88h]
    mov     r8,[rsp+90h]
    jmp     L4
L3:
    lea     rbx,[rsp+170h]
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    mov     rcx,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rcx
    mov     rdx,r15
    call    fn1
    mov     rcx,rax
    mov     [rsp+106h],cl
    mov     rdi,rbx
    mov     rsi,rcx
    movzx   esi,sil
    call    fn2
    jmp     L1
L4:
    mov     [rsp+100h],r13
    lea     rdx,[r12+r13*8]
    mov     [rsp+0E8h],r15
    mov     [rsp+0C0h],rcx
    mov     [rsp+0C8h],rbp
    mov     rbp,rbx
    mov     rbx,rdx
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],r9
    mov     [rsp+0E0h],r8
L5:
    mov     rax,[rsp+178h]
    cmp     rax,rbx
    jae     L6
    lea     r15,[rsp+170h]
    mov     rax,[rsp+178h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,[rsp+0E8h]
    call    fn1
    mov     [rsp+106h],al
    mov     rdi,r15
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L5
L6:
    cmp     r13,[rsp+0C0h]
    jne     L7
    call    qword ptr [fn11.slot]
    jmp     L13
L7:
    lea     rcx,[rsp+170h]
    mov     [rsp+100h],rcx
    mov     rdi,rcx
    mov     rsi,rbp
    movzx   esi,sil
    call    fn2
    mov     rcx,rax
    mov     r11,[rsp+0C0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],r12
    mov     r11,[rsp+0E8h]
    mov     [rsp+58h],r11
    mov     [rsp+50h],r14
    mov     r11,[rsp+0C0h]
    mov     [rsp+48h],r11
    mov     [rsp+40h],rbp
    mov     [rsp+20h],rcx
    mov     r11,[rsp+0D0h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+0D8h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0E0h]
    mov     [rsp+38h],r11
    jmp     L0
L8:
    jmp     L14
L9:
    mov     r10,[rsp+0D8h]
    mov     [rsp+100h],r10
    mov     rbx,[rsp+180h]
    jmp     L15
L10:
    cmp     r12,r13
    jb      L17
    jmp     L16
L11:
    mov     r10,[rsp+0B0h]
    lea     rcx,[rdi+r10*8]
    mov     r11,[rsp+0B8h]
    lea     rdx,[r11+rsi*8]
    mov     r10,[rsp+0B8h]
    mov     [rsp+170h],r10
    mov     [rsp+178h],rdi
    mov     qword ptr [rsp+180h],0
    mov     [rsp+188h],rdx
    mov     r11,[rsp+0B0h]
    mov     [rsp+68h],r11
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rcx
    mov     r11,[rsp+0A0h]
    mov     [rsp+50h],r11
    mov     [rsp+48h],rsi
    mov     r11,[rsp+0A8h]
    mov     [rsp+40h],r11
    mov     qword ptr [rsp+20h],0
    mov     [rsp+28h],rdi
    mov     r11,[rsp+0B8h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+0B8h]
    mov     [rsp+38h],r11
    jmp     L0
L12:
    mov     rcx,[rsp+100h]
    mov     r11,[rsp+60h]
    lea     rcx,[r11+rcx*8]
    mov     rbp,rcx
    mov     r15,[rsp+58h]
    mov     r14,[rsp+50h]
    mov     r13,[rsp+68h]
    mov     r12,[rsp+60h]
    mov     r11,[rsp+48h]
    mov     [rsp+98h],r11
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
L13:
    cmp     al,1
    jne     L8
    jmp     L9
L14:
    mov     r10,[rsp+0E8h]
    mov     [rsp+100h],r10
    lea     rax,[k13]
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+0C8h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     rdi,[rsp+0C8h]
    mov     rsi,[rsp+0E8h]
    mov     edx,8
    call    ryo_hr_Memcpy
    jmp     L9
L15:
    lea     rax,[k15]
    mov     rdi,[rsp+0D8h]
    mov     rsi,[rsp+0D0h]
    mov     edx,8
    mov     ecx,4
    mov     r8,rbx
    mov     r9,rax
    call    fn14
    imul    rbx,8
    mov     r11,[rsp+0D0h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rbx
    lea     rdi,[rsp+270h]
    mov     esi,0FFFFFDA0h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFDA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+180h]
    mov     r11,[rsp+0C0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+100h],rax
    mov     r12d,0
    mov     r13,rax
    mov     r14,[rsp+0C0h]
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+0D0h]
    jmp     L10
L16:
    mov     rax,[rsp+180h]
    mov     rbx,[rsp+160h]
    mov     r12,[rsp+150h]
    mov     r13,[rsp+140h]
    mov     r14,[rsp+130h]
    mov     r15,[rsp+120h]
    mov     rbp,[rsp+110h]
    add     rsp,278h
    ret
L17:
    lea     rax,[k17]
    mov     rdi,r12
    mov     esi,1
    mov     rdx,rax
    call    fn18
    mov     r11,r12
    add     r11,1
    mov     [rsp+0F0h],r11
    mov     [rsp+100h],r12
    mov     rax,r14
    sub     rax,1
    sub     rax,r12
    lea     rbx,[r15+rax*8]
    mov     rax,[rsp+180h]
    add     rax,r12
    lea     r12,[rbp+rax*8]
    lea     rax,[k19]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,8
    call    ryo_hr_Memcpy
    mov     r12,[rsp+0F0h]
    jmp     L10
L18:
    lea     rdi,[rsp+270h]
    call    ryo_h_Abort
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
    .long   L25
L20:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2E0h]
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-208h],r11
    mov     r11,[rsp+8]
    mov     [rdx-210h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-250h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-248h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-238h],r11
    lea     rsp,[rsp+70h]
    jmp     L0
L21:
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-200h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1F8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1F0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1E0h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+70h]
    jmp     L1
L22:
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
    mov     [rdx-270h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-268h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-188h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-198h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-190h],r11
    mov     rbx,[rsp]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    lea     rsp,[rsp+70h]
    jmp     L5
L23:
    ret
L24:
    ret
L25:
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
    mov     r12,[rsp]
    mov     r13,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r15,[rsp+18h]
    mov     rbp,[rsp+20h]
    lea     rsp,[rsp+40h]
    jmp     L10

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    cmp     r12,0
    jne     L0
    mov     r13d,0
    jmp     L1
L0:
    cmp     rdx,r12
    jae     L2
    lea     rax,[k0]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rcx,rdx
    mov     edx,0
    mov     r8,rax
    call    fn1
    lea     rax,[k2]
    lea     rcx,[rsp+30h]
    mov     rdi,rcx
    mov     rsi,rbx
    mov     rdx,r12
    mov     ecx,1
    mov     r8,rax
    call    fn3
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     rcx,[rsp+40h]
    mov     [rsp+20h],rcx
    mov     rcx,[rsp+48h]
    mov     [rsp+28h],rcx
    cmp     rax,0
    jbe     L3
    mov     rcx,[rsp+10h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rcx
    mov     rdx,[sym6]
    mov     rsi,[rsp+20h]
    mov     rdi,[rsp+28h]
    mov     rax,rdx
    mov     rdx,rcx
    mov     rcx,r13
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    call    rax
    mov     r13,rax
    cmp     r13,r12
    jae     L4
    lea     rcx,[k7]
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,0
    mov     r8,rcx
    mov     rcx,r13
    call    fn1
L1:
    mov     rax,r13
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    add     rsp,88h
    ret
L2:
    lea     rdi,[rsp+80h]
    call    ryo_h_Abort
    ud2
L3:
    lea     rcx,[k4]
    mov     edi,0
    mov     rsi,rax
    mov     rdx,rcx
    call    qword ptr [sym5]
    ud2
L4:
    lea     rdi,[rsp+80h]
    call    ryo_h_Abort
    ud2

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0D8h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+78h],rdi
    cmp     rsi,0
    jne     L0
    mov     eax,0
    jmp     L6
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
    mov     rax,[rsp+78h]
    mov     rcx,rax
    lea     rcx,[rcx+4]
    lea     rdx,[rsp+5Ch]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     [rsp+48h],rcx
    mov     qword ptr [rsp+50h],0
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     qword ptr [rsp+10h],1
    mov     rcx,rsi
    sub     rcx,1
    mov     [rsp+18h],rcx
    lea     rax,[rax+rcx*4]
    mov     rbx,rax
    mov     r12,rsi
L1:
    mov     rax,[rsp+48h]
    mov     [rsp+18h],rax
    cmp     rax,rbx
    jae     L2
    mov     byte ptr [rsp+5Ah],1
    lea     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rcx,[rsp+38h]
    mov     [rsp+10h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    lea     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rcx,[rsp+38h]
    mov     [rsp+10h],rcx
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L1
L2:
    mov     rax,[rsp+78h]
    lea     rax,[rax+r12*4]
    mov     [rsp+18h],rax
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+10h],rax
    mov     rcx,[rsp+18h]
    cmp     rax,rcx
    sete    al
    mov     [rsp+5Bh],al
    test    al,al
    je      L4
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    jmp     L5
L4:
    mov     rax,[rsp+48h]
    mov     [rsp+10h],rax
L5:
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    lea     rax,[rsp+60h]
    mov     [rsp+10h],rax
    lea     rcx,[rsp+38h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    movzx   eax,byte ptr [rsp+5Bh]
    test    al,al
    je      L3
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     r11,[rsp+40h]
    mov     rax,[rsp+50h]
L6:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    add     rsp,0D8h
    ret
    mov     rbx,rax
    jmp     L9
    mov     rbx,rax
    jmp     L9
    mov     rbx,rax
    jmp     L9
L7:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L8:
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn4.slot]
    jmp     L7
    call    qword ptr [sym5]
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
L11:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0F0h]
    mov     r11,[rdx-0A0h]
    mov     [rsp],r11
    mov     r11,[rdx-50h]
    mov     [rsp+8],r11
    mov     r11,[rdx-0B0h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+18h],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     r11,[rsp+10h]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0B8h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    lea     rsp,[rsp+20h]
    jmp     L1
L12:
    pop     rcx
    lea     rdx,[rsp+0D0h]
    lea     rsp,[rdx-0E0h]
    mov     r11,[rdx-0B0h]
    mov     [rsp],r11
    mov     r11,[rdx-0A8h]
    mov     [rsp+8],r11
    mov     [rdx-0A0h],rbx
    mov     [rdx-0B0h],r12
    mov     r11,[rsp]
    mov     [rdx-0C0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0B8h],r11
    lea     rsp,[rsp+10h]
    jmp     L3
L13:
    ret
L14:
    ret
L15:
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     rax,[rbx]
    mov     rcx,[r12+10h]
    mov     rdx,[rbx+8]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    mov     r13,rax
    mov     rax,[rbx+10h]
    mov     rax,[rax]
    mov     rcx,[r12+18h]
    lea     rbx,[rax+rcx*4]
    mov     r14,[r12]
    mov     eax,0
    jmp     L1
L0:
    mov     r15,[r12+10h]
    jmp     L2
L1:
    lea     rcx,[k1]
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    fn2
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L2:
    lea     rax,[k3]
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn4
    mov     rdi,rbx
    mov     rsi,r15
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rax,[r12+10h]
    mov     [r12],rax
    movzx   r13d,r13b
    mov     rcx,[r12+18h]
    add     rcx,r13
    mov     [r12+18h],rcx
    lea     rax,[rax+4]
    mov     [r12+10h],rax
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,178h
    mov     [rsp+0A0h],rbx
    mov     [rsp+90h],r12
    mov     [rsp+80h],r13
    mov     [rsp+70h],r14
    mov     [rsp+60h],r15
    mov     [rsp+50h],rbp
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     rbx,r8
    mov     r12,rcx
    mov     r13,rdx
L0:
    mov     rax,[rsp+10h]
    mov     [rsp+40h],rax
    mov     r14,[rsp+18h]
    call    fn0
    cmp     rax,r14
    jb      L1
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,rbx
    call    qword ptr [fn1.slot]
    jmp     L6
L1:
    cmp     r12d,0
    jne     L2
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,rbx
    call    qword ptr [fn2.slot]
    jmp     L6
L2:
    sub     r12d,1
    mov     rax,[rsp+10h]
    mov     [rsp+40h],rax
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,rbx
    call    qword ptr [fn3.slot]
    mov     r14,rax
    mov     rdi,r13
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
    .long   L5
    .long   L4
    .long   L11
L4:
    mov     r11,[rsp+10h]
    mov     rax,[rsp+18h]
    cmp     r14,rax
    jae     L8
    mov     rcx,[rsp+10h]
    lea     rcx,[rcx+r14*4]
    mov     [rsp+30h],rcx
    mov     [rsp+38h],r13
    mov     [rsp+40h],rcx
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,rcx
    call    fn6
    mov     rcx,rax
    test    cl,cl
    jne     L5
    mov     rcx,[rsp+10h]
    mov     [rsp+30h],rcx
    mov     r15,[rsp+18h]
    mov     [rsp+38h],r15
    mov     [rsp+0D0h],rbx
    lea     rdx,[rsp+0D0h]
    mov     [rsp+28h],rdx
    mov     rdi,rcx
    mov     rsi,r15
    mov     rcx,rdx
    mov     rdx,r14
    call    qword ptr [fn7.slot]
    mov     rcx,rax
    mov     [rsp+40h],rcx
    add     rcx,1
    mov     [rsp+38h],r15
    cmp     r15,rcx
    jb      L10
    jmp     L7
L5:
    mov     r15,[rsp+10h]
    mov     [rsp+38h],r15
    mov     rbp,[rsp+18h]
    mov     [rsp+40h],rbp
    mov     rdi,r15
    mov     rsi,rbp
    mov     rdx,r14
    mov     rcx,rbx
    call    qword ptr [fn8.slot]
    mov     rdx,rax
    mov     [rsp+30h],r15
    mov     [rsp+38h],rbp
    mov     [rsp+40h],rbp
    lea     rsi,[k9]
    lea     rdi,[rsp+0B8h]
    mov     rcx,rdx
    mov     rdx,rbp
    mov     r8,rsi
    mov     rsi,r15
    call    fn10
    mov     rdx,[rsp+0B8h]
    mov     [rsp+38h],rdx
    mov     rdx,[rsp+0C0h]
    mov     [rsp+40h],rdx
    mov     rdx,[rsp+0C8h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp+30h],rsi
    lea     rdi,[k11]
    lea     r8,[rsp+0A8h]
    mov     ecx,1
    mov     r10,rdi
    mov     rdi,r8
    mov     r8,r10
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    fn10
    mov     rdx,[rsp+0A8h]
    mov     [rsp+0C8h],rdx
    mov     rdx,[rsp+0B0h]
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+10h],rsi
    mov     rsi,[rsp+0C0h]
    mov     [rsp+18h],rsi
    cmp     rdx,0
    jbe     L9
    mov     rsi,[rsp+0C8h]
    mov     [rsp+0C0h],rsi
    mov     rsi,[rsp+38h]
    mov     rdi,[rsp+40h]
    mov     rdx,r13
    mov     rcx,r12
    mov     r8,rbx
    mov     r10,rdi
    mov     rdi,rsi
    mov     rsi,r10
    mov     ecx,ecx
    call    fn15
    mov     rsi,[rsp+0C0h]
    mov     r13,rsi
    jmp     L0
L6:
    mov     rbx,[rsp+0A0h]
    mov     r12,[rsp+90h]
    mov     r13,[rsp+80h]
    mov     r14,[rsp+70h]
    mov     r15,[rsp+60h]
    mov     rbp,[rsp+50h]
    add     rsp,178h
    ret
L7:
    mov     rsi,[rsp+38h]
    sub     rsi,rcx
    mov     [rsp+30h],rsi
    mov     rdi,[rsp+10h]
    mov     [rsp+0C0h],rdi
    mov     r8,[rsp+18h]
    mov     [rsp+0C8h],r8
    mov     [rsp+0B8h],rdi
    lea     rdi,[rdi+rcx*4]
    mov     [rsp+0B0h],rdi
    mov     [rsp+0D0h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     r13d,0
    jmp     L0
L8:
    lea     rsi,[k4]
    mov     rdi,r14
    mov     rdx,rsi
    mov     rsi,rax
    call    qword ptr [sym5]
    ud2
L9:
    lea     rax,[k13]
    mov     edi,0
    mov     rsi,rdx
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L10:
    lea     rax,[k16]
    mov     rdx,[rsp+38h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rcx,rax
    call    qword ptr [sym17]
    ud2
L11:
    ud2
  ; OSR entries
    lea     r11,[L12]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L12:
    .long   L13
L13:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1C0h]
    mov     r11,[rdx-28h]
    mov     [rsp],r11
    mov     r11d,[rdx-1Ch]
    mov     [rsp+8],r11
    mov     r11,[rdx-18h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-98h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-90h]
    mov     [rsp+20h],r11
    mov     r11,[rdx-88h]
    mov     [rsp+28h],r11
    mov     r11,[rdx-80h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-10h]
    mov     [rsp+38h],r11
    mov     r11,[rdx-8]
    mov     [rsp+40h],r11
    mov     [rdx-0D0h],rbx
    mov     [rdx-0E0h],r12
    mov     [rdx-0F0h],r13
    mov     [rdx-100h],r14
    mov     [rdx-110h],r15
    mov     [rdx-120h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-158h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+50h]
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

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     eax,eax
    add     rsp,18h
    ret

fn main::{closure#1}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     ebx,[rsi]
    mov     rdi,rbx
    mov     esi,3E8h
    call    ryo_hr_RemUW32
    mov     rdx,rbx
    mov     eax,eax
    mov     edx,edx
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret

fn main::{closure#2}
    sub     rsp,18h
    mov     eax,[rsi]
    mov     eax,eax
    add     rsp,18h
    ret

fn merge_sort
    sub     rsp,128h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r12,10h
    ja      L3
    mov     edi,1
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    mov     [rsp+0A0h],rax
    mov     [rsp+0A8h],rdx
    mov     r14,rbx
    mov     r15,r12
L0:
    lea     rax,[rsp+0A0h]
    mov     rdi,rax
    call    fn1
    mov     rbp,rdx
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
    .long   L2
    .long   L8
L2:
    cmp     rbp,0
    jbe     L0
    mov     rax,rbp
    sub     rax,1
    jb      L9
    cmp     rax,r15
    jae     L10
    lea     rcx,[r14+rax*4]
    mov     ecx,[rcx]
    cmp     rbp,r15
    jae     L11
    lea     rdx,[r14+rbp*4]
    mov     edx,[rdx]
    cmp     edx,ecx
    jae     L0
    mov     rcx,rbp
    sub     rcx,1
    jb      L12
    lea     rdx,[k10]
    mov     rdi,r14
    mov     rsi,r15
    mov     r8,rdx
    mov     rdx,rcx
    mov     rcx,rbp
    call    fn11
    mov     rcx,rbp
    sub     rcx,1
    jb      L13
    mov     rbp,rcx
    jmp     L2
L3:
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     r14,rax
    lea     rcx,[k16]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    call    qword ptr [fn17.slot]
    mov     rcx,rax
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rdx,r13
    call    fn18
    lea     rcx,[k19]
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    call    qword ptr [fn20.slot]
    mov     rcx,rax
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rdx,r13
    call    fn18
    mov     rdi,r13
    call    qword ptr [fn22.slot]
    mov     [rsp+18h],r14
    mov     [rsp+10h],r12
    mov     r12,r13
    mov     r13,rbx
    mov     ebx,0
L4:
    cmp     rbx,r14
    jae     L6
    mov     r11,[rsp+18h]
    cmp     r11,[rsp+10h]
    jae     L6
    cmp     rbx,[rsp+10h]
    jae     L14
    lea     rcx,[r13+rbx*4]
    mov     ecx,[rcx]
    mov     r11,[rsp+18h]
    cmp     r11,[rsp+10h]
    jae     L15
    mov     r10,[rsp+18h]
    lea     rdx,[r13+r10*4]
    mov     edx,[rdx]
    cmp     edx,ecx
    jb      L5
    cmp     rbx,[rsp+10h]
    jae     L16
    lea     rcx,[r13+rbx*4]
    mov     ecx,[rcx]
    mov     rdi,r12
    mov     rsi,rcx
    mov     esi,esi
    call    fn29
    mov     rcx,rbx
    add     rcx,1
    jb      L17
    mov     rbx,rcx
    jmp     L4
L5:
    mov     r11,[rsp+18h]
    cmp     r11,[rsp+10h]
    jae     L18
    mov     r10,[rsp+18h]
    lea     rcx,[r13+r10*4]
    mov     ecx,[rcx]
    mov     rdi,r12
    mov     rsi,rcx
    mov     esi,esi
    call    fn29
    mov     rcx,[rsp+18h]
    add     rcx,1
    jb      L19
    mov     [rsp+18h],rcx
    jmp     L4
L6:
    lea     rcx,[k37]
    mov     rdi,r13
    mov     rsi,[rsp+10h]
    mov     rdx,rbx
    mov     r8,rcx
    mov     rcx,r14
    call    qword ptr [fn38.slot]
    mov     rcx,rax
    mov     rdi,r12
    mov     rsi,rcx
    call    qword ptr [fn39.slot]
    lea     rcx,[k40]
    mov     rdi,r13
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    qword ptr [fn41.slot]
    mov     rcx,rax
    mov     rdi,r12
    mov     rsi,rcx
    call    qword ptr [fn39.slot]
    mov     rdi,r12
    call    qword ptr [fn43.slot]
    mov     rcx,rax
    lea     rsi,[k44]
    mov     rdi,r13
    mov     r8,rsi
    mov     rsi,[rsp+10h]
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [fn45.slot]
L7:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,128h
    ret
L8:
    ud2
L9:
    lea     rcx,[k2]
    mov     rdi,rcx
    call    qword ptr [sym3]
    ud2
L10:
    lea     rcx,[k4]
    mov     rdi,rax
    mov     rsi,r15
    mov     rdx,rcx
    call    qword ptr [sym5]
    ud2
L11:
    lea     rax,[k6]
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L12:
    lea     rax,[k8]
    mov     rdi,rax
    call    qword ptr [sym3]
    ud2
L13:
    lea     rax,[k12]
    mov     rdi,rax
    call    qword ptr [sym3]
    ud2
L14:
    lea     rax,[k23]
    mov     rdi,rbx
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L15:
    lea     rax,[k25]
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L16:
    lea     rax,[k27]
    mov     rdi,rbx
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L17:
    lea     rax,[k30]
    mov     rdi,rax
    call    qword ptr [sym31]
    ud2
L18:
    lea     rax,[k32]
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,rax
    call    qword ptr [sym5]
    ud2
L19:
    lea     rax,[k35]
    mov     rdi,rax
    call    qword ptr [sym31]
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
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-390h]
    mov     r11,[rdx-10h]
    mov     [rsp],r11
    mov     r11,[rdx-8]
    mov     [rsp+8],r11
    mov     r11,[rdx-48h]
    mov     [rsp+10h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+18h],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+10h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-0F0h],r11
    mov     r14,[rsp]
    mov     r15,[rsp+8]
    lea     rsp,[rsp+270h]
    jmp     L0
L22:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-3A0h]
    mov     r11,[rdx-0B0h]
    mov     [rsp],r11
    mov     r11,[rdx-10h]
    mov     [rsp+8],r11
    mov     r11,[rdx-8]
    mov     [rsp+10h],r11
    mov     r11,[rdx-48h]
    mov     [rsp+18h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+20h],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+18h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0F0h],r11
    mov     rbp,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+280h]
    jmp     L2
L23:
    pop     rcx
    lea     rdx,[rsp+370h]
    lea     rsp,[rdx-3B0h]
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
    mov     r11,[rdx-48h]
    mov     [rsp+30h],r11
    mov     r11,[rdx-40h]
    mov     [rsp+38h],r11
    mov     [rdx-90h],rbx
    mov     [rdx-0A0h],r12
    mov     [rdx-0B0h],r13
    mov     [rdx-0C0h],r14
    mov     [rdx-0D0h],r15
    mov     [rdx-0E0h],rbp
    mov     r11,[rsp+30h]
    mov     [rdx-0F8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-0F0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-108h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-110h],r11
    mov     rbx,[rsp]
    mov     r14,[rsp+8]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+28h]
    lea     rsp,[rsp+290h]
    jmp     L4

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
    mov     rax,[rsp+48h]
    mov     [rsp+50h],rax
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
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
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
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [fn4.slot]
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

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     [rsp+10h],esi
    mov     [rsp+14h],edx
    mov     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     ecx,[rsp+24h]
    mov     rsi,rax
    mov     rdx,rcx
    mov     esi,esi
    mov     edx,edx
    call    qword ptr [fn0.slot]
    add     rsp,38h
    ret

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
    sub     rsp,18h
    mov     esi,esi
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+18h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     [rsp+18h],eax
    mov     [rsp+1Ch],edx
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     ecx,[rsp+14h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     esi,esi
    mov     edx,edx
    call    qword ptr [fn1.slot]
    mov     rbx,[rsp+20h]
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

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+18h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    mov     rdi,rbx
    mov     rsi,rax
    mov     esi,esi
    call    qword ptr [fn1.slot]
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
    mov     ecx,1
    jmp     L3
    mov     ecx,0
    jmp     L3
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
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

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    sub     rsp,18h
    call    qword ptr [fn0.slot]
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
    mov     rdi,rbx
    mov     rsi,r13
    call    fn0
    jmp     L3
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
    mov     rdi,r12
    mov     rsi,r13
    call    fn0
    mov     rcx,rax
    jmp     L6
L2:
    cmp     rbx,0
    je      L8
    jmp     L7
L3:
    test    al,al
    jne     L1
    jmp     L9
L4:
    jmp     L0
L5:
    cmp     r12,0
    je      L8
    jmp     L0
L6:
    test    cl,cl
    jne     L4
    jmp     L10
L7:
    mov     rdi,r12
    mov     rsi,r13
    call    fn0
    test    al,al
    jne     L5
    jmp     L10
    jmp     L11
L8:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,1BBh
    mov     edx,0
    mov     rcx,r15
    movzx   edx,dl
    call    qword ptr [sym3]
    ud2
L9:
    jmp     L8
    jmp     L11
L10:
    jmp     L8
L11:
    call    qword ptr [sym6]
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

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn std::ptr::swap::<u32>
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    lea     r13,[rsp+0Ch]
    lea     rax,[k0]
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     eax,0
    jmp     L1
L0:
    lea     r13,[rsp+0Ch]
    jmp     L2
L1:
    lea     rcx,[k2]
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    mov     r8,rcx
    mov     rcx,rax
    movzx   ecx,cl
    call    fn3
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,4
    call    ryo_hr_Memmove
    jmp     L0
L2:
    lea     rax,[k4]
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,4
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
  ; OSR entries
    lea     r11,[L3]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L3:
    .long   L4
L4:
    ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     rbx,rdi
    mov     r12,rdx
    mov     rax,[rbx]
    mov     rdi,rax
    call    fn0
    mov     [rsp+0Ch],eax
    lea     r13,[rsp+0Ch]
    mov     rax,[rbx]
    mov     rdi,rax
    mov     rsi,r12
    call    fn0
    mov     [rsp+18h],eax
    lea     rax,[rsp+18h]
    mov     rdi,r13
    mov     rsi,rax
    call    fn2
    movzx   eax,al
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    add     rsp,58h
    ret
    jmp     L0
L0:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
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

fn std::slice::Iter::<'_, u32>::make_slice
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,[rdi]
    mov     r12,[rdi+8]
    mov     r13,[rdi]
    jmp     L2
L0:
    jmp     L3
L1:
    mov     r14,rax
    jmp     L0
L2:
    lea     rcx,[k0]
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rcx
    call    fn1
    sub     r12,r13
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    jmp     L1
L3:
    lea     rax,[k5]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,r14
    mov     r8,rax
    call    fn6
    mov     rax,rbx
    mov     rdx,r14
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
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

fn std::slice::from_raw_parts::precondition_check
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rdi,rbx
    mov     rsi,rdx
    call    fn0
    jmp     L3
L0:
    cmp     r12,0
    je      L4
    jmp     L5
L1:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L2:
    cmp     rbx,0
    je      L7
    jmp     L0
L3:
    test    al,al
    jne     L2
    jmp     L8
L4:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L6
L5:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
L6:
    cmp     r13,rax
    jbe     L1
    jmp     L7
    jmp     L9
L7:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,22Fh
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [sym3]
    ud2
L8:
    jmp     L7
L9:
    call    qword ptr [sym4]
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
    .long   L17
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

fn std::slice::from_raw_parts_mut::precondition_check
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rdi,rbx
    mov     rsi,rdx
    call    fn0
    jmp     L3
L0:
    cmp     r12,0
    je      L4
    jmp     L5
L1:
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L2:
    cmp     rbx,0
    je      L7
    jmp     L0
L3:
    test    al,al
    jne     L2
    jmp     L8
L4:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L6
L5:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
L6:
    cmp     r13,rax
    jbe     L1
    jmp     L7
    jmp     L9
L7:
    lea     rax,[k1]
    mov     rdi,rax
    mov     esi,237h
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [sym3]
    ud2
L8:
    jmp     L7
L9:
    call    qword ptr [sym4]
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
    .long   L17
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

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],esi
    mov     [rsp+14h],edx
    mov     rax,[rdi+10h]
    mov     rcx,[rdi+8]
    lea     rax,[rax+rcx*8]
    mov     rcx,[rsp+10h]
    mov     [rax],rcx
    mov     rax,[rdi+8]
    add     rax,1
    mov     [rdi+8],rax
    add     rsp,28h
    ret

fn std::vec::Vec::<u32>::append_elements
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     rdi,rbx
    mov     rsi,r13
    call    fn0
    mov     rax,[rbx+10h]
    cmp     r13,0
    jbe     L0
    mov     rcx,[rbx+8]
    lea     r14,[rcx+rax*4]
    jmp     L1
L0:
    mov     rax,[rbx+10h]
    add     rax,r13
    mov     [rbx+10h],rax
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L1:
    lea     rax,[k1]
    mov     rdi,r12
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8,r13
    mov     r9,rax
    call    fn2
    mov     rax,r13
    imul    rax,4
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    ret

fn std::vec::Vec::<u32>::clear
    sub     rsp,18h
    mov     rax,[rdi+8]
    mov     rcx,[rdi+10h]
    mov     qword ptr [rdi+10h],0
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [sym0]
    add     rsp,18h
    ret

fn std::vec::Vec::<u32>::extend_from_slice
    sub     rsp,38h
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rsi
    jmp     L1
L0:
    add     rsp,38h
    ret
L1:
    mov     [rsp+8],rsi
    lea     rax,[rsi+rdx*4]
    mov     [rsp+10h],rax
    mov     rdx,rax
    call    qword ptr [fn0.slot]
    jmp     L0
  ; OSR entries
    lea     r11,[L2]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L2:
    .long   L3
L3:
    ret

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
    sub     rsp,18h
    mov     rax,[rdi+10h]
    mov     rcx,[rdi+8]
    lea     rax,[rax+rcx*4]
    mov     [rax],esi
    mov     rax,[rdi+8]
    add     rax,1
    mov     [rdi+8],rax
    add     rsp,18h
    ret

fn std::vec::Vec::<u32>::push
    sub     rsp,28h
    mov     esi,esi
    call    fn0
    mov     [rsp+8],rax
    add     rsp,28h
    ret

fn std::vec::Vec::<u32>::push_mut
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    jmp     L3
L0:
    mov     rdi,rbx
    call    qword ptr [fn0.slot]
L1:
    mov     rax,[rbx+8]
    lea     rax,[rax+r13*4]
    mov     [rax],r12d
    mov     rcx,r13
    add     rcx,1
    mov     [rbx+10h],rcx
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L2:
    cmp     r13,rax
    je      L0
    jmp     L1
L3:
    mov     rax,[rbx]
    jmp     L2
    jmp     L5
L4:
    mov     [rsp],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
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
    .long   L10
    .long   L11
L7:
    ret
L8:
    ret
L9:
    ret
L10:
    ret
L11:
    ret

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
    call    qword ptr [sym1]
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

