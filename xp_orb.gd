extends Area2D

@export var xp_value = 2.5
@export var speed = 250.0

var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player:
		var direction = player.global_position - global_position
		var distance = direction.length()

		# Quando estiver perto, começa a puxar
		if direction.length() < player.stats["magnet"]:
			direction = direction.normalized()
			global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_xp(xp_value)
		queue_free()
