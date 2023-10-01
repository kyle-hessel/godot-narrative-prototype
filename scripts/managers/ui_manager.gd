extends Control

var ui_open: bool = false
var calendar_ui := preload("res://scenes/UI/calendar_ui.tscn")
var calendar_ui_inst : CanvasLayer

func _ready():
	pass


func _process(delta):
	if Input.is_action_just_pressed("menu_game"):
		if !ui_open:
			calendar_ui_inst = calendar_ui.instantiate()
			add_child(calendar_ui_inst)
			ui_open = true
		else:
			ui_open = false
			calendar_ui_inst.queue_free()
