extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const ANIM_DIRECTION_CONFIG = [
	{
		"direction" : Vector2(-0.7, -0.7),
		"animation_name" : "N"
	},
	{
		"direction" : Vector2(0, -1),
		"animation_name" : "NE"
	},
	{
		"direction" : Vector2(0.7, -0.7),
		"animation_name" : "E"
	},
	{
		"direction" : Vector2(1, 0),
		"animation_name" : "SE"
	},
	{
		"direction" : Vector2(0.7, 0.7),
		"animation_name" : "S"
	},
	{
		"direction" : Vector2(-0.7, 0.7),
		"animation_name" : "E",
		"flip_h": true
	},
	{
		"direction" : Vector2(0, 1),
		"animation_name" : "SE",
		"flip_h": true
	},
	{
		"direction" : Vector2(-1, 0),
		"animation_name" : "NE",
		"flip_h": true
	},
	
]
@export var dir: String = "N"
@onready var animated_sprite_2d = $AnimatedSprite2D
var direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	animated_sprite_2d.play(dir)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	var temp = Helpers.objectFind(
		ANIM_DIRECTION_CONFIG,
		"direction",
		direction
	)
	prints(temp, direction)
	_update_animation(temp)

	velocity = cartesian_to_isometric(direction) * SPEED
	move_and_slide()

func cartesian_to_isometric(cartesian_position: Vector2) -> Vector2:
	var isometric_x = cartesian_position.x - cartesian_position.y
	var isometric_y = (cartesian_position.x + cartesian_position.y)/2
	
	return Vector2(isometric_x, isometric_y)

func _update_animation(anim_config: Dictionary):
	if anim_config.is_empty():
		return
	print(anim_config.animation_name)
	animated_sprite_2d.play(anim_config.animation_name)
	animated_sprite_2d.flip_h = anim_config.get("flip_h", false)
