extends Control

signal move_made
@onready var timer_label = $TimerLabel
@onready var roll_button = $RollButton
@export var turn_time: int = 60
# Called when the node enters the scene tree for the first time.
func _ready():
	timer_label.text = str(turn_time)
	%TurnTimer.timeout.connect(_on_timeout)
	GameManager.switchTurn.connect(_handle_player_turn)

func _handle_player_turn(id):
	if id != GameManager.player.id:
		roll_button.disabled = true
		timer_label.text = str(turn_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		move_made.emit()
