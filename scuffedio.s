section .text

%include "util.s"

global _start                  ; predefined entry point name for ld

_start:
    mov rdi, PrintBuffer
    mov rsi, Msg
    push 123
    push 123
    push 123
    push 123
    push SecondaryMsg
    push rsi
    call printf

    mov rax, 0x3C      ; exit64 (rdi)
    xor rdi, rdi
    syscall

;--------------------------------------------------\
; Print the string (stack top) to the console.
;--------------------------------------------------
; IN:    [filled stack]
;        RDI = current buffer end ptr
; OUT:   message on the screen
; DESTR: RDX RAX
;--------------------------------------------------
printf:
    push rbp
    mov rbp, rsp

    add rbp, 16; RBP = first argument ptr
    read_argument rsi; RSI = format ptr
    ; mov rsi, [rsp]

    ReadLoopBgn:
        mov dl, [rsi]
        cmp dl, 0
        je ReadLoopEnd

        cmp dl, '%'; If character is '%', process it as the special character
        jne SkipSpecialCharacter
            xor rdx, rdx
            inc rsi
            mov dl, [rsi]; dl = next character after the '%'

            cmp dl, 0; If it is zero, stop reading.
            je ReadLoopEnd

            mov ecx, [PrintJmpTable + rdx * 4]
            jmp rcx; Switch by dl character

            PrintBinary:
                read_argument rax
                print_binary
            jmp ReadLoopContinue

            PrintOctal:
                read_argument rax
                print_octo
            jmp ReadLoopContinue

            PrintDecimal:
                read_argument rax
                print_decimal
            jmp ReadLoopContinue

            PrintChar:
                read_argument rax
                out_char al
            jmp ReadLoopContinue

            PrintHex:
                read_argument rax
                print_hex
            jmp ReadLoopContinue

            PrintString:
                read_argument rax
                print_string rax; CAUTION: Destroys DL!
            jmp ReadLoopContinue

            
        SkipSpecialCharacter:

        out_char dl

        ReadLoopContinue:
        inc rsi
        jmp ReadLoopBgn
    ReadLoopEnd:

    flush_pb

    pop rbp
    ret

section     .data

DigitTable: db "0123456789ABCDEF"
DigitBuffer: times 64 db '0'

PrintJmpTable:
    times '%' dd ReadLoopContinue
    dd SkipSpecialCharacter; '%'
    times 'b' - '%' - 1 dd ReadLoopContinue
    dd PrintBinary; 'b'
    dd PrintChar; 'c'
    dd PrintDecimal; 'd'
    times 'o' - 'd' - 1 dd ReadLoopContinue
    dd PrintOctal; 'o'
    times 's' - 'o' - 1 dd ReadLoopContinue
    dd PrintString; 's'
    times 'x' - 's' - 1 dd ReadLoopContinue
    dd PrintHex; 'x'
    times 256 dd ReadLoopContinue; <- Safety pad

Msg: db "Hello, world %s! I work 100%% for you now!", 0x0A
     db "The number 123 is %b in binary.", 0x0A
     db "The number 123 is also %o in octo.", 0x0A
     db "And who would have thought that number 123 is also %x in hexadecimal!", 0x0A
     db "In decimal 123 is... well... %d. What a surprize.", 0x0A, 0x00

SecondaryMsg: db "[unnamed_world_1]", 0x00

section .bss

PrintBuffer: resb 1024
PrintBufferEnd: