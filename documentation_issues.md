## Doc discrepancies you may want to report upstream
- `{:.6}` ,`{:.3}` ,`{:d}` are documented but`{:.N}` is rejected as`T0014 malformed placeholder` . Working form is`{}` with the`_fixed(v, n)` manipulator.
- `{:f}` parses but dies with an internal codegen failure (`G0002` , no monomorphized instance in`std/.../io/ios.crl` ), which is a compiler bug, not a syntax issue.
- Array syntax (`T name[N]` ) is stale
- it is `T[N] name`now.