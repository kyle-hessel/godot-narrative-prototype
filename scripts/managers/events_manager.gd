extends Node3D

class_name EventsManager

@export var events: Array[Event]
@export var cutscenes: Array[Cutscene]

func register_event(event: Event) -> void:
	pass

func register_cutscene(cutscene: Cutscene) -> void:
	cutscenes.append(cutscene)

func trigger_events() -> void:
	pass

func trigger_event(event: Event) -> void:
	pass

func trigger_cutscenes() -> void:
	pass

func trigger_cutscene(cutscene: Cutscene) -> void:
	pass
