extends RigidBody2D

signal roll_finished(number: int)

@export var disappear_time: int = 2
@onready var label = $AnimatedSprite/Label
@onready var animated_sprite = $AnimatedSprite
@onready var dust_particles = $DustParticles

var origin
var number
var faces_frame = [10, 4, 25, 16]
var roll_force = 1000  # Adjust the force magnitude to control speed
var is_rolling = false

func _ready():
	origin = position

func set_seed():
	randomize()
	number = randi() % 4
	roll_dice()

func roll_dice():
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
	var tween = get_tree().create_tween()
	tween.tween_property(animated_sprite, "frame", faces_frame[number], 0.2)
	tween.tween_callback(_reset)
	tween.tween_callback(tween.kill)

func _animate_label():
	if number == 0:
		return
	var random_pos = Vector2(randf_range(-100, -150),  randf_range(-200, -250))
	label.text = str(number)
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(label, "position", random_pos, 1).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0, 1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_label_anim_finished)
	tween.tween_callback(tween.kill)

func _on_label_anim_finished():
	label.text = ""
	label.position = Vector2(-20, -20)
	label.modulate = Color.WHITE

func _reset():
	_animate_label()
	roll_finished.emit(number)
	await get_tree().create_timer(disappear_time).timeout
	animated_sprite.pause()
	position = origin
	hide()

func _on_visibility_changed():
	if visible:
		set_seed()
