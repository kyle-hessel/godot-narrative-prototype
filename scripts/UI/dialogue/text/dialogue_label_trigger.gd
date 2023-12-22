extends RichTextEffect

class_name RichTextEffectTrigger

var bbcode := "trig"

var display_once: bool = true

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if display_once:
		display_once = false
		GameManager.ui_manager.dialogue_manager.dialogue_trigger.emit()
		return true
	else:
		return false
