extends Node
class_name CombatAnimator

signal player_attack_finished
signal enemy_attack_finished

@export var player: Player
@export var tile_scene: PackedScene
@export var deck_manager: DeckManager

var enemy: Enemy


func set_enemy(new_enemy: Enemy):
  enemy = new_enemy


func animate_player_attack(tiles: Array[LetterTile]):
  var player_center = player.global_position + Vector2(50, 50)
  var radius = 90.0
  var gather_tween = create_tween().set_parallel(true)

  for i in range(tiles.size()):
    var tile = tiles[i]
    if not is_instance_valid(tile):
      continue

    var start_global_pos = tile.global_position
    tile.reparent(get_parent())
    tile.global_position = start_global_pos

    var angle: float
    if tiles.size() == 1:
      angle = -PI / 2.0
    else:
      var percentage = float(i) / float(tiles.size() - 1)
      angle = lerp(deg_to_rad(-150), deg_to_rad(-30), percentage)

    var target_pos = player_center + (Vector2.from_angle(angle) * radius)
    (
      gather_tween
      . tween_property(tile, "global_position", target_pos, 0.5)
      . set_trans(Tween.TRANS_SINE)
      . set_ease(Tween.EASE_OUT)
    )

  await gather_tween.finished
  await get_tree().create_timer(0.2).timeout

  var last_enemy_pos = Vector2.ZERO
  if is_instance_valid(enemy):
    last_enemy_pos = enemy.global_position + Vector2(50, 50)

  for tile in tiles:
    if not is_instance_valid(tile):
      continue

    var shoot_tween = create_tween()
    if is_instance_valid(enemy):
      last_enemy_pos = enemy.global_position + Vector2(50, 50)

    var tweener = shoot_tween.tween_property(tile, "global_position", last_enemy_pos, 0.15)
    if tweener:
      tweener.set_ease(Tween.EASE_IN)
    await shoot_tween.finished

    if is_instance_valid(enemy) and enemy.current_hp > 0:
      enemy.take_damage(tile.point_value)
    _spawn_damage_number(tile.point_value, last_enemy_pos)
    deck_manager.discard_letter(tile.letter)
    tile.queue_free()
    await get_tree().create_timer(0.05).timeout

  player_attack_finished.emit()


func animate_enemy_attack():
  var attack_words = ["SMASH", "CRUSH", "POUND", "SLASH", "BLAST"]
  var word = attack_words.pick_random()
  var tiles: Array[LetterTile] = []
  var enemy_center = enemy.global_position + Vector2(50, 50)
  var player_center = player.global_position + Vector2(50, 50)

  for letter in word:
    var new_tile = tile_scene.instantiate() as LetterTile
    get_parent().add_child(new_tile)
    new_tile.setup(letter, deck_manager.letter_values.get(letter, 1))
    new_tile.global_position = enemy_center
    new_tile.disabled = true
    tiles.append(new_tile)

  var gather_tween = create_tween().set_parallel(true)
  var radius = 90.0

  for i in range(tiles.size()):
    var tile = tiles[i]
    var percentage = float(i) / float(tiles.size() - 1)
    var angle = lerp(deg_to_rad(-150), deg_to_rad(-30), percentage)
    var target_pos = enemy_center + (Vector2.from_angle(angle) * radius)
    (
      gather_tween
      . tween_property(tile, "global_position", target_pos, 0.5)
      . set_trans(Tween.TRANS_SINE)
      . set_ease(Tween.EASE_OUT)
    )

  await gather_tween.finished
  await get_tree().create_timer(0.2).timeout

  for tile in tiles:
    if not is_instance_valid(tile):
      continue

    var shoot_tween = create_tween()
    var tweener = shoot_tween.tween_property(tile, "global_position", player_center, 0.15)
    if tweener:
      tweener.set_ease(Tween.EASE_IN)
    await shoot_tween.finished

    if is_instance_valid(player) and player.current_hp > 0:
      player.take_damage(tile.point_value)
      _spawn_damage_number(tile.point_value, player_center)
    tile.queue_free()
    await get_tree().create_timer(0.05).timeout

  if player.current_hp <= 0:
    print("You were defeated by ", word, "!")
  enemy_attack_finished.emit()


func _spawn_damage_number(amount: int, spawn_pos: Vector2):
  var label = Label.new()
  label.text = str(amount)
  label.modulate = Color(1.0, 0.2, 0.2)
  label.scale = Vector2(1.5, 1.5)
  label.z_index = 100
  label.custom_minimum_size = Vector2(50, 50)
  get_parent().add_child(label)
  label.global_position = spawn_pos + Vector2(randf_range(-25, 25), randf_range(-25, 25))

  var tween = create_tween().set_parallel(true)
  (
    tween
    . tween_property(label, "global_position", label.global_position + Vector2(0, -50), 0.6)
    . set_ease(Tween.EASE_OUT)
  )
  tween.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
  await tween.finished
  label.queue_free()
