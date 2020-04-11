
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
reads MACRO buffer
            pusha
            ; show standard blinking text cursor
            mov           ch, 06h
            mov           cl, 07h
            mov           ah, 01h
            int           10h
            ; read string
            lea           dx, buffer
            mov           ah, 0ah
            int           21h
            ; add terminate character
            xor           bx, bx
            mov           bl, buffer[1]
            mov           buffer[bx+2], '$'
            lea           dx, buffer + 2
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
; Prints message treated as an alert
alert MACRO c, r, msg
            set_videopage 6
            clear_screen
            mov           ah, r
            mov           al, c
            prints        ah, al, 6, msg
alert ENDM