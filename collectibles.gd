extends Control

@onready var popup = $CardPopup
@onready var big_image = $CardPopup/Panel/BigImage
@onready var description_label = $CardPopup/Panel/DescriptionLabel

func open_card(texture: Texture2D, text: String):
	popup.visible = true
	big_image.texture = texture
	description_label.text = text


func _ready():
	# garante que o menu não esteja pausado
	get_tree().paused = false

func populate_collectibles():
	pass
	
func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Main_Menu.tscn")


func _on_close_button_pressed() -> void:
	pass # Replace with function body.
