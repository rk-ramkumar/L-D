extends Panel

@onready var texture_rect = $Panel/VBoxContainer/TextureRect
@onready var rich_text_label = $Panel/VBoxContainer/RichTextLabel
@onready var label = $Panel/VBoxContainer/Panel/Label
@onready var animation_player = $AnimationPlayer

var data
var extra_cost = 0
var parent
var selected = false

func _ready():
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)
	texture_rect.texture = load(data.image)
	rich_text_label.text = rich_text_label.text.format(data)
	label.text = label.text.format(data)

	match sign(extra_cost):
		-1:
			label.append_text("[color=red]-(%s)[/color]"%[abs(extra_cost)])
		1:
			label.append_text("[color=green]+[/color](%s)"%[ extra_cost])

func _on_panel_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_released():
			if selected:
				deselect()
			else:
				select()
				parent.card_selected(self)
			AudioController.popsound.play()

func select():
	selected = true
	animation_player.play("select")

func deselect():
	selected = false
	animation_player.play_backwards("select")