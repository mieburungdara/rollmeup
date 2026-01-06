extends Node

const RaceData = preload("res://scripts/data/race_data.gd")
const NameData = preload("res://scripts/data/name_data.gd")
const ClassData = preload("res://scripts/data/class_data.gd")
const JobData = preload("res://scripts/data/job_data.gd")
const TraitData = preload("res://scripts/data/trait_data.gd")

static func initialize_unit_data(u: CharacterBody2D) -> void:
	if u.u_traits.is_empty():
		generate_random_traits(u)

	var r_data = RaceData.RACES[u.u_race]
	u.unit_name = NameData.NAMES[u.u_race].pick_random() if NameData.NAMES.has(u.u_race) else r_data.name

	u.stats.max_hp = r_data.base_hp
	u.stats.damage = r_data.base_dmg
	u.stats.speed = r_data.base_speed
	u.base_scale = r_data.base_scale

	if u.is_monster:
		u.unit_name = "Orc Scout"
		u.stats.damage += 5.0
		u.stats.hp = u.stats.max_hp

	u.max_age = randi_range(r_data.avg_lifespan * 0.8, r_data.avg_lifespan * 1.2)
	u.age = randi_range(int(u.max_age * 0.2), int(u.max_age * 0.4))

	apply_all_modifiers(u)
	u.scale = u.base_scale
	u.move_target = u.position
	u.last_tracked_pos = u.global_position

static func generate_random_traits(u: CharacterBody2D) -> void:
	u.u_gender = 0 if randf() > 0.5 else 1
	u.u_class = ClassData.ClassType.values().pick_random()
	u.u_job = JobData.JobType.values().pick_random()
	u.v_head = 0; u.v_hair = randi() % 5; u.v_body = randi() % 5; u.v_eyes = randi() % 5

	if u.u_race == RaceData.RaceType.ELF: u.v_head = 1
	elif u.u_race == RaceData.RaceType.ORC: u.v_head = 2
	elif u.u_race == RaceData.RaceType.DWARF: u.v_head = 3; u.v_hair = 3

	var trait_pool = []
	for t in TraitData.TraitType.values():
		if t != TraitData.TraitType.NONE: trait_pool.append(t)
	trait_pool.shuffle()

	var target_count = randi_range(3, 5)
	for t_id in trait_pool:
		if u.u_traits.size() >= target_count: break
		var has_conflict = false
		if TraitData.CONFLICTS.has(t_id):
			for cid in TraitData.CONFLICTS[t_id]:
				if cid in u.u_traits: has_conflict = true; break
		if not has_conflict: u.u_traits.append(t_id)

static func apply_all_modifiers(u: CharacterBody2D) -> void:
	var c_data = ClassData.CLASSES[u.u_class]
	u.stats.max_hp += c_data.hp_bonus
	u.stats.damage += c_data.dmg_bonus
	u.stats.speed *= c_data.speed_mult

	for t_id in u.u_traits:
		if TraitData.TRAITS.has(t_id):
			var t_data = TraitData.TRAITS[t_id]
			if t_data.has("hp_mult"): u.stats.max_hp *= t_data.hp_mult
			if t_data.has("dmg_mult"): u.stats.damage *= t_data.dmg_mult
			if t_data.has("speed_mult"): u.stats.speed *= t_data.speed_mult
			if t_data.has("scale"): u.base_scale *= t_data.scale
	u.stats.hp = u.stats.max_hp

static func setup_visuals(u: CharacterBody2D) -> void:
	var apply_part = func(sprite, tex_path, variant):
		sprite.texture = load(tex_path); sprite.region_enabled = true; sprite.region_rect = Rect2(variant * 32, 0, 32, 32)
	
	apply_part.call(u.sprite_head, "res://assets/parts_heads.png", u.v_head)
	apply_part.call(u.sprite_eyes, "res://assets/parts_eyes.png", u.v_eyes)
	apply_part.call(u.sprite_body, "res://assets/parts_bodies.png", u.v_body)
	apply_part.call(u.sprite_arms, "res://assets/parts_arms.png", u.v_head)
	apply_part.call(u.sprite_legs, "res://assets/parts_legs.png", 0)
	apply_part.call(u.sprite_hair, "res://assets/parts_hair.png", u.v_hair)

	var r_data = RaceData.RACES[u.u_race]
	var skin = r_data.skin_colors.pick_random(); var hair = r_data.hair_colors.pick_random()
	u.sprite_head.modulate = skin; u.sprite_arms.modulate = skin; u.sprite_legs.modulate = skin; u.sprite_hair.modulate = hair
	u.sprite_body.material.set_shader_parameter("kingdom_color", u.kingdom_color if u.kingdom_id != 0 else Color.WHITE)
