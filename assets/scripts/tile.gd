extends Button
class_name LetterTile

# Signals let this tile "shout" to the main board that it was clicked
signal tile_clicked(tile_node: LetterTile)

@onready var letter_label = $LetterLabel
@onready var value_label = $ValueLabel

var letter: String = ""
var point_value: int = 0
var is_in_hand: bool = true # Tracks where the tile currently is

func _ready():
	# Connect the button's built-in pressed signal to our custom function
	pressed.connect(_on_button_pressed)

# A setup function to call when we spawn a tile
func setup(_letter: String, _value: int):
	letter = _letter
	point_value = _value
	
	letter_label.text = letter
	value_label.text = str(point_value)

func _on_button_pressed():
	# When clicked, emit our custom signal and pass 'self' (this specific tile)
	tile_clicked.emit(self)
