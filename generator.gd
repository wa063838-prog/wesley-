extends Node2D

@export var generator_id: int = 1

@onready var interaction_area: Area2D = $InteractionArea
@onready var sprite: Sprite2D = $Sprite2D

var player_near: bool = false
var activated: bool = false


func _ready():
	add_to_group("generators")

	# Detecta quando o player entra/sai da área
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	print("Gerador ", generator_id, " está desligado.")


func _process(_delta):
	if player_near and not activated:
		if Input.is_action_just_pressed("interact"):
			activate_generator()


func activate_generator():
	if activated:
		return

	activated = true

	print("GERADOR ", generator_id, " REATIVADO!")


func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		print("Pressione E para religar o gerador")


func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
