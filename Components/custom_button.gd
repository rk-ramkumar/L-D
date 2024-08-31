extends Button

@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
	text = text.to_upper()
	pressed.connect(_on_pressed)

func _on_pressed():
	audio_stream_player.play()
