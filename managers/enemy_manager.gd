extends Node

var enemies: Array = []
var frame_group := 0
var total_groups := 3
var total_kills := 0
const CELL_SIZE = 100
var grid = {}
var steering_forces = {}  # dict[enemy] = {separation, alignment, cohesion}
@export var min_dist := 80.0
@export var alignment_dist := 120.0
@export var cohesion_dist := 140.0
const ADJUSTED_CELL_SIZE = 100

var debug_timer := 0.0

func _process(delta):
	enemies = enemies.filter(func(e): return is_instance_valid(e))

	debug_timer += delta
	if debug_timer >= 1.0:
		debug_timer = 0.0

	frame_group = (frame_group + 1) % total_groups
	update_all_grids()
	compute_steering_forces()
func update_all_grids():
	grid.clear()
	for e in enemies:
		if is_instance_valid(e):
			var cell = Vector2i(
				int(e.global_position.x / CELL_SIZE),
				int(e.global_position.y / CELL_SIZE)
			)
			if not grid.has(cell):
				grid[cell] = []
			grid[cell].append(e)

func get_nearby_enemies(pos: Vector2):
	var cell = Vector2i(
		int(pos.x / CELL_SIZE),
		int(pos.y / CELL_SIZE)
	)
	var neighbors = []
	# Checa a célula atual e as 8 ao redor (9 total)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var target_cell = cell + Vector2i(x, y)
			if grid.has(target_cell):
				neighbors.append_array(grid[target_cell])
	return neighbors

func compute_steering_forces():
	steering_forces.clear()
	var min_d = min_dist
	var min_d2 = min_d * min_d
	var align_d2 = alignment_dist * alignment_dist
	var cohes_d2 = cohesion_dist * cohesion_dist

	for e in enemies:
		if is_instance_valid(e) and e.player and is_instance_valid(e.player):
			var dist_to_player = e.global_position.distance_to(e.player.global_position)
			if dist_to_player <= e.full_ai_distance:
				steering_forces[e] = {
					"separation": Vector2.ZERO,
					"alignment": Vector2.ZERO,
					"cohesion": Vector2.ZERO
				}

	for cell_key in grid.keys():
		var list_a = grid[cell_key]

		for e1 in list_a:
			if not is_instance_valid(e1):
				continue
			if not steering_forces.has(e1):
				continue

			var sep_force = Vector2.ZERO
			var align_dir = Vector2.ZERO
			var cohesion_pos = Vector2.ZERO
			var align_count = 0
			var cohes_count = 0

			for ox in range(-1, 2):
				for oy in range(-1, 2):
					var other_cell = cell_key + Vector2i(ox, oy)
					if not grid.has(other_cell):
						continue

					for e2 in grid[other_cell]:
						if not is_instance_valid(e2) or e1 == e2:
							continue
						if not steering_forces.has(e2):
							continue

						var diff = e1.global_position - e2.global_position
						var dist2 = diff.length_squared()
						if dist2 == 0:
							continue

						if dist2 < min_d2:
							var dist = sqrt(dist2)
							var overlap = min_d - dist
							var push = diff.normalized() * (overlap * 0.8)
							var max_push = min_d * 0.7
							if push.length() > max_push:
								push = push.normalized() * max_push
							sep_force += push

						if dist2 < align_d2:
							align_dir += e2.direction
							align_count += 1

						if dist2 < cohes_d2:
							cohesion_pos += e2.global_position
							cohes_count += 1

			steering_forces[e1]["separation"] = sep_force

			if align_count > 0:
				steering_forces[e1]["alignment"] = (align_dir / align_count).normalized() * 100.0

			if cohes_count > 0:
				var center = cohesion_pos / cohes_count
				steering_forces[e1]["cohesion"] = (center - e1.global_position).normalized() * 80.0

func get_steering_force(enemy, force_type: String):
	if steering_forces.has(enemy):
		return steering_forces[enemy].get(force_type, Vector2.ZERO)
	return Vector2.ZERO

func resolve_all_overlaps():
	var min_dist = 24.0
	
	for e in enemies:
		if not is_instance_valid(e):
			continue
		
		var neighbors = get_nearby_enemies(e.global_position)
		
		for neighbor in neighbors:
			if neighbor == e:
				continue
			if not is_instance_valid(neighbor):
				continue
			
			var diff = e.global_position - neighbor.global_position
			var dist = diff.length()
			
			if dist == 0:
				continue
			
			if dist < min_dist:
				var overlap = min_dist - dist
				var push = diff.normalized() * (overlap * 0.5)
				
				e.global_position += push
				neighbor.global_position -= push

func register_enemy(enemy):
	if not enemies.has(enemy):
		enemies.append(enemy)
func unregister_enemy(enemy): enemies.erase(enemy)
