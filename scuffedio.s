section .text

%include "util.s"

global _start                  ; predefined entry point name for ld

_start:
    mov rsi, 'a'
    push rsi
    call printf

    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall

printf:
    mov rdx, [rsp + 8]
    mov rdi, PrintBuffer
    out_char
    flush_pb
    ret

section     .data

Msg:        db "Hello, world! I work for you now!\n", 0x00
MsgLen      equ $ - Msg

section .bss

PrintBuffer: resb 1024
PrintBufferEnd: