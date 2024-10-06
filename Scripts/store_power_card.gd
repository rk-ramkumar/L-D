extends Panel

@onready var texture_rect = $Panel/VBoxContainer/TextureRect
@onready var rich_text_label = $Panel/VBoxContainer/RichTextLabel
@onready var label = $Panel/VBoxContainer/Panel/Label
@onready var animation_player = $AnimationPlayer
@onready var price_panel = $Panel/VBoxContainer/Panel
@onready var panel = $Panel

var data
var extra_cost = 0
var parent
var selected = false

func _ready():
	var new_stylebox_panel = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", new_stylebox_panel)
	price_panel.add_theme_stylebox_override("panel", price_panel.get_theme_stylebox("panel").duplicate())
	panel.add_theme_stylebox_override("panel", PowersManager.bg[data.used_on])
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
				parent.selected_card = null
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
