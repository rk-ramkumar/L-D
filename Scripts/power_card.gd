extends Panel

@onready var power_texture = $MarginContainer/Panel/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/Panel/VBoxContainer/BackgroundPanel/CardCount
@onready var animation_player = $AnimationPlayer
@onready var panel = $MarginContainer/Panel

var count = 0
var data = {}
var picked
var parent
var selected = false

func _ready():
	parent = get_parent().get_owner()
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())
	panel.add_theme_stylebox_override("panel", PowersManager.card_backgrounds[data.used_on])
	power_texture.texture = load(data.image)
	power_texture.material = power_texture.material.duplicate()
	update_count(1)
	Observer.power_cooldown_finished.connect(_on_power_cooldown_finished)
	Observer.power_activated.connect(_on_power_activated)
	if PowersManager.has_active_power(data.id, parent.playground.player.id):
		_on_cooldown()

func update_count(amount):
	count += amount
	if count > 1:
		card_count.text = "X"+str(count)
	elif count == 1:
		card_count.text = ""

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if selected:
				_handle_double_tap(event)
			else:
				select()
		if event.is_released():
			_handle_drag_end(event)
	

	if event is InputEventScreenDrag:
		if data.used_on == "player":
			MessageManager.add_info("Double tap to activate.")
			return
		Observer.power_card_move.emit(data)
		_handle_drag(event)

func select():
	selected = true
	animation_player.play("select")
	deselectOtherCard()

func deselect():
	selected = false
	animation_player.play_backwards("select")

func deselectOtherCard():
	for card in parent.power_cards.values():
		if card.card != self and card.card.selected:
			card.card.deselect()

func _handle_double_tap(event):
	if data.used_on == "player" and event.double_tap:
		if PowersManager.has_active_power(data.id, parent.playground.player.id):
			print("In Cooldown")
			return
		Observer.power_activated.emit(data, parent.playground.player)
		update_count(-1)
		# Remove card
		if count == 0:
			parent.add_empty_card(1)
			remove_card()
	else:
		deselect()

func _handle_drag(_event):
	if PowersManager.has_active_power(data.id, parent.playground.player.id):
		print("In Cooldown")
		return

	if !picked:
		picked = true
		parent.PowerCardHolder.move_start(data)
		update_count(-1)
		animation_player.play_backwards("select")
		await animation_player.animation_finished
		animation_player.play("drag")
	parent.PowerCardHolder.update_position()

func _handle_drag_end(_event):
	if picked:
		picked = false
		animation_player.play_backwards("drag")
		# Check for any actor selected.
		if !parent.PowerCardHolder.is_accept(data):
			update_count(1)
		# Remove card
		if count == 0:
			parent.add_empty_card(1)
			remove_card()
		parent.PowerCardHolder.move_end()

func remove_card():
	if gui_input.is_connected(_on_gui_input):
		gui_input.disconnect(_on_gui_input)
	var tween = create_tween()
	tween.tween_method(dissolve_card, 0.0, 1.0, 1)
	tween.tween_callback(func():
		parent.remove_power_card(data)
		tween.kill()
		queue_free()
	)

func dissolve_card(value):
	power_texture.material.set_shader_parameter("dissolve_amount", value)

func _on_power_cooldown_finished(power, _player_id):
	if power.id == data.id:
		gui_input.connect(_on_gui_input)
		animation_player.play_backwards("cooldown")

func _on_power_activated(power, _player, _dist={}):
	if power.id == data.id:
		_on_cooldown()
	
func _on_cooldown():
	gui_input.disconnect(_on_gui_input)
	animation_player.play("cooldown")
