extends Node2D

const CARD_SCENE_PATH = "res://scenes/Card.tscn"
const DRAW_ANIMATION_DURATION = 0.5

# Carrega o enum do script da carta
var CARD_TYPE = preload("res://scripts/card.gd").CARD_TYPE

@export var deck_spawn_position = Vector2(150, 890) 

var card_database = {
	"Goblin": {
		"type": CARD_TYPE.ATK,
		"cost": 3,
		"effect": 5,
		"texture": "res://assets/cards/goblin.png"
	},
	"Esqueleto": {
		"type": CARD_TYPE.DEF,
		"cost": 4,
		"effect": 7,
		"texture": "res://assets/cards/esqueleto.png"
	},
	"Fantasma": {
		"type": CARD_TYPE.HP,
		"cost": 2,
		"effect": 10,
		"texture": "res://assets/cards/fantasma.png"
	}
}

var player_deck = [
	"Goblin", "Goblin", "Goblin", 
	"Esqueleto", "Esqueleto", 
	"Fantasma", "Fantasma"
]
var can_draw = false

@onready var deck_image = $DeckImage

func _ready():
	$Area2D/CollisionShape2D.disabled = true
	update_deck_counter()

func draw_card() -> bool:
	if player_deck.is_empty():
		return false
	
	var card_type = player_deck.pop_front()
	var new_card = preload(CARD_SCENE_PATH).instantiate()
	
	# Configura a carta com base no banco de dados
	configure_card(new_card, card_type)
	
	# Posiciona a carta na posição do deck
	new_card.position = deck_spawn_position
	new_card.z_index = 100
	
	get_parent().get_node("CardManager").add_child(new_card)
	
	# Animação para a mão do jogador
	animate_to_hand(new_card)
	
	update_deck_counter()
	return true

func configure_card(card, card_name):
	if card_database.has(card_name):
		var data = card_database[card_name]
		card.card_name = card_name
		card.card_type = data["type"]
		card.soul_cost = data["cost"]
		card.effect_value = data["effect"]
		
	
	card.setup_visuals()

func animate_to_hand(card):
	var target_pos = get_parent().get_node("PlayerHand").get_next_card_position()
	var tween = create_tween()
	
	tween.tween_property(card, "position", target_pos, DRAW_ANIMATION_DURATION)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(card, "z_index", 1, DRAW_ANIMATION_DURATION)
	
	tween.tween_callback(get_parent().get_node("PlayerHand").add_card_to_hand.bind(card, 0.1))

func update_deck_counter():
	$Counter.text = str(player_deck.size())
	if player_deck.is_empty():
		$DeckImage.visible = false
		$Counter.visible = false

func shuffle_deck():
	player_deck.shuffle()
