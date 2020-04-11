
init_prog MACRO
                    ; data segment address
                    ; mov            dx, @data
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
init_prog ENDM