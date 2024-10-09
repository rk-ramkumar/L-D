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
	var end = min(playground.selected_actor.position_id + playground.player.coin, GameManager.max_tile_id)
	var target_ids = range(playground.selected_actor.position_id, end)
	var selected_id
	var step

	for id in target_ids.size():
		var target_cel = Vector2(blocks[target_ids[id]])
		#Select the tile that is closets to the clicked cell
		if target_cel.distance_squared_to(clicked_cell) <= 1:
			selected_id = target_ids[id]
			step = id + 1
			break

	if selected_id == null:
		MessageManager.add_info("Invalid position.")
		return false

	#Check for any actor already present in the tile
	if is_actor_present(selected_id, playground.selected_actor.team):
		MessageManager.add_info("Actor already in position.")
		return false
	var captured_actor = is_actor_present(
		selected_id,
		GameManager.get_opponent_team(playground.selected_actor.team),
		blocks[selected_id]
	)

	return {
		positions = blocks.slice(playground.selected_actor.position_id, selected_id+1),
		step = step,
		captured_actor = captured_actor
		}

func _unhandled_input(event):
	if event is InputEventScreenTouch and can_move:
		if !playground.selected_actor:
			MessageManager.add_info("Actor not select.")
			return

		if GameManager.player.id != playground.player.id:
			return

		if !playground.selected_actor.movable:
			MessageManager.add_info("Selected actor can't move.")
			return

		if event.is_released():
			var data = _is_valid_position()
			if data:
				playground.selected_actor.start_moving(data)
				GameManager.decrease_coin(data.step)

func is_actor_present(position_id, team, pos = null):
	if position_id <= 6: # Home lane
		return false

	if is_safe_tile(position_id): # Safe tile
		return PowersManager.has_sanctuary_seal(position_id, team)

	var target_pos = Vector2i(pos) if pos else blocks[position_id]
	var actors = GameManager.teamList[team].actors.filter(func(actor):
		return local_to_map(actor.position) == target_pos)

	if actors.size() > 0:
		return actors.front()

func is_safe_tile(id):
	var data = get_cell_tile_data(layer.BLOCKS, blocks[id])
	if data:
		return data.get_custom_data("safe_tile")
	else:
		return false
