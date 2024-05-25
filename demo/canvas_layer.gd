extends CanvasLayer

@onready var createUI = $"Create UI"
@onready var lobby = $Lobby
var peer
var port = 1313
var Name 

func _ready():
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	multiplayer.connected_to_server.connect(onConnectedToServer)

func onPeerConnected(id):
	print("Player connected " + str(id))
	createUI.hide()
	lobby.show()
	$"Lobby/Team L/Player 1/TextureButton".texture_normal = load("res://icon.svg")

@rpc("any_peer")
func sendPlayersInfo(id, Name = ""):
	if !GameManager.Players.has(id):
		GameManager.Players[id] =  { id = id, coins = 3000, Name = Name}
	
	if multiplayer.is_server():
		for playerId in GameManager.Players:
			sendPlayersInfo.rpc(playerId, GameManager.Players[playerId].Name)

func onPeerDisconnected(id):
	pass

func onConnectedToServer():
	print("Connected To Server!")
	sendPlayersInfo.rpc(multiplayer.get_unique_id(), Name)

func _on_join_pressed():
	Name = $"Create UI/LineEdit".text
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
func _on_host_pressed():
	Name = $"Create UI/LineEdit".text
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Player! ")
	sendPlayersInfo(1, "Ram")
	
func _on_texture_button_pressed(data):
	pass # Replace with function body.

@rpc("any_peer", "call_local")
func startGame():
	var level = load("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(level)
	hide()

func _on_start_pressed():
	startGame.rpc_id(1)
