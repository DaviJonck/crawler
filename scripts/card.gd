extends Node2D

signal hovered
signal hovered_off

enum CARD_TYPE {ATK, DEF, HP}

var starting_position
var card_name = "Goblin"
var soul_cost = 1
var power = 1
var card_type = CARD_TYPE.ATK
var effect_value = 5
var dynamic_values = {}

@onready var card_image = $CardImage
@onready var cost_label = $CostLabel
@onready var description_label = $DescriptionLabel
@onready var area_2d = $Area2D

func _ready():
	initialize_card()
	setup_visuals()
	if get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)

func initialize_card():
	match card_name:
		"Goblin":
			soul_cost = 3
			card_type = CARD_TYPE.ATK
			effect_value = 5
		"Esqueleto":
			soul_cost = 4
			card_type = CARD_TYPE.DEF
			effect_value = 7
		"Fantasma":
			soul_cost = 2
			card_type = CARD_TYPE.HP
			effect_value = 10
	
	if dynamic_values:
		apply_dynamic_values()

func apply_dynamic_values():
	for property in dynamic_values:
		if property in self:
			set(property, dynamic_values[property])

func setup_visuals():
	var texture_path = "res://assets/cards/%s.png" % card_name.to_lower()
	if card_image and ResourceLoader.exists(texture_path):
		card_image.texture = load(texture_path)
	update_labels()

func update_labels():
	if cost_label:
		cost_label.text = str(soul_cost)
	if description_label:
		description_label.text = get_description()

func get_description():
	var desc = ""
	match card_type:
		CARD_TYPE.ATK:
			desc = "ATK +%d" % effect_value
		CARD_TYPE.DEF:
			desc = "DEF +%d" % effect_value
		CARD_TYPE.HP:
			desc = "HP +%d" % effect_value
	
	if dynamic_values.has("bonus_effect"):
		desc += "\n+" + str(dynamic_values.bonus_effect)
	return desc

func apply_effect(dungeon_stats):
	var modified_stats = dungeon_stats.duplicate()
	
	match card_type:
		CARD_TYPE.ATK:
			modified_stats.atk += effect_value
		CARD_TYPE.DEF:
			modified_stats.def += effect_value
		CARD_TYPE.HP:
			modified_stats.hp = min(modified_stats.hp + effect_value, modified_stats.max_hp)
	

	
	return modified_stats

func remove_effect(dungeon_stats):
	var new_stats = dungeon_stats.duplicate()
	
	match card_type:
		CARD_TYPE.ATK:
			new_stats.atk -= effect_value
		CARD_TYPE.DEF:
			new_stats.def -= effect_value
		CARD_TYPE.HP:
			new_stats.hp = max(new_stats.hp - effect_value, 1)
	
	if dynamic_values.has("special_effect"):
		match dynamic_values.special_effect:
			"double_atk":
				new_stats.atk /= 2
			"heal_10":
				new_stats.hp = max(new_stats.hp - 10, 1)
			"temporary_def":
				new_stats.def -= 5
	
	return new_stats

func highlight(enable):
	var tween = create_tween()
	if enable:
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _on_area_2d_mouse_entered():
	# Só reage se a área estiver ativa
	if $Area2D.input_pickable:
		emit_signal("hovered", self)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_area_2d_mouse_exited():
	if $Area2D.input_pickable:
		emit_signal("hovered_off", self)
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
