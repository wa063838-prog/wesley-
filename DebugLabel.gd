extends CanvasLayer

@onready var label = $DebugLabel

func _process(_delta):

	var fps = Engine.get_frames_per_second()
	var enemy_count = EnemyManager.enemies.size()

	label.text = "FPS: %d\nInimigos: %d" % [fps, enemy_count]
