extends CharacterBody3D

class_name NPCBase

@export_group("Assignables")
@export var npc_mesh: Node3D
@export var npc_name: String
@export var npc_type: NPCType = NPCType.Converser
@export var npc_stats: NPCStats
@export_group("")

@export var dialogue: Dialogue
var checkpoint_dialogue: Dialogue
var dialogue_branch_pos: int = 0

enum NPCType {
	Combatant = 0,
	Ally = 1,
	Merchant = 2,
	Converser = 3,
	Other = 4
}

func _ready() -> void:
	if dialogue != null:
		checkpoint_dialogue = dialogue
		dialogue.speaker = npc_name

func _on_overlap_area_body_entered(body: Node3D):
	if body is Player && dialogue != null:
		# sample dialogue trigger by an NPC.
		GameManager.ui_manager.dialogue_manager.participants[npc_name] = self
		GameManager.ui_manager.dialogue_manager.participants[body.player_name] = body
		GameManager.ui_manager.dialogue_manager.initiate_dialogue(checkpoint_dialogue, dialogue_branch_pos)

func _on_overlap_area_body_exited(body: Node3D):
	if body is Player && dialogue != null:
		# early-out of dialogue if any exists when player strays too far from an NPC.
		GameManager.ui_manager.dialogue_early_out()
		GameManager.ui_manager.dialogue_manager.participants.clear()
