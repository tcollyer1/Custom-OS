; A simple printing function that prints any byte sequence stored in bx (in 16-bit mode) 
; using INT 10h.

display:
	mov ah, 0x0e			; Scrolling teletype mode (for printing)
	loop:
		cmp [bx], byte 0	; Check if at end of string (it's null-terminated, so compare with 0)
		je exit
		mov al, [bx]		; Move current char bx is pointing at from byte array to al register for printing
		int 0x10			; INT 10h. Interrupt required for scrolling teletype mode
		inc bx
		jmp loop
	exit:
		ret					; Pop return address off stack and jump back to it (call display)

bootMsg:
	db 'Boot program loaded (16-bit real mode). ', 0x0d, 0xa, 0 ; Carriage return & new line, then null terminate byte sequence