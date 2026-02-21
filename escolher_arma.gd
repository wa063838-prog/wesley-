extends Control

@export var machine_gun: WeaponData
@export var shotgun: WeaponData

@onready var metralhadora_button = $Metralhadora
@onready var doze_button = $Doze

@onready var btn = $Metralhadora

func _ready():
	btn.pressed.connect(func(): print("BOTAO PRESSIONADO"))

	metralhadora_button.pressed.connect(_on_metralhadora_pressed)
	doze_button.pressed.connect(_on_doze_pressed)

func _on_metralhadora_pressed():
	RunData.selected_weapon = machine_gun
	get_tree().change_scene_to_file("res://EscolhaPersonagem.tscn")

func _on_doze_pressed():
	RunData.selected_weapon = shotgun
	get_tree().change_scene_to_file("res://EscolhaPersonagem.tscn")
	
func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Main_Menu.tscn")
