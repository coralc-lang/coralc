# Coral Compiler Documentation

- [Compiler pipeline and monomorphization](compiler-pipeline.md)
- [Compiler defects found while porting the WebGPU API](compiler_defects_webgpu.md) — max-file limit truncating large ports, no-op `coralc build`, nested import parse gap.

The pipeline note records the boundary between Sema and `coral-mono`, including generic declarations, `comptime` type parameters, instantiation, and the self-host semantic module layout.
