extends Resource

class_name Event

@export var event_name: String

# An array of actions meant to be excuted in sequental order.
# Each action will likely be a String key (probably a character name)
# .. tied to an Animation value, a Dictionary value, or just about
# .. anything that is needed for an Event to occur.
@export var actions: Array[Dictionary]
