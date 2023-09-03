extends Node
class_name HexMetrics


static var outer_radius: float = 2.0
static var inner_radius: float = outer_radius * 0.866025404

static var corners: Array = [
	Vector3(0.0, 0.0, -outer_radius),
	Vector3(inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(0.0, 0.0, outer_radius),
	Vector3(-inner_radius, 0.0, 0.5 * outer_radius),
	Vector3(-inner_radius, 0.0, -0.5 * outer_radius),
	Vector3(0.0, 0.0, -outer_radius)
]
