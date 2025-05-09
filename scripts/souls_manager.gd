extends Node

signal souls_updated(new_amount)  # Certifique-se que este sinal existe
const MAX_SOULS = 10

var current_souls = 3
var souls_per_turn = 1

func new_turn():
	print("Adicionando almas do novo turno...")  # Debug
	add_souls(souls_per_turn)

func add_souls(amount):
	current_souls = min(current_souls + amount, MAX_SOULS)
	souls_updated.emit(current_souls)
	print("+", amount, " alma(s). Total:", current_souls)

func spend_souls(amount):
	if can_afford(amount):
		current_souls -= amount
		souls_updated.emit(current_souls)
		print("-", amount, " alma(s). Total:", current_souls)
		return true
	return false

func can_afford(amount):
	return current_souls >= amount
