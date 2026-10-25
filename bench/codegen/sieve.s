fn <() as std::process::Termination>::report [hint]
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

fn <alloc::raw_vec::RawVec<bool> as std::ops::Drop>::drop
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

fn <bool as std::vec::is_zero::IsZero>::is_zero [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,28h
    mov     [rsp+10h],rdi
    mov     rax,[rsp+10h]
    movzx   eax,byte ptr [rax]
    xor     al,1
    mov     [rsp+1Fh],al
    movzx   eax,byte ptr [rsp+1Fh]
    add     rsp,28h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <bool as std::vec::spec_from_elem::SpecFromElem>::from_elem::<std::alloc::Global> [hint]
    inc     qword ptr [jit_record]
    jns     L31
L0:
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
    je      L1
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
    jmp     L17
L1:
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
    jmp     L20
    nop     [rax+rax]
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L3:
    mov     rax,[rsp+58h]
    mov     [rsp+98h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+0A0h],rdx
    mov     rsi,[rsp+68h]
    mov     [rsp+0A8h],rsi
    nop     [rax+rax]
    nop     [rax]
L4:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L5:
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
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L25
L7:
    lea     rax,[rsp+58h]
    mov     [rsp+10h],rax
    mov     rdi,[rsp+10h]
    call    fn5
    jmp     L14
    nop     [rax+rax]
    nop     [rax]
L8:
    inc     qword ptr [jit_record.ctr_l]
    jns     L26
L9:
    test    byte ptr [rsp+86h],0FFh
    jne     L16
    nop     [rax+rax]
L10:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L11:
    lea     rdi,[rsp+0B0h]
    mov     esi,0FFFFFFC8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L13:
    jmp     L8
    nop
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L15:
    test    byte ptr [rsp+87h],0FFh
    je      L8
    jmp     L12
L16:
    jmp     L10
L17:
    mov     rax,[rsp+30h]
    mov     [rsp+28h],rax
    cmp     rax,0
    je      L19
    jmp     L18
    ud2
L18:
    mov     rax,[rsp+38h]
    mov     rcx,[rsp+40h]
    mov     [rsp+20h],rcx
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+20h]
    call    qword ptr [sym6]
    ud2
L19:
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
    jmp     L4
L20:
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
    jmp     L2
    nop     [rax+rax]
L21:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L22:
    call    qword ptr [sym8]
    ud2
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L14
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L21
    lea     rdi,[rsp+0B0h]
    mov     rsi,rax
    mov     edx,0FFFFFFC8h
    call    ryo_h_Lpad
    jmp     L6
L23:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L24:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L5
L25:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L7
L26:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L9
L27:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L11
L28:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L13
L29:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L15
L30:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L22
L31:
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

fn <std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize::<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L4
L0:
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
    movzx   eax,byte ptr [rsp+1Fh]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L3
L2:
    lea     rdi,[rsp+40h]
    mov     esi,0FFFFFFE0h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+40h]
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

fn <std::iter::Filter<std::slice::Iter<'_, bool>, {closure@bench/sieve.rs:24:37: 24:42}> as std::iter::Iterator>::count [hint]
    inc     qword ptr [jit_record]
    jns     L25
L0:
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
    cmp     rax,0
    je      L15
    jmp     L16
    nop     [rax+rax]
    nop
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L2:
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
    jmp     L17
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L4:
    mov     rax,[rsp+68h]
    add     rsp,78h
    ret
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L20
L6:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
    call    ryo_h_Resume
    ud2
    xchg    ax,ax
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L21
L8:
    test    byte ptr [rsp+4Fh],0FFh
    je      L5
    jmp     L5
    nop     [rax+rax]
    nop
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L22
L10:
    jmp     L7
    nop
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L23
L12:
    test    byte ptr [rsp+4Eh],0FFh
    je      L7
    jmp     L9
    nop     [rax+rax]
    nop
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L24
L14:
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
    ud2
L15:
    mov     qword ptr [rsp+50h],0FFFFFFFFFFFFFFFFh
    jmp     L13
L16:
    mov     rax,[rsp+38h]
    mov     [rsp+50h],rax
    jmp     L13
L17:
    mov     rdi,[rsp+68h]
    mov     rsi,[rsp+50h]
    call    fn3
    jmp     L3
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
    call    ryo_h_Lpad
    jmp     L11
L18:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L19:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L20:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L21:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L22:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L23:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L24:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L14
L25:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::iter::Rev<std::ops::RangeInclusive<usize>> as std::iter::Iterator>::find::<{closure@bench/sieve.rs:25:39: 25:43}> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::ControlFlow<usize> as std::ops::FromResidual<std::ops::ControlFlow<usize, std::convert::Infallible>>>::from_residual [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::ControlFlow<usize> as std::ops::Try>::branch [hint]
    inc     qword ptr [jit_record]
    jns     L4
L0:
    sub     rsp,48h
    mov     [rsp+20h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+20h]
    mov     [rsp+18h],rax
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+38h],rax
    mov     qword ptr [rsp+30h],1
    jmp     L3
L2:
    mov     qword ptr [rsp+30h],0
L3:
    mov     rax,[rsp+30h]
    mov     rdx,[rsp+38h]
    add     rsp,48h
    ret
L4:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::ControlFlow<usize> as std::ops::Try>::from_output [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     qword ptr [rsp],0
    mov     rax,[rsp]
    mov     rdx,[rsp+8]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::RangeInclusive<usize> as std::iter::DoubleEndedIterator>::rfind::<{closure@bench/sieve.rs:25:39: 25:43}> [hint]
    inc     qword ptr [jit_record]
    jns     L10
L0:
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
    cmp     rax,0
    je      L2
    jmp     L1
    ud2
L1:
    mov     rax,[rsp+28h]
    mov     [rsp+48h],rax
    mov     qword ptr [rsp+40h],1
    jmp     L7
L2:
    mov     qword ptr [rsp+40h],0
    jmp     L7
    nop     [rax+rax]
    nop     [rax+rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L8
L4:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
    ret
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L9
L6:
    jmp     L3
L7:
    mov     rax,[rsp+20h]
    mov     [rsp+8],rax
    cmp     rax,0
    je      L5
    jmp     L3
L8:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L9:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L6
L10:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::ops::RangeInclusive<usize> as std::iter::Iterator>::rev [hint]
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

fn <std::ops::RangeInclusive<usize> as std::iter::range::RangeInclusiveIteratorImpl>::spec_try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>> [hint]
    inc     qword ptr [jit_record]
    jns     L35
L0:
    sub     rsp,0A8h
    mov     [rsp+88h],rdi
    mov     [rsp+80h],rsi
    mov     byte ptr [rsp+66h],1
    mov     rdx,[rsp+88h]
    movzx   edx,byte ptr [rdx+10h]
    mov     [rsp+56h],dl
    test    byte ptr [rsp+56h],0FFh
    je      L26
    jmp     L25
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    mov     byte ptr [rsp+66h],0
    call    fn0
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L13
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L4:
    mov     byte ptr [rsp+66h],0
    mov     byte ptr [rsp+67h],1
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L6:
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
    je      L9
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
    cmp     rax,0
    je      L7
    jmp     L8
    ud2
L7:
    mov     byte ptr [rsp+67h],1
    jmp     L5
L8:
    mov     rax,[rsp+38h]
    mov     [rsp+28h],rax
    mov     rdi,[rsp+28h]
    call    fn5
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L13
L9:
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
    je      L12
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
    cmp     rax,0
    je      L10
    jmp     L11
L10:
    jmp     L12
L11:
    mov     rax,[rsp+48h]
    mov     [rsp+38h],rax
    mov     rdi,[rsp+38h]
    call    fn9
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L13
L12:
    mov     byte ptr [rsp+67h],0
    call    fn10
    mov     [rsp+90h],rax
    mov     [rsp+98h],rdx
    jmp     L13
L13:
    mov     rax,[rsp+90h]
    mov     rdx,[rsp+98h]
    add     rsp,0A8h
    ret
    nop
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L15:
    jmp     L24
    nop
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L17:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFFB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax+rax]
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L19:
    jmp     L14
    nop
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L21:
    test    byte ptr [rsp+67h],0FFh
    je      L14
    jmp     L18
    nop     [rax+rax]
    nop
L22:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L23:
    jmp     L16
L24:
    test    byte ptr [rsp+66h],0FFh
    je      L16
    jmp     L22
L25:
    jmp     L1
L26:
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
    je      L3
    jmp     L1
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L14
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFFB8h
    call    ryo_h_Lpad
    jmp     L20
L27:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L28:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L15
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L17
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L19
L33:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L21
L34:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L23
L35:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::filter::<{closure@bench/sieve.rs:24:37: 24:42}> [hint]
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::fold::<usize, {closure@std::iter::adapters::map::map_fold<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}}> [hint]
    inc     qword ptr [jit_record]
    jns     L39
L0:
    sub     rsp,0D8h
    mov     [rsp+0B8h],rdi
    mov     [rsp+0C0h],rsi
    mov     [rsp+0B0h],rdx
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L1
    mov     rsi,[rsp+0C0h]
    cmp     rsi,0
    sete    [rsp+77h]
    jmp     L2
L1:
    mov     rax,[rsp+0C0h]
    mov     rdx,[rsp+0B8h]
    cmp     rdx,rax
    sete    [rsp+77h]
L2:
    test    byte ptr [rsp+77h],0FFh
    je      L3
    mov     byte ptr [rsp+86h],0
    mov     rsi,[rsp+0B0h]
    mov     [rsp+0C8h],rsi
    jmp     L11
L3:
    mov     byte ptr [rsp+86h],0
    mov     byte ptr [rsp+87h],1
    mov     rsi,[rsp+0B0h]
    mov     [rsp+70h],rsi
    mov     qword ptr [rsp+98h],0
    mov     byte ptr [rsp+17h],0
    test    byte ptr [rsp+17h],0FFh
    je      L4
    mov     r10,[rsp+0C0h]
    mov     [rsp+90h],r10
    jmp     L5
L4:
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
    je      L26
    jmp     L25
    nop     [rax+rax]
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L6:
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
    je      L29
    jmp     L28
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L8:
    mov     rax,[rsp+70h]
    mov     [rsp+0C8h],rax
    jmp     L11
    nop     [rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L10:
    jmp     L5
L11:
    mov     rax,[rsp+0C8h]
    add     rsp,0D8h
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
    lea     rdi,[rsp+0D0h]
    mov     esi,0FFFFFFA8h
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
    test    byte ptr [rsp+87h],0FFh
    je      L12
    jmp     L16
    nop     [rax]
L20:
    inc     qword ptr [jit_record.ctr_l]
    jns     L37
L21:
    jmp     L14
L22:
    test    byte ptr [rsp+86h],0FFh
    je      L14
    jmp     L20
    nop     [rax+rax]
L23:
    inc     qword ptr [jit_record.ctr_l]
    jns     L38
L24:
    jmp     L5
L25:
    mov     rax,[rsp+68h]
    mov     [rsp+40h],rax
    mov     rdx,[rsp+60h]
    mov     [rsp+38h],rdx
    lea     rsi,[k1]
    mov     [rsp+10h],rsi
    mov     rdi,[rsp+40h]
    mov     rsi,[rsp+38h]
    mov     rdx,[rsp+10h]
    call    fn2
L26:
    mov     qword ptr [rsp+10h],0
    cmp     qword ptr [rsp+10h],1
    setb    [rsp+47h]
    test    byte ptr [rsp+47h],0FFh
    je      L27
    mov     qword ptr [rsp+10h],1
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+46h]
    test    byte ptr [rsp+46h],0FFh
    je      L27
    mov     r10,[rsp+48h]
    sub     r10,[rsp+50h]
    mov     [rsp+90h],r10
    jmp     L23
L27:
    lea     rax,[k3]
    mov     [rsp+8],rax
    mov     qword ptr [rsp+10h],49h
    lea     rsi,[k4]
    mov     [rsp],rsi
    mov     rdi,[rsp+8]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp]
    call    qword ptr [sym5]
    ud2
L28:
    mov     qword ptr [rsp+10h],1
    lea     rdx,[k6]
    mov     [rsp+8],rdx
    mov     rdi,[rsp+98h]
    mov     rsi,[rsp+10h]
    mov     rdx,[rsp+8]
    call    fn7
L29:
    mov     rax,[rsp+98h]
    add     rax,1
    mov     [rsp+98h],rax
    mov     [rsp+60h],rax
    mov     rdx,[rsp+90h]
    mov     [rsp+58h],rdx
    cmp     rax,rdx
    je      L7
    jmp     L9
    lea     rdi,[rsp+0D0h]
    mov     rsi,rax
    mov     edx,0FFFFFFA8h
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::map::<usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}> [hint]
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

fn <std::slice::Iter<'_, bool> as std::iter::Iterator>::size_hint [hint]
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
    cmp     qword ptr [rsp+10h],1
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L8
    mov     qword ptr [rsp+10h],1
    mov     r8,[rsp+10h]
    mov     rcx,7FFFFFFFFFFFFFFFh
    cmp     r8,rcx
    setbe   [rsp+26h]
    test    byte ptr [rsp+26h],0FFh
    je      L8
    mov     r10,[rsp+28h]
    sub     r10,[rsp+30h]
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

fn <std::slice::Iter<'_, bool> as std::iter::adapters::filter::SpecAssumeCount>::assume_count_le_upper_bound [hint]
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,28h
    mov     [rsp+18h],rdi
    mov     [rsp+10h],rsi
    mov     rax,[rsp+18h]
    cmp     rax,[rsp+10h]
    setbe   [rsp+0Fh]
    mov     byte ptr [rsp+0Eh],1
    test    byte ptr [rsp+0Eh],0FFh
    je      L1
    lea     rdi,[k0]
    mov     [rsp],rdi
    movzx   edi,byte ptr [rsp+0Fh]
    mov     rsi,[rsp]
    call    fn1
L1:
    add     rsp,28h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <std::vec::Vec<bool> as std::ops::Deref>::deref [hint]
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

fn <std::vec::Vec<bool> as std::ops::Drop>::drop
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

fn <std::vec::Vec<bool> as std::ops::Index<usize>>::index [hint]
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

fn <std::vec::Vec<bool> as std::ops::IndexMut<usize>>::index_mut [hint]
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

fn <std::vec::set_len_on_drop::SetLenOnDrop<'_> as std::ops::Drop>::drop [hint]
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

fn <usize as std::iter::Step>::backward_unchecked [hint]
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
    sub     rax,[rsp+8]
    mov     [rsp+18h],rax
    mov     rax,[rsp+18h]
    add     rsp,28h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::iter::Sum>::sum::<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L2
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     [rsp+20h],rdx
    mov     rax,[rsp+28h]
    add     rax,[rsp+20h]
    setb    cl
    mov     [rsp+18h],cl
    mov     [rsp+10h],rax
    test    byte ptr [rsp+18h],0FFh
    je      L1
    lea     rsi,[k0]
    mov     [rsp+8],rsi
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    ud2
L1:
    mov     rax,[rsp+10h]
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::slice::SliceIndex<[bool]>>::index [hint]
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
    imul    rcx,[rsp+30h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
L2:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn <usize as std::slice::SliceIndex<[bool]>>::index_mut [hint]
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
    imul    rcx,[rsp+30h],1
    add     rax,rcx
    mov     [rsp+38h],rax
    mov     rax,[rsp+38h]
    add     rsp,48h
    ret
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

fn alloc::raw_vec::RawVecInner::with_capacity_in [hint]
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

fn core::fmt::rt::Argument::<'_>::new_display::<usize> [hint]
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

fn core::num::<impl usize>::unchecked_add::precondition_check [hint]
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

fn core::num::<impl usize>::unchecked_sub::precondition_check [hint]
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

fn core::slice::<impl [bool]>::iter [hint]
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

fn main
    inc     qword ptr [jit_record]
    jns     L7
L0:
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
    mov     rax,[rsp+100h]
    mov     rcx,[rsp+108h]
    mov     [rsp+10h],rcx
    mov     [rsp+8],rax
    mov     rdx,[rsp+110h]
    mov     [rsp+18h],rdx
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
    lea     rax,[k9]
    mov     [rsp+18h],rax
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
    lea     rdi,[k14]
    mov     [rsp+48h],rdi
    lea     r8,[rsp+80h]
    mov     [rsp+40h],r8
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
    xchg    ax,ax
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L2:
    lea     rax,[rsp+190h]
    mov     [rsp+18h],rax
    mov     rdi,[rsp+18h]
    call    fn18
    lea     rdi,[rsp+1B0h]
    mov     esi,0FFFFFE70h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
    nop     [rax]
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L6
L4:
    call    qword ptr [sym19]
    ud2
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L1
    lea     rdi,[rsp+1B0h]
    mov     rsi,rax
    mov     edx,0FFFFFE70h
    call    ryo_h_Lpad
    jmp     L3
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L6:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L7:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#0}
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn main::{closure#1}
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,48h
    mov     [rsp+30h],rdi
    mov     [rsp+28h],rsi
    mov     rax,[rsp+28h]
    mov     rax,[rax]
    mov     [rsp+20h],rax
    mov     rdx,[rsp+30h]
    mov     rdx,[rdx]
    mov     [rsp+10h],rdx
    lea     rsi,[k0]
    mov     [rsp+8],rsi
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn sieve
    inc     qword ptr [jit_record]
    jns     L20
L0:
    sub     rsp,168h
    mov     [rsp+10h],rdi
    mov     [rsp+140h],rsi
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+140h]
    add     rdx,[rsp+8]
    setb    cl
    mov     [rsp+118h],cl
    mov     [rsp+110h],rdx
    test    byte ptr [rsp+118h],0FFh
    je      L1
    lea     rdi,[k0]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    qword ptr [sym1]
    ud2
L1:
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
    lea     rsi,[k3]
    mov     [rsp],rsi
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
    lea     r8,[k5]
    mov     [rsp],r8
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
    nop
L2:
    inc     qword ptr [jit_record.ctr_l]
    jns     L16
L3:
    mov     rax,[rsp+0E8h]
    mov     [rsp+0D0h],rax
    mov     rdx,[rsp+0E8h]
    mov     [rsp+0C8h],rdx
    mul     rdx
    setb    cl
    mov     [rsp+0C0h],cl
    mov     [rsp+0B8h],rax
    test    byte ptr [rsp+0C0h],0FFh
    je      L4
    lea     rdi,[k7]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    qword ptr [sym8]
    ud2
L4:
    mov     rax,[rsp+0B8h]
    mov     [rsp+0D8h],rax
    mov     rdx,[rsp+140h]
    cmp     rdx,rax
    jb      L11
    lea     rsi,[rsp+128h]
    mov     [rsp+0A0h],rsi
    mov     rdi,[rsp+0E8h]
    mov     [rsp+98h],rdi
    lea     r8,[k9]
    mov     [rsp+8],r8
    mov     rdi,[rsp+0A0h]
    mov     rsi,[rsp+98h]
    mov     rdx,[rsp+8]
    call    fn10
    mov     [rsp+0A8h],rax
    mov     rax,[rsp+0A8h]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0B7h],al
    test    byte ptr [rsp+0B7h],0FFh
    je      L9
    mov     rsi,[rsp+0E8h]
    mov     [rsp+88h],rsi
    mov     rdi,[rsp+0E8h]
    mov     [rsp+80h],rdi
    mov     rax,[rsp+88h]
    mul     rdi
    setb    cl
    mov     [rsp+78h],cl
    mov     [rsp+70h],rax
    test    byte ptr [rsp+78h],0FFh
    je      L5
    lea     r9,[k11]
    mov     [rsp+8],r9
    mov     rdi,[rsp+8]
    call    qword ptr [sym12]
    ud2
L5:
    mov     rax,[rsp+70h]
    mov     [rsp+90h],rax
    nop     [rax+rax]
L6:
    inc     qword ptr [jit_record.ctr_l]
    jns     L17
L7:
    mov     rax,[rsp+90h]
    mov     [rsp+60h],rax
    mov     rdx,[rsp+140h]
    cmp     rdx,rax
    jb      L9
    lea     rsi,[rsp+128h]
    mov     [rsp+50h],rsi
    mov     rdi,[rsp+90h]
    mov     [rsp+48h],rdi
    lea     r8,[k13]
    mov     [rsp+8],r8
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
    mov     rdi,[rsp+90h]
    add     rdi,rsi
    setb    cl
    mov     [rsp+38h],cl
    mov     [rsp+30h],rdi
    test    byte ptr [rsp+38h],0FFh
    je      L8
    lea     r9,[k15]
    mov     [rsp+8],r9
    mov     rdi,[rsp+8]
    call    qword ptr [sym16]
    ud2
L8:
    mov     rax,[rsp+30h]
    mov     [rsp+90h],rax
    jmp     L6
L9:
    mov     qword ptr [rsp+8],1
    mov     rdx,[rsp+0E8h]
    add     rdx,[rsp+8]
    setb    cl
    mov     [rsp+28h],cl
    mov     [rsp+20h],rdx
    test    byte ptr [rsp+28h],0FFh
    je      L10
    lea     rdi,[k17]
    mov     [rsp+8],rdi
    mov     rdi,[rsp+8]
    call    qword ptr [sym18]
    ud2
L10:
    mov     rax,[rsp+20h]
    mov     [rsp+0E8h],rax
    jmp     L2
L11:
    mov     rax,[rsp+128h]
    mov     [rsp+148h],rax
    mov     rdx,[rsp+130h]
    mov     [rsp+150h],rdx
    mov     rsi,[rsp+138h]
    mov     [rsp+158h],rsi
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEB0h
    xor     edx,edx
    mov     ecx,0FFFFFFE8h
    mov     r8d,18h
    call    ryo_h_StoreCopy
    mov     rax,[rsp+10h]
    add     rsp,168h
    ret
    nop
L12:
    inc     qword ptr [jit_record.ctr_l]
    jns     L18
L13:
    lea     rax,[rsp+128h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn19
    lea     rdi,[rsp+160h]
    mov     esi,0FFFFFEB8h
    call    ryo_h_Resume
    ud2
    nop     [rax+rax]
L14:
    inc     qword ptr [jit_record.ctr_l]
    jns     L19
L15:
    call    qword ptr [sym20]
    ud2
    lea     rdi,[rsp+160h]
    mov     rsi,rax
    mov     edx,0FFFFFEB8h
    call    ryo_h_Lpad
    jmp     L12
    lea     rdi,[rsp+160h]
    mov     rsi,rax
    mov     edx,0FFFFFEB8h
    call    ryo_h_Lpad
    jmp     L14
L16:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L3
L17:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L7
L18:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L13
L19:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L15
L20:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::clone::impls::<impl std::clone::Clone for bool>::clone [always]
    inc     qword ptr [jit_record]
    jns     L1
L0:
    sub     rsp,18h
    mov     [rsp],rdi
    mov     rax,[rsp]
    movzx   eax,byte ptr [rax]
    mov     [rsp+0Fh],al
    movzx   eax,byte ptr [rsp+0Fh]
    add     rsp,18h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialEq for usize>::eq [hint]
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
    sete    [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::le [always]
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
    setbe   [rsp+2Fh]
    movzx   eax,byte ptr [rsp+2Fh]
    add     rsp,38h
    ret
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::cmp::impls::<impl std::cmp::PartialOrd for usize>::lt [always]
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

fn std::fmt::Arguments::<'_>::new::<39, 3> [hint]
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

fn std::hint::assert_unchecked::precondition_check [hint]
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

fn std::hint::black_box::<usize> [hint]
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

fn std::iter::DoubleEndedIterator::rfind::check::<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L6
L0:
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
    je      L1
    mov     rdx,[rsp+30h]
    mov     [rsp+48h],rdx
    mov     qword ptr [rsp+40h],1
    jmp     L2
L1:
    mov     qword ptr [rsp+40h],0
L2:
    mov     rax,[rsp+40h]
    mov     rdx,[rsp+48h]
    add     rsp,58h
    ret
    nop     [rax+rax]
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L5
L4:
    lea     rdi,[rsp+50h]
    mov     esi,0FFFFFFD8h
    call    ryo_h_Resume
    ud2
    lea     rdi,[rsp+50h]
    mov     rsi,rax
    mov     edx,0FFFFFFD8h
    call    ryo_h_Lpad
    jmp     L3
L5:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L4
L6:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::iter::adapters::map::map_fold::<&bool, usize, usize, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}, {closure@<usize as std::iter::Sum>::sum<std::iter::Map<std::slice::Iter<'_, bool>, {closure@<std::iter::Filter<I, P> as std::iter::Iterator>::count::to_usize<&bool, {closure@bench/sieve.rs:24:37: 24:42}>::{closure#0}}>>::{closure#0}}>::{closure#0}
    inc     qword ptr [jit_record]
    jns     L10
L0:
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
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L7
L2:
    lea     rdi,[rsp+70h]
    mov     esi,0FFFFFFD0h
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
    test    byte ptr [rsp+4Fh],0FFh
    je      L1
    jmp     L3
    lea     rdi,[rsp+70h]
    mov     rsi,rax
    mov     edx,0FFFFFFD0h
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

fn std::iter::range::<impl std::iter::DoubleEndedIterator for std::ops::RangeInclusive<usize>>::try_rfold::<(), {closure@std::iter::DoubleEndedIterator::rfind::check<usize, {closure@bench/sieve.rs:25:39: 25:43}>::{closure#0}}, std::ops::ControlFlow<usize>> [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ops::RangeInclusive::<usize>::new [hint]
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::option::Option::<usize>::unwrap [always]
    inc     qword ptr [jit_record]
    jns     L3
L0:
    sub     rsp,38h
    mov     [rsp+18h],rdi
    mov     [rsp+20h],rsi
    mov     [rsp+8],rdx
    mov     rax,[rsp+18h]
    mov     [rsp+10h],rax
    cmp     rax,0
    je      L1
    jmp     L2
    ud2
L1:
    mov     rax,[rsp+8]
    mov     [rsp],rax
    mov     rdi,[rsp]
    call    qword ptr [sym0]
    ud2
L2:
    mov     rax,[rsp+20h]
    mov     [rsp+28h],rax
    mov     rax,[rsp+28h]
    add     rsp,38h
    ret
L3:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::ptr::const_ptr::<impl *const T>::offset_from_unsigned::precondition_check [hint]
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

fn std::ptr::drop_glue::<alloc::raw_vec::RawVec<bool>> - shim(Some(alloc::raw_vec::RawVec<bool>))
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

fn std::ptr::drop_glue::<std::vec::Vec<bool>> - shim(Some(std::vec::Vec<bool>))
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

fn std::slice::Iter::<'_, bool>::new [hint]
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
    imul    rcx,[rsp+40h],1
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

fn std::sys::backtrace::__rust_begin_short_backtrace::<fn(), ()> [never]
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

fn std::vec::Vec::<bool>::extend_with
    inc     qword ptr [jit_record]
    jns     L37
L0:
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
    nop     [rax]
L1:
    inc     qword ptr [jit_record.ctr_l]
    jns     L27
L2:
    mov     rax,[rsp+70h]
    mov     rdx,[rsp+78h]
    cmp     rax,rdx
    setb    [rsp+27h]
    test    byte ptr [rsp+27h],0FFh
    je      L21
    jmp     L20
    nop
L3:
    inc     qword ptr [jit_record.ctr_l]
    jns     L28
L4:
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
    jmp     L1
    nop     [rax+rax]
L5:
    inc     qword ptr [jit_record.ctr_l]
    jns     L29
L6:
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
    jmp     L24
    nop     [rax+rax]
    nop     [rax]
L7:
    inc     qword ptr [jit_record.ctr_l]
    jns     L30
L8:
    lea     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn2
    test    byte ptr [rsp+57h],0FFh
    jne     L15
    nop     [rax+rax]
L9:
    inc     qword ptr [jit_record.ctr_l]
    jns     L31
L10:
    add     rsp,0A8h
    ret
    nop     [rax+rax]
    xchg    ax,ax
L11:
    inc     qword ptr [jit_record.ctr_l]
    jns     L32
L12:
    lea     rax,[rsp+28h]
    mov     [rsp+8],rax
    mov     rdi,[rsp+8]
    call    fn3
    jmp     L18
    nop     [rax+rax]
    nop     [rax]
L13:
    inc     qword ptr [jit_record.ctr_l]
    jns     L33
L14:
    lea     rdi,[rsp+0A0h]
    mov     esi,0FFFFFF98h
    call    ryo_h_Resume
    ud2
L15:
    jmp     L9
    nop     [rax+rax]
    nop     [rax]
L16:
    inc     qword ptr [jit_record.ctr_l]
    jns     L34
L17:
    jmp     L13
    nop
L18:
    inc     qword ptr [jit_record.ctr_l]
    jns     L35
L19:
    test    byte ptr [rsp+57h],0FFh
    je      L13
    jmp     L16
L20:
    mov     rax,[rsp+70h]
    mov     [rsp+18h],rax
    mov     byte ptr [rsp+0Fh],1
    test    byte ptr [rsp+0Fh],0FFh
    je      L23
    jmp     L22
L21:
    cmp     qword ptr [rsp+90h],0
    ja      L5
    jmp     L7
L22:
    mov     qword ptr [rsp+8],1
    lea     rdx,[k4]
    mov     [rsp],rdx
    mov     rdi,[rsp+18h]
    mov     rsi,[rsp+8]
    mov     rdx,[rsp]
    call    fn5
L23:
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
    jmp     L3
L24:
    jmp     L9
    nop     [rax]
L25:
    inc     qword ptr [jit_record.ctr_l]
    jns     L36
L26:
    call    qword ptr [sym7]
    ud2
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L18
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L25
    lea     rdi,[rsp+0A0h]
    mov     rsi,rax
    mov     edx,0FFFFFF98h
    call    ryo_h_Lpad
    jmp     L11
L27:
    lea     r11,[jit_record]
    xor     eax,eax
    call    qword ptr [r11+10h]
    jmp     L2
L28:
    lea     r11,[jit_record]
    mov     eax,1
    call    qword ptr [r11+10h]
    jmp     L4
L29:
    lea     r11,[jit_record]
    mov     eax,2
    call    qword ptr [r11+10h]
    jmp     L6
L30:
    lea     r11,[jit_record]
    mov     eax,3
    call    qword ptr [r11+10h]
    jmp     L8
L31:
    lea     r11,[jit_record]
    mov     eax,4
    call    qword ptr [r11+10h]
    jmp     L10
L32:
    lea     r11,[jit_record]
    mov     eax,5
    call    qword ptr [r11+10h]
    jmp     L12
L33:
    lea     r11,[jit_record]
    mov     eax,6
    call    qword ptr [r11+10h]
    jmp     L14
L34:
    lea     r11,[jit_record]
    mov     eax,7
    call    qword ptr [r11+10h]
    jmp     L17
L35:
    lea     r11,[jit_record]
    mov     eax,8
    call    qword ptr [r11+10h]
    jmp     L19
L36:
    lea     r11,[jit_record]
    mov     eax,9
    call    qword ptr [r11+10h]
    jmp     L26
L37:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

fn std::vec::Vec::<bool>::reserve
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

fn std::vec::from_elem::<bool>
    inc     qword ptr [jit_record]
    jns     L1
L0:
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
L1:
    lea     r11,[jit_record]
    call    qword ptr [r11+8]
    jmp     L0

