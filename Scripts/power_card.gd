extends Panel

@onready var power_texture = $MarginContainer/Panel/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/Panel/VBoxContainer/BackgroundPanel/CardCount
@onready var animation_player = $AnimationPlayer
@onready var panel = $MarginContainer/Panel

var bg = {
	player =  preload("res://Assets/Resources/player_power_card.tres"),
	actor = preload("res://Assets/Resources/store_card_background.tres")
}
var count = 0
var data = {}
var picked
var parent
var selected = false

func _ready():
	parent = get_parent().get_owner()
	add_theme_stylebox_override("panel", get_theme_stylebox("panel").duplicate())
	panel.add_theme_stylebox_override("panel", bg[data.used_on])
	power_texture.texture = load(data.image)
	power_texture.material = power_texture.material.duplicate()
	update_count(1)

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
				deselect()
			else:
				select()
		if event.is_released():
			_handle_drag_end(event)

	if event is InputEventScreenDrag:
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

func _handle_drag(_event):
	if !picked:
		picked = true
		parent.PowerCardHolder.move_start(data)
		update_count(-1)
	parent.PowerCardHolder.update_position()

func _handle_drag_end(_event):
	if picked:
		picked = false
		# Check for any actor selected.
		if !parent.PowerCardHolder.is_accept(data):
			update_count(1)
		# Remove card
		if count == 0:
			parent.add_empty_card(1)
			remove_card()
		parent.PowerCardHolder.move_end()

func remove_card():
	var tween = create_tween()
	tween.tween_method(dissolve_card, 0.0, 1.0, 1)
	tween.tween_callback(func():
		parent.remove_power_card(data)
		tween.kill()
		queue_free()
	)

func dissolve_card(value):
	power_texture.material.set_shader_parameter("dissolve_amount", value)
