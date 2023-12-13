extends Resource

class_name Event

@export var event_name: String

# An dictionary of actions meant to be excuted in sequental order.
# Each action will likely be a String key (probably a character name)
# .. tied to an Animation value, a Dictionary value, or just about
# .. anything that is needed for an Event to occur.
# Even callables can be stored using this constructor:
# .. Callable Callable ( Object object, StringName method )
# It may make sense for the Dictionary's value entry (when using callables)
# .. to be an array of strings, with pos 0 being the function name,
# .. and any pos after that being function arguments in order.
# Callable's bindv function may also be useful here.
@export var actions: Dictionary
