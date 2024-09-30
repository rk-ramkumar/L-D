extends Control

@onready var timer_label = $TimerLabel
@onready var roll_button = $RollButton
@onready var die_2 = $Steps/DiceImageContainer/Die1
@onready var die_1 = $Steps/DiceImageContainer/Die2
@onready var store = $Store
@onready var user_coin_label = $Panel/UserCoinLabel

@export var turn_time: int = 25
@export var move_time: int = 15

var state: String
var die_textures = [
	preload("res://Assets/Icons/dice_empty.svg"),
	preload("res://Assets/Icons/dieWhite_border1.png"),
	preload("res://Assets/Icons/dieWhite_border2.png"),
	preload("res://Assets/Icons/dieWhite_border3.png"),
	preload("res://Assets/Icons/dieWhite_border6.png")
	]
var user_coin_text = ""

func _ready():
	%TurnTimer.timeout.connect(_on_timeout)
	user_coin_text = user_coin_label.text
	user_coin_label.text = user_coin_label.text.format(GameManager.Players[1])
	Observer.turn_started.connect(_on_turn_started)
	Observer.move_started.connect(_on_move_started)
	Observer.coin_changed.connect(_on_coin_changed)

func _on_turn_started():
	timer_label.text = str(turn_time)
	roll_button.disabled = GameManager.player.id != 1
	state = "roll"

func _on_move_started():
	timer_label.text = str(move_time)
	roll_button.disabled = true
	state = "move"

func on_roll_completed(dice_values):
	if dice_values.all(func(die_value): return die_value == 0):
		die_1.texture = die_textures.back()
		die_2.texture = die_textures.back()
	else:
		die_1.texture = die_textures[dice_values[0]]
		die_2.texture = die_textures[dice_values[1]]

func _handle_player_turn(id):
	if id != GameManager.player.id:
		roll_button.disabled = true
		timer_label.text = str(turn_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		Observer.emit_signal(state+"_failed")

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed() and store.visible:
			store.hide()

func _on_vending_machine_button_pressed():
	store.show()

func _on_coin_changed(prev_amount, amount):
#	user_coin_label.text = user_coin_label.text.format(GameManager.Players[1])
	var tween = create_tween()
	tween.tween_method(_lerp_coin, prev_amount, amount, 0.5)
	tween.tween_callback(func(): tween.kill())

func _lerp_coin(amount):
	user_coin_label.text = user_coin_text.format({coin=int(amount)})
