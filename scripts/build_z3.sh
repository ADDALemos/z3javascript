#!/bin/bash -e
./emsdk_portable/emsdk activate latest
source ./emsdk_portable/emsdk_env.sh

cd z3

if [ -e build ]; then
    rm -rf ./build/
fi

alias c++=em++
alias g++=em++
alias ar=emar
alias cc=emcc
alias gcc=emcc
alias clang=emcc
alias clang++=em++
alias cmake=emcmake
alias configure=emconfigure
alias ranlib=emranlib

export CC=em
export CXX=em++

python scripts/mk_make.py --x86 --githash=$(git rev-parse HEAD) --staticlib
cd build
sed -i 's/EXE_EXT=/EXE_EXT=.emscripten.js/g' config.mk
sed -i 's/-m32/-m64/g' config.mk
sed -i 's/^\(CXXFLAGS=.*\)/\1 -fPIC/g' config.mk
sed -i 's/^\(CXXFLAGS=.*\)/\1 INSERTEXPORTHERE/g' config.mk
sed -i 's/^\(LINK_EXTRA_FLAGS=.*\)/\1 -O2 -fPIC INSERTEXPORTHERE/g' config.mk
sed -i 's/O3/O2/g' config.mk
sed -i "s/INSERTEXPORTHERE/-s EXPORTED_FUNCTIONS=\"[$(cat ../../compiled/z3_bindings_flat)]\"/g" config.mk
emmake make
cp z3.emscripten.js* ../../compiled/