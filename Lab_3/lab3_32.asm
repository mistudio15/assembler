        section    .data

a       dd -2
b       dd 8
c       dd 3
y       dd 7

n       dd 5
m       dd 3
msg1    db "Result: "
lenm1   equ $-msg1
msg0    db "Division by zero...", 10
lenm0   equ $-msg0
endline db 10

        section    .bss 

strres  resb 10

        section    .text
        global _start
_start:
  
        test dword[b], 1        ; четное & 1 = 0, нечетное & 1 = 1        
        jz else         
                

                        ; b - нечетное, обрабатываем второе выражение (ниже)
        mov EAX, 1      ; через цикл-пока считаем a^n, где n = 5
        mov ECX, 0
cycle:  
                cmp ECX, [n]
                je break_cycle
                imul dword[a]
                inc ECX
                jmp cycle

break_cycle:

        mov EBX, EAX    ; a^n помещаем в EBX
                        ; через счетный цикл считаем c^m, где m = 3
        mov EAX, 1
        mov ECX, [m]
        jcxz end_loop
begin_loop:
                imul dword[c]
                loop begin_loop        
end_loop:

        sub EBX, EAX    ; a^n - c^m
        mov EAX, EBX    ; результат в EAX
        
        jmp continue 
        
else:                   ; обрабатываем первое выражение 
        mov EAX, [b]
        cmp EAX, 0
        je exception    ; если b = 0, "генерируем исключение"

        sub EAX, [a]    ;          b - a
        cdq
        idiv dword[b]   ;         (b - a) / b
        imul dword[y]   ;     y * (b - a) / b
        imul dword[a]   ; a * y * (b - a) / b
        jmp continue

exception:              ; выводим "Division by zero..."
        mov eax, 4          
        mov ebx, 1          
        mov ecx, msg0     
        mov edx, lenm0 
        int 80h
        jmp exit

continue:               ; выводим "Result: <EAX>"
        push eax

        mov     eax, 4  ; Выводим "Result: "    
        mov     ebx, 1          
        mov     ecx, msg1     
        mov     edx, lenm1  
        int     80h

        pop eax
                        ; в EAX хранится целочисленный результат
        mov esi, strres ; заносим в esi буфер для результата строки

        call IntToStr   ; esi теперь хранит адрес строки "<EAX>", а EAX - длину строки
        mov edi, eax
        
        mov eax, 4
        mov ebx, 1
        mov ecx, esi            ; esi содержит адрес строки "<EAX>"
        mov edx, edi            ; edi содержит длину строки "<EAX>"
        int 80h

exit:
        ; exit
        mov     eax, 1          ; системная функция 1 (exit)
        xor     ebx, ebx        ; код возврата 0    
        int     80h             ; вызов системной функции

%include "./lib.asm"
