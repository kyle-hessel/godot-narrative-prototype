extends Control

class_name DateUI

@onready var date_panel: PanelContainer = $DatePanel
@onready var date_number: Label = $DatePanel/DatePanelMargin/DateNumber

var date_num: int

var is_mouse_entered: bool = false

func _ready():
	pass

func _process(delta: float) -> void:
	if is_mouse_entered && Input.is_action_just_pressed("gui_select"):
		print("ello")

func _on_date_panel_mouse_entered():
	is_mouse_entered = true

func _on_date_panel_mouse_exited():
	is_mouse_entered = false
