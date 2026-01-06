extends Node

const Element = preload("res://scripts/core/world_manager.gd").Element
const RaceData = preload("res://scripts/data/race_data.gd")


static func register_unit(manager: Node2D, u):
	var k = Vector2i(u.global_position / manager.TRACKING_CELL_SIZE)
	if not manager.unit_tracking_grid.has(k):
		manager.unit_tracking_grid[k] = []
	manager.unit_tracking_grid[k].append(u)


static func unregister_unit(manager: Node2D, u):
	var k = Vector2i(u.global_position / manager.TRACKING_CELL_SIZE)
	if manager.unit_tracking_grid.has(k):
		manager.unit_tracking_grid[k].erase(u)


static func update_unit_position(manager: Node2D, u, old, new):
	var ok = Vector2i(old / manager.TRACKING_CELL_SIZE)
	var nk = Vector2i(new / manager.TRACKING_CELL_SIZE)
	if ok != nk:
		if manager.unit_tracking_grid.has(ok):
			manager.unit_tracking_grid[ok].erase(u)
		register_unit(manager, u)


static func get_units_in_range(manager: Node2D, pos, radius):
	var k = Vector2i(pos / manager.TRACKING_CELL_SIZE)
	var res = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if manager.unit_tracking_grid.has(k + Vector2i(x, y)):
				for u in manager.unit_tracking_grid[k + Vector2i(x, y)]:
					if is_instance_valid(u) and u.global_position.distance_to(pos) <= radius:
						res.append(u)
	return res


static func spawn_unit(manager: Node2D, pos: Vector2, type: int) -> CharacterBody2D:
	var unit = manager.unit_scene.instantiate()
	unit.position = pos
	if type == Element.SPAWN_KINGDOM_A:
		unit.u_race = RaceData.RaceType.HUMAN
		unit.kingdom_id = 1
		unit.kingdom_color = Color(0.2, 0.6, 1.0)
	elif type == Element.SPAWN_KINGDOM_B:
		unit.u_race = RaceData.RaceType.HUMAN
		unit.kingdom_id = 2
		unit.kingdom_color = Color(0.9, 0.2, 0.2)
	elif type == Element.SPAWN_MONSTER:
		unit.u_race = RaceData.RaceType.ORC
		unit.kingdom_id = 0
	unit.unit_clicked.connect(manager._on_unit_selected)
	unit.unit_hovered.connect(manager._on_unit_hovered)
	unit.unit_unhovered.connect(manager._on_unit_unhovered)
	manager.add_child(unit)
	register_unit(manager, unit)
	return unit


static func spawn_starting_units(manager: Node2D):
	var center = Vector2(manager.grid_size) / 2.0

	# Taruh Gerobak 2x2 di tengah
	var cx = int(center.x)
	var cy = int(center.y)
	if manager._is_in_bounds(cx + 1, cy + 1):
		manager._set_cell(cx, cy, 17)  # TL
		manager._set_cell(cx + 1, cy, 18)  # TR
		manager._set_cell(cx, cy + 1, 19)  # BL
		manager._set_cell(cx + 1, cy + 1, 20)  # BR

	var count = 0
	# Daftar ubin rumput yang boleh ditempati
	var grass_tiles = [
		manager.Element.GRASS,
		manager.Element.GRASS_B,
		manager.Element.GRASS_C,
		manager.Element.GRASS_D
	]

	for i in range(500):
		# Spawn di sekitar gerobak (radius 2-3 ubin)
		var test_pos = center + Vector2(randf_range(-3, 3), randf_range(-3, 3))
		var tx = int(test_pos.x)
		var ty = int(test_pos.y)

		if manager._is_in_bounds(tx, ty):
			var tile = manager.grid[tx][ty]
			# Pastikan ubin adalah rumput DAN tidak ada rintangan di PropLayer
			if tile in grass_tiles:
				if manager.prop_map.get_cell_source_id(Vector2i(tx, ty)) == -1:
					var u = spawn_unit(manager, test_pos * 32.0, Element.SPAWN_KINGDOM_A)
					if is_instance_valid(u):
						u.home_position = center * 32.0
						u.max_wander_distance = 120.0
					count += 1
					if count >= 3:
						break
