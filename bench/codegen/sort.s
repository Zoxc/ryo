fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <&u32 as std::fmt::Debug>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <() as std::process::Termination>::report
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     byte ptr [rbp-1],0
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     qword ptr [rbp-8],20h
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     byte ptr [rbp-1],1
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <(u32, u32) as std::fmt::Debug>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+18h]
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF88h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-70h],0
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-20h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+4]
    mov     [rbp-30h],rdx
    lea     rsi,[rbp-20h]
    mov     [rbp-40h],rsi
    lea     rdi,[rbp-28h]
    mov     [rbp-58h],rdi
    mov     [rbp-50h],rdi
    mov     edi,0FFFFFFB8h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-40h]
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-38h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym7]
L3:
    lea     rax,[rbp-20h]
    mov     [rbp-40h],rax
    lea     rdx,[rbp-30h]
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rdx
    mov     edi,0FFFFFFB8h
    lea     rsi,[k8]
    call    ryo_h_AddrAbs
    mov     rax,[rbp-40h]
    mov     [rbp-80h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[sym9]
    lea     rsi,[site10]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-38h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym11]
L5:
    lea     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     [rbp-80h],rax
    lea     rdi,[sym12]
    lea     rsi,[site13]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-1]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
L7:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <[u32] as std::fmt::Debug>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+20h]
    mov     [rbp-0A0h],rax
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-28h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rax,[rbp-28h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-68h],rdi
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rbp-78h]
    mov     [rbp-68h],rax
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp-10h]
    mov     [rbp-0A0h],rax
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-1]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L4:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
L5:
    mov     rax,[rbp-40h]
    mov     [rbp-60h],rax
    jmp     L7
L6:
    mov     rax,[rbp-48h]
    mov     [rbp-58h],rax
    imul    rcx,[rbp-40h],4
    add     rax,rcx
    mov     [rbp-50h],rax
    mov     [rbp-60h],rax
L7:
    mov     rax,[rbp-48h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-0A0h],rsi
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn6
    nop     [rcx-10h]
    jmp     L2

fn <alloc::raw_vec::RawVec<(u32, u32)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <alloc::raw_vec::RawVec<u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    mov     [rbp-18h],rsi
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     [rbp-20h],rax
    mov     [rbp-28h],rdx
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     qword ptr [rbp-50h],8
    mov     qword ptr [rbp-48h],4
    mov     [rbp-40h],rsi
    mov     edi,0FFFFFFC8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
L0:
    imul    rax,[rbp-18h],8
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFD0h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    mov     [rbp-18h],rsi
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     [rbp-20h],rax
    mov     [rbp-28h],rdx
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     qword ptr [rbp-50h],4
    mov     qword ptr [rbp-48h],4
    mov     [rbp-40h],rsi
    mov     edi,0FFFFFFC8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
L0:
    imul    rax,[rbp-18h],4
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFD0h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::slice::sort::stable::merge::MergeState<(u32, u32)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-8],rdx
    mov     [rbp-28h],rdx
    mov     [rbp-30h],rax
    mov     byte ptr [rbp-41h],1
    test    byte ptr [rbp-41h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-28h],rdx
    mov     byte ptr [rbp-41h],1
    test    byte ptr [rbp-41h],0FFh
    je      L7
    jmp     L6
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-40h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-10h]
L2:
    mov     qword ptr [rbp-48h],0
    cmp     qword ptr [rbp-48h],8
    setb    [rbp-31h]
    test    byte ptr [rbp-31h],0FFh
    je      L3
    mov     qword ptr [rbp-48h],8
    mov     r8,[rbp-48h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-32h]
    test    byte ptr [rbp-32h],0FFh
    je      L3
    mov     r10,[rbp-30h]
    sub     r10,[rbp-28h]
    mov     [rbp-18h],r10
    mov     qword ptr [rbp-48h],8
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFB8h
    call    ryo_h_DivUW64
    jmp     L0
L3:
    mov     edi,0FFFFFF80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],49h
    mov     edi,0FFFFFF90h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-10h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp-10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-38h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     qword ptr [rbp-70h],8
    mov     qword ptr [rbp-68h],4
    mov     r8,[rbp-18h]
    mov     [rbp-60h],r8
    mov     edi,0FFFFFFA8h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-10h]
L7:
    imul    rax,[rbp-18h],8
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFB8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-18h],rdx
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     r8,[rbp-8]
    mov     [rbp-20h],r8
    mov     [rbp-28h],rdx
    mov     [rbp-70h],r8
    mov     [rbp-68h],rdx
    mov     qword ptr [rbp-60h],4
    mov     qword ptr [rbp-58h],4
    mov     qword ptr [rbp-50h],1
    mov     edi,0FFFFFFB8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
L0:
    mov     qword ptr [rbp-30h],1
    imul    rdx,[rbp-30h],4
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    push    rbp
    mov     rbp,rsp
    mov     edi,10h
    lea     rsi,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-10h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <std::alloc::Global as std::clone::Clone>::clone
    push    rbp
    mov     rbp,rsp
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::array::IntoIter<usize, 2> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     byte ptr [rbp-21h],0
    test    byte ptr [rbp-21h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-20h],rsi
    mov     [rbp-30h],rsi
    mov     edi,0FFFFFFD8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    jmp     L0

fn <std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::hint::select_unpredictable::DropOnPanic<*const u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::hint::select_unpredictable::DropOnPanic<*mut u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    lea     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-50h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-48h],rdi
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rbp-30h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-28h]
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-68h],rax
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF90h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-10h],0FFh
    je      L2
    mov     edi,0FFFFFF70h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-60h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-18h]
    mov     [rax],rcx
    mov     rdx,[rbp-28h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L3:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L3

fn <std::iter::Enumerate<std::slice::Iter<'_, u32>> as std::iter::Iterator>::fold::<u64, {closure@bench/sort.rs:46:37: 46:51}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFE8h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-28h],rax
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-38h],rdx
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE8h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::collect::<std::vec::Vec<u32>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     edi,0FFFFFF50h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     edi,0FFFFFFF0h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,28h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-38h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFD0h
    mov     edx,20h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFE8h
    mov     esi,28h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::size_hint
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    lea     rax,[rax+8]
    mov     [rbp-20h],rax
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::collect::<std::vec::Vec<(u32, u32)>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     edi,0FFFFFF60h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD8h
    mov     esi,20h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD8h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFE8h
    mov     esi,20h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::size_hint
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     byte ptr [rbp-9],1
    nop     [rax]
L0:
    lea     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-28h]
    mov     rax,[rbp-28h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    lea     rdx,[rbp+20h]
    mov     [rbp-38h],rdx
    mov     byte ptr [rbp-9],0
    mov     [rbp-40h],rax
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rax
    call    fn1
    nop     [rcx-8]
    mov     byte ptr [rbp-9],1
    jmp     L0
L3:
    lea     rax,[rbp+20h]
    mov     [rbp-48h],rax
    mov     [rbp-60h],rax
    call    fn2
    nop     [rcx-48h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L4:
    lea     rax,[rbp+20h]
    mov     [rbp-48h],rax
    mov     [rbp-60h],rax
    call    fn3
    nop     [rcx-48h]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L6:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rbp-9],0FFh
    je      L4
    jmp     L6
L8:
    call    ryo_h_Unreachable
    ud2
    nop
L9:
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx-40h]
    jmp     L11
L10:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L11:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L7
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L5
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9

fn <std::ops::Range<usize> as std::iter::Iterator>::map::<u32, {closure@bench/sort.rs:52:37: 52:40}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<usize> as std::iter::range::RangeIteratorImpl>::spec_next
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-28h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    call    fn0
    nop     [rcx-11h]
    test    byte ptr [rbp-11h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-20h],rdx
    mov     [rbp-40h],rdx
    mov     qword ptr [rbp-38h],1
    call    fn1
    nop     [rcx-28h]
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-28h]
    mov     [rax],rcx
    mov     rdx,[rbp-20h]
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-10h],1
    jmp     L1
L0:
    mov     qword ptr [rbp-10h],0
L1:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::Range<usize> as std::slice::SliceIndex<[T]>>::get_unchecked_mut::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    cmp     rax,[rbp+10h]
    jb      L0
    mov     rdx,[rbp+20h]
    cmp     rdx,rax
    jb      L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DAh
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0DAh
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+28h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+28h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-20h],rdx
    cmp     rax,rdx
    jb      L4
    jmp     L5
    nop     [rax]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-68h],rax
    imul    rcx,[rbp-20h],4
    add     rax,rcx
    mov     [rbp-70h],rax
    mov     [rbp-50h],rax
    mov     rsi,[rbp-38h]
    mov     [rbp-48h],rsi
    mov     [rbp-10h],rax
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rax
    mov     rdi,[rbp+30h]
    mov     [rbp-88h],rdi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    jmp     L1
L5:
    mov     rax,[rbp-18h]
    sub     rax,[rbp-20h]
    mov     [rbp-40h],rax
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-30h],1
    mov     [rbp-38h],rax
    mov     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    cmp     rsi,[rbp-18h]
    jae     L0
    jmp     L1

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+28h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-20h],rdx
    cmp     rax,rdx
    jb      L4
    jmp     L5
    nop     [rax]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-68h],rax
    imul    rcx,[rbp-20h],4
    add     rax,rcx
    mov     [rbp-70h],rax
    mov     [rbp-50h],rax
    mov     rsi,[rbp-38h]
    mov     [rbp-48h],rsi
    mov     [rbp-10h],rax
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rax
    mov     rdi,[rbp+30h]
    mov     [rbp-88h],rdi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    jmp     L1
L5:
    mov     rax,[rbp-18h]
    sub     rax,[rbp-20h]
    mov     [rbp-40h],rax
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-30h],1
    mov     [rbp-38h],rax
    mov     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    cmp     rsi,[rbp-18h]
    jae     L0
    jmp     L1

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    cmp     rdx,rax
    jae     L2
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-68h],rdi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-20h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-20h]
    sub     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     [rbp-50h],rdx
    imul    rcx,[rbp-18h],4
    add     rdx,rcx
    mov     [rbp-58h],rdx
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-10h],rdx
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    cmp     rdx,rax
    jae     L2
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-68h],rdi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-20h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-20h]
    sub     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     [rbp-50h],rdx
    imul    rcx,[rbp-18h],4
    add     rdx,rcx
    mov     [rbp-58h],rdx
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rax
    mov     [rbp-10h],rdx
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+20h]
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-20h],0
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::slice::Iter<'_, u32> as std::iter::IntoIterator>::into_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::enumerate
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE8h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-8],0
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    cmp     rsi,0
    sete    [rbp-39h]
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rdx
    mov     [rbp-58h],rax
    cmp     rdx,rax
    sete    [rbp-39h]
L1:
    test    byte ptr [rbp-39h],0FFh
    je      L2
    mov     byte ptr [rbp-2Ah],0
    lea     rsi,[rbp+20h]
    mov     [rbp-80h],rsi
    mov     [rbp-0A0h],rsi
    call    fn0
    nop     [rcx-80h]
    jmp     L7
L2:
    mov     byte ptr [rbp-2Ah],0
    mov     byte ptr [rbp-29h],1
    mov     qword ptr [rbp-18h],0
    mov     byte ptr [rbp-79h],0
    test    byte ptr [rbp-79h],0FFh
    je      L3
    mov     r9,[rbp+18h]
    mov     [rbp-40h],r9
    mov     [rbp-20h],r9
    jmp     L4
L3:
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-48h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-58h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-60h],rsi
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
L4:
    lea     rax,[rbp+20h]
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-29h],0
    mov     rsi,[rbp+10h]
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-18h]
    mov     [rbp-68h],rdi
    mov     [rbp-78h],rsi
    imul    rcx,rdi,4
    add     rsi,rcx
    mov     [rbp-70h],rsi
    mov     [rbp-58h],rsi
    mov     [rbp-50h],rsi
    mov     [rbp-28h],rsi
    mov     [rbp-48h],rsi
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rsi
    call    fn1
    nop     [rcx-20h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
L5:
    lea     rax,[rbp+20h]
    mov     [rbp-80h],rax
    mov     [rbp-0A0h],rax
    call    fn2
    nop     [rcx-80h]
    jmp     L7
    nop     [rax]
L6:
    jmp     L4
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L8:
    lea     rax,[rbp+20h]
    mov     [rbp-80h],rax
    mov     [rbp-0A0h],rax
    call    fn3
    nop     [rcx-80h]
    jmp     L13
    nop     [rax]
L9:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L10:
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    test    byte ptr [rbp-29h],0FFh
    je      L8
    jmp     L10
    nop     [rax+rax]
L12:
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    test    byte ptr [rbp-2Ah],0FFh
    je      L9
    jmp     L12
    nop     [rax+rax]
L14:
    jmp     L4
L15:
    mov     rax,[rbp-40h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-70h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     edi,0FFFFFF70h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-2Ah]
L16:
    mov     qword ptr [rbp-80h],0
    cmp     qword ptr [rbp-80h],4
    setb    [rbp-61h]
    test    byte ptr [rbp-61h],0FFh
    je      L17
    mov     qword ptr [rbp-80h],4
    mov     r8,[rbp-80h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-62h]
    test    byte ptr [rbp-62h],0FFh
    je      L17
    mov     r10,[rbp-60h]
    sub     r10,[rbp-58h]
    mov     [rbp-20h],r10
    mov     qword ptr [rbp-80h],4
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L14
L17:
    mov     edi,0FFFFFF60h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-98h],49h
    mov     edi,0FFFFFF70h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx-2Ah]
    jmp     L19
L18:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym10]
L19:
    call    ryo_h_Unreachable
    ud2
L20:
    mov     rax,[rbp-18h]
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],1
    mov     edi,0FFFFFF70h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-2Ah]
L21:
    mov     rax,[rbp-18h]
    add     rax,1
    mov     [rbp-40h],rax
    mov     [rbp-18h],rax
    mov     [rbp-48h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-50h],rdx
    cmp     rax,rdx
    je      L5
    jmp     L6
L22:
    lea     rdi,[sym13]
    lea     rsi,[site14]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L23
    call    rax
    nop     [rcx-78h]
    jmp     L24
L23:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym15]
L24:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L13
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L22

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-0A1h],0
    test    byte ptr [rbp-0A1h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    mov     [rbp-58h],rsi
    mov     [rbp-50h],rsi
    cmp     rsi,0
    sete    [rbp-41h]
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-60h],rax
    cmp     rdx,rax
    sete    [rbp-41h]
L1:
    test    byte ptr [rbp-41h],0FFh
    je      L2
    mov     byte ptr [rbp-32h],0
    mov     rsi,[rbp+20h]
    mov     [rbp-8],rsi
    jmp     L7
L2:
    mov     byte ptr [rbp-32h],0
    mov     byte ptr [rbp-31h],1
    mov     rsi,[rbp+20h]
    mov     [rbp-48h],rsi
    mov     qword ptr [rbp-20h],0
    mov     byte ptr [rbp-0A1h],0
    test    byte ptr [rbp-0A1h],0FFh
    je      L3
    mov     r10,[rbp+18h]
    mov     [rbp-50h],r10
    mov     [rbp-28h],r10
    jmp     L4
L3:
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-58h],rdx
    mov     [rbp-60h],rax
    mov     [rbp-68h],rdx
    mov     rsi,[rbp-50h]
    mov     [rbp-70h],rsi
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L16
    jmp     L15
    xchg    ax,ax
L4:
    lea     rax,[rbp+28h]
    mov     [rbp-58h],rax
    mov     byte ptr [rbp-31h],0
    mov     rsi,[rbp-48h]
    mov     [rbp-70h],rsi
    mov     rdi,[rbp+10h]
    mov     [rbp-88h],rdi
    mov     r8,[rbp-20h]
    mov     [rbp-90h],r8
    mov     [rbp-0A0h],rdi
    imul    rcx,r8,4
    add     rdi,rcx
    mov     [rbp-98h],rdi
    mov     [rbp-80h],rdi
    mov     [rbp-78h],rdi
    mov     [rbp-30h],rdi
    mov     [rbp-68h],rsi
    mov     [rbp-60h],rdi
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rsi
    mov     [rbp-0B0h],rdi
    call    fn0
    nop     [rcx-50h]
    mov     rax,[rbp-50h]
    mov     [rbp-48h],rax
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    xchg    ax,ax
L5:
    mov     rax,[rbp-48h]
    mov     [rbp-8],rax
    jmp     L7
    nop     [rax+rax]
L6:
    jmp     L4
L7:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop
L8:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    mov     edi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L10:
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    test    byte ptr [rbp-31h],0FFh
    je      L8
    jmp     L10
    nop     [rax+rax]
L12:
    jmp     L9
L13:
    test    byte ptr [rbp-32h],0FFh
    je      L9
    jmp     L12
    nop     [rax+rax]
L14:
    jmp     L4
L15:
    mov     rax,[rbp-50h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-80h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    mov     edi,0FFFFFF50h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-32h]
L16:
    mov     qword ptr [rbp-0A8h],0
    cmp     qword ptr [rbp-0A8h],4
    setb    [rbp-71h]
    test    byte ptr [rbp-71h],0FFh
    je      L17
    mov     qword ptr [rbp-0A8h],4
    mov     r8,[rbp-0A8h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-72h]
    test    byte ptr [rbp-72h],0FFh
    je      L17
    mov     r10,[rbp-70h]
    sub     r10,[rbp-68h]
    mov     [rbp-28h],r10
    mov     qword ptr [rbp-0A8h],4
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF58h
    call    ryo_h_DivUW64
    jmp     L14
L17:
    mov     edi,0FFFFFF40h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B8h],49h
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx-32h]
    jmp     L19
L18:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L19:
    call    ryo_h_Unreachable
    ud2
L20:
    mov     rax,[rbp-20h]
    mov     [rbp-0C0h],rax
    mov     qword ptr [rbp-0B8h],1
    mov     edi,0FFFFFF50h
    lea     rsi,[k8]
    call    ryo_h_AddrAbs
    call    fn9
    nop     [rcx-32h]
L21:
    mov     rax,[rbp-20h]
    add     rax,1
    mov     [rbp-50h],rax
    mov     [rbp-20h],rax
    mov     [rbp-58h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-60h],rdx
    cmp     rax,rdx
    je      L5
    jmp     L6
    mov     rdi,rax
    mov     esi,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L11

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::map::<(u32, u32), {closure@bench/sort.rs:59:50: 59:54}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-40h],rdx
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L1
    mov     [rbp-48h],rdx
    cmp     rdx,0
    jne     L0
    mov     qword ptr [rbp-8],0
    jmp     L4
L0:
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-30h],rdx
    mov     [rbp-58h],rax
    cmp     rdx,rax
    sete    [rbp-41h]
    test    byte ptr [rbp-41h],0FFh
    je      L2
    mov     qword ptr [rbp-8],0
    jmp     L4
L2:
    mov     qword ptr [rbp-60h],1
    mov     rdx,[rbp-30h]
    imul    rcx,[rbp-60h],4
    add     rdx,rcx
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-48h]
    mov     [rsi],rcx
    nop     [rax+rax]
L3:
    mov     rax,[rbp-38h]
    mov     [rbp-50h],rax
    mov     [rbp-48h],rax
    mov     [rbp-8],rax
    jmp     L4
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L5:
    mov     rax,[rbp-48h]
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-78h],1
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-28h]
L6:
    mov     rax,[rbp-48h]
    sub     rax,1
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rdx+8],rcx
    jmp     L3

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-30h],rdx
    mov     [rbp-38h],rax
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-48h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L4
    jmp     L3
    xchg    ax,ax
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-30h],rdx
    mov     qword ptr [rbp-38h],1
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    jmp     L1
L3:
    mov     rax,[rbp-28h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-58h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-20h]
L4:
    mov     qword ptr [rbp-60h],0
    cmp     qword ptr [rbp-60h],4
    setb    [rbp-49h]
    test    byte ptr [rbp-49h],0FFh
    je      L5
    mov     qword ptr [rbp-60h],4
    mov     r8,[rbp-60h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-4Ah]
    test    byte ptr [rbp-4Ah],0FFh
    je      L5
    mov     r10,[rbp-48h]
    sub     r10,[rbp-40h]
    mov     [rbp-20h],r10
    mov     qword ptr [rbp-60h],4
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_DivUW64
    jmp     L2
L5:
    mov     edi,0FFFFFF80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],49h
    mov     edi,0FFFFFF90h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-20h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L7:
    call    ryo_h_Unreachable
    ud2

fn <std::vec::Vec<(u32, u32)> as std::iter::FromIterator<(u32, u32)>>::from_iter::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-28h]
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::DerefMut>::deref_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-30h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-20h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-38h],rdx
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-50h],rsi
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-48h],rax
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_extend::SpecExtend<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::spec_extend
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter::SpecFromIter<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter_nested::SpecFromIterNested<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     byte ptr [rbp-21h],1
    lea     rdx,[rbp+10h]
    mov     [rbp-68h],rdx
    mov     [rbp-0E0h],rdx
    call    fn0
    nop     [rcx-60h]
    mov     rax,[rbp-58h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L1
    .long   L4
    .long   L11
L1:
    mov     edi,0FFFFFF80h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],11h
    mov     rdx,[rbp-80h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp-78h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rdx
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF48h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B0h],11h
    mov     rdx,[rbp-0B0h]
    mov     [rbp-0A8h],rdx
    shl     rdx,1
    mov     [rbp-0A0h],rdx
    or      rdx,1
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-88h]
    mov     [rbp-70h],rsi
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-68h],rax
    mov     [rbp-0E0h],rax
    mov     edi,0FFFFFF28h
    lea     rsi,[k7]
    mov     edx,10h
    call    ryo_h_Const
    call    fn8
    nop     [rcx-88h]
    jmp     L10
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFB8h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L6:
    lea     rax,[rbp-48h]
    mov     [rbp-0C0h],rax
    mov     [rbp-0E0h],rax
    call    fn9
    nop     [rcx-0C0h]
    jmp     L9
L7:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L8:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-21h],0FFh
    je      L7
    jmp     L8
L10:
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-38h],0
    lea     rdx,[rbp-48h]
    mov     [rbp-50h],rdx
    mov     byte ptr [rbp-21h],0
    mov     edi,0FFFFFFA0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-0E0h],rax
    mov     edi,0FFFFFF28h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn10
    nop     [rcx-20h]
    jmp     L5
L11:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L12:
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-0B8h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym13]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L12
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::vec::Vec<u32> as std::clone::Clone>::clone
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    lea     rax,[rax+10h]
    mov     [rbp-20h],rax
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-18h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-48h],rdx
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-38h],rdx
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-40h],rax
    call    fn0
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::iter::FromIterator<u32>>::from_iter::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx-30h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFD0h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn1
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::ops::Deref>::deref
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-30h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-30h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-20h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    lea     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     [rbp-40h],rax
    call    fn0
    nop     [rcx-10h]
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-40h],rsi
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::spec_extend
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter::SpecFromIter<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter_nested::SpecFromIterNested<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     byte ptr [rbp-21h],1
    lea     rdx,[rbp+10h]
    mov     [rbp-68h],rdx
    mov     [rbp-0E0h],rdx
    call    fn0
    nop     [rcx-60h]
    mov     rax,[rbp-58h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L1
    .long   L4
    .long   L11
L1:
    mov     edi,0FFFFFF80h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],11h
    mov     rdx,[rbp-80h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp-78h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rdx
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF48h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0B0h],11h
    mov     rdx,[rbp-0B0h]
    mov     [rbp-0A8h],rdx
    shl     rdx,1
    mov     [rbp-0A0h],rdx
    or      rdx,1
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-88h]
    mov     [rbp-70h],rsi
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFF20h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-20h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-68h],rax
    mov     [rbp-0E0h],rax
    mov     edi,0FFFFFF28h
    lea     rsi,[k7]
    mov     edx,10h
    call    ryo_h_Const
    call    fn8
    nop     [rcx-88h]
    jmp     L10
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFB8h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L6:
    lea     rax,[rbp-48h]
    mov     [rbp-0C0h],rax
    mov     [rbp-0E0h],rax
    call    fn9
    nop     [rcx-0C0h]
    jmp     L9
L7:
    mov     edi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L8:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-21h],0FFh
    je      L7
    jmp     L8
L10:
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-38h],0
    lea     rdx,[rbp-48h]
    mov     [rbp-50h],rdx
    mov     byte ptr [rbp-21h],0
    mov     edi,0FFFFFF98h
    mov     esi,10h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-50h]
    mov     [rbp-0E0h],rax
    mov     edi,0FFFFFF28h
    mov     esi,0FFFFFF98h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn10
    nop     [rcx-20h]
    jmp     L5
L11:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L12:
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-0B8h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym13]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L12
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-8],rdx
    mov     rcx,[rbp-10h]
    mov     [rdx],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <u32 as core::slice::cmp::SlicePartialEq<u32>>::equal_same_length
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    imul    rax,[rbp+20h],4
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-20h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    cmp     dword ptr [rbp-8],0
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     qword ptr [rbp-18h],4
    cmp     qword ptr [rbp-18h],8
    setbe   [rbp-1]
    test    byte ptr [rbp-1],0FFh
    je      L0
    mov     qword ptr [rbp-18h],4
    imul    r8,[rbp-18h],20h
    mov     [rbp-10h],r8
    cmp     r8,1000h
    ja      L0
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    call    fn0
    nop     [rcx]
    jmp     L2
L0:
    mov     qword ptr [rbp-18h],4
    imul    rdx,[rbp-18h],30h
    mov     [rbp-10h],rdx
    cmp     rdx,1000h
    ja      L1
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    call    fn1
    nop     [rcx]
    jmp     L2
L1:
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    cmp     rax,2
    jae     L3
    jmp     L4
    nop     [rax]
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-30h],1
    mov     rdx,[rbp+20h]
    mov     [rbp-28h],rdx
    call    fn2
    nop     [rcx]
    jmp     L4
L4:
    jmp     L2

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     qword ptr [rbp-20h],4
    cmp     qword ptr [rbp-20h],8
    setbe   [rbp-9]
    test    byte ptr [rbp-9],0FFh
    je      L0
    mov     qword ptr [rbp-20h],4
    imul    r8,[rbp-20h],20h
    mov     [rbp-18h],r8
    cmp     r8,1000h
    ja      L0
    mov     qword ptr [rbp-8],20h
    jmp     L2
L0:
    mov     qword ptr [rbp-20h],4
    imul    rdx,[rbp-20h],30h
    mov     [rbp-18h],rdx
    cmp     rdx,1000h
    ja      L1
    mov     qword ptr [rbp-8],20h
    jmp     L2
L1:
    mov     qword ptr [rbp-8],10h
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    call    fn0
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <u32 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-58h],rax
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF48h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx-78h]
    jmp     L2
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    mov     [rbp-68h],rax
    mov     rsi,[rbp-10h]
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rsi
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
    nop
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L2:
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-8],0
    cmp     qword ptr [rbp-58h],0
    ja      L0
    jmp     L1
L3:
    mov     rax,[rbp-38h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-80h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    mov     qword ptr [rbp-0B0h],4
    mov     qword ptr [rbp-0A8h],4
    mov     r8,[rbp-58h]
    mov     [rbp-0A0h],r8
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-40h]
L4:
    imul    rax,[rbp-58h],4
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L5
    mov     qword ptr [rbp-88h],4
    cmp     qword ptr [rbp-88h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L5:
    mov     rax,[rbp-58h]
    mov     [rbp-8],rax
    jmp     L1
    nop     [rax]
L6:
    mov     rax,[rbp-58h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-68h]
    mov     [rbp-0B8h],rdx
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-40h]
    jmp     L5
L7:
    mov     qword ptr [rbp-68h],0FFFFFFFFFFFFFFFFh
    jmp     L6
L8:
    mov     rax,[rbp-18h]
    mov     [rbp-70h],rax
    mov     [rbp-68h],rax
    jmp     L6

fn <usize as std::cmp::Ord>::max
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     byte ptr [rbp-9],1
    lea     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     byte ptr [rbp-9],0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rbp-9],0FFh
    je      L3
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::cmp::Ord>::min
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     byte ptr [rbp-9],1
    lea     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    lea     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rdx,[rbp+18h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     byte ptr [rbp-9],0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rbp-9],0FFh
    je      L3
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::iter::Step>::forward_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     byte ptr [rbp-9],1
    test    byte ptr [rbp-9],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-28h],rdi
    mov     edi,0FFFFFFE0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
L0:
    mov     rax,[rbp+10h]
    add     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::iter::Step>::steps_between
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-28h],rdx
    cmp     rdx,rax
    jb      L0
    sub     rdx,rax
    mov     [rbp-38h],rdx
    mov     [rbp-40h],rdx
    mov     qword ptr [rbp-48h],1
    mov     rdi,[rbp-38h]
    mov     [rbp-18h],rdi
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    jmp     L1
L0:
    mov     qword ptr [rbp-18h],0
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    cmp     rdx,rax
    jb      L2
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rax
    mov     rsi,[rbp+28h]
    mov     [rbp-30h],rsi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-11h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp+20h],8
    add     rax,rcx
    mov     [rbp-20h],rax
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    cmp     rax,[rbp+18h]
    jae     L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0D6h
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0D6h
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    lea     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-4]
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn Rng::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     dword ptr [rbp-54h],0Dh
    mov     esi,[rbp-54h]
    mov     [rbp-1Ch],esi
    cmp     esi,40h
    jb      L2
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-4Dh]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-18h]
    shl     rax,0Dh
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-58h],rdx
    xor     rdx,rax
    mov     [rbp-60h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-60h]
    mov     [rsi],rcx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-30h],rdi
    mov     dword ptr [rbp-54h],7
    mov     r9d,[rbp-54h]
    mov     [rbp-34h],r9d
    cmp     r9d,40h
    jb      L5
    mov     edi,0FFFFFF90h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-4Dh]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rbp-30h]
    shr     rax,7
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-58h],rdx
    xor     rdx,rax
    mov     [rbp-60h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-60h]
    mov     [rsi],rcx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-48h],rdi
    mov     dword ptr [rbp-54h],11h
    mov     r9d,[rbp-54h]
    mov     [rbp-4Ch],r9d
    cmp     r9d,40h
    jb      L8
    mov     edi,0FFFFFF90h
    lea     rsi,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[sym9]
    lea     rsi,[site10]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-4Dh]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L7:
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rbp-48h]
    shl     rax,11h
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-58h],rdx
    xor     rdx,rax
    mov     [rbp-60h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-60h]
    mov     [rsi],rcx
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-8],rdi
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn alloc::raw_vec::RawVec::<u32>::grow_one
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     rax,[rax]
    mov     [rbp-28h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rax
    mov     qword ptr [rbp-50h],1
    mov     edi,0FFFFFFB8h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-18h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     edi,0FFFFFFCCh
    mov     esi,0FFFFFFE8h
    mov     rdx,0FFFFFFFFFFFFFFFFh
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFCCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L2:
    .long   L6
    .long   L3
    .long   L7
L3:
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym6]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L7:
    call    ryo_h_Unreachable
    ud2

fn alloc::raw_vec::RawVecInner::with_capacity_in
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     byte ptr [rbp-88h],0
    mov     edi,0FFFFFF80h
    mov     esi,18h
    call    ryo_h_MovW128
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-40h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    mov     rax,[rbp-40h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L7
    .long   L4
    .long   L3
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-20h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-60h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop
L8:
    mov     rax,[rbp-58h]
    sub     rax,0
    mov     [rbp-50h],rax
    cmp     rax,[rbp+10h]
    setb    [rbp-42h]
    movzx   edx,byte ptr [rbp-42h]
    xor     dl,1
    mov     [rbp-41h],dl
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L12
    jmp     L11
L9:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    jmp     L8
L10:
    mov     rax,[rbp-10h]
    mov     [rbp-68h],rax
    mov     [rbp-58h],rax
    jmp     L8
L11:
    movzx   eax,byte ptr [rbp-41h]
    mov     [rbp-90h],al
    mov     edi,0FFFFFF78h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx-28h]
L12:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn checksum
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     edi,0FFFFFFB0h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-30h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx-20h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFE0h
    mov     edx,18h
    call    ryo_h_Copy
    mov     qword ptr [rbp-38h],0
    call    fn2
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn checksum::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+20h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-40h],rdx
    mov     edx,[rdx]
    mov     [rbp-14h],edx
    mov     rsi,[rbp+18h]
    mov     [rbp-50h],rsi
    mov     qword ptr [rbp-48h],1Fh
    call    fn0
    nop     [rcx-20h]
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFECh
    call    ryo_h_ZextW32W64
    mov     rax,[rbp-10h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-30h]
    xor     rdx,rax
    mov     [rbp-28h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    call    fn1
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::num::<impl std::fmt::Debug for u32>::fmt
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     eax,[rax+10h]
    mov     [rbp-0Ch],eax
    and     eax,2000000h
    mov     [rbp-8],eax
    cmp     eax,0
    setne   [rbp-2]
    test    byte ptr [rbp-2],0FFh
    je      L2
    mov     rdi,[rbp+10h]
    mov     [rbp-30h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-28h],r8
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-1]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    jmp     L7
L2:
    mov     rax,[rbp+18h]
    mov     eax,[rax+10h]
    mov     [rbp-0Ch],eax
    and     eax,4000000h
    mov     [rbp-8],eax
    cmp     eax,0
    setne   [rbp-3]
    test    byte ptr [rbp-3],0FFh
    je      L5
    mov     rdi,[rbp+10h]
    mov     [rbp-30h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-28h],r8
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-1]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    jmp     L7
L5:
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-1]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L7:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_debug::<(u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::fmt::rt::Argument::<'_>::new_lower_hex::<u64>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl u64>::wrapping_add
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    add     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl u64>::wrapping_mul
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    imul    rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rbp-20h]
    mov     [rbp-11h],al
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0BAh
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0BAh
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::num::<impl usize>::unchecked_sub::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_SubOvfUW64
    movzx   eax,byte ptr [rbp-20h]
    mov     [rbp-11h],al
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0BAh
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0BAh
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::panicking::assert_failed::<std::vec::Vec<u32>, std::vec::Vec<u32>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    lea     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     edi,0FFFFFFE0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    movzx   eax,byte ptr [rbp+30h]
    mov     [rbp-50h],al
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA0h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+38h]
    mov     [rbp-48h],rax
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [(u32, u32)]>::reverse
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-70h],2
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF90h
    call    ryo_h_DivUW64
    mov     rax,[rbp+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     [rbp-30h],rax
    imul    rcx,[rbp-8],8
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-48h]
    mov     [rbp-58h],rax
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],8
    mov     qword ptr [rbp-90h],4
    mov     rdi,[rbp-50h]
    mov     [rbp-88h],rdi
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-48h]
L2:
    mov     rax,[rbp-30h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-58h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     byte ptr [rbp-69h],0
    test    byte ptr [rbp-69h],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L7
    jmp     L6
L4:
    mov     rax,[rbp-38h]
    mov     [rbp-58h],rax
    jmp     L3
L5:
    mov     rax,[rbp-50h]
    mov     [rbp-68h],rax
    mov     qword ptr [rbp-70h],0
    mov     rsi,[rbp-70h]
    sub     rsi,rax
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-38h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rbp-58h],rdi
    jmp     L3
L6:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],8
    mov     qword ptr [rbp-90h],4
    mov     rdi,[rbp-50h]
    mov     [rbp-88h],rdi
    mov     edi,0FFFFFF80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-48h]
L7:
    mov     rax,[rbp-58h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-60h],rdx
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    call    fn4
    nop     [rcx-28h]
    jmp     L0

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    cmp     rax,[rbp+20h]
    jb      L0
    mov     edi,0FFFFFF40h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-0B0h],rax
    mov     edi,0FFFFFF58h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-68h]
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF98h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFC0h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFA0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],9
    mov     rdx,[rbp-60h]
    mov     [rbp-80h],rdx
    mov     rsi,[rbp-58h]
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFF68h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-90h],9
    mov     rdx,[rbp-90h]
    mov     [rbp-88h],rdx
    shl     rdx,1
    mov     [rbp-80h],rdx
    or      rdx,1
    mov     [rbp-78h],rdx
    mov     [rbp-70h],rdx
    mov     rsi,[rbp-68h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-0B0h],rax
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-20h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L2:
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-28h],rsi
    mov     [rbp-40h],rdx
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L0
    mov     r9,[rbp+20h]
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rax
    mov     r10,[rbp+28h]
    mov     [rbp-0A0h],r10
    call    fn0
    nop     [rcx-20h]
L0:
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L1
    mov     rsi,[rbp-30h]
    mov     [rbp-58h],rsi
    mov     [rbp-0B0h],rsi
    mov     qword ptr [rbp-0A8h],8
    mov     qword ptr [rbp-0A0h],4
    mov     r9,[rbp+20h]
    mov     [rbp-98h],r9
    mov     r10,[rbp+28h]
    mov     [rbp-90h],r10
    call    fn1
    nop     [rcx-30h]
L1:
    mov     rax,[rbp-40h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    imul    rcx,[rbp+20h],8
    add     rsi,rcx
    mov     [rbp-68h],rsi
    mov     rdi,[rbp-38h]
    sub     rdi,[rbp+20h]
    mov     [rbp-70h],rdi
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L2
    mov     [rbp-78h],rsi
    mov     [rbp-0B0h],rsi
    mov     qword ptr [rbp-0A8h],8
    mov     qword ptr [rbp-0A0h],4
    mov     [rbp-98h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-90h],r8
    call    fn2
    nop     [rcx-30h]
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-78h],rdx
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [T]>::reverse::revswap::<(u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     edi,0FFFFFF50h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFF68h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-60h]
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-70h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-58h],0
    nop
L0:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    cmp     rax,[rbp+30h]
    jae     L7
    mov     rdx,[rbp-58h]
    mov     [rbp-60h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-10h],rsi
    cmp     rdx,rsi
    jb      L3
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rsi
    mov     edi,0FFFFFF60h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-78h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp-40h]
    imul    rcx,[rbp-60h],8
    add     rax,rcx
    mov     [rbp-80h],rax
    mov     [rbp-8],rax
    mov     rdx,[rbp+30h]
    sub     rdx,1
    mov     [rbp-70h],rdx
    mov     rsi,[rbp-58h]
    mov     [rbp-78h],rsi
    sub     rdx,rsi
    mov     [rbp-68h],rdx
    mov     rdi,[rbp-48h]
    mov     [rbp-28h],rdi
    cmp     rdx,rdi
    jb      L6
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rdi
    mov     edi,0FFFFFF60h
    lea     rsi,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[sym9]
    lea     rsi,[site10]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-78h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp-50h]
    imul    rcx,[rbp-68h],8
    add     rax,rcx
    mov     [rbp-80h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-70h],rdx
    mov     [rbp-78h],rax
    mov     qword ptr [rbp-88h],8
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF90h
    xor     edx,edx
    mov     ecx,8
    call    ryo_h_LoadCopy
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFF88h
    xor     esi,esi
    mov     edx,0FFFFFF80h
    mov     ecx,8
    call    ryo_h_StoreCopy
    jmp     L8
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L8:
    mov     rax,[rbp-58h]
    add     rax,1
    mov     [rbp-58h],rax
    jmp     L0

fn core::slice::<impl [T]>::reverse::revswap::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     edi,0FFFFFF50h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFF68h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-60h]
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-70h]
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-58h],0
    nop
L0:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    cmp     rax,[rbp+30h]
    jae     L7
    mov     rdx,[rbp-58h]
    mov     [rbp-60h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-10h],rsi
    cmp     rdx,rsi
    jb      L3
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rsi
    mov     edi,0FFFFFF60h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-78h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp-40h]
    imul    rcx,[rbp-60h],4
    add     rax,rcx
    mov     [rbp-80h],rax
    mov     [rbp-8],rax
    mov     rdx,[rbp+30h]
    sub     rdx,1
    mov     [rbp-70h],rdx
    mov     rsi,[rbp-58h]
    mov     [rbp-78h],rsi
    sub     rdx,rsi
    mov     [rbp-68h],rdx
    mov     rdi,[rbp-48h]
    mov     [rbp-28h],rdi
    cmp     rdx,rdi
    jb      L6
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rdi
    mov     edi,0FFFFFF60h
    lea     rsi,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[sym9]
    lea     rsi,[site10]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-78h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp-50h]
    imul    rcx,[rbp-68h],4
    add     rax,rcx
    mov     [rbp-80h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-70h],rdx
    mov     [rbp-78h],rax
    mov     qword ptr [rbp-88h],4
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF90h
    xor     edx,edx
    mov     ecx,4
    call    ryo_h_LoadCopy
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFF88h
    xor     esi,esi
    mov     edx,0FFFFFF80h
    mov     ecx,4
    call    ryo_h_StoreCopy
    jmp     L8
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L8:
    mov     rax,[rbp-58h]
    add     rax,1
    mov     [rbp-58h],rax
    jmp     L0

fn core::slice::<impl [T]>::split_at_mut_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    cmp     rax,[rbp+10h]
    jb      L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DDh
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0DDh
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    cmp     rax,[rbp+10h]
    jae     L0
    mov     rdx,[rbp+20h]
    cmp     rdx,[rbp+10h]
    jae     L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DAh
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0DAh
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+28h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [u32]>::copy_from_slice
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [u32]>::iter
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     edi,0FFFFFFE0h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [u32]>::reverse
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-70h],2
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF90h
    call    ryo_h_DivUW64
    mov     rax,[rbp+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     [rbp-30h],rax
    imul    rcx,[rbp-8],4
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-48h]
    mov     [rbp-58h],rax
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],4
    mov     rdi,[rbp-50h]
    mov     [rbp-88h],rdi
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-48h]
L2:
    mov     rax,[rbp-30h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-58h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     byte ptr [rbp-69h],0
    test    byte ptr [rbp-69h],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L7
    jmp     L6
L4:
    mov     rax,[rbp-38h]
    mov     [rbp-58h],rax
    jmp     L3
L5:
    mov     rax,[rbp-50h]
    mov     [rbp-68h],rax
    mov     qword ptr [rbp-70h],0
    mov     rsi,[rbp-70h]
    sub     rsi,rax
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-38h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-58h],rdi
    jmp     L3
L6:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],4
    mov     rdi,[rbp-50h]
    mov     [rbp-88h],rdi
    mov     edi,0FFFFFF80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-48h]
L7:
    mov     rax,[rbp-58h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-60h],rdx
    mov     [rbp-28h],rax
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    call    fn4
    nop     [rcx-28h]
    jmp     L0

fn core::slice::<impl [u32]>::sort_unstable
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    lea     rax,[rbp]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFE0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-8]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [u32]>::split_at_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    cmp     rax,[rbp+20h]
    jb      L0
    mov     edi,0FFFFFF40h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-0B0h],rax
    mov     edi,0FFFFFF58h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-68h]
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF98h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFC0h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFA0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],9
    mov     rdx,[rbp-60h]
    mov     [rbp-80h],rdx
    mov     rsi,[rbp-58h]
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFF68h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-90h],9
    mov     rdx,[rbp-90h]
    mov     [rbp-88h],rdx
    shl     rdx,1
    mov     [rbp-80h],rdx
    or      rdx,1
    mov     [rbp-78h],rdx
    mov     [rbp-70h],rdx
    mov     rsi,[rbp-68h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-0B0h],rax
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-20h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L2:
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-28h],rsi
    mov     [rbp-40h],rdx
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L0
    mov     r9,[rbp+20h]
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rax
    mov     r10,[rbp+28h]
    mov     [rbp-0A0h],r10
    call    fn0
    nop     [rcx-20h]
L0:
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L1
    mov     rsi,[rbp-30h]
    mov     [rbp-58h],rsi
    mov     [rbp-0B0h],rsi
    mov     qword ptr [rbp-0A8h],4
    mov     qword ptr [rbp-0A0h],4
    mov     r9,[rbp+20h]
    mov     [rbp-98h],r9
    mov     r10,[rbp+28h]
    mov     [rbp-90h],r10
    call    fn1
    nop     [rcx-30h]
L1:
    mov     rax,[rbp-40h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    imul    rcx,[rbp+20h],4
    add     rsi,rcx
    mov     [rbp-68h],rsi
    mov     rdi,[rbp-38h]
    sub     rdi,[rbp+20h]
    mov     [rbp-70h],rdi
    mov     byte ptr [rbp-81h],1
    test    byte ptr [rbp-81h],0FFh
    je      L2
    mov     [rbp-78h],rsi
    mov     [rbp-0B0h],rsi
    mov     qword ptr [rbp-0A8h],4
    mov     qword ptr [rbp-0A0h],4
    mov     [rbp-98h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-90h],r8
    call    fn2
    nop     [rcx-30h]
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-78h],rdx
    mov     [rbp-60h],rax
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE0h
    mov     esi,20h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [u32]>::swap
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+20h]
    cmp     rdx,rax
    jb      L2
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rax
    mov     rsi,[rbp+30h]
    mov     [rbp-30h],rsi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-0Ah]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+28h]
    cmp     rax,[rbp-8]
    jb      L5
    mov     [rbp-40h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-30h],rsi
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-0Ah]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-20h],rsi
    call    fn6
    nop     [rcx-0Ah]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::<impl [u32]>::swap_unchecked
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     byte ptr [rbp-19h],1
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    mov     [rbp-8],rsi
    mov     [rbp-40h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-38h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-30h],r8
    mov     r9,[rbp+30h]
    mov     [rbp-28h],r9
    call    fn0
    nop     [rcx]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rdx
    mov     [rbp-8],rax
    imul    rcx,[rbp+20h],4
    add     rax,rcx
    mov     [rbp-10h],rax
    mov     rsi,[rbp-8]
    imul    rcx,[rbp+28h],4
    add     rsi,rcx
    mov     [rbp-18h],rsi
    mov     [rbp-40h],rax
    mov     [rbp-38h],rsi
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::copy_from_slice_impl::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-10h],rdx
    cmp     rax,rdx
    je      L2
    mov     [rbp-90h],rax
    mov     [rbp-88h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-80h],rsi
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-18h],rdx
    mov     [rbp-38h],rax
    mov     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-28h],rdi
    mov     [rbp-40h],rsi
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L3
    mov     r10,[rbp-20h]
    mov     [rbp-48h],r10
    mov     r11,[rbp-30h]
    mov     [rbp-50h],r11
    mov     [rbp-90h],r10
    mov     [rbp-88h],r11
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     r8,[rbp-8]
    mov     [rbp-70h],r8
    mov     edi,0FFFFFF98h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-30h]
L3:
    imul    rax,[rbp-8],4
    mov     [rbp-58h],rax
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::index::<impl std::ops::Index<std::ops::Range<usize>> for [u32]>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     edi,0FFFFFFD0h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::index::<impl std::ops::Index<std::ops::RangeFrom<usize>> for [u32]>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-18h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeFrom<usize>> for [u32]>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-18h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeTo<usize>> for [u32]>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+28h]
    mov     [rbp-18h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::find_existing_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    cmp     rax,2
    jae     L0
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-8],0
    jmp     L10
L0:
    mov     qword ptr [rbp-18h],2
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    test    byte ptr [rbp-21h],0FFh
    je      L6
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp-18h]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    jae     L5
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L3:
    test    byte ptr [rbp-23h],0FFh
    je      L4
    mov     rdx,[rbp-18h]
    add     rdx,1
    mov     [rbp-18h],rdx
    jmp     L2
L4:
    jmp     L5
L5:
    jmp     L9
    nop     [rax+rax]
L6:
    mov     rax,[rbp-18h]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    jae     L9
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L7:
    test    byte ptr [rbp-23h],0FFh
    je      L8
    jmp     L9
L8:
    mov     rax,[rbp-18h]
    add     rax,1
    mov     [rbp-18h],rax
    jmp     L6
L9:
    mov     rax,[rbp-18h]
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-21h]
    mov     [rbp-8],dl
L10:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L11:
    mov     qword ptr [rbp-80h],1
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-18h]
L12:
    mov     qword ptr [rbp-60h],1
    mov     rdx,[rbp-60h]
    cmp     rdx,[rbp-20h]
    setb    [rbp-22h]
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+8]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L13
    mov     qword ptr [rbp-80h],0
    mov     r10,[rbp-20h]
    mov     [rbp-78h],r10
    mov     edi,0FFFFFF90h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-18h]
L13:
    mov     qword ptr [rbp-60h],0
    mov     rdx,[rbp-60h]
    cmp     rdx,[rbp-20h]
    setb    [rbp-22h]
    mov     rsi,[rbp+10h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    mov     rdi,[rbp-40h]
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rsi
    mov     r8,[rbp+20h]
    mov     [rbp-80h],r8
    mov     [rbp-78h],rdi
    mov     [rbp-70h],rsi
    call    fn4
    nop     [rcx-21h]
    jmp     L1
L14:
    mov     rax,[rbp-48h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-18h]
L15:
    mov     rax,[rbp-48h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-58h],rsi
    sub     rsi,1
    mov     [rbp-50h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L16
    mov     [rbp-80h],rsi
    mov     r9,[rbp-20h]
    mov     [rbp-78h],r9
    mov     edi,0FFFFFF90h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-18h]
L16:
    mov     rax,[rbp-50h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rdx
    mov     rdi,[rbp+20h]
    mov     [rbp-80h],rdi
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    call    fn9
    nop     [rcx-23h]
    jmp     L3
L17:
    mov     rax,[rbp-48h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx-18h]
L18:
    mov     rax,[rbp-48h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-58h],rsi
    sub     rsi,1
    mov     [rbp-50h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L19
    mov     [rbp-80h],rsi
    mov     r9,[rbp-20h]
    mov     [rbp-78h],r9
    mov     edi,0FFFFFF90h
    lea     rsi,[k12]
    call    ryo_h_AddrAbs
    call    fn13
    nop     [rcx-18h]
L19:
    mov     rax,[rbp-50h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rdx
    mov     rdi,[rbp+20h]
    mov     [rbp-80h],rdi
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    call    fn14
    nop     [rcx-23h]
    jmp     L7

fn core::slice::sort::shared::find_existing_run::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    cmp     rax,2
    jae     L0
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-8],0
    jmp     L10
L0:
    mov     qword ptr [rbp-18h],2
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    test    byte ptr [rbp-21h],0FFh
    je      L6
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp-18h]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    jae     L5
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L3:
    test    byte ptr [rbp-23h],0FFh
    je      L4
    mov     rdx,[rbp-18h]
    add     rdx,1
    mov     [rbp-18h],rdx
    jmp     L2
L4:
    jmp     L5
L5:
    jmp     L9
    nop     [rax+rax]
L6:
    mov     rax,[rbp-18h]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    jae     L9
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L18
    jmp     L17
    nop     [rax]
L7:
    test    byte ptr [rbp-23h],0FFh
    je      L8
    jmp     L9
L8:
    mov     rax,[rbp-18h]
    add     rax,1
    mov     [rbp-18h],rax
    jmp     L6
L9:
    mov     rax,[rbp-18h]
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-21h]
    mov     [rbp-8],dl
L10:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L11:
    mov     qword ptr [rbp-80h],1
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-18h]
L12:
    mov     qword ptr [rbp-60h],1
    mov     rdx,[rbp-60h]
    cmp     rdx,[rbp-20h]
    setb    [rbp-22h]
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+4]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L13
    mov     qword ptr [rbp-80h],0
    mov     r10,[rbp-20h]
    mov     [rbp-78h],r10
    mov     edi,0FFFFFF90h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-18h]
L13:
    mov     qword ptr [rbp-60h],0
    mov     rdx,[rbp-60h]
    cmp     rdx,[rbp-20h]
    setb    [rbp-22h]
    mov     rsi,[rbp+10h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    mov     rdi,[rbp-40h]
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rsi
    mov     r8,[rbp+20h]
    mov     [rbp-80h],r8
    mov     [rbp-78h],rdi
    mov     [rbp-70h],rsi
    call    fn4
    nop     [rcx-21h]
    jmp     L1
L14:
    mov     rax,[rbp-48h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-18h]
L15:
    mov     rax,[rbp-48h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-58h],rsi
    sub     rsi,1
    mov     [rbp-50h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L16
    mov     [rbp-80h],rsi
    mov     r9,[rbp-20h]
    mov     [rbp-78h],r9
    mov     edi,0FFFFFF90h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-18h]
L16:
    mov     rax,[rbp-50h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rdx
    mov     rdi,[rbp+20h]
    mov     [rbp-80h],rdi
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    call    fn9
    nop     [rcx-23h]
    jmp     L3
L17:
    mov     rax,[rbp-48h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx-18h]
L18:
    mov     rax,[rbp-48h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-58h],rsi
    sub     rsi,1
    mov     [rbp-50h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L19
    mov     [rbp-80h],rsi
    mov     r9,[rbp-20h]
    mov     [rbp-78h],r9
    mov     edi,0FFFFFF90h
    lea     rsi,[k12]
    call    ryo_h_AddrAbs
    call    fn13
    nop     [rcx-18h]
L19:
    mov     rax,[rbp-50h]
    cmp     rax,[rbp-20h]
    setb    [rbp-24h]
    mov     rdx,[rbp+10h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rdx
    mov     rdi,[rbp+20h]
    mov     [rbp-80h],rdi
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    call    fn14
    nop     [rcx-23h]
    jmp     L7

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    cmp     rax,8
    jae     L0
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rax
    mov     qword ptr [rbp-80h],8
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    imul    rax,[rbp-30h],4
    mov     [rbp-40h],rax
    mov     rdx,[rbp-10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-38h],rdx
    imul    rsi,[rbp-30h],7
    mov     [rbp-48h],rsi
    mov     rdi,[rbp-10h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rbp-40h],rdi
    cmp     qword ptr [rbp-28h],40h
    jae     L1
    mov     r9,[rbp-10h]
    mov     [rbp-58h],r9
    mov     [rbp-60h],rdx
    mov     [rbp-68h],rdi
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdi
    mov     r10,[rbp+20h]
    mov     [rbp-98h],r10
    call    fn0
    nop     [rcx-50h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L5
    jmp     L4
L1:
    mov     rax,[rbp-10h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp-30h]
    mov     [rbp-98h],rdi
    mov     r8,[rbp+20h]
    mov     [rbp-90h],r8
    call    fn1
    nop     [rcx-50h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L2:
    mov     rax,[rbp-8]
    mov     [rbp-38h],rax
    cmp     rax,[rbp-28h]
    setb    [rbp-29h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L2
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-20h]
L5:
    mov     qword ptr [rbp-80h],0
    cmp     qword ptr [rbp-80h],8
    setb    [rbp-42h]
    test    byte ptr [rbp-42h],0FFh
    je      L6
    mov     qword ptr [rbp-80h],8
    mov     r8,[rbp-80h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-43h]
    test    byte ptr [rbp-43h],0FFh
    je      L6
    mov     r10,[rbp-50h]
    sub     r10,[rbp-10h]
    mov     [rbp-8],r10
    mov     qword ptr [rbp-80h],8
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L3
L6:
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0A8h],49h
    mov     edi,0FFFFFF60h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-20h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    jmp     L2
L10:
    mov     rax,[rbp-50h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx-20h]
L11:
    mov     qword ptr [rbp-80h],0
    cmp     qword ptr [rbp-80h],8
    setb    [rbp-42h]
    test    byte ptr [rbp-42h],0FFh
    je      L12
    mov     qword ptr [rbp-80h],8
    mov     r8,[rbp-80h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-43h]
    test    byte ptr [rbp-43h],0FFh
    je      L12
    mov     r10,[rbp-50h]
    sub     r10,[rbp-10h]
    mov     [rbp-8],r10
    mov     qword ptr [rbp-80h],8
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L9
L12:
    mov     edi,0FFFFFF50h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0A8h],49h
    mov     edi,0FFFFFF60h
    lea     rsi,[k12]
    call    ryo_h_AddrAbs
    lea     rdi,[sym13]
    lea     rsi,[site14]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-20h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym15]
L14:
    call    ryo_h_Unreachable
    ud2
L15:
    movzx   eax,byte ptr [rbp-29h]
    mov     [rbp-0B0h],al
    mov     edi,0FFFFFF58h
    lea     rsi,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx-20h]
L16:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    cmp     rax,8
    jae     L0
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rax
    mov     qword ptr [rbp-80h],8
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    imul    rax,[rbp-30h],4
    mov     [rbp-40h],rax
    mov     rdx,[rbp-10h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-38h],rdx
    imul    rsi,[rbp-30h],7
    mov     [rbp-48h],rsi
    mov     rdi,[rbp-10h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-40h],rdi
    cmp     qword ptr [rbp-28h],40h
    jae     L1
    mov     r9,[rbp-10h]
    mov     [rbp-58h],r9
    mov     [rbp-60h],rdx
    mov     [rbp-68h],rdi
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdi
    mov     r10,[rbp+20h]
    mov     [rbp-98h],r10
    call    fn0
    nop     [rcx-50h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L5
    jmp     L4
L1:
    mov     rax,[rbp-10h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp-30h]
    mov     [rbp-98h],rdi
    mov     r8,[rbp+20h]
    mov     [rbp-90h],r8
    call    fn1
    nop     [rcx-50h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L2:
    mov     rax,[rbp-8]
    mov     [rbp-38h],rax
    cmp     rax,[rbp-28h]
    setb    [rbp-29h]
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L2
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-78h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-20h]
L5:
    mov     qword ptr [rbp-80h],0
    cmp     qword ptr [rbp-80h],4
    setb    [rbp-42h]
    test    byte ptr [rbp-42h],0FFh
    je      L6
    mov     qword ptr [rbp-80h],4
    mov     r8,[rbp-80h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-43h]
    test    byte ptr [rbp-43h],0FFh
    je      L6
    mov     r10,[rbp-50h]
    sub     r10,[rbp-10h]
    mov     [rbp-8],r10
    mov     qword ptr [rbp-80h],4
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L3
L6:
    mov     edi,0FFFFFF50h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0A8h],49h
    mov     edi,0FFFFFF60h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-20h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    jmp     L2
L10:
    mov     rax,[rbp-50h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFF60h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx-20h]
L11:
    mov     qword ptr [rbp-80h],0
    cmp     qword ptr [rbp-80h],4
    setb    [rbp-42h]
    test    byte ptr [rbp-42h],0FFh
    je      L12
    mov     qword ptr [rbp-80h],4
    mov     r8,[rbp-80h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-43h]
    test    byte ptr [rbp-43h],0FFh
    je      L12
    mov     r10,[rbp-50h]
    sub     r10,[rbp-10h]
    mov     [rbp-8],r10
    mov     qword ptr [rbp-80h],4
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L9
L12:
    mov     edi,0FFFFFF50h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0A8h],49h
    mov     edi,0FFFFFF60h
    lea     rsi,[k12]
    call    ryo_h_AddrAbs
    lea     rdi,[sym13]
    lea     rsi,[site14]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-20h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym15]
L14:
    call    ryo_h_Unreachable
    ud2
L15:
    movzx   eax,byte ptr [rbp-29h]
    mov     [rbp-0B0h],al
    mov     edi,0FFFFFF58h
    lea     rsi,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx-20h]
L16:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn0
    nop     [rcx-9]
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn1
    nop     [rcx-0Ah]
    movzx   eax,byte ptr [rbp-9]
    cmp     al,[rbp-0Ah]
    jne     L2
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-18h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rsi
    call    fn2
    nop     [rcx-0Ch]
    movzx   eax,byte ptr [rbp-0Ch]
    xor     al,[rbp-9]
    mov     [rbp-0Dh],al
    test    byte ptr [rbp-0Dh],0FFh
    je      L0
    mov     rsi,[rbp+20h]
    mov     [rbp-8],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
L1:
    jmp     L3
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
L3:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn0
    nop     [rcx-9]
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    call    fn1
    nop     [rcx-0Ah]
    movzx   eax,byte ptr [rbp-9]
    cmp     al,[rbp-0Ah]
    jne     L2
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-18h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rsi
    call    fn2
    nop     [rcx-0Ch]
    movzx   eax,byte ptr [rbp-0Ch]
    xor     al,[rbp-9]
    mov     [rbp-0Dh],al
    test    byte ptr [rbp-0Dh],0FFh
    je      L0
    mov     rsi,[rbp+20h]
    mov     [rbp-8],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
L1:
    jmp     L3
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
L3:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    imul    rax,[rbp+28h],8
    mov     [rbp-28h],rax
    cmp     rax,40h
    jb      L0
    mov     qword ptr [rbp-48h],8
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    mov     edx,0FFFFFFB8h
    call    ryo_h_DivUW64
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    imul    rsi,[rbp-28h],4
    mov     [rbp-10h],rsi
    imul    rcx,rsi,8
    add     rdx,rcx
    mov     [rbp-38h],rdx
    imul    rdi,[rbp-28h],7
    mov     [rbp-18h],rdi
    mov     r8,[rbp+10h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rbp-40h],r8
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],r8
    mov     r9,[rbp-28h]
    mov     [rbp-58h],r9
    mov     r10,[rbp+30h]
    mov     [rbp-50h],r10
    call    fn0
    nop     [rcx+10h]
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    imul    rcx,[rbp-10h],8
    add     rdx,rcx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    imul    rcx,[rbp-18h],8
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-28h]
    mov     [rbp-58h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-50h],r8
    call    fn1
    nop     [rcx+18h]
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-40h],rdx
    imul    rcx,[rbp-10h],8
    add     rdx,rcx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+20h]
    imul    rcx,[rbp-18h],8
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-28h]
    mov     [rbp-58h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-50h],r8
    call    fn2
    nop     [rcx+20h]
    jmp     L0
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-30h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-58h],rdi
    call    fn3
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    imul    rax,[rbp+28h],8
    mov     [rbp-28h],rax
    cmp     rax,40h
    jb      L0
    mov     qword ptr [rbp-48h],8
    mov     edi,0FFFFFFD8h
    mov     esi,28h
    mov     edx,0FFFFFFB8h
    call    ryo_h_DivUW64
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    imul    rsi,[rbp-28h],4
    mov     [rbp-10h],rsi
    imul    rcx,rsi,4
    add     rdx,rcx
    mov     [rbp-38h],rdx
    imul    rdi,[rbp-28h],7
    mov     [rbp-18h],rdi
    mov     r8,[rbp+10h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rbp-40h],r8
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],r8
    mov     r9,[rbp-28h]
    mov     [rbp-58h],r9
    mov     r10,[rbp+30h]
    mov     [rbp-50h],r10
    call    fn0
    nop     [rcx+10h]
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    imul    rcx,[rbp-10h],4
    add     rdx,rcx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    imul    rcx,[rbp-18h],4
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-28h]
    mov     [rbp-58h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-50h],r8
    call    fn1
    nop     [rcx+18h]
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-40h],rdx
    imul    rcx,[rbp-10h],4
    add     rdx,rcx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+20h]
    imul    rcx,[rbp-18h],4
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp-28h]
    mov     [rbp-58h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-50h],r8
    call    fn2
    nop     [rcx+20h]
    jmp     L0
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-30h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-58h],rdi
    call    fn3
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     rax,[rbp+18h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-80h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    mov     qword ptr [rbp-0A8h],2
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF58h
    call    ryo_h_DivUW64
    cmp     qword ptr [rbp-78h],0
    setne   [rbp-79h]
    mov     rdx,[rbp-70h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp-70h]
    imul    rcx,[rbp-78h],8
    add     rsi,rcx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp-78h]
    sub     rdi,1
    mov     [rbp-80h],rdi
    mov     r8,[rbp-70h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rbp-38h],r8
    mov     r9,[rbp-68h]
    sub     r9,1
    mov     [rbp-8],r9
    mov     r10,[rbp-70h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rbp-40h],r10
    mov     r11,[rbp+20h]
    mov     [rbp-80h],r11
    imul    rcx,r9,8
    add     r11,rcx
    mov     [rbp-48h],r11
    mov     qword ptr [rbp-18h],0
    mov     rdi,[rbp-78h]
    mov     [rbp-10h],rdi
L0:
    mov     rax,[rbp-18h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-90h],rdx
    cmp     rax,rdx
    setb    [rbp-79h]
    test    byte ptr [rbp-79h],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L1:
    mov     rax,[rbp-90h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-80h]
    mov     [rbp+20h],rsi
    mov     rdi,[rbp-38h]
    mov     [rbp-0E0h],rdi
    mov     r8,[rbp-40h]
    mov     [rbp-0D8h],r8
    mov     r9,[rbp-48h]
    mov     [rbp-0D0h],r9
    mov     r10,[rbp+28h]
    mov     [rbp-0C8h],r10
    call    fn0
    nop     [rcx-90h]
    mov     rax,[rbp-90h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-80h]
    mov     [rbp-48h],rsi
    jmp     L0
    nop     [rax]
L2:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rbp-28h]
    mov     [rbp-98h],rax
    cmp     rax,[rbp-80h]
    setb    [rbp-8Ah]
    test    byte ptr [rbp-8Ah],0FFh
    je      L4
    mov     rsi,[rbp-28h]
    mov     [rbp-50h],rsi
    jmp     L5
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-50h],rax
L5:
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
L6:
    mov     rax,[rbp-28h]
    cmp     rax,[rbp-80h]
    je      L7
    jmp     L8
L7:
    mov     rax,[rbp-30h]
    cmp     rax,[rbp-88h]
    je      L11
L8:
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx-50h]
    jmp     L10
L9:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L10:
    call    ryo_h_Unreachable
    ud2
L11:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L12:
    mov     rax,[rbp-18h]
    mov     [rbp-88h],rax
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L15
    jmp     L14
L13:
    mov     qword ptr [rbp-0A8h],1
    mov     rdx,[rbp-38h]
    imul    rcx,[rbp-0A8h],8
    add     rdx,rcx
    mov     [rbp-80h],rdx
    jmp     L16
L14:
    mov     rax,[rbp-88h]
    mov     [rbp-0E0h],rax
    mov     qword ptr [rbp-0D8h],1
    mov     edi,0FFFFFF30h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-60h]
L15:
    mov     rax,[rbp-88h]
    add     rax,1
    mov     [rbp-90h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-0E0h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-0D8h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-0D0h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-0C8h],r8
    call    fn6
    nop     [rcx-90h]
    jmp     L1
L16:
    mov     qword ptr [rbp-0A8h],1
    mov     rdx,[rbp-40h]
    imul    rcx,[rbp-0A8h],8
    add     rdx,rcx
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-0A8h],2
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF58h
    call    ryo_h_RemUW64
    cmp     qword ptr [rbp-98h],0
    sete    [rbp-89h]
    test    byte ptr [rbp-89h],0FFh
    je      L3
    jmp     L2
L17:
    mov     rax,[rbp-50h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-0E0h],rax
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-0D0h],8
    mov     qword ptr [rbp-0C8h],4
    mov     qword ptr [rbp-0C0h],1
    mov     edi,0FFFFFF48h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-60h]
L18:
    mov     qword ptr [rbp-0A8h],1
    imul    rdx,[rbp-0A8h],8
    mov     [rbp-0B0h],rdx
    mov     edi,20h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF50h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF76h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-28h]
    imul    rcx,[rbp-0A0h],8
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     [rbp-28h],rax
    movzx   edx,byte ptr [rbp-8Ah]
    xor     dl,1
    mov     [rbp-8Bh],dl
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF75h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-30h]
    imul    rcx,[rbp-0A0h],8
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     [rbp-30h],rax
    jmp     L6

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0E0h
    mov     rax,[rbp+18h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-80h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rdx
    mov     qword ptr [rbp-0A8h],2
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF58h
    call    ryo_h_DivUW64
    cmp     qword ptr [rbp-78h],0
    setne   [rbp-79h]
    mov     rdx,[rbp-70h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp-70h]
    imul    rcx,[rbp-78h],4
    add     rsi,rcx
    mov     [rbp-30h],rsi
    mov     rdi,[rbp-78h]
    sub     rdi,1
    mov     [rbp-80h],rdi
    mov     r8,[rbp-70h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rbp-38h],r8
    mov     r9,[rbp-68h]
    sub     r9,1
    mov     [rbp-8],r9
    mov     r10,[rbp-70h]
    imul    rcx,r9,4
    add     r10,rcx
    mov     [rbp-40h],r10
    mov     r11,[rbp+20h]
    mov     [rbp-80h],r11
    imul    rcx,r9,4
    add     r11,rcx
    mov     [rbp-48h],r11
    mov     qword ptr [rbp-18h],0
    mov     rdi,[rbp-78h]
    mov     [rbp-10h],rdi
L0:
    mov     rax,[rbp-18h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-90h],rdx
    cmp     rax,rdx
    setb    [rbp-79h]
    test    byte ptr [rbp-79h],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L1:
    mov     rax,[rbp-90h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-80h]
    mov     [rbp+20h],rsi
    mov     rdi,[rbp-38h]
    mov     [rbp-0E0h],rdi
    mov     r8,[rbp-40h]
    mov     [rbp-0D8h],r8
    mov     r9,[rbp-48h]
    mov     [rbp-0D0h],r9
    mov     r10,[rbp+28h]
    mov     [rbp-0C8h],r10
    call    fn0
    nop     [rcx-90h]
    mov     rax,[rbp-90h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-88h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-80h]
    mov     [rbp-48h],rsi
    jmp     L0
    nop     [rax]
L2:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rbp-28h]
    mov     [rbp-98h],rax
    cmp     rax,[rbp-80h]
    setb    [rbp-8Ah]
    test    byte ptr [rbp-8Ah],0FFh
    je      L4
    mov     rsi,[rbp-28h]
    mov     [rbp-50h],rsi
    jmp     L5
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-50h],rax
L5:
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L18
    jmp     L17
    nop     [rax+rax]
L6:
    mov     rax,[rbp-28h]
    cmp     rax,[rbp-80h]
    je      L7
    jmp     L8
L7:
    mov     rax,[rbp-30h]
    cmp     rax,[rbp-88h]
    je      L11
L8:
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx-50h]
    jmp     L10
L9:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L10:
    call    ryo_h_Unreachable
    ud2
L11:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L12:
    mov     rax,[rbp-18h]
    mov     [rbp-88h],rax
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L15
    jmp     L14
L13:
    mov     qword ptr [rbp-0A8h],1
    mov     rdx,[rbp-38h]
    imul    rcx,[rbp-0A8h],4
    add     rdx,rcx
    mov     [rbp-80h],rdx
    jmp     L16
L14:
    mov     rax,[rbp-88h]
    mov     [rbp-0E0h],rax
    mov     qword ptr [rbp-0D8h],1
    mov     edi,0FFFFFF30h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-60h]
L15:
    mov     rax,[rbp-88h]
    add     rax,1
    mov     [rbp-90h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-0E0h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-0D8h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-0D0h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-0C8h],r8
    call    fn6
    nop     [rcx-90h]
    jmp     L1
L16:
    mov     qword ptr [rbp-0A8h],1
    mov     rdx,[rbp-40h]
    imul    rcx,[rbp-0A8h],4
    add     rdx,rcx
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-0A8h],2
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF58h
    call    ryo_h_RemUW64
    cmp     qword ptr [rbp-98h],0
    sete    [rbp-89h]
    test    byte ptr [rbp-89h],0FFh
    je      L3
    jmp     L2
L17:
    mov     rax,[rbp-50h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-0E0h],rax
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-0D0h],4
    mov     qword ptr [rbp-0C8h],4
    mov     qword ptr [rbp-0C0h],1
    mov     edi,0FFFFFF48h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-60h]
L18:
    mov     qword ptr [rbp-0A8h],1
    imul    rdx,[rbp-0A8h],4
    mov     [rbp-0B0h],rdx
    mov     edi,20h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF50h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF76h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-28h]
    imul    rcx,[rbp-0A0h],4
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     [rbp-28h],rax
    movzx   edx,byte ptr [rbp-8Ah]
    xor     dl,1
    mov     [rbp-8Bh],dl
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF75h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-30h]
    imul    rcx,[rbp-0A0h],4
    add     rax,rcx
    mov     [rbp-98h],rax
    mov     [rbp-30h],rax
    jmp     L6

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     byte ptr [rbp-71h],0
    test    byte ptr [rbp-71h],0FFh
    je      L11
    jmp     L10
    xchg    ax,ax
L0:
    test    byte ptr [rbp-29h],0FFh
    je      L1
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     rdx,[rdx]
    mov     [rbp-38h],rdx
    mov     [rbp-40h],rdx
    mov     [rbp-30h],rdx
    lea     rsi,[rbp-30h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-40h],rdi
    mov     qword ptr [rbp-38h],1
    jmp     L2
L1:
    jmp     L7
L2:
    mov     rax,[rbp-8]
    mov     [rbp-18h],rax
    mov     [rbp-50h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L3:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     byte ptr [rbp-71h],0
    test    byte ptr [rbp-71h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L5:
    test    byte ptr [rbp-49h],0FFh
    je      L6
    jmp     L2
L6:
    lea     rax,[rbp-48h]
    mov     [rbp-78h],rax
    mov     [rbp-0B0h],rax
    call    fn0
    nop     [rcx-78h]
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    xchg    ax,ax
L8:
    lea     rax,[rbp-48h]
    mov     [rbp-78h],rax
    mov     [rbp-0B0h],rax
    call    fn1
    nop     [rcx-78h]
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L9:
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn2
    nop     [rcx-29h]
    jmp     L0
L10:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    jmp     L9
L11:
    mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-8],rdx
    jmp     L9
L12:
    mov     rax,[rbp-18h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],8
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-20h]
L13:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],8
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     rax,[rbp-8]
    mov     [rbp-50h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-58h],rdx
    cmp     rdx,[rbp+10h]
    je      L3
    jmp     L4
    nop     [rax+rax]
L14:
    mov     rax,[rbp-50h]
    mov     [rbp-8],rax
    lea     rdx,[rbp-30h]
    mov     [rbp-68h],rdx
    mov     [rbp-70h],rax
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rax
    call    fn5
    nop     [rcx-49h]
    jmp     L5
L15:
    mov     rax,[rbp-8]
    mov     [rbp-50h],rax
    jmp     L14
L16:
    mov     qword ptr [rbp-78h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-50h],rdx
    jmp     L14
    nop     [rax+rax]
L17:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx-70h]
    jmp     L19
L18:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L19:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L17
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L8

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     byte ptr [rbp-69h],0
    test    byte ptr [rbp-69h],0FFh
    je      L11
    jmp     L10
    xchg    ax,ax
L0:
    test    byte ptr [rbp-29h],0FFh
    je      L1
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     edx,[rdx]
    mov     [rbp-30h],edx
    mov     [rbp-34h],edx
    mov     [rbp-2Ch],edx
    lea     rsi,[rbp-2Ch]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-40h],rdi
    mov     qword ptr [rbp-38h],1
    jmp     L2
L1:
    jmp     L7
    nop     [rax]
L2:
    mov     rax,[rbp-8]
    mov     [rbp-18h],rax
    mov     [rbp-50h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L3:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     byte ptr [rbp-69h],0
    test    byte ptr [rbp-69h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L5:
    test    byte ptr [rbp-2Dh],0FFh
    je      L6
    jmp     L2
L6:
    lea     rax,[rbp-48h]
    mov     [rbp-70h],rax
    mov     [rbp-0B0h],rax
    call    fn0
    nop     [rcx-70h]
L7:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    xchg    ax,ax
L8:
    lea     rax,[rbp-48h]
    mov     [rbp-70h],rax
    mov     [rbp-0B0h],rax
    call    fn1
    nop     [rcx-70h]
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L9:
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn2
    nop     [rcx-29h]
    jmp     L0
L10:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    jmp     L9
L11:
    mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-70h],4
    add     rdx,rcx
    mov     [rbp-8],rdx
    jmp     L9
L12:
    mov     rax,[rbp-18h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-68h],rdx
    mov     [rbp-0B0h],rax
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],4
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-20h]
L13:
    mov     qword ptr [rbp-70h],1
    imul    rdx,[rbp-70h],4
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF88h
    call    ryo_h_Memcpy
    mov     rax,[rbp-8]
    mov     [rbp-50h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-50h],rdx
    cmp     rdx,[rbp+10h]
    je      L3
    jmp     L4
    nop     [rax+rax]
L14:
    mov     rax,[rbp-50h]
    mov     [rbp-8],rax
    lea     rdx,[rbp-2Ch]
    mov     [rbp-60h],rdx
    mov     [rbp-68h],rax
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rax
    call    fn5
    nop     [rcx-2Dh]
    jmp     L5
L15:
    mov     rax,[rbp-8]
    mov     [rbp-50h],rax
    jmp     L14
L16:
    mov     qword ptr [rbp-70h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-70h],4
    add     rdx,rcx
    mov     [rbp-50h],rdx
    jmp     L14
    nop     [rax+rax]
L17:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx-68h]
    jmp     L19
L18:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L19:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L17
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L8

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    cmp     qword ptr [rbp+20h],0
    je      L0
    cmp     rax,[rbp+20h]
    jae     L1
L0:
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    imul    rcx,[rbp-10h],8
    add     rax,rcx
    mov     [rbp-20h],rax
    mov     rsi,[rbp-18h]
    imul    rcx,[rbp+20h],8
    add     rsi,rcx
    mov     [rbp-8],rsi
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp-8]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    je      L3
    mov     rdx,[rbp-8]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    mov     rdi,[rbp+28h]
    mov     [rbp-40h],rdi
    call    fn0
    nop     [rcx-8]
    mov     qword ptr [rbp-38h],1
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-38h],8
    add     rdx,rcx
    mov     [rbp-30h],rdx
    mov     [rbp-8],rdx
    jmp     L2
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    cmp     qword ptr [rbp+20h],0
    je      L0
    cmp     rax,[rbp+20h]
    jae     L1
L0:
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    imul    rcx,[rbp-10h],4
    add     rax,rcx
    mov     [rbp-20h],rax
    mov     rsi,[rbp-18h]
    imul    rcx,[rbp+20h],4
    add     rsi,rcx
    mov     [rbp-8],rsi
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp-8]
    mov     [rbp-30h],rax
    cmp     rax,[rbp-20h]
    je      L3
    mov     rdx,[rbp-8]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    mov     rdi,[rbp+28h]
    mov     [rbp-40h],rdi
    call    fn0
    nop     [rcx-8]
    mov     qword ptr [rbp-38h],1
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-38h],4
    add     rdx,rcx
    mov     [rbp-30h],rdx
    mov     [rbp-8],rdx
    jmp     L2
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::merge_down::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rax
    mov     [rbp-80h],rdx
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    xor     al,1
    mov     [rbp-29h],al
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    mov     [rbp-28h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L2
    mov     rdi,[rbp-28h]
    mov     [rbp-40h],rdi
    mov     [rbp-48h],rax
    mov     [rbp-90h],rdi
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-80h],8
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L2:
    mov     qword ptr [rbp-58h],1
    imul    rdx,[rbp-58h],8
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA0h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-58h],0
    mov     rsi,[rbp-58h]
    sub     rsi,rax
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp+18h],rdi
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-58h],0
    mov     rsi,[rbp-58h]
    sub     rsi,rax
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp+10h],rdi
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L3:
    mov     rax,[rbp-38h]
    mov     [rbp+20h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-10h],rsi
    mov     [rbp-8],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    jmp     L3
L5:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp+20h]
    imul    rcx,[rbp-58h],8
    add     rdx,rcx
    mov     [rbp-38h],rdx
    jmp     L3

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rax
    mov     [rbp-80h],rdx
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    xor     al,1
    mov     [rbp-29h],al
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    mov     [rbp-28h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L2
    mov     rdi,[rbp-28h]
    mov     [rbp-40h],rdi
    mov     [rbp-48h],rax
    mov     [rbp-90h],rdi
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L2:
    mov     qword ptr [rbp-58h],1
    imul    rdx,[rbp-58h],4
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA0h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-58h],0
    mov     rsi,[rbp-58h]
    sub     rsi,rax
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp+18h],rdi
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-58h],0
    mov     rsi,[rbp-58h]
    sub     rsi,rax
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp+10h],rdi
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L3:
    mov     rax,[rbp-38h]
    mov     [rbp+20h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-10h],rsi
    mov     [rbp-8],rax
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    jmp     L3
L5:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp+20h]
    imul    rcx,[rbp-58h],4
    add     rdx,rcx
    mov     [rbp-38h],rdx
    jmp     L3

fn core::slice::sort::shared::smallsort::merge_up::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rax
    mov     [rbp-80h],rdx
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    xor     al,1
    mov     [rbp-29h],al
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-28h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L2
    mov     rdi,[rbp-28h]
    mov     [rbp-40h],rdi
    mov     [rbp-48h],rax
    mov     [rbp-90h],rdi
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-80h],8
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L2:
    mov     qword ptr [rbp-58h],1
    imul    rdx,[rbp-58h],8
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA0h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+18h]
    imul    rcx,[rbp-40h],8
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp+18h],rax
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-40h],8
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp+10h],rax
    mov     qword ptr [rbp-58h],1
    mov     rsi,[rbp+20h]
    imul    rcx,[rbp-58h],8
    add     rsi,rcx
    mov     [rbp-38h],rsi
    mov     [rbp+20h],rsi
    mov     [rbp-18h],rax
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rax
    mov     [rbp-80h],rdx
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    xor     al,1
    mov     [rbp-29h],al
    test    byte ptr [rbp-29h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-28h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L2
    mov     rdi,[rbp-28h]
    mov     [rbp-40h],rdi
    mov     [rbp-48h],rax
    mov     [rbp-90h],rdi
    mov     [rbp-88h],rax
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L2:
    mov     qword ptr [rbp-58h],1
    imul    rdx,[rbp-58h],4
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFA0h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+18h]
    imul    rcx,[rbp-40h],4
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp+18h],rax
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-40h],4
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp+10h],rax
    mov     qword ptr [rbp-58h],1
    mov     rsi,[rbp+20h]
    imul    rcx,[rbp-58h],4
    add     rsi,rcx
    mov     [rbp-38h],rsi
    mov     [rbp+20h],rsi
    mov     [rbp-18h],rax
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::small_sort_general::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,130h
    lea     rax,[rbp-0E0h]
    mov     [rbp-20h],rax
    mov     [rbp-0E8h],rax
    mov     byte ptr [rbp-0F9h],1
    test    byte ptr [rbp-0F9h],0FFh
    je      L2
    jmp     L1
    nop
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-0F0h],rax
    mov     [rbp-130h],rax
    mov     qword ptr [rbp-128h],4
    mov     qword ptr [rbp-120h],4
    mov     qword ptr [rbp-118h],30h
    mov     edi,0FFFFFEF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-20h]
L2:
    mov     rax,[rbp-20h]
    mov     [rbp-0F8h],rax
    mov     qword ptr [rbp-0F0h],30h
    mov     [rbp-10h],rax
    mov     rsi,[rbp-0F0h]
    mov     [rbp-8],rsi
    mov     edi,0FFFFFED0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEE0h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-110h],rax
    call    fn2
    nop     [rcx-18h]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,190h
    mov     rax,[rbp+18h]
    mov     [rbp-90h],rax
    cmp     rax,2
    jae     L0
    jmp     L16
L0:
    mov     rax,[rbp+28h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-90h]
    add     rdx,10h
    mov     [rbp-0A8h],rdx
    cmp     rax,rdx
    jae     L1
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-98h],rax
    mov     qword ptr [rbp-150h],2
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFEB0h
    call    ryo_h_DivUW64
    mov     rax,[rbp+20h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-68h],rdx
    mov     [rbp-8],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L2
    cmp     qword ptr [rbp-90h],10h
    jb      L2
    imul    rcx,[rbp-90h],8
    add     rax,rcx
    mov     [rbp-0B8h],rax
    mov     r9,[rbp-98h]
    mov     [rbp-190h],r9
    mov     r10,[rbp-8]
    mov     [rbp-188h],r10
    mov     [rbp-180h],rax
    mov     r11,[rbp+30h]
    mov     [rbp-178h],r11
    call    fn0
    nop     [rcx-8]
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],8
    add     rax,rcx
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],8
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     rsi,[rbp-90h]
    add     rsi,8
    mov     [rbp-0D0h],rsi
    mov     rdi,[rbp-8]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rbp-0C8h],rdi
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     [rbp-180h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-178h],r8
    call    fn1
    nop     [rcx-8]
    mov     qword ptr [rbp-0A8h],8
    jmp     L4
L2:
    cmp     qword ptr [rbp-90h],8
    jb      L3
    mov     rdx,[rbp-60h]
    mov     [rbp-0B8h],rdx
    mov     [rbp-190h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-188h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-180h],rdi
    call    fn2
    nop     [rcx-8]
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],8
    add     rax,rcx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],8
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-180h],rsi
    call    fn3
    nop     [rcx-8]
    mov     qword ptr [rbp-0A8h],4
    jmp     L4
L3:
    mov     rax,[rbp-60h]
    mov     [rbp-0B8h],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L4:
    mov     qword ptr [rbp-0D8h],0
    mov     rdx,[rbp-0A0h]
    mov     [rbp-0D0h],rdx
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF28h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEF8h
    lea     rsi,[k4]
    mov     edx,10h
    call    ryo_h_Const
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF18h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEB8h
    mov     esi,0FFFFFEF8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFED8h
    mov     esi,0FFFFFEB8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFED8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF38h
    mov     edx,20h
    call    ryo_h_Copy
    nop     [rax]
L5:
    lea     rax,[rbp-0E8h]
    mov     [rbp-110h],rax
    mov     [rbp-108h],rax
    mov     qword ptr [rbp-100h],2
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx-0F8h]
    jmp     L23
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rbp-0F0h]
    mov     [rbp-100h],rax
    mov     rdx,[rbp-98h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-108h],rdx
    mov     rsi,[rbp-8]
    imul    rcx,rax,8
    add     rsi,rcx
    mov     [rbp-110h],rsi
    cmp     rax,0
    je      L9
    jmp     L10
L8:
    lea     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn6
    nop     [rcx-150h]
    jmp     L14
L9:
    mov     rax,[rbp-0A0h]
    mov     [rbp-28h],rax
    jmp     L11
L10:
    mov     rax,[rbp-90h]
    sub     rax,[rbp-0A0h]
    mov     [rbp-28h],rax
L11:
    mov     rax,[rbp-0A8h]
    mov     [rbp-118h],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-30h],rdx
L12:
    mov     rax,[rbp-38h]
    mov     [rbp-130h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-138h],rdx
    cmp     rax,rdx
    setb    [rbp-121h]
    test    byte ptr [rbp-121h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    jmp     L12
L14:
    mov     rax,[rbp-70h]
    mov     [rbp-0C8h],rax
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-98h]
    mov     [rbp-0B8h],rdx
    mov     rsi,[rbp-90h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0D8h],rax
    mov     [rbp-0E0h],rsi
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L31
    jmp     L30
    nop     [rax+rax]
L15:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0C8h],rax
    mov     rdx,[rbp-0B8h]
    mov     [rbp-0D0h],rdx
    mov     rsi,[rbp-0B0h]
    mov     [rbp-0D8h],rsi
L16:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L17:
    lea     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn7
    nop     [rcx-150h]
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    mov     edi,0FFFFFF78h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L19:
    lea     rax,[rbp-0C0h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn8
    nop     [rcx-150h]
    jmp     L18
L20:
    mov     rax,[rbp-60h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-0C8h],rdx
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     qword ptr [rbp-180h],8
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx-70h]
L21:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],8
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],8
    add     rax,rcx
    mov     [rbp-10h],rax
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],8
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L22
    mov     r8,[rbp-10h]
    mov     [rbp-0C8h],r8
    mov     [rbp-0D0h],rdx
    mov     [rbp-190h],r8
    mov     [rbp-188h],rdx
    mov     qword ptr [rbp-180h],8
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-70h]
L22:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],8
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-0A8h],1
    jmp     L4
L23:
    mov     rax,[rbp-0F8h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L24]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L24:
    .long   L8
    .long   L7
    .long   L6
L25:
    mov     rax,[rbp-38h]
    mov     [rbp-130h],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L28
    jmp     L27
L26:
    jmp     L5
L27:
    mov     rax,[rbp-130h]
    mov     [rbp-190h],rax
    mov     qword ptr [rbp-188h],1
    mov     edi,0FFFFFE80h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-80h]
L28:
    mov     rax,[rbp-130h]
    add     rax,1
    mov     [rbp-138h],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp-130h]
    mov     [rbp-118h],rdx
    mov     qword ptr [rbp-120h],1
    mov     [rbp-128h],rdx
    mov     rdi,[rbp-108h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rbp-48h],rdi
    mov     [rbp-130h],rdi
    mov     r8,[rbp-110h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rbp-50h],r8
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L29
    mov     r11,[rbp-48h]
    mov     [rbp-138h],r11
    mov     [rbp-140h],r8
    mov     [rbp-190h],r11
    mov     [rbp-188h],r8
    mov     qword ptr [rbp-180h],8
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx-80h]
L29:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],8
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-110h]
    mov     [rbp-190h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-188h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-180h],rsi
    call    fn17
    nop     [rcx-50h]
    jmp     L13
L30:
    mov     rax,[rbp-0D8h]
    mov     [rbp-0E8h],rax
    mov     [rbp-190h],rax
    mov     qword ptr [rbp-188h],8
    mov     qword ptr [rbp-180h],4
    mov     rdi,[rbp-0E0h]
    mov     [rbp-178h],rdi
    mov     edi,0FFFFFE90h
    lea     rsi,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx-80h]
L31:
    mov     rax,[rbp-0D8h]
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-0E0h]
    mov     [rbp-0E8h],rdx
    mov     [rbp-0D0h],rax
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp-0B8h]
    mov     [rbp-0D8h],rsi
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    mov     rax,[rbp-0D8h]
    mov     [rbp-180h],rax
    mov     rdx,[rbp+30h]
    mov     [rbp-178h],rdx
    call    fn20
    nop     [rcx-50h]
    jmp     L15
    nop     [rax]
L32:
    lea     rdi,[sym21]
    lea     rsi,[site22]
    mov     edx,0FFFFFEB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L33
    call    rax
    nop     [rcx-148h]
    jmp     L34
L33:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L34:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L17
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L32
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L19

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,190h
    mov     rax,[rbp+18h]
    mov     [rbp-90h],rax
    cmp     rax,2
    jae     L0
    jmp     L16
L0:
    mov     rax,[rbp+28h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-90h]
    add     rdx,10h
    mov     [rbp-0A8h],rdx
    cmp     rax,rdx
    jae     L1
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-98h],rax
    mov     qword ptr [rbp-150h],2
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFEB0h
    call    ryo_h_DivUW64
    mov     rax,[rbp+20h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-68h],rdx
    mov     [rbp-8],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L2
    cmp     qword ptr [rbp-90h],10h
    jb      L2
    imul    rcx,[rbp-90h],4
    add     rax,rcx
    mov     [rbp-0B8h],rax
    mov     r9,[rbp-98h]
    mov     [rbp-190h],r9
    mov     r10,[rbp-8]
    mov     [rbp-188h],r10
    mov     [rbp-180h],rax
    mov     r11,[rbp+30h]
    mov     [rbp-178h],r11
    call    fn0
    nop     [rcx-8]
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],4
    add     rax,rcx
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],4
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     rsi,[rbp-90h]
    add     rsi,8
    mov     [rbp-0D0h],rsi
    mov     rdi,[rbp-8]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-0C8h],rdi
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     [rbp-180h],rdi
    mov     r8,[rbp+30h]
    mov     [rbp-178h],r8
    call    fn1
    nop     [rcx-8]
    mov     qword ptr [rbp-0A8h],8
    jmp     L4
L2:
    cmp     qword ptr [rbp-90h],8
    jb      L3
    mov     rdx,[rbp-60h]
    mov     [rbp-0B8h],rdx
    mov     [rbp-190h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-188h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-180h],rdi
    call    fn2
    nop     [rcx-8]
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],4
    add     rax,rcx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],4
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-180h],rsi
    call    fn3
    nop     [rcx-8]
    mov     qword ptr [rbp-0A8h],4
    jmp     L4
L3:
    mov     rax,[rbp-60h]
    mov     [rbp-0B8h],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L21
    jmp     L20
    nop     [rax]
L4:
    mov     qword ptr [rbp-0D8h],0
    mov     rdx,[rbp-0A0h]
    mov     [rbp-0D0h],rdx
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF28h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEF8h
    lea     rsi,[k4]
    mov     edx,10h
    call    ryo_h_Const
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF18h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEB8h
    mov     esi,0FFFFFEF8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFED8h
    mov     esi,0FFFFFEB8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFED8h
    mov     edx,20h
    call    ryo_h_Copy
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF38h
    mov     edx,20h
    call    ryo_h_Copy
    nop     [rax]
L5:
    lea     rax,[rbp-0E8h]
    mov     [rbp-110h],rax
    mov     [rbp-108h],rax
    mov     qword ptr [rbp-100h],2
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx-0F8h]
    jmp     L23
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rbp-0F0h]
    mov     [rbp-100h],rax
    mov     rdx,[rbp-98h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-108h],rdx
    mov     rsi,[rbp-8]
    imul    rcx,rax,4
    add     rsi,rcx
    mov     [rbp-110h],rsi
    cmp     rax,0
    je      L9
    jmp     L10
L8:
    lea     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn6
    nop     [rcx-150h]
    jmp     L14
L9:
    mov     rax,[rbp-0A0h]
    mov     [rbp-28h],rax
    jmp     L11
L10:
    mov     rax,[rbp-90h]
    sub     rax,[rbp-0A0h]
    mov     [rbp-28h],rax
L11:
    mov     rax,[rbp-0A8h]
    mov     [rbp-118h],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-30h],rdx
L12:
    mov     rax,[rbp-38h]
    mov     [rbp-130h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-138h],rdx
    cmp     rax,rdx
    setb    [rbp-121h]
    test    byte ptr [rbp-121h],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    jmp     L12
L14:
    mov     rax,[rbp-70h]
    mov     [rbp-0C8h],rax
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-98h]
    mov     [rbp-0B8h],rdx
    mov     rsi,[rbp-90h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0D8h],rax
    mov     [rbp-0E0h],rsi
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L31
    jmp     L30
    nop     [rax+rax]
L15:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0C8h],rax
    mov     rdx,[rbp-0B8h]
    mov     [rbp-0D0h],rdx
    mov     rsi,[rbp-0B0h]
    mov     [rbp-0D8h],rsi
L16:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    xchg    ax,ax
L17:
    lea     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn7
    nop     [rcx-150h]
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    mov     edi,0FFFFFF78h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L19:
    lea     rax,[rbp-0C0h]
    mov     [rbp-150h],rax
    mov     [rbp-190h],rax
    call    fn8
    nop     [rcx-150h]
    jmp     L18
L20:
    mov     rax,[rbp-60h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-0C8h],rdx
    mov     [rbp-190h],rax
    mov     [rbp-188h],rdx
    mov     qword ptr [rbp-180h],4
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx-70h]
L21:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],4
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0A0h],4
    add     rax,rcx
    mov     [rbp-10h],rax
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp-8]
    imul    rcx,[rbp-0A0h],4
    add     rdx,rcx
    mov     [rbp-0C0h],rdx
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L22
    mov     r8,[rbp-10h]
    mov     [rbp-0C8h],r8
    mov     [rbp-0D0h],rdx
    mov     [rbp-190h],r8
    mov     [rbp-188h],rdx
    mov     qword ptr [rbp-180h],4
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-70h]
L22:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],4
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF48h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-0A8h],1
    jmp     L4
L23:
    mov     rax,[rbp-0F8h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L24]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L24:
    .long   L8
    .long   L7
    .long   L6
L25:
    mov     rax,[rbp-38h]
    mov     [rbp-130h],rax
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L28
    jmp     L27
L26:
    jmp     L5
L27:
    mov     rax,[rbp-130h]
    mov     [rbp-190h],rax
    mov     qword ptr [rbp-188h],1
    mov     edi,0FFFFFE80h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-80h]
L28:
    mov     rax,[rbp-130h]
    add     rax,1
    mov     [rbp-138h],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp-130h]
    mov     [rbp-118h],rdx
    mov     qword ptr [rbp-120h],1
    mov     [rbp-128h],rdx
    mov     rdi,[rbp-108h]
    imul    rcx,rdx,4
    add     rdi,rcx
    mov     [rbp-48h],rdi
    mov     [rbp-130h],rdi
    mov     r8,[rbp-110h]
    imul    rcx,rdx,4
    add     r8,rcx
    mov     [rbp-50h],r8
    mov     byte ptr [rbp-149h],1
    test    byte ptr [rbp-149h],0FFh
    je      L29
    mov     r11,[rbp-48h]
    mov     [rbp-138h],r11
    mov     [rbp-140h],r8
    mov     [rbp-190h],r11
    mov     [rbp-188h],r8
    mov     qword ptr [rbp-180h],4
    mov     qword ptr [rbp-178h],4
    mov     qword ptr [rbp-170h],1
    mov     edi,0FFFFFE98h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx-80h]
L29:
    mov     qword ptr [rbp-150h],1
    imul    rdx,[rbp-150h],4
    mov     [rbp-158h],rdx
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-110h]
    mov     [rbp-190h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-188h],rdx
    mov     rsi,[rbp+30h]
    mov     [rbp-180h],rsi
    call    fn17
    nop     [rcx-50h]
    jmp     L13
L30:
    mov     rax,[rbp-0D8h]
    mov     [rbp-0E8h],rax
    mov     [rbp-190h],rax
    mov     qword ptr [rbp-188h],4
    mov     qword ptr [rbp-180h],4
    mov     rdi,[rbp-0E0h]
    mov     [rbp-178h],rdi
    mov     edi,0FFFFFE90h
    lea     rsi,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx-80h]
L31:
    mov     rax,[rbp-0D8h]
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-0E0h]
    mov     [rbp-0E8h],rdx
    mov     [rbp-0D0h],rax
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp-0B8h]
    mov     [rbp-0D8h],rsi
    mov     edi,0FFFFFE70h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    mov     rax,[rbp-0D8h]
    mov     [rbp-180h],rax
    mov     rdx,[rbp+30h]
    mov     [rbp-178h],rdx
    call    fn20
    nop     [rcx-50h]
    jmp     L15
    nop     [rax]
L32:
    lea     rdi,[sym21]
    lea     rsi,[site22]
    mov     edx,0FFFFFEB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L33
    call    rax
    nop     [rcx-148h]
    jmp     L34
L33:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L34:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L17
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L32
    mov     rdi,rax
    mov     esi,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L19

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,160h
    mov     rax,[rbp+18h]
    mov     [rbp-60h],rax
    cmp     rax,2
    jae     L0
    jmp     L11
L0:
    cmp     qword ptr [rbp-60h],20h
    jbe     L1
    call    ryo_h_Abort
    ud2
L1:
    mov     qword ptr [rbp-128h],2
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFED8h
    call    ryo_h_DivUW64
    cmp     qword ptr [rbp-60h],12h
    setb    [rbp-0E9h]
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-38h],rsi
    mov     [rbp-0F8h],rdx
    test    byte ptr [rbp-0E9h],0FFh
    je      L2
    mov     r8,[rbp-60h]
    mov     [rbp-8],r8
    jmp     L3
L2:
    mov     rax,[rbp-0E8h]
    mov     [rbp-8],rax
L3:
    mov     byte ptr [rbp-121h],1
    test    byte ptr [rbp-121h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    xchg    ax,ax
L4:
    mov     rax,[rbp-20h]
    mov     [rbp-110h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-108h],rdx
    mov     [rbp-100h],rdx
    cmp     rdx,0Dh
    jb      L5
    mov     edi,0FFFFFEF8h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-150h],rax
    call    fn0
    nop     [rcx-10h]
    mov     qword ptr [rbp-10h],0Dh
    jmp     L7
L5:
    mov     rax,[rbp-20h]
    mov     [rbp-110h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-108h],rdx
    mov     [rbp-100h],rdx
    cmp     rdx,9
    jb      L6
    mov     edi,0FFFFFEF8h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-150h],rax
    call    fn1
    nop     [rcx-10h]
    mov     qword ptr [rbp-10h],9
    jmp     L7
L6:
    mov     qword ptr [rbp-10h],1
L7:
    mov     edi,0FFFFFEF8h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rbp-10h]
    mov     [rbp-150h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-148h],rdx
    call    fn2
    nop     [rcx-10h]
    test    byte ptr [rbp-0E9h],0FFh
    je      L8
    jmp     L11
L8:
    mov     rax,[rbp-20h]
    mov     [rbp-110h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-108h],rdx
    mov     [rbp-120h],rax
    mov     [rbp-118h],rdx
    mov     [rbp-100h],rax
    mov     rsi,[rbp-40h]
    mov     [rbp-108h],rsi
    cmp     rax,rsi
    je      L9
    lea     rdi,[rbp-0E0h]
    mov     [rbp-48h],rdi
    mov     [rbp-28h],rdi
    mov     byte ptr [rbp-121h],1
    test    byte ptr [rbp-121h],0FFh
    je      L17
    jmp     L16
L9:
    mov     rax,[rbp-0F8h]
    imul    rcx,[rbp-0E8h],4
    add     rax,rcx
    mov     [rbp-100h],rax
    mov     rdx,[rbp-60h]
    sub     rdx,[rbp-0E8h]
    mov     [rbp-108h],rdx
    mov     byte ptr [rbp-121h],1
    test    byte ptr [rbp-121h],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    mov     rax,[rbp-48h]
    mov     [rbp-100h],rax
    mov     byte ptr [rbp-121h],1
    test    byte ptr [rbp-121h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax]
L11:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L12:
    mov     rax,[rbp-40h]
    mov     [rbp-100h],rax
    mov     [rbp-160h],rax
    mov     qword ptr [rbp-158h],4
    mov     qword ptr [rbp-150h],4
    mov     rdi,[rbp-8]
    mov     [rbp-148h],rdi
    mov     edi,0FFFFFEC0h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-40h]
L13:
    mov     rax,[rbp-0F8h]
    mov     [rbp-108h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-100h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    jmp     L4
L14:
    mov     rax,[rbp-100h]
    mov     [rbp-110h],rax
    mov     [rbp-160h],rax
    mov     qword ptr [rbp-158h],4
    mov     qword ptr [rbp-150h],4
    mov     rdi,[rbp-108h]
    mov     [rbp-148h],rdi
    mov     edi,0FFFFFEC0h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-48h]
L15:
    mov     rax,[rbp-100h]
    mov     [rbp-118h],rax
    mov     rdx,[rbp-108h]
    mov     [rbp-110h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    jmp     L4
L16:
    mov     rax,[rbp-40h]
    mov     [rbp-110h],rax
    mov     [rbp-160h],rax
    mov     qword ptr [rbp-158h],4
    mov     qword ptr [rbp-150h],4
    mov     rdi,[rbp-60h]
    mov     [rbp-148h],rdi
    mov     edi,0FFFFFEC0h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-48h]
L17:
    mov     rax,[rbp-0F8h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-50h],rdx
    mov     [rbp-108h],rax
    mov     [rbp-100h],rdx
    mov     edi,0FFFFFEA0h
    mov     esi,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rbp-28h]
    mov     [rbp-150h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-148h],rdx
    call    fn9
    nop     [rcx-30h]
    jmp     L10
L18:
    mov     rax,[rbp-48h]
    mov     [rbp-108h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-110h],rdx
    mov     [rbp-160h],rax
    mov     [rbp-158h],rdx
    mov     qword ptr [rbp-150h],4
    mov     qword ptr [rbp-148h],4
    mov     r8,[rbp-60h]
    mov     [rbp-140h],r8
    mov     edi,0FFFFFEC8h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx-58h]
L19:
    imul    rax,[rbp-60h],4
    mov     [rbp-128h],rax
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFED8h
    call    ryo_h_Memcpy
    jmp     L11

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    cmp     rax,0Dh
    jae     L0
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rdx
    mov     [rbp-8],rax
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],0Ch
    mov     r8,[rbp+20h]
    mov     [rbp-28h],r8
    call    fn0
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],0Ah
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn1
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],9
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn2
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn3
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],0Bh
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn4
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn5
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn6
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],3
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn7
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],0Bh
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn8
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],7
    mov     qword ptr [rbp-30h],9
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn9
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],8
    mov     qword ptr [rbp-30h],0Ah
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn10
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn11
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],2
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn12
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn13
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],7
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn14
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],9
    mov     qword ptr [rbp-30h],0Ah
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn15
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0Bh
    mov     qword ptr [rbp-30h],0Ch
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn16
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn17
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],9
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn18
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],8
    mov     qword ptr [rbp-30h],0Bh
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn19
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0Ah
    mov     qword ptr [rbp-30h],0Ch
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn20
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn21
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn22
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn23
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],0Bh
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn24
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],9
    mov     qword ptr [rbp-30h],0Ah
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn25
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],1
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn26
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn27
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],9
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn28
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],7
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn29
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0Ah
    mov     qword ptr [rbp-30h],0Bh
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn30
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],3
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn31
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn32
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn33
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],9
    mov     qword ptr [rbp-30h],0Ah
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn34
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],2
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn35
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn36
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn37
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn38
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],3
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn39
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn40
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn41
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],8
    mov     qword ptr [rbp-30h],9
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn42
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn43
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn44
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     qword ptr [rbp-78h],1
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-0B0h],rdi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rsi
    call    fn0
    nop     [rcx-1]
    mov     qword ptr [rbp-78h],3
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rdx
    mov     qword ptr [rbp-78h],2
    mov     rdi,[rbp+10h]
    imul    rcx,[rbp-78h],8
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rdi
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rdi
    mov     r8,[rbp+20h]
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdi
    call    fn1
    nop     [rcx-2]
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFFFh
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-18h],8
    add     rax,rcx
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-1]
    xor     dl,1
    mov     [rbp-3],dl
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-20h],8
    add     rax,rcx
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFFEh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp-78h]
    add     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rbp-20h],rsi
    movzx   edi,byte ptr [rbp-2]
    xor     dil,1
    mov     [rbp-3],dil
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp-78h]
    add     rdx,[rbp-38h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rbp-28h],rsi
    mov     rdi,[rbp-20h]
    mov     [rbp-40h],rdi
    mov     r8,[rbp-10h]
    mov     [rbp-48h],r8
    mov     [rbp-38h],rdi
    mov     [rbp-30h],r8
    mov     r9,[rbp+20h]
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rdi
    mov     [rbp-0A0h],r8
    call    fn2
    nop     [rcx-3]
    mov     rax,[rbp-28h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn3
    nop     [rcx-4]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-20h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-10h]
    mov     [rbp-0A0h],rsi
    call    fn4
    nop     [rcx-30h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-18h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-0A0h],rsi
    call    fn5
    nop     [rcx-38h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-20h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-0A0h],rsi
    call    fn6
    nop     [rcx-48h]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-10h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-0A0h],rsi
    call    fn7
    nop     [rcx-40h]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-18h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-0A0h],rsi
    call    fn8
    nop     [rcx-50h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-28h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-50h]
    mov     [rbp-0A0h],rsi
    call    fn9
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-68h],rdx
    mov     [rbp-58h],rax
    mov     [rbp-50h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn10
    nop     [rcx-5]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-48h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-0A0h],rsi
    call    fn11
    nop     [rcx-50h]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-40h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-0A0h],rsi
    call    fn12
    nop     [rcx-58h]
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L0
    mov     rsi,[rbp-30h]
    mov     [rbp-60h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-68h],rdi
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdi
    mov     qword ptr [rbp-0A0h],8
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx]
L0:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],8
    mov     [rbp-80h],rdx
    mov     edi,18h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],1
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L1
    mov     r8,[rbp-50h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],8
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx]
L1:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],8
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L2
    mov     r8,[rbp-58h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],8
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx]
L2:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],8
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],3
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],8
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L3
    mov     r8,[rbp-38h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],8
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx]
L3:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],8
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     qword ptr [rbp-78h],1
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-78h],4
    add     rdx,rcx
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-30h],rsi
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rsi
    mov     rdi,[rbp+20h]
    mov     [rbp-0B0h],rdi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rsi
    call    fn0
    nop     [rcx-1]
    mov     qword ptr [rbp-78h],3
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-78h],4
    add     rdx,rcx
    mov     [rbp-28h],rdx
    mov     [rbp-20h],rdx
    mov     qword ptr [rbp-78h],2
    mov     rdi,[rbp+10h]
    imul    rcx,[rbp-78h],4
    add     rdi,rcx
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rdi
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rdi
    mov     r8,[rbp+20h]
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdi
    call    fn1
    nop     [rcx-2]
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFFFh
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-18h],4
    add     rax,rcx
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-1]
    xor     dl,1
    mov     [rbp-3],dl
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-20h],4
    add     rax,rcx
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFFEh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp-78h]
    add     rdx,[rbp-30h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     [rbp-20h],rsi
    movzx   edi,byte ptr [rbp-2]
    xor     dil,1
    mov     [rbp-3],dil
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp-78h]
    add     rdx,[rbp-38h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     [rbp-28h],rsi
    mov     rdi,[rbp-20h]
    mov     [rbp-40h],rdi
    mov     r8,[rbp-10h]
    mov     [rbp-48h],r8
    mov     [rbp-38h],rdi
    mov     [rbp-30h],r8
    mov     r9,[rbp+20h]
    mov     [rbp-0B0h],r9
    mov     [rbp-0A8h],rdi
    mov     [rbp-0A0h],r8
    call    fn2
    nop     [rcx-3]
    mov     rax,[rbp-28h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     [rbp-38h],rax
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn3
    nop     [rcx-4]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-20h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-10h]
    mov     [rbp-0A0h],rsi
    call    fn4
    nop     [rcx-30h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-18h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-0A0h],rsi
    call    fn5
    nop     [rcx-38h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-20h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-0A0h],rsi
    call    fn6
    nop     [rcx-48h]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-10h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-0A0h],rsi
    call    fn7
    nop     [rcx-40h]
    movzx   eax,byte ptr [rbp-3]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-18h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-0A0h],rsi
    call    fn8
    nop     [rcx-50h]
    movzx   eax,byte ptr [rbp-4]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-28h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-50h]
    mov     [rbp-0A0h],rsi
    call    fn9
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-68h],rdx
    mov     [rbp-58h],rax
    mov     [rbp-50h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rax
    mov     [rbp-0A0h],rdx
    call    fn10
    nop     [rcx-5]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-48h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-0A0h],rsi
    call    fn11
    nop     [rcx-50h]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-0A8h],al
    mov     rdx,[rbp-40h]
    mov     [rbp-0B0h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-0A0h],rsi
    call    fn12
    nop     [rcx-58h]
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L0
    mov     rsi,[rbp-30h]
    mov     [rbp-60h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-68h],rdi
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdi
    mov     qword ptr [rbp-0A0h],4
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx]
L0:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],4
    mov     [rbp-80h],rdx
    mov     edi,18h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],1
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L1
    mov     r8,[rbp-50h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],4
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx]
L1:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],4
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],2
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L2
    mov     r8,[rbp-58h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],4
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx]
L2:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],4
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rbp-78h],3
    mov     rdx,[rbp+18h]
    imul    rcx,[rbp-78h],4
    add     rdx,rcx
    mov     [rbp-60h],rdx
    mov     byte ptr [rbp-71h],1
    test    byte ptr [rbp-71h],0FFh
    je      L3
    mov     r8,[rbp-38h]
    mov     [rbp-68h],r8
    mov     [rbp-70h],rdx
    mov     [rbp-0B0h],r8
    mov     [rbp-0A8h],rdx
    mov     qword ptr [rbp-0A0h],4
    mov     qword ptr [rbp-98h],4
    mov     qword ptr [rbp-90h],1
    mov     edi,0FFFFFF78h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx]
L3:
    mov     qword ptr [rbp-78h],1
    imul    rdx,[rbp-78h],4
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFF80h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-60h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-58h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-50h],rsi
    call    fn0
    nop     [rcx]
    mov     qword ptr [rbp-30h],4
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-30h],8
    add     rdx,rcx
    mov     [rbp-10h],rdx
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    imul    rcx,[rbp-30h],8
    add     rdi,rcx
    mov     [rbp-10h],rdi
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-50h],r8
    call    fn1
    nop     [rcx]
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     [rbp-60h],rax
    mov     qword ptr [rbp-58h],8
    mov     qword ptr [rbp-50h],4
    mov     qword ptr [rbp-48h],8
    mov     edi,0FFFFFFC0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx]
L2:
    mov     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-20h],8
    mov     [rbp-10h],rax
    mov     rsi,[rbp-20h]
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-48h],rdx
    call    fn4
    nop     [rcx]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort8_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-60h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-58h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-50h],rsi
    call    fn0
    nop     [rcx]
    mov     qword ptr [rbp-30h],4
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp-30h],4
    add     rdx,rcx
    mov     [rbp-10h],rdx
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    imul    rcx,[rbp-30h],4
    add     rdi,rcx
    mov     [rbp-10h],rdi
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-50h],r8
    call    fn1
    nop     [rcx]
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     [rbp-60h],rax
    mov     qword ptr [rbp-58h],4
    mov     qword ptr [rbp-50h],4
    mov     qword ptr [rbp-48h],8
    mov     edi,0FFFFFFC0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx]
L2:
    mov     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-20h],8
    mov     [rbp-10h],rax
    mov     rsi,[rbp-20h]
    mov     [rbp-8],rsi
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-48h],rdx
    call    fn4
    nop     [rcx]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    cmp     rax,9
    jae     L0
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rdx
    mov     [rbp-8],rax
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],3
    mov     r8,[rbp+20h]
    mov     [rbp-28h],r8
    call    fn0
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn1
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn2
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn3
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn4
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn5
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn6
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn7
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],2
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn8
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],3
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn9
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn10
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],7
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn11
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn12
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn13
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn14
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],0
    mov     qword ptr [rbp-30h],1
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn15
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn16
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn17
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],8
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn18
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],2
    mov     qword ptr [rbp-30h],3
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn19
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],4
    mov     qword ptr [rbp-30h],5
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn20
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],6
    mov     qword ptr [rbp-30h],7
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn21
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],1
    mov     qword ptr [rbp-30h],2
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn22
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],3
    mov     qword ptr [rbp-30h],4
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn23
    nop     [rcx]
    mov     rax,[rbp-8]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-38h],5
    mov     qword ptr [rbp-30h],6
    mov     rdi,[rbp+20h]
    mov     [rbp-28h],rdi
    call    fn24
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    imul    rcx,[rbp+18h],4
    add     rax,rcx
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    imul    rcx,[rbp+20h],4
    add     rdx,rcx
    mov     [rbp-18h],rdx
    mov     [rbp-38h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rax
    mov     rsi,[rbp+28h]
    mov     [rbp-90h],rsi
    mov     [rbp-88h],rdx
    mov     [rbp-80h],rax
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    mov     [rbp-88h],al
    mov     rdx,[rbp-18h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-10h]
    mov     [rbp-80h],rsi
    call    fn1
    nop     [rcx-28h]
    movzx   eax,byte ptr [rbp-19h]
    mov     [rbp-88h],al
    mov     rdx,[rbp-10h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-80h],rsi
    call    fn2
    nop     [rcx-30h]
    mov     rax,[rbp-30h]
    mov     [rbp-40h],rax
    mov     eax,[rax]
    mov     [rbp-34h],eax
    mov     [rbp-38h],eax
    mov     [rbp-20h],eax
    mov     rdx,[rbp-28h]
    mov     [rbp-38h],rdx
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rbp-28h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-49h],0
    test    byte ptr [rbp-49h],0FFh
    je      L2
    mov     byte ptr [rbp-1Ah],1
    jmp     L3
L2:
    mov     byte ptr [rbp-1Ah],0
L3:
    mov     rax,[rbp-40h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],4
    movzx   edi,byte ptr [rbp-1Ah]
    mov     [rbp-78h],dil
    mov     edi,0FFFFFF90h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-8]
L4:
    mov     qword ptr [rbp-50h],1
    imul    rdx,[rbp-50h],4
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rbp-38h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-48h],rdx
    mov     [rbp-90h],rax
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-8]
L6:
    mov     qword ptr [rbp-50h],1
    imul    rdx,[rbp-50h],4
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::stable::AlignedStorage::<(u32, u32), 4096>::as_uninit_slice_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     qword ptr [rbp-60h],8
    cmp     qword ptr [rbp-60h],0
    sete    [rbp-11h]
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFF70h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-58h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-60h],1000h
    mov     qword ptr [rbp-68h],8
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF98h
    call    ryo_h_DivUW64
    mov     rax,[rbp+10h]
    mov     [rbp-58h],rax
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-48h],1000h
    mov     [rbp-28h],rax
    mov     rsi,[rbp-48h]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rax
    mov     rdi,[rbp-28h]
    mov     [rbp-38h],rdi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L3
    mov     r10,[rbp-28h]
    mov     [rbp-40h],r10
    mov     [rbp-90h],r10
    mov     qword ptr [rbp-88h],8
    mov     qword ptr [rbp-80h],4
    mov     rax,[rbp-30h]
    mov     [rbp-78h],rax
    mov     edi,0FFFFFF90h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-28h]
L3:
    mov     rax,[rbp-38h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-40h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    cmp     rax,[rbp+30h]
    jb      L1
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-38h],rsi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-90h],rax
    call    fn0
    nop     [rcx-30h]
    mov     rax,[rbp-30h]
    mov     [rbp-20h],rax
    movzx   edx,byte ptr [rbp-28h]
    mov     [rbp-0Bh],dl
    cmp     rax,[rbp-18h]
    setbe   [rbp-9]
    cmp     rax,[rbp+30h]
    jb      L1
    test    byte ptr [rbp-0Bh],0FFh
    je      L0
    cmp     rax,0
    jb      L5
    jmp     L8
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rbp-20h]
    shl     rax,1
    mov     [rbp-30h],rax
    or      rax,1
    mov     [rbp-28h],rax
    mov     [rbp-8],rax
    jmp     L4
L1:
    test    byte ptr [rbp+38h],0FFh
    je      L3
    call    fn1
    nop     [rcx-28h]
    mov     rax,[rbp-28h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-98h],rdx
    call    fn2
    nop     [rcx-20h]
    jmp     L9
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp-20h]
    shl     rax,1
    mov     [rbp-30h],rax
    or      rax,1
    mov     [rbp-28h],rax
    mov     [rbp-8],rax
    jmp     L4
L3:
    mov     rax,[rbp+30h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-98h],rdx
    call    fn3
    nop     [rcx-20h]
    jmp     L16
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L5:
    mov     qword ptr [rbp-0A0h],0
    mov     rdx,[rbp-20h]
    mov     [rbp-98h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-90h],rsi
    mov     edi,0FFFFFF78h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-9]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-48h],rdx
    mov     [rbp-58h],rax
    mov     [rbp-40h],rax
    mov     rsi,[rbp-20h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rax
    mov     [rbp-28h],rsi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    call    fn8
    nop     [rcx-9]
    jmp     L0
L9:
    cmp     qword ptr [rbp-20h],0
    jb      L14
    jmp     L15
    nop     [rax+rax]
L10:
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-48h],rdx
    mov     [rbp-58h],rax
    mov     [rbp-40h],rax
    mov     rsi,[rbp-20h]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rax
    mov     [rbp-28h],rsi
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF70h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     dword ptr [rbp-78h],0
    mov     qword ptr [rbp-80h],0
    mov     rsi,[rbp+40h]
    mov     [rbp-70h],rsi
    call    fn9
    nop     [rcx-9]
    jmp     L2
    xchg    ax,ax
L11:
    mov     qword ptr [rbp-0A0h],0
    mov     rdx,[rbp-20h]
    mov     [rbp-98h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-90h],rsi
    mov     edi,0FFFFFF78h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L12
    call    rax
    nop     [rcx-9]
    jmp     L13
L12:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L13:
    call    ryo_h_Unreachable
    ud2
L14:
    jmp     L11
L15:
    mov     rax,[rbp-18h]
    cmp     rax,[rbp-20h]
    jae     L10
    jmp     L11
L16:
    mov     rax,[rbp-20h]
    shl     rax,1
    mov     [rbp-28h],rax
    mov     [rbp-8],rax
    jmp     L4

fn core::slice::sort::stable::drift::logical_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-38h],rdx
    cmp     rax,rdx
    setbe   [rbp-29h]
    test    byte ptr [rbp-29h],0FFh
    je      L1
    mov     rdi,[rbp+30h]
    mov     [rbp-40h],rdi
    and     rdi,1
    mov     [rbp-38h],rdi
    cmp     rdi,1
    sete    [rbp-2Ah]
    test    byte ptr [rbp-2Ah],0FFh
    je      L0
    jmp     L1
L0:
    mov     rax,[rbp+38h]
    mov     [rbp-40h],rax
    and     rax,1
    mov     [rbp-38h],rax
    cmp     rax,1
    sete    [rbp-2Bh]
    test    byte ptr [rbp-2Bh],0FFh
    je      L5
L1:
    mov     rax,[rbp+30h]
    mov     [rbp-20h],rax
    and     rax,1
    mov     [rbp-38h],rax
    cmp     rax,1
    sete    [rbp-2Ch]
    test    byte ptr [rbp-2Ch],0FFh
    jne     L2
    mov     rdi,[rbp-20h]
    shr     rdi,1
    mov     [rbp-10h],rdi
    cmp     rdi,0
    jb      L11
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp+38h]
    mov     [rbp-40h],rax
    and     rax,1
    mov     [rbp-38h],rax
    cmp     rax,1
    sete    [rbp-2Ch]
    test    byte ptr [rbp-2Ch],0FFh
    je      L3
    jmp     L4
L3:
    mov     rax,[rbp-20h]
    shr     rax,1
    mov     [rbp-18h],rax
    mov     rdx,[rbp-28h]
    cmp     rdx,rax
    jb      L13
    jmp     L16
    xchg    ax,ax
L4:
    mov     rax,[rbp-20h]
    shr     rax,1
    mov     [rbp-38h],rax
    mov     edi,0FFFFFF50h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF60h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-38h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+40h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-18h]
    mov     rax,[rbp-28h]
    shl     rax,1
    mov     [rbp-40h],rax
    or      rax,1
    mov     [rbp-38h],rax
    mov     [rbp-8],rax
    jmp     L6
L5:
    mov     rax,[rbp-28h]
    shl     rax,1
    mov     [rbp-38h],rax
    mov     [rbp-8],rax
L6:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L7:
    mov     rax,[rbp+10h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-58h],rdx
    mov     [rbp-68h],rax
    mov     [rbp-50h],rax
    mov     rsi,[rbp-10h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rax
    mov     [rbp-38h],rsi
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF60h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-90h],rax
    call    fn1
    nop     [rcx-8]
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    mov     qword ptr [rbp-0B0h],0
    mov     rdx,[rbp-10h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-0A0h],rsi
    mov     edi,0FFFFFF68h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx-18h]
    jmp     L10
L9:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L10:
    call    ryo_h_Unreachable
    ud2
L11:
    jmp     L8
L12:
    mov     rax,[rbp-28h]
    cmp     rax,[rbp-10h]
    jae     L7
    jmp     L8
L13:
    mov     rax,[rbp-18h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-0A0h],rsi
    mov     edi,0FFFFFF68h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L14
    call    rax
    nop     [rcx-18h]
    jmp     L15
L14:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L15:
    call    ryo_h_Unreachable
    ud2
L16:
    mov     rax,[rbp-28h]
    sub     rax,[rbp-18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-60h],rsi
    mov     [rbp-70h],rdx
    imul    rcx,[rbp-18h],8
    add     rdx,rcx
    mov     [rbp-78h],rdx
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rax
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF60h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-90h],rax
    call    fn10
    nop     [rcx-10h]
    jmp     L4

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,390h
    mov     rax,[rbp+18h]
    mov     [rbp-60h],rax
    cmp     rax,2
    jae     L0
    jmp     L18
L0:
    mov     rax,[rbp-60h]
    mov     [rbp-70h],rax
    cmp     rax,0
    sete    [rbp-79h]
    test    byte ptr [rbp-79h],0FFh
    je      L19
    mov     edi,0FFFFFC70h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-348h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L3:
    mov     qword ptr [rbp-350h],2
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFCB0h
    call    ryo_h_DivUW64
    mov     rax,[rbp-60h]
    sub     rax,[rbp-88h]
    mov     [rbp-80h],rax
    mov     [rbp-390h],rax
    mov     qword ptr [rbp-388h],40h
    call    fn4
    nop     [rcx-70h]
    jmp     L25
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rbp-60h]
    mov     [rbp-390h],rax
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-70h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym7]
L6:
    nop     [rax+rax]
    nop     [rax]
L7:
    mov     qword ptr [rbp-78h],0
    mov     edi,0FFFFFD78h
    lea     rsi,[k8]
    mov     edx,210h
    call    ryo_h_Const
    lea     rax,[rbp-288h]
    mov     [rbp-50h],rax
    mov     [rbp-298h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-290h],rdx
    mov     edi,0FFFFFD2Eh
    lea     rsi,[k9]
    mov     edx,42h
    call    ryo_h_Const
    lea     rax,[rbp-2D2h]
    mov     [rbp-58h],rax
    mov     [rbp-2E8h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-2E0h],rdx
    mov     qword ptr [rbp-2E8h],0
    mov     qword ptr [rbp-38h],1
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    mov     rax,[rbp-2E8h]
    mov     [rbp-2F0h],rax
    cmp     rax,[rbp-60h]
    jae     L10
    mov     rdx,[rbp-2E8h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp-60h]
    cmp     rsi,rdx
    jb      L26
    jmp     L29
    nop     [rax+rax]
    xchg    ax,ax
L9:
    mov     rax,[rbp-2E8h]
    mov     [rbp-2F8h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-308h],rdx
    shr     rdx,1
    mov     [rbp-300h],rdx
    sub     rax,rdx
    mov     [rbp-2F0h],rax
    mov     rsi,[rbp-2E8h]
    mov     [rbp-2F8h],rsi
    mov     rdi,[rbp-2E8h]
    mov     [rbp-308h],rdi
    mov     r8,[rbp-18h]
    mov     [rbp-318h],r8
    shr     r8,1
    mov     [rbp-310h],r8
    add     rdi,r8
    mov     [rbp-300h],rdi
    mov     r9,[rbp-68h]
    mov     [rbp-308h],r9
    mov     [rbp-318h],rax
    mov     [rbp-320h],rsi
    add     rax,rsi
    mov     [rbp-310h],rax
    mov     [rbp-328h],rdi
    add     rsi,rdi
    mov     [rbp-318h],rsi
    imul    r9,rax
    mov     [rbp-330h],r9
    mov     r10,[rbp-308h]
    imul    r10,rsi
    mov     [rbp-338h],r10
    xor     r9,r10
    mov     [rbp-328h],r9
    mov     edi,0FFFFFCB4h
    mov     esi,0FFFFFCD8h
    call    ryo_h_CtlzW64
    mov     eax,[rbp-34Ch]
    mov     [rbp-2D8h],eax
    jmp     L30
L10:
    mov     qword ptr [rbp-18h],1
    mov     byte ptr [rbp-21h],0
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    mov     rax,[rbp-78h]
    mov     [rbp-2F0h],rax
    cmp     rax,1
    jbe     L14
    mov     rsi,[rbp-78h]
    mov     [rbp-300h],rsi
    sub     rsi,1
    mov     [rbp-2F8h],rsi
    mov     rdi,[rbp-2E0h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rbp-2F0h],rdi
    movzx   edi,byte ptr [rdi]
    mov     [rbp-2D5h],dil
    movzx   r8d,byte ptr [rbp-21h]
    mov     [rbp-2D6h],r8b
    cmp     dil,r8b
    jb      L13
    mov     r9,[rbp-78h]
    mov     [rbp-308h],r9
    sub     r9,1
    mov     [rbp-300h],r9
    mov     r10,[rbp-290h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rbp-2F8h],r10
    mov     r10,[r10]
    mov     [rbp-2F0h],r10
    mov     [rbp-308h],r10
    shr     r10,1
    mov     [rbp-300h],r10
    mov     r11,[rbp-38h]
    mov     [rbp-310h],r11
    shr     r11,1
    mov     [rbp-308h],r11
    add     r10,r11
    mov     [rbp-2F8h],r10
    mov     rax,[rbp-2E8h]
    mov     [rbp-308h],rax
    sub     rax,r10
    mov     [rbp-300h],rax
    mov     rdx,[rbp-2E8h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-330h],rsi
    mov     r9,[rbp+18h]
    mov     [rbp-328h],r9
    mov     byte ptr [rbp-349h],1
    test    byte ptr [rbp-349h],0FFh
    je      L32
    jmp     L31
    nop     [rax+rax]
L12:
    mov     rax,[rbp-78h]
    sub     rax,1
    mov     [rbp-78h],rax
    jmp     L11
L13:
    jmp     L14
L14:
    mov     rax,[rbp-38h]
    mov     [rbp-2F0h],rax
    mov     rdx,[rbp-78h]
    mov     [rbp-300h],rdx
    mov     rsi,[rbp-290h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rbp-2F8h],rsi
    mov     rcx,[rbp-2F0h]
    mov     [rsi],rcx
    mov     rdi,[rbp-78h]
    mov     [rbp-2F8h],rdi
    mov     r8,[rbp-2E0h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rbp-2F0h],r8
    movzx   ecx,byte ptr [rbp-21h]
    mov     [r8],cl
    mov     r9,[rbp-78h]
    add     r9,1
    mov     [rbp-78h],r9
    mov     r10,[rbp-2E8h]
    mov     [rbp-2F0h],r10
    cmp     r10,[rbp-60h]
    jb      L15
    mov     r11,[rbp-38h]
    mov     [rbp-2F8h],r11
    and     r11,1
    mov     [rbp-2F0h],r11
    cmp     r11,1
    sete    [rbp-2D3h]
    test    byte ptr [rbp-2D3h],0FFh
    je      L17
    jmp     L16
L15:
    mov     rax,[rbp-18h]
    mov     [rbp-2F8h],rax
    shr     rax,1
    mov     [rbp-2F0h],rax
    mov     rdx,[rbp-2E8h]
    add     rdx,rax
    mov     [rbp-2E8h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-38h],rsi
    jmp     L8
L16:
    jmp     L18
L17:
    mov     edi,0FFFFFC70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC80h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+38h]
    mov     [rbp-370h],rax
    call    fn10
    nop     [rcx-38h]
L18:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L19:
    mov     rax,4000000000000000h
    mov     [rbp-350h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFCB0h
    mov     edx,0FFFFFF90h
    call    ryo_h_DivUW64
    test    byte ptr [rbp-79h],0FFh
    je      L22
    mov     edi,0FFFFFC70h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    lea     rdi,[sym12]
    lea     rsi,[site13]
    mov     edx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L20
    call    rax
    nop     [rcx-348h]
    jmp     L21
L20:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym14]
L21:
    call    ryo_h_Unreachable
    ud2
L22:
    mov     rax,4000000000000000h
    mov     [rbp-350h],rax
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFCB0h
    mov     edx,0FFFFFF90h
    call    ryo_h_RemUW64
    cmp     qword ptr [rbp-88h],0
    jbe     L23
    mov     rdx,[rbp-78h]
    add     rdx,1
    mov     [rbp-68h],rdx
    jmp     L24
L23:
    mov     rax,[rbp-78h]
    mov     [rbp-68h],rax
L24:
    cmp     qword ptr [rbp-60h],1000h
    jbe     L3
    jmp     L4
L25:
    jmp     L7
L26:
    mov     rax,[rbp-20h]
    mov     [rbp-390h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-388h],rdx
    mov     rsi,[rbp-60h]
    mov     [rbp-380h],rsi
    mov     edi,0FFFFFC88h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[sym16]
    lea     rsi,[site17]
    mov     edx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L27
    call    rax
    nop     [rcx-58h]
    jmp     L28
L27:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym18]
L28:
    call    ryo_h_Unreachable
    ud2
L29:
    mov     rax,[rbp-60h]
    sub     rax,[rbp-20h]
    mov     [rbp-300h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-320h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-318h],rsi
    mov     [rbp-328h],rdx
    imul    rcx,[rbp-20h],8
    add     rdx,rcx
    mov     [rbp-330h],rdx
    mov     [rbp-310h],rdx
    mov     [rbp-308h],rax
    mov     [rbp-2F8h],rdx
    mov     [rbp-2F0h],rax
    mov     rdi,[rbp-70h]
    mov     [rbp-300h],rdi
    mov     edi,0FFFFFC70h
    mov     esi,0FFFFFD08h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC80h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-300h]
    mov     [rbp-370h],rax
    movzx   edx,byte ptr [rbp+30h]
    mov     [rbp-368h],dl
    mov     rsi,[rbp+38h]
    mov     [rbp-360h],rsi
    call    fn19
    nop     [rcx-18h]
    jmp     L9
L30:
    mov     edi,0FFFFFFDFh
    mov     esi,0FFFFFD28h
    call    ryo_h_TruncW32W8
    jmp     L11
L31:
    mov     rax,[rbp-300h]
    mov     [rbp-390h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-388h],rdx
    mov     rsi,[rbp-60h]
    mov     [rbp-380h],rsi
    mov     edi,0FFFFFC88h
    lea     rsi,[k20]
    call    ryo_h_AddrAbs
    call    fn21
    nop     [rcx-58h]
L32:
    mov     rax,[rbp-30h]
    sub     rax,[rbp-300h]
    mov     [rbp-338h],rax
    mov     rdx,[rbp-330h]
    mov     [rbp-340h],rdx
    imul    rcx,[rbp-300h],8
    add     rdx,rcx
    mov     [rbp-348h],rdx
    mov     [rbp-320h],rdx
    mov     [rbp-318h],rax
    mov     [rbp-310h],rdx
    mov     [rbp-308h],rax
    mov     rsi,[rbp-38h]
    mov     [rbp-318h],rsi
    mov     edi,0FFFFFC70h
    mov     esi,0FFFFFCF0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC80h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-2F0h]
    mov     [rbp-370h],rax
    mov     rdx,[rbp-318h]
    mov     [rbp-368h],rdx
    mov     rsi,[rbp+38h]
    mov     [rbp-360h],rsi
    call    fn22
    nop     [rcx-38h]
    jmp     L12

fn core::slice::sort::stable::drift::stable_quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    or      rax,1
    mov     [rbp-10h],rax
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFC4h
    mov     esi,0FFFFFFE8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFC4h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L3
    .long   L6
    .long   L2
    nop     [rax+rax]
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFC0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp-18h]
    mov     [rbp-28h],rax
    mov     [rbp-38h],rax
    mov     edi,0FFFFFFC4h
    mov     esi,0FFFFFFC8h
    call    ryo_h_CtlzW64
    mov     eax,[rbp-3Ch]
    mov     [rbp-2Ch],eax
    mov     dword ptr [rbp-3Ch],3Fh
    mov     esi,[rbp-3Ch]
    sub     esi,eax
    mov     [rbp-4],esi
    mov     dword ptr [rbp-3Ch],2
    mov     r8d,[rbp-3Ch]
    imul    r8d,esi
    mov     [rbp-8],r8d
    mov     edi,0FFFFFF80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     eax,[rbp-8]
    mov     [rbp-58h],eax
    mov     qword ptr [rbp-60h],0
    mov     rsi,[rbp+30h]
    mov     [rbp-50h],rsi
    call    fn4
    nop     [rcx]
    jmp     L1

fn core::slice::sort::stable::driftsort_main::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}, std::vec::Vec<(u32, u32)>>
    push    rbp
    mov     rbp,rsp
    mov     eax,2090h
    call    ryo_probe_stack
    sub     rsp,2090h
    mov     byte ptr [rbp-19h],0
    mov     qword ptr [rbp-2048h],8
    cmp     qword ptr [rbp-2048h],0
    sete    [rbp-1]
    test    byte ptr [rbp-1],0FFh
    je      L2
    mov     edi,0FFFFDF70h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFDFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-2040h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rbp-2048h],7A1200h
    mov     qword ptr [rbp-2050h],8
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFB0h
    call    ryo_h_DivUW64
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-2048h],2
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFDFB8h
    call    ryo_h_DivUW64
    mov     rax,[rbp-38h]
    sub     rax,[rbp-58h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-2090h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-2088h],rsi
    call    fn4
    nop     [rcx-58h]
    jmp     L11
    nop     [rax+rax]
L3:
    mov     rax,[rbp-10h]
    mov     [rbp-1068h],rax
    cmp     rax,[rbp-40h]
    jb      L4
    jmp     L5
L4:
    mov     rax,[rbp-40h]
    mov     [rbp-2090h],rax
    call    fn5
    nop     [rcx-1078h]
    mov     byte ptr [rbp-19h],1
    mov     edi,0FFFFEFA8h
    mov     esi,0FFFFEF88h
    mov     edx,18h
    call    ryo_h_Copy
    lea     rax,[rbp-1058h]
    mov     [rbp-1068h],rax
    mov     [rbp-2090h],rax
    call    fn6
    nop     [rcx-18h]
L5:
    call    fn7
    nop     [rcx-1070h]
    imul    rax,[rbp-1070h],2
    mov     [rbp-1068h],rax
    mov     rdx,[rbp-38h]
    cmp     rdx,rax
    setbe   [rbp-1059h]
    mov     edi,0FFFFDF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFDF80h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    movzx   eax,byte ptr [rbp-1059h]
    mov     [rbp-2070h],al
    mov     rdx,[rbp+20h]
    mov     [rbp-2068h],rdx
    call    fn8
    nop     [rcx-18h]
    test    byte ptr [rbp-19h],0FFh
    jne     L8
    nop     [rax+rax]
    nop     [rax]
L6:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L7:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
L8:
    lea     rax,[rbp-1058h]
    mov     [rbp-2048h],rax
    mov     [rbp-2090h],rax
    call    fn9
    nop     [rcx-2048h]
    jmp     L6
    nop
L9:
    lea     rax,[rbp-1058h]
    mov     [rbp-2048h],rax
    mov     [rbp-2090h],rax
    call    fn10
    nop     [rcx-2048h]
    jmp     L7
    nop     [rax+rax]
    nop     [rax]
L10:
    test    byte ptr [rbp-19h],0FFh
    je      L7
    jmp     L9
L11:
    mov     rax,[rbp-50h]
    mov     [rbp-2090h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-2088h],rdx
    call    fn11
    nop     [rcx-48h]
    mov     rax,[rbp-48h]
    mov     [rbp-2090h],rax
    mov     qword ptr [rbp-2088h],30h
    call    fn12
    nop     [rcx-40h]
    mov     edi,0FFFFDFC0h
    lea     rsi,[k13]
    mov     edx,1
    call    ryo_h_Const
    lea     rax,[rbp-2040h]
    mov     [rbp-2048h],rax
    lea     rax,[rax+1]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],1
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+2]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],2
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+4]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],4
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+8]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],8
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+10h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],10h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+20h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],20h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+40h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],40h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+80h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],80h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+100h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],100h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+200h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],200h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+400h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],400h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp-2048h]
    lea     rax,[rax+800h]
    mov     [rbp-2050h],rax
    mov     qword ptr [rbp-2058h],800h
    mov     edi,0FFFFDFB0h
    mov     esi,0FFFFDFB8h
    mov     edx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     edi,0FFFFEFC0h
    mov     esi,0FFFFDFC0h
    mov     edx,1000h
    call    ryo_h_Copy
    lea     rax,[rbp-1040h]
    mov     [rbp-1048h],rax
    mov     [rbp-2090h],rax
    call    fn14
    nop     [rcx-18h]
    jmp     L3
    xchg    ax,ax
L12:
    lea     rdi,[sym15]
    lea     rsi,[site16]
    mov     edx,0FFFFDFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-2040h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym17]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L10
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_down::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-30h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L9
    jmp     L8
    nop
L1:
    test    byte ptr [rbp-29h],0FFh
    je      L2
    mov     rdx,[rbp-8]
    mov     [rbp-18h],rdx
    jmp     L3
L2:
    mov     rax,[rbp-10h]
    mov     [rbp-18h],rax
L3:
    mov     rax,[rbp-18h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-40h],rdx
    mov     byte ptr [rbp-51h],1
    test    byte ptr [rbp-51h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L4:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-38h],rax
    mov     [rbp-28h],rax
    cmp     rax,[rbp+20h]
    jne     L6
    nop     [rax+rax]
    nop
L5:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L6:
    jmp     L0
L7:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-30h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L12
    jmp     L11
L8:
    mov     rax,[rbp-30h]
    mov     [rbp-8],rax
    jmp     L7
L9:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-30h]
    imul    rcx,[rbp-58h],8
    add     rdx,rcx
    mov     [rbp-8],rdx
    jmp     L7
    nop     [rax]
L10:
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L15
    jmp     L14
L11:
    mov     rax,[rbp-30h]
    mov     [rbp-10h],rax
    jmp     L10
L12:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-30h]
    imul    rcx,[rbp-58h],8
    add     rdx,rcx
    mov     [rbp-10h],rdx
    jmp     L10
L13:
    mov     rax,[rbp-30h]
    mov     [rbp+28h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-50h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-90h],rdi
    mov     [rbp-88h],rdx
    mov     [rbp-80h],rsi
    call    fn0
    nop     [rcx-29h]
    jmp     L1
L14:
    mov     rax,[rbp+28h]
    mov     [rbp-30h],rax
    jmp     L13
L15:
    mov     qword ptr [rbp-58h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp+28h]
    imul    rcx,[rbp-58h],8
    add     rdx,rcx
    mov     [rbp-30h],rdx
    jmp     L13
L16:
    mov     rax,[rbp-18h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-50h],rdx
    mov     [rbp-90h],rax
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],8
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L17:
    mov     qword ptr [rbp-58h],1
    imul    rdx,[rbp-58h],8
    mov     [rbp-60h],rdx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFA0h
    call    ryo_h_Memcpy
    movzx   eax,byte ptr [rbp-29h]
    xor     al,1
    mov     [rbp-2Ah],al
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD6h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-8]
    imul    rcx,[rbp-40h],8
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-38h]
    mov     [rdx+10h],rcx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-10h]
    imul    rcx,[rbp-40h],8
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-38h]
    mov     [rdx+8],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+10h]
    mov     [rbp-38h],rsi
    mov     [rbp-20h],rsi
    cmp     rsi,[rbp+18h]
    je      L5
    jmp     L4

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_up::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-48h],rdx
    cmp     rax,rdx
    je      L3
    mov     rsi,[rbp+18h]
    mov     [rbp-18h],rsi
    cmp     rsi,[rbp+20h]
    je      L3
    mov     rdi,[rbp+18h]
    mov     [rbp-50h],rdi
    mov     r8,[rbp+10h]
    mov     r8,[r8]
    mov     [rbp-30h],r8
    mov     [rbp-58h],r8
    mov     [rbp-48h],rdi
    mov     [rbp-40h],r8
    mov     r9,[rbp+28h]
    mov     [rbp-0A0h],r9
    mov     [rbp-98h],rdi
    mov     [rbp-90h],r8
    call    fn0
    nop     [rcx-19h]
    movzx   eax,byte ptr [rbp-19h]
    xor     al,1
    mov     [rbp-33h],al
    test    byte ptr [rbp-33h],0FFh
    je      L1
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi]
    mov     [rbp-40h],rsi
    mov     [rbp-28h],rsi
    jmp     L2
L1:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L5
    jmp     L4
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp-28h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],8
    mov     qword ptr [rbp-88h],4
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-30h]
L5:
    mov     qword ptr [rbp-60h],1
    imul    rdx,[rbp-60h],8
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFCDh
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-48h]
    imul    rcx,[rbp-50h],8
    add     rax,rcx
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-40h]
    mov     [rdx],rcx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+18h]
    imul    rcx,[rbp-48h],8
    add     rax,rcx
    mov     [rbp-40h],rax
    mov     [rbp+18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-48h],rdx
    mov     qword ptr [rbp-60h],1
    imul    rcx,[rbp-60h],8
    add     rdx,rcx
    mov     [rbp-40h],rdx
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-40h]
    mov     [rdi+10h],rcx
    jmp     L0

fn core::slice::sort::stable::merge::merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    cmp     qword ptr [rbp+30h],0
    je      L0
    mov     rsi,[rbp+30h]
    cmp     rsi,rax
    jae     L0
    mov     rdi,[rbp+28h]
    mov     [rbp-58h],rdi
    sub     rax,rsi
    mov     [rbp-8],rax
    mov     [rbp-0D0h],rsi
    mov     [rbp-0C8h],rax
    call    fn0
    nop     [rcx-60h]
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rbp+20h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-20h],rdx
    mov     [rbp-58h],rax
    mov     rsi,[rbp-28h]
    mov     [rbp-50h],rsi
    mov     rdi,[rbp+10h]
    mov     [rbp-38h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-30h],r8
    mov     [rbp-10h],rdi
    imul    rcx,[rbp+30h],8
    add     rdi,rcx
    mov     [rbp-58h],rdi
    mov     r9,[rbp-10h]
    imul    rcx,[rbp-48h],8
    add     r9,rcx
    mov     [rbp-60h],r9
    mov     r10,[rbp+30h]
    cmp     r10,[rbp-8]
    setbe   [rbp-61h]
    test    byte ptr [rbp-61h],0FFh
    je      L2
    jmp     L3
L2:
    mov     rax,[rbp-58h]
    mov     [rbp-10h],rax
L3:
    test    byte ptr [rbp-61h],0FFh
    je      L4
    jmp     L5
L4:
    mov     rax,[rbp-8]
    mov     [rbp+30h],rax
L5:
    mov     rax,[rbp-10h]
    mov     [rbp-18h],rax
    mov     [rbp-70h],rax
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    mov     byte ptr [rbp-99h],1
    test    byte ptr [rbp-99h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    xchg    ax,ax
L6:
    lea     rax,[rbp-80h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-60h]
    mov     [rbp-98h],rsi
    mov     [rbp-0D0h],rax
    mov     [rbp-0C8h],rdx
    mov     [rbp-0C0h],rsi
    mov     rdi,[rbp+38h]
    mov     [rbp-0B8h],rdi
    call    fn1
    nop     [rcx-18h]
    jmp     L8
    nop
L7:
    lea     rax,[rbp-80h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-98h],rsi
    mov     [rbp-0D0h],rax
    mov     [rbp-0C8h],rdx
    mov     [rbp-0C0h],rsi
    mov     rdi,[rbp-60h]
    mov     [rbp-0B8h],rdi
    mov     r8,[rbp+38h]
    mov     [rbp-0B0h],r8
    call    fn2
    nop     [rcx-18h]
L8:
    lea     rax,[rbp-80h]
    mov     [rbp-0A0h],rax
    mov     [rbp-0D0h],rax
    call    fn3
    nop     [rcx-0A0h]
L9:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    lea     rax,[rbp-80h]
    mov     [rbp-0A0h],rax
    mov     [rbp-0D0h],rax
    call    fn4
    nop     [rcx-0A0h]
    mov     edi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L11:
    mov     rax,[rbp-58h]
    cmp     rax,[rbp-60h]
    jb      L0
    jmp     L1
L12:
    mov     rax,[rbp-18h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-88h],rdx
    mov     [rbp-0D0h],rax
    mov     [rbp-0C8h],rdx
    mov     qword ptr [rbp-0C0h],8
    mov     qword ptr [rbp-0B8h],4
    mov     r8,[rbp-78h]
    mov     [rbp-0B0h],r8
    mov     edi,0FFFFFF58h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-38h]
L13:
    imul    rax,[rbp-78h],8
    mov     [rbp-0A0h],rax
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF60h
    call    ryo_h_Memcpy
    mov     rax,[rbp-50h]
    imul    rcx,[rbp+30h],8
    add     rax,rcx
    mov     [rbp-88h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rax
    mov     rsi,[rbp-10h]
    mov     [rbp-70h],rsi
    test    byte ptr [rbp-61h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx-98h]
    jmp     L16
L15:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L16:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L10
    mov     rdi,rax
    mov     esi,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L14

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-20h],rax
    mov     byte ptr [rbp-29h],0
    test    byte ptr [rbp-29h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    jmp     L2
    nop     [rax]
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax+18h]
    mov     [rbp-10h],rax
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp-10h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-8],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-18h],rsi
    mov     byte ptr [rbp-29h],1
    test    byte ptr [rbp-29h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L3:
    mov     rax,[rbp+10h]
    mov     rcx,[rbp-18h]
    mov     [rax+18h],rcx
    test    byte ptr [rbp+18h],0FFh
    je      L1
    jmp     L0
L4:
    mov     rax,[rbp-20h]
    mov     [rbp-18h],rax
    jmp     L3
L5:
    mov     qword ptr [rbp-30h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rbp-20h]
    imul    rcx,[rbp-30h],8
    add     rdx,rcx
    mov     [rbp-18h],rdx
    jmp     L3
L6:
    mov     rax,[rbp-18h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-28h],rdx
    mov     [rbp-70h],rax
    mov     [rbp-68h],rdx
    mov     qword ptr [rbp-60h],8
    mov     qword ptr [rbp-58h],4
    mov     qword ptr [rbp-50h],1
    mov     edi,0FFFFFFB8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-10h]
L7:
    mov     qword ptr [rbp-30h],1
    imul    rdx,[rbp-30h],8
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFC8h
    call    ryo_h_Memcpy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-30h],rax
    add     rax,[rbp-18h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-40h]
    mov     [rdx+10h],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    mov     qword ptr [rbp-30h],1
    imul    rcx,[rbp-30h],8
    add     rsi,rcx
    mov     [rbp-18h],rsi
    mov     r8,[rbp+10h]
    mov     rcx,[rbp-18h]
    mov     [r8+8],rcx
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,110h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rdx
    call    fn0
    nop     [rcx-80h]
    mov     rax,[rbp-80h]
    cmp     rax,[rbp-78h]
    jb      L1
    mov     edi,0FFFFFEF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-0F0h],rax
    call    fn1
    nop     [rcx]
    jmp     L15
L1:
    mov     eax,[rbp+38h]
    mov     [rbp-70h],eax
    cmp     eax,0
    jne     L2
    mov     edi,0FFFFFEF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-0F0h],1
    mov     rdx,[rbp+40h]
    mov     [rbp-0E8h],rdx
    call    fn2
    nop     [rcx]
    jmp     L3
L2:
    mov     eax,[rbp+38h]
    sub     eax,1
    mov     [rbp+38h],eax
    mov     rdx,[rbp+10h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-88h],rsi
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-100h],rax
    call    fn3
    nop     [rcx-80h]
    jmp     L4
L3:
    jmp     L15
L4:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-8],rdx
    mov     [rbp-18h],rdx
    mov     rsi,[rbp-80h]
    cmp     rsi,rdx
    jb      L7
    mov     [rbp-110h],rsi
    mov     [rbp-108h],rdx
    mov     edi,0FFFFFF00h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-0D0h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-80h],8
    add     rax,rcx
    mov     [rbp-0D8h],rax
    mov     [rbp-98h],rax
    mov     [rbp-90h],rax
    mov     rax,[rax]
    mov     [rbp-88h],rax
    call    fn8
    nop     [rcx-69h]
    jmp     L16
L8:
    mov     rax,[rbp+30h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    mov     [rbp-58h],rsi
    mov     rdi,[rbp-80h]
    cmp     rdi,rsi
    jb      L11
    mov     [rbp-110h],rdi
    mov     [rbp-108h],rsi
    mov     edi,0FFFFFF00h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    lea     rdi,[sym10]
    lea     rsi,[site11]
    mov     edx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx-0D0h]
    jmp     L10
L9:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym12]
L10:
    call    ryo_h_Unreachable
    ud2
L11:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-80h],8
    add     rax,rcx
    mov     [rbp-0D8h],rax
    mov     [rbp-0A8h],rax
    mov     rdx,[rbp-90h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    mov     rsi,[rbp+40h]
    mov     [rbp-110h],rsi
    mov     [rbp-108h],rdx
    mov     [rbp-100h],rax
    call    fn13
    nop     [rcx-6Ah]
    movzx   eax,byte ptr [rbp-6Ah]
    xor     al,1
    mov     [rbp-31h],al
    mov     qword ptr [rbp-68h],0
    movzx   esi,byte ptr [rbp-31h]
    mov     [rbp-6Ah],sil
    test    byte ptr [rbp-6Ah],0FFh
    jne     L13
    nop     [rax]
L12:
    mov     edi,0FFFFFF68h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-80h]
    mov     [rbp-0F0h],rax
    mov     byte ptr [rbp-0E8h],0
    mov     rsi,[rbp+40h]
    mov     [rbp-0E0h],rsi
    call    fn14
    nop     [rcx-68h]
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
    cmp     rax,0
    sete    [rbp-31h]
L13:
    test    byte ptr [rbp-31h],0FFh
    je      L14
    mov     edi,0FFFFFF60h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+40h]
    mov     [rbp-0B0h],rax
    lea     rdx,[rbp-0B0h]
    mov     [rbp-0A8h],rdx
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF60h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     rax,[rbp-80h]
    mov     [rbp-0F0h],rax
    mov     byte ptr [rbp-0E8h],1
    mov     rsi,[rbp-0A8h]
    mov     [rbp-0E0h],rsi
    call    fn15
    nop     [rcx-90h]
    mov     rax,[rbp+18h]
    mov     [rbp-98h],rax
    cmp     rax,[rbp-90h]
    jb      L21
    jmp     L24
L14:
    mov     edi,0FFFFFEF0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-68h]
    mov     [rbp-100h],rax
    mov     edi,0FFFFFF08h
    lea     rsi,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx-0B8h]
    mov     edi,10h
    mov     esi,0FFFFFF48h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     eax,[rbp+38h]
    mov     [rbp-70h],eax
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,20h
    call    ryo_h_MovW128
    mov     eax,[rbp-70h]
    mov     [rbp-0E8h],eax
    mov     rdx,[rbp-28h]
    mov     [rbp-0F0h],rdx
    mov     rsi,[rbp+40h]
    mov     [rbp-0E0h],rsi
    call    fn18
    nop     [rcx-68h]
    jmp     L0
L15:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L16:
    lea     rax,[rbp-88h]
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rax
    mov     [rbp-90h],rax
    test    byte ptr [rbp-69h],0FFh
    je      L20
    jmp     L19
    nop     [rax+rax]
L17:
    mov     byte ptr [rbp-31h],0
    mov     edi,0FFFFFF2Ch
    mov     esi,30h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFF2Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L18]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L18:
    .long   L26
    .long   L8
    .long   L25
L19:
    mov     rax,[rbp-90h]
    mov     [rbp-28h],rax
    jmp     L17
L20:
    mov     qword ptr [rbp-28h],0
    jmp     L17
L21:
    mov     rax,[rbp-90h]
    mov     [rbp-110h],rax
    mov     rdx,[rbp-98h]
    mov     [rbp-108h],rdx
    mov     rsi,[rbp-98h]
    mov     [rbp-100h],rsi
    mov     edi,0FFFFFF08h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    lea     rdi,[sym20]
    lea     rsi,[site21]
    mov     edx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L22
    call    rax
    nop     [rcx-69h]
    jmp     L23
L22:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym22]
L23:
    call    ryo_h_Unreachable
    ud2
L24:
    mov     rax,[rbp-98h]
    sub     rax,[rbp-90h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-0C0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-0B8h],rsi
    mov     [rbp-0C8h],rdx
    imul    rcx,[rbp-90h],8
    add     rdx,rcx
    mov     [rbp-0D0h],rdx
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rax
    mov     [rbp+10h],rdx
    mov     [rbp+18h],rax
    mov     qword ptr [rbp+30h],0
    jmp     L0
L25:
    call    ryo_h_Unreachable
    ud2
L26:
    mov     qword ptr [rbp-68h],0
    jmp     L12

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rsi
    call    fn0
    nop     [rcx-11h]
    movzx   eax,byte ptr [rbp-11h]
    xor     al,1
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,150h
    mov     rax,[rbp+18h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-0A0h],rdx
    cmp     rdx,rax
    jae     L0
    mov     byte ptr [rbp-91h],1
    jmp     L10
L0:
    mov     rax,[rbp-90h]
    cmp     rax,[rbp+30h]
    setbe   [rbp-91h]
    test    byte ptr [rbp-91h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop
L1:
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L3
    mov     rsi,[rbp+30h]
    mov     [rbp-0E0h],rsi
    mov     [rbp-150h],rsi
    mov     qword ptr [rbp-148h],3
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0E0h],rax
    cmp     rax,[rbp-0D0h]
    jae     L3
    lea     rdx,[rbp-0C8h]
    mov     [rbp-0E8h],rdx
    mov     rsi,[rbp-0C0h]
    mov     [rbp-38h],rsi
    mov     [rbp-100h],rsi
    mov     rdi,[rbp-0A8h]
    mov     [rbp-108h],rdi
    mov     [rbp-0F8h],rsi
    mov     [rbp-0F0h],rdi
    mov     r8,[rbp+40h]
    mov     [rbp-150h],r8
    mov     [rbp-148h],rsi
    mov     [rbp-140h],rdi
    call    fn1
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn2
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-40h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn3
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn4
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-48h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn5
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn6
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-50h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn7
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn8
    nop     [rcx-0E0h]
    jmp     L2
L3:
    mov     rax,[rbp+30h]
    mov     [rbp-0D8h],rax
    mov     rdx,[rbp-98h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-0D0h],rdx
L4:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0E0h],rax
    cmp     rax,[rbp-0D0h]
    jae     L5
    lea     rdx,[rbp-0C8h]
    mov     [rbp-0E8h],rdx
    mov     rsi,[rbp-0C0h]
    mov     [rbp-58h],rsi
    mov     [rbp-100h],rsi
    mov     rdi,[rbp-0A8h]
    mov     [rbp-108h],rdi
    mov     [rbp-0F8h],rsi
    mov     [rbp-0F0h],rdi
    mov     r8,[rbp+40h]
    mov     [rbp-150h],r8
    mov     [rbp-148h],rsi
    mov     [rbp-140h],rdi
    call    fn9
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn10
    nop     [rcx-0E0h]
    jmp     L4
L5:
    mov     rax,[rbp+30h]
    cmp     rax,[rbp-90h]
    jne     L6
    call    fn11
    nop     [rcx-0CAh]
    jmp     L13
L6:
    lea     rax,[rbp-0C8h]
    mov     [rbp-0D8h],rax
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp+38h]
    mov     [rbp-148h],dl
    call    fn12
    nop     [rcx-10h]
    mov     rax,[rbp-90h]
    mov     [rbp+30h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-70h],rdx
    mov     [rbp-0D0h],rax
    mov     rsi,[rbp-68h]
    mov     [rbp-0D8h],rsi
    mov     rdi,[rbp-0B8h]
    mov     [rbp-0E0h],rdi
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L9:
    mov     rax,[rbp-20h]
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0F8h],rdx
    cmp     rax,rdx
    setb    [rbp-0E1h]
    test    byte ptr [rbp-0E1h],0FFh
    je      L19
    jmp     L18
L10:
    call    ryo_h_Abort
    ud2
L11:
    mov     rax,[rbp+10h]
    mov     [rbp-0A8h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-68h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-60h],rdi
    mov     [rbp-0A8h],rsi
    mov     r8,[rbp-68h]
    mov     [rbp-0A0h],r8
    imul    rcx,[rbp+30h],8
    add     rax,rcx
    mov     [rbp-0A8h],rax
    imul    rcx,[rbp-90h],8
    add     r8,rcx
    mov     [rbp-0D0h],r8
    mov     r9,[rbp-0A0h]
    mov     [rbp-0C8h],r9
    mov     r10,[rbp-98h]
    mov     [rbp-0C0h],r10
    mov     qword ptr [rbp-0B8h],0
    mov     [rbp-0B0h],r8
    mov     qword ptr [rbp-10h],0
    jmp     L1
L12:
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0D8h],8
    add     rax,rcx
    mov     [rbp-0D0h],rax
    jmp     L2
L13:
    movzx   eax,byte ptr [rbp-0CAh]
    xor     al,1
    mov     [rbp-0C9h],al
    test    byte ptr [rbp-0C9h],0FFh
    je      L8
    jmp     L7
L14:
    mov     rax,[rbp-0A8h]
    mov     [rbp-0D8h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-0E0h],rdx
    mov     [rbp-150h],rax
    mov     [rbp-148h],rdx
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     qword ptr [rbp-130h],1
    mov     edi,0FFFFFED8h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-68h]
L15:
    mov     qword ptr [rbp-110h],1
    imul    rdx,[rbp-110h],8
    mov     [rbp-118h],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L8
L16:
    mov     rax,[rbp-68h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-78h]
    mov     [rbp-0F0h],rdx
    mov     [rbp-150h],rax
    mov     [rbp-148h],rdx
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     r8,[rbp-0E0h]
    mov     [rbp-130h],r8
    mov     edi,0FFFFFED8h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx-78h]
L17:
    imul    rax,[rbp-0E0h],8
    mov     [rbp-110h],rax
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFEF0h
    call    ryo_h_Memcpy
    mov     rax,[rbp-0B8h]
    mov     [rbp-0E0h],rax
    mov     rdx,[rbp-90h]
    sub     rdx,rax
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-20h],0
    mov     [rbp-18h],rdx
    jmp     L9
L18:
    mov     rax,[rbp-20h]
    mov     [rbp-0F0h],rax
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L21
    jmp     L20
L19:
    mov     rax,[rbp-0B8h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L20:
    mov     rax,[rbp-0F0h]
    mov     [rbp-150h],rax
    mov     qword ptr [rbp-148h],1
    mov     edi,0FFFFFEC0h
    lea     rsi,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx-88h]
L21:
    mov     rax,[rbp-0F0h]
    add     rax,1
    mov     [rbp-0F8h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp-0F0h]
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-0E0h],1
    mov     [rbp-0E8h],rdx
    mov     rdi,[rbp-90h]
    sub     rdi,1
    mov     [rbp-100h],rdi
    sub     rdi,rdx
    mov     [rbp-0F8h],rdi
    mov     r8,[rbp-0A0h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rbp-30h],r8
    mov     [rbp-0F0h],r8
    mov     r9,[rbp-0B8h]
    mov     [rbp-108h],r9
    add     r9,rdx
    mov     [rbp-100h],r9
    mov     r10,[rbp-0D0h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rbp-0F8h],r10
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L22
    mov     rdi,[rbp-30h]
    mov     [rbp-100h],rdi
    mov     [rbp-108h],r10
    mov     [rbp-150h],rdi
    mov     [rbp-148h],r10
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     qword ptr [rbp-130h],1
    mov     edi,0FFFFFED8h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx-88h]
L22:
    mov     qword ptr [rbp-110h],1
    imul    rdx,[rbp-110h],8
    mov     [rbp-118h],rdx
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L9

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,150h
    mov     rax,[rbp+18h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-0A0h],rdx
    cmp     rdx,rax
    jae     L0
    mov     byte ptr [rbp-91h],1
    jmp     L10
L0:
    mov     rax,[rbp-90h]
    cmp     rax,[rbp+30h]
    setbe   [rbp-91h]
    test    byte ptr [rbp-91h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop
L1:
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L3
    mov     rsi,[rbp+30h]
    mov     [rbp-0E0h],rsi
    mov     [rbp-150h],rsi
    mov     qword ptr [rbp-148h],3
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0E0h],rax
    cmp     rax,[rbp-0D0h]
    jae     L3
    lea     rdx,[rbp-0C8h]
    mov     [rbp-0E8h],rdx
    mov     rsi,[rbp-0C0h]
    mov     [rbp-38h],rsi
    mov     [rbp-100h],rsi
    mov     rdi,[rbp-0A8h]
    mov     [rbp-108h],rdi
    mov     [rbp-0F8h],rsi
    mov     [rbp-0F0h],rdi
    mov     r8,[rbp+40h]
    mov     [rbp-150h],r8
    mov     [rbp-148h],rsi
    mov     [rbp-140h],rdi
    call    fn1
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn2
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-40h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn3
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn4
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-48h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn5
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn6
    nop     [rcx-0E0h]
    lea     rax,[rbp-0C8h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-0C0h]
    mov     [rbp-50h],rdx
    mov     [rbp-100h],rdx
    mov     rsi,[rbp-0A8h]
    mov     [rbp-108h],rsi
    mov     [rbp-0F8h],rdx
    mov     [rbp-0F0h],rsi
    mov     rdi,[rbp+40h]
    mov     [rbp-150h],rdi
    mov     [rbp-148h],rdx
    mov     [rbp-140h],rsi
    call    fn7
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn8
    nop     [rcx-0E0h]
    jmp     L2
L3:
    mov     rax,[rbp+30h]
    mov     [rbp-0D8h],rax
    mov     rdx,[rbp-98h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rbp-0D0h],rdx
L4:
    mov     rax,[rbp-0C0h]
    mov     [rbp-0E0h],rax
    cmp     rax,[rbp-0D0h]
    jae     L5
    lea     rdx,[rbp-0C8h]
    mov     [rbp-0E8h],rdx
    mov     rsi,[rbp-0C0h]
    mov     [rbp-58h],rsi
    mov     [rbp-100h],rsi
    mov     rdi,[rbp-0A8h]
    mov     [rbp-108h],rdi
    mov     [rbp-0F8h],rsi
    mov     [rbp-0F0h],rdi
    mov     r8,[rbp+40h]
    mov     [rbp-150h],r8
    mov     [rbp-148h],rsi
    mov     [rbp-140h],rdi
    call    fn9
    nop     [rcx-0D2h]
    mov     rax,[rbp-0E8h]
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp-0D2h]
    mov     [rbp-148h],dl
    call    fn10
    nop     [rcx-0E0h]
    jmp     L4
L5:
    mov     rax,[rbp+30h]
    cmp     rax,[rbp-90h]
    jne     L6
    call    fn11
    nop     [rcx-0CAh]
    jmp     L13
L6:
    lea     rax,[rbp-0C8h]
    mov     [rbp-0D8h],rax
    mov     [rbp-150h],rax
    movzx   edx,byte ptr [rbp+38h]
    mov     [rbp-148h],dl
    call    fn12
    nop     [rcx-10h]
    mov     rax,[rbp-90h]
    mov     [rbp+30h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L15
    jmp     L14
    nop     [rax]
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-70h],rdx
    mov     [rbp-0D0h],rax
    mov     rsi,[rbp-68h]
    mov     [rbp-0D8h],rsi
    mov     rdi,[rbp-0B8h]
    mov     [rbp-0E0h],rdi
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L9:
    mov     rax,[rbp-20h]
    mov     [rbp-0F0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0F8h],rdx
    cmp     rax,rdx
    setb    [rbp-0E1h]
    test    byte ptr [rbp-0E1h],0FFh
    je      L19
    jmp     L18
L10:
    call    ryo_h_Abort
    ud2
L11:
    mov     rax,[rbp+10h]
    mov     [rbp-0A8h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-68h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-60h],rdi
    mov     [rbp-0A8h],rsi
    mov     r8,[rbp-68h]
    mov     [rbp-0A0h],r8
    imul    rcx,[rbp+30h],8
    add     rax,rcx
    mov     [rbp-0A8h],rax
    imul    rcx,[rbp-90h],8
    add     r8,rcx
    mov     [rbp-0D0h],r8
    mov     r9,[rbp-0A0h]
    mov     [rbp-0C8h],r9
    mov     r10,[rbp-98h]
    mov     [rbp-0C0h],r10
    mov     qword ptr [rbp-0B8h],0
    mov     [rbp-0B0h],r8
    mov     qword ptr [rbp-10h],0
    jmp     L1
L12:
    mov     rax,[rbp-98h]
    imul    rcx,[rbp-0D8h],8
    add     rax,rcx
    mov     [rbp-0D0h],rax
    jmp     L2
L13:
    movzx   eax,byte ptr [rbp-0CAh]
    xor     al,1
    mov     [rbp-0C9h],al
    test    byte ptr [rbp-0C9h],0FFh
    je      L8
    jmp     L7
L14:
    mov     rax,[rbp-0A8h]
    mov     [rbp-0D8h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-0E0h],rdx
    mov     [rbp-150h],rax
    mov     [rbp-148h],rdx
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     qword ptr [rbp-130h],1
    mov     edi,0FFFFFED8h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-68h]
L15:
    mov     qword ptr [rbp-110h],1
    imul    rdx,[rbp-110h],8
    mov     [rbp-118h],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L8
L16:
    mov     rax,[rbp-68h]
    mov     [rbp-0E8h],rax
    mov     rdx,[rbp-78h]
    mov     [rbp-0F0h],rdx
    mov     [rbp-150h],rax
    mov     [rbp-148h],rdx
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     r8,[rbp-0E0h]
    mov     [rbp-130h],r8
    mov     edi,0FFFFFED8h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx-78h]
L17:
    imul    rax,[rbp-0E0h],8
    mov     [rbp-110h],rax
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFEF0h
    call    ryo_h_Memcpy
    mov     rax,[rbp-0B8h]
    mov     [rbp-0E0h],rax
    mov     rdx,[rbp-90h]
    sub     rdx,rax
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-20h],0
    mov     [rbp-18h],rdx
    jmp     L9
L18:
    mov     rax,[rbp-20h]
    mov     [rbp-0F0h],rax
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L21
    jmp     L20
L19:
    mov     rax,[rbp-0B8h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
L20:
    mov     rax,[rbp-0F0h]
    mov     [rbp-150h],rax
    mov     qword ptr [rbp-148h],1
    mov     edi,0FFFFFEC0h
    lea     rsi,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx-88h]
L21:
    mov     rax,[rbp-0F0h]
    add     rax,1
    mov     [rbp-0F8h],rax
    mov     [rbp-20h],rax
    mov     rdx,[rbp-0F0h]
    mov     [rbp-0D8h],rdx
    mov     qword ptr [rbp-0E0h],1
    mov     [rbp-0E8h],rdx
    mov     rdi,[rbp-90h]
    sub     rdi,1
    mov     [rbp-100h],rdi
    sub     rdi,rdx
    mov     [rbp-0F8h],rdi
    mov     r8,[rbp-0A0h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rbp-30h],r8
    mov     [rbp-0F0h],r8
    mov     r9,[rbp-0B8h]
    mov     [rbp-108h],r9
    add     r9,rdx
    mov     [rbp-100h],r9
    mov     r10,[rbp-0D0h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rbp-0F8h],r10
    mov     byte ptr [rbp-109h],1
    test    byte ptr [rbp-109h],0FFh
    je      L22
    mov     rdi,[rbp-30h]
    mov     [rbp-100h],rdi
    mov     [rbp-108h],r10
    mov     [rbp-150h],rdi
    mov     [rbp-148h],r10
    mov     qword ptr [rbp-140h],8
    mov     qword ptr [rbp-138h],4
    mov     qword ptr [rbp-130h],1
    mov     edi,0FFFFFED8h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx-88h]
L22:
    mov     qword ptr [rbp-110h],1
    imul    rdx,[rbp-110h],8
    mov     [rbp-118h],rdx
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L9

fn core::slice::sort::unstable::heapsort::heapsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    mov     rax,[rbp+18h]
    mov     [rbp-48h],rax
    mov     qword ptr [rbp-0A8h],2
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF58h
    call    ryo_h_DivUW64
    mov     rax,[rbp-48h]
    add     rax,[rbp-68h]
    mov     [rbp-60h],rax
    mov     qword ptr [rbp-58h],0
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    nop     [rax]
L0:
    mov     rax,[rbp-10h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-70h],rdx
    cmp     rax,rdx
    setb    [rbp-59h]
    test    byte ptr [rbp-59h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
    nop
L1:
    mov     rax,[rbp-60h]
    sub     rax,[rbp-48h]
    mov     [rbp-20h],rax
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     qword ptr [rbp-0A8h],0
    mov     rdx,[rbp-0A8h]
    cmp     rdx,[rbp-48h]
    setb    [rbp-62h]
    test    byte ptr [rbp-62h],0FFh
    jne     L12
    mov     qword ptr [rbp-0D0h],0
    mov     r8,[rbp-48h]
    mov     [rbp-0C8h],r8
    mov     edi,0FFFFFF40h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-0A0h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L4:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L5:
    mov     rax,[rbp-60h]
    mov     [rbp-0D0h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-0C8h],rdx
    call    fn4
    nop     [rcx-28h]
    jmp     L16
    nop     [rax+rax]
L6:
    jmp     L0
L7:
    mov     rax,[rbp-8]
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-0A1h],1
    test    byte ptr [rbp-0A1h],0FFh
    je      L10
    jmp     L9
L8:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L9:
    mov     rax,[rbp-70h]
    mov     [rbp-0D0h],rax
    mov     qword ptr [rbp-0C8h],1
    mov     edi,0FFFFFF40h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-40h]
L10:
    mov     rax,[rbp-70h]
    sub     rax,1
    mov     [rbp-68h],rax
    mov     [rbp-8],rax
    mov     [rbp-68h],rax
    mov     [rbp-50h],rax
    mov     qword ptr [rbp-58h],1
    mov     [rbp-60h],rax
    cmp     rax,[rbp-48h]
    jae     L1
    jmp     L2
L11:
    mov     qword ptr [rbp-20h],0
    jmp     L5
L12:
    mov     rax,[rbp-60h]
    cmp     rax,[rbp-48h]
    jb      L15
    mov     [rbp-0D0h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-0C8h],rdx
    mov     edi,0FFFFFF40h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-0A0h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym10]
L14:
    call    ryo_h_Unreachable
    ud2
L15:
    mov     edi,0FFFFFF30h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-0C0h],0
    mov     rdx,[rbp-60h]
    mov     [rbp-0B8h],rdx
    mov     edi,0FFFFFF50h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-40h]
    jmp     L11
L16:
    cmp     qword ptr [rbp-28h],0
    jb      L21
    jmp     L22
L17:
    mov     rax,[rbp+10h]
    mov     [rbp-98h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-90h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-88h],rax
    mov     rsi,[rbp-28h]
    mov     [rbp-80h],rsi
    mov     [rbp-70h],rax
    mov     [rbp-68h],rsi
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     rax,[rbp-20h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-0B8h],rdx
    call    fn13
    nop     [rcx-20h]
    jmp     L6
    nop     [rax+rax]
L18:
    mov     qword ptr [rbp-0D0h],0
    mov     rdx,[rbp-28h]
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-0C0h],rsi
    mov     edi,0FFFFFF48h
    lea     rsi,[k14]
    call    ryo_h_AddrAbs
    lea     rdi,[sym15]
    lea     rsi,[site16]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L19
    call    rax
    nop     [rcx-40h]
    jmp     L20
L19:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym17]
L20:
    call    ryo_h_Unreachable
    ud2
L21:
    jmp     L18
L22:
    mov     rax,[rbp-48h]
    cmp     rax,[rbp-28h]
    jae     L17
    jmp     L18

fn core::slice::sort::unstable::heapsort::sift_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-8],rdx
    cmp     rax,rdx
    setbe   [rbp-11h]
    mov     rsi,[rbp+10h]
    mov     [rbp-28h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-20h],rdi
    mov     [rbp-18h],rsi
    nop     [rax+rax]
    nop
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-70h],2
    mov     rsi,[rbp-70h]
    imul    rsi,rax
    mov     [rbp-20h],rsi
    add     rsi,1
    mov     [rbp-10h],rsi
    mov     [rbp-28h],rsi
    cmp     rsi,[rbp-8]
    jb      L1
    jmp     L5
L1:
    mov     rax,[rbp-10h]
    mov     [rbp-30h],rax
    add     rax,1
    mov     [rbp-28h],rax
    cmp     rax,[rbp-8]
    jae     L2
    mov     rdx,[rbp-10h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp-18h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    mov     rdi,[rbp-10h]
    mov     [rbp-68h],rdi
    add     rdi,1
    mov     [rbp-60h],rdi
    mov     r8,[rbp-18h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rbp-58h],r8
    mov     [rbp-50h],r8
    mov     [rbp-38h],rsi
    mov     [rbp-30h],r8
    mov     r9,[rbp+28h]
    mov     [rbp-0A0h],r9
    mov     [rbp-98h],rsi
    mov     [rbp-90h],r8
    call    fn0
    nop     [rcx-1Ah]
    jmp     L3
L2:
    jmp     L4
L3:
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE6h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp-10h]
    add     rax,[rbp-28h]
    mov     [rbp-10h],rax
L4:
    mov     rax,[rbp+20h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-18h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-10h]
    mov     [rbp-58h],rsi
    mov     rdi,[rbp-18h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-50h],rdi
    mov     [rbp-48h],rdi
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rdi
    mov     r8,[rbp+28h]
    mov     [rbp-0A0h],r8
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdi
    call    fn1
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L5
    mov     rdx,[rbp-18h]
    imul    rcx,[rbp+20h],4
    add     rdx,rcx
    mov     [rbp-20h],rdx
    mov     rsi,[rbp-10h]
    mov     [rbp-30h],rsi
    mov     rdi,[rbp-18h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-28h],rdi
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L7
    jmp     L6
L5:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L6:
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-38h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],4
    mov     qword ptr [rbp-88h],4
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-10h]
L7:
    mov     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-30h],1
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    imul    rax,[rbp-48h],4
    mov     [rbp-40h],rax
    jmp     L10
L8:
    mov     rax,[rbp-48h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-68h],rsi
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rax
    call    fn4
    nop     [rcx-10h]
    jmp     L9
L9:
    mov     rax,[rbp-10h]
    mov     [rbp+20h],rax
    jmp     L0
L10:
    mov     rax,[rbp-40h]
    mov     [rbp-48h],rax
    mov     edi,0FFFFFF94h
    mov     esi,0FFFFFFB8h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFF94h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFA8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L11]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L11:
    .long   L9
    .long   L8
    .long   L12
L12:
    call    ryo_h_Unreachable
    ud2

fn core::slice::sort::unstable::ipnsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-30h],rsi
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-70h],rax
    call    fn0
    nop     [rcx-28h]
    mov     rax,[rbp-28h]
    mov     [rbp-18h],rax
    movzx   edx,byte ptr [rbp-20h]
    mov     [rbp-5],dl
    cmp     rax,[rbp-10h]
    setbe   [rbp-6]
    cmp     rax,[rbp-10h]
    jne     L1
    test    byte ptr [rbp-5],0FFh
    je      L0
    mov     edi,0FFFFFF80h
    mov     esi,10h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx]
L0:
    jmp     L3
L1:
    mov     rax,[rbp-10h]
    or      rax,1
    mov     [rbp-28h],rax
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFB4h
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFB4h
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L2:
    .long   L5
    .long   L8
    .long   L4
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     edi,0FFFFFF80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L7:
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rbp-30h]
    mov     [rbp-40h],rax
    mov     [rbp-48h],rax
    mov     edi,0FFFFFFB4h
    mov     esi,0FFFFFFB8h
    call    ryo_h_CtlzW64
    mov     eax,[rbp-4Ch]
    mov     [rbp-20h],eax
    mov     dword ptr [rbp-4Ch],3Fh
    mov     esi,[rbp-4Ch]
    sub     esi,eax
    mov     [rbp-4],esi
    mov     dword ptr [rbp-4Ch],2
    mov     r8d,[rbp-4Ch]
    imul    r8d,esi
    mov     [rbp-1Ch],r8d
    mov     edi,0FFFFFF80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-70h],0
    mov     edx,[rbp-1Ch]
    mov     [rbp-68h],edx
    mov     rsi,[rbp+20h]
    mov     [rbp-60h],rsi
    call    fn6
    nop     [rcx]
    jmp     L3

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    cmp     rax,0
    jne     L0
    mov     qword ptr [rbp-8],0
    jmp     L8
L0:
    mov     rax,[rbp+20h]
    cmp     rax,[rbp-20h]
    jb      L1
    call    ryo_h_Abort
    ud2
L1:
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-60h]
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp-28h]
    mov     [rbp-10h],rax
    mov     qword ptr [rbp-68h],0
    mov     rsi,[rbp-68h]
    cmp     rsi,rax
    setb    [rbp-11h]
    test    byte ptr [rbp-11h],0FFh
    jne     L4
    mov     qword ptr [rbp-90h],0
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-60h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-48h],rax
    mov     [rbp-50h],rax
    mov     edi,0FFFFFF98h
    lea     rsi,[sym8]
    call    ryo_h_AddrSym
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[site9]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-8]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L6:
    mov     rax,[rbp-8]
    cmp     rax,[rbp-20h]
    jb      L7
    call    ryo_h_Abort
    ud2
L7:
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],0
    mov     rdx,[rbp-8]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-11h]
L8:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    cmp     rax,0
    jne     L0
    mov     qword ptr [rbp-8],0
    jmp     L8
L0:
    mov     rax,[rbp+20h]
    cmp     rax,[rbp-20h]
    jb      L1
    call    ryo_h_Abort
    ud2
L1:
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-8]
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-60h]
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp-28h]
    mov     [rbp-10h],rax
    mov     qword ptr [rbp-68h],0
    mov     rsi,[rbp-68h]
    cmp     rsi,rax
    setb    [rbp-11h]
    test    byte ptr [rbp-11h],0FFh
    jne     L4
    mov     qword ptr [rbp-90h],0
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-60h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-48h],rax
    mov     [rbp-50h],rax
    mov     edi,0FFFFFF98h
    lea     rsi,[sym8]
    call    ryo_h_AddrSym
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[site9]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-8]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L6:
    mov     rax,[rbp-8]
    cmp     rax,[rbp-20h]
    jb      L7
    call    ryo_h_Abort
    ud2
L7:
    mov     edi,0FFFFFF70h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-80h],0
    mov     rdx,[rbp-8]
    mov     [rbp-78h],rdx
    mov     edi,0FFFFFF90h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-11h]
L8:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-18h],rsi
    mov     [rbp-38h],rdx
    cmp     rax,0
    jne     L0
    mov     qword ptr [rbp-8],0
    jmp     L9
L0:
    lea     rax,[rbp-38h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rax
    mov     rdi,[rbp-20h]
    mov     [rbp-60h],rdi
    mov     edi,[rdi]
    mov     [rbp-58h],edi
    mov     [rbp-5Ch],edi
    mov     [rbp-54h],edi
    mov     qword ptr [rbp-0A8h],1
    mov     r9,[rbp-38h]
    imul    rcx,[rbp-0A8h],4
    add     r9,rcx
    mov     [rbp-80h],r9
    lea     r10,[rbp-54h]
    mov     [rbp-98h],r10
    mov     r11,[rbp-38h]
    mov     [rbp-90h],r11
    mov     [rbp-88h],r10
    mov     [rbp-68h],r9
    mov     qword ptr [rbp-60h],0
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-0A8h],2
    mov     rdx,[rbp-0A8h]
    sub     rdx,1
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-30h]
    sub     rsi,rdx
    mov     [rbp-88h],rsi
    mov     rdi,[rbp-38h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-80h],rdi
    nop     [rax]
L1:
    mov     rax,[rbp-68h]
    mov     [rbp-88h],rax
    cmp     rax,[rbp-80h]
    jae     L4
    mov     qword ptr [rbp-0A8h],2
    cmp     qword ptr [rbp-0A8h],2
    sete    [rbp-56h]
    test    byte ptr [rbp-56h],0FFh
    je      L2
    lea     r8,[rbp-50h]
    mov     [rbp-88h],r8
    lea     r9,[rbp-78h]
    mov     [rbp-98h],r9
    mov     [rbp-90h],r9
    mov     [rbp-0C0h],r8
    mov     [rbp-0B8h],r9
    call    fn0
    nop     [rcx-10h]
    lea     rax,[rbp-50h]
    mov     [rbp-88h],rax
    lea     rdx,[rbp-78h]
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    call    fn1
    nop     [rcx-10h]
    jmp     L3
L2:
    lea     rax,[rbp-50h]
    mov     [rbp-88h],rax
    lea     rdx,[rbp-78h]
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    call    fn2
    nop     [rcx-10h]
L3:
    jmp     L1
L4:
    mov     rax,[rbp-38h]
    imul    rcx,[rbp-30h],4
    add     rax,rcx
    mov     [rbp-88h],rax
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
    cmp     rax,[rbp-88h]
    sete    [rbp-55h]
    test    byte ptr [rbp-55h],0FFh
    je      L6
    mov     rsi,[rbp-70h]
    mov     [rbp-90h],rsi
    jmp     L7
L6:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
L7:
    mov     rax,[rbp-90h]
    mov     [rbp-68h],rax
    lea     rdx,[rbp-50h]
    mov     [rbp-90h],rdx
    lea     rsi,[rbp-78h]
    mov     [rbp-0A0h],rsi
    mov     [rbp-98h],rsi
    mov     [rbp-0C0h],rdx
    mov     [rbp-0B8h],rsi
    call    fn3
    nop     [rcx-10h]
    test    byte ptr [rbp-55h],0FFh
    je      L8
    mov     rdx,[rbp-78h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-70h]
    mov     [rbp-98h],rsi
    mov     rdi,[rbp-60h]
    mov     [rbp-8],rdi
    jmp     L9
L8:
    jmp     L5
L9:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L11:
    lea     rax,[rbp-78h]
    mov     [rbp-0A8h],rax
    mov     [rbp-0C0h],rax
    call    fn4
    nop     [rcx-0A8h]
    jmp     L10
L12:
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-0A0h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rsi
    call    fn0
    nop     [rcx-29h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-28h],rax
    mov     rax,[rax]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx+18h]
    mov     [rbp-48h],rdx
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp-40h],rax
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi]
    mov     [rbp-48h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rbp+18h]
    mov     rax,[rax+10h]
    mov     [rbp-8],rax
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rbp-38h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L2
    mov     byte ptr [rbp-2Ah],1
    jmp     L3
L2:
    mov     byte ptr [rbp-2Ah],0
L3:
    mov     rax,[rbp-50h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],4
    movzx   edi,byte ptr [rbp-2Ah]
    mov     [rbp-88h],dil
    mov     edi,0FFFFFF80h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L4:
    mov     qword ptr [rbp-60h],1
    imul    rdx,[rbp-60h],4
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rbp-8]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],4
    mov     qword ptr [rbp-88h],4
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-28h]
L6:
    mov     qword ptr [rbp-60h],1
    imul    rdx,[rbp-60h],4
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rbp+18h]
    mov     rax,[rax+10h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+18h]
    mov     rcx,[rbp-40h]
    mov     [rdx],rcx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+18h]
    mov     rax,[rax+18h]
    mov     [rbp-60h],rax
    add     rax,[rbp-40h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+18h]
    mov     rcx,[rbp-70h]
    mov     [rdx+18h],rcx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi+10h]
    mov     [rbp-48h],rsi
    mov     qword ptr [rbp-60h],1
    imul    rcx,[rbp-60h],4
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     r8,[rbp+18h]
    mov     rcx,[rbp-40h]
    mov     [r8+10h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-18h],rsi
    mov     [rbp-38h],rdx
    cmp     rax,0
    jne     L0
    mov     qword ptr [rbp-8],0
    jmp     L9
L0:
    lea     rax,[rbp-38h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rax
    mov     rdi,[rbp-20h]
    mov     [rbp-60h],rdi
    mov     edi,[rdi]
    mov     [rbp-58h],edi
    mov     [rbp-5Ch],edi
    mov     [rbp-54h],edi
    mov     qword ptr [rbp-0A8h],1
    mov     r9,[rbp-38h]
    imul    rcx,[rbp-0A8h],4
    add     r9,rcx
    mov     [rbp-80h],r9
    lea     r10,[rbp-54h]
    mov     [rbp-98h],r10
    mov     r11,[rbp-38h]
    mov     [rbp-90h],r11
    mov     [rbp-88h],r10
    mov     [rbp-68h],r9
    mov     qword ptr [rbp-60h],0
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-0A8h],2
    mov     rdx,[rbp-0A8h]
    sub     rdx,1
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-30h]
    sub     rsi,rdx
    mov     [rbp-88h],rsi
    mov     rdi,[rbp-38h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rbp-80h],rdi
    nop     [rax]
L1:
    mov     rax,[rbp-68h]
    mov     [rbp-88h],rax
    cmp     rax,[rbp-80h]
    jae     L4
    mov     qword ptr [rbp-0A8h],2
    cmp     qword ptr [rbp-0A8h],2
    sete    [rbp-56h]
    test    byte ptr [rbp-56h],0FFh
    je      L2
    lea     r8,[rbp-50h]
    mov     [rbp-88h],r8
    lea     r9,[rbp-78h]
    mov     [rbp-98h],r9
    mov     [rbp-90h],r9
    mov     [rbp-0C0h],r8
    mov     [rbp-0B8h],r9
    call    fn0
    nop     [rcx-10h]
    lea     rax,[rbp-50h]
    mov     [rbp-88h],rax
    lea     rdx,[rbp-78h]
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    call    fn1
    nop     [rcx-10h]
    jmp     L3
L2:
    lea     rax,[rbp-50h]
    mov     [rbp-88h],rax
    lea     rdx,[rbp-78h]
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rdx
    mov     [rbp-0C0h],rax
    mov     [rbp-0B8h],rdx
    call    fn2
    nop     [rcx-10h]
L3:
    jmp     L1
L4:
    mov     rax,[rbp-38h]
    imul    rcx,[rbp-30h],4
    add     rax,rcx
    mov     [rbp-88h],rax
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
    cmp     rax,[rbp-88h]
    sete    [rbp-55h]
    test    byte ptr [rbp-55h],0FFh
    je      L6
    mov     rsi,[rbp-70h]
    mov     [rbp-90h],rsi
    jmp     L7
L6:
    mov     rax,[rbp-68h]
    mov     [rbp-90h],rax
L7:
    mov     rax,[rbp-90h]
    mov     [rbp-68h],rax
    lea     rdx,[rbp-50h]
    mov     [rbp-90h],rdx
    lea     rsi,[rbp-78h]
    mov     [rbp-0A0h],rsi
    mov     [rbp-98h],rsi
    mov     [rbp-0C0h],rdx
    mov     [rbp-0B8h],rsi
    call    fn3
    nop     [rcx-10h]
    test    byte ptr [rbp-55h],0FFh
    je      L8
    mov     rdx,[rbp-78h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-70h]
    mov     [rbp-98h],rsi
    mov     rdi,[rbp-60h]
    mov     [rbp-8],rdi
    jmp     L9
L8:
    jmp     L5
L9:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L11:
    lea     rax,[rbp-78h]
    mov     [rbp-0A8h],rax
    mov     [rbp-0C0h],rax
    call    fn4
    nop     [rcx-0A8h]
    jmp     L10
L12:
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-0A0h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx+10h]
    mov     [rbp-18h],rdx
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     [rbp-90h],rsi
    call    fn0
    nop     [rcx-29h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-28h],rax
    mov     rax,[rax]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx+18h]
    mov     [rbp-48h],rdx
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rbp-38h],rax
    mov     [rbp-40h],rax
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi]
    mov     [rbp-48h],rsi
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rbp+18h]
    mov     rax,[rax+10h]
    mov     [rbp-8],rax
    mov     [rbp-40h],rax
    mov     byte ptr [rbp-59h],1
    test    byte ptr [rbp-59h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rbp-38h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-58h],rdx
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L2
    mov     byte ptr [rbp-2Ah],1
    jmp     L3
L2:
    mov     byte ptr [rbp-2Ah],0
L3:
    mov     rax,[rbp-50h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-58h]
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],4
    movzx   edi,byte ptr [rbp-2Ah]
    mov     [rbp-88h],dil
    mov     edi,0FFFFFF80h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-28h]
L4:
    mov     qword ptr [rbp-60h],1
    imul    rdx,[rbp-60h],4
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rbp-8]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    mov     qword ptr [rbp-90h],4
    mov     qword ptr [rbp-88h],4
    mov     qword ptr [rbp-80h],1
    mov     edi,0FFFFFF88h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-28h]
L6:
    mov     qword ptr [rbp-60h],1
    imul    rdx,[rbp-60h],4
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rbp+18h]
    mov     rax,[rax+10h]
    mov     [rbp-40h],rax
    mov     rdx,[rbp+18h]
    mov     rcx,[rbp-40h]
    mov     [rdx],rcx
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rbp+18h]
    mov     rax,[rax+18h]
    mov     [rbp-60h],rax
    add     rax,[rbp-40h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp+18h]
    mov     rcx,[rbp-70h]
    mov     [rdx+18h],rcx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi+10h]
    mov     [rbp-48h],rsi
    mov     qword ptr [rbp-60h],1
    imul    rcx,[rbp-60h],4
    add     rsi,rcx
    mov     [rbp-40h],rsi
    mov     r8,[rbp+18h]
    mov     rcx,[rbp-40h]
    mov     [r8+10h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0D0h
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rdx
    call    fn0
    nop     [rcx-50h]
    mov     rax,[rbp-50h]
    cmp     rax,[rbp-48h]
    jb      L1
    mov     edi,0FFFFFF30h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0C0h],rax
    call    fn1
    nop     [rcx]
    jmp     L15
L1:
    mov     eax,[rbp+28h]
    mov     [rbp-40h],eax
    cmp     eax,0
    jne     L2
    mov     edi,0FFFFFF30h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0C0h],rax
    call    fn2
    nop     [rcx]
    jmp     L3
L2:
    mov     eax,[rbp+28h]
    sub     eax,1
    mov     [rbp+28h],eax
    mov     rdx,[rbp+10h]
    mov     [rbp-58h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-50h],rsi
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-0C0h],rax
    call    fn3
    nop     [rcx-48h]
    jmp     L4
L3:
    jmp     L15
L4:
    mov     edi,0FFFFFF5Ch
    mov     esi,20h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L5]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L5:
    .long   L11
    .long   L6
    .long   L20
L6:
    mov     rax,[rbp+20h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-10h],rsi
    mov     [rbp-20h],rsi
    mov     rdi,[rbp-48h]
    cmp     rdi,rsi
    jb      L9
    mov     [rbp-0D0h],rdi
    mov     [rbp-0C8h],rsi
    mov     edi,0FFFFFF40h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-0A0h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-48h],4
    add     rax,rcx
    mov     [rbp-0A8h],rax
    mov     [rbp-68h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rax
    mov     rsi,[rbp+30h]
    mov     [rbp-0D0h],rsi
    mov     [rbp-0C8h],rdx
    mov     [rbp-0C0h],rax
    call    fn8
    nop     [rcx-3Ah]
    test    byte ptr [rbp-3Ah],0FFh
    je      L10
    jmp     L11
L10:
    mov     edi,0FFFFFF98h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+30h]
    mov     [rbp-78h],rax
    lea     rdx,[rbp-78h]
    mov     [rbp-70h],rdx
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    mov     rax,[rbp-48h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-0B8h],rdx
    call    fn9
    nop     [rcx-58h]
    mov     rax,[rbp-58h]
    add     rax,1
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-60h],rdx
    cmp     rdx,rax
    jb      L16
    jmp     L19
L11:
    mov     edi,0FFFFFFA0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     rax,[rbp-48h]
    mov     [rbp-0C0h],rax
    mov     rdx,[rbp+30h]
    mov     [rbp-0B8h],rdx
    call    fn10
    nop     [rcx-50h]
    mov     rax,[rbp+10h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     rsi,[rbp-50h]
    cmp     rsi,rdx
    setb    [rbp-3Ah]
    mov     edi,0FFFFFF30h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-0C0h],rax
    mov     edi,0FFFFFF48h
    lea     rsi,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx-90h]
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-0C0h],1
    mov     edi,0FFFFFF48h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-0A0h]
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFF60h
    call    ryo_h_MovW128
    mov     edi,10h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    mov     rax,[rbp-78h]
    mov     [rbp-38h],rax
    mov     qword ptr [rbp-0A8h],0
    mov     rsi,[rbp-0A8h]
    cmp     rsi,rax
    setb    [rbp-39h]
    test    byte ptr [rbp-39h],0FFh
    jne     L14
    mov     qword ptr [rbp-0D0h],0
    mov     [rbp-0C8h],rax
    mov     edi,0FFFFFF40h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[sym16]
    lea     rsi,[site17]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L12
    call    rax
    nop     [rcx-0A0h]
    jmp     L13
L12:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L13:
    call    ryo_h_Unreachable
    ud2
L14:
    mov     rax,[rbp-80h]
    mov     [rbp-88h],rax
    mov     edx,[rbp+28h]
    mov     [rbp-40h],edx
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-0C0h],rax
    mov     edx,[rbp-40h]
    mov     [rbp-0B8h],edx
    mov     rsi,[rbp+30h]
    mov     [rbp-0B0h],rsi
    call    fn19
    nop     [rcx-39h]
    mov     rax,[rbp-88h]
    mov     [rbp+20h],rax
    jmp     L0
L15:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L16:
    mov     rax,[rbp-30h]
    mov     [rbp-0D0h],rax
    mov     rdx,[rbp-60h]
    mov     [rbp-0C8h],rdx
    mov     rsi,[rbp-60h]
    mov     [rbp-0C0h],rsi
    mov     edi,0FFFFFF48h
    lea     rsi,[k20]
    call    ryo_h_AddrAbs
    lea     rdi,[sym21]
    lea     rsi,[site22]
    mov     edx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L17
    call    rax
    nop     [rcx-39h]
    jmp     L18
L17:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym23]
L18:
    call    ryo_h_Unreachable
    ud2
L19:
    mov     rax,[rbp-60h]
    sub     rax,[rbp-30h]
    mov     [rbp-68h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-88h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-80h],rsi
    mov     [rbp-90h],rdx
    imul    rcx,[rbp-30h],4
    add     rdx,rcx
    mov     [rbp-98h],rdx
    mov     [rbp-78h],rdx
    mov     [rbp-70h],rax
    mov     [rbp+10h],rdx
    mov     [rbp+18h],rax
    mov     qword ptr [rbp+20h],0
    jmp     L0
L20:
    call    ryo_h_Unreachable
    ud2

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-20h],rsi
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rsi
    call    fn0
    nop     [rcx-11h]
    movzx   eax,byte ptr [rbp-11h]
    xor     al,1
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn core::slice::sort::unstable::sort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     byte ptr [rbp-0Ah],0
    test    byte ptr [rbp-0Ah],0FFh
    jne     L2
    mov     rsi,[rbp+18h]
    mov     [rbp-8],rsi
    cmp     rsi,2
    setb    [rbp-9]
    test    byte ptr [rbp-9],0FFh
    je      L4
    jmp     L3
    nop     [rax+rax]
L0:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    jmp     L2
L4:
    cmp     qword ptr [rbp-8],14h
    setbe   [rbp-9]
    test    byte ptr [rbp-9],0FFh
    je      L5
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-20h],1
    mov     rdx,[rbp+20h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx]
    jmp     L0
L5:
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    call    fn1
    nop     [rcx]
    jmp     L1

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-38h],rsi
    mov     rdi,[rbp+28h]
    mov     [rbp-60h],rdi
    mov     edi,0FFFFFFA8h
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_MulOvfUW64
    mov     rax,[rbp-58h]
    mov     [rbp-38h],rax
    movzx   edx,byte ptr [rbp-50h]
    mov     [rbp-1Dh],dl
    mov     [rbp-68h],rax
    test    byte ptr [rbp-1Dh],0FFh
    je      L2
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],3Dh
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-1]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-68h]
    mov     [rbp-40h],rax
    mov     qword ptr [rbp-48h],1
    mov     [rbp-38h],rax
    mov     rsi,[rbp-28h]
    cmp     rsi,[rbp-30h]
    jae     L3
    mov     rdi,[rbp-30h]
    sub     rdi,rsi
    mov     [rbp-10h],rdi
    jmp     L4
L3:
    mov     rax,[rbp-28h]
    sub     rax,[rbp-30h]
    mov     [rbp-10h],rax
L4:
    mov     rax,[rbp-38h]
    cmp     rax,[rbp-10h]
    setbe   [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn main
    push    rbp
    mov     rbp,rsp
    sub     rsp,330h
    mov     qword ptr [rbp-330h],3D090h
    call    fn0
    nop     [rcx-8]
    mov     rax,2545F4914F6CDD1Dh
    mov     [rbp-10h],rax
    mov     qword ptr [rbp-50h],0
    mov     rsi,[rbp-8]
    mov     [rbp-48h],rsi
    lea     rdi,[rbp-10h]
    mov     [rbp-60h],rdi
    mov     [rbp-58h],rdi
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rbp-58h]
    mov     [rbp-320h],rax
    call    fn1
    nop     [rcx-40h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFFC0h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx-28h]
    lea     rax,[rbp-28h]
    mov     [rbp-80h],rax
    mov     [rbp-330h],rax
    call    fn3
    nop     [rcx-78h]
    lea     rax,[rbp-78h]
    mov     [rbp-98h],rax
    mov     [rbp-330h],rax
    call    fn4
    nop     [rcx-90h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFF70h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx-80h]
    lea     rax,[rbp-28h]
    mov     [rbp-0B8h],rax
    mov     [rbp-330h],rax
    call    fn6
    nop     [rcx-0B0h]
    lea     rax,[rbp-0B0h]
    mov     [rbp-0D0h],rax
    mov     [rbp-330h],rax
    call    fn7
    nop     [rcx-0C8h]
    mov     rax,[rbp-8]
    mov     [rbp-330h],rax
    call    fn8
    nop     [rcx-0F0h]
    lea     rax,[rbp-0F0h]
    mov     [rbp-0D8h],rax
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFF38h
    call    ryo_h_MovW128
    mov     rax,[rbp-0D8h]
    mov     [rbp-320h],rax
    call    fn9
    nop     [rcx-0B8h]
    lea     rax,[rbp-0F0h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn10
    nop     [rcx-2F8h]
    lea     rax,[rbp-78h]
    mov     [rbp-108h],rax
    lea     rdx,[rbp-0B0h]
    mov     [rbp-110h],rdx
    mov     [rbp-100h],rax
    mov     [rbp-0F8h],rdx
    mov     [rbp-118h],rax
    mov     [rbp-120h],rdx
    mov     [rbp-330h],rax
    mov     [rbp-328h],rdx
    call    fn11
    nop     [rcx-121h]
    test    byte ptr [rbp-121h],0FFh
    je      L0
    lea     rdx,[rbp-28h]
    mov     [rbp-188h],rdx
    mov     [rbp-330h],rdx
    call    fn12
    nop     [rcx-180h]
    jmp     L1
L0:
    mov     byte ptr [rbp-122h],0
    mov     qword ptr [rbp-138h],0
    movzx   esi,byte ptr [rbp-122h]
    mov     [rbp-310h],sil
    mov     rdi,[rbp-118h]
    mov     [rbp-330h],rdi
    mov     r8,[rbp-120h]
    mov     [rbp-328h],r8
    mov     edi,0FFFFFCE0h
    mov     esi,0FFFFFEC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFCF8h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-122h]
    call    ryo_h_Unreachable
    ud2
L1:
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFE80h
    call    ryo_h_MovW128
    call    fn15
    nop     [rcx-170h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFE90h
    call    ryo_h_MovW128
    call    fn16
    nop     [rcx-160h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFEA0h
    call    ryo_h_MovW128
    call    fn17
    nop     [rcx-150h]
    lea     rax,[rbp-150h]
    mov     [rbp-1A0h],rax
    mov     [rbp-330h],rax
    call    fn18
    nop     [rcx-198h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFE68h
    call    ryo_h_MovW128
    call    fn19
    nop     [rcx-188h]
    lea     rax,[rbp-78h]
    mov     [rbp-1F8h],rax
    mov     [rbp-330h],rax
    call    fn20
    nop     [rcx-1F0h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFE10h
    call    ryo_h_MovW128
    call    fn21
    nop     [rcx-1E0h]
    lea     rax,[rbp-1E0h]
    mov     [rbp-1D8h],rax
    lea     rdx,[rbp-150h]
    mov     [rbp-208h],rdx
    mov     [rbp-330h],rdx
    mov     qword ptr [rbp-328h],0
    mov     edi,0FFFFFCE0h
    lea     rsi,[k22]
    call    ryo_h_AddrAbs
    call    fn23
    nop     [rcx-200h]
    lea     rax,[rbp-150h]
    mov     [rbp-218h],rax
    mov     qword ptr [rbp-2F8h],1
    mov     edi,0FFFFFDD0h
    mov     esi,0FFFFFDD8h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFD08h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rbp-228h],0FFh
    je      L4
    mov     edi,0FFFFFCD0h
    lea     rsi,[k24]
    call    ryo_h_AddrAbs
    lea     rdi,[sym25]
    lea     rsi,[site26]
    mov     edx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-2F0h]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym27]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rbp-230h]
    mov     [rbp-220h],rax
    mov     rdx,[rbp-218h]
    mov     [rbp-330h],rdx
    mov     [rbp-328h],rax
    mov     edi,0FFFFFCE0h
    lea     rsi,[k28]
    call    ryo_h_AddrAbs
    call    fn29
    nop     [rcx-210h]
    lea     rax,[rbp-8]
    mov     [rbp-238h],rax
    mov     rdx,[rbp-1D8h]
    mov     [rbp-1D0h],rdx
    mov     rsi,[rbp-200h]
    mov     [rbp-1C8h],rsi
    mov     rdi,[rbp-210h]
    mov     [rbp-1C0h],rdi
    mov     [rbp-1B8h],rax
    mov     [rbp-2D0h],rax
    mov     [rbp-330h],rax
    call    fn30
    nop     [rcx-288h]
    mov     rax,[rbp-1D0h]
    mov     [rbp-2D8h],rax
    mov     [rbp-330h],rax
    call    fn31
    nop     [rcx-298h]
    mov     rax,[rbp-1C8h]
    mov     [rbp-2E0h],rax
    mov     [rbp-330h],rax
    call    fn32
    nop     [rcx-2A8h]
    mov     rax,[rbp-1C0h]
    mov     [rbp-2E8h],rax
    mov     [rbp-330h],rax
    call    fn33
    nop     [rcx-2B8h]
    mov     edi,0FFFFFD88h
    mov     esi,0FFFFFD78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFD98h
    mov     esi,0FFFFFD68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFDA8h
    mov     esi,0FFFFFD58h
    call    ryo_h_MovW128
    mov     edi,0FFFFFDB8h
    mov     esi,0FFFFFD48h
    call    ryo_h_MovW128
    mov     edi,0FFFFFD40h
    lea     rsi,[k34]
    call    ryo_h_AddrAbs
    lea     rax,[rbp-278h]
    mov     [rbp-2C8h],rax
    mov     rdx,[rbp-2C0h]
    mov     [rbp-330h],rdx
    mov     [rbp-328h],rax
    call    fn35
    nop     [rcx-1B0h]
    mov     edi,0FFFFFCD0h
    mov     esi,0FFFFFE50h
    call    ryo_h_MovW128
    lea     rdi,[sym36]
    lea     rsi,[site37]
    mov     edx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-1A0h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym38]
L6:
    lea     rax,[rbp-150h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn39
    nop     [rcx-2F8h]
    lea     rax,[rbp-0B0h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn40
    nop     [rcx-2F8h]
    lea     rax,[rbp-78h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn41
    nop     [rcx-2F8h]
    lea     rax,[rbp-28h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn42
    nop     [rcx-2F8h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L7:
    lea     rax,[rbp-150h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn43
    nop     [rcx-2F8h]
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L8:
    lea     rax,[rbp-0F0h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn44
    nop     [rcx-2F8h]
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    lea     rax,[rbp-0B0h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn45
    nop     [rcx-2F8h]
    nop     [rax+rax]
    nop     [rax+rax]
L10:
    lea     rax,[rbp-78h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn46
    nop     [rcx-2F8h]
    xchg    ax,ax
L11:
    lea     rax,[rbp-28h]
    mov     [rbp-2F8h],rax
    mov     [rbp-330h],rax
    call    fn47
    nop     [rcx-2F8h]
    mov     edi,0FFFFFD10h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L12:
    lea     rdi,[sym48]
    lea     rsi,[site49]
    mov     edx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-2F0h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym50]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L11
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L10
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L8
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L7
    mov     rdi,rax
    mov     esi,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L12

fn main::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFFCh
    mov     esi,0FFFFFFF0h
    call    ryo_h_TruncW64W32
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn main::{closure#1}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+18h]
    mov     eax,[rax]
    mov     [rbp-0Ch],eax
    mov     dword ptr [rbp-18h],3E8h
    cmp     dword ptr [rbp-18h],0
    sete    [rbp-11h]
    test    byte ptr [rbp-11h],0FFh
    je      L2
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFE0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-11h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     dword ptr [rbp-18h],3E8h
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFF4h
    mov     edx,0FFFFFFE8h
    call    ryo_h_RemUW32
    mov     eax,[rbp-10h]
    mov     [rbp-8],eax
    mov     edx,[rbp-0Ch]
    mov     [rbp-4],edx
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn main::{closure#2}
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+18h]
    mov     eax,[rax]
    mov     [rbp-4],eax
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn merge_sort
    push    rbp
    mov     rbp,rsp
    sub     rsp,380h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    mov     [rbp-10h],rdx
    cmp     rdx,10h
    ja      L20
    mov     rdi,[rbp+10h]
    mov     [rbp-58h],rdi
    mov     r8,[rbp+18h]
    mov     [rbp-50h],r8
    mov     [rbp-48h],r8
    mov     qword ptr [rbp-40h],1
    mov     [rbp-38h],r8
    mov     edi,0FFFFFC80h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-30h]
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    nop     [rax+rax]
    nop     [rax]
L0:
    lea     rax,[rbp-68h]
    mov     [rbp-80h],rax
    mov     [rbp-380h],rax
    call    fn1
    nop     [rcx-78h]
    mov     rax,[rbp-78h]
    mov     [rbp-88h],rax
    mov     edi,0FFFFFF78h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L45
    .long   L3
    .long   L2
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-90h],rax
    mov     [rbp-98h],rax
    nop     [rax]
L4:
    mov     rax,[rbp-98h]
    mov     [rbp-0A8h],rax
    cmp     rax,0
    jbe     L0
    mov     rsi,[rbp-98h]
    mov     [rbp-0C0h],rsi
    mov     qword ptr [rbp-358h],1
    mov     edi,0FFFFFF30h
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF40h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rbp-0C8h],0FFh
    je      L7
    mov     edi,0FFFFFC80h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-350h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rbp-0D0h]
    mov     [rbp-0B8h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-0E0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-0D8h],rsi
    mov     [rbp-0E8h],rsi
    cmp     rax,rsi
    jb      L10
    mov     [rbp-380h],rax
    mov     [rbp-378h],rsi
    mov     edi,0FFFFFC90h
    lea     rsi,[k6]
    call    ryo_h_AddrAbs
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx-350h]
    jmp     L9
L8:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L9:
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-0B8h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-0B0h],eax
    mov     rdx,[rbp-98h]
    mov     [rbp-0F8h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-108h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-100h],rdi
    mov     [rbp-110h],rdi
    cmp     rdx,rdi
    jb      L13
    mov     [rbp-380h],rdx
    mov     [rbp-378h],rdi
    mov     edi,0FFFFFC90h
    lea     rsi,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[sym11]
    lea     rsi,[site12]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L11
    call    rax
    nop     [rcx-350h]
    jmp     L12
L11:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L12:
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-0F8h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-0F0h],eax
    cmp     eax,[rbp-0B0h]
    jae     L0
    mov     rdx,[rbp-98h]
    mov     [rbp-128h],rdx
    mov     qword ptr [rbp-358h],1
    mov     edi,0FFFFFEC8h
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFED8h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rbp-130h],0FFh
    je      L16
    mov     edi,0FFFFFC80h
    lea     rsi,[k14]
    call    ryo_h_AddrAbs
    lea     rdi,[sym15]
    lea     rsi,[site16]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L14
    call    rax
    nop     [rcx-350h]
    jmp     L15
L14:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym17]
L15:
    call    ryo_h_Unreachable
    ud2
L16:
    mov     rax,[rbp-138h]
    mov     [rbp-120h],rax
    mov     rdx,[rbp-98h]
    mov     [rbp-140h],rdx
    mov     edi,0FFFFFC80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-120h]
    mov     [rbp-370h],rax
    mov     rdx,[rbp-140h]
    mov     [rbp-368h],rdx
    mov     edi,0FFFFFCA0h
    lea     rsi,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx-111h]
    mov     qword ptr [rbp-358h],1
    mov     edi,0FFFFFEB0h
    mov     esi,0FFFFFEB8h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rbp-148h],0FFh
    je      L19
    mov     edi,0FFFFFC80h
    lea     rsi,[k20]
    call    ryo_h_AddrAbs
    lea     rdi,[sym21]
    lea     rsi,[site22]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L17
    call    rax
    nop     [rcx-350h]
    jmp     L18
L17:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L18:
    call    ryo_h_Unreachable
    ud2
L19:
    mov     rax,[rbp-150h]
    mov     [rbp-98h],rax
    jmp     L4
L20:
    mov     rax,[rbp+10h]
    mov     [rbp-170h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-168h],rdx
    mov     [rbp-160h],rdx
    mov     qword ptr [rbp-358h],2
    cmp     qword ptr [rbp-358h],0
    sete    [rbp-171h]
    test    byte ptr [rbp-171h],0FFh
    je      L23
    mov     edi,0FFFFFC80h
    lea     rsi,[k24]
    call    ryo_h_AddrAbs
    lea     rdi,[sym25]
    lea     rsi,[site26]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-350h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym27]
L22:
    call    ryo_h_Unreachable
    ud2
L23:
    mov     qword ptr [rbp-358h],2
    mov     edi,0FFFFFEA8h
    mov     esi,0FFFFFEA0h
    mov     edx,0FFFFFCA8h
    call    ryo_h_DivUW64
    mov     rax,[rbp-158h]
    mov     [rbp-190h],rax
    mov     edi,0FFFFFC80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-190h]
    mov     [rbp-370h],rax
    mov     edi,0FFFFFC98h
    lea     rsi,[k28]
    call    ryo_h_AddrAbs
    call    fn29
    nop     [rcx-188h]
    mov     edi,0FFFFFC80h
    mov     esi,0FFFFFE78h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-370h],rax
    call    fn30
    nop     [rcx-171h]
    mov     rax,[rbp-158h]
    mov     [rbp-1A8h],rax
    mov     edi,0FFFFFC80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-1A8h]
    mov     [rbp-370h],rax
    mov     edi,0FFFFFC98h
    lea     rsi,[k31]
    call    ryo_h_AddrAbs
    call    fn32
    nop     [rcx-1A0h]
    mov     edi,0FFFFFC80h
    mov     esi,0FFFFFE60h
    call    ryo_h_MovW128
    mov     rax,[rbp+20h]
    mov     [rbp-370h],rax
    call    fn33
    nop     [rcx-190h]
    mov     rax,[rbp+20h]
    mov     [rbp-380h],rax
    call    fn34
    nop     [rcx-1A8h]
    mov     qword ptr [rbp-1C8h],0
    mov     rdx,[rbp-158h]
    mov     [rbp-1C0h],rdx
    mov     rsi,[rbp-1C8h]
    mov     [rbp-1B0h],rsi
    mov     [rbp-1B8h],rdx
    nop     [rax+rax]
    nop
L24:
    mov     rax,[rbp-1B0h]
    mov     [rbp-1D8h],rax
    cmp     rax,[rbp-158h]
    jae     L44
    mov     rdx,[rbp-1B8h]
    mov     [rbp-1E8h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-200h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-1F8h],rdi
    mov     [rbp-1F0h],rdi
    cmp     rdx,rdi
    jae     L44
    mov     r8,[rbp-1B0h]
    mov     [rbp-210h],r8
    mov     r9,[rbp+10h]
    mov     [rbp-220h],r9
    mov     r10,[rbp+18h]
    mov     [rbp-218h],r10
    mov     [rbp-228h],r10
    cmp     r8,r10
    jb      L27
    mov     [rbp-380h],r8
    mov     [rbp-378h],r10
    mov     edi,0FFFFFC90h
    lea     rsi,[k35]
    call    ryo_h_AddrAbs
    lea     rdi,[sym36]
    lea     rsi,[site37]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L25
    call    rax
    nop     [rcx-350h]
    jmp     L26
L25:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym38]
L26:
    call    ryo_h_Unreachable
    ud2
L27:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-210h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-208h],eax
    mov     rdx,[rbp-1B8h]
    mov     [rbp-238h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-248h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-240h],rdi
    mov     [rbp-250h],rdi
    cmp     rdx,rdi
    jb      L30
    mov     [rbp-380h],rdx
    mov     [rbp-378h],rdi
    mov     edi,0FFFFFC90h
    lea     rsi,[k39]
    call    ryo_h_AddrAbs
    lea     rdi,[sym40]
    lea     rsi,[site41]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L28
    call    rax
    nop     [rcx-350h]
    jmp     L29
L28:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym42]
L29:
    call    ryo_h_Unreachable
    ud2
L30:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-238h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-230h],eax
    cmp     eax,[rbp-208h]
    jb      L37
    mov     rdx,[rbp-1B0h]
    mov     [rbp-260h],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-270h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-268h],rdi
    mov     [rbp-278h],rdi
    cmp     rdx,rdi
    jb      L33
    mov     [rbp-380h],rdx
    mov     [rbp-378h],rdi
    mov     edi,0FFFFFC90h
    lea     rsi,[k43]
    call    ryo_h_AddrAbs
    lea     rdi,[sym44]
    lea     rsi,[site45]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L31
    call    rax
    nop     [rcx-350h]
    jmp     L32
L31:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym46]
L32:
    call    ryo_h_Unreachable
    ud2
L33:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-260h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-258h],eax
    mov     rdx,[rbp+20h]
    mov     [rbp-380h],rdx
    mov     [rbp-378h],eax
    call    fn47
    nop     [rcx-251h]
    mov     qword ptr [rbp-358h],1
    mov     edi,0FFFFFD70h
    mov     esi,0FFFFFD78h
    mov     edx,0FFFFFE50h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-288h],0FFh
    je      L36
    mov     edi,0FFFFFC80h
    lea     rsi,[k48]
    call    ryo_h_AddrAbs
    lea     rdi,[sym49]
    lea     rsi,[site50]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L34
    call    rax
    nop     [rcx-350h]
    jmp     L35
L34:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym51]
L35:
    call    ryo_h_Unreachable
    ud2
L36:
    mov     rax,[rbp-290h]
    mov     [rbp-1B0h],rax
    jmp     L24
L37:
    mov     rax,[rbp-1B8h]
    mov     [rbp-2A0h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-2B0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-2A8h],rsi
    mov     [rbp-2B8h],rsi
    cmp     rax,rsi
    jb      L40
    mov     [rbp-380h],rax
    mov     [rbp-378h],rsi
    mov     edi,0FFFFFC90h
    lea     rsi,[k52]
    call    ryo_h_AddrAbs
    lea     rdi,[sym53]
    lea     rsi,[site54]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L38
    call    rax
    nop     [rcx-350h]
    jmp     L39
L38:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym55]
L39:
    call    ryo_h_Unreachable
    ud2
L40:
    mov     rax,[rbp+10h]
    imul    rcx,[rbp-2A0h],4
    add     rax,rcx
    mov     [rbp-358h],rax
    mov     eax,[rax]
    mov     [rbp-294h],eax
    mov     rdx,[rbp+20h]
    mov     [rbp-380h],rdx
    mov     [rbp-378h],eax
    call    fn56
    nop     [rcx-290h]
    mov     qword ptr [rbp-358h],1
    mov     edi,0FFFFFD30h
    mov     esi,0FFFFFD38h
    mov     edx,0FFFFFE48h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-2C8h],0FFh
    je      L43
    mov     edi,0FFFFFC80h
    lea     rsi,[k57]
    call    ryo_h_AddrAbs
    lea     rdi,[sym58]
    lea     rsi,[site59]
    mov     edx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L41
    call    rax
    nop     [rcx-350h]
    jmp     L42
L41:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym60]
L42:
    call    ryo_h_Unreachable
    ud2
L43:
    mov     rax,[rbp-2D0h]
    mov     [rbp-1B8h],rax
    jmp     L24
L44:
    mov     rax,[rbp+10h]
    mov     [rbp-2F0h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-2E8h],rdx
    mov     rsi,[rbp-1B0h]
    mov     [rbp-308h],rsi
    mov     [rbp-300h],rsi
    mov     rdi,[rbp-158h]
    mov     [rbp-2F8h],rdi
    mov     edi,0FFFFFC80h
    mov     esi,0FFFFFD10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC90h
    mov     esi,0FFFFFD00h
    call    ryo_h_MovW128
    mov     edi,0FFFFFCA0h
    lea     rsi,[k61]
    call    ryo_h_AddrAbs
    call    fn62
    nop     [rcx-2E0h]
    mov     rax,[rbp+20h]
    mov     [rbp-380h],rax
    mov     edi,0FFFFFC88h
    mov     esi,0FFFFFD20h
    call    ryo_h_MovW128
    call    fn63
    nop     [rcx-2D0h]
    mov     rax,[rbp+10h]
    mov     [rbp-328h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-320h],rdx
    mov     rsi,[rbp-1B8h]
    mov     [rbp-338h],rsi
    mov     [rbp-330h],rsi
    mov     edi,0FFFFFC80h
    mov     esi,0FFFFFCD8h
    call    ryo_h_MovW128
    mov     rax,[rbp-330h]
    mov     [rbp-370h],rax
    mov     edi,0FFFFFC98h
    lea     rsi,[k64]
    call    ryo_h_AddrAbs
    call    fn65
    nop     [rcx-318h]
    mov     rax,[rbp+20h]
    mov     [rbp-380h],rax
    mov     edi,0FFFFFC88h
    mov     esi,0FFFFFCE8h
    call    ryo_h_MovW128
    call    fn66
    nop     [rcx-308h]
    mov     rax,[rbp+20h]
    mov     [rbp-350h],rax
    mov     [rbp-380h],rax
    call    fn67
    nop     [rcx-348h]
    mov     edi,0FFFFFC80h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     edi,0FFFFFC90h
    mov     esi,0FFFFFCB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFCA0h
    lea     rsi,[k68]
    call    ryo_h_AddrAbs
    call    fn69
    nop     [rcx-338h]
L45:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::array::iter::iter_inner::PolymorphicIter::<[std::mem::MaybeUninit<usize>]>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-58h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-60h],rdx
    sub     rax,rdx
    mov     [rbp-50h],rax
    cmp     rax,0
    jbe     L0
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-50h],rdi
    mov     byte ptr [rbp-99h],1
    test    byte ptr [rbp-99h],0FFh
    je      L2
    jmp     L1
L0:
    mov     edi,0FFFFFFC0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp+10h]
    lea     rax,[rax+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-10h],0
    jmp     L3
L1:
    mov     rax,[rbp-50h]
    mov     [rbp-0C0h],rax
    mov     qword ptr [rbp-0B8h],1
    mov     edi,0FFFFFF50h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-30h]
L2:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-58h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-58h]
    mov     [rdx],rcx
    mov     rsi,[rbp-50h]
    mov     [rbp-38h],rsi
    mov     qword ptr [rbp-40h],1
    mov     r8,[rbp+10h]
    lea     r8,[r8+10h]
    mov     [rbp-28h],r8
    mov     r9,[rbp+18h]
    mov     [rbp-20h],r9
    mov     edi,0FFFFFF68h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rbp-38h]
    mov     [rbp-48h],rax
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-99h],1
    test    byte ptr [rbp-99h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp-20h]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-48h]
    mov     [rbp-0C0h],rdx
    mov     [rbp-0B8h],rax
    mov     edi,0FFFFFF50h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx-30h]
L5:
    mov     rax,[rbp-20h]
    mov     [rbp-78h],rax
    mov     rdx,[rbp-48h]
    cmp     rdx,rax
    setb    [rbp-69h]
    mov     rsi,[rbp-28h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rbp-0A0h],rsi
    mov     [rbp-68h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
    mov     rax,[rbp-68h]
    mov     [rbp-70h],rax
    mov     rax,[rax]
    mov     [rbp-50h],rax
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L3

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     eax,[rax]
    mov     [rbp-8],eax
    mov     rdx,[rbp+18h]
    mov     edx,[rdx]
    mov     [rbp-0Ch],edx
    cmp     eax,edx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-18h],rdx
    cmp     rax,rdx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::Arguments::<'_>::new::<22, 4>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-20h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::DebugList::<'_, '_>::entries::<&u32, std::slice::Iter<'_, u32>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     edi,0FFFFFF70h
    mov     esi,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx-28h]
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    nop     [rax+rax]
    xchg    ax,ax
L0:
    lea     rax,[rbp-38h]
    mov     [rbp-48h],rax
    mov     [rbp-90h],rax
    call    fn1
    nop     [rcx-40h]
    mov     edi,0FFFFFF8Ch
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L1:
    .long   L6
    .long   L3
    .long   L2
L2:
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rbp-40h]
    mov     [rbp-50h],rax
    lea     rdx,[rbp-50h]
    mov     [rbp-70h],rdx
    mov     [rbp-68h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     edi,0FFFFFF78h
    mov     esi,0FFFFFF98h
    call    ryo_h_MovW128
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-58h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    jmp     L7
L6:
    jmp     L8
L7:
    jmp     L0
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax]
L9:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9

fn std::hint::assert_unchecked::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    test    byte ptr [rbp+10h],0FFh
    jne     L2
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DDh
    mov     rdx,[rbp-10h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-38h],rsi
    mov     [rbp-30h],rdx
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-50h],0DDh
    mov     rdx,[rbp-50h]
    mov     [rbp-48h],rdx
    shl     rdx,1
    mov     [rbp-40h],rdx
    or      rdx,1
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-28h]
    mov     [rbp-20h],rsi
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-70h],0
    mov     rdx,[rbp+18h]
    mov     [rbp-68h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-10h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::hint::black_box::<usize>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::hint::select_unpredictable::<*const (u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    lea     rsi,[rbp-30h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    lea     rdi,[rbp-38h]
    mov     [rbp-50h],rdi
    mov     [rbp-48h],rdi
    movzx   r8d,byte ptr [rbp+18h]
    mov     [rbp-88h],r8b
    mov     [rbp-90h],rsi
    mov     [rbp-80h],rdi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rbp+18h]
    mov     [rbp-88h],al
    mov     rdx,[rbp-48h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rbp-50h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF88h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    lea     rax,[rbp-58h]
    mov     [rbp-78h],rax
    mov     [rbp-90h],rax
    call    fn5
    nop     [rcx-78h]
    jmp     L1
L3:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-70h],rsi
    movzx   edi,byte ptr [rbp+18h]
    mov     [rbp-88h],dil
    mov     [rbp-90h],rdx
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rbp-60h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-70h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::hint::select_unpredictable::<*const u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    lea     rsi,[rbp-30h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    lea     rdi,[rbp-38h]
    mov     [rbp-50h],rdi
    mov     [rbp-48h],rdi
    movzx   r8d,byte ptr [rbp+18h]
    mov     [rbp-88h],r8b
    mov     [rbp-90h],rsi
    mov     [rbp-80h],rdi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rbp+18h]
    mov     [rbp-88h],al
    mov     rdx,[rbp-48h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rbp-50h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF88h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    lea     rax,[rbp-58h]
    mov     [rbp-78h],rax
    mov     [rbp-90h],rax
    call    fn5
    nop     [rcx-78h]
    jmp     L1
L3:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-70h],rsi
    movzx   edi,byte ptr [rbp+18h]
    mov     [rbp-88h],dil
    mov     [rbp-90h],rdx
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rbp-60h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-70h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::hint::select_unpredictable::<*mut u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    lea     rsi,[rbp-30h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    lea     rdi,[rbp-38h]
    mov     [rbp-50h],rdi
    mov     [rbp-48h],rdi
    movzx   r8d,byte ptr [rbp+18h]
    mov     [rbp-88h],r8b
    mov     [rbp-90h],rsi
    mov     [rbp-80h],rdi
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rbp+18h]
    mov     [rbp-88h],al
    mov     rdx,[rbp-48h]
    mov     [rbp-90h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rbp-50h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF88h
    lea     rsi,[sym2]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rdi,rbp
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    lea     rax,[rbp-58h]
    mov     [rbp-78h],rax
    mov     [rbp-90h],rax
    call    fn5
    nop     [rcx-78h]
    jmp     L1
L3:
    mov     rax,[rbp-58h]
    mov     [rbp-60h],rax
    mov     rdx,[rbp-30h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-70h],rsi
    movzx   edi,byte ptr [rbp+18h]
    mov     [rbp-88h],dil
    mov     [rbp-90h],rdx
    mov     [rbp-80h],rsi
    mov     rdi,rbp
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rbp-60h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L5:
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-70h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::intrinsics::cold_path
    push    rbp
    mov     rbp,rsp
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<*mut *const (u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<*mut *const u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<*mut *mut u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const (u32, u32)>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const u32>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*mut u32>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    test    byte ptr [rbp+18h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-8],rdx
    jmp     L1
L0:
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::intrinsics::typed_swap_nonoverlapping::<(u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     qword ptr [rbp-20h],1
    mov     edi,0FFFFFFE8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-8]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::intrinsics::typed_swap_nonoverlapping::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     qword ptr [rbp-20h],1
    mov     edi,0FFFFFFE8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-8]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rdx
    mov     [rbp-20h],rax
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     edx,[rbp+18h]
    mov     [rbp-0Ch],edx
    mov     [rbp-20h],rax
    mov     [rbp-18h],edx
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     byte ptr [rbp-1],1
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+18h]
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-38h],rdi
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdi
    call    fn0
    nop     [rcx-28h]
    mov     byte ptr [rbp-1],0
    mov     rdx,[rbp-28h]
    mov     [rbp-20h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-50h],rsi
    mov     [rbp-48h],rdx
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rbp-1],0FFh
    je      L0
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     byte ptr [rbp-1],1
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+18h]
    mov     [rbp-28h],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-30h],rdi
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdi
    call    fn0
    nop     [rcx-20h]
    mov     byte ptr [rbp-1],0
    mov     edx,[rbp-20h]
    mov     [rbp-1Ch],edx
    mov     rsi,[rbp-18h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],edx
    call    fn1
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rbp-1],0FFh
    je      L0
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::size_hint
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-30h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rdx,[rbp+10h]
    mov     [rbp-28h],rdx
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+8]
    mov     [rbp-30h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rsi
    call    fn1
    nop     [rcx-18h]
    jmp     L1
L0:
    mov     qword ptr [rbp-18h],0
    mov     edi,0FFFFFFF0h
    lea     rsi,[k2]
    mov     edx,10h
    call    ryo_h_Const
L1:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     edi,0FFFFFF9Ch
    mov     esi,18h
    call    ryo_h_CtpopW64
    mov     eax,[rbp-64h]
    mov     [rbp-8],eax
    jmp     L4
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    sub     rdx,1
    mov     [rbp-20h],rdx
    and     rax,rdx
    mov     [rbp-10h],rax
    cmp     rax,0
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFD8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-20h],2Ah
    mov     rdx,[rbp-28h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],2Ah
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-18h],rsi
    mov     [rbp-10h],rdx
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx-1]
    jmp     L3
L2:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L3:
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     dword ptr [rbp-8],1
    sete    [rbp-2]
    test    byte ptr [rbp-2],0FFh
    je      L1
    jmp     L0

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    cmp     rax,[rbp+18h]
    jb      L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0C9h
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0C9h
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::copy::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0DDh
    mov     rdx,[rbp-10h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],0DDh
    mov     rdx,[rbp-60h]
    mov     [rbp-58h],rdx
    shl     rdx,1
    mov     [rbp-50h],rdx
    or      rdx,1
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-10h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L5:
    test    byte ptr [rbp+28h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L6:
    jmp     L2
L7:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-30h],rdx
    mov     [rbp-90h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-88h],rsi
    call    fn6
    nop     [rcx-1Bh]
    jmp     L13
L8:
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L2
    jmp     L14
L9:
    test    byte ptr [rbp-1Ah],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
L10:
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L11:
    jmp     L0
    nop     [rax+rax]
    xchg    ax,ax
L12:
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    cmp     rax,0
    sete    [rbp-1Ch]
    movzx   esi,byte ptr [rbp-1Ch]
    xor     sil,1
    mov     [rbp-1Ah],sil
    test    byte ptr [rbp-1Ah],0FFh
    je      L1
    jmp     L0
L13:
    test    byte ptr [rbp-1Bh],0FFh
    je      L10
    jmp     L11
L14:
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-30h],rdx
    mov     [rbp-90h],rax
    mov     rsi,[rbp+20h]
    mov     [rbp-88h],rsi
    call    fn7
    nop     [rcx-1Bh]
    test    byte ptr [rbp-1Bh],0FFh
    je      L10
    jmp     L12
    nop     [rax]
L15:
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L16
    call    rax
    nop     [rcx-68h]
    jmp     L17
L16:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L17:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L15

fn std::ptr::copy_nonoverlapping::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    cmp     qword ptr [rbp+30h],0
    jne     L0
    mov     byte ptr [rbp-1],1
    jmp     L1
L0:
    cmp     qword ptr [rbp+20h],0
    sete    [rbp-1]
L1:
    movzx   eax,byte ptr [rbp-1]
    mov     [rbp-2Bh],al
    mov     rdx,[rbp+10h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp+28h]
    mov     [rbp-98h],rsi
    call    fn0
    nop     [rcx-2Ch]
    jmp     L13
    nop
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-98h],rdx
    call    fn1
    nop     [rcx-2Ch]
    jmp     L18
    nop     [rax+rax]
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-0A0h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-98h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-90h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-88h],rdi
    call    fn2
    nop     [rcx-29h]
    jmp     L19
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFE0h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-18h],11Bh
    mov     rdx,[rbp-20h]
    mov     [rbp-60h],rdx
    mov     rsi,[rbp-18h]
    mov     [rbp-58h],rsi
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rdx
    mov     edi,0FFFFFF88h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-70h],11Bh
    mov     rdx,[rbp-70h]
    mov     [rbp-68h],rdx
    shl     rdx,1
    mov     [rbp-60h],rdx
    or      rdx,1
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rdx
    mov     rsi,[rbp-48h]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-90h],0
    mov     rdx,[rbp+38h]
    mov     [rbp-88h],rdx
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-20h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-2Bh],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rbp+10h]
    mov     [rbp-38h],rax
    cmp     rax,0
    sete    [rbp-2Dh]
    movzx   esi,byte ptr [rbp-2Dh]
    xor     sil,1
    mov     [rbp-2Ah],sil
    test    byte ptr [rbp-2Ah],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rbp-2Ch],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L14:
    test    byte ptr [rbp-1],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    cmp     rax,0
    sete    [rbp-2Dh]
    movzx   esi,byte ptr [rbp-2Dh]
    xor     sil,1
    mov     [rbp-2Bh],sil
    test    byte ptr [rbp-2Bh],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rbp-2Ch],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rbp-29h],0FFh
    je      L5
    jmp     L8
    nop     [rax]
L20:
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-78h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<(u32, u32)>> - shim(Some(alloc::raw_vec::RawVec<(u32, u32)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u32>> - shim(Some(alloc::raw_vec::RawVec<u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::slice::sort::stable::merge::MergeState<(u32, u32)>> - shim(Some(core::slice::sort::stable::merge::MergeState<(u32, u32)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<core::slice::sort::unstable::quicksort::GapGuardRaw<u32>> - shim(Some(core::slice::sort::unstable::quicksort::GapGuardRaw<u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::array::IntoIter<usize, 2>> - shim(Some(std::array::IntoIter<usize, 2>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*mut u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*mut u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<std::vec::Vec<(u32, u32)>> - shim(Some(std::vec::Vec<(u32, u32)>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn1
    nop     [rcx-18h]
    jmp     L1
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn2
    nop     [rcx-18h]
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-10h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::drop_glue::<std::vec::Vec<u32>> - shim(Some(std::vec::Vec<u32>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn1
    nop     [rcx-18h]
    jmp     L1
L3:
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-20h],rax
    call    fn2
    nop     [rcx-18h]
    jmp     L0
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx-10h]
    jmp     L6
L5:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::drop_glue::<std::vec::set_len_on_drop::SetLenOnDrop<'_>> - shim(Some(std::vec::set_len_on_drop::SetLenOnDrop<'_>))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}))
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    lea     rdx,[rbp-24h]
    mov     [rbp-18h],rdx
    mov     [rbp-38h],rdx
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L0
    mov     r8,[rbp+10h]
    mov     [rbp-40h],r8
    mov     r9,[rbp-18h]
    mov     [rbp-48h],r9
    mov     [rbp-90h],r8
    mov     [rbp-88h],r9
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-18h]
L0:
    mov     qword ptr [rbp-50h],1
    imul    rdx,[rbp-50h],4
    mov     [rbp-58h],rdx
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memcpy
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L5
    jmp     L2
    nop     [rax]
L1:
    lea     rax,[rbp-24h]
    mov     [rbp-20h],rax
    mov     [rbp-30h],rax
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L7
    jmp     L6
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     byte ptr [rbp-49h],0
    test    byte ptr [rbp-49h],0FFh
    je      L3
    mov     byte ptr [rbp-25h],1
    jmp     L4
L3:
    mov     byte ptr [rbp-25h],0
L4:
    mov     rax,[rbp-38h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-40h]
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],4
    movzx   edi,byte ptr [rbp-25h]
    mov     [rbp-78h],dil
    mov     edi,0FFFFFF90h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx-18h]
L5:
    mov     qword ptr [rbp-50h],1
    imul    rdx,[rbp-50h],4
    mov     [rbp-58h],rdx
    mov     edi,10h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memmove
    jmp     L1
L6:
    mov     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-40h],rdx
    mov     [rbp-90h],rax
    mov     [rbp-88h],rdx
    mov     qword ptr [rbp-80h],4
    mov     qword ptr [rbp-78h],4
    mov     qword ptr [rbp-70h],1
    mov     edi,0FFFFFF98h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-20h]
L7:
    mov     qword ptr [rbp-50h],1
    imul    rdx,[rbp-50h],4
    mov     [rbp-58h],rdx
    mov     edi,18h
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_Memcpy
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<1>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-1],al
    mov     rdx,[rbp+18h]
    movzx   edx,byte ptr [rdx]
    mov     [rbp-2],dl
    mov     rsi,[rbp+10h]
    movzx   ecx,byte ptr [rbp-2]
    mov     [rsi],cl
    mov     rdi,[rbp+18h]
    movzx   ecx,byte ptr [rbp-1]
    mov     [rdi],cl
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<2>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,word ptr [rax]
    mov     [rbp-2],ax
    mov     rdx,[rbp+18h]
    movzx   edx,word ptr [rdx]
    mov     [rbp-4],dx
    mov     rsi,[rbp+10h]
    movzx   ecx,word ptr [rbp-4]
    mov     [rsi],cx
    mov     rdi,[rbp+18h]
    movzx   ecx,word ptr [rbp-2]
    mov     [rdi],cx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<4>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     eax,[rax]
    mov     [rbp-4],eax
    mov     rdx,[rbp+18h]
    mov     edx,[rdx]
    mov     [rbp-8],edx
    mov     rsi,[rbp+10h]
    mov     ecx,[rbp-8]
    mov     [rsi],ecx
    mov     rdi,[rbp+18h]
    mov     ecx,[rbp-4]
    mov     [rdi],ecx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_chunk::<8>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-8],rax
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+10h]
    mov     rcx,[rbp-10h]
    mov     [rsi],rcx
    mov     rdi,[rbp+18h]
    mov     rcx,[rbp-8]
    mov     [rdi],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::ptr::swap_nonoverlapping::<(u32, u32)>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-41h],1
    test    byte ptr [rbp-41h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-80h],rsi
    mov     [rbp-78h],rdi
    mov     qword ptr [rbp-70h],8
    mov     qword ptr [rbp-68h],4
    mov     r10,[rbp+20h]
    mov     [rbp-60h],r10
    mov     r11,[rbp+28h]
    mov     [rbp-58h],r11
    call    fn0
    nop     [rcx]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    imul    rax,[rbp-20h],8
    mov     [rbp-18h],rax
    jmp     L3
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rax
    call    fn1
    nop     [rcx]
    jmp     L2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp-18h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::<u32>
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-41h],1
    test    byte ptr [rbp-41h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    mov     rdi,[rbp+18h]
    mov     [rbp-10h],rdi
    mov     [rbp-80h],rsi
    mov     [rbp-78h],rdi
    mov     qword ptr [rbp-70h],4
    mov     qword ptr [rbp-68h],4
    mov     r10,[rbp+20h]
    mov     [rbp-60h],r10
    mov     r11,[rbp+28h]
    mov     [rbp-58h],r11
    call    fn0
    nop     [rcx]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    imul    rax,[rbp-20h],4
    mov     [rbp-18h],rax
    jmp     L3
L1:
    mov     rax,[rbp-20h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-38h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rsi
    mov     [rbp-70h],rax
    call    fn1
    nop     [rcx]
    jmp     L2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L3:
    mov     rax,[rbp-18h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFBCh
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFD0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    cmp     qword ptr [rbp+20h],0
    jne     L0
    mov     byte ptr [rbp-1],1
    jmp     L1
L0:
    cmp     qword ptr [rbp+30h],0
    sete    [rbp-1]
L1:
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    movzx   edx,byte ptr [rbp-1]
    mov     [rbp-33h],dl
    mov     [rbp-0B0h],rax
    mov     rsi,[rbp+28h]
    mov     [rbp-0A8h],rsi
    call    fn0
    nop     [rcx-34h]
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp+28h]
    mov     [rbp-0A8h],rdx
    call    fn1
    nop     [rcx-34h]
    jmp     L18
    nop     [rax+rax]
L3:
    mov     rax,[rbp-10h]
    mov     [rbp-0B0h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-0A0h],rsi
    mov     rdi,[rbp+30h]
    mov     [rbp-98h],rdi
    call    fn2
    nop     [rcx-31h]
    jmp     L19
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFD8h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-20h],11Bh
    mov     rdx,[rbp-28h]
    mov     [rbp-68h],rdx
    mov     rsi,[rbp-20h]
    mov     [rbp-60h],rsi
    mov     [rbp-58h],rdx
    mov     [rbp-50h],rdx
    mov     edi,0FFFFFF80h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-78h],11Bh
    mov     rdx,[rbp-78h]
    mov     [rbp-70h],rdx
    shl     rdx,1
    mov     [rbp-68h],rdx
    or      rdx,1
    mov     [rbp-60h],rdx
    mov     [rbp-58h],rdx
    mov     rsi,[rbp-50h]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-0A0h],0
    mov     rdx,[rbp+38h]
    mov     [rbp-98h],rdx
    lea     rdi,[sym5]
    lea     rsi,[site6]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-28h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-33h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    cmp     rax,0
    sete    [rbp-35h]
    movzx   esi,byte ptr [rbp-35h]
    xor     sil,1
    mov     [rbp-32h],sil
    test    byte ptr [rbp-32h],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rbp-34h],0FFh
    je      L10
    jmp     L9
    nop     [rax]
L14:
    test    byte ptr [rbp-1],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rbp+18h]
    mov     [rbp-40h],rax
    cmp     rax,0
    sete    [rbp-35h]
    movzx   esi,byte ptr [rbp-35h]
    xor     sil,1
    mov     [rbp-33h],sil
    test    byte ptr [rbp-33h],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rbp-34h],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rbp-31h],0FFh
    je      L5
    jmp     L8
    nop     [rax]
L20:
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-80h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::swap_nonoverlapping_bytes
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     qword ptr [rbp-58h],8
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_DivUW64
    mov     qword ptr [rbp-58h],8
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA8h
    call    ryo_h_RemUW64
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFACh
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFACh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L1
    .long   L6
L1:
    mov     rax,[rbp-30h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-48h],rsi
    mov     [rbp-70h],rdx
    mov     [rbp-68h],rsi
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-8]
    jmp     L2
L2:
    mov     rax,[rbp-28h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFACh
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9d,1
    call    ryo_h_DiscrNicheW64
    mov     edi,0FFFFFFF0h
    mov     esi,0FFFFFFACh
    call    ryo_h_ZextW32W64
    mov     edi,0FFFFFFF0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L3:
    .long   L5
    .long   L4
    .long   L6
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-38h],rax
    imul    rdx,[rbp-20h],8
    mov     [rbp-40h],rdx
    mov     rsi,[rbp+10h]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+18h]
    imul    rcx,rdx,1
    add     rdi,rcx
    mov     [rbp-50h],rdi
    mov     [rbp-70h],rsi
    mov     [rbp-68h],rdi
    mov     [rbp-60h],rax
    call    fn1
    nop     [rcx-10h]
    jmp     L5
L5:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L6:
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+20h]
    mov     [rbp-30h],rax
    mov     qword ptr [rbp-10h],0
    mov     [rbp-8],rax
    nop
L0:
    mov     rax,[rbp-10h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-58h],rdx
    cmp     rax,rdx
    setb    [rbp-41h]
    test    byte ptr [rbp-41h],0FFh
    je      L3
    jmp     L2
    nop
L1:
    jmp     L0
L2:
    mov     rax,[rbp-10h]
    mov     [rbp-50h],rax
    mov     byte ptr [rbp-69h],1
    test    byte ptr [rbp-69h],0FFh
    je      L5
    jmp     L4
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L4:
    mov     rax,[rbp-50h]
    mov     [rbp-90h],rax
    mov     qword ptr [rbp-88h],1
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-28h]
L5:
    mov     rax,[rbp-50h]
    add     rax,1
    mov     [rbp-58h],rax
    mov     [rbp-10h],rax
    mov     rdx,[rbp-50h]
    mov     [rbp-38h],rdx
    mov     qword ptr [rbp-40h],1
    mov     [rbp-48h],rdx
    mov     rdi,[rbp+10h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rbp-58h],rdi
    mov     [rbp-50h],rdi
    mov     r8,[rbp+18h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rbp-68h],r8
    mov     [rbp-60h],r8
    mov     [rbp-90h],rdi
    mov     [rbp-88h],r8
    call    fn2
    nop     [rcx-18h]
    jmp     L1

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    mov     qword ptr [rbp-28h],0
    and     rax,4
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L0
    mov     rdi,[rbp-28h]
    mov     [rbp-48h],rdi
    mov     r8,[rbp+10h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rbp-40h],r8
    mov     [rbp-38h],r8
    mov     [rbp-30h],r8
    mov     r9,[rbp-28h]
    mov     [rbp-58h],r9
    mov     r10,[rbp+18h]
    imul    rcx,r9,1
    add     r10,rcx
    mov     [rbp-50h],r10
    mov     [rbp-48h],r10
    mov     [rbp-40h],r10
    mov     [rbp-70h],r8
    mov     [rbp-68h],r10
    call    fn0
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,4
    mov     [rbp-28h],rax
    jmp     L0
L0:
    mov     rax,[rbp-20h]
    and     rax,2
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L1
    mov     rsi,[rbp-28h]
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rdi
    mov     r8,[rbp-28h]
    mov     [rbp-58h],r8
    mov     r9,[rbp+18h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rbp-50h],r9
    mov     [rbp-48h],r9
    mov     [rbp-40h],r9
    mov     [rbp-70h],rdi
    mov     [rbp-68h],r9
    call    fn1
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,2
    mov     [rbp-28h],rax
    jmp     L1
L1:
    mov     rax,[rbp-20h]
    and     rax,1
    mov     [rbp-30h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rbp-28h]
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+10h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rbp-40h],rdi
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rdi
    mov     r8,[rbp-28h]
    mov     [rbp-58h],r8
    mov     r9,[rbp+18h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rbp-50h],r9
    mov     [rbp-48h],r9
    mov     [rbp-40h],r9
    mov     [rbp-70h],rdi
    mov     [rbp-68h],r9
    call    fn2
    nop     [rcx]
    mov     rax,[rbp-28h]
    or      rax,1
    mov     [rbp-28h],rax
    jmp     L2
L2:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    lea     rdx,[rbp-28h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rdx
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     edi,0FFFFFFA0h
    mov     esi,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rbp+18h]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-48h],rdx
    movzx   esi,byte ptr [rbp+28h]
    mov     [rbp-40h],sil
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-8]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn std::rt::lang_start::<()>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx-4]
    call    fn1
    nop     [rcx-5]
    movzx   eax,byte ptr [rbp-5]
    mov     [rbp-6],al
    mov     edi,0FFFFFFFCh
    mov     esi,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    mov     edi,0FFFFFFFCh
    mov     esi,4
    call    ryo_h_Ret
    leave
    ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    lea     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFD0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-10h]
    mov     [rbp-20h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFF8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-38h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    call    fn0
    nop     [rcx-2Ch]
    lea     rax,[rbp-2Ch]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-18h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-40h],rsi
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rsi
    call    fn1
    nop     [rcx-30h]
    lea     rax,[rbp-30h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rax
    call    fn2
    nop     [rcx-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret
    nop
L0:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::as_uninit_slice_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-40h],rax
    mov     [rbp-38h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-40h],rdx
    imul    rcx,rdx,8
    add     rax,rcx
    mov     [rbp-30h],rax
    mov     [rbp-28h],rax
    mov     qword ptr [rbp-50h],8
    cmp     qword ptr [rbp-50h],0
    je      L1
    jmp     L2
    nop     [rax+rax]
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-40h]
    sub     rdx,rax
    mov     [rbp-38h],rdx
    mov     byte ptr [rbp-49h],1
    test    byte ptr [rbp-49h],0FFh
    je      L4
    jmp     L3
L1:
    mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
    jmp     L0
L2:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rax
    jmp     L0
L3:
    mov     rax,[rbp-30h]
    mov     [rbp-40h],rax
    mov     [rbp-80h],rax
    mov     qword ptr [rbp-78h],8
    mov     qword ptr [rbp-70h],4
    mov     rdi,[rbp-38h]
    mov     [rbp-68h],rdi
    mov     edi,0FFFFFFA0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-20h]
L4:
    mov     rax,[rbp-30h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-40h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::with_capacity
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFB8h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx-38h]
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-8],0
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::slice::Iter::<'_, u32>::make_slice
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-18h],rax
    mov     [rbp-28h],rax
    mov     byte ptr [rbp-61h],0
    test    byte ptr [rbp-61h],0FFh
    je      L0
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi+8]
    mov     [rbp-30h],rdi
    mov     [rbp-20h],rdi
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-38h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-38h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-50h],rsi
    mov     byte ptr [rbp-61h],1
    test    byte ptr [rbp-61h],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    mov     byte ptr [rbp-61h],1
    test    byte ptr [rbp-61h],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop     [rax]
L2:
    jmp     L1
L3:
    mov     rax,[rbp-30h]
    mov     [rbp-58h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-60h],rdx
    mov     [rbp-90h],rax
    mov     [rbp-88h],rdx
    mov     edi,0FFFFFF80h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-20h]
L4:
    mov     qword ptr [rbp-68h],0
    cmp     qword ptr [rbp-68h],4
    setb    [rbp-51h]
    test    byte ptr [rbp-51h],0FFh
    je      L5
    mov     qword ptr [rbp-68h],4
    mov     r8,[rbp-68h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-52h]
    test    byte ptr [rbp-52h],0FFh
    je      L5
    mov     r10,[rbp-50h]
    sub     r10,[rbp-48h]
    mov     [rbp-20h],r10
    mov     qword ptr [rbp-68h],4
    mov     edi,0FFFFFFE0h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFF98h
    call    ryo_h_DivUW64
    jmp     L2
L5:
    mov     edi,0FFFFFF70h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-88h],49h
    mov     edi,0FFFFFF80h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[sym4]
    lea     rsi,[site5]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx-20h]
    jmp     L7
L6:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L7:
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rbp-18h]
    mov     [rbp-30h],rax
    mov     [rbp-90h],rax
    mov     qword ptr [rbp-88h],4
    mov     qword ptr [rbp-80h],4
    mov     rdi,[rbp-20h]
    mov     [rbp-78h],rdi
    mov     edi,0FFFFFF90h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-20h]
L9:
    mov     rax,[rbp-28h]
    mov     [rbp-38h],rax
    mov     rdx,[rbp-20h]
    mov     [rbp-30h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::slice::Iter::<'_, u32>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+18h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-40h],rsi
    mov     edi,0FFFFFFC8h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-40h],rax
    mov     [rbp-28h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L0
    mov     rdi,[rbp-20h]
    mov     [rbp-18h],rdi
    jmp     L1
L0:
    mov     rax,[rbp-28h]
    mov     [rbp-38h],rax
    imul    rcx,[rbp-20h],4
    add     rax,rcx
    mov     [rbp-30h],rax
    mov     [rbp-18h],rax
L1:
    mov     rax,[rbp-28h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::slice::from_raw_parts::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rbp+18h],0
    je      L9
    jmp     L10
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],117h
    mov     rdx,[rbp-10h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],117h
    mov     rdx,[rbp-60h]
    mov     [rbp-58h],rdx
    shl     rdx,1
    mov     [rbp-50h],rdx
    or      rdx,1
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-10h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L6:
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L3
    jmp     L0
    nop     [rax+rax]
L7:
    jmp     L3
L8:
    test    byte ptr [rbp-1Ah],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rbp-70h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rbp+28h]
    cmp     rax,[rbp-28h]
    setbe   [rbp-1Ah]
    test    byte ptr [rbp-1Ah],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L12:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-68h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::slice::from_raw_parts_mut::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    mov     [rbp-90h],rax
    mov     rdx,[rbp+20h]
    mov     [rbp-88h],rdx
    call    fn0
    nop     [rcx-1Ah]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rbp+18h],0
    je      L9
    jmp     L10
L1:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],11Bh
    mov     rdx,[rbp-10h]
    mov     [rbp-50h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     edi,0FFFFFF98h
    lea     rsi,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-60h],11Bh
    mov     rdx,[rbp-60h]
    mov     [rbp-58h],rdx
    shl     rdx,1
    mov     [rbp-50h],rdx
    or      rdx,1
    mov     [rbp-48h],rdx
    mov     [rbp-40h],rdx
    mov     rsi,[rbp-38h]
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+30h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym3]
    lea     rsi,[site4]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-10h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L6:
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    cmp     rax,0
    sete    [rbp-1Bh]
    movzx   esi,byte ptr [rbp-1Bh]
    xor     sil,1
    mov     [rbp-19h],sil
    test    byte ptr [rbp-19h],0FFh
    je      L3
    jmp     L0
    nop     [rax+rax]
L7:
    jmp     L3
L8:
    test    byte ptr [rbp-1Ah],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rbp-28h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rbp-70h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFF90h
    mov     edx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rbp+28h]
    cmp     rax,[rbp-28h]
    setbe   [rbp-1Ah]
    test    byte ptr [rbp-1Ah],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L12:
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx-68h]
    jmp     L14
L13:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::slice::stable_sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    lea     rax,[rbp+20h]
    mov     [rbp-10h],rax
    mov     byte ptr [rbp-1Ah],0
    test    byte ptr [rbp-1Ah],0FFh
    je      L3
    jmp     L2
    nop     [rax]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L1:
    mov     edi,0FFFFFFF8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L2:
    jmp     L0
L3:
    mov     rax,[rbp+18h]
    mov     [rbp-18h],rax
    cmp     rax,2
    setb    [rbp-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
L4:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    jmp     L2
L6:
    jmp     L5
L7:
    cmp     qword ptr [rbp-18h],14h
    setbe   [rbp-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L8
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-30h],1
    mov     rdx,[rbp-10h]
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx]
    jmp     L9
L8:
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     rax,[rbp-10h]
    mov     [rbp-30h],rax
    call    fn1
    nop     [rcx]
    jmp     L4
L9:
    jmp     L5
    mov     rdi,rax
    mov     esi,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L1

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    call    fn0
    nop     [rcx]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,100h
    mov     byte ptr [rbp-49h],1
    lea     rdx,[rbp+18h]
    mov     [rbp-68h],rdx
    mov     [rbp-100h],rdx
    call    fn0
    nop     [rcx-90h]
    mov     rax,[rbp-90h]
    mov     [rbp-68h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     rax,[rbp-78h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L2
    .long   L1
    .long   L8
L1:
    mov     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-100h],rdx
    mov     [rbp-0F8h],rax
    call    fn1
    nop     [rcx-48h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-90h],rax
    mov     [rbp-88h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+10h]
    mov     [rbp-0A0h],rdx
    mov     rdx,[rdx]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-0A0h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rdx
    mov     byte ptr [rbp-49h],0
    mov     edi,0FFFFFF58h
    mov     esi,18h
    call    ryo_h_MovW128
    mov     rax,[rbp-88h]
    mov     [rbp-0B0h],rax
    mov     edi,0FFFFFF40h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    mov     esi,0FFFFFF58h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF10h
    mov     esi,0FFFFFF40h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx-48h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L2:
    mov     edi,0FFFFFF68h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-90h],11h
    mov     rdx,[rbp-98h]
    mov     [rbp-0B8h],rdx
    mov     rsi,[rbp-90h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdx
    mov     edi,0FFFFFF30h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0C8h],11h
    mov     rdx,[rbp-0C8h]
    mov     [rbp-0C0h],rdx
    shl     rdx,1
    mov     [rbp-0B8h],rdx
    or      rdx,1
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-0A0h]
    mov     [rbp-88h],rsi
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFF00h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF10h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-48h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L4:
    call    ryo_h_Unreachable
    ud2
    xchg    ax,ax
L5:
    mov     edi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rbp-49h],0FFh
    je      L5
    jmp     L6
L8:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L7

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-18h],rdx
    imul    rcx,rdx,8
    add     rax,rcx
    mov     [rbp-8],rax
    mov     rcx,[rbp+18h]
    mov     [rax],rcx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    add     rsi,1
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+8],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::vec::Vec::<(u32, u32)>::reserve
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp-28h]
    mov     [rbp-50h],rax
    cmp     rax,0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rbp-20h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-88h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-80h],rsi
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-8]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    nop     [rax+rax]
    xchg    ax,ax
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L4:
    mov     rax,[rbp-48h]
    sub     rax,[rbp-18h]
    mov     [rbp-40h],rax
    cmp     rax,[rbp+18h]
    setb    [rbp-31h]
    test    byte ptr [rbp-31h],0FFh
    je      L3
    jmp     L0
L5:
    mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rbp-20h]
    mov     rax,[rax]
    mov     [rbp-58h],rax
    mov     [rbp-48h],rax
    jmp     L4

fn std::vec::Vec::<T, A>::set_len::precondition_check
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+18h]
    cmp     rax,[rbp+10h]
    jb      L0
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L0:
    mov     edi,0FFFFFFF0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-8],0C6h
    mov     rdx,[rbp-10h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp-8]
    mov     [rbp-40h],rsi
    mov     [rbp-38h],rdx
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0C6h
    mov     rdx,[rbp-58h]
    mov     [rbp-50h],rdx
    shl     rdx,1
    mov     [rbp-48h],rdx
    or      rdx,1
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rdx
    mov     rsi,[rbp-30h]
    mov     [rbp-28h],rsi
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFF70h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-80h],0
    mov     rdx,[rbp+20h]
    mov     [rbp-78h],rdx
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-10h]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    call    ryo_h_Unreachable
    ud2

fn std::vec::Vec::<u32>::append_elements
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+20h]
    mov     [rbp-8],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-80h],rdx
    mov     [rbp-78h],rax
    call    fn0
    nop     [rcx]
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-10h],rax
    mov     rcx,1FFFFFFFFFFFFFFFh
    cmp     rax,rcx
    setbe   [rbp-11h]
    cmp     qword ptr [rbp-8],0
    jbe     L0
    mov     rsi,[rbp+18h]
    mov     [rbp-20h],rsi
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi+8]
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rdi
    imul    rcx,rax,4
    add     rdi,rcx
    mov     [rbp-28h],rdi
    mov     byte ptr [rbp-39h],1
    test    byte ptr [rbp-39h],0FFh
    je      L2
    jmp     L1
    xchg    ax,ax
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-40h],rax
    add     rax,[rbp-8]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-50h]
    mov     [rdx+10h],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp+18h]
    mov     [rbp-30h],rax
    mov     rdx,[rbp-28h]
    mov     [rbp-38h],rdx
    mov     [rbp-80h],rax
    mov     [rbp-78h],rdx
    mov     qword ptr [rbp-70h],4
    mov     qword ptr [rbp-68h],4
    mov     r8,[rbp-8]
    mov     [rbp-60h],r8
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx-8]
L2:
    imul    rax,[rbp-8],4
    mov     [rbp-40h],rax
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    call    ryo_h_Memcpy
    jmp     L0

fn std::vec::Vec::<u32>::clear
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-20h],rax
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rdx
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     qword ptr [rbp-30h],0
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp-10h]
    mov     [rbp-20h],r8
    mov     r9,[rbp-8]
    mov     [rbp-18h],r9
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFD8h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::vec::Vec::<u32>::extend_from_slice
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+20h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-48h],rdx
    mov     rsi,[rbp+20h]
    mov     [rbp-40h],rsi
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     rax,[rbp-50h]
    mov     [rbp-40h],rax
    mov     [rbp-20h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L1:
    mov     rax,[rbp-18h]
    mov     [rbp-38h],rax
    jmp     L3
L2:
    mov     rax,[rbp-20h]
    mov     [rbp-30h],rax
    imul    rcx,[rbp-18h],4
    add     rax,rcx
    mov     [rbp-28h],rax
    mov     [rbp-38h],rax
L3:
    mov     rax,[rbp-20h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp-38h]
    mov     [rbp-8],rdx
    mov     rsi,[rbp+10h]
    mov     [rbp-70h],rsi
    mov     edi,0FFFFFF98h
    mov     esi,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx]
    jmp     L0

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,110h
    mov     byte ptr [rbp-49h],1
    lea     rdx,[rbp+18h]
    mov     [rbp-68h],rdx
    mov     [rbp-110h],rdx
    call    fn0
    nop     [rcx-90h]
    mov     rax,[rbp-90h]
    mov     [rbp-68h],rax
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     rax,[rbp-78h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L2
    .long   L1
    .long   L8
L1:
    mov     rax,[rbp-70h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-110h],rdx
    mov     [rbp-108h],rax
    call    fn1
    nop     [rcx-48h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-90h],rax
    mov     [rbp-88h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+10h]
    mov     [rbp-0A0h],rdx
    mov     rdx,[rdx]
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-0A0h]
    mov     [rbp-98h],rsi
    mov     [rbp-90h],rdx
    mov     byte ptr [rbp-49h],0
    mov     edi,0FFFFFF50h
    mov     esi,18h
    mov     edx,18h
    call    ryo_h_Copy
    mov     rax,[rbp-88h]
    mov     [rbp-0B8h],rax
    mov     edi,0FFFFFF38h
    mov     esi,0FFFFFF68h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF50h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFF08h
    mov     esi,0FFFFFF38h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx-48h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
L2:
    mov     edi,0FFFFFF68h
    lea     rsi,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-90h],11h
    mov     rdx,[rbp-98h]
    mov     [rbp-0B8h],rdx
    mov     rsi,[rbp-90h]
    mov     [rbp-0B0h],rsi
    mov     [rbp-0A8h],rdx
    mov     [rbp-0A0h],rdx
    mov     edi,0FFFFFF30h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-0C8h],11h
    mov     rdx,[rbp-0C8h]
    mov     [rbp-0C0h],rdx
    shl     rdx,1
    mov     [rbp-0B8h],rdx
    or      rdx,1
    mov     [rbp-0B0h],rdx
    mov     [rbp-0A8h],rdx
    mov     rsi,[rbp-0A0h]
    mov     [rbp-88h],rsi
    mov     [rbp-80h],rdx
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFF78h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF00h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[sym6]
    lea     rsi,[site7]
    mov     edx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-48h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L4:
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L5:
    mov     edi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rbp-49h],0FFh
    je      L5
    jmp     L6
L8:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L7

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-18h],rdx
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rbp-8],rax
    mov     ecx,[rbp+18h]
    mov     [rax],ecx
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    add     rsi,1
    mov     [rbp-30h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-30h]
    mov     [rdi+8],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::vec::Vec::<u32>::push
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     edx,[rbp+18h]
    mov     [rbp-18h],edx
    call    fn0
    nop     [rcx-8]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn std::vec::Vec::<u32>::push_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-30h],rax
    mov     qword ptr [rbp-50h],4
    cmp     qword ptr [rbp-50h],0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rbp+10h]
    mov     [rbp-40h],rax
    mov     [rbp-60h],rax
    call    fn0
    nop     [rcx-10h]
    jmp     L1
    nop     [rax+rax]
L1:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-40h],rax
    mov     [rbp-38h],rax
    imul    rcx,[rbp-30h],4
    add     rax,rcx
    mov     [rbp-18h],rax
    mov     edx,[rbp+18h]
    mov     [rbp-34h],edx
    mov     ecx,[rbp-34h]
    mov     [rax],ecx
    mov     rsi,[rbp-30h]
    add     rsi,1
    mov     [rbp-50h],rsi
    mov     rdi,[rbp+10h]
    mov     rcx,[rbp-50h]
    mov     [rdi+10h],rcx
    mov     r8,[rbp-18h]
    mov     [rbp-8],r8
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rbp-30h]
    cmp     rax,[rbp-40h]
    je      L0
    jmp     L1
L5:
    mov     qword ptr [rbp-40h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rax
    jmp     L4
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3

fn std::vec::Vec::<u32>::reserve
    push    rbp
    mov     rbp,rsp
    sub     rsp,90h
    mov     rax,[rbp+10h]
    mov     rax,[rax+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-20h],rdx
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    mov     rax,[rbp-28h]
    mov     [rbp-50h],rax
    cmp     rax,0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rbp-20h]
    mov     [rbp-90h],rax
    mov     rdx,[rbp-18h]
    mov     [rbp-88h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-80h],rsi
    mov     edi,0FFFFFF88h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx-8]
    jmp     L2
L1:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    nop     [rax+rax]
    xchg    ax,ax
L3:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L4:
    mov     rax,[rbp-48h]
    sub     rax,[rbp-18h]
    mov     [rbp-40h],rax
    cmp     rax,[rbp+18h]
    setb    [rbp-31h]
    test    byte ptr [rbp-31h],0FFh
    je      L3
    jmp     L0
L5:
    mov     qword ptr [rbp-48h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rbp-20h]
    mov     rax,[rax]
    mov     [rbp-58h],rax
    mov     [rbp-48h],rax
    jmp     L4

fn std::vec::Vec::<u32>::with_capacity
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFB8h
    lea     rsi,[k0]
    mov     edx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx-38h]
    mov     edi,0FFFFFFD8h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-8],0
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u32>>::eq
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-48h],rax
    mov     [rbp-40h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-20h],rdx
    mov     [rbp-18h],rax
    mov     [rbp-10h],rdx
    mov     rsi,[rbp+18h]
    mov     rsi,[rsi+8]
    mov     [rbp-48h],rsi
    mov     [rbp-40h],rsi
    mov     rdi,[rbp+18h]
    mov     rdi,[rdi+10h]
    mov     [rbp-38h],rdi
    mov     [rbp-30h],rsi
    mov     [rbp-28h],rdi
    mov     r8,[rbp-20h]
    cmp     r8,[rbp-38h]
    jne     L0
    mov     [rbp-58h],rax
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rax
    mov     [rbp-60h],rsi
    mov     [rbp-58h],rdi
    mov     [rbp-50h],rsi
    mov     [rbp-80h],rax
    mov     [rbp-78h],rsi
    mov     [rbp-70h],r8
    call    fn0
    nop     [rcx-1]
    jmp     L1
L0:
    mov     byte ptr [rbp-1],0
L1:
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

