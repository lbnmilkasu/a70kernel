#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Run from an Android source checkout. This does not flash or package a ROM.
set -euo pipefail

# The host's CPU count is not the account's allocation on shared builders.
# Require an explicit job count after checking the account's CPU/RAM limits.
if [[ ! ${JOBS:-} =~ ^[1-9][0-9]*$ ]]; then
    echo "Set JOBS to a positive integer within your account's confirmed CPU/RAM quota." >&2
    exit 1
fi

a70q_top=$(pwd -P)
a70q_source="$a70q_top/kernel/samsung/sm6150"
a70q_out=${A70Q_KERNEL_OUT:-"$a70q_top/out/a70q-kernel-check"}
a70q_clang="$a70q_top/prebuilts/clang/host/linux-x86/clang-r547379/bin"
if [[ ! -x "$a70q_clang/clang" || ! -f "$a70q_source/Makefile" ]]; then
    echo "Run from the LineageOS 23.2 source root with clang-r547379 installed." >&2
    exit 1
fi
export PATH="$a70q_clang:$a70q_top/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:$a70q_top/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH"
a70q_args=(-C "$a70q_source" O="$a70q_out" ARCH=arm64 SUBARCH=arm64
    LLVM_IAS=1 CC=clang HOSTCC=clang HOSTCXX=clang++ LD=ld.lld AR=llvm-ar
    NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip
    CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android-
    CROSS_COMPILE_ARM32=arm-linux-androidkernel- CROSS_COMPILE_COMPAT=arm-linux-androidkernel-)
make "${a70q_args[@]}" a70q_defconfig
make -j"$JOBS" "${a70q_args[@]}" Image.gz-dtb dtbs
