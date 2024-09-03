extends Timer

@export var waitTime: float

func _ready():
	%UI.move_made.connect(_onMoveMade)
	GameManager.switchTurn.connect(_on_switch_turn)

func _on_switch_turn(id):
	startTimer()

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
