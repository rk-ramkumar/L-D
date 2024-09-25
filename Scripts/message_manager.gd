extends CanvasLayer

@onready var container = $VBoxContainer
@onready var label_ref = $Label
var msg_duration = 3


func add_message(msg):
	if container.get_child_count() == 3:
		_remove_child()
	var label = label_ref.duplicate(true)
	label.visible = true
	label.text = msg
	start_timer(label)
	container.add_child(label)

func _remove_child():
	container.get_child(0).queue_free()

func start_timer(label):
	await get_tree().create_timer(msg_duration).timeout
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "modulate:a", 0, 1)
	tween.tween_callback(func():
		tween.kill()
		label.queue_free()
	)
