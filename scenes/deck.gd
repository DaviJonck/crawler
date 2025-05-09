extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const DRAW_ANIMATION_DURATION = 0.5

var player_deck = ["Goblin", "Goblin", "Goblin"]  # Exemplo com 3 cartas iniciais
var can_draw = true

func _ready():
	update_deck_counter()

func draw_card() -> bool:
	if !can_draw || player_deck.is_empty():
		return false
	
	can_draw = false
	var card_type = player_deck.pop_front()
	
	var new_card = preload(CARD_SCENE_PATH).instantiate()
	new_card.card_name = card_type
	new_card.position = $DeckImage.position  # Começa na posição do deck
	
	get_parent().get_node("CardManager").add_child(new_card)
	
	# Animação de compra
	var target_pos = get_parent().get_node("PlayerHand").get_next_card_position()
	var tween = create_tween()
	tween.tween_property(new_card, "position", target_pos, DRAW_ANIMATION_DURATION)
	tween.tween_callback(get_parent().get_node("PlayerHand").add_card_to_hand.bind(new_card, DRAW_ANIMATION_DURATION))
	
	update_deck_counter()
	return true

func update_deck_counter():
	$Counter.text = str(player_deck.size())
	if player_deck.is_empty():
		$Area2D/CollisionShape2D.disabled = true
		$DeckImage.visible = false
		$Counter.visible = false

func reset_draw():
	can_draw = true
