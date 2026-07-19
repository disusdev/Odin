package vendor_box3d

import "core:c"
import "core:math"

foreign import lib {
	LIB_PATH,
}

// https://en.wikipedia.org/wiki/Pi
PI :: math.PI

// Convenience macro to convert from degrees to radians.
DEG_TO_RAD :: 0.01745329251

// Convenience macro to convert from radians to degrees.
RAD_TO_DEG :: 57.2957795131

// Minimum scale used for scaling collision meshes, etc.
MIN_SCALE :: 0.01

EPSILON :: math.F32_EPSILON

// A 2D vector.
Vec2 :: [2]f32

// A 3D vector.
Vec3 :: [3]f32

// Cosine and sine pair.
// This uses a custom implementation designed for cross-platform determinism.
CosSin :: struct {
	// cosine and sine
	cosine: f32,
	sine:   f32,
}

// A quaternion.
Quat :: struct {
	v: Vec3,
	s: f32,
}

// A rigid transform.
Transform :: struct {
	p: Vec3,
	q: Quat,
}

// In single precision mode these types are the same. In large world mode (BOX3D_DOUBLE_PRECISION)
// the C library uses double precision translation; these bindings target the single precision build.
Pos :: Vec3

// In single precision mode these types are the same.
WorldTransform :: Transform

// A 3x3 matrix.
Matrix3 :: struct {
	cx, cy, cz: Vec3,
}

// Axis aligned bounding box.
AABB :: struct {
	lowerBound: Vec3,
	upperBound: Vec3,
}

// A plane.
// separation = dot(normal, point) - offset
Plane :: struct {
	normal: Vec3,
	offset: f32,
}

Vec3_zero  :: Vec3{0, 0, 0}
Vec3_one   :: Vec3{1, 1, 1}
Vec3_axisX :: Vec3{1, 0, 0}
Vec3_axisY :: Vec3{0, 1, 0}
Vec3_axisZ :: Vec3{0, 0, 1}

Quat_identity      :: Quat{{0, 0, 0}, 1}
Transform_identity :: Transform{{0, 0, 0}, {{0, 0, 0}, 1}}

Mat3_zero :: Matrix3{
	{0, 0, 0},
	{0, 0, 0},
	{0, 0, 0},
}
Mat3_identity :: Matrix3{
	{1, 0, 0},
	{0, 1, 0},
	{0, 0, 1},
}

Pos_zero                :: Pos{0, 0, 0}
WorldTransform_identity :: WorldTransform{{0, 0, 0}, {{0, 0, 0}, 1}}

// @return the minimum of two integers.
@(deprecated="Prefer the built-in 'min(a, b)'", require_results)
MinInt :: proc "c" (a, b: c.int) -> c.int {
	return min(a, b)
}

// @return the maximum of two integers.
@(deprecated="Prefer the built-in 'max(a, b)'", require_results)
MaxInt :: proc "c" (a, b: c.int) -> c.int {
	return max(a, b)
}

// @return an integer clamped between a lower and upper bound.
@(deprecated="Prefer the built-in 'clamp(a, lower, upper)'", require_results)
ClampInt :: proc "c" (a, lower, upper: c.int) -> c.int {
	return clamp(a, lower, upper)
}

// @return the absolute value of a float.
@(deprecated="Prefer the built-in 'abs(a)'", require_results)
AbsFloat :: proc "c" (a: f32) -> f32 {
	return abs(a)
}

// @return the minimum of two floats.
@(deprecated="Prefer the built-in 'min(a, b)'", require_results)
MinFloat :: proc "c" (a, b: f32) -> f32 {
	return min(a, b)
}

// @return the maximum of two floats.
@(deprecated="Prefer the built-in 'max(a, b)'", require_results)
MaxFloat :: proc "c" (a, b: f32) -> f32 {
	return max(a, b)
}

// @return a float clamped between a lower and upper bound.
@(deprecated="Prefer the built-in 'clamp(a, lower, upper)'", require_results)
ClampFloat :: proc "c" (a, lower, upper: f32) -> f32 {
	return clamp(a, lower, upper)
}

// Interpolate a scalar.
@(require_results)
LerpFloat :: proc "c" (a, b, alpha: f32) -> f32 {
	return (1 - alpha) * a + alpha * b
}

// @deprecated
@(deprecated="Prefer 'ComputeCosSin(radians).sine'", require_results)
Sin :: proc "c" (radians: f32) -> f32 {
	cs := ComputeCosSin(radians)
	return cs.sine
}

// @deprecated
@(deprecated="Prefer 'ComputeCosSin(radians).cosine'", require_results)
Cos :: proc "c" (radians: f32) -> f32 {
	cs := ComputeCosSin(radians)
	return cs.cosine
}

// Convert any angle into the range [-pi, pi].
@(require_results)
UnwindAngle :: proc "c" (radians: f32) -> f32 {
	return math.remainder(radians, 2 * PI)
}

// Vector addition.
@(deprecated="Prefer 'a + b'", require_results)
Add :: proc "c" (a, b: Vec3) -> Vec3 {
	return a + b
}

// Vector subtraction.
@(deprecated="Prefer 'a - b'", require_results)
Sub :: proc "c" (a, b: Vec3) -> Vec3 {
	return a - b
}

// Vector component-wise multiplication.
@(deprecated="Prefer 'a * b'", require_results)
Mul :: proc "c" (a, b: Vec3) -> Vec3 {
	return a * b
}

// Vector negation.
@(deprecated="Prefer '-a'", require_results)
Neg :: proc "c" (a: Vec3) -> Vec3 {
	return -a
}

// Vector dot product.
@(require_results)
Dot :: proc "c" (a, b: Vec3) -> f32 {
	return a.x * b.x + a.y * b.y + a.z * b.z
}

// Vector length.
@(require_results)
Length :: proc "c" (v: Vec3) -> f32 {
	return math.sqrt(Dot(v, v))
}

// Vector length squared.
@(require_results)
LengthSquared :: proc "c" (a: Vec3) -> f32 {
	return a.x * a.x + a.y * a.y + a.z * a.z
}

// Distance between two points.
@(require_results)
Distance :: proc "c" (a, b: Vec3) -> f32 {
	dv := b - a
	return Length(dv)
}

// Squared distance between two points.
@(require_results)
DistanceSquared :: proc "c" (a, b: Vec3) -> f32 {
	dv := b - a
	return dv.x * dv.x + dv.y * dv.y + dv.z * dv.z
}

// Normalize a vector. Returns a zero vector if the input vector is very small.
@(require_results)
Normalize :: proc "c" (a: Vec3) -> Vec3 {
	lengthSquared := a.x * a.x + a.y * a.y + a.z * a.z
	if lengthSquared > 1000 * math.F32_MIN {
		s := 1 / math.sqrt(lengthSquared)
		return s * a
	}
	return Vec3{0, 0, 0}
}

// Normalize a vector and return the length. Returns a zero vector
// if the input is very small.
@(require_results)
GetLengthAndNormalize :: proc "c" (a: Vec3) -> (length: f32, n: Vec3) {
	length = Length(a)
	if length < EPSILON {
		return
	}
	invLength := 1 / length
	n = invLength * a
	return
}

// Get a unit vector that is perpendicular to the supplied vector.
@(require_results)
Perp :: proc "c" (a: Vec3) -> Vec3 {
	// Suppose vector a has all equal components and is a unit vector: a = (s, s, s)
	// Then 3*s*s = 1, s = sqrt(1/3) = 0.57735. This means that at least one component
	// of a unit vector must be greater or equal to 0.57735.
	p: Vec3
	if a.x < -0.5 || 0.5 < a.x {
		p = Vec3{a.y, -a.x, 0}
	} else {
		p = Vec3{0, a.z, -a.y}
	}
	return Normalize(p)
}

// Is a vector normalized? In other words, does it have unit length?
@(require_results)
IsNormalized :: proc "c" (a: Vec3) -> bool {
	aa := Dot(a, a)
	return abs(1 - aa) < 100 * EPSILON
}

// a + s * b
@(deprecated="Prefer 'a + s * b'", require_results)
MulAdd :: proc "c" (a: Vec3, s: f32, b: Vec3) -> Vec3 {
	return a + s * b
}

// a - s * b
@(deprecated="Prefer 'a - s * b'", require_results)
MulSub :: proc "c" (a: Vec3, s: f32, b: Vec3) -> Vec3 {
	return a - s * b
}

// s * a
@(deprecated="Prefer 's * a'", require_results)
MulSV :: proc "c" (s: f32, a: Vec3) -> Vec3 {
	return s * a
}

// https://en.wikipedia.org/wiki/Cross_product
@(require_results)
Cross :: proc "c" (a, b: Vec3) -> Vec3 {
	return Vec3{
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x,
	}
}

// Linearly interpolate between two vectors.
@(require_results)
Lerp :: proc "c" (a, b: Vec3, alpha: f32) -> Vec3 {
	return Vec3{
		(1 - alpha) * a.x + alpha * b.x,
		(1 - alpha) * a.y + alpha * b.y,
		(1 - alpha) * a.z + alpha * b.z,
	}
}

// Blend two vectors: s * a + t * b
@(require_results)
Blend2 :: proc "c" (s: f32, a: Vec3, t: f32, b: Vec3) -> Vec3 {
	return Vec3{
		s * a.x + t * b.x,
		s * a.y + t * b.y,
		s * a.z + t * b.z,
	}
}

// Component-wise absolute value.
@(require_results)
Abs :: proc "c" (a: Vec3) -> Vec3 {
	return Vec3{abs(a.x), abs(a.y), abs(a.z)}
}

// Component-wise -1 or 1 (1 if zero).
@(require_results)
Sign :: proc "c" (a: Vec3) -> Vec3 {
	return Vec3{
		a.x >= 0 ? 1 : -1,
		a.y >= 0 ? 1 : -1,
		a.z >= 0 ? 1 : -1,
	}
}

// Component-wise minimum value.
@(require_results)
Min :: proc "c" (a, b: Vec3) -> Vec3 {
	return Vec3{min(a.x, b.x), min(a.y, b.y), min(a.z, b.z)}
}

// Component-wise maximum value.
@(require_results)
Max :: proc "c" (a, b: Vec3) -> Vec3 {
	return Vec3{max(a.x, b.x), max(a.y, b.y), max(a.z, b.z)}
}

// Component-wise clamped value.
@(require_results)
Clamp :: proc "c" (a, lower, upper: Vec3) -> Vec3 {
	return Vec3{
		clamp(a.x, lower.x, upper.x),
		clamp(a.y, lower.y, upper.y),
		clamp(a.z, lower.z, upper.z),
	}
}

// Create a safe scaling value for scaling collision. This allows
// negative scale, but keeps scale sufficiently far from zero.
@(require_results)
SafeScale :: proc "c" (a: Vec3) -> Vec3 {
	absScale := Abs(a)
	minScale := Vec3{MIN_SCALE, MIN_SCALE, MIN_SCALE}
	return Sign(a) * Max(absScale, minScale)
}

// Does the supplied quaternion have unit length?
@(require_results)
IsNormalizedQuat :: proc "c" (q: Quat) -> bool {
	qq := q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z + q.s * q.s
	return 1 - 20 * EPSILON < qq && qq < 1 + 20 * EPSILON
}

// Rotate a vector.
@(require_results)
RotateVector :: proc "c" (q: Quat, v: Vec3) -> Vec3 {
	// v + 2 * cross(q.v, cross(q.v, v) + q.s * v)
	t1 := Cross(q.v, v)
	t2 := t1 + q.s * v
	t3 := Cross(q.v, t2)
	return v + 2 * t3
}

// Inverse rotate a vector.
@(require_results)
InvRotateVector :: proc "c" (q: Quat, v: Vec3) -> Vec3 {
	// v + 2 * cross(q.v, cross(q.v, v) - q.s * v)
	t1 := Cross(q.v, v)
	t2 := t1 - q.s * v
	t3 := Cross(q.v, t2)
	return v + 2 * t3
}

// Compute dot product of two quaternions. Useful for polarity tests.
@(require_results)
DotQuat :: proc "c" (a, b: Quat) -> f32 {
	return a.v.x * b.v.x + a.v.y * b.v.y + a.v.z * b.v.z + a.s * b.s
}

// Multiply two quaternions.
@(require_results)
MulQuat :: proc "c" (q1, q2: Quat) -> Quat {
	t1 := Cross(q1.v, q2.v)
	t2 := t1 + q1.s * q2.v
	t3 := t2 + q2.s * q1.v
	return Quat{t3, q1.s * q2.s - Dot(q1.v, q2.v)}
}

// Compute a relative quaternion.
// inv(q1) * q2
@(require_results)
InvMulQuat :: proc "c" (q1, q2: Quat) -> Quat {
	t1 := Cross(q2.v, q1.v)
	t2 := t1 + q1.s * q2.v
	t3 := t2 - q2.s * q1.v
	return Quat{t3, q1.s * q2.s + Dot(q1.v, q2.v)}
}

// Quaternion conjugate (cheap inverse).
@(require_results)
Conjugate :: proc "c" (q: Quat) -> Quat {
	return Quat{-q.v, q.s}
}

// Component-wise quaternion negation.
@(require_results)
NegateQuat :: proc "c" (q: Quat) -> Quat {
	return Quat{-q.v, -q.s}
}

// Normalize a quaternion.
@(require_results)
NormalizeQuat :: proc "c" (q: Quat) -> Quat {
	lengthSq := DotQuat(q, q)
	if lengthSq > 1000 * math.F32_MIN {
		s := 1 / math.sqrt(lengthSq)
		return Quat{s * q.v, s * q.s}
	}
	return Quat_identity
}

// Make a quaternion that is equivalent to rotating around an axis by a specified angle.
@(require_results)
MakeQuatFromAxisAngle :: proc "c" (axis: Vec3, radians: f32) -> Quat {
	cs := ComputeCosSin(0.5 * radians)
	return Quat{cs.sine * axis, cs.cosine}
}

// Get the axis and angle from a quaternion. Assumes the quaternion is normalized.
@(require_results)
GetAxisAngle :: proc "c" (q: Quat) -> (radians: f32, axis: Vec3) {
	length := math.sqrt(q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z)
	radians = 2 * Atan2(length, q.s)
	if length > 0 {
		invLength := 1 / length
		axis = invLength * q.v
	}
	return
}

// Get the angle for a quaternion in radians.
@(require_results)
GetQuatAngle :: proc "c" (q: Quat) -> f32 {
	length := math.sqrt(q.v.x * q.v.x + q.v.y * q.v.y + q.v.z * q.v.z)
	return 2 * Atan2(length, q.s)
}

// Twist angle around the z-axis, used for twist limit and revolute angle limit.
@(require_results)
GetTwistAngle :: proc "c" (q: Quat) -> f32 {
	// Account for polarity to keep the twist angle in range.
	// This is simpler than asking the user to check polarity or unwinding.
	twist := q.s < 0 ? Atan2(-q.v.z, -q.s) : Atan2(q.v.z, q.s)
	twist *= 2
	return twist
}

// Swing angle used for cone limit.
@(require_results)
GetSwingAngle :: proc "c" (q: Quat) -> f32 {
	// Polarity should not matter because all terms are squared.
	x := math.sqrt(q.v.z * q.v.z + q.s * q.s)
	y := math.sqrt(q.v.x * q.v.x + q.v.y * q.v.y)
	return 2 * Atan2(y, x)
}

// Linearly interpolate and normalize between two quaternions.
@(require_results)
NLerp :: proc "c" (q1, q2: Quat, alpha: f32) -> Quat {
	q1 := q1
	if DotQuat(q1, q2) < 0 {
		q1 = Quat{-q1.v, -q1.s}
	}

	q: Quat
	q.v = Lerp(q1.v, q2.v, alpha)
	q.s = (1 - alpha) * q1.s + alpha * q2.s

	return NormalizeQuat(q)
}

// Multiply two transforms. If the result is applied to a point p local to frame B,
// the transform would first convert p to a point local to frame A, then into a point
// in the world frame. This is useful if frame B is a child of frame A.
@(require_results)
MulTransforms :: proc "c" (a, b: Transform) -> (out: Transform) {
	out.p = RotateVector(a.q, b.p) + a.p
	out.q = MulQuat(a.q, b.q)
	return
}

// Creates a transform that converts a local point in frame B to a local point in frame A.
// This is useful for transforming points between the local spaces of two frames that are
// in world space.
@(require_results)
InvMulTransforms :: proc "c" (a, b: Transform) -> (out: Transform) {
	out.p = InvRotateVector(a.q, b.p - a.p)
	out.q = InvMulQuat(a.q, b.q)
	return
}

// Get the inverse of a transform.
@(require_results)
InvertTransform :: proc "c" (t: Transform) -> (out: Transform) {
	out.p = InvRotateVector(t.q, -t.p)
	out.q = Conjugate(t.q)
	return
}

// Transform a point.
@(require_results)
TransformPoint :: proc "c" (t: Transform, v: Vec3) -> Vec3 {
	return RotateVector(t.q, v) + t.p
}

// Inverse transform a point.
@(require_results)
InvTransformPoint :: proc "c" (t: Transform, v: Vec3) -> Vec3 {
	return InvRotateVector(t.q, v - t.p)
}

// World position boundary. These cross between the double precision world space at the public
// boundary and the float interior. In single precision mode the types collapse and the
// float casts become no-ops.

// Convert a vector to a world position.
@(require_results)
ToPos :: proc "c" (v: Vec3) -> Pos {
	return v
}

// Lossy conversion of a world position to a float vector.
@(require_results)
ToVec3 :: proc "c" (p: Pos) -> Vec3 {
	return p
}

// Narrow a world coordinate to float, rounding toward negative infinity. In single precision
// mode this is a plain conversion.
@(require_results)
RoundDownFloat :: proc "c" (x: f64) -> f32 {
	return f32(x)
}

// Narrow a world coordinate to float, rounding toward positive infinity.
@(require_results)
RoundUpFloat :: proc "c" (x: f64) -> f32 {
	return f32(x)
}

// a - b, demoted to float. The primary precision boundary operation.
@(require_results)
SubPos :: proc "c" (a, b: Pos) -> Vec3 {
	return a - b
}

// p + d
@(require_results)
OffsetPos :: proc "c" (p: Pos, d: Vec3) -> Pos {
	return p + d
}

// World position interpolation for sweeps and sampling.
@(require_results)
LerpPosition :: proc "c" (a, b: Pos, t: f32) -> Pos {
	return Pos{
		(1 - t) * a.x + t * b.x,
		(1 - t) * a.y + t * b.y,
		(1 - t) * a.z + t * b.z,
	}
}

// Transform a local point to a world position. Rotation in float, translation in double.
@(require_results)
TransformWorldPoint :: proc "c" (t: WorldTransform, p: Vec3) -> Pos {
	r := RotateVector(t.q, p)
	return t.p + r
}

// Transform a world position to a local point. One double subtraction, then float.
@(require_results)
InvTransformWorldPoint :: proc "c" (t: WorldTransform, p: Pos) -> Vec3 {
	d := p - t.p
	return InvRotateVector(t.q, d)
}

// Relative transform of frame B in frame A. The narrow phase boundary.
@(require_results)
InvMulWorldTransforms :: proc "c" (A, B: WorldTransform) -> (C: Transform) {
	C.q = InvMulQuat(A.q, B.q)
	d := B.p - A.p
	C.p = InvRotateVector(A.q, d)
	return
}

// Compose a world transform with a local transform.
@(require_results)
MulWorldTransforms :: proc "c" (A: WorldTransform, B: Transform) -> (C: WorldTransform) {
	C.q = MulQuat(A.q, B.q)
	r := RotateVector(A.q, B.p)
	C.p = A.p + r
	return
}

// Shift a world transform into the frame of a base position.
@(require_results)
ToRelativeTransform :: proc "c" (t: WorldTransform, base: Pos) -> (r: Transform) {
	r.q = t.q
	r.p = t.p - base
	return
}

// Promote a float transform to a world transform. Lossless.
@(require_results)
MakeWorldTransform :: proc "c" (t: Transform) -> (w: WorldTransform) {
	w.p = ToPos(t.p)
	w.q = t.q
	return
}

// Translate a local AABB by a world origin, rounding outward so the float box always contains
// the double box. In float mode the origin is float and the rounding is a no-op.
@(require_results)
OffsetAABB :: proc "c" (localBox: AABB, origin: Pos) -> (out: AABB) {
	out.lowerBound.x = RoundDownFloat(f64(origin.x) + f64(localBox.lowerBound.x))
	out.lowerBound.y = RoundDownFloat(f64(origin.y) + f64(localBox.lowerBound.y))
	out.lowerBound.z = RoundDownFloat(f64(origin.z) + f64(localBox.lowerBound.z))
	out.upperBound.x = RoundUpFloat(f64(origin.x) + f64(localBox.upperBound.x))
	out.upperBound.y = RoundUpFloat(f64(origin.y) + f64(localBox.upperBound.y))
	out.upperBound.z = RoundUpFloat(f64(origin.z) + f64(localBox.upperBound.z))
	return
}

// Compute the determinant of a 3-by-3 matrix.
@(require_results)
Det :: proc "c" (m: Matrix3) -> f32 {
	return Dot(m.cx, Cross(m.cy, m.cz))
}

// Multiply a matrix times a column vector.
@(require_results)
MulMV :: proc "c" (m: Matrix3, a: Vec3) -> Vec3 {
	return Vec3{
		m.cx.x * a.x + m.cy.x * a.y + m.cz.x * a.z,
		m.cx.y * a.x + m.cy.y * a.y + m.cz.y * a.z,
		m.cx.z * a.x + m.cy.z * a.y + m.cz.z * a.z,
	}
}

// Negate a matrix.
@(require_results)
NegateMat3 :: proc "c" (a: Matrix3) -> Matrix3 {
	return Matrix3{-a.cx, -a.cy, -a.cz}
}

// Matrix addition.
// @return a + b
@(require_results)
AddMM :: proc "c" (a, b: Matrix3) -> Matrix3 {
	return Matrix3{a.cx + b.cx, a.cy + b.cy, a.cz + b.cz}
}

// Matrix subtraction.
// @return a - b
@(require_results)
SubMM :: proc "c" (a, b: Matrix3) -> Matrix3 {
	return Matrix3{a.cx - b.cx, a.cy - b.cy, a.cz - b.cz}
}

// Multiply a matrix by a scalar, component-wise.
@(require_results)
MulSM :: proc "c" (s: f32, a: Matrix3) -> Matrix3 {
	return Matrix3{s * a.cx, s * a.cy, s * a.cz}
}

// Matrix multiplication.
// @return a * b
@(require_results)
MulMM :: proc "c" (a, b: Matrix3) -> (out: Matrix3) {
	out.cx = MulMV(a, b.cx)
	out.cy = MulMV(a, b.cy)
	out.cz = MulMV(a, b.cz)
	return
}

// Matrix transpose.
@(require_results)
Transpose :: proc "c" (m: Matrix3) -> (out: Matrix3) {
	out.cx = Vec3{m.cx.x, m.cy.x, m.cz.x}
	out.cy = Vec3{m.cx.y, m.cy.y, m.cz.y}
	out.cz = Vec3{m.cx.z, m.cy.z, m.cz.z}
	return
}

// General matrix inverse.
@(require_results)
InvertMatrix :: proc "c" (m: Matrix3) -> Matrix3 {
	det := Det(m)
	if abs(det) > 1000 * math.F32_MIN {
		invDet := 1 / det
		out: Matrix3
		out.cx = invDet * Cross(m.cy, m.cz)
		out.cy = invDet * Cross(m.cz, m.cx)
		out.cz = invDet * Cross(m.cx, m.cy)
		return Transpose(out)
	}
	return Mat3_zero
}

// Solve a matrix equation.
// @return inv(m) * a
@(require_results)
Solve3 :: proc "c" (m: Matrix3, a: Vec3) -> Vec3 {
	det := Det(m)
	if abs(det) > 1000 * math.F32_MIN {
		invDet := 1 / det
		s: Matrix3
		s.cx = Cross(m.cy, m.cz)
		s.cy = Cross(m.cz, m.cx)
		s.cz = Cross(m.cx, m.cy)
		return Vec3{
			invDet * Dot(s.cx, a),
			invDet * Dot(s.cy, a),
			invDet * Dot(s.cz, a),
		}
	}
	return Vec3_zero
}

// Invert a matrix.
@(require_results)
InvertT :: proc "c" (m: Matrix3) -> Matrix3 {
	det := Det(m)
	if abs(det) > 1000 * math.F32_MIN {
		invDet := 1 / det
		out: Matrix3
		out.cx = invDet * Cross(m.cy, m.cz)
		out.cy = invDet * Cross(m.cz, m.cx)
		out.cz = invDet * Cross(m.cx, m.cy)
		return out
	}
	return Mat3_zero
}

// Get the component-wise absolute value of a matrix.
@(require_results)
AbsMatrix3 :: proc "c" (m: Matrix3) -> (out: Matrix3) {
	out.cx = Abs(m.cx)
	out.cy = Abs(m.cy)
	out.cz = Abs(m.cz)
	return
}

// Make a matrix from a quaternion. This is useful if you need to
// rotate many vectors.
@(require_results)
MakeMatrixFromQuat :: proc "c" (q: Quat) -> Matrix3 {
	xx := q.v.x * q.v.x
	yy := q.v.y * q.v.y
	zz := q.v.z * q.v.z
	xy := q.v.x * q.v.y
	xz := q.v.x * q.v.z
	xw := q.v.x * q.s
	yz := q.v.y * q.v.z
	yw := q.v.y * q.s
	zw := q.v.z * q.s

	return Matrix3{
		{1 - 2 * (yy + zz), 2 * (xy + zw), 2 * (xz - yw)},
		{2 * (xy - zw), 1 - 2 * (xx + zz), 2 * (yz + xw)},
		{2 * (xz + yw), 2 * (yz - xw), 1 - 2 * (xx + yy)},
	}
}

// Get the AABB of a point cloud.
@(require_results)
MakeAABB :: proc "c" (points: []Vec3, radius: f32) -> AABB {
	a := AABB{points[0], points[0]}
	for point in points {
		a.lowerBound = Min(a.lowerBound, point)
		a.upperBound = Max(a.upperBound, point)
	}

	r := Vec3{radius, radius, radius}
	a.lowerBound = a.lowerBound - r
	a.upperBound = a.upperBound + r

	return a
}

// Does a fully contain b?
@(require_results)
AABB_Contains :: proc "c" (a, b: AABB) -> bool {
	(a.lowerBound.x <= b.lowerBound.x) or_return
	(a.lowerBound.y <= b.lowerBound.y) or_return
	(a.lowerBound.z <= b.lowerBound.z) or_return
	(b.upperBound.x <= a.upperBound.x) or_return
	(b.upperBound.y <= a.upperBound.y) or_return
	(b.upperBound.z <= a.upperBound.z) or_return
	return true
}

// Get the surface area of an axis-aligned bounding box.
@(require_results)
AABB_Area :: proc "c" (a: AABB) -> f32 {
	delta := a.upperBound - a.lowerBound
	return 2 * (delta.x * delta.y + delta.y * delta.z + delta.z * delta.x)
}

// Get the center of an axis-aligned bounding box.
@(require_results)
AABB_Center :: proc "c" (a: AABB) -> Vec3 {
	return 0.5 * (a.upperBound + a.lowerBound)
}

// Get the extents (half-widths) of an axis-aligned bounding box.
@(require_results)
AABB_Extents :: proc "c" (a: AABB) -> Vec3 {
	return 0.5 * (a.upperBound - a.lowerBound)
}

// Get the union of two axis-aligned bounding boxes.
@(require_results)
AABB_Union :: proc "c" (a, b: AABB) -> (out: AABB) {
	out.lowerBound = Min(a.lowerBound, b.lowerBound)
	out.upperBound = Max(a.upperBound, b.upperBound)
	return
}

// Add uniform padding to an axis-aligned bounding box.
@(require_results)
AABB_Inflate :: proc "c" (a: AABB, extension: f32) -> (out: AABB) {
	radius := Vec3{extension, extension, extension}
	out.lowerBound = a.lowerBound - radius
	out.upperBound = a.upperBound + radius
	return
}

// Do two axis-aligned boxes overlap?
@(require_results)
AABB_Overlaps :: proc "c" (a, b: AABB) -> bool {
	// No intersection if separated along one axis
	return !(
		a.upperBound.x < b.lowerBound.x || a.lowerBound.x > b.upperBound.x ||
		a.upperBound.y < b.lowerBound.y || a.lowerBound.y > b.upperBound.y ||
		a.upperBound.z < b.lowerBound.z || a.lowerBound.z > b.upperBound.z \
	)
}

// Transform an axis-aligned bounding box. This can create a larger box
// than if you recomputed the AABB of the original shape with the transform
// applied.
@(require_results)
AABB_Transform :: proc "c" (transform: Transform, a: AABB) -> AABB {
	center := TransformPoint(transform, AABB_Center(a))
	m := MakeMatrixFromQuat(transform.q)
	extent := MulMV(AbsMatrix3(m), AABB_Extents(a))
	return AABB{center - extent, center + extent}
}

// Get the closest point on an axis-aligned bounding box.
@(require_results)
ClosestPointToAABB :: proc "c" (point: Vec3, a: AABB) -> Vec3 {
	return Clamp(point, a.lowerBound, a.upperBound)
}

// The closest points between to segments or infinite lines.
SegmentDistanceResult :: struct {
	point1:    Vec3,
	fraction1: f32,
	point2:    Vec3,
	fraction2: f32,
}

@(link_prefix="b3", default_calling_convention="c")
foreign lib {
	// @return is this float valid (finite and not NaN).
	@(require_results)
	IsValidFloat :: proc(a: f32) -> bool ---

	// Compute an approximate arctangent in the range [-pi, pi].
	// This is hand coded for cross-platform determinism. The atan2f
	// function in the standard library is not cross-platform deterministic.
	// Accurate to around 0.0023 degrees.
	@(require_results)
	Atan2 :: proc(y, x: f32) -> f32 ---

	// Compute the cosine and sine of an angle in radians. Implemented
	// for cross-platform determinism.
	@(require_results)
	ComputeCosSin :: proc(radians: f32) -> CosSin ---

	// Extract a quaternion from a rotation matrix.
	@(require_results)
	MakeQuatFromMatrix :: proc(m: ^Matrix3) -> Quat ---

	// Find a quaternion that rotates one vector to another.
	@(require_results)
	ComputeQuatBetweenUnitVectors :: proc(v1, v2: Vec3) -> Quat ---

	// Get the inertia tensor of an offset point.
	// https://en.wikipedia.org/wiki/Parallel_axis_theorem
	@(require_results)
	Steiner :: proc(mass: f32, origin: Vec3) -> Matrix3 ---

	// Compute the closest point on the segment a-b to the target q.
	@(require_results)
	PointToSegmentDistance :: proc(a, b, q: Vec3) -> Vec3 ---

	// Compute the closest points on two infinite lines.
	@(require_results)
	LineDistance :: proc(p1, d1, p2, d2: Vec3) -> SegmentDistanceResult ---

	// Compute the closest points on two line segments.
	@(require_results)
	SegmentDistance :: proc(p1, q1, p2, q2: Vec3) -> SegmentDistanceResult ---

	// Is this a valid vector? Not NaN or infinity.
	@(require_results)
	IsValidVec3 :: proc(a: Vec3) -> bool ---

	// Is this a valid quaternion? Not NaN or infinity. Is normalized.
	@(require_results)
	IsValidQuat :: proc(q: Quat) -> bool ---

	// Is this a valid transform? Not NaN or infinity. Is normalized.
	@(require_results)
	IsValidTransform :: proc(a: Transform) -> bool ---

	// Is this a valid matrix? Not NaN or infinity.
	@(require_results)
	IsValidMatrix3 :: proc(a: Matrix3) -> bool ---

	// Is this a valid bounding box? Not Nan or infinity. Upper bound greater than or equal to lower bound.
	@(require_results)
	IsValidAABB :: proc(a: AABB) -> bool ---

	// Is this AABB reasonably close to the origin? See B3_HUGE.
	@(require_results)
	IsBoundedAABB :: proc(a: AABB) -> bool ---

	// Is this AABB valid and reasonable?
	@(require_results)
	IsSaneAABB :: proc(a: AABB) -> bool ---

	// Is this a valid plane? Normal is a unit vector. Not Nan or infinity.
	@(require_results)
	IsValidPlane :: proc(a: Plane) -> bool ---

	// Is this a valid world position? Not NaN or infinity.
	@(require_results)
	IsValidPosition :: proc(p: Pos) -> bool ---

	// Is this a valid world transform? Not NaN or infinity. Rotation is normalized.
	@(require_results)
	IsValidWorldTransform :: proc(t: WorldTransform) -> bool ---
}
