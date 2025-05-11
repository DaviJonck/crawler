extends Node2D

@onready var label = $TextLabel

func show_message(text: String, color: Color):
	label.text = text
	label.modulate = color
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.8)
	tween.tween_callback(queue_free)
