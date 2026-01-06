extends Node2D

# --- REFERENSI NODE ---
@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var prop_map: TileMapLayer = $PropLayer
@onready var fog_map: TileMapLayer = $FogLayer
@onready var camera: Camera2D = $Camera2D

# --- UI REFERENSI ---
@onready var ui_panel = $UI/Panel
@onready var brush_panel = $UI/BrushPanel
@onready var inspector_panel = $UI/InspectorPanel
@onready var options_window = $UI/OptionsWindow
@onready var date_label = $UI/TimePanel/DateLabel
@onready var save_btn = $UI/EditorActions/SaveBtn
@onready var name_label = $UI/InspectorPanel/VBox/NameLabel
@onready var kingdom_label = $UI/InspectorPanel/VBox/KingdomLabel
@onready var guild_label = $UI/InspectorPanel/VBox/GuildLabel
@onready var hp_label = $UI/InspectorPanel/VBox/HPLabel
@onready var traits_label = $UI/InspectorPanel/VBox/TraitsLabel
@onready var health_bar = $UI/InspectorPanel/VBox/HealthBar
@onready var loading_layer = $LoadingLayer
@onready var loading_bar = $LoadingLayer/VBox/ProgressBar
@onready var eraser_btn = $UI/Panel/HBox/EraserBtn
@onready var ocean_btn = $UI/Panel/HBox/OceanBtn
@onready var sand_btn = $UI/Panel/HBox/SandBtn
@onready var dirt_btn = $UI/Panel/HBox/DirtBtn
@onready var grass_btn = $UI/Panel/HBox/GrassBtn
@onready var tree_btn = $UI/Panel/HBox/TreeBtn
@onready var stone_btn = $UI/Panel/HBox/StoneBtn
@onready var mtn_btn = $UI/Panel/HBox/MtnBtn
@onready var k_blue_btn = $UI/Panel/HBox/K_Blue
@onready var k_red_btn = $UI/Panel/HBox/K_Red
@onready var monster_btn = $UI/Panel/HBox/Monster
@onready var hut_btn = $UI/Panel/HBox/HutBtn

# --- KONSTANTA & HELPER ---
const Generator = preload("res://scripts/core/world_generator.gd")
const Persistence = preload("res://scripts/core/world_persistence.gd")
const TileLogic = preload("res://scripts/core/world_tile_logic.gd")
const UnitLogic = preload("res://scripts/core/world_unit_logic.gd")
const UILogic = preload("res://scripts/core/world_ui_logic.gd")

enum Element {
    OCEAN,
    SAND,
    GRASS,
    MOUNTAIN,
    DIRT = 5,
    TREE = 6,
    STONE = 7,
    ERASER = -2,
    GRASS_B = 8,
    GRASS_C = 9,
    GRASS_D = 10,
    TREE_PINE = 11,
    TREE_BIRCH = 12,
    TREE_AUTUMN = 13,
    TREE_FRUIT = 14,
    CORPSE = 15,
    FOG = 16,
    WAGON_TL = 17,
    WAGON_TR = 18,
    WAGON_BL = 19,
    WAGON_BR = 20,
    HUT = 21,
    SPAWN_KINGDOM_A = 100,
    SPAWN_KINGDOM_B = 101,
    SPAWN_MONSTER = 102
}

# --- STATE ---
var grid_size := GameSettings.map_size
var grid := []
var current_element: int = -1
var brush_size := 1
var is_world_ready := false
var is_mouse_on_ui := false
var spawn_cooldown := 0.0
var world_year := 1
var world_month := 1
var world_day := 1
var unit_tracking_grid := {}
var selected_unit = null
var hovered_unit = null
const TRACKING_CELL_SIZE := 64
const CHUNK_SIZE := 16
var unit_scene = preload("res://scenes/unit.tscn")
const SAVE_PATH_BIN = "user://world_save.dat"
const SAVE_PATH_JSON = "user://custom_map.json"

signal show_unit_info(unit)

# ==========================================
# LIFECYCLE
# ==========================================


func _ready() -> void:
    show_unit_info.connect(_on_unit_selected)
    await get_tree().process_frame
    _setup_ui_events()
    _setup_speed_buttons()
    _setup_brush_buttons()
    UILogic.setup_button_icons(self)
    _initialize_camera()

    loading_layer.visible = true
    await _create_or_load_world()
    is_world_ready = true
    loading_layer.visible = false
    _fill_initial_fog()

    var timer = Timer.new()
    timer.wait_time = 0.1
    timer.autostart = true
    timer.timeout.connect(_on_simulation_step)
    add_child(timer)


func _process(delta: float) -> void:
    if not is_world_ready:
        return
    spawn_cooldown -= delta
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        if get_viewport().gui_get_hovered_control() == null:
            selected_unit = null
        if not is_mouse_on_ui and current_element != -1:
            TileLogic.paint_brush(
                self,
                tile_map.local_to_map(get_global_mouse_position()).x,
                tile_map.local_to_map(get_global_mouse_position()).y
            )


# ==========================================
# CORE LOGIC (Delegated)
# ==========================================


func _create_or_load_world():
    if GameSettings.is_editor_mode:
        match GameSettings.map_type:
            0:
                await Generator.generate_random_world(grid, grid_size, self)
            1:
                await Generator.generate_city_map(grid, grid_size, self)
            2:
                await _generate_payon_map()
    else:
        if GameSettings.map_type == 0:
            await Generator.generate_random_world(grid, grid_size, self)
            UnitLogic.spawn_starting_units(self)
            save_world()
        elif FileAccess.file_exists(SAVE_PATH_BIN):
            await Persistence.load_world(SAVE_PATH_BIN, self)
        else:
            await _generate_payon_map()
            UnitLogic.spawn_starting_units(self)
            save_world()


func _generate_payon_map():
    grid.clear()
    tile_map.clear()
    prop_map.clear()
    fog_map.clear()
    var map_script = load("res://scripts/maps/map_payon.gd").new()
    await map_script.generate(grid, grid_size, self)


func save_world():
    if Persistence.save_world(SAVE_PATH_BIN, grid_size, grid):
        Persistence.export_json(SAVE_PATH_JSON, grid_size, grid)
        print("Map Saved!")


func _on_simulation_step() -> void:
    if not is_world_ready:
        return
    world_day += 1
    if world_day > 30:
        world_day = 1
        world_month += 1
    if world_month > 12:
        world_month = 1
        world_year += 1
    date_label.text = "Year %d, Month %d, Day %d" % [world_year, world_month, world_day]
    UILogic.update_inspector_ui(self)
    _simulate_visible_chunks()


func _simulate_visible_chunks():
    var v = _get_visible_chunks_rect()
    for cx in range(v.position.x, v.end.x):
        for cy in range(v.position.y, v.end.y):
            for i in range(3):
                var gx = cx * CHUNK_SIZE + randi() % CHUNK_SIZE
                var gy = cy * CHUNK_SIZE + randi() % CHUNK_SIZE
                if _is_in_bounds(gx, gy) and grid[gx][gy] >= 2 and grid[gx][gy] <= 10:
                    _spread_grass(gx, gy)


func _spread_grass(x, y):
    for n in [Vector2i(x + 1, y), Vector2i(x - 1, y), Vector2i(x, y + 1), Vector2i(x, y - 1)]:
        if _is_in_bounds(n.x, n.y) and grid[n.x][n.y] == 5 and randf() < 0.1:
            _set_cell(n.x, n.y, get_random_grass())


# ==========================================
# PUBLIC API
# ==========================================


func _set_cell(x, y, type):
    TileLogic.set_cell(self, x, y, type)


func _update_tile_visuals(x, y, type):
    TileLogic.update_tile_visuals(self, x, y, type)


func _spawn_unit(pos, type):
    UnitLogic.spawn_unit(self, pos, type)


func register_unit(u):
    UnitLogic.register_unit(self, u)


func unregister_unit(u):
    UnitLogic.unregister_unit(self, u)


func update_unit_position(u, o, n):
    UnitLogic.update_unit_position(self, u, o, n)


func get_units_in_range(p, r):
    return UnitLogic.get_units_in_range(self, p, r)


func get_tile_at_pos(pos):
    var m = tile_map.local_to_map(pos)
    return grid[m.x][m.y] if _is_in_bounds(m.x, m.y) else 0


func _is_in_bounds(x, y):
    return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y


func get_random_grass():
    return [2, 8, 9, 10].pick_random()


func get_random_tree():
    return [6, 11, 12, 13, 14].pick_random()


func _fill_initial_fog():
    for x in range(grid_size.x):
        for y in range(grid_size.y):
            fog_map.set_cell(Vector2i(x, y), 0, Vector2i(16, 0))


# ==========================================
# UI & INPUT INTERNAL
# ==========================================


func _setup_ui_events():
    ui_panel.mouse_entered.connect(func(): is_mouse_on_ui = true)
    ui_panel.mouse_exited.connect(func(): is_mouse_on_ui = false)
    inspector_panel.mouse_entered.connect(func(): is_mouse_on_ui = true)
    inspector_panel.mouse_exited.connect(func(): is_mouse_on_ui = false)


func _setup_speed_buttons():
    var btns = {
        0: $UI/SpeedPanel/HBox/Btn0,
        1: $UI/SpeedPanel/HBox/Btn1,
        2: $UI/SpeedPanel/HBox/Btn2,
        4: $UI/SpeedPanel/HBox/Btn4
    }
    for s in btns:
        btns[s].pressed.connect(
            func():
                Engine.time_scale = float(s)
                _update_speed_ui(btns)
        )
    _update_speed_ui(btns)


func _update_speed_ui(btns):
    for s in btns:
        btns[s].modulate = Color(1, 0.8, 0.2) if Engine.time_scale == float(s) else Color.WHITE


func _setup_brush_buttons():
    var btns = {
        1: $UI/BrushPanel/VBox/HBox/Size1,
        2: $UI/BrushPanel/VBox/HBox/Size2,
        4: $UI/BrushPanel/VBox/HBox/Size4,
        8: $UI/BrushPanel/VBox/HBox/Size8
    }
    for s in btns:
        btns[s].pressed.connect(
            func():
                brush_size = s
                _update_brush_ui(btns)
        )
    _update_brush_ui(btns)


func _update_brush_ui(btns):
    for s in btns:
        btns[s].modulate = Color(1, 0.8, 0.2) if brush_size == s else Color.WHITE


func set_current_element(type: int):
    current_element = -1 if current_element == type else type
    _update_button_visuals()


func _update_button_visuals():
    var btns = {
        eraser_btn: -2,
        ocean_btn: 0,
        sand_btn: 1,
        dirt_btn: 5,
        grass_btn: 2,
        tree_btn: 6,
        stone_btn: 7,
        mtn_btn: 3,
        k_blue_btn: 100,
        k_red_btn: 101,
        monster_btn: 102,
        hut_btn: 21
    }
    for b in btns:
        b.modulate = Color(1, 1, 0.5) if current_element == btns[b] else Color(0.6, 0.6, 0.6)
        b.scale = Vector2(1.1, 1.1) if current_element == btns[b] else Vector2(1, 1)


func _initialize_camera():
    var map_size_px = Vector2(grid_size.x * 32.0, grid_size.y * 32.0)
    camera.position = map_size_px / 2.0
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = int(map_size_px.x)
    camera.limit_bottom = int(map_size_px.y)


func _on_unit_selected(u):
    selected_unit = u
    inspector_panel.visible = true


func _on_unit_hovered(u):
    hovered_unit = u
    if selected_unit == null:
        inspector_panel.visible = true


func _on_unit_unhovered():
    hovered_unit = null

    if selected_unit == null:
        inspector_panel.visible = false


func _on_toggle_editor_pressed():
    ui_panel.visible = !ui_panel.visible

    brush_panel.visible = ui_panel.visible


func _on_options_pressed():
    options_window.visible = !options_window.visible


func _on_exit_pressed():
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_quit_pressed():
    get_tree().quit()


func _get_visible_chunks_rect():
    var v = get_viewport_rect().size / camera.zoom
    var tl = camera.global_position - (v / 2.0)
    var br = camera.global_position + (v / 2.0)
    var x1 = clampi(int(tl.x / (32 * 16)), 0, int(grid_size.x / 16))
    var y1 = clampi(int(tl.y / (32 * 16)), 0, int(grid_size.y / 16))
    var x2 = clampi(int(br.x / (32 * 16)), 0, int(grid_size.x / 16))
    var y2 = clampi(int(br.y / (32 * 16)), 0, int(grid_size.y / 16))
    return Rect2i(x1, y1, x2 - x1 + 1, y2 - y1 + 1)
