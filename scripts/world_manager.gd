extends Node2D

@onready var tile_map: TileMapLayer = $TileMapLayer

signal show_unit_info(info)

enum Element { OCEAN, SAND, GRASS, MOUNTAIN, SPAWN_KINGDOM_A = 100, SPAWN_KINGDOM_B = 101, SPAWN_MONSTER = 102 }

var grid_size := Vector2i(128, 72)
var grid := []
var current_element := Element.SAND
var brush_size := 2
var unit_scene = preload("res://scenes/unit.tscn")

@onready var inspector_panel = $UI/InspectorPanel
@onready var name_label = $UI/InspectorPanel/VBox/NameLabel
@onready var kingdom_label = $UI/InspectorPanel/VBox/KingdomLabel
@onready var guild_label = $UI/InspectorPanel/VBox/GuildLabel
@onready var hp_label = $UI/InspectorPanel/VBox/HPLabel
@onready var traits_label = $UI/InspectorPanel/VBox/TraitsLabel

func _ready() -> void:
	randomize() # Acak seed global
	_generate_world()
	
	show_unit_info.connect(_update_inspector_ui)
	
	# Timer untuk simulasi (misal: pertumbuhan rumput)
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.autostart = true
	timer.timeout.connect(_on_simulation_step)
	add_child(timer)

func _update_inspector_ui(info: Dictionary) -> void:
	inspector_panel.visible = true
	name_label.text = "Name: " + info.name
	kingdom_label.text = "Kingdom: " + info.kingdom
	guild_label.text = "Guild: " + info.guild
	hp_label.text = "HP: " + info.hp
	traits_label.text = "Traits: " + info.traits

func _generate_world() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05
	noise.fractal_octaves = 4

	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			# Dapatkan nilai noise (-1 s/d 1)
			var n = noise.get_noise_2d(x, y)
			
			# Tambahkan mask agar berbentuk pulau
			var dist_x = float(x - grid_size.x / 2.0) / (grid_size.x / 2.0)
			var dist_y = float(y - grid_size.y / 2.0) / (grid_size.y / 2.0)
			var dist = sqrt(dist_x*dist_x + dist_y*dist_y)
			n -= dist * 0.5 
			
			var type = Element.OCEAN
			
			if n < -0.1:
				type = Element.OCEAN
			elif n < 0.05:
				type = Element.SAND
			elif n < 0.45:
				type = Element.GRASS
			else:
				type = Element.MOUNTAIN
			
			grid[x].append(type)
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i(type, 0))

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = tile_map.local_to_map(get_global_mouse_position())
		_paint_brush(mouse_pos.x, mouse_pos.y)

func _is_in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y

func set_current_element(type: int) -> void:
	current_element = type

func _set_cell(x: int, y: int, type: int) -> void:
	if _is_in_bounds(x, y):
		grid[x][y] = type
		tile_map.set_cell(Vector2i(x, y), 0, Vector2i(type, 0))

func _paint_brush(cx: int, cy: int) -> void:
	if current_element >= 100: # Logic Spawn Unit
		_spawn_unit(get_global_mouse_position(), current_element)
		return

	# Menggambar dengan ukuran kuas (lingkaran kasar)
	for x in range(cx - brush_size, cx + brush_size + 1):
		for y in range(cy - brush_size, cy + brush_size + 1):
			if Vector2(x, y).distance_to(Vector2(cx, cy)) <= brush_size:
				_set_cell(x, y, current_element)

func _spawn_unit(pos: Vector2, type: int) -> void:
	if randf() > 0.1: return # Rate limiter
	
	var unit = unit_scene.instantiate()
	unit.position = pos
	
	if type == Element.SPAWN_KINGDOM_A:
		unit.kingdom_id = 1
		unit.kingdom_color = Color(0.2, 0.6, 1.0) # Biru
		unit.unit_name = "Blue Human"
	elif type == Element.SPAWN_KINGDOM_B:
		unit.kingdom_id = 2
		unit.kingdom_color = Color(0.9, 0.2, 0.2) # Merah/Oranye
		unit.unit_name = "Red Human"
	elif type == Element.SPAWN_MONSTER:
		unit.is_monster = true
		unit.kingdom_color = Color(0.6, 0.0, 0.8) # Ungu Gelap
	
	unit.unit_clicked.connect(_on_unit_clicked)
	add_child(unit)

func _on_unit_clicked(info: Dictionary) -> void:
	emit_signal("show_unit_info", info)

func _on_simulation_step() -> void:
	for i in range(200): 
		var x = randi() % grid_size.x
		var y = randi() % grid_size.y
		if grid[x][y] == Element.GRASS:
			_spread_grass(x, y)

func _spread_grass(x: int, y: int) -> void:
	var neighbors = [Vector2i(x+1, y), Vector2i(x-1, y), Vector2i(x, y+1), Vector2i(x, y-1)]
	for n in neighbors:
		if _is_in_bounds(n.x, n.y) and grid[n.x][n.y] == Element.SAND:
			if randf() < 0.1: 
				_set_cell(n.x, n.y, Element.GRASS)