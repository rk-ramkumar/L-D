extends CanvasLayer

@onready var card_container = $Control/ScrollContainer/MarginContainer/CardContainer

var card_scene = preload("res://Scenes/power_details_card.tscn")

func _ready():
	for power in PowersManager.json_data.powers:
		var card = card_scene.instantiate()
		card.data = power
		card_container.add_child(card)
