extends Control

# a sub-manager for ui_manager that handles solely dialogue, since it specifically requires displaying string data to the screen in a chronological sequence.
class_name DialogueManager

@onready var textbox: PackedScene = preload("res://scenes/UI/dialogue/textbox_default.tscn")
@onready var textbox_response: PackedScene = preload("res://scenes/UI/dialogue/textbox_response.tscn")
var textbox_inst: Textbox
var textbox_response_inst: TextboxResponse

var npc_dialogue_lines: Array
var player_response_lines: Array
var player_selection: int
var current_dialogue: Dialogue
var line_index: int = 0

var is_npc_dialogue_active: bool = false
var is_player_dialogue_active: bool = false
var can_advance_line: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# if the right key is pressed, determine how to proceed through dialogue.
	if event.is_action_pressed("gui_select"):
		# if there's a player dialogue, select a choice and reload to delete.
		if is_player_dialogue_active:
			reload_textbox()
		# if there's an NPC dialogue, decide to reload OR display the rest of the line first.
		elif is_npc_dialogue_active:
			if can_advance_line:
				reload_textbox()
			# if the key is pressed early before the line can be advanced, display the rest of the line all at once.
			else:
				textbox_inst.display_line()

# starts a new dialogue if one isn't active by displaying a textbox with the given dialogue lines.
func start_dialogue(dialogue: Dialogue) -> void:
	current_dialogue = dialogue
	
	if dialogue.dialogue_type != Dialogue.DialogueType.RESPONSE:
		if is_npc_dialogue_active:
			return
		
		# overwrite pre-existing dialogue_lines with new lines that were passed to the dialogue manager.
		npc_dialogue_lines = dialogue.dialogue_options[0]
		# mark dialogue as active once a textbox is shown so another can't be instantiated over the existing one.
		is_npc_dialogue_active = true
	else:
		if is_player_dialogue_active:
			return
		
		player_response_lines = dialogue.dialogue_options[0]
		is_player_dialogue_active = true
	
	show_textbox(dialogue.dialogue_type)

# determine if an NPC dialogue box or a player response box is going to be shown.
func show_textbox(dialogue_type: Dialogue.DialogueType) -> void:
	# if NPC dialogue: instantiate the textbox, hook up a signal for advancing dialogue lines, and begin dialogue printing to the textbox.
	if dialogue_type != Dialogue.DialogueType.RESPONSE:
		textbox_inst = textbox.instantiate()
		# mark can_advance_line as true again once the textbox deems the current string as finished displaying, using this lamba function.
		textbox_inst.finished_displaying.connect(func(): can_advance_line = true)
		add_child(textbox_inst)
		# for consistent naming behind the scenes, probably not necessary but could be useful.
		textbox_inst.name = "TextboxInst" + str(line_index)
		# using the current line index (incremented using player input), decide which dialogue line to print from what was passed into the manager.
		textbox_inst.begin_display_dialogue(npc_dialogue_lines[line_index])
		# mark can_advance_line to false for now so that the line can't be skipped pre-emptively (modify later to print out all dialogue at once when skipping early).
		can_advance_line = false
	# if player response: do the same as above but skip some steps regarding line-by-line display, and pass in the whole array of strings at once.
	else:
		textbox_response_inst = textbox_response.instantiate()
		add_child(textbox_response_inst)
		textbox_response_inst.name = "TextboxResponseInst" + str(line_index)
		textbox_response_inst.begin_display_response(player_response_lines)

# deletes the current textbox, increments which dialogue string should be fed into the next textbox, and draws the next line with a new textbox if there is one.
func reload_textbox() -> void:
	# if there isn't a next dialogue queued up or if it isn't a player response, destroy old textboxes as normal.
	if current_dialogue.next_dialogue == null || current_dialogue.next_dialogue.dialogue_type != Dialogue.DialogueType.RESPONSE:
		# if the player has an active dialogue, destroy that when this function is called before destroying NPC dialogue.
		if is_player_dialogue_active:
			textbox_response_inst.queue_free()
			is_player_dialogue_active = false
			
		# destroy NPC dialogue regardless, as it should still be displayed below the player dialogue.
		textbox_inst.queue_free() # could add a function here instead that plays an animation before queue_free.
	
		if is_npc_dialogue_active:
			line_index += 1
			# if there is no more dialogue, reset to defaults.
			if line_index >= npc_dialogue_lines.size():
				is_npc_dialogue_active = false
				can_advance_line = false
				line_index = 0
				return
	
	# if there is a player response queued up, do the following instead.	
	else:
		line_index += 1
		# once NPC dialogue lines run out, just start the new dialogue chain.
		if line_index >= npc_dialogue_lines.size():
			is_npc_dialogue_active = false
			can_advance_line = false
			line_index = 0
			
			start_dialogue(current_dialogue.next_dialogue)
		# otherwise, continue dialogue chain.
		else:
			textbox_inst.queue_free()
			show_textbox(current_dialogue.dialogue_type)

func destroy_textboxes() -> void:
	if is_player_dialogue_active:
		textbox_response_inst.queue_free()
		is_player_dialogue_active = false
		textbox_inst.queue_free()
		is_npc_dialogue_active = false
		can_advance_line = false
		line_index = 0
	else:
		textbox_inst.queue_free()
		is_npc_dialogue_active = false
		can_advance_line = false
		line_index = 0
