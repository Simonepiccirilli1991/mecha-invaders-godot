extends Node2D

# Main scene script - connects all game components and manages game flow

@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner
@onready var hud = $HUD
@onready var game_manager = $GameManager
@onready var start_screen = $StartScreen
@onready var level_transition = $LevelTransition

var is_transitioning: bool = false

func _ready() -> void:
	# Connect player signals
	player.player_hit.connect(_on_player_hit)
	
	# Connect enemy spawner signals
	enemy_spawner.all_enemies_destroyed.connect(_on_all_enemies_destroyed)
	enemy_spawner.enemy_reached_player.connect(_on_enemy_reached_player)
	
	# Connect game manager signals
	game_manager.score_changed.connect(hud.update_score)
	game_manager.lives_changed.connect(hud.update_lives)
	game_manager.level_changed.connect(hud.update_level)
	game_manager.game_over.connect(_on_game_over)
	game_manager.game_won.connect(_on_game_won)
	game_manager.game_started.connect(_on_game_started)
	game_manager.level_complete.connect(_on_level_complete)
	
	# Connect start screen
	start_screen.start_game_pressed.connect(_on_start_game_pressed)
	
	# Connect level transition
	level_transition.transition_complete.connect(_on_transition_complete)
	
	# Set references in game manager
	game_manager.player = player
	game_manager.enemy_spawner = enemy_spawner
	game_manager.hud = hud
	
	# Hide player and HUD until game starts
	player.visible = false
	hud.visible = false

func _on_start_game_pressed() -> void:
	# Start the game
	player.visible = true
	hud.visible = true
	game_manager.start_game()
	start_level(1)

func _on_game_started() -> void:
	# Game has started, show level 1
	pass

func start_level(level_num: int) -> void:
	# Clear any remaining bullets
	clear_bullets()
	
	# Reset player position
	player.position = Vector2(540, 650)
	
	# Show level transition
	is_transitioning = true
	level_transition.show_level(level_num)

func _on_transition_complete() -> void:
	# Transition finished, spawn enemies for this level
	is_transitioning = false
	var config = game_manager.get_level_config()
	enemy_spawner.setup_level(config)
	
	# Connect enemy destroyed signals for all spawned enemies
	await get_tree().process_frame  # Wait one frame for enemies to be added
	for enemy in enemy_spawner.enemies:
		if enemy and is_instance_valid(enemy):
			if not enemy.enemy_destroyed.is_connected(_on_enemy_destroyed):
				enemy.enemy_destroyed.connect(_on_enemy_destroyed)

func clear_bullets() -> void:
	# Remove all bullets from the scene
	for node in get_children():
		if node.is_in_group("player_bullet") or node.is_in_group("enemy_bullet"):
			node.queue_free()

func _on_player_hit() -> void:
	if not is_transitioning:
		game_manager.lose_life()

func _on_enemy_destroyed(points: int) -> void:
	game_manager.add_score(points)

func _on_all_enemies_destroyed() -> void:
	print("Main: All enemies destroyed signal received!")
	if not is_transitioning:
		print("Main: Calling complete_level()")
		game_manager.complete_level()
	else:
		print("Main: Is transitioning, ignoring...")

func _on_level_complete() -> void:
	print("Main: Level complete signal received! Starting level ", game_manager.current_level)
	# Current level complete, start next level
	start_level(game_manager.current_level)

func _on_enemy_reached_player() -> void:
	if not is_transitioning:
		game_manager.end_game(false)

func _on_game_over() -> void:
	hud.show_game_over(false, game_manager.score)

func _on_game_won() -> void:
	hud.show_game_over(true, game_manager.score)
