nasm src/bootloader.asm -f bin -o bootloader.bin
nasm src/prgExtension.asm -f bin -o prgExtension.bin
copy /b bootloader.bin+prgExtension.bin bootloader.flp
del bootloader.bin prgExtension.bin