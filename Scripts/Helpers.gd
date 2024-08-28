extends Node

func _ready():
	randomize()
	
func getRandomNumbers(max_value = 3) -> Dictionary:
	var first = randi() % max_value
	var second = randi() % max_value
	
	return {first = first, second = second}

func objectFilter(objects, cb: Callable):
	var res = []
	for object in objects:
		if cb.call(object, objects[object]):
			res.append(objects[object])
	return res

func objectFind(collections, key, what) -> Dictionary:
	var objects = collections if typeof(collections) == TYPE_ARRAY else collections.values()
	for object in objects:
		if object[key] == what:
			return object
	return {}

func tween(object, property, duration = 1.0, finalValue = null) -> Tween:
	var tween_node: Tween = get_tree().create_tween()

	match typeof(property):
		TYPE_STRING:
			tween_node.tween_property(object, property, finalValue, duration)
		TYPE_DICTIONARY:
			for key in property:
				tween_node.tween_property(object, key, property[key], duration)
			
	return tween_node
