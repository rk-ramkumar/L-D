extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var path_follow_ref = $PathFollowRef

@export var tile_map: TileMap
@export var playground: Node2D

var is_move_started: bool = false
var sprites = []

func _ready():
	set_process(false)
	Observer.move_started.connect(_on_move_started)
	Observer.turn_started.connect(_on_turn_started)

func _process(_delta):
	if !is_move_started:
		return

	if !playground.selected_actor:
		return

	animate_move()
	set_process(false)

func animate_move():
	animation_player.play("zoom")
	var block_positions = tile_map.blocks.slice(
		playground.selected_actor.position_id,
		playground.selected_actor.position_id + playground.player.coin
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
	if GameManager.player.id != playground.player.id:
		return
	is_move_started = true
	set_process(true)

func _on_turn_started(_player):
	_reset()

func handle_actor_selected(actor):
	if !is_move_started:
		return
	if actor == null:
		hide()
		hide_sprites()
		return
	animate_move()

func _create_sprite():
	var sprite = path_follow_ref.duplicate(true)
	sprites.append(sprite)
	add_child(sprite)

func _reset():
	is_move_started = false
	animation_player.stop()
	hide_sprites()
	hide()
	
func hide_sprites():
	sprites.map(func(sprite): sprite.hide())

