
;**************************************************************************;
;-------------------------------   MACRO   --------------------------------;
;**************************************************************************;

; set cursor position
cursor_at MACRO row, column, page
            mov           dh, row
            mov           dl, column
            mov           bh, page
            mov           ah, 2
            int           10h
cursor_at ENDM

; string scanner
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

; string printing
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

; char printing
printc MACRO row, col, page, char
            pusha
            ; cursor _at
            mov           dh, row
            mov           dl, col
            mov           bh, page
            mov           ah, 2
            int           10h
            ; char
            mov           al, char
            mov           cx, 0001h
            mov           bh, page
            mov           ah, 0Ah
            int           10h
            popa
printc ENDM

; repeated char printing
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

alert MACRO msg
            set_videopage 6
            call          cls
            prints        0, 0, 0, msg
alert ENDM

withdrawable MACRO amount, balance

withdrawable ENDM

; passes the new pin
update_pin MACRO new_pin
            LOCAL         _loop
            ; update fbuffer before writing to file
            lea           si, new_pin[2]
            lea           di, fbuffer[20]
            xor           cx, cx
            mov           cx, 0006h
_loop:
            mov           al, [si]
            mov           [di], al
            inc           si
            inc           di
            loop          _loop
            ; seek file position
            mov           bx, fhandle
            mov           cx, 0000h
            mov           dx, 0000h
            mov           al, 00h
            mov           ah, 42h
            int           21h
            ; write to file
            mov           bx, fhandle
            mov           dx, offset fbuffer
            mov           cx, 40d
            mov           ah, 40h
            int           21h
update_pin ENDM

update_balance MACRO new_balance

update_balance ENDM

; select active video page
set_videopage MACRO pageno
            mov           al, pageno
            mov           ah, 05h
            int           10h
set_videopage ENDM