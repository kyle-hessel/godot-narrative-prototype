extends Control

class_name CalendarArrowUI

signal on_click

func _ready():
	pass

func _process(delta):
	pass

func _on_gui_input(event: InputEvent):
	if event.is_action_pressed("gui_select"):
		emit_signal("on_click")
