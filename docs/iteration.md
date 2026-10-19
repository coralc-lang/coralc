# Iteration and the `@iter` trait

Coral's `for-in` statement walks arrays, slices, and any collection that opts
into the built-in `@iter` marker trait. Iteration is index based: the compiler
asks the collection for a count once, then asks for each element by index.

## Forms

```coral
for (var elem : value)              { ... }  // whole container
for (T elem : value)                { ... }  // explicit element type
for (var a, b : value)              { ... }  // tuple destructuring

for (var elem : value(start, end))  { ... }  // half-open runtime bounds
for (var elem : value.range(start, end)) { ... } // same, method spelling
```

- `start` and `end` must be integer expressions.
- `end` is exclusive.
- Bounds are clamped to the current element count.
- If `end < start`, the loop body runs zero times.
- The bounded form has two spellings; both call `range(start, end)`.
- A single-bound form such as `value(end)` is intentionally **not** supported.

The loop variable is a copy of the element. Assigning to it does not modify
the collection. Use an index loop with `atPtr()` when mutation is required.

Multiple `var` bindings destructure a tuple returned by `at()`:

```coral
pub extend Pairs : @iter
{
    usize count() { return self.n; }

    struct(i32, i32) at(usize i)
    {
        return ((i32)i, (i32)(i * 10));
    }
}

for (var index, value : pairs)
    println("{} -> {}", index, value);
```

The tuple must have exactly one element per binding. The typed single-binding
form still accepts a tuple type: `for (struct(i32, i32) pair : pairs)`.

## Arrays and slices

Arrays and slices are iterable without any trait implementation:

```coral
i32 values[4] = { 1, 2, 3, 4 };
for (var value : values)
    println("{..}", value);

for (var value : values(1, 3)) // elements at indexes 1 and 2
    println("{..}", value);
```

The compiler uses the array/slice length directly and clamps bounded ranges.

## Implementing `@iter`

`@iter` is a structural marker. It has no runtime object, vtable, or methods of
its own. A type opts in by declaring an `@iter` extend block containing the
indexed protocol. The methods belong in the extend block, not in the struct
body:

```coral
import(lib) std::collections::range { IterRange };

struct CountTo
{
    usize n;
}

pub extend CountTo : @iter
{
    usize count()
    {
        return self.n;
    }

    i32 at(usize i)
    {
        return (i32)i;
    }

    IterRange range(usize start, usize end)
    {
        if (start > self.n) start = self.n;
        if (end > self.n) end = self.n;
        if (end < start) end = start;
        return IterRange { .start = start, .end = end };
    }
}

void main()
{
    CountTo c;
    c.n = 5;

    for (var value : c(1, 4))
        println("{..}", value); // 1, 2, 3
}
```

### Protocol

| Method | Required | Contract |
| --- | --- | --- |
| `usize count()` | Always | Number of elements. Plain for-in calls it once. |
| `T at(usize i)` | Always | Element at `0 <= i < count()`. Called once per element, in increasing index order. |
| `IterRange range(usize start, usize end)` | Bounded form only | Clamps and returns the half-open interval `[start, end)`. Must return `IterRange`. |

`range()` is O(1) for the built-in collections. The bounded loop still costs
`O(end - start)` calls to `at()`.

`IterRange` is declared in `std::collections::range`:

```coral
pub struct IterRange
{
    usize start;
    usize end;
}
```

It is deliberately non-generic so importing a collection does not implicitly
instantiate a container such as `Vec<T>` just because `range()` is declared.

`IterRange` is an ordinary struct, not a builtin type like `str`, and it is
not force-imported by the prelude. A bounded `for-in` does not need to name it:
the compiler desugars the bounds to `range()` plus `at()`. Import it only when
a declaration spells the return type:

```coral
import(lib) std::collections::range { IterRange };
```

## Built-in implementations

| Type | Iteration order | `at()` cost | Notes |
| --- | --- | --- | --- |
| `Vec<T>` | insertion order | O(1) | |
| `Arr<T, N>` | index order | O(1) | fixed-size array wrapper |
| `Deque<T>` | front to back | O(1) | |
| `RingBuf<T>` | front to back | O(1) | |
| `Queue<T>` | front to back | O(1) | does not consume elements |
| `LinkedList<T>` | head to tail | O(i) | plain for-in is O(n²); prefer `each()` for large lists |
| `PriorityQueue<T>` | heap-array order | O(1) | not sorted order; use `pop()` to consume by priority |
| `Bitset` | bit index order | O(1) | yields `bool`; `count()` counts set bits |

`Map`, `HashMap`, `Set`, `Tree`, `Trie`, `Cache`, and `UnorderedMap` do not
implement `@iter` because they have no single canonical indexed element order.

## Diagnostics

A type marked `@iter` must provide `count()` and `at()`. If either is missing,
the compiler reports a method-not-found error naming the type, the missing
method, and the `@iter` protocol. For example:

```text
[T0006]: method 'count' not found on type 'BadIter'
  help: the type implements @iter, whose indexed protocol requires
        `usize count()` and `T at(usize)`; add count() to the type's
        `extend Type : @iter` block
```

A bounded loop additionally requires `range()`. A missing or incorrectly typed
`range()` produces the same kind of method-not-found error, with the required
signature and `IterRange` return type.

Using for-in on a type that is neither an array/slice nor marked `@iter`
reports:

```text
for-in iterator must be an array, slice, or @iter collection
```

## Vector helpers

`std::collections::iter` provides convenience algorithms for `Vec`:
`map`, `filter`, `reduce`, `forEach`, `find`, `findIndex`, `hasAny`, `all`,
`take`, `skip`, `slice`, `zip`, `countIf`, `minBy`, `maxBy`, `unique`,
`flatten`, `enumerate`, `sum`, and `average`.

These functions accept `Vec<T>` or `const Vec<T>*`. They are not generic
`@iter` adapters; use for-in when iterating another collection.

## Current limitations

- Multi-binding only applies to the `var` form and requires `at()` to return a
  tuple with one element per binding.
- `@iter` is structural and built in; user-defined traits cannot be used as
  for-in protocols.
- Iteration yields copies. Mutation requires an explicit index loop.
- The bounded form requires the `range()` method on `@iter` types. Arrays and
  slices get bounded iteration without it.
