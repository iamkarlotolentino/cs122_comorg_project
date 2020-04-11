
validate_acct PROC
                    ; output:
                    ; AH={1} if valid or {0} when not
                    set_videopage  7
                    ; ensure correct length of input
                    cmp            in_card_no[1], 16d
                    jne            str_invalid
                    cmp            in_pin_code[1], 6d
                    jne            str_invalid
                    ; validate if input is a series of digit
                    validate       [in_card_no+2], 16d
                    cmp            al, 1
                    jne            str_invalid
                    validate       [in_pin_code+2], 06d
                    cmp            al, 1
                    jne            str_invalid
                    ; compare card_no
                    lea            si, ff_card_no
                    lea            di, [in_card_no+2]
                    mov            cx, 0010h
                    mov            al, [si]
                    mov            bl, [di]
                    cmp            al, bl
                    jne            str_notequal
                    repe cmpsb
                    jne            str_notequal
                    ; compare pin_code
                    lea            si, ff_pin_code
                    lea            di, [in_pin_code+2]
                    mov            cx, 0006h
                    mov            al, [si]
                    mov            bl, [di]
                    cmp            al, bl
                    jne            str_notequal
                    repe cmpsb
                    jne            str_notequal
                    set_videopage  0
                    mov            ah, 1
                    ret
    str_notequal:
                    alert          10, 10, err_incorrect
                    call           delay
                    set_videopage  0
                    mov            ah, 0
                    ret
    str_invalid:
                    alert          10, 10, err_blank
                    call           delay
                    set_videopage  0
                    mov            ah, 0
                    ret
validate_acct ENDP