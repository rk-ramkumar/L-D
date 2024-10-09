extends Node

var Players = {}
var player = {}
var actors_count = 6
var super_number = 13
var playerLoaded: int = 0
var availableId = [1, 2, 3, 4]
var teamList = { "L": {"actors": []}, "D": {"actors": []} }
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
var tile_map : TileMap
var playground
var extra_chance_dice = [1, 5, 6, 12]
var events = {
	"roll_completed": _on_roll_completed,
	"move_completed": _on_move_completed,
	"next_turn": _handle_next_turn,
	"extra_turn": _handle_extra_turn,
	"turn_started": _handle_turn_started,
	"roll_started": _handle_roll_started,
	"actor_move_completed": _on_roll_completed,
	"actor_completed": _on_actor_completed,
	"game_over": _on_game_over
}

func connect_signals():
	for event in events:
		if !Observer.is_connected(event, events[event]):
			Observer.connect(event, events[event])

func disconnect_signals():
	for event in events:
		if Observer.is_connected(event, events[event]):
			Observer[event].disconnect(events[event])

func _on_game_over(_team):
	Players.values().map(func(profile): profile.coin = 0)
	reset()
	
func reset_game_state():
	Players = {}
	playerLoaded = 0
	reset()

func get_opponent_team(team):
	return "L" if team == "D" else "D"

func reset():
	disconnect_signals()
	player = {}
	teamList = { "L": {"actors": []}, "D": {"actors": []} }
	currentPlayerTurn = 0
	tile_map = null
	playground = null

func register_resource(dict):
	tile_map = dict.tile_map
	playground = dict.playground
	connect_signals()
	PowersManager.connect_signals()

func _on_roll_completed(_die_value):
	Observer.coin_changed.emit(player)
	await get_tree().create_timer(0.1).timeout
	var actors = teamList[player.team].actors
	_set_movable(actors)
	if actors.any(func(actor): return actor.movable):
		Observer.move_started.emit()
	else:
		Observer.next_turn.emit()

func _on_move_completed(_player):
	Observer.next_turn.emit()

func _set_movable(actors):
	## Check for powers that stop movable
	for actor in actors:
		actor.movable = true

func _handle_actor_move_completed(actor, captured_actor):
	#Check for kill happen
	if captured_actor:
		var data = PowersManager.check_fortuna_shield(captured_actor, actor)
		Observer.actor_captured.emit(data[0], data[1])

func _on_actor_completed(actor):
	var team = actor.team
	teamList[team].actors.erase(actor)
	var complete_status = teamList[team].actors.is_empty()
	if complete_status:
		Observer.game_over.emit(team)

func _handle_next_turn():
	currentPlayerTurn = _get_next_id()
	player = Players[currentPlayerTurn]
	Observer.turn_started.emit(player)

func _handle_turn_started(_player):
	Observer.roll_started.emit()

func _handle_roll_started():
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
	Observer.turn_started.emit(player)

func _get_next_id():
	if playerLoaded == 0:
		return
	if !player.is_empty() and PowersManager.has_timewarp_power(player):
		return ((currentPlayerTurn + 1) % playerLoaded) + 1 # Skip next player turn

	return (currentPlayerTurn % playerLoaded) + 1

func increase_coin(amount):
	player.coin = player.coin + amount
	Observer.coin_changed.emit(player)

func decrease_coin(amount):
	player.coin = player.coin - amount
	Observer.coin_changed.emit(player)
 
func generate_ld(current_player):
	var effects = PowersManager.get_power_boosts(current_player)
	var coin_gained = randi_range(3, 6)
	current_player.coin = min(current_player.coin + coin_gained, super_number + effects.extra_space)
	current_player.coin += effects.extra_ld
	var half_coin = coin_gained / 2

	return [half_coin, coin_gained - half_coin]
