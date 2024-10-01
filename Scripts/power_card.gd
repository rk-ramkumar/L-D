extends Panel

@onready var power_texture = $MarginContainer/Panel/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/Panel/VBoxContainer/Panel/CardCount
@onready var animation_player = $AnimationPlayer

var count = 0
var data = {}
var picked
var parent

func _ready():
	parent = get_parent().get_owner()
	power_texture.texture = load(data.image)
	update_count(1)

func update_count(amount):
	count += amount
	if count > 1:
		card_count.text = "X"+str(count)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			select()
		if event.is_released():
			if picked:
				picked = false
				parent.PowerCardHolder.move_end()

	if event is InputEventScreenDrag:
		Observer.power_card_move.emit(data)
		_handle_drag(event)

func select():
	animation_player.play("select")

func _handle_drag(event):
	if !picked:
		picked = true
		parent.PowerCardHolder.move_start(data)
		print(count)
		update_count(-1)
	parent.PowerCardHolder.update_position()
