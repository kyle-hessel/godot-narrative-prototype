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

const test_dialogue: Array[String] = [
	"Hey mang, what's poppin?",
	"Ya like jazz?",
	"So, what's the deal with game engines anyway, amiright!? *laugh track*"
]

func _on_overlap_area_body_entered(body):
	GameManager.ui_manager.dialogue_manager.start_dialogue(test_dialogue)

func _on_overlap_area_body_exited(body):
	pass # Replace with function body.
