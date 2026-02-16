extends Area2D

@export var radius: float = 100.0
@export var rotation_speed: float = 3.0
@export var damage: float = 1.0
@export var shoot_cooldown: float = 1.0
@export var bullet_scene: PackedScene

var player
var angle: float = 0.0
var shoot_timer: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_instance_valid(player):
		queue_free()
		return
	
	# Movimento circular
	angle += rotation_speed * delta
	var offset = Vector2(cos(angle), sin(angle)) * radius
	global_position = player.global_position + offset
	
	# Sistema de tiro
	shoot_timer += delta
	
	if shoot_timer >= shoot_cooldown:
		shoot_timer = 0
		shoot_nearest_enemy()
		

func shoot_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if enemies.size() == 0:
		return
	
	var closest_enemy = null
	var closest_distance = INF
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var dist = global_position.distance_to(enemy.global_position)
		
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = enemy
	
	if closest_enemy:
		shoot(closest_enemy)

func shoot(target):
	if not bullet_scene:
		return
	
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = global_position
	
	var dir = (target.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.damage = damage
