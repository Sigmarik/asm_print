section .text

global _start                  ; predefined entry point name for ld

_start:
    mov rsi, Msg
    push rsi
    call printf

    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall

printf:
    mov rax, 0x01; RAX = write64
    mov rdi, 1 ; RDI = stdout
    mov rsi, [rsp - 4] ; RSI = message start
    mov rdx, 1 ; Printed part size is 1 (printing char-by-char)
    
    syscall

    ; WriteLoopBgn:
    ;     mov rbx, [rsi] ; RBX = current character
    ;     cmp rbx, 0 ; If current caracter is the terminator, return
    ;     je WriteLoopEnd

    ;     syscall ; Print the symbol

    ;     inc rsi ; Move to the next symbol
    ; WriteLoopEnd:

    ret

section     .data
            
Msg:        db "Hello, world! I work for you now!\n", 0x00
MsgLen      equ $ - Msg