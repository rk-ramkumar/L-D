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
		_moveToStartPosition()

func _moveToStartPosition():
	for dice in dices:
			var tween = get_tree().create_tween()
			tween.tween_property(dice, "rotation", Vector3(dice.rotation.x, 0, dice.rotation.z), 0.3)
			tween.tween_property(dice, "position", Vector3(dice.StartPosition.x, 1, dice.StartPosition.z), 0.3)
