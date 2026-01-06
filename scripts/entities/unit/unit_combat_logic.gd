extends Node


static func take_damage(u: CharacterBody2D, amount: float, attacker: Node2D = null) -> void:
	u.stats.hp -= amount
	u.mini_hp.visible = true
	u.mini_hp.max_value = u.stats.max_hp
	u.mini_hp.value = u.stats.hp

	var tween = u.create_tween()
	tween.set_parallel(true)
	tween.tween_property(u.get_node("Visuals"), "modulate", Color.RED, 0.05)
	tween.tween_property(u, "scale", u.base_scale * 0.8, 0.05)
	tween.chain().set_parallel(true)
	tween.tween_property(u.get_node("Visuals"), "modulate", Color.WHITE, 0.1)
	tween.tween_property(u, "scale", u.base_scale, 0.1)

	if attacker and u.state != u.State.FIGHT:
		u.target_unit = attacker
		u.state = u.State.CHASE
	if u.stats.hp <= 0:
		u._die(attacker)


static func gain_experience(u: CharacterBody2D, amount: float) -> void:
	u.experience += amount
	if u.experience >= u.exp_to_level:
		level_up(u)


static func level_up(u: CharacterBody2D) -> void:
	u.level += 1
	u.experience -= u.exp_to_level
	u.exp_to_level *= 1.3
	u.stats.max_hp += 20.0
	u.stats.damage += 5.0
	u.stats.hp = u.stats.max_hp
	var tw = u.create_tween()
	tw.tween_property(u, "modulate", Color.YELLOW, 0.2)
	tw.tween_property(u, "modulate", Color.WHITE, 0.2)
	var p = u.create_tween()
	p.tween_property(u, "scale", u.base_scale * 1.5, 0.2)
	p.tween_property(u, "scale", u.base_scale, 0.2)


static func die(u: CharacterBody2D, attacker = null):
	if is_instance_valid(attacker) and attacker.has_method("gain_experience"):
		attacker.gain_experience(60.0)
	var corpse = Sprite2D.new()
	corpse.set_script(load("res://scripts/entities/corpse.gd"))
	corpse.global_position = u.global_position
	u.get_parent().add_child(corpse)
	if is_instance_valid(u.world_manager):
		u.world_manager.unregister_unit(u)
	u.create_tween().tween_property(u, "scale", Vector2.ZERO, 0.3).finished.connect(u.queue_free)


static func attack_target(u: CharacterBody2D) -> void:
	if u.current_cd <= 0 and is_instance_valid(u.target_unit):
		u.target_unit.take_damage(u.stats.damage, u)
		u.current_cd = u.stats.attack_cooldown
		gain_experience(u, 5.0)
		u._play_animation("attack", true)
