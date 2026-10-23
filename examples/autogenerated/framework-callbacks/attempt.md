# Framework callback classes

Purpose: emit Android framework subclasses from checked Idriç descriptions,
without Java, Kotlin, d8 or an assembled Smali candidate. ZoneEdit requires an
Activity and a WebViewClient with native virtual callbacks.

The domain is a list of class declarations. Each declaration names its class,
superclass, optional native library, and native virtual method signatures.
Signatures distinguish result type from ordered parameter types. Constructors
delegate to the declared superclass; an optional class initializer loads the
declared library through the Android runtime's System.loadLibrary operation.

Central operation: checked class descriptions → Either diagnostic DEX bytes.
Writing the resulting file is a separate IO action. Invalid descriptors,
duplicate classes/methods, empty declarations, unsupported names and oversized
identifier pools must fail before publication. Native methods have no code
items. Constructor and class-initializer code belongs to the backend.

This is a typed Android class adapter, not a claim that generic ANF lowering
already implements objects or arbitrary Android calls. C/JNI owns callback
bodies in the consumer. The adapter itself is checked by the maintained Idriç
compiler and runs on the host to encode DEX directly.

Result: the adapter typechecks with compiler
`0e8cfdd1106ebdeffd01b6c519880ea3afc7dc35`. The compiled fixture passes eight
specific rejection cases and deterministic byte comparison. Pinned baksmali
3.0.10 independently decodes constructor delegation, library initialization,
and the native virtual signature. ZoneEdit additionally emits two classes
including overloaded callbacks. No Java/Smali production fallback is used.

ART and physical-device execution remain separate, unclaimed evidence. The
remaining general-language boundary is source-level Android object lowering
through the arithmetic ANF backend; this class adapter does not claim it.
