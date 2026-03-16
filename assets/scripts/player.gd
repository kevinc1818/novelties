extends Control
class_name Player

@onready var health_bar = $HealthBar

var max_hp: int = 50
var current_hp: int = 50

func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func take_damage(amount: int):
	current_hp -= amount
	health_bar.value = current_hp
	
	print("Player took ", amount, " damage! HP is now: ", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Game Over! The player has been defeated.")
	# Later, we can make this pull up a "Game Over" screen!
