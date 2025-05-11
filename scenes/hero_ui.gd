extends Control

@onready var hp_label = $VBoxContainer/HP
@onready var atk_label = $VBoxContainer/ATK
@onready var def_label = $VBoxContainer/DEF
@onready var level_label = $VBoxContainer/LEVEL

var hero_stats = {
	"hp": 50,
	"max_hp": 50,
	"atk": 10,
	"def": 5,
	"level": 1
}

func _ready():
	update_display()

func update_display():
	hp_label.text = "HP: %d/%d" % [hero_stats.hp, hero_stats.max_hp]
	atk_label.text = "ATK: %d" % hero_stats.atk
	def_label.text = "DEF: %d" % hero_stats.def
	level_label.text = "Nível: %d" % hero_stats.level

func take_damage(amount):
	var actual_damage = max(1, amount - hero_stats.def / 2)
	hero_stats.hp = max(0, hero_stats.hp - actual_damage)
	update_display()
	return hero_stats.hp > 0

func level_up():
	hero_stats.level += 1
	hero_stats.max_hp += 15
	hero_stats.hp = hero_stats.max_hp
	hero_stats.atk += 3
	hero_stats.def += 2
	update_display()

func reset_hero():
	hero_stats = {
		"hp": 50 + (hero_stats.level-1)*15,
		"max_hp": 50 + (hero_stats.level-1)*15,
		"atk": 10 + (hero_stats.level-1)*3,
		"def": 5 + (hero_stats.level-1)*2,
		"level": hero_stats.level
	}
	update_display()
