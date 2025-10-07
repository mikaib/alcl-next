#include "./alcl_main.h"
#include "./alcl_conv.h"

const char* alcl_main_identity(const char* x) {
    return x;
}

void alcl_main_main() {
    int x = 1;
    long* y = (&((long)x));
    int z = ((int)(*y));
    int* w = (&z);
    const char* q = alcl_main_identity(alcl_conv_i64_to_cstr((*y)));
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
