extends Node

signal switchTurn(id)

@onready var LCurvePath = preload("res://Resources/LCurvePath.tres")

var Players = {}
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

