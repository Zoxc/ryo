fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <alloc::raw_vec::RawVec<bool> as std::ops::Drop>::drop
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
    jmp     L1
L0:
    lea     rdi,[rsp+30h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    add     rsp,38h
    ret

fn <bool as std::vec::is_zero::IsZero>::is_zero
    sub     rsp,18h
    mov     rax,[rsp+20h]
    movzx   eax,byte ptr [rax]
    xor     al,1
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global>
    sub     rsp,0B8h
    mov     byte ptr [rsp+96h],1
    mov     byte ptr [rsp+97h],1
    lea     rsi,[rsp+0C8h]
    mov     [rsp+78h],rsi
    mov     [rsp],rsi
    call    fn0
    mov     [rsp+87h],al
    test    byte ptr [rsp+87h],0FFh
    je      L2
    mov     byte ptr [rsp+97h],0
    mov     rsi,[rsp+0C0h]
    mov     [rsp],rsi
    mov     byte ptr [rsp+8],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym2]
    lea     rdx,[site3]
    mov     ecx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF98h
    mov     edx,0FFFFFF50h
    mov     ecx,18h
    call    ryo_h_Copy
    jmp     L11
L2:
    mov     byte ptr [rsp+97h],0
    mov     rdx,[rsp+0C0h]
    mov     [rsp],rdx
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k5]
    mov     ecx,10h
    call    ryo_h_Const
    call    fn6
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    jmp     L18
    xchg    ax,ax
L3:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFC0h
    mov     ecx,18h
    call    ryo_h_Copy
    nop     [rax]
L4:
    lea     rdi,[rsp+0B0h]
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,0B8h
    ret
    nop     [rax+rax]
    nop     [rax]
L5:
    lea     rax,[rsp+70h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    call    fn7
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L6:
    test    byte ptr [rsp+96h],0FFh
    jne     L10
    nop     [rax+rax]
L7:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L8:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rsp+97h],0FFh
    je      L6
    jmp     L8
L10:
    jmp     L7
L11:
    mov     rax,[rsp+48h]
    mov     [rsp+40h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF90h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L12]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L12:
    .long   L17
    .long   L14
    .long   L13
L13:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L14:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF80h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFF80h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym8]
    lea     rdx,[site9]
    mov     ecx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    jmp     L16
L15:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym10]
L16:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L17:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rsp+0C0h]
    mov     [rsp+0A8h],rax
    jmp     L4
L18:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFB0h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+80h],0
    lea     rdx,[rsp+70h]
    mov     [rsp+68h],rdx
    mov     byte ptr [rsp+96h],0
    movzx   edi,byte ptr [rsp+0C8h]
    mov     [rsp+67h],dil
    mov     [rsp],rdx
    mov     r8,[rsp+0C0h]
    mov     [rsp+8],r8
    mov     [rsp+10h],dil
    call    fn11
    jmp     L3
    nop     [rax]
L19:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[sym12]
    lea     rdx,[site13]
    mov     ecx,0FFFFFF78h
    call    ryo_h_CallExt
    test    rax,rax
    je      L20
    call    rax
    jmp     L21
L20:
    lea     rdi,[rsp+0B0h]
    lea     rsi,[ro+36]
    call    qword ptr [sym14]
L21:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L19
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L5

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,8
    lea     rdi,[rsp]
    mov     esi,10h
    lea     rdx,[site0]
    call    ryo_h_CallInd
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp]
    lea     rsi,[ro+4]
    call    qword ptr [sym1]
L1:
    add     rsp,8
    ret

fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,48h
    mov     rax,[rsp+50h]
    mov     [rsp+20h],rax
    lea     rdx,[rsp+58h]
    mov     [rsp+18h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    mov     [rsp+2Fh],al
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFEFh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
L0:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFF0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count
    sub     rsp,78h
    mov     byte ptr [rsp+5Fh],1
    mov     byte ptr [rsp+5Eh],1
    lea     rsi,[rsp+80h]
    mov     [rsp+20h],rsi
    mov     [rsp],rsi
    call    fn0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFF90h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     rax,[rsp+40h]
    mov     [rsp+20h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFB0h
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
    .long   L9
    .long   L10
    .long   L8
L1:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFFD0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    mov     qword ptr [rsp+10h],0
    call    fn1
    mov     [rsp+68h],rax
    jmp     L11
L2:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+5Fh],0FFh
    je      L3
    jmp     L3
    nop     [rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rsp+5Eh],0FFh
    je      L4
    jmp     L5
    nop     [rax]
L7:
    mov     byte ptr [rsp+5Eh],0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFC0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     byte ptr [rsp+5Fh],0
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFF90h
    mov     edx,0FFFFFFC0h
    call    ryo_h_MovW128
    call    fn2
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    jmp     L1
L8:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     qword ptr [rsp+60h],0FFFFFFFFFFFFFFFFh
    jmp     L7
L10:
    mov     rax,[rsp+48h]
    mov     [rsp+60h],rax
    jmp     L7
L11:
    mov     rax,[rsp+68h]
    mov     [rsp],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+8],rdx
    call    fn3
    jmp     L2
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::iter::Rev<std::ops::RangeInclusive<usize>> as std::iter::Iterator>::find::<{closure@bench/sieve.rs:25:39: 25:43}>
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+8],rdx
    call    fn0
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual
    sub     rsp,38h
    mov     qword ptr [rsp+18h],1
    cmp     qword ptr [rsp+18h],1
    sete    [rsp+17h]
    mov     rsi,[rsp+40h]
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp+20h],1
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::branch
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     qword ptr [rsp+20h],1
    jmp     L4
L3:
    mov     qword ptr [rsp+20h],0
L4:
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::from_output
    sub     rsp,18h
    mov     qword ptr [rsp],0
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
    ret

fn <std::ops::RangeInclusive<usize> as std::iter::DoubleEndedIterator>::rfind::<{closure@bench/sieve.rs:25:39: 25:43}>
    sub     rsp,58h
    mov     rax,[rsp+68h]
    mov     [rsp+28h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn0
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
L0:
    .long   L3
    .long   L2
    .long   L1
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+38h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    jmp     L6
L3:
    mov     qword ptr [rsp+40h],0
    jmp     L6
    nop     [rax]
L4:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
    ret
L5:
    jmp     L4
L6:
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L7]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L7:
    .long   L5
    .long   L4
    .long   L1

fn <std::ops::RangeInclusive<usize> as std::iter::Iterator>::rev
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    mov     edx,10h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+20h]
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,28h
    ret

fn <std::ops::RangeInclusive<usize> as std::iter::range::RangeInclusiveIteratorImpl>::spec_try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    sub     rsp,0A8h
    mov     byte ptr [rsp+76h],1
    mov     rdx,[rsp+0B0h]
    movzx   edx,byte ptr [rdx+10h]
    mov     [rsp+66h],dl
    test    byte ptr [rsp+66h],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L0:
    mov     byte ptr [rsp+76h],0
    call    fn0
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
    nop
L1:
    mov     byte ptr [rsp+76h],0
    mov     byte ptr [rsp+77h],1
    nop     [rax+rax]
L2:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B0h]
    lea     rdx,[rdx+8]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L7
    mov     rdx,[rsp+0B0h]
    mov     rdx,[rdx+8]
    mov     [rsp+50h],rdx
    mov     [rsp],rdx
    mov     qword ptr [rsp+8],1
    call    fn2
    mov     [rsp+58h],rax
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+8]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+0B0h]
    mov     rcx,[rsp+58h]
    mov     [rdx+8],rcx
    lea     rsi,[rsp+0B8h]
    mov     [rsp+28h],rsi
    mov     byte ptr [rsp+77h],0
    mov     r8,[rsp+50h]
    mov     [rsp+20h],r8
    mov     [rsp],rsi
    mov     [rsp+8],r8
    call    fn3
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF90h
    call    ryo_h_MovW128
    call    fn4
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+40h]
    mov     [rsp+80h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFE0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L3]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L3:
    .long   L5
    .long   L6
    .long   L4
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     byte ptr [rsp+77h],1
    jmp     L2
L6:
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn5
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L7:
    mov     byte ptr [rsp+10h],1
    mov     rdx,[rsp+0B0h]
    movzx   ecx,byte ptr [rsp+10h]
    mov     [rdx+10h],cl
    mov     rsi,[rsp+0B0h]
    mov     [rsp+58h],rsi
    mov     rdi,[rsp+0B0h]
    lea     rdi,[rdi+8]
    mov     [rsp+50h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    call    fn6
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L11
    lea     rdx,[rsp+0B8h]
    mov     [rsp+38h],rdx
    mov     byte ptr [rsp+77h],0
    mov     rdi,[rsp+0B0h]
    mov     rdi,[rdi]
    mov     [rsp+30h],rdi
    mov     [rsp],rdx
    mov     [rsp+8],rdi
    call    fn7
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFFA0h
    call    ryo_h_MovW128
    call    fn8
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     [rsp+78h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L8]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L8:
    .long   L9
    .long   L10
    .long   L4
L9:
    jmp     L11
L10:
    mov     rax,[rsp+58h]
    mov     [rsp+48h],rax
    mov     [rsp],rax
    call    fn9
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L11:
    mov     byte ptr [rsp+77h],0
    call    fn10
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L12:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L13:
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L15:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    test    byte ptr [rsp+77h],0FFh
    je      L13
    jmp     L15
    nop     [rax]
L17:
    jmp     L14
L18:
    test    byte ptr [rsp+76h],0FFh
    je      L14
    jmp     L17
L19:
    jmp     L0
L20:
    mov     rax,[rsp+0B0h]
    mov     [rsp+58h],rax
    mov     rdx,[rsp+0B0h]
    lea     rdx,[rdx+8]
    mov     [rsp+50h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn11
    mov     [rsp+65h],al
    movzx   eax,byte ptr [rsp+65h]
    xor     al,1
    mov     [rsp+67h],al
    test    byte ptr [rsp+67h],0FFh
    je      L1
    jmp     L0
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L13
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L16

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::filter::<{closure@bench/sieve.rs:24:37: 24:42}>
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
    ret

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
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
    imul    rcx,r8,1
    add     rdi,rcx
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdi
    mov     [rsp],rax
    mov     [rsp+8],rsi
    mov     [rsp+10h],rdi
    call    fn0
    mov     [rsp+70h],rax
    mov     rax,[rsp+70h]
    mov     [rsp+78h],rax
    mov     byte ptr [rsp+1Fh],1
    test    byte ptr [rsp+1Fh],0FFh
    je      L21
    jmp     L20
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    mov     rax,[rsp+78h]
    mov     [rsp+0B8h],rax
    jmp     L7
    nop
L6:
    jmp     L4
L7:
    mov     rax,[rsp+0B8h]
    add     rsp,0C8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
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
L16:
    mov     qword ptr [rsp+18h],0
    cmp     qword ptr [rsp+18h],1
    setb    [rsp+4Fh]
    test    byte ptr [rsp+4Fh],0FFh
    je      L17
    mov     qword ptr [rsp+18h],1
    mov     r8,[rsp+18h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+4Eh]
    test    byte ptr [rsp+4Eh],0FFh
    je      L17
    mov     r10,[rsp+50h]
    sub     r10,[rsp+58h]
    mov     [rsp+98h],r10
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::map::<usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>
    sub     rsp,18h
    lea     rdi,[rsp+10h]
    mov     esi,0FFFFFFF0h
    mov     edx,10h
    call    ryo_h_MovW128
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
    ret

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::size_hint
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
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,88h
    ret
    nop     [rax]
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
L4:
    mov     qword ptr [rsp+20h],0
    cmp     qword ptr [rsp+20h],1
    setb    [rsp+37h]
    test    byte ptr [rsp+37h],0FFh
    je      L5
    mov     qword ptr [rsp+20h],1
    mov     r8,[rsp+20h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+36h]
    test    byte ptr [rsp+36h],0FFh
    je      L5
    mov     r10,[rsp+38h]
    sub     r10,[rsp+40h]
    mov     [rsp+60h],r10
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
    jmp     L7
L6:
    lea     rdi,[rsp+80h]
    lea     rsi,[ro+4]
    call    qword ptr [sym6]
L7:
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound
    sub     rsp,28h
    mov     rax,[rsp+30h]
    cmp     rax,[rsp+38h]
    setbe   [rsp+1Fh]
    mov     byte ptr [rsp+1Eh],1
    test    byte ptr [rsp+1Eh],0FFh
    je      L0
    movzx   edi,byte ptr [rsp+1Fh]
    mov     [rsp],dil
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
L0:
    add     rsp,28h
    ret

fn <std::vec::Vec<bool> as std::ops::Deref>::deref
    sub     rsp,38h
    mov     rax,[rsp+40h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+40h]
    mov     rdx,[rdx+10h]
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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
    add     rsp,48h
    ret

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
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
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
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
    mov     [rsp+58h],rax
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     rax,[rax+8]
    mov     [rsp],rax
    mov     rdx,[rsp+20h]
    mov     rdx,[rdx]
    mov     rcx,[rsp]
    mov     [rdx],rcx
    add     rsp,18h
    ret

fn <usize as std::iter::Step>::backward_unchecked
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
L0:
    mov     rax,[rsp+40h]
    sub     rax,[rsp+48h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
    sub     rsp,38h
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFF0h
    mov     ecx,18h
    mov     r8d,20h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+20h],0FFh
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
    mov     rax,[rsp+18h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index
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
    imul    rcx,[rsp+60h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
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
    imul    rcx,[rsp+60h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
    sub     rsp,28h
    lea     rax,[rsp+30h]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    mov     [rsp+1Ch],eax
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret
    nop     [rax+rax]
    nop     [rax]
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
    mov     [rsp+0Ch],eax
    mov     eax,[rsp+0Ch]
    add     rsp,18h
    ret

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
    jmp     L1
L0:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L1:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC0h
    mov     edx,0FFFFFF70h
    mov     ecx,18h
    call    ryo_h_Copy
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
    xchg    ax,ax
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
L12:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
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
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
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
    add     rsp,98h
    ret

fn core::slice::<impl [bool]>::iter
    sub     rsp,28h
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    mov     edx,10h
    call    ryo_h_MovW128
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret

fn main
    sub     rsp,1B8h
    mov     qword ptr [rsp],0C65D40h
    call    fn0
    mov     [rsp+1A8h],rax
    mov     rax,[rsp+1A8h]
    mov     [rsp],rax
    call    fn1
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFFE0h
    mov     edx,0FFFFFE50h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+190h]
    mov     [rsp+150h],rax
    mov     [rsp],rax
    call    fn2
    mov     [rsp+158h],rax
    mov     [rsp+160h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFFA8h
    call    ryo_h_MovW128
    call    fn3
    mov     [rsp+168h],rax
    mov     [rsp+170h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFFB8h
    call    ryo_h_MovW128
    call    fn4
    mov     [rsp+178h],rax
    mov     [rsp+180h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFFC8h
    call    ryo_h_MovW128
    call    fn5
    mov     [rsp+188h],rax
    mov     qword ptr [rsp],0
    mov     rdx,[rsp+1A8h]
    mov     [rsp+8],rdx
    call    fn6
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFF50h
    mov     edx,0FFFFFE50h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFF50h
    mov     ecx,18h
    call    ryo_h_Copy
    call    fn7
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFF68h
    mov     edx,0FFFFFE50h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+118h]
    mov     [rsp+130h],rax
    lea     rdx,[rsp+190h]
    mov     [rsp+0F8h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn8
    mov     [rsp+138h],rax
    mov     [rsp+140h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFF88h
    call    ryo_h_MovW128
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE60h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    call    fn10
    mov     [rsp+148h],rax
    lea     rax,[rsp+188h]
    lea     rdx,[rsp+1A8h]
    lea     rsi,[rsp+148h]
    mov     [rsp+0C8h],rax
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rsi
    mov     [rsp+38h],rax
    mov     [rsp],rax
    call    fn11
    mov     [rsp+70h],rax
    mov     [rsp+78h],rdx
    mov     rax,[rsp+0D0h]
    mov     [rsp+30h],rax
    mov     [rsp],rax
    call    fn12
    mov     [rsp+60h],rax
    mov     [rsp+68h],rdx
    mov     rax,[rsp+0D8h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    call    fn13
    mov     [rsp+50h],rax
    mov     [rsp+58h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFEC0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFEE0h
    mov     edx,0FFFFFEB0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFEF0h
    mov     edx,0FFFFFEA0h
    call    ryo_h_MovW128
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k14]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp],rdx
    mov     [rsp+8],rax
    call    fn15
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE50h
    mov     edx,0FFFFFF30h
    call    ryo_h_MovW128
    lea     rdi,[rsp+1B0h]
    lea     rsi,[sym16]
    lea     rdx,[site17]
    mov     ecx,0FFFFFE68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp+1B0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L1:
    lea     rax,[rsp+190h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn19
    add     rsp,1B8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L2:
    lea     rax,[rsp+190h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn20
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+1B0h]
    lea     rsi,[sym21]
    lea     rdx,[site22]
    mov     ecx,0FFFFFE68h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    jmp     L5
L4:
    lea     rdi,[rsp+1B0h]
    lea     rsi,[ro+20]
    call    qword ptr [sym23]
L5:
    lea     rdi,[rsp+1B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L3

fn main::{closure#0}
    sub     rsp,18h
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn main::{closure#1}
    sub     rsp,48h
    mov     rax,[rsp+58h]
    mov     rax,[rax]
    mov     [rsp+30h],rax
    mov     rdx,[rsp+50h]
    mov     rdx,[rdx]
    mov     [rsp+20h],rdx
    mov     [rsp],rdx
    mov     [rsp+8],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    call    fn1
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+3Fh],al
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret

fn sieve
    sub     rsp,178h
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFFB8h
    mov     edx,0FFFFFFC0h
    mov     ecx,10h
    mov     r8d,0FFFFFEB8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+130h],0FFh
    je      L2
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+170h]
    lea     rsi,[sym1]
    lea     rdx,[site2]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L0
    call    rax
    jmp     L1
L0:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+128h]
    mov     [rsp+138h],rax
    mov     byte ptr [rsp],1
    mov     [rsp+8],rax
    call    fn4
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFE90h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rax,[rsp+140h]
    mov     [rsp+118h],rax
    mov     [rsp],rax
    mov     qword ptr [rsp+8],0
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    call    fn6
    mov     [rsp+120h],rax
    mov     byte ptr [rsp+20h],0
    mov     rdx,[rsp+120h]
    movzx   ecx,byte ptr [rsp+20h]
    mov     [rdx],cl
    lea     rsi,[rsp+140h]
    mov     [rsp+108h],rsi
    mov     [rsp],rsi
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    call    fn8
    mov     [rsp+110h],rax
    mov     byte ptr [rsp+20h],0
    mov     rdx,[rsp+110h]
    movzx   ecx,byte ptr [rsp+20h]
    mov     [rdx],cl
    mov     qword ptr [rsp+100h],2
    nop     [rax+rax]
    nop
L3:
    mov     rax,[rsp+100h]
    mov     [rsp+0E8h],rax
    mov     rdx,[rsp+100h]
    mov     [rsp+0E0h],rdx
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFF60h
    mov     edx,0FFFFFF68h
    mov     ecx,0FFFFFF78h
    mov     r8d,0FFFFFF70h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rsp+0D8h],0FFh
    je      L6
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+170h]
    lea     rsi,[sym10]
    lea     rdx,[site11]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L4
    call    rax
    jmp     L5
L4:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym12]
L5:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
L6:
    mov     rax,[rsp+0D0h]
    mov     [rsp+0F0h],rax
    mov     rdx,[rsp+180h]
    cmp     rdx,rax
    jb      L18
    lea     rsi,[rsp+140h]
    mov     [rsp+0B8h],rsi
    mov     rdi,[rsp+100h]
    mov     [rsp+0B0h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    call    fn14
    mov     [rsp+0C0h],rax
    mov     rax,[rsp+0C0h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0CFh],al
    test    byte ptr [rsp+0CFh],0FFh
    je      L14
    mov     rsi,[rsp+100h]
    mov     [rsp+0A0h],rsi
    mov     rdi,[rsp+100h]
    mov     [rsp+98h],rdi
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFF18h
    mov     edx,0FFFFFF20h
    mov     ecx,0FFFFFF30h
    mov     r8d,0FFFFFF28h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rsp+90h],0FFh
    je      L9
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+170h]
    lea     rsi,[sym16]
    lea     rdx,[site17]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L7
    call    rax
    jmp     L8
L7:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym18]
L8:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     rax,[rsp+88h]
    mov     [rsp+0A8h],rax
    nop     [rax+rax]
    nop     [rax]
L10:
    mov     rax,[rsp+0A8h]
    mov     [rsp+78h],rax
    mov     rdx,[rsp+180h]
    cmp     rdx,rax
    jb      L14
    lea     rsi,[rsp+140h]
    mov     [rsp+68h],rsi
    mov     rdi,[rsp+0A8h]
    mov     [rsp+60h],rdi
    mov     [rsp],rsi
    mov     [rsp+8],rdi
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k19]
    call    ryo_h_AddrAbs
    call    fn20
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+20h],0
    mov     rdx,[rsp+70h]
    movzx   ecx,byte ptr [rsp+20h]
    mov     [rdx],cl
    mov     rsi,[rsp+100h]
    mov     [rsp+58h],rsi
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFED8h
    mov     edx,0FFFFFEE0h
    mov     ecx,0FFFFFF38h
    mov     r8d,0FFFFFEE8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+50h],0FFh
    je      L13
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k21]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+170h]
    lea     rsi,[sym22]
    lea     rdx,[site23]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L11
    call    rax
    jmp     L12
L11:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym24]
L12:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rsp+48h]
    mov     [rsp+0A8h],rax
    jmp     L10
L14:
    mov     qword ptr [rsp+28h],1
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEC8h
    mov     edx,0FFFFFED0h
    mov     ecx,0FFFFFF90h
    mov     r8d,0FFFFFEB8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+40h],0FFh
    je      L17
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFE90h
    lea     rdx,[k25]
    call    ryo_h_AddrAbs
    lea     rdi,[rsp+170h]
    lea     rsi,[sym26]
    lea     rdx,[site27]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L15
    call    rax
    jmp     L16
L15:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym28]
L16:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
L17:
    mov     rax,[rsp+38h]
    mov     [rsp+100h],rax
    jmp     L3
L18:
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+170h]
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,178h
    ret
    nop     [rax]
L19:
    lea     rax,[rsp+140h]
    mov     [rsp+28h],rax
    mov     [rsp],rax
    call    fn29
    lea     rdi,[rsp+170h]
    mov     esi,0FFFFFEC0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L20:
    lea     rdi,[rsp+170h]
    lea     rsi,[sym30]
    lea     rdx,[site31]
    mov     ecx,0FFFFFEB8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L21
    call    rax
    jmp     L22
L21:
    lea     rdi,[rsp+170h]
    lea     rsi,[ro+4]
    call    qword ptr [sym32]
L22:
    lea     rdi,[rsp+170h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+170h]
    mov     rsi,rax
    mov     edx,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L19
    lea     rdi,[rsp+170h]
    mov     rsi,rax
    mov     edx,0FFFFFEC0h
    call    ryo_h_Lpad
    jmp     L20

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    sub     rsp,18h
    mov     rax,[rsp+20h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn std::cmp::impls::<impl std::cmp::PartialEq for usize>::eq
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    sete    [rsp+1Fh]
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setbe   [rsp+1Fh]
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     rdx,[rsp+38h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setb    [rsp+1Fh]
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret

fn std::fmt::Arguments::<'_>::new::<39, 3>
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret

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
    add     rsp,88h
    ret

fn std::hint::black_box::<usize>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
    sub     rsp,58h
    mov     rax,[rsp+60h]
    mov     [rsp+28h],rax
    lea     rdx,[rsp+68h]
    mov     [rsp+20h],rdx
    mov     [rsp],rax
    mov     [rsp+8],rdx
    call    fn0
    mov     [rsp+37h],al
    test    byte ptr [rsp+37h],0FFh
    je      L0
    mov     rdx,[rsp+68h]
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+40h],1
    jmp     L1
L0:
    mov     qword ptr [rsp+40h],0
L1:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
    ret
    xchg    ax,ax
L2:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    sub     rsp,78h
    mov     rax,[rsp+80h]
    mov     [rsp+50h],rax
    mov     byte ptr [rsp+67h],1
    mov     rsi,[rsp+88h]
    mov     [rsp+38h],rsi
    mov     rdi,[rsp+80h]
    mov     [rsp+28h],rdi
    mov     r8,[rsp+90h]
    mov     [rsp+20h],r8
    mov     [rsp],rdi
    mov     [rsp+8],r8
    call    fn0
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+67h],0
    mov     rdx,[rsp+38h]
    mov     [rsp+40h],rdx
    mov     rsi,[rsp+30h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+50h]
    mov     [rsp],rdi
    mov     [rsp+8],rdx
    mov     [rsp+10h],rsi
    call    fn1
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L0:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    jmp     L0
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    test    byte ptr [rsp+67h],0FFh
    je      L0
    jmp     L1
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+8],rdx
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret

fn std::ops::RangeInclusive::<usize>::new
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     rdx,[rsp+38h]
    mov     [rsp+10h],rdx
    mov     byte ptr [rsp+18h],0
    lea     rdi,[rsp+20h]
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,28h
    ret

fn std::option::Option::<usize>::unwrap
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFF0h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L0]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
L0:
    .long   L2
    .long   L5
    .long   L1
L1:
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+40h]
    mov     [rsp],rax
    lea     rdi,[rsp+20h]
    lea     rsi,[sym0]
    lea     rdx,[site1]
    mov     ecx,0FFFFFFE8h
    call    ryo_h_CallExt
    test    rax,rax
    je      L3
    call    rax
    jmp     L4
L3:
    lea     rdi,[rsp+20h]
    lea     rsi,[ro+4]
    call    qword ptr [sym2]
L4:
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    sub     rsp,98h
    mov     rax,[rsp+0A0h]
    cmp     rax,[rsp+0A8h]
    jb      L0
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
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym4]
L2:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     [rsp],rax
    call    fn0
    jmp     L3
    nop     [rax]
L0:
    add     rsp,28h
    ret
    nop     [rax+rax]
    xchg    ax,ax
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
    jmp     L1
L3:
    mov     rax,[rsp+30h]
    mov     [rsp+8],rax
    mov     [rsp],rax
    call    fn2
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
    add     rsp,18h
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
    mov     [rsp+58h],rax
    jmp     L1
L0:
    lea     rdi,[rsp+60h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L1:
    mov     rax,[rsp+58h]
    add     rsp,68h
    ret

fn std::rt::lang_start::<()>::{closure#0}
    sub     rsp,28h
    mov     rax,[rsp+30h]
    mov     rax,[rax]
    mov     [rsp+10h],rax
    mov     [rsp],rax
    call    fn0
    call    fn1
    mov     [rsp+1Bh],al
    movzx   eax,byte ptr [rsp+1Bh]
    mov     [rsp+1Ah],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFFAh
    call    ryo_h_ZextW8W32
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn std::slice::Iter::<'_, bool>::new
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
    imul    rcx,[rsp+40h],1
    add     rax,rcx
    mov     [rsp+48h],rax
L1:
    mov     rax,[rsp+38h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+58h],rdx
    mov     rax,[rsp+50h]
    mov     rdx,[rsp+58h]
    add     rsp,68h
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     rax,[rsp+20h]
    mov     [rsp],rax
    call    fn0
    add     rsp,18h
    ret

fn std::vec::Vec::<bool>::extend_with
    sub     rsp,0A8h
    mov     byte ptr [rsp+6Fh],1
    mov     rdx,[rsp+0B0h]
    mov     [rsp],rdx
    mov     rsi,[rsp+0B8h]
    mov     [rsp+8],rsi
    call    fn0
    mov     rax,[rsp+0B0h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+0B0h]
    mov     rdx,[rdx+10h]
    mov     [rsp+40h],rdx
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rsp+3Fh]
    imul    rcx,rdx,1
    add     rax,rcx
    mov     [rsp+98h],rax
    mov     rsi,[rsp+0B0h]
    lea     rsi,[rsi+10h]
    mov     [rsp+38h],rsi
    mov     rsi,[rsi]
    mov     rdi,[rsp+38h]
    mov     [rsp+40h],rdi
    mov     [rsp+48h],rsi
    mov     qword ptr [rsp+88h],1
    mov     r9,[rsp+0B8h]
    mov     [rsp+90h],r9
    nop     [rax+rax]
L0:
    mov     rax,[rsp+88h]
    mov     rdx,[rsp+90h]
    cmp     rax,rdx
    setb    [rsp+3Fh]
    test    byte ptr [rsp+3Fh],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
L1:
    mov     rax,[rsp+38h]
    movzx   ecx,byte ptr [rsp+37h]
    mov     [rax],cl
    mov     qword ptr [rsp+20h],1
    mov     rsi,[rsp+98h]
    imul    rcx,[rsp+20h],1
    add     rsi,rcx
    mov     [rsp+98h],rsi
    mov     rdi,[rsp+48h]
    add     rdi,1
    mov     [rsp+48h],rdi
    jmp     L0
    xchg    ax,ax
L2:
    mov     byte ptr [rsp+6Fh],0
    movzx   edx,byte ptr [rsp+0C0h]
    mov     [rsp+3Eh],dl
    mov     rsi,[rsp+98h]
    movzx   ecx,byte ptr [rsp+3Eh]
    mov     [rsi],cl
    mov     rdi,[rsp+48h]
    add     rdi,1
    mov     [rsp+48h],rdi
    lea     r8,[rsp+40h]
    mov     [rsp+20h],r8
    mov     [rsp],r8
    call    fn1
    jmp     L14
    nop     [rax+rax]
    nop
L3:
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn2
    test    byte ptr [rsp+6Fh],0FFh
    jne     L7
    nop     [rax+rax]
L4:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L5:
    lea     rax,[rsp+40h]
    mov     [rsp+20h],rax
    mov     [rsp],rax
    call    fn3
    jmp     L9
    nop     [rax+rax]
    xchg    ax,ax
L6:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB0h
    call    ryo_h_Resume
    ud2
L7:
    jmp     L4
    nop     [rax+rax]
    nop
L8:
    jmp     L6
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    test    byte ptr [rsp+6Fh],0FFh
    je      L6
    jmp     L8
L10:
    mov     rax,[rsp+88h]
    mov     [rsp+30h],rax
    mov     byte ptr [rsp+27h],1
    test    byte ptr [rsp+27h],0FFh
    je      L13
    jmp     L12
L11:
    cmp     qword ptr [rsp+0B8h],0
    ja      L2
    jmp     L3
L12:
    mov     rax,[rsp+30h]
    mov     [rsp],rax
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF70h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    call    fn5
L13:
    mov     rax,[rsp+30h]
    add     rax,1
    mov     [rsp+88h],rax
    mov     rdx,[rsp+98h]
    mov     [rsp+38h],rdx
    lea     rsi,[rsp+0C0h]
    mov     [rsp+28h],rsi
    mov     [rsp],rsi
    call    fn6
    mov     [rsp+37h],al
    jmp     L1
L14:
    jmp     L4
    nop     [rax+rax]
L15:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[sym7]
    lea     rdx,[site8]
    mov     ecx,0FFFFFF80h
    call    ryo_h_CallExt
    test    rax,rax
    je      L16
    call    rax
    jmp     L17
L16:
    lea     rdi,[rsp+0A0h]
    lea     rsi,[ro+4]
    call    qword ptr [sym9]
L17:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB0h
    call    ryo_h_Lpad
    jmp     L5

fn std::vec::Vec::<bool>::reserve
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
    jmp     L2
L1:
    lea     rdi,[rsp+90h]
    lea     rsi,[ro+4]
    call    qword ptr [sym3]
L2:
    nop     [rax+rax]
    xchg    ax,ax
L3:
    add     rsp,98h
    ret
    nop     [rax+rax]
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

fn std::vec::from_elem::<bool>
    sub     rsp,38h
    movzx   eax,byte ptr [rsp+40h]
    mov     [rsp+8],al
    mov     rdx,[rsp+48h]
    mov     [rsp],rdx
    call    fn0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+30h]
    mov     esi,10h
    mov     edx,0FFFFFFE8h
    mov     ecx,18h
    call    ryo_h_Copy
    add     rsp,38h
    ret

