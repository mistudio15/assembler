; сумма элементов в столбце, который вводит пользователь

        section .data
ENDL            db 10
msg             db "Enter column", 10
lenmsg          equ $-msg

msg2            db "Enter matrix 5x5", 10
lenmsg2         equ $-msg2

msg3            db "Sum: "
lenmsg3         equ $-msg3

msgerror        db "Error..."
lenmsgerror     equ $-msgerror

        section .bss  
InBuf           resb    10    
lenIn           equ     $-InBuf 	
mas             resd	25         ; размер матрицы 5x5
OutBuf          resb    10


        section .text
        global  _start
_start:
        ; Вывод сообщение "Enter matrix 5x5"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msg2    
        mov     edx, lenmsg2  
        int     80h

        mov ecx, 25     ; заполнение 25 элементов матрицы 5x5
        mov ebx, 0
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


	mov ecx, 5     ; вывод матрицы построчно
	mov ebx, 0
cycleOut1:
	push ecx
	mov ecx, 5
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
        mov     ecx, ENDL    
        mov     edx, 1 
        int     80h 

        pop ebx

        pop ecx
        loop cycleOut1

        ; вывод сообщения "Enter column"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msg    
        mov     edx, lenmsg  
        int     80h

        ; ввод колонки для подсчета суммы
        mov eax, 3
        mov ebx, 0
        mov ecx, InBuf   
        mov edx, lenIn
        int 80h

        mov esi, InBuf
        call StrToInt
        dec eax         ; индексация с нуля, поэтому введенный номер колонки уменьшаем на 1

        ; проверка введенных данных

        cmp eax, 4      ; ввели номер столбца, которого не существует - ошибка
        jg error                        
        cmp eax, 0      ; ввели отрицательный номер столбца - ошибка
        jl error

        mov ebx, eax    ; итерация по столбцам
        mov edi, 0      ; итерация по строкам
        mov eax, 0      ; аккумулятор
        mov ecx, 5      
cycleProc:
        add eax, [edi + 4 * ebx + mas]
        add edi, 20
        loop cycleProc


        call IntToStr_Endl

        push eax

        ; вывод сообщения "Sum: "
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msg3    
        mov     edx, lenmsg3  
        int     80h

        pop eax

        ; вывод значения EAX после суммирования элементов колонки
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, esi    
        mov     edx, eax  
        int     80h

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