extends Node

func _ready():
	randomize()
	
func getRandomNumbers(max = 3) -> Dictionary:
	var first = randi() % max
	var second = randi() % max
	
	return {first = first, second = second}
