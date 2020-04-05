
;**************************************************************************;
;-------------------------------   MACRO   --------------------------------;
;**************************************************************************;

; set cursor position
cursor_at MACRO row,column, page
            mov           dh, row
            mov           dl, column
            mov           bh, page
            mov           ah, 2
            int           10h
ENDM

; string scanner
reads MACRO buffer
            ; show cursor
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
            mov           ch, 32h
            mov           ah, 01h
            int           10h
ENDM

; string printing
prints MACRO msg
            mov           dx, offset msg
            mov           ah, 9
            int           21h
ENDM

; char printing
printc MACRO char
            mov           dl, char
            mov           ah, 2
            int           21h
ENDM

; repeated char printing
printr MACRO sym, count
            LOCAL         l
            mov           ch, 00h
            mov           cl, count
l:          printc        sym
            loop          l
ENDM

alert MACRO msg
            set_videopage 6
            call          cls
            prints        msg
ENDM

withdrawable MACRO amount, balance
ENDM

; passes the new pin
update_pin MACRO new_pin
    
ENDM

update_balance MACRO new_balance

ENDM

; select active video page
set_videopage MACRO pageno
            mov           al, pageno
            mov           ah, 05h
            int           10h
ENDM