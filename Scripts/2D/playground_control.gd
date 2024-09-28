extends Control

@onready var timer_label = $TimerLabel
@onready var roll_button = $RollButton
@onready var die_2 = $StepLabel/Steps/DiceImageContainer/Die2
@onready var die_1 = $StepLabel/Steps/DiceImageContainer/Die1

@export var turn_time: int = 25
@export var move_time: int = 15

var state: String
var die_textures = [
	preload("res://Assets/Icons/dice_empty.svg"),
	preload("res://Assets/Icons/dieWhite_border1.png"),
	preload("res://Assets/Icons/dieWhite_border2.png"),
	preload("res://Assets/Icons/dieWhite_border3.png"),
	preload("res://Assets/Icons/dieWhite_border6.png")
	]

func _ready():
	%TurnTimer.timeout.connect(_on_timeout)
	Observer.turn_started.connect(_on_turn_started)
	Observer.move_started.connect(_on_move_started)

func _on_turn_started():
	timer_label.text = str(turn_time)
	roll_button.disabled = GameManager.currentPlayerTurn != GameManager.player.id
	state = "roll"

func _on_move_started():
	timer_label.text = str(move_time)
	state = "move"

func on_roll_completed(dice_values):
	if dice_values.all(func(die_value): return die_value == 0):
		die_1.texture = die_textures.back()
		die_2.texture = die_textures.back()
	else:
		die_1.texture = die_textures[dice_values[0]]
		die_2.texture = die_textures[dice_values[1]]

func _handle_player_turn(id):
	if id != GameManager.player.id:
		roll_button.disabled = true
		timer_label.text = str(turn_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		Observer.emit_signal(state+"_failed")
