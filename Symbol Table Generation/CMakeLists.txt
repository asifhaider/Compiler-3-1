cmake_minimum_required(VERSION 3.22)
project(Symbol_Table_Generation)

set(CMAKE_CXX_STANDARD 14)

add_executable(Symbol_Table_Generation SymbolTableManager.cpp SymbolTable.h)
