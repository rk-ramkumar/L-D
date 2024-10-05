extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var path_follow_ref = $PathFollowRef

@export var tile_map: TileMap

var is_move_started: bool = false
var sprites = []

func _ready():
	Observer.move_started.connect(_on_move_started)
	Observer.turn_started.connect(_on_turn_started)
	Observer.actor_selected.connect(_on_actor_selected)

func _process(_delta):
	if !is_move_started:
		return

	if !GameManager.selected_actor or animation_player.is_playing():
		return

	animate_move()

func animate_move():
	animation_player.play("zoom")
	var block_positions = tile_map.blocks.slice(
		GameManager.selected_actor.position_id,
		GameManager.selected_actor.position_id + GameManager.playground.player.coin
	)
	if block_positions.is_empty():
		_reset()
		return
	position = tile_map.map_to_local(block_positions.pop_back())

	if sprites.size() < block_positions.size():
		for i in block_positions.size() - sprites.size():
			_create_sprite()

	for idx in block_positions.size():
		sprites[idx].position = tile_map.map_to_local(block_positions[idx]) - position
		sprites[idx].show()
	show()

func  _on_move_started():
	if GameManager.player.id != GameManager.playground.player.id:
		return
	is_move_started = true

func _on_turn_started():
	if GameManager.player.id != GameManager.playground.player.id:
		return
	_reset()

func _on_actor_selected(_actor):
	if !is_move_started:
		return
	animate_move()

func _create_sprite():
	var sprite = path_follow_ref.duplicate(true)
	sprites.append(sprite)
	add_child(sprite)

func _reset():
	is_move_started = false
	hide()
