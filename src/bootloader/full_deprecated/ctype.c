#include "ctype.h"

char toUpper(char chr)
{
    return isLower(chr) ? (chr - 'a' + 'A') : chr;
}

bool isLower(char chr)
{
    return chr >= 'a' && chr <= 'z';
}
