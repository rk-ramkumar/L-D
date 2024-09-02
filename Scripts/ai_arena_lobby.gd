extends Control

@onready var popup = $ModeSelectPopup
@onready var mode_select_button = $ModeSelectPanel/ModeSelectButton
@onready var v_box_container = $LeftBoxContainer/VBoxContainer

var current_mode: String: 
	set(newMode):
		current_mode = newMode
		mode_select_button.text = current_mode
		_update_container()

func _ready():
	current_mode = "Solo"
	popup.size = get_viewport_rect().size
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
	pass
