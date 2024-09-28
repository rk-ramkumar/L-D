extends CanvasLayer

var power_card = preload("res://Scenes/store_power_card.tscn")
@onready var grid_container = $Control/CenterContainer/MarginContainer/GridContainer
var selected_card = null

func _ready():
	for power in PowersManager.json_data.powers:
		var card = power_card.instantiate()
		card.data = power
		card.parent = self
		grid_container.add_child(card)

func card_selected(card):
	selected_card = card
	for child in grid_container.get_children():
		if child == selected_card:
				continue
		if child.selected:
			child.deselect()
