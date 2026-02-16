extends CanvasLayer

var player
var upgrades = []

func setup(p, options):
	player = p
	upgrades = options
	visible = true

	$Panel/HBoxContainer/Button.text = upgrades[0]["name"]
	$Panel/HBoxContainer/Button2.text = upgrades[1]["name"]
	$Panel/HBoxContainer/Button3.text = upgrades[2]["name"]

func _on_button_pressed():
	player.apply_upgrade(upgrades[0])
	close()

func _on_button2_pressed():
	player.apply_upgrade(upgrades[1])
	close()

func _on_button3_pressed():
	player.apply_upgrade(upgrades[2])
	close()

func close():
	get_tree().paused = false
	queue_free()

func _ready():
	$Panel.modulate = Color(1, 0, 0, 0.5)
	print("LEVEL UP UI ENTROU")


	
