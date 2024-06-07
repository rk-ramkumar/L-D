extends Path3D

enum State {
	ATHOME,
	INUSE
}

@export var state: State = State.ATHOME
@export var level: Node3D
@export var number: int = -1
@export var tile: StaticBody3D
