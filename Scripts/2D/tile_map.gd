extends TileMap

enum layer{
	FLOOR,
	BLOCKS,
	PLANT
}
var blocks
var total_safe_point = 13 # Without opposite side 3 point

func _ready():
	blocks = get_used_cells(layer.BLOCKS).slice(0, total_safe_point * 6 + 1)

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

func get_clicked_tile_data(layer_name, layer_id = layer.FLOOR):
	var clicked_cell = local_to_map(get_local_mouse_position())
	var surrounding_cells = get_surrounding_cells(clicked_cell)
	for coords in surrounding_cells:
		var data = get_cell_tile_data(layer_id, coords)
		if data != null:
			return data.get_custom_data(layer_name)
	return null

func _input(event):
	if event is InputEventScreenTouch:
		prints(get_clicked_tile_data("can_walk", layer.BLOCKS))
#		var actor = $TopLevelProps/Actors.get_child(0)
#		if actor.movable:
#			actor.move(get_global_mouse_position())
