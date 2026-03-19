extends CanvasLayer

# HUD script - displays score, lives, level, special charge, ultimate cooldown, and game over screen

@onready var score_label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var lives_label = $MarginContainer/VBoxContainer/LivesLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var special_label = $MarginContainer/VBoxContainer/SpecialLabel
@onready var ultimate_label = $MarginContainer/VBoxContainer/UltimateLabel
@onready var weapon_label = $MarginContainer/VBoxContainer/WeaponLabel
@onready var game_over_panel = $GameOverPanel
@onready var message_label = $GameOverPanel/VBoxContainer/MessageLabel
@onready var final_score_label = $GameOverPanel/VBoxContainer/ScoreLabel

var _special_name: String = "SPECIAL"
var _ultimate_name: String = "ULTIMATE"

func _ready() -> void:
	game_over_panel.visible = false

func update_score(score: int) -> void:
	score_label.text = "Score: " + str(score)

func update_lives(lives: int) -> void:
	lives_label.text = "Lives: " + str(lives)

func update_level(level: int) -> void:
	level_label.text = "Level: " + str(level)

func set_special_name(name: String) -> void:
	_special_name = name

func set_ultimate_name(name: String) -> void:
	_ultimate_name = name
	ultimate_label.text = _ultimate_name + ": READY! [Z]"

func set_weapon_name(weapon_display_name: String) -> void:
	weapon_label.text = "WEAPON: " + weapon_display_name

func update_special(current: int, needed: int, is_ready: bool) -> void:
	if is_ready:
		special_label.text = _special_name + ": READY! [X]"
		special_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.0))
	else:
		special_label.text = "%s: %d/%d [X]" % [_special_name, current, needed]
		special_label.remove_theme_color_override("font_color")

func update_ultimate(remaining: float, max_val: float, is_ready: bool) -> void:
	if is_ready:
		ultimate_label.text = _ultimate_name + ": READY! [Z]"
		ultimate_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		ultimate_label.text = "%s: %.1fs [Z]" % [_ultimate_name, remaining]
		ultimate_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

func show_game_over(won: bool, final_score: int) -> void:
	game_over_panel.visible = true

	if won:
		message_label.text = "VICTORY!"
		message_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		message_label.text = "GAME OVER"
		message_label.add_theme_color_override("font_color", Color.RED)

	final_score_label.text = "Final Score: " + str(final_score)
