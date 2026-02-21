extends Area2D

@export var damage = 1
@export var max_distance: float = 1200
@export var pierce: int = 0


var start_position: Vector2
var speed = 1000
var direction = Vector2.ZERO
var initialized := false
var hit_enemies := []
func _physics_process(delta):

	if not initialized:
		start_position = global_position
		initialized = true

	global_position += direction * speed * delta

	if global_position.distance_to(start_position) > max_distance:
		queue_free()

	var hit_enemies := []

func _on_area_entered(area):
	var enemy = area.get_parent()

	if enemy in hit_enemies:
		return

	if enemy.has_method("take_damage"):
		hit_enemies.append(enemy)

		enemy.take_damage(damage)

		# Reduz dano ao atravessar
		damage -= 1
		pierce -= 1
		
		
		$Sprite2D.modulate *= Color(0.9, 0.9, 0.9)

		# Se o dano acabar ou pierce acabar, destrói
		if damage <= 0 or pierce <= 0:
			queue_free()
		else:
			pierce -= 1
