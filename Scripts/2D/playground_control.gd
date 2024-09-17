extends Control

@onready var timer_label = $TimerLabel
@onready var roll_button = $RollButton
@export var turn_time: int = 60
# Called when the node enters the scene tree for the first time.
func _ready():
	%TurnTimer.timeout.connect(_on_timeout)
	Observer.turn_started.connect(_on_turn_started)

func _on_turn_started():
	timer_label.text = str(turn_time)

func _handle_player_turn(id):
	if id != GameManager.player.id:
		roll_button.disabled = true
		timer_label.text = str(turn_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
