extends Node

enum TraitType { NONE, GIANT, TINY, FAST, STRONG, REGEN, PEACEFUL, AGGRESSIVE }

const TRAITS = {
	TraitType.GIANT:
	{"name": "Giant", "hp_mult": 2.0, "dmg_mult": 1.5, "speed_mult": 0.8, "scale": 1.2},
	TraitType.TINY:
	{"name": "Tiny", "hp_mult": 0.5, "dmg_mult": 0.5, "speed_mult": 1.4, "scale": 0.85},
	TraitType.FAST: {"name": "Fast", "speed_mult": 2.0},
	TraitType.STRONG: {"name": "Strong", "dmg_mult": 2.0},
	TraitType.REGEN: {"name": "Regeneration"},
	TraitType.PEACEFUL: {"name": "Peaceful"},
	TraitType.AGGRESSIVE: {"name": "Aggressive", "dmg_mult": 1.2}
}

const CONFLICTS = {
	TraitType.GIANT: [TraitType.TINY],
	TraitType.TINY: [TraitType.GIANT],
	TraitType.PEACEFUL: [TraitType.AGGRESSIVE],
	TraitType.AGGRESSIVE: [TraitType.PEACEFUL]
}
