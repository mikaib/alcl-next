#include "./alcl_main.h"

void alcl_main_foo(int x) {
}

void alcl_main_bar(float x) {
}

void alcl_main_main() {
    long z = ((long)3);
    alcl_main_foo(((int)z));
    alcl_main_bar(((float)z));
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
