# ethan-os
Super basic OS (boot lader with some added candy) just for testing tools

# Building
`make`

The binary files will be output to the `build` directory


# Running
`qemu-system-i386 -fda build/main_floppy.img`

# Depdencies
You're best off just looking at the makefile to figure it out but the incomplete list is:

mtools
masm
make
qemu
