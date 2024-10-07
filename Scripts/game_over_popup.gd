extends CanvasLayer

var message = {
	"victory": {
		text = "Congratulations ! You Won !",
		color = "Ffd700"
	},
	"defeat":{ 
		text = "Game Over !  You Lost !",
		color = "ff5055"
	}
}
@onready var rich_text_label = $Control/Panel/MarginContainer/RichTextLabel
@onready var animation_player = $Control/AnimationPlayer

func _ready():
	animation_player.play("fade_in")


func _on_exit_button_clicked():
	pass # Replace with function body.
