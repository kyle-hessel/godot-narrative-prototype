extends Node

@onready var calendar_manager: CalendarManager = $CalendarManager
@onready var ui_manager: UIManager = $UIManager
@onready var dialogue_manager: DialogueManager = $DialogueManager

func _ready():
	dialogue_manager.Test()

func _on_calendar_manager_ready():
	pass
