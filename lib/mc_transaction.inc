
; ---
; Raises flag to evaluate if withdraw is possible
; [output]
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

; ---
; Raises flag to evaluate if deposit is possible
; [output]
; Overflow flag is 1 if more than length
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

; ---
; Writes balance into the variable and account file
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

; ---
;  Writes to account file the new account pin code
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
