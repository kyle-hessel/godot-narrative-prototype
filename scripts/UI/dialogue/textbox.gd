extends CanvasLayer

class_name Textbox

@onready var textbox_margin: MarginContainer = $TextboxMargin
@onready var textbox_panel: PanelContainer = $TextboxMargin/TextboxPanel
@onready var dialogue_label: RichTextLabel = $TextboxMargin/TextboxPanel/TextboxVbox/DialogueLabel
@onready var letter_display_timer: Timer = $LetterDisplayTimer

var text_reveal_effect: RichTextEffect = preload("res://assets/UI/dialogue/text/dialogue_label_reveal.tres")
var dlg_trigger_effect: RichTextEffect = preload("res://assets/UI/dialogue/text/dialogue_label_trigger.tres")
var dlg_end_effect: RichTextEffect = preload("res://assets/UI/dialogue/text/dialogue_label_end.tres")

const MAX_WIDTH: int = 256

signal finished_displaying

var dialogue: String = ""
var letter_index: int = 0

@export var letter_time: float = 0.03
@export var space_time: float = 0.06
@export var punctuation_time: float = 0.2

func _ready() -> void:
	# ARBITRARY wraps per-letter, WORD wraps, well, per-word.
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# install the reveal and trigger effects.
	dialogue_label.install_effect(text_reveal_effect)
	dialogue_label.install_effect(dlg_trigger_effect)
	dialogue_label.install_effect(dlg_end_effect)
	
	# loop over any RichTextEffects.
	for e: int in dialogue_label.custom_effects.size():
		# if the effect is our reveal effect, act on it.
		if dialogue_label.custom_effects[e] is RichTextEffectReveal:
			# reset reveal_pos any time a new textbox is spawned.
			dialogue_label.custom_effects[e].reveal_pos = 0
			# increment the reveal effect in RichTextEffectReveal using the timer in this scene.
			letter_display_timer.timeout.connect(dialogue_label.custom_effects[e]._on_letter_display_timer_timeout)
			# also increment our letter index (for character monitoring) and restart our timer every time it ends.
			letter_display_timer.timeout.connect(increment_letter)
			# show all text at once in RichTextEffectReveal by connecting a function there to this signal.
			finished_displaying.connect(dialogue_label.custom_effects[e]._on_signal_show_entire_line)

# pass in dialogue, start the display timer, and add the [reveal] tag to the displayed text.
func begin_display_dialogue(text_to_display: String) -> void:
	dialogue = text_to_display
	letter_display_timer.start(letter_time)
	dialogue_label.text = "[reveal]" + dialogue + "[/reveal]"

# increments the letter by determining how long the timer should be and restarting it, which will modify the RichTextEffectReveal in turn.
func increment_letter() -> void:
	letter_index += 1
	# once the letter index is equal or greater than the length of the dialogue, finish displaying.
	if letter_index >= dialogue.length():
		display_line()
		return
	
	# determine the speed between character print-outs using a timer, and vary said timer's speed depending on punctuation, etc.
	match dialogue[letter_index]:
		"!", ".", ",", "?" when (letter_index < dialogue.length() - 2):
			letter_display_timer.start(punctuation_time)
		"!", ".", ",", "?" when (letter_index == dialogue.length() - 2):
			letter_display_timer.start(punctuation_time * 3.0)
		" ":
			letter_display_timer.start(space_time)
		_:
			letter_display_timer.start(letter_time)

# this function deems the entire dialogue line as displayed, meaning we can move onto the next line on the next key press.
func display_line() -> void:
	letter_display_timer.stop()
	finished_displaying.emit()
