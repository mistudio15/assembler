        section .data   
message db "Enter the string", 10
lenMsg  equ $-message
SPACE   db " "
E       db "E"

        section .bss
InBuf   resb    100             ; максимальная длина строки  
lenIn   equ     $-InBuf  
countE  resb    3        

        section .text 
        global  _start

_start:        

        ; вывод сообщения "Enter the string"

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, message     
        mov     edx, lenMsg  
        int     80h

        ; ввод строчки 

        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf
        mov edx, lenIn
        int 80h



        mov esi, ecx   
        mov edi, ecx    ; пересылаем строчку в esi и edi

        mov ecx, 8      ; счетчик слов


cycle: 
                push ecx
                mov ecx, lenIn

                movzx eax, byte[SPACE]
                repne scasb             ; в edi - адрес следующего пробела

                pop ecx
                mov eax, 0              ; счетчик буквы 'E'

                movzx ebx, byte[E]      ; ebx содержит символ 'E'
count:
                        cmp byte[esi], bl       ; сравниваем текущий символ с 'E'
                        jne not_e  

                        inc eax                 ; если символ = 'E', то счетчик увеличиваем на 1

not_e:
                        inc esi                 ; переходим на следующий символ
                        cmp esi, edi            ; сравниваем с edi, который указывает на конец слова (пробел)
                        jne count               ; если не конец слова, продолжаем считать "E"


                ; если пробел

                push ecx                ; stack <
                push edi                ; stack <

                ; выводим количество букв 'E' в слове под номером ECX
                ; в eax содержится кол-во 'E' в слове  

                mov esi, countE
                call IntToStr
                mov edi, eax    ; количество символов в строке "<EAX>"

                mov eax, 4
                mov ebx, 1
                mov ecx, esi
                mov edx, edi
                int 80h

                pop edi                 ; stack >
                pop ecx                 ; stack >

                ; inc edi             ; был на пробеле, переходим на следующий символ (на след. слово)
                mov esi, edi        ; оба указывают на новое слово

                loop cycle

        ; exit
        mov     eax, 1          ; системная функция 1 (exit)
        xor     ebx, ebx        ; код возврата 0    
        int     80h             ; вызов системной функции

%include "./lib.asm"


