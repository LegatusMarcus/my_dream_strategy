extends Node
class_name HexMetrics


const outer_radius: float = 2.0
const inner_radius: float = outer_radius * 0.866025404

const solid_factor: float = 0.75
const blend_factor: float = 1.0 - solid_factor

const terraces_per_slope: int = 2
const terrace_steps: int = terraces_per_slope * 2 + 1

const horizontal_terrace_step_size: float = 1.0 / terrace_steps
const vertical_terrace_step_size: float = 1.0 / (terraces_per_slope + 1)

const corners: Array = [
	Vector3(0.0, 0.0, -outer_radius),
	Vector3(inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(0.0, 0.0, outer_radius),
	Vector3(-inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(-inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(0.0, 0.0, -outer_radius)
]


static func get_first_corner(direction: int) -> Vector3:
	return corners[direction]

static func get_second_corner(direction: int) -> Vector3:
	return corners[direction + 1]

static func get_first_solid_corner(direction: int) -> Vector3:
	return corners[direction] * solid_factor

static func get_second_solid_corner(direction: int) -> Vector3:
	return corners[direction + 1] * solid_factor

static func get_bridge(direction: int) -> Vector3:
	return (corners[direction] + corners[direction + 1]) * blend_factor

static func terrace_lerp(a: Vector3, b: Vector3, step: int) -> Vector3:
	var h: float = step * HexMetrics.horizontal_terrace_step_size
	#print("a.x: %s, (%s - %s) * %s = %s" % [a.x, b.x, a.x, h, (b.x - a.x) * h])
	a.x += (b.x - a.x) * h
	#print("a.z: %s, -(%s + %s) * %s = %s" % [a.z, abs(b.z), abs(a.z), h, (abs(b.z) + abs(a.z)) * h])
	a.z += (b.z - a.z) * h
	@warning_ignore("integer_division")
	var v: float = ((step + 1) / 2) * HexMetrics.vertical_terrace_step_size
	#print("a.y: %s, (%s - %s) * %s = %s" % [a.y, b.y, a.y, v, (b.y - a.y) * v])
	a.y += (b.y - a.y) * v
	return a

static func terrace_color_lerp(a: Color, b: Color, step: int) -> Color:
	var h = step * HexMetrics.horizontal_terrace_step_size
	return a.lerp(b, 0.5)

static func get_edge_type(elevation_1: int, elevation_2: int) -> int:
	if elevation_1 == elevation_2:
		return HexEdgeType.Flat
	var delta = elevation_2 - elevation_1
	if delta == 1 || delta == -1:
		return HexEdgeType.Slope
	
	return HexEdgeType.Cliff








