extends Area2D

@export var damage = 1

var speed = 10000
var direction = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
