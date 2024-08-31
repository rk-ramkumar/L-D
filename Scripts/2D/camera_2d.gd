extends Camera2D

@export var map_width = 44 * 64  # Assuming 64 pixels per tile
@export var map_height = 44 * 32  # Assuming 32 pixels per tile
@onready var tile_map = $"../TileMap"
@onready var viewport_size = get_viewport().size

var min_zoom = 0.5
var max_zoom = 1.5
var pan_speed = 1.5
var target_ratio = 16.0 / 9.0
var start_zoom
var drag_start = Vector2()
var dragging = false
var touch_indexes = {}
var start_distance = 0
var center_position
var limit

func _ready():
	set_camera_limit()
	adjust_camera_to_fit_tilemap()
	get_viewport().size_changed.connect(adjust_camera_to_fit_tilemap)

func adjust_camera_to_fit_tilemap():
	var viewport_rect = get_viewport_rect().size
	var screen_ratio = viewport_rect.x / viewport_rect.y

	if screen_ratio > target_ratio:
		zoom.x = min_zoom * screen_ratio / target_ratio
		zoom.y = min_zoom
	else:
		zoom.y = min_zoom * target_ratio / screen_ratio
		zoom.x = min_zoom

func _input(event):
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func set_camera_limit():
	var tile_used_size = tile_map.get_used_rect().size
	var tile_size = tile_map.tile_set.tile_size / 2
	var tile_limit = tile_size  * tile_used_size
	limit_left = -tile_limit.x - tile_size.x
	limit_right = tile_limit.x + tile_size.x
	limit_top = -tile_limit.y
	limit_bottom = tile_limit.y	

func _handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_indexes[event.index] = event.position
	else:
		touch_indexes.erase(event.index)

	if touch_indexes.size() == 2:
		var points = touch_indexes.values()
		start_distance = points[0].distance_to(points[1])
		# Calculate the midpoint between the two touches
		start_zoom = zoom

	elif touch_indexes.size() < 2:
		start_distance = 0

func _handle_drag(event: InputEventScreenDrag):
	touch_indexes[event.index] = event.position 

	if touch_indexes.size() == 1:
		# Panning logic
		position -= event.relative * pan_speed

	if touch_indexes.size() == 2:
		# Zooming logic
		var points = touch_indexes.values()
		var current_distance  = points[0].distance_to(points[1])
		if current_distance != 0 and start_distance != 0:
			var zoom_factor = current_distance / start_distance
			var new_zoom = start_zoom * zoom_factor
			# Clamp the zoom level
			new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
			new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)

			# Adjust camera position to keep the center point under the pinch gesture
			center_position = (points[0] + points[1]) / 2
			var zoom_delta = new_zoom / zoom
			var camera_offset = center_position - position
			position += camera_offset * (zoom_delta - Vector2.ONE)
			zoom = new_zoom
