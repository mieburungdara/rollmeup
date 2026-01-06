extends Node

const ClassData = preload("res://scripts/data/class_data.gd")
const JobData = preload("res://scripts/data/job_data.gd")
const RaceData = preload("res://scripts/data/race_data.gd")
const TraitData = preload("res://scripts/data/trait_data.gd")


static func update_inspector_ui(manager: Node2D):
	var t = manager.selected_unit if manager.selected_unit != null else manager.hovered_unit
	if not is_instance_valid(t):
		manager.inspector_panel.visible = false
		return

	var c = ClassData.CLASSES[t.u_class].name
	var j = JobData.JOBS[t.u_job].name
	var r = RaceData.RACES[t.u_race].name
	var tn = []
	for tid in t.u_traits:
		if TraitData.TRAITS.has(tid):
			tn.append(TraitData.TRAITS[tid].name)

	manager.name_label.text = "LV.%d %s (%s)" % [t.level, t.unit_name, c]
	manager.kingdom_label.text = "Kingdom: " + (str(t.kingdom_id) if t.kingdom_id != 0 else "None")
	manager.guild_label.text = "Race: %s (%d)" % [r, t.age]
	manager.hp_label.text = "Job: %s (%d/%d)" % [j, int(t.experience), int(t.exp_to_level)]
	manager.health_bar.max_value = t.stats.max_hp
	manager.health_bar.value = t.stats.hp
	manager.traits_label.text = ", ".join(tn) if tn.size() > 0 else "None"
	manager.inspector_panel.visible = true


static func setup_button_icons(manager: Node2D):
	var atlas = load("res://assets/world_tiles.png")
	var terrain = {
		manager.eraser_btn: 2,
		manager.ocean_btn: 0,
		manager.sand_btn: 1,
		manager.dirt_btn: 5,
		manager.grass_btn: 2,
		manager.tree_btn: 6,
		manager.stone_btn: 7,
		manager.mtn_btn: 3
	}
	for b in terrain:
		var tex = AtlasTexture.new()
		tex.atlas = atlas
		tex.region = Rect2(terrain[b] * 32, 0, 32, 32)
		b.icon = tex
		b.expand_icon = true
	manager.k_blue_btn.icon = load("res://assets/human_male_0.png")
	manager.k_red_btn.icon = load("res://assets/human_male_0.png")
	manager.monster_btn.icon = load("res://assets/orc.png")
