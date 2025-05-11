extends Node2D  # Ou o tipo correto do seu nó Main

@onready var end_turn_button = $EndTurnButton
@onready var deck = $Deck
@onready var souls_ui = $SoulsUI
@onready var card_slot = $CardSlot
@onready var battle_message = $BattleMessage
@onready var message_timer = $BattleMessage/Timer 
@onready var dungeon_ui = $DungeonUI

func _ready():
	# Configurações iniciais
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	SoulsManager.souls_updated.connect(_on_souls_updated)
	update_ui()

func _on_end_turn_button_pressed():
	# Desabilita o botão
	$EndTurnButton.disabled = true
	
	# 1. Adiciona +1 alma (NÃO gasta mais almas aqui)
	SoulsManager.add_souls(1)
	
	# 2. Compra nova carta
	$Deck.draw_card()
	
	# 3. Mostra mensagem e atualiza UI
	show_battle_message()
	$SoulsUI.update_souls_display(SoulsManager.current_souls)
	
	# 4. Reativa o botão
	await get_tree().create_timer(1.0).timeout
	$EndTurnButton.disabled = false
func show_battle_message():
	battle_message.visible = true
	battle_message.modulate.a = 1.0  # Garante visível
	
	# Animação de fade in/out
	var tween = create_tween()
	tween.tween_property(battle_message, "modulate:a", 1.0, 0.5)  # Aparece
	tween.tween_interval(1.0)  # Mantém visível por 1 segundo
	tween.tween_property(battle_message, "modulate:a", 0.0, 0.5)  # Some
	tween.tween_callback(battle_message.hide)  # Esconde completamente
	
func _on_souls_updated(new_amount):
	souls_ui.update_souls_display(new_amount)

func update_ui():
	souls_ui.update_souls_display(SoulsManager.current_souls)
	
func _on_enemy_defeated():
	dungeon_ui.level_up()
