extends Control

@onready var souls_label = $SoulsLabel

func _ready():
	# Conexão segura com o sinal
	if SoulsManager:
		SoulsManager.souls_updated.connect(update_souls_display)
		# Atualiza com valor inicial
		update_souls_display(SoulsManager.current_souls)
	else:
		printerr("SoulsManager não encontrado!")

func update_souls_display(amount):
	print("Atualizando UI para:", amount)  # Debug
	if souls_label:
		souls_label.text = "Almas: %d" % amount
	else:
		printerr("SoulsLabel não encontrado!")
