#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "../src/hello/hello.h"

void test_get_greeting_with_version() {
    char buffer[256];
    get_greeting(buffer, sizeof(buffer), "1.2.3");
    assert(strcmp(buffer, "Hello World from version 1.2.3") == 0);
    printf("test_get_greeting_with_version: PASSED\n");
}

void test_get_greeting_with_null() {
    char buffer[256];
    get_greeting(buffer, sizeof(buffer), NULL);
    assert(strcmp(buffer, "Hello World from version unknown") == 0);
    printf("test_get_greeting_with_null: PASSED\n");
}

int main() {
    printf("Running unit tests...\n");
    test_get_greeting_with_version();
    test_get_greeting_with_null();
    printf("All tests PASSED!\n");
    return 0;
}
