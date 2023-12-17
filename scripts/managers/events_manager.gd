extends Node3D

class_name EventsManager

var events: Array[Event]
var cutscenes: Array[Cutscene]

var in_cutscene: bool = false

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
