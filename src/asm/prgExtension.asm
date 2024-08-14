[org 0x7e00] ; Set origin address of new sector

; Enable protected mode
jmp protectedMode

jmp $ ; Repeat until interrupted

; Include files
%include "src/asm/displayMsg.asm"

protectedMode:
	cli ; Disables interrupts
	jmp $

enableA20:
	in al, 0x92 ; Load in port 0x92 (A20 gate register)
	or al, 2 ; Bitwise OR with binary 10 - bit 1 of 0x92 handles A20. 0 to disable, 1 to enable. Enables regardless of whether it's on or off.
	out 0x92, al ; Output result in al back to port 0x92
	ret

times 2048-($-$) db 0 ; Pad out 4 further 512-byte sectors with zeroes that the BIOS can read from