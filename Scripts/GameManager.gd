extends Node

@onready var game_start_time = Time.get_ticks_msec()
var scene_paths = {
	"Playground": "res://Scenes/2D/play_ground.tscn",
	"MatchMaking": "res://Scenes/match_making.tscn",
	"AIArenaLobby": "res://Scenes/ai_arena_lobby.tscn",
	"Home": "res://Scenes/home.tscn"
}
var Players = {}
var player = {}
var actors_count = 6
var super_number = 13
var playerLoaded: int = 0
var availableId = [1, 2, 3, 4]
var teamList = { "L": {"actors": []}, "D": {"actors": []} }
var gameOver: bool = false
var max_tile_id = 80
var currentPlayerTurn: int = 0
var currentDieNumber: int :
	get:
		return currentDieNumber
	set(newNumber):
		if newNumber == 0:
			currentDieNumber = 12
		else:
			currentDieNumber = newNumber
enum player_state {
	AT_HOME,
	ON_FIELD,
	CAPTURED,
	COMPLETED
}
var selected_actor
var tile_map : TileMap
var playground
var extra_chance_dice = [1, 5, 6, 12]
var loading_scene = preload("res://Scenes/loading.tscn")

func get_opponent_team(team):
	return "L" if team == "D" else "D"

func _ready():
	connect_signals()

func reset():
	Players = {}
	player = {}
	actors_count = 6
	playerLoaded = 0
	availableId = [1,2, 3, 4]
	teamList = { "L": {"actors": []}, "D": {"actors": []} }
	gameOver = false
	max_tile_id = 80
	currentPlayerTurn = 0
	selected_actor = null
	tile_map = null
	playground = null

func load_scene(resource, _current_scene):
	var loading = GameManager.loading_scene.instantiate()
	loading.add_resource_name(resource)
	get_tree().root.add_child(loading)

func connect_signals():
	Observer.roll_completed.connect(_on_roll_completed)
	Observer.move_failed.connect(_on_move_failed)
	Observer.next_turn.connect(_handle_next_turn)
	Observer.extra_turn.connect(_handle_extra_turn)
	Observer.turn_started.connect(_handle_turn_started)
	Observer.roll_started.connect(_handle_roll_started)
	Observer.actor_move_completed.connect(_handle_actor_move_completed)

func register_resource(dict):
	tile_map = dict.tile_map
	playground = dict.playground

func _on_roll_completed(_die_value):
	Observer.coin_changed.emit(player)
	await get_tree().create_timer(0.1).timeout
	var actors = teamList[player.team].actors
	_set_movable(actors)
	if actors.any(func(actor): return actor.movable):
		Observer.move_started.emit()
	else:
		Observer.next_turn.emit()

func _on_move_failed():
	var actor = teamList[player.team].actors.filter(func(actor): return actor.movable).pick_random()
	var blocks = tile_map.blocks.slice(actor.position_id)
	actor.start_moving(blocks)

func _set_movable(actors):
	## Check for powers that stop movable
	for actor in actors:
		actor.movable = true
		if (actor.position_id + currentDieNumber > max_tile_id
			or actor.has_recent_capture
		):
			actor.movable = false

func _handle_actor_move_completed(actor):
	Observer.move_completed.emit()

	var captured_actor = tile_map.is_actor_present(
		actor.position_id,
		get_opponent_team(actor.team)
	)
	#Check for kill happen
	if captured_actor:
		Observer.actor_captured.emit(captured_actor, actor)
		return

	Observer.next_turn.emit()

func _handle_next_turn():
	currentPlayerTurn = _get_next_id()
	player = Players[currentPlayerTurn]
	Observer.turn_started.emit()

func _handle_turn_started():
	Observer.roll_started.emit()

func _handle_roll_started():
	playground.dice.map(func(die): die.visible = true)
	var numbers = generate_ld(player)
	for idx in playground.dice.size():
		playground.dice[idx].number = numbers[idx]

func has_extra_turn():
	var actors = teamList[player.team].actors
	if actors.any(func(actor): return actor.current_state != player_state.AT_HOME):
		return currentDieNumber in extra_chance_dice
	#Give extra chance when put 1
	return currentDieNumber == 1

func _handle_extra_turn():
	Observer.turn_started.emit()

func _get_next_id():
	return (currentPlayerTurn % playerLoaded) + 1

func increase_coin(amount):
	player.coin = player.coin + amount
	Observer.coin_changed.emit(player)

func decrease_coin(amount):
	player.coin = player.coin - amount
	Observer.coin_changed.emit(player)
 
func generate_ld(current_player):
	var coin_gained = randi_range(3, 6) 
	current_player.coin = min(current_player.coin + coin_gained, super_number)
	var half_coin = coin_gained / 2

	return [half_coin, coin_gained - half_coin]
