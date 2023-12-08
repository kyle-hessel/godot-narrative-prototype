extends Control

class_name UIManager

var ui_open: bool = false
var using_joypad: bool = false

var calendar_ui: PackedScene = preload("res://scenes/UI/calendar/calendar_ui.tscn")
var calendar_ui_inst: CalendarUI

@onready var dialogue_manager: DialogueManager = $DialogueManager

func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("menu_game"):
		get_viewport().set_input_as_handled() # not sure if this is really helping anything
		
		# this will need to change if the calendar can ever be opened over other UI elements later.
		if !ui_open:
			if event is InputEventJoypadButton:
				using_joypad = true
			else:
				using_joypad = false
			
			calendar_ui_inst = calendar_ui.instantiate()
			calendar_ui_inst.show_mouse.connect(_gui_show_mouse)
			calendar_ui_inst.hide_mouse.connect(_gui_hide_mouse)
			calendar_ui_inst.using_joypad = using_joypad
			add_child(calendar_ui_inst)
			
			ui_open = true
		else:
			ui_open = false
			calendar_ui_inst.queue_free()

func _process(delta):
	pass

func _gui_show_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _gui_hide_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func dialogue_early_out() -> void:
	if dialogue_manager.is_npc_dialogue_active:
		dialogue_manager.line_index = 99 # overload to a value bigger than any array of dialogue strings ever ought to be to force-delete.
		dialogue_manager.reload_textbox()
