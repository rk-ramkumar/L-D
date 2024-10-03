extends RigidBody2D

signal roll_finished(number: int)

@export var disappear_time: float = 1
@onready var label = $AnimatedSprite/Label
@onready var animated_sprite = $AnimatedSprite
@onready var dust_particles = $DustParticles

var origin
var number
var faces_frame = [10, 4, 25, 16]
var roll_force = 1000  # Adjust the force magnitude to control speed
var is_rolling = false
var tween

func _ready():
	origin = position
	Observer.roll_started.connect(roll_dice)

func roll_dice():
	if visible:
		_reset()
	show()
	animated_sprite.play_backwards("roll")
	dust_particles.emitting = true
	var random_direction = Vector2(randf_range(-0.2, 0.2), randf_range(-1, -0.5)).normalized()
	linear_velocity = random_direction * roll_force
	is_rolling = true

func _integrate_forces(_state):
	if linear_velocity.length() < 1 and is_rolling:
		# Stop the dice and choose a random frame for the final dice face
		linear_velocity = Vector2.ZERO
		animated_sprite.stop()
		_on_position_anim_finished()
		is_rolling = false

func _on_position_anim_finished():
	tween = create_tween()
	tween.tween_property(animated_sprite, "frame", faces_frame[number], 0.2)
	tween.tween_callback(_on_roll_finish)

func _animate_label():
	if tween:
		tween.kill()
	if number == 0:
		return
	var random_pos = Vector2(randf_range(-100, -150),  randf_range(-200, -250))
	label.text = str(number)
	tween = create_tween()
	tween.parallel().tween_property(label, "position", random_pos, disappear_time).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(label, "modulate:a", 0, disappear_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_reset)

func _on_roll_finish():
	_animate_label()
	roll_finished.emit(number)

func _reset():
	if tween:
		tween.kill()
	animated_sprite.pause()
	position = origin
	label.text = ""
	label.position = Vector2(-20, -20)
	label.modulate = Color.WHITE
	hide()
