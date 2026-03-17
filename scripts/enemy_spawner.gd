extends Node2D

# Enemy spawner - manages the enemy formation and movement

@export var enemy_scene: PackedScene
@export var enemy_bullet_scene: PackedScene

# These will be set by level config
var rows: int = 4
var columns: int = 10
var spacing: Vector2 = Vector2(80, 60)
var start_position: Vector2 = Vector2(100, 100)
var move_speed: float = 50.0
var descent_amount: float = 20.0
var shoot_interval: float = 2.0

var enemies: Array[Node] = []
var enemies_alive: int = 0  # Track count separately
var move_direction: int = 1
var edge_reached: bool = false

signal all_enemies_destroyed
signal enemy_reached_player

func _ready() -> void:
	pass  # Don't spawn immediately - wait for setup_level() call

func setup_level(config: Dictionary) -> void:
	# Clear any existing enemies
	clear_enemies()
	
	# Apply level configuration
	rows = config["rows"]
	columns = config["columns"]
	move_speed = config["speed"]
	descent_amount = config["descent"]
	shoot_interval = config["shoot_interval"]
	
	# Reset direction to start moving right
	move_direction = 1
	
	# Reset enemy count
	enemies_alive = rows * columns
	print("EnemySpawner: Setting up level with ", enemies_alive, " enemies")
	
	# Adjust starting position based on number of columns
	var total_width = (columns - 1) * spacing.x
	start_position.x = (get_viewport_rect().size.x - total_width) / 2.0
	
	# Ensure start position isn't too close to edge
	start_position.x = max(60.0, start_position.x)
	
	# Spawn enemies for this level
	spawn_enemies()
	
	# Start enemy shooting timer
	var shoot_timer = Timer.new()
	shoot_timer.name = "ShootTimer"
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.autostart = true
	add_child(shoot_timer)

func clear_enemies() -> void:
	# Remove all existing enemies and timers
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()
	enemies_alive = 0
	
	# Remove old shoot timer if exists
	var old_timer = get_node_or_null("ShootTimer")
	if old_timer:
		old_timer.queue_free()

func spawn_enemies() -> void:
	# Create a grid of enemies
	for row in range(rows):
		for col in range(columns):
			var enemy = enemy_scene.instantiate()
			var pos = start_position + Vector2(col * spacing.x, row * spacing.y)
			enemy.position = pos
			enemy.direction = move_direction
			enemy.move_speed = move_speed  # Set enemy speed from config
			enemy.descent_amount = descent_amount  # Set descent from config
			
			# Connect signals
			enemy.enemy_destroyed.connect(_on_enemy_destroyed)
			enemy.enemy_reached_bottom.connect(_on_enemy_reached_bottom)
			
			add_child(enemy)
			enemies.append(enemy)

func _process(delta: float) -> void:
	# Move all enemies together
	edge_reached = false
	
	# First, move all enemies
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			# Ensure enemy direction matches spawner direction
			enemy.direction = move_direction
			enemy.move_horizontal(delta)
	
	# Then check if any reached the edge
	var screen_width = get_viewport_rect().size.x
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			# Check boundaries
			if (enemy.position.x <= 40 and move_direction == -1) or \
			   (enemy.position.x >= screen_width - 40 and move_direction == 1):
				edge_reached = true
				break  # No need to check more

	# If edge reached, reverse all enemies
	if edge_reached:
		move_direction *= -1
		for enemy in enemies:
			if enemy and is_instance_valid(enemy):
				enemy.direction = move_direction
				enemy.reverse_direction()

func _on_enemy_destroyed(points: int) -> void:
	print("EnemySpawner: Enemy destroyed with ", points, " points")
	
	# Decrement count
	enemies_alive -= 1
	
	print("EnemySpawner: Remaining enemies: ", enemies_alive)
	
	# Check if all enemies are destroyed
	if enemies_alive <= 0:
		print("EnemySpawner: All enemies destroyed! Emitting signal...")
		all_enemies_destroyed.emit()
	
	# Also clean up the array for movement purposes
	await get_tree().process_frame
	enemies = enemies.filter(func(e): return e != null and is_instance_valid(e))

func _on_enemy_reached_bottom() -> void:
	enemy_reached_player.emit()

func _on_shoot_timer_timeout() -> void:
	# Random enemy shoots
	if enemies.size() > 0 and enemy_bullet_scene:
		var valid_enemies = enemies.filter(func(e): return e != null and is_instance_valid(e))
		if valid_enemies.size() > 0:
			var random_enemy = valid_enemies[randi() % valid_enemies.size()]
			shoot_from_enemy(random_enemy)

func shoot_from_enemy(enemy: Node2D) -> void:
	# Create enemy bullet
	var bullet = enemy_bullet_scene.instantiate()
	bullet.position = enemy.position + Vector2(0, 20)
	bullet.direction = Vector2.DOWN
	bullet.collision_layer = 8  # EnemyBullet layer
	bullet.collision_mask = 1   # Can hit player
	bullet.add_to_group("enemy_bullet")
	get_parent().add_child(bullet)
