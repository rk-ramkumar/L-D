extends Control

var match_making = preload("res://Scenes/match_making.tscn")

func _ready():
	pass # Replace with function body.

func _on_start_button_clicked():
	get_tree().change_scene_to_packed(match_making)
