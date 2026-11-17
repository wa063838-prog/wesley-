extends Control

@export var machine_gun: WeaponData
@export var shotgun: WeaponData

@onready var metralhadora_button = $MetralhadoraBox/Metralhadora
@onready var doze_button = $DozeBox/Doze

@onready var nome_arma = $NomePanel/NomeArma
@onready var descricao_arma = $DescricaoPanel/DescricaoArma
@onready var confirmar_button = $Confirmar

@onready var metralhadora = $MetralhadoraBox/Metralhadora
@onready var doze = $DozeBox/Doze

@onready var metralhadora_box = $MetralhadoraBox
@onready var doze_box = $DozeBox

@onready var click_sound = $ClickSound
@onready var stats_arma = $StatsPanel/StatsArma

var selected_weapon = null

var escala_normal := Vector2(5, 5)
var escala_selecionada := Vector2(5.65, 5.65)

func _ready():
	MusicManager.play_menu()

	metralhadora_button.pressed.connect(_on_metralhadora_pressed)
	doze_button.pressed.connect(_on_doze_pressed)
	confirmar_button.pressed.connect(_on_confirmar_pressed)

	metralhadora.modulate = Color(1, 1, 1)
	doze.modulate = Color(1, 1, 1)
	metralhadora.scale = escala_normal
	doze.scale = escala_normal

	nome_arma.text = "Selecione uma arma"
	descricao_arma.text = "Clique em uma arma para ver detalhes"
	stats_arma.text = "Dano:     -\nCadência: -\nAlcance:  -"

	atualizar_bordas()

func play_click():
	if click_sound:
		click_sound.play()

func atualizar_bordas():
	metralhadora_box.modulate = Color(0.5, 0.5, 0.5)
	doze_box.modulate = Color(0.5, 0.5, 0.5)

	if selected_weapon == machine_gun:
		metralhadora_box.modulate = Color(1.2, 1.2, 0.6)
	elif selected_weapon == shotgun:
		doze_box.modulate = Color(1.2, 1.2, 0.6)

func _on_metralhadora_pressed():
	play_click()
	selected_weapon = machine_gun
	
	nome_arma.text = "Metralhadora"
	descricao_arma.text = "Tiros rápidos e contínuos. Boa para pressão constante."
	stats_arma.text = "Dano:     ███░░\nCadência: █████\nAlcance:  ███░░"
	
	metralhadora.modulate = Color(1.2, 1.2, 1.2)
	doze.modulate = Color(0.6, 0.6, 0.6)

	metralhadora.scale = escala_selecionada
	doze.scale = escala_normal

	atualizar_bordas()

func _on_doze_pressed():
	play_click()
	selected_weapon = shotgun
	
	nome_arma.text = "Doze"
	descricao_arma.text = "Dispara vários projéteis. Muito forte de perto."
	stats_arma.text = "Dano:    █████\nCadência:  ██░░░\nAlcance:  ██░░░"
	
	doze.modulate = Color(1.2, 1.2, 1.2)
	metralhadora.modulate = Color(0.6, 0.6, 0.6)

	doze.scale = escala_selecionada
	metralhadora.scale = escala_normal

	atualizar_bordas()

func _on_confirmar_pressed():
	play_click()

	if selected_weapon == null:
		return
	
	RunData.selected_weapon = selected_weapon
	
	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file("res://EscolhaPersonagem.tscn")

func _on_voltar_pressed():
	play_click()
	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file("res://Main_Menu.tscn")
