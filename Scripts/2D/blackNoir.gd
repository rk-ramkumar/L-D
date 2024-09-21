extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var home_state_timer = $HomeStateTimer

@export var tile_map: TileMap
@export var current_direction: String
@export var data: Dictionary = {}
var directions = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
var tween
var position_id = 0
var movable: bool = true
var current_state = GameManager.player_state.HOME:
	set(new_state):
		current_state = new_state
		_set_current_state()

func _ready():
	position = data.positions.pick_random()
	_set_direction(get_angle_to(position))
	_update_animation("_idle")

func _set_current_state():
	if current_state == GameManager.player_state.HOME:
		home_state_timer.start(5)
	else:
		home_state_timer.stop()

func _set_direction(position_angle = get_local_mouse_position().angle()):
	var angle = snappedf(position_angle, PI/4) / (PI/4)
	angle = wrapi(int(angle), 0, 8)
	current_direction = str(directions[angle])

func move(target_position):
	pass

func _lerp_to_pos(pos, speed = SPEED):
	if tween:
		tween.kill()
	tween = create_tween()
	var time_delay = global_position.distance_to(pos) / speed
	tween.tween_property(self, "position", pos, time_delay)
	tween.tween_callback(_on_tween_position_finished)

func cartesian_to_isometric(cartesian_position: Vector2) -> Vector2:
	var isometric_x = cartesian_position.x - cartesian_position.y
	var isometric_y = (cartesian_position.x + cartesian_position.y)/2
	
	return Vector2(isometric_x, isometric_y)

func _update_animation(animation_name):
	animation_name = current_direction + animation_name
	animated_sprite_2d.play(animation_name)
	
	# Added offset for jump animation.
	if animation_name.contains("jump"):
		animated_sprite_2d.scale = Vector2(0.6, 0.6)
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.frame = 0
		_update_animation("_idle")
		animated_sprite_2d.scale = Vector2(0.5, 0.5)

func _on_tween_position_finished():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(
		animated_sprite_2d.play,
		animated_sprite_2d.animation,
		StringName(current_direction + "_idle"),
		0.2)

func _on_home_state_timer_timeout():
	home_state_timer.stop()
	var pos = data.positions.pick_random()
	_set_direction(get_angle_to(pos))
	_update_animation("_walk")
	_lerp_to_pos(pos, 100)
	await tween.finished
	home_state_timer.start(10)
