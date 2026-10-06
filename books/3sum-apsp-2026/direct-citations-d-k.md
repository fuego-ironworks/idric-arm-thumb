# Direct cited-paper notes — D–K

These are short reading summaries for the papers/books cited directly by Alman–Vassilevska Williams (2026). They are deliberately conservative: an entry can summarize the paper’s scope and its role in this literature without claiming that every theorem in the source was independently rederived here.

Primary source: https://arxiv.org/abs/2610.06783

## DEK+26 — Improving the matrix multiplication exponent with modern optimization and AlphaEvolve

Emilien Dupont; Marvin Eisenberger; Borislav Kozlovskii; Abbas Mehrabian; Francisco J. R. Ruiz; Abigail See; Renfei Zhou; Josh Alman; Virginia Vassilevska Williams; Matej Balog (2026).

Uses modern optimization/AlphaEvolve-style search to improve matrix-multiplication exponent bounds, illustrating computer-assisted discovery in the same algebraic-complexity neighborhood.

## DGS20 — All non-trivial variants of 3-LDT are equivalent

Bartłomiej Dudek; Paweł Gawrychowski; Tatiana Starikovskaya (2020).

Shows that all nontrivial 3-linear degeneracy tests are fine-grained equivalent, clarifying the algebraic decision problems surrounding 3SUM.

## DKPV20 — Equivalences between triangle and range query problems

Lech Duraj; Krzysztof Kleiner; Adam Polak; Virginia Vassilevska Williams (2020).

Studies triangle detection/listing/weight variants or reductions through them; triangle problems form the central junction between the new thin-product algorithm and 3SUM/APSP.

## DMRW09 — An optimal decomposition algorithm for tree edit distance

Erik D. Demaine; Shay Mozes; Benjamin Rossman; Oren Weimann (2009).

Studies tree edit distance algorithms or hardness and its relationship with APSP.

## Dob90 — A more efficient algorithm for the min-plus multiplication

Włodzimierz Dobosiewicz (1990).

Studies min-plus product or an equivalent problem, directly relevant because min-plus product is tightly connected with APSP.

## DSW18 — A subquadratic algorithm for 3XOR

Martin Dietzfelbinger; Philipp Schlag; Stefan Walzer (2018).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## Dür23 — Improved bounds for rectangular monotone Min-Plus product and applications

Anita Dürr (2023).

Studies min-plus product or an equivalent problem, directly relevant because min-plus product is tightly connected with APSP.

## Eri99 — Lower bounds for linear satisfiability problems

Jeff Erickson (1999).

Proves lower bounds for linear satisfiability/linear-degeneracy style decision problems, an ancestor of later k-SUM decision-tree work.

## ES17 — A nearly quadratic bound for the decision tree complexity of k-SUM

Esther Ezra; Micha Sharir (2017).

Obtains nearly quadratic decision-tree complexity for k-SUM, part of the comparison-model side of the 3SUM story.

## FBH+22 — Discovering faster matrix multiplication algorithms with reinforcement learning

Alhussein Fawzi; Matej Balog; Aja Huang; Thomas Hubert; Bernardino Romera-Paredes; Mohammadamin Barekatain; Alexander Novikov; Francisco J. R. Ruiz; Julian Schrittwieser; Grzegorz Swirszcz; David Silver; Demis Hassabis; Pushmeet Kohli (2022).

AlphaTensor work: reinforcement learning discovers new matrix-multiplication schemes, an earlier prominent example of machine-assisted algorithm discovery.

## Fis26 — Universe reduction for APSP: Equivalence of three fine-grained hypotheses

Nick Fischer (2026).

Develops an APSP fine-grained reduction/equivalence, so improvements to APSP can transfer to the linked problem class.

## FJX25 — New applications of 3SUM-counting in fine-grained complexity and pattern matching

Nick Fischer; Ce Jin; Yinzhan Xu (2025).

Studies 3SUM or a close variant/reduction, contributing to the algorithmic and fine-grained context around the primary result.

## FKP24 — Deterministic 3SUM-hardness

Nick Fischer; Piotr Kaliciak; Adam Polak (2024).

Builds a general toolkit for derandomizing additive-hashing-based 3SUM hardness reductions, including offline Set Disjointness/Intersection and Triangle Listing, and gives deterministic universe reduction for 3SUM.

## Flo62 — Algorithm 97: Shortest path

Robert W. Floyd (1962).

The compact Floyd shortest-path recurrence; together with Warshall it supplies the familiar cubic dynamic-programming baseline for APSP.

## FM71 — Boolean matrix multiplication and transitive closure

Michael J. Fischer; Albert R. Meyer (1971).

Relates Boolean matrix multiplication and transitive closure tightly, an early example of matrix/graph equivalence.

## Fre76 — New bounds on the complexity of the shortest path problem

Michael L. Fredman (1976).

Introduces Fredman’s trick for replacing arithmetic comparisons by comparisons of transformed differences; later fine-grained reductions use it to handle real-valued inputs.

## GGH+20 — Data structures meet cryptography: 3SUM with preprocessing

Alexander Golovnev; Siyao Guo; Thibaut Horel; Sunoo Park; Vinod Vaikuntanathan (2020).

Studies 3SUM or a close variant/reduction, contributing to the algorithmic and fine-grained context around the primary result.

## GKLP17 — Conditional lower bounds for space/time tradeoffs

Isaac Goldstein; Tsvi Kopelowitz; Moshe Lewenstein; Ely Porat (2017).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## GLP19 — On the hardness of set disjointness and set intersection with bounded universe

Isaac Goldstein; Moshe Lewenstein; Ely Porat (2019).

Studies set-disjointness/intersection data structures or lower bounds, a set-system form of the sparse-triangle / wanted-matrix-entry problem.

## GM93 — Witnesses for Boolean matrix multiplication and for transitive closure

Zvi Galil; Oded Margalit (1993).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## GO95 — On a class of O(n^2) problems in computational geometry

Anka Gajentaan; Mark H. Overmars (1995).

Catalogues geometric problems with quadratic 3SUM-based hardness, foundational to the notion of a 3SUM-hard problem.

## Goo58 — The interaction algorithm and practical Fourier analysis

Irving J. Good (1958).

Early mixed-radix/interaction ideas for Fourier computation; cited in the lineage of recursive transform factorizations.

## GP18 — Threesomes, degenerates, and love triangles

Allan Grønlund; Seth Pettie (2018).

Develops faster 3SUM and linear-degeneracy algorithms using decision-tree and word-RAM techniques, sharpening the polylogarithmic improvements that preceded the 2026 breakthrough.

## Gra26 — Optimal deterministic fully sparse matrix multiplication

Omar Graia (2026).

Studies sparse/output-sensitive matrix multiplication, useful for comparing the 2026 wanted-entry thin-product regime with algorithms that exploit input or output sparsity.

## GS17 — Improved bounds for 3SUM, k-SUM, and linear degeneracy

Omer Gold; Micha Sharir (2017).

Studies 3SUM or a close variant/reduction, contributing to the algorithmic and fine-grained context around the primary result.

## Han04 — Improved algorithm for all pairs shortest paths

Yijie Han (2004).

Studies shortest-path algorithms or complexity and belongs to the historical/technical APSP lineage.

## Han08 — An O(n^3(log log n/log n)^(5/4)) time algorithm for all pairs shortest path

Yijie Han (2008).

Studies shortest-path algorithms or complexity and belongs to the historical/technical APSP lineage.

## Her14 — 3-SAT faster and simpler—unique-SAT bounds for PPSZ hold in general

Timon Hertli (2014).

Simplifies and sharpens PPSZ-style 3-SAT bounds by extending unique-SAT analyses to general instances.

## HKNS15 — Unifying and strengthening hardness for dynamic problems via the online matrix-vector multiplication conjecture

Monika Henzinger; Sebastian Krinninger; Danupon Nanongkai; Thatchaphol Saranurak (2015).

Introduces the OMv conjecture as a unifying hardness source for dynamic problems; the ordinary conjecture survives the 2026 result while certain later hinted variants do not.

## HLS24 — Dynamic deterministic constant-approximate distance oracles with n^epsilon worst-case update time

Bernhard Haeupler; Yaowei Long; Thatchaphol Saranurak (2024).

Studies dynamic algorithms or conditional lower bounds, many of which use APSP/3SUM/OMv hypotheses and therefore need careful direction-of-reduction checks after the new upper bounds.

## HT16 — An O(n^3 log log n/log^2 n) time algorithm for all pairs shortest paths

Yijie Han; Tadao Takaoka (2016).

Studies shortest-path algorithms or complexity and belongs to the historical/technical APSP lineage.

## IP01 — On the complexity of k-SAT

Russell Impagliazzo; Ramamohan Paturi (2001).

Develops exponential-time lower-bound structure around k-SAT and helps motivate the Exponential Time Hypothesis family.

## IPZ01 — Which problems have strongly exponential complexity?

Russell Impagliazzo; Ramamohan Paturi; Francis Zane (2001).

Introduces/organizes strong exponential-time hypotheses and completeness phenomena for exponential algorithms.

## IR78 — Finding a minimum circuit in a graph

Alon Itai; Michael Rodeh (1978).

Early triangle/minimum-cycle work establishing the classical matrix-multiplication connection for triangle detection.

## Jin24 — 0-1 knapsack in nearly quadratic time

Ce Jin (2024).

Studies knapsack/subset-sum style algorithms or fine-grained complexity, useful as a neighboring exact-algorithms comparison rather than a core reduction in the new proof.

## Joh77 — Efficient algorithms for shortest paths in sparse networks

Donald B. Johnson (1977).

Johnson’s sparse-graph APSP algorithm combines reweighting with repeated single-source shortest paths, providing a contrasting sparse APSP baseline.

## JV16 — 3SUM, 3XOR, triangles

Zahra Jafargholi; Emanuele Viola (2016).

Studies 3SUM or a close variant/reduction, contributing to the algorithmic and fine-grained context around the primary result.

## JX23 — Removing additive structure in 3SUM-based reductions

Ce Jin; Yinzhan Xu (2023).

Uses a structure-versus-randomness approach to remove additive structure from 3SUM instances, enabling stronger modern 3SUM-based reductions.

## Kar72 — Reducibility among combinatorial problems

Richard M. Karp (1972).

Karp’s canonical reduction paper, establishing polynomial-time reducibility as a way to organize computational hardness.

## Ker70 — The Effect of Algebraic Structure on the Computational Complexity of Matrix Multiplication

Leslie Robert Kerr (1970).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## KKP93 — Finding the hidden path: Time bounds for all-pairs shortest paths

David R. Karger; Daphne Koller; Steven J. Phillips (1993).

Develops an APSP algorithm or structural reduction and is part of the long-running attempt to beat the cubic baseline.

## KLM19 — Near-optimal linear decision trees for k-SUM and related problems

Daniel M. Kane; Shachar Lovett; Shay Moran (2019).

Gives near-optimal linear decision trees for k-SUM and related problems, separating comparison/linear-query complexity from RAM running time.

## KM23 — Flip graphs for matrix multiplication

Manuel Kauers; Jakob Moosbauer (2023).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## KP19 — The strong 3SUM-INDEXING conjecture is false

Tsvi Kopelowitz; Ely Porat (2019).

Studies 3SUM or a close variant/reduction, contributing to the algorithmic and fine-grained context around the primary result.

## KPP16 — Higher lower bounds from the 3SUM conjecture

Tsvi Kopelowitz; Seth Pettie; Ely Porat (2016).

Strengthens 3SUM-based conditional lower bounds and gives the influential reduction from 3SUM to offline set problems / sparse triangle instances later reused and derandomized.

## KPS17 — On the fine-grained complexity of one-dimensional dynamic programming

Marvin Künnemann; Ramamohan Paturi; Stefan Schneider (2017).

Studies dynamic algorithms or conditional lower bounds, many of which use APSP/3SUM/OMv hypotheses and therefore need careful direction-of-reduction checks after the new upper bounds.

## KS20 — Matrix multiplication, a little faster

Elaye Karstadt; Oded Schwartz (2020).

Studies fast matrix multiplication or its implementation/structure, part of the algebraic toolkit surrounding the thin-product breakthrough.

## KV20 — Towards optimal set-disjointness and set-intersection data structures

Tsvi Kopelowitz; Virginia Vassilevska Williams (2020).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

