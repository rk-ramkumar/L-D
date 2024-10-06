extends Area2D

@onready var power_sprite = $Circle01/PowerSprite

var offset = Vector2(-50, -100)
var actor = null

func _ready():
	_hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func move_start(data):
	power_sprite.texture = load(data.image)
	_show()

func move_end():
	_hide()

func _show():
	monitoring = true
	show()

func _hide():
	monitoring = false
	hide()

func update_position():
	global_position = get_global_mouse_position() + offset

func is_accept(power):
	if actor == null:
		return false
	if actor.power.is_empty():
		actor.power = power
		Observer.power_activated.emit(power, GameManager.playground.player, {actor = actor})
		return true
	else:
		return false

func _on_body_entered(body):
	if (
		!(body is Actor)
		or GameManager.playground.player.team != body.team
		or actor
	):
		return

	actor = body
	actor.scale = Vector2(2, 2)
	body.select(true)

func _on_body_exited(body):
	if (
		!(body is Actor)
		or GameManager.playground.player.team != body.team
	):
		return

	if actor:
		actor.scale = Vector2(1, 1)
	actor = null
	body.select(false)
