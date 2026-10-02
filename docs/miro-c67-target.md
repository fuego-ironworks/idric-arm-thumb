# MIRO C67 target note for the native ARM/Thumb backend

This note records the compiler-relevant C67 facts without turning a product name
into an ABI.

## Model/platform evidence

MIRO C67 product material names a MediaTek Helio G36. MediaTek specifies that
SoC as:

```text
CPU          8 x Arm Cortex-A53
max clock    2.2 GHz
CPU width    64-bit
GPU          IMG PowerVR GE8320
```

The retail listing also gives Android 14, 4 GB physical RAM, 64 GB storage and a
1600 x 720 / 90 Hz display.

Sources:

- https://www.mediatek.com/products/smartphones/mediatek-helio-g36
- https://www.newegg.com/miro-c67-6-75-black/p/23B-00MN-00005

## Relationship to this backend

The active `native-arm` line currently targets:

```text
Android armeabi-v7a
ARMv7-A
Thumb-2
VFPv3-D16 scalar Float32
softfp public call boundary
```

The C67's Cortex-A53 silicon does not prove that its Android userspace accepts
`armeabi-v7a`. A physical device receipt must establish the ABI list first.

If the C67 exposes a supported 32-bit Android ABI, the existing generic
ARMv7/Thumb-2 ABI remains the compatibility baseline. Do not raise that baseline
globally merely because this device has newer silicon.

## Optimization lane after physical ABI proof

Cortex-A53-specific optimization should be an optional tuning dimension,
separate from ABI correctness. Candidate work includes:

- instruction scheduling for Cortex-A53;
- measuring Thumb-2 versus A32 choices where the backend permits both;
- selectively using newer floating-point/SIMD instructions only behind an
  explicitly qualified target feature set;
- comparing Horner/evaluation kernels on the physical phone against the generic
  ARMv7 baseline;
- retaining exact code size and execution-time receipts for both forms.

The softfp Android public boundary remains independent of the internal arithmetic
instructions.

## Required C67 receipt

Before claiming C67 execution here, retain:

```text
ro.product.cpu.abi
ro.product.cpu.abilist
ro.product.cpu.abilist32
ro.product.cpu.abilist64
uname -m
Android SDK/build fingerprint
runtime page size
exact backend/compiler revision
physical execution result
```

Shared hardware facts belong in `isomorphisms/android-NDK/hardware/`; this file
only records the consequences for the native Idriç backend.
