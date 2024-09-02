extends Control

@onready var popup = $ModeSelectPopup
@onready var mode_select_button = $ModeSelectPanel/ModeSelectButton
@onready var v_box_container = $LeftBoxContainer/VBoxContainer/BackgroundTexture
@onready var containers = [$RightBoxContainer/VBoxContainer, $LeftBoxContainer/VBoxContainer]
@onready var spark_divider = $SparkDivider

var default_player_detail = {
	"name": "rk",
	"type": "player",
	"team": "L",
	"icon": "res://icon.svg"
}
var player_loaded = 0
var character_icon = preload("res://Assets/Icons/character.svg")
var current_mode: String: 
	set(newMode):
		current_mode = newMode
		mode_select_button.text = current_mode
		_update_container()

func _ready():
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
	spark_divider.position = get_viewport_rect().size / 2

func _update_container():

	if player_loaded == 0:
		#Update player container
		v_box_container.get_node("IconButton").texture_normal = load(default_player_detail.icon)
		v_box_container.get_node("Namelabel").text = default_player_detail.name

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
	return _create_details() if current_mode == "Solo" else _create_details(2, ["L", "D"])

func _create_details(count = 1, team = ["D"]):
	return range(0, count).map(func(i):
		return {
		"name": "Bot_" + str(randi()),
		"type": "bot",
		"team": team[i]
		})

func _add_bot_containers():
	var player_details = _get_player_details()
	for idx in player_details.size():
		var box = v_box_container.duplicate(true)
		box.get_node("IconButton").texture_normal = character_icon
		box.get_node("Namelabel").text = player_details[idx].name
		containers[idx%2].add_child(box)

