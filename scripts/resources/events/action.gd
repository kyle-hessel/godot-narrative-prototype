extends Resource

class_name Action

# key is for the action itself, e.g. an Animation, and  the value
# .. is for any additional information to pass in to be used with the action.
# I'm using a Dictionary for high flexibility even if it's a bit less efficient.
@export var action: Dictionary = {}
