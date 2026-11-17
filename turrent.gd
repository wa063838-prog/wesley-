extends Node2D

@export var bullet_scene : PackedScene
@export var range : float = 300
@onready var ammo_bar = $AmmoBar
@onready var muzzle = $Body/muzzle

var target = null

var max_shots := 40
var shots_left := 40

func _ready():

	shots_left = max_shots

	if ammo_bar:
		ammo_bar.top_level = true
		ammo_bar.max_value = max_shots
		ammo_bar.value = shots_left
	
func _process(delta):

	if target == null or not is_instance_valid(target):
		find_target()

	if target and is_instance_valid(target):
		$Body.look_at(target.global_position)
		
	if ammo_bar:
		ammo_bar.global_position = global_position + Vector2(-20, -30)

func find_target():

	var enemies = get_tree().get_nodes_in_group("enemies")

	var closest = null
	var closest_dist = range

	for e in enemies:

		if not is_instance_valid(e):
			continue

		var d = global_position.distance_to(e.global_position)

		if d < closest_dist:
			closest = e
			closest_dist = d

	target = closest


func _on_timer_timeout():

	if shots_left <= 0:
		destroy_turret()
		return

	if target == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = muzzle.global_position
	bullet.direction = (target.global_position - muzzle.global_position).normalized()

	shots_left -= 1
	if ammo_bar:
		ammo_bar.value = shots_left
	
func destroy_turret():

	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.turret_count -= 1

	queue_free()
