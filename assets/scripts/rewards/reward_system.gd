extends Node
class_name RewardSystem

signal next_fight_requested

@export var deck_manager: DeckManager
@export var rewards_panel: Panel
@export var gold_label: Label
@export var continue_button: Button
@export var upgrade_panel: Panel
@export var upgrade_button: Button
@export var next_fight_button: Button
@export var player: Player

var player_gold: int = 0


func _ready():
  continue_button.pressed.connect(_on_continue_pressed)
  upgrade_button.pressed.connect(_on_upgrade_pressed)
  next_fight_button.pressed.connect(_on_next_fight_pressed)


func _on_enemy_defeated(gold_reward: int):
  player_gold += gold_reward
  gold_label.text = (
    "Victory!\nYou found " + str(gold_reward) + " Gold.\nTotal Gold: " + str(player_gold)
  )
  rewards_panel.show()
  player.hide()


func _on_continue_pressed():
  rewards_panel.hide()
  upgrade_panel.show()


func _on_upgrade_pressed():
  if player_gold >= 10:
    player_gold -= 10
    deck_manager.upgrade_random_letter()
    upgrade_button.disabled = true
  else:
    print("Not enough gold!")


func _on_next_fight_pressed():
  upgrade_panel.hide()
  upgrade_button.disabled = false
  player.show()
  next_fight_requested.emit()
