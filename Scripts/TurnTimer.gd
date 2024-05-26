extends Timer

@export var waitTime: float

func _ready():
	get_parent().rollFinsihed.connect(_onRollFinished)

func startTimer():
	start(waitTime)

func _onRollFinished():
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
