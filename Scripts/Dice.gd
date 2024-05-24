extends RigidBody3D

@export var StartPosition: Vector3 = Vector3.ZERO
@export var rollStrength: int = 30
@export var level: Node3D
@onready var rayCasts = $CollisionShape3D/RayCasts

signal rollFinished(die: RigidBody3D, number: int)

func roll():
	sleeping = false
	freeze = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", Vector3(0, 0, 0), 0.3)
	tween.tween_property(self, "position", StartPosition, 0.3)

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis
	
	var throwVector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throwVector * rollStrength / 2
	apply_central_impulse(throwVector * rollStrength)

func _on_sleeping_state_changed():
	if sleeping and level.isRolling :
		var landedOnSide = false
		for raycast in rayCasts.get_children():
			if raycast.is_colliding():
				rollFinished.emit(self, raycast.oppositeSide)
				landedOnSide = true

		if !landedOnSide:
			roll()
