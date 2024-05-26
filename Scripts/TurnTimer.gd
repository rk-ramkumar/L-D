extends Timer

@export var waitTime: float

func _ready():
	get_parent().rollFinsihed.connect(_onRollFinished)

func startTimer():
	if !multiplayer.is_server():
		return
	start(waitTime)

func _onRollFinished():
	if !multiplayer.is_server():
		return
	stop()
	updatePlayerTurn.rpc(getNextId())
	startTimer()

func getNextId():
	var nextId = (GameManager.currentPlayerTurn) % GameManager.playerLoaded
	print(nextId)
	return nextId + 1

@rpc("any_peer", "call_local")
func updatePlayerTurn(id):
	GameManager.currentPlayerTurn = id
	
func _on_timeout():
	_onRollFinished()
