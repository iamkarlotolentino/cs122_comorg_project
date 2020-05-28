
pg_balance PROC
                    set_videopage  4
                    cmp            pgf_balance, 1
                    je             blnc_print
    blnc:
                    clear_screen
                    prints         8, 7, 4, blnc_text
                    printr         9, 7, 4, 205d, 15
                    printc         10, 7, 4, 'P'
                    printr         11, 7, 4, 205d, 15
                    prints         18, 7, 4, blnc_frm_sel[0]

                    ; the page has been loaded
                    mov            pgf_balance, 1
    blnc_print:
                    ; reset balance printing
                    prints         10, 9, 4, ff_balance
    blnc_listen:
                    ; update mouse position
                    call           whereis_mouse
                    cmp            bx, 1
                    jne            blnc_listen

                    ; Go Back
                    cmp            dx, 0090h
                    jl             blnc_listen
                    cmp            dx, 0098h
                    jg             blnc_listen
                    cmp            cx, 0038h
                    jl             blnc_listen
                    cmp            cx, 0077h
                    jg             blnc_listen
                    ; BACK PROCESS
                    ret
                    ; ENDPRC
pg_balance ENDP