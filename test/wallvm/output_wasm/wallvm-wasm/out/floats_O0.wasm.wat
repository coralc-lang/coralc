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
(local $v0 i32)
i32.const 0
local.set $pc
loop $L
block $done
block $b0
local.get $pc
br_table $b0 $done
end ;; $b0
i32.const 9
return
end ;; $done
end ;; $L
unreachable
)
(export "main" (func $f0))
(export "__heap_base" (global $__heap_base))
)
