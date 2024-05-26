extends Timer

@export var waitTime: float

func _ready():
	get_parent().rollFinsihed.connect(_onRollFinished)

func startTimer():
	if !multiplayer.is_server():
		return
	start(waitTime)

@rpc("any_peer", "call_local", "reliable")
func stopTimer():
	stop()

func _onRollFinished():
	if !multiplayer.is_server():
		return
	stop()
	updatePlayerTurn.rpc(getNextId())
	startTimer()

func getNextId():
	var nextId = ((GameManager.currentPlayerTurn) % GameManager.playerLoaded) + 1
	return nextId 

@rpc("authority", "call_local")
func updatePlayerTurn(id):
	GameManager.currentPlayerTurn = id
	
func _on_timeout():
	_onRollFinished()
