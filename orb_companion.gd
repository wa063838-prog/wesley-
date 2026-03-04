extends Node2D

@export var orbit_radius: float = 100.0
@export var rotation_speed: float = 3.0
@export var damage: float = 1.0
@export var shoot_cooldown: float = 0.8
@export var search_interval: float = 0.4
@export var bullet_scene: PackedScene

var player: Node2D
var angle := 0.0
var shoot_timer := 0.0
var search_timer := 0.0
var nearby_enemies: Array = []

func _ready():
	player = get_tree().get_first_node_in_group("player")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if not is_instance_valid(player):
		queue_free()
		return

	# ORBITAR
	angle += rotation_speed * delta
	var offset := Vector2(cos(angle), sin(angle)) * orbit_radius
	global_position = player.global_position + offset

	# BUSCAR INIMIGOS DE TEMPOS EM TEMPOS
	search_timer += delta
	if search_timer >= search_interval:
		search_timer = 0.0
		update_nearby_enemies()

	# ATIRAR
	shoot_timer += delta
	if shoot_timer >= shoot_cooldown:
		shoot_timer = 0.0
		
		shoot_nearest_enemy()

# ------------------------------
# BUSCA OTIMIZADA
# ------------------------------

func update_nearby_enemies():
	nearby_enemies.clear()

	for e in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(e):
			continue
		
		var dist = global_position.distance_to(e.global_position)
		if dist <= 9999:
			nearby_enemies.append(e)

# ------------------------------
# TIRO
# ------------------------------

func shoot_nearest_enemy():
	# Limpa inimigos mortos
	nearby_enemies = nearby_enemies.filter(
		func(e): return is_instance_valid(e)
	)

	if nearby_enemies.is_empty():
		return

	var closest_enemy: Node2D = null
	var closest_distance := INF

	for e in nearby_enemies:
		var dist = global_position.distance_to(e.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = e

	if closest_enemy:
		shoot(closest_enemy)


func shoot(target: Node2D):

	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position

	var dir = (target.global_position - global_position).normalized()
	bullet.direction = dir
	bullet.damage = damage
