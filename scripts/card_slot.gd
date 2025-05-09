extends Node2D

var cards_in_slot = []  # Array para armazenar múltiplas cartas
const CARD_OFFSET = Vector2(0, -20)  # Pequeno deslocamento para empilhamento visual
var cards_played_this_turn = []  # Cartas jogadas no turno atual

func add_card(card):
	# Adiciona carta ao slot
	cards_in_slot.append(card)
	
	# Gasta almas IMEDIATAMENTE ao jogar
	if SoulsManager.spend_souls(card.soul_cost):
		print("Jogou carta. Almas gastas:", card.soul_cost)
	else:
		print("ERRO: Não foi possível gastar almas!")
	
	organize_cards()
	
	# Remove esta função se existir (não precisamos mais)
	# func get_total_spent_souls()
	
func remove_card(card):
	if card in cards_in_slot:
		cards_in_slot.erase(card)
		organize_cards()
	
func get_turn_soul_cost():
	var total = 0
	for card in cards_played_this_turn:
		total += card.soul_cost
	cards_played_this_turn = []  # Reseta para o próximo turno
	return total
	
func organize_cards():
	
	$CardSlotImage.visible = cards_in_slot.size() == 0

	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		var target_position = position + (CARD_OFFSET * i)
		
		var tween = create_tween()
		tween.tween_property(card, "position", target_position, 0.2)
		tween.parallel().tween_property(card, "rotation", deg_to_rad(randf_range(-5, 5)), 0.2)
		tween.parallel().tween_property(card, "scale", Vector2(1.0 - i*0.02, 1.0 - i*0.02), 0.2)
		
		card.z_index = i
	

		
func get_total_power():
	var total = 0
	for card in cards_in_slot:
		total += card.power  # Assumindo que cada carta tem uma propriedade 'power'
	return total
