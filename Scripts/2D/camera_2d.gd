extends Camera2D

@export var map_width = 44 * 64  # Assuming 64 pixels per tile
@export var map_height = 44 * 32  # Assuming 32 pixels per tile

@onready var viewport_size = get_viewport().size

var min_zoom = 0.5
var max_zoom = 2.0
var drag_start = Vector2()
var dragging = false


func _input(event):
	if event is InputEventScreenDrag:
		var offset = event.relative
		move_camera(offset)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = Vector2(zoom.x * 0.9, zoom.y * 0.9)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = Vector2(zoom.x * 1.1, zoom.y * 1.1)
		# Clamp the zoom level
		zoom = Vector2(clamp(zoom.x, min_zoom, max_zoom), clamp(zoom.y, min_zoom, max_zoom))
func move_camera(offset):
	var new_pos = position - offset
	# Clamp the camera position to the map boundaries
	var max_width = map_width - viewport_size.x
	var max_height = map_height - viewport_size.y
	new_pos.x = clamp(new_pos.x, -max_width, max_width)
	new_pos.y = clamp(new_pos.y, 0, max_height)

	print(new_pos)
	position = new_pos
