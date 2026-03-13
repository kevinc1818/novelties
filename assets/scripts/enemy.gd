extends Control
class_name Enemy

signal enemy_defeated(gold_reward: int)
@onready var health_bar = $HealthBar

var max_hp: int = 20
var current_hp: int = 20
var gold_to_drop: int = 15

func _ready():
	# Set up the health bar when the enemy spawns
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func take_damage(amount: int):
	current_hp -= amount
	health_bar.value = current_hp
	
	print("Enemy took ", amount, " damage! HP is now: ", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Enemy Defeated!")
	enemy_defeated.emit(gold_to_drop)
	queue_free()
