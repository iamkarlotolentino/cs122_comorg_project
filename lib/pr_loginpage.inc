
pg_login PROC
                    set_videopage  0
                    ; check if page has been loaded
                    cmp            pgf_login, 1
                    je             keep_listening
                    clear_screen
                    ; selection form printing
                    printc         3,  2, 0, 201d
                    printr         3,  3, 0, 205d, 34
                    printc         3, 37, 0, 187d
                    
                    printc         4,  2, 0, 186d
                    printc         4, 37, 0, 186d
                    prints         4,  4, 0, login_accnt
                    
                    printc         5,  2, 0, 186d
                    printc         5, 37, 0, 186d
                    prints         5,  4, 0, login_desc
                    
                    printc         6,  2, 0, 200d
                    printr         6,  3, 0, 205d, 34
                    printc         6, 37, 0, 188d
                     
                    printc         8,  2, 0, 201d
                    printr         8,  3, 0, 205d, 12
                    printc         8, 15, 0, 203d
                    printr         8, 16, 0, 205d, 21
                    printc         8, 37, 0, 187d
                    
                    printc         9,  2, 0, 186d
                    printc         9, 15, 0, 186d
                    printc         9, 37, 0, 186d
                    prints         9,  4, 0, login_frm_text[0]
                    
                    printc         10,  2, 0, 204d
                    printr         10,  3, 0, 205d, 12
                    printc         10, 15, 0, 206d
                    printr         10, 16, 0, 205d, 21
                    printc         10, 37, 0, 185d

                    printc         11,  2, 0, 186d
                    prints         11,  4, 0, login_frm_text[9]
                    printc         11, 15, 0, 186d
                    printc         11, 37, 0, 186d
                    
                    printc         12,  2, 0, 200d
                    printr         12,  3, 0, 205d, 12
                    printc         12, 15, 0, 202d
                    printr         12, 16, 0, 205d, 21
                    printc         12, 37, 0, 188d
                    
                    prints         14,  6, 0, login_frm_sel[0]
                    prints         14, 18, 0, login_frm_sel[7]

                    prints         23,  2, 0, msg_copyright

                    ; flag the page it has been loaded
                    mov            pgf_login, 1

    ; listens to mouse-pos
    keep_listening:
                    ; get mouse state
                    call           whereis_mouse
                    ; left button click
                    cmp            bx, 01h
                    jne            keep_listening
                    ; passes when left button is pressed
                    
                    ; form-selected detection
                    cmp            cx, 0080h
                    jnge           menu_selection
                    cmp            cx, 0126H
                    jnle           menu_selection
    card_no:
                    cmp            dx, 0050h
                    jnle           pin_code
                    cmp            dx, 0048h
                    jnge           menu_selection
                    cursor_at      9, 16, 0
                    reads          in_card_no, 16
    pin_code:
                    cmp            dx, 005Eh
                    jnle           menu_selection
                    cmp            dx, 0059h
                    jnge           menu_selection
                    cursor_at      11, 16, 0
                    reads          in_pin_code, 6
                    ; ok&cancel menu detection 
    menu_selection:
                    cmp            dx, 006Eh
                    jnge           keep_listening
                    cmp            dx, 0075h
                    jnle           keep_listening
    cancel_button:
                    cmp            cx, 0090h
                    jnge           ok_button
                    cmp            cx, 00DFh
                    jnle           keep_listening
                    call           sys_exit
    ok_button:
                    cmp            cx, 0030h
                    jnge           keep_listening
                    cmp            cx, 005Fh
                    jnle           keep_listening
                    ; returns to check credibility
                    ret
pg_login ENDP