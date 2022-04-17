        section .data   
n               dd 2    ; ���������� �����
m               dd 3    ; ���������� �������� 
bit             dd 4    ; ����������� �������
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
nm              resd    1       ; ���������� ��������� �������
mas             resd    100
InBuf           resb    10      ; ��������� ������� �������         
lenIn           equ     $-InBuf
OutBuf          resb    10

        section .text
        global  _start
_start:
        ; ��������� "Enter number of rows and columns"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, request     
        mov     edx, lenReq  
        int     80h

        ; ���� ���������� ����� [n]
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

        ; ���� ���������� ������� [m]
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

        ; ��������� "Enter elements of matrix n x m"
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msginput     
        mov     edx, lenMsgInput  
        int     80h

        mov eax, [n]
        mul dword[m]            ; � EAX - ���������� ���� ��������� ������� 6 * 5 = 30
        mov dword[nm], eax      ; ������� 30 � ������ [nm]

        mov ecx, [nm]           ; ����� �������� �������� (index) 
        jcxz end_loop_input             
                                ; ���� ����� 6 * 5 ����� � ��������� � ������ mas
loop_input:           
                push ecx        ; stack <

                ; ������ ����� � �������
                mov eax, 3
                mov ebx, 0
                mov ecx, InBuf   
                mov edx, lenIn
                int 80h

                ; ����� "124\n", ����� ����� ������������� � �������� ��������

                mov esi, ecx    ; ����� ������, ������� ����� �������������� � �����
                call StrToInt   ; ��������������� �� ������ ����� ��������� � EAX

                cmp EBX, 0    
                jne error  
                                ; ���� EBX = 0, �� ��������� ������, 1 � �������� ������ 
                                ; (����������. ������, ����� �� ������� ��������� �����)

                pop ecx         ; stack >

                mov edx, dword[nm]
                sub edx, ecx    ; edx - ������ �������, � ������� ����� �������� ��������� ��������
                                ; ���������� ����� - ����� ��������


                mov [mas + edx * 4], eax

                loop loop_input        
end_loop_input:


        ; �����
        mov ecx, [n]     ; ����� ������� ���������
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

                ; ����� �������� �� ����� ������
                mov     eax, 4  
                mov     ebx, 1
                mov     ecx, endline    
                mov     edx, 1 
                int     80h 

                pop ebx

                pop ecx
        loop cycleOut1



        ; ����� ��������� "Enter column number"

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, message     
        mov     edx, lenMsg  
        int     80h

        ; ���� ������ �������, ������� ���������� �������

        mov     eax, 3          
        mov     ebx, 0          
        mov     ecx, InBuf      
        mov     edx, lenIn      
        int     80h                   

        mov esi, ecx            ; ����� ������ � ������� ���������� �������

        call StrToInt           ; � eax - ������������� ����� ������� 
                                ; (��� ��������� � ���� - ����� ���������� �������)

        cmp EBX, 0                       
        jne error

        cmp eax, dword[m]       ; ����� ����� �������, �������� �� ���������� - ������
        jg error                        
        cmp eax, 1              ; ����� ������������� ����� ������� - ������
        jl error

        mov ecx, dword[m]       ; ecx = ���������� �������
        sub ecx, eax            ; ���-�� �������� - ����� ���������� ������� = ���-�� �������� ����� ���������� (ecx)



        ; ������� ���� - ����������� �� ��������
        ; ���������� ���� - ����������� �� �������

        jcxz end_loop_logic

outer_loop_logic:         
                push ecx
                mov ebx, 0      ; ebx - �������� �� �������
                mov ecx, [n]     

inner_loop_logic:
                        mov edx, [ebx + eax * 4 + mas]          ; ���������� �������� �� ������� � ������� edx
                        dec eax                                 ; ��������� �� ���������� �������    
                        mov dword[ebx + eax * 4 + mas], edx     ; ������� �������� edx � ���������� �������
                        inc eax                                 ; ��������� �� �������� �������

                        ; ������� �� ����� �������

                        push eax        ; stack <                                                        
                        mov eax, [m]
                        mul dword[bit]  ; eax = [n] * 4 = �������� �� ��������� ������
                        add ebx, eax    ; ��������� �� ��������� ������ (5 ��������� * 4 �����)
                        pop eax         ; stack >

                        loop inner_loop_logic

                inc eax         ; ������������ �� ��������� �������
                pop ecx            

                loop outer_loop_logic

end_loop_logic:


        ; ������� ������ ������ (����� ��� �����������)

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, endline     
        mov     edx, 1  
        int     80h  

        mov edi, 0              ; edi - �������� �� �������
        mov ecx, [n]    

outer_loop_output:
                push ecx          
                mov ecx, [m] 
                dec ecx         ; ���������� �������� ����������� �� 1, ������� �������� �������������� 
                mov ebx, 0      ; ebx - ����� �������

inner_loop_output:                  
                        push ecx                ; stack <  

                        mov eax, [edi + ebx * 4 + mas]   ; ���������� ������� �� ������� (����������� ���������)
                        call IntToStr                    ; ������������ ������� � ������

                        push ebx                ; stack <
                        
                        ; ������� �����
                        mov     eax, 4          
                        mov     ebx, 1          
                        mov     ecx, esi     
                        mov     edx, 4  
                        int     80h    

                        pop ebx                 ; stack >
                        inc ebx                 ; ������� � ���������� �������

                        pop ecx                 ; stack >
                        loop inner_loop_output

        ; ������� ������ ������ (��� ����������� ���������� ������ �������) 

        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, endline     
        mov     edx, 1  
        int     80h  

        ; ������� �� ����� �������

        mov eax, [m]
        mul dword[bit]          ; eax = [n] * 4 = �������� �� ��������� ������
        add edi, eax            ; ��������� �� ��������� ������ (5 ��������� * 4 �����)

        pop ecx    
        loop outer_loop_output

        jmp exit
    

error:
        ; ����� ��������� "Error" 
        mov     eax, 4          
        mov     ebx, 1          
        mov     ecx, msgError     
        mov     edx, lenMsgError  
        int     80h     
exit:
        ; exit
        mov     eax, 1          ; ��������� ������� 1 (exit)
        xor     ebx, ebx        ; ��� �������� 0    
        int     80h             ; ����� ��������� �������

%include "./lib.asm"