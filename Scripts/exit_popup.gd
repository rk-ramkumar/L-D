extends CanvasLayer

func _ready():
	visible = false

func _on_cancel_button_clicked():
	visible = false

func _on_ok_button_clicked():
	get_tree().quit()

func _on_background_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_released():
			visible = false
