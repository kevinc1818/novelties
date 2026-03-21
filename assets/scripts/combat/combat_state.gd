extends Node2D

@export var enemy_scene: PackedScene

@onready var hand_manager: HandManager = $HandManager
@onready var combat_animator: CombatAnimator = $CombatAnimator
@onready var reward_system: RewardSystem = $RewardSystem
@onready var enemy: Enemy = $Enemy


func _ready():
  randomize()

  hand_manager.word_submitted.connect(_on_word_submitted)
  hand_manager.submit_button.pressed.connect(hand_manager.try_submit)
  combat_animator.player_attack_finished.connect(_on_player_attack_finished)
  combat_animator.enemy_attack_finished.connect(_on_enemy_attack_finished)
  enemy.enemy_defeated.connect(reward_system._on_enemy_defeated)
  reward_system.next_fight_requested.connect(_on_next_fight)

  combat_animator.set_enemy(enemy)
  hand_manager.refill_hand()


func _on_word_submitted(tiles: Array[LetterTile], _damage: int):
  hand_manager.set_input_locked(true)
  combat_animator.animate_player_attack(tiles)


func _on_player_attack_finished():
  hand_manager.refill_hand()
  if is_instance_valid(enemy) and enemy.current_hp > 0:
    await get_tree().create_timer(0.5).timeout
    combat_animator.animate_enemy_attack()
  else:
    hand_manager.set_input_locked(false)


func _on_enemy_attack_finished():
  hand_manager.set_input_locked(false)


func _on_next_fight():
  hand_manager.set_input_locked(false)
  var new_enemy = enemy_scene.instantiate() as Enemy
  add_child(new_enemy)
  enemy = new_enemy
  enemy.enemy_defeated.connect(reward_system._on_enemy_defeated)
  enemy.position = Vector2(200, -200)
  combat_animator.set_enemy(new_enemy)
  hand_manager.refill_hand()
