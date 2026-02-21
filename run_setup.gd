extends Control

@export var machine_gun: WeaponData
@export var shotgun: WeaponData

@export var tank: CharacterData
@export var speed_char: CharacterData

@onready var metralhadora_button = $VBoxContainer/metralhadora
@onready var doze_button = $VBoxContainer/doze
@onready var tank_button = $VBoxContainer/Tank
@onready var speed_button = $VBoxContainer/Speed
@onready var tela_arma = $TelaArma
@onready var tela_personagem = $TelaPersonagem



func _ready():

	
	tela_personagem.hide()


	await get_tree().process_frame
	


	if machine_gun and metralhadora_button and machine_gun.icon:
		metralhadora_button.icon = machine_gun.icon
	
	if shotgun and doze_button and shotgun.icon:
		doze_button.icon = shotgun.icon
	
	if tank and tank_button and tank.icon:
		tank_button.icon = tank.icon
	
	if speed_char and speed_button and speed_char.icon:
		speed_button.icon = speed_char.icon

var selected_weapon: WeaponData
var selected_character: CharacterData

func _on_metralhadora_pressed():
	selected_weapon = machine_gun
	tela_arma.hide()
	tela_personagem.show()



func _on_doze_pressed():
	selected_weapon = shotgun
	tela_arma.hide()
	tela_personagem.show()


	

func _on_tank_pressed():
	selected_character = tank

func _on_speed_pressed():
	selected_character = speed_char

func _on_padrao_pressed():
	selected_character = null

func _on_comecar_pressed():
	RunData.selected_weapon = selected_weapon
	RunData.selected_character = selected_character
	get_tree().change_scene_to_file("res://main.tscn")
