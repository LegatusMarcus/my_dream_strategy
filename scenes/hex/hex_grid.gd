@tool
extends Node3D
class_name HexGrid


var width: int = 6
var height: int = 6

var cells: Array = []

@onready var hex_mesh: HexMesh = $HexMesh


func _init() -> void:
	cells.resize(width * height)
	
	var i: int = 0
	for z in height:
		for x in width:
			create_cell(x, z, i)
			i += 1


func _ready() -> void:
	hex_mesh.triangulate_cells(cells)


func create_cell(x: int, z: int, i: int) -> void:
	var cell: HexCell = load("res://scenes/hex/hex_cell.tscn").instantiate()
	var label_3d: Label3D = Label3D.new()
	
	cells[i] = cell
	@warning_ignore("integer_division")
	cell.position = Vector3(
		(x + z * 0.5 - z / 2) * (HexMetrics.inner_radius * 2.0), 
		0.0, 
		-z * (HexMetrics.outer_radius * 1.5)
	)
	label_3d.position = Vector3(cell.position.x, 0.005, cell.position.z)
	label_3d.rotation_degrees.x = -90
	label_3d.pixel_size = 0.02
	label_3d.text = "%s\n%s" % [x, z]
	add_child(label_3d)

