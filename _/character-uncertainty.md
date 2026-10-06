# Character uncertainty on ARM Thumb

Status: target-design note, 2026-10-06. High-level semantics belong in Idriç; this repository explores compact representations and deterministic kernels after those semantics are fixed.

## Companion notes

- [Econometrician in a Box](https://github.com/bl4ckb4ll/econometrician/blob/main/notes/character-uncertainty.md)
- [Idriç](https://github.com/isomorphisms/Idric/blob/Idriç/_/character-uncertainty.md)
- [ICK](https://github.com/dilapidated-shed/ick/blob/main/docs/character-uncertainty.md)

## Two distinct neighborhood kernels

### Visual relation

For an initial lowercase Latin fixture, `b p q d` form a useful close family because their rendered shapes differ largely by reflection/rotation and stem/bowl placement. This is a fixture for the relation, not a universal claim across fonts, scripts, or readers.

### Input-geometry relation

For QWERTY, one deliberately broad 3×3 neighborhood centered on `D` is

```text
W E R
S D F
Z X C
```

This is a spatial relation and says nothing about glyph similarity.

On a touchscreen, prefer actual touch coordinates and key rectangles when available. A wrong-key label is already a lossy reduction of the physical event.

## Representation experiments

Do not make the high-level type equal to one ARM layout. Candidate low-level representations to measure include:

- small sparse candidate list: character/code point + tagged evidence + compact cost;
- ASCII fast path using byte candidates while retaining a separate general Unicode path;
- bitset only for a deliberately bounded alphabet;
- keyboard coordinates plus a distance kernel rather than pre-expanding every neighbor;
- fixed-point costs or log weights only when their scale and interpretation are explicit.

An integer confidence byte without a defined calibration is not a probability.

## Kernel candidates

Useful small deterministic ARM/Thumb kernels:

- map an observed key position to neighboring key positions;
- compute distance from a touch point to candidate key centers/bounds;
- enumerate a visual-neighborhood fixture;
- merge candidate sets while retaining evidence tags;
- rank by an explicitly supplied cost function;
- convert a calibrated confusion-table representation into a compact target form without changing its semantics.

Measure code size, data size, cycles, and branch behavior separately from semantic correctness.

## Unicode boundary

Do not equate character with one byte. An ASCII/QWERTY prototype may use bytes internally, but the interface must state that restriction. General character identity belongs to the source-language semantics and may require a Unicode scalar/code-point representation or a higher text abstraction.

## Acceptance fixtures

- `d` under visual evidence can produce `{b,d,p,q}`.
- `d` under QWERTY physical evidence can produce the eight surrounding positions above.
- The two candidate sets can overlap or differ without overwriting provenance.
- No target kernel invents probabilities.
- A compact representation round trip preserves candidate identity, channel, and declared weight/cost semantics.

Econometrician in a Box owns statistical calibration; Idriç owns language semantics; ARM Thumb owns compact low-level target work; ICK owns C/compiler-facing representation and lowering experiments.
