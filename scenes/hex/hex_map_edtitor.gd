extends Node3D


const RAY_LENGTH = 1000.0

var colors: Array

var active_color: Color
var active_elevation: int

var mouse_position: Vector2

@onready var hex_grid: HexGrid = $HexGrid

enum AviabledColors {
	Yellow,
	Green,
	Blue,
	White
}


func _init() -> void:
	colors.push_back(Color.YELLOW)
	colors.push_back(Color.GREEN)
	colors.push_back(Color.BLUE)
	colors.push_back(Color.WHITE)
	select_color(AviabledColors.Yellow)


func _physics_process(_delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	if Input.is_action_just_pressed("LMB"):
		var camera: Camera3D = $Camera3D
		var from = camera.project_ray_origin(mouse_position)
		var to = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if result:
			edit_cell(hex_grid.get_cell(result["position"]))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_position = event.position
		else:
			mouse_position = Vector2.ZERO


func edit_cell(cell: HexCell) -> void:
	cell.color = active_color
	#cell.Elevation = active_elevation
	hex_grid.refresh()


func select_color(color: AviabledColors) -> void:
	active_color = colors[color]


func _on_yellow_box_pressed() -> void:
	select_color(AviabledColors.Yellow)


func _on_green_box_pressed() -> void:
	select_color(AviabledColors.Green)


func _on_blue_box_pressed() -> void:
	select_color(AviabledColors.Blue)


func _on_white_box_pressed() -> void:
	select_color(AviabledColors.White)
