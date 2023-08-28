org 0x7c00 ; The offset required for a legacy boot
bits 16 ; Boot in 16-bit. CPU needs to be started in Intel 8086 style instructions first (assembler will assemble 16 bit codes)

; nasm macros for ENDL
%define ENDL 0x0D, 0x0A

; Since puts is above main, we need to jump to it to make sure it is (ultimately) the entry point
start:
	jmp main

; Prints a string to the screen
; Params
;	si: points to a string loaded in memory
puts:
	; Save the registers we are going to work with for later
	push si
	push ax

.puts_loop:
	lodsb ; Loads in the next char
	or al, al ; Verify if the next char is null
	jz .puts_done ; If the 0 flag is set (i.e. the next char is null i.e. we are done, jump to the done label)

	; Call the BIOS interrupt for printing ASCII characters to the VGA output (video)
	mov ah, 0x0e
	mov bh, 0
	int 0x10

	jmp .puts_loop ; Print the next character of the string

.puts_done:
	; Restore the registers from earlier
	pop ax
	pop si
	ret


; Entry point
main:
	mov ax, 0 ; We can't write to  DS or ES directly
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7C00 ; The stack grows down from where we loaded into memory

	; Print our message to the user
	mov si, hello_world_msg
	call puts

	hlt

; Infinitely halts the CPU
.halt:
	jmp .halt


hello_world_msg: db 'Hello World', ENDL, 0


times 510-($-$$) db 0 ; Fills the rest of the bytes we need with 0s
dw 0AA55h
