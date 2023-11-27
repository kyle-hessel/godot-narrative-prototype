extends CharacterBody3D

@export_group("Assignables")
@export var npc_mesh: Node3D
@export var npc_type: NPCType = NPCType.Converser
@export var npc_stats: NPCStats
@export_group("")

enum NPCType {
	Combatant = 0,
	Ally = 1,
	Merchant = 2,
	Converser = 3,
	Other = 4
}
