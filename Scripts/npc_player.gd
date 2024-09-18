class_name NPCPlayer extends Node

var player = {}

func _ready():
	connect_signals()

func connect_signals():
	Observer.turn_started.connect(_handle_turn_started)
	Observer.move_started.connect(_handle_move_started)

func _handle_turn_started():
	if player.id != GameManager.currentPlayerTurn:
		return

	await get_tree().create_timer(randf_range(1, 5)).timeout
	Observer.roll_started.emit()

func _handle_move_started():
	pass
