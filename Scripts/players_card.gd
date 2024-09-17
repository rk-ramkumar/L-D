extends Panel

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var texture_rect = $TextureRect
@onready var label = $Label
var player = {}

func _ready():
	label.text = player.get("name", "s")
	if player.has("icon"):
		texture_rect.texture = load(player.icon)
	Observer.turn_started.connect(_on_turn_started)

func _on_turn_started():
	if GameManager.currentPlayerTurn == player.id:
		animated_sprite_2d.visible = true
		animated_sprite_2d.play("default")
	else:
		animated_sprite_2d.visible = false
		animated_sprite_2d.stop()
