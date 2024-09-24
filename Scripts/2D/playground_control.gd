extends Control

@onready var timer_label = $TimerLabel
@onready var roll_button = $RollButton
@onready var steps_label = $StepLabel/Steps
@export var turn_time: int = 60
@export var move_time: int = 30
var state: String

func _ready():
	%TurnTimer.timeout.connect(_on_timeout)
	Observer.turn_started.connect(_on_turn_started)
	Observer.move_started.connect(_on_move_started)
	Observer.roll_completed.connect(_on_roll_completed)

func _on_turn_started():
	timer_label.text = str(turn_time)
	roll_button.disabled = GameManager.currentPlayerTurn != GameManager.player.id
	state = "roll"

func _on_move_started():
	timer_label.text = str(move_time)
	state = "move"

func _on_roll_completed(dice_value):
	steps_label.text = str(dice_value)

func _handle_player_turn(id):
	if id != GameManager.player.id:
		roll_button.disabled = true
		timer_label.text = str(turn_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		Observer.emit_signal(state+"_failed")
