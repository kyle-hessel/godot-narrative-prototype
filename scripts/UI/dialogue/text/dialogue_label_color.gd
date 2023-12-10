extends RichTextEffect

var bbcode := "highlight_color"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color=char_fx.env.get("color")
	return true
