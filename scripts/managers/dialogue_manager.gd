extends Control

# a sub-manager for ui_manager that handles solely dialogue, since it specifically requires displaying string data to the screen in a chronological sequence.
class_name DialogueManager

@onready var textbox: PackedScene = preload("res://scenes/UI/dialogue/textbox_default.tscn")
@onready var textbox_response: PackedScene = preload("res://scenes/UI/dialogue/textbox_response.tscn")

var textbox_inst: Textbox
var textbox_response_inst: TextboxResponse
var participants = {}
var dialogue_initiator: String

var events = {}
#var event_history = {} # would make more sense in the save system than here.

#enum EventOutcome {
	#
#}

var npc_dialogue_lines: Array
var player_response_lines: Array
var player_selection: int = 0
# branch_index is used to track which player response branch is chosen (based on NPC dialogue branches) due to how the data is structured.
# if dialogue_index is the index of the actual dialogue in the nested array, branch_index is the index of which dialogues to choose from in the outer array.
var branch_index: int = 0
var current_dialogue: Dialogue
var line_index: int = 0

var is_npc_dialogue_active: bool = false
var is_player_dialogue_active: bool = false
var can_advance_line: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# if the right key is pressed, determine how to proceed through dialogue.
	if event.is_action_pressed("gui_select"):
		# if there's a player dialogue, pass in the player choice (branch) and reload to continue on.
		if is_player_dialogue_active:
			advance_dialogue_and_reload_textbox(textbox_response_inst.player_selection)
		# if there's an NPC dialogue, decide to reload with the correct branch OR display the rest of the line first.
		elif is_npc_dialogue_active:
			if can_advance_line:
				advance_dialogue_and_reload_textbox(branch_index)
			# if the key is pressed early before the line can be advanced, display the rest of the line all at once.
			else:
				textbox_inst.display_line()

func initiate_dialogue(dialogue: Dialogue, dialogue_index: int = 0) -> void:
	dialogue_initiator = dialogue.speaker
	continue_dialogue(dialogue, dialogue_index)

# starts a new dialogue if one isn't active by displaying a textbox with the given dialogue lines.
func continue_dialogue(dialogue: Dialogue, dialogue_index: int = 0) -> void:
	current_dialogue = dialogue
	
	if dialogue.dialogue_type != Dialogue.DialogueType.RESPONSE:
		# overwrite pre-existing dialogue_lines with new lines that were passed to the dialogue manager.
		npc_dialogue_lines = dialogue.dialogue_options[dialogue_index]
		# mark dialogue as active once a textbox is shown so another can't be instantiated over the existing one.
		is_npc_dialogue_active = true
	else:
		player_response_lines = dialogue.dialogue_options[dialogue_index]
		is_player_dialogue_active = true
	
	# cache the branch index for reload_textbox in _unhandled_input.
	branch_index = dialogue_index
	
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
func advance_dialogue_and_reload_textbox(dialogue_index: int = 0) -> void:
	# if there isn't a next dialogue queued up, destroy existing textboxes as normal.
	if current_dialogue.next_dialogue == null:
		# if the player has an active dialogue, destroy that when this function is called before destroying NPC dialogue.
		if is_player_dialogue_active:
			textbox_response_inst.queue_free()
			is_player_dialogue_active = false
		
		textbox_inst.queue_free() # could add a function here instead that plays an animation before queue_free.
		line_index += 1
		# if there is no more dialogue, reset to defaults.
		if line_index >= npc_dialogue_lines.size():
			is_npc_dialogue_active = false
			can_advance_line = false
			line_index = 0
			branch_index = 0
			
			# once dialogue is completely finished, clear participants dictionary.
			participants.clear()
			
			return
		# otherwise, keep printing dialogue.
		else:
			show_textbox(current_dialogue.dialogue_type)
	
	# if there is a dialogue queued up, determine what to do to transition to that dialogue depending on its type.
	else:
		match current_dialogue.next_dialogue.dialogue_type:
			Dialogue.DialogueType.DEFAULT:
				# if the next dialogue is an NPC default dialogue and the current dialogue is a player response, then do the following:
				if is_player_dialogue_active:
					# delete the player textbox and mark player dialogue as inactive.
					textbox_response_inst.queue_free()
					is_player_dialogue_active = false
					
					# realign dialogue_index to align 1D array of NPC dialogues with 1D array of potential player responses.
					dialogue_index = realign_npc_dialogue_index(dialogue_index)
				
				textbox_inst.queue_free() # could add a function here instead that plays an animation before queue_free.
				line_index = 0
				
				# make the new NPC dialogue the checkpoint dialogue for the initiator of the conversation.
				participants[dialogue_initiator].checkpoint_dialogue = current_dialogue.next_dialogue
				participants[dialogue_initiator].dialogue_branch_pos = dialogue_index
				
				continue_dialogue(current_dialogue.next_dialogue, dialogue_index)
				
			Dialogue.DialogueType.RESPONSE:
				line_index += 1
				# once NPC dialogue lines run out, just start the new dialogue chain.
				if line_index >= npc_dialogue_lines.size():
					is_npc_dialogue_active = false
					can_advance_line = false
					# don't reset line_index here, as we need that data if textbox_inst remains during a player response in order to properly destroy textbox_inst after the fact.
					# don't mark an NPC dialogue checkpoint during a player response, as they aren't speaking (going to try to ensure this isn't needed going forward).
					
					# realign dialogue_index depending on what the upcoming player dialogues contain.
					dialogue_index = realign_player_dialogue_index(dialogue_index)
					
					continue_dialogue(current_dialogue.next_dialogue, dialogue_index)
					
				# otherwise, continue dialogue chain.
				else:
					textbox_inst.queue_free()
					show_textbox(current_dialogue.dialogue_type)
			Dialogue.DialogueType.CALL:
				pass
			Dialogue.DialogueType.MESSAGE:
				pass
			Dialogue.DialogueType.SHOUT:
				pass

#region Dialogue & textbox helper functions
func realign_npc_dialogue_index(dialogue_index: int) -> int:
	# if the incoming NPC dialogue only has one option, just set dialogue_index to 0 as the branching tree is now collapsing back down.
	if current_dialogue.next_dialogue.dialogue_options.size() == 1:
		dialogue_index = 0
	# if the incoming NPC dialogue has multiple options, determine how to format dialogue_index before passing it onto the next NPC dialogue if the player had more than one response list from the prior branches.
	else:
		if current_dialogue.dialogue_options.size() > 1:
			# map position of player's response in a 2D array back to a 1D array and assign it to dialogue_index so that the NPC chooses the correct line of dialogue.
			dialogue_index = return_dialogue_index_in_1d_array_format(dialogue_index)
	
	return dialogue_index

func realign_player_dialogue_index(dialogue_index: int) -> int:
	# if the incoming player dialogue only has one option, just set dialogue_index to 0 as the branching tree is now collapsing back down.
	if current_dialogue.next_dialogue.dialogue_options.size() == 1:
		dialogue_index = 0
	
	return dialogue_index

# break down 2D array of potential player responses from Dialogue's dialogue_options into a flat 1D array and convert the dialogue index accordingly.
func return_dialogue_index_in_1d_array_format(dialogue_index: int) -> int:
	var temp_pos: int = 0
	
	for pos: int in range(branch_index):
		temp_pos += current_dialogue.dialogue_options[pos].size()
	
	return temp_pos + dialogue_index

func destroy_textboxes() -> void:
	if is_player_dialogue_active:
		textbox_response_inst.queue_free()
		is_player_dialogue_active = false
		textbox_inst.queue_free()
		is_npc_dialogue_active = false
		can_advance_line = false
		line_index = 0
		branch_index = 0
	else:
		textbox_inst.queue_free()
		is_npc_dialogue_active = false
		can_advance_line = false
		line_index = 0
		branch_index = 0
#endregion
