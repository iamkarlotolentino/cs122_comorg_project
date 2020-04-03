
;**************************************************************************;
;------------------------------   MACRO   --------------------------------;
;**************************************************************************;

; set cursor position
cursor_at MACRO row,column
    mov           dh, row
    mov           dl, column
    mov           bh, 0
    mov           ah, 2
    int           10h
ENDM

; string scanner
reads MACRO buffer
    mov           ch, 06h
    mov           cl, 07h
    mov           ah, 01h
    int           10h
    lea           dx, buffer
	mov           ah, 0ah
	int           21h
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
    LOCAL l
    mov           cl, count
l:  printc        sym
    loop          l
ENDM

alert MACRO msg
    call          cls
    prints        msg
ENDM

; passes the new pin
update_pin MACRO new_pin
    
ENDM

update_balance MACRO new_balance

ENDM

; reads character, act as a pause
pause MACRO
    mov           ah, 1
    int           21h
ENDM