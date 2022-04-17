        section .data   ; сегмент инициализированных переменных

a       dw  22
k       dw  5
d       dw  -6

        section .bss  ; сегмент неинициализированных переменных

c       resw 1

        section .text ; сегмент кода
        global  _start
_start:
        mov AX, [a]     
        
        
        mov CX, 3
        cwd
        div CX          ; a / 3
        
        sub AX, [k]     ; (a / 3) - k
        mov BX, AX
        
        add word[d], 2  ; d + 2
        mov AX, [d]
        
        mov CX, 5
        imul CX         ; (d + 2) * 5
        
        add AX, BX      ; (a / 3) - k + (d + 2) * 5
        
        mov [c], AX

        
        
