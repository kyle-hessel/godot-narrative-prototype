extends Node

# no class_name, as this is a singleton

@onready var calendar_manager: CalendarManager = $CalendarManager
@onready var ui_manager: UIManager = $UIManager

func _ready():
	pass

func _on_calendar_manager_ready():
	pass
