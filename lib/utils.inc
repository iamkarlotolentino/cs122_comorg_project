; This source file contains the following:
; 1. delay PROC
; 2. get mouse position PROC
; 3. get time PROC
; 4. to ascii PROC
; 5. clear screen MACRO
; 6. set video page MACRO
; 7. alert MACRO

; ---
; Creates one second delay of the program
delay PROC
                    mov            al, 00h
                    mov            cx, 0Fh
                    mov            dx, 4240h
                    mov            ah, 86h
                    int            15h
                    ret
ENDP

; ---
; Updates the registers on the current mouse status
whereis_mouse PROC
                    mov            ax, 03h
                    int            33h
                    ret
ENDP

; ---
; Exits the program and return to operating system
sys_exit PROC
                    alert          11, 11, msg_exit
                    ; DOS Exit
                    mov            ah, 4ch
                    int            21h
                    ret
sys_exit ENDP            

; ---
; System interrupt to get the current time
get_time PROC 
                    ; input  : BX=offset address of the string TIME
                    ; output : BX=current time
                    ; get current system time
                    mov            ah, 2ch
                    int            21h
                    
                    ; ch=hours
                    mov            al, ch
                    call           to_ascii
                    mov            [bx], ax
                    
                    ; cl=minutes
                    mov            al, cl
                    call           to_ascii
                    mov            [bx+3], ax
                    ; dh=seconds
                    mov            al, dh
                    call           to_ascii
                    mov            [bx+6], ax
                    ret
get_time ENDP 

; ---
; Converts the input into ascii value
to_ascii PROC
                    ; input  : AL=binary code
                    ; output : AX=ASCII code
                    mov            ah, 00h
                    mov            dl, 10d
                    div            dl
                    or             ax, 3030H
                    ret
to_ascii ENDP

; ---
; Clears the screen with background blue and foreground yellow.
clear_screen MACRO
                    pusha
                    xor            al, al
                    xor            cx, cx 
                    mov            dx, 184fh
                    mov            bh, 1eh      
                    mov            ah, 06h
                    int            10h
                    popa 
clear_screen ENDM

; ---
; Changes the active video page to given parameter
set_videopage MACRO pageno
            ; set active video page
            mov           al, pageno
            mov           ah, 05h
            int           10h
            ; update tracker to current page
            mov           pgf__current, pageno
set_videopage ENDM

; ---
; Prints message treated as an alert
alert MACRO c, r, msg
            set_videopage 6
            mov           ah, r
            mov           al, c
            prints        ah, al, 6, msg
            call          delay
            ; clear_screen (new color)
            xor            al, al
            xor            cx, cx 
            mov            dx, 184fh
            mov            bh, 00B4h      
            mov            ah, 06h
            int            10h
alert ENDM
