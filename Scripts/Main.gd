extends Node3D

@onready var dices = $Dices.get_children()
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var roll_button = $UI/Control/RollButton
@onready var turnTimer = $TurnTimer
@onready var spawnSides = $SpawnAreaMarker.get_children()

@export var erenScene: PackedScene
@export var tileSize: int = 3

signal rollFinsihed
signal moveMade

var player
var dieNumbers = {}
var isRolling: bool = false

func _ready():
	player = GameManager.Players[multiplayer.get_unique_id()]
	GameManager.switchTurn.connect(_onRoundSwitched)
#	parseTiles()
	addPawns()
#	setCameera()
	startGame()

func parseTiles():
	var tiles = $Tiles.get_children()
	for tile in tiles:
		GameManager.tiles[tile.name] = tile

func setCameera():
	var player = GameManager.Players[multiplayer.get_unique_id()]
	var camera = $CameraPivot/Camera3D if player.team == "L" else $CameraPivot2/Camera3D
	camera.current = true
	
func addPawns():
	for side in spawnSides:
		for place in side.get_children():
			var pos = side.position + place.position
			pos.y += 1
			var eren = erenScene.instantiate()
			eren.set_multiplayer_authority(multiplayer.get_unique_id())
			eren.name = str(place.name.to_int())
			eren.position = pos
			eren.level = self
			eren.side = side.name
			get_node(NodePath(side.name)).add_child(eren)

func startGame():
	turnTimer.startTimer()
	_onRoundSwitched(GameManager.currentPlayerTurn)

@rpc("any_peer", "call_local", "reliable")
func sendDieInfo(number):
	GameManager.currentDieNumber = number

func _moveToStartPosition():
	for dice in dices:
		var property =  {
			"rotation": Vector3(dice.rotation.x, 0, dice.rotation.z),
			"position": Vector3(dice.StartPosition.x, 1, dice.StartPosition.z)
			}
		Helpers.tween(dice, property, 0.3)

func _onRoundSwitched(id):
	if id == player.id:
		roll_button.disabled = false
	else:
		roll_button.disabled = true

func _on_roll_button_pressed():
	if !isRolling:
		for die in dices:
			die.roll.rpc()
		turnTimer.stopTimer.rpc_id(1)

func _onDiceRollFinished(die, number):
	dieNumbers.merge({die.name: number}, true)
	if (dices.all(func(dice): return dice.is_sleeping())):
		sendDieInfo.rpc(dieNumbers["FirstDie"] + dieNumbers["SecondDie"])
		rollFinsihed.emit()
		isRolling = false
		_moveToStartPosition()
		checkIsValidToMove()

func checkIsValidToMove():
	var pawns = $Right.get_children()
	
#	Check for the player put one number when no pawns are not on the board
#	if pawns.all(func(pawn): return pawn.state == pawn.State.ATHOME):
#		if GameManager.currentDieNumber != 1:
#			moveMade.emit()
#			return

	var filterPawns = pawns.filter(func(pawn):
		if pawn.number < 0:
			return true
		var key = GameManager.currentDieNumber + pawn.number
		var pos = pawn.curve.get_point_position(key)
		pos.y = 1
		var tile 
		for child in $Tiles.get_children(): 
			printt(child.position, pos)
			if child.position == pos:
				tile = child

		if tile and tile.capacity != 0:
			pawn.tile = tile
			return true
		)
	for filterPawn in filterPawns:
		filterPawn.get_node("PathFollow3D").get_child(0).set_process_input(true)
