# Idriç DEX backend

Direct Android Runtime DEX backend for Idriç.

The canonical reusable compiler now lives in
[`isomorphisms/android-NDK/dex/idric`](https://github.com/isomorphisms/android-NDK/tree/08bcb26a4530c1e68835f93c281f3a3a4ff4a77b/dex/idric).
This repository consumes version **0.2.0** at that exact commit. The source
snapshot keeps the existing paths usable offline; it is not an independently
maintained compiler. `deps/idric-dex.lock` records the commit, source tree,
package blob and build-rule blob. `deps/idric-dex/check-pin.grease` hashes the
actual worktree, including staged and untracked source, before a build. CI also
checks those identities against a fresh exact-revision canonical checkout and
rejects five deliberately divergent copies. Compiler fixes belong upstream;
consumer updates copy the verified snapshot and update the lock together.

[`deps/idric-dex/README.md`](deps/idric-dex/README.md) records migration,
commands and the current evidence boundary. All existing application fixtures
and separate ARM/Thumb history are retained.

This development line is a sibling of the ARM/Thumb backend. Both consume checked compiler forms, but DEX lowering, encoding, packaging, and acceptance are independent of ARM instruction selection and execution.

DEX is ART's class-and-method executable format. Direct DEX output may use
classes, inheritance, constructors, Android framework methods, and native
method declarations when the program or Android entry boundary needs them.
The constraint here is that Idriç writes those DEX structures directly: Java
source, `javac`, Kotlin, Gradle, and `d8` are not intermediate compiler stages.

The DEX executable registers only the `dex` code generator. Its acceptance path produces `classes.dex`, validates it independently, and executes it on ART. ARM source modules, ARM emulation, and QEMU are not part of the DEX build or correctness receipt.

## Supported targets

Maintained Linux GitHub Actions run on Ubuntu. Historical Debian receipts
remain historical evidence; the runner configuration alone proves no build.

The supported device environment is a physical Android phone. A low-resource
x86_64 Android emulator is retained only as a fast ART sanity check; it is not
accepted as proof of the phone target. Physical-device receipts record the
Android build fingerprint and CPU ABI, and the Wegert/JNI path builds the
native library for the attached phone's ABI rather than assuming x86_64.

Do not add another host environment merely because it is convenient for CI.
Prefer the lightest test environment that still represents a deployed target.

The generic compiler package contains only the checked-ANF DEX backend. A
separate `wegert-dex.ipkg` package contains the current direct-DEX
NativeActivity/JNI adapter used to exercise an Android application boundary.
That adapter is DEX/Android work, but it is not presented as generic Idriç
lowering.

See `src/Backend/DEX/README.md` and `tests/dex/README.md` for the current executable slice and evidence layers.

## Licensing and provenance

The repository license is GPL-3.0-or-later where contributors have authority
to grant it. [`THIRD_PARTY.md`](THIRD_PARTY.md) records external tools and one
unresolved copied-source issue in the DEX compiler-handoff glue. Independent
Git ancestry from ARM fixes the backend architecture; it does not by itself
erase copied-text provenance.


## Scalar numeric references

The ARM Thumb numeric-format references are collected in
[`specifications/`](specifications/README.md): Float16/binary16, OCP FP8,
OCP E3M2, Ootomo-Naruse E5M3, and Idris 2 Bits8.
