extends CharacterBody2D

@export var bullet_scene : PackedScene
@export var max_health : int = 3
@export var speed = 500.0
@export var invincibility_time: float = 0.6
@export var knockback_force: float = 1000.0
@export var knockback_decay: float = 1200.0
@export var hit_flash : ColorRect
@export var xp_bar : ProgressBar
@export var level_label : Label
@export var levelup_ui_scene : PackedScene
@export var heart_scene : PackedScene
@export var orb_scene : PackedScene



var health
var can_take_damage = true
var knockback_velocity = Vector2.ZERO

var xp_to_next_level = 10
var level = 1
var xp = 0

var stats = {
	"damage": 1.0,
	"speed": 500.0,
	"magnet": 150.0
}



@onready var hearts_container = get_parent().get_node("ui/hearts")

var heart_full = preload("res://heart_full.png")
var heart_empty = preload("res://heart_empty.png")

# ------------------------------------
# READY
# ------------------------------------
func _ready():
	health = max_health
	
	# Cria os corações iniciais
	for i in range(max_health):
		add_heart()

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

	for i in range(hearts_container.get_child_count()):
		var heart = hearts_container.get_child(i)
		
		if i < health:
			heart.texture = heart_full
		else:
			heart.texture = heart_empty

# ------------------------------------
# INVENCIBILIDADE (PISCAR)
# ------------------------------------
func start_invincibility():
	
	var blink_times = 6
	print("invincibility_time:", invincibility_time)
	print("blink_times:", blink_times)
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
	print("knockback_force:", knockback_force)

	if not can_take_damage:
		return
		
	can_take_damage = false
	
	health -= amount
	update_hearts()
	
	Engine.time_scale = 0.01
	await get_tree().create_timer(0.005, true).timeout
	Engine.time_scale = 1.0
	
	hit_flash.modulate.a = 0.1
	await get_tree().create_timer(0.05, true).timeout
	hit_flash.modulate.a = 0
	
	# Aplicar knockback
	if source_position != Vector2.INF:
		var knockback_dir = (global_position - source_position).normalized()
		knockback_velocity = knockback_dir * knockback_force

	
	if health <= 0:
		queue_free()
		return
		
	start_invincibility()
	
	
func flash_hit():
	if not hit_flash:
		print("HitFlash não setado!")
		return

	hit_flash.modulate.a = 0.6
	await get_tree().create_timer(0.08, true).timeout
	hit_flash.modulate.a = 0.0

# ------------------------------------
# MOVIMENTO
# ------------------------------------
func _physics_process(delta):

	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	$Weapon.look_at(get_global_mouse_position())
	
	var mouse_dir = get_global_mouse_position() - $Weapon.global_position
	
	if mouse_dir.x < 0:
		$Weapon.scale.y = -1 
	else:
		$Weapon.scale.y = 1

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
		$Sprite2D.flip_h = true
	elif direction.x >  0:
		$Sprite2D.flip_h = false
	var input_velocity = direction.normalized() * stats["speed"]
	
	# Combina movimento + knockback
	velocity = input_velocity + knockback_velocity
	
	move_and_slide()

	# Reduz knockback suavemente
	print("knockback_decay:", knockback_decay)
	print("delta:", delta)

	if knockback_decay != null:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)


# ------------------------------------
# TIRO
# ------------------------------------
func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = $Weapon.global_position
	bullet.rotation = $Weapon.global_rotation
	
	var dir = (get_global_mouse_position() - bullet.global_position).normalized()
	bullet.direction = dir
	
	bullet.damage = stats["damage"]


# ------------------------------------
# SISTEMA DE XP
# ------------------------------------

func add_xp(amount):
	xp += amount
	print("XP:", xp)
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

	print("LEVEL UP!", level)
	
	update_xp_bar()
	
	print("LEVEL UP! Agora nível ", level)


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
}


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
		"health":
			max_health += upgrade_data["value"]
			health += upgrade_data["value"]

			if heart_scene:
				print("Antes:", hearts_container.get_child_count())
				var new_heart = heart_scene.instantiate()
				hearts_container.add_child(new_heart)
				print("Depois:", hearts_container.get_child_count())

			update_hearts()



	print("Upgrade aplicado:", id, "Nível:", owned_upgrades[id])

func show_level_up_screen():
	print("Instanciando UI...")
	
	var ui = levelup_ui_scene.instantiate()
	
	get_tree().get_root().add_child(ui)
	
	print("UI adicionada na cena")
	
	var options = get_random_upgrades(3)
	ui.setup(self, options)
	
	get_tree().paused = true

	
func get_random_upgrades(amount := 3):
	var pool = all_upgrades.duplicate()
	pool.shuffle()
	return pool.slice(0, amount)
	
func spawn_orb():
	var orb = preload("res://orb_companion.tscn").instantiate()
	add_child(orb)



	
