extends Button

signal clicked
@onready var audio_stream_player = $AudioStreamPlayer

@export_group("custom override")
@export var to_caps = true
@export var font_color: Color = Color.WHITE

func _ready():
	if !has_theme_color_override("font_color"):
		add_theme_color_override("font_color", font_color)
	if to_caps:
		text = text.to_upper()
	pressed.connect(_on_pressed)

func _on_pressed():
	audio_stream_player.play()
	await audio_stream_player.finished
	clicked.emit()
