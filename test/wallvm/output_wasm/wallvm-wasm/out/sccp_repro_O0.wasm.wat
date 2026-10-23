(module
(type $t0 (func (param i64) (result i64)))
(type $t1 (func (result i32)))
(memory $0 32 65536)
(export "memory" (memory $0))
(global $__stack_pointer (mut i32) (i32.const 1048576))
(global $__heap_base i32 (i32.const 0))
(table $t 2 funcref)
(elem (i32.const 0) $f0 $f1)
(func $f0 (param $v0 i64) (result i64)
(local $pc i32)
(local $v1 i32)
(local $v2 i64)
(local $v3 i64)
(local $v4 i64)
(local $v5 i64)
(local $v6 i64)
(local $v8 i64)
i32.const 0
local.set $pc
loop $L
block $done
block $b2
block $b1
block $b0
local.get $pc
br_table $b0 $b1 $b2 $done
end ;; $b0
local.get $v0
i64.const 2
i64.lt_s
local.set $v1
i32.const 1
i32.const 2
local.get $v1
select
local.set $pc
br $L
end ;; $b1
local.get $v0
return
end ;; $b2
local.get $v0
i64.const 1
i64.sub
local.set $v3
local.get $v0
i64.const 2
i64.sub
local.set $v4
local.get $v3
call $f0
local.set $v5
local.get $v4
call $f0
local.set $v6
local.get $v5
local.get $v6
i64.add
return
end ;; $done
end ;; $L
unreachable
)
(func $f1 (result i32)
(local $pc i32)
(local $v2 i32)
i32.const 0
local.set $pc
loop $L
block $done
block $b0
local.get $pc
br_table $b0 $done
end ;; $b0
i64.const 10
call $f0
i32.wrap_i64
return
end ;; $done
end ;; $L
unreachable
)
(export "fib" (func $f0))
(export "main" (func $f1))
(export "__heap_base" (global $__heap_base))
)
