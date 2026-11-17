extends Control

@onready var fade_rect = $ColorRect

func _ready():
	start()

func start():
	# começa totalmente preto (loading visível)
	fade_rect.modulate.a = 1.0

	# para a música do menu
	MusicManager.stop_music()

	# 👇 segura a tela preta (importante!)
	await get_tree().create_timer(0.4).timeout

	# 👇 FADE ABRINDO (preto → transparente)
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.4)
	await tween.finished

	# 👇 deixa o jogo aparecer um pouco
	await get_tree().create_timer(0.2).timeout

	# 👇 FADE FECHANDO (transparente → preto)
	var tween2 = create_tween()
	tween2.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await tween2.finished

	# troca pra gameplay
	# começa a história dentro da casa
	get_tree().change_scene_to_file("res://house.tscn")
