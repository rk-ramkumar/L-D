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
	hide()

func game_over(data):
	rich_text_label.text = rich_text_label.text.format(message[data])
	animation_player.play("fade_in")
	
