extends Panel

@onready var power_texture = $MarginContainer/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/VBoxContainer/Panel/CardCount
var count = 0
var data = {}

func _ready():
	power_texture.texture = load(data.image)
	update_count(1)

func update_count(amount):
	count += amount
	if count > 1:
		card_count.text = "X"+str(count)
