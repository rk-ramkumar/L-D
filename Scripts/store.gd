extends CanvasLayer

var power_card = preload("res://Scenes/store_power_card.tscn")
@onready var grid_container = $HBoxContainer/CenterContainer/MarginContainer/GridContainer
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

func _on_buy_button_clicked():
	if selected_card == null:
		print("Select a card to purchase.")
		return
	if GameManager.player.coin < selected_card.data.base_price:
		print("Not have enough coin")
		return
	GameManager.decrease_coin(selected_card.data.base_price)
	AudioController.game_bonus.play()
	Observer.power_purchased.emit(selected_card.data)
