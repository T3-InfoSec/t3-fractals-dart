cmake_minimum_required(VERSION 3.10)
project(burningship VERSION 1.0.0)
add_library(burningship SHARED burningship.cpp burningship.cpp)
add_executable(burningship_test burningship.cpp)

set_target_properties(burningship PROPERTIES
    PUBLIC_HEADER burningship.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "burningship"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
