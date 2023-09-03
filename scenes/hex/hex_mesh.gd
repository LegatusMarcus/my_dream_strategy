extends MeshInstance3D
class_name HexMesh

var hex_mesh: ArrayMesh
var surface_array: Array
var vertices: PackedVector3Array
var colors: PackedColorArray
var triangles: PackedInt32Array


func _init() -> void:
	hex_mesh = ArrayMesh.new()


func add_triangle(v1: Vector3, v2: Vector3, v3: Vector3) -> void:
	var vertices_index = vertices.size()
	vertices.push_back(v1)
	vertices.push_back(v2)
	vertices.push_back(v3)
	triangles.push_back(vertices_index)
	triangles.push_back(vertices_index + 1)
	triangles.push_back(vertices_index + 2)

func add_triangle_color(color: Color) -> void:
	colors.push_back(color)
	colors.push_back(color)
	colors.push_back(color)

func add_triangle_color_for_each_vertex(c1: Color, c2: Color, c3: Color) -> void:
	colors.push_back(c1)
	colors.push_back(c2)
	colors.push_back(c3)

func triangulate_cells(cells: Array) -> void:
	hex_mesh.clear_surfaces()
	surface_array.clear()
	vertices.clear()
	colors.clear()
	triangles.clear()
	
	surface_array.resize(Mesh.ARRAY_MAX)
	for i in cells.size():
		triangulate_cell(cells[i])
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_COLOR] = colors
	surface_array[Mesh.ARRAY_INDEX] = triangles
	hex_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh = hex_mesh
	if get_child_count():
		var collider = get_child(0)
		if get_child(0) is StaticBody3D:
			remove_child(collider)
			collider.queue_free()
			create_trimesh_collision()
	else:
		create_trimesh_collision()


func triangulate_cell(cell: HexCell) -> void:
	var center: Vector3 = cell.position
	for i in 6:
		add_triangle(
			center,
			center + HexMetrics.corners[i],
			center + HexMetrics.corners[i+1]
		)
		add_triangle_color(cell.color)
