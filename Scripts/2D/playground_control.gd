extends Control

signal move_made
@onready var timer_label = $TimerLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	%TurnTimer.timeout.connect(_on_timeout)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		move_made.emit()

func _on_roll_button_clicked():
	move_made.emit()
