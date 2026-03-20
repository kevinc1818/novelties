extends Node
class_name RewardSystem

signal next_fight_requested

var player_gold: int = 0
var deck_manager: DeckManager
var rewards_panel: Panel
var gold_label: Label
var upgrade_panel: Panel
var upgrade_button: Button
var player: Player


func setup(
  p_deck_manager: DeckManager,
  p_rewards_panel: Panel,
  p_gold_label: Label,
  p_continue_button: Button,
  p_upgrade_panel: Panel,
  p_upgrade_button: Button,
  p_next_fight_button: Button,
  p_player: Player
):
  deck_manager = p_deck_manager
  rewards_panel = p_rewards_panel
  gold_label = p_gold_label
  upgrade_panel = p_upgrade_panel
  upgrade_button = p_upgrade_button
  player = p_player
  p_continue_button.pressed.connect(_on_continue_pressed)
  p_upgrade_button.pressed.connect(_on_upgrade_pressed)
  p_next_fight_button.pressed.connect(_on_next_fight_pressed)


func _on_enemy_defeated(gold_reward: int):
  player_gold += gold_reward
  gold_label.text = "Victory!\nYou found " + str(gold_reward) + " Gold.\nTotal Gold: " + str(player_gold)
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
