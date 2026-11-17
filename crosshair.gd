extends TextureRect

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	if get_tree().paused:
		visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	position = get_viewport().get_mouse_position() - (size * scale) / 2
