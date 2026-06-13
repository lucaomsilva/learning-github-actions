#include <stdio.h>
#include <stdlib.h>
#include "hello/hello.h"

#ifndef APP_VERSION
    #define APP_VERSION "unknown"
#endif

int main() {
    // Attempt to get the version from the environment variable
    const char *version = getenv("VERSION");
    
    // Fallback to compile-time defined APP_VERSION if env var is not present
    if (version == NULL || version[0] == '\0') {
#ifdef APP_VERSION
        version = APP_VERSION;
#else
        version = "unknown";
#endif
    }

    char buffer[256];
    get_greeting(buffer, sizeof(buffer), version);
    
    printf("%s\n", buffer);
    return 0;
}
