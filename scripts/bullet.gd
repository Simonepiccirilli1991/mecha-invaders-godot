extends Area2D

# Bullet script - handles bullet movement and cleanup

# Movement speed
@export var speed: float = 600.0

# Direction vector (set by whoever creates the bullet)
var direction: Vector2 = Vector2.UP

func _ready() -> void:
	# Bullets will be added to groups to identify them
	# Groups are set by the spawner (player_bullet or enemy_bullet)
	pass

func _process(delta: float) -> void:
	# Move the bullet in the specified direction
	position += direction * speed * delta
	
	# Remove bullet if it goes off screen
	var screen_size = get_viewport_rect().size
	if position.y < -20 or position.y > screen_size.y + 20:
		queue_free()
