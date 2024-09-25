extends Node

@onready var game_start_time = Time.get_ticks_msec()
var scene_paths = {
	"Playground": "res://Scenes/2D/play_ground.tscn",
	"ExitPopup": "res://Scenes/exit_popup.tscn",
	"MatchMaking": "res://Scenes/match_making.tscn",
	"AIArenaLobby": "res://Scenes/ai_arena_lobby.tscn",
	"Home": "res://Scenes/home.tscn"
}
var Players = {}
var player = {}
var actors_count = 6
var playerLoaded: int = 0
var availableId = [1,2, 3, 4]
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
	HOME,
	FIELD,
	KILLED
}
var selected_actor
var tile_map : TileMap
var playground
var extra_chance_dice = [1, 5, 6, 12]

func get_opponent_team(team):
	return "L" if team == "D" else "D"

func _ready():
	connect_signals()

func connect_signals():
	Observer.roll_completed.connect(_on_roll_completed)
	Observer.roll_failed.connect(_on_roll_failed)
	Observer.move_failed.connect(_on_move_failed)
	Observer.next_turn.connect(_handle_next_turn)
	Observer.extra_turn.connect(_handle_extra_turn)
	Observer.actor_move_completed.connect(_handle_actor_move_completed)

func register_resource(dict):
	tile_map = dict.tile_map
	playground = dict.playground

func _on_roll_completed(die_value):
	var actors = teamList[Players[currentPlayerTurn].team].actors
	var is_all_home = actors.all(func(actor): return actor.current_state == player_state.HOME)

	if is_all_home and die_value != 1:
		Observer.next_turn.emit()
		return

	_set_movable(actors)
	if actors.any(func(actor): return actor.movable):
		Observer.move_started.emit()
	else:
		Observer.next_turn.emit()

func _on_roll_failed():
	GameManager.currentDieNumber = randi() % 7 #Randomly set die value
	Observer.roll_completed.emit(GameManager.currentDieNumber)

func _on_move_failed():
	var actor = teamList[
		Players[currentPlayerTurn].team
	].actors.filter(func(actor): return actor.movable).pick_random()
	var blocks = tile_map.blocks.slice(actor.position_id)
	actor.start_moving(blocks)

func _set_movable(actors):
	## Check for powers that stop movable
	for actor in actors:
		actor.movable = true
		if (actor.position_id + currentDieNumber > max_tile_id
			or (actor.current_state == player_state.HOME and currentDieNumber != 1)
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
		captured_actor.start_moving_home()
		Observer.extra_turn.emit()
		return

	if has_extra_turn():
		Observer.extra_turn.emit()
	else:
		Observer.next_turn.emit()

func _handle_next_turn():
	currentPlayerTurn = _get_next_id()
	Observer.turn_started.emit()

func has_extra_turn():
	var actors = teamList[Players[currentPlayerTurn].team].actors
	if actors.any(func(actor): return actor.current_state != player_state.HOME):
		return currentDieNumber in extra_chance_dice
	#Give extra chance when put 1
	return currentDieNumber == 1

func _handle_extra_turn():
	Observer.turn_started.emit()

func _get_next_id():
	return (currentPlayerTurn % playerLoaded) + 1
