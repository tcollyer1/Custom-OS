[org 0x7c00] ; Specify the origin address that the program expects to be loaded into, so that calculated offsets are from this point of reference

mov [boot_disk], dl ; Once the BIOS loads this program into memory, it stores the number of the disk it was loaded from into register dl

mov bp, 0x7c00 ; BIOS loads this program into address 0x7c00 because memory addresses 0x7c00-0x7dff are reserved for the boot sector. So, load this address to indicate base of the stack
mov sp, bp ; Stack pointer - start at the base

mov bx, outputStr ; Store address of outputStr section (displayMsg.asm) so we can access its result easily (a string/byte array)
call display ; Store address of current line, jump to label display (displayMsg.asm), then resume from saved address afterwards

call diskRead ; Store address of current line, jump to label diskRead (readDisk.asm), then resume from saved address afterwards

; Display data from the next sector here, as a test
mov bx, program_space
call display

jmp $ ; Repeat until interrupted

; Include other .asm files here
%include "src/displayMsg.asm"
%include "src/readDisk.asm"

; Must always be at the end
times 510-($-$$) db 0 ; Pad 510 bytes with 0
dw 0xaa55 ; Define end of bootloader with remaining 2 bytes of 512-byte bootloader