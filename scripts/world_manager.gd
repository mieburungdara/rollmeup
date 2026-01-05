extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

signal show_unit_info(unit)

enum Element { OCEAN, SAND, GRASS, MOUNTAIN, DIRT = 5, SPAWN_KINGDOM_A = 100, SPAWN_KINGDOM_B = 101, SPAWN_MONSTER = 102 }

# Config Map Besar
var grid_size := Vector2i(256, 256)
const CHUNK_SIZE := 16 
var grid := []
var current_element: int = Element.SAND
var brush_size := 4
var unit_scene = preload("res://scenes/unit.tscn")
var spawn_cooldown := 0.0
var is_world_ready := false
var is_mouse_on_ui := false

# UI Logic
var selected_unit = null
@onready var ui_panel = $UI/Panel
@onready var inspector_panel = $UI/InspectorPanel
@onready var name_label = $UI/InspectorPanel/VBox/NameLabel
@onready var kingdom_label = $UI/InspectorPanel/VBox/KingdomLabel
@onready var guild_label = $UI/InspectorPanel/VBox/GuildLabel
@onready var hp_label = $UI/InspectorPanel/VBox/HPLabel
@onready var traits_label = $UI/InspectorPanel/VBox/TraitsLabel

# Tombol Toolbar
@onready var ocean_btn = $UI/Panel/HBox/OceanBtn
@onready var sand_btn = $UI/Panel/HBox/SandBtn
@onready var dirt_btn = $UI/Panel/HBox/DirtBtn
@onready var grass_btn = $UI/Panel/HBox/GrassBtn
@onready var mtn_btn = $UI/Panel/HBox/MtnBtn
@onready var k_blue_btn = $UI/Panel/HBox/K_Blue
@onready var k_red_btn = $UI/Panel/HBox/K_Red
@onready var monster_btn = $UI/Panel/HBox/Monster

func _ready() -> void:
	await get_tree().process_frame
	
	# Setup UI Blocking
	ui_panel.mouse_entered.connect(func(): is_mouse_on_ui = true)
	ui_panel.mouse_exited.connect(func(): is_mouse_on_ui = false)
	inspector_panel.mouse_entered.connect(func(): is_mouse_on_ui = true)
	inspector_panel.mouse_exited.connect(func(): is_mouse_on_ui = false)
	
	_update_button_visuals() # Set visual awal
	
	# SETUP KAMERA SEBELUM GENERATE
	var screen_size = get_viewport_rect().size
	if screen_size.x == 0: screen_size = Vector2(1152, 648)
	
	var map_size_px = Vector2(grid_size.x * 16.0, grid_size.y * 16.0)
	var limit_x = screen_size.x / map_size_px.x
	var limit_y = screen_size.y / map_size_px.y
	var safe_zoom = maxf(limit_x, limit_y)
	safe_zoom = maxf(safe_zoom, 0.1) 
	
	camera.min_zoom = safe_zoom
	camera.zoom = Vector2(safe_zoom, safe_zoom)
	if "zoom_target" in camera:
		camera.zoom_target = Vector2(safe_zoom, safe_zoom)
	
	camera.position = map_size_px / 2.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(map_size_px.x)
	camera.limit_bottom = int(map_size_px.y)
	
	randomize() 
	print("Generating World (256x256)...")
	
	await _generate_world()
	
	print("World Generated!")
	is_world_ready = true
	
	show_unit_info.connect(_on_unit_selected)
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.autostart = true
	timer.timeout.connect(_on_simulation_step)
	add_child(timer)

func _generate_world() -> void:
	tile_map.clear()
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.02 
	noise.fractal_octaves = 5

	for x in range(grid_size.x):
		if x % 8 == 0: await get_tree().process_frame
		
		grid.append([])
		for y in range(grid_size.y):
			var n = noise.get_noise_2d(x, y)
			
			var dist_x = float(x - grid_size.x / 2.0) / (grid_size.x / 2.0)
			var dist_y = float(y - grid_size.y / 2.0) / (grid_size.y / 2.0)
			var dist = sqrt(dist_x*dist_x + dist_y*dist_y)
			n -= dist * 0.6 
			
			var type = Element.OCEAN
			if n < -0.15: type = Element.OCEAN
			elif n < 0.05: type = Element.SAND
			elif n < 0.2: type = Element.DIRT 
			elif n < 0.6: type = Element.GRASS 
			else: type = Element.MOUNTAIN
			
			grid[x].append(type)
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(type, 0))

func _process(_delta: float) -> void:
	if not is_world_ready: return
	spawn_cooldown -= _delta
	
	# Pengecekan UI yang lebih kuat:
	# Jika mouse sedang di atas elemen UI apa pun, jangan proses input game
	if get_viewport().gui_get_hovered_control() != null:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_element == -1: return 
		var mouse_pos = tile_map.local_to_map(get_global_mouse_position())
		_paint_brush(mouse_pos.x, mouse_pos.y)

func _is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y

func set_current_element(type: int) -> void:
	if current_element == type:
		current_element = -1 
	else:
		current_element = type
	_update_button_visuals()

func _update_button_visuals() -> void:
	var active_color = Color(1, 1, 0.5) # Kuning Cerah untuk aktif
	var inactive_color = Color(0.6, 0.6, 0.6) # Abu-abu gelap untuk tidak aktif
	
	# Helper lambda
	var set_btn = func(btn, type):
		if current_element == type:
			btn.modulate = active_color
			btn.scale = Vector2(1.1, 1.1) # Efek membesar sedikit
		else:
			btn.modulate = inactive_color
			btn.scale = Vector2(1.0, 1.0)

	set_btn.call(ocean_btn, Element.OCEAN)
	set_btn.call(sand_btn, Element.SAND)
	set_btn.call(dirt_btn, Element.DIRT)
	set_btn.call(grass_btn, Element.GRASS)
	set_btn.call(mtn_btn, Element.MOUNTAIN)
	set_btn.call(k_blue_btn, Element.SPAWN_KINGDOM_A)
	set_btn.call(k_red_btn, Element.SPAWN_KINGDOM_B)
	set_btn.call(monster_btn, Element.SPAWN_MONSTER)

func _set_cell(x: int, y: int, type: int) -> void:    if _is_in_bounds(x, y):
		grid[x][y] = type
		tile_map.set_cell(Vector2i(x, y), 0, Vector2i(type, 0))

func _paint_brush(cx: int, cy: int) -> void:
	if current_element >= 100: 
		if spawn_cooldown <= 0:
			_spawn_unit(get_global_mouse_position(), current_element)
			spawn_cooldown = 0.1
		return

	for x in range(cx - brush_size, cx + brush_size + 1):
		for y in range(cy - brush_size, cy + brush_size + 1):
			if Vector2(x, y).distance_to(Vector2(cx, cy)) <= brush_size:
				if current_element == Element.GRASS:
					if _is_in_bounds(x, y) and grid[x][y] == Element.DIRT:
						_set_cell(x, y, Element.GRASS)
				else:
					_set_cell(x, y, current_element)

func _spawn_unit(pos: Vector2, type: int) -> void:
	var unit = unit_scene.instantiate()
	unit.position = pos
	
	if type == Element.SPAWN_KINGDOM_A:
		unit.kingdom_id = 1
		unit.kingdom_color = Color(0.2, 0.6, 1.0) 
		unit.unit_name = "Blue Human"
	elif type == Element.SPAWN_KINGDOM_B:
		unit.kingdom_id = 2
		unit.kingdom_color = Color(0.9, 0.2, 0.2) 
		unit.unit_name = "Red Human"
	elif type == Element.SPAWN_MONSTER:
		unit.is_monster = true
		unit.kingdom_color = Color(0.6, 0.0, 0.8) 
	
	unit.unit_clicked.connect(_on_unit_clicked_signal)
	add_child(unit)

func _on_unit_clicked_signal(unit) -> void:
	emit_signal("show_unit_info", unit)

func _on_unit_selected(unit) -> void:
	selected_unit = unit
	inspector_panel.visible = true

func _on_simulation_step() -> void:
	if not is_world_ready: return
	
	_update_inspector_ui()
	
	var visible_chunks = _get_visible_chunks_rect()
	
	for cx in range(visible_chunks.position.x, visible_chunks.end.x):
		for cy in range(visible_chunks.position.y, visible_chunks.end.y):
			_simulate_chunk(cx, cy)

func _get_visible_chunks_rect() -> Rect2i:
	var viewport_rect = get_viewport_rect()
	var cam_pos = camera.global_position
	var zoom = camera.zoom
	
	var view_size = viewport_rect.size / zoom
	var top_left = cam_pos - (view_size / 2.0)
	var bottom_right = cam_pos + (view_size / 2.0)
	
	var min_chunk_x = floor(top_left.x / (16.0 * CHUNK_SIZE))
	var min_chunk_y = floor(top_left.y / (16.0 * CHUNK_SIZE))
	var max_chunk_x = ceil(bottom_right.x / (16.0 * CHUNK_SIZE))
	var max_chunk_y = ceil(bottom_right.y / (16.0 * CHUNK_SIZE))
	
	min_chunk_x = clampi(min_chunk_x, 0, int(float(grid_size.x) / CHUNK_SIZE))
	min_chunk_y = clampi(min_chunk_y, 0, int(float(grid_size.y) / CHUNK_SIZE))
	max_chunk_x = clampi(max_chunk_x, 0, int(float(grid_size.x) / CHUNK_SIZE))
	max_chunk_y = clampi(max_chunk_y, 0, int(float(grid_size.y) / CHUNK_SIZE))
	
	return Rect2i(min_chunk_x, min_chunk_y, max_chunk_x - min_chunk_x, max_chunk_y - min_chunk_y)

func _simulate_chunk(cx: int, cy: int) -> void:
	for i in range(3):
		var lx = randi() % CHUNK_SIZE
		var ly = randi() % CHUNK_SIZE
		
		var gx = cx * CHUNK_SIZE + lx
		var gy = cy * CHUNK_SIZE + ly
		
		if gx < 0 or gx >= grid_size.x or gy < 0 or gy >= grid_size.y:
			continue
		
		if grid[gx][gy] == Element.GRASS:
			_spread_grass(gx, gy)

func _spread_grass(x: int, y: int) -> void:
	var neighbors = [Vector2i(x+1, y), Vector2i(x-1, y), Vector2i(x, y+1), Vector2i(x, y-1)]
	for n in neighbors:
		if _is_in_bounds(n.x, n.y) and grid[n.x][n.y] == Element.DIRT:
			if randf() < 0.1: 
				_set_cell(n.x, n.y, Element.GRASS)

func _update_inspector_ui() -> void:
	if not is_instance_valid(selected_unit):
		if inspector_panel.visible:
			inspector_panel.visible = false
		return

	name_label.text = "Name: " + selected_unit.unit_name
	var k_text = "Kingdom " + str(selected_unit.kingdom_id)
	if selected_unit.is_monster: k_text = "Monster Horde"
	kingdom_label.text = "Kingdom: " + k_text
	guild_label.text = "Guild: " + selected_unit.guild_name
	hp_label.text = "HP: " + str(int(selected_unit.stats.hp)) + "/" + str(int(selected_unit.stats.max_hp))
	traits_label.text = "Traits: " + str(selected_unit.u_traits)
