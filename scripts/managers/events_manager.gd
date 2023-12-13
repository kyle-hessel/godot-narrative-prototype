extends Node3D

class_name EventsManager

@export var events: Array[Event]
@export var cutscenes: Array[Cutscene]

func add_event(event: Event) -> void:
	pass

func add_cutscene(cutscene: Cutscene) -> void:
	pass

func trigger_events() -> void:
	pass

func trigger_event(event: Event) -> void:
	pass

func trigger_cutscene() -> void:
	pass
