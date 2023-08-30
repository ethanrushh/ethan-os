#pragma once



typedef enum
{
    IO,
    INFO
} LogInterest;


void log(LogInterest interest, const char* msg);
void putc(char c);
void puts(const char* str);
void _cdecl printf(const char* fmt, ...);
