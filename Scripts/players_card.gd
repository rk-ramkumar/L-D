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
	Observer.actor_completed.connect(_on_actor_completed)
	Observer.power_used.connect(_on_power_used)
	Observer.power_added.connect(_on_power_added)
	Observer.power_expired.connect(_on_power_expired)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if selected:
				Observer.actor_selected.emit(null)
				deselect()
			else:
				if data.actor.movable:
					select()

func select():
	selected = true
	animation_player.play("select")
	data.parent.card_selected(self)
	Observer.actor_selected.emit(data.actor)
	data.actor.select(true)
	
func deselect():
	selected = false
	animation_player.play_backwards("select")
	data.actor.select(false)

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
	
func _on_power_expired(power, player_id):
	pass
