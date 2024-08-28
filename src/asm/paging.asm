; Setup for simple identity paging for use in 64-bit long mode.

page_table_start equ 0x1000		; Define entry point into our page tables (starting with the PML4T).
								; Don't start from 0x0000 as there is code in the first section of memory that shouldn't be 
								; overwritten. Therefore, leave first 4,096 bytes free

identityPaging:
	mov edi, page_table_start	; Move start of page tables into destination index register
	mov cr3, edi				; Copy this to control register 3

	mov dword [edi], 0x2003		; Move value 0x2003 to address 0x1000 -> address of next 4 KB table, plus 2 bits set for
								; indicating page is present and is both readable/writeable
	add edi, 0x1000				; Point destination index 4,096 B (4 KB) ahead to the next table

	mov dword [edi], 0x3003		; Repeat the above process for the following 2 of our 4 tables
	add edi, 0x1000

	mov dword [edi], 0x4003
	add edi, 0x1000

	; Identity mapping - final table (PT)
	mov ebx, 0x00000003			; Set B register flag bits (32-bit value) - page is present and is both readable/writeable
	mov ecx, 512				; Set C register to number of entries to add - 512 64-bit values (4 KB) - used just below

	setEntry:
		mov dword [edi], ebx	; Move flag bits into memory address of the PT (0x4000)
		add ebx, 0x1000			; Increase B register by 0x1000 (???)
		add edi, 8				; Increase destination index by 8 (bytes) - next entry in page table (PT)
		loop setEntry

	; Set PAE (physical address space) bit in control register 4 to enable PAE paging
	mov eax, cr4				; Move contents of control register 4 to A register to modify
	or eax, 0x20				; Set PAE bit (bit 5 or 1 << 5)
	mov cr4, eax				; Apply to control register 4

	; Set long mode bit in EFER (extended feature enable register)
	mov ecx, 0xc0000080			; Set C register to EFER
	rdmsr						; Command that reads from model-specific register (MSR) specified in C register
								; into edx:eax registers
	or eax, 0x100				; Set long mode (bit 8 or 1 << 8)
	wrmsr						; Command that writes contents of edx:eax registers to MSR specified in C register

	; Finally, enable paging
	mov eax, cr0				; Move contents of control register 0 to A register to modify
	or eax, 0x80000000			; Set paging bit (bit 31, or 1 << 31)
	mov cr0, eax				; Apply to control register 0

	ret