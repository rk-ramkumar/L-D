extends Sprite2D

@onready var original_scale = scale
@onready var original_color = self_modulate
@export var scale_size = Vector2(0.1, 0.1)
@export var tile_map: TileMap
var tween

func _ready():
	hide()

func _input(event):
	if event is InputEventScreenTouch:
		position = get_global_mouse_position()
		animate_dissolve()

func animate_dissolve():
	# Kill if any tween are curently processing.
	if tween:
		tween.kill()
		_set_original_value()

	show()
	tween = create_tween()
	tween.parallel().tween_property(self, "scale", original_scale + scale_size, 0.5)
	tween.parallel().tween_property(self, "self_modulate", Color(original_color, 0), 1)
	tween.tween_callback(_on_animation_finish)

func _on_animation_finish():
	hide()
	_set_original_value()

func _set_original_value():
	scale = original_scale
	self_modulate = original_color 
