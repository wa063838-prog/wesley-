extends CharacterBody2D

@export var speed = 110
@export var max_health = 2
@export var damage = 1
@onready var xp_orb_scene = preload("res://xp_orb.tscn")


var player = null
var health

func _ready():
	print("Enemy scene path:", get_scene_file_path())

	player = get_tree().get_first_node_in_group("player")
	print("player encontrado",player)
	health = max_health

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
	var distance = global_position.distance_to(player.global_position)
	move_and_slide()

func take_damage(amount):
	print("Dano recebido:", amount)
	health -= amount
	
	if health <= 0:
		drop_xp()
		queue_free()

func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage,global_position)
		velocity = (global_position - body.global_position).normalized() * 150
func drop_xp():
	print("Drop XP chamado")
	print("xp_orb_scene:", xp_orb_scene)
	
	var orb = xp_orb_scene.instantiate()
	get_tree().current_scene.add_child(orb)
	orb.global_position = global_position
