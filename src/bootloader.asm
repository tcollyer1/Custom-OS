jmp $ ; Repeat until interrupted

times 510-($-$$) db 0 ; Pad 510 bytes with 0

dw 0xaa55 ; Define end of bootloader with remaining 2 bytes of 512-byte bootloader