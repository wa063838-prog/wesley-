extends StaticBody2D

@onready var collision = $CollisionShape2D

func open():
	visible = false
	
	if collision:
		collision.disabled = true
