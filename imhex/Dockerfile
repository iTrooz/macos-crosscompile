FROM crosscompile as build

# -- DOWNLOADING / INITING STUFF

# download stuff

## Install make
RUN apt install -y make

## Clone ImHex
RUN git clone --recursive https://github.com/iTrooz/ImHex   /mnt/ImHex 

# fix environment
## add install_name_tool for cmake command that won't have the right env set (see PostprocessBundle.cmake function postprocess_bundle())
RUN cp /osxcross/build/cctools-port/cctools/misc/install_name_tool /usr/bin/install_name_tool
## a cmake thing wants 'otool' and not '' apparently
RUN cp /osxcross/target/bin/x86_64-apple-darwin21.2-otool /usr/bin/otool

## Configure vcpkg deps
### Install freetype dep
RUN vcpkg install --triplet=x64-osx-mytriplet freetype
### Install glfw3 dep
RUN <<EOF
set -xe
if [ "$CUSTOM_GLFW" ]; then
    echo "Flag confirmation: using custom GLFW for software rendering"
else
    vcpkg install --triplet=x64-osx-mytriplet glfw3
fi
EOF
### Install libcurl dep
RUN vcpkg install --triplet=x64-osx-mytriplet curl
### Install mbedtls dep
RUN vcpkg install --triplet=x64-osx-mytriplet mbedtls

## download and patch GLFW
ARG CUSTOM_GLFW 1

### Clone glfw
RUN <<EOF
set -xe
if [ "$CUSTOM_GLFW" ]; then
    git clone https://github.com/glfw/glfw /mnt/glfw
fi
EOF

### Patch glfw
RUN <<EOF
set -xe
if [ "$CUSTOM_GLFW" ]; then
    cd /mnt/glfw
    git apply /mnt/ImHex/dist/macOS/0001-glfw-SW.patch
fi
EOF

## Download libmagic 
### Clone libmagic
RUN git clone https://github.com/file/file /mnt/file
## Download libmagic dependencies
RUN apt install -y libtool autoconf

# -- BUILDING STUFF
ARG JOBS 1
ARG BUILD_TYPE Debug

## Build libmagic
RUN --mount=type=cache,target=/cache <<EOF
    ccache -zs
    set -xe
    
    cd /mnt/file
    autoreconf -is

    # when cross-compiling, libmagic needs to have an the same version installed in the system.
    # So we install it normally first
    ./configure --prefix /usr
    make -j $JOBS install

    # Now, we cross-compile it and install it in the libraries folder
    CC=o64-gcc CXX=o64-g++ ./configure --prefix /vcpkg/installed/x64-osx-mytriplet --host $OSXCROSS_HOST
    make -j $JOBS
    make install

    ccache -s
    
EOF

## Build glfw
RUN --mount=type=cache,target=/cache <<EOF
set -xe
if [ "$CUSTOM_GLFW" ]; then
    ccache -zs

    cd /mnt/glfw
    mkdir build
    cd build
    CC=o64-gcc CXX=o64-g++ cmake -G "Ninja"             \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE                \
          -DBUILD_SHARED_LIBS=ON                        \
          -DCMAKE_C_COMPILER_LAUNCHER=ccache            \
          -DCMAKE_CXX_COMPILER_LAUNCHER=ccache          \
          -DCMAKE_OBJC_COMPILER_LAUNCHER=ccache         \
          -DCMAKE_OBJCXX_COMPILER_LAUNCHER=ccache       \
          -DCMAKE_INSTALL_PREFIX=/vcpkg/installed/x64-osx-mytriplet \
          -DVCPKG_TARGET_TRIPLET=x64-osx-mytriplet -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/osxcross/target/toolchain.cmake -DCMAKE_OSX_SYSROOT=/osxcross/target/SDK/MacOSX12.1.sdk -DCMAKE_OSX_DEPLOYMENT_TARGET=12.1 \
        ..
    ninja -j $JOBS install

    ccache -s
fi
EOF

# Build ImHex
## Patch ImHex with hacks
COPY toolchain.cmake.2 /osxcross/target/toolchain.cmake
## Configure ImHex build
RUN --mount=type=cache,target=/cache \
    cd /mnt/ImHex && \
    # compilers
    CC=o64-gcc CXX=o64-g++ OBJC=o64-clang OBJCXX=o64-clang++ \
        cmake -G "Ninja" \
        `# ccache flags` \
        -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -DCMAKE_OBJC_COMPILER_LAUNCHER=ccache -DCMAKE_OBJCXX_COMPILER_LAUNCHER=ccache \
        `# MacOS cross-compiling flags` \
        -DVCPKG_TARGET_TRIPLET=x64-osx-mytriplet -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/osxcross/target/toolchain.cmake -DCMAKE_OSX_SYSROOT=/osxcross/target/SDK/MacOSX12.1.sdk -DCMAKE_OSX_DEPLOYMENT_TARGET=12.1 \
        `# Override compilers for code generators` \
        -DBUILD_C_COMPILER=/usr/bin/gcc -DBUILD_CXX_COMPILER=/usr/bin/g++ \
        `# Normal ImHex flags` \
        -DIMHEX_GENERATE_PACKAGE=ON -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        `# other flags` \
        -DIMHEX_STRICT_WARNINGS=OFF \
        -B build
## Build ImHex
RUN --mount=type=cache,target=/cache <<EOF
    ccache -zs
    set -xe

    cd /mnt/ImHex
    cmake --build build --parallel $JOBS

    ccache -s
EOF

# package ImHex
## install genisoimage
RUN apt install -y genisoimage
## Move everything that need to be packaged inside a directory
RUN <<EOF
set -xe
cd /mnt/ImHex/build
mkdir installDir
mv imhex.app installDir
EOF
## generate dmg file
RUN cd /mnt/ImHex/build && genisoimage -V imhex.app -D -R -apple -no-pad -o imhex.dmg installDir

FROM scratch
COPY --from=build /mnt/ImHex/build/imhex.dmg .
