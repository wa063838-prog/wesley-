extends Node2D

@export var standard_enemy_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
@export var boss_scene: PackedScene
@export var base_spawn_time: float = 1.5
@export var victory_scene : PackedScene
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

var victory_shown := false

var boss_spawned := false

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


	if game_time >= 5 and not boss_spawned:
		print('SPAWNANDO BOSS')
		spawn_boss()
		boss_spawned = true
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
	if boss_spawned:
		return

	EnemyManager.enemies = EnemyManager.enemies.filter(func(e): return is_instance_valid(e))

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

			var enemy = standard_enemy_scene.instantiate()
			var t = choose_enemy_type()

			# seta o tipo no inimigo (0,1,2)
			enemy.enemy_type = t
			
			get_tree().current_scene.add_child(enemy)


			# Cluster compacto
			var spread = Vector2(
				randf_range(-150, 150),
				randf_range(-150, 150)
			)

			enemy.global_position = player.global_position + direction * spawn_distance + spread

func get_spawn_weights():

	var weights = {
		"standard": 0.0,
		"fast": 0.0,
		"tank": 0.0
	}

	var t = game_time

	# 0 - 2 minutos
	if t < 120:
		var progress = t / 120.0
		weights["standard"] = lerp(1.0, 0.2, progress)
		weights["fast"] = lerp(0.0, 0.8, progress)

	# 2 - 4 minutos
	elif t < 240:
		var progress = (t - 120) / 120.0
		weights["fast"] = lerp(1.0, 0.3, progress)
		weights["tank"] = lerp(0.0, 0.7, progress)

	# 4+ minutos
	else:
		weights["standard"] = 0.3
		weights["fast"] = 0.3
		weights["tank"] = 0.4

	return weights
	
func choose_enemy_type() -> int:
	var t = game_time
	var fade := 20.0 # segundos de transição suave (ajuste)

	# 0-2 min: standard -> no final começa a entrar fast
	if t < 120.0:
		var out = clamp((t - (120.0 - fade)) / fade, 0.0, 1.0)
		return 1 if randf() < out else 0

	# 2-4 min: fast -> no final começa a entrar tank
	if t < 240.0:
		var out = clamp((t - (240.0 - fade)) / fade, 0.0, 1.0)
		return 2 if randf() < out else 1

	# 4-6 min: tank -> no final começa a misturar
	if t < 360.0:
		var out = clamp((t - (360.0 - fade)) / fade, 0.0, 1.0)
		if randf() < out:
			return randi() % 3 # mistura começando
		return 2

	# 6-8 min: mistura total
	if t < 480.0:
		return randi() % 3

	# depois disso (boss), tanto faz
	return 0
		
func spawn_boss():

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var boss = boss_scene.instantiate()
	get_tree().current_scene.add_child(boss)

	boss.enemy_type = boss.EnemyType.BOSS

	var offset = Vector2(0, -200)
	boss.global_position = player.global_position + offset

func show_victory():
	
	if victory_shown:
		return
	
	victory_shown = true
	# ✅ trava o spawner
	set_process(false)

	# ✅ trava o player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		player.set_process_input(false)

	# ✅ trava todos os inimigos (inclusive boss, se ainda existir)
	for e in EnemyManager.enemies:
		if is_instance_valid(e):
			e.set_process(false)
			e.set_physics_process(false)

	# ✅ mostra a UI
	var layer = victory_scene.instantiate()
	add_child(layer)
	layer.get_node("VictoryUI").setup(game_time, EnemyManager.total_kills)

	# ✅ garante mouse livre pra clicar (caso seu jogo mexa nisso)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
