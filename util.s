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

    mov rdi, PrintBuffer
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Add character to the buffer, flush the buffer in case it has been overflown or '\n' was added.
;--------------------------------------------------
; IN:    [register 1] = character to push
;        RDI = buffer end ptr
; OUT:   RDI = RDI + 1
; DESTR: [register 1], RDI
;--------------------------------------------------
%macro out_char 1
    mov [rdi], %1
    inc rdi
    cmp %1, 0x0A; '\n' character
    jne %%SkipFlush
    cmp rdi, PrintBufferEnd
    jne %%SkipFlush
        flush_pb
    %%SkipFlush:
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Read an argument to the specified buffer (and shift RBP to the next position)
;--------------------------------------------------
; IN:    [register]
;        RBP = pointer to the argument
; OUT:   [register] = argument value
; DESTR: [register]
;--------------------------------------------------
%macro read_argument 1
    mov %1, [rbp]
    add rbp, 8
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Print string at the register
;--------------------------------------------------
; IN:    [register 1] = ptr to the start of the string
; OUT:   message in the print buffer (or on the screen)
; DESTR: [register 1] DL
;--------------------------------------------------
%macro print_string 1
    %%StrPrintLoopBgn:
        mov dl, [%1]
        cmp dl, 0
        je %%StrPrintLoopEnd

        out_char dl
        inc %1

        jmp %%StrPrintLoopBgn
    %%StrPrintLoopEnd:
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Print the number in binary form
;--------------------------------------------------
; IN:    RAX = number to print
; OUT:   message in the print buffer (or on the screen)
; DESTR: RAX RBX RCX RDX
;--------------------------------------------------
%macro print_binary 0
    mov rcx, 8 * 8 - 1
    mov rdx, 1
    shl rdx, cl
    %%ZeroDeletionBgn:
        cmp cl, -1; If we have reached the end, stop.
        jne %%ContinueZeroAnalisis
            add cl, '0'
            out_char cl; If the number is equal to zero, print it ('0' char)
            jmp %%LoopEnd
        %%ContinueZeroAnalisis:
        
        mov rbx, rax
        and rbx, rdx; RBX = bit at the position (shl RCX)

        cmp rbx, 0; If RBX is not zero, proceed to printing
        jne %%ZeroDeletionEnd

        shr rdx, 1
        dec rcx
        jmp %%ZeroDeletionBgn
    %%ZeroDeletionEnd:

    %%LoopBgn:
        cmp cl, -1
        je %%LoopEnd

        mov rbx, rax
        and rbx, rdx
        shr rbx, cl; RBX = bit at the position

        add rbx, '0'
        out_char bl; Print character corresponding to the given bit

        shr rdx, 1
        dec rcx
        jmp %%LoopBgn
    %%LoopEnd:
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Print the number in octo form
;--------------------------------------------------
; IN:    RAX = number to print
; OUT:   message in the print buffer (or on the screen)
; DESTR: RAX RBX RCX RDX
;--------------------------------------------------
%macro print_octo 0
    mov rcx, 8 * 8 - 4
    mov rdx, 0x07
    shl rdx, cl
    %%ZeroDeletionBgn:
        cmp cl, -3; If we have reached the end, stop.
        jne %%ContinueZeroAnalisis
            add cl, '0'
            out_char cl; If the number is equal to zero, print it ('0' char)
            jmp %%LoopEnd
        %%ContinueZeroAnalisis:
        
        mov rbx, rax
        and rbx, rdx; RBX = digit at the position

        cmp rbx, 0; If RBX is not zero, proceed to printing
        jne %%ZeroDeletionEnd

        shr rdx, 3
        sub rcx, 3
        jmp %%ZeroDeletionBgn
    %%ZeroDeletionEnd:

    %%LoopBgn:
        cmp cl, -3
        je %%LoopEnd

        mov rbx, rax
        and rbx, rdx
        shr rbx, cl; RBX = digit at the position

        add rbx, '0'
        out_char bl; Print character corresponding to the given digit

        shr rdx, 3
        sub rcx, 3
        jmp %%LoopBgn
    %%LoopEnd:
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Print the number in hex form
;--------------------------------------------------
; IN:    RAX = number to print
; OUT:   message in the print buffer (or on the screen)
; DESTR: RAX RBX RCX RDX
;--------------------------------------------------
%macro print_hex 0
    mov rcx, 8 * 8 - 4
    mov rdx, 0x0F
    shl rdx, cl
    %%ZeroDeletionBgn:
        cmp cl, -4; If we have reached the end, stop.
        jne %%ContinueZeroAnalisis
            add cl, '0'
            out_char cl; If the number is equal to zero, print it ('0' char)
            jmp %%LoopEnd
        %%ContinueZeroAnalisis:
        
        mov rbx, rax
        and rbx, rdx; RBX = digit at the position

        cmp rbx, 0; If RBX is not zero, proceed to printing
        jne %%ZeroDeletionEnd

        shr rdx, 4
        sub rcx, 4
        jmp %%ZeroDeletionBgn
    %%ZeroDeletionEnd:

    %%LoopBgn:
        cmp cl, -4
        je %%LoopEnd

        mov rbx, rax
        and rbx, rdx
        shr rbx, cl; RBX = digit at the position

        mov rbx, [DigitTable + rbx]
        out_char bl; Print character corresponding to the given digit

        shr rdx, 4
        sub rcx, 4
        jmp %%LoopBgn
    %%LoopEnd:
%endmacro
;--------------------------------------------------/

;--------------------------------------------------\
; Print the number in decimal form
;--------------------------------------------------
; IN:    RAX = number to print
; OUT:   message in the print buffer (or on the screen)
; DESTR: RAX RBX RCX RDX
;--------------------------------------------------
%macro print_decimal 0
    cmp rax, 0; If number is zero, print single '0' character and exit
    jne %%SkipZero
        add al, '0'
        out_char al
        jmp %%RetraceLoopEnd
    %%SkipZero:

    mov cl, 10; We will be dividing by 10 constantly...

    xor rbx, rbx
    %%ReadLoopBgn:
        cmp rax, 0
        je %%ReadLoopEnd

        push rax
        div cl; Round RAX to be divided by 10
        mul cl
        pop rdx; Put the original value of RAX to RDX

        sub rdx, rax; RDX = (original) RAX % 10
        add rdx, '0'
        mov [DigitBuffer + rbx], dl; Put digit to middle-stage buffer (they will need to be inverted later)

        div cl; Prepare RAX for the next loop pass by dividing it by 10
        inc rbx; Shift digit buffer cell

        jmp %%ReadLoopBgn
    %%ReadLoopEnd:

    %%RetraceLoopBgn:
        dec rbx
        
        mov dl, [DigitBuffer + rbx]
        out_char dl; Copy digit from digit buffer to print buffer

        cmp rbx, 0
        je %%RetraceLoopEnd

        jmp %%RetraceLoopBgn
    %%RetraceLoopEnd:
%endmacro
;--------------------------------------------------/
