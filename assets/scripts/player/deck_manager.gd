extends Node
class_name DeckManager

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

var draw_pile: Array[String] = []
var discard_pile: Array[String] = []


func _ready():
  setup_deck()


func setup_deck():
  var starting_letters: Array[String] = ["A", "A", "E", "E", "I", "O", "R", "R", "S", "S", "T", "T", "L", "N", "P"]
  draw_pile = starting_letters.duplicate()
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
