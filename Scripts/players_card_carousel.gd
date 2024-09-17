extends HBoxContainer

var card_scene = preload("res://Scenes/players_card.tscn")
@export var team = "L"

func _ready():
	for player in GameManager.Players.values():
		if player.team == team:
			var player_card = card_scene.instantiate()
			player_card.player = player
			add_child(player_card)
