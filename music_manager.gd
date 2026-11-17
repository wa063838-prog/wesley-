extends Node

var player: AudioStreamPlayer

var menu_music = preload("res://audio/menu.ogg")
var gameplay_music = preload("res://audio/gameplay.ogg")

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = -17

func play_menu():
	if player.stream != menu_music:
		player.stream = menu_music
		player.play()

func play_gameplay():
	if player.stream != gameplay_music:
		player.stream = gameplay_music
		player.play()
		
func stop_music():
	if player.playing:
		player.stop()
