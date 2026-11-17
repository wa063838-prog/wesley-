extends Node

var current_target: Node = null

func set_target(target: Node):
	current_target = target
	
@onready var generator1 = $"../Generators/Generator1"
@onready var generator2 = $"../Generators/Generator2"
@onready var generator3 = $"../Generators/Generator3"
@onready var scientist = $"../ScientistEntrance"

func _ready():
	add_to_group("stage_manager")
	current_target = generator1
