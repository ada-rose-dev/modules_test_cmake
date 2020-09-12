#NOTE: When building with VSCode, be sure to set CMAKE_CXX_COMPILER clang++, CMAKE_C_COMPILER clang
#This can be done by making a custom kit, stored in .vscode/cmake-kits.json

cmake_minimum_required (VERSION 3.8)
project ("main" LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PREBUILT_MODULE_PATH ${CMAKE_BINARY_DIR}/modules)
set(FLAGS -Wall -v)
set(moduleExec imported)


function(add_module name file) 
    set(moduleNames ${moduleNames} ${name} PARENT_SCOPE)
    set(moduleOutput ${moduleOutput} ${name}.pcm.o PARENT_SCOPE)
    set(moduleFiles ${moduleFiles} ${file} PARENT_SCOPE)
    
    file(MAKE_DIRECTORY ${PREBUILT_MODULE_PATH})
    #generate pcm
    add_custom_command(
        OUTPUT ${name}.pcm
        COMMAND echo "===> Generating ${name}.pcm ..."
        COMMAND ${CMAKE_CXX_COMPILER} ${FLAGS} -std=c++2a -fmodules-ts --precompile -x c++-module -Xclang -fmodules-embed-all-files -Xclang -fmodules-codegen -Xclang -fmodules-debuginfo -o ${PREBUILT_MODULE_PATH}/${name}.pcm ${CMAKE_CURRENT_SOURCE_DIR}/${file}
        VERBATIM
    )
    #generate pcm.o
    add_custom_command(
        OUTPUT ${name}.pcm.o
        DEPENDS ${name}.pcm
        COMMAND echo "===> Generating ${name}.pcm.o ..."
        COMMAND ${CMAKE_CXX_COMPILER} ${FLAGS} -std=c++2a -fmodules-ts -o ${PREBUILT_MODULE_PATH}/${name}.pcm.o -c ${PREBUILT_MODULE_PATH}/${name}.pcm
        VERBATIM
    )
    add_custom_target(
        ${name} DEPENDS ${name}.pcm.o
    )

endfunction()

# add modules
add_module(module module.mxx)
message("===> moduleNames: ${moduleNames}")
message("===> moduleOutput: ${moduleOutput}")
message("===> moduleFiles: ${moduleFiles}")

#TODO: creating main.o is breaking
#may have something to do with all the extra flags CMake attaches to the build
#"C:\\Program Files\\LLVM\\bin\\clang++.exe"
## probably all hardware related:
    # -cc1 -triple x86_64-pc-windows-msvc19.27.29111 -emit-obj -mrelax-all -mincremental-linker-compatible -disable-free -disable-llvm-verifier
    # -discard-value-names -main-file-name main.cpp -mrelocation-model pic -pic-level 2 -mthread-model posix -mframe-pointer=none -fmath-errno 
    # -fno-rounding-math -masm-verbose -mconstructor-aliases -munwind-tables -target-cpu x86-64 -dwarf-column-info -v
## include dirs:
    # -resource-dir "C:\\Program Files\\LLVM\\lib\\clang\\10.0.0" -internal-isystem "C:\\Program Files\\LLVM\\lib\\clang\\10.0.0\\include"
    # -internal-isystem "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.27.29110\\include"
    # -internal-isystem "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Tools\\MSVC\\14.27.29110\\atlmfc\\include"
    # -internal-isystem "C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.18362.0\\ucrt"
    # -internal-isystem "C:\\Program Files (x86)\\Windows Kits\\10\\include\\10.0.18362.0\\shared"
    # -internal-isystem "C:\\Program Files (x86)\\Windows Kits\\10\\include\\10.0.18362.0\\um"
    # -internal-isystem "C:\\Program Files (x86)\\Windows Kits\\10\\include\\10.0.18362.0\\winrt"
## start actual tags that matter:
# -Wall -std=c++2a -fdeprecated-macro -fdebug-compilation-dir "C:\\Users\\Phoenix Mandala\\source\\repos\\modules_test_cmake\\build"
# -ferror-limit 19 -fmessage-length 0 -fno-use-cxa-atexit -fms-extensions -fms-compatibility -fms-compatibility-version=19.27.29111
# -fdelayed-template-parsing -fmodules-ts -fno-implicit-modules
# "-fprebuilt-module-path=C:/Users/Phoenix Mandala/source/repos/modules_test_cmake/build/modules"
# -fobjc-runtime=gcc -fcxx-exceptions -fexceptions -fdiagnostics-show-option -faddrsig
# -o "C:/Users/Phoenix Mandala/source/repos/modules_test_cmake/build/main.o"
# -x c++ "C:/Users/Phoenix Mandala/source/repos/modules_test_cmake/main.cpp"

#compare to:
#clang++ -std=c++2a -fmodules-ts -x c++ -o main.o -fmodule-file=module.pcm -c main.cpp
add_custom_command(
    OUTPUT main.o
    DEPENDS ${moduleOutput}
    COMMAND echo "===> Linking modules to main ..."
    COMMAND clang++ -std=c++2a -fmodules-ts -x c++ -o ${CMAKE_BINARY_DIR}/main.o -fprebuilt-module-path=${PREBUILT_MODULE_PATH} -c ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
    VERBATIM
)

add_custom_target(
    ${moduleExec}
    DEPENDS main.o
    COMMAND echo "===> Creating main executable ..."
    COMMAND ${CMAKE_CXX_COMPILER} ${FLAGS} -o ${CMAKE_BINARY_DIR}/${moduleExec}.exe ${moduleOutput} ${CMAKE_BINARY_DIR}/main.o
    VERBATIM
)


# this is probably not going to work. before you try it, an imported exeuctable won't build anything.
add_executable(main main.cpp ${moduleFiles} main.o) 
#add_dependencies(main ${moduleExec})
