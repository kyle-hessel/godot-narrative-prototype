extends Node3D

class_name Cutscene

@onready var anim_player: AnimationPlayer = $CutsceneAnimationPlayer

@export var cutscene_name: String
@export var cameras: Dictionary = {}
@export var events: Array[Event]
@export var participants: Dictionary = {}
@export var is_replayable: bool = false

var action_contexts: Array
var event_index: int = 0
var action_index: int = 0
var action_context_index: int = 0
var dialogue_index: int = 0 # only used when dialogue is present

# send a signal when the cutscene finishes to send to the save system.
# the save system will then determine on boot which cutscenes should be monitoring for a cutscene trigger.
signal cutscene_finished
signal event_finished

func _ready() -> void:
	GameManager.events_manager.register_cutscene(self)
	
	# signal connections for continuing cutscenes, and finishing events and cutscenes
	anim_player.animation_finished.connect(func(anim_name: StringName): increment_action()) # this lambda is a weird hack
	cutscene_finished.connect(end_cutscene)
	event_finished.connect(func(): action_index = 0)
	
	GameManager.ui_manager.dialogue_manager.dialogue_complete.connect(increment_action)

func switch_camera(cam_name: String) -> void:
	pass

func _on_cutscene_area_body_entered(body: Node3D):
	if body is Player:
		start_cutscene()

func start_cutscene() -> void:
	GameManager.events_manager.in_cutscene = true
	# fetches the node from an assigned NodePath.
	get_node(cameras["main"]).current = true
	continue_cutscene()

func continue_cutscene() -> void:
	if event_index < events.size():
		continue_event()
	else:
		cutscene_finished.emit()

func end_cutscene() -> void:
	GameManager.events_manager.in_cutscene = false
	get_node(participants["Player"]).player_cam.current = true
	if is_replayable:
		event_index = 0
	else:
		queue_free()

func continue_event() -> void:
	if action_index < events[event_index].actions.size():
		play_action(events[event_index].actions[action_index])
	else:
		event_index += 1
		event_finished.emit()
		continue_cutscene()

func play_action(action: Action) -> void:
	action_contexts = action.action.keys()
	for action_context in action_contexts:
		if action_context is Animation:
			var anim_str: StringName = anim_player.find_animation(action_context)
			if anim_str != "":
				anim_player.play(anim_str)
				# Array position 0 of the action dictionary value is always the name of the node the animation is acting on. 
				# Array position 1 is always the animation to play on that node itself (its own AnimationPlayer).
				# any additional information appended after can be for animation speed, etc.
				# this is so that signals can be tied to said node for playing their own animations (e.g. a walk cycle).
				if action.action[action_context] is Array:
					var node_to_animate: Node3D = get_node(participants[action.action[action_context][0]])
					node_to_animate.play_animation(action.action[action_context][1], action_context.length)
			
		elif action_context is AnimationLibrary:
			pass
		elif action_context is Dialogue:
			# pass in all cutscene particiants as dialogue participants and initiate dialogue.
			for p in participants.keys():
				GameManager.ui_manager.dialogue_manager.participants[p] = get_node(participants[p])
			GameManager.ui_manager.dialogue_manager.initiate_dialogue(action_context, dialogue_index)
		elif action_context is String: # Callables?
			pass
		elif action_context is Array[String]: # Chain of callables?
			pass
		# run a specific function or task on a specific node
		elif action_context is NodePath:
			var node = get_node(action_context)
			# if the node is a camera, mark as active and decide what else to do.
			if node is Camera3D:
				node.current = true
				if action.action[action_context] is Animation:
					pass
				
				increment_action()
			# if the node is a player OR NPC (temporary, will be more granular later), execute a Callable.
			elif node is Player || node is NPCBase:
				# The key is a node, and the value is a method name, which we serialize by binding to a Callable and calling.
				Callable(node, action.action[action_context]).call()
				
				increment_action()
		else:
			pass
			
func increment_action() -> void:
	# if not all action contexts for the given action have completed yet, just increment action_context_index and early out.
	action_context_index += 1
	if action_context_index < action_contexts.size():
		return
	# if all action contexts for the given action have completed, move onto the next action in this event.
	else:
		action_context_index = 0
		action_index += 1
		continue_event()
