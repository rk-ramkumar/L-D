extends Timer

@export var waitTime: float

func _ready():
	Observer.move_started.connect(startTimer)
	Observer.turn_started.connect(_handle_stop)
	Observer.actor_move_started.connect(_handle_stop)

func _handle_stop(_actor):
	stopTimer()

# Online Multiplayer
func startTimer():
	if !multiplayer.is_server():
		return
	start(waitTime)

@rpc("any_peer", "call_local", "reliable")
func stopTimer():
	stop()

func _onMoveMade():
	stop()

# Online multiplayer
#	if !multiplayer.is_server():
#		return
#	stop()
#	updatePlayerTurn.rpc(getNextId())
#	startTimer()

func getNextId():
	var nextId = ((GameManager.currentPlayerTurn) % GameManager.playerLoaded) + 1
	return nextId 

@rpc("authority", "call_local")
func updatePlayerTurn(id):
	GameManager.currentPlayerTurn = id
