; This source file is a page view where it contains special menus that
; is accessed after login.


pg_menu PROC
    menu_start:
                    set_videopage  1
                    ; check if page has been loaded
                    cmp            pgf_menu, 1
                    je             render_loop
                    clear_screen

                    ; al=row start
                    mov bl,        07h
                    mov cl,        03h
                    ; print the selection box
    create_block:
                    ; creates block
                    prints         bl,  2, 1, menu_hdr
                    prints         bl, 20, 1, menu_hdr
                    inc            bl
                    printc         bl,  2, 1, 186d
                    printc         bl, 18, 1, 186d
                    printc         bl, 20, 1, 186d
                    printc         bl, 36, 1, 186d
                    inc            bl
                    prints         bl,  2, 1, menu_frm_ftr
                    prints         bl, 20, 1, menu_frm_ftr
                    add            bl, 2
                    loop           create_block
        
                    ; withdraw-text
                    prints         8,  6, 1, menu_frm_text[0]
                    ; deposit-text
                    prints         8, 25, 1, menu_frm_text[9]
                    ; balance-text
                    prints         12,  7, 1, menu_frm_text[17]
                    ; reset-pin text
                    prints         12, 24, 1, menu_frm_text[25]
                    ; log-out text
                    prints         16,  7, 1, menu_frm_text[35]
                    ; details text
                    prints         16, 27, 1, menu_frm_text[43]
    
                    ; prints time (text) 
                    prints         4, 2, 1, time

                    ; mark the page has been loaded
                    mov            pgf_menu, 1
    render_loop:
                    cmp            pgf__current, 1
                    je             active_page
                    set_videopage  1
    active_page:
                    ; time printing
                    lea            bx,timestamp
                    call           get_time
                    prints         2, 2, 1, login_desc
                    prints         4, 8, 1, timestamp
                    
                    call           whereis_mouse
                    cmp            bx, 0001h
                    jne            render_loop
    col_1:
                    ; checks if mouse coor is in first column
                    cmp            cx, 0018h
                    jl             render_loop
                    ; if not, check if it is in second column
                    cmp            cx, 008Fh
                    jg             col_2
    btn_withdraw:
                    cmp            dx, 0040h
                    jl             render_loop
                    cmp            dx, 0047h
                    jg             btn_balance
                    ; PROCESS: withdraw
                    mov            al, 0Ch        ; 0Ch=12d
                    call           pg_input
                    clean_input    12d
                    ; show please wait
                    set_videopage  7
                    withdrawable   _input, ff_balance
                    jc             trans_error
                    set_balance    _comp
                    alert          15, 10, msg_success
                    ; ENDPRC
                    ; go back to menu
                    jmp            render_loop
    btn_balance:
                    cmp            dx, 0060h
                    jl             render_loop
                    cmp            dx, 0067h
                    jg             btn_logout
                    ; PROCESS: balance
                    call           pg_balance
                    ; ENDPRC
                    jmp            render_loop
    btn_logout:
                    cmp            dx, 0080h
                    jl             render_loop
                    cmp            dx, 0087h
                    jg             render_loop
                    ; PROCESS: logout
                    ; sets all significant data to invalid state
                    mov            in_card_no[2], '$'
                    mov            in_pin_code[2], '$'
                    ; ENDPRC
                    ; returns to main PROC
                    ret
    col_2:
    btn_deposit:
                    cmp            dx, 0040h
                    jl             render_loop
                    cmp            dx, 0047h
                    jg             btn_reset_pin
                    ; PROCESS: deposit
                    mov            al, 0Ch
                    call           pg_input
                    clean_input    12d
                    ; show please wait
                    set_videopage  7
                    ; checks if possible to deposit
                    depositable    _input, ff_balance
                    jc             trans_error
                    ; set the new balance
                    set_balance    _comp
                    alert          15, 10, msg_success
                    ; ENDPRC
                    ; go back to menu
                    jmp            render_loop
    btn_reset_pin:
                    cmp            dx, 0060h
                    jl             render_loop
                    cmp            dx, 0067h
                    jg             render_loop
                    ; PROCESS: reset pin
                    ; get the new pin
                    mov            al, 06h
                    call           pg_input
                    ; check if exact 6 digits
                    ; setup string counting
                    mov            bx, 0000h
    rsp_str:
                    inc            bx
                    cmp            _input[bx], '$'
                    jne            rsp_str
                    ; should be 6 digits
                    cmp            bx, 0006d
                    jne            trans_error
                    update_pin     _input
                    alert          15, 10, msg_success
                    ; ENDPRC
                    jmp            menu_start

                    ; return to mouse listen
                    jmp            render_loop
    trans_error:
                    alert          11, 13, err_invalid
                    jmp            render_loop
pg_menu ENDP