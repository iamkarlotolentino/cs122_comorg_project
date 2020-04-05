
INCLUDE 'macros.inc'

TITLE "Bank Account Manager"

.MODEL SMALL
.STACK 100h
.DATA
    acct_login      db   0
    ff_card_no      db  16 dup(' '), '$'
    ff_pin_code     db   7 dup(' '), '$'
    ff_balance      db  12 dup(' '), '$'
    
    in_card_no      db  17, ?, 17 dup('$')
    in_pin_code     db   7, ?,  7 dup('$')
    new_pin_code    db   7, ?,  7 dup('$')
    
    input_amount    db  13, ?, 13 dup(' ')
    
    fname           db  "account.txt", 0
    fhandle         dw  ?
    fbuffer         db  38 dup(?)

                    ;  [0][1][2][3][4][5][6][7]
    page_buffer     db  0, 0, 0, 0, 0, 0, 0, 0
    
    time            db  "Time:$"
    timestamp       db  "00:00:00$"
                    ;   [0]   [1]   [2]   [3]   [4]   [5]   [6]   [7]   [8]   [9]   [10]
    _sym            db  185d, 186d, 187d, 188d, 200d, 201d, 202d, 203d, 204d, 205d, 206d

    login_accnt     db "Welcome, JC!$"
    login_desc      db "Your personal bank acc't manager$"
    login_frm_text  db "CARD NO.$", "PIN CODE$" 
    login_frm_sel   db "[ OK ]$", "[ CANCEL ]$"
    
    menu_frm_text   db  "Withdraw$", "Deposit$", "Balance$", "Reset PIN$", "Log Out$", "Details$"
    menu_hdr        db  201d, 15 dup(205d), 187d, '$'
    menu_frm_ftr    db  200d, 15 dup(205d), 188d, '$'
    
    err_blank       db  "NOT VALID INPUT$"
    err_incorrect   db  "Incorrect! Try again.$"
    err_file404     db  "Error. Account database not found!$"
    
    input_text      db  "Enter amount:$"
    input_note      db  "NOTE: Amount should be divisible by 20$"
    
    exit_msg        db "Thank you. Goodbye!$"
    app_version     db "Teller Machine @ 2020 ", 179d, " v1.0$"
.CODE
;---------------------- MAIN PROC -------------------------;
main PROC
                    ; initialize all proper data and setup
                    call           setup
    login:
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
                    jmp            continue
    login_error:
                    cursor_at      11,13,6
                    alert          err_blank
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
                    mov            cx, 30h
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
                    prints         err_file404
                    call           sys_exit  
setup ENDP

;---------------------- LOGIN PAGE PROC -------------------------;
login_page PROC
                    set_videopage  0
                    ; check if page has been loaded
                    cmp            page_buffer[0], 1
                    je             keep_listening
                    call           cls
                    ; selection form printing
                    cursor_at      3,2,0
                    printc         _sym[5]
                    printr         _sym[9],34
                    printc         _sym[2]
                    
                    cursor_at      4,2,0
                    printc         _sym[1]
                    cursor_at      4,37,0
                    printc         _sym[1]
                    cursor_at      4,4,0
                    prints         login_accnt
                    
                    cursor_at      5,2,0
                    printc         _sym[1]
                    cursor_at      5,37,0
                    printc         _sym[1]
                    cursor_at      5,4,0
                    prints         login_desc
                    
                    cursor_at      6,2,0
                    printc         _sym[4]
                    printr         _sym[9],34
                    printc         _sym[3]
                     
                    cursor_at      8,2,0
                    printc         _sym[5]
                    printr         _sym[9],12
                    printc         _sym[7]
                    printr         _sym[9],21
                    printc         _sym[2]
                    
                    cursor_at      9,2,0
                    printc         _sym[1]
                    cursor_at      9,15,0
                    printc         _sym[1]
                    cursor_at      9,37,0
                    printc         _sym[1]
                    cursor_at      9,4,0
                    prints         login_frm_text[0]
                    
                    cursor_at      10,2,0
                    printc         _sym[8]
                    printr         _sym[9],12
                    printc         _sym[10]
                    printr         _sym[9],21
                    printc         _sym[0]

                    cursor_at      11,2,0
                    printc         _sym[1]
                    cursor_at      11,4,0
                    prints         login_frm_text[9]
                    cursor_at      11,15,0
                    printc         _sym[1]
                    cursor_at      11,37,0
                    printc         _sym[1]
                    
                    cursor_at      12,2,0
                    printc         _sym[4]
                    printr         _sym[9],12
                    printc         _sym[6]
                    printr         _sym[9],21
                    printc         _sym[3]
                    
                    cursor_at      14,6,0
                    prints         login_frm_sel[0]
                    cursor_at      14,18,0
                    prints         login_frm_sel[7]
                    
                    cursor_at      23,2,0
                    prints         app_version

                    ; mark the page has been loaded
                    mov            page_buffer[0], 1

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
                    cursor_at      9,16,0
                    reads          in_card_no
    pin_code:
                    cmp            dx, 005Eh
                    jnle           menu_selection
                    cmp            dx, 0059h
                    jnge           menu_selection
                    cursor_at      11,16,0
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
                    cmp            page_buffer[1], 1
                    je             render_loop
                    call           cls

                    ; al=row start
                    mov bl,        07h
                    mov cl,        03h
                    ; print the selection box
    create_block:
                    ; creates block
                    cursor_at      bl,2,1
                    prints         menu_hdr
                    cursor_at      bl,20,1
                    prints         menu_hdr
                    inc            bl
                    cursor_at      bl,2,1
                    printc         _sym[1]
                    cursor_at      bl,18,1
                    printc         _sym[1]
                    cursor_at      bl,20,1
                    printc        _sym[1]
                    cursor_at      bl,36,1
                    printc         _sym[1]
                    inc            bl
                    cursor_at      bl,2,1
                    prints         menu_frm_ftr
                    cursor_at      bl,20,1
                    prints         menu_frm_ftr
                    add            bl, 2
                    loop           create_block
        
                    ; withdraw-text
                    cursor_at      8,6,1
                    prints         menu_frm_text[0]
                    ; deposit-text
                    cursor_at      8,25,1
                    prints         menu_frm_text[9]
                    ; balance-text
                    cursor_at      12,7,1
                    prints         menu_frm_text[17]
                    ; reset-pin text
                    cursor_at      12,24,1
                    prints         menu_frm_text[25]
                    ; log-out text
                    cursor_at      16,7,1
                    prints         menu_frm_text[35]
                    ; details text
                    cursor_at      16,25,1
                    prints         menu_frm_text[43]
    
                    ; prints time (text) 
                    cursor_at      4,2,1
                    prints         time

                    ; mark the page has been loaded
                    mov            page_buffer[1], 1
    render_loop:
                    ; time printing
                    lea            bx,timestamp
                    call           get_time
                    cursor_at      2,2,1
                    prints         login_desc
                    
                    cursor_at      4,8,1
                    prints         timestamp
                    
                    call           whereis_mouse
                    cmp            bx, 0001h
                    jne            render_loop
    col_1:
                    ; checks if mouse coor is in first column
                    cmp            cx, 0018h
                    jnge           render_loop
                    cmp            cx, 008Fh
                    ; if not, check if it is in second column
                    jnle           col_2
    btn_withdraw:
                    cmp            dx, 0040h
                    jnge           render_loop
                    cmp            dx, 0047h
                    jnle           btn_balance
                    ; PROCESS: withdraw
                    ; withdraw process
                    call           input_page
                    withdrawable   input_amount, ff_balance
                    ; ENDPRC
                    ; go back to menu
                    jmp            menu_start
    btn_balance:
                    cmp            dx, 0060h
                    jnge           render_loop
                    cmp            dx, 0067h
                    jnle           btn_logout
                    ; PROCESS: balance
                    ; ENDPRC
                    jmp            render_loop
    btn_logout:
                    cmp            dx, 0080h
                    jnge           render_loop
                    cmp            dx, 0087h
                    jnle           render_loop
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
                    jnge           render_loop
                    cmp            dx, 0047h
                    jnle           btn_reset_pin
                    cursor_at      8,21,1
                    printc         _sym[11]
                    jmp            render_loop
    btn_reset_pin:
                    cmp            dx, 0060h
                    jnge           render_loop
                    cmp            dx, 0067h
                    jnle           btn_details
                    ; PROCESS: reset pin
                    call           input_page
                    ; TODO
                    ; ENDPRC
                    jmp            menu_start
    btn_details:
                    cmp            dx, 0080h
                    jnge           render_loop
                    cmp            dx, 0087h
                    jnle           render_loop
                    jmp            render_loop
                    jmp            render_loop
                    ret
menu_page ENDP

;---------------------- INPUT PAGE PROC -------------------------;
input_page PROC
                    set_videopage  2
                    ; check if page has been loaded
                    cmp            page_buffer[2], 1
                    je             input_read
                    call           cls
                    cursor_at      9,11,2
                    prints         input_text
                    cursor_at      12,11,2
                    printr         '-',12d
                    cursor_at      15,1,2
                    prints         input_note 
                    cursor_at      11,11,2
                    mov            page_buffer[2], 1
    input_read:
                    reads          input_amount
                    ret
input_page ENDP

;---------------------- CLEAR PROC -------------------------;
cls PROC
                    xor            al, al
                    xor            cx, cx 
                    mov            dx, 184fh
                    mov            bh, 1eh      
                    mov            ah, 06h
                    int            10h
                    ret    
cls ENDP

;---------------------- EXIT PROC -------------------------;
sys_exit PROC
                    cursor_at      11,11,6
                    alert          exit_msg
                    ; DOS Exit
                    mov            ah, 4ch
                    int            21h
                    ret
sys_exit ENDP            

;---------------------- GET TIME PROC -------------------------;
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

;---------------------- TO ASCII PROC -------------------------;
to_ascii PROC
                    ; input  : AL=binary code
                    ; output : AX=ASCII code
                    mov            ah, 00h
                    mov            dl, 10d
                    div            dl
                    or             ax, 3030H
                    ret
to_ascii ENDP

;---------------------- VALIDATE ACCOUNT PROC -------------------------;
validate_acct PROC
                    ; compare card_no
                    lea            si, ff_card_no
                    lea            di, [in_card_no+2]
                    xor            cx, cx
                    mov            cx, 10h
                    mov            al, [si]
                    mov            bl, [di]
                    cmp            al, bl
                    jne            str_notequal
                    repe cmpsb
                    jne            str_notequal
                    ; compare pin_code
                    lea            si, ff_pin_code
                    lea            di, [in_pin_code+2]
                    xor            cx, cx
                    mov            cx, 06h
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
                    cursor_at      10,10,6
                    alert          err_incorrect
                    call           delay
                    ret    
validate_acct ENDP

;---------------------- GET MOUSE COORDINATE PROC -------------------------;
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
END main