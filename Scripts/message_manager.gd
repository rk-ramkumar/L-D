extends CanvasLayer

@onready var container = $VBoxContainer
@onready var label_ref = $Label
@onready var info_label = $InfoLabel

var msg_duration = 3
var info_label_text = "[center][color=white][b]{info}[/b][/color][/center]"
var info_count = 0
var label_tween

func add_message(msg):
	if container.get_child_count() == 3:
		_remove_child()
	var label = label_ref.duplicate(true)
	label.visible = true
	label.text = msg
	container.add_child(label)
	start_timer(label)

func _remove_child():
	container.get_child(0).queue_free()

func start_timer(label):
	await get_tree().create_timer(msg_duration).timeout
	if !label:
		return
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "modulate:a", 0, 1)
	tween.tween_callback(func():
		tween.kill()
		label.queue_free()
	)

func add_info(info):
	if info_count > 3:
		info_count = 0
		_reset_info_label()
		return
	info_count += 1
	info_label.text = info_label_text.format({info = info.to_upper()})
	info_label.show()
	start_info_timer(1)

func start_info_timer(duration):
	await get_tree().create_timer(duration).timeout
	if label_tween:
		label_tween.kill()
	label_tween = info_label.create_tween()
	label_tween.tween_property(info_label, "modulate:a", 0, 1)
	label_tween.tween_callback(_reset_info_label)

func _reset_info_label():
	label_tween.kill()
	info_label.modulate = Color.WHITE
	info_label.hide()
	
