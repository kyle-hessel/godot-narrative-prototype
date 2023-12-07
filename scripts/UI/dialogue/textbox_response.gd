extends Textbox

class_name TextboxResponse

var dialogue_labels: Array[RichTextLabel]

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_labels.append(dialogue_label) # append the first dialogue label (from Textbox) as we'll always have at least one.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass
