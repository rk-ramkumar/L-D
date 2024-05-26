extends Node3D

@onready var dices = $Dices.get_children()
@onready var own = $own
@onready var opponent = $opponent
@onready var label_3d = $Label3D
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var roll_button = $CanvasLayer/Control/RollButton
@onready var turn_timer = $TurnTimer

signal rollFinsihed

var dieNumbers = {}
var isRolling: bool = false
var colors = {"eren": "green", "mikasa": "yellow"}
var timeForEachTurn = 5

#	multiplayer_synchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
func _ready():
	GameManager.roundSwitched.connect(_onRoundSwitched)
	var player = GameManager.Players[multiplayer.get_unique_id()]
	label_3d.text = player.Name
	var opponentTeam = "D" if player.team == "L" else "L"
	var color = colors[GameManager.teamList[player.team].actor]
	own.material.set_albedo(Color(color))
	opponent.material.set_albedo(Color( colors[GameManager.teamList[opponentTeam].actor]))
	startGame()

func startGame():
	turn_timer.startTimer()
	_onRoundSwitched(GameManager.currentPlayerTurn)

func _onDiceRollFinished(die, number):
	dieNumbers.merge({die.name: number}, true)
	
	if (dices.all(func(dice): return dice.is_sleeping())):
		rollFinsihed.emit()
		isRolling = false
		_moveToStartPosition()
		own.position.x += dieNumbers["FirstDie"] + dieNumbers["SecondDie"]

func _moveToStartPosition():
	for dice in dices:
			var tween = get_tree().create_tween()
			tween.tween_property(dice, "rotation", Vector3(dice.rotation.x, 0, dice.rotation.z), 0.3)
			tween.tween_property(dice, "position", Vector3(dice.StartPosition.x, 1, dice.StartPosition.z), 0.3)

func _on_roll_button_pressed():
	if !isRolling:
		for die in dices:
			die.roll()
		isRolling = true
		turn_timer.stop()
	
func _onRoundSwitched(id):
	if id == GameManager.Players[multiplayer.get_unique_id()].id:
		roll_button.disabled = false
	else:
		roll_button.disabled = true
