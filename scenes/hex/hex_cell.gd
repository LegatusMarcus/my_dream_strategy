extends Node3D
class_name HexCell


var coordinates: HexCoordinates
var color: Color
var neighbors: Array
var Elevation: int:
	get:
		return elevation
	set(value):
		elevation = value
		position.y = value
		coord_label.position.y = value + 0.001
var elevation: int

var coord_label: Label3D

func _init() -> void:
	neighbors.resize(6)


func get_neighbor(direction: int) -> HexCell:
	return neighbors[direction]

func set_neighbor(direction: int, cell: HexCell) -> void:
	neighbors[direction] = cell
	cell.neighbors[HexDirection.opposite(direction)] = self

