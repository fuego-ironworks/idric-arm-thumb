# Reference specifications

This directory keeps the six scalar and circular machine-format references
currently used by the ARM Thumb work:

1. [Float16 / IEEE binary16](float16.md)
2. [FP8 / OCP OFP8](fp8.md)
3. [E3M2 / OCP FP6 element format](e3m2.md)
4. [E5M3 / Ootomo-Naruse unsigned 8-bit storage format](e5m3.md)
5. [Bits8 / Idris 2 unsigned 8-bit primitive](bits8.md)
6. [Finite circle machine representations](binary-circle.md)

Each local file is a complete implementation-oriented restatement of the format
contract needed by this repository and links to the exact upstream reference.
The upstream document or source remains authoritative where it specifies
behavior outside the local backend's scope.

The formats are deliberately kept distinct. In particular:

- OCP FP8 means the signed 8-bit E4M3 and E5M2 interchange formats.
- OCP E3M2 is a signed 6-bit FP6 element format.
- Ootomo-Naruse E5M3 is an **unsigned** 8-bit storage format: five exponent
  bits plus three mantissa bits and no sign bit.
- Bits8 is an unsigned modular integer, not a floating-point format.
- Finite circle values use bounded modular storage to represent positions around
  one complete cycle; the modulus need not be a power of two, and local signed
  displacements are linear/tangent data rather than circle points.


## SMS and Android messaging

[`sms/`](sms/README.md) records the Android provider contract, the relevant
IETF RFCs, and the 3GPP SMS references.  The included fetch script retrieves
exact RFC Editor text for RFC 5724, RFC 3966, RFC 3986, and RFC 5234 so local
development can keep the standards beside the implementation without relying
on an informal transcription.
