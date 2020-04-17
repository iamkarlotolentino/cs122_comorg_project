
validate_account MACRO
     LOCAL str_invalid, str_notequal
                    ; output:
                    ; AH={1} if valid or {0} when not
                    ; validate if input is a series of digit
                    validate       [in_card_no]
                    cmp            al, 1
                    jne            str_invalid
                    validate       [in_pin_code]
                    cmp            al, 1
                    jne            str_invalid
                    ; compare card_no
                    lea            si, fbuffer
                    lea            di, [in_card_no]
                    mov            cx, 0010h
                    mov            al, [si]
                    mov            bl, [di]
                    cmp            al, bl
                    jne            str_notequal
                    repe cmpsb
                    jne            str_notequal
                    ; compare pin_code
                    ; pin_code data is in the next 2 bytes
                    add            si, 2d
                    lea            di, [in_pin_code]
                    mov            cx, 0006h
                    mov            al, [si]
                    mov            bl, [di]
                    cmp            al, bl
                    jne            str_notequal
                    repe cmpsb
                    jne            str_notequal
                    mov            ah, 1
                    jmp            str_exit
     str_invalid:
                    alert          10, 10, err_invalid
                    mov            ah, 0
                    jmp            str_exit
     str_notequal:
                    mov            ah, 0
     str_exit:
validate_account ENDM