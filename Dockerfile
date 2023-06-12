FROM ubuntu:jammy AS busybox-prebuild

RUN apt-get update && \ 
    apt-get -y install \
        binutils build-essential libtool texinfo \
        gzip zip unzip patchutils curl

RUN curl https://busybox.net/downloads/busybox-1.36.1.tar.bz2 -o busybox-1.36.1.tar.bz2

RUN tar jxf busybox-1.36.1.tar.bz2 && \
    cd busybox-1.36.1

COPY patch/busybox_config busybox-1.36.1/.config
COPY patch/make_rootfs.sh busybox-1.36.1/make_rootfs.sh

RUN cd busybox-1.36.1 && \
    make -j4 && make install && \
    bash make_rootfs.sh


FROM ubuntu:jammy

RUN apt-get update && \ 
    apt-get -y install \
        binutils build-essential libtool texinfo \
        gzip zip unzip patchutils curl git \
        make cmake ninja-build automake bison flex gperf \
        grep sed gawk bc \
        zlib1g-dev libexpat1-dev libmpc-dev \
        libglib2.0-dev libfdt-dev libpixman-1-dev \
        libelf-dev libssl-dev \
        clang-format clang-tidy clang-tools clang \
        clangd libc++-dev libc++1 libc++abi-dev libc++abi1 \
        libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev \
        libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm \
        python3-clang \
        qemu-system-x86 cpio && \
        rm -rf /var/lib/apt/lists/*

    RUN git clone --depth=1 -b rust-e1000 https://github.com/fujita/linux.git && \
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y && \
        . "$HOME/.cargo/env" && \
        cd linux && \
        rustup override set $(scripts/min-tool-version.sh rustc)  && \
        rustup component add rust-src  && \
        cargo install --locked --version $(scripts/min-tool-version.sh bindgen) bindgen   && \
        rustup component add rustfmt  && \
        rustup component add clippy   && \
        make LLVM=1 rustavailable



COPY --from=busybox-prebuild /busybox-1.36.1/rootfs /rootfs/
COPY patch/kernel_config linux/arch/x86/configs/kernel_config_patch.config

RUN . "$HOME/.cargo/env" && \ 
    cd linux && \
    make LLVM=1 O=build x86_64_defconfig && \
    make LLVM=1 O=build kernel_config_patch.config && \
    make LLVM=1 O=build -j4

COPY playground playground



