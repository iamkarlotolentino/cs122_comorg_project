
TITLE "Bank Account Manager"

.MODEL small
.STACK 125h
.DATA
    ; Accounts flags and details
    ff_balance      db  12 dup(0), '$'                ; balance from the account file
    
    ; File handling of the account file
    fname           db  "account.txt", 0
    fhandle         dw  ?
    ; All important data are stored in here
    fbuffer         db  40 dup(?)
    
    new_pin_code    db   7, ?,  7 dup('$')
    
    ; for reading input
    _input          db  12 dup(0), '$'
    ; temporary placement for computation
    _comp           db  12 dup(0), '$'

    ; [page flags] 1=loaded, 0=empty
    pgf_login       db 0
    pgf_menu        db 0
    pgf_input       db 0
    pgf_reset       db 0
    pgf_balance     db 0
    pgf_alert       db 0
    pgf_wait        db 0
    ; [page flag trackers]
    pgf__current    db 0
    
    time            db  "Time:$"
    timestamp       db  "00:00:00$"

    login_accnt     db  "Welcome, JC!$"
    login_desc      db  "Your personal bank acc't manager$"
    login_frm_text  db  "CARD NO.$", "PIN CODE$" 
    login_frm_sel   db  "[ OK ]$", "[ CANCEL ]$"
    
    ; Input of account details, used in login page
    input_text      db  "ENTER INPUT$"
    in_card_no      db  17 dup(0)
    in_pin_code     db   7 dup(0)

    menu_frm_text   db  "Withdraw$", "Deposit$", "Balance$", "Reset PIN$", "Log Out$", "Details$"
    menu_hdr        db  201d, 15 dup(205d), 187d, '$'
    menu_frm_ftr    db  200d, 15 dup(205d), 188d, '$'

    blnc_text       db  "Your balance is$"
    blnc_frm_sel    db  "[ BACK ]$", "[ PRINT BALANCE ]$"
    
    err_blank       db  "Input cannot be blank$"
    err_incorrect   db  "Incorrect! Try again.$"
    err_file404     db  "Error. Account database not found!$"
    err_invalid     db  "Your input is invalid.$"

    msg_success     db  "Successful!$"
    msg_wait        db  "Please wait$"
    msg_exit        db  "Thank you. Goodbye!$"
    msg_copyright   db  "Teller Machine @ 2020 ", 179d, " v1.2$"
.CODE

INCLUDE 'lib/io.inc'
INCLUDE 'lib/mc_setup.inc'

INCLUDE 'lib/mc_loadacct.inc'
INCLUDE 'lib/mc_transaction.inc'
INCLUDE 'lib/pr_validateacct.inc'

INCLUDE 'lib/pr_loginpage.inc'
INCLUDE 'lib/pr_menupage.inc'
INCLUDE 'lib/pr_inputpage.inc'
INCLUDE 'lib/pr_balancepage.inc'

INCLUDE 'lib/utils.inc'

;---------------------- MAIN PROC -------------------------;
main PROC
                    ; initialize all appropriate setup
                    mov            dx, @data
                    init_prog
    load_pw:
                    ; load please wait
                    set_videopage  7
                    clear_screen
                    prints         11, 15, 7, msg_wait
                    mov            pgf_wait, 1
    login:
                    load_account   fname
                    call           pg_login
                    ; evaluate if the input is valid
                    ; card_no not empty
                    cmp            in_card_no[0], '$'
                    je             login_error
                    ; pin-code not empty
                    cmp            in_pin_code[0], '$'
                    je             login_error
                    ; validate acccount
                    call           validate_acct
                    cmp            ah, 1
                    jne            login
                    set_videopage  7
    clear_input:    
                    ; removing input text in login page
                    printr         9,  16, 0, ' ', 16
                    printr         11, 16, 0, ' ', 6
                    jmp            continue
    login_error:
                    alert          9, 13, err_blank
                    call           delay
                    jmp            login
    continue:
                    call           pg_menu
                    ; expected logout has been called
                    jmp            login
main ENDP
END main