extends CanvasLayer

@onready var createUI = $"Create UI"
@onready var lobby = $Lobby
@onready var line_edit = $"Create UI/CenterContainer/Control/VBoxContainer/LineEdit"

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 4

var peer
var port = 1313
var Name
var teams = ["L", "D"]


func _ready():
	multiplayer.peer_connected.connect(onPeerConnected)
	multiplayer.peer_disconnected.connect(onPeerDisconnected)
	multiplayer.connected_to_server.connect(onConnectedToServer)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func onPeerConnected(id):
	createUI.hide()
	lobby.show()

@rpc("any_peer")
func sendPlayersInfo(data):
	if !GameManager.Players.has(data.uniqueId):
		var team = teams[ (GameManager.Players.size()) % 2 ]
		GameManager.playerLoaded += 1
		GameManager.Players[data.uniqueId] =  {
			uniqueId = data.uniqueId,
			id = GameManager.playerLoaded, 
			coins = 3000, 
			Name = data.Name, 
			icon = data.get("icon", "res://icon.svg"),
			team = team
			}
		upadatePlayerDisplay()

	if multiplayer.is_server():
		for playerId in GameManager.Players:
			var player = GameManager.Players[playerId]
			sendPlayersInfo.rpc(player)

@rpc("any_peer", "call_local")
func updatePlayersInfo(id, data):
	GameManager.Players[id].merge(data, true)

func onPeerDisconnected(id):
	pass

func onConnectedToServer():
	lobby.get_node("StartLabel").visible = true
	lobby.get_node("Start").visible = false
	
	sendPlayersInfo.rpc({uniqueId = multiplayer.get_unique_id(), Name = Name})

func _on_join_pressed():
	Name = line_edit.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(DEFAULT_SERVER_IP, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_host_pressed():
	Name = line_edit.text
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	sendPlayersInfo({uniqueId = multiplayer.get_unique_id(), Name = "Ram"})
	onPeerConnected(multiplayer.get_unique_id())

func _on_texture_button_pressed(data):
	updatePlayersInfo.rpc(multiplayer.get_unique_id(), data)
	upadatePlayerDisplay.rpc()

@rpc("call_local", "reliable")
func startGame():
	var level = load("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(level)
	hide()

func _on_start_pressed():
	startGame.rpc_id(1)

@rpc("any_peer", "call_local")
func upadatePlayerDisplay():
	for team in teams:
		var playerNodes = lobby.get_node("Team " + team).get_children()
		
		for playerNode in playerNodes:
			var id = playerNode.name.to_int()
			var player = Helpers.objectFind(GameManager.Players, "id", id)
			if player != {}:
				playerNode.get_node("TextureButton").texture_normal = load(player.icon)
				playerNode.get_node("TextureButton").disabled = true
				playerNode.get_node("Name").text = player.Name
			else:
				playerNode.get_node("TextureButton").texture_normal = load("res://Assets/Textures/icons8-add-100.png")
				playerNode.get_node("TextureButton").disabled = false
				playerNode.get_node("Name").text = ''

func isValidToPlay():
	pass

func _on_player_disconnected(id):
	GameManager.Players.erase(id)
	player_disconnected.emit(id)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	GameManager.Players.clear()
	server_disconnected.emit()
