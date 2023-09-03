extends Node
class_name HexMetrics


static var outer_radius: float = 2.0
static var inner_radius: float = outer_radius * 0.866025404
static var solid_factor: float = 0.75
static var blend_factor: float = 1.0 - solid_factor

static var corners: Array = [
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
