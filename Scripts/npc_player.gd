class_name NPCPlayer extends Node

var player = {}
var tile_map

# Weight factors for decision-making (higher means more important)
const WEIGHT_KILL_OPPONENT = 10
const WEIGHT_SAFE_TILE = 5
const WEIGHT_LAST_TILE = 20
const WEIGHT_MOVE_FROM_HOME = 15
const WEIGHT_NO_NEARBY_OPPONENTS = 3

func _ready():
	connect_signals()

func connect_signals():
	Observer.turn_started.connect(_handle_turn_started)
	Observer.move_started.connect(_handle_move_started)

func _handle_turn_started():
	if player != GameManager.player:
		return
	
	await get_tree().create_timer(randf_range(1, 5)).timeout
	Observer.roll_started.emit()

func _handle_move_started():
	if player != GameManager.player:
		return

	# Heuristic-based decision-making
	var selected_actor = pick_best_actor()
	if selected_actor:
		await get_tree().create_timer(1).timeout
		var blocks = get_movement_path(selected_actor)
		selected_actor.start_moving(blocks)

# Returns the best actor based on heuristic scoring
func pick_best_actor():
	var actors = GameManager.teamList[player.team].actors.filter(func(actor): return actor.movable)
	if actors.is_empty():
		return null

	var opponent_actors = GameManager.teamList[GameManager.get_opponent_team(player.team)].actors
	var best_actor = null
	var highest_score = 0

	# Evaluate each actor's move based on heuristic scoring
	for actor in actors:
		var target_id = actor.position_id + GameManager.currentDieNumber
		var score = calculate_actor_score(actor, target_id, opponent_actors)

		# Select the actor with the highest score
		if score > highest_score:
			highest_score = score
			best_actor = actor
	
	# Fallback to random actor if no strong candidate
	return best_actor if best_actor else actors.pick_random()

# Returns the path of movement for the selected actor
func get_movement_path(actor):
	return tile_map.blocks.slice(actor.position_id).map(func(pos):
		return Vector2(pos.x, -pos.y if player.team == "D" else pos.y)
	)

# Calculates the score for each actor based on various heuristics
func calculate_actor_score(actor, target_id, opponent_actors):
	var score = 0

	# Highest priority: Actor is about to win (last tile)
	if actor.position_id == GameManager.max_tile_id - 1 and target_id == GameManager.max_tile_id:
		return WEIGHT_LAST_TILE

	# High priority: Moving out from home (die roll 1)
	if GameManager.currentDieNumber == 1 and target_id <= 7 and !tile_map.is_actor_present(target_id, player.team):
		return WEIGHT_MOVE_FROM_HOME

	# General move: On-field actors, checking safety and threats
	if actor.current_state == GameManager.player_state.ON_FIELD and target_id > 7:
		# Kill check (opponent on target tile)
		if opponent_actors.any(func(opponent_actor):
			return opponent_actor.position_id == target_id
		):
			score += WEIGHT_KILL_OPPONENT  # Bonus for killing opponent

		# Safe tile check (tiles like checkpoints or safe zones)
		if (target_id - 1) % 6 == 0:
			score += WEIGHT_SAFE_TILE  # Bonus for landing on a safe tile

		# No nearby opponent check (safer positions)
		score += get_no_nearby_weightage(opponent_actors, target_id)

	return score

# Evaluates the proximity of opponents and adjusts score accordingly
func get_no_nearby_weightage(opponent_actors, target_id):
	var opponent_positions = opponent_actors.map(func(opponent_actor): return target_id - opponent_actor.position_id)
	var weightage = 0

	if opponent_positions.all(func(distance): return distance <= 0):
		weightage += WEIGHT_NO_NEARBY_OPPONENTS  # Bonus for safer moves
	elif opponent_positions.all(func(distance): return distance > 8):
		weightage += 2  # Moderately safe
	else:
		weightage += 1  # Less safe

	return weightage
