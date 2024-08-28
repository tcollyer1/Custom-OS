; 32-bit string display - writes directly to video memory.

video_memory equ 0xb8000

display32:
	mov ebx, str32			; Move string to ebx
	mov ecx, video_memory	; Start of VGA text buffer
	loop32:
		cmp [ebx], byte 0	; Check if at end of string (it's null-terminated, so compare with 0)
		je exit32
		mov al, [ebx]		; Move to 8-bit register so an explicit byte can be written to the memory address
		mov [ecx], al		; Write to video memory
		add ecx, 2			; Increment address by 2 - addresses in between are for text formatting
		inc ebx				; Increment to process next byte in our byte array (string)
		jmp loop32
	exit32:
		ret					; Pop return address off stack and jump back

; String to display in 32-bit mode
str32:
	db '32-bit display mode :) ', 0