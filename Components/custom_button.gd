class_name CustomButton extends Button

signal clicked
@onready var audio_stream_player = $AudioStreamPlayer

@export var to_caps = true
@export var font_color: Color = Color.WHITE
@export var font_size: int = 32

func _ready():
	_add_ovverides()
	pressed.connect(_on_pressed)

func _on_pressed():
	audio_stream_player.play()
	await audio_stream_player.finished
	clicked.emit()

func _add_ovverides():
	if to_caps:
		text = text.to_upper()

	if !has_theme_color_override("font_color"):
		add_theme_color_override("font_color", font_color)
	
	if !has_theme_font_size_override("font_size"):
		add_theme_font_size_override("font_size", font_size)
	
