extends Node3D

@onready var dice = $Dice
@onready var dice2 = $Dice2

func _on_button_pressed():
	dice.roll()
	dice2.roll()
	
