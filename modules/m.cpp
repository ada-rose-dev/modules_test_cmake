module;
export module M;
#include <iostream>
export {
    void foo() {
        std::cout << "Hello, Module M!" <<std::endl;
    }
}