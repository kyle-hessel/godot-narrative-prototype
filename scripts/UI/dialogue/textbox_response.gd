extends Textbox

class_name TextboxResponse

var label_scene: PackedScene = preload("res://scenes/UI/dialogue/dialogue_label.tscn")
var spacer_scene: PackedScene = preload("res://scenes/UI/dialogue/dialogue_spacer.tscn")
var text_color_effect: RichTextEffect = preload("res://assets/UI/dialogue/text/dialogue_label_color.tres")
@onready var textbox_vbox: VBoxContainer = $TextboxMargin/TextboxPanel/TextboxVbox

var dialogue_labels: Array[RichTextLabel]
var dialogues: Array

var player_selection: int = 0

func _ready():
	# append the first dialogue label (from Textbox) as we'll always have at least one.
	dialogue_labels.append(dialogue_label)

func _unhandled_input(event: InputEvent):
	select_response(event)

func begin_display_response(text_to_display: Array) -> void:
	dialogues = text_to_display
	
	var l: int = 1 # start at one as one dialogue label already exists.
	while l < dialogues.size():
		var label_inst: RichTextLabel = label_scene.instantiate()
		textbox_vbox.add_child(spacer_scene.instantiate())
		textbox_vbox.add_child(label_inst)
		dialogue_labels.append(label_inst)
		l += 1
		
	# ensure each RichTextLabel contains the proper effects and populate text for each of them with effects included.
	for d in dialogue_labels.size():
		dialogue_labels[d].install_effect(text_color_effect)
		color_text_field_at_pos(d)

func select_response(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		if player_selection > 0:
			player_selection -= 1
			# refresh dialogue response fields
			for d in dialogue_labels.size():
				color_text_field_at_pos(d)
	elif event.is_action_pressed("ui_down"):	
		if player_selection < dialogue_labels.size() - 1:
			player_selection += 1
			# refresh dialogue response fields
			for d in dialogue_labels.size():
				color_text_field_at_pos(d)

# color the text for every possible response, taking into account which is currently selected by the player.
func color_text_field_at_pos(pos: int) -> void:
	if pos == player_selection:
		dialogue_labels[pos].text = "[highlight_color color=#417fc2 char=a]" + dialogues[pos] + "[/highlight_color]"
	else:
		dialogue_labels[pos].text = "[highlight_color color=#ffffff]" + dialogues[pos] + "[/highlight_color]"
