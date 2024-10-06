extends Node

var json_data = preload("res://Assets/data.json").data
var card_backgrounds = {
	player =  preload("res://Assets/Resources/player_power_card.tres"),
	actor = preload("res://Assets/Resources/store_card_background.tres")
}
var active_player_powers = {}
var player_power_effects = {
	"ZeusFavor": {
		"extra_ld": 4
	},
	"AetherBlessing": {
		"extra_space": 3
	}
}
var move_based_powers = ["RelentlessMarch", "HermesDash"]
var turn_based_powers = ["TimeWarp", "ZeusFavor", "AetherBlessing", "SanctuarySeal", "FortunaShield"]

func _ready():
	Observer.turn_started.connect(_on_turn_started)
	Observer.move_completed.connect(_on_move_completed)
	Observer.power_activated.connect(_on_power_activated)

func _on_turn_started(player):
	_process_power_cooldowns(player, turn_based_powers)

func _on_move_completed(player):
	_process_power_cooldowns(player, move_based_powers)

func _on_power_activated(power, player, dict = {}):
	if !active_player_powers.has(player.id):
		active_player_powers[player.id] = []
	var new_power = power.duplicate(true)
	new_power.data = dict
	active_player_powers[player.id].append(new_power)
	print("Power Activated ", active_player_powers[player.id])

func _process_power_cooldowns(player, list):
	if !active_player_powers.has(player.id):
		return
	for player_id in active_player_powers.keys():
		for power in active_player_powers[player_id]:
			if power.id in list: 
				_adjust_power_cooldown(power, player_id)

func _adjust_power_cooldown(power, player_id):
	power.cooldown -= 1
	power.expiry -= 1

	if power.cooldown == 0:
		Observer.power_cooldown_finished.emit(power, player_id)
		active_player_powers[player_id].erase(power)
		prints("cooldown finished ", active_player_powers[player_id])
	elif power.expiry == 0:
		Observer.power_expired.emit(power, player_id)
		print("Power expired")

func has_active_power(power_id, player_id):
	if !active_player_powers.has(player_id):
		return false
	return active_player_powers[player_id].any(func(power): return power.id == power_id)

func get_power_boosts(player):
	var res = {
		"extra_ld": 0,
		"extra_space": 0
	}
	if !active_player_powers.has(player.id):
		return res

	var filtered_active_player_powers = active_player_powers[player.id].filter(func(power): 
		return power.id == "AetherBlessing" or power.id == "ZeusFavor"
	)

	if filtered_active_player_powers.is_empty():
		return res

	for power in filtered_active_player_powers:
		if power.expiry == 0:
			continue
		
		res.merge(player_power_effects[power.id], true)

	return res

func has_timewarp_power(player):
	return _is_active_power(player.id, "TimeWarp")

func check_fortuna_shield(captured_actor, actor):
	if !captured_actor.power.is_empty():
		if actor.power.is_empty(): # "FortunaSheild: Reverse an opponent's capture attempt and capture their piece instead."
			if captured_actor.power.id == "FortunaShield": # Check whether captured_actor have FortunaSheild power
				Observer.power_used.emit(captured_actor.power, captured_actor)
				return [actor, captured_actor]
		else:
			if captured_actor.power.id == "FortunaShield" and actor.power.id == "FortunaShield": # Check whether both actor have FortunaSheild power
				Observer.power_used.emit(actor.power, actor)

	return [captured_actor, actor]

func _is_active_power(player_id, power_id):
	if !active_player_powers.has(player_id):
		return false
	return active_player_powers[player_id].any(func(power): return power.id == power_id)
