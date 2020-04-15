; This source file contains the following:
; 1. cursor at MACRO
; 2. reads MACRO
; 3. prints MACRO 
; 4. printc MACRO
; 5. printr MACRO
; 6. validate MACRO
; 7. clean input MACRO

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
            popa
            xor           cx, cx
            xor           bx, bx
            mov           cx, len
            mov           bx, 0
            pusha
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
            dec           bx
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
; al=1 if input is valid
; al=0 if input is not valid
validate MACRO input
            LOCAL vdt_loop, vdt_good, vdt_error, vdt_exit
            mov           bx, 0000h
vdt_loop:
            ; check if not yet end of string
            cmp           input[bx], '$'
            je            vdt_good
            ; check if digit
            cmp           input[bx], 0030h
            jl            vdt_error
            cmp           input[bx], 0039h
            jg            vdt_error
            inc           bx
            jmp           vdt_loop
vdt_good:
            mov           al, 1
            jmp           vdt_exit
vdt_error:
            mov           al, 0
vdt_exit:
validate ENDM

; ---
; Cleans the _input by shifting all digits to the right
clean_input MACRO strlen
            LOCAL         cln_len, cln_set, cln_g, cln_h, cln_exit
            ; get string length
            lea           si, _input-1
            mov           bx, -1h
cln_len:
            inc           bx
            inc           si
            cmp           [si], '$'
            jne           cln_len
            ;bx=input length
            ; if complete then no need
            cmp           bx, strlen
            je            cln_exit
            ; to retain for another loop
            push          bx
            ; if not complete then set blanks to '0'
            ; setup the loop
            xor           cx, cx
            mov           cx, strlen
            ; points to start
            mov           si, offset _input
            ; points to last
            mov           di, offset _input
            add           di, strlen
cln_set:
            ; transfer the data to correct position
            ; decrease bx
            cmp           bx, 0
            je            cln_g
            ; handling input first
            sub           di, bx
            mov           al, [si]
            mov           [di], al
            add           di, bx
            inc           si
            dec           bx
            loop          cln_set
cln_g:
            pop           bx
            sub           di, bx
            dec           di
cln_h:
            ; handling zeros
            mov           [di], '0'
            dec           di
            loop          cln_h
cln_exit:
clean_input ENDM
