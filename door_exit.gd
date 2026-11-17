extends Node2D

@export_file("*.tscn") var destination_scene: String

@export var interaction_label: Label

var player_near := false


func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		exit_house()


func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		interaction_label.visible = true


func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		interaction_label.visible = false


func exit_house():
	if destination_scene.is_empty():
		push_warning("Nenhuma cena de destino definida na porta.")
		return

	get_tree().change_scene_to_file(destination_scene)
