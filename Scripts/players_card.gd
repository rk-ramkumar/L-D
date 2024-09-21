extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label
@onready var animation_player = $AnimationPlayer

var data = {}

func _ready():
	label.text = data.get("actor_name", "")
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			animation_player.play("select")
			data.parent.card_selected(self)
			Observer.actor_selected.emit(data.actor)

func reset_animation():
	animation_player.play("RESET")
