# a70q kernel audit for LineageOS 23.2

This is the supplied Samsung kernel 4.14.190, starting at `f6d944f09fc9` on the
preserved lineage-22.2 branch. The lineage-23.2 branch is a compiler-validated
bring-up baseline, **not an Android 16 runtime-ready kernel**.

After confirming the account's CPU/RAM quota and shared-server rules, set
`A70Q_BUILD_JOBS` accordingly. From the Android source root run:

```sh
JOBS="$A70Q_BUILD_JOBS" kernel/samsung/sm6150/scripts/lineage/build-a70q.sh
```

The script uses platform clang-r547379, LLVM IAS and the existing GCC cross paths,
a70q_defconfig, Image.gz-dtb and dtbs. It does not modify the source defconfig,
flash hardware or package a ROM. A70 has twelve enabled EUR revision overlays;
the platform's kernel image rules assemble them into dtbo.img separately.
The common device BoardConfig pins the same Clang revision. This is a separate
kernel build; success does not validate Android's boot/recovery packaging.
`JOBS` is required explicitly; the script does not infer an allocation from the
host's CPU count. Do not run it alongside another build.

The old GNU assembler rejected Clang's generated assembly. LLVM IAS compiled
successfully. Modern Clang also diagnosed two `%10s` widths for 10-byte CoreSight
buffers; they are corrected to `%9s`, preserving the existing rejection of inputs
with length >= 10. Other existing kernel warnings/section mismatches remain.
No Android 16 network backport is claimed by this compiler cleanup.

Known runtime gap at the recorded platform revision:

* `packages/modules/Connectivity/bpf/loader/NetBpfLoad.cpp` rejects V on < 4.19
  and Android 16 (25Q2+) on < 5.4.
* `packages/modules/Connectivity/bpf/netd/BpfHandler.cpp` independently rejects
  those kernels. This kernel reports 4.14.190.
* Some BPF additions are present, but definitions of individual helpers do not
  establish a complete backport. Verifier, map/syscall, cgroup socket hooks and
  networking behavior need a reviewed feature audit/backport plus runtime tests.
* Preserve the real kernel release. Do not simply spoof 5.4 or delete userspace
  checks; the required behavior must be implemented and validated.

The kernel retains 4 KiB pages, vendor drivers, encryption setup and boot header
layout. Runtime validation must include early boot/pstore, SELinux enforcing,
BPF/netd/tethering, binder, encrypted storage, suspend/resume, thermal/charging
and all hardware revisions. No device was booted or flashed during this work.
