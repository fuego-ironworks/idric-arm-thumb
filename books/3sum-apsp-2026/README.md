# 3SUM / APSP 2026 breakthrough

Primary paper:

> Josh Alman and Virginia Vassilevska Williams, **“Truly Subquadratic 3SUM and Truly Subcubic APSP via Triangles in Sparse Lopsided Graphs,”** arXiv:2610.06783v1, 5 October 2026.

Primary links:

- https://arxiv.org/abs/2610.06783
- https://arxiv.org/html/2610.06783v1
- Lean formalization: https://github.com/anthropics/formal-math/tree/main/3sum-apsp

The arXiv version is 76 pages and is licensed CC BY 4.0.

## What actually changed

The paper gives the first polynomial improvements over the familiar quadratic 3SUM and cubic APSP bounds in the stated integer models:

- 3SUM on polynomially bounded integers: deterministic (O(n^{1.9992})).
- APSP on directed graphs with polynomially bounded integer weights and no negative cycles: deterministic (O(n^{2.9995})).
- The same line also gives improvements for Exact Triangle, real-valued variants through known randomized reductions, weighted clique variants, thin hinted-OMv regimes, and a collection of problems connected by fine-grained reductions.

The important point for implementation work is that this is **not** a new short 3SUM inner loop and it is **not** a new short APSP relaxation loop.

The common engine is a selective thin matrix-product algorithm.

Let

[
Xinmathbb Z^{N	imes D},qquad
Yinmathbb Z^{D	imes N},
]

with (Dle N^{1/18}), and let (W) be a requested set of at most (N^2/sqrt D) output positions. The paper computes only

[
(XY)[I,J],quad (I,J)in W,
]

in

[
O(N^2/D^{0.063})
]

word operations. It is therefore cheaper than materializing the entire (N	imes N) product and cheaper than evaluating every requested inner product independently.

## Core mechanism

The algorithm starts from the rectangular-matrix-multiplication line of Coppersmith and, below it, a ten-multiplication identity of Schönhage.

The useful structural facts are:

1. recursive encodings are shared among many desired outputs;
2. a recursive call can be skipped when it contributes to no requested output;
3. the union of leaves needed by a sparse requested set is much smaller than evaluating each output separately;
4. the asymmetric graph interpretation is exactly a lopsided sparse-triangle problem.

A useful dependency picture is:

[
	ext{wanted entries of a thin matrix product}
longrightarrow
	ext{lopsided All-Edges Sparse Triangle}
longrightarrow
	ext{Exact Triangle}.
]

Then established reductions provide the two headline paths:

[
	ext{3SUM}longrightarrow	ext{Exact Triangle}
]

and

[
	ext{APSP / }(min,+)	ext{-product}longrightarrow	ext{Exact Triangle}.
]

For the implementation work in this repository, keep the direction straight: the small assembly fixtures are semantic/compiler workloads; they do **not** by themselves instantiate the asymptotic algorithm.

## ARM / Thumb reading

There are at least four useful layers.

### 1. Small semantic oracles

These are ordinary algorithms whose machine behavior is easy to inspect:

- cubic 3SUM;
- sorted two-pointer 3SUM;
- open-addressed hash 3SUM;
- Floyd–Warshall;
- blocked Floyd–Warshall;
- direct scalar ((min,+))-product.

They exercise loops, indexed loads, comparisons, condition-code use, branches, stack/register pressure, integer-width contracts, and memory layout.

### 2. Reduction fixtures

Small exact instances can make the paper’s reduction boundaries executable:

- Exact Triangle;
- Convolution-3SUM;
- lopsided All-Edges Sparse Triangle;
- sparse wanted entries of a thin product.

Each should have a brute-force oracle.

### 3. Algebraic microkernels

Rather than trying to translate the entire asymptotic construction directly to assembly, isolate:

- Schönhage’s ten multiplication leaves;
- the associated plus/minus linear forms;
- recursive wanted-output masks;
- a tiny pruned recursion;
- direct-vs-full-vs-pruned thin-product checks.

These are much better compiler targets than a 76-page monolithic translation.

### 4. Full asymptotic line

Only after the preceding pieces agree should the full reduction stack be treated as an implementation target. Any claim of (n^{1.9992}) or (n^{2.9995}) belongs here, not to the simple 3SUM/APSP fixtures.

## Reading files

- [direct-citations-a-c.md](direct-citations-a-c.md)
- [direct-citations-d-k.md](direct-citations-d-k.md)
- [direct-citations-l-r.md](direct-citations-l-r.md)
- [direct-citations-s-z.md](direct-citations-s-z.md)

Together those files annotate every item in the primary paper’s reference list. A short note tells what the cited work contributes or why it matters to this literature. Where only the citation context/title was checked, the note says so rather than pretending a full-paper review.

- [direct-citations.tsv](direct-citations.tsv) is the machine-readable seed list.
- [bibliography-spider.py](bibliography-spider.py) resolves those seeds through OpenAlex and follows their reference lists one level.
- [one-hop-bibliography.md](one-hop-bibliography.md) records the checked-in recursive bibliography snapshot and its coverage status.

## Scope rule for the spider

Depth is deliberately one:

[
	ext{Alman–Vassilevska Williams 2026}
	o
	ext{direct references}
	o
	ext{their references}.
]

The second arrow is bibliographic only. The third-level papers are not summarized merely because they occur in a reference list.

The spider is fail-closed on ambiguous title matches. It records unresolved seeds rather than silently attaching the wrong paper.
