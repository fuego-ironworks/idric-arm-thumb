# Signed FP8 and the unsigned research codec at the ARM source boundary

Work envelope: https://github.com/isomorphisms/flexible-pipes/issues/83

## Types and purpose

E4M3 and E5M2 are different signed eight-bit numerical codebooks. Their
conversion and arithmetic functions keep their respective types. OotomoE5M3
is a separate positive-only eight-bit storage codec. It has conversion
functions but no arithmetic instance, implicit conversion to FP8, or bare
E5M3 compatibility alias at the ARM ABI.

Required signatures include E4M3 → E4M3, E5M2 → E5M2,
OotomoE5M3 → RendererPrimitives.Float32, and
RendererPrimitives.Float32 → OotomoE5M3. A function returning E4M3 cannot
return an E5M2 or OotomoE5M3 value. A historical Prelude E5M3 parameter must
produce the named ambiguity diagnostic before any ARM assembly is emitted.

The three `.idric` fixtures deliberately violate these boundaries. The
positive control is the existing checked `examples/Scalars.idric`, including
the signed E4M3/E5M2 source arithmetic exports and explicit storage exports.

## Host acceptance interface

`CheckBoundaries.idr` is an explicit Idris compatibility helper for the pinned
historical compiler API. It executes the actual source compiler, requires a
successful positive control, and checks each rejected fixture's nonzero status,
specific type diagnostic, and absent assembly artifact. It is not a substitute
ARM implementation or a Python/Bash test script.

The historical parser at Idriç ad674be3e2f0eade5cd007c419a0f0c048548d6a
accepts the older source vocabulary and predates canonical Text/Number/≟.
The `.idr` compatibility helper deliberately retains String and == at this
boundary; the test programs remain `.idric`. No canonical compiler integration
is inferred. System.run is the pinned library's process/capture interface:
argv is escaped by System.Escape, and its sole additional shell operation is
fixed stderr-to-stdout capture. No authored shell procedure is supplied.

## Verification and remaining language work

The required `verify` workflow checks out the actual PR head, compiles this
helper with the pinned compiler, then runs the positive and negative source
controls. Its logs are the execution evidence, not this attempt record.
The inherited source-to-Thumb and QEMU scalar tests still run afterward.

The next compiler boundary is canonical Idriç's owned Float32 source/IR
contract. The current canonical FP8 reference types and the historical
Float32/Float16 prelude are distinct lines. A canonical-source-to-ARM receipt
requires reconciling that compiler seam rather than importing the historical
branch wholesale or substituting Double. Host helper execution, assembly,
QEMU, and physical device behavior remain separate evidence levels.
