extends CanvasLayer

class_name Textbox

@onready var textbox_margin: MarginContainer = $TextboxMargin
@onready var textbox_panel: PanelContainer = $TextboxMargin/TextboxPanel
@onready var dialogue_label: Label = $TextboxMargin/TextboxPanel/DialogueLabel # make this a richtextlabel!
@onready var letter_display_timer: Timer = $LetterDisplayTimer

const MAX_WIDTH: int = 256

signal finished_displaying

var dialogue: String = ""
var letter_index: int = 0

var letter_time: float = 0.03
var space_time: float = 0.06
var punctuation_time: float = 0.2

func _ready() -> void:
	# ARBITRARY wraps per-letter, WORD wraps, well, per-word.
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	
	# each time the timer started by display_letter ends, said function is recursively called again by this lambda function.
	letter_display_timer.timeout.connect(func(): display_letter())

func begin_display(text_to_display: String) -> void:
	# fill the dialogue string with the passed in text, but don't apply it to the label itself yet.
	dialogue = text_to_display
	
	# begin displaying letters one by one for the given string of dialogue.
	display_letter()

# this function overrides displaying each letter and jumps to displaying the entire dialogue string.
func display_line() -> void:
	letter_display_timer.stop()
	dialogue_label.text = dialogue
	finished_displaying.emit()

# default dialogue display behavior.
func display_letter() -> void:
	# one by one, add each letter from the dialogue to the label each time this function is called.
	dialogue_label.text += dialogue[letter_index]
	
	# increment to the next letter, and if at the end of the dialogue, notify dialogue_manager and return early.
	letter_index += 1
	if letter_index >= dialogue.length():
		finished_displaying.emit()
		return
	
	# determine the speed between character print-outs using a timer, and vary said timer's speed depending on punctuation, etc.
	match dialogue[letter_index]:
		"!", ".", ",", "?" when (letter_index < dialogue.length()):
			letter_display_timer.start(punctuation_time)
		"!", ".", ",", "?" when (letter_index >= dialogue.length()):
			letter_display_timer.start(punctuation_time * 2.0)
		" ":
			letter_display_timer.start(space_time)
		_:
			letter_display_timer.start(letter_time)
