extends Popup

func _ready():
	size = get_parent().get_viewport().size

func _on_cancel_button_clicked():
	queue_free()

func _on_ok_button_clicked():
	get_tree().quit()
