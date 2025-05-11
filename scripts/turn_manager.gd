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
	# Heróis atacam a dungeon
	simulate_hero_attack()

# turn_manager.gd
func simulate_hero_attack():
	var dungeon_ui = get_node("../DungeonUI")
	if !dungeon_ui.has_method("take_damage"):
		push_error("DungeonUI não possui método take_damage()")
		return
	
	var hero_attack_power = randi_range(5, 15)
	var final_damage = max(1, hero_attack_power - dungeon_ui.dungeon_stats.def / 2)
	
	var dungeon_survived = dungeon_ui.take_damage(final_damage)
	if not dungeon_survived:
		game_over()
		
func show_damage_feedback(damage):
	if not ResourceLoader.exists("res://scenes/DamageText.tscn"):
		push_warning("DamageText scene not found!")
		return
	
	var damage_text = load("res://scenes/DamageText.tscn").instantiate()
	add_child(damage_text)
	damage_text.text = "-%d HP" % damage
	damage_text.get_node("Text").modulate = Color(1, 0, 0)
	damage_text.global_position = $"../DungeonUI".global_position + Vector2(50, -20)

func game_over():
	print("Game Over!")
	# Implementar lógica de game over
