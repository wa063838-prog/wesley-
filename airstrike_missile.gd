extends Node2D

var target: Node2D
var damage := 50
var radius := 300.0
var speed := 600.0
func setup(enemy: Node2D, dmg: int, rad: float):
	target = enemy
	damage = dmg
	radius = rad


func _process(delta):

	# Se o alvo morreu antes do míssil chegar
	if not is_instance_valid(target):
		explode()
		return

	# Segue o inimigo
	global_position = global_position.move_toward(
		target.global_position,
		speed * delta
	)

	# Quando chegar perto explode
	if global_position.distance_to(target.global_position) < 10:
		explode()


func explode():

	print("Centro explosão:", global_position)

	for enemy in EnemyManager.enemies:
		if not is_instance_valid(enemy):
			continue

		var dist = enemy.global_position.distance_to(global_position)

		if dist <= radius:
			enemy.take_damage(damage)

	queue_free()
