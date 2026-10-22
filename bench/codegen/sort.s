fn <&std::vec::Vec<u32> as std::fmt::Debug>::fmt
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+1Fh]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <&u32 as std::fmt::Debug>::fmt
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+1Fh]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,38h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    call    fn0
    nop     [rcx+30h]
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <(u32, u32) as core::slice::sort::shared::smallsort::StableSmallSortTypeImpl>::small_sort_threshold
    sub     rsp,18h
    mov     qword ptr [rsp+8],20h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <(u32, u32) as core::slice::sort::stable::quicksort::IsFreeze>::is_freeze
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],1
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <(u32, u32) as std::fmt::Debug>::fmt
    sub     rsp,88h
    mov     rax,[rsp+98h]
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],0
    lea     rdi,[rsp+80h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+60h]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    lea     rdx,[rdx+4]
    mov     [rsp+50h],rdx
    lea     rsi,[rsp+60h]
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+58h]
    mov     [rsp+28h],rdi
    mov     [rsp+30h],rdi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+48h]
    jmp     L3
L2:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+20]
    call    qword ptr [sym7]
L3:
    lea     rax,[rsp+60h]
    mov     [rsp+40h],rax
    lea     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    lea     rsi,[sym9]
    lea     rdx,[site10]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+48h]
    jmp     L5
L4:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+20]
    call    qword ptr [sym11]
L5:
    lea     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+80h]
    lea     rsi,[sym12]
    lea     rdx,[site13]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+7Fh]
    jmp     L7
L6:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
L7:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn <[u32] as std::fmt::Debug>::fmt
    sub     rsp,0A8h
    mov     rax,[rsp+0C0h]
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+78h]
    jmp     L1
L0:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rax,[rsp+78h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+30h],rsi
    mov     rdi,[rsp+0B8h]
    mov     [rsp+38h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rsp+28h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L6
    jmp     L5
    nop     [rax+rax]
    nop
L2:
    mov     rax,[rsp+90h]
    mov     [rsp],rax
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+9Fh]
    jmp     L4
L3:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L4:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L5:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    jmp     L7
L6:
    mov     rax,[rsp+58h]
    imul    rcx,[rsp+60h],4
    add     rax,rcx
    mov     [rsp+40h],rax
L7:
    mov     rax,[rsp+58h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn6
    nop     [rcx+90h]
    jmp     L2

fn <alloc::raw_vec::RawVec<(u32, u32)> as std::ops::Drop>::drop
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+30h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+30h]
    jmp     L1
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <alloc::raw_vec::RawVec<u32> as std::ops::Drop>::drop
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+30h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+30h]
    jmp     L1
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)> as std::ops::Drop>::drop
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx+8]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+70h]
    mov     rsi,[rsi+10h]
    mov     [rsp+48h],rsi
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L0
    mov     [rsp+40h],rax
    mov     [rsp+38h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+60h]
L0:
    imul    rax,[rsp+48h],8
    mov     [rsp+30h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn <core::slice::sort::shared::smallsort::CopyOnDrop<u32> as std::ops::Drop>::drop
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx+8]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+70h]
    mov     rsi,[rsi+10h]
    mov     [rsp+48h],rsi
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L0
    mov     [rsp+40h],rax
    mov     [rsp+38h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+60h]
L0:
    imul    rax,[rsp+48h],4
    mov     [rsp+30h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFFD0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn <core::slice::sort::stable::merge::MergeState<(u32, u32)> as std::ops::Drop>::drop
    sub     rsp,88h
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx]
    mov     [rsp+78h],rdx
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    jmp     L1
L0:
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+70h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+10h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L7
    jmp     L6
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+70h]
L2:
    mov     qword ptr [rsp+38h],0
    cmp     qword ptr [rsp+38h],8
    setb    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L3
    mov     qword ptr [rsp+38h],8
    mov     r8,[rsp+38h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+4Eh]
    test    byte ptr [rsp+4Eh],0FFh
    je      L3
    mov     r10,[rsp+50h]
    sub     r10,[rsp+58h]
    mov     [rsp+68h],r10
    mov     qword ptr [rsp+38h],8
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFB8h
    call    ryo_h_DivUW64
    jmp     L0
L3:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+80h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+70h]
    jmp     L5
L4:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L5:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+70h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+68h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+70h]
L7:
    imul    rax,[rsp+68h],8
    mov     [rsp+38h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFB8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn <core::slice::sort::unstable::quicksort::GapGuardRaw<u32> as std::ops::Drop>::drop
    sub     rsp,78h
    mov     rax,[rsp+80h]
    mov     rax,[rax+8]
    mov     [rsp+68h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L0
    mov     r8,[rsp+68h]
    mov     [rsp+50h],r8
    mov     [rsp+48h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+68h]
L0:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFF0h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+70h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,8
    lea     rdi,[rsp]
    mov     esi,10h
    lea     rdx,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx]
    jmp     L1
L0:
    lea     rdi,[rsp]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    lea     rdi,[rsp]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,8
    ret

fn <for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt} as std::ops::FnMut<(&u32, &u32)>>::call_mut - shim(for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt})
    sub     rsp,38h
    mov     rax,[rsp+48h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+20h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+2Fh]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::alloc::Global as std::clone::Clone>::clone
    sub     rsp,8
    lea     rdi,[rsp]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,8
    ret

fn <std::array::IntoIter<usize, 2> as std::ops::Drop>::drop
    sub     rsp,38h
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L0
    mov     rsi,[rsp+40h]
    mov     [rsp+10h],rsi
    mov     [rsp],rsi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret
L1:
    jmp     L0

fn <std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)> as std::ops::Drop>::drop
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::hint::select_unpredictable::DropOnPanic<*const u32> as std::ops::Drop>::drop
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::hint::select_unpredictable::DropOnPanic<*mut u32> as std::ops::Drop>::drop
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate::<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    lea     rax,[rax+8]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+40h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+48h],rdi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+68h]
    mov     rax,[rsp+0A0h]
    mov     rax,[rax]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFF0h
    mov     ecx,0FFFFFF98h
    mov     r8d,0FFFFFF90h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+80h],0FFh
    je      L2
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+30h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+0A0h]
    mov     rcx,[rsp+78h]
    mov     [rax],rcx
    mov     rdx,[rsp+68h]
    mov     [rsp+88h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L3

fn <std::iter::Enumerate<std::slice::Iter<'_, u32>> as std::iter::Iterator>::fold::<u64, {closure@bench/sort.rs:46:37: 46:51}>
    sub     rsp,58h
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+70h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+18h],rdx
    call    fn0
    nop     [rcx+48h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::IntoIterator>::into_iter
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::collect::<std::vec::Vec<u32>>
    sub     rsp,0B8h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+98h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>
    sub     rsp,78h
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    mov     edx,18h
    call    ryo_h_MovW128
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    mov     edx,28h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+38h]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFD0h
    mov     ecx,20h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+70h]
    lea     rdi,[rsp+70h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>
    sub     rsp,58h
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,28h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+50h]
    lea     rdi,[rsp+50h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}> as std::iter::Iterator>::size_hint
    sub     rsp,38h
    mov     rax,[rsp+40h]
    lea     rax,[rax+8]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::IntoIterator>::into_iter
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::collect::<std::vec::Vec<(u32, u32)>>
    sub     rsp,0A8h
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+88h]
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,0A8h
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::fold::<(), {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>
    sub     rsp,58h
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    mov     edx,20h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD8h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+50h]
    lea     rdi,[rsp+50h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::for_each::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>
    sub     rsp,48h
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    mov     edx,20h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+40h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}> as std::iter::Iterator>::size_hint
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::ops::Range<usize> as std::iter::IntoIterator>::into_iter
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <std::ops::Range<usize> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,68h
    mov     byte ptr [rsp+57h],1
    nop     [rax]
L0:
    lea     rax,[rsp+70h]
    mov     [rsp+30h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+38h]
    mov     rax,[rsp+38h]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L1:
    .long   L3
    .long   L2
    .long   L8
L2:
    mov     rax,[rsp+40h]
    lea     rdx,[rsp+80h]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+57h],0
    mov     [rsp+20h],rax
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn1
    nop     [rcx+58h]
    mov     byte ptr [rsp+57h],1
    jmp     L0
L3:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn2
    nop     [rcx+18h]
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rax,[rsp+80h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn3
    nop     [rcx+18h]
    nop     [rax]
L5:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+57h],0FFh
    je      L4
    jmp     L6
L8:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L9:
    lea     rdi,[rsp+60h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L10
    call    rax
    nop     [rcx+20h]
    jmp     L11
L10:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L11:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L7
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L5
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9

fn <std::ops::Range<usize> as std::iter::Iterator>::map::<u32, {closure@bench/sort.rs:52:37: 52:40}>
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::ops::Range<usize> as std::iter::range::RangeIteratorImpl>::spec_next
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+50h]
    lea     rdx,[rdx+8]
    mov     [rsp+18h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+2Fh]
    test    byte ptr [rsp+2Fh],0FFh
    je      L0
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx]
    mov     [rsp+20h],rdx
    mov     [rsp],rdx
    mov     qword ptr [rsp+8],1
    call    fn1
    nop     [rcx+18h]
    mov     rax,[rsp+50h]
    mov     rcx,[rsp+18h]
    mov     [rax],rcx
    mov     rdx,[rsp+20h]
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+30h],1
    jmp     L1
L0:
    mov     qword ptr [rsp+30h],0
L1:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <std::ops::Range<usize> as std::slice::SliceIndex<[T]>>::get_unchecked_mut::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+0A0h]
    jb      L0
    mov     rdx,[rsp+0B0h]
    cmp     rdx,rax
    jb      L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0DAh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0DAh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index
    sub     rsp,0A8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+80h],rdx
    cmp     rax,rdx
    jb      L4
    jmp     L5
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    imul    rcx,[rsp+80h],4
    add     rax,rcx
    mov     rsi,[rsp+68h]
    mov     [rsp+90h],rax
    mov     [rsp+98h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+0B8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    mov     rdi,[rsp+0D0h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+80h]
    jmp     L3
L2:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L4:
    jmp     L1
L5:
    mov     rax,[rsp+88h]
    sub     rax,[rsp+80h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rax
    mov     rsi,[rsp+0B8h]
    mov     [rsp+58h],rsi
    cmp     rsi,[rsp+88h]
    jae     L0
    jmp     L1

fn <std::ops::Range<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,0A8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+80h],rdx
    cmp     rax,rdx
    jb      L4
    jmp     L5
    nop     [rax+rax]
    xchg    ax,ax
L0:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    imul    rcx,[rsp+80h],4
    add     rax,rcx
    mov     rsi,[rsp+68h]
    mov     [rsp+90h],rax
    mov     [rsp+98h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+0B8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    mov     rdi,[rsp+0D0h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+80h]
    jmp     L3
L2:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L3:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L4:
    jmp     L1
L5:
    mov     rax,[rsp+88h]
    sub     rax,[rsp+80h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rax
    mov     rsi,[rsp+0B8h]
    mov     [rsp+58h],rsi
    cmp     rsi,[rsp+88h]
    jae     L0
    jmp     L1

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index
    sub     rsp,88h
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+60h],rdx
    cmp     rdx,rax
    jae     L2
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+80h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+60h]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+60h]
    sub     rax,[rsp+68h]
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+98h]
    imul    rcx,[rsp+68h],4
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn <std::ops::RangeFrom<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,88h
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+60h],rdx
    cmp     rdx,rax
    jae     L2
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+80h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+60h]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+60h]
    sub     rax,[rsp+68h]
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+98h]
    imul    rcx,[rsp+68h],4
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn <std::ops::RangeTo<usize> as std::slice::SliceIndex<[u32]>>::index_mut
    sub     rsp,58h
    mov     rax,[rsp+70h]
    mov     qword ptr [rsp+30h],0
    mov     [rsp+38h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+20h],rax
    call    fn0
    nop     [rcx+40h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::slice::Iter<'_, u32> as std::iter::IntoIterator>::into_iter
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::enumerate
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+18h],0
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<(), {closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}>
    sub     rsp,0A8h
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rsi,[rsp+0B8h]
    cmp     rsi,0
    sete    [rsp+67h]
    jmp     L1
L0:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B0h]
    cmp     rdx,rax
    sete    [rsp+67h]
L1:
    test    byte ptr [rsp+67h],0FFh
    je      L2
    mov     byte ptr [rsp+76h],0
    lea     rsi,[rsp+0C0h]
    mov     [rsp+20h],rsi
    mov     [rsp],rsi
    call    fn0
    nop     [rcx+20h]
    jmp     L7
L2:
    mov     byte ptr [rsp+76h],0
    mov     byte ptr [rsp+77h],1
    mov     qword ptr [rsp+88h],0
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L3
    mov     r9,[rsp+0B8h]
    mov     [rsp+80h],r9
    jmp     L4
L3:
    mov     rax,[rsp+0B8h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rax
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rax,[rsp+0C0h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+77h],0
    mov     rsi,[rsp+0B0h]
    mov     rdi,[rsp+88h]
    imul    rcx,rdi,4
    add     rsi,rcx
    mov     [rsp+58h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rsi
    call    fn1
    nop     [rcx+80h]
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
L5:
    lea     rax,[rsp+0C0h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn2
    nop     [rcx+20h]
    jmp     L7
    nop
L6:
    jmp     L4
L7:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
    xchg    ax,ax
L8:
    lea     rax,[rsp+0C0h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn3
    nop     [rcx+20h]
    jmp     L13
    nop
L9:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L10:
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    test    byte ptr [rsp+77h],0FFh
    je      L8
    jmp     L10
    nop     [rax]
L12:
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    test    byte ptr [rsp+76h],0FFh
    je      L9
    jmp     L12
    nop     [rax]
L14:
    jmp     L4
L15:
    mov     rax,[rsp+60h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+76h]
L16:
    mov     qword ptr [rsp+20h],0
    cmp     qword ptr [rsp+20h],4
    setb    [rsp+3Fh]
    test    byte ptr [rsp+3Fh],0FFh
    je      L17
    mov     qword ptr [rsp+20h],4
    mov     r8,[rsp+20h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+3Eh]
    test    byte ptr [rsp+3Eh],0FFh
    je      L17
    mov     r10,[rsp+40h]
    sub     r10,[rsp+48h]
    mov     [rsp+80h],r10
    mov     qword ptr [rsp+20h],4
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L14
L17:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx+76h]
    jmp     L19
L18:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym10]
L19:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L20:
    mov     rax,[rsp+88h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+76h]
L21:
    mov     rax,[rsp+88h]
    add     rax,1
    mov     [rsp+88h],rax
    mov     [rsp+58h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+50h],rdx
    cmp     rax,rdx
    je      L5
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L22:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym13]
    lea     rdx,[site14]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L23
    call    rax
    nop     [rcx+28h]
    jmp     L24
L23:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym15]
L24:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L13
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L22

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::fold::<u64, {closure@<std::iter::Enumerate<I> as std::iter::Iterator>::fold::enumerate<&u32, u64, {closure@bench/sort.rs:46:37: 46:51}>::{closure#0}}>
    sub     rsp,0C8h
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L0
    mov     rsi,[rsp+0D8h]
    cmp     rsi,0
    sete    [rsp+7Fh]
    jmp     L1
L0:
    mov     rax,[rsp+0D8h]
    mov     rdx,[rsp+0D0h]
    cmp     rdx,rax
    sete    [rsp+7Fh]
L1:
    test    byte ptr [rsp+7Fh],0FFh
    je      L2
    mov     byte ptr [rsp+8Eh],0
    mov     rsi,[rsp+0E0h]
    mov     [rsp+0B8h],rsi
    jmp     L7
L2:
    mov     byte ptr [rsp+8Eh],0
    mov     byte ptr [rsp+8Fh],1
    mov     rsi,[rsp+0E0h]
    mov     [rsp+78h],rsi
    mov     qword ptr [rsp+0A0h],0
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L3
    mov     r10,[rsp+0D8h]
    mov     [rsp+98h],r10
    jmp     L4
L3:
    mov     rax,[rsp+0D8h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+68h],rdx
    mov     [rsp+60h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+50h],rsi
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L16
    jmp     L15
    nop     [rax]
L4:
    lea     rax,[rsp+0E8h]
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+8Fh],0
    mov     rsi,[rsp+78h]
    mov     rdi,[rsp+0D0h]
    mov     r8,[rsp+0A0h]
    imul    rcx,r8,4
    add     rdi,rcx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp],rax
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn0
    nop     [rcx+70h]
    mov     rax,[rsp+70h]
    mov     [rsp+78h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax]
L5:
    mov     rax,[rsp+78h]
    mov     [rsp+0B8h],rax
    jmp     L7
    nop
L6:
    jmp     L4
L7:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    nop     [rax]
L8:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L10:
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    test    byte ptr [rsp+8Fh],0FFh
    je      L8
    jmp     L10
    nop     [rax]
L12:
    jmp     L9
L13:
    test    byte ptr [rsp+8Eh],0FFh
    je      L9
    jmp     L12
    xchg    ax,ax
L14:
    jmp     L4
L15:
    mov     rax,[rsp+70h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+8Eh]
L16:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],4
    setb    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L17
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+4Eh]
    test    byte ptr [rsp+4Eh],0FFh
    je      L17
    mov     r10,[rsp+50h]
    sub     r10,[rsp+58h]
    mov     [rsp+98h],r10
    mov     qword ptr [rsp+18h],4
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFF58h
    call    ryo_h_DivUW64
    jmp     L14
L17:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx+8Eh]
    jmp     L19
L18:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L19:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
L20:
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    call    fn9
    nop     [rcx+8Eh]
L21:
    mov     rax,[rsp+0A0h]
    add     rax,1
    mov     [rsp+0A0h],rax
    mov     [rsp+68h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+60h],rdx
    cmp     rax,rdx
    je      L5
    jmp     L6
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L11

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::map::<(u32, u32), {closure@bench/sort.rs:59:50: 59:54}>
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::next
    sub     rsp,88h
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+8]
    mov     [rsp+40h],rdx
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L1
    mov     [rsp+38h],rdx
    cmp     rdx,0
    jne     L0
    mov     qword ptr [rsp+78h],0
    jmp     L4
L0:
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    mov     [rsp+50h],rdx
    cmp     rdx,rax
    sete    [rsp+3Fh]
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     qword ptr [rsp+78h],0
    jmp     L4
L2:
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+20h],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+90h]
    mov     rcx,[rsp+38h]
    mov     [rsi],rcx
    nop     [rax+rax]
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+78h],rax
    jmp     L4
L4:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,88h
    ret
L5:
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+58h]
L6:
    mov     rax,[rsp+38h]
    sub     rax,1
    mov     [rsp+70h],rax
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+70h]
    mov     [rdx+8],rcx
    jmp     L3

fn <std::slice::Iter<'_, u32> as std::iter::Iterator>::size_hint
    sub     rsp,88h
    mov     byte ptr [rsp+27h],0
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rsi,[rsp+90h]
    mov     rsi,[rsi+8]
    mov     [rsp+60h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx]
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rax
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+38h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+50h],rdx
    mov     qword ptr [rsp+48h],1
    mov     [rsp+68h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,88h
    ret
    nop     [rax+rax]
L2:
    jmp     L1
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+28h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+60h]
L4:
    mov     qword ptr [rsp+20h],0
    cmp     qword ptr [rsp+20h],4
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L5
    mov     qword ptr [rsp+20h],4
    mov     r8,[rsp+20h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+36h]
    test    byte ptr [rsp+36h],0FFh
    je      L5
    mov     r10,[rsp+38h]
    sub     r10,[rsp+40h]
    mov     [rsp+60h],r10
    mov     qword ptr [rsp+20h],4
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_DivUW64
    jmp     L2
L5:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+80h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+60h]
    jmp     L7
L6:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L7:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn <std::vec::Vec<(u32, u32)> as std::iter::FromIterator<(u32, u32)>>::from_iter::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    sub     rsp,48h
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx+28h]
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::DerefMut>::deref_mut
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Drop>::drop
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <std::vec::Vec<(u32, u32)> as std::ops::Index<usize>>::index
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx+10h]
    mov     [rsp+48h],rax
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rsp+80h]
    mov     [rsp+18h],rax
    call    fn0
    nop     [rcx+58h]
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_extend::SpecExtend<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::spec_extend
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter::SpecFromIter<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    sub     rsp,38h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::vec::Vec<(u32, u32)> as std::vec::spec_from_iter_nested::SpecFromIterNested<(u32, u32), std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>>::from_iter
    sub     rsp,0E8h
    mov     byte ptr [rsp+0BFh],1
    lea     rdx,[rsp+0F0h]
    mov     [rsp+78h],rdx
    mov     [rsp],rdx
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+88h]
    mov     [rsp+0C0h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L1
    .long   L4
    .long   L11
L1:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],11h
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],11h
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+0C0h]
    jmp     L3
L2:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L3:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rsp+90h]
    mov     [rsp+78h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF28h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn8
    nop     [rcx+58h]
    jmp     L10
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,0E8h
    ret
    nop     [rax+rax]
L6:
    lea     rax,[rsp+98h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn9
    nop     [rcx+20h]
    jmp     L9
    nop
L7:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L8:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rsp+0BFh],0FFh
    je      L7
    jmp     L8
L10:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+0A8h],0
    lea     rdx,[rsp+98h]
    mov     [rsp+90h],rdx
    mov     byte ptr [rsp+0BFh],0
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFA0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+90h]
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn10
    nop     [rcx+0C0h]
    jmp     L5
L11:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L12:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym11]
    lea     rdx,[site12]
    mov     ecx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+28h]
    jmp     L14
L13:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym13]
L14:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L12
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::vec::Vec<u32> as std::clone::Clone>::clone
    sub     rsp,68h
    mov     rax,[rsp+70h]
    lea     rax,[rax+10h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+48h]
    mov     rax,[rsp+70h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+70h]
    mov     rdx,[rdx+10h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx+48h]
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn <std::vec::Vec<u32> as std::fmt::Debug>::fmt
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx+10h]
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rsp+68h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+4Fh]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::vec::Vec<u32> as std::iter::FromIterator<u32>>::from_iter::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    sub     rsp,58h
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn1
    nop     [rcx+38h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <std::vec::Vec<u32> as std::ops::Deref>::deref
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::vec::Vec<u32> as std::ops::DerefMut>::deref_mut
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::vec::Vec<u32> as std::ops::Drop>::drop
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<&u32, std::slice::Iter<'_, u32>>>::spec_extend
    sub     rsp,48h
    lea     rax,[rsp+58h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+30h]
    jmp     L1
L0:
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret
L1:
    mov     rax,[rsp+30h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx+40h]
    jmp     L0

fn <std::vec::Vec<u32> as std::vec::spec_extend::SpecExtend<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::spec_extend
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter::SpecFromIter<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    sub     rsp,38h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <std::vec::Vec<u32> as std::vec::spec_from_iter_nested::SpecFromIterNested<u32, std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>>::from_iter
    sub     rsp,0E8h
    mov     byte ptr [rsp+0BFh],1
    lea     rdx,[rsp+0F0h]
    mov     [rsp+78h],rdx
    mov     [rsp],rdx
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+88h]
    mov     [rsp+0C0h],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L0:
    .long   L1
    .long   L4
    .long   L11
L1:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],11h
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],11h
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+0C0h]
    jmp     L3
L2:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L3:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rsp+90h]
    mov     [rsp+78h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF28h
    lea     rdx,[k7]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn8
    nop     [rcx+58h]
    jmp     L10
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFB8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,0E8h
    ret
    nop     [rax+rax]
L6:
    lea     rax,[rsp+98h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn9
    nop     [rcx+20h]
    jmp     L9
    nop
L7:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L8:
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rsp+0BFh],0FFh
    je      L7
    jmp     L8
L10:
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF88h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+0A8h],0
    lea     rdx,[rsp+98h]
    mov     [rsp+90h],rdx
    mov     byte ptr [rsp+0BFh],0
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF98h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+90h]
    mov     [rsp],rax
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF28h
    mov     edx,0FFFFFF98h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn10
    nop     [rcx+0C0h]
    jmp     L5
L11:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym11]
    lea     rdx,[site12]
    mov     ecx,0FFFFFF40h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+28h]
    jmp     L14
L13:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym13]
L14:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L12
    lea     rdi,[rsp+0E0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     rax,[rax+8]
    mov     [rsp],rax
    mov     rdx,[rsp+20h]
    mov     rdx,[rdx]
    mov     rcx,[rsp]
    mov     [rdx],rcx
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <u32 as core::slice::cmp::SlicePartialEq<u32>>::equal_same_length
    sub     rsp,28h
    imul    rax,[rsp+40h],4
    mov     [rsp+10h],rax
    mov     rdx,[rsp+30h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp],rsi
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    cmp     dword ptr [rsp+18h],0
    sete    [rsp+1Fh]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,48h
    mov     qword ptr [rsp+28h],4
    cmp     qword ptr [rsp+28h],8
    setbe   [rsp+3Fh]
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    mov     qword ptr [rsp+28h],4
    imul    r8,[rsp+28h],20h
    mov     [rsp+30h],r8
    cmp     r8,1000h
    ja      L0
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+40h]
    jmp     L2
L0:
    mov     qword ptr [rsp+28h],4
    imul    rdx,[rsp+28h],30h
    mov     [rsp+30h],rdx
    cmp     rdx,1000h
    ja      L1
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+40h]
    jmp     L2
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    cmp     rax,2
    jae     L3
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    call    fn2
    nop     [rcx+40h]
    jmp     L4
L4:
    jmp     L2

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortFreezeTypeImpl>::small_sort_threshold
    sub     rsp,28h
    mov     qword ptr [rsp],4
    cmp     qword ptr [rsp],8
    setbe   [rsp+17h]
    test    byte ptr [rsp+17h],0FFh
    je      L0
    mov     qword ptr [rsp],4
    imul    r8,[rsp],20h
    mov     [rsp+8],r8
    cmp     r8,1000h
    ja      L0
    mov     qword ptr [rsp+18h],20h
    jmp     L2
L0:
    mov     qword ptr [rsp],4
    imul    rdx,[rsp],30h
    mov     [rsp+8],rdx
    cmp     rdx,1000h
    ja      L1
    mov     qword ptr [rsp+18h],20h
    jmp     L2
L1:
    mov     qword ptr [rsp+18h],10h
L2:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort::<for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn <u32 as core::slice::sort::shared::smallsort::UnstableSmallSortTypeImpl>::small_sort_threshold
    sub     rsp,18h
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn <u32 as std::slice::<impl [T]>::to_vec_in::ConvertVec>::to_vec::<std::alloc::Global>
    sub     rsp,0C8h
    mov     rax,[rsp+0D8h]
    mov     [rsp+68h],rax
    mov     [rsp],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx+48h]
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+0D0h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+90h],rdx
    mov     [rsp+58h],rax
    mov     rsi,[rsp+0B0h]
    mov     [rsp+80h],rsi
    mov     [rsp+50h],rsi
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L1:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
L2:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF88h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFF98h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+0B8h],0
    cmp     qword ptr [rsp+68h],0
    ja      L0
    jmp     L1
L3:
    mov     rax,[rsp+88h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+68h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+80h]
L4:
    imul    rax,[rsp+68h],4
    mov     [rsp+38h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF78h
    call    ryo_h_Memcpy
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L5
    mov     qword ptr [rsp+38h],4
    cmp     qword ptr [rsp+38h],0
    je      L7
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     rax,[rsp+68h]
    mov     [rsp+0B8h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+80h]
    jmp     L5
L7:
    mov     qword ptr [rsp+58h],0FFFFFFFFFFFFFFFFh
    jmp     L6
L8:
    mov     rax,[rsp+0A8h]
    mov     [rsp+58h],rax
    jmp     L6

fn <usize as std::cmp::Ord>::max
    sub     rsp,48h
    mov     byte ptr [rsp+37h],1
    lea     rdx,[rsp+58h]
    mov     [rsp+18h],rdx
    lea     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn0
    nop     [rcx+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     byte ptr [rsp+37h],0
    mov     rsi,[rsp+50h]
    mov     [rsp+38h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
L1:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,48h
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rsp+37h],0FFh
    je      L3
    jmp     L4
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::cmp::Ord>::min
    sub     rsp,48h
    mov     byte ptr [rsp+37h],1
    lea     rdx,[rsp+58h]
    mov     [rsp+18h],rdx
    lea     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn0
    nop     [rcx+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rdx,[rsp+58h]
    mov     [rsp+38h],rdx
    jmp     L1
L0:
    mov     byte ptr [rsp+37h],0
    mov     rdx,[rsp+50h]
    mov     [rsp+38h],rdx
L1:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,48h
    ret
    nop     [rax]
L2:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    jmp     L3
L5:
    test    byte ptr [rsp+37h],0FFh
    je      L3
    jmp     L4
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn <usize as std::iter::Step>::forward_unchecked
    sub     rsp,38h
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rsi,[rsp+40h]
    mov     [rsp],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+8],rdi
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+28h]
L0:
    mov     rax,[rsp+40h]
    add     rax,[rsp+48h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn <usize as std::iter::Step>::steps_between
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+68h]
    mov     rdx,[rdx]
    mov     [rsp+28h],rdx
    cmp     rdx,rax
    jb      L0
    sub     rdx,rax
    mov     [rsp+18h],rdx
    mov     [rsp+10h],rdx
    mov     qword ptr [rsp+8],1
    mov     rdi,[rsp+18h]
    mov     [rsp+38h],rdi
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFB8h
    call    ryo_h_MovW128
    jmp     L1
L0:
    mov     qword ptr [rsp+38h],0
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
L1:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn <usize as std::slice::SliceIndex<[(u32, u32)]>>::index
    sub     rsp,48h
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    cmp     rdx,rax
    jb      L2
    mov     [rsp],rdx
    mov     [rsp+8],rax
    mov     rsi,[rsp+68h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+40h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFE0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+2Fh]
    jmp     L1
L0:
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+50h]
    imul    rcx,[rsp+60h],8
    add     rax,rcx
    mov     [rsp+38h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn <usize as std::slice::SliceIndex<[T]>>::get_unchecked::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    cmp     rax,[rsp+0A8h]
    jae     L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0D6h
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0D6h
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    sub     rsp,28h
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+1Ch]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,4
    call    ryo_h_Ret
    add     rsp,28h
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp],rax
    call    fn0
    nop     [rcx+0Ch]
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFFCh
    mov     edx,4
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn Rng::next
    sub     rsp,78h
    mov     rax,[rsp+80h]
    mov     rax,[rax]
    mov     [rsp+58h],rax
    mov     dword ptr [rsp+1Ch],0Dh
    mov     esi,[rsp+1Ch]
    mov     [rsp+54h],esi
    cmp     esi,40h
    jb      L2
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+70h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+23h]
    jmp     L1
L0:
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+58h]
    shl     rax,0Dh
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+80h]
    mov     rcx,[rsp+10h]
    mov     [rsi],rcx
    mov     rdi,[rsp+80h]
    mov     rdi,[rdi]
    mov     [rsp+40h],rdi
    mov     dword ptr [rsp+1Ch],7
    mov     r9d,[rsp+1Ch]
    mov     [rsp+3Ch],r9d
    cmp     r9d,40h
    jb      L5
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+70h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+23h]
    jmp     L4
L3:
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L4:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rsp+40h]
    shr     rax,7
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+80h]
    mov     rcx,[rsp+10h]
    mov     [rsi],rcx
    mov     rdi,[rsp+80h]
    mov     rdi,[rdi]
    mov     [rsp+28h],rdi
    mov     dword ptr [rsp+1Ch],11h
    mov     r9d,[rsp+1Ch]
    mov     [rsp+24h],r9d
    cmp     r9d,40h
    jb      L8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+70h]
    lea     rsi,[sym9]
    lea     rdx,[site10]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+23h]
    jmp     L7
L6:
    lea     rdi,[rsp+70h]
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L7:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rsp+28h]
    shl     rax,11h
    mov     rdx,[rsp+80h]
    mov     rdx,[rdx]
    xor     rdx,rax
    mov     [rsp+10h],rdx
    mov     rsi,[rsp+80h]
    mov     rcx,[rsp+10h]
    mov     [rsi],rcx
    mov     rdi,[rsp+80h]
    mov     rdi,[rdi]
    mov     [rsp+68h],rdi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn alloc::raw_vec::RawVec::<u32>::grow_one
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     [rsp+58h],rax
    mov     rax,[rax]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+60h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+48h]
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFCCh
    mov     edx,0FFFFFFE8h
    mov     rcx,0FFFFFFFFFFFFFFFFh
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFCCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L6
    .long   L3
    .long   L7
L3:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+60h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+60h]
    jmp     L5
L4:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+20]
    call    qword ptr [sym6]
L5:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2
L6:
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret
L7:
    lea     rdi,[rsp+60h]
    call    ryo_h_Unreachable
    ud2

fn alloc::raw_vec::RawVecInner::with_capacity_in
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     byte ptr [rsp+8],0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    mov     edx,18h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+50h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    mov     rax,[rsp+50h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L2:
    .long   L7
    .long   L4
    .long   L3
L3:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L4:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+70h]
    jmp     L6
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym5]
L6:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rsp+0B0h]
    mov     [rsp+30h],rax
    cmp     rax,0
    je      L9
    jmp     L10
    nop     [rax+rax]
    nop     [rax+rax]
L8:
    mov     rax,[rsp+38h]
    sub     rax,0
    cmp     rax,[rsp+0A0h]
    setb    [rsp+4Eh]
    movzx   edx,byte ptr [rsp+4Eh]
    xor     dl,1
    mov     [rsp+4Fh],dl
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L12
    jmp     L11
L9:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    jmp     L8
L10:
    mov     rax,[rsp+80h]
    mov     [rsp+38h],rax
    jmp     L8
L11:
    movzx   eax,byte ptr [rsp+4Fh]
    mov     [rsp],al
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    call    fn7
    nop     [rcx+68h]
L12:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn checksum
    sub     rsp,58h
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx+30h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFE0h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     qword ptr [rsp+18h],0
    call    fn2
    nop     [rcx+48h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn checksum::{closure#0}
    sub     rsp,58h
    mov     rax,[rsp+70h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+78h]
    mov     edx,[rdx]
    mov     [rsp+3Ch],edx
    mov     rsi,[rsp+68h]
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],1Fh
    call    fn0
    nop     [rcx+30h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFECh
    call    ryo_h_ZextW32W64
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+20h]
    xor     rdx,rax
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+30h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+48h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn core::fmt::num::<impl std::fmt::Debug for u32>::fmt
    sub     rsp,38h
    mov     rax,[rsp+48h]
    mov     eax,[rax+10h]
    and     eax,2000000h
    cmp     eax,0
    setne   [rsp+2Eh]
    test    byte ptr [rsp+2Eh],0FFh
    je      L2
    mov     rdi,[rsp+40h]
    mov     [rsp],rdi
    mov     r8,[rsp+48h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+30h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+2Fh]
    jmp     L1
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    jmp     L7
L2:
    mov     rax,[rsp+48h]
    mov     eax,[rax+10h]
    and     eax,4000000h
    cmp     eax,0
    setne   [rsp+2Dh]
    test    byte ptr [rsp+2Dh],0FFh
    je      L5
    mov     rdi,[rsp+40h]
    mov     [rsp],rdi
    mov     r8,[rsp+48h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+30h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+2Fh]
    jmp     L4
L3:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    jmp     L7
L5:
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+30h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+2Fh]
    jmp     L7
L6:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L7:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn core::fmt::rt::Argument::<'_>::new_debug::<(u32, u32)>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::fmt::rt::Argument::<'_>::new_lower_hex::<u64>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+18h],rdx
    mov     [rsp+20h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::num::<impl u64>::wrapping_add
    sub     rsp,18h
    mov     rax,[rsp+20h]
    add     rax,[rsp+28h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn core::num::<impl u64>::wrapping_mul
    sub     rsp,18h
    mov     rax,[rsp+20h]
    imul    rax,[rsp+28h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFD0h
    mov     r8d,0FFFFFFC8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+70h]
    mov     [rsp+7Fh],al
    test    byte ptr [rsp+7Fh],0FFh
    je      L2
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0BAh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0BAh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+80h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::num::<impl usize>::unchecked_sub::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFD0h
    mov     r8d,0FFFFFFC8h
    call    ryo_h_SubOvfUW64
    movzx   eax,byte ptr [rsp+70h]
    mov     [rsp+7Fh],al
    test    byte ptr [rsp+7Fh],0FFh
    je      L2
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0BAh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0BAh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+80h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::panicking::assert_failed::<std::vec::Vec<u32>, std::vec::Vec<u32>>
    sub     rsp,88h
    lea     rax,[rsp+90h]
    mov     [rsp+68h],rax
    mov     [rsp+70h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+98h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    movzx   eax,byte ptr [rsp+0B0h]
    mov     [rsp+30h],al
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0B8h]
    mov     [rsp+38h],rax
    lea     rdi,[rsp+80h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFFC8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+80h]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [(u32, u32)]>::reverse
    sub     rsp,0A8h
    mov     rax,[rsp+0B8h]
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+30h],2
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF90h
    call    ryo_h_DivUW64
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+60h],rdx
    mov     [rsp+70h],rax
    imul    rcx,[rsp+98h],8
    add     rax,rcx
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+50h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+58h]
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+50h]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     byte ptr [rsp+37h],0
    test    byte ptr [rsp+37h],0FFh
    je      L5
    jmp     L4
L3:
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L7
    jmp     L6
L4:
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    jmp     L3
L5:
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+30h],0
    mov     rsi,[rsp+30h]
    sub     rsi,rax
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+48h],rdi
    jmp     L3
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+50h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+58h]
L7:
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    call    fn4
    nop     [rcx+78h]
    jmp     L0

fn core::slice::<impl [(u32, u32)]>::split_at_mut
    sub     rsp,0C8h
    mov     rax,[rsp+0D8h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+0E0h]
    jb      L0
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+58h]
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
L0:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],9
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],9
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+0A0h]
    jmp     L2
L1:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L2:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [(u32, u32)]>::split_at_mut_unchecked
    sub     rsp,0B8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+0C8h]
    mov     [rsp+88h],rsi
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L0
    mov     r9,[rsp+0D0h]
    mov     [rsp],r9
    mov     [rsp+8],rax
    mov     r10,[rsp+0D8h]
    mov     [rsp+10h],r10
    call    fn0
    nop     [rcx+90h]
L0:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L1
    mov     rsi,[rsp+80h]
    mov     [rsp+58h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     r9,[rsp+0D0h]
    mov     [rsp+18h],r9
    mov     r10,[rsp+0D8h]
    mov     [rsp+20h],r10
    call    fn1
    nop     [rcx+80h]
L1:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+0D0h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+70h]
    imul    rcx,[rsp+0D0h],8
    add     rsi,rcx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+78h]
    sub     rdi,[rsp+0D0h]
    mov     [rsp+40h],rdi
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L2
    mov     [rsp+38h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0D8h]
    mov     [rsp+20h],r8
    call    fn2
    nop     [rcx+80h]
L2:
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::<impl [T]>::reverse::revswap::<(u32, u32)>
    sub     rsp,0B8h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+50h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+40h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+58h],0
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+0E0h]
    jae     L7
    mov     rdx,[rsp+58h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+0A0h],rsi
    cmp     rdx,rsi
    jb      L3
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+38h]
    jmp     L2
L1:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L2:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+70h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0E0h]
    sub     rdx,1
    mov     rsi,[rsp+58h]
    sub     rdx,rsi
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+68h]
    mov     [rsp+88h],rdi
    cmp     rdx,rdi
    jb      L6
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym9]
    lea     rdx,[site10]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+38h]
    jmp     L5
L4:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L5:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+60h]
    imul    rcx,[rsp+48h],8
    add     rax,rcx
    mov     rdx,[rsp+0A8h]
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF90h
    xor     ecx,ecx
    mov     r8d,8
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF88h
    mov     ecx,0FFFFFF78h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    xor     edx,edx
    mov     ecx,0FFFFFF80h
    mov     r8d,8
    call    ryo_h_StoreCopy
    jmp     L8
L7:
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
L8:
    mov     rax,[rsp+58h]
    add     rax,1
    mov     [rsp+58h],rax
    jmp     L0

fn core::slice::<impl [T]>::reverse::revswap::<u32>
    sub     rsp,0B8h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+50h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+40h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+58h],0
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+0E0h]
    jae     L7
    mov     rdx,[rsp+58h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+0A0h],rsi
    cmp     rdx,rsi
    jb      L3
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+38h]
    jmp     L2
L1:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L2:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+70h]
    imul    rcx,[rsp+50h],4
    add     rax,rcx
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0E0h]
    sub     rdx,1
    mov     rsi,[rsp+58h]
    sub     rdx,rsi
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+68h]
    mov     [rsp+88h],rdi
    cmp     rdx,rdi
    jb      L6
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k8]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym9]
    lea     rdx,[site10]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+38h]
    jmp     L5
L4:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym11]
L5:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+60h]
    imul    rcx,[rsp+48h],4
    add     rax,rcx
    mov     rdx,[rsp+0A8h]
    mov     [rsp+40h],rdx
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+28h],4
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF90h
    xor     ecx,ecx
    mov     r8d,4
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF88h
    mov     ecx,0FFFFFF78h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF88h
    xor     edx,edx
    mov     ecx,0FFFFFF80h
    mov     r8d,4
    call    ryo_h_StoreCopy
    jmp     L8
L7:
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
L8:
    mov     rax,[rsp+58h]
    add     rax,1
    mov     [rsp+58h],rax
    jmp     L0

fn core::slice::<impl [T]>::split_at_mut_unchecked::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+0A0h]
    jb      L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0DDh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0DDh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [T]>::swap_unchecked::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+0A0h]
    jae     L0
    mov     rdx,[rsp+0B0h]
    cmp     rdx,[rsp+0A0h]
    jae     L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0DAh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0DAh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [u32]>::copy_from_slice
    sub     rsp,38h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp+20h],rax
    call    fn0
    nop     [rcx+30h]
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn core::slice::<impl [u32]>::iter
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+10h]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn core::slice::<impl [u32]>::reverse
    sub     rsp,0A8h
    mov     rax,[rsp+0B8h]
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+30h],2
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF90h
    call    ryo_h_DivUW64
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+60h],rdx
    mov     [rsp+70h],rax
    imul    rcx,[rsp+98h],4
    add     rax,rcx
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+50h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+58h]
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+50h]
    mov     [rsp+88h],rax
    mov     [rsp+90h],rdx
    mov     byte ptr [rsp+37h],0
    test    byte ptr [rsp+37h],0FFh
    je      L5
    jmp     L4
L3:
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L7
    jmp     L6
L4:
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    jmp     L3
L5:
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+30h],0
    mov     rsi,[rsp+30h]
    sub     rsi,rax
    mov     rdi,[rsp+68h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+48h],rdi
    jmp     L3
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+50h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+58h]
L7:
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+50h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    call    fn4
    nop     [rcx+78h]
    jmp     L0

fn core::slice::<impl [u32]>::sort_unstable
    sub     rsp,28h
    lea     rax,[rsp+20h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn core::slice::<impl [u32]>::split_at_mut
    sub     rsp,0C8h
    mov     rax,[rsp+0D8h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+0E0h]
    jb      L0
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+58h]
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF98h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC0h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
L0:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+68h],9
    mov     rdx,[rsp+60h]
    mov     rsi,[rsp+68h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],9
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+70h],rsi
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+0A0h]
    jmp     L2
L1:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L2:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::<impl [u32]>::split_at_mut_unchecked
    sub     rsp,0B8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0C0h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+0C8h]
    mov     [rsp+88h],rsi
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L0
    mov     r9,[rsp+0D0h]
    mov     [rsp],r9
    mov     [rsp+8],rax
    mov     r10,[rsp+0D8h]
    mov     [rsp+10h],r10
    call    fn0
    nop     [rcx+90h]
L0:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L1
    mov     rsi,[rsp+80h]
    mov     [rsp+58h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     r9,[rsp+0D0h]
    mov     [rsp+18h],r9
    mov     r10,[rsp+0D8h]
    mov     [rsp+20h],r10
    call    fn1
    nop     [rcx+80h]
L1:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+0D0h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+70h]
    imul    rcx,[rsp+0D0h],4
    add     rsi,rcx
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+78h]
    sub     rdi,[rsp+0D0h]
    mov     [rsp+40h],rdi
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L2
    mov     [rsp+38h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0D8h]
    mov     [rsp+20h],r8
    call    fn2
    nop     [rcx+80h]
L2:
    mov     rax,[rsp+48h]
    mov     rdx,[rsp+40h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,20h
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::<impl [u32]>::swap
    sub     rsp,48h
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+60h]
    cmp     rdx,rax
    jb      L2
    mov     [rsp],rdx
    mov     [rsp+8],rax
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+40h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+36h]
    jmp     L1
L0:
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+68h]
    cmp     rax,[rsp+38h]
    jb      L5
    mov     [rsp],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+40h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+36h]
    jmp     L4
L3:
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L5:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+60h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+20h],rsi
    call    fn6
    nop     [rcx+36h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::<impl [u32]>::swap_unchecked
    sub     rsp,48h
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rsi,[rsp+58h]
    mov     [rsp+38h],rsi
    mov     [rsp],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+8],rdi
    mov     r8,[rsp+68h]
    mov     [rsp+10h],r8
    mov     r9,[rsp+70h]
    mov     [rsp+18h],r9
    call    fn0
    nop     [rcx+40h]
L0:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+38h],rax
    imul    rcx,[rsp+60h],4
    add     rax,rcx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+38h]
    imul    rcx,[rsp+68h],4
    add     rsi,rcx
    mov     [rsp+28h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rsi
    call    fn1
    nop     [rcx+40h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::copy_from_slice_impl::<u32>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+80h],rdx
    cmp     rax,rdx
    je      L2
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+80h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+0B0h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+78h],rdx
    mov     [rsp+58h],rax
    mov     rsi,[rsp+0A0h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+68h],rdi
    mov     [rsp+50h],rsi
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L3
    mov     r10,[rsp+70h]
    mov     [rsp+48h],r10
    mov     r11,[rsp+60h]
    mov     [rsp+40h],r11
    mov     [rsp],r10
    mov     [rsp+8],r11
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+88h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+60h]
L3:
    imul    rax,[rsp+88h],4
    mov     [rsp+38h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::index::<impl std::ops::Index<std::ops::Range<usize>> for [u32]>::index
    sub     rsp,48h
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,20h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+70h]
    mov     [rsp+20h],rax
    call    fn0
    nop     [rcx+30h]
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::index::<impl std::ops::Index<std::ops::RangeFrom<usize>> for [u32]>::index
    sub     rsp,38h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeFrom<usize>> for [u32]>::index_mut
    sub     rsp,38h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn core::slice::index::<impl std::ops::IndexMut<std::ops::RangeTo<usize>> for [u32]>::index_mut
    sub     rsp,38h
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+58h]
    mov     [rsp+18h],rax
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn core::slice::sort::shared::find_existing_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,88h
    mov     rax,[rsp+98h]
    mov     [rsp+60h],rax
    cmp     rax,2
    jae     L0
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+78h],0
    jmp     L10
L0:
    mov     qword ptr [rsp+68h],2
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L1:
    test    byte ptr [rsp+5Fh],0FFh
    je      L6
    nop     [rax+rax]
L2:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+60h]
    jae     L5
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L15
    jmp     L14
L3:
    test    byte ptr [rsp+5Dh],0FFh
    je      L4
    mov     rdx,[rsp+68h]
    add     rdx,1
    mov     [rsp+68h],rdx
    jmp     L2
L4:
    jmp     L5
L5:
    jmp     L9
    nop     [rax+rax]
L6:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+60h]
    jae     L9
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L18
    jmp     L17
L7:
    test    byte ptr [rsp+5Dh],0FFh
    je      L8
    jmp     L9
L8:
    mov     rax,[rsp+68h]
    add     rax,1
    mov     [rsp+68h],rax
    jmp     L6
L9:
    mov     rax,[rsp+68h]
    mov     [rsp+70h],rax
    movzx   edx,byte ptr [rsp+5Fh]
    mov     [rsp+78h],dl
L10:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,88h
    ret
L11:
    mov     qword ptr [rsp],1
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+68h]
L12:
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+20h]
    cmp     rdx,[rsp+60h]
    setb    [rsp+5Eh]
    mov     rsi,[rsp+90h]
    lea     rsi,[rsi+8]
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L13
    mov     qword ptr [rsp],0
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+68h]
L13:
    mov     qword ptr [rsp+20h],0
    mov     rdx,[rsp+20h]
    cmp     rdx,[rsp+60h]
    setb    [rsp+5Eh]
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+40h]
    mov     [rsp+48h],rdi
    mov     [rsp+50h],rsi
    mov     r8,[rsp+0A0h]
    mov     [rsp],r8
    mov     [rsp+8],rdi
    mov     [rsp+10h],rsi
    call    fn4
    nop     [rcx+5Fh]
    jmp     L1
L14:
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+68h]
L15:
    mov     rax,[rsp+38h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+68h]
    sub     rsi,1
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L16
    mov     [rsp],rsi
    mov     r9,[rsp+60h]
    mov     [rsp+8],r9
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+68h]
L16:
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     rsi,[rsp+40h]
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A0h]
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    call    fn9
    nop     [rcx+5Dh]
    jmp     L3
L17:
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx+68h]
L18:
    mov     rax,[rsp+38h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+68h]
    sub     rsi,1
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L19
    mov     [rsp],rsi
    mov     r9,[rsp+60h]
    mov     [rsp+8],r9
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    call    fn13
    nop     [rcx+68h]
L19:
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     rsi,[rsp+40h]
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A0h]
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    call    fn14
    nop     [rcx+5Dh]
    jmp     L7

fn core::slice::sort::shared::find_existing_run::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     rax,[rsp+98h]
    mov     [rsp+60h],rax
    cmp     rax,2
    jae     L0
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+78h],0
    jmp     L10
L0:
    mov     qword ptr [rsp+68h],2
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L12
    jmp     L11
    nop     [rax+rax]
L1:
    test    byte ptr [rsp+5Fh],0FFh
    je      L6
    nop     [rax+rax]
L2:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+60h]
    jae     L5
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L15
    jmp     L14
L3:
    test    byte ptr [rsp+5Dh],0FFh
    je      L4
    mov     rdx,[rsp+68h]
    add     rdx,1
    mov     [rsp+68h],rdx
    jmp     L2
L4:
    jmp     L5
L5:
    jmp     L9
    nop     [rax+rax]
L6:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    cmp     rax,[rsp+60h]
    jae     L9
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L18
    jmp     L17
L7:
    test    byte ptr [rsp+5Dh],0FFh
    je      L8
    jmp     L9
L8:
    mov     rax,[rsp+68h]
    add     rax,1
    mov     [rsp+68h],rax
    jmp     L6
L9:
    mov     rax,[rsp+68h]
    mov     [rsp+70h],rax
    movzx   edx,byte ptr [rsp+5Fh]
    mov     [rsp+78h],dl
L10:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,88h
    ret
L11:
    mov     qword ptr [rsp],1
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+68h]
L12:
    mov     qword ptr [rsp+20h],1
    mov     rdx,[rsp+20h]
    cmp     rdx,[rsp+60h]
    setb    [rsp+5Eh]
    mov     rsi,[rsp+90h]
    lea     rsi,[rsi+4]
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L13
    mov     qword ptr [rsp],0
    mov     r10,[rsp+60h]
    mov     [rsp+8],r10
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+68h]
L13:
    mov     qword ptr [rsp+20h],0
    mov     rdx,[rsp+20h]
    cmp     rdx,[rsp+60h]
    setb    [rsp+5Eh]
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+40h]
    mov     [rsp+48h],rdi
    mov     [rsp+50h],rsi
    mov     r8,[rsp+0A0h]
    mov     [rsp],r8
    mov     [rsp+8],rdi
    mov     [rsp+10h],rsi
    call    fn4
    nop     [rcx+5Fh]
    jmp     L1
L14:
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+68h]
L15:
    mov     rax,[rsp+38h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+68h]
    sub     rsi,1
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L16
    mov     [rsp],rsi
    mov     r9,[rsp+60h]
    mov     [rsp+8],r9
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+68h]
L16:
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+40h]
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A0h]
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    call    fn9
    nop     [rcx+5Dh]
    jmp     L3
L17:
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx+68h]
L18:
    mov     rax,[rsp+38h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+68h]
    sub     rsi,1
    mov     [rsp+30h],rsi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L19
    mov     [rsp],rsi
    mov     r9,[rsp+60h]
    mov     [rsp+8],r9
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    call    fn13
    nop     [rcx+68h]
L19:
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+60h]
    setb    [rsp+5Ch]
    mov     rdx,[rsp+90h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+40h]
    mov     [rsp+48h],rsi
    mov     [rsp+50h],rdx
    mov     rdi,[rsp+0A0h]
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdx
    call    fn14
    nop     [rcx+5Dh]
    jmp     L7

fn core::slice::sort::shared::pivot::choose_pivot::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0B8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+88h],rax
    cmp     rax,8
    jae     L0
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rsp+0C0h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+30h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    imul    rax,[rsp+80h],4
    mov     rdx,[rsp+0A0h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+78h],rdx
    imul    rsi,[rsp+80h],7
    mov     rdi,[rsp+0A0h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+70h],rdi
    cmp     qword ptr [rsp+88h],40h
    jae     L1
    mov     r9,[rsp+0A0h]
    mov     [rsp+58h],r9
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rdi
    mov     [rsp],r9
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    mov     r10,[rsp+0D0h]
    mov     [rsp+18h],r10
    call    fn0
    nop     [rcx+60h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L5
    jmp     L4
L1:
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp+20h],r8
    call    fn1
    nop     [rcx+60h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L2:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+88h]
    setb    [rsp+87h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L16
    jmp     L15
    nop     [rax]
L3:
    jmp     L2
L4:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+38h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+90h]
L5:
    mov     qword ptr [rsp+30h],0
    cmp     qword ptr [rsp+30h],8
    setb    [rsp+6Eh]
    test    byte ptr [rsp+6Eh],0FFh
    je      L6
    mov     qword ptr [rsp+30h],8
    mov     r8,[rsp+30h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+6Dh]
    test    byte ptr [rsp+6Dh],0FFh
    je      L6
    mov     r10,[rsp+60h]
    sub     r10,[rsp+0A0h]
    mov     [rsp+0A8h],r10
    mov     qword ptr [rsp+30h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L3
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx+90h]
    jmp     L8
L7:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L8:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L9:
    jmp     L2
L10:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx+90h]
L11:
    mov     qword ptr [rsp+30h],0
    cmp     qword ptr [rsp+30h],8
    setb    [rsp+6Eh]
    test    byte ptr [rsp+6Eh],0FFh
    je      L12
    mov     qword ptr [rsp+30h],8
    mov     r8,[rsp+30h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+6Dh]
    test    byte ptr [rsp+6Dh],0FFh
    je      L12
    mov     r10,[rsp+60h]
    sub     r10,[rsp+0A0h]
    mov     [rsp+0A8h],r10
    mov     qword ptr [rsp+30h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L9
L12:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym13]
    lea     rdx,[site14]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+90h]
    jmp     L14
L13:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym15]
L14:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L15:
    movzx   eax,byte ptr [rsp+87h]
    mov     [rsp],al
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx+90h]
L16:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::sort::shared::pivot::choose_pivot::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0B8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+88h],rax
    cmp     rax,8
    jae     L0
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rsp+0C0h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+30h],8
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    imul    rax,[rsp+80h],4
    mov     rdx,[rsp+0A0h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+78h],rdx
    imul    rsi,[rsp+80h],7
    mov     rdi,[rsp+0A0h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+70h],rdi
    cmp     qword ptr [rsp+88h],40h
    jae     L1
    mov     r9,[rsp+0A0h]
    mov     [rsp+58h],r9
    mov     [rsp+50h],rdx
    mov     [rsp+48h],rdi
    mov     [rsp],r9
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    mov     r10,[rsp+0D0h]
    mov     [rsp+18h],r10
    call    fn0
    nop     [rcx+60h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L5
    jmp     L4
L1:
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp+20h],r8
    call    fn1
    nop     [rcx+60h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L2:
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+88h]
    setb    [rsp+87h]
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L16
    jmp     L15
    nop     [rax]
L3:
    jmp     L2
L4:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+38h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+90h]
L5:
    mov     qword ptr [rsp+30h],0
    cmp     qword ptr [rsp+30h],4
    setb    [rsp+6Eh]
    test    byte ptr [rsp+6Eh],0FFh
    je      L6
    mov     qword ptr [rsp+30h],4
    mov     r8,[rsp+30h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+6Dh]
    test    byte ptr [rsp+6Dh],0FFh
    je      L6
    mov     r10,[rsp+60h]
    sub     r10,[rsp+0A0h]
    mov     [rsp+0A8h],r10
    mov     qword ptr [rsp+30h],4
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L3
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx+90h]
    jmp     L8
L7:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L8:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L9:
    jmp     L2
L10:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx+90h]
L11:
    mov     qword ptr [rsp+30h],0
    cmp     qword ptr [rsp+30h],4
    setb    [rsp+6Eh]
    test    byte ptr [rsp+6Eh],0FFh
    je      L12
    mov     qword ptr [rsp+30h],4
    mov     r8,[rsp+30h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+6Dh]
    test    byte ptr [rsp+6Dh],0FFh
    je      L12
    mov     r10,[rsp+60h]
    sub     r10,[rsp+0A0h]
    mov     [rsp+0A8h],r10
    mov     qword ptr [rsp+30h],4
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFF8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_DivUW64
    jmp     L9
L12:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k12]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym13]
    lea     rdx,[site14]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+90h]
    jmp     L14
L13:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym15]
L14:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L15:
    movzx   eax,byte ptr [rsp+87h]
    mov     [rsp],al
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx+90h]
L16:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::sort::shared::pivot::median3::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+37h]
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn1
    nop     [rcx+36h]
    movzx   eax,byte ptr [rsp+37h]
    cmp     al,[rsp+36h]
    jne     L2
    mov     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+68h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn2
    nop     [rcx+34h]
    movzx   eax,byte ptr [rsp+34h]
    xor     al,[rsp+37h]
    mov     [rsp+33h],al
    test    byte ptr [rsp+33h],0FFh
    je      L0
    mov     rsi,[rsp+60h]
    mov     [rsp+38h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
L1:
    jmp     L3
L2:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::shared::pivot::median3::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+37h]
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn1
    nop     [rcx+36h]
    movzx   eax,byte ptr [rsp+37h]
    cmp     al,[rsp+36h]
    jne     L2
    mov     rdx,[rsp+58h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+68h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn2
    nop     [rcx+34h]
    movzx   eax,byte ptr [rsp+34h]
    xor     al,[rsp+37h]
    mov     [rsp+33h],al
    test    byte ptr [rsp+33h],0FFh
    je      L0
    mov     rsi,[rsp+60h]
    mov     [rsp+38h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
L1:
    jmp     L3
L2:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
L3:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::shared::pivot::median3_rec::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,78h
    imul    rax,[rsp+98h],8
    mov     [rsp+48h],rax
    cmp     rax,40h
    jb      L0
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    mov     edx,28h
    mov     ecx,0FFFFFFB8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+80h]
    imul    rsi,[rsp+48h],4
    mov     [rsp+60h],rsi
    imul    rcx,rsi,8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    imul    rdi,[rsp+48h],7
    mov     [rsp+58h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+30h],r8
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],r8
    mov     r9,[rsp+48h]
    mov     [rsp+18h],r9
    mov     r10,[rsp+0A0h]
    mov     [rsp+20h],r10
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+88h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+60h],8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+88h]
    imul    rcx,[rsp+58h],8
    add     rsi,rcx
    mov     [rsp+30h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+20h],r8
    call    fn1
    nop     [rcx+88h]
    mov     rax,[rsp+90h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+90h]
    imul    rcx,[rsp+60h],8
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+90h]
    imul    rcx,[rsp+58h],8
    add     rsi,rcx
    mov     [rsp+30h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+20h],r8
    call    fn2
    nop     [rcx+90h]
    jmp     L0
L0:
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+18h],rdi
    call    fn3
    nop     [rcx+68h]
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn core::slice::sort::shared::pivot::median3_rec::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,78h
    imul    rax,[rsp+98h],8
    mov     [rsp+48h],rax
    cmp     rax,40h
    jb      L0
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    mov     edx,28h
    mov     ecx,0FFFFFFB8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+80h]
    imul    rsi,[rsp+48h],4
    mov     [rsp+60h],rsi
    imul    rcx,rsi,4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    imul    rdi,[rsp+48h],7
    mov     [rsp+58h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rsp+30h],r8
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],r8
    mov     r9,[rsp+48h]
    mov     [rsp+18h],r9
    mov     r10,[rsp+0A0h]
    mov     [rsp+20h],r10
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+88h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+60h],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+88h]
    imul    rcx,[rsp+58h],4
    add     rsi,rcx
    mov     [rsp+30h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+20h],r8
    call    fn1
    nop     [rcx+88h]
    mov     rax,[rsp+90h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+90h]
    imul    rcx,[rsp+60h],4
    add     rdx,rcx
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+90h]
    imul    rcx,[rsp+58h],4
    add     rsi,rcx
    mov     [rsp+30h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+48h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+20h],r8
    call    fn2
    nop     [rcx+90h]
    jmp     L0
L0:
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+40h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0A0h]
    mov     [rsp+18h],rdi
    call    fn3
    nop     [rcx+68h]
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn core::slice::sort::shared::smallsort::bidirectional_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0E8h
    mov     rax,[rsp+0F8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    mov     [rsp+70h],rdx
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_DivUW64
    cmp     qword ptr [rsp+68h],0
    setne   [rsp+67h]
    mov     rdx,[rsp+70h]
    mov     [rsp+0B8h],rdx
    mov     rsi,[rsp+70h]
    imul    rcx,[rsp+68h],8
    add     rsi,rcx
    mov     [rsp+0B0h],rsi
    mov     rdi,[rsp+68h]
    sub     rdi,1
    mov     r8,[rsp+70h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+0A8h],r8
    mov     r9,[rsp+78h]
    sub     r9,1
    mov     [rsp+0D8h],r9
    mov     r10,[rsp+70h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+0A0h],r10
    mov     r11,[rsp+100h]
    imul    rcx,r9,8
    add     r11,rcx
    mov     [rsp+98h],r11
    mov     qword ptr [rsp+0C8h],0
    mov     rdi,[rsp+68h]
    mov     [rsp+0D0h],rdi
    xchg    ax,ax
L0:
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0D0h]
    cmp     rax,rdx
    setb    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L1:
    mov     rax,[rsp+50h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+100h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+8],r8
    mov     r9,[rsp+98h]
    mov     [rsp+10h],r9
    mov     r10,[rsp+108h]
    mov     [rsp+18h],r10
    call    fn0
    nop     [rcx+50h]
    mov     rax,[rsp+50h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+98h],rsi
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+60h]
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L4
    mov     rsi,[rsp+0B8h]
    mov     [rsp+90h],rsi
    jmp     L5
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+90h],rax
L5:
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L18
    jmp     L17
L6:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+60h]
    je      L7
    jmp     L8
L7:
    mov     rax,[rsp+0B0h]
    cmp     rax,[rsp+58h]
    je      L11
L8:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx+90h]
    jmp     L10
L9:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L10:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L11:
    lea     rdi,[rsp+0E0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0E8h
    ret
L12:
    mov     rax,[rsp+0C8h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L15
    jmp     L14
L13:
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L16
L14:
    mov     rax,[rsp+58h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+80h]
L15:
    mov     rax,[rsp+58h]
    add     rax,1
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+100h]
    mov     [rsp+10h],rdi
    mov     r8,[rsp+108h]
    mov     [rsp+18h],r8
    call    fn6
    nop     [rcx+50h]
    jmp     L1
L16:
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0A0h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    je      L3
    jmp     L2
L17:
    mov     rax,[rsp+90h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+100h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+80h]
L18:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,20h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF50h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF76h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B8h]
    imul    rcx,[rsp+40h],8
    add     rax,rcx
    mov     [rsp+0B8h],rax
    movzx   edx,byte ptr [rsp+56h]
    xor     dl,1
    mov     [rsp+55h],dl
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF75h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B0h]
    imul    rcx,[rsp+40h],8
    add     rax,rcx
    mov     [rsp+0B0h],rax
    jmp     L6

fn core::slice::sort::shared::smallsort::bidirectional_merge::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0E8h
    mov     rax,[rsp+0F8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0F0h]
    mov     rsi,[rsp+0F8h]
    mov     [rsp+70h],rdx
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_DivUW64
    cmp     qword ptr [rsp+68h],0
    setne   [rsp+67h]
    mov     rdx,[rsp+70h]
    mov     [rsp+0B8h],rdx
    mov     rsi,[rsp+70h]
    imul    rcx,[rsp+68h],4
    add     rsi,rcx
    mov     [rsp+0B0h],rsi
    mov     rdi,[rsp+68h]
    sub     rdi,1
    mov     r8,[rsp+70h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rsp+0A8h],r8
    mov     r9,[rsp+78h]
    sub     r9,1
    mov     [rsp+0D8h],r9
    mov     r10,[rsp+70h]
    imul    rcx,r9,4
    add     r10,rcx
    mov     [rsp+0A0h],r10
    mov     r11,[rsp+100h]
    imul    rcx,r9,4
    add     r11,rcx
    mov     [rsp+98h],r11
    mov     qword ptr [rsp+0C8h],0
    mov     rdi,[rsp+68h]
    mov     [rsp+0D0h],rdi
    xchg    ax,ax
L0:
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0D0h]
    cmp     rax,rdx
    setb    [rsp+67h]
    test    byte ptr [rsp+67h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
L1:
    mov     rax,[rsp+50h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+100h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp],rdi
    mov     r8,[rsp+0A0h]
    mov     [rsp+8],r8
    mov     r9,[rsp+98h]
    mov     [rsp+10h],r9
    mov     r10,[rsp+108h]
    mov     [rsp+18h],r10
    call    fn0
    nop     [rcx+50h]
    mov     rax,[rsp+50h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+98h],rsi
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+60h]
    setb    [rsp+56h]
    test    byte ptr [rsp+56h],0FFh
    je      L4
    mov     rsi,[rsp+0B8h]
    mov     [rsp+90h],rsi
    jmp     L5
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+90h],rax
L5:
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L18
    jmp     L17
L6:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+60h]
    je      L7
    jmp     L8
L7:
    mov     rax,[rsp+0B0h]
    cmp     rax,[rsp+58h]
    je      L11
L8:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx+90h]
    jmp     L10
L9:
    lea     rdi,[rsp+0E0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L10:
    lea     rdi,[rsp+0E0h]
    call    ryo_h_Unreachable
    ud2
L11:
    lea     rdi,[rsp+0E0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0E8h
    ret
L12:
    mov     rax,[rsp+0C8h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L15
    jmp     L14
L13:
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L16
L14:
    mov     rax,[rsp+58h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+80h]
L15:
    mov     rax,[rsp+58h]
    add     rax,1
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0B0h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+100h]
    mov     [rsp+10h],rdi
    mov     r8,[rsp+108h]
    mov     [rsp+18h],r8
    call    fn6
    nop     [rcx+50h]
    jmp     L1
L16:
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0A0h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF98h
    mov     ecx,0FFFFFF58h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+57h]
    test    byte ptr [rsp+57h],0FFh
    je      L3
    jmp     L2
L17:
    mov     rax,[rsp+90h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+100h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+80h]
L18:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0E0h]
    mov     esi,20h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF50h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF76h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B8h]
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+0B8h],rax
    movzx   edx,byte ptr [rsp+56h]
    xor     dl,1
    mov     [rsp+55h],dl
    lea     rdi,[rsp+0E0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF75h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B0h]
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+0B0h],rax
    jmp     L6

fn core::slice::sort::shared::smallsort::insert_tail::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0B8h
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L0:
    test    byte ptr [rsp+87h],0FFh
    je      L1
    mov     rdx,[rsp+0C8h]
    mov     rdx,[rdx]
    mov     [rsp+80h],rdx
    lea     rsi,[rsp+80h]
    mov     [rsp+68h],rsi
    mov     rdi,[rsp+0C8h]
    mov     [rsp+70h],rdi
    mov     qword ptr [rsp+78h],1
    jmp     L2
L1:
    jmp     L7
    nop     [rax+rax]
L2:
    mov     rax,[rsp+0A8h]
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    xchg    ax,ax
L5:
    test    byte ptr [rsp+67h],0FFh
    je      L6
    jmp     L2
L6:
    lea     rax,[rsp+68h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+38h]
L7:
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
    nop     [rax]
L8:
    lea     rax,[rsp+68h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+38h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L9:
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn2
    nop     [rcx+87h]
    jmp     L0
L10:
    mov     rax,[rsp+0C8h]
    mov     [rsp+0A8h],rax
    jmp     L9
L11:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    jmp     L9
L12:
    mov     rax,[rsp+98h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+90h]
L13:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+58h],rdx
    cmp     rdx,[rsp+0C0h]
    je      L3
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L14:
    mov     rax,[rsp+60h]
    mov     [rsp+0A8h],rax
    lea     rdx,[rsp+80h]
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rax
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rax
    call    fn5
    nop     [rcx+67h]
    jmp     L5
L15:
    mov     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    jmp     L14
L16:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L14
    nop     [rax+rax]
    nop
L17:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx+40h]
    jmp     L19
L18:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L19:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L8

fn core::slice::sort::shared::smallsort::insert_tail::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0B8h
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L11
    jmp     L10
    nop     [rax]
L0:
    test    byte ptr [rsp+87h],0FFh
    je      L1
    mov     rdx,[rsp+0C8h]
    mov     edx,[rdx]
    mov     [rsp+84h],edx
    lea     rsi,[rsp+84h]
    mov     [rsp+68h],rsi
    mov     rdi,[rsp+0C8h]
    mov     [rsp+70h],rdi
    mov     qword ptr [rsp+78h],1
    jmp     L2
L1:
    jmp     L7
    nop     [rax+rax]
    xchg    ax,ax
L2:
    mov     rax,[rsp+0A8h]
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L13
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L3:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    xchg    ax,ax
L5:
    test    byte ptr [rsp+83h],0FFh
    je      L6
    jmp     L2
L6:
    lea     rax,[rsp+68h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+40h]
L7:
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
    nop
L8:
    lea     rax,[rsp+68h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+40h]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L9:
    mov     rax,[rsp+0C8h]
    mov     rdx,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn2
    nop     [rcx+87h]
    jmp     L0
L10:
    mov     rax,[rsp+0C8h]
    mov     [rsp+0A8h],rax
    jmp     L9
L11:
    mov     qword ptr [rsp+40h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+40h],4
    add     rdx,rcx
    mov     [rsp+0A8h],rdx
    jmp     L9
L12:
    mov     rax,[rsp+98h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+90h]
L13:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF88h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+60h],rdx
    cmp     rdx,[rsp+0C0h]
    je      L3
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L14:
    mov     rax,[rsp+60h]
    mov     [rsp+0A8h],rax
    lea     rdx,[rsp+84h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rax
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rax
    call    fn5
    nop     [rcx+83h]
    jmp     L5
L15:
    mov     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    jmp     L14
L16:
    mov     qword ptr [rsp+40h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0A8h]
    imul    rcx,[rsp+40h],4
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L14
    nop     [rax+rax]
    nop
L17:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L18
    call    rax
    nop     [rcx+48h]
    jmp     L19
L18:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L19:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L8

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,58h
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    cmp     qword ptr [rsp+70h],0
    je      L0
    cmp     rax,[rsp+70h]
    jae     L1
L0:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rax
    imul    rcx,[rsp+40h],8
    add     rax,rcx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+38h]
    imul    rcx,[rsp+70h],8
    add     rsi,rcx
    mov     [rsp+48h],rsi
    nop     [rax]
L2:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    cmp     rax,[rsp+30h]
    je      L3
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     rdi,[rsp+78h]
    mov     [rsp+10h],rdi
    call    fn0
    nop     [rcx+48h]
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+18h],8
    add     rdx,rcx
    mov     [rsp+48h],rdx
    jmp     L2
L3:
    lea     rdi,[rsp+50h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn core::slice::sort::shared::smallsort::insertion_sort_shift_left::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,58h
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    cmp     qword ptr [rsp+70h],0
    je      L0
    cmp     rax,[rsp+70h]
    jae     L1
L0:
    lea     rdi,[rsp+50h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    mov     [rsp+38h],rax
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+30h],rax
    mov     rsi,[rsp+38h]
    imul    rcx,[rsp+70h],4
    add     rsi,rcx
    mov     [rsp+48h],rsi
    nop     [rax]
L2:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    cmp     rax,[rsp+30h]
    je      L3
    mov     rdx,[rsp+48h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     rdi,[rsp+78h]
    mov     [rsp+10h],rdi
    call    fn0
    nop     [rcx+48h]
    mov     qword ptr [rsp+18h],1
    mov     rdx,[rsp+48h]
    imul    rcx,[rsp+18h],4
    add     rdx,rcx
    mov     [rsp+48h],rdx
    jmp     L2
L3:
    lea     rdi,[rsp+50h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn core::slice::sort::shared::smallsort::merge_down::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+77h]
    movzx   eax,byte ptr [rsp+77h]
    xor     al,1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L0
    mov     rsi,[rsp+0A8h]
    mov     [rsp+68h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
L1:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     rdi,[rsp+68h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rax
    mov     [rsp],rdi
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+68h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+38h],0
    mov     rsi,[rsp+38h]
    sub     rsi,rax
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+0A8h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     [rsp+0A8h],rdi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+38h],0
    mov     rsi,[rsp+38h]
    sub     rsi,rax
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+0A0h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     [rsp+0A0h],rdi
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+80h],rsi
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,98h
    ret
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    jmp     L3
L5:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0B0h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+58h],rdx
    jmp     L3

fn core::slice::sort::shared::smallsort::merge_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+77h]
    movzx   eax,byte ptr [rsp+77h]
    xor     al,1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L0
    mov     rsi,[rsp+0A8h]
    mov     [rsp+68h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
L1:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     rdi,[rsp+68h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rax
    mov     [rsp],rdi
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+68h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+38h],0
    mov     rsi,[rsp+38h]
    sub     rsi,rax
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+0A8h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     [rsp+0A8h],rdi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+50h]
    mov     qword ptr [rsp+38h],0
    mov     rsi,[rsp+38h]
    sub     rsi,rax
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+0A0h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     [rsp+0A0h],rdi
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L5
    jmp     L4
    nop     [rax]
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+0B0h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+80h],rsi
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,98h
    ret
L4:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    jmp     L3
L5:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0B0h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+58h],rdx
    jmp     L3

fn core::slice::sort::shared::smallsort::merge_up::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+77h]
    movzx   eax,byte ptr [rsp+77h]
    xor     al,1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L0
    mov     rsi,[rsp+0A0h]
    mov     [rsp+68h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+0A8h]
    mov     [rsp+68h],rax
L1:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     rdi,[rsp+68h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rax
    mov     [rsp],rdi
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+68h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0A8h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+0A8h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0A0h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+38h],1
    mov     rsi,[rsp+0B0h]
    imul    rcx,[rsp+38h],8
    add     rsi,rcx
    mov     [rsp+0B0h],rsi
    mov     [rsp+78h],rax
    mov     rdi,[rsp+0A8h]
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::shared::smallsort::merge_up::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+0A0h]
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn0
    nop     [rcx+77h]
    movzx   eax,byte ptr [rsp+77h]
    xor     al,1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L0
    mov     rsi,[rsp+0A0h]
    mov     [rsp+68h],rsi
    jmp     L1
L0:
    mov     rax,[rsp+0A8h]
    mov     [rsp+68h],rax
L1:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     rdi,[rsp+68h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],rax
    mov     [rsp],rdi
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+68h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0A8h]
    imul    rcx,[rsp+50h],4
    add     rax,rcx
    mov     [rsp+0A8h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0A0h]
    imul    rcx,[rsp+50h],4
    add     rax,rcx
    mov     [rsp+0A0h],rax
    mov     qword ptr [rsp+38h],1
    mov     rsi,[rsp+0B0h]
    imul    rcx,[rsp+38h],4
    add     rsi,rcx
    mov     [rsp+0B0h],rsi
    mov     [rsp+78h],rax
    mov     rdi,[rsp+0A8h]
    mov     [rsp+80h],rdi
    mov     [rsp+88h],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::shared::smallsort::small_sort_general::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,138h
    lea     rax,[rsp+50h]
    mov     [rsp+110h],rax
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+130h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,138h
    ret
L1:
    mov     rax,[rsp+110h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],30h
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+110h]
L2:
    mov     rax,[rsp+110h]
    mov     qword ptr [rsp+40h],30h
    mov     [rsp+120h],rax
    mov     rsi,[rsp+40h]
    mov     [rsp+128h],rsi
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFED0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+130h]
    mov     esi,0FFFFFEE0h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rsp+150h]
    mov     [rsp+20h],rax
    call    fn2
    nop     [rcx+118h]
    jmp     L0

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,198h
    mov     rax,[rsp+1A8h]
    mov     [rsp+100h],rax
    cmp     rax,2
    jae     L0
    jmp     L16
L0:
    mov     rax,[rsp+1B8h]
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+100h]
    add     rdx,10h
    mov     [rsp+0E8h],rdx
    cmp     rax,rdx
    jae     L1
    lea     rdi,[rsp+190h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+1A0h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+1A8h]
    mov     [rsp+138h],rdx
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+40h],2
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF70h
    mov     ecx,0FFFFFEB0h
    call    ryo_h_DivUW64
    mov     rax,[rsp+1B0h]
    mov     [rsp+120h],rax
    mov     rdx,[rsp+1B8h]
    mov     [rsp+128h],rdx
    mov     [rsp+188h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L2
    cmp     qword ptr [rsp+100h],10h
    jb      L2
    imul    rcx,[rsp+100h],8
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     r9,[rsp+0F8h]
    mov     [rsp],r9
    mov     r10,[rsp+188h]
    mov     [rsp+8],r10
    mov     [rsp+10h],rax
    mov     r11,[rsp+1C0h]
    mov     [rsp+18h],r11
    call    fn0
    nop     [rcx+188h]
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],8
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],8
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+100h]
    add     rsi,8
    mov     rdi,[rsp+188h]
    imul    rcx,rsi,8
    add     rdi,rcx
    mov     [rsp+0C8h],rdi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+1C0h]
    mov     [rsp+18h],r8
    call    fn1
    nop     [rcx+188h]
    mov     qword ptr [rsp+0E8h],8
    jmp     L4
L2:
    cmp     qword ptr [rsp+100h],8
    jb      L3
    mov     rdx,[rsp+130h]
    mov     [rsp+0D8h],rdx
    mov     [rsp],rdx
    mov     rsi,[rsp+188h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+1C0h]
    mov     [rsp+10h],rdi
    call    fn2
    nop     [rcx+188h]
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],8
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],8
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rsi,[rsp+1C0h]
    mov     [rsp+10h],rsi
    call    fn3
    nop     [rcx+188h]
    mov     qword ptr [rsp+0E8h],4
    jmp     L4
L3:
    mov     rax,[rsp+130h]
    mov     [rsp+0D8h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     qword ptr [rsp+0B8h],0
    mov     rdx,[rsp+0F0h]
    mov     [rsp+0C0h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFF28h
    call    ryo_h_MovW128
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFEF8h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF18h
    call    ryo_h_MovW128
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFEB8h
    mov     edx,0FFFFFEF8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFED8h
    mov     edx,0FFFFFEB8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFED8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFF38h
    mov     ecx,20h
    call    ryo_h_Copy
    nop     [rax+rax]
L5:
    lea     rax,[rsp+0A8h]
    mov     [rsp+88h],rax
    mov     qword ptr [rsp+90h],2
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx+98h]
    jmp     L23
    nop     [rax+rax]
    nop     [rax]
L6:
    lea     rdi,[rsp+190h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+0A0h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0F8h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+88h],rdx
    mov     rsi,[rsp+188h]
    imul    rcx,rax,8
    add     rsi,rcx
    mov     [rsp+80h],rsi
    cmp     rax,0
    je      L9
    jmp     L10
L8:
    lea     rax,[rsp+0A8h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn6
    nop     [rcx+40h]
    jmp     L14
L9:
    mov     rax,[rsp+0F0h]
    mov     [rsp+168h],rax
    jmp     L11
L10:
    mov     rax,[rsp+100h]
    sub     rax,[rsp+0F0h]
    mov     [rsp+168h],rax
L11:
    mov     rax,[rsp+0E8h]
    mov     [rsp+158h],rax
    mov     rdx,[rsp+168h]
    mov     [rsp+160h],rdx
    xchg    ax,ax
L12:
    mov     rax,[rsp+158h]
    mov     rdx,[rsp+160h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
L13:
    jmp     L12
L14:
    mov     rax,[rsp+120h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+0D8h],rdx
    mov     rsi,[rsp+100h]
    mov     [rsp+0E0h],rsi
    mov     [rsp+0B8h],rax
    mov     [rsp+0B0h],rsi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L31
    jmp     L30
    nop     [rax+rax]
L15:
    mov     rax,[rsp+0D0h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+0C0h],rdx
    mov     rsi,[rsp+0E0h]
    mov     [rsp+0B8h],rsi
L16:
    lea     rdi,[rsp+190h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,198h
    ret
    nop     [rax]
L17:
    lea     rax,[rsp+0A8h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn7
    nop     [rcx+40h]
    nop     [rax]
L18:
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF78h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L19:
    lea     rax,[rsp+0D0h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn8
    nop     [rcx+40h]
    jmp     L18
L20:
    mov     rax,[rsp+130h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+120h]
    mov     [rsp+0C8h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx+120h]
L21:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF48h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],8
    add     rax,rcx
    mov     [rsp+180h],rax
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],8
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L22
    mov     r8,[rsp+180h]
    mov     [rsp+0C8h],r8
    mov     [rsp+0C0h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+120h]
L22:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF48h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+0E8h],1
    jmp     L4
L23:
    mov     rax,[rsp+98h]
    mov     [rsp+170h],rax
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L24]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L24:
    .long   L8
    .long   L7
    .long   L6
L25:
    mov     rax,[rsp+158h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L28
    jmp     L27
L26:
    jmp     L5
L27:
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE80h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+110h]
L28:
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+158h],rax
    mov     rdx,[rsp+60h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rsp+148h],rdi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rsp+140h],r8
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L29
    mov     r11,[rsp+148h]
    mov     [rsp+58h],r11
    mov     [rsp+50h],r8
    mov     [rsp],r11
    mov     [rsp+8],r8
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+110h]
L29:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFED0h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+80h]
    mov     [rsp],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+1C0h]
    mov     [rsp+10h],rsi
    call    fn17
    nop     [rcx+140h]
    jmp     L13
L30:
    mov     rax,[rsp+0B8h]
    mov     [rsp+0A8h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+0B0h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx+110h]
L31:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     [rsp+0C8h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0B8h],rsi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFF30h
    call    ryo_h_MovW128
    mov     rax,[rsp+0B8h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+1C0h]
    mov     [rsp+18h],rdx
    call    fn20
    nop     [rcx+140h]
    jmp     L15
    nop     [rax+rax]
    nop     [rax+rax]
L32:
    lea     rdi,[rsp+190h]
    lea     rsi,[sym21]
    lea     rdx,[site22]
    mov     ecx,0FFFFFEB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L33
    call    rax
    nop     [rcx+48h]
    jmp     L34
L33:
    lea     rdi,[rsp+190h]
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L34:
    lea     rdi,[rsp+190h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L32
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L19

fn core::slice::sort::shared::smallsort::small_sort_general_with_scratch::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,198h
    mov     rax,[rsp+1A8h]
    mov     [rsp+100h],rax
    cmp     rax,2
    jae     L0
    jmp     L16
L0:
    mov     rax,[rsp+1B8h]
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+100h]
    add     rdx,10h
    mov     [rsp+0E8h],rdx
    cmp     rax,rdx
    jae     L1
    lea     rdi,[rsp+190h]
    call    ryo_h_Abort
    ud2
L1:
    mov     rax,[rsp+1A0h]
    mov     [rsp+130h],rax
    mov     rdx,[rsp+1A8h]
    mov     [rsp+138h],rdx
    mov     [rsp+0F8h],rax
    mov     qword ptr [rsp+40h],2
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF70h
    mov     ecx,0FFFFFEB0h
    call    ryo_h_DivUW64
    mov     rax,[rsp+1B0h]
    mov     [rsp+120h],rax
    mov     rdx,[rsp+1B8h]
    mov     [rsp+128h],rdx
    mov     [rsp+188h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L2
    cmp     qword ptr [rsp+100h],10h
    jb      L2
    imul    rcx,[rsp+100h],4
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     r9,[rsp+0F8h]
    mov     [rsp],r9
    mov     r10,[rsp+188h]
    mov     [rsp+8],r10
    mov     [rsp+10h],rax
    mov     r11,[rsp+1C0h]
    mov     [rsp+18h],r11
    call    fn0
    nop     [rcx+188h]
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],4
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],4
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     rsi,[rsp+100h]
    add     rsi,8
    mov     rdi,[rsp+188h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+0C8h],rdi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    mov     r8,[rsp+1C0h]
    mov     [rsp+18h],r8
    call    fn1
    nop     [rcx+188h]
    mov     qword ptr [rsp+0E8h],8
    jmp     L4
L2:
    cmp     qword ptr [rsp+100h],8
    jb      L3
    mov     rdx,[rsp+130h]
    mov     [rsp+0D8h],rdx
    mov     [rsp],rdx
    mov     rsi,[rsp+188h]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+1C0h]
    mov     [rsp+10h],rdi
    call    fn2
    nop     [rcx+188h]
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],4
    add     rax,rcx
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],4
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     rsi,[rsp+1C0h]
    mov     [rsp+10h],rsi
    call    fn3
    nop     [rcx+188h]
    mov     qword ptr [rsp+0E8h],4
    jmp     L4
L3:
    mov     rax,[rsp+130h]
    mov     [rsp+0D8h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     qword ptr [rsp+0B8h],0
    mov     rdx,[rsp+0F0h]
    mov     [rsp+0C0h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFF28h
    call    ryo_h_MovW128
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFEF8h
    lea     rdx,[k4]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF18h
    call    ryo_h_MovW128
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFEB8h
    mov     edx,0FFFFFEF8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFED8h
    mov     edx,0FFFFFEB8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFED8h
    mov     ecx,20h
    call    ryo_h_Copy
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFF38h
    mov     ecx,20h
    call    ryo_h_Copy
    nop     [rax+rax]
L5:
    lea     rax,[rsp+0A8h]
    mov     [rsp+88h],rax
    mov     qword ptr [rsp+90h],2
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx+98h]
    jmp     L23
    nop     [rax+rax]
    nop     [rax]
L6:
    lea     rdi,[rsp+190h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+0A0h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0F8h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     [rsp+88h],rdx
    mov     rsi,[rsp+188h]
    imul    rcx,rax,4
    add     rsi,rcx
    mov     [rsp+80h],rsi
    cmp     rax,0
    je      L9
    jmp     L10
L8:
    lea     rax,[rsp+0A8h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn6
    nop     [rcx+40h]
    jmp     L14
L9:
    mov     rax,[rsp+0F0h]
    mov     [rsp+168h],rax
    jmp     L11
L10:
    mov     rax,[rsp+100h]
    sub     rax,[rsp+0F0h]
    mov     [rsp+168h],rax
L11:
    mov     rax,[rsp+0E8h]
    mov     [rsp+158h],rax
    mov     rdx,[rsp+168h]
    mov     [rsp+160h],rdx
    xchg    ax,ax
L12:
    mov     rax,[rsp+158h]
    mov     rdx,[rsp+160h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L26
    jmp     L25
    nop     [rax+rax]
L13:
    jmp     L12
L14:
    mov     rax,[rsp+120h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+0D8h],rdx
    mov     rsi,[rsp+100h]
    mov     [rsp+0E0h],rsi
    mov     [rsp+0B8h],rax
    mov     [rsp+0B0h],rsi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L31
    jmp     L30
    nop     [rax+rax]
L15:
    mov     rax,[rsp+0D0h]
    mov     [rsp+0C8h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+0C0h],rdx
    mov     rsi,[rsp+0E0h]
    mov     [rsp+0B8h],rsi
L16:
    lea     rdi,[rsp+190h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,198h
    ret
    nop     [rax]
L17:
    lea     rax,[rsp+0A8h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn7
    nop     [rcx+40h]
    nop     [rax]
L18:
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF78h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L19:
    lea     rax,[rsp+0D0h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    call    fn8
    nop     [rcx+40h]
    jmp     L18
L20:
    mov     rax,[rsp+130h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+120h]
    mov     [rsp+0C8h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx+120h]
L21:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF48h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0F8h]
    imul    rcx,[rsp+0F0h],4
    add     rax,rcx
    mov     [rsp+180h],rax
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+188h]
    imul    rcx,[rsp+0F0h],4
    add     rdx,rcx
    mov     [rsp+0D0h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L22
    mov     r8,[rsp+180h]
    mov     [rsp+0C8h],r8
    mov     [rsp+0C0h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+120h]
L22:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF48h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+0E8h],1
    jmp     L4
L23:
    mov     rax,[rsp+98h]
    mov     [rsp+170h],rax
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L24]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L24:
    .long   L8
    .long   L7
    .long   L6
L25:
    mov     rax,[rsp+158h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L28
    jmp     L27
L26:
    jmp     L5
L27:
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE80h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+110h]
L28:
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+158h],rax
    mov     rdx,[rsp+60h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rdx,4
    add     rdi,rcx
    mov     [rsp+148h],rdi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+80h]
    imul    rcx,rdx,4
    add     r8,rcx
    mov     [rsp+140h],r8
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L29
    mov     r11,[rsp+148h]
    mov     [rsp+58h],r11
    mov     [rsp+50h],r8
    mov     [rsp],r11
    mov     [rsp+8],r8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+110h]
L29:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFED0h
    mov     ecx,0FFFFFEA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+80h]
    mov     [rsp],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+1C0h]
    mov     [rsp+10h],rsi
    call    fn17
    nop     [rcx+140h]
    jmp     L13
L30:
    mov     rax,[rsp+0B8h]
    mov     [rsp+0A8h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+0B0h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx+110h]
L31:
    mov     rax,[rsp+0B8h]
    mov     rdx,[rsp+0B0h]
    mov     [rsp+0C0h],rax
    mov     [rsp+0C8h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0B8h],rsi
    lea     rdi,[rsp+190h]
    mov     esi,0FFFFFE70h
    mov     edx,0FFFFFF30h
    call    ryo_h_MovW128
    mov     rax,[rsp+0B8h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+1C0h]
    mov     [rsp+18h],rdx
    call    fn20
    nop     [rcx+140h]
    jmp     L15
    nop     [rax+rax]
    nop     [rax+rax]
L32:
    lea     rdi,[rsp+190h]
    lea     rsi,[sym21]
    lea     rdx,[site22]
    mov     ecx,0FFFFFEB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L33
    call    rax
    nop     [rcx+48h]
    jmp     L34
L33:
    lea     rdi,[rsp+190h]
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L34:
    lea     rdi,[rsp+190h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L17
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L32
    lea     rdi,[rsp+190h]
    mov     rsi,rax
    mov     edx,0FFFFFF78h
    call    ryo_h_Lpad
    jmp     L19

fn core::slice::sort::shared::smallsort::small_sort_network::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,168h
    mov     rax,[rsp+178h]
    mov     [rsp+100h],rax
    cmp     rax,2
    jae     L0
    jmp     L11
L0:
    cmp     qword ptr [rsp+100h],20h
    jbe     L1
    lea     rdi,[rsp+160h]
    call    ryo_h_Abort
    ud2
L1:
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFFA0h
    mov     ecx,0FFFFFED8h
    call    ryo_h_DivUW64
    cmp     qword ptr [rsp+100h],12h
    setb    [rsp+77h]
    mov     rdx,[rsp+170h]
    mov     [rsp+120h],rdx
    mov     rsi,[rsp+178h]
    mov     [rsp+128h],rsi
    mov     [rsp+68h],rdx
    test    byte ptr [rsp+77h],0FFh
    je      L2
    mov     r8,[rsp+100h]
    mov     [rsp+158h],r8
    jmp     L3
L2:
    mov     rax,[rsp+78h]
    mov     [rsp+158h],rax
L3:
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L13
    jmp     L12
    nop
L4:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+148h]
    mov     [rsp+60h],rdx
    cmp     rdx,0Dh
    jb      L5
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rsp+180h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+150h]
    mov     qword ptr [rsp+150h],0Dh
    jmp     L7
L5:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+148h]
    mov     [rsp+60h],rdx
    cmp     rdx,9
    jb      L6
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rsp+180h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+150h]
    mov     qword ptr [rsp+150h],9
    jmp     L7
L6:
    mov     qword ptr [rsp+150h],1
L7:
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEF8h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rsp+150h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+180h]
    mov     [rsp+18h],rdx
    call    fn2
    nop     [rcx+150h]
    test    byte ptr [rsp+77h],0FFh
    je      L8
    jmp     L11
L8:
    mov     rax,[rsp+140h]
    mov     rdx,[rsp+148h]
    mov     [rsp+60h],rax
    mov     rsi,[rsp+120h]
    mov     [rsp+58h],rsi
    cmp     rax,rsi
    je      L9
    lea     rdi,[rsp+80h]
    mov     [rsp+118h],rdi
    mov     [rsp+138h],rdi
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L17
    jmp     L16
L9:
    mov     rax,[rsp+68h]
    imul    rcx,[rsp+78h],4
    add     rax,rcx
    mov     [rsp+60h],rax
    mov     rdx,[rsp+100h]
    sub     rdx,[rsp+78h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
L10:
    mov     rax,[rsp+118h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    lea     rdi,[rsp+160h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,168h
    ret
L12:
    mov     rax,[rsp+120h]
    mov     [rsp+60h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+158h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+120h]
L13:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+158h]
    mov     [rsp+140h],rax
    mov     [rsp+148h],rdx
    jmp     L4
L14:
    mov     rax,[rsp+60h]
    mov     [rsp+50h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+58h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+118h]
L15:
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+58h]
    mov     [rsp+140h],rax
    mov     [rsp+148h],rdx
    jmp     L4
L16:
    mov     rax,[rsp+120h]
    mov     [rsp+50h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+100h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+118h]
L17:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+100h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    mov     edx,0FFFFFEF8h
    call    ryo_h_MovW128
    mov     rax,[rsp+138h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+180h]
    mov     [rsp+18h],rdx
    call    fn9
    nop     [rcx+130h]
    jmp     L10
L18:
    mov     rax,[rsp+118h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+120h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+100h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC8h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    call    fn11
    nop     [rcx+108h]
L19:
    imul    rax,[rsp+100h],4
    mov     [rsp+38h],rax
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF00h
    mov     ecx,0FFFFFED8h
    call    ryo_h_Memcpy
    jmp     L11

fn core::slice::sort::shared::smallsort::sort13_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,48h
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    cmp     rax,0Dh
    jae     L0
    lea     rdi,[rsp+40h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],0Ch
    mov     r8,[rsp+60h]
    mov     [rsp+18h],r8
    call    fn0
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],0Ah
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn1
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],9
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn2
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn3
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],0Bh
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn4
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn5
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn6
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],3
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn7
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],0Bh
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn8
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp+10h],9
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn9
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],0Ah
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn10
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn11
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],2
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn12
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn13
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn14
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp+10h],0Ah
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn15
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0Bh
    mov     qword ptr [rsp+10h],0Ch
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn16
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn17
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],9
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn18
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],0Bh
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn19
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0Ah
    mov     qword ptr [rsp+10h],0Ch
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn20
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn21
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn22
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn23
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],0Bh
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn24
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp+10h],0Ah
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn25
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],1
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn26
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn27
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],9
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn28
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn29
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0Ah
    mov     qword ptr [rsp+10h],0Bh
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn30
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],3
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn31
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn32
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn33
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],9
    mov     qword ptr [rsp+10h],0Ah
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn34
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],2
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn35
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn36
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn37
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn38
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],3
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn39
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn40
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn41
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],9
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn42
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn43
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn44
    nop     [rcx+40h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::shared::smallsort::sort4_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0B8h
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rsi
    mov     rdi,[rsp+0D0h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+0AFh]
    mov     qword ptr [rsp+38h],3
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     qword ptr [rsp+38h],2
    mov     rdi,[rsp+0C0h]
    imul    rcx,[rsp+38h],8
    add     rdi,rcx
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    call    fn1
    nop     [rcx+0AEh]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFFFh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0C0h]
    imul    rcx,[rsp+98h],8
    add     rax,rcx
    mov     [rsp+0A0h],rax
    movzx   edx,byte ptr [rsp+0AFh]
    xor     dl,1
    mov     [rsp+0ADh],dl
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0C0h]
    imul    rcx,[rsp+90h],8
    add     rax,rcx
    mov     [rsp+98h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFFEh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+38h]
    add     rdx,[rsp+80h]
    mov     rsi,[rsp+0C0h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rsp+90h],rsi
    movzx   edi,byte ptr [rsp+0AEh]
    xor     dil,1
    mov     [rsp+0ADh],dil
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+38h]
    add     rdx,[rsp+78h]
    mov     rsi,[rsp+0C0h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+0A0h]
    mov     [rsp+78h],rdi
    mov     [rsp+80h],r8
    mov     r9,[rsp+0D0h]
    mov     [rsp],r9
    mov     [rsp+8],rdi
    mov     [rsp+10h],r8
    call    fn2
    nop     [rcx+0ADh]
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+98h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn3
    nop     [rcx+0ACh]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+90h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+10h],rsi
    call    fn4
    nop     [rcx+80h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+98h]
    mov     [rsp],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    call    fn5
    nop     [rcx+78h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+90h]
    mov     [rsp],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+10h],rsi
    call    fn6
    nop     [rcx+68h]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+0A0h]
    mov     [rsp],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+10h],rsi
    call    fn7
    nop     [rcx+70h]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+98h]
    mov     [rsp],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+10h],rsi
    call    fn8
    nop     [rcx+60h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+88h]
    mov     [rsp],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+10h],rsi
    call    fn9
    nop     [rcx+68h]
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn10
    nop     [rcx+0ABh]
    movzx   eax,byte ptr [rsp+0ABh]
    mov     [rsp+8],al
    mov     rdx,[rsp+68h]
    mov     [rsp],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    call    fn11
    nop     [rcx+60h]
    movzx   eax,byte ptr [rsp+0ABh]
    mov     [rsp+8],al
    mov     rdx,[rsp+70h]
    mov     [rsp],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+10h],rsi
    call    fn12
    nop     [rcx+58h]
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    mov     rsi,[rsp+80h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+0C8h]
    mov     [rsp+48h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+0B0h]
L0:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,18h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L1
    mov     r8,[rsp+60h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+0B0h]
L1:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     r8,[rsp+58h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx+0B0h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFA8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],3
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L3
    mov     r8,[rsp+78h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx+0B0h]
L3:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::sort::shared::smallsort::sort4_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0B8h
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rsi
    mov     rdi,[rsp+0D0h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+0AFh]
    mov     qword ptr [rsp+38h],3
    mov     rdx,[rsp+0C0h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     qword ptr [rsp+38h],2
    mov     rdi,[rsp+0C0h]
    imul    rcx,[rsp+38h],4
    add     rdi,rcx
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rdi
    mov     r8,[rsp+0D0h]
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    call    fn1
    nop     [rcx+0AEh]
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFFFh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0C0h]
    imul    rcx,[rsp+98h],4
    add     rax,rcx
    mov     [rsp+0A0h],rax
    movzx   edx,byte ptr [rsp+0AFh]
    xor     dl,1
    mov     [rsp+0ADh],dl
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0C0h]
    imul    rcx,[rsp+90h],4
    add     rax,rcx
    mov     [rsp+98h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFFEh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+38h]
    add     rdx,[rsp+80h]
    mov     rsi,[rsp+0C0h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     [rsp+90h],rsi
    movzx   edi,byte ptr [rsp+0AEh]
    xor     dil,1
    mov     [rsp+0ADh],dil
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFFDh
    call    ryo_h_ZextW8W64
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+38h]
    add     rdx,[rsp+78h]
    mov     rsi,[rsp+0C0h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+90h]
    mov     r8,[rsp+0A0h]
    mov     [rsp+78h],rdi
    mov     [rsp+80h],r8
    mov     r9,[rsp+0D0h]
    mov     [rsp],r9
    mov     [rsp+8],rdi
    mov     [rsp+10h],r8
    call    fn2
    nop     [rcx+0ADh]
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+98h]
    mov     [rsp+78h],rax
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn3
    nop     [rcx+0ACh]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+90h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+10h],rsi
    call    fn4
    nop     [rcx+80h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+98h]
    mov     [rsp],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    call    fn5
    nop     [rcx+78h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+90h]
    mov     [rsp],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+10h],rsi
    call    fn6
    nop     [rcx+68h]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+0A0h]
    mov     [rsp],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+10h],rsi
    call    fn7
    nop     [rcx+70h]
    movzx   eax,byte ptr [rsp+0ADh]
    mov     [rsp+8],al
    mov     rdx,[rsp+98h]
    mov     [rsp],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+10h],rsi
    call    fn8
    nop     [rcx+60h]
    movzx   eax,byte ptr [rsp+0ACh]
    mov     [rsp+8],al
    mov     rdx,[rsp+88h]
    mov     [rsp],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+10h],rsi
    call    fn9
    nop     [rcx+68h]
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     [rsp+58h],rax
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp],rsi
    mov     [rsp+8],rax
    mov     [rsp+10h],rdx
    call    fn10
    nop     [rcx+0ABh]
    movzx   eax,byte ptr [rsp+0ABh]
    mov     [rsp+8],al
    mov     rdx,[rsp+68h]
    mov     [rsp],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    call    fn11
    nop     [rcx+60h]
    movzx   eax,byte ptr [rsp+0ABh]
    mov     [rsp+8],al
    mov     rdx,[rsp+70h]
    mov     [rsp],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+10h],rsi
    call    fn12
    nop     [rcx+58h]
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    mov     rsi,[rsp+80h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+0C8h]
    mov     [rsp+48h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+0B0h]
L0:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,18h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],1
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L1
    mov     r8,[rsp+60h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+0B0h]
L1:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],2
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L2
    mov     r8,[rsp+58h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx+0B0h]
L2:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFA8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    mov     qword ptr [rsp+38h],3
    mov     rdx,[rsp+0C8h]
    imul    rcx,[rsp+38h],4
    add     rdx,rcx
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L3
    mov     r8,[rsp+78h]
    mov     [rsp+48h],r8
    mov     [rsp+40h],rdx
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx+0B0h]
L3:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],4
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFF80h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret

fn core::slice::sort::shared::smallsort::sort8_stable::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     [rsp+58h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+60h]
    mov     qword ptr [rsp+30h],4
    mov     rdx,[rsp+70h]
    imul    rcx,[rsp+30h],8
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+30h],4
    mov     rdi,[rsp+80h]
    imul    rcx,[rsp+30h],8
    add     rdi,rcx
    mov     [rsp+50h],rdi
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    mov     r8,[rsp+88h]
    mov     [rsp+10h],r8
    call    fn1
    nop     [rcx+60h]
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L2
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret
L1:
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+60h]
L2:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+40h],8
    mov     [rsp+50h],rax
    mov     rsi,[rsp+40h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+18h],rdx
    call    fn4
    nop     [rcx+60h]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort8_stable::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     [rsp+58h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+60h]
    mov     qword ptr [rsp+30h],4
    mov     rdx,[rsp+70h]
    imul    rcx,[rsp+30h],4
    add     rdx,rcx
    mov     [rsp+58h],rdx
    mov     qword ptr [rsp+30h],4
    mov     rdi,[rsp+80h]
    imul    rcx,[rsp+30h],4
    add     rdi,rcx
    mov     [rsp+50h],rdi
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    mov     r8,[rsp+88h]
    mov     [rsp+10h],r8
    call    fn1
    nop     [rcx+60h]
    mov     rax,[rsp+80h]
    mov     [rsp+48h],rax
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L2
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,68h
    ret
L1:
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+60h]
L2:
    mov     rax,[rsp+48h]
    mov     qword ptr [rsp+40h],8
    mov     [rsp+50h],rax
    mov     rsi,[rsp+40h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+18h],rdx
    call    fn4
    nop     [rcx+60h]
    jmp     L0

fn core::slice::sort::shared::smallsort::sort9_optimal::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,48h
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
    cmp     rax,9
    jae     L0
    lea     rdi,[rsp+40h]
    call    ryo_h_Abort
    ud2
L0:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],3
    mov     r8,[rsp+60h]
    mov     [rsp+18h],r8
    call    fn0
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn1
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn2
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn3
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn4
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn5
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn6
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn7
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],2
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn8
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],3
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn9
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn10
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],7
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn11
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn12
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn13
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn14
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    mov     qword ptr [rsp+10h],1
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn15
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn16
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn17
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],8
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn18
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],2
    mov     qword ptr [rsp+10h],3
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn19
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],5
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn20
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],6
    mov     qword ptr [rsp+10h],7
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn21
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    mov     qword ptr [rsp+10h],2
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn22
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],3
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn23
    nop     [rcx+40h]
    mov     rax,[rsp+38h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],5
    mov     qword ptr [rsp+10h],6
    mov     rdi,[rsp+60h]
    mov     [rsp+18h],rdi
    call    fn24
    nop     [rcx+40h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::shared::smallsort::swap_if_less::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    imul    rcx,[rsp+0A8h],4
    add     rax,rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+0A0h]
    imul    rcx,[rsp+0B0h],4
    add     rdx,rcx
    mov     [rsp+78h],rdx
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rax
    mov     rsi,[rsp+0B8h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+77h]
    movzx   eax,byte ptr [rsp+77h]
    mov     [rsp+8],al
    mov     rdx,[rsp+78h]
    mov     [rsp],rdx
    mov     rsi,[rsp+80h]
    mov     [rsp+10h],rsi
    call    fn1
    nop     [rcx+68h]
    movzx   eax,byte ptr [rsp+77h]
    mov     [rsp+8],al
    mov     rdx,[rsp+80h]
    mov     [rsp],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+10h],rsi
    call    fn2
    nop     [rcx+60h]
    mov     rax,[rsp+60h]
    mov     eax,[rax]
    mov     [rsp+70h],eax
    mov     rdx,[rsp+68h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L0:
    lea     rax,[rsp+70h]
    mov     [rsp+58h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L2
    mov     byte ptr [rsp+76h],1
    jmp     L3
L2:
    mov     byte ptr [rsp+76h],0
L3:
    mov     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    movzx   edi,byte ptr [rsp+76h]
    mov     [rsp+18h],dil
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+88h]
L4:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rsp+58h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+88h]
L6:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::stable::AlignedStorage::<(u32, u32), 4096>::as_uninit_slice_mut
    sub     rsp,98h
    mov     qword ptr [rsp+30h],8
    cmp     qword ptr [rsp+30h],0
    sete    [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    je      L2
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+90h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+38h]
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+30h],1000h
    mov     qword ptr [rsp+28h],8
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_DivUW64
    mov     rax,[rsp+0A0h]
    mov     qword ptr [rsp+48h],1000h
    mov     [rsp+68h],rax
    mov     rsi,[rsp+48h]
    mov     [rsp+70h],rsi
    mov     [rsp+50h],rax
    mov     rdi,[rsp+68h]
    mov     [rsp+58h],rdi
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L3
    mov     r10,[rsp+68h]
    mov     [rsp+50h],r10
    mov     [rsp],r10
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     rax,[rsp+60h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+68h]
L3:
    mov     rax,[rsp+58h]
    mov     rdx,[rsp+60h]
    mov     [rsp+80h],rax
    mov     [rsp+88h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::stable::drift::create_run::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0A8h
    mov     rax,[rsp+0B8h]
    mov     [rsp+88h],rax
    cmp     rax,[rsp+0D0h]
    jb      L1
    mov     rdx,[rsp+0B0h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rsp+0E0h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+70h]
    mov     rax,[rsp+70h]
    mov     [rsp+80h],rax
    movzx   edx,byte ptr [rsp+78h]
    mov     [rsp+95h],dl
    cmp     rax,[rsp+88h]
    setbe   [rsp+97h]
    cmp     rax,[rsp+0D0h]
    jb      L1
    test    byte ptr [rsp+95h],0FFh
    je      L0
    cmp     rax,0
    jb      L5
    jmp     L8
    nop     [rax+rax]
L0:
    mov     rax,[rsp+80h]
    shl     rax,1
    or      rax,1
    mov     [rsp+98h],rax
    jmp     L4
L1:
    test    byte ptr [rsp+0D8h],0FFh
    je      L3
    call    fn1
    nop     [rcx+78h]
    mov     rax,[rsp+78h]
    mov     [rsp],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+8],rdx
    call    fn2
    nop     [rcx+80h]
    jmp     L9
    nop     [rax+rax]
L2:
    mov     rax,[rsp+80h]
    shl     rax,1
    or      rax,1
    mov     [rsp+98h],rax
    jmp     L4
L3:
    mov     rax,[rsp+0D0h]
    mov     [rsp],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+8],rdx
    call    fn3
    nop     [rcx+80h]
    jmp     L16
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L5:
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+97h]
    jmp     L7
L6:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    mov     rsi,[rsp+80h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    call    fn8
    nop     [rcx+97h]
    jmp     L0
L9:
    cmp     qword ptr [rsp+80h],0
    jb      L14
    jmp     L15
    nop     [rax]
L10:
    mov     rax,[rsp+0B0h]
    mov     rdx,[rsp+0B8h]
    mov     rsi,[rsp+80h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     dword ptr [rsp+28h],0
    mov     qword ptr [rsp+20h],0
    mov     rsi,[rsp+0E0h]
    mov     [rsp+30h],rsi
    call    fn9
    nop     [rcx+97h]
    jmp     L2
    nop
L11:
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+80h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym11]
    lea     rdx,[site12]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L12
    call    rax
    nop     [rcx+97h]
    jmp     L13
L12:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L13:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L14:
    jmp     L11
L15:
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jae     L10
    jmp     L11
L16:
    mov     rax,[rsp+80h]
    shl     rax,1
    mov     [rsp+98h],rax
    jmp     L4

fn core::slice::sort::stable::drift::logical_merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0B8h
    mov     rax,[rsp+0C8h]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+0D8h]
    cmp     rax,rdx
    setbe   [rsp+87h]
    test    byte ptr [rsp+87h],0FFh
    je      L1
    mov     rdi,[rsp+0E0h]
    and     rdi,1
    cmp     rdi,1
    sete    [rsp+86h]
    test    byte ptr [rsp+86h],0FFh
    je      L0
    jmp     L1
L0:
    mov     rax,[rsp+0E8h]
    and     rax,1
    cmp     rax,1
    sete    [rsp+85h]
    test    byte ptr [rsp+85h],0FFh
    je      L5
L1:
    mov     rax,[rsp+0E0h]
    mov     [rsp+90h],rax
    and     rax,1
    cmp     rax,1
    sete    [rsp+84h]
    test    byte ptr [rsp+84h],0FFh
    jne     L2
    mov     rdi,[rsp+90h]
    shr     rdi,1
    mov     [rsp+0A0h],rdi
    cmp     rdi,0
    jb      L11
    jmp     L12
    nop     [rax+rax]
L2:
    mov     rax,[rsp+0E8h]
    and     rax,1
    cmp     rax,1
    sete    [rsp+84h]
    test    byte ptr [rsp+84h],0FFh
    je      L3
    jmp     L4
L3:
    mov     rax,[rsp+90h]
    shr     rax,1
    mov     [rsp+98h],rax
    mov     rdx,[rsp+88h]
    cmp     rdx,rax
    jb      L13
    jmp     L16
    xchg    ax,ax
L4:
    mov     rax,[rsp+90h]
    shr     rax,1
    mov     [rsp+78h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+0F0h]
    mov     [rsp+28h],rdx
    call    fn0
    nop     [rcx+98h]
    mov     rax,[rsp+88h]
    shl     rax,1
    or      rax,1
    mov     [rsp+0A8h],rax
    jmp     L6
L5:
    mov     rax,[rsp+88h]
    shl     rax,1
    mov     [rsp+0A8h],rax
L6:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
    nop
L7:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    mov     rsi,[rsp+0A0h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0F0h]
    mov     [rsp+20h],rax
    call    fn1
    nop     [rcx+0A8h]
    jmp     L2
    xchg    ax,ax
L8:
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+0A0h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx+98h]
    jmp     L10
L9:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L10:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L11:
    jmp     L8
L12:
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+0A0h]
    jae     L7
    jmp     L8
L13:
    mov     rax,[rsp+98h]
    mov     [rsp],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L14
    call    rax
    nop     [rcx+98h]
    jmp     L15
L14:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L15:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L16:
    mov     rax,[rsp+88h]
    sub     rax,[rsp+98h]
    mov     rdx,[rsp+0C0h]
    mov     rsi,[rsp+0C8h]
    imul    rcx,[rsp+98h],8
    add     rdx,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0F0h]
    mov     [rsp+20h],rax
    call    fn10
    nop     [rcx+0A0h]
    jmp     L4

fn core::slice::sort::stable::drift::sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,398h
    mov     rax,[rsp+3A8h]
    mov     [rsp+330h],rax
    cmp     rax,2
    jae     L0
    jmp     L18
L0:
    mov     rax,[rsp+330h]
    mov     [rsp+320h],rax
    cmp     rax,0
    sete    [rsp+317h]
    test    byte ptr [rsp+317h],0FFh
    je      L19
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+390h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+48h]
    jmp     L2
L1:
    lea     rdi,[rsp+390h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    lea     rdi,[rsp+390h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax]
L3:
    mov     qword ptr [rsp+40h],2
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFFA0h
    mov     ecx,0FFFFFCB0h
    call    ryo_h_DivUW64
    mov     rax,[rsp+330h]
    sub     rax,[rsp+308h]
    mov     [rsp+310h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],40h
    call    fn4
    nop     [rcx+320h]
    jmp     L25
    nop     [rax+rax]
L4:
    mov     rax,[rsp+330h]
    mov     [rsp],rax
    lea     rdi,[rsp+390h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+320h]
    jmp     L6
L5:
    lea     rdi,[rsp+390h]
    lea     rsi,[ro+20]
    call    qword ptr [sym7]
L6:
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     qword ptr [rsp+318h],0
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFD78h
    lea     rdx,[k8]
    mov     ecx,210h
    call    ryo_h_Const
    lea     rax,[rsp+108h]
    mov     [rsp+340h],rax
    mov     [rsp+0F8h],rax
    mov     rdx,[rsp+340h]
    mov     [rsp+100h],rdx
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFD2Eh
    lea     rdx,[k9]
    mov     ecx,42h
    call    ryo_h_Const
    lea     rax,[rsp+0BEh]
    mov     [rsp+338h],rax
    mov     rdx,[rsp+338h]
    mov     [rsp+0B0h],rdx
    mov     qword ptr [rsp+0A8h],0
    mov     qword ptr [rsp+358h],1
    nop     [rax+rax]
L8:
    mov     rax,[rsp+0A8h]
    mov     [rsp+0A0h],rax
    cmp     rax,[rsp+330h]
    jae     L10
    mov     rdx,[rsp+0A8h]
    mov     [rsp+370h],rdx
    mov     rsi,[rsp+330h]
    cmp     rsi,rdx
    jb      L26
    jmp     L29
    nop     [rax+rax]
    nop     [rax]
L9:
    mov     rax,[rsp+0A8h]
    mov     rdx,[rsp+358h]
    shr     rdx,1
    sub     rax,rdx
    mov     rsi,[rsp+0A8h]
    mov     rdi,[rsp+0A8h]
    mov     r8,[rsp+378h]
    shr     r8,1
    add     rdi,r8
    mov     r9,[rsp+328h]
    mov     [rsp+88h],r9
    mov     [rsp+70h],rsi
    add     rax,rsi
    add     rsi,rdi
    imul    r9,rax
    mov     r10,[rsp+88h]
    imul    r10,rsi
    xor     r9,r10
    mov     [rsp+68h],r9
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFCB4h
    mov     edx,0FFFFFCD8h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+44h]
    mov     [rsp+0B8h],eax
    jmp     L30
L10:
    mov     qword ptr [rsp+378h],1
    mov     byte ptr [rsp+36Fh],0
    nop     [rax+rax]
    nop     [rax]
L11:
    mov     rax,[rsp+318h]
    mov     [rsp+0A0h],rax
    cmp     rax,1
    jbe     L14
    mov     rsi,[rsp+318h]
    sub     rsi,1
    mov     rdi,[rsp+0B0h]
    imul    rcx,rsi,1
    add     rdi,rcx
    movzx   edi,byte ptr [rdi]
    mov     [rsp+0BBh],dil
    movzx   r8d,byte ptr [rsp+36Fh]
    mov     [rsp+0BAh],r8b
    cmp     dil,r8b
    jb      L13
    mov     r9,[rsp+318h]
    sub     r9,1
    mov     r10,[rsp+100h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     r10,[r10]
    mov     [rsp+0A0h],r10
    shr     r10,1
    mov     r11,[rsp+358h]
    shr     r11,1
    add     r10,r11
    mov     rax,[rsp+0A8h]
    sub     rax,r10
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+360h],rdx
    mov     rsi,[rsp+3A0h]
    mov     [rsp+60h],rsi
    mov     r9,[rsp+3A8h]
    mov     [rsp+68h],r9
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L32
    jmp     L31
    nop     [rax+rax]
    xchg    ax,ax
L12:
    mov     rax,[rsp+318h]
    sub     rax,1
    mov     [rsp+318h],rax
    jmp     L11
L13:
    jmp     L14
L14:
    mov     rax,[rsp+358h]
    mov     [rsp+0A0h],rax
    mov     rdx,[rsp+318h]
    mov     rsi,[rsp+100h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     rcx,[rsp+0A0h]
    mov     [rsi],rcx
    mov     rdi,[rsp+318h]
    mov     r8,[rsp+0B0h]
    imul    rcx,rdi,1
    add     r8,rcx
    movzx   ecx,byte ptr [rsp+36Fh]
    mov     [r8],cl
    mov     r9,[rsp+318h]
    add     r9,1
    mov     [rsp+318h],r9
    mov     r10,[rsp+0A8h]
    mov     [rsp+0A0h],r10
    cmp     r10,[rsp+330h]
    jb      L15
    mov     r11,[rsp+358h]
    and     r11,1
    cmp     r11,1
    sete    [rsp+0BDh]
    test    byte ptr [rsp+0BDh],0FFh
    je      L17
    jmp     L16
L15:
    mov     rax,[rsp+378h]
    shr     rax,1
    mov     rdx,[rsp+0A8h]
    add     rdx,rax
    mov     [rsp+0A8h],rdx
    mov     rsi,[rsp+378h]
    mov     [rsp+358h],rsi
    jmp     L8
L16:
    jmp     L18
L17:
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC80h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+3C8h]
    mov     [rsp+20h],rax
    call    fn10
    nop     [rcx+358h]
L18:
    lea     rdi,[rsp+390h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,398h
    ret
L19:
    mov     rax,4000000000000000h
    mov     [rsp+40h],rax
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFCB0h
    mov     ecx,0FFFFFF90h
    call    ryo_h_DivUW64
    test    byte ptr [rsp+317h],0FFh
    je      L22
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+390h]
    lea     rsi,[sym12]
    lea     rdx,[site13]
    mov     ecx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L20
    call    rax
    nop     [rcx+48h]
    jmp     L21
L20:
    lea     rdi,[rsp+390h]
    lea     rsi,[ro+4]
    call    qword ptr [sym14]
L21:
    lea     rdi,[rsp+390h]
    call    ryo_h_Unreachable
    ud2
L22:
    mov     rax,4000000000000000h
    mov     [rsp+40h],rax
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFCB0h
    mov     ecx,0FFFFFF90h
    call    ryo_h_RemUW64
    cmp     qword ptr [rsp+308h],0
    jbe     L23
    mov     rdx,[rsp+318h]
    add     rdx,1
    mov     [rsp+328h],rdx
    jmp     L24
L23:
    mov     rax,[rsp+318h]
    mov     [rsp+328h],rax
L24:
    cmp     qword ptr [rsp+330h],1000h
    jbe     L3
    jmp     L4
L25:
    jmp     L7
L26:
    mov     rax,[rsp+370h]
    mov     [rsp],rax
    mov     rdx,[rsp+330h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+330h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC88h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+390h]
    lea     rsi,[sym16]
    lea     rdx,[site17]
    mov     ecx,0FFFFFCB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L27
    call    rax
    nop     [rcx+338h]
    jmp     L28
L27:
    lea     rdi,[rsp+390h]
    lea     rsi,[ro+36]
    call    qword ptr [sym18]
L28:
    lea     rdi,[rsp+390h]
    call    ryo_h_Unreachable
    ud2
L29:
    mov     rax,[rsp+330h]
    sub     rax,[rsp+370h]
    mov     rdx,[rsp+3A0h]
    mov     rsi,[rsp+3A8h]
    imul    rcx,[rsp+370h],8
    add     rdx,rcx
    mov     [rsp+98h],rdx
    mov     [rsp+0A0h],rax
    mov     rdi,[rsp+320h]
    mov     [rsp+90h],rdi
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    mov     edx,0FFFFFD08h
    call    ryo_h_MovW128
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC80h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+90h]
    mov     [rsp+20h],rax
    movzx   edx,byte ptr [rsp+3C0h]
    mov     [rsp+28h],dl
    mov     rsi,[rsp+3C8h]
    mov     [rsp+30h],rsi
    call    fn19
    nop     [rcx+378h]
    jmp     L9
L30:
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFFDFh
    mov     edx,0FFFFFD28h
    call    ryo_h_TruncW32W8
    jmp     L11
L31:
    mov     rax,[rsp+90h]
    mov     [rsp],rax
    mov     rdx,[rsp+360h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+330h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC88h
    lea     rdx,[k20]
    call    ryo_h_AddrAbs
    call    fn21
    nop     [rcx+338h]
L32:
    mov     rax,[rsp+360h]
    sub     rax,[rsp+90h]
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+90h],8
    add     rdx,rcx
    mov     [rsp+80h],rdx
    mov     [rsp+88h],rax
    mov     rsi,[rsp+358h]
    mov     [rsp+78h],rsi
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC70h
    mov     edx,0FFFFFCF0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+390h]
    mov     esi,0FFFFFC80h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+0A0h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+3C8h]
    mov     [rsp+30h],rsi
    call    fn22
    nop     [rcx+358h]
    jmp     L12

fn core::slice::sort::stable::drift::stable_quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,88h
    mov     rax,[rsp+98h]
    or      rax,1
    mov     [rsp+68h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC4h
    mov     edx,0FFFFFFE8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFC4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L0:
    .long   L3
    .long   L6
    .long   L2
    nop     [rax]
L1:
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret
L2:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L3:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+80h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFC0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+80h]
    jmp     L5
L4:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L5:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+68h]
    mov     [rsp+48h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC4h
    mov     edx,0FFFFFFC8h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+44h]
    mov     [rsp+54h],eax
    mov     dword ptr [rsp+44h],3Fh
    mov     esi,[rsp+44h]
    sub     esi,eax
    mov     dword ptr [rsp+44h],2
    mov     r8d,[rsp+44h]
    imul    r8d,esi
    mov     [rsp+78h],r8d
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     eax,[rsp+78h]
    mov     [rsp+28h],eax
    mov     qword ptr [rsp+20h],0
    mov     rsi,[rsp+0B0h]
    mov     [rsp+30h],rsi
    call    fn4
    nop     [rcx+80h]
    jmp     L1

fn core::slice::sort::stable::driftsort_main::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}, std::vec::Vec<(u32, u32)>>
    mov     eax,2098h
    call    ryo_probe_stack
    sub     rsp,2098h
    mov     byte ptr [rsp+2077h],0
    mov     qword ptr [rsp+48h],8
    cmp     qword ptr [rsp+48h],0
    sete    [rsp+208Fh]
    test    byte ptr [rsp+208Fh],0FFh
    je      L2
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDF70h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+2090h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFDFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+50h]
    jmp     L1
L0:
    lea     rdi,[rsp+2090h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+2090h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     qword ptr [rsp+48h],7A1200h
    mov     qword ptr [rsp+40h],8
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFB0h
    call    ryo_h_DivUW64
    mov     rax,[rsp+20A8h]
    mov     [rsp+2058h],rax
    mov     qword ptr [rsp+48h],2
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFDFB8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+2058h]
    sub     rax,[rsp+2038h]
    mov     [rsp+2040h],rax
    mov     rdx,[rsp+2058h]
    mov     [rsp],rdx
    mov     rsi,[rsp+2060h]
    mov     [rsp+8],rsi
    call    fn4
    nop     [rcx+2038h]
    jmp     L11
    nop     [rax]
L3:
    mov     rax,[rsp+2080h]
    mov     [rsp+1028h],rax
    cmp     rax,[rsp+2050h]
    jb      L4
    jmp     L5
L4:
    mov     rax,[rsp+2050h]
    mov     [rsp],rax
    call    fn5
    nop     [rcx+1018h]
    mov     byte ptr [rsp+2077h],1
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFEFA8h
    mov     edx,0FFFFEF88h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+1038h]
    mov     [rsp+1028h],rax
    mov     [rsp],rax
    call    fn6
    nop     [rcx+2078h]
L5:
    call    fn7
    nop     [rcx+1020h]
    imul    rax,[rsp+1020h],2
    mov     rdx,[rsp+2058h]
    cmp     rdx,rax
    setbe   [rsp+1037h]
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDF70h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDF80h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    movzx   eax,byte ptr [rsp+1037h]
    mov     [rsp+20h],al
    mov     rdx,[rsp+20B0h]
    mov     [rsp+28h],rdx
    call    fn8
    nop     [rcx+2078h]
    test    byte ptr [rsp+2077h],0FFh
    jne     L8
    nop     [rax]
L6:
    lea     rdi,[rsp+2090h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,2098h
    ret
    nop     [rax]
L7:
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
L8:
    lea     rax,[rsp+1038h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    call    fn9
    nop     [rcx+48h]
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L9:
    lea     rax,[rsp+1038h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    call    fn10
    nop     [rcx+48h]
    jmp     L7
    nop
L10:
    test    byte ptr [rsp+2077h],0FFh
    je      L7
    jmp     L9
L11:
    mov     rax,[rsp+2040h]
    mov     [rsp],rax
    mov     rdx,[rsp+2038h]
    mov     [rsp+8],rdx
    call    fn11
    nop     [rcx+2048h]
    mov     rax,[rsp+2048h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],30h
    call    fn12
    nop     [rcx+2050h]
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFC0h
    lea     rdx,[k13]
    mov     ecx,1
    call    ryo_h_Const
    lea     rax,[rsp+50h]
    mov     [rsp+48h],rax
    lea     rax,[rax+1]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],1
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+2]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],2
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+4]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],4
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+8]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],8
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+10h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],10h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+20h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],20h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+40h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],40h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+80h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],80h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+100h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],100h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+200h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],200h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+400h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],400h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+48h]
    lea     rax,[rax+800h]
    mov     [rsp+40h],rax
    mov     qword ptr [rsp+38h],800h
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFDFB0h
    mov     edx,0FFFFDFB8h
    mov     ecx,0FFFFDFA8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+2090h]
    mov     esi,0FFFFEFC0h
    mov     edx,0FFFFDFC0h
    mov     ecx,1000h
    call    ryo_h_Copy
    lea     rax,[rsp+1050h]
    mov     [rsp+1048h],rax
    mov     [rsp],rax
    call    fn14
    nop     [rcx+2078h]
    jmp     L3
    nop     [rax]
L12:
    lea     rdi,[rsp+2090h]
    lea     rsi,[sym15]
    lea     rdx,[site16]
    mov     ecx,0FFFFDFB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+50h]
    jmp     L14
L13:
    lea     rdi,[rsp+2090h]
    lea     rsi,[ro+4]
    call    qword ptr [sym17]
L14:
    lea     rdi,[rsp+2090h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+2090h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+2090h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_down::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,98h
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+10h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
    nop
L1:
    test    byte ptr [rsp+67h],0FFh
    je      L2
    mov     rdx,[rsp+88h]
    mov     [rsp+78h],rdx
    jmp     L3
L2:
    mov     rax,[rsp+80h]
    mov     [rsp+78h],rax
L3:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L17
    jmp     L16
    nop
L4:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+8]
    mov     [rsp+68h],rax
    cmp     rax,[rsp+0B0h]
    jne     L6
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L6:
    jmp     L0
    xchg    ax,ax
L7:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+8]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L12
    jmp     L11
L8:
    mov     rax,[rsp+60h]
    mov     [rsp+88h],rax
    jmp     L7
L9:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+88h],rdx
    jmp     L7
    nop
L10:
    mov     byte ptr [rsp+3Fh],0
    test    byte ptr [rsp+3Fh],0FFh
    je      L15
    jmp     L14
L11:
    mov     rax,[rsp+60h]
    mov     [rsp+80h],rax
    jmp     L10
L12:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+60h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+80h],rdx
    jmp     L10
    nop     [rax+rax]
    xchg    ax,ax
L13:
    mov     rax,[rsp+60h]
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+0C0h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+67h]
    jmp     L1
L14:
    mov     rax,[rsp+0B8h]
    mov     [rsp+60h],rax
    jmp     L13
L15:
    mov     qword ptr [rsp+38h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+0B8h]
    imul    rcx,[rsp+38h],8
    add     rdx,rcx
    mov     [rsp+60h],rdx
    jmp     L13
L16:
    mov     rax,[rsp+78h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+40h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+68h]
L17:
    mov     qword ptr [rsp+38h],1
    imul    rdx,[rsp+38h],8
    mov     [rsp+30h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFC8h
    mov     ecx,0FFFFFFA0h
    call    ryo_h_Memcpy
    movzx   eax,byte ptr [rsp+67h]
    xor     al,1
    mov     [rsp+66h],al
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD6h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+88h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+58h]
    mov     [rdx+10h],rcx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+80h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A0h]
    mov     rcx,[rsp+58h]
    mov     [rdx+8],rcx
    mov     rsi,[rsp+0A0h]
    mov     rsi,[rsi+10h]
    mov     [rsp+70h],rsi
    cmp     rsi,[rsp+0A8h]
    je      L5
    jmp     L4

fn core::slice::sort::stable::merge::MergeState::<(u32, u32)>::merge_up::<{closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0A8h
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     rdx,[rdx+8]
    mov     [rsp+58h],rdx
    cmp     rax,rdx
    je      L3
    mov     rsi,[rsp+0B8h]
    mov     [rsp+88h],rsi
    cmp     rsi,[rsp+0C0h]
    je      L3
    mov     rdi,[rsp+0B8h]
    mov     r8,[rsp+0B0h]
    mov     r8,[r8]
    mov     [rsp+58h],rdi
    mov     [rsp+60h],r8
    mov     r9,[rsp+0C8h]
    mov     [rsp],r9
    mov     [rsp+8],rdi
    mov     [rsp+10h],r8
    call    fn0
    nop     [rcx+87h]
    movzx   eax,byte ptr [rsp+87h]
    xor     al,1
    mov     [rsp+6Dh],al
    test    byte ptr [rsp+6Dh],0FFh
    je      L1
    mov     rsi,[rsp+0B0h]
    mov     rsi,[rsi]
    mov     [rsp+78h],rsi
    jmp     L2
L1:
    mov     rax,[rsp+0B8h]
    mov     [rsp+78h],rax
L2:
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+10h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L4
L3:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L4:
    mov     rax,[rsp+78h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+70h]
L5:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFCDh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+58h]
    imul    rcx,[rsp+50h],8
    add     rax,rcx
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp+60h]
    mov     [rdx],rcx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFE7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B8h]
    imul    rcx,[rsp+58h],8
    add     rax,rcx
    mov     [rsp+0B8h],rax
    mov     rdx,[rsp+0B0h]
    mov     rdx,[rdx+10h]
    mov     qword ptr [rsp+40h],1
    imul    rcx,[rsp+40h],8
    add     rdx,rcx
    mov     [rsp+60h],rdx
    mov     rdi,[rsp+0B0h]
    mov     rcx,[rsp+60h]
    mov     [rdi+10h],rcx
    jmp     L0

fn core::slice::sort::stable::merge::merge::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,0D8h
    mov     rax,[rsp+0E8h]
    mov     [rsp+88h],rax
    cmp     qword ptr [rsp+100h],0
    je      L0
    mov     rsi,[rsp+100h]
    cmp     rsi,rax
    jae     L0
    mov     rdi,[rsp+0F8h]
    mov     [rsp+78h],rdi
    sub     rax,rsi
    mov     [rsp+0C8h],rax
    mov     [rsp],rsi
    mov     [rsp+8],rax
    call    fn0
    nop     [rcx+70h]
    jmp     L11
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     rax,[rsp+0F0h]
    mov     [rsp+0A8h],rax
    mov     rdx,[rsp+0F8h]
    mov     [rsp+0B0h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+80h],rsi
    mov     rdi,[rsp+0E0h]
    mov     [rsp+98h],rdi
    mov     r8,[rsp+0E8h]
    mov     [rsp+0A0h],r8
    mov     [rsp+0C0h],rdi
    imul    rcx,[rsp+100h],8
    add     rdi,rcx
    mov     [rsp+78h],rdi
    mov     r9,[rsp+0C0h]
    imul    rcx,[rsp+88h],8
    add     r9,rcx
    mov     [rsp+70h],r9
    mov     r10,[rsp+100h]
    cmp     r10,[rsp+0C8h]
    setbe   [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L2
    jmp     L3
L2:
    mov     rax,[rsp+78h]
    mov     [rsp+0C0h],rax
L3:
    test    byte ptr [rsp+6Fh],0FFh
    je      L4
    jmp     L5
L4:
    mov     rax,[rsp+0C8h]
    mov     [rsp+100h],rax
L5:
    mov     rax,[rsp+0C0h]
    mov     [rsp+0B8h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+100h]
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L13
    jmp     L12
    nop     [rax]
L6:
    lea     rax,[rsp+50h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+38h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+108h]
    mov     [rsp+18h],rdi
    call    fn1
    nop     [rcx+0B8h]
    jmp     L8
    nop     [rax+rax]
L7:
    lea     rax,[rsp+50h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+38h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    mov     r8,[rsp+108h]
    mov     [rsp+20h],r8
    call    fn2
    nop     [rcx+0B8h]
L8:
    lea     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     [rsp],rax
    call    fn3
    nop     [rcx+30h]
L9:
    lea     rdi,[rsp+0D0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0D8h
    ret
    nop     [rax+rax]
L10:
    lea     rax,[rsp+50h]
    mov     [rsp+30h],rax
    mov     [rsp],rax
    call    fn4
    nop     [rcx+30h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFC0h
    call    ryo_h_Resume
    ud2
L11:
    mov     rax,[rsp+78h]
    cmp     rax,[rsp+70h]
    jb      L0
    jmp     L1
L12:
    mov     rax,[rsp+0B8h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+58h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+98h]
L13:
    imul    rax,[rsp+58h],8
    mov     [rsp+30h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFF60h
    call    ryo_h_Memcpy
    mov     rax,[rsp+80h]
    imul    rcx,[rsp+100h],8
    add     rax,rcx
    mov     rdx,[rsp+80h]
    mov     [rsp+50h],rdx
    mov     [rsp+58h],rax
    mov     rsi,[rsp+0C0h]
    mov     [rsp+60h],rsi
    test    byte ptr [rsp+6Fh],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF60h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx+38h]
    jmp     L16
L15:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L16:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC0h
    call    ryo_h_Lpad
    jmp     L14

fn core::slice::sort::stable::quicksort::PartitionState::<(u32, u32)>::partition_one
    sub     rsp,78h
    mov     rax,[rsp+80h]
    mov     rax,[rax+18h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
L0:
    mov     rax,[rsp+80h]
    mov     rax,[rax]
    mov     [rsp+60h],rax
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     rax,[rsp+80h]
    mov     rax,[rax+18h]
    mov     [rsp+60h],rax
L2:
    mov     rax,[rsp+80h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+60h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi+8]
    mov     [rsp+58h],rsi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L7
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rsp+80h]
    mov     rcx,[rsp+58h]
    mov     [rax+18h],rcx
    test    byte ptr [rsp+88h],0FFh
    je      L1
    jmp     L0
L4:
    mov     rax,[rsp+50h]
    mov     [rsp+58h],rax
    jmp     L3
L5:
    mov     qword ptr [rsp+40h],0FFFFFFFFFFFFFFFFh
    mov     rdx,[rsp+50h]
    imul    rcx,[rsp+40h],8
    add     rdx,rcx
    mov     [rsp+58h],rdx
    jmp     L3
L6:
    mov     rax,[rsp+58h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+60h]
L7:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFC8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+80h]
    mov     rax,[rax+10h]
    add     rax,[rsp+58h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+80h]
    mov     rcx,[rsp+30h]
    mov     [rdx+10h],rcx
    mov     rsi,[rsp+80h]
    mov     rsi,[rsi+8]
    mov     qword ptr [rsp+40h],1
    imul    rcx,[rsp+40h],8
    add     rsi,rcx
    mov     [rsp+58h],rsi
    mov     r8,[rsp+80h]
    mov     rcx,[rsp+58h]
    mov     [r8+8],rcx
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,118h
    nop     [rax+rax]
L0:
    mov     rax,[rsp+120h]
    mov     rdx,[rsp+128h]
    mov     [rsp+98h],rdx
    call    fn0
    nop     [rcx+90h]
    mov     rax,[rsp+90h]
    cmp     rax,[rsp+98h]
    jb      L1
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+150h]
    mov     [rsp+20h],rax
    call    fn1
    nop     [rcx+110h]
    jmp     L15
L1:
    mov     eax,[rsp+148h]
    mov     [rsp+0A0h],eax
    cmp     eax,0
    jne     L2
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+20h],1
    mov     rdx,[rsp+150h]
    mov     [rsp+28h],rdx
    call    fn2
    nop     [rcx+110h]
    jmp     L3
L2:
    mov     eax,[rsp+148h]
    sub     eax,1
    mov     [rsp+148h],eax
    mov     rdx,[rsp+120h]
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+128h]
    mov     [rsp+88h],rsi
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    mov     rax,[rsp+150h]
    mov     [rsp+10h],rax
    call    fn3
    nop     [rcx+90h]
    jmp     L4
L3:
    jmp     L15
L4:
    mov     rax,[rsp+120h]
    mov     rdx,[rsp+128h]
    mov     [rsp+0F8h],rdx
    mov     rsi,[rsp+90h]
    cmp     rsi,rdx
    jb      L7
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+110h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+40h]
    jmp     L6
L5:
    lea     rdi,[rsp+110h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L6:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+120h]
    imul    rcx,[rsp+90h],8
    add     rax,rcx
    mov     rax,[rax]
    mov     [rsp+88h],rax
    call    fn8
    nop     [rcx+0A7h]
    jmp     L16
L8:
    mov     rax,[rsp+140h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+120h]
    mov     rsi,[rsp+128h]
    mov     [rsp+0B8h],rsi
    mov     rdi,[rsp+90h]
    cmp     rdi,rsi
    jb      L11
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+110h]
    lea     rsi,[sym10]
    lea     rdx,[site11]
    mov     ecx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L9
    call    rax
    nop     [rcx+40h]
    jmp     L10
L9:
    lea     rdi,[rsp+110h]
    lea     rsi,[ro+4]
    call    qword ptr [sym12]
L10:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
L11:
    mov     rax,[rsp+120h]
    imul    rcx,[rsp+90h],8
    add     rax,rcx
    mov     rdx,[rsp+80h]
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    mov     rsi,[rsp+150h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rax
    call    fn13
    nop     [rcx+0A6h]
    movzx   eax,byte ptr [rsp+0A6h]
    xor     al,1
    mov     [rsp+0DFh],al
    mov     qword ptr [rsp+0A8h],0
    movzx   esi,byte ptr [rsp+0DFh]
    mov     [rsp+0A6h],sil
    test    byte ptr [rsp+0A6h],0FFh
    jne     L13
    nop     [rax+rax]
    xchg    ax,ax
L12:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF68h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF68h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+90h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+28h],0
    mov     rsi,[rsp+150h]
    mov     [rsp+30h],rsi
    call    fn14
    nop     [rcx+0A8h]
    mov     rax,[rsp+0A8h]
    cmp     rax,0
    sete    [rsp+0DFh]
L13:
    test    byte ptr [rsp+0DFh],0FFh
    je      L14
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF60h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+150h]
    mov     [rsp+60h],rax
    lea     rdx,[rsp+60h]
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF60h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     rax,[rsp+90h]
    mov     [rsp+20h],rax
    mov     byte ptr [rsp+28h],1
    mov     rsi,[rsp+68h]
    mov     [rsp+30h],rsi
    call    fn15
    nop     [rcx+80h]
    mov     rax,[rsp+128h]
    mov     [rsp+78h],rax
    cmp     rax,[rsp+80h]
    jb      L21
    jmp     L24
L14:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+0A8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF08h
    lea     rdx,[k16]
    call    ryo_h_AddrAbs
    call    fn17
    nop     [rcx+58h]
    lea     rdi,[rsp+110h]
    mov     esi,10h
    mov     edx,0FFFFFF48h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF58h
    call    ryo_h_MovW128
    mov     eax,[rsp+148h]
    mov     [rsp+0A0h],eax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF68h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    mov     edx,20h
    call    ryo_h_MovW128
    mov     eax,[rsp+0A0h]
    mov     [rsp+28h],eax
    mov     rdx,[rsp+0E8h]
    mov     [rsp+20h],rdx
    mov     rsi,[rsp+150h]
    mov     [rsp+30h],rsi
    call    fn18
    nop     [rcx+0A8h]
    jmp     L0
L15:
    lea     rdi,[rsp+110h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,118h
    ret
L16:
    lea     rax,[rsp+88h]
    mov     [rsp+80h],rax
    test    byte ptr [rsp+0A7h],0FFh
    je      L20
    jmp     L19
    nop     [rax+rax]
L17:
    mov     byte ptr [rsp+0DFh],0
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF2Ch
    mov     edx,30h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF2Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L18]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L18:
    .long   L26
    .long   L8
    .long   L25
L19:
    mov     rax,[rsp+80h]
    mov     [rsp+0E8h],rax
    jmp     L17
L20:
    mov     qword ptr [rsp+0E8h],0
    jmp     L17
L21:
    mov     rax,[rsp+80h]
    mov     [rsp],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF08h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+110h]
    lea     rsi,[sym20]
    lea     rdx,[site21]
    mov     ecx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L22
    call    rax
    nop     [rcx+0A7h]
    jmp     L23
L22:
    lea     rdi,[rsp+110h]
    lea     rsi,[ro+20]
    call    qword ptr [sym22]
L23:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
L24:
    mov     rax,[rsp+78h]
    sub     rax,[rsp+80h]
    mov     rdx,[rsp+120h]
    mov     rsi,[rsp+128h]
    imul    rcx,[rsp+80h],8
    add     rdx,rcx
    mov     [rsp+120h],rdx
    mov     [rsp+128h],rax
    mov     qword ptr [rsp+140h],0
    jmp     L0
L25:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
L26:
    mov     qword ptr [rsp+0A8h],0
    jmp     L12

fn core::slice::sort::stable::quicksort::quicksort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    xor     al,1
    mov     [rsp+3Fh],al
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@core::slice::sort::stable::quicksort::quicksort<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>::{closure#0}}>
    sub     rsp,158h
    mov     rax,[rsp+168h]
    mov     [rsp+0C0h],rax
    mov     rdx,[rsp+178h]
    mov     [rsp+0B0h],rdx
    cmp     rdx,rax
    jae     L0
    mov     byte ptr [rsp+0BFh],1
    jmp     L10
L0:
    mov     rax,[rsp+0C0h]
    cmp     rax,[rsp+180h]
    setbe   [rsp+0BFh]
    test    byte ptr [rsp+0BFh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L1:
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L3
    mov     rsi,[rsp+180h]
    mov     [rsp+70h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+150h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+80h]
    jae     L3
    lea     rdx,[rsp+88h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+0A8h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+190h]
    mov     [rsp],r8
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn1
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn2
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn3
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn4
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn5
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn6
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn7
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn8
    nop     [rcx+70h]
    jmp     L2
L3:
    mov     rax,[rsp+180h]
    mov     rdx,[rsp+0B8h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+80h],rdx
    nop     [rax+rax]
L4:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+80h]
    jae     L5
    lea     rdx,[rsp+88h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+0A8h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+190h]
    mov     [rsp],r8
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn9
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn10
    nop     [rcx+70h]
    jmp     L4
L5:
    mov     rax,[rsp+180h]
    cmp     rax,[rsp+0C0h]
    jne     L6
    call    fn11
    nop     [rcx+86h]
    jmp     L13
L6:
    lea     rax,[rsp+88h]
    mov     [rsp+78h],rax
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+188h]
    mov     [rsp+8],dl
    call    fn12
    nop     [rcx+140h]
    mov     rax,[rsp+0C0h]
    mov     [rsp+180h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
    xchg    ax,ax
L8:
    mov     rax,[rsp+160h]
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+168h]
    mov     [rsp+0E0h],rdx
    mov     [rsp+80h],rax
    mov     rsi,[rsp+0E8h]
    mov     [rsp+78h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+70h],rdi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L9:
    mov     rax,[rsp+130h]
    mov     rdx,[rsp+138h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L19
    jmp     L18
L10:
    lea     rdi,[rsp+150h]
    call    ryo_h_Abort
    ud2
L11:
    mov     rax,[rsp+160h]
    mov     rdx,[rsp+168h]
    mov     [rsp+0B8h],rax
    mov     rsi,[rsp+170h]
    mov     [rsp+0E8h],rsi
    mov     rdi,[rsp+178h]
    mov     [rsp+0F0h],rdi
    mov     r8,[rsp+0E8h]
    mov     [rsp+0B0h],r8
    imul    rcx,[rsp+180h],8
    add     rax,rcx
    mov     [rsp+0A8h],rax
    imul    rcx,[rsp+0C0h],8
    add     r8,rcx
    mov     r9,[rsp+0B0h]
    mov     [rsp+88h],r9
    mov     r10,[rsp+0B8h]
    mov     [rsp+90h],r10
    mov     qword ptr [rsp+98h],0
    mov     [rsp+0A0h],r8
    mov     qword ptr [rsp+140h],0
    jmp     L1
L12:
    mov     rax,[rsp+0B8h]
    imul    rcx,[rsp+78h],8
    add     rax,rcx
    mov     [rsp+80h],rax
    jmp     L2
L13:
    movzx   eax,byte ptr [rsp+86h]
    xor     al,1
    mov     [rsp+87h],al
    test    byte ptr [rsp+87h],0FFh
    je      L8
    jmp     L7
L14:
    mov     rax,[rsp+0A8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+70h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+0E8h]
L15:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFF58h
    mov     ecx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L8
L16:
    mov     rax,[rsp+0E8h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+60h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+70h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+0D8h]
L17:
    imul    rax,[rsp+70h],8
    mov     [rsp+40h],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF28h
    mov     ecx,0FFFFFEF0h
    call    ryo_h_Memcpy
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0C0h]
    sub     rdx,rax
    mov     qword ptr [rsp+130h],0
    mov     [rsp+138h],rdx
    jmp     L9
L18:
    mov     rax,[rsp+130h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L21
    jmp     L20
L19:
    mov     rax,[rsp+98h]
    mov     [rsp+148h],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,158h
    ret
L20:
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx+0C8h]
L21:
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+130h],rax
    mov     rdx,[rsp+60h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+0C0h]
    sub     rdi,1
    sub     rdi,rdx
    mov     r8,[rsp+0B0h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+120h],r8
    mov     [rsp+60h],r8
    mov     r9,[rsp+98h]
    add     r9,rdx
    mov     r10,[rsp+80h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+58h],r10
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L22
    mov     rdi,[rsp+120h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],r10
    mov     [rsp],rdi
    mov     [rsp+8],r10
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx+0C8h]
L22:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF10h
    mov     ecx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L9

fn core::slice::sort::stable::quicksort::stable_partition::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,158h
    mov     rax,[rsp+168h]
    mov     [rsp+0C0h],rax
    mov     rdx,[rsp+178h]
    mov     [rsp+0B0h],rdx
    cmp     rdx,rax
    jae     L0
    mov     byte ptr [rsp+0BFh],1
    jmp     L10
L0:
    mov     rax,[rsp+0C0h]
    cmp     rax,[rsp+180h]
    setbe   [rsp+0BFh]
    test    byte ptr [rsp+0BFh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L1:
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L3
    mov     rsi,[rsp+180h]
    mov     [rsp+70h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],3
    lea     rdi,[rsp+150h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    jmp     L12
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+80h]
    jae     L3
    lea     rdx,[rsp+88h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+0A8h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+190h]
    mov     [rsp],r8
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn1
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn2
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn3
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn4
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn5
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn6
    nop     [rcx+70h]
    lea     rax,[rsp+88h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+58h],rdx
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+190h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn7
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn8
    nop     [rcx+70h]
    jmp     L2
L3:
    mov     rax,[rsp+180h]
    mov     rdx,[rsp+0B8h]
    imul    rcx,rax,8
    add     rdx,rcx
    mov     [rsp+80h],rdx
    nop     [rax+rax]
L4:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    cmp     rax,[rsp+80h]
    jae     L5
    lea     rdx,[rsp+88h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+0A8h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     r8,[rsp+190h]
    mov     [rsp],r8
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn9
    nop     [rcx+7Eh]
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+7Eh]
    mov     [rsp+8],dl
    call    fn10
    nop     [rcx+70h]
    jmp     L4
L5:
    mov     rax,[rsp+180h]
    cmp     rax,[rsp+0C0h]
    jne     L6
    call    fn11
    nop     [rcx+86h]
    jmp     L13
L6:
    lea     rax,[rsp+88h]
    mov     [rsp+78h],rax
    mov     [rsp],rax
    movzx   edx,byte ptr [rsp+188h]
    mov     [rsp+8],dl
    call    fn12
    nop     [rcx+140h]
    mov     rax,[rsp+0C0h]
    mov     [rsp+180h],rax
    jmp     L1
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L15
    jmp     L14
    nop     [rax+rax]
    xchg    ax,ax
L8:
    mov     rax,[rsp+160h]
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+168h]
    mov     [rsp+0E0h],rdx
    mov     [rsp+80h],rax
    mov     rsi,[rsp+0E8h]
    mov     [rsp+78h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+70h],rdi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L17
    jmp     L16
    nop     [rax+rax]
L9:
    mov     rax,[rsp+130h]
    mov     rdx,[rsp+138h]
    cmp     rax,rdx
    setb    [rsp+6Fh]
    test    byte ptr [rsp+6Fh],0FFh
    je      L19
    jmp     L18
L10:
    lea     rdi,[rsp+150h]
    call    ryo_h_Abort
    ud2
L11:
    mov     rax,[rsp+160h]
    mov     rdx,[rsp+168h]
    mov     [rsp+0B8h],rax
    mov     rsi,[rsp+170h]
    mov     [rsp+0E8h],rsi
    mov     rdi,[rsp+178h]
    mov     [rsp+0F0h],rdi
    mov     r8,[rsp+0E8h]
    mov     [rsp+0B0h],r8
    imul    rcx,[rsp+180h],8
    add     rax,rcx
    mov     [rsp+0A8h],rax
    imul    rcx,[rsp+0C0h],8
    add     r8,rcx
    mov     r9,[rsp+0B0h]
    mov     [rsp+88h],r9
    mov     r10,[rsp+0B8h]
    mov     [rsp+90h],r10
    mov     qword ptr [rsp+98h],0
    mov     [rsp+0A0h],r8
    mov     qword ptr [rsp+140h],0
    jmp     L1
L12:
    mov     rax,[rsp+0B8h]
    imul    rcx,[rsp+78h],8
    add     rax,rcx
    mov     [rsp+80h],rax
    jmp     L2
L13:
    movzx   eax,byte ptr [rsp+86h]
    xor     al,1
    mov     [rsp+87h],al
    test    byte ptr [rsp+87h],0FFh
    je      L8
    jmp     L7
L14:
    mov     rax,[rsp+0A8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+140h]
    mov     [rsp+70h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+0E8h]
L15:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFF58h
    mov     ecx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L8
L16:
    mov     rax,[rsp+0E8h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+60h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+70h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    call    fn16
    nop     [rcx+0D8h]
L17:
    imul    rax,[rsp+70h],8
    mov     [rsp+40h],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF28h
    mov     ecx,0FFFFFEF0h
    call    ryo_h_Memcpy
    mov     rax,[rsp+98h]
    mov     rdx,[rsp+0C0h]
    sub     rdx,rax
    mov     qword ptr [rsp+130h],0
    mov     [rsp+138h],rdx
    jmp     L9
L18:
    mov     rax,[rsp+130h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L21
    jmp     L20
L19:
    mov     rax,[rsp+98h]
    mov     [rsp+148h],rax
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,158h
    ret
L20:
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFEC0h
    lea     rdx,[k17]
    call    ryo_h_AddrAbs
    call    fn18
    nop     [rcx+0C8h]
L21:
    mov     rax,[rsp+60h]
    add     rax,1
    mov     [rsp+130h],rax
    mov     rdx,[rsp+60h]
    mov     qword ptr [rsp+70h],1
    mov     [rsp+68h],rdx
    mov     rdi,[rsp+0C0h]
    sub     rdi,1
    sub     rdi,rdx
    mov     r8,[rsp+0B0h]
    imul    rcx,rdi,8
    add     r8,rcx
    mov     [rsp+120h],r8
    mov     [rsp+60h],r8
    mov     r9,[rsp+98h]
    add     r9,rdx
    mov     r10,[rsp+80h]
    imul    rcx,r9,8
    add     r10,rcx
    mov     [rsp+58h],r10
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L22
    mov     rdi,[rsp+120h]
    mov     [rsp+50h],rdi
    mov     [rsp+48h],r10
    mov     [rsp],rdi
    mov     [rsp+8],r10
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFED8h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx+0C8h]
L22:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],8
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+150h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF10h
    mov     ecx,0FFFFFEE8h
    call    ryo_h_Memcpy
    jmp     L9

fn core::slice::sort::unstable::heapsort::heapsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0D8h
    mov     rax,[rsp+0E8h]
    mov     [rsp+88h],rax
    mov     qword ptr [rsp+28h],2
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFFB8h
    mov     ecx,0FFFFFF58h
    call    ryo_h_DivUW64
    mov     rax,[rsp+88h]
    add     rax,[rsp+68h]
    mov     qword ptr [rsp+78h],0
    mov     [rsp+80h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFA8h
    call    ryo_h_MovW128
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0C8h]
    cmp     rax,rdx
    setb    [rsp+77h]
    test    byte ptr [rsp+77h],0FFh
    je      L8
    jmp     L7
    nop     [rax+rax]
L1:
    mov     rax,[rsp+70h]
    sub     rax,[rsp+88h]
    mov     [rsp+0B0h],rax
    jmp     L5
    nop     [rax+rax]
L2:
    mov     qword ptr [rsp+28h],0
    mov     rdx,[rsp+28h]
    cmp     rdx,[rsp+88h]
    setb    [rsp+6Eh]
    test    byte ptr [rsp+6Eh],0FFh
    jne     L12
    mov     qword ptr [rsp],0
    mov     r8,[rsp+88h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+30h]
    jmp     L4
L3:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L4:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L5:
    mov     rax,[rsp+70h]
    mov     [rsp],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+8],rdx
    call    fn4
    nop     [rcx+0A8h]
    jmp     L16
    nop     [rax+rax]
L6:
    jmp     L0
L7:
    mov     rax,[rsp+0C8h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L10
    jmp     L9
L8:
    lea     rdi,[rsp+0D0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0D8h
    ret
L9:
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx+90h]
L10:
    mov     rax,[rsp+60h]
    sub     rax,1
    mov     [rsp+0C8h],rax
    mov     qword ptr [rsp+78h],1
    mov     [rsp+70h],rax
    cmp     rax,[rsp+88h]
    jae     L1
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    mov     qword ptr [rsp+0B0h],0
    jmp     L5
L12:
    mov     rax,[rsp+70h]
    cmp     rax,[rsp+88h]
    jb      L15
    mov     [rsp],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+8],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+30h]
    jmp     L14
L13:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym10]
L14:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L15:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+90h]
    jmp     L11
L16:
    cmp     qword ptr [rsp+0A8h],0
    jb      L21
    jmp     L22
    nop     [rax+rax]
    nop
L17:
    mov     rax,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     rsi,[rsp+0A8h]
    mov     [rsp+60h],rax
    mov     [rsp+68h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    mov     rax,[rsp+0B0h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0F0h]
    mov     [rsp+18h],rdx
    call    fn13
    nop     [rcx+0B0h]
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L18:
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+0A8h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k14]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym15]
    lea     rdx,[site16]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L19
    call    rax
    nop     [rcx+90h]
    jmp     L20
L19:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym17]
L20:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L21:
    jmp     L18
L22:
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+0A8h]
    jae     L17
    jmp     L18

fn core::slice::sort::unstable::heapsort::sift_down::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0A8h
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0B8h]
    mov     [rsp+98h],rdx
    cmp     rax,rdx
    setbe   [rsp+8Fh]
    mov     rsi,[rsp+0B0h]
    mov     rdi,[rsp+0B8h]
    mov     [rsp+88h],rsi
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0C0h]
    mov     qword ptr [rsp+30h],2
    mov     rsi,[rsp+30h]
    imul    rsi,rax
    add     rsi,1
    mov     [rsp+90h],rsi
    mov     [rsp+78h],rsi
    cmp     rsi,[rsp+98h]
    jb      L1
    jmp     L5
L1:
    mov     rax,[rsp+90h]
    add     rax,1
    mov     [rsp+78h],rax
    cmp     rax,[rsp+98h]
    jae     L2
    mov     rdx,[rsp+90h]
    mov     rsi,[rsp+88h]
    imul    rcx,rdx,4
    add     rsi,rcx
    mov     rdi,[rsp+90h]
    add     rdi,1
    mov     r8,[rsp+88h]
    imul    rcx,rdi,4
    add     r8,rcx
    mov     [rsp+68h],rsi
    mov     [rsp+70h],r8
    mov     r9,[rsp+0C8h]
    mov     [rsp],r9
    mov     [rsp+8],rsi
    mov     [rsp+10h],r8
    call    fn0
    nop     [rcx+86h]
    jmp     L3
L2:
    jmp     L4
L3:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE6h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+90h]
    add     rax,[rsp+78h]
    mov     [rsp+90h],rax
L4:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+88h]
    imul    rcx,rax,4
    add     rdx,rcx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+88h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rdi
    mov     r8,[rsp+0C8h]
    mov     [rsp],r8
    mov     [rsp+8],rdx
    mov     [rsp+10h],rdi
    call    fn1
    nop     [rcx+87h]
    test    byte ptr [rsp+87h],0FFh
    je      L5
    mov     rdx,[rsp+88h]
    imul    rcx,[rsp+0C0h],4
    add     rdx,rcx
    mov     [rsp+80h],rdx
    mov     rsi,[rsp+90h]
    mov     rdi,[rsp+88h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+78h],rdi
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L7
    jmp     L6
L5:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+68h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+90h]
L7:
    mov     rax,[rsp+80h]
    mov     [rsp+68h],rax
    mov     qword ptr [rsp+70h],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    imul    rax,[rsp+58h],4
    mov     [rsp+60h],rax
    jmp     L10
L8:
    mov     rax,[rsp+58h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+38h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    call    fn4
    nop     [rcx+90h]
    jmp     L9
L9:
    mov     rax,[rsp+90h]
    mov     [rsp+0C0h],rax
    jmp     L0
L10:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF94h
    mov     edx,0FFFFFFB8h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFF94h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFA8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L11]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L11:
    .long   L9
    .long   L8
    .long   L12
L12:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::sort::unstable::ipnsort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,88h
    mov     rax,[rsp+98h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rsp+0A0h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+58h]
    mov     rax,[rsp+58h]
    mov     [rsp+68h],rax
    movzx   edx,byte ptr [rsp+60h]
    mov     [rsp+7Bh],dl
    cmp     rax,[rsp+70h]
    setbe   [rsp+7Ah]
    cmp     rax,[rsp+70h]
    jne     L1
    test    byte ptr [rsp+7Bh],0FFh
    je      L0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn1
    nop     [rcx+80h]
L0:
    jmp     L3
L1:
    mov     rax,[rsp+70h]
    or      rax,1
    mov     [rsp+50h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB4h
    mov     edx,0FFFFFFD0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFB4h
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L2]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L2:
    .long   L5
    .long   L8
    .long   L4
    nop     [rax+rax]
    nop     [rax]
L3:
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret
L4:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L5:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+80h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFFB0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+80h]
    jmp     L7
L6:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L7:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rsp+50h]
    mov     [rsp+38h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFB4h
    mov     edx,0FFFFFFB8h
    call    ryo_h_CtlzW64
    mov     eax,[rsp+34h]
    mov     [rsp+60h],eax
    mov     dword ptr [rsp+34h],3Fh
    mov     esi,[rsp+34h]
    sub     esi,eax
    mov     dword ptr [rsp+34h],2
    mov     r8d,[rsp+34h]
    imul    r8d,esi
    mov     [rsp+64h],r8d
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     edx,[rsp+64h]
    mov     [rsp+18h],edx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+20h],rsi
    call    fn6
    nop     [rcx+80h]
    jmp     L3

fn core::slice::sort::unstable::quicksort::partition::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    cmp     rax,0
    jne     L0
    mov     qword ptr [rsp+88h],0
    jmp     L8
L0:
    mov     rax,[rsp+0B0h]
    cmp     rax,[rsp+70h]
    jb      L1
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+88h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+30h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rsp+68h]
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+28h],0
    mov     rsi,[rsp+28h]
    cmp     rsi,rax
    setb    [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    jne     L4
    mov     qword ptr [rsp],0
    mov     [rsp+8],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+90h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+30h]
    jmp     L3
L2:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L3:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[sym8]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[site9]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+88h]
    jmp     L6
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L6:
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+70h]
    jb      L7
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+88h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+7Fh]
L8:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::unstable::quicksort::partition::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    mov     [rsp+70h],rax
    cmp     rax,0
    jne     L0
    mov     qword ptr [rsp+88h],0
    jmp     L8
L0:
    mov     rax,[rsp+0B0h]
    cmp     rax,[rsp+70h]
    jb      L1
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+88h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+30h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rsp+68h]
    mov     [rsp+80h],rax
    mov     qword ptr [rsp+28h],0
    mov     rsi,[rsp+28h]
    cmp     rsi,rax
    setb    [rsp+7Fh]
    test    byte ptr [rsp+7Fh],0FFh
    jne     L4
    mov     qword ptr [rsp],0
    mov     [rsp+8],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+90h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+30h]
    jmp     L3
L2:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L3:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rsp+60h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[sym8]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rsp+40h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[site9]
    call    ryo_h_CallInd
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+88h]
    jmp     L6
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L6:
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+70h]
    jb      L7
    lea     rdi,[rsp+90h]
    call    ryo_h_Abort
    ud2
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    mov     rdx,[rsp+88h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+7Fh]
L8:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0C8h
    mov     rax,[rsp+0D8h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0A8h],rsi
    mov     [rsp+88h],rdx
    cmp     rax,0
    jne     L0
    mov     qword ptr [rsp+0B8h],0
    jmp     L9
L0:
    lea     rax,[rsp+88h]
    mov     rdx,[rsp+0E8h]
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+0E0h]
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rax
    mov     rdi,[rsp+0A0h]
    mov     edi,[rdi]
    mov     [rsp+6Ch],edi
    mov     qword ptr [rsp+18h],1
    mov     r9,[rsp+88h]
    imul    rcx,[rsp+18h],4
    add     r9,rcx
    mov     [rsp+40h],r9
    lea     r10,[rsp+6Ch]
    mov     r11,[rsp+88h]
    mov     [rsp+30h],r11
    mov     [rsp+38h],r10
    mov     [rsp+58h],r9
    mov     qword ptr [rsp+60h],0
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+18h],2
    mov     rdx,[rsp+18h]
    sub     rdx,1
    mov     rsi,[rsp+90h]
    sub     rsi,rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+40h],rdi
    nop     [rax+rax]
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+40h]
    jae     L4
    mov     qword ptr [rsp+18h],2
    cmp     qword ptr [rsp+18h],2
    sete    [rsp+6Ah]
    test    byte ptr [rsp+6Ah],0FFh
    je      L2
    lea     r8,[rsp+70h]
    mov     [rsp+38h],r8
    lea     r9,[rsp+48h]
    mov     [rsp+30h],r9
    mov     [rsp],r8
    mov     [rsp+8],r9
    call    fn0
    nop     [rcx+0B0h]
    lea     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+0B0h]
    jmp     L3
L2:
    lea     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn2
    nop     [rcx+0B0h]
L3:
    jmp     L1
L4:
    mov     rax,[rsp+88h]
    imul    rcx,[rsp+90h],4
    add     rax,rcx
    mov     [rsp+38h],rax
    nop     [rax+rax]
L5:
    mov     rax,[rsp+58h]
    cmp     rax,[rsp+38h]
    sete    [rsp+6Bh]
    test    byte ptr [rsp+6Bh],0FFh
    je      L6
    mov     rsi,[rsp+50h]
    mov     [rsp+30h],rsi
    jmp     L7
L6:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+58h],rax
    lea     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    lea     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn3
    nop     [rcx+0B0h]
    test    byte ptr [rsp+6Bh],0FFh
    je      L8
    mov     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+0B8h],rdi
    jmp     L9
L8:
    jmp     L5
L9:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
    nop     [rax]
L10:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    lea     rax,[rsp+48h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn4
    nop     [rcx+18h]
    jmp     L10
    nop     [rax]
L12:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+20h]
    jmp     L14
L13:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L14:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,0A8h
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+10h]
    mov     rsi,[rsp+0B0h]
    mov     rsi,[rsi+8]
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+77h]
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+10h]
    mov     rax,[rax]
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+18h]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rsp+68h],rax
    mov     [rsp+60h],rax
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi]
    mov     [rsp+58h],rsi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L2
    mov     byte ptr [rsp+76h],1
    jmp     L3
L2:
    mov     byte ptr [rsp+76h],0
L3:
    mov     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    movzx   edi,byte ptr [rsp+76h]
    mov     [rsp+18h],dil
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+78h]
L4:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+78h]
L6:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+60h]
    mov     [rdx],rcx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+18h]
    add     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+30h]
    mov     [rdx+18h],rcx
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi+10h]
    mov     qword ptr [rsp+40h],1
    imul    rcx,[rsp+40h],4
    add     rsi,rcx
    mov     [rsp+60h],rsi
    mov     r8,[rsp+0B8h]
    mov     rcx,[rsp+60h]
    mov     [r8+10h],rcx
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>
    sub     rsp,0C8h
    mov     rax,[rsp+0D8h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0D0h]
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+0D8h]
    mov     [rsp+0A8h],rsi
    mov     [rsp+88h],rdx
    cmp     rax,0
    jne     L0
    mov     qword ptr [rsp+0B8h],0
    jmp     L9
L0:
    lea     rax,[rsp+88h]
    mov     rdx,[rsp+0E8h]
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+0E0h]
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rax
    mov     rdi,[rsp+0A0h]
    mov     edi,[rdi]
    mov     [rsp+6Ch],edi
    mov     qword ptr [rsp+18h],1
    mov     r9,[rsp+88h]
    imul    rcx,[rsp+18h],4
    add     r9,rcx
    mov     [rsp+40h],r9
    lea     r10,[rsp+6Ch]
    mov     r11,[rsp+88h]
    mov     [rsp+30h],r11
    mov     [rsp+38h],r10
    mov     [rsp+58h],r9
    mov     qword ptr [rsp+60h],0
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+18h],2
    mov     rdx,[rsp+18h]
    sub     rdx,1
    mov     rsi,[rsp+90h]
    sub     rsi,rdx
    mov     rdi,[rsp+88h]
    imul    rcx,rsi,4
    add     rdi,rcx
    mov     [rsp+40h],rdi
    nop     [rax+rax]
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    cmp     rax,[rsp+40h]
    jae     L4
    mov     qword ptr [rsp+18h],2
    cmp     qword ptr [rsp+18h],2
    sete    [rsp+6Ah]
    test    byte ptr [rsp+6Ah],0FFh
    je      L2
    lea     r8,[rsp+70h]
    mov     [rsp+38h],r8
    lea     r9,[rsp+48h]
    mov     [rsp+30h],r9
    mov     [rsp],r8
    mov     [rsp+8],r9
    call    fn0
    nop     [rcx+0B0h]
    lea     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+0B0h]
    jmp     L3
L2:
    lea     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn2
    nop     [rcx+0B0h]
L3:
    jmp     L1
L4:
    mov     rax,[rsp+88h]
    imul    rcx,[rsp+90h],4
    add     rax,rcx
    mov     [rsp+38h],rax
    nop     [rax+rax]
L5:
    mov     rax,[rsp+58h]
    cmp     rax,[rsp+38h]
    sete    [rsp+6Bh]
    test    byte ptr [rsp+6Bh],0FFh
    je      L6
    mov     rsi,[rsp+50h]
    mov     [rsp+30h],rsi
    jmp     L7
L6:
    mov     rax,[rsp+58h]
    mov     [rsp+30h],rax
L7:
    mov     rax,[rsp+30h]
    mov     [rsp+58h],rax
    lea     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    lea     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn3
    nop     [rcx+0B0h]
    test    byte ptr [rsp+6Bh],0FFh
    je      L8
    mov     rdx,[rsp+48h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+0B8h],rdi
    jmp     L9
L8:
    jmp     L5
L9:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
    nop     [rax]
L10:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L11:
    lea     rax,[rsp+48h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn4
    nop     [rcx+18h]
    jmp     L10
    nop     [rax]
L12:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+20h]
    jmp     L14
L13:
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L14:
    lea     rdi,[rsp+0C0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+0C0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L12

fn core::slice::sort::unstable::quicksort::partition_lomuto_branchless_cyclic::<u32, {closure@core::slice::sort::unstable::quicksort::quicksort<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}}>::{closure#0}
    sub     rsp,0A8h
    mov     rax,[rsp+0B0h]
    mov     rax,[rax]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+10h]
    mov     rsi,[rsp+0B0h]
    mov     rsi,[rsi+8]
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+77h]
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+10h]
    mov     rax,[rax]
    mov     rdx,[rsp+0B8h]
    mov     rdx,[rdx+18h]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     [rsp+68h],rax
    mov     [rsp+60h],rax
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi]
    mov     [rsp+58h],rsi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L4
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L6
    jmp     L5
L1:
    mov     rax,[rsp+68h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L2
    mov     byte ptr [rsp+76h],1
    jmp     L3
L2:
    mov     byte ptr [rsp+76h],0
L3:
    mov     rax,[rsp+50h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    movzx   edi,byte ptr [rsp+76h]
    mov     [rsp+18h],dil
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+78h]
L4:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_Memmove
    jmp     L0
L5:
    mov     rax,[rsp+98h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+78h]
L6:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFC0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+10h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+60h]
    mov     [rdx],rcx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD7h
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+0B8h]
    mov     rax,[rax+18h]
    add     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+0B8h]
    mov     rcx,[rsp+30h]
    mov     [rdx+18h],rcx
    mov     rsi,[rsp+0B8h]
    mov     rsi,[rsi+10h]
    mov     qword ptr [rsp+40h],1
    imul    rcx,[rsp+40h],4
    add     rsi,rcx
    mov     [rsp+60h],rsi
    mov     r8,[rsp+0B8h]
    mov     rcx,[rsp+60h]
    mov     [r8+10h],rcx
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,0D8h
    nop     [rax+rax]
L0:
    mov     rax,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     [rsp+88h],rdx
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+80h]
    cmp     rax,[rsp+88h]
    jb      L1
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+100h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+0D0h]
    jmp     L15
L1:
    mov     eax,[rsp+0F8h]
    mov     [rsp+90h],eax
    cmp     eax,0
    jne     L2
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+100h]
    mov     [rsp+10h],rax
    call    fn2
    nop     [rcx+0D0h]
    jmp     L3
L2:
    mov     eax,[rsp+0F8h]
    sub     eax,1
    mov     [rsp+0F8h],eax
    mov     rdx,[rsp+0E0h]
    mov     [rsp+78h],rdx
    mov     rsi,[rsp+0E8h]
    mov     [rsp+80h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFFA8h
    call    ryo_h_MovW128
    mov     rax,[rsp+100h]
    mov     [rsp+10h],rax
    call    fn3
    nop     [rcx+88h]
    jmp     L4
L3:
    jmp     L15
L4:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF5Ch
    mov     edx,20h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFF5Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L5]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L5:
    .long   L11
    .long   L6
    .long   L20
L6:
    mov     rax,[rsp+0F0h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    mov     [rsp+0B0h],rsi
    mov     rdi,[rsp+88h]
    cmp     rdi,rsi
    jb      L9
    mov     [rsp],rdi
    mov     [rsp+8],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx+30h]
    jmp     L8
L7:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L8:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rsp+0E0h]
    imul    rcx,[rsp+88h],4
    add     rax,rcx
    mov     rdx,[rsp+80h]
    mov     [rsp+70h],rdx
    mov     [rsp+78h],rax
    mov     rsi,[rsp+100h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rax
    call    fn8
    nop     [rcx+96h]
    test    byte ptr [rsp+96h],0FFh
    je      L10
    jmp     L11
L10:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF98h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+100h]
    mov     [rsp+58h],rax
    lea     rdx,[rsp+58h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF98h
    call    ryo_h_MovW128
    mov     rax,[rsp+88h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    call    fn9
    nop     [rcx+78h]
    mov     rax,[rsp+78h]
    add     rax,1
    mov     [rsp+0A0h],rax
    mov     rdx,[rsp+0E8h]
    mov     [rsp+70h],rdx
    cmp     rdx,rax
    jb      L16
    jmp     L19
L11:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFA0h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     rax,[rsp+88h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+100h]
    mov     [rsp+18h],rdx
    call    fn10
    nop     [rcx+80h]
    mov     rax,[rsp+0E0h]
    mov     rdx,[rsp+0E8h]
    mov     rsi,[rsp+80h]
    cmp     rsi,rdx
    setb    [rsp+96h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+80h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    call    fn12
    nop     [rcx+40h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFF80h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+30h]
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFF60h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0D0h]
    mov     esi,10h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    mov     rax,[rsp+58h]
    mov     [rsp+98h],rax
    mov     qword ptr [rsp+28h],0
    mov     rsi,[rsp+28h]
    cmp     rsi,rax
    setb    [rsp+97h]
    test    byte ptr [rsp+97h],0FFh
    jne     L14
    mov     qword ptr [rsp],0
    mov     [rsp+8],rax
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym16]
    lea     rdx,[site17]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L12
    call    rax
    nop     [rcx+30h]
    jmp     L13
L12:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L13:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L14:
    mov     rax,[rsp+50h]
    mov     [rsp+48h],rax
    mov     edx,[rsp+0F8h]
    mov     [rsp+90h],edx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     rax,[rsp+0F0h]
    mov     [rsp+10h],rax
    mov     edx,[rsp+90h]
    mov     [rsp+18h],edx
    mov     rsi,[rsp+100h]
    mov     [rsp+20h],rsi
    call    fn19
    nop     [rcx+97h]
    mov     rax,[rsp+48h]
    mov     [rsp+0F0h],rax
    jmp     L0
L15:
    lea     rdi,[rsp+0D0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0D8h
    ret
L16:
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF48h
    lea     rdx,[k20]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+0D0h]
    lea     rsi,[sym21]
    lea     rdx,[site22]
    mov     ecx,0FFFFFF58h
    call    ryo_h_CallExt
    test    rax,rax
    je      L17
    call    rax
    nop     [rcx+97h]
    jmp     L18
L17:
    lea     rdi,[rsp+0D0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym23]
L18:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L19:
    mov     rax,[rsp+70h]
    sub     rax,[rsp+0A0h]
    mov     rdx,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    imul    rcx,[rsp+0A0h],4
    add     rdx,rcx
    mov     [rsp+0E0h],rdx
    mov     [rsp+0E8h],rax
    mov     qword ptr [rsp+0F0h],0
    jmp     L0
L20:
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2

fn core::slice::sort::unstable::quicksort::quicksort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>::{closure#0}
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn0
    nop     [rcx+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    xor     al,1
    mov     [rsp+3Fh],al
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn core::slice::sort::unstable::sort::<u32, for<'a, 'b> fn(&'a u32, &'b u32) -> bool {<u32 as std::cmp::PartialOrd>::lt}>
    sub     rsp,38h
    mov     byte ptr [rsp+26h],0
    test    byte ptr [rsp+26h],0FFh
    jne     L2
    mov     rsi,[rsp+48h]
    mov     [rsp+28h],rsi
    cmp     rsi,2
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L4
    jmp     L3
    nop     [rax]
L0:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret
L3:
    jmp     L2
L4:
    cmp     qword ptr [rsp+28h],14h
    setbe   [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L5
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    mov     rdx,[rsp+50h]
    mov     [rsp+18h],rdx
    call    fn0
    nop     [rcx+30h]
    jmp     L0
L5:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+30h]
    jmp     L1

fn core::ub_checks::maybe_is_nonoverlapping::runtime
    sub     rsp,88h
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+0A0h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+20h],rdi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    mov     edx,0FFFFFFB0h
    mov     ecx,0FFFFFFC8h
    mov     r8d,0FFFFFFA0h
    call    ryo_h_MulOvfUW64
    mov     rax,[rsp+28h]
    movzx   edx,byte ptr [rsp+30h]
    mov     [rsp+63h],dl
    mov     [rsp+18h],rax
    test    byte ptr [rsp+63h],0FFh
    je      L2
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],3Dh
    lea     rdi,[rsp+80h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+7Fh]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+18h]
    mov     qword ptr [rsp+38h],1
    mov     [rsp+48h],rax
    mov     rsi,[rsp+58h]
    cmp     rsi,[rsp+50h]
    jae     L3
    mov     rdi,[rsp+50h]
    sub     rdi,rsi
    mov     [rsp+70h],rdi
    jmp     L4
L3:
    mov     rax,[rsp+58h]
    sub     rax,[rsp+50h]
    mov     [rsp+70h],rax
L4:
    mov     rax,[rsp+48h]
    cmp     rax,[rsp+70h]
    setbe   [rsp+7Fh]
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn main
    sub     rsp,338h
    mov     qword ptr [rsp],3D090h
    call    fn0
    nop     [rcx+328h]
    mov     rax,2545F4914F6CDD1Dh
    mov     [rsp+320h],rax
    mov     qword ptr [rsp+2E0h],0
    mov     rsi,[rsp+328h]
    mov     [rsp+2E8h],rsi
    lea     rdi,[rsp+320h]
    mov     [rsp+2D8h],rdi
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     rax,[rsp+2D8h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+2F0h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFFC0h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx+308h]
    lea     rax,[rsp+308h]
    mov     [rsp+2B0h],rax
    mov     [rsp],rax
    call    fn3
    nop     [rcx+2B8h]
    lea     rax,[rsp+2B8h]
    mov     [rsp+298h],rax
    mov     [rsp],rax
    call    fn4
    nop     [rcx+2A0h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFF70h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx+2B0h]
    lea     rax,[rsp+308h]
    mov     [rsp+278h],rax
    mov     [rsp],rax
    call    fn6
    nop     [rcx+280h]
    lea     rax,[rsp+280h]
    mov     [rsp+260h],rax
    mov     [rsp],rax
    call    fn7
    nop     [rcx+268h]
    mov     rax,[rsp+328h]
    mov     [rsp],rax
    call    fn8
    nop     [rcx+240h]
    lea     rax,[rsp+240h]
    mov     [rsp+258h],rax
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFF38h
    call    ryo_h_MovW128
    mov     rax,[rsp+258h]
    mov     [rsp+10h],rax
    call    fn9
    nop     [rcx+278h]
    lea     rax,[rsp+240h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn10
    nop     [rcx+38h]
    lea     rax,[rsp+2B8h]
    lea     rdx,[rsp+280h]
    mov     [rsp+230h],rax
    mov     [rsp+238h],rdx
    mov     [rsp+218h],rax
    mov     [rsp+210h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn11
    nop     [rcx+20Fh]
    test    byte ptr [rsp+20Fh],0FFh
    je      L0
    lea     rdx,[rsp+308h]
    mov     [rsp+1A8h],rdx
    mov     [rsp],rdx
    call    fn12
    nop     [rcx+1B0h]
    jmp     L1
L0:
    mov     byte ptr [rsp+20Eh],0
    mov     qword ptr [rsp+1F8h],0
    movzx   esi,byte ptr [rsp+20Eh]
    mov     [rsp+20h],sil
    mov     rdi,[rsp+218h]
    mov     [rsp],rdi
    mov     r8,[rsp+210h]
    mov     [rsp+8],r8
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCE0h
    mov     edx,0FFFFFEC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCF8h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx+20Eh]
    lea     rdi,[rsp+330h]
    call    ryo_h_Unreachable
    ud2
L1:
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFE80h
    call    ryo_h_MovW128
    call    fn15
    nop     [rcx+1C0h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFE90h
    call    ryo_h_MovW128
    call    fn16
    nop     [rcx+1D0h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFEA0h
    call    ryo_h_MovW128
    call    fn17
    nop     [rcx+1E0h]
    lea     rax,[rsp+1E0h]
    mov     [rsp+190h],rax
    mov     [rsp],rax
    call    fn18
    nop     [rcx+198h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFE68h
    call    ryo_h_MovW128
    call    fn19
    nop     [rcx+1A8h]
    lea     rax,[rsp+2B8h]
    mov     [rsp+138h],rax
    mov     [rsp],rax
    call    fn20
    nop     [rcx+140h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFE10h
    call    ryo_h_MovW128
    call    fn21
    nop     [rcx+150h]
    lea     rax,[rsp+150h]
    mov     [rsp+158h],rax
    lea     rdx,[rsp+1E0h]
    mov     [rsp+128h],rdx
    mov     [rsp],rdx
    mov     qword ptr [rsp+8],0
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCE0h
    lea     rdx,[k22]
    call    ryo_h_AddrAbs
    call    fn23
    nop     [rcx+130h]
    lea     rax,[rsp+1E0h]
    mov     [rsp+118h],rax
    mov     qword ptr [rsp+38h],1
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFDD0h
    mov     edx,0FFFFFDD8h
    mov     ecx,0FFFFFFF8h
    mov     r8d,0FFFFFD08h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rsp+108h],0FFh
    je      L4
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    lea     rdx,[k24]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+330h]
    lea     rsi,[sym25]
    lea     rdx,[site26]
    mov     ecx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+40h]
    jmp     L3
L2:
    lea     rdi,[rsp+330h]
    lea     rsi,[ro+4]
    call    qword ptr [sym27]
L3:
    lea     rdi,[rsp+330h]
    call    ryo_h_Unreachable
    ud2
L4:
    mov     rax,[rsp+100h]
    mov     [rsp+110h],rax
    mov     rdx,[rsp+118h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCE0h
    lea     rdx,[k28]
    call    ryo_h_AddrAbs
    call    fn29
    nop     [rcx+120h]
    lea     rax,[rsp+328h]
    mov     rdx,[rsp+158h]
    mov     [rsp+160h],rdx
    mov     rsi,[rsp+130h]
    mov     [rsp+168h],rsi
    mov     rdi,[rsp+120h]
    mov     [rsp+170h],rdi
    mov     [rsp+178h],rax
    mov     [rsp+60h],rax
    mov     [rsp],rax
    call    fn30
    nop     [rcx+0A8h]
    mov     rax,[rsp+160h]
    mov     [rsp+58h],rax
    mov     [rsp],rax
    call    fn31
    nop     [rcx+98h]
    mov     rax,[rsp+168h]
    mov     [rsp+50h],rax
    mov     [rsp],rax
    call    fn32
    nop     [rcx+88h]
    mov     rax,[rsp+170h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    call    fn33
    nop     [rcx+78h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFD88h
    mov     edx,0FFFFFD78h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFD98h
    mov     edx,0FFFFFD68h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFDA8h
    mov     edx,0FFFFFD58h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFDB8h
    mov     edx,0FFFFFD48h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFD40h
    lea     rdx,[k34]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+0B8h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn35
    nop     [rcx+180h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFCD0h
    mov     edx,0FFFFFE50h
    call    ryo_h_MovW128
    lea     rdi,[rsp+330h]
    lea     rsi,[sym36]
    lea     rdx,[site37]
    mov     ecx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+190h]
    jmp     L6
L5:
    lea     rdi,[rsp+330h]
    lea     rsi,[ro+20]
    call    qword ptr [sym38]
L6:
    lea     rax,[rsp+1E0h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn39
    nop     [rcx+38h]
    lea     rax,[rsp+280h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn40
    nop     [rcx+38h]
    lea     rax,[rsp+2B8h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn41
    nop     [rcx+38h]
    lea     rax,[rsp+308h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn42
    nop     [rcx+38h]
    lea     rdi,[rsp+330h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,338h
    ret
    nop     [rax]
L7:
    lea     rax,[rsp+1E0h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn43
    nop     [rcx+38h]
    jmp     L9
    nop
L8:
    lea     rax,[rsp+240h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn44
    nop     [rcx+38h]
    nop     [rax]
L9:
    lea     rax,[rsp+280h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn45
    nop     [rcx+38h]
    nop     [rax]
L10:
    lea     rax,[rsp+2B8h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn46
    nop     [rcx+38h]
    nop     [rax]
L11:
    lea     rax,[rsp+308h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn47
    nop     [rcx+38h]
    lea     rdi,[rsp+330h]
    mov     esi,0FFFFFD10h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    lea     rdi,[rsp+330h]
    lea     rsi,[sym48]
    lea     rdx,[site49]
    mov     ecx,0FFFFFD08h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+40h]
    jmp     L14
L13:
    lea     rdi,[rsp+330h]
    lea     rsi,[ro+4]
    call    qword ptr [sym50]
L14:
    lea     rdi,[rsp+330h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L11
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L10
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L8
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L7
    lea     rdi,[rsp+330h]
    mov     rsi,rax
    mov     edx,0FFFFFD10h
    call    ryo_h_Lpad
    jmp     L12

fn main::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+10h]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFF0h
    call    ryo_h_TruncW64W32
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,4
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn main::{closure#1}
    sub     rsp,38h
    mov     rax,[rsp+48h]
    mov     eax,[rax]
    mov     [rsp+24h],eax
    mov     dword ptr [rsp+18h],3E8h
    cmp     dword ptr [rsp+18h],0
    sete    [rsp+1Fh]
    test    byte ptr [rsp+1Fh],0FFh
    je      L2
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+30h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFE0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+1Fh]
    jmp     L1
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     dword ptr [rsp+18h],3E8h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFF4h
    mov     ecx,0FFFFFFE8h
    call    ryo_h_RemUW32
    mov     eax,[rsp+20h]
    mov     [rsp+28h],eax
    mov     edx,[rsp+24h]
    mov     [rsp+2Ch],edx
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn main::{closure#2}
    sub     rsp,18h
    mov     rax,[rsp+28h]
    mov     eax,[rax]
    mov     [rsp+0Ch],eax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFFCh
    mov     edx,4
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn merge_sort
    sub     rsp,388h
    mov     rax,[rsp+390h]
    mov     rdx,[rsp+398h]
    mov     [rsp+370h],rdx
    cmp     rdx,10h
    ja      L20
    mov     rdi,[rsp+390h]
    mov     r8,[rsp+398h]
    mov     qword ptr [rsp+340h],1
    mov     [rsp+348h],r8
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+350h]
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    nop     [rax+rax]
L0:
    lea     rax,[rsp+318h]
    mov     [rsp+300h],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+308h]
    mov     rax,[rsp+308h]
    mov     [rsp+2F8h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFF78h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L1:
    .long   L45
    .long   L3
    .long   L2
L2:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+310h]
    mov     [rsp+2E8h],rax
    nop     [rax+rax]
L4:
    mov     rax,[rsp+2E8h]
    mov     [rsp+2D8h],rax
    cmp     rax,0
    jbe     L0
    mov     rsi,[rsp+2E8h]
    mov     [rsp+2C0h],rsi
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFF30h
    mov     edx,0FFFFFF38h
    mov     ecx,0FFFFFF40h
    mov     r8d,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rsp+2B8h],0FFh
    je      L7
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+30h]
    jmp     L6
L5:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+2B0h]
    mov     [rsp+2C8h],rax
    mov     rdx,[rsp+390h]
    mov     rsi,[rsp+398h]
    mov     [rsp+298h],rsi
    cmp     rax,rsi
    jb      L10
    mov     [rsp],rax
    mov     [rsp+8],rsi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L8
    call    rax
    nop     [rcx+30h]
    jmp     L9
L8:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L9:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L10:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+2C8h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+2D0h],eax
    mov     rdx,[rsp+2E8h]
    mov     [rsp+288h],rdx
    mov     rsi,[rsp+390h]
    mov     rdi,[rsp+398h]
    mov     [rsp+270h],rdi
    cmp     rdx,rdi
    jb      L13
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k10]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym11]
    lea     rdx,[site12]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L11
    call    rax
    nop     [rcx+30h]
    jmp     L12
L11:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym13]
L12:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+288h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+290h],eax
    cmp     eax,[rsp+2D0h]
    jae     L0
    mov     rdx,[rsp+2E8h]
    mov     [rsp+258h],rdx
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFED0h
    mov     ecx,0FFFFFED8h
    mov     r8d,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rsp+250h],0FFh
    je      L16
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k14]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym15]
    lea     rdx,[site16]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L14
    call    rax
    nop     [rcx+30h]
    jmp     L15
L14:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym17]
L15:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L16:
    mov     rax,[rsp+248h]
    mov     [rsp+260h],rax
    mov     rdx,[rsp+2E8h]
    mov     [rsp+240h],rdx
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+260h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+240h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFCA0h
    lea     rdx,[k18]
    call    ryo_h_AddrAbs
    call    fn19
    nop     [rcx+26Fh]
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFEB0h
    mov     edx,0FFFFFEB8h
    mov     ecx,0FFFFFF68h
    mov     r8d,0FFFFFCA8h
    call    ryo_h_SubOvfUW64
    test    byte ptr [rsp+238h],0FFh
    je      L19
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k20]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym21]
    lea     rdx,[site22]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L17
    call    rax
    nop     [rcx+30h]
    jmp     L18
L17:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym23]
L18:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L19:
    mov     rax,[rsp+230h]
    mov     [rsp+2E8h],rax
    jmp     L4
L20:
    mov     rax,[rsp+390h]
    mov     rdx,[rsp+398h]
    mov     [rsp+220h],rdx
    mov     qword ptr [rsp+28h],2
    cmp     qword ptr [rsp+28h],0
    sete    [rsp+20Fh]
    test    byte ptr [rsp+20Fh],0FFh
    je      L23
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k24]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym25]
    lea     rdx,[site26]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx+30h]
    jmp     L22
L21:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym27]
L22:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L23:
    mov     qword ptr [rsp+28h],2
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFEA8h
    mov     edx,0FFFFFEA0h
    mov     ecx,0FFFFFCA8h
    call    ryo_h_DivUW64
    mov     rax,[rsp+228h]
    mov     [rsp+1F0h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+1F0h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC98h
    lea     rdx,[k28]
    call    ryo_h_AddrAbs
    call    fn29
    nop     [rcx+1F8h]
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,0FFFFFE78h
    call    ryo_h_MovW128
    mov     rax,[rsp+3A0h]
    mov     [rsp+10h],rax
    call    fn30
    nop     [rcx+20Fh]
    mov     rax,[rsp+228h]
    mov     [rsp+1D8h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+1D8h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC98h
    lea     rdx,[k31]
    call    ryo_h_AddrAbs
    call    fn32
    nop     [rcx+1E0h]
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,0FFFFFE60h
    call    ryo_h_MovW128
    mov     rax,[rsp+3A0h]
    mov     [rsp+10h],rax
    call    fn33
    nop     [rcx+1F0h]
    mov     rax,[rsp+3A0h]
    mov     [rsp],rax
    call    fn34
    nop     [rcx+1D8h]
    mov     qword ptr [rsp+1B8h],0
    mov     rdx,[rsp+228h]
    mov     [rsp+1C0h],rdx
    mov     rsi,[rsp+1B8h]
    mov     [rsp+1D0h],rsi
    mov     [rsp+1C8h],rdx
    nop     [rax+rax]
    nop     [rax+rax]
L24:
    mov     rax,[rsp+1D0h]
    mov     [rsp+1A8h],rax
    cmp     rax,[rsp+228h]
    jae     L44
    mov     rdx,[rsp+1C8h]
    mov     [rsp+198h],rdx
    mov     rsi,[rsp+390h]
    mov     rdi,[rsp+398h]
    mov     [rsp+190h],rdi
    cmp     rdx,rdi
    jae     L44
    mov     r8,[rsp+1D0h]
    mov     [rsp+170h],r8
    mov     r9,[rsp+390h]
    mov     r10,[rsp+398h]
    mov     [rsp+158h],r10
    cmp     r8,r10
    jb      L27
    mov     [rsp],r8
    mov     [rsp+8],r10
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k35]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym36]
    lea     rdx,[site37]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L25
    call    rax
    nop     [rcx+30h]
    jmp     L26
L25:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym38]
L26:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L27:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+170h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+178h],eax
    mov     rdx,[rsp+1C8h]
    mov     [rsp+148h],rdx
    mov     rsi,[rsp+390h]
    mov     rdi,[rsp+398h]
    mov     [rsp+130h],rdi
    cmp     rdx,rdi
    jb      L30
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k39]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym40]
    lea     rdx,[site41]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L28
    call    rax
    nop     [rcx+30h]
    jmp     L29
L28:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym42]
L29:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L30:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+148h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+150h],eax
    cmp     eax,[rsp+178h]
    jb      L37
    mov     rdx,[rsp+1D0h]
    mov     [rsp+120h],rdx
    mov     rsi,[rsp+390h]
    mov     rdi,[rsp+398h]
    mov     [rsp+108h],rdi
    cmp     rdx,rdi
    jb      L33
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k43]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym44]
    lea     rdx,[site45]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L31
    call    rax
    nop     [rcx+30h]
    jmp     L32
L31:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym46]
L32:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L33:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+120h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+128h],eax
    mov     rdx,[rsp+3A0h]
    mov     [rsp],rdx
    mov     [rsp+8],eax
    call    fn47
    nop     [rcx+12Fh]
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFD70h
    mov     edx,0FFFFFD78h
    mov     ecx,0FFFFFE50h
    mov     r8d,0FFFFFCA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+0F8h],0FFh
    je      L36
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k48]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym49]
    lea     rdx,[site50]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L34
    call    rax
    nop     [rcx+30h]
    jmp     L35
L34:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym51]
L35:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L36:
    mov     rax,[rsp+0F0h]
    mov     [rsp+1D0h],rax
    jmp     L24
L37:
    mov     rax,[rsp+1C8h]
    mov     [rsp+0E0h],rax
    mov     rdx,[rsp+390h]
    mov     rsi,[rsp+398h]
    mov     [rsp+0C8h],rsi
    cmp     rax,rsi
    jb      L40
    mov     [rsp],rax
    mov     [rsp+8],rsi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    lea     rdx,[k52]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym53]
    lea     rdx,[site54]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L38
    call    rax
    nop     [rcx+30h]
    jmp     L39
L38:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym55]
L39:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L40:
    mov     rax,[rsp+390h]
    imul    rcx,[rsp+0E0h],4
    add     rax,rcx
    mov     eax,[rax]
    mov     [rsp+0ECh],eax
    mov     rdx,[rsp+3A0h]
    mov     [rsp],rdx
    mov     [rsp+8],eax
    call    fn56
    nop     [rcx+0F0h]
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFD30h
    mov     edx,0FFFFFD38h
    mov     ecx,0FFFFFE48h
    mov     r8d,0FFFFFCA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+0B8h],0FFh
    je      L43
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    lea     rdx,[k57]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+380h]
    lea     rsi,[sym58]
    lea     rdx,[site59]
    mov     ecx,0FFFFFCA8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L41
    call    rax
    nop     [rcx+30h]
    jmp     L42
L41:
    lea     rdi,[rsp+380h]
    lea     rsi,[ro+4]
    call    qword ptr [sym60]
L42:
    lea     rdi,[rsp+380h]
    call    ryo_h_Unreachable
    ud2
L43:
    mov     rax,[rsp+0B0h]
    mov     [rsp+1C8h],rax
    jmp     L24
L44:
    mov     rax,[rsp+390h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+398h]
    mov     [rsp+98h],rdx
    mov     rsi,[rsp+1D0h]
    mov     [rsp+80h],rsi
    mov     rdi,[rsp+228h]
    mov     [rsp+88h],rdi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,0FFFFFD10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    mov     edx,0FFFFFD00h
    call    ryo_h_MovW128
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFCA0h
    lea     rdx,[k61]
    call    ryo_h_AddrAbs
    call    fn62
    nop     [rcx+0A0h]
    mov     rax,[rsp+3A0h]
    mov     [rsp],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC88h
    mov     edx,0FFFFFD20h
    call    ryo_h_MovW128
    call    fn63
    nop     [rcx+0B0h]
    mov     rax,[rsp+390h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+398h]
    mov     [rsp+60h],rdx
    mov     rsi,[rsp+1C8h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,0FFFFFCD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+50h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC98h
    lea     rdx,[k64]
    call    ryo_h_AddrAbs
    call    fn65
    nop     [rcx+68h]
    mov     rax,[rsp+3A0h]
    mov     [rsp],rax
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC88h
    mov     edx,0FFFFFCE8h
    call    ryo_h_MovW128
    call    fn66
    nop     [rcx+78h]
    mov     rax,[rsp+3A0h]
    mov     [rsp+30h],rax
    mov     [rsp],rax
    call    fn67
    nop     [rcx+38h]
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC80h
    mov     edx,10h
    call    ryo_h_MovW128
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFC90h
    mov     edx,0FFFFFCB8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+380h]
    mov     esi,0FFFFFCA0h
    lea     rdx,[k68]
    call    ryo_h_AddrAbs
    call    fn69
    nop     [rcx+48h]
L45:
    lea     rdi,[rsp+380h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,388h
    ret

fn std::array::iter::iter_inner::PolymorphicIter::<[std::mem::MaybeUninit<usize>]>::next
    sub     rsp,0C8h
    mov     rax,[rsp+0D0h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+0D0h]
    mov     rdx,[rdx]
    sub     rax,rdx
    mov     [rsp+70h],rax
    cmp     rax,0
    jbe     L0
    mov     rdi,[rsp+0D0h]
    mov     rdi,[rdi]
    mov     [rsp+70h],rdi
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L2
    jmp     L1
L0:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFC0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+0D0h]
    lea     rax,[rax+10h]
    mov     [rsp+98h],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+0A0h],rdx
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+0B0h],0
    jmp     L3
L1:
    mov     rax,[rsp+70h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+90h]
L2:
    mov     rax,[rsp+70h]
    add     rax,1
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0D0h]
    mov     rcx,[rsp+68h]
    mov     [rdx],rcx
    mov     rsi,[rsp+70h]
    mov     [rsp+88h],rsi
    mov     qword ptr [rsp+80h],1
    mov     r8,[rsp+0D0h]
    lea     r8,[r8+10h]
    mov     [rsp+98h],r8
    mov     r9,[rsp+0D8h]
    mov     [rsp+0A0h],r9
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     rax,[rsp+88h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L4
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,0C8h
    ret
L4:
    mov     rax,[rsp+0A0h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+78h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    lea     rdi,[rsp+0C0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    call    fn4
    nop     [rcx+90h]
L5:
    mov     rax,[rsp+0A0h]
    mov     rdx,[rsp+78h]
    cmp     rdx,rax
    setb    [rsp+57h]
    mov     rsi,[rsp+98h]
    imul    rcx,rdx,8
    add     rsi,rcx
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+0C0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+0B8h],rax
    mov     qword ptr [rsp+0B0h],1
    jmp     L3

fn std::cmp::impls::<impl std::cmp::PartialOrd for u32>::lt
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     eax,[rax]
    mov     rdx,[rsp+28h]
    mov     edx,[rdx]
    cmp     eax,edx
    setb    [rsp+0Fh]
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rsp+1Fh]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::fmt::Arguments::<'_>::new::<22, 4>
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::fmt::DebugList::<'_, '_>::entries::<&u32, std::slice::Iter<'_, u32>>
    sub     rsp,98h
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,18h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+68h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    lea     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+50h]
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF8Ch
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFF8Ch
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L1]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L1:
    .long   L6
    .long   L3
    .long   L2
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+40h],rax
    lea     rdx,[rsp+40h]
    mov     [rsp+20h],rdx
    mov     [rsp+28h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    mov     edx,0FFFFFF98h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+38h]
    jmp     L5
L4:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    jmp     L7
L6:
    jmp     L8
L7:
    jmp     L0
L8:
    mov     rax,[rsp+0A0h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L9:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L9

fn std::hint::assert_unchecked::precondition_check
    sub     rsp,88h
    test    byte ptr [rsp+90h],0FFh
    jne     L2
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0DDh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],0DDh
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+98h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+80h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+70h]
    jmp     L1
L0:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L2:
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn std::hint::black_box::<usize>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::hint::select_unpredictable::<*const (u32, u32)>
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+58h],rdx
    lea     rsi,[rsp+60h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+58h]
    mov     [rsp+48h],rdi
    movzx   r8d,byte ptr [rsp+0A8h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A8h]
    mov     [rsp+8],al
    mov     rdx,[rsp+48h]
    mov     [rsp],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     [rsp],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    lea     rdx,[sym2]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax]
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn5
    nop     [rcx+18h]
    jmp     L1
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    movzx   edi,byte ptr [rsp+0A8h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax+rax]
    nop
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+20h]
    jmp     L7
L6:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::hint::select_unpredictable::<*const u32>
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+58h],rdx
    lea     rsi,[rsp+60h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+58h]
    mov     [rsp+48h],rdi
    movzx   r8d,byte ptr [rsp+0A8h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A8h]
    mov     [rsp+8],al
    mov     rdx,[rsp+48h]
    mov     [rsp],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     [rsp],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    lea     rdx,[sym2]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax]
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn5
    nop     [rcx+18h]
    jmp     L1
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    movzx   edi,byte ptr [rsp+0A8h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax+rax]
    nop
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+20h]
    jmp     L7
L6:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::hint::select_unpredictable::<*mut u32>
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+58h],rdx
    lea     rsi,[rsp+60h]
    mov     [rsp+50h],rsi
    lea     rdi,[rsp+58h]
    mov     [rsp+48h],rdi
    movzx   r8d,byte ptr [rsp+0A8h]
    mov     [rsp+8],r8b
    mov     [rsp],rsi
    mov     [rsp+10h],rdi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym0]
    movzx   eax,byte ptr [rsp+0A8h]
    mov     [rsp+8],al
    mov     rdx,[rsp+48h]
    mov     [rsp],rdx
    mov     rsi,[rsp+50h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym1]
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+30h],rdx
    mov     [rsp],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    lea     rdx,[sym2]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+28]
    call    qword ptr [sym3]
    jmp     L3
    nop     [rax]
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+16]
    call    qword ptr [sym4]
    jmp     L4
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn5
    nop     [rcx+18h]
    jmp     L1
L3:
    mov     rax,[rsp+38h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    movzx   edi,byte ptr [rsp+0A8h]
    mov     [rsp+8],dil
    mov     [rsp],rdx
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+44]
    call    qword ptr [sym6]
    jmp     L0
L4:
    mov     rax,[rsp+30h]
    mov     [rsp+88h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax+rax]
    nop
L5:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF88h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+20h]
    jmp     L7
L6:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+56]
    call    qword ptr [sym9]
L7:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn std::intrinsics::cold_path
    sub     rsp,8
    lea     rdi,[rsp]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,8
    ret

fn std::intrinsics::select_unpredictable::<*mut *const (u32, u32)>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::select_unpredictable::<*mut *const u32>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::select_unpredictable::<*mut *mut u32>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const (u32, u32)>>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*const u32>>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::select_unpredictable::<std::mem::MaybeUninit<*mut u32>>
    sub     rsp,18h
    test    byte ptr [rsp+28h],0FFh
    je      L0
    mov     rdx,[rsp+20h]
    mov     [rsp+8],rdx
    jmp     L1
L0:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
L1:
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::intrinsics::typed_swap_nonoverlapping::<(u32, u32)>
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+30h]
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+28h]
    jmp     L2
L1:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::intrinsics::typed_swap_nonoverlapping::<u32>
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+30h]
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFFF0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+28h]
    jmp     L2
L1:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::iter::Iterator::for_each::call::<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::iter::Iterator::for_each::call::<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     edx,[rsp+38h]
    mov     [rsp+14h],edx
    mov     [rsp],rax
    mov     [rsp+8],edx
    call    fn0
    nop     [rcx+20h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::iter::adapters::map::map_fold::<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+4Fh],1
    mov     rsi,[rsp+60h]
    lea     rsi,[rsi+18h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+68h]
    mov     [rsp+18h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    call    fn0
    nop     [rcx+28h]
    mov     byte ptr [rsp+4Fh],0
    mov     rdx,[rsp+28h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+38h]
    mov     [rsp],rsi
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+50h]
    lea     rdi,[rsp+50h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,58h
    ret
    nop     [rax]
L0:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rsp+4Fh],0FFh
    je      L0
    jmp     L1
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::adapters::map::map_fold::<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+28h],rax
    mov     byte ptr [rsp+3Fh],1
    mov     rsi,[rsp+50h]
    lea     rsi,[rsi+18h]
    mov     [rsp+18h],rsi
    mov     rdi,[rsp+58h]
    mov     [rsp+10h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    call    fn0
    nop     [rcx+20h]
    mov     byte ptr [rsp+3Fh],0
    mov     edx,[rsp+20h]
    mov     [rsp+24h],edx
    mov     rsi,[rsp+28h]
    mov     [rsp],rsi
    mov     [rsp+8],edx
    call    fn1
    nop     [rcx+40h]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret
    nop     [rax]
L0:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    jmp     L1
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::next
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    call    fn0
    nop     [rcx+10h]
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::iter::range::<impl std::iter::Iterator for std::ops::Range<usize>>::size_hint
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+50h]
    lea     rdx,[rdx+8]
    mov     [rsp+10h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rdx,[rsp+50h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+50h]
    lea     rsi,[rsi+8]
    mov     [rsp+10h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn1
    nop     [rcx+28h]
    jmp     L1
L0:
    mov     qword ptr [rsp+28h],0
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k2]
    mov     ecx,10h
    call    ryo_h_Const
L1:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn std::ptr::const_ptr::<impl *const ()>::is_aligned_to
    sub     rsp,88h
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF9Ch
    mov     edx,18h
    call    ryo_h_CtpopW64
    mov     eax,[rsp+1Ch]
    mov     [rsp+78h],eax
    jmp     L4
    nop     [rax+rax]
L0:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    sub     rdx,1
    and     rax,rdx
    cmp     rax,0
    sete    [rsp+7Fh]
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,88h
    ret
    nop
L1:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+60h],2Ah
    mov     rdx,[rsp+58h]
    mov     rsi,[rsp+60h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],2Ah
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+80h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L2
    call    rax
    nop     [rcx+7Fh]
    jmp     L3
L2:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L3:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L4:
    cmp     dword ptr [rsp+78h],1
    sete    [rsp+7Eh]
    test    byte ptr [rsp+7Eh],0FFh
    je      L1
    jmp     L0

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    cmp     rax,[rsp+0A8h]
    jb      L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0C9h
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0C9h
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::copy::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+76h]
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L1:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0DDh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],0DDh
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0C0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+80h]
    jmp     L4
L3:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L4:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L5:
    test    byte ptr [rsp+0B8h],0FFh
    je      L8
    jmp     L7
    nop     [rax]
L6:
    jmp     L2
L7:
    mov     rax,[rsp+0A8h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+60h],rdx
    mov     [rsp],rax
    mov     rsi,[rsp+0B0h]
    mov     [rsp+8],rsi
    call    fn6
    nop     [rcx+75h]
    jmp     L13
L8:
    mov     rax,[rsp+0A0h]
    cmp     rax,0
    sete    [rsp+75h]
    movzx   esi,byte ptr [rsp+75h]
    xor     sil,1
    mov     [rsp+77h],sil
    test    byte ptr [rsp+77h],0FFh
    je      L2
    jmp     L14
L9:
    test    byte ptr [rsp+76h],0FFh
    je      L6
    jmp     L5
    nop     [rax]
L10:
    jmp     L1
    nop     [rax+rax]
    xchg    ax,ax
L11:
    jmp     L0
    nop     [rax+rax]
    xchg    ax,ax
L12:
    mov     rax,[rsp+0A8h]
    cmp     rax,0
    sete    [rsp+74h]
    movzx   esi,byte ptr [rsp+74h]
    xor     sil,1
    mov     [rsp+76h],sil
    test    byte ptr [rsp+76h],0FFh
    je      L1
    jmp     L0
L13:
    test    byte ptr [rsp+75h],0FFh
    je      L10
    jmp     L11
L14:
    mov     rax,[rsp+0A8h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+60h],rdx
    mov     [rsp],rax
    mov     rsi,[rsp+0B0h]
    mov     [rsp+8],rsi
    call    fn7
    nop     [rcx+75h]
    test    byte ptr [rsp+75h],0FFh
    je      L10
    jmp     L12
    nop     [rax]
L15:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L16
    call    rax
    nop     [rcx+28h]
    jmp     L17
L16:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L17:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L15

fn std::ptr::copy_nonoverlapping::precondition_check
    sub     rsp,0A8h
    cmp     qword ptr [rsp+0D0h],0
    jne     L0
    mov     byte ptr [rsp+9Fh],1
    jmp     L1
L0:
    cmp     qword ptr [rsp+0C0h],0
    sete    [rsp+9Fh]
L1:
    movzx   eax,byte ptr [rsp+9Fh]
    mov     [rsp+75h],al
    mov     rdx,[rsp+0B0h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0C8h]
    mov     [rsp+8],rsi
    call    fn0
    nop     [rcx+74h]
    jmp     L13
    nop     [rax+rax]
    nop     [rax]
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+90h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+0C8h]
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+74h]
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rsp+0B0h]
    mov     [rsp],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+0C0h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0D0h]
    mov     [rsp+18h],rdi
    call    fn2
    nop     [rcx+77h]
    jmp     L19
    nop     [rax+rax]
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],11Bh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],11Bh
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0D8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+80h]
    jmp     L7
L6:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L8:
    lea     rdi,[rsp+0A0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0A8h
    ret
    nop     [rax]
L9:
    test    byte ptr [rsp+75h],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rsp+0B0h]
    cmp     rax,0
    sete    [rsp+73h]
    movzx   esi,byte ptr [rsp+73h]
    xor     sil,1
    mov     [rsp+76h],sil
    test    byte ptr [rsp+76h],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rsp+74h],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    test    byte ptr [rsp+9Fh],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rsp+0B8h]
    cmp     rax,0
    sete    [rsp+73h]
    movzx   esi,byte ptr [rsp+73h]
    xor     sil,1
    mov     [rsp+75h],sil
    test    byte ptr [rsp+75h],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rsp+74h],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rsp+77h],0FFh
    je      L5
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L20:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx+28h]
    jmp     L22
L21:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<(u32, u32)>> - shim(Some(alloc::raw_vec::RawVec<(u32, u32)>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<u32>> - shim(Some(alloc::raw_vec::RawVec<u32>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<(u32, u32)>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::slice::sort::shared::smallsort::CopyOnDrop<u32>> - shim(Some(core::slice::sort::shared::smallsort::CopyOnDrop<u32>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::slice::sort::stable::merge::MergeState<(u32, u32)>> - shim(Some(core::slice::sort::stable::merge::MergeState<(u32, u32)>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<core::slice::sort::unstable::quicksort::GapGuardRaw<u32>> - shim(Some(core::slice::sort::unstable::quicksort::GapGuardRaw<u32>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::array::IntoIter<usize, 2>> - shim(Some(std::array::IntoIter<usize, 2>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const (u32, u32)>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*const u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*const u32>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::hint::select_unpredictable::DropOnPanic<*mut u32>> - shim(Some(std::hint::select_unpredictable::DropOnPanic<*mut u32>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::vec::Vec<(u32, u32)>> - shim(Some(std::vec::Vec<(u32, u32)>))
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+18h]
    jmp     L3
L0:
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+8]
    jmp     L1
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn2
    nop     [rcx+8]
    jmp     L0
    nop     [rax+rax]
L4:
    lea     rdi,[rsp+20h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+10h]
    jmp     L6
L5:
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::drop_glue::<std::vec::Vec<u32>> - shim(Some(std::vec::Vec<u32>))
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+18h]
    jmp     L3
L0:
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn1
    nop     [rcx+8]
    jmp     L1
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn2
    nop     [rcx+8]
    jmp     L0
    nop     [rax+rax]
L4:
    lea     rdi,[rsp+20h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L5
    call    rax
    nop     [rcx+10h]
    jmp     L6
L5:
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L6:
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::drop_glue::<std::vec::set_len_on_drop::SetLenOnDrop<'_>> - shim(Some(std::vec::set_len_on_drop::SetLenOnDrop<'_>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<&u32, (u32, u32), (), {closure@bench/sort.rs:59:50: 59:54}, {closure@std::iter::Iterator::for_each::call<(u32, u32), {closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}> - shim(Some({closure@std::iter::adapters::map::map_fold<usize, u32, (), {closure@bench/sort.rs:52:37: 52:40}, {closure@std::iter::Iterator::for_each::call<u32, {closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}>::{closure#0}}>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<(u32, u32)>::extend_trusted<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<{closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}> - shim(Some({closure@std::vec::Vec<u32>::extend_trusted<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}}))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+8]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::swap::<u32>
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+60h],rax
    lea     rdx,[rsp+6Ch]
    mov     [rsp+78h],rdx
    mov     [rsp+58h],rdx
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L0
    mov     r8,[rsp+0A0h]
    mov     [rsp+50h],r8
    mov     r9,[rsp+78h]
    mov     [rsp+48h],r9
    mov     [rsp],r8
    mov     [rsp+8],r9
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+78h]
L0:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memcpy
    mov     rax,[rsp+0A8h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L5
    jmp     L2
    xchg    ax,ax
L1:
    lea     rax,[rsp+6Ch]
    mov     [rsp+70h],rax
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L7
    jmp     L6
L2:
    mov     rax,[rsp+0A8h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+50h],rdx
    mov     byte ptr [rsp+47h],0
    test    byte ptr [rsp+47h],0FFh
    je      L3
    mov     byte ptr [rsp+6Bh],1
    jmp     L4
L3:
    mov     byte ptr [rsp+6Bh],0
L4:
    mov     rax,[rsp+58h]
    mov     [rsp],rax
    mov     rdx,[rsp+50h]
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    movzx   edi,byte ptr [rsp+6Bh]
    mov     [rsp+18h],dil
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    call    fn3
    nop     [rcx+78h]
L5:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,10h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memmove
    jmp     L1
L6:
    mov     rax,[rsp+70h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0A8h]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     qword ptr [rsp+20h],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx+70h]
L7:
    mov     qword ptr [rsp+40h],1
    imul    rdx,[rsp+40h],4
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,18h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_Memcpy
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn std::ptr::swap_chunk::<1>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    mov     rdx,[rsp+28h]
    movzx   edx,byte ptr [rdx]
    mov     [rsp+0Eh],dl
    mov     rsi,[rsp+20h]
    movzx   ecx,byte ptr [rsp+0Eh]
    mov     [rsi],cl
    mov     rdi,[rsp+28h]
    movzx   ecx,byte ptr [rsp+0Fh]
    mov     [rdi],cl
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::swap_chunk::<2>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    movzx   eax,word ptr [rax]
    mov     [rsp+0Eh],ax
    mov     rdx,[rsp+28h]
    movzx   edx,word ptr [rdx]
    mov     [rsp+0Ch],dx
    mov     rsi,[rsp+20h]
    movzx   ecx,word ptr [rsp+0Ch]
    mov     [rsi],cx
    mov     rdi,[rsp+28h]
    movzx   ecx,word ptr [rsp+0Eh]
    mov     [rdi],cx
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::swap_chunk::<4>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     eax,[rax]
    mov     [rsp+0Ch],eax
    mov     rdx,[rsp+28h]
    mov     edx,[rdx]
    mov     [rsp+8],edx
    mov     rsi,[rsp+20h]
    mov     ecx,[rsp+8]
    mov     [rsi],ecx
    mov     rdi,[rsp+28h]
    mov     ecx,[rsp+0Ch]
    mov     [rdi],ecx
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::swap_chunk::<8>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     [rsp+8],rax
    mov     rdx,[rsp+28h]
    mov     rdx,[rdx]
    mov     [rsp],rdx
    mov     rsi,[rsp+20h]
    mov     rcx,[rsp]
    mov     [rsi],rcx
    mov     rdi,[rsp+28h]
    mov     rcx,[rsp+8]
    mov     [rdi],rcx
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::ptr::swap_nonoverlapping::<(u32, u32)>
    sub     rsp,88h
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    mov     rsi,[rsp+90h]
    mov     [rsp+78h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+70h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    mov     qword ptr [rsp+10h],8
    mov     qword ptr [rsp+18h],4
    mov     r10,[rsp+0A0h]
    mov     [rsp+20h],r10
    mov     r11,[rsp+0A8h]
    mov     [rsp+28h],r11
    call    fn0
    nop     [rcx+80h]
L0:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    imul    rax,[rsp+60h],8
    mov     [rsp+68h],rax
    jmp     L3
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+40h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+80h]
    jmp     L2
L2:
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret
L3:
    mov     rax,[rsp+68h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFBCh
    mov     edx,0FFFFFFE0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::<u32>
    sub     rsp,88h
    mov     byte ptr [rsp+3Fh],1
    test    byte ptr [rsp+3Fh],0FFh
    je      L0
    mov     rsi,[rsp+90h]
    mov     [rsp+78h],rsi
    mov     rdi,[rsp+98h]
    mov     [rsp+70h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     r10,[rsp+0A0h]
    mov     [rsp+20h],r10
    mov     r11,[rsp+0A8h]
    mov     [rsp+28h],r11
    call    fn0
    nop     [rcx+80h]
L0:
    mov     rax,[rsp+90h]
    mov     [rsp+70h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    imul    rax,[rsp+60h],4
    mov     [rsp+68h],rax
    jmp     L3
L1:
    mov     rax,[rsp+60h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+98h]
    mov     [rsp+40h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+80h]
    jmp     L2
L2:
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret
L3:
    mov     rax,[rsp+68h]
    mov     [rsp+60h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFBCh
    mov     edx,0FFFFFFE0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFBCh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L4]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L4:
    .long   L2
    .long   L1
    .long   L5
L5:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping::precondition_check
    sub     rsp,0B8h
    cmp     qword ptr [rsp+0D0h],0
    jne     L0
    mov     byte ptr [rsp+0AFh],1
    jmp     L1
L0:
    cmp     qword ptr [rsp+0E0h],0
    sete    [rsp+0AFh]
L1:
    mov     rax,[rsp+0C0h]
    mov     [rsp+0A0h],rax
    movzx   edx,byte ptr [rsp+0AFh]
    mov     [rsp+7Dh],dl
    mov     [rsp],rax
    mov     rsi,[rsp+0D8h]
    mov     [rsp+8],rsi
    call    fn0
    nop     [rcx+7Ch]
    jmp     L13
    nop     [rax+rax]
L2:
    mov     rax,[rsp+0C8h]
    mov     [rsp+98h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+0D8h]
    mov     [rsp+8],rdx
    call    fn1
    nop     [rcx+7Ch]
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     rax,[rsp+0A0h]
    mov     [rsp],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+0D0h]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+0E0h]
    mov     [rsp+18h],rdi
    call    fn2
    nop     [rcx+7Fh]
    jmp     L19
    nop     [rax+rax]
    nop     [rax]
L4:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+90h],11Bh
    mov     rdx,[rsp+88h]
    mov     rsi,[rsp+90h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],11Bh
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFFB8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0E8h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym5]
    lea     rdx,[site6]
    mov     ecx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+88h]
    jmp     L7
L6:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym7]
L7:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L8:
    lea     rdi,[rsp+0B0h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,0B8h
    ret
    nop     [rax]
L9:
    test    byte ptr [rsp+7Dh],0FFh
    je      L12
    jmp     L11
    nop     [rax]
L10:
    jmp     L5
L11:
    jmp     L2
L12:
    mov     rax,[rsp+0C0h]
    cmp     rax,0
    sete    [rsp+7Bh]
    movzx   esi,byte ptr [rsp+7Bh]
    xor     sil,1
    mov     [rsp+7Eh],sil
    test    byte ptr [rsp+7Eh],0FFh
    je      L5
    jmp     L2
L13:
    test    byte ptr [rsp+7Ch],0FFh
    je      L10
    jmp     L9
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    test    byte ptr [rsp+0AFh],0FFh
    je      L17
    jmp     L16
    nop     [rax]
L15:
    jmp     L4
L16:
    jmp     L3
L17:
    mov     rax,[rsp+0C8h]
    cmp     rax,0
    sete    [rsp+7Bh]
    movzx   esi,byte ptr [rsp+7Bh]
    xor     sil,1
    mov     [rsp+7Dh],sil
    test    byte ptr [rsp+7Dh],0FFh
    je      L4
    jmp     L3
L18:
    test    byte ptr [rsp+7Ch],0FFh
    je      L15
    jmp     L14
L19:
    test    byte ptr [rsp+7Fh],0FFh
    je      L5
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L20:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx+30h]
    jmp     L22
L21:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L22:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L20

fn std::ptr::swap_nonoverlapping_bytes
    sub     rsp,78h
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_DivUW64
    mov     qword ptr [rsp+18h],8
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE8h
    mov     ecx,0FFFFFFA8h
    call    ryo_h_RemUW64
    mov     rax,[rsp+50h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFACh
    mov     edx,0FFFFFFD0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFACh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,2
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
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+88h]
    mov     [rsp+28h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+68h]
    jmp     L2
L2:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFACh
    mov     edx,0FFFFFFD0h
    xor     ecx,ecx
    xor     r8d,r8d
    mov     r9,100000000h
    call    ryo_h_DiscrNicheW64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    mov     edx,0FFFFFFACh
    call    ryo_h_ZextW32W64
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L3:
    .long   L5
    .long   L4
    .long   L6
L4:
    mov     rax,[rsp+40h]
    mov     [rsp+38h],rax
    imul    rdx,[rsp+50h],8
    mov     [rsp+30h],rdx
    mov     rsi,[rsp+80h]
    imul    rcx,rdx,1
    add     rsi,rcx
    mov     [rsp+28h],rsi
    mov     rdi,[rsp+88h]
    imul    rcx,rdx,1
    add     rdi,rcx
    mov     [rsp+20h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+60h]
    jmp     L5
L5:
    lea     rdi,[rsp+70h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,78h
    ret
L6:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_chunks::<8>
    sub     rsp,98h
    mov     rax,[rsp+0B0h]
    mov     qword ptr [rsp+80h],0
    mov     [rsp+88h],rax
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    cmp     rax,rdx
    setb    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L3
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L0
L2:
    mov     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L5
    jmp     L4
L3:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L4:
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+68h]
L5:
    mov     rax,[rsp+40h]
    add     rax,1
    mov     [rsp+80h],rax
    mov     rdx,[rsp+40h]
    mov     qword ptr [rsp+50h],1
    mov     [rsp+48h],rdx
    mov     rdi,[rsp+0A0h]
    imul    rcx,rdx,8
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     r8,[rsp+0A8h]
    imul    rcx,rdx,8
    add     r8,rcx
    mov     [rsp+30h],r8
    mov     [rsp],rdi
    mov     [rsp+8],r8
    call    fn2
    nop     [rcx+78h]
    jmp     L1

fn std::ptr::swap_nonoverlapping_bytes::swap_nonoverlapping_short
    sub     rsp,78h
    mov     rax,[rsp+90h]
    mov     [rsp+50h],rax
    mov     qword ptr [rsp+48h],0
    and     rax,4
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L0
    mov     rdi,[rsp+48h]
    mov     r8,[rsp+80h]
    imul    rcx,rdi,1
    add     r8,rcx
    mov     [rsp+40h],r8
    mov     r9,[rsp+48h]
    mov     r10,[rsp+88h]
    imul    rcx,r9,1
    add     r10,rcx
    mov     [rsp+30h],r10
    mov     [rsp],r8
    mov     [rsp+8],r10
    call    fn0
    nop     [rcx+70h]
    mov     rax,[rsp+48h]
    or      rax,4
    mov     [rsp+48h],rax
    jmp     L0
L0:
    mov     rax,[rsp+50h]
    and     rax,2
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L1
    mov     rsi,[rsp+48h]
    mov     rdi,[rsp+80h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     r8,[rsp+48h]
    mov     r9,[rsp+88h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+30h],r9
    mov     [rsp],rdi
    mov     [rsp+8],r9
    call    fn1
    nop     [rcx+70h]
    mov     rax,[rsp+48h]
    or      rax,2
    mov     [rsp+48h],rax
    jmp     L1
L1:
    mov     rax,[rsp+50h]
    and     rax,1
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L2
    mov     rsi,[rsp+48h]
    mov     rdi,[rsp+80h]
    imul    rcx,rsi,1
    add     rdi,rcx
    mov     [rsp+40h],rdi
    mov     r8,[rsp+48h]
    mov     r9,[rsp+88h]
    imul    rcx,r8,1
    add     r9,rcx
    mov     [rsp+30h],r9
    mov     [rsp],rdi
    mov     [rsp+8],r9
    call    fn2
    nop     [rcx+70h]
    mov     rax,[rsp+48h]
    or      rax,1
    mov     [rsp+48h],rax
    jmp     L2
L2:
    lea     rdi,[rsp+70h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,78h
    ret

fn std::rt::lang_start::<()>
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     [rsp+38h],rax
    lea     rdx,[rsp+38h]
    mov     [rsp+40h],rdx
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFA0h
    mov     edx,0FFFFFFE8h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+10h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+18h],rdx
    movzx   esi,byte ptr [rsp+88h]
    mov     [rsp+20h],sil
    lea     rdi,[rsp+60h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFD0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx+58h]
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn std::rt::lang_start::<()>::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+1Ch]
    call    fn1
    nop     [rcx+1Bh]
    movzx   eax,byte ptr [rsp+1Bh]
    mov     [rsp+1Ah],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,4
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>
    sub     rsp,38h
    lea     rax,[rsp+50h]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+20h]
    mov     [rsp+10h],rax
    call    fn0
    nop     [rcx+30h]
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFF8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+30h]
    mov     rsi,rax
    mov     edx,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L0

fn std::slice::<impl [(u32, u32)]>::sort_by_key::<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+68h]
    mov     [rsp+18h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+24h]
    lea     rax,[rsp+24h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+60h]
    mov     rdx,[rdx]
    mov     [rsp+38h],rdx
    mov     rsi,[rsp+70h]
    mov     [rsp+10h],rsi
    mov     [rsp],rdx
    mov     [rsp+8],rsi
    call    fn1
    nop     [rcx+20h]
    lea     rax,[rsp+20h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+28h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn2
    nop     [rcx+4Fh]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,58h
    ret
    nop     [rax+rax]
    nop     [rax]
L0:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::as_uninit_slice_mut
    sub     rsp,88h
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+10h]
    imul    rcx,rdx,8
    add     rax,rcx
    mov     [rsp+50h],rax
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+30h],8
    cmp     qword ptr [rsp+30h],0
    je      L1
    jmp     L2
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+90h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+40h]
    sub     rdx,rax
    mov     [rsp+48h],rdx
    mov     byte ptr [rsp+37h],1
    test    byte ptr [rsp+37h],0FFh
    je      L4
    jmp     L3
L1:
    mov     qword ptr [rsp+40h],0FFFFFFFFFFFFFFFFh
    jmp     L0
L2:
    mov     rax,[rsp+90h]
    mov     rax,[rax]
    mov     [rsp+40h],rax
    jmp     L0
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+40h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],8
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+48h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+60h]
L4:
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+48h]
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,88h
    ret

fn std::slice::<impl core::slice::sort::stable::BufGuard<(u32, u32)> for std::vec::Vec<(u32, u32)>>::with_capacity
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx+18h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+48h],0
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn std::slice::Iter::<'_, u32>::make_slice
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     rax,[rax]
    mov     [rsp+78h],rax
    mov     [rsp+68h],rax
    mov     byte ptr [rsp+2Fh],0
    test    byte ptr [rsp+2Fh],0FFh
    je      L0
    mov     rdi,[rsp+0A0h]
    mov     rdi,[rdi+8]
    mov     [rsp+70h],rdi
    jmp     L1
L0:
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+8]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+0A0h]
    mov     rdx,[rdx]
    mov     [rsp+58h],rdx
    mov     [rsp+50h],rax
    mov     [rsp+48h],rdx
    mov     rsi,[rsp+60h]
    mov     [rsp+40h],rsi
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L4
    jmp     L3
    xchg    ax,ax
L1:
    mov     byte ptr [rsp+2Fh],1
    test    byte ptr [rsp+2Fh],0FFh
    je      L9
    jmp     L8
    nop     [rax+rax]
    xchg    ax,ax
L2:
    jmp     L1
L3:
    mov     rax,[rsp+60h]
    mov     [rsp+38h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+30h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx+70h]
L4:
    mov     qword ptr [rsp+28h],0
    cmp     qword ptr [rsp+28h],4
    setb    [rsp+3Fh]
    test    byte ptr [rsp+3Fh],0FFh
    je      L5
    mov     qword ptr [rsp+28h],4
    mov     r8,[rsp+28h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+3Eh]
    test    byte ptr [rsp+3Eh],0FFh
    je      L5
    mov     r10,[rsp+40h]
    sub     r10,[rsp+48h]
    mov     [rsp+70h],r10
    mov     qword ptr [rsp+28h],4
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFF98h
    call    ryo_h_DivUW64
    jmp     L2
L5:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+8],49h
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+90h]
    lea     rsi,[sym4]
    lea     rdx,[site5]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L6
    call    rax
    nop     [rcx+70h]
    jmp     L7
L6:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L7:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L8:
    mov     rax,[rsp+78h]
    mov     [rsp+60h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],4
    mov     qword ptr [rsp+10h],4
    mov     rdi,[rsp+70h]
    mov     [rsp+18h],rdi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx+70h]
L9:
    mov     rax,[rsp+68h]
    mov     rdx,[rsp+70h]
    mov     [rsp+80h],rax
    mov     [rsp+88h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,98h
    ret

fn std::slice::Iter::<'_, u32>::new
    sub     rsp,68h
    mov     rax,[rsp+78h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    mov     rsi,[rsp+78h]
    mov     [rsp+20h],rsi
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFB8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    mov     rax,[rsp+10h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+0Fh],0
    test    byte ptr [rsp+0Fh],0FFh
    je      L0
    mov     rdi,[rsp+40h]
    mov     [rsp+48h],rdi
    jmp     L1
L0:
    mov     rax,[rsp+38h]
    imul    rcx,[rsp+40h],4
    add     rax,rcx
    mov     [rsp+48h],rax
L1:
    mov     rax,[rsp+38h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_Ret
    add     rsp,68h
    ret

fn std::slice::from_raw_parts::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+76h]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rsp+0A8h],0
    je      L9
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],117h
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],117h
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0C0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+80h]
    jmp     L5
L4:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L6:
    mov     rax,[rsp+0A0h]
    cmp     rax,0
    sete    [rsp+75h]
    movzx   esi,byte ptr [rsp+75h]
    xor     sil,1
    mov     [rsp+77h],sil
    test    byte ptr [rsp+77h],0FFh
    je      L3
    jmp     L0
    nop
L7:
    jmp     L3
L8:
    test    byte ptr [rsp+76h],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rsp+68h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+20h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF90h
    mov     ecx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+68h]
    setbe   [rsp+76h]
    test    byte ptr [rsp+76h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L12:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+28h]
    jmp     L14
L13:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::slice::from_raw_parts_mut::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     [rsp+68h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+0B0h]
    mov     [rsp+8],rdx
    call    fn0
    nop     [rcx+76h]
    jmp     L8
    nop     [rax+rax]
    nop
L0:
    cmp     qword ptr [rsp+0A8h],0
    je      L9
    jmp     L10
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L2:
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],11Bh
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF98h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+30h],11Bh
    mov     rdx,[rsp+30h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+58h]
    mov     [rsp+60h],rsi
    mov     [rsp+68h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0C0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym3]
    lea     rdx,[site4]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx+80h]
    jmp     L5
L4:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym5]
L5:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
    xchg    ax,ax
L6:
    mov     rax,[rsp+0A0h]
    cmp     rax,0
    sete    [rsp+75h]
    movzx   esi,byte ptr [rsp+75h]
    xor     sil,1
    mov     [rsp+77h],sil
    test    byte ptr [rsp+77h],0FFh
    je      L3
    jmp     L0
    nop
L7:
    jmp     L3
L8:
    test    byte ptr [rsp+76h],0FFh
    je      L7
    jmp     L6
L9:
    mov     qword ptr [rsp+68h],0FFFFFFFFFFFFFFFFh
    jmp     L11
L10:
    mov     rax,7FFFFFFFFFFFFFFFh
    mov     [rsp+20h],rax
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFF90h
    mov     ecx,18h
    call    ryo_h_DivUW64
L11:
    mov     rax,[rsp+0B8h]
    cmp     rax,[rsp+68h]
    setbe   [rsp+76h]
    test    byte ptr [rsp+76h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop
L12:
    lea     rdi,[rsp+90h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF90h
    call    ryo_h_CallExt
    test    rax,rax
    je      L13
    call    rax
    nop     [rcx+28h]
    jmp     L14
L13:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+20]
    call    qword ptr [sym8]
L14:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+90h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L12

fn std::slice::stable_sort::<(u32, u32), {closure@std::slice::<impl [(u32, u32)]>::sort_by_key<u32, {closure@bench/sort.rs:60:19: 60:28}>::{closure#0}}>
    sub     rsp,48h
    lea     rax,[rsp+60h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+26h],0
    test    byte ptr [rsp+26h],0FFh
    je      L3
    jmp     L2
    nop     [rax]
L0:
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax]
L1:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    jmp     L0
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+28h],rax
    cmp     rax,2
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L7
    jmp     L6
    xchg    ax,ax
L4:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    jmp     L2
L6:
    jmp     L5
L7:
    cmp     qword ptr [rsp+28h],14h
    setbe   [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L8
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],1
    mov     rdx,[rsp+30h]
    mov     [rsp+18h],rdx
    call    fn0
    nop     [rcx+40h]
    jmp     L9
L8:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    call    fn1
    nop     [rcx+40h]
    jmp     L4
L9:
    jmp     L5
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFF8h
    call    ryo_h_Lpad
    jmp     L1

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp],rax
    call    fn0
    nop     [rcx+10h]
    lea     rdi,[rsp+10h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,18h
    ret

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>
    sub     rsp,108h
    mov     byte ptr [rsp+0B7h],1
    lea     rdx,[rsp+118h]
    mov     [rsp+98h],rdx
    mov     [rsp],rdx
    call    fn0
    nop     [rcx+70h]
    mov     rax,[rsp+70h]
    mov     [rsp+98h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    mov     rax,[rsp+88h]
    mov     [rsp+0F8h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L1
    .long   L8
L1:
    mov     rax,[rsp+90h]
    mov     [rsp+80h],rax
    mov     rdx,[rsp+110h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn1
    nop     [rcx+0B8h]
    mov     rax,[rsp+110h]
    mov     rax,[rax+8]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+110h]
    lea     rdx,[rdx+10h]
    mov     [rsp+60h],rdx
    mov     rdx,[rdx]
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    mov     byte ptr [rsp+0B7h],0
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF58h
    mov     edx,18h
    call    ryo_h_MovW128
    mov     rax,[rsp+78h]
    mov     [rsp+50h],rax
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF40h
    mov     edx,0FFFFFF68h
    call    ryo_h_MovW128
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFF58h
    call    ryo_h_MovW128
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFF40h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx+0B8h]
    lea     rdi,[rsp+100h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,108h
    ret
L2:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+70h],11h
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],11h
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rdx
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF00h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFF10h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+100h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+0B8h]
    jmp     L4
L3:
    lea     rdi,[rsp+100h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L4:
    lea     rdi,[rsp+100h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+100h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+0B7h],0FFh
    je      L5
    jmp     L6
L8:
    lea     rdi,[rsp+100h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+100h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L7

fn std::vec::Vec::<(u32, u32)>::extend_trusted::<std::iter::Map<std::slice::Iter<'_, u32>, {closure@bench/sort.rs:59:50: 59:54}>>::{closure#0}
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+8]
    imul    rcx,rdx,8
    add     rax,rcx
    mov     rcx,[rsp+48h]
    mov     [rax],rcx
    mov     rsi,[rsp+40h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+40h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn std::vec::Vec::<(u32, u32)>::reserve
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+10h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rsp+70h]
    mov     [rsp],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+88h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    nop     [rax]
L3:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L4:
    mov     rax,[rsp+48h]
    sub     rax,[rsp+78h]
    cmp     rax,[rsp+0A8h]
    setb    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L3
    jmp     L0
L5:
    mov     qword ptr [rsp+48h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    jmp     L4

fn std::vec::Vec::<T, A>::set_len::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A8h]
    cmp     rax,[rsp+0A0h]
    jb      L0
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFF0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+88h],0C6h
    mov     rdx,[rsp+80h]
    mov     rsi,[rsp+88h]
    mov     [rsp+60h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+38h],0C6h
    mov     rdx,[rsp+38h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+60h]
    mov     [rsp+68h],rsi
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF70h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+10h],0
    mov     rdx,[rsp+0B0h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+90h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF98h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+80h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn std::vec::Vec::<u32>::append_elements
    sub     rsp,88h
    mov     rax,[rsp+0A0h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+90h]
    mov     rax,[rax+10h]
    mov     [rsp+70h],rax
    mov     rcx,1FFFFFFFFFFFFFFFh
    cmp     rax,rcx
    setbe   [rsp+6Fh]
    cmp     qword ptr [rsp+78h],0
    jbe     L0
    mov     rsi,[rsp+98h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+90h]
    mov     rdi,[rdi+8]
    imul    rcx,rax,4
    add     rdi,rcx
    mov     [rsp+58h],rdi
    mov     byte ptr [rsp+47h],1
    test    byte ptr [rsp+47h],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rax,[rsp+90h]
    mov     rax,[rax+10h]
    add     rax,[rsp+78h]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+90h]
    mov     rcx,[rsp+30h]
    mov     [rdx+10h],rcx
    lea     rdi,[rsp+80h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,88h
    ret
L1:
    mov     rax,[rsp+98h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+58h]
    mov     [rsp+48h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    mov     qword ptr [rsp+10h],4
    mov     qword ptr [rsp+18h],4
    mov     r8,[rsp+78h]
    mov     [rsp+20h],r8
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA8h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    call    fn2
    nop     [rcx+78h]
L2:
    imul    rax,[rsp+78h],4
    mov     [rsp+40h],rax
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFE0h
    mov     ecx,0FFFFFFC0h
    call    ryo_h_Memcpy
    jmp     L0

fn std::vec::Vec::<u32>::clear
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx+10h]
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     qword ptr [rsp+10h],0
    mov     rdi,[rsp+50h]
    mov     rcx,[rsp+10h]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+30h]
    mov     [rsp+20h],r8
    mov     r9,[rsp+38h]
    mov     [rsp+28h],r9
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFE0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    lea     rdi,[rsp+40h]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,48h
    ret

fn std::vec::Vec::<u32>::extend_from_slice
    sub     rsp,78h
    mov     rax,[rsp+90h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+90h]
    mov     [rsp+30h],rsi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFB8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     rax,[rsp+20h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+1Fh],0
    test    byte ptr [rsp+1Fh],0FFh
    je      L2
    jmp     L1
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+70h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,78h
    ret
L1:
    mov     rax,[rsp+58h]
    mov     [rsp+38h],rax
    jmp     L3
L2:
    mov     rax,[rsp+50h]
    imul    rcx,[rsp+58h],4
    add     rax,rcx
    mov     [rsp+38h],rax
L3:
    mov     rax,[rsp+50h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+68h],rdx
    mov     rsi,[rsp+80h]
    mov     [rsp],rsi
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFFF0h
    call    ryo_h_MovW128
    call    fn0
    nop     [rcx+70h]
    jmp     L0

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>
    sub     rsp,118h
    mov     byte ptr [rsp+0C7h],1
    lea     rdx,[rsp+128h]
    mov     [rsp+0A8h],rdx
    mov     [rsp],rdx
    call    fn0
    nop     [rcx+80h]
    mov     rax,[rsp+80h]
    mov     [rsp+0A8h],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    mov     rax,[rsp+98h]
    mov     [rsp+108h],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFF8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L2
    .long   L1
    .long   L8
L1:
    mov     rax,[rsp+0A0h]
    mov     [rsp+90h],rax
    mov     rdx,[rsp+120h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn1
    nop     [rcx+0C8h]
    mov     rax,[rsp+120h]
    mov     rax,[rax+8]
    mov     [rsp+88h],rax
    mov     rdx,[rsp+120h]
    lea     rdx,[rdx+10h]
    mov     [rsp+70h],rdx
    mov     rdx,[rdx]
    mov     rsi,[rsp+70h]
    mov     [rsp+78h],rsi
    mov     [rsp+80h],rdx
    mov     byte ptr [rsp+0C7h],0
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF50h
    mov     edx,18h
    mov     ecx,18h
    call    ryo_h_Copy
    mov     rax,[rsp+88h]
    mov     [rsp+58h],rax
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF38h
    mov     edx,0FFFFFF68h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF50h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF08h
    mov     edx,0FFFFFF38h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn2
    nop     [rcx+0C8h]
    lea     rdi,[rsp+110h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,118h
    ret
L2:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF68h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+80h],11h
    mov     rdx,[rsp+78h]
    mov     rsi,[rsp+80h]
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+48h],11h
    mov     rdx,[rsp+48h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+70h]
    mov     [rsp+88h],rsi
    mov     [rsp+90h],rdx
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFF78h
    call    ryo_h_MovW128
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFF00h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+110h]
    lea     rsi,[sym6]
    lea     rdx,[site7]
    mov     ecx,0FFFFFF28h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx+0C8h]
    jmp     L4
L3:
    lea     rdi,[rsp+110h]
    lea     rsi,[ro+4]
    call    qword ptr [sym8]
L4:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+110h]
    mov     esi,0FFFFFFA0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L6:
    jmp     L5
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+0C7h],0FFh
    je      L5
    jmp     L6
L8:
    lea     rdi,[rsp+110h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+110h]
    mov     rsi,rax
    mov     edx,0FFFFFFA0h
    call    ryo_h_Lpad
    jmp     L7

fn std::vec::Vec::<u32>::extend_trusted::<std::iter::Map<std::ops::Range<usize>, {closure@bench/sort.rs:52:37: 52:40}>>::{closure#0}
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+10h]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+8]
    imul    rcx,rdx,4
    add     rax,rcx
    mov     ecx,[rsp+48h]
    mov     [rax],ecx
    mov     rsi,[rsp+40h]
    mov     rsi,[rsi+8]
    add     rsi,1
    mov     [rsp],rsi
    mov     rdi,[rsp+40h]
    mov     rcx,[rsp]
    mov     [rdi+8],rcx
    lea     rdi,[rsp+30h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,38h
    ret

fn std::vec::Vec::<u32>::push
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     edx,[rsp+38h]
    mov     [rsp+8],edx
    call    fn0
    nop     [rcx+18h]
    lea     rdi,[rsp+20h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,28h
    ret

fn std::vec::Vec::<u32>::push_mut
    sub     rsp,68h
    mov     rax,[rsp+70h]
    mov     rax,[rax+10h]
    mov     [rsp+30h],rax
    mov     qword ptr [rsp+10h],4
    cmp     qword ptr [rsp+10h],0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rsp+70h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn0
    nop     [rcx+50h]
    jmp     L1
    nop     [rax]
L1:
    mov     rax,[rsp+70h]
    mov     rax,[rax+8]
    imul    rcx,[rsp+30h],4
    add     rax,rcx
    mov     [rsp+48h],rax
    mov     edx,[rsp+78h]
    mov     [rsp+2Ch],edx
    mov     ecx,[rsp+2Ch]
    mov     [rax],ecx
    mov     rsi,[rsp+30h]
    add     rsi,1
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+70h]
    mov     rcx,[rsp+10h]
    mov     [rdi+10h],rcx
    mov     r8,[rsp+48h]
    mov     [rsp+58h],r8
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFF8h
    mov     edx,8
    call    ryo_h_Ret
    add     rsp,68h
    ret
    nop     [rax+rax]
    nop     [rax]
L2:
    lea     rdi,[rsp+60h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    jmp     L2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+20h]
    je      L0
    jmp     L1
L5:
    mov     qword ptr [rsp+20h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    jmp     L4
    lea     rdi,[rsp+60h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3

fn std::vec::Vec::<u32>::reserve
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    mov     rax,[rax+10h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+0A0h]
    mov     [rsp+70h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    cmp     rax,0
    je      L5
    jmp     L6
    nop     [rax]
L0:
    mov     rax,[rsp+70h]
    mov     [rsp],rax
    mov     rdx,[rsp+78h]
    mov     [rsp+8],rdx
    mov     rsi,[rsp+0A8h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF88h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+90h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFFA0h
    call    ryo_h_CallExt
    test    rax,rax
    je      L1
    call    rax
    nop     [rcx+88h]
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    nop     [rax]
L3:
    lea     rdi,[rsp+90h]
    xor     esi,esi
    xor     edx,edx
    call    ryo_h_Ret
    add     rsp,98h
    ret
    nop     [rax]
L4:
    mov     rax,[rsp+48h]
    sub     rax,[rsp+78h]
    cmp     rax,[rsp+0A8h]
    setb    [rsp+5Fh]
    test    byte ptr [rsp+5Fh],0FFh
    je      L3
    jmp     L0
L5:
    mov     qword ptr [rsp+48h],0FFFFFFFFFFFFFFFFh
    jmp     L4
L6:
    mov     rax,[rsp+70h]
    mov     rax,[rax]
    mov     [rsp+48h],rax
    jmp     L4

fn std::vec::Vec::<u32>::with_capacity
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     [rsp],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
    lea     rdx,[k0]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn1
    nop     [rcx+18h]
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD8h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+48h],0
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    mov     edx,18h
    call    ryo_h_Ret
    add     rsp,58h
    ret

fn std::vec::partial_eq::<impl std::cmp::PartialEq for std::vec::Vec<u32>>::eq
    sub     rsp,88h
    mov     rax,[rsp+90h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+90h]
    mov     rdx,[rdx+10h]
    mov     [rsp+60h],rdx
    mov     [rsp+68h],rax
    mov     [rsp+70h],rdx
    mov     rsi,[rsp+98h]
    mov     rsi,[rsi+8]
    mov     rdi,[rsp+98h]
    mov     rdi,[rdi+10h]
    mov     [rsp+48h],rdi
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdi
    mov     r8,[rsp+60h]
    cmp     r8,[rsp+48h]
    jne     L0
    mov     [rsp+38h],rax
    mov     [rsp+30h],rsi
    mov     [rsp],rax
    mov     [rsp+8],rsi
    mov     [rsp+10h],r8
    call    fn0
    nop     [rcx+7Fh]
    jmp     L1
L0:
    mov     byte ptr [rsp+7Fh],0
L1:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFFFh
    mov     edx,1
    call    ryo_h_Ret
    add     rsp,88h
    ret

