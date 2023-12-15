extends Node3D

class_name Cutscene

@onready var anim_player: AnimationPlayer = $CutsceneAnimationPlayer

@export var cutscene_name: String
@export var cameras: Dictionary = {}
@export var events: Array[Event]
@export var participants: Dictionary = {}

var event_index: int = 0
var action_index: int = 0

# send a signal when the cutscene finishes to send to the save system.
# the save system will then determine on boot which cutscenes should be monitoring for a cutscene trigger.
signal cutscene_finished
signal event_finished

func _ready() -> void:
	GameManager.events_manager.register_cutscene(self)
	
	# signal connections for continuing cutscenes, and finishing events and cutscenes
	anim_player.animation_finished.connect(func(anim_name: StringName): increment_action())
	cutscene_finished.connect(func(): event_index = -1)
	event_finished.connect(func(): action_index = 0)

func switch_camera(cam_name: String) -> void:
	pass

func _on_cutscene_area_body_entered(body):
	start_cutscene()

func start_cutscene() -> void:
	# fetches the node from an assigned NodePath.
	get_node(cameras["main"]).current = true
	continue_cutscene()

func continue_cutscene() -> void:
	if event_index < events.size() && event_index > -1:
		continue_event()
	elif event_index < 0: # this means the cutscene has already been played before
		pass
	else:
		cutscene_finished.emit()

func continue_event() -> void:
	if action_index < events[event_index].actions.size():
		play_action(events[event_index].actions[action_index])
	else:
		event_index += 1
		event_finished.emit()
		continue_cutscene()

func play_action(action: Action) -> void:
	print(action)
	var action_context = action.action.keys()[0]
	if action_context is Animation:
		var anim_str: StringName = anim_player.find_animation(action_context)
		if anim_str != "":
			anim_player.play(anim_str)
			# extra information could be appended, such as animation speed, etc.
			if action.action[action_context] != null:
				pass
		
	elif action_context is AnimationLibrary:
		pass
	elif action_context is Dialogue:
		pass
	elif action_context is String: # Callables?
		pass
	elif action_context is Array[String]: # Chain of callables?
		pass
	elif action_context is NodePath:
		var node = get_node(action_context)
		if node is Camera3D:
			get_node(action_context).current = true
			# different potential camera movement
			# one potential way to switch cameras AND animate.
			# could just keep this up in the above Animation check
			# instead, and see what object is in the anim track?
			if action.action[action_context] is Animation:
				pass
			
			increment_action()
	else:
		pass

func increment_action() -> void:
	action_index += 1
	continue_event()
