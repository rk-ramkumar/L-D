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

func tween(object, property, duration = 1, finalValue = null):
	var tweenNode = get_tree().create_tween()
	match typeof(property):
		TYPE_STRING:
			tweenNode.tween_property(object, property, finalValue, duration)
		TYPE_DICTIONARY:
			for key in property:
				tweenNode.tween_property(object, key, property[key], duration)
			
