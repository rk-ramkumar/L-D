extends Control

var _progress = []
var resource_paths = []
@onready var progress_bar = $ProgressBar

func _ready():
	if Time.get_ticks_msec() - GameManager.game_start_time < 5000:
		resource_paths = ["ExitPopup", "MatchMaking"]
	_load_resources(resource_paths)

func _load_resources(resource_paths):
	var errors = resource_paths.map(func(resource_path):
			if get_tree().root.has_node(resource_path) or !GameManager.scene_paths.has(resource_path):
				return
			_progress.append(0.0)
			return ResourceLoader.load_threaded_request(GameManager.scene_paths[resource_path])
			)

	if errors.any(func(error): return error == OK):
		set_process(true)

func _process(_delta):
	if resource_paths.is_empty():
		set_process(false)
		queue_free()

	for resource_path in resource_paths:
		if !GameManager.scene_paths.has(resource_path):
			return

		var stage = ResourceLoader.load_threaded_get_status(GameManager.scene_paths[resource_path], _progress)
		_progress[0] *= 100

		match stage:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				update_loading_screen(_progress[0])
		
		match GameManager.scene_paths[resource_path]:
			GameManager.scene_paths.Playground:
				if stage == ResourceLoader.THREAD_LOAD_LOADED:
					_on_playground_loaded(resource_path)
			GameManager.scene_paths.ExitPopup:
				if stage == ResourceLoader.THREAD_LOAD_LOADED:
					_on_exit_popup_loaded(resource_path)
			_:
				if stage == ResourceLoader.THREAD_LOAD_FAILED:
					printerr("Loading" + resource_path + "resource failed!")


func update_loading_screen(progress: float):
	progress_bar.value = lerp(progress_bar.value, progress, 0.1)

func _on_playground_loaded(resource_path):
	var resource = _get_loaded_resource(resource_path)
	var tween = get_tree().create_tween()
	tween.tween_property(
		progress_bar,
		"value",
		_progress[0],
		0.5
	)
	tween.tween_callback(
		get_tree().change_scene_to_packed.bind(resource)
	)
	tween.tween_callback(resource_paths.erase.bind(resource_path))

func _on_exit_popup_loaded(resource_path):
	var exit_popup = _get_loaded_resource(resource_path).instantiate()
	exit_popup.size = get_viewport_rect().size
	get_tree().root.add_child(exit_popup)
	resource_paths.erase(resource_path)

func _get_loaded_resource(resource_path):
	return ResourceLoader.load_threaded_get(GameManager.scene_paths[resource_path])
