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
var end_check_powers = ["RelentlessMarch", "HermesDash"]

func _ready():
	Observer.turn_started.connect(_on_turn_started)
	Observer.move_completed.connect(_on_move_completed)
	Observer.power_activated.connect(_on_power_activated)

func _on_turn_started(player):
	_process_power_cooldowns(player)

func _on_move_completed(player):
	_handle_end_power_cooldowns(player)

func _on_power_activated(power, player, dict = {}):
	if !active_player_powers.has(player.id):
		active_player_powers[player.id] = []
	var new_power = power.duplicate(true)
	new_power.data = dict
	active_player_powers[player.id].append(new_power)
	print("Power Activated ", active_player_powers[player.id])

func _process_power_cooldowns(player):
	if !active_player_powers.has(player.id):
		return
	for player_id in active_player_powers.keys():
		for power in active_player_powers[player_id]:
			if power.id not in end_check_powers: 
				_adjust_power_cooldown(power, player_id)

func _handle_end_power_cooldowns(player):
	if !active_player_powers.has(player.id):
		return
	for player_id in active_player_powers.keys():
		for power in active_player_powers[player_id]:
			if power.id in end_check_powers: 
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
	if !active_player_powers.has(player.id):
		return false
	return active_player_powers[player.id].any(func(power): return power.id == "TimeWarp")

func has_active_power(power_id, player_id):
	if !active_player_powers.has(player_id):
		return false
	return active_player_powers[player_id].any(func(power): return power.id == power_id)
