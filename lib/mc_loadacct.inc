; This source file contains code instruction for reading file.
; This file contains the credentials of the person's account.

load_account MACRO
     LOCAL fileerr, lct_continue
                    ; load account details
                    ; open file
                    mov            al, 02h
                    mov            dx, offset fname
                    mov            ah, 3Dh
                    int            21h
                    jc             fileerr
                    mov            fhandle, ax
                    ; read file
                    mov            bx, fhandle
                    mov            cx, 26h
                    lea            dx, fbuffer
                    mov            ah, 3Fh
                    int            21h
                    ; parse current balance
                    lea            si, fbuffer
                    add            si, 25d             ; offset from card_no to balance
                    lea            di, ff_balance
                    mov            cx, 000Ch
                    inc            si
                    cld
                    rep
                    movsb
                    ; close file
                    mov            bx, fhandle   
                    mov            ah, 3Eh
                    jmp            lct_continue
    fileerr:
                    prints         0, 0, 0, err_file404
                    call           sys_exit
    lct_continue:
load_account ENDM