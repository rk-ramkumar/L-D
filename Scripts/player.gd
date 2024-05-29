extends CharacterBody3D

@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature

@export var level: Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var isEntered: bool = false

func _ready():
	animation_player.play("FightIdle")
	level.rollFinsihed.connect(_onRollFinished)

func _input(event):
	if isEntered and InputEventScreenTouch  and event.is_pressed() :
		pass
func _onRollFinished():
	pass
	
func _on_mouse_entered():
	isEntered = true
	tween(armature, "scale", Vector3(0.25, 0.25, 0.25), 0.3)

func _on_mouse_exited():
	isEntered = false
	tween(armature, "scale", Vector3(0.15, 0.15, 0.15), 0.5)

func tween(object, property: String, finalValue, duration = 1):
	var tweenNode = get_tree().create_tween()
	tweenNode.tween_property(object, property, finalValue, duration)
	
func playAnimation(action):
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play(action)
