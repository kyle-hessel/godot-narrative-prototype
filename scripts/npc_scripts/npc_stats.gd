extends Node

class_name NPCStats

@export var base_health_stat: int = 200
@export var current_health_stat: int = base_health_stat
@export var base_defense_stat: int # probably temporary until I break things down a bit more
@export var current_defense_stat: int = base_defense_stat
@export var base_speed_stat: int
@export var current_speed_stat: int = base_speed_stat
@export var base_luck_stat: int
@export var current_luck_stat: int = base_luck_stat
