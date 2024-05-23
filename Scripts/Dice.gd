extends RigidBody3D

@onready var pivot = $Pivot

var axes = {
	1 : 270,
	3 : 0,
	0 : 180,
	2 : 90  
}
var animDuration = 1

func updateRotation(key):
	var tween = get_tree().create_tween()
	tween.tween_property(pivot, "rotation", Vector3(0, 0, axes[key]), animDuration)
