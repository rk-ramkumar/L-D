extends Panel

@onready var power_texture = $MarginContainer/VBoxContainer/PowerTexture
@onready var card_count = $MarginContainer/VBoxContainer/Panel/CardCount
@onready var animation_player = $AnimationPlayer

var count = 0
var data = {}
var picked
var tween
var disable_color = "181818db"
var parent
var shake_duration = 0.3  # Total duration of the shake
var shake_strength = 100   # How far the card moves in pixels during shake

func _ready():
	parent = get_parent().get_owner()
	power_texture.texture = load(data.image)
	update_count(1)

func update_count(amount):
	count += amount
	if count > 1:
		card_count.text = "X"+str(count)

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			select()
		if event.is_released():
			if picked:
				_lerp_to_start()

	if event is InputEventScreenDrag:
		_handle_drag(event)

func select():
	animation_player.play("select")

func _handle_drag(event):
	if !picked:
		picked = duplicate(true)
		picked.scale = Vector2(2, 2)
		parent.top_level_props.add_child(picked)
	modulate = Color(disable_color)
	picked.position = event.position

func _lerp_to_start():
	if tween:
		tween.kill()
	
	tween = create_tween()

	# Apply the shake effect first before transitioning
	_apply_shake_effect(picked)
	tween.tween_callback(func():
		picked.queue_free()
		modulate = Color.WHITE
		picked = null
		tween.kill()
	)

# Function to apply a shake effect to the card
func _apply_shake_effect(card):
	if not card:
		return

	var original_position = card.position
	var original_rotation = card.rotation_degrees

	# Shake the position and rotation back and forth
	for i in range(6):  # Shake back and forth a few times
		var offset = Vector2(randi() % shake_strength - shake_strength / 2, 0)  # Random x offset
		var shake_time = shake_duration / 6  # Short time for each shake
		# Tween the card position and rotation back and forth
		tween.tween_property(card, "position", original_position + offset, shake_time).set_ease(Tween.EASE_IN_OUT)


