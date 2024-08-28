; The extended program, accessible via further disk space loaded into memory.
; Here, we also enable 32-bit protected mode, followed by 64-bit long mode - 
; so that we can enable paging and later load in our kernel compiled in 64-bit
; in C++.

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

; Includes for 32-bit protected mode
%include "src/asm/cpuid.asm"
%include "src/asm/paging.asm"
%include "src/asm/displayMsg32.asm"

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

	; Check if CPUID instruction is supported & then long mode.
	; Then, enable paging, update the GDT and enter 64-bit mode
	call testCPUID
	call test64Long
	call identityPaging
	call updateGDT64
	jmp code_segment:startLongMode

; Establish 64-bit mode code area.
;
; We don't need to update the segment registers again like we did for 32-bit mode,
; as we're still using the same GDT
[bits 64]

; 64-bit long mode
startLongMode:
	mov edi, 0xb8000			; Load 0xb8000 (start of video memory) to destination index
	mov rax, 0x4f204f204f204f20	; Displays a hexidecimal coloured space in 64-bit, using 64-bit A register
	mov ecx, 500
	rep stosq					; Stores contents of A register into where the destination index points to, N 
								; times - N being the value stored in the 32-bit C register.
								;
								; Essentially, just clears the screen using a BG colour (red) (4), FG colour
								; (white) (F) and character to clear with (space) (20) by displaying this
								; character 500 times
	jmp $

times 2048-($-$) db 0 ; Pad out 4 further 512-byte sectors with zeroes that the BIOS can read from