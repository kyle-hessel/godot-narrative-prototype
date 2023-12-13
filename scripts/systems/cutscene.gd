extends Node3D

class_name Cutscene

@export var cameras: Dictionary = {}
@export var events: Array[Event]

# send a signal when the cutscene finishes to send to the save system.
# the save system will then determine on boot which cutscenes should be monitoring for a cutscene trigger.
signal finished

func switch_camera(cam_name: String) -> void:
	pass
