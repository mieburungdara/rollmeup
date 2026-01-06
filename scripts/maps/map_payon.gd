extends Node

# Definisi Element (harus sama dengan world_manager)
enum Element { OCEAN, SAND, GRASS, MOUNTAIN, DIRT = 5, TREE = 6, STONE = 7 }


func generate(grid: Array, grid_size: Vector2i, manager: Node2D):
	var center = grid_size / 2

	# Setup Noise untuk Batu agar membentuk kelompok (clusters)
	var stone_noise = FastNoiseLite.new()
	stone_noise.seed = randi()
	stone_noise.frequency = 0.15

	for x in range(grid_size.x):
		if x % 16 == 0:
			await manager.get_tree().process_frame

		grid.append([])
		for y in range(grid_size.y):
			var type = Element.GRASS
			var dist = Vector2(x, y).distance_to(Vector2(center))
			var n_val = stone_noise.get_noise_2d(x, y)

			# 1. TEMBOK PEMBATAS DESA
			if x < 2 or x > grid_size.x - 3 or y < 2 or y > grid_size.y - 3:
				type = Element.MOUNTAIN

			# 2. SUNGAI PAYON (Horizontal)
			elif abs(y - (grid_size.y - 25)) < 5:
				type = Element.OCEAN

			# 3. JALAN UTAMA (Vertikal)
			elif abs(x - center.x) < 2:
				type = Element.DIRT

			# 4. PENYEBARAN BATU ALAMI (Clustered Outcrops)
			elif n_val > 0.4 and dist < 60:
				type = Element.STONE

			# 5. HUTAN SEKITAR
			elif dist > 40:
				if (x + y) % 3 == 0:
					type = Element.TREE

			grid[x].append(type)
			manager.tile_map.set_cell(Vector2i(x, y), 0, Vector2i(type, 0))

	print("Map Payon dari file terpisah berhasil dimuat!")
