extends Control

@onready var popup = $CardPopup
@onready var big_image = $CardPopup/Panel/BigImage
@onready var description_label = $CardPopup/Panel/DescriptionLabel

func _ready():
	get_tree().paused = false

func open_card(card_texture: Texture2D, text: String):
	popup.visible = true
	big_image.texture = card_texture
	description_label.text = text

func populate_collectibles():
	pass

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Main_Menu.tscn")

func _on_close_button_pressed() -> void:
	popup.visible = false
