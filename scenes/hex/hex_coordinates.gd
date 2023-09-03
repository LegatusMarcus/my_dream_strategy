extends Node
class_name HexCoordinates

var X: int
var Y: int:
	get:
		return -X - Z
var Z: int

func _init(x: int, z: int) -> void:
	X = x
	Z = z


static func from_offset_coordinates(x: int, z: int) -> HexCoordinates:
	@warning_ignore("integer_division")
	return HexCoordinates.new(x - z / 2, z)


static func from_position(pos: Vector3) -> HexCoordinates:
	var x: float = pos.x / (HexMetrics.inner_radius * 2.0)
	var y: float = -x
	var offset = -pos.z / (HexMetrics.outer_radius * 3.0)
	x -= offset
	y -= offset
	
	var iX: int = int(round(x))
	var iY: int = int(round(y))
	var iZ: int = int(round(-x - y))
	
	if iX + iY + iZ != 0:
		var dX = abs(x - iX)
		var dY = abs(y - iY)
		var dZ = abs(-x - y - iZ)
		
		if dX > dY && dX > dZ:
			iX = -iY - iZ
		elif dZ > dY:
			iZ = -iX - iY
	
	
	return HexCoordinates.new(iX, iZ)


func _to_string() -> String:
	return "(%s, %s, %s)" % [X, Y, Z]

func to_string_on_separate_lines() -> String:
	return "%s\n%s\n%s" % [X, Y, Z]
