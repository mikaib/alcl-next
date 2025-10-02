#include "./alcl_main.h"
#include "./alcl_io.h"
#include "./alcl_conv.h"

void alcl_main_main() {
    alcl_io_println("ran during runtime!");
    alcl_io_println(alcl_conv_i64_to_cstr(25));
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
