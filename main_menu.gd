extends Control

@onready var jogar_button = $VBoxContainer/Jogar
@onready var sair_button = $VBoxContainer/Sair 

func _ready():
	MusicManager.play_menu()
	jogar_button.pressed.connect(_on_jogar_pressed)
	sair_button.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://EscolherArma.tscn")

func _on_sair_pressed():
	get_tree().quit()
	
func _on_colecionaveis_pressed():
	get_tree().change_scene_to_file("res://collectibles.tscn")
