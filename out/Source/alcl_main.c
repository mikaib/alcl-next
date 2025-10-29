#include "./alcl_main.h"

double alcl_main_foo() {
    return (((double)3) + 3.5);
}

double alcl_main_main() {
    return alcl_main_foo();
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
