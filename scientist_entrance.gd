extends Area2D

@export var max_intruders := 10
@export var defeat_scene: PackedScene
var intruders := 0
var active := false

@onready var intruders_label = get_tree().get_first_node_in_group("intruders_label")

func _ready():
	monitoring = false
	monitorable = false

	print("Label encontrada:", intruders_label)

	if intruders_label:
		intruders_label.visible = true
		intruders_label.text = "TESTE 0/10"
		intruders_label.position = Vector2(20, 120)
		intruders_label.modulate = Color(1, 1, 1, 1)
		intruders_label.scale = Vector2(1, 1)

	update_ui()

func set_active(value: bool) -> void:
	active = value
	monitoring = value
	monitorable = value

	if intruders_label:
		intruders_label.visible = value

	update_ui()
	print("Entrada do cientista ativa:", active)

func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if not body.is_in_group("enemy"):
		return

	body.queue_free()

	intruders += 1
	update_ui()
	print("Inimigos que entraram:", intruders, "/", max_intruders)

	if intruders >= max_intruders:
		trigger_defeat()

func update_ui():
	if intruders_label:
		intruders_label.text = "Entraram: %d/%d" % [intruders, max_intruders]
		print("Texto da label:", intruders_label.text)
func trigger_defeat() -> void:
	print("TRIGGER DERROTA")

	var player = get_tree().get_first_node_in_group("player")

	var game_over = preload("res://GameOver.tscn").instantiate()

	var canvas = get_tree().current_scene.get_node("CanvasLayer")
	canvas.add_child(game_over)

	if player:
		game_over.setup(player.survival_time, player.total_kills)
	else:
		game_over.setup(0, 0)

	get_tree().paused = true
