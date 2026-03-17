extends CanvasLayer

# HUD script - displays score, lives, level, and game over screen

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label = $MarginContainer/VBoxContainer/LivesLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var game_over_panel = $GameOverPanel
@onready var message_label = $GameOverPanel/VBoxContainer/MessageLabel
@onready var final_score_label = $GameOverPanel/VBoxContainer/ScoreLabel

func _ready() -> void:
	game_over_panel.visible = false

func update_score(score: int) -> void:
	score_label.text = "Score: " + str(score)

func update_lives(lives: int) -> void:
	lives_label.text = "Lives: " + str(lives)

func update_level(level: int) -> void:
	level_label.text = "Level: " + str(level)

func show_game_over(won: bool, final_score: int) -> void:
	game_over_panel.visible = true
	
	if won:
		message_label.text = "VICTORY!"
		message_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		message_label.text = "GAME OVER"
		message_label.add_theme_color_override("font_color", Color.RED)
	
	final_score_label.text = "Final Score: " + str(final_score)
