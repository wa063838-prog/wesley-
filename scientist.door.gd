extends StaticBody2D

var opened := false

func open():
	print("open() chamado")

	if opened:
		print("já estava aberta")
		return

	opened = true

	print("PORTA ABERTA")

	$CollisionShape2D.disabled = true
	$Sprite2D.visible = false

	var entrance = get_tree().get_first_node_in_group("scientist_entrance")
	print("Entrada encontrada:", entrance)

	if entrance and entrance.has_method("set_active"):
		entrance.set_active(true)
