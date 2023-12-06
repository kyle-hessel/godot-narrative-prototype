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

# sample array of dialogue strings for an NPC.
const test_dialogue: Array[String] = [
	"What's poppin?",
	"Ya like jazz?",
	"brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrraaaaaaaaaaaaaaaaaaaaaaaaapppppppppppppppp!!!"
]

func _on_overlap_area_body_entered(body: Node3D):
	# sample dialogue trigger by an NPC.
	GameManager.ui_manager.dialogue_manager.start_dialogue(test_dialogue)

func _on_overlap_area_body_exited(body: Node3D):
	# a hacky sample way to force-delete dialogue when roaming too far from an NPC.
	var dlg_m: DialogueManager = GameManager.ui_manager.dialogue_manager
	if dlg_m.is_dialogue_active:
		dlg_m.current_line_index = 99 # overload to a value bigger than any array of dialogue strings ever ought to be
		dlg_m.reload_textbox()
