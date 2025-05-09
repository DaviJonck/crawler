extends Node2D

const COLLISION_MASK_CARD = 1 
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVEMENT_SPEED = 0.1

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var souls_manager

func _ready():
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", _on_left_click_released)

func start_drag(card):
	card_being_dragged = card
	card.z_index = 100  # Garante que a carta arrastada fique por cima

func finish_drag():
	if card_being_dragged:
		var card_slot_found = raycast_check_for_card_slot()
		
		if card_slot_found and SoulsManager.can_afford(card_being_dragged.soul_cost):
			# Carta solta no slot válido
			if SoulsManager.spend_souls(card_being_dragged.soul_cost):
				player_hand_reference.remove_card_from_hand(card_being_dragged)
				card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
				card_slot_found.add_card(card_being_dragged)
		else:
			# Retorna a carta para sua posição inicial
			var tween = get_tree().create_tween()
			tween.tween_property(card_being_dragged, "position", 
							   card_being_dragged.starting_position,
							   DEFAULT_CARD_MOVEMENT_SPEED)
			tween.tween_callback(card_being_dragged.set.bind("z_index", 1))
		
		card_being_dragged = null
func _on_left_click_released():
	finish_drag()

# Resto das funções auxiliares permanecem iguais...

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0 , screen_size.x), clamp(mouse_pos.y,0, screen_size.y))


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)
	
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
	
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		# check if hovered off card stright on to another card
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false
	
func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index= 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index= 1
	
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		#return 	result[0].collider.get_parent()
		return get_card_with_hightest_z_index(result)
	return null
	
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
	
func get_card_with_hightest_z_index(cards):
	# Assume the first card in cards arrays has the highest z index
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index 
	
	# Loop throught the rest of the cards checking for a gihter z index
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index 
	return highest_z_card
	
func on_left_click_released():
	if card_being_dragged:
		finish_drag()

	
