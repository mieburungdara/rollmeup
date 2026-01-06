extends CharacterBody2D
class_name Unit

# --- SINYAL ---
signal unit_clicked(unit)
signal unit_hovered(unit)
signal unit_unhovered

# --- KONSTANTA & HELPER ---
const Initializer = preload("res://scripts/entities/unit/unit_initializer.gd")
const AILogic = preload("res://scripts/entities/unit/unit_ai_logic.gd")
const CombatLogic = preload("res://scripts/entities/unit/unit_combat_logic.gd")
const FloatingText = preload("res://scripts/ui/floating_text.gd")

# --- IDENTITAS ---
var unit_name: String = ""
var u_race: int = 0
var u_gender: int = 0
var kingdom_id: int = 0
var kingdom_color: Color = Color.WHITE
var is_monster: bool = false

# --- STATS & PROGRES ---
var level := 1
var experience := 0.0
var exp_to_level := 100.0
var age := 0
var max_age := 0
var age_progress := 0.0
var u_class := 0
var u_job := 0
var u_traits := []
var stats = {"hp": 150.0, "max_hp": 150.0, "speed": 45.0, "damage": 15.0, "attack_cooldown": 0.6}
var current_cd := 0.0

# --- VISUAL ---
var v_head := 0
var v_eyes := 0
var v_body := 0
var v_hair := 0
var base_scale := Vector2(1.0, 1.0)
var last_tracked_pos: Vector2

# --- NODE REFERENCES ---
@onready var world_manager = get_tree().root.find_child("Main", true, false)
@onready var anim_player = $AnimationPlayer
@onready var mini_hp = $MiniHP
@onready var sprite_legs = $Visuals/Legs
@onready var sprite_body = $Visuals/Body
@onready var sprite_arms = $Visuals/Arms
@onready var sprite_head = $Visuals/Head
@onready var sprite_eyes = $Visuals/Eyes
@onready var sprite_hair = $Visuals/Hair

# --- AI & STATE ---
enum State { IDLE, MOVING, CHASE, FIGHT, GATHERING, RETURNING }
var state: State = State.IDLE
var move_target: Vector2
var home_position: Vector2
var max_wander_distance: float = 150.0
var target_unit: CharacterBody2D = null
var target_resource_pos: Vector2i
var held_resource_type: int = -1
var held_resource_amount: int = 0

@export_group("AI Settings")
@export var stop_distance := 10.0
@export var attack_range := 30.0
@export var chase_give_up_range := 45.0

# --- STUCK DETECTION ---
var last_pos_for_stuck_check: Vector2
var stuck_timer := 0.0

# ==========================================
# LIFECYCLE
# ==========================================


func _ready() -> void:
    Initializer.initialize_unit_data(self)
    Initializer.setup_visuals(self)
    _setup_groups()
    _start_ai_timer()


func _physics_process(delta: float) -> void:
    current_cd -= delta
    _update_facing_direction()
    _execute_state_machine(delta)
    _update_spatial_tracking()
    _update_fog()


# ==========================================
# DELEGATED ACTIONS
# ==========================================


func take_damage(amount: float, attacker: Node2D = null) -> void:
    CombatLogic.take_damage(self, amount, attacker)


func gain_experience(amount: float) -> void:
    CombatLogic.gain_experience(self, amount)


func _attack_target() -> void:
    CombatLogic.attack_target(self)


func _die(attacker = null) -> void:
    CombatLogic.die(self, attacker)


func popup_text(text: String, color: Color = Color.WHITE):
    FloatingText.create(get_parent(), global_position, text, color)


func _execute_state_machine(delta: float) -> void:
    if state == State.MOVING or state == State.CHASE:
        if position.distance_to(last_pos_for_stuck_check) < 0.5:
            stuck_timer += delta
            if stuck_timer > 1.0:
                state = State.IDLE
                stuck_timer = 0.0
        else:
            stuck_timer = 0.0
        last_pos_for_stuck_check = position

    match state:
        State.MOVING:
            _move_to_target(delta)
            _play_animation("walk")
            if position.distance_to(move_target) < stop_distance:
                state = State.IDLE
        State.CHASE:
            if is_instance_valid(target_unit):
                move_target = target_unit.global_position
                _move_to_target(delta)
                _play_animation("walk")
                if position.distance_to(target_unit.global_position) < attack_range:
                    state = State.FIGHT
            else:
                state = State.IDLE
        State.FIGHT:
            _play_animation("idle")
            if is_instance_valid(target_unit):
                if position.distance_to(target_unit.global_position) > chase_give_up_range:
                    state = State.CHASE
                else:
                    _attack_target()
            else:
                state = State.IDLE
        State.GATHERING:
            _move_to_target(delta)
            _play_animation("walk")
            if position.distance_to(move_target) < stop_distance:
                _perform_gathering(delta)
        State.RETURNING:
            move_target = home_position
            _move_to_target(delta)
            _play_animation("walk")
            if position.distance_to(home_position) < stop_distance:
                _deposit_resource()
        State.IDLE:
            _play_animation("idle")


func _perform_gathering(delta):
    _play_animation("attack")
    current_cd -= delta
    if current_cd <= 0:
        held_resource_amount += 10
        popup_text("+10 Resource", Color.GREEN)
        state = State.RETURNING
        current_cd = stats.attack_cooldown


func _deposit_resource():
    held_resource_amount = 0
    popup_text("Deposited!", Color.YELLOW)
    state = State.IDLE


# ==========================================
# HELPERS
# ==========================================


func _move_to_target(_delta: float) -> void:
    var final_speed = stats.speed
    if is_instance_valid(world_manager) and world_manager.get_tile_at_pos(global_position) == 0:
        final_speed *= 0.3
    velocity = (move_target - position).normalized() * final_speed
    move_and_slide()


func _is_hostile_to(body: Node) -> bool:
    if not body.is_in_group("units") or body == self:
        return false
    if is_monster:
        return not body.is_in_group("race_" + str(u_race))
    if body.is_in_group("monsters"):
        return true
    if kingdom_id != 0:
        for i in range(1, 5):
            var tk = "kingdom_" + str(i)
            if body.is_in_group(tk) and not is_in_group(tk):
                return true
    return false


func _play_animation(anim_name: String, force: bool = false) -> void:
    if anim_player.has_animation(anim_name):
        if anim_player.current_animation == "attack" and anim_player.is_playing() and not force:
            return
        if anim_player.current_animation != anim_name:
            anim_player.play(anim_name)


func _update_facing_direction() -> void:
    if velocity.x > 0:
        $Visuals.scale.x = 1
    elif velocity.x < 0:
        $Visuals.scale.x = -1


func _update_spatial_tracking() -> void:
    if is_instance_valid(world_manager):
        world_manager.update_unit_position(self, last_tracked_pos, global_position)
        last_tracked_pos = global_position


func _update_fog() -> void:
    if is_instance_valid(world_manager) and world_manager.is_world_ready:
        var m_pos = world_manager.tile_map.local_to_map(global_position)
        for x in range(-5, 6):
            for y in range(-5, 6):
                if Vector2(x, y).length() <= 5:
                    world_manager.fog_map.set_cell(m_pos + Vector2i(x, y), -1)


func _start_ai_timer() -> void:
    var t = Timer.new()
    t.wait_time = randf_range(0.4, 0.6)
    t.autostart = true
    t.timeout.connect(func(): AILogic.on_ai_tick(self))
    add_child(t)


func _setup_groups() -> void:
    add_to_group("units")
    add_to_group("race_" + str(u_race))
    if is_monster:
        add_to_group("monsters")
    if kingdom_id != 0:
        add_to_group("kingdom_" + str(kingdom_id))


func _on_click_button_pressed():
    emit_signal("unit_clicked", self)


func _on_mouse_entered():
    emit_signal("unit_hovered", self)


func _on_mouse_exited():
    emit_signal("unit_unhovered")
