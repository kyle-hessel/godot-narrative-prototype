extends RichTextEffect

class_name RichTextEffectEnd

var bbcode := "end"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	return true
