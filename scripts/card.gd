extends Node2D

signal hovered
signal hovered_off

var starting_position
var card_name = "Goblin"
var soul_cost = 1  # Custo padrão
var power = 1

func _ready():
	# Define custo baseado no tipo de carta
	if "Goblin" in name:
		soul_cost = 5
	elif "Esqueleto" in name:
		soul_cost = 4
	# Atualiza o label (se existir)
	if has_node("CostLabel"):
		$CostLabel.text = str(soul_cost)
	
	get_parent().connect_card_signals(self)
