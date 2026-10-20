module RendererPrimitives

%default total

||| Explicit unboxed renderer scalar used at the ARM ABI seam.
export
data Float32 : Type where [external]

||| Caller-owned contiguous Float32 memory. The backend assumes a non-null,
||| suitably aligned pointer and an in-bounds Int32 index at the FFI boundary.
export
data Float32Buffer : Type where [external]

export %extern float32_buffer_load : Float32Buffer -> Int32 -> Float32

export %extern float32_add : Float32 -> Float32 -> Float32
export %extern float32_subtract : Float32 -> Float32 -> Float32
export %extern float32_multiply : Float32 -> Float32 -> Float32
export %extern float32_divide : Float32 -> Float32 -> Float32

export %extern float32_negate : Float32 -> Float32
export %extern float32_absolute : Float32 -> Float32
export %extern float32_square_root : Float32 -> Float32

export %extern word32_multiply_high : Bits32 -> Bits32 -> Bits32
export %extern word32_add_carry : Bits32 -> Bits32 -> Bits32
export %extern word32_subtract_borrow : Bits32 -> Bits32 -> Bits32
