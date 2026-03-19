extends Node

# Game manager - handles game state, score, lives, and level progression

enum GameState { MENU, PLAYING, GAME_OVER, WIN }

var current_state: GameState = GameState.MENU
var score: int = 0
var lives: int = 3
var current_level: int = 1
const MAX_LEVELS: int = 10

# Level configurations - difficulty increases each level
var level_configs = [
	# Level 1 - The Burning City
	{ "rows": 4, "columns": 10, "speed": 50, "descent": 20, "shoot_interval": 2.5, "sprite": "res://sprites/enemy_ship_level_1.svg", "background": "res://sprites/backgrounds/bg_level_1.svg" },
	# Level 2 - Nuclear Fallout
	{ "rows": 4, "columns": 10, "speed": 58, "descent": 22, "shoot_interval": 2.3, "sprite": "res://sprites/enemy_ship_level_2.svg", "background": "res://sprites/backgrounds/bg_level_2.svg" },
	# Level 3 - The Great Flood
	{ "rows": 5, "columns": 10, "speed": 66, "descent": 24, "shoot_interval": 2.1, "sprite": "res://sprites/enemy_ship_level_3.svg", "background": "res://sprites/backgrounds/bg_level_3.svg" },
	# Level 4 - Volcanic Hellscape
	{ "rows": 5, "columns": 11, "speed": 76, "descent": 26, "shoot_interval": 1.9, "sprite": "res://sprites/enemy_ship_level_4.svg", "background": "res://sprites/backgrounds/bg_level_4.svg" },
	# Level 5 - Frozen Abyss
	{ "rows": 6, "columns": 11, "speed": 87, "descent": 28, "shoot_interval": 1.7, "sprite": "res://sprites/enemy_ship_level_5.svg", "background": "res://sprites/backgrounds/bg_level_5.svg" },
	# Level 6 - Toxic Plague
	{ "rows": 6, "columns": 12, "speed": 100, "descent": 30, "shoot_interval": 1.5, "sprite": "res://sprites/enemy_ship_level_6.svg", "background": "res://sprites/backgrounds/bg_level_6.svg" },
	# Level 7 - Desert of Bones
	{ "rows": 7, "columns": 12, "speed": 115, "descent": 32, "shoot_interval": 1.3, "sprite": "res://sprites/enemy_ship_level_7.svg", "background": "res://sprites/backgrounds/bg_level_7.svg" },
	# Level 8 - The Void Opens
	{ "rows": 7, "columns": 12, "speed": 132, "descent": 34, "shoot_interval": 1.2, "sprite": "res://sprites/enemy_ship_level_8.svg", "background": "res://sprites/backgrounds/bg_level_8.svg" },
	# Level 9 - Machine Apocalypse
	{ "rows": 8, "columns": 12, "speed": 152, "descent": 36, "shoot_interval": 1.0, "sprite": "res://sprites/enemy_ship_level_9.svg", "background": "res://sprites/backgrounds/bg_level_9.svg" },
	# Level 10 - Final Armageddon
	{ "rows": 8, "columns": 12, "speed": 175, "descent": 38, "shoot_interval": 0.9, "sprite": "res://sprites/enemy_ship_level_10.svg", "background": "res://sprites/backgrounds/bg_level_10.svg" }
]

# Signals for UI updates
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal level_changed(new_level: int)
signal game_over
signal game_won
signal game_started
signal level_complete

# References (set by main scene)
var player: Node2D
var enemy_spawner: Node2D
var hud: Control

func _ready() -> void:
	pass

func start_game() -> void:
	# Reset game state
	current_state = GameState.PLAYING
	score = 0
	current_level = 1
	
	# Apply mecha lives modifier
	var mecha_stats = MechaSelector.get_mecha_stats()
	lives = 3 + mecha_stats["lives_modifier"]
	print("GameManager: Starting with ", lives, " lives (modifier: ", mecha_stats["lives_modifier"], ")")
	
	# Emit initial values
	score_changed.emit(score)
	lives_changed.emit(lives)
	level_changed.emit(current_level)
	game_started.emit()

func get_level_config() -> Dictionary:
	# Return config for current level (0-indexed array)
	return level_configs[current_level - 1]

func complete_level() -> void:
	print("GameManager: complete_level() called. Current level: ", current_level)
	# Award level completion bonus
	var bonus = current_level * 100
	add_score(bonus)
	
	# Check if this was the final level
	if current_level >= MAX_LEVELS:
		print("GameManager: Max level reached! Victory!")
		end_game(true)  # Victory!
	else:
		# Move to next level
		current_level += 1
		print("GameManager: Moving to level ", current_level)
		level_changed.emit(current_level)
		level_complete.emit()

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	
	if lives <= 0:
		end_game(false)

func end_game(won: bool) -> void:
	if won:
		current_state = GameState.WIN
		game_won.emit()
	else:
		current_state = GameState.GAME_OVER
		game_over.emit()

func restart_game() -> void:
	# Reload the current scene
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	# Handle restart input
	if event.is_action_pressed("restart"):
		if current_state == GameState.GAME_OVER or current_state == GameState.WIN:
			restart_game()
