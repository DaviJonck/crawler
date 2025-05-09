extends Node2D

const HAND_Y_POSITION = 890
const DEFAULT_CARD_MOVEMENT_SPEED = 0.1

var player_hand = []
var center_screen_x
var card_width = 200

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2

func get_next_card_position() -> Vector2:
	var x_pos = calculate_card_position(player_hand.size())
	return Vector2(x_pos, HAND_Y_POSITION)


func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		set_card_width()
		# Define a posição inicial ANTES de animar
		card.starting_position = calculate_card_position(0)  # Sempre posição 0 para novas cartas
		update_hand_position(speed)
		
		var cost_label = card.get_node_or_null("CostLabel")
		if cost_label:
			cost_label.text = str(card.soul_cost)

func set_card_width():
	card_width = max(250 - (player_hand.size() * 10), 100)

func update_hand_position(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.starting_position = new_position  # Atualiza a posição de referência
		animated_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * card_width
	var x_offset = center_screen_x + index * card_width - total_width / 2
	return x_offset
	
func animated_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position(DEFAULT_CARD_MOVEMENT_SPEED)
