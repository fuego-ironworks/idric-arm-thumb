# ARM-1 word kernel oracle

Recovered from the preceding implementation record. Fresh source and execution
evidence are required; unavailable old local binaries are not relabelled current.

The existing Bits32 domain is the residue ring modulo 2³². Add/subtract and
low products wrap; the high product is floor(left × right / 2³²). Carry and
borrow return one word, equal to 0 or 1. No multi-result ABI or new scalar type
is introduced. Constant shifts admit 0..31 and other counts refuse.

The independent Integer oracle is pinned-compiler compatibility `.idr` source
at 081b9cde0591154839fb5d80d76e5570e0436300, executed through Chez. It generates
data only. Nine operations on all ordered pairs of 0,1,2,2³¹,2³²−1, plus four
boundaries, give 229 records. ARM arithmetic must come from WordKernels.idric
through the real source/ANF driver. C intermediates and RefC are excluded.

The caller compares and writes actual one-word results through the freestanding
Linux syscall harness. QEMU, Android object generation, Android execution and
physical MIRO A1 execution are different evidence levels.
