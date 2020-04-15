
load_account MACRO filename
                    ; load account details
                    ; open file
                    mov            al, 02h
                    mov            dx, offset filename
                    mov            ah, 3Dh
                    int            21h
                    jc             fileerr
                    mov            fhandle, ax
                    
                    ; read file
                    mov            bx, fhandle
                    mov            cx, 28h
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