extends HBoxContainer

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play_backwards("open")

func _on_button_toggled(button_pressed):
	if button_pressed:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")
