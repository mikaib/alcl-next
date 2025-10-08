#include "./alcl_main.h"
#include "./alcl_io.h"
#include "./alcl_conv.h"

double alcl_main_even(int x) {
    return (((x == 0)) ? (1.0) : (alcl_main_odd((x - 1))));
}

double alcl_main_odd(int x) {
    return (((x == 0)) ? (((double)5)) : (alcl_main_even((x - 1))));
}

void alcl_main_main() {
    alcl_io_println(alcl_conv_f64_to_cstr(alcl_main_even(4)));
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
