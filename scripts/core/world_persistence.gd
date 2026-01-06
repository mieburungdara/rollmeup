extends Node


static func save_world(path: String, grid_size: Vector2i, grid: Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_var(grid_size)
		file.store_var(grid)
		return true
	return false


static func load_world(path: String, manager: Node2D):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		manager.grid_size = file.get_var()
		manager.grid = file.get_var()
		manager.tile_map.clear()
		manager.prop_map.clear()
		manager.fog_map.clear()
		for x in range(manager.grid_size.x):
			if x % 16 == 0:
				await manager.get_tree().process_frame
			manager.loading_bar.value = x
			for y in range(manager.grid_size.y):
				manager._update_tile_visuals(x, y, manager.grid[x][y])
		return true
	return false


static func export_json(path: String, grid_size: Vector2i, grid: Array):
	var map_data = {"name": "Custom", "width": grid_size.x, "height": grid_size.y, "data": grid}
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(map_data))
