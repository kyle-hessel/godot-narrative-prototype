extends RichTextEffect

var bbcode := "highlight_color"

# Gets TextServer for retrieving font information.
func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = char_fx.env.get("color")
	
	return true
