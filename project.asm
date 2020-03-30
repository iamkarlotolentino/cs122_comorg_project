
title "Bank Account Manager"

.MODEL small
.STACK 100h
.DATA
    in_card_no      db  17, ?, 17 dup(' ')
    in_pin_code     db   7, ?,  7 dup(' ')
    
    time            db  "Time:$"
    timestamp       db  "00:00:00$"
                    ;   [0]   [1]   [2]   [3]   [4]   [5]   [6]   [7]   [8]   [9]   [10]  [11]
    _sym            db  185d, 186d, 187d, 188d, 200d, 201d, 202d, 203d, 204d, 205d, 206d, 175d                                                                      

	login_accnt     db "Welcome, JC!", "$"
	login_desc      db "Your personal bank acc't manager$"
	login_frm_text  db "CARD NO.$", "PIN CODE$" 
    login_frm_sel   db "[ OK ]$", "[ CANCEL ]$", "[-OK-]$", "[-CANCEL-]$"
    
    menu_frm_text   db  "Withdraw$", "Deposit$", "Balance$", "Reset PIN$", "Log Out$", "Details$"
    menu_hdr        db  201d, 15 dup(205d),  187d, "$"
    menu_frm_ftr    db  200d, 15 dup(205d), 188d, "$"
    
    err_blank       db  "NOT VALID INPUT$"
    err_incorrect   db  "Incorrect! Try again.$"
	
    exit_msg        db "Thank you. Goodbye!$"
    app_blank       db "                                    $"
    app_version     db "Teller Machine © 2020 ", 179d, " v1.0$" 	
.CODE

;**************************************************************************;
;------------------------------   MACRO   --------------------------------;
;**************************************************************************;

cursor_at MACRO row,column
    pusha
    mov dh, row
    mov dl, column
    mov bh, 0
    mov ah, 2
    int 10h
    popa
ENDM

; string scanner
reads MACRO buffer
    pusha
    lea dx, buffer
	mov ah, 0ah
	int 21h
	xor bx, bx
	mov bl, buffer[1]
	mov buffer[bx+2], '$'
	lea dx, buffer + 2
	popa
ENDM

; string printing
prints MACRO msg
    pusha
    lea msg
    mov ah, 9
    int 21h
    popa
ENDM

; char printing
printc MACRO char
    pusha
    mov dl, char
    mov ah, 2
    int 21h
    popa
ENDM

; repeated char printing
printr MACRO sym, count
    LOCAL l
    pusha
    mov cl, count
    l: printc sym
    loop l
    popa
ENDM

alert MACRO msg
    pusha
    call cls
    prints msg
    popa
ENDM

main PROC
    call setup
    
    login:
        call cls
        call login_page
        ; evaluate the input if valid
        ; if length of in_pin_code==6
       ; mov al, in_pin_code[1]
       ; cmp al, 6
       ; jne login_error
        ; if length of in_card_no==16
       ; mov al, in_card_no[1]
       ; cmp al, 16
       ; jne login_error
        jmp continue
    login_error:                 
        cursor_at 11,13
        alert err_blank
        jmp login
    continue:
        call menu_page
        call sys_exit
main ENDP

setup PROC
    ; data segment address
    mov ax, @data
	mov ds, ax
	
	mov ax, 1003h ; disable blinking.  
    mov bx, 0        
    int 10h
    
    ; hide text cursor:
    mov ch, 32
    mov ah, 1
    int 10h
	
	; initialize mouse
	mov ax, 0
	int 33h
	
	; display mouse cursor:
    mov ax, 1
    int 33h
	
	; set video mode
	mov al, 00h
	mov ah, 0
	int 10h
	
	call cls
    ret   
setup ENDP

login_page PROC
    cursor_at 3,2
    printc _sym[5]
	printr _sym[9],34
	printc _sym[2]
	
	cursor_at 4,2
	printc _sym[1]
	cursor_at 4,37
	printc _sym[1]
	cursor_at 4,4
	prints login_accnt
	
	cursor_at 5,2
	printc _sym[1]
	cursor_at 5,37
	printc _sym[1]                                                                       
	cursor_at 5,4
	prints login_desc
	
	cursor_at 6,2
	printc _sym[4]
	printr _sym[9],34
	printc _sym[3]
	 
	cursor_at   8,2
	printc _sym[5]
	printr _sym[9],12
	printc _sym[7]
	printr _sym[9],21
	printc _sym[2]
	
	cursor_at 9,2
	printc _sym[1]
	cursor_at 9,15
	printc _sym[1]
	cursor_at 9,37
	printc _sym[1]
	cursor_at 9,4
	prints login_frm_text[0]
	
	cursor_at 10,2
	printc _sym[8]
	printr _sym[9],12
	printc _sym[10]
	printr _sym[9],21
	printc _sym[0]
                                                     
	cursor_at 11,2
	printc _sym[1]
	cursor_at 11,4
	prints login_frm_text[9]
	cursor_at 11,15
	printc _sym[1]
	cursor_at 11,37
	printc _sym[1]
	
	cursor_at 12,2
	printc _sym[4]
	printr _sym[9],12
	printc _sym[6]
	printr _sym[9],21
	printc _sym[3]
	
	cursor_at 14,6
	prints login_frm_sel[0]
	cursor_at 14,18
	prints login_frm_sel[7]
	
	cursor_at   23,2
	prints      app_version
	
	; listens to mouse-pos
	keep_listening:
    	; get mouse state
    	mov     ax, 3
    	int     33h
    	; left button click
    	mov     ax, bx
    	and     ax, 0000000000000001b
    	jz      keep_listening
    	; passes when left button is pressed
    	
    	; form-selected detection
    	cmp     cx, 0080h
    	jnge    menu_selection
    	cmp     cx, 0126H
    	jnle    menu_selection
    	
    	card_no:
        	cmp         dx, 0050h
        	jnle        pin_code
        	cmp         dx, 0048h
        	jnge        menu_selection
        	cursor_at   9,16
        	reads       in_card_no
    	pin_code:
        	cmp         dx, 005Eh
        	jnle        menu_selection
        	cmp         dx, 0059h
        	jnge        menu_selection
        	cursor_at   11,16
    	    reads       in_pin_code
    	    
    	; ok&cancel menu detection 
    	menu_selection:
        	cmp     dx, 006Eh
        	jnge    keep_listening
        	cmp     dx, 0075h
        	jnle    keep_listening
    	cancel_button:
        	cmp     cx, 0090h
        	jnge    ok_button
        	cmp     cx, 00DFh
        	jnle    keep_listening
        	call sys_exit
    	ok_button:
    	    cmp     cx, 0030h
        	jnge    keep_listening
        	cmp     cx, 005Fh
        	jnle    keep_listening
        	; TODO: Check credibility first
    ret	 
login_page ENDP

menu_page PROC
    call cls                                       
    ; al=row start
    mov bl,   7
    mov cl,   3
    create_block:
        cursor_at   bl,2
        prints      menu_hdr
        cursor_at   bl,20
        prints      menu_hdr
        inc bl
        cursor_at   bl,2
        printc      _sym[1]
        cursor_at   bl,18
        printc      _sym[1]
        cursor_at   bl,20
        printc      _sym[1]
        cursor_at   bl,36
        printc      _sym[1]
        inc bl
        cursor_at   bl,2
        prints      menu_frm_ftr
        cursor_at   bl,20
        prints      menu_frm_ftr
        inc bl
        inc bl
    loop create_block
    
    ; withdraw-text
    cursor_at 8,6
    prints menu_frm_text[0]
    ; deposit-text
    cursor_at 8,25
    prints menu_frm_text[9]
    ; balance-text
    cursor_at 12,7
    prints menu_frm_text[17]
    ; reset-pin text
    cursor_at 12,24
    prints menu_frm_text[25]
    ; log-out text
    cursor_at 16,7
    prints menu_frm_text[35]
    ; details text
    cursor_at 16,25
    prints menu_frm_text[43]
    
    render_loop:
    
        ; time printing
        lea bx,timestamp           
        call get_time               
        cursor_at 2,2
        prints login_desc
        cursor_at 4,2
        prints time
        cursor_at 4,8
        prints timestamp
        
        call cls_menu
           
        ; get mouse state
        mov ax, 3
        int 33h
        
        col_1:
            cmp cx, 0018h
            jnge render_loop
            cmp cx, 008Fh
            jnle col_2
                btn_withdraw:
                    cmp dx, 0040h
                    jnge render_loop
                    cmp dx, 0047h
                    jnle btn_balance
                    cursor_at 8,3
                    printc _sym[11]
                    jmp render_loop
                btn_balance:
                    cmp dx, 0060h
                    jnge render_loop
                    cmp dx, 0067h
                    jnle btn_logout
                    cursor_at 12,3
                    printc _sym[11]
                    jmp render_loop
                btn_logout:
                    cmp dx, 0080h
                    jnge render_loop
                    cmp dx, 0087h
                    jnle render_loop
                    cursor_at 16,3
                    printc _sym[11]
                    jmp render_loop
            jmp render_loop
        col_2:
            btn_deposit:
                cmp dx, 0040h
                jnge render_loop
                cmp dx, 0047h
                jnle btn_reset_pin
                cursor_at 8,21
                printc _sym[11]
                jmp render_loop
            btn_reset_pin:
                cmp dx, 0060h
                jnge render_loop
                cmp dx, 0067h
                jnle btn_details
                cursor_at 12,21
                printc _sym[11]
                jmp render_loop
            btn_details:
                cmp dx, 0080h
                jnge render_loop
                cmp dx, 0087h
                jnle render_loop
                cursor_at 16,21
                printc _sym[11]
                jmp render_loop
        jmp render_loop
    ; stopper 
    mov ah, 1
    int 21h
    ret
menu_page ENDP

cls_menu PROC
    ; withdraw
    cursor_at 8,3
    printc ' '
    ; deposit
    cursor_at 8,21
    printc ' '
    ; balance
    cursor_at 12,3
    printc ' '
    ; reset pin
    cursor_at 12,21
    printc ' '
    ; logout
    cursor_at 16,3
    printc ' '
    ; details
    cursor_at 16,21
    printc ' '
    ret        
cls_menu ENDP

cls PROC
    xor al, al
    xor cx, cx 
    mov dx, 184fh
    mov bh, 1eh      
    mov ah, 06h
    int 10h
    ret    
cls ENDP

sys_exit PROC
    cursor_at 11,11
    alert exit_msg
    ; DOS Exit
	mov ah, 4ch
	int 21h
	ret
sys_exit ENDP            

get_time PROC 
    ; input  : BX=offset address of the string TIME
    ; output : BX=current time

    push ax                      
    push cx     
    
    ; get current system time
    mov ah, 2ch
    int 21h                    
    
    ; ch=hours
    mov al, ch
    call to_ascii
    mov [bx], ax                
    
    ; cl=minutes
    mov al, cl               
    call to_ascii                 
    mov [bx+3], ax                
    
    ; dh=seconds                         
    mov al, dh                    
    call to_ascii                
    mov [bx+6], ax               
                                                 
    pop cx
    pop ax  

    RET                          
get_time ENDP 

to_ascii PROC
    ; input  : AL=binary code
    ; output : AX=ASCII code
    push dx                       
    mov ah, 0              
    mov dl, 10                
    div dl
    or ax, 3030H                  
    pop DX 
    ret
to_ascii ENDP
END main