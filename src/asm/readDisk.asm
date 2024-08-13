program_space equ 0x7e00 ; First memory address usable after the 512-byte boot sector (0x7c00-0x7dff)

diskRead:
	mov ah, 0x02 ; Set BIOS to a mode to read disk sectors
	mov bx, program_space ; Memory location to load the data to ^
	mov al, 4 ; Number of sectors to read from. 4 sectors is around 2000 bytes, which is enough for now
	mov dl, [boot_disk] ; Tell the BIOS what disk to read from using our variable
	mov ch, 0x00 ; Indicate cylinder to read from (drive-specific)
	mov dh, 0x00 ; Indicate head to read from (drive-specific)
	mov cl, 0x02 ; Start reading from the second sector (boot sector is the first sector)

	int 0x13 ; INT 13h. Interrupt that tells the BIOS to read from the disk
	jc diskReadFailure ; If carry flag set (disk read failed), jump to diskReadFailure
	ret

boot_disk: 
	db 0 ; Reserve a byte, boot_disk

diskReadError: 
	db 'ERROR: failed to read from disk', 0

diskReadFailure:
	mov bx, diskReadError ; If we've jumped here, there was an error reading from the disk. So display error message
	call display
	jmp $