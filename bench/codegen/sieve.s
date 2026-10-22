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

fn <alloc::raw_vec::RawVec<bool> as std::ops::Drop>::drop
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

fn <bool as std::vec::is_zero::IsZero>::is_zero
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,byte ptr [rax]
    xor     al,1
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0B0h
    mov     byte ptr [rbp-1Ah],1
    mov     byte ptr [rbp-19h],1
    lea     rsi,[rbp+18h]
    mov     [rbp-38h],rsi
    mov     [rbp-0B0h],rsi
    call    fn0
    nop     [rcx-29h]
    test    byte ptr [rbp-29h],0FFh
    je      L2
    mov     byte ptr [rbp-19h],0
    mov     rsi,[rbp+10h]
    mov     [rbp-0B0h],rsi
    mov     byte ptr [rbp-0A8h],1
    mov     edi,0FFFFFF60h
    lea     rsi,[k1]
    mov     edx,10h
    call    ryo_h_Const
    lea     rdi,[sym2]
    lea     rsi,[site3]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-68h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    jmp     L11
L2:
    mov     byte ptr [rbp-19h],0
    mov     rdx,[rbp+10h]
    mov     [rbp-0B0h],rdx
    mov     edi,0FFFFFF58h
    lea     rsi,[k5]
    mov     edx,10h
    call    ryo_h_Const
    call    fn6
    nop     [rcx-60h]
    jmp     L18
    nop     [rax+rax]
    nop     [rax]
L3:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFC0h
    mov     edx,18h
    call    ryo_h_Copy
    nop     [rax+rax]
    nop     [rax]
L4:
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    lea     rax,[rbp-40h]
    mov     [rbp-88h],rax
    mov     [rbp-0B0h],rax
    call    fn7
    nop     [rcx-88h]
    jmp     L9
L6:
    test    byte ptr [rbp-1Ah],0FFh
    jne     L10
    nop     [rax+rax]
    nop
L7:
    mov     edi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L8:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-19h],0FFh
    je      L6
    jmp     L8
L10:
    jmp     L7
L11:
    mov     rax,[rbp-68h]
    mov     [rbp-70h],rax
    mov     edi,0FFFFFF90h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L12]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L12:
    .long   L17
    .long   L14
    .long   L13
L13:
    call    ryo_h_Unreachable
    ud2
L14:
    mov     edi,0FFFFFF80h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF50h
    mov     esi,0FFFFFF80h
    call    ryo_h_MovW128
    lea     rdi,[sym8]
    lea     rsi,[site9]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx-1Ah]
    jmp     L16
L15:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L16:
    call    ryo_h_Unreachable
    ud2
L17:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp+10h]
    mov     [rbp-8],rax
    jmp     L4
L18:
    mov     edi,0FFFFFFB0h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-30h],0
    lea     rdx,[rbp-40h]
    mov     [rbp-48h],rdx
    mov     byte ptr [rbp-1Ah],0
    movzx   edi,byte ptr [rbp+18h]
    mov     [rbp-49h],dil
    mov     [rbp-0B0h],rdx
    mov     r8,[rbp+10h]
    mov     [rbp-0A8h],r8
    mov     [rbp-0A0h],dil
    call    fn11
    nop     [rcx-18h]
    jmp     L3
    nop     [rax+rax]
    nop     [rax+rax]
L19:
    lea     rdi,[sym12]
    lea     rsi,[site13]
    mov     edx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L20
    call    rax
    nop     [rcx-80h]
    jmp     L21
L20:
    mov     rdi,rbp
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
L21:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L19
    mov     rdi,rax
    mov     esi,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

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

fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    mov     [rbp-40h],rax
    mov     [rbp-38h],rdx
    call    fn0
    nop     [rcx-11h]
    mov     edi,0FFFFFFF8h
    mov     esi,0FFFFFFEFh
    call    ryo_h_ZextW8W64
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L0:
    mov     edi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     byte ptr [rbp-11h],1
    mov     byte ptr [rbp-12h],1
    lea     rsi,[rbp+10h]
    mov     [rbp-50h],rsi
    mov     [rbp-70h],rsi
    call    fn0
    nop     [rcx-48h]
    mov     edi,0FFFFFFD0h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rbp-30h]
    mov     [rbp-50h],rax
    mov     edi,0FFFFFFB0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L9
    .long   L10
    .long   L8
    nop     [rax]
L1:
    mov     edi,0FFFFFFC0h
    mov     esi,0FFFFFFD0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     qword ptr [rbp-60h],0
    call    fn1
    nop     [rcx-8]
    jmp     L11
    nop     [rax+rax]
L2:
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    mov     edi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L4:
    test    byte ptr [rbp-11h],0FFh
    je      L3
    jmp     L3
    nop     [rax+rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rbp-12h],0FFh
    je      L4
    jmp     L5
    nop     [rax+rax]
L7:
    mov     byte ptr [rbp-12h],0
    mov     edi,0FFFFFFC0h
    mov     esi,10h
    call    ryo_h_MovW128
    mov     byte ptr [rbp-11h],0
    mov     edi,0FFFFFF90h
    mov     esi,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn2
    nop     [rcx-30h]
    jmp     L1
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    mov     qword ptr [rbp-10h],0FFFFFFFFFFFFFFFFh
    jmp     L7
L10:
    mov     rax,[rbp-28h]
    mov     [rbp-10h],rax
    jmp     L7
L11:
    mov     rax,[rbp-8]
    mov     [rbp-70h],rax
    mov     rdx,[rbp-10h]
    mov     [rbp-68h],rdx
    call    fn3
    nop     [rcx-10h]
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::iter::Rev<std::ops::RangeInclusive<usize>> as std::iter::Iterator>::find::<{closure@bench/sieve.rs:25:39: 25:43}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     [rbp-30h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-28h],rdx
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     qword ptr [rbp-18h],1
    cmp     qword ptr [rbp-18h],1
    sete    [rbp-19h]
    mov     rsi,[rbp+10h]
    mov     [rbp-8],rsi
    mov     qword ptr [rbp-10h],1
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::branch
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     edi,0FFFFFFE8h
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
    .long   L3
    .long   L2
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L4
L3:
    mov     qword ptr [rbp-10h],0
L4:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::from_output
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     qword ptr [rbp-10h],0
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::ops::RangeInclusive<usize> as std::iter::DoubleEndedIterator>::rfind::<{closure@bench/sieve.rs:25:39: 25:43}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+18h]
    mov     [rbp-28h],rax
    mov     rdx,[rbp+10h]
    mov     [rbp-50h],rdx
    mov     [rbp-48h],rax
    call    fn0
    nop     [rcx-20h]
    mov     rax,[rbp-20h]
    mov     [rbp-28h],rax
    mov     edi,0FFFFFFD8h
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
    .long   L3
    .long   L2
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-18h]
    mov     [rbp-8],rax
    mov     qword ptr [rbp-10h],1
    jmp     L6
L3:
    mov     qword ptr [rbp-10h],0
    jmp     L6
    nop     [rax+rax]
    nop     [rax]
L4:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
L5:
    jmp     L4
L6:
    mov     rax,[rbp-20h]
    mov     [rbp-38h],rax
    mov     edi,0FFFFFFC8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L7]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L7:
    .long   L5
    .long   L4
    .long   L1

fn <std::ops::RangeInclusive<usize> as std::iter::Iterator>::rev
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

fn <std::ops::RangeInclusive<usize> as std::iter::range::RangeInclusiveIteratorImpl>::spec_try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     byte ptr [rbp-2Ah],1
    mov     rdx,[rbp+10h]
    movzx   edx,byte ptr [rdx+10h]
    mov     [rbp-3Ah],dl
    test    byte ptr [rbp-3Ah],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L0:
    mov     byte ptr [rbp-2Ah],0
    call    fn0
    nop     [rcx-10h]
    jmp     L12
    nop     [rax+rax]
    xchg    ax,ax
L1:
    mov     byte ptr [rbp-2Ah],0
    mov     byte ptr [rbp-29h],1
    nop     [rax+rax]
L2:
    mov     rax,[rbp+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    call    fn1
    nop     [rcx-39h]
    test    byte ptr [rbp-39h],0FFh
    je      L7
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+8]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rdx
    mov     qword ptr [rbp-98h],1
    call    fn2
    nop     [rcx-48h]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-50h],rax
    mov     rdx,[rbp+10h]
    mov     rcx,[rbp-48h]
    mov     [rdx+8],rcx
    lea     rsi,[rbp+18h]
    mov     [rbp-78h],rsi
    mov     byte ptr [rbp-29h],0
    mov     r8,[rbp-50h]
    mov     [rbp-80h],r8
    mov     [rbp-0A0h],rsi
    mov     [rbp-98h],r8
    call    fn3
    nop     [rcx-70h]
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF90h
    call    ryo_h_MovW128
    call    fn4
    nop     [rcx-60h]
    mov     rax,[rbp-60h]
    mov     [rbp-20h],rax
    mov     edi,0FFFFFFE0h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L3:
    .long   L5
    .long   L6
    .long   L4
    nop     [rax+rax]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     byte ptr [rbp-29h],1
    jmp     L2
L6:
    mov     rax,[rbp-58h]
    mov     [rbp-68h],rax
    mov     [rbp-0A0h],rax
    call    fn5
    nop     [rcx-10h]
    jmp     L12
L7:
    mov     byte ptr [rbp-90h],1
    mov     rdx,[rbp+10h]
    movzx   ecx,byte ptr [rbp-90h]
    mov     [rdx+10h],cl
    mov     rsi,[rbp+10h]
    mov     [rbp-48h],rsi
    mov     rdi,[rbp+10h]
    lea     rdi,[rdi+8]
    mov     [rbp-50h],rdi
    mov     [rbp-0A0h],rsi
    mov     [rbp-98h],rdi
    call    fn6
    nop     [rcx-39h]
    test    byte ptr [rbp-39h],0FFh
    je      L11
    lea     rdx,[rbp+18h]
    mov     [rbp-68h],rdx
    mov     byte ptr [rbp-29h],0
    mov     rdi,[rbp+10h]
    mov     rdi,[rdi]
    mov     [rbp-70h],rdi
    mov     [rbp-0A0h],rdx
    mov     [rbp-98h],rdi
    call    fn7
    nop     [rcx-60h]
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn8
    nop     [rcx-50h]
    mov     rax,[rbp-50h]
    mov     [rbp-28h],rax
    mov     edi,0FFFFFFD8h
    xor     esi,esi
    mov     edx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L8]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
L8:
    .long   L9
    .long   L10
    .long   L4
L9:
    jmp     L11
L10:
    mov     rax,[rbp-48h]
    mov     [rbp-58h],rax
    mov     [rbp-0A0h],rax
    call    fn9
    nop     [rcx-10h]
    jmp     L12
L11:
    mov     byte ptr [rbp-29h],0
    call    fn10
    nop     [rcx-10h]
    jmp     L12
L12:
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L13:
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    mov     edi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L15:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    test    byte ptr [rbp-29h],0FFh
    je      L13
    jmp     L15
    nop     [rax+rax]
L17:
    jmp     L14
L18:
    test    byte ptr [rbp-2Ah],0FFh
    je      L14
    jmp     L17
L19:
    jmp     L0
L20:
    mov     rax,[rbp+10h]
    mov     [rbp-48h],rax
    mov     rdx,[rbp+10h]
    lea     rdx,[rdx+8]
    mov     [rbp-50h],rdx
    mov     [rbp-0A0h],rax
    mov     [rbp-98h],rdx
    call    fn11
    nop     [rcx-3Bh]
    movzx   eax,byte ptr [rbp-3Bh]
    xor     al,1
    mov     [rbp-39h],al
    test    byte ptr [rbp-39h],0FFh
    je      L1
    jmp     L0
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L13
    mov     rdi,rax
    mov     esi,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L16

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::filter::<{closure@bench/sieve.rs:24:37: 24:42}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    push    rbp
    mov     rbp,rsp
    sub     rsp,0C0h
    mov     byte ptr [rbp-0A1h],0
    test    byte ptr [rbp-0A1h],0FFh
    je      L0
    mov     rsi,[rbp+18h]
    cmp     rsi,0
    sete    [rbp-41h]
    jmp     L1
L0:
    mov     rax,[rbp+18h]
    mov     rdx,[rbp+10h]
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
    mov     [rbp-28h],r10
    jmp     L4
L3:
    mov     rax,[rbp+18h]
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
    nop     [rax+rax]
L4:
    lea     rax,[rbp+28h]
    mov     [rbp-58h],rax
    mov     byte ptr [rbp-31h],0
    mov     rsi,[rbp-48h]
    mov     rdi,[rbp+10h]
    mov     r8,[rbp-20h]
    imul    rcx,r8,1
    add     rdi,rcx
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
    nop     [rax]
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
    cmp     qword ptr [rbp-0A8h],1
    setb    [rbp-71h]
    test    byte ptr [rbp-71h],0FFh
    je      L17
    mov     qword ptr [rbp-0A8h],1
    mov     r8,[rbp-0A8h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-72h]
    test    byte ptr [rbp-72h],0FFh
    je      L17
    mov     r10,[rbp-70h]
    sub     r10,[rbp-68h]
    mov     [rbp-28h],r10
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::map::<usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::size_hint
    push    rbp
    mov     rbp,rsp
    sub     rsp,80h
    mov     byte ptr [rbp-59h],0
    test    byte ptr [rbp-59h],0FFh
    je      L0
    mov     rsi,[rbp+10h]
    mov     rsi,[rsi+8]
    mov     [rbp-20h],rsi
    jmp     L1
L0:
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
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
    nop     [rax+rax]
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
    cmp     qword ptr [rbp-60h],1
    setb    [rbp-49h]
    test    byte ptr [rbp-49h],0FFh
    je      L5
    mov     qword ptr [rbp-60h],1
    mov     r8,[rbp-60h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rbp-4Ah]
    test    byte ptr [rbp-4Ah],0FFh
    je      L5
    mov     r10,[rbp-48h]
    sub     r10,[rbp-40h]
    mov     [rbp-20h],r10
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

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    cmp     rax,[rbp+18h]
    setbe   [rbp-1]
    mov     byte ptr [rbp-2],1
    test    byte ptr [rbp-2],0FFh
    je      L0
    movzx   edi,byte ptr [rbp-1]
    mov     [rbp-20h],dil
    mov     edi,0FFFFFFE8h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx]
L0:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<bool> as std::ops::Deref>::deref
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
    push    rbp
    mov     rbp,rsp
    sub     rsp,60h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
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

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     rcx,[rbp-10h]
    mov     [rdx],rcx
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::iter::Step>::backward_unchecked
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
    sub     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFF0h
    mov     edx,18h
    mov     ecx,20h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-10h],0FFh
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
    nop     [rcx-18h]
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
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index
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
    imul    rcx,[rbp+20h],1
    add     rax,rcx
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
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
    imul    rcx,[rbp+20h],1
    add     rax,rcx
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

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

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+10h]
    mov     [rbp-30h],rax
    mov     edi,0FFFFFFC0h
    lea     rsi,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rbp-40h]
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
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0BAh
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
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
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0BAh
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
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

fn core::slice::<impl [bool]>::iter
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

fn main
    push    rbp
    mov     rbp,rsp
    sub     rsp,1B0h
    mov     qword ptr [rbp-1B0h],0C65D40h
    call    fn0
    nop     [rcx-8]
    mov     rax,[rbp-8]
    mov     [rbp-1B0h],rax
    call    fn1
    nop     [rcx-20h]
    lea     rax,[rbp-20h]
    mov     [rbp-60h],rax
    mov     [rbp-1B0h],rax
    call    fn2
    nop     [rcx-58h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFFA8h
    call    ryo_h_MovW128
    call    fn3
    nop     [rcx-48h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFFB8h
    call    ryo_h_MovW128
    call    fn4
    nop     [rcx-38h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn5
    nop     [rcx-28h]
    mov     qword ptr [rbp-1B0h],0
    mov     rdx,[rbp-8]
    mov     [rbp-1A8h],rdx
    call    fn6
    nop     [rcx-0B0h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFF50h
    mov     edx,18h
    call    ryo_h_Copy
    call    fn7
    nop     [rcx-98h]
    lea     rax,[rbp-98h]
    mov     [rbp-80h],rax
    lea     rdx,[rbp-20h]
    mov     [rbp-0B8h],rdx
    mov     [rbp-1B0h],rax
    mov     [rbp-1A8h],rdx
    call    fn8
    nop     [rcx-78h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFF88h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE60h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    nop     [rcx-68h]
    lea     rax,[rbp-28h]
    lea     rdx,[rbp-8]
    lea     rsi,[rbp-68h]
    mov     [rbp-0E8h],rax
    mov     [rbp-0E0h],rdx
    mov     [rbp-0D8h],rsi
    mov     [rbp-178h],rax
    mov     [rbp-1B0h],rax
    call    fn11
    nop     [rcx-140h]
    mov     rax,[rbp-0E0h]
    mov     [rbp-180h],rax
    mov     [rbp-1B0h],rax
    call    fn12
    nop     [rcx-150h]
    mov     rax,[rbp-0D8h]
    mov     [rbp-188h],rax
    mov     [rbp-1B0h],rax
    call    fn13
    nop     [rcx-160h]
    mov     edi,0FFFFFED0h
    mov     esi,0FFFFFEC0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEE0h
    mov     esi,0FFFFFEB0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFEF0h
    mov     esi,0FFFFFEA0h
    call    ryo_h_MovW128
    mov     edi,0FFFFFE98h
    lea     rsi,[k14]
    call    ryo_h_AddrAbs
    lea     rax,[rbp-130h]
    mov     [rbp-170h],rax
    mov     rdx,[rbp-168h]
    mov     [rbp-1B0h],rdx
    mov     [rbp-1A8h],rax
    call    fn15
    nop     [rcx-0D0h]
    mov     edi,0FFFFFE50h
    mov     esi,0FFFFFF30h
    call    ryo_h_MovW128
    lea     rdi,[sym16]
    lea     rsi,[site17]
    mov     edx,0FFFFFE68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-0C0h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L1:
    lea     rax,[rbp-20h]
    mov     [rbp-198h],rax
    mov     [rbp-1B0h],rax
    call    fn19
    nop     [rcx-198h]
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax]
L2:
    lea     rax,[rbp-20h]
    mov     [rbp-198h],rax
    mov     [rbp-1B0h],rax
    call    fn20
    nop     [rcx-198h]
    mov     edi,0FFFFFE70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L3:
    lea     rdi,[sym21]
    lea     rsi,[site22]
    mov     edx,0FFFFFE68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-190h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+20]
    call    qword ptr [sym23]
L5:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L2
    mov     rdi,rax
    mov     esi,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L3

fn main::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    movzx   eax,byte ptr [rax]
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn main::{closure#1}
    push    rbp
    mov     rbp,rsp
    sub     rsp,40h
    mov     rax,[rbp+18h]
    mov     rax,[rax]
    mov     [rbp-10h],rax
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx]
    mov     [rbp-20h],rdx
    mov     [rbp-40h],rdx
    mov     [rbp-38h],rax
    mov     edi,0FFFFFFD0h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    nop     [rcx-18h]
    mov     rax,[rbp-18h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn sieve
    push    rbp
    mov     rbp,rsp
    sub     rsp,170h
    mov     qword ptr [rbp-148h],1
    mov     edi,0FFFFFFB8h
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    mov     ecx,0FFFFFEB8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-40h],0FFh
    je      L2
    mov     edi,0FFFFFE90h
    lea     rsi,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[sym1]
    lea     rsi,[site2]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    nop     [rcx-140h]
    jmp     L1
L0:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp-48h]
    mov     [rbp-38h],rax
    mov     byte ptr [rbp-170h],1
    mov     [rbp-168h],rax
    call    fn4
    nop     [rcx-30h]
    lea     rax,[rbp-30h]
    mov     [rbp-58h],rax
    mov     [rbp-170h],rax
    mov     qword ptr [rbp-168h],0
    mov     edi,0FFFFFEA0h
    lea     rsi,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    nop     [rcx-50h]
    mov     byte ptr [rbp-150h],0
    mov     rdx,[rbp-50h]
    movzx   ecx,byte ptr [rbp-150h]
    mov     [rdx],cl
    lea     rsi,[rbp-30h]
    mov     [rbp-68h],rsi
    mov     [rbp-170h],rsi
    mov     qword ptr [rbp-168h],1
    mov     edi,0FFFFFEA0h
    lea     rsi,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    nop     [rcx-60h]
    mov     byte ptr [rbp-150h],0
    mov     rdx,[rbp-60h]
    movzx   ecx,byte ptr [rbp-150h]
    mov     [rdx],cl
    mov     qword ptr [rbp-70h],2
    nop     [rax+rax]
    xchg    ax,ax
L3:
    mov     rax,[rbp-70h]
    mov     [rbp-88h],rax
    mov     rdx,[rbp-70h]
    mov     [rbp-90h],rdx
    mov     edi,0FFFFFF60h
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFF78h
    mov     ecx,0FFFFFF70h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rbp-98h],0FFh
    je      L6
    mov     edi,0FFFFFE90h
    lea     rsi,[k9]
    call    ryo_h_AddrAbs
    lea     rdi,[sym10]
    lea     rsi,[site11]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    nop     [rcx-140h]
    jmp     L5
L4:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym12]
L5:
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rbp-0A0h]
    mov     [rbp-80h],rax
    mov     rdx,[rbp+10h]
    cmp     rdx,rax
    jb      L18
    lea     rsi,[rbp-30h]
    mov     [rbp-0B8h],rsi
    mov     rdi,[rbp-70h]
    mov     [rbp-0C0h],rdi
    mov     [rbp-170h],rsi
    mov     [rbp-168h],rdi
    mov     edi,0FFFFFEA0h
    lea     rsi,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    nop     [rcx-0B0h]
    mov     rax,[rbp-0B0h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-0A1h],al
    test    byte ptr [rbp-0A1h],0FFh
    je      L14
    mov     rsi,[rbp-70h]
    mov     [rbp-0D0h],rsi
    mov     rdi,[rbp-70h]
    mov     [rbp-0D8h],rdi
    mov     edi,0FFFFFF18h
    mov     esi,0FFFFFF20h
    mov     edx,0FFFFFF30h
    mov     ecx,0FFFFFF28h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rbp-0E0h],0FFh
    je      L9
    mov     edi,0FFFFFE90h
    lea     rsi,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[sym16]
    lea     rsi,[site17]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    nop     [rcx-140h]
    jmp     L8
L7:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L8:
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rbp-0E8h]
    mov     [rbp-0C8h],rax
    nop     [rax+rax]
    nop     [rax]
L10:
    mov     rax,[rbp-0C8h]
    mov     [rbp-0F8h],rax
    mov     rdx,[rbp+10h]
    cmp     rdx,rax
    jb      L14
    lea     rsi,[rbp-30h]
    mov     [rbp-108h],rsi
    mov     rdi,[rbp-0C8h]
    mov     [rbp-110h],rdi
    mov     [rbp-170h],rsi
    mov     [rbp-168h],rdi
    mov     edi,0FFFFFEA0h
    lea     rsi,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    nop     [rcx-100h]
    mov     byte ptr [rbp-150h],0
    mov     rdx,[rbp-100h]
    movzx   ecx,byte ptr [rbp-150h]
    mov     [rdx],cl
    mov     rsi,[rbp-70h]
    mov     [rbp-118h],rsi
    mov     edi,0FFFFFED8h
    mov     esi,0FFFFFEE0h
    mov     edx,0FFFFFF38h
    mov     ecx,0FFFFFEE8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-120h],0FFh
    je      L13
    mov     edi,0FFFFFE90h
    lea     rsi,[k21]
    call    ryo_h_AddrAbs
    lea     rdi,[sym22]
    lea     rsi,[site23]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L11
    call    rax
    nop     [rcx-140h]
    jmp     L12
L11:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym24]
L12:
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rbp-128h]
    mov     [rbp-0C8h],rax
    jmp     L10
L14:
    mov     qword ptr [rbp-148h],1
    mov     edi,0FFFFFEC8h
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFF90h
    mov     ecx,0FFFFFEB8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rbp-130h],0FFh
    je      L17
    mov     edi,0FFFFFE90h
    lea     rsi,[k25]
    call    ryo_h_AddrAbs
    lea     rdi,[sym26]
    lea     rsi,[site27]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    nop     [rcx-140h]
    jmp     L16
L15:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym28]
L16:
    call    ryo_h_Unreachable
    ud2
L17:
    mov     rax,[rbp-138h]
    mov     [rbp-70h],rax
    jmp     L3
L18:
    mov     edi,0FFFFFFE8h
    mov     esi,0FFFFFFD0h
    mov     edx,18h
    call    ryo_h_Copy
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L19:
    lea     rax,[rbp-30h]
    mov     [rbp-148h],rax
    mov     [rbp-170h],rax
    call    fn29
    nop     [rcx-148h]
    mov     edi,0FFFFFEC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L20:
    lea     rdi,[sym30]
    lea     rsi,[site31]
    mov     edx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    nop     [rcx-140h]
    jmp     L22
L21:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym32]
L22:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L19
    mov     rdi,rax
    mov     esi,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L20

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    push    rbp
    mov     rbp,rsp
    sub     rsp,10h
    mov     rax,[rbp+10h]
    movzx   eax,byte ptr [rax]
    mov     [rbp-1],al
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialEq for usize>::eq
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    sete    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rax,[rax]
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setbe   [rbp-1]
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
    mov     rdx,[rbp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rbp-1]
    mov     edi,0FFFFFFFFh
    mov     esi,1
    call    ryo_h_Ret
    leave
    ret

fn std::fmt::Arguments::<'_>::new::<39, 3>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rax
    mov     [rbp-8],rdx
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

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
    mov     rsi,[rbp-8]
    mov     [rbp-28h],rdx
    mov     edi,0FFFFFFA8h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-50h],0DDh
    mov     rdx,[rbp-50h]
    shl     rdx,1
    or      rdx,1
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

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,50h
    mov     rax,[rbp+10h]
    mov     [rbp-28h],rax
    lea     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    mov     [rbp-50h],rax
    mov     [rbp-48h],rdx
    call    fn0
    nop     [rcx-19h]
    test    byte ptr [rbp-19h],0FFh
    je      L0
    mov     rdx,[rbp+18h]
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
    nop     [rax]
L2:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    push    rbp
    mov     rbp,rsp
    sub     rsp,70h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     byte ptr [rbp-9],1
    mov     rsi,[rbp+18h]
    mov     [rbp-38h],rsi
    mov     rdi,[rbp+10h]
    mov     [rbp-48h],rdi
    mov     r8,[rbp+20h]
    mov     [rbp-50h],r8
    mov     [rbp-70h],rdi
    mov     [rbp-68h],r8
    call    fn0
    nop     [rcx-40h]
    mov     byte ptr [rbp-9],0
    mov     rdx,[rbp-38h]
    mov     [rbp-30h],rdx
    mov     rsi,[rbp-40h]
    mov     [rbp-28h],rsi
    mov     rdi,[rbp-20h]
    mov     [rbp-70h],rdi
    mov     [rbp-68h],rdx
    mov     [rbp-60h],rsi
    call    fn1
    nop     [rcx-8]
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
    nop     [rax+rax]
L0:
    mov     edi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rbp-9],0FFh
    je      L0
    jmp     L1
    mov     rdi,rax
    mov     esi,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-20h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-18h],rdx
    call    fn0
    nop     [rcx-10h]
    mov     edi,0FFFFFFF0h
    mov     esi,10h
    call    ryo_h_Ret
    leave
    ret

fn std::ops::RangeInclusive::<usize>::new
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-18h],rax
    mov     rdx,[rbp+18h]
    mov     [rbp-10h],rdx
    mov     byte ptr [rbp-8],0
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

fn std::option::Option::<usize>::unwrap
    push    rbp
    mov     rbp,rsp
    sub     rsp,20h
    mov     rax,[rbp+10h]
    mov     [rbp-10h],rax
    mov     edi,0FFFFFFF0h
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
    .long   L5
    .long   L1
L1:
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rbp+20h]
    mov     [rbp-20h],rax
    lea     rdi,[sym0]
    lea     rsi,[site1]
    mov     edx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    nop     [rcx-10h]
    jmp     L4
L3:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L4:
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rbp+18h]
    mov     [rbp-8],rax
    mov     edi,0FFFFFFF8h
    mov     esi,8
    call    ryo_h_Ret
    leave
    ret

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
    mov     rsi,[rbp-8]
    mov     [rbp-30h],rdx
    mov     edi,0FFFFFFA0h
    lea     rsi,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rbp-58h],0C9h
    mov     rdx,[rbp-58h]
    shl     rdx,1
    or      rdx,1
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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
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

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
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

fn std::slice::Iter::<'_, bool>::new
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
    mov     [rbp-28h],rax
    mov     byte ptr [rbp-51h],0
    test    byte ptr [rbp-51h],0FFh
    je      L0
    mov     rdi,[rbp-20h]
    mov     [rbp-18h],rdi
    jmp     L1
L0:
    mov     rax,[rbp-28h]
    imul    rcx,[rbp-20h],1
    add     rax,rcx
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

fn std::vec::Vec::<bool>::extend_with
    push    rbp
    mov     rbp,rsp
    sub     rsp,0A0h
    mov     byte ptr [rbp-31h],1
    mov     rdx,[rbp+10h]
    mov     [rbp-0A0h],rdx
    mov     rsi,[rbp+18h]
    mov     [rbp-98h],rsi
    call    fn0
    nop     [rcx]
    mov     rax,[rbp+10h]
    mov     rax,[rax+8]
    mov     rdx,[rbp+10h]
    mov     rdx,[rdx+10h]
    mov     [rbp-60h],rdx
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rbp-61h]
    imul    rcx,rdx,1
    add     rax,rcx
    mov     [rbp-8],rax
    mov     rsi,[rbp+10h]
    lea     rsi,[rsi+10h]
    mov     [rbp-68h],rsi
    mov     rsi,[rsi]
    mov     rdi,[rbp-68h]
    mov     [rbp-60h],rdi
    mov     [rbp-58h],rsi
    mov     qword ptr [rbp-18h],1
    mov     r9,[rbp+18h]
    mov     [rbp-10h],r9
    nop     [rax]
L0:
    mov     rax,[rbp-18h]
    mov     rdx,[rbp-10h]
    cmp     rax,rdx
    setb    [rbp-61h]
    test    byte ptr [rbp-61h],0FFh
    je      L11
    jmp     L10
    xchg    ax,ax
L1:
    mov     rax,[rbp-68h]
    movzx   ecx,byte ptr [rbp-69h]
    mov     [rax],cl
    mov     qword ptr [rbp-80h],1
    mov     rsi,[rbp-8]
    imul    rcx,[rbp-80h],1
    add     rsi,rcx
    mov     [rbp-8],rsi
    mov     rdi,[rbp-58h]
    add     rdi,1
    mov     [rbp-58h],rdi
    jmp     L0
L2:
    mov     byte ptr [rbp-31h],0
    movzx   edx,byte ptr [rbp+20h]
    mov     [rbp-62h],dl
    mov     rsi,[rbp-8]
    movzx   ecx,byte ptr [rbp-62h]
    mov     [rsi],cl
    mov     rdi,[rbp-58h]
    add     rdi,1
    mov     [rbp-58h],rdi
    lea     r8,[rbp-60h]
    mov     [rbp-80h],r8
    mov     [rbp-0A0h],r8
    call    fn1
    nop     [rcx-80h]
    jmp     L14
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    lea     rax,[rbp-60h]
    mov     [rbp-80h],rax
    mov     [rbp-0A0h],rax
    call    fn2
    nop     [rcx-80h]
    test    byte ptr [rbp-31h],0FFh
    jne     L7
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    xor     edi,edi
    xor     esi,esi
    call    ryo_h_Ret
    leave
    ret
    nop     [rax+rax]
L5:
    lea     rax,[rbp-60h]
    mov     [rbp-80h],rax
    mov     [rbp-0A0h],rax
    call    fn3
    nop     [rcx-80h]
    jmp     L9
    nop     [rax]
L6:
    mov     edi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L7:
    jmp     L4
    xchg    ax,ax
L8:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rbp-31h],0FFh
    je      L6
    jmp     L8
L10:
    mov     rax,[rbp-18h]
    mov     [rbp-70h],rax
    mov     byte ptr [rbp-79h],1
    test    byte ptr [rbp-79h],0FFh
    je      L13
    jmp     L12
L11:
    cmp     qword ptr [rbp+18h],0
    ja      L2
    jmp     L3
L12:
    mov     rax,[rbp-70h]
    mov     [rbp-0A0h],rax
    mov     qword ptr [rbp-98h],1
    mov     edi,0FFFFFF70h
    lea     rsi,[k4]
    call    ryo_h_AddrAbs
    call    fn5
    nop     [rcx-48h]
L13:
    mov     rax,[rbp-70h]
    add     rax,1
    mov     [rbp-18h],rax
    mov     rdx,[rbp-8]
    mov     [rbp-68h],rdx
    lea     rsi,[rbp+20h]
    mov     [rbp-78h],rsi
    mov     [rbp-0A0h],rsi
    call    fn6
    nop     [rcx-69h]
    jmp     L1
L14:
    jmp     L4
    nop     [rax+rax]
L15:
    lea     rdi,[sym7]
    lea     rsi,[site8]
    mov     edx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L16
    call    rax
    nop     [rcx-78h]
    jmp     L17
L16:
    mov     rdi,rbp
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L17:
    call    ryo_h_Unreachable
    ud2
    mov     rdi,rax
    mov     esi,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L9
    mov     rdi,rax
    mov     esi,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L15
    mov     rdi,rax
    mov     esi,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5

fn std::vec::Vec::<bool>::reserve
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
    mov     [rbp-48h],rax
    jmp     L4

fn std::vec::from_elem::<bool>
    push    rbp
    mov     rbp,rsp
    sub     rsp,30h
    movzx   eax,byte ptr [rbp+10h]
    mov     [rbp-28h],al
    mov     rdx,[rbp+18h]
    mov     [rbp-30h],rdx
    call    fn0
    nop     [rcx-18h]
    mov     edi,0FFFFFFE8h
    mov     esi,18h
    call    ryo_h_Ret
    leave
    ret

