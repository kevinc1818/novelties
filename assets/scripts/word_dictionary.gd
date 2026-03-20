extends Node

var _words: Dictionary = {}


func _ready():
  var file = FileAccess.open("res://assets/words/words.txt", FileAccess.READ)
  if not file:
    push_error("Failed to open assets/words/words.txt")
    return
  var content = file.get_as_text()
  file.close()
  for word in content.split("\n", false):
    _words[word.strip_edges().to_upper()] = true


func is_valid(word: String) -> bool:
  return _words.has(word.to_upper())
