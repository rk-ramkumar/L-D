extends Node

var _default_path = "user://profile.cfg"

# Create new ConfigFile object.
var _config
var player = {
	"id": 1,
	"name": "",
	"type": "pc",
	"team": "L",
	"icon": "res://icon.svg"
}

func _ready():
	_config = load_config(_default_path)
	var player_name = get_value("Player", "name")
	if player_name:
		player.name = player_name

func load_config(path):
	var config = ConfigFile.new()
	# Load data from a file.
	var err = config.load(path)
	# If the file didn't load, ignore it.
	if err == OK:
		return config
	return ConfigFile.new()

func get_value(section, key):
	if !_config.has_section(section):
		return
	return _config.get_value(section, key)

func set_value(section, key, value, path = _default_path):
	_config.set_value(section, key, value)
	_config.save(path)
