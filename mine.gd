extends Node2D

@export var damage := 1.5
@export var radius := 400.0
@export var explode_delay := 1.0

func _ready():
	await get_tree().create_timer(explode_delay).timeout
	explode()

func explode():
	for enemy in EnemyManager.enemies:
		if not is_instance_valid(enemy):
			continue
			
		var dist_sq = global_position.distance_squared_to(enemy.global_position)
		if dist_sq <= radius * radius:
			enemy.take_damage(damage)

	queue_free()
