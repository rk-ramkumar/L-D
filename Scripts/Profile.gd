extends Node

var _default_path = "user://profile.cfg"

# Create new ConfigFile object.
var _config

func _ready():
	_config = load_config(_default_path)

func load_config(path):
	var config = ConfigFile.new()
	# Load data from a file.
	var err = config.load(path)
	# If the file didn't load, ignore it.
	if err == OK:
		return config
	return null

func get_value(section, key):
	if !_config:
		return null
	return _config.get_value(section, key)

func set_value(section, key, value, path = _default_path):
	_config.set_value(section, key, value)
	_config.save(path)
