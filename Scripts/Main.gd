extends Node3D

@onready var dices = $Dices.get_children()
@onready var own = $actors/own
@onready var opponent = $actors/opponent
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var roll_button = $UI/Control/RollButton
@onready var turn_timer = $TurnTimer

signal rollFinsihed

var dieNumbers = {}
var isRolling: bool = false
var colors = {"eren": "green", "mikasa": "yellow"}

func _ready():
	own.set_multiplayer_authority(multiplayer.get_unique_id())
	opponent.set_multiplayer_authority(multiplayer.get_unique_id())
	GameManager.roundSwitched.connect(_onRoundSwitched)
	var player = GameManager.Players[multiplayer.get_unique_id()]
	var opponentTeam = "D" if player.team == "L" else "L"
	var color = colors[GameManager.teamList[player.team].actor]
	own.get_node("Label3D").text = player.team
	opponent.get_node("Label3D").text = opponentTeam
	startGame()

func startGame():
	turn_timer.startTimer()
	_onRoundSwitched(GameManager.currentPlayerTurn)

@rpc("any_peer", "call_local", "reliable")
func sendDieInfo(number):
	GameManager.currentDieNumber = number

@rpc("any_peer", "call_local", "reliable")
func upadatePosition():
	var uniqueId = Helpers.objectFind(GameManager.Players, "id", GameManager.currentPlayerTurn).uniqueId
	var tween = get_tree().create_tween()
	if multiplayer.get_unique_id() !=  uniqueId:
		var newPosition = own.position + Vector3(GameManager.currentDieNumber, 0, 0)
		tween.tween_property(own, "position", newPosition, 0.5)
	else:
		var newPosition = opponent.position + Vector3(GameManager.currentDieNumber, 0, 0)
		tween.tween_property(opponent, "position", newPosition, 0.5)
	
func _moveToStartPosition():
	for dice in dices:
			var tween = get_tree().create_tween()
			tween.tween_property(dice, "rotation", Vector3(dice.rotation.x, 0, dice.rotation.z), 0.3)
			tween.tween_property(dice, "position", Vector3(dice.StartPosition.x, 1, dice.StartPosition.z), 0.3)

func _onRoundSwitched(id):
	if id == GameManager.Players[multiplayer.get_unique_id()].id:
		roll_button.disabled = false
	else:
		roll_button.disabled = true

func _on_roll_button_pressed():
	if !isRolling:
		for die in dices:
			die.roll.rpc()
		turn_timer.stopTimer.rpc_id(1)

func _onDiceRollFinished(die, number):
	dieNumbers.merge({die.name: number}, true)
	if (dices.all(func(dice): return dice.is_sleeping())):
		sendDieInfo.rpc(dieNumbers["FirstDie"] + dieNumbers["SecondDie"])
		rollFinsihed.emit()
		isRolling = false
		_moveToStartPosition()
		upadatePosition.rpc()

