extends Control

@export var tank_data: CharacterData
@export var speed_data: CharacterData
@export var padrao_data: CharacterData

@onready var tank_button = $TankBox/Tank
@onready var speed_button = $SpeedBox/Speed
@onready var padrao_button = $PadraoBox/Padrao

@onready var nome_personagem = $NomePanel/NomePersonagem
@onready var descricao_personagem = $"DescriçãoPanel"/DescricaoPersonagem
@onready var stats_personagem = $StatsPanel/StatsPersonagem
@onready var confirmar_button = $Começar

@onready var tank = $TankBox/Tank
@onready var speed = $SpeedBox/Speed
@onready var padrao = $PadraoBox/Padrao

@onready var tank_box = $TankBox
@onready var speed_box = $SpeedBox
@onready var padrao_box = $PadraoBox

@onready var click_sound = $ClickSound

var personagem_selecionado: CharacterData = null

var escala_normal := Vector2(0.2, 0.2)
var escala_selecionada := Vector2(0.23, 0.23)

func _ready():
	tank_button.pressed.connect(_on_tank_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	padrao_button.pressed.connect(_on_padrao_pressed)
	confirmar_button.pressed.connect(_on_começar_pressed)

	tank.modulate = Color(1, 1, 1)
	speed.modulate = Color(1, 1, 1)
	padrao.modulate = Color(1, 1, 1)

	tank.scale = escala_normal
	speed.scale = escala_normal
	padrao.scale = escala_normal

	nome_personagem.text = "Selecione um personagem"
	descricao_personagem.text = "Clique em um personagem para ver detalhes"
	stats_personagem.text = "Vida:       -\nVelocidade: -\nDano:       -"

	atualizar_bordas()

func play_click():
	if click_sound:
		click_sound.play()

func atualizar_bordas():
	tank_box.modulate = Color(0.5, 0.5, 0.5)
	speed_box.modulate = Color(0.5, 0.5, 0.5)
	padrao_box.modulate = Color(0.5, 0.5, 0.5)

	if personagem_selecionado == tank_data:
		tank_box.modulate = Color(1.2, 1.2, 0.6)
	elif personagem_selecionado == speed_data:
		speed_box.modulate = Color(1.2, 1.2, 0.6)
	elif personagem_selecionado == padrao_data:
		padrao_box.modulate = Color(1.2, 1.2, 0.6)

func _on_tank_pressed():
	play_click()
	personagem_selecionado = tank_data

	nome_personagem.text = "Tank"
	descricao_personagem.text = "Mais vida, porém mais lento."
	stats_personagem.text = "Vida:       █████\nVelocidade: ██░░░\nDano:       ███░░"

	tank.modulate = Color(1.2, 1.2, 1.2)
	speed.modulate = Color(0.6, 0.6, 0.6)
	padrao.modulate = Color(0.6, 0.6, 0.6)

	tank.scale = escala_selecionada
	speed.scale = escala_normal
	padrao.scale = escala_normal

	atualizar_bordas()

func _on_speed_pressed():
	play_click()
	personagem_selecionado = speed_data

	nome_personagem.text = "Speed"
	descricao_personagem.text = "Mais rápido, menos resistente."
	stats_personagem.text = "Vida:       ██░░░\nVelocidade: █████\nDano:       ███░░"

	speed.modulate = Color(1.2, 1.2, 1.2)
	tank.modulate = Color(0.6, 0.6, 0.6)
	padrao.modulate = Color(0.6, 0.6, 0.6)

	speed.scale = escala_selecionada
	tank.scale = escala_normal
	padrao.scale = escala_normal

	atualizar_bordas()

func _on_padrao_pressed():
	play_click()
	personagem_selecionado = padrao_data

	nome_personagem.text = "Padrão"
	descricao_personagem.text = "Equilibrado em todos os atributos."
	stats_personagem.text = "Vida:       ███░░\nVelocidade: ███░░\nDano:       ███░░"

	padrao.modulate = Color(1.2, 1.2, 1.2)
	tank.modulate = Color(0.6, 0.6, 0.6)
	speed.modulate = Color(0.6, 0.6, 0.6)

	padrao.scale = escala_selecionada
	tank.scale = escala_normal
	speed.scale = escala_normal

	atualizar_bordas()

func _on_começar_pressed():
	if personagem_selecionado == null:
		return

	RunData.selected_character = personagem_selecionado

	if click_sound:
		click_sound.play()

	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_voltar_pressed():
	if click_sound:
		click_sound.play()

	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file("res://EscolherArma.tscn")
