#ifndef ALCL_CONV_H
#define ALCL_CONV_H

#include "stdlib.h"
#include "stdio.h"
#include "string.h"

const char* alcl_conv_i32_to_cstr(int x);
const char* alcl_conv_i64_to_cstr(long x);
const char* alcl_conv_f32_to_cstr(float x);
const char* alcl_conv_f64_to_cstr(double x);
const char* alcl_conv_bool_to_cstr(int x);

#endif //ALCL_CONV_H
