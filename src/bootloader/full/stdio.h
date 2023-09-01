#pragma once

typedef enum
{
    IO = 0,
    INFO = 1,
    VIDEO = 2
} LogInterest;


void log(LogInterest interest, const char* msg);
void putc(char c);
void puts(const char* str);
void putc_color(char c, unsigned char color);
void puts_color(const char* str, unsigned char color);
void _cdecl printf(const char* fmt, ...);
