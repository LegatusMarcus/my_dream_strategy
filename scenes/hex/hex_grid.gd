@tool
extends Node3D
class_name HexGrid


var width: int = 6
var height: int = 6
var default_color: Color = Color.WHITE

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


func get_cell(pos: Vector3) -> HexCell:
	var coordinates = HexCoordinates.from_position(pos)
	var index = coordinates.X + coordinates.Z * width + coordinates.Z / 2
	var cell: HexCell = cells[index]
	print("touched at %s" % coordinates)
	#print("neighbors: ", cell.neighbors)
	#print("elevation: ", cell.elevation)
	return cell

func refresh() -> void:
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
	cell.coordinates = HexCoordinates.from_offset_coordinates(x, z)
	cell.color = default_color
	
	label_3d.position = Vector3(cell.position.x, 0.005, cell.position.z)
	label_3d.rotation_degrees.x = -90
	label_3d.pixel_size = 0.02
	label_3d.text = cell.coordinates.to_string_on_separate_lines()
	add_child(label_3d)

