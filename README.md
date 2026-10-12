# Idriç ARM/Thumb backend

Direct ARMv7 Thumb-2/VFP backend for Idriç, without routing numerical leaves through C.

## Development lines

`native-arm` is the active native ARM/Thumb development line. It reconciles the former `arm-thumb-test-suite` and `branching-dispatch-fixtures` descendants.

`main` intentionally remains the separate direct-DEX line. Advancing native ARM/Thumb does not require merging this line into DEX.

The leaf slice compiles exported, closure-free Float32 and Bits32 functions
with checked one-word representations, arithmetic and caller-owned Float32 loads.

```text
.idric source
  -> current Idriç parser/typechecker/erasure
  -> Compiler.ANF
  -> validated runtime-free leaf IR
  -> deterministic Thumb-2/VFP .S
  -> ELF32 ARM object
```

The proof fixture is `examples/Affine.idric`:

```idris
%export "arm-thumb:evaluate_affine"
evaluate_affine : Float32 -> Float32 -> Float32 -> Float32
evaluate_affine a x b =
  float32_add (float32_multiply a x) b
```

The backend is pinned to Idriç commit:

```text
081b9cde0591154839fb5d80d76e5570e0436300
```

That compiler deliberately remains implemented on the current Idris 2 internals, so this backend uses its existing `Compiler.ANF` custom-codegen seam instead of creating a second competing Idriç IR.

## Target ABI

- Android `armeabi-v7a`
- ARMv7-A, Thumb-2
- VFPv3-D16 scalar Float32 arithmetic
- softfp C boundary: up to four one-word arguments enter through `r0`-`r3`; a Float32 or Word32 result leaves as raw bits in `r0`
- 8-byte-aligned stack frame
- no heap, GC, closures, or Idris runtime in the emitted numerical leaf

## Device notes

- [MIRO C67 target mapping](docs/miro-c67-target.md) keeps the Helio G36 /
  Cortex-A53 tuning opportunity separate from the still-unverified physical
  Android ABI.

## Build and verify

Build the pinned Idriç compiler and install its compiler API/libraries, then run:

```sh
make verify IDRIC=/path/to/Idric/build/exec/idris2
```

`make verify` checks the compiler revision, typechecks and builds the custom driver, compiles the real `.idric` affine fixture through `--cg arm-thumb`, requires `vmul.f32` and `vadd.f32` in the generated assembly, assembles it with Clang for `armv7a-linux-androideabi21`, and checks that the result is an ELF32 ARM object.

GitHub Actions performs that path from a clean checkout by bootstrapping the exact pinned Idriç revision first.

## Current boundary

Implemented now:

- one exported runtime-free function at a time or multiple independent exports
- zero to four explicit one-word arguments with checked representations
- `Float32` or `Bits32` result
- local copies
- `float32_add`
- `float32_multiply`
- Float32 subtract, divide, negate, absolute value and square root
- indexed caller-owned `Float32Buffer` loads
- modulo-2³² Bits32 add, subtract and low multiplication
- unsigned high multiplication, one-word carry and borrow
- word AND, OR and XOR
- checked constants and constant logical shifts from 0 through 31

Rejected now:

- 64-bit `Int` ABI and Float32 constants
- pointer results and more than four argument words
- dynamic shifts and shifts outside 0 through 31
- branches and comparisons
- recursion or general calls
- constructors, closures, allocation, strings, IO, JNI, or Android lifecycle code

The older `idris-arm-backend` remains useful reference code for the broader arithmetic/buffer subset. This repository is the Idriç-specific line and advances only when the current Idriç compiler accepts and verifies the slice.

## Next slice

`mul-word-test` compiles `WordKernels.idric` through the real driver, executes
229 independent Integer-oracle vectors under QEMU, and retains the 916 actual
result bytes. Its gates require Android ELF32 Thumb-2 objects with no undefined
helpers, correct source refusals and arithmetic defects that retain their
nonzero status through the outer Idriç runner. Android object generation and
emulated Linux-user execution are separate evidence; neither is physical MIRO A1
execution. The qualified native ICK source was evaluated at
143e29580c2644ea0f345fe609fa5673d036865d; the available binary targets x86_64,
so its ARM assembler/linker path has not been qualified. These tests use the
declared NDK 29.0.14206865 assembly/link stage.

ARM-2 depends on accepted exact arithmetic contracts. Typed word buffers,
comparisons and a constrained loop remain the next native backend slice.
