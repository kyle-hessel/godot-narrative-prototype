extends Textbox

class_name TextboxResponse

var label_scene: PackedScene = preload("res://scenes/UI/dialogue/dialogue_label.tscn")
var spacer_scene: PackedScene = preload("res://scenes/UI/dialogue/dialogue_spacer.tscn")
@onready var textbox_vbox: VBoxContainer = $TextboxMargin/TextboxPanel/TextboxVbox

var dialogue_labels: Array[RichTextLabel]
var dialogues: Array

func _ready():
	pass
	dialogue_labels.append(dialogue_label) # append the first dialogue label (from Textbox) as we'll always have at least one.

func _process(delta: float):
	pass

func begin_display_response(text_to_display: Array) -> void:
	dialogues = text_to_display
	
	var l: int = 1 # start at one as one dialogue label already exists.
	while l < dialogues.size():
		var label_inst: RichTextLabel = label_scene.instantiate()
		textbox_vbox.add_child(spacer_scene.instantiate())
		textbox_vbox.add_child(label_inst)
		dialogue_labels.append(label_inst)
		l += 1
	
	# populate text for each RichTextLabel.
	for d in dialogue_labels.size():
		dialogue_labels[d].text = dialogues[d]
