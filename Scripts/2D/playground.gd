extends Node2D

@onready var turn_timer = %TurnTimer
@onready var ui = $CanvasLayer/UI
@onready var tile_map = $TileMap
@onready var dice = [$TopLevelProps/Die1, $TopLevelProps/Die2]
enum tile_layer{
	FLOOR,
	BLOCKS,
	PLANT
}
var turnTime = 60
var dice_numbers = []
var is_rolling = false
var actor_scene = preload("res://Scenes/2D/blackNoir.tscn")

func _ready():
	connect_signals()
	GameManager.player = GameManager.Players[1]
	_add_actors()
	Observer.turn_started.emit()

func connect_signals():
	Observer.roll_started.connect(_handle_roll_started)
	Observer.roll_completed.connect(_handle_roll_completed)

func _add_actors():
	var player_args ={
		positions = _get_spawn_position(),
		team = GameManager.player.team
	}
	var opponent_args ={
		positions = _get_spawn_position(true),
		team = "D" if GameManager.player.team == "L" else "L"
	}
	for args in [player_args, opponent_args]:
		range(GameManager.actors_count).map(func(_no):_create_actors(args))

func _create_actors(args):
	var actor = actor_scene.instantiate()
	actor.data = args
	actor.modulate = args.get("color", Color.WHITE)
	GameManager.teamList[args.team].actors.append(actor)
	$TopLevelProps/Actors.add_child(actor)

func _get_spawn_position(opposite = false):
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
			positions.append(tile_map.map_to_local(Vector2(x, y)))

	return positions

func _handle_player_turn(id):
	pass

func _handle_roll_started():
	is_rolling = true
	turn_timer.stop()
	dice.map(func(die): die.visible = true)

func _handle_roll_completed():
	is_rolling = false
	dice_numbers = []
	var actors = GameManager.teamList[
		GameManager.Players[GameManager.currentPlayerTurn].team
	].actors
	var is_all_home = actors.all(func(actor):
		return actor.current_state == GameManager.player_state.HOME)

	if is_all_home and GameManager.currentDieNumber != 1:
		GameManager.currentPlayerTurn = _get_next_id()
		Observer.next_turn.emit()
		return

	_set_movable(actors)
	if actors.any(func(actor): return actor.movable):
		Observer.move_started.emit()
	else:
		GameManager.currentPlayerTurn = _get_next_id()
		Observer.next_turn.emit()

func _set_movable(actors):
	## Check for powers that stop movable
	for actor in actors:
		if actor.position_id + GameManager.currentDieNumber > GameManager.max_tile_id:
			actor.movable = false
		else:
			actor.movable = true

func _get_next_id():
	return (GameManager.currentPlayerTurn % GameManager.playerLoaded) + 1

func get_clicked_tile_data(layer_name, layer_id = tile_layer.FLOOR):
	var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var surrounding_cells = tile_map.get_surrounding_cells(clicked_cell)
	for coords in surrounding_cells:
		var data = tile_map.get_cell_tile_data(layer_id, coords)
		if data != null:
			return data.get_custom_data(layer_name)
	return null

func _input(event):
	if event is InputEventScreenTouch:
		prints(get_clicked_tile_data("can_walk", tile_layer.BLOCKS))

func _on_roll_button_clicked():
	if is_rolling:
		return
	Observer.roll_started.emit()

func _on_die_rolled(number):
	dice_numbers.append(number)
	if dice_numbers.size() == 2:
		GameManager.currentDieNumber = dice_numbers.reduce(func(acc, cur): return acc+cur, 0)
		Observer.roll_completed.emit()
