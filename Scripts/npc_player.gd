class_name NPCPlayer extends Node

var player = {}
var tile_map

func _ready():
	connect_signals()

func connect_signals():
	Observer.turn_started.connect(_handle_turn_started)
	Observer.move_started.connect(_handle_move_started)

func _handle_turn_started():
	if player.id != GameManager.currentPlayerTurn:
		return

	await get_tree().create_timer(randf_range(1, 5)).timeout
	Observer.roll_started.emit()

func _handle_move_started():
	if player.id != GameManager.currentPlayerTurn:
		print(player.id)
		return

	var selected_actor = pick_actor()
	await get_tree().create_timer(randf_range(1, 5)).timeout
	selected_actor.start_moving(tile_map.blocks.slice(selected_actor.position_id))
	GameManager.one_more = _has_one_more()

func _has_one_more():
	if GameManager.currentDieNumber == 1:
		return true
	var position_id = GameManager.selected_actor.position_id
	var opponent_actors = tile_map.is_actor_present(
		position_id,
		GameManager.get_opponent_team(GameManager.selected_actor.data.team)
	)

	if opponent_actors:
		opponent_actors.front().start_moving_home()
		return true

	return false

func pick_actor():
	var actors = GameManager.teamList[player.team].actors.filter(func(actor): return actor.movable)
	var opponent_actors = GameManager.teamList[GameManager.get_opponent_team(player.team)].actors
	var selected_actor
	var max_weightage = 0
	for actor in actors:
		var current_weightage = 0
		var target_id = actor.position_id + GameManager.currentDieNumber
		# Priority to last tile actor
		if actor.position_id == GameManager.max_tile_id - 1 and target_id == GameManager.max_tile_id:
			selected_actor = actor
			break

		# Priority to home lane actors
		if target_id <= 7 and !tile_map.is_actor_present(target_id, player.team):
			selected_actor = actor
			break

		# Kill check
		if opponent_actors.any(func(opponent_actor): 
			return opponent_actor.position_id == target_id
		):
			# No nearyby actor check
			current_weightage += get_no_nearby_weightage(opponent_actors, target_id)

		# Safe tile check
		if (target_id - 1) % 6 == 0:
			current_weightage += 1
		
		current_weightage += get_no_nearby_weightage(opponent_actors, target_id)
		
		if max_weightage < current_weightage:
			max_weightage = current_weightage
			selected_actor = actor
	
	return actors.pick_random() if !selected_actor else selected_actor

func get_no_nearby_weightage(opponent_actors, target_id):
	var opponent_positions = opponent_actors.map(func(opponent_actor): return target_id - opponent_actor)
	var weightage = 0
	if opponent_positions.all(func(id): return id <= 0):
		weightage += 3
	elif opponent_positions.all(func(id): return id > 8):
		weightage += 2
	else:
		weightage += 1
	
	return weightage
