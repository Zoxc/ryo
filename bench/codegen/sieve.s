fn <() as std::process::Termination>::report
    sub     rsp,18h
    mov     byte ptr [rsp+0Fh],0
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn <alloc::raw_vec::RawVec<bool> as std::ops::Drop>::drop
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

fn <bool as std::vec::is_zero::IsZero>::is_zero
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    movzx   eax,byte ptr [rax]
    xor     al,1
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global>
    sub     rsp,0B8h
    mov     [rsp+70h],rdi
    mov     [rsp+97h],sil
    mov     [rsp+88h],rdx
    mov     byte ptr [rsp+86h],1
    mov     byte ptr [rsp+87h],1
    lea     rsi,[rsp+97h]
    mov     [rsp+60h],rsi
    mov     rdi,[rsp+60h]
    call    fn0
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L0
    mov     byte ptr [rsp+87h],0
    mov     byte ptr [rsp+17h],1
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF50h
    lea     rdx,[k1]
    mov     ecx,10h
    call    ryo_h_Const
    lea     rdi,[rsp+30h]
    mov     rsi,[rsp+88h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp]
    mov     r8,[rsp+8]
    call    qword ptr [sym2]
    jmp     L9
L0:
    mov     byte ptr [rsp+87h],0
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF58h
    lea     rdx,[k3]
    mov     ecx,10h
    call    ryo_h_Const
    mov     rdi,[rsp+88h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp+10h]
    call    fn4
    mov     [rsp+38h],rax
    mov     [rsp+40h],rdx
    jmp     L14
    nop     [rax+rax]
L1:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFA8h
    mov     ecx,18h
    call    ryo_h_Copy
    nop     [rax]
L2:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+70h]
    add     rsp,0B8h
    ret
    nop     [rax]
L3:
    lea     rax,[rsp+58h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn5
    jmp     L7
    nop     [rax+rax]
    nop
L4:
    test    byte ptr [rsp+86h],0FFh
    jne     L8
    nop     [rax+rax]
L5:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L6:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L7:
    test    byte ptr [rsp+87h],0FFh
    je      L4
    jmp     L6
L8:
    jmp     L5
L9:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFF78h
    xor     edx,edx
    mov     ecx,2
    call    ryo_h_SwitchDenseW64
    lea     rcx,[L10]
    movsxd  rax,[rcx+rax*4]
    add     rax,rcx
    jmp     rax
    int3
    int3
    int3
L10:
    .long   L13
    .long   L12
    .long   L11
L11:
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L12:
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    call    qword ptr [sym6]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
L13:
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+60h],rcx
    mov     rcx,[rsp+60h]
    mov     [rsp+0A0h],rcx
    mov     [rsp+98h],rax
    mov     rdx,[rsp+88h]
    mov     [rsp+0A8h],rdx
    jmp     L2
L14:
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+50h],rcx
    mov     rcx,[rsp+50h]
    mov     [rsp+60h],rcx
    mov     [rsp+58h],rax
    mov     qword ptr [rsp+68h],0
    lea     rsi,[rsp+58h]
    mov     [rsp+50h],rsi
    mov     byte ptr [rsp+86h],0
    movzx   r8d,byte ptr [rsp+97h]
    mov     [rsp+4Fh],r8b
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+88h]
    movzx   edx,byte ptr [rsp+4Fh]
    call    fn7
    jmp     L1
    nop     [rax+rax]
L15:
    call    qword ptr [sym8]
    lea     rdi,[rsp+0B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L7
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L3

fn <fn() as std::ops::FnOnce<()>>::call_once - shim(fn())
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    call    rax
    add     rsp,18h
    ret

fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+30h]
    mov     [rsp+10h],rax
    lea     rdx,[rsp+28h]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+1Fh],al
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFF8h
    mov     edx,0FFFFFFDFh
    call    ryo_h_ZextW8W64
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop     [rax]
L0:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+40h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count
    sub     rsp,78h
    mov     [rsp+58h],rdi
    mov     [rsp+60h],rsi
    mov     byte ptr [rsp+4Fh],1
    mov     byte ptr [rsp+4Eh],1
    lea     rsi,[rsp+58h]
    mov     [rsp+10h],rsi
    lea     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     rax,[rsp+20h]
    mov     rcx,[rsp+28h]
    mov     [rsp+38h],rcx
    mov     [rsp+30h],rax
    mov     [rsp+10h],rax
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFA0h
    xor     edx,edx
    mov     ecx,2
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
    mov     rax,[rsp+30h]
    mov     rcx,[rsp+38h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rax
    mov     qword ptr [rsp+8],0
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+8]
    call    fn1
    mov     [rsp+68h],rax
    jmp     L11
    nop     [rax+rax]
L2:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L3:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L4:
    test    byte ptr [rsp+4Fh],0FFh
    je      L3
    jmp     L3
    nop     [rax]
L5:
    jmp     L4
    nop     [rax+rax]
    nop     [rax+rax]
L6:
    test    byte ptr [rsp+4Eh],0FFh
    je      L4
    jmp     L5
    nop     [rax]
L7:
    mov     byte ptr [rsp+4Eh],0
    mov     rdx,[rsp+58h]
    mov     rcx,[rsp+60h]
    mov     [rsp+28h],rcx
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+4Fh],0
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    call    fn2
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    jmp     L1
L8:
    lea     rdi,[rsp+70h]
    call    ryo_h_Unreachable
    ud2
L9:
    mov     qword ptr [rsp+50h],0FFFFFFFFFFFFFFFFh
    jmp     L7
L10:
    mov     rax,[rsp+38h]
    mov     [rsp+50h],rax
    jmp     L7
L11:
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+50h]
    call    fn3
    jmp     L2
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L6

fn <std::iter::Rev<std::ops::RangeInclusive<usize>> as std::iter::Iterator>::find::<{closure@bench/sieve.rs:25:39: 25:43}>
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     qword ptr [rsp+10h],1
    cmp     qword ptr [rsp+10h],1
    sete    [rsp+0Fh]
    mov     rsi,[rsp+18h]
    mov     [rsp+28h],rsi
    mov     qword ptr [rsp+20h],1
    mov     rax,[rsp+20h]
    mov     rdx,[rsp+28h]
    add     rsp,38h
    ret

fn <std::ops::ControlFlow<usize> as std::ops::Try>::branch
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD8h
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
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    jmp     L4
L3:
    mov     qword ptr [rsp+30h],0
L4:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
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
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    mov     rax,[rsp+30h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+18h]
    call    fn0
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFC8h
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
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+50h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+28h]
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
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB8h
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
    sub     rsp,48h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFC0h
    xor     ecx,ecx
    mov     r8d,18h
    call    ryo_h_LoadCopy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFD0h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+8]
    add     rsp,48h
    ret

fn <std::ops::RangeInclusive<usize> as std::iter::range::RangeInclusiveIteratorImpl>::spec_try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    sub     rsp,0A8h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     byte ptr [rsp+66h],1
    mov     rdx,[rsp+88h]
    movzx   edx,byte ptr [rdx+10h]
    mov     [rsp+56h],dl
    test    byte ptr [rsp+56h],0FFh
    je      L20
    jmp     L19
    nop     [rax]
L0:
    mov     byte ptr [rsp+66h],0
    call    fn0
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
    nop
L1:
    mov     byte ptr [rsp+66h],0
    mov     byte ptr [rsp+67h],1
    nop     [rax+rax]
L2:
    mov     rax,[rsp+88h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+88h]
    lea     rdx,[rdx+8]
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    call    fn1
    mov     [rsp+57h],al
    test    byte ptr [rsp+57h],0FFh
    je      L7
    mov     rdx,[rsp+88h]
    mov     rdx,[rdx+8]
    mov     [rsp+40h],rdx
    mov     qword ptr [rsp+8],1
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+8]
    call    fn2
    mov     [rsp+48h],rax
    mov     rax,[rsp+88h]
    mov     rax,[rax+8]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+88h]
    mov     rcx,[rsp+48h]
    mov     [rdx+8],rcx
    lea     rsi,[rsp+80h]
    mov     [rsp+18h],rsi
    mov     byte ptr [rsp+67h],0
    mov     r8,[rsp+40h]
    mov     [rsp+10h],r8
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn3
    mov     [rsp+20h],rax
    mov     [rsp+28h],rdx
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+28h]
    call    fn4
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rax,[rsp+30h]
    mov     [rsp+70h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFD0h
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
    nop     [rax]
L4:
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     byte ptr [rsp+67h],1
    jmp     L2
L6:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn5
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L7:
    mov     byte ptr [rsp],1
    mov     rdx,[rsp+88h]
    movzx   ecx,byte ptr [rsp]
    mov     [rdx+10h],cl
    mov     rsi,[rsp+88h]
    mov     [rsp+48h],rsi
    mov     rdi,[rsp+88h]
    lea     rdi,[rdi+8]
    mov     [rsp+40h],rdi
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    call    fn6
    mov     [rsp+57h],al
    test    byte ptr [rsp+57h],0FFh
    je      L11
    lea     rdx,[rsp+80h]
    mov     [rsp+28h],rdx
    mov     byte ptr [rsp+67h],0
    mov     rdi,[rsp+88h]
    mov     rdi,[rdi]
    mov     [rsp+20h],rdi
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+20h]
    call    fn7
    mov     [rsp+30h],rax
    mov     [rsp+38h],rdx
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+38h]
    call    fn8
    mov     [rsp+40h],rax
    mov     [rsp+48h],rdx
    mov     rax,[rsp+40h]
    mov     [rsp+68h],rax
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFC8h
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
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    mov     rdi,[rsp+38h]
    call    fn9
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L11:
    mov     byte ptr [rsp+67h],0
    call    fn10
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L12
L12:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
L13:
    jmp     L18
    nop     [rax+rax]
    nop     [rax+rax]
L14:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L15:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L16:
    test    byte ptr [rsp+67h],0FFh
    je      L13
    jmp     L15
    nop     [rax]
L17:
    jmp     L14
L18:
    test    byte ptr [rsp+66h],0FFh
    je      L14
    jmp     L17
L19:
    jmp     L0
L20:
    mov     rax,[rsp+88h]
    mov     [rsp+48h],rax
    mov     rdx,[rsp+88h]
    lea     rdx,[rdx+8]
    mov     [rsp+40h],rdx
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    call    fn11
    mov     [rsp+55h],al
    movzx   eax,byte ptr [rsp+55h]
    xor     al,1
    mov     [rsp+57h],al
    test    byte ptr [rsp+57h],0FFh
    je      L1
    jmp     L0
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L13
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L16

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::filter::<{closure@bench/sieve.rs:24:37: 24:42}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}>
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0C0h],rsi
    mov     [rsp+0B0h],rdx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L0
    mov     rsi,[rsp+0C0h]
    cmp     rsi,0
    sete    [rsp+77h]
    jmp     L1
L0:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0B8h]
    cmp     rdx,rax
    sete    [rsp+77h]
L1:
    test    byte ptr [rsp+77h],0FFh
    je      L2
    mov     byte ptr [rsp+86h],0
    mov     rsi,[rsp+0B0h]
    mov     [rsp+0C8h],rsi
    jmp     L7
L2:
    mov     byte ptr [rsp+86h],0
    mov     byte ptr [rsp+87h],1
    mov     rsi,[rsp+0B0h]
    mov     [rsp+70h],rsi
    mov     qword ptr [rsp+98h],0
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L3
    mov     r10,[rsp+0C0h]
    mov     [rsp+90h],r10
    jmp     L4
L3:
    mov     rax,[rsp+0C0h]
    mov     [rsp+68h],rax
    mov     rdx,[rsp+0B8h]
    mov     [rsp+60h],rdx
    mov     [rsp+58h],rax
    mov     [rsp+50h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+48h],rsi
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L16
    jmp     L15
    nop     [rax+rax]
    nop     [rax]
L4:
    lea     rax,[rsp+0B0h]
    mov     [rsp+60h],rax
    mov     byte ptr [rsp+87h],0
    mov     rsi,[rsp+70h]
    mov     rdi,[rsp+0B8h]
    mov     r8,[rsp+98h]
    imul    rcx,r8,1
    add     rdi,rcx
    mov     [rsp+50h],rsi
    mov     [rsp+58h],rdi
    mov     rdi,[rsp+60h]
    mov     rsi,[rsp+50h]
    mov     rdx,[rsp+58h]
    call    fn0
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    mov     [rsp+70h],rax
    mov     byte ptr [rsp+17h],1
    test    byte ptr [rsp+17h],0FFh
    je      L19
    jmp     L18
    nop     [rax+rax]
    nop     [rax]
L5:
    mov     rax,[rsp+70h]
    mov     [rsp+0C8h],rax
    jmp     L7
    nop
L6:
    jmp     L4
L7:
    mov     rax,[rsp+0C8h]
    add     rsp,0D8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L8:
    jmp     L13
    nop     [rax+rax]
    nop     [rax+rax]
L9:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFA8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L10:
    jmp     L8
    nop     [rax+rax]
    nop     [rax+rax]
L11:
    test    byte ptr [rsp+87h],0FFh
    je      L8
    jmp     L10
    nop     [rax]
L12:
    jmp     L9
L13:
    test    byte ptr [rsp+86h],0FFh
    je      L9
    jmp     L12
    xchg    ax,ax
L14:
    jmp     L4
L15:
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+38h],rdx
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF40h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+10h]
    call    fn2
L16:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],1
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L17
    mov     qword ptr [rsp+10h],1
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+46h]
    test    byte ptr [rsp+46h],0FFh
    je      L17
    mov     r10,[rsp+48h]
    sub     r10,[rsp+50h]
    mov     [rsp+90h],r10
    jmp     L14
L17:
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],49h
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF30h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym5]
    lea     rdi,[rsp+0D0h]
    call    ryo_h_Unreachable
    ud2
L18:
    mov     qword ptr [rsp+10h],1
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFF38h
    lea     rdx,[k6]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn7
L19:
    mov     rax,[rsp+98h]
    add     rax,1
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+58h],rdx
    cmp     rax,rdx
    je      L5
    jmp     L6
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
    call    ryo_h_Lpad
    jmp     L11

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::map::<usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::size_hint
    sub     rsp,88h
    mov     [rsp+50h],rdi
    mov     [rsp+60h],rsi
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L0
    mov     rsi,[rsp+60h]
    mov     rsi,[rsi+8]
    mov     [rsp+58h],rsi
    jmp     L1
L0:
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
    je      L4
    jmp     L3
    xchg    ax,ax
L1:
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
    nop     [rax]
L2:
    jmp     L1
L3:
    mov     rax,[rsp+48h]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+40h]
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+20h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+10h]
    call    fn1
L4:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],1
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L5
    mov     qword ptr [rsp+10h],1
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+26h]
    test    byte ptr [rsp+26h],0FFh
    je      L5
    mov     r10,[rsp+28h]
    sub     r10,[rsp+30h]
    mov     [rsp+58h],r10
    jmp     L2
L5:
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF88h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+10h],49h
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFF80h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym4]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+10h]
    setbe   [rsp+0Fh]
    mov     byte ptr [rsp+0Eh],1
    test    byte ptr [rsp+0Eh],0FFh
    je      L0
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    movzx   edi,byte ptr [rsp+0Fh]
    mov     rsi,[rsp]
    call    fn1
L0:
    add     rsp,28h
    ret

fn <std::vec::Vec<bool> as std::ops::Deref>::deref
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

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut
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

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop
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

fn <usize as std::iter::Step>::backward_unchecked
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     byte ptr [rsp+7],1
    test    byte ptr [rsp+7],0FFh
    je      L0
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn1
L0:
    mov     rax,[rsp+10h]
    sub     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFD0h
    mov     edx,0FFFFFFD8h
    mov     ecx,0FFFFFFE8h
    mov     r8d,0FFFFFFE0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+18h],0FFh
    je      L0
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,[rsp+10h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+30h]
    cmp     rdx,rax
    jb      L0
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,[rsp+20h]
    imul    rcx,[rsp+30h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+28h],rdx
    mov     [rsp+8],rcx
    mov     rax,[rsp+28h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+30h]
    cmp     rdx,rax
    jb      L0
    mov     rsi,[rsp+8]
    mov     [rsp],rsi
    mov     rdi,[rsp+30h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp]
    call    qword ptr [sym0]
    lea     rdi,[rsp+40h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,[rsp+20h]
    imul    rcx,[rsp+30h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim
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
L0:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE0h
    call    ryo_h_Lpad
    jmp     L0

fn <{closure@std::rt::lang_start<()>::{closure#0}} as std::ops::FnOnce<()>>::call_once - shim(vtable)
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

fn alloc::raw_vec::RawVecInner::with_capacity_in
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
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFD0h
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
    .long   L3
    .long   L2
    .long   L1
L1:
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+30h],rcx
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    mov     rsi,[rsp+30h]
    call    qword ptr [sym1]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+40h]
    mov     rcx,[rsp+48h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+70h]
    mov     [rsp+18h],rdx
    cmp     rdx,0
    je      L5
    jmp     L6
    nop     [rax+rax]
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
    jmp     L4
L6:
    mov     rax,[rsp+80h]
    mov     [rsp+20h],rax
    jmp     L4
L7:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF78h
    lea     rdx,[k2]
    call    ryo_h_AddrAbs
    movzx   edi,byte ptr [rsp+37h]
    mov     rsi,[rsp+8]
    call    fn3
L8:
    mov     rax,[rsp+80h]
    mov     rdx,[rsp+88h]
    add     rsp,98h
    ret

fn core::fmt::rt::Argument::<'_>::new_display::<usize>
    sub     rsp,58h
    mov     [rsp+28h],rdi
    mov     [rsp+38h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFB0h
    lea     rdx,[sym0]
    call    ryo_h_AddrSym
    mov     rax,[rsp]
    mov     rdx,[rsp+10h]
    mov     [rsp+20h],rax
    mov     rcx,[rsp+20h]
    mov     [rsp+48h],rcx
    mov     [rsp+40h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    xor     edx,edx
    mov     ecx,0FFFFFFF0h
    mov     r8d,10h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+28h]
    add     rsp,58h
    ret

fn core::num::<impl usize>::unchecked_add::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC0h
    mov     r8d,0FFFFFFB8h
    call    ryo_h_AddOvfUW64
    movzx   eax,byte ptr [rsp+60h]
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0BAh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0BAh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,98h
    ret

fn core::num::<impl usize>::unchecked_sub::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    mov     [rsp+50h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+48h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFC8h
    mov     edx,0FFFFFFD0h
    mov     ecx,0FFFFFFC0h
    mov     r8d,0FFFFFFB8h
    call    ryo_h_SubOvfUW64
    movzx   eax,byte ptr [rsp+60h]
    mov     [rsp+6Fh],al
    test    byte ptr [rsp+6Fh],0FFh
    je      L0
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0BAh
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0BAh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,98h
    ret

fn core::slice::<impl [bool]>::iter
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

fn main
    sub     rsp,1B8h
    mov     qword ptr [rsp+18h],0C65D40h
    mov     rdi,[rsp+18h]
    call    fn0
    mov     [rsp+1A8h],rax
    lea     rdi,[rsp+190h]
    mov     rsi,[rsp+1A8h]
    call    fn1
    lea     rax,[rsp+190h]
    mov     [rsp+150h],rax
    mov     rdi,[rsp+150h]
    call    fn2
    mov     [rsp+158h],rax
    mov     [rsp+160h],rdx
    mov     rdi,[rsp+158h]
    mov     rsi,[rsp+160h]
    call    fn3
    mov     [rsp+168h],rax
    mov     [rsp+170h],rdx
    mov     rdi,[rsp+168h]
    mov     rsi,[rsp+170h]
    call    fn4
    mov     [rsp+178h],rax
    mov     [rsp+180h],rdx
    mov     rdi,[rsp+178h]
    mov     rsi,[rsp+180h]
    call    fn5
    mov     [rsp+188h],rax
    mov     qword ptr [rsp+18h],0
    lea     rdi,[rsp+100h]
    mov     rsi,[rsp+18h]
    mov     rdx,[rsp+1A8h]
    call    fn6
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE58h
    mov     edx,0FFFFFF50h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+118h]
    lea     rsi,[rsp+8]
    call    fn7
    lea     rax,[rsp+118h]
    mov     [rsp+130h],rax
    lea     rdx,[rsp+190h]
    mov     [rsp+0F8h],rdx
    mov     rdi,[rsp+130h]
    mov     rsi,[rsp+0F8h]
    call    fn8
    mov     [rsp+138h],rax
    mov     [rsp+140h],rdx
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE68h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+138h]
    mov     rsi,[rsp+140h]
    mov     rdx,[rsp+18h]
    call    fn10
    mov     [rsp+148h],rax
    lea     rax,[rsp+188h]
    lea     rdx,[rsp+1A8h]
    lea     rsi,[rsp+148h]
    mov     [rsp+0C8h],rax
    mov     [rsp+0D0h],rdx
    mov     [rsp+0D8h],rsi
    mov     [rsp+38h],rax
    lea     rdi,[rsp+70h]
    mov     rsi,[rsp+38h]
    call    fn11
    mov     rax,[rsp+0D0h]
    mov     [rsp+30h],rax
    lea     rdi,[rsp+60h]
    mov     rsi,[rsp+30h]
    call    fn12
    mov     rax,[rsp+0D8h]
    mov     [rsp+28h],rax
    lea     rdi,[rsp+50h]
    mov     rsi,[rsp+28h]
    call    fn13
    mov     rax,[rsp+70h]
    mov     rcx,[rsp+78h]
    mov     [rsp+88h],rcx
    mov     [rsp+80h],rax
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+68h]
    mov     [rsp+98h],rcx
    mov     [rsp+90h],rdx
    mov     rsi,[rsp+50h]
    mov     rcx,[rsp+58h]
    mov     [rsp+0A8h],rcx
    mov     [rsp+0A0h],rsi
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE98h
    lea     rdx,[k14]
    call    ryo_h_AddrAbs
    lea     rax,[rsp+80h]
    mov     [rsp+40h],rax
    mov     rdi,[rsp+48h]
    mov     rsi,[rsp+40h]
    call    fn15
    mov     [rsp+0E0h],rax
    mov     [rsp+0E8h],rdx
    mov     rdi,[rsp+0E0h]
    mov     rsi,[rsp+0E8h]
    call    qword ptr [sym16]
    lea     rax,[rsp+190h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn17
    add     rsp,1B8h
    ret
L0:
    lea     rax,[rsp+190h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn18
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L1:
    call    qword ptr [sym19]
    lea     rdi,[rsp+1B0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L0
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L1

fn main::{closure#0}
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     [rsp+8],rsi
    mov     rax,[rsp+8]
    mov     rax,[rax]
    movzx   eax,byte ptr [rax]
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret

fn main::{closure#1}
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+30h]
    mov     rdx,[rdx]
    mov     [rsp+10h],rdx
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFC8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+20h]
    mov     rdx,[rsp+8]
    call    fn1
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+3Fh],al
    movzx   eax,byte ptr [rsp+3Fh]
    add     rsp,48h
    ret

fn sieve
    sub     rsp,168h
    mov     [rsp+10h],rdi
    mov     [rsp+140h],rsi
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFFB0h
    mov     edx,0FFFFFFB8h
    mov     ecx,0FFFFFFE0h
    mov     r8d,0FFFFFEA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+118h],0FFh
    je      L0
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L0:
    mov     rax,[rsp+110h]
    mov     [rsp+120h],rax
    mov     byte ptr [rsp+0Fh],1
    lea     rdi,[rsp+128h]
    movzx   esi,byte ptr [rsp+0Fh]
    mov     rdx,[rsp+120h]
    call    fn2
    lea     rax,[rsp+128h]
    mov     [rsp+100h],rax
    mov     qword ptr [rsp+8],0
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k3]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+100h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn4
    mov     [rsp+108h],rax
    mov     byte ptr [rsp],0
    mov     rdx,[rsp+108h]
    movzx   ecx,byte ptr [rsp]
    mov     [rdx],cl
    lea     rsi,[rsp+128h]
    mov     [rsp+0F0h],rsi
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA0h
    lea     rdx,[k5]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+0F0h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn6
    mov     [rsp+0F8h],rax
    mov     byte ptr [rsp],0
    mov     rdx,[rsp+0F8h]
    movzx   ecx,byte ptr [rsp]
    mov     [rdx],cl
    mov     qword ptr [rsp+0E8h],2
    nop     [rax+rax]
L1:
    mov     rax,[rsp+0E8h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+0E8h]
    mov     [rsp+0C8h],rdx
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF58h
    mov     edx,0FFFFFF60h
    mov     ecx,0FFFFFF70h
    mov     r8d,0FFFFFF68h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rsp+0C0h],0FFh
    je      L2
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k7]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym8]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+0B8h]
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+140h]
    cmp     rdx,rax
    jb      L8
    lea     rsi,[rsp+128h]
    mov     [rsp+0A0h],rsi
    mov     rdi,[rsp+0E8h]
    mov     [rsp+98h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k9]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+8]
    call    fn10
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0B7h],al
    test    byte ptr [rsp+0B7h],0FFh
    je      L6
    mov     rsi,[rsp+0E8h]
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+0E8h]
    mov     [rsp+80h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFF10h
    mov     edx,0FFFFFF18h
    mov     ecx,0FFFFFF28h
    mov     r8d,0FFFFFF20h
    call    ryo_h_MulOvfUW64
    test    byte ptr [rsp+78h],0FFh
    je      L3
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k11]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym12]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+70h]
    mov     [rsp+90h],rax
    nop     [rax+rax]
    nop     [rax]
L4:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+140h]
    cmp     rdx,rax
    jb      L6
    lea     rsi,[rsp+128h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+90h]
    mov     [rsp+48h],rdi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k13]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+50h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+8]
    call    fn14
    mov     [rsp+58h],rax
    mov     byte ptr [rsp],0
    mov     rdx,[rsp+58h]
    movzx   ecx,byte ptr [rsp]
    mov     [rdx],cl
    mov     rsi,[rsp+0E8h]
    mov     [rsp+40h],rsi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFED0h
    mov     edx,0FFFFFED8h
    mov     ecx,0FFFFFF30h
    mov     r8d,0FFFFFEE0h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+38h],0FFh
    je      L5
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k15]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym16]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L5:
    mov     rax,[rsp+30h]
    mov     [rsp+90h],rax
    jmp     L4
L6:
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEC0h
    mov     edx,0FFFFFEC8h
    mov     ecx,0FFFFFF88h
    mov     r8d,0FFFFFEA8h
    call    ryo_h_AddOvfUW64
    test    byte ptr [rsp+28h],0FFh
    je      L7
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEA8h
    lea     rdx,[k17]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+8]
    call    qword ptr [sym18]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+0E8h],rax
    jmp     L1
L8:
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFFE8h
    mov     edx,0FFFFFFC8h
    mov     ecx,18h
    call    ryo_h_Copy
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    add     rsp,168h
    ret
    nop     [rax+rax]
    nop     [rax]
L9:
    lea     rax,[rsp+128h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn19
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L10:
    call    qword ptr [sym20]
    lea     rdi,[rsp+160h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+160h]
    mov     rsi,rax
    mov     edx,0FFFFFEB8h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+160h]
    mov     rsi,rax
    mov     edx,0FFFFFEB8h
    call    ryo_h_Lpad
    jmp     L10

fn std::clone::impls::<impl std::clone::Clone for bool>::clone
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret

fn std::cmp::impls::<impl std::cmp::PartialEq for usize>::eq
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    sete    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le
    sub     rsp,38h
    mov     [rsp+20h],rdi
    mov     [rsp+18h],rsi
    mov     rax,[rsp+20h]
    mov     rax,[rax]
    mov     rdx,[rsp+18h]
    mov     rdx,[rdx]
    cmp     rax,rdx
    setbe   [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt
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

fn std::fmt::Arguments::<'_>::new::<39, 3>
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

fn std::hint::assert_unchecked::precondition_check
    sub     rsp,88h
    mov     [rsp+7Fh],dil
    mov     [rsp+18h],rsi
    test    byte ptr [rsp+7Fh],0FFh
    jne     L0
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFE8h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+70h],0DDh
    mov     rdx,[rsp+68h]
    mov     rsi,[rsp+70h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+80h]
    mov     esi,0FFFFFFA0h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0DDh
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+80h]
    call    ryo_h_Unreachable
    ud2
L0:
    add     rsp,88h
    ret

fn std::hint::black_box::<usize>
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    mov     [rsp+8],rax
    mov     rax,[rsp+8]
    add     rsp,18h
    ret

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
    sub     rsp,58h
    mov     [rsp+38h],rdi
    mov     [rsp+30h],rsi
    mov     rax,[rsp+38h]
    mov     [rsp+18h],rax
    lea     rdx,[rsp+30h]
    mov     [rsp+10h],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+10h]
    call    fn0
    mov     [rsp+27h],al
    test    byte ptr [rsp+27h],0FFh
    je      L0
    mov     rdx,[rsp+30h]
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
    nop     [rax]
L2:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    sub     rsp,78h
    mov     [rsp+60h],rdi
    mov     [rsp+58h],rsi
    mov     [rsp+50h],rdx
    mov     rax,[rsp+60h]
    mov     [rsp+38h],rax
    mov     byte ptr [rsp+4Fh],1
    mov     rsi,[rsp+58h]
    mov     [rsp+20h],rsi
    mov     rdi,[rsp+60h]
    mov     [rsp+10h],rdi
    mov     r8,[rsp+50h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+10h]
    mov     rsi,[rsp+8]
    call    fn0
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+4Fh],0
    mov     rdx,[rsp+20h]
    mov     [rsp+28h],rdx
    mov     rsi,[rsp+18h]
    mov     [rsp+30h],rsi
    mov     rdi,[rsp+38h]
    mov     rsi,[rsp+28h]
    mov     rdx,[rsp+30h]
    call    fn1
    mov     [rsp+68h],rax
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
L0:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
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
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L2

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>>
    sub     rsp,28h
    mov     [rsp+8],rdi
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp]
    call    fn0
    mov     [rsp+10h],rax
    mov     [rsp+18h],rdx
    mov     rax,[rsp+10h]
    mov     rdx,[rsp+18h]
    add     rsp,28h
    ret

fn std::ops::RangeInclusive::<usize>::new
    sub     rsp,38h
    mov     [rsp],rdi
    mov     [rsp+10h],rsi
    mov     [rsp+8],rdx
    mov     rax,[rsp+10h]
    mov     [rsp+18h],rax
    mov     rdx,[rsp+8]
    mov     [rsp+20h],rdx
    mov     byte ptr [rsp+28h],0
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFD0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp]
    add     rsp,38h
    ret

fn std::option::Option::<usize>::unwrap
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+8],rdx
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    lea     rdi,[rsp+30h]
    mov     esi,0FFFFFFE0h
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
    .long   L3
    .long   L1
L1:
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L2:
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym0]
    lea     rdi,[rsp+30h]
    call    ryo_h_Unreachable
    ud2
L3:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check
    sub     rsp,98h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     [rsp+18h],rdx
    mov     rax,[rsp+88h]
    cmp     rax,[rsp+80h]
    jb      L0
    add     rsp,98h
    ret
L0:
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFFE0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+78h],0C9h
    mov     rdx,[rsp+70h]
    mov     rsi,[rsp+78h]
    mov     [rsp+50h],rdx
    lea     rdi,[rsp+90h]
    mov     esi,0FFFFFF90h
    lea     rdx,[k1]
    call    ryo_h_AddrAbs
    mov     qword ptr [rsp+28h],0C9h
    mov     rdx,[rsp+28h]
    shl     rdx,1
    or      rdx,1
    mov     rsi,[rsp+50h]
    mov     [rsp+58h],rsi
    mov     [rsp+60h],rdx
    mov     byte ptr [rsp+17h],0
    mov     r8,[rsp+18h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+58h]
    mov     rsi,[rsp+60h]
    movzx   edx,byte ptr [rsp+17h]
    mov     rcx,[rsp+8]
    call    qword ptr [sym2]
    lea     rdi,[rsp+90h]
    call    ryo_h_Unreachable
    ud2

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn0
    jmp     L3
    nop
L0:
    add     rsp,28h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L1:
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFE8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L2:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn1
    jmp     L1
L3:
    mov     rax,[rsp+18h]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn2
    jmp     L0
    nop     [rax+rax]
L4:
    call    qword ptr [sym3]
    lea     rdi,[rsp+20h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L2
    lea     rdi,[rsp+20h]
    mov     rsi,rax
    mov     edx,0FFFFFFE8h
    call    ryo_h_Lpad
    jmp     L4

fn std::ptr::drop_glue::<std::vec::set_len_on_drop::SetLenOnDrop<'_>> - shim(Some(std::vec::set_len_on_drop::SetLenOnDrop<'_>))
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    fn0
    add     rsp,18h
    ret

fn std::rt::lang_start::<()>
    sub     rsp,58h
    mov     [rsp+40h],rdi
    mov     [rsp+38h],rsi
    mov     [rsp+30h],rdx
    mov     [rsp+2Fh],cl
    mov     rax,[rsp+40h]
    mov     [rsp+8],rax
    lea     rdx,[rsp+8]
    mov     [rsp+10h],rdx
    mov     [rsp+18h],rdx
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD0h
    lea     rdx,[k0]
    call    ryo_h_AddrAbs
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

fn std::rt::lang_start::<()>::{closure#0}
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
    mov     [rsp+0Eh],al
    lea     rdi,[rsp+20h]
    mov     esi,0FFFFFFFCh
    mov     edx,0FFFFFFEEh
    call    ryo_h_ZextW8W32
    mov     eax,[rsp+1Ch]
    add     rsp,28h
    ret

fn std::slice::Iter::<'_, bool>::new
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
    je      L0
    mov     [rsp+48h],rax
    jmp     L1
L0:
    mov     rax,[rsp+38h]
    imul    rcx,[rsp+40h],1
    add     rax,rcx
    mov     [rsp+48h],rax
L1:
    mov     rax,[rsp+38h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+48h]
    mov     [rsp+68h],rdx
    mov     rax,[rsp+60h]
    mov     rdx,[rsp+68h]
    add     rsp,78h
    ret

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()>
    sub     rsp,18h
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    fn0
    add     rsp,18h
    ret

fn std::vec::Vec::<bool>::extend_with
    sub     rsp,0A8h
    mov     [rsp+98h],rdi
    mov     [rsp+90h],rsi
    mov     [rsp+8Fh],dl
    mov     byte ptr [rsp+57h],1
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+90h]
    call    fn0
    mov     rax,[rsp+98h]
    mov     rax,[rax+8]
    mov     rdx,[rsp+98h]
    mov     rdx,[rdx+10h]
    mov     [rsp+28h],rdx
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     rdx,rcx
    setbe   [rsp+27h]
    imul    rcx,rdx,1
    add     rax,rcx
    mov     [rsp+80h],rax
    mov     rsi,[rsp+98h]
    lea     rsi,[rsi+10h]
    mov     [rsp+20h],rsi
    mov     rsi,[rsi]
    mov     rdi,[rsp+20h]
    mov     [rsp+28h],rdi
    mov     [rsp+30h],rsi
    mov     qword ptr [rsp+70h],1
    mov     r9,[rsp+90h]
    mov     [rsp+78h],r9
    nop
L0:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L11
    jmp     L10
    nop     [rax+rax]
    nop     [rax+rax]
L1:
    mov     rax,[rsp+20h]
    movzx   ecx,byte ptr [rsp+1Fh]
    mov     [rax],cl
    mov     qword ptr [rsp+8],1
    mov     rsi,[rsp+80h]
    imul    rcx,[rsp+8],1
    add     rsi,rcx
    mov     [rsp+80h],rsi
    mov     rdi,[rsp+30h]
    add     rdi,1
    mov     [rsp+30h],rdi
    jmp     L0
    xchg    ax,ax
L2:
    mov     byte ptr [rsp+57h],0
    movzx   edx,byte ptr [rsp+8Fh]
    mov     [rsp+26h],dl
    mov     rsi,[rsp+80h]
    movzx   ecx,byte ptr [rsp+26h]
    mov     [rsi],cl
    mov     rdi,[rsp+30h]
    add     rdi,1
    mov     [rsp+30h],rdi
    lea     r8,[rsp+28h]
    mov     [rsp+8],r8
    mov     rdi,[rsp+8]
    call    fn1
    jmp     L14
    nop     [rax+rax]
L3:
    lea     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn2
    test    byte ptr [rsp+57h],0FFh
    jne     L7
    nop     [rax+rax]
L4:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
L5:
    lea     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn3
    jmp     L9
    nop     [rax+rax]
    nop
L6:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF98h
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
    test    byte ptr [rsp+57h],0FFh
    je      L6
    jmp     L8
L10:
    mov     rax,[rsp+70h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L13
    jmp     L12
L11:
    cmp     qword ptr [rsp+90h],0
    ja      L2
    jmp     L3
L12:
    mov     qword ptr [rsp+8],1
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF60h
    lea     rdx,[k4]
    call    ryo_h_AddrAbs
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn5
L13:
    mov     rax,[rsp+18h]
    add     rax,1
    mov     [rsp+70h],rax
    mov     rdx,[rsp+80h]
    mov     [rsp+20h],rdx
    lea     rsi,[rsp+8Fh]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+10h]
    call    fn6
    mov     [rsp+1Fh],al
    jmp     L1
L14:
    jmp     L4
    nop     [rax+rax]
L15:
    call    qword ptr [sym7]
    lea     rdi,[rsp+0A0h]
    call    ryo_h_Unreachable
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L9
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L15
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L5

fn std::vec::Vec::<bool>::reserve
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
    je      L3
    jmp     L4
    nop     [rax+rax]
    nop     [rax]
L0:
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+48h]
    mov     rdx,[rsp+60h]
    mov     rcx,[rsp+30h]
    mov     r8,[rsp+38h]
    call    qword ptr [sym1]
    nop
L1:
    add     rsp,78h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L2:
    mov     rax,[rsp+18h]
    sub     rax,[rsp+48h]
    cmp     rax,[rsp+60h]
    setb    [rsp+2Fh]
    test    byte ptr [rsp+2Fh],0FFh
    je      L1
    jmp     L0
L3:
    mov     qword ptr [rsp+18h],0FFFFFFFFFFFFFFFFh
    jmp     L2
L4:
    mov     rax,[rsp+40h]
    mov     rax,[rax]
    mov     [rsp+18h],rax
    jmp     L2

fn std::vec::from_elem::<bool>
    sub     rsp,38h
    mov     [rsp],rdi
    mov     [rsp+17h],sil
    mov     [rsp+8],rdx
    lea     rdi,[rsp+18h]
    movzx   esi,byte ptr [rsp+17h]
    mov     rdx,[rsp+8]
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

