extends CharacterBody2D

signal unit_clicked(unit)

enum UnitClass { CIVILIAN, WARRIOR, ARCHER }
enum Trait { NONE, GIANT, TINY, FAST, STRONG, REGEN }

# Data Identitas
var unit_name: String = "Human"
var kingdom_id: int = 0 
var kingdom_color: Color = Color.WHITE
var guild_name: String = "None"
var is_monster: bool = false

# Stats
var stats = {
    "hp": 100.0,
    "max_hp": 100.0,
    "speed": 30.0,
    "damage": 15.0,
    "attack_cooldown": 0.5
}
var u_traits: Array = []
var current_cd: float = 0.0

# AI
var move_target: Vector2
var state: String = "idle" # idle, moving, chase, fight
var target_unit: CharacterBody2D = null

@onready var color_rect = $ColorRect
@onready var detection_area = $DetectionArea

func _ready() -> void:
    if unit_name == "Human": 
        _generate_random_unit()
    
    color_rect.color = kingdom_color
    move_target = position
    
    if is_monster:
        scale = Vector2(1.2, 1.2)
        unit_name = "Orc"
        stats.damage = 8.0
        stats.hp = 150.0
        stats.max_hp = 150.0

    # AI Timer (Thinking Tick)
    var ai_timer = Timer.new()
    ai_timer.wait_time = randf_range(0.4, 0.7) 
    ai_timer.autostart = true
    ai_timer.timeout.connect(_on_ai_tick)
    add_child(ai_timer)

func _generate_random_unit() -> void:
    var guilds = ["Merchants", "Builders", "Warriors", "Mages", "Farmers"]
    guild_name = guilds.pick_random()
    
    if randf() < 0.4:
        var trait_pool = Trait.values()
        trait_pool.erase(Trait.NONE)
        add_trait(trait_pool.pick_random())

func add_trait(t: int) -> void:
    if t in u_traits: return
    u_traits.append(t)
    match t:
        Trait.GIANT:
            stats.max_hp *= 2.0; stats.damage *= 1.5; scale *= 1.3
        Trait.TINY:
            stats.max_hp *= 0.5; stats.speed *= 1.5; scale *= 0.7
        Trait.FAST: stats.speed *= 2.0
        Trait.STRONG: stats.damage *= 2.0
    stats.hp = stats.max_hp

func take_damage(amount: float) -> void:
    stats.hp -= amount
    
    # Efek Visual
    color_rect.color = Color(3, 0, 0)
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(color_rect, "color", kingdom_color, 0.2)
    tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1).set_trans(Tween.TRANS_BOUNCE)
    tween.chain().tween_property(self, "scale", Vector2(1, 1), 0.1)
    
    if stats.hp <= 0:
        queue_free()

func _physics_process(delta: float) -> void:
    current_cd -= delta
    
    match state:
        "idle":
            pass # Ditangani oleh AI Tick
        "moving":
            _move_to_target(delta)
            if position.distance_to(move_target) < 5.0:
                state = "idle"
        "chase":
            _move_to_target(delta)
            # Pindah ke fight jika dekat
            if is_instance_valid(target_unit):
                if position.distance_to(target_unit.position) < 25.0:
                    state = "fight"
            else:
                state = "idle"
        "fight":
            if is_instance_valid(target_unit):
                if position.distance_to(target_unit.position) > 30.0:
                    state = "chase"
                else:
                    _attack_target()
            else:
                state = "idle"

func _on_ai_tick() -> void:
    _check_for_enemies()
    
    if state == "idle":
        if randf() < 0.3:
            _pick_new_wander_target()
    elif state == "chase":
        if is_instance_valid(target_unit):
            move_target = target_unit.position
        else:
            state = "idle"

func _move_to_target(_delta: float) -> void:
    var dir = (move_target - position).normalized()
    velocity = dir * stats.speed
    move_and_slide()

func _check_for_enemies() -> void:
    var bodies = detection_area.get_overlapping_bodies()
    var closest_enemy = null
    var closest_dist = 9999.0
    
    for body in bodies:
        if body == self: continue
        if body.has_method("take_damage"):
            var is_enemy = false
            if is_monster and not body.is_monster: is_enemy = true
            elif not is_monster and body.is_monster: is_enemy = true
            elif kingdom_id != body.kingdom_id and \
                 kingdom_id != 0 and body.kingdom_id != 0:
                 is_enemy = true
            
            if is_enemy:
                var d = position.distance_to(body.position)
                if d < closest_dist:
                    closest_dist = d
                    closest_enemy = body
    
    if closest_enemy:
        target_unit = closest_enemy
        state = "chase"

func _attack_target() -> void:
    if current_cd <= 0:
        target_unit.take_damage(stats.damage)
        current_cd = stats.attack_cooldown
        
        # Animasi serangan
        var original_pos = position
        var dir = (target_unit.position - position).normalized()
        var tween = create_tween()
        tween.tween_property(self, "position", position + dir * 8.0, 0.1)
        tween.tween_property(self, "position", original_pos, 0.1)

func _pick_new_wander_target() -> void:
    var random_offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
    move_target = position + random_offset
    state = "moving"

func _on_click_button_pressed() -> void:
    emit_signal("unit_clicked", self)
