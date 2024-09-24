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

func get_opponent_team(team):
	return "L" if team == "D" else "D"

func _ready():
	Observer.roll_completed.connect(_on_roll_completed)

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

func _set_movable(actors):
	## Check for powers that stop movable
	for actor in actors:
		actor.movable = true
		if (actor.position_id + currentDieNumber > max_tile_id
			or (actor.current_state == player_state.HOME and currentDieNumber != 1)
		):
			actor.movable = false
