extends Control

@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player = $AnimationPlayer

var loading_scene = preload("res://Scenes/loading.tscn")

func _ready():
	animation_player.play("splash_start")
	audio_stream_player.play()

func _on_animation_player_animation_finished(_anim_name):
	animation_player.stop()
	AudioController.main_background.play()
	Global.load_scene("Home", self)
