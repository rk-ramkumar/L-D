extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var tile_map: TileMap
@export var current_direction: String

var directions = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
var tween

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	_update_animation("_idle")

func _input(event):
	if event is InputEventScreenTouch:
		var mouse_pos = get_local_mouse_position()
		var angle = snappedf(mouse_pos.angle(), (PI/4)) / (PI/4)
		angle = wrapi(int(angle), 0, 8)
		current_direction = str(directions[angle])
		_update_animation("_walk")
		var pos = get_global_mouse_position()
		_lerp_to_pos(pos)

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		_update_animation("_jump")

func _lerp_to_pos(pos):
	if tween:
		tween.kill()
	tween = create_tween()
	var time_delay = global_position.distance_to(pos) / SPEED
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
