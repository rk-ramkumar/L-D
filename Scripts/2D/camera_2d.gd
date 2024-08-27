extends Camera2D

@export var map_width = 44 * 64  # Assuming 64 pixels per tile
@export var map_height = 44 * 32  # Assuming 32 pixels per tile
@onready var tile_map = $"../TileMap"
@onready var viewport_size = get_viewport().size

var min_zoom = 0.5
var max_zoom = 1.5
var pan_speed = 1.5
var start_zoom
var drag_start = Vector2()
var dragging = false
var touch_indexes = {}
var start_distance = 0


func _ready():
	set_camera_limit()

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
		start_zoom = zoom

	elif touch_indexes.size() < 2:
		start_distance = 0

func _handle_drag(event: InputEventScreenDrag):
	touch_indexes[event.index] = event.position * pan_speed

	if touch_indexes.size() == 1:
		position -= event.relative * pan_speed
	if touch_indexes.size() == 2:
		var points = touch_indexes.values()
		var current_distance  = points[0].distance_to(points[1])
		var zoom_factor = start_distance / current_distance
		zoom = start_zoom / zoom_factor
		# Clamp the zoom level
		zoom = Vector2(clamp(zoom.x, min_zoom, max_zoom), clamp(zoom.y, min_zoom, max_zoom))
