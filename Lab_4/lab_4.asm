        section .data   
n               dd 2    ; количество строк
m               dd 3    ; количество столбцов 
bit             dd 4    ; разрядность системы
message         db "Enter column number", 10
lenMsg          equ $-message
msginput        db "Enter elements of matrix n x m", 10
lenMsgInput     equ $-msginput
msgError        db "Error...", 10
lenMsgError     equ $-msgError
endline         db 10
request         db "Enter number of rows and columns", 10
lenReq          equ $-request   

        section .bss
nm              resd    1       ; количество элементов матрицы
mas             resd    100
InBuf           resb    10      ; введенный элемент матрицы         
lenIn           equ     $-InBuf
OutBuf          resb    10

        section .text
        global  _start
_start:
        ; сообщение "Enter number of rows and columns"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, request     
        mov     edx, lenReq  
        int     80h

        ; ввод количества строк [n]
        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf
        mov edx, lenIn
        int 80h

        mov esi, InBuf
        call StrToInt
        cmp eax, 0
        jle error
        mov [n], eax

        ; ввод количества стобцов [m]
        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf
        mov edx, lenIn
        int 80h

        mov esi, InBuf
        call StrToInt
        cmp eax, 1
        jle error
        mov [m], eax

        ; сообщение "Enter elements of matrix n x m"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msginput     
        mov     edx, lenMsgInput  
        int     80h

        mov eax, [n]
        mul dword[m]            ; в EAX - количество всех элементов матрицы 6 * 5 = 30
        mov dword[nm], eax      ; заносим 30 в память [nm]

        mov ecx, [nm]           ; номер текущего элемента (index) 
        jcxz end_loop_input             
                                ; цикл ввода 6 * 5 чисел и занесение в память mas
loop_input:           
                push ecx        ; stack <

                ; чтение числа с консоли
                mov eax, 3
                mov ebx, 0
                mov ecx, InBuf   
                mov edx, lenIn
                int 80h

                ; ввели "124\n", далее нужно преобразовать в числовое значение

                mov esi, ecx    ; адрес строки, которую нужно конвертировать в число
                call StrToInt   ; преобразованное из строки число находится в EAX

                cmp EBX, 0    
                jne error  
                                ; если EBX = 0, то произошла ошибка, 1 в обратном случае 
                                ; (недопустим. символ, выход за границы разрядной сетки)

                pop ecx         ; stack >

                mov edx, dword[nm]
                sub edx, ecx    ; edx - индекс массива, в который нужно записать введенное значение
                                ; количество чисел - номер итерации


                mov [mas + edx * 4], eax

                loop loop_input        
end_loop_input:


        ; вывод
        mov ecx, [n]     ; вывод матрицы построчно
        mov ebx, 0
cycleOut1:
                push ecx
                mov ecx, [m]
cycleOut2:
                        push ecx
                        mov eax, [mas + ebx * 4]
                        
                        push ebx
                        mov esi, OutBuf
                        call IntToStr       
                       
                        mov     ebx, 1         
                        mov     ecx, esi    
                        mov     edx, eax   
                        mov     eax, 4 
                        int     80h
                        
                        pop ebx
                        pop ecx    
                        inc ebx  
                        loop cycleOut2

                push ebx

                ; вывод перехода на новую строку
                mov     eax, 4  
                mov     ebx, 1
                mov     ecx, endline    
                mov     edx, 1 
                int     80h 

                pop ebx

                pop ecx
        loop cycleOut1



        ; вывод сообщения "Enter column number"

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, message     
        mov     edx, lenMsg  
        int     80h

        ; ввод номера столбца, который необходимо удалить

        mov     eax, 3          
        mov     ebx, 0          
        mov     ecx, InBuf      
        mov     edx, lenIn      
        int     80h                   

        mov esi, ecx            ; адрес строки с номером удаляемого столбца

        call StrToInt           ; в eax - целочисленный номер столбца 
                                ; (при нумерации с нуля - номер следующего столбца)

        cmp EBX, 0                       
        jne error

        cmp eax, dword[m]       ; ввели номер столбца, которого не существует - ошибка
        jg error                        
        cmp eax, 1              ; ввели отрицательный номер столбца - ошибка
        jl error

        mov ecx, dword[m]       ; ecx = количество стобцов
        sub ecx, eax            ; кол-во столбцов - номер удаляемого столбца = кол-во столбцов после удаляемого (ecx)



        ; внешний цикл - итерируемся по столбцам
        ; внутренний цикл - итерируемся по строкам

        jcxz end_loop_logic

outer_loop_logic:         
                push ecx
                mov ebx, 0      ; ebx - смещение по строкам
                mov ecx, [n]     

inner_loop_logic:
                        mov edx, [ebx + eax * 4 + mas]          ; пересылаем значение из столбца в регистр edx
                        dec eax                                 ; переходим на предыдущий столбец    
                        mov dword[ebx + eax * 4 + mas], edx     ; заносим значение edx в предыдущий столбец
                        inc eax                                 ; переходим на исходный столбец

                        ; переход на новую строчку

                        push eax        ; stack <                                                        
                        mov eax, [m]
                        mul dword[bit]  ; eax = [n] * 4 = смещение на следующую строку
                        add ebx, eax    ; смещаемся на следующую строку (5 элементов * 4 байта)
                        pop eax         ; stack >

                        loop inner_loop_logic

                inc eax         ; перемещаемся на следующий столбец
                pop ecx            

                loop outer_loop_logic

end_loop_logic:


        ; выводим пустую строку (отсуп для результатов)

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, endline     
        mov     edx, 1  
        int     80h  

        mov edi, 0              ; edi - смещение по строкам
        mov ecx, [n]    

outer_loop_output:
                push ecx          
                mov ecx, [m] 
                dec ecx         ; количество столбцов уменьшилось на 1, поэтому значение декрементируем 
                mov ebx, 0      ; ebx - номер столбца

inner_loop_output:                  
                        push ecx                ; stack <  

                        mov eax, [edi + ebx * 4 + mas]   ; пересылаем элемент из массива (итерируемся построчно)
                        call IntToStr                    ; конвертируем элемент в строку

                        push ebx                ; stack <
                        
                        ; выводим число
                        mov     eax, 4          
                        mov     ebx, 1          
                        mov     ecx, esi     
                        mov     edx, 4  
                        int     80h    

                        pop ebx                 ; stack >
                        inc ebx                 ; переход к следующему столбцу

                        pop ecx                 ; stack >
                        loop inner_loop_output

        ; выводим пустую строку (как обозначение завершения строки матрицы) 

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, endline     
        mov     edx, 1  
        int     80h  

        ; переход на новую строчку

        mov eax, [m]
        mul dword[bit]          ; eax = [n] * 4 = смещение на следующую строку
        add edi, eax            ; смещаемся на следующую строку (5 элементов * 4 байта)

        pop ecx    
        loop outer_loop_output

        jmp exit
    

error:
        ; вывод сообщения "Error" 
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msgError     
        mov     edx, lenMsgError  
        int     80h     
exit:
        ; exit
        mov     eax, 1          ; системная функция 1 (exit)
        xor     ebx, ebx        ; код возврата 0    
        int     80h             ; вызов системной функции

%include "./lib.asm"