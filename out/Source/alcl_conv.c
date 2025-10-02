#include "./alcl_conv.h"
#include "stdlib.h"
#include "stdio.h"
#include "string.h"

const char* alcl_conv_i32_to_cstr(int x) {
    char tmp[32];
    int len = snprintf(tmp, sizeof(tmp), "%d", x);
    char* result = (char*)malloc(len + 1);
    if (result) {
        snprintf(result, len + 1, "%d", x);
    }
    return result;
}

const char* alcl_conv_i64_to_cstr(long x) {
    char tmp[32];
    int len = snprintf(tmp, sizeof(tmp), "%lld", x);
    char* result = (char*)malloc(len + 1);
    if (result) {
        snprintf(result, len + 1, "%lld", x);
    }
    return result;
}

const char* alcl_conv_f32_to_cstr(float x) {
    char tmp[64];
    int len = snprintf(tmp, sizeof(tmp), "%g", x);
    char* result = (char*)malloc(len + 1);
    if (result) {
        snprintf(result, len + 1, "%g", x);
    }
    return result;
}

const char* alcl_conv_f64_to_cstr(double x) {
    char tmp[128];
    int len = snprintf(tmp, sizeof(tmp), "%lg", x);
    char* result = (char*)malloc(len + 1);
    if (result) {
        snprintf(result, len + 1, "%lg", x);
    }
    return result;
}

const char* alcl_conv_bool_to_cstr(int x) {
    const char* str = x == 1 ? "true" : "false";
    char* result = (char*)malloc(strlen(str) + 1);
    if (result) {
        strcpy(result, str);
    }
    return result;
}

