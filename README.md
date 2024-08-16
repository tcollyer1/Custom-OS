# Custom-OS
A custom, barebones 64-bit OS I'm learning to write from scratch using assembly and C++. So far it includes a simple bootloader and loads sectors from the disk into memory.

## Tools and Software
- Visual Studio 2019
- [Bochs](https://bochs.sourceforge.io) for emulating a PC and x86 CPU for the OS to run on
- [NASM](https://nasm.us) (Netwide Assembler)

## To Run
To run, ensure Bochs is installed and run `assemble.bat`, which will generate an `.flp` floppy image usable in Bochs. Further configuration will be added later.

## Current Features
Will add to this list as I flesh the project out.
- Simple bootloader that displays a string in 16-bit real mode
- Loads sectors from the disk into memory to extend program space beyond the boot sector
- Switches to 32-bit protected mode and writes to video memory to display a simple string
