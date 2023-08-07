FROM ubuntu:22.04

ENV PATH                $PATH:/osxcross/target/bin
ENV LD_LIBRARY_PATH     /osxcross/target/lib
ENV OSX_VER             12.1
ENV OSXCROSS_SDK        /osxcross/target/SDK/MacOSX${OSX_VER}.sdk
ENV OSXCROSS_TARGET     darwin21.2
ENV OSXCROSS_TARGET_DIR /osxcross/target
ENV OSXCROSS_HOST       x86_64-apple-darwin21.2

# -- DOWNLOADING STUFF

# Install common stuff
RUN export DEBIAN_FRONTEND=noninteractive &&\
    export TZ=Etc/UTC &&\
    dpkg --add-architecture i386 &&\
    apt update &&\
    apt -y install lsb-release build-essential python3 python3-pip git wget zip unzip pkg-config curl ninja-build software-properties-common gnupg libssl-dev ccache

# Install clang 17
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 17 &&\
    apt clean &&\
    ln -s /usr/bin/clang-17 /usr/bin/clang &&\
    ln -s /usr/bin/clang++-17 /usr/bin/clang++

# Install vcpkg
RUN cd / &&\
    git clone --depth 1 -b my_crosscompile https://github.com/Nemirtingas/vcpkg.git vcpkg &&\
    cd /vcpkg &&\
    ./bootstrap-vcpkg.sh -disableMetrics &&\
    ln -s /vcpkg/vcpkg /usr/bin/ &&\
    vcpkg install vcpkg-cmake &&\
    ln -s /vcpkg/downloads/tools/cmake-*/cmake-*/bin/cmake /usr/bin/

## Clone osxcross
RUN git clone https://github.com/tpoechtrager/osxcross /osxcross

## Download SDK
RUN cd /osxcross/tarballs && wget https://github.com/joseluisq/macosx-sdks/releases/download/12.1/MacOSX12.1.sdk.tar.xz

# Init stuff
## setup ccache dir
ENV CCACHE_DIR /cache/ccache

# Install triplet file
COPY x64-osx-mytriplet.cmake /vcpkg/triplets/community

# -- BUILDING STUFF
ARG JOBS 1

# Install osxcross
## Build cross-compiler clang-17
RUN --mount=type=cache,target=/cache <<EOF
    ccache -zs
    
    cd /osxcross
    UNATTENDED=1 CC=/usr/lib/ccache/clang-17 CXX=/usr/lib/ccache/clang++-17 ./build.sh
    
    ccache -s
EOF
## Install dependencies for gcc-13
RUN apt install -y gcc g++ zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev
## Build cross-compiler gcc-13
RUN --mount=type=cache,target=/cache <<EOF
    ccache -zs

    cd /osxcross
    UNATTENDED=1 CC=/usr/lib/ccache/gcc CXX=/usr/lib/ccache/g++ GCC_VERSION=13.2.0 ./build_gcc.sh

    ccache -s
EOF

## Copy a working toolchain.cmake (the original makes weird errors with zlib when installed libpng, idk why)
COPY toolchain.cmake /osxcross/target
