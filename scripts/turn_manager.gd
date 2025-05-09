extends Node

func _ready():
	start_new_turn()

func start_new_turn():
	# Habilita compra de carta
	$"../Deck".can_draw = true
	# Adiciona 1 alma
	$"../SoulsManager".new_turn()
	# Compra 1 carta
	$"../Deck".draw_card()
