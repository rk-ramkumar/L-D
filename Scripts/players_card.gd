extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label
var player = {}

func _ready():
	label.text = player.get("name", "s")
	if player.has("icon"):
		texture_rect.texture = load(player.icon)
