extends Node

func _ready():
	randomize()
	
func getRandomNumbers(max = 3) -> Dictionary:
	var first = randi() % max
	var second = randi() % max
	
	return {first = first, second = second}

func objectFilter(objects, cb: Callable):
	var res = []
	for object in objects:
		if cb.call(object, objects[object]):
			res.append(objects[object])
	return res

func objectFind(objects:Dictionary, key, what) -> Dictionary:
	for object in objects:
		if objects[object][key] == what:
			return objects[object]
	return {}
