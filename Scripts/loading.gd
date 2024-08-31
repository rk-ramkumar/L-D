extends Control

var _progress = [0.0]
var _loading_complete = false
var scene_path = "res://Scenes/2D/play_ground.tscn"
@onready var progress_bar = $ProgressBar

func _ready():
	_load_tilemap_async(scene_path)

func _load_tilemap_async(resource_path: String):
	var error = ResourceLoader.load_threaded_request(resource_path)
	if error == OK:
		set_process(true)

func _process(_delta):
	if  not _loading_complete:
		var stage = ResourceLoader.load_threaded_get_status(scene_path, _progress)
		_progress[0] *= 100
		match stage:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				update_loading_screen(_progress[0])
			ResourceLoader.THREAD_LOAD_LOADED:
				_on_loading_complete()
			ResourceLoader.THREAD_LOAD_FAILED:
				printerr("Loading resource failed!")

func update_loading_screen(progress: float):
	progress_bar.value = lerp(progress_bar.value, progress, 0.1)

func _on_loading_complete():
	_loading_complete = true
	set_process(false)
	var tween = get_tree().create_tween()
	tween.tween_property(
		progress_bar,
		"value",
		_progress[0],
		0.5
	)
	tween.tween_callback(
		get_tree().change_scene_to_packed.bind(
			ResourceLoader.load_threaded_get(scene_path)
		)
	)
	tween.tween_callback(tween.kill)
	_progress[0] = 0
