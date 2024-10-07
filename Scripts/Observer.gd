extends Node

signal roll_completed(dice_value)
signal roll_started
signal move_completed(player)
signal move_started
signal move_failed
signal next_turn
signal extra_turn
signal turn_started(player)
signal game_won
signal game_over(team)
signal invalid_move_attempted
signal actor_selected(actor)
signal actor_move_started(actor, step)
signal actor_move_completed(actor)
signal actor_captured(captured_actor, actor)
signal actor_completed(actor)
signal power_purchased(power)
signal coin_changed(player)
signal power_card_move(power)
signal power_used(power, actor)
signal power_activated(power, player, extra_data)
signal power_cooldown_finished(power, player_id)
signal power_expired(power, player_id)
