org 0x7c00 ; The offset required for a legacy boot
bits 16 ; Boot in 16-bit. CPU needs to be started in Intel 8086 style instructions first (assembler will assemble 16 bit codes)

; Entry point
main:
	hlt

; Infinitely halts the CPU
.halt:
	jmp .halt

times 510-($-$$) db 0 ; Fills the rest of the bytes we need with 0s
dw 0AA55h
