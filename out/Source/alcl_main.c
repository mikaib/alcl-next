#include "./alcl_main.h"

int alcl_main_sum(int x, double y) {
    return (((double)x) + y);
}

void alcl_main_main() {
    alcl_main_sum(((int)5.5), 10.5);
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
