extends Panel

@onready var cards_container = $ScrollContainer/MarginContainer/CardsContainer

@export var actors = []
@export var playground: Node

var cards = []
var card_scene = preload("res://Scenes/players_card.tscn")

func _ready():
	await playground.ready
	for actor in actors:
		var player_card = card_scene.instantiate()
		player_card.data = {
			"actor_name": actor.name,
			"parent" : self,
			"actor": actor
		}
		cards_container.add_child(player_card)
		cards.append(player_card)

func card_selected(selected_card):
	for card in cards:
		if card == selected_card:
			continue
		
		card.reset_animation()
