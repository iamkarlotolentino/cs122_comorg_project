
; ---
; Changes the cursor position
cursor_at MACRO row, column, page
            mov           dh, row
            mov           dl, column
            mov           bh, page
            mov           ah, 2
            int           10h
cursor_at ENDM

; ---
; Reads string
reads MACRO buffer, len
            LOCAL         rd_size, rd_read, rd_back, rd_cont
            pusha
            ; show standard blinking text cursor
            mov           ch, 06h
            mov           cl, 07h
            mov           ah, 01h
            int           10h
            ; read string, char by char
            ; setup the loop
            xor           cx, cx
            xor           bx, bx
            mov           cx, len
            mov           bx, 0
rd_read:
            ; read character
            mov           ah, 1
            int           21h
            ; check if not backspace
            cmp           al, 08h
            je            rd_back
            ; check if enter
            cmp           al, 0Dh
            je            rd_cont
            ; if valid, then store character
            mov           buffer[bx], al
            inc           bx
            loop          rd_read
            jmp           rd_cont
rd_back:
            ; recover the lost count
            add           cx, 0002h
            loop          rd_read
rd_cont:
            ; add string terminator
            mov           buffer[bx], '$'
            ; hide blinking cursor
            mov           ch, 20h
            mov           ah, 01h
            int           10h
            popa
reads ENDM

; ---
; String printing at current cursor position
prints MACRO row, col, page, msg
            pusha
            ; cursor _at
            mov           dh, row
            mov           dl, col
            mov           bh, page
            mov           ah, 2
            int           10h
            ; prints string
            mov           dx, offset msg
            mov           ah, 9
            int           21h
            popa
prints ENDM

; ---
; Character position at current cursor position
printc MACRO row, col, page, char
            pusha
            ; cursor _at
            mov           dh, row
            mov           dl, col
            mov           bh, page
            mov           ah, 2
            int           10h
            ; print char
            mov           al, char
            mov           cx, 0001h
            mov           bh, page
            mov           ah, 0Ah
            int           10h
            popa
printc ENDM

; ---
; Prints character at current cursor position with multiple times
printr MACRO row, col, page, sym, count
            pusha
            ; cursor _at
            mov           dh, row
            mov           dl, col
            mov           bh, page
            mov           ah, 2
            int           10h

            xor           cx, cx
            mov           cl, count
            mov           bh, page
            mov           bl, 1Eh
            mov           al, sym
            mov           ah, 09h
            int           10h
            popa
printr ENDM

; ---
; Validates input if it is a series of digit numbers.
; [output]
; al=1 if account is valid
; al=0 if account is not valid
validate MACRO input, count
            LOCAL vdt_loop, vdt_error, vdt_exit
            xor           cx, cx
            mov           cl, count
            xor           bx, bx
            mov           bl, count-1
vdt_loop:
            cmp           input[bx], 0030h
            jl            vdt_error
            cmp           input[bx], 0039h
            jg            vdt_error
            dec           bx
            loop          vdt_loop
            mov           al, 1
            jmp           vdt_exit
vdt_error:
            mov           al, 0
vdt_exit:
validate ENDM
