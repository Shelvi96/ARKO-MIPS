	section .data
	segment .bss
bufer resb 256
	section .text
	
	global remnth
remnth:
    push ebp
    mov ebp, esp
	sub esp, 4
	push ebx ;calling convention, ebx has to remain intact
	
	mov ecx, [ebp + 8]	;save char* arg to ECX
	mov ebx, [ebp + 12]
	mov eax, bufer        ;register to copy from
;	mov dh, 0x0		;initialize counter to 0

	mov dword [ebp-4], ebx
loop:
    mov dl, [ecx]	;take first byte of arg to dl
	mov [eax], dl   ;put it 	
    test dl, dl		;check if last byte
	jz end
	
    inc ecx
	dec ebx
	
    test ebx, ebx
	jnz next
	
	mov ebx, [ebp -4]
	jmp loop
	
next:
	inc eax
	jmp  loop   
	
end:
	mov byte [eax], 0x0
	mov byte [eax], 0x0
    mov eax, bufer
  		
	pop ebx
	mov esp, ebp
    pop ebp
    ret