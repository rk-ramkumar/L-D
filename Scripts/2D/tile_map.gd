extends TileMap

@export var playground: Node2D

enum layer{
	FLOOR,
	BLOCKS,
	PLANT,
	FOREST
}
var blocks
var total_safe_point = 13 # Without opposite side 3 point
var can_move = false

func _ready():
	blocks = get_used_cells(layer.BLOCKS).slice(0, total_safe_point * 6 + 1)
	blocks.append(get_used_cells(layer.PLANT)[0])

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
	var target_id = (playground.selected_actor.position_id + GameManager.currentDieNumber)
	var target_cel = Vector2(blocks[target_id - 1])
	
	if target_cel.distance_squared_to(clicked_cell) > 1 or !playground.selected_actor.movable:
		MessageManager.add_message("Invalid position.")
		return false
	#Check for any actor already present in the tile
	if is_actor_present(target_id, playground.selected_actor.team):
		MessageManager.add_message("Actor already in position.")
		return false

	return true

func _unhandled_input(event):
	if event is InputEventScreenTouch and can_move:
		if !playground.selected_actor:
			MessageManager.add_message("Actor not select.")
			return

		if GameManager.player.id != playground.player.id:
			return

		if event.is_released() and _is_valid_position():
			can_move = false
			playground.selected_actor.start_moving(
				blocks.slice(playground.selected_actor.position_id)
			)

func is_actor_present(position_id, team):
	if position_id <= 7: # Home lane
		return false
	if (position_id - 1) % 6 == 0: # Safe tile
		return false 

	var actors = GameManager.teamList[team].actors.filter(func(actor):
		return actor.position_id == position_id)

	if actors.size() > 0:
		return actors.front()
