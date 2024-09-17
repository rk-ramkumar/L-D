extends Node2D

@onready var turn_timer = %TurnTimer
@onready var ui = $CanvasLayer/UI
@onready var tile_map = $TileMap
@onready var dice = [$TopLevelProps/Die1, $TopLevelProps/Die2]
@onready var steps_label = $CanvasLayer/UI/StepLabel/Steps
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
	# Current player actors
	var player_positions = _get_spawn_position()
	range(GameManager.actors_count).map(func(_no):_create_actors(player_positions))
	#Opponent actors
	var opponent_positions = _get_spawn_position(true)
	range(GameManager.actors_count).map(func(_no):_create_actors(opponent_positions, Color.RED))
	
	Observer.turn_started.emit()

func connect_signals():
	Observer.roll_started.connect(_handle_roll_started)
	Observer.roll_completed.connect(_handle_roll_completed)
	
func _create_actors(positions, color = Color.WHITE):
	var actor = actor_scene.instantiate()
	actor.home_positions = positions
	actor.modulate = color
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
	GameManager.currentDieNumber = dice_numbers.reduce(func(acc, cur): return acc+cur, 0)
	dice_numbers = []
	steps_label.text = str(GameManager.currentDieNumber)
#	GameManager.currentPlayerTurn = turn_timer.getNextId()

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
		Observer.roll_completed.emit()
