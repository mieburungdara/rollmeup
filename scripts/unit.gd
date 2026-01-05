extends CharacterBody2D

signal unit_clicked(info: Dictionary)

enum UnitClass { CIVILIAN, WARRIOR, ARCHER }
enum Trait { NONE, GIANT, TINY, FAST, STRONG, REGEN }

# Data Identitas
var unit_name: String = "Human"
var kingdom_id: int = 0 # 0 = Independent, 1=Blue, 2=Red, etc
var kingdom_color: Color = Color.WHITE
var guild_name: String = "None"
var is_monster: bool = false

# Stats
var stats = {
	"hp": 100.0,
	"max_hp": 100.0,
	"speed": 20.0,
	"damage": 5.0,
	"attack_cooldown": 1.0
}
var u_traits: Array[Trait] = []
var current_cd: float = 0.0

# AI
var move_target: Vector2
var state: String = "idle" # idle, moving, chase, fight
var target_unit: CharacterBody2D = null
var idle_timer: float = 0.0

@onready var color_rect = $ColorRect
@onready var detection_area = $DetectionArea

func _ready() -> void:
	if unit_name == "Human": # Generate random jika belum diset
		_generate_random_unit()
	
	color_rect.color = kingdom_color
	move_target = position
	
	# Skala monster sedikit lebih besar
	if is_monster:
		scale = Vector2(1.2, 1.2)
		unit_name = "Orc"
		stats.damage = 8.0
		stats.hp = 150.0
		stats.max_hp = 150.0

func _generate_random_unit() -> void:
	# Nama Guild Acak
	var guilds = ["Merchants", "Builders", "Warriors", "Mages", "Farmers"]
	guild_name = guilds.pick_random()
	
	# Trait Acak
	if randf() < 0.4:
		var trait_pool = Trait.values()
		trait_pool.erase(Trait.NONE)
		add_trait(trait_pool.pick_random())

func add_trait(t: Trait) -> void:
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
	# Efek flash merah saat kena hit
	color_rect.color = Color.RED
	var tween = create_tween()
	tween.tween_property(color_rect, "color", kingdom_color, 0.2)
	
	if stats.hp <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	current_cd -= delta
	
	match state:
		"idle":
			idle_timer -= delta
			_check_for_enemies()
			if idle_timer <= 0:
				_pick_new_wander_target()
		"moving":
			_move_to_target(delta)
			_check_for_enemies()
			if position.distance_to(move_target) < 5.0:
				state = "idle"
				idle_timer = randf_range(1.0, 3.0)
		"chase":
			if not is_instance_valid(target_unit):
				state = "idle"
				return
			
			move_target = target_unit.position
			_move_to_target(delta)
			
			if position.distance_to(target_unit.position) < 10.0:
				state = "fight"
		"fight":
			if not is_instance_valid(target_unit):
				state = "idle"
				return
			
			if position.distance_to(target_unit.position) > 15.0:
				state = "chase"
			else:
				_attack_target()

func _move_to_target(_delta: float) -> void:
	var dir = (move_target - position).normalized()
	velocity = dir * stats.speed
	move_and_slide()

func _check_for_enemies() -> void:
	# Optimasi: tidak perlu cek setiap frame, tapi biar simpel kita cek terus
	var bodies = detection_area.get_overlapping_bodies()
	var closest_enemy = null
	var closest_dist = 9999.0
	
	for body in bodies:
		if body == self: continue
		if body.has_method("take_damage"):
			# Cek permusuhan: Monster vs Semua, atau Beda Kingdom
			var is_enemy = false
			if is_monster and not body.is_monster: is_enemy = true
			elif not is_monster and body.is_monster: is_enemy = true
			elif kingdom_id != body.kingdom_id and kingdom_id != 0 and body.kingdom_id != 0: is_enemy = true
			
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
		
		# Animasi serangan simpel (mundur dikit lalu maju)
		var knockback = (position - target_unit.position).normalized() * 5.0
		position += knockback

func _pick_new_wander_target() -> void:
	var random_offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
	move_target = position + random_offset
	state = "moving"

func _on_click_button_pressed() -> void:
	var info = {
		"name": unit_name,
		"kingdom": "Kingdom " + str(kingdom_id) if not is_monster else "Monster Horde",
		"guild": guild_name,
		"hp": str(int(stats.hp)) + "/" + str(int(stats.max_hp)),
		"damage": str(stats.damage),
		"traits": str(u_traits)
	}
	emit_signal("unit_clicked", info)