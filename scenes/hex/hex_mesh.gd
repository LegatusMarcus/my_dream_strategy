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


func add_quad(v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3) -> void:
	var vertex_index: int = vertices.size()
	vertices.push_back(v1)
	vertices.push_back(v2)	
	vertices.push_back(v3)
	vertices.push_back(v4)
	triangles.push_back(vertex_index)
	triangles.push_back(vertex_index + 2)
	triangles.push_back(vertex_index + 1)
	triangles.push_back(vertex_index + 1)
	triangles.push_back(vertex_index + 2)
	triangles.push_back(vertex_index + 3)

func add_quad_color(c1: Color, c2: Color, c3: Color, c4: Color) -> void:
	colors.push_back(c1)
	colors.push_back(c2)
	colors.push_back(c3)
	colors.push_back(c4)

func add_quad_two_color(c1: Color, c2: Color) -> void:
	colors.push_back(c1)
	colors.push_back(c1)
	colors.push_back(c2)
	colors.push_back(c2)


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
	var d: int = HexDirection.NE
	while d <= HexDirection.NW:
		triangulate_cell_direction(d, cell)
		d += 1

func triangulate_cell_direction(direction: int, cell: HexCell) -> void:
	var center: Vector3 = cell.position
	var v1: Vector3 = center + HexMetrics.get_first_solid_corner(direction)
	var v2: Vector3 = center + HexMetrics.get_second_solid_corner(direction)
	
	add_triangle(center, v1, v2)
	add_triangle_color(cell.color)
	
	if direction <= HexDirection.SE:
		triangulate_connection(direction, cell, v1, v2)

func triangulate_connection(direction: int, cell: HexCell, v1: Vector3, v2: Vector3) -> void:
	var neighbor = cell.get_neighbor(direction)
	if neighbor == null: return
	
	var bridge: Vector3 = HexMetrics.get_bridge(direction)
	var v3: Vector3 = v1 + bridge
	var v4: Vector3 = v2 + bridge
	v3.y = neighbor.Elevation
	v4.y = neighbor.Elevation
	
	add_quad(v1, v2, v3, v4)
	add_quad_two_color(
		cell.color,
		neighbor.color
	)
	
	var next_neighbor = cell.get_neighbor(HexDirection.next(direction))
	if direction <= HexDirection.E && next_neighbor != null:
		var v5: Vector3 = v2 + HexMetrics.get_bridge(HexDirection.next(direction))
		v5.y = next_neighbor.Elevation
		add_triangle(v2, v4, v5)
		add_triangle_color_for_each_vertex(
			cell.color,
			neighbor.color,
			next_neighbor.color
		)
