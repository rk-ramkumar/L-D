extends Panel

@onready var cards_container = $ScrollContainer/MarginContainer/CardsContainer

@export var actors = []
@export var playground: Node

var cards = []
var card_scene = preload("res://Scenes/players_card.tscn")
var empty_card_texture = preload("res://Assets/empty_card.png")

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
	if cards_container.get_child_count() < 13:
		add_empty_card(13 - cards_container.get_child_count())

func card_selected(selected_card):
	for card in cards:
		if card == selected_card:
			continue
		if card.selected:
			card.deselect()

func add_empty_card(number):
	for i in number:
		cards_container.add_child(create_empty_card())

func create_empty_card():
	var texture_rect = TextureRect.new()
	texture_rect.texture = empty_card_texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(100, 100)
	
	return texture_rect
