; Checks that the CPUID instruction is supported to switch to 64-bit long mode.

testCPUID:
    pushfd              ; Push flags double-word (32-bit). Pushes flags register (EFLAGS) on to the stack
    pop eax             ; Pops the EFLAGS register content currently on the stack off to eax for manipulation
    mov ecx, eax        ; Store for comparison to confirm if CPUID is supported
    xor eax, 0x200000   ; Flip ID bit (bit 21) to check if CPUID is supported
    
    push eax            ; Now push the content of eax, with our flipped bit, back to the stack
    popfd               ; Pop the new content of the stack back into the EFLAGS register
    
    pushfd              ; Now copy it back over to eax...
    pop eax             ; ...in order to confirm if changes were actually made to the flags register
    
    push ecx            ; Push the contents of ecx, holding the original EFLAGS values, to the stack
    popfd               ; Pop this content on the stack back off and into the EFLAGS register to revert any changes we made
    
    xor eax, ecx        ; Compare both values - if they're equal then the bit was never flipped
    jz notSupported     ; Jump if 0 (so equal). If equal then CPUID isn't supported
	ret
    
; In the event CPUID is available, now check if 64-bit long mode is available
test64Long:
    mov eax, 0x80000001         ; Detect long mode via extended functions of CPUID - which start at addresses > 0x80000000
    cpuid                       ; Execute our CPUID instruction (uses eax register that we just filled)
    test edx, 0x10000000        ; Check that bit 29 (bit for long mode) is set in the edx register (bitwise AND)
    jz notSupported             ; Jump if 0 (bit 29 not set) - long mode not supported
    ret

notSupported:
    hlt                         ; CPUID/long mode not supported, cannot use 64-bit long mode - halt CPU unless an interrupt occurs