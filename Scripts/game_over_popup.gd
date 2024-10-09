extends CanvasLayer

var message = {
	"victory": {
		text = "Congratulations ! You Won !",
		color = "198754"
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
	AudioController.level_completion.play()
	AudioController.secondary_background.stop()

func _on_exit_button_clicked():
	NotificationManager.back_request(name)

func _on_play_again_button_clicked():
	get_tree().reload_current_scene()
