extends RigidBody3D

@export var StartPosition: Vector3 = Vector3.ZERO
@export var rollStrength: int = 30

func roll():
	sleeping = false
	freeze = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", Vector3(0, 0, 0), 0.3)
	tween.tween_property(self, "position", StartPosition, 0.5)
#	transform.origin = StartPosition
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	
	var throwVector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throwVector * rollStrength / 2
	apply_central_impulse(throwVector * rollStrength)
