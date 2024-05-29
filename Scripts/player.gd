extends CharacterBody3D

enum State {
	AVAILABLE,
	UNAVAILABLE,
	INUSE
}

@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature

@export var state: State = State.AVAILABLE
@export var level: Node3D
@export var number: int = 0
@export var tile: StaticBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var isEntered: bool = false

func _ready():
	playAnimation("FightIdle")
	level.rollFinsihed.connect(_onRollFinished)
	set_process_input(false)

func _input(event):
	if isEntered and InputEventScreenTouch  and event.is_pressed():
		playAnimation("WalkForward")
		Helpers.tween(self, {"position": tile.get_parent().position + tile.position}, 0.5)

func _onRollFinished():
	pass
	
func _on_mouse_entered():
	isEntered = true
	Helpers.tween(armature, {"scale": Vector3(0.25, 0.25, 0.25)}, 0.3)

func _on_mouse_exited():
	isEntered = false
	Helpers.tween(armature, {"scale": Vector3(0.15, 0.15, 0.15)}, 0.5)
	
func playAnimation(action):
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play(action)

func reset():
	set_process_input(false)
	playAnimation("FightIdle")	
	tile = null
