extends CharacterBody2D

@export var bullet_scene : PackedScene
@export var max_health = 3
@export var speed = 500.0
@export var invincibility_time = 0.6
@export var knockback_force = 1000.0
@export var knockback_decay = 1200.0
@export var hit_flash : ColorRect
@onready var xp_bar = get_parent().get_node("ui/XPBar")


var health
var can_take_damage = true
var knockback_velocity = Vector2.ZERO

var current_xp = 0
var xp_to_next_level = 10
var level = 1


@onready var hearts_container = get_parent().get_node("ui/hearts")

var heart_full = preload("res://heart_full.jpg")
var heart_empty = preload("res://heart_empty.jpg")

# ------------------------------------
# READY
# ------------------------------------
func _ready():
	health = max_health
	update_hearts()
	
	update_xp_bar()

	
	
	if hit_flash:
		hit_flash.modulate.a = 0.0
# ------------------------------------
# ATUALIZA CORAÇÕES
# ------------------------------------
func update_hearts():
	for i in range(max_health):
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
	
	Engine.time_scale = 0.03
	await get_tree().create_timer(0.02, true).timeout
	Engine.time_scale = 1.0
	
	hit_flash.modulate.a = 0.5
	await get_tree().create_timer(0.1).timeout
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
	var input_velocity = direction.normalized() * speed
	
	# Combina movimento + knockback
	velocity = input_velocity + knockback_velocity
	
	move_and_slide()

	# Reduz knockback suavemente
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

# ------------------------------------
# SISTEMA DE XP
# ------------------------------------

# ------------------------------------
# SISTEMA DE XP
# ------------------------------------

func add_xp(amount):
	current_xp += amount
	
	update_xp_bar()
	
	if current_xp >= xp_to_next_level:
		level_up()


func level_up():
	level += 1
	current_xp -= xp_to_next_level
	
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	update_xp_bar()
	
	print("LEVEL UP! Agora nível ", level)


func update_xp_bar():
	xp_bar.max_value = xp_to_next_level
	xp_bar.value = current_xp
