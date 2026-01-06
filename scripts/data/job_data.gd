extends Node

enum JobType { UNEMPLOYED, FARMER, MINER, BUILDER, SOLDIER }

const JOBS = {
	JobType.UNEMPLOYED: {"name": "Unemployed", "description": "Looking for work"},
	JobType.FARMER: {"name": "Farmer", "description": "Produces food"},
	JobType.MINER: {"name": "Miner", "description": "Gathers minerals"},
	JobType.BUILDER: {"name": "Builder", "description": "Constructs buildings"},
	JobType.SOLDIER: {"name": "Soldier", "description": "Defends the kingdom"}
}
