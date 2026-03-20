extends Button
class_name LetterTile

signal tile_clicked(tile_node: LetterTile)  # signal click to the main board

@onready var letter_label = $LetterLabel
@onready var value_label = $ValueLabel

var letter: String = ""
var point_value: int = 0
var is_in_hand: bool = true


func _ready():
  pressed.connect(_on_button_pressed)


func setup(_letter: String, _value: int):
  letter = _letter
  point_value = _value

  letter_label.text = letter
  value_label.text = str(point_value)


func _on_button_pressed():
  tile_clicked.emit(self)
