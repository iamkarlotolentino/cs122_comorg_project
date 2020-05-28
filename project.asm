
TITLE "Bank Account Manager"

.MODEL small
.STACK 64h
.DATA
    ; Strings are placed above, herein the constants
    menu_frm_text   db  "Withdraw$", "Deposit$", "Balance$", "Reset PIN$", "Log Out$", "--$"
    menu_hdr        db  201d, 15 dup(205d), 187d, '$'
    menu_frm_ftr    db  200d, 15 dup(205d), 188d, '$'

    blnc_text       db  "Your balance is$"
    blnc_frm_sel    db  "[ BACK ]$"
    
    err_blank       db  "Input cannot be blank$"
    err_incorrect   db  "Incorrect! Try again.$"
    err_file404     db  "Error. Account database not found!$"
    err_invalid     db  "Your input is invalid.$"

    msg_success     db  "Successful!$"
    msg_wait        db  "Please wait$"
    msg_exit        db  "Thank you. Goodbye!$"
    msg_copyright   db  "Teller Machine @ 2020 ", 179d, " v1.2$"

    time            db  "Time:$"
    timestamp       db  "00:00:00$"

    login_accnt     db  "Welcome!$"
    login_desc      db  "Your personal bank acc't manager$"
    login_frm_text  db  "CARD NO.$", "PIN CODE$" 
    login_frm_sel   db  "[ OK ]$", "[ CANCEL ]$"

    input_text      db  "ENTER INPUT$"


    ; Accounts flags and details
    ff_balance      db  12 dup(0), '$'
    ; Inputs for reading
    in_card_no      db  16 dup(0), '$'
    in_pin_code     db   6 dup(0), '$'
    
    ; File handling of the account file
    fname           db  "account.txt", 0
    fhandle         dw  ?
    faccountn       dw  -40d
    ; All important account data are stored in this data
    ; NOTE: Additional 2 bytes to detect the EOF.
    fbuffer         db  40 dup(?)
    
    ; Inputs for money are buffered in this data
    _input          db  12 dup(0), '$'
    ; Computations are buffered in this data
    _comp           db  12 dup(0), '$'


    ; Flags for page loading
    ; If page has been loaded once, then it is set to { 1 }, otherwise, { 0 }
    pgf_login       db 0
    pgf_menu        db 0
    pgf_input       db 0
    pgf_reset       db 0
    pgf_balance     db 0
    pgf_alert       db 0
    pgf_wait        db 0
    pgf__current    db 0
.CODE

; Input/Output
INCLUDE 'lib/io.inc'
; Initialization of program
INCLUDE 'lib/mc_setup.inc'

; Account file reading
INCLUDE 'lib/mc_loadacct.inc'
; Manage deposit and withdraw
INCLUDE 'lib/mc_transaction.inc'
; Verifies the input from login page
INCLUDE 'lib/pr_validateacct.inc'

; Page views and response
INCLUDE 'lib/pr_loginpage.inc'
INCLUDE 'lib/pr_menupage.inc'
INCLUDE 'lib/pr_inputpage.inc'
INCLUDE 'lib/pr_balancepage.inc'

; Miscellaneous commands
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
                    call           pg_login
                    ; evaluate if the input is valid
                    ; card_no not empty
                    cmp            in_card_no[0], '$'
                    je             login_error
                    ; pin-code not empty
                    cmp            in_pin_code[0], '$'
                    je             login_error
                    ; PROCESS login
                    set_videopage  7
                    ; open file, or reset if not first call
                    open_file
    verify:         
                    ; offset to next account
                    add            faccountn, 40d
                    load_account
                    ; PROCESS evaluation
                    ; all accounts are checked (end of file)
                    pop            ax
                    cmp            ax, 0000h
                    je             no_match
                    ; verify account from buffered data
                    validate_account
                    ; ah = 1 if account is valid
                    cmp            ah, 1
                    je             clear_input
                    ; more accounts to check
                    pop            ax
                    cmp            ax, 28h
                    je             verify
                    ; ENDPRC
    no_match:
                    ; no account matches
                    alert          10, 10, err_incorrect
                    jmp            login
    clear_input:    
                    close_file
                    ; removing input text in login page
                    printr         9,  16, 0, ' ', 16
                    printr         11, 16, 0, ' ', 6
                    
                    call           pg_menu
                    ; expected logout has been called
                    jmp            login
    login_error:
                    alert          9, 13, err_blank
                    jmp            login
main ENDP
END main