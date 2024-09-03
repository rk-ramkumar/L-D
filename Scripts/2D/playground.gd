extends Node2D

signal moveMade
@onready var turn_timer = %TurnTimer
@onready var ui = $CanvasLayer/UI
@onready var tile_map = $TileMap

enum tile_layer{
	FLOOR,
	BLOCKS,
	PLANT
}
var turnTime = 60

func _ready():
	turn_timer.start()
	
func get_clicked_tile_data(layer_name, layer_id = tile_layer.FLOOR):
	var clicked_cell = tile_map.local_to_map(tile_map.get_local_mouse_position())
	var data = tile_map.get_cell_tile_data(layer_id, clicked_cell)
	return data.get_custom_data(layer_name) if data else null
