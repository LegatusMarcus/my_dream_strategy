extends Node3D
class_name HexCell


var coordinates: HexCoordinates
var color: Color
var neighbors: Array


func _init() -> void:
	neighbors.resize(6)


func get_neighbor(direction: int) -> HexCell:
	return neighbors[direction]

func set_neighbor(direction: int, cell: HexCell) -> void:
	neighbors[direction] = cell
	cell.neighbors[HexDirection.opposite(direction)] = self

