#include "./alcl_main.h"

int* alcl_main_add_ptrs(int* a, int* b) {
    return (&((*a) + (*b)));
}

void alcl_main_main() {
    int* x = alcl_main_add_ptrs((&10), (&20));
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
