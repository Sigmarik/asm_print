default rel

global print:function

extern printf

section .text

%include "print_macros.s"

;--------------------------------------------------\
; Mimic std printf
;--------------------------------------------------
; IN:    [cdecl-filled stack]
;        RDI = current buffer end ptr
; OUT:   message on the screen
; DESTR: RSI RDI RDX RAX RBX RCX
;--------------------------------------------------
print:
    push rbp
    mov rbp, rsp

    xor rax, rax

    mov rdi, start_msg
    call printf wrt ..plt

    ;            v~~ push ret_addr, push rbp
    add rbp, 8 * 2; RBP = first argument ptr
    read_argument rsi; RSI = format ptr

    lea rdi, [PrintBuffer]

    .ReadLoopBgn:
        mov dl, [rsi]
        cmp dl, 0
        je .ReadLoopEnd

        cmp dl, '%'; If character is '%', process it as a special character
        jne .SkipSpecialCharacter
            xor rdx, rdx
            inc rsi
            mov dl, [rsi]; dl = next character after the '%'

            cmp dl, 0; If it is zero, stop reading.
            je .ReadLoopEnd

            lea rcx, [PrintJmpTable]
            jmp [rcx + rdx * 8]; Switch by dl character

            .PrintBinary:
                read_argument rax
                print_binary
            jmp .ReadLoopContinue

            .PrintOctal:
                read_argument rax
                print_octo
            jmp .ReadLoopContinue

            .PrintDecimal:
                read_argument rax
                print_decimal
            jmp .ReadLoopContinue

            .PrintChar:
                read_argument rax
                print_char al
            jmp .ReadLoopContinue

            .PrintHex:
                read_argument rax
                print_hex
            jmp .ReadLoopContinue

            .PrintString:
                read_argument rax
                print_string rax; CAUTION: Destroys DL!
            jmp .ReadLoopContinue

            
        .SkipSpecialCharacter:

        print_char dl

        .ReadLoopContinue:
        inc rsi
        jmp .ReadLoopBgn
    .ReadLoopEnd:

    flush_pb

    push rax
    pop rax; Align the stack

    xor rax, rax

    mov rdi, end_msg
    call printf wrt ..plt

    pop rbp
    ret

section     .data

DigitTable: db "0123456789ABCDEF"
DigitBuffer: times 64 db '0'

section .rodata
PrintJmpTable:
    times '%' dq print.ReadLoopContinue
    dq print.SkipSpecialCharacter; '%'
    times 'b' - '%' - 1 dq print.ReadLoopContinue
    dq print.PrintBinary;  'b'
    dq print.PrintChar;    'c'
    dq print.PrintDecimal; 'd'
    times 'o' - 'd' - 1 dq print.ReadLoopContinue
    dq print.PrintOctal;   'o'
    times 's' - 'o' - 1 dq print.ReadLoopContinue
    dq print.PrintString;  's'
    times 'x' - 's' - 1 dq print.ReadLoopContinue
    dq print.PrintHex;     'x'
    times 256 - 'x' - 1 dq print.ReadLoopContinue; <- Safety pad

start_msg db "Here is a random quote: ", 0xA, 0
end_msg db 0x9, 0x9, 0x9, "- Sun Tzu, ", 0x22, "The art of war", 0x22, 0xA, 0

section .bss

PrintBuffer: resb 1024
PrintBufferEnd: