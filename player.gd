@tool
extends CharacterBody2D

@export var preview_weapon: WeaponData:
	set(value):
		preview_weapon = value
		update_visual()

@export var preview_character: CharacterData:
	set(value):
		preview_character = value
		update_visual()

@export var max_health : int = 3
@export var speed = 500.0
@export var invincibility_time: float = 0.6
@export var knockback_force: float = 600.0
@export var knockback_decay: float = 1000.0
@export var hit_flash : ColorRect
@export var xp_bar : ProgressBar
@export var level_label : Label
@export var levelup_ui_scene : PackedScene
@export var heart_scene : PackedScene
@export var orb_scene : PackedScene
@onready var sprite = $Sprite2D
@onready var ammo_label = $AmmoLabel
@onready var Weapon = $Weapon
@onready var Weapon_sprite: Sprite2D = $Weapon/Sprite2D 
@onready var muzzle: Marker2D = $Weapon/Muzzle
@export var mine_scene: PackedScene
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
@export var turret_scene: PackedScene
@onready var scrap_label = get_tree().get_first_node_in_group("scrap_ui")

var mine_enabled := false
var mine_kill_counter := 0

var mine_damage := 1.5
var mine_radius := 90.0
var mine_delay := 0.6
var mine_kill_requirement = 10

var scrap := 0
var turret_count := 0
var max_turrets := 3
var turret_cost := 10

@export var default_weapon: WeaponData
var current_weapon: WeaponData
var shoot_timer := 0.0
var ammo_in_mag: int = 0
var is_reloading: bool = false
var reload_timer: float = 0.0

var health
var can_take_damage = true
var knockback_velocity = Vector2.ZERO

var xp_to_next_level = 10
var level = 1
var xp = 0

var lifesteal_chance := 0.0

var stats = {
	"damage": 0.0,
	"speed": 500.0,
	"magnet": 150.0
}

@onready var hearts_container = get_tree().get_first_node_in_group("hearts_container")

var heart_full = preload("res://heart_full.png")
var heart_empty = preload("res://heart_empty.png")

var nearby_enemy: Array = []

var survival_time := 0.0
var total_kills := 0

var airstrike_enabled := false
var airstrike_kill_counter := 0
var  airstrike_kill_requirement := 20
var airstrike_damage := 50
var airstrike_radius := 120.0
# ------------------------------------
# READY
# ------------------------------------
func _ready():
	MusicManager.play_gameplay()
	if Engine.is_editor_hint():
		update_visual()
		return

	add_to_group("player")
	process_mode = Node.PROCESS_MODE_PAUSABLE

	# ===== RESET DA RUN =====
	max_health = 3
	health = max_health

	owned_upgrades.clear()

	stats["damage"] = 0.0
	stats["speed"] = 500.0
	stats["magnet"] = 150.0

	lifesteal_chance = 0.0

	mine_enabled = false
	mine_kill_counter = 0
	mine_damage = 1.5
	mine_radius = 90.0
	mine_delay = 0.6
	mine_kill_requirement = 10

	airstrike_enabled = false
	airstrike_kill_counter = 0
	airstrike_kill_requirement = 20
	airstrike_damage = 50
	airstrike_radius = 120.0

	scrap = 0
	turret_count = 0

	level = 1
	xp = 0
	xp_to_next_level = 10
	total_kills = 0
	survival_time = 0.0

	if scrap_label:
		scrap_label.text = "⚙ Scrap: " + str(scrap)

	# ===== APLICA PERSONAGEM PRIMEIRO =====
	if RunData.selected_character:
		max_health += RunData.selected_character.bonus_health
		stats["speed"] += RunData.selected_character.bonus_speed
		
		if RunData.selected_character.sprite_texture:
			$Sprite2D.texture = RunData.selected_character.sprite_texture
		elif RunData.selected_character.icon:
			$Sprite2D.texture = RunData.selected_character.icon

	# ===== APLICA ARMA =====
	var base_weapon = RunData.selected_weapon if RunData.selected_weapon else default_weapon
	current_weapon = base_weapon.duplicate(true)

	if current_weapon:
		if current_weapon.weapon_texture:
			$Weapon/Sprite2D.texture = current_weapon.weapon_texture
		elif current_weapon.icon:
			$Weapon/Sprite2D.texture = current_weapon.icon

		$Weapon/Sprite2D.scale = Vector2.ONE * current_weapon.visual_scale
		ammo_in_mag = current_weapon.mag_size
		update_ammo_label()

	# ===== AGORA DEFINE VIDA =====
	health = max_health

	# ===== LIMPA E CRIA CORAÇÕES =====
	print("CONTAINER DOS CORAÇÕES: ", hearts_container)

	if hearts_container:
		print("CAMINHO: ", hearts_container.get_path())
	if hearts_container:
		for child in hearts_container.get_children():
			child.queue_free()

		for i in range(max_health):
			add_heart()

	update_scrap_ui()
	update_hearts()
	update_level_label()
	update_xp_bar()

	if hit_flash:
		hit_flash.modulate.a = 0.0

func add_heart():
	var new_heart = heart_scene.instantiate()
	hearts_container.add_child(new_heart)


# ------------------------------------
# ATUALIZA CORAÇÕES
# ------------------------------------
func update_hearts():
	if hearts_container == null:
		return

	var heart_index := 0

	for child in hearts_container.get_children():
		if child is TextureRect:
			if heart_index < health:
				child.texture = heart_full
			else:
				child.texture = heart_empty

			heart_index += 1

# ------------------------------------
# INVENCIBILIDADE (PISCAR)
# ------------------------------------
func start_invincibility():
	
	var blink_times = 6
	var blink_interval = invincibility_time / blink_times
	
	for i in range(blink_times):
		$Sprite2D.visible = false
		await get_tree().create_timer(blink_interval / 2).timeout
		$Sprite2D.visible = true
		await get_tree().create_timer(blink_interval / 2).timeout
	
	can_take_damage = true


# ------------------------------------
# TOMAR DANO
# ------------------------------------
func take_damage(amount, source_position := Vector2.INF):

	if not can_take_damage:
		return
		
	can_take_damage = false
	
	health -= amount
	update_hearts()
	
	Engine.time_scale = 0.04
	await get_tree().create_timer(0.005, true).timeout
	Engine.time_scale = 1.0
	
	if is_instance_valid(hit_flash):
		hit_flash.modulate.a = 0.1
		await get_tree().create_timer(0.05, true).timeout

		if is_instance_valid(hit_flash):
			hit_flash.modulate.a = 0.0
	
	# Aplicar knockback
	if source_position != Vector2.INF:
		var knockback_dir = (global_position - source_position).normalized()
		knockback_velocity = knockback_dir * knockback_force

	
	if health <= 0:
		die()
		return
		
	start_invincibility()
	
	
func flash_hit():
	if not hit_flash:
		return

	hit_flash.modulate.a = 0.6
	await get_tree().create_timer(0.08, true).timeout
	hit_flash.modulate.a = 0.0

# ------------------------------------
# MOVIMENTO
# ------------------------------------
func _physics_process(delta):

	if Engine.is_editor_hint():
		return

	if not get_tree().paused:
		survival_time += delta

	# =========================
	# 🔄 SISTEMA DE RELOAD
	# =========================
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			is_reloading = false
			ammo_in_mag = current_weapon.mag_size
			update_ammo_label()

	# =========================
	# 🔫 TIRO
	# =========================
	if Input.is_action_just_pressed("shoot"):
		if not is_reloading:
			try_shoot()

	if ammo_in_mag <= 0 and not is_reloading:
		start_reload()

	# =========================
	# 🔄 ROTAÇÃO DA ARMA
	# =========================
	var dir: Vector2 = get_global_mouse_position() - Weapon.global_position
	Weapon.rotation = dir.angle() - deg_to_rad(90)
	Weapon_sprite.flip_v = dir.x > 0

	# 🔄 Espelha apenas o sprite da arma

	# =========================
	# 🏃 MOVIMENTO
	# =========================
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_rigth"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if direction.x < 0:
		$Sprite2D.flip_h = false
	elif direction.x > 0:
		$Sprite2D.flip_h = true

	var input_velocity = direction.normalized() * stats["speed"]

	velocity = input_velocity + knockback_velocity
	move_and_slide()

	if knockback_decay != null:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)


# ------------------------------------
# TIRO
# ------------------------------------

func shoot():
	if not current_weapon or not current_weapon.bullet_scene:
		return

	for i in range(current_weapon.projectile_count):
		var bullet = current_weapon.bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)

		bullet.global_position = muzzle.global_position

		var dir = (get_global_mouse_position() - muzzle.global_position).normalized()

		if current_weapon.spread_degrees > 0.0:
			var ang = deg_to_rad(randf_range(-current_weapon.spread_degrees, current_weapon.spread_degrees))
			dir = dir.rotated(ang)

		bullet.direction = dir
		bullet.damage = current_weapon.damage + stats["damage"]
		bullet.max_distance = current_weapon.max_distance
		bullet.pierce = current_weapon.pierce
		bullet.rotation = dir.angle()

	# 🔊 toca som UMA vez
	if current_weapon.shoot_sound:
		shoot_sound.stream = current_weapon.shoot_sound
		shoot_sound.pitch_scale = randf_range(0.95, 1.05)
		shoot_sound.play()

func try_shoot():
	if not current_weapon:
		return
		
	if ammo_in_mag <= 0:
		return
		
	shoot()
	ammo_in_mag -= 1
	update_ammo_label()
	
func start_reload():
	if not current_weapon:
		return
		
	is_reloading = true
	reload_timer = current_weapon.reload_time
# ------------------------------------
# SISTEMA DE XP
# ------------------------------------

func add_xp(amount):
	xp += amount
	update_xp_bar()
	
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp = 0
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	update_xp_bar()
	update_level_label()
	
	show_level_up_screen()
	
	update_xp_bar()
	
func update_xp_bar():
	if xp_bar:
		xp_bar.max_value = xp_to_next_level
		xp_bar.value = xp

#levellabel
func update_level_label():
	if level_label:
		level_label.text = "LV " + str(level)

var all_upgrades = [
	{
		"id": "speed",
		"name": "Agilidade",
		"description": "Aumenta velocidade em 15%",
		"type": "speed",
		"value": 0.15,
		"rarity": "common",
		"max_level": 5
	},
	{
		"id": "damage",
		"name": "Força",
		"description": "Aumenta dano em 1",
		"type": "damage",
		"value": 1,
		"rarity": "common",
		"max_level": 10
	},
	{
		"id": "magnet",
		"name": "Magnetismo",
		"description": "Aumenta alcance de coleta",
		"type": "magnet",
		"value": 30,
		"rarity": "rare",
		"max_level": 5
	},
	{
	"id": "health",
	"name": "Vitalidade",
	"description": "Aumenta vida máxima em 1",
	"type": "health",
	"value": 1,
	"rarity": "rare",
	"max_level": 5
},
{
	"id": "orb",
	"name": "Orb Espiritual",
	"description": "Invoca uma esfera que gira ao seu redor",
	"type": "companion_orb",
	"value": 1,
	"rarity": "rare",
	"max_level": 3
},
{
	"id": "pierce",
	"name": "Perfuração",
	"description": "Projéteis atravessam +1 inimigo",
	"type": "pierce",
	"value": 1,
	"rarity": "rare",
	"max_level": 5
},{
	"id": "lifesteal",
	"name": "Vampirismo",
	"description": "1% de chance de recuperar 1 de vida ao matar inimigos",
	"type": "lifesteal",
	"value": 0.01,
	"rarity": "rare",
	"max_level": 5
},{
	"id": "mine",
	"name": "Campo Minado",
	"description": "A cada 10 inimigos mortos, cria uma mina explosiva",
	"type": "mine",
	"value": 10,
	"rarity": "rare",
	"max_level": 5
},{ "id": "airstrike",
	"name": "Ataque Aéreo",
	"description": "A cada 20 inimigos mortos, um míssil cai do céu",
	"type": "airstrike",
	"value": 1 ,
	"rarity": "rare",
	"max_level": 4}

]
var owned_upgrades = {}

func apply_upgrade(upgrade_data):
	var id = upgrade_data["id"]

	if not owned_upgrades.has(id):
		owned_upgrades[id] = 0

	owned_upgrades[id] += 1

	match upgrade_data["type"]:
		"speed":
			stats["speed"] += stats["speed"] * upgrade_data["value"]

		"damage":
			stats["damage"] += upgrade_data["value"]

		"companion_orb":
			spawn_orb()

		"magnet":
			stats["magnet"] += upgrade_data["value"]
		"airstrike":
			airstrike_enabled = true
			airstrike_kill_requirement = max(5, airstrike_kill_requirement - 3)
			airstrike_damage += 15
		"health":
			max_health += upgrade_data["value"]
			health += upgrade_data["value"]

			# 🔥 Reconstrói completamente os corações
			for child in hearts_container.get_children():
				child.free()

			for i in range(max_health):
				add_heart()

			update_hearts()
		"lifesteal":
			lifesteal_chance += upgrade_data["value"]
			update_hearts()

		"pierce":
			current_weapon.pierce += upgrade_data["value"]
		
		"mine":
			mine_enabled = true
			mine_kill_requirement = upgrade_data["value"]


func show_level_up_screen():
	
	var ui = levelup_ui_scene.instantiate()
	
	get_tree().get_root().add_child(ui)
	
	
	var options = get_random_upgrades(3)
	ui.setup(self, options)
	
	get_tree().paused = true

	
func get_random_upgrades(amount := 3):
	var pool = all_upgrades.duplicate()
	pool.shuffle()
	return pool.slice(0, amount)
	
func spawn_orb():
	var orb = preload("res://orb_companion.tscn").instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position
	
func update_visual():
	if not Engine.is_editor_hint():
		return

	# PERSONAGEM
	if preview_character:
		if preview_character.sprite_texture:
			$Sprite2D.texture = preview_character.sprite_texture
		elif preview_character.icon:
			$Sprite2D.texture = preview_character.icon

	# ARMA
	if preview_weapon:
		if preview_weapon.weapon_texture:
			$Weapon/Sprite2D.texture = preview_weapon.weapon_texture
		elif preview_weapon.icon:
			$Weapon/Sprite2D.texture = preview_weapon.icon

		$Weapon/Sprite2D.scale = Vector2.ONE * preview_weapon.visual_scale

func heal(amount):
	health = min(health + amount, max_health)
	update_hearts()

		
func _process(delta):

	if Engine.is_editor_hint():
		update_visual()
		return

func _enter_tree():
	if Engine.is_editor_hint():
		update_visual()
		
func register_kill():
	total_kills += 1
	
	if airstrike_enabled:
		airstrike_kill_counter += 1
		
		if airstrike_kill_counter >= airstrike_kill_requirement:
			airstrike_kill_counter = 0
			spawn_airstrike()
	
	if mine_enabled:
		mine_kill_counter += 1

		if mine_kill_counter >= mine_kill_requirement:
			mine_kill_counter = 0
			spawn_mine()
func spawn_mine():
	if not mine_scene:
		return

	var mine = mine_scene.instantiate()
	get_tree().current_scene.add_child(mine)
	mine.global_position = global_position

	# passa stats pra mina
	if mine.has_method("setup"):
		mine.setup(mine_damage, mine_radius, mine_delay)
		
func die():

	var game_over = preload("res://GameOver.tscn").instantiate()

	var canvas = get_tree().current_scene.get_node("CanvasLayer")
	canvas.add_child(game_over)

	game_over.setup(survival_time, total_kills)

	get_tree().paused = true
	set_physics_process(false)
	set_process(false)
	visible = false
	
func update_ammo_label():

	if not ammo_label:
		return

	if is_reloading:
		ammo_label.text = "RECARREGANDO"
	else:
		ammo_label.text = str(ammo_in_mag) + " / " + str(current_weapon.mag_size)
		
func spawn_airstrike():

	var valid_enemies := []

	for enemy in EnemyManager.enemies:
		if is_instance_valid(enemy):
			valid_enemies.append(enemy)

	if valid_enemies.is_empty():
		return

	var target = valid_enemies[randi() % valid_enemies.size()]

	var missile_scene = preload("res://airstrike_missile.tscn")
	var missile = missile_scene.instantiate()

	get_tree().current_scene.add_child(missile)

	# Spawn acima do inimigo
	missile.global_position = target.global_position + Vector2(0, -800)

	# IMPORTANTE: passar o inimigo, não a posição
	missile.setup(target, airstrike_damage, airstrike_radius)


func _on_scientist_entrance_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

	
func add_scrap(amount):

	scrap += amount
	
	update_scrap_ui()
	
func _input(event):

	# =========================
	# ⏸️ PAUSE (ESC)
	# =========================
	if event.is_action_pressed("ui_cancel"):
		var pause_menu = get_tree().get_first_node_in_group("pause_menu")

		if pause_menu:
			if get_tree().paused:
				pause_menu.close()
			else:
				pause_menu.open()

		return


	# ⛔ bloqueia resto se estiver pausado
	if get_tree().paused:
		return


	# =========================
	# 🛠️ BUILD TURRET
	# =========================
	if event.is_action_pressed("build_turret"):

		if turret_count >= max_turrets:
			return

		if scrap < turret_cost:
			return

		build_turret()

		scrap -= turret_cost
		turret_count += 1

		update_scrap_ui()

func build_turret():

	if turret_scene == null:
		return

	var turret = turret_scene.instantiate()

	get_tree().current_scene.add_child(turret)

	turret.global_position = global_position + Vector2(40,0)
	
func update_scrap_ui():

	if scrap_label:
		scrap_label.text = "⚙ Scrap: " + str(scrap)
