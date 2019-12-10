	section .data
	segment .bss
bufer resb 256
	section .text
	
	global reversepairs
reversepairs:
    push ebp
    mov ebp, esp
	
	mov ecx, [ebp + 8]	;save char* arg to ECX
	mov eax, bufer        ;register to copy from

loop:
    mov dl, [ecx]	;take first byte of arg to dl
	test dl, dl
	jz	end
	inc ecx
	mov dh, [ecx]
	test dh, dh
	jz end2
	inc ecx
	
	mov [eax], dh
	inc eax
	mov [eax], dl
	inc eax
	jmp  loop   
	
end2:
	mov byte [eax], dl
	inc eax
end:
	mov byte [eax], 0x0
    mov eax, bufer	
	mov esp, ebp
    pop ebp
    ret