extends Node2D

@export var enemy_scene : PackedScene
@export var spawn_radius = 600
@export var base_spawn_time = 1.5   # valor inicial configurável

var spawn_time = 1.5
var timer = 0
var game_time = 0

func _process(delta):

	timer += delta
	game_time += delta

	# spawn vai ficando mais rápido com o tempo
	spawn_time = max(0.5, base_spawn_time - game_time * 0.01)

	if timer >= spawn_time:
		timer = 0
		spawn_enemy()


func spawn_enemy():

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var camera = player.get_node_or_null("Camera2D")
	if camera == null:
		return

	var viewport_rect = get_viewport().get_visible_rect()
	var screen_size = viewport_rect.size * camera.zoom
	
	# metade da diagonal da tela (garante fora da visão)
	var spawn_distance = screen_size.length() / 2 + 1500
	
	# quantidade aumenta com o tempo
	var enemy_count = 1 + int(game_time / 40)

	for i in enemy_count:

		var enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(enemy)

		var angle = randf() * TAU
		var direction = Vector2.RIGHT.rotated(angle)

		enemy.global_position = player.global_position + direction * spawn_distance
