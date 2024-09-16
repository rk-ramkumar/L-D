extends AnimatedSprite2D

signal roll_finished(number: int)

@export var roll_area_size = Vector2(100, 100)  # Adjust the area size as needed
@export var disappear_time: int = 2
@onready var label = $Label

var origin: Vector2
var number
var faces_frame = [38, 30, 22, 14]
var fall_speed = 400

func _ready():
	origin = position
	set_seed()
	set_process(false)

func set_seed():
	randomize()
	number = randi() % 4
	set_process(true)

func _process(delta):
	if position.y < 0:
		position.y += fall_speed * delta
	else:
		set_process(false)
		# Start the random frame change function
		randomize_rotation()
		randomize_position()

func randomize_position():
	# Randomly change position within the defined roll area
	var random_x = randf_range(-roll_area_size.x / 2, roll_area_size.x / 2)
	var random_y = randf_range(-roll_area_size.y / 2, roll_area_size.y / 2)
	# Set up the AnimatedSprite to play
	if [random_x, random_y].any(func(axis): return sign(axis) == -1):
		play("roll", 1.0, true)
	else:
		play("roll")

	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(random_x, random_y) + position, 0.5)
	tween.tween_callback(_on_position_anim_finished)
	tween.tween_callback(tween.kill)

func _on_position_anim_finished():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "frame", faces_frame[number], 0.5)
	tween.tween_callback(_reset)
	tween.tween_callback(tween.kill)

func _animate_label():
	if number == 3:
		return
	var random_pos = Vector2(randf_range(-20, -10),  randf_range(-400, -300))
	label.text = str(number+1)
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(label, "position", random_pos, 1).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0, 1).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_label_anim_finished)
	tween.tween_callback(tween.kill)

func _on_label_anim_finished():
	label.text = ""
	label.position = position

func _reset():
	_animate_label()
	await get_tree().create_timer(disappear_time).timeout
	pause()
	position = origin
	hide()

func randomize_rotation():
	# Generate a random rotation angle
	var random_angle = randf_range(-45, 45)
	# Apply the rotation to the sprite
	rotation_degrees = random_angle
	# Optionally, scale the sprite slightly to enhance the 3D effect
	var random_scale = Vector2(randf_range(0.9, 1.1), randf_range(0.9, 1.1))
	scale = random_scale

func _on_timer_timeout():
	roll_finished.emit(number)

func _on_visibility_changed():
	if visible and origin:
		position = origin
		set_seed()
