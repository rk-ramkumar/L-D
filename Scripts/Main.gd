extends Node3D

var diceScene = preload("res://Scenes/Dice.tscn")

func _on_button_pressed():
	var numbers = Helpers.getRandomNumbers()
	for number in numbers:
		var dice = diceScene.instantiate()
		var x = randi_range(-5, 5)
		var y = randi_range(-5, 5)
		dice.position = Vector3(x, 5, y)
		add_child(dice)
		dice.updateRotation(numbers[number])
