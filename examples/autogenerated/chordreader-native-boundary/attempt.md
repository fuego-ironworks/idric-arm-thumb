# Program attempt: ChordReader on maintained native ARM

Purpose: qualify a real checked Text normalization operation for the Android
application, without substituting C code for compiler output.

Type sketch: canonical_accidental maps decoded Text to decoded Text and replaces
an ASCII sharp alias. The operation needs a Text ABI and a Text-result branch.

Starting native-arm head: ac981d6a9a61e75ad913768f74353829d0cab2e1.
Maintained compiler: 0e8cfdd1106ebdeffd01b6c519880ea3afc7dc35 plus the checked
Unicode subtraction patch (published source28c5755d37fb868f1b9c2f5d8fab1ce2b2ada663).

Actual first build diagnostic: old AVar/ANF/ANFDef constructors were undefined
after the maintained compiler's descriptive ANF API migration. Migrated the
native lowerer and compiler phase selection to that API. Incremental host
compilation also tried to execute target-only RendererPrimitives externals;
separated their typechecked package from the host executable and disabled
incremental host code generation for that primitive declaration check.

Executed `make driver` with the current compiler. The repaired host driver
emitted the existing checked WordKernels.idric fixture (12 KiB assembly), and
NDK29 assembled it into an independently inspected ELF32 ARM object. No ARM
CPU execution is claimed by that assembly test.

Executed the actual NativeCore.idric export through that driver. It rejects
the Text/String source ABI before producing assembly; rejection.txt retains the
exact diagnostic. A runtime-free word/Float32 ABI cannot carry the parser's
recursive Text, records and collections. Adding a managed representation and
ownership/runtime ABI remains substantial work rather than a word-ABI cast.

The application therefore retains its separately tested Idriç host core and
executable DEX subset, with the explicitly authorized C+Lua contingency for
blocked Android operations. This result is not native ARM application acceptance.
