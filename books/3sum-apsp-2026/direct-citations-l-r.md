# Direct cited-paper notes — L–R

These are short reading summaries for the papers/books cited directly by Alman–Vassilevska Williams (2026). They are deliberately conservative: an entry can summarize the paper’s scope and its role in this literature without claiming that every theorem in the source was independently rederived here.

Primary source: https://arxiv.org/abs/2610.06783

## LG12 — Faster algorithms for rectangular matrix multiplication

François Le Gall (2012).

Improves or analyzes rectangular matrix multiplication, providing algebraic techniques and exponent baselines for thin products.

## LLV19 — Public-key cryptography in the fine-grained setting

Rio LaVigne; Andrea Lincoln; Virginia Vassilevska Williams (2019).

Develops the fine-grained complexity framework, protocols, reductions, or consequences used to interpret algorithmic exponent improvements.

## Lov75 — On the ratio of optimal integral and fractional covers

László Lovász (1975).

Studies the gap between integral and fractional covers, a classical set-cover approximation result used downstream in some reduction/approximation arguments.

## LPV20 — Monochromatic triangles, intermediate matrix products, and convolutions

Andrea Lincoln; Virginia Vassilevska Williams; R. Ryan Williams (2020).

Relates monochromatic triangles, intermediate matrix products, and convolutions; it develops intermediate problems that connect matrix multiplication to fine-grained reductions.

## LU18 — Improved rectangular matrix multiplication using powers of the Coppersmith–Winograd tensor

François Le Gall; Florent Urrutia (2018).

Improves or analyzes rectangular matrix multiplication, providing algebraic techniques and exponent baselines for thin products.

## LVW18 — Tight hardness for shortest cycles and paths in sparse graphs

Andrea Lincoln; Virginia Vassilevska Williams; R. Ryan Williams (2018).

Studies shortest-cycle/girth algorithms or hardness; these problems sit in the broader APSP/weighted-triangle reduction network.

## LVWW16 — Deterministic time-space trade-offs for k-SUM

Andrea Lincoln; Virginia Vassilevska Williams; Joshua R. Wang; R. Ryan Williams (2016).

Studies k-SUM/linear-degeneracy complexity, especially decision-tree or fine-grained bounds around the 3SUM family.

## Mao21 — Breaking the cubic barrier for (unweighted) tree edit distance

Xiao Mao (2021).

Breaks the cubic barrier for unweighted tree edit distance, showing that the weighted and unweighted variants live in different algorithmic regimes.

## Mar71 — FFT pruning

John D. Markel (1971).

Studies FFT pruning: avoiding transform work for unused inputs/outputs, an especially suggestive historical analogue of wanted-output pruning.

## Mat91 — Computing dominances in E^n

Jiří Matoušek (1991).

Introduces a matrix-multiplication technique for dominance counting. The 2026 paper adapts this block/dominance idea when evaluating many real-number comparison counts.

## Mey84 — A polynomial linear search algorithm for the n-dimensional knapsack problem

Friedhelm Meyer auf der Heide (1984).

Studies knapsack/subset-sum style algorithms or fine-grained complexity, useful as a neighboring exact-algorithms comparison rather than a core reduction in the new proof.

## MS25 — The number of the beast: Reducing additions in fast matrix multiplication algorithms for dimensions up to 666

Erik Mårtensson; Paul Stankovski Wagner (2025).

Optimizes the number of additions in small fast matrix-multiplication algorithms, directly relevant to instruction-count tradeoffs once bilinear schemes are lowered to native code.

## NP85 — On the complexity of the subgraph problem

Jaroslav Nešetřil; Svatopluk Poljak (1985).

Studies clique/subgraph detection or exact weights; weighted clique reductions are among the consequences propagated through Exact Triangle.

## NPS+25 — Faster weighted and unweighted tree edit distance and APSP equivalence

Jakob Nogler; Adam Polak; Barna Saha; Virginia Vassilevska Williams; Yinzhan Xu; Christopher Ye (2025).

Gives faster weighted/unweighted tree-edit-distance algorithms and a tight connection with APSP; therefore the 2026 APSP improvement transfers to weighted tree edit distance.

## NVE+25 — AlphaEvolve: A coding agent for scientific and algorithmic discovery

Alexander Novikov; Ngân Vũ; Marvin Eisenberger; Emilien Dupont; Po-Sen Huang; Adam Zsolt Wagner; Sergey Shirobokov; Borislav Kozlovskii; Francisco J. R. Ruiz; Abbas Mehrabian; M. Pawan Kumar; Abigail See; Swarat Chaudhuri; George Holland; Alex Davies; Sebastian Nowozin; Pushmeet Kohli; Matej Balog (2025).

Short scope note: this work supplies background, a reduction, or an algorithmic comparison used in the 2026 paper’s broader fine-grained/algebraic context; consult the paper itself before relying on a precise theorem or bound.

## Păt10 — Towards polynomial lower bounds for dynamic problems

Mihai Pătraşcu (2010).

The seminal dynamic-lower-bound paper that introduced the additive-hashing 3SUM reduction framework used by many later sparse-triangle and set-disjointness reductions.

## PPSZ05 — An improved exponential-time algorithm for k-SAT

Ramamohan Paturi; Pavel Pudlák; Michael E. Saks; Francis Zane (2005).

Improves exponential-time k-SAT algorithms through the PPSZ method.

## PS14 — The input/output complexity of sparse matrix multiplication

Rasmus Pagh; Morten Stöckel (2014).

Studies sparse/output-sensitive matrix multiplication, useful for comparing the 2026 wanted-entry thin-product regime with algorithms that exploit input or output sparsity.

## RV11 — Minimum weight cycles and triangles: Equivalences and algorithms

Liam Roditty; Virginia Vassilevska Williams (2011).

Studies triangle detection/listing/weight variants or reductions through them; triangle problems form the central junction between the new thin-product algorithm and 3SUM/APSP.

## RV12 — Subquadratic time approximation algorithms for the girth

Liam Roditty; Virginia Vassilevska Williams (2012).

Studies shortest-cycle/girth algorithms or hardness; these problems sit in the broader APSP/weighted-triangle reduction network.

## RZ04 — On dynamic shortest paths problems

Liam Roditty; Uri Zwick (2004).

Studies dynamic algorithms or conditional lower bounds, many of which use APSP/3SUM/OMv hypotheses and therefore need careful direction-of-reduction checks after the new upper bounds.

