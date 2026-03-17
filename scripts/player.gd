extends Area2D

# Player ship script - handles movement, shooting, and collision

# Movement speed (pixels per second)
@export var speed: float = 400.0

# Shoot settings
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.5  # Time between shots in seconds
var can_shoot: bool = true

# Screen boundaries
var screen_size: Vector2

# Signals to communicate with game manager
signal player_hit
signal bullet_fired

func _ready() -> void:
	# Get the viewport size for boundary checking
	screen_size = get_viewport_rect().size
	
	# Connect the area_entered signal to detect collisions
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	# Handle player movement
	var velocity = Vector2.ZERO
	
	# Check for left/right input
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	# Move the player
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		position += velocity * delta
	
	# Clamp position to screen boundaries (with some padding)
	position.x = clamp(position.x, 32, screen_size.x - 32)
	
	# Handle shooting
	if Input.is_action_pressed("shoot") and can_shoot and bullet_scene:
		shoot()

func shoot() -> void:
	# Create and fire a bullet
	can_shoot = false
	
	# Instantiate the bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -20)  # Spawn above player
	bullet.direction = Vector2.UP  # Shoot upward
	bullet.collision_layer = 4  # PlayerBullet layer
	bullet.collision_mask = 2   # Can hit enemies
	bullet.add_to_group("player_bullet")
	
	# Add bullet to the scene tree (same level as player)
	get_parent().add_child(bullet)
	
	# Emit signal for sound effects or other feedback
	bullet_fired.emit()
	
	# Start cooldown timer
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func _on_area_entered(area: Area2D) -> void:
	# Detect when an enemy bullet hits the player
	if area.is_in_group("enemy_bullet"):
		player_hit.emit()
		area.queue_free()  # Remove the bullet

func take_damage() -> void:
	# Called when player is hit
	player_hit.emit()
