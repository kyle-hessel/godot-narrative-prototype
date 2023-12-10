extends CharacterBody3D

@export_group("Assignables")
@export var npc_mesh: Node3D
@export var npc_type: NPCType = NPCType.Converser
@export var npc_stats: NPCStats
@export_group("")

@export var dialogue: Dialogue

enum NPCType {
	Combatant = 0,
	Ally = 1,
	Merchant = 2,
	Converser = 3,
	Other = 4
}

func _on_overlap_area_body_entered(body: Node3D):
	if body is Player:
		# sample dialogue trigger by an NPC.
		GameManager.ui_manager.dialogue_manager.start_dialogue(dialogue)

func _on_overlap_area_body_exited(body: Node3D):
	if body is Player:
		# early-out of dialogue if any exists when player strays too far from an NPC.
		GameManager.ui_manager.dialogue_early_out()
