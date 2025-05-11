extends Node2D

@export var text: String = "":
	set(value):
		text = value
		if has_node("Text"):
			$Text.text = value

func _ready():
	$Lifetime.wait_time = 0.8
	$Lifetime.timeout.connect(queue_free)
	$Lifetime.start()
	
	# Animação de flutuação
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 30, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.5)
