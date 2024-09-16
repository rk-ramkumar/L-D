extends Node

signal switchTurn(id)

@onready var game_start_time = Time.get_ticks_msec()
var scene_paths = {
	"Playground": "res://Scenes/2D/play_ground.tscn",
	"ExitPopup": "res://Scenes/exit_popup.tscn",
	"MatchMaking": "res://Scenes/match_making.tscn",
	"AIArenaLobby": "res://Scenes/ai_arena_lobby.tscn"
}
var Players = {}
var player = {}
var actors_count = 6
var playerLoaded: int = 0
var availableId = [1,2, 3, 4]
var teamList = { "L": {"actors": []}, "D": {"actors": []} }
var gameOver: bool = false
var currentPlayerTurn: int = 1:
	get:
		return currentPlayerTurn
	set(id):
		currentPlayerTurn = id
		switchTurn.emit(id)
var currentDieNumber: int :
	get:
		return currentDieNumber
	set(newNumber):
		if newNumber == 0:
			currentDieNumber = 12
		else:
			currentDieNumber = newNumber

