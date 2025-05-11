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
	
	# Animação mais dramática para dano
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 0.7)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.7)
	tween.parallel().tween_property(self, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.4)
