extends Node

@onready var game_start_time = Time.get_ticks_msec()

var scene_paths = {
	"Playground": "res://Scenes/2D/play_ground.tscn",
	"MatchMaking": "res://Scenes/match_making.tscn",
	"AIArenaLobby": "res://Scenes/ai_arena_lobby.tscn",
	"Home": "res://Scenes/home.tscn"
}

var autoload_scripts = {
	"GameManager": "res://Scripts/GameManager.gd",
	"PowersManager": "res://Scripts/PowersManager.gd"
}

var loading_scene = preload("res://Scenes/loading.tscn")

func load_scene(resource, _current_scene):
	var loading = loading_scene.instantiate()
	loading.add_resource_name(resource)
	get_tree().root.add_child(loading)

# Adds specified scripts to autoload when the game starts
func add_game_autoloads():
	for autoload_name in autoload_scripts:
		var script_path = autoload_scripts[autoload_name]
		# Check if autoload already exists to avoid duplication
		if ProjectSettings.has_setting("autoloads/" + autoload_name):
			print(autoload_name + " autoload already exists")
		else:
			# Add autoload
			ProjectSettings.set_setting("autoloads/" + autoload_name, script_path)
			ProjectSettings.save()

			# Define the autoload as a singleton
			var autoloads = ProjectSettings.get_setting("application/run/auto_load")
			autoloads.append([autoload_name, script_path, true])
			ProjectSettings.set_setting("application/run/auto_load", autoloads)

			# Save the changes
			ProjectSettings.save()

			print(autoload_name + " autoload added successfully")

# Removes specified autoloads after game over (win/loss)
func remove_game_autoloads():
	for autoload_name in autoload_scripts:
		# Check if autoload exists
		if ProjectSettings.has_setting("autoloads/" + autoload_name):
			# Remove from autoload settings
			ProjectSettings.clear("autoloads/" + autoload_name)

			# Update singleton settings
			var autoloads = ProjectSettings.get_setting("application/run/auto_load")
			autoloads = autoloads.filter(func(autoload):
				return autoload[0] != autoload_name
			)
			ProjectSettings.set_setting("application/run/auto_load", autoloads)

			# Save the changes
			ProjectSettings.save()

			print(autoload_name + " autoload removed successfully")


