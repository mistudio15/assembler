	global _Z7FuncStrPKcii
	extern _Z5printPc

	section .bss

str2	resb	255

	section .text
_Z7FuncStrPKcii:
	; пролог
	push rbp
	mov rbp, rsp

        ; параметры функции: rdi - строка, rsi - a, rdx - b

	; подготовка регистров

	mov rcx, 0 	; count - счетчик слов
	mov r8, rsi	; a - позиция первого слова
	mov r9, rdx 	; b - позиция второго слова
	mov rsi, rdi 	; str - исходная строка 
	mov rdi, str2 	; str2 - измененная строка
	mov bx, 1 	; f = true;
        mov dx, 1       ; existMiddle = true;  

	; r10 - left
	; r11 - middle
	; r12 - right
	; r13 - finally

        ;          ->          <-
        ; " hello world i am mikhail table pen"
 	;         ^     ^    ^       ^ 
	;         l     m    r       f 

        ; " hello world i am\nmikhail table pen\n"

        ; установка existMiddle
        push r9         ; stack >
        sub r9, r8
        cmp r9, 1      
        pop r9          ; stack <
        jne cycle
        mov dx, 0
cycle:
	cmp bx, 1
	jne fill_full
		cmp byte[rsi], 20h
		jne fill_begin

                ; обрабатываем <пробел>

		inc rcx
		cmp rcx, r8     ; if (count == a)
                jl fill_begin
		jg middle
		inc rsi	        ; переходим на <символ> 	
		mov r10, rsi    ; r10 - left
		jmp next_sym
middle:
                inc rsi	        ; переходим на <символ> 
                cmp dx, 1       ; if (existMiddle && count == a + 1)
                jne right

		push r8         ; stack <
		inc r8
		cmp rcx, r8
		pop r8          ; stack >
		jne right
		mov r11, rsi    ; r11 - middle
		jmp next_sym

right:
		cmp rcx, r9     ; if (count == b)
		jne finally
		
		mov r12, rsi    ; r12 - right

                cmp dx, 1       ; if (existMiddle)
                jne next_sym
		dec rsi         ; перед right ставим \n
		mov byte[rsi], 10
		inc rsi

		jmp next_sym

finally:	
		push r9         ; stack <
		inc r9
		cmp rcx, r9     ; if (count == b + 1)
		pop r9          ; stack <
		jne next_sym
		mov r13, rsi    ; r13 = finally
		mov bx, 0       ; f = false;

                ; заполняем начало (до слова left)
fill_begin:
		cmp rcx, r8  
                jge next_sym
		movsb           ; из rsi в rdi пересылаем символ 
	        jmp cycle
next_sym:
                inc rsi
                jmp cycle

fill_full:

        ; перемещаемся по rsi через r10 - r13
        ; заполняем rdi

        ; "<begin> <right>"
	mov byte[rdi], 20h      ; str2[cur2++] = ' ';       
	inc rdi
	mov rsi, r12            ; r12 - right
r_cycle:
	cmp byte[rsi], 20h      ; while(right[i] != ' ')
	je end_r_cycle
	movsb
	jmp r_cycle 
end_r_cycle:

        ; "<begin> <right> <middle>"
        cmp dx, 1               ; if (existMiddle)
        jne not_exist_middle
	mov byte[rdi], 20h
	inc rdi
	mov rsi, r11            ; r11 - middle
m_cycle:
	cmp byte[rsi], 10       ; while(middle[i] != '\n')
	je end_m_cycle
	movsb
	jmp m_cycle 
end_m_cycle:

not_exist_middle:

        ; "<begin> <right> <middle> <left>"
	mov byte[rdi], 20h
	inc rdi
	mov rsi, r10            ; r10 - left
l_cycle:
	cmp byte[rsi], 20h      ; while(left[i] != ' ')
	je end_l_cycle
	movsb
	jmp l_cycle 
end_l_cycle:

        ; "<begin> <right> <middle> <left> <finally>"
	mov byte[rdi], 20h
	inc rdi
	mov rsi, r13            ; r10 - finally
f_cycle:
	cmp byte[rsi], 10       ; while(finally[i] != '\n')
	je end_f_cycle
	movsb
	jmp f_cycle 
end_f_cycle:
        
	mov byte[rdi], 10       ; последний символ "\n"
        
        mov rdi, str2           ; возвращаем rdi на первый символ
        inc rdi
	call _Z5printPc

	; эпилог		
	mov rsp, rbp
	pop rbp
	ret