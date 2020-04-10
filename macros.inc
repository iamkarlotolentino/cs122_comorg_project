
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

alert MACRO c, r, msg
            set_videopage 6
            call          cls
            mov           ah, r
            mov           al, c
            prints        ah, al, 6, msg
alert ENDM

; OF is 1 if negative value
withdrawable MACRO amount, balance
            LOCAL wbl_next
            ; setup the loop
            mov           cx, 12d
            mov           bx, 11d
wbl_next:
            ; subtract digit
            mov           al, balance[bx]
            sbb           al, amount[bx+2]
            aas
            ; store result
            mov           _comp[bx], al
            dec           bx
            loop          wbl_next
withdrawable ENDM

depositable MACRO amount, balance
            LOCAL dbl_next
            ; setup the loop
            mov           cx, 12d
            mov           bx, 11d
dbl_next:
            ; subtract digit
            mov           al, balance[bx]
            adc           al, amount[bx+2]
            aaa
            ; store result
            mov           _comp[bx], al
            dec           bx
            loop          dbl_next
            adc           _comp[bx], 0
depositable ENDM

set_balance MACRO new_balance
            LOCAL         upb_next
            ; setup the loop
            mov           cx, 12d
            mov           bx, 11d
upb_next:
            ; write the digit to ff_balance
            or            new_balance[bx], 30h
            mov           al, new_balance[bx]
            mov           ff_balance[bx], al
            ; update fbuffer before writing to file
            mov           fbuffer[bx+25], al
            dec           bx
            loop          upb_next
            ; update balance in account database
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
set_balance ENDM

; passes the new pin
update_pin MACRO new_pin
            LOCAL         upi_loop
            ; update fbuffer before writing to file
            lea           si, new_pin[2]
            lea           di, fbuffer[18]
            xor           cx, cx
            mov           cl, 06h
upi_loop:
            mov           al, [si]
            mov           [di], al
            inc           si
            inc           di
            loop          upi_loop
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

; al = 1 if input is valid, otherwise 0
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

; select active video page
set_videopage MACRO pageno
            mov           al, pageno
            mov           ah, 05h
            int           10h
set_videopage ENDM