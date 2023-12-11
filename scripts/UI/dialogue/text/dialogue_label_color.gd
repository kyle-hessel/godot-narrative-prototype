extends RichTextEffect

var bbcode := "highlight_color"

# Gets TextServer for retrieving font information.
func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color=char_fx.env.get("color")
	var char_int: int = get_text_server().font_get_char_from_glyph_index(char_fx.font, 1, char_fx.glyph_index)
	if char_int == "a".unicode_at(0):
		char_fx.visible = false
	return true
