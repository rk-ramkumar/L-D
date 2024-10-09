extends Node

@onready var game_start_time = Time.get_ticks_msec()

var scene_paths = {
	"Playground": "res://Scenes/2D/play_ground.tscn",
	"MatchMaking": "res://Scenes/match_making.tscn",
	"AIArenaLobby": "res://Scenes/ai_arena_lobby.tscn",
	"Home": "res://Scenes/home.tscn"
}

var loading_scene = preload("res://Scenes/loading.tscn")

func load_scene(resource, _current_scene, should_load = true):
	if should_load:
		var loading = loading_scene.instantiate()
		loading.add_resource_name(resource)
		get_tree().root.add_child(loading)
	else:
		get_tree().change_scene_to_file(scene_paths[resource])
