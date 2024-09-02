extends Control

@onready var solo_mode_button = $ModeSelectionContainer/SoloModeButton
@onready var duo_mode_button = $ModeSelectionContainer/DuoModeButton

var current_mode = "solo"

func _ready():
	solo_mode_button.disabled = true

func _on_solo_mode_button_clicked():
	current_mode = "solo"
	solo_mode_button.disabled = true

func _on_duo_mode_button_clicked():
	current_mode = "double"
	duo_mode_button.disabled = true
