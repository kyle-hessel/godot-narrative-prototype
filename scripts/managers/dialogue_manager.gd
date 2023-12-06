extends Control

# a sub-manager for ui_manager that handles solely dialogue, since it specifically requires displaying string data to the screen in a chronological sequence.
class_name DialogueManager

@onready var textbox: PackedScene = preload("res://scenes/UI/dialogue/textbox.tscn")
var textbox_inst: Textbox

var dialogue_lines: Array[String] = []
var current_line_index: int = 0

var is_dialogue_active: bool = false
var can_advance_line: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# if the right key is pressed, there is an active dialogue, and there is a line to advance to, reload the textbox.
	if event.is_action_pressed("gui_select"):
		if is_dialogue_active && can_advance_line:
			reload_textbox()
		# if the key is pressed early before the line can be advanced, display the rest of the line all at once.
		elif is_dialogue_active && !can_advance_line:
			textbox_inst.display_line()

# starts a new dialogue if one isn't active by displaying a textbox with the given dialogue lines.
func start_dialogue(lines: Array[String]) -> void:
	if is_dialogue_active:
		return
	
	# overwrite pre-existing dialogue_lines with new lines that were passed to the dialogue manager.
	dialogue_lines = lines
	show_textbox()
	
	# mark dialogue as active once a textbox is shown so another can't be instantiated over the existing one.
	is_dialogue_active = true

# instantiate the textbox, hook up a signal for advancing dialogue lines, and begin dialogue printing to the textbox.
func show_textbox() -> void:
	textbox_inst = textbox.instantiate()
	# for consistent naming behind the scenes, probably not necessary but could be useful.
	textbox_inst.name = "TextboxLine" + str(current_line_index)
	# mark can_advance_line as true again once the textbox deems the current string as finished displaying, using this lamba function.
	textbox_inst.finished_displaying.connect(func(): can_advance_line = true)
	add_child(textbox_inst)
	# using the current line index (incremented using player input), decide which dialogue line to print from what was passed into the manager.
	textbox_inst.begin_display(dialogue_lines[current_line_index])
	# mark can_advance_line to false for now so that the line can't be skipped pre-emptively (modify later to print out all dialogue at once when skipping early).
	can_advance_line = false

# deletes the current textbox, increments which dialogue string should be fed into the next textbox, and draws the next line with a new textbox if there is one.
func reload_textbox() -> void:
	textbox_inst.queue_free() # could add a function here instead that plays an animation before queue_free.
	
	current_line_index += 1
	# if there is no more dialogue, reset to defaults.
	if current_line_index >= dialogue_lines.size():
		is_dialogue_active = false
		can_advance_line = false
		current_line_index = 0
		return
	
	show_textbox()
