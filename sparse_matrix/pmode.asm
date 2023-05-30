	.code 
public pr_tree
	.code
	
pr_tree proc
	push ebp
	mov	 ebp, esp
	
	push eax
	push edi

	
	mov edi, [ebp +  8]
	cmp [edi], 0
	jne ENDEND
	outstr 'Node '
	outint [edi]
	outstr '; Key: ('
	outint [edi + 4]
	outstr ', '
	outint [edi + 8]
	outstr '); Value: '
	movzx eax, [edi + 12]
	outu eax
	outstr ' | L: '
	cmp [edi + 14], 0 
	jne NO_L 
	;  write(a^.left^.node_number)
	jmp R
NO_L:
	outstr 'NULL'
R:  cmp [edi + 18], 0 
	jne NO_R 
	;  write(a^.left^.node_number)
	jmp NEXT
NO_R:
	outstr 'NULL'
NEXT:  
	newline
	cmp [edi + 14], 0 
	jne RT
	push [edi + 14]
	call pr_tree
RT: cmp [edi + 18], 0 
	jne ENDEND
	push [edi + 18]
	call pr_tree
ENDEND:

	pop edi

	pop eax
	pop ebp
	
	ret 4
pr_tree endp
