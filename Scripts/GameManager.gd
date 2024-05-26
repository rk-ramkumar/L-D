extends Node

signal roundSwitched(id)

var Players = {}
var playerLoaded: int = 0
var availableId = [1,2, 3, 4]
var teamList = { "L": {}, "D": {} }
var gameOver: bool = false
var currentPlayerTurn: int = 1:
	get:
		return currentPlayerTurn
	set(id):
		currentPlayerTurn = id
		roundSwitched.emit(id)
