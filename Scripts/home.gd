extends Control

var match_making = preload("res://Scenes/match_making.tscn")
@onready var animation_player = $AnimationPlayer
@onready var main_container = $MainContainer
@onready var profile_container = $ProfileContainer
@onready var profile_label = $ProfileContainer/CenterContainer/ProfileLabel
@onready var enter_button = $ProfileContainer/CenterContainer/EnterButton
@onready var button_container = $MainContainer/ButtonContainer
@onready var ai_arena_lobby = $AIArenaLobby

func _ready():
	var player_name = Profile.get_value("Player", "name")

	if player_name:
		main_container.visible = true
		main_container.modulate = Color.WHITE
		profile_container.visible = false
	else:
		main_container.visible = false
		profile_container.visible = true

func _on_play_button_clicked():
	ai_arena_lobby.visible = true
	button_container.visible = false

func _on_random_button_pressed():
	profile_label.text = RandomName.generate_name()

func _on_enter_button_clicked():
	var text = profile_label.text.dedent()
	if text.length() <= 0:
		MessageManager.add_message("Please enter a vaild name.")
		return
	Profile.set_value("Player", "name", profile_label.text)
	animation_player.play("enter_main")
