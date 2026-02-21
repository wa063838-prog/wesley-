extends Control

@export var tank: CharacterData
@export var speed_char: CharacterData
@export var default_character: CharacterData

func _ready():
	pass

func _on_tank_pressed():
	RunData.selected_character = tank

func _on_speed_pressed():
	RunData.selected_character = speed_char
	
func _on_padrão_pressed() -> void:
	RunData.selected_character = default_character
	
func _on_começar_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://EscolherArma.tscn")
