extends Control
class_name PileDisplay

enum PileType { DRAW, DISCARD }

@export var deck_manager: DeckManager
@export var pile_type: PileType
@export var tile_scene: PackedScene

@onready var pile_button: Button = $PileButton
@onready var modal: Control = $UILayer/Modal
@onready var backdrop: ColorRect = $UILayer/Modal/Backdrop
@onready var title_label: Label = $UILayer/Modal/ContentPanel/TitleLabel
@onready var tile_container: HFlowContainer = $UILayer/Modal/ContentPanel/ScrollContainer/TileContainer


func _ready():
  pile_button.focus_mode = FOCUS_NONE
  deck_manager.state_changed.connect(_on_state_changed)
  pile_button.pressed.connect(_toggle_modal)
  _refresh_label()


func _get_pile() -> Array[String]:
  return deck_manager.draw_pile if pile_type == PileType.DRAW else deck_manager.discard_pile


func _toggle_modal():
  modal.visible = not modal.visible
  if modal.visible:
    _populate_tiles()


func _input(event: InputEvent):
  if not modal.visible:
    return
  if not (event is InputEventMouseButton and event.pressed):
    return
  if pile_button.get_global_rect().has_point(event.global_position):
    return
  if not $UILayer/Modal/ContentPanel.get_global_rect().has_point(event.global_position):
    modal.visible = false
    get_viewport().set_input_as_handled()


func _on_state_changed():
  _refresh_label()
  if modal.visible:
    _populate_tiles()


func _refresh_label():
  var label_text = "Draw" if pile_type == PileType.DRAW else "Discard"
  pile_button.text = "%s: %d" % [label_text, _get_pile().size()]


func _populate_tiles():
  for child in tile_container.get_children():
    child.queue_free()
  title_label.text = "Draw Pile" if pile_type == PileType.DRAW else "Discard Pile"
  for letter in _get_pile():
    var tile = tile_scene.instantiate() as LetterTile
    tile_container.add_child(tile)
    tile.setup(letter, deck_manager.letter_values.get(letter, 0))
    tile.disabled = true
