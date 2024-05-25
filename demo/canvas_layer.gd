extends CanvasLayer

@onready var createUI = $"Create UI"
@onready var lobby = $Lobby
var peer
var port = 1313

func _ready():
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	multiplayer.connected_to_server.connect(onConnectedToServer)

func onPeerConnected(id):
	print("Player connected " + str(id))
	createUI.hide()
	lobby.show()
	$"Lobby/Team L/Player 1/TextureButton".texture_normal = load("res://icon.svg")

func onPeerDisconnected(id):
	pass

func onConnectedToServer():
	print("Connected To Server!")

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("Cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for Player! ")
#	onPeerConnected(1)
	

func _on_texture_button_pressed(data):
	pass # Replace with function body.
