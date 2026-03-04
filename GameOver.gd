extends Control

func setup(time_survived, kills):

	$VBoxContainer/TimeLabel.text = "Tempo: " + format_time(time_survived)
	$VBoxContainer/KillLabel.text = "Kills: " + str(kills)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	modulate.a = 0.0
	await get_tree().create_timer(0.1).timeout
	
	for i in range(10):
		modulate.a += 0.1
		await get_tree().create_timer(0.02).timeout

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Main_Menu.tscn")
	
func format_time(seconds: float) -> String:

	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60

	return "%02d:%02d" % [minutes, secs]
	
