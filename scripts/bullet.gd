extends Area2D

# Bullet script - handles bullet movement and cleanup

@export var speed: float = 600.0
var direction: Vector2 = Vector2.UP

# Visual and behavior properties set by whoever spawns this bullet
var bullet_color: Color = Color.WHITE
var bullet_scale: Vector2 = Vector2(1.0, 1.0)
var piercing: bool = false  # If true, bullet passes through enemies

func _ready() -> void:
	$Sprite2D.modulate = bullet_color
	scale = bullet_scale

func _process(delta: float) -> void:
	position += direction * speed * delta

	var screen_size = get_viewport_rect().size
	if position.y < -40 or position.y > screen_size.y + 40 or \
	   position.x < -40 or position.x > screen_size.x + 40:
		queue_free()
