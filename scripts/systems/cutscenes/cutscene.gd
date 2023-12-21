extends Node3D

class_name Cutscene

@onready var anim_player: AnimationPlayer = $CutsceneAnimationPlayer

@export var cutscene_name: String
@export var cameras: Dictionary = {}
@export var events: Array[Event]
@export var participants: Dictionary = {}
@export var is_replayable: bool = false

var cutscene_active: bool = false

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
	
	GameManager.ui_manager.dialogue_manager.dialogue_complete.connect(func():
		if cutscene_active:
			increment_action()
	)

func switch_camera(cam_name: String) -> void:
	pass

func _on_cutscene_area_body_entered(body: Node3D):
	if body is Player:
		start_cutscene()

func start_cutscene() -> void:
	cutscene_active = true
	GameManager.events_manager.in_cutscene = cutscene_active
	# fetches the node from an assigned NodePath.
	get_node(cameras["main"]).current = true
	continue_cutscene()

func continue_cutscene() -> void:
	if event_index < events.size():
		continue_event()
	else:
		cutscene_finished.emit()

func end_cutscene() -> void:
	cutscene_active = false
	GameManager.events_manager.in_cutscene = cutscene_active
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
				# array position 0 of the action dictionary value is always the name of the node the animation is acting on.
				# array position 1 is an Array of values pertaining to the animation data: 
				#			0 is the node property to animate (e.g. position).
				#			1 is the track_idx on the Animation that animates said property.
				# array position 2 is always the animation to play on that node itself (its own AnimationPlayer).
				# any additional information appended after can be for animation speed, etc.
				# this is so that signals can be tied to said node for playing their own animations (e.g. a walk cycle).
				if action.action[action_context] is Array:
					var action_context_value: Array = action.action[action_context]
					# retrieve a node path from the participants array using the name tagged to this animation action.
					var node_path: NodePath = participants[action_context_value[0]]
					
					# append the property to the node path to create the property path.
					var property_path: String = str(node_path) + ":" + action_context_value[1][0]
					# set the correct property on the correct track for this animation to ensure the right character is animated.
					action_context.track_set_path(action_context_value[1][1], NodePath(property_path)) # 0 won't always work here, will have to add a way to specify a track_index.
					
					# if an action is specified to play on the node's own AnimationPlayer, call the function to play it.
					if action_context_value[2] != "":
						var node_to_animate: Node3D = get_node(node_path)
						# this function, play_animation, has to be defined on the node.
						node_to_animate.play_animation(action_context_value[2], action_context.length)
				
				# play the animation. if the matching value is blank (not an Array), the animation will just play with default values.
				anim_player.play(anim_str)
			
		elif action_context is AnimationLibrary:
			pass
		elif action_context is Array:
			# if there is an array of Dialogues, determine which one to initiate depending on who is in the cutscene.
			# this is for divergent cutscene dialogue scenarios based on who the player chooses for their party, etc.
			if action_context[0] is Dialogue:
				var present_speakers: int = 0
				var dlg: Dialogue
				# determine if more than one participant has a dialogue in this array that they are a speaker for.
				# if so, stop overwriting dlg past 1 and keep count of how many.
				for dialogue: Dialogue in action_context:
					if participants.has(dialogue.speaker):
						if present_speakers < 1: # technically just a slight optimization
							dlg = dialogue
						present_speakers += 1
				
				# if there is more than one speaker present, use another metric, such as friendship level, to determine who speaks.
				if present_speakers > 1:
					pass
				# if there's only one speaker in the party that has a dialogue for this given action, have them speak.
				elif present_speakers == 1:
					for p in participants.keys():
						GameManager.ui_manager.dialogue_manager.participants[p] = get_node(participants[p])
					GameManager.ui_manager.dialogue_manager.initiate_dialogue(dlg, dialogue_index)
				else:
					print("No speakers present for the given dialogues.")
			
		elif action_context is Dialogue:
			# pass in all cutscene particiants as dialogue participants and initiate dialogue.
			for p in participants.keys():
				GameManager.ui_manager.dialogue_manager.participants[p] = get_node(participants[p])
			GameManager.ui_manager.dialogue_manager.initiate_dialogue(action_context, dialogue_index)
		# run a specific function on a specific node
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
			# for inserting a pause between moments.
			elif node is Timer:
				node.start(action.action[action_context])
				node.timeout.connect(increment_action)
			
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
