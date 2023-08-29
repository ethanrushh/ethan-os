# ethan-os
Super basic OS (boot lader with some added candy) just for testing tools

# Building
`make clean`
`make`

The binary files will be output to the `build` directory


# Running
`./debug.sh`

debug.sh will clean, build and execute the OS

# Depdencies
You're best off just looking at the makefile to figure it out but the incomplete list is:

mtools
masm
make
qemu
watcom C (16 bit realmode compiler)
~~bochs~~