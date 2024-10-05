extends Node2D

@onready var ui = $CanvasLayer/UI
@onready var tile_map = $TileMap
@onready var dice = [$TopLevelProps/Die1, $TopLevelProps/Die2]
@onready var actors_parent = $TopLevelProps/Actors
@onready var players_card_carousel = $CanvasLayer/UI/HBoxContainer/PlayersCardCarousel
@onready var target_position_indicator = $TopLevelProps/TargetPositionIndicator

var dice_numbers = []
var actor_scene = preload("res://Scenes/2D/blackNoir.tscn")
var player = {}
var selected_actor

func _ready():
	player = GameManager.Players[1]
	GameManager.register_resource({
		tile_map = tile_map,
		playground = self
	})
	AudioController.secondary_background.play()
	_add_npc_players()
	_add_actors()
	_connect_signals()
	await get_tree().create_timer(2).timeout
	Observer.next_turn.emit()

func _connect_signals():
	Observer.move_started.connect(_on_move_started)
	Observer.actor_selected.connect(_on_actor_selected)

func _on_move_started():
	if GameManager.player.id == player.id:
		tile_map.can_move = true
		ui.set_turn_over_btn_disable(false)

func _on_actor_selected(actor):
	selected_actor = actor
	target_position_indicator.handle_actor_selected(selected_actor)

func _add_npc_players():
	for Player in GameManager.Players.values():
		if Player.type != "npc":
			continue
		var npcPlayer = NPCPlayer.new()
		npcPlayer.player = Player
		npcPlayer.tile_map = tile_map
		add_child(npcPlayer)

func _add_actors():
	var player_args ={
		positions = tile_map.get_spawn_position(),
		team = player.team
	}
	var opponent_args ={
		positions = tile_map.get_spawn_position(true),
		team = GameManager.get_opponent_team(player.team)
	}

	for args in [player_args, opponent_args]:
		var actors = range(GameManager.actors_count).map(func(id): return _create_actors(args, id+1))
		if args == player_args:
			players_card_carousel.actors = actors

func _create_actors(args, id):
	var actor = actor_scene.instantiate()
	actor.name = "Actor_{team}_{id}".format({team = args.team, id = id})
	actor.data = args
	actor.tile_map = tile_map
	actor.modulate = args.get("color", Color.WHITE)
	GameManager.teamList[args.team].actors.append(actor)
	actors_parent.add_child(actor)
	return actor

func _on_die_rolled(number):
	dice_numbers.append(number)
	if dice_numbers.size() == 2:
		GameManager.currentDieNumber = dice_numbers.reduce(func(acc, cur): return acc+cur, 0)
		Observer.roll_completed.emit(GameManager.currentDieNumber)
		dice_numbers = []

func _on_turn_over_button_clicked():
	Observer.move_completed.emit()
	ui.set_turn_over_btn_disable(true)
	tile_map.can_move = false
