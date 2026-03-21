extends Node
class_name HandManager

signal word_submitted(tiles: Array[LetterTile], damage: int)
signal invalid_word

@export var deck_manager: DeckManager
@export var hand_area: HBoxContainer
@export var spelling_area: HBoxContainer
@export var submit_button: Button
@export var tile_scene: PackedScene

var input_locked: bool = false
var _peek_letter: String = ""
var _peek_index: int = 0
var _peek_tile: LetterTile = null
var _peek_tile_original_pos: Vector2 = Vector2.ZERO
var _peek_tween: Tween = null


func _ready():
  update_submit_indicator()


func set_input_locked(locked: bool):
  input_locked = locked
  if locked:
    submit_button.disabled = true
  else:
    update_submit_indicator()


func refill_hand():
  var tiles_needed = 10 - hand_area.get_child_count()
  for i in range(tiles_needed):
    var new_letter = deck_manager.draw_to_hand()
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
    deck_manager.submit_in_play()
    word_submitted.emit(tiles, total_damage)
  elif total_damage > 0:
    invalid_word.emit()
    for tile in tiles:
      tile.disabled = false


func _unhandled_input(event: InputEvent):
  if input_locked:
    return

  if not event is InputEventKey:
    return

  if event.pressed and not event.echo:
    var keycode = event.keycode

    if keycode == KEY_BACKSPACE:
      _handle_backspace()
      return

    if keycode == KEY_ENTER or keycode == KEY_KP_ENTER:
      if not submit_button.disabled:
        try_submit()
      return

    if keycode >= KEY_A and keycode <= KEY_Z:
      var letter = char(keycode)
      if event.shift_pressed:
        _handle_peek(letter)
      else:
        _handle_type(letter)

  elif not event.pressed:
    if event.keycode == KEY_SHIFT and _peek_tile != null:
      _commit_peek()


func _handle_type(letter: String):
  var tile = _find_leftmost_hand_tile(letter)
  if tile == null:
    return
  tile.reparent(spelling_area)
  tile.is_in_hand = false
  deck_manager.play_from_hand(tile.letter)
  update_submit_indicator()


func _handle_peek(letter: String):
  if _peek_tile != null and _peek_letter != letter:
    _cancel_peek()

  var candidates = _get_hand_tiles_for_letter(letter)
  if candidates.is_empty():
    return

  if _peek_letter == letter:
    _peek_index = (_peek_index + 1) % candidates.size()
    _snap_tile_back(_peek_tile)
  else:
    _peek_letter = letter
    _peek_index = 0

  _peek_tile = candidates[_peek_index]
  _tween_tile_up(_peek_tile)


func _handle_backspace():
  if _peek_tile != null:
    _cancel_peek()
    return

  var children = spelling_area.get_children()
  if children.is_empty():
    return
  var last_tile = children[-1] as LetterTile
  if last_tile == null:
    return
  last_tile.reparent(hand_area)
  last_tile.is_in_hand = true
  deck_manager.recall_to_hand(last_tile.letter)
  update_submit_indicator()


func _commit_peek():
  if _peek_tween != null:
    _peek_tween.kill()
    _peek_tween = null
  _peek_tile.reparent(spelling_area)
  _peek_tile.is_in_hand = false
  deck_manager.play_from_hand(_peek_tile.letter)
  _peek_tile = null
  _peek_letter = ""
  _peek_index = 0
  _peek_tile_original_pos = Vector2.ZERO
  update_submit_indicator()


func _cancel_peek():
  _snap_tile_back(_peek_tile)
  _peek_tile = null
  _peek_letter = ""
  _peek_index = 0
  _peek_tile_original_pos = Vector2.ZERO


func _snap_tile_back(tile: LetterTile):
  if _peek_tween != null:
    _peek_tween.kill()
    _peek_tween = null
  tile.position = _peek_tile_original_pos


func _tween_tile_up(tile: LetterTile):
  if _peek_tween != null:
    _peek_tween.kill()
    _peek_tween = null
  _peek_tile_original_pos = tile.position
  _peek_tween = create_tween()
  _peek_tween.tween_property(tile, "position:y", tile.position.y - 12, 0.1)


func _spawn_tile(letter: String, value: int):
  var new_tile = tile_scene.instantiate() as LetterTile
  hand_area.add_child(new_tile)
  new_tile.setup(letter, value)
  new_tile.tile_clicked.connect(_on_tile_clicked)


func update_submit_indicator():
  var word = ""
  for child in spelling_area.get_children():
    if child is LetterTile:
      word += child.letter
  submit_button.disabled = word.length() == 0 or not WordDictionary.is_valid(word)


func _find_leftmost_hand_tile(letter: String) -> LetterTile:
  for child in hand_area.get_children():
    if child is LetterTile and child.letter == letter:
      return child
  return null


func _get_hand_tiles_for_letter(letter: String) -> Array[LetterTile]:
  var result: Array[LetterTile] = []
  for child in hand_area.get_children():
    if child is LetterTile and child.letter == letter:
      result.append(child)
  return result


func _on_tile_clicked(tile: LetterTile):
  if input_locked:
    return
  if tile.is_in_hand:
    tile.reparent(spelling_area)
    tile.is_in_hand = false
    deck_manager.play_from_hand(tile.letter)
  else:
    tile.reparent(hand_area)
    tile.is_in_hand = true
    deck_manager.recall_to_hand(tile.letter)
  update_submit_indicator()
