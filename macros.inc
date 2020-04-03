
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
    pusha
    mov           ch, 6
    mov           cl, 7
    mov           ah, 1
    int           10h
    lea           dx, buffer
	mov           ah, 0ah
	int           21h
	xor           bx, bx
	mov           bl, buffer[1]
	mov           buffer[bx+2], '$'
	lea           dx, buffer + 2
	mov           ch, 32
	mov           ah, 1
	int           10h
	popa
ENDM

; string printing
prints MACRO msg
    pusha
    mov           dx, offset msg
    mov           ah, 9
    int           21h
    popa
ENDM

; char printing
printc MACRO char
    pusha
    mov           dl, char
    mov           ah, 2
    int           21h
    popa
ENDM

; repeated char printing
printr MACRO sym, count
    LOCAL l
    pusha
    mov           cl, count
    l: printc sym
    loop          l
    popa
ENDM

alert MACRO msg
    pusha
    call          cls
    prints        msg
    popa
ENDM

; reads character, act as a pause
pause MACRO
    mov           ah, 1
    int           21h
ENDM