db 'This is after the boot sector!', 0
times 2048-($-$) db 0 ; Pad out 4 further 512-byte sectors with zeroes that the BIOS can read from