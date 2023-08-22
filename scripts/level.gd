extends Node3D

var physics_tick: int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")

func _ready():
	randomize()
	Engine.max_fps = physics_tick

func _physics_process(delta):
	pass
