extends Node2D

var cards_in_slot = []
const CARD_OFFSET = Vector2(0, -20)
var dungeon_ui
var is_locked = false
var cards_played_this_turn = []

@onready var slot_area = $Area2D

func _ready():
	dungeon_ui = get_node("/root/Main/DungeonUI")

func add_card(card):
	# Desativa completamente a interação com a carta
	card.get_node("Area2D").input_pickable = false
	card.get_node("Area2D").monitoring = false
	card.get_node("Area2D").monitorable = false
	
	cards_in_slot.append(card)
	
	# Aplica o efeito na dungeon
	var new_stats = card.apply_effect(dungeon_ui.dungeon_stats)
	dungeon_ui.dungeon_stats = new_stats
	dungeon_ui.update_display()
	
	organize_cards()

func organize_cards():
	$CardSlotImage.visible = cards_in_slot.size() == 0

	for i in range(cards_in_slot.size()):
		var card = cards_in_slot[i]
		var target_position = position + (CARD_OFFSET * i)
		
		var tween = create_tween()
		tween.tween_property(card, "position", target_position, 0.2)
		tween.parallel().tween_property(card, "rotation", deg_to_rad(randf_range(-5, 5)), 0.2)
		tween.parallel().tween_property(card, "scale", Vector2(1.0 - i*0.02, 1.0 - i*0.02), 0.2)
		tween.parallel().tween_property(card, "z_index", i, 0.2)


func show_card_effect_feedback(card):
	if not ResourceLoader.exists("res://scenes/EffectText.tscn"):
		push_warning("EffectText scene not found!")
		return
	
	var effect_text = load("res://scenes/EffectText.tscn").instantiate()
	add_child(effect_text)
	
	match card.card_type:
		card.CARD_TYPE.ATK:
			effect_text.text = "+%d ATK" % card.effect_value
			effect_text.get_node("Text").modulate = Color(1, 0.2, 0.2)
		card.CARD_TYPE.DEF:
			effect_text.text = "+%d DEF" % card.effect_value
			effect_text.get_node("Text").modulate = Color(0.2, 0.2, 1)
		card.CARD_TYPE.HP:
			effect_text.text = "+%d HP" % card.effect_value
			effect_text.get_node("Text").modulate = Color(0.2, 1, 0.2)
	
	effect_text.global_position = card.global_position + Vector2(0, -50)

func lock_slot():
	is_locked = true
	for card in cards_in_slot:
		card.highlight(false)

func unlock_slot():
	is_locked = false

func get_cards_played_this_turn():
	var cards = cards_played_this_turn.duplicate()
	cards_played_this_turn.clear()
	return cards

func get_total_power():
	var total = 0
	for card in cards_in_slot:
		total += card.power
	return total
