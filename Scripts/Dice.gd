extends RigidBody3D

@onready var pivot = $Pivot

var axes = {
	1 : 300,
	3 : 30,
	0 : 210,
	2 : 120  
}
var animDuration = 5

func updateRotation(key):
	var tween = get_tree().create_tween()
	tween.tween_property(pivot, "rotation", Vector3(0, 0, axes[key]), animDuration)

