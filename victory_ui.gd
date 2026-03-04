extends Control

func setup(time_survived, total_kills):
	$Tempo.text = "Tempo: " + str(round(time_survived)) + "s"
	$Kills.text = "Kills: " + str(total_kills)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_reiniciar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
