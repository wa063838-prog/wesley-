extends Node2D

@export var time_to_win := 480.0

var progress := 0.0
var finished := false

@onready var bar = $ProgressBar
@onready var percent_label = $Label
func _process(delta):

	if finished:
		return

	progress += delta
	
	var percent = progress / time_to_win
	
	bar.value = percent * 100
	percent_label.text = str(int(percent * 100)) + "%"

	if percent >= 1.0:
		finished = true
		victory()


func victory():

	print("CIENTISTA TERMINOU")

	var victory = preload("res://victory_ui.tscn").instantiate()

	var canvas = get_tree().current_scene.get_node("CanvasLayer")

	canvas.add_child(victory)

	get_tree().paused = true
