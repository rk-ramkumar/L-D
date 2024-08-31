extends Popup

func _ready():
	visible = false

func _on_cancel_button_clicked():
	visible = false

func _on_ok_button_clicked():
	get_tree().quit()
