; src for documentation - https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system#Boot_Sector

org 0x7c00 ; The offset required for a legacy boot
bits 16 ; Boot in 16-bit. CPU needs to be started in Intel 8086 style instructions first (assembler will assemble 16 bit codes)

; nasm macros for ENDL
%define ENDL 0x0D, 0x0A


; ============
; FAT12 header
; ============
jmp short start
nop

; Details taken from the FAT12 docs and raw hex inspected from an "empty" image to get something that "should" work
bdb_oem:					db 'MSWIN4.1' ; 8 bytes. Should be highly compatible.
bdb_bytes_per_sector: 		dw 512		  ; 00 02 in little endian HEX
bdb_sectors_per_cluster:	db 1		  ; 1 sector per cluster
bdb_reserved_sectors:		dw 1
bdb_fat_count:				db 2
bdb_dir_entries_count:		dw 0E0h
bdb_total_sectors:			dw 2880		  ; Multiplied by the bytes per sector this is our 1.44MB of a floppy
bdb_media_descriptor_type:	db 0F0h		  ; 3.5" floppy
bdb_sectors_per_fat:		dw 9
bdb_sectors_per_track:		dw 18
bdb_heads:					dw 2
bdb_hidden_sectors:			dd 0
bdb_large_sector_count:		dd 0

; Extended boot record
ebr_drive_number:			db 0		  ; 0x00 is a floppy disk, 0x80 is an HDD. Seems useless??
db 0 									  ; Reserved byte so we'll just set it to 0
ebr_signature:				db 29h
ebr_volume_id:				db 12h, 34h, 56h, 78h
ebr_volume_label:			db 'ETHAN OS   '
ebr_system_id:				db 'FAT12   '


; ===============
; Bootloader code
; ===============


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
	push bx

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
	pop bx
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

	; Some BIOSes suck and start at 07C0:0000 instead of 0000:7C00
	push es
	push word .after
	retf

.after:
	; try to read something from the floppy disk
	; The BIOS will set DL to the drive number for us
	mov [ebr_drive_number], dl

	; Print our message to the user
	mov si, hello_world_msg
	call puts

	; Read drive parameters
	push es
	mov ah, 08h
	int 13h
	jc failed_read
	pop es

	and cl, 0x3F ; Remove the top 2 bits
	xor ch, ch
	mov [bdb_sectors_per_track], cx

	inc dh
	mov [bdb_heads], dh

	mov ax, [bdb_sectors_per_fat]
	mov bl, [bdb_fat_count]
	xor bh, bh
	mul bx
	add ax, [bdb_reserved_sectors]
	push ax

	mov ax, [bdb_sectors_per_fat]
	shl ax, 5
	xor dx, dx
	div word [bdb_bytes_per_sector]

	test dx, dx
	jz .root_dir_after
	inc ax

.root_dir_after:

	mov cl, al
	pop ax
	mov dl, [ebr_drive_number]
	mov bx, buffer
	call disk_read

	xor bx, bx
	mov di, buffer

.search_kernel:
	mov si, file_kernel_bin
	mov cx, 11
	push di
	repe cmpsb ; compare string bytes, compares strings stored in ds:si and es:di
			   ; repe will repeat the instruction until the zero flag = 1 a max of cx times
	pop di
	je .found_kernel

	add di, 32
	inc bx
	cmp bx, [bdb_dir_entries_count]
	jl .search_kernel

	jmp kernel_not_found_error


.found_kernel:
	mov ax, [di + 26]
	mov [kernel_cluster], ax

	mov ax, [bdb_reserved_sectors]
	mov bx, buffer
	mov cl, [bdb_sectors_per_fat]
	mov dl, [ebr_drive_number]
	call disk_read

	; lower memory is standardized
	; load the kernel into memory
	mov bx, KERNEL_LOAD_SEGMENT
	mov es, bx
	mov bx, KERNEL_LOAD_OFFSET

.load_kernel_loop:
	mov ax, [kernel_cluster]
	add ax, 31 ; temp - TODO: fix because this won't work on anything except a 1.44MB floppy

	mov cl, 1
	mov dl, [ebr_drive_number]
	call disk_read

	add bx, [bdb_bytes_per_sector]

	mov ax, [kernel_cluster]
	mov cx, 3
	mul cx
	mov cx, 2
	div cx

	; an overflow will occur if the kernel is above 64KiB
	; TODO: fix
	mov si, buffer
	add si, ax
	mov ax, [ds:si]

	or dx, dx
	jz .even


.odd:
	shr ax, 4
	jmp .next_cluster_after

.even:
	and ax, 0x0FFF

.next_cluster_after:
	cmp ax, 0x0FF8
	jae .read_finish

	mov [kernel_cluster], ax
	jmp .load_kernel_loop

.read_finish:
	mov dl, [ebr_drive_number]
	mov ax, KERNEL_LOAD_SEGMENT
	mov ds, ax
	mov es, ax

	jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET ; Load the kernel! This little shit costed me another few hours of debugging because I messed up the offest...

	jmp wait_for_key_then_reboot ; This should never happen. If we see this, something has gone VERY wrong.

	cli
	hlt


; ==============
; Error Handlers
; ==============


display_disk_read_error:
	mov si, disk_read_failure_msg
	call puts

	jmp wait_for_key_then_reboot

kernel_not_found_error:
	mov si, kernel_not_found_msg
	call puts

	jmp wait_for_key_then_reboot

wait_for_key_then_reboot:
	mov si, any_key_reboot_msg
	call puts

	mov ah, 0
	int 16h ; Wait for key press
	jmp 0FFFFh:0 ; Jump to the beginning of the BIOS, reinitializing the system, effectively rebooting

; Infinitely halts the CPU
.halt:
	cli ; Disables interrupts
	hlt




; ============
; Disk Methods
; ============

; Converts an LBA address to a CHS address
; Parameters:
; 	- ax: LBA address
; Returns:
; 	- cx: sector number [0~5], cylinder [6~15]
;	- dh: head
convert_lba_to_chs:

	; Save registers for later
	push ax
	push dx

	xor dx, dx ; set dx to 0
	div word [bdb_sectors_per_track] ; ax = LBA / bdb_sectors_per_track
									 ; dx = LBA % bdb_sectors_per_track

	inc dx ; Increment dx by 1
	mov cx, dx ; cx = sector

	xor dx, dx ; Set dx to 0
	div word [bdb_heads] ; ax = ax / heads
						 ; dx = remainer

	mov dh, dl ; head
	mov ch, al ; lower 8 bits of cylinder
	shl ah, 6
	or cl, ah ; upper 2 bits of cylinder into the cl register

	; Restore registers
	pop ax
	mov dl, al
	pop ax

	ret

; Reads sectors from a given disk
; Parameters:
;	- ax: LBA address
; 	- cl: number of sectors to read (max 128)
;	- dl: drive number
; 	- es:bx: memory address to store the data at

disk_read:
	; Save the registers we are going to modify
    push ax
    push bx
    push cx
    push dx
    push di

	push cx
	call convert_lba_to_chs
	pop ax

	mov ah, 02h
	mov di, 3 ; retry count. recommended as per spec is 3 tries else fuck it, its probably broken

	

.retry_disk_read:
	pusha ; the BIOS will touch some registers so we'll just save them all to be sure we don't break anything
	stc ; some BIOSes won't properly set the carry flag so we'll do that ourselves
	int 13h ; if the carry flag is clear, the read was a success
	jnc finish_read

	; If the read failed, reset the controller and go again
	popa
	call disk_reset

	dec di
	test di, di
	jnz .retry_disk_read

; The boot process has failed beyond recovery - all attempts to boot have failed
failed_read:
	jmp display_disk_read_error


finish_read:
	popa

	; Restore the registers we pushed
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret

; Resets the controller
; Parameters:
; 	- dl: drive number
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc display_disk_read_error
	popa
	ret


; Not enough space sadly.
; hello_world_msg: 		db "Welcome to Ethan's OS!", ENDL, 0
; disk_read_failure_msg: 	db "Failed to read the floppy. Make sure the floppy is working correctly and try again.", ENDL, 0
; any_key_reboot_msg: 	db "Press any key to reboot...", ENDL, 0
; file_kernel_bin:		db 'KERNEL  BIN' ; Fat file names are 11 bytes, padded with spaces
; kernel_not_found_msg:	db 'kernel.bin was not found. Check the drive is working correctly and that the installation is not corrupted', ENDL, 0
; kernel_cluster: 		dw 0

hello_world_msg: 		db "Booting EthanOS", ENDL, 0
disk_read_failure_msg: 	db "Read failed", ENDL, 0
any_key_reboot_msg: 	db "Press key", ENDL, 0
file_kernel_bin:		db 'FULL    BIN' ; Fat file names are 11 bytes, padded with spaces
kernel_not_found_msg:	db 'Bad floppy', ENDL, 0
kernel_cluster: 		dw 0

KERNEL_LOAD_SEGMENT		equ 0x2000
KERNEL_LOAD_OFFSET		equ 0

times 510-($-$$) db 0 ; Fills the rest of the bytes we need with 0s
dw 0AA55h ; The required signature for the BIOS to detect that we are a boot loader not the start of random data

; The buffer will be set to the first memory address AFTER our boot loader
buffer: