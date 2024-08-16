; The extended program, accessible via further disk space loaded into memory.
; Here, we also enable 32-bit protected mode so that we can later load in our kernel
; compiled in 32-bit in C++.
;
; Bytes are also written to the screen in 32-bit mode by writing to video memory.

[org 0x7e00] ; Set origin address of new sector

; Enable protected mode
jmp prepareProtectedMode

; Include files
%include "src/asm/displayMsg.asm"
%include "src/asm/gdt.asm"

prepareProtectedMode:
	call enableA20
	cli										; Disables interrupts
	lgdt [gdt]								; Load our GDT descriptor
	mov eax, cr0
	or eax, 1								; Set the bit in this register for 32-bit protected mode
	mov cr0, eax
	jmp code_segment:startProtectedMode		; Use the code segment offset value to jump to startProtectedMode,
											; which is in 32-bit mode

enableA20:
	in al, 0x92		; Load in port 0x92 (A20 gate register)
	or al, 2		; Bitwise OR with binary 10 - bit 1 of 0x92 handles A20. 0 to disable, 1 to enable. Enables regardless of whether it's on or off.
	out 0x92, al	; Output result in al back to port 0x92
	ret

; Establish 32-bit mode code area
[bits 32]

; 32-bit string display - writes directly to video memory
display32:
	mov ebx, str32			; Move string to ebx
	mov ecx, 0xb8000		; Start of VGA text buffer
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

; Protected mode
startProtectedMode:
    mov ax, data_segment		; Update segment registers to point to new data segment
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000			; Update stack pointer (32-bit)
	mov esp, ebp

	; Write directly to video memory in 32-bit mode
	call display32

	jmp $

times 2048-($-$) db 0 ; Pad out 4 further 512-byte sectors with zeroes that the BIOS can read from