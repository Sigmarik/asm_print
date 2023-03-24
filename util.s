;--------------------------------------------------\
; Flush the buffer (print its content to the screen)
;--------------------------------------------------
; IN:    RDI = end of the buffer
; OUT:   RDI = buffer start
; DESTR: RAX, RDI, RSI, RDX
;--------------------------------------------------
%macro flush_pb 0
    mov rdx, rdi
    sub rdx, PrintBuffer; rdx = length of the message

    mov rax, 1; RAX = write64()
    mov rdi, 1; RDI = stdout
    mov rsi, PrintBuffer
    syscall
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Add character to the buffer, flush the buffer in case it has been overflown or '\n' was added.
;--------------------------------------------------
; IN:    DL = character to push
;        RDI = buffer end ptr
; OUT:   RDI = RDI + 1
; DESTR: DL, RDI
;--------------------------------------------------
%macro out_char 0
    mov [rdi], dl
    inc rdi
    cmp dl, 0x0A; '\n' character
    jne %%SkipFlush
    cmp rdi, PrintBufferEnd
    jne %%SkipFlush
        flush_pb
    %%SkipFlush:
%endmacro
;--------------------------------------------------/
