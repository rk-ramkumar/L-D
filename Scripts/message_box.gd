class_name MessageBox extends HBoxContainer

@onready var animation_player = $AnimationPlayer
@onready var rich_text_label = $VBoxContainer/Panel/MarginContainer/RichTextLabel

var colors = ["9958ff", "ffffff9e"]
func _ready():
	animation_player.play("RESET")
	Observer.turn_started.connect(_on_turn_started)
	Observer.roll_completed.connect(_on_roll_completed)
	Observer.actor_move_started.connect(_on_actor_move_started)
	Observer.actor_move_completed.connect(_on_actor_move_completed)
	Observer.actor_captured.connect(_on_actor_captured)
	Observer.extra_turn.connect(_on_extra_turn)
	Observer.game_won.connect(_on_game_won)

func _on_button_toggled(button_pressed):
	if button_pressed:
		animation_player.play("open")
	else:
		animation_player.play_backwards("open")


func _on_roll_completed(die_value):
	log_game_event("roll_completed", {
		player_name = get_user_name(),
		die_value = die_value
		}
	)

func _on_turn_started():
	log_game_event("turn_started", {
		player_name = get_user_name(),
		}
	)
	MessageManager.add_message(get_user_name() + "'s turn to play.")

func _on_actor_move_started(actor):
	log_game_event("actor_move_started", {
		player_name = get_user_name(),
		start_tile = actor.position_id,
		end_tile = actor.position_id + GameManager.currentDieNumber
		}
	)

func _on_actor_move_completed(actor):
	log_game_event("actor_move_completed", {
		player_name = get_user_name(),
		end_tile = actor.position_id
		}
	)

func _on_actor_captured(captured_actor, actor):
	log_game_event("actor_captured", {
		player_team = actor.team,
		captured_player_team = captured_actor.team
		}
	)

func _on_extra_turn():
	log_game_event("extra_turn", {
		player_name = get_user_name(),
		}
	)

func _on_game_won(team):
	log_game_event("game_won", {
		team_name = team
		}
	)

func get_user_name():
	return GameManager.player.name

# Appends the user's message with escaping.
# Remember to escape both the player name and message contents.
func append_chat_line_escaped(message):
	var msg = "> [color=%s]%s[/color]"
	# Add time
	rich_text_label.append_text("[font_size=%s][center][color=%s]%s[/color][/center][/font_size] \n" % [
		12,
		colors[1],
		Time.get_datetime_string_from_system(false, true)
		]
	) 
	rich_text_label.append_text(msg % [
		colors[0],
		message
		]
	)
	
# Appends game event info with proper sentences
func log_game_event(event_type, extra_info = {}):
	var event_text = ""
	
	match event_type:
		"turn_started":
			event_text = "{player_name}'s turn to play."
		"roll_completed":
			event_text = "{player_name} rolled a {die_value}."
		"actor_move_started":
			event_text = "{player_name} is moving the piece from tile {start_tile} to tile {end_tile}."
		"actor_move_completed":
			event_text = "{player_name}'s piece has reached tile {end_tile}."
		"actor_captured":
			event_text = "{captured_player_team} team's piece was captured by {player_team} team!"
		"extra_turn":
			event_text = "{player_name} has earned an extra turn!"
		"game_won":
			event_text = "Team {team_name} has won the game!"

	# Replace placeholders in the sentence with actual data
	event_text = event_text.format(extra_info)
	
	# Log the event to the chat
	append_chat_line_escaped(event_text)

