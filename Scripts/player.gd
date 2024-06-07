extends CharacterBody3D

@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature
@onready var parent = get_owner()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const animationDelay = 1.6

var isEntered: bool = false

func _ready():
	playAnimation("FightIdle")
	parent.level.rollFinsihed.connect(_onRollFinished)
	set_process_input(false)

func _input(event):
	if isEntered and InputEventScreenTouch and event.is_pressed():
		
		# When user put 1 and the below code will take the pawn to the starting position.
		if parent.number < 0:
			parent.number = 0
			parent.position = Vector3.ZERO
			parent.set_curve(GameManager.LCurvePath)
			get_parent().progress = 0
			set_process_input(false)
			return

		playAnimation("WalkForward")
		parent.number += GameManager.currentDieNumber
		var tween = Helpers.tween(get_parent(), {"progress": parent.number * parent.level.tileSize}, animationDelay)
		tween.finished.connect(_onTwenFinished)
		set_process_input(false)

func _onTwenFinished():
	reset()
	parent.level.moveMade.emit()
	
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
	playAnimation("FightIdle")
	parent.tile = null
