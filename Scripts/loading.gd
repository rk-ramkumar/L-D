extends Control

var _progress = []
var resource_names = []
@onready var progress_bar = $ProgressBar
@onready var fade_color_rect = $FadeColorRect

func _ready():
	if Time.get_ticks_msec() - GameManager.game_start_time < 1000:
		resource_names = ["Home", "ExitPopup" ]
	_load_resources()

func _load_resources():
	var errors = resource_names.map(func(resource_name):
			if get_tree().root.has_node(resource_name) or !_is_path_exists(resource_name):
				return
			_progress.append(0.0)
			return ResourceLoader.load_threaded_request(get_resource_path(resource_name))
			)

	if errors.any(func(error): return error == OK):
		set_process(true)

func _process(_delta):
	if resource_names.is_empty():
		set_process(false)
		queue_free()

	for resource_name in resource_names:
		if !_is_path_exists(resource_name):
			return

		var stage = ResourceLoader.load_threaded_get_status(get_resource_path(resource_name), _progress)
		_progress[0] *= 100

		match stage:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				update_loading_screen(_progress[0])
		
		match get_resource_path(resource_name):

			GameManager.scene_paths.ExitPopup:
				if stage == ResourceLoader.THREAD_LOAD_LOADED:
					_on_exit_popup_loaded(resource_name)
			_:
				if stage == ResourceLoader.THREAD_LOAD_LOADED:
					_change_scene(resource_name)
				if stage == ResourceLoader.THREAD_LOAD_FAILED:
					printerr("Loading" + resource_name + "resource failed!")

func update_loading_screen(progress: float):
	progress_bar.value = lerp(progress_bar.value, progress, 0.1)

func _change_scene(resource_name):
	var resource = _get_loaded_resource(resource_name)
	var tween = get_tree().create_tween()
	tween.tween_property(
		progress_bar,
		"value",
		_progress[0],
		0.5
	)
	tween.tween_property(fade_color_rect, "color:a", 1.0, 0.5)
	tween.tween_callback(
		get_tree().change_scene_to_packed.bind(resource)
	)
	tween.tween_callback(func(): resource_names.erase(resource_name))

func _on_exit_popup_loaded(resource_name):
	var exit_popup = _get_loaded_resource(resource_name).instantiate()
	exit_popup.size = get_viewport_rect().size
	get_tree().root.add_child(exit_popup)
	resource_names.erase(resource_name)

func _get_loaded_resource(resource_name):
	return ResourceLoader.load_threaded_get(get_resource_path(resource_name))

func add_resource_name(resource_name):
	resource_names.append(resource_name)

func get_resource_path(resource_name):
	return GameManager.scene_paths[resource_name]

func _is_path_exists(resource_name):
	return GameManager.scene_paths.has(resource_name)
