extends Node

enum ClassType { CIVILIAN, WARRIOR, ARCHER, PALADIN, BERSERKER, MAGE }

const CLASSES = {
	ClassType.CIVILIAN:
	{
		"name": "Civilian",
		"hp_bonus": 0,
		"dmg_bonus": 0,
		"speed_mult": 1.0,
		"description": "Ordinary citizen"
	},
	ClassType.WARRIOR:
	{
		"name": "Warrior",
		"hp_bonus": 50,
		"dmg_bonus": 10,
		"speed_mult": 1.0,
		"description": "Standard melee fighter"
	},
	ClassType.ARCHER:
	{
		"name": "Archer",
		"hp_bonus": 20,
		"dmg_bonus": 5,
		"speed_mult": 1.2,
		"description": "Fast but fragile"
	},
	ClassType.PALADIN:
	{
		"name": "Paladin",
		"hp_bonus": 100,
		"dmg_bonus": 8,
		"speed_mult": 0.8,
		"description": "High defense tank"
	},
	ClassType.BERSERKER:
	{
		"name": "Berserker",
		"hp_bonus": 30,
		"dmg_bonus": 25,
		"speed_mult": 1.3,
		"description": "High damage, glass cannon"
	},
	ClassType.MAGE:
	{
		"name": "Mage",
		"hp_bonus": 10,
		"dmg_bonus": 20,
		"speed_mult": 0.9,
		"description": "Magical damage dealer"
	}
}
