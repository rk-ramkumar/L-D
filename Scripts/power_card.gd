extends Panel

@onready var power_texture = $MarginContainer/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/VBoxContainer/Panel/CardCount
@onready var animation_player = $AnimationPlayer

var count = 0
var data = {}
var picked
var UI

func _ready():
	UI = get_parent().get_owner().get_owner()
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
				picked.queue_free()

	if event is InputEventScreenDrag:
		if !picked:
			picked = duplicate(true)
			UI.add_child(picked)
		picked.position = event.position

func select():
	animation_player.play("select")
