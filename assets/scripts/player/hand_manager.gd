extends Node
class_name HandManager

signal word_submitted(tiles: Array[LetterTile], damage: int)
signal invalid_word

var deck_manager: DeckManager
var hand_area: HBoxContainer
var spelling_area: HBoxContainer
var tile_scene: PackedScene


func setup(
  p_deck_manager: DeckManager,
  p_hand_area: HBoxContainer,
  p_spelling_area: HBoxContainer,
  p_tile_scene: PackedScene,
):
  deck_manager = p_deck_manager
  hand_area = p_hand_area
  spelling_area = p_spelling_area
  tile_scene = p_tile_scene


func refill_hand():
  var tiles_needed = 10 - hand_area.get_child_count()
  for i in range(tiles_needed):
    var new_letter = deck_manager.draw_letter()
    if new_letter != "":
      _spawn_tile(new_letter, deck_manager.letter_values[new_letter])


func try_submit():
  var total_damage = 0
  var played_word = ""
  var tiles: Array[LetterTile] = []

  for child in spelling_area.get_children():
    if child is LetterTile:
      total_damage += child.point_value
      played_word += child.letter
      tiles.append(child)
      child.disabled = true

  if total_damage > 0 and WordDictionary.is_valid(played_word):
    word_submitted.emit(tiles, total_damage)
  elif total_damage > 0:
    invalid_word.emit()
    for tile in tiles:
      tile.disabled = false


func _spawn_tile(letter: String, value: int):
  var new_tile = tile_scene.instantiate() as LetterTile
  hand_area.add_child(new_tile)
  new_tile.setup(letter, value)
  new_tile.tile_clicked.connect(_on_tile_clicked)


func _on_tile_clicked(tile: LetterTile):
  if tile.is_in_hand:
    tile.reparent(spelling_area)
    tile.is_in_hand = false
  else:
    tile.reparent(hand_area)
    tile.is_in_hand = true
