include console.inc

MAXLEN equ 513

.data

text1 db MAXLEN dup (?)
text2 db MAXLEN dup (?)
text1len dw ?
text2len dw ?

.code


print proc
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
	outchar '\'; если в тексте """

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
print endp

; в al 0, если прочитан удачно
read proc
	push ebp
	mov ebp, esp
	push ebx
	push ecx
	push edx
	push edi
	push esi

	push dword ptr 0; 0 если не было слэша, 1 если был, 2 если после него -:fin:-
	mov ebx, [ebp + 8]; указатель на текущий элемент
	mov ecx, [ebp + 12]; MAXLEN
	xor eax, eax

Read:
	inchar al

FinCheck:
	cmp al, '-'; проверяем на fin
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

	cmp dword ptr [ebp - 24], 1; был ли \?
	jne Fin; слеша не было, признак конца текста
	mov dword ptr [ebp - 24], 2; fin полностью
	jmp NotFin

SlashCheck:
	cmp al, '\'
	jne NotSlash
	cmp dword ptr [ebp - 24], 1; был ли \ до этого?
	jne SlashEnc
	mov dword ptr [ebp - 24], 0
	jmp WriteInText

SlashEnc:
	mov dword ptr [ebp - 24], 1; встретили \
	jmp Read

NotSlash:
	cmp dword ptr [ebp - 24], 1; был ли \?
	jne WriteInText
	mov dword ptr [ebp - 24], 0; в al символ, следующий за \
	cmp al, '0'
	jl WriteInText
	cmp al, '9'
	jle FirstNumber; после \ цифра
	cmp al, 'a'
	jl WriteInText
	cmp al, 'f'
	jg WriteInText

; обработка кода символа после \
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
	mov [ebx], ah; записать в память
	sub ah, ah
	add ebx, 1; указатель на следующий символ
	sub ecx, 1; MAXLEN - 1
	cmp ecx, 0; максимальная длина?
	jne FinCheck
	jmp ReadError

WriteInText:
	mov [ebx], al; запись в память
	add ebx, 1; указатель на следующий символ
	sub ecx, 1; MAXLEN - 1
	cmp ecx, 0; максимальная длина?
	jne Read
	jmp ReadError

; в стеке не fin
NotFin:
	sub ecx, esi; вычитаем количество символов в стеке
	cmp dword ptr [ebp - 24], 2; полностью ли fin в стеке?
	jne FinNotComplete
	cmp ecx, 0
	jg WriteFromStack
	jle ClearStackErr; если при добавлении символов из стека переполнение

FinNotComplete:
	cmp ecx, -1; проверка на переполнение
	jg WriteFromStack
	jl ClearStackErr
	cmp al, '-'; если последний символ '-' то потом может быть fin
	jne ClearStackErr
	cmp dword ptr [ebp + 24], 1; был ли \?
	jne WriteFromStack

; очистить стек, вернуть ошибку
ClearStackErr:
	pop eax
	sub esi, 1
	cmp esi, 0
	jne ClearStackErr
	jmp ReadError

; очистить стек, записать в память
WriteFromStack:
	mov edi, 1
	mov edx, ebp
	sub edx, 24

WriteFromStackLoop:
	sub edx, 4; изначально ebp - 28 - указатель на первый элемент в стеке
	mov eax, [edx]
	mov [ebx], al; запись в текст
	add edi, 1
	add ebx, 1
	cmp edi, esi
	jne WriteFromStackLoop; повторяем если стек не пуст
	sub edx, 4
	mov eax, [edx]; в al последний символ

ClearStackOK:
	pop edi
	sub esi, 1
	cmp esi, 0
	jne ClearStackOK; очищаем стек

	cmp dword ptr [ebp - 24], 2; проверка на \ (fin после \)
	jne LastElem
	mov [ebx], al; запишем все
	add ebx, 1
	mov [ebp - 24], dword ptr 0; слеш отработан
	jmp Read

; если последний элемент - и после него fin то все ок
LastElem:
	mov [ebp - 24], dword ptr 0
	add ecx, 1; последний символ еще не записан
	cmp ecx, 1
	jne FinCheck
	sub ecx, 1
	jmp FinCheck; если после будет идти не fin то ошибка

; очистить стек, выйти после fin
Fin:
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax
	pop eax

	mov [ebx], byte ptr 0
	cmp ebx, [ebp + 8]; текст пустой?
	je ReadError
	mov al, 0; считано удачно
	jmp ReadEnd

ReadError:
	xor eax, eax
	mov al, 1; при чтении ошибка, возвращаем 1

; эпилог
ReadEnd:
	pop esi
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx
	pop ebp
	ret 8
read endp

; длина текста по метрике 3: количество пробельных символов
; пробельные символы - символы с кодами 9-13 и 32 (в десятичной системе)
Metric proc
; пролог
	push ebp
	mov ebp, esp
	push ebx
	push ecx

; начало
	mov ecx, [ebp + 8]; в ecx указатель на начало текста
	xor eax, eax

Read:
	mov ebx, [ecx]; в bl рассматриваемый элемент
	cmp bl, 0
	je MetricEnd; конец текста
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

; эпилог
MetricEnd:
	pop ecx
	pop ebx
	pop ebp
	ret 4
Metric endp

; преобразование короткого текста: A -> B, ..., Z -> A
TransformShort proc
; пролог
	push ebp
	mov ebp, esp
	push ebx
	push eax

; начало
	mov ebx, [ebp + 8]; в ebx указатель на начало текста
	xor eax, eax

Read:
	mov al, [ebx]
	cmp al, 0
	je TransformEnd
	cmp al, 'A'
	jb Cont
	cmp al, 'Z'
	ja Cont
	je Z
	add al, 1
	mov [ebx], al
	jmp Cont

Z:
	mov [ebx], byte ptr 'A'

Cont:
	add ebx, 1
	jmp Read

; эпилог
TransformEnd:
	pop eax
	pop ebx
	pop ebp
	ret 4
TransformShort endp

; находит фактическую длину текста (не по метрике)
FindTextLength proc
; пролог
	push ebp
	mov ebp, esp
	push ebx
	push ecx

; начало
	mov ebx, [ebp + 8]; в ebx указатель на начало текста
	xor eax, eax

L:
	mov cl, [ebx]
	cmp cl, 0
	je Fin
	inc ebx
	inc eax
	jmp L

; эпилог
Fin:
	pop ecx
	pop ebx
	pop ebp
	ret 4
FindTextLength endp

TransformLong proc
; пролог
	push ebp
	mov ebp, esp
	push ebx
	push eax
	push ecx
	push edx

; начало
	mov ax, word ptr [ebp + 12]; длина текста
	mov bx, 2
	xor dx, dx
	div bx
	movzx ecx, ax; в ecx количество повторений цикла (i/2)
	
	mov ebx, [ebp + 8]; в ebx указатель на начало текста
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
	
; эпилог
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
	outstrln "Short text: rule 3) Replace each uppercase Latin letter with the one following it alphabetically"
	outstrln "Long text: rule 1) Write the text backwards"
	outstrln "Metrics 3: Whitespace characters"
	
; чтение первого текста
	newline
	outstrln "First text:"
	push MAXLEN
	push offset text1
	call read

	cmp al, 1
	je ReadError
	; outstrln "Read Text 1"

; чтение второго текста
	newline
	outstrln "Second text:"
	inchar al; иначе во 2 тексте появляется перенос строки в начале
	push MAXLEN
	push offset text2
	call read

	cmp al, 1
	je ReadError
	; outstrln "Read Text 2"

	newline

; вычисление фактических длин текстов
	push offset text1
	call FindTextLength
	mov text1len, ax

	push offset text2
	call FindTextLength
	mov text2len, ax

; вычисление длин текстов по метрике
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

; сравнение длин текстов
	cmp ebx, eax
	jge FirstLonger

; первый короче
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
	call print
	newline
	
	outstrln "New second text: "
	push offset text2
	call print
	newline
	
	outstrln "Program ended"
	exit 0

ReadError:
	outstrln "Input Error"
	exit 1

end Start;
