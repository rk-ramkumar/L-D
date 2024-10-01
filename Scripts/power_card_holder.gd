extends Node2D

@onready var power_sprite = $Circle01/PowerSprite

var offset = Vector2(-50, -100)

func move_start(data):
	power_sprite.texture = load(data.image)
	visible = true

func move_end():
	visible = false

func update_position():
	global_position = get_global_mouse_position() + offset

func _on_body_entered(body):
	body.select(true)

func _on_body_exited(body):
	body.select(false)
