extends Panel

var card_scene = preload("res://Scenes/players_card.tscn")
@onready var cards_container = $ScrollContainer/MarginContainer/CardsContainer

@export var actors = []
@export var playground: Node

func _ready():
	await playground.ready
	for actor in actors:
		var player_card = card_scene.instantiate()
		player_card.actor_data = {
			"name": actor.name
		}
		cards_container.add_child(player_card)
