extends Node3D

@onready var dices = $Dices.get_children()

var dieNumbers = {}
var isRolling: bool = false

func _on_button_pressed():
	if !isRolling:
		for die in dices:
			die.roll()
		isRolling = true

func _onDiceRollFinished(die, number):
	dieNumbers.merge({die.name: number}, true)
	
	if (dices.all(func(dice): return dice.is_sleeping())):
		isRolling = false
	
