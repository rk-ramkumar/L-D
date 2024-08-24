extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d = $AnimatedSprite2D
var direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _input(event):
	if event is InputEventScreenTouch:
		var mouse_pos = get_local_mouse_position()
		var angle = snappedf(mouse_pos.angle(), (PI/4)) / (PI/4)
		angle = wrapi(int(angle), 0, 8)
		_update_animation("{direction}_run".format({direction = directions[angle]}))

func _lerp_to_pos(pos):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, 1)

func cartesian_to_isometric(cartesian_position: Vector2) -> Vector2:
	var isometric_x = cartesian_position.x - cartesian_position.y
	var isometric_y = (cartesian_position.x + cartesian_position.y)/2
	
	return Vector2(isometric_x, isometric_y)

func _update_animation(animation_name):
	animated_sprite_2d.play(animation_name)
