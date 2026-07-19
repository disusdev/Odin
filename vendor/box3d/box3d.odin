// Bindings for [[ Box3D ; https://box2d.org ]].
package vendor_box3d

import "base:intrinsics"
import "core:c"

_ :: intrinsics
_ :: c

when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
	@(private) VECTOR_EXT :: "_simd" when #config(VENDOR_BOX3D_ENABLE_SIMD128, intrinsics.has_target_feature("simd128")) else ""
}

when ODIN_OS == .Windows {
	@(private) LIB_PATH :: "lib/box3d_windows_amd64.lib"
} else when ODIN_OS == .Darwin && ODIN_ARCH == .arm64 {
	@(private) LIB_PATH :: "lib/box3d_darwin_arm64.a"
} else when ODIN_OS == .Darwin {
	@(private) LIB_PATH :: "lib/box3d_darwin_amd64.a"
} else when ODIN_ARCH == .amd64 {
	@(private) LIB_PATH :: "lib/box3d_other_amd64.a"
} else when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
	@(private) LIB_PATH :: "lib/box3d_wasm" + VECTOR_EXT + ".o"
} else {
	@(private) LIB_PATH :: "lib/box3d_other.a"
}

when !#exists(LIB_PATH) {
	#panic("Could not find the compiled box3d libraries at \"" + LIB_PATH + "\", they can be compiled by running the `build_box3d.sh` script at `" + ODIN_ROOT + "vendor/box3d/build_box3d.sh\"`")
}

foreign import lib {
	LIB_PATH,
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	// Use this to initialize your world definition
	// @ingroup world
	DefaultWorldDef          :: proc() -> WorldDef ---

	// Use this to initialize your body definition
	// @ingroup body
	DefaultBodyDef           :: proc() -> BodyDef ---

	// Use this to initialize your filter
	// @ingroup shape
	DefaultFilter            :: proc() -> Filter ---

	// Use this to initialize your query filter
	// @ingroup shape
	DefaultQueryFilter       :: proc() -> QueryFilter ---

	// Use this to initialize your surface material
	// @ingroup shape
	DefaultSurfaceMaterial   :: proc() -> SurfaceMaterial ---

	// Use this to initialize your shape definition
	// @ingroup shape
	DefaultShapeDef          :: proc() -> ShapeDef ---

	// Use this to initialize your joint definition
	// @ingroup distance_joint
	DefaultDistanceJointDef  :: proc() -> DistanceJointDef ---

	// Use this to initialize your joint definition
	// @ingroup motor_joint
	DefaultMotorJointDef     :: proc() -> MotorJointDef ---

	// Use this to initialize your joint definition
	// @ingroup filter_joint
	DefaultFilterJointDef    :: proc() -> FilterJointDef ---

	// Use this to initialize your joint definition
	// @ingroup parallel_joint
	DefaultParallelJointDef  :: proc() -> ParallelJointDef ---

	// Use this to initialize your joint definition
	// @ingroup prismatic_joint
	DefaultPrismaticJointDef :: proc() -> PrismaticJointDef ---

	// Use this to initialize your joint definition
	// @ingroup revolute_joint
	DefaultRevoluteJointDef  :: proc() -> RevoluteJointDef ---

	// Use this to initialize your joint definition
	// @ingroup spherical_joint
	DefaultSphericalJointDef :: proc() -> SphericalJointDef ---

	// Use this to initialize your joint definition
	// @ingroup weld_joint
	DefaultWeldJointDef      :: proc() -> WeldJointDef ---

	// Use this to initialize your joint definition
	// @ingroup wheel_joint
	DefaultWheelJointDef     :: proc() -> WheelJointDef ---

	// Use this to initialize your explosion definition
	// @ingroup world
	DefaultExplosionDef      :: proc() -> ExplosionDef ---

	// Use this to initialize your drawing interface. This allows you to implement a sub-set
	// of the drawing functions.
	DefaultDebugDraw         :: proc() -> DebugDraw ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup world World
	 * These functions allow you to create a simulation world.
	 *
	 * You can add rigid bodies and joint constraints to the world and run the simulation. You can get contact
	 * information to get contact points and normals as well as events. You can query the world, checking for overlaps and casting
	 * rays or shapes. There is also debugging information such as debug draw, timing information, and counters.
	 */

	// Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You may create
	// up to 128 worlds. Each world is completely independent and may be simulated in parallel.
	// @return the world id.
	CreateWorld                   :: proc(#by_ptr def: WorldDef) -> WorldId ---

	// Destroy a world
	DestroyWorld                  :: proc(worldId: WorldId) ---

	// Get the current number of worlds
	GetWorldCount                 :: proc() -> c.int ---

	// Get the maximum number of simultaneous worlds that have been created
	GetMaxWorldCount              :: proc() -> c.int ---

	// World id validation. Provides validation for up to 64K allocations.
	World_IsValid                 :: proc(id: WorldId) -> bool ---

	// Simulate a world for one time step. This performs collision detection, integration, and constraint solution.
	// @param worldId The world to simulate
	// @param timeStep The amount of time to simulate, this should be a fixed number. Usually 1/60.
	// @param subStepCount The number of sub-steps, increasing the sub-step count can increase accuracy. Usually 4.
	World_Step                    :: proc(worldId: WorldId, timeStep: f32, subStepCount: c.int) ---

	// Call this to draw shapes and other debug draw data
	World_Draw                    :: proc(worldId: WorldId, draw: ^DebugDraw, maskBits: u64) ---

	// Get the world's bounds. This is the bounding box that covers the current simulation. May have a small
	// amount of padding.
	World_GetBounds               :: proc(worldId: WorldId) -> AABB ---

	// Get the body events for the current time step. The event data is transient. Do not store a reference to this data.
	World_GetBodyEvents           :: proc(worldId: WorldId) -> BodyEvents ---

	// Get sensor events for the current time step. The event data is transient. Do not store a reference to this data.
	World_GetSensorEvents         :: proc(worldId: WorldId) -> SensorEvents ---

	// Get contact events for this current time step. The event data is transient. Do not store a reference to this data.
	World_GetContactEvents        :: proc(worldId: WorldId) -> ContactEvents ---

	// Get the joint events for the current time step. The event data is transient. Do not store a reference to this data.
	World_GetJointEvents          :: proc(worldId: WorldId) -> JointEvents ---

	// Overlap test for all shapes that *potentially* overlap the provided AABB
	World_OverlapAABB             :: proc(worldId: WorldId, aabb: AABB, filter: QueryFilter, fcn: OverlapResultFcn, ctx: rawptr) -> TreeStats ---

	// Overlap test for all shapes that overlap the provided shape proxy. The proxy points are relative
	// to the world origin, which lets the query stay precise far from the world origin.
	World_OverlapShape            :: proc(worldId: WorldId, origin: Pos, #by_ptr proxy: ShapeProxy, filter: QueryFilter, fcn: OverlapResultFcn, ctx: rawptr) -> TreeStats ---

	// Cast a ray into the world to collect shapes in the path of the ray.
	// Your callback function controls whether you get the closest point, any point, or n-points.
	// @note The callback function may receive shapes in any order
	// @return traversal performance counters
	World_CastRay                 :: proc(worldId: WorldId, origin: Pos, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, ctx: rawptr) -> TreeStats ---

	// Cast a ray into the world to collect the closest hit. This is a convenience function. Ignores initial overlap.
	// This is less general than World_CastRay and does not allow for custom filtering.
	World_CastRayClosest          :: proc(worldId: WorldId, origin: Pos, translation: Vec3, filter: QueryFilter) -> RayResult ---

	// Cast a shape through the world. Similar to a cast ray except that a shape is cast instead of a point.
	// The proxy points are relative to the origin and the hit points come back as world positions, so the
	// cast stays precise far from the world origin.
	// @see World_CastRay
	World_CastShape               :: proc(worldId: WorldId, origin: Pos, #by_ptr proxy: ShapeProxy, translation: Vec3, filter: QueryFilter, fcn: CastResultFcn, ctx: rawptr) -> TreeStats ---

	// Cast a capsule mover through the world. This is a special shape cast that handles sliding along other shapes while reducing
	// clipping. This is not a good source of information about what the mover is touching. Instead use the planes returned by
	// World_CollideMover.
	// @return the translation fraction
	World_CastMover               :: proc(worldId: WorldId, origin: Pos, #by_ptr mover: Capsule, translation: Vec3, filter: QueryFilter, fcn: MoverFilterFcn, ctx: rawptr) -> f32 ---

	// Collide a capsule mover with the world, gathering collision planes that can be fed to SolvePlanes. Useful for
	// kinematic character movement. The mover and the returned planes are relative to the origin.
	World_CollideMover            :: proc(worldId: WorldId, origin: Pos, #by_ptr mover: Capsule, filter: QueryFilter, fcn: PlaneResultFcn, ctx: rawptr) ---

	// Enable/disable sleep. If your application does not need sleeping, you can gain some performance
	// by disabling sleep completely at the world level.
	// @see WorldDef
	World_EnableSleeping          :: proc(worldId: WorldId, flag: bool) ---

	// Is body sleeping enabled?
	World_IsSleepingEnabled       :: proc(worldId: WorldId) -> bool ---

	// Enable/disable continuous collision between dynamic and static bodies. Generally you should keep continuous
	// collision enabled to prevent fast moving objects from going through static objects.
	// @see WorldDef
	World_EnableContinuous        :: proc(worldId: WorldId, flag: bool) ---

	// Is continuous collision enabled?
	World_IsContinuousEnabled     :: proc(worldId: WorldId) -> bool ---

	// Adjust the restitution threshold. It is recommended not to make this value very small
	// because it will prevent bodies from sleeping. Usually in meters per second.
	// @see WorldDef
	World_SetRestitutionThreshold :: proc(worldId: WorldId, value: f32) ---

	// Get the restitution speed threshold. Usually in meters per second.
	World_GetRestitutionThreshold :: proc(worldId: WorldId) -> f32 ---

	// Adjust the hit event threshold. This controls the collision speed needed to generate a ContactHitEvent.
	// Usually in meters per second.
	// @see WorldDef::hitEventThreshold
	World_SetHitEventThreshold    :: proc(worldId: WorldId, value: f32) ---

	// Get the hit event speed threshold. Usually in meters per second.
	World_GetHitEventThreshold    :: proc(worldId: WorldId) -> f32 ---

	// Register the custom filter callback. This is optional.
	World_SetCustomFilterCallback :: proc(worldId: WorldId, fcn: CustomFilterFcn, ctx: rawptr) ---

	// Register the pre-solve callback. This is optional.
	World_SetPreSolveCallback     :: proc(worldId: WorldId, fcn: PreSolveFcn, ctx: rawptr) ---

	// Set the gravity vector for the entire world. Box3D has no concept of an up direction and this
	// is left as a decision for the application. Usually in m/s^2.
	// @see WorldDef
	World_SetGravity              :: proc(worldId: WorldId, gravity: Vec3) ---

	// Get the gravity vector
	World_GetGravity              :: proc(worldId: WorldId) -> Vec3 ---

	// Apply a radial explosion
	// @param worldId The world id
	// @param explosionDef The explosion definition
	World_Explode                 :: proc(worldId: WorldId, #by_ptr explosionDef: ExplosionDef) ---

	// Adjust contact tuning parameters
	// @param hertz The contact stiffness (cycles per second)
	// @param dampingRatio The contact bounciness with 1 being critical damping (non-dimensional)
	// @param contactSpeed The maximum contact constraint push out speed (meters per second)
	// @note Advanced feature
	World_SetContactTuning        :: proc(worldId: WorldId, hertz: f32, dampingRatio: f32, contactSpeed: f32) ---

	// Set the contact point recycling distance. Setting this to zero disables contact point recycling.
	// Usually in meters.
	World_SetContactRecycleDistance :: proc(worldId: WorldId, recycleDistance: f32) ---

	// Get the contact point recycling distance. Usually in meters.
	World_GetContactRecycleDistance :: proc(worldId: WorldId) -> f32 ---

	// Set the maximum linear speed. Usually in m/s.
	World_SetMaximumLinearSpeed   :: proc(worldId: WorldId, maximumLinearSpeed: f32) ---

	// Get the maximum linear speed. Usually in m/s.
	World_GetMaximumLinearSpeed   :: proc(worldId: WorldId) -> f32 ---

	// Enable/disable constraint warm starting. Advanced feature for testing. Disabling
	// warm starting greatly reduces stability and provides no performance gain.
	World_EnableWarmStarting      :: proc(worldId: WorldId, flag: bool) ---

	// Is constraint warm starting enabled?
	World_IsWarmStartingEnabled   :: proc(worldId: WorldId) -> bool ---

	// Get the number of awake bodies
	World_GetAwakeBodyCount       :: proc(worldId: WorldId) -> c.int ---

	// Get the current world performance profile
	World_GetProfile              :: proc(worldId: WorldId) -> Profile ---

	// Get world counters and sizes
	World_GetCounters             :: proc(worldId: WorldId) -> Counters ---

	// Get max capacity. This can be used with WorldDef to avoid run-time allocations and copies
	World_GetMaxCapacity          :: proc(worldId: WorldId) -> Capacity ---

	// Set the user data pointer.
	World_SetUserData             :: proc(worldId: WorldId, userData: rawptr) ---

	// Get the user data pointer.
	World_GetUserData             :: proc(worldId: WorldId) -> rawptr ---

	// Set the friction callback. Passing nil resets to default.
	World_SetFrictionCallback     :: proc(worldId: WorldId, callback: FrictionCallback) ---

	// Set the restitution callback. Passing nil resets to default.
	World_SetRestitutionCallback  :: proc(worldId: WorldId, callback: RestitutionCallback) ---

	// Set the worker count. Must be in the range [1, MAX_WORKERS]
	World_SetWorkerCount          :: proc(worldId: WorldId, count: c.int) ---

	// Get the worker count.
	World_GetWorkerCount          :: proc(worldId: WorldId) -> c.int ---

	// Dump memory stats to log.
	World_DumpMemoryStats         :: proc(worldId: WorldId) ---

	// Dump shape bounds to box3d_bounds.txt
	World_DumpShapeBounds         :: proc(worldId: WorldId, type: BodyType) ---

	// This is for internal testing
	World_RebuildStaticTree       :: proc(worldId: WorldId) ---

	// This is for internal testing
	World_EnableSpeculative       :: proc(worldId: WorldId, flag: bool) ---

	// Dump world to a text file. Saves only awake bodies and associated static bodies.
	// Meshes are saved to binary b3m files.
	World_DumpAwake               :: proc(worldId: WorldId) ---

	// Dump world to a text file. Meshes are saved to binary b3m files.
	World_Dump                    :: proc(worldId: WorldId) ---
}


/**
 * @defgroup recording Recording
 * @brief Record and replay world state for debugging.
 */

// Opaque recording handle. Create with CreateRecording, destroy with DestroyRecording.
Recording :: struct {}

// Opaque incremental replay player with a keyframe ring for O(interval) backward seek.
RecPlayer :: struct {}

// Summary of a recording, read once at open so a viewer can frame and label it.
RecPlayerInfo :: struct {
	frameCount:   c.int, // total recorded steps
	workerCount:  c.int, // worker count requested for the replay world
	timeStep:     f32,   // dt of the recorded steps
	subStepCount: c.int, // recorded sub-steps
	lengthScale:  f32,   // length units per meter in effect when recorded
	bounds:       AABB,  // accumulated world bounds over the recording, zero-extent if unavailable
}

// The kind of a recorded spatial query, matching the public query and cast functions.
RecQueryType :: enum c.int {
	OverlapAABB,
	OverlapShape,
	CastRay,
	CastShape,
	CastRayClosest,
	CastMover,
	CollideMover,
}

// A spatial query recorded during a replayed frame, exposed for inspection.
RecQueryInfo :: struct {
	type:        RecQueryType,
	filter:      QueryFilter,
	aabb:        AABB,   // world-space bounds of the query, swept for casts
	origin:      Pos,    // query origin (zero for overlap AABB)
	translation: Vec3,   // ray and cast translation
	hitCount:    c.int,  // number of recorded results
	key:         u64,    // identity key, the hash of (id, name), 0 if untagged
	id:          u64,    // query id, 0 if none
	name:        cstring, // query label, nil if none
}

// One result of a recorded spatial query.
RecQueryHit :: struct {
	shape:    ShapeId,
	point:    Pos,
	normal:   Vec3,
	fraction: f32,
}

@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	// Create a recording buffer with an optional initial byte capacity.
	// Pass 0 to use the default (64 KiB). The buffer grows on demand.
	CreateRecording               :: proc(byteCapacity: c.int) -> ^Recording ---

	// Destroy a recording and free its buffer.
	DestroyRecording              :: proc(recording: ^Recording) ---

	// Get a pointer to the raw recording bytes.
	// Valid until the recording buffer is modified or destroyed.
	Recording_GetData             :: proc(recording: ^Recording) -> [^]u8 ---

	// Get the number of bytes currently in the recording buffer.
	Recording_GetSize             :: proc(recording: ^Recording) -> c.int ---

	// Begin recording world mutations into the provided buffer.
	// The buffer is reset on each call so a single Recording can be reused for multiple sessions.
	World_StartRecording          :: proc(worldId: WorldId, recording: ^Recording) ---

	// End the current recording session. Writes the trailing geometry registry and
	// backpatches the header. The buffer remains valid until the recording is destroyed.
	World_StopRecording           :: proc(worldId: WorldId) ---

	// Save the recording buffer to a file. Returns true on success.
	SaveRecordingToFile           :: proc(recording: ^Recording, path: cstring) -> bool ---

	// Load a recording from a file. Returns nil on failure (file not found, wrong magic).
	LoadRecordingFromFile         :: proc(path: cstring) -> ^Recording ---

	// Replay a recording from memory and verify it reproduces the same world-state hashes.
	ValidateReplay                :: proc(data: rawptr, size: c.int, workerCount: c.int) -> bool ---

	// Create a player over a recording. Owns a private copy of the bytes.
	// @return a new player, or nil on bad header or deserialization failure
	RecPlayer_Create              :: proc(data: rawptr, size: c.int, workerCount: c.int) -> ^RecPlayer ---

	// Destroy the player and free all memory. Restores the previous global length scale.
	RecPlayer_Destroy             :: proc(player: ^RecPlayer) ---

	// Advance one frame: dispatch ops until the next Step completes.
	// @return true when a frame was stepped, false at end-of-recording
	RecPlayer_StepFrame           :: proc(player: ^RecPlayer) -> bool ---

	// Rewind to frame 0 (in-place restore so the world id stays stable).
	RecPlayer_Restart             :: proc(player: ^RecPlayer) ---

	// Seek to a specific frame. Forward seek steps op-by-op; backward seek restores
	// the nearest keyframe then re-steps the remaining gap.
	RecPlayer_SeekFrame           :: proc(player: ^RecPlayer, targetFrame: c.int) ---

	// @return the world currently driven by this player
	RecPlayer_GetWorldId          :: proc(player: ^RecPlayer) -> WorldId ---

	// @return the last fully-stepped frame index (0 before any step)
	RecPlayer_GetFrame            :: proc(player: ^RecPlayer) -> c.int ---

	// @return total number of recorded frames
	RecPlayer_GetFrameCount       :: proc(player: ^RecPlayer) -> c.int ---

	// @return true when the op stream is exhausted
	RecPlayer_IsAtEnd             :: proc(player: ^RecPlayer) -> bool ---

	// @return true when any StateHash mismatch has been detected
	RecPlayer_HasDiverged         :: proc(player: ^RecPlayer) -> bool ---

	// @return a summary of the recording read at open: frame count, recorded tuning, and bounds
	RecPlayer_GetInfo             :: proc(player: ^RecPlayer) -> RecPlayerInfo ---

	// @return the first frame at which replay diverged, or -1 if it has not diverged
	RecPlayer_GetDivergeFrame     :: proc(player: ^RecPlayer) -> c.int ---

	// Set the worker count of the replay world. Clamped to [1, MAX_WORKERS].
	RecPlayer_SetWorkerCount      :: proc(player: ^RecPlayer, count: c.int) ---

	// Tune the keyframe ring used to speed up backward seeking.
	RecPlayer_SetKeyframePolicy   :: proc(player: ^RecPlayer, budgetBytes: c.size_t, minIntervalFrames: c.int) ---

	// @return the keyframe memory budget in bytes
	RecPlayer_GetKeyframeBudget   :: proc(player: ^RecPlayer) -> c.size_t ---

	// @return the finest keyframe spacing in frames
	RecPlayer_GetKeyframeMinInterval :: proc(player: ^RecPlayer) -> c.int ---

	// @return the current keyframe spacing in frames
	RecPlayer_GetKeyframeInterval :: proc(player: ^RecPlayer) -> c.int ---

	// @return the memory currently held by keyframe snapshots, in bytes
	RecPlayer_GetKeyframeBytes    :: proc(player: ^RecPlayer) -> c.size_t ---

	// @return the number of bodies tracked in creation order (including holes for destroyed bodies)
	RecPlayer_GetBodyCount        :: proc(player: ^RecPlayer) -> c.int ---

	// Resolve a creation ordinal to the live body id at the current frame.
	RecPlayer_GetBodyId           :: proc(player: ^RecPlayer, index: c.int) -> BodyId ---

	// Wire host debug-shape callbacks into the player's replay world so a renderer can build
	// per-shape draw resources.
	RecPlayer_SetDebugShapeCallbacks :: proc(player: ^RecPlayer, createDebugShape: CreateDebugShapeCallback, destroyDebugShape: DestroyDebugShapeCallback, ctx: rawptr) ---

	// Draw the spatial queries recorded during the most recently replayed frame, layered on top of the world.
	RecPlayer_DrawFrameQueries    :: proc(player: ^RecPlayer, draw: ^DebugDraw, queryIndex: c.int, selectedIndex: c.int) ---

	// @return the number of spatial queries recorded for the most recently replayed frame
	RecPlayer_GetFrameQueryCount  :: proc(player: ^RecPlayer) -> c.int ---

	// Get a recorded query from the most recently replayed frame by index.
	RecPlayer_GetFrameQuery       :: proc(player: ^RecPlayer, index: c.int) -> RecQueryInfo ---

	// Get one result of a recorded query from the most recently replayed frame.
	RecPlayer_GetFrameQueryHit    :: proc(player: ^RecPlayer, queryIndex: c.int, hitIndex: c.int) -> RecQueryHit ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup body Body
	 * This is the body API.
	 */

	// Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
	// on the stack and pass it as a pointer.
	// @warning This function is locked during callbacks.
	CreateBody                      :: proc(worldId: WorldId, #by_ptr def: BodyDef) -> BodyId ---

	// Destroy a rigid body given an id. This destroys all shapes and joints attached to the body.
	// Do not keep references to the associated shapes and joints.
	DestroyBody                     :: proc(bodyId: BodyId) ---

	// Body identifier validation. A valid body exists in a world and is non-null.
	Body_IsValid                    :: proc(id: BodyId) -> bool ---

	// Get the body type: static, kinematic, or dynamic
	Body_GetType                    :: proc(bodyId: BodyId) -> BodyType ---

	// Change the body type. This is an expensive operation. This automatically updates the mass
	// properties regardless of the automatic mass setting.
	Body_SetType                    :: proc(bodyId: BodyId, type: BodyType) ---

	// Set the body name. Up to BODY_NAME_LENGTH characters including null termination.
	Body_SetName                    :: proc(bodyId: BodyId, name: cstring) ---

	// Get the body name.
	Body_GetName                    :: proc(bodyId: BodyId) -> cstring ---

	// Set the user data for a body
	Body_SetUserData                :: proc(bodyId: BodyId, userData: rawptr) ---

	// Get the user data stored in a body
	Body_GetUserData                :: proc(bodyId: BodyId) -> rawptr ---

	// Get the world position of a body. This is the location of the body origin.
	Body_GetPosition                :: proc(bodyId: BodyId) -> Pos ---

	// Get the world rotation of a body as a quaternion
	Body_GetRotation                :: proc(bodyId: BodyId) -> Quat ---

	// Get the world transform of a body.
	Body_GetTransform               :: proc(bodyId: BodyId) -> WorldTransform ---

	// Set the world transform of a body. This acts as a teleport and is fairly expensive.
	// @note Generally you should create a body with the intended transform.
	Body_SetTransform               :: proc(bodyId: BodyId, position: Pos, rotation: Quat) ---

	// Get a local point on a body given a world point
	Body_GetLocalPoint              :: proc(bodyId: BodyId, worldPoint: Pos) -> Vec3 ---

	// Get a world point on a body given a local point
	Body_GetWorldPoint              :: proc(bodyId: BodyId, localPoint: Vec3) -> Pos ---

	// Get a local vector on a body given a world vector
	Body_GetLocalVector             :: proc(bodyId: BodyId, worldVector: Vec3) -> Vec3 ---

	// Get a world vector on a body given a local vector
	Body_GetWorldVector             :: proc(bodyId: BodyId, localVector: Vec3) -> Vec3 ---

	// Get the linear velocity of a body's center of mass. Usually in meters per second.
	Body_GetLinearVelocity          :: proc(bodyId: BodyId) -> Vec3 ---

	// Get the angular velocity of a body in radians per second
	Body_GetAngularVelocity         :: proc(bodyId: BodyId) -> Vec3 ---

	// Set the linear velocity of a body. Usually in meters per second.
	Body_SetLinearVelocity          :: proc(bodyId: BodyId, linearVelocity: Vec3) ---

	// Set the angular velocity of a body in radians per second
	Body_SetAngularVelocity         :: proc(bodyId: BodyId, angularVelocity: Vec3) ---

	// Set the velocity to reach the given transform after a given time step.
	// The result will be close but maybe not exact. This is meant for kinematic bodies.
	Body_SetTargetTransform         :: proc(bodyId: BodyId, target: WorldTransform, timeStep: f32, wake: bool) ---

	// Get the linear velocity of a local point attached to a body. Usually in meters per second.
	Body_GetLocalPointVelocity      :: proc(bodyId: BodyId, localPoint: Vec3) -> Vec3 ---

	// Get the linear velocity of a world point attached to a body. Usually in meters per second.
	Body_GetWorldPointVelocity      :: proc(bodyId: BodyId, worldPoint: Pos) -> Vec3 ---

	// Apply a force at a world point. If the force is not applied at the center of mass,
	// it will generate a torque and affect the angular velocity. This optionally wakes up the body.
	Body_ApplyForce                 :: proc(bodyId: BodyId, force: Vec3, point: Pos, wake: bool) ---

	// Apply a force to the center of mass. This optionally wakes up the body.
	Body_ApplyForceToCenter         :: proc(bodyId: BodyId, force: Vec3, wake: bool) ---

	// Apply a torque. This affects the angular velocity without affecting the linear velocity.
	Body_ApplyTorque                :: proc(bodyId: BodyId, torque: Vec3, wake: bool) ---

	// Apply an impulse at a point. This immediately modifies the velocity.
	// @warning This should be used for one-shot impulses.
	Body_ApplyLinearImpulse         :: proc(bodyId: BodyId, impulse: Vec3, point: Pos, wake: bool) ---

	// Apply an impulse to the center of mass. This immediately modifies the velocity.
	Body_ApplyLinearImpulseToCenter :: proc(bodyId: BodyId, impulse: Vec3, wake: bool) ---

	// Apply an angular impulse in world space. The impulse is ignored if the body is not awake.
	Body_ApplyAngularImpulse        :: proc(bodyId: BodyId, impulse: Vec3, wake: bool) ---

	// Get the mass of the body, usually in kilograms
	Body_GetMass                    :: proc(bodyId: BodyId) -> f32 ---

	// Get the rotational inertia of the body in local space, usually in kg*m^2
	Body_GetLocalRotationalInertia  :: proc(bodyId: BodyId) -> Matrix3 ---

	// Get the inverse mass of the body, usually in 1/kilograms
	Body_GetInverseMass             :: proc(bodyId: BodyId) -> f32 ---

	// Get the inverse rotational inertia of the body in world space, usually in 1/kg*m^2
	Body_GetWorldInverseRotationalInertia :: proc(bodyId: BodyId) -> Matrix3 ---

	// Get the center of mass position of the body in local space
	Body_GetLocalCenterOfMass       :: proc(bodyId: BodyId) -> Vec3 ---

	// Get the center of mass position of the body in world space
	Body_GetWorldCenterOfMass       :: proc(bodyId: BodyId) -> Pos ---

	// Override the body's mass properties. Normally this is computed automatically using the
	// shape geometry and density.
	Body_SetMassData                :: proc(bodyId: BodyId, massData: MassData) ---

	// Get the mass data for a body
	Body_GetMassData                :: proc(bodyId: BodyId) -> MassData ---

	// This updates the mass properties to the sum of the mass properties of the shapes.
	Body_ApplyMassFromShapes        :: proc(bodyId: BodyId) ---

	// Adjust the linear damping. Normally this is set in BodyDef before creation.
	Body_SetLinearDamping           :: proc(bodyId: BodyId, linearDamping: f32) ---

	// Get the current linear damping.
	Body_GetLinearDamping           :: proc(bodyId: BodyId) -> f32 ---

	// Adjust the angular damping. Normally this is set in BodyDef before creation.
	Body_SetAngularDamping          :: proc(bodyId: BodyId, angularDamping: f32) ---

	// Get the current angular damping.
	Body_GetAngularDamping          :: proc(bodyId: BodyId) -> f32 ---

	// Adjust the gravity scale. Normally this is set in BodyDef before creation.
	Body_SetGravityScale            :: proc(bodyId: BodyId, gravityScale: f32) ---

	// Get the current gravity scale
	Body_GetGravityScale            :: proc(bodyId: BodyId) -> f32 ---

	// @return true if this body is awake
	Body_IsAwake                    :: proc(bodyId: BodyId) -> bool ---

	// Wake a body from sleep. This wakes the entire island the body is touching.
	Body_SetAwake                   :: proc(bodyId: BodyId, awake: bool) ---

	// Enable or disable sleeping for this body. If sleeping is disabled the body will wake.
	Body_EnableSleep                :: proc(bodyId: BodyId, enableSleep: bool) ---

	// Returns true if sleeping is enabled for this body
	Body_IsSleepEnabled             :: proc(bodyId: BodyId) -> bool ---

	// Set the sleep threshold, usually in meters per second
	Body_SetSleepThreshold          :: proc(bodyId: BodyId, sleepThreshold: f32) ---

	// Get the sleep threshold, usually in meters per second.
	Body_GetSleepThreshold          :: proc(bodyId: BodyId) -> f32 ---

	// Returns true if this body is enabled
	Body_IsEnabled                  :: proc(bodyId: BodyId) -> bool ---

	// Disable a body by removing it completely from the simulation. This is expensive.
	Body_Disable                    :: proc(bodyId: BodyId) ---

	// Enable a body by adding it to the simulation. This is expensive.
	Body_Enable                     :: proc(bodyId: BodyId) ---

	// Set the motion locks on this body.
	Body_SetMotionLocks             :: proc(bodyId: BodyId, locks: MotionLocks) ---

	// Get the motion locks for this body.
	Body_GetMotionLocks             :: proc(bodyId: BodyId) -> MotionLocks ---

	// Set this body to be a bullet. A bullet does continuous collision detection
	// against dynamic bodies (but not other bullets).
	Body_SetBullet                  :: proc(bodyId: BodyId, flag: bool) ---

	// Is this body a bullet?
	Body_IsBullet                   :: proc(bodyId: BodyId) -> bool ---

	// Enable or disable contact recycling for this body.
	// @see BodyDef::enableContactRecycling
	Body_EnableContactRecycling     :: proc(bodyId: BodyId, flag: bool) ---

	// Is contact recycling enabled on this body?
	Body_IsContactRecyclingEnabled  :: proc(bodyId: BodyId) -> bool ---

	// Enable/disable hit events on all shapes
	// @see ShapeDef::enableHitEvents
	Body_EnableHitEvents            :: proc(bodyId: BodyId, enableHitEvents: bool) ---

	// Get the world that owns this body
	Body_GetWorld                   :: proc(bodyId: BodyId) -> WorldId ---

	// Get the number of shapes on this body
	Body_GetShapeCount              :: proc(bodyId: BodyId) -> c.int ---

	// Get the number of joints on this body
	Body_GetJointCount              :: proc(bodyId: BodyId) -> c.int ---

	// Get the maximum capacity required for retrieving all the touching contacts on a body
	Body_GetContactCapacity         :: proc(bodyId: BodyId) -> c.int ---

	// Get the current world AABB that contains all the attached shapes.
	Body_ComputeAABB                :: proc(bodyId: BodyId) -> AABB ---

	// Get the closest point on a body to a world target.
	Body_GetClosestPoint            :: proc(bodyId: BodyId, result: ^Vec3, target: Vec3) -> f32 ---

	// Cast a ray at a specific body using a specified body transform.
	Body_CastRay                    :: proc(bodyId: BodyId, origin: Pos, translation: Vec3, filter: QueryFilter, maxFraction: f32, bodyTransform: WorldTransform) -> BodyCastResult ---

	// Cast a shape at a specific body using a specified body transform.
	Body_CastShape                  :: proc(bodyId: BodyId, origin: Pos, #by_ptr proxy: ShapeProxy, translation: Vec3, filter: QueryFilter, maxFraction: f32, canEncroach: bool, bodyTransform: WorldTransform) -> BodyCastResult ---

	// Overlap a shape with a specific body using a specified body transform.
	Body_OverlapShape               :: proc(bodyId: BodyId, origin: Pos, #by_ptr proxy: ShapeProxy, filter: QueryFilter, bodyTransform: WorldTransform) -> bool ---

	// Collide a character mover with a specific body using a specified body transform.
	Body_CollideMover               :: proc(bodyId: BodyId, bodyPlanes: [^]BodyPlaneResult, planeCapacity: c.int, origin: Pos, #by_ptr mover: Capsule, filter: QueryFilter, bodyTransform: WorldTransform) -> c.int ---
}

// Get the shape ids for all shapes on this body, up to the provided capacity.
// @returns the shape ids stored in the user array
@(require_results)
Body_GetShapes :: proc "c" (bodyId: BodyId, shapeArray: []ShapeId) -> []ShapeId {
	foreign lib {
		b3Body_GetShapes :: proc "c" (bodyId: BodyId, shapeArray: [^]ShapeId, capacity: c.int) -> c.int ---
	}
	n := b3Body_GetShapes(bodyId, raw_data(shapeArray), c.int(len(shapeArray)))
	return shapeArray[:n]
}

// Get the joint ids for all joints on this body, up to the provided capacity
// @returns the joint ids stored in the user array
@(require_results)
Body_GetJoints :: proc "c" (bodyId: BodyId, jointArray: []JointId) -> []JointId {
	foreign lib {
		b3Body_GetJoints :: proc "c" (bodyId: BodyId, jointArray: [^]JointId, capacity: c.int) -> c.int ---
	}
	n := b3Body_GetJoints(bodyId, raw_data(jointArray), c.int(len(jointArray)))
	return jointArray[:n]
}

// Get the touching contact data for a body
@(require_results)
Body_GetContactData :: proc "c" (bodyId: BodyId, contactData: []ContactData) -> []ContactData {
	foreign lib {
		b3Body_GetContactData :: proc "c" (bodyId: BodyId, contactData: [^]ContactData, capacity: c.int) -> c.int ---
	}
	n := b3Body_GetContactData(bodyId, raw_data(contactData), c.int(len(contactData)))
	return contactData[:n]
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup shape Shape
	 * Functions to create, destroy, and access.
	 * Shapes bind raw geometry to bodies and hold material properties including friction and restitution.
	 */

	// Create a sphere shape and attach it to a body. The shape definition and geometry are fully cloned.
	// @return the shape id for accessing the shape
	CreateSphereShape              :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, #by_ptr sphere: Sphere) -> ShapeId ---

	// Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
	// @return the shape id for accessing the shape
	CreateCapsuleShape             :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, #by_ptr capsule: Capsule) -> ShapeId ---

	// Create a convex hull shape and attach it to a body. The shape definition is fully cloned.
	// @return the shape id for accessing the shape
	// NOTE: `hull` is a raw pointer (not #by_ptr): HullData/MeshData/HeightFieldData are
	// variable-length — their vertex/edge/face arrays follow the header and are referenced by
	// byte offsets. #by_ptr would copy only the fixed-size header to a temporary, so the
	// offsets would point past it into garbage (b3IsValidHull fails → invalid AABB / crash).
	CreateHullShape                :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, hull: ^HullData) -> ShapeId ---

	// Create a convex hull shape and attach it to a body. The hull is cloned then transformed with scale applied first.
	// @return the shape id for accessing the shape
	CreateTransformedHullShape     :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, hull: ^HullData, transform: Transform, scale: Vec3) -> ShapeId ---

	// Create a mesh hull shape and attach it to a body. The shape definition is fully cloned but the mesh is not.
	// @warning this holds reference to the input mesh data which must remain valid for the lifetime of this shape
	// @return the shape id for accessing the shape
	CreateMeshShape                :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, mesh: ^MeshData, scale: Vec3) -> ShapeId ---

	// Create a height-field shape and attach it to a body. The shape definition is fully cloned but the height field is not.
	// @warning this holds reference to the input height field which must remain valid for the lifetime of this shape
	// @return the shape id for accessing the shape
	CreateHeightFieldShape         :: proc(bodyId: BodyId, #by_ptr def: ShapeDef, heightField: ^HeightFieldData) -> ShapeId ---

	// Compound shapes are only allowed on static bodies.
	CreateCompoundShape            :: proc(bodyId: BodyId, def: ^ShapeDef, compound: ^CompoundData) -> ShapeId ---

	// Destroy a shape. You may defer the body mass update which can improve performance if several shapes on a
	// body are destroyed at once.
	// @see Body_ApplyMassFromShapes
	DestroyShape                   :: proc(shapeId: ShapeId, updateBodyMass: bool) ---

	// Shape identifier validation. Provides validation for up to 64K allocations.
	Shape_IsValid                  :: proc(id: ShapeId) -> bool ---

	// Get the type of a shape
	Shape_GetType                  :: proc(shapeId: ShapeId) -> ShapeType ---

	// Get the id of the body that a shape is attached to
	Shape_GetBody                  :: proc(shapeId: ShapeId) -> BodyId ---

	// Get the world that owns this shape
	Shape_GetWorld                 :: proc(shapeId: ShapeId) -> WorldId ---

	// Returns true if the shape is a sensor
	Shape_IsSensor                 :: proc(shapeId: ShapeId) -> bool ---

	// Set the user data for a shape
	Shape_SetUserData              :: proc(shapeId: ShapeId, userData: rawptr) ---

	// Get the user data for a shape. This is useful when you get a shape id from an event or query.
	Shape_GetUserData              :: proc(shapeId: ShapeId) -> rawptr ---

	// Set the mass density of a shape, usually in kg/m^3.
	// @see ShapeDef::density, Body_ApplyMassFromShapes
	Shape_SetDensity               :: proc(shapeId: ShapeId, density: f32, updateBodyMass: bool) ---

	// Get the density of a shape, usually in kg/m^3
	Shape_GetDensity               :: proc(shapeId: ShapeId) -> f32 ---

	// Set the friction on a shape
	Shape_SetFriction              :: proc(shapeId: ShapeId, friction: f32) ---

	// Get the friction of a shape
	Shape_GetFriction              :: proc(shapeId: ShapeId) -> f32 ---

	// Set the shape restitution (bounciness)
	Shape_SetRestitution           :: proc(shapeId: ShapeId, restitution: f32) ---

	// Get the shape restitution
	Shape_GetRestitution           :: proc(shapeId: ShapeId) -> f32 ---

	// Set the shape base surface material. Does not change per triangle materials.
	Shape_SetSurfaceMaterial       :: proc(shapeId: ShapeId, surfaceMaterial: SurfaceMaterial) ---

	// Get the base shape surface material.
	Shape_GetSurfaceMaterial       :: proc(shapeId: ShapeId) -> SurfaceMaterial ---

	// Get the number of mesh surface materials.
	Shape_GetMeshMaterialCount     :: proc(shapeId: ShapeId) -> c.int ---

	// Set a surface material for a mesh shape.
	Shape_SetMeshMaterial          :: proc(shapeId: ShapeId, surfaceMaterial: SurfaceMaterial, index: c.int) ---

	// Get a surface material for a mesh shape
	Shape_GetMeshSurfaceMaterial   :: proc(shapeId: ShapeId, index: c.int) -> SurfaceMaterial ---

	// Get the shape filter
	Shape_GetFilter                :: proc(shapeId: ShapeId) -> Filter ---

	// Set the current filter. This is almost as expensive as recreating the shape.
	// @see ShapeDef::filter
	Shape_SetFilter                :: proc(shapeId: ShapeId, filter: Filter, invokeContacts: bool) ---

	// Enable sensor events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	Shape_EnableSensorEvents       :: proc(shapeId: ShapeId, flag: bool) ---

	// Returns true if sensor events are enabled
	Shape_AreSensorEventsEnabled   :: proc(shapeId: ShapeId) -> bool ---

	// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
	Shape_EnableContactEvents      :: proc(shapeId: ShapeId, flag: bool) ---

	// Returns true if contact events are enabled
	Shape_AreContactEventsEnabled  :: proc(shapeId: ShapeId) -> bool ---

	// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. Ignored for sensors.
	Shape_EnablePreSolveEvents     :: proc(shapeId: ShapeId, flag: bool) ---

	// Returns true if pre-solve events are enabled
	Shape_ArePreSolveEventsEnabled :: proc(shapeId: ShapeId) -> bool ---

	// Enable contact hit events for this shape. Ignored for sensors.
	Shape_EnableHitEvents          :: proc(shapeId: ShapeId, flag: bool) ---

	// Returns true if hit events are enabled
	Shape_AreHitEventsEnabled      :: proc(shapeId: ShapeId) -> bool ---

	// Ray cast a shape directly. The ray runs from origin to origin + translation and the hit point
	// comes back as a world position, so the cast stays precise far from the world origin.
	Shape_RayCast                  :: proc(shapeId: ShapeId, origin: Pos, translation: Vec3) -> WorldCastOutput ---

	// Get a copy of the shape's sphere. Asserts the type is correct.
	Shape_GetSphere                :: proc(shapeId: ShapeId) -> Sphere ---

	// Get a copy of the shape's capsule. Asserts the type is correct.
	Shape_GetCapsule               :: proc(shapeId: ShapeId) -> Capsule ---

	// Get the shape's convex hull. Asserts the type is correct.
	Shape_GetHull                  :: proc(shapeId: ShapeId) -> ^HullData ---

	// Get the shape's mesh. Asserts the type is correct.
	Shape_GetMesh                  :: proc(shapeId: ShapeId) -> Mesh ---

	// Get the shape's height field. Asserts the type is correct.
	Shape_GetHeightField           :: proc(shapeId: ShapeId) -> ^HeightFieldData ---

	// Allows you to change a shape to be a sphere or update the current sphere.
	// @see Body_ApplyMassFromShapes
	Shape_SetSphere                :: proc(shapeId: ShapeId, #by_ptr sphere: Sphere) ---

	// Allows you to change a shape to be a capsule or update the current capsule.
	// @see Body_ApplyMassFromShapes
	Shape_SetCapsule               :: proc(shapeId: ShapeId, #by_ptr capsule: Capsule) ---

	// Allows you to change a shape to be a hull or update the current hull.
	// @see Body_ApplyMassFromShapes
	Shape_SetHull                  :: proc(shapeId: ShapeId, hull: ^HullData) ---

	// Allows you to change a shape to be a mesh or update the current mesh.
	// @see Body_ApplyMassFromShapes
	Shape_SetMesh                  :: proc(shapeId: ShapeId, meshData: ^MeshData, scale: Vec3) ---

	// Get the maximum capacity required for retrieving all the touching contacts on a shape
	Shape_GetContactCapacity       :: proc(shapeId: ShapeId) -> c.int ---

	// Get the maximum capacity required for retrieving all the overlapped shapes on a sensor shape.
	Shape_GetSensorCapacity        :: proc(shapeId: ShapeId) -> c.int ---

	// Get the current world AABB
	Shape_GetAABB                  :: proc(shapeId: ShapeId) -> AABB ---

	// Compute the mass data for a shape
	Shape_ComputeMassData          :: proc(shapeId: ShapeId) -> MassData ---

	// Get the closest point on a shape to a target point. Target and result are in world space.
	Shape_GetClosestPoint          :: proc(shapeId: ShapeId, target: Vec3) -> Vec3 ---

	// Apply a wind force to the body for this shape using the density of air.
	Shape_ApplyWind                :: proc(shapeId: ShapeId, wind: Vec3, drag: f32, lift: f32, maxSpeed: f32, wake: bool) ---
}

// Get the touching contact data for a shape. The provided shapeId will be either shapeIdA or shapeIdB on the contact data.
@(require_results)
Shape_GetContactData :: proc "c" (shapeId: ShapeId, contactData: []ContactData) -> []ContactData {
	foreign lib {
		b3Shape_GetContactData :: proc "c" (shapeId: ShapeId, contactData: [^]ContactData, capacity: c.int) -> c.int ---
	}
	n := b3Shape_GetContactData(shapeId, raw_data(contactData), c.int(len(contactData)))
	return contactData[:n]
}

// Get the overlap data for a sensor shape.
// @warning overlaps may contain destroyed shapes so use Shape_IsValid to confirm each overlap
@(require_results)
Shape_GetSensorData :: proc "c" (shapeId: ShapeId, visitorIds: []ShapeId) -> []ShapeId {
	foreign lib {
		b3Shape_GetSensorData :: proc "c" (shapeId: ShapeId, visitorIds: [^]ShapeId, capacity: c.int) -> c.int ---
	}
	n := b3Shape_GetSensorData(shapeId, raw_data(visitorIds), c.int(len(visitorIds)))
	return visitorIds[:n]
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup joint Joint
	 * @brief Joints allow you to connect rigid bodies together while allowing various forms of relative motions.
	 */

	// Destroy a joint
	DestroyJoint               :: proc(jointId: JointId, wakeAttached: bool) ---

	// Joint identifier validation. Provides validation for up to 64K allocations.
	Joint_IsValid              :: proc(id: JointId) -> bool ---

	// Get the joint type
	Joint_GetType              :: proc(jointId: JointId) -> JointType ---

	// Get body A id on a joint
	Joint_GetBodyA             :: proc(jointId: JointId) -> BodyId ---

	// Get body B id on a joint
	Joint_GetBodyB             :: proc(jointId: JointId) -> BodyId ---

	// Get the world that owns this joint
	Joint_GetWorld             :: proc(jointId: JointId) -> WorldId ---

	// Set the local frame on bodyA
	Joint_SetLocalFrameA       :: proc(jointId: JointId, localFrame: Transform) ---

	// Get the local frame on bodyA
	Joint_GetLocalFrameA       :: proc(jointId: JointId) -> Transform ---

	// Set the local frame on bodyB
	Joint_SetLocalFrameB       :: proc(jointId: JointId, localFrame: Transform) ---

	// Get the local frame on bodyB
	Joint_GetLocalFrameB       :: proc(jointId: JointId) -> Transform ---

	// Toggle collision between connected bodies
	Joint_SetCollideConnected  :: proc(jointId: JointId, shouldCollide: bool) ---

	// Is collision allowed between connected bodies?
	Joint_GetCollideConnected  :: proc(jointId: JointId) -> bool ---

	// Set the user data on a joint
	Joint_SetUserData          :: proc(jointId: JointId, userData: rawptr) ---

	// Get the user data on a joint
	Joint_GetUserData          :: proc(jointId: JointId) -> rawptr ---

	// Wake the bodies connect to this joint
	Joint_WakeBodies           :: proc(jointId: JointId) ---

	// Get the current constraint force for this joint
	Joint_GetConstraintForce   :: proc(jointId: JointId) -> Vec3 ---

	// Get the current constraint torque for this joint
	Joint_GetConstraintTorque  :: proc(jointId: JointId) -> Vec3 ---

	// Get the current linear separation error for this joint. Usually in meters.
	Joint_GetLinearSeparation  :: proc(jointId: JointId) -> f32 ---

	// Get the current angular separation error for this joint. Usually in radians.
	Joint_GetAngularSeparation :: proc(jointId: JointId) -> f32 ---

	// Set the joint constraint tuning. Advanced feature.
	// @param hertz the stiffness in Hertz (cycles per second)
	// @param dampingRatio the non-dimensional damping ratio (one for critical damping)
	Joint_SetConstraintTuning  :: proc(jointId: JointId, hertz: f32, dampingRatio: f32) ---

	// Get the joint constraint tuning. Advanced feature.
	Joint_GetConstraintTuning  :: proc(jointId: JointId, hertz: ^f32, dampingRatio: ^f32) ---

	// Set the force threshold for joint events (Newtons)
	Joint_SetForceThreshold    :: proc(jointId: JointId, threshold: f32) ---

	// Get the force threshold for joint events (Newtons)
	Joint_GetForceThreshold    :: proc(jointId: JointId) -> f32 ---

	// Set the torque threshold for joint events (N-m)
	Joint_SetTorqueThreshold   :: proc(jointId: JointId, threshold: f32) ---

	// Get the torque threshold for joint events (N-m)
	Joint_GetTorqueThreshold   :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup parallel_joint Parallel Joint
	 * @brief Functions for the parallel joint.
	 */

	// Create a parallel joint
	// @see ParallelJointDef for details
	CreateParallelJoint                 :: proc(worldId: WorldId, #by_ptr def: ParallelJointDef) -> JointId ---

	// Set the spring stiffness in Hertz
	ParallelJoint_SetSpringHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Set the spring damping ratio, non-dimensional
	ParallelJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the spring Hertz
	ParallelJoint_GetSpringHertz        :: proc(jointId: JointId) -> f32 ---

	// Get the spring damping ratio
	ParallelJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the maximum spring torque, usually in newton-meters
	ParallelJoint_SetMaxTorque          :: proc(jointId: JointId, force: f32) ---

	// Get the maximum spring torque, usually in newton-meters
	ParallelJoint_GetMaxTorque          :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup distance_joint Distance Joint
	 * @brief Functions for the distance joint.
	 */

	// Create a distance joint
	// @see DistanceJointDef for details
	CreateDistanceJoint                 :: proc(worldId: WorldId, #by_ptr def: DistanceJointDef) -> JointId ---

	// Set the rest length of a distance joint
	DistanceJoint_SetLength             :: proc(jointId: JointId, length: f32) ---

	// Get the rest length of a distance joint
	DistanceJoint_GetLength             :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the distance joint spring. When disabled the distance joint is rigid.
	DistanceJoint_EnableSpring          :: proc(jointId: JointId, enableSpring: bool) ---

	// Is the distance joint spring enabled?
	DistanceJoint_IsSpringEnabled       :: proc(jointId: JointId) -> bool ---

	// Set the force range for the spring.
	DistanceJoint_SetSpringForceRange   :: proc(jointId: JointId, lowerForce: f32, upperForce: f32) ---

	// Get the force range for the spring.
	DistanceJoint_GetSpringForceRange   :: proc(jointId: JointId, lowerForce: ^f32, upperForce: ^f32) ---

	// Set the spring stiffness in Hertz
	DistanceJoint_SetSpringHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Set the spring damping ratio, non-dimensional
	DistanceJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the spring Hertz
	DistanceJoint_GetSpringHertz        :: proc(jointId: JointId) -> f32 ---

	// Get the spring damping ratio
	DistanceJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Enable joint limit. The limit only works if the joint spring is enabled.
	DistanceJoint_EnableLimit           :: proc(jointId: JointId, enableLimit: bool) ---

	// Is the distance joint limit enabled?
	DistanceJoint_IsLimitEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the minimum and maximum length parameters of a distance joint
	DistanceJoint_SetLengthRange        :: proc(jointId: JointId, minLength: f32, maxLength: f32) ---

	// Get the distance joint minimum length
	DistanceJoint_GetMinLength          :: proc(jointId: JointId) -> f32 ---

	// Get the distance joint maximum length
	DistanceJoint_GetMaxLength          :: proc(jointId: JointId) -> f32 ---

	// Get the current length of a distance joint
	DistanceJoint_GetCurrentLength      :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the distance joint motor
	DistanceJoint_EnableMotor           :: proc(jointId: JointId, enableMotor: bool) ---

	// Is the distance joint motor enabled?
	DistanceJoint_IsMotorEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the distance joint motor speed, usually in meters per second
	DistanceJoint_SetMotorSpeed         :: proc(jointId: JointId, motorSpeed: f32) ---

	// Get the distance joint motor speed, usually in meters per second
	DistanceJoint_GetMotorSpeed         :: proc(jointId: JointId) -> f32 ---

	// Set the distance joint maximum motor force, usually in newtons
	DistanceJoint_SetMaxMotorForce      :: proc(jointId: JointId, force: f32) ---

	// Get the distance joint maximum motor force, usually in newtons
	DistanceJoint_GetMaxMotorForce      :: proc(jointId: JointId) -> f32 ---

	// Get the distance joint current motor force, usually in newtons
	DistanceJoint_GetMotorForce         :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup motor_joint Motor Joint
	 * @brief Functions for the motor joint.
	 */

	// Create a motor joint
	// @see MotorJointDef for details
	CreateMotorJoint                 :: proc(worldId: WorldId, #by_ptr def: MotorJointDef) -> JointId ---

	// Set the desired relative linear velocity in meters per second
	MotorJoint_SetLinearVelocity     :: proc(jointId: JointId, velocity: Vec3) ---

	// Get the desired relative linear velocity in meters per second
	MotorJoint_GetLinearVelocity     :: proc(jointId: JointId) -> Vec3 ---

	// Set the desired relative angular velocity in radians per second
	MotorJoint_SetAngularVelocity    :: proc(jointId: JointId, velocity: Vec3) ---

	// Get the desired relative angular velocity in radians per second
	MotorJoint_GetAngularVelocity    :: proc(jointId: JointId) -> Vec3 ---

	// Set the motor joint maximum force, usually in newtons
	MotorJoint_SetMaxVelocityForce   :: proc(jointId: JointId, maxForce: f32) ---

	// Get the motor joint maximum force, usually in newtons
	MotorJoint_GetMaxVelocityForce   :: proc(jointId: JointId) -> f32 ---

	// Set the motor joint maximum torque, usually in newton-meters
	MotorJoint_SetMaxVelocityTorque  :: proc(jointId: JointId, maxTorque: f32) ---

	// Get the motor joint maximum torque, usually in newton-meters
	MotorJoint_GetMaxVelocityTorque  :: proc(jointId: JointId) -> f32 ---

	// Set the spring linear hertz stiffness
	MotorJoint_SetLinearHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Get the spring linear hertz stiffness
	MotorJoint_GetLinearHertz        :: proc(jointId: JointId) -> f32 ---

	// Set the spring linear damping ratio. Use 1.0 for critical damping.
	MotorJoint_SetLinearDampingRatio :: proc(jointId: JointId, damping: f32) ---

	// Get the spring linear damping ratio.
	MotorJoint_GetLinearDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the spring angular hertz stiffness
	MotorJoint_SetAngularHertz       :: proc(jointId: JointId, hertz: f32) ---

	// Get the spring angular hertz stiffness
	MotorJoint_GetAngularHertz       :: proc(jointId: JointId) -> f32 ---

	// Set the spring angular damping ratio. Use 1.0 for critical damping.
	MotorJoint_SetAngularDampingRatio :: proc(jointId: JointId, damping: f32) ---

	// Get the spring angular damping ratio.
	MotorJoint_GetAngularDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the maximum spring force in newtons.
	MotorJoint_SetMaxSpringForce     :: proc(jointId: JointId, maxForce: f32) ---

	// Get the maximum spring force in newtons.
	MotorJoint_GetMaxSpringForce     :: proc(jointId: JointId) -> f32 ---

	// Set the maximum spring torque in newtons * meters
	MotorJoint_SetMaxSpringTorque    :: proc(jointId: JointId, maxTorque: f32) ---

	// Get the maximum spring torque in newtons * meters
	MotorJoint_GetMaxSpringTorque    :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup filter_joint Filter Joint
	 * @brief The filter joint is used to disable collision between two bodies.
	 */

	// Create a filter joint.
	// @see FilterJointDef for details
	CreateFilterJoint :: proc(worldId: WorldId, #by_ptr def: FilterJointDef) -> JointId ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup prismatic_joint Prismatic Joint
	 * @brief A prismatic joint allows for translation along a single axis with no rotation.
	 */

	// Create a prismatic (slider) joint.
	// @see PrismaticJointDef for details
	CreatePrismaticJoint                 :: proc(worldId: WorldId, #by_ptr def: PrismaticJointDef) -> JointId ---

	// Enable/disable the joint spring.
	PrismaticJoint_EnableSpring          :: proc(jointId: JointId, enableSpring: bool) ---

	// Is the prismatic joint spring enabled or not?
	PrismaticJoint_IsSpringEnabled       :: proc(jointId: JointId) -> bool ---

	// Set the prismatic joint stiffness in Hertz.
	PrismaticJoint_SetSpringHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Get the prismatic joint stiffness in Hertz
	PrismaticJoint_GetSpringHertz        :: proc(jointId: JointId) -> f32 ---

	// Set the prismatic joint damping ratio (non-dimensional)
	PrismaticJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the prismatic spring damping ratio (non-dimensional)
	PrismaticJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the prismatic joint target translation. Usually in meters.
	PrismaticJoint_SetTargetTranslation  :: proc(jointId: JointId, targetTranslation: f32) ---

	// Get the prismatic joint target translation. Usually in meters.
	PrismaticJoint_GetTargetTranslation  :: proc(jointId: JointId) -> f32 ---

	// Enable/disable a prismatic joint limit
	PrismaticJoint_EnableLimit           :: proc(jointId: JointId, enableLimit: bool) ---

	// Is the prismatic joint limit enabled?
	PrismaticJoint_IsLimitEnabled        :: proc(jointId: JointId) -> bool ---

	// Get the prismatic joint lower limit
	PrismaticJoint_GetLowerLimit         :: proc(jointId: JointId) -> f32 ---

	// Get the prismatic joint upper limit
	PrismaticJoint_GetUpperLimit         :: proc(jointId: JointId) -> f32 ---

	// Set the prismatic joint limits
	PrismaticJoint_SetLimits             :: proc(jointId: JointId, lower: f32, upper: f32) ---

	// Enable/disable a prismatic joint motor
	PrismaticJoint_EnableMotor           :: proc(jointId: JointId, enableMotor: bool) ---

	// Is the prismatic joint motor enabled?
	PrismaticJoint_IsMotorEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the prismatic joint motor speed, usually in meters per second
	PrismaticJoint_SetMotorSpeed         :: proc(jointId: JointId, motorSpeed: f32) ---

	// Get the prismatic joint motor speed, usually in meters per second
	PrismaticJoint_GetMotorSpeed         :: proc(jointId: JointId) -> f32 ---

	// Set the prismatic joint maximum motor force, usually in newtons
	PrismaticJoint_SetMaxMotorForce      :: proc(jointId: JointId, force: f32) ---

	// Get the prismatic joint maximum motor force, usually in newtons
	PrismaticJoint_GetMaxMotorForce      :: proc(jointId: JointId) -> f32 ---

	// Get the prismatic joint current motor force, usually in newtons
	PrismaticJoint_GetMotorForce         :: proc(jointId: JointId) -> f32 ---

	// Get the current joint translation, usually in meters.
	PrismaticJoint_GetTranslation        :: proc(jointId: JointId) -> f32 ---

	// Get the current joint translation speed, usually in meters per second.
	PrismaticJoint_GetSpeed              :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup revolute_joint Revolute Joint
	 * @brief A revolute joint allows for relative rotation about a single axis with no relative translation.
	 */

	// Create a revolute joint
	// @see RevoluteJointDef for details
	CreateRevoluteJoint                 :: proc(worldId: WorldId, #by_ptr def: RevoluteJointDef) -> JointId ---

	// Enable/disable the revolute joint spring
	RevoluteJoint_EnableSpring          :: proc(jointId: JointId, enableSpring: bool) ---

	// Is the revolute angular spring enabled?
	RevoluteJoint_IsSpringEnabled       :: proc(jointId: JointId) -> bool ---

	// Set the revolute joint spring stiffness in Hertz
	RevoluteJoint_SetSpringHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Get the revolute joint spring stiffness in Hertz
	RevoluteJoint_GetSpringHertz        :: proc(jointId: JointId) -> f32 ---

	// Set the revolute joint spring damping ratio, non-dimensional
	RevoluteJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the revolute joint spring damping ratio, non-dimensional
	RevoluteJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the revolute joint target angle in radians
	RevoluteJoint_SetTargetAngle        :: proc(jointId: JointId, targetRadians: f32) ---

	// Get the revolute joint target angle in radians
	RevoluteJoint_GetTargetAngle        :: proc(jointId: JointId) -> f32 ---

	// Get the revolute joint current angle in radians relative to the reference angle
	RevoluteJoint_GetAngle              :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the revolute joint limit
	RevoluteJoint_EnableLimit           :: proc(jointId: JointId, enableLimit: bool) ---

	// Is the revolute joint limit enabled?
	RevoluteJoint_IsLimitEnabled        :: proc(jointId: JointId) -> bool ---

	// Get the revolute joint lower limit in radians
	RevoluteJoint_GetLowerLimit         :: proc(jointId: JointId) -> f32 ---

	// Get the revolute joint upper limit in radians
	RevoluteJoint_GetUpperLimit         :: proc(jointId: JointId) -> f32 ---

	// Set the revolute joint limits in radians
	RevoluteJoint_SetLimits             :: proc(jointId: JointId, lowerLimitRadians: f32, upperLimitRadians: f32) ---

	// Enable/disable a revolute joint motor
	RevoluteJoint_EnableMotor           :: proc(jointId: JointId, enableMotor: bool) ---

	// Is the revolute joint motor enabled?
	RevoluteJoint_IsMotorEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the revolute joint motor speed in radians per second
	RevoluteJoint_SetMotorSpeed         :: proc(jointId: JointId, motorSpeed: f32) ---

	// Get the revolute joint motor speed in radians per second
	RevoluteJoint_GetMotorSpeed         :: proc(jointId: JointId) -> f32 ---

	// Get the revolute joint current motor torque, usually in newton-meters
	RevoluteJoint_GetMotorTorque        :: proc(jointId: JointId) -> f32 ---

	// Set the revolute joint maximum motor torque, usually in newton-meters
	RevoluteJoint_SetMaxMotorTorque     :: proc(jointId: JointId, torque: f32) ---

	// Get the revolute joint maximum motor torque, usually in newton-meters
	RevoluteJoint_GetMaxMotorTorque     :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup spherical_joint Spherical Joint
	 * @brief A spherical joint allows for relative rotation in 3D space with no relative translation.
	 */

	// Create a spherical joint
	// @see SphericalJointDef for details
	CreateSphericalJoint                 :: proc(worldId: WorldId, #by_ptr def: SphericalJointDef) -> JointId ---

	// Enable/disable the spherical joint cone limit
	SphericalJoint_EnableConeLimit       :: proc(jointId: JointId, enableLimit: bool) ---

	// Is the spherical joint cone limit enabled?
	SphericalJoint_IsConeLimitEnabled    :: proc(jointId: JointId) -> bool ---

	// Get the spherical joint cone limit in radians
	SphericalJoint_GetConeLimit          :: proc(jointId: JointId) -> f32 ---

	// Set the spherical joint cone limit in radians
	SphericalJoint_SetConeLimit          :: proc(jointId: JointId, angleRadians: f32) ---

	// Get the spherical joint current cone angle in radians.
	SphericalJoint_GetConeAngle          :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the spherical joint twist limit
	SphericalJoint_EnableTwistLimit      :: proc(jointId: JointId, enableLimit: bool) ---

	// Is the spherical joint twist limit enabled?
	SphericalJoint_IsTwistLimitEnabled   :: proc(jointId: JointId) -> bool ---

	// Get the spherical joint lower twist limit in radians
	SphericalJoint_GetLowerTwistLimit    :: proc(jointId: JointId) -> f32 ---

	// Get the spherical joint upper twist limit in radians
	SphericalJoint_GetUpperTwistLimit    :: proc(jointId: JointId) -> f32 ---

	// Set the spherical joint twist limits in radians
	SphericalJoint_SetTwistLimits        :: proc(jointId: JointId, lowerLimitRadians: f32, upperLimitRadians: f32) ---

	// Get the spherical joint current twist angle in radians.
	SphericalJoint_GetTwistAngle         :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the spherical joint spring
	SphericalJoint_EnableSpring          :: proc(jointId: JointId, enableSpring: bool) ---

	// Is the spherical angular spring enabled?
	SphericalJoint_IsSpringEnabled       :: proc(jointId: JointId) -> bool ---

	// Set the spherical joint spring stiffness in Hertz
	SphericalJoint_SetSpringHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Get the spherical joint spring stiffness in Hertz
	SphericalJoint_GetSpringHertz        :: proc(jointId: JointId) -> f32 ---

	// Set the spherical joint spring damping ratio, non-dimensional
	SphericalJoint_SetSpringDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the spherical joint spring damping ratio, non-dimensional
	SphericalJoint_GetSpringDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Set the spherical joint spring target rotation
	SphericalJoint_SetTargetRotation     :: proc(jointId: JointId, targetRotation: Quat) ---

	// Get the spherical joint spring target rotation
	SphericalJoint_GetTargetRotation     :: proc(jointId: JointId) -> Quat ---

	// Enable/disable a spherical joint motor
	SphericalJoint_EnableMotor           :: proc(jointId: JointId, enableMotor: bool) ---

	// Is the spherical joint motor enabled?
	SphericalJoint_IsMotorEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the spherical joint motor velocity in radians per second
	SphericalJoint_SetMotorVelocity      :: proc(jointId: JointId, motorVelocity: Vec3) ---

	// Get the spherical joint motor velocity in radians per second
	SphericalJoint_GetMotorVelocity      :: proc(jointId: JointId) -> Vec3 ---

	// Get the spherical joint current motor torque, usually in newton-meters
	SphericalJoint_GetMotorTorque        :: proc(jointId: JointId) -> Vec3 ---

	// Set the spherical joint maximum motor torque, usually in newton-meters
	SphericalJoint_SetMaxMotorTorque     :: proc(jointId: JointId, torque: f32) ---

	// Get the spherical joint maximum motor torque, usually in newton-meters
	SphericalJoint_GetMaxMotorTorque     :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup weld_joint Weld Joint
	 * @brief A weld joint fully constrains the relative transform between two bodies while allowing for springiness.
	 */

	// Create a weld joint
	// @see WeldJointDef for details
	CreateWeldJoint                  :: proc(worldId: WorldId, #by_ptr def: WeldJointDef) -> JointId ---

	// Set the weld joint linear stiffness in Hertz. 0 is rigid.
	WeldJoint_SetLinearHertz         :: proc(jointId: JointId, hertz: f32) ---

	// Get the weld joint linear stiffness in Hertz
	WeldJoint_GetLinearHertz         :: proc(jointId: JointId) -> f32 ---

	// Set the weld joint linear damping ratio (non-dimensional)
	WeldJoint_SetLinearDampingRatio  :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the weld joint linear damping ratio (non-dimensional)
	WeldJoint_GetLinearDampingRatio  :: proc(jointId: JointId) -> f32 ---

	// Set the weld joint angular stiffness in Hertz. 0 is rigid.
	WeldJoint_SetAngularHertz        :: proc(jointId: JointId, hertz: f32) ---

	// Get the weld joint angular stiffness in Hertz
	WeldJoint_GetAngularHertz        :: proc(jointId: JointId) -> f32 ---

	// Set weld joint angular damping ratio, non-dimensional
	WeldJoint_SetAngularDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the weld joint angular damping ratio, non-dimensional
	WeldJoint_GetAngularDampingRatio :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup wheel_joint Wheel Joint
	 * The wheel joint can be used to simulate wheels on vehicles.
	 */

	// Create a wheel joint.
	// @see WheelJointDef for details.
	CreateWheelJoint                    :: proc(worldId: WorldId, #by_ptr def: WheelJointDef) -> JointId ---

	// Enable/disable the wheel joint spring.
	WheelJoint_EnableSuspension         :: proc(jointId: JointId, flag: bool) ---

	// Is the wheel joint spring enabled?
	WheelJoint_IsSuspensionEnabled      :: proc(jointId: JointId) -> bool ---

	// Set the wheel joint stiffness in Hertz.
	WheelJoint_SetSuspensionHertz       :: proc(jointId: JointId, hertz: f32) ---

	// Get the wheel joint stiffness in Hertz.
	WheelJoint_GetSuspensionHertz       :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint damping ratio, non-dimensional.
	WheelJoint_SetSuspensionDampingRatio :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the wheel joint damping ratio, non-dimensional.
	WheelJoint_GetSuspensionDampingRatio :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the wheel joint limit.
	WheelJoint_EnableSuspensionLimit    :: proc(jointId: JointId, flag: bool) ---

	// Is the wheel joint limit enabled?
	WheelJoint_IsSuspensionLimitEnabled :: proc(jointId: JointId) -> bool ---

	// Get the wheel joint lower limit.
	WheelJoint_GetLowerSuspensionLimit  :: proc(jointId: JointId) -> f32 ---

	// Get the wheel joint upper limit.
	WheelJoint_GetUpperSuspensionLimit  :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint limits.
	WheelJoint_SetSuspensionLimits      :: proc(jointId: JointId, lower: f32, upper: f32) ---

	// Enable/disable the wheel joint motor.
	WheelJoint_EnableSpinMotor          :: proc(jointId: JointId, flag: bool) ---

	// Is the wheel joint motor enabled?
	WheelJoint_IsSpinMotorEnabled       :: proc(jointId: JointId) -> bool ---

	// Set the wheel joint motor speed in radians per second.
	WheelJoint_SetSpinMotorSpeed        :: proc(jointId: JointId, speed: f32) ---

	// Get the wheel joint motor speed in radians per second.
	WheelJoint_GetSpinMotorSpeed        :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint maximum motor torque, usually in newton-meters.
	WheelJoint_SetMaxSpinTorque         :: proc(jointId: JointId, torque: f32) ---

	// Get the wheel joint maximum motor torque, usually in newton-meters.
	WheelJoint_GetMaxSpinTorque         :: proc(jointId: JointId) -> f32 ---

	// Get the current spin speed in radians per second.
	WheelJoint_GetSpinSpeed             :: proc(jointId: JointId) -> f32 ---

	// Get the wheel joint current motor torque, usually in newton-meters.
	WheelJoint_GetSpinTorque            :: proc(jointId: JointId) -> f32 ---

	// Enable/disable wheel steering. Steering allows the wheel to rotate about the suspension axis.
	WheelJoint_EnableSteering           :: proc(jointId: JointId, flag: bool) ---

	// Can the wheel steer?
	WheelJoint_IsSteeringEnabled        :: proc(jointId: JointId) -> bool ---

	// Set the wheel joint steering stiffness in Hertz.
	WheelJoint_SetSteeringHertz         :: proc(jointId: JointId, hertz: f32) ---

	// Get the wheel joint steering stiffness in Hertz.
	WheelJoint_GetSteeringHertz         :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint steering damping ratio, non-dimensional.
	WheelJoint_SetSteeringDampingRatio  :: proc(jointId: JointId, dampingRatio: f32) ---

	// Get the wheel joint steering damping ratio, non-dimensional.
	WheelJoint_GetSteeringDampingRatio  :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint maximum steering torque in N*m.
	WheelJoint_SetMaxSteeringTorque     :: proc(jointId: JointId, torque: f32) ---

	// Get the wheel joint maximum steering torque in N*m.
	WheelJoint_GetMaxSteeringTorque     :: proc(jointId: JointId) -> f32 ---

	// Enable/disable the wheel joint steering limit.
	WheelJoint_EnableSteeringLimit      :: proc(jointId: JointId, flag: bool) ---

	// Is the wheel joint steering limit enabled?
	WheelJoint_IsSteeringLimitEnabled   :: proc(jointId: JointId) -> bool ---

	// Get the wheel joint lower steering limit in radians.
	WheelJoint_GetLowerSteeringLimit    :: proc(jointId: JointId) -> f32 ---

	// Get the wheel joint upper steering limit in radians.
	WheelJoint_GetUpperSteeringLimit    :: proc(jointId: JointId) -> f32 ---

	// Set the wheel joint steering limits in radians.
	WheelJoint_SetSteeringLimits        :: proc(jointId: JointId, lowerRadians: f32, upperRadians: f32) ---

	// Set the wheel joint target steering angle in radians.
	WheelJoint_SetTargetSteeringAngle   :: proc(jointId: JointId, radians: f32) ---

	// Get the wheel joint target steering angle in radians.
	WheelJoint_GetTargetSteeringAngle   :: proc(jointId: JointId) -> f32 ---

	// Get the current steering angle in radians.
	WheelJoint_GetSteeringAngle         :: proc(jointId: JointId) -> f32 ---

	// Get the current steering torque in N*m.
	WheelJoint_GetSteeringTorque        :: proc(jointId: JointId) -> f32 ---
}


@(link_prefix="b3", default_calling_convention="c", require_results)
foreign lib {
	/**
	 * @defgroup contact Contact
	 * Access to contacts
	 */

	// Contact identifier validation. Provides validation for up to 2^32 allocations.
	Contact_IsValid :: proc(id: ContactId) -> bool ---

	// Get the manifolds for a contact. The manifold may have no points if the contact is not touching.
	Contact_GetData :: proc(contactId: ContactId) -> ContactData ---
}
