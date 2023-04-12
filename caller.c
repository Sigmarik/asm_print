#include <stdio.h>
#include <stdlib.h>

extern void call_asm(void* ptr, ...);
extern void print(const char* format, ...);

int main(void) {
    call_asm(print, "%d %s %x %d%%%c%b\n", (long long) -1, "love", 0xEDA, 100, '!', 127);

    return EXIT_SUCCESS;
}
