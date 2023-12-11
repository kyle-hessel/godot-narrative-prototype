extends Resource

class_name Dialogue

@export var dialogue_type: DialogueType = DialogueType.DEFAULT
@export var dialogue_options: Array[Array]
@export var speaker: String
@export var next_dialogue: Dialogue

enum DialogueType {
	DEFAULT = 0, # normal dialogue when an NPC talks to you
	RESPONSE = 1, # the player's response to any form of NPC dialogue
	CALL = 2, # phone call?
	MESSAGE = 3, # phone message?
	SHOUT = 4 # from distance shout, to get player's attention (dynamic dialogue box)
}
