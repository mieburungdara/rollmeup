extends Node

enum RaceType { HUMAN, ORC, ELF, DWARF }

const RACES = {
	RaceType.HUMAN:
	{
		"name": "Human",
		"base_hp": 100,
		"base_dmg": 10,
		"base_speed": 45,
		"swimming_speed_mult": 0.3,
		"avg_lifespan": 75,
		"is_aggressive": false,
		"base_scale": Vector2(1.0, 1.0),
		"skin_colors": [Color(0.9, 0.7, 0.6), Color(0.7, 0.5, 0.3), Color(0.4, 0.2, 0.1)],
		"hair_colors": [Color(0.2, 0.1, 0.05), Color(0.6, 0.4, 0.2), Color(0.9, 0.8, 0.5)]
	},
	RaceType.ORC:
	{
		"name": "Orc",
		"base_hp": 180,
		"base_dmg": 18,
		"base_speed": 35,
		"swimming_speed_mult": 0.15,
		"avg_lifespan": 55,
		"is_aggressive": true,
		"base_scale": Vector2(1.2, 1.1),
		"skin_colors": [Color(0.3, 0.5, 0.2), Color(0.4, 0.6, 0.3), Color(0.2, 0.4, 0.1)],
		"hair_colors": [Color(0.1, 0.1, 0.1), Color(0.3, 0.3, 0.3)]
	},
	RaceType.ELF:
	{
		"name": "Elf",
		"base_hp": 85,
		"base_dmg": 14,
		"base_speed": 55,
		"swimming_speed_mult": 0.5,
		"avg_lifespan": 350,
		"is_aggressive": false,
		"base_scale": Vector2(0.9, 1.1),
		"skin_colors": [Color(1.0, 0.9, 0.8), Color(0.9, 0.8, 0.7)],
		"hair_colors": [Color(0.9, 0.9, 0.7), Color(0.7, 0.9, 0.9), Color(0.6, 0.4, 0.8)]
	},
	RaceType.DWARF:
	{
		"name": "Dwarf",
		"base_hp": 150,
		"base_dmg": 12,
		"base_speed": 30,
		"swimming_speed_mult": 0.1,
		"avg_lifespan": 150,
		"is_aggressive": false,
		"base_scale": Vector2(0.85, 0.85),
		"skin_colors": [Color(0.8, 0.6, 0.4), Color(0.7, 0.5, 0.3)],
		"hair_colors": [Color(0.5, 0.2, 0.1), Color(0.4, 0.4, 0.4), Color(0.3, 0.1, 0.0)]
	}
}
