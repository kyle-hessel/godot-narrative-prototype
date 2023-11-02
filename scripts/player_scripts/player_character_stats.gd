extends Node

class_name PlayerCharacterStats

@export var base_health_stat: int = 200
@export var current_health_stat: int = base_health_stat
@export var base_defense_stat: int # probably temporary until I break things down a bit more
@export var current_defense_stat: int = base_defense_stat
@export var base_speed_stat: int
@export var current_speed_stat: int = base_speed_stat
@export var base_luck_stat: int
@export var current_luck_stat: int = base_luck_stat

# just some ideas for now
enum PlayerClass {
	RANGER = 0,
	BARD = 1,
	ALCHEMIST = 2,
	ASSASSIN = 3,
	MONK = 4,
	WIZARD = 5,
	KNIGHT = 6,
	SAMURAI = 7,
	MARKSMAN = 8,
	SPIRIT = 9,
}

# just some ideas for now
enum ClassModifier {
	LONE_WOLF = 0,
	DEMON = 1,
	ANGEL = 2,
	ROYALTY = 3,
	LUMBERJACK = 4,
	BEAST_WHISPERER = 5,
	TACTICIAN = 6,
	CHARMED = 7,
	TANK = 8,
	ROGUE = 9
}

var player_class: PlayerClass = PlayerClass.RANGER
var class_modifier: ClassModifier = ClassModifier.LONE_WOLF

# outside of merely holding stats, functions relating to modifying stats 
# based on external (battles, etc) or internal (leveling up, skill trees, etc)
# factors could belong here, too.
