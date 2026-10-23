# Canonical DEX consumer

This snapshot consumes `isomorphisms/android-NDK/dex/idric` version 0.2.0,
commit `08bcb26a4530c1e68835f93c281f3a3a4ff4a77b`. The canonical change is
[isomorphisms/android-NDK #30 — Canonicalize DEX/JNI and execute checked recursive calls](https://github.com/isomorphisms/android-NDK/pull/30).
The independent observer is
[isomorphisms/ai-ci #326 — Observe checked DEX calls and reject wrong runtime results](https://github.com/isomorphisms/ai-ci/pull/326),
commit `aa49ac75a6db8c8043b382932d39ac3e5bd2b0db`.

The previous consumer default is `6ecf378dd3e8dac59091ce8d7f3c3f315f43e4a5`.
Its source and history are retained in Git; no branch was merged or deleted.
Generic changes and framework, WebView, Wegert, Reddit and NativeActivity
compatibility serializers have been reconciled upstream before copying back.
The 14-module generic package and four application compatibility encoders use
the same DEX writer. Application fixtures remain separate packages. ARM/Thumb
machine-code development remains its independent history and is not a DEX
dependency.

`src/Backend/DEX`, `backend.ipkg` and `deps/idric-dex/Makefile` are verbatim
vendored content. The root Makefile is a thin consumer adapter. The lock binds
all source files, including documentation and compatibility adapters, with a
Git source-tree identity. The checker uses an isolated temporary index and
never alters the user's index. It rejects changed, staged or newly added
compiler files, a changed package, changed build rules and a wrong canonical
revision. The one-argument mode verifies an offline snapshot; the two-argument
mode additionally verifies the canonical checkout's exact commit and blobs.

To update: inspect current upstream and consumer changes, reconcile upstream,
qualify the canonical package, copy its source/package/build snapshot, then
update the lock's exact commit and identities in one reviewed change. Do not
edit copies to fix a consumer build. Retain application behavior and acceptance
fixtures and run their regressions against the new canonical implementation.

Commands executed and consumer test results are recorded in `receipt.tsv`.
Canonical executable fixtures, detailed test commands and pins are retained in
[`qualification/`](https://github.com/isomorphisms/android-NDK/tree/08bcb26a4530c1e68835f93c281f3a3a4ff4a77b/dex/idric/qualification)
and its `reconciliation-receipt.tsv`. Those receipts prove checked scalar calls,
recursion and cross-module execution on API29 x86_64 ART: 43 assertions and a
compiled wrong-helper rejected with exit 73. Host adapter checks do not confer
new physical Wegert or Reddit acceptance.

Actual ICU `b1c19dc281e5e7d3d326c9275093fb379bafd4bd` now passes its `IO ()`
entrypoint ABI, but lowering stops at `System.prim__getArgCount`, exit 1 without
a DEX. Runtime arguments, required data representations/primitives and complete
IO/JNI remain unimplemented. Real ICU DEX/ART HTTP and HTTPS, physical A1/C67
and Cat Food packaging/publication/installation are NOT_VERIFIED. No native
transport implementation was rewritten and no stock GCC substituted for ICK.
