; This source file contains code instruction for reading file.
; This file contains the credentials of the person's account.

;---
; Traverse reading.
; Reads the next 40 bytes from the file and stored in the fbuffer.
; The first call will start at the start of the file, and last position is
; maintained. Another call, will start at offset of 40 bytes.
; [output]
; ax = number of bytes read
; cx = explicit times to read
load_account MACRO
                    ; load account details
                    ; read file
                    mov            bx, fhandle
                    mov            cx, 28h
                    lea            dx, fbuffer
                    mov            ah, 3Fh
                    int            21h
                    ; maintain ax to evaluate after (needed two)
                    push           ax
                    push           ax
                    ; copy current balance
                    lea            si, fbuffer
                    add            si, 25d             ; offset from card_no to balance
                    lea            di, ff_balance
                    mov            cx, 000Ch
                    inc            si
                    cld
                    rep
                    movsb
load_account ENDM

;---
; Opens the file from the storage
open_file MACRO
     LOCAL fileerr, lct_continue
                    ; reset account offset
                    mov            faccountn, -40d
                    ; open file
                    mov            al, 02h
                    mov            dx, offset fname
                    mov            ah, 3Dh
                    int            21h
                    jc             fileerr
                    mov            fhandle, ax
                    jmp            lct_continue
     fileerr:
                    prints         0, 0, 0, err_file404
                    call           sys_exit
    lct_continue:
open_file ENDM

;---
; Release the file from the program.
close_file MACRO
                    ; close file
                    mov            bx, fhandle   
                    mov            ah, 3Eh
close_file ENDM