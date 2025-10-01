#include "./alcl_main.h"
#include "./alcl_io.h"
#include "./alcl_conv.h"

int alcl_main_sumA(int x, double y) {
    return (x + ((int)y));
}

int alcl_main_sumB(int x, double y) {
    return (x + ((int)y));
}

int alcl_main_sumC(int x, double y) {
    return ((int)(((double)x) + y));
}

double alcl_main_sumD(int x, double y) {
    return (((double)x) + y);
}

int alcl_main_sumE(double x, double y) {
    return ((int)(x + y));
}

double alcl_main_sumF(double x, double y) {
    return (x + y);
}

void alcl_main_main() {
    const char* v = alcl_conv_f64_to_cstr(((double)((int)5.5)));
    alcl_main_sumA(((int)5.5), 10.5);
    alcl_main_sumB(((int)5.5), 10.5);
    alcl_main_sumC(((int)5.5), 10.5);
    alcl_main_sumD(((int)5.5), 10.5);
    alcl_main_sumE(5.5, 10.5);
    alcl_main_sumF(5.5, 10.5);
    alcl_io_println(v);
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
