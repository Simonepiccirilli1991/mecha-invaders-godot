extends CanvasLayer

# Level transition screen - shows level number before starting

signal transition_complete

@onready var level_label = $CenterContainer/VBoxContainer/LevelLabel
@onready var ready_label = $CenterContainer/VBoxContainer/ReadyLabel

func show_level(level: int) -> void:
	level_label.text = "LEVEL " + str(level)
	visible = true
	
	# Wait 2 seconds then signal completion
	await get_tree().create_timer(2.0).timeout
	transition_complete.emit()
	visible = false
