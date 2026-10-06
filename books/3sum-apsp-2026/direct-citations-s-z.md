# Direct cited-paper notes — S–Z

These are short reading summaries for the papers/books cited directly by Alman–Vassilevska Williams (2026). They are deliberately conservative: an entry can summarize the paper’s scope and its role in this literature without claiming that every theorem in the source was independently rederived here.

Primary source: https://arxiv.org/abs/2610.06783

## San04 — Dynamic transitive closure via dynamic matrix inverse

Piotr Sankowski (2004).

Studies dynamic algorithms or conditional lower bounds, many of which use APSP/3SUM/OMv hypotheses and therefore need careful direction-of-reduction checks after the new upper bounds.

## SB93 — Efficient computation of the DFT with only a subset of input or output points

Henrik V. Sorensen; C. Sidney Burrus (1993).

Computes only selected DFT inputs/outputs efficiently; another direct precedent for output-sensitive pruning in an algebraic transform.

## Sch81 — Partial and total matrix multiplication

Arnold Schönhage (1981).

Introduces the partial/total matrix-multiplication framework and the ten-multiplication identity underneath the 2026 recursive thin-product construction; this is one of the most load-bearing papers in the collection.

## Sch99 — A probabilistic algorithm for k-SAT and constraint satisfaction problems

Uwe Schöning (1999).

Gives the classic randomized local-search algorithm for k-SAT.

## Sei95 — On the all-pairs-shortest-path problem in unweighted undirected graphs

Raimund Seidel (1995).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## SEO03 — Preprocessing chains for fast dihedral rotations is hard or even impossible

Michael Soss; Jeff Erickson; Mark H. Overmars (2003).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## Str69 — Gaussian elimination is not optimal

Volker Strassen (1969).

Introduces Strassen’s subcubic matrix multiplication, the canonical recursive bilinear algorithm and the conceptual starting point for modern algebraic matrix-multiplication work.

## Str73 — Vermeidung von Divisionen

Volker Strassen (1973).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## SVX27 — The limits of black-box reductions for all-pairs triangle detection

Nathan Sheffield; Virginia Vassilevska Williams; Zoe Xi (2027).

Studies triangle detection/listing/weight variants or reductions through them; triangle problems form the central junction between the new thin-product algorithm and 3SUM/APSP.

## Tak92 — A new upper bound on the complexity of the all pairs shortest path problem

Tadao Takaoka (1992).

Studies shortest-path algorithms or complexity and belongs to the historical/technical APSP lineage.

## Tak04 — A faster algorithm for the all-pairs shortest path problem and its application

Tadao Takaoka (2004).

Develops an APSP algorithm or structural reduction and is part of the long-running attempt to beat the cubic baseline.

## Tak05 — An O(n^3 log log n/log n) time algorithm for the all-pairs shortest path problem

Tadao Takaoka (2005).

Develops an APSP algorithm or structural reduction and is part of the long-running attempt to beat the cubic baseline.

## TT00 — Algorithms for the maximum subarray problem based on matrix multiplication

Hisao Tamaki; Takeshi Tokuyama (2000).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## Vas18 — On some fine-grained questions in algorithms and complexity

Virginia Vassilevska Williams (2018).

Survey of fine-grained algorithms/complexity and its main conjectures and reduction web.

## vdBNS19 — Dynamic matrix inverse: Improved algorithms and matching conditional lower bounds

Jan van den Brand; Danupon Nanongkai; Thatchaphol Saranurak (2019).

Introduces hinted online matrix–vector conjectures while developing dynamic matrix-inverse algorithms. The 2026 thin-product data structure refutes the conjectures in sufficiently thin hint regimes.

## vdBSZ24 — Algorithm and hardness for dynamic attention maintenance in large language models

Jan van den Brand; Zhao Song; Tianyi Zhou (2024).

Studies dynamic algorithms or conditional lower bounds, many of which use APSP/3SUM/OMv hypotheses and therefore need careful direction-of-reduction checks after the new upper bounds.

## VW10 — Subcubic equivalences between path, matrix and triangle problems

Virginia Vassilevska Williams; Ryan Williams (2010).

Establishes fine-grained subcubic equivalences among APSP-related path, min-plus matrix-product, and triangle problems; it is a central bridge in the APSP reduction web.

## VW13 — Finding, minimizing, and counting weighted subgraphs

Virginia Vassilevska Williams; Ryan Williams (2013).

Develops algorithms and reductions for finding, minimizing, and counting weighted subgraphs, including weighted-triangle machinery reused in later exact-weight reductions.

## VW18 — Subcubic equivalences between path, matrix, and triangle problems

Virginia Vassilevska Williams; R. Ryan Williams (2018).

Journal treatment of the subcubic-equivalence framework linking path, matrix-product, and triangle problems around APSP.

## VX20 — Monochromatic triangles, triangle listing and APSP

Virginia Vassilevska Williams; Yinzhan Xu (2020).

Reduces Exact Triangle to All-Edges Sparse Triangle, tying APSP hardness to the sparse-triangle problem that the 2026 paper finally exploits algorithmically.

## VXXZ24 — New bounds for matrix multiplication: From alpha to omega

Virginia Vassilevska Williams; Yinzhan Xu; Zixuan Xu; Renfei Zhou (2024).

Sharpens rectangular matrix-multiplication exponents, including the modern alpha/omega tradeoff used as a comparison point for thin products.

## War62 — A theorem on Boolean matrices

Stephen Warshall (1962).

Gives the Boolean transitive-closure recurrence whose weighted analogue underlies Floyd–Warshall; useful as the cleanest loop-and-branch assembly oracle.

## Wil05 — A new algorithm for optimal 2-constraint satisfaction and its implications

Ryan Williams (2005).

Studies exact exponential-time SAT algorithms or SAT-based hardness, providing the SETH side of fine-grained complexity that is not refuted by the 2026 result.

## Wil14 — The polynomial method in circuit complexity applied to algorithm design

R. Ryan Williams (2014).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## Wil16 — Strong ETH breaks with Merlin and Arthur: Short non-interactive proofs of batch evaluation

R. Ryan Williams (2016).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## Wil18 — Faster all-pairs shortest paths via circuit complexity

R. Ryan Williams (2018).

The previous best general real-weight APSP line shaves a subpolynomial factor from cubic time using circuit-complexity ideas; the 2026 result is the first polynomial exponent improvement in its integer model.

## Wil24 — The orthogonal vectors conjecture and non-uniform circuit lower bounds

R. Ryan Williams (2024).

Studies Orthogonal Vectors and its fine-grained role; OV remains an important unaffected hardness source in the 2026 paper’s discussion.

## Yat37 — The design and analysis of factorial experiments

Frank Yates (1937).

Classical factorial-design transform predating modern FFT terminology; historically relevant to divide-and-conquer linear transforms.

## Yu18 — An improved combinatorial algorithm for Boolean matrix multiplication

Huacheng Yu (2018).

Improves combinatorial Boolean matrix multiplication, part of the line that still lacks truly subcubic bounds.

## YZ05a — Answering distance queries in directed graphs using fast matrix multiplication

Raphael Yuster; Uri Zwick (2005).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## YZ05b — Fast sparse matrix multiplication

Raphael Yuster; Uri Zwick (2005).

Studies sparse/output-sensitive matrix multiplication, useful for comparing the 2026 wanted-entry thin-product regime with algorithms that exploit input or output sparsity.

## Zwi02 — All pairs shortest paths using bridging sets and rectangular matrix multiplication

Uri Zwick (2002).

Uses bridging sets and rectangular matrix multiplication for directed unweighted APSP; the 2026 paper gives the first improvement beyond this long-standing scheme not attributable merely to better matrix-multiplication exponents.

## Zwi06 — A slightly improved sub-cubic algorithm for the all pairs shortest paths problem with real edge lengths

Uri Zwick (2006).

Gives a modest subcubic improvement for real-weight APSP, part of the long sequence that achieved only subpolynomial savings before 2026.

