export CFLAGS = -std=c99 -g
export CC = gcc
export GXX = g++
export LD = gcc
export ASSEMBLER = nasm
export ASSEMBLER_FLAGS = 
export LINKFLAGS = 
export LIBS = 

export TARGET = i686-elf
export TARGET_CFLAGS = -std=c99 -g
export TARGET_CC = $(TARGET)-gcc
export TARGET_CXX = $(TARGET)-g++
export TARGET_LD = $(TARGET)-gcc
export TARGET_ASSEMBLER = nasm
export TARGET_ASSEMBLER_FLAGS =
export TARGET_LINKFLAGS =
export TARGET_LIBS =

export BUILD_DIR=$(abspath build)

BINUTILS_URL = https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.xz
GCC_URL = https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.xz
