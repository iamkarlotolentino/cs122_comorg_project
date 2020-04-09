
INCLUDE 'macros.inc'

TITLE "Bank Account Manager"

.MODEL small
.STACK 125h
.DATA
    blnc_printer1   db  "-------- BANK ACCOUNT --------", "$"
    blnc_printer2   db  0dh, 0ah, "Acc't No. : ", "$"
    blnc_printer3   db  0dh, 0ah, "Balance   : ", "$"
    blnc_printer4   db  "------------------------------", "$"

    ; Accounts flags and details
    acct_login      db   0                              ; {1} = account is active
    ff_card_no      db  16 dup(' '), '$'                ; card no from the account file
    ff_pin_code     db   7 dup(' '), '$'                ; pin code from the account file
    ff_balance      db  12 dup(' '), '$'                ; balance from the account file
    
    ; File handling of the account file
    fname           db  "account.txt", 0
    fhandle         dw  ?
    fbuffer         db  40 dup(?)
    
    new_pin_code    db   7, ?,  7 dup('$')
    
    _input          db  13, ?, 13 dup('$')

    ; Flags to check if page has been loaded
    PAGE_LOGIN      db 0
    PAGE_MENU       db 0
    PAGE_INPUT      db 0
    PAGE_RESET      db 0
    PAGE_BALANCE    db 0
    PAGE_ALERT      db 0
    PAGE_WAIT       db 0
    
    time            db  "Time:$"
    timestamp       db  "00:00:00$"

    login_accnt     db "Welcome, JC!$"
    login_desc      db "Your personal bank acc't manager$"
    login_frm_text  db "CARD NO.$", "PIN CODE$" 
    login_frm_sel   db "[ OK ]$", "[ CANCEL ]$"
    
    ; Input of account details, used in login page
    input_text      db  "ENTER INPUT$"
    in_card_no      db  17, ?, 17 dup('$')
    in_pin_code     db   7, ?,  7 dup('$')

    menu_frm_text   db  "Withdraw$", "Deposit$", "Balance$", "Reset PIN$", "Log Out$", "Details$"
    menu_hdr        db  201d, 15 dup(205d), 187d, '$'
    menu_frm_ftr    db  200d, 15 dup(205d), 188d, '$'

    blnc_text       db  "Your balance$"
    blnc_frm_sel    db  "[ BACK ]$", "[ PRINT BALANCE ]$"
    
    err_blank       db  "NOT VALID INPUT$"
    err_incorrect   db  "Incorrect! Try again.$"
    err_file404     db  "Error. Account database not found!$"

    msg_wait        db  "Please wait$"
    msg_exit        db "Thank you. Goodbye!$"
    msg_copyright   db "Teller Machine @ 2020 ", 179d, " v1.0$"
.CODE
;---------------------- MAIN PROC -------------------------;
main PROC
                    ; initialize all proper data and setup
                    call           setup
    login:
                    call           account
                    call           login_page
                    ; evaluate if the input is valid
                    ; pin-code not empty
                    cmp            in_pin_code[2], '$'
                    je             login_error
                    ; card-no not empty
                    cmp            in_card_no[2], '$'
                    je             login_error
                    ; validate acccount
                    call           validate_acct
                    cmp            acct_login, 01h
                    jne            login
                    ; load please wait
                    set_videopage  7
                    cmp            PAGE_WAIT, 1
                    je             please_wait
                    call           cls
                    prints         11, 15, 7, msg_wait
                    mov            PAGE_WAIT, 1
    please_wait:    
                    ; removing input text in login page
                    printr         9,  16, 0, ' ', 16
                    printr         11, 16, 0, ' ', 6
                    jmp            continue
    login_error:
                    alert          9, 13, err_blank
                    call           delay
                    jmp            login
    continue:
                    call           menu_page
                    ; expected logout has been called
                    jmp            login
main ENDP

;---------------------- SETUP PROC -------------------------;
setup PROC
                    ; data segment address
                    mov            dx, @data
                    mov            ds, dx
                    mov            es, dx
    
                    ; set video mode
                    mov            al, 00h
                    mov            ah, 00h
                    int            10h
                    
                    ; disable blinking
                    mov            ax, 1003h
                    mov            bx, 00h
                    int            10h   
                       
                    ; hide text cursor:
                    mov            ch, 32h
                    mov            ah, 01h
                    int            10h
                    
                    ; initialize mouse
                    mov            ax, 00h
                    int            33h
                    
                    ; display mouse cursor:
                    mov            ax, 01h
                    int            33h
                    ret
setup ENDP

account PROC
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
                    ret 
    fileerr:
                    prints         0, 0, 0, err_file404
                    call           sys_exit
account ENDP

;---------------------- LOGIN PAGE PROC -------------------------;
login_page PROC
                    set_videopage  0
                    ; check if page has been loaded
                    cmp            PAGE_LOGIN, 1
                    je             keep_listening
                    call           cls
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

                    ; mark the page has been loaded
                    mov            PAGE_LOGIN, 1

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
                    reads          in_card_no
    pin_code:
                    cmp            dx, 005Eh
                    jnle           menu_selection
                    cmp            dx, 0059h
                    jnge           menu_selection
                    cursor_at      11, 16, 0
                    reads          in_pin_code
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
login_page ENDP

;---------------------- MENU PAGE PROC -------------------------;
menu_page PROC
    menu_start:
                    set_videopage  1
                    ; check if page has been loaded
                    cmp            PAGE_MENU, 1
                    je             render_loop
                    call           cls

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
                    prints         16, 25, 1, menu_frm_text[43]
    
                    ; prints time (text) 
                    prints         4, 2, 1, time

                    ; mark the page has been loaded
                    mov            PAGE_MENU, 1
    render_loop:
                    set_videopage  1
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
                    cmp            cx, 008Fh
                    ; if not, check if it is in second column
                    jg             col_2
    btn_withdraw:
                    cmp            dx, 0040h
                    jl             render_loop
                    cmp            dx, 0047h
                    jg             btn_balance
                    ; PROCESS: withdraw
                    ; withdraw process
                    mov            al, 0Ch
                    call           input_page
                    withdrawable   _input, ff_balance
                    ; ENDPRC
                    ; go back to menu
                    jmp            menu_start
    btn_balance:
                    cmp            dx, 0060h
                    jl             render_loop
                    cmp            dx, 0067h
                    jg             btn_logout
                    ; PROCESS: balance
                    call           balance_page
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
                    mov            acct_login[0], 00h
                    ; ENDPRC
                    ; returns to main PROC
                    ret
    col_2:
    btn_deposit:
                    cmp            dx, 0040h
                    jl             render_loop
                    cmp            dx, 0047h
                    jg             btn_reset_pin
                    printc         8, 21, 1, _sym[11]
                    jmp            render_loop
    btn_reset_pin:
                    cmp            dx, 0060h
                    jl             render_loop
                    cmp            dx, 0067h
                    jg             btn_details
                    ; PROCESS: reset pin
                    mov            al, 06h
                    call           input_page
                    update_pin     _input
                    ; TODO
                    ; ENDPRC
                    jmp            menu_start
    btn_details:
                    cmp            dx, 0080h
                    jl             render_loop
                    cmp            dx, 0087h
                    jg             render_loop
                    jmp            render_loop
                    ret
menu_page ENDP

;-------------------- INPUT PAGE PROC -----------------------;
; al = number of input
; dx = header text
input_page PROC
                    pusha
                    set_videopage  2
                    ; check if page has been loaded
                    cmp            PAGE_INPUT, 1
                    je             input_read
                    call           cls
                    printc         7,  6, 2, 201d
                    printr         7,  7, 2, 205d, 26
                    printc         7, 33, 2, 187d
                    printc         8,  6, 2, 186d
                    printc         8, 33, 2, 186d
                    printc         9,  6, 2, 186d
                    printc         9, 33, 2, 186d

                    printc         12,  6, 2, 186d
                    printc         12, 33, 2, 186d
                    printc         13,  6, 2, 200d
                    printr         13,  7, 2, 205d, 26
                    printc         13, 33, 2, 188d

                    mov            PAGE_INPUT, 1
    input_read:
                    popa

                    ; limit the no. of input
                    mov            _input[1], al

                    ; preserve the no. of input {al}
                    push           ax
                    ; 19d is the center, 2d for the [ ] symbol
                    sub            al, 38d
                    neg            al
                    ; divide by 2
                    mov            dx, 0000h
                    mov            ah, 00h
                    mov            cx, 02h
                    div            cx
                    ; cx=offset
                    mov            cl, al
                    pop            ax
                    mov            ah, cl

                    ; start printing
                    printc         11, ah, 2, '['
                    inc            ah
                    printr         11, ah, 2, '-', al
                    add            ah, al
                    printc         11, ah, 2, ']'

                    prints         9, 15, 2, input_text

                    sub            ah, al
                    cursor_at      11, ah, 2
                    reads          _input

                    ; please wait
                    set_videopage  7
                    ; should not be empty
                    cmp            _input[2], '$'
                    je             empty
                    ; clears input in video page
                    printr         11, 0, 2, ' ', 39
                    ; return to process if not empty
                    ret
    empty:
                    alert          11, 13, err_blank
                    call           delay
                    set_videopage  2
                    jmp            input_read
input_page ENDP

;----------------------- CLEAR PROC -------------------------;
cls PROC
                    pusha
                    xor            al, al
                    xor            cx, cx 
                    mov            dx, 184fh
                    mov            bh, 1eh      
                    mov            ah, 06h
                    int            10h
                    popa
                    ret    
cls ENDP

;----------------------- EXIT PROC --------------------------;
sys_exit PROC
                    alert          11, 11, msg_exit
                    ; DOS Exit
                    mov            ah, 4ch
                    int            21h
                    ret
sys_exit ENDP            

;--------------------- GET TIME PROC ------------------------;
get_time PROC 
                    ; input  : BX=offset address of the string TIME
                    ; output : BX=current time
                    ; get current system time
                    mov            ah, 2ch
                    int            21h
                    
                    ; ch=hours
                    mov            al, ch
                    call           to_ascii
                    mov            [bx], ax
                    
                    ; cl=minutes
                    mov            al, cl
                    call           to_ascii
                    mov            [bx+3], ax
                    ; dh=seconds
                    mov            al, dh
                    call           to_ascii
                    mov            [bx+6], ax
                    ret
get_time ENDP 

;--------------------- TO ASCII PROC -----------------------;
to_ascii PROC
                    ; input  : AL=binary code
                    ; output : AX=ASCII code
                    mov            ah, 00h
                    mov            dl, 10d
                    div            dl
                    or             ax, 3030H
                    ret
to_ascii ENDP

;----------------- VALIDATE ACCOUNT PROC -------------------;
validate_acct PROC
                    ; ensure correct length of input
                    cmp            in_card_no[1], 16d
                    jne            str_notequal
                    cmp            in_pin_code[1], 6d
                    jne            str_notequal
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
                    ; equal
                    mov            acct_login[0], 01h
                    ret
    str_notequal:
                    alert          10, 10, err_incorrect
                    call           delay
                    ret
validate_acct ENDP

;---------------- GET MOUSE COORDINATE PROC ----------------;
whereis_mouse PROC
                    mov            ax, 03h
                    int            33h
                    ret
ENDP

;---------------------- DELAY PROC -------------------------;
; one second delay
delay PROC
                    mov            al, 00h
                    mov            cx, 0Fh
                    mov            dx, 4240h
                    mov            ah, 86h
                    int            15h
                    ret
ENDP

balance_page PROC
                    set_videopage  6
                    cmp            PAGE_BALANCE, 1
                    je             blnc_listen
    blnc:
                    call           cls
                    prints         8, 7, 6, blnc_text
                    printr         9, 7, 6, 205d, 15
                    printc         10, 7, 6, 'P'
                    printr         11, 7, 6, 205d, 15
                    prints         13, 7, 6, blnc_frm_sel[9]
                    prints         18, 7, 6, blnc_frm_sel[0]

                    ; the page has been loaded
                    mov            PAGE_BALANCE, 1
    blnc_listen:
                    ; reset balance printing
                    prints         10, 9, 6, ff_balance
                    ; update mouse position
                    call           whereis_mouse
                    cmp            bx, 1
                    jne            blnc_listen
    blnc_print:
                    cmp            dx, 0068h
                    jl             blnc_listen
                    cmp            dx, 0070h
                    jg             blnc_back
                    cmp            cx, 0038h
                    jl             blnc_listen
                    cmp            cx, 00BEh
                    jg             blnc_listen
                    ; PRINT PROCESS
                    ; ENDPRC
                    jmp            blnc_listen
    blnc_back:
                    cmp            dx, 0090h
                    jl             blnc_listen
                    cmp            dx, 0098h
                    jg             blnc_listen
                    cmp            cx, 0038h
                    jl             blnc_listen
                    cmp            cx, 0077h
                    jg             blnc_print
                    ; BACK PROCESS
                    ret
                    ; ENDPRC
balance_page ENDP
END main