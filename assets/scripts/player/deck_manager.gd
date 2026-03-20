extends Node
class_name DeckManager

@export var config: CharacterConfig

var letter_values: Dictionary = {}
var draw_pile: Array[String] = []
var discard_pile: Array[String] = []


func _ready():
  if config:
    letter_values = config.letter_values.duplicate()
    setup_deck(config.starting_words)


func setup_deck(starting_words: Array[String]):
  draw_pile = []
  for word in starting_words:
    for letter in word:
      draw_pile.append(letter.to_upper())
  draw_pile.shuffle()


func draw_letter() -> String:
  if draw_pile.is_empty():
    if discard_pile.is_empty():
      return ""
    draw_pile = discard_pile.duplicate()
    discard_pile.clear()
    draw_pile.shuffle()
  return draw_pile.pop_back()


func discard_letter(letter: String):
  discard_pile.append(letter)


func upgrade_random_letter():
  if draw_pile.is_empty():
    return
  var letter = draw_pile[randi() % draw_pile.size()]
  letter_values[letter] += 1
