extends Node3D

@onready var dices = $Dices.get_children()
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var roll_button = $UI/Control/RollButton
@onready var turn_timer = $TurnTimer
@onready var teamsChildren = $Teams.get_children()
@onready var teams = {
	"L": $L,
	"D": $D
}
@export var erenScene: PackedScene

signal rollFinsihed
signal moveMade

var dieNumbers = {}
var isRolling: bool = false
var colors = {"eren": "green", "mikasa": "yellow"}

func _ready():
	GameManager.roundSwitched.connect(_onRoundSwitched)
	parseTiles()
	addPawns()
	startGame()

func parseTiles():
	var tiles = $Tiles.get_children()
	for tile in tiles:
		GameManager.tiles[tile.name] = tile
func addPawns():
	for team in teamsChildren:
		for place in team.get_children():
			var pos = team.position + place.position
			pos.y += 1
			var eren = erenScene.instantiate()
			eren.set_multiplayer_authority(multiplayer.get_unique_id())
			eren.position = pos
			eren.level = self
			if team.name == "D":
				eren.rotation.y = 90
			teams[team.name].add_child(eren)

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
#	if multiplayer.get_unique_id() !=  uniqueId:
#		var newPosition = own.position + Vector3(GameManager.currentDieNumber, 0, 0)
#		tween.tween_property(own, "position", newPosition, 0.5)
#	else:
#		var newPosition = opponent.position + Vector3(GameManager.currentDieNumber, 0, 0)
#		tween.tween_property(opponent, "position", newPosition, 0.5)
	
func _moveToStartPosition():
	for dice in dices:
		var property =  {
			"rotation": Vector3(dice.rotation.x, 0, dice.rotation.z),
			"position": Vector3(dice.StartPosition.x, 1, dice.StartPosition.z)
			}
		Helpers.tween(dice, property, 0.3)

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
		checkIsValidToMove()
		upadatePosition.rpc()

func checkIsValidToMove():
	var player = GameManager.Players[multiplayer.get_unique_id()]
	var pawns = teams[player.team].get_children()
	var filterPawns = pawns.filter(func(pawn):
		if pawn.number < 0:
			true
		var key = str(GameManager.currentDieNumber + pawn.number)
		var tile = GameManager.tiles.get("L" + key, GameManager.tiles.get("LD" + key, GameManager.tiles.get("D" + key)))
		if tile.capacity != 0:
			pawn.tile = tile
			return true 
		)
	for filterPawn in filterPawns:
		filterPawn.set_process_input(true)
