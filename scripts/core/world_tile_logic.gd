extends Node

const Element = preload("res://scripts/core/world_manager.gd").Element


static func set_cell(manager: Node2D, x: int, y: int, type: int) -> void:
	if manager._is_in_bounds(x, y):
		manager.grid[x][y] = type
		update_tile_visuals(manager, x, y, type)


static func update_tile_visuals(manager: Node2D, x: int, y: int, type: int) -> void:
	var pos = Vector2i(x, y)
	var props = [
		Element.TREE,
		Element.STONE,
		Element.MOUNTAIN,
		Element.TREE_PINE,
		Element.TREE_BIRCH,
		Element.TREE_AUTUMN,
		Element.TREE_FRUIT
	]
	if type in props:
		manager.prop_map.set_cell(pos, 0, Vector2i(type, 0))
		if manager.tile_map.get_cell_source_id(pos) == -1:
			manager.tile_map.set_cell(pos, 0, Vector2i(Element.GRASS, 0))
	else:
		manager.tile_map.set_cell(pos, 0, Vector2i(type, 0))
		manager.prop_map.set_cell(pos, -1)


static func paint_brush(manager: Node2D, cx: int, cy: int) -> void:
	if manager.current_element >= 100:
		if manager.spawn_cooldown <= 0:
			manager._spawn_unit(manager.get_global_mouse_position(), manager.current_element)
			manager.spawn_cooldown = 0.1
		return
	var offset = manager.brush_size / 2
	for x in range(cx - offset, cx - offset + manager.brush_size):
		for y in range(cy - offset, cy - offset + manager.brush_size):
			if manager._is_in_bounds(x, y):
				var current_tile = manager.grid[x][y]
				if (
					manager.current_element == Element.TREE
					or manager.current_element == Element.STONE
				):
					if current_tile == Element.OCEAN:
						continue
				var final_type = (
					manager.current_element
					if manager.current_element != Element.ERASER
					else manager.get_random_grass()
				)
				set_cell(manager, x, y, final_type)
				manager.fog_map.set_cell(Vector2i(x, y), -1)
