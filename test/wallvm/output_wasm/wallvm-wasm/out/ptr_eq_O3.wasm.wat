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
(local $sp0 i32)
(local $v0 i32)
(local $v1 i32)
(local $v4 i32)
global.get $__stack_pointer
local.set $sp0
i32.const 0
local.set $pc
loop $L
block $done
block $b0
local.get $pc
br_table $b0 $done
end ;; $b0
global.get $__stack_pointer
i32.const 16
i32.sub
global.set $__stack_pointer
global.get $__stack_pointer
local.set $v0
global.get $__stack_pointer
i32.const 16
i32.sub
global.set $__stack_pointer
global.get $__stack_pointer
local.set $v1
local.get $v0
i32.const 1
i32.store align=4
local.get $v1
i32.const 2
i32.store align=4
local.get $v0
local.get $v1
i32.eq
i32.const 1
i32.and
local.get $sp0
global.set $__stack_pointer
return
end ;; $done
end ;; $L
local.get $sp0
global.set $__stack_pointer
unreachable
)
(export "main" (func $f0))
(export "__heap_base" (global $__heap_base))
)
