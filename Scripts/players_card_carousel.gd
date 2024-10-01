extends ScrollContainer

@onready var cards_container = $MarginContainer/CardsContainer

@export var actors = []
@export var playground: Node
@export var PowerCardHolder: Node2D

var cards = []
var card_scene = preload("res://Scenes/players_card.tscn")
var empty_card_texture = preload("res://Assets/empty_card.png")
var power_card_scene = preload("res://Scenes/power_card.tscn")
var power_cards = {}

func _ready():
	Observer.power_purchased.connect(_on_power_purchased)
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
		cards_container.add_child(create_empty_card(i))

func create_empty_card(i):
	var texture_rect = TextureRect.new()
	texture_rect.name = "EmptyCard_"+str(i)
	texture_rect.texture = empty_card_texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.custom_minimum_size = Vector2(100, 100)
	
	return texture_rect

func _on_power_purchased(power):
	if power_cards.has(power.name):
		power_cards[power.name].card.update_count(1)
		return
	power_cards[power.name] = power
	power_cards[power.name].merge(_add_power_card(power))

func _add_power_card(power):
	var power_card = power_card_scene.instantiate()
	power_card.data = power
	var empty_card = cards_container.find_child("EmptyCard_*", true, false)
	var card_index = empty_card.get_index()
	empty_card.queue_free()
	cards_container.add_child(power_card)
	cards_container.move_child(power_card, card_index)
	
	return {index = card_index, card = power_card}
