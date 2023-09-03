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
	
	if cell.get_edge_type(direction) == HexEdgeType.Slope:
		triangulate_edge_terraces(v1, v2, cell, v3, v4, neighbor)
	else:
		add_quad(v1, v2, v3, v4)
		add_quad_two_color(cell.color, neighbor.color)
	
	var next_neighbor = cell.get_neighbor(HexDirection.next(direction))
	if direction <= HexDirection.E && next_neighbor != null:
		var v5: Vector3 = v2 + HexMetrics.get_bridge(HexDirection.next(direction))
		v5.y = next_neighbor.Elevation
		
		if cell.Elevation <= neighbor.Elevation:
			if cell.Elevation <= next_neighbor.Elevation:
				triangulate_corner(v2, cell, v4, neighbor, v5, next_neighbor)
			else:
				triangulate_corner(v5, next_neighbor, v2, cell, v4, neighbor)
		elif neighbor.Elevation <= next_neighbor.Elevation:
			triangulate_corner(v4, neighbor, v5, next_neighbor, v2, cell)
		else:
			triangulate_corner(v5, next_neighbor, v2, cell, v4, neighbor)
			

func triangulate_edge_terraces(
	begin_left: Vector3, begin_right: Vector3, begin_cell: HexCell,
	end_left: Vector3, end_right: Vector3, end_cell: HexCell
) -> void:
	var v3: Vector3 = HexMetrics.terrace_lerp(begin_left, end_left, 1)
	var v4: Vector3 = HexMetrics.terrace_lerp(begin_right, end_right, 1)
	var c2: Color = HexMetrics.terrace_color_lerp(begin_cell.color, end_cell.color, 1)
	
	add_quad(begin_left, begin_right, v3, v4)
	add_quad_two_color(begin_cell.color, c2)
	
	var i: int = 2
	while  i < HexMetrics.terrace_steps:
		var v1: Vector3 = v3
		var v2: Vector3 = v4
		var c1: Color = c2
		
		v3 = HexMetrics.terrace_lerp(begin_left, end_left, i)
		v4 = HexMetrics.terrace_lerp(begin_right, end_right, i)
		c2 = HexMetrics.terrace_color_lerp(begin_cell.color, end_cell.color, i)
		
		add_quad(v1, v2, v3, v4)
		add_quad_two_color(c1, c2)
		
		i+=1
	
	add_quad(v3, v4, end_left, end_right)
	add_quad_two_color(c2, end_cell.color)

func triangulate_corner(
	bottom: Vector3, bottom_cell: HexCell,
	left: Vector3, left_cell: HexCell,
	right: Vector3, right_cell: HexCell
) -> void:
	var left_edge_type: int = bottom_cell.get_edge_cell_type(left_cell)
	var right_edge_type: int = bottom_cell.get_edge_cell_type(right_cell)
	
	if left_edge_type == HexEdgeType.Slope:
		if right_edge_type == HexEdgeType.Slope:
			triangulate_corner_terraces(
				bottom, bottom_cell, left, left_cell, right, right_cell
			)
		elif right_edge_type == HexEdgeType.Flat:
			triangulate_corner_terraces(
				left, left_cell, right, right_cell, bottom, bottom_cell
			)
		else:
			triangulate_corner_terraces_cliff(
				bottom, bottom_cell, left, left_cell, right, right_cell
			)
	if right_edge_type == HexEdgeType.Slope:
		if left_edge_type == HexEdgeType.Flat:
			triangulate_corner_terraces(
				right, right_cell, bottom, bottom_cell, left, left_cell
			)
		else:
			triangulate_corner_cliff_terraces(
				bottom, bottom_cell, left, left_cell, right, right_cell
			)
	if left_cell.get_edge_cell_type(right_cell) == HexEdgeType.Slope:
		if left_cell.Elevation < right_cell.Elevation:
			triangulate_corner_cliff_terraces(
				right, right_cell, bottom, bottom_cell, left, left_cell
			)
		else:
			triangulate_corner_terraces_cliff(
				left, left_cell, right, right_cell, bottom, bottom_cell
			)
	else:
		add_triangle(bottom, left, right)
		add_triangle_color_for_each_vertex(bottom_cell.color, left_cell.color, right_cell.color)

func triangulate_corner_terraces(
	begin: Vector3, begin_cell: HexCell,
	left: Vector3, left_cell: HexCell,
	right: Vector3, right_cell: HexCell
) -> void:
	var v3: Vector3 = HexMetrics.terrace_lerp(begin, left, 1)
	var v4: Vector3 = HexMetrics.terrace_lerp(begin, right, 1)
	var c3: Color = HexMetrics.terrace_color_lerp(begin_cell.color, left_cell.color, 1)
	var c4: Color = HexMetrics.terrace_color_lerp(begin_cell.color, right_cell.color, 1)
	
	add_triangle(begin, v3, v4)
	add_triangle_color_for_each_vertex(
		begin_cell.color, c3, c4
	)
	
	var i: int = 2
	while i < HexMetrics.terrace_steps:
		var v1: Vector3 = v3
		var v2: Vector3 = v4
		var c1: Color = c3
		var c2: Color = c4
		
		v3 = HexMetrics.terrace_lerp(begin, left, i)
		v4 = HexMetrics.terrace_lerp(begin, right, i)
		c3 = HexMetrics.terrace_color_lerp(begin_cell.color, left_cell.color, 1)
		c4 = HexMetrics.terrace_color_lerp(begin_cell.color, right_cell.color, 1)
		
		add_quad(v1, v2, v3, v4)
		add_quad_color(c1, c2, c3, c4)
		
		i+=1
	
	add_quad(v3, v4, left, right)
	add_quad_color(c3, c4, left_cell.color, right_cell.color)

func triangulate_corner_terraces_cliff(
	begin: Vector3, begin_cell: HexCell,
	left: Vector3, left_cell: HexCell,
	right: Vector3, right_cell: HexCell
) -> void:
	print('is the triangulate_corner_terraces_cliff function')
	var b: float = 1.0 / (right_cell.Elevation - begin_cell.Elevation)
	if b < 0: b = -b
	var boundary: Vector3 = begin.lerp(right, b)
	var boundary_color: Color = begin_cell.color.lerp(right_cell.color, b)
	
	triangulate_boundary_triangle(
		begin, begin_cell, left, left_cell, boundary, boundary_color
	)
	
	if left_cell.get_edge_cell_type(right_cell) == HexEdgeType.Slope:
		triangulate_boundary_triangle(
			left, left_cell, right, right_cell, boundary, boundary_color
		)
	else:
		add_triangle(left, right, boundary)
		add_triangle_color_for_each_vertex(
			left_cell.color, right_cell.color, boundary_color
		)

func triangulate_corner_cliff_terraces(
	begin: Vector3, begin_cell: HexCell,
	left: Vector3, left_cell: HexCell,
	right: Vector3, right_cell: HexCell
) -> void:
	print('is the triangulate_corner_terraces_cliff function')
	var b: float = 1.0 / (left_cell.Elevation - begin_cell.Elevation)
	if b < 0: b = -b
	var boundary: Vector3 = begin.lerp(left, b)
	var boundary_color: Color = begin_cell.color.lerp(left_cell.color, b)
	
	triangulate_boundary_triangle(
		right, right_cell, begin, begin_cell, boundary, boundary_color
	)
	
	if left_cell.get_edge_cell_type(right_cell) == HexEdgeType.Slope:
		triangulate_boundary_triangle(
			left, left_cell, right, right_cell, boundary, boundary_color
		)
	else:
		add_triangle(left, right, boundary)
		add_triangle_color_for_each_vertex(
			left_cell.color, right_cell.color, boundary_color
		)

func triangulate_boundary_triangle(
	begin: Vector3, begin_cell: HexCell,
	left: Vector3, left_cell: HexCell,
	boundary: Vector3, boundary_color: Color
) -> void:
	var v2: Vector3 = HexMetrics.terrace_lerp(begin, left, 1)
	var c2: Color = HexMetrics.terrace_color_lerp(begin_cell.color, left_cell.color, 1)
	
	add_triangle(begin, v2, boundary)
	add_triangle_color_for_each_vertex(
		begin_cell.color, c2, boundary_color
	)
	
	var i: int = 2
	while i < HexMetrics.terrace_steps:
		var v1: Vector3 = v2
		var c1: Color = c2
		
		v2 = HexMetrics.terrace_lerp(begin, left, i)
		c2 = HexMetrics.terrace_color_lerp(begin_cell.color, left_cell.color, i)
		
		add_triangle(v1, v2, boundary)
		add_triangle_color_for_each_vertex(
			c1, c2, boundary_color
		)
		
		i+=1
	
	add_triangle(v2, left, boundary)
	add_triangle_color_for_each_vertex(
		c2, left_cell.color, boundary_color
	)





