extends Node2D

@export var enemy_scene: PackedScene
@export var base_spawn_time: float = 1.5

# 🔥 Limite de inimigos ativos
@export var base_enemy_cap: int = 100
@export var cap_growth_per_minute: int = 50

var spawn_time: float = 1.5
var timer: float = 0.0
var game_time: float = 0.0

var dynamic_enemy_cap := 580
var min_enemy_cap := 250
var max_enemy_cap := 700

var fps_timer := 0.0


func _process(delta):

	timer += delta
	game_time += delta

	# ------------------------------
	# AJUSTE AUTOMÁTICO DE PERFORMANCE
	# ------------------------------

	fps_timer += delta

	if fps_timer >= 1.0:
		fps_timer = 0.0
		
		var fps = Engine.get_frames_per_second()

		if fps < 50:
			dynamic_enemy_cap -= 50
		elif fps > 58:
			dynamic_enemy_cap += 25

		dynamic_enemy_cap = clamp(dynamic_enemy_cap, min_enemy_cap, max_enemy_cap)


	# ------------------------------
	# SPAWN
	# ------------------------------

	spawn_time = max(0.7, base_spawn_time - game_time * 0.005)

	if timer >= spawn_time:
		timer = 0
		try_spawn()



# ------------------------------
# CAP DINÂMICO
# ------------------------------

func get_enemy_cap() -> int:
	var minutes = game_time / 60.0
	return base_enemy_cap + int(minutes * cap_growth_per_minute)


# ------------------------------
# SPAWN CONTROLADO
# ------------------------------

func try_spawn():

	if EnemyManager.enemies.size() >= dynamic_enemy_cap:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var camera = player.get_node_or_null("Camera2D")
	if camera == null:
		return

	var viewport_rect = get_viewport().get_visible_rect()
	var screen_size = viewport_rect.size * camera.zoom
	var spawn_distance = screen_size.length() / 2 + 1600

	# Quantidade cresce suave
	var enemy_count = 1 + int(game_time / 60)

	# Quantidade de direções ativas (máx 4)
	var directions_count = clamp(1 + int(game_time / 90), 1, 4)

	for d in directions_count:

		var base_angle = randf() * TAU
		var direction = Vector2.RIGHT.rotated(base_angle)

		for i in enemy_count:

			if EnemyManager.enemies.size() >= dynamic_enemy_cap:
				return

			var enemy = enemy_scene.instantiate()
			get_parent().add_child(enemy)



			# Cluster compacto
			var spread = Vector2(
				randf_range(-150, 150),
				randf_range(-150, 150)
			)

			enemy.global_position = player.global_position + direction * spawn_distance + spread
