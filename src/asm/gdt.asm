; The GDT (global descriptor table) will define our memory segments as we move to operating in 32-bit protected mode.

; Null segment descriptor
gdtNull:
	dq 0 ; The invalid null descriptor as a zeroed 64-bit value

; Code segment descriptor
gdtCode:
	dw 0xffff		; Limit	(l)		(bits 0-15)
	dw 0x0			; Base (l)		(bits 0-15)
	db 0x0			; Base (m)		(bits 16-23)
	db 10011010b	; Flags			(present=1, privilege=00, descriptor type=1 ------> 1001)
					;				(code=1, conforming=0, readable=1, accessed=0 ----> 1010)
	db 11001111b	; Flags			(granularity=1, default=1, long=0, avl=0 ---------> 1100)
					; Limit (h)		(limit @ bits 16-19=1111 or 0xf000 to give 0xf000ffff)
	db 0x0			; Base (h)		(bits 24-31)

; Data segment descriptor
gdtData:
	dw 0xffff		; Limit (l)		(bits 0-15)
	dw 0x0			; Base (l)		(bits 0-15)
	db 0x0			; Base (m)		(bits 16-23)
	db 10010010b	; Flags			(present=1, privilege=00, descriptor type=1 ------> 1001)
					;				(code=0, expand down=0, writable=1, accessed=0 ---> 0010)
	db 11001111b	; Flags			(granularity=1, default=1, long=0, avl=0 ---------> 1100)
					; Limit (h)		(limit @ bits 16-19=1111 or 0xf000 to give 0xf000ffff)
	db 0x0			; Base (h)		(bits 24-31)

gdtEnd: ; This is an empty label that we will use to save the memory address of the very end of the GDT.
		; This is for calculating its entire size, used below.

; GDT descriptor
gdt:
	dw gdtEnd - gdtNull - 1 ; GDT size (16 bits)
	dd gdtNull				; GDT address (32 bits)

; Useful constants
code_segment equ gdtCode - gdtNull ; Code segment descriptor offset
data_segment equ gdtData - gdtNull ; Data segment descriptor offset

; Establish 32-bit mode code area - we'll be calling this to operate in 64-bit mode, from
; 32-bit mode
[bits 32]

updateGDT64:
	mov [gdtCode + 6], byte 10101111b	; Access the second flags byte from within our code descriptor,
										; accessed by using the address of gdtCode with an offset of 6,
										; and modify the existing flags for 64-bit mode.
										; Flags			(granularity=1, default=0, long=1, avl=0 ---------> 1010)
										; Limit (h)		(limit @ bits 16-19=1111 or 0xf000 to give 0xf000ffff)

	mov [gdtData + 6], byte 10101111b	; Repeat for data descriptor
	ret

; Specify 16-bit mode here so that we retain compatibility with the 16-bit code from before
; in this file
[bits 16]