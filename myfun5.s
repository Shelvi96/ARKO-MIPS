	section .data
	segment .bss
bufer resb 256
	section .text
	
	global reverselet
reverselet:
    push ebp
    mov ebp, esp
	push ebx
	
	mov ecx, [ebp + 8]	;save char* arg to ECX
	mov eax, bufer        ;register to copy from
	mov ebx, 0x0
findEnd: ;find the end of the string
    mov dl, [ecx]	;take first byte of arg to dl
	test dl, dl
	jz	searchBeg			;if end of string, go to delete
	inc ecx
	jmp findEnd
	
searchBeg:
	mov ebx, ecx
	mov ecx, [ebp + 8]
loop:
	mov dl, [ecx]
	inc ecx
	test dl, dl
	jz	end
;now check if it is a letter or not	
	cmp dl, 'A'
	jl	notLetter
	cmp dl, 'Z'
	jna searchEnd;
	cmp dl, 'a'
	jl	notLetter ;so just put it as the next char
	cmp dl, 'z'
	jna searchEnd;it is a letter, search from back to find what to swap it with
notLetter:
	mov [eax], dl
	inc eax
	jmp loop
	
searchEnd:	
	cmp ebx, [ebp+8]
	jl	end
	mov dh, [ebx]
	dec ebx
;now check if it is a letter or not
	cmp dh, 'A'
	jl	searchEnd
	cmp dh, 'Z'
	jle letter2	
	cmp dh, 'a'
	jl	searchEnd
	cmp dh, 'z'
	jg searchEnd
letter2:
	mov [eax], dh
	inc eax
	jmp loop
	
end:
	mov byte [eax], 0x0
    mov eax, bufer	
	pop ebx
	mov esp, ebp
    pop ebp
    ret