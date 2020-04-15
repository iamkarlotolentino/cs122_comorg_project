; This source file contains a page view where it reads input from user at maximum of 12 digits.

;-------------------- INPUT PAGE PROC -----------------------;
; [input]
; al = number of input
; dx = header text
; [output]
; _comp = data
pg_input PROC
                    pusha
                    set_videopage  2
                    ; check if page has been loaded
                    cmp            pgf_input, 1
                    je             input_read
                    clear_screen
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

                    mov            pgf_input, 1
    input_read:
                    popa

                    ; limit the no. of input
                    mov            _input[0], al

                    ; preserve the no. of input {al}
                    push           ax
                    ; 36d is the center, 2d for the [ ] symbol
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

                    mov            ah, 0
                    mov            al, _input[0]
                    reads          _input, ax

                    ; validate if input is valid
                    validate       _input
                    cmp            al, 1
                    jne            inp_invalid

                    ; please wait
                    set_videopage  7
                    ; should not be empty
                    cmp            _input[0], '$'
                    je             inp_blank
                    ; clears input in video page
                    printr         11, 0, 2, ' ', 39
                    ; return to process if not empty
                    ret
    inp_blank:
                    alert          11, 13, err_blank
                    call           delay
                    ret
    inp_invalid:
                    alert          10, 13, err_invalid
                    call           delay
                    ret
pg_input ENDP