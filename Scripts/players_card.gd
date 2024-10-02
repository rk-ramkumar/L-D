extends Panel

@onready var label = $Label
@onready var animation_player = $AnimationPlayer
@onready var power_texture = $BackgroundPanel/Panel/PowerTexture

var data = {}
var selected = false
var is_moving = false

func _ready():
	label.text = data.get("actor_name", "")
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)
	Observer.move_started.connect(_on_move_started)
	Observer.actor_completed.connect(_on_actor_completed)
	Observer.power_used.connect(_on_power_used)
	Observer.power_added.connect(_on_power_added)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if selected:
				GameManager.selected_actor = null
				deselect()
			else:
				if data.actor.movable:
					select()
				else:
					print("Need die value 1 to move actor.")

func select():
	selected = true
	animation_player.play("select")
	GameManager.selected_actor = data.actor
	data.parent.card_selected(self)
	Observer.actor_selected.emit(data.actor)
	data.actor.select(true)
	
func deselect():
	selected = false
	animation_player.play_backwards("select")
	data.actor.select(false)

func _on_move_started():
	if GameManager.selected_actor:
		Observer.actor_selected.emit(data.actor)

func _on_actor_completed(actor):
	if data.actor == actor:
		animation_player.play("completed")
		gui_input.disconnect(_on_gui_input)

func _on_power_used(_power, actor):
	if actor == data.actor:
		power_texture.texture = null

func _on_power_added(power, actor):
	if actor == data.actor:
		power_texture.texture = load(power.image)
	
