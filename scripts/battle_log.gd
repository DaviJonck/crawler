extends RichTextLabel

func _ready():
	clear()

func add_message(message):
	push_color(Color.WHITE)
	add_text("• " + message + "\n")
	scroll_to_line(get_line_count() - 1)
