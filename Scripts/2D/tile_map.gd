extends TileMap

enum layer{
	FLOOR,
	BLOCKS,
	PLANT
}
var blocks
var total_safe_point = 13 # Without opposite side 3 point
var can_move = false

func _ready():
	blocks = get_used_cells(layer.BLOCKS).slice(0, total_safe_point * 6 + 1)
	Observer.move_started.connect(_on_move_started)
	Observer.move_completed.connect(_on_move_completed)

func get_spawn_position(opposite = false):
	var top_left = Vector2(4, 4) # Start safe tile local position
	var bottom_right = Vector2(16, 14) # Center tile local position
	if opposite:
		top_left.y = -bottom_right.y
		bottom_right.y = -4
	# Add offset
	top_left.x += 4
	bottom_right.x -= 4
	var positions = []

	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			positions.append(map_to_local(Vector2(x, y)))

	return positions

func _is_valid_position():
	var clicked_cell = local_to_map(get_local_mouse_position())
	var target_id = (GameManager.selected_actor.position_id + GameManager.currentDieNumber) - 1
	var target_cel = Vector2(blocks[target_id])
	
	if target_cel.distance_squared_to(clicked_cell) > 1 or !GameManager.selected_actor.movable:
		print("Invalid position")
		return false

	return true

func _unhandled_input(event):
	if event is InputEventScreenTouch and can_move:
		if !GameManager.selected_actor:
			print("Actor not select.")
		else:
			if _is_valid_position():
				GameManager.selected_actor.start_moving(blocks.slice(GameManager.selected_actor.position_id))
				Observer.move_completed.emit()

func _on_move_started():
	can_move = true

func _on_move_completed():
	can_move = false
