extends Area2D

# Enemy alien script - handles movement and getting destroyed

# Movement settings
@export var move_speed: float = 50.0
@export var descent_amount: float = 20.0

# Points awarded when destroyed
@export var points: int = 10

# Sprite to display (set by EnemySpawner based on level config)
var sprite_path: String = "res://sprites/enemy_alien.svg"

# Signals
signal enemy_destroyed(points: int)
signal enemy_reached_bottom

# Movement direction (1 = right, -1 = left)
var direction: int = 1
var can_move: bool = true

# --- Animation state ---------------------------------------------------------
var _tilt_current: float = 0.0
var _hover_time: float = 0.0
var _flash_tween: Tween
var _death_tween: Tween

func _ready() -> void:
	add_to_group("enemies")
	_apply_sprite()
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not can_move or not $Sprite2D:
		return
	# Idle tilt: lean in the direction of travel for a dynamic feel
	var target_tilt = deg_to_rad(direction * 6.0)
	_tilt_current = lerp(_tilt_current, target_tilt, 1.0 - exp(-5.0 * delta))
	# Gentle hover oscillation
	_hover_time += delta
	$Sprite2D.position.y = sin(_hover_time * 1.8) * 2.5
	$Sprite2D.rotation = _tilt_current

func _apply_sprite() -> void:
	var texture = load(sprite_path)
	if texture:
		$Sprite2D.texture = texture

func move_horizontal(delta: float) -> void:
	if not can_move:
		return
	position.x += direction * move_speed * delta

func reverse_direction() -> void:
	direction *= -1
	position.y += descent_amount
	if position.y > get_viewport_rect().size.y - 100:
		enemy_reached_bottom.emit()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		if not area.piercing:
			area.queue_free()
		destroy()

func destroy() -> void:
	# Stop movement and disable collision immediately
	can_move = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Notify score/spawner right away so game logic stays correct
	enemy_destroyed.emit(points)

	# Animated death: flash white, spin and shrink, then free
	if _death_tween:
		_death_tween.kill()
	var spr = $Sprite2D
	_death_tween = create_tween()
	_death_tween.tween_property(spr, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.05)
	_death_tween.parallel().tween_property(spr, "scale", spr.scale * 1.3, 0.05)
	_death_tween.tween_property(spr, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.15)
	_death_tween.parallel().tween_property(spr, "scale", Vector2.ZERO, 0.15)
	_death_tween.parallel().tween_property(spr, "rotation", spr.rotation + deg_to_rad(90.0), 0.15)
	_death_tween.tween_callback(queue_free)
