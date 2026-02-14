extends CharacterBody2D

@export var speed = 150
@export var max_health = 2
@export var damage = 1

var player = null
var health

func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("player encontrado",player)
	health = max_health

func _physics_process(delta):
	print("rodando")
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

	var distance = global_position.distance_to(player.global_position)
	move_and_slide()

func take_damage(amount):
	health -= amount
	
	if health <= 0:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.add_xp(5)
		queue_free()

func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage,global_position)
		velocity = (global_position - body.global_position).normalized() * 150
