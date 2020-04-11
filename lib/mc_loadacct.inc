
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
                    
                    ; parse data
                    ; first 16 bytes is acc't no.
                    lea            si, [fbuffer-1]
                    lea            di, ff_card_no
                    mov            cx, 0010h
                    inc            si
                    cld
                    rep
                    movsb
                    ; next 6 bytes is pin code
                    inc            si
                    lea            di, ff_pin_code
                    mov            cx, 0006h
                    inc            si
                    cld
                    rep
                    movsb
                    ; next 12 bytes is current balance
                    inc            si
                    lea            di, ff_balance
                    mov            cx, 000Ch
                    inc            si
                    cld
                    rep
                    movsb
                    ; close file
                    mov            ah, 3Eh
                    mov            bx, fhandle   
                    jmp            lct_continue
    fileerr:
                    prints         0, 0, 0, err_file404
                    call           sys_exit
    lct_continue:
load_account ENDM