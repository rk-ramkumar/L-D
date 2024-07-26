extends TileMap


func _ready():
	pass


func _input(event):
	if event is InputEventScreenTouch:
		print(get_surrounding_cells(event.position))
