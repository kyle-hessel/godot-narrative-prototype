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

func _on_overlap_area_body_entered(body):
	pass # Replace with function body.

func _on_overlap_area_body_exited(body):
	pass # Replace with function body.
