extends Node2D

const COLLISION_MASK_CARD = 1 
const COLLISION_MASK_CARD_SLOT = 2
const DEFAULT_CARD_MOVEMENT_SPEED = 0.1
const SHAKE_DURATION = 0.3
const SHAKE_STRENGTH = 15.0
const RETURN_DURATION = 0.2

var card_being_dragged
var screen_size
var is_hovering_on_card
var player_hand_reference
var souls_manager
var active_message = null  # Variável para controlar a mensagem ativa

func _ready():
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".connect("left_mouse_button_released", _on_left_click_released)

func start_drag(card):
	if card.get_node("Area2D").input_pickable:
		card_being_dragged = card
		card.z_index = 100
		
func finish_drag():
	if !card_being_dragged:
		return
	
	var card_slot_found = raycast_check_for_card_slot()
	
	if card_slot_found:
		handle_card_placement(card_slot_found)
	else:
		return_card_to_hand(card_being_dragged)
	
	card_being_dragged = null

func handle_card_placement(slot):
	if SoulsManager.can_afford(card_being_dragged.soul_cost):
		if SoulsManager.spend_souls(card_being_dragged.soul_cost):
			move_card_to_slot(card_being_dragged, slot)
		else:
			show_insufficient_souls_feedback(card_being_dragged)
	else:
		show_insufficient_souls_feedback(card_being_dragged)

func move_card_to_slot(card, slot):
	var tween = create_tween()
	tween.tween_property(card, "position", slot.position, 0.2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(card, "rotation", 0, 0.2)
	tween.tween_callback(slot.add_card.bind(card))
	tween.tween_callback(player_hand_reference.remove_card_from_hand.bind(card))

func show_insufficient_souls_feedback(card):
	# Remove a mensagem anterior se existir
	if is_instance_valid(active_message) and active_message:
		active_message.queue_free()
	
	# Efeito de shake
	var shake_tween = create_tween()
	var start_pos = card.position
	for i in range(3):
		shake_tween.tween_property(card, "position", 
			start_pos + Vector2(randf_range(-SHAKE_STRENGTH, SHAKE_STRENGTH), 
							  randf_range(-SHAKE_STRENGTH/2, SHAKE_STRENGTH/2)), 
			SHAKE_DURATION/6)
	
	shake_tween.tween_property(card, "position", start_pos, SHAKE_DURATION/6)
	
	# Efeito de cor vermelha
	var sprite = card.get_node("CardImage")
	var original_modulate = sprite.modulate
	var color_tween = create_tween()
	color_tween.tween_property(sprite, "modulate", Color.RED, SHAKE_DURATION/2)
	color_tween.tween_property(sprite, "modulate", original_modulate, SHAKE_DURATION/2)
	
	# Retorna à mão
	await shake_tween.finished
	return_card_to_hand(card)
	
	# Mostra mensagem na UI
	show_souls_message("Almas insuficientes!", Color.RED)

func return_card_to_hand(card):
	var tween = create_tween()
	tween.tween_property(card, "position", card.starting_position, RETURN_DURATION)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card, "rotation", 0, RETURN_DURATION)
	tween.tween_callback(card.set.bind("z_index", 1))

func show_souls_message(text, color):
	# Remove mensagem anterior se existir
	if is_instance_valid(active_message) and active_message:
		active_message.queue_free()
	
	active_message = preload("res://scenes/souls_message.tscn").instantiate()
	add_child(active_message)
	active_message.show_message(text, color)
	
	# Timer seguro usando SceneTree
	var timer = get_tree().create_timer(1.5)
	await timer.timeout
	
	if is_instance_valid(active_message) and active_message:
		active_message.queue_free()
		active_message = null


func shake_card(card):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position:x", card.position.x + 10, 0.1)
	tween.tween_property(card, "position:x", card.position.x - 10, 0.1)
	tween.tween_property(card, "position:x", card.position.x, 0.1)
	
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
		var card = get_card_with_hightest_z_index(result)
		# Verifica se a carta já está em um slot
		if card and card.get_node("Area2D").input_pickable:
			return card
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

	
