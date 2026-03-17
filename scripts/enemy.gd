extends Area2D

# Enemy alien script - handles movement and getting destroyed

# Movement settings
@export var move_speed: float = 50.0
@export var descent_amount: float = 20.0

# Points awarded when destroyed
@export var points: int = 10

# Signals
signal enemy_destroyed(points: int)
signal enemy_reached_bottom

# Movement direction (1 = right, -1 = left)
var direction: int = 1
var can_move: bool = true

func _ready() -> void:
	# Add to enemy group for easy reference
	add_to_group("enemies")
	
	# Connect collision signal
	area_entered.connect(_on_area_entered)

func move_horizontal(delta: float) -> void:
	# Move left or right based on direction
	position.x += direction * move_speed * delta

func reverse_direction() -> void:
	# Change direction and move down
	direction *= -1
	position.y += descent_amount
	
	# Check if enemy reached the bottom of the screen
	if position.y > get_viewport_rect().size.y - 100:
		enemy_reached_bottom.emit()

func _on_area_entered(area: Area2D) -> void:
	# Check if hit by player bullet
	if area.is_in_group("player_bullet"):
		# Destroy both bullet and enemy
		area.queue_free()
		destroy()

func destroy() -> void:
	# Disable immediately to prevent further processing
	set_process(false)
	visible = false
	
	# Emit signal with points before destroying
	enemy_destroyed.emit(points)
	
	# Queue for deletion
	queue_free()
