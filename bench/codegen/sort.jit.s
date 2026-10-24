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
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
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
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+8]
    mov     rcx,[rbx]
    mov     [rsp+20h],rcx
    mov     [rsp+28h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+8],rcx
    mov     rcx,[rsp+28h]
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+8]
    mov     rdx,[rsp+10h]
    mov     rdi,rax
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    qword ptr [fn0.slot]
    mov     r12,rax
    mov     rax,[rbx]
    mov     r13,rax
    add     r13,1
    jae     L1
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym2]
    jmp     L0
    mov     r14,rax
    jmp     L3
L0:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     [rbx],r13
    mov     rax,r12
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    add     rsp,78h
    ret
L2:
    mov     [rsp],r14
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L3:
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

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdx,rcx
    add     rsp,38h
    ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,78h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     [rsp+60h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF90h
    mov     ecx,0
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     ebx,1
L0:
    lea     rax,[rsp+60h]
    mov     rdi,rax
    call    fn0
    mov     r12,rdx
    jmp     L1
    mov     rcx,rax
    mov     r13,rbx
    mov     r12,rcx
    jmp     L13
L1:
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L2]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L2:
    .long   L5
    .long   L3
    .long   L11
L3:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    mov     rsi,r12
    call    fn1
    jmp     L4
    mov     r13d,0
    mov     r12,rax
    jmp     L13
L4:
    mov     ebx,1
    jmp     L0
L5:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    jmp     L6
    mov     rbx,rax
    jmp     L14
L6:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,78h
    ret
L7:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    qword ptr [fn2.slot]
    mov     rax,r12
    jmp     L8
    jmp     L15
L8:
    mov     [rsp],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L9:
    jmp     L7
L10:
    test    r13b,r13b
    je      L7
    jmp     L9
L11:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L12:
    call    qword ptr [sym4]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L13:
    jmp     L10
L14:
    mov     rax,rbx
    jmp     L8
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
L17:
    pop     rcx
    lea     rdx,[rsp+80h]
    lea     rsp,[rdx-90h]
    movzx   r11d,byte ptr [rdx-39h]
    mov     [rsp],r11
    mov     [rdx-40h],rbx
    mov     [rdx-50h],r12
    mov     [rdx-60h],r13
    mov     rbx,[rsp]
    lea     rsp,[rsp+20h]
    jmp     L0
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
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    cmp     r12,rbx
    jb      L2
    jmp     L3
L0:
    lea     rax,[r13+rbx*4]
    mov     rdx,rbp
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L1:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r15
    call    qword ptr [sym0]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L2:
    jmp     L1
L3:
    mov     rbp,r12
    sub     rbp,rbx
    cmp     r14,r12
    jae     L0
    jmp     L1
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

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    cmp     r12,rbx
    jb      L2
    jmp     L3
L0:
    lea     rax,[r13+rbx*4]
    mov     rdx,rbp
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L1:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r14
    mov     rcx,r15
    call    qword ptr [sym0]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L2:
    jmp     L1
L3:
    mov     rbp,r12
    sub     rbp,rbx
    cmp     r14,r12
    jae     L0
    jmp     L1
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

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r13,rbx
    jae     L0
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r13
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    sub     r13,rbx
    lea     r12,[r12+rbx*4]
    mov     rax,r12
    mov     rdx,r13
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    cmp     r13,rbx
    jae     L0
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r13
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    sub     r13,rbx
    lea     r12,[r12+rbx*4]
    mov     rax,r12
    mov     rdx,r13
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

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
    sub     rsp,0B8h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     [rsp+40h],r15
    mov     [rsp+30h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF50h
    mov     ecx,0
    mov     r8d,18h
    call    ryo_h_LoadCopy
    jmp     L0
    cmp     r12,0
    sete    al
    jmp     L1
L0:
    cmp     rbx,r12
    sete    al
L1:
    test    al,al
    je      L3
    lea     rax,[rsp+88h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L2
    mov     rcx,rax
    mov     eax,0
    jmp     L26
L2:
    jmp     L12
L3:
    jmp     L4
    mov     r13,rbx
    mov     r14d,0
    mov     r15,r12
    mov     qword ptr [rsp+20h],0
    jmp     L6
L4:
    jmp     L5
L5:
    jmp     L21
L6:
    lea     rax,[rsp+88h]
    lea     rcx,[r13+r14*4]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn1
    jmp     L7
    mov     qword ptr [rsp+28h],0
    mov     r11,[rsp+20h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],rax
    jmp     L27
L7:
    jmp     L8
L8:
    jmp     L24
L9:
    lea     rax,[rsp+88h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L10
    mov     rcx,rax
    mov     rax,[rsp+20h]
    jmp     L26
L10:
    jmp     L12
L11:
    mov     r13,rax
    mov     r14,rcx
    mov     r15,rdx
    mov     [rsp+20h],rsi
    jmp     L6
L12:
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    mov     r15,[rsp+40h]
    mov     rbp,[rsp+30h]
    add     rsp,0B8h
    ret
L13:
    lea     rax,[rsp+88h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L14
    jmp     L28
L14:
    mov     rax,[rsp+10h]
    mov     rbp,[rsp+18h]
    jmp     L19
L15:
    mov     [rsp],rbp
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
L16:
    jmp     L13
L17:
    cmp     byte ptr [rsp+28h],0
    je      L13
    jmp     L16
L18:
    jmp     L15
L19:
    test    al,al
    je      L15
    jmp     L18
L20:
    mov     r13,rbx
    mov     r14d,0
    mov     r15,rbp
    mov     qword ptr [rsp+20h],0
    jmp     L6
L21:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rax
    call    fn5
    mov     r11d,0
    cmp     r11,4
    jae     L22
    mov     r11d,4
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L22
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rbp,rax
    jmp     L20
L22:
    lea     rdi,[k6]
    call    ryo_hr_AddrAbs
    mov     rbx,rax
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym8]
    jmp     L23
    mov     qword ptr [rsp+28h],1
    mov     qword ptr [rsp+10h],0
    mov     [rsp+18h],rax
    jmp     L27
L23:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L24:
    lea     rdi,[k9]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     esi,1
    mov     rdx,rax
    call    fn10
    add     r14,1
    cmp     r14,r15
    je      L9
    mov     rax,r13
    mov     rcx,r14
    mov     rdx,r15
    mov     rsi,[rsp+20h]
    jmp     L11
L25:
    call    qword ptr [sym11]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L26:
    mov     rbp,rcx
    jmp     L19
L27:
    jmp     L17
L28:
    jmp     L25
  ; OSR entries
    lea     r11,[L29]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L29:
    .long   L30
    .long   L31
    .long   L32
    .long   L33
    .long   L34
    .long   L35
    .long   L36
    .long   L37
    .long   L38
    .long   L39
    .long   L40
L30:
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
    mov     r11,[rsp+18h]
    mov     [rdx-90h],r11
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+30h]
    jmp     L6
L31:
    ret
L32:
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
    lea     rsp,[rsp+30h]
    jmp     L11
L33:
    ret
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
L39:
    ret
L40:
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,0C8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     [rsp+98h],rcx
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
    mov     rax,r13
    jmp     L10
L2:
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
    lea     rcx,[rsp+98h]
    lea     rdx,[r14+r15*4]
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
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0C8h
    ret
L11:
    jmp     L16
L12:
    mov     r11,[rsp+28h]
    mov     [rsp],r11
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
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
    call    fn2
    mov     r11d,0
    cmp     r11,4
    jae     L19
    mov     r11d,4
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L19
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rbp,rax
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
    lea     rdi,[rsp+0C0h]
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
    mov     r11,[rsp+18h]
    mov     [rdx-88h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-0B0h],r11
    mov     rax,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L5
L25:
    ret
L26:
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
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r11d,4
    cmp     r11,8
    ja      L0
    mov     eax,4
    imul    rax,20h
    cmp     rax,1000h
    ja      L0
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    call    fn0
    jmp     L2
L0:
    mov     eax,4
    imul    rax,30h
    cmp     rax,1000h
    ja      L1
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    call    qword ptr [fn1.slot]
    jmp     L2
L1:
    cmp     r12,2
    jae     L3
    jmp     L4
L2:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret
L3:
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,1
    mov     rcx,r13
    call    fn2
L4:
    jmp     L2
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
    sub     rsp,18h
    mov     r11d,4
    cmp     r11,8
    ja      L0
    mov     eax,4
    imul    rax,20h
    cmp     rax,1000h
    ja      L0
    mov     eax,20h
    jmp     L2
L0:
    mov     eax,4
    imul    rax,30h
    cmp     rax,1000h
    ja      L1
    mov     eax,20h
    jmp     L2
L1:
    mov     eax,10h
L2:
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
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    cmp     rdi,rsi
    jae     L0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0D6h
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

fn Rng::next
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,[rbx]
    mov     r11d,0Dh
    cmp     r11d,40h
    jb      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L0:
    shl     r12,0Dh
    mov     rax,[rbx]
    xor     rax,r12
    mov     [rbx],rax
    mov     r12,[rbx]
    mov     r11d,7
    cmp     r11d,40h
    jb      L1
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L1:
    shr     r12,7
    mov     rax,[rbx]
    xor     rax,r12
    mov     [rbx],rax
    mov     r12,[rbx]
    mov     r11d,11h
    cmp     r11d,40h
    jb      L2
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L2:
    shl     r12,11h
    mov     rax,[rbx]
    xor     rax,r12
    mov     [rbx],rax
    mov     rax,[rbx]
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    mov     r11,rdi
    add     r11,rsi
    jae     L0
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

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     [rsp+70h],r13
    mov     rax,[rsp+70h]
    cmp     rax,r14
    jb      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+58h]
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,r14
    mov     r8,rax
    call    qword ptr [fn1.slot]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF60h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0
    mov     ecx,0FFFFFF40h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    add     rsp,0D8h
    ret
L0:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],9
    mov     rax,[rsp+60h]
    mov     r11,[rsp+68h]
    mov     [rsp+58h],rax
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     eax,9
    shl     rax,1
    or      rax,1
    mov     rcx,[rsp+58h]
    mov     [rsp+70h],rcx
    mov     rcx,[rsp+70h]
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,r15
    call    qword ptr [sym4]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
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
    jmp     L0
L0:
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r15
    call    fn0
    jmp     L1
L1:
    mov     [rsp+48h],r12
    mov     rax,[rsp+48h]
    mov     rdi,rax
    mov     esi,8
    mov     edx,4
    mov     rcx,r14
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r14
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    lea     r12,[r12+r14*8]
    sub     r13,r14
    jmp     L2
L2:
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
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    cmp     rsi,rdi
    jb      L0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0DDh
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

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rcx
    cmp     rsi,rdi
    jae     L0
    cmp     rdx,rdi
    jae     L0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0DAh
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

fn core::slice::<impl [u32]>::copy_from_slice
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn core::slice::<impl [u32]>::split_at_mut
    sub     rsp,0D8h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    mov     r15,r8
    mov     [rsp+70h],r13
    mov     rax,[rsp+70h]
    cmp     rax,r14
    jb      L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+58h]
    mov     rdi,rcx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,r14
    mov     r8,rax
    call    qword ptr [fn1.slot]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF88h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF60h
    mov     ecx,20h
    call    ryo_h_Copy
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0
    mov     ecx,0FFFFFF40h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,rbx
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    add     rsp,0D8h
    ret
L0:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],9
    mov     rax,[rsp+60h]
    mov     r11,[rsp+68h]
    mov     [rsp+58h],rax
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     eax,9
    shl     rax,1
    or      rax,1
    mov     rcx,[rsp+58h]
    mov     [rsp+70h],rcx
    mov     rcx,[rsp+70h]
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,r15
    call    qword ptr [sym4]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
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
    jmp     L0
L0:
    mov     rdi,r14
    mov     rsi,r13
    mov     rdx,r15
    call    qword ptr [fn0.slot]
    jmp     L1
L1:
    mov     [rsp+48h],r12
    mov     rax,[rsp+48h]
    mov     rdi,rax
    mov     esi,4
    mov     edx,4
    mov     rcx,r14
    mov     r8,r15
    call    fn1
    mov     [rsp+40h],r12
    mov     [rsp+48h],r14
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    lea     r12,[r12+r14*4]
    sub     r13,r14
    jmp     L2
L2:
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
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
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
    cmp     r13,r12
    jb      L0
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,r15
    call    qword ptr [sym0]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L0:
    cmp     r14,r12
    jb      L1
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r15
    call    qword ptr [sym0]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,r14
    mov     r8,r15
    call    fn2
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret

fn core::slice::<impl [u32]>::swap_unchecked
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rdx
    mov     r13,rcx
    jmp     L0
L0:
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
    je      L0
    mov     rdi,r12
    mov     rsi,rcx
    mov     rdx,r8
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    jmp     L1
L1:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8,r12
    mov     r9,rax
    call    fn2
    imul    r12,4
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,r12
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

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
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rdi
    mov     [rsp+10h],rsi
    mov     r13,rdx
    mov     r11,[rsp+10h]
    cmp     r11,8
    jae     L0
    lea     rdi,[rsp+80h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rdi,[rsp+10h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r14,rax
    mov     rax,r14
    imul    rax,4
    lea     r15,[rbx+rax*8]
    mov     rax,r14
    imul    rax,7
    lea     rbp,[rbx+rax*8]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L2
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,r13
    call    fn0
    mov     r12,rax
    jmp     L1
L1:
    jmp     L7
L2:
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,r14
    mov     r8,r13
    call    fn1
    mov     r13,rax
    jmp     L3
L3:
    jmp     L10
L4:
    cmp     r14,[rsp+10h]
    setb    r15b
    jmp     L5
L5:
    jmp     L12
L6:
    mov     r14,rbp
    jmp     L4
L7:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rax
    call    fn3
    mov     r11d,0
    cmp     r11,8
    jae     L8
    mov     r11d,8
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L8
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     rbp,rax
    jmp     L6
L8:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym6]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     r14,r12
    jmp     L4
L10:
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,rax
    call    fn3
    mov     r11d,0
    cmp     r11,8
    jae     L11
    mov     r11d,8
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L11
    sub     r13,rbx
    mov     rdi,r13
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r12,rax
    jmp     L9
L11:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rbx,rax
    lea     rdi,[k10]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym6]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L12:
    lea     rdi,[k12]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     rsi,rax
    movzx   edi,dil
    call    fn13
    mov     rax,r14
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
  ; OSR entries
    lea     r11,[L13]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L13:
    .long   L14
    .long   L15
    .long   L16
L14:
    ret
L15:
    ret
L16:
    ret

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     [rsp+70h],rbx
    mov     [rsp+60h],r12
    mov     [rsp+50h],r13
    mov     [rsp+40h],r14
    mov     [rsp+30h],r15
    mov     [rsp+20h],rbp
    mov     rbx,rdi
    mov     [rsp+10h],rsi
    mov     r13,rdx
    mov     r11,[rsp+10h]
    cmp     r11,8
    jae     L0
    lea     rdi,[rsp+80h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rdi,[rsp+10h]
    mov     esi,8
    call    ryo_hr_DivUW64
    mov     r14,rax
    mov     rax,r14
    imul    rax,4
    lea     r15,[rbx+rax*4]
    mov     rax,r14
    imul    rax,7
    lea     rbp,[rbx+rax*4]
    mov     r11,[rsp+10h]
    cmp     r11,40h
    jae     L2
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,r13
    call    fn0
    mov     r12,rax
    jmp     L1
L1:
    jmp     L7
L2:
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rbp
    mov     rcx,r14
    mov     r8,r13
    call    fn1
    mov     r13,rax
    jmp     L3
L3:
    jmp     L10
L4:
    cmp     r14,[rsp+10h]
    setb    r15b
    jmp     L5
L5:
    jmp     L12
L6:
    mov     r14,rbp
    jmp     L4
L7:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,rbx
    mov     rdx,rax
    call    qword ptr [fn3.slot]
    mov     r11d,0
    cmp     r11,4
    jae     L8
    mov     r11d,4
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L8
    sub     r12,rbx
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     rbp,rax
    jmp     L6
L8:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym6]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     r14,r12
    jmp     L4
L10:
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,rax
    call    qword ptr [fn3.slot]
    mov     r11d,0
    cmp     r11,4
    jae     L11
    mov     r11d,4
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L11
    sub     r13,rbx
    mov     rdi,r13
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r12,rax
    jmp     L9
L11:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rbx,rax
    lea     rdi,[k10]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym6]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L12:
    lea     rdi,[k12]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     rsi,rax
    movzx   edi,dil
    call    qword ptr [fn13.slot]
    mov     rax,r14
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
  ; OSR entries
    lea     r11,[L13]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L13:
    .long   L14
    .long   L15
    .long   L16
L14:
    ret
L15:
    ret
L16:
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
    jne     L2
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    call    fn0
    xor     eax,r15d
    test    al,al
    je      L0
    jmp     L1
L0:
    mov     r13,r12
L1:
    jmp     L3
L2:
    mov     r13,rbx
L3:
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
    jne     L2
    mov     rdi,r14
    mov     rsi,r12
    mov     rdx,r13
    call    fn0
    xor     eax,r15d
    test    al,al
    je      L0
    jmp     L1
L0:
    mov     r13,r12
L1:
    jmp     L3
L2:
    mov     r13,rbx
L3:
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
    sub     rsp,188h
    mov     [rsp+0C0h],rbx
    mov     [rsp+0B0h],r12
    mov     [rsp+0A0h],r13
    mov     [rsp+90h],r14
    mov     [rsp+80h],r15
    mov     [rsp+70h],rbp
    mov     rbx,rsi
    mov     r12,rdx
    mov     r13,rcx
    mov     [rsp+0E0h],rdi
    mov     r14,[rsp+0E0h]
    mov     rdi,rbx
    mov     esi,2
    call    ryo_hr_DivUW64
    cmp     rax,0
    setne   cl
    mov     [rsp+0E7h],cl
    lea     rcx,[r14+rax*4]
    mov     rdx,rax
    sub     rdx,1
    mov     [rsp+0E0h],rdx
    mov     rdx,[rsp+0E0h]
    lea     rdx,[r14+rdx*4]
    mov     rsi,rbx
    sub     rsi,1
    lea     rdi,[r14+rsi*4]
    mov     [rsp+0E0h],r12
    mov     r8,[rsp+0E0h]
    lea     r8,[r8+rsi*4]
    mov     qword ptr [rsp+58h],0
    mov     [rsp+50h],rax
    mov     [rsp+48h],rdx
    mov     [rsp+18h],r14
    mov     [rsp+10h],rcx
    mov     [rsp+20h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],rdi
    mov     [rsp+38h],r8
    mov     [rsp+28h],rbx
L0:
    mov     r10,[rsp+58h]
    mov     [rsp+0D8h],r10
    mov     r10,[rsp+50h]
    mov     [rsp+0D0h],r10
    mov     rax,[rsp+0D8h]
    mov     rcx,[rsp+0D0h]
    cmp     rax,rcx
    setb    al
    mov     [rsp+0E7h],al
    movzx   eax,byte ptr [rsp+0E7h]
    test    al,al
    je      L13
    jmp     L11
L1:
    mov     r12,[rsp+0D0h]
    mov     rbx,[rsp+0D8h]
    mov     r11,[rsp+0E0h]
    mov     [rsp+60h],r11
    lea     rsi,[rsp+0D0h]
    mov     rdi,rsi
    mov     rsi,rax
    mov     r8,r14
    mov     r10,rdx
    mov     rdx,rcx
    mov     rcx,r10
    call    fn0
    mov     rax,[rsp+0D0h]
    mov     rcx,[rsp+0D8h]
    mov     rdx,[rsp+0E0h]
    mov     [rsp+58h],rbp
    mov     [rsp+50h],r15
    mov     [rsp+48h],rax
    mov     [rsp+18h],r12
    mov     [rsp+10h],rbx
    mov     r11,[rsp+60h]
    mov     [rsp+20h],r11
    mov     [rsp+40h],r14
    mov     [rsp+30h],rcx
    mov     [rsp+38h],rdx
    mov     [rsp+28h],r13
    jmp     L0
L2:
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+10h]
    jmp     L7
L3:
    mov     rax,[rsp+0E0h]
    mov     r11,[rsp+18h]
    cmp     r11,rax
    setb    al
    mov     [rsp+0D6h],al
    movzx   eax,byte ptr [rsp+0D6h]
    test    al,al
    je      L4
    mov     rbx,[rsp+18h]
    jmp     L5
L4:
    mov     rbx,[rsp+10h]
L5:
    jmp     L6
L6:
    jmp     L16
L7:
    mov     rdx,[rsp+0E0h]
    cmp     rax,rdx
    je      L8
    jmp     L9
L8:
    mov     rax,[rsp+0D8h]
    cmp     rcx,rax
    je      L10
L9:
    call    qword ptr [sym1]
    lea     rdi,[rsp+180h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rbx,[rsp+0C0h]
    mov     r12,[rsp+0B0h]
    mov     r13,[rsp+0A0h]
    mov     r14,[rsp+90h]
    mov     r15,[rsp+80h]
    mov     rbp,[rsp+70h]
    add     rsp,188h
    ret
L11:
    mov     r10,[rsp+58h]
    mov     [rsp+0D8h],r10
    jmp     L12
L12:
    jmp     L14
L13:
    mov     r11,[rsp+48h]
    mov     r10d,1
    lea     rax,[r11+r10*4]
    mov     [rsp+0E0h],rax
    jmp     L15
L14:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0D8h]
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    call    fn3
    mov     rax,[rsp+0D8h]
    add     rax,1
    mov     [rsp+0D0h],rax
    mov     r12,[rsp+0D0h]
    lea     rax,[rsp+0D0h]
    mov     rdi,rax
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn4
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     r14,[rsp+40h]
    mov     rbp,r12
    mov     r15,[rsp+50h]
    mov     r13,[rsp+28h]
    jmp     L1
L15:
    mov     r11,[rsp+30h]
    mov     r10d,1
    lea     rax,[r11+r10*4]
    mov     [rsp+0D8h],rax
    mov     rdi,[rsp+28h]
    mov     esi,2
    call    ryo_hr_RemUW64
    cmp     rax,0
    sete    al
    mov     [rsp+0D7h],al
    movzx   eax,byte ptr [rsp+0D7h]
    test    al,al
    je      L3
    jmp     L2
L16:
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,[rsp+20h]
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn6
    mov     eax,1
    imul    rax,4
    mov     rdi,[rsp+20h]
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    movzx   eax,byte ptr [rsp+0D6h]
    movzx   eax,al
    mov     r11,[rsp+18h]
    lea     rax,[r11+rax*4]
    movzx   ecx,byte ptr [rsp+0D6h]
    xor     ecx,1
    mov     [rsp+0D5h],cl
    movzx   ecx,byte ptr [rsp+0D5h]
    movzx   ecx,cl
    mov     r11,[rsp+10h]
    lea     rcx,[r11+rcx*4]
    jmp     L7
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
L18:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1D0h]
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
    mov     r11,[rsp]
    mov     [rdx-128h],r11
    mov     r11,[rsp+8]
    mov     [rdx-130h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-168h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-140h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-148h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-158h],r11
    lea     rsp,[rsp+50h]
    jmp     L0
L19:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1C0h]
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
    mov     r14,[rsp+18h]
    mov     rbp,[rsp+20h]
    mov     r15,[rsp+28h]
    mov     r13,[rsp+30h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L1
L20:
    ret
L21:
    ret
L22:
    ret

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,108h
    mov     [rsp+0B0h],rbx
    mov     [rsp+0A0h],r12
    mov     [rsp+90h],r13
    mov     [rsp+80h],r14
    mov     [rsp+70h],r15
    mov     [rsp+60h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    jmp     L13
    jmp     L12
L0:
    movzx   eax,byte ptr [rsp+0BFh]
    test    al,al
    je      L1
    mov     [rsp+50h],r12
    mov     rax,[rsp+50h]
    mov     eax,[rax]
    mov     [rsp+54h],eax
    mov     eax,[rsp+54h]
    mov     [rsp+0BCh],eax
    lea     rax,[rsp+0BCh]
    mov     [rsp+40h],rax
    mov     [rsp+48h],r12
    mov     qword ptr [rsp+50h],1
    mov     r15,r14
    mov     [rsp+18h],rbx
    mov     [rsp+10h],r13
    jmp     L2
L1:
    jmp     L8
L2:
    mov     rbp,[rsp+48h]
    jmp     L3
L3:
    jmp     L14
L4:
    jmp     L7
L5:
    jmp     L18
    jmp     L17
L6:
    test    al,al
    je      L7
    mov     r15,rcx
    mov     [rsp+18h],rdx
    mov     [rsp+10h],rsi
    jmp     L2
L7:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
L8:
    mov     rbx,[rsp+0B0h]
    mov     r12,[rsp+0A0h]
    mov     r13,[rsp+90h]
    mov     r14,[rsp+80h]
    mov     r15,[rsp+70h]
    mov     rbp,[rsp+60h]
    add     rsp,108h
    ret
L9:
    lea     rax,[rsp+40h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L10
    jmp     L20
L10:
    mov     r11,[rsp+38h]
    mov     [rsp],r11
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
    call    ryo_h_Resume
    ud2
L11:
    mov     [rsp+40h],r12
    mov     rax,[rsp+40h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],r14
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     rdi,r13
    mov     rsi,rax
    mov     rdx,rcx
    call    fn2
    mov     [rsp+0BFh],al
    jmp     L0
L12:
    mov     r14,r12
    jmp     L11
L13:
    mov     r10,0FFFFFFFFFFFFFFFFh
    lea     rax,[r12+r10*4]
    mov     r14,rax
    jmp     L11
L14:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     rsi,rbp
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn4
    mov     eax,1
    imul    rax,4
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     [rsp+48h],r15
    cmp     r15,[rsp+18h]
    je      L4
    mov     [rsp+20h],r15
    mov     r11,[rsp+10h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+18h]
    mov     [rsp+30h],r11
    jmp     L5
L15:
    lea     rax,[rsp+0BCh]
    mov     rdi,r12
    mov     rsi,rax
    mov     rdx,rbx
    call    fn2
    jmp     L16
    mov     [rsp+38h],rax
    jmp     L21
L16:
    mov     rcx,rbx
    mov     rdx,r13
    mov     rsi,r12
    jmp     L6
L17:
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    jmp     L15
L18:
    mov     r11,[rsp+20h]
    mov     r10,0FFFFFFFFFFFFFFFFh
    lea     rax,[r11+r10*4]
    mov     rbx,rax
    mov     r12,[rsp+28h]
    mov     r13,[rsp+30h]
    jmp     L15
L19:
    call    qword ptr [sym6]
    lea     rdi,[rsp+100h]
    call    ryo_h_Unreachable
    ud2
L20:
    jmp     L19
L21:
    jmp     L9
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
    .long   L28
    .long   L29
    .long   L30
    .long   L31
L23:
    ret
L24:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-130h]
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
    mov     [rdx-0E8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0F0h],r11
    mov     r15,[rsp]
    lea     rsp,[rsp+30h]
    jmp     L2
L25:
    ret
L26:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-130h]
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
    mov     r11,[rsp]
    mov     [rdx-0E0h],r11
    mov     r11,[rsp+8]
    mov     [rdx-0D8h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-0D0h],r11
    lea     rsp,[rsp+30h]
    jmp     L5
L27:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-140h]
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+40h]
    jmp     L6
L28:
    ret
L29:
    ret
L30:
    pop     rcx
    lea     rdx,[rsp+0A0h]
    lea     rsp,[rdx-130h]
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
    jmp     L15
L31:
    ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    cmp     r13,0
    je      L0
    cmp     r12,r13
    jae     L1
L0:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
    ud2
L1:
    lea     rax,[rbx+r12*4]
    lea     rcx,[rbx+r13*4]
    mov     r12,rax
    mov     r13,rbx
    mov     rbx,rcx
L2:
    cmp     rbx,r12
    je      L3
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,r14
    call    fn0
    mov     r10d,1
    lea     rbx,[rbx+r10*4]
    jmp     L2
L3:
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
L5:
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
    jmp     L2

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
    test    bpl,bpl
    je      L0
    mov     rbx,r13
    jmp     L1
L0:
    mov     rbx,r12
L1:
    jmp     L2
L2:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn2
    mov     eax,1
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    movzx   ebp,bpl
    mov     eax,0
    sub     rax,rbp
    lea     r13,[r13+rax*4]
    movzx   r15d,r15b
    mov     eax,0
    sub     rax,r15
    lea     r12,[r12+rax*4]
    jmp     L5
    jmp     L4
L3:
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
L4:
    mov     rax,r14
    jmp     L3
L5:
    mov     r10,0FFFFFFFFFFFFFFFFh
    lea     r14,[r14+r10*4]
    mov     rax,r14
    jmp     L3
  ; OSR entries
    lea     r11,[L6]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L6:
    .long   L7
L7:
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
    test    bpl,bpl
    je      L0
    mov     rbx,r12
    jmp     L1
L0:
    mov     rbx,r13
L1:
    jmp     L2
L2:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn2
    mov     eax,1
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    movzx   r15d,r15b
    lea     r13,[r13+r15*4]
    movzx   ebp,bpl
    lea     r12,[r12+rbp*4]
    mov     r10d,1
    lea     r14,[r14+r10*4]
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
    jae     L0
    jmp     L20
L0:
    mov     rax,r12
    add     rax,10h
    cmp     rcx,rax
    jae     L1
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     [rsp+90h],rax
    jmp     L2
L2:
    cmp     r12,10h
    jb      L3
    lea     rax,[r13+r12*8]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+0B0h]
    mov     rdi,rbx
    mov     rsi,r13
    mov     rdx,rax
    mov     rcx,r14
    call    qword ptr [fn0.slot]
    mov     r10,[rsp+90h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+0B0h],rax
    mov     r10,[rsp+90h]
    lea     rax,[r13+r10*8]
    mov     [rsp+0A8h],rax
    mov     rax,r12
    add     rax,8
    mov     [rsp+198h],rax
    mov     rax,[rsp+198h]
    lea     rax,[r13+rax*8]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,r14
    call    qword ptr [fn0.slot]
    mov     ebp,8
    jmp     L6
L3:
    cmp     r12,8
    jb      L4
    mov     [rsp+0B0h],rbx
    mov     rax,[rsp+0B0h]
    mov     rdi,rax
    mov     rsi,r13
    mov     rdx,r14
    call    qword ptr [fn2.slot]
    mov     r10,[rsp+90h]
    lea     rax,[rbx+r10*8]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+0B0h],rax
    mov     r10,[rsp+90h]
    lea     rax,[r13+r10*8]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0A8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r14
    call    qword ptr [fn2.slot]
    mov     ebp,4
    jmp     L6
L4:
    mov     [rsp+0B0h],rbx
    jmp     L5
L5:
    jmp     L25
L6:
    mov     qword ptr [rsp+190h],0
    mov     r10,[rsp+90h]
    mov     [rsp+198h],r10
    mov     rax,[rsp+190h]
    mov     [rsp+180h],rax
    mov     rax,[rsp+198h]
    mov     [rsp+188h],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE30h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+180h]
    mov     [rsp+0D0h],rax
    mov     rax,[rsp+188h]
    mov     [rsp+0D8h],rax
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
L7:
    lea     rax,[rsp+180h]
    mov     [rsp+0F8h],rax
    mov     rax,[rsp+0F8h]
    mov     [rsp+0C0h],rax
    mov     qword ptr [rsp+0C8h],2
    mov     rax,[rsp+0C0h]
    mov     rcx,[rsp+0C8h]
    mov     rdi,rax
    mov     rsi,rcx
    call    qword ptr [fn5.slot]
    mov     [rsp+0D0h],rax
    mov     [rsp+0D8h],rdx
    jmp     L8
    mov     r15,rax
    jmp     L38
L8:
    jmp     L27
L9:
    lea     rdi,[rsp+290h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rax,[rsp+0D8h]
    mov     [rsp+0C8h],rax
    mov     rax,[rsp+0C8h]
    mov     r11,[rsp+10h]
    lea     rax,[r11+rax*8]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0C8h]
    mov     r11,[rsp+20h]
    lea     rax,[r11+rax*8]
    mov     [rsp+0F8h],rax
    mov     rax,[rsp+0C8h]
    cmp     rax,0
    je      L12
    jmp     L13
L11:
    lea     rax,[rsp+180h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    jmp     L17
L12:
    mov     rax,[rsp+28h]
    jmp     L14
L13:
    mov     rax,[rsp+18h]
    sub     rax,[rsp+28h]
L14:
    mov     r10,[rsp+30h]
    mov     [rsp+0F0h],r10
    mov     rcx,[rsp+0F0h]
    mov     [rsp+40h],rcx
    mov     [rsp+48h],rax
    mov     r11,[rsp+88h]
    mov     [rsp+50h],r11
    mov     r11,[rsp+10h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+18h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+28h]
    mov     [rsp+70h],r11
    mov     r11,[rsp+30h]
    mov     [rsp+78h],r11
    mov     r11,[rsp+38h]
    mov     [rsp+80h],r11
L15:
    mov     r10,[rsp+40h]
    mov     [rsp+118h],r10
    mov     r10,[rsp+48h]
    mov     [rsp+110h],r10
    mov     rax,[rsp+118h]
    mov     rcx,[rsp+110h]
    cmp     rax,rcx
    setb    al
    mov     [rsp+0E7h],al
    movzx   eax,byte ptr [rsp+0E7h]
    test    al,al
    je      L31
    jmp     L29
L16:
    mov     [rsp+40h],rax
    mov     [rsp+48h],rcx
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp+68h],r8
    mov     [rsp+70h],r9
    mov     [rsp+78h],rbp
    mov     [rsp+80h],r15
    jmp     L15
L17:
    mov     r10,[rsp+88h]
    mov     [rsp+0A0h],r10
    mov     rax,[rsp+0A0h]
    mov     [rsp+0A8h],rax
    mov     r10,[rsp+10h]
    mov     [rsp+0B0h],r10
    mov     r10,[rsp+18h]
    mov     [rsp+0B8h],r10
    mov     rax,[rsp+0A8h]
    mov     [rsp+190h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+188h],rax
    jmp     L18
L18:
    jmp     L35
L19:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+198h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+190h],rax
L20:
    mov     rbx,[rsp+170h]
    mov     r12,[rsp+160h]
    mov     r13,[rsp+150h]
    mov     r14,[rsp+140h]
    mov     r15,[rsp+130h]
    mov     rbp,[rsp+120h]
    add     rsp,298h
    ret
L21:
    lea     rax,[rsp+180h]
    mov     rdi,rax
    call    qword ptr [fn6.slot]
    mov     rax,r15
    jmp     L22
    jmp     L39
L22:
    mov     [rsp],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    call    ryo_h_Resume
    ud2
L23:
    lea     rax,[rsp+0A8h]
    mov     rdi,rax
    call    qword ptr [fn8.slot]
    jmp     L24
    jmp     L39
L24:
    mov     rax,rbp
    jmp     L22
L25:
    mov     [rsp+0A8h],rbx
    mov     [rsp+0A0h],r13
    lea     rdi,[k9]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     eax,1
    imul    rax,8
    mov     [rsp],r13
    mov     [rsp+8],rax
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
    jmp     L26
L26:
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+198h],rax
    lea     rdi,[k11]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0A0h]
    mov     rdx,[rsp+198h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     eax,1
    imul    rax,8
    mov     [rsp],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFE18h
    mov     edx,0FFFFFE20h
    mov     ecx,0FFFFFD70h
    call    ryo_h_Memcpy
    mov     ebp,1
    jmp     L6
L27:
    mov     rax,[rsp+0D0h]
    mov     rdi,rax
    mov     esi,0
    mov     edx,2
    call    ryo_hr_SwitchDenseW64
    mov     r10,rax
    lea     r11,[L28]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
    int3
L28:
    .long   L11
    .long   L10
    .long   L9
L29:
    mov     r10,[rsp+40h]
    mov     [rsp+118h],r10
    jmp     L30
L30:
    jmp     L32
L31:
    mov     r11,[rsp+50h]
    mov     [rsp+88h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+10h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+18h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+38h],r11
    jmp     L7
L32:
    lea     rdi,[k13]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+118h]
    mov     rdi,rcx
    mov     esi,1
    mov     rdx,rax
    call    fn14
    mov     rax,[rsp+118h]
    add     rax,1
    mov     [rsp+110h],rax
    mov     rbx,[rsp+110h]
    mov     rax,[rsp+118h]
    mov     [rsp+0F0h],rax
    mov     qword ptr [rsp+0E8h],1
    mov     rax,[rsp+0F0h]
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+0C0h]
    mov     rcx,[rsp+0E0h]
    lea     rax,[rax+rcx*8]
    mov     [rsp+118h],rax
    mov     rcx,[rsp+0F8h]
    mov     rdx,[rsp+0E0h]
    lea     r12,[rcx+rdx*8]
    jmp     L33
L33:
    mov     [rsp+110h],rax
    mov     [rsp+108h],r12
    lea     rdi,[k15]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+110h]
    mov     rdx,[rsp+108h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn10
    mov     eax,1
    imul    rax,8
    mov     [rsp],r12
    mov     [rsp+8],rax
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD70h
    mov     edx,0FFFFFE88h
    mov     ecx,0FFFFFD78h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0F8h]
    mov     rdi,rax
    mov     rsi,r12
    mov     rdx,[rsp+80h]
    call    qword ptr [fn17.slot]
    jmp     L34
    mov     r15,rax
    jmp     L38
L34:
    mov     rax,rbx
    mov     rcx,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+70h]
    mov     rbp,[rsp+78h]
    mov     r15,[rsp+80h]
    jmp     L16
L35:
    mov     rax,[rsp+190h]
    mov     [rsp+180h],rax
    lea     rdi,[k18]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+180h]
    mov     rdx,[rsp+188h]
    mov     rdi,rcx
    mov     esi,8
    mov     rcx,rdx
    mov     edx,4
    mov     r8,rax
    call    fn19
    mov     rax,[rsp+190h]
    mov     [rsp+0D8h],rax
    mov     rax,[rsp+188h]
    mov     [rsp+180h],rax
    mov     rax,[rsp+0D8h]
    mov     [rsp+198h],rax
    mov     rax,[rsp+180h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+190h],rax
    mov     rax,[rsp+198h]
    mov     rcx,[rsp+0A0h]
    mov     rdx,[rsp+190h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,[rsp+38h]
    call    qword ptr [fn20.slot]
    jmp     L36
    mov     rbp,rax
    jmp     L40
L36:
    jmp     L19
L37:
    call    qword ptr [sym21]
    lea     rdi,[rsp+290h]
    call    ryo_h_Unreachable
    ud2
L38:
    jmp     L21
L39:
    jmp     L37
L40:
    jmp     L23
  ; OSR entries
    lea     r11,[L41]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L41:
    .long   L42
    .long   L43
    .long   L44
    .long   L45
    .long   L46
    .long   L47
    .long   L48
    .long   L49
    .long   L50
    .long   L51
L42:
    ret
L43:
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
    jmp     L7
L44:
    ret
L45:
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
    mov     [rdx-250h],r11
    mov     r11,[rsp+8]
    mov     [rdx-248h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-240h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-238h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-230h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-220h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-218h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-210h],r11
    lea     rsp,[rsp+0D0h]
    jmp     L15
L46:
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
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     rsi,[rsp+18h]
    mov     rdi,[rsp+20h]
    mov     r8,[rsp+28h]
    mov     r9,[rsp+30h]
    mov     rbp,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     rdx,[rsp+10h]
    lea     rsp,[rsp+0D0h]
    jmp     L16
L47:
    ret
L48:
    ret
L49:
    ret
L50:
    ret
L51:
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
    jae     L0
    jmp     L15
L0:
    cmp     r12,20h
    jbe     L1
    lea     rdi,[rsp+150h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     r14,rax
    cmp     r12,12h
    setb    r15b
    test    r15b,r15b
    je      L2
    mov     rbp,r12
    jmp     L3
L2:
    mov     rbp,r14
L3:
    jmp     L4
L4:
    jmp     L16
L5:
    mov     r11,[rsp+48h]
    mov     rax,[rsp+50h]
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+0E0h]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0E8h]
    cmp     rax,0Dh
    jb      L6
    mov     rax,[rsp+48h]
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0E0h]
    mov     rcx,[rsp+0E8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+10h]
    call    qword ptr [fn0.slot]
    mov     eax,0Dh
    jmp     L8
L6:
    mov     r11,[rsp+48h]
    mov     rax,[rsp+50h]
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+0E0h]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0E8h]
    cmp     rax,9
    jb      L7
    mov     rax,[rsp+48h]
    mov     [rsp+0E0h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+0E0h]
    mov     rcx,[rsp+0E8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+10h]
    call    qword ptr [fn1.slot]
    mov     eax,9
    jmp     L8
L7:
    mov     eax,1
L8:
    mov     rcx,[rsp+48h]
    mov     [rsp+0E0h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+0E8h],rcx
    mov     rcx,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     rdi,rcx
    mov     rsi,rdx
    mov     rdx,rax
    mov     rcx,[rsp+10h]
    call    fn2
    cmp     byte ptr [rsp+18h],0
    je      L9
    jmp     L15
L9:
    mov     rax,[rsp+48h]
    mov     rcx,[rsp+50h]
    mov     [rsp+0E0h],rcx
    mov     r11,[rsp+0E0h]
    mov     [rsp+0E8h],rax
    mov     r10,[rsp+20h]
    mov     [rsp+0E0h],r10
    mov     rax,[rsp+0E8h]
    mov     rcx,[rsp+0E0h]
    cmp     rax,rcx
    je      L11
    lea     r11,[rsp+58h]
    mov     [rsp+40h],r11
    jmp     L10
L10:
    jmp     L18
L11:
    mov     r11,[rsp+28h]
    mov     r10,[rsp+30h]
    lea     rax,[r11+r10*4]
    mov     [rsp+0E8h],rax
    mov     rax,[rsp+38h]
    sub     rax,[rsp+30h]
    mov     [rsp+0E0h],rax
    jmp     L12
L12:
    jmp     L17
L13:
    mov     r10,[rsp+40h]
    mov     [rsp+0E8h],r10
    jmp     L14
L14:
    jmp     L19
L15:
    mov     rbx,[rsp+140h]
    mov     r12,[rsp+130h]
    mov     r13,[rsp+120h]
    mov     r14,[rsp+110h]
    mov     r15,[rsp+100h]
    mov     rbp,[rsp+0F0h]
    add     rsp,158h
    ret
L16:
    mov     [rsp+0E8h],rbx
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0E8h]
    mov     rdi,rcx
    mov     esi,4
    mov     edx,4
    mov     rcx,rbp
    mov     r8,rax
    call    fn4
    mov     [rsp+0E0h],rbx
    mov     [rsp+0E8h],rbp
    mov     rax,[rsp+0E0h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+0E8h]
    mov     [rsp+50h],rax
    mov     [rsp+10h],r13
    mov     [rsp+18h],r15
    mov     [rsp+20h],rbx
    mov     [rsp+28h],rbx
    mov     [rsp+30h],r14
    mov     [rsp+38h],r12
    jmp     L5
L17:
    mov     rbx,[rsp+0E8h]
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0E0h]
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     r8,rax
    call    fn4
    mov     rax,[rsp+0E8h]
    mov     rcx,[rsp+0E0h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rcx
    jmp     L5
L18:
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
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
    mov     rax,[rsp+0E0h]
    mov     rcx,[rsp+0E8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+10h]
    call    fn9
    jmp     L13
L19:
    mov     r10,[rsp+40h]
    mov     [rsp+0E0h],r10
    lea     rdi,[k10]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+0E0h]
    mov     rdi,rcx
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
    jmp     L15
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
    jmp     L5
L22:
    ret
L23:
    ret

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,0Dh
    jae     L0
    lea     rdi,[rsp+30h]
    call    ryo_h_Abort
    ud2
L0:
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

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdi
    mov     r12,rdx
    cmp     rsi,9
    jae     L0
    lea     rdi,[rsp+30h]
    call    ryo_h_Abort
    ud2
L0:
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

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
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
    jmp     L0
L0:
    jmp     L3
L1:
    lea     r13,[rsp+10h]
    jmp     L2
L2:
    jmp     L6
L3:
    jmp     L4
    mov     r15d,1
    jmp     L5
L4:
    mov     r15d,0
L5:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,rbx
    mov     edx,4
    mov     rcx,r15
    mov     r8,rax
    movzx   ecx,cl
    call    fn4
    mov     eax,1
    imul    rax,4
    mov     rdi,rbx
    mov     rsi,r14
    mov     rdx,rax
    call    ryo_hr_Memmove
    jmp     L1
L6:
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn6
    mov     eax,1
    imul    rax,4
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    add     rsp,78h
    ret
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
L8:
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
    jmp     L6
    jmp     L5
L0:
    mov     rcx,[rbx]
    jmp     L2
L1:
    mov     rcx,[rbx+18h]
L2:
    mov     rdx,[rbx+10h]
    lea     r13,[rcx+rdx*8]
    mov     r14,[rbx+8]
    jmp     L3
L3:
    jmp     L7
L4:
    mov     [rbx+18h],rcx
    test    r12b,r12b
    je      L1
    jmp     L0
L5:
    mov     rcx,rax
    jmp     L4
L6:
    mov     r10,0FFFFFFFFFFFFFFFFh
    lea     rax,[rax+r10*8]
    mov     rcx,rax
    jmp     L4
L7:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r13
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
    mov     eax,1
    imul    rax,8
    mov     rdi,r13
    mov     rsi,r14
    mov     rdx,rax
    call    ryo_hr_Memcpy
    movzx   r12d,r12b
    mov     rax,[rbx+10h]
    add     rax,r12
    mov     [rbx+10h],rax
    mov     rax,[rbx+8]
    mov     r10d,1
    lea     rax,[rax+r10*8]
    mov     [rbx+8],rax
    mov     rax,r13
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
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

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,218h
    mov     [rsp+110h],rbx
    mov     [rsp+100h],r12
    mov     [rsp+0F0h],r13
    mov     [rsp+0E0h],r14
    mov     [rsp+0D0h],r15
    mov     [rsp+0C0h],rbp
    mov     rax,[rsp+220h]
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     [rsp+80h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rax
    mov     r14,r8
    mov     [rsp+68h],r9
L0:
    mov     rax,[rsp+0B0h]
    mov     [rsp+150h],rax
    mov     rbp,[rsp+0B8h]
    call    fn0
    cmp     rax,rbp
    jb      L1
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8,[rsp+70h]
    call    qword ptr [fn1.slot]
    jmp     L13
L1:
    cmp     r14d,0
    jne     L2
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8d,1
    mov     r9,[rsp+70h]
    movzx   r8d,r8b
    call    qword ptr [fn2.slot]
    jmp     L3
L2:
    mov     r11,r14
    sub     r11d,1
    mov     [rsp+60h],r11
    mov     rax,[rsp+0B0h]
    mov     [rsp+148h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+150h],rax
    mov     rax,[rsp+148h]
    mov     rcx,[rsp+150h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,[rsp+70h]
    call    fn3
    mov     [rsp+20h],rax
    jmp     L4
L3:
    jmp     L13
L4:
    mov     r11,[rsp+0B0h]
    mov     rbp,[rsp+0B8h]
    mov     r11,[rsp+20h]
    cmp     r11,rbp
    jb      L5
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,rbp
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+210h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rsp+0B0h]
    mov     r10,[rsp+20h]
    lea     rax,[rax+r10*8]
    mov     [rsp+140h],rax
    mov     rax,[rsp+140h]
    mov     [rsp+148h],rax
    mov     rax,[rsp+148h]
    mov     rax,[rax]
    mov     [rsp+150h],rax
    call    fn6
    mov     [rsp+88h],rax
    jmp     L14
L6:
    mov     r10,[rsp+28h]
    mov     [rsp+148h],r10
    mov     r11,[rsp+0B0h]
    mov     r14,[rsp+0B8h]
    mov     r11,[rsp+30h]
    cmp     r11,r14
    jb      L7
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+30h]
    mov     rsi,r14
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+210h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+0B0h]
    mov     r10,[rsp+30h]
    lea     rax,[rax+r10*8]
    mov     [rsp+130h],rax
    mov     rax,[rsp+148h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+130h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+138h]
    mov     rcx,[rsp+140h]
    mov     rdi,[rsp+38h]
    mov     rsi,rax
    mov     rdx,rcx
    call    fn9
    xor     eax,1
    test    al,al
    jne     L8
    jmp     L9
L8:
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r11,[rsp+48h]
    mov     [rsp+0A0h],r11
    mov     r12,[rsp+30h]
    mov     ebx,0
    mov     r11,[rsp+50h]
    mov     [rsp+98h],r11
    mov     rbp,[rsp+58h]
    mov     r13,[rsp+28h]
    jmp     L11
L9:
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r13,[rsp+48h]
    mov     r12,[rsp+30h]
    mov     rbx,[rsp+50h]
    mov     rbp,[rsp+58h]
    mov     r11,[rsp+28h]
    mov     [rsp+90h],r11
    jmp     L10
L10:
    mov     rax,[rsp+0B0h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+148h],rax
    mov     [rsp],r14
    mov     rax,[rsp+140h]
    mov     rcx,[rsp+148h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r15
    mov     rcx,r13
    mov     r8,r12
    mov     r9d,0
    movzx   r9d,r9b
    call    fn10
    mov     [rsp+148h],rax
    mov     rcx,[rsp+148h]
    cmp     rcx,0
    sete    cl
    mov     [rsp+0A0h],r13
    mov     [rsp+98h],rbx
    mov     rbx,rax
    mov     rax,rcx
    mov     r13,[rsp+90h]
L11:
    test    al,al
    je      L12
    mov     rax,[rsp+0B0h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+140h],rax
    mov     [rsp+128h],r14
    lea     rax,[rsp+128h]
    mov     [rsp+130h],rax
    mov     rax,[rsp+130h]
    mov     [rsp],rax
    mov     rax,[rsp+138h]
    mov     rcx,[rsp+140h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r15
    mov     rcx,[rsp+0A0h]
    mov     r8,r12
    mov     r9d,1
    movzx   r9d,r9b
    call    fn11
    mov     [rsp+148h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+140h]
    mov     rcx,[rsp+148h]
    cmp     rax,rcx
    jb      L19
    jmp     L20
L12:
    lea     rdi,[k12]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+120h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+0B8h]
    mov     rdi,rcx
    mov     rcx,rbx
    mov     r8,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [fn13.slot]
    mov     rax,[rsp+120h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+128h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+130h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+148h],rax
    mov     [rsp],r14
    mov     rax,[rsp+140h]
    mov     rcx,[rsp+148h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r15
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+98h]
    mov     r9,rbp
    mov     r8d,r8d
    call    fn14
    mov     [rsp+80h],r15
    mov     r11,[rsp+0A0h]
    mov     [rsp+78h],r11
    mov     [rsp+70h],r14
    mov     r14,[rsp+98h]
    mov     [rsp+68h],r13
    jmp     L0
L13:
    mov     rbx,[rsp+110h]
    mov     r12,[rsp+100h]
    mov     r13,[rsp+0F0h]
    mov     r14,[rsp+0E0h]
    mov     r15,[rsp+0D0h]
    mov     rbp,[rsp+0C0h]
    add     rsp,218h
    ret
L14:
    lea     rax,[rsp+150h]
    mov     [rsp+138h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+140h],rax
    mov     rax,[rsp+140h]
    mov     [rsp+148h],rax
    cmp     byte ptr [rsp+88h],0
    je      L18
    jmp     L17
L15:
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
    lea     r11,[L16]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
L16:
    .long   L22
    .long   L6
    .long   L21
L17:
    mov     rax,[rsp+148h]
    mov     r11,[rsp+68h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+50h],r11
    mov     [rsp+58h],rax
    jmp     L15
L18:
    mov     r11,[rsp+68h]
    mov     [rsp+28h],r11
    mov     r11,[rsp+20h]
    mov     [rsp+30h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+78h]
    mov     [rsp+48h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+50h],r11
    mov     qword ptr [rsp+58h],0
    jmp     L15
L19:
    lea     rdi,[k15]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+148h]
    mov     rdx,[rsp+140h]
    mov     rsi,[rsp+140h]
    mov     rdi,rcx
    mov     rcx,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    qword ptr [sym16]
    lea     rdi,[rsp+210h]
    call    ryo_h_Unreachable
    ud2
L20:
    mov     rax,[rsp+140h]
    mov     rcx,[rsp+148h]
    sub     rax,rcx
    mov     [rsp+138h],rax
    mov     rax,[rsp+0B0h]
    mov     rcx,[rsp+0B8h]
    mov     [rsp+120h],rcx
    mov     rcx,[rsp+148h]
    lea     rax,[rax+rcx*8]
    mov     [rsp+128h],rax
    mov     rax,[rsp+138h]
    mov     [rsp+130h],rax
    mov     rax,[rsp+128h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+130h]
    mov     [rsp+0B8h],rax
    mov     [rsp+80h],r15
    mov     r11,[rsp+0A0h]
    mov     [rsp+78h],r11
    mov     [rsp+70h],r14
    mov     r14,[rsp+98h]
    mov     qword ptr [rsp+68h],0
    jmp     L0
L21:
    lea     rdi,[rsp+210h]
    call    ryo_h_Unreachable
    ud2
L22:
    mov     r14,[rsp+38h]
    mov     r15,[rsp+40h]
    mov     r13,[rsp+48h]
    mov     r12,[rsp+30h]
    mov     rbx,[rsp+50h]
    mov     rbp,[rsp+58h]
    mov     r11,[rsp+28h]
    mov     [rsp+90h],r11
    jmp     L10
  ; OSR entries
    lea     r11,[L23]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L23:
    .long   L24
    .long   L25
    .long   L26
L24:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-250h]
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
    mov     [rdx-210h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-158h],r11
    mov     r11,[rsp]
    mov     [rdx-190h],r11
    mov     r11,[rsp+8]
    mov     [rdx-198h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1A8h],r11
    mov     r14,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L0
L25:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-260h]
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
    mov     [rdx-210h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-158h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-180h],r11
    mov     r14,[rsp]
    mov     r15,[rsp+8]
    mov     r13,[rsp+10h]
    mov     r12,[rsp+18h]
    mov     rbx,[rsp+20h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+50h]
    jmp     L10
L26:
    pop     rcx
    lea     rdx,[rsp+120h]
    lea     rsp,[rdx-260h]
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
    mov     [rdx-210h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-160h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-158h],r11
    mov     r11,[rsp]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+8]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+10h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+18h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1C0h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1B8h],r11
    lea     rsp,[rsp+50h]
    jmp     L15

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
    sub     rsp,298h
    mov     [rsp+180h],rbx
    mov     [rsp+170h],r12
    mov     [rsp+160h],r13
    mov     [rsp+150h],r14
    mov     [rsp+140h],r15
    mov     [rsp+130h],rbp
    mov     [rsp+0A0h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     [rsp+88h],r8
    mov     [rsp+80h],r9
    mov     r11,[rsp+2A0h]
    mov     [rsp+78h],r11
    cmp     rcx,[rsp+98h]
    jae     L0
    jmp     L15
L0:
    mov     r11,[rsp+98h]
    cmp     r11,[rsp+88h]
    ja      L16
    jmp     L15
L1:
    jmp     L2
    mov     r13,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+70h]
    jmp     L6
L2:
    mov     r10,[rsp+20h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+290h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L17
L3:
    mov     rax,[rsp+198h]
    cmp     rax,rbp
    jb      L5
    jmp     L4
L4:
    mov     rax,[rsp+0D8h]
    mov     rcx,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+0B8h]
    mov     rdi,[rsp+0C0h]
    mov     r8,[rsp+0C8h]
    mov     r9,[rsp+0D0h]
    jmp     L6
L5:
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L3
L6:
    mov     [rsp+120h],r13
    mov     rbx,[rsp+120h]
    lea     rbx,[r12+rbx*8]
    mov     [rsp+0F8h],r15
    mov     [rsp+0E0h],rax
    mov     rbp,rcx
    mov     [rsp+0E8h],rdx
    mov     [rsp+0F0h],rsi
    mov     [rsp+110h],rdi
    mov     [rsp+100h],r8
    mov     [rsp+108h],r9
L7:
    mov     rax,[rsp+198h]
    cmp     rax,rbx
    jae     L8
    lea     r15,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,[rsp+0F8h]
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,r15
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L7
L8:
    cmp     r13,[rsp+0E0h]
    jne     L9
    call    qword ptr [fn11.slot]
    mov     rbx,rax
    jmp     L18
L9:
    lea     rax,[rsp+190h]
    mov     [rsp+120h],rax
    mov     rax,[rsp+120h]
    mov     rdi,rax
    mov     rsi,rbp
    movzx   esi,sil
    call    fn2
    mov     r11,[rsp+0E0h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],r12
    mov     r11,[rsp+0F8h]
    mov     [rsp+30h],r11
    mov     [rsp+38h],r14
    mov     r11,[rsp+0E0h]
    mov     [rsp+40h],r11
    mov     [rsp+48h],rbp
    mov     [rsp+50h],rax
    mov     r11,[rsp+0F0h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+110h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+108h]
    mov     [rsp+70h],r11
    jmp     L1
L10:
    jmp     L11
L11:
    jmp     L19
L12:
    mov     r10,[rsp+100h]
    mov     [rsp+120h],r10
    mov     r12,[rsp+1A0h]
    jmp     L13
L13:
    jmp     L20
L14:
    cmp     r13,r14
    jae     L23
    jmp     L21
L15:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L16:
    mov     r11,[rsp+0A0h]
    mov     r10,[rsp+88h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+90h]
    mov     r10,[rsp+98h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+90h]
    mov     [rsp+190h],r10
    mov     r10,[rsp+0A0h]
    mov     [rsp+198h],r10
    mov     qword ptr [rsp+1A0h],0
    mov     [rsp+1A8h],rcx
    mov     r11,[rsp+88h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+0A0h]
    mov     [rsp+28h],r11
    mov     [rsp+30h],rax
    mov     r11,[rsp+78h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+98h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+48h],r11
    mov     qword ptr [rsp+50h],0
    mov     r11,[rsp+0A0h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+98h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+90h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+90h]
    mov     [rsp+70h],r11
    jmp     L1
L17:
    mov     rax,[rsp+120h]
    mov     r11,[rsp+28h]
    lea     rax,[r11+rax*8]
    mov     rbp,rax
    mov     r15,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r13,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r11,[rsp+40h]
    mov     [rsp+0D8h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+0D0h],r11
    jmp     L3
L18:
    xor     ebx,1
    test    bl,bl
    je      L12
    jmp     L10
L19:
    mov     r10,[rsp+0F8h]
    mov     [rsp+120h],r10
    lea     rdi,[k13]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+120h]
    mov     rdi,rcx
    mov     rsi,[rsp+0E8h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     eax,1
    imul    rax,8
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+0F8h]
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L12
L20:
    lea     rdi,[k15]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+0F0h]
    mov     edx,8
    mov     ecx,4
    mov     r8,r12
    mov     r9,rax
    call    fn14
    imul    r12,8
    mov     r11,[rsp+0F0h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],r12
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD80h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFD88h
    call    ryo_h_Memcpy
    mov     rax,[rsp+1A0h]
    mov     r11,[rsp+0E0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+120h],rax
    mov     rax,[rsp+120h]
    mov     r13d,0
    mov     r14,rax
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+108h]
    mov     r11,[rsp+0F0h]
    mov     [rsp+118h],r11
    jmp     L14
L21:
    jmp     L22
L22:
    jmp     L24
L23:
    mov     rax,[rsp+1A0h]
    mov     rbx,[rsp+180h]
    mov     r12,[rsp+170h]
    mov     r13,[rsp+160h]
    mov     r14,[rsp+150h]
    mov     r15,[rsp+140h]
    mov     rbp,[rsp+130h]
    add     rsp,298h
    ret
L24:
    lea     rdi,[k17]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     esi,1
    mov     rdx,rax
    call    fn18
    mov     rbx,r13
    add     rbx,1
    mov     [rsp+120h],r13
    mov     rax,[rsp+120h]
    mov     rcx,r15
    sub     rcx,1
    sub     rcx,rax
    lea     r12,[rbp+rcx*8]
    mov     rcx,[rsp+1A0h]
    add     rcx,rax
    mov     r11,[rsp+118h]
    lea     r13,[r11+rcx*8]
    jmp     L25
L25:
    lea     rdi,[k19]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     eax,1
    imul    rax,8
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     r13,rbx
    jmp     L14
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
L27:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-300h]
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
    mov     r11,[rdx-10h]
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
    mov     [rdx-290h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-270h],r11
    mov     r11,[rsp+8]
    mov     [rdx-268h],r11
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
    mov     r11,[rsp+48h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-220h],r11
    lea     rsp,[rsp+70h]
    jmp     L1
L28:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-310h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+70h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+60h]
    mov     [rdx-290h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1C0h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L3
L29:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-310h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+70h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+60h]
    mov     [rdx-290h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-198h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-188h],r11
    mov     rbx,[rsp]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    lea     rsp,[rsp+80h]
    jmp     L7
L30:
    ret
L31:
    ret
L32:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2D0h]
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
    mov     [rdx-290h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-178h],r11
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L14

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,298h
    mov     [rsp+180h],rbx
    mov     [rsp+170h],r12
    mov     [rsp+160h],r13
    mov     [rsp+150h],r14
    mov     [rsp+140h],r15
    mov     [rsp+130h],rbp
    mov     [rsp+0A0h],rdi
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     [rsp+88h],r8
    mov     [rsp+80h],r9
    mov     r11,[rsp+2A0h]
    mov     [rsp+78h],r11
    cmp     rcx,[rsp+98h]
    jae     L0
    jmp     L15
L0:
    mov     r11,[rsp+98h]
    cmp     r11,[rsp+88h]
    ja      L16
    jmp     L15
L1:
    jmp     L2
    mov     r13,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r15,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+70h]
    jmp     L6
L2:
    mov     r10,[rsp+20h]
    mov     [rsp],r10
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+290h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L17
L3:
    mov     rax,[rsp+198h]
    cmp     rax,rbp
    jb      L5
    jmp     L4
L4:
    mov     rax,[rsp+0D8h]
    mov     rcx,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+0B8h]
    mov     rdi,[rsp+0C0h]
    mov     r8,[rsp+0C8h]
    mov     r9,[rsp+0D0h]
    jmp     L6
L5:
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    lea     rbx,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,r15
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,rbx
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L3
L6:
    mov     [rsp+120h],r13
    mov     rbx,[rsp+120h]
    lea     rbx,[r12+rbx*8]
    mov     [rsp+0F8h],r15
    mov     [rsp+0E0h],rax
    mov     rbp,rcx
    mov     [rsp+0E8h],rdx
    mov     [rsp+0F0h],rsi
    mov     [rsp+110h],rdi
    mov     [rsp+100h],r8
    mov     [rsp+108h],r9
L7:
    mov     rax,[rsp+198h]
    cmp     rax,rbx
    jae     L8
    lea     r15,[rsp+190h]
    mov     rax,[rsp+198h]
    mov     rdi,r14
    mov     rsi,rax
    mov     rdx,[rsp+0F8h]
    call    fn1
    mov     [rsp+126h],al
    movzx   eax,byte ptr [rsp+126h]
    mov     rdi,r15
    mov     rsi,rax
    movzx   esi,sil
    call    fn2
    jmp     L7
L8:
    cmp     r13,[rsp+0E0h]
    jne     L9
    call    qword ptr [fn11.slot]
    mov     rbx,rax
    jmp     L18
L9:
    lea     rax,[rsp+190h]
    mov     [rsp+120h],rax
    mov     rax,[rsp+120h]
    mov     rdi,rax
    mov     rsi,rbp
    movzx   esi,sil
    call    fn2
    mov     r11,[rsp+0E0h]
    mov     [rsp+20h],r11
    mov     [rsp+28h],r12
    mov     r11,[rsp+0F8h]
    mov     [rsp+30h],r11
    mov     [rsp+38h],r14
    mov     r11,[rsp+0E0h]
    mov     [rsp+40h],r11
    mov     [rsp+48h],rbp
    mov     [rsp+50h],rax
    mov     r11,[rsp+0F0h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+110h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+100h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+108h]
    mov     [rsp+70h],r11
    jmp     L1
L10:
    jmp     L11
L11:
    jmp     L19
L12:
    mov     r10,[rsp+100h]
    mov     [rsp+120h],r10
    mov     r12,[rsp+1A0h]
    jmp     L13
L13:
    jmp     L20
L14:
    cmp     r13,r14
    jae     L23
    jmp     L21
L15:
    lea     rdi,[rsp+290h]
    call    ryo_h_Abort
    ud2
L16:
    mov     r11,[rsp+0A0h]
    mov     r10,[rsp+88h]
    lea     rax,[r11+r10*8]
    mov     r11,[rsp+90h]
    mov     r10,[rsp+98h]
    lea     rcx,[r11+r10*8]
    mov     r10,[rsp+90h]
    mov     [rsp+190h],r10
    mov     r10,[rsp+0A0h]
    mov     [rsp+198h],r10
    mov     qword ptr [rsp+1A0h],0
    mov     [rsp+1A8h],rcx
    mov     r11,[rsp+88h]
    mov     [rsp+20h],r11
    mov     r11,[rsp+0A0h]
    mov     [rsp+28h],r11
    mov     [rsp+30h],rax
    mov     r11,[rsp+78h]
    mov     [rsp+38h],r11
    mov     r11,[rsp+98h]
    mov     [rsp+40h],r11
    mov     r11,[rsp+80h]
    mov     [rsp+48h],r11
    mov     qword ptr [rsp+50h],0
    mov     r11,[rsp+0A0h]
    mov     [rsp+58h],r11
    mov     r11,[rsp+98h]
    mov     [rsp+60h],r11
    mov     r11,[rsp+90h]
    mov     [rsp+68h],r11
    mov     r11,[rsp+90h]
    mov     [rsp+70h],r11
    jmp     L1
L17:
    mov     rax,[rsp+120h]
    mov     r11,[rsp+28h]
    lea     rax,[r11+rax*8]
    mov     rbp,rax
    mov     r15,[rsp+30h]
    mov     r14,[rsp+38h]
    mov     r13,[rsp+20h]
    mov     r12,[rsp+28h]
    mov     r11,[rsp+40h]
    mov     [rsp+0D8h],r11
    mov     r11,[rsp+48h]
    mov     [rsp+0A8h],r11
    mov     r11,[rsp+50h]
    mov     [rsp+0B0h],r11
    mov     r11,[rsp+58h]
    mov     [rsp+0B8h],r11
    mov     r11,[rsp+60h]
    mov     [rsp+0C0h],r11
    mov     r11,[rsp+68h]
    mov     [rsp+0C8h],r11
    mov     r11,[rsp+70h]
    mov     [rsp+0D0h],r11
    jmp     L3
L18:
    xor     ebx,1
    test    bl,bl
    je      L12
    jmp     L10
L19:
    mov     r10,[rsp+0F8h]
    mov     [rsp+120h],r10
    lea     rdi,[k13]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+120h]
    mov     rdi,rcx
    mov     rsi,[rsp+0E8h]
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     eax,1
    imul    rax,8
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+0F8h]
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L12
L20:
    lea     rdi,[k15]
    call    ryo_hr_AddrAbs
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+0F0h]
    mov     edx,8
    mov     ecx,4
    mov     r8,r12
    mov     r9,rax
    call    fn14
    imul    r12,8
    mov     r11,[rsp+0F0h]
    mov     [rsp+10h],r11
    mov     [rsp+18h],r12
    lea     rdi,[rsp+290h]
    mov     esi,0FFFFFD80h
    mov     edx,0FFFFFE90h
    mov     ecx,0FFFFFD88h
    call    ryo_h_Memcpy
    mov     rax,[rsp+1A0h]
    mov     r11,[rsp+0E0h]
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+120h],rax
    mov     rax,[rsp+120h]
    mov     r13d,0
    mov     r14,rax
    mov     r15,[rsp+0E0h]
    mov     rbp,[rsp+108h]
    mov     r11,[rsp+0F0h]
    mov     [rsp+118h],r11
    jmp     L14
L21:
    jmp     L22
L22:
    jmp     L24
L23:
    mov     rax,[rsp+1A0h]
    mov     rbx,[rsp+180h]
    mov     r12,[rsp+170h]
    mov     r13,[rsp+160h]
    mov     r14,[rsp+150h]
    mov     r15,[rsp+140h]
    mov     rbp,[rsp+130h]
    add     rsp,298h
    ret
L24:
    lea     rdi,[k17]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     esi,1
    mov     rdx,rax
    call    fn18
    mov     rbx,r13
    add     rbx,1
    mov     [rsp+120h],r13
    mov     rax,[rsp+120h]
    mov     rcx,r15
    sub     rcx,1
    sub     rcx,rax
    lea     r12,[rbp+rcx*8]
    mov     rcx,[rsp+1A0h]
    add     rcx,rax
    mov     r11,[rsp+118h]
    lea     r13,[r11+rcx*8]
    jmp     L25
L25:
    lea     rdi,[k19]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,r13
    mov     edx,8
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn14
    mov     eax,1
    imul    rax,8
    mov     rdi,r13
    mov     rsi,r12
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     r13,rbx
    jmp     L14
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
L27:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-300h]
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
    mov     r11,[rdx-10h]
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
    mov     [rdx-290h],r11
    mov     r11,[rsp+60h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-170h],r11
    mov     r11,[rsp]
    mov     [rdx-270h],r11
    mov     r11,[rsp+8]
    mov     [rdx-268h],r11
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
    mov     r11,[rsp+48h]
    mov     [rdx-228h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-220h],r11
    lea     rsp,[rsp+70h]
    jmp     L1
L28:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-310h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+70h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+60h]
    mov     [rdx-290h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-1B8h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-1E8h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1E0h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1D8h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-1D0h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-1C8h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-1C0h],r11
    mov     rbp,[rsp]
    mov     r15,[rsp+8]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     r12,[rsp+20h]
    lea     rsp,[rsp+80h]
    jmp     L3
L29:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-310h]
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
    mov     r11,[rdx-10h]
    mov     [rsp+48h],r11
    mov     r11,[rdx-0A0h]
    mov     [rsp+50h],r11
    mov     r11,[rdx-0D8h]
    mov     [rsp+58h],r11
    mov     r11,[rdx-170h]
    mov     [rsp+60h],r11
    mov     r11,[rdx-168h]
    mov     [rsp+68h],r11
    mov     r11,[rdx-110h]
    mov     [rsp+70h],r11
    mov     [rdx-110h],rbx
    mov     [rdx-120h],r12
    mov     [rdx-130h],r13
    mov     [rdx-140h],r14
    mov     [rdx-150h],r15
    mov     [rdx-160h],rbp
    mov     r11,[rsp+60h]
    mov     [rdx-290h],r11
    mov     r11,[rsp+68h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+70h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+8]
    mov     [rdx-198h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-1B0h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-1A8h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-1A0h],r11
    mov     r11,[rsp+48h]
    mov     [rdx-180h],r11
    mov     r11,[rsp+50h]
    mov     [rdx-190h],r11
    mov     r11,[rsp+58h]
    mov     [rdx-188h],r11
    mov     rbx,[rsp]
    mov     r14,[rsp+10h]
    mov     r13,[rsp+18h]
    mov     rbp,[rsp+28h]
    mov     r12,[rsp+30h]
    lea     rsp,[rsp+80h]
    jmp     L7
L30:
    ret
L31:
    ret
L32:
    pop     rcx
    lea     rdx,[rsp+170h]
    lea     rsp,[rdx-2D0h]
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
    mov     [rdx-290h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-288h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-170h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-178h],r11
    mov     r13,[rsp]
    mov     r14,[rsp+8]
    mov     r15,[rsp+10h]
    mov     rbp,[rsp+18h]
    lea     rsp,[rsp+40h]
    jmp     L14

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     [rsp+50h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rdx
    mov     r14,rcx
    cmp     r12,0
    jne     L0
    mov     r13d,0
    jmp     L4
L0:
    cmp     r13,r12
    jb      L1
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L1:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,0
    mov     rcx,r13
    mov     r8,rax
    call    fn1
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
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
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     r13,[rsp+18h]
    mov     r11d,0
    cmp     r11,r13
    jb      L2
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     edi,0
    mov     rsi,r13
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    lea     rdi,[sym6]
    call    ryo_hr_AddrSym
    mov     rcx,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rsi,[rsp+40h]
    mov     rdi,rcx
    mov     rcx,r14
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    rax
    mov     r13,rax
    cmp     r13,r12
    jb      L3
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L3:
    lea     rdi,[k7]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     edx,0
    mov     rcx,r13
    mov     r8,rax
    call    fn1
L4:
    mov     rax,r13
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    mov     r14,[rsp+50h]
    add     rsp,98h
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0D8h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+78h],rdi
    cmp     rsi,0
    jne     L0
    mov     eax,0
    jmp     L12
L0:
    lea     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rcx
    mov     [rsp+68h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+70h],rax
    mov     [rsp+50h],rdi
    mov     rax,[rsp+50h]
    mov     eax,[rax]
    mov     [rsp+58h],eax
    mov     eax,[rsp+58h]
    mov     [rsp+54h],eax
    mov     eax,[rsp+54h]
    mov     [rsp+5Ch],eax
    mov     rax,[rsp+78h]
    mov     r10d,1
    lea     rax,[rax+r10*4]
    lea     rcx,[rsp+5Ch]
    mov     rdx,[rsp+78h]
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rcx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+50h],0
    mov     rax,[rsp+10h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+40h],rax
    mov     eax,2
    sub     rax,1
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     r11,rsi
    sub     r11,rax
    mov     rax,r11
    mov     [rsp+18h],rax
    mov     rax,[rsp+78h]
    mov     rcx,[rsp+18h]
    lea     rax,[rax+rcx*4]
    mov     rbx,rax
    mov     r12,rsi
L1:
    mov     rax,[rsp+48h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    cmp     rax,rbx
    jae     L6
    mov     r11d,2
    cmp     r11,2
    sete    al
    mov     [rsp+5Ah],al
    movzx   eax,byte ptr [rsp+5Ah]
    test    al,al
    je      L4
    lea     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L2
    mov     rbx,rax
    jmp     L17
L2:
    lea     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L3
    mov     rbx,rax
    jmp     L17
L3:
    jmp     L5
L4:
    lea     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     rdi,rax
    mov     rsi,rcx
    call    fn0
    jmp     L5
    mov     rbx,rax
    jmp     L17
L5:
    jmp     L1
L6:
    mov     rax,[rsp+78h]
    lea     rax,[rax+r12*4]
    mov     [rsp+18h],rax
L7:
    mov     rax,[rsp+48h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    cmp     rax,rcx
    sete    al
    mov     [rsp+5Bh],al
    movzx   eax,byte ptr [rsp+5Bh]
    test    al,al
    je      L8
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    jmp     L9
L8:
    mov     rax,[rsp+48h]
    mov     [rsp+10h],rax
L9:
    mov     rax,[rsp+10h]
    mov     [rsp+48h],rax
    lea     rax,[rsp+60h]
    mov     [rsp+10h],rax
    lea     rax,[rsp+38h]
    mov     rcx,[rsp+10h]
    mov     rdi,rcx
    mov     rsi,rax
    call    fn0
    jmp     L10
    mov     rbx,rax
    jmp     L17
L10:
    movzx   eax,byte ptr [rsp+5Bh]
    test    al,al
    je      L11
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    mov     r11,[rsp+40h]
    mov     rax,[rsp+50h]
    jmp     L12
L11:
    jmp     L7
L12:
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    add     rsp,0D8h
    ret
L13:
    mov     [rsp],rbx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    call    ryo_h_Resume
    ud2
L14:
    lea     rax,[rsp+38h]
    mov     rdi,rax
    call    qword ptr [fn4.slot]
    jmp     L15
    jmp     L18
L15:
    jmp     L13
L16:
    call    qword ptr [sym5]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L17:
    jmp     L14
L18:
    jmp     L16
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
L21:
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
    jmp     L7
L22:
    ret
L23:
    ret
L24:
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
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
    jmp     L0
L0:
    jmp     L3
L1:
    mov     r15,[r12+10h]
    jmp     L2
L2:
    jmp     L6
L3:
    jmp     L4
    mov     ebp,1
    jmp     L5
L4:
    mov     ebp,0
L5:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r14
    mov     edx,4
    mov     rcx,rbp
    mov     r8,rax
    movzx   ecx,cl
    call    fn2
    mov     eax,1
    imul    rax,4
    mov     rdi,r14
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memmove
    jmp     L1
L6:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,r15
    mov     rsi,rbx
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn4
    mov     eax,1
    imul    rax,4
    mov     rdi,rbx
    mov     rsi,r15
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rax,[r12+10h]
    mov     [r12],rax
    movzx   r13d,r13b
    mov     rax,[r12+18h]
    add     rax,r13
    mov     [r12+18h],rax
    mov     rax,[r12+10h]
    mov     r10d,1
    lea     rax,[rax+r10*4]
    mov     [r12+10h],rax
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
  ; OSR entries
    lea     r11,[L7]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L7:
    .long   L8
L8:
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,168h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
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
    jmp     L11
L1:
    cmp     r12d,0
    jne     L2
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,rbx
    call    qword ptr [fn2.slot]
    jmp     L3
L2:
    sub     r12d,1
    mov     rax,[rsp+10h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+40h]
    mov     rdi,rcx
    mov     rsi,rax
    mov     rdx,rbx
    call    qword ptr [fn3.slot]
    mov     r14,rax
    jmp     L4
L3:
    jmp     L11
L4:
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
    lea     r11,[L5]
    movsxd  r10,[r11+r10*4]
    add     r10,r11
    jmp     r10
    int3
    int3
L5:
    .long   L9
    .long   L6
    .long   L14
L6:
    mov     r11,[rsp+10h]
    mov     r15,[rsp+18h]
    cmp     r14,r15
    jb      L7
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+10h]
    lea     rax,[rax+r14*4]
    mov     [rsp+30h],rax
    mov     [rsp+38h],r13
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    call    fn6
    test    al,al
    je      L8
    jmp     L9
L8:
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    mov     [rsp+0C0h],rbx
    lea     rax,[rsp+0C0h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     rdx,[rsp+28h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rcx,rdx
    mov     rdx,r14
    call    qword ptr [fn7.slot]
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    mov     r15,rax
    add     r15,1
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    cmp     rax,r15
    jb      L12
    jmp     L13
L9:
    mov     rax,[rsp+10h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r14
    mov     rcx,rbx
    call    qword ptr [fn8.slot]
    mov     r14,rax
    mov     rax,[rsp+10h]
    mov     [rsp+30h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    lea     rdi,[k9]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+0A8h]
    mov     rdx,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdi,rcx
    mov     rcx,r14
    mov     r8,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    fn10
    mov     rax,[rsp+0A8h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+40h],rax
    mov     rax,[rsp+0B8h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+0C0h]
    mov     [rsp+30h],rax
    lea     rdi,[k11]
    call    ryo_hr_AddrAbs
    lea     rcx,[rsp+98h]
    mov     rdx,[rsp+28h]
    mov     rsi,[rsp+30h]
    mov     rdi,rcx
    mov     ecx,1
    mov     r8,rax
    mov     r10,rsi
    mov     rsi,rdx
    mov     rdx,r10
    call    fn10
    mov     rax,[rsp+98h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+18h],rax
    mov     r14,[rsp+0C0h]
    mov     r11d,0
    cmp     r11,r14
    jb      L10
    lea     rdi,[k13]
    call    ryo_hr_AddrAbs
    mov     edi,0
    mov     rsi,r14
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rax,[rsp+0B8h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     rdi,rax
    mov     rsi,rcx
    mov     rdx,r13
    mov     rcx,r12
    mov     r8,rbx
    mov     ecx,ecx
    call    fn15
    mov     rax,[rsp+0B0h]
    mov     r13,rax
    jmp     L0
L11:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    add     rsp,168h
    ret
L12:
    lea     rdi,[k16]
    call    ryo_hr_AddrAbs
    mov     rcx,[rsp+38h]
    mov     rdx,[rsp+38h]
    mov     rdi,r15
    mov     rsi,rcx
    mov     rcx,rax
    call    qword ptr [sym17]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rsp+38h]
    sub     rax,r15
    mov     [rsp+30h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+0B0h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+0B8h],rax
    mov     rax,[rsp+0B0h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    lea     rax,[rax+r15*4]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+0A0h]
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+0C0h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     r13d,0
    jmp     L0
L14:
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
  ; OSR entries
    lea     r11,[L15]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L15:
    .long   L16
L16:
    pop     rcx
    lea     rdx,[rsp+0E0h]
    lea     rsp,[rdx-1B0h]
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
    mov     r11,[rsp+18h]
    mov     [rdx-138h],r11
    mov     r11,[rsp+20h]
    mov     [rdx-130h],r11
    mov     r11,[rsp+28h]
    mov     [rdx-128h],r11
    mov     r11,[rsp+30h]
    mov     [rdx-120h],r11
    mov     r11,[rsp+38h]
    mov     [rdx-150h],r11
    mov     r11,[rsp+40h]
    mov     [rdx-148h],r11
    mov     rbx,[rsp]
    mov     r12,[rsp+8]
    mov     r13,[rsp+10h]
    lea     rsp,[rsp+50h]
    jmp     L0

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    sub     rsp,48h
    mov     [rsp+30h],rbx
    mov     [rsp+20h],r12
    mov     [rsp+10h],r13
    mov     rbx,rdi
    mov     r12,rsi
    mov     r11,rax
    mov     r10,rdx
    mov     rax,rdx
    mul     rcx
    mov     r13,rax
    mov     rax,r11
    mov     rdx,r10
    jae     L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    mov     esi,3Dh
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    cmp     rbx,r12
    jae     L1
    mov     rax,r12
    sub     rax,rbx
    jmp     L2
L1:
    sub     rbx,r12
    mov     rax,rbx
L2:
    cmp     r13,rax
    setbe   al
    movzx   eax,al
    mov     rbx,[rsp+30h]
    mov     r12,[rsp+20h]
    mov     r13,[rsp+10h]
    add     rsp,48h
    ret

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
    mov     r11d,3E8h
    cmp     r11d,0
    jne     L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym1]
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
L0:
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
    mov     [rsp+10h],rdx
    cmp     r12,10h
    ja      L9
    mov     edi,1
    mov     rsi,r12
    call    qword ptr [fn0.slot]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    mov     rax,[rsp+28h]
    mov     [rsp+0A0h],rax
    mov     rax,[rsp+30h]
    mov     [rsp+0A8h],rax
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
    .long   L20
    .long   L3
    .long   L2
L2:
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L3:
    cmp     rbp,0
    jbe     L0
    mov     r13,rbp
    sub     r13,1
    jae     L4
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     r13,r15
    jb      L5
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L5:
    lea     rax,[r14+r13*4]
    mov     r13d,[rax]
    cmp     rbp,r15
    jb      L6
    lea     rdi,[k6]
    call    ryo_hr_AddrAbs
    mov     rdi,rbp
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L6:
    lea     rax,[r14+rbp*4]
    mov     eax,[rax]
    cmp     eax,r13d
    jae     L0
    mov     r13,rbp
    sub     r13,1
    jae     L7
    lea     rdi,[k8]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L7:
    lea     rdi,[k10]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,r13
    mov     rcx,rbp
    mov     r8,rax
    call    fn11
    sub     rbp,1
    jae     L8
    lea     rdi,[k12]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L8:
    jmp     L3
L9:
    mov     r11d,2
    cmp     r11,0
    jne     L10
    lea     rdi,[k14]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym15]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rdi,r12
    mov     esi,2
    call    ryo_hr_DivUW64
    mov     r13,rax
    lea     rdi,[k16]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    qword ptr [fn17.slot]
    mov     rdi,rax
    mov     rsi,rdx
    mov     rdx,[rsp+10h]
    call    fn18
    lea     rdi,[k19]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,r13
    mov     rcx,rax
    call    qword ptr [fn20.slot]
    mov     rdi,rax
    mov     rsi,rdx
    mov     rdx,[rsp+10h]
    call    fn18
    mov     rdi,[rsp+10h]
    call    qword ptr [fn22.slot]
    mov     r14,rbx
    mov     ebx,0
    mov     [rsp+18h],r12
    mov     r12,r13
    mov     rbp,[rsp+10h]
L11:
    cmp     rbx,r13
    jae     L19
    cmp     r12,[rsp+18h]
    jae     L19
    cmp     rbx,[rsp+18h]
    jb      L12
    lea     rdi,[k23]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,[rsp+18h]
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L12:
    lea     rax,[r14+rbx*4]
    mov     r15d,[rax]
    cmp     r12,[rsp+18h]
    jb      L13
    lea     rdi,[k25]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,[rsp+18h]
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L13:
    lea     rax,[r14+r12*4]
    mov     eax,[rax]
    cmp     eax,r15d
    jb      L16
    cmp     rbx,[rsp+18h]
    jb      L14
    lea     rdi,[k27]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,[rsp+18h]
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L14:
    lea     rax,[r14+rbx*4]
    mov     eax,[rax]
    mov     rdi,rbp
    mov     rsi,rax
    mov     esi,esi
    call    fn29
    mov     r15,rbx
    add     r15,1
    jae     L15
    lea     rdi,[k30]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym31]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L15:
    mov     rbx,r15
    jmp     L11
L16:
    cmp     r12,[rsp+18h]
    jb      L17
    lea     rdi,[k32]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,[rsp+18h]
    mov     rdx,rax
    call    qword ptr [sym5]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L17:
    lea     rax,[r14+r12*4]
    mov     eax,[rax]
    mov     rdi,rbp
    mov     rsi,rax
    mov     esi,esi
    call    fn29
    mov     r15,r12
    add     r15,1
    jae     L18
    lea     rdi,[k35]
    call    ryo_hr_AddrAbs
    mov     rdi,rax
    call    qword ptr [sym31]
    lea     rdi,[rsp+120h]
    call    ryo_h_Unreachable
    ud2
L18:
    mov     r12,r15
    jmp     L11
L19:
    lea     rdi,[k37]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,[rsp+18h]
    mov     rdx,rbx
    mov     rcx,r13
    mov     r8,rax
    call    qword ptr [fn38.slot]
    mov     rdi,rbp
    mov     rsi,rax
    call    qword ptr [fn39.slot]
    lea     rdi,[k40]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,[rsp+18h]
    mov     rdx,r12
    mov     rcx,rax
    call    qword ptr [fn41.slot]
    mov     rdi,rbp
    mov     rsi,rax
    call    qword ptr [fn39.slot]
    mov     rdi,rbp
    call    qword ptr [fn43.slot]
    mov     rbx,rax
    mov     r12,rdx
    lea     rdi,[k44]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,[rsp+18h]
    mov     rdx,rbx
    mov     rcx,r12
    mov     r8,rax
    call    qword ptr [fn45.slot]
L20:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,128h
    ret
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
L23:
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
    jmp     L3
L24:
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
    mov     r11,[rsp+20h]
    mov     [rdx-108h],r11
    mov     rbx,[rsp]
    mov     r13,[rsp+8]
    mov     r12,[rsp+10h]
    mov     r14,[rsp+18h]
    mov     rbp,[rsp+28h]
    lea     rsp,[rsp+290h]
    jmp     L11

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
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rsi
    test    dil,dil
    jne     L0
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0DDh
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

fn std::hint::select_unpredictable::<*mut u32>
    sub     rsp,98h
    mov     [rsp+80h],rbx
    mov     [rsp+70h],r12
    mov     [rsp+60h],r13
    mov     rbx,rdi
    mov     [rsp+40h],rsi
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    lea     r12,[rsp+38h]
    lea     rax,[rsp+40h]
    mov     [rsp+48h],rax
    mov     r13,[rsp+48h]
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
    mov     rax,[rsp+58h]
    mov     rdi,rax
    call    qword ptr [sym2]
    jmp     L0
    mov     r12,rax
    jmp     L8
L0:
    jmp     L5
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L6
L2:
    mov     [rsp+20h],r12
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L3:
    lea     rax,[rsp+50h]
    mov     rdi,rax
    call    qword ptr [fn4.slot]
    jmp     L4
    jmp     L9
L4:
    jmp     L2
L5:
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
    jmp     L1
L6:
    mov     rax,[rsp+58h]
    mov     rbx,[rsp+80h]
    mov     r12,[rsp+70h]
    mov     r13,[rsp+60h]
    add     rsp,98h
    ret
L7:
    call    qword ptr [sym6]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L8:
    jmp     L3
L9:
    jmp     L7
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
L11:
    ret
L12:
    ret
L13:
    ret
L14:
    ret

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
    sub     rsp,38h
    mov     [rsp+10h],esi
    mov     [rsp+14h],edx
    mov     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     eax,[rsp+20h]
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
    jmp     L0
    mov     rbx,rax
    mov     eax,1
    jmp     L5
L0:
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     eax,[rsp+10h]
    mov     ecx,[rsp+14h]
    mov     rdi,rbx
    mov     rsi,rax
    mov     rdx,rcx
    mov     esi,esi
    mov     edx,edx
    call    qword ptr [fn1.slot]
    jmp     L1
    mov     rbx,rax
    mov     eax,0
    jmp     L5
L1:
    mov     rbx,[rsp+20h]
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

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rbx
    mov     rbx,rdi
    mov     rax,rbx
    lea     rax,[rax+18h]
    mov     rdi,rax
    call    qword ptr [fn0.slot]
    jmp     L0
    mov     rcx,rax
    mov     eax,1
    mov     rbx,rcx
    jmp     L5
L0:
    mov     rdi,rbx
    mov     rsi,rax
    mov     esi,esi
    call    qword ptr [fn1.slot]
    jmp     L1
    mov     rbx,rax
    mov     eax,0
    jmp     L5
L1:
    mov     rbx,[rsp+10h]
    add     rsp,28h
    ret
L2:
    mov     [rsp],rbx
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
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

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,rdi
    mov     r12,rsi
    mov     rdi,r12
    call    ryo_hr_CtpopW64
    mov     r13,rax
    jmp     L2
L0:
    mov     rax,r12
    sub     rax,1
    and     rax,rbx
    cmp     rax,0
    sete    al
    movzx   eax,al
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
L1:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r14,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,2Ah
    shl     rax,1
    mov     r15,rax
    or      r15,1
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r14
    mov     rsi,r15
    mov     rdx,rax
    call    qword ptr [sym3]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L2:
    cmp     r13d,1
    jne     L1
    jmp     L0
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

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    sub     rsp,38h
    mov     [rsp+20h],rbx
    mov     [rsp+10h],r12
    mov     rbx,rdx
    cmp     rdi,rsi
    jb      L0
    mov     rbx,[rsp+20h]
    mov     r12,[rsp+10h]
    add     rsp,38h
    ret
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     eax,0C9h
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

fn std::ptr::copy::precondition_check
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
    mov     rdi,rbx
    mov     rsi,r13
    call    fn0
    mov     rbp,rax
    jmp     L0
    jmp     L16
L0:
    jmp     L8
L1:
    mov     rbx,[rsp+70h]
    mov     r12,[rsp+60h]
    mov     r13,[rsp+50h]
    mov     r14,[rsp+40h]
    mov     r15,[rsp+30h]
    mov     rbp,[rsp+20h]
    add     rsp,88h
    ret
L2:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     r15,rax
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     eax,0DDh
    shl     rax,1
    or      rax,1
    mov     rdi,r15
    mov     rsi,rax
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [sym3]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L3:
    test    r14b,r14b
    je      L7
    jmp     L5
L4:
    jmp     L2
L5:
    mov     rdi,r12
    mov     rsi,r13
    call    fn0
    jmp     L6
    jmp     L16
L6:
    jmp     L12
L7:
    cmp     rbx,0
    sete    cl
    xor     ecx,1
    test    cl,cl
    je      L2
    jmp     L13
L8:
    test    bpl,bpl
    je      L4
    jmp     L3
L9:
    jmp     L2
L10:
    jmp     L1
L11:
    cmp     r12,0
    sete    cl
    xor     ecx,1
    test    cl,cl
    je      L2
    jmp     L1
L12:
    test    al,al
    je      L9
    jmp     L10
L13:
    mov     rdi,r12
    mov     rsi,r13
    call    fn0
    jmp     L14
    jmp     L16
L14:
    test    al,al
    je      L9
    jmp     L11
L15:
    call    qword ptr [sym6]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L16:
    jmp     L15
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
L26:
    ret

fn std::ptr::copy_nonoverlapping::precondition_check
    sub     rsp,0A8h
    mov     [rsp+90h],rbx
    mov     [rsp+80h],r12
    mov     [rsp+70h],r13
    mov     [rsp+60h],r14
    mov     [rsp+50h],r15
    mov     [rsp+40h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     [rsp+30h],rdx
    mov     r14,rcx
    mov     [rsp+20h],r8
    mov     [rsp+10h],r9
    mov     r11,[rsp+20h]
    cmp     r11,0
    jne     L0
    mov     qword ptr [rsp+18h],1
    jmp     L1
L0:
    mov     r11,[rsp+30h]
    cmp     r11,0
    sete    al
    mov     [rsp+18h],rax
L1:
    mov     rdi,rbx
    mov     rsi,r14
    call    fn0
    mov     rbp,rax
    jmp     L2
    jmp     L21
L2:
    jmp     L13
L3:
    mov     rdi,r12
    mov     rsi,r14
    call    fn0
    mov     r15,rax
    jmp     L4
    jmp     L21
L4:
    jmp     L18
L5:
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+20h]
    call    qword ptr [fn2.slot]
    mov     [rsp+28h],rax
    jmp     L6
    jmp     L21
L6:
    jmp     L19
L7:
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     r13,rax
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     eax,11Bh
    shl     rax,1
    or      rax,1
    mov     rdi,r13
    mov     rsi,rax
    mov     edx,0
    mov     rcx,[rsp+10h]
    movzx   edx,dl
    call    qword ptr [sym5]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rbx,[rsp+90h]
    mov     r12,[rsp+80h]
    mov     r13,[rsp+70h]
    mov     r14,[rsp+60h]
    mov     r15,[rsp+50h]
    mov     rbp,[rsp+40h]
    add     rsp,0A8h
    ret
L9:
    cmp     byte ptr [rsp+18h],0
    je      L12
    jmp     L11
L10:
    jmp     L7
L11:
    jmp     L3
L12:
    cmp     rbx,0
    sete    al
    xor     eax,1
    test    al,al
    je      L7
    jmp     L3
L13:
    test    bpl,bpl
    je      L10
    jmp     L9
L14:
    cmp     byte ptr [rsp+18h],0
    je      L17
    jmp     L16
L15:
    jmp     L7
L16:
    jmp     L5
L17:
    cmp     r12,0
    sete    al
    xor     eax,1
    test    al,al
    je      L7
    jmp     L5
L18:
    test    r15b,r15b
    je      L15
    jmp     L14
L19:
    cmp     byte ptr [rsp+28h],0
    je      L7
    jmp     L8
L20:
    call    qword ptr [sym6]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L21:
    jmp     L20
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
    .long   L28
    .long   L29
    .long   L30
    .long   L31
    .long   L32
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
L29:
    ret
L30:
    ret
L31:
    ret
L32:
    ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    sub     rsp,18h
    call    qword ptr [fn0.slot]
    add     rsp,18h
    ret

fn std::ptr::swap::<u32>
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    lea     r13,[rsp+0Ch]
    jmp     L0
L0:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     rsi,r13
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
    mov     eax,1
    imul    rax,4
    mov     rdi,r13
    mov     rsi,rbx
    mov     rdx,rax
    call    ryo_hr_Memcpy
    jmp     L1
L1:
    jmp     L4
L2:
    lea     r13,[rsp+0Ch]
    jmp     L3
L3:
    jmp     L7
L4:
    jmp     L5
    mov     r14d,1
    jmp     L6
L5:
    mov     r14d,0
L6:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,rbx
    mov     edx,4
    mov     rcx,r14
    mov     r8,rax
    movzx   ecx,cl
    call    fn3
    mov     eax,1
    imul    rax,4
    mov     rdi,rbx
    mov     rsi,r12
    mov     rdx,rax
    call    ryo_hr_Memmove
    jmp     L2
L7:
    lea     rdi,[k4]
    call    ryo_hr_AddrAbs
    mov     rdi,r13
    mov     rsi,r12
    mov     edx,4
    mov     ecx,4
    mov     r8d,1
    mov     r9,rax
    call    fn1
    mov     eax,1
    imul    rax,4
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    ryo_hr_Memcpy
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
  ; OSR entries
    lea     r11,[L8]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L8:
    .long   L9
L9:
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
    jmp     L0
    mov     rbx,rax
    jmp     L3
L0:
    lea     rax,[rsp+18h]
    mov     rdi,r13
    mov     rsi,rax
    call    fn2
    jmp     L1
    mov     r12,rax
    jmp     L4
L1:
    movzx   eax,al
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    add     rsp,58h
    ret
L2:
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L3:
    mov     rax,rbx
    jmp     L2
L4:
    mov     rax,r12
    jmp     L2
  ; OSR entries
    lea     r11,[L5]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L5:
    .long   L6
L6:
    ret

fn std::slice::Iter::<'_, u32>::make_slice
    sub     rsp,68h
    mov     [rsp+50h],rbx
    mov     [rsp+40h],r12
    mov     [rsp+30h],r13
    mov     [rsp+20h],r14
    mov     [rsp+10h],r15
    mov     rbx,[rdi]
    jmp     L0
    mov     rax,[rdi+8]
    mov     r14,rax
    jmp     L2
L0:
    mov     r12,[rdi+8]
    mov     r13,[rdi]
    jmp     L1
L1:
    jmp     L5
L2:
    jmp     L3
L3:
    jmp     L7
L4:
    mov     r14,r15
    jmp     L2
L5:
    lea     rdi,[k0]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     rsi,r13
    mov     rdx,rax
    call    fn1
    mov     r11d,0
    cmp     r11,4
    jae     L6
    mov     r11d,4
    mov     r10,7FFFFFFFFFFFFFFFh
    cmp     r11,r10
    ja      L6
    sub     r12,r13
    mov     rdi,r12
    mov     esi,4
    call    ryo_hr_DivUW64
    mov     r15,rax
    jmp     L4
L6:
    lea     rdi,[k2]
    call    ryo_hr_AddrAbs
    mov     r12,rax
    lea     rdi,[k3]
    call    ryo_hr_AddrAbs
    mov     rdi,r12
    mov     esi,49h
    mov     rdx,rax
    call    qword ptr [sym4]
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L7:
    lea     rdi,[k5]
    call    ryo_hr_AddrAbs
    mov     rdi,rbx
    mov     esi,4
    mov     edx,4
    mov     rcx,r14
    mov     r8,rax
    call    fn6
    mov     rax,rbx
    mov     rdx,r14
    mov     rbx,[rsp+50h]
    mov     r12,[rsp+40h]
    mov     r13,[rsp+30h]
    mov     r14,[rsp+20h]
    mov     r15,[rsp+10h]
    add     rsp,68h
    ret
  ; OSR entries
    lea     r11,[L8]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L8:
    .long   L9
    .long   L10
L9:
    ret
L10:
    ret

fn std::slice::from_raw_parts::precondition_check
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rdi,rbx
    mov     rsi,rdx
    call    fn0
    mov     r15,rax
    jmp     L0
    jmp     L11
L0:
    jmp     L6
L1:
    cmp     r12,0
    je      L7
    jmp     L8
L2:
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L3:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rbp,rax
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     eax,117h
    shl     rax,1
    or      rax,1
    mov     rdi,rbp
    mov     rsi,rax
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [sym3]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     rbx,0
    sete    al
    xor     eax,1
    test    al,al
    je      L3
    jmp     L1
L5:
    jmp     L3
L6:
    test    r15b,r15b
    je      L5
    jmp     L4
L7:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L9
L8:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
L9:
    cmp     r13,rax
    ja      L3
    jmp     L2
L10:
    call    qword ptr [sym4]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L11:
    jmp     L10
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

fn std::slice::from_raw_parts_mut::precondition_check
    sub     rsp,78h
    mov     [rsp+60h],rbx
    mov     [rsp+50h],r12
    mov     [rsp+40h],r13
    mov     [rsp+30h],r14
    mov     [rsp+20h],r15
    mov     [rsp+10h],rbp
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,rcx
    mov     r14,r8
    mov     rdi,rbx
    mov     rsi,rdx
    call    fn0
    mov     r15,rax
    jmp     L0
    jmp     L11
L0:
    jmp     L6
L1:
    cmp     r12,0
    je      L7
    jmp     L8
L2:
    mov     rbx,[rsp+60h]
    mov     r12,[rsp+50h]
    mov     r13,[rsp+40h]
    mov     r14,[rsp+30h]
    mov     r15,[rsp+20h]
    mov     rbp,[rsp+10h]
    add     rsp,78h
    ret
L3:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     rbp,rax
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
    mov     eax,11Bh
    shl     rax,1
    or      rax,1
    mov     rdi,rbp
    mov     rsi,rax
    mov     edx,0
    mov     rcx,r14
    movzx   edx,dl
    call    qword ptr [sym3]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     rbx,0
    sete    al
    xor     eax,1
    test    al,al
    je      L3
    jmp     L1
L5:
    jmp     L3
L6:
    test    r15b,r15b
    je      L5
    jmp     L4
L7:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L9
L8:
    mov     rdi,7FFFFFFFFFFFFFFFh
    mov     rsi,r12
    call    ryo_hr_DivUW64
L9:
    cmp     r13,rax
    ja      L3
    jmp     L2
L10:
    call    qword ptr [sym4]
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L11:
    jmp     L10
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
    jbe     L1
    mov     rcx,[rbx+8]
    lea     r14,[rcx+rax*4]
    jmp     L0
L0:
    jmp     L2
L1:
    mov     rax,[rbx+10h]
    add     rax,r13
    mov     [rbx+10h],rax
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L2:
    lea     rdi,[k1]
    call    ryo_hr_AddrAbs
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
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rax,[rsp+28h]
    mov     [rsp+10h],rax
    mov     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rax,[rsp+18h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    jmp     L2
    jmp     L1
L0:
    add     rsp,38h
    ret
L1:
    jmp     L3
L2:
    mov     [rsp+8],rax
    mov     rcx,[rsp+8]
    lea     rcx,[rcx+rdx*4]
    mov     [rsp+10h],rcx
    mov     rcx,[rsp+10h]
    mov     rdx,rcx
L3:
    mov     rsi,rax
    call    qword ptr [fn0.slot]
    jmp     L0
  ; OSR entries
    lea     r11,[L4]
    movsxd  rax,[r11+rax*4]
    add     rax,r11
    jmp     rax
L4:
    .long   L5
L5:
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
    sub     rsp,58h
    mov     [rsp+40h],rbx
    mov     [rsp+30h],r12
    mov     [rsp+20h],r13
    mov     [rsp+10h],r14
    mov     rbx,rdi
    mov     r12,rsi
    mov     r13,[rbx+10h]
    mov     r11d,4
    cmp     r11,0
    je      L5
    jmp     L6
L0:
    mov     rdi,rbx
    call    qword ptr [fn0.slot]
    jmp     L1
    mov     r14,rax
    jmp     L7
L1:
    mov     rax,[rbx+8]
    lea     rax,[rax+r13*4]
    mov     [rax],r12d
    mov     rcx,r13
    add     rcx,1
    mov     [rbx+10h],rcx
    mov     rbx,[rsp+40h]
    mov     r12,[rsp+30h]
    mov     r13,[rsp+20h]
    mov     r14,[rsp+10h]
    add     rsp,58h
    ret
L2:
    mov     [rsp],r14
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L3:
    jmp     L2
L4:
    cmp     r13,rax
    je      L0
    jmp     L1
L5:
    mov     rax,0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rbx]
    jmp     L4
L7:
    jmp     L3
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
    jae     L1
    jmp     L0
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

