extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label
@onready var animation_player = $AnimationPlayer

var data = {}
var selected = false

func _ready():
	label.text = data.get("actor_name", "")
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if selected:
				GameManager.selected_actor = null
				deselect()
			else:
				select()

func select():
	selected = true
	animation_player.play("select")
	GameManager.selected_actor = data.actor
	data.parent.card_selected(self)
	Observer.actor_selected.emit(data.actor)
	
func deselect():
	selected = false
	animation_player.play_backwards("select")
