class_name Actor extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var home_state_timer = $HomeStateTimer
@onready var pivot = $Pivot
@onready var gpu_particles_2d = $Pivot/Magic01/GPUParticles2D

@export var tile_map: TileMap
@export var current_direction: String
@export var data: Dictionary = {}
var directions = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
var tween
var position_id = 0
var movable: bool = true
var has_recent_capture: bool = false
var is_moving: bool = false
var team
var power: Dictionary = {} 
var current_state = GameManager.player_state.AT_HOME:
	set(new_state):
		current_state = new_state
		_set_current_state()

func _ready():
	position = data.positions.pick_random()
	team = data.team
	_set_direction(get_angle_to(position))
	_update_animation("_idle")
	Observer.actor_captured.connect(_on_capture)
	Observer.power_used.connect(_on_power_used)

func _set_current_state():
	if current_state == GameManager.player_state.AT_HOME:
		home_state_timer.start(5)
	else:
		if tween:
			tween.kill()
		home_state_timer.stop()

func _set_direction(position_angle = get_local_mouse_position().angle()):
	var angle = snappedf(position_angle, PI/4) / (PI/4)
	angle = wrapi(int(angle), 0, 8)
	current_direction = str(directions[angle])

func start_moving(chosen_move):
	if !is_moving:
		is_moving = true
		if PowersManager.has_hermes_dash(power): # Check for hermes dash power
			PowersManager.activate_hermes_dash(chosen_move, self)
		Observer.actor_move_started.emit(self, chosen_move.step)
		position_id = position_id + chosen_move.step
		if position_id == GameManager.max_tile_id:
			finished(chosen_move.positions.back())
			return
		current_state = GameManager.player_state.ON_FIELD
		for target_position in chosen_move.positions:
			target_position = tile_map.map_to_local(target_position)
			_set_direction(get_angle_to(target_position))
			_update_animation("_walk")
			if !tween:
				_lerp_to_pos(target_position)
			else:
				await tween.finished
				_lerp_to_pos(target_position)

func finished(pos):
	position_id = position_id + GameManager.currentDieNumber
	current_state = GameManager.player_state.COMPLETED
	Observer.actor_completed.emit(self)
	pos = tile_map.map_to_local(pos)
	_set_direction(get_angle_to(pos))
	_update_animation("_walk")
	_lerp_to_finish(pos)

func start_moving_home():
	current_state = GameManager.player_state.CAPTURED
	var pos = data.positions.pick_random()
	position_id = 0
	_set_direction(get_angle_to(pos))
	_update_animation("_walk")
	_lerp_to_pos(pos)

func _lerp_to_finish(pos, speed = SPEED):
	if tween:
		tween.kill()
	tween = create_tween()
	var time_delay = global_position.distance_to(pos) / speed
	tween.parallel().tween_property(self, "position", pos, time_delay)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, time_delay)
	tween.tween_callback(_on_finish)

func _on_finish():
	tween.kill()
	visible = false
	Observer.actor_move_completed.emit(self)

func _lerp_to_pos(pos, speed = SPEED):
	if tween:
		tween.kill()
	tween = create_tween()
	var time_delay = global_position.distance_to(pos) / speed
	tween.tween_property(self, "position", pos, time_delay)
	tween.tween_callback(_on_tween_position_finished)

func cartesian_to_isometric(cartesian_position: Vector2) -> Vector2:
	var isometric_x = cartesian_position.x - cartesian_position.y
	var isometric_y = (cartesian_position.x + cartesian_position.y)/2
	
	return Vector2(isometric_x, isometric_y)

func _update_animation(animation_name):
	animation_name = current_direction + animation_name
	animated_sprite_2d.play(animation_name)
	
	# Added offset for jump animation.
	if animation_name.contains("jump"):
		animated_sprite_2d.scale = Vector2(0.6, 0.6)
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.frame = 0
		_update_animation("_idle")
		animated_sprite_2d.scale = Vector2(0.5, 0.5)

func _on_tween_position_finished():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(
		animated_sprite_2d.play,
		animated_sprite_2d.animation,
		StringName(current_direction + "_idle"),
		0.2)
	tween.tween_callback(func(): 
		is_moving = false
		tween.kill()
		tween = null
		if current_state == GameManager.player_state.ON_FIELD:
			Observer.actor_move_completed.emit(self)
	)

func _on_home_state_timer_timeout():
	home_state_timer.stop()
	var pos = data.positions.pick_random()
	_set_direction(get_angle_to(pos))
	_update_animation("_walk")
	_lerp_to_pos(pos, 100)
	await tween.finished
	home_state_timer.start(10)

func select(value):
	pivot.visible = value
	gpu_particles_2d.emitting = value

func _on_capture(captured_actor, actor):
	if actor == self:
		movable = PowersManager.has_relentless_march(self)
		Observer.power_used.emit(power, actor)

	if captured_actor == self:
		start_moving_home()

func _on_power_used(power, actor):
	if actor == self:
		power = {}