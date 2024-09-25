extends Control

@onready var popup = $ModeSelectPopup
@onready var mode_select_button = $VBoxContainer/ModeSelectButton
@onready var v_box_container = $HBoxContainer/LeftBoxContainer/VBoxContainer/ProfilePanel
@onready var containers = [$HBoxContainer/RightBoxContainer/VBoxContainer, $HBoxContainer/LeftBoxContainer/VBoxContainer]

var main_scene = preload("res://Scenes/loading.tscn")

var player_loaded = 0
var character_icon = preload("res://Assets/Icons/character.svg")
var current_mode: String: 
	set(newMode):
		current_mode = newMode
		mode_select_button.text = current_mode
		_update_container()

func _ready():
	v_box_container.set_meta("profile", Profile.player)
	current_mode = "Solo"
	_on_viewport_changed()
	get_viewport().size_changed.connect(_on_viewport_changed)

func _on_solo_mode_button_clicked():
	current_mode = "Solo"
	popup.visible = false

func _on_duo_mode_button_clicked():
	current_mode = "Duo"
	popup.visible = false

func _on_mode_select_button_clicked():
	popup.visible = true

func _on_viewport_changed():
	popup.size = get_viewport_rect().size

func _update_container():

	if player_loaded == 0:
		#Update player container
		v_box_container.get_node("IconButton").texture_normal = load(Profile.player.icon)
		v_box_container.get_node("Namelabel").text = Profile.player.name

	match current_mode:
		"Solo":
			if player_loaded == 4:
				containers.map(func(container):
					if container.get_child_count() > 0:
						container.get_children().back().queue_free())
				player_loaded = 2

			if player_loaded >= 2:
				return

			#Update bot container
			_add_bot_containers()
			player_loaded = 2

		"Duo":
			if player_loaded >= 4:
				return
			#Update bot container
			_add_bot_containers()
			player_loaded = 4

func _get_player_details():
	return _create_details() if current_mode == "Solo" else _create_details(2, 4, ["L", "D"])

func _create_details(start = 1, end = 2, team = ["D"]):
	return range(start, end).map(func(i):
		return {
		"id": i+1,
		"name": RandomName.generate_name(),
		"type": "npc",
		"team": team[i-start]
		})

func _add_bot_containers():
	var player_details = _get_player_details()
	for idx in player_details.size():
		var box = v_box_container.duplicate(true)
		box.set_meta("profile", player_details[idx])
		box.get_node("IconButton").texture_normal = character_icon
		box.get_node("Namelabel").text = player_details[idx].name
		containers[idx%2].add_child(box)

func _on_start_button_clicked():
	GameManager.playerLoaded = player_loaded
	containers.reverse()
	containers.map(func(container): 
		container.get_children().map(func(child):
			var profile = child.get_meta("profile")
			GameManager.Players[profile.id] = profile
		))
	var level = main_scene.instantiate()
	level.add_resource_name("Playground")
	get_tree().root.add_child(level)
	hide()
