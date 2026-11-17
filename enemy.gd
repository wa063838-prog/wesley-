extends CharacterBody2D

@export var speed: float = 100.0
@export var wander_radius: float = 250.0
@export var wait_min: float = 1.0
@export var wait_max: float = 3.0

@onready var agent: NavigationAgent2D = $NavigationAgent2D

var start_position: Vector2
var wait_timer: float = 0.0
var waiting: bool = false

@export var vision_distance: float = 450.0
@export var vision_angle: float = 100.0
@export var chase_speed: float = 170.0

var player: Node2D
var facing_direction: Vector2 = Vector2.DOWN
var chasing: bool = false

@export var search_time: float = 3.0

var last_seen_position: Vector2
var searching: bool = false
var search_timer: float = 0.0

@export var max_health: float = 3.0
@export var damage: int = 1
@export var attack_cooldown: float = 0.8

var health: float
var is_dead: bool = false
var attack_timer: float = 0.0
var attack_target: Node2D = null

func _ready():
	start_position = global_position

	player = get_tree().get_first_node_in_group("player")

	await get_tree().process_frame

	pick_new_destination()
	
	health = max_health


func _physics_process(delta):
	attack_timer -= delta

	if attack_target != null and is_instance_valid(attack_target):
		if attack_timer <= 0:
			attack_timer = attack_cooldown
			attack_target.take_damage(damage, global_position)

	# Detectou o player
	if can_see_player():
		chasing = true
		searching = false
		last_seen_position = player.global_position


	# =========================
	# PERSEGUINDO
	# =========================
	if chasing:

		if can_see_player():
			last_seen_position = player.global_position
			agent.target_position = player.global_position

		else:
			chasing = false
			searching = true
			search_timer = search_time
			agent.target_position = last_seen_position


		var next_position = agent.get_next_path_position()
		var direction = (next_position - global_position).normalized()

		if direction.length() > 0:
			facing_direction = direction

		velocity = direction * chase_speed

		move_and_slide()
		return


	# =========================
	# PROCURANDO
	# =========================
	if searching:

		agent.target_position = last_seen_position

		# Ainda não chegou no último local onde viu o player
		if not agent.is_navigation_finished():

			var next_position = agent.get_next_path_position()
			var direction = (next_position - global_position).normalized()

			if direction.length() > 0:
				facing_direction = direction

			velocity = direction * speed

			move_and_slide()
			return


		# Chegou no último local
		velocity = Vector2.ZERO
		search_timer -= delta

		if search_timer <= 0:
			searching = false
			waiting = false
			pick_new_destination()

		move_and_slide()
		return


	# =========================
	# ESPERANDO
	# =========================
	if waiting:

		velocity = Vector2.ZERO
		wait_timer -= delta

		if wait_timer <= 0:
			waiting = false
			pick_new_destination()

		move_and_slide()
		return


	# =========================
	# CHEGOU AO DESTINO DO WANDER
	# =========================
	if agent.is_navigation_finished():
		start_waiting()
		return


	# =========================
	# VAGANDO
	# =========================
	var next_position = agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()

	if direction.length() > 0:
		facing_direction = direction

	velocity = direction * speed

	move_and_slide()


func pick_new_destination():

	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)

	agent.target_position = start_position + random_offset


func start_waiting():

	waiting = true
	wait_timer = randf_range(wait_min, wait_max)
	velocity = Vector2.ZERO
	
func can_see_player() -> bool:
	if player == null or not is_instance_valid(player):
		return false

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	# Player longe demais
	if distance > vision_distance:
		return false

	var direction_to_player = to_player.normalized()

	# Calcula o ângulo entre a direção do inimigo e o player
	var dot = facing_direction.dot(direction_to_player)
	dot = clamp(dot, -1.0, 1.0)

	var angle = rad_to_deg(acos(dot))

	if angle > vision_angle / 2.0:
		return false

	# Raycast para verificar paredes
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)

	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return false

	return result.collider == player

func take_damage(amount: float):
	if is_dead:
		return

	health -= amount

	if health <= 0:
		die()


func die():
	if is_dead:
		return

	is_dead = true
	queue_free()
	
func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		attack_target = body


func _on_damage_area_body_exited(body):
	if body == attack_target:
		attack_target = null
