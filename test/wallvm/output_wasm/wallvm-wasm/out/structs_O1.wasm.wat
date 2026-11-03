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
(local $v2 i32)
(local $v4 i64)
(local $v5 i64)
(local $v8 i32)
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
local.get $v0
i32.const 0
i32.add
local.set $v1
local.get $v0
i32.const 8
i32.add
local.set $v2
local.get $v0
i32.const 7
i32.store align=4
local.get $v0
i64.const 50
i64.store offset=8 align=8
local.get $v0
i32.load align=4
i64.extend_i32_u
local.set $v4
local.get $v0
i64.load offset=8 align=8
local.set $v5
local.get $v4
local.get $v5
i64.add
i32.wrap_i64
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
