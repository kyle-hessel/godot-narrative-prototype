extends Control

class_name DialogueManager

@onready var textbox: PackedScene = preload("res://scenes/UI/dialogue/textbox.tscn")
var textbox_inst: Textbox

var dialogue_lines: Array[String] = []
var current_line_index: int = 0

var is_dialogue_active: bool = false
var can_advance_line: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("gui_select") && is_dialogue_active && can_advance_line):
		reload_textbox()

func start_dialogue(lines: Array[String]) -> void:
	if is_dialogue_active:
		return
	
	dialogue_lines = lines
	show_textbox()
	
	is_dialogue_active = true

func show_textbox() -> void:
	textbox_inst = textbox.instantiate()
	textbox_inst.finished_displaying.connect(_on_textbox_finished_displaying)
	add_child(textbox_inst)
	textbox_inst.display_text(dialogue_lines[current_line_index])
	can_advance_line = false

func reload_textbox() -> void:
	textbox_inst.queue_free()
	
	current_line_index += 1
	if current_line_index >= dialogue_lines.size():
		is_dialogue_active = false
		current_line_index = 0
		return
	
	show_textbox()

func _on_textbox_finished_displaying() -> void:
	can_advance_line = true
