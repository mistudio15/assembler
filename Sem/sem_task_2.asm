; отсортировать выбранную строку в матрице  

        section .data
ENDL            db 10
msg             db "Enter row", 10
lenmsg          equ $-msg

msg2            db "Enter matrix 5x5", 10
lenmsg2         equ $-msg2

msgerror        db "Error..."
lenmsgerror     equ $-msgerror

byte_in_row     dd 20   ; количество байт в 1 строке размером 5 элементов

        section .bss  
InBuf           resb    10    
lenIn           equ     $-InBuf 	
mas             resd	25         ; размер матрицы 5x5
OutBuf          resb    10


        section .text
        global  _start
_start:
        ; вывод сообщения "Enter matrix 5x5"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msg2    
        mov     edx, lenmsg2  
        int     80h

        mov ecx, 25
        mov ebx, 0

        ; заполнение 25 элементов матрицы 5x5
cycleIn:
        push ecx
        push ebx

        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf   
        mov edx, lenIn
        int 80h

        mov esi, InBuf
        call StrToInt

        pop ebx
        mov [mas + ebx * 4], eax

        pop ecx
        inc ebx
 	loop cycleIn


        ; вывод матрицы построчно
        mov ecx, 5
        mov ebx, 0
cycleOut11:
        push ecx
        mov ecx, 5
cycleOut12:
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
                loop cycleOut12

        push ebx

        ; вывод перехода на новую строку
        mov     eax, 4 
        mov     ebx, 1
        mov     ecx, ENDL    
        mov     edx, 1 
        int     80h 

        pop ebx

        pop ecx
        loop cycleOut11

        ; вывод сообщения "Enter row"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msg    
        mov     edx, lenmsg  
        int     80h

        ; ввод номера строки 
        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf   
        mov edx, lenIn
        int 80h


        ; проверка введенных данных

        mov esi, InBuf
        call StrToInt
        dec eax   
        
        cmp eax, 4      ; ввели номер столбца, которого не существует - ошибка
        jg error                        
        cmp eax, 0      ; ввели отрицательный номер столбца - ошибка
        jl error
                              ; нумерация с нуля, поэтому уменьшаем на 1
        imul dword[byte_in_row]         ; т.к. в одной строке 5 элементов по 4 байта
        mov edi, eax


        ; СОРТИРОВКА ПУЗЫРЬКОМ
        ; eax - количество перестановок
        ; ebx - итерация по столбцам
        ; edi - фиксация введенной строки = (<веденная строка> - 1) * 20
        mov eax, 1
sort:
        cmp eax, 0      ; пока количество перестановок не равно 0
        je continue
                mov eax, 0      
                mov ebx, 0
                mov ecx, 4
cycleswap:
                mov esi, [edi + ebx * 4 + mas]
                inc ebx
                cmp esi, [edi + ebx * 4 + mas]
                jle skip
                        ; swap
                        inc eax
                        push dword[edi + ebx * 4 + mas]
                        mov [edi + ebx * 4 + mas], esi
                        dec ebx
                        pop dword[edi + ebx * 4 + mas]
                        inc ebx
                skip:
                loop cycleswap

                jmp sort
continue:


        ; вывод обработанной матрицы
	mov ecx, 5
	mov ebx, 0
cycleOut21:
	push ecx
	mov ecx, 5
cycleOut22:
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
                loop cycleOut22

        push ebx

        mov     eax, 4 
        mov     ebx, 1
        mov     ecx, ENDL    
        mov     edx, 1 
        int     80h 

        pop ebx

        pop ecx
        loop cycleOut21

        jmp exit
error:
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msgerror    
        mov     edx, lenmsgerror
        int     80h

exit:
        mov     eax, 1          
        xor     ebx, ebx       
        int     80h


%include "./lib_2.asm"   