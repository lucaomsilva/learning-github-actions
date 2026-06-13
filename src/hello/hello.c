#include "hello.h"
#include <stdio.h>

void get_greeting(char *buffer, size_t size, const char *version) {
    if (version == NULL || version[0] == '\0') {
        version = "unknown";
    }
    snprintf(buffer, size, "Hello World from version %s", version);
}
