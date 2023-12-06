extends CanvasLayer

class_name Textbox

@onready var textbox_margin: MarginContainer = $TextboxMargin
@onready var textbox_panel: PanelContainer = $TextboxMargin/TextboxPanel
@onready var dialogue_label: Label = $TextboxMargin/TextboxPanel/DialogueLabel
@onready var letter_display_timer: Timer = $LetterDisplayTimer

const MAX_WIDTH: int = 256

signal finished_displaying

var dialogue: String = ""
var letter_index: int = 0

var letter_time: float = 0.03
var space_time: float = 0.06
var punctuation_time: float = 0.2

func _ready() -> void:
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD

func display_text(text_to_display: String) -> void:
	dialogue = text_to_display
	#dialogue_label.text = dialogue
	
	display_letter()

func display_letter() -> void:
	dialogue_label.text += dialogue[letter_index]
	
	letter_index += 1
	if letter_index >= dialogue.length():
		finished_displaying.emit()
		return
	
	match dialogue[letter_index]:
		"!", ".", ",", "?" when (letter_index < dialogue.length()):
			letter_display_timer.start(punctuation_time)
		"!", ".", ",", "?" when (letter_index >= dialogue.length()):
			letter_display_timer.start(punctuation_time * 2.0)
		" ":
			letter_display_timer.start(space_time)
		_:
			letter_display_timer.start(letter_time)

func _on_letter_display_timer_timeout():
	display_letter()
