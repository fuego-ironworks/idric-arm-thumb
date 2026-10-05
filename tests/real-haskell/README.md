# Real-Haskell branch corpus

This directory keeps small decision structures taken from real Haskell code next to mechanically reduced Idriç fixtures for the ARM/Thumb backend.

The point is not to claim that an isolated microbenchmark represents the speed of GHC, Aeson, or a whole application.  The point is to preserve recognizable source-level branch shapes, compile comparable kernels, inspect what native code each compiler chooses, and eventually time the same decision problem on the same ARM target.

## Why these are not in `Prelude.hs`

`Prelude` is mostly the public import/re-export surface.  The implementations worth studying live lower down in `ghc-internal`, `base`, and ordinary Haskell libraries.  The first pass therefore starts there rather than manufacturing synthetic examples.

## Seed corpus

| Corpus entry | Pinned upstream source | What the original code does | Branch shape | Local Idriç reduction |
| --- | --- | --- | --- | --- |
| GHC lexer control escape | https://github.com/ghc/ghc/blob/cd653714596108ebf47450202b6748c20bb53799/libraries/ghc-internal/src/GHC/Internal/Text/Read/Lex.hs | Parses Haskell control escapes such as `\\^A` through `\\^_` | dense 33-way exact `case` including failure | `idric/GhcLexControl.idric` |
| GHC `showLitChar` | https://github.com/ghc/ghc/blob/cd653714596108ebf47450202b6748c20bb53799/libraries/ghc-internal/src/GHC/Internal/Show.hs | Chooses how a `Char` should be escaped when rendered as Haskell source | ordered guards plus sparse exact control-character cases | `idric/GhcShowLitChar.idric` |
| GHC UTF-8 decoder | https://github.com/ghc/ghc/blob/cd653714596108ebf47450202b6748c20bb53799/libraries/ghc-internal/src/GHC/Internal/Encoding/UTF8.hs | Decodes one UTF-8 code point and validates continuation bytes | ordered byte-range tree with nested failure checks | `idric/GhcUtf8Lead.idric` (lead-byte decision only) |
| Aeson JSON value parser | https://github.com/haskell/aeson/blob/51c4db6d9dbe5c6900e626bf6a58fd00e8ef9f09/attoparsec-aeson/src/Data/Aeson/Parser/Internal.hs | Dispatches on the first non-space byte of a JSON value | sparse exact byte cases plus digit/hyphen range | `idric/AesonJsonValueDispatch.idric` |

`originals/` retains the relevant Haskell excerpts and their pinned source links.  They are provenance/reference material, not standalone modules.  Upstream license texts are retained under `upstream-licenses/`.

The Idriç reductions intentionally return a `Float32` sentinel selected from `Float32Buffer`. This preserves the source decision without turning the copied parsers into runtime dependencies. `fixtures.ipkg` typechecks all four against the existing `native-arm` compiler/RendererPrimitives profile after the backend build. This gate proves source checking only: it does not claim that all four have generated/assembled/executed ARM code.

## Benchmark

`bench/BranchCorpus.hs` contains self-contained Haskell reductions of the same four decision kernels. The native-ARM workflow compiles that foreign reference with `ghc -O2` and runs its five-repetition median/checksum report. GHC is a comparison oracle here, not an alternative Idriç backend or a production build toolchain.

The benchmark is deliberately narrow:

- Inputs are generated at runtime so the decision cannot be folded to a constant.
- The classifier functions are `NOINLINE`, so the measured loop repeatedly enters the compiled decision kernel.
- Results are accumulated into a checksum so calls cannot be discarded.
- GitHub-hosted-runner timings are evidence about this microbenchmark on that runner, not a cross-machine performance claim.
- There is no Haskell-vs-Idriç speed ratio. Native lowering has evolved since this corpus was first proposed; this PR makes no blanket unsupported-control-flow claim. Add an Idriç timing column only after each corresponding fixture has generated, assembled, and executed on the same declared target.

GHC assembly inspection is at least as important as the timing: a surprising result should be explained by the emitted branch tree, jump table, arithmetic collapse, or other native lowering rather than by guessing from source syntax.

## Next candidates

This is a seed, not an attempt to crawl all of GitHub in one commit.  Good follow-ups already found include:

- GHC's generated Unicode general-category lookup, a very large nested threshold tree: https://github.com/ghc/ghc/blob/cd653714596108ebf47450202b6748c20bb53799/libraries/ghc-internal/src/GHC/Internal/Unicode/Char/UnicodeData/GeneralCategory.hs
- the named ASCII-escape alternatives in the same GHC `Text.Read.Lex` source;
- more parser/token dispatch from GHC and parser libraries;
- protocol/tag dispatch from network and binary-format libraries;
- state-machine transitions where the source is still small enough to preserve faithfully.

A Real World Haskell book example can be added separately if useful, but the book material has a different CC BY-NC licensing story.  This seed sticks to the permissively licensed GHC and Aeson sources so copied excerpts can remain in a public compiler test repository without mixing licensing assumptions.

## Retained native profile

This corpus is historical research scaffolding, checked against the current
`native-arm` line's declared immutable Idriç profile
`081b9cde0591154839fb5d80d76e5570e0436300`. Its Float32-buffer sentinels are
not a selected Boolean, text, node or ordinary browser-value ABI; #31's ordered
language/memory gates remain authoritative for new implementation.

The candidate's native assembly/link stages use Android NDK
`29.0.14206865`, with the exact revision checked. `ci/build-toolchain.tsv`
records ICK `73af2ef14fd81a1a4f2cf977aea87aa9d537cad8` and the absent
qualification for these exact Thumb/VFP/STRH and freestanding Linux-QEMU
translations. The GHC executable is a foreign reference oracle, not an
alternative production compiler. None of these hosted receipts is a phone or
tablet acceptance claim.
