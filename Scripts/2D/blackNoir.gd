extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
#	if direction.x != 0 and direction.y != 0:
#		velocity.x = direction * SPEED
	velocity = cartesian_to_isometric(direction) * SPEED

	
	move_and_slide()

func cartesian_to_isometric(cartesian_position: Vector2) -> Vector2:
	var isometric_x = cartesian_position.x - cartesian_position.y
	var isometric_y = (cartesian_position.x + cartesian_position.y)/2
	
	return Vector2(isometric_x, isometric_y)
