(module
(type $t0 (func (result i32)))
(memory $0 32 65536)
(export "memory" (memory $0))
(global $__stack_pointer (mut i32) (i32.const 1048576))
(global $__heap_base i32 (i32.const 0))
(table $t 1 funcref)
(elem (i32.const 0) $f0)
(func $f0 (result i32)
(local $pc i32)
(local $condT i32)
(local $swI32 i32)
(local $swI64 i64)
(local $tI32_0 i32)
(local $tI64_0 i64)
(local $tF32_0 f32)
(local $tF64_0 f64)
(local $tV128_0 v128)
(local $tI32_1 i32)
(local $tI64_1 i64)
(local $tF32_1 f32)
(local $tF64_1 f64)
(local $tV128_1 v128)
(local $tI32_2 i32)
(local $tI64_2 i64)
(local $tF32_2 f32)
(local $tF64_2 f64)
(local $tV128_2 v128)
(local $tI32_3 i32)
(local $tI64_3 i64)
(local $tF32_3 f32)
(local $tF64_3 f64)
(local $tV128_3 v128)
(local $tI32_4 i32)
(local $tI64_4 i64)
(local $tF32_4 f32)
(local $tF64_4 f64)
(local $tV128_4 v128)
(local $tI32_5 i32)
(local $tI64_5 i64)
(local $tF32_5 f32)
(local $tF64_5 f64)
(local $tV128_5 v128)
(local $tI32_6 i32)
(local $tI64_6 i64)
(local $tF32_6 f32)
(local $tF64_6 f64)
(local $tV128_6 v128)
(local $tI32_7 i32)
(local $tI64_7 i64)
(local $tF32_7 f32)
(local $tF64_7 f64)
(local $tV128_7 v128)
(local $v3 i32)
i32.const 0
local.set $pc
loop $L
block $done
block $b0
local.get $pc
br_table $b0 $done
end ;; $b0
f64.const 0x1.8000000000000p0
f64.const 0x1.4000000000000p1
f64.ge
i32.const 1
i32.and
i64.extend_i32_u
i32.wrap_i64
return
end ;; $done
end ;; $L
unreachable
)
(export "main" (func $f0))
(export "__heap_base" (global $__heap_base))
)
