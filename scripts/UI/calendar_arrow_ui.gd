extends Control

class_name CalendarArrowUI

var is_mouse_entered: bool = false

signal on_click

func _ready():
	pass


func _process(delta):
	pass


func _on_mouse_entered():
	is_mouse_entered = true


func _on_mouse_exited():
	is_mouse_entered = false


func _on_gui_input(event: InputEvent):
	if is_mouse_entered && event.is_action_pressed("gui_select"):
		emit_signal("on_click")
