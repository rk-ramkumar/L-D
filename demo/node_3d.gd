extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var playerScene: PackedScene

func _on_host_pressed():
	peer.create_server(1313)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_addPlayer)
	_addPlayer(1)
	$CanvasLayer.hide()
	$Start.show()
func _addPlayer(id):
	print(id)

func _on_join_pressed():
	peer.create_client("localhost", 1313)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
