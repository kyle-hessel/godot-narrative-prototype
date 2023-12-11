extends CanvasLayer

class_name Textbox

@onready var textbox_margin: MarginContainer = $TextboxMargin
@onready var textbox_panel: PanelContainer = $TextboxMargin/TextboxPanel
@onready var dialogue_label: RichTextLabel = $TextboxMargin/TextboxPanel/TextboxVbox/DialogueLabel
@onready var letter_display_timer: Timer = $LetterDisplayTimer

var text_reveal_effect: RichTextEffect = preload("res://assets/UI/dialogue/text/dialogue_label_reveal.tres")

const MAX_WIDTH: int = 256

signal finished_displaying

var dialogue: String = ""
var letter_index: int = 0

var letter_time: float = 0.03
var space_time: float = 0.06
var punctuation_time: float = 0.2

func _ready() -> void:
	# ARBITRARY wraps per-letter, WORD wraps, well, per-word.
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# each time the timer started by display_letter ends, said function is recursively called again by this lambda function.
	#letter_display_timer.timeout.connect(func(): display_letter())
	
	dialogue_label.install_effect(text_reveal_effect)
	
	for e in dialogue_label.custom_effects.size():
		if dialogue_label.custom_effects[e] is RichTextEffectReveal:
			dialogue_label.custom_effects[e].reveal_pos = 0
			letter_display_timer.timeout.connect(dialogue_label.custom_effects[e]._on_letter_display_timer_timeout)
			letter_display_timer.timeout.connect(func(): 
				letter_index += 1
				if letter_index >= dialogue.length():
					display_line()
			)
			finished_displaying.connect(dialogue_label.custom_effects[e]._on_signal_show_entire_line)

func begin_display_dialogue(text_to_display: String) -> void:
	dialogue = text_to_display
	letter_display_timer.start()
	dialogue_label.text = "[reveal]" + dialogue + "[/reveal]"

# this function overrides displaying each letter and jumps to displaying the entire dialogue string.
func display_line() -> void:
	letter_display_timer.stop()
	finished_displaying.emit()

## default dialogue display behavior.
#func display_letter() -> void:
	## one by one, add each letter from the dialogue to the label each time this function is called.
	#dialogue_label.text += dialogue[letter_index]
	#
	## increment to the next letter, and if at the end of the dialogue, notify dialogue_manager and return early.
	#letter_index += 1
	#if letter_index >= dialogue.length():
		#finished_displaying.emit()
		#return
	#
	## determine the speed between character print-outs using a timer, and vary said timer's speed depending on punctuation, etc.
	#match dialogue[letter_index]:
		#"!", ".", ",", "?" when (letter_index < dialogue.length()):
			#letter_display_timer.start(punctuation_time)
		#"!", ".", ",", "?" when (letter_index >= dialogue.length()):
			#letter_display_timer.start(punctuation_time * 2.0)
		#" ":
			#letter_display_timer.start(space_time)
		#_:
			#letter_display_timer.start(letter_time)
