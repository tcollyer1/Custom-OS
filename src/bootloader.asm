[org 0x7c00] ; Specify the origin address that the program expects to be loaded into, so that calculated offsets are from this point of reference

mov bp, 0x7c00 ; BIOS loads this program into address 0x7c00 because memory addresses 0x7c00-0x7dff are reserved for the boot sector. So, load this address to indicate base of the stack
mov sp, bp ; Stack pointer - start at the base

mov bx, outputStr ; Store address of outputStr section so we can access its result easily
call display ; Store address of current line, jump to label display, then resume from saved address afterwards

jmp $ ; Repeat until interrupted

display:
	mov ah, 0x0e ; Scrolling teletype mode (for printing)
	loop:
		cmp [bx], byte 0 ; Check if at end of string (it's null-terminated, so compare with 0)
		je exit
		mov al, [bx] ; Move current char bx is pointing at from byte array to al register for printing
		int 0x10 ; INT 10h. Interrupt required for scrolling teletype mode
		inc bx
		jmp loop
	exit:
		ret ; Pop return address off stack and jump back to it (call display)

outputStr:
	db 'Welcome to the bootloader', 0 ; Null terminate byte sequence

; Must always be at the end
times 510-($-$$) db 0 ; Pad 510 bytes with 0
dw 0xaa55 ; Define end of bootloader with remaining 2 bytes of 512-byte bootloader