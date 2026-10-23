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
(local $v2 i64)
(local $v3 i64)
(local $v4 i32)
(local $v5 i64)
(local $v6 i64)
(local $v8 i32)
global.get $__stack_pointer
local.set $sp0
i32.const 0
local.set $pc
loop $L
block $done
block $b3
block $b2
block $b1
block $b0
local.get $pc
br_table $b0 $b1 $b2 $b3 $done
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
i64.const 0
i64.store align=8
local.get $v1
i64.const 0
i64.store align=8
i32.const 1
local.set $pc
br $L
end ;; $b1
local.get $v0
i64.load align=8
local.set $v2
local.get $v1
i64.load align=8
local.set $v3
local.get $v2
i64.const 10
i64.lt_s
local.set $v4
i32.const 2
i32.const 3
local.get $v4
select
local.set $pc
br $L
end ;; $b2
local.get $v2
local.get $v3
i64.add
local.set $v5
i64.const 1
local.get $v2
i64.add
local.set $v6
local.get $v0
local.get $v6
i64.store align=8
local.get $v1
local.get $v5
i64.store align=8
i32.const 1
local.set $pc
br $L
end ;; $b3
local.get $v3
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
