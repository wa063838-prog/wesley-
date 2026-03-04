extends CharacterBody2D


@export var max_health = 300
@export var speed = 120
@export var damage = 2

var health
var player

func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if player:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
		
func take_damage(amount):
	health -= amount
	
	if health <= 0:
		die()
		
func die():
	get_tree().current_scene.boss_defeated()
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
