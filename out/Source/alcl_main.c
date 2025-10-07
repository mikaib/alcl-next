#include "./alcl_main.h"

void alcl_main_main() {
    double x = alcl_main_identity(10.0);
}

double alcl_main_identity(double x) {
    return (x + 3.0);
}

int main(int argc, char** argv) {
    alcl_main_main();
    return 0;
}
