extends TextureRect

@export var front_texture: Texture2D
@export var back_texture: Texture2D

var flipped := false
var animating := false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = size / 2.0

	if front_texture:
		texture = front_texture

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		flip_card()

func flip_card():
	if animating:
		return

	animating = true
	pivot_offset = size / 2.0

	var tween = create_tween()

	tween.tween_property(self, "scale:x", 0.0, 0.12)

	tween.tween_callback(func():
		if flipped:
			if front_texture:
				texture = front_texture
		else:
			if back_texture:
				texture = back_texture

		flipped = not flipped
	)

	tween.tween_property(self, "scale:x", 1.0, 0.12)
	tween.finished.connect(func(): animating = false)
