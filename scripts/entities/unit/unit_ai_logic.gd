extends Node

static func on_ai_tick(u: CharacterBody2D) -> void:
	update_age(u)
	if u.state == u.State.CHASE or u.state == u.State.FIGHT:
		if not is_instance_valid(u.target_unit): u.state = u.State.IDLE
		return
	check_for_enemies(u)
	if u.state == u.State.IDLE and randf() < 0.4: pick_new_wander_target(u)
	if 1 in u.u_traits: # REGEN (ID 1)
		u.stats.hp = min(u.stats.hp + 4.0, u.stats.max_hp)

static func update_age(u: CharacterBody2D) -> void:
	u.age_progress += 1.0
	if u.age_progress >= 20.0:
		u.age += 1; u.age_progress = 0.0
		if u.age >= u.max_age: u._die()

static func check_for_enemies(u: CharacterBody2D) -> void:
	if not is_instance_valid(u.world_manager): return
	var nearby = u.world_manager.get_units_in_range(u.global_position, 150.0)
	var closest_enemy = null; var closest_dist = 9999.0
	for other in nearby:
		if u._is_hostile_to(other):
			var d = u.global_position.distance_to(other.global_position)
			if d < closest_dist: closest_dist = d; closest_enemy = other
	if closest_enemy: u.target_unit = closest_enemy; u.state = u.State.CHASE

static func pick_new_wander_target(u: CharacterBody2D) -> void:
	for i in range(8):
		var target = u.position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
		if is_instance_valid(u.world_manager):
			var tile = u.world_manager.get_tile_at_pos(target)
			if tile in [1, 2, 5, 8, 9, 10]:
				u.move_target = target; u.state = u.State.MOVING; return
	u.state = u.State.IDLE
