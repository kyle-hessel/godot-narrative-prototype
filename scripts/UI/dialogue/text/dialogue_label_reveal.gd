extends RichTextEffect

class_name RichTextEffectReveal

var bbcode := "reveal"

var advance_letter: bool = false
var reveal_pos: int = 0

# Gets TextServer for retrieving font information.
func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	# example of how to only act on specific characters.
	#var char_int: int = get_text_server().font_get_char_from_glyph_index(char_fx.font, 1, char_fx.glyph_index)
	#if char_int == "a".unicode_at(0):
		#char_fx.visible = false
	
	# if the index of the current character is greater than the reveal position, keep it hidden.
	if char_fx.relative_index > reveal_pos:
		char_fx.visible = false
	
	# if advance_letter is true, increment the reveal_pos and then instantly disable advance_letter once more.
	if advance_letter:
		reveal_pos += 1
		advance_letter = false
	
	return true

# temporarily enable advance_letter from a signal trigger in textbox.gd.
func _on_letter_display_timer_timeout() -> void:
	advance_letter = true

# temporarily reset reveal_pos from a signal trigger in textbox.gd.
func _on_signal_show_entire_line() -> void:
	reveal_pos = 500 # a big number to overload the whole string.
