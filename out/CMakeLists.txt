cmake_minimum_required(VERSION 3.10)
project(alcl)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED True)

add_executable(alcl
    ./Source/alcl_conv.c
    ./Source/alcl_main.c
    ./Source/alcl_io.c
)

target_include_directories(alcl PRIVATE ./Source)

