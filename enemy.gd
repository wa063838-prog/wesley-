extends Node2D

@export var speed = 190
@export var max_health = 2
@export var damage = 1
enum EnemyType { STANDARD, FAST, TANK, BOSS }
@export var enemy_type : EnemyType = EnemyType.STANDARD
@onready var xp_orb_scene = preload("res://xp_orb.tscn")

var knockback_velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var direction_timer := 0.0

var orbit_angle: float
var orbit_radius: float

var surround_offset: Vector2
var angle_offset: float

@export var separation_scale := 1.2
@export var alignment_scale := 0.2
@export var cohesion_scale := 0.1
@export var arrival_damping := 100.0
@export var orbit_speed_base := 0.4
@export var orbit_speed_var := 0.18
@export var jitter_strength := 12.0


var orbit_speed := 0.4
var jitter_accum := Vector2.ZERO
var velocity_current := Vector2.ZERO

var update_group := 0

var player = null
var health

var is_dead := false

func _ready():
	update_group = randi() % EnemyManager.total_groups
	player = get_tree().get_first_node_in_group("player")
	EnemyManager.register_enemy(self)
	speed *= randf_range(0.92, 1.08)
	EnemyManager.total_kills = 0

	orbit_angle = randf() * TAU + randf_range(-0.5, 0.5)
	var base_radius = 80.0
	var density_factor = EnemyManager.enemies.size() * 0.15
	orbit_radius = base_radius + density_factor + randf_range(-20.0, 20.0)
	orbit_speed = orbit_speed_base + randf_range(-orbit_speed_var, orbit_speed_var)
	# small per-enemy jitter accumulator to break perfect symmetry
	jitter_accum = Vector2.ZERO
	
	match enemy_type:

		EnemyType.STANDARD:
			speed = 190
			max_health = 2
			damage = 1
			modulate = Color.WHITE

		EnemyType.FAST:
			speed = 280
			max_health = 1
			damage = 1
			modulate = Color(1, 0.6, 0.6)

		EnemyType.TANK:
			speed = 120
			max_health = 6
			damage = 2
			modulate = Color(0.6, 0.6, 1)

		EnemyType.BOSS:
			speed = 140
			max_health = 200
			damage = 4
			scale = Vector2(2,2)
			modulate = Color(1, 0.3, 0.3)
	
	health = max_health
	EnemyManager.register_enemy(self)
	speed *= randf_range(0.92, 1.08)
func _process(delta):
	if update_group != EnemyManager.frame_group:
		# Apply separation steering on off-frame groups
		var sep = EnemyManager.get_steering_force(self, "separation") * separation_scale
		var velocity = direction * speed + sep
		var max_speed = speed * 1.3
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		global_position += (velocity + knockback_velocity) * delta
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 600 * delta)
		return

	if player == null:
		return

	# advance orbit angle with small per-enemy variation and a tiny noise term
	orbit_angle += orbit_speed * delta
	# accumulate jitter noise (low-cost) and apply as small offset
	jitter_accum += Vector2(randf() - 0.5, randf() - 0.5) * jitter_strength * delta
	if jitter_accum.length() > 16:
		jitter_accum = jitter_accum.normalized() * 16

	var target_pos = player.global_position + Vector2.RIGHT.rotated(orbit_angle) * orbit_radius + jitter_accum

	direction = (target_pos - global_position).normalized()

	# Gather steering forces from EnemyManager
	var sep = EnemyManager.get_steering_force(self, "separation") * separation_scale
	var align = EnemyManager.get_steering_force(self, "alignment") * alignment_scale
	var cohes = EnemyManager.get_steering_force(self, "cohesion") * cohesion_scale
	
	# Arrival force: smooth deceleration near target
	var to_target = target_pos - global_position
	var dist_to_target = to_target.length()
	var arrival_force = Vector2.ZERO
	if dist_to_target > 5.0:
		var desired_velocity = to_target.normalized() * speed
		if dist_to_target < 100.0:
			desired_velocity = to_target.normalized() * speed * (dist_to_target / 100.0)
		arrival_force = (desired_velocity - velocity_current) * (arrival_damping * 0.01)
	
	# Combine all steering forces
	var steering = sep + align + cohes + arrival_force
	velocity_current = direction * speed + steering
	
	var max_speed = speed * 1.4
	if velocity_current.length() > max_speed:
		velocity_current = velocity_current.normalized() * max_speed

	global_position += (velocity_current + knockback_velocity) * delta
	resolve_overlap()
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 600 * delta)
	
func resolve_overlap():
	var neighbors = EnemyManager.get_nearby_enemies(global_position)
	var min_dist = 96.0 # ajuste pro tamanho do seu inimigo
	
	for neighbor in neighbors:
		if neighbor == self:
			continue
		
		var diff = global_position - neighbor.global_position
		var dist = diff.length()
		
		if dist == 0:
			continue
		
		if dist < min_dist:
			var overlap = min_dist - dist
			var push = diff.normalized() * (overlap * 0.5)
			
			global_position += push
			neighbor.global_position -= push

func take_damage(amount):

	if is_dead:
		return

	health -= amount
	
	if health <= 0:
		is_dead = true

		if enemy_type == EnemyType.BOSS:
			die_as_boss()
			return

	# inimigo normal
		if player and randf() < player.lifesteal_chance:
			player.heal(1)

		if player:
			player.register_kill()
	
		EnemyManager.total_kills += 1
		
		drop_xp()
		queue_free()

func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
		knockback_velocity = (global_position - body.global_position).normalized() * 150

func drop_xp():
	var orb = xp_orb_scene.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position

func _exit_tree():
	EnemyManager.unregister_enemy(self)

func die_as_boss():

	if player:
		player.register_kill()

	get_tree().paused = true
	get_tree().get_first_node_in_group("spawner").show_victory()

	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
