	section .data
	segment .bss
bufer resb 256
	section .text
	
    global removerng
removerng:
    push ebp
    mov ebp, esp
	push ebx ;calling convention, ebx has to remain intact
	
	mov ecx, [ebp + 8]	;save char* arg to EAX
	mov bl, [ebp + 12]
	mov bh, [ebp + 16]
    mov eax, bufer        ;register to copy from
loop:
    mov dl, [ecx]	;take first byte of arg to dl
	mov [eax], dl   ;put it 	
    inc ecx
    test dl, dl		;check if last byte
    je  end			; if it is the last, go to end
    cmp dl, bl         ;check if less than a
    jl  next            ;if less, go next
    cmp dl, bh         ;check if more than b
    jle  loop            ;if more, go next loop
next:
	inc eax
	jmp  loop   
	
end:  
    mov eax, bufer
  		
	pop ebx
	mov esp, ebp
    pop ebp
    ret    