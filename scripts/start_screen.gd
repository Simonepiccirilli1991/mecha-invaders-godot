extends CanvasLayer

# Start screen - displays title and waits for player to start

signal start_game_pressed

@onready var title_label = $CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label = $CenterContainer/VBoxContainer/SubtitleLabel
@onready var instruction_label = $CenterContainer/VBoxContainer/InstructionLabel

func _ready() -> void:
	# Animate instruction text (blink effect)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(instruction_label, "modulate:a", 0.3, 1.0)
	tween.tween_property(instruction_label, "modulate:a", 1.0, 1.0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):  # Space key
		start_game_pressed.emit()
		queue_free()  # Remove start screen
