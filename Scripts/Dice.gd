extends RigidBody3D

@export var StartPosition: Vector3 = Vector3.ZERO
@export var rollStrength: int = 30

func roll():
	sleeping = false
	freeze = false
	transform.origin = StartPosition
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	
	var throwVector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
