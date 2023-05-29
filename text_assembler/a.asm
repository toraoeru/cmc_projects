include console.inc

MAXLEN equ 513

.data

text1 db MAXLEN dup (?)
text2 db MAXLEN dup (?)
text1len dw ?
text2len dw ?

.code

PrintText proc
	push ebp
	mov ebp, esp
	push ebx
	push eax


	mov ebx, [ebp + 8]
	outstrln '"""'

PrLoop:
	mov al, [ebx]
	cmp al, '"'
	jne Cont
	cmp byte ptr [ebx + 1], '"'
	jne Cont
	cmp byte ptr [ebx + 2], '"'
	jne Cont
	outchar '\'

Cont:
	outchar al
	add ebx, 1
	cmp al, 0
	jne PrLoop
	outstr '"""'
	newline

	pop eax
	pop ebx
	pop ebp
	ret 4
PrintText endp


ReadText proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	push edi;сколько считано из стека
	push esi;сколько в стеке

	push dword ptr 0
	mov ebx, [ebp + 8]
	mov ecx, [ebp + 12]
	xor eax, eax

Read:
	inchar al

FinCheck:
	cmp al, '-'
	jne SlashCheck

	mov esi, 1
	push eax

	inchar al
	add esi, 1
	push eax
	cmp al, ':'
	jne NotFin

	inchar al
	add esi, 1
	push eax
	cmp al, 'f'
	jne NotFin

	inchar al
	add esi, 1
	push eax
	cmp al, 'i'
	jne NotFin

	inchar al
	add esi, 1
	push eax
	cmp al, 'n'
	jne NotFin

	inchar al
	add esi, 1
	push eax
	cmp al, ':'
	jne NotFin

	inchar al
	add esi, 1
	push eax
	cmp al, '-'
	jne NotFin

	cmp dword ptr [ebp - 24], 1
	jne Fin
	mov dword ptr [ebp - 24], 2
	jmp NotFin

SlashCheck:
	cmp al, '\'
	jne NotSlash
	cmp dword ptr [ebp - 24], 1
	jne SlashEnc
	mov dword ptr [ebp - 24], 0
	jmp WriteInText

SlashEnc:
	mov dword ptr [ebp - 24], 1
	jmp Read

NotSlash:
	cmp dword ptr [ebp - 24], 1
	jne WriteInText
	mov dword ptr [ebp - 24], 0
	cmp al, '0'
	jl WriteInText
	cmp al, '9'
	jle FirstNumber
	cmp al, 'a'
	jl WriteInText
	cmp al, 'f'
	jg WriteInText

FirstLetter:
	mov ah, al
	inchar al
	cmp al, '0'
	jl NotCode
	cmp al, '9'	
	jle LetterNumber
	cmp al, 'a'
	jl NotCode
	cmp al, 'f'
	jg NotCode
	sub ah, 'a'; в ah и al буквы => это код символа
	add ah, 10
	shl ah, 4; ah * 16
	sub al, 'a'
	add al, 10
	add al, ah
	sub ah, ah
	jmp WriteInText

LetterNumber:
	sub ah, 'a'; в ah буква, al - цифра => это код символа
	add ah, 10
	shl ah, 4; ah * 16
	sub al, '0'
	add al, ah
	sub ah, ah
	jmp WriteInText
	
FirstNumber:
	mov ah, al
	inchar al
	cmp al, '0'
	jl NotCode
	cmp al, '9'	
	jle NumberNumber
	cmp al, 'a'
	jl NotCode
	cmp al, 'f'
	jg NotCode
	sub ah, '0'; в ah цифра, в al буква
	shl ah, 4; * 16
	sub al, 'a'
	add al, 10
	add al, ah
	sub ah, ah
	jmp WriteInText

NumberNumber:
	sub ah, '0'
	shl ah, 4; * 16
	sub al, '0'
	add al, ah
	sub ah, ah
	jmp WriteInText

NotCode:
	mov [ebx], ah
	sub ah, ah
	add ebx, 1
	sub ecx, 1
	cmp ecx, 0
	jne FinCheck
	jmp ReadError

WriteInText:
	mov [ebx], al
	add ebx, 1
	sub ecx, 1
	cmp ecx, 0
	jne Read
	jmp ReadError


NotFin:
	sub ecx, esi
	cmp dword ptr [ebp - 24], 2
	jne FinNotComplete
	cmp ecx, 0
	jg WriteFromStack
	jle ClearStackErr

FinNotComplete:
	cmp ecx, -1
	jg WriteFromStack
	jl ClearStackErr
	cmp al, '-'; если последний символ '-' то потом может быть fin
	jne ClearStackErr
	cmp dword ptr [ebp + 24], 1
	jne WriteFromStack


ClearStackErr:
	pop eax
	sub esi, 1
	cmp esi, 0
	jne ClearStackErr
	jmp ReadError
 
WriteFromStack:
	mov edi, 1
	mov edx, ebp
	sub edx, 24


WriteFromStackLoop:
	sub edx, 4
	mov eax, [edx]
	mov [ebx], al
	add edi, 1
	add ebx, 1
	cmp edi, esi
	jne WriteFromStackLoop
	sub edx, 4
	mov eax, [edx]; в al последний символ

ClearStackOK:
	pop edi
	sub esi, 1
	cmp esi, 0
	jne ClearStackOK

	cmp dword ptr [ebp - 24], 2
	jne LastElem
	mov [ebx], al
	add ebx, 1
	mov [ebp - 24], dword ptr 0
	jmp Read


LastElem:
	mov [ebp - 24], dword ptr 0
	add ecx, 1; последний символ еще не записан
	cmp ecx, 1
	jne FinCheck
	sub ecx, 1
	jmp FinCheck


Fin:
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax

	mov [ebx], byte ptr 0
	cmp ebx, [ebp + 8]
	je ReadError
	mov al, 0
	jmp ReadEnd

ReadError:
	xor eax, eax
	mov al, 1


ReadEnd:
	pop esi
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop ebp
	ret 8
ReadText endp



Metric proc

	push ebp
	mov ebp, esp
	push ebx
	push ecx

	mov ecx, [ebp + 8]
	xor eax, eax

Read:
	mov ebx, [ecx]
	cmp bl, 0
	je MetricEnd
	cmp bl, 020h
	je IncLen
	cmp bl, 09h
	jb Cont
	cmp bl, 0Dh
	ja Cont

IncLen:
	inc eax

Cont:
	inc ecx
	jmp Read

MetricEnd:
	pop ecx
	pop ebx
	pop ebp
	ret 4
Metric endp


TransformShort proc
; пролог
	push ebp
	mov ebp, esp
	push ebx
	push eax
	push ecx

	mov ebx, [ebp + 8]
	xor eax, eax
	mov cl, 10
	
Read:
	mov al, [ebx]
	cmp al, 0
	je TransformEnd
	cmp al, 'a'
	jb Cont
	cmp al, 'z'
	ja Cont
	sub al, 'a'
	movzx ax, al
	idiv cl
	cmp ah, 9
    jne NZ
    mov ah, '0'
    jmp Z
NZ: add ah, '1'
Z:  mov [ebx], ah
	jmp Cont

Cont:
	add ebx, 1
	jmp Read

TransformEnd:
	pop ecx
	pop eax
	pop ebx
	pop ebp
	ret 4
TransformShort endp


FindTextLength proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx

	mov ebx, [ebp + 8]
	xor eax, eax

L:
	mov cl, [ebx]
	cmp cl, 0
	je Fin
	inc ebx
	inc eax
	jmp L

Fin:
	pop ecx
	pop ebx
	pop ebp
	ret 4
FindTextLength endp


TransformLong proc
	push ebp
	mov ebp, esp
	push ebx
	push eax
	push ecx
	push edx

	mov ax, word ptr [ebp + 12]
	mov bx, 2
	xor dx, dx
	div bx
	movzx ecx, ax; в ecx количество повторений цикла (i/2)
	
	mov ebx, [ebp + 8]
	movzx eax, word ptr [ebp + 12]; длина текста
	add eax, ebx
	sub eax, 1
	xor edx, edx

L:
	mov dl, [ebx]
	xchg dl, byte ptr [eax]
	mov [ebx], dl
	inc ebx
	dec eax
	Loop L
	

TransformEnd:
	pop edx
	pop ecx
	pop eax
	pop ebx
	pop ebp
	ret 8
TransformLong endp

Start:
	ClrScr

	outstrln "Please input two texts."
	outstrln "Short text: rule 2) Replace each lowercase letter with the last digit of its number in the alphabet"
	outstrln "Long text: rule 1) Write the text backwards"
	outstrln "Metrics 3: Whitespace characters"
	
	newline
	outstrln "First text:"
	push MAXLEN
	push offset text1
	call ReadText

	cmp al, 1
	je ReadError

	newline
	outstrln "Second text:"
	inchar al; иначе во 2 тексте появляется перенос строки в начале
	push MAXLEN
	push offset text2
	call ReadText

	cmp al, 1
	je ReadError

	newline
	
	push offset text1
	call FindTextLength
	mov text1len, ax

	push offset text2
	call FindTextLength
	mov text2len, ax

	push offset text1
	call Metric
	outstr "Text 1 Length: "
	outwordln eax
	mov ebx, eax
	push offset text2
	call Metric
	outstr "Text 2 Length: "
	outwordln eax

	newline

	cmp ebx, eax
	jge FirstLonger


	push offset text1
	call TransformShort
	push text2len
	push offset text2
	call TransformLong
	jmp PrintTransformed

FirstLonger:
	push offset text2
	call TransformShort
	push text1len
	push offset text1
	call TransformLong
	jmp PrintTransformed

PrintTransformed:
	outstrln "New first text: "
	push offset text1
	call PrintText
	newline
	
	outstrln "New second text: "
	push offset text2
	call PrintText
	newline
	
	outstrln "Program ended"
	exit 0

ReadError:
	outstrln "Input Error"
	exit 1

end Start;
