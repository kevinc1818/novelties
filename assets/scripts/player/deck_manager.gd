extends Node
class_name DeckManager

signal state_changed

@export var config: CharacterConfig

var letter_values: Dictionary = {}
var draw_pile: Array[String] = []
var hand: Array[String] = []
var in_play: Array[String] = []
var discard_pile: Array[String] = []


func _ready():
  if config:
    letter_values = config.letter_values.duplicate()
    setup_deck(config.starting_words)


func setup_deck(starting_words: Array[String]):
  draw_pile = []
  hand = []
  in_play = []
  discard_pile = []
  for word in starting_words:
    for letter in word:
      draw_pile.append(letter.to_upper())
  draw_pile.shuffle()
  state_changed.emit()


func draw_to_hand() -> String:
  if draw_pile.is_empty():
    if discard_pile.is_empty():
      return ""
    draw_pile = discard_pile.duplicate()
    discard_pile.clear()
    draw_pile.shuffle()
  var letter = draw_pile.pop_back()
  hand.append(letter)
  state_changed.emit()
  return letter


func play_from_hand(letter: String):
  hand.erase(letter)
  in_play.append(letter)
  state_changed.emit()


func recall_to_hand(letter: String):
  in_play.erase(letter)
  hand.append(letter)
  state_changed.emit()


func submit_in_play():
  discard_pile.append_array(in_play)
  in_play.clear()
  state_changed.emit()


func upgrade_random_letter():
  if draw_pile.is_empty():
    return
  var letter = draw_pile[randi() % draw_pile.size()]
  letter_values[letter] += 1
