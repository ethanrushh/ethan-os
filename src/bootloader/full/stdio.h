#pragma once
#include <stdint.h>

typedef enum
{
    IO = 0,
    INFO = 1,
    VIDEO = 2
} LogInterest;


void clrscr();
void log(LogInterest interest, const char* msg);
void putc(char c);
void puts(const char* str);
void putc_color(char c, unsigned char color);
void puts_color(const char* str, unsigned char color);
void printf(const char* fmt, ...);
