default rel

global call_asm:function

section .text
call_asm:
    pop r10
    mov [return_addr], r10
    
    push r9
    push r8
    push rcx
    push rdx
    push rsi

    call rdi

    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9

    mov r10, [return_addr]
    push r10
    ret

section .data

return_addr dq 0
