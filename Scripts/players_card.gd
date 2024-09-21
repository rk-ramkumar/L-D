extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label
@onready var animation_player = $AnimationPlayer

var actor_data = {}

func _ready():
	label.text = actor_data.get("name", "")
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			animation_player.play("select")
