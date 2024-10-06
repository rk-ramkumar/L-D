extends Control

@onready var timer_label = $TimerLabel
@onready var turn_over_button = $HBoxContainer/TurnOverButton
@onready var store = $Store
@onready var user_coin_label = $Panel/UserCoinLabel

@export var move_time: int = 20
@export var playground: Node2D

var user_coin_text = ""
var replace_coin_text = "[b][img=64]res://Assets/PowersImages/Coin.png[/img][color=Ffd700]"

func _ready():
	%TurnTimer.timeout.connect(_on_timeout)
	Observer.move_started.connect(_on_move_started)
	Observer.turn_started.connect(_on_turn_started)
	Observer.coin_changed.connect(_on_coin_changed)
	# Wait for playground ready finish for updated player values
	await playground.ready
	user_coin_text = user_coin_label.text
	user_coin_label.text = user_coin_text.format(playground.player)

func set_turn_over_btn_disable(value):
	turn_over_button.disabled = value

func _on_turn_started(_player):
	timer_label.text = ""

func _on_move_started():
	timer_label.text = str(move_time)

func _on_timeout():
	timer_label.text = str(int(timer_label.text) - 1)
	if int(timer_label.text) == 0:
		Observer.move_failed.emit()

func _on_vending_machine_button_pressed():
	store.show()

func _on_coin_changed(player):
	if player.id != playground.player.id:
		return
	var prev_amount = user_coin_label.text.replace(replace_coin_text, "").to_int()
	var tween = create_tween()
	tween.tween_method(_lerp_coin, prev_amount, player.coin, 0.5)
	tween.tween_callback(func(): tween.kill())

func _lerp_coin(amount):
	user_coin_label.text = user_coin_text.format({coin=int(amount)})
