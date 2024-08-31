extends Control

var _progress = []
var _loading_complete = false
var resource_paths = [
	"res://Scenes/2D/play_ground.tscn",
	"res://Scenes/exit_popup.tscn"
]
@onready var progress_bar = $ProgressBar

func _ready():
	_load_resources(resource_paths)

func _load_resources(resource_paths):
	var errors = resource_paths.map(func(resource_path):
			_progress.append(0.0)
			return ResourceLoader.load_threaded_request(resource_path)
			)

	if errors.any(func(error): return error == OK):
		set_process(true)

func _stage_handler(stage, progressCB, loadedCB):
	match stage:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progressCB.call()
		ResourceLoader.THREAD_LOAD_LOADED:
			loadedCB.call()
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("Loading resource failed!")

func _process(_delta):
	if  not _loading_complete:
		for resource_path in resource_paths:
			var stage = ResourceLoader.load_threaded_get_status(resource_path, _progress)
			_progress[0] *= 100
			match stage:
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					update_loading_screen(_progress[0])
			
			match resource_path:
				"res://Scenes/2D/play_ground.tscn":
					match stage:
						ResourceLoader.THREAD_LOAD_LOADED:
							_on_loading_complete(ResourceLoader.load_threaded_get(resource_path))
				"res://Scenes/exit_popup.tscn":
					if stage == ResourceLoader.THREAD_LOAD_LOADED:
						var exit_popup = ResourceLoader.load_threaded_get(resource_path).instantiate()
						exit_popup.size = get_viewport_rect().size
						get_tree().root.add_child(exit_popup)
				_:
					if stage == ResourceLoader.THREAD_LOAD_FAILED:
						printerr("Loading resource failed!")


func update_loading_screen(progress: float):
	progress_bar.value = lerp(progress_bar.value, progress, 0.1)

func _on_loading_complete(resouce):
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
		get_tree().change_scene_to_packed.bind(resouce)
	)
