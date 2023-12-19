extends Node3D

var physics_tick: int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")

signal cutscene_ready

func _ready():
	randomize()
	Engine.max_fps = physics_tick
	OS.delta_smoothing = true
	
	cutscene_ready.connect(func(): print("cutscene loaded!"))
	
	spawn_cutscene()

func spawn_cutscene() -> void:
	var test_cutscene: PackedScene = load("res://assets/cutscenes/samples/cutscene_test.tscn")
	var test_cutscene_inst: Node3D = test_cutscene.instantiate()
	add_child(test_cutscene_inst)
	cutscene_ready.emit()

func _physics_process(delta):
	match physics_tick:
		30:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 4)
		60:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 8)
		120:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 16)
		144:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 20)
		240:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 32)
		_:
			ProjectSettings.set_setting("physics/common/max_physics_steps_per_frame", 16)
