# Backend rejection exit status

Purpose: complete August ARM corpus PR #12 without relaxing the retained
source-ABI and reachable-program rejection gates.

Type-system sketch: backend acceptance still admits only the existing validated
RendererPrimitives representations and ANF shapes. Rejection constructs no
assembly artifact. The process must also return failure to its caller.

Observed failure at abc138d9af539787d8f511c36bf422c5064e05fd: InvalidInt
was correctly diagnosed as unsupported, but the frontend post-options handler
caught UserError and returned status zero. The negative gate correctly failed.

Repair: backend-specific refusal now prints the same diagnostic and exits
failure through System.die lifted into Core. Missing exports, invalid ABI,
invalid reachable code, and attempted implicit execution all fail the command.
The three invalid-source gates additionally require absent assembly artifacts.
The positive backend, ABI, QEMU, deterministic output, and corpus gates remain.

No fallback backend or widened ABI is introduced. Fresh checks qualify this
repair; historical receipts are not reused. No physical-device claim is made.
