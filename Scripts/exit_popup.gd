extends CanvasLayer

func _ready():
	visible = false

func _on_cancel_button_clicked():
	visible = false

func _on_ok_button_clicked():
	var current_scene = get_tree().root.get_child(-1)
	visible = false
	match current_scene.name:
		"Home":
			get_tree().quit()
		"Playground":
			GameManager.load_scene("Home", current_scene)
			

func _on_background_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_released():
			visible = false

func handle_back_request():
	var current_scene = get_tree().root.get_child(-1)
	visible = false
	match current_scene.name:
		"Home":
			visible = true
		"Loading":
			pass
		"Playground":
			visible = true
		_:
			GameManager.load_scene("Home", current_scene)
