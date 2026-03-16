extends Node

@export var tile_scene: PackedScene  # Drag your Tile.tscn into this slot in the Inspector
@export var enemy_scene: PackedScene

@onready var spelling_area = $VBoxContainer/SpellingArea
@onready var hand_area = $VBoxContainer/HandArea

@onready var submit_button = $VBoxContainer/SubmitButton
@onready var enemy = $Enemy
@onready var player = $Player

var player_gold: int = 0

@onready var rewards_panel = $RewardsPanel
@onready var gold_label = $RewardsPanel/GoldLabel
@onready var continue_button = $RewardsPanel/ContinueButton

@onready var upgrade_panel = $UpgradePanel
@onready var upgrade_button = $UpgradePanel/UpgradeButton
@onready var next_fight_button = $UpgradePanel/NextFightButton

# The Deck System
var draw_pile: Array[String] = []
var discard_pile: Array[String] = []

# A dictionary to easily look up how much a letter is worth
var letter_values: Dictionary = {
  "A": 1,
  "B": 3,
  "C": 3,
  "D": 2,
  "E": 1,
  "F": 4,
  "G": 2,
  "H": 4,
  "I": 1,
  "J": 8,
  "K": 5,
  "L": 1,
  "M": 3,
  "N": 1,
  "O": 1,
  "P": 3,
  "Q": 10,
  "R": 1,
  "S": 1,
  "T": 1,
  "U": 1,
  "V": 4,
  "W": 4,
  "X": 8,
  "Y": 4,
  "Z": 10
}


func _ready():
  submit_button.pressed.connect(_on_submit_pressed)
  # Connect the UI buttons
  continue_button.pressed.connect(_on_continue_pressed)
  upgrade_button.pressed.connect(_on_upgrade_pressed)
  next_fight_button.pressed.connect(_on_next_fight_pressed)
  # Connect the enemy death signal
  if enemy:  # Make sure the enemy exists before connecting
    enemy.enemy_defeated.connect(_on_enemy_defeated)
    # Randomize Godot's internal seed so the shuffles are different every game
  randomize()
  setup_deck()
  refill_hand()


func setup_deck():
  # Let's give the player a starting deck of 15 basic letters
  var starting_letters: Array[String] = ["A", "A", "E", "E", "I", "O", "R", "R", "S", "S", "T", "T", "L", "N", "P"]

  draw_pile = starting_letters.duplicate()
  draw_pile.shuffle()  # Shuffle the deck!


func spawn_tile_to_hand(letter: String, value: int):
  # 1. Create the tile
  var new_tile = tile_scene.instantiate() as LetterTile

  # 2. Add it to the hand container
  hand_area.add_child(new_tile)

  # 3. Set its data
  new_tile.setup(letter, value)

  # 4. Listen for when it gets clicked
  new_tile.tile_clicked.connect(_on_tile_clicked)


func _on_tile_clicked(tile: LetterTile):
  # Godot 4 makes reparenting incredibly easy!
  if tile.is_in_hand:
    # Move to spelling area
    tile.reparent(spelling_area)
    tile.is_in_hand = false

    # Move back to hand
  else:
    # Move back to hand
    tile.reparent(hand_area)
    tile.is_in_hand = true


func _on_submit_pressed():
  var total_damage = 0
  var played_word = ""

  # 1. Loop through all the tiles currently in the spelling area
  for child in spelling_area.get_children():
    if child is LetterTile:
      total_damage += child.point_value
      played_word += child.letter

      # Add the letter to the discard pile before destroying the visual tile!
      discard_pile.append(child.letter)
      child.queue_free()

      # 3. Check if they actually played anything

      # Optional: Draw new tiles to replace the ones you just used
  if total_damage > 0:
    print("You played: ", played_word, " for ", total_damage, " damage!")
    enemy.take_damage(total_damage)

    # Optional: Draw new tiles to replace the ones you just used
    refill_hand()
    if is_instance_valid(enemy) and enemy.current_hp > 0:
      execute_enemy_turn()


func refill_hand():
  # Simple logic to get back to 5 tiles.
  # Later, you can draw randomly from a "Deck" array!
  var tiles_needed = 5 - hand_area.get_child_count()
  for i in range(tiles_needed):
    var new_letter = draw_letter()

    # Make sure we actually drew a letter (in case the deck was completely empty)
    if new_letter != "":
      # Look up the correct point value from our dictionary
      var value = letter_values[new_letter]
      spawn_tile_to_hand(new_letter, value)


func draw_letter() -> String:
  # 1. Check if the draw pile is empty
  if draw_pile.is_empty():
    # If discard is ALSO empty, we have no tiles left to draw!
    if discard_pile.is_empty():
      print("Deck and Discard are completely empty!")
      return ""

      # 2. Pop the last letter off the array and return it
    print("Shuffling discard pile into draw pile...")
    draw_pile = discard_pile.duplicate()
    discard_pile.clear()
    draw_pile.shuffle()

    # 2. Pop the last letter off the array and return it
  return draw_pile.pop_back()


func _on_enemy_defeated(gold_reward: int):
  # 1. Give the player money
  player_gold += gold_reward
  print("Enemy Defeated! Total Gold: ", player_gold)

  # 2. Update the UI text
  gold_label.text = "Victory!\nYou found " + str(gold_reward) + " Gold.\nTotal Gold: " + str(player_gold)

  # 3. Show the rewards screen
  rewards_panel.show()


func _on_continue_pressed():
  # Hide rewards, show upgrade screen
  rewards_panel.hide()
  upgrade_panel.show()


func _on_upgrade_pressed():
  if player_gold >= 10:
    player_gold -= 10

    # Pick a random letter from the current draw pile to upgrade
    var random_index = randi() % draw_pile.size()
    var letter_to_upgrade = draw_pile[random_index]

    # Increase its global value in our dictionary by 1
    letter_values[letter_to_upgrade] += 1

    print("Upgraded ", letter_to_upgrade, "! It is now worth ", letter_values[letter_to_upgrade], " points.")
    print("Gold remaining: ", player_gold)

    # Disable the button so they only upgrade once per shop
    upgrade_button.disabled = true
  else:
    print("Not enough gold!")


func _on_next_fight_pressed():
  # Hide the UI
  upgrade_panel.hide()
  upgrade_button.disabled = false

  print("Starting next encounter...")

  var new_enemy = enemy_scene.instantiate() as Enemy

  add_child(new_enemy)
  enemy = new_enemy
  enemy.enemy_defeated.connect(_on_enemy_defeated)
  enemy.position = Vector2(-50, -200)

  refill_hand()


func execute_enemy_turn():
  # For now, the enemy just hits for a flat 5 damage every turn
  var enemy_damage = 5
  print("Enemy attacks you for ", enemy_damage, " damage!")

  player.take_damage(enemy_damage)
