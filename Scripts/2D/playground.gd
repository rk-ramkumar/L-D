extends Node2D

signal moveMade
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

func _ready():
	GameManager.player = GameManager.Players[1]
	turn_timer.start()
	GameManager.switchTurn.connect(_handle_player_turn)

func _handle_player_turn(id):
	pass

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

	is_rolling = true
	turn_timer.stop()
	dice.map(func(die): die.visible = true)

func _on_die_rolled(number):
	dice_numbers.append(number)
	if dice_numbers.size() == 2:
		is_rolling = false
		GameManager.currentDieNumber = dice_numbers.reduce(func(acc, cur): return acc+cur, 0)
		steps_label.text = str(GameManager.currentDieNumber)
		GameManager.currentPlayerTurn = turn_timer.getNextId()
