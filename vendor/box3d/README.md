# Box3D

Odin bindings for [Box3D](https://github.com/erincatto/box3d), a 3D physics engine for games by Erin Catto.

## Compiling the native libraries

The bindings link against a static Box3D library that must be compiled for your
platform. Run the build script (requires `cmake`, a C compiler, and `curl`):

```sh
./build_box3d.sh
```

This downloads the Box3D sources, builds them, and places the resulting static
libraries in `lib/`. It also attempts a WASM build; if your default C compiler
and linker don't support WASM, set the `CC` and `LD` environment variables to a
compiler/linker that does (e.g. LLVM's `clang` and `wasm-ld`).

### SIMD

On native targets Box3D uses SSE2 (x86) or NEON (ARM) by default. On WASM,
`simd128` is used when the target feature is enabled; you can override detection
with `-define:VENDOR_BOX3D_ENABLE_SIMD128=<true|false>`.

## Usage

```odin
import b3 "vendor:box3d"

main :: proc() {
	world_def := b3.DefaultWorldDef()
	world_def.gravity = {0, -10, 0}
	world := b3.CreateWorld(world_def)
	defer b3.DestroyWorld(world)

	// ... create bodies, step the world with b3.World_Step, etc.
}
```

## License

Box3D is developed by Erin Catto and uses the [MIT license](LICENSE).
