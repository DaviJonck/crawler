extends Node2D  # Ou o tipo correto do seu nó Main

@onready var end_turn_button = $EndTurnButton
@onready var deck = $Deck
@onready var souls_ui = $SoulsUI
@onready var card_slot = $CardSlot
@onready var battle_message = $BattleMessage
@onready var message_timer = $BattleMessage/Timer 

func _ready():
	# Configurações iniciais
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	SoulsManager.souls_updated.connect(_on_souls_updated)
	update_ui()

func _on_end_turn_button_pressed():
	# Desabilita botão durante a transição
	$EndTurnButton.disabled = true
	
	# 1. Adiciona +1 alma
	SoulsManager.add_souls(1)
	
	# 2. Compra +1 carta
	if $Deck.draw_card():
		print("Carta comprada com sucesso!")
	else:
		print("Deck vazio - não foi possível comprar carta")
	
	# 3. Mostra mensagem de luta
	show_battle_message()
	
	# 4. Atualiza UI
	$SoulsUI.update_souls_display(SoulsManager.current_souls)
	
	# 5. Reativa o botão após animações
	await get_tree().create_timer(1.0).timeout
	$EndTurnButton.disabled = false
	$Deck.reset_draw()

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
