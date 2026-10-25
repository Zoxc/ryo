fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp],rax
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <&u32 as std::fmt::Debug>::fmt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp],rax
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <() as std::process::Termination>::report
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rcx
    mov     [rsp+8],r8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+8]
    call    fn0
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     qword ptr [rsp+8],20h
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],1
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <(u32, u32) as std::fmt::Debug>::fmt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rax,[k0]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],0
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym1]
    mov     rax,[rsp+70h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+70h]
    lea     rdx,[rdx+4]
    mov     [rsp+40h],rdx
    lea     rsi,[rsp+50h]
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+48h]
    mov     [rsp+20h],rdi
    lea     r8,[k2]
    mov     [rsp+28h],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    call    qword ptr [sym3]
    mov     [rsp+38h],rax
    lea     rax,[rsp+50h]
    mov     [rsp+30h],rax
    lea     rdx,[rsp+40h]
    mov     [rsp+20h],rdx
    lea     rsi,[k4]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    call    qword ptr [sym5]
    mov     [rsp+38h],rax
    lea     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     rdi,[rsp+38h]
    call    qword ptr [sym6]
    mov     [rsp+7Fh],al
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <[u32] as std::fmt::Debug>::fmt
    inc     qword ptr [jit_record]
    jns     L7
L0:
    sub     rsp,0A8h
    mov     [rsp+88h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+80h],rdx
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+80h]
    call    qword ptr [sym0]
    lea     rax,[rsp+60h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+88h]
    mov     rdi,[rsp+90h]
    mov     [rsp+20h],rdi
    mov     rcx,[rsp+20h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+18h],rcx
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    mov     rdi,[rsp+78h]
    call    qword ptr [sym1]
    mov     [rsp+9Fh],al
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    jmp     L5
L4:
    mov     rax,[rsp+40h]
    imul    rcx,[rsp+48h],4
    add     rax,rcx
    mov     [rsp+28h],rax
L5:
    mov     rax,[rsp+40h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+28h]
    mov     [rsp+58h],rdx
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+58h]
    call    fn2
    mov     [rsp+78h],rax
    jmp     L1
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <alloc::raw_vec::RawVec<(u32, u32)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    qword ptr [sym1]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <alloc::raw_vec::RawVec<u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    qword ptr [sym1]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     rax,[rsp+48h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+48h]
    mov     rdx,[rdx+8]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+48h]
    mov     rsi,[rsi+10h]
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     [rsp+28h],rax
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    lea     r11,[k0]
    mov     [rsp+8],r11
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+8]
    call    fn1
L1:
    imul    rax,[rsp+30h],8
    mov     [rsp+18h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFF0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_Memcpy
    add     rsp,58h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     rax,[rsp+48h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+48h]
    mov     rdx,[rdx+8]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+48h]
    mov     rsi,[rsi+10h]
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     [rsp+28h],rax
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    lea     r11,[k0]
    mov     [rsp+8],r11
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+30h]
    mov     r9,[rsp+8]
    call    fn1
L1:
    imul    rax,[rsp+30h],4
    mov     [rsp+18h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFF0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_Memcpy
    add     rsp,58h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::slice::sort::stable::merge::MergeState<(u32, u32)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,68h
    mov     [rsp+58h],rdi
    mov     rax,[rsp+58h]
    mov     rax,[rax+8]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+58h]
    mov     rdx,[rdx]
    mov     [rsp+50h],rdx
    mov     [rsp+30h],rdx
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L2:
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     [rsp+38h],rax
    mov     rdx,[rsp+58h]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+18h],rdx
    lea     rsi,[k0]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn1
L4:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],8
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L5
    mov     qword ptr [rsp+10h],8
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+26h]
    test    byte ptr [rsp+26h],0FFh
    je      L5
    mov     r10,[rsp+28h]
    sub     r10,[rsp+30h]
    shr     r10,3
    mov     [rsp+40h],r10
    jmp     L1
L5:
    lea     rax,[k2]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k3]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    ud2
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    lea     r8,[k5]
    mov     [rsp],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+40h]
    mov     r9,[rsp]
    call    fn6
L7:
    imul    rax,[rsp+40h],8
    mov     [rsp+10h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFB0h
    call    ryo_h_Memcpy
    add     rsp,68h
    ret
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     rax,[rsp+48h]
    mov     rax,[rax+8]
    mov     [rsp+40h],rax
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     r8,[rsp+40h]
    mov     [rsp+28h],r8
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     rsi,[k0]
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn1
L1:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+30h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    add     rsp,58h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::alloc::Global as std::clone::Clone>::clone
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::array::IntoIter<usize, 2> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L1
    mov     rsi,[rsp+28h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L2:
    add     rsp,38h
    ret
L3:
    jmp     L1
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hint::select_unpredictable::DropOnPanic<*const u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::hint::select_unpredictable::DropOnPanic<*mut u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    qword ptr [sym0]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+70h],rdx
    mov     rax,[rsp+80h]
    lea     rax,[rax+8]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx]
    mov     rsi,[rsp+70h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+78h]
    mov     [rsp+30h],rdi
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rcx
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    call    fn0
    mov     [rsp+50h],rax
    mov     rax,[rsp+80h]
    mov     rax,[rax]
    mov     qword ptr [rsp+8],1
    add     rax,[rsp+8]
    setb    cl
    mov     [rsp+68h],cl
    mov     [rsp+60h],rax
    test    byte ptr [rsp+68h],0FFh
    je      L1
    lea     rdi,[k1]
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+10h]
    call    qword ptr [sym2]
    ud2
L1:
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+60h]
    mov     [rax],rcx
    mov     rdx,[rsp+50h]
    mov     [rsp+88h],rdx
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L2
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Enumerate<std::slice::Iter<'_, u32>> as std::iter::Iterator>::fold::<u64, {closure@bench/sort.rs:46:37: 46:51}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp],rdi
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFB0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+10h]
    call    fn0
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::IntoIterator>::into_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+10h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+18h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::collect::<std::vec::Vec<u32>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0D8h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF48h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+0A8h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+0B8h]
    lea     rsi,[rsp]
    call    fn0
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+20h]
    add     rsp,0D8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0A8h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFF90h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+68h],rcx
    mov     [rsp+60h],rax
    mov     rdx,[rsp+88h]
    mov     rsi,[rsp+70h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+78h]
    mov     [rsp+48h],rdi
    mov     r8,[rsp+80h]
    mov     [rsp+50h],r8
    mov     [rsp+58h],rdx
    mov     rcx,[rsp+48h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rsi
    mov     rcx,[rsp+58h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],r8
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    lea     rdx,[rsp+8]
    call    fn0
    add     rsp,0A8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,98h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFB0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdi
    mov     r8,[rsp+88h]
    mov     [rsp+30h],r8
    mov     rcx,[rsp+50h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+8]
    call    fn0
    add     rsp,98h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::size_hint
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+8],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    lea     rax,[rax+8]
    mov     [rsp],rax
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp]
    call    fn0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::IntoIterator>::into_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::collect::<std::vec::Vec<(u32, u32)>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,0B8h
    mov     [rsp+8],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    lea     rdi,[rsp+98h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+90h]
    call    fn0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,0B8h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+40h],rcx
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+58h]
    mov     [rsp+30h],rdi
    mov     rcx,[rsp+28h]
    mov     [rsp+8],rcx
    mov     [rsp],rdx
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+40h]
    lea     rdx,[rsp]
    call    fn0
    add     rsp,78h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+38h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+48h]
    mov     [rsp+30h],rsi
    mov     rcx,[rsp+28h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    lea     rdx,[rsp]
    call    fn0
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::size_hint
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+8],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+10h]
    mov     [rsp],rax
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp]
    call    fn0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L20
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF88h
    xor     ecx,ecx
    mov     r8d,20h
    call    ryo_h_LoadCopy
    mov     byte ptr [rsp+47h],1
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    lea     rax,[rsp+70h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn0
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L3
    mov     rsi,[rsp+30h]
    lea     rdi,[rsp+50h]
    mov     [rsp+18h],rdi
    mov     byte ptr [rsp+47h],0
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn1
    mov     byte ptr [rsp+47h],1
    jmp     L1
L3:
    lea     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    add     rsp,88h
    ret
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L5:
    lea     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn3
    nop
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L7:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L9:
    jmp     L4
    nop
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L11:
    test    byte ptr [rsp+47h],0FFh
    je      L4
    jmp     L8
    ud2
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L13:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L6
    lea     rdi,[rsp+80h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L12
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L15:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L16:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L17:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L18:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L19:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L13
L20:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::iter::Iterator>::map::<u32, {closure@bench/sort.rs:52:37: 52:40}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+8],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rdx,[rsp+10h]
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::iter::range::RangeIteratorImpl>::spec_next
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+28h]
    lea     rdx,[rdx+8]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+27h],al
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+8],1
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    call    fn1
    mov     [rsp+10h],rax
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+10h]
    mov     [rax],rcx
    mov     rdx,[rsp+18h]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+30h],1
    jmp     L2
L1:
    mov     qword ptr [rsp+30h],0
L2:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::slice::SliceIndex<[T]>>::get_unchecked_mut::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L1
    mov     rdx,[rsp+78h]
    cmp     rdx,rax
    jb      L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+70h],0DAh
    mov     rsi,[rsp+70h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+20h],0DAh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0A8h
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+8],r8
    mov     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+60h],rdx
    cmp     rax,rdx
    jb      L5
    jmp     L6
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    imul    rcx,[rsp+60h],4
    add     rax,rcx
    mov     rsi,[rsp+48h]
    mov     [rsp+90h],rax
    mov     [rsp+98h],rsi
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+8]
    mov     [rsp],rdx
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp]
    call    qword ptr [sym0]
    ud2
L5:
    jmp     L3
L6:
    mov     rax,[rsp+68h]
    sub     rax,[rsp+60h]
    mov     qword ptr [rsp+50h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+78h]
    mov     [rsp+38h],rsi
    cmp     rsi,[rsp+68h]
    jae     L1
    jmp     L3
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0A8h
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+8],r8
    mov     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+60h],rdx
    cmp     rax,rdx
    jb      L5
    jmp     L6
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    imul    rcx,[rsp+60h],4
    add     rax,rcx
    mov     rsi,[rsp+48h]
    mov     [rsp+90h],rax
    mov     [rsp+98h],rsi
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+8]
    mov     [rsp],rdx
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp]
    call    qword ptr [sym0]
    ud2
L5:
    jmp     L3
L6:
    mov     rax,[rsp+68h]
    sub     rax,[rsp+60h]
    mov     qword ptr [rsp+50h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+78h]
    mov     [rsp+38h],rsi
    cmp     rsi,[rsp+68h]
    jae     L1
    jmp     L3
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+68h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+48h],rdx
    cmp     rdx,rax
    jae     L1
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+48h]
    sub     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    imul    rcx,[rsp+50h],4
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+68h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+48h],rdx
    cmp     rdx,rax
    jae     L1
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+48h]
    mov     rcx,[rsp]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+48h]
    sub     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    imul    rcx,[rsp+50h],4
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+38h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+38h]
    mov     qword ptr [rsp+18h],0
    mov     [rsp+20h],rax
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn0
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::IntoIterator>::into_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::enumerate
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+8]
    mov     rcx,[rsp+10h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+28h],0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L44
L0:
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF58h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rsi,[rsp+0B8h]
    cmp     rsi,0
    sete    [rsp+5Fh]
    jmp     L2
L1:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B0h]
    cmp     rdx,rax
    sete    [rsp+5Fh]
L2:
    test    byte ptr [rsp+5Fh],0FFh
    je      L3
    mov     byte ptr [rsp+6Eh],0
    lea     rsi,[rsp+98h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L11
L3:
    mov     byte ptr [rsp+6Eh],0
    mov     byte ptr [rsp+6Fh],1
    mov     qword ptr [rsp+80h],0
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L4
    mov     r9,[rsp+0B8h]
    mov     [rsp+78h],r9
    jmp     L5
L4:
    mov     rax,[rsp+0B8h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rax
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+38h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L27
    jmp     L26
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L6:
    lea     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+6Fh],0
    mov     rsi,[rsp+0B0h]
    mov     rdi,[rsp+80h]
    imul    rcx,rdi,4
    add     rsi,rcx
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+50h]
    call    fn1
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L30
    jmp     L29
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L8:
    lea     rax,[rsp+98h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn2
    jmp     L11
    nop     [rax+rax]
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L10:
    jmp     L5
L11:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L13:
    lea     rax,[rsp+98h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn3
    jmp     L22
    nop     [rax+rax]
    nop
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L15:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L17:
    jmp     L12
    nop
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L19:
    test    byte ptr [rsp+6Fh],0FFh
    je      L12
    jmp     L16
    nop     [rax+rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L40
L21:
    jmp     L14
    nop
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L41
L23:
    test    byte ptr [rsp+6Eh],0FFh
    je      L14
    jmp     L20
    nop     [rax+rax]
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L42
L25:
    jmp     L5
L26:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    lea     rsi,[k4]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    call    fn5
L27:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],4
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L28
    mov     qword ptr [rsp+10h],4
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+36h]
    test    byte ptr [rsp+36h],0FFh
    je      L28
    mov     r10,[rsp+38h]
    sub     r10,[rsp+40h]
    shr     r10,2
    mov     [rsp+78h],r10
    jmp     L24
L28:
    lea     rax,[k6]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k7]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym8]
    ud2
L29:
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k9]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn10
L30:
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+80h],rax
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+48h],rdx
    cmp     rax,rdx
    je      L7
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L31:
    inc     qword ptr [jit_record.ctr_l]
    jns     L43
L32:
    call    qword ptr [sym11]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L22
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L18
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L31
L33:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L6
L34:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L35:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L36:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L13
L37:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L15
L38:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L39:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L19
L40:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L41:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L42:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L25
L43:
    lea     r11,[jit_record]
    mov     eax,0Ah
    call    qword ptr [r11+10h]
    jmp     L32
L44:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L39
L0:
    sub     rsp,0E8h
    mov     [rsp+0C8h],rdi
    mov     [rsp+0D0h],rsi
    mov     [rsp+0C0h],rdx
    mov     [rsp+0B8h],rcx
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     rsi,[rsp+0D0h]
    cmp     rsi,0
    sete    [rsp+7Fh]
    jmp     L2
L1:
    mov     rax,[rsp+0D0h]
    mov     rdx,[rsp+0C8h]
    cmp     rdx,rax
    sete    [rsp+7Fh]
L2:
    test    byte ptr [rsp+7Fh],0FFh
    je      L3
    mov     byte ptr [rsp+8Eh],0
    mov     rsi,[rsp+0C0h]
    mov     [rsp+0D8h],rsi
    jmp     L11
L3:
    mov     byte ptr [rsp+8Eh],0
    mov     byte ptr [rsp+8Fh],1
    mov     rsi,[rsp+0C0h]
    mov     [rsp+78h],rsi
    mov     qword ptr [rsp+0A0h],0
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L4
    mov     r10,[rsp+0D0h]
    mov     [rsp+98h],r10
    jmp     L5
L4:
    mov     rax,[rsp+0D0h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+68h],rdx
    mov     [rsp+60h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+50h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L26
    jmp     L25
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L6:
    lea     rax,[rsp+0B8h]
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+8Fh],0
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+0C8h]
    mov     r8,[rsp+0A0h]
    imul    rcx,r8,4
    add     rdi,rcx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    call    fn0
    mov     [rsp+70h],rax
    mov     rax,[rsp+70h]
    mov     [rsp+78h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L29
    jmp     L28
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L8:
    mov     rax,[rsp+78h]
    mov     [rsp+0D8h],rax
    jmp     L11
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L10:
    jmp     L5
L11:
    mov     rax,[rsp+0D8h]
    add     rsp,0E8h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L13:
    jmp     L22
    nop
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L15:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L17:
    jmp     L12
    nop
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L19:
    test    byte ptr [rsp+8Fh],0FFh
    je      L12
    jmp     L16
    nop     [rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    jmp     L14
L22:
    test    byte ptr [rsp+8Eh],0FFh
    je      L14
    jmp     L20
    nop     [rax+rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L24:
    jmp     L5
L25:
    mov     rax,[rsp+70h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+40h],rdx
    lea     rsi,[k1]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+18h]
    call    fn2
L26:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],4
    setb    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L27
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+4Eh]
    test    byte ptr [rsp+4Eh],0FFh
    je      L27
    mov     r10,[rsp+50h]
    sub     r10,[rsp+58h]
    shr     r10,2
    mov     [rsp+98h],r10
    jmp     L23
L27:
    lea     rax,[k3]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],49h
    lea     rsi,[k4]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym5]
    ud2
L28:
    mov     qword ptr [rsp+18h],1
    lea     rdx,[k6]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn7
L29:
    mov     rax,[rsp+0A0h]
    add     rax,1
    mov     [rsp+0A0h],rax
    mov     [rsp+68h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+60h],rdx
    cmp     rax,rdx
    je      L7
    jmp     L9
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L18
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L6
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L13
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L15
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L36:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L19
L37:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L38:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L24
L39:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::map::<(u32, u32), {closure@bench/sort.rs:59:50: 59:54}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+18h],rcx
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::next
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     rax,[rsp+60h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx+8]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L2
    mov     [rsp+20h],rdx
    cmp     rdx,0
    jne     L1
    mov     qword ptr [rsp+68h],0
    jmp     L6
L1:
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
L2:
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+30h]
    mov     [rsp+38h],rdx
    cmp     rdx,rax
    sete    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     qword ptr [rsp+68h],0
    jmp     L6
L3:
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],4
    add     rdx,rcx
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+60h]
    mov     rcx,[rsp+20h]
    mov     [rsi],rcx
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L5:
    mov     rax,[rsp+30h]
    mov     [rsp+68h],rax
    jmp     L6
L6:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L7:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L8:
    mov     rax,[rsp+20h]
    sub     rax,1
    mov     [rsp+58h],rax
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+58h]
    mov     [rdx+8],rcx
    jmp     L4
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,88h
    mov     [rsp+50h],rdi
    mov     [rsp+60h],rsi
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rsi,[rsp+60h]
    mov     rsi,[rsi+8]
    mov     [rsp+58h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+60h]
    mov     rax,[rax+8]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rax
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
    xchg    ax,ax
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L3:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+58h]
    mov     [rsp+40h],rdx
    mov     qword ptr [rsp+38h],1
    mov     [rsp+68h],rax
    mov     rdi,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,88h
    ret
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L5:
    jmp     L2
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    lea     rsi,[k0]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn1
L7:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],4
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L8
    mov     qword ptr [rsp+10h],4
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+26h]
    test    byte ptr [rsp+26h],0FFh
    je      L8
    mov     r10,[rsp+28h]
    sub     r10,[rsp+30h]
    shr     r10,2
    mov     [rsp+58h],r10
    jmp     L4
L8:
    lea     rax,[k2]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k3]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    ud2
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::iter::FromIterator<(u32, u32)>>::from_iter::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    call    fn0
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::ops::DerefMut>::deref_mut
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym0]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+10h],rdx
    mov     rax,[rsp+50h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+10h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+10h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+8]
    call    fn0
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_extend::SpecExtend<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::spec_extend
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter::SpecFromIter<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter_nested::SpecFromIterNested<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    inc     qword ptr [jit_record]
    jns     L22
L0:
    sub     rsp,0E8h
    mov     [rsp+98h],rdi
    mov     [rsp+0B8h],rsi
    mov     [rsp+0C0h],rdx
    mov     byte ptr [rsp+0AFh],1
    lea     rdx,[rsp+0B8h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+68h]
    mov     rsi,[rsp+60h]
    call    fn0
    mov     rax,[rsp+70h]
    mov     [rsp+0B0h],rax
    cmp     rax,0
    je      L1
    jmp     L2
L1:
    lea     rax,[k1]
    mov     qword ptr [rsp+50h],11h
    mov     rsi,[rsp+50h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+18h],11h
    mov     r9,[rsp+18h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    lea     r10,[k3]
    mov     [rsp+8],r10
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym4]
    ud2
L2:
    mov     rax,[rsp+78h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn6
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    jmp     L13
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L4:
    mov     rax,[rsp+80h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+0D8h],rsi
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+98h]
    add     rsp,0E8h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L6:
    lea     rax,[rsp+80h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn7
    jmp     L11
    nop     [rax+rax]
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L8:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L10:
    jmp     L7
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L12:
    test    byte ptr [rsp+0AFh],0FFh
    je      L7
    jmp     L9
L13:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     rcx,[rsp+58h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+90h],0
    lea     rsi,[rsp+80h]
    mov     [rsp+78h],rsi
    mov     byte ptr [rsp+0AFh],0
    mov     r8,[rsp+0B8h]
    mov     rcx,[rsp+0C0h]
    mov     [rsp+70h],rcx
    mov     [rsp+68h],r8
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+70h]
    call    fn8
    jmp     L3
    ud2
    nop     [rax+rax]
    nop     [rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L15:
    call    qword ptr [sym9]
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L14
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L5
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L19:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L20:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L21:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L22:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::clone::Clone>::clone
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+38h],rdi
    mov     [rsp+40h],rsi
    mov     rax,[rsp+40h]
    lea     rax,[rax+10h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+30h]
    call    fn0
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+48h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+30h]
    call    fn1
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+38h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+28h],rax
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn0
    mov     [rsp+4Fh],al
    movzx   eax,byte ptr [rsp+4Fh]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::iter::FromIterator<u32>>::from_iter::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+38h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA8h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp]
    call    fn0
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+58h]
    lea     rsi,[rsp]
    call    fn1
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+38h]
    add     rsp,78h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::ops::Deref>::deref
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym0]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+30h],rdx
    lea     rax,[rsp+28h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L4
L2:
    add     rsp,48h
    ret
L3:
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+20h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    jmp     L1
L4:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::spec_extend
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+18h],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD8h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+8],rcx
    mov     [rsp],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    lea     rsi,[rsp]
    call    fn0
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_from_iter::SpecFromIter<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+48h]
    lea     rsi,[rsp+8]
    call    fn0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_from_iter_nested::SpecFromIterNested<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    inc     qword ptr [jit_record]
    jns     L22
L0:
    sub     rsp,108h
    mov     [rsp+0B0h],rdi
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF20h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     byte ptr [rsp+0C7h],1
    lea     rdx,[rsp+0D0h]
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+80h]
    mov     rsi,[rsp+78h]
    call    fn0
    mov     rax,[rsp+88h]
    mov     [rsp+0C8h],rax
    cmp     rax,0
    je      L1
    jmp     L2
L1:
    lea     rax,[k1]
    mov     qword ptr [rsp+68h],11h
    mov     rsi,[rsp+68h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+30h],11h
    mov     r9,[rsp+30h]
    shl     r9,1
    or      r9,1
    mov     [rsp+70h],rax
    mov     [rsp+78h],r9
    lea     r10,[k3]
    mov     [rsp+18h],r10
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym4]
    ud2
L2:
    mov     rax,[rsp+90h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    fn6
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    jmp     L13
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L4:
    mov     rax,[rsp+98h]
    mov     [rsp+0E8h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+0F0h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+0F8h],rsi
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+0B0h]
    add     rsp,108h
    ret
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L6:
    lea     rax,[rsp+98h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn7
    jmp     L11
    nop     [rax+rax]
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L8:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L10:
    jmp     L7
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L12:
    test    byte ptr [rsp+0C7h],0FFh
    je      L7
    jmp     L9
L13:
    mov     rax,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+70h],rcx
    mov     rcx,[rsp+70h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+0A8h],0
    lea     rsi,[rsp+98h]
    mov     [rsp+90h],rsi
    mov     byte ptr [rsp+0C7h],0
    mov     r8,[rsp+0D0h]
    mov     [rsp+78h],r8
    mov     r9,[rsp+0D8h]
    mov     [rsp+80h],r9
    mov     r10,[rsp+0E0h]
    mov     [rsp+88h],r10
    mov     rcx,[rsp+80h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],r8
    mov     [rsp+18h],r10
    mov     rdi,[rsp+90h]
    lea     rsi,[rsp+8]
    call    fn8
    jmp     L3
    ud2
    xchg    ax,ax
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L15:
    call    qword ptr [sym9]
    ud2
    lea     rdi,[rsp+100h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+100h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L14
    lea     rdi,[rsp+100h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L5
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L19:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L20:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L21:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L22:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     rax,[rax+8]
    mov     [rsp+8],rax
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    mov     rcx,[rsp+8]
    mov     [rdx],rcx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as core::slice::cmp::SlicePartialEq<u32>>::equal_same_length
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    imul    rax,[rsp+20h],4
    mov     [rsp+18h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+28h]
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    cmp     dword ptr [rsp+14h],0
    sete    [rsp+3Fh]
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp],4
    cmp     qword ptr [rsp],8
    setbe   [rsp+17h]
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     qword ptr [rsp],4
    imul    r8,[rsp],20h
    mov     [rsp+8],r8
    cmp     r8,1000h
    ja      L1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+18h]
    call    fn0
    jmp     L3
L1:
    mov     qword ptr [rsp],4
    imul    rdx,[rsp],30h
    mov     [rsp+8],rdx
    cmp     rdx,1000h
    ja      L2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+18h]
    call    fn1
    jmp     L3
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+8],rax
    cmp     rax,2
    jae     L5
    jmp     L6
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    add     rsp,38h
    ret
L5:
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp]
    mov     rcx,[rsp+18h]
    call    fn2
    jmp     L6
L6:
    jmp     L3
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,28h
    mov     qword ptr [rsp],4
    cmp     qword ptr [rsp],8
    setbe   [rsp+17h]
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     qword ptr [rsp],4
    imul    r8,[rsp],20h
    mov     [rsp+8],r8
    cmp     r8,1000h
    ja      L1
    mov     qword ptr [rsp+18h],20h
    jmp     L3
L1:
    mov     qword ptr [rsp],4
    imul    rdx,[rsp],30h
    mov     [rsp+8],rdx
    cmp     rdx,1000h
    ja      L2
    mov     qword ptr [rsp+18h],20h
    jmp     L3
L2:
    mov     qword ptr [rsp+18h],10h
L3:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    call    fn0
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <u32 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,0B8h
    mov     [rsp+48h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+90h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    mov     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+70h],rdx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+0A0h]
    mov     [rsp+60h],rsi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF98h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+48h]
    add     rsp,0B8h
    ret
L5:
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     rcx,[rsp+38h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+0A8h],0
    cmp     qword ptr [rsp+40h],0
    ja      L1
    jmp     L3
L6:
    mov     rax,[rsp+68h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     r8,[k2]
    mov     [rsp],r8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+40h]
    mov     r9,[rsp]
    call    fn3
L7:
    imul    rax,[rsp+40h],4
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF80h
    mov     ecx,0FFFFFF60h
    call    ryo_h_Memcpy
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L8
    mov     qword ptr [rsp+10h],4
    cmp     qword ptr [rsp+10h],0
    je      L12
    jmp     L13
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L9:
    mov     rax,[rsp+40h]
    mov     [rsp+0A8h],rax
    jmp     L3
    nop
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L11:
    lea     rax,[k4]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+10h]
    call    fn5
    jmp     L8
L12:
    mov     qword ptr [rsp+30h],0FFFFFFFFFFFFFFFFh
    jmp     L10
L13:
    mov     rax,[rsp+98h]
    mov     [rsp+30h],rax
    jmp     L10
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L15:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L16:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L17:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::cmp::Ord>::max
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+27h],1
    lea     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+17h],al
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     byte ptr [rsp+27h],0
    mov     rsi,[rsp+30h]
    mov     [rsp+38h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
L2:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L8:
    jmp     L5
L9:
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L7
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::cmp::Ord>::min
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+27h],1
    lea     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    lea     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+17h],al
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+28h]
    mov     [rsp+38h],rdx
    jmp     L2
L1:
    mov     byte ptr [rsp+27h],0
    mov     rdx,[rsp+30h]
    mov     [rsp+38h],rdx
L2:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L9
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L8:
    jmp     L5
L9:
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L7
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::iter::Step>::forward_unchecked
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L1
    lea     rsi,[k0]
    mov     [rsp],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L1:
    mov     rax,[rsp+10h]
    add     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::iter::Step>::steps_between
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,68h
    mov     [rsp+20h],rdi
    mov     [rsp+40h],rsi
    mov     [rsp+38h],rdx
    mov     rax,[rsp+40h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    cmp     rdx,rax
    jb      L1
    sub     rdx,rax
    mov     [rsp+10h],rdx
    mov     [rsp+8],rdx
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+10h]
    mov     [rsp+48h],rdi
    mov     r8,[rsp]
    mov     rcx,[rsp+8]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],r8
    jmp     L2
L1:
    mov     qword ptr [rsp+48h],0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+20h]
    add     rsp,68h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+30h]
    cmp     rdx,rax
    jb      L1
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+20h]
    imul    rcx,[rsp+30h],8
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jae     L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0D6h
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0D6h
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    lea     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn Rng::next
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     rax,[rsp+60h]
    mov     rax,[rax]
    mov     [rsp+50h],rax
    mov     dword ptr [rsp+14h],0Dh
    mov     esi,[rsp+14h]
    mov     [rsp+4Ch],esi
    cmp     esi,40h
    jb      L1
    lea     r8,[k0]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     rax,[rsp+50h]
    shl     rax,0Dh
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp],rdx
    mov     rsi,[rsp+60h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+60h]
    mov     rdi,[rdi]
    mov     [rsp+38h],rdi
    mov     dword ptr [rsp+14h],7
    mov     r9d,[rsp+14h]
    mov     [rsp+34h],r9d
    cmp     r9d,40h
    jb      L2
    lea     r11,[k2]
    mov     [rsp+10h],r11
    mov     rdi,[rsp+10h]
    call    qword ptr [sym3]
    ud2
L2:
    mov     rax,[rsp+38h]
    shr     rax,7
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp],rdx
    mov     rsi,[rsp+60h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+60h]
    mov     rdi,[rdi]
    mov     [rsp+20h],rdi
    mov     dword ptr [rsp+14h],11h
    mov     r9d,[rsp+14h]
    mov     [rsp+1Ch],r9d
    cmp     r9d,40h
    jb      L3
    lea     r11,[k4]
    mov     [rsp+10h],r11
    mov     rdi,[rsp+10h]
    call    qword ptr [sym5]
    ud2
L3:
    mov     rax,[rsp+20h]
    shl     rax,11h
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp],rdx
    mov     rsi,[rsp+60h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+60h]
    mov     rdi,[rdi]
    mov     [rsp+68h],rdi
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn alloc::raw_vec::RawVec::<u32>::grow_one
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rax,[rax]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp]
    mov     r8,[rsp+8]
    call    qword ptr [sym1]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    cmp     qword ptr [rsp+30h],0FFFFFFFFFFFFFFFFh
    je      L1
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,58h
    ret
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn alloc::raw_vec::RawVecInner::with_capacity_in
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+0Fh],0
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+78h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+70h]
    call    qword ptr [sym0]
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym1]
    ud2
L2:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    cmp     rdx,0
    je      L5
    jmp     L6
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L4:
    mov     rax,[rsp+20h]
    sub     rax,0
    cmp     rax,[rsp+78h]
    setb    [rsp+36h]
    movzx   edx,byte ptr [rsp+36h]
    xor     dl,1
    mov     [rsp+37h],dl
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
L5:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    jmp     L3
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+20h],rax
    jmp     L3
L7:
    lea     rax,[k2]
    mov     [rsp+8],rax
    movzx   edi,byte ptr [rsp+37h]
    mov     rsi,[rsp+8]
    call    fn3
L8:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn checksum
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+48h],rdi
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    call    fn0
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    call    fn1
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    mov     qword ptr [rsp],0
    lea     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn2
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn checksum::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+48h],rdx
    mov     [rsp+50h],rcx
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+50h]
    mov     edx,[rdx]
    mov     [rsp+3Ch],edx
    mov     qword ptr [rsp+8],1Fh
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+30h],rax
    mov     eax,[rsp+3Ch]
    mov     rdx,[rsp+40h]
    xor     rax,rdx
    mov     [rsp+28h],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    call    fn1
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::num::<impl std::fmt::Debug for u32>::fmt
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+18h]
    mov     eax,[rax+10h]
    and     eax,2000000h
    cmp     eax,0
    setne   [rsp+17h]
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    qword ptr [sym0]
    mov     [rsp+2Fh],al
    jmp     L3
L1:
    mov     rax,[rsp+18h]
    mov     eax,[rax+10h]
    and     eax,4000000h
    cmp     eax,0
    setne   [rsp+16h]
    test    byte ptr [rsp+16h],0FFh
    je      L2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    qword ptr [sym1]
    mov     [rsp+2Fh],al
    jmp     L3
L2:
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    qword ptr [sym2]
    mov     [rsp+2Fh],al
L3:
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_debug::<(u32, u32)>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::fmt::rt::Argument::<'_>::new_lower_hex::<u64>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     rdx,[sym0]
    mov     [rsp+20h],rdx
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u64>::wrapping_add
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    add     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl u64>::wrapping_mul
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    imul    rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl usize>::unchecked_add::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+80h]
    add     rax,rdx
    setb    cl
    mov     [rsp+60h],cl
    movzx   esi,byte ptr [rsp+60h]
    mov     [rsp+6Fh],sil
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    lea     r8,[k0]
    mov     qword ptr [rsp+78h],0BAh
    mov     r10,[rsp+78h]
    lea     r11,[k1]
    mov     qword ptr [rsp+28h],0BAh
    mov     rdi,[rsp+28h]
    shl     rdi,1
    or      rdi,1
    mov     [rsp+58h],r8
    mov     [rsp+60h],rdi
    mov     byte ptr [rsp+17h],0
    mov     r9,[rsp+18h]
    mov     [rsp+8],r9
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,98h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::num::<impl usize>::unchecked_sub::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+80h]
    sub     rax,rdx
    setb    cl
    mov     [rsp+60h],cl
    movzx   esi,byte ptr [rsp+60h]
    mov     [rsp+6Fh],sil
    test    byte ptr [rsp+6Fh],0FFh
    je      L1
    lea     r8,[k0]
    mov     qword ptr [rsp+78h],0BAh
    mov     r10,[rsp+78h]
    lea     r11,[k1]
    mov     qword ptr [rsp+28h],0BAh
    mov     rdi,[rsp+28h]
    shl     rdi,1
    or      rdi,1
    mov     [rsp+58h],r8
    mov     [rsp+60h],rdi
    mov     byte ptr [rsp+17h],0
    mov     r9,[rsp+18h]
    mov     [rsp+8],r9
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,98h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::panicking::assert_failed::<std::vec::Vec<u32>, std::vec::Vec<u32>>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,88h
    mov     [rsp+7Fh],dil
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+58h],rcx
    mov     [rsp+60h],r8
    mov     [rsp+20h],r9
    lea     rax,[rsp+70h]
    mov     [rsp+48h],rax
    lea     rdx,[k0]
    mov     [rsp+50h],rdx
    lea     rsi,[rsp+68h]
    mov     [rsp+30h],rsi
    lea     rdi,[k1]
    mov     [rsp+38h],rdi
    mov     r8,[rsp+20h]
    mov     [rsp+18h],r8
    mov     r9,[rsp+60h]
    mov     [rsp],r9
    mov     [rsp+8],r8
    movzx   edi,byte ptr [rsp+7Fh]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+38h]
    mov     r9,[rsp+58h]
    call    qword ptr [sym2]
    ud2
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [(u32, u32)]>::reverse
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+88h]
    mov     [rsp+78h],rax
    shr     rax,1
    mov     [rsp+30h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+40h],rsi
    mov     [rsp+50h],rdx
    imul    rcx,[rsp+78h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    add     rsp,98h
    ret
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    lea     rdi,[k0]
    mov     [rsp],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn1
L4:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+30h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L10
    jmp     L9
L7:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    jmp     L5
L8:
    mov     rax,[rsp+30h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+48h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L5
L9:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    lea     rdi,[k2]
    mov     [rsp],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn3
L10:
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+30h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     r8,[rsp+30h]
    call    fn4
    jmp     L1
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,0D8h
    mov     [rsp+90h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+98h],rcx
    mov     [rsp+10h],r8
    mov     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    cmp     rax,[rsp+98h]
    jb      L1
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+48h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+8]
    call    fn1
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rdx
    mov     [rsp+0C0h],rsi
    mov     [rsp+0C8h],rdi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+90h]
    add     rsp,0D8h
    ret
L1:
    lea     rax,[k2]
    mov     qword ptr [rsp+58h],9
    mov     rsi,[rsp+58h]
    lea     rdi,[k3]
    mov     qword ptr [rsp+20h],9
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+60h],rax
    mov     [rsp+68h],r9
    mov     r10,[rsp+10h]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym4]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0C8h
    mov     [rsp+70h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rdx
    mov     [rsp+88h],rcx
    mov     [rsp+18h],r8
    mov     rax,[rsp+98h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+80h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     r9,[rsp+18h]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+10h]
    call    fn0
L1:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L2
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rsi
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    mov     r9,[rsp+18h]
    mov     [rsp],r9
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp]
    call    fn1
L2:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+60h]
    imul    rcx,[rsp+88h],8
    add     rsi,rcx
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+68h]
    sub     rdi,[rsp+88h]
    mov     [rsp+30h],rdi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L3
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    mov     r8,[rsp+18h]
    mov     [rsp],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn2
L3:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rsi
    mov     rcx,[rsp+48h]
    mov     [rsp+0B8h],rcx
    mov     [rsp+0B0h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+70h]
    add     rsp,0C8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [T]>::reverse::revswap::<(u32, u32)>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rcx
    mov     [rsp+98h],r8
    lea     rax,[k0]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+18h]
    call    fn1
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+60h],rcx
    mov     [rsp+58h],rax
    lea     rdx,[k2]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+18h]
    call    fn3
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],0
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+98h]
    jae     L5
    mov     rdx,[rsp+40h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+88h],rsi
    cmp     rdx,rsi
    jb      L3
    lea     rdi,[k4]
    mov     [rsp+18h],rdi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym5]
    ud2
L3:
    mov     rax,[rsp+58h]
    imul    rcx,[rsp+38h],8
    add     rax,rcx
    mov     [rsp+90h],rax
    mov     rdx,[rsp+98h]
    sub     rdx,1
    mov     rsi,[rsp+40h]
    sub     rdx,rsi
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+50h]
    mov     [rsp+70h],rdi
    cmp     rdx,rdi
    jb      L4
    lea     r8,[k6]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym7]
    ud2
L4:
    mov     rax,[rsp+48h]
    imul    rcx,[rsp+30h],8
    add     rax,rcx
    mov     rdx,[rsp+90h]
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rax
    mov     edx,[rdx]
    mov     [rsp+10h],edx
    mov     rsi,[rsp+28h]
    mov     esi,[rsi+4]
    mov     [rsp+14h],esi
    mov     eax,[rax]
    mov     [rsp],eax
    mov     rdi,[rsp+20h]
    mov     edi,[rdi+4]
    mov     [rsp+4],edi
    mov     r8,[rsp+28h]
    mov     ecx,[rsp]
    mov     [r8],ecx
    mov     r9,[rsp+28h]
    mov     ecx,[rsp+4]
    mov     [r9+4],ecx
    mov     r10,[rsp+20h]
    mov     ecx,[rsp+10h]
    mov     [r10],ecx
    mov     r11,[rsp+20h]
    mov     ecx,[rsp+14h]
    mov     [r11+4],ecx
    jmp     L6
L5:
    add     rsp,0C8h
    ret
L6:
    mov     rax,[rsp+40h]
    add     rax,1
    mov     [rsp+40h],rax
    jmp     L1
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [T]>::reverse::revswap::<u32>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,0C8h
    mov     [rsp+0B0h],rdi
    mov     [rsp+0B8h],rsi
    mov     [rsp+0A0h],rdx
    mov     [rsp+0A8h],rcx
    mov     [rsp+98h],r8
    lea     rax,[k0]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+38h]
    mov     rsi,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+18h]
    call    fn1
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+60h],rcx
    mov     [rsp+58h],rax
    lea     rdx,[k2]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+18h]
    call    fn3
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],0
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+98h]
    jae     L5
    mov     rdx,[rsp+40h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+88h],rsi
    cmp     rdx,rsi
    jb      L3
    lea     rdi,[k4]
    mov     [rsp+18h],rdi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym5]
    ud2
L3:
    mov     rax,[rsp+58h]
    imul    rcx,[rsp+38h],4
    add     rax,rcx
    mov     [rsp+90h],rax
    mov     rdx,[rsp+98h]
    sub     rdx,1
    mov     rsi,[rsp+40h]
    sub     rdx,rsi
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+50h]
    mov     [rsp+70h],rdi
    cmp     rdx,rdi
    jb      L4
    lea     r8,[k6]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym7]
    ud2
L4:
    mov     rax,[rsp+48h]
    imul    rcx,[rsp+30h],4
    add     rax,rcx
    mov     rdx,[rsp+90h]
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rax
    mov     edx,[rdx]
    mov     [rsp+10h],edx
    mov     eax,[rax]
    mov     [rsp],eax
    mov     rsi,[rsp+28h]
    mov     ecx,[rsp]
    mov     [rsi],ecx
    mov     rdi,[rsp+20h]
    mov     ecx,[rsp+10h]
    mov     [rdi],ecx
    jmp     L6
L5:
    add     rsp,0C8h
    ret
L6:
    mov     rax,[rsp+40h]
    add     rax,1
    mov     [rsp+40h],rax
    jmp     L1
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [T]>::split_at_mut_unchecked::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0DDh
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0DDh
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jae     L1
    mov     rdx,[rsp+78h]
    cmp     rdx,[rsp+88h]
    jae     L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+70h],0DAh
    mov     rsi,[rsp+70h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+20h],0DAh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::copy_from_slice
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rcx
    mov     [rsp+8],r8
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp]
    call    fn0
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::iter
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     rdi,[rsp]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::reverse
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    mov     rax,[rsp+88h]
    mov     [rsp+78h],rax
    shr     rax,1
    mov     [rsp+30h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+40h],rsi
    mov     [rsp+50h],rdx
    imul    rcx,[rsp+78h],4
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    add     rsp,98h
    ret
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k0]
    mov     [rsp],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn1
L4:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+30h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L10
    jmp     L9
L7:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    jmp     L5
L8:
    mov     rax,[rsp+30h]
    mov     qword ptr [rsp+10h],0
    mov     rsi,[rsp+10h]
    sub     rsi,rax
    mov     rdi,[rsp+48h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+28h],rdi
    jmp     L5
L9:
    mov     rax,[rsp+28h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k2]
    mov     [rsp],rdi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn3
L10:
    mov     rax,[rsp+28h]
    mov     rdx,[rsp+30h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     r8,[rsp+30h]
    call    fn4
    jmp     L1
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::sort_unstable
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+18h],rsi
    lea     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::split_at_mut
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,0D8h
    mov     [rsp+90h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+98h],rcx
    mov     [rsp+10h],r8
    mov     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    cmp     rax,[rsp+98h]
    jb      L1
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+48h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    mov     r8,[rsp+8]
    call    fn1
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdi,[rsp+60h]
    mov     [rsp+0B0h],rax
    mov     [rsp+0B8h],rdx
    mov     [rsp+0C0h],rsi
    mov     [rsp+0C8h],rdi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+90h]
    add     rsp,0D8h
    ret
L1:
    lea     rax,[k2]
    mov     qword ptr [rsp+58h],9
    mov     rsi,[rsp+58h]
    lea     rdi,[k3]
    mov     qword ptr [rsp+20h],9
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+60h],rax
    mov     [rsp+68h],r9
    mov     r10,[rsp+10h]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym4]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::split_at_mut_unchecked
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0C8h
    mov     [rsp+70h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rdx
    mov     [rsp+88h],rcx
    mov     [rsp+18h],r8
    mov     rax,[rsp+98h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+80h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     r9,[rsp+18h]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+10h]
    call    fn0
L1:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L2
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rsi
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    mov     r9,[rsp+18h]
    mov     [rsp],r9
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp]
    call    fn1
L2:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+60h]
    imul    rcx,[rsp+88h],4
    add     rsi,rcx
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+68h]
    sub     rdi,[rsp+88h]
    mov     [rsp+30h],rdi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L3
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    mov     r8,[rsp+18h]
    mov     [rsp],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn2
L3:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rsi
    mov     rcx,[rsp+48h]
    mov     [rsp+0B8h],rcx
    mov     [rsp+0B0h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE0h
    mov     r8d,20h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+70h]
    add     rsp,0C8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::swap
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+20h],rcx
    mov     [rsp+8],r8
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+28h]
    cmp     rdx,rax
    jb      L1
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+18h]
    jb      L2
    mov     rdx,[rsp+8]
    mov     [rsp],rdx
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    call    qword ptr [sym1]
    ud2
L2:
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp]
    call    fn2
    add     rsp,48h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::<impl [u32]>::swap_unchecked
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+38h],rdx
    mov     [rsp+30h],rcx
    mov     [rsp+10h],r8
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L1
    mov     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+10h]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+8]
    call    fn0
L1:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+28h],rax
    imul    rcx,[rsp+38h],4
    add     rax,rcx
    mov     [rsp+20h],rax
    mov     rsi,[rsp+28h]
    imul    rcx,[rsp+30h],4
    add     rsi,rcx
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    fn1
    add     rsp,58h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::copy_from_slice_impl::<u32>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rcx
    mov     [rsp+18h],r8
    mov     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+60h],rdx
    cmp     rax,rdx
    je      L1
    mov     rsi,[rsp+18h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym0]
    ud2
L1:
    mov     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+58h],rdx
    mov     [rsp+38h],rax
    mov     rsi,[rsp+80h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+88h]
    mov     [rsp+48h],rdi
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L2
    mov     r10,[rsp+50h]
    mov     [rsp+28h],r10
    mov     r11,[rsp+40h]
    mov     [rsp+20h],r11
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     r8,[k1]
    mov     [rsp],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+68h]
    mov     r9,[rsp]
    call    fn2
L2:
    imul    rax,[rsp+68h],4
    mov     [rsp+10h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFA8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    add     rsp,98h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::index::<impl std::ops::Index<std::ops::Range<usize>> for [u32]>::index
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rcx
    mov     [rsp+8],r8
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     r8,[rsp]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::index::<impl std::ops::Index<std::ops::RangeFrom<usize>> for [u32]>::index
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+18h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+8]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeFrom<usize>> for [u32]>::index_mut
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+18h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+8]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeTo<usize>> for [u32]>::index_mut
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+18h],rdx
    mov     [rsp+10h],rcx
    mov     rax,[rsp+10h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+8]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::find_existing_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L31
L0:
    sub     rsp,88h
    mov     [rsp+60h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    cmp     rax,2
    jae     L1
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+78h],0
    jmp     L16
L1:
    mov     qword ptr [rsp+50h],2
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L18
    jmp     L17
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L3:
    test    byte ptr [rsp+47h],0FFh
    je      L10
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L5:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+48h]
    jae     L9
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L7:
    test    byte ptr [rsp+45h],0FFh
    je      L8
    mov     rdx,[rsp+50h]
    add     rdx,1
    mov     [rsp+50h],rdx
    jmp     L4
L8:
    jmp     L9
L9:
    jmp     L15
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L11:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+48h]
    jae     L15
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L24
    jmp     L23
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L13:
    test    byte ptr [rsp+45h],0FFh
    je      L14
    jmp     L15
L14:
    mov     rax,[rsp+50h]
    add     rax,1
    mov     [rsp+50h],rax
    jmp     L10
L15:
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    movzx   edx,byte ptr [rsp+47h]
    mov     [rsp+78h],dl
L16:
    mov     rax,[rsp+70h]
    movzx   edx,byte ptr [rsp+78h]
    add     rsp,88h
    ret
L17:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp]
    call    fn1
L18:
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+8]
    cmp     rdx,[rsp+48h]
    setb    [rsp+46h]
    mov     rsi,[rsp+60h]
    lea     rsi,[rsi+8]
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L19
    mov     qword ptr [rsp+8],0
    lea     r10,[k2]
    mov     [rsp],r10
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp]
    call    fn3
L19:
    mov     qword ptr [rsp+8],0
    mov     rdx,[rsp+8]
    cmp     rdx,[rsp+48h]
    setb    [rsp+46h]
    mov     rsi,[rsp+60h]
    mov     rdi,[rsp+28h]
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn4
    mov     [rsp+47h],al
    jmp     L2
L20:
    lea     rax,[k5]
    mov     [rsp+8],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn6
L21:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+50h]
    sub     rsi,1
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L22
    lea     r9,[k7]
    mov     [rsp+8],r9
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn8
L22:
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     rsi,[rsp+28h]
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn9
    mov     [rsp+45h],al
    jmp     L6
L23:
    lea     rax,[k10]
    mov     [rsp+8],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn11
L24:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+50h]
    sub     rsi,1
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L25
    lea     r9,[k12]
    mov     [rsp+8],r9
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn13
L25:
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     rsi,[rsp+28h]
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn14
    mov     [rsp+45h],al
    jmp     L12
L26:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L27:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L28:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L29:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L30:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L31:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::find_existing_run::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L31
L0:
    sub     rsp,88h
    mov     [rsp+60h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    cmp     rax,2
    jae     L1
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+78h],0
    jmp     L16
L1:
    mov     qword ptr [rsp+50h],2
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L18
    jmp     L17
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L3:
    test    byte ptr [rsp+47h],0FFh
    je      L10
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L5:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+48h]
    jae     L9
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L7:
    test    byte ptr [rsp+45h],0FFh
    je      L8
    mov     rdx,[rsp+50h]
    add     rdx,1
    mov     [rsp+50h],rdx
    jmp     L4
L8:
    jmp     L9
L9:
    jmp     L15
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L11:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+48h]
    jae     L15
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L24
    jmp     L23
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L13:
    test    byte ptr [rsp+45h],0FFh
    je      L14
    jmp     L15
L14:
    mov     rax,[rsp+50h]
    add     rax,1
    mov     [rsp+50h],rax
    jmp     L10
L15:
    mov     rax,[rsp+50h]
    mov     [rsp+70h],rax
    movzx   edx,byte ptr [rsp+47h]
    mov     [rsp+78h],dl
L16:
    mov     rax,[rsp+70h]
    movzx   edx,byte ptr [rsp+78h]
    add     rsp,88h
    ret
L17:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp]
    call    fn1
L18:
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+8]
    cmp     rdx,[rsp+48h]
    setb    [rsp+46h]
    mov     rsi,[rsp+60h]
    lea     rsi,[rsi+4]
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L19
    mov     qword ptr [rsp+8],0
    lea     r10,[k2]
    mov     [rsp],r10
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp]
    call    fn3
L19:
    mov     qword ptr [rsp+8],0
    mov     rdx,[rsp+8]
    cmp     rdx,[rsp+48h]
    setb    [rsp+46h]
    mov     rsi,[rsp+60h]
    mov     rdi,[rsp+28h]
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn4
    mov     [rsp+47h],al
    jmp     L2
L20:
    lea     rax,[k5]
    mov     [rsp+8],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn6
L21:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+50h]
    sub     rsi,1
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L22
    lea     r9,[k7]
    mov     [rsp+8],r9
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn8
L22:
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+28h]
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn9
    mov     [rsp+45h],al
    jmp     L6
L23:
    lea     rax,[k10]
    mov     [rsp+8],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn11
L24:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+50h]
    sub     rsi,1
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L25
    lea     r9,[k12]
    mov     [rsp+8],r9
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn13
L25:
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+48h]
    setb    [rsp+44h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+28h]
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn14
    mov     [rsp+45h],al
    jmp     L12
L26:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L27:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L28:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L29:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L30:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L31:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L20
L0:
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+0A0h]
    mov     [rsp+70h],rax
    cmp     rax,8
    jae     L1
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+98h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rax
    mov     rsi,[rsp+70h]
    shr     rsi,3
    mov     [rsp+68h],rsi
    imul    rdi,rsi,4
    imul    rcx,rdi,8
    add     rax,rcx
    mov     [rsp+60h],rax
    imul    r8,rsi,7
    mov     r9,[rsp+88h]
    imul    rcx,r8,8
    add     r9,rcx
    mov     [rsp+58h],r9
    cmp     qword ptr [rsp+70h],40h
    jae     L2
    mov     r11,[rsp+88h]
    mov     [rsp+40h],r11
    mov     [rsp+38h],rax
    mov     [rsp+30h],r9
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+90h]
    call    fn0
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    jmp     L7
L2:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+90h]
    call    fn1
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L4:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+70h]
    setb    [rsp+6Fh]
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L6:
    jmp     L3
L7:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+20h],rdx
    lea     rsi,[k2]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    call    fn3
L8:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],8
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L9
    mov     qword ptr [rsp+18h],8
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+55h]
    test    byte ptr [rsp+55h],0FFh
    je      L9
    mov     r10,[rsp+48h]
    sub     r10,[rsp+88h]
    shr     r10,3
    mov     [rsp+0A8h],r10
    jmp     L5
L9:
    lea     rax,[k4]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],49h
    lea     rsi,[k5]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym6]
    ud2
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L11:
    jmp     L3
L12:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    lea     rsi,[k7]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+18h]
    call    fn8
L13:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],8
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L14
    mov     qword ptr [rsp+18h],8
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+55h]
    test    byte ptr [rsp+55h],0FFh
    je      L14
    mov     r10,[rsp+48h]
    sub     r10,[rsp+88h]
    shr     r10,3
    mov     [rsp+0A8h],r10
    jmp     L10
L14:
    lea     rax,[k9]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],49h
    lea     rsi,[k10]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym11]
    ud2
L15:
    lea     rax,[k12]
    mov     [rsp+18h],rax
    movzx   edi,byte ptr [rsp+6Fh]
    mov     rsi,[rsp+18h]
    call    fn13
L16:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L17:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L18:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L19:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L11
L20:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L20
L0:
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+0A0h]
    mov     [rsp+70h],rax
    cmp     rax,8
    jae     L1
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+98h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rax
    mov     rsi,[rsp+70h]
    shr     rsi,3
    mov     [rsp+68h],rsi
    imul    rdi,rsi,4
    imul    rcx,rdi,4
    add     rax,rcx
    mov     [rsp+60h],rax
    imul    r8,rsi,7
    mov     r9,[rsp+88h]
    imul    rcx,r8,4
    add     r9,rcx
    mov     [rsp+58h],r9
    cmp     qword ptr [rsp+70h],40h
    jae     L2
    mov     r11,[rsp+88h]
    mov     [rsp+40h],r11
    mov     [rsp+38h],rax
    mov     [rsp+30h],r9
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     rcx,[rsp+90h]
    call    fn0
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L8
    jmp     L7
L2:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+90h]
    call    fn1
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L4:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+70h]
    setb    [rsp+6Fh]
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L6:
    jmp     L3
L7:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+20h],rdx
    lea     rsi,[k2]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    call    fn3
L8:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],4
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L9
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+55h]
    test    byte ptr [rsp+55h],0FFh
    je      L9
    mov     r10,[rsp+48h]
    sub     r10,[rsp+88h]
    shr     r10,2
    mov     [rsp+0A8h],r10
    jmp     L5
L9:
    lea     rax,[k4]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],49h
    lea     rsi,[k5]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym6]
    ud2
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L11:
    jmp     L3
L12:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    lea     rsi,[k7]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+18h]
    call    fn8
L13:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],4
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L14
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+55h]
    test    byte ptr [rsp+55h],0FFh
    je      L14
    mov     r10,[rsp+48h]
    sub     r10,[rsp+88h]
    shr     r10,2
    mov     [rsp+0A8h],r10
    jmp     L10
L14:
    lea     rax,[k9]
    mov     [rsp+10h],rax
    mov     qword ptr [rsp+18h],49h
    lea     rsi,[k10]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym11]
    ud2
L15:
    lea     rax,[k12]
    mov     [rsp+18h],rax
    movzx   edi,byte ptr [rsp+6Fh]
    mov     rsi,[rsp+18h]
    call    fn13
L16:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L17:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L18:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L19:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L11
L20:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+18h],rcx
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn0
    mov     [rsp+17h],al
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn1
    mov     [rsp+16h],al
    movzx   eax,byte ptr [rsp+17h]
    cmp     al,[rsp+16h]
    jne     L3
    mov     rdx,[rsp+28h]
    mov     [rsp],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn2
    mov     [rsp+14h],al
    movzx   eax,byte ptr [rsp+14h]
    xor     al,[rsp+17h]
    mov     [rsp+13h],al
    test    byte ptr [rsp+13h],0FFh
    je      L1
    mov     rsi,[rsp+20h]
    mov     [rsp+38h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
L2:
    jmp     L4
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
L4:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     [rsp+18h],rcx
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn0
    mov     [rsp+17h],al
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn1
    mov     [rsp+16h],al
    movzx   eax,byte ptr [rsp+17h]
    cmp     al,[rsp+16h]
    jne     L3
    mov     rdx,[rsp+28h]
    mov     [rsp],rdx
    mov     rsi,[rsp+20h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn2
    mov     [rsp+14h],al
    movzx   eax,byte ptr [rsp+14h]
    xor     al,[rsp+17h]
    mov     [rsp+13h],al
    test    byte ptr [rsp+13h],0FFh
    je      L1
    mov     rsi,[rsp+20h]
    mov     [rsp+38h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
L2:
    jmp     L4
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
L4:
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rcx
    mov     [rsp+40h],r8
    imul    rax,[rsp+48h],8
    mov     [rsp+20h],rax
    cmp     rax,40h
    jb      L1
    mov     rsi,[rsp+48h]
    shr     rsi,3
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+60h]
    imul    r9,rsi,4
    mov     [rsp+38h],r9
    imul    rcx,r9,8
    add     r8,rcx
    mov     [rsp+10h],r8
    imul    r10,rsi,7
    mov     [rsp+30h],r10
    mov     r11,[rsp+60h]
    imul    rcx,r10,8
    add     r11,rcx
    mov     [rsp+8],r11
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn0
    mov     [rsp+60h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+58h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+58h]
    imul    rcx,[rsp+30h],8
    add     rsi,rcx
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn1
    mov     [rsp+58h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+50h]
    imul    rcx,[rsp+30h],8
    add     rsi,rcx
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn2
    mov     [rsp+50h],rax
    jmp     L1
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+40h]
    call    fn3
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rcx
    mov     [rsp+40h],r8
    imul    rax,[rsp+48h],8
    mov     [rsp+20h],rax
    cmp     rax,40h
    jb      L1
    mov     rsi,[rsp+48h]
    shr     rsi,3
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+60h]
    imul    r9,rsi,4
    mov     [rsp+38h],r9
    imul    rcx,r9,4
    add     r8,rcx
    mov     [rsp+10h],r8
    imul    r10,rsi,7
    mov     [rsp+30h],r10
    mov     r11,[rsp+60h]
    imul    rcx,r10,4
    add     r11,rcx
    mov     [rsp+8],r11
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn0
    mov     [rsp+60h],rax
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+58h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+58h]
    imul    rcx,[rsp+30h],4
    add     rsi,rcx
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn1
    mov     [rsp+58h],rax
    mov     rax,[rsp+50h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+50h]
    imul    rcx,[rsp+30h],4
    add     rsi,rcx
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+40h]
    call    fn2
    mov     [rsp+50h],rax
    jmp     L1
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+40h]
    call    fn3
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::bidirectional_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L28
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    mov     [rsp+0D8h],rsi
    mov     [rsp+0C8h],rdx
    mov     [rsp+0C0h],rcx
    mov     rax,[rsp+0D8h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     [rsp+50h],rdx
    shr     rax,1
    mov     [rsp+48h],rax
    cmp     rax,0
    setne   [rsp+47h]
    mov     [rsp+98h],rdx
    mov     r8,[rsp+50h]
    imul    rcx,rax,8
    add     r8,rcx
    mov     [rsp+90h],r8
    sub     rax,1
    mov     r9,[rsp+50h]
    imul    rcx,rax,8
    add     r9,rcx
    mov     [rsp+88h],r9
    mov     r10,[rsp+58h]
    sub     r10,1
    mov     [rsp+0B8h],r10
    mov     r11,[rsp+50h]
    imul    rcx,r10,8
    add     r11,rcx
    mov     [rsp+80h],r11
    mov     rsi,[rsp+0C8h]
    imul    rcx,r10,8
    add     rsi,rcx
    mov     [rsp+78h],rsi
    mov     qword ptr [rsp+0A8h],0
    mov     rax,[rsp+48h]
    mov     [rsp+0B0h],rax
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L2:
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    cmp     rax,rdx
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+98h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+0C8h],rsi
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8,[rsp+0C0h]
    call    fn0
    mov     rax,[rsp+30h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+78h],rsi
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L6:
    jmp     L11
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L8:
    mov     rax,[rsp+98h]
    cmp     rax,[rsp+40h]
    setb    [rsp+36h]
    test    byte ptr [rsp+36h],0FFh
    je      L9
    mov     rsi,[rsp+98h]
    mov     [rsp+70h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
L10:
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L12:
    mov     rax,[rsp+98h]
    cmp     rax,[rsp+40h]
    je      L13
    jmp     L14
L13:
    mov     rax,[rsp+90h]
    cmp     rax,[rsp+38h]
    je      L15
L14:
    call    qword ptr [sym1]
    ud2
L15:
    add     rsp,0E8h
    ret
L16:
    mov     rax,[rsp+0A8h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L19
    jmp     L18
L17:
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+18h],8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L20
L18:
    mov     qword ptr [rsp+18h],1
    lea     rdx,[k2]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn3
L19:
    mov     rax,[rsp+38h]
    add     rax,1
    mov     [rsp+0A8h],rax
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+0C8h]
    mov     r8,[rsp+0C0h]
    call    fn4
    jmp     L3
L20:
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+80h]
    imul    rcx,[rsp+18h],8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+58h]
    and     rsi,1
    cmp     rsi,0
    sete    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L7
    jmp     L5
L21:
    mov     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r9,[k5]
    mov     [rsp],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn6
L22:
    mov     rax,[rsp+70h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+70h]
    mov     edx,[rdx+4]
    mov     [rsp+14h],edx
    mov     rsi,[rsp+0C8h]
    mov     ecx,[rsp+10h]
    mov     [rsi],ecx
    mov     rdi,[rsp+0C8h]
    mov     ecx,[rsp+14h]
    mov     [rdi+4],ecx
    movzx   r8d,byte ptr [rsp+36h]
    mov     r9,[rsp+98h]
    imul    rcx,r8,8
    add     r9,rcx
    mov     [rsp+98h],r9
    movzx   r10d,byte ptr [rsp+36h]
    xor     r10b,1
    mov     [rsp+35h],r10b
    movzx   r11d,byte ptr [rsp+35h]
    mov     rax,[rsp+90h]
    imul    rcx,r11,8
    add     rax,rcx
    mov     [rsp+90h],rax
    jmp     L11
L23:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L24:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L25:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L26:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L27:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L28:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L28
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    mov     [rsp+0D8h],rsi
    mov     [rsp+0C8h],rdx
    mov     [rsp+0C0h],rcx
    mov     rax,[rsp+0D8h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     [rsp+50h],rdx
    shr     rax,1
    mov     [rsp+48h],rax
    cmp     rax,0
    setne   [rsp+47h]
    mov     [rsp+98h],rdx
    mov     r8,[rsp+50h]
    imul    rcx,rax,4
    add     r8,rcx
    mov     [rsp+90h],r8
    sub     rax,1
    mov     r9,[rsp+50h]
    imul    rcx,rax,4
    add     r9,rcx
    mov     [rsp+88h],r9
    mov     r10,[rsp+58h]
    sub     r10,1
    mov     [rsp+0B8h],r10
    mov     r11,[rsp+50h]
    imul    rcx,r10,4
    add     r11,rcx
    mov     [rsp+80h],r11
    mov     rsi,[rsp+0C8h]
    imul    rcx,r10,4
    add     rsi,rcx
    mov     [rsp+78h],rsi
    mov     qword ptr [rsp+0A8h],0
    mov     rax,[rsp+48h]
    mov     [rsp+0B0h],rax
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L2:
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    cmp     rax,rdx
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+98h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+0C8h],rsi
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+78h]
    mov     r8,[rsp+0C0h]
    call    fn0
    mov     rax,[rsp+30h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+78h],rsi
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L6:
    jmp     L11
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L8:
    mov     rax,[rsp+98h]
    cmp     rax,[rsp+40h]
    setb    [rsp+36h]
    test    byte ptr [rsp+36h],0FFh
    je      L9
    mov     rsi,[rsp+98h]
    mov     [rsp+70h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
L10:
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L12:
    mov     rax,[rsp+98h]
    cmp     rax,[rsp+40h]
    je      L13
    jmp     L14
L13:
    mov     rax,[rsp+90h]
    cmp     rax,[rsp+38h]
    je      L15
L14:
    call    qword ptr [sym1]
    ud2
L15:
    add     rsp,0E8h
    ret
L16:
    mov     rax,[rsp+0A8h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L19
    jmp     L18
L17:
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+18h],4
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L20
L18:
    mov     qword ptr [rsp+18h],1
    lea     rdx,[k2]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn3
L19:
    mov     rax,[rsp+38h]
    add     rax,1
    mov     [rsp+0A8h],rax
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+0C8h]
    mov     r8,[rsp+0C0h]
    call    fn4
    jmp     L3
L20:
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+80h]
    imul    rcx,[rsp+18h],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+58h]
    and     rsi,1
    cmp     rsi,0
    sete    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L7
    jmp     L5
L21:
    mov     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r9,[k5]
    mov     [rsp],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn6
L22:
    mov     rax,[rsp+70h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+0C8h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    movzx   esi,byte ptr [rsp+36h]
    mov     rdi,[rsp+98h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+98h],rdi
    movzx   r8d,byte ptr [rsp+36h]
    xor     r8b,1
    mov     [rsp+35h],r8b
    movzx   r9d,byte ptr [rsp+35h]
    mov     r10,[rsp+90h]
    imul    rcx,r9,4
    add     r10,rcx
    mov     [rsp+90h],r10
    jmp     L11
L23:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L24:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L25:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L26:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L27:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L28:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L37
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+98h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L2:
    test    byte ptr [rsp+6Fh],0FFh
    je      L3
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+68h],rdx
    lea     rsi,[rsp+68h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+58h],rdi
    mov     qword ptr [rsp+60h],1
    jmp     L4
L3:
    jmp     L13
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L5:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],rax
    mov     [rsp+48h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+40h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L7:
    jmp     L12
    nop
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L9:
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L25
    jmp     L24
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L11:
    test    byte ptr [rsp+4Fh],0FFh
    je      L12
    jmp     L4
L12:
    lea     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn0
L13:
    add     rsp,0B8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L15:
    lea     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L17:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+90h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    call    fn2
    mov     [rsp+6Fh],al
    jmp     L1
L18:
    mov     rax,[rsp+0A0h]
    mov     [rsp+90h],rax
    jmp     L16
L19:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0A0h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+90h],rdx
    jmp     L16
L20:
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+30h],rdx
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k3]
    mov     [rsp+8],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn4
L21:
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    mov     r8,[rsp+90h]
    mov     [rsp+58h],r8
    mov     r9,[rsp+90h]
    mov     [rsp+40h],r9
    cmp     r9,[rsp+0A8h]
    je      L6
    jmp     L8
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L23:
    mov     rax,[rsp+48h]
    mov     [rsp+90h],rax
    lea     rdx,[rsp+68h]
    mov     [rsp+38h],rdx
    mov     [rsp+40h],rax
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn5
    mov     [rsp+4Fh],al
    jmp     L10
L24:
    mov     rax,[rsp+90h]
    mov     [rsp+48h],rax
    jmp     L22
L25:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+90h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    jmp     L22
    nop     [rax]
L26:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L27:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L26
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L14
L28:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L29:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L30:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L31:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L32:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L33:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L34:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L17
L35:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L23
L36:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L27
L37:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L37
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L2:
    test    byte ptr [rsp+5Fh],0FFh
    je      L3
    mov     rdx,[rsp+90h]
    mov     edx,[rdx]
    mov     [rsp+5Ch],edx
    lea     rsi,[rsp+5Ch]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+90h]
    mov     [rsp+48h],rdi
    mov     qword ptr [rsp+50h],1
    jmp     L4
L3:
    jmp     L13
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L5:
    mov     rax,[rsp+80h]
    mov     [rsp+70h],rax
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L21
    jmp     L20
    xchg    ax,ax
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L7:
    jmp     L12
    nop
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L9:
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L25
    jmp     L24
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L11:
    test    byte ptr [rsp+5Bh],0FFh
    je      L12
    jmp     L4
L12:
    lea     rax,[rsp+40h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn0
L13:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L15:
    lea     rax,[rsp+40h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L17:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+80h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    call    fn2
    mov     [rsp+5Fh],al
    jmp     L1
L18:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],rax
    jmp     L16
L19:
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+90h]
    imul    rcx,[rsp+18h],4
    add     rdx,rcx
    mov     [rsp+80h],rdx
    jmp     L16
L20:
    mov     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r9,[k3]
    mov     [rsp],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn4
L21:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+30h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    mov     rsi,[rsp+80h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+38h],rdi
    cmp     rdi,[rsp+98h]
    je      L6
    jmp     L8
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L23:
    mov     rax,[rsp+38h]
    mov     [rsp+80h],rax
    lea     rdx,[rsp+5Ch]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+38h]
    call    fn5
    mov     [rsp+5Bh],al
    jmp     L10
L24:
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    jmp     L22
L25:
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+80h]
    imul    rcx,[rsp+18h],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L22
    nop     [rax]
L26:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L27:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L26
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L14
L28:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L29:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L30:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L31:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L32:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L33:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L34:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L17
L35:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L23
L36:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L27
L37:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L7
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+48h],rdx
    mov     [rsp+40h],rcx
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    cmp     qword ptr [rsp+48h],0
    je      L1
    cmp     rax,[rsp+48h]
    jae     L2
L1:
    lea     rdi,[rsp+60h]
    call    ryo_h_Abort
    ud2
L2:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rax
    imul    rcx,[rsp+30h],8
    add     rax,rcx
    mov     [rsp+20h],rax
    mov     rsi,[rsp+28h]
    imul    rcx,[rsp+48h],8
    add     rsi,rcx
    mov     [rsp+38h],rsi
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L4:
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,[rsp+20h]
    je      L5
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L3
L5:
    add     rsp,68h
    ret
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L7
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+48h],rdx
    mov     [rsp+40h],rcx
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    cmp     qword ptr [rsp+48h],0
    je      L1
    cmp     rax,[rsp+48h]
    jae     L2
L1:
    lea     rdi,[rsp+60h]
    call    ryo_h_Abort
    ud2
L2:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rax
    imul    rcx,[rsp+30h],4
    add     rax,rcx
    mov     [rsp+20h],rax
    mov     rsi,[rsp+28h]
    imul    rcx,[rsp+48h],4
    add     rsi,rcx
    mov     [rsp+38h],rsi
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L4:
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,[rsp+20h]
    je      L5
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+38h]
    imul    rcx,[rsp+8],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L3
L5:
    add     rsp,68h
    ret
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_down::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0A8h
    mov     [rsp+50h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+70h],rcx
    mov     [rsp+68h],r8
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+67h],al
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+4Fh],al
    test    byte ptr [rsp+4Fh],0FFh
    je      L1
    mov     rsi,[rsp+78h]
    mov     [rsp+58h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+80h]
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     rdi,[rsp+58h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k1]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L3:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+58h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    movzx   r8d,byte ptr [rsp+4Fh]
    mov     qword ptr [rsp+20h],0
    mov     r10,[rsp+20h]
    sub     r10,r8
    mov     r11,[rsp+78h]
    imul    rcx,r10,8
    add     r11,rcx
    mov     [rsp+78h],r11
    movzx   eax,byte ptr [rsp+67h]
    mov     qword ptr [rsp+20h],0
    mov     rsi,[rsp+20h]
    sub     rsi,rax
    mov     [rsp+30h],rsi
    mov     rdi,[rsp+80h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     [rsp+80h],rdi
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L7
    jmp     L6
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    mov     rax,[rsp+40h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+88h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0A8h
    ret
L6:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    jmp     L4
L7:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+70h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L4
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0A8h
    mov     [rsp+50h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+70h],rcx
    mov     [rsp+68h],r8
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+67h],al
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+4Fh],al
    test    byte ptr [rsp+4Fh],0FFh
    je      L1
    mov     rsi,[rsp+78h]
    mov     [rsp+58h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+80h]
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     rdi,[rsp+58h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k1]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L3:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    movzx   esi,byte ptr [rsp+4Fh]
    mov     qword ptr [rsp+20h],0
    mov     r8,[rsp+20h]
    sub     r8,rsi
    mov     r9,[rsp+78h]
    imul    rcx,r8,4
    add     r9,rcx
    mov     [rsp+78h],r9
    movzx   r10d,byte ptr [rsp+67h]
    mov     qword ptr [rsp+20h],0
    mov     rax,[rsp+20h]
    sub     rax,r10
    mov     [rsp+30h],rax
    mov     rdx,[rsp+80h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     [rsp+80h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L7
    jmp     L6
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    mov     rax,[rsp+40h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+88h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+90h],rsi
    mov     [rsp+98h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0A8h
    ret
L6:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    jmp     L4
L7:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+70h]
    imul    rcx,[rsp+20h],4
    add     rdx,rcx
    mov     [rsp+40h],rdx
    jmp     L4
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_up::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0A8h
    mov     [rsp+50h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+70h],rcx
    mov     [rsp+68h],r8
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+67h],al
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+4Fh],al
    test    byte ptr [rsp+4Fh],0FFh
    je      L1
    mov     rsi,[rsp+80h]
    mov     [rsp+58h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     rdi,[rsp+58h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k1]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L3:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+58h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    movzx   r8d,byte ptr [rsp+67h]
    mov     r9,[rsp+78h]
    imul    rcx,r8,8
    add     r9,rcx
    mov     [rsp+78h],r9
    movzx   r10d,byte ptr [rsp+4Fh]
    mov     r11,[rsp+80h]
    imul    rcx,r10,8
    add     r11,rcx
    mov     [rsp+80h],r11
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+70h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+88h],r11
    mov     [rsp+90h],r9
    mov     [rsp+98h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0A8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0A8h
    mov     [rsp+50h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+70h],rcx
    mov     [rsp+68h],r8
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+67h],al
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+4Fh],al
    test    byte ptr [rsp+4Fh],0FFh
    je      L1
    mov     rsi,[rsp+80h]
    mov     [rsp+58h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
L2:
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     rdi,[rsp+58h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k1]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L3:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    movzx   esi,byte ptr [rsp+67h]
    mov     rdi,[rsp+78h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+78h],rdi
    movzx   r8d,byte ptr [rsp+4Fh]
    mov     r9,[rsp+80h]
    imul    rcx,r8,4
    add     r9,rcx
    mov     [rsp+80h],r9
    mov     qword ptr [rsp+20h],1
    mov     r11,[rsp+70h]
    imul    rcx,[rsp+20h],4
    add     r11,rcx
    mov     [rsp+70h],r11
    mov     [rsp+88h],r9
    mov     [rsp+90h],rdi
    mov     [rsp+98h],r11
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+50h]
    add     rsp,0A8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_general::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,138h
    mov     [rsp+120h],rdi
    mov     [rsp+128h],rsi
    mov     [rsp+118h],rdx
    lea     rax,[rsp+38h]
    mov     [rsp+0F8h],rax
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    add     rsp,138h
    ret
L3:
    mov     rax,[rsp+0F8h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],30h
    lea     r8,[k0]
    mov     [rsp],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp]
    call    fn1
L4:
    mov     rax,[rsp+0F8h]
    mov     qword ptr [rsp+28h],30h
    mov     [rsp+108h],rax
    mov     rsi,[rsp+28h]
    mov     [rsp+110h],rsi
    mov     rdi,[rsp+120h]
    mov     rsi,[rsp+128h]
    mov     rdx,[rsp+108h]
    mov     rcx,[rsp+110h]
    mov     r8,[rsp+118h]
    call    fn2
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L54
L0:
    sub     rsp,198h
    mov     [rsp+180h],rdi
    mov     [rsp+188h],rsi
    mov     [rsp+170h],rdx
    mov     [rsp+178h],rcx
    mov     [rsp+168h],r8
    mov     rax,[rsp+188h]
    mov     [rsp+0D8h],rax
    cmp     rax,2
    jae     L1
    jmp     L23
L1:
    mov     rax,[rsp+178h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0D8h]
    add     rdx,10h
    mov     [rsp+0C0h],rdx
    cmp     rax,rdx
    jae     L2
    lea     rdi,[rsp+190h]
    call    ryo_h_Abort
    ud2
L2:
    mov     rax,[rsp+180h]
    mov     [rsp+108h],rax
    mov     rdx,[rsp+188h]
    mov     [rsp+110h],rdx
    mov     [rsp+0D0h],rax
    mov     rsi,[rsp+0D8h]
    shr     rsi,1
    mov     [rsp+0C8h],rsi
    mov     rdi,[rsp+170h]
    mov     [rsp+0F8h],rdi
    mov     r8,[rsp+178h]
    mov     [rsp+100h],r8
    mov     [rsp+160h],rdi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L3
    cmp     qword ptr [rsp+0D8h],10h
    jb      L3
    imul    rcx,[rsp+0D8h],8
    add     rdi,rcx
    mov     [rsp+0B0h],rdi
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+160h]
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp+168h]
    call    fn0
    mov     rax,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],8
    add     rax,rcx
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+160h]
    imul    rcx,[rsp+0C8h],8
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+0D8h]
    add     rsi,8
    mov     rdi,[rsp+160h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+0A0h],rdi
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+168h]
    call    fn1
    mov     qword ptr [rsp+0C0h],8
    jmp     L5
L3:
    cmp     qword ptr [rsp+0D8h],8
    jb      L4
    mov     rdx,[rsp+108h]
    mov     [rsp+0B0h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+160h]
    mov     rdx,[rsp+168h]
    call    fn2
    mov     rax,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],8
    add     rax,rcx
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+160h]
    imul    rcx,[rsp+0C8h],8
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp+168h]
    call    fn3
    mov     qword ptr [rsp+0C0h],4
    jmp     L5
L4:
    mov     rax,[rsp+108h]
    mov     [rsp+0B0h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L31
    jmp     L30
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L43
L6:
    mov     qword ptr [rsp+90h],0
    mov     rdx,[rsp+0C8h]
    mov     [rsp+98h],rdx
    mov     rsi,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rsi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFED0h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+78h],rcx
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdi,[rsp+78h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdi
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L44
L8:
    lea     rax,[rsp+80h]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+68h],2
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    call    fn5
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    jmp     L33
    ud2
    nop     [rax+rax]
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L45
L10:
    mov     rax,[rsp+78h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0D0h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+160h]
    imul    rcx,rax,8
    add     rsi,rcx
    mov     [rsp+58h],rsi
    cmp     rax,0
    je      L13
    jmp     L14
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L46
L12:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn6
    jmp     L20
L13:
    mov     rax,[rsp+0C8h]
    mov     [rsp+140h],rax
    jmp     L15
L14:
    mov     rax,[rsp+0D8h]
    sub     rax,[rsp+0C8h]
    mov     [rsp+140h],rax
L15:
    mov     rax,[rsp+0C0h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+138h],rdx
    nop     [rax+rax]
    nop     [rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L47
L17:
    mov     rax,[rsp+130h]
    mov     rdx,[rsp+138h]
    cmp     rax,rdx
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L35
    jmp     L34
    nop     [rax+rax]
    xchg    ax,ax
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L48
L19:
    jmp     L16
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0B8h],rsi
    mov     [rsp+90h],rax
    mov     [rsp+88h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L40
    jmp     L39
    nop     [rax+rax]
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L49
L22:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0A0h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+98h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+90h],rsi
L23:
    add     rsp,198h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L50
L25:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn7
    nop     [rax+rax]
    nop     [rax]
L26:
    inc     qword ptr [jit_record.ctr_l]
    jns     L51
L27:
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L52
L29:
    lea     rax,[rsp+0A8h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn8
    jmp     L26
L30:
    mov     rax,[rsp+108h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+0A0h],rdx
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r9,[k9]
    mov     [rsp],r9
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn10
L31:
    mov     rax,[rsp+0B0h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+0B0h]
    mov     edx,[rdx+4]
    mov     [rsp+14h],edx
    mov     rsi,[rsp+160h]
    mov     ecx,[rsp+10h]
    mov     [rsi],ecx
    mov     rdi,[rsp+160h]
    mov     ecx,[rsp+14h]
    mov     [rdi+4],ecx
    mov     r8,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],8
    add     r8,rcx
    mov     [rsp+158h],r8
    mov     [rsp+0B0h],r8
    mov     r9,[rsp+160h]
    imul    rcx,[rsp+0C8h],8
    add     r9,rcx
    mov     [rsp+0A8h],r9
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L32
    mov     rax,[rsp+158h]
    mov     [rsp+0A0h],rax
    mov     [rsp+98h],r9
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r10,[k11]
    mov     [rsp],r10
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn12
L32:
    mov     rax,[rsp+0B0h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+0B0h]
    mov     edx,[rdx+4]
    mov     [rsp+14h],edx
    mov     rsi,[rsp+0A8h]
    mov     ecx,[rsp+10h]
    mov     [rsi],ecx
    mov     rdi,[rsp+0A8h]
    mov     ecx,[rsp+14h]
    mov     [rdi+4],ecx
    mov     qword ptr [rsp+0C0h],1
    jmp     L5
L33:
    mov     rax,[rsp+70h]
    mov     [rsp+148h],rax
    cmp     rax,0
    je      L11
    jmp     L9
L34:
    mov     rax,[rsp+130h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L37
    jmp     L36
L35:
    jmp     L7
L36:
    mov     qword ptr [rsp+18h],1
    lea     rdx,[k13]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn14
L37:
    mov     rax,[rsp+38h]
    add     rax,1
    mov     [rsp+130h],rax
    mov     rdx,[rsp+38h]
    mov     qword ptr [rsp+48h],1
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+60h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rsp+120h],rdi
    mov     [rsp+38h],rdi
    mov     r8,[rsp+58h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rsp+118h],r8
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L38
    mov     r11,[rsp+120h]
    mov     [rsp+30h],r11
    mov     [rsp+28h],r8
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     rsi,[k15]
    mov     [rsp],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn16
L38:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+38h]
    mov     edx,[rdx+4]
    mov     [rsp+14h],edx
    mov     rsi,[rsp+118h]
    mov     ecx,[rsp+10h]
    mov     [rsi],ecx
    mov     rdi,[rsp+118h]
    mov     ecx,[rsp+14h]
    mov     [rdi+4],ecx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+118h]
    mov     rdx,[rsp+168h]
    call    fn17
    jmp     L18
L39:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    lea     rdi,[k18]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp+8]
    call    fn19
L40:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+88h]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+90h],rsi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+168h]
    call    fn20
    jmp     L21
    nop     [rax+rax]
    nop
L41:
    inc     qword ptr [jit_record.ctr_l]
    jns     L53
L42:
    call    qword ptr [sym21]
    ud2
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L24
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L41
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L28
L43:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L6
L44:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L45:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L46:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L47:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L17
L48:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L49:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L50:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L25
L51:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L27
L52:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L53:
    lea     r11,[jit_record]
    mov     eax,0Ah
    call    qword ptr [r11+10h]
    jmp     L42
L54:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L54
L0:
    sub     rsp,198h
    mov     [rsp+180h],rdi
    mov     [rsp+188h],rsi
    mov     [rsp+170h],rdx
    mov     [rsp+178h],rcx
    mov     [rsp+168h],r8
    mov     rax,[rsp+188h]
    mov     [rsp+0D8h],rax
    cmp     rax,2
    jae     L1
    jmp     L23
L1:
    mov     rax,[rsp+178h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0D8h]
    add     rdx,10h
    mov     [rsp+0C0h],rdx
    cmp     rax,rdx
    jae     L2
    lea     rdi,[rsp+190h]
    call    ryo_h_Abort
    ud2
L2:
    mov     rax,[rsp+180h]
    mov     [rsp+108h],rax
    mov     rdx,[rsp+188h]
    mov     [rsp+110h],rdx
    mov     [rsp+0D0h],rax
    mov     rsi,[rsp+0D8h]
    shr     rsi,1
    mov     [rsp+0C8h],rsi
    mov     rdi,[rsp+170h]
    mov     [rsp+0F8h],rdi
    mov     r8,[rsp+178h]
    mov     [rsp+100h],r8
    mov     [rsp+160h],rdi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L3
    cmp     qword ptr [rsp+0D8h],10h
    jb      L3
    imul    rcx,[rsp+0D8h],4
    add     rdi,rcx
    mov     [rsp+0B0h],rdi
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+160h]
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp+168h]
    call    fn0
    mov     rax,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],4
    add     rax,rcx
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+160h]
    imul    rcx,[rsp+0C8h],4
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+0D8h]
    add     rsi,8
    mov     rdi,[rsp+160h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+0A0h],rdi
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+168h]
    call    fn1
    mov     qword ptr [rsp+0C0h],8
    jmp     L5
L3:
    cmp     qword ptr [rsp+0D8h],8
    jb      L4
    mov     rdx,[rsp+108h]
    mov     [rsp+0B0h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+160h]
    mov     rdx,[rsp+168h]
    call    fn2
    mov     rax,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],4
    add     rax,rcx
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+160h]
    imul    rcx,[rsp+0C8h],4
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rsi,[rsp+0A8h]
    mov     rdx,[rsp+168h]
    call    fn3
    mov     qword ptr [rsp+0C0h],4
    jmp     L5
L4:
    mov     rax,[rsp+108h]
    mov     [rsp+0B0h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L31
    jmp     L30
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L43
L6:
    mov     qword ptr [rsp+90h],0
    mov     rdx,[rsp+0C8h]
    mov     [rsp+98h],rdx
    mov     rsi,[rsp+90h]
    mov     rcx,[rsp+98h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rsi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFED0h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+88h]
    mov     [rsp+78h],rcx
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdi,[rsp+78h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdi
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L44
L8:
    lea     rax,[rsp+80h]
    mov     [rsp+60h],rax
    mov     qword ptr [rsp+68h],2
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    call    fn5
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    jmp     L33
    ud2
    nop     [rax+rax]
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L45
L10:
    mov     rax,[rsp+78h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0D0h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+160h]
    imul    rcx,rax,4
    add     rsi,rcx
    mov     [rsp+58h],rsi
    cmp     rax,0
    je      L13
    jmp     L14
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L46
L12:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn6
    jmp     L20
L13:
    mov     rax,[rsp+0C8h]
    mov     [rsp+140h],rax
    jmp     L15
L14:
    mov     rax,[rsp+0D8h]
    sub     rax,[rsp+0C8h]
    mov     [rsp+140h],rax
L15:
    mov     rax,[rsp+0C0h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+138h],rdx
    nop     [rax+rax]
    nop     [rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L47
L17:
    mov     rax,[rsp+130h]
    mov     rdx,[rsp+138h]
    cmp     rax,rdx
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L35
    jmp     L34
    nop     [rax+rax]
    xchg    ax,ax
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L48
L19:
    jmp     L16
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0B8h],rsi
    mov     [rsp+90h],rax
    mov     [rsp+88h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L40
    jmp     L39
    nop     [rax+rax]
    nop     [rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L49
L22:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0A0h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+98h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+90h],rsi
L23:
    add     rsp,198h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L24:
    inc     qword ptr [jit_record.ctr_l]
    jns     L50
L25:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn7
    nop     [rax+rax]
    nop     [rax]
L26:
    inc     qword ptr [jit_record.ctr_l]
    jns     L51
L27:
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF50h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L52
L29:
    lea     rax,[rsp+0A8h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn8
    jmp     L26
L30:
    mov     rax,[rsp+108h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+0A0h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r9,[k9]
    mov     [rsp],r9
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn10
L31:
    mov     rax,[rsp+0B0h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+160h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    mov     rsi,[rsp+0D0h]
    imul    rcx,[rsp+0C8h],4
    add     rsi,rcx
    mov     [rsp+158h],rsi
    mov     [rsp+0B0h],rsi
    mov     rdi,[rsp+160h]
    imul    rcx,[rsp+0C8h],4
    add     rdi,rcx
    mov     [rsp+0A8h],rdi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L32
    mov     r10,[rsp+158h]
    mov     [rsp+0A0h],r10
    mov     [rsp+98h],rdi
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     r8,[k11]
    mov     [rsp],r8
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn12
L32:
    mov     rax,[rsp+0B0h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+0A8h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    mov     qword ptr [rsp+0C0h],1
    jmp     L5
L33:
    mov     rax,[rsp+70h]
    mov     [rsp+148h],rax
    cmp     rax,0
    je      L11
    jmp     L9
L34:
    mov     rax,[rsp+130h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L37
    jmp     L36
L35:
    jmp     L7
L36:
    mov     qword ptr [rsp+18h],1
    lea     rdx,[k13]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn14
L37:
    mov     rax,[rsp+38h]
    add     rax,1
    mov     [rsp+130h],rax
    mov     rdx,[rsp+38h]
    mov     qword ptr [rsp+48h],1
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+60h]
    imul    rcx,rdx,4
    add     rdi,rcx
    mov     [rsp+120h],rdi
    mov     [rsp+38h],rdi
    mov     r8,[rsp+58h]
    imul    rcx,rdx,4
    add     r8,rcx
    mov     [rsp+118h],r8
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L38
    mov     r11,[rsp+120h]
    mov     [rsp+30h],r11
    mov     [rsp+28h],r8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],1
    lea     rsi,[k15]
    mov     [rsp],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    mov     r9,[rsp]
    call    fn16
L38:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+10h],eax
    mov     rdx,[rsp+118h]
    mov     ecx,[rsp+10h]
    mov     [rdx],ecx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+118h]
    mov     rdx,[rsp+168h]
    call    fn17
    jmp     L18
L39:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    lea     rdi,[k18]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp+8]
    call    fn19
L40:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+88h]
    mov     [rsp+98h],rax
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+90h],rsi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+168h]
    call    fn20
    jmp     L21
    nop
L41:
    inc     qword ptr [jit_record.ctr_l]
    jns     L53
L42:
    call    qword ptr [sym21]
    ud2
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L24
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L41
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF50h
    call    ryo_h_Lpad
    jmp     L28
L43:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L6
L44:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L45:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L46:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L47:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L17
L48:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L49:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L22
L50:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L25
L51:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L27
L52:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L53:
    lea     r11,[jit_record]
    mov     eax,0Ah
    call    qword ptr [r11+10h]
    jmp     L42
L54:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L27
L0:
    sub     rsp,158h
    mov     [rsp+140h],rdi
    mov     [rsp+148h],rsi
    mov     [rsp+138h],rdx
    mov     rax,[rsp+148h]
    mov     [rsp+0D8h],rax
    cmp     rax,2
    jae     L1
    jmp     L14
L1:
    cmp     qword ptr [rsp+0D8h],20h
    jbe     L2
    lea     rdi,[rsp+150h]
    call    ryo_h_Abort
    ud2
L2:
    mov     rax,[rsp+0D8h]
    shr     rax,1
    mov     [rsp+50h],rax
    cmp     qword ptr [rsp+0D8h],12h
    setb    [rsp+4Fh]
    mov     rsi,[rsp+140h]
    mov     [rsp+0F8h],rsi
    mov     rdi,[rsp+148h]
    mov     [rsp+100h],rdi
    mov     [rsp+40h],rsi
    test    byte ptr [rsp+4Fh],0FFh
    je      L3
    mov     r9,[rsp+0D8h]
    mov     [rsp+130h],r9
    jmp     L4
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+130h],rax
L4:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L17
    jmp     L16
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L6:
    mov     rax,[rsp+118h]
    mov     rdx,[rsp+120h]
    mov     [rsp+38h],rdx
    cmp     rdx,0Dh
    jb      L7
    mov     rdi,[rsp+118h]
    mov     rcx,[rsp+120h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rdi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+138h]
    call    fn0
    mov     qword ptr [rsp+128h],0Dh
    jmp     L9
L7:
    mov     rax,[rsp+118h]
    mov     rdx,[rsp+120h]
    mov     [rsp+38h],rdx
    cmp     rdx,9
    jb      L8
    mov     rdi,[rsp+118h]
    mov     rcx,[rsp+120h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rdi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+138h]
    call    fn1
    mov     qword ptr [rsp+128h],9
    jmp     L9
L8:
    mov     qword ptr [rsp+128h],1
L9:
    mov     rax,[rsp+118h]
    mov     rcx,[rsp+120h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+128h]
    mov     rcx,[rsp+138h]
    call    fn2
    test    byte ptr [rsp+4Fh],0FFh
    je      L10
    jmp     L14
L10:
    mov     rax,[rsp+118h]
    mov     rdx,[rsp+120h]
    mov     [rsp+38h],rax
    mov     rsi,[rsp+0F8h]
    mov     [rsp+30h],rsi
    cmp     rax,rsi
    je      L11
    lea     rdi,[rsp+58h]
    mov     [rsp+0F0h],rdi
    mov     [rsp+110h],rdi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L21
    jmp     L20
L11:
    mov     rax,[rsp+40h]
    imul    rcx,[rsp+50h],4
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rdx,[rsp+0D8h]
    sub     rdx,[rsp+50h]
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L19
    jmp     L18
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L13:
    mov     rax,[rsp+0F0h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L23
    jmp     L22
    nop
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L15:
    add     rsp,158h
    ret
L16:
    mov     rax,[rsp+0F8h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k3]
    mov     [rsp],rdi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+130h]
    mov     r8,[rsp]
    call    fn4
L17:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+130h]
    mov     [rsp+118h],rax
    mov     [rsp+120h],rdx
    jmp     L5
L18:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k5]
    mov     [rsp],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp]
    call    fn6
L19:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     [rsp+118h],rax
    mov     [rsp+120h],rdx
    jmp     L5
L20:
    mov     rax,[rsp+0F8h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k7]
    mov     [rsp],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+0D8h]
    mov     r8,[rsp]
    call    fn8
L21:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+0D8h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+110h]
    mov     rcx,[rsp+138h]
    call    fn9
    jmp     L12
L22:
    mov     rax,[rsp+0F0h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     r8,[k10]
    mov     [rsp],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+0D8h]
    mov     r9,[rsp]
    call    fn11
L23:
    imul    rax,[rsp+0D8h],4
    mov     [rsp+10h],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFEE8h
    mov     ecx,0FFFFFEC0h
    call    ryo_h_Memcpy
    jmp     L14
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L6
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L13
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L15
L27:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rdx
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    cmp     rax,0Dh
    jae     L1
    lea     rdi,[rsp+40h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],0Ch
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn0
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],0Ah
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn1
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],9
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn2
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn3
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],0Bh
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn4
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn5
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn6
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn7
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],0Bh
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn8
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp],9
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn9
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp],0Ah
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn10
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn11
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn12
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn13
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn14
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp],0Ah
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn15
    mov     qword ptr [rsp+8],0Bh
    mov     qword ptr [rsp],0Ch
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn16
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn17
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],9
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn18
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp],0Bh
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn19
    mov     qword ptr [rsp+8],0Ah
    mov     qword ptr [rsp],0Ch
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn20
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn21
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn22
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn23
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],0Bh
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn24
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp],0Ah
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn25
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn26
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn27
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],9
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn28
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn29
    mov     qword ptr [rsp+8],0Ah
    mov     qword ptr [rsp],0Bh
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn30
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn31
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn32
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn33
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp],0Ah
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn34
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn35
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn36
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn37
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn38
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn39
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn40
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn41
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp],9
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn42
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn43
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn44
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+98h],rdx
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+88h]
    call    fn0
    mov     [rsp+97h],al
    mov     qword ptr [rsp+20h],3
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     qword ptr [rsp+20h],2
    mov     rdi,[rsp+0A8h]
    imul    rcx,[rsp+20h],8
    add     rdi,rcx
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rdi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+88h]
    call    fn1
    mov     [rsp+96h],al
    movzx   eax,byte ptr [rsp+97h]
    mov     rdx,[rsp+0A8h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+88h],rdx
    movzx   esi,byte ptr [rsp+97h]
    xor     sil,1
    mov     [rsp+95h],sil
    movzx   edi,byte ptr [rsp+95h]
    mov     r8,[rsp+0A8h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+80h],r8
    movzx   r9d,byte ptr [rsp+96h]
    mov     qword ptr [rsp+20h],2
    mov     r11,[rsp+20h]
    add     r11,r9
    mov     rax,[rsp+0A8h]
    imul    rcx,r11,8
    add     rax,rcx
    mov     [rsp+78h],rax
    movzx   esi,byte ptr [rsp+96h]
    xor     sil,1
    mov     [rsp+95h],sil
    movzx   edi,byte ptr [rsp+95h]
    mov     qword ptr [rsp+20h],2
    mov     rsi,[rsp+20h]
    add     rsi,rdi
    mov     r9,[rsp+0A8h]
    imul    rcx,rsi,8
    add     r9,rcx
    mov     [rsp+70h],r9
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    call    fn2
    mov     [rsp+95h],al
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+80h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    call    fn3
    mov     [rsp+94h],al
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+88h]
    call    fn4
    mov     [rsp+68h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+70h]
    call    fn5
    mov     [rsp+60h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    call    fn6
    mov     [rsp+50h],rax
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+50h]
    call    fn7
    mov     [rsp+58h],rax
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+78h]
    call    fn8
    mov     [rsp+48h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+48h]
    call    fn9
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn10
    mov     [rsp+93h],al
    movzx   edi,byte ptr [rsp+93h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+58h]
    call    fn11
    mov     [rsp+48h],rax
    movzx   edi,byte ptr [rsp+93h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+50h]
    call    fn12
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rsi,[rsp+68h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+30h],rdi
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k13]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn14
L1:
    mov     rax,[rsp+68h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+68h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+0A0h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+0A0h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    mov     qword ptr [rsp+20h],1
    mov     r9,[rsp+0A0h]
    imul    rcx,[rsp+20h],8
    add     r9,rcx
    mov     [rsp+38h],r9
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L2
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     [rsp+28h],r9
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r8,[k15]
    mov     [rsp+8],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn16
L2:
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+38h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    mov     qword ptr [rsp+20h],2
    mov     r9,[rsp+0A0h]
    imul    rcx,[rsp+20h],8
    add     r9,rcx
    mov     [rsp+38h],r9
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     [rsp+28h],r9
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r8,[k17]
    mov     [rsp+8],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn18
L3:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+40h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+38h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    mov     qword ptr [rsp+20h],3
    mov     r9,[rsp+0A0h]
    imul    rcx,[rsp+20h],8
    add     r9,rcx
    mov     [rsp+38h],r9
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L4
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     [rsp+28h],r9
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r8,[k19]
    mov     [rsp+8],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn20
L4:
    mov     rax,[rsp+60h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+60h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+38h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    add     rsp,0B8h
    ret
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L5
L0:
    sub     rsp,0B8h
    mov     [rsp+0A8h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+98h],rdx
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+20h],4
    add     rdx,rcx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+88h]
    call    fn0
    mov     [rsp+97h],al
    mov     qword ptr [rsp+20h],3
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+20h],4
    add     rdx,rcx
    mov     qword ptr [rsp+20h],2
    mov     rdi,[rsp+0A8h]
    imul    rcx,[rsp+20h],4
    add     rdi,rcx
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rdi
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+88h]
    call    fn1
    mov     [rsp+96h],al
    movzx   eax,byte ptr [rsp+97h]
    mov     rdx,[rsp+0A8h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+88h],rdx
    movzx   esi,byte ptr [rsp+97h]
    xor     sil,1
    mov     [rsp+95h],sil
    movzx   edi,byte ptr [rsp+95h]
    mov     r8,[rsp+0A8h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rsp+80h],r8
    movzx   r9d,byte ptr [rsp+96h]
    mov     qword ptr [rsp+20h],2
    mov     r11,[rsp+20h]
    add     r11,r9
    mov     rax,[rsp+0A8h]
    imul    rcx,r11,4
    add     rax,rcx
    mov     [rsp+78h],rax
    movzx   esi,byte ptr [rsp+96h]
    xor     sil,1
    mov     [rsp+95h],sil
    movzx   edi,byte ptr [rsp+95h]
    mov     qword ptr [rsp+20h],2
    mov     rsi,[rsp+20h]
    add     rsi,rdi
    mov     r9,[rsp+0A8h]
    imul    rcx,rsi,4
    add     r9,rcx
    mov     [rsp+70h],r9
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    call    fn2
    mov     [rsp+95h],al
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+80h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    call    fn3
    mov     [rsp+94h],al
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+88h]
    call    fn4
    mov     [rsp+68h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+70h]
    call    fn5
    mov     [rsp+60h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    call    fn6
    mov     [rsp+50h],rax
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+50h]
    call    fn7
    mov     [rsp+58h],rax
    movzx   edi,byte ptr [rsp+95h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+78h]
    call    fn8
    mov     [rsp+48h],rax
    movzx   edi,byte ptr [rsp+94h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+48h]
    call    fn9
    mov     [rsp+50h],rax
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn10
    mov     [rsp+93h],al
    movzx   edi,byte ptr [rsp+93h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+58h]
    call    fn11
    mov     [rsp+48h],rax
    movzx   edi,byte ptr [rsp+93h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+50h]
    call    fn12
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     rsi,[rsp+68h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+30h],rdi
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r11,[k13]
    mov     [rsp+8],r11
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn14
L1:
    mov     rax,[rsp+68h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+0A0h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     qword ptr [rsp+20h],1
    mov     rdi,[rsp+0A0h]
    imul    rcx,[rsp+20h],4
    add     rdi,rcx
    mov     [rsp+38h],rdi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L2
    mov     r10,[rsp+48h]
    mov     [rsp+30h],r10
    mov     [rsp+28h],rdi
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     rsi,[k15]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn16
L2:
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     qword ptr [rsp+20h],2
    mov     rdi,[rsp+0A0h]
    imul    rcx,[rsp+20h],4
    add     rdi,rcx
    mov     [rsp+38h],rdi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     r10,[rsp+40h]
    mov     [rsp+30h],r10
    mov     [rsp+28h],rdi
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     rsi,[k17]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn18
L3:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     qword ptr [rsp+20h],3
    mov     rdi,[rsp+0A0h]
    imul    rcx,[rsp+20h],4
    add     rdi,rcx
    mov     [rsp+38h],rdi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L4
    mov     r10,[rsp+60h]
    mov     [rsp+30h],r10
    mov     [rsp+28h],rdi
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     rsi,[k19]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn20
L4:
    mov     rax,[rsp+60h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    add     rsp,0B8h
    ret
L5:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rcx
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+50h]
    call    fn0
    mov     qword ptr [rsp+20h],4
    mov     rdx,[rsp+68h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+20h],4
    mov     rdi,[rsp+58h]
    imul    rcx,[rsp+20h],8
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+50h]
    call    fn1
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    add     rsp,78h
    ret
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],8
    lea     r8,[k2]
    mov     [rsp+8],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    call    fn3
L4:
    mov     rax,[rsp+38h]
    mov     qword ptr [rsp+30h],8
    mov     [rsp+40h],rax
    mov     rsi,[rsp+30h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+50h]
    call    fn4
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort8_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rcx
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+50h]
    call    fn0
    mov     qword ptr [rsp+20h],4
    mov     rdx,[rsp+68h]
    imul    rcx,[rsp+20h],4
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+20h],4
    mov     rdi,[rsp+58h]
    imul    rcx,[rsp+20h],4
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+50h]
    call    fn1
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    add     rsp,78h
    ret
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],8
    lea     r8,[k2]
    mov     [rsp+8],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    call    fn3
L4:
    mov     rax,[rsp+38h]
    mov     qword ptr [rsp+30h],8
    mov     [rsp+40h],rax
    mov     rsi,[rsp+30h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+50h]
    call    fn4
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rdx
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    cmp     rax,9
    jae     L1
    lea     rdi,[rsp+40h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn0
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn1
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn2
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn3
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn4
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn5
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn6
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn7
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn8
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn9
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn10
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn11
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn12
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn13
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn14
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn15
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn16
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn17
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],8
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn18
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp],3
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn19
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp],5
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn20
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp],7
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn21
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp],2
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn22
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp],4
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn23
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp],6
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    mov     rcx,[rsp+28h]
    call    fn24
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     [rsp+70h],rcx
    mov     rax,[rsp+88h]
    imul    rcx,[rsp+80h],4
    add     rax,rcx
    mov     [rsp+60h],rax
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+78h],4
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn0
    mov     [rsp+57h],al
    movzx   edi,byte ptr [rsp+57h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    call    fn1
    mov     [rsp+48h],rax
    movzx   edi,byte ptr [rsp+57h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+58h]
    call    fn2
    mov     [rsp+40h],rax
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+50h],eax
    mov     rdx,[rsp+48h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L6
    jmp     L3
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    lea     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L8
    jmp     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L4
    mov     byte ptr [rsp+56h],1
    jmp     L5
L4:
    mov     byte ptr [rsp+56h],0
L5:
    mov     qword ptr [rsp+20h],4
    lea     rdx,[k3]
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    movzx   ecx,byte ptr [rsp+56h]
    mov     r8,[rsp+18h]
    call    fn4
L6:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+60h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    jmp     L1
L7:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k5]
    mov     [rsp+8],r9
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn6
L8:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+58h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    add     rsp,98h
    ret
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::AlignedStorage::<(u32, u32), 4096>::as_uninit_slice_mut
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,88h
    mov     [rsp+68h],rdi
    mov     qword ptr [rsp+18h],8
    cmp     qword ptr [rsp+18h],0
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L1
    lea     rdi,[k0]
    mov     [rsp+18h],rdi
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     qword ptr [rsp+18h],1000h
    mov     rdx,[rsp+18h]
    shr     rdx,3
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+68h]
    mov     qword ptr [rsp+30h],1000h
    mov     [rsp+50h],rsi
    mov     r8,[rsp+30h]
    mov     [rsp+58h],r8
    mov     [rsp+38h],rsi
    mov     r9,[rsp+50h]
    mov     [rsp+40h],r9
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L2
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    lea     r10,[k2]
    mov     [rsp+8],r10
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+48h]
    mov     r8,[rsp+8]
    call    fn3
L2:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0B8h
    mov     [rsp+98h],rdi
    mov     [rsp+0A0h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+90h],rcx
    mov     [rsp+80h],r8
    mov     [rsp+7Fh],r9b
    mov     rax,[rsp+0C0h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+60h],rdx
    cmp     rdx,[rsp+80h]
    jb      L3
    mov     rsi,[rsp+98h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+40h],rdi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+70h]
    call    fn0
    mov     [rsp+48h],rax
    mov     [rsp+50h],dl
    mov     rax,[rsp+48h]
    mov     [rsp+58h],rax
    movzx   edx,byte ptr [rsp+50h]
    mov     [rsp+6Dh],dl
    cmp     rax,[rsp+60h]
    setbe   [rsp+6Fh]
    cmp     rax,[rsp+80h]
    jb      L3
    test    byte ptr [rsp+6Dh],0FFh
    je      L1
    cmp     rax,0
    jb      L9
    jmp     L10
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    mov     rax,[rsp+58h]
    shl     rax,1
    or      rax,1
    mov     [rsp+0A8h],rax
    jmp     L7
L3:
    test    byte ptr [rsp+7Fh],0FFh
    je      L6
    call    fn1
    mov     [rsp+50h],rax
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+60h]
    call    fn2
    mov     [rsp+58h],rax
    jmp     L11
    xchg    ax,ax
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L5:
    mov     rax,[rsp+58h]
    shl     rax,1
    or      rax,1
    mov     [rsp+0A8h],rax
    jmp     L7
L6:
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+60h]
    call    fn3
    mov     [rsp+58h],rax
    jmp     L18
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
L9:
    mov     qword ptr [rsp+18h],0
    lea     rdx,[k4]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym5]
    ud2
L10:
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0A0h]
    mov     rsi,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    call    fn6
    jmp     L1
L11:
    cmp     qword ptr [rsp+58h],0
    jb      L16
    jmp     L17
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L13:
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0A0h]
    mov     rsi,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rsi
    mov     dword ptr [rsp+1Ch],0
    mov     qword ptr [rsp+10h],0
    mov     r9,[rsp+70h]
    mov     [rsp],r9
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     r8d,[rsp+1Ch]
    mov     r9,[rsp+10h]
    call    fn7
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L15:
    mov     qword ptr [rsp+18h],0
    lea     rdx,[k8]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym9]
    ud2
L16:
    jmp     L14
L17:
    mov     rax,[rsp+60h]
    cmp     rax,[rsp+58h]
    jae     L12
    jmp     L14
L18:
    mov     rax,[rsp+58h]
    shl     rax,1
    mov     [rsp+0A8h],rax
    jmp     L7
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L13
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L15
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::drift::logical_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L22
L0:
    sub     rsp,0C8h
    mov     [rsp+0A8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+90h],r8
    mov     [rsp+88h],r9
    mov     rax,[rsp+0D0h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0A0h]
    cmp     rdx,rsi
    setbe   [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L2
    mov     r8,[rsp+90h]
    and     r8,1
    cmp     r8,1
    sete    [rsp+5Eh]
    test    byte ptr [rsp+5Eh],0FFh
    je      L1
    jmp     L2
L1:
    mov     rax,[rsp+88h]
    and     rax,1
    cmp     rax,1
    sete    [rsp+5Dh]
    test    byte ptr [rsp+5Dh],0FFh
    je      L8
L2:
    mov     rax,[rsp+90h]
    mov     [rsp+68h],rax
    and     rax,1
    cmp     rax,1
    sete    [rsp+5Ch]
    test    byte ptr [rsp+5Ch],0FFh
    jne     L3
    mov     rdi,[rsp+68h]
    shr     rdi,1
    mov     [rsp+78h],rdi
    cmp     rdi,0
    jb      L14
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L4:
    mov     rax,[rsp+88h]
    and     rax,1
    cmp     rax,1
    sete    [rsp+5Ch]
    test    byte ptr [rsp+5Ch],0FFh
    je      L5
    jmp     L6
L5:
    mov     rax,[rsp+68h]
    shr     rax,1
    mov     [rsp+70h],rax
    mov     rdx,[rsp+60h]
    cmp     rdx,rax
    jb      L16
    jmp     L17
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L7:
    mov     rax,[rsp+68h]
    shr     rax,1
    mov     [rsp+50h],rax
    mov     rdi,[rsp+0A8h]
    mov     rsi,[rsp+0B0h]
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+50h]
    mov     r9,[rsp+80h]
    call    fn0
    mov     rax,[rsp+60h]
    shl     rax,1
    or      rax,1
    mov     [rsp+0B8h],rax
    jmp     L9
L8:
    mov     rax,[rsp+60h]
    shl     rax,1
    mov     [rsp+0B8h],rax
L9:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L11:
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    mov     rsi,[rsp+78h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+80h]
    call    fn1
    jmp     L3
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L13:
    mov     qword ptr [rsp+8],0
    lea     rdx,[k2]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    ud2
L14:
    jmp     L12
L15:
    mov     rax,[rsp+60h]
    cmp     rax,[rsp+78h]
    jae     L10
    jmp     L12
L16:
    lea     rax,[k4]
    mov     [rsp+8],rax
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym5]
    ud2
L17:
    mov     rax,[rsp+60h]
    sub     rax,[rsp+70h]
    mov     rdx,[rsp+0A8h]
    mov     rsi,[rsp+0B0h]
    imul    rcx,[rsp+70h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    mov     [rsp+50h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+0A0h]
    mov     r8,[rsp+80h]
    call    fn6
    jmp     L6
L18:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L19:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L20:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L11
L21:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L13
L22:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,398h
    mov     [rsp+380h],rdi
    mov     [rsp+388h],rsi
    mov     [rsp+370h],rdx
    mov     [rsp+378h],rcx
    mov     [rsp+36Fh],r8b
    mov     [rsp+360h],r9
    mov     rax,[rsp+388h]
    mov     [rsp+300h],rax
    cmp     rax,2
    jae     L1
    jmp     L22
L1:
    mov     rax,[rsp+300h]
    mov     [rsp+2F0h],rax
    cmp     rax,0
    sete    [rsp+2E7h]
    test    byte ptr [rsp+2E7h],0FFh
    je      L23
    lea     rdi,[k0]
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L3:
    mov     rax,[rsp+300h]
    shr     rax,1
    mov     rdx,[rsp+300h]
    sub     rdx,rax
    mov     [rsp+2E0h],rdx
    mov     qword ptr [rsp+10h],40h
    mov     rdi,[rsp+2E0h]
    mov     rsi,[rsp+10h]
    call    fn2
    mov     [rsp+2F0h],rax
    jmp     L27
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L5:
    mov     rdi,[rsp+300h]
    call    qword ptr [sym3]
    mov     [rsp+2F0h],rax
    nop     [rax+rax]
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L7:
    mov     qword ptr [rsp+2E8h],0
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFD48h
    lea     rdx,[k4]
    mov     ecx,210h
    call    ryo_h_Const
    lea     rax,[rsp+0D8h]
    mov     [rsp+310h],rax
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+310h]
    mov     [rsp+0D0h],rdx
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFCFEh
    lea     rdx,[k5]
    mov     ecx,42h
    call    ryo_h_Const
    lea     rax,[rsp+8Eh]
    mov     [rsp+308h],rax
    mov     rdx,[rsp+308h]
    mov     [rsp+80h],rdx
    mov     qword ptr [rsp+78h],0
    mov     qword ptr [rsp+328h],1
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L9:
    mov     rax,[rsp+78h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+300h]
    jae     L12
    mov     rdx,[rsp+78h]
    mov     [rsp+340h],rdx
    mov     rsi,[rsp+300h]
    cmp     rsi,rdx
    jb      L28
    jmp     L29
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L11:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+328h]
    shr     rdx,1
    sub     rax,rdx
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+78h]
    mov     r8,[rsp+348h]
    shr     r8,1
    add     rdi,r8
    mov     r9,[rsp+2F8h]
    mov     [rsp+58h],r9
    mov     [rsp+40h],rsi
    add     rax,rsi
    add     rsi,rdi
    imul    r9,rax
    mov     r10,[rsp+58h]
    imul    r10,rsi
    xor     r9,r10
    mov     [rsp+38h],r9
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC84h
    mov     edx,0FFFFFCA8h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+14h]
    mov     [rsp+88h],eax
    jmp     L30
L12:
    mov     qword ptr [rsp+348h],1
    mov     byte ptr [rsp+33Fh],0
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L14:
    mov     rax,[rsp+2E8h]
    mov     [rsp+70h],rax
    cmp     rax,1
    jbe     L18
    mov     rsi,[rsp+2E8h]
    sub     rsi,1
    mov     rdi,[rsp+80h]
    imul    rcx,rsi,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    mov     [rsp+8Bh],dil
    movzx   r8d,byte ptr [rsp+33Fh]
    mov     [rsp+8Ah],r8b
    cmp     dil,r8b
    jb      L17
    mov     r9,[rsp+2E8h]
    sub     r9,1
    mov     r10,[rsp+0D0h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     r10,[r10]
    mov     [rsp+70h],r10
    shr     r10,1
    mov     r11,[rsp+328h]
    shr     r11,1
    add     r10,r11
    mov     rax,[rsp+78h]
    sub     rax,r10
    mov     [rsp+60h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+330h],rdx
    mov     rsi,[rsp+380h]
    mov     [rsp+30h],rsi
    mov     r9,[rsp+388h]
    mov     [rsp+38h],r9
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L32
    jmp     L31
    nop     [rax+rax]
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L16:
    mov     rax,[rsp+2E8h]
    sub     rax,1
    mov     [rsp+2E8h],rax
    jmp     L13
L17:
    jmp     L18
L18:
    mov     rax,[rsp+328h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+2E8h]
    mov     rsi,[rsp+0D0h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     rcx,[rsp+70h]
    mov     [rsi],rcx
    mov     rdi,[rsp+2E8h]
    mov     r8,[rsp+80h]
    imul    rcx,rdi,1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+33Fh]
    mov     [r8],cl
    mov     r9,[rsp+2E8h]
    add     r9,1
    mov     [rsp+2E8h],r9
    mov     r10,[rsp+78h]
    mov     [rsp+70h],r10
    cmp     r10,[rsp+300h]
    jb      L19
    mov     r11,[rsp+328h]
    and     r11,1
    cmp     r11,1
    sete    [rsp+8Dh]
    test    byte ptr [rsp+8Dh],0FFh
    je      L21
    jmp     L20
L19:
    mov     rax,[rsp+348h]
    shr     rax,1
    mov     rdx,[rsp+78h]
    add     rdx,rax
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+348h]
    mov     [rsp+328h],rsi
    jmp     L8
L20:
    jmp     L22
L21:
    mov     rdi,[rsp+380h]
    mov     rsi,[rsp+388h]
    mov     rdx,[rsp+370h]
    mov     rcx,[rsp+378h]
    mov     r8,[rsp+360h]
    call    fn6
L22:
    add     rsp,398h
    ret
L23:
    mov     rax,4000000000000000h
    mov     [rsp+10h],rax
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFC80h
    mov     ecx,0FFFFFF60h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+2E7h],0FFh
    je      L24
    lea     rdx,[k7]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+10h]
    call    qword ptr [sym8]
    ud2
L24:
    mov     rax,4000000000000000h
    mov     [rsp+10h],rax
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFC80h
    mov     ecx,0FFFFFF60h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+2D8h],0
    jbe     L25
    mov     rdx,[rsp+2E8h]
    add     rdx,1
    mov     [rsp+2F8h],rdx
    jmp     L26
L25:
    mov     rax,[rsp+2E8h]
    mov     [rsp+2F8h],rax
L26:
    cmp     qword ptr [rsp+300h],1000h
    jbe     L2
    jmp     L4
L27:
    jmp     L6
L28:
    lea     rax,[k9]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+340h]
    mov     rsi,[rsp+300h]
    mov     rdx,[rsp+300h]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym10]
    ud2
L29:
    mov     rax,[rsp+300h]
    sub     rax,[rsp+340h]
    mov     rdx,[rsp+380h]
    mov     rsi,[rsp+388h]
    imul    rcx,[rsp+340h],8
    add     rdx,rcx
    mov     [rsp+68h],rdx
    mov     [rsp+70h],rax
    mov     rdi,[rsp+2F0h]
    mov     [rsp+60h],rdi
    mov     r8,[rsp+360h]
    mov     [rsp],r8
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+370h]
    mov     rcx,[rsp+378h]
    mov     r8,[rsp+60h]
    movzx   r9d,byte ptr [rsp+36Fh]
    call    fn11
    mov     [rsp+348h],rax
    jmp     L10
L30:
    mov     eax,[rsp+88h]
    mov     [rsp+33Fh],al
    jmp     L13
L31:
    lea     rax,[k12]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+330h]
    mov     rdx,[rsp+300h]
    mov     rcx,[rsp+10h]
    call    fn13
L32:
    mov     rax,[rsp+330h]
    sub     rax,[rsp+60h]
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp+60h],8
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rax
    mov     rsi,[rsp+328h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+360h]
    mov     [rsp],rdi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+370h]
    mov     rcx,[rsp+378h]
    mov     r8,[rsp+70h]
    mov     r9,[rsp+48h]
    call    fn14
    mov     [rsp+328h],rax
    jmp     L15
L33:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L34:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L35:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L36:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L37:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L38:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L39:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L16
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::drift::stable_quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+78h],rsi
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rcx
    mov     [rsp+58h],r8
    mov     rax,[rsp+78h]
    or      rax,1
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L3
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    add     rsp,88h
    ret
    ud2
L3:
    lea     rax,[k0]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    qword ptr [sym1]
    ud2
L4:
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFFA0h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+1Ch]
    mov     [rsp+2Ch],eax
    mov     dword ptr [rsp+1Ch],3Fh
    mov     esi,[rsp+1Ch]
    sub     esi,eax
    mov     dword ptr [rsp+1Ch],2
    mov     r8d,[rsp+1Ch]
    imul    r8d,esi
    mov     [rsp+50h],r8d
    mov     qword ptr [rsp+18h],0
    mov     r10,[rsp+58h]
    mov     [rsp],r10
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     r8d,[rsp+50h]
    mov     r9,[rsp+18h]
    call    fn2
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::driftsort_main::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}, std::vec::Vec<(u32, u32)>>
    inc     qword ptr [jit_record]
    jns     L24
L0:
    mov     eax,2078h
    call    ryo_probe_stack
    sub     rsp,2078h
    mov     [rsp+2060h],rdi
    mov     [rsp+2068h],rsi
    mov     [rsp+2058h],rdx
    mov     byte ptr [rsp+203Fh],0
    mov     qword ptr [rsp+10h],8
    cmp     qword ptr [rsp+10h],0
    sete    [rsp+2057h]
    test    byte ptr [rsp+2057h],0FFh
    je      L1
    lea     r8,[k0]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     qword ptr [rsp+10h],7A1200h
    mov     rdx,[rsp+10h]
    shr     rdx,3
    mov     [rsp+2028h],rdx
    mov     rsi,[rsp+2068h]
    mov     [rsp+2020h],rsi
    shr     rsi,1
    mov     rdi,[rsp+2020h]
    sub     rdi,rsi
    mov     [rsp+2008h],rdi
    mov     rdi,[rsp+2020h]
    mov     rsi,[rsp+2028h]
    call    fn2
    mov     [rsp+2000h],rax
    jmp     L15
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L3:
    mov     rax,[rsp+2048h]
    mov     [rsp+0FF0h],rax
    cmp     rax,[rsp+2018h]
    jb      L4
    jmp     L5
L4:
    lea     rdi,[rsp+0FE0h]
    mov     rsi,[rsp+2018h]
    call    fn3
    mov     byte ptr [rsp+203Fh],1
    mov     rdx,[rsp+0FE0h]
    mov     [rsp+1000h],rdx
    mov     rsi,[rsp+0FE8h]
    mov     [rsp+1008h],rsi
    mov     rdi,[rsp+0FF0h]
    mov     [rsp+1010h],rdi
    lea     r8,[rsp+1000h]
    mov     [rsp+0FF0h],r8
    mov     rdi,[rsp+0FF0h]
    call    fn4
    mov     [rsp+2040h],rax
    mov     [rsp+2048h],rdx
L5:
    call    fn5
    mov     [rsp+0FE8h],rax
    imul    rax,[rsp+0FE8h],2
    mov     rdx,[rsp+2020h]
    cmp     rdx,rax
    setbe   [rsp+0FFFh]
    mov     rdi,[rsp+2060h]
    mov     rsi,[rsp+2068h]
    mov     rdx,[rsp+2040h]
    mov     rcx,[rsp+2048h]
    movzx   r8d,byte ptr [rsp+0FFFh]
    mov     r9,[rsp+2058h]
    call    fn6
    test    byte ptr [rsp+203Fh],0FFh
    jne     L10
    nop     [rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L7:
    add     rsp,2078h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L9:
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L10:
    lea     rax,[rsp+1000h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn7
    jmp     L6
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L12:
    lea     rax,[rsp+1000h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn8
    jmp     L8
    nop     [rax+rax]
    nop
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L14:
    test    byte ptr [rsp+203Fh],0FFh
    je      L8
    jmp     L11
L15:
    mov     rdi,[rsp+2008h]
    mov     rsi,[rsp+2000h]
    call    fn9
    mov     [rsp+2010h],rax
    mov     qword ptr [rsp+10h],30h
    mov     rdi,[rsp+2010h]
    mov     rsi,[rsp+10h]
    call    fn10
    mov     [rsp+2018h],rax
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDFA8h
    lea     rdx,[k11]
    mov     ecx,1
    call    ryo_h_Const
    lea     rax,[rsp+18h]
    mov     [rsp+10h],rax
    lea     rax,[rax+1]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],1
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+2]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],2
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+4]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],4
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+8]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],8
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+10h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],10h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+20h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],20h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+40h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],40h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+80h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],80h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+100h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],100h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+200h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],200h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+400h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],400h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    mov     rax,[rsp+10h]
    lea     rax,[rax+800h]
    mov     [rsp+8],rax
    mov     qword ptr [rsp],800h
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFDF98h
    mov     edx,0FFFFDFA0h
    mov     ecx,0FFFFDF90h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+2070h]
    mov     esi,0FFFFEFA8h
    mov     edx,0FFFFDFA8h
    mov     ecx,1000h
    call    ryo_h_Copy
    lea     rax,[rsp+1018h]
    mov     [rsp+1010h],rax
    mov     rdi,[rsp+1010h]
    call    fn12
    mov     [rsp+2040h],rax
    mov     [rsp+2048h],rdx
    jmp     L2
    nop     [rax+rax]
    xchg    ax,ax
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L17:
    call    qword ptr [sym13]
    ud2
    lea     rdi,[rsp+2070h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L13
    lea     rdi,[rsp+2070h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L16
L18:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L19:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L20:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L21:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L22:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L23:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_down::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L33
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+80h],rcx
    mov     [rsp+78h],r8
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L2:
    mov     rax,[rsp+98h]
    mov     rax,[rax+10h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L4:
    test    byte ptr [rsp+4Fh],0FFh
    je      L5
    mov     rdx,[rsp+70h]
    mov     [rsp+60h],rdx
    jmp     L6
L5:
    mov     rax,[rsp+68h]
    mov     [rsp+60h],rax
L6:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L25
    jmp     L24
    nop     [rax+rax]
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L8:
    mov     rax,[rsp+98h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+88h]
    jne     L11
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L10:
    add     rsp,0A8h
    ret
L11:
    jmp     L1
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L13:
    mov     rax,[rsp+98h]
    mov     rax,[rax+8]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L19
    jmp     L18
L14:
    mov     rax,[rsp+48h]
    mov     [rsp+70h],rax
    jmp     L12
L15:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+70h],rdx
    jmp     L12
    nop     [rax+rax]
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L17:
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L23
    jmp     L22
L18:
    mov     rax,[rsp+48h]
    mov     [rsp+68h],rax
    jmp     L16
L19:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+68h],rdx
    jmp     L16
    nop     [rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L21:
    mov     rax,[rsp+48h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+38h],rdx
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+4Fh],al
    jmp     L3
L22:
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    jmp     L20
L23:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+80h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    jmp     L20
L24:
    mov     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k1]
    mov     [rsp+8],r9
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L25:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+40h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+38h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    movzx   r8d,byte ptr [rsp+4Fh]
    xor     r8b,1
    mov     [rsp+4Eh],r8b
    movzx   r9d,byte ptr [rsp+4Eh]
    mov     r10,[rsp+70h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+40h],r10
    mov     r11,[rsp+98h]
    mov     rcx,[rsp+40h]
    mov     [r11+10h],rcx
    movzx   eax,byte ptr [rsp+4Fh]
    mov     rdx,[rsp+68h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+98h]
    mov     rcx,[rsp+40h]
    mov     [rsi+8],rcx
    mov     rdi,[rsp+98h]
    mov     rdi,[rdi+10h]
    mov     [rsp+58h],rdi
    cmp     rdi,[rsp+90h]
    je      L9
    jmp     L7
L26:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L27:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L28:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L29:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L30:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L31:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L17
L32:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L21
L33:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_up::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+80h],rcx
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L2:
    mov     rax,[rsp+98h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+8]
    mov     [rsp+38h],rdx
    cmp     rax,rdx
    je      L5
    mov     rsi,[rsp+90h]
    mov     [rsp+68h],rsi
    cmp     rsi,[rsp+88h]
    je      L5
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+98h]
    mov     r8,[r8]
    mov     [rsp+38h],rdi
    mov     [rsp+40h],r8
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+67h],al
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+4Dh],al
    test    byte ptr [rsp+4Dh],0FFh
    je      L3
    mov     rsi,[rsp+98h]
    mov     rsi,[rsi]
    mov     [rsp+58h],rsi
    jmp     L4
L3:
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
L4:
    mov     rax,[rsp+98h]
    mov     rax,[rax+10h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L7
    jmp     L6
L5:
    add     rsp,0A8h
    ret
L6:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+30h],rdx
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k1]
    mov     [rsp+8],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn2
L7:
    mov     rax,[rsp+58h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+58h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    mov     r8,[rsp+98h]
    mov     r8,[r8]
    movzx   r9d,byte ptr [rsp+4Dh]
    imul    rcx,r9,8
    add     r8,rcx
    mov     [rsp+40h],r8
    mov     r10,[rsp+98h]
    mov     rcx,[rsp+40h]
    mov     [r10],rcx
    movzx   r11d,byte ptr [rsp+67h]
    mov     rax,[rsp+90h]
    imul    rcx,r11,8
    add     rax,rcx
    mov     [rsp+90h],rax
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+10h]
    mov     qword ptr [rsp+20h],1
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+98h]
    mov     rcx,[rsp+40h]
    mov     [rdi+10h],rcx
    jmp     L1
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::merge::merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L28
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    mov     [rsp+0D8h],rsi
    mov     [rsp+0C0h],rdx
    mov     [rsp+0C8h],rcx
    mov     [rsp+0B8h],r8
    mov     [rsp+0B0h],r9
    mov     rax,[rsp+0D8h]
    mov     [rsp+68h],rax
    cmp     qword ptr [rsp+0B8h],0
    je      L1
    mov     rsi,[rsp+0B8h]
    cmp     rsi,rax
    jae     L1
    mov     rdi,[rsp+0C8h]
    mov     [rsp+58h],rdi
    sub     rax,rsi
    mov     [rsp+0A8h],rax
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A8h]
    call    fn0
    mov     [rsp+50h],rax
    jmp     L17
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L2:
    jmp     L14
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L4:
    mov     rax,[rsp+0C0h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+0D0h]
    mov     [rsp+78h],rdi
    mov     r8,[rsp+0D8h]
    mov     [rsp+80h],r8
    mov     [rsp+0A0h],rdi
    imul    rcx,[rsp+0B8h],8
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     r9,[rsp+0A0h]
    imul    rcx,[rsp+68h],8
    add     r9,rcx
    mov     [rsp+50h],r9
    mov     r10,[rsp+0B8h]
    cmp     r10,[rsp+0A8h]
    setbe   [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L5
    jmp     L6
L5:
    mov     rax,[rsp+58h]
    mov     [rsp+0A0h],rax
L6:
    test    byte ptr [rsp+4Fh],0FFh
    je      L7
    jmp     L8
L7:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0B8h],rax
L8:
    mov     rax,[rsp+0A0h]
    mov     [rsp+98h],rax
    mov     [rsp+40h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L10:
    lea     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+0B0h]
    call    fn1
    jmp     L13
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L12:
    lea     rax,[rsp+30h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+50h]
    mov     r8,[rsp+0B0h]
    call    fn2
L13:
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn3
L14:
    add     rsp,0E8h
    ret
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L16:
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn4
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF90h
    call    ryo_h_Resume
    ud2
L17:
    mov     rax,[rsp+58h]
    cmp     rax,[rsp+50h]
    jb      L1
    jmp     L3
L18:
    mov     rax,[rsp+98h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+8],4
    lea     r8,[k5]
    mov     [rsp],r8
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp+38h]
    mov     r9,[rsp]
    call    fn6
L19:
    imul    rax,[rsp+38h],8
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF60h
    mov     ecx,0FFFFFF30h
    call    ryo_h_Memcpy
    mov     rax,[rsp+60h]
    imul    rcx,[rsp+0B8h],8
    add     rax,rcx
    mov     rdx,[rsp+60h]
    mov     [rsp+30h],rdx
    mov     [rsp+38h],rax
    mov     rsi,[rsp+0A0h]
    mov     [rsp+40h],rsi
    test    byte ptr [rsp+4Fh],0FFh
    je      L11
    jmp     L9
    nop     [rax+rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L21:
    call    qword ptr [sym7]
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF90h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFF90h
    call    ryo_h_Lpad
    jmp     L20
L22:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L23:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L24:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L10
L25:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L26:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L16
L27:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L21
L28:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+4Fh],sil
    mov     rax,[rsp+50h]
    mov     rax,[rax+18h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L9
    jmp     L8
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L2:
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    jmp     L5
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L4:
    mov     rax,[rsp+50h]
    mov     rax,[rax+18h]
    mov     [rsp+40h],rax
L5:
    mov     rax,[rsp+50h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+40h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+50h]
    mov     rsi,[rsi+8]
    mov     [rsp+38h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    xchg    ax,ax
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L7:
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+38h]
    mov     [rax+18h],rcx
    test    byte ptr [rsp+4Fh],0FFh
    je      L3
    jmp     L1
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+38h],rax
    jmp     L6
L9:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+30h]
    imul    rcx,[rsp+20h],8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    jmp     L6
L10:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rdx
    mov     qword ptr [rsp+20h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k0]
    mov     [rsp+8],r9
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn1
L11:
    mov     rax,[rsp+38h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+58h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+58h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    movzx   r8d,byte ptr [rsp+4Fh]
    mov     r9,[rsp+50h]
    mov     r9,[r9+10h]
    add     r9,r8
    mov     [rsp+10h],r9
    mov     r10,[rsp+50h]
    mov     rcx,[rsp+10h]
    mov     [r10+10h],rcx
    mov     r11,[rsp+50h]
    mov     r11,[r11+8]
    mov     qword ptr [rsp+20h],1
    imul    rcx,[rsp+20h],8
    add     r11,rcx
    mov     [rsp+38h],r11
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+38h]
    mov     [rdx+8],rcx
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L12:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L13:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L14:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L28
L0:
    sub     rsp,128h
    mov     [rsp+110h],rdi
    mov     [rsp+118h],rsi
    mov     [rsp+100h],rdx
    mov     [rsp+108h],rcx
    mov     [rsp+0FCh],r8d
    mov     [rsp+0F0h],r9
    mov     rax,[rsp+130h]
    mov     [rsp+0E8h],rax
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L2:
    mov     rax,[rsp+110h]
    mov     rdx,[rsp+118h]
    mov     [rsp+70h],rdx
    call    fn0
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    cmp     rax,[rsp+70h]
    jb      L3
    mov     rdi,[rsp+110h]
    mov     rsi,[rsp+118h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     r8,[rsp+0E8h]
    call    fn1
    jmp     L15
L3:
    mov     eax,[rsp+0FCh]
    mov     [rsp+78h],eax
    cmp     eax,0
    jne     L4
    mov     byte ptr [rsp+17h],1
    mov     rdi,[rsp+110h]
    mov     rsi,[rsp+118h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+108h]
    movzx   r8d,byte ptr [rsp+17h]
    mov     r9,[rsp+0E8h]
    call    fn2
    jmp     L5
L4:
    mov     eax,[rsp+0FCh]
    sub     eax,1
    mov     [rsp+0FCh],eax
    mov     rdx,[rsp+110h]
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+118h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+0E8h]
    call    fn3
    mov     [rsp+68h],rax
    jmp     L6
L5:
    jmp     L15
L6:
    mov     rax,[rsp+110h]
    mov     rdx,[rsp+118h]
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+68h]
    cmp     rsi,rdx
    jb      L7
    lea     rdi,[k4]
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+0D0h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym5]
    ud2
L7:
    mov     rax,[rsp+110h]
    imul    rcx,[rsp+68h],8
    add     rax,rcx
    mov     rax,[rax]
    mov     [rsp+60h],rax
    call    fn6
    mov     [rsp+7Fh],al
    jmp     L16
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L9:
    mov     rax,[rsp+0F0h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+110h]
    mov     rsi,[rsp+118h]
    mov     [rsp+90h],rsi
    mov     rdi,[rsp+68h]
    cmp     rdi,rsi
    jb      L10
    lea     r8,[k7]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym8]
    ud2
L10:
    mov     rax,[rsp+110h]
    imul    rcx,[rsp+68h],8
    add     rax,rcx
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     [rsp+50h],rax
    mov     rdi,[rsp+0E8h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    call    fn9
    mov     [rsp+7Eh],al
    movzx   eax,byte ptr [rsp+7Eh]
    xor     al,1
    mov     [rsp+0B7h],al
    mov     qword ptr [rsp+80h],0
    movzx   esi,byte ptr [rsp+0B7h]
    mov     [rsp+7Eh],sil
    test    byte ptr [rsp+7Eh],0FFh
    jne     L13
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L12:
    mov     rax,[rsp+110h]
    mov     rcx,[rsp+118h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    mov     rsi,[rsp+0E8h]
    mov     [rsp],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     r8,[rsp+68h]
    movzx   r9d,byte ptr [rsp+17h]
    call    fn10
    mov     [rsp+80h],rax
    mov     rax,[rsp+80h]
    cmp     rax,0
    sete    [rsp+0B7h]
L13:
    test    byte ptr [rsp+0B7h],0FFh
    je      L14
    mov     rdx,[rsp+110h]
    mov     rcx,[rsp+118h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+0E8h]
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+38h]
    mov     [rsp+40h],rdi
    mov     byte ptr [rsp+17h],1
    mov     [rsp],rdi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     r8,[rsp+68h]
    movzx   r9d,byte ptr [rsp+17h]
    call    fn11
    mov     [rsp+58h],rax
    mov     rax,[rsp+118h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+58h]
    jb      L21
    jmp     L22
L14:
    lea     rax,[k12]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+110h]
    mov     rdx,[rsp+118h]
    mov     rcx,[rsp+80h]
    mov     r8,[rsp+10h]
    call    fn13
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+118h],rcx
    mov     [rsp+110h],rax
    mov     rdx,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rdx
    mov     esi,[rsp+0FCh]
    mov     [rsp+78h],esi
    mov     rdi,[rsp+0E8h]
    mov     [rsp],rdi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     r8d,[rsp+78h]
    mov     r9,[rsp+0C0h]
    call    fn14
    jmp     L1
L15:
    add     rsp,128h
    ret
L16:
    lea     rax,[rsp+60h]
    mov     [rsp+58h],rax
    test    byte ptr [rsp+7Fh],0FFh
    je      L20
    jmp     L19
    nop     [rax+rax]
    nop
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L18:
    mov     byte ptr [rsp+0B7h],0
    cmp     qword ptr [rsp+0F0h],0
    je      L23
    jmp     L8
L19:
    mov     rax,[rsp+58h]
    mov     [rsp+0C0h],rax
    jmp     L17
L20:
    mov     qword ptr [rsp+0C0h],0
    jmp     L17
L21:
    lea     rax,[k15]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym16]
    ud2
L22:
    mov     rax,[rsp+50h]
    sub     rax,[rsp+58h]
    mov     rdx,[rsp+110h]
    mov     rsi,[rsp+118h]
    imul    rcx,[rsp+58h],8
    add     rdx,rcx
    mov     [rsp+110h],rdx
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+0F0h],0
    jmp     L1
    ud2
L23:
    mov     qword ptr [rsp+80h],0
    jmp     L11
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L9
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L12
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L18
L28:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+20h]
    mov     [rsp],rdx
    mov     rsi,[rsp+28h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn0
    mov     [rsp+17h],al
    movzx   eax,byte ptr [rsp+17h]
    xor     al,1
    mov     [rsp+3Fh],al
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L36
L0:
    sub     rsp,178h
    mov     [rsp+158h],rdi
    mov     [rsp+160h],rsi
    mov     [rsp+148h],rdx
    mov     [rsp+150h],rcx
    mov     [rsp+140h],r8
    mov     [rsp+13Fh],r9b
    mov     rax,[rsp+180h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+160h]
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+150h]
    mov     [rsp+98h],rsi
    cmp     rsi,rdx
    jae     L1
    mov     byte ptr [rsp+0A7h],1
    jmp     L17
L1:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+140h]
    setbe   [rsp+0A7h]
    test    byte ptr [rsp+0A7h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L3:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L6
    mov     rsi,[rsp+140h]
    mov     [rsp+58h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+28h],3
    mov     r8,[rsp+28h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L19
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L5:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+68h]
    jae     L6
    lea     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn1
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn2
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn3
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn4
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn5
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn6
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn7
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn8
    mov     [rsp+58h],rax
    jmp     L4
L6:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+0A0h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+68h],rdx
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+68h]
    jae     L9
    lea     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn9
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn10
    mov     [rsp+58h],rax
    jmp     L7
L9:
    mov     rax,[rsp+140h]
    cmp     rax,[rsp+0A8h]
    jne     L10
    call    fn11
    mov     [rsp+6Eh],al
    jmp     L20
L10:
    lea     rax,[rsp+70h]
    mov     [rsp+60h],rax
    mov     rdi,[rsp+60h]
    movzx   esi,byte ptr [rsp+13Fh]
    call    fn12
    mov     [rsp+128h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+140h],rax
    jmp     L2
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L12:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L14:
    mov     rax,[rsp+158h]
    mov     [rsp+0C0h],rax
    mov     rdx,[rsp+160h]
    mov     [rsp+0C8h],rdx
    mov     [rsp+68h],rax
    mov     rsi,[rsp+0D0h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+58h],rdi
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L24
    jmp     L23
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L16:
    mov     rax,[rsp+118h]
    mov     rdx,[rsp+120h]
    cmp     rax,rdx
    setb    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    je      L26
    jmp     L25
L17:
    lea     rdi,[rsp+170h]
    call    ryo_h_Abort
    ud2
L18:
    mov     rax,[rsp+158h]
    mov     rdx,[rsp+160h]
    mov     [rsp+0A0h],rax
    mov     rsi,[rsp+148h]
    mov     [rsp+0D0h],rsi
    mov     rdi,[rsp+150h]
    mov     [rsp+0D8h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp+98h],r8
    imul    rcx,[rsp+140h],8
    add     rax,rcx
    mov     [rsp+90h],rax
    imul    rcx,[rsp+0A8h],8
    add     r8,rcx
    mov     r9,[rsp+98h]
    mov     [rsp+70h],r9
    mov     r10,[rsp+0A0h]
    mov     [rsp+78h],r10
    mov     qword ptr [rsp+80h],0
    mov     [rsp+88h],r8
    mov     qword ptr [rsp+128h],0
    jmp     L2
L19:
    mov     rax,[rsp+0A0h]
    imul    rcx,[rsp+60h],8
    add     rax,rcx
    mov     [rsp+68h],rax
    jmp     L4
L20:
    movzx   eax,byte ptr [rsp+6Eh]
    xor     al,1
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L13
    jmp     L11
L21:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+128h]
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],1
    lea     r9,[k13]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
    call    fn14
L22:
    mov     rax,[rsp+90h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+90h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+128h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+128h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    jmp     L13
L23:
    mov     rax,[rsp+0D0h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    lea     r8,[k15]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+58h]
    mov     r9,[rsp+18h]
    call    fn16
L24:
    imul    rax,[rsp+58h],8
    mov     [rsp+28h],rax
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFEF0h
    mov     ecx,0FFFFFEB8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+0A8h]
    sub     rdx,rax
    mov     qword ptr [rsp+118h],0
    mov     [rsp+120h],rdx
    jmp     L15
L25:
    mov     rax,[rsp+118h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L28
    jmp     L27
L26:
    mov     rax,[rsp+80h]
    mov     [rsp+168h],rax
    mov     rax,[rsp+168h]
    add     rsp,178h
    ret
L27:
    mov     qword ptr [rsp+28h],1
    lea     rdx,[k17]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    call    fn18
L28:
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+118h],rax
    mov     rdx,[rsp+48h]
    mov     qword ptr [rsp+58h],1
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A8h]
    sub     rdi,1
    sub     rdi,rdx
    mov     r8,[rsp+98h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+108h],r8
    mov     [rsp+48h],r8
    mov     r9,[rsp+80h]
    add     r9,rdx
    mov     r10,[rsp+68h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+40h],r10
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L29
    mov     rdi,[rsp+108h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],r10
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],1
    lea     r9,[k19]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
    call    fn20
L29:
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    jmp     L15
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L16
L36:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L36
L0:
    sub     rsp,178h
    mov     [rsp+158h],rdi
    mov     [rsp+160h],rsi
    mov     [rsp+148h],rdx
    mov     [rsp+150h],rcx
    mov     [rsp+140h],r8
    mov     [rsp+13Fh],r9b
    mov     rax,[rsp+180h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+160h]
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+150h]
    mov     [rsp+98h],rsi
    cmp     rsi,rdx
    jae     L1
    mov     byte ptr [rsp+0A7h],1
    jmp     L17
L1:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+140h]
    setbe   [rsp+0A7h]
    test    byte ptr [rsp+0A7h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L3:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L6
    mov     rsi,[rsp+140h]
    mov     [rsp+58h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+28h],3
    mov     r8,[rsp+28h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L19
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L5:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+68h]
    jae     L6
    lea     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn1
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn2
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn3
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn4
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn5
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn6
    mov     [rsp+58h],rax
    lea     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn7
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn8
    mov     [rsp+58h],rax
    jmp     L4
L6:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+0A0h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+68h],rdx
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    cmp     rax,[rsp+68h]
    jae     L9
    lea     rdx,[rsp+70h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp+48h],rdi
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn9
    mov     [rsp+66h],al
    mov     rdi,[rsp+50h]
    movzx   esi,byte ptr [rsp+66h]
    call    fn10
    mov     [rsp+58h],rax
    jmp     L7
L9:
    mov     rax,[rsp+140h]
    cmp     rax,[rsp+0A8h]
    jne     L10
    call    fn11
    mov     [rsp+6Eh],al
    jmp     L20
L10:
    lea     rax,[rsp+70h]
    mov     [rsp+60h],rax
    mov     rdi,[rsp+60h]
    movzx   esi,byte ptr [rsp+13Fh]
    call    fn12
    mov     [rsp+128h],rax
    mov     rax,[rsp+0A8h]
    mov     [rsp+140h],rax
    jmp     L2
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L12:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L22
    jmp     L21
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L14:
    mov     rax,[rsp+158h]
    mov     [rsp+0C0h],rax
    mov     rdx,[rsp+160h]
    mov     [rsp+0C8h],rdx
    mov     [rsp+68h],rax
    mov     rsi,[rsp+0D0h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+58h],rdi
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L24
    jmp     L23
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L16:
    mov     rax,[rsp+118h]
    mov     rdx,[rsp+120h]
    cmp     rax,rdx
    setb    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    je      L26
    jmp     L25
L17:
    lea     rdi,[rsp+170h]
    call    ryo_h_Abort
    ud2
L18:
    mov     rax,[rsp+158h]
    mov     rdx,[rsp+160h]
    mov     [rsp+0A0h],rax
    mov     rsi,[rsp+148h]
    mov     [rsp+0D0h],rsi
    mov     rdi,[rsp+150h]
    mov     [rsp+0D8h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp+98h],r8
    imul    rcx,[rsp+140h],8
    add     rax,rcx
    mov     [rsp+90h],rax
    imul    rcx,[rsp+0A8h],8
    add     r8,rcx
    mov     r9,[rsp+98h]
    mov     [rsp+70h],r9
    mov     r10,[rsp+0A0h]
    mov     [rsp+78h],r10
    mov     qword ptr [rsp+80h],0
    mov     [rsp+88h],r8
    mov     qword ptr [rsp+128h],0
    jmp     L2
L19:
    mov     rax,[rsp+0A0h]
    imul    rcx,[rsp+60h],8
    add     rax,rcx
    mov     [rsp+68h],rax
    jmp     L4
L20:
    movzx   eax,byte ptr [rsp+6Eh]
    xor     al,1
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L13
    jmp     L11
L21:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+128h]
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],1
    lea     r9,[k13]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
    call    fn14
L22:
    mov     rax,[rsp+90h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+90h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+128h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+128h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    jmp     L13
L23:
    mov     rax,[rsp+0D0h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    lea     r8,[k15]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+58h]
    mov     r9,[rsp+18h]
    call    fn16
L24:
    imul    rax,[rsp+58h],8
    mov     [rsp+28h],rax
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFEF0h
    mov     ecx,0FFFFFEB8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+0A8h]
    sub     rdx,rax
    mov     qword ptr [rsp+118h],0
    mov     [rsp+120h],rdx
    jmp     L15
L25:
    mov     rax,[rsp+118h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L28
    jmp     L27
L26:
    mov     rax,[rsp+80h]
    mov     [rsp+168h],rax
    mov     rax,[rsp+168h]
    add     rsp,178h
    ret
L27:
    mov     qword ptr [rsp+28h],1
    lea     rdx,[k17]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    call    fn18
L28:
    mov     rax,[rsp+48h]
    add     rax,1
    mov     [rsp+118h],rax
    mov     rdx,[rsp+48h]
    mov     qword ptr [rsp+58h],1
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A8h]
    sub     rdi,1
    sub     rdi,rdx
    mov     r8,[rsp+98h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+108h],r8
    mov     [rsp+48h],r8
    mov     r9,[rsp+80h]
    add     r9,rdx
    mov     r10,[rsp+68h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+40h],r10
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L29
    mov     rdi,[rsp+108h]
    mov     [rsp+38h],rdi
    mov     [rsp+30h],r10
    mov     qword ptr [rsp+28h],8
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],1
    lea     r9,[k19]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+20h]
    mov     r8,[rsp+18h]
    mov     r9,[rsp+10h]
    call    fn20
L29:
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     edx,[rdx+4]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+40h]
    mov     ecx,[rsp+20h]
    mov     [rsi],ecx
    mov     rdi,[rsp+40h]
    mov     ecx,[rsp+24h]
    mov     [rdi+4],ecx
    jmp     L15
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L12
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L14
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L16
L36:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::heapsort::heapsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L34
L0:
    sub     rsp,0D8h
    mov     [rsp+0C0h],rdi
    mov     [rsp+0C8h],rsi
    mov     [rsp+0B8h],rdx
    mov     rax,[rsp+0C8h]
    mov     [rsp+70h],rax
    shr     rax,1
    mov     rdx,[rsp+70h]
    add     rdx,rax
    mov     qword ptr [rsp+60h],0
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+0B0h],rcx
    mov     [rsp+0A8h],rdi
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L2:
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0B0h]
    cmp     rax,rdx
    setb    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L4:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+70h]
    mov     [rsp+98h],rax
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L6:
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+10h]
    cmp     rdx,[rsp+70h]
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    jne     L17
    mov     qword ptr [rsp+10h],0
    lea     r8,[k0]
    mov     [rsp+8],r8
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym1]
    ud2
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L8:
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+70h]
    call    fn2
    mov     [rsp+90h],rax
    jmp     L19
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L10:
    jmp     L1
L11:
    mov     rax,[rsp+0B0h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L14
    jmp     L13
L12:
    add     rsp,0D8h
    ret
L13:
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k3]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn4
L14:
    mov     rax,[rsp+48h]
    sub     rax,1
    mov     [rsp+0B0h],rax
    mov     qword ptr [rsp+60h],1
    mov     [rsp+58h],rax
    cmp     rax,[rsp+70h]
    jae     L3
    jmp     L5
    nop     [rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L16:
    mov     qword ptr [rsp+98h],0
    jmp     L7
L17:
    mov     rax,[rsp+58h]
    cmp     rax,[rsp+70h]
    jb      L18
    lea     rdx,[k5]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym6]
    ud2
L18:
    mov     qword ptr [rsp+10h],0
    lea     rdx,[k7]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+0C0h]
    mov     rsi,[rsp+0C8h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+58h]
    mov     r8,[rsp+8]
    call    fn8
    jmp     L15
L19:
    cmp     qword ptr [rsp+90h],0
    jb      L24
    jmp     L25
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L21:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     rsi,[rsp+90h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+98h]
    mov     rcx,[rsp+0B8h]
    call    fn9
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L23:
    mov     qword ptr [rsp+10h],0
    lea     rdx,[k10]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym11]
    ud2
L24:
    jmp     L22
L25:
    mov     rax,[rsp+70h]
    cmp     rax,[rsp+90h]
    jae     L20
    jmp     L22
L26:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L27:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L28:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L29:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L30:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L31:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L16
L32:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L21
L33:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L23
L34:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::heapsort::sift_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,0B8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],rsi
    mov     [rsp+98h],rdx
    mov     [rsp+90h],rcx
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0A8h]
    mov     [rsp+88h],rdx
    cmp     rax,rdx
    setbe   [rsp+7Fh]
    mov     rsi,[rsp+0A0h]
    mov     rdi,[rsp+0A8h]
    mov     [rsp+78h],rsi
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L2:
    mov     rax,[rsp+98h]
    mov     qword ptr [rsp+20h],2
    mov     rsi,[rsp+20h]
    imul    rsi,rax
    add     rsi,1
    mov     [rsp+80h],rsi
    mov     [rsp+68h],rsi
    cmp     rsi,[rsp+88h]
    jb      L3
    jmp     L7
L3:
    mov     rax,[rsp+80h]
    add     rax,1
    mov     [rsp+68h],rax
    cmp     rax,[rsp+88h]
    jae     L4
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+78h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     rdi,[rsp+80h]
    add     rdi,1
    mov     r8,[rsp+78h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],r8
    mov     rdi,[rsp+90h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    call    fn0
    mov     [rsp+76h],al
    jmp     L5
L4:
    jmp     L6
L5:
    movzx   eax,byte ptr [rsp+76h]
    mov     rdx,[rsp+80h]
    add     rdx,rax
    mov     [rsp+80h],rdx
L6:
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+78h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+80h]
    mov     rdi,[rsp+78h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rdi
    mov     rdi,[rsp+90h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+68h]
    call    fn1
    mov     [rsp+77h],al
    test    byte ptr [rsp+77h],0FFh
    je      L7
    mov     rdx,[rsp+78h]
    imul    rcx,[rsp+98h],4
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+80h]
    mov     rdi,[rsp+78h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+68h],rdi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L9
    jmp     L8
L7:
    add     rsp,0B8h
    ret
L8:
    mov     rax,[rsp+70h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k2]
    mov     [rsp+8],r9
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn3
L9:
    mov     rax,[rsp+70h]
    mov     qword ptr [rsp+60h],1
    mov     rcx,[rsp+60h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    imul    rsi,[rsp+48h],4
    mov     [rsp+50h],rsi
    jmp     L14
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L11:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+40h]
    call    fn4
    jmp     L12
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L13:
    mov     rax,[rsp+80h]
    mov     [rsp+98h],rax
    jmp     L1
L14:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L12
    jmp     L10
    ud2
L15:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L16:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L11
L17:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L13
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::ipnsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+68h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+58h]
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],dl
    mov     rax,[rsp+30h]
    mov     [rsp+40h],rax
    movzx   edx,byte ptr [rsp+38h]
    mov     [rsp+53h],dl
    cmp     rax,[rsp+48h]
    setbe   [rsp+52h]
    cmp     rax,[rsp+48h]
    jne     L2
    test    byte ptr [rsp+53h],0FFh
    je      L1
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    call    fn1
L1:
    jmp     L3
L2:
    mov     rax,[rsp+48h]
    or      rax,1
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L5
    jmp     L6
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    add     rsp,78h
    ret
    ud2
L5:
    lea     rax,[k2]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    qword ptr [sym3]
    ud2
L6:
    mov     rax,[rsp+28h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF9Ch
    mov     edx,0FFFFFFA0h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+0Ch]
    mov     [rsp+38h],eax
    mov     dword ptr [rsp+0Ch],3Fh
    mov     esi,[rsp+0Ch]
    sub     esi,eax
    mov     dword ptr [rsp+0Ch],2
    mov     r8d,[rsp+0Ch]
    imul    r8d,esi
    mov     [rsp+3Ch],r8d
    mov     qword ptr [rsp+8],0
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+8]
    mov     ecx,[rsp+3Ch]
    mov     r8,[rsp+58h]
    call    fn4
    jmp     L3
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+68h],rcx
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    cmp     rax,0
    jne     L1
    mov     qword ptr [rsp+88h],0
    jmp     L5
L1:
    mov     rax,[rsp+70h]
    cmp     rax,[rsp+50h]
    jb      L2
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L2:
    mov     qword ptr [rsp+8],0
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+70h]
    mov     r8,[rsp]
    call    fn1
    mov     qword ptr [rsp+8],1
    lea     rdx,[k2]
    mov     [rsp],rdx
    lea     rdi,[rsp+10h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp]
    call    fn3
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+48h]
    mov     [rsp+60h],rsi
    mov     qword ptr [rsp+8],0
    mov     r8,[rsp+8]
    cmp     r8,rsi
    setb    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    jne     L3
    mov     qword ptr [rsp+8],0
    lea     r11,[k4]
    mov     [rsp],r11
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp]
    call    qword ptr [sym5]
    ud2
L3:
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdx,[sym6]
    mov     [rsp+8],rdx
    mov     rax,[rsp+8]
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+68h]
    call    rax
    mov     [rsp+88h],rax
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+50h]
    jb      L4
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L4:
    mov     qword ptr [rsp+8],0
    lea     rdx,[k7]
    mov     [rsp],rdx
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp]
    call    fn8
L5:
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,98h
    mov     [rsp+78h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+70h],rdx
    mov     [rsp+68h],rcx
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    cmp     rax,0
    jne     L1
    mov     qword ptr [rsp+88h],0
    jmp     L5
L1:
    mov     rax,[rsp+70h]
    cmp     rax,[rsp+50h]
    jb      L2
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L2:
    mov     qword ptr [rsp+8],0
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+70h]
    mov     r8,[rsp]
    call    fn1
    mov     qword ptr [rsp+8],1
    lea     rdx,[k2]
    mov     [rsp],rdx
    lea     rdi,[rsp+10h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+8]
    mov     r8,[rsp]
    call    fn3
    mov     rax,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+48h]
    mov     [rsp+60h],rsi
    mov     qword ptr [rsp+8],0
    mov     r8,[rsp+8]
    cmp     r8,rsi
    setb    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    jne     L3
    mov     qword ptr [rsp+8],0
    lea     r11,[k4]
    mov     [rsp],r11
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp]
    call    qword ptr [sym5]
    ud2
L3:
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdx,[sym6]
    mov     [rsp+8],rdx
    mov     rax,[rsp+8]
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+68h]
    call    rax
    mov     [rsp+88h],rax
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+50h]
    jb      L4
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L4:
    mov     qword ptr [rsp+8],0
    lea     rdx,[k7]
    mov     [rsp],rdx
    mov     rdi,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+88h]
    mov     r8,[rsp]
    call    fn8
L5:
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0C0h],rsi
    mov     [rsp+0B0h],rdx
    mov     [rsp+0A8h],rcx
    mov     rax,[rsp+0C0h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+98h],rsi
    mov     [rsp+78h],rdx
    cmp     rax,0
    jne     L1
    mov     qword ptr [rsp+0C8h],0
    jmp     L12
L1:
    lea     rax,[rsp+78h]
    mov     rdx,[rsp+0A8h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rax
    mov     rdi,[rsp+90h]
    mov     edi,[rdi]
    mov     [rsp+5Ch],edi
    mov     qword ptr [rsp+8],1
    mov     r9,[rsp+78h]
    imul    rcx,[rsp+8],4
    add     r9,rcx
    lea     r10,[rsp+5Ch]
    mov     r11,[rsp+78h]
    mov     [rsp+28h],r10
    mov     [rsp+48h],r9
    mov     qword ptr [rsp+50h],0
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rcx
    mov     [rsp+38h],r11
    mov     qword ptr [rsp+8],2
    mov     r8,[rsp+8]
    sub     r8,1
    mov     rdx,[rsp+80h]
    sub     rdx,r8
    mov     r10,[rsp+78h]
    imul    rcx,rdx,4
    add     r10,rcx
    mov     [rsp+30h],r10
    nop     [rax+rax]
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    cmp     rax,[rsp+30h]
    jae     L6
    mov     qword ptr [rsp+8],2
    cmp     qword ptr [rsp+8],2
    sete    [rsp+5Ah]
    test    byte ptr [rsp+5Ah],0FFh
    je      L4
    lea     r8,[rsp+60h]
    mov     [rsp+28h],r8
    lea     r9,[rsp+38h]
    mov     [rsp+20h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn0
    lea     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn1
    jmp     L5
L4:
    lea     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn2
L5:
    jmp     L2
L6:
    mov     rax,[rsp+78h]
    imul    rcx,[rsp+80h],4
    add     rax,rcx
    mov     [rsp+28h],rax
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L8:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+28h]
    sete    [rsp+5Bh]
    test    byte ptr [rsp+5Bh],0FFh
    je      L9
    mov     rsi,[rsp+40h]
    mov     [rsp+20h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+60h]
    mov     [rsp+20h],rdx
    lea     rsi,[rsp+38h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    fn3
    test    byte ptr [rsp+5Bh],0FFh
    je      L11
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+50h]
    mov     [rsp+0C8h],rdi
    jmp     L12
L11:
    jmp     L7
L12:
    mov     rax,[rsp+0C8h]
    add     rsp,0D8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L14:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L16:
    lea     rax,[rsp+38h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn4
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L18:
    call    qword ptr [sym5]
    ud2
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L17
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L14
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L16
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L18
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     rax,[rsp+88h]
    mov     rax,[rax]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx+10h]
    mov     rsi,[rsp+88h]
    mov     rsi,[rsi+8]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn0
    mov     [rsp+57h],al
    mov     rax,[rsp+88h]
    mov     rax,[rax+10h]
    mov     rax,[rax]
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx+18h]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi]
    mov     [rsp+38h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L6
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rax,[rsp+80h]
    mov     rax,[rax+10h]
    mov     [rsp+78h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L8
    jmp     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L4
    mov     byte ptr [rsp+56h],1
    jmp     L5
L4:
    mov     byte ptr [rsp+56h],0
L5:
    mov     qword ptr [rsp+20h],4
    lea     rdx,[k1]
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    movzx   ecx,byte ptr [rsp+56h]
    mov     r8,[rsp+18h]
    call    fn2
L6:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    jmp     L1
L7:
    mov     rax,[rsp+78h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k3]
    mov     [rsp+8],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn4
L8:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi+10h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+80h]
    mov     rcx,[rsp+40h]
    mov     [rdi],rcx
    movzx   r8d,byte ptr [rsp+57h]
    mov     r9,[rsp+80h]
    mov     r9,[r9+18h]
    add     r9,r8
    mov     [rsp+10h],r9
    mov     r10,[rsp+80h]
    mov     rcx,[rsp+10h]
    mov     [r10+18h],rcx
    mov     r11,[rsp+80h]
    mov     r11,[r11+10h]
    mov     qword ptr [rsp+20h],1
    imul    rcx,[rsp+20h],4
    add     r11,rcx
    mov     [rsp+40h],r11
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+40h]
    mov     [rdx+10h],rcx
    add     rsp,98h
    ret
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L24
L0:
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0C0h],rsi
    mov     [rsp+0B0h],rdx
    mov     [rsp+0A8h],rcx
    mov     rax,[rsp+0C0h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+98h],rsi
    mov     [rsp+78h],rdx
    cmp     rax,0
    jne     L1
    mov     qword ptr [rsp+0C8h],0
    jmp     L12
L1:
    lea     rax,[rsp+78h]
    mov     rdx,[rsp+0A8h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rax
    mov     rdi,[rsp+90h]
    mov     edi,[rdi]
    mov     [rsp+5Ch],edi
    mov     qword ptr [rsp+8],1
    mov     r9,[rsp+78h]
    imul    rcx,[rsp+8],4
    add     r9,rcx
    lea     r10,[rsp+5Ch]
    mov     r11,[rsp+78h]
    mov     [rsp+28h],r10
    mov     [rsp+48h],r9
    mov     qword ptr [rsp+50h],0
    mov     rcx,[rsp+28h]
    mov     [rsp+40h],rcx
    mov     [rsp+38h],r11
    mov     qword ptr [rsp+8],2
    mov     r8,[rsp+8]
    sub     r8,1
    mov     rdx,[rsp+80h]
    sub     rdx,r8
    mov     r10,[rsp+78h]
    imul    rcx,rdx,4
    add     r10,rcx
    mov     [rsp+30h],r10
    nop     [rax+rax]
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    cmp     rax,[rsp+30h]
    jae     L6
    mov     qword ptr [rsp+8],2
    cmp     qword ptr [rsp+8],2
    sete    [rsp+5Ah]
    test    byte ptr [rsp+5Ah],0FFh
    je      L4
    lea     r8,[rsp+60h]
    mov     [rsp+28h],r8
    lea     r9,[rsp+38h]
    mov     [rsp+20h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn0
    lea     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn1
    jmp     L5
L4:
    lea     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn2
L5:
    jmp     L2
L6:
    mov     rax,[rsp+78h]
    imul    rcx,[rsp+80h],4
    add     rax,rcx
    mov     [rsp+28h],rax
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L8:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+28h]
    sete    [rsp+5Bh]
    test    byte ptr [rsp+5Bh],0FFh
    je      L9
    mov     rsi,[rsp+40h]
    mov     [rsp+20h],rsi
    jmp     L10
L9:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+48h],rax
    lea     rdx,[rsp+60h]
    mov     [rsp+20h],rdx
    lea     rsi,[rsp+38h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    call    fn3
    test    byte ptr [rsp+5Bh],0FFh
    je      L11
    mov     rdx,[rsp+38h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+50h]
    mov     [rsp+0C8h],rdi
    jmp     L12
L11:
    jmp     L7
L12:
    mov     rax,[rsp+0C8h]
    add     rsp,0D8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L14:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L16:
    lea     rax,[rsp+38h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn4
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L18:
    call    qword ptr [sym5]
    ud2
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L17
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L14
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L16
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L18
L24:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     rax,[rsp+88h]
    mov     rax,[rax]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx+10h]
    mov     rsi,[rsp+88h]
    mov     rsi,[rsi+8]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn0
    mov     [rsp+57h],al
    mov     rax,[rsp+88h]
    mov     rax,[rax+10h]
    mov     rax,[rax]
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx+18h]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rsp+48h],rax
    mov     [rsp+40h],rax
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi]
    mov     [rsp+38h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L6
    jmp     L3
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rax,[rsp+80h]
    mov     rax,[rax+10h]
    mov     [rsp+78h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L8
    jmp     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L4
    mov     byte ptr [rsp+56h],1
    jmp     L5
L4:
    mov     byte ptr [rsp+56h],0
L5:
    mov     qword ptr [rsp+20h],4
    lea     rdx,[k1]
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    movzx   ecx,byte ptr [rsp+56h]
    mov     r8,[rsp+18h]
    call    fn2
L6:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    jmp     L1
L7:
    mov     rax,[rsp+78h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k3]
    mov     [rsp+8],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn4
L8:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+48h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi+10h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+80h]
    mov     rcx,[rsp+40h]
    mov     [rdi],rcx
    movzx   r8d,byte ptr [rsp+57h]
    mov     r9,[rsp+80h]
    mov     r9,[r9+18h]
    add     r9,r8
    mov     [rsp+10h],r9
    mov     r10,[rsp+80h]
    mov     rcx,[rsp+10h]
    mov     [r10+18h],rcx
    mov     r11,[rsp+80h]
    mov     r11,[r11+10h]
    mov     qword ptr [rsp+20h],1
    imul    rcx,[rsp+20h],4
    add     r11,rcx
    mov     [rsp+40h],r11
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+40h]
    mov     [rdx+10h],rcx
    add     rsp,98h
    ret
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,0E8h
    mov     [rsp+0D0h],rdi
    mov     [rsp+0D8h],rsi
    mov     [rsp+0C8h],rdx
    mov     [rsp+0C4h],ecx
    mov     [rsp+0B8h],r8
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L2:
    mov     rax,[rsp+0D0h]
    mov     rdx,[rsp+0D8h]
    mov     [rsp+70h],rdx
    call    fn0
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    cmp     rax,[rsp+70h]
    jb      L3
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     rdx,[rsp+0B8h]
    call    fn1
    jmp     L11
L3:
    mov     eax,[rsp+0C4h]
    mov     [rsp+78h],eax
    cmp     eax,0
    jne     L4
    mov     rdi,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    mov     rdx,[rsp+0B8h]
    call    fn2
    jmp     L5
L4:
    mov     eax,[rsp+0C4h]
    sub     eax,1
    mov     [rsp+0C4h],eax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+68h],rsi
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+0B8h]
    call    fn3
    mov     [rsp+70h],rax
    jmp     L6
L5:
    jmp     L11
L6:
    cmp     qword ptr [rsp+0C8h],0
    je      L9
    mov     rdx,[rsp+0C8h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+0D0h]
    mov     rdi,[rsp+0D8h]
    mov     [rsp+98h],rdi
    mov     r8,[rsp+70h]
    cmp     r8,rdi
    jb      L7
    lea     r9,[k4]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym5]
    ud2
L7:
    mov     rax,[rsp+0D0h]
    imul    rcx,[rsp+70h],4
    add     rax,rcx
    mov     rdx,[rsp+68h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rax
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+60h]
    call    fn6
    mov     [rsp+7Eh],al
    test    byte ptr [rsp+7Eh],0FFh
    je      L8
    jmp     L9
L8:
    mov     rax,[rsp+0D0h]
    mov     rcx,[rsp+0D8h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+40h],rdx
    lea     rsi,[rsp+40h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+48h]
    call    fn7
    mov     [rsp+60h],rax
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+58h],rdx
    cmp     rdx,rax
    jb      L12
    jmp     L13
L9:
    mov     rax,[rsp+0D0h]
    mov     rcx,[rsp+0D8h]
    mov     [rsp+60h],rcx
    mov     [rsp+58h],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+70h]
    mov     rcx,[rsp+0B8h]
    call    fn8
    mov     [rsp+68h],rax
    mov     rax,[rsp+0D0h]
    mov     rdx,[rsp+0D8h]
    mov     rsi,[rsp+68h]
    cmp     rsi,rdx
    setb    [rsp+7Eh]
    lea     rdi,[k9]
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+0D0h]
    mov     rdx,[rsp+0D8h]
    mov     rcx,[rsp+68h]
    mov     r8,[rsp+10h]
    call    fn10
    mov     rax,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+60h],rcx
    mov     [rsp+58h],rax
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+10h],1
    lea     rdi,[k11]
    mov     [rsp+8],rdi
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+8]
    call    fn12
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+40h],rcx
    mov     [rsp+38h],rax
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp+30h]
    mov     [rsp+0D8h],rcx
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+80h],rsi
    mov     qword ptr [rsp+10h],0
    mov     r8,[rsp+10h]
    cmp     r8,rsi
    setb    [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    jne     L10
    mov     qword ptr [rsp+10h],0
    lea     r11,[k13]
    mov     [rsp+8],r11
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+8]
    call    qword ptr [sym14]
    ud2
L10:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     edx,[rsp+0C4h]
    mov     [rsp+78h],edx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     rdx,[rsp+0C8h]
    mov     ecx,[rsp+78h]
    mov     r8,[rsp+0B8h]
    call    fn15
    mov     rax,[rsp+30h]
    mov     [rsp+0C8h],rax
    jmp     L1
L11:
    add     rsp,0E8h
    ret
L12:
    lea     rax,[k16]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+10h]
    call    qword ptr [sym17]
    ud2
L13:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+88h]
    mov     rdx,[rsp+0D0h]
    mov     rsi,[rsp+0D8h]
    imul    rcx,[rsp+88h],4
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rax
    mov     qword ptr [rsp+0C8h],0
    jmp     L1
    ud2
L14:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+20h]
    mov     [rsp],rdx
    mov     rsi,[rsp+28h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp]
    mov     rdx,[rsp+8]
    call    fn0
    mov     [rsp+17h],al
    movzx   eax,byte ptr [rsp+17h]
    xor     al,1
    mov     [rsp+3Fh],al
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::slice::sort::unstable::sort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+18h],rdx
    mov     byte ptr [rsp+0Eh],0
    test    byte ptr [rsp+0Eh],0FFh
    jne     L5
    mov     rsi,[rsp+28h]
    mov     [rsp+10h],rsi
    cmp     rsi,2
    setb    [rsp+0Fh]
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    jmp     L5
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    jmp     L5
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    add     rsp,38h
    ret
L7:
    jmp     L5
L8:
    cmp     qword ptr [rsp+10h],14h
    setbe   [rsp+0Fh]
    test    byte ptr [rsp+0Fh],0FFh
    je      L9
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp]
    mov     rcx,[rsp+18h]
    call    fn0
    jmp     L1
L9:
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+18h]
    call    fn1
    jmp     L3
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,0A8h
    mov     [rsp+90h],rdi
    mov     [rsp+88h],rsi
    mov     [rsp+80h],rdx
    mov     [rsp+78h],rcx
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+80h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+78h]
    mov     rax,[rsp+48h]
    mul     rdi
    setb    cl
    mov     [rsp+30h],cl
    mov     [rsp+28h],rax
    movzx   r8d,byte ptr [rsp+30h]
    mov     [rsp+63h],r8b
    mov     [rsp+18h],rax
    test    byte ptr [rsp+63h],0FFh
    je      L1
    lea     r10,[k0]
    mov     [rsp+8],r10
    mov     qword ptr [rsp+10h],3Dh
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     rax,[rsp+18h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+58h]
    cmp     rsi,[rsp+50h]
    jae     L2
    mov     rdi,[rsp+50h]
    sub     rdi,rsi
    mov     [rsp+70h],rdi
    jmp     L3
L2:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+50h]
    mov     [rsp+70h],rax
L3:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+70h]
    setbe   [rsp+9Fh]
    movzx   eax,byte ptr [rsp+9Fh]
    add     rsp,0A8h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main
    inc     qword ptr [jit_record]
    jns     L22
L0:
    sub     rsp,318h
    mov     qword ptr [rsp+18h],3D090h
    mov     rdi,[rsp+18h]
    call    fn0
    mov     [rsp+308h],rax
    mov     rax,2545F4914F6CDD1Dh
    mov     [rsp+300h],rax
    mov     qword ptr [rsp+2C0h],0
    mov     rsi,[rsp+308h]
    mov     [rsp+2C8h],rsi
    lea     rdi,[rsp+300h]
    mov     [rsp+2B8h],rdi
    lea     rdi,[rsp+2D0h]
    mov     rsi,[rsp+2C0h]
    mov     rdx,[rsp+2C8h]
    mov     rcx,[rsp+2B8h]
    call    fn1
    mov     rax,[rsp+2D0h]
    mov     rcx,[rsp+2D8h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+2E0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+2E8h]
    lea     rsi,[rsp+8]
    call    fn2
    lea     rax,[rsp+2E8h]
    mov     [rsp+290h],rax
    lea     rdi,[rsp+298h]
    mov     rsi,[rsp+290h]
    call    fn3
    lea     rax,[rsp+298h]
    mov     [rsp+278h],rax
    mov     rdi,[rsp+278h]
    call    fn4
    mov     [rsp+280h],rax
    mov     [rsp+288h],rdx
    mov     rdi,[rsp+280h]
    mov     rsi,[rsp+288h]
    call    fn5
    lea     rax,[rsp+2E8h]
    mov     [rsp+258h],rax
    lea     rdi,[rsp+260h]
    mov     rsi,[rsp+258h]
    call    fn6
    lea     rax,[rsp+260h]
    mov     [rsp+240h],rax
    mov     rdi,[rsp+240h]
    call    fn7
    mov     [rsp+248h],rax
    mov     [rsp+250h],rdx
    lea     rdi,[rsp+220h]
    mov     rsi,[rsp+308h]
    call    fn8
    lea     rax,[rsp+220h]
    mov     [rsp+238h],rax
    mov     rdi,[rsp+248h]
    mov     rsi,[rsp+250h]
    mov     rdx,[rsp+238h]
    call    fn9
    lea     rax,[rsp+220h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn10
    lea     rax,[rsp+298h]
    lea     rdx,[rsp+260h]
    mov     [rsp+210h],rax
    mov     [rsp+218h],rdx
    mov     [rsp+1F8h],rax
    mov     [rsp+1F0h],rdx
    mov     rdi,[rsp+1F8h]
    mov     rsi,[rsp+1F0h]
    call    fn11
    mov     [rsp+1EFh],al
    test    byte ptr [rsp+1EFh],0FFh
    je      L1
    lea     rdx,[rsp+2E8h]
    mov     [rsp+188h],rdx
    mov     rdi,[rsp+188h]
    call    fn12
    mov     [rsp+190h],rax
    mov     [rsp+198h],rdx
    jmp     L2
L1:
    mov     byte ptr [rsp+1EEh],0
    mov     qword ptr [rsp+1D8h],0
    lea     rsi,[k13]
    mov     [rsp+18h],rsi
    movzx   edi,byte ptr [rsp+1EEh]
    mov     rsi,[rsp+1F8h]
    mov     rdx,[rsp+1F0h]
    mov     rcx,[rsp+1D8h]
    mov     r8,[rsp+1E0h]
    mov     r9,[rsp+18h]
    call    fn14
    ud2
L2:
    mov     rdi,[rsp+190h]
    mov     rsi,[rsp+198h]
    call    fn15
    mov     [rsp+1A0h],rax
    mov     [rsp+1A8h],rdx
    mov     rdi,[rsp+1A0h]
    mov     rsi,[rsp+1A8h]
    call    fn16
    mov     [rsp+1B0h],rax
    mov     [rsp+1B8h],rdx
    lea     rdi,[rsp+1C0h]
    mov     rsi,[rsp+1B0h]
    mov     rdx,[rsp+1B8h]
    call    fn17
    lea     rax,[rsp+1C0h]
    mov     [rsp+170h],rax
    mov     rdi,[rsp+170h]
    call    fn18
    mov     [rsp+178h],rax
    mov     [rsp+180h],rdx
    mov     rdi,[rsp+178h]
    mov     rsi,[rsp+180h]
    call    fn19
    lea     rax,[rsp+298h]
    mov     [rsp+118h],rax
    mov     rdi,[rsp+118h]
    call    fn20
    mov     [rsp+120h],rax
    mov     [rsp+128h],rdx
    mov     rdi,[rsp+120h]
    mov     rsi,[rsp+128h]
    call    fn21
    mov     [rsp+130h],rax
    lea     rax,[rsp+130h]
    mov     [rsp+138h],rax
    lea     rdx,[rsp+1C0h]
    mov     [rsp+108h],rdx
    mov     qword ptr [rsp+18h],0
    lea     rdi,[k22]
    mov     [rsp+10h],rdi
    mov     rdi,[rsp+108h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn23
    mov     [rsp+110h],rax
    lea     rax,[rsp+1C0h]
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+18h],1
    mov     rsi,[rsp+308h]
    sub     rsi,[rsp+18h]
    setb    cl
    mov     [rsp+0E8h],cl
    mov     [rsp+0E0h],rsi
    test    byte ptr [rsp+0E8h],0FFh
    je      L3
    lea     r8,[k24]
    mov     [rsp+18h],r8
    mov     rdi,[rsp+18h]
    call    qword ptr [sym25]
    ud2
L3:
    mov     rax,[rsp+0E0h]
    mov     [rsp+0F0h],rax
    lea     rdx,[k26]
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+0F8h]
    mov     rsi,[rsp+0F0h]
    mov     rdx,[rsp+18h]
    call    fn27
    mov     [rsp+100h],rax
    lea     rax,[rsp+308h]
    mov     rdx,[rsp+138h]
    mov     [rsp+140h],rdx
    mov     rsi,[rsp+110h]
    mov     [rsp+148h],rsi
    mov     rdi,[rsp+100h]
    mov     [rsp+150h],rdi
    mov     [rsp+158h],rax
    mov     [rsp+40h],rax
    lea     rdi,[rsp+88h]
    mov     rsi,[rsp+40h]
    call    fn28
    mov     rax,[rsp+140h]
    mov     [rsp+38h],rax
    lea     rdi,[rsp+78h]
    mov     rsi,[rsp+38h]
    call    fn29
    mov     rax,[rsp+148h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+68h]
    mov     rsi,[rsp+30h]
    call    fn30
    mov     rax,[rsp+150h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+58h]
    mov     rsi,[rsp+28h]
    call    fn31
    mov     rax,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     rdx,[rsp+78h]
    mov     rcx,[rsp+80h]
    mov     [rsp+0B0h],rcx
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+68h]
    mov     rcx,[rsp+70h]
    mov     [rsp+0C0h],rcx
    mov     [rsp+0B8h],rsi
    mov     rdi,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+0D0h],rcx
    mov     [rsp+0C8h],rdi
    lea     r8,[k32]
    mov     [rsp+50h],r8
    lea     r9,[rsp+98h]
    mov     [rsp+48h],r9
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    call    fn33
    mov     [rsp+160h],rax
    mov     [rsp+168h],rdx
    mov     rdi,[rsp+160h]
    mov     rsi,[rsp+168h]
    call    qword ptr [sym34]
    lea     rax,[rsp+1C0h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn35
    lea     rax,[rsp+260h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn36
    lea     rax,[rsp+298h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn37
    lea     rax,[rsp+2E8h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn38
    add     rsp,318h
    ret
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L5:
    lea     rax,[rsp+1C0h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn39
    jmp     L8
    nop     [rax+rax]
    nop
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L7:
    lea     rax,[rsp+220h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn40
    nop     [rax+rax]
    nop     [rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L9:
    lea     rax,[rsp+260h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn41
    nop     [rax+rax]
    nop     [rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L11:
    lea     rax,[rsp+298h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn42
    nop     [rax+rax]
    nop     [rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L13:
    lea     rax,[rsp+2E8h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn43
    lea     rdi,[rsp+310h]
    mov     esi,0FFFFFD10h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L15:
    call    qword ptr [sym44]
    ud2
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L12
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L8
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L6
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L4
    lea     rdi,[rsp+310h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L14
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L9
L19:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L11
L20:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L13
L21:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L22:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+10h],rax
    mov     rax,[rsp+10h]
    mov     [rsp+2Ch],eax
    mov     eax,[rsp+2Ch]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#1}
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+28h]
    mov     eax,[rax]
    mov     [rsp+24h],eax
    mov     dword ptr [rsp+18h],3E8h
    cmp     dword ptr [rsp+18h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    lea     r8,[k0]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+10h]
    call    qword ptr [sym1]
    ud2
L1:
    mov     eax,[rsp+24h]
    imul    rdx,rax,10624DD3h
    shr     rdx,26h
    mov     [rsp+0Ch],edx
    imul    esi,[rsp+0Ch],3E8h
    mov     edi,[rsp+24h]
    sub     edi,esi
    mov     [rsp+38h],edi
    mov     r8d,[rsp+24h]
    mov     [rsp+3Ch],r8d
    mov     eax,[rsp+38h]
    mov     edx,[rsp+3Ch]
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#2}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+8]
    mov     eax,[rax]
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn merge_sort
    inc     qword ptr [jit_record]
    jns     L27
L0:
    sub     rsp,378h
    mov     [rsp+360h],rdi
    mov     [rsp+368h],rsi
    mov     [rsp+358h],rdx
    mov     rax,[rsp+360h]
    mov     rdx,[rsp+368h]
    mov     [rsp+348h],rdx
    cmp     rdx,10h
    ja      L11
    mov     rdi,[rsp+360h]
    mov     r8,[rsp+368h]
    mov     qword ptr [rsp+318h],1
    mov     [rsp+320h],r8
    mov     rdi,[rsp+318h]
    mov     rsi,[rsp+320h]
    call    fn0
    mov     [rsp+328h],rax
    mov     [rsp+330h],rdx
    mov     rax,[rsp+328h]
    mov     rcx,[rsp+330h]
    mov     [rsp+2F8h],rcx
    mov     [rsp+2F0h],rax
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L2:
    lea     rax,[rsp+2F0h]
    mov     [rsp+2D8h],rax
    mov     rdi,[rsp+2D8h]
    call    fn1
    mov     [rsp+2E0h],rax
    mov     [rsp+2E8h],rdx
    mov     rax,[rsp+2E0h]
    mov     [rsp+2D0h],rax
    cmp     rax,0
    je      L23
    jmp     L3
    ud2
L3:
    mov     rax,[rsp+2E8h]
    mov     [rsp+2C0h],rax
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L5:
    mov     rax,[rsp+2C0h]
    mov     [rsp+2B0h],rax
    cmp     rax,0
    jbe     L1
    mov     rsi,[rsp+2C0h]
    mov     [rsp+298h],rsi
    mov     qword ptr [rsp],1
    sub     rsi,[rsp]
    setb    cl
    mov     [rsp+290h],cl
    mov     [rsp+288h],rsi
    test    byte ptr [rsp+290h],0FFh
    je      L6
    lea     r9,[k2]
    mov     [rsp],r9
    mov     rdi,[rsp]
    call    qword ptr [sym3]
    ud2
L6:
    mov     rax,[rsp+288h]
    mov     [rsp+2A0h],rax
    mov     rdx,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     [rsp+270h],rsi
    cmp     rax,rsi
    jb      L7
    lea     rdi,[k4]
    mov     [rsp],rdi
    mov     rdi,[rsp+2A0h]
    mov     rsi,[rsp+270h]
    mov     rdx,[rsp]
    call    qword ptr [sym5]
    ud2
L7:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+2A0h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+2A8h],eax
    mov     rdx,[rsp+2C0h]
    mov     [rsp+260h],rdx
    mov     rsi,[rsp+360h]
    mov     rdi,[rsp+368h]
    mov     [rsp+248h],rdi
    cmp     rdx,rdi
    jb      L8
    lea     r8,[k6]
    mov     [rsp],r8
    mov     rdi,[rsp+260h]
    mov     rsi,[rsp+248h]
    mov     rdx,[rsp]
    call    qword ptr [sym7]
    ud2
L8:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+260h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+268h],eax
    cmp     eax,[rsp+2A8h]
    jae     L1
    mov     rdx,[rsp+2C0h]
    mov     [rsp+230h],rdx
    mov     qword ptr [rsp],1
    sub     rdx,[rsp]
    setb    cl
    mov     [rsp+228h],cl
    mov     [rsp+220h],rdx
    test    byte ptr [rsp+228h],0FFh
    je      L9
    lea     r8,[k8]
    mov     [rsp],r8
    mov     rdi,[rsp]
    call    qword ptr [sym9]
    ud2
L9:
    mov     rax,[rsp+220h]
    mov     [rsp+238h],rax
    mov     rdx,[rsp+2C0h]
    mov     [rsp+218h],rdx
    lea     rsi,[k10]
    mov     [rsp],rsi
    mov     rdi,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     rdx,[rsp+238h]
    mov     rcx,[rsp+218h]
    mov     r8,[rsp]
    call    fn11
    mov     qword ptr [rsp],1
    mov     rdx,[rsp+2C0h]
    sub     rdx,[rsp]
    setb    cl
    mov     [rsp+210h],cl
    mov     [rsp+208h],rdx
    test    byte ptr [rsp+210h],0FFh
    je      L10
    lea     rdi,[k12]
    mov     [rsp],rdi
    mov     rdi,[rsp]
    call    qword ptr [sym13]
    ud2
L10:
    mov     rax,[rsp+208h]
    mov     [rsp+2C0h],rax
    jmp     L4
L11:
    mov     rax,[rsp+360h]
    mov     rdx,[rsp+368h]
    mov     [rsp+1F8h],rdx
    mov     qword ptr [rsp],2
    cmp     qword ptr [rsp],0
    sete    [rsp+1E7h]
    test    byte ptr [rsp+1E7h],0FFh
    je      L12
    lea     r9,[k14]
    mov     [rsp],r9
    mov     rdi,[rsp]
    call    qword ptr [sym15]
    ud2
L12:
    mov     rax,[rsp+1F8h]
    shr     rax,1
    mov     [rsp+200h],rax
    mov     [rsp+1C8h],rax
    lea     rdx,[k16]
    mov     [rsp],rdx
    mov     rdi,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     rdx,[rsp+1C8h]
    mov     rcx,[rsp]
    call    fn17
    mov     [rsp+1D0h],rax
    mov     [rsp+1D8h],rdx
    mov     rdi,[rsp+1D0h]
    mov     rsi,[rsp+1D8h]
    mov     rdx,[rsp+358h]
    call    fn18
    mov     rax,[rsp+200h]
    mov     [rsp+1B0h],rax
    lea     rdx,[k19]
    mov     [rsp],rdx
    mov     rdi,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     rdx,[rsp+1B0h]
    mov     rcx,[rsp]
    call    fn20
    mov     [rsp+1B8h],rax
    mov     [rsp+1C0h],rdx
    mov     rdi,[rsp+1B8h]
    mov     rsi,[rsp+1C0h]
    mov     rdx,[rsp+358h]
    call    fn21
    mov     rdi,[rsp+358h]
    call    fn22
    mov     qword ptr [rsp+190h],0
    mov     rdx,[rsp+200h]
    mov     [rsp+198h],rdx
    mov     rsi,[rsp+190h]
    mov     [rsp+1A8h],rsi
    mov     [rsp+1A0h],rdx
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L14:
    mov     rax,[rsp+1A8h]
    mov     [rsp+180h],rax
    cmp     rax,[rsp+200h]
    jae     L22
    mov     rdx,[rsp+1A0h]
    mov     [rsp+170h],rdx
    mov     rsi,[rsp+360h]
    mov     rdi,[rsp+368h]
    mov     [rsp+168h],rdi
    cmp     rdx,rdi
    jae     L22
    mov     r8,[rsp+1A8h]
    mov     [rsp+148h],r8
    mov     r9,[rsp+360h]
    mov     r10,[rsp+368h]
    mov     [rsp+130h],r10
    cmp     r8,r10
    jb      L15
    lea     r11,[k23]
    mov     [rsp],r11
    mov     rdi,[rsp+148h]
    mov     rsi,[rsp+130h]
    mov     rdx,[rsp]
    call    qword ptr [sym24]
    ud2
L15:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+148h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+150h],eax
    mov     rdx,[rsp+1A0h]
    mov     [rsp+120h],rdx
    mov     rsi,[rsp+360h]
    mov     rdi,[rsp+368h]
    mov     [rsp+108h],rdi
    cmp     rdx,rdi
    jb      L16
    lea     r8,[k25]
    mov     [rsp],r8
    mov     rdi,[rsp+120h]
    mov     rsi,[rsp+108h]
    mov     rdx,[rsp]
    call    qword ptr [sym26]
    ud2
L16:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+120h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+128h],eax
    cmp     eax,[rsp+150h]
    jb      L19
    mov     rdx,[rsp+1A8h]
    mov     [rsp+0F8h],rdx
    mov     rsi,[rsp+360h]
    mov     rdi,[rsp+368h]
    mov     [rsp+0E0h],rdi
    cmp     rdx,rdi
    jb      L17
    lea     r8,[k27]
    mov     [rsp],r8
    mov     rdi,[rsp+0F8h]
    mov     rsi,[rsp+0E0h]
    mov     rdx,[rsp]
    call    qword ptr [sym28]
    ud2
L17:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+0F8h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+100h],eax
    mov     rdi,[rsp+358h]
    mov     esi,[rsp+100h]
    call    fn29
    mov     qword ptr [rsp],1
    mov     rdx,[rsp+1A8h]
    add     rdx,[rsp]
    setb    cl
    mov     [rsp+0D0h],cl
    mov     [rsp+0C8h],rdx
    test    byte ptr [rsp+0D0h],0FFh
    je      L18
    lea     rdi,[k30]
    mov     [rsp],rdi
    mov     rdi,[rsp]
    call    qword ptr [sym31]
    ud2
L18:
    mov     rax,[rsp+0C8h]
    mov     [rsp+1A8h],rax
    jmp     L13
L19:
    mov     rax,[rsp+1A0h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     [rsp+0A0h],rsi
    cmp     rax,rsi
    jb      L20
    lea     rdi,[k32]
    mov     [rsp],rdi
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A0h]
    mov     rdx,[rsp]
    call    qword ptr [sym33]
    ud2
L20:
    mov     rax,[rsp+360h]
    imul    rcx,[rsp+0B8h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+0C4h],eax
    mov     rdi,[rsp+358h]
    mov     esi,[rsp+0C4h]
    call    fn34
    mov     qword ptr [rsp],1
    mov     rdx,[rsp+1A0h]
    add     rdx,[rsp]
    setb    cl
    mov     [rsp+90h],cl
    mov     [rsp+88h],rdx
    test    byte ptr [rsp+90h],0FFh
    je      L21
    lea     rdi,[k35]
    mov     [rsp],rdi
    mov     rdi,[rsp]
    call    qword ptr [sym36]
    ud2
L21:
    mov     rax,[rsp+88h]
    mov     [rsp+1A0h],rax
    jmp     L13
L22:
    mov     rax,[rsp+360h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+368h]
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+1A8h]
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+200h]
    mov     [rsp+60h],rdi
    lea     r8,[k37]
    mov     [rsp],r8
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     r8,[rsp]
    call    fn38
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    mov     rdi,[rsp+358h]
    mov     rsi,[rsp+78h]
    mov     rdx,[rsp+80h]
    call    fn39
    mov     rax,[rsp+360h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+368h]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+1A0h]
    mov     [rsp+28h],rsi
    lea     rdi,[k40]
    mov     [rsp],rdi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+28h]
    mov     rcx,[rsp]
    call    fn41
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+358h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+48h]
    call    fn42
    mov     rax,[rsp+358h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn43
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    lea     rax,[k44]
    mov     [rsp],rax
    mov     rdi,[rsp+360h]
    mov     rsi,[rsp+368h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp]
    call    fn45
L23:
    add     rsp,378h
    ret
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L14
L27:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::array::iter::iter_inner::PolymorphicIter::<[std::mem::MaybeUninit<usize>]>::next
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,0C8h
    mov     [rsp+0A0h],rdi
    mov     [rsp+0A8h],rsi
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    sub     rax,rdx
    mov     [rsp+60h],rax
    cmp     rax,0
    jbe     L1
    mov     rdi,[rsp+0A0h]
    mov     rdi,[rdi]
    mov     [rsp+60h],rdi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L3
    jmp     L2
L1:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+0A0h]
    lea     rax,[rax+10h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+90h],rdx
    mov     rcx,[rsp+90h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     qword ptr [rsp+0B0h],0
    jmp     L4
L2:
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k1]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn2
L3:
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+58h]
    mov     [rdx],rcx
    mov     rsi,[rsp+60h]
    mov     [rsp+78h],rsi
    mov     qword ptr [rsp+70h],1
    mov     r8,[rsp+0A0h]
    lea     r8,[r8+10h]
    mov     [rsp+88h],r8
    mov     r9,[rsp+0A8h]
    mov     [rsp+90h],r9
    mov     rcx,[rsp+90h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],r8
    mov     [rsp+68h],rsi
    mov     r10,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],r10
    mov     r11,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+58h],rcx
    mov     [rsp+50h],r11
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    add     rsp,0C8h
    ret
L6:
    mov     rax,[rsp+90h]
    mov     [rsp+40h],rax
    lea     rdx,[k3]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+40h]
    mov     rdx,[rsp+10h]
    call    fn4
L7:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+68h]
    cmp     rdx,rax
    setb    [rsp+47h]
    mov     rsi,[rsp+88h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rsp+48h],rsi
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
    mov     rax,[rsp+48h]
    mov     rax,[rax]
    mov     [rsp+0B8h],rax
    mov     qword ptr [rsp+0B0h],1
    jmp     L4
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+10h]
    mov     eax,[rax]
    mov     rdx,[rsp+8]
    mov     edx,[rdx]
    cmp     eax,edx
    setb    [rsp+1Fh]
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::Arguments::<'_>::new::<22, 4>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::fmt::DebugList::<'_, '_>::entries::<&u32, std::slice::Iter<'_, u32>>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,98h
    mov     [rsp+80h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rdx
    mov     rdi,[rsp+70h]
    mov     rsi,[rsp+78h]
    call    fn0
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    lea     rax,[rsp+40h]
    mov     [rsp+30h],rax
    mov     rdi,[rsp+30h]
    call    fn1
    mov     [rsp+38h],rax
    cmp     qword ptr [rsp+38h],0
    je      L4
    jmp     L3
    ud2
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+28h]
    mov     [rsp+10h],rdx
    lea     rsi,[k2]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+18h]
    call    qword ptr [sym3]
    mov     [rsp+20h],rax
    jmp     L5
L4:
    jmp     L6
L5:
    jmp     L1
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+88h],rax
    mov     rax,[rsp+88h]
    add     rsp,98h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L8:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L7
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L7
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L8
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::assert_unchecked::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,88h
    mov     [rsp+7Fh],dil
    mov     [rsp+18h],rsi
    test    byte ptr [rsp+7Fh],0FFh
    jne     L1
    lea     rdx,[k0]
    mov     qword ptr [rsp+70h],0DDh
    mov     rdi,[rsp+70h]
    lea     r8,[k1]
    mov     qword ptr [rsp+28h],0DDh
    mov     r10,[rsp+28h]
    shl     r10,1
    or      r10,1
    mov     [rsp+58h],rdx
    mov     [rsp+60h],r10
    mov     byte ptr [rsp+17h],0
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L1:
    add     rsp,88h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::black_box::<usize>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::select_unpredictable::<*const (u32, u32)>
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,0B8h
    mov     [rsp+0A7h],dil
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+98h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+60h],rdx
    lea     rsi,[rsp+68h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     [rsp+50h],rdi
    movzx   r8d,byte ptr [rsp+0A7h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A7h]
    mov     [rsp+8],al
    mov     rdx,[rsp+50h]
    mov     [rsp],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+38h]
    call    qword ptr [sym2]
    jmp     L7
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym3]
    jmp     L8
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L6:
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn4
    jmp     L3
L7:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+28h],rsi
    movzx   edi,byte ptr [rsp+0A7h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+28]
    call    qword ptr [sym5]
    jmp     L1
L8:
    mov     rax,[rsp+38h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    xchg    ax,ax
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L10:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L9
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L13:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L14:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::select_unpredictable::<*const u32>
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,0B8h
    mov     [rsp+0A7h],dil
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+98h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+60h],rdx
    lea     rsi,[rsp+68h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     [rsp+50h],rdi
    movzx   r8d,byte ptr [rsp+0A7h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A7h]
    mov     [rsp+8],al
    mov     rdx,[rsp+50h]
    mov     [rsp],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+38h]
    call    qword ptr [sym2]
    jmp     L7
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym3]
    jmp     L8
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L6:
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn4
    jmp     L3
L7:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+28h],rsi
    movzx   edi,byte ptr [rsp+0A7h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+28]
    call    qword ptr [sym5]
    jmp     L1
L8:
    mov     rax,[rsp+38h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    xchg    ax,ax
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L10:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L9
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L13:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L14:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::hint::select_unpredictable::<*mut u32>
    inc     qword ptr [jit_record]
    jns     L15
L0:
    sub     rsp,0B8h
    mov     [rsp+0A7h],dil
    mov     [rsp+98h],rsi
    mov     [rsp+90h],rdx
    mov     rax,[rsp+98h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+60h],rdx
    lea     rsi,[rsp+68h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     [rsp+50h],rdi
    movzx   r8d,byte ptr [rsp+0A7h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A7h]
    mov     [rsp+8],al
    mov     rdx,[rsp+50h]
    mov     [rsp],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+38h]
    call    qword ptr [sym2]
    jmp     L7
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L2:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+16]
    call    qword ptr [sym3]
    jmp     L8
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L6:
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     rdi,[rsp+20h]
    call    fn4
    jmp     L3
L7:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+28h],rsi
    movzx   edi,byte ptr [rsp+0A7h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+28]
    call    qword ptr [sym5]
    jmp     L1
L8:
    mov     rax,[rsp+38h]
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    add     rsp,0B8h
    ret
    xchg    ax,ax
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L10:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L9
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L13:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L14:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L15:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::cold_path
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,8
    add     rsp,8
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<*mut *const (u32, u32)>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<*mut *const u32>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<*mut *mut u32>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const (u32, u32)>>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const u32>>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*mut u32>>
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,28h
    mov     [rsp+17h],dil
    mov     [rsp+8],rsi
    mov     [rsp],rdx
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    jmp     L2
L1:
    mov     rax,[rsp]
    mov     [rsp+18h],rax
L2:
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::typed_swap_nonoverlapping::<(u32, u32)>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    call    fn1
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    call    qword ptr [sym2]
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::intrinsics::typed_swap_nonoverlapping::<u32>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     [rsp+20h],rsi
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k0]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+8]
    call    fn1
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    call    qword ptr [sym2]
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],esi
    mov     [rsp+14h],edx
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+10h]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     esi,[rsp]
    mov     edx,[rsp+4]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+14h],esi
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     edx,[rsp+14h]
    mov     [rsp+10h],edx
    mov     rdi,[rsp+8]
    mov     esi,[rsp+10h]
    call    fn0
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,58h
    mov     [rsp+48h],rdi
    mov     [rsp+40h],rsi
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+3Fh],1
    mov     rsi,[rsp+48h]
    lea     rsi,[rsi+18h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+40h]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+18h],eax
    mov     [rsp+1Ch],edx
    mov     byte ptr [rsp+3Fh],0
    mov     rdx,[rsp+18h]
    mov     [rsp+20h],rdx
    mov     rdi,[rsp+28h]
    mov     esi,[rsp+20h]
    mov     edx,[rsp+24h]
    call    fn1
    add     rsp,58h
    ret
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    jmp     L1
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L6:
    test    byte ptr [rsp+3Fh],0FFh
    je      L1
    jmp     L3
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L5
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L10
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+2Fh],1
    mov     rsi,[rsp+38h]
    lea     rsi,[rsi+18h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+30h]
    mov     [rsp],rdi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+10h],eax
    mov     byte ptr [rsp+2Fh],0
    mov     edx,[rsp+10h]
    mov     [rsp+14h],edx
    mov     rdi,[rsp+18h]
    mov     esi,[rsp+14h]
    call    fn1
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    jmp     L1
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L6:
    test    byte ptr [rsp+2Fh],0FFh
    je      L1
    jmp     L3
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L5
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::size_hint
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,48h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+20h]
    lea     rdx,[rdx+8]
    mov     [rsp],rdx
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+17h],al
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+20h]
    lea     rsi,[rsi+8]
    mov     [rsp],rsi
    lea     rdi,[rsp+28h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
    jmp     L2
L1:
    mov     qword ptr [rsp+28h],0
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
L2:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+18h]
    add     rsp,48h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,88h
    mov     [rsp+70h],rdi
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF84h
    mov     edx,0FFFFFFE8h
    call    ryo_h_CtpopW64
    mov     eax,[rsp+4]
    mov     [rsp+60h],eax
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+68h]
    sub     rdx,1
    and     rax,rdx
    cmp     rax,0
    sete    [rsp+7Fh]
    movzx   eax,byte ptr [rsp+7Fh]
    add     rsp,88h
    ret
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L4:
    lea     rax,[k0]
    mov     qword ptr [rsp+48h],2Ah
    mov     rsi,[rsp+48h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+10h],2Ah
    mov     r9,[rsp+10h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    lea     r10,[k2]
    mov     [rsp],r10
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp]
    call    qword ptr [sym3]
    ud2
L5:
    cmp     dword ptr [rsp+60h],1
    sete    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L3
    jmp     L1
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jb      L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0C9h
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0C9h
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::copy::precondition_check
    inc     qword ptr [jit_record]
    jns     L33
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+87h],cl
    mov     [rsp+10h],r8
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+88h]
    call    fn0
    mov     [rsp+66h],al
    jmp     L13
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L2:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L4:
    jmp     L5
    nop
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L6:
    lea     rax,[k1]
    mov     qword ptr [rsp+78h],0DDh
    mov     rsi,[rsp+78h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+20h],0DDh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L8:
    test    byte ptr [rsp+87h],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L10:
    jmp     L5
L11:
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+88h]
    call    fn4
    mov     [rsp+65h],al
    jmp     L20
L12:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L5
    jmp     L21
L13:
    test    byte ptr [rsp+66h],0FFh
    je      L9
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L15:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L17:
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L19:
    mov     rax,[rsp+90h]
    cmp     rax,0
    sete    [rsp+64h]
    movzx   esi,byte ptr [rsp+64h]
    xor     sil,1
    mov     [rsp+66h],sil
    test    byte ptr [rsp+66h],0FFh
    je      L3
    jmp     L1
L20:
    test    byte ptr [rsp+65h],0FFh
    je      L14
    jmp     L16
L21:
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+88h]
    call    fn5
    mov     [rsp+65h],al
    test    byte ptr [rsp+65h],0FFh
    je      L14
    jmp     L18
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L23:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L22
L24:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L25:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L26:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L27:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L28:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L29:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L15
L30:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L17
L31:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L19
L32:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L33:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::copy_nonoverlapping::precondition_check
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+18h],r9
    cmp     qword ptr [rsp+98h],0
    jne     L1
    mov     byte ptr [rsp+97h],1
    jmp     L2
L1:
    cmp     qword ptr [rsp+0A8h],0
    sete    [rsp+97h]
L2:
    movzx   eax,byte ptr [rsp+97h]
    mov     [rsp+6Dh],al
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+6Ch],al
    jmp     L19
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+88h],rax
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+6Ch],al
    jmp     L26
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L6:
    mov     rdi,[rsp+0B8h]
    mov     rsi,[rsp+88h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+6Fh],al
    jmp     L27
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    jmp     L9
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L10:
    lea     rax,[k3]
    mov     qword ptr [rsp+80h],11Bh
    mov     rsi,[rsp+80h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+28h],11Bh
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym5]
    ud2
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L12:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L14:
    test    byte ptr [rsp+6Dh],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L16:
    jmp     L9
L17:
    jmp     L3
L18:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Eh],sil
    test    byte ptr [rsp+6Eh],0FFh
    je      L9
    jmp     L3
L19:
    test    byte ptr [rsp+6Ch],0FFh
    je      L15
    jmp     L13
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    test    byte ptr [rsp+97h],0FFh
    je      L25
    jmp     L24
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L23:
    jmp     L7
L24:
    jmp     L5
L25:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+6Bh]
    movzx   esi,byte ptr [rsp+6Bh]
    xor     sil,1
    mov     [rsp+6Dh],sil
    test    byte ptr [rsp+6Dh],0FFh
    je      L7
    jmp     L5
L26:
    test    byte ptr [rsp+6Ch],0FFh
    je      L22
    jmp     L20
L27:
    test    byte ptr [rsp+6Fh],0FFh
    je      L9
    jmp     L11
    nop
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L29:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L28
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L36:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L16
L37:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L38:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L39:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<(u32, u32)>> - shim(Some(alloc::raw_vec::RawVec<(u32, u32)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u32>> - shim(Some(alloc::raw_vec::RawVec<u32>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<core::slice::sort::stable::merge::MergeState<(u32, u32)>> - shim(Some(core::slice::sort::stable::merge::MergeState<(u32, u32)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<core::slice::sort::unstable::quicksort::GapGuardRaw<u32>> - shim(Some(core::slice::sort::unstable::quicksort::GapGuardRaw<u32>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::array::IntoIter<usize, 2>> - shim(Some(std::array::IntoIter<usize, 2>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const u32>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*mut u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*mut u32>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::vec::Vec<(u32, u32)>> - shim(Some(std::vec::Vec<(u32, u32)>))
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L7
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    jmp     L3
L7:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L9:
    call    qword ptr [sym3]
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L8
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::vec::Vec<u32>> - shim(Some(std::vec::Vec<u32>))
    inc     qword ptr [jit_record]
    jns     L14
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L7
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L2:
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L4:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L6:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    jmp     L3
L7:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L9:
    call    qword ptr [sym3]
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L8
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L11:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L12:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L13:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L14:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<std::vec::set_len_on_drop::SetLenOnDrop<'_>> - shim(Some(std::vec::set_len_on_drop::SetLenOnDrop<'_>))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::drop_glue::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}))
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap::<u32>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+70h],rsi
    mov     rax,[rsp+78h]
    mov     [rsp+40h],rax
    lea     rdx,[rsp+4Ch]
    mov     [rsp+58h],rdx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     r8,[rsp+78h]
    mov     [rsp+30h],r8
    mov     r9,[rsp+58h]
    mov     [rsp+28h],r9
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     rdi,[k0]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn1
L1:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+38h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    mov     rsi,[rsp+70h]
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L7
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L3:
    lea     rax,[rsp+4Ch]
    mov     [rsp+50h],rax
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L9
    jmp     L8
L4:
    mov     rax,[rsp+70h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L5
    mov     byte ptr [rsp+4Bh],1
    jmp     L6
L5:
    mov     byte ptr [rsp+4Bh],0
L6:
    mov     qword ptr [rsp+20h],4
    lea     rdx,[k2]
    mov     [rsp+18h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    movzx   ecx,byte ptr [rsp+4Bh]
    mov     r8,[rsp+18h]
    call    fn3
L7:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+78h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    jmp     L2
L8:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     qword ptr [rsp+20h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],1
    lea     r9,[k4]
    mov     [rsp+8],r9
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+30h]
    mov     rdx,[rsp+20h]
    mov     rcx,[rsp+18h]
    mov     r8,[rsp+10h]
    mov     r9,[rsp+8]
    call    fn5
L9:
    mov     rax,[rsp+40h]
    mov     eax,[rax]
    mov     [rsp+20h],eax
    mov     rdx,[rsp+70h]
    mov     ecx,[rsp+20h]
    mov     [rdx],ecx
    add     rsp,88h
    ret
L10:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<1>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    mov     rdx,[rsp+10h]
    movzx   edx,byte ptr [rdx]
    mov     [rsp+0Eh],dl
    mov     rsi,[rsp+18h]
    movzx   ecx,byte ptr [rsp+0Eh]
    mov     [rsi],cl
    mov     rdi,[rsp+10h]
    movzx   ecx,byte ptr [rsp+0Fh]
    mov     [rdi],cl
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<2>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    movzx   eax,word ptr [rax]
    mov     [rsp+0Eh],ax
    mov     rdx,[rsp+10h]
    movzx   edx,word ptr [rdx]
    mov     [rsp+0Ch],dx
    mov     rsi,[rsp+18h]
    movzx   ecx,word ptr [rsp+0Ch]
    mov     [rsi],cx
    mov     rdi,[rsp+10h]
    movzx   ecx,word ptr [rsp+0Eh]
    mov     [rdi],cx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<4>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     eax,[rax]
    mov     [rsp+0Ch],eax
    mov     rdx,[rsp+10h]
    mov     edx,[rdx]
    mov     [rsp+8],edx
    mov     rsi,[rsp+18h]
    mov     ecx,[rsp+8]
    mov     [rsi],ecx
    mov     rdi,[rsp+10h]
    mov     ecx,[rsp+0Ch]
    mov     [rdi],ecx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_chunk::<8>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdx,[rsp+10h]
    mov     rdx,[rdx]
    mov     [rsp],rdx
    mov     rsi,[rsp+18h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+10h]
    mov     rcx,[rsp+8]
    mov     [rdi],rcx
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping::<(u32, u32)>
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+20h],rcx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     rsi,[rsp+78h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+70h]
    mov     [rsp+58h],rdi
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    mov     r10,[rsp+20h]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+8]
    call    fn0
L1:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+68h]
    mov     [rsp+60h],rdx
    mov     rcx,[rsp+60h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    imul    rsi,[rsp+48h],8
    mov     [rsp+50h],rsi
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+40h]
    call    fn1
    jmp     L4
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    add     rsp,88h
    ret
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L4
    jmp     L2
    ud2
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping::<u32>
    inc     qword ptr [jit_record]
    jns     L9
L0:
    sub     rsp,88h
    mov     [rsp+78h],rdi
    mov     [rsp+70h],rsi
    mov     [rsp+68h],rdx
    mov     [rsp+20h],rcx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L1
    mov     rsi,[rsp+78h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+70h]
    mov     [rsp+58h],rdi
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    mov     r10,[rsp+20h]
    mov     [rsp+8],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+58h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+68h]
    mov     r9,[rsp+8]
    call    fn0
L1:
    mov     rax,[rsp+78h]
    mov     rdx,[rsp+68h]
    mov     [rsp+60h],rdx
    mov     rcx,[rsp+60h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rax
    imul    rsi,[rsp+48h],4
    mov     [rsp+50h],rsi
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+40h]
    call    fn1
    jmp     L4
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L5:
    add     rsp,88h
    ret
L6:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    cmp     rax,0
    je      L4
    jmp     L2
    ud2
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L8:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L9:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping::precondition_check
    inc     qword ptr [jit_record]
    jns     L40
L0:
    sub     rsp,0C8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0B0h],rsi
    mov     [rsp+0A8h],rdx
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],r8
    mov     [rsp+10h],r9
    cmp     qword ptr [rsp+0A8h],0
    jne     L1
    mov     byte ptr [rsp+97h],1
    jmp     L2
L1:
    cmp     qword ptr [rsp+98h],0
    sete    [rsp+97h]
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+88h],rax
    movzx   edx,byte ptr [rsp+97h]
    mov     [rsp+65h],dl
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+0A0h]
    call    fn0
    mov     [rsp+64h],al
    jmp     L19
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+80h],rax
    mov     rdi,[rsp+80h]
    mov     rsi,[rsp+0A0h]
    call    fn1
    mov     [rsp+64h],al
    jmp     L26
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L6:
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+80h]
    mov     rdx,[rsp+0A8h]
    mov     rcx,[rsp+98h]
    call    fn2
    mov     [rsp+67h],al
    jmp     L27
    nop     [rax+rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L8:
    jmp     L9
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L10:
    lea     rax,[k3]
    mov     qword ptr [rsp+78h],11Bh
    mov     rsi,[rsp+78h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+20h],11Bh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym5]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L12:
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L14:
    test    byte ptr [rsp+65h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
    nop
L15:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L16:
    jmp     L9
L17:
    jmp     L3
L18:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+66h],sil
    test    byte ptr [rsp+66h],0FFh
    je      L9
    jmp     L3
L19:
    test    byte ptr [rsp+64h],0FFh
    je      L15
    jmp     L13
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    test    byte ptr [rsp+97h],0FFh
    je      L25
    jmp     L24
    nop     [rax]
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L23:
    jmp     L7
L24:
    jmp     L5
L25:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+63h]
    movzx   esi,byte ptr [rsp+63h]
    xor     sil,1
    mov     [rsp+65h],sil
    test    byte ptr [rsp+65h],0FFh
    je      L7
    jmp     L5
L26:
    test    byte ptr [rsp+64h],0FFh
    je      L22
    jmp     L20
L27:
    test    byte ptr [rsp+67h],0FFh
    je      L9
    jmp     L11
    nop
L28:
    inc     qword ptr [jit_record.ctr_l]
    jns     L39
L29:
    call    qword ptr [sym6]
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L28
L30:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L31:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L32:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L8
L33:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L10
L34:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L12
L35:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L14
L36:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L16
L37:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L21
L38:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L23
L39:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L29
L40:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    shr     rax,3
    mov     [rsp+38h],rax
    mov     rdx,[rsp+40h]
    and     rdx,7
    mov     [rsp+30h],rdx
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L1
    mov     [rsp+20h],rax
    mov     rdi,[rsp+68h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+60h]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+20h]
    call    fn0
    jmp     L1
L1:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L2
    mov     [rsp+20h],rax
    imul    rsi,[rsp+38h],8
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+60h]
    imul    rcx,rsi,1
    add     r8,rcx
    mov     [rsp+8],r8
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+20h]
    call    fn1
    jmp     L2
L2:
    add     rsp,78h
    ret
    ud2
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+78h],rdx
    mov     rax,[rsp+78h]
    mov     qword ptr [rsp+68h],0
    mov     [rsp+70h],rax
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    cmp     rax,rdx
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    jmp     L1
L5:
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L8
    jmp     L7
L6:
    add     rsp,98h
    ret
L7:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k0]
    mov     [rsp],rdx
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L8:
    mov     rax,[rsp+28h]
    add     rax,1
    mov     [rsp+68h],rax
    mov     rdx,[rsp+28h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+30h],rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rsp+18h],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn2
    jmp     L3
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     [rsp+58h],rdx
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],0
    and     rax,4
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L1
    mov     rdi,[rsp+30h]
    mov     r8,[rsp+68h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rsp+28h],r8
    mov     r9,[rsp+30h]
    mov     r10,[rsp+60h]
    imul    rcx,r9,1
    add     r10,rcx
    mov     [rsp+18h],r10
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn0
    mov     rax,[rsp+30h]
    or      rax,4
    mov     [rsp+30h],rax
    jmp     L1
L1:
    mov     rax,[rsp+38h]
    and     rax,2
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rsp+30h]
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+30h]
    mov     r9,[rsp+60h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+18h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn1
    mov     rax,[rsp+30h]
    or      rax,2
    mov     [rsp+30h],rax
    jmp     L2
L2:
    mov     rax,[rsp+38h]
    and     rax,1
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L3
    mov     rsi,[rsp+30h]
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+28h],rdi
    mov     r8,[rsp+30h]
    mov     r9,[rsp+60h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+18h],r9
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    call    fn2
    mov     rax,[rsp+30h]
    or      rax,1
    mov     [rsp+30h],rax
    jmp     L3
L3:
    add     rsp,78h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+2Fh],cl
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdx,[rsp+8]
    mov     [rsp+18h],rdx
    lea     rsi,[k0]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+38h]
    mov     rcx,[rsp+30h]
    movzx   r8d,byte ptr [rsp+2Fh]
    call    qword ptr [sym1]
    mov     [rsp+48h],rax
    mov     rax,[rsp+48h]
    add     rsp,58h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::rt::lang_start::<()>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    mov     rax,[rax]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    call    fn1
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    lea     rax,[rsp+20h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+10h]
    call    fn0
    add     rsp,38h
    ret
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rsi
    mov     [rsp+40h],rdx
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+1Ch],eax
    lea     rax,[rsp+1Ch]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+40h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+8]
    call    fn1
    mov     [rsp+18h],eax
    lea     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+10h]
    call    fn2
    mov     [rsp+5Fh],al
    movzx   eax,byte ptr [rsp+5Fh]
    add     rsp,68h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L1
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L1
L3:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::as_uninit_slice_mut
    inc     qword ptr [jit_record]
    jns     L8
L0:
    sub     rsp,78h
    mov     [rsp+58h],rdi
    mov     rax,[rsp+58h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+58h]
    mov     rdx,[rdx+10h]
    imul    rcx,rdx,8
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+18h],8
    cmp     qword ptr [rsp+18h],0
    je      L3
    jmp     L4
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    mov     rax,[rsp+58h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+28h]
    sub     rdx,rax
    mov     [rsp+30h],rdx
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L6
    jmp     L5
L3:
    mov     qword ptr [rsp+28h],0FFFFFFFFFFFFFFFFh
    jmp     L1
L4:
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+28h],rax
    jmp     L1
L5:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+18h],8
    mov     qword ptr [rsp+10h],4
    lea     rdi,[k0]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+8]
    call    fn1
L6:
    mov     rax,[rsp+38h]
    mov     rdx,[rsp+30h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    add     rsp,78h
    ret
L7:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L8:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::with_capacity
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+38h],rdi
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+58h],0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+38h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::Iter::<'_, u32>::make_slice
    inc     qword ptr [jit_record]
    jns     L13
L0:
    sub     rsp,88h
    mov     [rsp+68h],rdi
    mov     rax,[rsp+68h]
    mov     rax,[rax]
    mov     [rsp+60h],rax
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rdi,[rsp+68h]
    mov     rdi,[rdi+8]
    mov     [rsp+58h],rdi
    jmp     L2
L1:
    mov     rax,[rsp+68h]
    mov     rax,[rax+8]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     rdx,[rdx]
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rax
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L3:
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L12
L5:
    jmp     L2
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    lea     rsi,[k0]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn1
L7:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],4
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L8
    mov     qword ptr [rsp+10h],4
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+26h]
    test    byte ptr [rsp+26h],0FFh
    je      L8
    mov     r10,[rsp+28h]
    sub     r10,[rsp+30h]
    shr     r10,2
    mov     [rsp+58h],r10
    jmp     L4
L8:
    lea     rax,[k2]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k3]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    ud2
L9:
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+8],4
    lea     rdi,[k5]
    mov     [rsp],rdi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    mov     rcx,[rsp+58h]
    mov     r8,[rsp]
    call    fn6
L10:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    add     rsp,88h
    ret
L11:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L12:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L13:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::Iter::<'_, u32>::new
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,78h
    mov     [rsp+50h],rdi
    mov     [rsp+58h],rsi
    mov     rax,[rsp+58h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+50h]
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    mov     rcx,[rsp+20h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+18h],rcx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L1
    mov     [rsp+48h],rax
    jmp     L2
L1:
    mov     rax,[rsp+38h]
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+48h],rax
L2:
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+68h],rdx
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    add     rsp,78h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::from_raw_parts::precondition_check
    inc     qword ptr [jit_record]
    jns     L26
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+80h],rcx
    mov     [rsp+10h],r8
    mov     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+88h]
    call    fn0
    mov     [rsp+66h],al
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    cmp     qword ptr [rsp+90h],0
    je      L14
    jmp     L15
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L4:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L6:
    jmp     L7
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L8:
    lea     rax,[k1]
    mov     qword ptr [rsp+78h],117h
    mov     rsi,[rsp+78h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+20h],117h
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L10:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L7
    jmp     L1
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L12:
    jmp     L7
L13:
    test    byte ptr [rsp+66h],0FFh
    je      L11
    jmp     L9
L14:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L16
L15:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L16:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L18:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L17
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L24:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L25:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L18
L26:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::from_raw_parts_mut::precondition_check
    inc     qword ptr [jit_record]
    jns     L26
L0:
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+88h],rdx
    mov     [rsp+80h],rcx
    mov     [rsp+10h],r8
    mov     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+88h]
    call    fn0
    mov     [rsp+66h],al
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L2:
    cmp     qword ptr [rsp+90h],0
    je      L14
    jmp     L15
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L4:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L6:
    jmp     L7
    nop
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L8:
    lea     rax,[k1]
    mov     qword ptr [rsp+78h],11Bh
    mov     rsi,[rsp+78h]
    lea     rdi,[k2]
    mov     qword ptr [rsp+20h],11Bh
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+50h],rax
    mov     [rsp+58h],r9
    mov     byte ptr [rsp+0Fh],0
    mov     r11,[rsp+10h]
    mov     [rsp],r11
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+58h]
    movzx   edx,byte ptr [rsp+0Fh]
    mov     rcx,[rsp]
    call    qword ptr [sym3]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L10:
    mov     rax,[rsp+98h]
    cmp     rax,0
    sete    [rsp+65h]
    movzx   esi,byte ptr [rsp+65h]
    xor     sil,1
    mov     [rsp+67h],sil
    test    byte ptr [rsp+67h],0FFh
    je      L7
    jmp     L1
    nop     [rax]
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L12:
    jmp     L7
L13:
    test    byte ptr [rsp+66h],0FFh
    je      L11
    jmp     L9
L14:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L16
L15:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+8],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFFF0h
    call    ryo_h_DivUW64
L16:
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+58h]
    setbe   [rsp+66h]
    test    byte ptr [rsp+66h],0FFh
    je      L5
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L17:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L18:
    call    qword ptr [sym4]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L17
L19:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L20:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L21:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L22:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L23:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L24:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L25:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L18
L26:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::slice::stable_sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    inc     qword ptr [jit_record]
    jns     L21
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+28h],rdx
    lea     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Eh],0
    test    byte ptr [rsp+0Eh],0FFh
    je      L7
    jmp     L5
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L2:
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L4:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L6:
    jmp     L1
L7:
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,2
    setb    [rsp+0Fh]
    test    byte ptr [rsp+0Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L9:
    jmp     L5
    nop
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L11:
    jmp     L5
L12:
    jmp     L10
L13:
    cmp     qword ptr [rsp+10h],14h
    setbe   [rsp+0Fh]
    test    byte ptr [rsp+0Fh],0FFh
    je      L14
    mov     qword ptr [rsp],1
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp]
    mov     rcx,[rsp+18h]
    call    fn0
    jmp     L15
L14:
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+18h]
    call    fn1
    jmp     L8
L15:
    jmp     L10
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L3
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L19:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L20:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L21:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,108h
    mov     [rsp+0F8h],rdi
    mov     [rsp+0E8h],rsi
    mov     [rsp+0F0h],rdx
    mov     byte ptr [rsp+9Fh],1
    lea     rdx,[rsp+0E8h]
    mov     [rsp+80h],rdx
    lea     rdi,[rsp+58h]
    mov     rsi,[rsp+80h]
    call    fn0
    mov     rax,[rsp+58h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+78h],rcx
    mov     [rsp+70h],rdx
    mov     [rsp+0E0h],rdx
    cmp     rdx,0
    je      L1
    mov     rdi,[rsp+78h]
    mov     [rsp+68h],rdi
    mov     rdi,[rsp+0F8h]
    mov     rsi,[rsp+68h]
    call    fn1
    mov     rax,[rsp+0F8h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+0F8h]
    lea     rdx,[rdx+10h]
    mov     [rsp+48h],rdx
    mov     rdx,[rdx]
    mov     rsi,[rsp+48h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+9Fh],0
    mov     r8,[rsp+0E8h]
    mov     rcx,[rsp+0F0h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],r8
    mov     [rsp+38h],rax
    mov     rcx,[rsp+58h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rsi
    mov     rcx,[rsp+30h]
    mov     [rsp+8],rcx
    mov     [rsp],rsi
    mov     [rsp+10h],rax
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    lea     rdx,[rsp]
    call    fn2
    add     rsp,108h
    ret
L1:
    lea     rax,[k3]
    mov     qword ptr [rsp+58h],11h
    mov     rsi,[rsp+58h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+20h],11h
    mov     r9,[rsp+20h]
    shl     r9,1
    or      r9,1
    mov     [rsp+60h],rax
    mov     [rsp+68h],r9
    lea     r10,[k5]
    mov     [rsp+10h],r10
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     rdx,[rsp+10h]
    call    qword ptr [sym6]
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L3:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF88h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L5:
    jmp     L2
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L7:
    test    byte ptr [rsp+9Fh],0FFh
    je      L2
    jmp     L4
    ud2
    lea     rdi,[rsp+100h]
    mov     rsi,rax
    mov     edx,0FFFFFF88h
    call    ryo_h_Lpad
    jmp     L6
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L9:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L10:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],esi
    mov     [rsp+34h],edx
    mov     rax,[rsp+38h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx+8]
    imul    rcx,rdx,8
    add     rax,rcx
    mov     rcx,[rsp+30h]
    mov     [rax],rcx
    mov     rsi,[rsp+38h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+38h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<(u32, u32)>::reserve
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     rax,[rsp+68h]
    mov     rax,[rax+10h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,0
    je      L7
    jmp     L8
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+38h]
    call    qword ptr [sym1]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    add     rsp,78h
    ret
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    mov     rax,[rsp+18h]
    sub     rax,[rsp+48h]
    cmp     rax,[rsp+60h]
    setb    [rsp+2Fh]
    test    byte ptr [rsp+2Fh],0FFh
    je      L3
    jmp     L1
L7:
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    jmp     L5
L8:
    mov     rax,[rsp+40h]
    mov     rax,[rax]
    mov     [rsp+18h],rax
    jmp     L5
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<T, A>::set_len::precondition_check
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L1
    add     rsp,98h
    ret
L1:
    lea     rax,[k0]
    mov     qword ptr [rsp+78h],0C6h
    mov     rsi,[rsp+78h]
    lea     rdi,[k1]
    mov     qword ptr [rsp+28h],0C6h
    mov     r9,[rsp+28h]
    shl     r9,1
    or      r9,1
    mov     [rsp+58h],rax
    mov     [rsp+60h],r9
    mov     byte ptr [rsp+17h],0
    mov     r11,[rsp+18h]
    mov     [rsp+8],r11
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    ud2
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::append_elements
    inc     qword ptr [jit_record]
    jns     L6
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+50h]
    call    fn0
    mov     rax,[rsp+68h]
    mov     rax,[rax+10h]
    mov     [rsp+48h],rax
    mov     rcx,1FFFFFFFFFFFFFFFh
    cmp     rax,rcx
    setbe   [rsp+47h]
    cmp     qword ptr [rsp+50h],0
    jbe     L1
    mov     rsi,[rsp+58h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+68h]
    mov     rdi,[rdi+8]
    imul    rcx,rax,4
    add     rdi,rcx
    mov     [rsp+30h],rdi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    mov     rax,[rsp+68h]
    mov     rax,[rax+10h]
    add     rax,[rsp+50h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+68h]
    mov     rcx,[rsp+10h]
    mov     [rdx+10h],rcx
    add     rsp,78h
    ret
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+10h],4
    lea     r8,[k1]
    mov     [rsp+8],r8
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+18h]
    mov     rcx,[rsp+10h]
    mov     r8,[rsp+50h]
    mov     r9,[rsp+8]
    call    fn2
L4:
    imul    rax,[rsp+50h],4
    mov     [rsp+18h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memcpy
    jmp     L1
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::clear
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,38h
    mov     [rsp+28h],rdi
    mov     rax,[rsp+28h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx+10h]
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    mov     qword ptr [rsp],0
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     r9,[rsp+20h]
    mov     [rsp+10h],r9
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    qword ptr [sym0]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::extend_from_slice
    inc     qword ptr [jit_record]
    jns     L7
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     [rsp+18h],rsi
    mov     rcx,[rsp+18h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+10h],rcx
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+7],0
    test    byte ptr [rsp+7],0FFh
    je      L4
    jmp     L3
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L2:
    add     rsp,78h
    ret
L3:
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    jmp     L5
L4:
    mov     rax,[rsp+38h]
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+20h],rax
L5:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+20h]
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+50h]
    call    fn0
    jmp     L1
L6:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    inc     qword ptr [jit_record]
    jns     L11
L0:
    sub     rsp,138h
    mov     [rsp+128h],rdi
    mov     [rsp+38h],rsi
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF08h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    mov     byte ptr [rsp+0C7h],1
    lea     rdx,[rsp+110h]
    mov     [rsp+0A8h],rdx
    lea     rdi,[rsp+80h]
    mov     rsi,[rsp+0A8h]
    call    fn0
    mov     rax,[rsp+80h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+88h]
    mov     rcx,[rsp+90h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rdx
    mov     [rsp+108h],rdx
    cmp     rdx,0
    je      L1
    mov     rdi,[rsp+0A0h]
    mov     [rsp+90h],rdi
    mov     rdi,[rsp+128h]
    mov     rsi,[rsp+90h]
    call    fn1
    mov     rax,[rsp+128h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+128h]
    lea     rdx,[rdx+10h]
    mov     [rsp+70h],rdx
    mov     rdx,[rdx]
    mov     rsi,[rsp+70h]
    mov     [rsp+80h],rdx
    mov     byte ptr [rsp+0C7h],0
    mov     r8,[rsp+110h]
    mov     [rsp+60h],r8
    mov     r9,[rsp+118h]
    mov     [rsp+68h],r9
    mov     r10,[rsp+120h]
    mov     [rsp+70h],r10
    mov     [rsp+58h],rax
    mov     rcx,[rsp+80h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rsi
    mov     rcx,[rsp+68h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],r8
    mov     [rsp+30h],r10
    mov     rcx,[rsp+50h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rsi
    mov     [rsp+18h],rax
    lea     rdi,[rsp+20h]
    lea     rsi,[rsp+8]
    call    fn2
    add     rsp,138h
    ret
L1:
    lea     rax,[k3]
    mov     qword ptr [rsp+80h],11h
    mov     rsi,[rsp+80h]
    lea     rdi,[k4]
    mov     qword ptr [rsp+48h],11h
    mov     r9,[rsp+48h]
    shl     r9,1
    or      r9,1
    mov     [rsp+88h],rax
    mov     [rsp+90h],r9
    lea     r10,[k5]
    mov     [rsp+30h],r10
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     rdx,[rsp+30h]
    call    qword ptr [sym6]
    ud2
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L3:
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFF80h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L5:
    jmp     L2
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L7:
    test    byte ptr [rsp+0C7h],0FFh
    je      L2
    jmp     L4
    ud2
    lea     rdi,[rsp+130h]
    mov     rsi,rax
    mov     edx,0FFFFFF80h
    call    ryo_h_Lpad
    jmp     L6
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L9:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L10:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L11:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+38h],rdi
    mov     [rsp+34h],esi
    mov     rax,[rsp+38h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx+8]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     ecx,[rsp+34h]
    mov     [rax],ecx
    mov     rsi,[rsp+38h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+38h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    add     rsp,48h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::push
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+14h],esi
    mov     rdi,[rsp+18h]
    mov     esi,[rsp+14h]
    call    fn0
    mov     [rsp+8],rax
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::push_mut
    inc     qword ptr [jit_record]
    jns     L18
L0:
    sub     rsp,68h
    mov     [rsp+50h],rdi
    mov     [rsp+4Ch],esi
    mov     rax,[rsp+50h]
    mov     rax,[rax+10h]
    mov     [rsp+20h],rax
    mov     qword ptr [rsp],4
    cmp     qword ptr [rsp],0
    je      L11
    jmp     L12
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L13
L2:
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L3
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L14
L4:
    mov     rax,[rsp+50h]
    mov     rax,[rax+8]
    imul    rcx,[rsp+20h],4
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     edx,[rsp+4Ch]
    mov     [rsp+1Ch],edx
    mov     ecx,[rsp+1Ch]
    mov     [rax],ecx
    mov     rsi,[rsp+20h]
    add     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+50h]
    mov     rcx,[rsp]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+38h]
    mov     [rsp+58h],r8
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L15
L6:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L8:
    jmp     L5
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L10:
    mov     rax,[rsp+20h]
    cmp     rax,[rsp+10h]
    je      L1
    jmp     L3
L11:
    mov     qword ptr [rsp+10h],0FFFFFFFFFFFFFFFFh
    jmp     L9
L12:
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    jmp     L9
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L7
L13:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L14:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L15:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L16:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L17:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L18:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::reserve
    inc     qword ptr [jit_record]
    jns     L12
L0:
    sub     rsp,78h
    mov     [rsp+68h],rdi
    mov     [rsp+60h],rsi
    mov     rax,[rsp+68h]
    mov     rax,[rax+10h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    cmp     rax,0
    je      L7
    jmp     L8
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L2:
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+38h]
    call    qword ptr [sym1]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L10
L4:
    add     rsp,78h
    ret
    xchg    ax,ax
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L11
L6:
    mov     rax,[rsp+18h]
    sub     rax,[rsp+48h]
    cmp     rax,[rsp+60h]
    setb    [rsp+2Fh]
    test    byte ptr [rsp+2Fh],0FFh
    je      L3
    jmp     L1
L7:
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    jmp     L5
L8:
    mov     rax,[rsp+40h]
    mov     rax,[rax]
    mov     [rsp+18h],rax
    jmp     L5
L9:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L10:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L11:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L12:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<u32>::with_capacity
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,68h
    mov     [rsp+38h],rdi
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn1
    mov     [rsp+18h],rax
    mov     [rsp+20h],rdx
    mov     rax,[rsp+18h]
    mov     rcx,[rsp+20h]
    mov     [rsp+30h],rcx
    mov     rcx,[rsp+30h]
    mov     [rsp+50h],rcx
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+58h],0
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+38h]
    add     rsp,68h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u32>>::eq
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     rax,[rsp+60h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx+10h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+58h]
    mov     rsi,[rsi+8]
    mov     rdi,[rsp+58h]
    mov     rdi,[rdi+10h]
    mov     [rsp+28h],rdi
    mov     [rsp+30h],rsi
    mov     [rsp+38h],rdi
    mov     r8,[rsp+40h]
    cmp     r8,[rsp+28h]
    jne     L1
    mov     [rsp+18h],rax
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+40h]
    call    fn0
    mov     [rsp+6Fh],al
    jmp     L2
L1:
    mov     byte ptr [rsp+6Fh],0
L2:
    movzx   eax,byte ptr [rsp+6Fh]
    add     rsp,78h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

