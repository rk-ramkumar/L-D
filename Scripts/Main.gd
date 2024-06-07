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
@export var tileSize: int = 3

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
			teams[team.name].add_child(eren)
			GameManager.teamList[team.name]["actors"].append(eren)

func startGame():
	turn_timer.startTimer()
	_onRoundSwitched(GameManager.currentPlayerTurn)

@rpc("any_peer", "call_local", "reliable")
func sendDieInfo(number):
	GameManager.currentDieNumber = number

@rpc("any_peer", "call_local", "reliable")
func upadatePosition():
	var uniqueId = Helpers.objectFind(GameManager.Players, "id", GameManager.currentPlayerTurn).uniqueId
	
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
	var pawns = GameManager.teamList[player.team].actors
#	if pawns.all(func(pawn): return pawn.state == pawn.State.ATHOME):
#		if GameManager.currentDieNumber != 1:
#			moveMade.emit()
#			return

	var filterPawns = pawns.filter(func(pawn):
		var key = str(GameManager.currentDieNumber + pawn.number)
		var tile = GameManager.tiles.get("L" + key, GameManager.tiles.get("LD" + key, GameManager.tiles.get("D" + key)))

		if tile and tile.capacity != 0:
			pawn.tile = tile
			return true
		)
	for filterPawn in filterPawns:
		filterPawn.get_node("PathFollow3D").get_child(0).set_process_input(true)
