class_name NPCPlayer extends Node

var player = {}
var tile_map
var opponent_actors
var can_connect = true

# Weight factors for decision-making (higher means more important)
const WEIGHT_KILL_OPPONENT = 10
const WEIGHT_SAFE_TILE = 5
const WEIGHT_LAST_TILE = 20
const WEIGHT_MOVE_FROM_HOME = 15
const WEIGHT_NO_NEARBY_OPPONENTS = 3

# New weight factors for human-like behavior
const WEIGHT_RANDOM_FACTOR = 3  # Random bias
const RISKY_MOVE_CHANCE = 0.2   # 20% chance for risky moves
const FOCUS_SINGLE_ACTOR = 0.5  # 50% chance to focus on one actor

const PROXIMITY_THRESHOLD = 8


func _ready():
	connect_signals()
	randomize()
	opponent_actors = GameManager.teamList[GameManager.get_opponent_team(player.team)].actors

func connect_signals():
	if can_connect:
		Observer.move_started.connect(_handle_move_started)

func _handle_move_started():
	if player != GameManager.player:
		return
	await get_tree().create_timer(randf_range(1, 5)).timeout
	decide_and_move()

func decide_and_move(time_delay = 5):
	# Decide on whether to move multiple actors or focus on one
	var move_multiple = randf() > FOCUS_SINGLE_ACTOR

	if move_multiple:
		move_multiple_pieces()
	else:
		move_single_piece()
	await get_tree().create_timer(time_delay).timeout
	Observer.move_completed.emit(player)
	
# Moves multiple actors using available LD (coins)
func move_multiple_pieces():
	var selected_actors = pick_random_actors()  # Random selection of actors
	for actor in selected_actors:
		if player.coin <= 0:
			break
		var possible_moves = calculate_all_moves(actor)
		var chosen_move = evaluate_moves(possible_moves)
		if chosen_move:
			actor.start_moving({positions = chosen_move.blocks, step = chosen_move.steps, captured_actor = chosen_move.captured_actor})
			GameManager.decrease_coin(chosen_move.steps)

# Moves a single piece with human-like randomness
func move_single_piece():
	var selected_actor = pick_actor_with_randomness()  # Pick actor with less optimal logic
	if selected_actor:
		var possible_moves = calculate_all_moves(selected_actor)
		var chosen_move = evaluate_moves(possible_moves)
		if chosen_move:
			selected_actor.start_moving({positions = chosen_move.blocks, step = chosen_move.steps, captured_actor = chosen_move.captured_actor})
			GameManager.decrease_coin(chosen_move.steps)

# Randomly picks actors for multiple moves
func pick_random_actors():
	var actors = GameManager.teamList[player.team].actors.filter(func(actor): return actor.movable)
	actors.shuffle()
	return actors.slice(0, randi_range(1, actors.size()))

# Picks the actor, but adds some randomness for less optimal behavior
func pick_actor_with_randomness():
	var actors = GameManager.teamList[player.team].actors.filter(func(actor): return actor.movable)
	if actors.is_empty():
		return null

	var best_actor = null
	var highest_score = 0
	var opponent_positions = opponent_actors.map(func(opponent_actor): return opponent_actor.position_id)

	# Evaluate each actor's move but introduce random factors
	for actor in actors:
		var possible_moves = calculate_all_moves(actor)
		var chosen_move = evaluate_moves(possible_moves)

		if chosen_move:
			var score = calculate_actor_score(chosen_move.target_position, opponent_positions)

			# Add a random factor to the score to simulate human-like decisions
			score += randi() % WEIGHT_RANDOM_FACTOR

			# Sometimes, pick risky moves (ignore threats)
			if randf() < RISKY_MOVE_CHANCE:
				score -= WEIGHT_SAFE_TILE  # Ignore safe tiles, take risks

			# Select the actor with the highest (randomly influenced) score
			if score > highest_score:
				highest_score = score
				best_actor = actor
	
	return best_actor if best_actor else actors.pick_random()

# Calculate all possible moves based on the actor's current position and available LD (coins)
func calculate_all_moves(actor):
	var possible_moves = []
	var current_position = actor.position_id

	# Loop through all possible moves based on the available LD
	for step in range(1, player.coin + 1):
		var target_position = current_position + step
		var blocks = get_movement_path(actor, target_position)
		var captured_actor = tile_map.is_actor_present(target_position-1, GameManager.get_opponent_team(actor.team))
		possible_moves.append(
			{
				"blocks": blocks,
				"steps": step,
				"target_position": target_position,
				"captured_actor": captured_actor
			}
		)

	return possible_moves

# Get movement path from actor's current position to target
func get_movement_path(actor, target_position):
	var end = min(target_position, GameManager.max_tile_id)
	return tile_map.blocks.slice(actor.position_id, end).map(func(pos):
		return Vector2(pos.x, -pos.y if player.team == "D" else pos.y)
	)

# Evaluates all possible moves and picks the best one with some randomness
func evaluate_moves(possible_moves):
	var best_move = null
	var highest_score = 0

	for move in possible_moves:
		var score = calculate_move_score(move.target_position)

		# Add some randomness to the score
		score += randi() % WEIGHT_RANDOM_FACTOR

		# Sometimes, favor risky moves over safe ones
		if randf() < RISKY_MOVE_CHANCE:
			score -= WEIGHT_SAFE_TILE  # Risky move, ignore safe tiles

		# Select the move with the highest score
		if score > highest_score:
			highest_score = score
			best_move = move

	return best_move

# Calculate score for a particular move
func calculate_move_score(target_position):
	var score = 0

	# Priority: Reaching the last tile
	if target_position == GameManager.max_tile_id:
		return WEIGHT_LAST_TILE

	# Priority: Moving out of the starting position
	if target_position <= 7:
		score += WEIGHT_MOVE_FROM_HOME

	# Priority: Killing opponents
	if opponent_actors.any(func(opponent_actor): return opponent_actor.position_id == target_position):
		score += WEIGHT_KILL_OPPONENT

	# Priority: Safe tiles (checkpoints)
	if (target_position - 1) % 6 == 0:
		score += WEIGHT_SAFE_TILE

	# Add more weight for safer positions
	score += get_no_nearby_weightage(target_position)

	return score

# Evaluates how safe the target position is based on proximity to opponents
func get_no_nearby_weightage(target_position):
	var opponent_positions = opponent_actors.map(func(opponent_actor): return target_position - opponent_actor.position_id)
	var weightage = 0

	# If all opponents are behind, it's safer
	if opponent_positions.all(func(distance): return distance <= 0):
		weightage += WEIGHT_NO_NEARBY_OPPONENTS
	elif opponent_positions.all(func(distance): return distance > PROXIMITY_THRESHOLD):
		weightage += 2  # Moderately safe
	else:
		weightage += 1  # Less safe

	return weightage

# Calculate score for a particular actor based on potential move
func calculate_actor_score(target_position, opponent_positions):
	var score = 0

	# Higher score for being closer to the enemy
	if target_position in opponent_positions:
		score += WEIGHT_KILL_OPPONENT  # Add weight for potential kills

	# Higher score for reaching a checkpoint or safe tile
	if (target_position - 1) % 6 == 0:
		score += WEIGHT_SAFE_TILE

	# Reward for advancing towards final tile
	if target_position == GameManager.max_tile_id:
		score += WEIGHT_LAST_TILE
	
	# Penalize if moving into a heavily contested area
	var opponent_count = opponent_actors.reduce(func(acc, cur):
		if target_position <= 7:
			return acc
		if target_position - cur.position_id < PROXIMITY_THRESHOLD:
			acc += 1
		return acc,
		0)
	if opponent_count > 1:
		score -= opponent_count  # More opponents means a lower score

	return score
