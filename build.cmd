clang++ -std=c++2a -fmodules-ts --precompile -x c++-module -Xclang -fmodules-embed-all-files -Xclang -fmodules-codegen -Xclang -fmodules-debuginfo -o module.pcm module.cpp

clang++ -std=c++2a -fmodules-ts -o module.pcm.o -c module.pcm

clang++ -std=c++2a -fmodules-ts -x c++ -o main.o -fmodule-file=module.pcm -c main.cpp

clang++ -o main.exe module.pcm.o main.o