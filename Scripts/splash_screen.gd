extends Control

@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player = $AnimationPlayer

var loading_scene = preload("res://Scenes/loading.tscn")

func _ready():
	animation_player.play("splash_start")
	audio_stream_player.play()

func _on_animation_player_animation_finished(anim_name):
	GameManager.game_start_time = Time.get_ticks_msec()
	animation_player.stop()
	AudioController.main_background.play()
	get_tree().change_scene_to_packed(loading_scene)
