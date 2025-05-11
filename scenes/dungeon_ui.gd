extends Control

@onready var hp_label: Label = $VBoxContainer/HP
@onready var atk_label: Label = $VBoxContainer/ATK
@onready var def_label: Label = $VBoxContainer/DEF
@onready var level_label: Label = $VBoxContainer/LEVEL

var dungeon_stats = {
	"hp": 100,
	"max_hp": 100,
	"atk": 15,
	"def": 10,
	"level": 1
}

func _ready():
	update_display()

func update_display():
	if hp_label:
		hp_label.text = "HP: %d/%d" % [dungeon_stats.hp, dungeon_stats.max_hp]
	if atk_label:
		atk_label.text = "ATK: %d" % dungeon_stats.atk
	if def_label:
		def_label.text = "DEF: %d" % dungeon_stats.def
	if level_label:
		level_label.text = "Nível: %d" % dungeon_stats.level

func take_damage(amount):
	var actual_damage = max(1, amount - dungeon_stats.def / 2)
	dungeon_stats.hp = max(0, dungeon_stats.hp - actual_damage)
	update_display()
	show_damage_popup(actual_damage)
	return dungeon_stats.hp > 0

func show_damage_popup(damage_amount):
	if ResourceLoader.exists("res://scenes/DamageText.tscn"):
		var damage_text = preload("res://scenes/DamageText.tscn").instantiate()
		add_child(damage_text)
		damage_text.text = "-%d" % damage_amount
		damage_text.position = Vector2(50, 20)
