extends Node2D

@export var zone_data: ZoneData

var player

var current_enemies: Array = []
var enemy_counts := {}  # track per jenis

var can_spawn_voidfin := true
var voidfin_cooldown := 20.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	await get_tree().process_frame
	start_spawn_loop()

func start_spawn_loop():
	spawn_cycle()
	
func spawn_cycle():
	if not below_threshold():
		await get_tree().create_timer(randf_range(
			zone_data.spawn_interval_min,
			zone_data.spawn_interval_max
		)).timeout

	try_spawn_enemy()
	spawn_cycle()

func can_spawn() -> bool:
	return current_enemies.size() < zone_data.max_capacity
	
func below_threshold() -> bool:
	return current_enemies.size() < zone_data.min_threshold

func pick_enemy():
	var valid_entries = []

	for entry in zone_data.spawn_table.entries:
		var name = entry.scene.resource_path
		
		var current = enemy_counts.get(name, 0)
		if current < entry.max:
			valid_entries.append(entry)

	if valid_entries.is_empty():
		return null

	var total_weight = 0
	for e in valid_entries:
		total_weight += e.weight

	var r = randf() * total_weight

	for e in valid_entries:
		r -= e.weight
		if r <= 0:
			return e

	return valid_entries[0]

func get_spawn_position() -> Vector2:
	var max_tries = 10

	for i in range(max_tries):
		var angle = randf() * TAU
		var dist = randf_range(
			zone_data.spawn_radius_min,
			zone_data.spawn_radius_max
		)

		var pos = player.global_position + Vector2.RIGHT.rotated(angle) * dist

		if is_valid_spawn_position(pos):
			return pos

	# fallback (kalau gagal terus)
	return player.global_position

func is_valid_spawn_position(pos: Vector2) -> bool:
	# cek dalam map
	if not zone_data.map_bounds.has_point(pos):
		return false

	var space = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true

	var result = space.intersect_point(query)

	if result.size() > 0:
		return false

	return true

func try_spawn_enemy():
	if not can_spawn():
		return

	var entry = pick_enemy()
	if entry == null:
		return

	var enemy = entry.scene.instantiate()
	enemy.global_position = get_spawn_position()

	add_child(enemy)

	current_enemies.append(enemy)

	var key = entry.scene.resource_path
	enemy_counts[key] = enemy_counts.get(key, 0) + 1

	enemy.tree_exited.connect(func():
		current_enemies.erase(enemy)
		enemy_counts[key] -= 1
	)
