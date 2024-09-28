extends Timer

@export var waitTime: float

func _ready():
	Observer.turn_started.connect(startTimer)
	Observer.roll_started.connect(stopTimer)
	Observer.roll_completed.connect(_on_roll_completed)
	Observer.actor_move_started.connect(_on_move_started)

func _on_roll_completed(_die_value):
	startTimer()

func _on_move_started(_actor):
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
