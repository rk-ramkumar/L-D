extends AnimatedSprite2D

signal roll_finished(number: int)
@export var roll_area_size = Vector2(200, 200)  # Adjust the area size as needed
var number
var faces_frame = [6, 30, 22, 14]

func _ready():
	number = randi() % 3
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
	tween.tween_callback(_animate)
	tween.tween_callback(tween.kill)

func _animate():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "frame", faces_frame[number], 0.5)
	tween.tween_callback(pause)

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
