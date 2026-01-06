extends Node

const Element = preload("res://scripts/core/world_manager.gd").Element


static func generate_random_world(grid: Array, grid_size: Vector2i, manager: Node2D):
	grid.clear()
	manager.tile_map.clear()
	manager.prop_map.clear()
	manager.fog_map.clear()

	var terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = randi()
	terrain_noise.frequency = 0.015

	var stone_noise = FastNoiseLite.new()
	stone_noise.seed = randi()
	stone_noise.frequency = 0.01

	var forest_noise = FastNoiseLite.new()
	forest_noise.seed = randi()
	forest_noise.frequency = 0.05

	for x in range(grid_size.x):
		if x % 16 == 0:
			await manager.get_tree().process_frame
		manager.loading_bar.value = x
		grid.append([])
		for y in range(grid_size.y):
			var tv = terrain_noise.get_noise_2d(x, y)
			var fv = forest_noise.get_noise_2d(x, y)
			var sv = stone_noise.get_noise_2d(x, y)

			var type = manager.get_random_grass()
			if tv < -0.5:
				type = Element.OCEAN
			elif tv < -0.4:
				type = Element.SAND
			else:
				type = manager.get_random_grass()

			grid[x].append(type)
			manager._update_tile_visuals(x, y, type)

			if type >= Element.GRASS and type <= Element.GRASS_D:
				if sv > 0.3:
					manager._set_cell(x, y, Element.STONE)
				elif fv > 0.2:
					var tree_chance = 0.8 if fv > 0.4 else 0.15
					if randf() < tree_chance:
						manager._set_cell(x, y, manager.get_random_tree())


static func generate_city_map(grid: Array, grid_size: Vector2i, manager: Node2D):
	grid.clear()
	manager.tile_map.clear()
	manager.prop_map.clear()
	manager.fog_map.clear()
	for x in range(grid_size.x):
		if x % 16 == 0:
			await manager.get_tree().process_frame
		manager.loading_bar.value = x
		grid.append([])
		for y in range(grid_size.y):
			var type = manager.get_random_grass()
			if abs(y - grid_size.y / 2) < 8:
				type = Element.OCEAN
			elif x % 20 == 0 or y % 20 == 0:
				type = Element.DIRT
			else:
				var lx = x % 20
				var ly = y % 20
				if lx > 4 and lx < 16 and ly > 4 and ly < 16:
					if (x + y) % 3 == 0:
						type = Element.STONE
					elif (x * y) % 7 == 0:
						type = manager.get_random_tree()
			grid[x].append(type)
			manager._update_tile_visuals(x, y, type)
