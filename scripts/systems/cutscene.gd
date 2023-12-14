extends Node3D

class_name Cutscene

@onready var anim_player: AnimationPlayer = $CutsceneAnimationPlayer

@export var cutscene_name: String
@export var cameras: Dictionary = {}
@export var events: Array[Event]
@export var participants: Dictionary = {}

# send a signal when the cutscene finishes to send to the save system.
# the save system will then determine on boot which cutscenes should be monitoring for a cutscene trigger.
signal finished

func _ready() -> void:
	pass
	#GameManager.events_manager.register_cutscene(self)

func switch_camera(cam_name: String) -> void:
	pass

func _on_cutscene_area_body_entered(body):
	play_cutscene()

func play_cutscene() -> void:
	# fetches the node from an assigned NodePath.
	get_node(cameras["main"]).current = true
	
	print("cutscene!")
	for e: Event in events:
		var e_actions: Array = e.actions.keys()
		for a: String in e_actions:
			var val = e.actions[a] # cannot infer this type.
			
			if val is Animation:
				var anim_str: StringName = anim_player.find_animation(val)
				if anim_str != "":
					anim_player.play(anim_str)
			elif val is AnimationLibrary:
				pass
			elif val is Dialogue:
				pass
			elif val is Array[String]: # for Callables?
				pass
			else:
				pass
