package vendor_box3d

import "core:c"

foreign import lib {
	LIB_PATH,
}

// This is used to indicate null for interfaces that work with indices instead of pointers
NULL_INDEX :: -1

// Prototype for user allocation function.
//	@param size the allocation size in bytes
//	@param alignment the required alignment, guaranteed to be a power of 2
AllocFcn :: #type proc "c" (size: i32, alignment: i32) -> rawptr

// Prototype for user free function.
//	@param mem the memory previously allocated through `b3AllocFcn`
FreeFcn :: #type proc "c" (mem: rawptr)

// Prototype for the user assert callback. Return 0 to skip the debugger break.
AssertFcn :: #type proc "c" (condition, fileName: cstring, lineNumber: c.int) -> c.int

// Prototype for user log callback. Used to log warnings.
LogFcn :: #type proc "c" (message: cstring)

// Version numbering scheme.
//
// See https://semver.org/
Version :: struct {
	major:    c.int, // Significant changes
	minor:    c.int, // Incremental changes
	revision: c.int, // Bug fixes
}

// Simple djb2 hash function for determinism testing
HASH_INIT :: 5381

@(link_prefix="b3", default_calling_convention="c")
foreign lib {
	// This allows the user to override the allocation functions. These should be
	//	set during application startup.
	SetAllocator :: proc(allocFcn: AllocFcn, freeFcn: FreeFcn) ---

	// Total bytes allocated by Box3D
	@(require_results)
	GetByteCount :: proc() -> i32 ---

	// Override the default assert callback.
	//	@param assertFcn a non-null assert callback
	SetAssertFcn :: proc(assertFcn: AssertFcn) ---

	// Override the default logging callback.
	SetLogFcn :: proc(logFcn: LogFcn) ---

	// Get the current version of Box3D
	@(require_results)
	GetVersion :: proc() -> Version ---

	// @return true if the library was built with BOX3D_DOUBLE_PRECISION (large world mode)
	@(require_results)
	IsDoublePrecision :: proc() -> bool ---

	// Get the absolute number of system ticks. The value is platform specific.
	@(require_results)
	GetTicks :: proc() -> u64 ---

	// Get the milliseconds passed from an initial tick value.
	@(require_results)
	GetMilliseconds :: proc(ticks: u64) -> f32 ---

	// Get the milliseconds passed from an initial tick value.
	@(require_results)
	GetMillisecondsAndReset :: proc(ticks: ^u64) -> f32 ---

	// Yield to be used in a busy loop.
	Yield :: proc() ---

	// Sleep the current thread for a number of milliseconds.
	Sleep :: proc(milliseconds: c.int) ---

	// Simple djb2 hash function for determinism testing
	@(require_results)
	Hash :: proc(hash: u32, data: [^]byte, count: c.int) -> u32 ---

	// Dump file support functions
	WriteBinaryFile :: proc(data: rawptr, size: c.int, fileName: cstring) ---
	@(require_results)
	ReadBinaryFile  :: proc(prefix: cstring, fileName: cstring, memSize: ^c.int) -> rawptr ---
}
