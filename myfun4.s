	section .data
	segment .bss
bufer resb 256
	section .text
	
	global remlastnum
remlastnum:
    push ebp
    mov ebp, esp
	push ebx
	push esi
	
	mov ecx, [ebp + 8]	;save char* arg to ECX
	mov eax, bufer        ;register to copy from
	mov ebx, 0x0
	mov esi, 0x0
search:
    mov dl, [ecx]	;take first byte of arg to dl
	test dl, dl
	jz	delete			;if end of string, go to delete
	cmp dl, '0'         ;check if less than 0
    jl  next            ;if less, go next
    cmp dl, '9'         ;check if more than 9
    jle  remember  		;remember this address
next:
	inc ecx				;go to the next byte
	jmp search			;repeat
	
	
remember:
	mov ebx, ecx 	;remember the start of the last number in ebx
findEnd:
	inc ecx			;go to the next byte
	mov dl, [ecx] 	;take it
	test dl, dl		
	jz	delete		;if end of string, go to delete
	cmp dl, '0'         ;check if less than 0
    jl  next2            ;if less, go next2
    cmp dl, '9'         ;check if more than 9
    jle  findEnd
next2:
	mov esi, ecx 	;remember in esi the one after the last one to be removed
	inc ecx			
	jmp search		;and search for the next one
	
	
delete:
	mov ecx, [ebp + 8] ;reset pointer at ecx
loop:
	mov dl, [ecx]	;take first byte of string to dl
	test dl, dl
	jz	end			;if end of string, go end
	cmp ecx, ebx         ;check if this is the char that we want to omit
    jz  omit            ;if yes, go to omit section
	mov [eax], dl
	inc	ecx
	inc eax
	jmp loop
omit:
	cmp ebx, esi
	jg	end			;if the end of the number wasnt detected, go end
	
	test esi, esi ;
	jz end
	
	mov ecx, esi
	jmp loop
	
end:
	mov byte [eax], 0x0
    mov eax, bufer	
	pop esi
	pop ebx
	mov esp, ebp
    pop ebp
    ret