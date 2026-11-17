extends Node2D

@onready var label = $Label

var float_speed := 45.0
var lifetime := 0.6
var velocity := Vector2.ZERO

func setup(amount: int, crit := false):
	label.text = str(int(amount))

	if crit:
		label.modulate = Color(1, 0.8, 0.2)
		label.scale = Vector2(1.3, 1.3)
	else:
		label.modulate = Color(1, 1, 1)

	velocity = Vector2(randf_range(-60, 60), randf_range(-80, -30))

func _process(delta):
	position += velocity * delta
	velocity.y += 70 * delta

	lifetime -= delta
	modulate.a = min(lifetime / 0.6, 1.0)

	if lifetime <= 0.0:
		queue_free()
