extends Node2D

@export var tile_scene: PackedScene
@export var enemy_scene: PackedScene

@onready var deck_manager: DeckManager = $DeckManager
@onready var hand_manager: HandManager = $HandManager
@onready var combat_animator: CombatAnimator = $CombatAnimator
@onready var reward_system: RewardSystem = $RewardSystem

@onready var spelling_area = $VBoxContainer/SpellingArea
@onready var hand_area = $VBoxContainer/HandArea
@onready var submit_button = $VBoxContainer/SubmitButton
@onready var enemy: Enemy = $Enemy
@onready var player: Player = $Player


func _ready():
  randomize()
  hand_manager.setup(deck_manager, hand_area, spelling_area, tile_scene)
  combat_animator.setup(player, enemy, tile_scene, deck_manager)
  reward_system.setup(
    deck_manager,
    $RewardsPanel,
    $RewardsPanel/GoldLabel,
    $RewardsPanel/ContinueButton,
    $UpgradePanel,
    $UpgradePanel/UpgradeButton,
    $UpgradePanel/NextFightButton,
    player
  )

  submit_button.pressed.connect(hand_manager.try_submit)
  hand_manager.word_submitted.connect(_on_word_submitted)
  combat_animator.player_attack_finished.connect(_on_player_attack_finished)
  combat_animator.enemy_attack_finished.connect(_on_enemy_attack_finished)
  enemy.enemy_defeated.connect(reward_system._on_enemy_defeated)
  reward_system.next_fight_requested.connect(_on_next_fight)

  hand_manager.refill_hand()


func _on_word_submitted(tiles: Array[LetterTile], _damage: int):
  submit_button.disabled = true
  combat_animator.animate_player_attack(tiles)


func _on_player_attack_finished():
  hand_manager.refill_hand()
  if is_instance_valid(enemy) and enemy.current_hp > 0:
    await get_tree().create_timer(0.5).timeout
    combat_animator.animate_enemy_attack()
  else:
    submit_button.disabled = false


func _on_enemy_attack_finished():
  submit_button.disabled = false


func _on_next_fight():
  submit_button.disabled = false
  var new_enemy = enemy_scene.instantiate() as Enemy
  add_child(new_enemy)
  enemy = new_enemy
  enemy.enemy_defeated.connect(reward_system._on_enemy_defeated)
  enemy.position = Vector2(200, -200)
  combat_animator.set_enemy(new_enemy)
  hand_manager.refill_hand()
