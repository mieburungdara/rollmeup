extends Node


static func on_ai_tick(u: CharacterBody2D) -> void:
	update_age(u)
	if u.state == u.State.CHASE or u.state == u.State.FIGHT:
		if not is_instance_valid(u.target_unit):
			u.state = u.State.IDLE
		return

	if u.state == u.State.IDLE:
		# Cari Resource terdekat jika tangan kosong
		if u.held_resource_amount == 0:
			find_nearby_resource(u)

		# Jika masih IDLE (tidak nemu resource), baru jalan-jalan acak
		if u.state == u.State.IDLE and randf() < 0.3:
			pick_new_wander_target(u)

	if 1 in u.u_traits:  # REGEN
		u.stats.hp = min(u.stats.hp + 4.0, u.stats.max_hp)


static func find_nearby_resource(u: CharacterBody2D):
	if not is_instance_valid(u.world_manager):
		return

	var map_pos = u.world_manager.tile_map.local_to_map(u.global_position)
	var search_range = 8

	for x in range(-search_range, search_range + 1):
		for y in range(-search_range, search_range + 1):
			var check_pos = map_pos + Vector2i(x, y)
			var type = u.world_manager.prop_map.get_cell_atlas_coords(check_pos).x

			# Jika menemukan Tree (6) atau Stone (7)
			if type == 6 or type == 7:
				u.target_resource_pos = check_pos
				u.move_target = check_pos * 32
				u.state = u.State.GATHERING
				u.popup_text("Found Resource!", Color.CYAN)
				return


static func update_age(u: CharacterBody2D) -> void:
	u.age_progress += 1.0
	if u.age_progress >= 20.0:
		u.age += 1
		u.age_progress = 0.0
		if u.age >= u.max_age:
			u._die()


static func check_for_enemies(u: CharacterBody2D) -> void:
	if not is_instance_valid(u.world_manager):
		return
	var nearby = u.world_manager.get_units_in_range(u.global_position, 150.0)
	var closest_enemy = null
	var closest_dist = 9999.0
	for other in nearby:
		if u._is_hostile_to(other):
			var d = u.global_position.distance_to(other.global_position)
			if d < closest_dist:
				closest_dist = d
				closest_enemy = other
	if closest_enemy:
		u.target_unit = closest_enemy
		u.state = u.State.CHASE


static func pick_new_wander_target(u: CharacterBody2D) -> void:
	var center = u.home_position if u.home_position != Vector2.ZERO else u.position

	for i in range(8):
		var target = (
			center
			+ Vector2(
				randf_range(-u.max_wander_distance, u.max_wander_distance),
				randf_range(-u.max_wander_distance, u.max_wander_distance)
			)
		)

		if is_instance_valid(u.world_manager):
			var tile = u.world_manager.get_tile_at_pos(target)
			if tile in [1, 2, 5, 8, 9, 10]:
				u.move_target = target
				u.state = u.State.MOVING
				return
	u.state = u.State.IDLE
